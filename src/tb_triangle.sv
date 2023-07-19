// Title:   Triangle synthesizer testbench
// File:    tb_triangle.sv
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

`default_nettype none
`timescale 1ns/100ps

module tb_triangle ();

  reg  [7:0] apu_reg [0:31];
  reg  clk = 0;  // 894,720 Hz
  wire enable_240hz;      // 240 Hz
  wire enable_120hz;      // 120 Hz
  wire reg_change;  // toggle
  wire signed [15:0] p1_out;

  initial forever #558 clk = ~clk;  // 896 kHz APU clock

  initial begin : reg_init
    integer i;
    for (i=0; i<=31; i=i+1)
      apu_reg[i] = 0;  // clear APU registers
    repeat (2) @(negedge enable_120hz);
    apu_reg[0] = 1;
    @(negedge enable_120hz);
  end

  frame_counter frame_counter_inst (
    .clk        ( clk ),
    .fc_enable_240hz ( enable_240hz ),
    .fc_enable_120hz ( enable_120hz )
  );
  
  rectangle rectangle_inst (
    .clk          (clk),
    .enable_240hz (enable_240hz),
    .enable_120hz (enable_120hz),
    .reg_0        (apu_reg[0]),
    .reg_1        (apu_reg[1]),
    .reg_2        (apu_reg[2]),
    .reg_3        (apu_reg[3]),
    .reg_change   (reg_change),
    .pulse_out    (p1_out)
  );

endmodule
