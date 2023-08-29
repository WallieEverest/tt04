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
//   Use at the end of module declaration where needed: /* synthesis syn_hier="fixed" */

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

  localparam OSCRATE = 12_000_000;  // external oscillator
  localparam BAUDRATE = 9600;       // serial baud rate

  wire apu_ref;
  wire blink;
  wire link;
  wire pwm;
  wire apu_clk = ui_in[1];      // APU clock, 1.79 MHz (typ)

  assign led[0] = blink;        // D1, 1 Hz blink
  assign led[1] = link;         // D3, RX activity status
  assign led[2] = dtrn;         // D2, DTRn from COM
  assign led[3] = rtsn;         // D4, RTSn from COM
  assign led[4] = ( ui_in[7:2] == 0 )
               && ( ui_in[0] == 0 );  // D5, power (center green LED)
  assign uo_out[0] = 0;
  assign uo_out[1] = 0;
  assign uo_out[2] = apu_ref;   // 2 MHz clock reference, connect to ui_in[1]
  assign uo_out[3] = pwm;       // PWM audio output
  assign uo_out[4] = 0;
  assign uo_out[5] = 0;
  assign uo_out[6] = 0;
  assign uo_out[7] = 0;
  assign tx = rx;               // serial loop-back to host

  apu #(
    .OSCRATE(OSCRATE),
    .BAUDRATE(BAUDRATE)
  ) apu_inst (
    .apu_clk(apu_clk),
    .clk    (clk),
    .rx     (rx),
    .apu_ref(apu_ref),
    .blink  (blink),
    .link   (link),
    .pwm    (pwm)
  );

endmodule
