-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for SPARTAN3A
-- /___/   /\     Filename : STARTUP_SPARTAN3A.vhd
-- \   \  /  \    Timestamp : Tue Jul  5 15:01:35 PDT 2005
--  \___\/\___\
--
-- Revision:
--    07/05/05 - Initial version.

----- CELL STARTUP_SPARTAN3A -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTUP_SPARTAN3A is
  port(
    CLK : in std_ulogic := 'X';
    GSR : in std_ulogic := 'X';
    GTS : in std_ulogic := 'X'
    );
end STARTUP_SPARTAN3A;

architecture STARTUP_SPARTAN3A_V of STARTUP_SPARTAN3A is
begin
end STARTUP_SPARTAN3A_V;
