-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/USR_ACCESS_VIRTEX4.vhd,v 1.1 2008/06/19 16:59:27 vandanad Exp $
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
-- /___/   /\     Filename : USR_ACCESS_VIRTEX4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:05 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL USR_ACCESS_VIRTEX4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity USR_ACCESS_VIRTEX4 is
  port(
    DATA	: out std_logic_vector(31 downto 0);
    DATAVALID	: out std_ulogic
    );

end USR_ACCESS_VIRTEX4;

architecture USR_ACCESS_VIRTEX4_V of USR_ACCESS_VIRTEX4 is

begin
end USR_ACCESS_VIRTEX4_V;
