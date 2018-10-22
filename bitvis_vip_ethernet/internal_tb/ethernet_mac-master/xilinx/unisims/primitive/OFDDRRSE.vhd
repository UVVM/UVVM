-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OFDDRRSE.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Dual Data Rate Output D Flip-Flop with Synchronous Reset and Set and Clock Enable
-- /___/   /\     Filename : OFDDRRSE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:44 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OFDDRRSE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity OFDDRRSE is
  port(
    Q : out std_ulogic;

    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D0 : in std_ulogic;
    D1 : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic
    );
end OFDDRRSE;

architecture OFDDRRSE_V of OFDDRRSE is

  signal Q_out : std_ulogic := 'X';

begin
  O1 : OBUF
    port map (
      I => Q_out,
      O => Q
      );

  F0 : FDDRRSE
    generic map (INIT => '0'
                 )

    port map (
      C0 => C0,
      C1 => C1,
      CE => CE,
      R  => R,
      D0 => D0,
      D1 => D1,
      S  => S,
      Q  => Q_out
      );
end OFDDRRSE_V;


