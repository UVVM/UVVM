-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Internal Configuration Access Port for Spartan3A
-- /___/   /\     Filename : ICAP_SPARTAN3A.vhd
-- \   \  /  \    Timestamp : Wed Jul  6 18:07:07 PDT 2005
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL ICAP_SPARTAN3A -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

entity ICAP_SPARTAN3A is

  port(
    BUSY : out std_ulogic;
    O    : out std_logic_vector(7 downto 0);

    CE    : in std_ulogic;
    CLK   : in std_ulogic;
    I     : in std_logic_vector(7 downto 0);
    WRITE : in std_ulogic
    );

end ICAP_SPARTAN3A;

architecture ICAP_SPARTAN3A_V of ICAP_SPARTAN3A is

begin
end ICAP_SPARTAN3A_V;
