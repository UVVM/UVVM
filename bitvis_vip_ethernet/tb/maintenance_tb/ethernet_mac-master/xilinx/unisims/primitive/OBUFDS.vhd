-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUFDS.vhd,v 1.4 2010/12/02 01:13:43 fphillip Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Output Buffer
-- /___/   /\     Filename : OBUFDS.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:25 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    12/01/10 - CR 584500 - added attribute SLEW
-- End Revision


----- CELL OBUFDS -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUFDS is
  generic(
      CAPACITANCE : string     := "DONT_CARE";
      IOSTANDARD  : string     := "DEFAULT";
      SLEW        : string     := "SLOW"
    );

  port(
    O  : out std_ulogic;
    OB : out std_ulogic;

    I : in std_ulogic
    );
end OBUFDS;

architecture OBUFDS_V of OBUFDS is
begin
  VitalBehavior    : process (I)
    variable O_zd  : std_logic;
    variable OB_zd : std_logic;
  begin
    O_zd  := TO_X01(I);
    OB_zd := (not O_zd);
    O  <= O_zd;
    OB <= OB_zd;
  end process;
end OBUFDS_V;


