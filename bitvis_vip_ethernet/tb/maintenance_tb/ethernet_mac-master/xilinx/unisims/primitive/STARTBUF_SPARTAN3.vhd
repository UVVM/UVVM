-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/STARTBUF_SPARTAN3.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for SPARTAN3
-- /___/   /\     Filename : STARTBUF_SPARTAN3.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:58 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL STARTBUF_SPARTAN3 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTBUF_SPARTAN3 is
    port(
          GSROUT    : out std_ulogic;
          GTSOUT    : out std_ulogic;
          
          CLKIN     : in std_ulogic := 'X';          
          GSRIN     : in std_ulogic := 'X';
          GTSIN     : in std_ulogic := 'X'
);
end STARTBUF_SPARTAN3;

architecture STARTBUF_SPARTAN3_V of STARTBUF_SPARTAN3 is
   begin
      GTSOUT    <= TO_X01(GTSIN);
      GSROUT    <= TO_X01(GSRIN);
 end STARTBUF_SPARTAN3_V;
