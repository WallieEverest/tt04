// Title:   Sound generator
// File:    apu.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description: The instructions set is similar to an enhanced 6502 with
// an Audio Processing Unit (APU), designated the RP2A03 found in NTSC Nintendo consoles.

`default_nettype none

module apu #(
  parameter OSCRATE = 12_000_000,  // external oscillator
  parameter BAUDRATE = 9600        // serial baud rate
)(
  input  wire apu_clk,  // APU clock
  input  wire clk,      // external oscillator
  input  wire rst_n,    // asynchronous reset
  input  wire rx,       // serial data
  output wire apu_ref,  // 1.79 MHz
  output wire blink,    // status LED
  output wire link,     // link LED
  output wire pwm       // audio PWM
);

  localparam CLKRATE = 1_790_000;  // APU system clock

  wire uart_clk;      // 48 kHz
  wire enable_240hz;  // 240 Hz
  wire enable_120hz;  // 120 Hz
  wire [16*8-1:0] reg_data;
  wire [7:0] reg_array [0:15];
  wire [3:0] reg_event;
  wire [3:0] pulse1_out;
  wire [3:0] pulse2_out;
  wire [3:0] tri_out;
  wire [3:0] noise_out;
  wire [5:0] pwm_data;
  wire [3:0] uart_addr;
  wire [7:0] uart_data;
  wire uart_ready;
  reg reset /* synthesis syn_preserve=1 */;
  reg reset_meta;

  genvar i;
  for (i=0; i<=15; i=i+1) assign reg_array[i] = reg_data[8*i+7:8*i];

  // *** OSC Clock Domain ***
  prescaler #(
    .OSCRATE(OSCRATE),    // oscillator frequency
    .BAUDRATE(BAUDRATE),  // baud rate
    .APURATE(1_790_000)   // system clock frequency
  ) prescaler_inst (
    .clk     (clk),       // system oscillator
    .rx      (rx),        // serial input for activity indicator
    .apu_clk (apu_ref),   // APU system clock, ~1.79 MHz
    .blink   (blink),     // 1 Hz blink indicator
    .link    (link),      // activity indicator
    .uart_clk(uart_clk)   // 5x UART clock, 48 kHz
  );

  // *** UART Clock Domain ***
  uart uart_inst (
    .clk       (uart_clk),
    .rx        (rx),
    .uart_addr (uart_addr),
    .uart_data (uart_data),
    .uart_ready(uart_ready)
  );

  // *** APU Clock Domain ***
  // Synchronize external reset to clock
  always @(posedge apu_clk) begin
    if (rst_n == 0) begin
      reset <= 1;
      reset_meta <= 1;
    end else begin
      reset <= reset_meta;
      reset_meta <= 0;
    end
  end

  registers registers_inst (
    .clk       (apu_clk),
    .uart_addr (uart_addr),
    .uart_data (uart_data),
    .uart_ready(uart_ready),
    .reg_data  (reg_data),
    .reg_event (reg_event)
  );

  frame #(
    .CLKRATE(CLKRATE)
  ) frame_inst (
    .clk         (apu_clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz)
  );

  square square1_inst (
    .clk         (apu_clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .reg_4000    (reg_array[4'h0]),
    .reg_4001    (reg_array[4'h1]),
    .reg_4002    (reg_array[4'h2]),
    .reg_4003    (reg_array[4'h3]),
    .reg_event   (reg_event[0]),
    .pulse_out   (pulse1_out)
  );

  square square2_inst (
    .clk         (apu_clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .reg_4000    (reg_array[4'h4]),
    .reg_4001    (reg_array[4'h5]),
    .reg_4002    (reg_array[4'h6]),
    .reg_4003    (reg_array[4'h7]),
    .reg_event   (reg_event[1]),
    .pulse_out   (pulse2_out)
  );

  triangle triangle_inst (
    .clk         (apu_clk),
    .enable_240hz(enable_240hz),
    .reg_4008    (reg_array[4'h8]),
    .reg_400A    (reg_array[4'hA]),
    .reg_400B    (reg_array[4'hB]),
    .reg_event   (reg_event[2]),
    .tri_out     (tri_out)
  );

  noise noise_inst (
    .clk         (apu_clk),
    .enable_240hz(enable_240hz),
    .reg_400C    (reg_array[4'hC]),
    .reg_400E    (reg_array[4'hE]),
    .reg_400F    (reg_array[4'hF]),
    .reg_event   (reg_event[3]),
    .noise_out   (noise_out)
  );

  // Mixer
  assign pwm_data = {2'b00, pulse1_out}
                  + {2'b00, pulse2_out}
                  + {2'b00, tri_out}
                  + {2'b00, noise_out};

  audio_pwm #(
    .WIDTH(6)
  ) audio_pwm_inst (
    .clk  (apu_clk),
    .reset(reset),
    .data (pwm_data),
    .pwm  (pwm)
  );

endmodule
