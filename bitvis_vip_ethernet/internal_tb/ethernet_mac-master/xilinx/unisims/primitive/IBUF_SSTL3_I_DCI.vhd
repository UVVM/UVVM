-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUF_SSTL3_I_DCI.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Buffer with SSTL3_I_DCI I/O Standard
-- /___/   /\     Filename : IBUF_SSTL3_I_DCI.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:32 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUF_SSTL3_I_DCI -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUF_SSTL3_I_DCI is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end IBUF_SSTL3_I_DCI;

architecture IBUF_SSTL3_I_DCI_V of IBUF_SSTL3_I_DCI is
begin
  O <= TO_X01(I);
end IBUF_SSTL3_I_DCI_V;
