-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BUFGP.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Primary Global Buffer for Driving Clocks or Long Lines
-- /___/   /\     Filename : BUFGP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:16 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFGP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BUFGP is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end BUFGP;

architecture BUFGP_V of BUFGP is
begin
  O <= TO_X01(I);
end BUFGP_V;


