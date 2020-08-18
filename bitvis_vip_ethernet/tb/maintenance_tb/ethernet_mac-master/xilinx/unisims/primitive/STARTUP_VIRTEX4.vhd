-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/STARTUP_VIRTEX4.vhd,v 1.1 2008/06/19 16:59:27 vandanad Exp $
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
-- /___/   /\     Filename : STARTUP_VIRTEX4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:05 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL STARTUP_VIRTEX4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTUP_VIRTEX4 is
  port(
    EOS		: out std_ulogic;

    CLK		: in std_ulogic := 'X';
    GSR		: in std_ulogic := 'X';
    GTS		: in std_ulogic := 'X';
    USRCCLKO	: in std_ulogic := 'X';
    USRCCLKTS	: in std_ulogic := 'X';
    USRDONEO	: in std_ulogic := 'X';
    USRDONETS	: in std_ulogic := 'X'
    );

end STARTUP_VIRTEX4;

architecture STARTUP_VIRTEX4_V of STARTUP_VIRTEX4 is

begin
end STARTUP_VIRTEX4_V;
