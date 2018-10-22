-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/ILD.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Tranparent Input Data Latch
-- /___/   /\     Filename : ILD.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:42 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/25/04 - Removed INIT to match the verilog model.

----- CELL ILD -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ILD is
  port(
    Q : out std_ulogic;

    D : in std_ulogic;
    G : in std_ulogic
    );
end ILD;

architecture ILD_V of ILD is
begin
  VITALBehavior   : process(D, G)
    variable Q_zd : std_ulogic := '0';
  begin
    if (G = '1') then
      Q <= D after 100 ps;
    end if;
  end process;
end ILD_V;
