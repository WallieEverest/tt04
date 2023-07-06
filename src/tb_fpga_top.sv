// Title:   Tiny Tapeout Simulation Test Procedure
// File:    tb_fpga_top.sv
// Author:  Wallace Everest
// Date:    25-MAR-2023
// URL:     https://github.com/wallieeverest/tt03
// License: Apache 2.0
//
// Description:
// Implementation:
// Operation:

`default_nettype none
`timescale 1ns/100ps

module a_tb_fpga_top ();
  localparam WIDTH = 10;  // number of bits in message
  localparam DELAY = WIDTH+0;
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP  = 1'b1;
  
  reg  [WIDTH-1:0] message = IDLE;  // default to IDLE pattern
  wire [7:0] i_data;
  wire [7:0] o_data;
  reg  clk = 0;
  reg  trst = 0;
  reg  sck = 0;
  wire sdi;
  wire sdo;
  reg  tms = 0;  // scan chain defaults to bypass
  wire rx = message[0];

  assign i_data = 0;

  fpga_top fpga_inst (
    .OSC(clk),
    .DTRN(trst),
    .RX(rx),
    .RTSN(tms),
    .I_DATA(i_data),
    .O_DATA(o_data),
    .TX(),
    .LED()
  );
    
  initial forever #41.7ns clk = ~clk;   // 12 MHz system clock
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
