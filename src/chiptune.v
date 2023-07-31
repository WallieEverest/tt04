// Title:   Sound generator
// File:    chiptune.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

`default_nettype none

module chiptune #(
  parameter OSCRATE = 12_000_000,  // external oscillator
  parameter BAUDRATE = 9600        // serial baud rate
)(
  input  wire osc,        // external oscillator
  input  wire rst_n,      // asynchronous reset
  input  wire rx,         // serial data
  output wire pwm,        // audio PWM
  output wire [3:0] dac,  // audio DAC
  output wire blink,      // status LED
  output wire link        // link LED
) /* synthesis syn_hier="fixed" */;

  localparam CLKRATE = 1_790_000;  // number of bits in message

  wire clk;
  wire clk_uart;
  wire [7:0] reg_4000;
  wire [7:0] reg_4001;
  wire [7:0] reg_4002;
  wire [7:0] reg_4003;
  wire enable_240hz;  // 240 Hz
  wire enable_120hz;  // 120 Hz
  wire reg_change;
  wire [3:0] pulse_out;
  reg reset = 1 /* synthesis syn_preserve=1 */;
  assign dac = pulse_out;

  // Synchronize external reset to clock
  always @(posedge clk) begin
    if (rst_n == 1)
      reset <= 0;
    else
      reset <= 1;
  end

  prescaler #(
    .OSCRATE(OSCRATE),    // oscillator frequency
    .BAUDRATE(BAUDRATE),  // baud rate
    .CLKRATE(1_790_000)   // system clock frequency
  ) prescaler_inst (
    .osc     (osc),       // system oscillator
    .rx      (rx),        // serial input for activity indicator
    .clk     (clk),       // APU system clock, ~1.79 MHz
    .clk_uart(clk_uart),  // 5x UART clock, 48 kHz
    .blink   (blink),     // 1 Hz blink indicator
    .link    (link)       // activity indicator
  );

  uart uart_inst (
    .clk       (clk_uart),
    .rx        (rx),
    .reg_4000  (reg_4000),
    .reg_4001  (reg_4001),
    .reg_4002  (reg_4002),
    .reg_4003  (reg_4003),
    .reg_change(reg_change)
  );

  frame #(
    .CLKRATE(CLKRATE)
  ) frame_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz)
  );
  
  rectangle rectangle_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .reg_4000    (reg_4000),
    .reg_4001    (reg_4001),
    .reg_4002    (reg_4002),
    .reg_4003    (reg_4003),
    .reg_change  (reg_change),
    .pulse_out   (pulse_out)
  );

  audio_pwm #(
    .WIDTH(4)
  ) audio_pwm_inst (
    .clk  (clk),
    .reset(reset),
    .data (pulse_out),
    .pwm  (pwm)
  );

endmodule
