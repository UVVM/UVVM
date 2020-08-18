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
--  /   /                      
-- /___/   /\      Filename    : PCIE_2_1.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  03/18/10 - CR - Initial Version : 11.1
--  05/26/10 - CR - Complete VHDL simprim wrapper support
--  05/26/10 - CR562036 - specify block updated from 100ps to 0ps to match Verilog/VHDL vcd files
--  01/22/13 - Added DRP monitor (CR 695630).
-------------------------------------------------------

----- CELL PCIE_2_1 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity PCIE_2_1 is
    generic (
      AER_BASE_PTR : bit_vector := X"140";
      AER_CAP_ECRC_CHECK_CAPABLE : string := "FALSE";
      AER_CAP_ECRC_GEN_CAPABLE : string := "FALSE";
      AER_CAP_ID : bit_vector := X"0001";
      AER_CAP_MULTIHEADER : string := "FALSE";
      AER_CAP_NEXTPTR : bit_vector := X"178";
      AER_CAP_ON : string := "FALSE";
      AER_CAP_OPTIONAL_ERR_SUPPORT : bit_vector := X"000000";
      AER_CAP_PERMIT_ROOTERR_UPDATE : string := "TRUE";
      AER_CAP_VERSION : bit_vector := X"2";
      ALLOW_X8_GEN2 : string := "FALSE";
      BAR0 : bit_vector := X"FFFFFF00";
      BAR1 : bit_vector := X"FFFF0000";
      BAR2 : bit_vector := X"FFFF000C";
      BAR3 : bit_vector := X"FFFFFFFF";
      BAR4 : bit_vector := X"00000000";
      BAR5 : bit_vector := X"00000000";
      CAPABILITIES_PTR : bit_vector := X"40";
      CARDBUS_CIS_POINTER : bit_vector := X"00000000";
      CFG_ECRC_ERR_CPLSTAT : integer := 0;
      CLASS_CODE : bit_vector := X"000000";
      CMD_INTX_IMPLEMENTED : string := "TRUE";
      CPL_TIMEOUT_DISABLE_SUPPORTED : string := "FALSE";
      CPL_TIMEOUT_RANGES_SUPPORTED : bit_vector := X"0";
      CRM_MODULE_RSTS : bit_vector := X"00";
      DEV_CAP2_ARI_FORWARDING_SUPPORTED : string := "FALSE";
      DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED : string := "FALSE";
      DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED : string := "FALSE";
      DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED : string := "FALSE";
      DEV_CAP2_CAS128_COMPLETER_SUPPORTED : string := "FALSE";
      DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED : string := "FALSE";
      DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED : string := "FALSE";
      DEV_CAP2_LTR_MECHANISM_SUPPORTED : string := "FALSE";
      DEV_CAP2_MAX_ENDEND_TLP_PREFIXES : bit_vector := X"0";
      DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING : string := "FALSE";
      DEV_CAP2_TPH_COMPLETER_SUPPORTED : bit_vector := X"0";
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE : string := "TRUE";
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE : string := "TRUE";
      DEV_CAP_ENDPOINT_L0S_LATENCY : integer := 0;
      DEV_CAP_ENDPOINT_L1_LATENCY : integer := 0;
      DEV_CAP_EXT_TAG_SUPPORTED : string := "TRUE";
      DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE : string := "FALSE";
      DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer := 2;
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer := 0;
      DEV_CAP_ROLE_BASED_ERROR : string := "TRUE";
      DEV_CAP_RSVD_14_12 : integer := 0;
      DEV_CAP_RSVD_17_16 : integer := 0;
      DEV_CAP_RSVD_31_29 : integer := 0;
      DEV_CONTROL_AUX_POWER_SUPPORTED : string := "FALSE";
      DEV_CONTROL_EXT_TAG_DEFAULT : string := "FALSE";
      DISABLE_ASPM_L1_TIMER : string := "FALSE";
      DISABLE_BAR_FILTERING : string := "FALSE";
      DISABLE_ERR_MSG : string := "FALSE";
      DISABLE_ID_CHECK : string := "FALSE";
      DISABLE_LANE_REVERSAL : string := "FALSE";
      DISABLE_LOCKED_FILTER : string := "FALSE";
      DISABLE_PPM_FILTER : string := "FALSE";
      DISABLE_RX_POISONED_RESP : string := "FALSE";
      DISABLE_RX_TC_FILTER : string := "FALSE";
      DISABLE_SCRAMBLING : string := "FALSE";
      DNSTREAM_LINK_NUM : bit_vector := X"00";
      DSN_BASE_PTR : bit_vector := X"100";
      DSN_CAP_ID : bit_vector := X"0003";
      DSN_CAP_NEXTPTR : bit_vector := X"10C";
      DSN_CAP_ON : string := "TRUE";
      DSN_CAP_VERSION : bit_vector := X"1";
      ENABLE_MSG_ROUTE : bit_vector := X"000";
      ENABLE_RX_TD_ECRC_TRIM : string := "FALSE";
      ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED : string := "FALSE";
      ENTER_RVRY_EI_L0 : string := "TRUE";
      EXIT_LOOPBACK_ON_EI : string := "TRUE";
      EXPANSION_ROM : bit_vector := X"FFFFF001";
      EXT_CFG_CAP_PTR : bit_vector := X"3F";
      EXT_CFG_XP_CAP_PTR : bit_vector := X"3FF";
      HEADER_TYPE : bit_vector := X"00";
      INFER_EI : bit_vector := X"00";
      INTERRUPT_PIN : bit_vector := X"01";
      INTERRUPT_STAT_AUTO : string := "TRUE";
      IS_SWITCH : string := "FALSE";
      LAST_CONFIG_DWORD : bit_vector := X"3FF";
      LINK_CAP_ASPM_OPTIONALITY : string := "TRUE";
      LINK_CAP_ASPM_SUPPORT : integer := 1;
      LINK_CAP_CLOCK_POWER_MANAGEMENT : string := "FALSE";
      LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP : string := "FALSE";
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_GEN1 : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_GEN2 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_GEN1 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_GEN2 : integer := 7;
      LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP : string := "FALSE";
      LINK_CAP_MAX_LINK_SPEED : bit_vector := X"1";
      LINK_CAP_MAX_LINK_WIDTH : bit_vector := X"08";
      LINK_CAP_RSVD_23 : integer := 0;
      LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE : string := "FALSE";
      LINK_CONTROL_RCB : integer := 0;
      LINK_CTRL2_DEEMPHASIS : string := "FALSE";
      LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE : string := "FALSE";
      LINK_CTRL2_TARGET_LINK_SPEED : bit_vector := X"2";
      LINK_STATUS_SLOT_CLOCK_CONFIG : string := "TRUE";
      LL_ACK_TIMEOUT : bit_vector := X"0000";
      LL_ACK_TIMEOUT_EN : string := "FALSE";
      LL_ACK_TIMEOUT_FUNC : integer := 0;
      LL_REPLAY_TIMEOUT : bit_vector := X"0000";
      LL_REPLAY_TIMEOUT_EN : string := "FALSE";
      LL_REPLAY_TIMEOUT_FUNC : integer := 0;
      LTSSM_MAX_LINK_WIDTH : bit_vector := X"01";
      MPS_FORCE : string := "FALSE";
      MSIX_BASE_PTR : bit_vector := X"9C";
      MSIX_CAP_ID : bit_vector := X"11";
      MSIX_CAP_NEXTPTR : bit_vector := X"00";
      MSIX_CAP_ON : string := "FALSE";
      MSIX_CAP_PBA_BIR : integer := 0;
      MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      MSIX_CAP_TABLE_BIR : integer := 0;
      MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      MSI_BASE_PTR : bit_vector := X"48";
      MSI_CAP_64_BIT_ADDR_CAPABLE : string := "TRUE";
      MSI_CAP_ID : bit_vector := X"05";
      MSI_CAP_MULTIMSGCAP : integer := 0;
      MSI_CAP_MULTIMSG_EXTENSION : integer := 0;
      MSI_CAP_NEXTPTR : bit_vector := X"60";
      MSI_CAP_ON : string := "FALSE";
      MSI_CAP_PER_VECTOR_MASKING_CAPABLE : string := "TRUE";
      N_FTS_COMCLK_GEN1 : integer := 255;
      N_FTS_COMCLK_GEN2 : integer := 255;
      N_FTS_GEN1 : integer := 255;
      N_FTS_GEN2 : integer := 255;
      PCIE_BASE_PTR : bit_vector := X"60";
      PCIE_CAP_CAPABILITY_ID : bit_vector := X"10";
      PCIE_CAP_CAPABILITY_VERSION : bit_vector := X"2";
      PCIE_CAP_DEVICE_PORT_TYPE : bit_vector := X"0";
      PCIE_CAP_NEXTPTR : bit_vector := X"9C";
      PCIE_CAP_ON : string := "TRUE";
      PCIE_CAP_RSVD_15_14 : integer := 0;
      PCIE_CAP_SLOT_IMPLEMENTED : string := "FALSE";
      PCIE_REVISION : integer := 2;
      PL_AUTO_CONFIG : integer := 0;
      PL_FAST_TRAIN : string := "FALSE";
      PM_ASPML0S_TIMEOUT : bit_vector := X"0000";
      PM_ASPML0S_TIMEOUT_EN : string := "FALSE";
      PM_ASPML0S_TIMEOUT_FUNC : integer := 0;
      PM_ASPM_FASTEXIT : string := "FALSE";
      PM_BASE_PTR : bit_vector := X"40";
      PM_CAP_AUXCURRENT : integer := 0;
      PM_CAP_D1SUPPORT : string := "TRUE";
      PM_CAP_D2SUPPORT : string := "TRUE";
      PM_CAP_DSI : string := "FALSE";
      PM_CAP_ID : bit_vector := X"01";
      PM_CAP_NEXTPTR : bit_vector := X"48";
      PM_CAP_ON : string := "TRUE";
      PM_CAP_PMESUPPORT : bit_vector := X"0F";
      PM_CAP_PME_CLOCK : string := "FALSE";
      PM_CAP_RSVD_04 : integer := 0;
      PM_CAP_VERSION : integer := 3;
      PM_CSR_B2B3 : string := "FALSE";
      PM_CSR_BPCCEN : string := "FALSE";
      PM_CSR_NOSOFTRST : string := "TRUE";
      PM_DATA0 : bit_vector := X"01";
      PM_DATA1 : bit_vector := X"01";
      PM_DATA2 : bit_vector := X"01";
      PM_DATA3 : bit_vector := X"01";
      PM_DATA4 : bit_vector := X"01";
      PM_DATA5 : bit_vector := X"01";
      PM_DATA6 : bit_vector := X"01";
      PM_DATA7 : bit_vector := X"01";
      PM_DATA_SCALE0 : bit_vector := X"1";
      PM_DATA_SCALE1 : bit_vector := X"1";
      PM_DATA_SCALE2 : bit_vector := X"1";
      PM_DATA_SCALE3 : bit_vector := X"1";
      PM_DATA_SCALE4 : bit_vector := X"1";
      PM_DATA_SCALE5 : bit_vector := X"1";
      PM_DATA_SCALE6 : bit_vector := X"1";
      PM_DATA_SCALE7 : bit_vector := X"1";
      PM_MF : string := "FALSE";
      RBAR_BASE_PTR : bit_vector := X"178";
      RBAR_CAP_CONTROL_ENCODEDBAR0 : bit_vector := X"00";
      RBAR_CAP_CONTROL_ENCODEDBAR1 : bit_vector := X"00";
      RBAR_CAP_CONTROL_ENCODEDBAR2 : bit_vector := X"00";
      RBAR_CAP_CONTROL_ENCODEDBAR3 : bit_vector := X"00";
      RBAR_CAP_CONTROL_ENCODEDBAR4 : bit_vector := X"00";
      RBAR_CAP_CONTROL_ENCODEDBAR5 : bit_vector := X"00";
      RBAR_CAP_ID : bit_vector := X"0015";
      RBAR_CAP_INDEX0 : bit_vector := X"0";
      RBAR_CAP_INDEX1 : bit_vector := X"0";
      RBAR_CAP_INDEX2 : bit_vector := X"0";
      RBAR_CAP_INDEX3 : bit_vector := X"0";
      RBAR_CAP_INDEX4 : bit_vector := X"0";
      RBAR_CAP_INDEX5 : bit_vector := X"0";
      RBAR_CAP_NEXTPTR : bit_vector := X"000";
      RBAR_CAP_ON : string := "FALSE";
      RBAR_CAP_SUP0 : bit_vector := X"00000000";
      RBAR_CAP_SUP1 : bit_vector := X"00000000";
      RBAR_CAP_SUP2 : bit_vector := X"00000000";
      RBAR_CAP_SUP3 : bit_vector := X"00000000";
      RBAR_CAP_SUP4 : bit_vector := X"00000000";
      RBAR_CAP_SUP5 : bit_vector := X"00000000";
      RBAR_CAP_VERSION : bit_vector := X"1";
      RBAR_NUM : bit_vector := X"1";
      RECRC_CHK : integer := 0;
      RECRC_CHK_TRIM : string := "FALSE";
      ROOT_CAP_CRS_SW_VISIBILITY : string := "FALSE";
      RP_AUTO_SPD : bit_vector := X"1";
      RP_AUTO_SPD_LOOPCNT : bit_vector := X"1F";
      SELECT_DLL_IF : string := "FALSE";
      SIM_VERSION : string := "1.0";
      SLOT_CAP_ATT_BUTTON_PRESENT : string := "FALSE";
      SLOT_CAP_ATT_INDICATOR_PRESENT : string := "FALSE";
      SLOT_CAP_ELEC_INTERLOCK_PRESENT : string := "FALSE";
      SLOT_CAP_HOTPLUG_CAPABLE : string := "FALSE";
      SLOT_CAP_HOTPLUG_SURPRISE : string := "FALSE";
      SLOT_CAP_MRL_SENSOR_PRESENT : string := "FALSE";
      SLOT_CAP_NO_CMD_COMPLETED_SUPPORT : string := "FALSE";
      SLOT_CAP_PHYSICAL_SLOT_NUM : bit_vector := X"0000";
      SLOT_CAP_POWER_CONTROLLER_PRESENT : string := "FALSE";
      SLOT_CAP_POWER_INDICATOR_PRESENT : string := "FALSE";
      SLOT_CAP_SLOT_POWER_LIMIT_SCALE : integer := 0;
      SLOT_CAP_SLOT_POWER_LIMIT_VALUE : bit_vector := X"00";
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
      SSL_MESSAGE_AUTO : string := "FALSE";
      TECRC_EP_INV : string := "FALSE";
      TL_RBYPASS : string := "FALSE";
      TL_RX_RAM_RADDR_LATENCY : integer := 0;
      TL_RX_RAM_RDATA_LATENCY : integer := 2;
      TL_RX_RAM_WRITE_LATENCY : integer := 0;
      TL_TFC_DISABLE : string := "FALSE";
      TL_TX_CHECKS_DISABLE : string := "FALSE";
      TL_TX_RAM_RADDR_LATENCY : integer := 0;
      TL_TX_RAM_RDATA_LATENCY : integer := 2;
      TL_TX_RAM_WRITE_LATENCY : integer := 0;
      TRN_DW : string := "FALSE";
      TRN_NP_FC : string := "FALSE";
      UPCONFIG_CAPABLE : string := "TRUE";
      UPSTREAM_FACING : string := "TRUE";
      UR_ATOMIC : string := "TRUE";
      UR_CFG1 : string := "TRUE";
      UR_INV_REQ : string := "TRUE";
      UR_PRS_RESPONSE : string := "TRUE";
      USER_CLK2_DIV2 : string := "FALSE";
      USER_CLK_FREQ : integer := 3;
      USE_RID_PINS : string := "FALSE";
      VC0_CPL_INFINITE : string := "TRUE";
      VC0_RX_RAM_LIMIT : bit_vector := X"03FF";
      VC0_TOTAL_CREDITS_CD : integer := 127;
      VC0_TOTAL_CREDITS_CH : integer := 31;
      VC0_TOTAL_CREDITS_NPD : integer := 24;
      VC0_TOTAL_CREDITS_NPH : integer := 12;
      VC0_TOTAL_CREDITS_PD : integer := 288;
      VC0_TOTAL_CREDITS_PH : integer := 32;
      VC0_TX_LASTPACKET : integer := 31;
      VC_BASE_PTR : bit_vector := X"10C";
      VC_CAP_ID : bit_vector := X"0002";
      VC_CAP_NEXTPTR : bit_vector := X"000";
      VC_CAP_ON : string := "FALSE";
      VC_CAP_REJECT_SNOOP_TRANSACTIONS : string := "FALSE";
      VC_CAP_VERSION : bit_vector := X"1";
      VSEC_BASE_PTR : bit_vector := X"128";
      VSEC_CAP_HDR_ID : bit_vector := X"1234";
      VSEC_CAP_HDR_LENGTH : bit_vector := X"018";
      VSEC_CAP_HDR_REVISION : bit_vector := X"1";
      VSEC_CAP_ID : bit_vector := X"000B";
      VSEC_CAP_IS_LINK_VISIBLE : string := "TRUE";
      VSEC_CAP_NEXTPTR : bit_vector := X"140";
      VSEC_CAP_ON : string := "FALSE";
      VSEC_CAP_VERSION : bit_vector := X"1"
    );

    port (
      CFGAERECRCCHECKEN    : out std_ulogic;
      CFGAERECRCGENEN      : out std_ulogic;
      CFGAERROOTERRCORRERRRECEIVED : out std_ulogic;
      CFGAERROOTERRCORRERRREPORTINGEN : out std_ulogic;
      CFGAERROOTERRFATALERRRECEIVED : out std_ulogic;
      CFGAERROOTERRFATALERRREPORTINGEN : out std_ulogic;
      CFGAERROOTERRNONFATALERRRECEIVED : out std_ulogic;
      CFGAERROOTERRNONFATALERRREPORTINGEN : out std_ulogic;
      CFGBRIDGESERREN      : out std_ulogic;
      CFGCOMMANDBUSMASTERENABLE : out std_ulogic;
      CFGCOMMANDINTERRUPTDISABLE : out std_ulogic;
      CFGCOMMANDIOENABLE   : out std_ulogic;
      CFGCOMMANDMEMENABLE  : out std_ulogic;
      CFGCOMMANDSERREN     : out std_ulogic;
      CFGDEVCONTROL2ARIFORWARDEN : out std_ulogic;
      CFGDEVCONTROL2ATOMICEGRESSBLOCK : out std_ulogic;
      CFGDEVCONTROL2ATOMICREQUESTEREN : out std_ulogic;
      CFGDEVCONTROL2CPLTIMEOUTDIS : out std_ulogic;
      CFGDEVCONTROL2CPLTIMEOUTVAL : out std_logic_vector(3 downto 0);
      CFGDEVCONTROL2IDOCPLEN : out std_ulogic;
      CFGDEVCONTROL2IDOREQEN : out std_ulogic;
      CFGDEVCONTROL2LTREN  : out std_ulogic;
      CFGDEVCONTROL2TLPPREFIXBLOCK : out std_ulogic;
      CFGDEVCONTROLAUXPOWEREN : out std_ulogic;
      CFGDEVCONTROLCORRERRREPORTINGEN : out std_ulogic;
      CFGDEVCONTROLENABLERO : out std_ulogic;
      CFGDEVCONTROLEXTTAGEN : out std_ulogic;
      CFGDEVCONTROLFATALERRREPORTINGEN : out std_ulogic;
      CFGDEVCONTROLMAXPAYLOAD : out std_logic_vector(2 downto 0);
      CFGDEVCONTROLMAXREADREQ : out std_logic_vector(2 downto 0);
      CFGDEVCONTROLNONFATALREPORTINGEN : out std_ulogic;
      CFGDEVCONTROLNOSNOOPEN : out std_ulogic;
      CFGDEVCONTROLPHANTOMEN : out std_ulogic;
      CFGDEVCONTROLURERRREPORTINGEN : out std_ulogic;
      CFGDEVSTATUSCORRERRDETECTED : out std_ulogic;
      CFGDEVSTATUSFATALERRDETECTED : out std_ulogic;
      CFGDEVSTATUSNONFATALERRDETECTED : out std_ulogic;
      CFGDEVSTATUSURDETECTED : out std_ulogic;
      CFGERRAERHEADERLOGSETN : out std_ulogic;
      CFGERRCPLRDYN        : out std_ulogic;
      CFGINTERRUPTDO       : out std_logic_vector(7 downto 0);
      CFGINTERRUPTMMENABLE : out std_logic_vector(2 downto 0);
      CFGINTERRUPTMSIENABLE : out std_ulogic;
      CFGINTERRUPTMSIXENABLE : out std_ulogic;
      CFGINTERRUPTMSIXFM   : out std_ulogic;
      CFGINTERRUPTRDYN     : out std_ulogic;
      CFGLINKCONTROLASPMCONTROL : out std_logic_vector(1 downto 0);
      CFGLINKCONTROLAUTOBANDWIDTHINTEN : out std_ulogic;
      CFGLINKCONTROLBANDWIDTHINTEN : out std_ulogic;
      CFGLINKCONTROLCLOCKPMEN : out std_ulogic;
      CFGLINKCONTROLCOMMONCLOCK : out std_ulogic;
      CFGLINKCONTROLEXTENDEDSYNC : out std_ulogic;
      CFGLINKCONTROLHWAUTOWIDTHDIS : out std_ulogic;
      CFGLINKCONTROLLINKDISABLE : out std_ulogic;
      CFGLINKCONTROLRCB    : out std_ulogic;
      CFGLINKCONTROLRETRAINLINK : out std_ulogic;
      CFGLINKSTATUSAUTOBANDWIDTHSTATUS : out std_ulogic;
      CFGLINKSTATUSBANDWIDTHSTATUS : out std_ulogic;
      CFGLINKSTATUSCURRENTSPEED : out std_logic_vector(1 downto 0);
      CFGLINKSTATUSDLLACTIVE : out std_ulogic;
      CFGLINKSTATUSLINKTRAINING : out std_ulogic;
      CFGLINKSTATUSNEGOTIATEDWIDTH : out std_logic_vector(3 downto 0);
      CFGMGMTDO            : out std_logic_vector(31 downto 0);
      CFGMGMTRDWRDONEN     : out std_ulogic;
      CFGMSGDATA           : out std_logic_vector(15 downto 0);
      CFGMSGRECEIVED       : out std_ulogic;
      CFGMSGRECEIVEDASSERTINTA : out std_ulogic;
      CFGMSGRECEIVEDASSERTINTB : out std_ulogic;
      CFGMSGRECEIVEDASSERTINTC : out std_ulogic;
      CFGMSGRECEIVEDASSERTINTD : out std_ulogic;
      CFGMSGRECEIVEDDEASSERTINTA : out std_ulogic;
      CFGMSGRECEIVEDDEASSERTINTB : out std_ulogic;
      CFGMSGRECEIVEDDEASSERTINTC : out std_ulogic;
      CFGMSGRECEIVEDDEASSERTINTD : out std_ulogic;
      CFGMSGRECEIVEDERRCOR : out std_ulogic;
      CFGMSGRECEIVEDERRFATAL : out std_ulogic;
      CFGMSGRECEIVEDERRNONFATAL : out std_ulogic;
      CFGMSGRECEIVEDPMASNAK : out std_ulogic;
      CFGMSGRECEIVEDPMETO  : out std_ulogic;
      CFGMSGRECEIVEDPMETOACK : out std_ulogic;
      CFGMSGRECEIVEDPMPME  : out std_ulogic;
      CFGMSGRECEIVEDSETSLOTPOWERLIMIT : out std_ulogic;
      CFGMSGRECEIVEDUNLOCK : out std_ulogic;
      CFGPCIELINKSTATE     : out std_logic_vector(2 downto 0);
      CFGPMCSRPMEEN        : out std_ulogic;
      CFGPMCSRPMESTATUS    : out std_ulogic;
      CFGPMCSRPOWERSTATE   : out std_logic_vector(1 downto 0);
      CFGPMRCVASREQL1N     : out std_ulogic;
      CFGPMRCVENTERL1N     : out std_ulogic;
      CFGPMRCVENTERL23N    : out std_ulogic;
      CFGPMRCVREQACKN      : out std_ulogic;
      CFGROOTCONTROLPMEINTEN : out std_ulogic;
      CFGROOTCONTROLSYSERRCORRERREN : out std_ulogic;
      CFGROOTCONTROLSYSERRFATALERREN : out std_ulogic;
      CFGROOTCONTROLSYSERRNONFATALERREN : out std_ulogic;
      CFGSLOTCONTROLELECTROMECHILCTLPULSE : out std_ulogic;
      CFGTRANSACTION       : out std_ulogic;
      CFGTRANSACTIONADDR   : out std_logic_vector(6 downto 0);
      CFGTRANSACTIONTYPE   : out std_ulogic;
      CFGVCTCVCMAP         : out std_logic_vector(6 downto 0);
      DBGSCLRA             : out std_ulogic;
      DBGSCLRB             : out std_ulogic;
      DBGSCLRC             : out std_ulogic;
      DBGSCLRD             : out std_ulogic;
      DBGSCLRE             : out std_ulogic;
      DBGSCLRF             : out std_ulogic;
      DBGSCLRG             : out std_ulogic;
      DBGSCLRH             : out std_ulogic;
      DBGSCLRI             : out std_ulogic;
      DBGSCLRJ             : out std_ulogic;
      DBGSCLRK             : out std_ulogic;
      DBGVECA              : out std_logic_vector(63 downto 0);
      DBGVECB              : out std_logic_vector(63 downto 0);
      DBGVECC              : out std_logic_vector(11 downto 0);
      DRPDO                : out std_logic_vector(15 downto 0);
      DRPRDY               : out std_ulogic;
      LL2BADDLLPERR        : out std_ulogic;
      LL2BADTLPERR         : out std_ulogic;
      LL2LINKSTATUS        : out std_logic_vector(4 downto 0);
      LL2PROTOCOLERR       : out std_ulogic;
      LL2RECEIVERERR       : out std_ulogic;
      LL2REPLAYROERR       : out std_ulogic;
      LL2REPLAYTOERR       : out std_ulogic;
      LL2SUSPENDOK         : out std_ulogic;
      LL2TFCINIT1SEQ       : out std_ulogic;
      LL2TFCINIT2SEQ       : out std_ulogic;
      LL2TXIDLE            : out std_ulogic;
      LNKCLKEN             : out std_ulogic;
      MIMRXRADDR           : out std_logic_vector(12 downto 0);
      MIMRXREN             : out std_ulogic;
      MIMRXWADDR           : out std_logic_vector(12 downto 0);
      MIMRXWDATA           : out std_logic_vector(67 downto 0);
      MIMRXWEN             : out std_ulogic;
      MIMTXRADDR           : out std_logic_vector(12 downto 0);
      MIMTXREN             : out std_ulogic;
      MIMTXWADDR           : out std_logic_vector(12 downto 0);
      MIMTXWDATA           : out std_logic_vector(68 downto 0);
      MIMTXWEN             : out std_ulogic;
      PIPERX0POLARITY      : out std_ulogic;
      PIPERX1POLARITY      : out std_ulogic;
      PIPERX2POLARITY      : out std_ulogic;
      PIPERX3POLARITY      : out std_ulogic;
      PIPERX4POLARITY      : out std_ulogic;
      PIPERX5POLARITY      : out std_ulogic;
      PIPERX6POLARITY      : out std_ulogic;
      PIPERX7POLARITY      : out std_ulogic;
      PIPETX0CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX0COMPLIANCE    : out std_ulogic;
      PIPETX0DATA          : out std_logic_vector(15 downto 0);
      PIPETX0ELECIDLE      : out std_ulogic;
      PIPETX0POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX1CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX1COMPLIANCE    : out std_ulogic;
      PIPETX1DATA          : out std_logic_vector(15 downto 0);
      PIPETX1ELECIDLE      : out std_ulogic;
      PIPETX1POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX2CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX2COMPLIANCE    : out std_ulogic;
      PIPETX2DATA          : out std_logic_vector(15 downto 0);
      PIPETX2ELECIDLE      : out std_ulogic;
      PIPETX2POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX3CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX3COMPLIANCE    : out std_ulogic;
      PIPETX3DATA          : out std_logic_vector(15 downto 0);
      PIPETX3ELECIDLE      : out std_ulogic;
      PIPETX3POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX4CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX4COMPLIANCE    : out std_ulogic;
      PIPETX4DATA          : out std_logic_vector(15 downto 0);
      PIPETX4ELECIDLE      : out std_ulogic;
      PIPETX4POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX5CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX5COMPLIANCE    : out std_ulogic;
      PIPETX5DATA          : out std_logic_vector(15 downto 0);
      PIPETX5ELECIDLE      : out std_ulogic;
      PIPETX5POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX6CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX6COMPLIANCE    : out std_ulogic;
      PIPETX6DATA          : out std_logic_vector(15 downto 0);
      PIPETX6ELECIDLE      : out std_ulogic;
      PIPETX6POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETX7CHARISK       : out std_logic_vector(1 downto 0);
      PIPETX7COMPLIANCE    : out std_ulogic;
      PIPETX7DATA          : out std_logic_vector(15 downto 0);
      PIPETX7ELECIDLE      : out std_ulogic;
      PIPETX7POWERDOWN     : out std_logic_vector(1 downto 0);
      PIPETXDEEMPH         : out std_ulogic;
      PIPETXMARGIN         : out std_logic_vector(2 downto 0);
      PIPETXRATE           : out std_ulogic;
      PIPETXRCVRDET        : out std_ulogic;
      PIPETXRESET          : out std_ulogic;
      PL2L0REQ             : out std_ulogic;
      PL2LINKUP            : out std_ulogic;
      PL2RECEIVERERR       : out std_ulogic;
      PL2RECOVERY          : out std_ulogic;
      PL2RXELECIDLE        : out std_ulogic;
      PL2RXPMSTATE         : out std_logic_vector(1 downto 0);
      PL2SUSPENDOK         : out std_ulogic;
      PLDBGVEC             : out std_logic_vector(11 downto 0);
      PLDIRECTEDCHANGEDONE : out std_ulogic;
      PLINITIALLINKWIDTH   : out std_logic_vector(2 downto 0);
      PLLANEREVERSALMODE   : out std_logic_vector(1 downto 0);
      PLLINKGEN2CAP        : out std_ulogic;
      PLLINKPARTNERGEN2SUPPORTED : out std_ulogic;
      PLLINKUPCFGCAP       : out std_ulogic;
      PLLTSSMSTATE         : out std_logic_vector(5 downto 0);
      PLPHYLNKUPN          : out std_ulogic;
      PLRECEIVEDHOTRST     : out std_ulogic;
      PLRXPMSTATE          : out std_logic_vector(1 downto 0);
      PLSELLNKRATE         : out std_ulogic;
      PLSELLNKWIDTH        : out std_logic_vector(1 downto 0);
      PLTXPMSTATE          : out std_logic_vector(2 downto 0);
      RECEIVEDFUNCLVLRSTN  : out std_ulogic;
      TL2ASPMSUSPENDCREDITCHECKOK : out std_ulogic;
      TL2ASPMSUSPENDREQ    : out std_ulogic;
      TL2ERRFCPE           : out std_ulogic;
      TL2ERRHDR            : out std_logic_vector(63 downto 0);
      TL2ERRMALFORMED      : out std_ulogic;
      TL2ERRRXOVERFLOW     : out std_ulogic;
      TL2PPMSUSPENDOK      : out std_ulogic;
      TRNFCCPLD            : out std_logic_vector(11 downto 0);
      TRNFCCPLH            : out std_logic_vector(7 downto 0);
      TRNFCNPD             : out std_logic_vector(11 downto 0);
      TRNFCNPH             : out std_logic_vector(7 downto 0);
      TRNFCPD              : out std_logic_vector(11 downto 0);
      TRNFCPH              : out std_logic_vector(7 downto 0);
      TRNLNKUP             : out std_ulogic;
      TRNRBARHIT           : out std_logic_vector(7 downto 0);
      TRNRD                : out std_logic_vector(127 downto 0);
      TRNRDLLPDATA         : out std_logic_vector(63 downto 0);
      TRNRDLLPSRCRDY       : out std_logic_vector(1 downto 0);
      TRNRECRCERR          : out std_ulogic;
      TRNREOF              : out std_ulogic;
      TRNRERRFWD           : out std_ulogic;
      TRNRREM              : out std_logic_vector(1 downto 0);
      TRNRSOF              : out std_ulogic;
      TRNRSRCDSC           : out std_ulogic;
      TRNRSRCRDY           : out std_ulogic;
      TRNTBUFAV            : out std_logic_vector(5 downto 0);
      TRNTCFGREQ           : out std_ulogic;
      TRNTDLLPDSTRDY       : out std_ulogic;
      TRNTDSTRDY           : out std_logic_vector(3 downto 0);
      TRNTERRDROP          : out std_ulogic;
      USERRSTN             : out std_ulogic;
      CFGAERINTERRUPTMSGNUM : in std_logic_vector(4 downto 0);
      CFGDEVID             : in std_logic_vector(15 downto 0);
      CFGDSBUSNUMBER       : in std_logic_vector(7 downto 0);
      CFGDSDEVICENUMBER    : in std_logic_vector(4 downto 0);
      CFGDSFUNCTIONNUMBER  : in std_logic_vector(2 downto 0);
      CFGDSN               : in std_logic_vector(63 downto 0);
      CFGERRACSN           : in std_ulogic;
      CFGERRAERHEADERLOG   : in std_logic_vector(127 downto 0);
      CFGERRATOMICEGRESSBLOCKEDN : in std_ulogic;
      CFGERRCORN           : in std_ulogic;
      CFGERRCPLABORTN      : in std_ulogic;
      CFGERRCPLTIMEOUTN    : in std_ulogic;
      CFGERRCPLUNEXPECTN   : in std_ulogic;
      CFGERRECRCN          : in std_ulogic;
      CFGERRINTERNALCORN   : in std_ulogic;
      CFGERRINTERNALUNCORN : in std_ulogic;
      CFGERRLOCKEDN        : in std_ulogic;
      CFGERRMALFORMEDN     : in std_ulogic;
      CFGERRMCBLOCKEDN     : in std_ulogic;
      CFGERRNORECOVERYN    : in std_ulogic;
      CFGERRPOISONEDN      : in std_ulogic;
      CFGERRPOSTEDN        : in std_ulogic;
      CFGERRTLPCPLHEADER   : in std_logic_vector(47 downto 0);
      CFGERRURN            : in std_ulogic;
      CFGFORCECOMMONCLOCKOFF : in std_ulogic;
      CFGFORCEEXTENDEDSYNCON : in std_ulogic;
      CFGFORCEMPS          : in std_logic_vector(2 downto 0);
      CFGINTERRUPTASSERTN  : in std_ulogic;
      CFGINTERRUPTDI       : in std_logic_vector(7 downto 0);
      CFGINTERRUPTN        : in std_ulogic;
      CFGINTERRUPTSTATN    : in std_ulogic;
      CFGMGMTBYTEENN       : in std_logic_vector(3 downto 0);
      CFGMGMTDI            : in std_logic_vector(31 downto 0);
      CFGMGMTDWADDR        : in std_logic_vector(9 downto 0);
      CFGMGMTRDENN         : in std_ulogic;
      CFGMGMTWRENN         : in std_ulogic;
      CFGMGMTWRREADONLYN   : in std_ulogic;
      CFGMGMTWRRW1CASRWN   : in std_ulogic;
      CFGPCIECAPINTERRUPTMSGNUM : in std_logic_vector(4 downto 0);
      CFGPMFORCESTATE      : in std_logic_vector(1 downto 0);
      CFGPMFORCESTATEENN   : in std_ulogic;
      CFGPMHALTASPML0SN    : in std_ulogic;
      CFGPMHALTASPML1N     : in std_ulogic;
      CFGPMSENDPMETON      : in std_ulogic;
      CFGPMTURNOFFOKN      : in std_ulogic;
      CFGPMWAKEN           : in std_ulogic;
      CFGPORTNUMBER        : in std_logic_vector(7 downto 0);
      CFGREVID             : in std_logic_vector(7 downto 0);
      CFGSUBSYSID          : in std_logic_vector(15 downto 0);
      CFGSUBSYSVENDID      : in std_logic_vector(15 downto 0);
      CFGTRNPENDINGN       : in std_ulogic;
      CFGVENDID            : in std_logic_vector(15 downto 0);
      CMRSTN               : in std_ulogic;
      CMSTICKYRSTN         : in std_ulogic;
      DBGMODE              : in std_logic_vector(1 downto 0);
      DBGSUBMODE           : in std_ulogic;
      DLRSTN               : in std_ulogic;
      DRPADDR              : in std_logic_vector(8 downto 0);
      DRPCLK               : in std_ulogic;
      DRPDI                : in std_logic_vector(15 downto 0);
      DRPEN                : in std_ulogic;
      DRPWE                : in std_ulogic;
      FUNCLVLRSTN          : in std_ulogic;
      LL2SENDASREQL1       : in std_ulogic;
      LL2SENDENTERL1       : in std_ulogic;
      LL2SENDENTERL23      : in std_ulogic;
      LL2SENDPMACK         : in std_ulogic;
      LL2SUSPENDNOW        : in std_ulogic;
      LL2TLPRCV            : in std_ulogic;
      MIMRXRDATA           : in std_logic_vector(67 downto 0);
      MIMTXRDATA           : in std_logic_vector(68 downto 0);
      PIPECLK              : in std_ulogic;
      PIPERX0CHANISALIGNED : in std_ulogic;
      PIPERX0CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX0DATA          : in std_logic_vector(15 downto 0);
      PIPERX0ELECIDLE      : in std_ulogic;
      PIPERX0PHYSTATUS     : in std_ulogic;
      PIPERX0STATUS        : in std_logic_vector(2 downto 0);
      PIPERX0VALID         : in std_ulogic;
      PIPERX1CHANISALIGNED : in std_ulogic;
      PIPERX1CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX1DATA          : in std_logic_vector(15 downto 0);
      PIPERX1ELECIDLE      : in std_ulogic;
      PIPERX1PHYSTATUS     : in std_ulogic;
      PIPERX1STATUS        : in std_logic_vector(2 downto 0);
      PIPERX1VALID         : in std_ulogic;
      PIPERX2CHANISALIGNED : in std_ulogic;
      PIPERX2CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX2DATA          : in std_logic_vector(15 downto 0);
      PIPERX2ELECIDLE      : in std_ulogic;
      PIPERX2PHYSTATUS     : in std_ulogic;
      PIPERX2STATUS        : in std_logic_vector(2 downto 0);
      PIPERX2VALID         : in std_ulogic;
      PIPERX3CHANISALIGNED : in std_ulogic;
      PIPERX3CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX3DATA          : in std_logic_vector(15 downto 0);
      PIPERX3ELECIDLE      : in std_ulogic;
      PIPERX3PHYSTATUS     : in std_ulogic;
      PIPERX3STATUS        : in std_logic_vector(2 downto 0);
      PIPERX3VALID         : in std_ulogic;
      PIPERX4CHANISALIGNED : in std_ulogic;
      PIPERX4CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX4DATA          : in std_logic_vector(15 downto 0);
      PIPERX4ELECIDLE      : in std_ulogic;
      PIPERX4PHYSTATUS     : in std_ulogic;
      PIPERX4STATUS        : in std_logic_vector(2 downto 0);
      PIPERX4VALID         : in std_ulogic;
      PIPERX5CHANISALIGNED : in std_ulogic;
      PIPERX5CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX5DATA          : in std_logic_vector(15 downto 0);
      PIPERX5ELECIDLE      : in std_ulogic;
      PIPERX5PHYSTATUS     : in std_ulogic;
      PIPERX5STATUS        : in std_logic_vector(2 downto 0);
      PIPERX5VALID         : in std_ulogic;
      PIPERX6CHANISALIGNED : in std_ulogic;
      PIPERX6CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX6DATA          : in std_logic_vector(15 downto 0);
      PIPERX6ELECIDLE      : in std_ulogic;
      PIPERX6PHYSTATUS     : in std_ulogic;
      PIPERX6STATUS        : in std_logic_vector(2 downto 0);
      PIPERX6VALID         : in std_ulogic;
      PIPERX7CHANISALIGNED : in std_ulogic;
      PIPERX7CHARISK       : in std_logic_vector(1 downto 0);
      PIPERX7DATA          : in std_logic_vector(15 downto 0);
      PIPERX7ELECIDLE      : in std_ulogic;
      PIPERX7PHYSTATUS     : in std_ulogic;
      PIPERX7STATUS        : in std_logic_vector(2 downto 0);
      PIPERX7VALID         : in std_ulogic;
      PL2DIRECTEDLSTATE    : in std_logic_vector(4 downto 0);
      PLDBGMODE            : in std_logic_vector(2 downto 0);
      PLDIRECTEDLINKAUTON  : in std_ulogic;
      PLDIRECTEDLINKCHANGE : in std_logic_vector(1 downto 0);
      PLDIRECTEDLINKSPEED  : in std_ulogic;
      PLDIRECTEDLINKWIDTH  : in std_logic_vector(1 downto 0);
      PLDIRECTEDLTSSMNEW   : in std_logic_vector(5 downto 0);
      PLDIRECTEDLTSSMNEWVLD : in std_ulogic;
      PLDIRECTEDLTSSMSTALL : in std_ulogic;
      PLDOWNSTREAMDEEMPHSOURCE : in std_ulogic;
      PLRSTN               : in std_ulogic;
      PLTRANSMITHOTRST     : in std_ulogic;
      PLUPSTREAMPREFERDEEMPH : in std_ulogic;
      SYSRSTN              : in std_ulogic;
      TL2ASPMSUSPENDCREDITCHECK : in std_ulogic;
      TL2PPMSUSPENDREQ     : in std_ulogic;
      TLRSTN               : in std_ulogic;
      TRNFCSEL             : in std_logic_vector(2 downto 0);
      TRNRDSTRDY           : in std_ulogic;
      TRNRFCPRET           : in std_ulogic;
      TRNRNPOK             : in std_ulogic;
      TRNRNPREQ            : in std_ulogic;
      TRNTCFGGNT           : in std_ulogic;
      TRNTD                : in std_logic_vector(127 downto 0);
      TRNTDLLPDATA         : in std_logic_vector(31 downto 0);
      TRNTDLLPSRCRDY       : in std_ulogic;
      TRNTECRCGEN          : in std_ulogic;
      TRNTEOF              : in std_ulogic;
      TRNTERRFWD           : in std_ulogic;
      TRNTREM              : in std_logic_vector(1 downto 0);
      TRNTSOF              : in std_ulogic;
      TRNTSRCDSC           : in std_ulogic;
      TRNTSRCRDY           : in std_ulogic;
      TRNTSTR              : in std_ulogic;
      USERCLK              : in std_ulogic;
      USERCLK2             : in std_ulogic      
    );
  end PCIE_2_1;

  architecture PCIE_2_1_V of PCIE_2_1 is
    component PCIE_2_1_WRAP
      generic (
        AER_BASE_PTR : string;
        AER_CAP_ECRC_CHECK_CAPABLE : string;
        AER_CAP_ECRC_GEN_CAPABLE : string;
        AER_CAP_ID : string;
        AER_CAP_MULTIHEADER : string;
        AER_CAP_NEXTPTR : string;
        AER_CAP_ON : string;
        AER_CAP_OPTIONAL_ERR_SUPPORT : string;
        AER_CAP_PERMIT_ROOTERR_UPDATE : string;
        AER_CAP_VERSION : string;
        ALLOW_X8_GEN2 : string;
        BAR0 : string;
        BAR1 : string;
        BAR2 : string;
        BAR3 : string;
        BAR4 : string;
        BAR5 : string;
        CAPABILITIES_PTR : string;
        CARDBUS_CIS_POINTER : string;
        CFG_ECRC_ERR_CPLSTAT : integer;
        CLASS_CODE : string;
        CMD_INTX_IMPLEMENTED : string;
        CPL_TIMEOUT_DISABLE_SUPPORTED : string;
        CPL_TIMEOUT_RANGES_SUPPORTED : string;
        CRM_MODULE_RSTS : string;
        DEV_CAP2_ARI_FORWARDING_SUPPORTED : string;
        DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED : string;
        DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED : string;
        DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED : string;
        DEV_CAP2_CAS128_COMPLETER_SUPPORTED : string;
        DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED : string;
        DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED : string;
        DEV_CAP2_LTR_MECHANISM_SUPPORTED : string;
        DEV_CAP2_MAX_ENDEND_TLP_PREFIXES : string;
        DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING : string;
        DEV_CAP2_TPH_COMPLETER_SUPPORTED : string;
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE : string;
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE : string;
        DEV_CAP_ENDPOINT_L0S_LATENCY : integer;
        DEV_CAP_ENDPOINT_L1_LATENCY : integer;
        DEV_CAP_EXT_TAG_SUPPORTED : string;
        DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE : string;
        DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer;
        DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer;
        DEV_CAP_ROLE_BASED_ERROR : string;
        DEV_CAP_RSVD_14_12 : integer;
        DEV_CAP_RSVD_17_16 : integer;
        DEV_CAP_RSVD_31_29 : integer;
        DEV_CONTROL_AUX_POWER_SUPPORTED : string;
        DEV_CONTROL_EXT_TAG_DEFAULT : string;
        DISABLE_ASPM_L1_TIMER : string;
        DISABLE_BAR_FILTERING : string;
        DISABLE_ERR_MSG : string;
        DISABLE_ID_CHECK : string;
        DISABLE_LANE_REVERSAL : string;
        DISABLE_LOCKED_FILTER : string;
        DISABLE_PPM_FILTER : string;
        DISABLE_RX_POISONED_RESP : string;
        DISABLE_RX_TC_FILTER : string;
        DISABLE_SCRAMBLING : string;
        DNSTREAM_LINK_NUM : string;
        DSN_BASE_PTR : string;
        DSN_CAP_ID : string;
        DSN_CAP_NEXTPTR : string;
        DSN_CAP_ON : string;
        DSN_CAP_VERSION : string;
        ENABLE_MSG_ROUTE : string;
        ENABLE_RX_TD_ECRC_TRIM : string;
        ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED : string;
        ENTER_RVRY_EI_L0 : string;
        EXIT_LOOPBACK_ON_EI : string;
        EXPANSION_ROM : string;
        EXT_CFG_CAP_PTR : string;
        EXT_CFG_XP_CAP_PTR : string;
        HEADER_TYPE : string;
        INFER_EI : string;
        INTERRUPT_PIN : string;
        INTERRUPT_STAT_AUTO : string;
        IS_SWITCH : string;
        LAST_CONFIG_DWORD : string;
        LINK_CAP_ASPM_OPTIONALITY : string;
        LINK_CAP_ASPM_SUPPORT : integer;
        LINK_CAP_CLOCK_POWER_MANAGEMENT : string;
        LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP : string;
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 : integer;
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 : integer;
        LINK_CAP_L0S_EXIT_LATENCY_GEN1 : integer;
        LINK_CAP_L0S_EXIT_LATENCY_GEN2 : integer;
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 : integer;
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 : integer;
        LINK_CAP_L1_EXIT_LATENCY_GEN1 : integer;
        LINK_CAP_L1_EXIT_LATENCY_GEN2 : integer;
        LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP : string;
        LINK_CAP_MAX_LINK_SPEED : string;
        LINK_CAP_MAX_LINK_WIDTH : string;
        LINK_CAP_RSVD_23 : integer;
        LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE : string;
        LINK_CONTROL_RCB : integer;
        LINK_CTRL2_DEEMPHASIS : string;
        LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE : string;
        LINK_CTRL2_TARGET_LINK_SPEED : string;
        LINK_STATUS_SLOT_CLOCK_CONFIG : string;
        LL_ACK_TIMEOUT : string;
        LL_ACK_TIMEOUT_EN : string;
        LL_ACK_TIMEOUT_FUNC : integer;
        LL_REPLAY_TIMEOUT : string;
        LL_REPLAY_TIMEOUT_EN : string;
        LL_REPLAY_TIMEOUT_FUNC : integer;
        LTSSM_MAX_LINK_WIDTH : string;
        MPS_FORCE : string;
        MSIX_BASE_PTR : string;
        MSIX_CAP_ID : string;
        MSIX_CAP_NEXTPTR : string;
        MSIX_CAP_ON : string;
        MSIX_CAP_PBA_BIR : integer;
        MSIX_CAP_PBA_OFFSET : string;
        MSIX_CAP_TABLE_BIR : integer;
        MSIX_CAP_TABLE_OFFSET : string;
        MSIX_CAP_TABLE_SIZE : string;
        MSI_BASE_PTR : string;
        MSI_CAP_64_BIT_ADDR_CAPABLE : string;
        MSI_CAP_ID : string;
        MSI_CAP_MULTIMSGCAP : integer;
        MSI_CAP_MULTIMSG_EXTENSION : integer;
        MSI_CAP_NEXTPTR : string;
        MSI_CAP_ON : string;
        MSI_CAP_PER_VECTOR_MASKING_CAPABLE : string;
        N_FTS_COMCLK_GEN1 : integer;
        N_FTS_COMCLK_GEN2 : integer;
        N_FTS_GEN1 : integer;
        N_FTS_GEN2 : integer;
        PCIE_BASE_PTR : string;
        PCIE_CAP_CAPABILITY_ID : string;
        PCIE_CAP_CAPABILITY_VERSION : string;
        PCIE_CAP_DEVICE_PORT_TYPE : string;
        PCIE_CAP_NEXTPTR : string;
        PCIE_CAP_ON : string;
        PCIE_CAP_RSVD_15_14 : integer;
        PCIE_CAP_SLOT_IMPLEMENTED : string;
        PCIE_REVISION : integer;
        PL_AUTO_CONFIG : integer;
        PL_FAST_TRAIN : string;
        PM_ASPML0S_TIMEOUT : string;
        PM_ASPML0S_TIMEOUT_EN : string;
        PM_ASPML0S_TIMEOUT_FUNC : integer;
        PM_ASPM_FASTEXIT : string;
        PM_BASE_PTR : string;
        PM_CAP_AUXCURRENT : integer;
        PM_CAP_D1SUPPORT : string;
        PM_CAP_D2SUPPORT : string;
        PM_CAP_DSI : string;
        PM_CAP_ID : string;
        PM_CAP_NEXTPTR : string;
        PM_CAP_ON : string;
        PM_CAP_PMESUPPORT : string;
        PM_CAP_PME_CLOCK : string;
        PM_CAP_RSVD_04 : integer;
        PM_CAP_VERSION : integer;
        PM_CSR_B2B3 : string;
        PM_CSR_BPCCEN : string;
        PM_CSR_NOSOFTRST : string;
        PM_DATA0 : string;
        PM_DATA1 : string;
        PM_DATA2 : string;
        PM_DATA3 : string;
        PM_DATA4 : string;
        PM_DATA5 : string;
        PM_DATA6 : string;
        PM_DATA7 : string;
        PM_DATA_SCALE0 : string;
        PM_DATA_SCALE1 : string;
        PM_DATA_SCALE2 : string;
        PM_DATA_SCALE3 : string;
        PM_DATA_SCALE4 : string;
        PM_DATA_SCALE5 : string;
        PM_DATA_SCALE6 : string;
        PM_DATA_SCALE7 : string;
        PM_MF : string;
        RBAR_BASE_PTR : string;
        RBAR_CAP_CONTROL_ENCODEDBAR0 : string;
        RBAR_CAP_CONTROL_ENCODEDBAR1 : string;
        RBAR_CAP_CONTROL_ENCODEDBAR2 : string;
        RBAR_CAP_CONTROL_ENCODEDBAR3 : string;
        RBAR_CAP_CONTROL_ENCODEDBAR4 : string;
        RBAR_CAP_CONTROL_ENCODEDBAR5 : string;
        RBAR_CAP_ID : string;
        RBAR_CAP_INDEX0 : string;
        RBAR_CAP_INDEX1 : string;
        RBAR_CAP_INDEX2 : string;
        RBAR_CAP_INDEX3 : string;
        RBAR_CAP_INDEX4 : string;
        RBAR_CAP_INDEX5 : string;
        RBAR_CAP_NEXTPTR : string;
        RBAR_CAP_ON : string;
        RBAR_CAP_SUP0 : string;
        RBAR_CAP_SUP1 : string;
        RBAR_CAP_SUP2 : string;
        RBAR_CAP_SUP3 : string;
        RBAR_CAP_SUP4 : string;
        RBAR_CAP_SUP5 : string;
        RBAR_CAP_VERSION : string;
        RBAR_NUM : string;
        RECRC_CHK : integer;
        RECRC_CHK_TRIM : string;
        ROOT_CAP_CRS_SW_VISIBILITY : string;
        RP_AUTO_SPD : string;
        RP_AUTO_SPD_LOOPCNT : string;
        SELECT_DLL_IF : string;
        SIM_VERSION : string;
        SLOT_CAP_ATT_BUTTON_PRESENT : string;
        SLOT_CAP_ATT_INDICATOR_PRESENT : string;
        SLOT_CAP_ELEC_INTERLOCK_PRESENT : string;
        SLOT_CAP_HOTPLUG_CAPABLE : string;
        SLOT_CAP_HOTPLUG_SURPRISE : string;
        SLOT_CAP_MRL_SENSOR_PRESENT : string;
        SLOT_CAP_NO_CMD_COMPLETED_SUPPORT : string;
        SLOT_CAP_PHYSICAL_SLOT_NUM : string;
        SLOT_CAP_POWER_CONTROLLER_PRESENT : string;
        SLOT_CAP_POWER_INDICATOR_PRESENT : string;
        SLOT_CAP_SLOT_POWER_LIMIT_SCALE : integer;
        SLOT_CAP_SLOT_POWER_LIMIT_VALUE : string;
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
        SSL_MESSAGE_AUTO : string;
        TECRC_EP_INV : string;
        TL_RBYPASS : string;
        TL_RX_RAM_RADDR_LATENCY : integer;
        TL_RX_RAM_RDATA_LATENCY : integer;
        TL_RX_RAM_WRITE_LATENCY : integer;
        TL_TFC_DISABLE : string;
        TL_TX_CHECKS_DISABLE : string;
        TL_TX_RAM_RADDR_LATENCY : integer;
        TL_TX_RAM_RDATA_LATENCY : integer;
        TL_TX_RAM_WRITE_LATENCY : integer;
        TRN_DW : string;
        TRN_NP_FC : string;
        UPCONFIG_CAPABLE : string;
        UPSTREAM_FACING : string;
        UR_ATOMIC : string;
        UR_CFG1 : string;
        UR_INV_REQ : string;
        UR_PRS_RESPONSE : string;
        USER_CLK2_DIV2 : string;
        USER_CLK_FREQ : integer;
        USE_RID_PINS : string;
        VC0_CPL_INFINITE : string;
        VC0_RX_RAM_LIMIT : string;
        VC0_TOTAL_CREDITS_CD : integer;
        VC0_TOTAL_CREDITS_CH : integer;
        VC0_TOTAL_CREDITS_NPD : integer;
        VC0_TOTAL_CREDITS_NPH : integer;
        VC0_TOTAL_CREDITS_PD : integer;
        VC0_TOTAL_CREDITS_PH : integer;
        VC0_TX_LASTPACKET : integer;
        VC_BASE_PTR : string;
        VC_CAP_ID : string;
        VC_CAP_NEXTPTR : string;
        VC_CAP_ON : string;
        VC_CAP_REJECT_SNOOP_TRANSACTIONS : string;
        VC_CAP_VERSION : string;
        VSEC_BASE_PTR : string;
        VSEC_CAP_HDR_ID : string;
        VSEC_CAP_HDR_LENGTH : string;
        VSEC_CAP_HDR_REVISION : string;
        VSEC_CAP_ID : string;
        VSEC_CAP_IS_LINK_VISIBLE : string;
        VSEC_CAP_NEXTPTR : string;
        VSEC_CAP_ON : string;
        VSEC_CAP_VERSION : string        
      );
      
      port (
        CFGAERECRCCHECKEN    : out std_ulogic;
        CFGAERECRCGENEN      : out std_ulogic;
        CFGAERROOTERRCORRERRRECEIVED : out std_ulogic;
        CFGAERROOTERRCORRERRREPORTINGEN : out std_ulogic;
        CFGAERROOTERRFATALERRRECEIVED : out std_ulogic;
        CFGAERROOTERRFATALERRREPORTINGEN : out std_ulogic;
        CFGAERROOTERRNONFATALERRRECEIVED : out std_ulogic;
        CFGAERROOTERRNONFATALERRREPORTINGEN : out std_ulogic;
        CFGBRIDGESERREN      : out std_ulogic;
        CFGCOMMANDBUSMASTERENABLE : out std_ulogic;
        CFGCOMMANDINTERRUPTDISABLE : out std_ulogic;
        CFGCOMMANDIOENABLE   : out std_ulogic;
        CFGCOMMANDMEMENABLE  : out std_ulogic;
        CFGCOMMANDSERREN     : out std_ulogic;
        CFGDEVCONTROL2ARIFORWARDEN : out std_ulogic;
        CFGDEVCONTROL2ATOMICEGRESSBLOCK : out std_ulogic;
        CFGDEVCONTROL2ATOMICREQUESTEREN : out std_ulogic;
        CFGDEVCONTROL2CPLTIMEOUTDIS : out std_ulogic;
        CFGDEVCONTROL2CPLTIMEOUTVAL : out std_logic_vector(3 downto 0);
        CFGDEVCONTROL2IDOCPLEN : out std_ulogic;
        CFGDEVCONTROL2IDOREQEN : out std_ulogic;
        CFGDEVCONTROL2LTREN  : out std_ulogic;
        CFGDEVCONTROL2TLPPREFIXBLOCK : out std_ulogic;
        CFGDEVCONTROLAUXPOWEREN : out std_ulogic;
        CFGDEVCONTROLCORRERRREPORTINGEN : out std_ulogic;
        CFGDEVCONTROLENABLERO : out std_ulogic;
        CFGDEVCONTROLEXTTAGEN : out std_ulogic;
        CFGDEVCONTROLFATALERRREPORTINGEN : out std_ulogic;
        CFGDEVCONTROLMAXPAYLOAD : out std_logic_vector(2 downto 0);
        CFGDEVCONTROLMAXREADREQ : out std_logic_vector(2 downto 0);
        CFGDEVCONTROLNONFATALREPORTINGEN : out std_ulogic;
        CFGDEVCONTROLNOSNOOPEN : out std_ulogic;
        CFGDEVCONTROLPHANTOMEN : out std_ulogic;
        CFGDEVCONTROLURERRREPORTINGEN : out std_ulogic;
        CFGDEVSTATUSCORRERRDETECTED : out std_ulogic;
        CFGDEVSTATUSFATALERRDETECTED : out std_ulogic;
        CFGDEVSTATUSNONFATALERRDETECTED : out std_ulogic;
        CFGDEVSTATUSURDETECTED : out std_ulogic;
        CFGERRAERHEADERLOGSETN : out std_ulogic;
        CFGERRCPLRDYN        : out std_ulogic;
        CFGINTERRUPTDO       : out std_logic_vector(7 downto 0);
        CFGINTERRUPTMMENABLE : out std_logic_vector(2 downto 0);
        CFGINTERRUPTMSIENABLE : out std_ulogic;
        CFGINTERRUPTMSIXENABLE : out std_ulogic;
        CFGINTERRUPTMSIXFM   : out std_ulogic;
        CFGINTERRUPTRDYN     : out std_ulogic;
        CFGLINKCONTROLASPMCONTROL : out std_logic_vector(1 downto 0);
        CFGLINKCONTROLAUTOBANDWIDTHINTEN : out std_ulogic;
        CFGLINKCONTROLBANDWIDTHINTEN : out std_ulogic;
        CFGLINKCONTROLCLOCKPMEN : out std_ulogic;
        CFGLINKCONTROLCOMMONCLOCK : out std_ulogic;
        CFGLINKCONTROLEXTENDEDSYNC : out std_ulogic;
        CFGLINKCONTROLHWAUTOWIDTHDIS : out std_ulogic;
        CFGLINKCONTROLLINKDISABLE : out std_ulogic;
        CFGLINKCONTROLRCB    : out std_ulogic;
        CFGLINKCONTROLRETRAINLINK : out std_ulogic;
        CFGLINKSTATUSAUTOBANDWIDTHSTATUS : out std_ulogic;
        CFGLINKSTATUSBANDWIDTHSTATUS : out std_ulogic;
        CFGLINKSTATUSCURRENTSPEED : out std_logic_vector(1 downto 0);
        CFGLINKSTATUSDLLACTIVE : out std_ulogic;
        CFGLINKSTATUSLINKTRAINING : out std_ulogic;
        CFGLINKSTATUSNEGOTIATEDWIDTH : out std_logic_vector(3 downto 0);
        CFGMGMTDO            : out std_logic_vector(31 downto 0);
        CFGMGMTRDWRDONEN     : out std_ulogic;
        CFGMSGDATA           : out std_logic_vector(15 downto 0);
        CFGMSGRECEIVED       : out std_ulogic;
        CFGMSGRECEIVEDASSERTINTA : out std_ulogic;
        CFGMSGRECEIVEDASSERTINTB : out std_ulogic;
        CFGMSGRECEIVEDASSERTINTC : out std_ulogic;
        CFGMSGRECEIVEDASSERTINTD : out std_ulogic;
        CFGMSGRECEIVEDDEASSERTINTA : out std_ulogic;
        CFGMSGRECEIVEDDEASSERTINTB : out std_ulogic;
        CFGMSGRECEIVEDDEASSERTINTC : out std_ulogic;
        CFGMSGRECEIVEDDEASSERTINTD : out std_ulogic;
        CFGMSGRECEIVEDERRCOR : out std_ulogic;
        CFGMSGRECEIVEDERRFATAL : out std_ulogic;
        CFGMSGRECEIVEDERRNONFATAL : out std_ulogic;
        CFGMSGRECEIVEDPMASNAK : out std_ulogic;
        CFGMSGRECEIVEDPMETO  : out std_ulogic;
        CFGMSGRECEIVEDPMETOACK : out std_ulogic;
        CFGMSGRECEIVEDPMPME  : out std_ulogic;
        CFGMSGRECEIVEDSETSLOTPOWERLIMIT : out std_ulogic;
        CFGMSGRECEIVEDUNLOCK : out std_ulogic;
        CFGPCIELINKSTATE     : out std_logic_vector(2 downto 0);
        CFGPMCSRPMEEN        : out std_ulogic;
        CFGPMCSRPMESTATUS    : out std_ulogic;
        CFGPMCSRPOWERSTATE   : out std_logic_vector(1 downto 0);
        CFGPMRCVASREQL1N     : out std_ulogic;
        CFGPMRCVENTERL1N     : out std_ulogic;
        CFGPMRCVENTERL23N    : out std_ulogic;
        CFGPMRCVREQACKN      : out std_ulogic;
        CFGROOTCONTROLPMEINTEN : out std_ulogic;
        CFGROOTCONTROLSYSERRCORRERREN : out std_ulogic;
        CFGROOTCONTROLSYSERRFATALERREN : out std_ulogic;
        CFGROOTCONTROLSYSERRNONFATALERREN : out std_ulogic;
        CFGSLOTCONTROLELECTROMECHILCTLPULSE : out std_ulogic;
        CFGTRANSACTION       : out std_ulogic;
        CFGTRANSACTIONADDR   : out std_logic_vector(6 downto 0);
        CFGTRANSACTIONTYPE   : out std_ulogic;
        CFGVCTCVCMAP         : out std_logic_vector(6 downto 0);
        DBGSCLRA             : out std_ulogic;
        DBGSCLRB             : out std_ulogic;
        DBGSCLRC             : out std_ulogic;
        DBGSCLRD             : out std_ulogic;
        DBGSCLRE             : out std_ulogic;
        DBGSCLRF             : out std_ulogic;
        DBGSCLRG             : out std_ulogic;
        DBGSCLRH             : out std_ulogic;
        DBGSCLRI             : out std_ulogic;
        DBGSCLRJ             : out std_ulogic;
        DBGSCLRK             : out std_ulogic;
        DBGVECA              : out std_logic_vector(63 downto 0);
        DBGVECB              : out std_logic_vector(63 downto 0);
        DBGVECC              : out std_logic_vector(11 downto 0);
        DRPDO                : out std_logic_vector(15 downto 0);
        DRPRDY               : out std_ulogic;
        LL2BADDLLPERR        : out std_ulogic;
        LL2BADTLPERR         : out std_ulogic;
        LL2LINKSTATUS        : out std_logic_vector(4 downto 0);
        LL2PROTOCOLERR       : out std_ulogic;
        LL2RECEIVERERR       : out std_ulogic;
        LL2REPLAYROERR       : out std_ulogic;
        LL2REPLAYTOERR       : out std_ulogic;
        LL2SUSPENDOK         : out std_ulogic;
        LL2TFCINIT1SEQ       : out std_ulogic;
        LL2TFCINIT2SEQ       : out std_ulogic;
        LL2TXIDLE            : out std_ulogic;
        LNKCLKEN             : out std_ulogic;
        MIMRXRADDR           : out std_logic_vector(12 downto 0);
        MIMRXREN             : out std_ulogic;
        MIMRXWADDR           : out std_logic_vector(12 downto 0);
        MIMRXWDATA           : out std_logic_vector(67 downto 0);
        MIMRXWEN             : out std_ulogic;
        MIMTXRADDR           : out std_logic_vector(12 downto 0);
        MIMTXREN             : out std_ulogic;
        MIMTXWADDR           : out std_logic_vector(12 downto 0);
        MIMTXWDATA           : out std_logic_vector(68 downto 0);
        MIMTXWEN             : out std_ulogic;
        PIPERX0POLARITY      : out std_ulogic;
        PIPERX1POLARITY      : out std_ulogic;
        PIPERX2POLARITY      : out std_ulogic;
        PIPERX3POLARITY      : out std_ulogic;
        PIPERX4POLARITY      : out std_ulogic;
        PIPERX5POLARITY      : out std_ulogic;
        PIPERX6POLARITY      : out std_ulogic;
        PIPERX7POLARITY      : out std_ulogic;
        PIPETX0CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX0COMPLIANCE    : out std_ulogic;
        PIPETX0DATA          : out std_logic_vector(15 downto 0);
        PIPETX0ELECIDLE      : out std_ulogic;
        PIPETX0POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX1CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX1COMPLIANCE    : out std_ulogic;
        PIPETX1DATA          : out std_logic_vector(15 downto 0);
        PIPETX1ELECIDLE      : out std_ulogic;
        PIPETX1POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX2CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX2COMPLIANCE    : out std_ulogic;
        PIPETX2DATA          : out std_logic_vector(15 downto 0);
        PIPETX2ELECIDLE      : out std_ulogic;
        PIPETX2POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX3CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX3COMPLIANCE    : out std_ulogic;
        PIPETX3DATA          : out std_logic_vector(15 downto 0);
        PIPETX3ELECIDLE      : out std_ulogic;
        PIPETX3POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX4CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX4COMPLIANCE    : out std_ulogic;
        PIPETX4DATA          : out std_logic_vector(15 downto 0);
        PIPETX4ELECIDLE      : out std_ulogic;
        PIPETX4POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX5CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX5COMPLIANCE    : out std_ulogic;
        PIPETX5DATA          : out std_logic_vector(15 downto 0);
        PIPETX5ELECIDLE      : out std_ulogic;
        PIPETX5POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX6CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX6COMPLIANCE    : out std_ulogic;
        PIPETX6DATA          : out std_logic_vector(15 downto 0);
        PIPETX6ELECIDLE      : out std_ulogic;
        PIPETX6POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETX7CHARISK       : out std_logic_vector(1 downto 0);
        PIPETX7COMPLIANCE    : out std_ulogic;
        PIPETX7DATA          : out std_logic_vector(15 downto 0);
        PIPETX7ELECIDLE      : out std_ulogic;
        PIPETX7POWERDOWN     : out std_logic_vector(1 downto 0);
        PIPETXDEEMPH         : out std_ulogic;
        PIPETXMARGIN         : out std_logic_vector(2 downto 0);
        PIPETXRATE           : out std_ulogic;
        PIPETXRCVRDET        : out std_ulogic;
        PIPETXRESET          : out std_ulogic;
        PL2L0REQ             : out std_ulogic;
        PL2LINKUP            : out std_ulogic;
        PL2RECEIVERERR       : out std_ulogic;
        PL2RECOVERY          : out std_ulogic;
        PL2RXELECIDLE        : out std_ulogic;
        PL2RXPMSTATE         : out std_logic_vector(1 downto 0);
        PL2SUSPENDOK         : out std_ulogic;
        PLDBGVEC             : out std_logic_vector(11 downto 0);
        PLDIRECTEDCHANGEDONE : out std_ulogic;
        PLINITIALLINKWIDTH   : out std_logic_vector(2 downto 0);
        PLLANEREVERSALMODE   : out std_logic_vector(1 downto 0);
        PLLINKGEN2CAP        : out std_ulogic;
        PLLINKPARTNERGEN2SUPPORTED : out std_ulogic;
        PLLINKUPCFGCAP       : out std_ulogic;
        PLLTSSMSTATE         : out std_logic_vector(5 downto 0);
        PLPHYLNKUPN          : out std_ulogic;
        PLRECEIVEDHOTRST     : out std_ulogic;
        PLRXPMSTATE          : out std_logic_vector(1 downto 0);
        PLSELLNKRATE         : out std_ulogic;
        PLSELLNKWIDTH        : out std_logic_vector(1 downto 0);
        PLTXPMSTATE          : out std_logic_vector(2 downto 0);
        RECEIVEDFUNCLVLRSTN  : out std_ulogic;
        TL2ASPMSUSPENDCREDITCHECKOK : out std_ulogic;
        TL2ASPMSUSPENDREQ    : out std_ulogic;
        TL2ERRFCPE           : out std_ulogic;
        TL2ERRHDR            : out std_logic_vector(63 downto 0);
        TL2ERRMALFORMED      : out std_ulogic;
        TL2ERRRXOVERFLOW     : out std_ulogic;
        TL2PPMSUSPENDOK      : out std_ulogic;
        TRNFCCPLD            : out std_logic_vector(11 downto 0);
        TRNFCCPLH            : out std_logic_vector(7 downto 0);
        TRNFCNPD             : out std_logic_vector(11 downto 0);
        TRNFCNPH             : out std_logic_vector(7 downto 0);
        TRNFCPD              : out std_logic_vector(11 downto 0);
        TRNFCPH              : out std_logic_vector(7 downto 0);
        TRNLNKUP             : out std_ulogic;
        TRNRBARHIT           : out std_logic_vector(7 downto 0);
        TRNRD                : out std_logic_vector(127 downto 0);
        TRNRDLLPDATA         : out std_logic_vector(63 downto 0);
        TRNRDLLPSRCRDY       : out std_logic_vector(1 downto 0);
        TRNRECRCERR          : out std_ulogic;
        TRNREOF              : out std_ulogic;
        TRNRERRFWD           : out std_ulogic;
        TRNRREM              : out std_logic_vector(1 downto 0);
        TRNRSOF              : out std_ulogic;
        TRNRSRCDSC           : out std_ulogic;
        TRNRSRCRDY           : out std_ulogic;
        TRNTBUFAV            : out std_logic_vector(5 downto 0);
        TRNTCFGREQ           : out std_ulogic;
        TRNTDLLPDSTRDY       : out std_ulogic;
        TRNTDSTRDY           : out std_logic_vector(3 downto 0);
        TRNTERRDROP          : out std_ulogic;
        USERRSTN             : out std_ulogic;
        CFGAERINTERRUPTMSGNUM : in std_logic_vector(4 downto 0);
        CFGDEVID             : in std_logic_vector(15 downto 0);
        CFGDSBUSNUMBER       : in std_logic_vector(7 downto 0);
        CFGDSDEVICENUMBER    : in std_logic_vector(4 downto 0);
        CFGDSFUNCTIONNUMBER  : in std_logic_vector(2 downto 0);
        CFGDSN               : in std_logic_vector(63 downto 0);
        CFGERRACSN           : in std_ulogic;
        CFGERRAERHEADERLOG   : in std_logic_vector(127 downto 0);
        CFGERRATOMICEGRESSBLOCKEDN : in std_ulogic;
        CFGERRCORN           : in std_ulogic;
        CFGERRCPLABORTN      : in std_ulogic;
        CFGERRCPLTIMEOUTN    : in std_ulogic;
        CFGERRCPLUNEXPECTN   : in std_ulogic;
        CFGERRECRCN          : in std_ulogic;
        CFGERRINTERNALCORN   : in std_ulogic;
        CFGERRINTERNALUNCORN : in std_ulogic;
        CFGERRLOCKEDN        : in std_ulogic;
        CFGERRMALFORMEDN     : in std_ulogic;
        CFGERRMCBLOCKEDN     : in std_ulogic;
        CFGERRNORECOVERYN    : in std_ulogic;
        CFGERRPOISONEDN      : in std_ulogic;
        CFGERRPOSTEDN        : in std_ulogic;
        CFGERRTLPCPLHEADER   : in std_logic_vector(47 downto 0);
        CFGERRURN            : in std_ulogic;
        CFGFORCECOMMONCLOCKOFF : in std_ulogic;
        CFGFORCEEXTENDEDSYNCON : in std_ulogic;
        CFGFORCEMPS          : in std_logic_vector(2 downto 0);
        CFGINTERRUPTASSERTN  : in std_ulogic;
        CFGINTERRUPTDI       : in std_logic_vector(7 downto 0);
        CFGINTERRUPTN        : in std_ulogic;
        CFGINTERRUPTSTATN    : in std_ulogic;
        CFGMGMTBYTEENN       : in std_logic_vector(3 downto 0);
        CFGMGMTDI            : in std_logic_vector(31 downto 0);
        CFGMGMTDWADDR        : in std_logic_vector(9 downto 0);
        CFGMGMTRDENN         : in std_ulogic;
        CFGMGMTWRENN         : in std_ulogic;
        CFGMGMTWRREADONLYN   : in std_ulogic;
        CFGMGMTWRRW1CASRWN   : in std_ulogic;
        CFGPCIECAPINTERRUPTMSGNUM : in std_logic_vector(4 downto 0);
        CFGPMFORCESTATE      : in std_logic_vector(1 downto 0);
        CFGPMFORCESTATEENN   : in std_ulogic;
        CFGPMHALTASPML0SN    : in std_ulogic;
        CFGPMHALTASPML1N     : in std_ulogic;
        CFGPMSENDPMETON      : in std_ulogic;
        CFGPMTURNOFFOKN      : in std_ulogic;
        CFGPMWAKEN           : in std_ulogic;
        CFGPORTNUMBER        : in std_logic_vector(7 downto 0);
        CFGREVID             : in std_logic_vector(7 downto 0);
        CFGSUBSYSID          : in std_logic_vector(15 downto 0);
        CFGSUBSYSVENDID      : in std_logic_vector(15 downto 0);
        CFGTRNPENDINGN       : in std_ulogic;
        CFGVENDID            : in std_logic_vector(15 downto 0);
        CMRSTN               : in std_ulogic;
        CMSTICKYRSTN         : in std_ulogic;
        DBGMODE              : in std_logic_vector(1 downto 0);
        DBGSUBMODE           : in std_ulogic;
        DLRSTN               : in std_ulogic;
        DRPADDR              : in std_logic_vector(8 downto 0);
        DRPCLK               : in std_ulogic;
        DRPDI                : in std_logic_vector(15 downto 0);
        DRPEN                : in std_ulogic;
        DRPWE                : in std_ulogic;
        FUNCLVLRSTN          : in std_ulogic;
        LL2SENDASREQL1       : in std_ulogic;
        LL2SENDENTERL1       : in std_ulogic;
        LL2SENDENTERL23      : in std_ulogic;
        LL2SENDPMACK         : in std_ulogic;
        LL2SUSPENDNOW        : in std_ulogic;
        LL2TLPRCV            : in std_ulogic;
        MIMRXRDATA           : in std_logic_vector(67 downto 0);
        MIMTXRDATA           : in std_logic_vector(68 downto 0);
        PIPECLK              : in std_ulogic;
        PIPERX0CHANISALIGNED : in std_ulogic;
        PIPERX0CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX0DATA          : in std_logic_vector(15 downto 0);
        PIPERX0ELECIDLE      : in std_ulogic;
        PIPERX0PHYSTATUS     : in std_ulogic;
        PIPERX0STATUS        : in std_logic_vector(2 downto 0);
        PIPERX0VALID         : in std_ulogic;
        PIPERX1CHANISALIGNED : in std_ulogic;
        PIPERX1CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX1DATA          : in std_logic_vector(15 downto 0);
        PIPERX1ELECIDLE      : in std_ulogic;
        PIPERX1PHYSTATUS     : in std_ulogic;
        PIPERX1STATUS        : in std_logic_vector(2 downto 0);
        PIPERX1VALID         : in std_ulogic;
        PIPERX2CHANISALIGNED : in std_ulogic;
        PIPERX2CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX2DATA          : in std_logic_vector(15 downto 0);
        PIPERX2ELECIDLE      : in std_ulogic;
        PIPERX2PHYSTATUS     : in std_ulogic;
        PIPERX2STATUS        : in std_logic_vector(2 downto 0);
        PIPERX2VALID         : in std_ulogic;
        PIPERX3CHANISALIGNED : in std_ulogic;
        PIPERX3CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX3DATA          : in std_logic_vector(15 downto 0);
        PIPERX3ELECIDLE      : in std_ulogic;
        PIPERX3PHYSTATUS     : in std_ulogic;
        PIPERX3STATUS        : in std_logic_vector(2 downto 0);
        PIPERX3VALID         : in std_ulogic;
        PIPERX4CHANISALIGNED : in std_ulogic;
        PIPERX4CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX4DATA          : in std_logic_vector(15 downto 0);
        PIPERX4ELECIDLE      : in std_ulogic;
        PIPERX4PHYSTATUS     : in std_ulogic;
        PIPERX4STATUS        : in std_logic_vector(2 downto 0);
        PIPERX4VALID         : in std_ulogic;
        PIPERX5CHANISALIGNED : in std_ulogic;
        PIPERX5CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX5DATA          : in std_logic_vector(15 downto 0);
        PIPERX5ELECIDLE      : in std_ulogic;
        PIPERX5PHYSTATUS     : in std_ulogic;
        PIPERX5STATUS        : in std_logic_vector(2 downto 0);
        PIPERX5VALID         : in std_ulogic;
        PIPERX6CHANISALIGNED : in std_ulogic;
        PIPERX6CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX6DATA          : in std_logic_vector(15 downto 0);
        PIPERX6ELECIDLE      : in std_ulogic;
        PIPERX6PHYSTATUS     : in std_ulogic;
        PIPERX6STATUS        : in std_logic_vector(2 downto 0);
        PIPERX6VALID         : in std_ulogic;
        PIPERX7CHANISALIGNED : in std_ulogic;
        PIPERX7CHARISK       : in std_logic_vector(1 downto 0);
        PIPERX7DATA          : in std_logic_vector(15 downto 0);
        PIPERX7ELECIDLE      : in std_ulogic;
        PIPERX7PHYSTATUS     : in std_ulogic;
        PIPERX7STATUS        : in std_logic_vector(2 downto 0);
        PIPERX7VALID         : in std_ulogic;
        PL2DIRECTEDLSTATE    : in std_logic_vector(4 downto 0);
        PLDBGMODE            : in std_logic_vector(2 downto 0);
        PLDIRECTEDLINKAUTON  : in std_ulogic;
        PLDIRECTEDLINKCHANGE : in std_logic_vector(1 downto 0);
        PLDIRECTEDLINKSPEED  : in std_ulogic;
        PLDIRECTEDLINKWIDTH  : in std_logic_vector(1 downto 0);
        PLDIRECTEDLTSSMNEW   : in std_logic_vector(5 downto 0);
        PLDIRECTEDLTSSMNEWVLD : in std_ulogic;
        PLDIRECTEDLTSSMSTALL : in std_ulogic;
        PLDOWNSTREAMDEEMPHSOURCE : in std_ulogic;
        PLRSTN               : in std_ulogic;
        PLTRANSMITHOTRST     : in std_ulogic;
        PLUPSTREAMPREFERDEEMPH : in std_ulogic;
        SYSRSTN              : in std_ulogic;
        TL2ASPMSUSPENDCREDITCHECK : in std_ulogic;
        TL2PPMSUSPENDREQ     : in std_ulogic;
        TLRSTN               : in std_ulogic;
        TRNFCSEL             : in std_logic_vector(2 downto 0);
        TRNRDSTRDY           : in std_ulogic;
        TRNRFCPRET           : in std_ulogic;
        TRNRNPOK             : in std_ulogic;
        TRNRNPREQ            : in std_ulogic;
        TRNTCFGGNT           : in std_ulogic;
        TRNTD                : in std_logic_vector(127 downto 0);
        TRNTDLLPDATA         : in std_logic_vector(31 downto 0);
        TRNTDLLPSRCRDY       : in std_ulogic;
        TRNTECRCGEN          : in std_ulogic;
        TRNTEOF              : in std_ulogic;
        TRNTERRFWD           : in std_ulogic;
        TRNTREM              : in std_logic_vector(1 downto 0);
        TRNTSOF              : in std_ulogic;
        TRNTSRCDSC           : in std_ulogic;
        TRNTSRCRDY           : in std_ulogic;
        TRNTSTR              : in std_ulogic;
        USERCLK              : in std_ulogic;
        USERCLK2             : in std_ulogic        
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
    constant AER_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(AER_BASE_PTR)(11 downto 0);
    constant AER_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(AER_CAP_ID)(15 downto 0);
    constant AER_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(AER_CAP_NEXTPTR)(11 downto 0);
    constant AER_CAP_OPTIONAL_ERR_SUPPORT_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(AER_CAP_OPTIONAL_ERR_SUPPORT)(23 downto 0);
    constant AER_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(AER_CAP_VERSION)(3 downto 0);
    constant BAR0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR0)(31 downto 0);
    constant BAR1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR1)(31 downto 0);
    constant BAR2_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR2)(31 downto 0);
    constant BAR3_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR3)(31 downto 0);
    constant BAR4_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR4)(31 downto 0);
    constant BAR5_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR5)(31 downto 0);
    constant CAPABILITIES_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(CAPABILITIES_PTR)(7 downto 0);
    constant CARDBUS_CIS_POINTER_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(CARDBUS_CIS_POINTER)(31 downto 0);
    constant CLASS_CODE_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(CLASS_CODE)(23 downto 0);
    constant CPL_TIMEOUT_RANGES_SUPPORTED_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CPL_TIMEOUT_RANGES_SUPPORTED)(3 downto 0);
    constant CRM_MODULE_RSTS_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(CRM_MODULE_RSTS)(6 downto 0);
    constant DEV_CAP2_MAX_ENDEND_TLP_PREFIXES_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(DEV_CAP2_MAX_ENDEND_TLP_PREFIXES)(1 downto 0);
    constant DEV_CAP2_TPH_COMPLETER_SUPPORTED_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(DEV_CAP2_TPH_COMPLETER_SUPPORTED)(1 downto 0);
    constant DNSTREAM_LINK_NUM_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(DNSTREAM_LINK_NUM)(7 downto 0);
    constant DSN_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(DSN_BASE_PTR)(11 downto 0);
    constant DSN_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DSN_CAP_ID)(15 downto 0);
    constant DSN_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(DSN_CAP_NEXTPTR)(11 downto 0);
    constant DSN_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(DSN_CAP_VERSION)(3 downto 0);
    constant ENABLE_MSG_ROUTE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(ENABLE_MSG_ROUTE)(10 downto 0);
    constant EXPANSION_ROM_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(EXPANSION_ROM)(31 downto 0);
    constant EXT_CFG_CAP_PTR_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(EXT_CFG_CAP_PTR)(5 downto 0);
    constant EXT_CFG_XP_CAP_PTR_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(EXT_CFG_XP_CAP_PTR)(9 downto 0);
    constant HEADER_TYPE_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(HEADER_TYPE)(7 downto 0);
    constant INFER_EI_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(INFER_EI)(4 downto 0);
    constant INTERRUPT_PIN_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(INTERRUPT_PIN)(7 downto 0);
    constant LAST_CONFIG_DWORD_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(LAST_CONFIG_DWORD)(9 downto 0);
    constant LINK_CAP_MAX_LINK_SPEED_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(LINK_CAP_MAX_LINK_SPEED)(3 downto 0);
    constant LINK_CAP_MAX_LINK_WIDTH_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(LINK_CAP_MAX_LINK_WIDTH)(5 downto 0);
    constant LINK_CTRL2_TARGET_LINK_SPEED_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(LINK_CTRL2_TARGET_LINK_SPEED)(3 downto 0);
    constant LL_ACK_TIMEOUT_BINARY : std_logic_vector(14 downto 0) := To_StdLogicVector(LL_ACK_TIMEOUT)(14 downto 0);
    constant LL_REPLAY_TIMEOUT_BINARY : std_logic_vector(14 downto 0) := To_StdLogicVector(LL_REPLAY_TIMEOUT)(14 downto 0);
    constant LTSSM_MAX_LINK_WIDTH_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(LTSSM_MAX_LINK_WIDTH)(5 downto 0);
    constant MSIX_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSIX_BASE_PTR)(7 downto 0);
    constant MSIX_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSIX_CAP_ID)(7 downto 0);
    constant MSIX_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSIX_CAP_NEXTPTR)(7 downto 0);
    constant MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(MSIX_CAP_PBA_OFFSET)(28 downto 0);
    constant MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(MSIX_CAP_TABLE_OFFSET)(28 downto 0);
    constant MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(MSIX_CAP_TABLE_SIZE)(10 downto 0);
    constant MSI_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSI_BASE_PTR)(7 downto 0);
    constant MSI_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSI_CAP_ID)(7 downto 0);
    constant MSI_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSI_CAP_NEXTPTR)(7 downto 0);
    constant PCIE_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PCIE_BASE_PTR)(7 downto 0);
    constant PCIE_CAP_CAPABILITY_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PCIE_CAP_CAPABILITY_ID)(7 downto 0);
    constant PCIE_CAP_CAPABILITY_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PCIE_CAP_CAPABILITY_VERSION)(3 downto 0);
    constant PCIE_CAP_DEVICE_PORT_TYPE_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PCIE_CAP_DEVICE_PORT_TYPE)(3 downto 0);
    constant PCIE_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PCIE_CAP_NEXTPTR)(7 downto 0);
    constant PM_ASPML0S_TIMEOUT_BINARY : std_logic_vector(14 downto 0) := To_StdLogicVector(PM_ASPML0S_TIMEOUT)(14 downto 0);
    constant PM_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_BASE_PTR)(7 downto 0);
    constant PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_CAP_ID)(7 downto 0);
    constant PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_CAP_NEXTPTR)(7 downto 0);
    constant PM_CAP_PMESUPPORT_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PM_CAP_PMESUPPORT)(4 downto 0);
    constant PM_DATA0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA0)(7 downto 0);
    constant PM_DATA1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA1)(7 downto 0);
    constant PM_DATA2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA2)(7 downto 0);
    constant PM_DATA3_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA3)(7 downto 0);
    constant PM_DATA4_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA4)(7 downto 0);
    constant PM_DATA5_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA5)(7 downto 0);
    constant PM_DATA6_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA6)(7 downto 0);
    constant PM_DATA7_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA7)(7 downto 0);
    constant PM_DATA_SCALE0_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE0)(1 downto 0);
    constant PM_DATA_SCALE1_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE1)(1 downto 0);
    constant PM_DATA_SCALE2_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE2)(1 downto 0);
    constant PM_DATA_SCALE3_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE3)(1 downto 0);
    constant PM_DATA_SCALE4_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE4)(1 downto 0);
    constant PM_DATA_SCALE5_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE5)(1 downto 0);
    constant PM_DATA_SCALE6_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE6)(1 downto 0);
    constant PM_DATA_SCALE7_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE7)(1 downto 0);
    constant RBAR_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(RBAR_BASE_PTR)(11 downto 0);
    constant RBAR_CAP_CONTROL_ENCODEDBAR0_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RBAR_CAP_CONTROL_ENCODEDBAR0)(4 downto 0);
    constant RBAR_CAP_CONTROL_ENCODEDBAR1_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RBAR_CAP_CONTROL_ENCODEDBAR1)(4 downto 0);
    constant RBAR_CAP_CONTROL_ENCODEDBAR2_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RBAR_CAP_CONTROL_ENCODEDBAR2)(4 downto 0);
    constant RBAR_CAP_CONTROL_ENCODEDBAR3_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RBAR_CAP_CONTROL_ENCODEDBAR3)(4 downto 0);
    constant RBAR_CAP_CONTROL_ENCODEDBAR4_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RBAR_CAP_CONTROL_ENCODEDBAR4)(4 downto 0);
    constant RBAR_CAP_CONTROL_ENCODEDBAR5_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RBAR_CAP_CONTROL_ENCODEDBAR5)(4 downto 0);
    constant RBAR_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RBAR_CAP_ID)(15 downto 0);
    constant RBAR_CAP_INDEX0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RBAR_CAP_INDEX0)(2 downto 0);
    constant RBAR_CAP_INDEX1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RBAR_CAP_INDEX1)(2 downto 0);
    constant RBAR_CAP_INDEX2_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RBAR_CAP_INDEX2)(2 downto 0);
    constant RBAR_CAP_INDEX3_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RBAR_CAP_INDEX3)(2 downto 0);
    constant RBAR_CAP_INDEX4_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RBAR_CAP_INDEX4)(2 downto 0);
    constant RBAR_CAP_INDEX5_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RBAR_CAP_INDEX5)(2 downto 0);
    constant RBAR_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(RBAR_CAP_NEXTPTR)(11 downto 0);
    constant RBAR_CAP_SUP0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(RBAR_CAP_SUP0)(31 downto 0);
    constant RBAR_CAP_SUP1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(RBAR_CAP_SUP1)(31 downto 0);
    constant RBAR_CAP_SUP2_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(RBAR_CAP_SUP2)(31 downto 0);
    constant RBAR_CAP_SUP3_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(RBAR_CAP_SUP3)(31 downto 0);
    constant RBAR_CAP_SUP4_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(RBAR_CAP_SUP4)(31 downto 0);
    constant RBAR_CAP_SUP5_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(RBAR_CAP_SUP5)(31 downto 0);
    constant RBAR_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RBAR_CAP_VERSION)(3 downto 0);
    constant RBAR_NUM_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RBAR_NUM)(2 downto 0);
    constant RP_AUTO_SPD_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(RP_AUTO_SPD)(1 downto 0);
    constant RP_AUTO_SPD_LOOPCNT_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RP_AUTO_SPD_LOOPCNT)(4 downto 0);
    constant SLOT_CAP_PHYSICAL_SLOT_NUM_BINARY : std_logic_vector(12 downto 0) := To_StdLogicVector(SLOT_CAP_PHYSICAL_SLOT_NUM)(12 downto 0);
    constant SLOT_CAP_SLOT_POWER_LIMIT_VALUE_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SLOT_CAP_SLOT_POWER_LIMIT_VALUE)(7 downto 0);
    constant SPARE_BYTE0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE0)(7 downto 0);
    constant SPARE_BYTE1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE1)(7 downto 0);
    constant SPARE_BYTE2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE2)(7 downto 0);
    constant SPARE_BYTE3_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE3)(7 downto 0);
    constant SPARE_WORD0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD0)(31 downto 0);
    constant SPARE_WORD1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD1)(31 downto 0);
    constant SPARE_WORD2_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD2)(31 downto 0);
    constant SPARE_WORD3_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD3)(31 downto 0);
    constant VC0_RX_RAM_LIMIT_BINARY : std_logic_vector(12 downto 0) := To_StdLogicVector(VC0_RX_RAM_LIMIT)(12 downto 0);
    constant VC_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VC_BASE_PTR)(11 downto 0);
    constant VC_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(VC_CAP_ID)(15 downto 0);
    constant VC_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VC_CAP_NEXTPTR)(11 downto 0);
    constant VC_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VC_CAP_VERSION)(3 downto 0);
    constant VSEC_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VSEC_BASE_PTR)(11 downto 0);
    constant VSEC_CAP_HDR_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(VSEC_CAP_HDR_ID)(15 downto 0);
    constant VSEC_CAP_HDR_LENGTH_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VSEC_CAP_HDR_LENGTH)(11 downto 0);
    constant VSEC_CAP_HDR_REVISION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VSEC_CAP_HDR_REVISION)(3 downto 0);
    constant VSEC_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(VSEC_CAP_ID)(15 downto 0);
    constant VSEC_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VSEC_CAP_NEXTPTR)(11 downto 0);
    constant VSEC_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VSEC_CAP_VERSION)(3 downto 0);
    
    -- Get String Length
    constant AER_BASE_PTR_STRLEN : integer := getstrlength(AER_BASE_PTR_BINARY);
    constant AER_CAP_ID_STRLEN : integer := getstrlength(AER_CAP_ID_BINARY);
    constant AER_CAP_NEXTPTR_STRLEN : integer := getstrlength(AER_CAP_NEXTPTR_BINARY);
    constant AER_CAP_OPTIONAL_ERR_SUPPORT_STRLEN : integer := getstrlength(AER_CAP_OPTIONAL_ERR_SUPPORT_BINARY);
    constant AER_CAP_VERSION_STRLEN : integer := getstrlength(AER_CAP_VERSION_BINARY);
    constant BAR0_STRLEN : integer := getstrlength(BAR0_BINARY);
    constant BAR1_STRLEN : integer := getstrlength(BAR1_BINARY);
    constant BAR2_STRLEN : integer := getstrlength(BAR2_BINARY);
    constant BAR3_STRLEN : integer := getstrlength(BAR3_BINARY);
    constant BAR4_STRLEN : integer := getstrlength(BAR4_BINARY);
    constant BAR5_STRLEN : integer := getstrlength(BAR5_BINARY);
    constant CAPABILITIES_PTR_STRLEN : integer := getstrlength(CAPABILITIES_PTR_BINARY);
    constant CARDBUS_CIS_POINTER_STRLEN : integer := getstrlength(CARDBUS_CIS_POINTER_BINARY);
    constant CLASS_CODE_STRLEN : integer := getstrlength(CLASS_CODE_BINARY);
    constant CPL_TIMEOUT_RANGES_SUPPORTED_STRLEN : integer := getstrlength(CPL_TIMEOUT_RANGES_SUPPORTED_BINARY);
    constant CRM_MODULE_RSTS_STRLEN : integer := getstrlength(CRM_MODULE_RSTS_BINARY);
    constant DEV_CAP2_MAX_ENDEND_TLP_PREFIXES_STRLEN : integer := getstrlength(DEV_CAP2_MAX_ENDEND_TLP_PREFIXES_BINARY);
    constant DEV_CAP2_TPH_COMPLETER_SUPPORTED_STRLEN : integer := getstrlength(DEV_CAP2_TPH_COMPLETER_SUPPORTED_BINARY);
    constant DNSTREAM_LINK_NUM_STRLEN : integer := getstrlength(DNSTREAM_LINK_NUM_BINARY);
    constant DSN_BASE_PTR_STRLEN : integer := getstrlength(DSN_BASE_PTR_BINARY);
    constant DSN_CAP_ID_STRLEN : integer := getstrlength(DSN_CAP_ID_BINARY);
    constant DSN_CAP_NEXTPTR_STRLEN : integer := getstrlength(DSN_CAP_NEXTPTR_BINARY);
    constant DSN_CAP_VERSION_STRLEN : integer := getstrlength(DSN_CAP_VERSION_BINARY);
    constant ENABLE_MSG_ROUTE_STRLEN : integer := getstrlength(ENABLE_MSG_ROUTE_BINARY);
    constant EXPANSION_ROM_STRLEN : integer := getstrlength(EXPANSION_ROM_BINARY);
    constant EXT_CFG_CAP_PTR_STRLEN : integer := getstrlength(EXT_CFG_CAP_PTR_BINARY);
    constant EXT_CFG_XP_CAP_PTR_STRLEN : integer := getstrlength(EXT_CFG_XP_CAP_PTR_BINARY);
    constant HEADER_TYPE_STRLEN : integer := getstrlength(HEADER_TYPE_BINARY);
    constant INFER_EI_STRLEN : integer := getstrlength(INFER_EI_BINARY);
    constant INTERRUPT_PIN_STRLEN : integer := getstrlength(INTERRUPT_PIN_BINARY);
    constant LAST_CONFIG_DWORD_STRLEN : integer := getstrlength(LAST_CONFIG_DWORD_BINARY);
    constant LINK_CAP_MAX_LINK_SPEED_STRLEN : integer := getstrlength(LINK_CAP_MAX_LINK_SPEED_BINARY);
    constant LINK_CAP_MAX_LINK_WIDTH_STRLEN : integer := getstrlength(LINK_CAP_MAX_LINK_WIDTH_BINARY);
    constant LINK_CTRL2_TARGET_LINK_SPEED_STRLEN : integer := getstrlength(LINK_CTRL2_TARGET_LINK_SPEED_BINARY);
    constant LL_ACK_TIMEOUT_STRLEN : integer := getstrlength(LL_ACK_TIMEOUT_BINARY);
    constant LL_REPLAY_TIMEOUT_STRLEN : integer := getstrlength(LL_REPLAY_TIMEOUT_BINARY);
    constant LTSSM_MAX_LINK_WIDTH_STRLEN : integer := getstrlength(LTSSM_MAX_LINK_WIDTH_BINARY);
    constant MSIX_BASE_PTR_STRLEN : integer := getstrlength(MSIX_BASE_PTR_BINARY);
    constant MSIX_CAP_ID_STRLEN : integer := getstrlength(MSIX_CAP_ID_BINARY);
    constant MSIX_CAP_NEXTPTR_STRLEN : integer := getstrlength(MSIX_CAP_NEXTPTR_BINARY);
    constant MSIX_CAP_PBA_OFFSET_STRLEN : integer := getstrlength(MSIX_CAP_PBA_OFFSET_BINARY);
    constant MSIX_CAP_TABLE_OFFSET_STRLEN : integer := getstrlength(MSIX_CAP_TABLE_OFFSET_BINARY);
    constant MSIX_CAP_TABLE_SIZE_STRLEN : integer := getstrlength(MSIX_CAP_TABLE_SIZE_BINARY);
    constant MSI_BASE_PTR_STRLEN : integer := getstrlength(MSI_BASE_PTR_BINARY);
    constant MSI_CAP_ID_STRLEN : integer := getstrlength(MSI_CAP_ID_BINARY);
    constant MSI_CAP_NEXTPTR_STRLEN : integer := getstrlength(MSI_CAP_NEXTPTR_BINARY);
    constant PCIE_BASE_PTR_STRLEN : integer := getstrlength(PCIE_BASE_PTR_BINARY);
    constant PCIE_CAP_CAPABILITY_ID_STRLEN : integer := getstrlength(PCIE_CAP_CAPABILITY_ID_BINARY);
    constant PCIE_CAP_CAPABILITY_VERSION_STRLEN : integer := getstrlength(PCIE_CAP_CAPABILITY_VERSION_BINARY);
    constant PCIE_CAP_DEVICE_PORT_TYPE_STRLEN : integer := getstrlength(PCIE_CAP_DEVICE_PORT_TYPE_BINARY);
    constant PCIE_CAP_NEXTPTR_STRLEN : integer := getstrlength(PCIE_CAP_NEXTPTR_BINARY);
    constant PM_ASPML0S_TIMEOUT_STRLEN : integer := getstrlength(PM_ASPML0S_TIMEOUT_BINARY);
    constant PM_BASE_PTR_STRLEN : integer := getstrlength(PM_BASE_PTR_BINARY);
    constant PM_CAP_ID_STRLEN : integer := getstrlength(PM_CAP_ID_BINARY);
    constant PM_CAP_NEXTPTR_STRLEN : integer := getstrlength(PM_CAP_NEXTPTR_BINARY);
    constant PM_CAP_PMESUPPORT_STRLEN : integer := getstrlength(PM_CAP_PMESUPPORT_BINARY);
    constant PM_DATA0_STRLEN : integer := getstrlength(PM_DATA0_BINARY);
    constant PM_DATA1_STRLEN : integer := getstrlength(PM_DATA1_BINARY);
    constant PM_DATA2_STRLEN : integer := getstrlength(PM_DATA2_BINARY);
    constant PM_DATA3_STRLEN : integer := getstrlength(PM_DATA3_BINARY);
    constant PM_DATA4_STRLEN : integer := getstrlength(PM_DATA4_BINARY);
    constant PM_DATA5_STRLEN : integer := getstrlength(PM_DATA5_BINARY);
    constant PM_DATA6_STRLEN : integer := getstrlength(PM_DATA6_BINARY);
    constant PM_DATA7_STRLEN : integer := getstrlength(PM_DATA7_BINARY);
    constant PM_DATA_SCALE0_STRLEN : integer := getstrlength(PM_DATA_SCALE0_BINARY);
    constant PM_DATA_SCALE1_STRLEN : integer := getstrlength(PM_DATA_SCALE1_BINARY);
    constant PM_DATA_SCALE2_STRLEN : integer := getstrlength(PM_DATA_SCALE2_BINARY);
    constant PM_DATA_SCALE3_STRLEN : integer := getstrlength(PM_DATA_SCALE3_BINARY);
    constant PM_DATA_SCALE4_STRLEN : integer := getstrlength(PM_DATA_SCALE4_BINARY);
    constant PM_DATA_SCALE5_STRLEN : integer := getstrlength(PM_DATA_SCALE5_BINARY);
    constant PM_DATA_SCALE6_STRLEN : integer := getstrlength(PM_DATA_SCALE6_BINARY);
    constant PM_DATA_SCALE7_STRLEN : integer := getstrlength(PM_DATA_SCALE7_BINARY);
    constant RBAR_BASE_PTR_STRLEN : integer := getstrlength(RBAR_BASE_PTR_BINARY);
    constant RBAR_CAP_CONTROL_ENCODEDBAR0_STRLEN : integer := getstrlength(RBAR_CAP_CONTROL_ENCODEDBAR0_BINARY);
    constant RBAR_CAP_CONTROL_ENCODEDBAR1_STRLEN : integer := getstrlength(RBAR_CAP_CONTROL_ENCODEDBAR1_BINARY);
    constant RBAR_CAP_CONTROL_ENCODEDBAR2_STRLEN : integer := getstrlength(RBAR_CAP_CONTROL_ENCODEDBAR2_BINARY);
    constant RBAR_CAP_CONTROL_ENCODEDBAR3_STRLEN : integer := getstrlength(RBAR_CAP_CONTROL_ENCODEDBAR3_BINARY);
    constant RBAR_CAP_CONTROL_ENCODEDBAR4_STRLEN : integer := getstrlength(RBAR_CAP_CONTROL_ENCODEDBAR4_BINARY);
    constant RBAR_CAP_CONTROL_ENCODEDBAR5_STRLEN : integer := getstrlength(RBAR_CAP_CONTROL_ENCODEDBAR5_BINARY);
    constant RBAR_CAP_ID_STRLEN : integer := getstrlength(RBAR_CAP_ID_BINARY);
    constant RBAR_CAP_INDEX0_STRLEN : integer := getstrlength(RBAR_CAP_INDEX0_BINARY);
    constant RBAR_CAP_INDEX1_STRLEN : integer := getstrlength(RBAR_CAP_INDEX1_BINARY);
    constant RBAR_CAP_INDEX2_STRLEN : integer := getstrlength(RBAR_CAP_INDEX2_BINARY);
    constant RBAR_CAP_INDEX3_STRLEN : integer := getstrlength(RBAR_CAP_INDEX3_BINARY);
    constant RBAR_CAP_INDEX4_STRLEN : integer := getstrlength(RBAR_CAP_INDEX4_BINARY);
    constant RBAR_CAP_INDEX5_STRLEN : integer := getstrlength(RBAR_CAP_INDEX5_BINARY);
    constant RBAR_CAP_NEXTPTR_STRLEN : integer := getstrlength(RBAR_CAP_NEXTPTR_BINARY);
    constant RBAR_CAP_SUP0_STRLEN : integer := getstrlength(RBAR_CAP_SUP0_BINARY);
    constant RBAR_CAP_SUP1_STRLEN : integer := getstrlength(RBAR_CAP_SUP1_BINARY);
    constant RBAR_CAP_SUP2_STRLEN : integer := getstrlength(RBAR_CAP_SUP2_BINARY);
    constant RBAR_CAP_SUP3_STRLEN : integer := getstrlength(RBAR_CAP_SUP3_BINARY);
    constant RBAR_CAP_SUP4_STRLEN : integer := getstrlength(RBAR_CAP_SUP4_BINARY);
    constant RBAR_CAP_SUP5_STRLEN : integer := getstrlength(RBAR_CAP_SUP5_BINARY);
    constant RBAR_CAP_VERSION_STRLEN : integer := getstrlength(RBAR_CAP_VERSION_BINARY);
    constant RBAR_NUM_STRLEN : integer := getstrlength(RBAR_NUM_BINARY);
    constant RP_AUTO_SPD_LOOPCNT_STRLEN : integer := getstrlength(RP_AUTO_SPD_LOOPCNT_BINARY);
    constant RP_AUTO_SPD_STRLEN : integer := getstrlength(RP_AUTO_SPD_BINARY);
    constant SLOT_CAP_PHYSICAL_SLOT_NUM_STRLEN : integer := getstrlength(SLOT_CAP_PHYSICAL_SLOT_NUM_BINARY);
    constant SLOT_CAP_SLOT_POWER_LIMIT_VALUE_STRLEN : integer := getstrlength(SLOT_CAP_SLOT_POWER_LIMIT_VALUE_BINARY);
    constant SPARE_BYTE0_STRLEN : integer := getstrlength(SPARE_BYTE0_BINARY);
    constant SPARE_BYTE1_STRLEN : integer := getstrlength(SPARE_BYTE1_BINARY);
    constant SPARE_BYTE2_STRLEN : integer := getstrlength(SPARE_BYTE2_BINARY);
    constant SPARE_BYTE3_STRLEN : integer := getstrlength(SPARE_BYTE3_BINARY);
    constant SPARE_WORD0_STRLEN : integer := getstrlength(SPARE_WORD0_BINARY);
    constant SPARE_WORD1_STRLEN : integer := getstrlength(SPARE_WORD1_BINARY);
    constant SPARE_WORD2_STRLEN : integer := getstrlength(SPARE_WORD2_BINARY);
    constant SPARE_WORD3_STRLEN : integer := getstrlength(SPARE_WORD3_BINARY);
    constant VC0_RX_RAM_LIMIT_STRLEN : integer := getstrlength(VC0_RX_RAM_LIMIT_BINARY);
    constant VC_BASE_PTR_STRLEN : integer := getstrlength(VC_BASE_PTR_BINARY);
    constant VC_CAP_ID_STRLEN : integer := getstrlength(VC_CAP_ID_BINARY);
    constant VC_CAP_NEXTPTR_STRLEN : integer := getstrlength(VC_CAP_NEXTPTR_BINARY);
    constant VC_CAP_VERSION_STRLEN : integer := getstrlength(VC_CAP_VERSION_BINARY);
    constant VSEC_BASE_PTR_STRLEN : integer := getstrlength(VSEC_BASE_PTR_BINARY);
    constant VSEC_CAP_HDR_ID_STRLEN : integer := getstrlength(VSEC_CAP_HDR_ID_BINARY);
    constant VSEC_CAP_HDR_LENGTH_STRLEN : integer := getstrlength(VSEC_CAP_HDR_LENGTH_BINARY);
    constant VSEC_CAP_HDR_REVISION_STRLEN : integer := getstrlength(VSEC_CAP_HDR_REVISION_BINARY);
    constant VSEC_CAP_ID_STRLEN : integer := getstrlength(VSEC_CAP_ID_BINARY);
    constant VSEC_CAP_NEXTPTR_STRLEN : integer := getstrlength(VSEC_CAP_NEXTPTR_BINARY);
    constant VSEC_CAP_VERSION_STRLEN : integer := getstrlength(VSEC_CAP_VERSION_BINARY);
    
    -- Convert std_logic_vector to string
    constant AER_BASE_PTR_STRING : string := SLV_TO_HEX(AER_BASE_PTR_BINARY, AER_BASE_PTR_STRLEN);
    constant AER_CAP_ID_STRING : string := SLV_TO_HEX(AER_CAP_ID_BINARY, AER_CAP_ID_STRLEN);
    constant AER_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(AER_CAP_NEXTPTR_BINARY, AER_CAP_NEXTPTR_STRLEN);
    constant AER_CAP_OPTIONAL_ERR_SUPPORT_STRING : string := SLV_TO_HEX(AER_CAP_OPTIONAL_ERR_SUPPORT_BINARY, AER_CAP_OPTIONAL_ERR_SUPPORT_STRLEN);
    constant AER_CAP_VERSION_STRING : string := SLV_TO_HEX(AER_CAP_VERSION_BINARY, AER_CAP_VERSION_STRLEN);
    constant BAR0_STRING : string := SLV_TO_HEX(BAR0_BINARY, BAR0_STRLEN);
    constant BAR1_STRING : string := SLV_TO_HEX(BAR1_BINARY, BAR1_STRLEN);
    constant BAR2_STRING : string := SLV_TO_HEX(BAR2_BINARY, BAR2_STRLEN);
    constant BAR3_STRING : string := SLV_TO_HEX(BAR3_BINARY, BAR3_STRLEN);
    constant BAR4_STRING : string := SLV_TO_HEX(BAR4_BINARY, BAR4_STRLEN);
    constant BAR5_STRING : string := SLV_TO_HEX(BAR5_BINARY, BAR5_STRLEN);
    constant CAPABILITIES_PTR_STRING : string := SLV_TO_HEX(CAPABILITIES_PTR_BINARY, CAPABILITIES_PTR_STRLEN);
    constant CARDBUS_CIS_POINTER_STRING : string := SLV_TO_HEX(CARDBUS_CIS_POINTER_BINARY, CARDBUS_CIS_POINTER_STRLEN);
    constant CLASS_CODE_STRING : string := SLV_TO_HEX(CLASS_CODE_BINARY, CLASS_CODE_STRLEN);
    constant CPL_TIMEOUT_RANGES_SUPPORTED_STRING : string := SLV_TO_HEX(CPL_TIMEOUT_RANGES_SUPPORTED_BINARY, CPL_TIMEOUT_RANGES_SUPPORTED_STRLEN);
    constant CRM_MODULE_RSTS_STRING : string := SLV_TO_HEX(CRM_MODULE_RSTS_BINARY, CRM_MODULE_RSTS_STRLEN);
    constant DEV_CAP2_MAX_ENDEND_TLP_PREFIXES_STRING : string := SLV_TO_HEX(DEV_CAP2_MAX_ENDEND_TLP_PREFIXES_BINARY, DEV_CAP2_MAX_ENDEND_TLP_PREFIXES_STRLEN);
    constant DEV_CAP2_TPH_COMPLETER_SUPPORTED_STRING : string := SLV_TO_HEX(DEV_CAP2_TPH_COMPLETER_SUPPORTED_BINARY, DEV_CAP2_TPH_COMPLETER_SUPPORTED_STRLEN);
    constant DNSTREAM_LINK_NUM_STRING : string := SLV_TO_HEX(DNSTREAM_LINK_NUM_BINARY, DNSTREAM_LINK_NUM_STRLEN);
    constant DSN_BASE_PTR_STRING : string := SLV_TO_HEX(DSN_BASE_PTR_BINARY, DSN_BASE_PTR_STRLEN);
    constant DSN_CAP_ID_STRING : string := SLV_TO_HEX(DSN_CAP_ID_BINARY, DSN_CAP_ID_STRLEN);
    constant DSN_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(DSN_CAP_NEXTPTR_BINARY, DSN_CAP_NEXTPTR_STRLEN);
    constant DSN_CAP_VERSION_STRING : string := SLV_TO_HEX(DSN_CAP_VERSION_BINARY, DSN_CAP_VERSION_STRLEN);
    constant ENABLE_MSG_ROUTE_STRING : string := SLV_TO_HEX(ENABLE_MSG_ROUTE_BINARY, ENABLE_MSG_ROUTE_STRLEN);
    constant EXPANSION_ROM_STRING : string := SLV_TO_HEX(EXPANSION_ROM_BINARY, EXPANSION_ROM_STRLEN);
    constant EXT_CFG_CAP_PTR_STRING : string := SLV_TO_HEX(EXT_CFG_CAP_PTR_BINARY, EXT_CFG_CAP_PTR_STRLEN);
    constant EXT_CFG_XP_CAP_PTR_STRING : string := SLV_TO_HEX(EXT_CFG_XP_CAP_PTR_BINARY, EXT_CFG_XP_CAP_PTR_STRLEN);
    constant HEADER_TYPE_STRING : string := SLV_TO_HEX(HEADER_TYPE_BINARY, HEADER_TYPE_STRLEN);
    constant INFER_EI_STRING : string := SLV_TO_HEX(INFER_EI_BINARY, INFER_EI_STRLEN);
    constant INTERRUPT_PIN_STRING : string := SLV_TO_HEX(INTERRUPT_PIN_BINARY, INTERRUPT_PIN_STRLEN);
    constant LAST_CONFIG_DWORD_STRING : string := SLV_TO_HEX(LAST_CONFIG_DWORD_BINARY, LAST_CONFIG_DWORD_STRLEN);
    constant LINK_CAP_MAX_LINK_SPEED_STRING : string := SLV_TO_HEX(LINK_CAP_MAX_LINK_SPEED_BINARY, LINK_CAP_MAX_LINK_SPEED_STRLEN);
    constant LINK_CAP_MAX_LINK_WIDTH_STRING : string := SLV_TO_HEX(LINK_CAP_MAX_LINK_WIDTH_BINARY, LINK_CAP_MAX_LINK_WIDTH_STRLEN);
    constant LINK_CTRL2_TARGET_LINK_SPEED_STRING : string := SLV_TO_HEX(LINK_CTRL2_TARGET_LINK_SPEED_BINARY, LINK_CTRL2_TARGET_LINK_SPEED_STRLEN);
    constant LL_ACK_TIMEOUT_STRING : string := SLV_TO_HEX(LL_ACK_TIMEOUT_BINARY, LL_ACK_TIMEOUT_STRLEN);
    constant LL_REPLAY_TIMEOUT_STRING : string := SLV_TO_HEX(LL_REPLAY_TIMEOUT_BINARY, LL_REPLAY_TIMEOUT_STRLEN);
    constant LTSSM_MAX_LINK_WIDTH_STRING : string := SLV_TO_HEX(LTSSM_MAX_LINK_WIDTH_BINARY, LTSSM_MAX_LINK_WIDTH_STRLEN);
    constant MSIX_BASE_PTR_STRING : string := SLV_TO_HEX(MSIX_BASE_PTR_BINARY, MSIX_BASE_PTR_STRLEN);
    constant MSIX_CAP_ID_STRING : string := SLV_TO_HEX(MSIX_CAP_ID_BINARY, MSIX_CAP_ID_STRLEN);
    constant MSIX_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(MSIX_CAP_NEXTPTR_BINARY, MSIX_CAP_NEXTPTR_STRLEN);
    constant MSIX_CAP_PBA_OFFSET_STRING : string := SLV_TO_HEX(MSIX_CAP_PBA_OFFSET_BINARY, MSIX_CAP_PBA_OFFSET_STRLEN);
    constant MSIX_CAP_TABLE_OFFSET_STRING : string := SLV_TO_HEX(MSIX_CAP_TABLE_OFFSET_BINARY, MSIX_CAP_TABLE_OFFSET_STRLEN);
    constant MSIX_CAP_TABLE_SIZE_STRING : string := SLV_TO_HEX(MSIX_CAP_TABLE_SIZE_BINARY, MSIX_CAP_TABLE_SIZE_STRLEN);
    constant MSI_BASE_PTR_STRING : string := SLV_TO_HEX(MSI_BASE_PTR_BINARY, MSI_BASE_PTR_STRLEN);
    constant MSI_CAP_ID_STRING : string := SLV_TO_HEX(MSI_CAP_ID_BINARY, MSI_CAP_ID_STRLEN);
    constant MSI_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(MSI_CAP_NEXTPTR_BINARY, MSI_CAP_NEXTPTR_STRLEN);
    constant PCIE_BASE_PTR_STRING : string := SLV_TO_HEX(PCIE_BASE_PTR_BINARY, PCIE_BASE_PTR_STRLEN);
    constant PCIE_CAP_CAPABILITY_ID_STRING : string := SLV_TO_HEX(PCIE_CAP_CAPABILITY_ID_BINARY, PCIE_CAP_CAPABILITY_ID_STRLEN);
    constant PCIE_CAP_CAPABILITY_VERSION_STRING : string := SLV_TO_HEX(PCIE_CAP_CAPABILITY_VERSION_BINARY, PCIE_CAP_CAPABILITY_VERSION_STRLEN);
    constant PCIE_CAP_DEVICE_PORT_TYPE_STRING : string := SLV_TO_HEX(PCIE_CAP_DEVICE_PORT_TYPE_BINARY, PCIE_CAP_DEVICE_PORT_TYPE_STRLEN);
    constant PCIE_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PCIE_CAP_NEXTPTR_BINARY, PCIE_CAP_NEXTPTR_STRLEN);
    constant PM_ASPML0S_TIMEOUT_STRING : string := SLV_TO_HEX(PM_ASPML0S_TIMEOUT_BINARY, PM_ASPML0S_TIMEOUT_STRLEN);
    constant PM_BASE_PTR_STRING : string := SLV_TO_HEX(PM_BASE_PTR_BINARY, PM_BASE_PTR_STRLEN);
    constant PM_CAP_ID_STRING : string := SLV_TO_HEX(PM_CAP_ID_BINARY, PM_CAP_ID_STRLEN);
    constant PM_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PM_CAP_NEXTPTR_BINARY, PM_CAP_NEXTPTR_STRLEN);
    constant PM_CAP_PMESUPPORT_STRING : string := SLV_TO_HEX(PM_CAP_PMESUPPORT_BINARY, PM_CAP_PMESUPPORT_STRLEN);
    constant PM_DATA0_STRING : string := SLV_TO_HEX(PM_DATA0_BINARY, PM_DATA0_STRLEN);
    constant PM_DATA1_STRING : string := SLV_TO_HEX(PM_DATA1_BINARY, PM_DATA1_STRLEN);
    constant PM_DATA2_STRING : string := SLV_TO_HEX(PM_DATA2_BINARY, PM_DATA2_STRLEN);
    constant PM_DATA3_STRING : string := SLV_TO_HEX(PM_DATA3_BINARY, PM_DATA3_STRLEN);
    constant PM_DATA4_STRING : string := SLV_TO_HEX(PM_DATA4_BINARY, PM_DATA4_STRLEN);
    constant PM_DATA5_STRING : string := SLV_TO_HEX(PM_DATA5_BINARY, PM_DATA5_STRLEN);
    constant PM_DATA6_STRING : string := SLV_TO_HEX(PM_DATA6_BINARY, PM_DATA6_STRLEN);
    constant PM_DATA7_STRING : string := SLV_TO_HEX(PM_DATA7_BINARY, PM_DATA7_STRLEN);
    constant PM_DATA_SCALE0_STRING : string := SLV_TO_HEX(PM_DATA_SCALE0_BINARY, PM_DATA_SCALE0_STRLEN);
    constant PM_DATA_SCALE1_STRING : string := SLV_TO_HEX(PM_DATA_SCALE1_BINARY, PM_DATA_SCALE1_STRLEN);
    constant PM_DATA_SCALE2_STRING : string := SLV_TO_HEX(PM_DATA_SCALE2_BINARY, PM_DATA_SCALE2_STRLEN);
    constant PM_DATA_SCALE3_STRING : string := SLV_TO_HEX(PM_DATA_SCALE3_BINARY, PM_DATA_SCALE3_STRLEN);
    constant PM_DATA_SCALE4_STRING : string := SLV_TO_HEX(PM_DATA_SCALE4_BINARY, PM_DATA_SCALE4_STRLEN);
    constant PM_DATA_SCALE5_STRING : string := SLV_TO_HEX(PM_DATA_SCALE5_BINARY, PM_DATA_SCALE5_STRLEN);
    constant PM_DATA_SCALE6_STRING : string := SLV_TO_HEX(PM_DATA_SCALE6_BINARY, PM_DATA_SCALE6_STRLEN);
    constant PM_DATA_SCALE7_STRING : string := SLV_TO_HEX(PM_DATA_SCALE7_BINARY, PM_DATA_SCALE7_STRLEN);
    constant RBAR_BASE_PTR_STRING : string := SLV_TO_HEX(RBAR_BASE_PTR_BINARY, RBAR_BASE_PTR_STRLEN);
    constant RBAR_CAP_CONTROL_ENCODEDBAR0_STRING : string := SLV_TO_HEX(RBAR_CAP_CONTROL_ENCODEDBAR0_BINARY, RBAR_CAP_CONTROL_ENCODEDBAR0_STRLEN);
    constant RBAR_CAP_CONTROL_ENCODEDBAR1_STRING : string := SLV_TO_HEX(RBAR_CAP_CONTROL_ENCODEDBAR1_BINARY, RBAR_CAP_CONTROL_ENCODEDBAR1_STRLEN);
    constant RBAR_CAP_CONTROL_ENCODEDBAR2_STRING : string := SLV_TO_HEX(RBAR_CAP_CONTROL_ENCODEDBAR2_BINARY, RBAR_CAP_CONTROL_ENCODEDBAR2_STRLEN);
    constant RBAR_CAP_CONTROL_ENCODEDBAR3_STRING : string := SLV_TO_HEX(RBAR_CAP_CONTROL_ENCODEDBAR3_BINARY, RBAR_CAP_CONTROL_ENCODEDBAR3_STRLEN);
    constant RBAR_CAP_CONTROL_ENCODEDBAR4_STRING : string := SLV_TO_HEX(RBAR_CAP_CONTROL_ENCODEDBAR4_BINARY, RBAR_CAP_CONTROL_ENCODEDBAR4_STRLEN);
    constant RBAR_CAP_CONTROL_ENCODEDBAR5_STRING : string := SLV_TO_HEX(RBAR_CAP_CONTROL_ENCODEDBAR5_BINARY, RBAR_CAP_CONTROL_ENCODEDBAR5_STRLEN);
    constant RBAR_CAP_ID_STRING : string := SLV_TO_HEX(RBAR_CAP_ID_BINARY, RBAR_CAP_ID_STRLEN);
    constant RBAR_CAP_INDEX0_STRING : string := SLV_TO_HEX(RBAR_CAP_INDEX0_BINARY, RBAR_CAP_INDEX0_STRLEN);
    constant RBAR_CAP_INDEX1_STRING : string := SLV_TO_HEX(RBAR_CAP_INDEX1_BINARY, RBAR_CAP_INDEX1_STRLEN);
    constant RBAR_CAP_INDEX2_STRING : string := SLV_TO_HEX(RBAR_CAP_INDEX2_BINARY, RBAR_CAP_INDEX2_STRLEN);
    constant RBAR_CAP_INDEX3_STRING : string := SLV_TO_HEX(RBAR_CAP_INDEX3_BINARY, RBAR_CAP_INDEX3_STRLEN);
    constant RBAR_CAP_INDEX4_STRING : string := SLV_TO_HEX(RBAR_CAP_INDEX4_BINARY, RBAR_CAP_INDEX4_STRLEN);
    constant RBAR_CAP_INDEX5_STRING : string := SLV_TO_HEX(RBAR_CAP_INDEX5_BINARY, RBAR_CAP_INDEX5_STRLEN);
    constant RBAR_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(RBAR_CAP_NEXTPTR_BINARY, RBAR_CAP_NEXTPTR_STRLEN);
    constant RBAR_CAP_SUP0_STRING : string := SLV_TO_HEX(RBAR_CAP_SUP0_BINARY, RBAR_CAP_SUP0_STRLEN);
    constant RBAR_CAP_SUP1_STRING : string := SLV_TO_HEX(RBAR_CAP_SUP1_BINARY, RBAR_CAP_SUP1_STRLEN);
    constant RBAR_CAP_SUP2_STRING : string := SLV_TO_HEX(RBAR_CAP_SUP2_BINARY, RBAR_CAP_SUP2_STRLEN);
    constant RBAR_CAP_SUP3_STRING : string := SLV_TO_HEX(RBAR_CAP_SUP3_BINARY, RBAR_CAP_SUP3_STRLEN);
    constant RBAR_CAP_SUP4_STRING : string := SLV_TO_HEX(RBAR_CAP_SUP4_BINARY, RBAR_CAP_SUP4_STRLEN);
    constant RBAR_CAP_SUP5_STRING : string := SLV_TO_HEX(RBAR_CAP_SUP5_BINARY, RBAR_CAP_SUP5_STRLEN);
    constant RBAR_CAP_VERSION_STRING : string := SLV_TO_HEX(RBAR_CAP_VERSION_BINARY, RBAR_CAP_VERSION_STRLEN);
    constant RBAR_NUM_STRING : string := SLV_TO_HEX(RBAR_NUM_BINARY, RBAR_NUM_STRLEN);
    constant RP_AUTO_SPD_LOOPCNT_STRING : string := SLV_TO_HEX(RP_AUTO_SPD_LOOPCNT_BINARY, RP_AUTO_SPD_LOOPCNT_STRLEN);
    constant RP_AUTO_SPD_STRING : string := SLV_TO_HEX(RP_AUTO_SPD_BINARY, RP_AUTO_SPD_STRLEN);
    constant SLOT_CAP_PHYSICAL_SLOT_NUM_STRING : string := SLV_TO_HEX(SLOT_CAP_PHYSICAL_SLOT_NUM_BINARY, SLOT_CAP_PHYSICAL_SLOT_NUM_STRLEN);
    constant SLOT_CAP_SLOT_POWER_LIMIT_VALUE_STRING : string := SLV_TO_HEX(SLOT_CAP_SLOT_POWER_LIMIT_VALUE_BINARY, SLOT_CAP_SLOT_POWER_LIMIT_VALUE_STRLEN);
    constant SPARE_BYTE0_STRING : string := SLV_TO_HEX(SPARE_BYTE0_BINARY, SPARE_BYTE0_STRLEN);
    constant SPARE_BYTE1_STRING : string := SLV_TO_HEX(SPARE_BYTE1_BINARY, SPARE_BYTE1_STRLEN);
    constant SPARE_BYTE2_STRING : string := SLV_TO_HEX(SPARE_BYTE2_BINARY, SPARE_BYTE2_STRLEN);
    constant SPARE_BYTE3_STRING : string := SLV_TO_HEX(SPARE_BYTE3_BINARY, SPARE_BYTE3_STRLEN);
    constant SPARE_WORD0_STRING : string := SLV_TO_HEX(SPARE_WORD0_BINARY, SPARE_WORD0_STRLEN);
    constant SPARE_WORD1_STRING : string := SLV_TO_HEX(SPARE_WORD1_BINARY, SPARE_WORD1_STRLEN);
    constant SPARE_WORD2_STRING : string := SLV_TO_HEX(SPARE_WORD2_BINARY, SPARE_WORD2_STRLEN);
    constant SPARE_WORD3_STRING : string := SLV_TO_HEX(SPARE_WORD3_BINARY, SPARE_WORD3_STRLEN);
    constant VC0_RX_RAM_LIMIT_STRING : string := SLV_TO_HEX(VC0_RX_RAM_LIMIT_BINARY, VC0_RX_RAM_LIMIT_STRLEN);
    constant VC_BASE_PTR_STRING : string := SLV_TO_HEX(VC_BASE_PTR_BINARY, VC_BASE_PTR_STRLEN);
    constant VC_CAP_ID_STRING : string := SLV_TO_HEX(VC_CAP_ID_BINARY, VC_CAP_ID_STRLEN);
    constant VC_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VC_CAP_NEXTPTR_BINARY, VC_CAP_NEXTPTR_STRLEN);
    constant VC_CAP_VERSION_STRING : string := SLV_TO_HEX(VC_CAP_VERSION_BINARY, VC_CAP_VERSION_STRLEN);
    constant VSEC_BASE_PTR_STRING : string := SLV_TO_HEX(VSEC_BASE_PTR_BINARY, VSEC_BASE_PTR_STRLEN);
    constant VSEC_CAP_HDR_ID_STRING : string := SLV_TO_HEX(VSEC_CAP_HDR_ID_BINARY, VSEC_CAP_HDR_ID_STRLEN);
    constant VSEC_CAP_HDR_LENGTH_STRING : string := SLV_TO_HEX(VSEC_CAP_HDR_LENGTH_BINARY, VSEC_CAP_HDR_LENGTH_STRLEN);
    constant VSEC_CAP_HDR_REVISION_STRING : string := SLV_TO_HEX(VSEC_CAP_HDR_REVISION_BINARY, VSEC_CAP_HDR_REVISION_STRLEN);
    constant VSEC_CAP_ID_STRING : string := SLV_TO_HEX(VSEC_CAP_ID_BINARY, VSEC_CAP_ID_STRLEN);
    constant VSEC_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VSEC_CAP_NEXTPTR_BINARY, VSEC_CAP_NEXTPTR_STRLEN);
    constant VSEC_CAP_VERSION_STRING : string := SLV_TO_HEX(VSEC_CAP_VERSION_BINARY, VSEC_CAP_VERSION_STRLEN);
     
    signal AER_CAP_ECRC_CHECK_CAPABLE_BINARY : std_ulogic;
    signal AER_CAP_ECRC_GEN_CAPABLE_BINARY : std_ulogic;
    signal AER_CAP_MULTIHEADER_BINARY : std_ulogic;
    signal AER_CAP_ON_BINARY : std_ulogic;
    signal AER_CAP_PERMIT_ROOTERR_UPDATE_BINARY : std_ulogic;
    signal ALLOW_X8_GEN2_BINARY : std_ulogic;
    signal CFG_ECRC_ERR_CPLSTAT_BINARY : std_logic_vector(1 downto 0);
    signal CMD_INTX_IMPLEMENTED_BINARY : std_ulogic;
    signal CPL_TIMEOUT_DISABLE_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_ARI_FORWARDING_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_CAS128_COMPLETER_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_LTR_MECHANISM_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING_BINARY : std_ulogic;
    signal DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE_BINARY : std_ulogic;
    signal DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE_BINARY : std_ulogic;
    signal DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CAP_ENDPOINT_L1_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CAP_EXT_TAG_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY : std_ulogic;
    signal DEV_CAP_MAX_PAYLOAD_SUPPORTED_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT_BINARY : std_logic_vector(1 downto 0);
    signal DEV_CAP_ROLE_BASED_ERROR_BINARY : std_ulogic;
    signal DEV_CAP_RSVD_14_12_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CAP_RSVD_17_16_BINARY : std_logic_vector(1 downto 0);
    signal DEV_CAP_RSVD_31_29_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CONTROL_AUX_POWER_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CONTROL_EXT_TAG_DEFAULT_BINARY : std_ulogic;
    signal DISABLE_ASPM_L1_TIMER_BINARY : std_ulogic;
    signal DISABLE_BAR_FILTERING_BINARY : std_ulogic;
    signal DISABLE_ERR_MSG_BINARY : std_ulogic;
    signal DISABLE_ID_CHECK_BINARY : std_ulogic;
    signal DISABLE_LANE_REVERSAL_BINARY : std_ulogic;
    signal DISABLE_LOCKED_FILTER_BINARY : std_ulogic;
    signal DISABLE_PPM_FILTER_BINARY : std_ulogic;
    signal DISABLE_RX_POISONED_RESP_BINARY : std_ulogic;
    signal DISABLE_RX_TC_FILTER_BINARY : std_ulogic;
    signal DISABLE_SCRAMBLING_BINARY : std_ulogic;
    signal DSN_CAP_ON_BINARY : std_ulogic;
    signal ENABLE_RX_TD_ECRC_TRIM_BINARY : std_ulogic;
    signal ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED_BINARY : std_ulogic;
    signal ENTER_RVRY_EI_L0_BINARY : std_ulogic;
    signal EXIT_LOOPBACK_ON_EI_BINARY : std_ulogic;
    signal INTERRUPT_STAT_AUTO_BINARY : std_ulogic;
    signal IS_SWITCH_BINARY : std_ulogic;
    signal LINK_CAP_ASPM_OPTIONALITY_BINARY : std_ulogic;
    signal LINK_CAP_ASPM_SUPPORT_BINARY : std_logic_vector(1 downto 0);
    signal LINK_CAP_CLOCK_POWER_MANAGEMENT_BINARY : std_ulogic;
    signal LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP_BINARY : std_ulogic;
    signal LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L0S_EXIT_LATENCY_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L0S_EXIT_LATENCY_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L1_EXIT_LATENCY_GEN1_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L1_EXIT_LATENCY_GEN2_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP_BINARY : std_ulogic;
    signal LINK_CAP_RSVD_23_BINARY : std_ulogic;
    signal LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_BINARY : std_ulogic;
    signal LINK_CONTROL_RCB_BINARY : std_ulogic;
    signal LINK_CTRL2_DEEMPHASIS_BINARY : std_ulogic;
    signal LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_BINARY : std_ulogic;
    signal LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY : std_ulogic;
    signal LL_ACK_TIMEOUT_EN_BINARY : std_ulogic;
    signal LL_ACK_TIMEOUT_FUNC_BINARY : std_logic_vector(1 downto 0);
    signal LL_REPLAY_TIMEOUT_EN_BINARY : std_ulogic;
    signal LL_REPLAY_TIMEOUT_FUNC_BINARY : std_logic_vector(1 downto 0);
    signal MPS_FORCE_BINARY : std_ulogic;
    signal MSIX_CAP_ON_BINARY : std_ulogic;
    signal MSIX_CAP_PBA_BIR_BINARY : std_logic_vector(2 downto 0);
    signal MSIX_CAP_TABLE_BIR_BINARY : std_logic_vector(2 downto 0);
    signal MSI_CAP_64_BIT_ADDR_CAPABLE_BINARY : std_ulogic;
    signal MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal MSI_CAP_MULTIMSG_EXTENSION_BINARY : std_ulogic;
    signal MSI_CAP_ON_BINARY : std_ulogic;
    signal MSI_CAP_PER_VECTOR_MASKING_CAPABLE_BINARY : std_ulogic;
    signal N_FTS_COMCLK_GEN1_BINARY : std_logic_vector(7 downto 0);
    signal N_FTS_COMCLK_GEN2_BINARY : std_logic_vector(7 downto 0);
    signal N_FTS_GEN1_BINARY : std_logic_vector(7 downto 0);
    signal N_FTS_GEN2_BINARY : std_logic_vector(7 downto 0);
    signal PCIE_CAP_ON_BINARY : std_ulogic;
    signal PCIE_CAP_RSVD_15_14_BINARY : std_logic_vector(1 downto 0);
    signal PCIE_CAP_SLOT_IMPLEMENTED_BINARY : std_ulogic;
    signal PCIE_REVISION_BINARY : std_logic_vector(3 downto 0);
    signal PL_AUTO_CONFIG_BINARY : std_logic_vector(2 downto 0);
    signal PL_FAST_TRAIN_BINARY : std_ulogic;
    signal PM_ASPML0S_TIMEOUT_EN_BINARY : std_ulogic;
    signal PM_ASPML0S_TIMEOUT_FUNC_BINARY : std_logic_vector(1 downto 0);
    signal PM_ASPM_FASTEXIT_BINARY : std_ulogic;
    signal PM_CAP_AUXCURRENT_BINARY : std_logic_vector(2 downto 0);
    signal PM_CAP_D1SUPPORT_BINARY : std_ulogic;
    signal PM_CAP_D2SUPPORT_BINARY : std_ulogic;
    signal PM_CAP_DSI_BINARY : std_ulogic;
    signal PM_CAP_ON_BINARY : std_ulogic;
    signal PM_CAP_PME_CLOCK_BINARY : std_ulogic;
    signal PM_CAP_RSVD_04_BINARY : std_ulogic;
    signal PM_CAP_VERSION_BINARY : std_logic_vector(2 downto 0);
    signal PM_CSR_B2B3_BINARY : std_ulogic;
    signal PM_CSR_BPCCEN_BINARY : std_ulogic;
    signal PM_CSR_NOSOFTRST_BINARY : std_ulogic;
    signal PM_MF_BINARY : std_ulogic;
    signal RBAR_CAP_ON_BINARY : std_ulogic;
    signal RECRC_CHK_BINARY : std_logic_vector(1 downto 0);
    signal RECRC_CHK_TRIM_BINARY : std_ulogic;
    signal ROOT_CAP_CRS_SW_VISIBILITY_BINARY : std_ulogic;
    signal SELECT_DLL_IF_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    signal SLOT_CAP_ATT_BUTTON_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_ELEC_INTERLOCK_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_HOTPLUG_CAPABLE_BINARY : std_ulogic;
    signal SLOT_CAP_HOTPLUG_SURPRISE_BINARY : std_ulogic;
    signal SLOT_CAP_MRL_SENSOR_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_NO_CMD_COMPLETED_SUPPORT_BINARY : std_ulogic;
    signal SLOT_CAP_POWER_CONTROLLER_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_SLOT_POWER_LIMIT_SCALE_BINARY : std_logic_vector(1 downto 0);
    signal SPARE_BIT0_BINARY : std_ulogic;
    signal SPARE_BIT1_BINARY : std_ulogic;
    signal SPARE_BIT2_BINARY : std_ulogic;
    signal SPARE_BIT3_BINARY : std_ulogic;
    signal SPARE_BIT4_BINARY : std_ulogic;
    signal SPARE_BIT5_BINARY : std_ulogic;
    signal SPARE_BIT6_BINARY : std_ulogic;
    signal SPARE_BIT7_BINARY : std_ulogic;
    signal SPARE_BIT8_BINARY : std_ulogic;
    signal SSL_MESSAGE_AUTO_BINARY : std_ulogic;
    signal TECRC_EP_INV_BINARY : std_ulogic;
    signal TL_RBYPASS_BINARY : std_ulogic;
    signal TL_RX_RAM_RADDR_LATENCY_BINARY : std_ulogic;
    signal TL_RX_RAM_RDATA_LATENCY_BINARY : std_logic_vector(1 downto 0);
    signal TL_RX_RAM_WRITE_LATENCY_BINARY : std_ulogic;
    signal TL_TFC_DISABLE_BINARY : std_ulogic;
    signal TL_TX_CHECKS_DISABLE_BINARY : std_ulogic;
    signal TL_TX_RAM_RADDR_LATENCY_BINARY : std_ulogic;
    signal TL_TX_RAM_RDATA_LATENCY_BINARY : std_logic_vector(1 downto 0);
    signal TL_TX_RAM_WRITE_LATENCY_BINARY : std_ulogic;
    signal TRN_DW_BINARY : std_ulogic;
    signal TRN_NP_FC_BINARY : std_ulogic;
    signal UPCONFIG_CAPABLE_BINARY : std_ulogic;
    signal UPSTREAM_FACING_BINARY : std_ulogic;
    signal UR_ATOMIC_BINARY : std_ulogic;
    signal UR_CFG1_BINARY : std_ulogic;
    signal UR_INV_REQ_BINARY : std_ulogic;
    signal UR_PRS_RESPONSE_BINARY : std_ulogic;
    signal USER_CLK2_DIV2_BINARY : std_ulogic;
    signal USER_CLK_FREQ_BINARY : std_logic_vector(2 downto 0);
    signal USE_RID_PINS_BINARY : std_ulogic;
    signal VC0_CPL_INFINITE_BINARY : std_ulogic;
    signal VC0_TOTAL_CREDITS_CD_BINARY : std_logic_vector(10 downto 0);
    signal VC0_TOTAL_CREDITS_CH_BINARY : std_logic_vector(6 downto 0);
    signal VC0_TOTAL_CREDITS_NPD_BINARY : std_logic_vector(10 downto 0);
    signal VC0_TOTAL_CREDITS_NPH_BINARY : std_logic_vector(6 downto 0);
    signal VC0_TOTAL_CREDITS_PD_BINARY : std_logic_vector(10 downto 0);
    signal VC0_TOTAL_CREDITS_PH_BINARY : std_logic_vector(6 downto 0);
    signal VC0_TX_LASTPACKET_BINARY : std_logic_vector(4 downto 0);
    signal VC_CAP_ON_BINARY : std_ulogic;
    signal VC_CAP_REJECT_SNOOP_TRANSACTIONS_BINARY : std_ulogic;
    signal VSEC_CAP_IS_LINK_VISIBLE_BINARY : std_ulogic;
    signal VSEC_CAP_ON_BINARY : std_ulogic;
    
    signal CFGAERECRCCHECKEN_out : std_ulogic;
    signal CFGAERECRCGENEN_out : std_ulogic;
    signal CFGAERROOTERRCORRERRRECEIVED_out : std_ulogic;
    signal CFGAERROOTERRCORRERRREPORTINGEN_out : std_ulogic;
    signal CFGAERROOTERRFATALERRRECEIVED_out : std_ulogic;
    signal CFGAERROOTERRFATALERRREPORTINGEN_out : std_ulogic;
    signal CFGAERROOTERRNONFATALERRRECEIVED_out : std_ulogic;
    signal CFGAERROOTERRNONFATALERRREPORTINGEN_out : std_ulogic;
    signal CFGBRIDGESERREN_out : std_ulogic;
    signal CFGCOMMANDBUSMASTERENABLE_out : std_ulogic;
    signal CFGCOMMANDINTERRUPTDISABLE_out : std_ulogic;
    signal CFGCOMMANDIOENABLE_out : std_ulogic;
    signal CFGCOMMANDMEMENABLE_out : std_ulogic;
    signal CFGCOMMANDSERREN_out : std_ulogic;
    signal CFGDEVCONTROL2ARIFORWARDEN_out : std_ulogic;
    signal CFGDEVCONTROL2ATOMICEGRESSBLOCK_out : std_ulogic;
    signal CFGDEVCONTROL2ATOMICREQUESTEREN_out : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTDIS_out : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTVAL_out : std_logic_vector(3 downto 0);
    signal CFGDEVCONTROL2IDOCPLEN_out : std_ulogic;
    signal CFGDEVCONTROL2IDOREQEN_out : std_ulogic;
    signal CFGDEVCONTROL2LTREN_out : std_ulogic;
    signal CFGDEVCONTROL2TLPPREFIXBLOCK_out : std_ulogic;
    signal CFGDEVCONTROLAUXPOWEREN_out : std_ulogic;
    signal CFGDEVCONTROLCORRERRREPORTINGEN_out : std_ulogic;
    signal CFGDEVCONTROLENABLERO_out : std_ulogic;
    signal CFGDEVCONTROLEXTTAGEN_out : std_ulogic;
    signal CFGDEVCONTROLFATALERRREPORTINGEN_out : std_ulogic;
    signal CFGDEVCONTROLMAXPAYLOAD_out : std_logic_vector(2 downto 0);
    signal CFGDEVCONTROLMAXREADREQ_out : std_logic_vector(2 downto 0);
    signal CFGDEVCONTROLNONFATALREPORTINGEN_out : std_ulogic;
    signal CFGDEVCONTROLNOSNOOPEN_out : std_ulogic;
    signal CFGDEVCONTROLPHANTOMEN_out : std_ulogic;
    signal CFGDEVCONTROLURERRREPORTINGEN_out : std_ulogic;
    signal CFGDEVSTATUSCORRERRDETECTED_out : std_ulogic;
    signal CFGDEVSTATUSFATALERRDETECTED_out : std_ulogic;
    signal CFGDEVSTATUSNONFATALERRDETECTED_out : std_ulogic;
    signal CFGDEVSTATUSURDETECTED_out : std_ulogic;
    signal CFGERRAERHEADERLOGSETN_out : std_ulogic;
    signal CFGERRCPLRDYN_out : std_ulogic;
    signal CFGINTERRUPTDO_out : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTMMENABLE_out : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIENABLE_out : std_ulogic;
    signal CFGINTERRUPTMSIXENABLE_out : std_ulogic;
    signal CFGINTERRUPTMSIXFM_out : std_ulogic;
    signal CFGINTERRUPTRDYN_out : std_ulogic;
    signal CFGLINKCONTROLASPMCONTROL_out : std_logic_vector(1 downto 0);
    signal CFGLINKCONTROLAUTOBANDWIDTHINTEN_out : std_ulogic;
    signal CFGLINKCONTROLBANDWIDTHINTEN_out : std_ulogic;
    signal CFGLINKCONTROLCLOCKPMEN_out : std_ulogic;
    signal CFGLINKCONTROLCOMMONCLOCK_out : std_ulogic;
    signal CFGLINKCONTROLEXTENDEDSYNC_out : std_ulogic;
    signal CFGLINKCONTROLHWAUTOWIDTHDIS_out : std_ulogic;
    signal CFGLINKCONTROLLINKDISABLE_out : std_ulogic;
    signal CFGLINKCONTROLRCB_out : std_ulogic;
    signal CFGLINKCONTROLRETRAINLINK_out : std_ulogic;
    signal CFGLINKSTATUSAUTOBANDWIDTHSTATUS_out : std_ulogic;
    signal CFGLINKSTATUSBANDWIDTHSTATUS_out : std_ulogic;
    signal CFGLINKSTATUSCURRENTSPEED_out : std_logic_vector(1 downto 0);
    signal CFGLINKSTATUSDLLACTIVE_out : std_ulogic;
    signal CFGLINKSTATUSLINKTRAINING_out : std_ulogic;
    signal CFGLINKSTATUSNEGOTIATEDWIDTH_out : std_logic_vector(3 downto 0);
    signal CFGMGMTDO_out : std_logic_vector(31 downto 0);
    signal CFGMGMTRDWRDONEN_out : std_ulogic;
    signal CFGMSGDATA_out : std_logic_vector(15 downto 0);
    signal CFGMSGRECEIVEDASSERTINTA_out : std_ulogic;
    signal CFGMSGRECEIVEDASSERTINTB_out : std_ulogic;
    signal CFGMSGRECEIVEDASSERTINTC_out : std_ulogic;
    signal CFGMSGRECEIVEDASSERTINTD_out : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTA_out : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTB_out : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTC_out : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTD_out : std_ulogic;
    signal CFGMSGRECEIVEDERRCOR_out : std_ulogic;
    signal CFGMSGRECEIVEDERRFATAL_out : std_ulogic;
    signal CFGMSGRECEIVEDERRNONFATAL_out : std_ulogic;
    signal CFGMSGRECEIVEDPMASNAK_out : std_ulogic;
    signal CFGMSGRECEIVEDPMETOACK_out : std_ulogic;
    signal CFGMSGRECEIVEDPMETO_out : std_ulogic;
    signal CFGMSGRECEIVEDPMPME_out : std_ulogic;
    signal CFGMSGRECEIVEDSETSLOTPOWERLIMIT_out : std_ulogic;
    signal CFGMSGRECEIVEDUNLOCK_out : std_ulogic;
    signal CFGMSGRECEIVED_out : std_ulogic;
    signal CFGPCIELINKSTATE_out : std_logic_vector(2 downto 0);
    signal CFGPMCSRPMEEN_out : std_ulogic;
    signal CFGPMCSRPMESTATUS_out : std_ulogic;
    signal CFGPMCSRPOWERSTATE_out : std_logic_vector(1 downto 0);
    signal CFGPMRCVASREQL1N_out : std_ulogic;
    signal CFGPMRCVENTERL1N_out : std_ulogic;
    signal CFGPMRCVENTERL23N_out : std_ulogic;
    signal CFGPMRCVREQACKN_out : std_ulogic;
    signal CFGROOTCONTROLPMEINTEN_out : std_ulogic;
    signal CFGROOTCONTROLSYSERRCORRERREN_out : std_ulogic;
    signal CFGROOTCONTROLSYSERRFATALERREN_out : std_ulogic;
    signal CFGROOTCONTROLSYSERRNONFATALERREN_out : std_ulogic;
    signal CFGSLOTCONTROLELECTROMECHILCTLPULSE_out : std_ulogic;
    signal CFGTRANSACTIONADDR_out : std_logic_vector(6 downto 0);
    signal CFGTRANSACTIONTYPE_out : std_ulogic;
    signal CFGTRANSACTION_out : std_ulogic;
    signal CFGVCTCVCMAP_out : std_logic_vector(6 downto 0);
    signal DBGSCLRA_out : std_ulogic;
    signal DBGSCLRB_out : std_ulogic;
    signal DBGSCLRC_out : std_ulogic;
    signal DBGSCLRD_out : std_ulogic;
    signal DBGSCLRE_out : std_ulogic;
    signal DBGSCLRF_out : std_ulogic;
    signal DBGSCLRG_out : std_ulogic;
    signal DBGSCLRH_out : std_ulogic;
    signal DBGSCLRI_out : std_ulogic;
    signal DBGSCLRJ_out : std_ulogic;
    signal DBGSCLRK_out : std_ulogic;
    signal DBGVECA_out : std_logic_vector(63 downto 0);
    signal DBGVECB_out : std_logic_vector(63 downto 0);
    signal DBGVECC_out : std_logic_vector(11 downto 0);
    signal DRPDO_out : std_logic_vector(15 downto 0);
    signal DRPRDY_out : std_ulogic;
    signal LL2BADDLLPERR_out : std_ulogic;
    signal LL2BADTLPERR_out : std_ulogic;
    signal LL2LINKSTATUS_out : std_logic_vector(4 downto 0);
    signal LL2PROTOCOLERR_out : std_ulogic;
    signal LL2RECEIVERERR_out : std_ulogic;
    signal LL2REPLAYROERR_out : std_ulogic;
    signal LL2REPLAYTOERR_out : std_ulogic;
    signal LL2SUSPENDOK_out : std_ulogic;
    signal LL2TFCINIT1SEQ_out : std_ulogic;
    signal LL2TFCINIT2SEQ_out : std_ulogic;
    signal LL2TXIDLE_out : std_ulogic;
    signal LNKCLKEN_out : std_ulogic;
    signal MIMRXRADDR_out : std_logic_vector(12 downto 0);
    signal MIMRXREN_out : std_ulogic;
    signal MIMRXWADDR_out : std_logic_vector(12 downto 0);
    signal MIMRXWDATA_out : std_logic_vector(67 downto 0);
    signal MIMRXWEN_out : std_ulogic;
    signal MIMTXRADDR_out : std_logic_vector(12 downto 0);
    signal MIMTXREN_out : std_ulogic;
    signal MIMTXWADDR_out : std_logic_vector(12 downto 0);
    signal MIMTXWDATA_out : std_logic_vector(68 downto 0);
    signal MIMTXWEN_out : std_ulogic;
    signal PIPERX0POLARITY_out : std_ulogic;
    signal PIPERX1POLARITY_out : std_ulogic;
    signal PIPERX2POLARITY_out : std_ulogic;
    signal PIPERX3POLARITY_out : std_ulogic;
    signal PIPERX4POLARITY_out : std_ulogic;
    signal PIPERX5POLARITY_out : std_ulogic;
    signal PIPERX6POLARITY_out : std_ulogic;
    signal PIPERX7POLARITY_out : std_ulogic;
    signal PIPETX0CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX0COMPLIANCE_out : std_ulogic;
    signal PIPETX0DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX0ELECIDLE_out : std_ulogic;
    signal PIPETX0POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX1CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX1COMPLIANCE_out : std_ulogic;
    signal PIPETX1DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX1ELECIDLE_out : std_ulogic;
    signal PIPETX1POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX2CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX2COMPLIANCE_out : std_ulogic;
    signal PIPETX2DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX2ELECIDLE_out : std_ulogic;
    signal PIPETX2POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX3CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX3COMPLIANCE_out : std_ulogic;
    signal PIPETX3DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX3ELECIDLE_out : std_ulogic;
    signal PIPETX3POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX4CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX4COMPLIANCE_out : std_ulogic;
    signal PIPETX4DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX4ELECIDLE_out : std_ulogic;
    signal PIPETX4POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX5CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX5COMPLIANCE_out : std_ulogic;
    signal PIPETX5DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX5ELECIDLE_out : std_ulogic;
    signal PIPETX5POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX6CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX6COMPLIANCE_out : std_ulogic;
    signal PIPETX6DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX6ELECIDLE_out : std_ulogic;
    signal PIPETX6POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETX7CHARISK_out : std_logic_vector(1 downto 0);
    signal PIPETX7COMPLIANCE_out : std_ulogic;
    signal PIPETX7DATA_out : std_logic_vector(15 downto 0);
    signal PIPETX7ELECIDLE_out : std_ulogic;
    signal PIPETX7POWERDOWN_out : std_logic_vector(1 downto 0);
    signal PIPETXDEEMPH_out : std_ulogic;
    signal PIPETXMARGIN_out : std_logic_vector(2 downto 0);
    signal PIPETXRATE_out : std_ulogic;
    signal PIPETXRCVRDET_out : std_ulogic;
    signal PIPETXRESET_out : std_ulogic;
    signal PL2L0REQ_out : std_ulogic;
    signal PL2LINKUP_out : std_ulogic;
    signal PL2RECEIVERERR_out : std_ulogic;
    signal PL2RECOVERY_out : std_ulogic;
    signal PL2RXELECIDLE_out : std_ulogic;
    signal PL2RXPMSTATE_out : std_logic_vector(1 downto 0);
    signal PL2SUSPENDOK_out : std_ulogic;
    signal PLDBGVEC_out : std_logic_vector(11 downto 0);
    signal PLDIRECTEDCHANGEDONE_out : std_ulogic;
    signal PLINITIALLINKWIDTH_out : std_logic_vector(2 downto 0);
    signal PLLANEREVERSALMODE_out : std_logic_vector(1 downto 0);
    signal PLLINKGEN2CAP_out : std_ulogic;
    signal PLLINKPARTNERGEN2SUPPORTED_out : std_ulogic;
    signal PLLINKUPCFGCAP_out : std_ulogic;
    signal PLLTSSMSTATE_out : std_logic_vector(5 downto 0);
    signal PLPHYLNKUPN_out : std_ulogic;
    signal PLRECEIVEDHOTRST_out : std_ulogic;
    signal PLRXPMSTATE_out : std_logic_vector(1 downto 0);
    signal PLSELLNKRATE_out : std_ulogic;
    signal PLSELLNKWIDTH_out : std_logic_vector(1 downto 0);
    signal PLTXPMSTATE_out : std_logic_vector(2 downto 0);
    signal RECEIVEDFUNCLVLRSTN_out : std_ulogic;
    signal TL2ASPMSUSPENDCREDITCHECKOK_out : std_ulogic;
    signal TL2ASPMSUSPENDREQ_out : std_ulogic;
    signal TL2ERRFCPE_out : std_ulogic;
    signal TL2ERRHDR_out : std_logic_vector(63 downto 0);
    signal TL2ERRMALFORMED_out : std_ulogic;
    signal TL2ERRRXOVERFLOW_out : std_ulogic;
    signal TL2PPMSUSPENDOK_out : std_ulogic;
    signal TRNFCCPLD_out : std_logic_vector(11 downto 0);
    signal TRNFCCPLH_out : std_logic_vector(7 downto 0);
    signal TRNFCNPD_out : std_logic_vector(11 downto 0);
    signal TRNFCNPH_out : std_logic_vector(7 downto 0);
    signal TRNFCPD_out : std_logic_vector(11 downto 0);
    signal TRNFCPH_out : std_logic_vector(7 downto 0);
    signal TRNLNKUP_out : std_ulogic;
    signal TRNRBARHIT_out : std_logic_vector(7 downto 0);
    signal TRNRDLLPDATA_out : std_logic_vector(63 downto 0);
    signal TRNRDLLPSRCRDY_out : std_logic_vector(1 downto 0);
    signal TRNRD_out : std_logic_vector(127 downto 0);
    signal TRNRECRCERR_out : std_ulogic;
    signal TRNREOF_out : std_ulogic;
    signal TRNRERRFWD_out : std_ulogic;
    signal TRNRREM_out : std_logic_vector(1 downto 0);
    signal TRNRSOF_out : std_ulogic;
    signal TRNRSRCDSC_out : std_ulogic;
    signal TRNRSRCRDY_out : std_ulogic;
    signal TRNTBUFAV_out : std_logic_vector(5 downto 0);
    signal TRNTCFGREQ_out : std_ulogic;
    signal TRNTDLLPDSTRDY_out : std_ulogic;
    signal TRNTDSTRDY_out : std_logic_vector(3 downto 0);
    signal TRNTERRDROP_out : std_ulogic;
    signal USERRSTN_out : std_ulogic;
    
    signal CFGAERECRCCHECKEN_outdelay : std_ulogic;
    signal CFGAERECRCGENEN_outdelay : std_ulogic;
    signal CFGAERROOTERRCORRERRRECEIVED_outdelay : std_ulogic;
    signal CFGAERROOTERRCORRERRREPORTINGEN_outdelay : std_ulogic;
    signal CFGAERROOTERRFATALERRRECEIVED_outdelay : std_ulogic;
    signal CFGAERROOTERRFATALERRREPORTINGEN_outdelay : std_ulogic;
    signal CFGAERROOTERRNONFATALERRRECEIVED_outdelay : std_ulogic;
    signal CFGAERROOTERRNONFATALERRREPORTINGEN_outdelay : std_ulogic;
    signal CFGBRIDGESERREN_outdelay : std_ulogic;
    signal CFGCOMMANDBUSMASTERENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDINTERRUPTDISABLE_outdelay : std_ulogic;
    signal CFGCOMMANDIOENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDMEMENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDSERREN_outdelay : std_ulogic;
    signal CFGDEVCONTROL2ARIFORWARDEN_outdelay : std_ulogic;
    signal CFGDEVCONTROL2ATOMICEGRESSBLOCK_outdelay : std_ulogic;
    signal CFGDEVCONTROL2ATOMICREQUESTEREN_outdelay : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTDIS_outdelay : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTVAL_outdelay : std_logic_vector(3 downto 0);
    signal CFGDEVCONTROL2IDOCPLEN_outdelay : std_ulogic;
    signal CFGDEVCONTROL2IDOREQEN_outdelay : std_ulogic;
    signal CFGDEVCONTROL2LTREN_outdelay : std_ulogic;
    signal CFGDEVCONTROL2TLPPREFIXBLOCK_outdelay : std_ulogic;
    signal CFGDEVCONTROLAUXPOWEREN_outdelay : std_ulogic;
    signal CFGDEVCONTROLCORRERRREPORTINGEN_outdelay : std_ulogic;
    signal CFGDEVCONTROLENABLERO_outdelay : std_ulogic;
    signal CFGDEVCONTROLEXTTAGEN_outdelay : std_ulogic;
    signal CFGDEVCONTROLFATALERRREPORTINGEN_outdelay : std_ulogic;
    signal CFGDEVCONTROLMAXPAYLOAD_outdelay : std_logic_vector(2 downto 0);
    signal CFGDEVCONTROLMAXREADREQ_outdelay : std_logic_vector(2 downto 0);
    signal CFGDEVCONTROLNONFATALREPORTINGEN_outdelay : std_ulogic;
    signal CFGDEVCONTROLNOSNOOPEN_outdelay : std_ulogic;
    signal CFGDEVCONTROLPHANTOMEN_outdelay : std_ulogic;
    signal CFGDEVCONTROLURERRREPORTINGEN_outdelay : std_ulogic;
    signal CFGDEVSTATUSCORRERRDETECTED_outdelay : std_ulogic;
    signal CFGDEVSTATUSFATALERRDETECTED_outdelay : std_ulogic;
    signal CFGDEVSTATUSNONFATALERRDETECTED_outdelay : std_ulogic;
    signal CFGDEVSTATUSURDETECTED_outdelay : std_ulogic;
    signal CFGERRAERHEADERLOGSETN_outdelay : std_ulogic;
    signal CFGERRCPLRDYN_outdelay : std_ulogic;
    signal CFGINTERRUPTDO_outdelay : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTMMENABLE_outdelay : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIENABLE_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIXENABLE_outdelay : std_ulogic;
    signal CFGINTERRUPTMSIXFM_outdelay : std_ulogic;
    signal CFGINTERRUPTRDYN_outdelay : std_ulogic;
    signal CFGLINKCONTROLASPMCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal CFGLINKCONTROLAUTOBANDWIDTHINTEN_outdelay : std_ulogic;
    signal CFGLINKCONTROLBANDWIDTHINTEN_outdelay : std_ulogic;
    signal CFGLINKCONTROLCLOCKPMEN_outdelay : std_ulogic;
    signal CFGLINKCONTROLCOMMONCLOCK_outdelay : std_ulogic;
    signal CFGLINKCONTROLEXTENDEDSYNC_outdelay : std_ulogic;
    signal CFGLINKCONTROLHWAUTOWIDTHDIS_outdelay : std_ulogic;
    signal CFGLINKCONTROLLINKDISABLE_outdelay : std_ulogic;
    signal CFGLINKCONTROLRCB_outdelay : std_ulogic;
    signal CFGLINKCONTROLRETRAINLINK_outdelay : std_ulogic;
    signal CFGLINKSTATUSAUTOBANDWIDTHSTATUS_outdelay : std_ulogic;
    signal CFGLINKSTATUSBANDWIDTHSTATUS_outdelay : std_ulogic;
    signal CFGLINKSTATUSCURRENTSPEED_outdelay : std_logic_vector(1 downto 0);
    signal CFGLINKSTATUSDLLACTIVE_outdelay : std_ulogic;
    signal CFGLINKSTATUSLINKTRAINING_outdelay : std_ulogic;
    signal CFGLINKSTATUSNEGOTIATEDWIDTH_outdelay : std_logic_vector(3 downto 0);
    signal CFGMGMTDO_outdelay : std_logic_vector(31 downto 0);
    signal CFGMGMTRDWRDONEN_outdelay : std_ulogic;
    signal CFGMSGDATA_outdelay : std_logic_vector(15 downto 0);
    signal CFGMSGRECEIVEDASSERTINTA_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDASSERTINTB_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDASSERTINTC_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDASSERTINTD_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTA_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTB_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTC_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDDEASSERTINTD_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDERRCOR_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDERRFATAL_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDERRNONFATAL_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDPMASNAK_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDPMETOACK_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDPMETO_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDPMPME_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDSETSLOTPOWERLIMIT_outdelay : std_ulogic;
    signal CFGMSGRECEIVEDUNLOCK_outdelay : std_ulogic;
    signal CFGMSGRECEIVED_outdelay : std_ulogic;
    signal CFGPCIELINKSTATE_outdelay : std_logic_vector(2 downto 0);
    signal CFGPMCSRPMEEN_outdelay : std_ulogic;
    signal CFGPMCSRPMESTATUS_outdelay : std_ulogic;
    signal CFGPMCSRPOWERSTATE_outdelay : std_logic_vector(1 downto 0);
    signal CFGPMRCVASREQL1N_outdelay : std_ulogic;
    signal CFGPMRCVENTERL1N_outdelay : std_ulogic;
    signal CFGPMRCVENTERL23N_outdelay : std_ulogic;
    signal CFGPMRCVREQACKN_outdelay : std_ulogic;
    signal CFGROOTCONTROLPMEINTEN_outdelay : std_ulogic;
    signal CFGROOTCONTROLSYSERRCORRERREN_outdelay : std_ulogic;
    signal CFGROOTCONTROLSYSERRFATALERREN_outdelay : std_ulogic;
    signal CFGROOTCONTROLSYSERRNONFATALERREN_outdelay : std_ulogic;
    signal CFGSLOTCONTROLELECTROMECHILCTLPULSE_outdelay : std_ulogic;
    signal CFGTRANSACTIONADDR_outdelay : std_logic_vector(6 downto 0);
    signal CFGTRANSACTIONTYPE_outdelay : std_ulogic;
    signal CFGTRANSACTION_outdelay : std_ulogic;
    signal CFGVCTCVCMAP_outdelay : std_logic_vector(6 downto 0);
    signal DBGSCLRA_outdelay : std_ulogic;
    signal DBGSCLRB_outdelay : std_ulogic;
    signal DBGSCLRC_outdelay : std_ulogic;
    signal DBGSCLRD_outdelay : std_ulogic;
    signal DBGSCLRE_outdelay : std_ulogic;
    signal DBGSCLRF_outdelay : std_ulogic;
    signal DBGSCLRG_outdelay : std_ulogic;
    signal DBGSCLRH_outdelay : std_ulogic;
    signal DBGSCLRI_outdelay : std_ulogic;
    signal DBGSCLRJ_outdelay : std_ulogic;
    signal DBGSCLRK_outdelay : std_ulogic;
    signal DBGVECA_outdelay : std_logic_vector(63 downto 0);
    signal DBGVECB_outdelay : std_logic_vector(63 downto 0);
    signal DBGVECC_outdelay : std_logic_vector(11 downto 0);
    signal DRPDO_outdelay : std_logic_vector(15 downto 0);
    signal DRPRDY_outdelay : std_ulogic;
    signal LL2BADDLLPERR_outdelay : std_ulogic;
    signal LL2BADTLPERR_outdelay : std_ulogic;
    signal LL2LINKSTATUS_outdelay : std_logic_vector(4 downto 0);
    signal LL2PROTOCOLERR_outdelay : std_ulogic;
    signal LL2RECEIVERERR_outdelay : std_ulogic;
    signal LL2REPLAYROERR_outdelay : std_ulogic;
    signal LL2REPLAYTOERR_outdelay : std_ulogic;
    signal LL2SUSPENDOK_outdelay : std_ulogic;
    signal LL2TFCINIT1SEQ_outdelay : std_ulogic;
    signal LL2TFCINIT2SEQ_outdelay : std_ulogic;
    signal LL2TXIDLE_outdelay : std_ulogic;
    signal LNKCLKEN_outdelay : std_ulogic;
    signal MIMRXRADDR_outdelay : std_logic_vector(12 downto 0);
    signal MIMRXREN_outdelay : std_ulogic;
    signal MIMRXWADDR_outdelay : std_logic_vector(12 downto 0);
    signal MIMRXWDATA_outdelay : std_logic_vector(67 downto 0);
    signal MIMRXWEN_outdelay : std_ulogic;
    signal MIMTXRADDR_outdelay : std_logic_vector(12 downto 0);
    signal MIMTXREN_outdelay : std_ulogic;
    signal MIMTXWADDR_outdelay : std_logic_vector(12 downto 0);
    signal MIMTXWDATA_outdelay : std_logic_vector(68 downto 0);
    signal MIMTXWEN_outdelay : std_ulogic;
    signal PIPERX0POLARITY_outdelay : std_ulogic;
    signal PIPERX1POLARITY_outdelay : std_ulogic;
    signal PIPERX2POLARITY_outdelay : std_ulogic;
    signal PIPERX3POLARITY_outdelay : std_ulogic;
    signal PIPERX4POLARITY_outdelay : std_ulogic;
    signal PIPERX5POLARITY_outdelay : std_ulogic;
    signal PIPERX6POLARITY_outdelay : std_ulogic;
    signal PIPERX7POLARITY_outdelay : std_ulogic;
    signal PIPETX0CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX0COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX0DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX0ELECIDLE_outdelay : std_ulogic;
    signal PIPETX0POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX1CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX1COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX1DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX1ELECIDLE_outdelay : std_ulogic;
    signal PIPETX1POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX2CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX2COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX2DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX2ELECIDLE_outdelay : std_ulogic;
    signal PIPETX2POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX3CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX3COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX3DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX3ELECIDLE_outdelay : std_ulogic;
    signal PIPETX3POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX4CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX4COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX4DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX4ELECIDLE_outdelay : std_ulogic;
    signal PIPETX4POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX5CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX5COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX5DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX5ELECIDLE_outdelay : std_ulogic;
    signal PIPETX5POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX6CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX6COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX6DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX6ELECIDLE_outdelay : std_ulogic;
    signal PIPETX6POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX7CHARISK_outdelay : std_logic_vector(1 downto 0);
    signal PIPETX7COMPLIANCE_outdelay : std_ulogic;
    signal PIPETX7DATA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETX7ELECIDLE_outdelay : std_ulogic;
    signal PIPETX7POWERDOWN_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXDEEMPH_outdelay : std_ulogic;
    signal PIPETXMARGIN_outdelay : std_logic_vector(2 downto 0);
    signal PIPETXRATE_outdelay : std_ulogic;
    signal PIPETXRCVRDET_outdelay : std_ulogic;
    signal PIPETXRESET_outdelay : std_ulogic;
    signal PL2L0REQ_outdelay : std_ulogic;
    signal PL2LINKUP_outdelay : std_ulogic;
    signal PL2RECEIVERERR_outdelay : std_ulogic;
    signal PL2RECOVERY_outdelay : std_ulogic;
    signal PL2RXELECIDLE_outdelay : std_ulogic;
    signal PL2RXPMSTATE_outdelay : std_logic_vector(1 downto 0);
    signal PL2SUSPENDOK_outdelay : std_ulogic;
    signal PLDBGVEC_outdelay : std_logic_vector(11 downto 0);
    signal PLDIRECTEDCHANGEDONE_outdelay : std_ulogic;
    signal PLINITIALLINKWIDTH_outdelay : std_logic_vector(2 downto 0);
    signal PLLANEREVERSALMODE_outdelay : std_logic_vector(1 downto 0);
    signal PLLINKGEN2CAP_outdelay : std_ulogic;
    signal PLLINKPARTNERGEN2SUPPORTED_outdelay : std_ulogic;
    signal PLLINKUPCFGCAP_outdelay : std_ulogic;
    signal PLLTSSMSTATE_outdelay : std_logic_vector(5 downto 0);
    signal PLPHYLNKUPN_outdelay : std_ulogic;
    signal PLRECEIVEDHOTRST_outdelay : std_ulogic;
    signal PLRXPMSTATE_outdelay : std_logic_vector(1 downto 0);
    signal PLSELLNKRATE_outdelay : std_ulogic;
    signal PLSELLNKWIDTH_outdelay : std_logic_vector(1 downto 0);
    signal PLTXPMSTATE_outdelay : std_logic_vector(2 downto 0);
    signal RECEIVEDFUNCLVLRSTN_outdelay : std_ulogic;
    signal TL2ASPMSUSPENDCREDITCHECKOK_outdelay : std_ulogic;
    signal TL2ASPMSUSPENDREQ_outdelay : std_ulogic;
    signal TL2ERRFCPE_outdelay : std_ulogic;
    signal TL2ERRHDR_outdelay : std_logic_vector(63 downto 0);
    signal TL2ERRMALFORMED_outdelay : std_ulogic;
    signal TL2ERRRXOVERFLOW_outdelay : std_ulogic;
    signal TL2PPMSUSPENDOK_outdelay : std_ulogic;
    signal TRNFCCPLD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCCPLH_outdelay : std_logic_vector(7 downto 0);
    signal TRNFCNPD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCNPH_outdelay : std_logic_vector(7 downto 0);
    signal TRNFCPD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCPH_outdelay : std_logic_vector(7 downto 0);
    signal TRNLNKUP_outdelay : std_ulogic;
    signal TRNRBARHIT_outdelay : std_logic_vector(7 downto 0);
    signal TRNRDLLPDATA_outdelay : std_logic_vector(63 downto 0);
    signal TRNRDLLPSRCRDY_outdelay : std_logic_vector(1 downto 0);
    signal TRNRD_outdelay : std_logic_vector(127 downto 0);
    signal TRNRECRCERR_outdelay : std_ulogic;
    signal TRNREOF_outdelay : std_ulogic;
    signal TRNRERRFWD_outdelay : std_ulogic;
    signal TRNRREM_outdelay : std_logic_vector(1 downto 0);
    signal TRNRSOF_outdelay : std_ulogic;
    signal TRNRSRCDSC_outdelay : std_ulogic;
    signal TRNRSRCRDY_outdelay : std_ulogic;
    signal TRNTBUFAV_outdelay : std_logic_vector(5 downto 0);
    signal TRNTCFGREQ_outdelay : std_ulogic;
    signal TRNTDLLPDSTRDY_outdelay : std_ulogic;
    signal TRNTDSTRDY_outdelay : std_logic_vector(3 downto 0);
    signal TRNTERRDROP_outdelay : std_ulogic;
    signal USERRSTN_outdelay : std_ulogic;
    
    signal CFGAERINTERRUPTMSGNUM_ipd : std_logic_vector(4 downto 0);
    signal CFGDEVID_ipd : std_logic_vector(15 downto 0);
    signal CFGDSBUSNUMBER_ipd : std_logic_vector(7 downto 0);
    signal CFGDSDEVICENUMBER_ipd : std_logic_vector(4 downto 0);
    signal CFGDSFUNCTIONNUMBER_ipd : std_logic_vector(2 downto 0);
    signal CFGDSN_ipd : std_logic_vector(63 downto 0);
    signal CFGERRACSN_ipd : std_ulogic;
    signal CFGERRAERHEADERLOG_ipd : std_logic_vector(127 downto 0);
    signal CFGERRATOMICEGRESSBLOCKEDN_ipd : std_ulogic;
    signal CFGERRCORN_ipd : std_ulogic;
    signal CFGERRCPLABORTN_ipd : std_ulogic;
    signal CFGERRCPLTIMEOUTN_ipd : std_ulogic;
    signal CFGERRCPLUNEXPECTN_ipd : std_ulogic;
    signal CFGERRECRCN_ipd : std_ulogic;
    signal CFGERRINTERNALCORN_ipd : std_ulogic;
    signal CFGERRINTERNALUNCORN_ipd : std_ulogic;
    signal CFGERRLOCKEDN_ipd : std_ulogic;
    signal CFGERRMALFORMEDN_ipd : std_ulogic;
    signal CFGERRMCBLOCKEDN_ipd : std_ulogic;
    signal CFGERRNORECOVERYN_ipd : std_ulogic;
    signal CFGERRPOISONEDN_ipd : std_ulogic;
    signal CFGERRPOSTEDN_ipd : std_ulogic;
    signal CFGERRTLPCPLHEADER_ipd : std_logic_vector(47 downto 0);
    signal CFGERRURN_ipd : std_ulogic;
    signal CFGFORCECOMMONCLOCKOFF_ipd : std_ulogic;
    signal CFGFORCEEXTENDEDSYNCON_ipd : std_ulogic;
    signal CFGFORCEMPS_ipd : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTASSERTN_ipd : std_ulogic;
    signal CFGINTERRUPTDI_ipd : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTN_ipd : std_ulogic;
    signal CFGINTERRUPTSTATN_ipd : std_ulogic;
    signal CFGMGMTBYTEENN_ipd : std_logic_vector(3 downto 0);
    signal CFGMGMTDI_ipd : std_logic_vector(31 downto 0);
    signal CFGMGMTDWADDR_ipd : std_logic_vector(9 downto 0);
    signal CFGMGMTRDENN_ipd : std_ulogic;
    signal CFGMGMTWRENN_ipd : std_ulogic;
    signal CFGMGMTWRREADONLYN_ipd : std_ulogic;
    signal CFGMGMTWRRW1CASRWN_ipd : std_ulogic;
    signal CFGPCIECAPINTERRUPTMSGNUM_ipd : std_logic_vector(4 downto 0);
    signal CFGPMFORCESTATEENN_ipd : std_ulogic;
    signal CFGPMFORCESTATE_ipd : std_logic_vector(1 downto 0);
    signal CFGPMHALTASPML0SN_ipd : std_ulogic;
    signal CFGPMHALTASPML1N_ipd : std_ulogic;
    signal CFGPMSENDPMETON_ipd : std_ulogic;
    signal CFGPMTURNOFFOKN_ipd : std_ulogic;
    signal CFGPMWAKEN_ipd : std_ulogic;
    signal CFGPORTNUMBER_ipd : std_logic_vector(7 downto 0);
    signal CFGREVID_ipd : std_logic_vector(7 downto 0);
    signal CFGSUBSYSID_ipd : std_logic_vector(15 downto 0);
    signal CFGSUBSYSVENDID_ipd : std_logic_vector(15 downto 0);
    signal CFGTRNPENDINGN_ipd : std_ulogic;
    signal CFGVENDID_ipd : std_logic_vector(15 downto 0);
    signal CMRSTN_ipd : std_ulogic;
    signal CMSTICKYRSTN_ipd : std_ulogic;
    signal DBGMODE_ipd : std_logic_vector(1 downto 0);
    signal DBGSUBMODE_ipd : std_ulogic;
    signal DLRSTN_ipd : std_ulogic;
    signal DRPADDR_ipd : std_logic_vector(8 downto 0);
    signal DRPCLK_ipd : std_ulogic;
    signal DRPDI_ipd : std_logic_vector(15 downto 0);
    signal DRPEN_ipd : std_ulogic;
    signal DRPWE_ipd : std_ulogic;
    signal FUNCLVLRSTN_ipd : std_ulogic;
    signal LL2SENDASREQL1_ipd : std_ulogic;
    signal LL2SENDENTERL1_ipd : std_ulogic;
    signal LL2SENDENTERL23_ipd : std_ulogic;
    signal LL2SENDPMACK_ipd : std_ulogic;
    signal LL2SUSPENDNOW_ipd : std_ulogic;
    signal LL2TLPRCV_ipd : std_ulogic;
    signal MIMRXRDATA_ipd : std_logic_vector(67 downto 0);
    signal MIMTXRDATA_ipd : std_logic_vector(68 downto 0);
    signal PIPECLK_ipd : std_ulogic;
    signal PIPERX0CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX0CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX0DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX0ELECIDLE_ipd : std_ulogic;
    signal PIPERX0PHYSTATUS_ipd : std_ulogic;
    signal PIPERX0STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX0VALID_ipd : std_ulogic;
    signal PIPERX1CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX1CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX1DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX1ELECIDLE_ipd : std_ulogic;
    signal PIPERX1PHYSTATUS_ipd : std_ulogic;
    signal PIPERX1STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX1VALID_ipd : std_ulogic;
    signal PIPERX2CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX2CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX2DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX2ELECIDLE_ipd : std_ulogic;
    signal PIPERX2PHYSTATUS_ipd : std_ulogic;
    signal PIPERX2STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX2VALID_ipd : std_ulogic;
    signal PIPERX3CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX3CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX3DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX3ELECIDLE_ipd : std_ulogic;
    signal PIPERX3PHYSTATUS_ipd : std_ulogic;
    signal PIPERX3STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX3VALID_ipd : std_ulogic;
    signal PIPERX4CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX4CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX4DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX4ELECIDLE_ipd : std_ulogic;
    signal PIPERX4PHYSTATUS_ipd : std_ulogic;
    signal PIPERX4STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX4VALID_ipd : std_ulogic;
    signal PIPERX5CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX5CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX5DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX5ELECIDLE_ipd : std_ulogic;
    signal PIPERX5PHYSTATUS_ipd : std_ulogic;
    signal PIPERX5STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX5VALID_ipd : std_ulogic;
    signal PIPERX6CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX6CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX6DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX6ELECIDLE_ipd : std_ulogic;
    signal PIPERX6PHYSTATUS_ipd : std_ulogic;
    signal PIPERX6STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX6VALID_ipd : std_ulogic;
    signal PIPERX7CHANISALIGNED_ipd : std_ulogic;
    signal PIPERX7CHARISK_ipd : std_logic_vector(1 downto 0);
    signal PIPERX7DATA_ipd : std_logic_vector(15 downto 0);
    signal PIPERX7ELECIDLE_ipd : std_ulogic;
    signal PIPERX7PHYSTATUS_ipd : std_ulogic;
    signal PIPERX7STATUS_ipd : std_logic_vector(2 downto 0);
    signal PIPERX7VALID_ipd : std_ulogic;
    signal PL2DIRECTEDLSTATE_ipd : std_logic_vector(4 downto 0);
    signal PLDBGMODE_ipd : std_logic_vector(2 downto 0);
    signal PLDIRECTEDLINKAUTON_ipd : std_ulogic;
    signal PLDIRECTEDLINKCHANGE_ipd : std_logic_vector(1 downto 0);
    signal PLDIRECTEDLINKSPEED_ipd : std_ulogic;
    signal PLDIRECTEDLINKWIDTH_ipd : std_logic_vector(1 downto 0);
    signal PLDIRECTEDLTSSMNEWVLD_ipd : std_ulogic;
    signal PLDIRECTEDLTSSMNEW_ipd : std_logic_vector(5 downto 0);
    signal PLDIRECTEDLTSSMSTALL_ipd : std_ulogic;
    signal PLDOWNSTREAMDEEMPHSOURCE_ipd : std_ulogic;
    signal PLRSTN_ipd : std_ulogic;
    signal PLTRANSMITHOTRST_ipd : std_ulogic;
    signal PLUPSTREAMPREFERDEEMPH_ipd : std_ulogic;
    signal SYSRSTN_ipd : std_ulogic;
    signal TL2ASPMSUSPENDCREDITCHECK_ipd : std_ulogic;
    signal TL2PPMSUSPENDREQ_ipd : std_ulogic;
    signal TLRSTN_ipd : std_ulogic;
    signal TRNFCSEL_ipd : std_logic_vector(2 downto 0);
    signal TRNRDSTRDY_ipd : std_ulogic;
    signal TRNRFCPRET_ipd : std_ulogic;
    signal TRNRNPOK_ipd : std_ulogic;
    signal TRNRNPREQ_ipd : std_ulogic;
    signal TRNTCFGGNT_ipd : std_ulogic;
    signal TRNTDLLPDATA_ipd : std_logic_vector(31 downto 0);
    signal TRNTDLLPSRCRDY_ipd : std_ulogic;
    signal TRNTD_ipd : std_logic_vector(127 downto 0);
    signal TRNTECRCGEN_ipd : std_ulogic;
    signal TRNTEOF_ipd : std_ulogic;
    signal TRNTERRFWD_ipd : std_ulogic;
    signal TRNTREM_ipd : std_logic_vector(1 downto 0);
    signal TRNTSOF_ipd : std_ulogic;
    signal TRNTSRCDSC_ipd : std_ulogic;
    signal TRNTSRCRDY_ipd : std_ulogic;
    signal TRNTSTR_ipd : std_ulogic;
    signal USERCLK2_ipd : std_ulogic;
    signal USERCLK_ipd : std_ulogic;
    
    signal CFGAERINTERRUPTMSGNUM_indelay : std_logic_vector(4 downto 0);
    signal CFGDEVID_indelay : std_logic_vector(15 downto 0);
    signal CFGDSBUSNUMBER_indelay : std_logic_vector(7 downto 0);
    signal CFGDSDEVICENUMBER_indelay : std_logic_vector(4 downto 0);
    signal CFGDSFUNCTIONNUMBER_indelay : std_logic_vector(2 downto 0);
    signal CFGDSN_indelay : std_logic_vector(63 downto 0);
    signal CFGERRACSN_indelay : std_ulogic;
    signal CFGERRAERHEADERLOG_indelay : std_logic_vector(127 downto 0);
    signal CFGERRATOMICEGRESSBLOCKEDN_indelay : std_ulogic;
    signal CFGERRCORN_indelay : std_ulogic;
    signal CFGERRCPLABORTN_indelay : std_ulogic;
    signal CFGERRCPLTIMEOUTN_indelay : std_ulogic;
    signal CFGERRCPLUNEXPECTN_indelay : std_ulogic;
    signal CFGERRECRCN_indelay : std_ulogic;
    signal CFGERRINTERNALCORN_indelay : std_ulogic;
    signal CFGERRINTERNALUNCORN_indelay : std_ulogic;
    signal CFGERRLOCKEDN_indelay : std_ulogic;
    signal CFGERRMALFORMEDN_indelay : std_ulogic;
    signal CFGERRMCBLOCKEDN_indelay : std_ulogic;
    signal CFGERRNORECOVERYN_indelay : std_ulogic;
    signal CFGERRPOISONEDN_indelay : std_ulogic;
    signal CFGERRPOSTEDN_indelay : std_ulogic;
    signal CFGERRTLPCPLHEADER_indelay : std_logic_vector(47 downto 0);
    signal CFGERRURN_indelay : std_ulogic;
    signal CFGFORCECOMMONCLOCKOFF_indelay : std_ulogic;
    signal CFGFORCEEXTENDEDSYNCON_indelay : std_ulogic;
    signal CFGFORCEMPS_indelay : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTASSERTN_indelay : std_ulogic;
    signal CFGINTERRUPTDI_indelay : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTN_indelay : std_ulogic;
    signal CFGINTERRUPTSTATN_indelay : std_ulogic;
    signal CFGMGMTBYTEENN_indelay : std_logic_vector(3 downto 0);
    signal CFGMGMTDI_indelay : std_logic_vector(31 downto 0);
    signal CFGMGMTDWADDR_indelay : std_logic_vector(9 downto 0);
    signal CFGMGMTRDENN_indelay : std_ulogic;
    signal CFGMGMTWRENN_indelay : std_ulogic;
    signal CFGMGMTWRREADONLYN_indelay : std_ulogic;
    signal CFGMGMTWRRW1CASRWN_indelay : std_ulogic;
    signal CFGPCIECAPINTERRUPTMSGNUM_indelay : std_logic_vector(4 downto 0);
    signal CFGPMFORCESTATEENN_indelay : std_ulogic;
    signal CFGPMFORCESTATE_indelay : std_logic_vector(1 downto 0);
    signal CFGPMHALTASPML0SN_indelay : std_ulogic;
    signal CFGPMHALTASPML1N_indelay : std_ulogic;
    signal CFGPMSENDPMETON_indelay : std_ulogic;
    signal CFGPMTURNOFFOKN_indelay : std_ulogic;
    signal CFGPMWAKEN_indelay : std_ulogic;
    signal CFGPORTNUMBER_indelay : std_logic_vector(7 downto 0);
    signal CFGREVID_indelay : std_logic_vector(7 downto 0);
    signal CFGSUBSYSID_indelay : std_logic_vector(15 downto 0);
    signal CFGSUBSYSVENDID_indelay : std_logic_vector(15 downto 0);
    signal CFGTRNPENDINGN_indelay : std_ulogic;
    signal CFGVENDID_indelay : std_logic_vector(15 downto 0);
    signal CMRSTN_indelay : std_ulogic;
    signal CMSTICKYRSTN_indelay : std_ulogic;
    signal DBGMODE_indelay : std_logic_vector(1 downto 0);
    signal DBGSUBMODE_indelay : std_ulogic;
    signal DLRSTN_indelay : std_ulogic;
    signal DRPADDR_indelay : std_logic_vector(8 downto 0);
    signal DRPCLK_indelay : std_ulogic;
    signal DRPDI_indelay : std_logic_vector(15 downto 0);
    signal DRPEN_indelay : std_ulogic;
    signal DRPWE_indelay : std_ulogic;
    signal FUNCLVLRSTN_indelay : std_ulogic;
    signal LL2SENDASREQL1_indelay : std_ulogic;
    signal LL2SENDENTERL1_indelay : std_ulogic;
    signal LL2SENDENTERL23_indelay : std_ulogic;
    signal LL2SENDPMACK_indelay : std_ulogic;
    signal LL2SUSPENDNOW_indelay : std_ulogic;
    signal LL2TLPRCV_indelay : std_ulogic;
    signal MIMRXRDATA_indelay : std_logic_vector(67 downto 0);
    signal MIMTXRDATA_indelay : std_logic_vector(68 downto 0);
    signal PIPECLK_indelay : std_ulogic;
    signal PIPERX0CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX0CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX0DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX0ELECIDLE_indelay : std_ulogic;
    signal PIPERX0PHYSTATUS_indelay : std_ulogic;
    signal PIPERX0STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX0VALID_indelay : std_ulogic;
    signal PIPERX1CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX1CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX1DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX1ELECIDLE_indelay : std_ulogic;
    signal PIPERX1PHYSTATUS_indelay : std_ulogic;
    signal PIPERX1STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX1VALID_indelay : std_ulogic;
    signal PIPERX2CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX2CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX2DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX2ELECIDLE_indelay : std_ulogic;
    signal PIPERX2PHYSTATUS_indelay : std_ulogic;
    signal PIPERX2STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX2VALID_indelay : std_ulogic;
    signal PIPERX3CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX3CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX3DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX3ELECIDLE_indelay : std_ulogic;
    signal PIPERX3PHYSTATUS_indelay : std_ulogic;
    signal PIPERX3STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX3VALID_indelay : std_ulogic;
    signal PIPERX4CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX4CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX4DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX4ELECIDLE_indelay : std_ulogic;
    signal PIPERX4PHYSTATUS_indelay : std_ulogic;
    signal PIPERX4STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX4VALID_indelay : std_ulogic;
    signal PIPERX5CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX5CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX5DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX5ELECIDLE_indelay : std_ulogic;
    signal PIPERX5PHYSTATUS_indelay : std_ulogic;
    signal PIPERX5STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX5VALID_indelay : std_ulogic;
    signal PIPERX6CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX6CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX6DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX6ELECIDLE_indelay : std_ulogic;
    signal PIPERX6PHYSTATUS_indelay : std_ulogic;
    signal PIPERX6STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX6VALID_indelay : std_ulogic;
    signal PIPERX7CHANISALIGNED_indelay : std_ulogic;
    signal PIPERX7CHARISK_indelay : std_logic_vector(1 downto 0);
    signal PIPERX7DATA_indelay : std_logic_vector(15 downto 0);
    signal PIPERX7ELECIDLE_indelay : std_ulogic;
    signal PIPERX7PHYSTATUS_indelay : std_ulogic;
    signal PIPERX7STATUS_indelay : std_logic_vector(2 downto 0);
    signal PIPERX7VALID_indelay : std_ulogic;
    signal PL2DIRECTEDLSTATE_indelay : std_logic_vector(4 downto 0);
    signal PLDBGMODE_indelay : std_logic_vector(2 downto 0);
    signal PLDIRECTEDLINKAUTON_indelay : std_ulogic;
    signal PLDIRECTEDLINKCHANGE_indelay : std_logic_vector(1 downto 0);
    signal PLDIRECTEDLINKSPEED_indelay : std_ulogic;
    signal PLDIRECTEDLINKWIDTH_indelay : std_logic_vector(1 downto 0);
    signal PLDIRECTEDLTSSMNEWVLD_indelay : std_ulogic;
    signal PLDIRECTEDLTSSMNEW_indelay : std_logic_vector(5 downto 0);
    signal PLDIRECTEDLTSSMSTALL_indelay : std_ulogic;
    signal PLDOWNSTREAMDEEMPHSOURCE_indelay : std_ulogic;
    signal PLRSTN_indelay : std_ulogic;
    signal PLTRANSMITHOTRST_indelay : std_ulogic;
    signal PLUPSTREAMPREFERDEEMPH_indelay : std_ulogic;
    signal SYSRSTN_indelay : std_ulogic;
    signal TL2ASPMSUSPENDCREDITCHECK_indelay : std_ulogic;
    signal TL2PPMSUSPENDREQ_indelay : std_ulogic;
    signal TLRSTN_indelay : std_ulogic;
    signal TRNFCSEL_indelay : std_logic_vector(2 downto 0);
    signal TRNRDSTRDY_indelay : std_ulogic;
    signal TRNRFCPRET_indelay : std_ulogic;
    signal TRNRNPOK_indelay : std_ulogic;
    signal TRNRNPREQ_indelay : std_ulogic;
    signal TRNTCFGGNT_indelay : std_ulogic;
    signal TRNTDLLPDATA_indelay : std_logic_vector(31 downto 0);
    signal TRNTDLLPSRCRDY_indelay : std_ulogic;
    signal TRNTD_indelay : std_logic_vector(127 downto 0);
    signal TRNTECRCGEN_indelay : std_ulogic;
    signal TRNTEOF_indelay : std_ulogic;
    signal TRNTERRFWD_indelay : std_ulogic;
    signal TRNTREM_indelay : std_logic_vector(1 downto 0);
    signal TRNTSOF_indelay : std_ulogic;
    signal TRNTSRCDSC_indelay : std_ulogic;
    signal TRNTSRCRDY_indelay : std_ulogic;
    signal TRNTSTR_indelay : std_ulogic;
    signal USERCLK2_indelay : std_ulogic;
    signal USERCLK_indelay : std_ulogic;
    
    begin
    CFGAERECRCCHECKEN_out <= CFGAERECRCCHECKEN_outdelay after OUT_DELAY;
    CFGAERECRCGENEN_out <= CFGAERECRCGENEN_outdelay after OUT_DELAY;
    CFGAERROOTERRCORRERRRECEIVED_out <= CFGAERROOTERRCORRERRRECEIVED_outdelay after OUT_DELAY;
    CFGAERROOTERRCORRERRREPORTINGEN_out <= CFGAERROOTERRCORRERRREPORTINGEN_outdelay after OUT_DELAY;
    CFGAERROOTERRFATALERRRECEIVED_out <= CFGAERROOTERRFATALERRRECEIVED_outdelay after OUT_DELAY;
    CFGAERROOTERRFATALERRREPORTINGEN_out <= CFGAERROOTERRFATALERRREPORTINGEN_outdelay after OUT_DELAY;
    CFGAERROOTERRNONFATALERRRECEIVED_out <= CFGAERROOTERRNONFATALERRRECEIVED_outdelay after OUT_DELAY;
    CFGAERROOTERRNONFATALERRREPORTINGEN_out <= CFGAERROOTERRNONFATALERRREPORTINGEN_outdelay after OUT_DELAY;
    CFGBRIDGESERREN_out <= CFGBRIDGESERREN_outdelay after OUT_DELAY;
    CFGCOMMANDBUSMASTERENABLE_out <= CFGCOMMANDBUSMASTERENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDINTERRUPTDISABLE_out <= CFGCOMMANDINTERRUPTDISABLE_outdelay after OUT_DELAY;
    CFGCOMMANDIOENABLE_out <= CFGCOMMANDIOENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDMEMENABLE_out <= CFGCOMMANDMEMENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDSERREN_out <= CFGCOMMANDSERREN_outdelay after OUT_DELAY;
    CFGDEVCONTROL2ARIFORWARDEN_out <= CFGDEVCONTROL2ARIFORWARDEN_outdelay after OUT_DELAY;
    CFGDEVCONTROL2ATOMICEGRESSBLOCK_out <= CFGDEVCONTROL2ATOMICEGRESSBLOCK_outdelay after OUT_DELAY;
    CFGDEVCONTROL2ATOMICREQUESTEREN_out <= CFGDEVCONTROL2ATOMICREQUESTEREN_outdelay after OUT_DELAY;
    CFGDEVCONTROL2CPLTIMEOUTDIS_out <= CFGDEVCONTROL2CPLTIMEOUTDIS_outdelay after OUT_DELAY;
    CFGDEVCONTROL2CPLTIMEOUTVAL_out <= CFGDEVCONTROL2CPLTIMEOUTVAL_outdelay after OUT_DELAY;
    CFGDEVCONTROL2IDOCPLEN_out <= CFGDEVCONTROL2IDOCPLEN_outdelay after OUT_DELAY;
    CFGDEVCONTROL2IDOREQEN_out <= CFGDEVCONTROL2IDOREQEN_outdelay after OUT_DELAY;
    CFGDEVCONTROL2LTREN_out <= CFGDEVCONTROL2LTREN_outdelay after OUT_DELAY;
    CFGDEVCONTROL2TLPPREFIXBLOCK_out <= CFGDEVCONTROL2TLPPREFIXBLOCK_outdelay after OUT_DELAY;
    CFGDEVCONTROLAUXPOWEREN_out <= CFGDEVCONTROLAUXPOWEREN_outdelay after OUT_DELAY;
    CFGDEVCONTROLCORRERRREPORTINGEN_out <= CFGDEVCONTROLCORRERRREPORTINGEN_outdelay after OUT_DELAY;
    CFGDEVCONTROLENABLERO_out <= CFGDEVCONTROLENABLERO_outdelay after OUT_DELAY;
    CFGDEVCONTROLEXTTAGEN_out <= CFGDEVCONTROLEXTTAGEN_outdelay after OUT_DELAY;
    CFGDEVCONTROLFATALERRREPORTINGEN_out <= CFGDEVCONTROLFATALERRREPORTINGEN_outdelay after OUT_DELAY;
    CFGDEVCONTROLMAXPAYLOAD_out <= CFGDEVCONTROLMAXPAYLOAD_outdelay after OUT_DELAY;
    CFGDEVCONTROLMAXREADREQ_out <= CFGDEVCONTROLMAXREADREQ_outdelay after OUT_DELAY;
    CFGDEVCONTROLNONFATALREPORTINGEN_out <= CFGDEVCONTROLNONFATALREPORTINGEN_outdelay after OUT_DELAY;
    CFGDEVCONTROLNOSNOOPEN_out <= CFGDEVCONTROLNOSNOOPEN_outdelay after OUT_DELAY;
    CFGDEVCONTROLPHANTOMEN_out <= CFGDEVCONTROLPHANTOMEN_outdelay after OUT_DELAY;
    CFGDEVCONTROLURERRREPORTINGEN_out <= CFGDEVCONTROLURERRREPORTINGEN_outdelay after OUT_DELAY;
    CFGDEVSTATUSCORRERRDETECTED_out <= CFGDEVSTATUSCORRERRDETECTED_outdelay after OUT_DELAY;
    CFGDEVSTATUSFATALERRDETECTED_out <= CFGDEVSTATUSFATALERRDETECTED_outdelay after OUT_DELAY;
    CFGDEVSTATUSNONFATALERRDETECTED_out <= CFGDEVSTATUSNONFATALERRDETECTED_outdelay after OUT_DELAY;
    CFGDEVSTATUSURDETECTED_out <= CFGDEVSTATUSURDETECTED_outdelay after OUT_DELAY;
    CFGERRAERHEADERLOGSETN_out <= CFGERRAERHEADERLOGSETN_outdelay after OUT_DELAY;
    CFGERRCPLRDYN_out <= CFGERRCPLRDYN_outdelay after OUT_DELAY;
    CFGINTERRUPTDO_out <= CFGINTERRUPTDO_outdelay after OUT_DELAY;
    CFGINTERRUPTMMENABLE_out <= CFGINTERRUPTMMENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIENABLE_out <= CFGINTERRUPTMSIENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXENABLE_out <= CFGINTERRUPTMSIXENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIXFM_out <= CFGINTERRUPTMSIXFM_outdelay after OUT_DELAY;
    CFGINTERRUPTRDYN_out <= CFGINTERRUPTRDYN_outdelay after OUT_DELAY;
    CFGLINKCONTROLASPMCONTROL_out <= CFGLINKCONTROLASPMCONTROL_outdelay after OUT_DELAY;
    CFGLINKCONTROLAUTOBANDWIDTHINTEN_out <= CFGLINKCONTROLAUTOBANDWIDTHINTEN_outdelay after OUT_DELAY;
    CFGLINKCONTROLBANDWIDTHINTEN_out <= CFGLINKCONTROLBANDWIDTHINTEN_outdelay after OUT_DELAY;
    CFGLINKCONTROLCLOCKPMEN_out <= CFGLINKCONTROLCLOCKPMEN_outdelay after OUT_DELAY;
    CFGLINKCONTROLCOMMONCLOCK_out <= CFGLINKCONTROLCOMMONCLOCK_outdelay after OUT_DELAY;
    CFGLINKCONTROLEXTENDEDSYNC_out <= CFGLINKCONTROLEXTENDEDSYNC_outdelay after OUT_DELAY;
    CFGLINKCONTROLHWAUTOWIDTHDIS_out <= CFGLINKCONTROLHWAUTOWIDTHDIS_outdelay after OUT_DELAY;
    CFGLINKCONTROLLINKDISABLE_out <= CFGLINKCONTROLLINKDISABLE_outdelay after OUT_DELAY;
    CFGLINKCONTROLRCB_out <= CFGLINKCONTROLRCB_outdelay after OUT_DELAY;
    CFGLINKCONTROLRETRAINLINK_out <= CFGLINKCONTROLRETRAINLINK_outdelay after OUT_DELAY;
    CFGLINKSTATUSAUTOBANDWIDTHSTATUS_out <= CFGLINKSTATUSAUTOBANDWIDTHSTATUS_outdelay after OUT_DELAY;
    CFGLINKSTATUSBANDWIDTHSTATUS_out <= CFGLINKSTATUSBANDWIDTHSTATUS_outdelay after OUT_DELAY;
    CFGLINKSTATUSCURRENTSPEED_out <= CFGLINKSTATUSCURRENTSPEED_outdelay after OUT_DELAY;
    CFGLINKSTATUSDLLACTIVE_out <= CFGLINKSTATUSDLLACTIVE_outdelay after OUT_DELAY;
    CFGLINKSTATUSLINKTRAINING_out <= CFGLINKSTATUSLINKTRAINING_outdelay after OUT_DELAY;
    CFGLINKSTATUSNEGOTIATEDWIDTH_out <= CFGLINKSTATUSNEGOTIATEDWIDTH_outdelay after OUT_DELAY;
    CFGMGMTDO_out <= CFGMGMTDO_outdelay after OUT_DELAY;
    CFGMGMTRDWRDONEN_out <= CFGMGMTRDWRDONEN_outdelay after OUT_DELAY;
    CFGMSGDATA_out <= CFGMSGDATA_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDASSERTINTA_out <= CFGMSGRECEIVEDASSERTINTA_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDASSERTINTB_out <= CFGMSGRECEIVEDASSERTINTB_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDASSERTINTC_out <= CFGMSGRECEIVEDASSERTINTC_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDASSERTINTD_out <= CFGMSGRECEIVEDASSERTINTD_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDDEASSERTINTA_out <= CFGMSGRECEIVEDDEASSERTINTA_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDDEASSERTINTB_out <= CFGMSGRECEIVEDDEASSERTINTB_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDDEASSERTINTC_out <= CFGMSGRECEIVEDDEASSERTINTC_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDDEASSERTINTD_out <= CFGMSGRECEIVEDDEASSERTINTD_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDERRCOR_out <= CFGMSGRECEIVEDERRCOR_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDERRFATAL_out <= CFGMSGRECEIVEDERRFATAL_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDERRNONFATAL_out <= CFGMSGRECEIVEDERRNONFATAL_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDPMASNAK_out <= CFGMSGRECEIVEDPMASNAK_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDPMETOACK_out <= CFGMSGRECEIVEDPMETOACK_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDPMETO_out <= CFGMSGRECEIVEDPMETO_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDPMPME_out <= CFGMSGRECEIVEDPMPME_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDSETSLOTPOWERLIMIT_out <= CFGMSGRECEIVEDSETSLOTPOWERLIMIT_outdelay after OUT_DELAY;
    CFGMSGRECEIVEDUNLOCK_out <= CFGMSGRECEIVEDUNLOCK_outdelay after OUT_DELAY;
    CFGMSGRECEIVED_out <= CFGMSGRECEIVED_outdelay after OUT_DELAY;
    CFGPCIELINKSTATE_out <= CFGPCIELINKSTATE_outdelay after OUT_DELAY;
    CFGPMCSRPMEEN_out <= CFGPMCSRPMEEN_outdelay after OUT_DELAY;
    CFGPMCSRPMESTATUS_out <= CFGPMCSRPMESTATUS_outdelay after OUT_DELAY;
    CFGPMCSRPOWERSTATE_out <= CFGPMCSRPOWERSTATE_outdelay after OUT_DELAY;
    CFGPMRCVASREQL1N_out <= CFGPMRCVASREQL1N_outdelay after OUT_DELAY;
    CFGPMRCVENTERL1N_out <= CFGPMRCVENTERL1N_outdelay after OUT_DELAY;
    CFGPMRCVENTERL23N_out <= CFGPMRCVENTERL23N_outdelay after OUT_DELAY;
    CFGPMRCVREQACKN_out <= CFGPMRCVREQACKN_outdelay after OUT_DELAY;
    CFGROOTCONTROLPMEINTEN_out <= CFGROOTCONTROLPMEINTEN_outdelay after OUT_DELAY;
    CFGROOTCONTROLSYSERRCORRERREN_out <= CFGROOTCONTROLSYSERRCORRERREN_outdelay after OUT_DELAY;
    CFGROOTCONTROLSYSERRFATALERREN_out <= CFGROOTCONTROLSYSERRFATALERREN_outdelay after OUT_DELAY;
    CFGROOTCONTROLSYSERRNONFATALERREN_out <= CFGROOTCONTROLSYSERRNONFATALERREN_outdelay after OUT_DELAY;
    CFGSLOTCONTROLELECTROMECHILCTLPULSE_out <= CFGSLOTCONTROLELECTROMECHILCTLPULSE_outdelay after OUT_DELAY;
    CFGTRANSACTIONADDR_out <= CFGTRANSACTIONADDR_outdelay after OUT_DELAY;
    CFGTRANSACTIONTYPE_out <= CFGTRANSACTIONTYPE_outdelay after OUT_DELAY;
    CFGTRANSACTION_out <= CFGTRANSACTION_outdelay after OUT_DELAY;
    CFGVCTCVCMAP_out <= CFGVCTCVCMAP_outdelay after OUT_DELAY;
    DBGSCLRA_out <= DBGSCLRA_outdelay after OUT_DELAY;
    DBGSCLRB_out <= DBGSCLRB_outdelay after OUT_DELAY;
    DBGSCLRC_out <= DBGSCLRC_outdelay after OUT_DELAY;
    DBGSCLRD_out <= DBGSCLRD_outdelay after OUT_DELAY;
    DBGSCLRE_out <= DBGSCLRE_outdelay after OUT_DELAY;
    DBGSCLRF_out <= DBGSCLRF_outdelay after OUT_DELAY;
    DBGSCLRG_out <= DBGSCLRG_outdelay after OUT_DELAY;
    DBGSCLRH_out <= DBGSCLRH_outdelay after OUT_DELAY;
    DBGSCLRI_out <= DBGSCLRI_outdelay after OUT_DELAY;
    DBGSCLRJ_out <= DBGSCLRJ_outdelay after OUT_DELAY;
    DBGSCLRK_out <= DBGSCLRK_outdelay after OUT_DELAY;
    DBGVECA_out <= DBGVECA_outdelay after OUT_DELAY;
    DBGVECB_out <= DBGVECB_outdelay after OUT_DELAY;
    DBGVECC_out <= DBGVECC_outdelay after OUT_DELAY;
    DRPDO_out <= DRPDO_outdelay after OUT_DELAY;
    DRPRDY_out <= DRPRDY_outdelay after OUT_DELAY;
    LL2BADDLLPERR_out <= LL2BADDLLPERR_outdelay after OUT_DELAY;
    LL2BADTLPERR_out <= LL2BADTLPERR_outdelay after OUT_DELAY;
    LL2LINKSTATUS_out <= LL2LINKSTATUS_outdelay after OUT_DELAY;
    LL2PROTOCOLERR_out <= LL2PROTOCOLERR_outdelay after OUT_DELAY;
    LL2RECEIVERERR_out <= LL2RECEIVERERR_outdelay after OUT_DELAY;
    LL2REPLAYROERR_out <= LL2REPLAYROERR_outdelay after OUT_DELAY;
    LL2REPLAYTOERR_out <= LL2REPLAYTOERR_outdelay after OUT_DELAY;
    LL2SUSPENDOK_out <= LL2SUSPENDOK_outdelay after OUT_DELAY;
    LL2TFCINIT1SEQ_out <= LL2TFCINIT1SEQ_outdelay after OUT_DELAY;
    LL2TFCINIT2SEQ_out <= LL2TFCINIT2SEQ_outdelay after OUT_DELAY;
    LL2TXIDLE_out <= LL2TXIDLE_outdelay after OUT_DELAY;
    LNKCLKEN_out <= LNKCLKEN_outdelay after OUT_DELAY;
    MIMRXRADDR_out <= MIMRXRADDR_outdelay after OUT_DELAY;
    MIMRXREN_out <= MIMRXREN_outdelay after OUT_DELAY;
    MIMRXWADDR_out <= MIMRXWADDR_outdelay after OUT_DELAY;
    MIMRXWDATA_out <= MIMRXWDATA_outdelay after OUT_DELAY;
    MIMRXWEN_out <= MIMRXWEN_outdelay after OUT_DELAY;
    MIMTXRADDR_out <= MIMTXRADDR_outdelay after OUT_DELAY;
    MIMTXREN_out <= MIMTXREN_outdelay after OUT_DELAY;
    MIMTXWADDR_out <= MIMTXWADDR_outdelay after OUT_DELAY;
    MIMTXWDATA_out <= MIMTXWDATA_outdelay after OUT_DELAY;
    MIMTXWEN_out <= MIMTXWEN_outdelay after OUT_DELAY;
    PIPERX0POLARITY_out <= PIPERX0POLARITY_outdelay after OUT_DELAY;
    PIPERX1POLARITY_out <= PIPERX1POLARITY_outdelay after OUT_DELAY;
    PIPERX2POLARITY_out <= PIPERX2POLARITY_outdelay after OUT_DELAY;
    PIPERX3POLARITY_out <= PIPERX3POLARITY_outdelay after OUT_DELAY;
    PIPERX4POLARITY_out <= PIPERX4POLARITY_outdelay after OUT_DELAY;
    PIPERX5POLARITY_out <= PIPERX5POLARITY_outdelay after OUT_DELAY;
    PIPERX6POLARITY_out <= PIPERX6POLARITY_outdelay after OUT_DELAY;
    PIPERX7POLARITY_out <= PIPERX7POLARITY_outdelay after OUT_DELAY;
    PIPETX0CHARISK_out <= PIPETX0CHARISK_outdelay after OUT_DELAY;
    PIPETX0COMPLIANCE_out <= PIPETX0COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX0DATA_out <= PIPETX0DATA_outdelay after OUT_DELAY;
    PIPETX0ELECIDLE_out <= PIPETX0ELECIDLE_outdelay after OUT_DELAY;
    PIPETX0POWERDOWN_out <= PIPETX0POWERDOWN_outdelay after OUT_DELAY;
    PIPETX1CHARISK_out <= PIPETX1CHARISK_outdelay after OUT_DELAY;
    PIPETX1COMPLIANCE_out <= PIPETX1COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX1DATA_out <= PIPETX1DATA_outdelay after OUT_DELAY;
    PIPETX1ELECIDLE_out <= PIPETX1ELECIDLE_outdelay after OUT_DELAY;
    PIPETX1POWERDOWN_out <= PIPETX1POWERDOWN_outdelay after OUT_DELAY;
    PIPETX2CHARISK_out <= PIPETX2CHARISK_outdelay after OUT_DELAY;
    PIPETX2COMPLIANCE_out <= PIPETX2COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX2DATA_out <= PIPETX2DATA_outdelay after OUT_DELAY;
    PIPETX2ELECIDLE_out <= PIPETX2ELECIDLE_outdelay after OUT_DELAY;
    PIPETX2POWERDOWN_out <= PIPETX2POWERDOWN_outdelay after OUT_DELAY;
    PIPETX3CHARISK_out <= PIPETX3CHARISK_outdelay after OUT_DELAY;
    PIPETX3COMPLIANCE_out <= PIPETX3COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX3DATA_out <= PIPETX3DATA_outdelay after OUT_DELAY;
    PIPETX3ELECIDLE_out <= PIPETX3ELECIDLE_outdelay after OUT_DELAY;
    PIPETX3POWERDOWN_out <= PIPETX3POWERDOWN_outdelay after OUT_DELAY;
    PIPETX4CHARISK_out <= PIPETX4CHARISK_outdelay after OUT_DELAY;
    PIPETX4COMPLIANCE_out <= PIPETX4COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX4DATA_out <= PIPETX4DATA_outdelay after OUT_DELAY;
    PIPETX4ELECIDLE_out <= PIPETX4ELECIDLE_outdelay after OUT_DELAY;
    PIPETX4POWERDOWN_out <= PIPETX4POWERDOWN_outdelay after OUT_DELAY;
    PIPETX5CHARISK_out <= PIPETX5CHARISK_outdelay after OUT_DELAY;
    PIPETX5COMPLIANCE_out <= PIPETX5COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX5DATA_out <= PIPETX5DATA_outdelay after OUT_DELAY;
    PIPETX5ELECIDLE_out <= PIPETX5ELECIDLE_outdelay after OUT_DELAY;
    PIPETX5POWERDOWN_out <= PIPETX5POWERDOWN_outdelay after OUT_DELAY;
    PIPETX6CHARISK_out <= PIPETX6CHARISK_outdelay after OUT_DELAY;
    PIPETX6COMPLIANCE_out <= PIPETX6COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX6DATA_out <= PIPETX6DATA_outdelay after OUT_DELAY;
    PIPETX6ELECIDLE_out <= PIPETX6ELECIDLE_outdelay after OUT_DELAY;
    PIPETX6POWERDOWN_out <= PIPETX6POWERDOWN_outdelay after OUT_DELAY;
    PIPETX7CHARISK_out <= PIPETX7CHARISK_outdelay after OUT_DELAY;
    PIPETX7COMPLIANCE_out <= PIPETX7COMPLIANCE_outdelay after OUT_DELAY;
    PIPETX7DATA_out <= PIPETX7DATA_outdelay after OUT_DELAY;
    PIPETX7ELECIDLE_out <= PIPETX7ELECIDLE_outdelay after OUT_DELAY;
    PIPETX7POWERDOWN_out <= PIPETX7POWERDOWN_outdelay after OUT_DELAY;
    PIPETXDEEMPH_out <= PIPETXDEEMPH_outdelay after OUT_DELAY;
    PIPETXMARGIN_out <= PIPETXMARGIN_outdelay after OUT_DELAY;
    PIPETXRATE_out <= PIPETXRATE_outdelay after OUT_DELAY;
    PIPETXRCVRDET_out <= PIPETXRCVRDET_outdelay after OUT_DELAY;
    PIPETXRESET_out <= PIPETXRESET_outdelay after OUT_DELAY;
    PL2L0REQ_out <= PL2L0REQ_outdelay after OUT_DELAY;
    PL2LINKUP_out <= PL2LINKUP_outdelay after OUT_DELAY;
    PL2RECEIVERERR_out <= PL2RECEIVERERR_outdelay after OUT_DELAY;
    PL2RECOVERY_out <= PL2RECOVERY_outdelay after OUT_DELAY;
    PL2RXELECIDLE_out <= PL2RXELECIDLE_outdelay after OUT_DELAY;
    PL2RXPMSTATE_out <= PL2RXPMSTATE_outdelay after OUT_DELAY;
    PL2SUSPENDOK_out <= PL2SUSPENDOK_outdelay after OUT_DELAY;
    PLDBGVEC_out <= PLDBGVEC_outdelay after OUT_DELAY;
    PLDIRECTEDCHANGEDONE_out <= PLDIRECTEDCHANGEDONE_outdelay after OUT_DELAY;
    PLINITIALLINKWIDTH_out <= PLINITIALLINKWIDTH_outdelay after OUT_DELAY;
    PLLANEREVERSALMODE_out <= PLLANEREVERSALMODE_outdelay after OUT_DELAY;
    PLLINKGEN2CAP_out <= PLLINKGEN2CAP_outdelay after OUT_DELAY;
    PLLINKPARTNERGEN2SUPPORTED_out <= PLLINKPARTNERGEN2SUPPORTED_outdelay after OUT_DELAY;
    PLLINKUPCFGCAP_out <= PLLINKUPCFGCAP_outdelay after OUT_DELAY;
    PLLTSSMSTATE_out <= PLLTSSMSTATE_outdelay after OUT_DELAY;
    PLPHYLNKUPN_out <= PLPHYLNKUPN_outdelay after OUT_DELAY;
    PLRECEIVEDHOTRST_out <= PLRECEIVEDHOTRST_outdelay after OUT_DELAY;
    PLRXPMSTATE_out <= PLRXPMSTATE_outdelay after OUT_DELAY;
    PLSELLNKRATE_out <= PLSELLNKRATE_outdelay after OUT_DELAY;
    PLSELLNKWIDTH_out <= PLSELLNKWIDTH_outdelay after OUT_DELAY;
    PLTXPMSTATE_out <= PLTXPMSTATE_outdelay after OUT_DELAY;
    RECEIVEDFUNCLVLRSTN_out <= RECEIVEDFUNCLVLRSTN_outdelay after OUT_DELAY;
    TL2ASPMSUSPENDCREDITCHECKOK_out <= TL2ASPMSUSPENDCREDITCHECKOK_outdelay after OUT_DELAY;
    TL2ASPMSUSPENDREQ_out <= TL2ASPMSUSPENDREQ_outdelay after OUT_DELAY;
    TL2ERRFCPE_out <= TL2ERRFCPE_outdelay after OUT_DELAY;
    TL2ERRHDR_out <= TL2ERRHDR_outdelay after OUT_DELAY;
    TL2ERRMALFORMED_out <= TL2ERRMALFORMED_outdelay after OUT_DELAY;
    TL2ERRRXOVERFLOW_out <= TL2ERRRXOVERFLOW_outdelay after OUT_DELAY;
    TL2PPMSUSPENDOK_out <= TL2PPMSUSPENDOK_outdelay after OUT_DELAY;
    TRNFCCPLD_out <= TRNFCCPLD_outdelay after OUT_DELAY;
    TRNFCCPLH_out <= TRNFCCPLH_outdelay after OUT_DELAY;
    TRNFCNPD_out <= TRNFCNPD_outdelay after OUT_DELAY;
    TRNFCNPH_out <= TRNFCNPH_outdelay after OUT_DELAY;
    TRNFCPD_out <= TRNFCPD_outdelay after OUT_DELAY;
    TRNFCPH_out <= TRNFCPH_outdelay after OUT_DELAY;
    TRNLNKUP_out <= TRNLNKUP_outdelay after OUT_DELAY;
    TRNRBARHIT_out <= TRNRBARHIT_outdelay after OUT_DELAY;
    TRNRDLLPDATA_out <= TRNRDLLPDATA_outdelay after OUT_DELAY;
    TRNRDLLPSRCRDY_out <= TRNRDLLPSRCRDY_outdelay after OUT_DELAY;
    TRNRD_out <= TRNRD_outdelay after OUT_DELAY;
    TRNRECRCERR_out <= TRNRECRCERR_outdelay after OUT_DELAY;
    TRNREOF_out <= TRNREOF_outdelay after OUT_DELAY;
    TRNRERRFWD_out <= TRNRERRFWD_outdelay after OUT_DELAY;
    TRNRREM_out <= TRNRREM_outdelay after OUT_DELAY;
    TRNRSOF_out <= TRNRSOF_outdelay after OUT_DELAY;
    TRNRSRCDSC_out <= TRNRSRCDSC_outdelay after OUT_DELAY;
    TRNRSRCRDY_out <= TRNRSRCRDY_outdelay after OUT_DELAY;
    TRNTBUFAV_out <= TRNTBUFAV_outdelay after OUT_DELAY;
    TRNTCFGREQ_out <= TRNTCFGREQ_outdelay after OUT_DELAY;
    TRNTDLLPDSTRDY_out <= TRNTDLLPDSTRDY_outdelay after OUT_DELAY;
    TRNTDSTRDY_out <= TRNTDSTRDY_outdelay after OUT_DELAY;
    TRNTERRDROP_out <= TRNTERRDROP_outdelay after OUT_DELAY;
    USERRSTN_out <= USERRSTN_outdelay after OUT_DELAY;
    
    DRPCLK_ipd <= DRPCLK;
    PIPECLK_ipd <= PIPECLK;
    USERCLK2_ipd <= USERCLK2;
    USERCLK_ipd <= USERCLK;
    
    CFGAERINTERRUPTMSGNUM_ipd <= CFGAERINTERRUPTMSGNUM;
    CFGDEVID_ipd <= CFGDEVID;
    CFGDSBUSNUMBER_ipd <= CFGDSBUSNUMBER;
    CFGDSDEVICENUMBER_ipd <= CFGDSDEVICENUMBER;
    CFGDSFUNCTIONNUMBER_ipd <= CFGDSFUNCTIONNUMBER;
    CFGDSN_ipd <= CFGDSN;
    CFGERRACSN_ipd <= CFGERRACSN;
    CFGERRAERHEADERLOG_ipd <= CFGERRAERHEADERLOG;
    CFGERRATOMICEGRESSBLOCKEDN_ipd <= CFGERRATOMICEGRESSBLOCKEDN;
    CFGERRCORN_ipd <= CFGERRCORN;
    CFGERRCPLABORTN_ipd <= CFGERRCPLABORTN;
    CFGERRCPLTIMEOUTN_ipd <= CFGERRCPLTIMEOUTN;
    CFGERRCPLUNEXPECTN_ipd <= CFGERRCPLUNEXPECTN;
    CFGERRECRCN_ipd <= CFGERRECRCN;
    CFGERRINTERNALCORN_ipd <= CFGERRINTERNALCORN;
    CFGERRINTERNALUNCORN_ipd <= CFGERRINTERNALUNCORN;
    CFGERRLOCKEDN_ipd <= CFGERRLOCKEDN;
    CFGERRMALFORMEDN_ipd <= CFGERRMALFORMEDN;
    CFGERRMCBLOCKEDN_ipd <= CFGERRMCBLOCKEDN;
    CFGERRNORECOVERYN_ipd <= CFGERRNORECOVERYN;
    CFGERRPOISONEDN_ipd <= CFGERRPOISONEDN;
    CFGERRPOSTEDN_ipd <= CFGERRPOSTEDN;
    CFGERRTLPCPLHEADER_ipd <= CFGERRTLPCPLHEADER;
    CFGERRURN_ipd <= CFGERRURN;
    CFGFORCECOMMONCLOCKOFF_ipd <= CFGFORCECOMMONCLOCKOFF;
    CFGFORCEEXTENDEDSYNCON_ipd <= CFGFORCEEXTENDEDSYNCON;
    CFGFORCEMPS_ipd <= CFGFORCEMPS;
    CFGINTERRUPTASSERTN_ipd <= CFGINTERRUPTASSERTN;
    CFGINTERRUPTDI_ipd <= CFGINTERRUPTDI;
    CFGINTERRUPTN_ipd <= CFGINTERRUPTN;
    CFGINTERRUPTSTATN_ipd <= CFGINTERRUPTSTATN;
    CFGMGMTBYTEENN_ipd <= CFGMGMTBYTEENN;
    CFGMGMTDI_ipd <= CFGMGMTDI;
    CFGMGMTDWADDR_ipd <= CFGMGMTDWADDR;
    CFGMGMTRDENN_ipd <= CFGMGMTRDENN;
    CFGMGMTWRENN_ipd <= CFGMGMTWRENN;
    CFGMGMTWRREADONLYN_ipd <= CFGMGMTWRREADONLYN;
    CFGMGMTWRRW1CASRWN_ipd <= CFGMGMTWRRW1CASRWN;
    CFGPCIECAPINTERRUPTMSGNUM_ipd <= CFGPCIECAPINTERRUPTMSGNUM;
    CFGPMFORCESTATEENN_ipd <= CFGPMFORCESTATEENN;
    CFGPMFORCESTATE_ipd <= CFGPMFORCESTATE;
    CFGPMHALTASPML0SN_ipd <= CFGPMHALTASPML0SN;
    CFGPMHALTASPML1N_ipd <= CFGPMHALTASPML1N;
    CFGPMSENDPMETON_ipd <= CFGPMSENDPMETON;
    CFGPMTURNOFFOKN_ipd <= CFGPMTURNOFFOKN;
    CFGPMWAKEN_ipd <= CFGPMWAKEN;
    CFGPORTNUMBER_ipd <= CFGPORTNUMBER;
    CFGREVID_ipd <= CFGREVID;
    CFGSUBSYSID_ipd <= CFGSUBSYSID;
    CFGSUBSYSVENDID_ipd <= CFGSUBSYSVENDID;
    CFGTRNPENDINGN_ipd <= CFGTRNPENDINGN;
    CFGVENDID_ipd <= CFGVENDID;
    CMRSTN_ipd <= CMRSTN;
    CMSTICKYRSTN_ipd <= CMSTICKYRSTN;
    DBGMODE_ipd <= DBGMODE;
    DBGSUBMODE_ipd <= DBGSUBMODE;
    DLRSTN_ipd <= DLRSTN;
    DRPADDR_ipd <= DRPADDR;
    DRPDI_ipd <= DRPDI;
    DRPEN_ipd <= DRPEN;
    DRPWE_ipd <= DRPWE;
    FUNCLVLRSTN_ipd <= FUNCLVLRSTN;
    LL2SENDASREQL1_ipd <= LL2SENDASREQL1;
    LL2SENDENTERL1_ipd <= LL2SENDENTERL1;
    LL2SENDENTERL23_ipd <= LL2SENDENTERL23;
    LL2SENDPMACK_ipd <= LL2SENDPMACK;
    LL2SUSPENDNOW_ipd <= LL2SUSPENDNOW;
    LL2TLPRCV_ipd <= LL2TLPRCV;
    MIMRXRDATA_ipd <= MIMRXRDATA;
    MIMTXRDATA_ipd <= MIMTXRDATA;
    PIPERX0CHANISALIGNED_ipd <= PIPERX0CHANISALIGNED;
    PIPERX0CHARISK_ipd <= PIPERX0CHARISK;
    PIPERX0DATA_ipd <= PIPERX0DATA;
    PIPERX0ELECIDLE_ipd <= PIPERX0ELECIDLE;
    PIPERX0PHYSTATUS_ipd <= PIPERX0PHYSTATUS;
    PIPERX0STATUS_ipd <= PIPERX0STATUS;
    PIPERX0VALID_ipd <= PIPERX0VALID;
    PIPERX1CHANISALIGNED_ipd <= PIPERX1CHANISALIGNED;
    PIPERX1CHARISK_ipd <= PIPERX1CHARISK;
    PIPERX1DATA_ipd <= PIPERX1DATA;
    PIPERX1ELECIDLE_ipd <= PIPERX1ELECIDLE;
    PIPERX1PHYSTATUS_ipd <= PIPERX1PHYSTATUS;
    PIPERX1STATUS_ipd <= PIPERX1STATUS;
    PIPERX1VALID_ipd <= PIPERX1VALID;
    PIPERX2CHANISALIGNED_ipd <= PIPERX2CHANISALIGNED;
    PIPERX2CHARISK_ipd <= PIPERX2CHARISK;
    PIPERX2DATA_ipd <= PIPERX2DATA;
    PIPERX2ELECIDLE_ipd <= PIPERX2ELECIDLE;
    PIPERX2PHYSTATUS_ipd <= PIPERX2PHYSTATUS;
    PIPERX2STATUS_ipd <= PIPERX2STATUS;
    PIPERX2VALID_ipd <= PIPERX2VALID;
    PIPERX3CHANISALIGNED_ipd <= PIPERX3CHANISALIGNED;
    PIPERX3CHARISK_ipd <= PIPERX3CHARISK;
    PIPERX3DATA_ipd <= PIPERX3DATA;
    PIPERX3ELECIDLE_ipd <= PIPERX3ELECIDLE;
    PIPERX3PHYSTATUS_ipd <= PIPERX3PHYSTATUS;
    PIPERX3STATUS_ipd <= PIPERX3STATUS;
    PIPERX3VALID_ipd <= PIPERX3VALID;
    PIPERX4CHANISALIGNED_ipd <= PIPERX4CHANISALIGNED;
    PIPERX4CHARISK_ipd <= PIPERX4CHARISK;
    PIPERX4DATA_ipd <= PIPERX4DATA;
    PIPERX4ELECIDLE_ipd <= PIPERX4ELECIDLE;
    PIPERX4PHYSTATUS_ipd <= PIPERX4PHYSTATUS;
    PIPERX4STATUS_ipd <= PIPERX4STATUS;
    PIPERX4VALID_ipd <= PIPERX4VALID;
    PIPERX5CHANISALIGNED_ipd <= PIPERX5CHANISALIGNED;
    PIPERX5CHARISK_ipd <= PIPERX5CHARISK;
    PIPERX5DATA_ipd <= PIPERX5DATA;
    PIPERX5ELECIDLE_ipd <= PIPERX5ELECIDLE;
    PIPERX5PHYSTATUS_ipd <= PIPERX5PHYSTATUS;
    PIPERX5STATUS_ipd <= PIPERX5STATUS;
    PIPERX5VALID_ipd <= PIPERX5VALID;
    PIPERX6CHANISALIGNED_ipd <= PIPERX6CHANISALIGNED;
    PIPERX6CHARISK_ipd <= PIPERX6CHARISK;
    PIPERX6DATA_ipd <= PIPERX6DATA;
    PIPERX6ELECIDLE_ipd <= PIPERX6ELECIDLE;
    PIPERX6PHYSTATUS_ipd <= PIPERX6PHYSTATUS;
    PIPERX6STATUS_ipd <= PIPERX6STATUS;
    PIPERX6VALID_ipd <= PIPERX6VALID;
    PIPERX7CHANISALIGNED_ipd <= PIPERX7CHANISALIGNED;
    PIPERX7CHARISK_ipd <= PIPERX7CHARISK;
    PIPERX7DATA_ipd <= PIPERX7DATA;
    PIPERX7ELECIDLE_ipd <= PIPERX7ELECIDLE;
    PIPERX7PHYSTATUS_ipd <= PIPERX7PHYSTATUS;
    PIPERX7STATUS_ipd <= PIPERX7STATUS;
    PIPERX7VALID_ipd <= PIPERX7VALID;
    PL2DIRECTEDLSTATE_ipd <= PL2DIRECTEDLSTATE;
    PLDBGMODE_ipd <= PLDBGMODE;
    PLDIRECTEDLINKAUTON_ipd <= PLDIRECTEDLINKAUTON;
    PLDIRECTEDLINKCHANGE_ipd <= PLDIRECTEDLINKCHANGE;
    PLDIRECTEDLINKSPEED_ipd <= PLDIRECTEDLINKSPEED;
    PLDIRECTEDLINKWIDTH_ipd <= PLDIRECTEDLINKWIDTH;
    PLDIRECTEDLTSSMNEWVLD_ipd <= PLDIRECTEDLTSSMNEWVLD;
    PLDIRECTEDLTSSMNEW_ipd <= PLDIRECTEDLTSSMNEW;
    PLDIRECTEDLTSSMSTALL_ipd <= PLDIRECTEDLTSSMSTALL;
    PLDOWNSTREAMDEEMPHSOURCE_ipd <= PLDOWNSTREAMDEEMPHSOURCE;
    PLRSTN_ipd <= PLRSTN;
    PLTRANSMITHOTRST_ipd <= PLTRANSMITHOTRST;
    PLUPSTREAMPREFERDEEMPH_ipd <= PLUPSTREAMPREFERDEEMPH;
    SYSRSTN_ipd <= SYSRSTN;
    TL2ASPMSUSPENDCREDITCHECK_ipd <= TL2ASPMSUSPENDCREDITCHECK;
    TL2PPMSUSPENDREQ_ipd <= TL2PPMSUSPENDREQ;
    TLRSTN_ipd <= TLRSTN;
    TRNFCSEL_ipd <= TRNFCSEL;
    TRNRDSTRDY_ipd <= TRNRDSTRDY;
    TRNRFCPRET_ipd <= TRNRFCPRET;
    TRNRNPOK_ipd <= TRNRNPOK;
    TRNRNPREQ_ipd <= TRNRNPREQ;
    TRNTCFGGNT_ipd <= TRNTCFGGNT;
    TRNTDLLPDATA_ipd <= TRNTDLLPDATA;
    TRNTDLLPSRCRDY_ipd <= TRNTDLLPSRCRDY;
    TRNTD_ipd <= TRNTD;
    TRNTECRCGEN_ipd <= TRNTECRCGEN;
    TRNTEOF_ipd <= TRNTEOF;
    TRNTERRFWD_ipd <= TRNTERRFWD;
    TRNTREM_ipd <= TRNTREM;
    TRNTSOF_ipd <= TRNTSOF;
    TRNTSRCDSC_ipd <= TRNTSRCDSC;
    TRNTSRCRDY_ipd <= TRNTSRCRDY;
    TRNTSTR_ipd <= TRNTSTR;
    
    DRPCLK_indelay <= DRPCLK_ipd after INCLK_DELAY;
    PIPECLK_indelay <= PIPECLK_ipd after INCLK_DELAY;
    USERCLK2_indelay <= USERCLK2_ipd after INCLK_DELAY;
    USERCLK_indelay <= USERCLK_ipd after INCLK_DELAY;
    
    CFGAERINTERRUPTMSGNUM_indelay <= CFGAERINTERRUPTMSGNUM_ipd after IN_DELAY;
    CFGDEVID_indelay <= CFGDEVID_ipd after IN_DELAY;
    CFGDSBUSNUMBER_indelay <= CFGDSBUSNUMBER_ipd after IN_DELAY;
    CFGDSDEVICENUMBER_indelay <= CFGDSDEVICENUMBER_ipd after IN_DELAY;
    CFGDSFUNCTIONNUMBER_indelay <= CFGDSFUNCTIONNUMBER_ipd after IN_DELAY;
    CFGDSN_indelay <= CFGDSN_ipd after IN_DELAY;
    CFGERRACSN_indelay <= CFGERRACSN_ipd after IN_DELAY;
    CFGERRAERHEADERLOG_indelay <= CFGERRAERHEADERLOG_ipd after IN_DELAY;
    CFGERRATOMICEGRESSBLOCKEDN_indelay <= CFGERRATOMICEGRESSBLOCKEDN_ipd after IN_DELAY;
    CFGERRCORN_indelay <= CFGERRCORN_ipd after IN_DELAY;
    CFGERRCPLABORTN_indelay <= CFGERRCPLABORTN_ipd after IN_DELAY;
    CFGERRCPLTIMEOUTN_indelay <= CFGERRCPLTIMEOUTN_ipd after IN_DELAY;
    CFGERRCPLUNEXPECTN_indelay <= CFGERRCPLUNEXPECTN_ipd after IN_DELAY;
    CFGERRECRCN_indelay <= CFGERRECRCN_ipd after IN_DELAY;
    CFGERRINTERNALCORN_indelay <= CFGERRINTERNALCORN_ipd after IN_DELAY;
    CFGERRINTERNALUNCORN_indelay <= CFGERRINTERNALUNCORN_ipd after IN_DELAY;
    CFGERRLOCKEDN_indelay <= CFGERRLOCKEDN_ipd after IN_DELAY;
    CFGERRMALFORMEDN_indelay <= CFGERRMALFORMEDN_ipd after IN_DELAY;
    CFGERRMCBLOCKEDN_indelay <= CFGERRMCBLOCKEDN_ipd after IN_DELAY;
    CFGERRNORECOVERYN_indelay <= CFGERRNORECOVERYN_ipd after IN_DELAY;
    CFGERRPOISONEDN_indelay <= CFGERRPOISONEDN_ipd after IN_DELAY;
    CFGERRPOSTEDN_indelay <= CFGERRPOSTEDN_ipd after IN_DELAY;
    CFGERRTLPCPLHEADER_indelay <= CFGERRTLPCPLHEADER_ipd after IN_DELAY;
    CFGERRURN_indelay <= CFGERRURN_ipd after IN_DELAY;
    CFGFORCECOMMONCLOCKOFF_indelay <= CFGFORCECOMMONCLOCKOFF_ipd after IN_DELAY;
    CFGFORCEEXTENDEDSYNCON_indelay <= CFGFORCEEXTENDEDSYNCON_ipd after IN_DELAY;
    CFGFORCEMPS_indelay <= CFGFORCEMPS_ipd after IN_DELAY;
    CFGINTERRUPTASSERTN_indelay <= CFGINTERRUPTASSERTN_ipd after IN_DELAY;
    CFGINTERRUPTDI_indelay <= CFGINTERRUPTDI_ipd after IN_DELAY;
    CFGINTERRUPTN_indelay <= CFGINTERRUPTN_ipd after IN_DELAY;
    CFGINTERRUPTSTATN_indelay <= CFGINTERRUPTSTATN_ipd after IN_DELAY;
    CFGMGMTBYTEENN_indelay <= CFGMGMTBYTEENN_ipd after IN_DELAY;
    CFGMGMTDI_indelay <= CFGMGMTDI_ipd after IN_DELAY;
    CFGMGMTDWADDR_indelay <= CFGMGMTDWADDR_ipd after IN_DELAY;
    CFGMGMTRDENN_indelay <= CFGMGMTRDENN_ipd after IN_DELAY;
    CFGMGMTWRENN_indelay <= CFGMGMTWRENN_ipd after IN_DELAY;
    CFGMGMTWRREADONLYN_indelay <= CFGMGMTWRREADONLYN_ipd after IN_DELAY;
    CFGMGMTWRRW1CASRWN_indelay <= CFGMGMTWRRW1CASRWN_ipd after IN_DELAY;
    CFGPCIECAPINTERRUPTMSGNUM_indelay <= CFGPCIECAPINTERRUPTMSGNUM_ipd after IN_DELAY;
    CFGPMFORCESTATEENN_indelay <= CFGPMFORCESTATEENN_ipd after IN_DELAY;
    CFGPMFORCESTATE_indelay <= CFGPMFORCESTATE_ipd after IN_DELAY;
    CFGPMHALTASPML0SN_indelay <= CFGPMHALTASPML0SN_ipd after IN_DELAY;
    CFGPMHALTASPML1N_indelay <= CFGPMHALTASPML1N_ipd after IN_DELAY;
    CFGPMSENDPMETON_indelay <= CFGPMSENDPMETON_ipd after IN_DELAY;
    CFGPMTURNOFFOKN_indelay <= CFGPMTURNOFFOKN_ipd after IN_DELAY;
    CFGPMWAKEN_indelay <= CFGPMWAKEN_ipd after IN_DELAY;
    CFGPORTNUMBER_indelay <= CFGPORTNUMBER_ipd after IN_DELAY;
    CFGREVID_indelay <= CFGREVID_ipd after IN_DELAY;
    CFGSUBSYSID_indelay <= CFGSUBSYSID_ipd after IN_DELAY;
    CFGSUBSYSVENDID_indelay <= CFGSUBSYSVENDID_ipd after IN_DELAY;
    CFGTRNPENDINGN_indelay <= CFGTRNPENDINGN_ipd after IN_DELAY;
    CFGVENDID_indelay <= CFGVENDID_ipd after IN_DELAY;
    CMRSTN_indelay <= CMRSTN_ipd after IN_DELAY;
    CMSTICKYRSTN_indelay <= CMSTICKYRSTN_ipd after IN_DELAY;
    DBGMODE_indelay <= DBGMODE_ipd after IN_DELAY;
    DBGSUBMODE_indelay <= DBGSUBMODE_ipd after IN_DELAY;
    DLRSTN_indelay <= DLRSTN_ipd after IN_DELAY;
    DRPADDR_indelay <= DRPADDR_ipd after IN_DELAY;
    DRPDI_indelay <= DRPDI_ipd after IN_DELAY;
    DRPEN_indelay <= DRPEN_ipd after IN_DELAY;
    DRPWE_indelay <= DRPWE_ipd after IN_DELAY;
    FUNCLVLRSTN_indelay <= FUNCLVLRSTN_ipd after IN_DELAY;
    LL2SENDASREQL1_indelay <= LL2SENDASREQL1_ipd after IN_DELAY;
    LL2SENDENTERL1_indelay <= LL2SENDENTERL1_ipd after IN_DELAY;
    LL2SENDENTERL23_indelay <= LL2SENDENTERL23_ipd after IN_DELAY;
    LL2SENDPMACK_indelay <= LL2SENDPMACK_ipd after IN_DELAY;
    LL2SUSPENDNOW_indelay <= LL2SUSPENDNOW_ipd after IN_DELAY;
    LL2TLPRCV_indelay <= LL2TLPRCV_ipd after IN_DELAY;
    MIMRXRDATA_indelay <= MIMRXRDATA_ipd after IN_DELAY;
    MIMTXRDATA_indelay <= MIMTXRDATA_ipd after IN_DELAY;
    PIPERX0CHANISALIGNED_indelay <= PIPERX0CHANISALIGNED_ipd after IN_DELAY;
    PIPERX0CHARISK_indelay <= PIPERX0CHARISK_ipd after IN_DELAY;
    PIPERX0DATA_indelay <= PIPERX0DATA_ipd after IN_DELAY;
    PIPERX0ELECIDLE_indelay <= PIPERX0ELECIDLE_ipd after IN_DELAY;
    PIPERX0PHYSTATUS_indelay <= PIPERX0PHYSTATUS_ipd after IN_DELAY;
    PIPERX0STATUS_indelay <= PIPERX0STATUS_ipd after IN_DELAY;
    PIPERX0VALID_indelay <= PIPERX0VALID_ipd after IN_DELAY;
    PIPERX1CHANISALIGNED_indelay <= PIPERX1CHANISALIGNED_ipd after IN_DELAY;
    PIPERX1CHARISK_indelay <= PIPERX1CHARISK_ipd after IN_DELAY;
    PIPERX1DATA_indelay <= PIPERX1DATA_ipd after IN_DELAY;
    PIPERX1ELECIDLE_indelay <= PIPERX1ELECIDLE_ipd after IN_DELAY;
    PIPERX1PHYSTATUS_indelay <= PIPERX1PHYSTATUS_ipd after IN_DELAY;
    PIPERX1STATUS_indelay <= PIPERX1STATUS_ipd after IN_DELAY;
    PIPERX1VALID_indelay <= PIPERX1VALID_ipd after IN_DELAY;
    PIPERX2CHANISALIGNED_indelay <= PIPERX2CHANISALIGNED_ipd after IN_DELAY;
    PIPERX2CHARISK_indelay <= PIPERX2CHARISK_ipd after IN_DELAY;
    PIPERX2DATA_indelay <= PIPERX2DATA_ipd after IN_DELAY;
    PIPERX2ELECIDLE_indelay <= PIPERX2ELECIDLE_ipd after IN_DELAY;
    PIPERX2PHYSTATUS_indelay <= PIPERX2PHYSTATUS_ipd after IN_DELAY;
    PIPERX2STATUS_indelay <= PIPERX2STATUS_ipd after IN_DELAY;
    PIPERX2VALID_indelay <= PIPERX2VALID_ipd after IN_DELAY;
    PIPERX3CHANISALIGNED_indelay <= PIPERX3CHANISALIGNED_ipd after IN_DELAY;
    PIPERX3CHARISK_indelay <= PIPERX3CHARISK_ipd after IN_DELAY;
    PIPERX3DATA_indelay <= PIPERX3DATA_ipd after IN_DELAY;
    PIPERX3ELECIDLE_indelay <= PIPERX3ELECIDLE_ipd after IN_DELAY;
    PIPERX3PHYSTATUS_indelay <= PIPERX3PHYSTATUS_ipd after IN_DELAY;
    PIPERX3STATUS_indelay <= PIPERX3STATUS_ipd after IN_DELAY;
    PIPERX3VALID_indelay <= PIPERX3VALID_ipd after IN_DELAY;
    PIPERX4CHANISALIGNED_indelay <= PIPERX4CHANISALIGNED_ipd after IN_DELAY;
    PIPERX4CHARISK_indelay <= PIPERX4CHARISK_ipd after IN_DELAY;
    PIPERX4DATA_indelay <= PIPERX4DATA_ipd after IN_DELAY;
    PIPERX4ELECIDLE_indelay <= PIPERX4ELECIDLE_ipd after IN_DELAY;
    PIPERX4PHYSTATUS_indelay <= PIPERX4PHYSTATUS_ipd after IN_DELAY;
    PIPERX4STATUS_indelay <= PIPERX4STATUS_ipd after IN_DELAY;
    PIPERX4VALID_indelay <= PIPERX4VALID_ipd after IN_DELAY;
    PIPERX5CHANISALIGNED_indelay <= PIPERX5CHANISALIGNED_ipd after IN_DELAY;
    PIPERX5CHARISK_indelay <= PIPERX5CHARISK_ipd after IN_DELAY;
    PIPERX5DATA_indelay <= PIPERX5DATA_ipd after IN_DELAY;
    PIPERX5ELECIDLE_indelay <= PIPERX5ELECIDLE_ipd after IN_DELAY;
    PIPERX5PHYSTATUS_indelay <= PIPERX5PHYSTATUS_ipd after IN_DELAY;
    PIPERX5STATUS_indelay <= PIPERX5STATUS_ipd after IN_DELAY;
    PIPERX5VALID_indelay <= PIPERX5VALID_ipd after IN_DELAY;
    PIPERX6CHANISALIGNED_indelay <= PIPERX6CHANISALIGNED_ipd after IN_DELAY;
    PIPERX6CHARISK_indelay <= PIPERX6CHARISK_ipd after IN_DELAY;
    PIPERX6DATA_indelay <= PIPERX6DATA_ipd after IN_DELAY;
    PIPERX6ELECIDLE_indelay <= PIPERX6ELECIDLE_ipd after IN_DELAY;
    PIPERX6PHYSTATUS_indelay <= PIPERX6PHYSTATUS_ipd after IN_DELAY;
    PIPERX6STATUS_indelay <= PIPERX6STATUS_ipd after IN_DELAY;
    PIPERX6VALID_indelay <= PIPERX6VALID_ipd after IN_DELAY;
    PIPERX7CHANISALIGNED_indelay <= PIPERX7CHANISALIGNED_ipd after IN_DELAY;
    PIPERX7CHARISK_indelay <= PIPERX7CHARISK_ipd after IN_DELAY;
    PIPERX7DATA_indelay <= PIPERX7DATA_ipd after IN_DELAY;
    PIPERX7ELECIDLE_indelay <= PIPERX7ELECIDLE_ipd after IN_DELAY;
    PIPERX7PHYSTATUS_indelay <= PIPERX7PHYSTATUS_ipd after IN_DELAY;
    PIPERX7STATUS_indelay <= PIPERX7STATUS_ipd after IN_DELAY;
    PIPERX7VALID_indelay <= PIPERX7VALID_ipd after IN_DELAY;
    PL2DIRECTEDLSTATE_indelay <= PL2DIRECTEDLSTATE_ipd after IN_DELAY;
    PLDBGMODE_indelay <= PLDBGMODE_ipd after IN_DELAY;
    PLDIRECTEDLINKAUTON_indelay <= PLDIRECTEDLINKAUTON_ipd after IN_DELAY;
    PLDIRECTEDLINKCHANGE_indelay <= PLDIRECTEDLINKCHANGE_ipd after IN_DELAY;
    PLDIRECTEDLINKSPEED_indelay <= PLDIRECTEDLINKSPEED_ipd after IN_DELAY;
    PLDIRECTEDLINKWIDTH_indelay <= PLDIRECTEDLINKWIDTH_ipd after IN_DELAY;
    PLDIRECTEDLTSSMNEWVLD_indelay <= PLDIRECTEDLTSSMNEWVLD_ipd after IN_DELAY;
    PLDIRECTEDLTSSMNEW_indelay <= PLDIRECTEDLTSSMNEW_ipd after IN_DELAY;
    PLDIRECTEDLTSSMSTALL_indelay <= PLDIRECTEDLTSSMSTALL_ipd after IN_DELAY;
    PLDOWNSTREAMDEEMPHSOURCE_indelay <= PLDOWNSTREAMDEEMPHSOURCE_ipd after IN_DELAY;
    PLRSTN_indelay <= PLRSTN_ipd after IN_DELAY;
    PLTRANSMITHOTRST_indelay <= PLTRANSMITHOTRST_ipd after IN_DELAY;
    PLUPSTREAMPREFERDEEMPH_indelay <= PLUPSTREAMPREFERDEEMPH_ipd after IN_DELAY;
    SYSRSTN_indelay <= SYSRSTN_ipd after IN_DELAY;
    TL2ASPMSUSPENDCREDITCHECK_indelay <= TL2ASPMSUSPENDCREDITCHECK_ipd after IN_DELAY;
    TL2PPMSUSPENDREQ_indelay <= TL2PPMSUSPENDREQ_ipd after IN_DELAY;
    TLRSTN_indelay <= TLRSTN_ipd after IN_DELAY;
    TRNFCSEL_indelay <= TRNFCSEL_ipd after IN_DELAY;
    TRNRDSTRDY_indelay <= TRNRDSTRDY_ipd after IN_DELAY;
    TRNRFCPRET_indelay <= TRNRFCPRET_ipd after IN_DELAY;
    TRNRNPOK_indelay <= TRNRNPOK_ipd after IN_DELAY;
    TRNRNPREQ_indelay <= TRNRNPREQ_ipd after IN_DELAY;
    TRNTCFGGNT_indelay <= TRNTCFGGNT_ipd after IN_DELAY;
    TRNTDLLPDATA_indelay <= TRNTDLLPDATA_ipd after IN_DELAY;
    TRNTDLLPSRCRDY_indelay <= TRNTDLLPSRCRDY_ipd after IN_DELAY;
    TRNTD_indelay <= TRNTD_ipd after IN_DELAY;
    TRNTECRCGEN_indelay <= TRNTECRCGEN_ipd after IN_DELAY;
    TRNTEOF_indelay <= TRNTEOF_ipd after IN_DELAY;
    TRNTERRFWD_indelay <= TRNTERRFWD_ipd after IN_DELAY;
    TRNTREM_indelay <= TRNTREM_ipd after IN_DELAY;
    TRNTSOF_indelay <= TRNTSOF_ipd after IN_DELAY;
    TRNTSRCDSC_indelay <= TRNTSRCDSC_ipd after IN_DELAY;
    TRNTSRCRDY_indelay <= TRNTSRCRDY_ipd after IN_DELAY;
    TRNTSTR_indelay <= TRNTSTR_ipd after IN_DELAY;
    
    
    PCIE_2_1_WRAP_INST : PCIE_2_1_WRAP
      generic map (
        AER_BASE_PTR         => AER_BASE_PTR_STRING,
        AER_CAP_ECRC_CHECK_CAPABLE => AER_CAP_ECRC_CHECK_CAPABLE,
        AER_CAP_ECRC_GEN_CAPABLE => AER_CAP_ECRC_GEN_CAPABLE,
        AER_CAP_ID           => AER_CAP_ID_STRING,
        AER_CAP_MULTIHEADER  => AER_CAP_MULTIHEADER,
        AER_CAP_NEXTPTR      => AER_CAP_NEXTPTR_STRING,
        AER_CAP_ON           => AER_CAP_ON,
        AER_CAP_OPTIONAL_ERR_SUPPORT => AER_CAP_OPTIONAL_ERR_SUPPORT_STRING,
        AER_CAP_PERMIT_ROOTERR_UPDATE => AER_CAP_PERMIT_ROOTERR_UPDATE,
        AER_CAP_VERSION      => AER_CAP_VERSION_STRING,
        ALLOW_X8_GEN2        => ALLOW_X8_GEN2,
        BAR0                 => BAR0_STRING,
        BAR1                 => BAR1_STRING,
        BAR2                 => BAR2_STRING,
        BAR3                 => BAR3_STRING,
        BAR4                 => BAR4_STRING,
        BAR5                 => BAR5_STRING,
        CAPABILITIES_PTR     => CAPABILITIES_PTR_STRING,
        CARDBUS_CIS_POINTER  => CARDBUS_CIS_POINTER_STRING,
        CFG_ECRC_ERR_CPLSTAT => CFG_ECRC_ERR_CPLSTAT,
        CLASS_CODE           => CLASS_CODE_STRING,
        CMD_INTX_IMPLEMENTED => CMD_INTX_IMPLEMENTED,
        CPL_TIMEOUT_DISABLE_SUPPORTED => CPL_TIMEOUT_DISABLE_SUPPORTED,
        CPL_TIMEOUT_RANGES_SUPPORTED => CPL_TIMEOUT_RANGES_SUPPORTED_STRING,
        CRM_MODULE_RSTS      => CRM_MODULE_RSTS_STRING,
        DEV_CAP2_ARI_FORWARDING_SUPPORTED => DEV_CAP2_ARI_FORWARDING_SUPPORTED,
        DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED => DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED,
        DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED => DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED,
        DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED => DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED,
        DEV_CAP2_CAS128_COMPLETER_SUPPORTED => DEV_CAP2_CAS128_COMPLETER_SUPPORTED,
        DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED => DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED,
        DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED => DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED,
        DEV_CAP2_LTR_MECHANISM_SUPPORTED => DEV_CAP2_LTR_MECHANISM_SUPPORTED,
        DEV_CAP2_MAX_ENDEND_TLP_PREFIXES => DEV_CAP2_MAX_ENDEND_TLP_PREFIXES_STRING,
        DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING => DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING,
        DEV_CAP2_TPH_COMPLETER_SUPPORTED => DEV_CAP2_TPH_COMPLETER_SUPPORTED_STRING,
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE,
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE,
        DEV_CAP_ENDPOINT_L0S_LATENCY => DEV_CAP_ENDPOINT_L0S_LATENCY,
        DEV_CAP_ENDPOINT_L1_LATENCY => DEV_CAP_ENDPOINT_L1_LATENCY,
        DEV_CAP_EXT_TAG_SUPPORTED => DEV_CAP_EXT_TAG_SUPPORTED,
        DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE => DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE,
        DEV_CAP_MAX_PAYLOAD_SUPPORTED => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
        DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT => DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT,
        DEV_CAP_ROLE_BASED_ERROR => DEV_CAP_ROLE_BASED_ERROR,
        DEV_CAP_RSVD_14_12   => DEV_CAP_RSVD_14_12,
        DEV_CAP_RSVD_17_16   => DEV_CAP_RSVD_17_16,
        DEV_CAP_RSVD_31_29   => DEV_CAP_RSVD_31_29,
        DEV_CONTROL_AUX_POWER_SUPPORTED => DEV_CONTROL_AUX_POWER_SUPPORTED,
        DEV_CONTROL_EXT_TAG_DEFAULT => DEV_CONTROL_EXT_TAG_DEFAULT,
        DISABLE_ASPM_L1_TIMER => DISABLE_ASPM_L1_TIMER,
        DISABLE_BAR_FILTERING => DISABLE_BAR_FILTERING,
        DISABLE_ERR_MSG      => DISABLE_ERR_MSG,
        DISABLE_ID_CHECK     => DISABLE_ID_CHECK,
        DISABLE_LANE_REVERSAL => DISABLE_LANE_REVERSAL,
        DISABLE_LOCKED_FILTER => DISABLE_LOCKED_FILTER,
        DISABLE_PPM_FILTER   => DISABLE_PPM_FILTER,
        DISABLE_RX_POISONED_RESP => DISABLE_RX_POISONED_RESP,
        DISABLE_RX_TC_FILTER => DISABLE_RX_TC_FILTER,
        DISABLE_SCRAMBLING   => DISABLE_SCRAMBLING,
        DNSTREAM_LINK_NUM    => DNSTREAM_LINK_NUM_STRING,
        DSN_BASE_PTR         => DSN_BASE_PTR_STRING,
        DSN_CAP_ID           => DSN_CAP_ID_STRING,
        DSN_CAP_NEXTPTR      => DSN_CAP_NEXTPTR_STRING,
        DSN_CAP_ON           => DSN_CAP_ON,
        DSN_CAP_VERSION      => DSN_CAP_VERSION_STRING,
        ENABLE_MSG_ROUTE     => ENABLE_MSG_ROUTE_STRING,
        ENABLE_RX_TD_ECRC_TRIM => ENABLE_RX_TD_ECRC_TRIM,
        ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED => ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED,
        ENTER_RVRY_EI_L0     => ENTER_RVRY_EI_L0,
        EXIT_LOOPBACK_ON_EI  => EXIT_LOOPBACK_ON_EI,
        EXPANSION_ROM        => EXPANSION_ROM_STRING,
        EXT_CFG_CAP_PTR      => EXT_CFG_CAP_PTR_STRING,
        EXT_CFG_XP_CAP_PTR   => EXT_CFG_XP_CAP_PTR_STRING,
        HEADER_TYPE          => HEADER_TYPE_STRING,
        INFER_EI             => INFER_EI_STRING,
        INTERRUPT_PIN        => INTERRUPT_PIN_STRING,
        INTERRUPT_STAT_AUTO  => INTERRUPT_STAT_AUTO,
        IS_SWITCH            => IS_SWITCH,
        LAST_CONFIG_DWORD    => LAST_CONFIG_DWORD_STRING,
        LINK_CAP_ASPM_OPTIONALITY => LINK_CAP_ASPM_OPTIONALITY,
        LINK_CAP_ASPM_SUPPORT => LINK_CAP_ASPM_SUPPORT,
        LINK_CAP_CLOCK_POWER_MANAGEMENT => LINK_CAP_CLOCK_POWER_MANAGEMENT,
        LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP => LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP,
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1,
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2,
        LINK_CAP_L0S_EXIT_LATENCY_GEN1 => LINK_CAP_L0S_EXIT_LATENCY_GEN1,
        LINK_CAP_L0S_EXIT_LATENCY_GEN2 => LINK_CAP_L0S_EXIT_LATENCY_GEN2,
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1,
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2,
        LINK_CAP_L1_EXIT_LATENCY_GEN1 => LINK_CAP_L1_EXIT_LATENCY_GEN1,
        LINK_CAP_L1_EXIT_LATENCY_GEN2 => LINK_CAP_L1_EXIT_LATENCY_GEN2,
        LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP => LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP,
        LINK_CAP_MAX_LINK_SPEED => LINK_CAP_MAX_LINK_SPEED_STRING,
        LINK_CAP_MAX_LINK_WIDTH => LINK_CAP_MAX_LINK_WIDTH_STRING,
        LINK_CAP_RSVD_23     => LINK_CAP_RSVD_23,
        LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE => LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE,
        LINK_CONTROL_RCB     => LINK_CONTROL_RCB,
        LINK_CTRL2_DEEMPHASIS => LINK_CTRL2_DEEMPHASIS,
        LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE => LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE,
        LINK_CTRL2_TARGET_LINK_SPEED => LINK_CTRL2_TARGET_LINK_SPEED_STRING,
        LINK_STATUS_SLOT_CLOCK_CONFIG => LINK_STATUS_SLOT_CLOCK_CONFIG,
        LL_ACK_TIMEOUT       => LL_ACK_TIMEOUT_STRING,
        LL_ACK_TIMEOUT_EN    => LL_ACK_TIMEOUT_EN,
        LL_ACK_TIMEOUT_FUNC  => LL_ACK_TIMEOUT_FUNC,
        LL_REPLAY_TIMEOUT    => LL_REPLAY_TIMEOUT_STRING,
        LL_REPLAY_TIMEOUT_EN => LL_REPLAY_TIMEOUT_EN,
        LL_REPLAY_TIMEOUT_FUNC => LL_REPLAY_TIMEOUT_FUNC,
        LTSSM_MAX_LINK_WIDTH => LTSSM_MAX_LINK_WIDTH_STRING,
        MPS_FORCE            => MPS_FORCE,
        MSIX_BASE_PTR        => MSIX_BASE_PTR_STRING,
        MSIX_CAP_ID          => MSIX_CAP_ID_STRING,
        MSIX_CAP_NEXTPTR     => MSIX_CAP_NEXTPTR_STRING,
        MSIX_CAP_ON          => MSIX_CAP_ON,
        MSIX_CAP_PBA_BIR     => MSIX_CAP_PBA_BIR,
        MSIX_CAP_PBA_OFFSET  => MSIX_CAP_PBA_OFFSET_STRING,
        MSIX_CAP_TABLE_BIR   => MSIX_CAP_TABLE_BIR,
        MSIX_CAP_TABLE_OFFSET => MSIX_CAP_TABLE_OFFSET_STRING,
        MSIX_CAP_TABLE_SIZE  => MSIX_CAP_TABLE_SIZE_STRING,
        MSI_BASE_PTR         => MSI_BASE_PTR_STRING,
        MSI_CAP_64_BIT_ADDR_CAPABLE => MSI_CAP_64_BIT_ADDR_CAPABLE,
        MSI_CAP_ID           => MSI_CAP_ID_STRING,
        MSI_CAP_MULTIMSGCAP  => MSI_CAP_MULTIMSGCAP,
        MSI_CAP_MULTIMSG_EXTENSION => MSI_CAP_MULTIMSG_EXTENSION,
        MSI_CAP_NEXTPTR      => MSI_CAP_NEXTPTR_STRING,
        MSI_CAP_ON           => MSI_CAP_ON,
        MSI_CAP_PER_VECTOR_MASKING_CAPABLE => MSI_CAP_PER_VECTOR_MASKING_CAPABLE,
        N_FTS_COMCLK_GEN1    => N_FTS_COMCLK_GEN1,
        N_FTS_COMCLK_GEN2    => N_FTS_COMCLK_GEN2,
        N_FTS_GEN1           => N_FTS_GEN1,
        N_FTS_GEN2           => N_FTS_GEN2,
        PCIE_BASE_PTR        => PCIE_BASE_PTR_STRING,
        PCIE_CAP_CAPABILITY_ID => PCIE_CAP_CAPABILITY_ID_STRING,
        PCIE_CAP_CAPABILITY_VERSION => PCIE_CAP_CAPABILITY_VERSION_STRING,
        PCIE_CAP_DEVICE_PORT_TYPE => PCIE_CAP_DEVICE_PORT_TYPE_STRING,
        PCIE_CAP_NEXTPTR     => PCIE_CAP_NEXTPTR_STRING,
        PCIE_CAP_ON          => PCIE_CAP_ON,
        PCIE_CAP_RSVD_15_14  => PCIE_CAP_RSVD_15_14,
        PCIE_CAP_SLOT_IMPLEMENTED => PCIE_CAP_SLOT_IMPLEMENTED,
        PCIE_REVISION        => PCIE_REVISION,
        PL_AUTO_CONFIG       => PL_AUTO_CONFIG,
        PL_FAST_TRAIN        => PL_FAST_TRAIN,
        PM_ASPML0S_TIMEOUT   => PM_ASPML0S_TIMEOUT_STRING,
        PM_ASPML0S_TIMEOUT_EN => PM_ASPML0S_TIMEOUT_EN,
        PM_ASPML0S_TIMEOUT_FUNC => PM_ASPML0S_TIMEOUT_FUNC,
        PM_ASPM_FASTEXIT     => PM_ASPM_FASTEXIT,
        PM_BASE_PTR          => PM_BASE_PTR_STRING,
        PM_CAP_AUXCURRENT    => PM_CAP_AUXCURRENT,
        PM_CAP_D1SUPPORT     => PM_CAP_D1SUPPORT,
        PM_CAP_D2SUPPORT     => PM_CAP_D2SUPPORT,
        PM_CAP_DSI           => PM_CAP_DSI,
        PM_CAP_ID            => PM_CAP_ID_STRING,
        PM_CAP_NEXTPTR       => PM_CAP_NEXTPTR_STRING,
        PM_CAP_ON            => PM_CAP_ON,
        PM_CAP_PMESUPPORT    => PM_CAP_PMESUPPORT_STRING,
        PM_CAP_PME_CLOCK     => PM_CAP_PME_CLOCK,
        PM_CAP_RSVD_04       => PM_CAP_RSVD_04,
        PM_CAP_VERSION       => PM_CAP_VERSION,
        PM_CSR_B2B3          => PM_CSR_B2B3,
        PM_CSR_BPCCEN        => PM_CSR_BPCCEN,
        PM_CSR_NOSOFTRST     => PM_CSR_NOSOFTRST,
        PM_DATA0             => PM_DATA0_STRING,
        PM_DATA1             => PM_DATA1_STRING,
        PM_DATA2             => PM_DATA2_STRING,
        PM_DATA3             => PM_DATA3_STRING,
        PM_DATA4             => PM_DATA4_STRING,
        PM_DATA5             => PM_DATA5_STRING,
        PM_DATA6             => PM_DATA6_STRING,
        PM_DATA7             => PM_DATA7_STRING,
        PM_DATA_SCALE0       => PM_DATA_SCALE0_STRING,
        PM_DATA_SCALE1       => PM_DATA_SCALE1_STRING,
        PM_DATA_SCALE2       => PM_DATA_SCALE2_STRING,
        PM_DATA_SCALE3       => PM_DATA_SCALE3_STRING,
        PM_DATA_SCALE4       => PM_DATA_SCALE4_STRING,
        PM_DATA_SCALE5       => PM_DATA_SCALE5_STRING,
        PM_DATA_SCALE6       => PM_DATA_SCALE6_STRING,
        PM_DATA_SCALE7       => PM_DATA_SCALE7_STRING,
        PM_MF                => PM_MF,
        RBAR_BASE_PTR        => RBAR_BASE_PTR_STRING,
        RBAR_CAP_CONTROL_ENCODEDBAR0 => RBAR_CAP_CONTROL_ENCODEDBAR0_STRING,
        RBAR_CAP_CONTROL_ENCODEDBAR1 => RBAR_CAP_CONTROL_ENCODEDBAR1_STRING,
        RBAR_CAP_CONTROL_ENCODEDBAR2 => RBAR_CAP_CONTROL_ENCODEDBAR2_STRING,
        RBAR_CAP_CONTROL_ENCODEDBAR3 => RBAR_CAP_CONTROL_ENCODEDBAR3_STRING,
        RBAR_CAP_CONTROL_ENCODEDBAR4 => RBAR_CAP_CONTROL_ENCODEDBAR4_STRING,
        RBAR_CAP_CONTROL_ENCODEDBAR5 => RBAR_CAP_CONTROL_ENCODEDBAR5_STRING,
        RBAR_CAP_ID          => RBAR_CAP_ID_STRING,
        RBAR_CAP_INDEX0      => RBAR_CAP_INDEX0_STRING,
        RBAR_CAP_INDEX1      => RBAR_CAP_INDEX1_STRING,
        RBAR_CAP_INDEX2      => RBAR_CAP_INDEX2_STRING,
        RBAR_CAP_INDEX3      => RBAR_CAP_INDEX3_STRING,
        RBAR_CAP_INDEX4      => RBAR_CAP_INDEX4_STRING,
        RBAR_CAP_INDEX5      => RBAR_CAP_INDEX5_STRING,
        RBAR_CAP_NEXTPTR     => RBAR_CAP_NEXTPTR_STRING,
        RBAR_CAP_ON          => RBAR_CAP_ON,
        RBAR_CAP_SUP0        => RBAR_CAP_SUP0_STRING,
        RBAR_CAP_SUP1        => RBAR_CAP_SUP1_STRING,
        RBAR_CAP_SUP2        => RBAR_CAP_SUP2_STRING,
        RBAR_CAP_SUP3        => RBAR_CAP_SUP3_STRING,
        RBAR_CAP_SUP4        => RBAR_CAP_SUP4_STRING,
        RBAR_CAP_SUP5        => RBAR_CAP_SUP5_STRING,
        RBAR_CAP_VERSION     => RBAR_CAP_VERSION_STRING,
        RBAR_NUM             => RBAR_NUM_STRING,
        RECRC_CHK            => RECRC_CHK,
        RECRC_CHK_TRIM       => RECRC_CHK_TRIM,
        ROOT_CAP_CRS_SW_VISIBILITY => ROOT_CAP_CRS_SW_VISIBILITY,
        RP_AUTO_SPD          => RP_AUTO_SPD_STRING,
        RP_AUTO_SPD_LOOPCNT  => RP_AUTO_SPD_LOOPCNT_STRING,
        SELECT_DLL_IF        => SELECT_DLL_IF,
        SIM_VERSION          => SIM_VERSION,
        SLOT_CAP_ATT_BUTTON_PRESENT => SLOT_CAP_ATT_BUTTON_PRESENT,
        SLOT_CAP_ATT_INDICATOR_PRESENT => SLOT_CAP_ATT_INDICATOR_PRESENT,
        SLOT_CAP_ELEC_INTERLOCK_PRESENT => SLOT_CAP_ELEC_INTERLOCK_PRESENT,
        SLOT_CAP_HOTPLUG_CAPABLE => SLOT_CAP_HOTPLUG_CAPABLE,
        SLOT_CAP_HOTPLUG_SURPRISE => SLOT_CAP_HOTPLUG_SURPRISE,
        SLOT_CAP_MRL_SENSOR_PRESENT => SLOT_CAP_MRL_SENSOR_PRESENT,
        SLOT_CAP_NO_CMD_COMPLETED_SUPPORT => SLOT_CAP_NO_CMD_COMPLETED_SUPPORT,
        SLOT_CAP_PHYSICAL_SLOT_NUM => SLOT_CAP_PHYSICAL_SLOT_NUM_STRING,
        SLOT_CAP_POWER_CONTROLLER_PRESENT => SLOT_CAP_POWER_CONTROLLER_PRESENT,
        SLOT_CAP_POWER_INDICATOR_PRESENT => SLOT_CAP_POWER_INDICATOR_PRESENT,
        SLOT_CAP_SLOT_POWER_LIMIT_SCALE => SLOT_CAP_SLOT_POWER_LIMIT_SCALE,
        SLOT_CAP_SLOT_POWER_LIMIT_VALUE => SLOT_CAP_SLOT_POWER_LIMIT_VALUE_STRING,
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
        SSL_MESSAGE_AUTO     => SSL_MESSAGE_AUTO,
        TECRC_EP_INV         => TECRC_EP_INV,
        TL_RBYPASS           => TL_RBYPASS,
        TL_RX_RAM_RADDR_LATENCY => TL_RX_RAM_RADDR_LATENCY,
        TL_RX_RAM_RDATA_LATENCY => TL_RX_RAM_RDATA_LATENCY,
        TL_RX_RAM_WRITE_LATENCY => TL_RX_RAM_WRITE_LATENCY,
        TL_TFC_DISABLE       => TL_TFC_DISABLE,
        TL_TX_CHECKS_DISABLE => TL_TX_CHECKS_DISABLE,
        TL_TX_RAM_RADDR_LATENCY => TL_TX_RAM_RADDR_LATENCY,
        TL_TX_RAM_RDATA_LATENCY => TL_TX_RAM_RDATA_LATENCY,
        TL_TX_RAM_WRITE_LATENCY => TL_TX_RAM_WRITE_LATENCY,
        TRN_DW               => TRN_DW,
        TRN_NP_FC            => TRN_NP_FC,
        UPCONFIG_CAPABLE     => UPCONFIG_CAPABLE,
        UPSTREAM_FACING      => UPSTREAM_FACING,
        UR_ATOMIC            => UR_ATOMIC,
        UR_CFG1              => UR_CFG1,
        UR_INV_REQ           => UR_INV_REQ,
        UR_PRS_RESPONSE      => UR_PRS_RESPONSE,
        USER_CLK2_DIV2       => USER_CLK2_DIV2,
        USER_CLK_FREQ        => USER_CLK_FREQ,
        USE_RID_PINS         => USE_RID_PINS,
        VC0_CPL_INFINITE     => VC0_CPL_INFINITE,
        VC0_RX_RAM_LIMIT     => VC0_RX_RAM_LIMIT_STRING,
        VC0_TOTAL_CREDITS_CD => VC0_TOTAL_CREDITS_CD,
        VC0_TOTAL_CREDITS_CH => VC0_TOTAL_CREDITS_CH,
        VC0_TOTAL_CREDITS_NPD => VC0_TOTAL_CREDITS_NPD,
        VC0_TOTAL_CREDITS_NPH => VC0_TOTAL_CREDITS_NPH,
        VC0_TOTAL_CREDITS_PD => VC0_TOTAL_CREDITS_PD,
        VC0_TOTAL_CREDITS_PH => VC0_TOTAL_CREDITS_PH,
        VC0_TX_LASTPACKET    => VC0_TX_LASTPACKET,
        VC_BASE_PTR          => VC_BASE_PTR_STRING,
        VC_CAP_ID            => VC_CAP_ID_STRING,
        VC_CAP_NEXTPTR       => VC_CAP_NEXTPTR_STRING,
        VC_CAP_ON            => VC_CAP_ON,
        VC_CAP_REJECT_SNOOP_TRANSACTIONS => VC_CAP_REJECT_SNOOP_TRANSACTIONS,
        VC_CAP_VERSION       => VC_CAP_VERSION_STRING,
        VSEC_BASE_PTR        => VSEC_BASE_PTR_STRING,
        VSEC_CAP_HDR_ID      => VSEC_CAP_HDR_ID_STRING,
        VSEC_CAP_HDR_LENGTH  => VSEC_CAP_HDR_LENGTH_STRING,
        VSEC_CAP_HDR_REVISION => VSEC_CAP_HDR_REVISION_STRING,
        VSEC_CAP_ID          => VSEC_CAP_ID_STRING,
        VSEC_CAP_IS_LINK_VISIBLE => VSEC_CAP_IS_LINK_VISIBLE,
        VSEC_CAP_NEXTPTR     => VSEC_CAP_NEXTPTR_STRING,
        VSEC_CAP_ON          => VSEC_CAP_ON,
        VSEC_CAP_VERSION     => VSEC_CAP_VERSION_STRING
      )
      
      port map (
        CFGAERECRCCHECKEN    => CFGAERECRCCHECKEN_outdelay,
        CFGAERECRCGENEN      => CFGAERECRCGENEN_outdelay,
        CFGAERROOTERRCORRERRRECEIVED => CFGAERROOTERRCORRERRRECEIVED_outdelay,
        CFGAERROOTERRCORRERRREPORTINGEN => CFGAERROOTERRCORRERRREPORTINGEN_outdelay,
        CFGAERROOTERRFATALERRRECEIVED => CFGAERROOTERRFATALERRRECEIVED_outdelay,
        CFGAERROOTERRFATALERRREPORTINGEN => CFGAERROOTERRFATALERRREPORTINGEN_outdelay,
        CFGAERROOTERRNONFATALERRRECEIVED => CFGAERROOTERRNONFATALERRRECEIVED_outdelay,
        CFGAERROOTERRNONFATALERRREPORTINGEN => CFGAERROOTERRNONFATALERRREPORTINGEN_outdelay,
        CFGBRIDGESERREN      => CFGBRIDGESERREN_outdelay,
        CFGCOMMANDBUSMASTERENABLE => CFGCOMMANDBUSMASTERENABLE_outdelay,
        CFGCOMMANDINTERRUPTDISABLE => CFGCOMMANDINTERRUPTDISABLE_outdelay,
        CFGCOMMANDIOENABLE   => CFGCOMMANDIOENABLE_outdelay,
        CFGCOMMANDMEMENABLE  => CFGCOMMANDMEMENABLE_outdelay,
        CFGCOMMANDSERREN     => CFGCOMMANDSERREN_outdelay,
        CFGDEVCONTROL2ARIFORWARDEN => CFGDEVCONTROL2ARIFORWARDEN_outdelay,
        CFGDEVCONTROL2ATOMICEGRESSBLOCK => CFGDEVCONTROL2ATOMICEGRESSBLOCK_outdelay,
        CFGDEVCONTROL2ATOMICREQUESTEREN => CFGDEVCONTROL2ATOMICREQUESTEREN_outdelay,
        CFGDEVCONTROL2CPLTIMEOUTDIS => CFGDEVCONTROL2CPLTIMEOUTDIS_outdelay,
        CFGDEVCONTROL2CPLTIMEOUTVAL => CFGDEVCONTROL2CPLTIMEOUTVAL_outdelay,
        CFGDEVCONTROL2IDOCPLEN => CFGDEVCONTROL2IDOCPLEN_outdelay,
        CFGDEVCONTROL2IDOREQEN => CFGDEVCONTROL2IDOREQEN_outdelay,
        CFGDEVCONTROL2LTREN  => CFGDEVCONTROL2LTREN_outdelay,
        CFGDEVCONTROL2TLPPREFIXBLOCK => CFGDEVCONTROL2TLPPREFIXBLOCK_outdelay,
        CFGDEVCONTROLAUXPOWEREN => CFGDEVCONTROLAUXPOWEREN_outdelay,
        CFGDEVCONTROLCORRERRREPORTINGEN => CFGDEVCONTROLCORRERRREPORTINGEN_outdelay,
        CFGDEVCONTROLENABLERO => CFGDEVCONTROLENABLERO_outdelay,
        CFGDEVCONTROLEXTTAGEN => CFGDEVCONTROLEXTTAGEN_outdelay,
        CFGDEVCONTROLFATALERRREPORTINGEN => CFGDEVCONTROLFATALERRREPORTINGEN_outdelay,
        CFGDEVCONTROLMAXPAYLOAD => CFGDEVCONTROLMAXPAYLOAD_outdelay,
        CFGDEVCONTROLMAXREADREQ => CFGDEVCONTROLMAXREADREQ_outdelay,
        CFGDEVCONTROLNONFATALREPORTINGEN => CFGDEVCONTROLNONFATALREPORTINGEN_outdelay,
        CFGDEVCONTROLNOSNOOPEN => CFGDEVCONTROLNOSNOOPEN_outdelay,
        CFGDEVCONTROLPHANTOMEN => CFGDEVCONTROLPHANTOMEN_outdelay,
        CFGDEVCONTROLURERRREPORTINGEN => CFGDEVCONTROLURERRREPORTINGEN_outdelay,
        CFGDEVSTATUSCORRERRDETECTED => CFGDEVSTATUSCORRERRDETECTED_outdelay,
        CFGDEVSTATUSFATALERRDETECTED => CFGDEVSTATUSFATALERRDETECTED_outdelay,
        CFGDEVSTATUSNONFATALERRDETECTED => CFGDEVSTATUSNONFATALERRDETECTED_outdelay,
        CFGDEVSTATUSURDETECTED => CFGDEVSTATUSURDETECTED_outdelay,
        CFGERRAERHEADERLOGSETN => CFGERRAERHEADERLOGSETN_outdelay,
        CFGERRCPLRDYN        => CFGERRCPLRDYN_outdelay,
        CFGINTERRUPTDO       => CFGINTERRUPTDO_outdelay,
        CFGINTERRUPTMMENABLE => CFGINTERRUPTMMENABLE_outdelay,
        CFGINTERRUPTMSIENABLE => CFGINTERRUPTMSIENABLE_outdelay,
        CFGINTERRUPTMSIXENABLE => CFGINTERRUPTMSIXENABLE_outdelay,
        CFGINTERRUPTMSIXFM   => CFGINTERRUPTMSIXFM_outdelay,
        CFGINTERRUPTRDYN     => CFGINTERRUPTRDYN_outdelay,
        CFGLINKCONTROLASPMCONTROL => CFGLINKCONTROLASPMCONTROL_outdelay,
        CFGLINKCONTROLAUTOBANDWIDTHINTEN => CFGLINKCONTROLAUTOBANDWIDTHINTEN_outdelay,
        CFGLINKCONTROLBANDWIDTHINTEN => CFGLINKCONTROLBANDWIDTHINTEN_outdelay,
        CFGLINKCONTROLCLOCKPMEN => CFGLINKCONTROLCLOCKPMEN_outdelay,
        CFGLINKCONTROLCOMMONCLOCK => CFGLINKCONTROLCOMMONCLOCK_outdelay,
        CFGLINKCONTROLEXTENDEDSYNC => CFGLINKCONTROLEXTENDEDSYNC_outdelay,
        CFGLINKCONTROLHWAUTOWIDTHDIS => CFGLINKCONTROLHWAUTOWIDTHDIS_outdelay,
        CFGLINKCONTROLLINKDISABLE => CFGLINKCONTROLLINKDISABLE_outdelay,
        CFGLINKCONTROLRCB    => CFGLINKCONTROLRCB_outdelay,
        CFGLINKCONTROLRETRAINLINK => CFGLINKCONTROLRETRAINLINK_outdelay,
        CFGLINKSTATUSAUTOBANDWIDTHSTATUS => CFGLINKSTATUSAUTOBANDWIDTHSTATUS_outdelay,
        CFGLINKSTATUSBANDWIDTHSTATUS => CFGLINKSTATUSBANDWIDTHSTATUS_outdelay,
        CFGLINKSTATUSCURRENTSPEED => CFGLINKSTATUSCURRENTSPEED_outdelay,
        CFGLINKSTATUSDLLACTIVE => CFGLINKSTATUSDLLACTIVE_outdelay,
        CFGLINKSTATUSLINKTRAINING => CFGLINKSTATUSLINKTRAINING_outdelay,
        CFGLINKSTATUSNEGOTIATEDWIDTH => CFGLINKSTATUSNEGOTIATEDWIDTH_outdelay,
        CFGMGMTDO            => CFGMGMTDO_outdelay,
        CFGMGMTRDWRDONEN     => CFGMGMTRDWRDONEN_outdelay,
        CFGMSGDATA           => CFGMSGDATA_outdelay,
        CFGMSGRECEIVED       => CFGMSGRECEIVED_outdelay,
        CFGMSGRECEIVEDASSERTINTA => CFGMSGRECEIVEDASSERTINTA_outdelay,
        CFGMSGRECEIVEDASSERTINTB => CFGMSGRECEIVEDASSERTINTB_outdelay,
        CFGMSGRECEIVEDASSERTINTC => CFGMSGRECEIVEDASSERTINTC_outdelay,
        CFGMSGRECEIVEDASSERTINTD => CFGMSGRECEIVEDASSERTINTD_outdelay,
        CFGMSGRECEIVEDDEASSERTINTA => CFGMSGRECEIVEDDEASSERTINTA_outdelay,
        CFGMSGRECEIVEDDEASSERTINTB => CFGMSGRECEIVEDDEASSERTINTB_outdelay,
        CFGMSGRECEIVEDDEASSERTINTC => CFGMSGRECEIVEDDEASSERTINTC_outdelay,
        CFGMSGRECEIVEDDEASSERTINTD => CFGMSGRECEIVEDDEASSERTINTD_outdelay,
        CFGMSGRECEIVEDERRCOR => CFGMSGRECEIVEDERRCOR_outdelay,
        CFGMSGRECEIVEDERRFATAL => CFGMSGRECEIVEDERRFATAL_outdelay,
        CFGMSGRECEIVEDERRNONFATAL => CFGMSGRECEIVEDERRNONFATAL_outdelay,
        CFGMSGRECEIVEDPMASNAK => CFGMSGRECEIVEDPMASNAK_outdelay,
        CFGMSGRECEIVEDPMETO  => CFGMSGRECEIVEDPMETO_outdelay,
        CFGMSGRECEIVEDPMETOACK => CFGMSGRECEIVEDPMETOACK_outdelay,
        CFGMSGRECEIVEDPMPME  => CFGMSGRECEIVEDPMPME_outdelay,
        CFGMSGRECEIVEDSETSLOTPOWERLIMIT => CFGMSGRECEIVEDSETSLOTPOWERLIMIT_outdelay,
        CFGMSGRECEIVEDUNLOCK => CFGMSGRECEIVEDUNLOCK_outdelay,
        CFGPCIELINKSTATE     => CFGPCIELINKSTATE_outdelay,
        CFGPMCSRPMEEN        => CFGPMCSRPMEEN_outdelay,
        CFGPMCSRPMESTATUS    => CFGPMCSRPMESTATUS_outdelay,
        CFGPMCSRPOWERSTATE   => CFGPMCSRPOWERSTATE_outdelay,
        CFGPMRCVASREQL1N     => CFGPMRCVASREQL1N_outdelay,
        CFGPMRCVENTERL1N     => CFGPMRCVENTERL1N_outdelay,
        CFGPMRCVENTERL23N    => CFGPMRCVENTERL23N_outdelay,
        CFGPMRCVREQACKN      => CFGPMRCVREQACKN_outdelay,
        CFGROOTCONTROLPMEINTEN => CFGROOTCONTROLPMEINTEN_outdelay,
        CFGROOTCONTROLSYSERRCORRERREN => CFGROOTCONTROLSYSERRCORRERREN_outdelay,
        CFGROOTCONTROLSYSERRFATALERREN => CFGROOTCONTROLSYSERRFATALERREN_outdelay,
        CFGROOTCONTROLSYSERRNONFATALERREN => CFGROOTCONTROLSYSERRNONFATALERREN_outdelay,
        CFGSLOTCONTROLELECTROMECHILCTLPULSE => CFGSLOTCONTROLELECTROMECHILCTLPULSE_outdelay,
        CFGTRANSACTION       => CFGTRANSACTION_outdelay,
        CFGTRANSACTIONADDR   => CFGTRANSACTIONADDR_outdelay,
        CFGTRANSACTIONTYPE   => CFGTRANSACTIONTYPE_outdelay,
        CFGVCTCVCMAP         => CFGVCTCVCMAP_outdelay,
        DBGSCLRA             => DBGSCLRA_outdelay,
        DBGSCLRB             => DBGSCLRB_outdelay,
        DBGSCLRC             => DBGSCLRC_outdelay,
        DBGSCLRD             => DBGSCLRD_outdelay,
        DBGSCLRE             => DBGSCLRE_outdelay,
        DBGSCLRF             => DBGSCLRF_outdelay,
        DBGSCLRG             => DBGSCLRG_outdelay,
        DBGSCLRH             => DBGSCLRH_outdelay,
        DBGSCLRI             => DBGSCLRI_outdelay,
        DBGSCLRJ             => DBGSCLRJ_outdelay,
        DBGSCLRK             => DBGSCLRK_outdelay,
        DBGVECA              => DBGVECA_outdelay,
        DBGVECB              => DBGVECB_outdelay,
        DBGVECC              => DBGVECC_outdelay,
        DRPDO                => DRPDO_outdelay,
        DRPRDY               => DRPRDY_outdelay,
        LL2BADDLLPERR        => LL2BADDLLPERR_outdelay,
        LL2BADTLPERR         => LL2BADTLPERR_outdelay,
        LL2LINKSTATUS        => LL2LINKSTATUS_outdelay,
        LL2PROTOCOLERR       => LL2PROTOCOLERR_outdelay,
        LL2RECEIVERERR       => LL2RECEIVERERR_outdelay,
        LL2REPLAYROERR       => LL2REPLAYROERR_outdelay,
        LL2REPLAYTOERR       => LL2REPLAYTOERR_outdelay,
        LL2SUSPENDOK         => LL2SUSPENDOK_outdelay,
        LL2TFCINIT1SEQ       => LL2TFCINIT1SEQ_outdelay,
        LL2TFCINIT2SEQ       => LL2TFCINIT2SEQ_outdelay,
        LL2TXIDLE            => LL2TXIDLE_outdelay,
        LNKCLKEN             => LNKCLKEN_outdelay,
        MIMRXRADDR           => MIMRXRADDR_outdelay,
        MIMRXREN             => MIMRXREN_outdelay,
        MIMRXWADDR           => MIMRXWADDR_outdelay,
        MIMRXWDATA           => MIMRXWDATA_outdelay,
        MIMRXWEN             => MIMRXWEN_outdelay,
        MIMTXRADDR           => MIMTXRADDR_outdelay,
        MIMTXREN             => MIMTXREN_outdelay,
        MIMTXWADDR           => MIMTXWADDR_outdelay,
        MIMTXWDATA           => MIMTXWDATA_outdelay,
        MIMTXWEN             => MIMTXWEN_outdelay,
        PIPERX0POLARITY      => PIPERX0POLARITY_outdelay,
        PIPERX1POLARITY      => PIPERX1POLARITY_outdelay,
        PIPERX2POLARITY      => PIPERX2POLARITY_outdelay,
        PIPERX3POLARITY      => PIPERX3POLARITY_outdelay,
        PIPERX4POLARITY      => PIPERX4POLARITY_outdelay,
        PIPERX5POLARITY      => PIPERX5POLARITY_outdelay,
        PIPERX6POLARITY      => PIPERX6POLARITY_outdelay,
        PIPERX7POLARITY      => PIPERX7POLARITY_outdelay,
        PIPETX0CHARISK       => PIPETX0CHARISK_outdelay,
        PIPETX0COMPLIANCE    => PIPETX0COMPLIANCE_outdelay,
        PIPETX0DATA          => PIPETX0DATA_outdelay,
        PIPETX0ELECIDLE      => PIPETX0ELECIDLE_outdelay,
        PIPETX0POWERDOWN     => PIPETX0POWERDOWN_outdelay,
        PIPETX1CHARISK       => PIPETX1CHARISK_outdelay,
        PIPETX1COMPLIANCE    => PIPETX1COMPLIANCE_outdelay,
        PIPETX1DATA          => PIPETX1DATA_outdelay,
        PIPETX1ELECIDLE      => PIPETX1ELECIDLE_outdelay,
        PIPETX1POWERDOWN     => PIPETX1POWERDOWN_outdelay,
        PIPETX2CHARISK       => PIPETX2CHARISK_outdelay,
        PIPETX2COMPLIANCE    => PIPETX2COMPLIANCE_outdelay,
        PIPETX2DATA          => PIPETX2DATA_outdelay,
        PIPETX2ELECIDLE      => PIPETX2ELECIDLE_outdelay,
        PIPETX2POWERDOWN     => PIPETX2POWERDOWN_outdelay,
        PIPETX3CHARISK       => PIPETX3CHARISK_outdelay,
        PIPETX3COMPLIANCE    => PIPETX3COMPLIANCE_outdelay,
        PIPETX3DATA          => PIPETX3DATA_outdelay,
        PIPETX3ELECIDLE      => PIPETX3ELECIDLE_outdelay,
        PIPETX3POWERDOWN     => PIPETX3POWERDOWN_outdelay,
        PIPETX4CHARISK       => PIPETX4CHARISK_outdelay,
        PIPETX4COMPLIANCE    => PIPETX4COMPLIANCE_outdelay,
        PIPETX4DATA          => PIPETX4DATA_outdelay,
        PIPETX4ELECIDLE      => PIPETX4ELECIDLE_outdelay,
        PIPETX4POWERDOWN     => PIPETX4POWERDOWN_outdelay,
        PIPETX5CHARISK       => PIPETX5CHARISK_outdelay,
        PIPETX5COMPLIANCE    => PIPETX5COMPLIANCE_outdelay,
        PIPETX5DATA          => PIPETX5DATA_outdelay,
        PIPETX5ELECIDLE      => PIPETX5ELECIDLE_outdelay,
        PIPETX5POWERDOWN     => PIPETX5POWERDOWN_outdelay,
        PIPETX6CHARISK       => PIPETX6CHARISK_outdelay,
        PIPETX6COMPLIANCE    => PIPETX6COMPLIANCE_outdelay,
        PIPETX6DATA          => PIPETX6DATA_outdelay,
        PIPETX6ELECIDLE      => PIPETX6ELECIDLE_outdelay,
        PIPETX6POWERDOWN     => PIPETX6POWERDOWN_outdelay,
        PIPETX7CHARISK       => PIPETX7CHARISK_outdelay,
        PIPETX7COMPLIANCE    => PIPETX7COMPLIANCE_outdelay,
        PIPETX7DATA          => PIPETX7DATA_outdelay,
        PIPETX7ELECIDLE      => PIPETX7ELECIDLE_outdelay,
        PIPETX7POWERDOWN     => PIPETX7POWERDOWN_outdelay,
        PIPETXDEEMPH         => PIPETXDEEMPH_outdelay,
        PIPETXMARGIN         => PIPETXMARGIN_outdelay,
        PIPETXRATE           => PIPETXRATE_outdelay,
        PIPETXRCVRDET        => PIPETXRCVRDET_outdelay,
        PIPETXRESET          => PIPETXRESET_outdelay,
        PL2L0REQ             => PL2L0REQ_outdelay,
        PL2LINKUP            => PL2LINKUP_outdelay,
        PL2RECEIVERERR       => PL2RECEIVERERR_outdelay,
        PL2RECOVERY          => PL2RECOVERY_outdelay,
        PL2RXELECIDLE        => PL2RXELECIDLE_outdelay,
        PL2RXPMSTATE         => PL2RXPMSTATE_outdelay,
        PL2SUSPENDOK         => PL2SUSPENDOK_outdelay,
        PLDBGVEC             => PLDBGVEC_outdelay,
        PLDIRECTEDCHANGEDONE => PLDIRECTEDCHANGEDONE_outdelay,
        PLINITIALLINKWIDTH   => PLINITIALLINKWIDTH_outdelay,
        PLLANEREVERSALMODE   => PLLANEREVERSALMODE_outdelay,
        PLLINKGEN2CAP        => PLLINKGEN2CAP_outdelay,
        PLLINKPARTNERGEN2SUPPORTED => PLLINKPARTNERGEN2SUPPORTED_outdelay,
        PLLINKUPCFGCAP       => PLLINKUPCFGCAP_outdelay,
        PLLTSSMSTATE         => PLLTSSMSTATE_outdelay,
        PLPHYLNKUPN          => PLPHYLNKUPN_outdelay,
        PLRECEIVEDHOTRST     => PLRECEIVEDHOTRST_outdelay,
        PLRXPMSTATE          => PLRXPMSTATE_outdelay,
        PLSELLNKRATE         => PLSELLNKRATE_outdelay,
        PLSELLNKWIDTH        => PLSELLNKWIDTH_outdelay,
        PLTXPMSTATE          => PLTXPMSTATE_outdelay,
        RECEIVEDFUNCLVLRSTN  => RECEIVEDFUNCLVLRSTN_outdelay,
        TL2ASPMSUSPENDCREDITCHECKOK => TL2ASPMSUSPENDCREDITCHECKOK_outdelay,
        TL2ASPMSUSPENDREQ    => TL2ASPMSUSPENDREQ_outdelay,
        TL2ERRFCPE           => TL2ERRFCPE_outdelay,
        TL2ERRHDR            => TL2ERRHDR_outdelay,
        TL2ERRMALFORMED      => TL2ERRMALFORMED_outdelay,
        TL2ERRRXOVERFLOW     => TL2ERRRXOVERFLOW_outdelay,
        TL2PPMSUSPENDOK      => TL2PPMSUSPENDOK_outdelay,
        TRNFCCPLD            => TRNFCCPLD_outdelay,
        TRNFCCPLH            => TRNFCCPLH_outdelay,
        TRNFCNPD             => TRNFCNPD_outdelay,
        TRNFCNPH             => TRNFCNPH_outdelay,
        TRNFCPD              => TRNFCPD_outdelay,
        TRNFCPH              => TRNFCPH_outdelay,
        TRNLNKUP             => TRNLNKUP_outdelay,
        TRNRBARHIT           => TRNRBARHIT_outdelay,
        TRNRD                => TRNRD_outdelay,
        TRNRDLLPDATA         => TRNRDLLPDATA_outdelay,
        TRNRDLLPSRCRDY       => TRNRDLLPSRCRDY_outdelay,
        TRNRECRCERR          => TRNRECRCERR_outdelay,
        TRNREOF              => TRNREOF_outdelay,
        TRNRERRFWD           => TRNRERRFWD_outdelay,
        TRNRREM              => TRNRREM_outdelay,
        TRNRSOF              => TRNRSOF_outdelay,
        TRNRSRCDSC           => TRNRSRCDSC_outdelay,
        TRNRSRCRDY           => TRNRSRCRDY_outdelay,
        TRNTBUFAV            => TRNTBUFAV_outdelay,
        TRNTCFGREQ           => TRNTCFGREQ_outdelay,
        TRNTDLLPDSTRDY       => TRNTDLLPDSTRDY_outdelay,
        TRNTDSTRDY           => TRNTDSTRDY_outdelay,
        TRNTERRDROP          => TRNTERRDROP_outdelay,
        USERRSTN             => USERRSTN_outdelay,
        CFGAERINTERRUPTMSGNUM => CFGAERINTERRUPTMSGNUM_indelay,
        CFGDEVID             => CFGDEVID_indelay,
        CFGDSBUSNUMBER       => CFGDSBUSNUMBER_indelay,
        CFGDSDEVICENUMBER    => CFGDSDEVICENUMBER_indelay,
        CFGDSFUNCTIONNUMBER  => CFGDSFUNCTIONNUMBER_indelay,
        CFGDSN               => CFGDSN_indelay,
        CFGERRACSN           => CFGERRACSN_indelay,
        CFGERRAERHEADERLOG   => CFGERRAERHEADERLOG_indelay,
        CFGERRATOMICEGRESSBLOCKEDN => CFGERRATOMICEGRESSBLOCKEDN_indelay,
        CFGERRCORN           => CFGERRCORN_indelay,
        CFGERRCPLABORTN      => CFGERRCPLABORTN_indelay,
        CFGERRCPLTIMEOUTN    => CFGERRCPLTIMEOUTN_indelay,
        CFGERRCPLUNEXPECTN   => CFGERRCPLUNEXPECTN_indelay,
        CFGERRECRCN          => CFGERRECRCN_indelay,
        CFGERRINTERNALCORN   => CFGERRINTERNALCORN_indelay,
        CFGERRINTERNALUNCORN => CFGERRINTERNALUNCORN_indelay,
        CFGERRLOCKEDN        => CFGERRLOCKEDN_indelay,
        CFGERRMALFORMEDN     => CFGERRMALFORMEDN_indelay,
        CFGERRMCBLOCKEDN     => CFGERRMCBLOCKEDN_indelay,
        CFGERRNORECOVERYN    => CFGERRNORECOVERYN_indelay,
        CFGERRPOISONEDN      => CFGERRPOISONEDN_indelay,
        CFGERRPOSTEDN        => CFGERRPOSTEDN_indelay,
        CFGERRTLPCPLHEADER   => CFGERRTLPCPLHEADER_indelay,
        CFGERRURN            => CFGERRURN_indelay,
        CFGFORCECOMMONCLOCKOFF => CFGFORCECOMMONCLOCKOFF_indelay,
        CFGFORCEEXTENDEDSYNCON => CFGFORCEEXTENDEDSYNCON_indelay,
        CFGFORCEMPS          => CFGFORCEMPS_indelay,
        CFGINTERRUPTASSERTN  => CFGINTERRUPTASSERTN_indelay,
        CFGINTERRUPTDI       => CFGINTERRUPTDI_indelay,
        CFGINTERRUPTN        => CFGINTERRUPTN_indelay,
        CFGINTERRUPTSTATN    => CFGINTERRUPTSTATN_indelay,
        CFGMGMTBYTEENN       => CFGMGMTBYTEENN_indelay,
        CFGMGMTDI            => CFGMGMTDI_indelay,
        CFGMGMTDWADDR        => CFGMGMTDWADDR_indelay,
        CFGMGMTRDENN         => CFGMGMTRDENN_indelay,
        CFGMGMTWRENN         => CFGMGMTWRENN_indelay,
        CFGMGMTWRREADONLYN   => CFGMGMTWRREADONLYN_indelay,
        CFGMGMTWRRW1CASRWN   => CFGMGMTWRRW1CASRWN_indelay,
        CFGPCIECAPINTERRUPTMSGNUM => CFGPCIECAPINTERRUPTMSGNUM_indelay,
        CFGPMFORCESTATE      => CFGPMFORCESTATE_indelay,
        CFGPMFORCESTATEENN   => CFGPMFORCESTATEENN_indelay,
        CFGPMHALTASPML0SN    => CFGPMHALTASPML0SN_indelay,
        CFGPMHALTASPML1N     => CFGPMHALTASPML1N_indelay,
        CFGPMSENDPMETON      => CFGPMSENDPMETON_indelay,
        CFGPMTURNOFFOKN      => CFGPMTURNOFFOKN_indelay,
        CFGPMWAKEN           => CFGPMWAKEN_indelay,
        CFGPORTNUMBER        => CFGPORTNUMBER_indelay,
        CFGREVID             => CFGREVID_indelay,
        CFGSUBSYSID          => CFGSUBSYSID_indelay,
        CFGSUBSYSVENDID      => CFGSUBSYSVENDID_indelay,
        CFGTRNPENDINGN       => CFGTRNPENDINGN_indelay,
        CFGVENDID            => CFGVENDID_indelay,
        CMRSTN               => CMRSTN_indelay,
        CMSTICKYRSTN         => CMSTICKYRSTN_indelay,
        DBGMODE              => DBGMODE_indelay,
        DBGSUBMODE           => DBGSUBMODE_indelay,
        DLRSTN               => DLRSTN_indelay,
        DRPADDR              => DRPADDR_indelay,
        DRPCLK               => DRPCLK_indelay,
        DRPDI                => DRPDI_indelay,
        DRPEN                => DRPEN_indelay,
        DRPWE                => DRPWE_indelay,
        FUNCLVLRSTN          => FUNCLVLRSTN_indelay,
        LL2SENDASREQL1       => LL2SENDASREQL1_indelay,
        LL2SENDENTERL1       => LL2SENDENTERL1_indelay,
        LL2SENDENTERL23      => LL2SENDENTERL23_indelay,
        LL2SENDPMACK         => LL2SENDPMACK_indelay,
        LL2SUSPENDNOW        => LL2SUSPENDNOW_indelay,
        LL2TLPRCV            => LL2TLPRCV_indelay,
        MIMRXRDATA           => MIMRXRDATA_indelay,
        MIMTXRDATA           => MIMTXRDATA_indelay,
        PIPECLK              => PIPECLK_indelay,
        PIPERX0CHANISALIGNED => PIPERX0CHANISALIGNED_indelay,
        PIPERX0CHARISK       => PIPERX0CHARISK_indelay,
        PIPERX0DATA          => PIPERX0DATA_indelay,
        PIPERX0ELECIDLE      => PIPERX0ELECIDLE_indelay,
        PIPERX0PHYSTATUS     => PIPERX0PHYSTATUS_indelay,
        PIPERX0STATUS        => PIPERX0STATUS_indelay,
        PIPERX0VALID         => PIPERX0VALID_indelay,
        PIPERX1CHANISALIGNED => PIPERX1CHANISALIGNED_indelay,
        PIPERX1CHARISK       => PIPERX1CHARISK_indelay,
        PIPERX1DATA          => PIPERX1DATA_indelay,
        PIPERX1ELECIDLE      => PIPERX1ELECIDLE_indelay,
        PIPERX1PHYSTATUS     => PIPERX1PHYSTATUS_indelay,
        PIPERX1STATUS        => PIPERX1STATUS_indelay,
        PIPERX1VALID         => PIPERX1VALID_indelay,
        PIPERX2CHANISALIGNED => PIPERX2CHANISALIGNED_indelay,
        PIPERX2CHARISK       => PIPERX2CHARISK_indelay,
        PIPERX2DATA          => PIPERX2DATA_indelay,
        PIPERX2ELECIDLE      => PIPERX2ELECIDLE_indelay,
        PIPERX2PHYSTATUS     => PIPERX2PHYSTATUS_indelay,
        PIPERX2STATUS        => PIPERX2STATUS_indelay,
        PIPERX2VALID         => PIPERX2VALID_indelay,
        PIPERX3CHANISALIGNED => PIPERX3CHANISALIGNED_indelay,
        PIPERX3CHARISK       => PIPERX3CHARISK_indelay,
        PIPERX3DATA          => PIPERX3DATA_indelay,
        PIPERX3ELECIDLE      => PIPERX3ELECIDLE_indelay,
        PIPERX3PHYSTATUS     => PIPERX3PHYSTATUS_indelay,
        PIPERX3STATUS        => PIPERX3STATUS_indelay,
        PIPERX3VALID         => PIPERX3VALID_indelay,
        PIPERX4CHANISALIGNED => PIPERX4CHANISALIGNED_indelay,
        PIPERX4CHARISK       => PIPERX4CHARISK_indelay,
        PIPERX4DATA          => PIPERX4DATA_indelay,
        PIPERX4ELECIDLE      => PIPERX4ELECIDLE_indelay,
        PIPERX4PHYSTATUS     => PIPERX4PHYSTATUS_indelay,
        PIPERX4STATUS        => PIPERX4STATUS_indelay,
        PIPERX4VALID         => PIPERX4VALID_indelay,
        PIPERX5CHANISALIGNED => PIPERX5CHANISALIGNED_indelay,
        PIPERX5CHARISK       => PIPERX5CHARISK_indelay,
        PIPERX5DATA          => PIPERX5DATA_indelay,
        PIPERX5ELECIDLE      => PIPERX5ELECIDLE_indelay,
        PIPERX5PHYSTATUS     => PIPERX5PHYSTATUS_indelay,
        PIPERX5STATUS        => PIPERX5STATUS_indelay,
        PIPERX5VALID         => PIPERX5VALID_indelay,
        PIPERX6CHANISALIGNED => PIPERX6CHANISALIGNED_indelay,
        PIPERX6CHARISK       => PIPERX6CHARISK_indelay,
        PIPERX6DATA          => PIPERX6DATA_indelay,
        PIPERX6ELECIDLE      => PIPERX6ELECIDLE_indelay,
        PIPERX6PHYSTATUS     => PIPERX6PHYSTATUS_indelay,
        PIPERX6STATUS        => PIPERX6STATUS_indelay,
        PIPERX6VALID         => PIPERX6VALID_indelay,
        PIPERX7CHANISALIGNED => PIPERX7CHANISALIGNED_indelay,
        PIPERX7CHARISK       => PIPERX7CHARISK_indelay,
        PIPERX7DATA          => PIPERX7DATA_indelay,
        PIPERX7ELECIDLE      => PIPERX7ELECIDLE_indelay,
        PIPERX7PHYSTATUS     => PIPERX7PHYSTATUS_indelay,
        PIPERX7STATUS        => PIPERX7STATUS_indelay,
        PIPERX7VALID         => PIPERX7VALID_indelay,
        PL2DIRECTEDLSTATE    => PL2DIRECTEDLSTATE_indelay,
        PLDBGMODE            => PLDBGMODE_indelay,
        PLDIRECTEDLINKAUTON  => PLDIRECTEDLINKAUTON_indelay,
        PLDIRECTEDLINKCHANGE => PLDIRECTEDLINKCHANGE_indelay,
        PLDIRECTEDLINKSPEED  => PLDIRECTEDLINKSPEED_indelay,
        PLDIRECTEDLINKWIDTH  => PLDIRECTEDLINKWIDTH_indelay,
        PLDIRECTEDLTSSMNEW   => PLDIRECTEDLTSSMNEW_indelay,
        PLDIRECTEDLTSSMNEWVLD => PLDIRECTEDLTSSMNEWVLD_indelay,
        PLDIRECTEDLTSSMSTALL => PLDIRECTEDLTSSMSTALL_indelay,
        PLDOWNSTREAMDEEMPHSOURCE => PLDOWNSTREAMDEEMPHSOURCE_indelay,
        PLRSTN               => PLRSTN_indelay,
        PLTRANSMITHOTRST     => PLTRANSMITHOTRST_indelay,
        PLUPSTREAMPREFERDEEMPH => PLUPSTREAMPREFERDEEMPH_indelay,
        SYSRSTN              => SYSRSTN_indelay,
        TL2ASPMSUSPENDCREDITCHECK => TL2ASPMSUSPENDCREDITCHECK_indelay,
        TL2PPMSUSPENDREQ     => TL2PPMSUSPENDREQ_indelay,
        TLRSTN               => TLRSTN_indelay,
        TRNFCSEL             => TRNFCSEL_indelay,
        TRNRDSTRDY           => TRNRDSTRDY_indelay,
        TRNRFCPRET           => TRNRFCPRET_indelay,
        TRNRNPOK             => TRNRNPOK_indelay,
        TRNRNPREQ            => TRNRNPREQ_indelay,
        TRNTCFGGNT           => TRNTCFGGNT_indelay,
        TRNTD                => TRNTD_indelay,
        TRNTDLLPDATA         => TRNTDLLPDATA_indelay,
        TRNTDLLPSRCRDY       => TRNTDLLPSRCRDY_indelay,
        TRNTECRCGEN          => TRNTECRCGEN_indelay,
        TRNTEOF              => TRNTEOF_indelay,
        TRNTERRFWD           => TRNTERRFWD_indelay,
        TRNTREM              => TRNTREM_indelay,
        TRNTSOF              => TRNTSOF_indelay,
        TRNTSRCDSC           => TRNTSRCDSC_indelay,
        TRNTSRCRDY           => TRNTSRCRDY_indelay,
        TRNTSTR              => TRNTSTR_indelay,
        USERCLK              => USERCLK_indelay,
        USERCLK2             => USERCLK2_indelay        
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
    -- case AER_CAP_ECRC_CHECK_CAPABLE is
      if((AER_CAP_ECRC_CHECK_CAPABLE = "FALSE") or (AER_CAP_ECRC_CHECK_CAPABLE = "false")) then
        AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '0';
      elsif((AER_CAP_ECRC_CHECK_CAPABLE = "TRUE") or (AER_CAP_ECRC_CHECK_CAPABLE= "true")) then
        AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : AER_CAP_ECRC_CHECK_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AER_CAP_ECRC_GEN_CAPABLE is
      if((AER_CAP_ECRC_GEN_CAPABLE = "FALSE") or (AER_CAP_ECRC_GEN_CAPABLE = "false")) then
        AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '0';
      elsif((AER_CAP_ECRC_GEN_CAPABLE = "TRUE") or (AER_CAP_ECRC_GEN_CAPABLE= "true")) then
        AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : AER_CAP_ECRC_GEN_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AER_CAP_MULTIHEADER is
      if((AER_CAP_MULTIHEADER = "FALSE") or (AER_CAP_MULTIHEADER = "false")) then
        AER_CAP_MULTIHEADER_BINARY <= '0';
      elsif((AER_CAP_MULTIHEADER = "TRUE") or (AER_CAP_MULTIHEADER= "true")) then
        AER_CAP_MULTIHEADER_BINARY <= '1';
      else
        assert FALSE report "Error : AER_CAP_MULTIHEADER = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AER_CAP_ON is
      if((AER_CAP_ON = "FALSE") or (AER_CAP_ON = "false")) then
        AER_CAP_ON_BINARY <= '0';
      elsif((AER_CAP_ON = "TRUE") or (AER_CAP_ON= "true")) then
        AER_CAP_ON_BINARY <= '1';
      else
        assert FALSE report "Error : AER_CAP_ON = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case AER_CAP_PERMIT_ROOTERR_UPDATE is
      if((AER_CAP_PERMIT_ROOTERR_UPDATE = "TRUE") or (AER_CAP_PERMIT_ROOTERR_UPDATE = "true")) then
        AER_CAP_PERMIT_ROOTERR_UPDATE_BINARY <= '1';
      elsif((AER_CAP_PERMIT_ROOTERR_UPDATE = "FALSE") or (AER_CAP_PERMIT_ROOTERR_UPDATE= "false")) then
        AER_CAP_PERMIT_ROOTERR_UPDATE_BINARY <= '0';
      else
        assert FALSE report "Error : AER_CAP_PERMIT_ROOTERR_UPDATE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case ALLOW_X8_GEN2 is
      if((ALLOW_X8_GEN2 = "FALSE") or (ALLOW_X8_GEN2 = "false")) then
        ALLOW_X8_GEN2_BINARY <= '0';
      elsif((ALLOW_X8_GEN2 = "TRUE") or (ALLOW_X8_GEN2= "true")) then
        ALLOW_X8_GEN2_BINARY <= '1';
      else
        assert FALSE report "Error : ALLOW_X8_GEN2 = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case CMD_INTX_IMPLEMENTED is
      if((CMD_INTX_IMPLEMENTED = "TRUE") or (CMD_INTX_IMPLEMENTED = "true")) then
        CMD_INTX_IMPLEMENTED_BINARY <= '1';
      elsif((CMD_INTX_IMPLEMENTED = "FALSE") or (CMD_INTX_IMPLEMENTED= "false")) then
        CMD_INTX_IMPLEMENTED_BINARY <= '0';
      else
        assert FALSE report "Error : CMD_INTX_IMPLEMENTED = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case CPL_TIMEOUT_DISABLE_SUPPORTED is
      if((CPL_TIMEOUT_DISABLE_SUPPORTED = "FALSE") or (CPL_TIMEOUT_DISABLE_SUPPORTED = "false")) then
        CPL_TIMEOUT_DISABLE_SUPPORTED_BINARY <= '0';
      elsif((CPL_TIMEOUT_DISABLE_SUPPORTED = "TRUE") or (CPL_TIMEOUT_DISABLE_SUPPORTED= "true")) then
        CPL_TIMEOUT_DISABLE_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : CPL_TIMEOUT_DISABLE_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_ARI_FORWARDING_SUPPORTED is
      if((DEV_CAP2_ARI_FORWARDING_SUPPORTED = "FALSE") or (DEV_CAP2_ARI_FORWARDING_SUPPORTED = "false")) then
        DEV_CAP2_ARI_FORWARDING_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_ARI_FORWARDING_SUPPORTED = "TRUE") or (DEV_CAP2_ARI_FORWARDING_SUPPORTED= "true")) then
        DEV_CAP2_ARI_FORWARDING_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_ARI_FORWARDING_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED is
      if((DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED = "FALSE") or (DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED = "false")) then
        DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED = "TRUE") or (DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED= "true")) then
        DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_ATOMICOP32_COMPLETER_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED is
      if((DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED = "FALSE") or (DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED = "false")) then
        DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED = "TRUE") or (DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED= "true")) then
        DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_ATOMICOP64_COMPLETER_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED is
      if((DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED = "FALSE") or (DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED = "false")) then
        DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED = "TRUE") or (DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED= "true")) then
        DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_ATOMICOP_ROUTING_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_CAS128_COMPLETER_SUPPORTED is
      if((DEV_CAP2_CAS128_COMPLETER_SUPPORTED = "FALSE") or (DEV_CAP2_CAS128_COMPLETER_SUPPORTED = "false")) then
        DEV_CAP2_CAS128_COMPLETER_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_CAS128_COMPLETER_SUPPORTED = "TRUE") or (DEV_CAP2_CAS128_COMPLETER_SUPPORTED= "true")) then
        DEV_CAP2_CAS128_COMPLETER_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_CAS128_COMPLETER_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED is
      if((DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED = "FALSE") or (DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED = "false")) then
        DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED = "TRUE") or (DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED= "true")) then
        DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_ENDEND_TLP_PREFIX_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED is
      if((DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED = "FALSE") or (DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED = "false")) then
        DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED = "TRUE") or (DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED= "true")) then
        DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_EXTENDED_FMT_FIELD_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_LTR_MECHANISM_SUPPORTED is
      if((DEV_CAP2_LTR_MECHANISM_SUPPORTED = "FALSE") or (DEV_CAP2_LTR_MECHANISM_SUPPORTED = "false")) then
        DEV_CAP2_LTR_MECHANISM_SUPPORTED_BINARY <= '0';
      elsif((DEV_CAP2_LTR_MECHANISM_SUPPORTED = "TRUE") or (DEV_CAP2_LTR_MECHANISM_SUPPORTED= "true")) then
        DEV_CAP2_LTR_MECHANISM_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_LTR_MECHANISM_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING is
      if((DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING = "FALSE") or (DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING = "false")) then
        DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING_BINARY <= '0';
      elsif((DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING = "TRUE") or (DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING= "true")) then
        DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP2_NO_RO_ENABLED_PRPR_PASSING = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE is
      if((DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE = "TRUE") or (DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE = "true")) then
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE_BINARY <= '1';
      elsif((DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE = "FALSE") or (DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE= "false")) then
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE_BINARY <= '0';
      else
        assert FALSE report "Error : DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE is
      if((DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE = "TRUE") or (DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE = "true")) then
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE_BINARY <= '1';
      elsif((DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE = "FALSE") or (DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE= "false")) then
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE_BINARY <= '0';
      else
        assert FALSE report "Error : DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP_EXT_TAG_SUPPORTED is
      if((DEV_CAP_EXT_TAG_SUPPORTED = "TRUE") or (DEV_CAP_EXT_TAG_SUPPORTED = "true")) then
        DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '1';
      elsif((DEV_CAP_EXT_TAG_SUPPORTED = "FALSE") or (DEV_CAP_EXT_TAG_SUPPORTED= "false")) then
        DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '0';
      else
        assert FALSE report "Error : DEV_CAP_EXT_TAG_SUPPORTED = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE is
      if((DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = "FALSE") or (DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = "false")) then
        DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY <= '0';
      elsif((DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = "TRUE") or (DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE= "true")) then
        DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CAP_ROLE_BASED_ERROR is
      if((DEV_CAP_ROLE_BASED_ERROR = "TRUE") or (DEV_CAP_ROLE_BASED_ERROR = "true")) then
        DEV_CAP_ROLE_BASED_ERROR_BINARY <= '1';
      elsif((DEV_CAP_ROLE_BASED_ERROR = "FALSE") or (DEV_CAP_ROLE_BASED_ERROR= "false")) then
        DEV_CAP_ROLE_BASED_ERROR_BINARY <= '0';
      else
        assert FALSE report "Error : DEV_CAP_ROLE_BASED_ERROR = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case DEV_CONTROL_AUX_POWER_SUPPORTED is
      if((DEV_CONTROL_AUX_POWER_SUPPORTED = "FALSE") or (DEV_CONTROL_AUX_POWER_SUPPORTED = "false")) then
        DEV_CONTROL_AUX_POWER_SUPPORTED_BINARY <= '0';
      elsif((DEV_CONTROL_AUX_POWER_SUPPORTED = "TRUE") or (DEV_CONTROL_AUX_POWER_SUPPORTED= "true")) then
        DEV_CONTROL_AUX_POWER_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CONTROL_AUX_POWER_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DEV_CONTROL_EXT_TAG_DEFAULT is
      if((DEV_CONTROL_EXT_TAG_DEFAULT = "FALSE") or (DEV_CONTROL_EXT_TAG_DEFAULT = "false")) then
        DEV_CONTROL_EXT_TAG_DEFAULT_BINARY <= '0';
      elsif((DEV_CONTROL_EXT_TAG_DEFAULT = "TRUE") or (DEV_CONTROL_EXT_TAG_DEFAULT= "true")) then
        DEV_CONTROL_EXT_TAG_DEFAULT_BINARY <= '1';
      else
        assert FALSE report "Error : DEV_CONTROL_EXT_TAG_DEFAULT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_ASPM_L1_TIMER is
      if((DISABLE_ASPM_L1_TIMER = "FALSE") or (DISABLE_ASPM_L1_TIMER = "false")) then
        DISABLE_ASPM_L1_TIMER_BINARY <= '0';
      elsif((DISABLE_ASPM_L1_TIMER = "TRUE") or (DISABLE_ASPM_L1_TIMER= "true")) then
        DISABLE_ASPM_L1_TIMER_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_ASPM_L1_TIMER = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_BAR_FILTERING is
      if((DISABLE_BAR_FILTERING = "FALSE") or (DISABLE_BAR_FILTERING = "false")) then
        DISABLE_BAR_FILTERING_BINARY <= '0';
      elsif((DISABLE_BAR_FILTERING = "TRUE") or (DISABLE_BAR_FILTERING= "true")) then
        DISABLE_BAR_FILTERING_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_BAR_FILTERING = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_ERR_MSG is
      if((DISABLE_ERR_MSG = "FALSE") or (DISABLE_ERR_MSG = "false")) then
        DISABLE_ERR_MSG_BINARY <= '0';
      elsif((DISABLE_ERR_MSG = "TRUE") or (DISABLE_ERR_MSG= "true")) then
        DISABLE_ERR_MSG_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_ERR_MSG = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_ID_CHECK is
      if((DISABLE_ID_CHECK = "FALSE") or (DISABLE_ID_CHECK = "false")) then
        DISABLE_ID_CHECK_BINARY <= '0';
      elsif((DISABLE_ID_CHECK = "TRUE") or (DISABLE_ID_CHECK= "true")) then
        DISABLE_ID_CHECK_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_ID_CHECK = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_LANE_REVERSAL is
      if((DISABLE_LANE_REVERSAL = "FALSE") or (DISABLE_LANE_REVERSAL = "false")) then
        DISABLE_LANE_REVERSAL_BINARY <= '0';
      elsif((DISABLE_LANE_REVERSAL = "TRUE") or (DISABLE_LANE_REVERSAL= "true")) then
        DISABLE_LANE_REVERSAL_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_LANE_REVERSAL = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_LOCKED_FILTER is
      if((DISABLE_LOCKED_FILTER = "FALSE") or (DISABLE_LOCKED_FILTER = "false")) then
        DISABLE_LOCKED_FILTER_BINARY <= '0';
      elsif((DISABLE_LOCKED_FILTER = "TRUE") or (DISABLE_LOCKED_FILTER= "true")) then
        DISABLE_LOCKED_FILTER_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_LOCKED_FILTER = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_PPM_FILTER is
      if((DISABLE_PPM_FILTER = "FALSE") or (DISABLE_PPM_FILTER = "false")) then
        DISABLE_PPM_FILTER_BINARY <= '0';
      elsif((DISABLE_PPM_FILTER = "TRUE") or (DISABLE_PPM_FILTER= "true")) then
        DISABLE_PPM_FILTER_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_PPM_FILTER = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_RX_POISONED_RESP is
      if((DISABLE_RX_POISONED_RESP = "FALSE") or (DISABLE_RX_POISONED_RESP = "false")) then
        DISABLE_RX_POISONED_RESP_BINARY <= '0';
      elsif((DISABLE_RX_POISONED_RESP = "TRUE") or (DISABLE_RX_POISONED_RESP= "true")) then
        DISABLE_RX_POISONED_RESP_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_RX_POISONED_RESP = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_RX_TC_FILTER is
      if((DISABLE_RX_TC_FILTER = "FALSE") or (DISABLE_RX_TC_FILTER = "false")) then
        DISABLE_RX_TC_FILTER_BINARY <= '0';
      elsif((DISABLE_RX_TC_FILTER = "TRUE") or (DISABLE_RX_TC_FILTER= "true")) then
        DISABLE_RX_TC_FILTER_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_RX_TC_FILTER = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DISABLE_SCRAMBLING is
      if((DISABLE_SCRAMBLING = "FALSE") or (DISABLE_SCRAMBLING = "false")) then
        DISABLE_SCRAMBLING_BINARY <= '0';
      elsif((DISABLE_SCRAMBLING = "TRUE") or (DISABLE_SCRAMBLING= "true")) then
        DISABLE_SCRAMBLING_BINARY <= '1';
      else
        assert FALSE report "Error : DISABLE_SCRAMBLING = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DSN_CAP_ON is
      if((DSN_CAP_ON = "TRUE") or (DSN_CAP_ON = "true")) then
        DSN_CAP_ON_BINARY <= '1';
      elsif((DSN_CAP_ON = "FALSE") or (DSN_CAP_ON= "false")) then
        DSN_CAP_ON_BINARY <= '0';
      else
        assert FALSE report "Error : DSN_CAP_ON = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case ENABLE_RX_TD_ECRC_TRIM is
      if((ENABLE_RX_TD_ECRC_TRIM = "FALSE") or (ENABLE_RX_TD_ECRC_TRIM = "false")) then
        ENABLE_RX_TD_ECRC_TRIM_BINARY <= '0';
      elsif((ENABLE_RX_TD_ECRC_TRIM = "TRUE") or (ENABLE_RX_TD_ECRC_TRIM= "true")) then
        ENABLE_RX_TD_ECRC_TRIM_BINARY <= '1';
      else
        assert FALSE report "Error : ENABLE_RX_TD_ECRC_TRIM = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED is
      if((ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED = "FALSE") or (ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED = "false")) then
        ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED_BINARY <= '0';
      elsif((ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED = "TRUE") or (ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED= "true")) then
        ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED_BINARY <= '1';
      else
        assert FALSE report "Error : ENDEND_TLP_PREFIX_FORWARDING_SUPPORTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case ENTER_RVRY_EI_L0 is
      if((ENTER_RVRY_EI_L0 = "TRUE") or (ENTER_RVRY_EI_L0 = "true")) then
        ENTER_RVRY_EI_L0_BINARY <= '1';
      elsif((ENTER_RVRY_EI_L0 = "FALSE") or (ENTER_RVRY_EI_L0= "false")) then
        ENTER_RVRY_EI_L0_BINARY <= '0';
      else
        assert FALSE report "Error : ENTER_RVRY_EI_L0 = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case EXIT_LOOPBACK_ON_EI is
      if((EXIT_LOOPBACK_ON_EI = "TRUE") or (EXIT_LOOPBACK_ON_EI = "true")) then
        EXIT_LOOPBACK_ON_EI_BINARY <= '1';
      elsif((EXIT_LOOPBACK_ON_EI = "FALSE") or (EXIT_LOOPBACK_ON_EI= "false")) then
        EXIT_LOOPBACK_ON_EI_BINARY <= '0';
      else
        assert FALSE report "Error : EXIT_LOOPBACK_ON_EI = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case INTERRUPT_STAT_AUTO is
      if((INTERRUPT_STAT_AUTO = "TRUE") or (INTERRUPT_STAT_AUTO = "true")) then
        INTERRUPT_STAT_AUTO_BINARY <= '1';
      elsif((INTERRUPT_STAT_AUTO = "FALSE") or (INTERRUPT_STAT_AUTO= "false")) then
        INTERRUPT_STAT_AUTO_BINARY <= '0';
      else
        assert FALSE report "Error : INTERRUPT_STAT_AUTO = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case IS_SWITCH is
      if((IS_SWITCH = "FALSE") or (IS_SWITCH = "false")) then
        IS_SWITCH_BINARY <= '0';
      elsif((IS_SWITCH = "TRUE") or (IS_SWITCH= "true")) then
        IS_SWITCH_BINARY <= '1';
      else
        assert FALSE report "Error : IS_SWITCH = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LINK_CAP_ASPM_OPTIONALITY is
      if((LINK_CAP_ASPM_OPTIONALITY = "TRUE") or (LINK_CAP_ASPM_OPTIONALITY = "true")) then
        LINK_CAP_ASPM_OPTIONALITY_BINARY <= '1';
      elsif((LINK_CAP_ASPM_OPTIONALITY = "FALSE") or (LINK_CAP_ASPM_OPTIONALITY= "false")) then
        LINK_CAP_ASPM_OPTIONALITY_BINARY <= '0';
      else
        assert FALSE report "Error : LINK_CAP_ASPM_OPTIONALITY = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case LINK_CAP_CLOCK_POWER_MANAGEMENT is
      if((LINK_CAP_CLOCK_POWER_MANAGEMENT = "FALSE") or (LINK_CAP_CLOCK_POWER_MANAGEMENT = "false")) then
        LINK_CAP_CLOCK_POWER_MANAGEMENT_BINARY <= '0';
      elsif((LINK_CAP_CLOCK_POWER_MANAGEMENT = "TRUE") or (LINK_CAP_CLOCK_POWER_MANAGEMENT= "true")) then
        LINK_CAP_CLOCK_POWER_MANAGEMENT_BINARY <= '1';
      else
        assert FALSE report "Error : LINK_CAP_CLOCK_POWER_MANAGEMENT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP is
      if((LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP = "FALSE") or (LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP = "false")) then
        LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP_BINARY <= '0';
      elsif((LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP = "TRUE") or (LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP= "true")) then
        LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP_BINARY <= '1';
      else
        assert FALSE report "Error : LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP is
      if((LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP = "FALSE") or (LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP = "false")) then
        LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP_BINARY <= '0';
      elsif((LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP = "TRUE") or (LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP= "true")) then
        LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP_BINARY <= '1';
      else
        assert FALSE report "Error : LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE is
      if((LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE = "FALSE") or (LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE = "false")) then
        LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_BINARY <= '0';
      elsif((LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE = "TRUE") or (LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE= "true")) then
        LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LINK_CTRL2_DEEMPHASIS is
      if((LINK_CTRL2_DEEMPHASIS = "FALSE") or (LINK_CTRL2_DEEMPHASIS = "false")) then
        LINK_CTRL2_DEEMPHASIS_BINARY <= '0';
      elsif((LINK_CTRL2_DEEMPHASIS = "TRUE") or (LINK_CTRL2_DEEMPHASIS= "true")) then
        LINK_CTRL2_DEEMPHASIS_BINARY <= '1';
      else
        assert FALSE report "Error : LINK_CTRL2_DEEMPHASIS = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE is
      if((LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE = "FALSE") or (LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE = "false")) then
        LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_BINARY <= '0';
      elsif((LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE = "TRUE") or (LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE= "true")) then
        LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_BINARY <= '1';
      else
        assert FALSE report "Error : LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case LINK_STATUS_SLOT_CLOCK_CONFIG is
      if((LINK_STATUS_SLOT_CLOCK_CONFIG = "TRUE") or (LINK_STATUS_SLOT_CLOCK_CONFIG = "true")) then
        LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY <= '1';
      elsif((LINK_STATUS_SLOT_CLOCK_CONFIG = "FALSE") or (LINK_STATUS_SLOT_CLOCK_CONFIG= "false")) then
        LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY <= '0';
      else
        assert FALSE report "Error : LINK_STATUS_SLOT_CLOCK_CONFIG = is not TRUE, FALSE." severity error;
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
    -- case LL_REPLAY_TIMEOUT_EN is
      if((LL_REPLAY_TIMEOUT_EN = "FALSE") or (LL_REPLAY_TIMEOUT_EN = "false")) then
        LL_REPLAY_TIMEOUT_EN_BINARY <= '0';
      elsif((LL_REPLAY_TIMEOUT_EN = "TRUE") or (LL_REPLAY_TIMEOUT_EN= "true")) then
        LL_REPLAY_TIMEOUT_EN_BINARY <= '1';
      else
        assert FALSE report "Error : LL_REPLAY_TIMEOUT_EN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case MPS_FORCE is
      if((MPS_FORCE = "FALSE") or (MPS_FORCE = "false")) then
        MPS_FORCE_BINARY <= '0';
      elsif((MPS_FORCE = "TRUE") or (MPS_FORCE= "true")) then
        MPS_FORCE_BINARY <= '1';
      else
        assert FALSE report "Error : MPS_FORCE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case MSIX_CAP_ON is
      if((MSIX_CAP_ON = "FALSE") or (MSIX_CAP_ON = "false")) then
        MSIX_CAP_ON_BINARY <= '0';
      elsif((MSIX_CAP_ON = "TRUE") or (MSIX_CAP_ON= "true")) then
        MSIX_CAP_ON_BINARY <= '1';
      else
        assert FALSE report "Error : MSIX_CAP_ON = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case MSI_CAP_64_BIT_ADDR_CAPABLE is
      if((MSI_CAP_64_BIT_ADDR_CAPABLE = "TRUE") or (MSI_CAP_64_BIT_ADDR_CAPABLE = "true")) then
        MSI_CAP_64_BIT_ADDR_CAPABLE_BINARY <= '1';
      elsif((MSI_CAP_64_BIT_ADDR_CAPABLE = "FALSE") or (MSI_CAP_64_BIT_ADDR_CAPABLE= "false")) then
        MSI_CAP_64_BIT_ADDR_CAPABLE_BINARY <= '0';
      else
        assert FALSE report "Error : MSI_CAP_64_BIT_ADDR_CAPABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case MSI_CAP_ON is
      if((MSI_CAP_ON = "FALSE") or (MSI_CAP_ON = "false")) then
        MSI_CAP_ON_BINARY <= '0';
      elsif((MSI_CAP_ON = "TRUE") or (MSI_CAP_ON= "true")) then
        MSI_CAP_ON_BINARY <= '1';
      else
        assert FALSE report "Error : MSI_CAP_ON = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case MSI_CAP_PER_VECTOR_MASKING_CAPABLE is
      if((MSI_CAP_PER_VECTOR_MASKING_CAPABLE = "TRUE") or (MSI_CAP_PER_VECTOR_MASKING_CAPABLE = "true")) then
        MSI_CAP_PER_VECTOR_MASKING_CAPABLE_BINARY <= '1';
      elsif((MSI_CAP_PER_VECTOR_MASKING_CAPABLE = "FALSE") or (MSI_CAP_PER_VECTOR_MASKING_CAPABLE= "false")) then
        MSI_CAP_PER_VECTOR_MASKING_CAPABLE_BINARY <= '0';
      else
        assert FALSE report "Error : MSI_CAP_PER_VECTOR_MASKING_CAPABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PCIE_CAP_ON is
      if((PCIE_CAP_ON = "TRUE") or (PCIE_CAP_ON = "true")) then
        PCIE_CAP_ON_BINARY <= '1';
      elsif((PCIE_CAP_ON = "FALSE") or (PCIE_CAP_ON= "false")) then
        PCIE_CAP_ON_BINARY <= '0';
      else
        assert FALSE report "Error : PCIE_CAP_ON = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PCIE_CAP_SLOT_IMPLEMENTED is
      if((PCIE_CAP_SLOT_IMPLEMENTED = "FALSE") or (PCIE_CAP_SLOT_IMPLEMENTED = "false")) then
        PCIE_CAP_SLOT_IMPLEMENTED_BINARY <= '0';
      elsif((PCIE_CAP_SLOT_IMPLEMENTED = "TRUE") or (PCIE_CAP_SLOT_IMPLEMENTED= "true")) then
        PCIE_CAP_SLOT_IMPLEMENTED_BINARY <= '1';
      else
        assert FALSE report "Error : PCIE_CAP_SLOT_IMPLEMENTED = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PL_FAST_TRAIN is
      if((PL_FAST_TRAIN = "FALSE") or (PL_FAST_TRAIN = "false")) then
        PL_FAST_TRAIN_BINARY <= '0';
      elsif((PL_FAST_TRAIN = "TRUE") or (PL_FAST_TRAIN= "true")) then
        PL_FAST_TRAIN_BINARY <= '1';
      else
        assert FALSE report "Error : PL_FAST_TRAIN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PM_ASPML0S_TIMEOUT_EN is
      if((PM_ASPML0S_TIMEOUT_EN = "FALSE") or (PM_ASPML0S_TIMEOUT_EN = "false")) then
        PM_ASPML0S_TIMEOUT_EN_BINARY <= '0';
      elsif((PM_ASPML0S_TIMEOUT_EN = "TRUE") or (PM_ASPML0S_TIMEOUT_EN= "true")) then
        PM_ASPML0S_TIMEOUT_EN_BINARY <= '1';
      else
        assert FALSE report "Error : PM_ASPML0S_TIMEOUT_EN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PM_ASPM_FASTEXIT is
      if((PM_ASPM_FASTEXIT = "FALSE") or (PM_ASPM_FASTEXIT = "false")) then
        PM_ASPM_FASTEXIT_BINARY <= '0';
      elsif((PM_ASPM_FASTEXIT = "TRUE") or (PM_ASPM_FASTEXIT= "true")) then
        PM_ASPM_FASTEXIT_BINARY <= '1';
      else
        assert FALSE report "Error : PM_ASPM_FASTEXIT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PM_CAP_D1SUPPORT is
      if((PM_CAP_D1SUPPORT = "TRUE") or (PM_CAP_D1SUPPORT = "true")) then
        PM_CAP_D1SUPPORT_BINARY <= '1';
      elsif((PM_CAP_D1SUPPORT = "FALSE") or (PM_CAP_D1SUPPORT= "false")) then
        PM_CAP_D1SUPPORT_BINARY <= '0';
      else
        assert FALSE report "Error : PM_CAP_D1SUPPORT = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PM_CAP_D2SUPPORT is
      if((PM_CAP_D2SUPPORT = "TRUE") or (PM_CAP_D2SUPPORT = "true")) then
        PM_CAP_D2SUPPORT_BINARY <= '1';
      elsif((PM_CAP_D2SUPPORT = "FALSE") or (PM_CAP_D2SUPPORT= "false")) then
        PM_CAP_D2SUPPORT_BINARY <= '0';
      else
        assert FALSE report "Error : PM_CAP_D2SUPPORT = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PM_CAP_DSI is
      if((PM_CAP_DSI = "FALSE") or (PM_CAP_DSI = "false")) then
        PM_CAP_DSI_BINARY <= '0';
      elsif((PM_CAP_DSI = "TRUE") or (PM_CAP_DSI= "true")) then
        PM_CAP_DSI_BINARY <= '1';
      else
        assert FALSE report "Error : PM_CAP_DSI = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PM_CAP_ON is
      if((PM_CAP_ON = "TRUE") or (PM_CAP_ON = "true")) then
        PM_CAP_ON_BINARY <= '1';
      elsif((PM_CAP_ON = "FALSE") or (PM_CAP_ON= "false")) then
        PM_CAP_ON_BINARY <= '0';
      else
        assert FALSE report "Error : PM_CAP_ON = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PM_CAP_PME_CLOCK is
      if((PM_CAP_PME_CLOCK = "FALSE") or (PM_CAP_PME_CLOCK = "false")) then
        PM_CAP_PME_CLOCK_BINARY <= '0';
      elsif((PM_CAP_PME_CLOCK = "TRUE") or (PM_CAP_PME_CLOCK= "true")) then
        PM_CAP_PME_CLOCK_BINARY <= '1';
      else
        assert FALSE report "Error : PM_CAP_PME_CLOCK = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PM_CSR_B2B3 is
      if((PM_CSR_B2B3 = "FALSE") or (PM_CSR_B2B3 = "false")) then
        PM_CSR_B2B3_BINARY <= '0';
      elsif((PM_CSR_B2B3 = "TRUE") or (PM_CSR_B2B3= "true")) then
        PM_CSR_B2B3_BINARY <= '1';
      else
        assert FALSE report "Error : PM_CSR_B2B3 = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PM_CSR_BPCCEN is
      if((PM_CSR_BPCCEN = "FALSE") or (PM_CSR_BPCCEN = "false")) then
        PM_CSR_BPCCEN_BINARY <= '0';
      elsif((PM_CSR_BPCCEN = "TRUE") or (PM_CSR_BPCCEN= "true")) then
        PM_CSR_BPCCEN_BINARY <= '1';
      else
        assert FALSE report "Error : PM_CSR_BPCCEN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case PM_CSR_NOSOFTRST is
      if((PM_CSR_NOSOFTRST = "TRUE") or (PM_CSR_NOSOFTRST = "true")) then
        PM_CSR_NOSOFTRST_BINARY <= '1';
      elsif((PM_CSR_NOSOFTRST = "FALSE") or (PM_CSR_NOSOFTRST= "false")) then
        PM_CSR_NOSOFTRST_BINARY <= '0';
      else
        assert FALSE report "Error : PM_CSR_NOSOFTRST = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case PM_MF is
      if((PM_MF = "FALSE") or (PM_MF = "false")) then
        PM_MF_BINARY <= '0';
      elsif((PM_MF = "TRUE") or (PM_MF= "true")) then
        PM_MF_BINARY <= '1';
      else
        assert FALSE report "Error : PM_MF = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case RBAR_CAP_ON is
      if((RBAR_CAP_ON = "FALSE") or (RBAR_CAP_ON = "false")) then
        RBAR_CAP_ON_BINARY <= '0';
      elsif((RBAR_CAP_ON = "TRUE") or (RBAR_CAP_ON= "true")) then
        RBAR_CAP_ON_BINARY <= '1';
      else
        assert FALSE report "Error : RBAR_CAP_ON = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case RECRC_CHK_TRIM is
      if((RECRC_CHK_TRIM = "FALSE") or (RECRC_CHK_TRIM = "false")) then
        RECRC_CHK_TRIM_BINARY <= '0';
      elsif((RECRC_CHK_TRIM = "TRUE") or (RECRC_CHK_TRIM= "true")) then
        RECRC_CHK_TRIM_BINARY <= '1';
      else
        assert FALSE report "Error : RECRC_CHK_TRIM = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case ROOT_CAP_CRS_SW_VISIBILITY is
      if((ROOT_CAP_CRS_SW_VISIBILITY = "FALSE") or (ROOT_CAP_CRS_SW_VISIBILITY = "false")) then
        ROOT_CAP_CRS_SW_VISIBILITY_BINARY <= '0';
      elsif((ROOT_CAP_CRS_SW_VISIBILITY = "TRUE") or (ROOT_CAP_CRS_SW_VISIBILITY= "true")) then
        ROOT_CAP_CRS_SW_VISIBILITY_BINARY <= '1';
      else
        assert FALSE report "Error : ROOT_CAP_CRS_SW_VISIBILITY = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SELECT_DLL_IF is
      if((SELECT_DLL_IF = "FALSE") or (SELECT_DLL_IF = "false")) then
        SELECT_DLL_IF_BINARY <= '0';
      elsif((SELECT_DLL_IF = "TRUE") or (SELECT_DLL_IF= "true")) then
        SELECT_DLL_IF_BINARY <= '1';
      else
        assert FALSE report "Error : SELECT_DLL_IF = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_ATT_BUTTON_PRESENT is
      if((SLOT_CAP_ATT_BUTTON_PRESENT = "FALSE") or (SLOT_CAP_ATT_BUTTON_PRESENT = "false")) then
        SLOT_CAP_ATT_BUTTON_PRESENT_BINARY <= '0';
      elsif((SLOT_CAP_ATT_BUTTON_PRESENT = "TRUE") or (SLOT_CAP_ATT_BUTTON_PRESENT= "true")) then
        SLOT_CAP_ATT_BUTTON_PRESENT_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_ATT_BUTTON_PRESENT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_ATT_INDICATOR_PRESENT is
      if((SLOT_CAP_ATT_INDICATOR_PRESENT = "FALSE") or (SLOT_CAP_ATT_INDICATOR_PRESENT = "false")) then
        SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY <= '0';
      elsif((SLOT_CAP_ATT_INDICATOR_PRESENT = "TRUE") or (SLOT_CAP_ATT_INDICATOR_PRESENT= "true")) then
        SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_ATT_INDICATOR_PRESENT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_ELEC_INTERLOCK_PRESENT is
      if((SLOT_CAP_ELEC_INTERLOCK_PRESENT = "FALSE") or (SLOT_CAP_ELEC_INTERLOCK_PRESENT = "false")) then
        SLOT_CAP_ELEC_INTERLOCK_PRESENT_BINARY <= '0';
      elsif((SLOT_CAP_ELEC_INTERLOCK_PRESENT = "TRUE") or (SLOT_CAP_ELEC_INTERLOCK_PRESENT= "true")) then
        SLOT_CAP_ELEC_INTERLOCK_PRESENT_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_ELEC_INTERLOCK_PRESENT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_HOTPLUG_CAPABLE is
      if((SLOT_CAP_HOTPLUG_CAPABLE = "FALSE") or (SLOT_CAP_HOTPLUG_CAPABLE = "false")) then
        SLOT_CAP_HOTPLUG_CAPABLE_BINARY <= '0';
      elsif((SLOT_CAP_HOTPLUG_CAPABLE = "TRUE") or (SLOT_CAP_HOTPLUG_CAPABLE= "true")) then
        SLOT_CAP_HOTPLUG_CAPABLE_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_HOTPLUG_CAPABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_HOTPLUG_SURPRISE is
      if((SLOT_CAP_HOTPLUG_SURPRISE = "FALSE") or (SLOT_CAP_HOTPLUG_SURPRISE = "false")) then
        SLOT_CAP_HOTPLUG_SURPRISE_BINARY <= '0';
      elsif((SLOT_CAP_HOTPLUG_SURPRISE = "TRUE") or (SLOT_CAP_HOTPLUG_SURPRISE= "true")) then
        SLOT_CAP_HOTPLUG_SURPRISE_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_HOTPLUG_SURPRISE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_MRL_SENSOR_PRESENT is
      if((SLOT_CAP_MRL_SENSOR_PRESENT = "FALSE") or (SLOT_CAP_MRL_SENSOR_PRESENT = "false")) then
        SLOT_CAP_MRL_SENSOR_PRESENT_BINARY <= '0';
      elsif((SLOT_CAP_MRL_SENSOR_PRESENT = "TRUE") or (SLOT_CAP_MRL_SENSOR_PRESENT= "true")) then
        SLOT_CAP_MRL_SENSOR_PRESENT_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_MRL_SENSOR_PRESENT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_NO_CMD_COMPLETED_SUPPORT is
      if((SLOT_CAP_NO_CMD_COMPLETED_SUPPORT = "FALSE") or (SLOT_CAP_NO_CMD_COMPLETED_SUPPORT = "false")) then
        SLOT_CAP_NO_CMD_COMPLETED_SUPPORT_BINARY <= '0';
      elsif((SLOT_CAP_NO_CMD_COMPLETED_SUPPORT = "TRUE") or (SLOT_CAP_NO_CMD_COMPLETED_SUPPORT= "true")) then
        SLOT_CAP_NO_CMD_COMPLETED_SUPPORT_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_NO_CMD_COMPLETED_SUPPORT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_POWER_CONTROLLER_PRESENT is
      if((SLOT_CAP_POWER_CONTROLLER_PRESENT = "FALSE") or (SLOT_CAP_POWER_CONTROLLER_PRESENT = "false")) then
        SLOT_CAP_POWER_CONTROLLER_PRESENT_BINARY <= '0';
      elsif((SLOT_CAP_POWER_CONTROLLER_PRESENT = "TRUE") or (SLOT_CAP_POWER_CONTROLLER_PRESENT= "true")) then
        SLOT_CAP_POWER_CONTROLLER_PRESENT_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_POWER_CONTROLLER_PRESENT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SLOT_CAP_POWER_INDICATOR_PRESENT is
      if((SLOT_CAP_POWER_INDICATOR_PRESENT = "FALSE") or (SLOT_CAP_POWER_INDICATOR_PRESENT = "false")) then
        SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY <= '0';
      elsif((SLOT_CAP_POWER_INDICATOR_PRESENT = "TRUE") or (SLOT_CAP_POWER_INDICATOR_PRESENT= "true")) then
        SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY <= '1';
      else
        assert FALSE report "Error : SLOT_CAP_POWER_INDICATOR_PRESENT = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case SSL_MESSAGE_AUTO is
      if((SSL_MESSAGE_AUTO = "FALSE") or (SSL_MESSAGE_AUTO = "false")) then
        SSL_MESSAGE_AUTO_BINARY <= '0';
      elsif((SSL_MESSAGE_AUTO = "TRUE") or (SSL_MESSAGE_AUTO= "true")) then
        SSL_MESSAGE_AUTO_BINARY <= '1';
      else
        assert FALSE report "Error : SSL_MESSAGE_AUTO = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TECRC_EP_INV is
      if((TECRC_EP_INV = "FALSE") or (TECRC_EP_INV = "false")) then
        TECRC_EP_INV_BINARY <= '0';
      elsif((TECRC_EP_INV = "TRUE") or (TECRC_EP_INV= "true")) then
        TECRC_EP_INV_BINARY <= '1';
      else
        assert FALSE report "Error : TECRC_EP_INV = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_RBYPASS is
      if((TL_RBYPASS = "FALSE") or (TL_RBYPASS = "false")) then
        TL_RBYPASS_BINARY <= '0';
      elsif((TL_RBYPASS = "TRUE") or (TL_RBYPASS= "true")) then
        TL_RBYPASS_BINARY <= '1';
      else
        assert FALSE report "Error : TL_RBYPASS = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_TFC_DISABLE is
      if((TL_TFC_DISABLE = "FALSE") or (TL_TFC_DISABLE = "false")) then
        TL_TFC_DISABLE_BINARY <= '0';
      elsif((TL_TFC_DISABLE = "TRUE") or (TL_TFC_DISABLE= "true")) then
        TL_TFC_DISABLE_BINARY <= '1';
      else
        assert FALSE report "Error : TL_TFC_DISABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TL_TX_CHECKS_DISABLE is
      if((TL_TX_CHECKS_DISABLE = "FALSE") or (TL_TX_CHECKS_DISABLE = "false")) then
        TL_TX_CHECKS_DISABLE_BINARY <= '0';
      elsif((TL_TX_CHECKS_DISABLE = "TRUE") or (TL_TX_CHECKS_DISABLE= "true")) then
        TL_TX_CHECKS_DISABLE_BINARY <= '1';
      else
        assert FALSE report "Error : TL_TX_CHECKS_DISABLE = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TRN_DW is
      if((TRN_DW = "FALSE") or (TRN_DW = "false")) then
        TRN_DW_BINARY <= '0';
      elsif((TRN_DW = "TRUE") or (TRN_DW= "true")) then
        TRN_DW_BINARY <= '1';
      else
        assert FALSE report "Error : TRN_DW = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TRN_NP_FC is
      if((TRN_NP_FC = "FALSE") or (TRN_NP_FC = "false")) then
        TRN_NP_FC_BINARY <= '0';
      elsif((TRN_NP_FC = "TRUE") or (TRN_NP_FC= "true")) then
        TRN_NP_FC_BINARY <= '1';
      else
        assert FALSE report "Error : TRN_NP_FC = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case UPCONFIG_CAPABLE is
      if((UPCONFIG_CAPABLE = "TRUE") or (UPCONFIG_CAPABLE = "true")) then
        UPCONFIG_CAPABLE_BINARY <= '1';
      elsif((UPCONFIG_CAPABLE = "FALSE") or (UPCONFIG_CAPABLE= "false")) then
        UPCONFIG_CAPABLE_BINARY <= '0';
      else
        assert FALSE report "Error : UPCONFIG_CAPABLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case UPSTREAM_FACING is
      if((UPSTREAM_FACING = "TRUE") or (UPSTREAM_FACING = "true")) then
        UPSTREAM_FACING_BINARY <= '1';
      elsif((UPSTREAM_FACING = "FALSE") or (UPSTREAM_FACING= "false")) then
        UPSTREAM_FACING_BINARY <= '0';
      else
        assert FALSE report "Error : UPSTREAM_FACING = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case UR_ATOMIC is
      if((UR_ATOMIC = "TRUE") or (UR_ATOMIC = "true")) then
        UR_ATOMIC_BINARY <= '1';
      elsif((UR_ATOMIC = "FALSE") or (UR_ATOMIC= "false")) then
        UR_ATOMIC_BINARY <= '0';
      else
        assert FALSE report "Error : UR_ATOMIC = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case UR_CFG1 is
      if((UR_CFG1 = "TRUE") or (UR_CFG1 = "true")) then
        UR_CFG1_BINARY <= '1';
      elsif((UR_CFG1 = "FALSE") or (UR_CFG1= "false")) then
        UR_CFG1_BINARY <= '0';
      else
        assert FALSE report "Error : UR_CFG1 = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case UR_INV_REQ is
      if((UR_INV_REQ = "TRUE") or (UR_INV_REQ = "true")) then
        UR_INV_REQ_BINARY <= '1';
      elsif((UR_INV_REQ = "FALSE") or (UR_INV_REQ= "false")) then
        UR_INV_REQ_BINARY <= '0';
      else
        assert FALSE report "Error : UR_INV_REQ = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case UR_PRS_RESPONSE is
      if((UR_PRS_RESPONSE = "TRUE") or (UR_PRS_RESPONSE = "true")) then
        UR_PRS_RESPONSE_BINARY <= '1';
      elsif((UR_PRS_RESPONSE = "FALSE") or (UR_PRS_RESPONSE= "false")) then
        UR_PRS_RESPONSE_BINARY <= '0';
      else
        assert FALSE report "Error : UR_PRS_RESPONSE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case USER_CLK2_DIV2 is
      if((USER_CLK2_DIV2 = "FALSE") or (USER_CLK2_DIV2 = "false")) then
        USER_CLK2_DIV2_BINARY <= '0';
      elsif((USER_CLK2_DIV2 = "TRUE") or (USER_CLK2_DIV2= "true")) then
        USER_CLK2_DIV2_BINARY <= '1';
      else
        assert FALSE report "Error : USER_CLK2_DIV2 = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case USE_RID_PINS is
      if((USE_RID_PINS = "FALSE") or (USE_RID_PINS = "false")) then
        USE_RID_PINS_BINARY <= '0';
      elsif((USE_RID_PINS = "TRUE") or (USE_RID_PINS= "true")) then
        USE_RID_PINS_BINARY <= '1';
      else
        assert FALSE report "Error : USE_RID_PINS = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VC0_CPL_INFINITE is
      if((VC0_CPL_INFINITE = "TRUE") or (VC0_CPL_INFINITE = "true")) then
        VC0_CPL_INFINITE_BINARY <= '1';
      elsif((VC0_CPL_INFINITE = "FALSE") or (VC0_CPL_INFINITE= "false")) then
        VC0_CPL_INFINITE_BINARY <= '0';
      else
        assert FALSE report "Error : VC0_CPL_INFINITE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VC_CAP_ON is
      if((VC_CAP_ON = "FALSE") or (VC_CAP_ON = "false")) then
        VC_CAP_ON_BINARY <= '0';
      elsif((VC_CAP_ON = "TRUE") or (VC_CAP_ON= "true")) then
        VC_CAP_ON_BINARY <= '1';
      else
        assert FALSE report "Error : VC_CAP_ON = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VC_CAP_REJECT_SNOOP_TRANSACTIONS is
      if((VC_CAP_REJECT_SNOOP_TRANSACTIONS = "FALSE") or (VC_CAP_REJECT_SNOOP_TRANSACTIONS = "false")) then
        VC_CAP_REJECT_SNOOP_TRANSACTIONS_BINARY <= '0';
      elsif((VC_CAP_REJECT_SNOOP_TRANSACTIONS = "TRUE") or (VC_CAP_REJECT_SNOOP_TRANSACTIONS= "true")) then
        VC_CAP_REJECT_SNOOP_TRANSACTIONS_BINARY <= '1';
      else
        assert FALSE report "Error : VC_CAP_REJECT_SNOOP_TRANSACTIONS = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case VSEC_CAP_IS_LINK_VISIBLE is
      if((VSEC_CAP_IS_LINK_VISIBLE = "TRUE") or (VSEC_CAP_IS_LINK_VISIBLE = "true")) then
        VSEC_CAP_IS_LINK_VISIBLE_BINARY <= '1';
      elsif((VSEC_CAP_IS_LINK_VISIBLE = "FALSE") or (VSEC_CAP_IS_LINK_VISIBLE= "false")) then
        VSEC_CAP_IS_LINK_VISIBLE_BINARY <= '0';
      else
        assert FALSE report "Error : VSEC_CAP_IS_LINK_VISIBLE = is not TRUE, FALSE." severity error;
      end if;
    -- end case;
    -- case VSEC_CAP_ON is
      if((VSEC_CAP_ON = "FALSE") or (VSEC_CAP_ON = "false")) then
        VSEC_CAP_ON_BINARY <= '0';
      elsif((VSEC_CAP_ON = "TRUE") or (VSEC_CAP_ON= "true")) then
        VSEC_CAP_ON_BINARY <= '1';
      else
        assert FALSE report "Error : VSEC_CAP_ON = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    case LINK_CAP_RSVD_23 is
      when  0   =>  LINK_CAP_RSVD_23_BINARY <= '0';
      when  1   =>  LINK_CAP_RSVD_23_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CAP_RSVD_23 is not in range 0 .. 1." severity error;
    end case;
    case LINK_CONTROL_RCB is
      when  0   =>  LINK_CONTROL_RCB_BINARY <= '0';
      when  1   =>  LINK_CONTROL_RCB_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CONTROL_RCB is not in range 0 .. 1." severity error;
    end case;
    case MSI_CAP_MULTIMSG_EXTENSION is
      when  0   =>  MSI_CAP_MULTIMSG_EXTENSION_BINARY <= '0';
      when  1   =>  MSI_CAP_MULTIMSG_EXTENSION_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MSI_CAP_MULTIMSG_EXTENSION is not in range 0 .. 1." severity error;
    end case;
    case PM_CAP_RSVD_04 is
      when  0   =>  PM_CAP_RSVD_04_BINARY <= '0';
      when  1   =>  PM_CAP_RSVD_04_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_RSVD_04 is not in range 0 .. 1." severity error;
    end case;
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
    case TL_RX_RAM_RADDR_LATENCY is
      when  0   =>  TL_RX_RAM_RADDR_LATENCY_BINARY <= '0';
      when  1   =>  TL_RX_RAM_RADDR_LATENCY_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TL_RX_RAM_RADDR_LATENCY is not in range 0 .. 1." severity error;
    end case;
    case TL_RX_RAM_WRITE_LATENCY is
      when  0   =>  TL_RX_RAM_WRITE_LATENCY_BINARY <= '0';
      when  1   =>  TL_RX_RAM_WRITE_LATENCY_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TL_RX_RAM_WRITE_LATENCY is not in range 0 .. 1." severity error;
    end case;
    case TL_TX_RAM_RADDR_LATENCY is
      when  0   =>  TL_TX_RAM_RADDR_LATENCY_BINARY <= '0';
      when  1   =>  TL_TX_RAM_RADDR_LATENCY_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TL_TX_RAM_RADDR_LATENCY is not in range 0 .. 1." severity error;
    end case;
    case TL_TX_RAM_WRITE_LATENCY is
      when  0   =>  TL_TX_RAM_WRITE_LATENCY_BINARY <= '0';
      when  1   =>  TL_TX_RAM_WRITE_LATENCY_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TL_TX_RAM_WRITE_LATENCY is not in range 0 .. 1." severity error;
    end case;
    if ((CFG_ECRC_ERR_CPLSTAT >= 0) and (CFG_ECRC_ERR_CPLSTAT <= 3)) then
      CFG_ECRC_ERR_CPLSTAT_BINARY <= CONV_STD_LOGIC_VECTOR(CFG_ECRC_ERR_CPLSTAT, 2);
    else
      assert FALSE report "Error : CFG_ECRC_ERR_CPLSTAT is not in range 0 .. 3." severity error;
    end if;
    if ((DEV_CAP_ENDPOINT_L0S_LATENCY >= 0) and (DEV_CAP_ENDPOINT_L0S_LATENCY <= 7)) then
      DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY <= CONV_STD_LOGIC_VECTOR(DEV_CAP_ENDPOINT_L0S_LATENCY, 3);
    else
      assert FALSE report "Error : DEV_CAP_ENDPOINT_L0S_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((DEV_CAP_ENDPOINT_L1_LATENCY >= 0) and (DEV_CAP_ENDPOINT_L1_LATENCY <= 7)) then
      DEV_CAP_ENDPOINT_L1_LATENCY_BINARY <= CONV_STD_LOGIC_VECTOR(DEV_CAP_ENDPOINT_L1_LATENCY, 3);
    else
      assert FALSE report "Error : DEV_CAP_ENDPOINT_L1_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((DEV_CAP_MAX_PAYLOAD_SUPPORTED >= 0) and (DEV_CAP_MAX_PAYLOAD_SUPPORTED <= 7)) then
      DEV_CAP_MAX_PAYLOAD_SUPPORTED_BINARY <= CONV_STD_LOGIC_VECTOR(DEV_CAP_MAX_PAYLOAD_SUPPORTED, 3);
    else
      assert FALSE report "Error : DEV_CAP_MAX_PAYLOAD_SUPPORTED is not in range 0 .. 7." severity error;
    end if;
    if ((DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT >= 0) and (DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT <= 3)) then
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT_BINARY <= CONV_STD_LOGIC_VECTOR(DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT, 2);
    else
      assert FALSE report "Error : DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT is not in range 0 .. 3." severity error;
    end if;
    if ((DEV_CAP_RSVD_14_12 >= 0) and (DEV_CAP_RSVD_14_12 <= 7)) then
      DEV_CAP_RSVD_14_12_BINARY <= CONV_STD_LOGIC_VECTOR(DEV_CAP_RSVD_14_12, 3);
    else
      assert FALSE report "Error : DEV_CAP_RSVD_14_12 is not in range 0 .. 7." severity error;
    end if;
    if ((DEV_CAP_RSVD_17_16 >= 0) and (DEV_CAP_RSVD_17_16 <= 3)) then
      DEV_CAP_RSVD_17_16_BINARY <= CONV_STD_LOGIC_VECTOR(DEV_CAP_RSVD_17_16, 2);
    else
      assert FALSE report "Error : DEV_CAP_RSVD_17_16 is not in range 0 .. 3." severity error;
    end if;
    if ((DEV_CAP_RSVD_31_29 >= 0) and (DEV_CAP_RSVD_31_29 <= 7)) then
      DEV_CAP_RSVD_31_29_BINARY <= CONV_STD_LOGIC_VECTOR(DEV_CAP_RSVD_31_29, 3);
    else
      assert FALSE report "Error : DEV_CAP_RSVD_31_29 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_ASPM_SUPPORT >= 0) and (LINK_CAP_ASPM_SUPPORT <= 3)) then
      LINK_CAP_ASPM_SUPPORT_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_ASPM_SUPPORT, 2);
    else
      assert FALSE report "Error : LINK_CAP_ASPM_SUPPORT is not in range 0 .. 3." severity error;
    end if;
    if ((LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 >= 0) and (LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 <= 7)) then
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1, 3);
    else
      assert FALSE report "Error : LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 >= 0) and (LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 <= 7)) then
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2, 3);
    else
      assert FALSE report "Error : LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L0S_EXIT_LATENCY_GEN1 >= 0) and (LINK_CAP_L0S_EXIT_LATENCY_GEN1 <= 7)) then
      LINK_CAP_L0S_EXIT_LATENCY_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L0S_EXIT_LATENCY_GEN1, 3);
    else
      assert FALSE report "Error : LINK_CAP_L0S_EXIT_LATENCY_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L0S_EXIT_LATENCY_GEN2 >= 0) and (LINK_CAP_L0S_EXIT_LATENCY_GEN2 <= 7)) then
      LINK_CAP_L0S_EXIT_LATENCY_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L0S_EXIT_LATENCY_GEN2, 3);
    else
      assert FALSE report "Error : LINK_CAP_L0S_EXIT_LATENCY_GEN2 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 >= 0) and (LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 <= 7)) then
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1, 3);
    else
      assert FALSE report "Error : LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 >= 0) and (LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 <= 7)) then
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2, 3);
    else
      assert FALSE report "Error : LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L1_EXIT_LATENCY_GEN1 >= 0) and (LINK_CAP_L1_EXIT_LATENCY_GEN1 <= 7)) then
      LINK_CAP_L1_EXIT_LATENCY_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L1_EXIT_LATENCY_GEN1, 3);
    else
      assert FALSE report "Error : LINK_CAP_L1_EXIT_LATENCY_GEN1 is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L1_EXIT_LATENCY_GEN2 >= 0) and (LINK_CAP_L1_EXIT_LATENCY_GEN2 <= 7)) then
      LINK_CAP_L1_EXIT_LATENCY_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_L1_EXIT_LATENCY_GEN2, 3);
    else
      assert FALSE report "Error : LINK_CAP_L1_EXIT_LATENCY_GEN2 is not in range 0 .. 7." severity error;
    end if;
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
    if ((MSIX_CAP_PBA_BIR >= 0) and (MSIX_CAP_PBA_BIR <= 7)) then
      MSIX_CAP_PBA_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(MSIX_CAP_PBA_BIR, 3);
    else
      assert FALSE report "Error : MSIX_CAP_PBA_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((MSIX_CAP_TABLE_BIR >= 0) and (MSIX_CAP_TABLE_BIR <= 7)) then
      MSIX_CAP_TABLE_BIR_BINARY <= CONV_STD_LOGIC_VECTOR(MSIX_CAP_TABLE_BIR, 3);
    else
      assert FALSE report "Error : MSIX_CAP_TABLE_BIR is not in range 0 .. 7." severity error;
    end if;
    if ((MSI_CAP_MULTIMSGCAP >= 0) and (MSI_CAP_MULTIMSGCAP <= 7)) then
      MSI_CAP_MULTIMSGCAP_BINARY <= CONV_STD_LOGIC_VECTOR(MSI_CAP_MULTIMSGCAP, 3);
    else
      assert FALSE report "Error : MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
    if ((N_FTS_COMCLK_GEN1 >= 0) and (N_FTS_COMCLK_GEN1 <= 255)) then
      N_FTS_COMCLK_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(N_FTS_COMCLK_GEN1, 8);
    else
      assert FALSE report "Error : N_FTS_COMCLK_GEN1 is not in range 0 .. 255." severity error;
    end if;
    if ((N_FTS_COMCLK_GEN2 >= 0) and (N_FTS_COMCLK_GEN2 <= 255)) then
      N_FTS_COMCLK_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(N_FTS_COMCLK_GEN2, 8);
    else
      assert FALSE report "Error : N_FTS_COMCLK_GEN2 is not in range 0 .. 255." severity error;
    end if;
    if ((N_FTS_GEN1 >= 0) and (N_FTS_GEN1 <= 255)) then
      N_FTS_GEN1_BINARY <= CONV_STD_LOGIC_VECTOR(N_FTS_GEN1, 8);
    else
      assert FALSE report "Error : N_FTS_GEN1 is not in range 0 .. 255." severity error;
    end if;
    if ((N_FTS_GEN2 >= 0) and (N_FTS_GEN2 <= 255)) then
      N_FTS_GEN2_BINARY <= CONV_STD_LOGIC_VECTOR(N_FTS_GEN2, 8);
    else
      assert FALSE report "Error : N_FTS_GEN2 is not in range 0 .. 255." severity error;
    end if;
    if ((PCIE_CAP_RSVD_15_14 >= 0) and (PCIE_CAP_RSVD_15_14 <= 3)) then
      PCIE_CAP_RSVD_15_14_BINARY <= CONV_STD_LOGIC_VECTOR(PCIE_CAP_RSVD_15_14, 2);
    else
      assert FALSE report "Error : PCIE_CAP_RSVD_15_14 is not in range 0 .. 3." severity error;
    end if;
    if ((PCIE_REVISION >= 0) and (PCIE_REVISION <= 15)) then
      PCIE_REVISION_BINARY <= CONV_STD_LOGIC_VECTOR(PCIE_REVISION, 4);
    else
      assert FALSE report "Error : PCIE_REVISION is not in range 0 .. 15." severity error;
    end if;
    if ((PL_AUTO_CONFIG >= 0) and (PL_AUTO_CONFIG <= 7)) then
      PL_AUTO_CONFIG_BINARY <= CONV_STD_LOGIC_VECTOR(PL_AUTO_CONFIG, 3);
    else
      assert FALSE report "Error : PL_AUTO_CONFIG is not in range 0 .. 7." severity error;
    end if;
    if ((PM_ASPML0S_TIMEOUT_FUNC >= 0) and (PM_ASPML0S_TIMEOUT_FUNC <= 3)) then
      PM_ASPML0S_TIMEOUT_FUNC_BINARY <= CONV_STD_LOGIC_VECTOR(PM_ASPML0S_TIMEOUT_FUNC, 2);
    else
      assert FALSE report "Error : PM_ASPML0S_TIMEOUT_FUNC is not in range 0 .. 3." severity error;
    end if;
    if ((PM_CAP_AUXCURRENT >= 0) and (PM_CAP_AUXCURRENT <= 7)) then
      PM_CAP_AUXCURRENT_BINARY <= CONV_STD_LOGIC_VECTOR(PM_CAP_AUXCURRENT, 3);
    else
      assert FALSE report "Error : PM_CAP_AUXCURRENT is not in range 0 .. 7." severity error;
    end if;
    if ((PM_CAP_VERSION >= 0) and (PM_CAP_VERSION <= 7)) then
      PM_CAP_VERSION_BINARY <= CONV_STD_LOGIC_VECTOR(PM_CAP_VERSION, 3);
    else
      assert FALSE report "Error : PM_CAP_VERSION is not in range 0 .. 7." severity error;
    end if;
    if ((RECRC_CHK >= 0) and (RECRC_CHK <= 3)) then
      RECRC_CHK_BINARY <= CONV_STD_LOGIC_VECTOR(RECRC_CHK, 2);
    else
      assert FALSE report "Error : RECRC_CHK is not in range 0 .. 3." severity error;
    end if;
    if ((SLOT_CAP_SLOT_POWER_LIMIT_SCALE >= 0) and (SLOT_CAP_SLOT_POWER_LIMIT_SCALE <= 3)) then
      SLOT_CAP_SLOT_POWER_LIMIT_SCALE_BINARY <= CONV_STD_LOGIC_VECTOR(SLOT_CAP_SLOT_POWER_LIMIT_SCALE, 2);
    else
      assert FALSE report "Error : SLOT_CAP_SLOT_POWER_LIMIT_SCALE is not in range 0 .. 3." severity error;
    end if;
    if ((TL_RX_RAM_RDATA_LATENCY >= 0) and (TL_RX_RAM_RDATA_LATENCY <= 3)) then
      TL_RX_RAM_RDATA_LATENCY_BINARY <= CONV_STD_LOGIC_VECTOR(TL_RX_RAM_RDATA_LATENCY, 2);
    else
      assert FALSE report "Error : TL_RX_RAM_RDATA_LATENCY is not in range 0 .. 3." severity error;
    end if;
    if ((TL_TX_RAM_RDATA_LATENCY >= 0) and (TL_TX_RAM_RDATA_LATENCY <= 3)) then
      TL_TX_RAM_RDATA_LATENCY_BINARY <= CONV_STD_LOGIC_VECTOR(TL_TX_RAM_RDATA_LATENCY, 2);
    else
      assert FALSE report "Error : TL_TX_RAM_RDATA_LATENCY is not in range 0 .. 3." severity error;
    end if;
    if ((USER_CLK_FREQ >= 0) and (USER_CLK_FREQ <= 7)) then
      USER_CLK_FREQ_BINARY <= CONV_STD_LOGIC_VECTOR(USER_CLK_FREQ, 3);
    else
      assert FALSE report "Error : USER_CLK_FREQ is not in range 0 .. 7." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_CD >= 0) and (VC0_TOTAL_CREDITS_CD <= 2047)) then
      VC0_TOTAL_CREDITS_CD_BINARY <= CONV_STD_LOGIC_VECTOR(VC0_TOTAL_CREDITS_CD, 11);
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_CD is not in range 0 .. 2047." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_CH >= 0) and (VC0_TOTAL_CREDITS_CH <= 127)) then
      VC0_TOTAL_CREDITS_CH_BINARY <= CONV_STD_LOGIC_VECTOR(VC0_TOTAL_CREDITS_CH, 7);
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_CH is not in range 0 .. 127." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_NPD >= 0) and (VC0_TOTAL_CREDITS_NPD <= 2047)) then
      VC0_TOTAL_CREDITS_NPD_BINARY <= CONV_STD_LOGIC_VECTOR(VC0_TOTAL_CREDITS_NPD, 11);
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_NPD is not in range 0 .. 2047." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_NPH >= 0) and (VC0_TOTAL_CREDITS_NPH <= 127)) then
      VC0_TOTAL_CREDITS_NPH_BINARY <= CONV_STD_LOGIC_VECTOR(VC0_TOTAL_CREDITS_NPH, 7);
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_NPH is not in range 0 .. 127." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_PD >= 0) and (VC0_TOTAL_CREDITS_PD <= 2047)) then
      VC0_TOTAL_CREDITS_PD_BINARY <= CONV_STD_LOGIC_VECTOR(VC0_TOTAL_CREDITS_PD, 11);
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_PD is not in range 0 .. 2047." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_PH >= 0) and (VC0_TOTAL_CREDITS_PH <= 127)) then
      VC0_TOTAL_CREDITS_PH_BINARY <= CONV_STD_LOGIC_VECTOR(VC0_TOTAL_CREDITS_PH, 7);
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_PH is not in range 0 .. 127." severity error;
    end if;
    if ((VC0_TX_LASTPACKET >= 0) and (VC0_TX_LASTPACKET <= 31)) then
      VC0_TX_LASTPACKET_BINARY <= CONV_STD_LOGIC_VECTOR(VC0_TX_LASTPACKET, 5);
    else
      assert FALSE report "Error : VC0_TX_LASTPACKET is not in range 0 .. 31." severity error;
    end if;
    wait;
    end process INIPROC;
    CFGAERECRCCHECKEN <= CFGAERECRCCHECKEN_out;
    CFGAERECRCGENEN <= CFGAERECRCGENEN_out;
    CFGAERROOTERRCORRERRRECEIVED <= CFGAERROOTERRCORRERRRECEIVED_out;
    CFGAERROOTERRCORRERRREPORTINGEN <= CFGAERROOTERRCORRERRREPORTINGEN_out;
    CFGAERROOTERRFATALERRRECEIVED <= CFGAERROOTERRFATALERRRECEIVED_out;
    CFGAERROOTERRFATALERRREPORTINGEN <= CFGAERROOTERRFATALERRREPORTINGEN_out;
    CFGAERROOTERRNONFATALERRRECEIVED <= CFGAERROOTERRNONFATALERRRECEIVED_out;
    CFGAERROOTERRNONFATALERRREPORTINGEN <= CFGAERROOTERRNONFATALERRREPORTINGEN_out;
    CFGBRIDGESERREN <= CFGBRIDGESERREN_out;
    CFGCOMMANDBUSMASTERENABLE <= CFGCOMMANDBUSMASTERENABLE_out;
    CFGCOMMANDINTERRUPTDISABLE <= CFGCOMMANDINTERRUPTDISABLE_out;
    CFGCOMMANDIOENABLE <= CFGCOMMANDIOENABLE_out;
    CFGCOMMANDMEMENABLE <= CFGCOMMANDMEMENABLE_out;
    CFGCOMMANDSERREN <= CFGCOMMANDSERREN_out;
    CFGDEVCONTROL2ARIFORWARDEN <= CFGDEVCONTROL2ARIFORWARDEN_out;
    CFGDEVCONTROL2ATOMICEGRESSBLOCK <= CFGDEVCONTROL2ATOMICEGRESSBLOCK_out;
    CFGDEVCONTROL2ATOMICREQUESTEREN <= CFGDEVCONTROL2ATOMICREQUESTEREN_out;
    CFGDEVCONTROL2CPLTIMEOUTDIS <= CFGDEVCONTROL2CPLTIMEOUTDIS_out;
    CFGDEVCONTROL2CPLTIMEOUTVAL <= CFGDEVCONTROL2CPLTIMEOUTVAL_out;
    CFGDEVCONTROL2IDOCPLEN <= CFGDEVCONTROL2IDOCPLEN_out;
    CFGDEVCONTROL2IDOREQEN <= CFGDEVCONTROL2IDOREQEN_out;
    CFGDEVCONTROL2LTREN <= CFGDEVCONTROL2LTREN_out;
    CFGDEVCONTROL2TLPPREFIXBLOCK <= CFGDEVCONTROL2TLPPREFIXBLOCK_out;
    CFGDEVCONTROLAUXPOWEREN <= CFGDEVCONTROLAUXPOWEREN_out;
    CFGDEVCONTROLCORRERRREPORTINGEN <= CFGDEVCONTROLCORRERRREPORTINGEN_out;
    CFGDEVCONTROLENABLERO <= CFGDEVCONTROLENABLERO_out;
    CFGDEVCONTROLEXTTAGEN <= CFGDEVCONTROLEXTTAGEN_out;
    CFGDEVCONTROLFATALERRREPORTINGEN <= CFGDEVCONTROLFATALERRREPORTINGEN_out;
    CFGDEVCONTROLMAXPAYLOAD <= CFGDEVCONTROLMAXPAYLOAD_out;
    CFGDEVCONTROLMAXREADREQ <= CFGDEVCONTROLMAXREADREQ_out;
    CFGDEVCONTROLNONFATALREPORTINGEN <= CFGDEVCONTROLNONFATALREPORTINGEN_out;
    CFGDEVCONTROLNOSNOOPEN <= CFGDEVCONTROLNOSNOOPEN_out;
    CFGDEVCONTROLPHANTOMEN <= CFGDEVCONTROLPHANTOMEN_out;
    CFGDEVCONTROLURERRREPORTINGEN <= CFGDEVCONTROLURERRREPORTINGEN_out;
    CFGDEVSTATUSCORRERRDETECTED <= CFGDEVSTATUSCORRERRDETECTED_out;
    CFGDEVSTATUSFATALERRDETECTED <= CFGDEVSTATUSFATALERRDETECTED_out;
    CFGDEVSTATUSNONFATALERRDETECTED <= CFGDEVSTATUSNONFATALERRDETECTED_out;
    CFGDEVSTATUSURDETECTED <= CFGDEVSTATUSURDETECTED_out;
    CFGERRAERHEADERLOGSETN <= CFGERRAERHEADERLOGSETN_out;
    CFGERRCPLRDYN <= CFGERRCPLRDYN_out;
    CFGINTERRUPTDO <= CFGINTERRUPTDO_out;
    CFGINTERRUPTMMENABLE <= CFGINTERRUPTMMENABLE_out;
    CFGINTERRUPTMSIENABLE <= CFGINTERRUPTMSIENABLE_out;
    CFGINTERRUPTMSIXENABLE <= CFGINTERRUPTMSIXENABLE_out;
    CFGINTERRUPTMSIXFM <= CFGINTERRUPTMSIXFM_out;
    CFGINTERRUPTRDYN <= CFGINTERRUPTRDYN_out;
    CFGLINKCONTROLASPMCONTROL <= CFGLINKCONTROLASPMCONTROL_out;
    CFGLINKCONTROLAUTOBANDWIDTHINTEN <= CFGLINKCONTROLAUTOBANDWIDTHINTEN_out;
    CFGLINKCONTROLBANDWIDTHINTEN <= CFGLINKCONTROLBANDWIDTHINTEN_out;
    CFGLINKCONTROLCLOCKPMEN <= CFGLINKCONTROLCLOCKPMEN_out;
    CFGLINKCONTROLCOMMONCLOCK <= CFGLINKCONTROLCOMMONCLOCK_out;
    CFGLINKCONTROLEXTENDEDSYNC <= CFGLINKCONTROLEXTENDEDSYNC_out;
    CFGLINKCONTROLHWAUTOWIDTHDIS <= CFGLINKCONTROLHWAUTOWIDTHDIS_out;
    CFGLINKCONTROLLINKDISABLE <= CFGLINKCONTROLLINKDISABLE_out;
    CFGLINKCONTROLRCB <= CFGLINKCONTROLRCB_out;
    CFGLINKCONTROLRETRAINLINK <= CFGLINKCONTROLRETRAINLINK_out;
    CFGLINKSTATUSAUTOBANDWIDTHSTATUS <= CFGLINKSTATUSAUTOBANDWIDTHSTATUS_out;
    CFGLINKSTATUSBANDWIDTHSTATUS <= CFGLINKSTATUSBANDWIDTHSTATUS_out;
    CFGLINKSTATUSCURRENTSPEED <= CFGLINKSTATUSCURRENTSPEED_out;
    CFGLINKSTATUSDLLACTIVE <= CFGLINKSTATUSDLLACTIVE_out;
    CFGLINKSTATUSLINKTRAINING <= CFGLINKSTATUSLINKTRAINING_out;
    CFGLINKSTATUSNEGOTIATEDWIDTH <= CFGLINKSTATUSNEGOTIATEDWIDTH_out;
    CFGMGMTDO <= CFGMGMTDO_out;
    CFGMGMTRDWRDONEN <= CFGMGMTRDWRDONEN_out;
    CFGMSGDATA <= CFGMSGDATA_out;
    CFGMSGRECEIVED <= CFGMSGRECEIVED_out;
    CFGMSGRECEIVEDASSERTINTA <= CFGMSGRECEIVEDASSERTINTA_out;
    CFGMSGRECEIVEDASSERTINTB <= CFGMSGRECEIVEDASSERTINTB_out;
    CFGMSGRECEIVEDASSERTINTC <= CFGMSGRECEIVEDASSERTINTC_out;
    CFGMSGRECEIVEDASSERTINTD <= CFGMSGRECEIVEDASSERTINTD_out;
    CFGMSGRECEIVEDDEASSERTINTA <= CFGMSGRECEIVEDDEASSERTINTA_out;
    CFGMSGRECEIVEDDEASSERTINTB <= CFGMSGRECEIVEDDEASSERTINTB_out;
    CFGMSGRECEIVEDDEASSERTINTC <= CFGMSGRECEIVEDDEASSERTINTC_out;
    CFGMSGRECEIVEDDEASSERTINTD <= CFGMSGRECEIVEDDEASSERTINTD_out;
    CFGMSGRECEIVEDERRCOR <= CFGMSGRECEIVEDERRCOR_out;
    CFGMSGRECEIVEDERRFATAL <= CFGMSGRECEIVEDERRFATAL_out;
    CFGMSGRECEIVEDERRNONFATAL <= CFGMSGRECEIVEDERRNONFATAL_out;
    CFGMSGRECEIVEDPMASNAK <= CFGMSGRECEIVEDPMASNAK_out;
    CFGMSGRECEIVEDPMETO <= CFGMSGRECEIVEDPMETO_out;
    CFGMSGRECEIVEDPMETOACK <= CFGMSGRECEIVEDPMETOACK_out;
    CFGMSGRECEIVEDPMPME <= CFGMSGRECEIVEDPMPME_out;
    CFGMSGRECEIVEDSETSLOTPOWERLIMIT <= CFGMSGRECEIVEDSETSLOTPOWERLIMIT_out;
    CFGMSGRECEIVEDUNLOCK <= CFGMSGRECEIVEDUNLOCK_out;
    CFGPCIELINKSTATE <= CFGPCIELINKSTATE_out;
    CFGPMCSRPMEEN <= CFGPMCSRPMEEN_out;
    CFGPMCSRPMESTATUS <= CFGPMCSRPMESTATUS_out;
    CFGPMCSRPOWERSTATE <= CFGPMCSRPOWERSTATE_out;
    CFGPMRCVASREQL1N <= CFGPMRCVASREQL1N_out;
    CFGPMRCVENTERL1N <= CFGPMRCVENTERL1N_out;
    CFGPMRCVENTERL23N <= CFGPMRCVENTERL23N_out;
    CFGPMRCVREQACKN <= CFGPMRCVREQACKN_out;
    CFGROOTCONTROLPMEINTEN <= CFGROOTCONTROLPMEINTEN_out;
    CFGROOTCONTROLSYSERRCORRERREN <= CFGROOTCONTROLSYSERRCORRERREN_out;
    CFGROOTCONTROLSYSERRFATALERREN <= CFGROOTCONTROLSYSERRFATALERREN_out;
    CFGROOTCONTROLSYSERRNONFATALERREN <= CFGROOTCONTROLSYSERRNONFATALERREN_out;
    CFGSLOTCONTROLELECTROMECHILCTLPULSE <= CFGSLOTCONTROLELECTROMECHILCTLPULSE_out;
    CFGTRANSACTION <= CFGTRANSACTION_out;
    CFGTRANSACTIONADDR <= CFGTRANSACTIONADDR_out;
    CFGTRANSACTIONTYPE <= CFGTRANSACTIONTYPE_out;
    CFGVCTCVCMAP <= CFGVCTCVCMAP_out;
    DBGSCLRA <= DBGSCLRA_out;
    DBGSCLRB <= DBGSCLRB_out;
    DBGSCLRC <= DBGSCLRC_out;
    DBGSCLRD <= DBGSCLRD_out;
    DBGSCLRE <= DBGSCLRE_out;
    DBGSCLRF <= DBGSCLRF_out;
    DBGSCLRG <= DBGSCLRG_out;
    DBGSCLRH <= DBGSCLRH_out;
    DBGSCLRI <= DBGSCLRI_out;
    DBGSCLRJ <= DBGSCLRJ_out;
    DBGSCLRK <= DBGSCLRK_out;
    DBGVECA <= DBGVECA_out;
    DBGVECB <= DBGVECB_out;
    DBGVECC <= DBGVECC_out;
    DRPDO <= DRPDO_out;
    DRPRDY <= DRPRDY_out;
    LL2BADDLLPERR <= LL2BADDLLPERR_out;
    LL2BADTLPERR <= LL2BADTLPERR_out;
    LL2LINKSTATUS <= LL2LINKSTATUS_out;
    LL2PROTOCOLERR <= LL2PROTOCOLERR_out;
    LL2RECEIVERERR <= LL2RECEIVERERR_out;
    LL2REPLAYROERR <= LL2REPLAYROERR_out;
    LL2REPLAYTOERR <= LL2REPLAYTOERR_out;
    LL2SUSPENDOK <= LL2SUSPENDOK_out;
    LL2TFCINIT1SEQ <= LL2TFCINIT1SEQ_out;
    LL2TFCINIT2SEQ <= LL2TFCINIT2SEQ_out;
    LL2TXIDLE <= LL2TXIDLE_out;
    LNKCLKEN <= LNKCLKEN_out;
    MIMRXRADDR <= MIMRXRADDR_out;
    MIMRXREN <= MIMRXREN_out;
    MIMRXWADDR <= MIMRXWADDR_out;
    MIMRXWDATA <= MIMRXWDATA_out;
    MIMRXWEN <= MIMRXWEN_out;
    MIMTXRADDR <= MIMTXRADDR_out;
    MIMTXREN <= MIMTXREN_out;
    MIMTXWADDR <= MIMTXWADDR_out;
    MIMTXWDATA <= MIMTXWDATA_out;
    MIMTXWEN <= MIMTXWEN_out;
    PIPERX0POLARITY <= PIPERX0POLARITY_out;
    PIPERX1POLARITY <= PIPERX1POLARITY_out;
    PIPERX2POLARITY <= PIPERX2POLARITY_out;
    PIPERX3POLARITY <= PIPERX3POLARITY_out;
    PIPERX4POLARITY <= PIPERX4POLARITY_out;
    PIPERX5POLARITY <= PIPERX5POLARITY_out;
    PIPERX6POLARITY <= PIPERX6POLARITY_out;
    PIPERX7POLARITY <= PIPERX7POLARITY_out;
    PIPETX0CHARISK <= PIPETX0CHARISK_out;
    PIPETX0COMPLIANCE <= PIPETX0COMPLIANCE_out;
    PIPETX0DATA <= PIPETX0DATA_out;
    PIPETX0ELECIDLE <= PIPETX0ELECIDLE_out;
    PIPETX0POWERDOWN <= PIPETX0POWERDOWN_out;
    PIPETX1CHARISK <= PIPETX1CHARISK_out;
    PIPETX1COMPLIANCE <= PIPETX1COMPLIANCE_out;
    PIPETX1DATA <= PIPETX1DATA_out;
    PIPETX1ELECIDLE <= PIPETX1ELECIDLE_out;
    PIPETX1POWERDOWN <= PIPETX1POWERDOWN_out;
    PIPETX2CHARISK <= PIPETX2CHARISK_out;
    PIPETX2COMPLIANCE <= PIPETX2COMPLIANCE_out;
    PIPETX2DATA <= PIPETX2DATA_out;
    PIPETX2ELECIDLE <= PIPETX2ELECIDLE_out;
    PIPETX2POWERDOWN <= PIPETX2POWERDOWN_out;
    PIPETX3CHARISK <= PIPETX3CHARISK_out;
    PIPETX3COMPLIANCE <= PIPETX3COMPLIANCE_out;
    PIPETX3DATA <= PIPETX3DATA_out;
    PIPETX3ELECIDLE <= PIPETX3ELECIDLE_out;
    PIPETX3POWERDOWN <= PIPETX3POWERDOWN_out;
    PIPETX4CHARISK <= PIPETX4CHARISK_out;
    PIPETX4COMPLIANCE <= PIPETX4COMPLIANCE_out;
    PIPETX4DATA <= PIPETX4DATA_out;
    PIPETX4ELECIDLE <= PIPETX4ELECIDLE_out;
    PIPETX4POWERDOWN <= PIPETX4POWERDOWN_out;
    PIPETX5CHARISK <= PIPETX5CHARISK_out;
    PIPETX5COMPLIANCE <= PIPETX5COMPLIANCE_out;
    PIPETX5DATA <= PIPETX5DATA_out;
    PIPETX5ELECIDLE <= PIPETX5ELECIDLE_out;
    PIPETX5POWERDOWN <= PIPETX5POWERDOWN_out;
    PIPETX6CHARISK <= PIPETX6CHARISK_out;
    PIPETX6COMPLIANCE <= PIPETX6COMPLIANCE_out;
    PIPETX6DATA <= PIPETX6DATA_out;
    PIPETX6ELECIDLE <= PIPETX6ELECIDLE_out;
    PIPETX6POWERDOWN <= PIPETX6POWERDOWN_out;
    PIPETX7CHARISK <= PIPETX7CHARISK_out;
    PIPETX7COMPLIANCE <= PIPETX7COMPLIANCE_out;
    PIPETX7DATA <= PIPETX7DATA_out;
    PIPETX7ELECIDLE <= PIPETX7ELECIDLE_out;
    PIPETX7POWERDOWN <= PIPETX7POWERDOWN_out;
    PIPETXDEEMPH <= PIPETXDEEMPH_out;
    PIPETXMARGIN <= PIPETXMARGIN_out;
    PIPETXRATE <= PIPETXRATE_out;
    PIPETXRCVRDET <= PIPETXRCVRDET_out;
    PIPETXRESET <= PIPETXRESET_out;
    PL2L0REQ <= PL2L0REQ_out;
    PL2LINKUP <= PL2LINKUP_out;
    PL2RECEIVERERR <= PL2RECEIVERERR_out;
    PL2RECOVERY <= PL2RECOVERY_out;
    PL2RXELECIDLE <= PL2RXELECIDLE_out;
    PL2RXPMSTATE <= PL2RXPMSTATE_out;
    PL2SUSPENDOK <= PL2SUSPENDOK_out;
    PLDBGVEC <= PLDBGVEC_out;
    PLDIRECTEDCHANGEDONE <= PLDIRECTEDCHANGEDONE_out;
    PLINITIALLINKWIDTH <= PLINITIALLINKWIDTH_out;
    PLLANEREVERSALMODE <= PLLANEREVERSALMODE_out;
    PLLINKGEN2CAP <= PLLINKGEN2CAP_out;
    PLLINKPARTNERGEN2SUPPORTED <= PLLINKPARTNERGEN2SUPPORTED_out;
    PLLINKUPCFGCAP <= PLLINKUPCFGCAP_out;
    PLLTSSMSTATE <= PLLTSSMSTATE_out;
    PLPHYLNKUPN <= PLPHYLNKUPN_out;
    PLRECEIVEDHOTRST <= PLRECEIVEDHOTRST_out;
    PLRXPMSTATE <= PLRXPMSTATE_out;
    PLSELLNKRATE <= PLSELLNKRATE_out;
    PLSELLNKWIDTH <= PLSELLNKWIDTH_out;
    PLTXPMSTATE <= PLTXPMSTATE_out;
    RECEIVEDFUNCLVLRSTN <= RECEIVEDFUNCLVLRSTN_out;
    TL2ASPMSUSPENDCREDITCHECKOK <= TL2ASPMSUSPENDCREDITCHECKOK_out;
    TL2ASPMSUSPENDREQ <= TL2ASPMSUSPENDREQ_out;
    TL2ERRFCPE <= TL2ERRFCPE_out;
    TL2ERRHDR <= TL2ERRHDR_out;
    TL2ERRMALFORMED <= TL2ERRMALFORMED_out;
    TL2ERRRXOVERFLOW <= TL2ERRRXOVERFLOW_out;
    TL2PPMSUSPENDOK <= TL2PPMSUSPENDOK_out;
    TRNFCCPLD <= TRNFCCPLD_out;
    TRNFCCPLH <= TRNFCCPLH_out;
    TRNFCNPD <= TRNFCNPD_out;
    TRNFCNPH <= TRNFCNPH_out;
    TRNFCPD <= TRNFCPD_out;
    TRNFCPH <= TRNFCPH_out;
    TRNLNKUP <= TRNLNKUP_out;
    TRNRBARHIT <= TRNRBARHIT_out;
    TRNRD <= TRNRD_out;
    TRNRDLLPDATA <= TRNRDLLPDATA_out;
    TRNRDLLPSRCRDY <= TRNRDLLPSRCRDY_out;
    TRNRECRCERR <= TRNRECRCERR_out;
    TRNREOF <= TRNREOF_out;
    TRNRERRFWD <= TRNRERRFWD_out;
    TRNRREM <= TRNRREM_out;
    TRNRSOF <= TRNRSOF_out;
    TRNRSRCDSC <= TRNRSRCDSC_out;
    TRNRSRCRDY <= TRNRSRCRDY_out;
    TRNTBUFAV <= TRNTBUFAV_out;
    TRNTCFGREQ <= TRNTCFGREQ_out;
    TRNTDLLPDSTRDY <= TRNTDLLPDSTRDY_out;
    TRNTDSTRDY <= TRNTDSTRDY_out;
    TRNTERRDROP <= TRNTERRDROP_out;
    USERRSTN <= USERRSTN_out;
  end PCIE_2_1_V;
