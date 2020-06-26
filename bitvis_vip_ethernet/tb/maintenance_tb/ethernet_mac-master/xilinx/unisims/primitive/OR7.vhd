-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/OR7.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  7-input OR Gate
-- /___/   /\     Filename : OR7.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:46 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OR7 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OR7 is
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
end OR7;

architecture OR7_V of OR7 is
begin
  O <= (I0 or I1 or I2 or I3 or I4 or I5 or I6);
end OR7_V;
