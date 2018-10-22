-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/FTCP.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Toggle Flip-Flop with Toggle Enable and Asynchronous Clear and Preset
-- /___/   /\     Filename : FTCP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:26 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL FTCP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FTCP is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CLR : in std_ulogic;
    PRE : in std_ulogic;
    T   : in std_ulogic
    );
end FTCP;

architecture FTCP_V of FTCP is
begin
  VITALBehavior         : process(C, CLR, PRE)
    variable FIRST_TIME : boolean := true ;
    variable Q_zd : std_ulogic := TO_X01(INIT);    
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (CLR = '1') then
      Q   <= '0';
      Q_zd   := '0';
    elsif (PRE = '1') then
      Q   <= '1';
      Q_zd   := '1';
    elsif (C'event and C = '1') then
      if (T = '1') then
        Q_zd := not Q_zd;
        Q <= Q_zd  after 100 ps;
      end if;
    end if;
  end process;
end FTCP_V;


