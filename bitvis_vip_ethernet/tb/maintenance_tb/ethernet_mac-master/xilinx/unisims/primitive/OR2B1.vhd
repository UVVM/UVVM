-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OR2B1.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-input OR Gate
-- /___/   /\     Filename : OR2B1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:44 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OR2B1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OR2B1 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );
end OR2B1;

architecture OR2B1_V of OR2B1 is
begin
  O <= ((not I0) or I1);
end OR2B1_V;
