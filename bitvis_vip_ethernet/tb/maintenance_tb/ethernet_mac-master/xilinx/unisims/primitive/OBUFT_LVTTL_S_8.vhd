-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUFT_LVTTL_S_8.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-State Output Buffer with LVTTL I/O Standard Slow Slew 8 mA Drive
-- /___/   /\     Filename : OBUFT_LVTTL_S_8.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:39 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OBUFT_LVTTL_S_8 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUFT_LVTTL_S_8 is
  port(
    O : out std_ulogic;

    I : in std_ulogic;
    T : in std_ulogic
    );

end OBUFT_LVTTL_S_8;

architecture OBUFT_LVTTL_S_8_V of OBUFT_LVTTL_S_8 is
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
  end process;
end OBUFT_LVTTL_S_8_V;
