// Title:   Rectangule pulse generator
// File:    rectangle.v
// Author:  Wallace Everest
// Date:    28-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
// --------------
// Square Channel
// --------------
//                    +---------+    +---------+
//                    |  Sweep  |--->|Timer / 2|
//                    +---------+    +---------+
//                         |              |
//                         |              v 
//                         |         +---------+    +---------+
//                         |         |Sequencer|    | Length  |
//                         |         +---------+    +---------+
//                         |              |              |
//                         v              v              v
//     +---------+        |\             |\             |\          +---------+
//     |Envelope |------->| >----------->| >----------->| >-------->|   DAC   |
//     +---------+        |/             |/             |/          +---------+

`default_nettype none

module rectangle (
  input wire       clk,
  input wire       enable_240hz,
  input wire       enable_120hz,
  input wire [7:0] reg_4000,
  input wire [7:0] reg_4001,
  input wire [7:0] reg_4002,
  input wire [7:0] reg_4003,
  input wire       reg_change,
  output reg [3:0] pulse_out = 0
) /* synthesis syn_hier="fixed" */;

  // Input registers
  wire [ 3:0] decay_rate      = reg_4000[3:0];  // volume / decay rate
  wire        decay_disable   = reg_4000[4];
  wire        length_disable  = reg_4000[5];  // length disable / decay looping enable
  wire [ 1:0] duty_cycle_type = reg_4000[7:6];
  wire [ 2:0] sweep_shift     = reg_4001[2:0];
  wire        sweep_decrement = reg_4001[3];
  wire [ 2:0] sweep_rate      = reg_4001[6:4];
  wire        sweep_enable    = reg_4001[7];
  wire [10:0] wavelength      = {reg_4003[2:0], reg_4002};
  wire [ 4:0] length_select   = reg_4003[7:3];
  wire [ 3:0] volume;
  wire length_count_zero;
  wire [11:0] preset_decrement;
  wire [11:0] preset_increment;
  wire preset_valid;

  reg timer_event = 0;
  reg reload = 0;
  reg [ 1:0] reg_delay = 0;
  reg [ 7:0] length_counter = 0;
  reg [ 2:0] sweep_counter = 0;
  reg [10:0] preset_timer = 0;
  reg [ 3:0] decay_counter = 0;
  reg [ 3:0] envelope_counter = 0;
  reg [10:0] programmable_timer = 0;
  reg [ 2:0] index = 0;
  reg [ 7:0] length_preset;
  reg [ 7:0] duty_cycle_pattern;

  // Detect configuration change
  always @( posedge clk ) begin
    reg_delay[0] <= reg_change;  // asynchronous input from clock crossing
    reg_delay[1] <= reg_delay[0];
    reload <= ( reg_delay[1] != reg_delay[0] );  // detect edge of toggle input
  end

  // Length counter
  assign length_count_zero = ( length_counter == 0 );

  always @( posedge clk ) begin
    if ( length_disable )
      length_counter <= 0;
    else
      if ( reload )
        length_counter <= length_preset;
      else
        if ( enable_120hz && !length_count_zero )
          length_counter <= length_counter - 1;
  end

  // Envelope unit
  assign volume = decay_disable ? decay_rate : envelope_counter;

  always @( posedge clk ) begin
    if ( reload ) begin
      decay_counter <= decay_rate;
      envelope_counter <= ~0;
    end else 
      if ( enable_240hz ) begin
        if ( !decay_disable )
          if ( decay_counter != 0 )
            decay_counter <= decay_counter - 1;
          else begin
            decay_counter <= decay_rate;
            if ( envelope_counter != 0 )
              envelope_counter <= envelope_counter - 1;
            else
              if ( length_disable )  // enable decay looping
                envelope_counter <= ~0;
          end
      end 
  end

  // Sweep unit
  assign preset_decrement = {1'b0, preset_timer} - (wavelength >> sweep_shift);  // should be 1's compliment for CH1
  assign preset_increment = {1'b0, preset_timer} + (wavelength >> sweep_shift);
  assign preset_valid = (!preset_increment[11] && !preset_decrement[11] && (preset_timer[10:3] != 0) );
  // DEBUG: Clock enable has priority over reload
  always @( posedge clk ) begin
    if ( reload ) begin
      sweep_counter <= sweep_rate;
      preset_timer <= wavelength;
    end else 
      if ( enable_120hz ) begin
        if ( sweep_counter != 0 ) 
          sweep_counter <= sweep_counter - 1;
        else 
          if ( sweep_enable ) begin
            sweep_counter <= sweep_rate;
            if ( sweep_decrement ) begin  // sweep up to higher frequencies
              if ( !preset_decrement[11] )  // check undeflow
                preset_timer <= preset_decrement[10:0];
            end else  // sweep down to lower frequencies
              if ( !preset_increment[11] )  // check overflow
                preset_timer <= preset_increment[10:0];
          end
      end
  end

  // Timer
  always @( posedge clk ) begin  // originally at 1.79 MHz
    timer_event <= ( programmable_timer == 0 );
    if ( programmable_timer != 0 )
      programmable_timer <= programmable_timer - 1;
    else
      programmable_timer <= preset_timer;
  end

  // Duty cycle
  always @( posedge clk ) begin
    if ( reload )
      index <= ~0;
    else
      if ( !length_count_zero && timer_event ) begin
        index <= index - 1;
        if ( duty_cycle_pattern[index] && preset_valid)
          pulse_out <= volume;
        else
          pulse_out <= 0;  // was -volume
      end 
  end

  always @*
  begin
    case ( duty_cycle_type )
      0: duty_cycle_pattern = 8'b00000010;
      1: duty_cycle_pattern = 8'b00000110;
      2: duty_cycle_pattern = 8'b00011110;
      3: duty_cycle_pattern = 8'b11111001;
    endcase
  end
  
  always @*  // shifted left to count at 60 Hz
  begin
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

endmodule
