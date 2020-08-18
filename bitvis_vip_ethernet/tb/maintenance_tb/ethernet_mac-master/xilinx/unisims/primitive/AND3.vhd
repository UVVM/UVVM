-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/AND3.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-input AND Gate
-- /___/   /\     Filename : AND3.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:12 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL AND3 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity AND3 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic
    );
end AND3;

architecture AND3_V of AND3 is
begin
  O <= I0 and I1 and I2;
end AND3_V;


