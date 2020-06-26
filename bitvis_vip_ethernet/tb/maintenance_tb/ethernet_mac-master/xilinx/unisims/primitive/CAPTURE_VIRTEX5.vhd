-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Register State Capture for Bitstream Readback for VIRTEX5
-- /___/   /\     Filename : CAPTURE_VIRTEX5.vhd
-- \   \  /  \    Timestamp : Thu Jun  2 10:57:03 PDT 2005
--  \___\/\___\
--
-- Revision:
--    06/03/05 - Initial version.

----- CELL CAPTURE_VIRTEX5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CAPTURE_VIRTEX5 is
  generic(
    ONESHOT : boolean := true
    );  
  port(
    CAP : in std_ulogic;
    CLK : in std_ulogic
    );

end CAPTURE_VIRTEX5;

architecture CAPTURE_VIRTEX5_V of CAPTURE_VIRTEX5 is

begin
end CAPTURE_VIRTEX5_V;
