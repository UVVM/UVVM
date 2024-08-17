-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/NAND3B1.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-input NAND Gate
-- /___/   /\     Filename : NAND3B1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:05 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL NAND3B1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity NAND3B1 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic
    );
end NAND3B1;

architecture NAND3B1_V of NAND3B1 is
begin
  O <= not ((not I0) and I1 and I2);
end NAND3B1_V;


