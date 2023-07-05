// Title:   Top-level wrapper in Verilog
// File:    tt_um_morningjava_top.v
// Author:  Wallie Everest
// Date:    04-JUL-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description:
// Implementation:

`default_nettype none

module tt_um_morningjava_top (
  input  wire [7:0] io_in,
  output wire [7:0] io_out,
  inout  wire [7:0] io_bidir
);
  assign io_out = io_in;
  assign io_bidir[7:4] = io_bidir[3:0];
  
endmodule
