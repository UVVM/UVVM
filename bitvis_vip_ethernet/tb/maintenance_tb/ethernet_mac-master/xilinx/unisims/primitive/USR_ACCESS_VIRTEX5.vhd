-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  
-- /___/   /\     Filename : USR_ACCESS_VIRTEX5.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:05 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL USR_ACCESS_VIRTEX5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity USR_ACCESS_VIRTEX5 is
  port(
    CFGCLK      : out std_ulogic;
    DATA	: out std_logic_vector(31 downto 0);
    DATAVALID	: out std_ulogic
    );

end USR_ACCESS_VIRTEX5;

architecture USR_ACCESS_VIRTEX5_V of USR_ACCESS_VIRTEX5 is

begin
end USR_ACCESS_VIRTEX5_V;
