-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Register State Capture for Bitstream Readback for SPARTAN3
-- /___/   /\     Filename : CAPTURE_SPARTAN3A.vhd
-- \   \  /  \    Timestamp : Tue Jul  5 15:01:35 PDT 2005
--  \___\/\___\
--
-- Revision:
--    07/05/05 - Initial version.

----- CELL CAPTURE_SPARTAN3A -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CAPTURE_SPARTAN3A is
  generic(
    ONESHOT : boolean := true
    );  
  port(
    CAP : in std_ulogic;
    CLK : in std_ulogic
    );
end CAPTURE_SPARTAN3A;

architecture CAPTURE_SPARTAN3A_V of CAPTURE_SPARTAN3A is
begin
end CAPTURE_SPARTAN3A_V;
