// Title:   External synchonization of frame generator
// File:    euro.v
// Author:  Wallace Everest
// Date:    03-SEP-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Generates a Euro character at the 60 Hz frame rate.
//   Provides a synchronization pulse that aligns with the internal frame generator.
//   Actual pulse is merely the serial word 8'b80 (Win1252 Euro character)
//   which is eight low-periods of the serial bit rate (including the start bit).

`default_nettype none

module euro (
  input  wire clk,          // system clock
  input  wire enable_60hz,  // frame rate
  input  wire uart_clk,     // 6x baud clock
  output reg  tx            // serial character
);

  localparam WIDTH = 6*8;  // pulse width

  reg [5:0] counter;

  always @( posedge clk ) begin : euro_frame_sync
    tx <= (counter == 0 );

    if ( enable_60hz )
      counter <= WIDTH;
    else if (uart_clk && ( counter != 0 ))
      counter <= counter-1;
  end

endmodule
