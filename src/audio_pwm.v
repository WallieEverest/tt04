// Title:   Pulse Width Modulator (PWM)
// File:    audio_pwm.v
// Author:  Wallie Everest
// Date:    11-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

`default_nettype none

module audio_pwm #(
  parameter WIDTH = 6
)(
  input  wire clk,
  input  wire [WIDTH-1:0] data,  // unsigned input
  output wire pwm
);

  wire [WIDTH:0] data_ext = {1'b0, data};  // extend input vector
  reg [WIDTH:0] accum;                     // unsigned accumulator
  assign pwm = accum[WIDTH];               // msb of the accumulator (OVF) is the PWM output

  // Delta-modulation function
  always @(posedge clk) begin : audio_pwm_accumulator
    if ( accum != 0 )  // ensure startup value is non-zero
      accum <= {1'b0, accum[WIDTH-1:0]} + data_ext;
    else
      accum <= 1;
  end

endmodule
