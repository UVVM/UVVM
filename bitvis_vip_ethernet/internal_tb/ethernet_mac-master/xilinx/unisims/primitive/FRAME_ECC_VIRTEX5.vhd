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
-- /___/   /\     Filename : FRAME_ECC_VIRTEX5.vhd
-- \   \  /  \    Timestamp : Thu Jun  2 10:57:03 PDT 2005
--  \___\/\___\
--
-- Revision:
--    06/03/05 - Initial version.

----- CELL FRAME_ECC_VIRTEX5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FRAME_ECC_VIRTEX5 is
  port(
    CRCERROR		: out std_ulogic;
    ECCERROR		: out std_ulogic;
    SYNDROME		: out std_logic_vector(11 downto 0);
    SYNDROMEVALID	: out std_ulogic
    );

end FRAME_ECC_VIRTEX5;

architecture FRAME_ECC_VIRTEX5_V of FRAME_ECC_VIRTEX5 is

begin
end FRAME_ECC_VIRTEX5_V;
