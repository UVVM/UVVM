-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUF_GTL_DCI.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Buffer with GTL_DCI I/O Standard
-- /___/   /\     Filename : IBUF_GTL_DCI.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:26 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL IBUF_GTL_DCI -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUF_GTL_DCI is
   port(
      O : out std_ulogic;

      I : in std_ulogic
      );
end IBUF_GTL_DCI;

architecture IBUF_GTL_DCI_V of IBUF_GTL_DCI is
begin
  O <= TO_X01(I);
end IBUF_GTL_DCI_V;


