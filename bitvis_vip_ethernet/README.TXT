-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- bitvis_vip_ethernet       : A VIP that uses UVVM
  - doc               	    : Quick Reference for VVC
  - script            	    : Compile scripts
  - src               	    : Ethernet VIP HVVC source code
  - tb                      : Ethernet VIP testbenches and demo

This VIP can be used as transmitter and receiver.

IMPORTANT
This is a hierarchical VVC (HVVC) and is a simplified Verification IP (VIP) for Ethernet.
The given VIP complies with the basic Ethernet protocol and thus allows a normal
access towards a Ethernet interface. This VIP is not a Ethernet protocol checker.
