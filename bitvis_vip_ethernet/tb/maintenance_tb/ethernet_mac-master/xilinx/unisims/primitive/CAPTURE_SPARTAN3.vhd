-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/CAPTURE_SPARTAN3.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
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
-- /___/   /\     Filename : CAPTURE_SPARTAN3.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:17 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/23/05 - Added ONESHOT to all CAPUTURE comps; CR # 212645
--    01/10/06 - made ONESHOT false; CR # 220151
-- End Revision

----- CELL CAPTURE_SPARTAN3 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CAPTURE_SPARTAN3 is
  generic(
    ONESHOT : boolean := false
    );  
  port(
    CAP : in std_ulogic;
    CLK : in std_ulogic
    );
end CAPTURE_SPARTAN3;

architecture CAPTURE_SPARTAN3_V of CAPTURE_SPARTAN3 is
begin
end CAPTURE_SPARTAN3_V;


