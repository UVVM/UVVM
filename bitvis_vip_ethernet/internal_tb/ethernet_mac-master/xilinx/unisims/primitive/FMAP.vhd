-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/FMAP.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  F Function Generator Partitioning Control Symbol
-- /___/   /\     Filename : FMAP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:25 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL FMAP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FMAP is
  port(
    O : in std_ulogic := 'X';

    I1 : in std_ulogic := 'X';
    I2 : in std_ulogic := 'X';
    I3 : in std_ulogic := 'X';
    I4 : in std_ulogic := 'X'
    );
end FMAP;

architecture FMAP_V of FMAP is
begin
end FMAP_V;


