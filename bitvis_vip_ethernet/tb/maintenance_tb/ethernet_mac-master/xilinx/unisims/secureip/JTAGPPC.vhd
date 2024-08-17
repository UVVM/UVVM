-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/SMODEL/JTAGPPC.vhd,v 1.2 2010/06/23 21:46:17 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  JTAG Primitive for Power PC
-- /___/   /\     Filename : JTAGPPC.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:12 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL JTAGPPC -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity JTAGPPC is
  port (
        TCK : out std_ulogic;
        TDIPPC : out std_ulogic;
        TMS : out std_ulogic;

        TDOPPC : in std_ulogic;
        TDOTSPPC : in std_ulogic
        );
end JTAGPPC;

architecture JTAGPPC_v of JTAGPPC is
  begin
    TCK <= '1';
    TDIPPC <= '1';
    TMS <= '1';    
end JTAGPPC_v;
