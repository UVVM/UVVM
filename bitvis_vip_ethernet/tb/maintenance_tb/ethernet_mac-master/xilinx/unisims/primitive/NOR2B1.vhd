-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/NOR2B1.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-input NOR Gate
-- /___/   /\     Filename : NOR2B1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:07 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL NOR2B1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity NOR2B1 is
  port(
    O : out STD_ULOGIC;

    I0 : in STD_ULOGIC;
    I1 : in STD_ULOGIC
    );
end NOR2B1;

architecture NOR2B1_V of NOR2B1 is
begin
  O <= (NOT ((NOT I0) OR I1));
end NOR2B1_V;



