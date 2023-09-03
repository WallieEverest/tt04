// Title:   Audio frame generator
// File:    frame.v
// Author:  Wallie Everest
// Date:    09-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Generate low-frequency clock enables.
//   The NES updates notes based on a 60 Hz video frame rate.
//   The APU updates modulation parameters at the quarter and half-frame rates.

`default_nettype none

module frame #(
  parameter CLKRATE = 1_790_000  // system clock rate
)(
  input  wire clk,           // system clock
  output reg  enable_240hz,  // 240 Hz, quarter-frame
  output reg  enable_120hz,  // 120 Hz, half-frame
  output reg  enable_60hz    // 60 Hz, frame rate
);

localparam PRESCALE = (CLKRATE / 240);  // quarter-frame rate

reg [13:0] prescaler;  // size allows max system clock of 3.9 MHz
reg [ 1:0] divider = 0;
wire prescaler_zero = ( prescaler == 0 );

always @ ( posedge clk ) begin : frame_generator
  enable_240hz <= ( prescaler_zero );
  enable_120hz <= ( prescaler_zero && !divider[0] );
  enable_60hz  <= ( prescaler_zero && !divider[1] & !divider[0] );

  if ( !prescaler_zero ) begin
    prescaler <= prescaler[13:0] - 1;
  end else begin
    prescaler <= PRESCALE-1;
    divider <= divider+1;
  end
end

endmodule
