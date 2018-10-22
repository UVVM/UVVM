-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUFTDS_LVDS_33.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-State Differential Signaling Output Buffer with LVDS_33 I/O Standard
-- /___/   /\     Filename : OBUFTDS_LVDS_33.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:43 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OBUFTDS_LVDS_33 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUFTDS_LVDS_33 is
  port(
    O  : out std_ulogic;
    OB : out std_ulogic;

    I : in std_ulogic;
    T : in std_ulogic
    );
end OBUFTDS_LVDS_33;

architecture OBUFTDS_LVDS_33_V of OBUFTDS_LVDS_33 is
begin
  VITALBehavior    : process (I, T)
  begin

    if ((T = '1') or (T = 'H')) then
      O <= 'Z';
    elsif ((T = '0') or (T = 'L')) then
      if ((I = '1') or (I = 'H')) then
        O <= '1';
      elsif ((I = '0') or (I = 'L')) then
        O <= '0';
      elsif (I = 'U') then
        O <= 'U';
      else
        O <= 'X';  
      end if;
    elsif (T = 'U') then
      O <= 'U';          
    else                                      
      O <= 'X';  
    end if;

    if ((T = '1') or (T = 'H')) then
      OB <= 'Z';
    elsif ((T = '0') or (T = 'L')) then
      if (((not I) = '1') or ((not I) = 'H')) then
        OB <= '1';
      elsif (((not I) = '0') or ((not I) = 'L')) then
        OB <= '0';
      elsif ((not I) = 'U') then
        OB <= 'U';
      else
        OB <= 'X';  
      end if;
    elsif (T = 'U') then
      OB <= 'U';          
    else                                      
      OB <= 'X';  
    end if;            
  end process;
end OBUFTDS_LVDS_33_V;


