-----------------------------------------------------------
-- Directory structure                                   -- 
-----------------------------------------------------------

This VIP can be used as master and slave.

- bitvis_vip_axistream      : A VIP that uses UVVM
  - doc               	    : Quick Reference for BFM and VVC
  - script            	    : Compile scripts
  - src               	    : AXI Stream VIP BFM and VVC source code

IMPORTANT
This is a simplified Verification IP (VIP) for AXI Stream.
The given VIP complies with the basic AXI Stream protocol and thus allows a normal 
access towards a AXI Stream interface. This VIP is not a AXI Stream protocol checker.
