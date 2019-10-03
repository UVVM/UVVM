-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BSCAN_FPGACORE.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Boundary Scan Logic Control Circuit for FPGACORE
-- /___/   /\     Filename : BSCAN_FPGACORE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:14 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BSCAN_FPGACORE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BSCAN_FPGACORE is
  port(
    CAPTURE : out std_ulogic := 'H';
    DRCK1   : out std_ulogic := 'H';
    DRCK2   : out std_ulogic := 'H';
    RESET   : out std_ulogic := 'H';
    SEL1    : out std_ulogic := 'L';
    SEL2    : out std_ulogic := 'L';
    SHIFT   : out std_ulogic := 'L';
    TDI     : out std_ulogic := 'L';
    UPDATE  : out std_ulogic := 'L';

    TDO1 : in std_ulogic := 'X';
    TDO2 : in std_ulogic := 'X'
    );
end BSCAN_FPGACORE;

architecture BSCAN_FPGACORE_V of BSCAN_FPGACORE is
begin
  CAPTURE <= 'H';
  RESET   <= 'H';
  UPDATE  <= 'L';
  SHIFT   <= 'L';
  DRCK1   <= 'H';
  DRCK2   <= 'H';
  SEL1    <= 'L';
  SEL2    <= 'L';
  TDI     <= 'L';
end BSCAN_FPGACORE_V;


