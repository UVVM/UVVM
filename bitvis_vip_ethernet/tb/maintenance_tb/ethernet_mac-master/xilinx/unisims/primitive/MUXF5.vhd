-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/MUXF5.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-to-1 Lookup Table Multiplexer with General Output
-- /___/   /\     Filename : MUXF5.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    02/10/07 - When input same, output same for any sel value. (CR433761).
--    08/23/07 - Handle S= X case. CR434611 

----- CELL MUXF5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXF5 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    S  : in std_ulogic
    );
end MUXF5;

architecture MUXF5_V of MUXF5 is
begin
  VITALBehavior   : process (I0, I1, S)
  begin
    if ( S = '1') then
      O <= I1;
    else
      O <= I0;      
    end if;    
  end process;
end MUXF5_V;


