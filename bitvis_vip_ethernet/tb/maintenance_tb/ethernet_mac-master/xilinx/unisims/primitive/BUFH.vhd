-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/BUFH.vhd,v 1.3 2008/11/11 21:46:34 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  H Clock Buffer
-- /___/   /\     Filename : BUFH.vhd
-- \   \  /  \    Timestamp :
--  \___\/\___\
--
-- Revision:
--    04/08/08 - Initial version.
--    09/19/08 - Changed to use BUFHCE according to yaml.
--    11/11/08 - Changed to not use BUFHCE.
-- End Revision

----- CELL BUFH -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity BUFH is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end BUFH;

architecture BUFH_V of BUFH is
begin

  O <= TO_X01(I);

end BUFH_V;
