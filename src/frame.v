// Title:   Audio frame generator
// File:    frame.v
// Author:  Wallie Everest
// Date:    09-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

`default_nettype none

// Generate low-frequency clocks
module frame #(
  parameter CLKRATE = 1_790_000  // system clock rate
)(
  input  wire clk,           // system clock
  output reg  enable_240hz,  // 240 Hz
  output reg  enable_120hz   // 120 Hz
);

localparam PRESCALE = (CLKRATE / 240);  // frame rate

reg [13:0] prescaler;  // size allows max system clock of 3.9 MHz
reg divider = 0;

// Cycle through 4-step sequence
always @ ( posedge clk ) begin
  enable_240hz <= ( prescaler == 0 );
  enable_120hz <= ( divider && ( prescaler == 0 ));
  if ( prescaler != 0 )
    prescaler <= prescaler[13:0] - 1;
  else begin
    prescaler <= PRESCALE-1;
    divider <= ~divider;
  end
end

endmodule
