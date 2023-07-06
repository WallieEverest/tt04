// Title:   Top-level FPGA wrapper
// File:    fpga_top.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description: Test of a Tiny Tapeout project on an FPGA evaluation board.
// Implementation: Targets a Lattice iCEstick Evaluation Kit with an iCE40HX1K-TQ100.
//   The COM port is the latter selection of the two FTDI ports.
// Operation:

`default_nettype none

module fpga_top (
  input  wire       OSC,     // PIO_3[0], pin 21 (ICE_CLK)
  input  wire       DTRN,    // PIO_3[4], pin 3  (RS232_DTRn)
  input  wire       RX,      // PIO_3[8], pin 9  (RS232_RX)
  input  wire       RTSN,    // PIO_3[6], pin 7  (RS232_RTSn)
  input  wire [7:0] I_DATA,  // PIO_0[9:2]       (pullup)
  output wire [7:0] O_DATA,  // PIO_1[9:2],was PIO_2[10:17]
  output wire       TX,      // PIO_3[7], pin 8  (RS232_TX)
  output wire [4:0] LED      // PIO_1[10:14]
);

  wire [7:0] io_in;
  wire [7:0] io_out;
  wire blink;
  wire link;
  wire clk_sys;
  wire clk_uart;

  // Evaluation board features
  assign LED[0]   = 1;      // D1, power
  assign LED[1]   = RTSN;   // D2, test enable from COM
  assign LED[2]   = link;   // D3, RX activity status
  assign LED[3]   = (DTRN && (I_DATA != 0) );   // D4, DTRn from COM
  assign LED[4]   = blink;  // D5, 1 Hz blink (center green LED)
  assign io_in[0] = clk_sys;
  assign io_in[1] = clk_uart;
  assign io_in[2] = RX;
  assign io_in[7:3] = 0;
  assign O_DATA   = io_out;     // output pins from projects
  assign TX       = RX;         // serial data to host

  morningjava_top morningjava_top_inst(
    .io_in (io_in),
    .io_out(io_out)
  );

  prescaler #(
    .OSCRATE(12_000_000),  // oscillator frequency
    .CLKRATE(1_790_000),   // system clock frequency
    .BAUDRATE(9600)        // baud rate
  ) prescaler_inst (
    .osc     (OSC),        // sysem oscillator
    .rx      (RX),         // serial input for activity indicator
    .clk_sys (clk_sys),    // APU system clock, 1.79 MHz
    .clk_uart(clk_uart),   // 16x UART clock, 4800 Hz
    .blink   (blink),      // 1 Hz blink indicator
    .link    (link)        // activity indicator
  );
  
endmodule
