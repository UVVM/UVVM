-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUFTDS.vhd,v 1.5 2010/12/02 01:13:43 fphillip Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-State Differential Signaling Output Buffer
-- /___/   /\     Filename : OBUFTDS.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:42 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/12/10 - CR 559468 -- Added DRC warnings for LVDS_25 bus architectures.
--    12/01/10 - CR 584500 -- Added attribute SLEW
-- End Revision

----- CELL OBUFTDS -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUFTDS is
  generic(
      CAPACITANCE : string     := "DONT_CARE";
      IOSTANDARD  : string     := "DEFAULT";
      SLEW        : string     := "SLOW"
    );

  port(
    O  : out std_ulogic;
    OB : out std_ulogic;

    I : in std_ulogic;
    T : in std_ulogic
    );
end OBUFTDS;

architecture OBUFTDS_V of OBUFTDS is
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

     if((IOSTANDARD = "LVDS_25") or (IOSTANDARD = "LVDSEXT_25")) then
        assert false
        report "DRC Warning : The IOSTANDARD attribute on OBUFTDS instance is either set to LVDS_25 or LVDSEXT_25. These are fixed impedance structure optimized to 100ohm differential. If the intended usage is a bus architecture, please use BLVDS. This is only intended to be used in point to point transmissions that do not have turn around timing requirements"
        severity Warning;
     end if;

     wait;
  end process prcs_init;

  VITALBehavior    : process (I, T)
  begin

    if ((T = '1') or (T = 'H')) then
      O <= 'Z';
    elsif ((T = '0') or (T = 'L')) then
      if ((I = '1') or (I = 'H')) then
        O <= '1';
      elsif ((I = '0') or (I = 'L')) then
        O <= '0';
      elsif (I = 'U') then
        O <= 'U';
      else
        O <= 'X';  
      end if;
    elsif (T = 'U') then
      O <= 'U';          
    else                                      
      O <= 'X';  
    end if;

    if ((T = '1') or (T = 'H')) then
      OB <= 'Z';
    elsif ((T = '0') or (T = 'L')) then
      if (((not I) = '1') or ((not I) = 'H')) then
        OB <= '1';
      elsif (((not I) = '0') or ((not I) = 'L')) then
        OB <= '0';
      elsif ((not I) = 'U') then
        OB <= 'U';
      else
        OB <= 'X';  
      end if;
    elsif (T = 'U') then
      OB <= 'U';          
    else                                      
      OB <= 'X';  
    end if;        
  end process;
end OBUFTDS_V;
