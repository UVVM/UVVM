-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/LUT1_L.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  1-input Look-Up-Table with Local Output
-- /___/   /\     Filename : LUT1_L.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:01 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL LUT1_L -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LUT1_L is
  generic(
    INIT : bit_vector := X"0"
    );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic
    );
end LUT1_L;

architecture LUT1_L_V of LUT1_L is
begin
  VITALBehavior    : process (I0)
    variable INIT_reg : std_logic_vector((INIT'length - 1) downto 0) := To_StdLogicVector(INIT);
  begin
    if (I0 = '0') then
      LO <= INIT_reg(0);
    elsif (I0 = '1') then
      LO <= INIT_reg(1);      
    elsif (INIT_reg(0) = INIT_reg(1)) then
      LO <= INIT_reg(0);
    else
      LO <= 'X';
    end if;    
  end process;
end LUT1_L_V;


