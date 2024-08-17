-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/AND4B4.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  4-input AND Gate
-- /___/   /\     Filename : AND4B4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:13 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL AND4B4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity AND4B4 is
  port(
    O : out std_ulogic;

    I0     : in std_ulogic;
    I1     : in std_ulogic;
    I2     : in std_ulogic;
    I3     : in std_ulogic
    );
end AND4B4;

architecture AND4B4_V of AND4B4 is
begin
  O <= (not I1) and (not I0) and (not I2) and (not I3);
end AND4B4_V;



