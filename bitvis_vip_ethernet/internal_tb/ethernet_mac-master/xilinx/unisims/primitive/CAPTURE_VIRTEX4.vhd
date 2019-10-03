-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/CAPTURE_VIRTEX4.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Register State Capture for Bitstream Readback for VIRTEX4
-- /___/   /\     Filename : CAPTURE_VIRTEX4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL CAPTURE_VIRTEX4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CAPTURE_VIRTEX4 is
  generic(
    ONESHOT : boolean := true
    );  
  port(
    CAP : in std_ulogic;
    CLK : in std_ulogic
    );

end CAPTURE_VIRTEX4;

architecture CAPTURE_VIRTEX4_V of CAPTURE_VIRTEX4 is

begin
end CAPTURE_VIRTEX4_V;
