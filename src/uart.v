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

`default_nettype none

module uart (
  input  wire clk,                  // 5x baud clock
  input  wire rx,                   // asynchronous serial input
  output reg  [4:0] uart_addr = 0,  // serial address
  output reg  [3:0] uart_data = 0,  // serial data
  output reg  uart_ready = 0        // data ready
);

  localparam [2:0] BAUD_DIV = 5;
  localparam WIDTH = 10;  // number of bits in message
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP = 1'b1;

  reg [2:0] baud_count = 0 /* synthesis syn_preserve=1 */;
  reg rx_meta = 0;
  reg sdi = 0;
  reg sck = 0;                   // recovered serial clock
  reg  [WIDTH-1:0] shift = IDLE; // default to IDLE pattern
  wire       bank = shift[8];    // bank select
  wire [2:0] addr = shift[7:5];  // nibble address
  wire [3:0] data = shift[4:1];  // data nibble
  reg  [3:0] bit_count = 0;
  reg  [1:0] bank_select = 0;
  wire [4:0] reg_select = {bank_select, addr};
  wire zero_count = (bit_count == 0);
  wire msg_sync = ( shift[WIDTH-1] == STOP ) && ( shift[0] == START ) && zero_count;  // valid message

  always @( posedge clk ) begin : uart_serial_clock
    rx_meta <= rx;       // capture asynchronous input
    sdi     <= rx_meta;  // generate delay to detect edge

    if ( sdi != rx_meta ) begin // edge detected
      baud_count <= 0;   // synchronize bit clock with phase offset
    end else begin
      if ( baud_count < BAUD_DIV-1 )
        baud_count <= baud_count+1;
      else
        baud_count <= 0;
    end

    if ( baud_count < BAUD_DIV/2 )
      sck <= 0;  // generate falling edge of SCK on RX change
    else
      sck <= 1;  // generate rising edge of SCK midway through bit period
  end

  always @( posedge sck ) begin : uart_serial_shift
    shift <= {sdi, shift[WIDTH-1:1]};  // right-shift and get next SDI bit

    if ( zero_count )
      bit_count <= WIDTH-1;
    else if ( ( shift[WIDTH-1] == START ) || ( bit_count != WIDTH-1 ) )  // synchronize with IDLE pattern
      bit_count <= bit_count - 1;
  end

  always @( posedge sck ) begin : uart_decode
    uart_ready <= ( msg_sync && !bank );
    if ( msg_sync ) begin  // capture user inbound data
      if ( bank ) begin
        bank_select <= data[1:0];  // select register bank
      end else begin
        uart_addr  <= reg_select;
        uart_data  <= data;
      end
    end
  end
endmodule
