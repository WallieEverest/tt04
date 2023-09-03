// Title:   Noise pulse generator
// File:    noise.v
// Author:  Wallace Everest
// Date:    09-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description: (from apu_ref.txt and nesdev.org)
// -------------
// Noise Channel
// -------------
// The shift register is clocked by the timer and the vacated bit 14 is filled
// with the exclusive-OR of *pre-shifted* bits 0 and 1 (mode = 0) or bits 0 and 6
// (mode = 1), resulting in 32767-bit and 93-bit sequences, respectively.
//
// On power-up, the shift register is loaded with the value 1.
//
//    Timer --> Shift Register   Length Counter
//                    |                |
//                    v                v
// Envelope -------> Gate ----------> Gate --> (to mixer)

`default_nettype none

module noise (
  input wire       clk,
  input wire       enable_240hz,
  input wire [7:0] reg_400C,
  input wire [7:0] reg_400E,
  input wire [7:0] reg_400F,
  input wire       reg_event,
  output reg [3:0] noise_data
);

  // Input assignments
  wire [ 3:0] envelope         = reg_400C[3:0];
  // wire        constant_volume  = reg_400C[4];  // DEBUG
  wire        length_halt      = reg_400C[5];
  wire [ 3:0] timer_select     = reg_400E[3:0];
  wire        mode_flag        = reg_400E[7];
  wire [ 4:0] length_select    = reg_400F[7:3];

  reg [ 7:0] length_counter = 0;
  reg [11:0] timer = 0;
  reg [11:0] timer_preset;
  reg [14:0] shift_register = 0;
  reg timer_event = 0;

  reg [ 7:0] length_preset;

  wire length_count_zero = ( length_counter == 0 );
  wire timer_count_zero  = ( timer == 0 );
  wire feedback = mode_flag ? shift_register[6] ^ shift_register[0]
                            : shift_register[1] ^ shift_register[0];

  // Linear Feedback Shift Register
  always @( posedge clk ) begin : noise_lfsr
    if ( timer_event )
      shift_register <= {feedback, shift_register[14:1]};  // right shift with feedback
    else if ( shift_register == 0 )  // ensure register is initialized
      shift_register <= 1;
  end

  // Length counter
  always @( posedge clk ) begin : noise_length_counter
    if ( reg_event )
      length_counter <= length_preset;
    else if ( enable_240hz && !length_count_zero && !length_halt )
      length_counter <= length_counter - 1;
  end

  always @* begin : noise_length_lookup
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
  always @( posedge clk ) begin : noise_timer
    timer_event <= timer_count_zero;
    if ( timer_count_zero )
      timer <= timer_preset;
    else
      timer <= timer - 1;
  end

  always @* begin : noise_timer_lookup
    case ( timer_select )
      0:  timer_preset = 12'h004;
      1:  timer_preset = 12'h008;
      2:  timer_preset = 12'h010;
      3:  timer_preset = 12'h020;
      4:  timer_preset = 12'h040;
      5:  timer_preset = 12'h060;
      6:  timer_preset = 12'h080;
      7:  timer_preset = 12'h0A0;
      8:  timer_preset = 12'h0CA;
      9:  timer_preset = 12'h0FE;
      10: timer_preset = 12'h17C;
      11: timer_preset = 12'h1FC;
      12: timer_preset = 12'h2FA;
      13: timer_preset = 12'h3F8;
      14: timer_preset = 12'h7F2;
      15: timer_preset = 12'hFE4;
    endcase
  end

  // Envelope
  always @( posedge clk ) begin : noise_envelope
    if ( length_count_zero || shift_register[0] )
      noise_data <= 0;
    else
      noise_data <= envelope;  // volume
  end

endmodule
