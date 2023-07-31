// Title:   Audio PWM testbench
// File:    tb_audio_pwm.sv
// Author:  Wallace Everest
// Date:    11-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

`default_nettype none
`timescale 1ns/100ps

module tb_audio_pwm (
  input wire pwm
);
  const real VDD       = 3.3;
  const real VSS       = 0;
  const real RESISTOR  = 1_000.0;  // resistance in ohms
  const real CAPACITOR = 100.0;  // capacitance in nanofarads
  real cap_voltage;
  real cap_current;
  int vout;

  initial forever begin : rc_filter

    //#1us;  // delay while device initializes
    cap_current = 0.0;
    if (pwm == 1) begin
      if (cap_voltage < VDD)
        cap_current = (VDD - cap_voltage) / RESISTOR;
    end else begin
      if (cap_voltage > VSS)
        cap_current = (VSS - cap_voltage) / RESISTOR;
    end
    cap_voltage = 0.99999 * cap_voltage;  // high pass (DC block)
    cap_voltage = cap_voltage + (cap_current / CAPACITOR);  // integration adjusted for ns/nF
    vout = int'(1000.0 * cap_voltage);  // scaled to millivolts
    #1ns;
  end
endmodule
