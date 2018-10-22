-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/XORCY.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  XOR for Carry Logic with General Output
-- /___/   /\     Filename : XORCY.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:01 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL XORCY -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity XORCY is
  port(
    O : out std_ulogic;

    CI : in std_ulogic;
    LI : in std_ulogic
    );
end XORCY;

architecture XORCY_V of XORCY is
begin
    O <= (CI xor LI);
end XORCY_V;


