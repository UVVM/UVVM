-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/SMODEL/PHASER_IN_PHY.vhd,v 1.19 2012/10/16 15:57:56 robh Exp $
-------------------------------------------------------
--  Copyright (c) 2010 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                        Fujisan PHASER IN
-- /___/   /\      Filename    : PHASER_IN_PHY.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: Comment:
--  08MAR2010 Initial UNI/SIM version from yaml
--  12JUL2010 enable secureip
--  14SEP2010 yaml, rtl update
--  24SEP2010 yaml, rtl update
--  13OCT2010 yaml, rtl update
--  26OCT2010 rtl update
--  02NOV2010 yaml update
--  05NOV2010 secureip parameter name update
--  01DEC2010 yaml update, REFCLK_PERIOD max
--  09DEC2010 586079 yaml update, tie off defaults
--  20DEC2010 587097 yaml update, OUTPUT_CLK_SRC
--  02FEB2011 592485 yaml, rtl update
--  02JUN2011 610011 rtl update, ADD REFCLK_PERIOD parameter
--  27JUL2011 618669 REFCLK_PERIOD = 0 not allowed
--  15AUG2011 621681 yaml update, remove SIM_SPEEDUP make default
--  01DEC2011 635710 yaml update SEL_CLK_OFFSET = 0 per model alert
--  01MAR2012 637179 (and others) RTL update, TEST_OPT split apart
--  22MAY2012 660507 DQS_AUTO_RECAL default value change
--  10JUL2012 669266 Make DQS_AUTO_RECAL and DQS_FIND_PATTERN visible
-------------------------------------------------------

----- CELL PHASER_IN_PHY -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity PHASER_IN_PHY is
    generic (
      BURST_MODE : string := "FALSE";
      CLKOUT_DIV : integer := 4;
      DQS_AUTO_RECAL : bit := '1';
      DQS_BIAS_MODE : string := "FALSE";
      DQS_FIND_PATTERN : bit_vector := "001";
      FINE_DELAY : integer := 0;
      FREQ_REF_DIV : string := "NONE";
      MEMREFCLK_PERIOD : real := 0.000;
      OUTPUT_CLK_SRC : string := "PHASE_REF";
      PHASEREFCLK_PERIOD : real := 0.000;
      REFCLK_PERIOD : real := 0.000;
      SEL_CLK_OFFSET : integer := 5;
      SYNC_IN_DIV_RST : string := "FALSE";
      WR_CYCLES : string := "FALSE"
    );

    port (
      COUNTERREADVAL       : out std_logic_vector(5 downto 0);
      DQSFOUND             : out std_ulogic;
      DQSOUTOFRANGE        : out std_ulogic;
      FINEOVERFLOW         : out std_ulogic;
      ICLK                 : out std_ulogic;
      ICLKDIV              : out std_ulogic;
      ISERDESRST           : out std_ulogic;
      PHASELOCKED          : out std_ulogic;
      RCLK                 : out std_ulogic;
      WRENABLE             : out std_ulogic;
      BURSTPENDINGPHY      : in std_ulogic;
      COUNTERLOADEN        : in std_ulogic;
      COUNTERLOADVAL       : in std_logic_vector(5 downto 0);
      COUNTERREADEN        : in std_ulogic;
      ENCALIBPHY           : in std_logic_vector(1 downto 0);
      FINEENABLE           : in std_ulogic;
      FINEINC              : in std_ulogic;
      FREQREFCLK           : in std_ulogic;
      MEMREFCLK            : in std_ulogic;
      PHASEREFCLK          : in std_ulogic;
      RANKSELPHY           : in std_logic_vector(1 downto 0);
      RST                  : in std_ulogic;
      RSTDQSFIND           : in std_ulogic;
      SYNCIN               : in std_ulogic;
      SYSCLK               : in std_ulogic      
    );
  end PHASER_IN_PHY;

  architecture PHASER_IN_PHY_V of PHASER_IN_PHY is
    component SIP_PHASER_IN
      generic (
        REFCLK_PERIOD : in real
      );
      port (
        BURST_MODE : in std_ulogic;
        CALIB_EDGE_IN_INV : in std_ulogic;
        CLKOUT_DIV : in std_logic_vector(3 downto 0);
        CLKOUT_DIV_ST : in std_logic_vector(3 downto 0);
        CTL_MODE : in std_ulogic;
        DQS_AUTO_RECAL : in std_ulogic;
        DQS_BIAS_MODE : in std_ulogic;
        DQS_FIND_PATTERN : in std_logic_vector(2 downto 0);
        EN_ISERDES_RST : in std_ulogic;
        EN_TEST_RING : in std_ulogic;
        FINE_DELAY : in std_logic_vector(5 downto 0);
        FREQ_REF_DIV : in std_logic_vector(1 downto 0);
        GATE_SET_CLK_MUX : in std_ulogic;
        HALF_CYCLE_ADJ : in std_ulogic;
        ICLK_TO_RCLK_BYPASS : in std_ulogic;
        OUTPUT_CLK_SRC : in std_logic_vector(3 downto 0);
        PD_REVERSE : in std_logic_vector(2 downto 0);
        PHASER_IN_EN : in std_ulogic;
        RD_ADDR_INIT : in std_logic_vector(1 downto 0);
        REG_OPT_1 : in std_ulogic;
        REG_OPT_2 : in std_ulogic;
        REG_OPT_4 : in std_ulogic;
        RST_SEL : in std_ulogic;
        SEL_CLK_OFFSET : in std_logic_vector(2 downto 0);
        SEL_OUT : in std_ulogic;
        STG1_PD_UPDATE : in std_logic_vector(2 downto 0);
        SYNC_IN_DIV_RST : in std_ulogic;
        TEST_BP : in std_ulogic;
        UPDATE_NONACTIVE : in std_ulogic;
        WR_CYCLES : in std_ulogic;

        CLKOUT_DIV_POS : in std_logic_vector(3 downto 0);
      
        COUNTERREADVAL       : out std_logic_vector(5 downto 0);
        DQSFOUND             : out std_ulogic;
        DQSOUTOFRANGE        : out std_ulogic;
        FINEOVERFLOW         : out std_ulogic;
        ICLK                 : out std_ulogic;
        ICLKDIV              : out std_ulogic;
        ISERDESRST           : out std_ulogic;
        PHASELOCKED          : out std_ulogic;
        RCLK                 : out std_ulogic;
        SCANOUT              : out std_ulogic;
        STG1OVERFLOW         : out std_ulogic;
        STG1REGR             : out std_logic_vector(8 downto 0);
        TESTOUT              : out std_logic_vector(3 downto 0);
        WRENABLE             : out std_ulogic;
        BURSTPENDING         : in std_ulogic;
        BURSTPENDINGPHY      : in std_ulogic;
        COUNTERLOADEN        : in std_ulogic;
        COUNTERLOADVAL       : in std_logic_vector(5 downto 0);
        COUNTERREADEN        : in std_ulogic;
        DIVIDERST            : in std_ulogic;
        EDGEADV              : in std_ulogic;
        ENCALIB              : in std_logic_vector(1 downto 0);
        ENCALIBPHY           : in std_logic_vector(1 downto 0);
        ENSTG1               : in std_ulogic;
        ENSTG1ADJUSTB        : in std_ulogic;
        FINEENABLE           : in std_ulogic;
        FINEINC              : in std_ulogic;
        FREQREFCLK           : in std_ulogic;
        MEMREFCLK            : in std_ulogic;
        PHASEREFCLK          : in std_ulogic;
        RANKSEL              : in std_logic_vector(1 downto 0);
        RANKSELPHY           : in std_logic_vector(1 downto 0);
        RST                  : in std_ulogic;
        RSTDQSFIND           : in std_ulogic;
        SCANCLK              : in std_ulogic;
        SCANENB              : in std_ulogic;
        SCANIN               : in std_ulogic;
        SCANMODEB            : in std_ulogic;
        SELCALORSTG1         : in std_ulogic;
        STG1INCDEC           : in std_ulogic;
        STG1LOAD             : in std_ulogic;
        STG1READ             : in std_ulogic;
        STG1REGL             : in std_logic_vector(8 downto 0);
        SYNCIN               : in std_ulogic;
        SYSCLK               : in std_ulogic;
        TESTIN               : in std_logic_vector(13 downto 0);
        GSR                  : in std_ulogic
      );
    end component;
    
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    constant MODULE_NAME : string  := "PHASER_IN_PHY";
    constant CALIB_EDGE_IN_INV_BINARY : std_ulogic := '0';
    constant CLKOUT_DIV_ST_BINARY : std_logic_vector(3 downto 0) := "0000";
    constant GATE_SET_CLK_MUX_BINARY : std_ulogic := '0';
    constant RD_ADDR_INIT_BINARY : std_logic_vector(1 downto 0) := "00";
    constant REG_OPT_1_BINARY : std_ulogic := '0';
    constant REG_OPT_2_BINARY : std_ulogic := '0';
    constant REG_OPT_4_BINARY : std_ulogic := '0';
    constant RST_SEL_BINARY : std_ulogic := '0';
    constant SEL_OUT_BINARY : std_ulogic := '0';
    constant TEST_BP_BINARY : std_ulogic := '0';
    constant DQS_AUTO_RECAL_BINARY : std_ulogic := To_StduLogic(DQS_AUTO_RECAL);
    constant DQS_FIND_PATTERN_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(DQS_FIND_PATTERN)(2 downto 0);
    signal BURST_MODE_BINARY : std_ulogic;
    signal CLKOUT_DIV_BINARY : std_logic_vector(3 downto 0);
    signal CLKOUT_DIV_POS_BINARY : std_logic_vector(3 downto 0);
    signal CTL_MODE_BINARY : std_ulogic;
    signal DQS_BIAS_MODE_BINARY : std_ulogic;
    signal EN_ISERDES_RST_BINARY : std_ulogic;
    signal EN_TEST_RING_BINARY : std_ulogic;
    signal FINE_DELAY_BINARY : std_logic_vector(5 downto 0);
    signal FREQ_REF_DIV_BINARY : std_logic_vector(1 downto 0);
    signal HALF_CYCLE_ADJ_BINARY : std_ulogic;
    signal ICLK_TO_RCLK_BYPASS_BINARY : std_ulogic;
    signal MEMREFCLK_PERIOD_BINARY : std_ulogic;
    signal OUTPUT_CLK_SRC_BINARY : std_logic_vector(3 downto 0);
    signal PD_REVERSE_BINARY : std_logic_vector(2 downto 0);
    signal PHASEREFCLK_PERIOD_BINARY : std_ulogic;
    signal PHASER_IN_EN_BINARY : std_ulogic;
    signal REFCLK_PERIOD_BINARY : std_ulogic;
    signal SEL_CLK_OFFSET_BINARY : std_logic_vector(2 downto 0);
    signal STG1_PD_UPDATE_BINARY : std_logic_vector(2 downto 0);
    signal SYNC_IN_DIV_RST_BINARY : std_ulogic;
    signal UPDATE_NONACTIVE_BINARY : std_ulogic;
    signal WR_CYCLES_BINARY : std_ulogic;
    
    signal COUNTERREADVAL_out : std_logic_vector(5 downto 0);
    signal DQSFOUND_out : std_ulogic;
    signal DQSOUTOFRANGE_out : std_ulogic;
    signal FINEOVERFLOW_out : std_ulogic;
    signal ICLKDIV_out : std_ulogic;
    signal ICLK_out : std_ulogic;
    signal ISERDESRST_out : std_ulogic;
    signal PHASELOCKED_out : std_ulogic;
    signal RCLK_out : std_ulogic;
    signal WRENABLE_out : std_ulogic;
    
    signal COUNTERREADVAL_outdelay : std_logic_vector(5 downto 0);
    signal DQSFOUND_outdelay : std_ulogic;
    signal DQSOUTOFRANGE_outdelay : std_ulogic;
    signal FINEOVERFLOW_outdelay : std_ulogic;
    signal ICLKDIV_outdelay : std_ulogic;
    signal ICLK_outdelay : std_ulogic;
    signal ISERDESRST_outdelay : std_ulogic;
    signal PHASELOCKED_outdelay : std_ulogic;
    signal RCLK_outdelay : std_ulogic;
    signal SCANOUT_outdelay : std_ulogic;
    signal STG1OVERFLOW_outdelay : std_ulogic;
    signal STG1REGR_outdelay : std_logic_vector(8 downto 0);
    signal TESTOUT_outdelay : std_logic_vector(3 downto 0);
    signal WRENABLE_outdelay : std_ulogic;
    
    signal BURSTPENDINGPHY_in : std_ulogic;
    signal COUNTERLOADEN_in : std_ulogic;
    signal COUNTERLOADVAL_in : std_logic_vector(5 downto 0);
    signal COUNTERREADEN_in : std_ulogic;
    signal ENCALIBPHY_in : std_logic_vector(1 downto 0);
    signal FINEENABLE_in : std_ulogic;
    signal FINEINC_in : std_ulogic;
    signal FREQREFCLK_in : std_ulogic;
    signal MEMREFCLK_in : std_ulogic;
    signal PHASEREFCLK_in : std_ulogic;
    signal RANKSELPHY_in : std_logic_vector(1 downto 0);
    signal RSTDQSFIND_in : std_ulogic;
    signal RST_in : std_ulogic;
    signal SYNCIN_in : std_ulogic;
    signal SYSCLK_in : std_ulogic;
    
    signal BURSTPENDINGPHY_indelay : std_ulogic;
    signal BURSTPENDING_indelay : std_ulogic := '1';
    signal COUNTERLOADEN_indelay : std_ulogic;
    signal COUNTERLOADVAL_indelay : std_logic_vector(5 downto 0);
    signal COUNTERREADEN_indelay : std_ulogic;
    signal DIVIDERST_indelay : std_ulogic := '0';
    signal EDGEADV_indelay : std_ulogic := '0';
    signal ENCALIBPHY_indelay : std_logic_vector(1 downto 0);
    signal ENCALIB_indelay : std_logic_vector(1 downto 0) := "11";
    signal ENSTG1ADJUSTB_indelay : std_ulogic := '1';
    signal ENSTG1_indelay : std_ulogic := '0';
    signal FINEENABLE_indelay : std_ulogic;
    signal FINEINC_indelay : std_ulogic;
    signal FREQREFCLK_indelay : std_ulogic;
    signal MEMREFCLK_indelay : std_ulogic;
    signal PHASEREFCLK_indelay : std_ulogic;
    signal RANKSELPHY_indelay : std_logic_vector(1 downto 0);
    signal RANKSEL_indelay : std_logic_vector(1 downto 0) := "00";
    signal RSTDQSFIND_indelay : std_ulogic;
    signal RST_indelay : std_ulogic;
    signal SCANCLK_indelay : std_ulogic := '1';
    signal SCANENB_indelay : std_ulogic := '1';
    signal SCANIN_indelay : std_ulogic := '1';
    signal SCANMODEB_indelay : std_ulogic := '1';
    signal SELCALORSTG1_indelay : std_ulogic := '1';
    signal STG1INCDEC_indelay : std_ulogic := '1';
    signal STG1LOAD_indelay : std_ulogic := '1';
    signal STG1READ_indelay : std_ulogic := '1';
    signal STG1REGL_indelay : std_logic_vector(8 downto 0) := "111111111";
    signal SYNCIN_indelay : std_ulogic;
    signal SYSCLK_indelay : std_ulogic;
    signal TESTIN_indelay : std_logic_vector(13 downto 0) := "11111111111111";
    signal GSR_indelay : std_ulogic := '0';
    
    begin
    ICLKDIV_out <= ICLKDIV_outdelay after OUTCLK_DELAY;
    ICLK_out <= ICLK_outdelay after OUTCLK_DELAY;
    RCLK_out <= RCLK_outdelay after OUTCLK_DELAY;
    
    COUNTERREADVAL_out <= COUNTERREADVAL_outdelay after OUT_DELAY;
    DQSFOUND_out <= DQSFOUND_outdelay after OUT_DELAY;
    DQSOUTOFRANGE_out <= DQSOUTOFRANGE_outdelay after OUT_DELAY;
    FINEOVERFLOW_out <= FINEOVERFLOW_outdelay after OUT_DELAY;
    ISERDESRST_out <= ISERDESRST_outdelay after OUT_DELAY;
    PHASELOCKED_out <= PHASELOCKED_outdelay after OUT_DELAY;
    WRENABLE_out <= WRENABLE_outdelay after OUT_DELAY;
    
    SYSCLK_in <= SYSCLK;
    
    BURSTPENDINGPHY_in <= BURSTPENDINGPHY;
    COUNTERLOADEN_in <= COUNTERLOADEN;
    COUNTERLOADVAL_in <= COUNTERLOADVAL;
    COUNTERREADEN_in <= COUNTERREADEN;
    ENCALIBPHY_in <= ENCALIBPHY;
    FINEENABLE_in <= FINEENABLE;
    FINEINC_in <= FINEINC;
    FREQREFCLK_in <= FREQREFCLK;
    MEMREFCLK_in <= MEMREFCLK;
    PHASEREFCLK_in <= PHASEREFCLK;
    RANKSELPHY_in <= RANKSELPHY;
    RSTDQSFIND_in <= RSTDQSFIND;
    RST_in <= RST;
    SYNCIN_in <= SYNCIN;
    
    SYSCLK_indelay <= SYSCLK_in after INCLK_DELAY;
    
    BURSTPENDINGPHY_indelay <= BURSTPENDINGPHY_in after IN_DELAY;
    COUNTERLOADEN_indelay <= COUNTERLOADEN_in after IN_DELAY;
    COUNTERLOADVAL_indelay <= COUNTERLOADVAL_in after IN_DELAY;
    COUNTERREADEN_indelay <= COUNTERREADEN_in after IN_DELAY;
    ENCALIBPHY_indelay <= ENCALIBPHY_in after IN_DELAY;
    FINEENABLE_indelay <= FINEENABLE_in after IN_DELAY;
    FINEINC_indelay <= FINEINC_in after IN_DELAY;
    FREQREFCLK_indelay <= FREQREFCLK_in after IN_DELAY;
    MEMREFCLK_indelay <= MEMREFCLK_in after IN_DELAY;
    PHASEREFCLK_indelay <= PHASEREFCLK_in after IN_DELAY;
    RANKSELPHY_indelay <= RANKSELPHY_in after IN_DELAY;
    RSTDQSFIND_indelay <= RSTDQSFIND_in after IN_DELAY;
    RST_indelay <= RST_in after IN_DELAY;
    SYNCIN_indelay <= SYNCIN_in after IN_DELAY;
    GSR_indelay <= GSR after IN_DELAY;
    
    
    PHASER_IN_INST : SIP_PHASER_IN
      generic map (
        REFCLK_PERIOD        => REFCLK_PERIOD
      )
      port map (
        BURST_MODE           => BURST_MODE_BINARY,
        CALIB_EDGE_IN_INV    => CALIB_EDGE_IN_INV_BINARY,
        CLKOUT_DIV           => CLKOUT_DIV_BINARY,
        CLKOUT_DIV_ST        => CLKOUT_DIV_ST_BINARY,
        CTL_MODE             => CTL_MODE_BINARY,
        DQS_AUTO_RECAL       => DQS_AUTO_RECAL_BINARY,
        DQS_BIAS_MODE        => DQS_BIAS_MODE_BINARY,
        DQS_FIND_PATTERN     => DQS_FIND_PATTERN_BINARY,
        EN_ISERDES_RST       => EN_ISERDES_RST_BINARY,
        EN_TEST_RING         => EN_TEST_RING_BINARY,
        FINE_DELAY           => FINE_DELAY_BINARY,
        FREQ_REF_DIV         => FREQ_REF_DIV_BINARY,
        GATE_SET_CLK_MUX     => GATE_SET_CLK_MUX_BINARY,
        HALF_CYCLE_ADJ       => HALF_CYCLE_ADJ_BINARY,
        ICLK_TO_RCLK_BYPASS  => ICLK_TO_RCLK_BYPASS_BINARY,
        OUTPUT_CLK_SRC       => OUTPUT_CLK_SRC_BINARY,
        PD_REVERSE           => PD_REVERSE_BINARY,
        PHASER_IN_EN         => PHASER_IN_EN_BINARY,
        RD_ADDR_INIT         => RD_ADDR_INIT_BINARY,
        REG_OPT_1            => REG_OPT_1_BINARY,
        REG_OPT_2            => REG_OPT_2_BINARY,
        REG_OPT_4            => REG_OPT_4_BINARY,
        RST_SEL              => RST_SEL_BINARY,
        SEL_CLK_OFFSET       => SEL_CLK_OFFSET_BINARY,
        SEL_OUT              => SEL_OUT_BINARY,
        STG1_PD_UPDATE       => STG1_PD_UPDATE_BINARY,
        SYNC_IN_DIV_RST      => SYNC_IN_DIV_RST_BINARY,
        TEST_BP              => TEST_BP_BINARY,
        UPDATE_NONACTIVE     => UPDATE_NONACTIVE_BINARY,
        WR_CYCLES            => WR_CYCLES_BINARY,
      
        CLKOUT_DIV_POS       => CLKOUT_DIV_POS_BINARY,

        COUNTERREADVAL       => COUNTERREADVAL_outdelay,
        DQSFOUND             => DQSFOUND_outdelay,
        DQSOUTOFRANGE        => DQSOUTOFRANGE_outdelay,
        FINEOVERFLOW         => FINEOVERFLOW_outdelay,
        ICLK                 => ICLK_outdelay,
        ICLKDIV              => ICLKDIV_outdelay,
        ISERDESRST           => ISERDESRST_outdelay,
        PHASELOCKED          => PHASELOCKED_outdelay,
        RCLK                 => RCLK_outdelay,
        SCANOUT              => SCANOUT_outdelay,
        STG1OVERFLOW         => STG1OVERFLOW_outdelay,
        STG1REGR             => STG1REGR_outdelay,
        TESTOUT              => TESTOUT_outdelay,
        WRENABLE             => WRENABLE_outdelay,
        BURSTPENDING         => BURSTPENDING_indelay,
        BURSTPENDINGPHY      => BURSTPENDINGPHY_indelay,
        COUNTERLOADEN        => COUNTERLOADEN_indelay,
        COUNTERLOADVAL       => COUNTERLOADVAL_indelay,
        COUNTERREADEN        => COUNTERREADEN_indelay,
        DIVIDERST            => DIVIDERST_indelay,
        EDGEADV              => EDGEADV_indelay,
        ENCALIB              => ENCALIB_indelay,
        ENCALIBPHY           => ENCALIBPHY_indelay,
        ENSTG1               => ENSTG1_indelay,
        ENSTG1ADJUSTB        => ENSTG1ADJUSTB_indelay,
        FINEENABLE           => FINEENABLE_indelay,
        FINEINC              => FINEINC_indelay,
        FREQREFCLK           => FREQREFCLK_indelay,
        MEMREFCLK            => MEMREFCLK_indelay,
        PHASEREFCLK          => PHASEREFCLK_indelay,
        RANKSEL              => RANKSEL_indelay,
        RANKSELPHY           => RANKSELPHY_indelay,
        RST                  => RST_indelay,
        RSTDQSFIND           => RSTDQSFIND_indelay,
        SCANCLK              => SCANCLK_indelay,
        SCANENB              => SCANENB_indelay,
        SCANIN               => SCANIN_indelay,
        SCANMODEB            => SCANMODEB_indelay,
        SELCALORSTG1         => SELCALORSTG1_indelay,
        STG1INCDEC           => STG1INCDEC_indelay,
        STG1LOAD             => STG1LOAD_indelay,
        STG1READ             => STG1READ_indelay,
        STG1REGL             => STG1REGL_indelay,
        SYNCIN               => SYNCIN_indelay,
        SYSCLK               => SYSCLK_indelay,
        TESTIN               => TESTIN_indelay,
        GSR                  => GSR_indelay        
      );
    
    INIPROC : process
    begin
    -- case BURST_MODE is
      if((BURST_MODE = "FALSE") or (BURST_MODE = "false")) then
        BURST_MODE_BINARY <= '0';
      elsif((BURST_MODE = "TRUE") or (BURST_MODE = "true")) then
        BURST_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : BURST_MODE is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    CTL_MODE_BINARY <= '1'; -- model alert
    -- case DQS_BIAS_MODE is
      if((DQS_BIAS_MODE = "FALSE") or (DQS_BIAS_MODE = "false")) then
        DQS_BIAS_MODE_BINARY <= '0';
      elsif((DQS_BIAS_MODE = "TRUE") or (DQS_BIAS_MODE = "true")) then
        DQS_BIAS_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : DQS_BIAS_MODE is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    EN_ISERDES_RST_BINARY <= '0';
    EN_TEST_RING_BINARY <= '0';
    -- case FREQ_REF_DIV is
      if((FREQ_REF_DIV = "NONE") or (FREQ_REF_DIV = "none")) then
        FREQ_REF_DIV_BINARY <= "00";
      elsif((FREQ_REF_DIV = "DIV2") or (FREQ_REF_DIV = "div2")) then
        FREQ_REF_DIV_BINARY <= "01";
      else
        assert FALSE report "Error : FREQ_REF_DIV is not NONE, DIV2." severity error;
      end if;
    -- end case;
    HALF_CYCLE_ADJ_BINARY <= '0';
    ICLK_TO_RCLK_BYPASS_BINARY <= '1';
    -- case OUTPUT_CLK_SRC is
      if((OUTPUT_CLK_SRC = "PHASE_REF") or (OUTPUT_CLK_SRC = "phase_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "0000";
      elsif((OUTPUT_CLK_SRC = "DELAYED_MEM_REF") or (OUTPUT_CLK_SRC = "delayed_mem_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "0101";
      elsif((OUTPUT_CLK_SRC = "DELAYED_PHASE_REF") or (OUTPUT_CLK_SRC = "delayed_phase_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "0011";
      elsif((OUTPUT_CLK_SRC = "DELAYED_REF") or (OUTPUT_CLK_SRC = "delayed_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "0001";
      elsif((OUTPUT_CLK_SRC = "FREQ_REF") or (OUTPUT_CLK_SRC = "freq_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "1000";
      elsif((OUTPUT_CLK_SRC = "MEM_REF") or (OUTPUT_CLK_SRC = "mem_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "0010";
      else
        assert FALSE report "Error : OUTPUT_CLK_SRC is not PHASE_REF, DELAYED_MEM_REF, DELAYED_PHASE_REF, DELAYED_REF, FREQ_REF or MEM_REF." severity error;
      end if;
    -- end case;
    PHASER_IN_EN_BINARY <= '1';
    -- case SYNC_IN_DIV_RST is
      if((SYNC_IN_DIV_RST = "FALSE") or (SYNC_IN_DIV_RST = "false")) then
        SYNC_IN_DIV_RST_BINARY <= '0';
      elsif((SYNC_IN_DIV_RST = "TRUE") or (SYNC_IN_DIV_RST = "true")) then
        SYNC_IN_DIV_RST_BINARY <= '1';
      else
        assert FALSE report "Error : SYNC_IN_DIV_RST is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    UPDATE_NONACTIVE_BINARY <= '0';
    -- case WR_CYCLES is
      if((WR_CYCLES = "FALSE") or (WR_CYCLES = "false")) then
        WR_CYCLES_BINARY <= '0';
      elsif((WR_CYCLES = "TRUE") or (WR_CYCLES = "true")) then
        WR_CYCLES_BINARY <= '1';
      else
        assert FALSE report "Error : WR_CYCLES is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    if ((MEMREFCLK_PERIOD > 0.000) and (MEMREFCLK_PERIOD <= 5.000)) then
      MEMREFCLK_PERIOD_BINARY <= '1';
    else
      assert FALSE report "Error : MEMREFCLK_PERIOD (" & real'Image(MEMREFCLK_PERIOD) & ") is not greater than 0.000 and less than or equal to 5.000." severity error;
    end if;
    if ((PHASEREFCLK_PERIOD > 0.000) and (PHASEREFCLK_PERIOD <= 5.000)) then
      PHASEREFCLK_PERIOD_BINARY <= '1';
    else
      assert FALSE report "Error : PHASEREFCLK_PERIOD (" & real'Image(PHASEREFCLK_PERIOD) & ") is not greater than 0.000 and less than or equal to 5.000." severity error;
    end if;
    if ((REFCLK_PERIOD > 0.000) and (REFCLK_PERIOD <= 2.500)) then
      REFCLK_PERIOD_BINARY <= '1';
    else
      assert FALSE report "Error : REFCLK_PERIOD (" & real'Image(REFCLK_PERIOD) & ") is not greater than 0.000 and less than or equal to 2.500." severity error;
    end if;
    if ((CLKOUT_DIV >= 2) and (CLKOUT_DIV <= 16)) then
      CLKOUT_DIV_BINARY <= STD_LOGIC_VECTOR(TO_UNSIGNED(CLKOUT_DIV-2, 4));
    else
      assert FALSE report "Error : CLKOUT_DIV is not in range 2 .. 16." severity error;
    end if;
   case CLKOUT_DIV is
      when    2    =>  CLKOUT_DIV_POS_BINARY <= "0001";
      when    3    =>  CLKOUT_DIV_POS_BINARY <= "0001";
      when    4    =>  CLKOUT_DIV_POS_BINARY <= "0010";
      when    5    =>  CLKOUT_DIV_POS_BINARY <= "0010";
      when    6    =>  CLKOUT_DIV_POS_BINARY <= "0011";
      when    7    =>  CLKOUT_DIV_POS_BINARY <= "0011";
      when    8    =>  CLKOUT_DIV_POS_BINARY <= "0100";
      when    9    =>  CLKOUT_DIV_POS_BINARY <= "0100";
      when   10    =>  CLKOUT_DIV_POS_BINARY <= "0101";
      when   11    =>  CLKOUT_DIV_POS_BINARY <= "0101";
      when   12    =>  CLKOUT_DIV_POS_BINARY <= "0110";
      when   13    =>  CLKOUT_DIV_POS_BINARY <= "0110";
      when   14    =>  CLKOUT_DIV_POS_BINARY <= "0111";
      when   15    =>  CLKOUT_DIV_POS_BINARY <= "0111";
      when   16    =>  CLKOUT_DIV_POS_BINARY <= "1000";
      when others  =>  CLKOUT_DIV_POS_BINARY <= "0010";
    end case;
    if ((FINE_DELAY >= 0) and (FINE_DELAY <= 63)) then
      FINE_DELAY_BINARY <= STD_LOGIC_VECTOR(TO_UNSIGNED(FINE_DELAY, 6));
    else
      assert FALSE report "Error : FINE_DELAY is not in range 0 .. 63." severity error;
    end if;
    PD_REVERSE_BINARY <= "011";
    if ((SEL_CLK_OFFSET >= 0) and (SEL_CLK_OFFSET <= 7)) then
      SEL_CLK_OFFSET_BINARY <= "000"; -- model alert always 0
    else
      assert FALSE report "Error : SEL_CLK_OFFSET is not in range 0 .. 7." severity error;
    end if;
    STG1_PD_UPDATE_BINARY <= "000";
    wait;
    end process INIPROC;
    COUNTERREADVAL <= COUNTERREADVAL_out;
    DQSFOUND <= DQSFOUND_out;
    DQSOUTOFRANGE <= DQSOUTOFRANGE_out;
    FINEOVERFLOW <= FINEOVERFLOW_out;
    ICLK <= ICLK_out;
    ICLKDIV <= ICLKDIV_out;
    ISERDESRST <= ISERDESRST_out;
    PHASELOCKED <= PHASELOCKED_out;
    RCLK <= RCLK_out;
    WRENABLE <= WRENABLE_out;
  end PHASER_IN_PHY_V;
