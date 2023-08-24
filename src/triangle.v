// Title:   Triangule pulse generator
// File:    triangle.v
// Author:  Wallace Everest
// Date:    09-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description: (from apu_ref.txt and nesdev.org)
// The triangle channel contains the following: Timer, 32-step sequencer, Length
// Counter, Linear Counter, 4-bit DAC.
// $4008: length counter disable, linear counter
// $400A: period low
// $400B: length counter reload, period high
// When the timer generates a clock and the Length Counter and Linear Counter both
// have a non-zero count, the sequencer is clocked.
// The sequencer feeds the following repeating 32-step sequence to the DAC:
//     F E D C B A 9 8 7 6 5 4 3 2 1 0 0 1 2 3 4 5 6 7 8 9 A B C D E F
// At the lowest two periods ($400B = 0 and $400A = 0 or 1), the resulting
// frequency is so high that the DAC effectively outputs a value half way between
// 7 and 8.
//
//       Linear Counter   Length Counter
//             |                |
//             v                v
// Timer ---> Gate ----------> Gate ---> Sequencer ---> (to mixer)

`default_nettype none

module triangle (
  input wire       clk,
  input wire       enable_240hz,
  input wire [7:0] reg_4008,
  input wire [7:0] reg_400A,
  input wire [7:0] reg_400B,
  input wire       reg_event,
  output reg [3:0] tri_out = 0
);

  // Input registers
  wire [ 6:0]  linear_preset  = reg_4008[6:0];
  wire         linear_control = reg_4008[7];
  wire [ 10:0] timer_preset   = {reg_400B[2:0], reg_400A};
  wire [ 4:0]  length_select  = reg_400B[7:3];

  reg [ 6:0] linear_counter = 0;
  reg [ 7:0] length_counter = 0;
  reg [ 7:0] length_preset;
  reg [10:0] timer = 0;
  reg [ 4:0] sequencer = 0;
  reg        linear_reload = 0;
  reg        timer_event = 0;
  reg        length_halt = 0;
  // reg [1:0]  reg_delay = 0;
  // reg        reload = 0;
  
  wire linear_count_zero    = ( linear_counter == 0 );
  wire length_count_zero    = ( length_counter == 0 );
  wire timer_count_zero     = ( timer == 0 );
  wire sequencer_count_zero = ( sequencer == 0 );

  // Detect configuration change on $400B
  // always @( posedge clk ) begin : triangle_reload
  //   reg_delay[0] <= reg_change;  // asynchronous input from clock crossing
  //   reg_delay[1] <= reg_delay[0];
  //   reload <= ( reg_delay[1] != reg_delay[0] );  // detect edge of toggle input
  // end

  // Select active counter
  always @( posedge clk ) begin : triangle_counter_select
    if ( reg_event )
      length_halt <= 1;
    else if ( enable_240hz )
      length_halt <= linear_control;
  end

  // Linear counter
  always @( posedge clk ) begin : triangle_linear_counter
    if ( linear_reload || ( enable_240hz && linear_count_zero && length_halt ))
      linear_counter <= linear_preset;
    else if ( enable_240hz && !linear_count_zero ) 
      linear_counter <= linear_counter - 1;
  end

  // Length counter
  always @( posedge clk ) begin : triangle_length_counter
    if ( reg_event ) begin
      length_counter <= length_preset;
    end else begin
      if ( !length_halt ) begin  // suspend while linear is in control
        if ( enable_240hz && !length_count_zero ) begin
          length_counter <= length_counter - 1;
          linear_reload <= 1;
        end else begin
          linear_reload <= 0;
        end
      end
    end
  end
  
  always @* begin
    case ( length_select )
       0: length_preset = 8'h0A;
       1: length_preset = 8'hFE;
       2: length_preset = 8'h14;
       3: length_preset = 8'h02;
       4: length_preset = 8'h28;
       5: length_preset = 8'h04;
       6: length_preset = 8'h50;
       7: length_preset = 8'h06;
       8: length_preset = 8'hA0;
       9: length_preset = 8'h08;
      10: length_preset = 8'h3C;
      11: length_preset = 8'h0A;
      12: length_preset = 8'h0E;
      13: length_preset = 8'h0C;
      14: length_preset = 8'h1A;
      15: length_preset = 8'h0E;
      16: length_preset = 8'h0C;
      17: length_preset = 8'h10;
      18: length_preset = 8'h18;
      19: length_preset = 8'h12;
      20: length_preset = 8'h30;
      21: length_preset = 8'h14;
      22: length_preset = 8'h60;
      23: length_preset = 8'h16;
      24: length_preset = 8'hC0;
      25: length_preset = 8'h18;
      26: length_preset = 8'h48;
      27: length_preset = 8'h1A;
      28: length_preset = 8'h10;
      29: length_preset = 8'h1C;
      30: length_preset = 8'h20;
      31: length_preset = 8'h1E;
    endcase
  end

  // Timer, ticks at 1.79 MHz
  always @( posedge clk ) begin : triangle_timer
    timer_event <= timer_count_zero;
    if ( timer_count_zero )
      timer <= timer_preset;
    else
      timer <= timer - 1;
  end

  // Sequencer
  always @( posedge clk ) begin : triangle_sequencer
    if ( !sequencer[4] )
      tri_out <= ~sequencer[3:0];  // count down for first half of sequencer count
    else
      tri_out <= sequencer[3:0];  // count up for second half of sequencer count

    if ( timer_event && !linear_count_zero && !length_count_zero )  // DEBUG nasty logic width
      sequencer <= sequencer + 1;
  end

endmodule
