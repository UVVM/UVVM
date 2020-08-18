-------------------------------------------------------
--  Copyright (c) 2011 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : PCIE_3_0.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  02/23/11 - Initial Version : 11.1
--  04/13/11 - 605801 - Updated YML
--  04/28/11 - 608328 - Updated YML & initial secureip publish
--  07/20/11 - 617638 - Updated YML (new attributes)
--  07/26/11 - 618494 - Updated YML
--  01/22/13 - Added DRP monitor (CR 695630).
-------------------------------------------------------

----- CELL PCIE_3_0 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity PCIE_3_0 is
    generic (
      ARI_CAP_ENABLE : string := "FALSE";
      AXISTEN_IF_CC_ALIGNMENT_MODE : string := "FALSE";
      AXISTEN_IF_CC_PARITY_CHK : string := "TRUE";
      AXISTEN_IF_CQ_ALIGNMENT_MODE : string := "FALSE";
      AXISTEN_IF_ENABLE_CLIENT_TAG : string := "FALSE";
      AXISTEN_IF_ENABLE_MSG_ROUTE : bit_vector := X"00000";
      AXISTEN_IF_ENABLE_RX_MSG_INTFC : string := "FALSE";
      AXISTEN_IF_RC_ALIGNMENT_MODE : string := "FALSE";
      AXISTEN_IF_RC_STRADDLE : string := "FALSE";
      AXISTEN_IF_RQ_ALIGNMENT_MODE : string := "FALSE";
      AXISTEN_IF_RQ_PARITY_CHK : string := "TRUE";
      AXISTEN_IF_WIDTH : bit_vector := X"2";
      CRM_CORE_CLK_FREQ_500 : string := "TRUE";
      CRM_USER_CLK_FREQ : bit_vector := X"2";
      DNSTREAM_LINK_NUM : bit_vector := X"00";
      GEN3_PCS_AUTO_REALIGN : bit_vector := X"1";
      GEN3_PCS_RX_ELECIDLE_INTERNAL : string := "TRUE";
      LL_ACK_TIMEOUT : bit_vector := X"000";
      LL_ACK_TIMEOUT_EN : string := "FALSE";
      LL_ACK_TIMEOUT_FUNC : integer := 0;
      LL_CPL_FC_UPDATE_TIMER : bit_vector := X"0000";
      LL_CPL_FC_UPDATE_TIMER_OVERRIDE : string := "FALSE";
      LL_FC_UPDATE_TIMER : bit_vector := X"0000";
      LL_FC_UPDATE_TIMER_OVERRIDE : string := "FALSE";
      LL_NP_FC_UPDATE_TIMER : bit_vector := X"0000";
      LL_NP_FC_UPDATE_TIMER_OVERRIDE : string := "FALSE";
      LL_P_FC_UPDATE_TIMER : bit_vector := X"0000";
      LL_P_FC_UPDATE_TIMER_OVERRIDE : string := "FALSE";
      LL_REPLAY_TIMEOUT : bit_vector := X"000";
      LL_REPLAY_TIMEOUT_EN : string := "FALSE";
      LL_REPLAY_TIMEOUT_FUNC : integer := 0;
      LTR_TX_MESSAGE_MINIMUM_INTERVAL : bit_vector := X"0FA";
      LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE : string := "FALSE";
      LTR_TX_MESSAGE_ON_LTR_ENABLE : string := "FALSE";
      PF0_AER_CAP_ECRC_CHECK_CAPABLE : string := "FALSE";
      PF0_AER_CAP_ECRC_GEN_CAPABLE : string := "FALSE";
      PF0_AER_CAP_NEXTPTR : bit_vector := X"000";
      PF0_ARI_CAP_NEXTPTR : bit_vector := X"000";
      PF0_ARI_CAP_NEXT_FUNC : bit_vector := X"00";
      PF0_ARI_CAP_VER : bit_vector := X"1";
      PF0_BAR0_APERTURE_SIZE : bit_vector := X"03";
      PF0_BAR0_CONTROL : bit_vector := X"4";
      PF0_BAR1_APERTURE_SIZE : bit_vector := X"00";
      PF0_BAR1_CONTROL : bit_vector := X"0";
      PF0_BAR2_APERTURE_SIZE : bit_vector := X"03";
      PF0_BAR2_CONTROL : bit_vector := X"4";
      PF0_BAR3_APERTURE_SIZE : bit_vector := X"03";
      PF0_BAR3_CONTROL : bit_vector := X"0";
      PF0_BAR4_APERTURE_SIZE : bit_vector := X"03";
      PF0_BAR4_CONTROL : bit_vector := X"4";
      PF0_BAR5_APERTURE_SIZE : bit_vector := X"03";
      PF0_BAR5_CONTROL : bit_vector := X"0";
      PF0_BIST_REGISTER : bit_vector := X"00";
      PF0_CAPABILITY_POINTER : bit_vector := X"50";
      PF0_CLASS_CODE : bit_vector := X"000000";
      PF0_DEVICE_ID : bit_vector := X"0000";
      PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT : string := "TRUE";
      PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT : string := "TRUE";
      PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT : string := "TRUE";
      PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE : string := "TRUE";
      PF0_DEV_CAP2_LTR_SUPPORT : string := "TRUE";
      PF0_DEV_CAP2_OBFF_SUPPORT : bit_vector := X"0";
      PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT : string := "FALSE";
      PF0_DEV_CAP_ENDPOINT_L0S_LATENCY : integer := 0;
      PF0_DEV_CAP_ENDPOINT_L1_LATENCY : integer := 0;
      PF0_DEV_CAP_EXT_TAG_SUPPORTED : string := "TRUE";
      PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE : string := "TRUE";
      PF0_DEV_CAP_MAX_PAYLOAD_SIZE : bit_vector := X"3";
      PF0_DPA_CAP_NEXTPTR : bit_vector := X"000";
      PF0_DPA_CAP_SUB_STATE_CONTROL : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_CONTROL_EN : string := "TRUE";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 : bit_vector := X"00";
      PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 : bit_vector := X"00";
      PF0_DPA_CAP_VER : bit_vector := X"1";
      PF0_DSN_CAP_NEXTPTR : bit_vector := X"10C";
      PF0_EXPANSION_ROM_APERTURE_SIZE : bit_vector := X"03";
      PF0_EXPANSION_ROM_ENABLE : string := "FALSE";
      PF0_INTERRUPT_LINE : bit_vector := X"00";
      PF0_INTERRUPT_PIN : bit_vector := X"1";
      PF0_LINK_CAP_ASPM_SUPPORT : integer := 0;
      PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
      PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
      PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 : integer := 7;
      PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 : integer := 7;
      PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 : integer := 7;
      PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 : integer := 7;
      PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
      PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
      PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 : integer := 7;
      PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 : integer := 7;
      PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 : integer := 7;
      PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 : integer := 7;
      PF0_LINK_STATUS_SLOT_CLOCK_CONFIG : string := "TRUE";
      PF0_LTR_CAP_MAX_NOSNOOP_LAT : bit_vector := X"000";
      PF0_LTR_CAP_MAX_SNOOP_LAT : bit_vector := X"000";
      PF0_LTR_CAP_NEXTPTR : bit_vector := X"000";
      PF0_LTR_CAP_VER : bit_vector := X"1";
      PF0_MSIX_CAP_NEXTPTR : bit_vector := X"00";
      PF0_MSIX_CAP_PBA_BIR : integer := 0;
      PF0_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      PF0_MSIX_CAP_TABLE_BIR : integer := 0;
      PF0_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      PF0_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      PF0_MSI_CAP_MULTIMSGCAP : integer := 0;
      PF0_MSI_CAP_NEXTPTR : bit_vector := X"00";
      PF0_PB_CAP_NEXTPTR : bit_vector := X"000";
      PF0_PB_CAP_SYSTEM_ALLOCATED : string := "FALSE";
      PF0_PB_CAP_VER : bit_vector := X"1";
      PF0_PM_CAP_ID : bit_vector := X"01";
      PF0_PM_CAP_NEXTPTR : bit_vector := X"00";
      PF0_PM_CAP_PMESUPPORT_D0 : string := "TRUE";
      PF0_PM_CAP_PMESUPPORT_D1 : string := "TRUE";
      PF0_PM_CAP_PMESUPPORT_D3HOT : string := "TRUE";
      PF0_PM_CAP_SUPP_D1_STATE : string := "TRUE";
      PF0_PM_CAP_VER_ID : bit_vector := X"3";
      PF0_PM_CSR_NOSOFTRESET : string := "TRUE";
      PF0_RBAR_CAP_ENABLE : string := "FALSE";
      PF0_RBAR_CAP_INDEX0 : bit_vector := X"0";
      PF0_RBAR_CAP_INDEX1 : bit_vector := X"0";
      PF0_RBAR_CAP_INDEX2 : bit_vector := X"0";
      PF0_RBAR_CAP_NEXTPTR : bit_vector := X"000";
      PF0_RBAR_CAP_SIZE0 : bit_vector := X"00000";
      PF0_RBAR_CAP_SIZE1 : bit_vector := X"00000";
      PF0_RBAR_CAP_SIZE2 : bit_vector := X"00000";
      PF0_RBAR_CAP_VER : bit_vector := X"1";
      PF0_RBAR_NUM : bit_vector := X"1";
      PF0_REVISION_ID : bit_vector := X"00";
      PF0_SRIOV_BAR0_APERTURE_SIZE : bit_vector := X"03";
      PF0_SRIOV_BAR0_CONTROL : bit_vector := X"4";
      PF0_SRIOV_BAR1_APERTURE_SIZE : bit_vector := X"00";
      PF0_SRIOV_BAR1_CONTROL : bit_vector := X"0";
      PF0_SRIOV_BAR2_APERTURE_SIZE : bit_vector := X"03";
      PF0_SRIOV_BAR2_CONTROL : bit_vector := X"4";
      PF0_SRIOV_BAR3_APERTURE_SIZE : bit_vector := X"03";
      PF0_SRIOV_BAR3_CONTROL : bit_vector := X"0";
      PF0_SRIOV_BAR4_APERTURE_SIZE : bit_vector := X"03";
      PF0_SRIOV_BAR4_CONTROL : bit_vector := X"4";
      PF0_SRIOV_BAR5_APERTURE_SIZE : bit_vector := X"03";
      PF0_SRIOV_BAR5_CONTROL : bit_vector := X"0";
      PF0_SRIOV_CAP_INITIAL_VF : bit_vector := X"0000";
      PF0_SRIOV_CAP_NEXTPTR : bit_vector := X"000";
      PF0_SRIOV_CAP_TOTAL_VF : bit_vector := X"0000";
      PF0_SRIOV_CAP_VER : bit_vector := X"1";
      PF0_SRIOV_FIRST_VF_OFFSET : bit_vector := X"0000";
      PF0_SRIOV_FUNC_DEP_LINK : bit_vector := X"0000";
      PF0_SRIOV_SUPPORTED_PAGE_SIZE : bit_vector := X"00000000";
      PF0_SRIOV_VF_DEVICE_ID : bit_vector := X"0000";
      PF0_SUBSYSTEM_ID : bit_vector := X"0000";
      PF0_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      PF0_TPHR_CAP_ENABLE : string := "FALSE";
      PF0_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      PF0_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      PF0_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      PF0_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      PF0_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      PF0_TPHR_CAP_VER : bit_vector := X"1";
      PF0_VC_CAP_NEXTPTR : bit_vector := X"000";
      PF0_VC_CAP_VER : bit_vector := X"1";
      PF1_AER_CAP_ECRC_CHECK_CAPABLE : string := "FALSE";
      PF1_AER_CAP_ECRC_GEN_CAPABLE : string := "FALSE";
      PF1_AER_CAP_NEXTPTR : bit_vector := X"000";
      PF1_ARI_CAP_NEXTPTR : bit_vector := X"000";
      PF1_ARI_CAP_NEXT_FUNC : bit_vector := X"00";
      PF1_BAR0_APERTURE_SIZE : bit_vector := X"03";
      PF1_BAR0_CONTROL : bit_vector := X"4";
      PF1_BAR1_APERTURE_SIZE : bit_vector := X"00";
      PF1_BAR1_CONTROL : bit_vector := X"0";
      PF1_BAR2_APERTURE_SIZE : bit_vector := X"03";
      PF1_BAR2_CONTROL : bit_vector := X"4";
      PF1_BAR3_APERTURE_SIZE : bit_vector := X"03";
      PF1_BAR3_CONTROL : bit_vector := X"0";
      PF1_BAR4_APERTURE_SIZE : bit_vector := X"03";
      PF1_BAR4_CONTROL : bit_vector := X"4";
      PF1_BAR5_APERTURE_SIZE : bit_vector := X"03";
      PF1_BAR5_CONTROL : bit_vector := X"0";
      PF1_BIST_REGISTER : bit_vector := X"00";
      PF1_CAPABILITY_POINTER : bit_vector := X"50";
      PF1_CLASS_CODE : bit_vector := X"000000";
      PF1_DEVICE_ID : bit_vector := X"0000";
      PF1_DEV_CAP_MAX_PAYLOAD_SIZE : bit_vector := X"3";
      PF1_DPA_CAP_NEXTPTR : bit_vector := X"000";
      PF1_DPA_CAP_SUB_STATE_CONTROL : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_CONTROL_EN : string := "TRUE";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 : bit_vector := X"00";
      PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 : bit_vector := X"00";
      PF1_DPA_CAP_VER : bit_vector := X"1";
      PF1_DSN_CAP_NEXTPTR : bit_vector := X"10C";
      PF1_EXPANSION_ROM_APERTURE_SIZE : bit_vector := X"03";
      PF1_EXPANSION_ROM_ENABLE : string := "FALSE";
      PF1_INTERRUPT_LINE : bit_vector := X"00";
      PF1_INTERRUPT_PIN : bit_vector := X"1";
      PF1_MSIX_CAP_NEXTPTR : bit_vector := X"00";
      PF1_MSIX_CAP_PBA_BIR : integer := 0;
      PF1_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      PF1_MSIX_CAP_TABLE_BIR : integer := 0;
      PF1_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      PF1_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      PF1_MSI_CAP_MULTIMSGCAP : integer := 0;
      PF1_MSI_CAP_NEXTPTR : bit_vector := X"00";
      PF1_PB_CAP_NEXTPTR : bit_vector := X"000";
      PF1_PB_CAP_SYSTEM_ALLOCATED : string := "FALSE";
      PF1_PB_CAP_VER : bit_vector := X"1";
      PF1_PM_CAP_ID : bit_vector := X"01";
      PF1_PM_CAP_NEXTPTR : bit_vector := X"00";
      PF1_PM_CAP_VER_ID : bit_vector := X"3";
      PF1_RBAR_CAP_ENABLE : string := "FALSE";
      PF1_RBAR_CAP_INDEX0 : bit_vector := X"0";
      PF1_RBAR_CAP_INDEX1 : bit_vector := X"0";
      PF1_RBAR_CAP_INDEX2 : bit_vector := X"0";
      PF1_RBAR_CAP_NEXTPTR : bit_vector := X"000";
      PF1_RBAR_CAP_SIZE0 : bit_vector := X"00000";
      PF1_RBAR_CAP_SIZE1 : bit_vector := X"00000";
      PF1_RBAR_CAP_SIZE2 : bit_vector := X"00000";
      PF1_RBAR_CAP_VER : bit_vector := X"1";
      PF1_RBAR_NUM : bit_vector := X"1";
      PF1_REVISION_ID : bit_vector := X"00";
      PF1_SRIOV_BAR0_APERTURE_SIZE : bit_vector := X"03";
      PF1_SRIOV_BAR0_CONTROL : bit_vector := X"4";
      PF1_SRIOV_BAR1_APERTURE_SIZE : bit_vector := X"00";
      PF1_SRIOV_BAR1_CONTROL : bit_vector := X"0";
      PF1_SRIOV_BAR2_APERTURE_SIZE : bit_vector := X"03";
      PF1_SRIOV_BAR2_CONTROL : bit_vector := X"4";
      PF1_SRIOV_BAR3_APERTURE_SIZE : bit_vector := X"03";
      PF1_SRIOV_BAR3_CONTROL : bit_vector := X"0";
      PF1_SRIOV_BAR4_APERTURE_SIZE : bit_vector := X"03";
      PF1_SRIOV_BAR4_CONTROL : bit_vector := X"4";
      PF1_SRIOV_BAR5_APERTURE_SIZE : bit_vector := X"03";
      PF1_SRIOV_BAR5_CONTROL : bit_vector := X"0";
      PF1_SRIOV_CAP_INITIAL_VF : bit_vector := X"0000";
      PF1_SRIOV_CAP_NEXTPTR : bit_vector := X"000";
      PF1_SRIOV_CAP_TOTAL_VF : bit_vector := X"0000";
      PF1_SRIOV_CAP_VER : bit_vector := X"1";
      PF1_SRIOV_FIRST_VF_OFFSET : bit_vector := X"0000";
      PF1_SRIOV_FUNC_DEP_LINK : bit_vector := X"0000";
      PF1_SRIOV_SUPPORTED_PAGE_SIZE : bit_vector := X"00000000";
      PF1_SRIOV_VF_DEVICE_ID : bit_vector := X"0000";
      PF1_SUBSYSTEM_ID : bit_vector := X"0000";
      PF1_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      PF1_TPHR_CAP_ENABLE : string := "FALSE";
      PF1_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      PF1_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      PF1_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      PF1_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      PF1_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      PF1_TPHR_CAP_VER : bit_vector := X"1";
      PL_DISABLE_EI_INFER_IN_L0 : string := "FALSE";
      PL_DISABLE_GEN3_DC_BALANCE : string := "FALSE";
      PL_DISABLE_SCRAMBLING : string := "FALSE";
      PL_DISABLE_UPCONFIG_CAPABLE : string := "FALSE";
      PL_EQ_ADAPT_DISABLE_COEFF_CHECK : string := "FALSE";
      PL_EQ_ADAPT_DISABLE_PRESET_CHECK : string := "FALSE";
      PL_EQ_ADAPT_ITER_COUNT : bit_vector := X"02";
      PL_EQ_ADAPT_REJECT_RETRY_COUNT : bit_vector := X"1";
      PL_EQ_BYPASS_PHASE23 : string := "FALSE";
      PL_EQ_SHORT_ADAPT_PHASE : string := "FALSE";
      PL_LANE0_EQ_CONTROL : bit_vector := X"3F00";
      PL_LANE1_EQ_CONTROL : bit_vector := X"3F00";
      PL_LANE2_EQ_CONTROL : bit_vector := X"3F00";
      PL_LANE3_EQ_CONTROL : bit_vector := X"3F00";
      PL_LANE4_EQ_CONTROL : bit_vector := X"3F00";
      PL_LANE5_EQ_CONTROL : bit_vector := X"3F00";
      PL_LANE6_EQ_CONTROL : bit_vector := X"3F00";
      PL_LANE7_EQ_CONTROL : bit_vector := X"3F00";
      PL_LINK_CAP_MAX_LINK_SPEED : bit_vector := X"4";
      PL_LINK_CAP_MAX_LINK_WIDTH : bit_vector := X"8";
      PL_N_FTS_COMCLK_GEN1 : integer := 255;
      PL_N_FTS_COMCLK_GEN2 : integer := 255;
      PL_N_FTS_COMCLK_GEN3 : integer := 255;
      PL_N_FTS_GEN1 : integer := 255;
      PL_N_FTS_GEN2 : integer := 255;
      PL_N_FTS_GEN3 : integer := 255;
      PL_SIM_FAST_LINK_TRAINING : string := "FALSE";
      PL_UPSTREAM_FACING : string := "TRUE";
      PM_ASPML0S_TIMEOUT : bit_vector := X"05DC";
      PM_ASPML1_ENTRY_DELAY : bit_vector := X"00000";
      PM_ENABLE_SLOT_POWER_CAPTURE : string := "TRUE";
      PM_L1_REENTRY_DELAY : bit_vector := X"00000000";
      PM_PME_SERVICE_TIMEOUT_DELAY : bit_vector := X"186A0";
      PM_PME_TURNOFF_ACK_DELAY : bit_vector := X"0064";
      SIM_VERSION : string := "1.0";
      SPARE_BIT0 : integer := 0;
      SPARE_BIT1 : integer := 0;
      SPARE_BIT2 : integer := 0;
      SPARE_BIT3 : integer := 0;
      SPARE_BIT4 : integer := 0;
      SPARE_BIT5 : integer := 0;
      SPARE_BIT6 : integer := 0;
      SPARE_BIT7 : integer := 0;
      SPARE_BIT8 : integer := 0;
      SPARE_BYTE0 : bit_vector := X"00";
      SPARE_BYTE1 : bit_vector := X"00";
      SPARE_BYTE2 : bit_vector := X"00";
      SPARE_BYTE3 : bit_vector := X"00";
      SPARE_WORD0 : bit_vector := X"00000000";
      SPARE_WORD1 : bit_vector := X"00000000";
      SPARE_WORD2 : bit_vector := X"00000000";
      SPARE_WORD3 : bit_vector := X"00000000";
      SRIOV_CAP_ENABLE : string := "FALSE";
      TL_COMPL_TIMEOUT_REG0 : bit_vector := X"BEBC20";
      TL_COMPL_TIMEOUT_REG1 : bit_vector := X"0000000";
      TL_CREDITS_CD : bit_vector := X"3E0";
      TL_CREDITS_CH : bit_vector := X"20";
      TL_CREDITS_NPD : bit_vector := X"028";
      TL_CREDITS_NPH : bit_vector := X"20";
      TL_CREDITS_PD : bit_vector := X"198";
      TL_CREDITS_PH : bit_vector := X"20";
      TL_ENABLE_MESSAGE_RID_CHECK_ENABLE : string := "TRUE";
      TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE : string := "FALSE";
      TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE : string := "FALSE";
      TL_LEGACY_MODE_ENABLE : string := "FALSE";
      TL_PF_ENABLE_REG : string := "FALSE";
      TL_TAG_MGMT_ENABLE : string := "TRUE";
      VF0_ARI_CAP_NEXTPTR : bit_vector := X"000";
      VF0_CAPABILITY_POINTER : bit_vector := X"50";
      VF0_MSIX_CAP_PBA_BIR : integer := 0;
      VF0_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      VF0_MSIX_CAP_TABLE_BIR : integer := 0;
      VF0_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      VF0_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      VF0_MSI_CAP_MULTIMSGCAP : integer := 0;
      VF0_PM_CAP_ID : bit_vector := X"01";
      VF0_PM_CAP_NEXTPTR : bit_vector := X"00";
      VF0_PM_CAP_VER_ID : bit_vector := X"3";
      VF0_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      VF0_TPHR_CAP_ENABLE : string := "FALSE";
      VF0_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      VF0_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      VF0_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      VF0_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      VF0_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      VF0_TPHR_CAP_VER : bit_vector := X"1";
      VF1_ARI_CAP_NEXTPTR : bit_vector := X"000";
      VF1_MSIX_CAP_PBA_BIR : integer := 0;
      VF1_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      VF1_MSIX_CAP_TABLE_BIR : integer := 0;
      VF1_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      VF1_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      VF1_MSI_CAP_MULTIMSGCAP : integer := 0;
      VF1_PM_CAP_ID : bit_vector := X"01";
      VF1_PM_CAP_NEXTPTR : bit_vector := X"00";
      VF1_PM_CAP_VER_ID : bit_vector := X"3";
      VF1_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      VF1_TPHR_CAP_ENABLE : string := "FALSE";
      VF1_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      VF1_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      VF1_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      VF1_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      VF1_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      VF1_TPHR_CAP_VER : bit_vector := X"1";
      VF2_ARI_CAP_NEXTPTR : bit_vector := X"000";
      VF2_MSIX_CAP_PBA_BIR : integer := 0;
      VF2_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      VF2_MSIX_CAP_TABLE_BIR : integer := 0;
      VF2_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      VF2_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      VF2_MSI_CAP_MULTIMSGCAP : integer := 0;
      VF2_PM_CAP_ID : bit_vector := X"01";
      VF2_PM_CAP_NEXTPTR : bit_vector := X"00";
      VF2_PM_CAP_VER_ID : bit_vector := X"3";
      VF2_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      VF2_TPHR_CAP_ENABLE : string := "FALSE";
      VF2_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      VF2_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      VF2_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      VF2_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      VF2_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      VF2_TPHR_CAP_VER : bit_vector := X"1";
      VF3_ARI_CAP_NEXTPTR : bit_vector := X"000";
      VF3_MSIX_CAP_PBA_BIR : integer := 0;
      VF3_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      VF3_MSIX_CAP_TABLE_BIR : integer := 0;
      VF3_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      VF3_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      VF3_MSI_CAP_MULTIMSGCAP : integer := 0;
      VF3_PM_CAP_ID : bit_vector := X"01";
      VF3_PM_CAP_NEXTPTR : bit_vector := X"00";
      VF3_PM_CAP_VER_ID : bit_vector := X"3";
      VF3_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      VF3_TPHR_CAP_ENABLE : string := "FALSE";
      VF3_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      VF3_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      VF3_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      VF3_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      VF3_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      VF3_TPHR_CAP_VER : bit_vector := X"1";
      VF4_ARI_CAP_NEXTPTR : bit_vector := X"000";
      VF4_MSIX_CAP_PBA_BIR : integer := 0;
      VF4_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      VF4_MSIX_CAP_TABLE_BIR : integer := 0;
      VF4_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      VF4_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      VF4_MSI_CAP_MULTIMSGCAP : integer := 0;
      VF4_PM_CAP_ID : bit_vector := X"01";
      VF4_PM_CAP_NEXTPTR : bit_vector := X"00";
      VF4_PM_CAP_VER_ID : bit_vector := X"3";
      VF4_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      VF4_TPHR_CAP_ENABLE : string := "FALSE";
      VF4_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      VF4_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      VF4_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      VF4_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      VF4_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      VF4_TPHR_CAP_VER : bit_vector := X"1";
      VF5_ARI_CAP_NEXTPTR : bit_vector := X"000";
      VF5_MSIX_CAP_PBA_BIR : integer := 0;
      VF5_MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      VF5_MSIX_CAP_TABLE_BIR : integer := 0;
      VF5_MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      VF5_MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      VF5_MSI_CAP_MULTIMSGCAP : integer := 0;
      VF5_PM_CAP_ID : bit_vector := X"01";
      VF5_PM_CAP_NEXTPTR : bit_vector := X"00";
      VF5_PM_CAP_VER_ID : bit_vector := X"3";
      VF5_TPHR_CAP_DEV_SPECIFIC_MODE : string := "TRUE";
      VF5_TPHR_CAP_ENABLE : string := "FALSE";
      VF5_TPHR_CAP_INT_VEC_MODE : string := "TRUE";
      VF5_TPHR_CAP_NEXTPTR : bit_vector := X"000";
      VF5_TPHR_CAP_ST_MODE_SEL : bit_vector := X"0";
      VF5_TPHR_CAP_ST_TABLE_LOC : bit_vector := X"0";
      VF5_TPHR_CAP_ST_TABLE_SIZE : bit_vector := X"000";
      VF5_TPHR_CAP_VER : bit_vector := X"1"
    );

    port (
      CFGCURRENTSPEED      : out std_logic_vector(2 downto 0);
      CFGDPASUBSTATECHANGE : out std_logic_vector(1 downto 0);
      CFGERRCOROUT         : out std_ulogic;
      CFGERRFATALOUT       : out std_ulogic;
      CFGERRNONFATALOUT    : out std_ulogic;
      CFGEXTFUNCTIONNUMBER : out std_logic_vector(7 downto 0);
      CFGEXTREADRECEIVED   : out std_ulogic;
      CFGEXTREGISTERNUMBER : out std_logic_vector(9 downto 0);
      CFGEXTWRITEBYTEENABLE : out std_logic_vector(3 downto 0);
      CFGEXTWRITEDATA      : out std_logic_vector(31 downto 0);
      CFGEXTWRITERECEIVED  : out std_ulogic;
      CFGFCCPLD            : out std_logic_vector(11 downto 0);
      CFGFCCPLH            : out std_logic_vector(7 downto 0);
      CFGFCNPD             : out std_logic_vector(11 downto 0);
      CFGFCNPH             : out std_logic_vector(7 downto 0);
      CFGFCPD              : out std_logic_vector(11 downto 0);
      CFGFCPH              : out std_logic_vector(7 downto 0);
      CFGFLRINPROCESS      : out std_logic_vector(1 downto 0);
      CFGFUNCTIONPOWERSTATE : out std_logic_vector(5 downto 0);
      CFGFUNCTIONSTATUS    : out std_logic_vector(7 downto 0);
      CFGHOTRESETOUT       : out std_ulogic;
      CFGINPUTUPDATEDONE   : out std_ulogic;
      CFGINTERRUPTAOUTPUT  : out std_ulogic;
      CFGINTERRUPTBOUTPUT  : out std_ulogic;
      CFGINTERRUPTCOUTPUT  : out std_ulogic;
      CFGINTERRUPTDOUTPUT  : out std_ulogic;
      CFGINTERRUPTMSIDATA  : out std_logic_vector(31 downto 0);
      CFGINTERRUPTMSIENABLE : out std_logic_vector(1 downto 0);
      CFGINTERRUPTMSIFAIL  : out std_ulogic;
      CFGINTERRUPTMSIMASKUPDATE : out std_ulogic;
      CFGINTERRUPTMSIMMENABLE : out std_logic_vector(5 downto 0);
      CFGINTERRUPTMSISENT  : out std_ulogic;
      CFGINTERRUPTMSIVFENABLE : out std_logic_vector(5 downto 0);
      CFGINTERRUPTMSIXENABLE : out std_logic_vector(1 downto 0);
      CFGINTERRUPTMSIXFAIL : out std_ulogic;
      CFGINTERRUPTMSIXMASK : out std_logic_vector(1 downto 0);
      CFGINTERRUPTMSIXSENT : out std_ulogic;
      CFGINTERRUPTMSIXVFENABLE : out std_logic_vector(5 downto 0);
      CFGINTERRUPTMSIXVFMASK : out std_logic_vector(5 downto 0);
      CFGINTERRUPTSENT     : out std_ulogic;
      CFGLINKPOWERSTATE    : out std_logic_vector(1 downto 0);
      CFGLOCALERROR        : out std_ulogic;
      CFGLTRENABLE         : out std_ulogic;
      CFGLTSSMSTATE        : out std_logic_vector(5 downto 0);
      CFGMAXPAYLOAD        : out std_logic_vector(2 downto 0);
      CFGMAXREADREQ        : out std_logic_vector(2 downto 0);
      CFGMCUPDATEDONE      : out std_ulogic;
      CFGMGMTREADDATA      : out std_logic_vector(31 downto 0);
      CFGMGMTREADWRITEDONE : out std_ulogic;
      CFGMSGRECEIVED       : out std_ulogic;
      CFGMSGRECEIVEDDATA   : out std_logic_vector(7 downto 0);
      CFGMSGRECEIVEDTYPE   : out std_logic_vector(4 downto 0);
      CFGMSGTRANSMITDONE   : out std_ulogic;
      CFGNEGOTIATEDWIDTH   : out std_logic_vector(3 downto 0);
      CFGOBFFENABLE        : out std_logic_vector(1 downto 0);
      CFGPERFUNCSTATUSDATA : out std_logic_vector(15 downto 0);
      CFGPERFUNCTIONUPDATEDONE : out std_ulogic;
      CFGPHYLINKDOWN       : out std_ulogic;
      CFGPHYLINKSTATUS     : out std_logic_vector(1 downto 0);
      CFGPLSTATUSCHANGE    : out std_ulogic;
      CFGPOWERSTATECHANGEINTERRUPT : out std_ulogic;
      CFGRCBSTATUS         : out std_logic_vector(1 downto 0);
      CFGTPHFUNCTIONNUM    : out std_logic_vector(2 downto 0);
      CFGTPHREQUESTERENABLE : out std_logic_vector(1 downto 0);
      CFGTPHSTMODE         : out std_logic_vector(5 downto 0);
      CFGTPHSTTADDRESS     : out std_logic_vector(4 downto 0);
      CFGTPHSTTREADENABLE  : out std_ulogic;
      CFGTPHSTTWRITEBYTEVALID : out std_logic_vector(3 downto 0);
      CFGTPHSTTWRITEDATA   : out std_logic_vector(31 downto 0);
      CFGTPHSTTWRITEENABLE : out std_ulogic;
      CFGVFFLRINPROCESS    : out std_logic_vector(5 downto 0);
      CFGVFPOWERSTATE      : out std_logic_vector(17 downto 0);
      CFGVFSTATUS          : out std_logic_vector(11 downto 0);
      CFGVFTPHREQUESTERENABLE : out std_logic_vector(5 downto 0);
      CFGVFTPHSTMODE       : out std_logic_vector(17 downto 0);
      DBGDATAOUT           : out std_logic_vector(15 downto 0);
      DRPDO                : out std_logic_vector(15 downto 0);
      DRPRDY               : out std_ulogic;
      MAXISCQTDATA         : out std_logic_vector(255 downto 0);
      MAXISCQTKEEP         : out std_logic_vector(7 downto 0);
      MAXISCQTLAST         : out std_ulogic;
      MAXISCQTUSER         : out std_logic_vector(84 downto 0);
      MAXISCQTVALID        : out std_ulogic;
      MAXISRCTDATA         : out std_logic_vector(255 downto 0);
      MAXISRCTKEEP         : out std_logic_vector(7 downto 0);
      MAXISRCTLAST         : out std_ulogic;
      MAXISRCTUSER         : out std_logic_vector(74 downto 0);
      MAXISRCTVALID        : out std_ulogic;
      MICOMPLETIONRAMREADADDRESSAL : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMREADADDRESSAU : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMREADADDRESSBL : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMREADADDRESSBU : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMREADENABLEL : out std_logic_vector(3 downto 0);
      MICOMPLETIONRAMREADENABLEU : out std_logic_vector(3 downto 0);
      MICOMPLETIONRAMWRITEADDRESSAL : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMWRITEADDRESSAU : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMWRITEADDRESSBL : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMWRITEADDRESSBU : out std_logic_vector(9 downto 0);
      MICOMPLETIONRAMWRITEDATAL : out std_logic_vector(71 downto 0);
      MICOMPLETIONRAMWRITEDATAU : out std_logic_vector(71 downto 0);
      MICOMPLETIONRAMWRITEENABLEL : out std_logic_vector(3 downto 0);
      MICOMPLETIONRAMWRITEENABLEU : out std_logic_vector(3 downto 0);
      MIREPLAYRAMADDRESS   : out std_logic_vector(8 downto 0);
      MIREPLAYRAMREADENABLE : out std_logic_vector(1 downto 0);
      MIREPLAYRAMWRITEDATA : out std_logic_vector(143 downto 0);
      MIREPLAYRAMWRITEENABLE : out std_logic_vector(1 downto 0);
      MIREQUESTRAMREADADDRESSA : out std_logic_vector(8 downto 0);
      MIREQUESTRAMREADADDRESSB : out std_logic_vector(8 downto 0);
      MIREQUESTRAMREADENABLE : out std_logic_vector(3 downto 0);
      MIREQUESTRAMWRITEADDRESSA : out std_logic_vector(8 downto 0);
      MIREQUESTRAMWRITEADDRESSB : out std_logic_vector(8 downto 0);
      MIREQUESTRAMWRITEDATA : out std_logic_vector(143 downto 0);
      MIREQUESTRAMWRITEENABLE : out std_logic_vector(3 downto 0);
      PCIECQNPREQCOUNT     : out std_logic_vector(5 downto 0);
      PCIERQSEQNUM         : out std_logic_vector(3 downto 0);
      PCIERQSEQNUMVLD      : out std_ulogic;
      PCIERQTAG            : out std_logic_vector(5 downto 0);
      PCIERQTAGAV          : out std_logic_vector(1 downto 0);
      PCIERQTAGVLD         : out std_ulogic;
      PCIETFCNPDAV         : out std_logic_vector(1 downto 0);
      PCIETFCNPHAV         : out std_logic_vector(1 downto 0);
      PIPERX0EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX0EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX0EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX0EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX0POLARITY      : out std_ulogic;
      PIPERX1EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX1EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX1EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX1EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX1POLARITY      : out std_ulogic;
      PIPERX2EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX2EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX2EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX2EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX2POLARITY      : out std_ulogic;
      PIPERX3EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX3EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX3EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX3EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX3POLARITY      : out std_ulogic;
      PIPERX4EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX4EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX4EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX4EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX4POLARITY      : out std_ulogic;
      PIPERX5EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX5EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX5EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX5EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX5POLARITY      : out std_ulogic;
      PIPERX6EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX6EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX6EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX6EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX6POLARITY      : out std_ulogic;
      PIPERX7EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPERX7EQLPLFFS      : out std_logic_vector(5 downto 0);
      PIPERX7EQLPTXPRESET  : out std_logic_vector(3 downto 0);
      PIPERX7EQPRESET      : out std_logic_vector(2 downto 0);
      PIPERX7POLARITY      : out std_ulogic;
      PIPETX0CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX0COMPLIANCE    : out std_ulogic;
      PIPETX0DATA          : out std_logic_vector(31 downto 0);
      PIPETX0DATAVALID     : out std_ulogic;
      PIPETX0ELECIDLE      : out std_ulogic;
      PIPETX0EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX0EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX0EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX0POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX0STARTBLOCK    : out std_ulogic;
      PIPETX0SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETX1CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX1COMPLIANCE    : out std_ulogic;
      PIPETX1DATA          : out std_logic_vector(31 downto 0);
      PIPETX1DATAVALID     : out std_ulogic;
      PIPETX1ELECIDLE      : out std_ulogic;
      PIPETX1EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX1EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX1EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX1POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX1STARTBLOCK    : out std_ulogic;
      PIPETX1SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETX2CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX2COMPLIANCE    : out std_ulogic;
      PIPETX2DATA          : out std_logic_vector(31 downto 0);
      PIPETX2DATAVALID     : out std_ulogic;
      PIPETX2ELECIDLE      : out std_ulogic;
      PIPETX2EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX2EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX2EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX2POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX2STARTBLOCK    : out std_ulogic;
      PIPETX2SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETX3CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX3COMPLIANCE    : out std_ulogic;
      PIPETX3DATA          : out std_logic_vector(31 downto 0);
      PIPETX3DATAVALID     : out std_ulogic;
      PIPETX3ELECIDLE      : out std_ulogic;
      PIPETX3EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX3EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX3EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX3POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX3STARTBLOCK    : out std_ulogic;
      PIPETX3SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETX4CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX4COMPLIANCE    : out std_ulogic;
      PIPETX4DATA          : out std_logic_vector(31 downto 0);
      PIPETX4DATAVALID     : out std_ulogic;
      PIPETX4ELECIDLE      : out std_ulogic;
      PIPETX4EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX4EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX4EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX4POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX4STARTBLOCK    : out std_ulogic;
      PIPETX4SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETX5CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX5COMPLIANCE    : out std_ulogic;
      PIPETX5DATA          : out std_logic_vector(31 downto 0);
      PIPETX5DATAVALID     : out std_ulogic;
      PIPETX5ELECIDLE      : out std_ulogic;
      PIPETX5EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX5EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX5EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX5POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX5STARTBLOCK    : out std_ulogic;
      PIPETX5SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETX6CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX6COMPLIANCE    : out std_ulogic;
      PIPETX6DATA          : out std_logic_vector(31 downto 0);
      PIPETX6DATAVALID     : out std_ulogic;
      PIPETX6ELECIDLE      : out std_ulogic;
      PIPETX6EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX6EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX6EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX6POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX6STARTBLOCK    : out std_ulogic;
      PIPETX6SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETX7CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX7COMPLIANCE    : out std_ulogic;
      PIPETX7DATA          : out std_logic_vector(31 downto 0);
      PIPETX7DATAVALID     : out std_ulogic;
      PIPETX7ELECIDLE      : out std_ulogic;
      PIPETX7EQCONTROL     : out std_logic_vector(1 downto 0);
      PIPETX7EQDEEMPH      : out std_logic_vector(5 downto 0);
      PIPETX7EQPRESET      : out std_logic_vector(3 downto 0);
      PIPETX7POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX7STARTBLOCK    : out std_ulogic;
      PIPETX7SYNCHEADER    : out std_logic_vector(1 downto 0);
      PIPETXDEEMPH         : out std_ulogic;
      PIPETXMARGIN         : out std_logic_vector(2 downto 0);
      PIPETXRATE           : out std_logic_vector(1 downto 0);
      PIPETXRCVRDET        : out std_ulogic;
      PIPETXRESET          : out std_ulogic;
      PIPETXSWING          : out std_ulogic;
      PLEQINPROGRESS       : out std_ulogic;
      PLEQPHASE            : out std_logic_vector(1 downto 0);
      PLGEN3PCSRXSLIDE     : out std_logic_vector(7 downto 0);
      SAXISCCTREADY        : out std_logic_vector(3 downto 0);
      SAXISRQTREADY        : out std_logic_vector(3 downto 0);
      CFGCONFIGSPACEENABLE : in std_ulogic;
      CFGDEVID             : in std_logic_vector(15 downto 0);
      CFGDSBUSNUMBER       : in std_logic_vector(7 downto 0);
      CFGDSDEVICENUMBER    : in std_logic_vector(4 downto 0);
      CFGDSFUNCTIONNUMBER  : in std_logic_vector(2 downto 0);
      CFGDSN               : in std_logic_vector(63 downto 0);
      CFGDSPORTNUMBER      : in std_logic_vector(7 downto 0);
      CFGERRCORIN          : in std_ulogic;
      CFGERRUNCORIN        : in std_ulogic;
      CFGEXTREADDATA       : in std_logic_vector(31 downto 0);
      CFGEXTREADDATAVALID  : in std_ulogic;
      CFGFCSEL             : in std_logic_vector(2 downto 0);
      CFGFLRDONE           : in std_logic_vector(1 downto 0);
      CFGHOTRESETIN        : in std_ulogic;
      CFGINPUTUPDATEREQUEST : in std_ulogic;
      CFGINTERRUPTINT      : in std_logic_vector(3 downto 0);
      CFGINTERRUPTMSIATTR  : in std_logic_vector(2 downto 0);
      CFGINTERRUPTMSIFUNCTIONNUMBER : in std_logic_vector(2 downto 0);
      CFGINTERRUPTMSIINT   : in std_logic_vector(31 downto 0);
      CFGINTERRUPTMSIPENDINGSTATUS : in std_logic_vector(63 downto 0);
      CFGINTERRUPTMSISELECT : in std_logic_vector(3 downto 0);
      CFGINTERRUPTMSITPHPRESENT : in std_ulogic;
      CFGINTERRUPTMSITPHSTTAG : in std_logic_vector(8 downto 0);
      CFGINTERRUPTMSITPHTYPE : in std_logic_vector(1 downto 0);
      CFGINTERRUPTMSIXADDRESS : in std_logic_vector(63 downto 0);
      CFGINTERRUPTMSIXDATA : in std_logic_vector(31 downto 0);
      CFGINTERRUPTMSIXINT  : in std_ulogic;
      CFGINTERRUPTPENDING  : in std_logic_vector(1 downto 0);
      CFGLINKTRAININGENABLE : in std_ulogic;
      CFGMCUPDATEREQUEST   : in std_ulogic;
      CFGMGMTADDR          : in std_logic_vector(18 downto 0);
      CFGMGMTBYTEENABLE    : in std_logic_vector(3 downto 0);
      CFGMGMTREAD          : in std_ulogic;
      CFGMGMTTYPE1CFGREGACCESS : in std_ulogic;
      CFGMGMTWRITE         : in std_ulogic;
      CFGMGMTWRITEDATA     : in std_logic_vector(31 downto 0);
      CFGMSGTRANSMIT       : in std_ulogic;
      CFGMSGTRANSMITDATA   : in std_logic_vector(31 downto 0);
      CFGMSGTRANSMITTYPE   : in std_logic_vector(2 downto 0);
      CFGPERFUNCSTATUSCONTROL : in std_logic_vector(2 downto 0);
      CFGPERFUNCTIONNUMBER : in std_logic_vector(2 downto 0);
      CFGPERFUNCTIONOUTPUTREQUEST : in std_ulogic;
      CFGPOWERSTATECHANGEACK : in std_ulogic;
      CFGREQPMTRANSITIONL23READY : in std_ulogic;
      CFGREVID             : in std_logic_vector(7 downto 0);
      CFGSUBSYSID          : in std_logic_vector(15 downto 0);
      CFGSUBSYSVENDID      : in std_logic_vector(15 downto 0);
      CFGTPHSTTREADDATA    : in std_logic_vector(31 downto 0);
      CFGTPHSTTREADDATAVALID : in std_ulogic;
      CFGVENDID            : in std_logic_vector(15 downto 0);
      CFGVFFLRDONE         : in std_logic_vector(5 downto 0);
      CORECLK              : in std_ulogic;
      CORECLKMICOMPLETIONRAML : in std_ulogic;
      CORECLKMICOMPLETIONRAMU : in std_ulogic;
      CORECLKMIREPLAYRAM   : in std_ulogic;
      CORECLKMIREQUESTRAM  : in std_ulogic;
      DRPADDR              : in std_logic_vector(10 downto 0);
      DRPCLK               : in std_ulogic;
      DRPDI                : in std_logic_vector(15 downto 0);
      DRPEN                : in std_ulogic;
      DRPWE                : in std_ulogic;
      MAXISCQTREADY        : in std_logic_vector(21 downto 0);
      MAXISRCTREADY        : in std_logic_vector(21 downto 0);
      MGMTRESETN           : in std_ulogic;
      MGMTSTICKYRESETN     : in std_ulogic;
      MICOMPLETIONRAMREADDATA : in std_logic_vector(143 downto 0);
      MIREPLAYRAMREADDATA  : in std_logic_vector(143 downto 0);
      MIREQUESTRAMREADDATA : in std_logic_vector(143 downto 0);
      PCIECQNPREQ          : in std_ulogic;
      PIPECLK              : in std_ulogic;
      PIPEEQFS             : in std_logic_vector(5 downto 0);
      PIPEEQLF             : in std_logic_vector(5 downto 0);
      PIPERESETN           : in std_ulogic;
      PIPERX0CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX0DATA          : in std_logic_vector(31 downto 0);
      PIPERX0DATAVALID     : in std_ulogic;
      PIPERX0ELECIDLE      : in std_ulogic;
      PIPERX0EQDONE        : in std_ulogic;
      PIPERX0EQLPADAPTDONE : in std_ulogic;
      PIPERX0EQLPLFFSSEL   : in std_ulogic;
      PIPERX0EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX0PHYSTATUS     : in std_ulogic;
      PIPERX0STARTBLOCK    : in std_ulogic;
      PIPERX0STATUS        : in std_logic_vector(2 downto 0);
      PIPERX0SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX0VALID         : in std_ulogic;
      PIPERX1CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX1DATA          : in std_logic_vector(31 downto 0);
      PIPERX1DATAVALID     : in std_ulogic;
      PIPERX1ELECIDLE      : in std_ulogic;
      PIPERX1EQDONE        : in std_ulogic;
      PIPERX1EQLPADAPTDONE : in std_ulogic;
      PIPERX1EQLPLFFSSEL   : in std_ulogic;
      PIPERX1EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX1PHYSTATUS     : in std_ulogic;
      PIPERX1STARTBLOCK    : in std_ulogic;
      PIPERX1STATUS        : in std_logic_vector(2 downto 0);
      PIPERX1SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX1VALID         : in std_ulogic;
      PIPERX2CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX2DATA          : in std_logic_vector(31 downto 0);
      PIPERX2DATAVALID     : in std_ulogic;
      PIPERX2ELECIDLE      : in std_ulogic;
      PIPERX2EQDONE        : in std_ulogic;
      PIPERX2EQLPADAPTDONE : in std_ulogic;
      PIPERX2EQLPLFFSSEL   : in std_ulogic;
      PIPERX2EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX2PHYSTATUS     : in std_ulogic;
      PIPERX2STARTBLOCK    : in std_ulogic;
      PIPERX2STATUS        : in std_logic_vector(2 downto 0);
      PIPERX2SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX2VALID         : in std_ulogic;
      PIPERX3CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX3DATA          : in std_logic_vector(31 downto 0);
      PIPERX3DATAVALID     : in std_ulogic;
      PIPERX3ELECIDLE      : in std_ulogic;
      PIPERX3EQDONE        : in std_ulogic;
      PIPERX3EQLPADAPTDONE : in std_ulogic;
      PIPERX3EQLPLFFSSEL   : in std_ulogic;
      PIPERX3EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX3PHYSTATUS     : in std_ulogic;
      PIPERX3STARTBLOCK    : in std_ulogic;
      PIPERX3STATUS        : in std_logic_vector(2 downto 0);
      PIPERX3SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX3VALID         : in std_ulogic;
      PIPERX4CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX4DATA          : in std_logic_vector(31 downto 0);
      PIPERX4DATAVALID     : in std_ulogic;
      PIPERX4ELECIDLE      : in std_ulogic;
      PIPERX4EQDONE        : in std_ulogic;
      PIPERX4EQLPADAPTDONE : in std_ulogic;
      PIPERX4EQLPLFFSSEL   : in std_ulogic;
      PIPERX4EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX4PHYSTATUS     : in std_ulogic;
      PIPERX4STARTBLOCK    : in std_ulogic;
      PIPERX4STATUS        : in std_logic_vector(2 downto 0);
      PIPERX4SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX4VALID         : in std_ulogic;
      PIPERX5CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX5DATA          : in std_logic_vector(31 downto 0);
      PIPERX5DATAVALID     : in std_ulogic;
      PIPERX5ELECIDLE      : in std_ulogic;
      PIPERX5EQDONE        : in std_ulogic;
      PIPERX5EQLPADAPTDONE : in std_ulogic;
      PIPERX5EQLPLFFSSEL   : in std_ulogic;
      PIPERX5EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX5PHYSTATUS     : in std_ulogic;
      PIPERX5STARTBLOCK    : in std_ulogic;
      PIPERX5STATUS        : in std_logic_vector(2 downto 0);
      PIPERX5SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX5VALID         : in std_ulogic;
      PIPERX6CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX6DATA          : in std_logic_vector(31 downto 0);
      PIPERX6DATAVALID     : in std_ulogic;
      PIPERX6ELECIDLE      : in std_ulogic;
      PIPERX6EQDONE        : in std_ulogic;
      PIPERX6EQLPADAPTDONE : in std_ulogic;
      PIPERX6EQLPLFFSSEL   : in std_ulogic;
      PIPERX6EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX6PHYSTATUS     : in std_ulogic;
      PIPERX6STARTBLOCK    : in std_ulogic;
      PIPERX6STATUS        : in std_logic_vector(2 downto 0);
      PIPERX6SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX6VALID         : in std_ulogic;
      PIPERX7CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX7DATA          : in std_logic_vector(31 downto 0);
      PIPERX7DATAVALID     : in std_ulogic;
      PIPERX7ELECIDLE      : in std_ulogic;
      PIPERX7EQDONE        : in std_ulogic;
      PIPERX7EQLPADAPTDONE : in std_ulogic;
      PIPERX7EQLPLFFSSEL   : in std_ulogic;
      PIPERX7EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
      PIPERX7PHYSTATUS     : in std_ulogic;
      PIPERX7STARTBLOCK    : in std_ulogic;
      PIPERX7STATUS        : in std_logic_vector(2 downto 0);
      PIPERX7SYNCHEADER    : in std_logic_vector(1 downto 0);
      PIPERX7VALID         : in std_ulogic;
      PIPETX0EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX0EQDONE        : in std_ulogic;
      PIPETX1EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX1EQDONE        : in std_ulogic;
      PIPETX2EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX2EQDONE        : in std_ulogic;
      PIPETX3EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX3EQDONE        : in std_ulogic;
      PIPETX4EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX4EQDONE        : in std_ulogic;
      PIPETX5EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX5EQDONE        : in std_ulogic;
      PIPETX6EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX6EQDONE        : in std_ulogic;
      PIPETX7EQCOEFF       : in std_logic_vector(17 downto 0);
      PIPETX7EQDONE        : in std_ulogic;
      PLDISABLESCRAMBLER   : in std_ulogic;
      PLEQRESETEIEOSCOUNT  : in std_ulogic;
      PLGEN3PCSDISABLE     : in std_ulogic;
      PLGEN3PCSRXSYNCDONE  : in std_logic_vector(7 downto 0);
      RECCLK               : in std_ulogic;
      RESETN               : in std_ulogic;
      SAXISCCTDATA         : in std_logic_vector(255 downto 0);
      SAXISCCTKEEP         : in std_logic_vector(7 downto 0);
      SAXISCCTLAST         : in std_ulogic;
      SAXISCCTUSER         : in std_logic_vector(32 downto 0);
      SAXISCCTVALID        : in std_ulogic;
      SAXISRQTDATA         : in std_logic_vector(255 downto 0);
      SAXISRQTKEEP         : in std_logic_vector(7 downto 0);
      SAXISRQTLAST         : in std_ulogic;
      SAXISRQTUSER         : in std_logic_vector(59 downto 0);
      SAXISRQTVALID        : in std_ulogic;
      USERCLK              : in std_ulogic      
    );
  end PCIE_3_0;

  architecture PCIE_3_0_V of PCIE_3_0 is
    component PCIE_3_0_WRAP
      generic (
        ARI_CAP_ENABLE : string;
        AXISTEN_IF_CC_ALIGNMENT_MODE : string;
        AXISTEN_IF_CC_PARITY_CHK : string;
        AXISTEN_IF_CQ_ALIGNMENT_MODE : string;
        AXISTEN_IF_ENABLE_CLIENT_TAG : string;
        AXISTEN_IF_ENABLE_MSG_ROUTE : string;
        AXISTEN_IF_ENABLE_RX_MSG_INTFC : string;
        AXISTEN_IF_RC_ALIGNMENT_MODE : string;
        AXISTEN_IF_RC_STRADDLE : string;
        AXISTEN_IF_RQ_ALIGNMENT_MODE : string;
        AXISTEN_IF_RQ_PARITY_CHK : string;
        AXISTEN_IF_WIDTH : string;
        CRM_CORE_CLK_FREQ_500 : string;
        CRM_USER_CLK_FREQ : string;
        DNSTREAM_LINK_NUM : string;
        GEN3_PCS_AUTO_REALIGN : string;
        GEN3_PCS_RX_ELECIDLE_INTERNAL : string;
        LL_ACK_TIMEOUT : string;
        LL_ACK_TIMEOUT_EN : string;
        LL_ACK_TIMEOUT_FUNC : integer;
        LL_CPL_FC_UPDATE_TIMER : string;
        LL_CPL_FC_UPDATE_TIMER_OVERRIDE : string;
        LL_FC_UPDATE_TIMER : string;
        LL_FC_UPDATE_TIMER_OVERRIDE : string;
        LL_NP_FC_UPDATE_TIMER : string;
        LL_NP_FC_UPDATE_TIMER_OVERRIDE : string;
        LL_P_FC_UPDATE_TIMER : string;
        LL_P_FC_UPDATE_TIMER_OVERRIDE : string;
        LL_REPLAY_TIMEOUT : string;
        LL_REPLAY_TIMEOUT_EN : string;
        LL_REPLAY_TIMEOUT_FUNC : integer;
        LTR_TX_MESSAGE_MINIMUM_INTERVAL : string;
        LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE : string;
        LTR_TX_MESSAGE_ON_LTR_ENABLE : string;
        PF0_AER_CAP_ECRC_CHECK_CAPABLE : string;
        PF0_AER_CAP_ECRC_GEN_CAPABLE : string;
        PF0_AER_CAP_NEXTPTR : string;
        PF0_ARI_CAP_NEXTPTR : string;
        PF0_ARI_CAP_NEXT_FUNC : string;
        PF0_ARI_CAP_VER : string;
        PF0_BAR0_APERTURE_SIZE : string;
        PF0_BAR0_CONTROL : string;
        PF0_BAR1_APERTURE_SIZE : string;
        PF0_BAR1_CONTROL : string;
        PF0_BAR2_APERTURE_SIZE : string;
        PF0_BAR2_CONTROL : string;
        PF0_BAR3_APERTURE_SIZE : string;
        PF0_BAR3_CONTROL : string;
        PF0_BAR4_APERTURE_SIZE : string;
        PF0_BAR4_CONTROL : string;
        PF0_BAR5_APERTURE_SIZE : string;
        PF0_BAR5_CONTROL : string;
        PF0_BIST_REGISTER : string;
        PF0_CAPABILITY_POINTER : string;
        PF0_CLASS_CODE : string;
        PF0_DEVICE_ID : string;
        PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT : string;
        PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT : string;
        PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT : string;
        PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE : string;
        PF0_DEV_CAP2_LTR_SUPPORT : string;
        PF0_DEV_CAP2_OBFF_SUPPORT : string;
        PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT : string;
        PF0_DEV_CAP_ENDPOINT_L0S_LATENCY : integer;
        PF0_DEV_CAP_ENDPOINT_L1_LATENCY : integer;
        PF0_DEV_CAP_EXT_TAG_SUPPORTED : string;
        PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE : string;
        PF0_DEV_CAP_MAX_PAYLOAD_SIZE : string;
        PF0_DPA_CAP_NEXTPTR : string;
        PF0_DPA_CAP_SUB_STATE_CONTROL : string;
        PF0_DPA_CAP_SUB_STATE_CONTROL_EN : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 : string;
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 : string;
        PF0_DPA_CAP_VER : string;
        PF0_DSN_CAP_NEXTPTR : string;
        PF0_EXPANSION_ROM_APERTURE_SIZE : string;
        PF0_EXPANSION_ROM_ENABLE : string;
        PF0_INTERRUPT_LINE : string;
        PF0_INTERRUPT_PIN : string;
        PF0_LINK_CAP_ASPM_SUPPORT : integer;
        PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 : integer;
        PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 : integer;
        PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 : integer;
        PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 : integer;
        PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 : integer;
        PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 : integer;
        PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 : integer;
        PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 : integer;
        PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 : integer;
        PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 : integer;
        PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 : integer;
        PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 : integer;
        PF0_LINK_STATUS_SLOT_CLOCK_CONFIG : string;
        PF0_LTR_CAP_MAX_NOSNOOP_LAT : string;
        PF0_LTR_CAP_MAX_SNOOP_LAT : string;
        PF0_LTR_CAP_NEXTPTR : string;
        PF0_LTR_CAP_VER : string;
        PF0_MSIX_CAP_NEXTPTR : string;
        PF0_MSIX_CAP_PBA_BIR : integer;
        PF0_MSIX_CAP_PBA_OFFSET : string;
        PF0_MSIX_CAP_TABLE_BIR : integer;
        PF0_MSIX_CAP_TABLE_OFFSET : string;
        PF0_MSIX_CAP_TABLE_SIZE : string;
        PF0_MSI_CAP_MULTIMSGCAP : integer;
        PF0_MSI_CAP_NEXTPTR : string;
        PF0_PB_CAP_NEXTPTR : string;
        PF0_PB_CAP_SYSTEM_ALLOCATED : string;
        PF0_PB_CAP_VER : string;
        PF0_PM_CAP_ID : string;
        PF0_PM_CAP_NEXTPTR : string;
        PF0_PM_CAP_PMESUPPORT_D0 : string;
        PF0_PM_CAP_PMESUPPORT_D1 : string;
        PF0_PM_CAP_PMESUPPORT_D3HOT : string;
        PF0_PM_CAP_SUPP_D1_STATE : string;
        PF0_PM_CAP_VER_ID : string;
        PF0_PM_CSR_NOSOFTRESET : string;
        PF0_RBAR_CAP_ENABLE : string;
        PF0_RBAR_CAP_INDEX0 : string;
        PF0_RBAR_CAP_INDEX1 : string;
        PF0_RBAR_CAP_INDEX2 : string;
        PF0_RBAR_CAP_NEXTPTR : string;
        PF0_RBAR_CAP_SIZE0 : string;
        PF0_RBAR_CAP_SIZE1 : string;
        PF0_RBAR_CAP_SIZE2 : string;
        PF0_RBAR_CAP_VER : string;
        PF0_RBAR_NUM : string;
        PF0_REVISION_ID : string;
        PF0_SRIOV_BAR0_APERTURE_SIZE : string;
        PF0_SRIOV_BAR0_CONTROL : string;
        PF0_SRIOV_BAR1_APERTURE_SIZE : string;
        PF0_SRIOV_BAR1_CONTROL : string;
        PF0_SRIOV_BAR2_APERTURE_SIZE : string;
        PF0_SRIOV_BAR2_CONTROL : string;
        PF0_SRIOV_BAR3_APERTURE_SIZE : string;
        PF0_SRIOV_BAR3_CONTROL : string;
        PF0_SRIOV_BAR4_APERTURE_SIZE : string;
        PF0_SRIOV_BAR4_CONTROL : string;
        PF0_SRIOV_BAR5_APERTURE_SIZE : string;
        PF0_SRIOV_BAR5_CONTROL : string;
        PF0_SRIOV_CAP_INITIAL_VF : string;
        PF0_SRIOV_CAP_NEXTPTR : string;
        PF0_SRIOV_CAP_TOTAL_VF : string;
        PF0_SRIOV_CAP_VER : string;
        PF0_SRIOV_FIRST_VF_OFFSET : string;
        PF0_SRIOV_FUNC_DEP_LINK : string;
        PF0_SRIOV_SUPPORTED_PAGE_SIZE : string;
        PF0_SRIOV_VF_DEVICE_ID : string;
        PF0_SUBSYSTEM_ID : string;
        PF0_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        PF0_TPHR_CAP_ENABLE : string;
        PF0_TPHR_CAP_INT_VEC_MODE : string;
        PF0_TPHR_CAP_NEXTPTR : string;
        PF0_TPHR_CAP_ST_MODE_SEL : string;
        PF0_TPHR_CAP_ST_TABLE_LOC : string;
        PF0_TPHR_CAP_ST_TABLE_SIZE : string;
        PF0_TPHR_CAP_VER : string;
        PF0_VC_CAP_NEXTPTR : string;
        PF0_VC_CAP_VER : string;
        PF1_AER_CAP_ECRC_CHECK_CAPABLE : string;
        PF1_AER_CAP_ECRC_GEN_CAPABLE : string;
        PF1_AER_CAP_NEXTPTR : string;
        PF1_ARI_CAP_NEXTPTR : string;
        PF1_ARI_CAP_NEXT_FUNC : string;
        PF1_BAR0_APERTURE_SIZE : string;
        PF1_BAR0_CONTROL : string;
        PF1_BAR1_APERTURE_SIZE : string;
        PF1_BAR1_CONTROL : string;
        PF1_BAR2_APERTURE_SIZE : string;
        PF1_BAR2_CONTROL : string;
        PF1_BAR3_APERTURE_SIZE : string;
        PF1_BAR3_CONTROL : string;
        PF1_BAR4_APERTURE_SIZE : string;
        PF1_BAR4_CONTROL : string;
        PF1_BAR5_APERTURE_SIZE : string;
        PF1_BAR5_CONTROL : string;
        PF1_BIST_REGISTER : string;
        PF1_CAPABILITY_POINTER : string;
        PF1_CLASS_CODE : string;
        PF1_DEVICE_ID : string;
        PF1_DEV_CAP_MAX_PAYLOAD_SIZE : string;
        PF1_DPA_CAP_NEXTPTR : string;
        PF1_DPA_CAP_SUB_STATE_CONTROL : string;
        PF1_DPA_CAP_SUB_STATE_CONTROL_EN : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 : string;
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 : string;
        PF1_DPA_CAP_VER : string;
        PF1_DSN_CAP_NEXTPTR : string;
        PF1_EXPANSION_ROM_APERTURE_SIZE : string;
        PF1_EXPANSION_ROM_ENABLE : string;
        PF1_INTERRUPT_LINE : string;
        PF1_INTERRUPT_PIN : string;
        PF1_MSIX_CAP_NEXTPTR : string;
        PF1_MSIX_CAP_PBA_BIR : integer;
        PF1_MSIX_CAP_PBA_OFFSET : string;
        PF1_MSIX_CAP_TABLE_BIR : integer;
        PF1_MSIX_CAP_TABLE_OFFSET : string;
        PF1_MSIX_CAP_TABLE_SIZE : string;
        PF1_MSI_CAP_MULTIMSGCAP : integer;
        PF1_MSI_CAP_NEXTPTR : string;
        PF1_PB_CAP_NEXTPTR : string;
        PF1_PB_CAP_SYSTEM_ALLOCATED : string;
        PF1_PB_CAP_VER : string;
        PF1_PM_CAP_ID : string;
        PF1_PM_CAP_NEXTPTR : string;
        PF1_PM_CAP_VER_ID : string;
        PF1_RBAR_CAP_ENABLE : string;
        PF1_RBAR_CAP_INDEX0 : string;
        PF1_RBAR_CAP_INDEX1 : string;
        PF1_RBAR_CAP_INDEX2 : string;
        PF1_RBAR_CAP_NEXTPTR : string;
        PF1_RBAR_CAP_SIZE0 : string;
        PF1_RBAR_CAP_SIZE1 : string;
        PF1_RBAR_CAP_SIZE2 : string;
        PF1_RBAR_CAP_VER : string;
        PF1_RBAR_NUM : string;
        PF1_REVISION_ID : string;
        PF1_SRIOV_BAR0_APERTURE_SIZE : string;
        PF1_SRIOV_BAR0_CONTROL : string;
        PF1_SRIOV_BAR1_APERTURE_SIZE : string;
        PF1_SRIOV_BAR1_CONTROL : string;
        PF1_SRIOV_BAR2_APERTURE_SIZE : string;
        PF1_SRIOV_BAR2_CONTROL : string;
        PF1_SRIOV_BAR3_APERTURE_SIZE : string;
        PF1_SRIOV_BAR3_CONTROL : string;
        PF1_SRIOV_BAR4_APERTURE_SIZE : string;
        PF1_SRIOV_BAR4_CONTROL : string;
        PF1_SRIOV_BAR5_APERTURE_SIZE : string;
        PF1_SRIOV_BAR5_CONTROL : string;
        PF1_SRIOV_CAP_INITIAL_VF : string;
        PF1_SRIOV_CAP_NEXTPTR : string;
        PF1_SRIOV_CAP_TOTAL_VF : string;
        PF1_SRIOV_CAP_VER : string;
        PF1_SRIOV_FIRST_VF_OFFSET : string;
        PF1_SRIOV_FUNC_DEP_LINK : string;
        PF1_SRIOV_SUPPORTED_PAGE_SIZE : string;
        PF1_SRIOV_VF_DEVICE_ID : string;
        PF1_SUBSYSTEM_ID : string;
        PF1_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        PF1_TPHR_CAP_ENABLE : string;
        PF1_TPHR_CAP_INT_VEC_MODE : string;
        PF1_TPHR_CAP_NEXTPTR : string;
        PF1_TPHR_CAP_ST_MODE_SEL : string;
        PF1_TPHR_CAP_ST_TABLE_LOC : string;
        PF1_TPHR_CAP_ST_TABLE_SIZE : string;
        PF1_TPHR_CAP_VER : string;
        PL_DISABLE_EI_INFER_IN_L0 : string;
        PL_DISABLE_GEN3_DC_BALANCE : string;
        PL_DISABLE_SCRAMBLING : string;
        PL_DISABLE_UPCONFIG_CAPABLE : string;
        PL_EQ_ADAPT_DISABLE_COEFF_CHECK : string;
        PL_EQ_ADAPT_DISABLE_PRESET_CHECK : string;
        PL_EQ_ADAPT_ITER_COUNT : string;
        PL_EQ_ADAPT_REJECT_RETRY_COUNT : string;
        PL_EQ_BYPASS_PHASE23 : string;
        PL_EQ_SHORT_ADAPT_PHASE : string;
        PL_LANE0_EQ_CONTROL : string;
        PL_LANE1_EQ_CONTROL : string;
        PL_LANE2_EQ_CONTROL : string;
        PL_LANE3_EQ_CONTROL : string;
        PL_LANE4_EQ_CONTROL : string;
        PL_LANE5_EQ_CONTROL : string;
        PL_LANE6_EQ_CONTROL : string;
        PL_LANE7_EQ_CONTROL : string;
        PL_LINK_CAP_MAX_LINK_SPEED : string;
        PL_LINK_CAP_MAX_LINK_WIDTH : string;
        PL_N_FTS_COMCLK_GEN1 : integer;
        PL_N_FTS_COMCLK_GEN2 : integer;
        PL_N_FTS_COMCLK_GEN3 : integer;
        PL_N_FTS_GEN1 : integer;
        PL_N_FTS_GEN2 : integer;
        PL_N_FTS_GEN3 : integer;
        PL_SIM_FAST_LINK_TRAINING : string;
        PL_UPSTREAM_FACING : string;
        PM_ASPML0S_TIMEOUT : string;
        PM_ASPML1_ENTRY_DELAY : string;
        PM_ENABLE_SLOT_POWER_CAPTURE : string;
        PM_L1_REENTRY_DELAY : string;
        PM_PME_SERVICE_TIMEOUT_DELAY : string;
        PM_PME_TURNOFF_ACK_DELAY : string;
        SIM_VERSION : string;
        SPARE_BIT0 : integer;
        SPARE_BIT1 : integer;
        SPARE_BIT2 : integer;
        SPARE_BIT3 : integer;
        SPARE_BIT4 : integer;
        SPARE_BIT5 : integer;
        SPARE_BIT6 : integer;
        SPARE_BIT7 : integer;
        SPARE_BIT8 : integer;
        SPARE_BYTE0 : string;
        SPARE_BYTE1 : string;
        SPARE_BYTE2 : string;
        SPARE_BYTE3 : string;
        SPARE_WORD0 : string;
        SPARE_WORD1 : string;
        SPARE_WORD2 : string;
        SPARE_WORD3 : string;
        SRIOV_CAP_ENABLE : string;
        TL_COMPL_TIMEOUT_REG0 : string;
        TL_COMPL_TIMEOUT_REG1 : string;
        TL_CREDITS_CD : string;
        TL_CREDITS_CH : string;
        TL_CREDITS_NPD : string;
        TL_CREDITS_NPH : string;
        TL_CREDITS_PD : string;
        TL_CREDITS_PH : string;
        TL_ENABLE_MESSAGE_RID_CHECK_ENABLE : string;
        TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE : string;
        TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE : string;
        TL_LEGACY_MODE_ENABLE : string;
        TL_PF_ENABLE_REG : string;
        TL_TAG_MGMT_ENABLE : string;
        VF0_ARI_CAP_NEXTPTR : string;
        VF0_CAPABILITY_POINTER : string;
        VF0_MSIX_CAP_PBA_BIR : integer;
        VF0_MSIX_CAP_PBA_OFFSET : string;
        VF0_MSIX_CAP_TABLE_BIR : integer;
        VF0_MSIX_CAP_TABLE_OFFSET : string;
        VF0_MSIX_CAP_TABLE_SIZE : string;
        VF0_MSI_CAP_MULTIMSGCAP : integer;
        VF0_PM_CAP_ID : string;
        VF0_PM_CAP_NEXTPTR : string;
        VF0_PM_CAP_VER_ID : string;
        VF0_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        VF0_TPHR_CAP_ENABLE : string;
        VF0_TPHR_CAP_INT_VEC_MODE : string;
        VF0_TPHR_CAP_NEXTPTR : string;
        VF0_TPHR_CAP_ST_MODE_SEL : string;
        VF0_TPHR_CAP_ST_TABLE_LOC : string;
        VF0_TPHR_CAP_ST_TABLE_SIZE : string;
        VF0_TPHR_CAP_VER : string;
        VF1_ARI_CAP_NEXTPTR : string;
        VF1_MSIX_CAP_PBA_BIR : integer;
        VF1_MSIX_CAP_PBA_OFFSET : string;
        VF1_MSIX_CAP_TABLE_BIR : integer;
        VF1_MSIX_CAP_TABLE_OFFSET : string;
        VF1_MSIX_CAP_TABLE_SIZE : string;
        VF1_MSI_CAP_MULTIMSGCAP : integer;
        VF1_PM_CAP_ID : string;
        VF1_PM_CAP_NEXTPTR : string;
        VF1_PM_CAP_VER_ID : string;
        VF1_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        VF1_TPHR_CAP_ENABLE : string;
        VF1_TPHR_CAP_INT_VEC_MODE : string;
        VF1_TPHR_CAP_NEXTPTR : string;
        VF1_TPHR_CAP_ST_MODE_SEL : string;
        VF1_TPHR_CAP_ST_TABLE_LOC : string;
        VF1_TPHR_CAP_ST_TABLE_SIZE : string;
        VF1_TPHR_CAP_VER : string;
        VF2_ARI_CAP_NEXTPTR : string;
        VF2_MSIX_CAP_PBA_BIR : integer;
        VF2_MSIX_CAP_PBA_OFFSET : string;
        VF2_MSIX_CAP_TABLE_BIR : integer;
        VF2_MSIX_CAP_TABLE_OFFSET : string;
        VF2_MSIX_CAP_TABLE_SIZE : string;
        VF2_MSI_CAP_MULTIMSGCAP : integer;
        VF2_PM_CAP_ID : string;
        VF2_PM_CAP_NEXTPTR : string;
        VF2_PM_CAP_VER_ID : string;
        VF2_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        VF2_TPHR_CAP_ENABLE : string;
        VF2_TPHR_CAP_INT_VEC_MODE : string;
        VF2_TPHR_CAP_NEXTPTR : string;
        VF2_TPHR_CAP_ST_MODE_SEL : string;
        VF2_TPHR_CAP_ST_TABLE_LOC : string;
        VF2_TPHR_CAP_ST_TABLE_SIZE : string;
        VF2_TPHR_CAP_VER : string;
        VF3_ARI_CAP_NEXTPTR : string;
        VF3_MSIX_CAP_PBA_BIR : integer;
        VF3_MSIX_CAP_PBA_OFFSET : string;
        VF3_MSIX_CAP_TABLE_BIR : integer;
        VF3_MSIX_CAP_TABLE_OFFSET : string;
        VF3_MSIX_CAP_TABLE_SIZE : string;
        VF3_MSI_CAP_MULTIMSGCAP : integer;
        VF3_PM_CAP_ID : string;
        VF3_PM_CAP_NEXTPTR : string;
        VF3_PM_CAP_VER_ID : string;
        VF3_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        VF3_TPHR_CAP_ENABLE : string;
        VF3_TPHR_CAP_INT_VEC_MODE : string;
        VF3_TPHR_CAP_NEXTPTR : string;
        VF3_TPHR_CAP_ST_MODE_SEL : string;
        VF3_TPHR_CAP_ST_TABLE_LOC : string;
        VF3_TPHR_CAP_ST_TABLE_SIZE : string;
        VF3_TPHR_CAP_VER : string;
        VF4_ARI_CAP_NEXTPTR : string;
        VF4_MSIX_CAP_PBA_BIR : integer;
        VF4_MSIX_CAP_PBA_OFFSET : string;
        VF4_MSIX_CAP_TABLE_BIR : integer;
        VF4_MSIX_CAP_TABLE_OFFSET : string;
        VF4_MSIX_CAP_TABLE_SIZE : string;
        VF4_MSI_CAP_MULTIMSGCAP : integer;
        VF4_PM_CAP_ID : string;
        VF4_PM_CAP_NEXTPTR : string;
        VF4_PM_CAP_VER_ID : string;
        VF4_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        VF4_TPHR_CAP_ENABLE : string;
        VF4_TPHR_CAP_INT_VEC_MODE : string;
        VF4_TPHR_CAP_NEXTPTR : string;
        VF4_TPHR_CAP_ST_MODE_SEL : string;
        VF4_TPHR_CAP_ST_TABLE_LOC : string;
        VF4_TPHR_CAP_ST_TABLE_SIZE : string;
        VF4_TPHR_CAP_VER : string;
        VF5_ARI_CAP_NEXTPTR : string;
        VF5_MSIX_CAP_PBA_BIR : integer;
        VF5_MSIX_CAP_PBA_OFFSET : string;
        VF5_MSIX_CAP_TABLE_BIR : integer;
        VF5_MSIX_CAP_TABLE_OFFSET : string;
        VF5_MSIX_CAP_TABLE_SIZE : string;
        VF5_MSI_CAP_MULTIMSGCAP : integer;
        VF5_PM_CAP_ID : string;
        VF5_PM_CAP_NEXTPTR : string;
        VF5_PM_CAP_VER_ID : string;
        VF5_TPHR_CAP_DEV_SPECIFIC_MODE : string;
        VF5_TPHR_CAP_ENABLE : string;
        VF5_TPHR_CAP_INT_VEC_MODE : string;
        VF5_TPHR_CAP_NEXTPTR : string;
        VF5_TPHR_CAP_ST_MODE_SEL : string;
        VF5_TPHR_CAP_ST_TABLE_LOC : string;
        VF5_TPHR_CAP_ST_TABLE_SIZE : string;
        VF5_TPHR_CAP_VER : string        
      );
      
      port (
        CFGCURRENTSPEED      : out std_logic_vector(2 downto 0);
        CFGDPASUBSTATECHANGE : out std_logic_vector(1 downto 0);
        CFGERRCOROUT         : out std_ulogic;
        CFGERRFATALOUT       : out std_ulogic;
        CFGERRNONFATALOUT    : out std_ulogic;
        CFGEXTFUNCTIONNUMBER : out std_logic_vector(7 downto 0);
        CFGEXTREADRECEIVED   : out std_ulogic;
        CFGEXTREGISTERNUMBER : out std_logic_vector(9 downto 0);
        CFGEXTWRITEBYTEENABLE : out std_logic_vector(3 downto 0);
        CFGEXTWRITEDATA      : out std_logic_vector(31 downto 0);
        CFGEXTWRITERECEIVED  : out std_ulogic;
        CFGFCCPLD            : out std_logic_vector(11 downto 0);
        CFGFCCPLH            : out std_logic_vector(7 downto 0);
        CFGFCNPD             : out std_logic_vector(11 downto 0);
        CFGFCNPH             : out std_logic_vector(7 downto 0);
        CFGFCPD              : out std_logic_vector(11 downto 0);
        CFGFCPH              : out std_logic_vector(7 downto 0);
        CFGFLRINPROCESS      : out std_logic_vector(1 downto 0);
        CFGFUNCTIONPOWERSTATE : out std_logic_vector(5 downto 0);
        CFGFUNCTIONSTATUS    : out std_logic_vector(7 downto 0);
        CFGHOTRESETOUT       : out std_ulogic;
        CFGINPUTUPDATEDONE   : out std_ulogic;
        CFGINTERRUPTAOUTPUT  : out std_ulogic;
        CFGINTERRUPTBOUTPUT  : out std_ulogic;
        CFGINTERRUPTCOUTPUT  : out std_ulogic;
        CFGINTERRUPTDOUTPUT  : out std_ulogic;
        CFGINTERRUPTMSIDATA  : out std_logic_vector(31 downto 0);
        CFGINTERRUPTMSIENABLE : out std_logic_vector(1 downto 0);
        CFGINTERRUPTMSIFAIL  : out std_ulogic;
        CFGINTERRUPTMSIMASKUPDATE : out std_ulogic;
        CFGINTERRUPTMSIMMENABLE : out std_logic_vector(5 downto 0);
        CFGINTERRUPTMSISENT  : out std_ulogic;
        CFGINTERRUPTMSIVFENABLE : out std_logic_vector(5 downto 0);
        CFGINTERRUPTMSIXENABLE : out std_logic_vector(1 downto 0);
        CFGINTERRUPTMSIXFAIL : out std_ulogic;
        CFGINTERRUPTMSIXMASK : out std_logic_vector(1 downto 0);
        CFGINTERRUPTMSIXSENT : out std_ulogic;
        CFGINTERRUPTMSIXVFENABLE : out std_logic_vector(5 downto 0);
        CFGINTERRUPTMSIXVFMASK : out std_logic_vector(5 downto 0);
        CFGINTERRUPTSENT     : out std_ulogic;
        CFGLINKPOWERSTATE    : out std_logic_vector(1 downto 0);
        CFGLOCALERROR        : out std_ulogic;
        CFGLTRENABLE         : out std_ulogic;
        CFGLTSSMSTATE        : out std_logic_vector(5 downto 0);
        CFGMAXPAYLOAD        : out std_logic_vector(2 downto 0);
        CFGMAXREADREQ        : out std_logic_vector(2 downto 0);
        CFGMCUPDATEDONE      : out std_ulogic;
        CFGMGMTREADDATA      : out std_logic_vector(31 downto 0);
        CFGMGMTREADWRITEDONE : out std_ulogic;
        CFGMSGRECEIVED       : out std_ulogic;
        CFGMSGRECEIVEDDATA   : out std_logic_vector(7 downto 0);
        CFGMSGRECEIVEDTYPE   : out std_logic_vector(4 downto 0);
        CFGMSGTRANSMITDONE   : out std_ulogic;
        CFGNEGOTIATEDWIDTH   : out std_logic_vector(3 downto 0);
        CFGOBFFENABLE        : out std_logic_vector(1 downto 0);
        CFGPERFUNCSTATUSDATA : out std_logic_vector(15 downto 0);
        CFGPERFUNCTIONUPDATEDONE : out std_ulogic;
        CFGPHYLINKDOWN       : out std_ulogic;
        CFGPHYLINKSTATUS     : out std_logic_vector(1 downto 0);
        CFGPLSTATUSCHANGE    : out std_ulogic;
        CFGPOWERSTATECHANGEINTERRUPT : out std_ulogic;
        CFGRCBSTATUS         : out std_logic_vector(1 downto 0);
        CFGTPHFUNCTIONNUM    : out std_logic_vector(2 downto 0);
        CFGTPHREQUESTERENABLE : out std_logic_vector(1 downto 0);
        CFGTPHSTMODE         : out std_logic_vector(5 downto 0);
        CFGTPHSTTADDRESS     : out std_logic_vector(4 downto 0);
        CFGTPHSTTREADENABLE  : out std_ulogic;
        CFGTPHSTTWRITEBYTEVALID : out std_logic_vector(3 downto 0);
        CFGTPHSTTWRITEDATA   : out std_logic_vector(31 downto 0);
        CFGTPHSTTWRITEENABLE : out std_ulogic;
        CFGVFFLRINPROCESS    : out std_logic_vector(5 downto 0);
        CFGVFPOWERSTATE      : out std_logic_vector(17 downto 0);
        CFGVFSTATUS          : out std_logic_vector(11 downto 0);
        CFGVFTPHREQUESTERENABLE : out std_logic_vector(5 downto 0);
        CFGVFTPHSTMODE       : out std_logic_vector(17 downto 0);
        DBGDATAOUT           : out std_logic_vector(15 downto 0);
        DRPDO                : out std_logic_vector(15 downto 0);
        DRPRDY               : out std_ulogic;
        MAXISCQTDATA         : out std_logic_vector(255 downto 0);
        MAXISCQTKEEP         : out std_logic_vector(7 downto 0);
        MAXISCQTLAST         : out std_ulogic;
        MAXISCQTUSER         : out std_logic_vector(84 downto 0);
        MAXISCQTVALID        : out std_ulogic;
        MAXISRCTDATA         : out std_logic_vector(255 downto 0);
        MAXISRCTKEEP         : out std_logic_vector(7 downto 0);
        MAXISRCTLAST         : out std_ulogic;
        MAXISRCTUSER         : out std_logic_vector(74 downto 0);
        MAXISRCTVALID        : out std_ulogic;
        MICOMPLETIONRAMREADADDRESSAL : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMREADADDRESSAU : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMREADADDRESSBL : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMREADADDRESSBU : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMREADENABLEL : out std_logic_vector(3 downto 0);
        MICOMPLETIONRAMREADENABLEU : out std_logic_vector(3 downto 0);
        MICOMPLETIONRAMWRITEADDRESSAL : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMWRITEADDRESSAU : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMWRITEADDRESSBL : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMWRITEADDRESSBU : out std_logic_vector(9 downto 0);
        MICOMPLETIONRAMWRITEDATAL : out std_logic_vector(71 downto 0);
        MICOMPLETIONRAMWRITEDATAU : out std_logic_vector(71 downto 0);
        MICOMPLETIONRAMWRITEENABLEL : out std_logic_vector(3 downto 0);
        MICOMPLETIONRAMWRITEENABLEU : out std_logic_vector(3 downto 0);
        MIREPLAYRAMADDRESS   : out std_logic_vector(8 downto 0);
        MIREPLAYRAMREADENABLE : out std_logic_vector(1 downto 0);
        MIREPLAYRAMWRITEDATA : out std_logic_vector(143 downto 0);
        MIREPLAYRAMWRITEENABLE : out std_logic_vector(1 downto 0);
        MIREQUESTRAMREADADDRESSA : out std_logic_vector(8 downto 0);
        MIREQUESTRAMREADADDRESSB : out std_logic_vector(8 downto 0);
        MIREQUESTRAMREADENABLE : out std_logic_vector(3 downto 0);
        MIREQUESTRAMWRITEADDRESSA : out std_logic_vector(8 downto 0);
        MIREQUESTRAMWRITEADDRESSB : out std_logic_vector(8 downto 0);
        MIREQUESTRAMWRITEDATA : out std_logic_vector(143 downto 0);
        MIREQUESTRAMWRITEENABLE : out std_logic_vector(3 downto 0);
        PCIECQNPREQCOUNT     : out std_logic_vector(5 downto 0);
        PCIERQSEQNUM         : out std_logic_vector(3 downto 0);
        PCIERQSEQNUMVLD      : out std_ulogic;
        PCIERQTAG            : out std_logic_vector(5 downto 0);
        PCIERQTAGAV          : out std_logic_vector(1 downto 0);
        PCIERQTAGVLD         : out std_ulogic;
        PCIETFCNPDAV         : out std_logic_vector(1 downto 0);
        PCIETFCNPHAV         : out std_logic_vector(1 downto 0);
        PIPERX0EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX0EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX0EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX0EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX0POLARITY      : out std_ulogic;
        PIPERX1EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX1EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX1EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX1EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX1POLARITY      : out std_ulogic;
        PIPERX2EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX2EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX2EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX2EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX2POLARITY      : out std_ulogic;
        PIPERX3EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX3EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX3EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX3EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX3POLARITY      : out std_ulogic;
        PIPERX4EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX4EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX4EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX4EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX4POLARITY      : out std_ulogic;
        PIPERX5EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX5EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX5EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX5EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX5POLARITY      : out std_ulogic;
        PIPERX6EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX6EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX6EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX6EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX6POLARITY      : out std_ulogic;
        PIPERX7EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPERX7EQLPLFFS      : out std_logic_vector(5 downto 0);
        PIPERX7EQLPTXPRESET  : out std_logic_vector(3 downto 0);
        PIPERX7EQPRESET      : out std_logic_vector(2 downto 0);
        PIPERX7POLARITY      : out std_ulogic;
        PIPETX0CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX0COMPLIANCE    : out std_ulogic;
        PIPETX0DATA          : out std_logic_vector(31 downto 0);
        PIPETX0DATAVALID     : out std_ulogic;
        PIPETX0ELECIDLE      : out std_ulogic;
        PIPETX0EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX0EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX0EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX0POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX0STARTBLOCK    : out std_ulogic;
        PIPETX0SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETX1CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX1COMPLIANCE    : out std_ulogic;
        PIPETX1DATA          : out std_logic_vector(31 downto 0);
        PIPETX1DATAVALID     : out std_ulogic;
        PIPETX1ELECIDLE      : out std_ulogic;
        PIPETX1EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX1EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX1EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX1POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX1STARTBLOCK    : out std_ulogic;
        PIPETX1SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETX2CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX2COMPLIANCE    : out std_ulogic;
        PIPETX2DATA          : out std_logic_vector(31 downto 0);
        PIPETX2DATAVALID     : out std_ulogic;
        PIPETX2ELECIDLE      : out std_ulogic;
        PIPETX2EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX2EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX2EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX2POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX2STARTBLOCK    : out std_ulogic;
        PIPETX2SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETX3CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX3COMPLIANCE    : out std_ulogic;
        PIPETX3DATA          : out std_logic_vector(31 downto 0);
        PIPETX3DATAVALID     : out std_ulogic;
        PIPETX3ELECIDLE      : out std_ulogic;
        PIPETX3EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX3EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX3EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX3POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX3STARTBLOCK    : out std_ulogic;
        PIPETX3SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETX4CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX4COMPLIANCE    : out std_ulogic;
        PIPETX4DATA          : out std_logic_vector(31 downto 0);
        PIPETX4DATAVALID     : out std_ulogic;
        PIPETX4ELECIDLE      : out std_ulogic;
        PIPETX4EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX4EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX4EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX4POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX4STARTBLOCK    : out std_ulogic;
        PIPETX4SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETX5CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX5COMPLIANCE    : out std_ulogic;
        PIPETX5DATA          : out std_logic_vector(31 downto 0);
        PIPETX5DATAVALID     : out std_ulogic;
        PIPETX5ELECIDLE      : out std_ulogic;
        PIPETX5EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX5EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX5EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX5POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX5STARTBLOCK    : out std_ulogic;
        PIPETX5SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETX6CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX6COMPLIANCE    : out std_ulogic;
        PIPETX6DATA          : out std_logic_vector(31 downto 0);
        PIPETX6DATAVALID     : out std_ulogic;
        PIPETX6ELECIDLE      : out std_ulogic;
        PIPETX6EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX6EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX6EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX6POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX6STARTBLOCK    : out std_ulogic;
        PIPETX6SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETX7CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX7COMPLIANCE    : out std_ulogic;
        PIPETX7DATA          : out std_logic_vector(31 downto 0);
        PIPETX7DATAVALID     : out std_ulogic;
        PIPETX7ELECIDLE      : out std_ulogic;
        PIPETX7EQCONTROL     : out std_logic_vector(1 downto 0);
        PIPETX7EQDEEMPH      : out std_logic_vector(5 downto 0);
        PIPETX7EQPRESET      : out std_logic_vector(3 downto 0);
        PIPETX7POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX7STARTBLOCK    : out std_ulogic;
        PIPETX7SYNCHEADER    : out std_logic_vector(1 downto 0);
        PIPETXDEEMPH         : out std_ulogic;
        PIPETXMARGIN         : out std_logic_vector(2 downto 0);
        PIPETXRATE           : out std_logic_vector(1 downto 0);
        PIPETXRCVRDET        : out std_ulogic;
        PIPETXRESET          : out std_ulogic;
        PIPETXSWING          : out std_ulogic;
        PLEQINPROGRESS       : out std_ulogic;
        PLEQPHASE            : out std_logic_vector(1 downto 0);
        PLGEN3PCSRXSLIDE     : out std_logic_vector(7 downto 0);
        SAXISCCTREADY        : out std_logic_vector(3 downto 0);
        SAXISRQTREADY        : out std_logic_vector(3 downto 0);
        CFGCONFIGSPACEENABLE : in std_ulogic;
        CFGDEVID             : in std_logic_vector(15 downto 0);
        CFGDSBUSNUMBER       : in std_logic_vector(7 downto 0);
        CFGDSDEVICENUMBER    : in std_logic_vector(4 downto 0);
        CFGDSFUNCTIONNUMBER  : in std_logic_vector(2 downto 0);
        CFGDSN               : in std_logic_vector(63 downto 0);
        CFGDSPORTNUMBER      : in std_logic_vector(7 downto 0);
        CFGERRCORIN          : in std_ulogic;
        CFGERRUNCORIN        : in std_ulogic;
        CFGEXTREADDATA       : in std_logic_vector(31 downto 0);
        CFGEXTREADDATAVALID  : in std_ulogic;
        CFGFCSEL             : in std_logic_vector(2 downto 0);
        CFGFLRDONE           : in std_logic_vector(1 downto 0);
        CFGHOTRESETIN        : in std_ulogic;
        CFGINPUTUPDATEREQUEST : in std_ulogic;
        CFGINTERRUPTINT      : in std_logic_vector(3 downto 0);
        CFGINTERRUPTMSIATTR  : in std_logic_vector(2 downto 0);
        CFGINTERRUPTMSIFUNCTIONNUMBER : in std_logic_vector(2 downto 0);
        CFGINTERRUPTMSIINT   : in std_logic_vector(31 downto 0);
        CFGINTERRUPTMSIPENDINGSTATUS : in std_logic_vector(63 downto 0);
        CFGINTERRUPTMSISELECT : in std_logic_vector(3 downto 0);
        CFGINTERRUPTMSITPHPRESENT : in std_ulogic;
        CFGINTERRUPTMSITPHSTTAG : in std_logic_vector(8 downto 0);
        CFGINTERRUPTMSITPHTYPE : in std_logic_vector(1 downto 0);
        CFGINTERRUPTMSIXADDRESS : in std_logic_vector(63 downto 0);
        CFGINTERRUPTMSIXDATA : in std_logic_vector(31 downto 0);
        CFGINTERRUPTMSIXINT  : in std_ulogic;
        CFGINTERRUPTPENDING  : in std_logic_vector(1 downto 0);
        CFGLINKTRAININGENABLE : in std_ulogic;
        CFGMCUPDATEREQUEST   : in std_ulogic;
        CFGMGMTADDR          : in std_logic_vector(18 downto 0);
        CFGMGMTBYTEENABLE    : in std_logic_vector(3 downto 0);
        CFGMGMTREAD          : in std_ulogic;
        CFGMGMTTYPE1CFGREGACCESS : in std_ulogic;
        CFGMGMTWRITE         : in std_ulogic;
        CFGMGMTWRITEDATA     : in std_logic_vector(31 downto 0);
        CFGMSGTRANSMIT       : in std_ulogic;
        CFGMSGTRANSMITDATA   : in std_logic_vector(31 downto 0);
        CFGMSGTRANSMITTYPE   : in std_logic_vector(2 downto 0);
        CFGPERFUNCSTATUSCONTROL : in std_logic_vector(2 downto 0);
        CFGPERFUNCTIONNUMBER : in std_logic_vector(2 downto 0);
        CFGPERFUNCTIONOUTPUTREQUEST : in std_ulogic;
        CFGPOWERSTATECHANGEACK : in std_ulogic;
        CFGREQPMTRANSITIONL23READY : in std_ulogic;
        CFGREVID             : in std_logic_vector(7 downto 0);
        CFGSUBSYSID          : in std_logic_vector(15 downto 0);
        CFGSUBSYSVENDID      : in std_logic_vector(15 downto 0);
        CFGTPHSTTREADDATA    : in std_logic_vector(31 downto 0);
        CFGTPHSTTREADDATAVALID : in std_ulogic;
        CFGVENDID            : in std_logic_vector(15 downto 0);
        CFGVFFLRDONE         : in std_logic_vector(5 downto 0);
        CORECLK              : in std_ulogic;
        CORECLKMICOMPLETIONRAML : in std_ulogic;
        CORECLKMICOMPLETIONRAMU : in std_ulogic;
        CORECLKMIREPLAYRAM   : in std_ulogic;
        CORECLKMIREQUESTRAM  : in std_ulogic;
        DRPADDR              : in std_logic_vector(10 downto 0);
        DRPCLK               : in std_ulogic;
        DRPDI                : in std_logic_vector(15 downto 0);
        DRPEN                : in std_ulogic;
        DRPWE                : in std_ulogic;
        MAXISCQTREADY        : in std_logic_vector(21 downto 0);
        MAXISRCTREADY        : in std_logic_vector(21 downto 0);
        MGMTRESETN           : in std_ulogic;
        MGMTSTICKYRESETN     : in std_ulogic;
        MICOMPLETIONRAMREADDATA : in std_logic_vector(143 downto 0);
        MIREPLAYRAMREADDATA  : in std_logic_vector(143 downto 0);
        MIREQUESTRAMREADDATA : in std_logic_vector(143 downto 0);
        PCIECQNPREQ          : in std_ulogic;
        PIPECLK              : in std_ulogic;
        PIPEEQFS             : in std_logic_vector(5 downto 0);
        PIPEEQLF             : in std_logic_vector(5 downto 0);
        PIPERESETN           : in std_ulogic;
        PIPERX0CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX0DATA          : in std_logic_vector(31 downto 0);
        PIPERX0DATAVALID     : in std_ulogic;
        PIPERX0ELECIDLE      : in std_ulogic;
        PIPERX0EQDONE        : in std_ulogic;
        PIPERX0EQLPADAPTDONE : in std_ulogic;
        PIPERX0EQLPLFFSSEL   : in std_ulogic;
        PIPERX0EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX0PHYSTATUS     : in std_ulogic;
        PIPERX0STARTBLOCK    : in std_ulogic;
        PIPERX0STATUS        : in std_logic_vector(2 downto 0);
        PIPERX0SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX0VALID         : in std_ulogic;
        PIPERX1CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX1DATA          : in std_logic_vector(31 downto 0);
        PIPERX1DATAVALID     : in std_ulogic;
        PIPERX1ELECIDLE      : in std_ulogic;
        PIPERX1EQDONE        : in std_ulogic;
        PIPERX1EQLPADAPTDONE : in std_ulogic;
        PIPERX1EQLPLFFSSEL   : in std_ulogic;
        PIPERX1EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX1PHYSTATUS     : in std_ulogic;
        PIPERX1STARTBLOCK    : in std_ulogic;
        PIPERX1STATUS        : in std_logic_vector(2 downto 0);
        PIPERX1SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX1VALID         : in std_ulogic;
        PIPERX2CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX2DATA          : in std_logic_vector(31 downto 0);
        PIPERX2DATAVALID     : in std_ulogic;
        PIPERX2ELECIDLE      : in std_ulogic;
        PIPERX2EQDONE        : in std_ulogic;
        PIPERX2EQLPADAPTDONE : in std_ulogic;
        PIPERX2EQLPLFFSSEL   : in std_ulogic;
        PIPERX2EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX2PHYSTATUS     : in std_ulogic;
        PIPERX2STARTBLOCK    : in std_ulogic;
        PIPERX2STATUS        : in std_logic_vector(2 downto 0);
        PIPERX2SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX2VALID         : in std_ulogic;
        PIPERX3CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX3DATA          : in std_logic_vector(31 downto 0);
        PIPERX3DATAVALID     : in std_ulogic;
        PIPERX3ELECIDLE      : in std_ulogic;
        PIPERX3EQDONE        : in std_ulogic;
        PIPERX3EQLPADAPTDONE : in std_ulogic;
        PIPERX3EQLPLFFSSEL   : in std_ulogic;
        PIPERX3EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX3PHYSTATUS     : in std_ulogic;
        PIPERX3STARTBLOCK    : in std_ulogic;
        PIPERX3STATUS        : in std_logic_vector(2 downto 0);
        PIPERX3SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX3VALID         : in std_ulogic;
        PIPERX4CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX4DATA          : in std_logic_vector(31 downto 0);
        PIPERX4DATAVALID     : in std_ulogic;
        PIPERX4ELECIDLE      : in std_ulogic;
        PIPERX4EQDONE        : in std_ulogic;
        PIPERX4EQLPADAPTDONE : in std_ulogic;
        PIPERX4EQLPLFFSSEL   : in std_ulogic;
        PIPERX4EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX4PHYSTATUS     : in std_ulogic;
        PIPERX4STARTBLOCK    : in std_ulogic;
        PIPERX4STATUS        : in std_logic_vector(2 downto 0);
        PIPERX4SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX4VALID         : in std_ulogic;
        PIPERX5CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX5DATA          : in std_logic_vector(31 downto 0);
        PIPERX5DATAVALID     : in std_ulogic;
        PIPERX5ELECIDLE      : in std_ulogic;
        PIPERX5EQDONE        : in std_ulogic;
        PIPERX5EQLPADAPTDONE : in std_ulogic;
        PIPERX5EQLPLFFSSEL   : in std_ulogic;
        PIPERX5EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX5PHYSTATUS     : in std_ulogic;
        PIPERX5STARTBLOCK    : in std_ulogic;
        PIPERX5STATUS        : in std_logic_vector(2 downto 0);
        PIPERX5SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX5VALID         : in std_ulogic;
        PIPERX6CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX6DATA          : in std_logic_vector(31 downto 0);
        PIPERX6DATAVALID     : in std_ulogic;
        PIPERX6ELECIDLE      : in std_ulogic;
        PIPERX6EQDONE        : in std_ulogic;
        PIPERX6EQLPADAPTDONE : in std_ulogic;
        PIPERX6EQLPLFFSSEL   : in std_ulogic;
        PIPERX6EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX6PHYSTATUS     : in std_ulogic;
        PIPERX6STARTBLOCK    : in std_ulogic;
        PIPERX6STATUS        : in std_logic_vector(2 downto 0);
        PIPERX6SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX6VALID         : in std_ulogic;
        PIPERX7CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX7DATA          : in std_logic_vector(31 downto 0);
        PIPERX7DATAVALID     : in std_ulogic;
        PIPERX7ELECIDLE      : in std_ulogic;
        PIPERX7EQDONE        : in std_ulogic;
        PIPERX7EQLPADAPTDONE : in std_ulogic;
        PIPERX7EQLPLFFSSEL   : in std_ulogic;
        PIPERX7EQLPNEWTXCOEFFORPRESET : in std_logic_vector(17 downto 0);
        PIPERX7PHYSTATUS     : in std_ulogic;
        PIPERX7STARTBLOCK    : in std_ulogic;
        PIPERX7STATUS        : in std_logic_vector(2 downto 0);
        PIPERX7SYNCHEADER    : in std_logic_vector(1 downto 0);
        PIPERX7VALID         : in std_ulogic;
        PIPETX0EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX0EQDONE        : in std_ulogic;
        PIPETX1EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX1EQDONE        : in std_ulogic;
        PIPETX2EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX2EQDONE        : in std_ulogic;
        PIPETX3EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX3EQDONE        : in std_ulogic;
        PIPETX4EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX4EQDONE        : in std_ulogic;
        PIPETX5EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX5EQDONE        : in std_ulogic;
        PIPETX6EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX6EQDONE        : in std_ulogic;
        PIPETX7EQCOEFF       : in std_logic_vector(17 downto 0);
        PIPETX7EQDONE        : in std_ulogic;
        PLDISABLESCRAMBLER   : in std_ulogic;
        PLEQRESETEIEOSCOUNT  : in std_ulogic;
        PLGEN3PCSDISABLE     : in std_ulogic;
        PLGEN3PCSRXSYNCDONE  : in std_logic_vector(7 downto 0);
        RECCLK               : in std_ulogic;
        RESETN               : in std_ulogic;
        SAXISCCTDATA         : in std_logic_vector(255 downto 0);
        SAXISCCTKEEP         : in std_logic_vector(7 downto 0);
        SAXISCCTLAST         : in std_ulogic;
        SAXISCCTUSER         : in std_logic_vector(32 downto 0);
        SAXISCCTVALID        : in std_ulogic;
        SAXISRQTDATA         : in std_logic_vector(255 downto 0);
        SAXISRQTKEEP         : in std_logic_vector(7 downto 0);
        SAXISRQTLAST         : in std_ulogic;
        SAXISRQTUSER         : in std_logic_vector(59 downto 0);
        SAXISRQTVALID        : in std_ulogic;
        USERCLK              : in std_ulogic        
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
    constant AXISTEN_IF_ENABLE_MSG_ROUTE_BINARY : std_logic_vector(17 downto 0) := To_StdLogicVector(AXISTEN_IF_ENABLE_MSG_ROUTE)(17 downto 0);
    constant AXISTEN_IF_WIDTH_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(AXISTEN_IF_WIDTH)(1 downto 0);
    constant CRM_USER_CLK_FREQ_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(CRM_USER_CLK_FREQ)(1 downto 0);
    constant DNSTREAM_LINK_NUM_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(DNSTREAM_LINK_NUM)(7 downto 0);
    constant GEN3_PCS_AUTO_REALIGN_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(GEN3_PCS_AUTO_REALIGN)(1 downto 0);
    constant LL_ACK_TIMEOUT_BINARY : std_logic_vector(8 downto 0) := To_StdLogicVector(LL_ACK_TIMEOUT)(8 downto 0);
    constant LL_CPL_FC_UPDATE_TIMER_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LL_CPL_FC_UPDATE_TIMER)(15 downto 0);
    constant LL_FC_UPDATE_TIMER_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LL_FC_UPDATE_TIMER)(15 downto 0);
    constant LL_NP_FC_UPDATE_TIMER_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LL_NP_FC_UPDATE_TIMER)(15 downto 0);
    constant LL_P_FC_UPDATE_TIMER_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LL_P_FC_UPDATE_TIMER)(15 downto 0);
    constant LL_REPLAY_TIMEOUT_BINARY : std_logic_vector(8 downto 0) := To_StdLogicVector(LL_REPLAY_TIMEOUT)(8 downto 0);
    constant LTR_TX_MESSAGE_MINIMUM_INTERVAL_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(LTR_TX_MESSAGE_MINIMUM_INTERVAL)(9 downto 0);
    constant PF0_AER_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_AER_CAP_NEXTPTR)(11 downto 0);
    constant PF0_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_ARI_CAP_NEXTPTR)(11 downto 0);
    constant PF0_ARI_CAP_NEXT_FUNC_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_ARI_CAP_NEXT_FUNC)(7 downto 0);
    constant PF0_ARI_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_ARI_CAP_VER)(3 downto 0);
    constant PF0_BAR0_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_BAR0_APERTURE_SIZE)(4 downto 0);
    constant PF0_BAR0_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_BAR0_CONTROL)(2 downto 0);
    constant PF0_BAR1_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_BAR1_APERTURE_SIZE)(4 downto 0);
    constant PF0_BAR1_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_BAR1_CONTROL)(2 downto 0);
    constant PF0_BAR2_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_BAR2_APERTURE_SIZE)(4 downto 0);
    constant PF0_BAR2_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_BAR2_CONTROL)(2 downto 0);
    constant PF0_BAR3_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_BAR3_APERTURE_SIZE)(4 downto 0);
    constant PF0_BAR3_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_BAR3_CONTROL)(2 downto 0);
    constant PF0_BAR4_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_BAR4_APERTURE_SIZE)(4 downto 0);
    constant PF0_BAR4_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_BAR4_CONTROL)(2 downto 0);
    constant PF0_BAR5_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_BAR5_APERTURE_SIZE)(4 downto 0);
    constant PF0_BAR5_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_BAR5_CONTROL)(2 downto 0);
    constant PF0_BIST_REGISTER_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_BIST_REGISTER)(7 downto 0);
    constant PF0_CAPABILITY_POINTER_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_CAPABILITY_POINTER)(7 downto 0);
    constant PF0_CLASS_CODE_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(PF0_CLASS_CODE)(23 downto 0);
    constant PF0_DEVICE_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF0_DEVICE_ID)(15 downto 0);
    constant PF0_DEV_CAP2_OBFF_SUPPORT_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PF0_DEV_CAP2_OBFF_SUPPORT)(1 downto 0);
    constant PF0_DEV_CAP_MAX_PAYLOAD_SIZE_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_DEV_CAP_MAX_PAYLOAD_SIZE)(2 downto 0);
    constant PF0_DPA_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_DPA_CAP_NEXTPTR)(11 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_CONTROL_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_CONTROL)(4 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0)(7 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1)(7 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2)(7 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3)(7 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4)(7 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5)(7 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6)(7 downto 0);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7)(7 downto 0);
    constant PF0_DPA_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_DPA_CAP_VER)(3 downto 0);
    constant PF0_DSN_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_DSN_CAP_NEXTPTR)(11 downto 0);
    constant PF0_EXPANSION_ROM_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_EXPANSION_ROM_APERTURE_SIZE)(4 downto 0);
    constant PF0_INTERRUPT_LINE_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_INTERRUPT_LINE)(7 downto 0);
    constant PF0_INTERRUPT_PIN_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_INTERRUPT_PIN)(2 downto 0);
    constant PF0_LTR_CAP_MAX_NOSNOOP_LAT_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(PF0_LTR_CAP_MAX_NOSNOOP_LAT)(9 downto 0);
    constant PF0_LTR_CAP_MAX_SNOOP_LAT_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(PF0_LTR_CAP_MAX_SNOOP_LAT)(9 downto 0);
    constant PF0_LTR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_LTR_CAP_NEXTPTR)(11 downto 0);
    constant PF0_LTR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_LTR_CAP_VER)(3 downto 0);
    constant PF0_MSIX_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_MSIX_CAP_NEXTPTR)(7 downto 0);
    constant PF0_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(PF0_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant PF0_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(PF0_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant PF0_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(PF0_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant PF0_MSI_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_MSI_CAP_NEXTPTR)(7 downto 0);
    constant PF0_PB_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_PB_CAP_NEXTPTR)(11 downto 0);
    constant PF0_PB_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_PB_CAP_VER)(3 downto 0);
    constant PF0_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_PM_CAP_ID)(7 downto 0);
    constant PF0_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_PM_CAP_NEXTPTR)(7 downto 0);
    constant PF0_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_PM_CAP_VER_ID)(2 downto 0);
    constant PF0_RBAR_CAP_INDEX0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_INDEX0)(2 downto 0);
    constant PF0_RBAR_CAP_INDEX1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_INDEX1)(2 downto 0);
    constant PF0_RBAR_CAP_INDEX2_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_INDEX2)(2 downto 0);
    constant PF0_RBAR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_NEXTPTR)(11 downto 0);
    constant PF0_RBAR_CAP_SIZE0_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_SIZE0)(19 downto 0);
    constant PF0_RBAR_CAP_SIZE1_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_SIZE1)(19 downto 0);
    constant PF0_RBAR_CAP_SIZE2_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_SIZE2)(19 downto 0);
    constant PF0_RBAR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_RBAR_CAP_VER)(3 downto 0);
    constant PF0_RBAR_NUM_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_RBAR_NUM)(2 downto 0);
    constant PF0_REVISION_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF0_REVISION_ID)(7 downto 0);
    constant PF0_SRIOV_BAR0_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR0_APERTURE_SIZE)(4 downto 0);
    constant PF0_SRIOV_BAR0_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR0_CONTROL)(2 downto 0);
    constant PF0_SRIOV_BAR1_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR1_APERTURE_SIZE)(4 downto 0);
    constant PF0_SRIOV_BAR1_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR1_CONTROL)(2 downto 0);
    constant PF0_SRIOV_BAR2_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR2_APERTURE_SIZE)(4 downto 0);
    constant PF0_SRIOV_BAR2_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR2_CONTROL)(2 downto 0);
    constant PF0_SRIOV_BAR3_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR3_APERTURE_SIZE)(4 downto 0);
    constant PF0_SRIOV_BAR3_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR3_CONTROL)(2 downto 0);
    constant PF0_SRIOV_BAR4_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR4_APERTURE_SIZE)(4 downto 0);
    constant PF0_SRIOV_BAR4_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR4_CONTROL)(2 downto 0);
    constant PF0_SRIOV_BAR5_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR5_APERTURE_SIZE)(4 downto 0);
    constant PF0_SRIOV_BAR5_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_SRIOV_BAR5_CONTROL)(2 downto 0);
    constant PF0_SRIOV_CAP_INITIAL_VF_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF0_SRIOV_CAP_INITIAL_VF)(15 downto 0);
    constant PF0_SRIOV_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_SRIOV_CAP_NEXTPTR)(11 downto 0);
    constant PF0_SRIOV_CAP_TOTAL_VF_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF0_SRIOV_CAP_TOTAL_VF)(15 downto 0);
    constant PF0_SRIOV_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_SRIOV_CAP_VER)(3 downto 0);
    constant PF0_SRIOV_FIRST_VF_OFFSET_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF0_SRIOV_FIRST_VF_OFFSET)(15 downto 0);
    constant PF0_SRIOV_FUNC_DEP_LINK_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF0_SRIOV_FUNC_DEP_LINK)(15 downto 0);
    constant PF0_SRIOV_SUPPORTED_PAGE_SIZE_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(PF0_SRIOV_SUPPORTED_PAGE_SIZE)(31 downto 0);
    constant PF0_SRIOV_VF_DEVICE_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF0_SRIOV_VF_DEVICE_ID)(15 downto 0);
    constant PF0_SUBSYSTEM_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF0_SUBSYSTEM_ID)(15 downto 0);
    constant PF0_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant PF0_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF0_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant PF0_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PF0_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant PF0_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(PF0_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant PF0_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_TPHR_CAP_VER)(3 downto 0);
    constant PF0_VC_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF0_VC_CAP_NEXTPTR)(11 downto 0);
    constant PF0_VC_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF0_VC_CAP_VER)(3 downto 0);
    constant PF1_AER_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_AER_CAP_NEXTPTR)(11 downto 0);
    constant PF1_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_ARI_CAP_NEXTPTR)(11 downto 0);
    constant PF1_ARI_CAP_NEXT_FUNC_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_ARI_CAP_NEXT_FUNC)(7 downto 0);
    constant PF1_BAR0_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_BAR0_APERTURE_SIZE)(4 downto 0);
    constant PF1_BAR0_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_BAR0_CONTROL)(2 downto 0);
    constant PF1_BAR1_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_BAR1_APERTURE_SIZE)(4 downto 0);
    constant PF1_BAR1_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_BAR1_CONTROL)(2 downto 0);
    constant PF1_BAR2_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_BAR2_APERTURE_SIZE)(4 downto 0);
    constant PF1_BAR2_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_BAR2_CONTROL)(2 downto 0);
    constant PF1_BAR3_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_BAR3_APERTURE_SIZE)(4 downto 0);
    constant PF1_BAR3_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_BAR3_CONTROL)(2 downto 0);
    constant PF1_BAR4_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_BAR4_APERTURE_SIZE)(4 downto 0);
    constant PF1_BAR4_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_BAR4_CONTROL)(2 downto 0);
    constant PF1_BAR5_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_BAR5_APERTURE_SIZE)(4 downto 0);
    constant PF1_BAR5_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_BAR5_CONTROL)(2 downto 0);
    constant PF1_BIST_REGISTER_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_BIST_REGISTER)(7 downto 0);
    constant PF1_CAPABILITY_POINTER_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_CAPABILITY_POINTER)(7 downto 0);
    constant PF1_CLASS_CODE_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(PF1_CLASS_CODE)(23 downto 0);
    constant PF1_DEVICE_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF1_DEVICE_ID)(15 downto 0);
    constant PF1_DEV_CAP_MAX_PAYLOAD_SIZE_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_DEV_CAP_MAX_PAYLOAD_SIZE)(2 downto 0);
    constant PF1_DPA_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_DPA_CAP_NEXTPTR)(11 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_CONTROL_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_CONTROL)(4 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0)(7 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1)(7 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2)(7 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3)(7 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4)(7 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5)(7 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6)(7 downto 0);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7)(7 downto 0);
    constant PF1_DPA_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF1_DPA_CAP_VER)(3 downto 0);
    constant PF1_DSN_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_DSN_CAP_NEXTPTR)(11 downto 0);
    constant PF1_EXPANSION_ROM_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_EXPANSION_ROM_APERTURE_SIZE)(4 downto 0);
    constant PF1_INTERRUPT_LINE_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_INTERRUPT_LINE)(7 downto 0);
    constant PF1_INTERRUPT_PIN_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_INTERRUPT_PIN)(2 downto 0);
    constant PF1_MSIX_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_MSIX_CAP_NEXTPTR)(7 downto 0);
    constant PF1_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(PF1_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant PF1_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(PF1_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant PF1_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(PF1_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant PF1_MSI_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_MSI_CAP_NEXTPTR)(7 downto 0);
    constant PF1_PB_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_PB_CAP_NEXTPTR)(11 downto 0);
    constant PF1_PB_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF1_PB_CAP_VER)(3 downto 0);
    constant PF1_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_PM_CAP_ID)(7 downto 0);
    constant PF1_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_PM_CAP_NEXTPTR)(7 downto 0);
    constant PF1_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_PM_CAP_VER_ID)(2 downto 0);
    constant PF1_RBAR_CAP_INDEX0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_INDEX0)(2 downto 0);
    constant PF1_RBAR_CAP_INDEX1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_INDEX1)(2 downto 0);
    constant PF1_RBAR_CAP_INDEX2_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_INDEX2)(2 downto 0);
    constant PF1_RBAR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_NEXTPTR)(11 downto 0);
    constant PF1_RBAR_CAP_SIZE0_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_SIZE0)(19 downto 0);
    constant PF1_RBAR_CAP_SIZE1_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_SIZE1)(19 downto 0);
    constant PF1_RBAR_CAP_SIZE2_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_SIZE2)(19 downto 0);
    constant PF1_RBAR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF1_RBAR_CAP_VER)(3 downto 0);
    constant PF1_RBAR_NUM_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_RBAR_NUM)(2 downto 0);
    constant PF1_REVISION_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PF1_REVISION_ID)(7 downto 0);
    constant PF1_SRIOV_BAR0_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR0_APERTURE_SIZE)(4 downto 0);
    constant PF1_SRIOV_BAR0_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR0_CONTROL)(2 downto 0);
    constant PF1_SRIOV_BAR1_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR1_APERTURE_SIZE)(4 downto 0);
    constant PF1_SRIOV_BAR1_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR1_CONTROL)(2 downto 0);
    constant PF1_SRIOV_BAR2_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR2_APERTURE_SIZE)(4 downto 0);
    constant PF1_SRIOV_BAR2_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR2_CONTROL)(2 downto 0);
    constant PF1_SRIOV_BAR3_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR3_APERTURE_SIZE)(4 downto 0);
    constant PF1_SRIOV_BAR3_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR3_CONTROL)(2 downto 0);
    constant PF1_SRIOV_BAR4_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR4_APERTURE_SIZE)(4 downto 0);
    constant PF1_SRIOV_BAR4_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR4_CONTROL)(2 downto 0);
    constant PF1_SRIOV_BAR5_APERTURE_SIZE_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR5_APERTURE_SIZE)(4 downto 0);
    constant PF1_SRIOV_BAR5_CONTROL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_SRIOV_BAR5_CONTROL)(2 downto 0);
    constant PF1_SRIOV_CAP_INITIAL_VF_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF1_SRIOV_CAP_INITIAL_VF)(15 downto 0);
    constant PF1_SRIOV_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_SRIOV_CAP_NEXTPTR)(11 downto 0);
    constant PF1_SRIOV_CAP_TOTAL_VF_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF1_SRIOV_CAP_TOTAL_VF)(15 downto 0);
    constant PF1_SRIOV_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF1_SRIOV_CAP_VER)(3 downto 0);
    constant PF1_SRIOV_FIRST_VF_OFFSET_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF1_SRIOV_FIRST_VF_OFFSET)(15 downto 0);
    constant PF1_SRIOV_FUNC_DEP_LINK_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF1_SRIOV_FUNC_DEP_LINK)(15 downto 0);
    constant PF1_SRIOV_SUPPORTED_PAGE_SIZE_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(PF1_SRIOV_SUPPORTED_PAGE_SIZE)(31 downto 0);
    constant PF1_SRIOV_VF_DEVICE_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF1_SRIOV_VF_DEVICE_ID)(15 downto 0);
    constant PF1_SUBSYSTEM_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PF1_SUBSYSTEM_ID)(15 downto 0);
    constant PF1_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PF1_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant PF1_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PF1_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant PF1_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PF1_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant PF1_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(PF1_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant PF1_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PF1_TPHR_CAP_VER)(3 downto 0);
    constant PL_EQ_ADAPT_ITER_COUNT_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PL_EQ_ADAPT_ITER_COUNT)(4 downto 0);
    constant PL_EQ_ADAPT_REJECT_RETRY_COUNT_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PL_EQ_ADAPT_REJECT_RETRY_COUNT)(1 downto 0);
    constant PL_LANE0_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE0_EQ_CONTROL)(15 downto 0);
    constant PL_LANE1_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE1_EQ_CONTROL)(15 downto 0);
    constant PL_LANE2_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE2_EQ_CONTROL)(15 downto 0);
    constant PL_LANE3_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE3_EQ_CONTROL)(15 downto 0);
    constant PL_LANE4_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE4_EQ_CONTROL)(15 downto 0);
    constant PL_LANE5_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE5_EQ_CONTROL)(15 downto 0);
    constant PL_LANE6_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE6_EQ_CONTROL)(15 downto 0);
    constant PL_LANE7_EQ_CONTROL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PL_LANE7_EQ_CONTROL)(15 downto 0);
    constant PL_LINK_CAP_MAX_LINK_SPEED_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PL_LINK_CAP_MAX_LINK_SPEED)(2 downto 0);
    constant PL_LINK_CAP_MAX_LINK_WIDTH_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PL_LINK_CAP_MAX_LINK_WIDTH)(3 downto 0);
    constant PM_ASPML0S_TIMEOUT_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PM_ASPML0S_TIMEOUT)(15 downto 0);
    constant PM_ASPML1_ENTRY_DELAY_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PM_ASPML1_ENTRY_DELAY)(19 downto 0);
    constant PM_L1_REENTRY_DELAY_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(PM_L1_REENTRY_DELAY)(31 downto 0);
    constant PM_PME_SERVICE_TIMEOUT_DELAY_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PM_PME_SERVICE_TIMEOUT_DELAY)(19 downto 0);
    constant PM_PME_TURNOFF_ACK_DELAY_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PM_PME_TURNOFF_ACK_DELAY)(15 downto 0);
    constant SPARE_BYTE0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE0)(7 downto 0);
    constant SPARE_BYTE1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE1)(7 downto 0);
    constant SPARE_BYTE2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE2)(7 downto 0);
    constant SPARE_BYTE3_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE3)(7 downto 0);
    constant SPARE_WORD0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD0)(31 downto 0);
    constant SPARE_WORD1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD1)(31 downto 0);
    constant SPARE_WORD2_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD2)(31 downto 0);
    constant SPARE_WORD3_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD3)(31 downto 0);
    constant TL_COMPL_TIMEOUT_REG0_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(TL_COMPL_TIMEOUT_REG0)(23 downto 0);
    constant TL_COMPL_TIMEOUT_REG1_BINARY : std_logic_vector(27 downto 0) := To_StdLogicVector(TL_COMPL_TIMEOUT_REG1)(27 downto 0);
    constant TL_CREDITS_CD_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(TL_CREDITS_CD)(11 downto 0);
    constant TL_CREDITS_CH_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TL_CREDITS_CH)(7 downto 0);
    constant TL_CREDITS_NPD_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(TL_CREDITS_NPD)(11 downto 0);
    constant TL_CREDITS_NPH_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TL_CREDITS_NPH)(7 downto 0);
    constant TL_CREDITS_PD_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(TL_CREDITS_PD)(11 downto 0);
    constant TL_CREDITS_PH_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TL_CREDITS_PH)(7 downto 0);
    constant VF0_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF0_ARI_CAP_NEXTPTR)(11 downto 0);
    constant VF0_CAPABILITY_POINTER_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF0_CAPABILITY_POINTER)(7 downto 0);
    constant VF0_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF0_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant VF0_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF0_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant VF0_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF0_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant VF0_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF0_PM_CAP_ID)(7 downto 0);
    constant VF0_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF0_PM_CAP_NEXTPTR)(7 downto 0);
    constant VF0_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF0_PM_CAP_VER_ID)(2 downto 0);
    constant VF0_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF0_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant VF0_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF0_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant VF0_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(VF0_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant VF0_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF0_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant VF0_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VF0_TPHR_CAP_VER)(3 downto 0);
    constant VF1_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF1_ARI_CAP_NEXTPTR)(11 downto 0);
    constant VF1_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF1_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant VF1_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF1_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant VF1_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF1_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant VF1_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF1_PM_CAP_ID)(7 downto 0);
    constant VF1_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF1_PM_CAP_NEXTPTR)(7 downto 0);
    constant VF1_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF1_PM_CAP_VER_ID)(2 downto 0);
    constant VF1_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF1_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant VF1_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF1_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant VF1_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(VF1_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant VF1_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF1_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant VF1_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VF1_TPHR_CAP_VER)(3 downto 0);
    constant VF2_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF2_ARI_CAP_NEXTPTR)(11 downto 0);
    constant VF2_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF2_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant VF2_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF2_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant VF2_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF2_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant VF2_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF2_PM_CAP_ID)(7 downto 0);
    constant VF2_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF2_PM_CAP_NEXTPTR)(7 downto 0);
    constant VF2_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF2_PM_CAP_VER_ID)(2 downto 0);
    constant VF2_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF2_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant VF2_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF2_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant VF2_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(VF2_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant VF2_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF2_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant VF2_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VF2_TPHR_CAP_VER)(3 downto 0);
    constant VF3_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF3_ARI_CAP_NEXTPTR)(11 downto 0);
    constant VF3_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF3_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant VF3_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF3_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant VF3_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF3_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant VF3_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF3_PM_CAP_ID)(7 downto 0);
    constant VF3_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF3_PM_CAP_NEXTPTR)(7 downto 0);
    constant VF3_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF3_PM_CAP_VER_ID)(2 downto 0);
    constant VF3_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF3_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant VF3_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF3_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant VF3_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(VF3_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant VF3_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF3_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant VF3_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VF3_TPHR_CAP_VER)(3 downto 0);
    constant VF4_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF4_ARI_CAP_NEXTPTR)(11 downto 0);
    constant VF4_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF4_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant VF4_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF4_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant VF4_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF4_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant VF4_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF4_PM_CAP_ID)(7 downto 0);
    constant VF4_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF4_PM_CAP_NEXTPTR)(7 downto 0);
    constant VF4_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF4_PM_CAP_VER_ID)(2 downto 0);
    constant VF4_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF4_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant VF4_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF4_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant VF4_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(VF4_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant VF4_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF4_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant VF4_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VF4_TPHR_CAP_VER)(3 downto 0);
    constant VF5_ARI_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF5_ARI_CAP_NEXTPTR)(11 downto 0);
    constant VF5_MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF5_MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant VF5_MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(VF5_MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant VF5_MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF5_MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant VF5_PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF5_PM_CAP_ID)(7 downto 0);
    constant VF5_PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(VF5_PM_CAP_NEXTPTR)(7 downto 0);
    constant VF5_PM_CAP_VER_ID_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF5_PM_CAP_VER_ID)(2 downto 0);
    constant VF5_TPHR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VF5_TPHR_CAP_NEXTPTR)(11 downto 0);
    constant VF5_TPHR_CAP_ST_MODE_SEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(VF5_TPHR_CAP_ST_MODE_SEL)(2 downto 0);
    constant VF5_TPHR_CAP_ST_TABLE_LOC_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(VF5_TPHR_CAP_ST_TABLE_LOC)(1 downto 0);
    constant VF5_TPHR_CAP_ST_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(VF5_TPHR_CAP_ST_TABLE_SIZE)(10 downto 0);
    constant VF5_TPHR_CAP_VER_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VF5_TPHR_CAP_VER)(3 downto 0);
    
    -- Get String Length
    constant AXISTEN_IF_ENABLE_MSG_ROUTE_STRLEN : integer := getstrlength(AXISTEN_IF_ENABLE_MSG_ROUTE_BINARY);
    constant AXISTEN_IF_WIDTH_STRLEN : integer := getstrlength(AXISTEN_IF_WIDTH_BINARY);
    constant CRM_USER_CLK_FREQ_STRLEN : integer := getstrlength(CRM_USER_CLK_FREQ_BINARY);
    constant DNSTREAM_LINK_NUM_STRLEN : integer := getstrlength(DNSTREAM_LINK_NUM_BINARY);
    constant GEN3_PCS_AUTO_REALIGN_STRLEN : integer := getstrlength(GEN3_PCS_AUTO_REALIGN_BINARY);
    constant LL_ACK_TIMEOUT_STRLEN : integer := getstrlength(LL_ACK_TIMEOUT_BINARY);
    constant LL_CPL_FC_UPDATE_TIMER_STRLEN : integer := getstrlength(LL_CPL_FC_UPDATE_TIMER_BINARY);
    constant LL_FC_UPDATE_TIMER_STRLEN : integer := getstrlength(LL_FC_UPDATE_TIMER_BINARY);
    constant LL_NP_FC_UPDATE_TIMER_STRLEN : integer := getstrlength(LL_NP_FC_UPDATE_TIMER_BINARY);
    constant LL_P_FC_UPDATE_TIMER_STRLEN : integer := getstrlength(LL_P_FC_UPDATE_TIMER_BINARY);
    constant LL_REPLAY_TIMEOUT_STRLEN : integer := getstrlength(LL_REPLAY_TIMEOUT_BINARY);
    constant LTR_TX_MESSAGE_MINIMUM_INTERVAL_STRLEN : integer := getstrlength(LTR_TX_MESSAGE_MINIMUM_INTERVAL_BINARY);
    constant PF0_AER_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_AER_CAP_NEXTPTR_BINARY);
    constant PF0_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_ARI_CAP_NEXTPTR_BINARY);
    constant PF0_ARI_CAP_NEXT_FUNC_STRLEN : integer := getstrlength(PF0_ARI_CAP_NEXT_FUNC_BINARY);
    constant PF0_ARI_CAP_VER_STRLEN : integer := getstrlength(PF0_ARI_CAP_VER_BINARY);
    constant PF0_BAR0_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_BAR0_APERTURE_SIZE_BINARY);
    constant PF0_BAR0_CONTROL_STRLEN : integer := getstrlength(PF0_BAR0_CONTROL_BINARY);
    constant PF0_BAR1_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_BAR1_APERTURE_SIZE_BINARY);
    constant PF0_BAR1_CONTROL_STRLEN : integer := getstrlength(PF0_BAR1_CONTROL_BINARY);
    constant PF0_BAR2_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_BAR2_APERTURE_SIZE_BINARY);
    constant PF0_BAR2_CONTROL_STRLEN : integer := getstrlength(PF0_BAR2_CONTROL_BINARY);
    constant PF0_BAR3_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_BAR3_APERTURE_SIZE_BINARY);
    constant PF0_BAR3_CONTROL_STRLEN : integer := getstrlength(PF0_BAR3_CONTROL_BINARY);
    constant PF0_BAR4_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_BAR4_APERTURE_SIZE_BINARY);
    constant PF0_BAR4_CONTROL_STRLEN : integer := getstrlength(PF0_BAR4_CONTROL_BINARY);
    constant PF0_BAR5_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_BAR5_APERTURE_SIZE_BINARY);
    constant PF0_BAR5_CONTROL_STRLEN : integer := getstrlength(PF0_BAR5_CONTROL_BINARY);
    constant PF0_BIST_REGISTER_STRLEN : integer := getstrlength(PF0_BIST_REGISTER_BINARY);
    constant PF0_CAPABILITY_POINTER_STRLEN : integer := getstrlength(PF0_CAPABILITY_POINTER_BINARY);
    constant PF0_CLASS_CODE_STRLEN : integer := getstrlength(PF0_CLASS_CODE_BINARY);
    constant PF0_DEVICE_ID_STRLEN : integer := getstrlength(PF0_DEVICE_ID_BINARY);
    constant PF0_DEV_CAP2_OBFF_SUPPORT_STRLEN : integer := getstrlength(PF0_DEV_CAP2_OBFF_SUPPORT_BINARY);
    constant PF0_DEV_CAP_MAX_PAYLOAD_SIZE_STRLEN : integer := getstrlength(PF0_DEV_CAP_MAX_PAYLOAD_SIZE_BINARY);
    constant PF0_DPA_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_DPA_CAP_NEXTPTR_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_CONTROL_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_CONTROL_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_BINARY);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRLEN : integer := getstrlength(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_BINARY);
    constant PF0_DPA_CAP_VER_STRLEN : integer := getstrlength(PF0_DPA_CAP_VER_BINARY);
    constant PF0_DSN_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_DSN_CAP_NEXTPTR_BINARY);
    constant PF0_EXPANSION_ROM_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_EXPANSION_ROM_APERTURE_SIZE_BINARY);
    constant PF0_INTERRUPT_LINE_STRLEN : integer := getstrlength(PF0_INTERRUPT_LINE_BINARY);
    constant PF0_INTERRUPT_PIN_STRLEN : integer := getstrlength(PF0_INTERRUPT_PIN_BINARY);
    constant PF0_LTR_CAP_MAX_NOSNOOP_LAT_STRLEN : integer := getstrlength(PF0_LTR_CAP_MAX_NOSNOOP_LAT_BINARY);
    constant PF0_LTR_CAP_MAX_SNOOP_LAT_STRLEN : integer := getstrlength(PF0_LTR_CAP_MAX_SNOOP_LAT_BINARY);
    constant PF0_LTR_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_LTR_CAP_NEXTPTR_BINARY);
    constant PF0_LTR_CAP_VER_STRLEN : integer := getstrlength(PF0_LTR_CAP_VER_BINARY);
    constant PF0_MSIX_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_MSIX_CAP_NEXTPTR_BINARY);
    constant PF0_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(PF0_MSIX_CAP_PBA_OFFSET_BINARY);
    constant PF0_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(PF0_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant PF0_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(PF0_MSIX_CAP_TABLE_SIZE_BINARY);
    constant PF0_MSI_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_MSI_CAP_NEXTPTR_BINARY);
    constant PF0_PB_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_PB_CAP_NEXTPTR_BINARY);
    constant PF0_PB_CAP_VER_STRLEN : integer := getstrlength(PF0_PB_CAP_VER_BINARY);
    constant PF0_PM_CAP_ID_STRLEN : integer := getstrlength(PF0_PM_CAP_ID_BINARY);
    constant PF0_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_PM_CAP_NEXTPTR_BINARY);
    constant PF0_PM_CAP_VER_ID_STRLEN : integer := getstrlength(PF0_PM_CAP_VER_ID_BINARY);
    constant PF0_RBAR_CAP_INDEX0_STRLEN : integer := getstrlength(PF0_RBAR_CAP_INDEX0_BINARY);
    constant PF0_RBAR_CAP_INDEX1_STRLEN : integer := getstrlength(PF0_RBAR_CAP_INDEX1_BINARY);
    constant PF0_RBAR_CAP_INDEX2_STRLEN : integer := getstrlength(PF0_RBAR_CAP_INDEX2_BINARY);
    constant PF0_RBAR_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_RBAR_CAP_NEXTPTR_BINARY);
    constant PF0_RBAR_CAP_SIZE0_STRLEN : integer := getstrlength(PF0_RBAR_CAP_SIZE0_BINARY);
    constant PF0_RBAR_CAP_SIZE1_STRLEN : integer := getstrlength(PF0_RBAR_CAP_SIZE1_BINARY);
    constant PF0_RBAR_CAP_SIZE2_STRLEN : integer := getstrlength(PF0_RBAR_CAP_SIZE2_BINARY);
    constant PF0_RBAR_CAP_VER_STRLEN : integer := getstrlength(PF0_RBAR_CAP_VER_BINARY);
    constant PF0_RBAR_NUM_STRLEN : integer := getstrlength(PF0_RBAR_NUM_BINARY);
    constant PF0_REVISION_ID_STRLEN : integer := getstrlength(PF0_REVISION_ID_BINARY);
    constant PF0_SRIOV_BAR0_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_SRIOV_BAR0_APERTURE_SIZE_BINARY);
    constant PF0_SRIOV_BAR0_CONTROL_STRLEN : integer := getstrlength(PF0_SRIOV_BAR0_CONTROL_BINARY);
    constant PF0_SRIOV_BAR1_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_SRIOV_BAR1_APERTURE_SIZE_BINARY);
    constant PF0_SRIOV_BAR1_CONTROL_STRLEN : integer := getstrlength(PF0_SRIOV_BAR1_CONTROL_BINARY);
    constant PF0_SRIOV_BAR2_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_SRIOV_BAR2_APERTURE_SIZE_BINARY);
    constant PF0_SRIOV_BAR2_CONTROL_STRLEN : integer := getstrlength(PF0_SRIOV_BAR2_CONTROL_BINARY);
    constant PF0_SRIOV_BAR3_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_SRIOV_BAR3_APERTURE_SIZE_BINARY);
    constant PF0_SRIOV_BAR3_CONTROL_STRLEN : integer := getstrlength(PF0_SRIOV_BAR3_CONTROL_BINARY);
    constant PF0_SRIOV_BAR4_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_SRIOV_BAR4_APERTURE_SIZE_BINARY);
    constant PF0_SRIOV_BAR4_CONTROL_STRLEN : integer := getstrlength(PF0_SRIOV_BAR4_CONTROL_BINARY);
    constant PF0_SRIOV_BAR5_APERTURE_SIZE_STRLEN : integer := getstrlength(PF0_SRIOV_BAR5_APERTURE_SIZE_BINARY);
    constant PF0_SRIOV_BAR5_CONTROL_STRLEN : integer := getstrlength(PF0_SRIOV_BAR5_CONTROL_BINARY);
    constant PF0_SRIOV_CAP_INITIAL_VF_STRLEN : integer := getstrlength(PF0_SRIOV_CAP_INITIAL_VF_BINARY);
    constant PF0_SRIOV_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_SRIOV_CAP_NEXTPTR_BINARY);
    constant PF0_SRIOV_CAP_TOTAL_VF_STRLEN : integer := getstrlength(PF0_SRIOV_CAP_TOTAL_VF_BINARY);
    constant PF0_SRIOV_CAP_VER_STRLEN : integer := getstrlength(PF0_SRIOV_CAP_VER_BINARY);
    constant PF0_SRIOV_FIRST_VF_OFFSET_STRLEN : integer := getstrlength(PF0_SRIOV_FIRST_VF_OFFSET_BINARY);
    constant PF0_SRIOV_FUNC_DEP_LINK_STRLEN : integer := getstrlength(PF0_SRIOV_FUNC_DEP_LINK_BINARY);
    constant PF0_SRIOV_SUPPORTED_PAGE_SIZE_STRLEN : integer := getstrlength(PF0_SRIOV_SUPPORTED_PAGE_SIZE_BINARY);
    constant PF0_SRIOV_VF_DEVICE_ID_STRLEN : integer := getstrlength(PF0_SRIOV_VF_DEVICE_ID_BINARY);
    constant PF0_SUBSYSTEM_ID_STRLEN : integer := getstrlength(PF0_SUBSYSTEM_ID_BINARY);
    constant PF0_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_TPHR_CAP_NEXTPTR_BINARY);
    constant PF0_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(PF0_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant PF0_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(PF0_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant PF0_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(PF0_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant PF0_TPHR_CAP_VER_STRLEN : integer := getstrlength(PF0_TPHR_CAP_VER_BINARY);
    constant PF0_VC_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF0_VC_CAP_NEXTPTR_BINARY);
    constant PF0_VC_CAP_VER_STRLEN : integer := getstrlength(PF0_VC_CAP_VER_BINARY);
    constant PF1_AER_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_AER_CAP_NEXTPTR_BINARY);
    constant PF1_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_ARI_CAP_NEXTPTR_BINARY);
    constant PF1_ARI_CAP_NEXT_FUNC_STRLEN : integer := getstrlength(PF1_ARI_CAP_NEXT_FUNC_BINARY);
    constant PF1_BAR0_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_BAR0_APERTURE_SIZE_BINARY);
    constant PF1_BAR0_CONTROL_STRLEN : integer := getstrlength(PF1_BAR0_CONTROL_BINARY);
    constant PF1_BAR1_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_BAR1_APERTURE_SIZE_BINARY);
    constant PF1_BAR1_CONTROL_STRLEN : integer := getstrlength(PF1_BAR1_CONTROL_BINARY);
    constant PF1_BAR2_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_BAR2_APERTURE_SIZE_BINARY);
    constant PF1_BAR2_CONTROL_STRLEN : integer := getstrlength(PF1_BAR2_CONTROL_BINARY);
    constant PF1_BAR3_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_BAR3_APERTURE_SIZE_BINARY);
    constant PF1_BAR3_CONTROL_STRLEN : integer := getstrlength(PF1_BAR3_CONTROL_BINARY);
    constant PF1_BAR4_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_BAR4_APERTURE_SIZE_BINARY);
    constant PF1_BAR4_CONTROL_STRLEN : integer := getstrlength(PF1_BAR4_CONTROL_BINARY);
    constant PF1_BAR5_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_BAR5_APERTURE_SIZE_BINARY);
    constant PF1_BAR5_CONTROL_STRLEN : integer := getstrlength(PF1_BAR5_CONTROL_BINARY);
    constant PF1_BIST_REGISTER_STRLEN : integer := getstrlength(PF1_BIST_REGISTER_BINARY);
    constant PF1_CAPABILITY_POINTER_STRLEN : integer := getstrlength(PF1_CAPABILITY_POINTER_BINARY);
    constant PF1_CLASS_CODE_STRLEN : integer := getstrlength(PF1_CLASS_CODE_BINARY);
    constant PF1_DEVICE_ID_STRLEN : integer := getstrlength(PF1_DEVICE_ID_BINARY);
    constant PF1_DEV_CAP_MAX_PAYLOAD_SIZE_STRLEN : integer := getstrlength(PF1_DEV_CAP_MAX_PAYLOAD_SIZE_BINARY);
    constant PF1_DPA_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_DPA_CAP_NEXTPTR_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_CONTROL_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_CONTROL_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_BINARY);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRLEN : integer := getstrlength(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_BINARY);
    constant PF1_DPA_CAP_VER_STRLEN : integer := getstrlength(PF1_DPA_CAP_VER_BINARY);
    constant PF1_DSN_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_DSN_CAP_NEXTPTR_BINARY);
    constant PF1_EXPANSION_ROM_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_EXPANSION_ROM_APERTURE_SIZE_BINARY);
    constant PF1_INTERRUPT_LINE_STRLEN : integer := getstrlength(PF1_INTERRUPT_LINE_BINARY);
    constant PF1_INTERRUPT_PIN_STRLEN : integer := getstrlength(PF1_INTERRUPT_PIN_BINARY);
    constant PF1_MSIX_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_MSIX_CAP_NEXTPTR_BINARY);
    constant PF1_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(PF1_MSIX_CAP_PBA_OFFSET_BINARY);
    constant PF1_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(PF1_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant PF1_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(PF1_MSIX_CAP_TABLE_SIZE_BINARY);
    constant PF1_MSI_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_MSI_CAP_NEXTPTR_BINARY);
    constant PF1_PB_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_PB_CAP_NEXTPTR_BINARY);
    constant PF1_PB_CAP_VER_STRLEN : integer := getstrlength(PF1_PB_CAP_VER_BINARY);
    constant PF1_PM_CAP_ID_STRLEN : integer := getstrlength(PF1_PM_CAP_ID_BINARY);
    constant PF1_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_PM_CAP_NEXTPTR_BINARY);
    constant PF1_PM_CAP_VER_ID_STRLEN : integer := getstrlength(PF1_PM_CAP_VER_ID_BINARY);
    constant PF1_RBAR_CAP_INDEX0_STRLEN : integer := getstrlength(PF1_RBAR_CAP_INDEX0_BINARY);
    constant PF1_RBAR_CAP_INDEX1_STRLEN : integer := getstrlength(PF1_RBAR_CAP_INDEX1_BINARY);
    constant PF1_RBAR_CAP_INDEX2_STRLEN : integer := getstrlength(PF1_RBAR_CAP_INDEX2_BINARY);
    constant PF1_RBAR_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_RBAR_CAP_NEXTPTR_BINARY);
    constant PF1_RBAR_CAP_SIZE0_STRLEN : integer := getstrlength(PF1_RBAR_CAP_SIZE0_BINARY);
    constant PF1_RBAR_CAP_SIZE1_STRLEN : integer := getstrlength(PF1_RBAR_CAP_SIZE1_BINARY);
    constant PF1_RBAR_CAP_SIZE2_STRLEN : integer := getstrlength(PF1_RBAR_CAP_SIZE2_BINARY);
    constant PF1_RBAR_CAP_VER_STRLEN : integer := getstrlength(PF1_RBAR_CAP_VER_BINARY);
    constant PF1_RBAR_NUM_STRLEN : integer := getstrlength(PF1_RBAR_NUM_BINARY);
    constant PF1_REVISION_ID_STRLEN : integer := getstrlength(PF1_REVISION_ID_BINARY);
    constant PF1_SRIOV_BAR0_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_SRIOV_BAR0_APERTURE_SIZE_BINARY);
    constant PF1_SRIOV_BAR0_CONTROL_STRLEN : integer := getstrlength(PF1_SRIOV_BAR0_CONTROL_BINARY);
    constant PF1_SRIOV_BAR1_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_SRIOV_BAR1_APERTURE_SIZE_BINARY);
    constant PF1_SRIOV_BAR1_CONTROL_STRLEN : integer := getstrlength(PF1_SRIOV_BAR1_CONTROL_BINARY);
    constant PF1_SRIOV_BAR2_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_SRIOV_BAR2_APERTURE_SIZE_BINARY);
    constant PF1_SRIOV_BAR2_CONTROL_STRLEN : integer := getstrlength(PF1_SRIOV_BAR2_CONTROL_BINARY);
    constant PF1_SRIOV_BAR3_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_SRIOV_BAR3_APERTURE_SIZE_BINARY);
    constant PF1_SRIOV_BAR3_CONTROL_STRLEN : integer := getstrlength(PF1_SRIOV_BAR3_CONTROL_BINARY);
    constant PF1_SRIOV_BAR4_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_SRIOV_BAR4_APERTURE_SIZE_BINARY);
    constant PF1_SRIOV_BAR4_CONTROL_STRLEN : integer := getstrlength(PF1_SRIOV_BAR4_CONTROL_BINARY);
    constant PF1_SRIOV_BAR5_APERTURE_SIZE_STRLEN : integer := getstrlength(PF1_SRIOV_BAR5_APERTURE_SIZE_BINARY);
    constant PF1_SRIOV_BAR5_CONTROL_STRLEN : integer := getstrlength(PF1_SRIOV_BAR5_CONTROL_BINARY);
    constant PF1_SRIOV_CAP_INITIAL_VF_STRLEN : integer := getstrlength(PF1_SRIOV_CAP_INITIAL_VF_BINARY);
    constant PF1_SRIOV_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_SRIOV_CAP_NEXTPTR_BINARY);
    constant PF1_SRIOV_CAP_TOTAL_VF_STRLEN : integer := getstrlength(PF1_SRIOV_CAP_TOTAL_VF_BINARY);
    constant PF1_SRIOV_CAP_VER_STRLEN : integer := getstrlength(PF1_SRIOV_CAP_VER_BINARY);
    constant PF1_SRIOV_FIRST_VF_OFFSET_STRLEN : integer := getstrlength(PF1_SRIOV_FIRST_VF_OFFSET_BINARY);
    constant PF1_SRIOV_FUNC_DEP_LINK_STRLEN : integer := getstrlength(PF1_SRIOV_FUNC_DEP_LINK_BINARY);
    constant PF1_SRIOV_SUPPORTED_PAGE_SIZE_STRLEN : integer := getstrlength(PF1_SRIOV_SUPPORTED_PAGE_SIZE_BINARY);
    constant PF1_SRIOV_VF_DEVICE_ID_STRLEN : integer := getstrlength(PF1_SRIOV_VF_DEVICE_ID_BINARY);
    constant PF1_SUBSYSTEM_ID_STRLEN : integer := getstrlength(PF1_SUBSYSTEM_ID_BINARY);
    constant PF1_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(PF1_TPHR_CAP_NEXTPTR_BINARY);
    constant PF1_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(PF1_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant PF1_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(PF1_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant PF1_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(PF1_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant PF1_TPHR_CAP_VER_STRLEN : integer := getstrlength(PF1_TPHR_CAP_VER_BINARY);
    constant PL_EQ_ADAPT_ITER_COUNT_STRLEN : integer := getstrlength(PL_EQ_ADAPT_ITER_COUNT_BINARY);
    constant PL_EQ_ADAPT_REJECT_RETRY_COUNT_STRLEN : integer := getstrlength(PL_EQ_ADAPT_REJECT_RETRY_COUNT_BINARY);
    constant PL_LANE0_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE0_EQ_CONTROL_BINARY);
    constant PL_LANE1_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE1_EQ_CONTROL_BINARY);
    constant PL_LANE2_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE2_EQ_CONTROL_BINARY);
    constant PL_LANE3_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE3_EQ_CONTROL_BINARY);
    constant PL_LANE4_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE4_EQ_CONTROL_BINARY);
    constant PL_LANE5_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE5_EQ_CONTROL_BINARY);
    constant PL_LANE6_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE6_EQ_CONTROL_BINARY);
    constant PL_LANE7_EQ_CONTROL_STRLEN : integer := getstrlength(PL_LANE7_EQ_CONTROL_BINARY);
    constant PL_LINK_CAP_MAX_LINK_SPEED_STRLEN : integer := getstrlength(PL_LINK_CAP_MAX_LINK_SPEED_BINARY);
    constant PL_LINK_CAP_MAX_LINK_WIDTH_STRLEN : integer := getstrlength(PL_LINK_CAP_MAX_LINK_WIDTH_BINARY);
    constant PM_ASPML0S_TIMEOUT_STRLEN : integer := getstrlength(PM_ASPML0S_TIMEOUT_BINARY);
    constant PM_ASPML1_ENTRY_DELAY_STRLEN : integer := getstrlength(PM_ASPML1_ENTRY_DELAY_BINARY);
    constant PM_L1_REENTRY_DELAY_STRLEN : integer := getstrlength(PM_L1_REENTRY_DELAY_BINARY);
    constant PM_PME_SERVICE_TIMEOUT_DELAY_STRLEN : integer := getstrlength(PM_PME_SERVICE_TIMEOUT_DELAY_BINARY);
    constant PM_PME_TURNOFF_ACK_DELAY_STRLEN : integer := getstrlength(PM_PME_TURNOFF_ACK_DELAY_BINARY);
    constant SPARE_BYTE0_STRLEN : integer := getstrlength(SPARE_BYTE0_BINARY);
    constant SPARE_BYTE1_STRLEN : integer := getstrlength(SPARE_BYTE1_BINARY);
    constant SPARE_BYTE2_STRLEN : integer := getstrlength(SPARE_BYTE2_BINARY);
    constant SPARE_BYTE3_STRLEN : integer := getstrlength(SPARE_BYTE3_BINARY);
    constant SPARE_WORD0_STRLEN : integer := getstrlength(SPARE_WORD0_BINARY);
    constant SPARE_WORD1_STRLEN : integer := getstrlength(SPARE_WORD1_BINARY);
    constant SPARE_WORD2_STRLEN : integer := getstrlength(SPARE_WORD2_BINARY);
    constant SPARE_WORD3_STRLEN : integer := getstrlength(SPARE_WORD3_BINARY);
    constant TL_COMPL_TIMEOUT_REG0_STRLEN : integer := getstrlength(TL_COMPL_TIMEOUT_REG0_BINARY);
    constant TL_COMPL_TIMEOUT_REG1_STRLEN : integer := getstrlength(TL_COMPL_TIMEOUT_REG1_BINARY);
    constant TL_CREDITS_CD_STRLEN : integer := getstrlength(TL_CREDITS_CD_BINARY);
    constant TL_CREDITS_CH_STRLEN : integer := getstrlength(TL_CREDITS_CH_BINARY);
    constant TL_CREDITS_NPD_STRLEN : integer := getstrlength(TL_CREDITS_NPD_BINARY);
    constant TL_CREDITS_NPH_STRLEN : integer := getstrlength(TL_CREDITS_NPH_BINARY);
    constant TL_CREDITS_PD_STRLEN : integer := getstrlength(TL_CREDITS_PD_BINARY);
    constant TL_CREDITS_PH_STRLEN : integer := getstrlength(TL_CREDITS_PH_BINARY);
    constant VF0_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF0_ARI_CAP_NEXTPTR_BINARY);
    constant VF0_CAPABILITY_POINTER_STRLEN : integer := getstrlength(VF0_CAPABILITY_POINTER_BINARY);
    constant VF0_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(VF0_MSIX_CAP_PBA_OFFSET_BINARY);
    constant VF0_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(VF0_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant VF0_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(VF0_MSIX_CAP_TABLE_SIZE_BINARY);
    constant VF0_PM_CAP_ID_STRLEN : integer := getstrlength(VF0_PM_CAP_ID_BINARY);
    constant VF0_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF0_PM_CAP_NEXTPTR_BINARY);
    constant VF0_PM_CAP_VER_ID_STRLEN : integer := getstrlength(VF0_PM_CAP_VER_ID_BINARY);
    constant VF0_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF0_TPHR_CAP_NEXTPTR_BINARY);
    constant VF0_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(VF0_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant VF0_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(VF0_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant VF0_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(VF0_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant VF0_TPHR_CAP_VER_STRLEN : integer := getstrlength(VF0_TPHR_CAP_VER_BINARY);
    constant VF1_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF1_ARI_CAP_NEXTPTR_BINARY);
    constant VF1_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(VF1_MSIX_CAP_PBA_OFFSET_BINARY);
    constant VF1_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(VF1_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant VF1_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(VF1_MSIX_CAP_TABLE_SIZE_BINARY);
    constant VF1_PM_CAP_ID_STRLEN : integer := getstrlength(VF1_PM_CAP_ID_BINARY);
    constant VF1_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF1_PM_CAP_NEXTPTR_BINARY);
    constant VF1_PM_CAP_VER_ID_STRLEN : integer := getstrlength(VF1_PM_CAP_VER_ID_BINARY);
    constant VF1_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF1_TPHR_CAP_NEXTPTR_BINARY);
    constant VF1_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(VF1_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant VF1_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(VF1_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant VF1_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(VF1_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant VF1_TPHR_CAP_VER_STRLEN : integer := getstrlength(VF1_TPHR_CAP_VER_BINARY);
    constant VF2_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF2_ARI_CAP_NEXTPTR_BINARY);
    constant VF2_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(VF2_MSIX_CAP_PBA_OFFSET_BINARY);
    constant VF2_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(VF2_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant VF2_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(VF2_MSIX_CAP_TABLE_SIZE_BINARY);
    constant VF2_PM_CAP_ID_STRLEN : integer := getstrlength(VF2_PM_CAP_ID_BINARY);
    constant VF2_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF2_PM_CAP_NEXTPTR_BINARY);
    constant VF2_PM_CAP_VER_ID_STRLEN : integer := getstrlength(VF2_PM_CAP_VER_ID_BINARY);
    constant VF2_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF2_TPHR_CAP_NEXTPTR_BINARY);
    constant VF2_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(VF2_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant VF2_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(VF2_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant VF2_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(VF2_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant VF2_TPHR_CAP_VER_STRLEN : integer := getstrlength(VF2_TPHR_CAP_VER_BINARY);
    constant VF3_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF3_ARI_CAP_NEXTPTR_BINARY);
    constant VF3_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(VF3_MSIX_CAP_PBA_OFFSET_BINARY);
    constant VF3_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(VF3_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant VF3_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(VF3_MSIX_CAP_TABLE_SIZE_BINARY);
    constant VF3_PM_CAP_ID_STRLEN : integer := getstrlength(VF3_PM_CAP_ID_BINARY);
    constant VF3_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF3_PM_CAP_NEXTPTR_BINARY);
    constant VF3_PM_CAP_VER_ID_STRLEN : integer := getstrlength(VF3_PM_CAP_VER_ID_BINARY);
    constant VF3_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF3_TPHR_CAP_NEXTPTR_BINARY);
    constant VF3_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(VF3_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant VF3_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(VF3_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant VF3_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(VF3_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant VF3_TPHR_CAP_VER_STRLEN : integer := getstrlength(VF3_TPHR_CAP_VER_BINARY);
    constant VF4_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF4_ARI_CAP_NEXTPTR_BINARY);
    constant VF4_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(VF4_MSIX_CAP_PBA_OFFSET_BINARY);
    constant VF4_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(VF4_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant VF4_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(VF4_MSIX_CAP_TABLE_SIZE_BINARY);
    constant VF4_PM_CAP_ID_STRLEN : integer := getstrlength(VF4_PM_CAP_ID_BINARY);
    constant VF4_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF4_PM_CAP_NEXTPTR_BINARY);
    constant VF4_PM_CAP_VER_ID_STRLEN : integer := getstrlength(VF4_PM_CAP_VER_ID_BINARY);
    constant VF4_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF4_TPHR_CAP_NEXTPTR_BINARY);
    constant VF4_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(VF4_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant VF4_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(VF4_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant VF4_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(VF4_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant VF4_TPHR_CAP_VER_STRLEN : integer := getstrlength(VF4_TPHR_CAP_VER_BINARY);
    constant VF5_ARI_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF5_ARI_CAP_NEXTPTR_BINARY);
    constant VF5_MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(VF5_MSIX_CAP_PBA_OFFSET_BINARY);
    constant VF5_MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(VF5_MSIX_CAP_TABLE_OFFSET_BINARY);
    constant VF5_MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(VF5_MSIX_CAP_TABLE_SIZE_BINARY);
    constant VF5_PM_CAP_ID_STRLEN : integer := getstrlength(VF5_PM_CAP_ID_BINARY);
    constant VF5_PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF5_PM_CAP_NEXTPTR_BINARY);
    constant VF5_PM_CAP_VER_ID_STRLEN : integer := getstrlength(VF5_PM_CAP_VER_ID_BINARY);
    constant VF5_TPHR_CAP_NEXTPTR_STRLEN : integer := getstrlength(VF5_TPHR_CAP_NEXTPTR_BINARY);
    constant VF5_TPHR_CAP_ST_MODE_SEL_STRLEN : integer := getstrlength(VF5_TPHR_CAP_ST_MODE_SEL_BINARY);
    constant VF5_TPHR_CAP_ST_TABLE_LOC_STRLEN : integer := getstrlength(VF5_TPHR_CAP_ST_TABLE_LOC_BINARY);
    constant VF5_TPHR_CAP_ST_TABLE_SIZE_STRLEN : integer := getstrlength(VF5_TPHR_CAP_ST_TABLE_SIZE_BINARY);
    constant VF5_TPHR_CAP_VER_STRLEN : integer := getstrlength(VF5_TPHR_CAP_VER_BINARY);
    
    -- Convert std_logic_vector to string
    constant AXISTEN_IF_ENABLE_MSG_ROUTE_STRING : string := SLV_TO_HEX(AXISTEN_IF_ENABLE_MSG_ROUTE_BINARY, AXISTEN_IF_ENABLE_MSG_ROUTE_STRLEN);
    constant AXISTEN_IF_WIDTH_STRING : string := SLV_TO_HEX(AXISTEN_IF_WIDTH_BINARY, AXISTEN_IF_WIDTH_STRLEN);
    constant CRM_USER_CLK_FREQ_STRING : string := SLV_TO_HEX(CRM_USER_CLK_FREQ_BINARY, CRM_USER_CLK_FREQ_STRLEN);
    constant DNSTREAM_LINK_NUM_STRING : string := SLV_TO_HEX(DNSTREAM_LINK_NUM_BINARY, DNSTREAM_LINK_NUM_STRLEN);
    constant GEN3_PCS_AUTO_REALIGN_STRING : string := SLV_TO_HEX(GEN3_PCS_AUTO_REALIGN_BINARY, GEN3_PCS_AUTO_REALIGN_STRLEN);
    constant LL_ACK_TIMEOUT_STRING : string := SLV_TO_HEX(LL_ACK_TIMEOUT_BINARY, LL_ACK_TIMEOUT_STRLEN);
    constant LL_CPL_FC_UPDATE_TIMER_STRING : string := SLV_TO_HEX(LL_CPL_FC_UPDATE_TIMER_BINARY, LL_CPL_FC_UPDATE_TIMER_STRLEN);
    constant LL_FC_UPDATE_TIMER_STRING : string := SLV_TO_HEX(LL_FC_UPDATE_TIMER_BINARY, LL_FC_UPDATE_TIMER_STRLEN);
    constant LL_NP_FC_UPDATE_TIMER_STRING : string := SLV_TO_HEX(LL_NP_FC_UPDATE_TIMER_BINARY, LL_NP_FC_UPDATE_TIMER_STRLEN);
    constant LL_P_FC_UPDATE_TIMER_STRING : string := SLV_TO_HEX(LL_P_FC_UPDATE_TIMER_BINARY, LL_P_FC_UPDATE_TIMER_STRLEN);
    constant LL_REPLAY_TIMEOUT_STRING : string := SLV_TO_HEX(LL_REPLAY_TIMEOUT_BINARY, LL_REPLAY_TIMEOUT_STRLEN);
    constant LTR_TX_MESSAGE_MINIMUM_INTERVAL_STRING : string := SLV_TO_HEX(LTR_TX_MESSAGE_MINIMUM_INTERVAL_BINARY, LTR_TX_MESSAGE_MINIMUM_INTERVAL_STRLEN);
    constant PF0_AER_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_AER_CAP_NEXTPTR_BINARY, PF0_AER_CAP_NEXTPTR_STRLEN);
    constant PF0_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_ARI_CAP_NEXTPTR_BINARY, PF0_ARI_CAP_NEXTPTR_STRLEN);
    constant PF0_ARI_CAP_NEXT_FUNC_STRING : string := SLV_TO_HEX(PF0_ARI_CAP_NEXT_FUNC_BINARY, PF0_ARI_CAP_NEXT_FUNC_STRLEN);
    constant PF0_ARI_CAP_VER_STRING : string := SLV_TO_HEX(PF0_ARI_CAP_VER_BINARY, PF0_ARI_CAP_VER_STRLEN);
    constant PF0_BAR0_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_BAR0_APERTURE_SIZE_BINARY, PF0_BAR0_APERTURE_SIZE_STRLEN);
    constant PF0_BAR0_CONTROL_STRING : string := SLV_TO_HEX(PF0_BAR0_CONTROL_BINARY, PF0_BAR0_CONTROL_STRLEN);
    constant PF0_BAR1_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_BAR1_APERTURE_SIZE_BINARY, PF0_BAR1_APERTURE_SIZE_STRLEN);
    constant PF0_BAR1_CONTROL_STRING : string := SLV_TO_HEX(PF0_BAR1_CONTROL_BINARY, PF0_BAR1_CONTROL_STRLEN);
    constant PF0_BAR2_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_BAR2_APERTURE_SIZE_BINARY, PF0_BAR2_APERTURE_SIZE_STRLEN);
    constant PF0_BAR2_CONTROL_STRING : string := SLV_TO_HEX(PF0_BAR2_CONTROL_BINARY, PF0_BAR2_CONTROL_STRLEN);
    constant PF0_BAR3_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_BAR3_APERTURE_SIZE_BINARY, PF0_BAR3_APERTURE_SIZE_STRLEN);
    constant PF0_BAR3_CONTROL_STRING : string := SLV_TO_HEX(PF0_BAR3_CONTROL_BINARY, PF0_BAR3_CONTROL_STRLEN);
    constant PF0_BAR4_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_BAR4_APERTURE_SIZE_BINARY, PF0_BAR4_APERTURE_SIZE_STRLEN);
    constant PF0_BAR4_CONTROL_STRING : string := SLV_TO_HEX(PF0_BAR4_CONTROL_BINARY, PF0_BAR4_CONTROL_STRLEN);
    constant PF0_BAR5_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_BAR5_APERTURE_SIZE_BINARY, PF0_BAR5_APERTURE_SIZE_STRLEN);
    constant PF0_BAR5_CONTROL_STRING : string := SLV_TO_HEX(PF0_BAR5_CONTROL_BINARY, PF0_BAR5_CONTROL_STRLEN);
    constant PF0_BIST_REGISTER_STRING : string := SLV_TO_HEX(PF0_BIST_REGISTER_BINARY, PF0_BIST_REGISTER_STRLEN);
    constant PF0_CAPABILITY_POINTER_STRING : string := SLV_TO_HEX(PF0_CAPABILITY_POINTER_BINARY, PF0_CAPABILITY_POINTER_STRLEN);
    constant PF0_CLASS_CODE_STRING : string := SLV_TO_HEX(PF0_CLASS_CODE_BINARY, PF0_CLASS_CODE_STRLEN);
    constant PF0_DEVICE_ID_STRING : string := SLV_TO_HEX(PF0_DEVICE_ID_BINARY, PF0_DEVICE_ID_STRLEN);
    constant PF0_DEV_CAP2_OBFF_SUPPORT_STRING : string := SLV_TO_HEX(PF0_DEV_CAP2_OBFF_SUPPORT_BINARY, PF0_DEV_CAP2_OBFF_SUPPORT_STRLEN);
    constant PF0_DEV_CAP_MAX_PAYLOAD_SIZE_STRING : string := SLV_TO_HEX(PF0_DEV_CAP_MAX_PAYLOAD_SIZE_BINARY, PF0_DEV_CAP_MAX_PAYLOAD_SIZE_STRLEN);
    constant PF0_DPA_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_NEXTPTR_BINARY, PF0_DPA_CAP_NEXTPTR_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_CONTROL_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_CONTROL_BINARY, PF0_DPA_CAP_SUB_STATE_CONTROL_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRLEN);
    constant PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_BINARY, PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRLEN);
    constant PF0_DPA_CAP_VER_STRING : string := SLV_TO_HEX(PF0_DPA_CAP_VER_BINARY, PF0_DPA_CAP_VER_STRLEN);
    constant PF0_DSN_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_DSN_CAP_NEXTPTR_BINARY, PF0_DSN_CAP_NEXTPTR_STRLEN);
    constant PF0_EXPANSION_ROM_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_EXPANSION_ROM_APERTURE_SIZE_BINARY, PF0_EXPANSION_ROM_APERTURE_SIZE_STRLEN);
    constant PF0_INTERRUPT_LINE_STRING : string := SLV_TO_HEX(PF0_INTERRUPT_LINE_BINARY, PF0_INTERRUPT_LINE_STRLEN);
    constant PF0_INTERRUPT_PIN_STRING : string := SLV_TO_HEX(PF0_INTERRUPT_PIN_BINARY, PF0_INTERRUPT_PIN_STRLEN);
    constant PF0_LTR_CAP_MAX_NOSNOOP_LAT_STRING : string := SLV_TO_HEX(PF0_LTR_CAP_MAX_NOSNOOP_LAT_BINARY, PF0_LTR_CAP_MAX_NOSNOOP_LAT_STRLEN);
    constant PF0_LTR_CAP_MAX_SNOOP_LAT_STRING : string := SLV_TO_HEX(PF0_LTR_CAP_MAX_SNOOP_LAT_BINARY, PF0_LTR_CAP_MAX_SNOOP_LAT_STRLEN);
    constant PF0_LTR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_LTR_CAP_NEXTPTR_BINARY, PF0_LTR_CAP_NEXTPTR_STRLEN);
    constant PF0_LTR_CAP_VER_STRING : string := SLV_TO_HEX(PF0_LTR_CAP_VER_BINARY, PF0_LTR_CAP_VER_STRLEN);
    constant PF0_MSIX_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_MSIX_CAP_NEXTPTR_BINARY, PF0_MSIX_CAP_NEXTPTR_STRLEN);
    constant PF0_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(PF0_MSIX_CAP_PBA_OFFSET_BINARY, PF0_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant PF0_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(PF0_MSIX_CAP_TABLE_OFFSET_BINARY, PF0_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant PF0_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(PF0_MSIX_CAP_TABLE_SIZE_BINARY, PF0_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant PF0_MSI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_MSI_CAP_NEXTPTR_BINARY, PF0_MSI_CAP_NEXTPTR_STRLEN);
    constant PF0_PB_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_PB_CAP_NEXTPTR_BINARY, PF0_PB_CAP_NEXTPTR_STRLEN);
    constant PF0_PB_CAP_VER_STRING : string := SLV_TO_HEX(PF0_PB_CAP_VER_BINARY, PF0_PB_CAP_VER_STRLEN);
    constant PF0_PM_CAP_ID_STRING : string := SLV_TO_HEX(PF0_PM_CAP_ID_BINARY, PF0_PM_CAP_ID_STRLEN);
    constant PF0_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_PM_CAP_NEXTPTR_BINARY, PF0_PM_CAP_NEXTPTR_STRLEN);
    constant PF0_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(PF0_PM_CAP_VER_ID_BINARY, PF0_PM_CAP_VER_ID_STRLEN);
    constant PF0_RBAR_CAP_INDEX0_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_INDEX0_BINARY, PF0_RBAR_CAP_INDEX0_STRLEN);
    constant PF0_RBAR_CAP_INDEX1_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_INDEX1_BINARY, PF0_RBAR_CAP_INDEX1_STRLEN);
    constant PF0_RBAR_CAP_INDEX2_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_INDEX2_BINARY, PF0_RBAR_CAP_INDEX2_STRLEN);
    constant PF0_RBAR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_NEXTPTR_BINARY, PF0_RBAR_CAP_NEXTPTR_STRLEN);
    constant PF0_RBAR_CAP_SIZE0_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_SIZE0_BINARY, PF0_RBAR_CAP_SIZE0_STRLEN);
    constant PF0_RBAR_CAP_SIZE1_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_SIZE1_BINARY, PF0_RBAR_CAP_SIZE1_STRLEN);
    constant PF0_RBAR_CAP_SIZE2_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_SIZE2_BINARY, PF0_RBAR_CAP_SIZE2_STRLEN);
    constant PF0_RBAR_CAP_VER_STRING : string := SLV_TO_HEX(PF0_RBAR_CAP_VER_BINARY, PF0_RBAR_CAP_VER_STRLEN);
    constant PF0_RBAR_NUM_STRING : string := SLV_TO_HEX(PF0_RBAR_NUM_BINARY, PF0_RBAR_NUM_STRLEN);
    constant PF0_REVISION_ID_STRING : string := SLV_TO_HEX(PF0_REVISION_ID_BINARY, PF0_REVISION_ID_STRLEN);
    constant PF0_SRIOV_BAR0_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR0_APERTURE_SIZE_BINARY, PF0_SRIOV_BAR0_APERTURE_SIZE_STRLEN);
    constant PF0_SRIOV_BAR0_CONTROL_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR0_CONTROL_BINARY, PF0_SRIOV_BAR0_CONTROL_STRLEN);
    constant PF0_SRIOV_BAR1_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR1_APERTURE_SIZE_BINARY, PF0_SRIOV_BAR1_APERTURE_SIZE_STRLEN);
    constant PF0_SRIOV_BAR1_CONTROL_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR1_CONTROL_BINARY, PF0_SRIOV_BAR1_CONTROL_STRLEN);
    constant PF0_SRIOV_BAR2_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR2_APERTURE_SIZE_BINARY, PF0_SRIOV_BAR2_APERTURE_SIZE_STRLEN);
    constant PF0_SRIOV_BAR2_CONTROL_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR2_CONTROL_BINARY, PF0_SRIOV_BAR2_CONTROL_STRLEN);
    constant PF0_SRIOV_BAR3_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR3_APERTURE_SIZE_BINARY, PF0_SRIOV_BAR3_APERTURE_SIZE_STRLEN);
    constant PF0_SRIOV_BAR3_CONTROL_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR3_CONTROL_BINARY, PF0_SRIOV_BAR3_CONTROL_STRLEN);
    constant PF0_SRIOV_BAR4_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR4_APERTURE_SIZE_BINARY, PF0_SRIOV_BAR4_APERTURE_SIZE_STRLEN);
    constant PF0_SRIOV_BAR4_CONTROL_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR4_CONTROL_BINARY, PF0_SRIOV_BAR4_CONTROL_STRLEN);
    constant PF0_SRIOV_BAR5_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR5_APERTURE_SIZE_BINARY, PF0_SRIOV_BAR5_APERTURE_SIZE_STRLEN);
    constant PF0_SRIOV_BAR5_CONTROL_STRING : string := SLV_TO_HEX(PF0_SRIOV_BAR5_CONTROL_BINARY, PF0_SRIOV_BAR5_CONTROL_STRLEN);
    constant PF0_SRIOV_CAP_INITIAL_VF_STRING : string := SLV_TO_HEX(PF0_SRIOV_CAP_INITIAL_VF_BINARY, PF0_SRIOV_CAP_INITIAL_VF_STRLEN);
    constant PF0_SRIOV_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_SRIOV_CAP_NEXTPTR_BINARY, PF0_SRIOV_CAP_NEXTPTR_STRLEN);
    constant PF0_SRIOV_CAP_TOTAL_VF_STRING : string := SLV_TO_HEX(PF0_SRIOV_CAP_TOTAL_VF_BINARY, PF0_SRIOV_CAP_TOTAL_VF_STRLEN);
    constant PF0_SRIOV_CAP_VER_STRING : string := SLV_TO_HEX(PF0_SRIOV_CAP_VER_BINARY, PF0_SRIOV_CAP_VER_STRLEN);
    constant PF0_SRIOV_FIRST_VF_OFFSET_STRING : string := SLV_TO_HEX(PF0_SRIOV_FIRST_VF_OFFSET_BINARY, PF0_SRIOV_FIRST_VF_OFFSET_STRLEN);
    constant PF0_SRIOV_FUNC_DEP_LINK_STRING : string := SLV_TO_HEX(PF0_SRIOV_FUNC_DEP_LINK_BINARY, PF0_SRIOV_FUNC_DEP_LINK_STRLEN);
    constant PF0_SRIOV_SUPPORTED_PAGE_SIZE_STRING : string := SLV_TO_HEX(PF0_SRIOV_SUPPORTED_PAGE_SIZE_BINARY, PF0_SRIOV_SUPPORTED_PAGE_SIZE_STRLEN);
    constant PF0_SRIOV_VF_DEVICE_ID_STRING : string := SLV_TO_HEX(PF0_SRIOV_VF_DEVICE_ID_BINARY, PF0_SRIOV_VF_DEVICE_ID_STRLEN);
    constant PF0_SUBSYSTEM_ID_STRING : string := SLV_TO_HEX(PF0_SUBSYSTEM_ID_BINARY, PF0_SUBSYSTEM_ID_STRLEN);
    constant PF0_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_TPHR_CAP_NEXTPTR_BINARY, PF0_TPHR_CAP_NEXTPTR_STRLEN);
    constant PF0_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(PF0_TPHR_CAP_ST_MODE_SEL_BINARY, PF0_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant PF0_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(PF0_TPHR_CAP_ST_TABLE_LOC_BINARY, PF0_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant PF0_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(PF0_TPHR_CAP_ST_TABLE_SIZE_BINARY, PF0_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant PF0_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(PF0_TPHR_CAP_VER_BINARY, PF0_TPHR_CAP_VER_STRLEN);
    constant PF0_VC_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF0_VC_CAP_NEXTPTR_BINARY, PF0_VC_CAP_NEXTPTR_STRLEN);
    constant PF0_VC_CAP_VER_STRING : string := SLV_TO_HEX(PF0_VC_CAP_VER_BINARY, PF0_VC_CAP_VER_STRLEN);
    constant PF1_AER_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_AER_CAP_NEXTPTR_BINARY, PF1_AER_CAP_NEXTPTR_STRLEN);
    constant PF1_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_ARI_CAP_NEXTPTR_BINARY, PF1_ARI_CAP_NEXTPTR_STRLEN);
    constant PF1_ARI_CAP_NEXT_FUNC_STRING : string := SLV_TO_HEX(PF1_ARI_CAP_NEXT_FUNC_BINARY, PF1_ARI_CAP_NEXT_FUNC_STRLEN);
    constant PF1_BAR0_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_BAR0_APERTURE_SIZE_BINARY, PF1_BAR0_APERTURE_SIZE_STRLEN);
    constant PF1_BAR0_CONTROL_STRING : string := SLV_TO_HEX(PF1_BAR0_CONTROL_BINARY, PF1_BAR0_CONTROL_STRLEN);
    constant PF1_BAR1_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_BAR1_APERTURE_SIZE_BINARY, PF1_BAR1_APERTURE_SIZE_STRLEN);
    constant PF1_BAR1_CONTROL_STRING : string := SLV_TO_HEX(PF1_BAR1_CONTROL_BINARY, PF1_BAR1_CONTROL_STRLEN);
    constant PF1_BAR2_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_BAR2_APERTURE_SIZE_BINARY, PF1_BAR2_APERTURE_SIZE_STRLEN);
    constant PF1_BAR2_CONTROL_STRING : string := SLV_TO_HEX(PF1_BAR2_CONTROL_BINARY, PF1_BAR2_CONTROL_STRLEN);
    constant PF1_BAR3_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_BAR3_APERTURE_SIZE_BINARY, PF1_BAR3_APERTURE_SIZE_STRLEN);
    constant PF1_BAR3_CONTROL_STRING : string := SLV_TO_HEX(PF1_BAR3_CONTROL_BINARY, PF1_BAR3_CONTROL_STRLEN);
    constant PF1_BAR4_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_BAR4_APERTURE_SIZE_BINARY, PF1_BAR4_APERTURE_SIZE_STRLEN);
    constant PF1_BAR4_CONTROL_STRING : string := SLV_TO_HEX(PF1_BAR4_CONTROL_BINARY, PF1_BAR4_CONTROL_STRLEN);
    constant PF1_BAR5_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_BAR5_APERTURE_SIZE_BINARY, PF1_BAR5_APERTURE_SIZE_STRLEN);
    constant PF1_BAR5_CONTROL_STRING : string := SLV_TO_HEX(PF1_BAR5_CONTROL_BINARY, PF1_BAR5_CONTROL_STRLEN);
    constant PF1_BIST_REGISTER_STRING : string := SLV_TO_HEX(PF1_BIST_REGISTER_BINARY, PF1_BIST_REGISTER_STRLEN);
    constant PF1_CAPABILITY_POINTER_STRING : string := SLV_TO_HEX(PF1_CAPABILITY_POINTER_BINARY, PF1_CAPABILITY_POINTER_STRLEN);
    constant PF1_CLASS_CODE_STRING : string := SLV_TO_HEX(PF1_CLASS_CODE_BINARY, PF1_CLASS_CODE_STRLEN);
    constant PF1_DEVICE_ID_STRING : string := SLV_TO_HEX(PF1_DEVICE_ID_BINARY, PF1_DEVICE_ID_STRLEN);
    constant PF1_DEV_CAP_MAX_PAYLOAD_SIZE_STRING : string := SLV_TO_HEX(PF1_DEV_CAP_MAX_PAYLOAD_SIZE_BINARY, PF1_DEV_CAP_MAX_PAYLOAD_SIZE_STRLEN);
    constant PF1_DPA_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_NEXTPTR_BINARY, PF1_DPA_CAP_NEXTPTR_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_CONTROL_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_CONTROL_BINARY, PF1_DPA_CAP_SUB_STATE_CONTROL_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRLEN);
    constant PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_BINARY, PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRLEN);
    constant PF1_DPA_CAP_VER_STRING : string := SLV_TO_HEX(PF1_DPA_CAP_VER_BINARY, PF1_DPA_CAP_VER_STRLEN);
    constant PF1_DSN_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_DSN_CAP_NEXTPTR_BINARY, PF1_DSN_CAP_NEXTPTR_STRLEN);
    constant PF1_EXPANSION_ROM_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_EXPANSION_ROM_APERTURE_SIZE_BINARY, PF1_EXPANSION_ROM_APERTURE_SIZE_STRLEN);
    constant PF1_INTERRUPT_LINE_STRING : string := SLV_TO_HEX(PF1_INTERRUPT_LINE_BINARY, PF1_INTERRUPT_LINE_STRLEN);
    constant PF1_INTERRUPT_PIN_STRING : string := SLV_TO_HEX(PF1_INTERRUPT_PIN_BINARY, PF1_INTERRUPT_PIN_STRLEN);
    constant PF1_MSIX_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_MSIX_CAP_NEXTPTR_BINARY, PF1_MSIX_CAP_NEXTPTR_STRLEN);
    constant PF1_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(PF1_MSIX_CAP_PBA_OFFSET_BINARY, PF1_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant PF1_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(PF1_MSIX_CAP_TABLE_OFFSET_BINARY, PF1_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant PF1_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(PF1_MSIX_CAP_TABLE_SIZE_BINARY, PF1_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant PF1_MSI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_MSI_CAP_NEXTPTR_BINARY, PF1_MSI_CAP_NEXTPTR_STRLEN);
    constant PF1_PB_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_PB_CAP_NEXTPTR_BINARY, PF1_PB_CAP_NEXTPTR_STRLEN);
    constant PF1_PB_CAP_VER_STRING : string := SLV_TO_HEX(PF1_PB_CAP_VER_BINARY, PF1_PB_CAP_VER_STRLEN);
    constant PF1_PM_CAP_ID_STRING : string := SLV_TO_HEX(PF1_PM_CAP_ID_BINARY, PF1_PM_CAP_ID_STRLEN);
    constant PF1_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_PM_CAP_NEXTPTR_BINARY, PF1_PM_CAP_NEXTPTR_STRLEN);
    constant PF1_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(PF1_PM_CAP_VER_ID_BINARY, PF1_PM_CAP_VER_ID_STRLEN);
    constant PF1_RBAR_CAP_INDEX0_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_INDEX0_BINARY, PF1_RBAR_CAP_INDEX0_STRLEN);
    constant PF1_RBAR_CAP_INDEX1_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_INDEX1_BINARY, PF1_RBAR_CAP_INDEX1_STRLEN);
    constant PF1_RBAR_CAP_INDEX2_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_INDEX2_BINARY, PF1_RBAR_CAP_INDEX2_STRLEN);
    constant PF1_RBAR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_NEXTPTR_BINARY, PF1_RBAR_CAP_NEXTPTR_STRLEN);
    constant PF1_RBAR_CAP_SIZE0_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_SIZE0_BINARY, PF1_RBAR_CAP_SIZE0_STRLEN);
    constant PF1_RBAR_CAP_SIZE1_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_SIZE1_BINARY, PF1_RBAR_CAP_SIZE1_STRLEN);
    constant PF1_RBAR_CAP_SIZE2_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_SIZE2_BINARY, PF1_RBAR_CAP_SIZE2_STRLEN);
    constant PF1_RBAR_CAP_VER_STRING : string := SLV_TO_HEX(PF1_RBAR_CAP_VER_BINARY, PF1_RBAR_CAP_VER_STRLEN);
    constant PF1_RBAR_NUM_STRING : string := SLV_TO_HEX(PF1_RBAR_NUM_BINARY, PF1_RBAR_NUM_STRLEN);
    constant PF1_REVISION_ID_STRING : string := SLV_TO_HEX(PF1_REVISION_ID_BINARY, PF1_REVISION_ID_STRLEN);
    constant PF1_SRIOV_BAR0_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR0_APERTURE_SIZE_BINARY, PF1_SRIOV_BAR0_APERTURE_SIZE_STRLEN);
    constant PF1_SRIOV_BAR0_CONTROL_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR0_CONTROL_BINARY, PF1_SRIOV_BAR0_CONTROL_STRLEN);
    constant PF1_SRIOV_BAR1_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR1_APERTURE_SIZE_BINARY, PF1_SRIOV_BAR1_APERTURE_SIZE_STRLEN);
    constant PF1_SRIOV_BAR1_CONTROL_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR1_CONTROL_BINARY, PF1_SRIOV_BAR1_CONTROL_STRLEN);
    constant PF1_SRIOV_BAR2_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR2_APERTURE_SIZE_BINARY, PF1_SRIOV_BAR2_APERTURE_SIZE_STRLEN);
    constant PF1_SRIOV_BAR2_CONTROL_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR2_CONTROL_BINARY, PF1_SRIOV_BAR2_CONTROL_STRLEN);
    constant PF1_SRIOV_BAR3_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR3_APERTURE_SIZE_BINARY, PF1_SRIOV_BAR3_APERTURE_SIZE_STRLEN);
    constant PF1_SRIOV_BAR3_CONTROL_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR3_CONTROL_BINARY, PF1_SRIOV_BAR3_CONTROL_STRLEN);
    constant PF1_SRIOV_BAR4_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR4_APERTURE_SIZE_BINARY, PF1_SRIOV_BAR4_APERTURE_SIZE_STRLEN);
    constant PF1_SRIOV_BAR4_CONTROL_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR4_CONTROL_BINARY, PF1_SRIOV_BAR4_CONTROL_STRLEN);
    constant PF1_SRIOV_BAR5_APERTURE_SIZE_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR5_APERTURE_SIZE_BINARY, PF1_SRIOV_BAR5_APERTURE_SIZE_STRLEN);
    constant PF1_SRIOV_BAR5_CONTROL_STRING : string := SLV_TO_HEX(PF1_SRIOV_BAR5_CONTROL_BINARY, PF1_SRIOV_BAR5_CONTROL_STRLEN);
    constant PF1_SRIOV_CAP_INITIAL_VF_STRING : string := SLV_TO_HEX(PF1_SRIOV_CAP_INITIAL_VF_BINARY, PF1_SRIOV_CAP_INITIAL_VF_STRLEN);
    constant PF1_SRIOV_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_SRIOV_CAP_NEXTPTR_BINARY, PF1_SRIOV_CAP_NEXTPTR_STRLEN);
    constant PF1_SRIOV_CAP_TOTAL_VF_STRING : string := SLV_TO_HEX(PF1_SRIOV_CAP_TOTAL_VF_BINARY, PF1_SRIOV_CAP_TOTAL_VF_STRLEN);
    constant PF1_SRIOV_CAP_VER_STRING : string := SLV_TO_HEX(PF1_SRIOV_CAP_VER_BINARY, PF1_SRIOV_CAP_VER_STRLEN);
    constant PF1_SRIOV_FIRST_VF_OFFSET_STRING : string := SLV_TO_HEX(PF1_SRIOV_FIRST_VF_OFFSET_BINARY, PF1_SRIOV_FIRST_VF_OFFSET_STRLEN);
    constant PF1_SRIOV_FUNC_DEP_LINK_STRING : string := SLV_TO_HEX(PF1_SRIOV_FUNC_DEP_LINK_BINARY, PF1_SRIOV_FUNC_DEP_LINK_STRLEN);
    constant PF1_SRIOV_SUPPORTED_PAGE_SIZE_STRING : string := SLV_TO_HEX(PF1_SRIOV_SUPPORTED_PAGE_SIZE_BINARY, PF1_SRIOV_SUPPORTED_PAGE_SIZE_STRLEN);
    constant PF1_SRIOV_VF_DEVICE_ID_STRING : string := SLV_TO_HEX(PF1_SRIOV_VF_DEVICE_ID_BINARY, PF1_SRIOV_VF_DEVICE_ID_STRLEN);
    constant PF1_SUBSYSTEM_ID_STRING : string := SLV_TO_HEX(PF1_SUBSYSTEM_ID_BINARY, PF1_SUBSYSTEM_ID_STRLEN);
    constant PF1_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PF1_TPHR_CAP_NEXTPTR_BINARY, PF1_TPHR_CAP_NEXTPTR_STRLEN);
    constant PF1_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(PF1_TPHR_CAP_ST_MODE_SEL_BINARY, PF1_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant PF1_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(PF1_TPHR_CAP_ST_TABLE_LOC_BINARY, PF1_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant PF1_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(PF1_TPHR_CAP_ST_TABLE_SIZE_BINARY, PF1_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant PF1_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(PF1_TPHR_CAP_VER_BINARY, PF1_TPHR_CAP_VER_STRLEN);
    constant PL_EQ_ADAPT_ITER_COUNT_STRING : string := SLV_TO_HEX(PL_EQ_ADAPT_ITER_COUNT_BINARY, PL_EQ_ADAPT_ITER_COUNT_STRLEN);
    constant PL_EQ_ADAPT_REJECT_RETRY_COUNT_STRING : string := SLV_TO_HEX(PL_EQ_ADAPT_REJECT_RETRY_COUNT_BINARY, PL_EQ_ADAPT_REJECT_RETRY_COUNT_STRLEN);
    constant PL_LANE0_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE0_EQ_CONTROL_BINARY, PL_LANE0_EQ_CONTROL_STRLEN);
    constant PL_LANE1_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE1_EQ_CONTROL_BINARY, PL_LANE1_EQ_CONTROL_STRLEN);
    constant PL_LANE2_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE2_EQ_CONTROL_BINARY, PL_LANE2_EQ_CONTROL_STRLEN);
    constant PL_LANE3_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE3_EQ_CONTROL_BINARY, PL_LANE3_EQ_CONTROL_STRLEN);
    constant PL_LANE4_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE4_EQ_CONTROL_BINARY, PL_LANE4_EQ_CONTROL_STRLEN);
    constant PL_LANE5_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE5_EQ_CONTROL_BINARY, PL_LANE5_EQ_CONTROL_STRLEN);
    constant PL_LANE6_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE6_EQ_CONTROL_BINARY, PL_LANE6_EQ_CONTROL_STRLEN);
    constant PL_LANE7_EQ_CONTROL_STRING : string := SLV_TO_HEX(PL_LANE7_EQ_CONTROL_BINARY, PL_LANE7_EQ_CONTROL_STRLEN);
    constant PL_LINK_CAP_MAX_LINK_SPEED_STRING : string := SLV_TO_HEX(PL_LINK_CAP_MAX_LINK_SPEED_BINARY, PL_LINK_CAP_MAX_LINK_SPEED_STRLEN);
    constant PL_LINK_CAP_MAX_LINK_WIDTH_STRING : string := SLV_TO_HEX(PL_LINK_CAP_MAX_LINK_WIDTH_BINARY, PL_LINK_CAP_MAX_LINK_WIDTH_STRLEN);
    constant PM_ASPML0S_TIMEOUT_STRING : string := SLV_TO_HEX(PM_ASPML0S_TIMEOUT_BINARY, PM_ASPML0S_TIMEOUT_STRLEN);
    constant PM_ASPML1_ENTRY_DELAY_STRING : string := SLV_TO_HEX(PM_ASPML1_ENTRY_DELAY_BINARY, PM_ASPML1_ENTRY_DELAY_STRLEN);
    constant PM_L1_REENTRY_DELAY_STRING : string := SLV_TO_HEX(PM_L1_REENTRY_DELAY_BINARY, PM_L1_REENTRY_DELAY_STRLEN);
    constant PM_PME_SERVICE_TIMEOUT_DELAY_STRING : string := SLV_TO_HEX(PM_PME_SERVICE_TIMEOUT_DELAY_BINARY, PM_PME_SERVICE_TIMEOUT_DELAY_STRLEN);
    constant PM_PME_TURNOFF_ACK_DELAY_STRING : string := SLV_TO_HEX(PM_PME_TURNOFF_ACK_DELAY_BINARY, PM_PME_TURNOFF_ACK_DELAY_STRLEN);
    constant SPARE_BYTE0_STRING : string := SLV_TO_HEX(SPARE_BYTE0_BINARY, SPARE_BYTE0_STRLEN);
    constant SPARE_BYTE1_STRING : string := SLV_TO_HEX(SPARE_BYTE1_BINARY, SPARE_BYTE1_STRLEN);
    constant SPARE_BYTE2_STRING : string := SLV_TO_HEX(SPARE_BYTE2_BINARY, SPARE_BYTE2_STRLEN);
    constant SPARE_BYTE3_STRING : string := SLV_TO_HEX(SPARE_BYTE3_BINARY, SPARE_BYTE3_STRLEN);
    constant SPARE_WORD0_STRING : string := SLV_TO_HEX(SPARE_WORD0_BINARY, SPARE_WORD0_STRLEN);
    constant SPARE_WORD1_STRING : string := SLV_TO_HEX(SPARE_WORD1_BINARY, SPARE_WORD1_STRLEN);
    constant SPARE_WORD2_STRING : string := SLV_TO_HEX(SPARE_WORD2_BINARY, SPARE_WORD2_STRLEN);
    constant SPARE_WORD3_STRING : string := SLV_TO_HEX(SPARE_WORD3_BINARY, SPARE_WORD3_STRLEN);
    constant TL_COMPL_TIMEOUT_REG0_STRING : string := SLV_TO_HEX(TL_COMPL_TIMEOUT_REG0_BINARY, TL_COMPL_TIMEOUT_REG0_STRLEN);
    constant TL_COMPL_TIMEOUT_REG1_STRING : string := SLV_TO_HEX(TL_COMPL_TIMEOUT_REG1_BINARY, TL_COMPL_TIMEOUT_REG1_STRLEN);
    constant TL_CREDITS_CD_STRING : string := SLV_TO_HEX(TL_CREDITS_CD_BINARY, TL_CREDITS_CD_STRLEN);
    constant TL_CREDITS_CH_STRING : string := SLV_TO_HEX(TL_CREDITS_CH_BINARY, TL_CREDITS_CH_STRLEN);
    constant TL_CREDITS_NPD_STRING : string := SLV_TO_HEX(TL_CREDITS_NPD_BINARY, TL_CREDITS_NPD_STRLEN);
    constant TL_CREDITS_NPH_STRING : string := SLV_TO_HEX(TL_CREDITS_NPH_BINARY, TL_CREDITS_NPH_STRLEN);
    constant TL_CREDITS_PD_STRING : string := SLV_TO_HEX(TL_CREDITS_PD_BINARY, TL_CREDITS_PD_STRLEN);
    constant TL_CREDITS_PH_STRING : string := SLV_TO_HEX(TL_CREDITS_PH_BINARY, TL_CREDITS_PH_STRLEN);
    constant VF0_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF0_ARI_CAP_NEXTPTR_BINARY, VF0_ARI_CAP_NEXTPTR_STRLEN);
    constant VF0_CAPABILITY_POINTER_STRING : string := SLV_TO_HEX(VF0_CAPABILITY_POINTER_BINARY, VF0_CAPABILITY_POINTER_STRLEN);
    constant VF0_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(VF0_MSIX_CAP_PBA_OFFSET_BINARY, VF0_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant VF0_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(VF0_MSIX_CAP_TABLE_OFFSET_BINARY, VF0_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant VF0_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF0_MSIX_CAP_TABLE_SIZE_BINARY, VF0_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant VF0_PM_CAP_ID_STRING : string := SLV_TO_HEX(VF0_PM_CAP_ID_BINARY, VF0_PM_CAP_ID_STRLEN);
    constant VF0_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF0_PM_CAP_NEXTPTR_BINARY, VF0_PM_CAP_NEXTPTR_STRLEN);
    constant VF0_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(VF0_PM_CAP_VER_ID_BINARY, VF0_PM_CAP_VER_ID_STRLEN);
    constant VF0_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF0_TPHR_CAP_NEXTPTR_BINARY, VF0_TPHR_CAP_NEXTPTR_STRLEN);
    constant VF0_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(VF0_TPHR_CAP_ST_MODE_SEL_BINARY, VF0_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant VF0_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(VF0_TPHR_CAP_ST_TABLE_LOC_BINARY, VF0_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant VF0_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF0_TPHR_CAP_ST_TABLE_SIZE_BINARY, VF0_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant VF0_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(VF0_TPHR_CAP_VER_BINARY, VF0_TPHR_CAP_VER_STRLEN);
    constant VF1_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF1_ARI_CAP_NEXTPTR_BINARY, VF1_ARI_CAP_NEXTPTR_STRLEN);
    constant VF1_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(VF1_MSIX_CAP_PBA_OFFSET_BINARY, VF1_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant VF1_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(VF1_MSIX_CAP_TABLE_OFFSET_BINARY, VF1_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant VF1_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF1_MSIX_CAP_TABLE_SIZE_BINARY, VF1_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant VF1_PM_CAP_ID_STRING : string := SLV_TO_HEX(VF1_PM_CAP_ID_BINARY, VF1_PM_CAP_ID_STRLEN);
    constant VF1_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF1_PM_CAP_NEXTPTR_BINARY, VF1_PM_CAP_NEXTPTR_STRLEN);
    constant VF1_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(VF1_PM_CAP_VER_ID_BINARY, VF1_PM_CAP_VER_ID_STRLEN);
    constant VF1_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF1_TPHR_CAP_NEXTPTR_BINARY, VF1_TPHR_CAP_NEXTPTR_STRLEN);
    constant VF1_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(VF1_TPHR_CAP_ST_MODE_SEL_BINARY, VF1_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant VF1_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(VF1_TPHR_CAP_ST_TABLE_LOC_BINARY, VF1_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant VF1_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF1_TPHR_CAP_ST_TABLE_SIZE_BINARY, VF1_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant VF1_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(VF1_TPHR_CAP_VER_BINARY, VF1_TPHR_CAP_VER_STRLEN);
    constant VF2_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF2_ARI_CAP_NEXTPTR_BINARY, VF2_ARI_CAP_NEXTPTR_STRLEN);
    constant VF2_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(VF2_MSIX_CAP_PBA_OFFSET_BINARY, VF2_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant VF2_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(VF2_MSIX_CAP_TABLE_OFFSET_BINARY, VF2_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant VF2_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF2_MSIX_CAP_TABLE_SIZE_BINARY, VF2_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant VF2_PM_CAP_ID_STRING : string := SLV_TO_HEX(VF2_PM_CAP_ID_BINARY, VF2_PM_CAP_ID_STRLEN);
    constant VF2_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF2_PM_CAP_NEXTPTR_BINARY, VF2_PM_CAP_NEXTPTR_STRLEN);
    constant VF2_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(VF2_PM_CAP_VER_ID_BINARY, VF2_PM_CAP_VER_ID_STRLEN);
    constant VF2_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF2_TPHR_CAP_NEXTPTR_BINARY, VF2_TPHR_CAP_NEXTPTR_STRLEN);
    constant VF2_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(VF2_TPHR_CAP_ST_MODE_SEL_BINARY, VF2_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant VF2_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(VF2_TPHR_CAP_ST_TABLE_LOC_BINARY, VF2_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant VF2_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF2_TPHR_CAP_ST_TABLE_SIZE_BINARY, VF2_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant VF2_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(VF2_TPHR_CAP_VER_BINARY, VF2_TPHR_CAP_VER_STRLEN);
    constant VF3_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF3_ARI_CAP_NEXTPTR_BINARY, VF3_ARI_CAP_NEXTPTR_STRLEN);
    constant VF3_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(VF3_MSIX_CAP_PBA_OFFSET_BINARY, VF3_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant VF3_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(VF3_MSIX_CAP_TABLE_OFFSET_BINARY, VF3_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant VF3_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF3_MSIX_CAP_TABLE_SIZE_BINARY, VF3_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant VF3_PM_CAP_ID_STRING : string := SLV_TO_HEX(VF3_PM_CAP_ID_BINARY, VF3_PM_CAP_ID_STRLEN);
    constant VF3_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF3_PM_CAP_NEXTPTR_BINARY, VF3_PM_CAP_NEXTPTR_STRLEN);
    constant VF3_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(VF3_PM_CAP_VER_ID_BINARY, VF3_PM_CAP_VER_ID_STRLEN);
    constant VF3_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF3_TPHR_CAP_NEXTPTR_BINARY, VF3_TPHR_CAP_NEXTPTR_STRLEN);
    constant VF3_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(VF3_TPHR_CAP_ST_MODE_SEL_BINARY, VF3_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant VF3_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(VF3_TPHR_CAP_ST_TABLE_LOC_BINARY, VF3_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant VF3_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF3_TPHR_CAP_ST_TABLE_SIZE_BINARY, VF3_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant VF3_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(VF3_TPHR_CAP_VER_BINARY, VF3_TPHR_CAP_VER_STRLEN);
    constant VF4_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF4_ARI_CAP_NEXTPTR_BINARY, VF4_ARI_CAP_NEXTPTR_STRLEN);
    constant VF4_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(VF4_MSIX_CAP_PBA_OFFSET_BINARY, VF4_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant VF4_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(VF4_MSIX_CAP_TABLE_OFFSET_BINARY, VF4_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant VF4_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF4_MSIX_CAP_TABLE_SIZE_BINARY, VF4_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant VF4_PM_CAP_ID_STRING : string := SLV_TO_HEX(VF4_PM_CAP_ID_BINARY, VF4_PM_CAP_ID_STRLEN);
    constant VF4_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF4_PM_CAP_NEXTPTR_BINARY, VF4_PM_CAP_NEXTPTR_STRLEN);
    constant VF4_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(VF4_PM_CAP_VER_ID_BINARY, VF4_PM_CAP_VER_ID_STRLEN);
    constant VF4_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF4_TPHR_CAP_NEXTPTR_BINARY, VF4_TPHR_CAP_NEXTPTR_STRLEN);
    constant VF4_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(VF4_TPHR_CAP_ST_MODE_SEL_BINARY, VF4_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant VF4_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(VF4_TPHR_CAP_ST_TABLE_LOC_BINARY, VF4_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant VF4_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF4_TPHR_CAP_ST_TABLE_SIZE_BINARY, VF4_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant VF4_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(VF4_TPHR_CAP_VER_BINARY, VF4_TPHR_CAP_VER_STRLEN);
    constant VF5_ARI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF5_ARI_CAP_NEXTPTR_BINARY, VF5_ARI_CAP_NEXTPTR_STRLEN);
    constant VF5_MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(VF5_MSIX_CAP_PBA_OFFSET_BINARY, VF5_MSIX_CAP_PBA_OFFSET_STRLEN);
    constant VF5_MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(VF5_MSIX_CAP_TABLE_OFFSET_BINARY, VF5_MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant VF5_MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF5_MSIX_CAP_TABLE_SIZE_BINARY, VF5_MSIX_CAP_TABLE_SIZE_STRLEN);
    constant VF5_PM_CAP_ID_STRING : string := SLV_TO_HEX(VF5_PM_CAP_ID_BINARY, VF5_PM_CAP_ID_STRLEN);
    constant VF5_PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF5_PM_CAP_NEXTPTR_BINARY, VF5_PM_CAP_NEXTPTR_STRLEN);
    constant VF5_PM_CAP_VER_ID_STRING : string := SLV_TO_HEX(VF5_PM_CAP_VER_ID_BINARY, VF5_PM_CAP_VER_ID_STRLEN);
    constant VF5_TPHR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VF5_TPHR_CAP_NEXTPTR_BINARY, VF5_TPHR_CAP_NEXTPTR_STRLEN);
    constant VF5_TPHR_CAP_ST_MODE_SEL_STRING : string := SLV_TO_HEX(VF5_TPHR_CAP_ST_MODE_SEL_BINARY, VF5_TPHR_CAP_ST_MODE_SEL_STRLEN);
    constant VF5_TPHR_CAP_ST_TABLE_LOC_STRING : string := SLV_TO_HEX(VF5_TPHR_CAP_ST_TABLE_LOC_BINARY, VF5_TPHR_CAP_ST_TABLE_LOC_STRLEN);
    constant VF5_TPHR_CAP_ST_TABLE_SIZE_STRING : string := SLV_TO_HEX(VF5_TPHR_CAP_ST_TABLE_SIZE_BINARY, VF5_TPHR_CAP_ST_TABLE_SIZE_STRLEN);
    constant VF5_TPHR_CAP_VER_STRING : string := SLV_TO_HEX(VF5_TPHR_CAP_VER_BINARY, VF5_TPHR_CAP_VER_STRLEN);
    
    signal ARI_CAP_ENABLE_BINARY : std_ulogic;
    signal AXISTEN_IF_CC_ALIGNMENT_MODE_BINARY : std_ulogic;
    signal AXISTEN_IF_CC_PARITY_CHK_BINARY : std_ulogic;
    signal AXISTEN_IF_CQ_ALIGNMENT_MODE_BINARY : std_ulogic;
    signal AXISTEN_IF_ENABLE_CLIENT_TAG_BINARY : std_ulogic;
    signal AXISTEN_IF_ENABLE_RX_MSG_INTFC_BINARY : std_ulogic;
    signal AXISTEN_IF_RC_ALIGNMENT_MODE_BINARY : std_ulogic;
    signal AXISTEN_IF_RC_STRADDLE_BINARY : std_ulogic;
    signal AXISTEN_IF_RQ_ALIGNMENT_MODE_BINARY : std_ulogic;
    signal AXISTEN_IF_RQ_PARITY_CHK_BINARY : std_ulogic;
    signal CRM_CORE_CLK_FREQ_500_BINARY : std_ulogic;
    signal GEN3_PCS_RX_ELECIDLE_INTERNAL_BINARY : std_ulogic;
    signal LL_ACK_TIMEOUT_EN_BINARY : std_ulogic;
    signal LL_ACK_TIMEOUT_FUNC_BINARY : std_logic_vector(1 downto 0);
    signal LL_CPL_FC_UPDATE_TIMER_OVERRIDE_BINARY : std_ulogic;
    signal LL_FC_UPDATE_TIMER_OVERRIDE_BINARY : std_ulogic;
    signal LL_NP_FC_UPDATE_TIMER_OVERRIDE_BINARY : std_ulogic;
    signal LL_P_FC_UPDATE_TIMER_OVERRIDE_BINARY : std_ulogic;
    signal LL_REPLAY_TIMEOUT_EN_BINARY : std_ulogic;
    signal LL_REPLAY_TIMEOUT_FUNC_BINARY : std_logic_vector(1 downto 0);
    signal LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE_BINARY : std_ulogic;
    signal LTR_TX_MESSAGE_ON_LTR_ENABLE_BINARY : std_ulogic;
    signal PF0_AER_CAP_ECRC_CHECK_CAPABLE_BINARY : std_ulogic;
    signal PF0_AER_CAP_ECRC_GEN_CAPABLE_BINARY : std_ulogic;
    signal PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT_BINARY : std_ulogic;
    signal PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT_BINARY : std_ulogic;
    signal PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT_BINARY : std_ulogic;
    signal PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE_BINARY : std_ulogic;
    signal PF0_DEV_CAP2_LTR_SUPPORT_BINARY : std_ulogic;
    signal PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT_BINARY : std_ulogic;
    signal PF0_DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal PF0_DEV_CAP_ENDPOINT_L1_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal PF0_DEV_CAP_EXT_TAG_SUPPORTED_BINARY : std_ulogic;
    signal PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY : std_ulogic;
    signal PF0_DPA_CAP_SUB_STATE_CONTROL_EN_BINARY : std_ulogic;
    signal PF0_EXPANSION_ROM_ENABLE_BINARY : std_ulogic;
    signal PF0_LINK_CAP_ASPM_SUPPORT_BINARY : std_logic_vector(1 downto 0);
    signal PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3_BINARY : std_logic_vector(2 downto 0);
    signal PF0_LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY : std_ulogic;
    signal PF0_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal PF0_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal PF0_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal PF0_PB_CAP_SYSTEM_ALLOCATED_BINARY : std_ulogic;
    signal PF0_PM_CAP_PMESUPPORT_D0_BINARY : std_ulogic;
    signal PF0_PM_CAP_PMESUPPORT_D1_BINARY : std_ulogic;
    signal PF0_PM_CAP_PMESUPPORT_D3HOT_BINARY : std_ulogic;
    signal PF0_PM_CAP_SUPP_D1_STATE_BINARY : std_ulogic;
    signal PF0_PM_CSR_NOSOFTRESET_BINARY : std_ulogic;
    signal PF0_RBAR_CAP_ENABLE_BINARY : std_ulogic;
    signal PF0_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal PF0_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal PF0_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    signal PF1_AER_CAP_ECRC_CHECK_CAPABLE_BINARY : std_ulogic;
    signal PF1_AER_CAP_ECRC_GEN_CAPABLE_BINARY : std_ulogic;
    signal PF1_DPA_CAP_SUB_STATE_CONTROL_EN_BINARY : std_ulogic;
    signal PF1_EXPANSION_ROM_ENABLE_BINARY : std_ulogic;
    signal PF1_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal PF1_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal PF1_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal PF1_PB_CAP_SYSTEM_ALLOCATED_BINARY : std_ulogic;
    signal PF1_RBAR_CAP_ENABLE_BINARY : std_ulogic;
    signal PF1_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal PF1_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal PF1_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    signal PL_DISABLE_EI_INFER_IN_L0_BINARY : std_ulogic;
    signal PL_DISABLE_GEN3_DC_BALANCE_BINARY : std_ulogic;
    signal PL_DISABLE_SCRAMBLING_BINARY : std_ulogic;
    signal PL_DISABLE_UPCONFIG_CAPABLE_BINARY : std_ulogic;
    signal PL_EQ_ADAPT_DISABLE_COEFF_CHECK_BINARY : std_ulogic;
    signal PL_EQ_ADAPT_DISABLE_PRESET_CHECK_BINARY : std_ulogic;
    signal PL_EQ_BYPASS_PHASE23_BINARY : std_ulogic;
    signal PL_EQ_SHORT_ADAPT_PHASE_BINARY : std_ulogic;
    signal PL_N_FTS_COMCLK_GEN1_BINARY : std_logic_vector(7 downto 0);
    signal PL_N_FTS_COMCLK_GEN2_BINARY : std_logic_vector(7 downto 0);
    signal PL_N_FTS_COMCLK_GEN3_BINARY : std_logic_vector(7 downto 0);
    signal PL_N_FTS_GEN1_BINARY : std_logic_vector(7 downto 0);
    signal PL_N_FTS_GEN2_BINARY : std_logic_vector(7 downto 0);
    signal PL_N_FTS_GEN3_BINARY : std_logic_vector(7 downto 0);
    signal PL_SIM_FAST_LINK_TRAINING_BINARY : std_ulogic;
    signal PL_UPSTREAM_FACING_BINARY : std_ulogic;
    signal PM_ENABLE_SLOT_POWER_CAPTURE_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    signal SPARE_BIT0_BINARY : std_ulogic;
    signal SPARE_BIT1_BINARY : std_ulogic;
    signal SPARE_BIT2_BINARY : std_ulogic;
    signal SPARE_BIT3_BINARY : std_ulogic;
    signal SPARE_BIT4_BINARY : std_ulogic;
    signal SPARE_BIT5_BINARY : std_ulogic;
    signal SPARE_BIT6_BINARY : std_ulogic;
    signal SPARE_BIT7_BINARY : std_ulogic;
    signal SPARE_BIT8_BINARY : std_ulogic;
    signal SRIOV_CAP_ENABLE_BINARY : std_ulogic;
    signal TL_ENABLE_MESSAGE_RID_CHECK_ENABLE_BINARY : std_ulogic;
    signal TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE_BINARY : std_ulogic;
    signal TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE_BINARY : std_ulogic;
    signal TL_LEGACY_MODE_ENABLE_BINARY : std_ulogic;
    signal TL_PF_ENABLE_REG_BINARY : std_ulogic;
    signal TL_TAG_MGMT_ENABLE_BINARY : std_ulogic;
    signal VF0_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF0_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF0_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal VF0_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal VF0_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal VF0_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    signal VF1_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF1_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF1_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal VF1_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal VF1_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal VF1_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    signal VF2_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF2_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF2_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal VF2_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal VF2_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal VF2_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    signal VF3_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF3_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF3_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal VF3_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal VF3_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal VF3_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    signal VF4_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF4_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF4_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal VF4_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal VF4_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal VF4_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    signal VF5_MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF5_MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal VF5_MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal VF5_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY : std_ulogic;
    signal VF5_TPHR_CAP_ENABLE_BINARY : std_ulogic;
    signal VF5_TPHR_CAP_INT_VEC_MODE_BINARY : std_ulogic;
    
    signal CFGCURRENTSPEED_out : std_logic_vector(2 downto 0);
    signal CFGDPASUBSTATECHANGE_out : std_logic_vector(1 downto 0);
    signal CFGERRCOROUT_out : std_ulogic;
    signal CFGERRFATALOUT_out : std_ulogic;
    signal CFGERRNONFATALOUT_out : std_ulogic;
    signal CFGEXTFUNCTIONNUMBER_out : std_logic_vector(7 downto 0);
    signal CFGEXTREADRECEIVED_out : std_ulogic;
    signal CFGEXTREGISTERNUMBER_out : std_logic_vector(9 downto 0);
    signal CFGEXTWRITEBYTEENABLE_out : std_logic_vector(3 downto 0);
    signal CFGEXTWRITEDATA_out : std_logic_vector(31 downto 0);
    signal CFGEXTWRITERECEIVED_out : std_ulogic;
    signal CFGFCCPLD_out : std_logic_vector(11 downto 0);
    signal CFGFCCPLH_out : std_logic_vector(7 downto 0);
    signal CFGFCNPD_out : std_logic_vector(11 downto 0);
    signal CFGFCNPH_out : std_logic_vector(7 downto 0);
    signal CFGFCPD_out : std_logic_vector(11 downto 0);
    signal CFGFCPH_out : std_logic_vector(7 downto 0);
    signal CFGFLRINPROCESS_out : std_logic_vector(1 downto 0);
    signal CFGFUNCTIONPOWERSTATE_out : std_logic_vector(5 downto 0);
    signal CFGFUNCTIONSTATUS_out : std_logic_vector(7 downto 0);
    signal CFGHOTRESETOUT_out : std_ulogic;
    signal CFGINPUTUPDATEDONE_out : std_ulogic;
    signal CFGINTERRUPTAOUTPUT_out : std_ulogic;
    signal CFGINTERRUPTBOUTPUT_out : std_ulogic;
    signal CFGINTERRUPTCOUTPUT_out : std_ulogic;
    signal CFGINTERRUPTDOUTPUT_out : std_ulogic;
    signal CFGINTERRUPTMSIDATA_out : std_logic_vector(31 downto 0);
    signal CFGINTERRUPTMSIENABLE_out : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIFAIL_out : std_ulogic;
    signal CFGINTERRUPTMSIMASKUPDATE_out : std_ulogic;
    signal CFGINTERRUPTMSIMMENABLE_out : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTMSISENT_out : std_ulogic;
    signal CFGINTERRUPTMSIVFENABLE_out : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTMSIXENABLE_out : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIXFAIL_out : std_ulogic;
    signal CFGINTERRUPTMSIXMASK_out : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIXSENT_out : std_ulogic;
    signal CFGINTERRUPTMSIXVFENABLE_out : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTMSIXVFMASK_out : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTSENT_out : std_ulogic;
    signal CFGLINKPOWERSTATE_out : std_logic_vector(1 downto 0);
    signal CFGLOCALERROR_out : std_ulogic;
    signal CFGLTRENABLE_out : std_ulogic;
    signal CFGLTSSMSTATE_out : std_logic_vector(5 downto 0);
    signal CFGMAXPAYLOAD_out : std_logic_vector(2 downto 0);
    signal CFGMAXREADREQ_out : std_logic_vector(2 downto 0);
    signal CFGMCUPDATEDONE_out : std_ulogic;
    signal CFGMGMTREADDATA_out : std_logic_vector(31 downto 0);
    signal CFGMGMTREADWRITEDONE_out : std_ulogic;
    signal CFGMSGRECEIVEDDATA_out : std_logic_vector(7 downto 0);
    signal CFGMSGRECEIVEDTYPE_out : std_logic_vector(4 downto 0);
    signal CFGMSGRECEIVED_out : std_ulogic;
    signal CFGMSGTRANSMITDONE_out : std_ulogic;
    signal CFGNEGOTIATEDWIDTH_out : std_logic_vector(3 downto 0);
    signal CFGOBFFENABLE_out : std_logic_vector(1 downto 0);
    signal CFGPERFUNCSTATUSDATA_out : std_logic_vector(15 downto 0);
    signal CFGPERFUNCTIONUPDATEDONE_out : std_ulogic;
    signal CFGPHYLINKDOWN_out : std_ulogic;
    signal CFGPHYLINKSTATUS_out : std_logic_vector(1 downto 0);
    signal CFGPLSTATUSCHANGE_out : std_ulogic;
    signal CFGPOWERSTATECHANGEINTERRUPT_out : std_ulogic;
    signal CFGRCBSTATUS_out : std_logic_vector(1 downto 0);
    signal CFGTPHFUNCTIONNUM_out : std_logic_vector(2 downto 0);
    signal CFGTPHREQUESTERENABLE_out : std_logic_vector(1 downto 0);
    signal CFGTPHSTMODE_out : std_logic_vector(5 downto 0);
    signal CFGTPHSTTADDRESS_out : std_logic_vector(4 downto 0);
    signal CFGTPHSTTREADENABLE_out : std_ulogic;
    signal CFGTPHSTTWRITEBYTEVALID_out : std_logic_vector(3 downto 0);
    signal CFGTPHSTTWRITEDATA_out : std_logic_vector(31 downto 0);
    signal CFGTPHSTTWRITEENABLE_out : std_ulogic;
    signal CFGVFFLRINPROCESS_out : std_logic_vector(5 downto 0);
    signal CFGVFPOWERSTATE_out : std_logic_vector(17 downto 0);
    signal CFGVFSTATUS_out : std_logic_vector(11 downto 0);
    signal CFGVFTPHREQUESTERENABLE_out : std_logic_vector(5 downto 0);
    signal CFGVFTPHSTMODE_out : std_logic_vector(17 downto 0);
    signal DBGDATAOUT_out : std_logic_vector(15 downto 0);
    signal DRPDO_out : std_logic_vector(15 downto 0);
    signal DRPRDY_out : std_ulogic;
    signal MAXISCQTDATA_out : std_logic_vector(255 downto 0);
    signal MAXISCQTKEEP_out : std_logic_vector(7 downto 0);
    signal MAXISCQTLAST_out : std_ulogic;
    signal MAXISCQTUSER_out : std_logic_vector(84 downto 0);
    signal MAXISCQTVALID_out : std_ulogic;
    signal MAXISRCTDATA_out : std_logic_vector(255 downto 0);
    signal MAXISRCTKEEP_out : std_logic_vector(7 downto 0);
    signal MAXISRCTLAST_out : std_ulogic;
    signal MAXISRCTUSER_out : std_logic_vector(74 downto 0);
    signal MAXISRCTVALID_out : std_ulogic;
    signal MICOMPLETIONRAMREADADDRESSAL_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADADDRESSAU_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADADDRESSBL_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADADDRESSBU_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADENABLEL_out : std_logic_vector(3 downto 0);
    signal MICOMPLETIONRAMREADENABLEU_out : std_logic_vector(3 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSAL_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSAU_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSBL_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSBU_out : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEDATAL_out : std_logic_vector(71 downto 0);
    signal MICOMPLETIONRAMWRITEDATAU_out : std_logic_vector(71 downto 0);
    signal MICOMPLETIONRAMWRITEENABLEL_out : std_logic_vector(3 downto 0);
    signal MICOMPLETIONRAMWRITEENABLEU_out : std_logic_vector(3 downto 0);
    signal MIREPLAYRAMADDRESS_out : std_logic_vector(8 downto 0);
    signal MIREPLAYRAMREADENABLE_out : std_logic_vector(1 downto 0);
    signal MIREPLAYRAMWRITEDATA_out : std_logic_vector(143 downto 0);
    signal MIREPLAYRAMWRITEENABLE_out : std_logic_vector(1 downto 0);
    signal MIREQUESTRAMREADADDRESSA_out : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMREADADDRESSB_out : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMREADENABLE_out : std_logic_vector(3 downto 0);
    signal MIREQUESTRAMWRITEADDRESSA_out : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMWRITEADDRESSB_out : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMWRITEDATA_out : std_logic_vector(143 downto 0);
    signal MIREQUESTRAMWRITEENABLE_out : std_logic_vector(3 downto 0);
    signal PCIECQNPREQCOUNT_out : std_logic_vector(5 downto 0);
    signal PCIERQSEQNUMVLD_out : std_ulogic;
    signal PCIERQSEQNUM_out : std_logic_vector(3 downto 0);
    signal PCIERQTAGAV_out : std_logic_vector(1 downto 0);
    signal PCIERQTAGVLD_out : std_ulogic;
    signal PCIERQTAG_out : std_logic_vector(5 downto 0);
    signal PCIETFCNPDAV_out : std_logic_vector(1 downto 0);
    signal PCIETFCNPHAV_out : std_logic_vector(1 downto 0);
    signal PIPERX0EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX0EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX0EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX0EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX0POLARITY_out : std_ulogic;
    signal PIPERX1EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX1EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX1EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX1EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX1POLARITY_out : std_ulogic;
    signal PIPERX2EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX2EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX2EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX2EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX2POLARITY_out : std_ulogic;
    signal PIPERX3EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX3EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX3EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX3EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX3POLARITY_out : std_ulogic;
    signal PIPERX4EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX4EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX4EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX4EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX4POLARITY_out : std_ulogic;
    signal PIPERX5EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX5EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX5EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX5EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX5POLARITY_out : std_ulogic;
    signal PIPERX6EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX6EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX6EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX6EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX6POLARITY_out : std_ulogic;
    signal PIPERX7EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPERX7EQLPLFFS_out : std_logic_vector(5 downto 0);
    signal PIPERX7EQLPTXPRESET_out : std_logic_vector(3 downto 0);
    signal PIPERX7EQPRESET_out : std_logic_vector(2 downto 0);
    signal PIPERX7POLARITY_out : std_ulogic;
    signal PIPETX0CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX0COMPLIANCE_out : std_ulogic;
    signal PIPETX0DATAVALID_out : std_ulogic;
    signal PIPETX0DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX0ELECIDLE_out : std_ulogic;
    signal PIPETX0EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX0EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX0EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX0POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX0STARTBLOCK_out : std_ulogic;
    signal PIPETX0SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETX1CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX1COMPLIANCE_out : std_ulogic;
    signal PIPETX1DATAVALID_out : std_ulogic;
    signal PIPETX1DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX1ELECIDLE_out : std_ulogic;
    signal PIPETX1EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX1EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX1EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX1POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX1STARTBLOCK_out : std_ulogic;
    signal PIPETX1SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETX2CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX2COMPLIANCE_out : std_ulogic;
    signal PIPETX2DATAVALID_out : std_ulogic;
    signal PIPETX2DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX2ELECIDLE_out : std_ulogic;
    signal PIPETX2EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX2EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX2EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX2POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX2STARTBLOCK_out : std_ulogic;
    signal PIPETX2SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETX3CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX3COMPLIANCE_out : std_ulogic;
    signal PIPETX3DATAVALID_out : std_ulogic;
    signal PIPETX3DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX3ELECIDLE_out : std_ulogic;
    signal PIPETX3EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX3EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX3EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX3POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX3STARTBLOCK_out : std_ulogic;
    signal PIPETX3SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETX4CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX4COMPLIANCE_out : std_ulogic;
    signal PIPETX4DATAVALID_out : std_ulogic;
    signal PIPETX4DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX4ELECIDLE_out : std_ulogic;
    signal PIPETX4EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX4EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX4EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX4POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX4STARTBLOCK_out : std_ulogic;
    signal PIPETX4SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETX5CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX5COMPLIANCE_out : std_ulogic;
    signal PIPETX5DATAVALID_out : std_ulogic;
    signal PIPETX5DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX5ELECIDLE_out : std_ulogic;
    signal PIPETX5EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX5EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX5EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX5POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX5STARTBLOCK_out : std_ulogic;
    signal PIPETX5SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETX6CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX6COMPLIANCE_out : std_ulogic;
    signal PIPETX6DATAVALID_out : std_ulogic;
    signal PIPETX6DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX6ELECIDLE_out : std_ulogic;
    signal PIPETX6EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX6EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX6EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX6POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX6STARTBLOCK_out : std_ulogic;
    signal PIPETX6SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETX7CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX7COMPLIANCE_out : std_ulogic;
    signal PIPETX7DATAVALID_out : std_ulogic;
    signal PIPETX7DATA_out : std_logic_vector(31 downto 0);
    signal PIPETX7ELECIDLE_out : std_ulogic;
    signal PIPETX7EQCONTROL_out : std_logic_vector(1 downto 0);
    signal PIPETX7EQDEEMPH_out : std_logic_vector(5 downto 0);
    signal PIPETX7EQPRESET_out : std_logic_vector(3 downto 0);
    signal PIPETX7POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX7STARTBLOCK_out : std_ulogic;
    signal PIPETX7SYNCHEADER_out : std_logic_vector(1 downto 0);
    signal PIPETXDEEMPH_out : std_ulogic;
    signal PIPETXMARGIN_out : std_logic_vector(2 downto 0);
    signal PIPETXRATE_out : std_logic_vector(1 downto 0);
    signal PIPETXRCVRDET_out : std_ulogic;
    signal PIPETXRESET_out : std_ulogic;
    signal PIPETXSWING_out : std_ulogic;
    signal PLEQINPROGRESS_out : std_ulogic;
    signal PLEQPHASE_out : std_logic_vector(1 downto 0);
    signal PLGEN3PCSRXSLIDE_out : std_logic_vector(7 downto 0);
    signal SAXISCCTREADY_out : std_logic_vector(3 downto 0);
    signal SAXISRQTREADY_out : std_logic_vector(3 downto 0);
    
    signal CFGCURRENTSPEED_outdelay : std_logic_vector(2 downto 0);
    signal CFGDPASUBSTATECHANGE_outdelay : std_logic_vector(1 downto 0);
    signal CFGERRCOROUT_outdelay : std_ulogic;
    signal CFGERRFATALOUT_outdelay : std_ulogic;
    signal CFGERRNONFATALOUT_outdelay : std_ulogic;
    signal CFGEXTFUNCTIONNUMBER_outdelay : std_logic_vector(7 downto 0);
    signal CFGEXTREADRECEIVED_outdelay : std_ulogic;
    signal CFGEXTREGISTERNUMBER_outdelay : std_logic_vector(9 downto 0);
    signal CFGEXTWRITEBYTEENABLE_outdelay : std_logic_vector(3 downto 0);
    signal CFGEXTWRITEDATA_outdelay : std_logic_vector(31 downto 0);
    signal CFGEXTWRITERECEIVED_outdelay : std_ulogic;
    signal CFGFCCPLD_outdelay : std_logic_vector(11 downto 0);
    signal CFGFCCPLH_outdelay : std_logic_vector(7 downto 0);
    signal CFGFCNPD_outdelay : std_logic_vector(11 downto 0);
    signal CFGFCNPH_outdelay : std_logic_vector(7 downto 0);
    signal CFGFCPD_outdelay : std_logic_vector(11 downto 0);
    signal CFGFCPH_outdelay : std_logic_vector(7 downto 0);
    signal CFGFLRINPROCESS_outdelay : std_logic_vector(1 downto 0);
    signal CFGFUNCTIONPOWERSTATE_outdelay : std_logic_vector(5 downto 0);
    signal CFGFUNCTIONSTATUS_outdelay : std_logic_vector(7 downto 0);
    signal CFGHOTRESETOUT_outdelay : std_ulogic;
    signal CFGINPUTUPDATEDONE_outdelay : std_ulogic;
    signal CFGINTERRUPTAOUTPUT_outdelay : std_ulogic;
    signal CFGINTERRUPTBOUTPUT_outdelay : std_ulogic;
    signal CFGINTERRUPTCOUTPUT_outdelay : std_ulogic;
    signal CFGINTERRUPTDOUTPUT_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIDATA_outdelay : std_logic_vector(31 downto 0);
    signal CFGINTERRUPTMSIENABLE_outdelay : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIFAIL_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIMASKUPDATE_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIMMENABLE_outdelay : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTMSISENT_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIVFENABLE_outdelay : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTMSIXENABLE_outdelay : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIXFAIL_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIXMASK_outdelay : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIXSENT_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIXVFENABLE_outdelay : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTMSIXVFMASK_outdelay : std_logic_vector(5 downto 0);
    signal CFGINTERRUPTSENT_outdelay : std_ulogic;
    signal CFGLINKPOWERSTATE_outdelay : std_logic_vector(1 downto 0);
    signal CFGLOCALERROR_outdelay : std_ulogic;
    signal CFGLTRENABLE_outdelay : std_ulogic;
    signal CFGLTSSMSTATE_outdelay : std_logic_vector(5 downto 0);
    signal CFGMAXPAYLOAD_outdelay : std_logic_vector(2 downto 0);
    signal CFGMAXREADREQ_outdelay : std_logic_vector(2 downto 0);
    signal CFGMCUPDATEDONE_outdelay : std_ulogic;
    signal CFGMGMTREADDATA_outdelay : std_logic_vector(31 downto 0);
    signal CFGMGMTREADWRITEDONE_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDDATA_outdelay : std_logic_vector(7 downto 0);
    signal CFGMSGRECEIVEDTYPE_outdelay : std_logic_vector(4 downto 0);
    signal CFGMSGRECEIVED_outdelay : std_ulogic;
    signal CFGMSGTRANSMITDONE_outdelay : std_ulogic;
    signal CFGNEGOTIATEDWIDTH_outdelay : std_logic_vector(3 downto 0);
    signal CFGOBFFENABLE_outdelay : std_logic_vector(1 downto 0);
    signal CFGPERFUNCSTATUSDATA_outdelay : std_logic_vector(15 downto 0);
    signal CFGPERFUNCTIONUPDATEDONE_outdelay : std_ulogic;
    signal CFGPHYLINKDOWN_outdelay : std_ulogic;
    signal CFGPHYLINKSTATUS_outdelay : std_logic_vector(1 downto 0);
    signal CFGPLSTATUSCHANGE_outdelay : std_ulogic;
    signal CFGPOWERSTATECHANGEINTERRUPT_outdelay : std_ulogic;
    signal CFGRCBSTATUS_outdelay : std_logic_vector(1 downto 0);
    signal CFGTPHFUNCTIONNUM_outdelay : std_logic_vector(2 downto 0);
    signal CFGTPHREQUESTERENABLE_outdelay : std_logic_vector(1 downto 0);
    signal CFGTPHSTMODE_outdelay : std_logic_vector(5 downto 0);
    signal CFGTPHSTTADDRESS_outdelay : std_logic_vector(4 downto 0);
    signal CFGTPHSTTREADENABLE_outdelay : std_ulogic;
    signal CFGTPHSTTWRITEBYTEVALID_outdelay : std_logic_vector(3 downto 0);
    signal CFGTPHSTTWRITEDATA_outdelay : std_logic_vector(31 downto 0);
    signal CFGTPHSTTWRITEENABLE_outdelay : std_ulogic;
    signal CFGVFFLRINPROCESS_outdelay : std_logic_vector(5 downto 0);
    signal CFGVFPOWERSTATE_outdelay : std_logic_vector(17 downto 0);
    signal CFGVFSTATUS_outdelay : std_logic_vector(11 downto 0);
    signal CFGVFTPHREQUESTERENABLE_outdelay : std_logic_vector(5 downto 0);
    signal CFGVFTPHSTMODE_outdelay : std_logic_vector(17 downto 0);
    signal DBGDATAOUT_outdelay : std_logic_vector(15 downto 0);
    signal DRPDO_outdelay : std_logic_vector(15 downto 0);
    signal DRPRDY_outdelay : std_ulogic;
    signal MAXISCQTDATA_outdelay : std_logic_vector(255 downto 0);
    signal MAXISCQTKEEP_outdelay : std_logic_vector(7 downto 0);
    signal MAXISCQTLAST_outdelay : std_ulogic;
    signal MAXISCQTUSER_outdelay : std_logic_vector(84 downto 0);
    signal MAXISCQTVALID_outdelay : std_ulogic;
    signal MAXISRCTDATA_outdelay : std_logic_vector(255 downto 0);
    signal MAXISRCTKEEP_outdelay : std_logic_vector(7 downto 0);
    signal MAXISRCTLAST_outdelay : std_ulogic;
    signal MAXISRCTUSER_outdelay : std_logic_vector(74 downto 0);
    signal MAXISRCTVALID_outdelay : std_ulogic;
    signal MICOMPLETIONRAMREADADDRESSAL_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADADDRESSAU_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADADDRESSBL_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADADDRESSBU_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMREADENABLEL_outdelay : std_logic_vector(3 downto 0);
    signal MICOMPLETIONRAMREADENABLEU_outdelay : std_logic_vector(3 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSAL_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSAU_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSBL_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEADDRESSBU_outdelay : std_logic_vector(9 downto 0);
    signal MICOMPLETIONRAMWRITEDATAL_outdelay : std_logic_vector(71 downto 0);
    signal MICOMPLETIONRAMWRITEDATAU_outdelay : std_logic_vector(71 downto 0);
    signal MICOMPLETIONRAMWRITEENABLEL_outdelay : std_logic_vector(3 downto 0);
    signal MICOMPLETIONRAMWRITEENABLEU_outdelay : std_logic_vector(3 downto 0);
    signal MIREPLAYRAMADDRESS_outdelay : std_logic_vector(8 downto 0);
    signal MIREPLAYRAMREADENABLE_outdelay : std_logic_vector(1 downto 0);
    signal MIREPLAYRAMWRITEDATA_outdelay : std_logic_vector(143 downto 0);
    signal MIREPLAYRAMWRITEENABLE_outdelay : std_logic_vector(1 downto 0);
    signal MIREQUESTRAMREADADDRESSA_outdelay : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMREADADDRESSB_outdelay : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMREADENABLE_outdelay : std_logic_vector(3 downto 0);
    signal MIREQUESTRAMWRITEADDRESSA_outdelay : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMWRITEADDRESSB_outdelay : std_logic_vector(8 downto 0);
    signal MIREQUESTRAMWRITEDATA_outdelay : std_logic_vector(143 downto 0);
    signal MIREQUESTRAMWRITEENABLE_outdelay : std_logic_vector(3 downto 0);
    signal PCIECQNPREQCOUNT_outdelay : std_logic_vector(5 downto 0);
    signal PCIERQSEQNUMVLD_outdelay : std_ulogic;
    signal PCIERQSEQNUM_outdelay : std_logic_vector(3 downto 0);
    signal PCIERQTAGAV_outdelay : std_logic_vector(1 downto 0);
    signal PCIERQTAGVLD_outdelay : std_ulogic;
    signal PCIERQTAG_outdelay : std_logic_vector(5 downto 0);
    signal PCIETFCNPDAV_outdelay : std_logic_vector(1 downto 0);
    signal PCIETFCNPHAV_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX0EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX0EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX0EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX0EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX0POLARITY_outdelay : std_ulogic;
    signal PIPERX1EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX1EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX1EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX1EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX1POLARITY_outdelay : std_ulogic;
    signal PIPERX2EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX2EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX2EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX2EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX2POLARITY_outdelay : std_ulogic;
    signal PIPERX3EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX3EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX3EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX3EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX3POLARITY_outdelay : std_ulogic;
    signal PIPERX4EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX4EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX4EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX4EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX4POLARITY_outdelay : std_ulogic;
    signal PIPERX5EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX5EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX5EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX5EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX5POLARITY_outdelay : std_ulogic;
    signal PIPERX6EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX6EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX6EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX6EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX6POLARITY_outdelay : std_ulogic;
    signal PIPERX7EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPERX7EQLPLFFS_outdelay : std_logic_vector(5 downto 0);
    signal PIPERX7EQLPTXPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPERX7EQPRESET_outdelay : std_logic_vector(2 downto 0);
    signal PIPERX7POLARITY_outdelay : std_ulogic;
    signal PIPETX0CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX0COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX0DATAVALID_outdelay : std_ulogic;
    signal PIPETX0DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX0ELECIDLE_outdelay : std_ulogic;
    signal PIPETX0EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX0EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX0EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX0POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX0STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX0SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX1CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX1COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX1DATAVALID_outdelay : std_ulogic;
    signal PIPETX1DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX1ELECIDLE_outdelay : std_ulogic;
    signal PIPETX1EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX1EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX1EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX1POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX1STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX1SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX2CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX2COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX2DATAVALID_outdelay : std_ulogic;
    signal PIPETX2DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX2ELECIDLE_outdelay : std_ulogic;
    signal PIPETX2EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX2EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX2EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX2POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX2STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX2SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX3CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX3COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX3DATAVALID_outdelay : std_ulogic;
    signal PIPETX3DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX3ELECIDLE_outdelay : std_ulogic;
    signal PIPETX3EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX3EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX3EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX3POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX3STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX3SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX4CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX4COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX4DATAVALID_outdelay : std_ulogic;
    signal PIPETX4DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX4ELECIDLE_outdelay : std_ulogic;
    signal PIPETX4EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX4EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX4EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX4POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX4STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX4SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX5CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX5COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX5DATAVALID_outdelay : std_ulogic;
    signal PIPETX5DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX5ELECIDLE_outdelay : std_ulogic;
    signal PIPETX5EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX5EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX5EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX5POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX5STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX5SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX6CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX6COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX6DATAVALID_outdelay : std_ulogic;
    signal PIPETX6DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX6ELECIDLE_outdelay : std_ulogic;
    signal PIPETX6EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX6EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX6EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX6POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX6STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX6SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX7CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX7COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX7DATAVALID_outdelay : std_ulogic;
    signal PIPETX7DATA_outdelay : std_logic_vector(31 downto 0);
    signal PIPETX7ELECIDLE_outdelay : std_ulogic;
    signal PIPETX7EQCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX7EQDEEMPH_outdelay : std_logic_vector(5 downto 0);
    signal PIPETX7EQPRESET_outdelay : std_logic_vector(3 downto 0);
    signal PIPETX7POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX7STARTBLOCK_outdelay : std_ulogic;
    signal PIPETX7SYNCHEADER_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXDEEMPH_outdelay : std_ulogic;
    signal PIPETXMARGIN_outdelay : std_logic_vector(2 downto 0);
    signal PIPETXRATE_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXRCVRDET_outdelay : std_ulogic;
    signal PIPETXRESET_outdelay : std_ulogic;
    signal PIPETXSWING_outdelay : std_ulogic;
    signal PLEQINPROGRESS_outdelay : std_ulogic;
    signal PLEQPHASE_outdelay : std_logic_vector(1 downto 0);
    signal PLGEN3PCSRXSLIDE_outdelay : std_logic_vector(7 downto 0);
    signal SAXISCCTREADY_outdelay : std_logic_vector(3 downto 0);
    signal SAXISRQTREADY_outdelay : std_logic_vector(3 downto 0);
    
    signal CFGCONFIGSPACEENABLE_ipd : std_ulogic;
    signal CFGDEVID_ipd : std_logic_vector(15 downto 0);
    signal CFGDSBUSNUMBER_ipd : std_logic_vector(7 downto 0);
    signal CFGDSDEVICENUMBER_ipd : std_logic_vector(4 downto 0);
    signal CFGDSFUNCTIONNUMBER_ipd : std_logic_vector(2 downto 0);
    signal CFGDSN_ipd : std_logic_vector(63 downto 0);
    signal CFGDSPORTNUMBER_ipd : std_logic_vector(7 downto 0);
    signal CFGERRCORIN_ipd : std_ulogic;
    signal CFGERRUNCORIN_ipd : std_ulogic;
    signal CFGEXTREADDATAVALID_ipd : std_ulogic;
    signal CFGEXTREADDATA_ipd : std_logic_vector(31 downto 0);
    signal CFGFCSEL_ipd : std_logic_vector(2 downto 0);
    signal CFGFLRDONE_ipd : std_logic_vector(1 downto 0);
    signal CFGHOTRESETIN_ipd : std_ulogic;
    signal CFGINPUTUPDATEREQUEST_ipd : std_ulogic;
    signal CFGINTERRUPTINT_ipd : std_logic_vector(3 downto 0);
    signal CFGINTERRUPTMSIATTR_ipd : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIFUNCTIONNUMBER_ipd : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIINT_ipd : std_logic_vector(31 downto 0);
    signal CFGINTERRUPTMSIPENDINGSTATUS_ipd : std_logic_vector(63 downto 0);
    signal CFGINTERRUPTMSISELECT_ipd : std_logic_vector(3 downto 0);
    signal CFGINTERRUPTMSITPHPRESENT_ipd : std_ulogic;
    signal CFGINTERRUPTMSITPHSTTAG_ipd : std_logic_vector(8 downto 0);
    signal CFGINTERRUPTMSITPHTYPE_ipd : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIXADDRESS_ipd : std_logic_vector(63 downto 0);
    signal CFGINTERRUPTMSIXDATA_ipd : std_logic_vector(31 downto 0);
    signal CFGINTERRUPTMSIXINT_ipd : std_ulogic;
    signal CFGINTERRUPTPENDING_ipd : std_logic_vector(1 downto 0);
    signal CFGLINKTRAININGENABLE_ipd : std_ulogic;
    signal CFGMCUPDATEREQUEST_ipd : std_ulogic;
    signal CFGMGMTADDR_ipd : std_logic_vector(18 downto 0);
    signal CFGMGMTBYTEENABLE_ipd : std_logic_vector(3 downto 0);
    signal CFGMGMTREAD_ipd : std_ulogic;
    signal CFGMGMTTYPE1CFGREGACCESS_ipd : std_ulogic;
    signal CFGMGMTWRITEDATA_ipd : std_logic_vector(31 downto 0);
    signal CFGMGMTWRITE_ipd : std_ulogic;
    signal CFGMSGTRANSMITDATA_ipd : std_logic_vector(31 downto 0);
    signal CFGMSGTRANSMITTYPE_ipd : std_logic_vector(2 downto 0);
    signal CFGMSGTRANSMIT_ipd : std_ulogic;
    signal CFGPERFUNCSTATUSCONTROL_ipd : std_logic_vector(2 downto 0);
    signal CFGPERFUNCTIONNUMBER_ipd : std_logic_vector(2 downto 0);
    signal CFGPERFUNCTIONOUTPUTREQUEST_ipd : std_ulogic;
    signal CFGPOWERSTATECHANGEACK_ipd : std_ulogic;
    signal CFGREQPMTRANSITIONL23READY_ipd : std_ulogic;
    signal CFGREVID_ipd : std_logic_vector(7 downto 0);
    signal CFGSUBSYSID_ipd : std_logic_vector(15 downto 0);
    signal CFGSUBSYSVENDID_ipd : std_logic_vector(15 downto 0);
    signal CFGTPHSTTREADDATAVALID_ipd : std_ulogic;
    signal CFGTPHSTTREADDATA_ipd : std_logic_vector(31 downto 0);
    signal CFGVENDID_ipd : std_logic_vector(15 downto 0);
    signal CFGVFFLRDONE_ipd : std_logic_vector(5 downto 0);
    signal CORECLKMICOMPLETIONRAML_ipd : std_ulogic;
    signal CORECLKMICOMPLETIONRAMU_ipd : std_ulogic;
    signal CORECLKMIREPLAYRAM_ipd : std_ulogic;
    signal CORECLKMIREQUESTRAM_ipd : std_ulogic;
    signal CORECLK_ipd : std_ulogic;
    signal DRPADDR_ipd : std_logic_vector(10 downto 0);
    signal DRPCLK_ipd : std_ulogic;
    signal DRPDI_ipd : std_logic_vector(15 downto 0);
    signal DRPEN_ipd : std_ulogic;
    signal DRPWE_ipd : std_ulogic;
    signal MAXISCQTREADY_ipd : std_logic_vector(21 downto 0);
    signal MAXISRCTREADY_ipd : std_logic_vector(21 downto 0);
    signal MGMTRESETN_ipd : std_ulogic;
    signal MGMTSTICKYRESETN_ipd : std_ulogic;
    signal MICOMPLETIONRAMREADDATA_ipd : std_logic_vector(143 downto 0);
    signal MIREPLAYRAMREADDATA_ipd : std_logic_vector(143 downto 0);
    signal MIREQUESTRAMREADDATA_ipd : std_logic_vector(143 downto 0);
    signal PCIECQNPREQ_ipd : std_ulogic;
    signal PIPECLK_ipd : std_ulogic;
    signal PIPEEQFS_ipd : std_logic_vector(5 downto 0);
    signal PIPEEQLF_ipd : std_logic_vector(5 downto 0);
    signal PIPERESETN_ipd : std_ulogic;
    signal PIPERX0CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX0DATAVALID_ipd : std_ulogic;
    signal PIPERX0DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX0ELECIDLE_ipd : std_ulogic;
    signal PIPERX0EQDONE_ipd : std_ulogic;
    signal PIPERX0EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX0EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX0EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX0PHYSTATUS_ipd : std_ulogic;
    signal PIPERX0STARTBLOCK_ipd : std_ulogic;
    signal PIPERX0STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX0SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX0VALID_ipd : std_ulogic;
    signal PIPERX1CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX1DATAVALID_ipd : std_ulogic;
    signal PIPERX1DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX1ELECIDLE_ipd : std_ulogic;
    signal PIPERX1EQDONE_ipd : std_ulogic;
    signal PIPERX1EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX1EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX1EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX1PHYSTATUS_ipd : std_ulogic;
    signal PIPERX1STARTBLOCK_ipd : std_ulogic;
    signal PIPERX1STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX1SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX1VALID_ipd : std_ulogic;
    signal PIPERX2CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX2DATAVALID_ipd : std_ulogic;
    signal PIPERX2DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX2ELECIDLE_ipd : std_ulogic;
    signal PIPERX2EQDONE_ipd : std_ulogic;
    signal PIPERX2EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX2EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX2EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX2PHYSTATUS_ipd : std_ulogic;
    signal PIPERX2STARTBLOCK_ipd : std_ulogic;
    signal PIPERX2STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX2SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX2VALID_ipd : std_ulogic;
    signal PIPERX3CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX3DATAVALID_ipd : std_ulogic;
    signal PIPERX3DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX3ELECIDLE_ipd : std_ulogic;
    signal PIPERX3EQDONE_ipd : std_ulogic;
    signal PIPERX3EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX3EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX3EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX3PHYSTATUS_ipd : std_ulogic;
    signal PIPERX3STARTBLOCK_ipd : std_ulogic;
    signal PIPERX3STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX3SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX3VALID_ipd : std_ulogic;
    signal PIPERX4CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX4DATAVALID_ipd : std_ulogic;
    signal PIPERX4DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX4ELECIDLE_ipd : std_ulogic;
    signal PIPERX4EQDONE_ipd : std_ulogic;
    signal PIPERX4EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX4EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX4EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX4PHYSTATUS_ipd : std_ulogic;
    signal PIPERX4STARTBLOCK_ipd : std_ulogic;
    signal PIPERX4STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX4SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX4VALID_ipd : std_ulogic;
    signal PIPERX5CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX5DATAVALID_ipd : std_ulogic;
    signal PIPERX5DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX5ELECIDLE_ipd : std_ulogic;
    signal PIPERX5EQDONE_ipd : std_ulogic;
    signal PIPERX5EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX5EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX5EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX5PHYSTATUS_ipd : std_ulogic;
    signal PIPERX5STARTBLOCK_ipd : std_ulogic;
    signal PIPERX5STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX5SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX5VALID_ipd : std_ulogic;
    signal PIPERX6CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX6DATAVALID_ipd : std_ulogic;
    signal PIPERX6DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX6ELECIDLE_ipd : std_ulogic;
    signal PIPERX6EQDONE_ipd : std_ulogic;
    signal PIPERX6EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX6EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX6EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX6PHYSTATUS_ipd : std_ulogic;
    signal PIPERX6STARTBLOCK_ipd : std_ulogic;
    signal PIPERX6STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX6SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX6VALID_ipd : std_ulogic;
    signal PIPERX7CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX7DATAVALID_ipd : std_ulogic;
    signal PIPERX7DATA_ipd : std_logic_vector(31 downto 0);
    signal PIPERX7ELECIDLE_ipd : std_ulogic;
    signal PIPERX7EQDONE_ipd : std_ulogic;
    signal PIPERX7EQLPADAPTDONE_ipd : std_ulogic;
    signal PIPERX7EQLPLFFSSEL_ipd : std_ulogic;
    signal PIPERX7EQLPNEWTXCOEFFORPRESET_ipd : std_logic_vector(17 downto 0);
    signal PIPERX7PHYSTATUS_ipd : std_ulogic;
    signal PIPERX7STARTBLOCK_ipd : std_ulogic;
    signal PIPERX7STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX7SYNCHEADER_ipd : std_logic_vector(1 downto 0);
    signal PIPERX7VALID_ipd : std_ulogic;
    signal PIPETX0EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX0EQDONE_ipd : std_ulogic;
    signal PIPETX1EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX1EQDONE_ipd : std_ulogic;
    signal PIPETX2EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX2EQDONE_ipd : std_ulogic;
    signal PIPETX3EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX3EQDONE_ipd : std_ulogic;
    signal PIPETX4EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX4EQDONE_ipd : std_ulogic;
    signal PIPETX5EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX5EQDONE_ipd : std_ulogic;
    signal PIPETX6EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX6EQDONE_ipd : std_ulogic;
    signal PIPETX7EQCOEFF_ipd : std_logic_vector(17 downto 0);
    signal PIPETX7EQDONE_ipd : std_ulogic;
    signal PLDISABLESCRAMBLER_ipd : std_ulogic;
    signal PLEQRESETEIEOSCOUNT_ipd : std_ulogic;
    signal PLGEN3PCSDISABLE_ipd : std_ulogic;
    signal PLGEN3PCSRXSYNCDONE_ipd : std_logic_vector(7 downto 0);
    signal RECCLK_ipd : std_ulogic;
    signal RESETN_ipd : std_ulogic;
    signal SAXISCCTDATA_ipd : std_logic_vector(255 downto 0);
    signal SAXISCCTKEEP_ipd : std_logic_vector(7 downto 0);
    signal SAXISCCTLAST_ipd : std_ulogic;
    signal SAXISCCTUSER_ipd : std_logic_vector(32 downto 0);
    signal SAXISCCTVALID_ipd : std_ulogic;
    signal SAXISRQTDATA_ipd : std_logic_vector(255 downto 0);
    signal SAXISRQTKEEP_ipd : std_logic_vector(7 downto 0);
    signal SAXISRQTLAST_ipd : std_ulogic;
    signal SAXISRQTUSER_ipd : std_logic_vector(59 downto 0);
    signal SAXISRQTVALID_ipd : std_ulogic;
    signal USERCLK_ipd : std_ulogic;
    
    signal CFGCONFIGSPACEENABLE_indelay : std_ulogic;
    signal CFGDEVID_indelay : std_logic_vector(15 downto 0);
    signal CFGDSBUSNUMBER_indelay : std_logic_vector(7 downto 0);
    signal CFGDSDEVICENUMBER_indelay : std_logic_vector(4 downto 0);
    signal CFGDSFUNCTIONNUMBER_indelay : std_logic_vector(2 downto 0);
    signal CFGDSN_indelay : std_logic_vector(63 downto 0);
    signal CFGDSPORTNUMBER_indelay : std_logic_vector(7 downto 0);
    signal CFGERRCORIN_indelay : std_ulogic;
    signal CFGERRUNCORIN_indelay : std_ulogic;
    signal CFGEXTREADDATAVALID_indelay : std_ulogic;
    signal CFGEXTREADDATA_indelay : std_logic_vector(31 downto 0);
    signal CFGFCSEL_indelay : std_logic_vector(2 downto 0);
    signal CFGFLRDONE_indelay : std_logic_vector(1 downto 0);
    signal CFGHOTRESETIN_indelay : std_ulogic;
    signal CFGINPUTUPDATEREQUEST_indelay : std_ulogic;
    signal CFGINTERRUPTINT_indelay : std_logic_vector(3 downto 0);
    signal CFGINTERRUPTMSIATTR_indelay : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIFUNCTIONNUMBER_indelay : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIINT_indelay : std_logic_vector(31 downto 0);
    signal CFGINTERRUPTMSIPENDINGSTATUS_indelay : std_logic_vector(63 downto 0);
    signal CFGINTERRUPTMSISELECT_indelay : std_logic_vector(3 downto 0);
    signal CFGINTERRUPTMSITPHPRESENT_indelay : std_ulogic;
    signal CFGINTERRUPTMSITPHSTTAG_indelay : std_logic_vector(8 downto 0);
    signal CFGINTERRUPTMSITPHTYPE_indelay : std_logic_vector(1 downto 0);
    signal CFGINTERRUPTMSIXADDRESS_indelay : std_logic_vector(63 downto 0);
    signal CFGINTERRUPTMSIXDATA_indelay : std_logic_vector(31 downto 0);
    signal CFGINTERRUPTMSIXINT_indelay : std_ulogic;
    signal CFGINTERRUPTPENDING_indelay : std_logic_vector(1 downto 0);
    signal CFGLINKTRAININGENABLE_indelay : std_ulogic;
    signal CFGMCUPDATEREQUEST_indelay : std_ulogic;
    signal CFGMGMTADDR_indelay : std_logic_vector(18 downto 0);
    signal CFGMGMTBYTEENABLE_indelay : std_logic_vector(3 downto 0);
    signal CFGMGMTREAD_indelay : std_ulogic;
    signal CFGMGMTTYPE1CFGREGACCESS_indelay : std_ulogic;
    signal CFGMGMTWRITEDATA_indelay : std_logic_vector(31 downto 0);
    signal CFGMGMTWRITE_indelay : std_ulogic;
    signal CFGMSGTRANSMITDATA_indelay : std_logic_vector(31 downto 0);
    signal CFGMSGTRANSMITTYPE_indelay : std_logic_vector(2 downto 0);
    signal CFGMSGTRANSMIT_indelay : std_ulogic;
    signal CFGPERFUNCSTATUSCONTROL_indelay : std_logic_vector(2 downto 0);
    signal CFGPERFUNCTIONNUMBER_indelay : std_logic_vector(2 downto 0);
    signal CFGPERFUNCTIONOUTPUTREQUEST_indelay : std_ulogic;
    signal CFGPOWERSTATECHANGEACK_indelay : std_ulogic;
    signal CFGREQPMTRANSITIONL23READY_indelay : std_ulogic;
    signal CFGREVID_indelay : std_logic_vector(7 downto 0);
    signal CFGSUBSYSID_indelay : std_logic_vector(15 downto 0);
    signal CFGSUBSYSVENDID_indelay : std_logic_vector(15 downto 0);
    signal CFGTPHSTTREADDATAVALID_indelay : std_ulogic;
    signal CFGTPHSTTREADDATA_indelay : std_logic_vector(31 downto 0);
    signal CFGVENDID_indelay : std_logic_vector(15 downto 0);
    signal CFGVFFLRDONE_indelay : std_logic_vector(5 downto 0);
    signal CORECLKMICOMPLETIONRAML_indelay : std_ulogic;
    signal CORECLKMICOMPLETIONRAMU_indelay : std_ulogic;
    signal CORECLKMIREPLAYRAM_indelay : std_ulogic;
    signal CORECLKMIREQUESTRAM_indelay : std_ulogic;
    signal CORECLK_indelay : std_ulogic;
    signal DRPADDR_indelay : std_logic_vector(10 downto 0);
    signal DRPCLK_indelay : std_ulogic;
    signal DRPDI_indelay : std_logic_vector(15 downto 0);
    signal DRPEN_indelay : std_ulogic;
    signal DRPWE_indelay : std_ulogic;
    signal MAXISCQTREADY_indelay : std_logic_vector(21 downto 0);
    signal MAXISRCTREADY_indelay : std_logic_vector(21 downto 0);
    signal MGMTRESETN_indelay : std_ulogic;
    signal MGMTSTICKYRESETN_indelay : std_ulogic;
    signal MICOMPLETIONRAMREADDATA_indelay : std_logic_vector(143 downto 0);
    signal MIREPLAYRAMREADDATA_indelay : std_logic_vector(143 downto 0);
    signal MIREQUESTRAMREADDATA_indelay : std_logic_vector(143 downto 0);
    signal PCIECQNPREQ_indelay : std_ulogic;
    signal PIPECLK_indelay : std_ulogic;
    signal PIPEEQFS_indelay : std_logic_vector(5 downto 0);
    signal PIPEEQLF_indelay : std_logic_vector(5 downto 0);
    signal PIPERESETN_indelay : std_ulogic;
    signal PIPERX0CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX0DATAVALID_indelay : std_ulogic;
    signal PIPERX0DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX0ELECIDLE_indelay : std_ulogic;
    signal PIPERX0EQDONE_indelay : std_ulogic;
    signal PIPERX0EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX0EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX0EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX0PHYSTATUS_indelay : std_ulogic;
    signal PIPERX0STARTBLOCK_indelay : std_ulogic;
    signal PIPERX0STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX0SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX0VALID_indelay : std_ulogic;
    signal PIPERX1CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX1DATAVALID_indelay : std_ulogic;
    signal PIPERX1DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX1ELECIDLE_indelay : std_ulogic;
    signal PIPERX1EQDONE_indelay : std_ulogic;
    signal PIPERX1EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX1EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX1EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX1PHYSTATUS_indelay : std_ulogic;
    signal PIPERX1STARTBLOCK_indelay : std_ulogic;
    signal PIPERX1STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX1SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX1VALID_indelay : std_ulogic;
    signal PIPERX2CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX2DATAVALID_indelay : std_ulogic;
    signal PIPERX2DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX2ELECIDLE_indelay : std_ulogic;
    signal PIPERX2EQDONE_indelay : std_ulogic;
    signal PIPERX2EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX2EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX2EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX2PHYSTATUS_indelay : std_ulogic;
    signal PIPERX2STARTBLOCK_indelay : std_ulogic;
    signal PIPERX2STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX2SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX2VALID_indelay : std_ulogic;
    signal PIPERX3CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX3DATAVALID_indelay : std_ulogic;
    signal PIPERX3DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX3ELECIDLE_indelay : std_ulogic;
    signal PIPERX3EQDONE_indelay : std_ulogic;
    signal PIPERX3EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX3EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX3EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX3PHYSTATUS_indelay : std_ulogic;
    signal PIPERX3STARTBLOCK_indelay : std_ulogic;
    signal PIPERX3STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX3SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX3VALID_indelay : std_ulogic;
    signal PIPERX4CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX4DATAVALID_indelay : std_ulogic;
    signal PIPERX4DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX4ELECIDLE_indelay : std_ulogic;
    signal PIPERX4EQDONE_indelay : std_ulogic;
    signal PIPERX4EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX4EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX4EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX4PHYSTATUS_indelay : std_ulogic;
    signal PIPERX4STARTBLOCK_indelay : std_ulogic;
    signal PIPERX4STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX4SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX4VALID_indelay : std_ulogic;
    signal PIPERX5CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX5DATAVALID_indelay : std_ulogic;
    signal PIPERX5DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX5ELECIDLE_indelay : std_ulogic;
    signal PIPERX5EQDONE_indelay : std_ulogic;
    signal PIPERX5EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX5EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX5EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX5PHYSTATUS_indelay : std_ulogic;
    signal PIPERX5STARTBLOCK_indelay : std_ulogic;
    signal PIPERX5STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX5SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX5VALID_indelay : std_ulogic;
    signal PIPERX6CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX6DATAVALID_indelay : std_ulogic;
    signal PIPERX6DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX6ELECIDLE_indelay : std_ulogic;
    signal PIPERX6EQDONE_indelay : std_ulogic;
    signal PIPERX6EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX6EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX6EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX6PHYSTATUS_indelay : std_ulogic;
    signal PIPERX6STARTBLOCK_indelay : std_ulogic;
    signal PIPERX6STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX6SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX6VALID_indelay : std_ulogic;
    signal PIPERX7CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX7DATAVALID_indelay : std_ulogic;
    signal PIPERX7DATA_indelay : std_logic_vector(31 downto 0);
    signal PIPERX7ELECIDLE_indelay : std_ulogic;
    signal PIPERX7EQDONE_indelay : std_ulogic;
    signal PIPERX7EQLPADAPTDONE_indelay : std_ulogic;
    signal PIPERX7EQLPLFFSSEL_indelay : std_ulogic;
    signal PIPERX7EQLPNEWTXCOEFFORPRESET_indelay : std_logic_vector(17 downto 0);
    signal PIPERX7PHYSTATUS_indelay : std_ulogic;
    signal PIPERX7STARTBLOCK_indelay : std_ulogic;
    signal PIPERX7STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX7SYNCHEADER_indelay : std_logic_vector(1 downto 0);
    signal PIPERX7VALID_indelay : std_ulogic;
    signal PIPETX0EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX0EQDONE_indelay : std_ulogic;
    signal PIPETX1EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX1EQDONE_indelay : std_ulogic;
    signal PIPETX2EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX2EQDONE_indelay : std_ulogic;
    signal PIPETX3EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX3EQDONE_indelay : std_ulogic;
    signal PIPETX4EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX4EQDONE_indelay : std_ulogic;
    signal PIPETX5EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX5EQDONE_indelay : std_ulogic;
    signal PIPETX6EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX6EQDONE_indelay : std_ulogic;
    signal PIPETX7EQCOEFF_indelay : std_logic_vector(17 downto 0);
    signal PIPETX7EQDONE_indelay : std_ulogic;
    signal PLDISABLESCRAMBLER_indelay : std_ulogic;
    signal PLEQRESETEIEOSCOUNT_indelay : std_ulogic;
    signal PLGEN3PCSDISABLE_indelay : std_ulogic;
    signal PLGEN3PCSRXSYNCDONE_indelay : std_logic_vector(7 downto 0);
    signal RECCLK_indelay : std_ulogic;
    signal RESETN_indelay : std_ulogic;
    signal SAXISCCTDATA_indelay : std_logic_vector(255 downto 0);
    signal SAXISCCTKEEP_indelay : std_logic_vector(7 downto 0);
    signal SAXISCCTLAST_indelay : std_ulogic;
    signal SAXISCCTUSER_indelay : std_logic_vector(32 downto 0);
    signal SAXISCCTVALID_indelay : std_ulogic;
    signal SAXISRQTDATA_indelay : std_logic_vector(255 downto 0);
    signal SAXISRQTKEEP_indelay : std_logic_vector(7 downto 0);
    signal SAXISRQTLAST_indelay : std_ulogic;
    signal SAXISRQTUSER_indelay : std_logic_vector(59 downto 0);
    signal SAXISRQTVALID_indelay : std_ulogic;
    signal USERCLK_indelay : std_ulogic;
    
    begin
    CFGCURRENTSPEED_out <= CFGCURRENTSPEED_outdelay after OUT_DELAY;
    CFGDPASUBSTATECHANGE_out <= CFGDPASUBSTATECHANGE_outdelay after OUT_DELAY;
    CFGERRCOROUT_out <= CFGERRCOROUT_outdelay after OUT_DELAY;
    CFGERRFATALOUT_out <= CFGERRFATALOUT_outdelay after OUT_DELAY;
    CFGERRNONFATALOUT_out <= CFGERRNONFATALOUT_outdelay after OUT_DELAY;
    CFGEXTFUNCTIONNUMBER_out <= CFGEXTFUNCTIONNUMBER_outdelay after OUT_DELAY;
    CFGEXTREADRECEIVED_out <= CFGEXTREADRECEIVED_outdelay after OUT_DELAY;
    CFGEXTREGISTERNUMBER_out <= CFGEXTREGISTERNUMBER_outdelay after OUT_DELAY;
    CFGEXTWRITEBYTEENABLE_out <= CFGEXTWRITEBYTEENABLE_outdelay after OUT_DELAY;
    CFGEXTWRITEDATA_out <= CFGEXTWRITEDATA_outdelay after OUT_DELAY;
    CFGEXTWRITERECEIVED_out <= CFGEXTWRITERECEIVED_outdelay after OUT_DELAY;
    CFGFCCPLD_out <= CFGFCCPLD_outdelay after OUT_DELAY;
    CFGFCCPLH_out <= CFGFCCPLH_outdelay after OUT_DELAY;
    CFGFCNPD_out <= CFGFCNPD_outdelay after OUT_DELAY;
    CFGFCNPH_out <= CFGFCNPH_outdelay after OUT_DELAY;
    CFGFCPD_out <= CFGFCPD_outdelay after OUT_DELAY;
    CFGFCPH_out <= CFGFCPH_outdelay after OUT_DELAY;
    CFGFLRINPROCESS_out <= CFGFLRINPROCESS_outdelay after OUT_DELAY;
    CFGFUNCTIONPOWERSTATE_out <= CFGFUNCTIONPOWERSTATE_outdelay after OUT_DELAY;
    CFGFUNCTIONSTATUS_out <= CFGFUNCTIONSTATUS_outdelay after OUT_DELAY;
    CFGHOTRESETOUT_out <= CFGHOTRESETOUT_outdelay after OUT_DELAY;
    CFGINPUTUPDATEDONE_out <= CFGINPUTUPDATEDONE_outdelay after OUT_DELAY;
    CFGINTERRUPTAOUTPUT_out <= CFGINTERRUPTAOUTPUT_outdelay after OUT_DELAY;
    CFGINTERRUPTBOUTPUT_out <= CFGINTERRUPTBOUTPUT_outdelay after OUT_DELAY;
    CFGINTERRUPTCOUTPUT_out <= CFGINTERRUPTCOUTPUT_outdelay after OUT_DELAY;
    CFGINTERRUPTDOUTPUT_out <= CFGINTERRUPTDOUTPUT_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIDATA_out <= CFGINTERRUPTMSIDATA_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIENABLE_out <= CFGINTERRUPTMSIENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIFAIL_out <= CFGINTERRUPTMSIFAIL_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIMASKUPDATE_out <= CFGINTERRUPTMSIMASKUPDATE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIMMENABLE_out <= CFGINTERRUPTMSIMMENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSISENT_out <= CFGINTERRUPTMSISENT_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIVFENABLE_out <= CFGINTERRUPTMSIVFENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXENABLE_out <= CFGINTERRUPTMSIXENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXFAIL_out <= CFGINTERRUPTMSIXFAIL_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXMASK_out <= CFGINTERRUPTMSIXMASK_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXSENT_out <= CFGINTERRUPTMSIXSENT_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXVFENABLE_out <= CFGINTERRUPTMSIXVFENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXVFMASK_out <= CFGINTERRUPTMSIXVFMASK_outdelay after OUT_DELAY;
    CFGINTERRUPTSENT_out <= CFGINTERRUPTSENT_outdelay after OUT_DELAY;
    CFGLINKPOWERSTATE_out <= CFGLINKPOWERSTATE_outdelay after OUT_DELAY;
    CFGLOCALERROR_out <= CFGLOCALERROR_outdelay after OUT_DELAY;
    CFGLTRENABLE_out <= CFGLTRENABLE_outdelay after OUT_DELAY;
    CFGLTSSMSTATE_out <= CFGLTSSMSTATE_outdelay after OUT_DELAY;
    CFGMAXPAYLOAD_out <= CFGMAXPAYLOAD_outdelay after OUT_DELAY;
    CFGMAXREADREQ_out <= CFGMAXREADREQ_outdelay after OUT_DELAY;
    CFGMCUPDATEDONE_out <= CFGMCUPDATEDONE_outdelay after OUT_DELAY;
    CFGMGMTREADDATA_out <= CFGMGMTREADDATA_outdelay after OUT_DELAY;
    CFGMGMTREADWRITEDONE_out <= CFGMGMTREADWRITEDONE_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDDATA_out <= CFGMSGRECEIVEDDATA_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDTYPE_out <= CFGMSGRECEIVEDTYPE_outdelay after OUT_DELAY;
    CFGMSGRECEIVED_out <= CFGMSGRECEIVED_outdelay after OUT_DELAY;
    CFGMSGTRANSMITDONE_out <= CFGMSGTRANSMITDONE_outdelay after OUT_DELAY;
    CFGNEGOTIATEDWIDTH_out <= CFGNEGOTIATEDWIDTH_outdelay after OUT_DELAY;
    CFGOBFFENABLE_out <= CFGOBFFENABLE_outdelay after OUT_DELAY;
    CFGPERFUNCSTATUSDATA_out <= CFGPERFUNCSTATUSDATA_outdelay after OUT_DELAY;
    CFGPERFUNCTIONUPDATEDONE_out <= CFGPERFUNCTIONUPDATEDONE_outdelay after OUT_DELAY;
    CFGPHYLINKDOWN_out <= CFGPHYLINKDOWN_outdelay after OUT_DELAY;
    CFGPHYLINKSTATUS_out <= CFGPHYLINKSTATUS_outdelay after OUT_DELAY;
    CFGPLSTATUSCHANGE_out <= CFGPLSTATUSCHANGE_outdelay after OUT_DELAY;
    CFGPOWERSTATECHANGEINTERRUPT_out <= CFGPOWERSTATECHANGEINTERRUPT_outdelay after OUT_DELAY;
    CFGRCBSTATUS_out <= CFGRCBSTATUS_outdelay after OUT_DELAY;
    CFGTPHFUNCTIONNUM_out <= CFGTPHFUNCTIONNUM_outdelay after OUT_DELAY;
    CFGTPHREQUESTERENABLE_out <= CFGTPHREQUESTERENABLE_outdelay after OUT_DELAY;
    CFGTPHSTMODE_out <= CFGTPHSTMODE_outdelay after OUT_DELAY;
    CFGTPHSTTADDRESS_out <= CFGTPHSTTADDRESS_outdelay after OUT_DELAY;
    CFGTPHSTTREADENABLE_out <= CFGTPHSTTREADENABLE_outdelay after OUT_DELAY;
    CFGTPHSTTWRITEBYTEVALID_out <= CFGTPHSTTWRITEBYTEVALID_outdelay after OUT_DELAY;
    CFGTPHSTTWRITEDATA_out <= CFGTPHSTTWRITEDATA_outdelay after OUT_DELAY;
    CFGTPHSTTWRITEENABLE_out <= CFGTPHSTTWRITEENABLE_outdelay after OUT_DELAY;
    CFGVFFLRINPROCESS_out <= CFGVFFLRINPROCESS_outdelay after OUT_DELAY;
    CFGVFPOWERSTATE_out <= CFGVFPOWERSTATE_outdelay after OUT_DELAY;
    CFGVFSTATUS_out <= CFGVFSTATUS_outdelay after OUT_DELAY;
    CFGVFTPHREQUESTERENABLE_out <= CFGVFTPHREQUESTERENABLE_outdelay after OUT_DELAY;
    CFGVFTPHSTMODE_out <= CFGVFTPHSTMODE_outdelay after OUT_DELAY;
    DBGDATAOUT_out <= DBGDATAOUT_outdelay after OUT_DELAY;
    DRPDO_out <= DRPDO_outdelay after OUT_DELAY;
    DRPRDY_out <= DRPRDY_outdelay after OUT_DELAY;
    MAXISCQTDATA_out <= MAXISCQTDATA_outdelay after OUT_DELAY;
    MAXISCQTKEEP_out <= MAXISCQTKEEP_outdelay after OUT_DELAY;
    MAXISCQTLAST_out <= MAXISCQTLAST_outdelay after OUT_DELAY;
    MAXISCQTUSER_out <= MAXISCQTUSER_outdelay after OUT_DELAY;
    MAXISCQTVALID_out <= MAXISCQTVALID_outdelay after OUT_DELAY;
    MAXISRCTDATA_out <= MAXISRCTDATA_outdelay after OUT_DELAY;
    MAXISRCTKEEP_out <= MAXISRCTKEEP_outdelay after OUT_DELAY;
    MAXISRCTLAST_out <= MAXISRCTLAST_outdelay after OUT_DELAY;
    MAXISRCTUSER_out <= MAXISRCTUSER_outdelay after OUT_DELAY;
    MAXISRCTVALID_out <= MAXISRCTVALID_outdelay after OUT_DELAY;
    MICOMPLETIONRAMREADADDRESSAL_out <= MICOMPLETIONRAMREADADDRESSAL_outdelay after OUT_DELAY;
    MICOMPLETIONRAMREADADDRESSAU_out <= MICOMPLETIONRAMREADADDRESSAU_outdelay after OUT_DELAY;
    MICOMPLETIONRAMREADADDRESSBL_out <= MICOMPLETIONRAMREADADDRESSBL_outdelay after OUT_DELAY;
    MICOMPLETIONRAMREADADDRESSBU_out <= MICOMPLETIONRAMREADADDRESSBU_outdelay after OUT_DELAY;
    MICOMPLETIONRAMREADENABLEL_out <= MICOMPLETIONRAMREADENABLEL_outdelay after OUT_DELAY;
    MICOMPLETIONRAMREADENABLEU_out <= MICOMPLETIONRAMREADENABLEU_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEADDRESSAL_out <= MICOMPLETIONRAMWRITEADDRESSAL_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEADDRESSAU_out <= MICOMPLETIONRAMWRITEADDRESSAU_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEADDRESSBL_out <= MICOMPLETIONRAMWRITEADDRESSBL_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEADDRESSBU_out <= MICOMPLETIONRAMWRITEADDRESSBU_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEDATAL_out <= MICOMPLETIONRAMWRITEDATAL_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEDATAU_out <= MICOMPLETIONRAMWRITEDATAU_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEENABLEL_out <= MICOMPLETIONRAMWRITEENABLEL_outdelay after OUT_DELAY;
    MICOMPLETIONRAMWRITEENABLEU_out <= MICOMPLETIONRAMWRITEENABLEU_outdelay after OUT_DELAY;
    MIREPLAYRAMADDRESS_out <= MIREPLAYRAMADDRESS_outdelay after OUT_DELAY;
    MIREPLAYRAMREADENABLE_out <= MIREPLAYRAMREADENABLE_outdelay after OUT_DELAY;
    MIREPLAYRAMWRITEDATA_out <= MIREPLAYRAMWRITEDATA_outdelay after OUT_DELAY;
    MIREPLAYRAMWRITEENABLE_out <= MIREPLAYRAMWRITEENABLE_outdelay after OUT_DELAY;
    MIREQUESTRAMREADADDRESSA_out <= MIREQUESTRAMREADADDRESSA_outdelay after OUT_DELAY;
    MIREQUESTRAMREADADDRESSB_out <= MIREQUESTRAMREADADDRESSB_outdelay after OUT_DELAY;
    MIREQUESTRAMREADENABLE_out <= MIREQUESTRAMREADENABLE_outdelay after OUT_DELAY;
    MIREQUESTRAMWRITEADDRESSA_out <= MIREQUESTRAMWRITEADDRESSA_outdelay after OUT_DELAY;
    MIREQUESTRAMWRITEADDRESSB_out <= MIREQUESTRAMWRITEADDRESSB_outdelay after OUT_DELAY;
    MIREQUESTRAMWRITEDATA_out <= MIREQUESTRAMWRITEDATA_outdelay after OUT_DELAY;
    MIREQUESTRAMWRITEENABLE_out <= MIREQUESTRAMWRITEENABLE_outdelay after OUT_DELAY;
    PCIECQNPREQCOUNT_out <= PCIECQNPREQCOUNT_outdelay after OUT_DELAY;
    PCIERQSEQNUMVLD_out <= PCIERQSEQNUMVLD_outdelay after OUT_DELAY;
    PCIERQSEQNUM_out <= PCIERQSEQNUM_outdelay after OUT_DELAY;
    PCIERQTAGAV_out <= PCIERQTAGAV_outdelay after OUT_DELAY;
    PCIERQTAGVLD_out <= PCIERQTAGVLD_outdelay after OUT_DELAY;
    PCIERQTAG_out <= PCIERQTAG_outdelay after OUT_DELAY;
    PCIETFCNPDAV_out <= PCIETFCNPDAV_outdelay after OUT_DELAY;
    PCIETFCNPHAV_out <= PCIETFCNPHAV_outdelay after OUT_DELAY;
    PIPERX0EQCONTROL_out <= PIPERX0EQCONTROL_outdelay after OUT_DELAY;
    PIPERX0EQLPLFFS_out <= PIPERX0EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX0EQLPTXPRESET_out <= PIPERX0EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX0EQPRESET_out <= PIPERX0EQPRESET_outdelay after OUT_DELAY;
    PIPERX0POLARITY_out <= PIPERX0POLARITY_outdelay after OUT_DELAY;
    PIPERX1EQCONTROL_out <= PIPERX1EQCONTROL_outdelay after OUT_DELAY;
    PIPERX1EQLPLFFS_out <= PIPERX1EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX1EQLPTXPRESET_out <= PIPERX1EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX1EQPRESET_out <= PIPERX1EQPRESET_outdelay after OUT_DELAY;
    PIPERX1POLARITY_out <= PIPERX1POLARITY_outdelay after OUT_DELAY;
    PIPERX2EQCONTROL_out <= PIPERX2EQCONTROL_outdelay after OUT_DELAY;
    PIPERX2EQLPLFFS_out <= PIPERX2EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX2EQLPTXPRESET_out <= PIPERX2EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX2EQPRESET_out <= PIPERX2EQPRESET_outdelay after OUT_DELAY;
    PIPERX2POLARITY_out <= PIPERX2POLARITY_outdelay after OUT_DELAY;
    PIPERX3EQCONTROL_out <= PIPERX3EQCONTROL_outdelay after OUT_DELAY;
    PIPERX3EQLPLFFS_out <= PIPERX3EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX3EQLPTXPRESET_out <= PIPERX3EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX3EQPRESET_out <= PIPERX3EQPRESET_outdelay after OUT_DELAY;
    PIPERX3POLARITY_out <= PIPERX3POLARITY_outdelay after OUT_DELAY;
    PIPERX4EQCONTROL_out <= PIPERX4EQCONTROL_outdelay after OUT_DELAY;
    PIPERX4EQLPLFFS_out <= PIPERX4EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX4EQLPTXPRESET_out <= PIPERX4EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX4EQPRESET_out <= PIPERX4EQPRESET_outdelay after OUT_DELAY;
    PIPERX4POLARITY_out <= PIPERX4POLARITY_outdelay after OUT_DELAY;
    PIPERX5EQCONTROL_out <= PIPERX5EQCONTROL_outdelay after OUT_DELAY;
    PIPERX5EQLPLFFS_out <= PIPERX5EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX5EQLPTXPRESET_out <= PIPERX5EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX5EQPRESET_out <= PIPERX5EQPRESET_outdelay after OUT_DELAY;
    PIPERX5POLARITY_out <= PIPERX5POLARITY_outdelay after OUT_DELAY;
    PIPERX6EQCONTROL_out <= PIPERX6EQCONTROL_outdelay after OUT_DELAY;
    PIPERX6EQLPLFFS_out <= PIPERX6EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX6EQLPTXPRESET_out <= PIPERX6EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX6EQPRESET_out <= PIPERX6EQPRESET_outdelay after OUT_DELAY;
    PIPERX6POLARITY_out <= PIPERX6POLARITY_outdelay after OUT_DELAY;
    PIPERX7EQCONTROL_out <= PIPERX7EQCONTROL_outdelay after OUT_DELAY;
    PIPERX7EQLPLFFS_out <= PIPERX7EQLPLFFS_outdelay after OUT_DELAY;
    PIPERX7EQLPTXPRESET_out <= PIPERX7EQLPTXPRESET_outdelay after OUT_DELAY;
    PIPERX7EQPRESET_out <= PIPERX7EQPRESET_outdelay after OUT_DELAY;
    PIPERX7POLARITY_out <= PIPERX7POLARITY_outdelay after OUT_DELAY;
    PIPETX0CHARISK_out <= PIPETX0CHARISK_outdelay after OUT_DELAY;
    PIPETX0COMPLIANCE_out <= PIPETX0COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX0DATAVALID_out <= PIPETX0DATAVALID_outdelay after OUT_DELAY;
    PIPETX0DATA_out <= PIPETX0DATA_outdelay after OUT_DELAY;
    PIPETX0ELECIDLE_out <= PIPETX0ELECIDLE_outdelay after OUT_DELAY;
    PIPETX0EQCONTROL_out <= PIPETX0EQCONTROL_outdelay after OUT_DELAY;
    PIPETX0EQDEEMPH_out <= PIPETX0EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX0EQPRESET_out <= PIPETX0EQPRESET_outdelay after OUT_DELAY;
    PIPETX0POWERDOWN_out <= PIPETX0POWERDOWN_outdelay after OUT_DELAY;
    PIPETX0STARTBLOCK_out <= PIPETX0STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX0SYNCHEADER_out <= PIPETX0SYNCHEADER_outdelay after OUT_DELAY;
    PIPETX1CHARISK_out <= PIPETX1CHARISK_outdelay after OUT_DELAY;
    PIPETX1COMPLIANCE_out <= PIPETX1COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX1DATAVALID_out <= PIPETX1DATAVALID_outdelay after OUT_DELAY;
    PIPETX1DATA_out <= PIPETX1DATA_outdelay after OUT_DELAY;
    PIPETX1ELECIDLE_out <= PIPETX1ELECIDLE_outdelay after OUT_DELAY;
    PIPETX1EQCONTROL_out <= PIPETX1EQCONTROL_outdelay after OUT_DELAY;
    PIPETX1EQDEEMPH_out <= PIPETX1EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX1EQPRESET_out <= PIPETX1EQPRESET_outdelay after OUT_DELAY;
    PIPETX1POWERDOWN_out <= PIPETX1POWERDOWN_outdelay after OUT_DELAY;
    PIPETX1STARTBLOCK_out <= PIPETX1STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX1SYNCHEADER_out <= PIPETX1SYNCHEADER_outdelay after OUT_DELAY;
    PIPETX2CHARISK_out <= PIPETX2CHARISK_outdelay after OUT_DELAY;
    PIPETX2COMPLIANCE_out <= PIPETX2COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX2DATAVALID_out <= PIPETX2DATAVALID_outdelay after OUT_DELAY;
    PIPETX2DATA_out <= PIPETX2DATA_outdelay after OUT_DELAY;
    PIPETX2ELECIDLE_out <= PIPETX2ELECIDLE_outdelay after OUT_DELAY;
    PIPETX2EQCONTROL_out <= PIPETX2EQCONTROL_outdelay after OUT_DELAY;
    PIPETX2EQDEEMPH_out <= PIPETX2EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX2EQPRESET_out <= PIPETX2EQPRESET_outdelay after OUT_DELAY;
    PIPETX2POWERDOWN_out <= PIPETX2POWERDOWN_outdelay after OUT_DELAY;
    PIPETX2STARTBLOCK_out <= PIPETX2STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX2SYNCHEADER_out <= PIPETX2SYNCHEADER_outdelay after OUT_DELAY;
    PIPETX3CHARISK_out <= PIPETX3CHARISK_outdelay after OUT_DELAY;
    PIPETX3COMPLIANCE_out <= PIPETX3COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX3DATAVALID_out <= PIPETX3DATAVALID_outdelay after OUT_DELAY;
    PIPETX3DATA_out <= PIPETX3DATA_outdelay after OUT_DELAY;
    PIPETX3ELECIDLE_out <= PIPETX3ELECIDLE_outdelay after OUT_DELAY;
    PIPETX3EQCONTROL_out <= PIPETX3EQCONTROL_outdelay after OUT_DELAY;
    PIPETX3EQDEEMPH_out <= PIPETX3EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX3EQPRESET_out <= PIPETX3EQPRESET_outdelay after OUT_DELAY;
    PIPETX3POWERDOWN_out <= PIPETX3POWERDOWN_outdelay after OUT_DELAY;
    PIPETX3STARTBLOCK_out <= PIPETX3STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX3SYNCHEADER_out <= PIPETX3SYNCHEADER_outdelay after OUT_DELAY;
    PIPETX4CHARISK_out <= PIPETX4CHARISK_outdelay after OUT_DELAY;
    PIPETX4COMPLIANCE_out <= PIPETX4COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX4DATAVALID_out <= PIPETX4DATAVALID_outdelay after OUT_DELAY;
    PIPETX4DATA_out <= PIPETX4DATA_outdelay after OUT_DELAY;
    PIPETX4ELECIDLE_out <= PIPETX4ELECIDLE_outdelay after OUT_DELAY;
    PIPETX4EQCONTROL_out <= PIPETX4EQCONTROL_outdelay after OUT_DELAY;
    PIPETX4EQDEEMPH_out <= PIPETX4EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX4EQPRESET_out <= PIPETX4EQPRESET_outdelay after OUT_DELAY;
    PIPETX4POWERDOWN_out <= PIPETX4POWERDOWN_outdelay after OUT_DELAY;
    PIPETX4STARTBLOCK_out <= PIPETX4STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX4SYNCHEADER_out <= PIPETX4SYNCHEADER_outdelay after OUT_DELAY;
    PIPETX5CHARISK_out <= PIPETX5CHARISK_outdelay after OUT_DELAY;
    PIPETX5COMPLIANCE_out <= PIPETX5COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX5DATAVALID_out <= PIPETX5DATAVALID_outdelay after OUT_DELAY;
    PIPETX5DATA_out <= PIPETX5DATA_outdelay after OUT_DELAY;
    PIPETX5ELECIDLE_out <= PIPETX5ELECIDLE_outdelay after OUT_DELAY;
    PIPETX5EQCONTROL_out <= PIPETX5EQCONTROL_outdelay after OUT_DELAY;
    PIPETX5EQDEEMPH_out <= PIPETX5EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX5EQPRESET_out <= PIPETX5EQPRESET_outdelay after OUT_DELAY;
    PIPETX5POWERDOWN_out <= PIPETX5POWERDOWN_outdelay after OUT_DELAY;
    PIPETX5STARTBLOCK_out <= PIPETX5STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX5SYNCHEADER_out <= PIPETX5SYNCHEADER_outdelay after OUT_DELAY;
    PIPETX6CHARISK_out <= PIPETX6CHARISK_outdelay after OUT_DELAY;
    PIPETX6COMPLIANCE_out <= PIPETX6COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX6DATAVALID_out <= PIPETX6DATAVALID_outdelay after OUT_DELAY;
    PIPETX6DATA_out <= PIPETX6DATA_outdelay after OUT_DELAY;
    PIPETX6ELECIDLE_out <= PIPETX6ELECIDLE_outdelay after OUT_DELAY;
    PIPETX6EQCONTROL_out <= PIPETX6EQCONTROL_outdelay after OUT_DELAY;
    PIPETX6EQDEEMPH_out <= PIPETX6EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX6EQPRESET_out <= PIPETX6EQPRESET_outdelay after OUT_DELAY;
    PIPETX6POWERDOWN_out <= PIPETX6POWERDOWN_outdelay after OUT_DELAY;
    PIPETX6STARTBLOCK_out <= PIPETX6STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX6SYNCHEADER_out <= PIPETX6SYNCHEADER_outdelay after OUT_DELAY;
    PIPETX7CHARISK_out <= PIPETX7CHARISK_outdelay after OUT_DELAY;
    PIPETX7COMPLIANCE_out <= PIPETX7COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX7DATAVALID_out <= PIPETX7DATAVALID_outdelay after OUT_DELAY;
    PIPETX7DATA_out <= PIPETX7DATA_outdelay after OUT_DELAY;
    PIPETX7ELECIDLE_out <= PIPETX7ELECIDLE_outdelay after OUT_DELAY;
    PIPETX7EQCONTROL_out <= PIPETX7EQCONTROL_outdelay after OUT_DELAY;
    PIPETX7EQDEEMPH_out <= PIPETX7EQDEEMPH_outdelay after OUT_DELAY;
    PIPETX7EQPRESET_out <= PIPETX7EQPRESET_outdelay after OUT_DELAY;
    PIPETX7POWERDOWN_out <= PIPETX7POWERDOWN_outdelay after OUT_DELAY;
    PIPETX7STARTBLOCK_out <= PIPETX7STARTBLOCK_outdelay after OUT_DELAY;
    PIPETX7SYNCHEADER_out <= PIPETX7SYNCHEADER_outdelay after OUT_DELAY;
    PIPETXDEEMPH_out <= PIPETXDEEMPH_outdelay after OUT_DELAY;
    PIPETXMARGIN_out <= PIPETXMARGIN_outdelay after OUT_DELAY;
    PIPETXRATE_out <= PIPETXRATE_outdelay after OUT_DELAY;
    PIPETXRCVRDET_out <= PIPETXRCVRDET_outdelay after OUT_DELAY;
    PIPETXRESET_out <= PIPETXRESET_outdelay after OUT_DELAY;
    PIPETXSWING_out <= PIPETXSWING_outdelay after OUT_DELAY;
    PLEQINPROGRESS_out <= PLEQINPROGRESS_outdelay after OUT_DELAY;
    PLEQPHASE_out <= PLEQPHASE_outdelay after OUT_DELAY;
    PLGEN3PCSRXSLIDE_out <= PLGEN3PCSRXSLIDE_outdelay after OUT_DELAY;
    SAXISCCTREADY_out <= SAXISCCTREADY_outdelay after OUT_DELAY;
    SAXISRQTREADY_out <= SAXISRQTREADY_outdelay after OUT_DELAY;
    
    CORECLKMICOMPLETIONRAML_ipd <= CORECLKMICOMPLETIONRAML;
    CORECLKMICOMPLETIONRAMU_ipd <= CORECLKMICOMPLETIONRAMU;
    CORECLKMIREPLAYRAM_ipd <= CORECLKMIREPLAYRAM;
    CORECLKMIREQUESTRAM_ipd <= CORECLKMIREQUESTRAM;
    CORECLK_ipd <= CORECLK;
    DRPCLK_ipd <= DRPCLK;
    PIPECLK_ipd <= PIPECLK;
    RECCLK_ipd <= RECCLK;
    USERCLK_ipd <= USERCLK;
    
    CFGCONFIGSPACEENABLE_ipd <= CFGCONFIGSPACEENABLE;
    CFGDEVID_ipd <= CFGDEVID;
    CFGDSBUSNUMBER_ipd <= CFGDSBUSNUMBER;
    CFGDSDEVICENUMBER_ipd <= CFGDSDEVICENUMBER;
    CFGDSFUNCTIONNUMBER_ipd <= CFGDSFUNCTIONNUMBER;
    CFGDSN_ipd <= CFGDSN;
    CFGDSPORTNUMBER_ipd <= CFGDSPORTNUMBER;
    CFGERRCORIN_ipd <= CFGERRCORIN;
    CFGERRUNCORIN_ipd <= CFGERRUNCORIN;
    CFGEXTREADDATAVALID_ipd <= CFGEXTREADDATAVALID;
    CFGEXTREADDATA_ipd <= CFGEXTREADDATA;
    CFGFCSEL_ipd <= CFGFCSEL;
    CFGFLRDONE_ipd <= CFGFLRDONE;
    CFGHOTRESETIN_ipd <= CFGHOTRESETIN;
    CFGINPUTUPDATEREQUEST_ipd <= CFGINPUTUPDATEREQUEST;
    CFGINTERRUPTINT_ipd <= CFGINTERRUPTINT;
    CFGINTERRUPTMSIATTR_ipd <= CFGINTERRUPTMSIATTR;
    CFGINTERRUPTMSIFUNCTIONNUMBER_ipd <= CFGINTERRUPTMSIFUNCTIONNUMBER;
    CFGINTERRUPTMSIINT_ipd <= CFGINTERRUPTMSIINT;
    CFGINTERRUPTMSIPENDINGSTATUS_ipd <= CFGINTERRUPTMSIPENDINGSTATUS;
    CFGINTERRUPTMSISELECT_ipd <= CFGINTERRUPTMSISELECT;
    CFGINTERRUPTMSITPHPRESENT_ipd <= CFGINTERRUPTMSITPHPRESENT;
    CFGINTERRUPTMSITPHSTTAG_ipd <= CFGINTERRUPTMSITPHSTTAG;
    CFGINTERRUPTMSITPHTYPE_ipd <= CFGINTERRUPTMSITPHTYPE;
    CFGINTERRUPTMSIXADDRESS_ipd <= CFGINTERRUPTMSIXADDRESS;
    CFGINTERRUPTMSIXDATA_ipd <= CFGINTERRUPTMSIXDATA;
    CFGINTERRUPTMSIXINT_ipd <= CFGINTERRUPTMSIXINT;
    CFGINTERRUPTPENDING_ipd <= CFGINTERRUPTPENDING;
    CFGLINKTRAININGENABLE_ipd <= CFGLINKTRAININGENABLE;
    CFGMCUPDATEREQUEST_ipd <= CFGMCUPDATEREQUEST;
    CFGMGMTADDR_ipd <= CFGMGMTADDR;
    CFGMGMTBYTEENABLE_ipd <= CFGMGMTBYTEENABLE;
    CFGMGMTREAD_ipd <= CFGMGMTREAD;
    CFGMGMTTYPE1CFGREGACCESS_ipd <= CFGMGMTTYPE1CFGREGACCESS;
    CFGMGMTWRITEDATA_ipd <= CFGMGMTWRITEDATA;
    CFGMGMTWRITE_ipd <= CFGMGMTWRITE;
    CFGMSGTRANSMITDATA_ipd <= CFGMSGTRANSMITDATA;
    CFGMSGTRANSMITTYPE_ipd <= CFGMSGTRANSMITTYPE;
    CFGMSGTRANSMIT_ipd <= CFGMSGTRANSMIT;
    CFGPERFUNCSTATUSCONTROL_ipd <= CFGPERFUNCSTATUSCONTROL;
    CFGPERFUNCTIONNUMBER_ipd <= CFGPERFUNCTIONNUMBER;
    CFGPERFUNCTIONOUTPUTREQUEST_ipd <= CFGPERFUNCTIONOUTPUTREQUEST;
    CFGPOWERSTATECHANGEACK_ipd <= CFGPOWERSTATECHANGEACK;
    CFGREQPMTRANSITIONL23READY_ipd <= CFGREQPMTRANSITIONL23READY;
    CFGREVID_ipd <= CFGREVID;
    CFGSUBSYSID_ipd <= CFGSUBSYSID;
    CFGSUBSYSVENDID_ipd <= CFGSUBSYSVENDID;
    CFGTPHSTTREADDATAVALID_ipd <= CFGTPHSTTREADDATAVALID;
    CFGTPHSTTREADDATA_ipd <= CFGTPHSTTREADDATA;
    CFGVENDID_ipd <= CFGVENDID;
    CFGVFFLRDONE_ipd <= CFGVFFLRDONE;
    DRPADDR_ipd <= DRPADDR;
    DRPDI_ipd <= DRPDI;
    DRPEN_ipd <= DRPEN;
    DRPWE_ipd <= DRPWE;
    MAXISCQTREADY_ipd <= MAXISCQTREADY;
    MAXISRCTREADY_ipd <= MAXISRCTREADY;
    MGMTRESETN_ipd <= MGMTRESETN;
    MGMTSTICKYRESETN_ipd <= MGMTSTICKYRESETN;
    MICOMPLETIONRAMREADDATA_ipd <= MICOMPLETIONRAMREADDATA;
    MIREPLAYRAMREADDATA_ipd <= MIREPLAYRAMREADDATA;
    MIREQUESTRAMREADDATA_ipd <= MIREQUESTRAMREADDATA;
    PCIECQNPREQ_ipd <= PCIECQNPREQ;
    PIPEEQFS_ipd <= PIPEEQFS;
    PIPEEQLF_ipd <= PIPEEQLF;
    PIPERESETN_ipd <= PIPERESETN;
    PIPERX0CHARISK_ipd <= PIPERX0CHARISK;
    PIPERX0DATAVALID_ipd <= PIPERX0DATAVALID;
    PIPERX0DATA_ipd <= PIPERX0DATA;
    PIPERX0ELECIDLE_ipd <= PIPERX0ELECIDLE;
    PIPERX0EQDONE_ipd <= PIPERX0EQDONE;
    PIPERX0EQLPADAPTDONE_ipd <= PIPERX0EQLPADAPTDONE;
    PIPERX0EQLPLFFSSEL_ipd <= PIPERX0EQLPLFFSSEL;
    PIPERX0EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX0EQLPNEWTXCOEFFORPRESET;
    PIPERX0PHYSTATUS_ipd <= PIPERX0PHYSTATUS;
    PIPERX0STARTBLOCK_ipd <= PIPERX0STARTBLOCK;
    PIPERX0STATUS_ipd <= PIPERX0STATUS;
    PIPERX0SYNCHEADER_ipd <= PIPERX0SYNCHEADER;
    PIPERX0VALID_ipd <= PIPERX0VALID;
    PIPERX1CHARISK_ipd <= PIPERX1CHARISK;
    PIPERX1DATAVALID_ipd <= PIPERX1DATAVALID;
    PIPERX1DATA_ipd <= PIPERX1DATA;
    PIPERX1ELECIDLE_ipd <= PIPERX1ELECIDLE;
    PIPERX1EQDONE_ipd <= PIPERX1EQDONE;
    PIPERX1EQLPADAPTDONE_ipd <= PIPERX1EQLPADAPTDONE;
    PIPERX1EQLPLFFSSEL_ipd <= PIPERX1EQLPLFFSSEL;
    PIPERX1EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX1EQLPNEWTXCOEFFORPRESET;
    PIPERX1PHYSTATUS_ipd <= PIPERX1PHYSTATUS;
    PIPERX1STARTBLOCK_ipd <= PIPERX1STARTBLOCK;
    PIPERX1STATUS_ipd <= PIPERX1STATUS;
    PIPERX1SYNCHEADER_ipd <= PIPERX1SYNCHEADER;
    PIPERX1VALID_ipd <= PIPERX1VALID;
    PIPERX2CHARISK_ipd <= PIPERX2CHARISK;
    PIPERX2DATAVALID_ipd <= PIPERX2DATAVALID;
    PIPERX2DATA_ipd <= PIPERX2DATA;
    PIPERX2ELECIDLE_ipd <= PIPERX2ELECIDLE;
    PIPERX2EQDONE_ipd <= PIPERX2EQDONE;
    PIPERX2EQLPADAPTDONE_ipd <= PIPERX2EQLPADAPTDONE;
    PIPERX2EQLPLFFSSEL_ipd <= PIPERX2EQLPLFFSSEL;
    PIPERX2EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX2EQLPNEWTXCOEFFORPRESET;
    PIPERX2PHYSTATUS_ipd <= PIPERX2PHYSTATUS;
    PIPERX2STARTBLOCK_ipd <= PIPERX2STARTBLOCK;
    PIPERX2STATUS_ipd <= PIPERX2STATUS;
    PIPERX2SYNCHEADER_ipd <= PIPERX2SYNCHEADER;
    PIPERX2VALID_ipd <= PIPERX2VALID;
    PIPERX3CHARISK_ipd <= PIPERX3CHARISK;
    PIPERX3DATAVALID_ipd <= PIPERX3DATAVALID;
    PIPERX3DATA_ipd <= PIPERX3DATA;
    PIPERX3ELECIDLE_ipd <= PIPERX3ELECIDLE;
    PIPERX3EQDONE_ipd <= PIPERX3EQDONE;
    PIPERX3EQLPADAPTDONE_ipd <= PIPERX3EQLPADAPTDONE;
    PIPERX3EQLPLFFSSEL_ipd <= PIPERX3EQLPLFFSSEL;
    PIPERX3EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX3EQLPNEWTXCOEFFORPRESET;
    PIPERX3PHYSTATUS_ipd <= PIPERX3PHYSTATUS;
    PIPERX3STARTBLOCK_ipd <= PIPERX3STARTBLOCK;
    PIPERX3STATUS_ipd <= PIPERX3STATUS;
    PIPERX3SYNCHEADER_ipd <= PIPERX3SYNCHEADER;
    PIPERX3VALID_ipd <= PIPERX3VALID;
    PIPERX4CHARISK_ipd <= PIPERX4CHARISK;
    PIPERX4DATAVALID_ipd <= PIPERX4DATAVALID;
    PIPERX4DATA_ipd <= PIPERX4DATA;
    PIPERX4ELECIDLE_ipd <= PIPERX4ELECIDLE;
    PIPERX4EQDONE_ipd <= PIPERX4EQDONE;
    PIPERX4EQLPADAPTDONE_ipd <= PIPERX4EQLPADAPTDONE;
    PIPERX4EQLPLFFSSEL_ipd <= PIPERX4EQLPLFFSSEL;
    PIPERX4EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX4EQLPNEWTXCOEFFORPRESET;
    PIPERX4PHYSTATUS_ipd <= PIPERX4PHYSTATUS;
    PIPERX4STARTBLOCK_ipd <= PIPERX4STARTBLOCK;
    PIPERX4STATUS_ipd <= PIPERX4STATUS;
    PIPERX4SYNCHEADER_ipd <= PIPERX4SYNCHEADER;
    PIPERX4VALID_ipd <= PIPERX4VALID;
    PIPERX5CHARISK_ipd <= PIPERX5CHARISK;
    PIPERX5DATAVALID_ipd <= PIPERX5DATAVALID;
    PIPERX5DATA_ipd <= PIPERX5DATA;
    PIPERX5ELECIDLE_ipd <= PIPERX5ELECIDLE;
    PIPERX5EQDONE_ipd <= PIPERX5EQDONE;
    PIPERX5EQLPADAPTDONE_ipd <= PIPERX5EQLPADAPTDONE;
    PIPERX5EQLPLFFSSEL_ipd <= PIPERX5EQLPLFFSSEL;
    PIPERX5EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX5EQLPNEWTXCOEFFORPRESET;
    PIPERX5PHYSTATUS_ipd <= PIPERX5PHYSTATUS;
    PIPERX5STARTBLOCK_ipd <= PIPERX5STARTBLOCK;
    PIPERX5STATUS_ipd <= PIPERX5STATUS;
    PIPERX5SYNCHEADER_ipd <= PIPERX5SYNCHEADER;
    PIPERX5VALID_ipd <= PIPERX5VALID;
    PIPERX6CHARISK_ipd <= PIPERX6CHARISK;
    PIPERX6DATAVALID_ipd <= PIPERX6DATAVALID;
    PIPERX6DATA_ipd <= PIPERX6DATA;
    PIPERX6ELECIDLE_ipd <= PIPERX6ELECIDLE;
    PIPERX6EQDONE_ipd <= PIPERX6EQDONE;
    PIPERX6EQLPADAPTDONE_ipd <= PIPERX6EQLPADAPTDONE;
    PIPERX6EQLPLFFSSEL_ipd <= PIPERX6EQLPLFFSSEL;
    PIPERX6EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX6EQLPNEWTXCOEFFORPRESET;
    PIPERX6PHYSTATUS_ipd <= PIPERX6PHYSTATUS;
    PIPERX6STARTBLOCK_ipd <= PIPERX6STARTBLOCK;
    PIPERX6STATUS_ipd <= PIPERX6STATUS;
    PIPERX6SYNCHEADER_ipd <= PIPERX6SYNCHEADER;
    PIPERX6VALID_ipd <= PIPERX6VALID;
    PIPERX7CHARISK_ipd <= PIPERX7CHARISK;
    PIPERX7DATAVALID_ipd <= PIPERX7DATAVALID;
    PIPERX7DATA_ipd <= PIPERX7DATA;
    PIPERX7ELECIDLE_ipd <= PIPERX7ELECIDLE;
    PIPERX7EQDONE_ipd <= PIPERX7EQDONE;
    PIPERX7EQLPADAPTDONE_ipd <= PIPERX7EQLPADAPTDONE;
    PIPERX7EQLPLFFSSEL_ipd <= PIPERX7EQLPLFFSSEL;
    PIPERX7EQLPNEWTXCOEFFORPRESET_ipd <= PIPERX7EQLPNEWTXCOEFFORPRESET;
    PIPERX7PHYSTATUS_ipd <= PIPERX7PHYSTATUS;
    PIPERX7STARTBLOCK_ipd <= PIPERX7STARTBLOCK;
    PIPERX7STATUS_ipd <= PIPERX7STATUS;
    PIPERX7SYNCHEADER_ipd <= PIPERX7SYNCHEADER;
    PIPERX7VALID_ipd <= PIPERX7VALID;
    PIPETX0EQCOEFF_ipd <= PIPETX0EQCOEFF;
    PIPETX0EQDONE_ipd <= PIPETX0EQDONE;
    PIPETX1EQCOEFF_ipd <= PIPETX1EQCOEFF;
    PIPETX1EQDONE_ipd <= PIPETX1EQDONE;
    PIPETX2EQCOEFF_ipd <= PIPETX2EQCOEFF;
    PIPETX2EQDONE_ipd <= PIPETX2EQDONE;
    PIPETX3EQCOEFF_ipd <= PIPETX3EQCOEFF;
    PIPETX3EQDONE_ipd <= PIPETX3EQDONE;
    PIPETX4EQCOEFF_ipd <= PIPETX4EQCOEFF;
    PIPETX4EQDONE_ipd <= PIPETX4EQDONE;
    PIPETX5EQCOEFF_ipd <= PIPETX5EQCOEFF;
    PIPETX5EQDONE_ipd <= PIPETX5EQDONE;
    PIPETX6EQCOEFF_ipd <= PIPETX6EQCOEFF;
    PIPETX6EQDONE_ipd <= PIPETX6EQDONE;
    PIPETX7EQCOEFF_ipd <= PIPETX7EQCOEFF;
    PIPETX7EQDONE_ipd <= PIPETX7EQDONE;
    PLDISABLESCRAMBLER_ipd <= PLDISABLESCRAMBLER;
    PLEQRESETEIEOSCOUNT_ipd <= PLEQRESETEIEOSCOUNT;
    PLGEN3PCSDISABLE_ipd <= PLGEN3PCSDISABLE;
    PLGEN3PCSRXSYNCDONE_ipd <= PLGEN3PCSRXSYNCDONE;
    RESETN_ipd <= RESETN;
    SAXISCCTDATA_ipd <= SAXISCCTDATA;
    SAXISCCTKEEP_ipd <= SAXISCCTKEEP;
    SAXISCCTLAST_ipd <= SAXISCCTLAST;
    SAXISCCTUSER_ipd <= SAXISCCTUSER;
    SAXISCCTVALID_ipd <= SAXISCCTVALID;
    SAXISRQTDATA_ipd <= SAXISRQTDATA;
    SAXISRQTKEEP_ipd <= SAXISRQTKEEP;
    SAXISRQTLAST_ipd <= SAXISRQTLAST;
    SAXISRQTUSER_ipd <= SAXISRQTUSER;
    SAXISRQTVALID_ipd <= SAXISRQTVALID;
    
    CORECLKMICOMPLETIONRAML_indelay <= CORECLKMICOMPLETIONRAML_ipd after INCLK_DELAY;
    CORECLKMICOMPLETIONRAMU_indelay <= CORECLKMICOMPLETIONRAMU_ipd after INCLK_DELAY;
    CORECLKMIREPLAYRAM_indelay <= CORECLKMIREPLAYRAM_ipd after INCLK_DELAY;
    CORECLKMIREQUESTRAM_indelay <= CORECLKMIREQUESTRAM_ipd after INCLK_DELAY;
    CORECLK_indelay <= CORECLK_ipd after INCLK_DELAY;
    DRPCLK_indelay <= DRPCLK_ipd after INCLK_DELAY;
    PIPECLK_indelay <= PIPECLK_ipd after INCLK_DELAY;
    RECCLK_indelay <= RECCLK_ipd after INCLK_DELAY;
    USERCLK_indelay <= USERCLK_ipd after INCLK_DELAY;
    
    CFGCONFIGSPACEENABLE_indelay <= CFGCONFIGSPACEENABLE_ipd after IN_DELAY;
    CFGDEVID_indelay <= CFGDEVID_ipd after IN_DELAY;
    CFGDSBUSNUMBER_indelay <= CFGDSBUSNUMBER_ipd after IN_DELAY;
    CFGDSDEVICENUMBER_indelay <= CFGDSDEVICENUMBER_ipd after IN_DELAY;
    CFGDSFUNCTIONNUMBER_indelay <= CFGDSFUNCTIONNUMBER_ipd after IN_DELAY;
    CFGDSN_indelay <= CFGDSN_ipd after IN_DELAY;
    CFGDSPORTNUMBER_indelay <= CFGDSPORTNUMBER_ipd after IN_DELAY;
    CFGERRCORIN_indelay <= CFGERRCORIN_ipd after IN_DELAY;
    CFGERRUNCORIN_indelay <= CFGERRUNCORIN_ipd after IN_DELAY;
    CFGEXTREADDATAVALID_indelay <= CFGEXTREADDATAVALID_ipd after IN_DELAY;
    CFGEXTREADDATA_indelay <= CFGEXTREADDATA_ipd after IN_DELAY;
    CFGFCSEL_indelay <= CFGFCSEL_ipd after IN_DELAY;
    CFGFLRDONE_indelay <= CFGFLRDONE_ipd after IN_DELAY;
    CFGHOTRESETIN_indelay <= CFGHOTRESETIN_ipd after IN_DELAY;
    CFGINPUTUPDATEREQUEST_indelay <= CFGINPUTUPDATEREQUEST_ipd after IN_DELAY;
    CFGINTERRUPTINT_indelay <= CFGINTERRUPTINT_ipd after IN_DELAY;
    CFGINTERRUPTMSIATTR_indelay <= CFGINTERRUPTMSIATTR_ipd after IN_DELAY;
    CFGINTERRUPTMSIFUNCTIONNUMBER_indelay <= CFGINTERRUPTMSIFUNCTIONNUMBER_ipd after IN_DELAY;
    CFGINTERRUPTMSIINT_indelay <= CFGINTERRUPTMSIINT_ipd after IN_DELAY;
    CFGINTERRUPTMSIPENDINGSTATUS_indelay <= CFGINTERRUPTMSIPENDINGSTATUS_ipd after IN_DELAY;
    CFGINTERRUPTMSISELECT_indelay <= CFGINTERRUPTMSISELECT_ipd after IN_DELAY;
    CFGINTERRUPTMSITPHPRESENT_indelay <= CFGINTERRUPTMSITPHPRESENT_ipd after IN_DELAY;
    CFGINTERRUPTMSITPHSTTAG_indelay <= CFGINTERRUPTMSITPHSTTAG_ipd after IN_DELAY;
    CFGINTERRUPTMSITPHTYPE_indelay <= CFGINTERRUPTMSITPHTYPE_ipd after IN_DELAY;
    CFGINTERRUPTMSIXADDRESS_indelay <= CFGINTERRUPTMSIXADDRESS_ipd after IN_DELAY;
    CFGINTERRUPTMSIXDATA_indelay <= CFGINTERRUPTMSIXDATA_ipd after IN_DELAY;
    CFGINTERRUPTMSIXINT_indelay <= CFGINTERRUPTMSIXINT_ipd after IN_DELAY;
    CFGINTERRUPTPENDING_indelay <= CFGINTERRUPTPENDING_ipd after IN_DELAY;
    CFGLINKTRAININGENABLE_indelay <= CFGLINKTRAININGENABLE_ipd after IN_DELAY;
    CFGMCUPDATEREQUEST_indelay <= CFGMCUPDATEREQUEST_ipd after IN_DELAY;
    CFGMGMTADDR_indelay <= CFGMGMTADDR_ipd after IN_DELAY;
    CFGMGMTBYTEENABLE_indelay <= CFGMGMTBYTEENABLE_ipd after IN_DELAY;
    CFGMGMTREAD_indelay <= CFGMGMTREAD_ipd after IN_DELAY;
    CFGMGMTTYPE1CFGREGACCESS_indelay <= CFGMGMTTYPE1CFGREGACCESS_ipd after IN_DELAY;
    CFGMGMTWRITEDATA_indelay <= CFGMGMTWRITEDATA_ipd after IN_DELAY;
    CFGMGMTWRITE_indelay <= CFGMGMTWRITE_ipd after IN_DELAY;
    CFGMSGTRANSMITDATA_indelay <= CFGMSGTRANSMITDATA_ipd after IN_DELAY;
    CFGMSGTRANSMITTYPE_indelay <= CFGMSGTRANSMITTYPE_ipd after IN_DELAY;
    CFGMSGTRANSMIT_indelay <= CFGMSGTRANSMIT_ipd after IN_DELAY;
    CFGPERFUNCSTATUSCONTROL_indelay <= CFGPERFUNCSTATUSCONTROL_ipd after IN_DELAY;
    CFGPERFUNCTIONNUMBER_indelay <= CFGPERFUNCTIONNUMBER_ipd after IN_DELAY;
    CFGPERFUNCTIONOUTPUTREQUEST_indelay <= CFGPERFUNCTIONOUTPUTREQUEST_ipd after IN_DELAY;
    CFGPOWERSTATECHANGEACK_indelay <= CFGPOWERSTATECHANGEACK_ipd after IN_DELAY;
    CFGREQPMTRANSITIONL23READY_indelay <= CFGREQPMTRANSITIONL23READY_ipd after IN_DELAY;
    CFGREVID_indelay <= CFGREVID_ipd after IN_DELAY;
    CFGSUBSYSID_indelay <= CFGSUBSYSID_ipd after IN_DELAY;
    CFGSUBSYSVENDID_indelay <= CFGSUBSYSVENDID_ipd after IN_DELAY;
    CFGTPHSTTREADDATAVALID_indelay <= CFGTPHSTTREADDATAVALID_ipd after IN_DELAY;
    CFGTPHSTTREADDATA_indelay <= CFGTPHSTTREADDATA_ipd after IN_DELAY;
    CFGVENDID_indelay <= CFGVENDID_ipd after IN_DELAY;
    CFGVFFLRDONE_indelay <= CFGVFFLRDONE_ipd after IN_DELAY;
    DRPADDR_indelay <= DRPADDR_ipd after IN_DELAY;
    DRPDI_indelay <= DRPDI_ipd after IN_DELAY;
    DRPEN_indelay <= DRPEN_ipd after IN_DELAY;
    DRPWE_indelay <= DRPWE_ipd after IN_DELAY;
    MAXISCQTREADY_indelay <= MAXISCQTREADY_ipd after IN_DELAY;
    MAXISRCTREADY_indelay <= MAXISRCTREADY_ipd after IN_DELAY;
    MGMTRESETN_indelay <= MGMTRESETN_ipd after IN_DELAY;
    MGMTSTICKYRESETN_indelay <= MGMTSTICKYRESETN_ipd after IN_DELAY;
    MICOMPLETIONRAMREADDATA_indelay <= MICOMPLETIONRAMREADDATA_ipd after IN_DELAY;
    MIREPLAYRAMREADDATA_indelay <= MIREPLAYRAMREADDATA_ipd after IN_DELAY;
    MIREQUESTRAMREADDATA_indelay <= MIREQUESTRAMREADDATA_ipd after IN_DELAY;
    PCIECQNPREQ_indelay <= PCIECQNPREQ_ipd after IN_DELAY;
    PIPEEQFS_indelay <= PIPEEQFS_ipd after IN_DELAY;
    PIPEEQLF_indelay <= PIPEEQLF_ipd after IN_DELAY;
    PIPERESETN_indelay <= PIPERESETN_ipd after IN_DELAY;
    PIPERX0CHARISK_indelay <= PIPERX0CHARISK_ipd after IN_DELAY;
    PIPERX0DATAVALID_indelay <= PIPERX0DATAVALID_ipd after IN_DELAY;
    PIPERX0DATA_indelay <= PIPERX0DATA_ipd after IN_DELAY;
    PIPERX0ELECIDLE_indelay <= PIPERX0ELECIDLE_ipd after IN_DELAY;
    PIPERX0EQDONE_indelay <= PIPERX0EQDONE_ipd after IN_DELAY;
    PIPERX0EQLPADAPTDONE_indelay <= PIPERX0EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX0EQLPLFFSSEL_indelay <= PIPERX0EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX0EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX0EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX0PHYSTATUS_indelay <= PIPERX0PHYSTATUS_ipd after IN_DELAY;
    PIPERX0STARTBLOCK_indelay <= PIPERX0STARTBLOCK_ipd after IN_DELAY;
    PIPERX0STATUS_indelay <= PIPERX0STATUS_ipd after IN_DELAY;
    PIPERX0SYNCHEADER_indelay <= PIPERX0SYNCHEADER_ipd after IN_DELAY;
    PIPERX0VALID_indelay <= PIPERX0VALID_ipd after IN_DELAY;
    PIPERX1CHARISK_indelay <= PIPERX1CHARISK_ipd after IN_DELAY;
    PIPERX1DATAVALID_indelay <= PIPERX1DATAVALID_ipd after IN_DELAY;
    PIPERX1DATA_indelay <= PIPERX1DATA_ipd after IN_DELAY;
    PIPERX1ELECIDLE_indelay <= PIPERX1ELECIDLE_ipd after IN_DELAY;
    PIPERX1EQDONE_indelay <= PIPERX1EQDONE_ipd after IN_DELAY;
    PIPERX1EQLPADAPTDONE_indelay <= PIPERX1EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX1EQLPLFFSSEL_indelay <= PIPERX1EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX1EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX1EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX1PHYSTATUS_indelay <= PIPERX1PHYSTATUS_ipd after IN_DELAY;
    PIPERX1STARTBLOCK_indelay <= PIPERX1STARTBLOCK_ipd after IN_DELAY;
    PIPERX1STATUS_indelay <= PIPERX1STATUS_ipd after IN_DELAY;
    PIPERX1SYNCHEADER_indelay <= PIPERX1SYNCHEADER_ipd after IN_DELAY;
    PIPERX1VALID_indelay <= PIPERX1VALID_ipd after IN_DELAY;
    PIPERX2CHARISK_indelay <= PIPERX2CHARISK_ipd after IN_DELAY;
    PIPERX2DATAVALID_indelay <= PIPERX2DATAVALID_ipd after IN_DELAY;
    PIPERX2DATA_indelay <= PIPERX2DATA_ipd after IN_DELAY;
    PIPERX2ELECIDLE_indelay <= PIPERX2ELECIDLE_ipd after IN_DELAY;
    PIPERX2EQDONE_indelay <= PIPERX2EQDONE_ipd after IN_DELAY;
    PIPERX2EQLPADAPTDONE_indelay <= PIPERX2EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX2EQLPLFFSSEL_indelay <= PIPERX2EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX2EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX2EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX2PHYSTATUS_indelay <= PIPERX2PHYSTATUS_ipd after IN_DELAY;
    PIPERX2STARTBLOCK_indelay <= PIPERX2STARTBLOCK_ipd after IN_DELAY;
    PIPERX2STATUS_indelay <= PIPERX2STATUS_ipd after IN_DELAY;
    PIPERX2SYNCHEADER_indelay <= PIPERX2SYNCHEADER_ipd after IN_DELAY;
    PIPERX2VALID_indelay <= PIPERX2VALID_ipd after IN_DELAY;
    PIPERX3CHARISK_indelay <= PIPERX3CHARISK_ipd after IN_DELAY;
    PIPERX3DATAVALID_indelay <= PIPERX3DATAVALID_ipd after IN_DELAY;
    PIPERX3DATA_indelay <= PIPERX3DATA_ipd after IN_DELAY;
    PIPERX3ELECIDLE_indelay <= PIPERX3ELECIDLE_ipd after IN_DELAY;
    PIPERX3EQDONE_indelay <= PIPERX3EQDONE_ipd after IN_DELAY;
    PIPERX3EQLPADAPTDONE_indelay <= PIPERX3EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX3EQLPLFFSSEL_indelay <= PIPERX3EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX3EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX3EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX3PHYSTATUS_indelay <= PIPERX3PHYSTATUS_ipd after IN_DELAY;
    PIPERX3STARTBLOCK_indelay <= PIPERX3STARTBLOCK_ipd after IN_DELAY;
    PIPERX3STATUS_indelay <= PIPERX3STATUS_ipd after IN_DELAY;
    PIPERX3SYNCHEADER_indelay <= PIPERX3SYNCHEADER_ipd after IN_DELAY;
    PIPERX3VALID_indelay <= PIPERX3VALID_ipd after IN_DELAY;
    PIPERX4CHARISK_indelay <= PIPERX4CHARISK_ipd after IN_DELAY;
    PIPERX4DATAVALID_indelay <= PIPERX4DATAVALID_ipd after IN_DELAY;
    PIPERX4DATA_indelay <= PIPERX4DATA_ipd after IN_DELAY;
    PIPERX4ELECIDLE_indelay <= PIPERX4ELECIDLE_ipd after IN_DELAY;
    PIPERX4EQDONE_indelay <= PIPERX4EQDONE_ipd after IN_DELAY;
    PIPERX4EQLPADAPTDONE_indelay <= PIPERX4EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX4EQLPLFFSSEL_indelay <= PIPERX4EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX4EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX4EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX4PHYSTATUS_indelay <= PIPERX4PHYSTATUS_ipd after IN_DELAY;
    PIPERX4STARTBLOCK_indelay <= PIPERX4STARTBLOCK_ipd after IN_DELAY;
    PIPERX4STATUS_indelay <= PIPERX4STATUS_ipd after IN_DELAY;
    PIPERX4SYNCHEADER_indelay <= PIPERX4SYNCHEADER_ipd after IN_DELAY;
    PIPERX4VALID_indelay <= PIPERX4VALID_ipd after IN_DELAY;
    PIPERX5CHARISK_indelay <= PIPERX5CHARISK_ipd after IN_DELAY;
    PIPERX5DATAVALID_indelay <= PIPERX5DATAVALID_ipd after IN_DELAY;
    PIPERX5DATA_indelay <= PIPERX5DATA_ipd after IN_DELAY;
    PIPERX5ELECIDLE_indelay <= PIPERX5ELECIDLE_ipd after IN_DELAY;
    PIPERX5EQDONE_indelay <= PIPERX5EQDONE_ipd after IN_DELAY;
    PIPERX5EQLPADAPTDONE_indelay <= PIPERX5EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX5EQLPLFFSSEL_indelay <= PIPERX5EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX5EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX5EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX5PHYSTATUS_indelay <= PIPERX5PHYSTATUS_ipd after IN_DELAY;
    PIPERX5STARTBLOCK_indelay <= PIPERX5STARTBLOCK_ipd after IN_DELAY;
    PIPERX5STATUS_indelay <= PIPERX5STATUS_ipd after IN_DELAY;
    PIPERX5SYNCHEADER_indelay <= PIPERX5SYNCHEADER_ipd after IN_DELAY;
    PIPERX5VALID_indelay <= PIPERX5VALID_ipd after IN_DELAY;
    PIPERX6CHARISK_indelay <= PIPERX6CHARISK_ipd after IN_DELAY;
    PIPERX6DATAVALID_indelay <= PIPERX6DATAVALID_ipd after IN_DELAY;
    PIPERX6DATA_indelay <= PIPERX6DATA_ipd after IN_DELAY;
    PIPERX6ELECIDLE_indelay <= PIPERX6ELECIDLE_ipd after IN_DELAY;
    PIPERX6EQDONE_indelay <= PIPERX6EQDONE_ipd after IN_DELAY;
    PIPERX6EQLPADAPTDONE_indelay <= PIPERX6EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX6EQLPLFFSSEL_indelay <= PIPERX6EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX6EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX6EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX6PHYSTATUS_indelay <= PIPERX6PHYSTATUS_ipd after IN_DELAY;
    PIPERX6STARTBLOCK_indelay <= PIPERX6STARTBLOCK_ipd after IN_DELAY;
    PIPERX6STATUS_indelay <= PIPERX6STATUS_ipd after IN_DELAY;
    PIPERX6SYNCHEADER_indelay <= PIPERX6SYNCHEADER_ipd after IN_DELAY;
    PIPERX6VALID_indelay <= PIPERX6VALID_ipd after IN_DELAY;
    PIPERX7CHARISK_indelay <= PIPERX7CHARISK_ipd after IN_DELAY;
    PIPERX7DATAVALID_indelay <= PIPERX7DATAVALID_ipd after IN_DELAY;
    PIPERX7DATA_indelay <= PIPERX7DATA_ipd after IN_DELAY;
    PIPERX7ELECIDLE_indelay <= PIPERX7ELECIDLE_ipd after IN_DELAY;
    PIPERX7EQDONE_indelay <= PIPERX7EQDONE_ipd after IN_DELAY;
    PIPERX7EQLPADAPTDONE_indelay <= PIPERX7EQLPADAPTDONE_ipd after IN_DELAY;
    PIPERX7EQLPLFFSSEL_indelay <= PIPERX7EQLPLFFSSEL_ipd after IN_DELAY;
    PIPERX7EQLPNEWTXCOEFFORPRESET_indelay <= PIPERX7EQLPNEWTXCOEFFORPRESET_ipd after IN_DELAY;
    PIPERX7PHYSTATUS_indelay <= PIPERX7PHYSTATUS_ipd after IN_DELAY;
    PIPERX7STARTBLOCK_indelay <= PIPERX7STARTBLOCK_ipd after IN_DELAY;
    PIPERX7STATUS_indelay <= PIPERX7STATUS_ipd after IN_DELAY;
    PIPERX7SYNCHEADER_indelay <= PIPERX7SYNCHEADER_ipd after IN_DELAY;
    PIPERX7VALID_indelay <= PIPERX7VALID_ipd after IN_DELAY;
    PIPETX0EQCOEFF_indelay <= PIPETX0EQCOEFF_ipd after IN_DELAY;
    PIPETX0EQDONE_indelay <= PIPETX0EQDONE_ipd after IN_DELAY;
    PIPETX1EQCOEFF_indelay <= PIPETX1EQCOEFF_ipd after IN_DELAY;
    PIPETX1EQDONE_indelay <= PIPETX1EQDONE_ipd after IN_DELAY;
    PIPETX2EQCOEFF_indelay <= PIPETX2EQCOEFF_ipd after IN_DELAY;
    PIPETX2EQDONE_indelay <= PIPETX2EQDONE_ipd after IN_DELAY;
    PIPETX3EQCOEFF_indelay <= PIPETX3EQCOEFF_ipd after IN_DELAY;
    PIPETX3EQDONE_indelay <= PIPETX3EQDONE_ipd after IN_DELAY;
    PIPETX4EQCOEFF_indelay <= PIPETX4EQCOEFF_ipd after IN_DELAY;
    PIPETX4EQDONE_indelay <= PIPETX4EQDONE_ipd after IN_DELAY;
    PIPETX5EQCOEFF_indelay <= PIPETX5EQCOEFF_ipd after IN_DELAY;
    PIPETX5EQDONE_indelay <= PIPETX5EQDONE_ipd after IN_DELAY;
    PIPETX6EQCOEFF_indelay <= PIPETX6EQCOEFF_ipd after IN_DELAY;
    PIPETX6EQDONE_indelay <= PIPETX6EQDONE_ipd after IN_DELAY;
    PIPETX7EQCOEFF_indelay <= PIPETX7EQCOEFF_ipd after IN_DELAY;
    PIPETX7EQDONE_indelay <= PIPETX7EQDONE_ipd after IN_DELAY;
    PLDISABLESCRAMBLER_indelay <= PLDISABLESCRAMBLER_ipd after IN_DELAY;
    PLEQRESETEIEOSCOUNT_indelay <= PLEQRESETEIEOSCOUNT_ipd after IN_DELAY;
    PLGEN3PCSDISABLE_indelay <= PLGEN3PCSDISABLE_ipd after IN_DELAY;
    PLGEN3PCSRXSYNCDONE_indelay <= PLGEN3PCSRXSYNCDONE_ipd after IN_DELAY;
    RESETN_indelay <= RESETN_ipd after IN_DELAY;
    SAXISCCTDATA_indelay <= SAXISCCTDATA_ipd after IN_DELAY;
    SAXISCCTKEEP_indelay <= SAXISCCTKEEP_ipd after IN_DELAY;
    SAXISCCTLAST_indelay <= SAXISCCTLAST_ipd after IN_DELAY;
    SAXISCCTUSER_indelay <= SAXISCCTUSER_ipd after IN_DELAY;
    SAXISCCTVALID_indelay <= SAXISCCTVALID_ipd after IN_DELAY;
    SAXISRQTDATA_indelay <= SAXISRQTDATA_ipd after IN_DELAY;
    SAXISRQTKEEP_indelay <= SAXISRQTKEEP_ipd after IN_DELAY;
    SAXISRQTLAST_indelay <= SAXISRQTLAST_ipd after IN_DELAY;
    SAXISRQTUSER_indelay <= SAXISRQTUSER_ipd after IN_DELAY;
    SAXISRQTVALID_indelay <= SAXISRQTVALID_ipd after IN_DELAY;
    
    
    PCIE_3_0_INST : PCIE_3_0_WRAP
      generic map (
        ARI_CAP_ENABLE       => ARI_CAP_ENABLE,
        AXISTEN_IF_CC_ALIGNMENT_MODE => AXISTEN_IF_CC_ALIGNMENT_MODE,
        AXISTEN_IF_CC_PARITY_CHK => AXISTEN_IF_CC_PARITY_CHK,
        AXISTEN_IF_CQ_ALIGNMENT_MODE => AXISTEN_IF_CQ_ALIGNMENT_MODE,
        AXISTEN_IF_ENABLE_CLIENT_TAG => AXISTEN_IF_ENABLE_CLIENT_TAG,
        AXISTEN_IF_ENABLE_MSG_ROUTE => AXISTEN_IF_ENABLE_MSG_ROUTE_STRING,
        AXISTEN_IF_ENABLE_RX_MSG_INTFC => AXISTEN_IF_ENABLE_RX_MSG_INTFC,
        AXISTEN_IF_RC_ALIGNMENT_MODE => AXISTEN_IF_RC_ALIGNMENT_MODE,
        AXISTEN_IF_RC_STRADDLE => AXISTEN_IF_RC_STRADDLE,
        AXISTEN_IF_RQ_ALIGNMENT_MODE => AXISTEN_IF_RQ_ALIGNMENT_MODE,
        AXISTEN_IF_RQ_PARITY_CHK => AXISTEN_IF_RQ_PARITY_CHK,
        AXISTEN_IF_WIDTH     => AXISTEN_IF_WIDTH_STRING,
        CRM_CORE_CLK_FREQ_500 => CRM_CORE_CLK_FREQ_500,
        CRM_USER_CLK_FREQ    => CRM_USER_CLK_FREQ_STRING,
        DNSTREAM_LINK_NUM    => DNSTREAM_LINK_NUM_STRING,
        GEN3_PCS_AUTO_REALIGN => GEN3_PCS_AUTO_REALIGN_STRING,
        GEN3_PCS_RX_ELECIDLE_INTERNAL => GEN3_PCS_RX_ELECIDLE_INTERNAL,
        LL_ACK_TIMEOUT       => LL_ACK_TIMEOUT_STRING,
        LL_ACK_TIMEOUT_EN    => LL_ACK_TIMEOUT_EN,
        LL_ACK_TIMEOUT_FUNC  => LL_ACK_TIMEOUT_FUNC,
        LL_CPL_FC_UPDATE_TIMER => LL_CPL_FC_UPDATE_TIMER_STRING,
        LL_CPL_FC_UPDATE_TIMER_OVERRIDE => LL_CPL_FC_UPDATE_TIMER_OVERRIDE,
        LL_FC_UPDATE_TIMER   => LL_FC_UPDATE_TIMER_STRING,
        LL_FC_UPDATE_TIMER_OVERRIDE => LL_FC_UPDATE_TIMER_OVERRIDE,
        LL_NP_FC_UPDATE_TIMER => LL_NP_FC_UPDATE_TIMER_STRING,
        LL_NP_FC_UPDATE_TIMER_OVERRIDE => LL_NP_FC_UPDATE_TIMER_OVERRIDE,
        LL_P_FC_UPDATE_TIMER => LL_P_FC_UPDATE_TIMER_STRING,
        LL_P_FC_UPDATE_TIMER_OVERRIDE => LL_P_FC_UPDATE_TIMER_OVERRIDE,
        LL_REPLAY_TIMEOUT    => LL_REPLAY_TIMEOUT_STRING,
        LL_REPLAY_TIMEOUT_EN => LL_REPLAY_TIMEOUT_EN,
        LL_REPLAY_TIMEOUT_FUNC => LL_REPLAY_TIMEOUT_FUNC,
        LTR_TX_MESSAGE_MINIMUM_INTERVAL => LTR_TX_MESSAGE_MINIMUM_INTERVAL_STRING,
        LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE => LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE,
        LTR_TX_MESSAGE_ON_LTR_ENABLE => LTR_TX_MESSAGE_ON_LTR_ENABLE,
        PF0_AER_CAP_ECRC_CHECK_CAPABLE => PF0_AER_CAP_ECRC_CHECK_CAPABLE,
        PF0_AER_CAP_ECRC_GEN_CAPABLE => PF0_AER_CAP_ECRC_GEN_CAPABLE,
        PF0_AER_CAP_NEXTPTR  => PF0_AER_CAP_NEXTPTR_STRING,
        PF0_ARI_CAP_NEXTPTR  => PF0_ARI_CAP_NEXTPTR_STRING,
        PF0_ARI_CAP_NEXT_FUNC => PF0_ARI_CAP_NEXT_FUNC_STRING,
        PF0_ARI_CAP_VER      => PF0_ARI_CAP_VER_STRING,
        PF0_BAR0_APERTURE_SIZE => PF0_BAR0_APERTURE_SIZE_STRING,
        PF0_BAR0_CONTROL     => PF0_BAR0_CONTROL_STRING,
        PF0_BAR1_APERTURE_SIZE => PF0_BAR1_APERTURE_SIZE_STRING,
        PF0_BAR1_CONTROL     => PF0_BAR1_CONTROL_STRING,
        PF0_BAR2_APERTURE_SIZE => PF0_BAR2_APERTURE_SIZE_STRING,
        PF0_BAR2_CONTROL     => PF0_BAR2_CONTROL_STRING,
        PF0_BAR3_APERTURE_SIZE => PF0_BAR3_APERTURE_SIZE_STRING,
        PF0_BAR3_CONTROL     => PF0_BAR3_CONTROL_STRING,
        PF0_BAR4_APERTURE_SIZE => PF0_BAR4_APERTURE_SIZE_STRING,
        PF0_BAR4_CONTROL     => PF0_BAR4_CONTROL_STRING,
        PF0_BAR5_APERTURE_SIZE => PF0_BAR5_APERTURE_SIZE_STRING,
        PF0_BAR5_CONTROL     => PF0_BAR5_CONTROL_STRING,
        PF0_BIST_REGISTER    => PF0_BIST_REGISTER_STRING,
        PF0_CAPABILITY_POINTER => PF0_CAPABILITY_POINTER_STRING,
        PF0_CLASS_CODE       => PF0_CLASS_CODE_STRING,
        PF0_DEVICE_ID        => PF0_DEVICE_ID_STRING,
        PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT => PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT,
        PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT => PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT,
        PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT => PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT,
        PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE => PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE,
        PF0_DEV_CAP2_LTR_SUPPORT => PF0_DEV_CAP2_LTR_SUPPORT,
        PF0_DEV_CAP2_OBFF_SUPPORT => PF0_DEV_CAP2_OBFF_SUPPORT_STRING,
        PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT => PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT,
        PF0_DEV_CAP_ENDPOINT_L0S_LATENCY => PF0_DEV_CAP_ENDPOINT_L0S_LATENCY,
        PF0_DEV_CAP_ENDPOINT_L1_LATENCY => PF0_DEV_CAP_ENDPOINT_L1_LATENCY,
        PF0_DEV_CAP_EXT_TAG_SUPPORTED => PF0_DEV_CAP_EXT_TAG_SUPPORTED,
        PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE => PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE,
        PF0_DEV_CAP_MAX_PAYLOAD_SIZE => PF0_DEV_CAP_MAX_PAYLOAD_SIZE_STRING,
        PF0_DPA_CAP_NEXTPTR  => PF0_DPA_CAP_NEXTPTR_STRING,
        PF0_DPA_CAP_SUB_STATE_CONTROL => PF0_DPA_CAP_SUB_STATE_CONTROL_STRING,
        PF0_DPA_CAP_SUB_STATE_CONTROL_EN => PF0_DPA_CAP_SUB_STATE_CONTROL_EN,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRING,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRING,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRING,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRING,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRING,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRING,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRING,
        PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 => PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRING,
        PF0_DPA_CAP_VER      => PF0_DPA_CAP_VER_STRING,
        PF0_DSN_CAP_NEXTPTR  => PF0_DSN_CAP_NEXTPTR_STRING,
        PF0_EXPANSION_ROM_APERTURE_SIZE => PF0_EXPANSION_ROM_APERTURE_SIZE_STRING,
        PF0_EXPANSION_ROM_ENABLE => PF0_EXPANSION_ROM_ENABLE,
        PF0_INTERRUPT_LINE   => PF0_INTERRUPT_LINE_STRING,
        PF0_INTERRUPT_PIN    => PF0_INTERRUPT_PIN_STRING,
        PF0_LINK_CAP_ASPM_SUPPORT => PF0_LINK_CAP_ASPM_SUPPORT,
        PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 => PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1,
        PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 => PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2,
        PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 => PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3,
        PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 => PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1,
        PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 => PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2,
        PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 => PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3,
        PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 => PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1,
        PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 => PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2,
        PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 => PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3,
        PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 => PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1,
        PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 => PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2,
        PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 => PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3,
        PF0_LINK_STATUS_SLOT_CLOCK_CONFIG => PF0_LINK_STATUS_SLOT_CLOCK_CONFIG,
        PF0_LTR_CAP_MAX_NOSNOOP_LAT => PF0_LTR_CAP_MAX_NOSNOOP_LAT_STRING,
        PF0_LTR_CAP_MAX_SNOOP_LAT => PF0_LTR_CAP_MAX_SNOOP_LAT_STRING,
        PF0_LTR_CAP_NEXTPTR  => PF0_LTR_CAP_NEXTPTR_STRING,
        PF0_LTR_CAP_VER      => PF0_LTR_CAP_VER_STRING,
        PF0_MSIX_CAP_NEXTPTR => PF0_MSIX_CAP_NEXTPTR_STRING,
        PF0_MSIX_CAP_PBA_BIR => PF0_MSIX_CAP_PBA_BIR,
        PF0_MSIX_CAP_PBA_OFFSET => PF0_MSIX_CAP_PBA_OFFSET_STRING,
        PF0_MSIX_CAP_TABLE_BIR => PF0_MSIX_CAP_TABLE_BIR,
        PF0_MSIX_CAP_TABLE_OFFSET => PF0_MSIX_CAP_TABLE_OFFSET_STRING,
        PF0_MSIX_CAP_TABLE_SIZE => PF0_MSIX_CAP_TABLE_SIZE_STRING,
        PF0_MSI_CAP_MULTIMSGCAP => PF0_MSI_CAP_MULTIMSGCAP,
        PF0_MSI_CAP_NEXTPTR  => PF0_MSI_CAP_NEXTPTR_STRING,
        PF0_PB_CAP_NEXTPTR   => PF0_PB_CAP_NEXTPTR_STRING,
        PF0_PB_CAP_SYSTEM_ALLOCATED => PF0_PB_CAP_SYSTEM_ALLOCATED,
        PF0_PB_CAP_VER       => PF0_PB_CAP_VER_STRING,
        PF0_PM_CAP_ID        => PF0_PM_CAP_ID_STRING,
        PF0_PM_CAP_NEXTPTR   => PF0_PM_CAP_NEXTPTR_STRING,
        PF0_PM_CAP_PMESUPPORT_D0 => PF0_PM_CAP_PMESUPPORT_D0,
        PF0_PM_CAP_PMESUPPORT_D1 => PF0_PM_CAP_PMESUPPORT_D1,
        PF0_PM_CAP_PMESUPPORT_D3HOT => PF0_PM_CAP_PMESUPPORT_D3HOT,
        PF0_PM_CAP_SUPP_D1_STATE => PF0_PM_CAP_SUPP_D1_STATE,
        PF0_PM_CAP_VER_ID    => PF0_PM_CAP_VER_ID_STRING,
        PF0_PM_CSR_NOSOFTRESET => PF0_PM_CSR_NOSOFTRESET,
        PF0_RBAR_CAP_ENABLE  => PF0_RBAR_CAP_ENABLE,
        PF0_RBAR_CAP_INDEX0  => PF0_RBAR_CAP_INDEX0_STRING,
        PF0_RBAR_CAP_INDEX1  => PF0_RBAR_CAP_INDEX1_STRING,
        PF0_RBAR_CAP_INDEX2  => PF0_RBAR_CAP_INDEX2_STRING,
        PF0_RBAR_CAP_NEXTPTR => PF0_RBAR_CAP_NEXTPTR_STRING,
        PF0_RBAR_CAP_SIZE0   => PF0_RBAR_CAP_SIZE0_STRING,
        PF0_RBAR_CAP_SIZE1   => PF0_RBAR_CAP_SIZE1_STRING,
        PF0_RBAR_CAP_SIZE2   => PF0_RBAR_CAP_SIZE2_STRING,
        PF0_RBAR_CAP_VER     => PF0_RBAR_CAP_VER_STRING,
        PF0_RBAR_NUM         => PF0_RBAR_NUM_STRING,
        PF0_REVISION_ID      => PF0_REVISION_ID_STRING,
        PF0_SRIOV_BAR0_APERTURE_SIZE => PF0_SRIOV_BAR0_APERTURE_SIZE_STRING,
        PF0_SRIOV_BAR0_CONTROL => PF0_SRIOV_BAR0_CONTROL_STRING,
        PF0_SRIOV_BAR1_APERTURE_SIZE => PF0_SRIOV_BAR1_APERTURE_SIZE_STRING,
        PF0_SRIOV_BAR1_CONTROL => PF0_SRIOV_BAR1_CONTROL_STRING,
        PF0_SRIOV_BAR2_APERTURE_SIZE => PF0_SRIOV_BAR2_APERTURE_SIZE_STRING,
        PF0_SRIOV_BAR2_CONTROL => PF0_SRIOV_BAR2_CONTROL_STRING,
        PF0_SRIOV_BAR3_APERTURE_SIZE => PF0_SRIOV_BAR3_APERTURE_SIZE_STRING,
        PF0_SRIOV_BAR3_CONTROL => PF0_SRIOV_BAR3_CONTROL_STRING,
        PF0_SRIOV_BAR4_APERTURE_SIZE => PF0_SRIOV_BAR4_APERTURE_SIZE_STRING,
        PF0_SRIOV_BAR4_CONTROL => PF0_SRIOV_BAR4_CONTROL_STRING,
        PF0_SRIOV_BAR5_APERTURE_SIZE => PF0_SRIOV_BAR5_APERTURE_SIZE_STRING,
        PF0_SRIOV_BAR5_CONTROL => PF0_SRIOV_BAR5_CONTROL_STRING,
        PF0_SRIOV_CAP_INITIAL_VF => PF0_SRIOV_CAP_INITIAL_VF_STRING,
        PF0_SRIOV_CAP_NEXTPTR => PF0_SRIOV_CAP_NEXTPTR_STRING,
        PF0_SRIOV_CAP_TOTAL_VF => PF0_SRIOV_CAP_TOTAL_VF_STRING,
        PF0_SRIOV_CAP_VER    => PF0_SRIOV_CAP_VER_STRING,
        PF0_SRIOV_FIRST_VF_OFFSET => PF0_SRIOV_FIRST_VF_OFFSET_STRING,
        PF0_SRIOV_FUNC_DEP_LINK => PF0_SRIOV_FUNC_DEP_LINK_STRING,
        PF0_SRIOV_SUPPORTED_PAGE_SIZE => PF0_SRIOV_SUPPORTED_PAGE_SIZE_STRING,
        PF0_SRIOV_VF_DEVICE_ID => PF0_SRIOV_VF_DEVICE_ID_STRING,
        PF0_SUBSYSTEM_ID     => PF0_SUBSYSTEM_ID_STRING,
        PF0_TPHR_CAP_DEV_SPECIFIC_MODE => PF0_TPHR_CAP_DEV_SPECIFIC_MODE,
        PF0_TPHR_CAP_ENABLE  => PF0_TPHR_CAP_ENABLE,
        PF0_TPHR_CAP_INT_VEC_MODE => PF0_TPHR_CAP_INT_VEC_MODE,
        PF0_TPHR_CAP_NEXTPTR => PF0_TPHR_CAP_NEXTPTR_STRING,
        PF0_TPHR_CAP_ST_MODE_SEL => PF0_TPHR_CAP_ST_MODE_SEL_STRING,
        PF0_TPHR_CAP_ST_TABLE_LOC => PF0_TPHR_CAP_ST_TABLE_LOC_STRING,
        PF0_TPHR_CAP_ST_TABLE_SIZE => PF0_TPHR_CAP_ST_TABLE_SIZE_STRING,
        PF0_TPHR_CAP_VER     => PF0_TPHR_CAP_VER_STRING,
        PF0_VC_CAP_NEXTPTR   => PF0_VC_CAP_NEXTPTR_STRING,
        PF0_VC_CAP_VER       => PF0_VC_CAP_VER_STRING,
        PF1_AER_CAP_ECRC_CHECK_CAPABLE => PF1_AER_CAP_ECRC_CHECK_CAPABLE,
        PF1_AER_CAP_ECRC_GEN_CAPABLE => PF1_AER_CAP_ECRC_GEN_CAPABLE,
        PF1_AER_CAP_NEXTPTR  => PF1_AER_CAP_NEXTPTR_STRING,
        PF1_ARI_CAP_NEXTPTR  => PF1_ARI_CAP_NEXTPTR_STRING,
        PF1_ARI_CAP_NEXT_FUNC => PF1_ARI_CAP_NEXT_FUNC_STRING,
        PF1_BAR0_APERTURE_SIZE => PF1_BAR0_APERTURE_SIZE_STRING,
        PF1_BAR0_CONTROL     => PF1_BAR0_CONTROL_STRING,
        PF1_BAR1_APERTURE_SIZE => PF1_BAR1_APERTURE_SIZE_STRING,
        PF1_BAR1_CONTROL     => PF1_BAR1_CONTROL_STRING,
        PF1_BAR2_APERTURE_SIZE => PF1_BAR2_APERTURE_SIZE_STRING,
        PF1_BAR2_CONTROL     => PF1_BAR2_CONTROL_STRING,
        PF1_BAR3_APERTURE_SIZE => PF1_BAR3_APERTURE_SIZE_STRING,
        PF1_BAR3_CONTROL     => PF1_BAR3_CONTROL_STRING,
        PF1_BAR4_APERTURE_SIZE => PF1_BAR4_APERTURE_SIZE_STRING,
        PF1_BAR4_CONTROL     => PF1_BAR4_CONTROL_STRING,
        PF1_BAR5_APERTURE_SIZE => PF1_BAR5_APERTURE_SIZE_STRING,
        PF1_BAR5_CONTROL     => PF1_BAR5_CONTROL_STRING,
        PF1_BIST_REGISTER    => PF1_BIST_REGISTER_STRING,
        PF1_CAPABILITY_POINTER => PF1_CAPABILITY_POINTER_STRING,
        PF1_CLASS_CODE       => PF1_CLASS_CODE_STRING,
        PF1_DEVICE_ID        => PF1_DEVICE_ID_STRING,
        PF1_DEV_CAP_MAX_PAYLOAD_SIZE => PF1_DEV_CAP_MAX_PAYLOAD_SIZE_STRING,
        PF1_DPA_CAP_NEXTPTR  => PF1_DPA_CAP_NEXTPTR_STRING,
        PF1_DPA_CAP_SUB_STATE_CONTROL => PF1_DPA_CAP_SUB_STATE_CONTROL_STRING,
        PF1_DPA_CAP_SUB_STATE_CONTROL_EN => PF1_DPA_CAP_SUB_STATE_CONTROL_EN,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0_STRING,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1_STRING,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2_STRING,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3_STRING,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4_STRING,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5_STRING,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6_STRING,
        PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 => PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7_STRING,
        PF1_DPA_CAP_VER      => PF1_DPA_CAP_VER_STRING,
        PF1_DSN_CAP_NEXTPTR  => PF1_DSN_CAP_NEXTPTR_STRING,
        PF1_EXPANSION_ROM_APERTURE_SIZE => PF1_EXPANSION_ROM_APERTURE_SIZE_STRING,
        PF1_EXPANSION_ROM_ENABLE => PF1_EXPANSION_ROM_ENABLE,
        PF1_INTERRUPT_LINE   => PF1_INTERRUPT_LINE_STRING,
        PF1_INTERRUPT_PIN    => PF1_INTERRUPT_PIN_STRING,
        PF1_MSIX_CAP_NEXTPTR => PF1_MSIX_CAP_NEXTPTR_STRING,
        PF1_MSIX_CAP_PBA_BIR => PF1_MSIX_CAP_PBA_BIR,
        PF1_MSIX_CAP_PBA_OFFSET => PF1_MSIX_CAP_PBA_OFFSET_STRING,
        PF1_MSIX_CAP_TABLE_BIR => PF1_MSIX_CAP_TABLE_BIR,
        PF1_MSIX_CAP_TABLE_OFFSET => PF1_MSIX_CAP_TABLE_OFFSET_STRING,
        PF1_MSIX_CAP_TABLE_SIZE => PF1_MSIX_CAP_TABLE_SIZE_STRING,
        PF1_MSI_CAP_MULTIMSGCAP => PF1_MSI_CAP_MULTIMSGCAP,
        PF1_MSI_CAP_NEXTPTR  => PF1_MSI_CAP_NEXTPTR_STRING,
        PF1_PB_CAP_NEXTPTR   => PF1_PB_CAP_NEXTPTR_STRING,
        PF1_PB_CAP_SYSTEM_ALLOCATED => PF1_PB_CAP_SYSTEM_ALLOCATED,
        PF1_PB_CAP_VER       => PF1_PB_CAP_VER_STRING,
        PF1_PM_CAP_ID        => PF1_PM_CAP_ID_STRING,
        PF1_PM_CAP_NEXTPTR   => PF1_PM_CAP_NEXTPTR_STRING,
        PF1_PM_CAP_VER_ID    => PF1_PM_CAP_VER_ID_STRING,
        PF1_RBAR_CAP_ENABLE  => PF1_RBAR_CAP_ENABLE,
        PF1_RBAR_CAP_INDEX0  => PF1_RBAR_CAP_INDEX0_STRING,
        PF1_RBAR_CAP_INDEX1  => PF1_RBAR_CAP_INDEX1_STRING,
        PF1_RBAR_CAP_INDEX2  => PF1_RBAR_CAP_INDEX2_STRING,
        PF1_RBAR_CAP_NEXTPTR => PF1_RBAR_CAP_NEXTPTR_STRING,
        PF1_RBAR_CAP_SIZE0   => PF1_RBAR_CAP_SIZE0_STRING,
        PF1_RBAR_CAP_SIZE1   => PF1_RBAR_CAP_SIZE1_STRING,
        PF1_RBAR_CAP_SIZE2   => PF1_RBAR_CAP_SIZE2_STRING,
        PF1_RBAR_CAP_VER     => PF1_RBAR_CAP_VER_STRING,
        PF1_RBAR_NUM         => PF1_RBAR_NUM_STRING,
        PF1_REVISION_ID      => PF1_REVISION_ID_STRING,
        PF1_SRIOV_BAR0_APERTURE_SIZE => PF1_SRIOV_BAR0_APERTURE_SIZE_STRING,
        PF1_SRIOV_BAR0_CONTROL => PF1_SRIOV_BAR0_CONTROL_STRING,
        PF1_SRIOV_BAR1_APERTURE_SIZE => PF1_SRIOV_BAR1_APERTURE_SIZE_STRING,
        PF1_SRIOV_BAR1_CONTROL => PF1_SRIOV_BAR1_CONTROL_STRING,
        PF1_SRIOV_BAR2_APERTURE_SIZE => PF1_SRIOV_BAR2_APERTURE_SIZE_STRING,
        PF1_SRIOV_BAR2_CONTROL => PF1_SRIOV_BAR2_CONTROL_STRING,
        PF1_SRIOV_BAR3_APERTURE_SIZE => PF1_SRIOV_BAR3_APERTURE_SIZE_STRING,
        PF1_SRIOV_BAR3_CONTROL => PF1_SRIOV_BAR3_CONTROL_STRING,
        PF1_SRIOV_BAR4_APERTURE_SIZE => PF1_SRIOV_BAR4_APERTURE_SIZE_STRING,
        PF1_SRIOV_BAR4_CONTROL => PF1_SRIOV_BAR4_CONTROL_STRING,
        PF1_SRIOV_BAR5_APERTURE_SIZE => PF1_SRIOV_BAR5_APERTURE_SIZE_STRING,
        PF1_SRIOV_BAR5_CONTROL => PF1_SRIOV_BAR5_CONTROL_STRING,
        PF1_SRIOV_CAP_INITIAL_VF => PF1_SRIOV_CAP_INITIAL_VF_STRING,
        PF1_SRIOV_CAP_NEXTPTR => PF1_SRIOV_CAP_NEXTPTR_STRING,
        PF1_SRIOV_CAP_TOTAL_VF => PF1_SRIOV_CAP_TOTAL_VF_STRING,
        PF1_SRIOV_CAP_VER    => PF1_SRIOV_CAP_VER_STRING,
        PF1_SRIOV_FIRST_VF_OFFSET => PF1_SRIOV_FIRST_VF_OFFSET_STRING,
        PF1_SRIOV_FUNC_DEP_LINK => PF1_SRIOV_FUNC_DEP_LINK_STRING,
        PF1_SRIOV_SUPPORTED_PAGE_SIZE => PF1_SRIOV_SUPPORTED_PAGE_SIZE_STRING,
        PF1_SRIOV_VF_DEVICE_ID => PF1_SRIOV_VF_DEVICE_ID_STRING,
        PF1_SUBSYSTEM_ID     => PF1_SUBSYSTEM_ID_STRING,
        PF1_TPHR_CAP_DEV_SPECIFIC_MODE => PF1_TPHR_CAP_DEV_SPECIFIC_MODE,
        PF1_TPHR_CAP_ENABLE  => PF1_TPHR_CAP_ENABLE,
        PF1_TPHR_CAP_INT_VEC_MODE => PF1_TPHR_CAP_INT_VEC_MODE,
        PF1_TPHR_CAP_NEXTPTR => PF1_TPHR_CAP_NEXTPTR_STRING,
        PF1_TPHR_CAP_ST_MODE_SEL => PF1_TPHR_CAP_ST_MODE_SEL_STRING,
        PF1_TPHR_CAP_ST_TABLE_LOC => PF1_TPHR_CAP_ST_TABLE_LOC_STRING,
        PF1_TPHR_CAP_ST_TABLE_SIZE => PF1_TPHR_CAP_ST_TABLE_SIZE_STRING,
        PF1_TPHR_CAP_VER     => PF1_TPHR_CAP_VER_STRING,
        PL_DISABLE_EI_INFER_IN_L0 => PL_DISABLE_EI_INFER_IN_L0,
        PL_DISABLE_GEN3_DC_BALANCE => PL_DISABLE_GEN3_DC_BALANCE,
        PL_DISABLE_SCRAMBLING => PL_DISABLE_SCRAMBLING,
        PL_DISABLE_UPCONFIG_CAPABLE => PL_DISABLE_UPCONFIG_CAPABLE,
        PL_EQ_ADAPT_DISABLE_COEFF_CHECK => PL_EQ_ADAPT_DISABLE_COEFF_CHECK,
        PL_EQ_ADAPT_DISABLE_PRESET_CHECK => PL_EQ_ADAPT_DISABLE_PRESET_CHECK,
        PL_EQ_ADAPT_ITER_COUNT => PL_EQ_ADAPT_ITER_COUNT_STRING,
        PL_EQ_ADAPT_REJECT_RETRY_COUNT => PL_EQ_ADAPT_REJECT_RETRY_COUNT_STRING,
        PL_EQ_BYPASS_PHASE23 => PL_EQ_BYPASS_PHASE23,
        PL_EQ_SHORT_ADAPT_PHASE => PL_EQ_SHORT_ADAPT_PHASE,
        PL_LANE0_EQ_CONTROL  => PL_LANE0_EQ_CONTROL_STRING,
        PL_LANE1_EQ_CONTROL  => PL_LANE1_EQ_CONTROL_STRING,
        PL_LANE2_EQ_CONTROL  => PL_LANE2_EQ_CONTROL_STRING,
        PL_LANE3_EQ_CONTROL  => PL_LANE3_EQ_CONTROL_STRING,
        PL_LANE4_EQ_CONTROL  => PL_LANE4_EQ_CONTROL_STRING,
        PL_LANE5_EQ_CONTROL  => PL_LANE5_EQ_CONTROL_STRING,
        PL_LANE6_EQ_CONTROL  => PL_LANE6_EQ_CONTROL_STRING,
        PL_LANE7_EQ_CONTROL  => PL_LANE7_EQ_CONTROL_STRING,
        PL_LINK_CAP_MAX_LINK_SPEED => PL_LINK_CAP_MAX_LINK_SPEED_STRING,
        PL_LINK_CAP_MAX_LINK_WIDTH => PL_LINK_CAP_MAX_LINK_WIDTH_STRING,
        PL_N_FTS_COMCLK_GEN1 => PL_N_FTS_COMCLK_GEN1,
        PL_N_FTS_COMCLK_GEN2 => PL_N_FTS_COMCLK_GEN2,
        PL_N_FTS_COMCLK_GEN3 => PL_N_FTS_COMCLK_GEN3,
        PL_N_FTS_GEN1        => PL_N_FTS_GEN1,
        PL_N_FTS_GEN2        => PL_N_FTS_GEN2,
        PL_N_FTS_GEN3        => PL_N_FTS_GEN3,
        PL_SIM_FAST_LINK_TRAINING => PL_SIM_FAST_LINK_TRAINING,
        PL_UPSTREAM_FACING   => PL_UPSTREAM_FACING,
        PM_ASPML0S_TIMEOUT   => PM_ASPML0S_TIMEOUT_STRING,
        PM_ASPML1_ENTRY_DELAY => PM_ASPML1_ENTRY_DELAY_STRING,
        PM_ENABLE_SLOT_POWER_CAPTURE => PM_ENABLE_SLOT_POWER_CAPTURE,
        PM_L1_REENTRY_DELAY  => PM_L1_REENTRY_DELAY_STRING,
        PM_PME_SERVICE_TIMEOUT_DELAY => PM_PME_SERVICE_TIMEOUT_DELAY_STRING,
        PM_PME_TURNOFF_ACK_DELAY => PM_PME_TURNOFF_ACK_DELAY_STRING,
        SIM_VERSION          => SIM_VERSION,
        SPARE_BIT0           => SPARE_BIT0,
        SPARE_BIT1           => SPARE_BIT1,
        SPARE_BIT2           => SPARE_BIT2,
        SPARE_BIT3           => SPARE_BIT3,
        SPARE_BIT4           => SPARE_BIT4,
        SPARE_BIT5           => SPARE_BIT5,
        SPARE_BIT6           => SPARE_BIT6,
        SPARE_BIT7           => SPARE_BIT7,
        SPARE_BIT8           => SPARE_BIT8,
        SPARE_BYTE0          => SPARE_BYTE0_STRING,
        SPARE_BYTE1          => SPARE_BYTE1_STRING,
        SPARE_BYTE2          => SPARE_BYTE2_STRING,
        SPARE_BYTE3          => SPARE_BYTE3_STRING,
        SPARE_WORD0          => SPARE_WORD0_STRING,
        SPARE_WORD1          => SPARE_WORD1_STRING,
        SPARE_WORD2          => SPARE_WORD2_STRING,
        SPARE_WORD3          => SPARE_WORD3_STRING,
        SRIOV_CAP_ENABLE     => SRIOV_CAP_ENABLE,
        TL_COMPL_TIMEOUT_REG0 => TL_COMPL_TIMEOUT_REG0_STRING,
        TL_COMPL_TIMEOUT_REG1 => TL_COMPL_TIMEOUT_REG1_STRING,
        TL_CREDITS_CD        => TL_CREDITS_CD_STRING,
        TL_CREDITS_CH        => TL_CREDITS_CH_STRING,
        TL_CREDITS_NPD       => TL_CREDITS_NPD_STRING,
        TL_CREDITS_NPH       => TL_CREDITS_NPH_STRING,
        TL_CREDITS_PD        => TL_CREDITS_PD_STRING,
        TL_CREDITS_PH        => TL_CREDITS_PH_STRING,
        TL_ENABLE_MESSAGE_RID_CHECK_ENABLE => TL_ENABLE_MESSAGE_RID_CHECK_ENABLE,
        TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE => TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE,
        TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE => TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE,
        TL_LEGACY_MODE_ENABLE => TL_LEGACY_MODE_ENABLE,
        TL_PF_ENABLE_REG     => TL_PF_ENABLE_REG,
        TL_TAG_MGMT_ENABLE   => TL_TAG_MGMT_ENABLE,
        VF0_ARI_CAP_NEXTPTR  => VF0_ARI_CAP_NEXTPTR_STRING,
        VF0_CAPABILITY_POINTER => VF0_CAPABILITY_POINTER_STRING,
        VF0_MSIX_CAP_PBA_BIR => VF0_MSIX_CAP_PBA_BIR,
        VF0_MSIX_CAP_PBA_OFFSET => VF0_MSIX_CAP_PBA_OFFSET_STRING,
        VF0_MSIX_CAP_TABLE_BIR => VF0_MSIX_CAP_TABLE_BIR,
        VF0_MSIX_CAP_TABLE_OFFSET => VF0_MSIX_CAP_TABLE_OFFSET_STRING,
        VF0_MSIX_CAP_TABLE_SIZE => VF0_MSIX_CAP_TABLE_SIZE_STRING,
        VF0_MSI_CAP_MULTIMSGCAP => VF0_MSI_CAP_MULTIMSGCAP,
        VF0_PM_CAP_ID        => VF0_PM_CAP_ID_STRING,
        VF0_PM_CAP_NEXTPTR   => VF0_PM_CAP_NEXTPTR_STRING,
        VF0_PM_CAP_VER_ID    => VF0_PM_CAP_VER_ID_STRING,
        VF0_TPHR_CAP_DEV_SPECIFIC_MODE => VF0_TPHR_CAP_DEV_SPECIFIC_MODE,
        VF0_TPHR_CAP_ENABLE  => VF0_TPHR_CAP_ENABLE,
        VF0_TPHR_CAP_INT_VEC_MODE => VF0_TPHR_CAP_INT_VEC_MODE,
        VF0_TPHR_CAP_NEXTPTR => VF0_TPHR_CAP_NEXTPTR_STRING,
        VF0_TPHR_CAP_ST_MODE_SEL => VF0_TPHR_CAP_ST_MODE_SEL_STRING,
        VF0_TPHR_CAP_ST_TABLE_LOC => VF0_TPHR_CAP_ST_TABLE_LOC_STRING,
        VF0_TPHR_CAP_ST_TABLE_SIZE => VF0_TPHR_CAP_ST_TABLE_SIZE_STRING,
        VF0_TPHR_CAP_VER     => VF0_TPHR_CAP_VER_STRING,
        VF1_ARI_CAP_NEXTPTR  => VF1_ARI_CAP_NEXTPTR_STRING,
        VF1_MSIX_CAP_PBA_BIR => VF1_MSIX_CAP_PBA_BIR,
        VF1_MSIX_CAP_PBA_OFFSET => VF1_MSIX_CAP_PBA_OFFSET_STRING,
        VF1_MSIX_CAP_TABLE_BIR => VF1_MSIX_CAP_TABLE_BIR,
        VF1_MSIX_CAP_TABLE_OFFSET => VF1_MSIX_CAP_TABLE_OFFSET_STRING,
        VF1_MSIX_CAP_TABLE_SIZE => VF1_MSIX_CAP_TABLE_SIZE_STRING,
        VF1_MSI_CAP_MULTIMSGCAP => VF1_MSI_CAP_MULTIMSGCAP,
        VF1_PM_CAP_ID        => VF1_PM_CAP_ID_STRING,
        VF1_PM_CAP_NEXTPTR   => VF1_PM_CAP_NEXTPTR_STRING,
        VF1_PM_CAP_VER_ID    => VF1_PM_CAP_VER_ID_STRING,
        VF1_TPHR_CAP_DEV_SPECIFIC_MODE => VF1_TPHR_CAP_DEV_SPECIFIC_MODE,
        VF1_TPHR_CAP_ENABLE  => VF1_TPHR_CAP_ENABLE,
        VF1_TPHR_CAP_INT_VEC_MODE => VF1_TPHR_CAP_INT_VEC_MODE,
        VF1_TPHR_CAP_NEXTPTR => VF1_TPHR_CAP_NEXTPTR_STRING,
        VF1_TPHR_CAP_ST_MODE_SEL => VF1_TPHR_CAP_ST_MODE_SEL_STRING,
        VF1_TPHR_CAP_ST_TABLE_LOC => VF1_TPHR_CAP_ST_TABLE_LOC_STRING,
        VF1_TPHR_CAP_ST_TABLE_SIZE => VF1_TPHR_CAP_ST_TABLE_SIZE_STRING,
        VF1_TPHR_CAP_VER     => VF1_TPHR_CAP_VER_STRING,
        VF2_ARI_CAP_NEXTPTR  => VF2_ARI_CAP_NEXTPTR_STRING,
        VF2_MSIX_CAP_PBA_BIR => VF2_MSIX_CAP_PBA_BIR,
        VF2_MSIX_CAP_PBA_OFFSET => VF2_MSIX_CAP_PBA_OFFSET_STRING,
        VF2_MSIX_CAP_TABLE_BIR => VF2_MSIX_CAP_TABLE_BIR,
        VF2_MSIX_CAP_TABLE_OFFSET => VF2_MSIX_CAP_TABLE_OFFSET_STRING,
        VF2_MSIX_CAP_TABLE_SIZE => VF2_MSIX_CAP_TABLE_SIZE_STRING,
        VF2_MSI_CAP_MULTIMSGCAP => VF2_MSI_CAP_MULTIMSGCAP,
        VF2_PM_CAP_ID        => VF2_PM_CAP_ID_STRING,
        VF2_PM_CAP_NEXTPTR   => VF2_PM_CAP_NEXTPTR_STRING,
        VF2_PM_CAP_VER_ID    => VF2_PM_CAP_VER_ID_STRING,
        VF2_TPHR_CAP_DEV_SPECIFIC_MODE => VF2_TPHR_CAP_DEV_SPECIFIC_MODE,
        VF2_TPHR_CAP_ENABLE  => VF2_TPHR_CAP_ENABLE,
        VF2_TPHR_CAP_INT_VEC_MODE => VF2_TPHR_CAP_INT_VEC_MODE,
        VF2_TPHR_CAP_NEXTPTR => VF2_TPHR_CAP_NEXTPTR_STRING,
        VF2_TPHR_CAP_ST_MODE_SEL => VF2_TPHR_CAP_ST_MODE_SEL_STRING,
        VF2_TPHR_CAP_ST_TABLE_LOC => VF2_TPHR_CAP_ST_TABLE_LOC_STRING,
        VF2_TPHR_CAP_ST_TABLE_SIZE => VF2_TPHR_CAP_ST_TABLE_SIZE_STRING,
        VF2_TPHR_CAP_VER     => VF2_TPHR_CAP_VER_STRING,
        VF3_ARI_CAP_NEXTPTR  => VF3_ARI_CAP_NEXTPTR_STRING,
        VF3_MSIX_CAP_PBA_BIR => VF3_MSIX_CAP_PBA_BIR,
        VF3_MSIX_CAP_PBA_OFFSET => VF3_MSIX_CAP_PBA_OFFSET_STRING,
        VF3_MSIX_CAP_TABLE_BIR => VF3_MSIX_CAP_TABLE_BIR,
        VF3_MSIX_CAP_TABLE_OFFSET => VF3_MSIX_CAP_TABLE_OFFSET_STRING,
        VF3_MSIX_CAP_TABLE_SIZE => VF3_MSIX_CAP_TABLE_SIZE_STRING,
        VF3_MSI_CAP_MULTIMSGCAP => VF3_MSI_CAP_MULTIMSGCAP,
        VF3_PM_CAP_ID        => VF3_PM_CAP_ID_STRING,
        VF3_PM_CAP_NEXTPTR   => VF3_PM_CAP_NEXTPTR_STRING,
        VF3_PM_CAP_VER_ID    => VF3_PM_CAP_VER_ID_STRING,
        VF3_TPHR_CAP_DEV_SPECIFIC_MODE => VF3_TPHR_CAP_DEV_SPECIFIC_MODE,
        VF3_TPHR_CAP_ENABLE  => VF3_TPHR_CAP_ENABLE,
        VF3_TPHR_CAP_INT_VEC_MODE => VF3_TPHR_CAP_INT_VEC_MODE,
        VF3_TPHR_CAP_NEXTPTR => VF3_TPHR_CAP_NEXTPTR_STRING,
        VF3_TPHR_CAP_ST_MODE_SEL => VF3_TPHR_CAP_ST_MODE_SEL_STRING,
        VF3_TPHR_CAP_ST_TABLE_LOC => VF3_TPHR_CAP_ST_TABLE_LOC_STRING,
        VF3_TPHR_CAP_ST_TABLE_SIZE => VF3_TPHR_CAP_ST_TABLE_SIZE_STRING,
        VF3_TPHR_CAP_VER     => VF3_TPHR_CAP_VER_STRING,
        VF4_ARI_CAP_NEXTPTR  => VF4_ARI_CAP_NEXTPTR_STRING,
        VF4_MSIX_CAP_PBA_BIR => VF4_MSIX_CAP_PBA_BIR,
        VF4_MSIX_CAP_PBA_OFFSET => VF4_MSIX_CAP_PBA_OFFSET_STRING,
        VF4_MSIX_CAP_TABLE_BIR => VF4_MSIX_CAP_TABLE_BIR,
        VF4_MSIX_CAP_TABLE_OFFSET => VF4_MSIX_CAP_TABLE_OFFSET_STRING,
        VF4_MSIX_CAP_TABLE_SIZE => VF4_MSIX_CAP_TABLE_SIZE_STRING,
        VF4_MSI_CAP_MULTIMSGCAP => VF4_MSI_CAP_MULTIMSGCAP,
        VF4_PM_CAP_ID        => VF4_PM_CAP_ID_STRING,
        VF4_PM_CAP_NEXTPTR   => VF4_PM_CAP_NEXTPTR_STRING,
        VF4_PM_CAP_VER_ID    => VF4_PM_CAP_VER_ID_STRING,
        VF4_TPHR_CAP_DEV_SPECIFIC_MODE => VF4_TPHR_CAP_DEV_SPECIFIC_MODE,
        VF4_TPHR_CAP_ENABLE  => VF4_TPHR_CAP_ENABLE,
        VF4_TPHR_CAP_INT_VEC_MODE => VF4_TPHR_CAP_INT_VEC_MODE,
        VF4_TPHR_CAP_NEXTPTR => VF4_TPHR_CAP_NEXTPTR_STRING,
        VF4_TPHR_CAP_ST_MODE_SEL => VF4_TPHR_CAP_ST_MODE_SEL_STRING,
        VF4_TPHR_CAP_ST_TABLE_LOC => VF4_TPHR_CAP_ST_TABLE_LOC_STRING,
        VF4_TPHR_CAP_ST_TABLE_SIZE => VF4_TPHR_CAP_ST_TABLE_SIZE_STRING,
        VF4_TPHR_CAP_VER     => VF4_TPHR_CAP_VER_STRING,
        VF5_ARI_CAP_NEXTPTR  => VF5_ARI_CAP_NEXTPTR_STRING,
        VF5_MSIX_CAP_PBA_BIR => VF5_MSIX_CAP_PBA_BIR,
        VF5_MSIX_CAP_PBA_OFFSET => VF5_MSIX_CAP_PBA_OFFSET_STRING,
        VF5_MSIX_CAP_TABLE_BIR => VF5_MSIX_CAP_TABLE_BIR,
        VF5_MSIX_CAP_TABLE_OFFSET => VF5_MSIX_CAP_TABLE_OFFSET_STRING,
        VF5_MSIX_CAP_TABLE_SIZE => VF5_MSIX_CAP_TABLE_SIZE_STRING,
        VF5_MSI_CAP_MULTIMSGCAP => VF5_MSI_CAP_MULTIMSGCAP,
        VF5_PM_CAP_ID        => VF5_PM_CAP_ID_STRING,
        VF5_PM_CAP_NEXTPTR   => VF5_PM_CAP_NEXTPTR_STRING,
        VF5_PM_CAP_VER_ID    => VF5_PM_CAP_VER_ID_STRING,
        VF5_TPHR_CAP_DEV_SPECIFIC_MODE => VF5_TPHR_CAP_DEV_SPECIFIC_MODE,
        VF5_TPHR_CAP_ENABLE  => VF5_TPHR_CAP_ENABLE,
        VF5_TPHR_CAP_INT_VEC_MODE => VF5_TPHR_CAP_INT_VEC_MODE,
        VF5_TPHR_CAP_NEXTPTR => VF5_TPHR_CAP_NEXTPTR_STRING,
        VF5_TPHR_CAP_ST_MODE_SEL => VF5_TPHR_CAP_ST_MODE_SEL_STRING,
        VF5_TPHR_CAP_ST_TABLE_LOC => VF5_TPHR_CAP_ST_TABLE_LOC_STRING,
        VF5_TPHR_CAP_ST_TABLE_SIZE => VF5_TPHR_CAP_ST_TABLE_SIZE_STRING,
        VF5_TPHR_CAP_VER     => VF5_TPHR_CAP_VER_STRING
      )
      
      port map (
        CFGCURRENTSPEED      => CFGCURRENTSPEED_outdelay,
        CFGDPASUBSTATECHANGE => CFGDPASUBSTATECHANGE_outdelay,
        CFGERRCOROUT         => CFGERRCOROUT_outdelay,
        CFGERRFATALOUT       => CFGERRFATALOUT_outdelay,
        CFGERRNONFATALOUT    => CFGERRNONFATALOUT_outdelay,
        CFGEXTFUNCTIONNUMBER => CFGEXTFUNCTIONNUMBER_outdelay,
        CFGEXTREADRECEIVED   => CFGEXTREADRECEIVED_outdelay,
        CFGEXTREGISTERNUMBER => CFGEXTREGISTERNUMBER_outdelay,
        CFGEXTWRITEBYTEENABLE => CFGEXTWRITEBYTEENABLE_outdelay,
        CFGEXTWRITEDATA      => CFGEXTWRITEDATA_outdelay,
        CFGEXTWRITERECEIVED  => CFGEXTWRITERECEIVED_outdelay,
        CFGFCCPLD            => CFGFCCPLD_outdelay,
        CFGFCCPLH            => CFGFCCPLH_outdelay,
        CFGFCNPD             => CFGFCNPD_outdelay,
        CFGFCNPH             => CFGFCNPH_outdelay,
        CFGFCPD              => CFGFCPD_outdelay,
        CFGFCPH              => CFGFCPH_outdelay,
        CFGFLRINPROCESS      => CFGFLRINPROCESS_outdelay,
        CFGFUNCTIONPOWERSTATE => CFGFUNCTIONPOWERSTATE_outdelay,
        CFGFUNCTIONSTATUS    => CFGFUNCTIONSTATUS_outdelay,
        CFGHOTRESETOUT       => CFGHOTRESETOUT_outdelay,
        CFGINPUTUPDATEDONE   => CFGINPUTUPDATEDONE_outdelay,
        CFGINTERRUPTAOUTPUT  => CFGINTERRUPTAOUTPUT_outdelay,
        CFGINTERRUPTBOUTPUT  => CFGINTERRUPTBOUTPUT_outdelay,
        CFGINTERRUPTCOUTPUT  => CFGINTERRUPTCOUTPUT_outdelay,
        CFGINTERRUPTDOUTPUT  => CFGINTERRUPTDOUTPUT_outdelay,
        CFGINTERRUPTMSIDATA  => CFGINTERRUPTMSIDATA_outdelay,
        CFGINTERRUPTMSIENABLE => CFGINTERRUPTMSIENABLE_outdelay,
        CFGINTERRUPTMSIFAIL  => CFGINTERRUPTMSIFAIL_outdelay,
        CFGINTERRUPTMSIMASKUPDATE => CFGINTERRUPTMSIMASKUPDATE_outdelay,
        CFGINTERRUPTMSIMMENABLE => CFGINTERRUPTMSIMMENABLE_outdelay,
        CFGINTERRUPTMSISENT  => CFGINTERRUPTMSISENT_outdelay,
        CFGINTERRUPTMSIVFENABLE => CFGINTERRUPTMSIVFENABLE_outdelay,
        CFGINTERRUPTMSIXENABLE => CFGINTERRUPTMSIXENABLE_outdelay,
        CFGINTERRUPTMSIXFAIL => CFGINTERRUPTMSIXFAIL_outdelay,
        CFGINTERRUPTMSIXMASK => CFGINTERRUPTMSIXMASK_outdelay,
        CFGINTERRUPTMSIXSENT => CFGINTERRUPTMSIXSENT_outdelay,
        CFGINTERRUPTMSIXVFENABLE => CFGINTERRUPTMSIXVFENABLE_outdelay,
        CFGINTERRUPTMSIXVFMASK => CFGINTERRUPTMSIXVFMASK_outdelay,
        CFGINTERRUPTSENT     => CFGINTERRUPTSENT_outdelay,
        CFGLINKPOWERSTATE    => CFGLINKPOWERSTATE_outdelay,
        CFGLOCALERROR        => CFGLOCALERROR_outdelay,
        CFGLTRENABLE         => CFGLTRENABLE_outdelay,
        CFGLTSSMSTATE        => CFGLTSSMSTATE_outdelay,
        CFGMAXPAYLOAD        => CFGMAXPAYLOAD_outdelay,
        CFGMAXREADREQ        => CFGMAXREADREQ_outdelay,
        CFGMCUPDATEDONE      => CFGMCUPDATEDONE_outdelay,
        CFGMGMTREADDATA      => CFGMGMTREADDATA_outdelay,
        CFGMGMTREADWRITEDONE => CFGMGMTREADWRITEDONE_outdelay,
        CFGMSGRECEIVED       => CFGMSGRECEIVED_outdelay,
        CFGMSGRECEIVEDDATA   => CFGMSGRECEIVEDDATA_outdelay,
        CFGMSGRECEIVEDTYPE   => CFGMSGRECEIVEDTYPE_outdelay,
        CFGMSGTRANSMITDONE   => CFGMSGTRANSMITDONE_outdelay,
        CFGNEGOTIATEDWIDTH   => CFGNEGOTIATEDWIDTH_outdelay,
        CFGOBFFENABLE        => CFGOBFFENABLE_outdelay,
        CFGPERFUNCSTATUSDATA => CFGPERFUNCSTATUSDATA_outdelay,
        CFGPERFUNCTIONUPDATEDONE => CFGPERFUNCTIONUPDATEDONE_outdelay,
        CFGPHYLINKDOWN       => CFGPHYLINKDOWN_outdelay,
        CFGPHYLINKSTATUS     => CFGPHYLINKSTATUS_outdelay,
        CFGPLSTATUSCHANGE    => CFGPLSTATUSCHANGE_outdelay,
        CFGPOWERSTATECHANGEINTERRUPT => CFGPOWERSTATECHANGEINTERRUPT_outdelay,
        CFGRCBSTATUS         => CFGRCBSTATUS_outdelay,
        CFGTPHFUNCTIONNUM    => CFGTPHFUNCTIONNUM_outdelay,
        CFGTPHREQUESTERENABLE => CFGTPHREQUESTERENABLE_outdelay,
        CFGTPHSTMODE         => CFGTPHSTMODE_outdelay,
        CFGTPHSTTADDRESS     => CFGTPHSTTADDRESS_outdelay,
        CFGTPHSTTREADENABLE  => CFGTPHSTTREADENABLE_outdelay,
        CFGTPHSTTWRITEBYTEVALID => CFGTPHSTTWRITEBYTEVALID_outdelay,
        CFGTPHSTTWRITEDATA   => CFGTPHSTTWRITEDATA_outdelay,
        CFGTPHSTTWRITEENABLE => CFGTPHSTTWRITEENABLE_outdelay,
        CFGVFFLRINPROCESS    => CFGVFFLRINPROCESS_outdelay,
        CFGVFPOWERSTATE      => CFGVFPOWERSTATE_outdelay,
        CFGVFSTATUS          => CFGVFSTATUS_outdelay,
        CFGVFTPHREQUESTERENABLE => CFGVFTPHREQUESTERENABLE_outdelay,
        CFGVFTPHSTMODE       => CFGVFTPHSTMODE_outdelay,
        DBGDATAOUT           => DBGDATAOUT_outdelay,
        DRPDO                => DRPDO_outdelay,
        DRPRDY               => DRPRDY_outdelay,
        MAXISCQTDATA         => MAXISCQTDATA_outdelay,
        MAXISCQTKEEP         => MAXISCQTKEEP_outdelay,
        MAXISCQTLAST         => MAXISCQTLAST_outdelay,
        MAXISCQTUSER         => MAXISCQTUSER_outdelay,
        MAXISCQTVALID        => MAXISCQTVALID_outdelay,
        MAXISRCTDATA         => MAXISRCTDATA_outdelay,
        MAXISRCTKEEP         => MAXISRCTKEEP_outdelay,
        MAXISRCTLAST         => MAXISRCTLAST_outdelay,
        MAXISRCTUSER         => MAXISRCTUSER_outdelay,
        MAXISRCTVALID        => MAXISRCTVALID_outdelay,
        MICOMPLETIONRAMREADADDRESSAL => MICOMPLETIONRAMREADADDRESSAL_outdelay,
        MICOMPLETIONRAMREADADDRESSAU => MICOMPLETIONRAMREADADDRESSAU_outdelay,
        MICOMPLETIONRAMREADADDRESSBL => MICOMPLETIONRAMREADADDRESSBL_outdelay,
        MICOMPLETIONRAMREADADDRESSBU => MICOMPLETIONRAMREADADDRESSBU_outdelay,
        MICOMPLETIONRAMREADENABLEL => MICOMPLETIONRAMREADENABLEL_outdelay,
        MICOMPLETIONRAMREADENABLEU => MICOMPLETIONRAMREADENABLEU_outdelay,
        MICOMPLETIONRAMWRITEADDRESSAL => MICOMPLETIONRAMWRITEADDRESSAL_outdelay,
        MICOMPLETIONRAMWRITEADDRESSAU => MICOMPLETIONRAMWRITEADDRESSAU_outdelay,
        MICOMPLETIONRAMWRITEADDRESSBL => MICOMPLETIONRAMWRITEADDRESSBL_outdelay,
        MICOMPLETIONRAMWRITEADDRESSBU => MICOMPLETIONRAMWRITEADDRESSBU_outdelay,
        MICOMPLETIONRAMWRITEDATAL => MICOMPLETIONRAMWRITEDATAL_outdelay,
        MICOMPLETIONRAMWRITEDATAU => MICOMPLETIONRAMWRITEDATAU_outdelay,
        MICOMPLETIONRAMWRITEENABLEL => MICOMPLETIONRAMWRITEENABLEL_outdelay,
        MICOMPLETIONRAMWRITEENABLEU => MICOMPLETIONRAMWRITEENABLEU_outdelay,
        MIREPLAYRAMADDRESS   => MIREPLAYRAMADDRESS_outdelay,
        MIREPLAYRAMREADENABLE => MIREPLAYRAMREADENABLE_outdelay,
        MIREPLAYRAMWRITEDATA => MIREPLAYRAMWRITEDATA_outdelay,
        MIREPLAYRAMWRITEENABLE => MIREPLAYRAMWRITEENABLE_outdelay,
        MIREQUESTRAMREADADDRESSA => MIREQUESTRAMREADADDRESSA_outdelay,
        MIREQUESTRAMREADADDRESSB => MIREQUESTRAMREADADDRESSB_outdelay,
        MIREQUESTRAMREADENABLE => MIREQUESTRAMREADENABLE_outdelay,
        MIREQUESTRAMWRITEADDRESSA => MIREQUESTRAMWRITEADDRESSA_outdelay,
        MIREQUESTRAMWRITEADDRESSB => MIREQUESTRAMWRITEADDRESSB_outdelay,
        MIREQUESTRAMWRITEDATA => MIREQUESTRAMWRITEDATA_outdelay,
        MIREQUESTRAMWRITEENABLE => MIREQUESTRAMWRITEENABLE_outdelay,
        PCIECQNPREQCOUNT     => PCIECQNPREQCOUNT_outdelay,
        PCIERQSEQNUM         => PCIERQSEQNUM_outdelay,
        PCIERQSEQNUMVLD      => PCIERQSEQNUMVLD_outdelay,
        PCIERQTAG            => PCIERQTAG_outdelay,
        PCIERQTAGAV          => PCIERQTAGAV_outdelay,
        PCIERQTAGVLD         => PCIERQTAGVLD_outdelay,
        PCIETFCNPDAV         => PCIETFCNPDAV_outdelay,
        PCIETFCNPHAV         => PCIETFCNPHAV_outdelay,
        PIPERX0EQCONTROL     => PIPERX0EQCONTROL_outdelay,
        PIPERX0EQLPLFFS      => PIPERX0EQLPLFFS_outdelay,
        PIPERX0EQLPTXPRESET  => PIPERX0EQLPTXPRESET_outdelay,
        PIPERX0EQPRESET      => PIPERX0EQPRESET_outdelay,
        PIPERX0POLARITY      => PIPERX0POLARITY_outdelay,
        PIPERX1EQCONTROL     => PIPERX1EQCONTROL_outdelay,
        PIPERX1EQLPLFFS      => PIPERX1EQLPLFFS_outdelay,
        PIPERX1EQLPTXPRESET  => PIPERX1EQLPTXPRESET_outdelay,
        PIPERX1EQPRESET      => PIPERX1EQPRESET_outdelay,
        PIPERX1POLARITY      => PIPERX1POLARITY_outdelay,
        PIPERX2EQCONTROL     => PIPERX2EQCONTROL_outdelay,
        PIPERX2EQLPLFFS      => PIPERX2EQLPLFFS_outdelay,
        PIPERX2EQLPTXPRESET  => PIPERX2EQLPTXPRESET_outdelay,
        PIPERX2EQPRESET      => PIPERX2EQPRESET_outdelay,
        PIPERX2POLARITY      => PIPERX2POLARITY_outdelay,
        PIPERX3EQCONTROL     => PIPERX3EQCONTROL_outdelay,
        PIPERX3EQLPLFFS      => PIPERX3EQLPLFFS_outdelay,
        PIPERX3EQLPTXPRESET  => PIPERX3EQLPTXPRESET_outdelay,
        PIPERX3EQPRESET      => PIPERX3EQPRESET_outdelay,
        PIPERX3POLARITY      => PIPERX3POLARITY_outdelay,
        PIPERX4EQCONTROL     => PIPERX4EQCONTROL_outdelay,
        PIPERX4EQLPLFFS      => PIPERX4EQLPLFFS_outdelay,
        PIPERX4EQLPTXPRESET  => PIPERX4EQLPTXPRESET_outdelay,
        PIPERX4EQPRESET      => PIPERX4EQPRESET_outdelay,
        PIPERX4POLARITY      => PIPERX4POLARITY_outdelay,
        PIPERX5EQCONTROL     => PIPERX5EQCONTROL_outdelay,
        PIPERX5EQLPLFFS      => PIPERX5EQLPLFFS_outdelay,
        PIPERX5EQLPTXPRESET  => PIPERX5EQLPTXPRESET_outdelay,
        PIPERX5EQPRESET      => PIPERX5EQPRESET_outdelay,
        PIPERX5POLARITY      => PIPERX5POLARITY_outdelay,
        PIPERX6EQCONTROL     => PIPERX6EQCONTROL_outdelay,
        PIPERX6EQLPLFFS      => PIPERX6EQLPLFFS_outdelay,
        PIPERX6EQLPTXPRESET  => PIPERX6EQLPTXPRESET_outdelay,
        PIPERX6EQPRESET      => PIPERX6EQPRESET_outdelay,
        PIPERX6POLARITY      => PIPERX6POLARITY_outdelay,
        PIPERX7EQCONTROL     => PIPERX7EQCONTROL_outdelay,
        PIPERX7EQLPLFFS      => PIPERX7EQLPLFFS_outdelay,
        PIPERX7EQLPTXPRESET  => PIPERX7EQLPTXPRESET_outdelay,
        PIPERX7EQPRESET      => PIPERX7EQPRESET_outdelay,
        PIPERX7POLARITY      => PIPERX7POLARITY_outdelay,
        PIPETX0CHARISK       => PIPETX0CHARISK_outdelay,
        PIPETX0COMPLIANCE    => PIPETX0COMPLIANCE_outdelay,
        PIPETX0DATA          => PIPETX0DATA_outdelay,
        PIPETX0DATAVALID     => PIPETX0DATAVALID_outdelay,
        PIPETX0ELECIDLE      => PIPETX0ELECIDLE_outdelay,
        PIPETX0EQCONTROL     => PIPETX0EQCONTROL_outdelay,
        PIPETX0EQDEEMPH      => PIPETX0EQDEEMPH_outdelay,
        PIPETX0EQPRESET      => PIPETX0EQPRESET_outdelay,
        PIPETX0POWERDOWN     => PIPETX0POWERDOWN_outdelay,
        PIPETX0STARTBLOCK    => PIPETX0STARTBLOCK_outdelay,
        PIPETX0SYNCHEADER    => PIPETX0SYNCHEADER_outdelay,
        PIPETX1CHARISK       => PIPETX1CHARISK_outdelay,
        PIPETX1COMPLIANCE    => PIPETX1COMPLIANCE_outdelay,
        PIPETX1DATA          => PIPETX1DATA_outdelay,
        PIPETX1DATAVALID     => PIPETX1DATAVALID_outdelay,
        PIPETX1ELECIDLE      => PIPETX1ELECIDLE_outdelay,
        PIPETX1EQCONTROL     => PIPETX1EQCONTROL_outdelay,
        PIPETX1EQDEEMPH      => PIPETX1EQDEEMPH_outdelay,
        PIPETX1EQPRESET      => PIPETX1EQPRESET_outdelay,
        PIPETX1POWERDOWN     => PIPETX1POWERDOWN_outdelay,
        PIPETX1STARTBLOCK    => PIPETX1STARTBLOCK_outdelay,
        PIPETX1SYNCHEADER    => PIPETX1SYNCHEADER_outdelay,
        PIPETX2CHARISK       => PIPETX2CHARISK_outdelay,
        PIPETX2COMPLIANCE    => PIPETX2COMPLIANCE_outdelay,
        PIPETX2DATA          => PIPETX2DATA_outdelay,
        PIPETX2DATAVALID     => PIPETX2DATAVALID_outdelay,
        PIPETX2ELECIDLE      => PIPETX2ELECIDLE_outdelay,
        PIPETX2EQCONTROL     => PIPETX2EQCONTROL_outdelay,
        PIPETX2EQDEEMPH      => PIPETX2EQDEEMPH_outdelay,
        PIPETX2EQPRESET      => PIPETX2EQPRESET_outdelay,
        PIPETX2POWERDOWN     => PIPETX2POWERDOWN_outdelay,
        PIPETX2STARTBLOCK    => PIPETX2STARTBLOCK_outdelay,
        PIPETX2SYNCHEADER    => PIPETX2SYNCHEADER_outdelay,
        PIPETX3CHARISK       => PIPETX3CHARISK_outdelay,
        PIPETX3COMPLIANCE    => PIPETX3COMPLIANCE_outdelay,
        PIPETX3DATA          => PIPETX3DATA_outdelay,
        PIPETX3DATAVALID     => PIPETX3DATAVALID_outdelay,
        PIPETX3ELECIDLE      => PIPETX3ELECIDLE_outdelay,
        PIPETX3EQCONTROL     => PIPETX3EQCONTROL_outdelay,
        PIPETX3EQDEEMPH      => PIPETX3EQDEEMPH_outdelay,
        PIPETX3EQPRESET      => PIPETX3EQPRESET_outdelay,
        PIPETX3POWERDOWN     => PIPETX3POWERDOWN_outdelay,
        PIPETX3STARTBLOCK    => PIPETX3STARTBLOCK_outdelay,
        PIPETX3SYNCHEADER    => PIPETX3SYNCHEADER_outdelay,
        PIPETX4CHARISK       => PIPETX4CHARISK_outdelay,
        PIPETX4COMPLIANCE    => PIPETX4COMPLIANCE_outdelay,
        PIPETX4DATA          => PIPETX4DATA_outdelay,
        PIPETX4DATAVALID     => PIPETX4DATAVALID_outdelay,
        PIPETX4ELECIDLE      => PIPETX4ELECIDLE_outdelay,
        PIPETX4EQCONTROL     => PIPETX4EQCONTROL_outdelay,
        PIPETX4EQDEEMPH      => PIPETX4EQDEEMPH_outdelay,
        PIPETX4EQPRESET      => PIPETX4EQPRESET_outdelay,
        PIPETX4POWERDOWN     => PIPETX4POWERDOWN_outdelay,
        PIPETX4STARTBLOCK    => PIPETX4STARTBLOCK_outdelay,
        PIPETX4SYNCHEADER    => PIPETX4SYNCHEADER_outdelay,
        PIPETX5CHARISK       => PIPETX5CHARISK_outdelay,
        PIPETX5COMPLIANCE    => PIPETX5COMPLIANCE_outdelay,
        PIPETX5DATA          => PIPETX5DATA_outdelay,
        PIPETX5DATAVALID     => PIPETX5DATAVALID_outdelay,
        PIPETX5ELECIDLE      => PIPETX5ELECIDLE_outdelay,
        PIPETX5EQCONTROL     => PIPETX5EQCONTROL_outdelay,
        PIPETX5EQDEEMPH      => PIPETX5EQDEEMPH_outdelay,
        PIPETX5EQPRESET      => PIPETX5EQPRESET_outdelay,
        PIPETX5POWERDOWN     => PIPETX5POWERDOWN_outdelay,
        PIPETX5STARTBLOCK    => PIPETX5STARTBLOCK_outdelay,
        PIPETX5SYNCHEADER    => PIPETX5SYNCHEADER_outdelay,
        PIPETX6CHARISK       => PIPETX6CHARISK_outdelay,
        PIPETX6COMPLIANCE    => PIPETX6COMPLIANCE_outdelay,
        PIPETX6DATA          => PIPETX6DATA_outdelay,
        PIPETX6DATAVALID     => PIPETX6DATAVALID_outdelay,
        PIPETX6ELECIDLE      => PIPETX6ELECIDLE_outdelay,
        PIPETX6EQCONTROL     => PIPETX6EQCONTROL_outdelay,
        PIPETX6EQDEEMPH      => PIPETX6EQDEEMPH_outdelay,
        PIPETX6EQPRESET      => PIPETX6EQPRESET_outdelay,
        PIPETX6POWERDOWN     => PIPETX6POWERDOWN_outdelay,
        PIPETX6STARTBLOCK    => PIPETX6STARTBLOCK_outdelay,
        PIPETX6SYNCHEADER    => PIPETX6SYNCHEADER_outdelay,
        PIPETX7CHARISK       => PIPETX7CHARISK_outdelay,
        PIPETX7COMPLIANCE    => PIPETX7COMPLIANCE_outdelay,
        PIPETX7DATA          => PIPETX7DATA_outdelay,
        PIPETX7DATAVALID     => PIPETX7DATAVALID_outdelay,
        PIPETX7ELECIDLE      => PIPETX7ELECIDLE_outdelay,
        PIPETX7EQCONTROL     => PIPETX7EQCONTROL_outdelay,
        PIPETX7EQDEEMPH      => PIPETX7EQDEEMPH_outdelay,
        PIPETX7EQPRESET      => PIPETX7EQPRESET_outdelay,
        PIPETX7POWERDOWN     => PIPETX7POWERDOWN_outdelay,
        PIPETX7STARTBLOCK    => PIPETX7STARTBLOCK_outdelay,
        PIPETX7SYNCHEADER    => PIPETX7SYNCHEADER_outdelay,
        PIPETXDEEMPH         => PIPETXDEEMPH_outdelay,
        PIPETXMARGIN         => PIPETXMARGIN_outdelay,
        PIPETXRATE           => PIPETXRATE_outdelay,
        PIPETXRCVRDET        => PIPETXRCVRDET_outdelay,
        PIPETXRESET          => PIPETXRESET_outdelay,
        PIPETXSWING          => PIPETXSWING_outdelay,
        PLEQINPROGRESS       => PLEQINPROGRESS_outdelay,
        PLEQPHASE            => PLEQPHASE_outdelay,
        PLGEN3PCSRXSLIDE     => PLGEN3PCSRXSLIDE_outdelay,
        SAXISCCTREADY        => SAXISCCTREADY_outdelay,
        SAXISRQTREADY        => SAXISRQTREADY_outdelay,
        CFGCONFIGSPACEENABLE => CFGCONFIGSPACEENABLE_indelay,
        CFGDEVID             => CFGDEVID_indelay,
        CFGDSBUSNUMBER       => CFGDSBUSNUMBER_indelay,
        CFGDSDEVICENUMBER    => CFGDSDEVICENUMBER_indelay,
        CFGDSFUNCTIONNUMBER  => CFGDSFUNCTIONNUMBER_indelay,
        CFGDSN               => CFGDSN_indelay,
        CFGDSPORTNUMBER      => CFGDSPORTNUMBER_indelay,
        CFGERRCORIN          => CFGERRCORIN_indelay,
        CFGERRUNCORIN        => CFGERRUNCORIN_indelay,
        CFGEXTREADDATA       => CFGEXTREADDATA_indelay,
        CFGEXTREADDATAVALID  => CFGEXTREADDATAVALID_indelay,
        CFGFCSEL             => CFGFCSEL_indelay,
        CFGFLRDONE           => CFGFLRDONE_indelay,
        CFGHOTRESETIN        => CFGHOTRESETIN_indelay,
        CFGINPUTUPDATEREQUEST => CFGINPUTUPDATEREQUEST_indelay,
        CFGINTERRUPTINT      => CFGINTERRUPTINT_indelay,
        CFGINTERRUPTMSIATTR  => CFGINTERRUPTMSIATTR_indelay,
        CFGINTERRUPTMSIFUNCTIONNUMBER => CFGINTERRUPTMSIFUNCTIONNUMBER_indelay,
        CFGINTERRUPTMSIINT   => CFGINTERRUPTMSIINT_indelay,
        CFGINTERRUPTMSIPENDINGSTATUS => CFGINTERRUPTMSIPENDINGSTATUS_indelay,
        CFGINTERRUPTMSISELECT => CFGINTERRUPTMSISELECT_indelay,
        CFGINTERRUPTMSITPHPRESENT => CFGINTERRUPTMSITPHPRESENT_indelay,
        CFGINTERRUPTMSITPHSTTAG => CFGINTERRUPTMSITPHSTTAG_indelay,
        CFGINTERRUPTMSITPHTYPE => CFGINTERRUPTMSITPHTYPE_indelay,
        CFGINTERRUPTMSIXADDRESS => CFGINTERRUPTMSIXADDRESS_indelay,
        CFGINTERRUPTMSIXDATA => CFGINTERRUPTMSIXDATA_indelay,
        CFGINTERRUPTMSIXINT  => CFGINTERRUPTMSIXINT_indelay,
        CFGINTERRUPTPENDING  => CFGINTERRUPTPENDING_indelay,
        CFGLINKTRAININGENABLE => CFGLINKTRAININGENABLE_indelay,
        CFGMCUPDATEREQUEST   => CFGMCUPDATEREQUEST_indelay,
        CFGMGMTADDR          => CFGMGMTADDR_indelay,
        CFGMGMTBYTEENABLE    => CFGMGMTBYTEENABLE_indelay,
        CFGMGMTREAD          => CFGMGMTREAD_indelay,
        CFGMGMTTYPE1CFGREGACCESS => CFGMGMTTYPE1CFGREGACCESS_indelay,
        CFGMGMTWRITE         => CFGMGMTWRITE_indelay,
        CFGMGMTWRITEDATA     => CFGMGMTWRITEDATA_indelay,
        CFGMSGTRANSMIT       => CFGMSGTRANSMIT_indelay,
        CFGMSGTRANSMITDATA   => CFGMSGTRANSMITDATA_indelay,
        CFGMSGTRANSMITTYPE   => CFGMSGTRANSMITTYPE_indelay,
        CFGPERFUNCSTATUSCONTROL => CFGPERFUNCSTATUSCONTROL_indelay,
        CFGPERFUNCTIONNUMBER => CFGPERFUNCTIONNUMBER_indelay,
        CFGPERFUNCTIONOUTPUTREQUEST => CFGPERFUNCTIONOUTPUTREQUEST_indelay,
        CFGPOWERSTATECHANGEACK => CFGPOWERSTATECHANGEACK_indelay,
        CFGREQPMTRANSITIONL23READY => CFGREQPMTRANSITIONL23READY_indelay,
        CFGREVID             => CFGREVID_indelay,
        CFGSUBSYSID          => CFGSUBSYSID_indelay,
        CFGSUBSYSVENDID      => CFGSUBSYSVENDID_indelay,
        CFGTPHSTTREADDATA    => CFGTPHSTTREADDATA_indelay,
        CFGTPHSTTREADDATAVALID => CFGTPHSTTREADDATAVALID_indelay,
        CFGVENDID            => CFGVENDID_indelay,
        CFGVFFLRDONE         => CFGVFFLRDONE_indelay,
        CORECLK              => CORECLK_indelay,
        CORECLKMICOMPLETIONRAML => CORECLKMICOMPLETIONRAML_indelay,
        CORECLKMICOMPLETIONRAMU => CORECLKMICOMPLETIONRAMU_indelay,
        CORECLKMIREPLAYRAM   => CORECLKMIREPLAYRAM_indelay,
        CORECLKMIREQUESTRAM  => CORECLKMIREQUESTRAM_indelay,
        DRPADDR              => DRPADDR_indelay,
        DRPCLK               => DRPCLK_indelay,
        DRPDI                => DRPDI_indelay,
        DRPEN                => DRPEN_indelay,
        DRPWE                => DRPWE_indelay,
        MAXISCQTREADY        => MAXISCQTREADY_indelay,
        MAXISRCTREADY        => MAXISRCTREADY_indelay,
        MGMTRESETN           => MGMTRESETN_indelay,
        MGMTSTICKYRESETN     => MGMTSTICKYRESETN_indelay,
        MICOMPLETIONRAMREADDATA => MICOMPLETIONRAMREADDATA_indelay,
        MIREPLAYRAMREADDATA  => MIREPLAYRAMREADDATA_indelay,
        MIREQUESTRAMREADDATA => MIREQUESTRAMREADDATA_indelay,
        PCIECQNPREQ          => PCIECQNPREQ_indelay,
        PIPECLK              => PIPECLK_indelay,
        PIPEEQFS             => PIPEEQFS_indelay,
        PIPEEQLF             => PIPEEQLF_indelay,
        PIPERESETN           => PIPERESETN_indelay,
        PIPERX0CHARISK       => PIPERX0CHARISK_indelay,
        PIPERX0DATA          => PIPERX0DATA_indelay,
        PIPERX0DATAVALID     => PIPERX0DATAVALID_indelay,
        PIPERX0ELECIDLE      => PIPERX0ELECIDLE_indelay,
        PIPERX0EQDONE        => PIPERX0EQDONE_indelay,
        PIPERX0EQLPADAPTDONE => PIPERX0EQLPADAPTDONE_indelay,
        PIPERX0EQLPLFFSSEL   => PIPERX0EQLPLFFSSEL_indelay,
        PIPERX0EQLPNEWTXCOEFFORPRESET => PIPERX0EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX0PHYSTATUS     => PIPERX0PHYSTATUS_indelay,
        PIPERX0STARTBLOCK    => PIPERX0STARTBLOCK_indelay,
        PIPERX0STATUS        => PIPERX0STATUS_indelay,
        PIPERX0SYNCHEADER    => PIPERX0SYNCHEADER_indelay,
        PIPERX0VALID         => PIPERX0VALID_indelay,
        PIPERX1CHARISK       => PIPERX1CHARISK_indelay,
        PIPERX1DATA          => PIPERX1DATA_indelay,
        PIPERX1DATAVALID     => PIPERX1DATAVALID_indelay,
        PIPERX1ELECIDLE      => PIPERX1ELECIDLE_indelay,
        PIPERX1EQDONE        => PIPERX1EQDONE_indelay,
        PIPERX1EQLPADAPTDONE => PIPERX1EQLPADAPTDONE_indelay,
        PIPERX1EQLPLFFSSEL   => PIPERX1EQLPLFFSSEL_indelay,
        PIPERX1EQLPNEWTXCOEFFORPRESET => PIPERX1EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX1PHYSTATUS     => PIPERX1PHYSTATUS_indelay,
        PIPERX1STARTBLOCK    => PIPERX1STARTBLOCK_indelay,
        PIPERX1STATUS        => PIPERX1STATUS_indelay,
        PIPERX1SYNCHEADER    => PIPERX1SYNCHEADER_indelay,
        PIPERX1VALID         => PIPERX1VALID_indelay,
        PIPERX2CHARISK       => PIPERX2CHARISK_indelay,
        PIPERX2DATA          => PIPERX2DATA_indelay,
        PIPERX2DATAVALID     => PIPERX2DATAVALID_indelay,
        PIPERX2ELECIDLE      => PIPERX2ELECIDLE_indelay,
        PIPERX2EQDONE        => PIPERX2EQDONE_indelay,
        PIPERX2EQLPADAPTDONE => PIPERX2EQLPADAPTDONE_indelay,
        PIPERX2EQLPLFFSSEL   => PIPERX2EQLPLFFSSEL_indelay,
        PIPERX2EQLPNEWTXCOEFFORPRESET => PIPERX2EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX2PHYSTATUS     => PIPERX2PHYSTATUS_indelay,
        PIPERX2STARTBLOCK    => PIPERX2STARTBLOCK_indelay,
        PIPERX2STATUS        => PIPERX2STATUS_indelay,
        PIPERX2SYNCHEADER    => PIPERX2SYNCHEADER_indelay,
        PIPERX2VALID         => PIPERX2VALID_indelay,
        PIPERX3CHARISK       => PIPERX3CHARISK_indelay,
        PIPERX3DATA          => PIPERX3DATA_indelay,
        PIPERX3DATAVALID     => PIPERX3DATAVALID_indelay,
        PIPERX3ELECIDLE      => PIPERX3ELECIDLE_indelay,
        PIPERX3EQDONE        => PIPERX3EQDONE_indelay,
        PIPERX3EQLPADAPTDONE => PIPERX3EQLPADAPTDONE_indelay,
        PIPERX3EQLPLFFSSEL   => PIPERX3EQLPLFFSSEL_indelay,
        PIPERX3EQLPNEWTXCOEFFORPRESET => PIPERX3EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX3PHYSTATUS     => PIPERX3PHYSTATUS_indelay,
        PIPERX3STARTBLOCK    => PIPERX3STARTBLOCK_indelay,
        PIPERX3STATUS        => PIPERX3STATUS_indelay,
        PIPERX3SYNCHEADER    => PIPERX3SYNCHEADER_indelay,
        PIPERX3VALID         => PIPERX3VALID_indelay,
        PIPERX4CHARISK       => PIPERX4CHARISK_indelay,
        PIPERX4DATA          => PIPERX4DATA_indelay,
        PIPERX4DATAVALID     => PIPERX4DATAVALID_indelay,
        PIPERX4ELECIDLE      => PIPERX4ELECIDLE_indelay,
        PIPERX4EQDONE        => PIPERX4EQDONE_indelay,
        PIPERX4EQLPADAPTDONE => PIPERX4EQLPADAPTDONE_indelay,
        PIPERX4EQLPLFFSSEL   => PIPERX4EQLPLFFSSEL_indelay,
        PIPERX4EQLPNEWTXCOEFFORPRESET => PIPERX4EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX4PHYSTATUS     => PIPERX4PHYSTATUS_indelay,
        PIPERX4STARTBLOCK    => PIPERX4STARTBLOCK_indelay,
        PIPERX4STATUS        => PIPERX4STATUS_indelay,
        PIPERX4SYNCHEADER    => PIPERX4SYNCHEADER_indelay,
        PIPERX4VALID         => PIPERX4VALID_indelay,
        PIPERX5CHARISK       => PIPERX5CHARISK_indelay,
        PIPERX5DATA          => PIPERX5DATA_indelay,
        PIPERX5DATAVALID     => PIPERX5DATAVALID_indelay,
        PIPERX5ELECIDLE      => PIPERX5ELECIDLE_indelay,
        PIPERX5EQDONE        => PIPERX5EQDONE_indelay,
        PIPERX5EQLPADAPTDONE => PIPERX5EQLPADAPTDONE_indelay,
        PIPERX5EQLPLFFSSEL   => PIPERX5EQLPLFFSSEL_indelay,
        PIPERX5EQLPNEWTXCOEFFORPRESET => PIPERX5EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX5PHYSTATUS     => PIPERX5PHYSTATUS_indelay,
        PIPERX5STARTBLOCK    => PIPERX5STARTBLOCK_indelay,
        PIPERX5STATUS        => PIPERX5STATUS_indelay,
        PIPERX5SYNCHEADER    => PIPERX5SYNCHEADER_indelay,
        PIPERX5VALID         => PIPERX5VALID_indelay,
        PIPERX6CHARISK       => PIPERX6CHARISK_indelay,
        PIPERX6DATA          => PIPERX6DATA_indelay,
        PIPERX6DATAVALID     => PIPERX6DATAVALID_indelay,
        PIPERX6ELECIDLE      => PIPERX6ELECIDLE_indelay,
        PIPERX6EQDONE        => PIPERX6EQDONE_indelay,
        PIPERX6EQLPADAPTDONE => PIPERX6EQLPADAPTDONE_indelay,
        PIPERX6EQLPLFFSSEL   => PIPERX6EQLPLFFSSEL_indelay,
        PIPERX6EQLPNEWTXCOEFFORPRESET => PIPERX6EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX6PHYSTATUS     => PIPERX6PHYSTATUS_indelay,
        PIPERX6STARTBLOCK    => PIPERX6STARTBLOCK_indelay,
        PIPERX6STATUS        => PIPERX6STATUS_indelay,
        PIPERX6SYNCHEADER    => PIPERX6SYNCHEADER_indelay,
        PIPERX6VALID         => PIPERX6VALID_indelay,
        PIPERX7CHARISK       => PIPERX7CHARISK_indelay,
        PIPERX7DATA          => PIPERX7DATA_indelay,
        PIPERX7DATAVALID     => PIPERX7DATAVALID_indelay,
        PIPERX7ELECIDLE      => PIPERX7ELECIDLE_indelay,
        PIPERX7EQDONE        => PIPERX7EQDONE_indelay,
        PIPERX7EQLPADAPTDONE => PIPERX7EQLPADAPTDONE_indelay,
        PIPERX7EQLPLFFSSEL   => PIPERX7EQLPLFFSSEL_indelay,
        PIPERX7EQLPNEWTXCOEFFORPRESET => PIPERX7EQLPNEWTXCOEFFORPRESET_indelay,
        PIPERX7PHYSTATUS     => PIPERX7PHYSTATUS_indelay,
        PIPERX7STARTBLOCK    => PIPERX7STARTBLOCK_indelay,
        PIPERX7STATUS        => PIPERX7STATUS_indelay,
        PIPERX7SYNCHEADER    => PIPERX7SYNCHEADER_indelay,
        PIPERX7VALID         => PIPERX7VALID_indelay,
        PIPETX0EQCOEFF       => PIPETX0EQCOEFF_indelay,
        PIPETX0EQDONE        => PIPETX0EQDONE_indelay,
        PIPETX1EQCOEFF       => PIPETX1EQCOEFF_indelay,
        PIPETX1EQDONE        => PIPETX1EQDONE_indelay,
        PIPETX2EQCOEFF       => PIPETX2EQCOEFF_indelay,
        PIPETX2EQDONE        => PIPETX2EQDONE_indelay,
        PIPETX3EQCOEFF       => PIPETX3EQCOEFF_indelay,
        PIPETX3EQDONE        => PIPETX3EQDONE_indelay,
        PIPETX4EQCOEFF       => PIPETX4EQCOEFF_indelay,
        PIPETX4EQDONE        => PIPETX4EQDONE_indelay,
        PIPETX5EQCOEFF       => PIPETX5EQCOEFF_indelay,
        PIPETX5EQDONE        => PIPETX5EQDONE_indelay,
        PIPETX6EQCOEFF       => PIPETX6EQCOEFF_indelay,
        PIPETX6EQDONE        => PIPETX6EQDONE_indelay,
        PIPETX7EQCOEFF       => PIPETX7EQCOEFF_indelay,
        PIPETX7EQDONE        => PIPETX7EQDONE_indelay,
        PLDISABLESCRAMBLER   => PLDISABLESCRAMBLER_indelay,
        PLEQRESETEIEOSCOUNT  => PLEQRESETEIEOSCOUNT_indelay,
        PLGEN3PCSDISABLE     => PLGEN3PCSDISABLE_indelay,
        PLGEN3PCSRXSYNCDONE  => PLGEN3PCSRXSYNCDONE_indelay,
        RECCLK               => RECCLK_indelay,
        RESETN               => RESETN_indelay,
        SAXISCCTDATA         => SAXISCCTDATA_indelay,
        SAXISCCTKEEP         => SAXISCCTKEEP_indelay,
        SAXISCCTLAST         => SAXISCCTLAST_indelay,
        SAXISCCTUSER         => SAXISCCTUSER_indelay,
        SAXISCCTVALID        => SAXISCCTVALID_indelay,
        SAXISRQTDATA         => SAXISRQTDATA_indelay,
        SAXISRQTKEEP         => SAXISRQTKEEP_indelay,
        SAXISRQTLAST         => SAXISRQTLAST_indelay,
        SAXISRQTUSER         => SAXISRQTUSER_indelay,
        SAXISRQTVALID        => SAXISRQTVALID_indelay,
        USERCLK              => USERCLK_indelay        
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
    -- case ARI_CAP_ENABLE is
      if((ARI_CAP_ENABLE = "FALSE") or (ARI_CAP_ENABLE = "false")) then
        ARI_CAP_ENABLE_BINARY <= '0';
      elsif((ARI_CAP_ENABLE = "TRUE") or (ARI_CAP_ENABLE= "true")) then
        ARI_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : ARI_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_CC_ALIGNMENT_MODE is
      if((AXISTEN_IF_CC_ALIGNMENT_MODE = "FALSE") or (AXISTEN_IF_CC_ALIGNMENT_MODE = "false")) then
        AXISTEN_IF_CC_ALIGNMENT_MODE_BINARY <= '0';
      elsif((AXISTEN_IF_CC_ALIGNMENT_MODE = "TRUE") or (AXISTEN_IF_CC_ALIGNMENT_MODE= "true")) then
        AXISTEN_IF_CC_ALIGNMENT_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : AXISTEN_IF_CC_ALIGNMENT_MODE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_CC_PARITY_CHK is
      if((AXISTEN_IF_CC_PARITY_CHK = "TRUE") or (AXISTEN_IF_CC_PARITY_CHK = "true")) then
        AXISTEN_IF_CC_PARITY_CHK_BINARY <= '1';
      elsif((AXISTEN_IF_CC_PARITY_CHK = "FALSE") or (AXISTEN_IF_CC_PARITY_CHK= "false")) then
        AXISTEN_IF_CC_PARITY_CHK_BINARY <= '0';
      else
        assert FALSE report "Error : AXISTEN_IF_CC_PARITY_CHK = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_CQ_ALIGNMENT_MODE is
      if((AXISTEN_IF_CQ_ALIGNMENT_MODE = "FALSE") or (AXISTEN_IF_CQ_ALIGNMENT_MODE = "false")) then
        AXISTEN_IF_CQ_ALIGNMENT_MODE_BINARY <= '0';
      elsif((AXISTEN_IF_CQ_ALIGNMENT_MODE = "TRUE") or (AXISTEN_IF_CQ_ALIGNMENT_MODE= "true")) then
        AXISTEN_IF_CQ_ALIGNMENT_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : AXISTEN_IF_CQ_ALIGNMENT_MODE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_ENABLE_CLIENT_TAG is
      if((AXISTEN_IF_ENABLE_CLIENT_TAG = "FALSE") or (AXISTEN_IF_ENABLE_CLIENT_TAG = "false")) then
        AXISTEN_IF_ENABLE_CLIENT_TAG_BINARY <= '0';
      elsif((AXISTEN_IF_ENABLE_CLIENT_TAG = "TRUE") or (AXISTEN_IF_ENABLE_CLIENT_TAG= "true")) then
        AXISTEN_IF_ENABLE_CLIENT_TAG_BINARY <= '1';
      else
        assert FALSE report "Error : AXISTEN_IF_ENABLE_CLIENT_TAG = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_ENABLE_RX_MSG_INTFC is
      if((AXISTEN_IF_ENABLE_RX_MSG_INTFC = "FALSE") or (AXISTEN_IF_ENABLE_RX_MSG_INTFC = "false")) then
        AXISTEN_IF_ENABLE_RX_MSG_INTFC_BINARY <= '0';
      elsif((AXISTEN_IF_ENABLE_RX_MSG_INTFC = "TRUE") or (AXISTEN_IF_ENABLE_RX_MSG_INTFC= "true")) then
        AXISTEN_IF_ENABLE_RX_MSG_INTFC_BINARY <= '1';
      else
        assert FALSE report "Error : AXISTEN_IF_ENABLE_RX_MSG_INTFC = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_RC_ALIGNMENT_MODE is
      if((AXISTEN_IF_RC_ALIGNMENT_MODE = "FALSE") or (AXISTEN_IF_RC_ALIGNMENT_MODE = "false")) then
        AXISTEN_IF_RC_ALIGNMENT_MODE_BINARY <= '0';
      elsif((AXISTEN_IF_RC_ALIGNMENT_MODE = "TRUE") or (AXISTEN_IF_RC_ALIGNMENT_MODE= "true")) then
        AXISTEN_IF_RC_ALIGNMENT_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : AXISTEN_IF_RC_ALIGNMENT_MODE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_RC_STRADDLE is
      if((AXISTEN_IF_RC_STRADDLE = "FALSE") or (AXISTEN_IF_RC_STRADDLE = "false")) then
        AXISTEN_IF_RC_STRADDLE_BINARY <= '0';
      elsif((AXISTEN_IF_RC_STRADDLE = "TRUE") or (AXISTEN_IF_RC_STRADDLE= "true")) then
        AXISTEN_IF_RC_STRADDLE_BINARY <= '1';
      else
        assert FALSE report "Error : AXISTEN_IF_RC_STRADDLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_RQ_ALIGNMENT_MODE is
      if((AXISTEN_IF_RQ_ALIGNMENT_MODE = "FALSE") or (AXISTEN_IF_RQ_ALIGNMENT_MODE = "false")) then
        AXISTEN_IF_RQ_ALIGNMENT_MODE_BINARY <= '0';
      elsif((AXISTEN_IF_RQ_ALIGNMENT_MODE = "TRUE") or (AXISTEN_IF_RQ_ALIGNMENT_MODE= "true")) then
        AXISTEN_IF_RQ_ALIGNMENT_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : AXISTEN_IF_RQ_ALIGNMENT_MODE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AXISTEN_IF_RQ_PARITY_CHK is
      if((AXISTEN_IF_RQ_PARITY_CHK = "TRUE") or (AXISTEN_IF_RQ_PARITY_CHK = "true")) then
        AXISTEN_IF_RQ_PARITY_CHK_BINARY <= '1';
      elsif((AXISTEN_IF_RQ_PARITY_CHK = "FALSE") or (AXISTEN_IF_RQ_PARITY_CHK= "false")) then
        AXISTEN_IF_RQ_PARITY_CHK_BINARY <= '0';
      else
        assert FALSE report "Error : AXISTEN_IF_RQ_PARITY_CHK = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case CRM_CORE_CLK_FREQ_500 is
      if((CRM_CORE_CLK_FREQ_500 = "TRUE") or (CRM_CORE_CLK_FREQ_500 = "true")) then
        CRM_CORE_CLK_FREQ_500_BINARY <= '1';
      elsif((CRM_CORE_CLK_FREQ_500 = "FALSE") or (CRM_CORE_CLK_FREQ_500= "false")) then
        CRM_CORE_CLK_FREQ_500_BINARY <= '0';
      else
        assert FALSE report "Error : CRM_CORE_CLK_FREQ_500 = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case GEN3_PCS_RX_ELECIDLE_INTERNAL is
      if((GEN3_PCS_RX_ELECIDLE_INTERNAL = "TRUE") or (GEN3_PCS_RX_ELECIDLE_INTERNAL = "true")) then
        GEN3_PCS_RX_ELECIDLE_INTERNAL_BINARY <= '1';
      elsif((GEN3_PCS_RX_ELECIDLE_INTERNAL = "FALSE") or (GEN3_PCS_RX_ELECIDLE_INTERNAL= "false")) then
        GEN3_PCS_RX_ELECIDLE_INTERNAL_BINARY <= '0';
      else
        assert FALSE report "Error : GEN3_PCS_RX_ELECIDLE_INTERNAL = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case LL_ACK_TIMEOUT_EN is
      if((LL_ACK_TIMEOUT_EN = "FALSE") or (LL_ACK_TIMEOUT_EN = "false")) then
        LL_ACK_TIMEOUT_EN_BINARY <= '0';
      elsif((LL_ACK_TIMEOUT_EN = "TRUE") or (LL_ACK_TIMEOUT_EN= "true")) then
        LL_ACK_TIMEOUT_EN_BINARY <= '1';
      else
        assert FALSE report "Error : LL_ACK_TIMEOUT_EN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LL_CPL_FC_UPDATE_TIMER_OVERRIDE is
      if((LL_CPL_FC_UPDATE_TIMER_OVERRIDE = "FALSE") or (LL_CPL_FC_UPDATE_TIMER_OVERRIDE = "false")) then
        LL_CPL_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '0';
      elsif((LL_CPL_FC_UPDATE_TIMER_OVERRIDE = "TRUE") or (LL_CPL_FC_UPDATE_TIMER_OVERRIDE= "true")) then
        LL_CPL_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '1';
      else
        assert FALSE report "Error : LL_CPL_FC_UPDATE_TIMER_OVERRIDE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LL_FC_UPDATE_TIMER_OVERRIDE is
      if((LL_FC_UPDATE_TIMER_OVERRIDE = "FALSE") or (LL_FC_UPDATE_TIMER_OVERRIDE = "false")) then
        LL_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '0';
      elsif((LL_FC_UPDATE_TIMER_OVERRIDE = "TRUE") or (LL_FC_UPDATE_TIMER_OVERRIDE= "true")) then
        LL_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '1';
      else
        assert FALSE report "Error : LL_FC_UPDATE_TIMER_OVERRIDE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LL_NP_FC_UPDATE_TIMER_OVERRIDE is
      if((LL_NP_FC_UPDATE_TIMER_OVERRIDE = "FALSE") or (LL_NP_FC_UPDATE_TIMER_OVERRIDE = "false")) then
        LL_NP_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '0';
      elsif((LL_NP_FC_UPDATE_TIMER_OVERRIDE = "TRUE") or (LL_NP_FC_UPDATE_TIMER_OVERRIDE= "true")) then
        LL_NP_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '1';
      else
        assert FALSE report "Error : LL_NP_FC_UPDATE_TIMER_OVERRIDE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LL_P_FC_UPDATE_TIMER_OVERRIDE is
      if((LL_P_FC_UPDATE_TIMER_OVERRIDE = "FALSE") or (LL_P_FC_UPDATE_TIMER_OVERRIDE = "false")) then
        LL_P_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '0';
      elsif((LL_P_FC_UPDATE_TIMER_OVERRIDE = "TRUE") or (LL_P_FC_UPDATE_TIMER_OVERRIDE= "true")) then
        LL_P_FC_UPDATE_TIMER_OVERRIDE_BINARY <= '1';
      else
        assert FALSE report "Error : LL_P_FC_UPDATE_TIMER_OVERRIDE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LL_REPLAY_TIMEOUT_EN is
      if((LL_REPLAY_TIMEOUT_EN = "FALSE") or (LL_REPLAY_TIMEOUT_EN = "false")) then
        LL_REPLAY_TIMEOUT_EN_BINARY <= '0';
      elsif((LL_REPLAY_TIMEOUT_EN = "TRUE") or (LL_REPLAY_TIMEOUT_EN= "true")) then
        LL_REPLAY_TIMEOUT_EN_BINARY <= '1';
      else
        assert FALSE report "Error : LL_REPLAY_TIMEOUT_EN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE is
      if((LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE = "FALSE") or (LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE = "false")) then
        LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE_BINARY <= '0';
      elsif((LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE = "TRUE") or (LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE= "true")) then
        LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE_BINARY <= '1';
      else
        assert FALSE report "Error : LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LTR_TX_MESSAGE_ON_LTR_ENABLE is
      if((LTR_TX_MESSAGE_ON_LTR_ENABLE = "FALSE") or (LTR_TX_MESSAGE_ON_LTR_ENABLE = "false")) then
        LTR_TX_MESSAGE_ON_LTR_ENABLE_BINARY <= '0';
      elsif((LTR_TX_MESSAGE_ON_LTR_ENABLE = "TRUE") or (LTR_TX_MESSAGE_ON_LTR_ENABLE= "true")) then
        LTR_TX_MESSAGE_ON_LTR_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : LTR_TX_MESSAGE_ON_LTR_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_AER_CAP_ECRC_CHECK_CAPABLE is
      if((PF0_AER_CAP_ECRC_CHECK_CAPABLE = "FALSE") or (PF0_AER_CAP_ECRC_CHECK_CAPABLE = "false")) then
        PF0_AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '0';
      elsif((PF0_AER_CAP_ECRC_CHECK_CAPABLE = "TRUE") or (PF0_AER_CAP_ECRC_CHECK_CAPABLE= "true")) then
        PF0_AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF0_AER_CAP_ECRC_CHECK_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_AER_CAP_ECRC_GEN_CAPABLE is
      if((PF0_AER_CAP_ECRC_GEN_CAPABLE = "FALSE") or (PF0_AER_CAP_ECRC_GEN_CAPABLE = "false")) then
        PF0_AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '0';
      elsif((PF0_AER_CAP_ECRC_GEN_CAPABLE = "TRUE") or (PF0_AER_CAP_ECRC_GEN_CAPABLE= "true")) then
        PF0_AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF0_AER_CAP_ECRC_GEN_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT is
      if((PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT = "TRUE") or (PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT = "true")) then
        PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT_BINARY <= '1';
      elsif((PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT = "FALSE") or (PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT= "false")) then
        PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT is
      if((PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT = "TRUE") or (PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT = "true")) then
        PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT_BINARY <= '1';
      elsif((PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT = "FALSE") or (PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT= "false")) then
        PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT is
      if((PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT = "TRUE") or (PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT = "true")) then
        PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT_BINARY <= '1';
      elsif((PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT = "FALSE") or (PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT= "false")) then
        PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE is
      if((PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE = "TRUE") or (PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE = "true")) then
        PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE_BINARY <= '1';
      elsif((PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE = "FALSE") or (PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE= "false")) then
        PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP2_LTR_SUPPORT is
      if((PF0_DEV_CAP2_LTR_SUPPORT = "TRUE") or (PF0_DEV_CAP2_LTR_SUPPORT = "true")) then
        PF0_DEV_CAP2_LTR_SUPPORT_BINARY <= '1';
      elsif((PF0_DEV_CAP2_LTR_SUPPORT = "FALSE") or (PF0_DEV_CAP2_LTR_SUPPORT= "false")) then
        PF0_DEV_CAP2_LTR_SUPPORT_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DEV_CAP2_LTR_SUPPORT = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT is
      if((PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT = "FALSE") or (PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT = "false")) then
        PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT_BINARY <= '0';
      elsif((PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT = "TRUE") or (PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT= "true")) then
        PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT_BINARY <= '1';
      else
        assert FALSE report "Error : PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP_EXT_TAG_SUPPORTED is
      if((PF0_DEV_CAP_EXT_TAG_SUPPORTED = "TRUE") or (PF0_DEV_CAP_EXT_TAG_SUPPORTED = "true")) then
        PF0_DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '1';
      elsif((PF0_DEV_CAP_EXT_TAG_SUPPORTED = "FALSE") or (PF0_DEV_CAP_EXT_TAG_SUPPORTED= "false")) then
        PF0_DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DEV_CAP_EXT_TAG_SUPPORTED = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE is
      if((PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = "TRUE") or (PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = "true")) then
        PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY <= '1';
      elsif((PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = "FALSE") or (PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE= "false")) then
        PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_DPA_CAP_SUB_STATE_CONTROL_EN is
      if((PF0_DPA_CAP_SUB_STATE_CONTROL_EN = "TRUE") or (PF0_DPA_CAP_SUB_STATE_CONTROL_EN = "true")) then
        PF0_DPA_CAP_SUB_STATE_CONTROL_EN_BINARY <= '1';
      elsif((PF0_DPA_CAP_SUB_STATE_CONTROL_EN = "FALSE") or (PF0_DPA_CAP_SUB_STATE_CONTROL_EN= "false")) then
        PF0_DPA_CAP_SUB_STATE_CONTROL_EN_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_DPA_CAP_SUB_STATE_CONTROL_EN = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_EXPANSION_ROM_ENABLE is
      if((PF0_EXPANSION_ROM_ENABLE = "FALSE") or (PF0_EXPANSION_ROM_ENABLE = "false")) then
        PF0_EXPANSION_ROM_ENABLE_BINARY <= '0';
      elsif((PF0_EXPANSION_ROM_ENABLE = "TRUE") or (PF0_EXPANSION_ROM_ENABLE= "true")) then
        PF0_EXPANSION_ROM_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF0_EXPANSION_ROM_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_LINK_STATUS_SLOT_CLOCK_CONFIG is
      if((PF0_LINK_STATUS_SLOT_CLOCK_CONFIG = "TRUE") or (PF0_LINK_STATUS_SLOT_CLOCK_CONFIG = "true")) then
        PF0_LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY <= '1';
      elsif((PF0_LINK_STATUS_SLOT_CLOCK_CONFIG = "FALSE") or (PF0_LINK_STATUS_SLOT_CLOCK_CONFIG= "false")) then
        PF0_LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_LINK_STATUS_SLOT_CLOCK_CONFIG = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_PB_CAP_SYSTEM_ALLOCATED is
      if((PF0_PB_CAP_SYSTEM_ALLOCATED = "FALSE") or (PF0_PB_CAP_SYSTEM_ALLOCATED = "false")) then
        PF0_PB_CAP_SYSTEM_ALLOCATED_BINARY <= '0';
      elsif((PF0_PB_CAP_SYSTEM_ALLOCATED = "TRUE") or (PF0_PB_CAP_SYSTEM_ALLOCATED= "true")) then
        PF0_PB_CAP_SYSTEM_ALLOCATED_BINARY <= '1';
      else
        assert FALSE report "Error : PF0_PB_CAP_SYSTEM_ALLOCATED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_PM_CAP_PMESUPPORT_D0 is
      if((PF0_PM_CAP_PMESUPPORT_D0 = "TRUE") or (PF0_PM_CAP_PMESUPPORT_D0 = "true")) then
        PF0_PM_CAP_PMESUPPORT_D0_BINARY <= '1';
      elsif((PF0_PM_CAP_PMESUPPORT_D0 = "FALSE") or (PF0_PM_CAP_PMESUPPORT_D0= "false")) then
        PF0_PM_CAP_PMESUPPORT_D0_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_PM_CAP_PMESUPPORT_D0 = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_PM_CAP_PMESUPPORT_D1 is
      if((PF0_PM_CAP_PMESUPPORT_D1 = "TRUE") or (PF0_PM_CAP_PMESUPPORT_D1 = "true")) then
        PF0_PM_CAP_PMESUPPORT_D1_BINARY <= '1';
      elsif((PF0_PM_CAP_PMESUPPORT_D1 = "FALSE") or (PF0_PM_CAP_PMESUPPORT_D1= "false")) then
        PF0_PM_CAP_PMESUPPORT_D1_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_PM_CAP_PMESUPPORT_D1 = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_PM_CAP_PMESUPPORT_D3HOT is
      if((PF0_PM_CAP_PMESUPPORT_D3HOT = "TRUE") or (PF0_PM_CAP_PMESUPPORT_D3HOT = "true")) then
        PF0_PM_CAP_PMESUPPORT_D3HOT_BINARY <= '1';
      elsif((PF0_PM_CAP_PMESUPPORT_D3HOT = "FALSE") or (PF0_PM_CAP_PMESUPPORT_D3HOT= "false")) then
        PF0_PM_CAP_PMESUPPORT_D3HOT_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_PM_CAP_PMESUPPORT_D3HOT = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_PM_CAP_SUPP_D1_STATE is
      if((PF0_PM_CAP_SUPP_D1_STATE = "TRUE") or (PF0_PM_CAP_SUPP_D1_STATE = "true")) then
        PF0_PM_CAP_SUPP_D1_STATE_BINARY <= '1';
      elsif((PF0_PM_CAP_SUPP_D1_STATE = "FALSE") or (PF0_PM_CAP_SUPP_D1_STATE= "false")) then
        PF0_PM_CAP_SUPP_D1_STATE_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_PM_CAP_SUPP_D1_STATE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_PM_CSR_NOSOFTRESET is
      if((PF0_PM_CSR_NOSOFTRESET = "TRUE") or (PF0_PM_CSR_NOSOFTRESET = "true")) then
        PF0_PM_CSR_NOSOFTRESET_BINARY <= '1';
      elsif((PF0_PM_CSR_NOSOFTRESET = "FALSE") or (PF0_PM_CSR_NOSOFTRESET= "false")) then
        PF0_PM_CSR_NOSOFTRESET_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_PM_CSR_NOSOFTRESET = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_RBAR_CAP_ENABLE is
      if((PF0_RBAR_CAP_ENABLE = "FALSE") or (PF0_RBAR_CAP_ENABLE = "false")) then
        PF0_RBAR_CAP_ENABLE_BINARY <= '0';
      elsif((PF0_RBAR_CAP_ENABLE = "TRUE") or (PF0_RBAR_CAP_ENABLE= "true")) then
        PF0_RBAR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF0_RBAR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((PF0_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (PF0_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        PF0_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((PF0_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (PF0_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        PF0_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF0_TPHR_CAP_ENABLE is
      if((PF0_TPHR_CAP_ENABLE = "FALSE") or (PF0_TPHR_CAP_ENABLE = "false")) then
        PF0_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((PF0_TPHR_CAP_ENABLE = "TRUE") or (PF0_TPHR_CAP_ENABLE= "true")) then
        PF0_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF0_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF0_TPHR_CAP_INT_VEC_MODE is
      if((PF0_TPHR_CAP_INT_VEC_MODE = "TRUE") or (PF0_TPHR_CAP_INT_VEC_MODE = "true")) then
        PF0_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((PF0_TPHR_CAP_INT_VEC_MODE = "FALSE") or (PF0_TPHR_CAP_INT_VEC_MODE= "false")) then
        PF0_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : PF0_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF1_AER_CAP_ECRC_CHECK_CAPABLE is
      if((PF1_AER_CAP_ECRC_CHECK_CAPABLE = "FALSE") or (PF1_AER_CAP_ECRC_CHECK_CAPABLE = "false")) then
        PF1_AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '0';
      elsif((PF1_AER_CAP_ECRC_CHECK_CAPABLE = "TRUE") or (PF1_AER_CAP_ECRC_CHECK_CAPABLE= "true")) then
        PF1_AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF1_AER_CAP_ECRC_CHECK_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF1_AER_CAP_ECRC_GEN_CAPABLE is
      if((PF1_AER_CAP_ECRC_GEN_CAPABLE = "FALSE") or (PF1_AER_CAP_ECRC_GEN_CAPABLE = "false")) then
        PF1_AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '0';
      elsif((PF1_AER_CAP_ECRC_GEN_CAPABLE = "TRUE") or (PF1_AER_CAP_ECRC_GEN_CAPABLE= "true")) then
        PF1_AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF1_AER_CAP_ECRC_GEN_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF1_DPA_CAP_SUB_STATE_CONTROL_EN is
      if((PF1_DPA_CAP_SUB_STATE_CONTROL_EN = "TRUE") or (PF1_DPA_CAP_SUB_STATE_CONTROL_EN = "true")) then
        PF1_DPA_CAP_SUB_STATE_CONTROL_EN_BINARY <= '1';
      elsif((PF1_DPA_CAP_SUB_STATE_CONTROL_EN = "FALSE") or (PF1_DPA_CAP_SUB_STATE_CONTROL_EN= "false")) then
        PF1_DPA_CAP_SUB_STATE_CONTROL_EN_BINARY <= '0';
      else
        assert FALSE report "Error : PF1_DPA_CAP_SUB_STATE_CONTROL_EN = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF1_EXPANSION_ROM_ENABLE is
      if((PF1_EXPANSION_ROM_ENABLE = "FALSE") or (PF1_EXPANSION_ROM_ENABLE = "false")) then
        PF1_EXPANSION_ROM_ENABLE_BINARY <= '0';
      elsif((PF1_EXPANSION_ROM_ENABLE = "TRUE") or (PF1_EXPANSION_ROM_ENABLE= "true")) then
        PF1_EXPANSION_ROM_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF1_EXPANSION_ROM_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF1_PB_CAP_SYSTEM_ALLOCATED is
      if((PF1_PB_CAP_SYSTEM_ALLOCATED = "FALSE") or (PF1_PB_CAP_SYSTEM_ALLOCATED = "false")) then
        PF1_PB_CAP_SYSTEM_ALLOCATED_BINARY <= '0';
      elsif((PF1_PB_CAP_SYSTEM_ALLOCATED = "TRUE") or (PF1_PB_CAP_SYSTEM_ALLOCATED= "true")) then
        PF1_PB_CAP_SYSTEM_ALLOCATED_BINARY <= '1';
      else
        assert FALSE report "Error : PF1_PB_CAP_SYSTEM_ALLOCATED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF1_RBAR_CAP_ENABLE is
      if((PF1_RBAR_CAP_ENABLE = "FALSE") or (PF1_RBAR_CAP_ENABLE = "false")) then
        PF1_RBAR_CAP_ENABLE_BINARY <= '0';
      elsif((PF1_RBAR_CAP_ENABLE = "TRUE") or (PF1_RBAR_CAP_ENABLE= "true")) then
        PF1_RBAR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF1_RBAR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF1_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((PF1_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (PF1_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        PF1_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((PF1_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (PF1_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        PF1_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : PF1_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PF1_TPHR_CAP_ENABLE is
      if((PF1_TPHR_CAP_ENABLE = "FALSE") or (PF1_TPHR_CAP_ENABLE = "false")) then
        PF1_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((PF1_TPHR_CAP_ENABLE = "TRUE") or (PF1_TPHR_CAP_ENABLE= "true")) then
        PF1_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PF1_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PF1_TPHR_CAP_INT_VEC_MODE is
      if((PF1_TPHR_CAP_INT_VEC_MODE = "TRUE") or (PF1_TPHR_CAP_INT_VEC_MODE = "true")) then
        PF1_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((PF1_TPHR_CAP_INT_VEC_MODE = "FALSE") or (PF1_TPHR_CAP_INT_VEC_MODE= "false")) then
        PF1_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : PF1_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PL_DISABLE_EI_INFER_IN_L0 is
      if((PL_DISABLE_EI_INFER_IN_L0 = "FALSE") or (PL_DISABLE_EI_INFER_IN_L0 = "false")) then
        PL_DISABLE_EI_INFER_IN_L0_BINARY <= '0';
      elsif((PL_DISABLE_EI_INFER_IN_L0 = "TRUE") or (PL_DISABLE_EI_INFER_IN_L0= "true")) then
        PL_DISABLE_EI_INFER_IN_L0_BINARY <= '1';
      else
        assert FALSE report "Error : PL_DISABLE_EI_INFER_IN_L0 = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_DISABLE_GEN3_DC_BALANCE is
      if((PL_DISABLE_GEN3_DC_BALANCE = "FALSE") or (PL_DISABLE_GEN3_DC_BALANCE = "false")) then
        PL_DISABLE_GEN3_DC_BALANCE_BINARY <= '0';
      elsif((PL_DISABLE_GEN3_DC_BALANCE = "TRUE") or (PL_DISABLE_GEN3_DC_BALANCE= "true")) then
        PL_DISABLE_GEN3_DC_BALANCE_BINARY <= '1';
      else
        assert FALSE report "Error : PL_DISABLE_GEN3_DC_BALANCE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_DISABLE_SCRAMBLING is
      if((PL_DISABLE_SCRAMBLING = "FALSE") or (PL_DISABLE_SCRAMBLING = "false")) then
        PL_DISABLE_SCRAMBLING_BINARY <= '0';
      elsif((PL_DISABLE_SCRAMBLING = "TRUE") or (PL_DISABLE_SCRAMBLING= "true")) then
        PL_DISABLE_SCRAMBLING_BINARY <= '1';
      else
        assert FALSE report "Error : PL_DISABLE_SCRAMBLING = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_DISABLE_UPCONFIG_CAPABLE is
      if((PL_DISABLE_UPCONFIG_CAPABLE = "FALSE") or (PL_DISABLE_UPCONFIG_CAPABLE = "false")) then
        PL_DISABLE_UPCONFIG_CAPABLE_BINARY <= '0';
      elsif((PL_DISABLE_UPCONFIG_CAPABLE = "TRUE") or (PL_DISABLE_UPCONFIG_CAPABLE= "true")) then
        PL_DISABLE_UPCONFIG_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : PL_DISABLE_UPCONFIG_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_EQ_ADAPT_DISABLE_COEFF_CHECK is
      if((PL_EQ_ADAPT_DISABLE_COEFF_CHECK = "FALSE") or (PL_EQ_ADAPT_DISABLE_COEFF_CHECK = "false")) then
        PL_EQ_ADAPT_DISABLE_COEFF_CHECK_BINARY <= '0';
      elsif((PL_EQ_ADAPT_DISABLE_COEFF_CHECK = "TRUE") or (PL_EQ_ADAPT_DISABLE_COEFF_CHECK= "true")) then
        PL_EQ_ADAPT_DISABLE_COEFF_CHECK_BINARY <= '1';
      else
        assert FALSE report "Error : PL_EQ_ADAPT_DISABLE_COEFF_CHECK = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_EQ_ADAPT_DISABLE_PRESET_CHECK is
      if((PL_EQ_ADAPT_DISABLE_PRESET_CHECK = "FALSE") or (PL_EQ_ADAPT_DISABLE_PRESET_CHECK = "false")) then
        PL_EQ_ADAPT_DISABLE_PRESET_CHECK_BINARY <= '0';
      elsif((PL_EQ_ADAPT_DISABLE_PRESET_CHECK = "TRUE") or (PL_EQ_ADAPT_DISABLE_PRESET_CHECK= "true")) then
        PL_EQ_ADAPT_DISABLE_PRESET_CHECK_BINARY <= '1';
      else
        assert FALSE report "Error : PL_EQ_ADAPT_DISABLE_PRESET_CHECK = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_EQ_BYPASS_PHASE23 is
      if((PL_EQ_BYPASS_PHASE23 = "FALSE") or (PL_EQ_BYPASS_PHASE23 = "false")) then
        PL_EQ_BYPASS_PHASE23_BINARY <= '0';
      elsif((PL_EQ_BYPASS_PHASE23 = "TRUE") or (PL_EQ_BYPASS_PHASE23= "true")) then
        PL_EQ_BYPASS_PHASE23_BINARY <= '1';
      else
        assert FALSE report "Error : PL_EQ_BYPASS_PHASE23 = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_EQ_SHORT_ADAPT_PHASE is
      if((PL_EQ_SHORT_ADAPT_PHASE = "FALSE") or (PL_EQ_SHORT_ADAPT_PHASE = "false")) then
        PL_EQ_SHORT_ADAPT_PHASE_BINARY <= '0';
      elsif((PL_EQ_SHORT_ADAPT_PHASE = "TRUE") or (PL_EQ_SHORT_ADAPT_PHASE= "true")) then
        PL_EQ_SHORT_ADAPT_PHASE_BINARY <= '1';
      else
        assert FALSE report "Error : PL_EQ_SHORT_ADAPT_PHASE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_SIM_FAST_LINK_TRAINING is
      if((PL_SIM_FAST_LINK_TRAINING = "FALSE") or (PL_SIM_FAST_LINK_TRAINING = "false")) then
        PL_SIM_FAST_LINK_TRAINING_BINARY <= '0';
      elsif((PL_SIM_FAST_LINK_TRAINING = "TRUE") or (PL_SIM_FAST_LINK_TRAINING= "true")) then
        PL_SIM_FAST_LINK_TRAINING_BINARY <= '1';
      else
        assert FALSE report "Error : PL_SIM_FAST_LINK_TRAINING = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_UPSTREAM_FACING is
      if((PL_UPSTREAM_FACING = "TRUE") or (PL_UPSTREAM_FACING = "true")) then
        PL_UPSTREAM_FACING_BINARY <= '1';
      elsif((PL_UPSTREAM_FACING = "FALSE") or (PL_UPSTREAM_FACING= "false")) then
        PL_UPSTREAM_FACING_BINARY <= '0';
      else
        assert FALSE report "Error : PL_UPSTREAM_FACING = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PM_ENABLE_SLOT_POWER_CAPTURE is
      if((PM_ENABLE_SLOT_POWER_CAPTURE = "TRUE") or (PM_ENABLE_SLOT_POWER_CAPTURE = "true")) then
        PM_ENABLE_SLOT_POWER_CAPTURE_BINARY <= '1';
      elsif((PM_ENABLE_SLOT_POWER_CAPTURE = "FALSE") or (PM_ENABLE_SLOT_POWER_CAPTURE= "false")) then
        PM_ENABLE_SLOT_POWER_CAPTURE_BINARY <= '0';
      else
        assert FALSE report "Error : PM_ENABLE_SLOT_POWER_CAPTURE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case SRIOV_CAP_ENABLE is
      if((SRIOV_CAP_ENABLE = "FALSE") or (SRIOV_CAP_ENABLE = "false")) then
        SRIOV_CAP_ENABLE_BINARY <= '0';
      elsif((SRIOV_CAP_ENABLE = "TRUE") or (SRIOV_CAP_ENABLE= "true")) then
        SRIOV_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : SRIOV_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_ENABLE_MESSAGE_RID_CHECK_ENABLE is
      if((TL_ENABLE_MESSAGE_RID_CHECK_ENABLE = "TRUE") or (TL_ENABLE_MESSAGE_RID_CHECK_ENABLE = "true")) then
        TL_ENABLE_MESSAGE_RID_CHECK_ENABLE_BINARY <= '1';
      elsif((TL_ENABLE_MESSAGE_RID_CHECK_ENABLE = "FALSE") or (TL_ENABLE_MESSAGE_RID_CHECK_ENABLE= "false")) then
        TL_ENABLE_MESSAGE_RID_CHECK_ENABLE_BINARY <= '0';
      else
        assert FALSE report "Error : TL_ENABLE_MESSAGE_RID_CHECK_ENABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE is
      if((TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE = "FALSE") or (TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE = "false")) then
        TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE_BINARY <= '0';
      elsif((TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE = "TRUE") or (TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE= "true")) then
        TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE is
      if((TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE = "FALSE") or (TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE = "false")) then
        TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE_BINARY <= '0';
      elsif((TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE = "TRUE") or (TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE= "true")) then
        TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_LEGACY_MODE_ENABLE is
      if((TL_LEGACY_MODE_ENABLE = "FALSE") or (TL_LEGACY_MODE_ENABLE = "false")) then
        TL_LEGACY_MODE_ENABLE_BINARY <= '0';
      elsif((TL_LEGACY_MODE_ENABLE = "TRUE") or (TL_LEGACY_MODE_ENABLE= "true")) then
        TL_LEGACY_MODE_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : TL_LEGACY_MODE_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_PF_ENABLE_REG is
      if((TL_PF_ENABLE_REG = "FALSE") or (TL_PF_ENABLE_REG = "false")) then
        TL_PF_ENABLE_REG_BINARY <= '0';
      elsif((TL_PF_ENABLE_REG = "TRUE") or (TL_PF_ENABLE_REG= "true")) then
        TL_PF_ENABLE_REG_BINARY <= '1';
      else
        assert FALSE report "Error : TL_PF_ENABLE_REG = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_TAG_MGMT_ENABLE is
      if((TL_TAG_MGMT_ENABLE = "TRUE") or (TL_TAG_MGMT_ENABLE = "true")) then
        TL_TAG_MGMT_ENABLE_BINARY <= '1';
      elsif((TL_TAG_MGMT_ENABLE = "FALSE") or (TL_TAG_MGMT_ENABLE= "false")) then
        TL_TAG_MGMT_ENABLE_BINARY <= '0';
      else
        assert FALSE report "Error : TL_TAG_MGMT_ENABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF0_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((VF0_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (VF0_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        VF0_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((VF0_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (VF0_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        VF0_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF0_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF0_TPHR_CAP_ENABLE is
      if((VF0_TPHR_CAP_ENABLE = "FALSE") or (VF0_TPHR_CAP_ENABLE = "false")) then
        VF0_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((VF0_TPHR_CAP_ENABLE = "TRUE") or (VF0_TPHR_CAP_ENABLE= "true")) then
        VF0_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : VF0_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VF0_TPHR_CAP_INT_VEC_MODE is
      if((VF0_TPHR_CAP_INT_VEC_MODE = "TRUE") or (VF0_TPHR_CAP_INT_VEC_MODE = "true")) then
        VF0_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((VF0_TPHR_CAP_INT_VEC_MODE = "FALSE") or (VF0_TPHR_CAP_INT_VEC_MODE= "false")) then
        VF0_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF0_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF1_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((VF1_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (VF1_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        VF1_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((VF1_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (VF1_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        VF1_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF1_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF1_TPHR_CAP_ENABLE is
      if((VF1_TPHR_CAP_ENABLE = "FALSE") or (VF1_TPHR_CAP_ENABLE = "false")) then
        VF1_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((VF1_TPHR_CAP_ENABLE = "TRUE") or (VF1_TPHR_CAP_ENABLE= "true")) then
        VF1_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : VF1_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VF1_TPHR_CAP_INT_VEC_MODE is
      if((VF1_TPHR_CAP_INT_VEC_MODE = "TRUE") or (VF1_TPHR_CAP_INT_VEC_MODE = "true")) then
        VF1_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((VF1_TPHR_CAP_INT_VEC_MODE = "FALSE") or (VF1_TPHR_CAP_INT_VEC_MODE= "false")) then
        VF1_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF1_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF2_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((VF2_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (VF2_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        VF2_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((VF2_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (VF2_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        VF2_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF2_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF2_TPHR_CAP_ENABLE is
      if((VF2_TPHR_CAP_ENABLE = "FALSE") or (VF2_TPHR_CAP_ENABLE = "false")) then
        VF2_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((VF2_TPHR_CAP_ENABLE = "TRUE") or (VF2_TPHR_CAP_ENABLE= "true")) then
        VF2_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : VF2_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VF2_TPHR_CAP_INT_VEC_MODE is
      if((VF2_TPHR_CAP_INT_VEC_MODE = "TRUE") or (VF2_TPHR_CAP_INT_VEC_MODE = "true")) then
        VF2_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((VF2_TPHR_CAP_INT_VEC_MODE = "FALSE") or (VF2_TPHR_CAP_INT_VEC_MODE= "false")) then
        VF2_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF2_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF3_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((VF3_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (VF3_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        VF3_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((VF3_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (VF3_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        VF3_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF3_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF3_TPHR_CAP_ENABLE is
      if((VF3_TPHR_CAP_ENABLE = "FALSE") or (VF3_TPHR_CAP_ENABLE = "false")) then
        VF3_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((VF3_TPHR_CAP_ENABLE = "TRUE") or (VF3_TPHR_CAP_ENABLE= "true")) then
        VF3_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : VF3_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VF3_TPHR_CAP_INT_VEC_MODE is
      if((VF3_TPHR_CAP_INT_VEC_MODE = "TRUE") or (VF3_TPHR_CAP_INT_VEC_MODE = "true")) then
        VF3_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((VF3_TPHR_CAP_INT_VEC_MODE = "FALSE") or (VF3_TPHR_CAP_INT_VEC_MODE= "false")) then
        VF3_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF3_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF4_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((VF4_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (VF4_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        VF4_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((VF4_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (VF4_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        VF4_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF4_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF4_TPHR_CAP_ENABLE is
      if((VF4_TPHR_CAP_ENABLE = "FALSE") or (VF4_TPHR_CAP_ENABLE = "false")) then
        VF4_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((VF4_TPHR_CAP_ENABLE = "TRUE") or (VF4_TPHR_CAP_ENABLE= "true")) then
        VF4_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : VF4_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VF4_TPHR_CAP_INT_VEC_MODE is
      if((VF4_TPHR_CAP_INT_VEC_MODE = "TRUE") or (VF4_TPHR_CAP_INT_VEC_MODE = "true")) then
        VF4_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((VF4_TPHR_CAP_INT_VEC_MODE = "FALSE") or (VF4_TPHR_CAP_INT_VEC_MODE= "false")) then
        VF4_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF4_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF5_TPHR_CAP_DEV_SPECIFIC_MODE is
      if((VF5_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE") or (VF5_TPHR_CAP_DEV_SPECIFIC_MODE = "true")) then
        VF5_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '1';
      elsif((VF5_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE") or (VF5_TPHR_CAP_DEV_SPECIFIC_MODE= "false")) then
        VF5_TPHR_CAP_DEV_SPECIFIC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF5_TPHR_CAP_DEV_SPECIFIC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VF5_TPHR_CAP_ENABLE is
      if((VF5_TPHR_CAP_ENABLE = "FALSE") or (VF5_TPHR_CAP_ENABLE = "false")) then
        VF5_TPHR_CAP_ENABLE_BINARY <= '0';
      elsif((VF5_TPHR_CAP_ENABLE = "TRUE") or (VF5_TPHR_CAP_ENABLE= "true")) then
        VF5_TPHR_CAP_ENABLE_BINARY <= '1';
      else
        assert FALSE report "Error : VF5_TPHR_CAP_ENABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VF5_TPHR_CAP_INT_VEC_MODE is
      if((VF5_TPHR_CAP_INT_VEC_MODE = "TRUE") or (VF5_TPHR_CAP_INT_VEC_MODE = "true")) then
        VF5_TPHR_CAP_INT_VEC_MODE_BINARY <= '1';
      elsif((VF5_TPHR_CAP_INT_VEC_MODE = "FALSE") or (VF5_TPHR_CAP_INT_VEC_MODE= "false")) then
        VF5_TPHR_CAP_INT_VEC_MODE_BINARY <= '0';
      else
        assert FALSE report "Error : VF5_TPHR_CAP_INT_VEC_MODE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    case SPARE_BIT0 is
      when  0   =>  SPARE_BIT0_BINARY <= '0';
      when  1   =>  SPARE_BIT0_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT0 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT1 is
      when  0   =>  SPARE_BIT1_BINARY <= '0';
      when  1   =>  SPARE_BIT1_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT1 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT2 is
      when  0   =>  SPARE_BIT2_BINARY <= '0';
      when  1   =>  SPARE_BIT2_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT2 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT3 is
      when  0   =>  SPARE_BIT3_BINARY <= '0';
      when  1   =>  SPARE_BIT3_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT3 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT4 is
      when  0   =>  SPARE_BIT4_BINARY <= '0';
      when  1   =>  SPARE_BIT4_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT4 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT5 is
      when  0   =>  SPARE_BIT5_BINARY <= '0';
      when  1   =>  SPARE_BIT5_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT5 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT6 is
      when  0   =>  SPARE_BIT6_BINARY <= '0';
      when  1   =>  SPARE_BIT6_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT6 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT7 is
      when  0   =>  SPARE_BIT7_BINARY <= '0';
      when  1   =>  SPARE_BIT7_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT7 is not in range 0 .. 1." severity error;
    end case;
    case SPARE_BIT8 is
      when  0   =>  SPARE_BIT8_BINARY <= '0';
      when  1   =>  SPARE_BIT8_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SPARE_BIT8 is not in range 0 .. 1." severity error;
    end case;
    if ((LL_ACK_TIMEOUT_FUNC >= 0) and (LL_ACK_TIMEOUT_FUNC <= 3)) then
      LL_ACK_TIMEOUT_FUNC_BINARY <= CONV_STD_LOGIC_VECTOR(LL_ACK_TIMEOUT_FUNC, 2);
    else
      assert FALSE report "Error : LL_ACK_TIMEOUT_FUNC is not in range 0 .. 3." severity error;
    end if;
    if ((LL_REPLAY_TIMEOUT_FUNC >= 0) and (LL_REPLAY_TIMEOUT_FUNC <= 3)) then
      LL_REPLAY_TIMEOUT_FUNC_BINARY <= CONV_STD_LOGIC_VECTOR(LL_REPLAY_TIMEOUT_FUNC, 2);
    else
      assert FALSE report "Error : LL_REPLAY_TIMEOUT_FUNC is not in range 0 .. 3." severity error;
    end if;
    if ((PF0_DEV_CAP_ENDPOINT_L0S_LATENCY >= 0) and (PF0_DEV_CAP_ENDPOINT_L0S_LATENCY <= 7)) then
      PF0_DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_DEV_CAP_ENDPOINT_L0S_LATENCY, 3);
    else
      assert FALSE report "Error : PF0_DEV_CAP_ENDPOINT_L0S_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_DEV_CAP_ENDPOINT_L1_LATENCY >= 0) and (PF0_DEV_CAP_ENDPOINT_L1_LATENCY <= 7)) then
      PF0_DEV_CAP_ENDPOINT_L1_LATENCY_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_DEV_CAP_ENDPOINT_L1_LATENCY, 3);
    else
      assert FALSE report "Error : PF0_DEV_CAP_ENDPOINT_L1_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_ASPM_SUPPORT >= 0) and (PF0_LINK_CAP_ASPM_SUPPORT <= 3)) then
      PF0_LINK_CAP_ASPM_SUPPORT_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_ASPM_SUPPORT, 2);
    else
      assert FALSE report "Error : PF0_LINK_CAP_ASPM_SUPPORT is not in range 0 .. 3." severity error;
    end if;
    if ((PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 >= 0) and (PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 <= 7)) then
      PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 >= 0) and (PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 <= 7)) then
      PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 >= 0) and (PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 <= 7)) then
      PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 >= 0) and (PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 <= 7)) then
      PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 >= 0) and (PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 <= 7)) then
      PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 >= 0) and (PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 <= 7)) then
      PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 >= 0) and (PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 <= 7)) then
      PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 >= 0) and (PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 <= 7)) then
      PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 >= 0) and (PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 <= 7)) then
      PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 >= 0) and (PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 <= 7)) then
      PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 >= 0) and (PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 <= 7)) then
      PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 >= 0) and (PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 <= 7)) then
      PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3, 3);
    else
      assert FALSE report "Error : PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_MSIX_CAP_PBA_BIR >= 0) and (PF0_MSIX_CAP_PBA_BIR <= 7)) then
      PF0_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : PF0_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_MSIX_CAP_TABLE_BIR >= 0) and (PF0_MSIX_CAP_TABLE_BIR <= 7)) then
      PF0_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : PF0_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((PF0_MSI_CAP_MULTIMSGCAP >= 0) and (PF0_MSI_CAP_MULTIMSGCAP <= 7)) then
      PF0_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(PF0_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : PF0_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((PF1_MSIX_CAP_PBA_BIR >= 0) and (PF1_MSIX_CAP_PBA_BIR <= 7)) then
      PF1_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(PF1_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : PF1_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((PF1_MSIX_CAP_TABLE_BIR >= 0) and (PF1_MSIX_CAP_TABLE_BIR <= 7)) then
      PF1_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(PF1_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : PF1_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((PF1_MSI_CAP_MULTIMSGCAP >= 0) and (PF1_MSI_CAP_MULTIMSGCAP <= 7)) then
      PF1_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(PF1_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : PF1_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((PL_N_FTS_COMCLK_GEN1 >= 0) and (PL_N_FTS_COMCLK_GEN1 <= 255)) then
      PL_N_FTS_COMCLK_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(PL_N_FTS_COMCLK_GEN1, 8);
    else
      assert FALSE report "Error : PL_N_FTS_COMCLK_GEN1 is not in range 0 .. 255." severity error;
    end if;
    if ((PL_N_FTS_COMCLK_GEN2 >= 0) and (PL_N_FTS_COMCLK_GEN2 <= 255)) then
      PL_N_FTS_COMCLK_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(PL_N_FTS_COMCLK_GEN2, 8);
    else
      assert FALSE report "Error : PL_N_FTS_COMCLK_GEN2 is not in range 0 .. 255." severity error;
    end if;
    if ((PL_N_FTS_COMCLK_GEN3 >= 0) and (PL_N_FTS_COMCLK_GEN3 <= 255)) then
      PL_N_FTS_COMCLK_GEN3_BINARY <= CONV_STD_LOGIC_VECTOR(PL_N_FTS_COMCLK_GEN3, 8);
    else
      assert FALSE report "Error : PL_N_FTS_COMCLK_GEN3 is not in range 0 .. 255." severity error;
    end if;
    if ((PL_N_FTS_GEN1 >= 0) and (PL_N_FTS_GEN1 <= 255)) then
      PL_N_FTS_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(PL_N_FTS_GEN1, 8);
    else
      assert FALSE report "Error : PL_N_FTS_GEN1 is not in range 0 .. 255." severity error;
    end if;
    if ((PL_N_FTS_GEN2 >= 0) and (PL_N_FTS_GEN2 <= 255)) then
      PL_N_FTS_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(PL_N_FTS_GEN2, 8);
    else
      assert FALSE report "Error : PL_N_FTS_GEN2 is not in range 0 .. 255." severity error;
    end if;
    if ((PL_N_FTS_GEN3 >= 0) and (PL_N_FTS_GEN3 <= 255)) then
      PL_N_FTS_GEN3_BINARY <= CONV_STD_LOGIC_VECTOR(PL_N_FTS_GEN3, 8);
    else
      assert FALSE report "Error : PL_N_FTS_GEN3 is not in range 0 .. 255." severity error;
    end if;
    if ((VF0_MSIX_CAP_PBA_BIR >= 0) and (VF0_MSIX_CAP_PBA_BIR <= 7)) then
      VF0_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF0_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : VF0_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF0_MSIX_CAP_TABLE_BIR >= 0) and (VF0_MSIX_CAP_TABLE_BIR <= 7)) then
      VF0_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF0_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : VF0_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF0_MSI_CAP_MULTIMSGCAP >= 0) and (VF0_MSI_CAP_MULTIMSGCAP <= 7)) then
      VF0_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(VF0_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : VF0_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((VF1_MSIX_CAP_PBA_BIR >= 0) and (VF1_MSIX_CAP_PBA_BIR <= 7)) then
      VF1_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF1_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : VF1_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF1_MSIX_CAP_TABLE_BIR >= 0) and (VF1_MSIX_CAP_TABLE_BIR <= 7)) then
      VF1_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF1_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : VF1_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF1_MSI_CAP_MULTIMSGCAP >= 0) and (VF1_MSI_CAP_MULTIMSGCAP <= 7)) then
      VF1_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(VF1_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : VF1_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((VF2_MSIX_CAP_PBA_BIR >= 0) and (VF2_MSIX_CAP_PBA_BIR <= 7)) then
      VF2_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF2_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : VF2_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF2_MSIX_CAP_TABLE_BIR >= 0) and (VF2_MSIX_CAP_TABLE_BIR <= 7)) then
      VF2_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF2_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : VF2_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF2_MSI_CAP_MULTIMSGCAP >= 0) and (VF2_MSI_CAP_MULTIMSGCAP <= 7)) then
      VF2_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(VF2_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : VF2_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((VF3_MSIX_CAP_PBA_BIR >= 0) and (VF3_MSIX_CAP_PBA_BIR <= 7)) then
      VF3_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF3_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : VF3_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF3_MSIX_CAP_TABLE_BIR >= 0) and (VF3_MSIX_CAP_TABLE_BIR <= 7)) then
      VF3_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF3_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : VF3_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF3_MSI_CAP_MULTIMSGCAP >= 0) and (VF3_MSI_CAP_MULTIMSGCAP <= 7)) then
      VF3_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(VF3_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : VF3_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((VF4_MSIX_CAP_PBA_BIR >= 0) and (VF4_MSIX_CAP_PBA_BIR <= 7)) then
      VF4_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF4_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : VF4_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF4_MSIX_CAP_TABLE_BIR >= 0) and (VF4_MSIX_CAP_TABLE_BIR <= 7)) then
      VF4_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF4_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : VF4_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF4_MSI_CAP_MULTIMSGCAP >= 0) and (VF4_MSI_CAP_MULTIMSGCAP <= 7)) then
      VF4_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(VF4_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : VF4_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((VF5_MSIX_CAP_PBA_BIR >= 0) and (VF5_MSIX_CAP_PBA_BIR <= 7)) then
      VF5_MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF5_MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : VF5_MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF5_MSIX_CAP_TABLE_BIR >= 0) and (VF5_MSIX_CAP_TABLE_BIR <= 7)) then
      VF5_MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(VF5_MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : VF5_MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((VF5_MSI_CAP_MULTIMSGCAP >= 0) and (VF5_MSI_CAP_MULTIMSGCAP <= 7)) then
      VF5_MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(VF5_MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : VF5_MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    wait;
    end process INIPROC;
    CFGCURRENTSPEED <= CFGCURRENTSPEED_out;
    CFGDPASUBSTATECHANGE <= CFGDPASUBSTATECHANGE_out;
    CFGERRCOROUT <= CFGERRCOROUT_out;
    CFGERRFATALOUT <= CFGERRFATALOUT_out;
    CFGERRNONFATALOUT <= CFGERRNONFATALOUT_out;
    CFGEXTFUNCTIONNUMBER <= CFGEXTFUNCTIONNUMBER_out;
    CFGEXTREADRECEIVED <= CFGEXTREADRECEIVED_out;
    CFGEXTREGISTERNUMBER <= CFGEXTREGISTERNUMBER_out;
    CFGEXTWRITEBYTEENABLE <= CFGEXTWRITEBYTEENABLE_out;
    CFGEXTWRITEDATA <= CFGEXTWRITEDATA_out;
    CFGEXTWRITERECEIVED <= CFGEXTWRITERECEIVED_out;
    CFGFCCPLD <= CFGFCCPLD_out;
    CFGFCCPLH <= CFGFCCPLH_out;
    CFGFCNPD <= CFGFCNPD_out;
    CFGFCNPH <= CFGFCNPH_out;
    CFGFCPD <= CFGFCPD_out;
    CFGFCPH <= CFGFCPH_out;
    CFGFLRINPROCESS <= CFGFLRINPROCESS_out;
    CFGFUNCTIONPOWERSTATE <= CFGFUNCTIONPOWERSTATE_out;
    CFGFUNCTIONSTATUS <= CFGFUNCTIONSTATUS_out;
    CFGHOTRESETOUT <= CFGHOTRESETOUT_out;
    CFGINPUTUPDATEDONE <= CFGINPUTUPDATEDONE_out;
    CFGINTERRUPTAOUTPUT <= CFGINTERRUPTAOUTPUT_out;
    CFGINTERRUPTBOUTPUT <= CFGINTERRUPTBOUTPUT_out;
    CFGINTERRUPTCOUTPUT <= CFGINTERRUPTCOUTPUT_out;
    CFGINTERRUPTDOUTPUT <= CFGINTERRUPTDOUTPUT_out;
    CFGINTERRUPTMSIDATA <= CFGINTERRUPTMSIDATA_out;
    CFGINTERRUPTMSIENABLE <= CFGINTERRUPTMSIENABLE_out;
    CFGINTERRUPTMSIFAIL <= CFGINTERRUPTMSIFAIL_out;
    CFGINTERRUPTMSIMASKUPDATE <= CFGINTERRUPTMSIMASKUPDATE_out;
    CFGINTERRUPTMSIMMENABLE <= CFGINTERRUPTMSIMMENABLE_out;
    CFGINTERRUPTMSISENT <= CFGINTERRUPTMSISENT_out;
    CFGINTERRUPTMSIVFENABLE <= CFGINTERRUPTMSIVFENABLE_out;
    CFGINTERRUPTMSIXENABLE <= CFGINTERRUPTMSIXENABLE_out;
    CFGINTERRUPTMSIXFAIL <= CFGINTERRUPTMSIXFAIL_out;
    CFGINTERRUPTMSIXMASK <= CFGINTERRUPTMSIXMASK_out;
    CFGINTERRUPTMSIXSENT <= CFGINTERRUPTMSIXSENT_out;
    CFGINTERRUPTMSIXVFENABLE <= CFGINTERRUPTMSIXVFENABLE_out;
    CFGINTERRUPTMSIXVFMASK <= CFGINTERRUPTMSIXVFMASK_out;
    CFGINTERRUPTSENT <= CFGINTERRUPTSENT_out;
    CFGLINKPOWERSTATE <= CFGLINKPOWERSTATE_out;
    CFGLOCALERROR <= CFGLOCALERROR_out;
    CFGLTRENABLE <= CFGLTRENABLE_out;
    CFGLTSSMSTATE <= CFGLTSSMSTATE_out;
    CFGMAXPAYLOAD <= CFGMAXPAYLOAD_out;
    CFGMAXREADREQ <= CFGMAXREADREQ_out;
    CFGMCUPDATEDONE <= CFGMCUPDATEDONE_out;
    CFGMGMTREADDATA <= CFGMGMTREADDATA_out;
    CFGMGMTREADWRITEDONE <= CFGMGMTREADWRITEDONE_out;
    CFGMSGRECEIVED <= CFGMSGRECEIVED_out;
    CFGMSGRECEIVEDDATA <= CFGMSGRECEIVEDDATA_out;
    CFGMSGRECEIVEDTYPE <= CFGMSGRECEIVEDTYPE_out;
    CFGMSGTRANSMITDONE <= CFGMSGTRANSMITDONE_out;
    CFGNEGOTIATEDWIDTH <= CFGNEGOTIATEDWIDTH_out;
    CFGOBFFENABLE <= CFGOBFFENABLE_out;
    CFGPERFUNCSTATUSDATA <= CFGPERFUNCSTATUSDATA_out;
    CFGPERFUNCTIONUPDATEDONE <= CFGPERFUNCTIONUPDATEDONE_out;
    CFGPHYLINKDOWN <= CFGPHYLINKDOWN_out;
    CFGPHYLINKSTATUS <= CFGPHYLINKSTATUS_out;
    CFGPLSTATUSCHANGE <= CFGPLSTATUSCHANGE_out;
    CFGPOWERSTATECHANGEINTERRUPT <= CFGPOWERSTATECHANGEINTERRUPT_out;
    CFGRCBSTATUS <= CFGRCBSTATUS_out;
    CFGTPHFUNCTIONNUM <= CFGTPHFUNCTIONNUM_out;
    CFGTPHREQUESTERENABLE <= CFGTPHREQUESTERENABLE_out;
    CFGTPHSTMODE <= CFGTPHSTMODE_out;
    CFGTPHSTTADDRESS <= CFGTPHSTTADDRESS_out;
    CFGTPHSTTREADENABLE <= CFGTPHSTTREADENABLE_out;
    CFGTPHSTTWRITEBYTEVALID <= CFGTPHSTTWRITEBYTEVALID_out;
    CFGTPHSTTWRITEDATA <= CFGTPHSTTWRITEDATA_out;
    CFGTPHSTTWRITEENABLE <= CFGTPHSTTWRITEENABLE_out;
    CFGVFFLRINPROCESS <= CFGVFFLRINPROCESS_out;
    CFGVFPOWERSTATE <= CFGVFPOWERSTATE_out;
    CFGVFSTATUS <= CFGVFSTATUS_out;
    CFGVFTPHREQUESTERENABLE <= CFGVFTPHREQUESTERENABLE_out;
    CFGVFTPHSTMODE <= CFGVFTPHSTMODE_out;
    DBGDATAOUT <= DBGDATAOUT_out;
    DRPDO <= DRPDO_out;
    DRPRDY <= DRPRDY_out;
    MAXISCQTDATA <= MAXISCQTDATA_out;
    MAXISCQTKEEP <= MAXISCQTKEEP_out;
    MAXISCQTLAST <= MAXISCQTLAST_out;
    MAXISCQTUSER <= MAXISCQTUSER_out;
    MAXISCQTVALID <= MAXISCQTVALID_out;
    MAXISRCTDATA <= MAXISRCTDATA_out;
    MAXISRCTKEEP <= MAXISRCTKEEP_out;
    MAXISRCTLAST <= MAXISRCTLAST_out;
    MAXISRCTUSER <= MAXISRCTUSER_out;
    MAXISRCTVALID <= MAXISRCTVALID_out;
    MICOMPLETIONRAMREADADDRESSAL <= MICOMPLETIONRAMREADADDRESSAL_out;
    MICOMPLETIONRAMREADADDRESSAU <= MICOMPLETIONRAMREADADDRESSAU_out;
    MICOMPLETIONRAMREADADDRESSBL <= MICOMPLETIONRAMREADADDRESSBL_out;
    MICOMPLETIONRAMREADADDRESSBU <= MICOMPLETIONRAMREADADDRESSBU_out;
    MICOMPLETIONRAMREADENABLEL <= MICOMPLETIONRAMREADENABLEL_out;
    MICOMPLETIONRAMREADENABLEU <= MICOMPLETIONRAMREADENABLEU_out;
    MICOMPLETIONRAMWRITEADDRESSAL <= MICOMPLETIONRAMWRITEADDRESSAL_out;
    MICOMPLETIONRAMWRITEADDRESSAU <= MICOMPLETIONRAMWRITEADDRESSAU_out;
    MICOMPLETIONRAMWRITEADDRESSBL <= MICOMPLETIONRAMWRITEADDRESSBL_out;
    MICOMPLETIONRAMWRITEADDRESSBU <= MICOMPLETIONRAMWRITEADDRESSBU_out;
    MICOMPLETIONRAMWRITEDATAL <= MICOMPLETIONRAMWRITEDATAL_out;
    MICOMPLETIONRAMWRITEDATAU <= MICOMPLETIONRAMWRITEDATAU_out;
    MICOMPLETIONRAMWRITEENABLEL <= MICOMPLETIONRAMWRITEENABLEL_out;
    MICOMPLETIONRAMWRITEENABLEU <= MICOMPLETIONRAMWRITEENABLEU_out;
    MIREPLAYRAMADDRESS <= MIREPLAYRAMADDRESS_out;
    MIREPLAYRAMREADENABLE <= MIREPLAYRAMREADENABLE_out;
    MIREPLAYRAMWRITEDATA <= MIREPLAYRAMWRITEDATA_out;
    MIREPLAYRAMWRITEENABLE <= MIREPLAYRAMWRITEENABLE_out;
    MIREQUESTRAMREADADDRESSA <= MIREQUESTRAMREADADDRESSA_out;
    MIREQUESTRAMREADADDRESSB <= MIREQUESTRAMREADADDRESSB_out;
    MIREQUESTRAMREADENABLE <= MIREQUESTRAMREADENABLE_out;
    MIREQUESTRAMWRITEADDRESSA <= MIREQUESTRAMWRITEADDRESSA_out;
    MIREQUESTRAMWRITEADDRESSB <= MIREQUESTRAMWRITEADDRESSB_out;
    MIREQUESTRAMWRITEDATA <= MIREQUESTRAMWRITEDATA_out;
    MIREQUESTRAMWRITEENABLE <= MIREQUESTRAMWRITEENABLE_out;
    PCIECQNPREQCOUNT <= PCIECQNPREQCOUNT_out;
    PCIERQSEQNUM <= PCIERQSEQNUM_out;
    PCIERQSEQNUMVLD <= PCIERQSEQNUMVLD_out;
    PCIERQTAG <= PCIERQTAG_out;
    PCIERQTAGAV <= PCIERQTAGAV_out;
    PCIERQTAGVLD <= PCIERQTAGVLD_out;
    PCIETFCNPDAV <= PCIETFCNPDAV_out;
    PCIETFCNPHAV <= PCIETFCNPHAV_out;
    PIPERX0EQCONTROL <= PIPERX0EQCONTROL_out;
    PIPERX0EQLPLFFS <= PIPERX0EQLPLFFS_out;
    PIPERX0EQLPTXPRESET <= PIPERX0EQLPTXPRESET_out;
    PIPERX0EQPRESET <= PIPERX0EQPRESET_out;
    PIPERX0POLARITY <= PIPERX0POLARITY_out;
    PIPERX1EQCONTROL <= PIPERX1EQCONTROL_out;
    PIPERX1EQLPLFFS <= PIPERX1EQLPLFFS_out;
    PIPERX1EQLPTXPRESET <= PIPERX1EQLPTXPRESET_out;
    PIPERX1EQPRESET <= PIPERX1EQPRESET_out;
    PIPERX1POLARITY <= PIPERX1POLARITY_out;
    PIPERX2EQCONTROL <= PIPERX2EQCONTROL_out;
    PIPERX2EQLPLFFS <= PIPERX2EQLPLFFS_out;
    PIPERX2EQLPTXPRESET <= PIPERX2EQLPTXPRESET_out;
    PIPERX2EQPRESET <= PIPERX2EQPRESET_out;
    PIPERX2POLARITY <= PIPERX2POLARITY_out;
    PIPERX3EQCONTROL <= PIPERX3EQCONTROL_out;
    PIPERX3EQLPLFFS <= PIPERX3EQLPLFFS_out;
    PIPERX3EQLPTXPRESET <= PIPERX3EQLPTXPRESET_out;
    PIPERX3EQPRESET <= PIPERX3EQPRESET_out;
    PIPERX3POLARITY <= PIPERX3POLARITY_out;
    PIPERX4EQCONTROL <= PIPERX4EQCONTROL_out;
    PIPERX4EQLPLFFS <= PIPERX4EQLPLFFS_out;
    PIPERX4EQLPTXPRESET <= PIPERX4EQLPTXPRESET_out;
    PIPERX4EQPRESET <= PIPERX4EQPRESET_out;
    PIPERX4POLARITY <= PIPERX4POLARITY_out;
    PIPERX5EQCONTROL <= PIPERX5EQCONTROL_out;
    PIPERX5EQLPLFFS <= PIPERX5EQLPLFFS_out;
    PIPERX5EQLPTXPRESET <= PIPERX5EQLPTXPRESET_out;
    PIPERX5EQPRESET <= PIPERX5EQPRESET_out;
    PIPERX5POLARITY <= PIPERX5POLARITY_out;
    PIPERX6EQCONTROL <= PIPERX6EQCONTROL_out;
    PIPERX6EQLPLFFS <= PIPERX6EQLPLFFS_out;
    PIPERX6EQLPTXPRESET <= PIPERX6EQLPTXPRESET_out;
    PIPERX6EQPRESET <= PIPERX6EQPRESET_out;
    PIPERX6POLARITY <= PIPERX6POLARITY_out;
    PIPERX7EQCONTROL <= PIPERX7EQCONTROL_out;
    PIPERX7EQLPLFFS <= PIPERX7EQLPLFFS_out;
    PIPERX7EQLPTXPRESET <= PIPERX7EQLPTXPRESET_out;
    PIPERX7EQPRESET <= PIPERX7EQPRESET_out;
    PIPERX7POLARITY <= PIPERX7POLARITY_out;
    PIPETX0CHARISK <= PIPETX0CHARISK_out;
    PIPETX0COMPLIANCE <= PIPETX0COMPLIANCE_out;
    PIPETX0DATA <= PIPETX0DATA_out;
    PIPETX0DATAVALID <= PIPETX0DATAVALID_out;
    PIPETX0ELECIDLE <= PIPETX0ELECIDLE_out;
    PIPETX0EQCONTROL <= PIPETX0EQCONTROL_out;
    PIPETX0EQDEEMPH <= PIPETX0EQDEEMPH_out;
    PIPETX0EQPRESET <= PIPETX0EQPRESET_out;
    PIPETX0POWERDOWN <= PIPETX0POWERDOWN_out;
    PIPETX0STARTBLOCK <= PIPETX0STARTBLOCK_out;
    PIPETX0SYNCHEADER <= PIPETX0SYNCHEADER_out;
    PIPETX1CHARISK <= PIPETX1CHARISK_out;
    PIPETX1COMPLIANCE <= PIPETX1COMPLIANCE_out;
    PIPETX1DATA <= PIPETX1DATA_out;
    PIPETX1DATAVALID <= PIPETX1DATAVALID_out;
    PIPETX1ELECIDLE <= PIPETX1ELECIDLE_out;
    PIPETX1EQCONTROL <= PIPETX1EQCONTROL_out;
    PIPETX1EQDEEMPH <= PIPETX1EQDEEMPH_out;
    PIPETX1EQPRESET <= PIPETX1EQPRESET_out;
    PIPETX1POWERDOWN <= PIPETX1POWERDOWN_out;
    PIPETX1STARTBLOCK <= PIPETX1STARTBLOCK_out;
    PIPETX1SYNCHEADER <= PIPETX1SYNCHEADER_out;
    PIPETX2CHARISK <= PIPETX2CHARISK_out;
    PIPETX2COMPLIANCE <= PIPETX2COMPLIANCE_out;
    PIPETX2DATA <= PIPETX2DATA_out;
    PIPETX2DATAVALID <= PIPETX2DATAVALID_out;
    PIPETX2ELECIDLE <= PIPETX2ELECIDLE_out;
    PIPETX2EQCONTROL <= PIPETX2EQCONTROL_out;
    PIPETX2EQDEEMPH <= PIPETX2EQDEEMPH_out;
    PIPETX2EQPRESET <= PIPETX2EQPRESET_out;
    PIPETX2POWERDOWN <= PIPETX2POWERDOWN_out;
    PIPETX2STARTBLOCK <= PIPETX2STARTBLOCK_out;
    PIPETX2SYNCHEADER <= PIPETX2SYNCHEADER_out;
    PIPETX3CHARISK <= PIPETX3CHARISK_out;
    PIPETX3COMPLIANCE <= PIPETX3COMPLIANCE_out;
    PIPETX3DATA <= PIPETX3DATA_out;
    PIPETX3DATAVALID <= PIPETX3DATAVALID_out;
    PIPETX3ELECIDLE <= PIPETX3ELECIDLE_out;
    PIPETX3EQCONTROL <= PIPETX3EQCONTROL_out;
    PIPETX3EQDEEMPH <= PIPETX3EQDEEMPH_out;
    PIPETX3EQPRESET <= PIPETX3EQPRESET_out;
    PIPETX3POWERDOWN <= PIPETX3POWERDOWN_out;
    PIPETX3STARTBLOCK <= PIPETX3STARTBLOCK_out;
    PIPETX3SYNCHEADER <= PIPETX3SYNCHEADER_out;
    PIPETX4CHARISK <= PIPETX4CHARISK_out;
    PIPETX4COMPLIANCE <= PIPETX4COMPLIANCE_out;
    PIPETX4DATA <= PIPETX4DATA_out;
    PIPETX4DATAVALID <= PIPETX4DATAVALID_out;
    PIPETX4ELECIDLE <= PIPETX4ELECIDLE_out;
    PIPETX4EQCONTROL <= PIPETX4EQCONTROL_out;
    PIPETX4EQDEEMPH <= PIPETX4EQDEEMPH_out;
    PIPETX4EQPRESET <= PIPETX4EQPRESET_out;
    PIPETX4POWERDOWN <= PIPETX4POWERDOWN_out;
    PIPETX4STARTBLOCK <= PIPETX4STARTBLOCK_out;
    PIPETX4SYNCHEADER <= PIPETX4SYNCHEADER_out;
    PIPETX5CHARISK <= PIPETX5CHARISK_out;
    PIPETX5COMPLIANCE <= PIPETX5COMPLIANCE_out;
    PIPETX5DATA <= PIPETX5DATA_out;
    PIPETX5DATAVALID <= PIPETX5DATAVALID_out;
    PIPETX5ELECIDLE <= PIPETX5ELECIDLE_out;
    PIPETX5EQCONTROL <= PIPETX5EQCONTROL_out;
    PIPETX5EQDEEMPH <= PIPETX5EQDEEMPH_out;
    PIPETX5EQPRESET <= PIPETX5EQPRESET_out;
    PIPETX5POWERDOWN <= PIPETX5POWERDOWN_out;
    PIPETX5STARTBLOCK <= PIPETX5STARTBLOCK_out;
    PIPETX5SYNCHEADER <= PIPETX5SYNCHEADER_out;
    PIPETX6CHARISK <= PIPETX6CHARISK_out;
    PIPETX6COMPLIANCE <= PIPETX6COMPLIANCE_out;
    PIPETX6DATA <= PIPETX6DATA_out;
    PIPETX6DATAVALID <= PIPETX6DATAVALID_out;
    PIPETX6ELECIDLE <= PIPETX6ELECIDLE_out;
    PIPETX6EQCONTROL <= PIPETX6EQCONTROL_out;
    PIPETX6EQDEEMPH <= PIPETX6EQDEEMPH_out;
    PIPETX6EQPRESET <= PIPETX6EQPRESET_out;
    PIPETX6POWERDOWN <= PIPETX6POWERDOWN_out;
    PIPETX6STARTBLOCK <= PIPETX6STARTBLOCK_out;
    PIPETX6SYNCHEADER <= PIPETX6SYNCHEADER_out;
    PIPETX7CHARISK <= PIPETX7CHARISK_out;
    PIPETX7COMPLIANCE <= PIPETX7COMPLIANCE_out;
    PIPETX7DATA <= PIPETX7DATA_out;
    PIPETX7DATAVALID <= PIPETX7DATAVALID_out;
    PIPETX7ELECIDLE <= PIPETX7ELECIDLE_out;
    PIPETX7EQCONTROL <= PIPETX7EQCONTROL_out;
    PIPETX7EQDEEMPH <= PIPETX7EQDEEMPH_out;
    PIPETX7EQPRESET <= PIPETX7EQPRESET_out;
    PIPETX7POWERDOWN <= PIPETX7POWERDOWN_out;
    PIPETX7STARTBLOCK <= PIPETX7STARTBLOCK_out;
    PIPETX7SYNCHEADER <= PIPETX7SYNCHEADER_out;
    PIPETXDEEMPH <= PIPETXDEEMPH_out;
    PIPETXMARGIN <= PIPETXMARGIN_out;
    PIPETXRATE <= PIPETXRATE_out;
    PIPETXRCVRDET <= PIPETXRCVRDET_out;
    PIPETXRESET <= PIPETXRESET_out;
    PIPETXSWING <= PIPETXSWING_out;
    PLEQINPROGRESS <= PLEQINPROGRESS_out;
    PLEQPHASE <= PLEQPHASE_out;
    PLGEN3PCSRXSLIDE <= PLGEN3PCSRXSLIDE_out;
    SAXISCCTREADY <= SAXISCCTREADY_out;
    SAXISRQTREADY <= SAXISRQTREADY_out;
  end PCIE_3_0_V;
