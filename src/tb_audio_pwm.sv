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
  const real CAPACITOR = 0.1;  // capacitance in micofarads
  real cap_voltage = 0.0;
  real cap_current;
  // real t;
  // real t1 = 0.0;
  // real t2;
  int vout;

  initial forever begin : rc_filter
    // @(pwm)
    // t2 = t1;
    // t1 = $realtime;
    // t = t1 - t2;
    // if (t > 10000) t = 0;  // startup glitch
    if (pwm == 1) cap_current = (VDD - cap_voltage) / RESISTOR;
    else cap_current = (VSS - cap_voltage) / RESISTOR;
    cap_voltage = 0.99999 * cap_voltage;  // decay rate
    cap_voltage = cap_voltage + (cap_current / CAPACITOR);  // integration
    if (cap_voltage > VDD) cap_voltage = VDD;
    if (cap_voltage < VSS) cap_voltage = VSS;
    vout = int'(1000.0 * cap_voltage);  // scaled to millivolts
    #100ns;
  end
endmodule
