-----------------------------------------------------------
-- Directory structure                                   -- 
-----------------------------------------------------------

This VIP can be used as master and slave.

- bitvis_vip_i2c    : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : I2C BFM and VVC source code

IMPORTANT
This is a simplified Verification IP (VIP) for I2C.
The given VIP complies with the basic I2C protocol and thus allows a normal 
access towards a I2C interface. This VIP is not a I2C protocol checker.