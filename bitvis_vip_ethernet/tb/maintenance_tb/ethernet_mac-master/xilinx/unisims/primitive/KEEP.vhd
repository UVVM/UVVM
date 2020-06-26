-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/KEEP.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  
-- /___/   /\     Filename : KEEP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:59 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL KEEP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity KEEP is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end KEEP;

architecture KEEP_V of KEEP is
begin
  VITALBehavior : process (I)
  begin
    O <= TO_X01(I);
  end process;
end KEEP_V;


