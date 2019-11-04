-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/BUFIO.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Local Clock Buffer for I/O
-- /___/   /\     Filename : BUFIO.v
-- \   \  /  \    Timestamp : Fri Mar 26 08:17:58 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFIO -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BUFIO is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );

end BUFIO;

architecture BUFIO_V of BUFIO is
begin
  O <= I after 0 ps;
end BUFIO_V;
