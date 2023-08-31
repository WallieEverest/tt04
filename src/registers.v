// Title:   Serial UART and register decoder
// File:    uart.v
// Author:  Wallace Everest
// Date:    12-APR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Decodes serial bytes onto a register array
//
//   The 16 byte register array is configured as four banks of four registers each.
//   One bit in reg_event[] is pulsed after receiving the top register in each bank.

`default_nettype none

module registers (
  input  wire clk,
  input  wire [3:0] uart_addr,       // serial address
  input  wire [7:0] uart_data,       // serial data
  input  wire uart_ready,            // data ready
  output reg  [127:0] reg_data = 0,  // flattened array of 16 bytes (128 bits)
  output reg  [3:0] reg_event = 0
);

  reg [1:0] edge_detect = 0;
  wire uart_event = ( edge_detect == 2'b01 );  // rising edge of uart ready

  always @( posedge clk ) begin : registers_decode
    edge_detect <= {edge_detect[0], uart_ready};

    if ( uart_event ) begin   // capture inbound data
      reg_data[8*uart_addr+0] <= uart_data[0];
      reg_data[8*uart_addr+1] <= uart_data[1];
      reg_data[8*uart_addr+2] <= uart_data[2];
      reg_data[8*uart_addr+3] <= uart_data[3];
      reg_data[8*uart_addr+4] <= uart_data[4];
      reg_data[8*uart_addr+5] <= uart_data[5];
      reg_data[8*uart_addr+6] <= uart_data[6];
      reg_data[8*uart_addr+7] <= uart_data[7];
    end

    if ( uart_event && ( uart_addr[1:0] == 3 ))  // event for high-order register in bank
      reg_event <= 4'h1 << uart_addr[3:2];
    else
      reg_event <= 4'h0;
  end
  
endmodule
