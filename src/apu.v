// Title:   Sound generator
// File:    apu.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description: The instructions set is similar to an enhanced 6502 with
// an Audio Processing Unit (APU), designated the RP2A03 found in the Nintendo Entertainment System.

`default_nettype none

module apu #(
  parameter CLKRATE = 1_789_773,  // APU clock frequency, 21.477 MHz/12 or 1.89 GHz/88/12
  parameter BAUDRATE = 9600       // serial baud rate
)(
  input  wire clk,       // APU clock
  input  wire rx,        // serial input
  output wire blink,     // status LED
  output wire link,      // link LED
  output wire noise,     // noise PWM
  output wire square1,   // square1 PWM
  output wire square2,   // square2 PWM
  output wire pwm,       // merged audio PWM
  output wire triangle,  // triangle PWM
  output wire tx         // serial output
);

  wire uart_clk;  // 48 kHz
  wire enable_240hz;
  wire enable_120hz;
  wire enable_60hz;
  wire [16*8-1:0] reg_data;
  wire [7:0] reg_array [0:15];
  wire [3:0] reg_event;
  wire [3:0] square1_data;
  wire [3:0] square2_data;
  wire [3:0] triangle_data;
  wire [3:0] noise_data;
  wire [5:0] pwm_data;
  wire [3:0] uart_addr;
  wire [7:0] uart_data;
  wire uart_ready;

  genvar i;
  for ( i=0; i<=15; i=i+1 ) assign reg_array[i] = reg_data[8*i+7:8*i];

  system #(
    .CLKRATE(CLKRATE),
    .BAUDRATE(BAUDRATE)
  ) system_inst (
    .clk     (clk),
    .rx      (rx),
    .blink   (blink),
    .link    (link),
    .uart_clk(uart_clk)
  );

  uart uart_inst (
    .clk       (clk),
    .uart_clk  (uart_clk),
    .rx        (rx),
    .uart_addr (uart_addr),
    .uart_data (uart_data),
    .uart_ready(uart_ready)
  );

  euro euro_inst (
    .clk        (clk),
    .enable_60hz(enable_60hz),
    .uart_clk   (uart_clk),
    .tx         (tx) 
  );

  registers registers_inst (
    .clk       (clk),
    .uart_addr (uart_addr),
    .uart_data (uart_data),
    .uart_ready(uart_ready),
    .reg_data  (reg_data),
    .reg_event (reg_event)
  );

  frame #(
    .CLKRATE(CLKRATE)
  ) frame_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .enable_60hz (enable_60hz)
  );

  square square1_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .reg_4000    (reg_array[4'h0]),
    .reg_4001    (reg_array[4'h1]),
    .reg_4002    (reg_array[4'h2]),
    .reg_4003    (reg_array[4'h3]),
    .reg_event   (reg_event[0]),
    .pulse_data  (square1_data)
  );

  square square2_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .enable_120hz(enable_120hz),
    .reg_4000    (reg_array[4'h4]),
    .reg_4001    (reg_array[4'h5]),
    .reg_4002    (reg_array[4'h6]),
    .reg_4003    (reg_array[4'h7]),
    .reg_event   (reg_event[1]),
    .pulse_data  (square2_data)
  );

  triangle triangle_inst (
    .clk          (clk),
    .enable_240hz (enable_240hz),
    .reg_4008     (reg_array[4'h8]),
    .reg_400A     (reg_array[4'hA]),
    .reg_400B     (reg_array[4'hB]),
    .reg_event    (reg_event[2]),
    .triangle_data(triangle_data)
  );

  noise noise_inst (
    .clk         (clk),
    .enable_240hz(enable_240hz),
    .reg_400C    (reg_array[4'hC]),
    .reg_400E    (reg_array[4'hE]),
    .reg_400F    (reg_array[4'hF]),
    .reg_event   (reg_event[3]),
    .noise_data  (noise_data)
  );

  // Mixer
  assign pwm_data = {2'b00, square1_data}
                  + {2'b00, square2_data}
                  + {2'b00, triangle_data}
                  + {2'b00, noise_data};

  audio_pwm #(
    .WIDTH(6)
  ) audio_pwm_inst (
    .clk (clk),
    .data(pwm_data),
    .pwm (pwm)
  );

  audio_pwm #(
    .WIDTH(4)
  ) audio_square1_inst (
    .clk (clk),
    .data(square1_data),
    .pwm (square1)
  );

  audio_pwm #(
    .WIDTH(4)
  ) audio_square2_inst (
    .clk (clk),
    .data(square2_data),
    .pwm (square2)
  );

  audio_pwm #(
    .WIDTH(4)
  ) audio_triangle_inst (
    .clk (clk),
    .data(triangle_data),
    .pwm (triangle)
  );

  audio_pwm #(
    .WIDTH(4)
  ) audio_noise_inst (
    .clk (clk),
    .data(noise_data),
    .pwm (noise)
  );

endmodule
