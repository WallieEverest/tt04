// Title:   UART clock recovery
// File:    clk_gen.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description: Recovers a bit clock (sck) from asynchronous serial data.
// Implementation: A reference clock must be supplied at 16x the baud rate
// The TT03 scan clock is presumed to operate at 9,600 bytes per second,
// yielding a project clock of 4,800 Hz.
// This 16x UART clock produces a 300 baud serial interface.

`default_nettype none

module clk_gen (
  input  wire clk,  // 16x baud clock
  input  wire rx,
  output reg  sck = 0  // recovered serial clock
) /* synthesis syn_hier="fixed" */;

  reg rx_meta = 0;
  reg sdi = 0;
  reg [3:0] count = 0 /* synthesis syn_preserve=1 */;
  localparam [3:0] HALF_BIT = 8;

  always @(posedge clk) begin
    rx_meta <= rx;       // capture asynchronous input
    sdi     <= rx_meta;  // generate delay to detect edge

    if (sdi != rx_meta)  // edge detected
      count <= 4;        // synchronize bit clock with phase offset
    else
      count <= count+1;

    if (count < HALF_BIT)
      sck <= 0;  // generate falling edge of sck on RX change
    else
      sck <= 1;  // generate rising edge of sck midway through bit period
  end
  
endmodule
