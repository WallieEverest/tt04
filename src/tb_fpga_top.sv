// Title:   FPGA top-level testbench
// File:    tb_fpga_top.sv
// Author:  Wallace Everest
// Date:    25-MAR-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

// FreqRegLookupTbl:
//  [0]  $00, $88, $00, $2f, $00, $00
//  [6]  $02, $a6, $02, $80, $02, $5c, $02, $3a
//  [14] $02, $1a, $01, $df, $01, $c4, $01, $ab
//  [22] $01, $93, $01, $7c, $01, $67, $01, $53
//  [30] $01, $40, $01, $2e, $01, $1d, $01, $0d
//  [38] $00, $fe, $00, $ef, $00, $e2, $00, $d5
//  [46] $00, $c9, $00, $be, $00, $b3, $00, $a9
//  [54] $00, $a0, $00, $97, $00, $8e, $00, $86
//  [62] $00, $77, $00, $7e, $00, $71, $00, $54
//  [70] $00, $64, $00, $5f, $00, $59, $00, $50
//  [78] $00, $47, $00, $43, $00, $3b, $00, $35
//  [86] $00, $2a, $00, $23, $04, $75, $03, $57
//  [94] $02, $f9, $02, $cf, $01, $fc, $00, $6a

`default_nettype none
`timescale 1ns/100ps

module a_tb_fpga_top ();
  localparam WIDTH = 10;  // number of bits in message
  localparam DELAY = WIDTH+0;
  localparam [WIDTH-1:0] IDLE = ~0;
  localparam START = 1'b0;
  localparam STOP  = 1'b1;
  
  reg  [WIDTH-1:0] message = IDLE;  // default to IDLE pattern
  reg  clk = 0;
  reg  sck = 0;
  wire dtrn = 1;
  wire rtsn = 0;
  wire [7:0] ui_in = 0;
  wire [7:0] uo_out;
  wire rx = message[0];

  tb_audio_pwm tb_audio_pwm_inst (
    .pwm(uo_out[3])
  );

  fpga_top dut (
    .clk(clk),
    .dtrn(dtrn),
    .rx(rx),
    .rtsn(rtsn),
    .ui_in(ui_in),
    .uo_out(uo_out),
    .tx(),
    .led()
  );
    
  initial forever #41.7ns clk = ~clk;   // 12 MHz system clock
  initial forever #52083ns sck = ~sck;  // 9,600 baud UART

  initial begin
    repeat (2) @(negedge sck);
    
    // Set Bank 0
    message = {STOP,8'h80,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    // SMBDIS.ASM
    // PlayBigJump:
    //  lda #$18
    //  SND_SQUARE1_REG+1 = 0xA7; Y
    //  SND_SQUARE1_REG = 0x82; X
    //  SND_REGISTER+2 = 0x7C; FreqRegLookupTbl+1[A=0x18]
    //  SND_REGISTER+3 = 0x09; FreqRegLookupTbl[A=24] | 0x08
    //  lda #$28                  ;store length of sfx for both jumping sounds
    //  sta Squ1_SfxLenCounter    ;then continue on here
    //  fading tone
      
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
    //  ldy #$93
    // Fthrow:
    //  sta Squ1_SfxLenCounter
    //  SND_SQUARE1_REG+1 = 0x93; Y
    //  SND_SQUARE1_REG = 0x9E; X
    //  SND_REGISTER+2 = 0x3A; FreqRegLookupTbl+1[A=0x0A]
    //  SND_REGISTER+3 = 0x0A; FreqRegLookupTbl[A=12] | 0x08
    //  descending tone

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
    //  lda #$28
    //  SND_SQUARE1_REG+1 = 0xCB; Y
    //  SND_SQUARE1_REG = 0x9F; X
    //  SND_REGISTER+2 = 0xEF; FreqRegLookupTbl+1[A=0x28]
    //  SND_REGISTER+3 = 0x08; FreqRegLookupTbl[A=40] | 0x08
    //  ascending and fading tone

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

  // PlayFireballThrow
  //  lda #$05
  //  ldy #$99
  // Fthrow:
  //  sta Squ1_SfxLenCounter
  //  SND_SQUARE1_REG+1 = 0x99; Y
  //  SND_SQUARE1_REG = 0x9E; X
  //  SND_REGISTER+2 = 0x0A; FreqRegLookupTbl+1[A=0x05]
  //  SND_REGISTER+3 = 0x08; FreqRegLookupTbl[A=5] | 0x08
  //  descending tone

  // PlaySmallJump:
  //  lda #$26
  //  SND_SQUARE1_REG+1 = 0xA7; Y
  //  SND_SQUARE1_REG = 0x82; X
  //  SND_REGISTER+2 = 0xFE; FreqRegLookupTbl+1[A=0x26]
  //  SND_REGISTER+3 = 0x08; FreqRegLookupTbl[A=38] | 0x08
  //  lda #$28                  ;store length of sfx for both jumping sounds
  //  sta Squ1_SfxLenCounter    ;then continue on here
  //  fading tone

  // PlaySwimStomp:
  //  lda #$0e               ;store length of swim/stomp sound
  //  sta Squ1_SfxLenCounter
  //  lda #$26
  //  SND_SQUARE1_REG+1 = 0x9C; Y
  //  SND_SQUARE1_REG = 0x9E; X
  //  SND_REGISTER+2 = 0xFE; FreqRegLookupTbl+1[A=0x26]
  //  SND_REGISTER+3 = 0x08; FreqRegLookupTbl[A=38] | 0x08

  // PlayCoinGrab:
  // lda #$35
  // sta Squ2_SfxLenCounter 
  // lda #$42
  // SND_SQUARE2_REG = 0x8D; X
  // SND_SQUARE2_REG+1 = 0x7F; Y
  // SND_REGISTER2+2 = 0x71; FreqRegLookupTbl+1[A=66]
  // SND_REGISTER2+3 = 0x08; FreqRegLookupTbl[A=0x42] | 0x08

  // PlayTimerTick:
  // lda #$06
  // sta Squ2_SfxLenCounter 
  // lda #$42
  // SND_SQUARE2_REG = 0x98; X
  // SND_SQUARE2_REG+1 = 0x7F; Y
  // SND_REGISTER2+2 = 0x71; FreqRegLookupTbl+1[A=66]
  // SND_REGISTER2+3 = 0x08; FreqRegLookupTbl[A=0x42] | 0x08

  // PlayBlast:
  // lda #$20
  // sta Squ2_SfxLenCounter 
  // lda #$42
  // SND_SQUARE2_REG = 0x9F; X
  // SND_SQUARE2_REG+1 = 0x94; Y
  // SND_REGISTER2+2 = 0xF9; FreqRegLookupTbl+1[A=94]
  // SND_REGISTER2+3 = 0x0A; FreqRegLookupTbl[A=0x5E] | 0x08

  // PlayPowerUpGrab: debug
  // lda #$36
  // sta Squ2_SfxLenCounter 
  // lda #$42
  // SND_SQUARE2_REG = 0x7F; X
  // SND_SQUARE2_REG+1 = 0x5D; Y
  // SND_REGISTER2+2 = 0x71; FreqRegLookupTbl+1[A=66]
  // SND_REGISTER2+3 = 0x08; FreqRegLookupTbl[A=0x42] | 0x08

endmodule
