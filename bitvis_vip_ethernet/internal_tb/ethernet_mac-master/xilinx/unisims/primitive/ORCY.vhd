-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/ORCY.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  OR with Carry Logic
-- /___/   /\     Filename : ORCY.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:47 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL ORCY -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ORCY is
   port(
      O : out std_ulogic;

      CI : in std_ulogic;
      I  : in std_ulogic
      );
end ORCY;

architecture ORCY_V of ORCY is
begin
      O <= (CI or I);
end ORCY_V;


