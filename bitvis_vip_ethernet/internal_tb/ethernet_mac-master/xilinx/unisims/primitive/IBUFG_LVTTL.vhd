-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFG_LVTTL.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Clock Buffer with LVTTL I/O Standard
-- /___/   /\     Filename : IBUFG_LVTTL.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:38 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUFG_LVTTL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFG_LVTTL is
  port(
    O : out STD_ULOGIC;

    I : in STD_ULOGIC
    );
end IBUFG_LVTTL;

architecture IBUFG_LVTTL_V of IBUFG_LVTTL is
begin
  O <= TO_X01(I);
end IBUFG_LVTTL_V;


