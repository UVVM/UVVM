-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/ICAP_VIRTEX4.vhd,v 1.1 2008/06/19 16:59:27 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Internal Configuration Access Port for Virtex4
-- /___/   /\     Filename : ICAP_VIRTEX4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:04 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL ICAP_VIRTEX4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

entity ICAP_VIRTEX4 is
  generic(
    ICAP_WIDTH : string := "X8"
    );


  port(
    BUSY : out std_ulogic;
    O    : out std_logic_vector(31 downto 0);

    CE    : in std_ulogic;
    CLK   : in std_ulogic;
    I     : in std_logic_vector(31 downto 0);
    WRITE : in std_ulogic
    );

end ICAP_VIRTEX4;

architecture ICAP_VIRTEX4_V of ICAP_VIRTEX4 is

begin
end ICAP_VIRTEX4_V;
