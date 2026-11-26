-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- p2l2_vip_pwm      : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : PWM VIP BFM and VVC source code
  - tb              : PWM VIP testbenches

This VIP generates, measures and checks single-line pulse-width modulated
(PWM) signals. A VVC instance is either a GENERATOR (drives the line) or an
OBSERVER (measures/checks the line), selected with the GC_ROLE generic.
