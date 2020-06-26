-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/OR2L.vhd,v 1.2 2009/02/19 20:40:06 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Latch used 2-input OR Gate
-- /___/   /\     Filename : OR2L.vhd
-- \   \  /  \    Timestamp : Tue Feb 26 11:11:42 PST 2008
--  \___\/\___\
--
-- Revision:
--    02/26/08 - Initial version.
--    04/01/08 - Change input pins name.
--    02/19/09 - Order port name. (CR509139)
-- End Revision

----- CELL OR2L -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OR2L is
  port(
    O : out std_ulogic;

    DI : in std_ulogic;
    SRI : in std_ulogic
    );
end OR2L;

architecture OR2L_V of OR2L is
begin
  O <= SRI or DI;
end OR2L_V;
