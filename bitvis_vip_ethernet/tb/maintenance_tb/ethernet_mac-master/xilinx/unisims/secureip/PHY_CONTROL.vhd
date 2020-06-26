-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/SMODEL/PHY_CONTROL.vhd,v 1.10.202.1 2013/08/06 18:40:37 robh Exp $
-------------------------------------------------------
--  Copyright (c) 2009 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                        Fujisan PHY CONTROL
-- /___/   /\      Filename    : PHY_CONTROL.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Date:     Comment:
--  08MAR2010 Initial UNI/SIM version from yml
--  11JUN2010 yml update
--  02JUL2010 yml update
--  28SEP2010 yml, rtl update
--  29SEP2010 yml update
--  28OCT2010 rtl update
--  05NOV2010 update defaults
--  14FEB2011 593832 yml, rtl update
--  14APR2011 606310 yml update
--  15AUG2011 621681 remove SIM_SPEEDUP, make default
-------------------------------------------------------

----- CELL PHY_CONTROL -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity PHY_CONTROL is
    generic (
      AO_TOGGLE : integer := 0;
      AO_WRLVL_EN : bit_vector := "0000";
      BURST_MODE : string := "FALSE";
      CLK_RATIO : integer := 1;
      CMD_OFFSET : integer := 0;
      CO_DURATION : integer := 0;
      DATA_CTL_A_N : string := "FALSE";
      DATA_CTL_B_N : string := "FALSE";
      DATA_CTL_C_N : string := "FALSE";
      DATA_CTL_D_N : string := "FALSE";
      DISABLE_SEQ_MATCH : string := "TRUE";
      DI_DURATION : integer := 0;
      DO_DURATION : integer := 0;
      EVENTS_DELAY : integer := 63;
      FOUR_WINDOW_CLOCKS : integer := 63;
      MULTI_REGION : string := "FALSE";
      PHY_COUNT_ENABLE : string := "FALSE";
      RD_CMD_OFFSET_0 : integer := 0;
      RD_CMD_OFFSET_1 : integer := 00;
      RD_CMD_OFFSET_2 : integer := 0;
      RD_CMD_OFFSET_3 : integer := 0;
      RD_DURATION_0 : integer := 0;
      RD_DURATION_1 : integer := 0;
      RD_DURATION_2 : integer := 0;
      RD_DURATION_3 : integer := 0;
      SYNC_MODE : string := "FALSE";
      WR_CMD_OFFSET_0 : integer := 0;
      WR_CMD_OFFSET_1 : integer := 0;
      WR_CMD_OFFSET_2 : integer := 0;
      WR_CMD_OFFSET_3 : integer := 0;
      WR_DURATION_0 : integer := 0;
      WR_DURATION_1 : integer := 0;
      WR_DURATION_2 : integer := 0;
      WR_DURATION_3 : integer := 0
    );

    port (
      AUXOUTPUT            : out std_logic_vector(3 downto 0);
      INBURSTPENDING       : out std_logic_vector(3 downto 0);
      INRANKA              : out std_logic_vector(1 downto 0);
      INRANKB              : out std_logic_vector(1 downto 0);
      INRANKC              : out std_logic_vector(1 downto 0);
      INRANKD              : out std_logic_vector(1 downto 0);
      OUTBURSTPENDING      : out std_logic_vector(3 downto 0);
      PCENABLECALIB        : out std_logic_vector(1 downto 0);
      PHYCTLALMOSTFULL     : out std_ulogic;
      PHYCTLEMPTY          : out std_ulogic;
      PHYCTLFULL           : out std_ulogic;
      PHYCTLREADY          : out std_ulogic;
      MEMREFCLK            : in std_ulogic;
      PHYCLK               : in std_ulogic;
      PHYCTLMSTREMPTY      : in std_ulogic;
      PHYCTLWD             : in std_logic_vector(31 downto 0);
      PHYCTLWRENABLE       : in std_ulogic;
      PLLLOCK              : in std_ulogic;
      READCALIBENABLE      : in std_ulogic;
      REFDLLLOCK           : in std_ulogic;
      RESET                : in std_ulogic;
      SYNCIN               : in std_ulogic;
      WRITECALIBENABLE     : in std_ulogic      
    );
  end PHY_CONTROL;

  architecture PHY_CONTROL_V of PHY_CONTROL is
    component SIP_PHY_CONTROL
      port (
        AO_TOGGLE            : in std_logic_vector(3 downto 0);
        AO_WRLVL_EN          : in std_logic_vector(3 downto 0);
        BURST_MODE           : in std_ulogic;
        CLK_RATIO            : in std_logic_vector(2 downto 0);
        CMD_OFFSET           : in std_logic_vector(5 downto 0);
        CO_DURATION          : in std_logic_vector(2 downto 0);
        DATA_CTL_A_N         : in std_ulogic;
        DATA_CTL_B_N         : in std_ulogic;
        DATA_CTL_C_N         : in std_ulogic;
        DATA_CTL_D_N         : in std_ulogic;
        DISABLE_SEQ_MATCH    : in std_ulogic;
        DI_DURATION          : in std_logic_vector(2 downto 0);
        DO_DURATION          : in std_logic_vector(2 downto 0);
        EVENTS_DELAY         : in std_logic_vector(5 downto 0);
        FOUR_WINDOW_CLOCKS   : in std_logic_vector(5 downto 0);
        MULTI_REGION         : in std_ulogic;
        PHY_COUNT_ENABLE     : in std_ulogic;
        RD_CMD_OFFSET_0      : in std_logic_vector(5 downto 0);
        RD_CMD_OFFSET_1      : in std_logic_vector(5 downto 0);
        RD_CMD_OFFSET_2      : in std_logic_vector(5 downto 0);
        RD_CMD_OFFSET_3      : in std_logic_vector(5 downto 0);
        RD_DURATION_0        : in std_logic_vector(5 downto 0);
        RD_DURATION_1        : in std_logic_vector(5 downto 0);
        RD_DURATION_2        : in std_logic_vector(5 downto 0);
        RD_DURATION_3        : in std_logic_vector(5 downto 0);
        SPARE                : in std_ulogic;
        SYNC_MODE            : in std_ulogic;
        WR_CMD_OFFSET_0      : in std_logic_vector(5 downto 0);
        WR_CMD_OFFSET_1      : in std_logic_vector(5 downto 0);
        WR_CMD_OFFSET_2      : in std_logic_vector(5 downto 0);
        WR_CMD_OFFSET_3      : in std_logic_vector(5 downto 0);
        WR_DURATION_0        : in std_logic_vector(5 downto 0);
        WR_DURATION_1        : in std_logic_vector(5 downto 0);
        WR_DURATION_2        : in std_logic_vector(5 downto 0);
        WR_DURATION_3        : in std_logic_vector(5 downto 0);

        AUXOUTPUT            : out std_logic_vector(3 downto 0);
        INBURSTPENDING       : out std_logic_vector(3 downto 0);
        INRANKA              : out std_logic_vector(1 downto 0);
        INRANKB              : out std_logic_vector(1 downto 0);
        INRANKC              : out std_logic_vector(1 downto 0);
        INRANKD              : out std_logic_vector(1 downto 0);
        OUTBURSTPENDING      : out std_logic_vector(3 downto 0);
        PCENABLECALIB        : out std_logic_vector(1 downto 0);
        PHYCTLALMOSTFULL     : out std_ulogic;
        PHYCTLEMPTY          : out std_ulogic;
        PHYCTLFULL           : out std_ulogic;
        PHYCTLREADY          : out std_ulogic;
        TESTOUTPUT           : out std_logic_vector(15 downto 0);
        MEMREFCLK            : in std_ulogic;
        PHYCLK               : in std_ulogic;
        PHYCTLMSTREMPTY      : in std_ulogic;
        PHYCTLWD             : in std_logic_vector(31 downto 0);
        PHYCTLWRENABLE       : in std_ulogic;
        PLLLOCK              : in std_ulogic;
        READCALIBENABLE      : in std_ulogic;
        REFDLLLOCK           : in std_ulogic;
        RESET                : in std_ulogic;
        SCANENABLEN          : in std_ulogic;
        SYNCIN               : in std_ulogic;
        TESTINPUT            : in std_logic_vector(15 downto 0);
        TESTSELECT           : in std_logic_vector(2 downto 0);
        WRITECALIBENABLE     : in std_ulogic;
        GSR                  : in std_ulogic
      );
    end component;
    
    constant IN_DELAY : time := 1 ps;
    constant OUT_DELAY : time := 100 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;
    constant MODULE_NAME : string  := "PHY_CONTROL";

    constant AO_WRLVL_EN_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(AO_WRLVL_EN)(3 downto 0);
    constant SPARE_BINARY : std_ulogic := '0';

    signal AO_TOGGLE_BINARY : std_logic_vector(3 downto 0);
    signal BURST_MODE_BINARY : std_ulogic;
    signal CLK_RATIO_BINARY : std_logic_vector(2 downto 0);
    signal CMD_OFFSET_BINARY : std_logic_vector(5 downto 0);
    signal CO_DURATION_BINARY : std_logic_vector(2 downto 0);
    signal DATA_CTL_A_N_BINARY : std_ulogic;
    signal DATA_CTL_B_N_BINARY : std_ulogic;
    signal DATA_CTL_C_N_BINARY : std_ulogic;
    signal DATA_CTL_D_N_BINARY : std_ulogic;
    signal DISABLE_SEQ_MATCH_BINARY : std_ulogic;
    signal DI_DURATION_BINARY : std_logic_vector(2 downto 0);
    signal DO_DURATION_BINARY : std_logic_vector(2 downto 0);
    signal EVENTS_DELAY_BINARY : std_logic_vector(5 downto 0);
    signal FOUR_WINDOW_CLOCKS_BINARY : std_logic_vector(5 downto 0);
    signal MULTI_REGION_BINARY : std_ulogic;
    signal PHY_COUNT_ENABLE_BINARY : std_ulogic;
    signal RD_CMD_OFFSET_0_BINARY : std_logic_vector(5 downto 0);
    signal RD_CMD_OFFSET_1_BINARY : std_logic_vector(5 downto 0);
    signal RD_CMD_OFFSET_2_BINARY : std_logic_vector(5 downto 0);
    signal RD_CMD_OFFSET_3_BINARY : std_logic_vector(5 downto 0);
    signal RD_DURATION_0_BINARY : std_logic_vector(5 downto 0);
    signal RD_DURATION_1_BINARY : std_logic_vector(5 downto 0);
    signal RD_DURATION_2_BINARY : std_logic_vector(5 downto 0);
    signal RD_DURATION_3_BINARY : std_logic_vector(5 downto 0);
    signal SYNC_MODE_BINARY : std_ulogic;
    signal WR_CMD_OFFSET_0_BINARY : std_logic_vector(5 downto 0);
    signal WR_CMD_OFFSET_1_BINARY : std_logic_vector(5 downto 0);
    signal WR_CMD_OFFSET_2_BINARY : std_logic_vector(5 downto 0);
    signal WR_CMD_OFFSET_3_BINARY : std_logic_vector(5 downto 0);
    signal WR_DURATION_0_BINARY : std_logic_vector(5 downto 0);
    signal WR_DURATION_1_BINARY : std_logic_vector(5 downto 0);
    signal WR_DURATION_2_BINARY : std_logic_vector(5 downto 0);
    signal WR_DURATION_3_BINARY : std_logic_vector(5 downto 0);
    
    signal AUXOUTPUT_out : std_logic_vector(3 downto 0);
    signal INBURSTPENDING_out : std_logic_vector(3 downto 0);
    signal INRANKA_out : std_logic_vector(1 downto 0);
    signal INRANKB_out : std_logic_vector(1 downto 0);
    signal INRANKC_out : std_logic_vector(1 downto 0);
    signal INRANKD_out : std_logic_vector(1 downto 0);
    signal OUTBURSTPENDING_out : std_logic_vector(3 downto 0);
    signal PCENABLECALIB_out : std_logic_vector(1 downto 0);
    signal PHYCTLALMOSTFULL_out : std_ulogic;
    signal PHYCTLEMPTY_out : std_ulogic;
    signal PHYCTLFULL_out : std_ulogic;
    signal PHYCTLREADY_out : std_ulogic;
    
    signal AUXOUTPUT_outdelay : std_logic_vector(3 downto 0);
    signal INBURSTPENDING_outdelay : std_logic_vector(3 downto 0);
    signal INRANKA_outdelay : std_logic_vector(1 downto 0);
    signal INRANKB_outdelay : std_logic_vector(1 downto 0);
    signal INRANKC_outdelay : std_logic_vector(1 downto 0);
    signal INRANKD_outdelay : std_logic_vector(1 downto 0);
    signal OUTBURSTPENDING_outdelay : std_logic_vector(3 downto 0);
    signal PCENABLECALIB_outdelay : std_logic_vector(1 downto 0);
    signal PHYCTLALMOSTFULL_outdelay : std_ulogic;
    signal PHYCTLEMPTY_outdelay : std_ulogic;
    signal PHYCTLFULL_outdelay : std_ulogic;
    signal PHYCTLREADY_outdelay : std_ulogic;
    signal TESTOUTPUT_outdelay : std_logic_vector(15 downto 0);
    
    signal MEMREFCLK_in : std_ulogic;
    signal PHYCLK_in : std_ulogic;
    signal PHYCTLMSTREMPTY_in : std_ulogic;
    signal PHYCTLWD_in : std_logic_vector(31 downto 0);
    signal PHYCTLWRENABLE_in : std_ulogic;
    signal PLLLOCK_in : std_ulogic;
    signal READCALIBENABLE_in : std_ulogic;
    signal REFDLLLOCK_in : std_ulogic;
    signal RESET_in : std_ulogic;
    signal SYNCIN_in : std_ulogic;
    signal WRITECALIBENABLE_in : std_ulogic;
    
    signal MEMREFCLK_indelay : std_ulogic;
    signal PHYCLK_indelay : std_ulogic;
    signal PHYCTLMSTREMPTY_indelay : std_ulogic;
    signal PHYCTLWD_indelay : std_logic_vector(31 downto 0);
    signal PHYCTLWRENABLE_indelay : std_ulogic;
    signal PLLLOCK_indelay : std_ulogic;
    signal READCALIBENABLE_indelay : std_ulogic;
    signal REFDLLLOCK_indelay : std_ulogic;
    signal RESET_indelay : std_ulogic;
    signal SCANENABLEN_indelay : std_ulogic := '1';
    signal SYNCIN_indelay : std_ulogic;
    signal TESTINPUT_indelay : std_logic_vector(15 downto 0) := X"FFFF";
    signal TESTSELECT_indelay : std_logic_vector(2 downto 0) := "111";
    signal WRITECALIBENABLE_indelay : std_ulogic;

    signal GSR_indelay : std_ulogic := '0';
    
    begin
    AUXOUTPUT_out <= AUXOUTPUT_outdelay after OUT_DELAY;
    INBURSTPENDING_out <= INBURSTPENDING_outdelay after OUT_DELAY;
    INRANKA_out <= INRANKA_outdelay after OUT_DELAY;
    INRANKB_out <= INRANKB_outdelay after OUT_DELAY;
    INRANKC_out <= INRANKC_outdelay after OUT_DELAY;
    INRANKD_out <= INRANKD_outdelay after OUT_DELAY;
    OUTBURSTPENDING_out <= OUTBURSTPENDING_outdelay after OUT_DELAY;
    PCENABLECALIB_out <= PCENABLECALIB_outdelay after OUT_DELAY;
    PHYCTLALMOSTFULL_out <= PHYCTLALMOSTFULL_outdelay after OUT_DELAY;
    PHYCTLEMPTY_out <= PHYCTLEMPTY_outdelay after OUT_DELAY;
    PHYCTLFULL_out <= PHYCTLFULL_outdelay after OUT_DELAY;
    PHYCTLREADY_out <= PHYCTLREADY_outdelay after OUT_DELAY;
    
    MEMREFCLK_in <= MEMREFCLK;
    PHYCLK_in <= PHYCLK;
    
    PHYCTLMSTREMPTY_in <= PHYCTLMSTREMPTY;
    PHYCTLWD_in <= PHYCTLWD;
    PHYCTLWRENABLE_in <= PHYCTLWRENABLE;
    PLLLOCK_in <= PLLLOCK;
    READCALIBENABLE_in <= READCALIBENABLE;
    REFDLLLOCK_in <= REFDLLLOCK;
    RESET_in <= RESET;
    SYNCIN_in <= SYNCIN;
    WRITECALIBENABLE_in <= WRITECALIBENABLE;
    
    MEMREFCLK_indelay <= MEMREFCLK_in after INCLK_DELAY;
    PHYCLK_indelay <= PHYCLK_in after INCLK_DELAY;
    
    PHYCTLMSTREMPTY_indelay <= PHYCTLMSTREMPTY_in after IN_DELAY;
    PHYCTLWD_indelay <= PHYCTLWD_in after IN_DELAY;
    PHYCTLWRENABLE_indelay <= PHYCTLWRENABLE_in after IN_DELAY;
    PLLLOCK_indelay <= PLLLOCK_in after IN_DELAY;
    READCALIBENABLE_indelay <= READCALIBENABLE_in after IN_DELAY;
    REFDLLLOCK_indelay <= REFDLLLOCK_in after IN_DELAY;
    RESET_indelay <= RESET_in after IN_DELAY;
    SYNCIN_indelay <= SYNCIN_in after IN_DELAY;
    WRITECALIBENABLE_indelay <= WRITECALIBENABLE_in after IN_DELAY;

    GSR_indelay <= GSR;
    
    
    PHY_CONTROL_INST : SIP_PHY_CONTROL
      port map (
        AO_TOGGLE            => AO_TOGGLE_BINARY,
        AO_WRLVL_EN          => AO_WRLVL_EN_BINARY,
        BURST_MODE           => BURST_MODE_BINARY,
        CLK_RATIO            => CLK_RATIO_BINARY,
        CMD_OFFSET           => CMD_OFFSET_BINARY,
        CO_DURATION          => CO_DURATION_BINARY,
        DATA_CTL_A_N         => DATA_CTL_A_N_BINARY,
        DATA_CTL_B_N         => DATA_CTL_B_N_BINARY,
        DATA_CTL_C_N         => DATA_CTL_C_N_BINARY,
        DATA_CTL_D_N         => DATA_CTL_D_N_BINARY,
        DISABLE_SEQ_MATCH    => DISABLE_SEQ_MATCH_BINARY,
        DI_DURATION          => DI_DURATION_BINARY,
        DO_DURATION          => DO_DURATION_BINARY,
        EVENTS_DELAY         => EVENTS_DELAY_BINARY,
        FOUR_WINDOW_CLOCKS   => FOUR_WINDOW_CLOCKS_BINARY,
        MULTI_REGION         => MULTI_REGION_BINARY,
        PHY_COUNT_ENABLE     => PHY_COUNT_ENABLE_BINARY,
        RD_CMD_OFFSET_0      => RD_CMD_OFFSET_0_BINARY,
        RD_CMD_OFFSET_1      => RD_CMD_OFFSET_1_BINARY,
        RD_CMD_OFFSET_2      => RD_CMD_OFFSET_2_BINARY,
        RD_CMD_OFFSET_3      => RD_CMD_OFFSET_3_BINARY,
        RD_DURATION_0        => RD_DURATION_0_BINARY,
        RD_DURATION_1        => RD_DURATION_1_BINARY,
        RD_DURATION_2        => RD_DURATION_2_BINARY,
        RD_DURATION_3        => RD_DURATION_3_BINARY,
        SPARE                => SPARE_BINARY,
        SYNC_MODE            => SYNC_MODE_BINARY,
        WR_CMD_OFFSET_0      => WR_CMD_OFFSET_0_BINARY,
        WR_CMD_OFFSET_1      => WR_CMD_OFFSET_1_BINARY,
        WR_CMD_OFFSET_2      => WR_CMD_OFFSET_2_BINARY,
        WR_CMD_OFFSET_3      => WR_CMD_OFFSET_3_BINARY,
        WR_DURATION_0        => WR_DURATION_0_BINARY,
        WR_DURATION_1        => WR_DURATION_1_BINARY,
        WR_DURATION_2        => WR_DURATION_2_BINARY,
        WR_DURATION_3        => WR_DURATION_3_BINARY,

        AUXOUTPUT            => AUXOUTPUT_outdelay,
        INBURSTPENDING       => INBURSTPENDING_outdelay,
        INRANKA              => INRANKA_outdelay,
        INRANKB              => INRANKB_outdelay,
        INRANKC              => INRANKC_outdelay,
        INRANKD              => INRANKD_outdelay,
        OUTBURSTPENDING      => OUTBURSTPENDING_outdelay,
        PCENABLECALIB        => PCENABLECALIB_outdelay,
        PHYCTLALMOSTFULL     => PHYCTLALMOSTFULL_outdelay,
        PHYCTLEMPTY          => PHYCTLEMPTY_outdelay,
        PHYCTLFULL           => PHYCTLFULL_outdelay,
        PHYCTLREADY          => PHYCTLREADY_outdelay,
        TESTOUTPUT           => TESTOUTPUT_outdelay,

        MEMREFCLK            => MEMREFCLK_indelay,
        PHYCLK               => PHYCLK_indelay,
        PHYCTLMSTREMPTY      => PHYCTLMSTREMPTY_indelay,
        PHYCTLWD             => PHYCTLWD_indelay,
        PHYCTLWRENABLE       => PHYCTLWRENABLE_indelay,
        PLLLOCK              => PLLLOCK_indelay,
        READCALIBENABLE      => READCALIBENABLE_indelay,
        REFDLLLOCK           => REFDLLLOCK_indelay,
        RESET                => RESET_indelay,
        SCANENABLEN          => SCANENABLEN_indelay,
        SYNCIN               => SYNCIN_indelay,
        TESTINPUT            => TESTINPUT_indelay,
        TESTSELECT           => TESTSELECT_indelay,
        WRITECALIBENABLE     => WRITECALIBENABLE_indelay,
        GSR                  => GSR_indelay
      );
    
    INIPROC : process
    begin
    -- case BURST_MODE is
      if((BURST_MODE = "FALSE") or (BURST_MODE = "false")) then
        BURST_MODE_BINARY <= '0';
      elsif((BURST_MODE = "TRUE") or (BURST_MODE= "true")) then
        BURST_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : BURST_MODE is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DATA_CTL_A_N is
      if((DATA_CTL_A_N = "FALSE") or (DATA_CTL_A_N = "false")) then
        DATA_CTL_A_N_BINARY <= '0';
      elsif((DATA_CTL_A_N = "TRUE") or (DATA_CTL_A_N= "true")) then
        DATA_CTL_A_N_BINARY <= '1';
      else
        assert FALSE report "Error : DATA_CTL_A_N is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DATA_CTL_B_N is
      if((DATA_CTL_B_N = "FALSE") or (DATA_CTL_B_N = "false")) then
        DATA_CTL_B_N_BINARY <= '0';
      elsif((DATA_CTL_B_N = "TRUE") or (DATA_CTL_B_N= "true")) then
        DATA_CTL_B_N_BINARY <= '1';
      else
        assert FALSE report "Error : DATA_CTL_B_N is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DATA_CTL_C_N is
      if((DATA_CTL_C_N = "FALSE") or (DATA_CTL_C_N = "false")) then
        DATA_CTL_C_N_BINARY <= '0';
      elsif((DATA_CTL_C_N = "TRUE") or (DATA_CTL_C_N= "true")) then
        DATA_CTL_C_N_BINARY <= '1';
      else
        assert FALSE report "Error : DATA_CTL_C_N is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DATA_CTL_D_N is
      if((DATA_CTL_D_N = "FALSE") or (DATA_CTL_D_N = "false")) then
        DATA_CTL_D_N_BINARY <= '0';
      elsif((DATA_CTL_D_N = "TRUE") or (DATA_CTL_D_N= "true")) then
        DATA_CTL_D_N_BINARY <= '1';
      else
        assert FALSE report "Error : DATA_CTL_D_N is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_SEQ_MATCH is
      if((DISABLE_SEQ_MATCH = "TRUE") or (DISABLE_SEQ_MATCH = "true")) then
        DISABLE_SEQ_MATCH_BINARY <= '1';
      elsif((DISABLE_SEQ_MATCH = "FALSE") or (DISABLE_SEQ_MATCH= "false")) then
        DISABLE_SEQ_MATCH_BINARY <= '0';
      else
        assert FALSE report "Error : DISABLE_SEQ_MATCH is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case MULTI_REGION is
      if((MULTI_REGION = "FALSE") or (MULTI_REGION = "false")) then
        MULTI_REGION_BINARY <= '0';
      elsif((MULTI_REGION = "TRUE") or (MULTI_REGION= "true")) then
        MULTI_REGION_BINARY <= '1';
      else
        assert FALSE report "Error : MULTI_REGION is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PHY_COUNT_ENABLE is
      if((PHY_COUNT_ENABLE = "FALSE") or (PHY_COUNT_ENABLE = "false")) then
        PHY_COUNT_ENABLE_BINARY <= '0';
      elsif((PHY_COUNT_ENABLE = "TRUE") or (PHY_COUNT_ENABLE= "true")) then
        PHY_COUNT_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PHY_COUNT_ENABLE is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SYNC_MODE is
      if((SYNC_MODE = "TRUE") or (SYNC_MODE = "true")) then
        SYNC_MODE_BINARY <= '1';
      elsif((SYNC_MODE = "FALSE") or (SYNC_MODE= "false")) then
        SYNC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : SYNC_MODE is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    if ((AO_TOGGLE >= 0) and (AO_TOGGLE <= 15)) then
      AO_TOGGLE_BINARY <= std_logic_vector(to_unsigned(AO_TOGGLE, 4));
    else
      assert FALSE report "Error : AO_TOGGLE is not in range 0 .. 15." severity error;
    end if;
    if ((CLK_RATIO >= 1) and (CLK_RATIO <= 8)) then
-- integer math rounds 1/2 -> 0
      CLK_RATIO_BINARY <= std_logic_vector(to_unsigned(CLK_RATIO/2, 3));
    else
      assert FALSE report "Error : CLK_RATIO is not in range 1 .. 8." severity error;
    end if;
    if ((CMD_OFFSET >= 0) and (CMD_OFFSET <= 63)) then
      CMD_OFFSET_BINARY <= std_logic_vector(to_unsigned(CMD_OFFSET, 6));
    else
      assert FALSE report "Error : CMD_OFFSET is not in range 0 .. 63." severity error;
    end if;
    if ((CO_DURATION >= 0) and (CO_DURATION <= 7)) then
      CO_DURATION_BINARY <= std_logic_vector(to_unsigned(CO_DURATION, 3));
    else
      assert FALSE report "Error : CO_DURATION is not in range 0 .. 7." severity error;
    end if;
    if ((DI_DURATION >= 0) and (DI_DURATION <= 7)) then
      DI_DURATION_BINARY <= std_logic_vector(to_unsigned(DI_DURATION, 3));
    else
      assert FALSE report "Error : DI_DURATION is not in range 0 .. 7." severity error;
    end if;
    if ((DO_DURATION >= 0) and (DO_DURATION <= 7)) then
      DO_DURATION_BINARY <= std_logic_vector(to_unsigned(DO_DURATION, 3));
    else
      assert FALSE report "Error : DO_DURATION is not in range 0 .. 7." severity error;
    end if;
    if ((EVENTS_DELAY >= 0) and (EVENTS_DELAY <= 63)) then
      EVENTS_DELAY_BINARY <= std_logic_vector(to_unsigned(EVENTS_DELAY, 6));
    else
      assert FALSE report "Error : EVENTS_DELAY is not in range 0 .. 63." severity error;
    end if;
    if ((FOUR_WINDOW_CLOCKS >= 0) and (FOUR_WINDOW_CLOCKS <= 63)) then
      FOUR_WINDOW_CLOCKS_BINARY <= std_logic_vector(to_unsigned(FOUR_WINDOW_CLOCKS, 6));
    else
      assert FALSE report "Error : FOUR_WINDOW_CLOCKS is not in range 0 .. 63." severity error;
    end if;
    if ((RD_CMD_OFFSET_0 >= 0) and (RD_CMD_OFFSET_0 <= 63)) then
      RD_CMD_OFFSET_0_BINARY <= std_logic_vector(to_unsigned(RD_CMD_OFFSET_0, 6));
    else
      assert FALSE report "Error : RD_CMD_OFFSET_0 is not in range 0 .. 63." severity error;
    end if;
    if ((RD_CMD_OFFSET_1 >= 0) and (RD_CMD_OFFSET_1 <= 63)) then
      RD_CMD_OFFSET_1_BINARY <= std_logic_vector(to_unsigned(RD_CMD_OFFSET_1, 6));
    else
      assert FALSE report "Error : RD_CMD_OFFSET_1 is not in range 0 .. 63." severity error;
    end if;
    if ((RD_CMD_OFFSET_2 >= 0) and (RD_CMD_OFFSET_2 <= 63)) then
      RD_CMD_OFFSET_2_BINARY <= std_logic_vector(to_unsigned(RD_CMD_OFFSET_2, 6));
    else
      assert FALSE report "Error : RD_CMD_OFFSET_2 is not in range 0 .. 63." severity error;
    end if;
    if ((RD_CMD_OFFSET_3 >= 0) and (RD_CMD_OFFSET_3 <= 63)) then
      RD_CMD_OFFSET_3_BINARY <= std_logic_vector(to_unsigned(RD_CMD_OFFSET_3, 6));
    else
      assert FALSE report "Error : RD_CMD_OFFSET_3 is not in range 0 .. 63." severity error;
    end if;
    if ((RD_DURATION_0 >= 0) and (RD_DURATION_0 <= 63)) then
      RD_DURATION_0_BINARY <= std_logic_vector(to_unsigned(RD_DURATION_0, 6));
    else
      assert FALSE report "Error : RD_DURATION_0 is not in range 0 .. 63." severity error;
    end if;
    if ((RD_DURATION_1 >= 0) and (RD_DURATION_1 <= 63)) then
      RD_DURATION_1_BINARY <= std_logic_vector(to_unsigned(RD_DURATION_1, 6));
    else
      assert FALSE report "Error : RD_DURATION_1 is not in range 0 .. 63." severity error;
    end if;
    if ((RD_DURATION_2 >= 0) and (RD_DURATION_2 <= 63)) then
      RD_DURATION_2_BINARY <= std_logic_vector(to_unsigned(RD_DURATION_2, 6));
    else
      assert FALSE report "Error : RD_DURATION_2 is not in range 0 .. 63." severity error;
    end if;
    if ((RD_DURATION_3 >= 0) and (RD_DURATION_3 <= 63)) then
      RD_DURATION_3_BINARY <= std_logic_vector(to_unsigned(RD_DURATION_3, 6));
    else
      assert FALSE report "Error : RD_DURATION_3 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_CMD_OFFSET_0 >= 0) and (WR_CMD_OFFSET_0 <= 63)) then
      WR_CMD_OFFSET_0_BINARY <= std_logic_vector(to_unsigned(WR_CMD_OFFSET_0, 6));
    else
      assert FALSE report "Error : WR_CMD_OFFSET_0 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_CMD_OFFSET_1 >= 0) and (WR_CMD_OFFSET_1 <= 63)) then
      WR_CMD_OFFSET_1_BINARY <= std_logic_vector(to_unsigned(WR_CMD_OFFSET_1, 6));
    else
      assert FALSE report "Error : WR_CMD_OFFSET_1 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_CMD_OFFSET_2 >= 0) and (WR_CMD_OFFSET_2 <= 63)) then
      WR_CMD_OFFSET_2_BINARY <= std_logic_vector(to_unsigned(WR_CMD_OFFSET_2, 6));
    else
      assert FALSE report "Error : WR_CMD_OFFSET_2 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_CMD_OFFSET_3 >= 0) and (WR_CMD_OFFSET_3 <= 63)) then
      WR_CMD_OFFSET_3_BINARY <= std_logic_vector(to_unsigned(WR_CMD_OFFSET_3, 6));
    else
      assert FALSE report "Error : WR_CMD_OFFSET_3 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_DURATION_0 >= 0) and (WR_DURATION_0 <= 63)) then
      WR_DURATION_0_BINARY <= std_logic_vector(to_unsigned(WR_DURATION_0, 6));
    else
      assert FALSE report "Error : WR_DURATION_0 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_DURATION_1 >= 0) and (WR_DURATION_1 <= 63)) then
      WR_DURATION_1_BINARY <= std_logic_vector(to_unsigned(WR_DURATION_1, 6));
    else
      assert FALSE report "Error : WR_DURATION_1 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_DURATION_2 >= 0) and (WR_DURATION_2 <= 63)) then
      WR_DURATION_2_BINARY <= std_logic_vector(to_unsigned(WR_DURATION_2, 6));
    else
      assert FALSE report "Error : WR_DURATION_2 is not in range 0 .. 63." severity error;
    end if;
    if ((WR_DURATION_3 >= 0) and (WR_DURATION_3 <= 63)) then
      WR_DURATION_3_BINARY <= std_logic_vector(to_unsigned(WR_DURATION_3, 6));
    else
      assert FALSE report "Error : WR_DURATION_3 is not in range 0 .. 63." severity error;
    end if;
    wait;
    end process INIPROC;
    AUXOUTPUT <= AUXOUTPUT_out;
    INBURSTPENDING <= INBURSTPENDING_out;
    INRANKA <= INRANKA_out;
    INRANKB <= INRANKB_out;
    INRANKC <= INRANKC_out;
    INRANKD <= INRANKD_out;
    OUTBURSTPENDING <= OUTBURSTPENDING_out;
    PCENABLECALIB <= PCENABLECALIB_out;
    PHYCTLALMOSTFULL <= PHYCTLALMOSTFULL_out;
    PHYCTLEMPTY <= PHYCTLEMPTY_out;
    PHYCTLFULL <= PHYCTLFULL_out;
    PHYCTLREADY <= PHYCTLREADY_out;
  end PHY_CONTROL_V;
