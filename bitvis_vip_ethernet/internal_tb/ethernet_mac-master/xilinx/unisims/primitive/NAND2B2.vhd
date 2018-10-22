-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/NAND2B2.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-input NAND Gate
-- /___/   /\     Filename : NAND2B2.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:05 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL NAND2B2 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity NAND2B2 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );
end NAND2B2;

architecture NAND2B2_V of NAND2B2 is
begin
  O <= not ((not I0) and (not I1));
end NAND2B2_V;


