-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/XOR2.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-input XOR Gate
-- /___/   /\     Filename : XOR2.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:00 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL XOR2 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity XOR2 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );
end XOR2;

architecture XOR2_V of XOR2 is
begin
  O <= (I0 xor I1);
end XOR2_V;
