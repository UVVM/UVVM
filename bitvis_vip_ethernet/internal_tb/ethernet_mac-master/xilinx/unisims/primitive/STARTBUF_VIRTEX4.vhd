-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/STARTBUF_VIRTEX4.vhd,v 1.1 2008/06/19 16:59:27 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for VIRTEX4
-- /___/   /\     Filename : STARTBUF_VIRTEX4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:05 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL STARTBUF_VIRTEX4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTBUF_VIRTEX4 is
  port(
    EOSOUT	: out std_ulogic;
    GSROUT	: out std_ulogic;
    GTSOUT	: out std_ulogic;
    CLKIN	: in std_ulogic := 'X';          
    GSRIN	: in std_ulogic := 'X';
    GTSIN	: in std_ulogic := 'X';
    USRCCLKOIN	: in std_ulogic := 'X';
    USRCCLKTSIN	: in std_ulogic := 'X';
    USRDONEOIN	: in std_ulogic := 'X';
    USRDONETSIN	: in std_ulogic := 'X'

);

end STARTBUF_VIRTEX4;

architecture STARTBUF_VIRTEX4_V of STARTBUF_VIRTEX4 is

begin

   
   GSROUT <= GSRIN;
   GTSOUT <= GTSIN;
 

end STARTBUF_VIRTEX4_V;
