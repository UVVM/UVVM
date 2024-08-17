-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/CLK_DIV16RSD.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Divider with Synchronous Reset and Start Delay
-- /___/   /\     Filename : CLK_DIV16RSD.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:18 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL CLK_DIV16RSD -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CLK_DIV16RSD is

  port(
    CLKDV : out std_ulogic := '0';

    CDRST : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0'
    );
end CLK_DIV16RSD;

architecture CLK_DIV16RSD_V of CLK_DIV16RSD is

  constant  DIVIDE_BY     : integer := 16;
  constant  DIVIDER_DELAY : integer := 1;

  signal CLKDV_i : std_ulogic := '0';
  signal CDRST_i : std_ulogic := '0';

begin

  CLOCK_DIVIDE                 : process (CLKIN, CDRST)
    variable CLOCK_DIVIDER     : integer := 0;
    variable RESET_WAIT_COUNT  : integer := 0;
    variable START_WAIT_COUNT  : integer := 0;
    variable DELAY_RESET       : boolean := false;
    variable STARTUP           : boolean := true;
    variable DELAY_START       : integer := DIVIDER_DELAY;
    variable NO_BITS_REMAINING : integer := 0;

  begin
    if (CLKIN'event and CLKIN = '0') then
      CDRST_i <= CDRST;
    end if;

    if (CLKIN'event and CLKIN = '1') then

      if (CDRST_i = '1' and CLKDV_i = '1' and STARTUP = true) then
        CLKDV_i <= '0';
        CLOCK_DIVIDER := 0;
        DELAY_START   := 1;
      end if;

      if (CDRST_i = '1' and CLKDV_i = '1' and STARTUP = false) then
        NO_BITS_REMAINING := ((DIVIDE_BY/2 + 1) - CLOCK_DIVIDER);
        DELAY_RESET       := true;
        DELAY_START       := DIVIDER_DELAY;
      end if;

      if (DELAY_RESET = true) then
        RESET_WAIT_COUNT   := RESET_WAIT_COUNT + 1;
        if (RESET_WAIT_COUNT = NO_BITS_REMAINING) then
          CLKDV_i <= '0';
          DELAY_RESET      := false;
          RESET_WAIT_COUNT := 0;
          STARTUP          := true;
          CLOCK_DIVIDER    := 0;
        end if;
      end if;

      if (CDRST_i = '0' and DELAY_START = 1) then
        START_WAIT_COUNT   := START_WAIT_COUNT + 1;
        if (START_WAIT_COUNT = DIVIDE_BY+1) then
          START_WAIT_COUNT := 0;
          DELAY_START      := 0;
        end if;
      end if;

      if (CDRST_i = '0' and DELAY_START = 0 and DELAY_RESET = false) then

        if ((CLOCK_DIVIDER = 0) and (STARTUP = true)) then
          CLKDV_i <= '1';
        end if;

        CLOCK_DIVIDER   := CLOCK_DIVIDER + 1;
        if (CLOCK_DIVIDER = (DIVIDE_BY/2 + 1)) then
          STARTUP       := false;
          CLOCK_DIVIDER := 1;
          CLKDV_i <= not CLKDV_i;
        end if;
      end if;

    end if;
  end process;

  CLKDV <= CLKDV_i;

end CLK_DIV16RSD_V;

