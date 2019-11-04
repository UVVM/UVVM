-------------------------------------------------------
--  Copyright (c) 2012 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : GTPE2_COMMON.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  06/02/11 - Initial version
--  09/27/11 - 626008 - YML update
--  10/24/11 - 630158 - Add message
--  01/04/12 - 640449 - YML update
--  02/01/12 - 641156 - complete GTPE2 wrapper
--  11/8/12  - 686589 - YML default changes
--  01/22/13 - Added DRP monitor (CR 695630).
-------------------------------------------------------

----- CELL GTPE2_COMMON -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity GTPE2_COMMON is
    generic (
      BIAS_CFG : bit_vector := X"0000000000000000";
      COMMON_CFG : bit_vector := X"00000000";
      PLL0_CFG : bit_vector := X"01F03DC";
      PLL0_DMON_CFG : bit := '0';
      PLL0_FBDIV : integer := 4;
      PLL0_FBDIV_45 : integer := 5;
      PLL0_INIT_CFG : bit_vector := X"00001E";
      PLL0_LOCK_CFG : bit_vector := X"1E8";
      PLL0_REFCLK_DIV : integer := 1;
      PLL1_CFG : bit_vector := X"01F03DC";
      PLL1_DMON_CFG : bit := '0';
      PLL1_FBDIV : integer := 4;
      PLL1_FBDIV_45 : integer := 5;
      PLL1_INIT_CFG : bit_vector := X"00001E";
      PLL1_LOCK_CFG : bit_vector := X"1E8";
      PLL1_REFCLK_DIV : integer := 1;
      PLL_CLKOUT_CFG : bit_vector := "00000000";
      RSVD_ATTR0 : bit_vector := X"0000";
      RSVD_ATTR1 : bit_vector := X"0000";
      SIM_PLL0REFCLK_SEL : bit_vector := "001";
      SIM_PLL1REFCLK_SEL : bit_vector := "001";
      SIM_RESET_SPEEDUP : string := "TRUE";
      SIM_VERSION : string := "1.0"
    );

    port (
      DMONITOROUT          : out std_logic_vector(7 downto 0);
      DRPDO                : out std_logic_vector(15 downto 0);
      DRPRDY               : out std_ulogic;
      PLL0FBCLKLOST        : out std_ulogic;
      PLL0LOCK             : out std_ulogic;
      PLL0OUTCLK           : out std_ulogic;
      PLL0OUTREFCLK        : out std_ulogic;
      PLL0REFCLKLOST       : out std_ulogic;
      PLL1FBCLKLOST        : out std_ulogic;
      PLL1LOCK             : out std_ulogic;
      PLL1OUTCLK           : out std_ulogic;
      PLL1OUTREFCLK        : out std_ulogic;
      PLL1REFCLKLOST       : out std_ulogic;
      PMARSVDOUT           : out std_logic_vector(15 downto 0);
      REFCLKOUTMONITOR0    : out std_ulogic;
      REFCLKOUTMONITOR1    : out std_ulogic;
      BGBYPASSB            : in std_ulogic;
      BGMONITORENB         : in std_ulogic;
      BGPDB                : in std_ulogic;
      BGRCALOVRD           : in std_logic_vector(4 downto 0);
      BGRCALOVRDENB        : in std_ulogic;
      DRPADDR              : in std_logic_vector(7 downto 0);
      DRPCLK               : in std_ulogic;
      DRPDI                : in std_logic_vector(15 downto 0);
      DRPEN                : in std_ulogic;
      DRPWE                : in std_ulogic;
      GTEASTREFCLK0        : in std_ulogic;
      GTEASTREFCLK1        : in std_ulogic;
      GTGREFCLK0           : in std_ulogic;
      GTGREFCLK1           : in std_ulogic;
      GTREFCLK0            : in std_ulogic;
      GTREFCLK1            : in std_ulogic;
      GTWESTREFCLK0        : in std_ulogic;
      GTWESTREFCLK1        : in std_ulogic;
      PLL0LOCKDETCLK       : in std_ulogic;
      PLL0LOCKEN           : in std_ulogic;
      PLL0PD               : in std_ulogic;
      PLL0REFCLKSEL        : in std_logic_vector(2 downto 0);
      PLL0RESET            : in std_ulogic;
      PLL1LOCKDETCLK       : in std_ulogic;
      PLL1LOCKEN           : in std_ulogic;
      PLL1PD               : in std_ulogic;
      PLL1REFCLKSEL        : in std_logic_vector(2 downto 0);
      PLL1RESET            : in std_ulogic;
      PLLRSVD1             : in std_logic_vector(15 downto 0);
      PLLRSVD2             : in std_logic_vector(4 downto 0);
      PMARSVD              : in std_logic_vector(7 downto 0);
      RCALENB              : in std_ulogic      
    );
  end GTPE2_COMMON;

  architecture GTPE2_COMMON_V of GTPE2_COMMON is
    component GTPE2_COMMON_WRAP
      generic (
        BIAS_CFG : string;
        COMMON_CFG : string;
        PLL0_CFG : string;
        PLL0_DMON_CFG : string;
        PLL0_FBDIV : integer;
        PLL0_FBDIV_45 : integer;
        PLL0_INIT_CFG : string;
        PLL0_LOCK_CFG : string;
        PLL0_REFCLK_DIV : integer;
        PLL1_CFG : string;
        PLL1_DMON_CFG : string;
        PLL1_FBDIV : integer;
        PLL1_FBDIV_45 : integer;
        PLL1_INIT_CFG : string;
        PLL1_LOCK_CFG : string;
        PLL1_REFCLK_DIV : integer;
        PLL_CLKOUT_CFG : string;
        RSVD_ATTR0 : string;
        RSVD_ATTR1 : string;
        SIM_PLL0REFCLK_SEL : string;
        SIM_PLL1REFCLK_SEL : string;
        SIM_RESET_SPEEDUP : string;
        SIM_VERSION : string        
      );
      
      port (
        DMONITOROUT          : out std_logic_vector(7 downto 0);
        DRPDO                : out std_logic_vector(15 downto 0);
        DRPRDY               : out std_ulogic;
        PLL0FBCLKLOST        : out std_ulogic;
        PLL0LOCK             : out std_ulogic;
        PLL0OUTCLK           : out std_ulogic;
        PLL0OUTREFCLK        : out std_ulogic;
        PLL0REFCLKLOST       : out std_ulogic;
        PLL1FBCLKLOST        : out std_ulogic;
        PLL1LOCK             : out std_ulogic;
        PLL1OUTCLK           : out std_ulogic;
        PLL1OUTREFCLK        : out std_ulogic;
        PLL1REFCLKLOST       : out std_ulogic;
        PMARSVDOUT           : out std_logic_vector(15 downto 0);
        REFCLKOUTMONITOR0    : out std_ulogic;
        REFCLKOUTMONITOR1    : out std_ulogic;

        GSR                  : in std_ulogic;
        BGBYPASSB            : in std_ulogic;
        BGMONITORENB         : in std_ulogic;
        BGPDB                : in std_ulogic;
        BGRCALOVRD           : in std_logic_vector(4 downto 0);
        BGRCALOVRDENB        : in std_ulogic;
        DRPADDR              : in std_logic_vector(7 downto 0);
        DRPCLK               : in std_ulogic;
        DRPDI                : in std_logic_vector(15 downto 0);
        DRPEN                : in std_ulogic;
        DRPWE                : in std_ulogic;
        GTEASTREFCLK0        : in std_ulogic;
        GTEASTREFCLK1        : in std_ulogic;
        GTGREFCLK0           : in std_ulogic;
        GTGREFCLK1           : in std_ulogic;
        GTREFCLK0            : in std_ulogic;
        GTREFCLK1            : in std_ulogic;
        GTWESTREFCLK0        : in std_ulogic;
        GTWESTREFCLK1        : in std_ulogic;
        PLL0LOCKDETCLK       : in std_ulogic;
        PLL0LOCKEN           : in std_ulogic;
        PLL0PD               : in std_ulogic;
        PLL0REFCLKSEL        : in std_logic_vector(2 downto 0);
        PLL0RESET            : in std_ulogic;
        PLL1LOCKDETCLK       : in std_ulogic;
        PLL1LOCKEN           : in std_ulogic;
        PLL1PD               : in std_ulogic;
        PLL1REFCLKSEL        : in std_logic_vector(2 downto 0);
        PLL1RESET            : in std_ulogic;
        PLLRSVD1             : in std_logic_vector(15 downto 0);
        PLLRSVD2             : in std_logic_vector(4 downto 0);
        PMARSVD              : in std_logic_vector(7 downto 0);
        RCALENB              : in std_ulogic        
      );
    end component;
    
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    function SUL_TO_STR (sul : std_ulogic)
    return string is
    begin
      if sul = '0' then
        return "0";
      else
        return "1";
      end if;
    end SUL_TO_STR;

    function boolean_to_string(bool: boolean)
    return string is
    begin
      if bool then
        return "TRUE";
      else
        return "FALSE";
      end if;
    end boolean_to_string;

    function getstrlength(in_vec : std_logic_vector)
    return integer is
      variable string_length : integer;
    begin
      if ((in_vec'length mod 4) = 0) then
        string_length := in_vec'length/4;
      elsif ((in_vec'length mod 4) > 0) then
        string_length := in_vec'length/4 + 1;
      end if;
      return string_length;
    end getstrlength;

    -- Convert bit_vector to std_logic_vector
    constant BIAS_CFG_BINARY : std_logic_vector(63 downto 0) := To_StdLogicVector(BIAS_CFG)(63 downto 0);
    constant COMMON_CFG_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(COMMON_CFG)(31 downto 0);
    constant PLL0_CFG_BINARY : std_logic_vector(26 downto 0) := To_StdLogicVector(PLL0_CFG)(26 downto 0);
    constant PLL0_DMON_CFG_BINARY : std_ulogic := To_StduLogic(PLL0_DMON_CFG);
    constant PLL0_INIT_CFG_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(PLL0_INIT_CFG)(23 downto 0);
    constant PLL0_LOCK_CFG_BINARY : std_logic_vector(8 downto 0) := To_StdLogicVector(PLL0_LOCK_CFG)(8 downto 0);
    constant PLL1_CFG_BINARY : std_logic_vector(26 downto 0) := To_StdLogicVector(PLL1_CFG)(26 downto 0);
    constant PLL1_DMON_CFG_BINARY : std_ulogic := To_StduLogic(PLL1_DMON_CFG);
    constant PLL1_INIT_CFG_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(PLL1_INIT_CFG)(23 downto 0);
    constant PLL1_LOCK_CFG_BINARY : std_logic_vector(8 downto 0) := To_StdLogicVector(PLL1_LOCK_CFG)(8 downto 0);
    constant PLL_CLKOUT_CFG_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PLL_CLKOUT_CFG)(7 downto 0);
    constant RSVD_ATTR0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RSVD_ATTR0)(15 downto 0);
    constant RSVD_ATTR1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RSVD_ATTR1)(15 downto 0);
    constant SIM_PLL0REFCLK_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SIM_PLL0REFCLK_SEL)(2 downto 0);
    constant SIM_PLL1REFCLK_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SIM_PLL1REFCLK_SEL)(2 downto 0);
    
    -- Get String Length
    constant BIAS_CFG_STRLEN : integer := getstrlength(BIAS_CFG_BINARY);
    constant COMMON_CFG_STRLEN : integer := getstrlength(COMMON_CFG_BINARY);
    constant PLL0_CFG_STRLEN : integer := getstrlength(PLL0_CFG_BINARY);
    constant PLL0_INIT_CFG_STRLEN : integer := getstrlength(PLL0_INIT_CFG_BINARY);
    constant PLL0_LOCK_CFG_STRLEN : integer := getstrlength(PLL0_LOCK_CFG_BINARY);
    constant PLL1_CFG_STRLEN : integer := getstrlength(PLL1_CFG_BINARY);
    constant PLL1_INIT_CFG_STRLEN : integer := getstrlength(PLL1_INIT_CFG_BINARY);
    constant PLL1_LOCK_CFG_STRLEN : integer := getstrlength(PLL1_LOCK_CFG_BINARY);
    constant RSVD_ATTR0_STRLEN : integer := getstrlength(RSVD_ATTR0_BINARY);
    constant RSVD_ATTR1_STRLEN : integer := getstrlength(RSVD_ATTR1_BINARY);
    
    -- Convert std_logic_vector to string
    constant BIAS_CFG_STRING : string := SLV_TO_HEX(BIAS_CFG_BINARY, BIAS_CFG_STRLEN);
    constant COMMON_CFG_STRING : string := SLV_TO_HEX(COMMON_CFG_BINARY, COMMON_CFG_STRLEN);
    constant PLL0_CFG_STRING : string := SLV_TO_HEX(PLL0_CFG_BINARY, PLL0_CFG_STRLEN);
    constant PLL0_DMON_CFG_STRING : string := SUL_TO_STR(PLL0_DMON_CFG_BINARY);
    constant PLL0_INIT_CFG_STRING : string := SLV_TO_HEX(PLL0_INIT_CFG_BINARY, PLL0_INIT_CFG_STRLEN);
    constant PLL0_LOCK_CFG_STRING : string := SLV_TO_HEX(PLL0_LOCK_CFG_BINARY, PLL0_LOCK_CFG_STRLEN);
    constant PLL1_CFG_STRING : string := SLV_TO_HEX(PLL1_CFG_BINARY, PLL1_CFG_STRLEN);
    constant PLL1_DMON_CFG_STRING : string := SUL_TO_STR(PLL1_DMON_CFG_BINARY);
    constant PLL1_INIT_CFG_STRING : string := SLV_TO_HEX(PLL1_INIT_CFG_BINARY, PLL1_INIT_CFG_STRLEN);
    constant PLL1_LOCK_CFG_STRING : string := SLV_TO_HEX(PLL1_LOCK_CFG_BINARY, PLL1_LOCK_CFG_STRLEN);
    constant PLL_CLKOUT_CFG_STRING : string := SLV_TO_STR(PLL_CLKOUT_CFG_BINARY);
    constant RSVD_ATTR0_STRING : string := SLV_TO_HEX(RSVD_ATTR0_BINARY, RSVD_ATTR0_STRLEN);
    constant RSVD_ATTR1_STRING : string := SLV_TO_HEX(RSVD_ATTR1_BINARY, RSVD_ATTR1_STRLEN);
    constant SIM_PLL0REFCLK_SEL_STRING : string := SLV_TO_STR(SIM_PLL0REFCLK_SEL_BINARY);
    constant SIM_PLL1REFCLK_SEL_STRING : string := SLV_TO_STR(SIM_PLL1REFCLK_SEL_BINARY);
    
    signal PLL0_FBDIV_45_BINARY : std_ulogic;
    signal PLL0_FBDIV_BINARY : std_logic_vector(5 downto 0);
    signal PLL0_REFCLK_DIV_BINARY : std_logic_vector(4 downto 0);
    signal PLL1_FBDIV_45_BINARY : std_ulogic;
    signal PLL1_FBDIV_BINARY : std_logic_vector(5 downto 0);
    signal PLL1_REFCLK_DIV_BINARY : std_logic_vector(4 downto 0);
    signal SIM_RESET_SPEEDUP_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    
    signal DMONITOROUT_out : std_logic_vector(7 downto 0);
    signal DRPDO_out : std_logic_vector(15 downto 0);
    signal DRPRDY_out : std_ulogic;
    signal PLL0FBCLKLOST_out : std_ulogic;
    signal PLL0LOCK_out : std_ulogic;
    signal PLL0OUTCLK_out : std_ulogic;
    signal PLL0OUTREFCLK_out : std_ulogic;
    signal PLL0REFCLKLOST_out : std_ulogic;
    signal PLL1FBCLKLOST_out : std_ulogic;
    signal PLL1LOCK_out : std_ulogic;
    signal PLL1OUTCLK_out : std_ulogic;
    signal PLL1OUTREFCLK_out : std_ulogic;
    signal PLL1REFCLKLOST_out : std_ulogic;
    signal PMARSVDOUT_out : std_logic_vector(15 downto 0);
    signal REFCLKOUTMONITOR0_out : std_ulogic;
    signal REFCLKOUTMONITOR1_out : std_ulogic;
    
    signal DMONITOROUT_outdelay : std_logic_vector(7 downto 0);
    signal DRPDO_outdelay : std_logic_vector(15 downto 0);
    signal DRPRDY_outdelay : std_ulogic;
    signal PLL0FBCLKLOST_outdelay : std_ulogic;
    signal PLL0LOCK_outdelay : std_ulogic;
    signal PLL0OUTCLK_outdelay : std_ulogic;
    signal PLL0OUTREFCLK_outdelay : std_ulogic;
    signal PLL0REFCLKLOST_outdelay : std_ulogic;
    signal PLL1FBCLKLOST_outdelay : std_ulogic;
    signal PLL1LOCK_outdelay : std_ulogic;
    signal PLL1OUTCLK_outdelay : std_ulogic;
    signal PLL1OUTREFCLK_outdelay : std_ulogic;
    signal PLL1REFCLKLOST_outdelay : std_ulogic;
    signal PMARSVDOUT_outdelay : std_logic_vector(15 downto 0);
    signal REFCLKOUTMONITOR0_outdelay : std_ulogic;
    signal REFCLKOUTMONITOR1_outdelay : std_ulogic;
    
    signal BGBYPASSB_ipd : std_ulogic;
    signal BGMONITORENB_ipd : std_ulogic;
    signal BGPDB_ipd : std_ulogic;
    signal BGRCALOVRDENB_ipd : std_ulogic;
    signal BGRCALOVRD_ipd : std_logic_vector(4 downto 0);
    signal DRPADDR_ipd : std_logic_vector(7 downto 0);
    signal DRPCLK_ipd : std_ulogic;
    signal DRPDI_ipd : std_logic_vector(15 downto 0);
    signal DRPEN_ipd : std_ulogic;
    signal DRPWE_ipd : std_ulogic;
    signal GTEASTREFCLK0_ipd : std_ulogic;
    signal GTEASTREFCLK1_ipd : std_ulogic;
    signal GTGREFCLK0_ipd : std_ulogic;
    signal GTGREFCLK1_ipd : std_ulogic;
    signal GTREFCLK0_ipd : std_ulogic;
    signal GTREFCLK1_ipd : std_ulogic;
    signal GTWESTREFCLK0_ipd : std_ulogic;
    signal GTWESTREFCLK1_ipd : std_ulogic;
    signal PLL0LOCKDETCLK_ipd : std_ulogic;
    signal PLL0LOCKEN_ipd : std_ulogic;
    signal PLL0PD_ipd : std_ulogic;
    signal PLL0REFCLKSEL_ipd : std_logic_vector(2 downto 0);
    signal PLL0RESET_ipd : std_ulogic;
    signal PLL1LOCKDETCLK_ipd : std_ulogic;
    signal PLL1LOCKEN_ipd : std_ulogic;
    signal PLL1PD_ipd : std_ulogic;
    signal PLL1REFCLKSEL_ipd : std_logic_vector(2 downto 0);
    signal PLL1RESET_ipd : std_ulogic;
    signal PLLRSVD1_ipd : std_logic_vector(15 downto 0);
    signal PLLRSVD2_ipd : std_logic_vector(4 downto 0);
    signal PMARSVD_ipd : std_logic_vector(7 downto 0);
    signal RCALENB_ipd : std_ulogic;
    
    signal BGBYPASSB_indelay : std_ulogic;
    signal BGMONITORENB_indelay : std_ulogic;
    signal BGPDB_indelay : std_ulogic;
    signal BGRCALOVRDENB_indelay : std_ulogic;
    signal BGRCALOVRD_indelay : std_logic_vector(4 downto 0);
    signal DRPADDR_indelay : std_logic_vector(7 downto 0);
    signal DRPCLK_indelay : std_ulogic;
    signal DRPDI_indelay : std_logic_vector(15 downto 0);
    signal DRPEN_indelay : std_ulogic;
    signal DRPWE_indelay : std_ulogic;
    signal GTEASTREFCLK0_indelay : std_ulogic;
    signal GTEASTREFCLK1_indelay : std_ulogic;
    signal GTGREFCLK0_indelay : std_ulogic;
    signal GTGREFCLK1_indelay : std_ulogic;
    signal GTREFCLK0_indelay : std_ulogic;
    signal GTREFCLK1_indelay : std_ulogic;
    signal GTWESTREFCLK0_indelay : std_ulogic;
    signal GTWESTREFCLK1_indelay : std_ulogic;
    signal PLL0LOCKDETCLK_indelay : std_ulogic;
    signal PLL0LOCKEN_indelay : std_ulogic;
    signal PLL0PD_indelay : std_ulogic;
    signal PLL0REFCLKSEL_indelay : std_logic_vector(2 downto 0);
    signal PLL0RESET_indelay : std_ulogic;
    signal PLL1LOCKDETCLK_indelay : std_ulogic;
    signal PLL1LOCKEN_indelay : std_ulogic;
    signal PLL1PD_indelay : std_ulogic;
    signal PLL1REFCLKSEL_indelay : std_logic_vector(2 downto 0);
    signal PLL1RESET_indelay : std_ulogic;
    signal PLLRSVD1_indelay : std_logic_vector(15 downto 0);
    signal PLLRSVD2_indelay : std_logic_vector(4 downto 0);
    signal PMARSVD_indelay : std_logic_vector(7 downto 0);
    signal RCALENB_indelay : std_ulogic;
    
    begin
    PLL0OUTCLK_out <= PLL0OUTCLK_outdelay after OUTCLK_DELAY;
    PLL1OUTCLK_out <= PLL1OUTCLK_outdelay after OUTCLK_DELAY;
    REFCLKOUTMONITOR0_out <= REFCLKOUTMONITOR0_outdelay after OUTCLK_DELAY;
    REFCLKOUTMONITOR1_out <= REFCLKOUTMONITOR1_outdelay after OUTCLK_DELAY;
    
    DMONITOROUT_out <= DMONITOROUT_outdelay after OUT_DELAY;
    DRPDO_out <= DRPDO_outdelay after OUT_DELAY;
    DRPRDY_out <= DRPRDY_outdelay after OUT_DELAY;
    PLL0FBCLKLOST_out <= PLL0FBCLKLOST_outdelay after OUT_DELAY;
    PLL0LOCK_out <= PLL0LOCK_outdelay after OUT_DELAY;
    PLL0OUTREFCLK_out <= PLL0OUTREFCLK_outdelay after OUT_DELAY;
    PLL0REFCLKLOST_out <= PLL0REFCLKLOST_outdelay after OUT_DELAY;
    PLL1FBCLKLOST_out <= PLL1FBCLKLOST_outdelay after OUT_DELAY;
    PLL1LOCK_out <= PLL1LOCK_outdelay after OUT_DELAY;
    PLL1OUTREFCLK_out <= PLL1OUTREFCLK_outdelay after OUT_DELAY;
    PLL1REFCLKLOST_out <= PLL1REFCLKLOST_outdelay after OUT_DELAY;
    PMARSVDOUT_out <= PMARSVDOUT_outdelay after OUT_DELAY;
    
    DRPCLK_ipd <= DRPCLK;
    GTEASTREFCLK0_ipd <= GTEASTREFCLK0;
    GTEASTREFCLK1_ipd <= GTEASTREFCLK1;
    GTGREFCLK0_ipd <= GTGREFCLK0;
    GTGREFCLK1_ipd <= GTGREFCLK1;
    GTREFCLK0_ipd <= GTREFCLK0;
    GTREFCLK1_ipd <= GTREFCLK1;
    GTWESTREFCLK0_ipd <= GTWESTREFCLK0;
    GTWESTREFCLK1_ipd <= GTWESTREFCLK1;
    PLL0LOCKDETCLK_ipd <= PLL0LOCKDETCLK;
    PLL1LOCKDETCLK_ipd <= PLL1LOCKDETCLK;
    
    BGBYPASSB_ipd <= BGBYPASSB;
    BGMONITORENB_ipd <= BGMONITORENB;
    BGPDB_ipd <= BGPDB;
    BGRCALOVRDENB_ipd <= BGRCALOVRDENB;
    BGRCALOVRD_ipd <= BGRCALOVRD;
    DRPADDR_ipd <= DRPADDR;
    DRPDI_ipd <= DRPDI;
    DRPEN_ipd <= DRPEN;
    DRPWE_ipd <= DRPWE;
    PLL0LOCKEN_ipd <= PLL0LOCKEN;
    PLL0PD_ipd <= PLL0PD;
    PLL0REFCLKSEL_ipd <= PLL0REFCLKSEL;
    PLL0RESET_ipd <= PLL0RESET;
    PLL1LOCKEN_ipd <= PLL1LOCKEN;
    PLL1PD_ipd <= PLL1PD;
    PLL1REFCLKSEL_ipd <= PLL1REFCLKSEL;
    PLL1RESET_ipd <= PLL1RESET;
    PLLRSVD1_ipd <= PLLRSVD1;
    PLLRSVD2_ipd <= PLLRSVD2;
    PMARSVD_ipd <= PMARSVD;
    RCALENB_ipd <= RCALENB;
    
    DRPCLK_indelay <= DRPCLK_ipd after INCLK_DELAY;
    GTEASTREFCLK0_indelay <= GTEASTREFCLK0_ipd after INCLK_DELAY;
    GTEASTREFCLK1_indelay <= GTEASTREFCLK1_ipd after INCLK_DELAY;
    GTGREFCLK0_indelay <= GTGREFCLK0_ipd after INCLK_DELAY;
    GTGREFCLK1_indelay <= GTGREFCLK1_ipd after INCLK_DELAY;
    GTREFCLK0_indelay <= GTREFCLK0_ipd after INCLK_DELAY;
    GTREFCLK1_indelay <= GTREFCLK1_ipd after INCLK_DELAY;
    GTWESTREFCLK0_indelay <= GTWESTREFCLK0_ipd after INCLK_DELAY;
    GTWESTREFCLK1_indelay <= GTWESTREFCLK1_ipd after INCLK_DELAY;
    PLL0LOCKDETCLK_indelay <= PLL0LOCKDETCLK_ipd after INCLK_DELAY;
    PLL1LOCKDETCLK_indelay <= PLL1LOCKDETCLK_ipd after INCLK_DELAY;
    
    BGBYPASSB_indelay <= BGBYPASSB_ipd after IN_DELAY;
    BGMONITORENB_indelay <= BGMONITORENB_ipd after IN_DELAY;
    BGPDB_indelay <= BGPDB_ipd after IN_DELAY;
    BGRCALOVRDENB_indelay <= BGRCALOVRDENB_ipd after IN_DELAY;
    BGRCALOVRD_indelay <= BGRCALOVRD_ipd after IN_DELAY;
    DRPADDR_indelay <= DRPADDR_ipd after IN_DELAY;
    DRPDI_indelay <= DRPDI_ipd after IN_DELAY;
    DRPEN_indelay <= DRPEN_ipd after IN_DELAY;
    DRPWE_indelay <= DRPWE_ipd after IN_DELAY;
    PLL0LOCKEN_indelay <= PLL0LOCKEN_ipd after IN_DELAY;
    PLL0PD_indelay <= PLL0PD_ipd after IN_DELAY;
    PLL0REFCLKSEL_indelay <= PLL0REFCLKSEL_ipd after IN_DELAY;
    PLL0RESET_indelay <= PLL0RESET_ipd after IN_DELAY;
    PLL1LOCKEN_indelay <= PLL1LOCKEN_ipd after IN_DELAY;
    PLL1PD_indelay <= PLL1PD_ipd after IN_DELAY;
    PLL1REFCLKSEL_indelay <= PLL1REFCLKSEL_ipd after IN_DELAY;
    PLL1RESET_indelay <= PLL1RESET_ipd after IN_DELAY;
    PLLRSVD1_indelay <= PLLRSVD1_ipd after IN_DELAY;
    PLLRSVD2_indelay <= PLLRSVD2_ipd after IN_DELAY;
    PMARSVD_indelay <= PMARSVD_ipd after IN_DELAY;
    RCALENB_indelay <= RCALENB_ipd after IN_DELAY;
    
    
    GTPE2_COMMON_INST : GTPE2_COMMON_WRAP
      generic map (
        BIAS_CFG             => BIAS_CFG_STRING,
        COMMON_CFG           => COMMON_CFG_STRING,
        PLL0_CFG             => PLL0_CFG_STRING,
        PLL0_DMON_CFG        => PLL0_DMON_CFG_STRING,
        PLL0_FBDIV           => PLL0_FBDIV,
        PLL0_FBDIV_45        => PLL0_FBDIV_45,
        PLL0_INIT_CFG        => PLL0_INIT_CFG_STRING,
        PLL0_LOCK_CFG        => PLL0_LOCK_CFG_STRING,
        PLL0_REFCLK_DIV      => PLL0_REFCLK_DIV,
        PLL1_CFG             => PLL1_CFG_STRING,
        PLL1_DMON_CFG        => PLL1_DMON_CFG_STRING,
        PLL1_FBDIV           => PLL1_FBDIV,
        PLL1_FBDIV_45        => PLL1_FBDIV_45,
        PLL1_INIT_CFG        => PLL1_INIT_CFG_STRING,
        PLL1_LOCK_CFG        => PLL1_LOCK_CFG_STRING,
        PLL1_REFCLK_DIV      => PLL1_REFCLK_DIV,
        PLL_CLKOUT_CFG       => PLL_CLKOUT_CFG_STRING,
        RSVD_ATTR0           => RSVD_ATTR0_STRING,
        RSVD_ATTR1           => RSVD_ATTR1_STRING,
        SIM_PLL0REFCLK_SEL   => SIM_PLL0REFCLK_SEL_STRING,
        SIM_PLL1REFCLK_SEL   => SIM_PLL1REFCLK_SEL_STRING,
        SIM_RESET_SPEEDUP    => SIM_RESET_SPEEDUP,
        SIM_VERSION          => SIM_VERSION
      )
      
      port map (
        GSR                  => GSR,
        DMONITOROUT          => DMONITOROUT_outdelay,
        DRPDO                => DRPDO_outdelay,
        DRPRDY               => DRPRDY_outdelay,
        PLL0FBCLKLOST        => PLL0FBCLKLOST_outdelay,
        PLL0LOCK             => PLL0LOCK_outdelay,
        PLL0OUTCLK           => PLL0OUTCLK_outdelay,
        PLL0OUTREFCLK        => PLL0OUTREFCLK_outdelay,
        PLL0REFCLKLOST       => PLL0REFCLKLOST_outdelay,
        PLL1FBCLKLOST        => PLL1FBCLKLOST_outdelay,
        PLL1LOCK             => PLL1LOCK_outdelay,
        PLL1OUTCLK           => PLL1OUTCLK_outdelay,
        PLL1OUTREFCLK        => PLL1OUTREFCLK_outdelay,
        PLL1REFCLKLOST       => PLL1REFCLKLOST_outdelay,
        PMARSVDOUT           => PMARSVDOUT_outdelay,
        REFCLKOUTMONITOR0    => REFCLKOUTMONITOR0_outdelay,
        REFCLKOUTMONITOR1    => REFCLKOUTMONITOR1_outdelay,
        BGBYPASSB            => BGBYPASSB_indelay,
        BGMONITORENB         => BGMONITORENB_indelay,
        BGPDB                => BGPDB_indelay,
        BGRCALOVRD           => BGRCALOVRD_indelay,
        BGRCALOVRDENB        => BGRCALOVRDENB_indelay,
        DRPADDR              => DRPADDR_indelay,
        DRPCLK               => DRPCLK_indelay,
        DRPDI                => DRPDI_indelay,
        DRPEN                => DRPEN_indelay,
        DRPWE                => DRPWE_indelay,
        GTEASTREFCLK0        => GTEASTREFCLK0_indelay,
        GTEASTREFCLK1        => GTEASTREFCLK1_indelay,
        GTGREFCLK0           => GTGREFCLK0_indelay,
        GTGREFCLK1           => GTGREFCLK1_indelay,
        GTREFCLK0            => GTREFCLK0_indelay,
        GTREFCLK1            => GTREFCLK1_indelay,
        GTWESTREFCLK0        => GTWESTREFCLK0_indelay,
        GTWESTREFCLK1        => GTWESTREFCLK1_indelay,
        PLL0LOCKDETCLK       => PLL0LOCKDETCLK_indelay,
        PLL0LOCKEN           => PLL0LOCKEN_indelay,
        PLL0PD               => PLL0PD_indelay,
        PLL0REFCLKSEL        => PLL0REFCLKSEL_indelay,
        PLL0RESET            => PLL0RESET_indelay,
        PLL1LOCKDETCLK       => PLL1LOCKDETCLK_indelay,
        PLL1LOCKEN           => PLL1LOCKEN_indelay,
        PLL1PD               => PLL1PD_indelay,
        PLL1REFCLKSEL        => PLL1REFCLKSEL_indelay,
        PLL1RESET            => PLL1RESET_indelay,
        PLLRSVD1             => PLLRSVD1_indelay,
        PLLRSVD2             => PLLRSVD2_indelay,
        PMARSVD              => PMARSVD_indelay,
        RCALENB              => RCALENB_indelay        
      );

      
   drp_monitor: process (DRPCLK_indelay)

     variable drpen_r1 : std_logic := '0';
     variable drpen_r2 : std_logic := '0';
     variable drpwe_r1 : std_logic := '0';
     variable drpwe_r2 : std_logic := '0';
     type statetype is (FSM_IDLE, FSM_WAIT);
     variable sfsm : statetype := FSM_IDLE;

   begin  -- process drp_monitor

     if (rising_edge(DRPCLK_indelay)) then

       -- pipeline the DRPEN and DRPWE
       drpen_r2 := drpen_r1;
       drpwe_r2 := drpwe_r1;
       drpen_r1 := DRPEN_indelay;
       drpwe_r1 := DRPWE_indelay;
    
    
       -- Check -  if DRPEN or DRPWE is more than 1 DCLK
       if ((drpen_r1 = '1') and (drpen_r2 = '1')) then 
         assert false
           report "DRC Error : DRPEN is high for more than 1 DRPCLK."
           severity failure;
       end if;
       
       if ((drpwe_r1 = '1') and (drpwe_r2 = '1')) then 
         assert false
           report "DRC Error : DRPWE is high for more than 1 DRPCLK."
           severity failure;
       end if;

       
       -- After the 1st DRPEN pulse, check the DRPEN and DRPRDY.
       case sfsm is
         when FSM_IDLE =>
           if (DRPEN_indelay = '1') then 
             sfsm := FSM_WAIT;
           end if;
           
         when FSM_WAIT =>

           -- After the 1st DRPEN, 4 cases can happen
           -- DRPEN DRPRDY NEXT STATE
           -- 0     0      FSM_WAIT - wait for DRPRDY
           -- 0     1      FSM_IDLE - normal operation
           -- 1     0      FSM_WAIT - display error and wait for DRPRDY
           -- 1     1      FSM_WAIT - normal operation. Per UG470, DRPEN and DRPRDY can be at the same cycle.;                       
           -- Add the check for another DPREN pulse
           if(DRPEN_indelay = '1' and DRPRDY_out = '0') then 
             assert false
               report "DRC Error :  DRPEN is enabled before DRPRDY returns."
               severity failure;
           end if;

           -- Add the check for another DRPWE pulse
           if ((DRPWE_indelay = '1') and (DRPEN_indelay = '0')) then
             assert false
               report "DRC Error :  DRPWE is enabled before DRPRDY returns."
               severity failure;
           end if;
                    
           if ((DRPRDY_out = '1') and (DRPEN_indelay = '0')) then
             sfsm := FSM_IDLE;
           end if;
             
               
           if ((DRPRDY_out = '1') and (DRPEN_indelay = '1')) then
             sfsm := FSM_WAIT;
           end if;


         when others =>
           assert false
             report "DRC Error : Default state in DRP FSM."
             severity failure;

       end case;
    
     end if;

   end process drp_monitor;
      
      
    INIPROC : process
    begin
    case PLL0_FBDIV_45 is
      when  5   =>  PLL0_FBDIV_45_BINARY <= '1';
      when  4   =>  PLL0_FBDIV_45_BINARY <= '0';
      when others  =>  assert FALSE report "Error : PLL0_FBDIV_45 is not in range 4 .. 5." severity error;
    end case;
    case PLL1_FBDIV_45 is
      when  5   =>  PLL1_FBDIV_45_BINARY <= '1';
      when  4   =>  PLL1_FBDIV_45_BINARY <= '0';
      when others  =>  assert FALSE report "Error : PLL1_FBDIV_45 is not in range 4 .. 5." severity error;
    end case;
    if ((PLL0_FBDIV >= 1) and (PLL0_FBDIV <= 20)) then
      PLL0_FBDIV_BINARY <= CONV_STD_LOGIC_VECTOR(PLL0_FBDIV, 6);
    else
      assert FALSE report "Error : PLL0_FBDIV is not in range 1 .. 20." severity error;
    end if;
    if ((PLL0_REFCLK_DIV >= 1) and (PLL0_REFCLK_DIV <= 20)) then
      PLL0_REFCLK_DIV_BINARY <= CONV_STD_LOGIC_VECTOR(PLL0_REFCLK_DIV, 5);
    else
      assert FALSE report "Error : PLL0_REFCLK_DIV is not in range 1 .. 20." severity error;
    end if;
    if ((PLL1_FBDIV >= 1) and (PLL1_FBDIV <= 20)) then
      PLL1_FBDIV_BINARY <= CONV_STD_LOGIC_VECTOR(PLL1_FBDIV, 6);
    else
      assert FALSE report "Error : PLL1_FBDIV is not in range 1 .. 20." severity error;
    end if;
    if ((PLL1_REFCLK_DIV >= 1) and (PLL1_REFCLK_DIV <= 20)) then
      PLL1_REFCLK_DIV_BINARY <= CONV_STD_LOGIC_VECTOR(PLL1_REFCLK_DIV, 5);
    else
      assert FALSE report "Error : PLL1_REFCLK_DIV is not in range 1 .. 20." severity error;
    end if;
    wait;
    end process INIPROC;
    DMONITOROUT <= DMONITOROUT_out;
    DRPDO <= DRPDO_out;
    DRPRDY <= DRPRDY_out;
    PLL0FBCLKLOST <= PLL0FBCLKLOST_out;
    PLL0LOCK <= PLL0LOCK_out;
    PLL0OUTCLK <= PLL0OUTCLK_out;
    PLL0OUTREFCLK <= PLL0OUTREFCLK_out;
    PLL0REFCLKLOST <= PLL0REFCLKLOST_out;
    PLL1FBCLKLOST <= PLL1FBCLKLOST_out;
    PLL1LOCK <= PLL1LOCK_out;
    PLL1OUTCLK <= PLL1OUTCLK_out;
    PLL1OUTREFCLK <= PLL1OUTREFCLK_out;
    PLL1REFCLKLOST <= PLL1REFCLKLOST_out;
    PMARSVDOUT <= PMARSVDOUT_out;
    REFCLKOUTMONITOR0 <= REFCLKOUTMONITOR0_out;
    REFCLKOUTMONITOR1 <= REFCLKOUTMONITOR1_out;
  end GTPE2_COMMON_V;
