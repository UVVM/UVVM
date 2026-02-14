-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- bitvis_vip_gmii   : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : GMII VIP BFM and VVC source code
  - tb              : GMII VIP testbenches

This VIP can be used as transmitter and receiver.

IMPORTANT
This is a simplified Verification IP (VIP) for GMII.
The given VIP complies with the basic GMII protocol and thus allows a normal
access towards a GMII interface. This VIP is not a GMII protocol checker.
