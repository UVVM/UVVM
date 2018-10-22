-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/BUFGTS.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global 3-State Input Buffer
-- /___/   /\     Filename : BUFGTS.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:16 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFGTS -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BUFGTS is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end BUFGTS;

architecture BUFGTS_V of BUFGTS is
begin
  O <= TO_X01(I);
end BUFGTS_V;


