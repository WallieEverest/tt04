// Title:   Serial UART and register decoder
// File:    uart.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Recovers a bit clock (sck) from asynchronous serial data.
//   A reference clock must be supplied at 5x the baud rate
//   A register address and data are recovered from two consecutive
//   serial bytes. A byte with the msb=0 is considered the
//   first byte with 7-bits of data. A byte with msb=1 is considered
//   the second byte with the remaining 1-bit of data and a 6-bit address.
//   A ready flag is generated after receiving the second byte.
//     Byte 1                              Byte 2
//   -------------------------------------------------------------------------
//   | Start D0 D1 D2 D3 D4 D5 D6 0 Stop | Start D7 A0 A1 A2 A3 A4 A5 1 Stop |
//   -------------------------------------------------------------------------
//  To do:
//    1.) Consider if powerup of shift register can cause an errant event.
//    Possibly need to invert signal.

`default_nettype none

module uart (
  input  wire clk,                  // system clock
  input  wire uart_clk,             // 6x baud clock
  input  wire rx,                   // asynchronous serial input
  output reg  [3:0] uart_addr = 0,  // serial address, addr[5:4] is unused
  output reg  [7:0] uart_data = 0,  // serial data
  output reg  uart_ready = 0        // data ready
);

  localparam [2:0] BAUD_DIV = 6;
  localparam WIDTH = 10;  // number of bits in message
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP = 1'b1;

  reg rx_meta = 0;
  reg sdi = 0;
  reg [WIDTH-1:0] shift = IDLE;  // default to IDLE pattern
  reg [2:0] baud_count = 0;
  reg [3:0] bit_count = 0;
  reg [6:0] data_hold = 0;
  wire [7:0] data = shift[8:1];  // serial byte
  wire zero_count = ( bit_count == 0 );
  wire msg_valid = ( shift[WIDTH-1] == STOP ) && ( shift[0] == START ) && zero_count;  // valid message
  wire sck = ( baud_count == 3 );  // recovered serial clock at mid-point of symbol

  always @( posedge clk ) begin : uart_serial_receiver
    if ( uart_clk ) begin
      rx_meta <= rx;   // capture asynchronous input
      sdi <= rx_meta;  // generate delay to detect edge

      if (( sdi != rx_meta ) || ( baud_count >= BAUD_DIV-1 ))  // edge detected or rollover
        baud_count <= 0;  // synchronize bit clock with phase offset
      else
        baud_count <= baud_count+1;

      if ( sck ) begin
        shift <= {sdi, shift[WIDTH-1:1]};  // right-shift and get next SDI bit

        if ( zero_count )
          bit_count <= WIDTH-1;
        else if (( shift[WIDTH-1] == START ) || ( bit_count != WIDTH-1 ))  // synchronize with IDLE pattern
          bit_count <= bit_count - 1;

        if ( msg_valid ) begin
          data_hold <= data[6:0];

          if ( data[7] ) begin  // capture user inbound data
            uart_addr <= data[4:1];
            uart_data <= {data[0], data_hold};
            uart_ready <= 1;
          end else begin
            uart_ready <= 0;
          end
        end
      end
    end
  end

endmodule
