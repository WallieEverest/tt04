// Title:   Top-level ASIC wrapper
// File:    tt_um_morningjava_top.v
// Author:  Wallie Everest
// Date:    04-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

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
) /* synthesis syn_hier="fixed" */;

  wire pwm;
  wire blink;
  wire link;
  
  assign uo_out[0] = pwm;
  assign uo_out[1] = blink;
  assign uo_out[2] = link;
  assign uo_out[7:3] = 0;
  assign uio_out = 0;
  assign uio_oe = 0;

  chiptune #(
    .CLKRATE(12_000_000),  // external oscillator
    .BAUDRATE(9600)        // serial baud rate
  ) chiptune_inst (
    .osc  (clk),
    .rst_n(rst_n),
    .rx   (ui_in[0]),      // serial data input
    .pwm  (pwm),           // audio PWM
    .blink(blink),         // status LED
    .link (link)           // link LED
  );

endmodule
