-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/AND7.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  7-input AND Gate
-- /___/   /\     Filename : AND7.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:14 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL AND7 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity AND7 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic;
    I5 : in std_ulogic;
    I6 : in std_ulogic
    );
end AND7;

architecture AND7_V of AND7 is
begin
  O <= I0 and I1 and I2 and I3 and I4 and I5 and I6;
end AND7_V;



