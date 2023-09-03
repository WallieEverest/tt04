// Title:   Top-level FPGA wrapper
// File:    fpga_top.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Test of a Tiny Tapeout project on an FPGA evaluation board.
//   Targets a Lattice iCEstick Evaluation Kit with an iCE40HX1K-TQ100.
//   The JTAG emulator for progrmming is the first instance of the two FTDI ports.
//   The serial COM port is the latter selection of the two FTDI ports.

`default_nettype none

module fpga_top (
  input  wire       clk,     // PIO_3[0], pin 21 (ICE_CLK)
  input  wire       dtrn,    // PIO_3[4], pin 3  (RS232_DTRn)
  input  wire       rx,      // PIO_3[8], pin 9  (RS232_RX)
  input  wire       rtsn,    // PIO_3[6], pin 7  (RS232_RTSn)
  input  wire [7:0] ui_in,   // PMOD
  output wire [7:0] uo_out,  // PMOD
  output wire       tx,      // PIO_3[7], pin 8  (RS232_TX)
  output wire [4:0] led      // PIO_1[10:14]
) /* synthesis syn_hier="fixed" */;

  wire apu_clk;

  wire blink;
  wire link;
  wire noise;
  wire square1;
  wire square2;
  wire pwm;
  wire triangle;

  assign led[0] = blink;           // D1, 1 Hz blink
  assign led[1] = link;            // D3, RX activity status
  assign led[2] = dtrn;            // D2, DTRn from COM
  assign led[3] = rtsn;            // D4, RTSn from COM
  assign led[4] = ( ui_in != 0 );  // D5, power (center green LED)

  assign uo_out[0] = blink;     // 1 Hz blink
  assign uo_out[1] = link;      // RX activity status
  assign uo_out[2] = 0;
  assign uo_out[3] = pwm;       // Merged PWM audio output
  assign uo_out[4] = square1;   // Square1 channel
  assign uo_out[5] = square2;   // Square2 channel
  assign uo_out[6] = triangle;  // Triangle channel
  assign uo_out[7] = noise;     // Triangle channel
  
  prescaler #(
    .OSCRATE(12_000_000),  // oscillator frequency
    .APURATE(1_790_000)    // desired system clock frequency
  ) prescaler_inst (
    .clk    (clk),
    .apu_clk(apu_clk)      // 2 MHz actual frequency
  );

  apu #(
    .CLKRATE(2_000_000),  // actual APU clock frequency
    .BAUDRATE(9600)       // serial baud rate
  ) apu_inst (
    .clk     (apu_clk),
    .rx      (rx),
    .blink   (blink),
    .link    (link),
    .noise   (noise),
    .square1 (square1),
    .square2 (square2),
    .pwm     (pwm),
    .triangle(triangle),
    .tx      (tx) 
  );

endmodule
