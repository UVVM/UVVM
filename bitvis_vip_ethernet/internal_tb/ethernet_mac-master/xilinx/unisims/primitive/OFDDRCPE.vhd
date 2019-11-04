-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OFDDRCPE.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Dual Data Rate Output D Flip-Flop with Asynchronous Clear and Preset and Clock Enable
-- /___/   /\     Filename : OFDDRCPE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:44 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OFDDRCPE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity OFDDRCPE is
  port(
    Q : out std_ulogic;

    C0  : in std_ulogic;
    C1  : in std_ulogic;
    CE  : in std_ulogic;
    CLR : in std_ulogic;
    D0  : in std_ulogic;
    D1  : in std_ulogic;
    PRE : in std_ulogic
    );
end OFDDRCPE;

architecture OFDDRCPE_V of OFDDRCPE is
   SIGNAL Q_out : STD_ULOGIC := 'X';
   
begin
  F0 : FDDRCPE
    generic map (
      INIT => '0' )
    port map (
      C0   => C0,
      C1   => C1,
      CE   => CE,
      CLR  => CLR,
      D0   => D0,
      D1   => D1,
      PRE  => PRE,
      Q    => Q_out
      );

  O1 : OBUF
    port map (
      I => Q_out,
      O => Q
      );
end OFDDRCPE_V;


