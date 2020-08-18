-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/XNOR3.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-input XNOR Gate
-- /___/   /\     Filename : XNOR3.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:00 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL XNOR3 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity XNOR3 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic
    );
end XNOR3;

architecture XNOR3_V of XNOR3 is
begin
  O <= (not (I0 xor I1 xor I2));
end XNOR3_V;
