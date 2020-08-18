-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/FDDRCPE.vhd,v 1.2 2008/11/04 22:39:33 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Dual Data Rate D Flip-Flop with Asynchronous Clear and Preset and Clock Enable
-- /___/   /\     Filename : FDDRCPE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:23 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL FDDRCPE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDDRCPE is
  generic(
    INIT : bit := '0'
    );

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
end FDDRCPE;

architecture FDDRCPE_V of FDDRCPE is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;

  VITALBehavior         : process(C0, C1, CLR, PRE)

  begin


    if (CLR = '1') then
      q_o   <= '0';
    elsif (PRE = '1' ) then
      q_o   <= '1';
    elsif ( rising_edge(C0) = true) then
      if (CE = '1' ) then
        q_o <= D0 after 100 ps;
      end if;
    elsif (rising_edge(C1) = true ) then
      if (CE = '1') then
        q_o <= D1 after 100 ps;
      end if;
    end if;
  end process VITALBehavior;
end FDDRCPE_V;


