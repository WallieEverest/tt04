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
  input  wire       clk,      // clock
  input  wire       rst_n,    // reset_n - low to reset
  input  wire       ena,      // will go high when the design is enabled
  input  wire [7:0] ui_in,    // Dedicated inputs
  input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
  output wire [7:0] uo_out,   // Dedicated outputs
  output wire [7:0] uio_out,  // IOs: Bidirectional Output path
  output wire [7:0] uio_oe    // IOs: Bidirectional Enable path (active high: 0=input, 1=output)

);
  assign uo_out = clk ? ui_in : 8'x0;
  assign uio_out[7:4] = rst_n ? uio_in[3:0] : 4'x0;
  assign uio_oe = ena ? 8'xF0 : 8'x00;
  
endmodule
