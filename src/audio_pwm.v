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
  parameter WIDTH = 12
)(
  input  wire clk,
  input  wire reset,
//  input  wire [WIDTH-1:0] data,  // signed input
  input  wire [WIDTH-1:0] data,  // unsigned input
  output wire pwm
) /* synthesis syn_hier="fixed" */;

//  wire [WIDTH:0] data_ext = {1'b0, ~data[WIDTH-1], data[WIDTH-2:0]};  // convert from signed to signed-offset (unsigned)
  wire [WIDTH:0] data_ext = {1'b0, data};  // extend vector
  reg [WIDTH:0] accum = 0;    // unsigned
  assign pwm = accum[WIDTH];  // msb of the accumulator (OVF) is the PWM output

  // Delta-modulation function
  always @(posedge clk) begin : audio_pwm_accumulator
    if (reset == 1)
      accum <= 0;
    else
      accum <= {1'b0, accum[WIDTH-1:0]} + data_ext;
  end

endmodule
