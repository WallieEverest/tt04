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

module registers (
  input  wire clk,
  input  wire [4:0] uart_addr,          // serial address
  input  wire [3:0] uart_data,          // serial data
  input  wire uart_ready,               // data ready
  output reg  [16*8-1:0] reg_data = 0,  // flattened array of 16 bytes (128 bits)
  output reg  [3:0] reg_event = 0
);

  reg uart_meta = 0;  // asynchronous clock crossing
  reg [1:0] edge_detect = 0;
  wire uart_event = ( edge_detect == 2'b01 );  // rising edge of uart ready

  always @( posedge clk ) begin : registers_decode
    uart_meta <= uart_ready;
    edge_detect <= {edge_detect[0], uart_meta};
    
    if ( uart_event ) begin  // capture user inbound data
        reg_data[4*uart_addr+0] <= uart_data[0];  // data nibble of register
        reg_data[4*uart_addr+1] <= uart_data[1];
        reg_data[4*uart_addr+2] <= uart_data[2];
        reg_data[4*uart_addr+3] <= uart_data[3];
    end

    if ( uart_event && ( uart_addr[2:0] == 7 ))  // event for high-order register in bank
      reg_event <= 4'h1 << uart_addr[4:3];
    else
      reg_event <= 4'h0;
  end
endmodule
