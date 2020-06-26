-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/AND2B1L.vhd,v 1.4 2009/08/22 00:26:00 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Latch used 2-input AND Gate
-- /___/   /\     Filename : AND2B1L.vhd
-- \   \  /  \    Timestamp : Tue Feb 26 11:11:42 PST 2008
--  \___\/\___\
--
-- Revision:
--    04/01/08 - Initial version.
--    02/26/09 - Change port order (CR510370)
--    04/14/09 - Invert SRI not DI (CR517897)
-- End Revision

----- CELL AND2B1L -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity AND2B1L is
  port(
    O : out std_ulogic;

    DI : in std_ulogic;
    SRI : in std_ulogic
    );
end AND2B1L;

architecture AND2B1L_V of AND2B1L is
begin
  O <= (not SRI) and  DI;
end AND2B1L_V;


