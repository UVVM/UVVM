-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Internal Configuration Access Port for VIRTEX5
-- /___/   /\     Filename : ICAP_VIRTEX5.vhd
-- \   \  /  \    Timestamp : Thu Jun  03 10:57:04 PDT 2005
--  \___\/\___\
--
-- Revision:
--    06/03/05 - Initial version.

----- CELL ICAP_VIRTEX5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

entity ICAP_VIRTEX5 is
  generic(
    ICAP_WIDTH : string := "X8"
    );


  port(
    BUSY : out std_ulogic;
    O    : out std_logic_vector(31 downto 0);

    CE    : in std_ulogic;
    CLK   : in std_ulogic;
    I     : in std_logic_vector(31 downto 0);
    WRITE : in std_ulogic
    );

end ICAP_VIRTEX5;

architecture ICAP_VIRTEX5_V of ICAP_VIRTEX5 is

begin
--####################################################################
--#####                        Initialization                      ###
--####################################################################
  prcs_init:process
  begin
     if((ICAP_WIDTH /="X8") and (ICAP_WIDTH /="X16") and (ICAP_WIDTH /="X32")) then
        assert false
        report "Attribute Syntax Error: The allowed values for ICAP_WIDTH are X8, X16 or X32."
        severity Failure;
     end if;
    
     wait;
  end process prcs_init;
end ICAP_VIRTEX5_V;
