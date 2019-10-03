-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/KEEPER.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Weak Keeper
-- /___/   /\     Filename : KEEPER.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:59 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/09/05 - Fixed CR#198911

----- CELL KEEPER -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity KEEPER is
  port(
    O : inout std_ulogic := 'W'
    );
end KEEPER;

architecture KEEPER_V of KEEPER is
begin
  process (O)
  begin
    if (O'event) then
      if (O = '1') then
        O <= 'H';
      elsif (O = '0') then
        O <= 'L';
      elsif (O = 'X') then
        O <= 'W';        
      end if;
    end if;
  end process;
end KEEPER_V;


