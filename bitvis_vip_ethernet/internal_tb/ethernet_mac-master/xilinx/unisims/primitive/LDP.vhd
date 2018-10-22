-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/LDP.vhd,v 1.2 2008/11/03 21:16:44 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Transparent Data Latch with Asynchronous Preset
-- /___/   /\     Filename : LDP.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:01 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL LDP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LDP is
  generic(
    INIT : bit := '1'
    );

  port(
    Q : out std_ulogic;

    D   : in std_ulogic;
    G   : in std_ulogic;
    PRE : in std_ulogic
    );
end LDP;

architecture LDP_V of LDP is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;
  VITALBehavior : process(D, G, PRE)
  begin
    if (PRE = '1') then
      q_o <= '1';
    elsif (G = '1') then
      q_o <= D after 100 ps;        
    end if;
  end process;
end LDP_V;


