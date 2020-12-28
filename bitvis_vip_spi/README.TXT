-----------------------------------------------------------
-- Directory structure                                   -- 
-----------------------------------------------------------

This VIP can be used as master and slave.

- bitvis_vip_spi    : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : SPI VIP BFM and VVC source code

IMPORTANT
This is a simplified Verification IP (VIP) for SPI.
The given VIP complies with the basic SPI protocol and thus allows a normal 
access towards a SPI interface. This VIP is not a SPI protocol checker.