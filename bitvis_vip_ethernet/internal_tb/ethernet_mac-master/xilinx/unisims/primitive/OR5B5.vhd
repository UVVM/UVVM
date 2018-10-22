-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OR5B5.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  5-input OR Gate
-- /___/   /\     Filename : OR5B5.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:46 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OR5B5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OR5B5 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic
    );
end OR5B5;

architecture OR5B5_V of OR5B5 is
begin
  O <= ((not I0) or (not I1) or (not I2) or (not I3) or (not I4));
end OR5B5_V;


