-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BUFGDLL.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Clock Delay Locked Loop Buffer
-- /___/   /\     Filename : BUFGDLL.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:16 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFGDLL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity BUFGDLL is
  generic(
    DUTY_CYCLE_CORRECTION :     boolean := true
    );
  port(
    O                     : out std_ulogic;

    I : in std_ulogic
    );
end BUFGDLL;

architecture BUFGDLL_V of BUFGDLL is

  signal clkin_int, clkout                           : std_ulogic;
  signal clk0_out, clk180_out, clk270_out, clk90_out : std_ulogic;
  signal clk2x_out, clkdv_out, locked_out            : std_ulogic := '0';
  signal gnd                                         : std_ulogic := '0';
begin
  IBUFG_inst                                         : IBUFG
    port map (
      O => clkin_int,

      I => I
      );

  CLKDLL_inst : CLKDLL
    generic map (
      DUTY_CYCLE_CORRECTION => DUTY_CYCLE_CORRECTION
      )

    port map(
      CLK0   => clk0_out,
      CLK180 => clk180_out,
      CLK270 => clk270_out,
      CLK2X  => clk2x_out,
      CLK90  => clk90_out,
      CLKDV  => clkdv_out,
      LOCKED => locked_out,

      CLKFB => clkout,
      CLKIN => clkin_int,
      RST   => gnd
      );

  BUFG_inst : BUFG
    port map (
      O => clkout,

      I => clk0_out
      );

  O <= clkout;
end BUFGDLL_V;
