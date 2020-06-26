-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/GND.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  GND Connection
-- /___/   /\     Filename : GND.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:26 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL GND -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity GND is
  port(
    G : out std_ulogic := '0'
    );
end GND;

architecture GND_V of GND is
begin

  G <= '0';
end GND_V;


