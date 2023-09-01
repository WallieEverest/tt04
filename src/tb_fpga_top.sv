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
  wire rtsn = 1;
  wire [7:0] ui_in;
  wire [7:0] uo_out;
  wire rx = message[0];
  assign ui_in = 0;

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

    // # Square 1
    // 08 82 30 80 00 84 00 86 #Clear $30 $08 $00 $00
    // 27 83 02 81 7E 85 08 86 #PlaySmallJump
    // 27 83 02 81 7C 84 09 86 #PlayBigJump
    // 13 83 1E 81 3A 84 0A 86 #PlayBump
    // 19 83 1E 81 0A 84 08 86 #PlayFireballThrow
    // 4B 83 1F 81 6F 85 08 86 #PlaySmackEnemy
    // 1C 83 1E 81 7E 85 08 86 #PlaySwimStomp
    // 08 82 3F 81 17 84 01 86 #400Hz $BF $08 $17 $01

    message = {STOP,8'h08,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h82,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h3F,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h81,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h17,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h84,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h01,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h86,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    // # Square 2
    // 30 88 08 8A 00 8C 00 8E #Clear $30 $08 $00 $00
    // 18 89 7F 8A 71 8C 08 8E #PlayTimerTick
    // 0D 89 7F 8A 71 8C 08 8E #PlayCoinGrab
    // 1F 89 14 8B 79 8D 0A 8E #PlayBlast
    // 7F 88 5D 8A 71 8C 08 8E #PlayPowerUpGrab
    // 3F 89 08 8A 17 8C 01 8E #400Hz $BF $08 $17 $01

    message = {STOP,8'h3F,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h89,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h08,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h8A,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h17,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h8C,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h01,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h8E,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    // # Triangle
    // 00 91 00 94 00 96 #Clear $80 $00 $00
    // 40 91 0B 95 00 96 #400Hz $C0 $8B $00

    message = {STOP,8'h40,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h91,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h0B,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h95,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h00,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h96,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    // # Noise
    // 30 98 00 9A 00 9C 00 9E #Clear $30 $00 $00 $00
    // 05 9D 3F 98 #300Hz $3F $85

    message = {STOP,8'h05,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h9D,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h3F,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h98,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    #20ms

    #2000ms

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
    message = {STOP,8'h83,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h02,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h81,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h7C,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h84,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h09,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h86,START};
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

    message = {STOP,8'h13,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h83,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h1E,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h81,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h3A,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h84,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h0A,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h86,START};
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

    message = {STOP,8'h4B,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h83,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h1F,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h81,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h6F,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h85,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};

    message = {STOP,8'h08,START};
    repeat (DELAY) @(negedge sck) message = {STOP, message[WIDTH-1:1]};
    message = {STOP,8'h86,START};
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


// # Square 1
// 08 82 30 80 00 84 00 86 #Clear
// 27 83 02 81 7E 85 08 86 #PlaySmallJump
// 27 83 02 81 7C 84 09 86 #PlayBigJump
// 13 83 1E 81 3A 84 0A 86 #PlayBump
// 19 83 1E 81 0A 84 08 86 #PlayFireballThrow
// 4B 83 1F 81 6F 85 08 86 #PlaySmackEnemy
// 1C 83 1E 81 7E 85 08 86 #PlaySwimStomp
// 08 82 3F 81 17 84 01 86 #400Hz
// # Square 2
// 30 88 08 8A 00 8C 00 8E #Clear
// 18 89 7F 8A 71 8C 08 8E #PlayTimerTick
// 0D 89 7F 8A 71 8C 08 8E #PlayCoinGrab
// 1F 89 14 8B 79 8D 0A 8E #PlayBlast
// 7F 88 5D 8A 71 8C 08 8E #PlayPowerUpGrab
// 3F 89 08 8A 17 8C 01 8E #400Hz
// # Triangle
// 00 91 00 92 00 94 00 96 #Clear
// 00 92 0B 95 00 96 40 91 #400Hz
// # Noise
// 30 98 00 9A 00 9C 00 9E #Clear
// 00 9A 00 9E 05 9D 3F 98 #300Hz
//  #StrongBeat
//  #LongBeat

endmodule
