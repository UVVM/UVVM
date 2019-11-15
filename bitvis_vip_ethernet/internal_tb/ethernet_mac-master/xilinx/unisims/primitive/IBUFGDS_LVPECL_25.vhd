-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFGDS_LVPECL_25.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Clock Buffer with LVPECL_25 I/O Standard
-- /___/   /\     Filename : IBUFGDS_LVPECL_25.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:42 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUFGDS_LVPECL_25 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFGDS_LVPECL_25 is
  port(
    O : out std_ulogic;

    I  : in std_ulogic;
    IB : in std_ulogic
    );
end IBUFGDS_LVPECL_25;

architecture IBUFGDS_LVPECL_25_V of IBUFGDS_LVPECL_25 is
begin
  VitalBehavior : process (I, IB)
  begin
    if ((I = '1') and (IB = '0')) then
      O <= TO_X01(I);
    elsif ((I = '0') and (IB = '1')) then
      O <= TO_X01(I);
    end if;
  end process;
end IBUFGDS_LVPECL_25_V;


