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
| mprj_io[0]  | jtag       | in  | 31  |       |
| mprj_io[1]  | sdo        | out | 32  |       |
| mprj_io[2]  | sdi        | in  | 33  |       |
| mprj_io[3]  | csb        | in  | 34  |       |
| mprj_io[4]  | sck        | in  | 35  |       |
| mprj_io[5]  | user_clk   | out | 36  |       |
| mprj_io[6]  | clk        | in  | 37  |       |
| mprj_io[7]  | rst_n      | in  | 41  |       |
| mprj_io[8]  | ui_in[0]   | in  | 42  |       |
| mprj_io[9]  | ui_in[1]   | in  | 43  |       |
| mprj_io[10] | ui_in[2]   | in  | 44  |       |
| mprj_io[11] | ui_in[3]   | in  | 45  |       |
| mprj_io[12] | ui_in[4]   | in  | 46  |       |
| mprj_io[13] | ui_in[5]   | in  | 48  |       |
| mprj_io[14] | ui_in[6]   | in  | 50  |       |
| mprj_io[15] | ui_in[7]   | in  | 51  |       |
| mprj_io[16] | uo_out[0]  | out | 53  |       |
| mprj_io[17] | uo_out[1]  | out | 54  |       |
| mprj_io[18] | uo_out[2]  | out | 55  |       |
| mprj_io[19] | uo_out[3]  | out | 57  |       |
| mprj_io[20] | uo_out[4]  | out | 58  |       |
| mprj_io[21] | uo_out[5]  | out | 59  |       |
| mprj_io[22] | uo_out[6]  | out | 60  |       |
| mprj_io[23] | uo_out[7]  | out | 61  |       |
| mprj_io[24] | uio[0]     | bid | 62  |       |
| mprj_io[25] | uio[1]     | bid |  2  |       |
| mprj_io[26] | uio[2]     | bid |  3  |       |
| mprj_io[27] | uio[3]     | bid |  4  |       |
| mprj_io[28] | uio[4]     | bid |  5  |       |
| mprj_io[29] | uio[5]     | bid |  6  |       |
| mprj_io[30] | uio[6]     | bid |  7  |       |
| mprj_io[31] | uio[7]     | bid |  8  |       |
| mprj_io[32] | sel_ena    | in  | 11  |       |
| mprj_io[33] | spare      |     | 12  |       |
| mprj_io[34] | sel_inc    | in  | 13  |       |
| mprj_io[35] | spare      |     | 14  |       |
| mprj_io[36] | sel_rst_n  | in  | 15  |       |
| mprj_io[37] | spare      |     | 16  |       |

## ChipTune Operation

The audio portion of the project consists of two rectangular pulse generators. Each module is controlled by four 8-bit registers. Configurable parameters are the frequency, duty cycle, sweep, decay, and note duration.

### ChipTune Pin Assignments
| Signal       | Name     | Signal       | Name     |
| ------------ | ---------| ------------ | ---------|
| clk          | 12 MHz   | ena          | spare    |
| rst_n        | reset_n  | uio_oe[7:0]  | spare    |
| ui_in[0]     | spare    | uo_out[0]    | blink    |
| ui_in[1]     | spare    | uo_out[1]    | link     |
| ui_in[2]     | rx       | uo_out[2]    | tx       |
| ui_in[3]     | spare    | uo_out[3]    | pwm      |
| ui_in[4]     | spare    | uo_out[4]    | dac[0]   |
| ui_in[5]     | spare    | uo_out[5]    | dac[1]   |
| ui_in[6]     | spare    | uo_out[6]    | dac[2]   |
| ui_in[7]     | spare    | uo_out[7]    | dac[3]   |
| uio_in[7:0]  | spare    | uio_out[7:0] | spare    |

## Design For Test Considerations

Communication with the computer is at {9600,n,8,1}.

## Summary

An external serial port can play music through this TT04 project.
