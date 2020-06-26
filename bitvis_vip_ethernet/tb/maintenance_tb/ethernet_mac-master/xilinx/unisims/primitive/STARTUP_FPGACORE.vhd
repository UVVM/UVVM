-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/STARTUP_FPGACORE.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for FPGACORE
-- /___/   /\     Filename : STARTUP_FPGACORE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:59 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL STARTUP_FPGACORE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTUP_FPGACORE is
  port(
    CLK : in std_ulogic := 'X';
    GSR : in std_ulogic := 'X'
    );
end STARTUP_FPGACORE;

architecture STARTUP_FPGACORE_V of STARTUP_FPGACORE is
begin
end STARTUP_FPGACORE_V;
