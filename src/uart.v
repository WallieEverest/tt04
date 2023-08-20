// Title:   Serial register decoder
// File:    decoder.v
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
  input  wire clk,  // 5x baud clock
  input  wire rx,   // asynchronous serial input
  output reg  [7:0] reg_4000 = 0,
  output reg  [7:0] reg_4001 = 0,
  output reg  [7:0] reg_4002 = 0,
  output reg  [7:0] reg_4003 = 0,
  output reg  [7:0] reg_4007 = 0,
  output reg  [7:0] reg_4008 = 0,
  output reg  [7:0] reg_400A = 0,
  output reg  [7:0] reg_400B = 0,
  output reg        reg_change = 0
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
  wire [3:0] addr = shift[8:5];  // address is upper nibble
  wire [3:0] data = shift[4:1];  // data is lower nibble
  reg  [3:0] hold = 0;
  reg  [3:0] bit_count = 0;
  wire zero_count = (bit_count == 0);
  wire msg_sync = (shift[WIDTH-1] == STOP) && (shift[0] == START) && zero_count;  // valid message

  always @(posedge clk) begin
    rx_meta <= rx;       // capture asynchronous input
    sdi     <= rx_meta;  // generate delay to detect edge

    if (sdi != rx_meta)  // edge detected
      baud_count <= 0;   // synchronize bit clock with phase offset
    else
      if (baud_count < BAUD_DIV-1)
        baud_count <= baud_count+1;
      else
        baud_count <= 0;

    if (baud_count < BAUD_DIV/2)
      sck <= 0;  // generate falling edge of sck on RX change
    else
      sck <= 1;  // generate rising edge of sck midway through bit period
  end

  always @(posedge sck) begin
    shift <= {sdi, shift[WIDTH-1:1]};  // right-shift and get next sdi bit

    if (zero_count)
      bit_count <= WIDTH-1;
    else
      if ( (shift[WIDTH-1] == START) || (bit_count != WIDTH-1) )  // synchronize with IDLE pattern
        bit_count <= bit_count - 1;

    if (msg_sync) begin // capture user inbound data
      hold <= data;     // hold first 4-bits and wait for remaining half
      if (addr == 7)  // DEBUG
        reg_change <= ~reg_change;  // toggle on register update
      case (addr)
        1:  reg_4000 <= {data, hold};
        3:  reg_4001 <= {data, hold};
        5:  reg_4002 <= {data, hold};
        7:  reg_4003 <= {data, hold};
        9:  reg_4007 <= {data, hold};
        11: reg_4008 <= {data, hold};
        13: reg_400A <= {data, hold};
        15: reg_400B <= {data, hold};
      endcase
    end
  end

endmodule
