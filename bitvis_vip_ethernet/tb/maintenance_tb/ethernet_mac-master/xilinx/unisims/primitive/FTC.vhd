-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/FTC.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Toggle Flip-Flop with Toggle Enable and Asynchronous Clear
-- /___/   /\     Filename : FTC.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:26 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/23/05 -- Removed INIT to match verilog
-- End Revision

----- CELL FTC -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FTC is
  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CLR : in std_ulogic;
    T   : in std_ulogic
    );
end FTC;

architecture FTC_V of FTC is
begin
  VITALBehavior         : process(C, CLR)
    variable FIRST_TIME : boolean := true ;
    variable Q_zd : std_ulogic := '0';
  begin

    if (FIRST_TIME = true) then
      Q <= '0';
      FIRST_TIME := false;
    end if;

    if (CLR = '1') then
      Q   <= '0';
    elsif (rising_edge(C)) then
      if (T = '1') then
        Q_zd := not Q_zd;
        Q <= Q_zd after 100 ps;        
      end if;

    end if;
  end process;
end FTC_V;


