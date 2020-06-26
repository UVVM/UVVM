-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BUFG.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Buffer
-- /___/   /\     Filename : BUFG.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:15 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFG -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BUFG is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end BUFG;

architecture BUFG_V of BUFG is
begin
  O <= TO_X01(I);
end BUFG_V;


