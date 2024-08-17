-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/CLK_DIV14SD.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Divider with Start Delay
-- /___/   /\     Filename : CLK_DIV14SD.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:18 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL CLK_DIV14SD -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CLK_DIV14SD is

  port(
    CLKDV : out std_ulogic := '0';
    
    CLKIN : in  std_ulogic := '0'
    );
end CLK_DIV14SD;

architecture CLK_DIV14SD_V of CLK_DIV14SD is

  constant  DIVIDE_BY     : integer := 14;
  constant  DIVIDER_DELAY : integer := 1;
 
  signal CLKDV_i : std_ulogic := '0';

begin

  CLOCK_DIVIDE                : process (CLKIN)
    variable START_WAIT_COUNT : integer := 0;
    variable CLOCK_DIVIDER    : integer := 0;
    variable DELAY_START      : integer := DIVIDER_DELAY;

  begin
    if (CLKIN'event and CLKIN = '1') then

      if (DELAY_START = 1) then
        START_WAIT_COUNT   := START_WAIT_COUNT + 1;
        if (START_WAIT_COUNT = DIVIDE_BY+1) then
          DELAY_START      := 0;
          START_WAIT_COUNT := 0;
        end if;
      end if;

      if (DELAY_START = 0) then
        CLOCK_DIVIDER   := CLOCK_DIVIDER + 1;
        if (CLOCK_DIVIDER = (DIVIDE_BY/2 + 1)) then
          CLOCK_DIVIDER := 1;
          CLKDV_i <= not CLKDV_i;
        end if;
      end if;

    end if;
  end process;

  CLKDV <= CLKDV_i;

end CLK_DIV14SD_V;

