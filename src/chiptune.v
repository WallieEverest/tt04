// Title:   Sound generator
// File:    chiptune.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description: The instructions set is similar to an enhanced 6502 with
// a sound generator designated the RP2A03 found in some Nintendo products.

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

  localparam CLKRATE = 1_790_000;  // APU system clock
  // Note: [Heil and Zhao] mention 894 kHz instead, possibly with a differnt frame rate divider

  wire clk;
  wire clk_uart;
  wire [7:0] reg_4000;
  wire [7:0] reg_4001;
  wire [7:0] reg_4002;
  wire [7:0] reg_4003;
  wire [7:0] reg_4007;
  wire [7:0] reg_4008;
  wire [7:0] reg_400A;
  wire [7:0] reg_400B;
  wire enable_240hz;  // 240 Hz
  wire enable_120hz;  // 120 Hz
  wire reg_change;
  wire [3:0] pulse_out;
  reg reset /* synthesis syn_preserve=1 */;
  reg reset_meta;
  assign dac = pulse_out;

  // Synchronize external reset to clock
  always @(posedge clk) begin
    if (rst_n == 0) begin
      reset      <= 1;
      reset_meta <= 1;
    end else begin      
      reset      <= reset_meta;
      reset_meta <= 0;
    end
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
    .reg_4007  (reg_4007),
    .reg_4008  (reg_4008),
    .reg_400A  (reg_400A),
    .reg_400B  (reg_400B),
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
