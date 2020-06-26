-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OR4B1.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  4-input OR Gate
-- /___/   /\     Filename : OR4B1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:45 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OR4B1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OR4B1 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic
    );
end OR4B1;

architecture OR4B1_V of OR4B1 is
begin
  O <= ((not I0) or I1 or I2 or I3);
end OR4B1_V;
