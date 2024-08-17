-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/NAND5B5.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  5-input NAND Gate
-- /___/   /\     Filename : NAND5B5.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:07 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL NAND5B5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity NAND5B5 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic
    );
end NAND5B5;

architecture NAND5B5_V of NAND5B5 is
begin
  O <= not ((not I0) and (not I1) and (not I2) and (not I3) and (not I4));
end NAND5B5_V;


