// Title:   Serial UART and register decoder
// File:    uart.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Uses Verilog-2001 array features
//
//   Recovers a bit clock (sck) from asynchronous serial data.
//   A reference clock must be supplied at 5x the baud rate
//   Decodes serial bytes onto a register array
//
//   Byte format
//   Bit Description
//    7  Bank
//    6  Addr[2]
//    5  Addr[1]
//    4  Addr[0]
//    3  Data[3]
//    2  Data[2]
//    1  Data[1]
//    0  Data[0]
//
//   The 16 byte register array is configured as four banks of four registers each.
//   When (Bank=1), the bank select register is set to Data[1:0]
//   When (Bank=0), the data register addressed by {Bank[1:0], Addr[2:0]} is set to Data[3:0]
//   A write event is posted for the high-order register in each bank
//
//   Example
//   8'h82 selects bank 2
//   8'h6F sets the lower nibble of bank 2, register 3 to the value 4'hF
//   8'h7A sets the upper nibble of bank 2, register 3 to the value 4'hA
//   reg_data[8] = 8'hAF
//   reg_event[2] = 1 for one serial-clock period

`default_nettype none

module uart (
  input  wire clk,  // 5x baud clock
  input  wire rx,   // asynchronous serial input
  output reg [16*8-1:0] reg_data = 0,  // flattened array of 16 bytes (128 bits)
  output reg  [3:0] reg_event = 0
) /* synthesis syn_hier="fixed" */;

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
  wire msg_sync = (shift[WIDTH-1] == STOP) && (shift[0] == START) && zero_count;  // valid message

  always @(posedge clk) begin : uart_serial_clock
    rx_meta <= rx;       // capture asynchronous input
    sdi     <= rx_meta;  // generate delay to detect edge

    if (sdi != rx_meta) begin // edge detected
      baud_count <= 0;   // synchronize bit clock with phase offset
    end else begin
      if (baud_count < BAUD_DIV-1)
        baud_count <= baud_count+1;
      else
        baud_count <= 0;
    end

    if (baud_count < BAUD_DIV/2)
      sck <= 0;  // generate falling edge of SCK on RX change
    else
      sck <= 1;  // generate rising edge of SCK midway through bit period
  end

  always @(posedge sck) begin : uart_serial_shift
    shift <= {sdi, shift[WIDTH-1:1]};  // right-shift and get next SDI bit

    if ( zero_count )
      bit_count <= WIDTH-1;
    else if ( (shift[WIDTH-1] == START) || (bit_count != WIDTH-1) )  // synchronize with IDLE pattern
      bit_count <= bit_count - 1;
  end

  always @(posedge sck) begin : uart_decode
    if (msg_sync) begin  // capture user inbound data
      if (bank)
        bank_select <= data[1:0];  // select register bank
      else begin
        reg_data[4*reg_select+0] <= data[0];  // data nibble of register
        reg_data[4*reg_select+1] <= data[1];
        reg_data[4*reg_select+2] <= data[2];
        reg_data[4*reg_select+3] <= data[3];
      end
    end

    if (msg_sync && !bank && (addr == 7))  // event for high-order register in bank
      reg_event <= 4'h1 << bank_select;
    else
      reg_event <= 4'h0;
  end
endmodule
