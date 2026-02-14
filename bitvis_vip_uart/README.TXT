-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- bitvis_vip_uart   : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : UART VIP BFM, VVC and Monitor source code
  - tb              : UART VIP testbenches and demo

This VIP can be used as transmitter and receiver.
This VIP comes with a UART Monitor.

IMPORTANT
This is a simplified Verification IP (VIP) for UART.
The given VIP complies with the basic UART protocol and thus allows a normal
access towards a UART interface. This VIP is not a UART protocol checker.
