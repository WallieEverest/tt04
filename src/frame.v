// File: frame.v

`default_nettype none

// Generate low-frequency clocks
module frame #(
  parameter CLKRATE = 1_790_000  // system clock rate
)(
  input  wire clk,               // system clock
  output reg enable_240hz = 0,   // 240 Hz
  output reg enable_120hz = 0    // 120 Hz
) /* synthesis syn_hier="fixed" */;

localparam PRESCALE = CLKRATE/240;  // frame rate
reg [12:0] prescaler = 0;  // size allows max system clock of 1.9 MHz
reg divider = 0;

// Step through 4-step sequence
always @ ( posedge clk ) begin
  enable_240hz <= ( prescaler == 0 );
  enable_120hz <= ( divider && ( prescaler == 0 ) );
  if ( prescaler != 0 )
    prescaler <= prescaler - 1;
  else begin
    prescaler <= PRESCALE-1;
    divider <= ~divider;
  end
end

endmodule