// Title:   System in indicator
// File:    system.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Divides the system clock down to a communication clock and status indicators.

`default_nettype none

module system #(
  parameter CLKRATE  = 1_789_773,  // APU clock frequency
  parameter BAUDRATE = 9600        // serial data rate
)(
  input  wire clk,      // system clock
  input  wire rx,       // serial input data
  output wire blink,    // 1 Hz
  output reg  link,     // serial activity
  output reg  uart_clk  // 6x baud rate, 57,600 Hz
);

  localparam UART_DIVISOR = (CLKRATE / BAUDRATE / 6);  // 31: 9600 baud => 57,600 Hz
  localparam KHZ_DIVISOR  = (CLKRATE / 1000);  // 1789: 1000 Hz

  reg event_1khz;
  reg rx_meta;
  reg sdi;
  reg [ 1:0] sdi_delay;
  reg [ 5:0] count_baud;
  reg [10:0] count_1khz;
  reg [ 9:0] count_1hz;
  reg [ 4:0] count_link;
  
  assign blink = count_1hz[9];  // toggle LED at 1 Hz

  always @( posedge clk ) begin
    rx_meta      <= rx;       // capture asynchronous input
    sdi          <= rx_meta;  // align input to the system clock
    sdi_delay[0] <= sdi;      // asynchronous input
    sdi_delay[1] <= sdi_delay[0];
    link         <= ( count_link != 0 );  // show RX activity

    if ( count_baud != 0 )  // baud rate divisor
      count_baud <= count_baud-1;
    else
      count_baud <= UART_DIVISOR[5:0] - 1;

    uart_clk <= ( count_baud == 0 );

    if ( count_1khz != 0 )  // 1 kHz counter
      count_1khz <= count_1khz-1;
    else
      count_1khz <= KHZ_DIVISOR[10:0] - 1;

    event_1khz <= ( count_1khz == 0 );  // 1 kHz event

    if ( event_1khz ) begin  // 1 Hz counter
      if ( count_1hz != 0 )
        count_1hz <= count_1hz-1;
      else
        count_1hz <= 999;
    end

    if ( sdi_delay[1] != sdi_delay[0] )  // edge detect of RX
      count_link <= ~0;
    else if ( event_1khz && ( count_link != 0 ))  // LED persistence
      count_link <= count_link-1;
  end

endmodule
