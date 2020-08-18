-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFDS_BLVDS_25.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Buffer with BLVDS_25 I/O Standard
-- /___/   /\     Filename : IBUFDS_BLVDS_25.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:32 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUFDS_BLVDS_25 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFDS_BLVDS_25 is
  port(
    O : out std_ulogic;

    I  : in std_ulogic;
    IB : in std_ulogic
    );
end IBUFDS_BLVDS_25;

architecture IBUFDS_BLVDS_25_V of IBUFDS_BLVDS_25 is
begin
  VitalBehavior : process (I, IB)
  begin
    if ((I = '1') and (IB = '0')) then
      O <= TO_X01(I);
    elsif ((I = '0') and (IB = '1')) then
      O <= TO_X01(I);
    end if;
  end process;
end IBUFDS_BLVDS_25_V;


