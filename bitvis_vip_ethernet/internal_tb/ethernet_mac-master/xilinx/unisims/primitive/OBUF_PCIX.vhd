-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUF_PCIX.vhd,v 1.1 2008/06/19 16:59:25 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Output Buffer with PCIX I/O Standard
-- /___/   /\     Filename : OBUF_PCIX.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:22 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OBUF_PCIX -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUF_PCIX is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end OBUF_PCIX;

architecture OBUF_PCIX_V of OBUF_PCIX is
begin
  O <= TO_X01(I);
end OBUF_PCIX_V;


