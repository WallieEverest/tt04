// Title:   Sound generator
// File:    chiptune.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description:
// Implementation:
// Operation:

`default_nettype none

module chiptune #(
  parameter CLKRATE = 1_790_000  // system clock rate
)(
  input  wire clk,       // 4800 Hz
  input  wire sck,       // 300 baud
  input  wire sdi,       // serial data
  output wire [3:0] dac  // audio DAC
);

  wire [7:0] reg_4000;
  wire [7:0] reg_4001;
  wire [7:0] reg_4002;
  wire [7:0] reg_4003;
  wire enable_240hz;  // 240 Hz
  wire enable_120hz;  // 120 Hz
  wire [3:0] p1_out;
  wire reg_change;
  assign dac = p1_out;
  
  decoder decoder_inst (
    .sck       (sck),
    .sdi       (sdi),
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
    .pulse_out   (p1_out)
  );

endmodule
