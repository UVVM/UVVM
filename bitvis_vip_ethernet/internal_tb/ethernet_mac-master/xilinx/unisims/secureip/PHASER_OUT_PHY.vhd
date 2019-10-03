-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/SMODEL/PHASER_OUT_PHY.vhd,v 1.16 2012/05/03 20:07:26 robh Exp $
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
--  /   /                        Fujisan PHASER OUT
-- /___/   /\      Filename    : PHASER_OUT_PHY.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: Comment:
--  08MAR2010 Initial UNI/SIM version from yaml
--  12JUL2010 enable secureip
--  30AUG2010 yaml, rtl update
--  24SEP2010 yaml, rtl update
--  13OCT2010 yaml update
--  26OCT2010 rtl update
--  02NOV2010 yaml update, correct tieoffs
--  05NOV2010 secureip parameter name update
--  01DEC2010 yaml update, REFCLK_PERIOD max
--  20DEC2010 587097 yaml update, OUTPUT_CLK_SRC, STG1_BYPASS
--  20DEC2010 592485 yaml, rtl update
--  02JUN2011 610011 rtl update, ADD REFCLK_PERIOD parameter
--  15AUG2011 621681 yml update, remove SIM_SPEEDUP make default
--  15FEB2012 646230 yml update, add param PO
-------------------------------------------------------

----- CELL PHASER_OUT_PHY -----

library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity PHASER_OUT_PHY is
    generic (
      CLKOUT_DIV : integer := 4;
      COARSE_BYPASS : string := "FALSE";
      COARSE_DELAY : integer := 0;
      DATA_CTL_N : string := "FALSE";
      DATA_RD_CYCLES : string := "FALSE";
      FINE_DELAY : integer := 0;
      MEMREFCLK_PERIOD : real := 0.000;
      OCLKDELAY_INV : string := "FALSE";
      OCLK_DELAY : integer := 0;
      OUTPUT_CLK_SRC : string := "PHASE_REF";
      PHASEREFCLK_PERIOD : real := 0.000;
      PO : bit_vector := "000";
      REFCLK_PERIOD : real := 0.000;
      SYNC_IN_DIV_RST : string := "FALSE"
    );

    port (
      COARSEOVERFLOW       : out std_ulogic;
      COUNTERREADVAL       : out std_logic_vector(8 downto 0);
      CTSBUS               : out std_logic_vector(1 downto 0);
      DQSBUS               : out std_logic_vector(1 downto 0);
      DTSBUS               : out std_logic_vector(1 downto 0);
      FINEOVERFLOW         : out std_ulogic;
      OCLK                 : out std_ulogic;
      OCLKDELAYED          : out std_ulogic;
      OCLKDIV              : out std_ulogic;
      OSERDESRST           : out std_ulogic;
      RDENABLE             : out std_ulogic;
      BURSTPENDINGPHY      : in std_ulogic;
      COARSEENABLE         : in std_ulogic;
      COARSEINC            : in std_ulogic;
      COUNTERLOADEN        : in std_ulogic;
      COUNTERLOADVAL       : in std_logic_vector(8 downto 0);
      COUNTERREADEN        : in std_ulogic;
      ENCALIBPHY           : in std_logic_vector(1 downto 0);
      FINEENABLE           : in std_ulogic;
      FINEINC              : in std_ulogic;
      FREQREFCLK           : in std_ulogic;
      MEMREFCLK            : in std_ulogic;
      PHASEREFCLK          : in std_ulogic;
      RST                  : in std_ulogic;
      SELFINEOCLKDELAY     : in std_ulogic;
      SYNCIN               : in std_ulogic;
      SYSCLK               : in std_ulogic      
    );
  end PHASER_OUT_PHY;

  architecture PHASER_OUT_PHY_V of PHASER_OUT_PHY is
    component SIP_PHASER_OUT
      generic (
        REFCLK_PERIOD : in real
      );
      port (
        CLKOUT_DIV : in std_logic_vector(3 downto 0);
        CLKOUT_DIV_POS : in std_logic_vector(3 downto 0);
        CLKOUT_DIV_ST : in std_logic_vector(3 downto 0);
        COARSE_BYPASS : in std_ulogic;
        COARSE_DELAY : in std_logic_vector(5 downto 0);
        CTL_MODE : in std_ulogic;
        DATA_CTL_N : in std_ulogic;
        DATA_RD_CYCLES : in std_ulogic;
        EN_OSERDES_RST : in std_ulogic;
        EN_TEST_RING : in std_ulogic;
        FINE_DELAY : in std_logic_vector(5 downto 0);
        OCLKDELAY_INV : in std_ulogic;
        OCLK_DELAY : in std_logic_vector(5 downto 0);
        OUTPUT_CLK_SRC : in std_logic_vector(1 downto 0);
        PHASER_OUT_EN : in std_ulogic;
        STG1_BYPASS : in std_ulogic;
        SYNC_IN_DIV_RST : in std_ulogic;
        TEST_OPT : in std_logic_vector(10 downto 0);

        COARSEOVERFLOW       : out std_ulogic;
        COUNTERREADVAL       : out std_logic_vector(8 downto 0);
        CTSBUS               : out std_logic_vector(1 downto 0);
        DQSBUS               : out std_logic_vector(1 downto 0);
        DTSBUS               : out std_logic_vector(1 downto 0);
        FINEOVERFLOW         : out std_ulogic;
        OCLK                 : out std_ulogic;
        OCLKDELAYED          : out std_ulogic;
        OCLKDIV              : out std_ulogic;
        OSERDESRST           : out std_ulogic;
        RDENABLE             : out std_ulogic;
        SCANOUT              : out std_ulogic;
        TESTOUT              : out std_logic_vector(3 downto 0);
        BURSTPENDING         : in std_ulogic;
        BURSTPENDINGPHY      : in std_ulogic;
        COARSEENABLE         : in std_ulogic;
        COARSEINC            : in std_ulogic;
        COUNTERLOADEN        : in std_ulogic;
        COUNTERLOADVAL       : in std_logic_vector(8 downto 0);
        COUNTERREADEN        : in std_ulogic;
        DIVIDERST            : in std_ulogic;
        EDGEADV              : in std_ulogic;
        ENCALIB              : in std_logic_vector(1 downto 0);
        ENCALIBPHY           : in std_logic_vector(1 downto 0);
        FINEENABLE           : in std_ulogic;
        FINEINC              : in std_ulogic;
        FREQREFCLK           : in std_ulogic;
        MEMREFCLK            : in std_ulogic;
        PHASEREFCLK          : in std_ulogic;
        RST                  : in std_ulogic;
        SCANCLK              : in std_ulogic;
        SCANENB              : in std_ulogic;
        SCANIN               : in std_ulogic;
        SCANMODEB            : in std_ulogic;
        SELFINEOCLKDELAY     : in std_ulogic;
        SYNCIN               : in std_ulogic;
        SYSCLK               : in std_ulogic;
        TESTIN               : in std_logic_vector(15 downto 0);
        GSR                  : in std_ulogic
      );
    end component;
    
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    constant MODULE_NAME : string  := "PHASER_OUT_PHY";
    constant CLKOUT_DIV_ST_BINARY : std_logic_vector(3 downto 0) := "0000";
    constant PO_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PO)(2 downto 0);
    constant TEST_OPT_BINARY : std_logic_vector(10 downto 0) := "00" & To_StdLogicVector(PO)(2 downto 0) & "000000";
    signal CLKOUT_DIV_BINARY : std_logic_vector(3 downto 0);
    signal CLKOUT_DIV_POS_BINARY : std_logic_vector(3 downto 0);
    signal COARSE_BYPASS_BINARY : std_ulogic;
    signal COARSE_DELAY_BINARY : std_logic_vector(5 downto 0);
    signal CTL_MODE_BINARY : std_ulogic;
    signal DATA_CTL_N_BINARY : std_ulogic;
    signal DATA_RD_CYCLES_BINARY : std_ulogic;
    signal EN_OSERDES_RST_BINARY : std_ulogic;
    signal EN_TEST_RING_BINARY : std_ulogic;
    signal FINE_DELAY_BINARY : std_logic_vector(5 downto 0);
    signal MEMREFCLK_PERIOD_BINARY : std_ulogic;
    signal OCLKDELAY_INV_BINARY : std_ulogic;
    signal OCLK_DELAY_BINARY : std_logic_vector(5 downto 0);
    signal OUTPUT_CLK_SRC_BINARY : std_logic_vector(1 downto 0);
    signal PHASEREFCLK_PERIOD_BINARY : std_ulogic;
    signal PHASER_OUT_EN_BINARY : std_ulogic;
    signal REFCLK_PERIOD_BINARY : std_ulogic;
    signal STG1_BYPASS_BINARY : std_ulogic;
    signal SYNC_IN_DIV_RST_BINARY : std_ulogic;
    
    signal COARSEOVERFLOW_out : std_ulogic;
    signal COUNTERREADVAL_out : std_logic_vector(8 downto 0);
    signal CTSBUS_out : std_logic_vector(1 downto 0);
    signal DQSBUS_out : std_logic_vector(1 downto 0);
    signal DTSBUS_out : std_logic_vector(1 downto 0);
    signal FINEOVERFLOW_out : std_ulogic;
    signal OCLKDELAYED_out : std_ulogic;
    signal OCLKDIV_out : std_ulogic;
    signal OCLK_out : std_ulogic;
    signal OSERDESRST_out : std_ulogic;
    signal RDENABLE_out : std_ulogic;
    
    signal COARSEOVERFLOW_outdelay : std_ulogic;
    signal COUNTERREADVAL_outdelay : std_logic_vector(8 downto 0);
    signal CTSBUS_outdelay : std_logic_vector(1 downto 0);
    signal DQSBUS_outdelay : std_logic_vector(1 downto 0);
    signal DTSBUS_outdelay : std_logic_vector(1 downto 0);
    signal FINEOVERFLOW_outdelay : std_ulogic;
    signal OCLKDELAYED_outdelay : std_ulogic;
    signal OCLKDIV_outdelay : std_ulogic;
    signal OCLK_outdelay : std_ulogic;
    signal OSERDESRST_outdelay : std_ulogic;
    signal RDENABLE_outdelay : std_ulogic;
    signal SCANOUT_outdelay : std_ulogic;
    signal TESTOUT_outdelay : std_logic_vector(3 downto 0);
    
    signal BURSTPENDINGPHY_in : std_ulogic;
    signal COARSEENABLE_in : std_ulogic;
    signal COARSEINC_in : std_ulogic;
    signal COUNTERLOADEN_in : std_ulogic;
    signal COUNTERLOADVAL_in : std_logic_vector(8 downto 0);
    signal COUNTERREADEN_in : std_ulogic;
    signal ENCALIBPHY_in : std_logic_vector(1 downto 0);
    signal FINEENABLE_in : std_ulogic;
    signal FINEINC_in : std_ulogic;
    signal FREQREFCLK_in : std_ulogic;
    signal MEMREFCLK_in : std_ulogic;
    signal PHASEREFCLK_in : std_ulogic;
    signal RST_in : std_ulogic;
    signal SELFINEOCLKDELAY_in : std_ulogic;
    signal SYNCIN_in : std_ulogic;
    signal SYSCLK_in : std_ulogic;
    
    signal BURSTPENDINGPHY_indelay : std_ulogic;
    signal BURSTPENDING_indelay : std_ulogic := '1';
    signal COARSEENABLE_indelay : std_ulogic;
    signal COARSEINC_indelay : std_ulogic;
    signal COUNTERLOADEN_indelay : std_ulogic;
    signal COUNTERLOADVAL_indelay : std_logic_vector(8 downto 0);
    signal COUNTERREADEN_indelay : std_ulogic;
    signal DIVIDERST_indelay : std_ulogic := '0';
    signal EDGEADV_indelay : std_ulogic := '0';
    signal ENCALIBPHY_indelay : std_logic_vector(1 downto 0);
    signal ENCALIB_indelay : std_logic_vector(1 downto 0) := "11";
    signal FINEENABLE_indelay : std_ulogic;
    signal FINEINC_indelay : std_ulogic;
    signal FREQREFCLK_indelay : std_ulogic;
    signal MEMREFCLK_indelay : std_ulogic;
    signal PHASEREFCLK_indelay : std_ulogic;
    signal RST_indelay : std_ulogic;
    signal SCANCLK_indelay : std_ulogic := '1';
    signal SCANENB_indelay : std_ulogic := '1';
    signal SCANIN_indelay : std_ulogic := '1';
    signal SCANMODEB_indelay : std_ulogic := '1';
    signal SELFINEOCLKDELAY_indelay : std_ulogic;
    signal SYNCIN_indelay : std_ulogic;
    signal SYSCLK_indelay : std_ulogic;
    signal TESTIN_indelay : std_logic_vector(15 downto 0) := X"FFFF";
    signal GSR_indelay : std_ulogic;
    
    begin
    OCLKDELAYED_out <= OCLKDELAYED_outdelay after OUTCLK_DELAY;
    OCLKDIV_out <= OCLKDIV_outdelay after OUTCLK_DELAY;
    OCLK_out <= OCLK_outdelay after OUTCLK_DELAY;
    
    COARSEOVERFLOW_out <= COARSEOVERFLOW_outdelay after OUT_DELAY;
    COUNTERREADVAL_out <= COUNTERREADVAL_outdelay after OUT_DELAY;
    CTSBUS_out <= CTSBUS_outdelay after OUT_DELAY;
    DQSBUS_out <= DQSBUS_outdelay after OUT_DELAY;
    DTSBUS_out <= DTSBUS_outdelay after OUT_DELAY;
    FINEOVERFLOW_out <= FINEOVERFLOW_outdelay after OUT_DELAY;
    OSERDESRST_out <= OSERDESRST_outdelay after OUT_DELAY;
    RDENABLE_out <= RDENABLE_outdelay after OUT_DELAY;
    
    FREQREFCLK_in <= FREQREFCLK;
    SYSCLK_in <= SYSCLK;
    
    BURSTPENDINGPHY_in <= BURSTPENDINGPHY;
    COARSEENABLE_in <= COARSEENABLE;
    COARSEINC_in <= COARSEINC;
    COUNTERLOADEN_in <= COUNTERLOADEN;
    COUNTERLOADVAL_in <= COUNTERLOADVAL;
    COUNTERREADEN_in <= COUNTERREADEN;
    ENCALIBPHY_in <= ENCALIBPHY;
    FINEENABLE_in <= FINEENABLE;
    FINEINC_in <= FINEINC;
    MEMREFCLK_in <= MEMREFCLK;
    PHASEREFCLK_in <= PHASEREFCLK;
    RST_in <= RST;
    SELFINEOCLKDELAY_in <= SELFINEOCLKDELAY;
    SYNCIN_in <= SYNCIN;
    
    FREQREFCLK_indelay <= FREQREFCLK_in after INCLK_DELAY;
    SYSCLK_indelay <= SYSCLK_in after INCLK_DELAY;
    GSR_indelay <= GSR;
    
    BURSTPENDINGPHY_indelay <= BURSTPENDINGPHY_in after IN_DELAY;
    COARSEENABLE_indelay <= COARSEENABLE_in after IN_DELAY;
    COARSEINC_indelay <= COARSEINC_in after IN_DELAY;
    COUNTERLOADEN_indelay <= COUNTERLOADEN_in after IN_DELAY;
    COUNTERLOADVAL_indelay <= COUNTERLOADVAL_in after IN_DELAY;
    COUNTERREADEN_indelay <= COUNTERREADEN_in after IN_DELAY;
    ENCALIBPHY_indelay <= ENCALIBPHY_in after IN_DELAY;
    FINEENABLE_indelay <= FINEENABLE_in after IN_DELAY;
    FINEINC_indelay <= FINEINC_in after IN_DELAY;
    MEMREFCLK_indelay <= MEMREFCLK_in after IN_DELAY;
    PHASEREFCLK_indelay <= PHASEREFCLK_in after IN_DELAY;
    RST_indelay <= RST_in after IN_DELAY;
    SELFINEOCLKDELAY_indelay <= SELFINEOCLKDELAY_in after IN_DELAY;
    SYNCIN_indelay <= SYNCIN_in after IN_DELAY;
    
    
    PHASER_OUT_INST : SIP_PHASER_OUT
      generic map (
        REFCLK_PERIOD        => REFCLK_PERIOD
      )
      port map (
        CLKOUT_DIV           => CLKOUT_DIV_BINARY,
        CLKOUT_DIV_POS       => CLKOUT_DIV_POS_BINARY,
        CLKOUT_DIV_ST        => CLKOUT_DIV_ST_BINARY,
        COARSE_BYPASS        => COARSE_BYPASS_BINARY,
        COARSE_DELAY         => COARSE_DELAY_BINARY,
        CTL_MODE             => CTL_MODE_BINARY,
        DATA_CTL_N           => DATA_CTL_N_BINARY,
        DATA_RD_CYCLES       => DATA_RD_CYCLES_BINARY,
        EN_OSERDES_RST       => EN_OSERDES_RST_BINARY,
        EN_TEST_RING         => EN_TEST_RING_BINARY,
        FINE_DELAY           => FINE_DELAY_BINARY,
        OCLKDELAY_INV        => OCLKDELAY_INV_BINARY,
        OCLK_DELAY           => OCLK_DELAY_BINARY,
        OUTPUT_CLK_SRC       => OUTPUT_CLK_SRC_BINARY,
        PHASER_OUT_EN        => PHASER_OUT_EN_BINARY,
        STG1_BYPASS          => STG1_BYPASS_BINARY,
        SYNC_IN_DIV_RST      => SYNC_IN_DIV_RST_BINARY,
        TEST_OPT             => TEST_OPT_BINARY,

        COARSEOVERFLOW       => COARSEOVERFLOW_outdelay,
        COUNTERREADVAL       => COUNTERREADVAL_outdelay,
        CTSBUS               => CTSBUS_outdelay,
        DQSBUS               => DQSBUS_outdelay,
        DTSBUS               => DTSBUS_outdelay,
        FINEOVERFLOW         => FINEOVERFLOW_outdelay,
        OCLK                 => OCLK_outdelay,
        OCLKDELAYED          => OCLKDELAYED_outdelay,
        OCLKDIV              => OCLKDIV_outdelay,
        OSERDESRST           => OSERDESRST_outdelay,
        RDENABLE             => RDENABLE_outdelay,
        SCANOUT              => SCANOUT_outdelay,
        TESTOUT              => TESTOUT_outdelay,
        BURSTPENDING         => BURSTPENDING_indelay,
        BURSTPENDINGPHY      => BURSTPENDINGPHY_indelay,
        COARSEENABLE         => COARSEENABLE_indelay,
        COARSEINC            => COARSEINC_indelay,
        COUNTERLOADEN        => COUNTERLOADEN_indelay,
        COUNTERLOADVAL       => COUNTERLOADVAL_indelay,
        COUNTERREADEN        => COUNTERREADEN_indelay,
        DIVIDERST            => DIVIDERST_indelay,
        EDGEADV              => EDGEADV_indelay,
        ENCALIB              => ENCALIB_indelay,
        ENCALIBPHY           => ENCALIBPHY_indelay,
        FINEENABLE           => FINEENABLE_indelay,
        FINEINC              => FINEINC_indelay,
        FREQREFCLK           => FREQREFCLK_indelay,
        MEMREFCLK            => MEMREFCLK_indelay,
        PHASEREFCLK          => PHASEREFCLK_indelay,
        RST                  => RST_indelay,
        SCANCLK              => SCANCLK_indelay,
        SCANENB              => SCANENB_indelay,
        SCANIN               => SCANIN_indelay,
        SCANMODEB            => SCANMODEB_indelay,
        SELFINEOCLKDELAY     => SELFINEOCLKDELAY_indelay,
        SYNCIN               => SYNCIN_indelay,
        SYSCLK               => SYSCLK_indelay,
        TESTIN               => TESTIN_indelay,
        GSR                  => GSR_indelay
      );
    
    INIPROC : process
    begin
    -- case COARSE_BYPASS is
      if((COARSE_BYPASS = "FALSE") or (COARSE_BYPASS = "false")) then
        COARSE_BYPASS_BINARY <= '0';
      elsif((COARSE_BYPASS = "TRUE") or (COARSE_BYPASS = "true")) then
        COARSE_BYPASS_BINARY <= '1';
      else
        assert FALSE report "Error : COARSE_BYPASS is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    CTL_MODE_BINARY <= '1'; -- model alert
    -- case DATA_CTL_N is
      if((DATA_CTL_N = "FALSE") or (DATA_CTL_N = "false")) then
        DATA_CTL_N_BINARY <= '0';
      elsif((DATA_CTL_N = "TRUE") or (DATA_CTL_N = "true")) then
        DATA_CTL_N_BINARY <= '1';
      else
        assert FALSE report "Error : DATA_CTL_N is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DATA_RD_CYCLES is
      if((DATA_RD_CYCLES = "FALSE") or (DATA_RD_CYCLES = "false")) then
        DATA_RD_CYCLES_BINARY <= '0';
      elsif((DATA_RD_CYCLES = "TRUE") or (DATA_RD_CYCLES = "true")) then
        DATA_RD_CYCLES_BINARY <= '1';
      else
        assert FALSE report "Error : DATA_RD_CYCLES is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    EN_OSERDES_RST_BINARY <= '0';
    EN_TEST_RING_BINARY <= '0';
    -- case OCLKDELAY_INV is
      if((OCLKDELAY_INV = "FALSE") or (OCLKDELAY_INV = "false")) then
        OCLKDELAY_INV_BINARY <= '0';
      elsif((OCLKDELAY_INV = "TRUE") or (OCLKDELAY_INV = "true")) then
        OCLKDELAY_INV_BINARY <= '1';
      else
        assert FALSE report "Error : OCLKDELAY_INV is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case OUTPUT_CLK_SRC is
      if((OUTPUT_CLK_SRC = "PHASE_REF") or (OUTPUT_CLK_SRC = "phase_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "00";
      elsif((OUTPUT_CLK_SRC = "DELAYED_PHASE_REF") or (OUTPUT_CLK_SRC = "delayed_phase_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "11";
      elsif((OUTPUT_CLK_SRC = "DELAYED_REF") or (OUTPUT_CLK_SRC = "delayed_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "01";
      elsif((OUTPUT_CLK_SRC = "FREQ_REF") or (OUTPUT_CLK_SRC = "freq_ref")) then
        OUTPUT_CLK_SRC_BINARY <= "10";
      else
        assert FALSE report "Error : OUTPUT_CLK_SRC is not PHASE_REF, DELAYED_PHASE_REF, DELAYED_REF or FREQ_REF." severity error;
      end if;
    -- end case;
    PHASER_OUT_EN_BINARY <= '1';
      if((OUTPUT_CLK_SRC = "DELAYED_PHASE_REF") or (OUTPUT_CLK_SRC = "delayed_phase_ref")) then
        STG1_BYPASS_BINARY <= '0';
      else
        STG1_BYPASS_BINARY <= '1';
      end if;
    -- case SYNC_IN_DIV_RST is
      if((SYNC_IN_DIV_RST = "FALSE") or (SYNC_IN_DIV_RST = "false")) then
        SYNC_IN_DIV_RST_BINARY <= '0';
      elsif((SYNC_IN_DIV_RST = "TRUE") or (SYNC_IN_DIV_RST = "true")) then
        SYNC_IN_DIV_RST_BINARY <= '1';
      else
        assert FALSE report "Error : SYNC_IN_DIV_RST is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    if ((MEMREFCLK_PERIOD > 0.000) and (MEMREFCLK_PERIOD <= 10.000)) then
      MEMREFCLK_PERIOD_BINARY <= '1';
    else
      assert FALSE report "Error : MEMREFCLK_PERIOD (" & real'Image(MEMREFCLK_PERIOD) & ") is not greater than 0.000 and less than or equal to 10.000." severity error;
    end if;
    if ((PHASEREFCLK_PERIOD > 0.000) and (PHASEREFCLK_PERIOD <= 10.000)) then
      PHASEREFCLK_PERIOD_BINARY <= '1';
    else
      assert FALSE report "Error : PHASEREFCLK_PERIOD (" & real'Image(PHASEREFCLK_PERIOD) & ") is not greater than 0.000 and less than or equal to 10.000." severity error;
    end if;
    if ((REFCLK_PERIOD > 0.000) and (REFCLK_PERIOD <= 10.000)) then
      REFCLK_PERIOD_BINARY <= '1';
    else
      assert FALSE report "Error : REFCLK_PERIOD (" & real'Image(REFCLK_PERIOD) & ") is not greater than 0.000 and less than or equal to 10.000." severity error;
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
    if ((CLKOUT_DIV >= 2) and (CLKOUT_DIV <= 16)) then
      CLKOUT_DIV_BINARY <= STD_LOGIC_VECTOR(TO_UNSIGNED(CLKOUT_DIV - 2, 4));
    else
      assert FALSE report "Error : CLKOUT_DIV is not in range 2 .. 16." severity error;
    end if;
    if ((COARSE_DELAY >= 0) and (COARSE_DELAY <= 63)) then
      COARSE_DELAY_BINARY <= STD_LOGIC_VECTOR(TO_UNSIGNED(COARSE_DELAY, 6));
    else
      assert FALSE report "Error : COARSE_DELAY is not in range 0 .. 63." severity error;
    end if;
    if ((FINE_DELAY >= 0) and (FINE_DELAY <= 63)) then
      FINE_DELAY_BINARY <= STD_LOGIC_VECTOR(TO_UNSIGNED(FINE_DELAY, 6));
    else
      assert FALSE report "Error : FINE_DELAY is not in range 0 .. 63." severity error;
    end if;
    if ((OCLK_DELAY >= 0) and (OCLK_DELAY <= 63)) then
      OCLK_DELAY_BINARY <= STD_LOGIC_VECTOR(TO_UNSIGNED(OCLK_DELAY, 6));
    else
      assert FALSE report "Error : OCLK_DELAY is not in range 0 .. 63." severity error;
    end if;
    wait;
    end process INIPROC;
    COARSEOVERFLOW <= COARSEOVERFLOW_out;
    COUNTERREADVAL <= COUNTERREADVAL_out;
    CTSBUS <= CTSBUS_out;
    DQSBUS <= DQSBUS_out;
    DTSBUS <= DTSBUS_out;
    FINEOVERFLOW <= FINEOVERFLOW_out;
    OCLK <= OCLK_out;
    OCLKDELAYED <= OCLKDELAYED_out;
    OCLKDIV <= OCLKDIV_out;
    OSERDESRST <= OSERDESRST_out;
    RDENABLE <= RDENABLE_out;
  end PHASER_OUT_PHY_V;
