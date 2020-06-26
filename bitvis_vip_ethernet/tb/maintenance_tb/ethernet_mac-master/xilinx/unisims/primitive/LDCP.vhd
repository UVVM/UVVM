-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/LDCP.vhd,v 1.2 2008/11/03 21:16:44 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Transparent Data Latch with Asynchronous Clear and Preset
-- /___/   /\     Filename : LDCP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:00 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL LDCP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LDCP is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    CLR : in std_ulogic;
    D   : in std_ulogic;
    G   : in std_ulogic;
    PRE : in std_ulogic
    );
end LDCP;

architecture LDCP_V of LDCP is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;
  VITALBehavior : process(CLR, D, G, PRE)
  begin
    if (CLR = '1') then
      q_o <= '0';
    elsif (PRE = '1') then
      q_o <= '1';
    elsif (G = '1') then
      q_o <= D after 100 ps;        
    end if;
  end process;
end LDCP_V;


