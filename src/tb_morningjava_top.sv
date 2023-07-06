// Title:   Square root testbench
// File:    tb_morningjava_top.sv
// Author:  Wallace Everest
// Date:    23-NOV-2022
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0

`default_nettype none
`timescale 1us/100ns

module a_tb_morning_java_top ();
  localparam WIDTH = 10;  // number of bits in message
  localparam DELAY = WIDTH+0; // assume two stop bits
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP  = 1'b1;

  reg  [WIDTH-1:0] message = IDLE;  // default to IDLE pattern
  reg  clk = 0;
  wire clk_uart = clk;  // uart clock is same as system clock for this version
  wire [7:0] io_in;
  wire [7:0] io_out;
  wire [3:0] dac = io_out[3:0];
  wire sdi = message[0];
  wire sck;
  assign io_in[0] = clk;
  assign io_in[1] = clk_uart;
  assign io_in[2] = sdi;
  assign io_in[3] = 0;
  assign io_in[4] = 0;
  assign io_in[5] = 0;
  assign io_in[6] = 0;
  assign io_in[7] = 0;
 
  morningjava_top dut (
    .io_in (io_in),
    .io_out(io_out)
  );

  initial forever #104 clk = ~clk;  // 4800 Hz system clock
  
  initial begin
    repeat (2) @(negedge sck);
    message = {STOP,8'h01,START};  // select project 1
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h01,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h10,START};  // select tap 2
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h22,START};  // send data
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h30,START};  // send data
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h43,START};  // deselect tap 2
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h50,START};  // send data
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h64,START};  // deselect tap 2
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h70,START};  // send data
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    repeat (2) @(negedge sck);

  end
endmodule
