// Title:   Clock prescaler
// File:    prescaler.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Divides the oscillator down to a system and communication clocks.

`default_nettype none

module prescaler #(
  parameter OSCRATE = 12_000_000,  // oscillator clock frequency
  parameter APURATE = 1_790_000    // system clock frequency
)(
  input  wire clk,     // external oscillator
  output reg  apu_clk  // APU system clock
);

  localparam [2:0] APU_DIVISOR = (OSCRATE / APURATE);  // 1.79 MHz => 6.7

  reg [ 2:0] count_clk;

  always @( posedge clk ) begin
    apu_clk <= ( count_clk < 3 );  // extend clock duration

    if ( count_clk != 0 )
      count_clk <= count_clk-1;
    else
      count_clk <= APU_DIVISOR-1;
  end

endmodule
