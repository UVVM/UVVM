-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/CLK_DIV10.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Divider
-- /___/   /\     Filename : CLK_DIV10.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:17 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL CLK_DIV10 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CLK_DIV10 is
  port(
    CLKDV : out std_ulogic := '0';
    
    CLKIN : in std_ulogic := '0'
    );

end CLK_DIV10;

architecture CLK_DIV10_V of CLK_DIV10 is

  constant  DIVIDE_BY : integer := 10;

  signal CLKDV_i : std_ulogic := '0';

begin

  CLOCK_DIVIDE : process (CLKIN)
    variable CLOCK_DIVIDER : integer := 0;

  begin
    if (CLKIN'event and CLKIN = '1') then
      CLOCK_DIVIDER := CLOCK_DIVIDER + 1;
      if (CLOCK_DIVIDER = (DIVIDE_BY/2 + 1)) then
        CLOCK_DIVIDER := 1;
        CLKDV_i <= not CLKDV_i;
      end if;

    end if;
  end process;

  CLKDV <= CLKDV_i;

end CLK_DIV10_V;


