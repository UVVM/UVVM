-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex5fxt/SMODEL/JTAGPPC440.vhd,v 1.2 2010/06/23 21:46:17 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                 JTAG Primitive for Virtex5 Power PC 
-- /___/   /\     Filename : JTAGPPC440.vhd
-- \   \  /  \    Timestamp : hu Aug 18 13:47:04 PDT 2005
--  \___\/\___\
--
-- Revision:
--    08/19/05 - Initial version.

----- CELL JTAGPPC440 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity JTAGPPC440 is
  port (
        TCK : out std_ulogic;
        TDIPPC : out std_ulogic;
        TMS : out std_ulogic;

        TDOPPC : in std_ulogic
        );
end JTAGPPC440;

architecture JTAGPPC440_v of JTAGPPC440 is
  begin
    TCK <= '1';
    TDIPPC <= '1';
    TMS <= '1';    
end JTAGPPC440_v;
