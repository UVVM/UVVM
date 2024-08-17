-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/SMODEL/GT11CLK.vhd,v 1.1 2008/09/11 16:44:42 vandanad Exp $
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
-- /___/   /\     Filename : GT11CLK.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:57:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL GT11CLK -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity GT11CLK is
generic (
		REFCLKSEL : string := "MGTCLK";
		SYNCLK1OUTEN : string := "ENABLE";
		SYNCLK2OUTEN : string := "DISABLE"
  );

port (
		SYNCLK1OUT : out std_ulogic;
		SYNCLK2OUT : out std_ulogic;

		MGTCLKN : in std_ulogic;
		MGTCLKP : in std_ulogic;
		REFCLK : in std_ulogic;
		RXBCLK : in std_ulogic;
		SYNCLK1IN : in std_ulogic;
		SYNCLK2IN : in std_ulogic
     );
end GT11CLK;

architecture GT11CLK_V of GT11CLK is
signal mgtclk_out : std_ulogic;
signal mux_out : std_ulogic;

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
      if((REFCLKSEL = "MGTCLK") or (REFCLKSEL = "mgtclk")) then
      elsif((REFCLKSEL = "SYNCLK1IN") or (REFCLKSEL = "synclk1in")) then
      elsif((REFCLKSEL = "SYNCLK2IN") or (REFCLKSEL = "synclk2in")) then
      elsif((REFCLKSEL = "REFCLK") or (REFCLKSEL = "grefclk")) then
      elsif((REFCLKSEL = "RXBCLK") or (REFCLKSEL = "rxbclk")) then
      else
        assert FALSE report "Error : REFCLKSEL = is not MGTCLK, SYNCLK1IN, SYNCLK2IN, REFCLK, RXBCLK." severity error;
      end if;
      
      if((SYNCLK1OUTEN = "ENABLE") or (SYNCLK1OUTEN = "enable")) then
      elsif((SYNCLK1OUTEN = "DISABLE") or (SYNCLK1OUTEN = "disable")) then
      else
        assert FALSE report "Error : SYNCLK1OUTEN = is not ENABLE, DISABLE." severity error;
      end if;

      if((SYNCLK2OUTEN = "ENABLE") or (SYNCLK2OUTEN = "enable")) then
      elsif((SYNCLK2OUTEN = "DISABLE") or (SYNCLK2OUTEN = "disable")) then
      else
        assert FALSE report "Error : SYNCLK2OUTEN = is not ENABLE, DISABLE." severity error;
      end if;
      first_time := false;
    end if;
    
    if (mgtclk_out'event) then
      if((REFCLKSEL = "MGTCLK") or (REFCLKSEL = "mgtclk")) then
        mux_out <= mgtclk_out;
      end if;          
    end if;

    if (SYNCLK1IN'event) then
      if((REFCLKSEL = "SYNCLK1IN") or (REFCLKSEL = "synclk1in")) then
        mux_out <= SYNCLK1IN;
      end if;          
    end if;

    if (SYNCLK2IN'event) then
      if((REFCLKSEL = "SYNCLK2IN") or (REFCLKSEL = "synclk2in")) then
        mux_out <= SYNCLK2IN;
      end if;          
    end if;    

    if (REFCLK'event) then
      if((REFCLKSEL = "REFCLK") or (REFCLKSEL = "refclk")) then
        mux_out <= REFCLK;
      end if;      
    end if;

    if (RXBCLK'event) then
      if((REFCLKSEL = "RXBCLK") or (REFCLKSEL = "RXBCLK")) then
        mux_out <= RXBCLK;
      end if;          
    end if;        
    wait on mgtclk_out, SYNCLK1IN, SYNCLK2IN, REFCLK, RXBCLK;        
  end process VitalBehavior;

  schedule_outputs : process
    begin
    if ((SYNCLK1OUTEN = "ENABLE") or (SYNCLK1OUTEN = "enable")) then
      SYNCLK1OUT <= mux_out;
    elsif((SYNCLK1OUTEN = "DISABLE") or (SYNCLK1OUTEN = "disable")) then
      SYNCLK1OUT <= 'Z';      
    else
    end if;           
           
    if ((SYNCLK2OUTEN = "ENABLE") or (SYNCLK2OUTEN = "enable")) then
      SYNCLK2OUT <= mux_out;
    elsif((SYNCLK2OUTEN = "DISABLE") or (SYNCLK2OUTEN = "disable")) then
      SYNCLK2OUT <= 'Z';      
    else
    end if;           
           
    wait on mux_out;
  end process schedule_outputs;
end GT11CLK_V;
