-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BUFE.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Internal 3-State Buffer with Active High Enable
-- /___/   /\     Filename : BUFE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:15 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BUFE is
  port(
    O : out std_ulogic;

    E : in std_ulogic;
    I : in std_ulogic
    );
end BUFE;

architecture BUFE_V of BUFE is
begin
  VITALBehavior : process(E, I)
    begin
      if ((E = '0') or (E = 'L')) then
        O <= 'Z';
      elsif ((E = '1') or (E = 'H')) then
        if ((I = '1') or (I = 'H')) then
          O <= '1';
        elsif ((I = '0') or (I = 'L')) then
          O <= '0';
        elsif (I = 'U') then
          O <= 'U';
        else
          O <= 'X';  
        end if;
      elsif (E = 'U') then
        O <= 'U';          
      else                                      
        O <= 'X';  
      end if;
  end process;  
end BUFE_V;


