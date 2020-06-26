-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/SMODEL/GT11CLK_MGT.vhd,v 1.1 2008/09/11 16:44:42 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  11-Gigabit Transceiver Clock
-- /___/   /\     Filename : GT11CLK_MGT.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL GT11CLK_MGT -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity GT11CLK_MGT is
  generic (
    SYNCLK1OUTEN : string := "ENABLE";
    SYNCLK2OUTEN : string := "DISABLE"
    );

  port (
    SYNCLK1OUT : out std_ulogic;
    SYNCLK2OUT : out std_ulogic;
    
    MGTCLKN : in std_ulogic;
    MGTCLKP : in std_ulogic
    );
end GT11CLK_MGT;

architecture GT11CLK_MGT_V of GT11CLK_MGT is
signal mgtclk_out : std_ulogic;
begin
  gen_mgtclk_out : process
  begin
    if ((MGTCLKP = '1') and (MGTCLKN = '0')) then
      mgtclk_out <= MGTCLKP;
    elsif ((MGTCLKP = '0') and (MGTCLKN = '1')) then
      mgtclk_out <= MGTCLKP;       
    end if;
    wait on MGTCLKN, MGTCLKP;
  end process;
  
  VitalBehavior : process
    variable first_time : boolean := true;

     
  begin
    if (first_time = true) then
      if((SYNCLK1OUTEN = "ENABLE") or (SYNCLK1OUTEN = "enable")) then
      elsif((SYNCLK1OUTEN = "DISABLE") or (SYNCLK1OUTEN = "disable")) then
      else
        assert FALSE report "Error : SYNCLK1OUTEN = is not ENABLE, DISABLE." severity warning;
      end if;

      if((SYNCLK2OUTEN = "ENABLE") or (SYNCLK2OUTEN = "enable")) then
      elsif((SYNCLK2OUTEN = "DISABLE") or (SYNCLK2OUTEN = "disable")) then
      else
        assert FALSE report "Error : SYNCLK2OUTEN = is not ENABLE, DISABLE." severity warning;
      end if;
      first_time := false;
    end if;
    wait;
  end process VitalBehavior;  

  schedule_outputs : process
    begin
    if ((SYNCLK1OUTEN = "ENABLE") or (SYNCLK1OUTEN = "enable")) then
      SYNCLK1OUT <= mgtclk_out;
    elsif((SYNCLK1OUTEN = "DISABLE") or (SYNCLK1OUTEN = "disable")) then
      SYNCLK1OUT <= 'Z';      
    else
    end if;           
           
    if ((SYNCLK2OUTEN = "ENABLE") or (SYNCLK2OUTEN = "enable")) then
      SYNCLK2OUT <= mgtclk_out;
    elsif((SYNCLK2OUTEN = "DISABLE") or (SYNCLK2OUTEN = "disable")) then
      SYNCLK2OUT <= 'Z';      
    else
    end if;           
           
    wait on mgtclk_out;
  end process schedule_outputs;
end GT11CLK_MGT_V;
