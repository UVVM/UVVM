-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- external_vip_apb  : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : APB BFM and VVC source code
  - tb              : APB VIP testbenches

IMPORTANT
This is a simplified Verification IP (VIP) for APB.
The given VIP complies with the basic APB protocol and thus allows a normal
access towards a APB interface. This VIP is not a APB protocol checker.
