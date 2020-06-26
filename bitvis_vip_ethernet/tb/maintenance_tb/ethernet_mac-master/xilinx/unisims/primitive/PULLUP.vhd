-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/PULLUP.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Resistor to VCC
-- /___/   /\     Filename : PULLUP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:47 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL PULLUP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity PULLUP is
  port(
    O : out std_ulogic := 'H'
    );
end PULLUP;

architecture PULLUP_V of PULLUP is
begin
  O <= 'H';
end PULLUP_V;


