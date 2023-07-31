// Title:   Top-level ASIC wrapper
// File:    tt_um_morningjava_top.v
// Author:  Wallie Everest
// Date:    04-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Tiny Tapeout project for the Efabless Caravel device.
//   Targets the SkyWater 130nm PDK.
//   An external PWM low-pass filter is required below 5 kHz.
//   The external serial COM port is set for 9600 baud.

`default_nettype none

module tt_um_morningjava_top (
  input  wire       clk,      // clock
  input  wire       rst_n,    // active-low asynchronous reset
  input  wire       ena,      // (unused) active-high design is selected
  input  wire [7:0] ui_in,    // Dedicated inputs
  input  wire [7:0] uio_in,   // Bidirectional input
  output wire [7:0] uo_out,   // Dedicated outputs
  output wire [7:0] uio_out,  // Bidirectional output
  output wire [7:0] uio_oe    // Bidirectional enable (active-high: 0=input, 1=output)
);

  localparam OSCRATE = 12_000_000;  // external oscillator
  localparam BAUDRATE = 9600;       // serial baud rate

  wire pwm;
  wire [3:0] dac;
  wire blink;
  wire link;
  wire rx = ui_in[0];

  assign uo_out[0] = pwm;
  assign uo_out[1] = blink;
  assign uo_out[2] = link;
  assign uo_out[3] = rx;
  assign uo_out[7:4] = dac;
  assign uio_out = 0;
  assign uio_oe = 0;

  chiptune #(
    .OSCRATE(OSCRATE),
    .BAUDRATE(BAUDRATE)
  ) chiptune_inst (
    .osc  (clk),
    .rst_n(rst_n),
    .rx   (rx),     // serial data input
    .pwm  (pwm),    // audio PWM
    .dac  (dac),    // audio DAC
    .blink(blink),  // status LED
    .link (link)    // link LED
  );

endmodule
