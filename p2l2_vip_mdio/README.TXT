-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- p2l2_vip_mdio     : A VIP that uses UVVM
  - doc             : Quick Reference for BFM and VVC
  - script          : Compile scripts
  - src             : MDIO VIP BFM and VVC source code
  - tb              : MDIO VIP testbenches

This VIP supports IEEE 802.3 Clause 22 and Clause 45 MDIO frames and can be
used as STA (station management entity) and PHY.

IMPORTANT
Besides generating and receiving frames, the VIP checks the MDIO protocol and
timing of the other side of the bus (protocol errors, bus timing, unwanted
activity). See the Quick Reference under 'doc' for what is checked and its
limitations.
The timing checks only see the timing the DUT has in simulation. In a zero-delay
RTL simulation, the DUT (or a wrapper in the testbench) must model the relevant
MDC/MDIO timing, e.g. output delays, if it is to be checked.
