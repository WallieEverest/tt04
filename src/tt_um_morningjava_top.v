// Title:   Top-level ASIC wrapper
// File:    tt_um_morningjava_top.v
// Author:  Wallie Everest
// Date:    04-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Tiny Tapeout project for the Efabless Caravel device.
//   Targets the SkyWater 130nm PDK.
//   An external PWM low-pass filter is set for 4 kHz.
//   The external serial COM port is set for 9600 baud.

`default_nettype none

module tt_um_morningjava_top (
  input  wire       clk,      // clock
  input  wire       rst_n,    // active-low asynchronous reset
  input  wire       ena,      // (unused) active-high design is selected
  input  wire [7:0] ui_in,    // Dedicated inputs
  input  wire [7:0] uio_in,   // Bidirectional input
  output wire [7:0] uo_out,   // Dedicated outputs
  output wire [7:0] uio_out,  // Bidirectional output
  output wire [7:0] uio_oe    // Bidirectional enable (active-high: 0=input, 1=output)
);

  localparam OSCRATE = 12_000_000;  // external oscillator
  localparam BAUDRATE = 9600;       // serial baud rate

  wire apu_ref;
  wire blink;
  wire link;
  wire pwm;
  wire rx = ui_in[2];          // UART RX
  wire apu_clk = ui_in[7];     // APU clock

  assign uo_out[0] = blink;    // 1 Hz blink
  assign uo_out[1] = 0;
  assign uo_out[2] = rx;       // UART TX, serial loop-back to host
  assign uo_out[3] = pwm;      // PWM audio output
  assign uo_out[4] = link;     // RX activity status 
  assign uo_out[5] = 0;
  assign uo_out[6] = 0;
  assign uo_out[7] = apu_ref;  // 1.79 MHz
  assign uio_out = 0;
  assign uio_oe = 0;

  chiptune #(
    .OSCRATE(OSCRATE),
    .BAUDRATE(BAUDRATE)
  ) chiptune_inst (
    .clk    (clk),
    .rst_n  (rst_n),
    .apu_clk(apu_clk),
    .rx     (rx),
    .apu_ref(apu_ref),
    .blink  (blink),
    .link   (link),
    .pwm    (pwm)
  );  

endmodule
