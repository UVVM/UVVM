-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/LDCPE.vhd,v 1.2 2008/11/03 21:16:44 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Transparent Data Latch with Asynchronous Clear and Preset and Gate Enable
-- /___/   /\     Filename : LDCPE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:00 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL LDCPE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LDCPE is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    CLR : in std_ulogic;
    D   : in std_ulogic;
    G   : in std_ulogic;
    GE  : in std_ulogic;
    PRE : in std_ulogic
    );
end LDCPE;

architecture LDCPE_V of LDCPE is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;
  VITALBehavior : process(CLR, D, G, GE, PRE)
    begin
    if (CLR = '1') then
      q_o   <= '0';
    elsif (PRE = '1') then
      q_o   <= '1';
    elsif ((GE = '1') and (G = '1'))then
      q_o <= D after 100 ps;        
    end if;
  end process;
end LDCPE_V;


