-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IFDDRCPE.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Dual Data Rate Input D Flip-Flop with Asynchronous Clear and Preset and Clock Enable
-- /___/   /\     Filename : IFDDRCPE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:42 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IFDDRCPE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity IFDDRCPE is
  port(
    Q0 : out std_ulogic;
    Q1 : out std_ulogic;

    C0  : in std_ulogic;
    C1  : in std_ulogic;
    CE  : in std_ulogic;
    CLR : in std_ulogic;
    D   : in std_ulogic;
    PRE : in std_ulogic
    );
end IFDDRCPE;

architecture IFDDRCPE_V of IFDDRCPE is
  signal D_in : std_ulogic := 'X';
begin

  I1 : IBUF
    port map (
      I => D,
      O => D_in
      );

  F0 : FDCPE
    generic map (
      INIT => '0' )
    port map (
      C    => C0,
      CE   => CE,
      CLR  => CLR,
      D    => D_in,
      PRE  => PRE,
      Q    => Q0
      );

  F1 : FDCPE
    generic map (
      INIT => '0' )
    port map (
      C    => C1,
      CE   => CE,
      CLR  => CLR,
      D    => D_in,
      PRE  => PRE,
      Q    => Q1
      );
end IFDDRCPE_V;


