-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IOBUFDS_BLVDS_25.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-State Differential Signaling I/O Buffer with BLVDS_25 I/O Standard
-- /___/   /\     Filename : IOBUFDS_BLVDS_25.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:58 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IOBUFDS_BLVDS_25 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IOBUFDS_BLVDS_25 is

  port(
    O : out std_ulogic;

    IO  : inout std_ulogic;
    IOB : inout std_ulogic;

    I : in std_ulogic;
    T : in std_ulogic
    );
end IOBUFDS_BLVDS_25;

architecture IOBUFDS_BLVDS_25_V of IOBUFDS_BLVDS_25 is
begin

  VPKGBehavior : process (IO, IOB, I, T)
  begin
    if (IO /= IOB ) then
      O <= TO_X01(IO);
    else
      O <= 'X';
    end if;

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

    if ((T = '1') or (T = 'H')) then
      IOB <= 'Z';
    elsif ((T = '0') or (T = 'L')) then
      if (((not I) = '1') or ((not I) = 'H')) then
        IOB <= '1';
      elsif (((not I) = '0') or ((not I) = 'L')) then
        IOB <= '0';
      elsif ((not I) = 'U') then
        IOB <= 'U';
      else
        IOB <= 'X';  
      end if;
    elsif (T = 'U') then
      IOB <= 'U';          
    else                                      
      IOB <= 'X';  
    end if;            
  end process;

end IOBUFDS_BLVDS_25_V;


