-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUF.vhd,v 1.3 2009/08/22 00:26:02 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Output Buffer
-- /___/   /\     Filename : OBUF.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:09 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OBUF -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUF is
  generic(
      CAPACITANCE : string     := "DONT_CARE";
      DRIVE       : integer    := 12;
      IOSTANDARD  : string     := "DEFAULT";
      SLEW        : string     := "SLOW"
    );  
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end OBUF;

architecture OBUF_V of OBUF is
begin
  prcs_init : process
  variable FIRST_TIME        : boolean    := TRUE;
  begin

     If(FIRST_TIME = true) then
        if((CAPACITANCE = "LOW") or
           (CAPACITANCE = "NORMAL") or
           (CAPACITANCE = "DONT_CARE")) then
           FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The allowed values for CAPACITANCE are LOW, NORMAL or DONT_CARE"
           severity Failure;
        end if;
     end if;
     wait;
  end process prcs_init;

  O <= TO_X01(I);
end OBUF_V;
