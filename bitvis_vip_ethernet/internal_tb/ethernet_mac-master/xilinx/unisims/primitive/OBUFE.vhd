-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/OBUFE.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-State Output Buffer
-- /___/   /\     Filename : OBUFE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:26 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OBUFE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUFE is
  port(
    O : out std_ulogic;
    I : in  std_ulogic;
    E : in  std_ulogic
    );
end OBUFE;

architecture OBUFE_V of OBUFE is
begin

  VITALBehavior   : process (I, E)
  begin
      if (((not E) = '1') or ((not E) = 'H')) then
        O <= 'Z';
      elsif (((not E) = '0') or ((not E) = 'L')) then
        if ((I = '1') or (I = 'H')) then
          O <= '1';
        elsif ((I = '0') or (I = 'L')) then
          O <= '0';
        elsif (I = 'U') then
          O <= 'U';
        else
          O <= 'X';  
        end if;
      elsif ((not E) = 'U') then
        O <= 'U';          
      else                                      
        O <= 'X';  
      end if;    
  end process;
end OBUFE_V;
