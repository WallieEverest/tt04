// Title:   Clock prescaler
// File:    prescaler.v
// Author:  Wallie Everest
// Date:    26-MAR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:
//   Divides the oscillator down to a system and communication clocks.

`default_nettype none

module prescaler #(
  parameter OSCRATE = 12_000_000,  // oscillator clock frequency
  parameter BAUDRATE = 9600,       // serial data rate
  parameter CLKRATE = 1_790_000    // system clock frequency
)(
  input  wire osc,
  input  wire rx,
  output reg  clk = 0,       // APU system clock
  output reg  clk_uart = 0,  // 5x baud rate
  output reg  blink = 0,     // 1 Hz
  output reg  link = 0       // serial activity
)  /* synthesis syn_hier="fixed" */;

  localparam [2:0] CLK_DIVISOR = OSCRATE / CLKRATE;  // 1.79 MHz => 6.7
  localparam [7:0] BAUD_DIVISOR = OSCRATE / BAUDRATE / 5;  // 250: 9600 baud => 48,000 Hz

  reg rx_meta = 0;
  reg sdi = 0;
  reg [ 1:0] sdi_delay = 0;
  reg [ 2:0] count_clk = 0 /* synthesis syn_preserve=1 */;
  reg [ 7:0] count_baud = 0 /* synthesis syn_preserve=1 */;
  reg [11:0] count_4khz = 0;
  reg [10:0] count_2hz = 0;
  reg [ 7:0] count_link = 0;
  reg event_4khz = 0;
  reg event_2hz = 0;

  always @(posedge osc) begin
    rx_meta      <= rx;       // capture asynchronous input
    sdi          <= rx_meta;  // align input to the system clock
    sdi_delay[0] <= sdi;      // asyncronous input
    sdi_delay[1] <= sdi_delay[0];
    clk          <= (count_clk < 3);  // extend clock duration
    link         <= (count_link != 0);  // show RX activity

    if (count_clk != 0)
      count_clk <= count_clk-1;
    else
      count_clk <= CLK_DIVISOR-1;

    if (count_baud != 0)
      count_baud <= count_baud-1;
    else
      count_baud <= BAUD_DIVISOR-1;

    if (count_baud < BAUD_DIVISOR/2)
      clk_uart <= 1;
    else
      clk_uart <= 0;

    event_4khz <= (count_4khz == 1);  // 4 kHz clock
    count_4khz <= (event_4khz) ? 3000-1 : count_4khz-1;
    
    if (event_4khz) begin
      event_2hz <= (count_2hz == 1);  // 2 Hz clock
      count_2hz <= (event_2hz) ? 2000-1 : count_2hz-1;
    end

    if (event_4khz && event_2hz)
      blink <= ~blink;  // toggle LED at 1 Hz

    if (sdi_delay[1] != sdi_delay[0])
      count_link <= ~0;
    else
      if (event_4khz && (count_link != 0))
        count_link <= count_link-1;
  end
  
endmodule
