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
//   An external PWM low-pass filter is set for 4 kHz.
//   The external serial COM port is set for 9600 baud.

`default_nettype none

module tt_um_morningjava_top (
  input  wire       clk,      // System clock, 1.789773 MHz
  /* verilator lint_off UNUSEDSIGNAL */
  input  wire       rst_n,    // (unused) Active-low asynchronous reset
  input  wire       ena,      // (unused) Active-high design is selected
  input  wire [7:0] uio_in,   // (unused) Bidirectional input
  /* verilator lint_on UNUSEDSIGNAL */
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  output wire [7:0] uio_out,  // (unused) Bidirectional output
  output wire [7:0] uio_oe    // (unused) Bidirectional enable (active-high: 0=input, 1=output)
);

  wire blink;
  wire link;
  wire pwm;
  wire rx = ui_in[2];        // UART RX

  assign uo_out[0] = 0;
  assign uo_out[1] = 0;
  assign uo_out[2] = rx;     // UART TX, serial loop-back to host
  assign uo_out[3] = pwm;    // PWM audio output
  assign uo_out[4] = 0;
  assign uo_out[5] = 0;
  assign uo_out[6] = blink;  // 1 Hz blink
  assign uo_out[7] = link;   // RX activity status
  assign uio_out = 0;
  assign uio_oe = 0;

  apu #(
    .CLKRATE(1_789_773),  // actual APU clock frequency
    .BAUDRATE(9600)       // serial baud rate
  ) apu_inst (
    .clk  (clk),
    .rx   (rx),
    .blink(blink),
    .link (link),
    .pwm  (pwm)
  );

endmodule
