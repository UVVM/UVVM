-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/STARTUP_SPARTAN3.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for SPARTAN3
-- /___/   /\     Filename : STARTUP_SPARTAN3.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:59 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL STARTUP_SPARTAN3 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTUP_SPARTAN3 is
  port(
    CLK : in std_ulogic := 'X';
    GSR : in std_ulogic := 'X';
    GTS : in std_ulogic := 'X'
    );
end STARTUP_SPARTAN3;

architecture STARTUP_SPARTAN3_V of STARTUP_SPARTAN3 is
begin
end STARTUP_SPARTAN3_V;


