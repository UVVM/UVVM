-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BUFGCE.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Mux Buffer with Clock Enable and Output State 0
-- /___/   /\     Filename : BUFGCE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:15 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFGCE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity BUFGCE is
     port(
	 O : out STD_ULOGIC;
         
	 CE: in STD_ULOGIC;
	 I : in STD_ULOGIC
         );
end BUFGCE;

architecture BUFGCE_V of BUFGCE is

    signal NCE : STD_ULOGIC := 'X';
    signal GND : STD_ULOGIC := '0';

begin
    B1 : BUFGMUX 
	port map (
	I0 => I,
	I1 => GND,
	O =>O,
	s =>NCE);

    I1 : INV
	port map (
	I => CE,
	O => NCE);

end BUFGCE_V;


