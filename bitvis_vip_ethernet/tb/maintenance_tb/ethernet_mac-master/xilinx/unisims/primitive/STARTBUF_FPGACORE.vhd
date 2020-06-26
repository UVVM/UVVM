-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/STARTBUF_FPGACORE.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for FPGACORE
-- /___/   /\     Filename : STARTBUF_FPGACORE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:58 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL STARTBUF_FPGACORE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTBUF_FPGACORE is
    port(
          GSROUT    : out std_ulogic;

          CLKIN     : in std_ulogic := 'X';          
          GSRIN     : in std_ulogic := 'X'
);
end STARTBUF_FPGACORE;

architecture STARTBUF_FPGACORE_V of STARTBUF_FPGACORE is
begin
      GSROUT    <= TO_X01(GSRIN);
end STARTBUF_FPGACORE_V;
