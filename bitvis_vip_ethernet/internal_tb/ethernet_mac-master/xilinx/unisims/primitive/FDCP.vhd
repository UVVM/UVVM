-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/FDCP.vhd,v 1.2 2008/11/04 22:39:33 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  D Flip-Flop with Asynchronous Clear and Preset
-- /___/   /\     Filename : FDCP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:22 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL FDCP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDCP is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CLR : in std_ulogic;
    D   : in std_ulogic;
    PRE : in std_ulogic
    );
end FDCP;

architecture FDCP_V of FDCP is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;
  VITALBehavior         : process(C, CLR, PRE)

  begin


    if (CLR = '1') then
      q_o <= '0';
    elsif (PRE = '1') then
      q_o <= '1';
    elsif (rising_edge(C)) then
      q_o <= D after 100 ps;
    end if;
  end process;
end FDCP_V;


