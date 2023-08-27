// Title:   Rectangular pulse generator
// File:    square.v
// Author:  Wallace Everest
// Date:    28-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description: (from apu_ref.txt and nesdev.org)
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

module square (
  input wire       clk,
  input wire       enable_240hz,
  input wire       enable_120hz,
  input wire [7:0] reg_4000,
  input wire [7:0] reg_4001,
  input wire [7:0] reg_4002,
  input wire [7:0] reg_4003,
  input wire       reg_event,
  output reg [3:0] pulse_out = 0
);

  // Input assignments
  wire [ 3:0] decay_rate      = reg_4000[3:0];  // volume / decay rate
  wire        decay_halt      = reg_4000[4];
  wire        length_halt     = reg_4000[5];  // length disable / decay looping enable
  wire [ 1:0] duty_cycle_type = reg_4000[7:6];
  wire [ 2:0] sweep_shift     = reg_4001[2:0];
  wire        sweep_decrement = reg_4001[3];
  wire [ 2:0] sweep_rate      = reg_4001[6:4];
  wire        sweep_enable    = reg_4001[7];
  wire [10:0] timer_preset    = {reg_4003[2:0], reg_4002};
  wire [ 4:0] length_select   = reg_4003[7:3];

  reg timer_event = 0;
  reg [ 7:0] length_counter = 0;
  reg [ 2:0] sweep_counter = 0;
  reg [10:0] timer_load = 0;
  reg [ 3:0] decay_counter = 0;
  reg [ 3:0] envelope_counter = 0;
  reg [10:0] timer = 0;
  reg [ 2:0] index = 0;
  reg [ 7:0] length_preset;
  reg [ 7:0] duty_cycle_pattern;
  reg length_count_zero;
  reg [11:0] preset_decrement;
  reg [11:0] preset_increment;
  reg preset_valid;
  reg [ 3:0] volume;

  always @* begin : square_comb
    length_count_zero <= ( length_counter == 0 );
    preset_decrement  <= {1'b0, timer_load} - (timer_preset >> sweep_shift);  // should be 1's compliment for CH1
    preset_increment  <= {1'b0, timer_load} + (timer_preset >> sweep_shift);
    preset_valid      <= ( !preset_increment[11] && !preset_decrement[11] && (timer_load[10:3] != 0) );
    if ( decay_halt )
      volume <= decay_rate;
    else
      volume <= envelope_counter;
  end

  // Length counter
  always @( posedge clk ) begin : square_length_counter
    if ( reg_event )
      length_counter <= length_preset;
    else if ( !length_halt && enable_120hz && !length_count_zero )
      length_counter <= length_counter - 1;
  end
  
  always @* begin : square_length_lookup
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
  
  // Envelope unit
  always @( posedge clk ) begin : square_envelope_counter
    if ( reg_event ) begin
      decay_counter <= decay_rate;
      envelope_counter <= ~0;
    end else begin
      if ( enable_240hz && !decay_halt ) begin
        if ( decay_counter != 0 )
          decay_counter <= decay_counter - 1;
        else begin
          decay_counter <= decay_rate;
          if ( envelope_counter != 0 )
            envelope_counter <= envelope_counter - 1;
          else if ( length_halt )  // enable decay looping
            envelope_counter <= ~0;
        end
      end
    end
  end

  // Sweep unit
  // DEBUG: Clock enable has priority over reload
  always @( posedge clk ) begin : square_sweep_counter
    if ( reg_event ) begin
      sweep_counter <= sweep_rate;
      timer_load <= timer_preset;
    end else begin
      if ( enable_120hz ) begin
        if ( sweep_counter != 0 ) begin
          sweep_counter <= sweep_counter - 1;
        end else begin
          if ( sweep_enable ) begin
            sweep_counter <= sweep_rate;
            if ( sweep_decrement ) begin  // sweep up to higher frequencies
              if ( !preset_decrement[11] )  // check undeflow
                timer_load <= preset_decrement[10:0];
            end else begin // sweep down to lower frequencies
              if ( !preset_increment[11] )  // check overflow
                timer_load <= preset_increment[10:0];
            end
          end
        end
      end
    end
  end

  // Timer, ticks at 1.79 MHz / 2
  always @( posedge clk ) begin : square_timer  // originally at 1.79 MHz
    if ( timer == 0 ) begin
      timer <= timer_load;  // DEBUG reduce effective clock rate
      timer_event <= 1;
    end else begin
      timer <= timer - 1;
      timer_event <= 0;
    end
  end

  // Duty cycle
  always @( posedge clk ) begin : square_duty_cycle
    if ( reg_event ) 
      index <= ~0;
    else if ( timer_event && !length_count_zero )
      index <= index - 1;

    if ( duty_cycle_pattern[index] && preset_valid && !length_count_zero)
      pulse_out <= volume;
    else
      pulse_out <= 0;
  end

  always @* begin : square_duty_cycle_lookup
    case ( duty_cycle_type )
      0: duty_cycle_pattern = 8'b00000010;
      1: duty_cycle_pattern = 8'b00000110;
      2: duty_cycle_pattern = 8'b00011110;
      3: duty_cycle_pattern = 8'b11111001;
    endcase
  end

endmodule
