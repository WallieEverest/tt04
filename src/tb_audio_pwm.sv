// Title:   Audio PWM testbench
// File:    tb_audio_pwm.sv
// Author:  Wallace Everest
// Date:    11-JUL-2023
// URL:     https://github.com/wallieeverest/tt04
// License: Apache 2.0
//
// Description:

`default_nettype none

wire pwm;
int vout;

module tb_audio_pwm ();
  reg clk = 0;
  reg reset = 1;
  reg [11:0] data = 0;

  audio_pwm audio_pwm_dut (
    .clk  (clk),
    .reset(reset),
    .data (data),
    .pwm  (pwm)
  );

  initial forever #42.7ns clk = ~clk;  // 12 MHz clock
  initial #10ns reset = 0;

endmodule

program automatic test;
  initial begin : rc_filter
    const real VDD       = 3.3;
    const real VSS       = -3.3;
    const real RESISTOR  = 1_000.0;  // resistance in ohms
    const real CAPACITOR = 1.0;  // capacitance in nanofarads
    real cap_voltage;
    real cap_current;

    #5us;  // delay while device initializes
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
    //wait;
  end

  final
    $display("Test done.");
endprogram
