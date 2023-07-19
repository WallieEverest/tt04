// Title:   ASIC top-level testbench
// File:    tb_morningjava_top.sv
// Author:  Wallace Everest
// Date:    23-NOV-2022
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0

`default_nettype none
`timescale 1ns/100ps

module a_tb_morning_java_top ();
  localparam WIDTH = 10;  // number of bits in message
  localparam DELAY = WIDTH+0; // assume two stop bits
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP  = 1'b1;

  reg  [WIDTH-1:0] message = IDLE;  // default to IDLE pattern
  reg  clk = 0;
  reg  sck = 0;
  wire rst_n = 1;
  wire ena = 1;
  wire [7:0] ui_in;
  wire [7:0] uio_in = 0;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
  wire rx = message[0];
  assign ui_in[0] = rx;
  assign ui_in[7:1] = 0;
 
  tt_um_morningjava_top dut (
    .clk    (clk),
    .rst_n  (rst_n),
    .ena    (ena),
    .ui_in  (ui_in),
    .uio_in (uio_in),
    .uo_out (uo_out),
    .uio_out(uio_out),
    .uio_oe (uio_oe)
  );

  initial forever #41.7ns clk = ~clk;  // 12 MHz system clock
  initial forever #52083ns sck = ~sck;  // 9,600 baud UART

  initial begin
    repeat (2) @(negedge sck);
    
    // SMBDIS.ASM
    // PlayBigJump:
    //  SND_SQUARE1_REG+1 = 0xA7; Y
    //  SND_SQUARE1_REG = 0x82; X
    //  SND_REGISTER+2 = 0x7C; FreqRegLookupTbl+1[A=24]
    //  SND_REGISTER+3 = 0x09; FreqRegLookupTbl+1[A=24] | 0x08
    //  lda #$28                  ;store length of sfx for both jumping sounds
    //  sta Squ1_SfxLenCounter    ;then continue on here
      
    message = {STOP,8'h27,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h3A,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h02,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h18,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h4C,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h57,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h69,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h70,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    #200ms
    // PlayBump:
    //  lda #$0a
    // Fthrow:
    //  sta Squ1_SfxLenCounter
    //  SND_SQUARE1_REG+1 = 0x93; Y
    //  SND_SQUARE1_REG = 0x9E; X
    //  SND_REGISTER+2 = 0x3A; FreqRegLookupTbl+1[A=12]
    //  SND_REGISTER+3 = 0x0A; FreqRegLookupTbl+1[A=12] | 0x08

    message = {STOP,8'h23,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h39,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h0E,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h19,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h4A,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h53,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h6A,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h70,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    #400ms
    // PlaySmackEnemy:
    //  lda #$0e
    //  sta Squ1_SfxLenCounter
    //  SND_SQUARE1_REG+1 = 0xCB; Y
    //  SND_SQUARE1_REG = 0x9F; X
    //  SND_REGISTER+2 = 0xEF; FreqRegLookupTbl+1[A=40]
    //  SND_REGISTER+3 = 0x08; FreqRegLookupTbl+1[A=40] | 0x08

    message = {STOP,8'h2B,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h3C,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h0F,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h19,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h4F,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h5E,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h68,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h70,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};        
  end

endmodule
