-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BUFGCE_1.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Mux Buffer with Clock Enable and Output State 1
-- /___/   /\     Filename : BUFGCE_1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:15 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL BUFGCE_1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity BUFGCE_1 is
	port(
	O : out STD_ULOGIC;
        
	CE: in STD_ULOGIC;
	I : in STD_ULOGIC
        );
end BUFGCE_1;
architecture BUFGCE_1_V of BUFGCE_1 is

    signal NCE : STD_ULOGIC := 'X';
    signal VCC : STD_ULOGIC := '1';

begin
    B1 : BUFGMUX_1 
	port map (
	I0 => I,
	I1 => VCC,
	O => O,
	s => NCE);

    I1 : INV 
	port map (
	I => CE,
	O => NCE);

end BUFGCE_1_V;


