-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/CAPTURE_FPGACORE.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Register State Capture for Bitstream Readback for FPGACORE
-- /___/   /\     Filename : CAPTURE_FPGACORE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:16 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/23/05 - Added ONESHOT to all CAPUTURE comps; CR # 212645
--    01/10/06 - made ONESHOT false; CR # 220151
-- End Revision


----- CELL CAPTURE_FPGACORE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CAPTURE_FPGACORE is
  generic(
    ONESHOT : boolean := false
    );
  port(
    CAP : in std_ulogic;
    CLK : in std_ulogic
    );
end CAPTURE_FPGACORE;

architecture CAPTURE_FPGACORE_V of CAPTURE_FPGACORE is
begin
end CAPTURE_FPGACORE_V;


