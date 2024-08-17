-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/INV.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Inverter
-- /___/   /\     Filename : INV.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:42 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL INV -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity INV is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end INV;

architecture INV_V of INV is
begin
  O <= (not TO_X01(I));
end INV_V;


