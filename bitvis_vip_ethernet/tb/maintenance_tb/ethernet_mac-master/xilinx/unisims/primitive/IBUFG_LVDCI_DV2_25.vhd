-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFG_LVDCI_DV2_25.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Clock Buffer with LVDCI_DV2_25 I/O Standard
-- /___/   /\     Filename : IBUFG_LVDCI_DV2_25.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:38 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUFG_LVDCI_DV2_25 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFG_LVDCI_DV2_25 is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end IBUFG_LVDCI_DV2_25;

architecture IBUFG_LVDCI_DV2_25_V of IBUFG_LVDCI_DV2_25 is
begin
  O <= TO_X01(I);
end IBUFG_LVDCI_DV2_25_V;


