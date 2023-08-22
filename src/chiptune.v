// Title:   Sound generator
// File:    chiptune.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description: The instructions set is similar to an enhanced 6502 with
// an Audio Processing Unit (APU), designated the RP2A03 found in NTSC Nintendo consoles.

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

  wire clk;
  wire clk_uart;
  wire enable_240hz;  // 240 Hz
  wire enable_120hz;  // 120 Hz
  wire [16*8-1:0] reg_data;
  wire [7:0] reg_array [0:15];
  wire [3:0] reg_event;
  wire [3:0] pulse1_out;
  wire [3:0] pulse2_out;
  wire [3:0] tri_out;
  wire [5:0] pwm_data;
  reg reset /* synthesis syn_preserve=1 */;
  reg reset_meta;
  assign dac = pwm_data[5:2];

  genvar i;
  for (i=0; i<=15; i=i+1) assign reg_array[i] = reg_data[8*i+7:8*i];

  // Synchronize external reset to clock
  always @(posedge clk) begin
    if (rst_n == 0) begin
      reset <= 1;
      reset_meta <= 1;
    end else begin      
      reset <= reset_meta;
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
    .clk      (clk_uart),
    .rx       (rx),
    .reg_data (reg_data),
    .reg_event(reg_event)
  );

  frame #(
    .CLKRATE(CLKRATE)
  ) frame_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz)
  );
  
  square square1_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .reg_4000    (reg_array[4'h0]),
    .reg_4001    (reg_array[4'h1]),
    .reg_4002    (reg_array[4'h2]),
    .reg_4003    (reg_array[4'h3]),
    .reg_change  (reg_event[0]),
    .pulse_out   (pulse1_out)
  );

  square square2_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .reg_4000    (reg_array[4'h4]),
    .reg_4001    (reg_array[4'h5]),
    .reg_4002    (reg_array[4'h6]),
    .reg_4003    (reg_array[4'h7]),
    .reg_change  (reg_event[1]),
    .pulse_out   (pulse2_out)
  );

  triangle triangle_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .reg_4008    (reg_array[4'h8]),
    .reg_400A    (reg_array[4'hA]),
    .reg_400B    (reg_array[4'hB]),
    .reg_change  (reg_event[2]),
    .tri_out     (tri_out)
  );

  // noise generator

  // mixer
  assign pwm_data = {2'b00, pulse1_out} + {2'b00, pulse2_out} + {2'b00, tri_out};

  audio_pwm #(
    .WIDTH(6)
  ) audio_pwm_inst (
    .clk  (clk),
    .reset(reset),
    .data (pwm_data),
    .pwm  (pwm)
  );

endmodule
