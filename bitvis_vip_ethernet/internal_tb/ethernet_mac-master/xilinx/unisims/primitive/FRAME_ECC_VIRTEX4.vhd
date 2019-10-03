-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/FRAME_ECC_VIRTEX4.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  
-- /___/   /\     Filename : FRAME_ECC_VIRTEX4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL FRAME_ECC_VIRTEX4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FRAME_ECC_VIRTEX4 is
  port(
    ERROR		: out std_ulogic;
    SYNDROME		: out std_logic_vector(11 downto 0);
    SYNDROMEVALID	: out std_ulogic
    );

end FRAME_ECC_VIRTEX4;

architecture FRAME_ECC_VIRTEX4_V of FRAME_ECC_VIRTEX4 is

begin
end FRAME_ECC_VIRTEX4_V;
