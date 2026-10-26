-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- bitvis_vip_sbi    : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : SBI VIP BFM and VVC source code
  - tb              : SBI VIP testbenches

IMPORTANT
This is a simplified Verification IP (VIP) for SBI.
The given VIP complies with the basic SBI protocol and thus allows a normal
access towards a SBI interface. This VIP is not a SBI protocol checker.
