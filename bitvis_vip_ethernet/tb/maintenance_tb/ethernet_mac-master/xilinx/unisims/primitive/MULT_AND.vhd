-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/MULT_AND.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Fast Multiplier AND
-- /___/   /\     Filename : MULT_AND.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL MULT_AND -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MULT_AND is
  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );

end MULT_AND;

architecture MULT_AND_V of MULT_AND is
begin
  VITALBehavior : process (I1, I0)
  begin
    LO <= (I0 and I1) after 0 ps;
  end process;
end MULT_AND_V;


