-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/ROCBUF.vhd,v 1.1 2008/06/19 16:59:26 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Reset On Configuration Buffer
-- /___/   /\     Filename : ROCBUF.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:56 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL ROCBUF -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ROCBUF is
  port(
    O : out std_ulogic;
    I : in  std_ulogic
    );
end ROCBUF;

architecture ROCBUF_V of ROCBUF is
begin
  O <= I;
end ROCBUF_V;


