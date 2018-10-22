-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/XORCY_D.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  XOR for Carry Logic with Dual Output
-- /___/   /\     Filename : XORCY_D.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:01 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL XORCY_D -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity XORCY_D is
  port(
    LO : out std_ulogic;
    O  : out std_ulogic;

    CI : in std_ulogic;
    LI : in std_ulogic
    );
end XORCY_D;

architecture XORCY_D_V of XORCY_D is
begin
  O     <= (CI xor LI);
  LO <= (CI xor LI);
end XORCY_D_V;


