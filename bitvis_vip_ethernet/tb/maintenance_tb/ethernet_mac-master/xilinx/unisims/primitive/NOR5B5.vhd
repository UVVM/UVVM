-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/NOR5B5.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  5-input NOR Gate
-- /___/   /\     Filename : NOR5B5.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:09 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL NOR5B5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity NOR5B5 is
  port(
    O : out STD_ULOGIC;

    I0 : in STD_ULOGIC;
    I1 : in STD_ULOGIC;
    I2 : in STD_ULOGIC;
    I3 : in STD_ULOGIC;
    I4 : in STD_ULOGIC
    );
end NOR5B5;

architecture NOR5B5_V of NOR5B5 is
begin
  O <= (NOT ((not I0) or (not I1) OR (not I2) or (not I3) or (not I4)));
end NOR5B5_V;
