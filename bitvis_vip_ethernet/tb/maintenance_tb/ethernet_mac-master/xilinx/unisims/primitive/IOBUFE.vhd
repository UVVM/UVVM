-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/IOBUFE.vhd,v 1.3 2009/08/22 00:26:00 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Bi-Directional Buffer
-- /___/   /\     Filename : IOBUFE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:59 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    08/06/09 - 529249 - Undo the fix for CR 476136.

----- CELL IOBUFE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IOBUFE is
  port(
    O : out std_ulogic;

    IO : inout std_ulogic;

    E : in std_ulogic;
    I : in std_ulogic
    );
end IOBUFE;

architecture IOBUFE_V of IOBUFE is
begin
  VPKGBehavior     : process (IO, I, E)
    variable IO_zd : std_ulogic;
  begin
    O  <= IO;
    if ((E = '0') or (E = 'L')) then
      IO <= 'Z';
    elsif ((E = '1') or (E = 'H')) then
      if ((I = '1') or (I = 'H')) then
        IO <= '1';
      elsif ((I = '0') or (I = 'L')) then
        IO <= '0';
      elsif (I = 'U') then
        IO <= 'U';
      else
        IO <= 'X';  
      end if;
    elsif (E = 'U') then
      IO <= 'U';          
    else                                      
      IO <= 'X';  
    end if;    
  end process;
end IOBUFE_V;


