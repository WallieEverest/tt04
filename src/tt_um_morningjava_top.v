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
) /* synthesis syn_hier="fixed" */;

  wire clk_uart = ui_in[0];
  wire sdi = ui_in[1];  // serial data input
  wire sck;
  wire [3:0] dac;
  
  assign uo_out[3:0] = dac;
  assign uo_out[7:4] = 4'h00;
  assign uio_out = 8'h00;
  assign uio_oe = 8'h00;

  // Bit-clock generator derived from asynchronous serial data input
  clk_gen clk_gen_inst (
    .clk(clk_uart),
    .rx (sdi),
    .sck(sck)
  );

  chiptune #(
    .CLKRATE(3_579_545)  // 315/88
  ) chiptune_inst (
    .clk(clk),
    .sck(sck),
    .sdi(sdi),
    .dac(dac)
  );

endmodule
