-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IOBUF_LVTTL_F_4.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Bi-Directional Buffer with LVTTL I/O Standard Fast Slew 4 mA Drive
-- /___/   /\     Filename : IOBUF_LVTTL_F_4.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:55 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IOBUF_LVTTL_F_4 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IOBUF_LVTTL_F_4 is
  port(
    O : out std_ulogic;

    IO : inout std_ulogic;

    I : in std_ulogic;
    T : in std_ulogic
    );

end IOBUF_LVTTL_F_4;

architecture IOBUF_LVTTL_F_4_V of IOBUF_LVTTL_F_4 is
begin
  VPKGBehavior     : process (IO, I, T)
  begin
    O  <= TO_X01(IO);
    if ((T = '1') or (T = 'H')) then
      IO <= 'Z';
    elsif ((T = '0') or (T = 'L')) then
      if ((I = '1') or (I = 'H')) then
        IO <= '1';
      elsif ((I = '0') or (I = 'L')) then
        IO <= '0';
      elsif (I = 'U') then
        IO <= 'U';
      else
        IO <= 'X';  
      end if;
    elsif (T = 'U') then
      IO <= 'U';          
    else                                      
      IO <= 'X';  
    end if;
  end process;
end IOBUF_LVTTL_F_4_V;
