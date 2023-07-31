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
  input  wire [7:0] i_data,  // PIO_0[9:2]       (J1, pullup)
  output wire [7:0] o_data,  // PIO_1[9:2]       (PMOD)
  output wire       tx,      // PIO_3[7], pin 8  (RS232_TX)
  output wire [4:0] led      // PIO_1[10:14]
) /* synthesis syn_hier="fixed" */;

  localparam OSCRATE = 12_000_000;  // external oscillator
  localparam BAUDRATE = 9600;       // serial baud rate

  wire pwm;
  wire [3:0] dac;
  wire blink;
  wire link;
  wire rst_n = dtrn;

  assign led[0] = blink;     // D1, 1 Hz blink
  assign led[1] = link;      // D3, RX activity status
  assign led[2] = dtrn;      // D2, DTRn from COM
  assign led[3] = rtsn;      // D4, RTSn from COM
  assign led[4] = (i_data == 8'hFF);  // D5, power (center green LED)
  assign o_data[0] = pwm;    // PWM audio output
  assign o_data[3:1] = 0;    // output pins from projects
  assign o_data[7:4] = dac;  // output pins from projects
  assign tx = rx;            // serial loop-back to host

  chiptune #(
    .OSCRATE(OSCRATE),
    .BAUDRATE(BAUDRATE)
  ) chiptune_inst (
    .osc  (clk),
    .rst_n(rst_n),
    .rx   (rx),     // serial data input
    .pwm  (pwm),    // audio PWM
    .dac  (dac),    // audio DAC
    .blink(blink),  // status LED
    .link (link)    // link LED
  );
  
endmodule
