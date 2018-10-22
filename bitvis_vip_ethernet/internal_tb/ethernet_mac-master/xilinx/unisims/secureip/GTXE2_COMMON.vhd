-------------------------------------------------------
--  Copyright (c) 2010 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Simulation Library Component
--  /   /                      
-- /___/   /\      Filename    : GTXE2_COMMON.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  11/10/09 - CR - Initial version
--  11/20/09 - CR - Attribute updates in YML
--  04/27/10 - CR - YML update
--  06/17/10 - CR564909 - Complete VHDL support, YML & RTL updates
--  08/05/10 - CR569010 - gtxe2 yml and secureip update
--  09/15/10 - CR575512 - gtxe2 yml and secureip update
--  01/09/11 - CR582278,579504,588137, 591741 - GTXE2 YML/secureip update
--  09/07/11 - CR624062 - YML update
--  06/20/12 - CR666177 - YML update
--  01/22/13 - Added DRP monitor (CR 695630).
-------------------------------------------------------

----- CELL GTXE2_COMMON -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity GTXE2_COMMON is
    generic (
      BIAS_CFG : bit_vector := X"0000040000001000";
      COMMON_CFG : bit_vector := X"00000000";
      QPLL_CFG : bit_vector := X"0680181";
      QPLL_CLKOUT_CFG : bit_vector := "0000";
      QPLL_COARSE_FREQ_OVRD : bit_vector := "010000";
      QPLL_COARSE_FREQ_OVRD_EN : bit := '0';
      QPLL_CP : bit_vector := "0000011111";
      QPLL_CP_MONITOR_EN : bit := '0';
      QPLL_DMONITOR_SEL : bit := '0';
      QPLL_FBDIV : bit_vector := "0000000000";
      QPLL_FBDIV_MONITOR_EN : bit := '0';
      QPLL_FBDIV_RATIO : bit := '0';
      QPLL_INIT_CFG : bit_vector := X"000006";
      QPLL_LOCK_CFG : bit_vector := X"21E8";
      QPLL_LPF : bit_vector := "1111";
      QPLL_REFCLK_DIV : integer := 2;
      SIM_QPLLREFCLK_SEL : bit_vector := "001";
      SIM_RESET_SPEEDUP : string := "TRUE";
      SIM_VERSION : string := "4.0"
    );

    port (
      DRPDO                : out std_logic_vector(15 downto 0);
      DRPRDY               : out std_ulogic;
      QPLLDMONITOR         : out std_logic_vector(7 downto 0);
      QPLLFBCLKLOST        : out std_ulogic;
      QPLLLOCK             : out std_ulogic;
      QPLLOUTCLK           : out std_ulogic;
      QPLLOUTREFCLK        : out std_ulogic;
      QPLLREFCLKLOST       : out std_ulogic;
      REFCLKOUTMONITOR     : out std_ulogic;
      BGBYPASSB            : in std_ulogic;
      BGMONITORENB         : in std_ulogic;
      BGPDB                : in std_ulogic;
      BGRCALOVRD           : in std_logic_vector(4 downto 0);
      DRPADDR              : in std_logic_vector(7 downto 0);
      DRPCLK               : in std_ulogic;
      DRPDI                : in std_logic_vector(15 downto 0);
      DRPEN                : in std_ulogic;
      DRPWE                : in std_ulogic;
      GTGREFCLK            : in std_ulogic;
      GTNORTHREFCLK0       : in std_ulogic;
      GTNORTHREFCLK1       : in std_ulogic;
      GTREFCLK0            : in std_ulogic;
      GTREFCLK1            : in std_ulogic;
      GTSOUTHREFCLK0       : in std_ulogic;
      GTSOUTHREFCLK1       : in std_ulogic;
      PMARSVD              : in std_logic_vector(7 downto 0);
      QPLLLOCKDETCLK       : in std_ulogic;
      QPLLLOCKEN           : in std_ulogic;
      QPLLOUTRESET         : in std_ulogic;
      QPLLPD               : in std_ulogic;
      QPLLREFCLKSEL        : in std_logic_vector(2 downto 0);
      QPLLRESET            : in std_ulogic;
      QPLLRSVD1            : in std_logic_vector(15 downto 0);
      QPLLRSVD2            : in std_logic_vector(4 downto 0);
      RCALENB              : in std_ulogic      
    );
  end GTXE2_COMMON;

  architecture GTXE2_COMMON_V of GTXE2_COMMON is
    component GTXE2_COMMON_WRAP
      generic (
        BIAS_CFG : string;
        COMMON_CFG : string;
        QPLL_CFG : string;
        QPLL_CLKOUT_CFG : string;
        QPLL_COARSE_FREQ_OVRD : string;
        QPLL_COARSE_FREQ_OVRD_EN : string;
        QPLL_CP : string;
        QPLL_CP_MONITOR_EN : string;
        QPLL_DMONITOR_SEL : string;
        QPLL_FBDIV : string;
        QPLL_FBDIV_MONITOR_EN : string;
        QPLL_FBDIV_RATIO : string;
        QPLL_INIT_CFG : string;
        QPLL_LOCK_CFG : string;
        QPLL_LPF : string;
        QPLL_REFCLK_DIV : integer;
        SIM_QPLLREFCLK_SEL : string;
        SIM_RESET_SPEEDUP : string;
        SIM_VERSION : string        
      );
      
      port (
        DRPDO                : out std_logic_vector(15 downto 0);
        DRPRDY               : out std_ulogic;
        QPLLDMONITOR         : out std_logic_vector(7 downto 0);
        QPLLFBCLKLOST        : out std_ulogic;
        QPLLLOCK             : out std_ulogic;
        QPLLOUTCLK           : out std_ulogic;
        QPLLOUTREFCLK        : out std_ulogic;
        QPLLREFCLKLOST       : out std_ulogic;
        REFCLKOUTMONITOR     : out std_ulogic;

        GSR                  : in std_ulogic;
        BGBYPASSB            : in std_ulogic;
        BGMONITORENB         : in std_ulogic;
        BGPDB                : in std_ulogic;
        BGRCALOVRD           : in std_logic_vector(4 downto 0);
        DRPADDR              : in std_logic_vector(7 downto 0);
        DRPCLK               : in std_ulogic;
        DRPDI                : in std_logic_vector(15 downto 0);
        DRPEN                : in std_ulogic;
        DRPWE                : in std_ulogic;
        GTGREFCLK            : in std_ulogic;
        GTNORTHREFCLK0       : in std_ulogic;
        GTNORTHREFCLK1       : in std_ulogic;
        GTREFCLK0            : in std_ulogic;
        GTREFCLK1            : in std_ulogic;
        GTSOUTHREFCLK0       : in std_ulogic;
        GTSOUTHREFCLK1       : in std_ulogic;
        PMARSVD              : in std_logic_vector(7 downto 0);
        QPLLLOCKDETCLK       : in std_ulogic;
        QPLLLOCKEN           : in std_ulogic;
        QPLLOUTRESET         : in std_ulogic;
        QPLLPD               : in std_ulogic;
        QPLLREFCLKSEL        : in std_logic_vector(2 downto 0);
        QPLLRESET            : in std_ulogic;
        QPLLRSVD1            : in std_logic_vector(15 downto 0);
        QPLLRSVD2            : in std_logic_vector(4 downto 0);
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
    constant QPLL_CFG_BINARY : std_logic_vector(26 downto 0) := To_StdLogicVector(QPLL_CFG)(26 downto 0);
    constant QPLL_CLKOUT_CFG_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(QPLL_CLKOUT_CFG)(3 downto 0);
    constant QPLL_COARSE_FREQ_OVRD_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(QPLL_COARSE_FREQ_OVRD)(5 downto 0);
    constant QPLL_COARSE_FREQ_OVRD_EN_BINARY : std_ulogic := To_StduLogic(QPLL_COARSE_FREQ_OVRD_EN);
    constant QPLL_CP_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(QPLL_CP)(9 downto 0);
    constant QPLL_CP_MONITOR_EN_BINARY : std_ulogic := To_StduLogic(QPLL_CP_MONITOR_EN);
    constant QPLL_DMONITOR_SEL_BINARY : std_ulogic := To_StduLogic(QPLL_DMONITOR_SEL);
    constant QPLL_FBDIV_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(QPLL_FBDIV)(9 downto 0);
    constant QPLL_FBDIV_MONITOR_EN_BINARY : std_ulogic := To_StduLogic(QPLL_FBDIV_MONITOR_EN);
    constant QPLL_FBDIV_RATIO_BINARY : std_ulogic := To_StduLogic(QPLL_FBDIV_RATIO);
    constant QPLL_INIT_CFG_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(QPLL_INIT_CFG)(23 downto 0);
    constant QPLL_LOCK_CFG_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(QPLL_LOCK_CFG)(15 downto 0);
    constant QPLL_LPF_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(QPLL_LPF)(3 downto 0);
    constant SIM_QPLLREFCLK_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SIM_QPLLREFCLK_SEL)(2 downto 0);
    
    -- Get String Length
    constant BIAS_CFG_STRLEN : integer := getstrlength(BIAS_CFG_BINARY);
    constant COMMON_CFG_STRLEN : integer := getstrlength(COMMON_CFG_BINARY);
    constant QPLL_CFG_STRLEN : integer := getstrlength(QPLL_CFG_BINARY);
    constant QPLL_INIT_CFG_STRLEN : integer := getstrlength(QPLL_INIT_CFG_BINARY);
    constant QPLL_LOCK_CFG_STRLEN : integer := getstrlength(QPLL_LOCK_CFG_BINARY);
    
    -- Convert std_logic_vector to string
    constant BIAS_CFG_STRING : string := SLV_TO_HEX(BIAS_CFG_BINARY, BIAS_CFG_STRLEN);
    constant COMMON_CFG_STRING : string := SLV_TO_HEX(COMMON_CFG_BINARY, COMMON_CFG_STRLEN);
    constant QPLL_CFG_STRING : string := SLV_TO_HEX(QPLL_CFG_BINARY, QPLL_CFG_STRLEN);
    constant QPLL_CLKOUT_CFG_STRING : string := SLV_TO_STR(QPLL_CLKOUT_CFG_BINARY);
    constant QPLL_COARSE_FREQ_OVRD_EN_STRING : string := SUL_TO_STR(QPLL_COARSE_FREQ_OVRD_EN_BINARY);
    constant QPLL_COARSE_FREQ_OVRD_STRING : string := SLV_TO_STR(QPLL_COARSE_FREQ_OVRD_BINARY);
    constant QPLL_CP_MONITOR_EN_STRING : string := SUL_TO_STR(QPLL_CP_MONITOR_EN_BINARY);
    constant QPLL_CP_STRING : string := SLV_TO_STR(QPLL_CP_BINARY);
    constant QPLL_DMONITOR_SEL_STRING : string := SUL_TO_STR(QPLL_DMONITOR_SEL_BINARY);
    constant QPLL_FBDIV_MONITOR_EN_STRING : string := SUL_TO_STR(QPLL_FBDIV_MONITOR_EN_BINARY);
    constant QPLL_FBDIV_RATIO_STRING : string := SUL_TO_STR(QPLL_FBDIV_RATIO_BINARY);
    constant QPLL_FBDIV_STRING : string := SLV_TO_STR(QPLL_FBDIV_BINARY);
    constant QPLL_INIT_CFG_STRING : string := SLV_TO_HEX(QPLL_INIT_CFG_BINARY, QPLL_INIT_CFG_STRLEN);
    constant QPLL_LOCK_CFG_STRING : string := SLV_TO_HEX(QPLL_LOCK_CFG_BINARY, QPLL_LOCK_CFG_STRLEN);
    constant QPLL_LPF_STRING : string := SLV_TO_STR(QPLL_LPF_BINARY);
    constant SIM_QPLLREFCLK_SEL_STRING : string := SLV_TO_STR(SIM_QPLLREFCLK_SEL_BINARY);
    
    signal QPLL_REFCLK_DIV_BINARY : std_logic_vector(4 downto 0);
    signal SIM_RESET_SPEEDUP_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    
    signal DRPDO_out : std_logic_vector(15 downto 0);
    signal DRPRDY_out : std_ulogic;
    signal QPLLDMONITOR_out : std_logic_vector(7 downto 0);
    signal QPLLFBCLKLOST_out : std_ulogic;
    signal QPLLLOCK_out : std_ulogic;
    signal QPLLOUTCLK_out : std_ulogic;
    signal QPLLOUTREFCLK_out : std_ulogic;
    signal QPLLREFCLKLOST_out : std_ulogic;
    signal REFCLKOUTMONITOR_out : std_ulogic;
    
    signal DRPDO_outdelay : std_logic_vector(15 downto 0);
    signal DRPRDY_outdelay : std_ulogic;
    signal QPLLDMONITOR_outdelay : std_logic_vector(7 downto 0);
    signal QPLLFBCLKLOST_outdelay : std_ulogic;
    signal QPLLLOCK_outdelay : std_ulogic;
    signal QPLLOUTCLK_outdelay : std_ulogic;
    signal QPLLOUTREFCLK_outdelay : std_ulogic;
    signal QPLLREFCLKLOST_outdelay : std_ulogic;
    signal REFCLKOUTMONITOR_outdelay : std_ulogic;
    
    signal BGBYPASSB_ipd : std_ulogic;
    signal BGMONITORENB_ipd : std_ulogic;
    signal BGPDB_ipd : std_ulogic;
    signal BGRCALOVRD_ipd : std_logic_vector(4 downto 0);
    signal DRPADDR_ipd : std_logic_vector(7 downto 0);
    signal DRPCLK_ipd : std_ulogic;
    signal DRPDI_ipd : std_logic_vector(15 downto 0);
    signal DRPEN_ipd : std_ulogic;
    signal DRPWE_ipd : std_ulogic;
    signal GTGREFCLK_ipd : std_ulogic;
    signal GTNORTHREFCLK0_ipd : std_ulogic;
    signal GTNORTHREFCLK1_ipd : std_ulogic;
    signal GTREFCLK0_ipd : std_ulogic;
    signal GTREFCLK1_ipd : std_ulogic;
    signal GTSOUTHREFCLK0_ipd : std_ulogic;
    signal GTSOUTHREFCLK1_ipd : std_ulogic;
    signal PMARSVD_ipd : std_logic_vector(7 downto 0);
    signal QPLLLOCKDETCLK_ipd : std_ulogic;
    signal QPLLLOCKEN_ipd : std_ulogic;
    signal QPLLOUTRESET_ipd : std_ulogic;
    signal QPLLPD_ipd : std_ulogic;
    signal QPLLREFCLKSEL_ipd : std_logic_vector(2 downto 0);
    signal QPLLRESET_ipd : std_ulogic;
    signal QPLLRSVD1_ipd : std_logic_vector(15 downto 0);
    signal QPLLRSVD2_ipd : std_logic_vector(4 downto 0);
    signal RCALENB_ipd : std_ulogic;
    
    signal BGBYPASSB_indelay : std_ulogic;
    signal BGMONITORENB_indelay : std_ulogic;
    signal BGPDB_indelay : std_ulogic;
    signal BGRCALOVRD_indelay : std_logic_vector(4 downto 0);
    signal DRPADDR_indelay : std_logic_vector(7 downto 0);
    signal DRPCLK_indelay : std_ulogic;
    signal DRPDI_indelay : std_logic_vector(15 downto 0);
    signal DRPEN_indelay : std_ulogic;
    signal DRPWE_indelay : std_ulogic;
    signal GTGREFCLK_indelay : std_ulogic;
    signal GTNORTHREFCLK0_indelay : std_ulogic;
    signal GTNORTHREFCLK1_indelay : std_ulogic;
    signal GTREFCLK0_indelay : std_ulogic;
    signal GTREFCLK1_indelay : std_ulogic;
    signal GTSOUTHREFCLK0_indelay : std_ulogic;
    signal GTSOUTHREFCLK1_indelay : std_ulogic;
    signal PMARSVD_indelay : std_logic_vector(7 downto 0);
    signal QPLLLOCKDETCLK_indelay : std_ulogic;
    signal QPLLLOCKEN_indelay : std_ulogic;
    signal QPLLOUTRESET_indelay : std_ulogic;
    signal QPLLPD_indelay : std_ulogic;
    signal QPLLREFCLKSEL_indelay : std_logic_vector(2 downto 0);
    signal QPLLRESET_indelay : std_ulogic;
    signal QPLLRSVD1_indelay : std_logic_vector(15 downto 0);
    signal QPLLRSVD2_indelay : std_logic_vector(4 downto 0);
    signal RCALENB_indelay : std_ulogic;
    
    begin
    QPLLOUTCLK_out <= QPLLOUTCLK_outdelay after OUTCLK_DELAY;
    REFCLKOUTMONITOR_out <= REFCLKOUTMONITOR_outdelay after OUTCLK_DELAY;
    
    DRPDO_out <= DRPDO_outdelay after OUT_DELAY;
    DRPRDY_out <= DRPRDY_outdelay after OUT_DELAY;
    QPLLDMONITOR_out <= QPLLDMONITOR_outdelay after OUT_DELAY;
    QPLLFBCLKLOST_out <= QPLLFBCLKLOST_outdelay after OUT_DELAY;
    QPLLLOCK_out <= QPLLLOCK_outdelay after OUT_DELAY;
    QPLLOUTREFCLK_out <= QPLLOUTREFCLK_outdelay after OUT_DELAY;
    QPLLREFCLKLOST_out <= QPLLREFCLKLOST_outdelay after OUT_DELAY;
    
    DRPCLK_ipd <= DRPCLK;
    GTGREFCLK_ipd <= GTGREFCLK;
    GTNORTHREFCLK0_ipd <= GTNORTHREFCLK0;
    GTNORTHREFCLK1_ipd <= GTNORTHREFCLK1;
    GTREFCLK0_ipd <= GTREFCLK0;
    GTREFCLK1_ipd <= GTREFCLK1;
    GTSOUTHREFCLK0_ipd <= GTSOUTHREFCLK0;
    GTSOUTHREFCLK1_ipd <= GTSOUTHREFCLK1;
    QPLLLOCKDETCLK_ipd <= QPLLLOCKDETCLK;
    
    BGBYPASSB_ipd <= BGBYPASSB;
    BGMONITORENB_ipd <= BGMONITORENB;
    BGPDB_ipd <= BGPDB;
    BGRCALOVRD_ipd <= BGRCALOVRD;
    DRPADDR_ipd <= DRPADDR;
    DRPDI_ipd <= DRPDI;
    DRPEN_ipd <= DRPEN;
    DRPWE_ipd <= DRPWE;
    PMARSVD_ipd <= PMARSVD;
    QPLLLOCKEN_ipd <= QPLLLOCKEN;
    QPLLOUTRESET_ipd <= QPLLOUTRESET;
    QPLLPD_ipd <= QPLLPD;
    QPLLREFCLKSEL_ipd <= QPLLREFCLKSEL;
    QPLLRESET_ipd <= QPLLRESET;
    QPLLRSVD1_ipd <= QPLLRSVD1;
    QPLLRSVD2_ipd <= QPLLRSVD2;
    RCALENB_ipd <= RCALENB;
    
    DRPCLK_indelay <= DRPCLK_ipd after INCLK_DELAY;
    GTGREFCLK_indelay <= GTGREFCLK_ipd after INCLK_DELAY;
    GTNORTHREFCLK0_indelay <= GTNORTHREFCLK0_ipd after INCLK_DELAY;
    GTNORTHREFCLK1_indelay <= GTNORTHREFCLK1_ipd after INCLK_DELAY;
    GTREFCLK0_indelay <= GTREFCLK0_ipd after INCLK_DELAY;
    GTREFCLK1_indelay <= GTREFCLK1_ipd after INCLK_DELAY;
    GTSOUTHREFCLK0_indelay <= GTSOUTHREFCLK0_ipd after INCLK_DELAY;
    GTSOUTHREFCLK1_indelay <= GTSOUTHREFCLK1_ipd after INCLK_DELAY;
    QPLLLOCKDETCLK_indelay <= QPLLLOCKDETCLK_ipd after INCLK_DELAY;
    
    BGBYPASSB_indelay <= BGBYPASSB_ipd after IN_DELAY;
    BGMONITORENB_indelay <= BGMONITORENB_ipd after IN_DELAY;
    BGPDB_indelay <= BGPDB_ipd after IN_DELAY;
    BGRCALOVRD_indelay <= BGRCALOVRD_ipd after IN_DELAY;
    DRPADDR_indelay <= DRPADDR_ipd after IN_DELAY;
    DRPDI_indelay <= DRPDI_ipd after IN_DELAY;
    DRPEN_indelay <= DRPEN_ipd after IN_DELAY;
    DRPWE_indelay <= DRPWE_ipd after IN_DELAY;
    PMARSVD_indelay <= PMARSVD_ipd after IN_DELAY;
    QPLLLOCKEN_indelay <= QPLLLOCKEN_ipd after IN_DELAY;
    QPLLOUTRESET_indelay <= QPLLOUTRESET_ipd after IN_DELAY;
    QPLLPD_indelay <= QPLLPD_ipd after IN_DELAY;
    QPLLREFCLKSEL_indelay <= QPLLREFCLKSEL_ipd after IN_DELAY;
    QPLLRESET_indelay <= QPLLRESET_ipd after IN_DELAY;
    QPLLRSVD1_indelay <= QPLLRSVD1_ipd after IN_DELAY;
    QPLLRSVD2_indelay <= QPLLRSVD2_ipd after IN_DELAY;
    RCALENB_indelay <= RCALENB_ipd after IN_DELAY;
    
    
    GTXE2_COMMON_INST : GTXE2_COMMON_WRAP
      generic map (
        BIAS_CFG             => BIAS_CFG_STRING,
        COMMON_CFG           => COMMON_CFG_STRING,
        QPLL_CFG             => QPLL_CFG_STRING,
        QPLL_CLKOUT_CFG      => QPLL_CLKOUT_CFG_STRING,
        QPLL_COARSE_FREQ_OVRD => QPLL_COARSE_FREQ_OVRD_STRING,
        QPLL_COARSE_FREQ_OVRD_EN => QPLL_COARSE_FREQ_OVRD_EN_STRING,
        QPLL_CP              => QPLL_CP_STRING,
        QPLL_CP_MONITOR_EN   => QPLL_CP_MONITOR_EN_STRING,
        QPLL_DMONITOR_SEL    => QPLL_DMONITOR_SEL_STRING,
        QPLL_FBDIV           => QPLL_FBDIV_STRING,
        QPLL_FBDIV_MONITOR_EN => QPLL_FBDIV_MONITOR_EN_STRING,
        QPLL_FBDIV_RATIO     => QPLL_FBDIV_RATIO_STRING,
        QPLL_INIT_CFG        => QPLL_INIT_CFG_STRING,
        QPLL_LOCK_CFG        => QPLL_LOCK_CFG_STRING,
        QPLL_LPF             => QPLL_LPF_STRING,
        QPLL_REFCLK_DIV      => QPLL_REFCLK_DIV,
        SIM_QPLLREFCLK_SEL   => SIM_QPLLREFCLK_SEL_STRING,
        SIM_RESET_SPEEDUP    => SIM_RESET_SPEEDUP,
        SIM_VERSION          => SIM_VERSION
      )
      
      port map (
        GSR                  => GSR,
        DRPDO                => DRPDO_outdelay,
        DRPRDY               => DRPRDY_outdelay,
        QPLLDMONITOR         => QPLLDMONITOR_outdelay,
        QPLLFBCLKLOST        => QPLLFBCLKLOST_outdelay,
        QPLLLOCK             => QPLLLOCK_outdelay,
        QPLLOUTCLK           => QPLLOUTCLK_outdelay,
        QPLLOUTREFCLK        => QPLLOUTREFCLK_outdelay,
        QPLLREFCLKLOST       => QPLLREFCLKLOST_outdelay,
        REFCLKOUTMONITOR     => REFCLKOUTMONITOR_outdelay,
        BGBYPASSB            => BGBYPASSB_indelay,
        BGMONITORENB         => BGMONITORENB_indelay,
        BGPDB                => BGPDB_indelay,
        BGRCALOVRD           => BGRCALOVRD_indelay,
        DRPADDR              => DRPADDR_indelay,
        DRPCLK               => DRPCLK_indelay,
        DRPDI                => DRPDI_indelay,
        DRPEN                => DRPEN_indelay,
        DRPWE                => DRPWE_indelay,
        GTGREFCLK            => GTGREFCLK_indelay,
        GTNORTHREFCLK0       => GTNORTHREFCLK0_indelay,
        GTNORTHREFCLK1       => GTNORTHREFCLK1_indelay,
        GTREFCLK0            => GTREFCLK0_indelay,
        GTREFCLK1            => GTREFCLK1_indelay,
        GTSOUTHREFCLK0       => GTSOUTHREFCLK0_indelay,
        GTSOUTHREFCLK1       => GTSOUTHREFCLK1_indelay,
        PMARSVD              => PMARSVD_indelay,
        QPLLLOCKDETCLK       => QPLLLOCKDETCLK_indelay,
        QPLLLOCKEN           => QPLLLOCKEN_indelay,
        QPLLOUTRESET         => QPLLOUTRESET_indelay,
        QPLLPD               => QPLLPD_indelay,
        QPLLREFCLKSEL        => QPLLREFCLKSEL_indelay,
        QPLLRESET            => QPLLRESET_indelay,
        QPLLRSVD1            => QPLLRSVD1_indelay,
        QPLLRSVD2            => QPLLRSVD2_indelay,
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
    if ((QPLL_REFCLK_DIV >= 1) and (QPLL_REFCLK_DIV <= 20)) then
      QPLL_REFCLK_DIV_BINARY <= CONV_STD_LOGIC_VECTOR(QPLL_REFCLK_DIV, 5);
    else
      assert FALSE report "Error : QPLL_REFCLK_DIV is not in range 1 .. 20." severity error;
    end if;
    wait;
    end process INIPROC;
    DRPDO <= DRPDO_out;
    DRPRDY <= DRPRDY_out;
    QPLLDMONITOR <= QPLLDMONITOR_out;
    QPLLFBCLKLOST <= QPLLFBCLKLOST_out;
    QPLLLOCK <= QPLLLOCK_out;
    QPLLOUTCLK <= QPLLOUTCLK_out;
    QPLLOUTREFCLK <= QPLLOUTREFCLK_out;
    QPLLREFCLKLOST <= QPLLREFCLKLOST_out;
    REFCLKOUTMONITOR <= REFCLKOUTMONITOR_out;
  end GTXE2_COMMON_V;
