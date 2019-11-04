-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFG_CTT.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Clock Buffer with CTT I/O Standard
-- /___/   /\     Filename : IBUFG_CTT.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:34 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUFG_CTT -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFG_CTT is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end IBUFG_CTT;

architecture IBUFG_CTT_V of IBUFG_CTT is
begin
  O <= TO_X01(I);
end IBUFG_CTT_V;

