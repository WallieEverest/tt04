![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)

# The ChipTune Project

This project is an audio device that replicates the square-wave sound generators of vintage video games.

## TinyTapeout 4 Configuration

![Top Level Drawing](image/tt04.svg)

Devices from the eFabless Multi-Project Wafer (MPW) shuttle are delivered in two package options, each with 64 pins. TinyTapeout 4 will be packaged in the QFN variant, mounted on a daughterboard for breakout.

Based on data from:
    
https://github.com/efabless/caravel_board/blob/main/hardware/breakout/caravel-M.2-card-QFN/caravel-M.2-card-QFN.pdf
    
https://github.com/psychogenic/caravel-breakout-pcb/tree/main/breakout-qfn

https://github.com/TinyTapeout/tt-multiplexer/blob/main/docs/INFO.md

### MPRJ_IO Pin Assignments
| Signal      | Name       | Dir | QFN | PCB   |
| ----------- | ---------- |---- |---- |------ |
| mprj_io[0]  | JTAG       | In  | 31  |       |
| mprj_io[1]  | SDO        | Out | 32  |       |
| mprj_io[2]  | SDI        | In  | 33  |       |
| mprj_io[3]  | CSB        | In  | 34  |       |
| mprj_io[4]  | SCK        | In  | 35  |       |
| mprj_io[5]  | USER_CLK   | Out | 36  |       |
| mprj_io[6]  | CLK        | In  | 37  |       |
| mprj_io[7]  | RST_N      | In  | 41  |       |
| mprj_io[8]  | UI_IN[0]   | In  | 42  |       |
| mprj_io[9]  | UI_IN[1]   | In  | 43  |       |
| mprj_io[10] | UI_IN[2]   | In  | 44  |       |
| mprj_io[11] | UI_IN[3]   | In  | 45  |       |
| mprj_io[12] | UI_IN[4]   | In  | 46  |       |
| mprj_io[13] | UI_IN[5]   | In  | 48  |       |
| mprj_io[14] | UI_IN[6]   | In  | 50  |       |
| mprj_io[15] | UI_IN[7]   | In  | 51  |       |
| mprj_io[16] | UO_OUT[0]  | Out | 53  |       |
| mprj_io[17] | UO_OUT[1]  | Out | 54  |       |
| mprj_io[18] | UO_OUT[2]  | Out | 55  |       |
| mprj_io[19] | UO_OUT[3]  | Out | 57  |       |
| mprj_io[20] | UO_OUT[4]  | Out | 58  |       |
| mprj_io[21] | UO_OUT[5]  | Out | 59  |       |
| mprj_io[22] | UO_OUT[6]  | Out | 60  |       |
| mprj_io[23] | UO_OUT[7]  | Out | 61  |       |
| mprj_io[24] | UIO[0]     | Bid | 62  |       |
| mprj_io[25] | UIO[1]     | Bid |  2  |       |
| mprj_io[26] | UIO[2]     | Bid |  3  |       |
| mprj_io[27] | UIO[3]     | Bid |  4  |       |
| mprj_io[28] | UIO[4]     | Bid |  5  |       |
| mprj_io[29] | UIO[5]     | Bid |  6  |       |
| mprj_io[30] | UIO[6]     | Bid |  7  |       |
| mprj_io[31] | UIO[7]     | Bid |  8  |       |
| mprj_io[32] | SEL_ENA    | In  | 11  |       |
| mprj_io[33] | SPARE      |     | 12  |       |
| mprj_io[34] | SEL_INC    | In  | 13  |       |
| mprj_io[35] | SPARE      |     | 14  |       |
| mprj_io[36] | SEL_RST_N  | In  | 15  |       |
| mprj_io[37] | SPARE      |     | 16  |       |

## ChipTune Operation

The audio portion of the project consists of two rectangular pulse generators. Each module is controlled by four 8-bit registers. Configurable parameters are the frequency, duty cycle, sweep, decay, and note duration.

### ChipTune Pin Assignments
| Signal       | Name     | Signal       | Name     |
| ------------ | ---------| ------------ | ---------|
| clk          | 12 MHz   | ena          | SPARE    |
| rst_n        | RESET_N  | uio_oe[7:0]  | SPARE    |
| ui_in[0]     | SPARE    | uo_out[0]    | BLINK    |
| ui_in[1]     | SPARE    | uo_out[1]    | LINK     |
| ui_in[2]     | RX       | uo_out[2]    | TX       |
| ui_in[3]     | SPARE    | uo_out[3]    | PWM      |
| ui_in[4]     | SPARE    | uo_out[4]    | DAC[0]   |
| ui_in[5]     | SPARE    | uo_out[5]    | DAC[1]   |
| ui_in[6]     | SPARE    | uo_out[6]    | DAC[2]   |
| ui_in[7]     | SPARE    | uo_out[7]    | DAC[3]   |
| uio_in[7:0]  | SPARE    | uio_out[7:0] | SPARE    |

## Design For Test Considerations

Communication with the computer is at {9600,n,8,1}.

## Summary

An external serial port can play music through this TT04 project.
