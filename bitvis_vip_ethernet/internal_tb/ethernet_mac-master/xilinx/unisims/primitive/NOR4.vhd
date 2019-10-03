-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/NOR4.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  4-input NOR Gate
-- /___/   /\     Filename : NOR4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:07 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL NOR4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity NOR4 is
   port(
      O                              :	out   STD_ULOGIC;
      
      I0                             :	in    STD_ULOGIC;
      I1                             :	in    STD_ULOGIC;
      I2                             :	in    STD_ULOGIC;
      I3                             :	in    STD_ULOGIC
      );
end NOR4;

architecture NOR4_V of NOR4 is
begin
      O <= (NOT (I0 or I1 OR I2 or I3));
end NOR4_V;
