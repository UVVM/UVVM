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
--  /   /                      
-- /___/   /\      Filename    : PCIE_2_0.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  05/30/08 - CR1014 - Initial version
--  06/06/08 - CR1014 - added component instantiation
--  06/06/08 - CR1014 - removed PIPETXSWING and added PLSELLNKWIDTH.
--  07/23/08 - CR1014 - CFGLINKCONTROLRCB typo updated in yml
--  10/02/08 - CR491285 - Publish complete PCIE_2_0 VHDL unisim wrapper
--  10/05/08 - CR491285 - Added conversion functions bv_to_integer,boolean_to_string to support vhdl mixed-mode simulation
--  10/13/08 - CR492333 - PCIE_2_0 yml parameter updates
--  10/28/08 - CR494036 - remove Vitalpathdelay, set OUT_DELAY to 100ps
--  11/11/08 - CR493971 - SIM_VERSION real to string
--  11/12/08 - CR496296 - convert parameter type bit_vector to string to support VHDL simulation
--  02/18/09 - CR509025 - New pins & timing paths added
--  04/01/09 - CR517362 - Updated constant section for VHDL mixed mode simulation
--  04/13/09 - CR518461 - Connect 4 new pins LNKCLKEN, CFGPMCSR* to RTL
--  05/05/09 - CR520519 - Update OUT_DELAY from 100ps to 0ps
--  07/28/09 - CR528331 - writer update, attribute changes
--  11/05/09 - CR538256 - Add GSR pulse as a workaround for vhdl coregen to work
----- CELL PCIE_2_0 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all; 
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity PCIE_2_0 is
    generic (
      AER_BASE_PTR : bit_vector := X"128";
      AER_CAP_ECRC_CHECK_CAPABLE : boolean := FALSE;
      AER_CAP_ECRC_GEN_CAPABLE : boolean := FALSE;
      AER_CAP_ID : bit_vector := X"1111";
      AER_CAP_INT_MSG_NUM_MSI : bit_vector := X"0A";
      AER_CAP_INT_MSG_NUM_MSIX : bit_vector := X"15";
      AER_CAP_NEXTPTR : bit_vector := X"160";
      AER_CAP_ON : boolean := FALSE;
      AER_CAP_PERMIT_ROOTERR_UPDATE : boolean := TRUE;
      AER_CAP_VERSION : bit_vector := X"1";
      ALLOW_X8_GEN2 : boolean := FALSE;
      BAR0 : bit_vector := X"FFFFFF00";
      BAR1 : bit_vector := X"FFFF0000";
      BAR2 : bit_vector := X"FFFF000C";
      BAR3 : bit_vector := X"FFFFFFFF";
      BAR4 : bit_vector := X"00000000";
      BAR5 : bit_vector := X"00000000";
      CAPABILITIES_PTR : bit_vector := X"40";
      CARDBUS_CIS_POINTER : bit_vector := X"00000000";
      CLASS_CODE : bit_vector := X"000000";
      CMD_INTX_IMPLEMENTED : boolean := TRUE;
      CPL_TIMEOUT_DISABLE_SUPPORTED : boolean := FALSE;
      CPL_TIMEOUT_RANGES_SUPPORTED : bit_vector := X"0";
      CRM_MODULE_RSTS : bit_vector := X"00";
      DEVICE_ID : bit_vector := X"0007";
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE : boolean := TRUE;
      DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE : boolean := TRUE;
      DEV_CAP_ENDPOINT_L0S_LATENCY : integer := 0;
      DEV_CAP_ENDPOINT_L1_LATENCY : integer := 0;
      DEV_CAP_EXT_TAG_SUPPORTED : boolean := TRUE;
      DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE : boolean := FALSE;
      DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer := 2;
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer := 0;
      DEV_CAP_ROLE_BASED_ERROR : boolean := TRUE;
      DEV_CAP_RSVD_14_12 : integer := 0;
      DEV_CAP_RSVD_17_16 : integer := 0;
      DEV_CAP_RSVD_31_29 : integer := 0;
      DEV_CONTROL_AUX_POWER_SUPPORTED : boolean := FALSE;
      DISABLE_ASPM_L1_TIMER : boolean := FALSE;
      DISABLE_BAR_FILTERING : boolean := FALSE;
      DISABLE_ID_CHECK : boolean := FALSE;
      DISABLE_LANE_REVERSAL : boolean := FALSE;
      DISABLE_RX_TC_FILTER : boolean := FALSE;
      DISABLE_SCRAMBLING : boolean := FALSE;
      DNSTREAM_LINK_NUM : bit_vector := X"00";
      DSN_BASE_PTR : bit_vector := X"100";
      DSN_CAP_ID : bit_vector := X"0003";
      DSN_CAP_NEXTPTR : bit_vector := X"000";
      DSN_CAP_ON : boolean := TRUE;
      DSN_CAP_VERSION : bit_vector := X"1";
      ENABLE_MSG_ROUTE : bit_vector := X"000";
      ENABLE_RX_TD_ECRC_TRIM : boolean := FALSE;
      ENTER_RVRY_EI_L0 : boolean := TRUE;
      EXIT_LOOPBACK_ON_EI : boolean := TRUE;
      EXPANSION_ROM : bit_vector := X"FFFFF001";
      EXT_CFG_CAP_PTR : bit_vector := X"3F";
      EXT_CFG_XP_CAP_PTR : bit_vector := X"3FF";
      HEADER_TYPE : bit_vector := X"00";
      INFER_EI : bit_vector := X"00";
      INTERRUPT_PIN : bit_vector := X"01";
      IS_SWITCH : boolean := FALSE;
      LAST_CONFIG_DWORD : bit_vector := X"042";
      LINK_CAP_ASPM_SUPPORT : integer := 1;
      LINK_CAP_CLOCK_POWER_MANAGEMENT : boolean := FALSE;
      LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP : boolean := FALSE;
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_GEN1 : integer := 7;
      LINK_CAP_L0S_EXIT_LATENCY_GEN2 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_GEN1 : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY_GEN2 : integer := 7;
      LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP : boolean := FALSE;
      LINK_CAP_MAX_LINK_SPEED : bit_vector := X"1";
      LINK_CAP_MAX_LINK_WIDTH : bit_vector := X"08";
      LINK_CAP_RSVD_23_22 : integer := 0;
      LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE : boolean := FALSE;
      LINK_CONTROL_RCB : integer := 0;
      LINK_CTRL2_DEEMPHASIS : boolean := FALSE;
      LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE : boolean := FALSE;
      LINK_CTRL2_TARGET_LINK_SPEED : bit_vector := X"2";
      LINK_STATUS_SLOT_CLOCK_CONFIG : boolean := TRUE;
      LL_ACK_TIMEOUT : bit_vector := X"0000";
      LL_ACK_TIMEOUT_EN : boolean := FALSE;
      LL_ACK_TIMEOUT_FUNC : integer := 0;
      LL_REPLAY_TIMEOUT : bit_vector := X"0000";
      LL_REPLAY_TIMEOUT_EN : boolean := FALSE;
      LL_REPLAY_TIMEOUT_FUNC : integer := 0;
      LTSSM_MAX_LINK_WIDTH : bit_vector := X"01";
      MSIX_BASE_PTR : bit_vector := X"9C";
      MSIX_CAP_ID : bit_vector := X"11";
      MSIX_CAP_NEXTPTR : bit_vector := X"00";
      MSIX_CAP_ON : boolean := FALSE;
      MSIX_CAP_PBA_BIR : integer := 0;
      MSIX_CAP_PBA_OFFSET : bit_vector := X"00000050";
      MSIX_CAP_TABLE_BIR : integer := 0;
      MSIX_CAP_TABLE_OFFSET : bit_vector := X"00000040";
      MSIX_CAP_TABLE_SIZE : bit_vector := X"000";
      MSI_BASE_PTR : bit_vector := X"48";
      MSI_CAP_64_BIT_ADDR_CAPABLE : boolean := TRUE;
      MSI_CAP_ID : bit_vector := X"05";
      MSI_CAP_MULTIMSGCAP : integer := 0;
      MSI_CAP_MULTIMSG_EXTENSION : integer := 0;
      MSI_CAP_NEXTPTR : bit_vector := X"60";
      MSI_CAP_ON : boolean := FALSE;
      MSI_CAP_PER_VECTOR_MASKING_CAPABLE : boolean := TRUE;
      N_FTS_COMCLK_GEN1 : integer := 255;
      N_FTS_COMCLK_GEN2 : integer := 255;
      N_FTS_GEN1 : integer := 255;
      N_FTS_GEN2 : integer := 255;
      PCIE_BASE_PTR : bit_vector := X"60";
      PCIE_CAP_CAPABILITY_ID : bit_vector := X"10";
      PCIE_CAP_CAPABILITY_VERSION : bit_vector := X"2";
      PCIE_CAP_DEVICE_PORT_TYPE : bit_vector := X"0";
      PCIE_CAP_INT_MSG_NUM : bit_vector := X"00";
      PCIE_CAP_NEXTPTR : bit_vector := X"00";
      PCIE_CAP_ON : boolean := TRUE;
      PCIE_CAP_RSVD_15_14 : integer := 0;
      PCIE_CAP_SLOT_IMPLEMENTED : boolean := FALSE;
      PCIE_REVISION : integer := 2;
      PGL0_LANE : integer := 0;
      PGL1_LANE : integer := 1;
      PGL2_LANE : integer := 2;
      PGL3_LANE : integer := 3;
      PGL4_LANE : integer := 4;
      PGL5_LANE : integer := 5;
      PGL6_LANE : integer := 6;
      PGL7_LANE : integer := 7;
      PL_AUTO_CONFIG : integer := 0;
      PL_FAST_TRAIN : boolean := FALSE;
      PM_BASE_PTR : bit_vector := X"40";
      PM_CAP_AUXCURRENT : integer := 0;
      PM_CAP_D1SUPPORT : boolean := TRUE;
      PM_CAP_D2SUPPORT : boolean := TRUE;
      PM_CAP_DSI : boolean := FALSE;
      PM_CAP_ID : bit_vector := X"11";
      PM_CAP_NEXTPTR : bit_vector := X"48";
      PM_CAP_ON : boolean := TRUE;
      PM_CAP_PMESUPPORT : bit_vector := X"0F";
      PM_CAP_PME_CLOCK : boolean := FALSE;
      PM_CAP_RSVD_04 : integer := 0;
      PM_CAP_VERSION : integer := 3;
      PM_CSR_B2B3 : boolean := FALSE;
      PM_CSR_BPCCEN : boolean := FALSE;
      PM_CSR_NOSOFTRST : boolean := TRUE;
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
      RECRC_CHK : integer := 0;
      RECRC_CHK_TRIM : boolean := FALSE;
      REVISION_ID : bit_vector := X"00";
      ROOT_CAP_CRS_SW_VISIBILITY : boolean := FALSE;
      SELECT_DLL_IF : boolean := FALSE;
      SIM_VERSION : string := "1.0";
      SLOT_CAP_ATT_BUTTON_PRESENT : boolean := FALSE;
      SLOT_CAP_ATT_INDICATOR_PRESENT : boolean := FALSE;
      SLOT_CAP_ELEC_INTERLOCK_PRESENT : boolean := FALSE;
      SLOT_CAP_HOTPLUG_CAPABLE : boolean := FALSE;
      SLOT_CAP_HOTPLUG_SURPRISE : boolean := FALSE;
      SLOT_CAP_MRL_SENSOR_PRESENT : boolean := FALSE;
      SLOT_CAP_NO_CMD_COMPLETED_SUPPORT : boolean := FALSE;
      SLOT_CAP_PHYSICAL_SLOT_NUM : bit_vector := X"0000";
      SLOT_CAP_POWER_CONTROLLER_PRESENT : boolean := FALSE;
      SLOT_CAP_POWER_INDICATOR_PRESENT : boolean := FALSE;
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
      SUBSYSTEM_ID : bit_vector := X"0007";
      SUBSYSTEM_VENDOR_ID : bit_vector := X"10EE";
      TL_RBYPASS : boolean := FALSE;
      TL_RX_RAM_RADDR_LATENCY : integer := 0;
      TL_RX_RAM_RDATA_LATENCY : integer := 2;
      TL_RX_RAM_WRITE_LATENCY : integer := 0;
      TL_TFC_DISABLE : boolean := FALSE;
      TL_TX_CHECKS_DISABLE : boolean := FALSE;
      TL_TX_RAM_RADDR_LATENCY : integer := 0;
      TL_TX_RAM_RDATA_LATENCY : integer := 2;
      TL_TX_RAM_WRITE_LATENCY : integer := 0;
      UPCONFIG_CAPABLE : boolean := TRUE;
      UPSTREAM_FACING : boolean := TRUE;
      UR_INV_REQ : boolean := TRUE;
      USER_CLK_FREQ : integer := 3;
      VC0_CPL_INFINITE : boolean := TRUE;
      VC0_RX_RAM_LIMIT : bit_vector := X"03FF";
      VC0_TOTAL_CREDITS_CD : integer := 127;
      VC0_TOTAL_CREDITS_CH : integer := 31;
      VC0_TOTAL_CREDITS_NPH : integer := 12;
      VC0_TOTAL_CREDITS_PD : integer := 288;
      VC0_TOTAL_CREDITS_PH : integer := 32;
      VC0_TX_LASTPACKET : integer := 31;
      VC_BASE_PTR : bit_vector := X"10C";
      VC_CAP_ID : bit_vector := X"0002";
      VC_CAP_NEXTPTR : bit_vector := X"000";
      VC_CAP_ON : boolean := FALSE;
      VC_CAP_REJECT_SNOOP_TRANSACTIONS : boolean := FALSE;
      VC_CAP_VERSION : bit_vector := X"1";
      VENDOR_ID : bit_vector := X"10EE";
      VSEC_BASE_PTR : bit_vector := X"160";
      VSEC_CAP_HDR_ID : bit_vector := X"1234";
      VSEC_CAP_HDR_LENGTH : bit_vector := X"018";
      VSEC_CAP_HDR_REVISION : bit_vector := X"1";
      VSEC_CAP_ID : bit_vector := X"000B";
      VSEC_CAP_IS_LINK_VISIBLE : boolean := TRUE;
      VSEC_CAP_NEXTPTR : bit_vector := X"000";
      VSEC_CAP_ON : boolean := FALSE;
      VSEC_CAP_VERSION : bit_vector := X"1"
    );

    port (
      CFGAERECRCCHECKEN    : out std_ulogic;
      CFGAERECRCGENEN      : out std_ulogic;
      CFGCOMMANDBUSMASTERENABLE : out std_ulogic;
      CFGCOMMANDINTERRUPTDISABLE : out std_ulogic;
      CFGCOMMANDIOENABLE   : out std_ulogic;
      CFGCOMMANDMEMENABLE  : out std_ulogic;
      CFGCOMMANDSERREN     : out std_ulogic;
      CFGDEVCONTROL2CPLTIMEOUTDIS : out std_ulogic;
      CFGDEVCONTROL2CPLTIMEOUTVAL : out std_logic_vector(3 downto 0);
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
      CFGDO                : out std_logic_vector(31 downto 0);
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
      CFGLINKCONTROLRCB     : out std_ulogic;
      CFGLINKCONTROLRETRAINLINK : out std_ulogic;
      CFGLINKSTATUSAUTOBANDWIDTHSTATUS : out std_ulogic;
      CFGLINKSTATUSBANDWITHSTATUS : out std_ulogic;
      CFGLINKSTATUSCURRENTSPEED : out std_logic_vector(1 downto 0);
      CFGLINKSTATUSDLLACTIVE : out std_ulogic;
      CFGLINKSTATUSLINKTRAINING : out std_ulogic;
      CFGLINKSTATUSNEGOTIATEDWIDTH : out std_logic_vector(3 downto 0);
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
      CFGRDWRDONEN         : out std_ulogic;
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
      DRPDRDY              : out std_ulogic;
      LL2BADDLLPERRN       : out std_ulogic;
      LL2BADTLPERRN        : out std_ulogic;
      LL2PROTOCOLERRN      : out std_ulogic;
      LL2REPLAYROERRN      : out std_ulogic;
      LL2REPLAYTOERRN      : out std_ulogic;
      LL2SUSPENDOKN        : out std_ulogic;
      LL2TFCINIT1SEQN      : out std_ulogic;
      LL2TFCINIT2SEQN      : out std_ulogic;
      LNKCLKEN             : out std_ulogic;
      MIMRXRADDR           : out std_logic_vector(12 downto 0);
      MIMRXRCE             : out std_ulogic;
      MIMRXREN             : out std_ulogic;
      MIMRXWADDR           : out std_logic_vector(12 downto 0);
      MIMRXWDATA           : out std_logic_vector(67 downto 0);
      MIMRXWEN             : out std_ulogic;
      MIMTXRADDR           : out std_logic_vector(12 downto 0);
      MIMTXRCE             : out std_ulogic;
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
      PL2LINKUPN           : out std_ulogic;
      PL2RECEIVERERRN      : out std_ulogic;
      PL2RECOVERYN         : out std_ulogic;
      PL2RXELECIDLE        : out std_ulogic;
      PL2SUSPENDOK         : out std_ulogic;
      PLDBGVEC             : out std_logic_vector(11 downto 0);
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
      TL2ASPMSUSPENDCREDITCHECKOKN : out std_ulogic;
      TL2ASPMSUSPENDREQN   : out std_ulogic;
      TL2PPMSUSPENDOKN     : out std_ulogic;
      TRNFCCPLD            : out std_logic_vector(11 downto 0);
      TRNFCCPLH            : out std_logic_vector(7 downto 0);
      TRNFCNPD             : out std_logic_vector(11 downto 0);
      TRNFCNPH             : out std_logic_vector(7 downto 0);
      TRNFCPD              : out std_logic_vector(11 downto 0);
      TRNFCPH              : out std_logic_vector(7 downto 0);
      TRNLNKUPN            : out std_ulogic;
      TRNRBARHITN          : out std_logic_vector(6 downto 0);
      TRNRD                : out std_logic_vector(63 downto 0);
      TRNRDLLPDATA         : out std_logic_vector(31 downto 0);
      TRNRDLLPSRCRDYN      : out std_ulogic;
      TRNRECRCERRN         : out std_ulogic;
      TRNREOFN             : out std_ulogic;
      TRNRERRFWDN          : out std_ulogic;
      TRNRREMN             : out std_ulogic;
      TRNRSOFN             : out std_ulogic;
      TRNRSRCDSCN          : out std_ulogic;
      TRNRSRCRDYN          : out std_ulogic;
      TRNTBUFAV            : out std_logic_vector(5 downto 0);
      TRNTCFGREQN          : out std_ulogic;
      TRNTDLLPDSTRDYN      : out std_ulogic;
      TRNTDSTRDYN          : out std_ulogic;
      TRNTERRDROPN         : out std_ulogic;
      USERRSTN             : out std_ulogic;
      CFGBYTEENN           : in std_logic_vector(3 downto 0);
      CFGDI                : in std_logic_vector(31 downto 0);
      CFGDSBUSNUMBER       : in std_logic_vector(7 downto 0);
      CFGDSDEVICENUMBER    : in std_logic_vector(4 downto 0);
      CFGDSFUNCTIONNUMBER  : in std_logic_vector(2 downto 0);
      CFGDSN               : in std_logic_vector(63 downto 0);
      CFGDWADDR            : in std_logic_vector(9 downto 0);
      CFGERRACSN           : in std_ulogic;
      CFGERRAERHEADERLOG   : in std_logic_vector(127 downto 0);
      CFGERRCORN           : in std_ulogic;
      CFGERRCPLABORTN      : in std_ulogic;
      CFGERRCPLTIMEOUTN    : in std_ulogic;
      CFGERRCPLUNEXPECTN   : in std_ulogic;
      CFGERRECRCN          : in std_ulogic;
      CFGERRLOCKEDN        : in std_ulogic;
      CFGERRPOSTEDN        : in std_ulogic;
      CFGERRTLPCPLHEADER   : in std_logic_vector(47 downto 0);
      CFGERRURN            : in std_ulogic;
      CFGINTERRUPTASSERTN  : in std_ulogic;
      CFGINTERRUPTDI       : in std_logic_vector(7 downto 0);
      CFGINTERRUPTN        : in std_ulogic;
      CFGPMDIRECTASPML1N   : in std_ulogic;
      CFGPMSENDPMACKN      : in std_ulogic;
      CFGPMSENDPMETON      : in std_ulogic;
      CFGPMSENDPMNAKN      : in std_ulogic;
      CFGPMTURNOFFOKN      : in std_ulogic;
      CFGPMWAKEN           : in std_ulogic;
      CFGPORTNUMBER        : in std_logic_vector(7 downto 0);
      CFGRDENN             : in std_ulogic;
      CFGTRNPENDINGN       : in std_ulogic;
      CFGWRENN             : in std_ulogic;
      CFGWRREADONLYN       : in std_ulogic;
      CFGWRRW1CASRWN       : in std_ulogic;
      CMRSTN               : in std_ulogic;
      CMSTICKYRSTN         : in std_ulogic;
      DBGMODE              : in std_logic_vector(1 downto 0);
      DBGSUBMODE           : in std_ulogic;
      DLRSTN               : in std_ulogic;
      DRPCLK               : in std_ulogic;
      DRPDADDR             : in std_logic_vector(8 downto 0);
      DRPDEN               : in std_ulogic;
      DRPDI                : in std_logic_vector(15 downto 0);
      DRPDWE               : in std_ulogic;
      FUNCLVLRSTN          : in std_ulogic;
      LL2SENDASREQL1N      : in std_ulogic;
      LL2SENDENTERL1N      : in std_ulogic;
      LL2SENDENTERL23N     : in std_ulogic;
      LL2SUSPENDNOWN       : in std_ulogic;
      LL2TLPRCVN           : in std_ulogic;
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
      PLDOWNSTREAMDEEMPHSOURCE : in std_ulogic;
      PLRSTN               : in std_ulogic;
      PLTRANSMITHOTRST     : in std_ulogic;
      PLUPSTREAMPREFERDEEMPH : in std_ulogic;
      SYSRSTN              : in std_ulogic;
      TL2ASPMSUSPENDCREDITCHECKN : in std_ulogic;
      TL2PPMSUSPENDREQN    : in std_ulogic;
      TLRSTN               : in std_ulogic;
      TRNFCSEL             : in std_logic_vector(2 downto 0);
      TRNRDSTRDYN          : in std_ulogic;
      TRNRNPOKN            : in std_ulogic;
      TRNTCFGGNTN          : in std_ulogic;
      TRNTD                : in std_logic_vector(63 downto 0);
      TRNTDLLPDATA         : in std_logic_vector(31 downto 0);
      TRNTDLLPSRCRDYN      : in std_ulogic;
      TRNTECRCGENN         : in std_ulogic;
      TRNTEOFN             : in std_ulogic;
      TRNTERRFWDN          : in std_ulogic;
      TRNTREMN             : in std_ulogic;
      TRNTSOFN             : in std_ulogic;
      TRNTSRCDSCN          : in std_ulogic;
      TRNTSRCRDYN          : in std_ulogic;
      TRNTSTRN             : in std_ulogic;
      USERCLK              : in std_ulogic      
    );
  end PCIE_2_0;

  architecture PCIE_2_0_V of PCIE_2_0 is
   component PCIE_2_0_WRAP
    generic (
      AER_BASE_PTR : string;
      AER_CAP_ECRC_CHECK_CAPABLE : string;
      AER_CAP_ECRC_GEN_CAPABLE : string;
      AER_CAP_ID : string;
      AER_CAP_INT_MSG_NUM_MSI : string;
      AER_CAP_INT_MSG_NUM_MSIX : string;
      AER_CAP_NEXTPTR : string;
      AER_CAP_ON : string;
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
      CLASS_CODE : string;
      CMD_INTX_IMPLEMENTED : string;
      CPL_TIMEOUT_DISABLE_SUPPORTED : string;
      CPL_TIMEOUT_RANGES_SUPPORTED : string;
      CRM_MODULE_RSTS : string;
      DEVICE_ID : string;
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
      DISABLE_ASPM_L1_TIMER : string;
      DISABLE_BAR_FILTERING : string;
      DISABLE_ID_CHECK : string;
      DISABLE_LANE_REVERSAL : string;
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
      ENTER_RVRY_EI_L0 : string;
      EXIT_LOOPBACK_ON_EI : string;
      EXPANSION_ROM : string;
      EXT_CFG_CAP_PTR : string;
      EXT_CFG_XP_CAP_PTR : string;
      HEADER_TYPE : string;
      INFER_EI : string;
      INTERRUPT_PIN : string;
      IS_SWITCH : string;
      LAST_CONFIG_DWORD : string;
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
      LINK_CAP_RSVD_23_22 : integer;
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
      PCIE_CAP_INT_MSG_NUM : string;
      PCIE_CAP_NEXTPTR : string;
      PCIE_CAP_ON : string;
      PCIE_CAP_RSVD_15_14 : integer;
      PCIE_CAP_SLOT_IMPLEMENTED : string;
      PCIE_REVISION : integer;
      PGL0_LANE : integer;
      PGL1_LANE : integer;
      PGL2_LANE : integer;
      PGL3_LANE : integer;
      PGL4_LANE : integer;
      PGL5_LANE : integer;
      PGL6_LANE : integer;
      PGL7_LANE : integer;
      PL_AUTO_CONFIG : integer;
      PL_FAST_TRAIN : string;
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
      RECRC_CHK : integer;
      RECRC_CHK_TRIM : string;
      REVISION_ID : string;
      ROOT_CAP_CRS_SW_VISIBILITY : string;
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
      SUBSYSTEM_ID : string;
      SUBSYSTEM_VENDOR_ID : string;
      TL_RBYPASS : string;
      TL_RX_RAM_RADDR_LATENCY : integer;
      TL_RX_RAM_RDATA_LATENCY : integer;
      TL_RX_RAM_WRITE_LATENCY : integer;
      TL_TFC_DISABLE : string;
      TL_TX_CHECKS_DISABLE : string;
      TL_TX_RAM_RADDR_LATENCY : integer;
      TL_TX_RAM_RDATA_LATENCY : integer;
      TL_TX_RAM_WRITE_LATENCY : integer;
      UPCONFIG_CAPABLE : string;
      UPSTREAM_FACING : string;
      UR_INV_REQ : string;
      USER_CLK_FREQ : integer;
      VC0_CPL_INFINITE : string;
      VC0_RX_RAM_LIMIT : string;
      VC0_TOTAL_CREDITS_CD : integer;
      VC0_TOTAL_CREDITS_CH : integer;
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
      VENDOR_ID : string;
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
        CFGCOMMANDBUSMASTERENABLE : out std_ulogic;
        CFGCOMMANDINTERRUPTDISABLE : out std_ulogic;
        CFGCOMMANDIOENABLE   : out std_ulogic;
        CFGCOMMANDMEMENABLE  : out std_ulogic;
        CFGCOMMANDSERREN     : out std_ulogic;
        CFGDEVCONTROL2CPLTIMEOUTDIS : out std_ulogic;
        CFGDEVCONTROL2CPLTIMEOUTVAL : out std_logic_vector(3 downto 0);
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
        CFGDO                : out std_logic_vector(31 downto 0);
        CFGERRAERHEADERLOGSETN : out std_ulogic;
        CFGERRCPLRDYN        : out std_ulogic;
        CFGINTERRUPTDO       : out std_logic_vector(7 downto 0);
        CFGINTERRUPTMMENABLE : out std_logic_vector(2 downto 0);
        CFGINTERRUPTMSIENABLE : out std_ulogic;
        CFGINTERRUPTMSIXENABLE : out std_ulogic;
        CFGINTERRUPTMSIXFM   : out std_ulogic;
        CFGINTERRUPTRDYN     : out std_ulogic;
        CFGLINKCONTROLRCB     : out std_ulogic;
        CFGLINKCONTROLASPMCONTROL : out std_logic_vector(1 downto 0);
        CFGLINKCONTROLAUTOBANDWIDTHINTEN : out std_ulogic;
        CFGLINKCONTROLBANDWIDTHINTEN : out std_ulogic;
        CFGLINKCONTROLCLOCKPMEN : out std_ulogic;
        CFGLINKCONTROLCOMMONCLOCK : out std_ulogic;
        CFGLINKCONTROLEXTENDEDSYNC : out std_ulogic;
        CFGLINKCONTROLHWAUTOWIDTHDIS : out std_ulogic;
        CFGLINKCONTROLLINKDISABLE : out std_ulogic;
        CFGLINKCONTROLRETRAINLINK : out std_ulogic;
        CFGLINKSTATUSAUTOBANDWIDTHSTATUS : out std_ulogic;
        CFGLINKSTATUSBANDWITHSTATUS : out std_ulogic;
        CFGLINKSTATUSCURRENTSPEED : out std_logic_vector(1 downto 0);
        CFGLINKSTATUSDLLACTIVE : out std_ulogic;
        CFGLINKSTATUSLINKTRAINING : out std_ulogic;
        CFGLINKSTATUSNEGOTIATEDWIDTH : out std_logic_vector(3 downto 0);
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
        CFGRDWRDONEN         : out std_ulogic;
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
        DRPDRDY              : out std_ulogic;
        LL2BADDLLPERRN       : out std_ulogic;
        LL2BADTLPERRN        : out std_ulogic;
        LL2PROTOCOLERRN      : out std_ulogic;
        LL2REPLAYROERRN      : out std_ulogic;
        LL2REPLAYTOERRN      : out std_ulogic;
        LL2SUSPENDOKN        : out std_ulogic;
        LL2TFCINIT1SEQN      : out std_ulogic;
        LL2TFCINIT2SEQN      : out std_ulogic;
        LNKCLKEN             : out std_ulogic;
        MIMRXRADDR           : out std_logic_vector(12 downto 0);
        MIMRXRCE             : out std_ulogic;
        MIMRXREN             : out std_ulogic;
        MIMRXWADDR           : out std_logic_vector(12 downto 0);
        MIMRXWDATA           : out std_logic_vector(67 downto 0);
        MIMRXWEN             : out std_ulogic;
        MIMTXRADDR           : out std_logic_vector(12 downto 0);
        MIMTXRCE             : out std_ulogic;
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
        PL2LINKUPN           : out std_ulogic;
        PL2RECEIVERERRN      : out std_ulogic;
        PL2RECOVERYN         : out std_ulogic;
        PL2RXELECIDLE        : out std_ulogic;
        PL2SUSPENDOK         : out std_ulogic;
        PLDBGVEC             : out std_logic_vector(11 downto 0);
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
        TL2ASPMSUSPENDCREDITCHECKOKN : out std_ulogic;
        TL2ASPMSUSPENDREQN   : out std_ulogic;
        TL2PPMSUSPENDOKN     : out std_ulogic;
        TRNFCCPLD            : out std_logic_vector(11 downto 0);
        TRNFCCPLH            : out std_logic_vector(7 downto 0);
        TRNFCNPD             : out std_logic_vector(11 downto 0);
        TRNFCNPH             : out std_logic_vector(7 downto 0);
        TRNFCPD              : out std_logic_vector(11 downto 0);
        TRNFCPH              : out std_logic_vector(7 downto 0);
        TRNLNKUPN            : out std_ulogic;
        TRNRBARHITN          : out std_logic_vector(6 downto 0);
        TRNRD                : out std_logic_vector(63 downto 0);
        TRNRDLLPDATA         : out std_logic_vector(31 downto 0);
        TRNRDLLPSRCRDYN      : out std_ulogic;
        TRNRECRCERRN         : out std_ulogic;
        TRNREOFN             : out std_ulogic;
        TRNRERRFWDN          : out std_ulogic;
        TRNRREMN             : out std_ulogic;
        TRNRSOFN             : out std_ulogic;
        TRNRSRCDSCN          : out std_ulogic;
        TRNRSRCRDYN          : out std_ulogic;
        TRNTBUFAV            : out std_logic_vector(5 downto 0);
        TRNTCFGREQN          : out std_ulogic;
        TRNTDLLPDSTRDYN      : out std_ulogic;
        TRNTDSTRDYN          : out std_ulogic;
        TRNTERRDROPN         : out std_ulogic;
        USERRSTN             : out std_ulogic;
        CFGBYTEENN           : in std_logic_vector(3 downto 0);
        CFGDI                : in std_logic_vector(31 downto 0);
        CFGDSBUSNUMBER       : in std_logic_vector(7 downto 0);
        CFGDSDEVICENUMBER    : in std_logic_vector(4 downto 0);
        CFGDSFUNCTIONNUMBER  : in std_logic_vector(2 downto 0);
        CFGDSN               : in std_logic_vector(63 downto 0);
        CFGDWADDR            : in std_logic_vector(9 downto 0);
        CFGERRACSN           : in std_ulogic;
        CFGERRAERHEADERLOG   : in std_logic_vector(127 downto 0);
        CFGERRCORN           : in std_ulogic;
        CFGERRCPLABORTN      : in std_ulogic;
        CFGERRCPLTIMEOUTN    : in std_ulogic;
        CFGERRCPLUNEXPECTN   : in std_ulogic;
        CFGERRECRCN          : in std_ulogic;
        CFGERRLOCKEDN        : in std_ulogic;
        CFGERRPOSTEDN        : in std_ulogic;
        CFGERRTLPCPLHEADER   : in std_logic_vector(47 downto 0);
        CFGERRURN            : in std_ulogic;
        CFGINTERRUPTASSERTN  : in std_ulogic;
        CFGINTERRUPTDI       : in std_logic_vector(7 downto 0);
        CFGINTERRUPTN        : in std_ulogic;
        CFGPMDIRECTASPML1N   : in std_ulogic;
        CFGPMSENDPMACKN      : in std_ulogic;
        CFGPMSENDPMETON      : in std_ulogic;
        CFGPMSENDPMNAKN      : in std_ulogic;
        CFGPMTURNOFFOKN      : in std_ulogic;
        CFGPMWAKEN           : in std_ulogic;
        CFGPORTNUMBER        : in std_logic_vector(7 downto 0);
        CFGRDENN             : in std_ulogic;
        CFGTRNPENDINGN       : in std_ulogic;
        CFGWRENN             : in std_ulogic;
        CFGWRREADONLYN       : in std_ulogic;
        CFGWRRW1CASRWN       : in std_ulogic;
        CMRSTN               : in std_ulogic;
        CMSTICKYRSTN         : in std_ulogic;
        DBGMODE              : in std_logic_vector(1 downto 0);
        DBGSUBMODE           : in std_ulogic;
        DLRSTN               : in std_ulogic;
        DRPCLK               : in std_ulogic;
        DRPDADDR             : in std_logic_vector(8 downto 0);
        DRPDEN               : in std_ulogic;
        DRPDI                : in std_logic_vector(15 downto 0);
        DRPDWE               : in std_ulogic;
        FUNCLVLRSTN          : in std_ulogic;
        GSR                  : in std_ulogic;   
        LL2SENDASREQL1N      : in std_ulogic;
        LL2SENDENTERL1N      : in std_ulogic;
        LL2SENDENTERL23N     : in std_ulogic;
        LL2SUSPENDNOWN       : in std_ulogic;
        LL2TLPRCVN           : in std_ulogic;
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
        PLDOWNSTREAMDEEMPHSOURCE : in std_ulogic;
        PLRSTN               : in std_ulogic;
        PLTRANSMITHOTRST     : in std_ulogic;
        PLUPSTREAMPREFERDEEMPH : in std_ulogic;
        SYSRSTN              : in std_ulogic;
        TL2ASPMSUSPENDCREDITCHECKN : in std_ulogic;
        TL2PPMSUSPENDREQN    : in std_ulogic;
        TLRSTN               : in std_ulogic;
        TRNFCSEL             : in std_logic_vector(2 downto 0);
        TRNRDSTRDYN          : in std_ulogic;
        TRNRNPOKN            : in std_ulogic;
        TRNTCFGGNTN          : in std_ulogic;
        TRNTD                : in std_logic_vector(63 downto 0);
        TRNTDLLPDATA         : in std_logic_vector(31 downto 0);
        TRNTDLLPSRCRDYN      : in std_ulogic;
        TRNTECRCGENN         : in std_ulogic;
        TRNTEOFN             : in std_ulogic;
        TRNTERRFWDN          : in std_ulogic;
        TRNTREMN             : in std_ulogic;
        TRNTSOFN             : in std_ulogic;
        TRNTSRCDSCN          : in std_ulogic;
        TRNTSRCRDYN          : in std_ulogic;
        TRNTSTRN             : in std_ulogic;
        USERCLK              : in std_ulogic
        );
    end component;
    
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    function boolean_to_string(
        bool: boolean)
    return string is
    begin
     if bool then
       return "TRUE";
     else
       return "FALSE";
     end if;
    end boolean_to_string;
    function getstrlength (
           in_vec : std_logic_vector)
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
       
     -- Converts bit_vector to std_logic_vector
       constant AER_BASE_PTR_BINARY : std_logic_vector(11 downto 0):= To_StdLogicVector(AER_BASE_PTR)(11 downto 0);
       constant AER_BASE_PTR_STRLEN : integer:= getstrlength(AER_BASE_PTR_BINARY);
       constant AER_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(AER_CAP_ID)(15 downto 0);
       constant AER_CAP_ID_STRLEN : integer:= getstrlength(AER_CAP_ID_BINARY);
       constant AER_CAP_INT_MSG_NUM_MSIX_BINARY : std_logic_vector(4 downto 0):= To_StdLogicVector(AER_CAP_INT_MSG_NUM_MSIX)(4 downto 0);
       constant AER_CAP_INT_MSG_NUM_MSIX_STRLEN : integer:= getstrlength(AER_CAP_INT_MSG_NUM_MSIX_BINARY);
       constant AER_CAP_INT_MSG_NUM_MSI_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(AER_CAP_INT_MSG_NUM_MSI)(4 downto 0) ;
       constant AER_CAP_INT_MSG_NUM_MSI_STRLEN : integer:= getstrlength(AER_CAP_INT_MSG_NUM_MSI_BINARY);
       constant AER_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(AER_CAP_NEXTPTR)(11 downto 0);
       constant AER_CAP_NEXTPTR_STRLEN : integer:= getstrlength(AER_CAP_NEXTPTR_BINARY);
        constant AER_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(AER_CAP_VERSION)(3 downto 0);
       constant AER_CAP_VERSION_STRLEN : integer:= getstrlength(AER_CAP_VERSION_BINARY);
       constant BAR0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR0)(31 downto 0);
       constant BAR0_STRLEN : integer:= getstrlength(BAR0_BINARY);
    constant BAR1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR1)(31 downto 0);
       constant BAR1_STRLEN : integer:= getstrlength(BAR1_BINARY);
    constant BAR2_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR2)(31 downto 0);
       constant BAR2_STRLEN : integer:= getstrlength(BAR2_BINARY);
    constant BAR3_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR3)(31 downto 0);
       constant BAR3_STRLEN : integer:= getstrlength(BAR3_BINARY);
    constant BAR4_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR4)(31 downto 0);
       constant BAR4_STRLEN : integer:= getstrlength(BAR4_BINARY);
    constant BAR5_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR5)(31 downto 0);
       constant BAR5_STRLEN : integer:= getstrlength(BAR5_BINARY);
    constant CAPABILITIES_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(CAPABILITIES_PTR)(7 downto 0);
       constant CAPABILITIES_PTR_STRLEN : integer:= getstrlength(CAPABILITIES_PTR_BINARY);
    constant CARDBUS_CIS_POINTER_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(CARDBUS_CIS_POINTER)(31 downto 0);
       constant CARDBUS_CIS_POINTER_STRLEN : integer:= getstrlength(CARDBUS_CIS_POINTER_BINARY);
        constant CLASS_CODE_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(CLASS_CODE)(23 downto 0) ;
       constant  CLASS_CODE_STRLEN : integer:= getstrlength( CLASS_CODE_BINARY);
       constant CPL_TIMEOUT_RANGES_SUPPORTED_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CPL_TIMEOUT_RANGES_SUPPORTED)(3 downto 0);
       constant  CPL_TIMEOUT_RANGES_SUPPORTED_STRLEN : integer:= getstrlength( CPL_TIMEOUT_RANGES_SUPPORTED_BINARY);
    constant CRM_MODULE_RSTS_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(CRM_MODULE_RSTS)(6 downto 0);
       constant  CRM_MODULE_RSTS_STRLEN : integer:= getstrlength( CRM_MODULE_RSTS_BINARY);
    constant DEVICE_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DEVICE_ID)(15 downto 0);
       constant  DEVICE_ID_STRLEN : integer:= getstrlength( DEVICE_ID_BINARY);
       constant DNSTREAM_LINK_NUM_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(DNSTREAM_LINK_NUM)(7 downto 0);
       constant  DNSTREAM_LINK_NUM_STRLEN : integer:= getstrlength( DNSTREAM_LINK_NUM_BINARY);
    constant DSN_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(DSN_BASE_PTR)(11 downto 0) ;
       constant  DSN_BASE_PTR_STRLEN : integer:= getstrlength( DSN_BASE_PTR_BINARY);
    constant DSN_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DSN_CAP_ID)(15 downto 0);
       constant  DSN_CAP_ID_STRLEN : integer:= getstrlength( DSN_CAP_ID_BINARY);
    constant DSN_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(DSN_CAP_NEXTPTR)(11 downto 0);
       constant  DSN_CAP_NEXTPTR_STRLEN : integer:= getstrlength( DSN_CAP_NEXTPTR_BINARY);
      constant DSN_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(DSN_CAP_VERSION)(3 downto 0) ;
       constant  DSN_CAP_VERSION_STRLEN : integer:= getstrlength( DSN_CAP_VERSION_BINARY);
    constant ENABLE_MSG_ROUTE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(ENABLE_MSG_ROUTE)(10 downto 0);
       constant  ENABLE_MSG_ROUTE_STRLEN : integer:= getstrlength( ENABLE_MSG_ROUTE_BINARY);
       constant EXPANSION_ROM_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(EXPANSION_ROM)(31 downto 0);
       constant  EXPANSION_ROM_STRLEN : integer:= getstrlength( EXPANSION_ROM_BINARY);
       constant EXT_CFG_CAP_PTR_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(EXT_CFG_CAP_PTR)(5 downto 0);
       constant  EXT_CFG_CAP_PTR_STRLEN : integer:= getstrlength( EXT_CFG_CAP_PTR_BINARY);
       constant EXT_CFG_XP_CAP_PTR_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(EXT_CFG_XP_CAP_PTR)(9 downto 0);
       constant  EXT_CFG_XP_CAP_PTR_STRLEN : integer:= getstrlength( EXT_CFG_XP_CAP_PTR_BINARY);
       constant HEADER_TYPE_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(HEADER_TYPE)(7 downto 0);
       constant  HEADER_TYPE_STRLEN : integer:= getstrlength( HEADER_TYPE_BINARY);
       constant INFER_EI_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(INFER_EI)(4 downto 0);
       constant  INFER_EI_STRLEN : integer:= getstrlength( INFER_EI_BINARY);
       constant INTERRUPT_PIN_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(INTERRUPT_PIN)(7 downto 0);
       constant  INTERRUPT_PIN_STRLEN : integer:= getstrlength( INTERRUPT_PIN_BINARY);
 constant LAST_CONFIG_DWORD_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(LAST_CONFIG_DWORD)(9 downto 0);
       constant  LAST_CONFIG_DWORD_STRLEN : integer:= getstrlength( LAST_CONFIG_DWORD_BINARY);
        constant LINK_CAP_MAX_LINK_SPEED_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(LINK_CAP_MAX_LINK_SPEED)(3 downto 0);
       constant  LINK_CAP_MAX_LINK_SPEED_STRLEN : integer:= getstrlength( LINK_CAP_MAX_LINK_SPEED_BINARY);
    constant LINK_CAP_MAX_LINK_WIDTH_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(LINK_CAP_MAX_LINK_WIDTH)(5 downto 0);
       constant  LINK_CAP_MAX_LINK_WIDTH_STRLEN : integer:= getstrlength( LINK_CAP_MAX_LINK_WIDTH_BINARY);
       constant LINK_CTRL2_TARGET_LINK_SPEED_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(LINK_CTRL2_TARGET_LINK_SPEED)(3 downto 0);
       constant  LINK_CTRL2_TARGET_LINK_SPEED_STRLEN : integer:= getstrlength( LINK_CTRL2_TARGET_LINK_SPEED_BINARY);
       constant LL_ACK_TIMEOUT_BINARY : std_logic_vector(14 downto 0) := To_StdLogicVector(LL_ACK_TIMEOUT)(14 downto 0);
       constant  LL_ACK_TIMEOUT_STRLEN : integer:= getstrlength( LL_ACK_TIMEOUT_BINARY);
       constant LL_REPLAY_TIMEOUT_BINARY : std_logic_vector(14 downto 0) := To_StdLogicVector(LL_REPLAY_TIMEOUT)(14 downto 0);
       constant  LL_REPLAY_TIMEOUT_STRLEN : integer:= getstrlength( LL_REPLAY_TIMEOUT_BINARY);
   constant LTSSM_MAX_LINK_WIDTH_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(LTSSM_MAX_LINK_WIDTH)(5 downto 0);
       constant  LTSSM_MAX_LINK_WIDTH_STRLEN : integer:= getstrlength( LTSSM_MAX_LINK_WIDTH_BINARY);
    constant MSIX_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSIX_BASE_PTR)(7 downto 0);
       constant  MSIX_BASE_PTR_STRLEN : integer:= getstrlength( MSIX_BASE_PTR_BINARY);
    constant MSIX_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSIX_CAP_ID)(7 downto 0);
       constant  MSIX_CAP_ID_STRLEN : integer:= getstrlength( MSIX_CAP_ID_BINARY);
    constant MSIX_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSIX_CAP_NEXTPTR)(7 downto 0);
       constant  MSIX_CAP_NEXTPTR_STRLEN : integer:= getstrlength( MSIX_CAP_NEXTPTR_BINARY);
 constant MSIX_CAP_PBA_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(MSIX_CAP_PBA_OFFSET)(28 downto 0);
       constant  MSIX_CAP_PBA_OFFSET_STRLEN : integer:= getstrlength( MSIX_CAP_PBA_OFFSET_BINARY);
        constant MSIX_CAP_TABLE_OFFSET_BINARY : std_logic_vector(28 downto 0) := To_StdLogicVector(MSIX_CAP_TABLE_OFFSET)(28 downto 0);
       constant  MSIX_CAP_TABLE_OFFSET_STRLEN : integer:= getstrlength( MSIX_CAP_TABLE_OFFSET_BINARY);
constant MSIX_CAP_TABLE_SIZE_BINARY : std_logic_vector(10 downto 0) := To_StdLogicVector(MSIX_CAP_TABLE_SIZE)(10 downto 0);
       constant  MSIX_CAP_TABLE_SIZE_STRLEN : integer:= getstrlength( MSIX_CAP_TABLE_SIZE_BINARY);
    constant MSI_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSI_BASE_PTR)(7 downto 0);
       constant  MSI_BASE_PTR_STRLEN : integer:= getstrlength( MSI_BASE_PTR_BINARY);
       constant MSI_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSI_CAP_ID)(7 downto 0);
       constant  MSI_CAP_ID_STRLEN : integer:= getstrlength( MSI_CAP_ID_BINARY);
constant MSI_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(MSI_CAP_NEXTPTR)(7 downto 0);
       constant  MSI_CAP_NEXTPTR_STRLEN : integer:= getstrlength( MSI_CAP_NEXTPTR_BINARY);
       constant PCIE_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PCIE_BASE_PTR)(7 downto 0);
       constant  PCIE_BASE_PTR_STRLEN : integer:= getstrlength( PCIE_BASE_PTR_BINARY);
    constant PCIE_CAP_CAPABILITY_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PCIE_CAP_CAPABILITY_ID)(7 downto 0);
       constant PCIE_CAP_CAPABILITY_ID_STRLEN : integer:= getstrlength( PCIE_CAP_CAPABILITY_ID_BINARY);
    constant PCIE_CAP_CAPABILITY_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PCIE_CAP_CAPABILITY_VERSION)(3 downto 0);
       constant PCIE_CAP_CAPABILITY_VERSION_STRLEN : integer:= getstrlength( PCIE_CAP_CAPABILITY_VERSION_BINARY);
    constant PCIE_CAP_DEVICE_PORT_TYPE_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PCIE_CAP_DEVICE_PORT_TYPE)(3 downto 0);
       constant PCIE_CAP_DEVICE_PORT_TYPE_STRLEN : integer:= getstrlength( PCIE_CAP_DEVICE_PORT_TYPE_BINARY);
    constant PCIE_CAP_INT_MSG_NUM_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PCIE_CAP_INT_MSG_NUM)(4 downto 0);
       constant PCIE_CAP_INT_MSG_NUM_STRLEN : integer:= getstrlength( PCIE_CAP_INT_MSG_NUM_BINARY);
    constant PCIE_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PCIE_CAP_NEXTPTR)(7 downto 0);
       constant PCIE_CAP_NEXTPTR_STRLEN : integer:= getstrlength( PCIE_CAP_NEXTPTR_BINARY);
 constant PM_BASE_PTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_BASE_PTR)(7 downto 0);
       constant PM_BASE_PTR_STRLEN : integer:= getstrlength( PM_BASE_PTR_BINARY);
 constant PM_CAP_ID_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_CAP_ID)(7 downto 0);
       constant PM_CAP_ID_STRLEN : integer:= getstrlength( PM_CAP_ID_BINARY);
    constant PM_CAP_NEXTPTR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_CAP_NEXTPTR)(7 downto 0);
       constant PM_CAP_NEXTPTR_STRLEN : integer:= getstrlength( PM_CAP_NEXTPTR_BINARY);
       constant PM_CAP_PMESUPPORT_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PM_CAP_PMESUPPORT)(4 downto 0);
       constant PM_CAP_PMESUPPORT_STRLEN : integer:= getstrlength( PM_CAP_PMESUPPORT_BINARY);
      constant PM_DATA0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA0)(7 downto 0);
       constant PM_DATA0_STRLEN : integer:= getstrlength( PM_DATA0_BINARY);
    constant PM_DATA1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA1)(7 downto 0);
       constant PM_DATA1_STRLEN : integer:= getstrlength( PM_DATA1_BINARY);
    constant PM_DATA2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA2)(7 downto 0);
       constant PM_DATA2_STRLEN : integer:= getstrlength( PM_DATA2_BINARY);
    constant PM_DATA3_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA3)(7 downto 0);
       constant PM_DATA3_STRLEN : integer:= getstrlength( PM_DATA3_BINARY);
    constant PM_DATA4_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA4)(7 downto 0);
       constant PM_DATA4_STRLEN : integer:= getstrlength( PM_DATA4_BINARY);
    constant PM_DATA5_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA5)(7 downto 0);
       constant PM_DATA5_STRLEN : integer:= getstrlength( PM_DATA5_BINARY);
    constant PM_DATA6_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA6)(7 downto 0);
       constant PM_DATA6_STRLEN : integer:= getstrlength( PM_DATA6_BINARY);
    constant PM_DATA7_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PM_DATA7)(7 downto 0);
       constant PM_DATA7_STRLEN : integer:= getstrlength( PM_DATA7_BINARY);
    constant PM_DATA_SCALE0_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE0)(1 downto 0);
       constant PM_DATA_SCALE0_STRLEN : integer:= getstrlength( PM_DATA_SCALE0_BINARY);
    constant PM_DATA_SCALE1_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE1)(1 downto 0);
       constant PM_DATA_SCALE1_STRLEN : integer:= getstrlength( PM_DATA_SCALE1_BINARY);
    constant PM_DATA_SCALE2_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE2)(1 downto 0);
       constant PM_DATA_SCALE2_STRLEN : integer:= getstrlength( PM_DATA_SCALE2_BINARY);
    constant PM_DATA_SCALE3_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE3)(1 downto 0);
       constant PM_DATA_SCALE3_STRLEN : integer:= getstrlength( PM_DATA_SCALE3_BINARY);
    constant PM_DATA_SCALE4_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE4)(1 downto 0);
       constant PM_DATA_SCALE4_STRLEN : integer:= getstrlength( PM_DATA_SCALE4_BINARY);
    constant PM_DATA_SCALE5_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE5)(1 downto 0);
       constant PM_DATA_SCALE5_STRLEN : integer:= getstrlength( PM_DATA_SCALE5_BINARY);
    constant PM_DATA_SCALE6_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE6)(1 downto 0);
       constant PM_DATA_SCALE6_STRLEN : integer:= getstrlength( PM_DATA_SCALE6_BINARY);
    constant PM_DATA_SCALE7_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(PM_DATA_SCALE7)(1 downto 0);
       constant PM_DATA_SCALE7_STRLEN : integer:= getstrlength( PM_DATA_SCALE7_BINARY);
     constant REVISION_ID_BINARY : std_logic_vector(7 downto 0):= To_StdLogicVector(REVISION_ID)(7 downto 0);
       constant REVISION_ID_STRLEN : integer:= getstrlength( REVISION_ID_BINARY);
     constant SLOT_CAP_PHYSICAL_SLOT_NUM_BINARY : std_logic_vector(12 downto 0) := To_StdLogicVector(SLOT_CAP_PHYSICAL_SLOT_NUM)(12 downto 0); 
       constant SLOT_CAP_PHYSICAL_SLOT_NUM_STRLEN : integer:= getstrlength( SLOT_CAP_PHYSICAL_SLOT_NUM_BINARY);
     constant SLOT_CAP_SLOT_POWER_LIMIT_VALUE_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SLOT_CAP_SLOT_POWER_LIMIT_VALUE)(7 downto 0);
       constant SLOT_CAP_SLOT_POWER_LIMIT_VALUE_STRLEN : integer:= getstrlength( SLOT_CAP_SLOT_POWER_LIMIT_VALUE_BINARY);
    constant SPARE_BYTE0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE0)(7 downto 0);
       constant SPARE_BYTE0_STRLEN : integer:= getstrlength( SPARE_BYTE0_BINARY);
    constant SPARE_BYTE1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE1)(7 downto 0);
       constant SPARE_BYTE1_STRLEN : integer:= getstrlength( SPARE_BYTE1_BINARY);
    constant SPARE_BYTE2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE2)(7 downto 0);
       constant SPARE_BYTE2_STRLEN : integer:= getstrlength( SPARE_BYTE2_BINARY);
    constant SPARE_BYTE3_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(SPARE_BYTE3)(7 downto 0);
       constant SPARE_BYTE3_STRLEN : integer:= getstrlength( SPARE_BYTE3_BINARY);
    constant SPARE_WORD0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD0)(31 downto 0);
       constant SPARE_WORD0_STRLEN : integer:= getstrlength( SPARE_WORD0_BINARY);
    constant SPARE_WORD1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD1)(31 downto 0);
       constant SPARE_WORD1_STRLEN : integer:= getstrlength( SPARE_WORD1_BINARY);
    constant SPARE_WORD2_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD2)(31 downto 0);
       constant SPARE_WORD2_STRLEN : integer:= getstrlength( SPARE_WORD2_BINARY);
    constant SPARE_WORD3_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SPARE_WORD3)(31 downto 0);
       constant SPARE_WORD3_STRLEN : integer:= getstrlength( SPARE_WORD3_BINARY);
    constant SUBSYSTEM_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SUBSYSTEM_ID)(15 downto 0);
       constant SUBSYSTEM_ID_STRLEN : integer:= getstrlength( SUBSYSTEM_ID_BINARY);
    constant SUBSYSTEM_VENDOR_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SUBSYSTEM_VENDOR_ID)(15 downto 0);
       constant SUBSYSTEM_VENDOR_ID_STRLEN : integer:= getstrlength( SUBSYSTEM_VENDOR_ID_BINARY);
constant VC0_RX_RAM_LIMIT_BINARY : std_logic_vector(12 downto 0) := To_StdLogicVector(VC0_RX_RAM_LIMIT)(12 downto 0);
       constant VC0_RX_RAM_LIMIT_STRLEN : integer:= getstrlength( VC0_RX_RAM_LIMIT_BINARY);
constant VC_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VC_BASE_PTR)(11 downto 0);
       constant VC_BASE_PTR_STRLEN : integer:= getstrlength( VC_BASE_PTR_BINARY);
    constant VC_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(VC_CAP_ID)(15 downto 0);
       constant VC_CAP_ID_STRLEN : integer:= getstrlength( VC_CAP_ID_BINARY);
       constant VC_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VC_CAP_NEXTPTR)(11 downto 0); 
       constant VC_CAP_NEXTPTR_STRLEN : integer:= getstrlength( VC_CAP_NEXTPTR_BINARY);
      constant VC_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VC_CAP_VERSION)(3 downto 0);
       constant VC_CAP_VERSION_STRLEN : integer:= getstrlength( VC_CAP_VERSION_BINARY);
    constant VENDOR_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(VENDOR_ID)(15 downto 0);
       constant VENDOR_ID_STRLEN : integer:= getstrlength( VENDOR_ID_BINARY);
    constant VSEC_BASE_PTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VSEC_BASE_PTR)(11 downto 0);
       constant VSEC_BASE_PTR_STRLEN : integer:= getstrlength( VSEC_BASE_PTR_BINARY);
    constant VSEC_CAP_HDR_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(VSEC_CAP_HDR_ID)(15 downto 0);
       constant VSEC_CAP_HDR_ID_STRLEN : integer:= getstrlength( VSEC_CAP_HDR_ID_BINARY);
    constant VSEC_CAP_HDR_LENGTH_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VSEC_CAP_HDR_LENGTH)(11 downto 0);
       constant VSEC_CAP_HDR_LENGTH_STRLEN : integer:= getstrlength( VSEC_CAP_HDR_LENGTH_BINARY);
    constant VSEC_CAP_HDR_REVISION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VSEC_CAP_HDR_REVISION)(3 downto 0);
       constant VSEC_CAP_HDR_REVISION_STRLEN : integer:= getstrlength( VSEC_CAP_HDR_REVISION_BINARY);
    constant VSEC_CAP_ID_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(VSEC_CAP_ID)(15 downto 0);
       constant VSEC_CAP_ID_STRLEN : integer:= getstrlength( VSEC_CAP_ID_BINARY);
       constant VSEC_CAP_NEXTPTR_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VSEC_CAP_NEXTPTR)(11 downto 0);
       constant VSEC_CAP_NEXTPTR_STRLEN : integer:= getstrlength( VSEC_CAP_NEXTPTR_BINARY);
       constant VSEC_CAP_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(VSEC_CAP_VERSION)(3 downto 0);
       constant VSEC_CAP_VERSION_STRLEN : integer:= getstrlength( VSEC_CAP_VERSION_BINARY);

       
     -- Convert std_logic_vector to string
     constant AER_BASE_PTR_STRING : string := SLV_TO_HEX(AER_BASE_PTR_BINARY, AER_BASE_PTR_STRLEN);
     constant AER_CAP_ID_STRING : string := SLV_TO_HEX(AER_CAP_ID_BINARY, AER_CAP_ID_STRLEN);
     constant AER_CAP_INT_MSG_NUM_MSIX_STRING : string := SLV_TO_HEX(AER_CAP_INT_MSG_NUM_MSIX_BINARY, AER_CAP_INT_MSG_NUM_MSIX_STRLEN);
     constant AER_CAP_INT_MSG_NUM_MSI_STRING : string := SLV_TO_HEX(AER_CAP_INT_MSG_NUM_MSI_BINARY, AER_CAP_INT_MSG_NUM_MSI_STRLEN);
     constant AER_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(AER_CAP_NEXTPTR_BINARY, AER_CAP_NEXTPTR_STRLEN);
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
     constant DEVICE_ID_STRING : string := SLV_TO_HEX(DEVICE_ID_BINARY, DEVICE_ID_STRLEN);
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
     constant MSIX_BASE_PTR_STRING :string := SLV_TO_HEX(MSIX_BASE_PTR_BINARY,MSIX_BASE_PTR_STRLEN);
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
    constant PCIE_CAP_INT_MSG_NUM_STRING : string := SLV_TO_HEX(PCIE_CAP_INT_MSG_NUM_BINARY, PCIE_CAP_INT_MSG_NUM_STRLEN);
     constant PCIE_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(PCIE_CAP_NEXTPTR_BINARY, PCIE_CAP_NEXTPTR_STRLEN);
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
     constant REVISION_ID_STRING : string := SLV_TO_HEX(REVISION_ID_BINARY, REVISION_ID_STRLEN);
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
    constant SUBSYSTEM_ID_STRING : string := SLV_TO_HEX(SUBSYSTEM_ID_BINARY, SUBSYSTEM_ID_STRLEN);
    constant SUBSYSTEM_VENDOR_ID_STRING : string := SLV_TO_HEX(SUBSYSTEM_VENDOR_ID_BINARY, SUBSYSTEM_VENDOR_ID_STRLEN);
    constant VC0_RX_RAM_LIMIT_STRING : string := SLV_TO_HEX(VC0_RX_RAM_LIMIT_BINARY, VC0_RX_RAM_LIMIT_STRLEN);
    constant VC_BASE_PTR_STRING : string := SLV_TO_HEX(VC_BASE_PTR_BINARY, VC_BASE_PTR_STRLEN);
    constant VC_CAP_ID_STRING : string := SLV_TO_HEX(VC_CAP_ID_BINARY, VC_CAP_ID_STRLEN);
    constant VC_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VC_CAP_NEXTPTR_BINARY, VC_CAP_NEXTPTR_STRLEN); 
    constant VC_CAP_VERSION_STRING : string := SLV_TO_HEX(VC_CAP_VERSION_BINARY, VC_CAP_VERSION_STRLEN);
    constant VENDOR_ID_STRING : string := SLV_TO_HEX(VENDOR_ID_BINARY, VENDOR_ID_STRLEN);
    constant VSEC_BASE_PTR_STRING : string := SLV_TO_HEX(VSEC_BASE_PTR_BINARY, VSEC_BASE_PTR_STRLEN);
    constant VSEC_CAP_HDR_ID_STRING : string := SLV_TO_HEX(VSEC_CAP_HDR_ID_BINARY, VSEC_CAP_HDR_ID_STRLEN);
    constant VSEC_CAP_HDR_LENGTH_STRING : string := SLV_TO_HEX(VSEC_CAP_HDR_LENGTH_BINARY, VSEC_CAP_HDR_LENGTH_STRLEN);
    constant VSEC_CAP_HDR_REVISION_STRING : string := SLV_TO_HEX(VSEC_CAP_HDR_REVISION_BINARY, VSEC_CAP_HDR_REVISION_STRLEN);
    constant VSEC_CAP_ID_STRING : string := SLV_TO_HEX(VSEC_CAP_ID_BINARY, VSEC_CAP_ID_STRLEN);
    constant VSEC_CAP_NEXTPTR_STRING : string := SLV_TO_HEX(VSEC_CAP_NEXTPTR_BINARY, VSEC_CAP_NEXTPTR_STRLEN);
    constant VSEC_CAP_VERSION_STRING : string := SLV_TO_HEX(VSEC_CAP_VERSION_BINARY, VSEC_CAP_VERSION_STRLEN);
         
     -- Convert boolean to string
     constant  AER_CAP_ECRC_CHECK_CAPABLE_STRING : string  := boolean_to_string(AER_CAP_ECRC_CHECK_CAPABLE);
     constant AER_CAP_ECRC_GEN_CAPABLE_STRING : string  := boolean_to_string(AER_CAP_ECRC_GEN_CAPABLE);
     constant AER_CAP_ON_STRING : string := boolean_to_string(AER_CAP_ON);
     constant AER_CAP_PERMIT_ROOTERR_UPDATE_STRING : string := boolean_to_string(AER_CAP_PERMIT_ROOTERR_UPDATE);
     constant ALLOW_X8_GEN2_STRING : string := boolean_to_string(ALLOW_X8_GEN2);
     constant CMD_INTX_IMPLEMENTED_STRING : string := boolean_to_string(CMD_INTX_IMPLEMENTED);
     constant CPL_TIMEOUT_DISABLE_SUPPORTED_STRING : string := boolean_to_string(CPL_TIMEOUT_DISABLE_SUPPORTED);
     constant DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE_STRING : string := boolean_to_string(DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE);
     constant DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE_STRING : string := boolean_to_string(DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE);
     constant DEV_CAP_EXT_TAG_SUPPORTED_STRING : string := boolean_to_string(DEV_CAP_EXT_TAG_SUPPORTED);
     constant DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_STRING : string := boolean_to_string(DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE);
     constant DEV_CAP_ROLE_BASED_ERROR_STRING : string := boolean_to_string(DEV_CAP_ROLE_BASED_ERROR);
     constant DEV_CONTROL_AUX_POWER_SUPPORTED_STRING : string := boolean_to_string(DEV_CONTROL_AUX_POWER_SUPPORTED);
     constant DISABLE_ASPM_L1_TIMER_STRING : string := boolean_to_string(DISABLE_ASPM_L1_TIMER);
     constant DISABLE_BAR_FILTERING_STRING : string := boolean_to_string(DISABLE_BAR_FILTERING);
     constant DISABLE_ID_CHECK_STRING : string := boolean_to_string(DISABLE_ID_CHECK);
     constant DISABLE_LANE_REVERSAL_STRING : string := boolean_to_string(DISABLE_LANE_REVERSAL);
     constant DISABLE_RX_TC_FILTER_STRING : string := boolean_to_string(DISABLE_RX_TC_FILTER);
     constant DISABLE_SCRAMBLING_STRING : string := boolean_to_string(DISABLE_SCRAMBLING);
     constant DSN_CAP_ON_STRING : string := boolean_to_string(DSN_CAP_ON);
     constant ENABLE_RX_TD_ECRC_TRIM_STRING : string := boolean_to_string(ENABLE_RX_TD_ECRC_TRIM);
     constant ENTER_RVRY_EI_L0_STRING : string := boolean_to_string(ENTER_RVRY_EI_L0);
      constant EXIT_LOOPBACK_ON_EI_STRING : string := boolean_to_string(EXIT_LOOPBACK_ON_EI);
     constant IS_SWITCH_STRING : string := boolean_to_string(IS_SWITCH);
     constant LINK_CAP_CLOCK_POWER_MANAGEMENT_STRING : string := boolean_to_string(LINK_CAP_CLOCK_POWER_MANAGEMENT);
     constant LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP_STRING : string := boolean_to_string(LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP);
     constant LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP_STRING : string := boolean_to_string(LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP);
     constant LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_STRING : string := boolean_to_string(LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE);
     constant LINK_CTRL2_DEEMPHASIS_STRING : string := boolean_to_string(LINK_CTRL2_DEEMPHASIS);
     constant LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_STRING : string := boolean_to_string(LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE);
     constant LINK_STATUS_SLOT_CLOCK_CONFIG_STRING : string := boolean_to_string(LINK_STATUS_SLOT_CLOCK_CONFIG);
     constant LL_ACK_TIMEOUT_EN_STRING : string := boolean_to_string(LL_ACK_TIMEOUT_EN);
     constant LL_REPLAY_TIMEOUT_EN_STRING : string := boolean_to_string(LL_REPLAY_TIMEOUT_EN);
     constant MSIX_CAP_ON_STRING : string := boolean_to_string(MSIX_CAP_ON);
     constant MSI_CAP_64_BIT_ADDR_CAPABLE_STRING : string := boolean_to_string(MSI_CAP_64_BIT_ADDR_CAPABLE);
     constant MSI_CAP_ON_STRING : string := boolean_to_string(MSI_CAP_ON);
     constant MSI_CAP_PER_VECTOR_MASKING_CAPABLE_STRING : string := boolean_to_string( MSI_CAP_PER_VECTOR_MASKING_CAPABLE);
     constant PCIE_CAP_ON_STRING : string := boolean_to_string(PCIE_CAP_ON);
     constant PCIE_CAP_SLOT_IMPLEMENTED_STRING : string := boolean_to_string(PCIE_CAP_SLOT_IMPLEMENTED);
     constant PL_FAST_TRAIN_STRING : string := boolean_to_string(PL_FAST_TRAIN);
     constant PM_CAP_D1SUPPORT_STRING : string := boolean_to_string(PM_CAP_D1SUPPORT);
     constant PM_CAP_D2SUPPORT_STRING : string := boolean_to_string(PM_CAP_D2SUPPORT);
     constant PM_CAP_DSI_STRING : string := boolean_to_string(PM_CAP_DSI);
     constant PM_CAP_ON_STRING : string := boolean_to_string(PM_CAP_ON);
     constant PM_CAP_PME_CLOCK_STRING : string := boolean_to_string(PM_CAP_PME_CLOCK);
     constant PM_CSR_B2B3_STRING : string := boolean_to_string(PM_CSR_B2B3);
     constant PM_CSR_BPCCEN_STRING : string := boolean_to_string(PM_CSR_BPCCEN);
     constant PM_CSR_NOSOFTRST_STRING : string := boolean_to_string(PM_CSR_NOSOFTRST);
     constant RECRC_CHK_TRIM_STRING : string := boolean_to_string(RECRC_CHK_TRIM);
     constant ROOT_CAP_CRS_SW_VISIBILITY_STRING : string := boolean_to_string(ROOT_CAP_CRS_SW_VISIBILITY);
     constant SELECT_DLL_IF_STRING : string := boolean_to_string(SELECT_DLL_IF);
    constant SLOT_CAP_ATT_BUTTON_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_ATT_BUTTON_PRESENT);
    constant SLOT_CAP_ATT_INDICATOR_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_ATT_INDICATOR_PRESENT);
    constant SLOT_CAP_ELEC_INTERLOCK_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_ELEC_INTERLOCK_PRESENT);
    constant SLOT_CAP_HOTPLUG_CAPABLE_STRING : string := boolean_to_string(SLOT_CAP_HOTPLUG_CAPABLE);
    constant SLOT_CAP_HOTPLUG_SURPRISE_STRING : string := boolean_to_string(SLOT_CAP_HOTPLUG_SURPRISE);
    constant SLOT_CAP_MRL_SENSOR_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_MRL_SENSOR_PRESENT);
    constant SLOT_CAP_NO_CMD_COMPLETED_SUPPORT_STRING : string := boolean_to_string(SLOT_CAP_NO_CMD_COMPLETED_SUPPORT);
    constant SLOT_CAP_POWER_CONTROLLER_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_POWER_CONTROLLER_PRESENT);
    constant SLOT_CAP_POWER_INDICATOR_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_POWER_INDICATOR_PRESENT);
     constant TL_TFC_DISABLE_STRING : string := boolean_to_string(TL_TFC_DISABLE);
     constant TL_RBYPASS_STRING : string := boolean_to_string(TL_RBYPASS);
     constant TL_TX_CHECKS_DISABLE_STRING : string := boolean_to_string(TL_TX_CHECKS_DISABLE);
     
     constant UPCONFIG_CAPABLE_STRING : string := boolean_to_string(UPCONFIG_CAPABLE);
     constant UPSTREAM_FACING_STRING : string := boolean_to_string(UPSTREAM_FACING);
     constant UR_INV_REQ_STRING : string := boolean_to_string(UR_INV_REQ);
     constant VC0_CPL_INFINITE_STRING : string := boolean_to_string(VC0_CPL_INFINITE);
     constant VC_CAP_ON_STRING : string := boolean_to_string(VC_CAP_ON);
     constant VC_CAP_REJECT_SNOOP_TRANSACTIONS_STRING : string := boolean_to_string(VC_CAP_REJECT_SNOOP_TRANSACTIONS);
     constant VSEC_CAP_ON_STRING : string := boolean_to_string(VSEC_CAP_ON);
     constant VSEC_CAP_IS_LINK_VISIBLE_STRING : string := boolean_to_string(VSEC_CAP_IS_LINK_VISIBLE);

    signal GSR_dly : std_ulogic;
    
    signal AER_CAP_ECRC_CHECK_CAPABLE_BINARY : std_ulogic;
    signal AER_CAP_ECRC_GEN_CAPABLE_BINARY : std_ulogic;
    signal AER_CAP_ON_BINARY : std_ulogic;
    signal AER_CAP_PERMIT_ROOTERR_UPDATE_BINARY : std_ulogic;
    signal ALLOW_X8_GEN2_BINARY : std_ulogic;
    signal CMD_INTX_IMPLEMENTED_BINARY : std_ulogic;
    signal CPL_TIMEOUT_DISABLE_SUPPORTED_BINARY : std_ulogic;
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
    signal DISABLE_ASPM_L1_TIMER_BINARY : std_ulogic;
    signal DISABLE_BAR_FILTERING_BINARY : std_ulogic;
    signal DISABLE_ID_CHECK_BINARY : std_ulogic;
    signal DISABLE_LANE_REVERSAL_BINARY : std_ulogic;
    signal DISABLE_RX_TC_FILTER_BINARY : std_ulogic;
    signal DISABLE_SCRAMBLING_BINARY : std_ulogic;
    signal DSN_CAP_ON_BINARY : std_ulogic;
    signal ENABLE_RX_TD_ECRC_TRIM_BINARY : std_ulogic;
    signal ENTER_RVRY_EI_L0_BINARY : std_ulogic;
    signal EXIT_LOOPBACK_ON_EI_BINARY : std_ulogic;
    signal IS_SWITCH_BINARY : std_ulogic;
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
    signal LINK_CAP_RSVD_23_22_BINARY : std_logic_vector(1 downto 0);
    signal LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_BINARY : std_ulogic;
    signal LINK_CONTROL_RCB_BINARY : std_ulogic;
    signal LINK_CTRL2_DEEMPHASIS_BINARY : std_ulogic;
    signal LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_BINARY : std_ulogic;
    
    signal LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY : std_ulogic;
    signal LL_ACK_TIMEOUT_EN_BINARY : std_ulogic;
    signal LL_ACK_TIMEOUT_FUNC_BINARY : std_logic_vector(1 downto 0);
    signal LL_REPLAY_TIMEOUT_EN_BINARY : std_ulogic;
    signal LL_REPLAY_TIMEOUT_FUNC_BINARY : std_logic_vector(1 downto 0);
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
    signal PGL0_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PGL1_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PGL2_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PGL3_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PGL4_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PGL5_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PGL6_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PGL7_LANE_BINARY : std_logic_vector(2 downto 0);
    signal PL_AUTO_CONFIG_BINARY : std_logic_vector(2 downto 0);
    signal PL_FAST_TRAIN_BINARY : std_ulogic;
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
    signal SPARE_BIT0_BINARY : std_ulogic;
    signal SPARE_BIT1_BINARY : std_ulogic;
    signal SPARE_BIT2_BINARY : std_ulogic;
    signal SPARE_BIT3_BINARY : std_ulogic;
    signal SPARE_BIT4_BINARY : std_ulogic;
    signal SPARE_BIT5_BINARY : std_ulogic;
    signal SPARE_BIT6_BINARY : std_ulogic;
    signal SPARE_BIT7_BINARY : std_ulogic;
    signal SPARE_BIT8_BINARY : std_ulogic;
    signal SLOT_CAP_SLOT_POWER_LIMIT_SCALE_BINARY : std_logic_vector(1 downto 0);
    signal TL_RBYPASS_BINARY : std_ulogic;
    signal TL_RX_RAM_RADDR_LATENCY_BINARY : std_ulogic;
    signal TL_RX_RAM_RDATA_LATENCY_BINARY : std_logic_vector(1 downto 0);
    signal TL_RX_RAM_WRITE_LATENCY_BINARY : std_ulogic;
    signal TL_TFC_DISABLE_BINARY : std_ulogic;
    signal TL_TX_CHECKS_DISABLE_BINARY : std_ulogic;
    signal TL_TX_RAM_RADDR_LATENCY_BINARY : std_ulogic;
    signal TL_TX_RAM_RDATA_LATENCY_BINARY : std_logic_vector(1 downto 0);
    signal TL_TX_RAM_WRITE_LATENCY_BINARY : std_ulogic;
    signal UPCONFIG_CAPABLE_BINARY : std_ulogic;
    signal UPSTREAM_FACING_BINARY : std_ulogic;
    signal UR_INV_REQ_BINARY : std_ulogic;
    signal USER_CLK_FREQ_BINARY : std_logic_vector(2 downto 0);
    signal VC0_CPL_INFINITE_BINARY : std_ulogic;
    signal VC0_TOTAL_CREDITS_CD_BINARY : std_logic_vector(10 downto 0);
    signal VC0_TOTAL_CREDITS_CH_BINARY : std_logic_vector(6 downto 0);
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
    signal CFGCOMMANDBUSMASTERENABLE_out : std_ulogic;
    signal CFGCOMMANDINTERRUPTDISABLE_out : std_ulogic;
    signal CFGCOMMANDIOENABLE_out : std_ulogic;
    signal CFGCOMMANDMEMENABLE_out : std_ulogic;
    signal CFGCOMMANDSERREN_out : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTDIS_out : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTVAL_out : std_logic_vector(3 downto 0);
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
    signal CFGDO_out : std_logic_vector(31 downto 0);
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
    signal CFGLINKSTATUSBANDWITHSTATUS_out : std_ulogic;
    signal CFGLINKSTATUSCURRENTSPEED_out : std_logic_vector(1 downto 0);
    signal CFGLINKSTATUSDLLACTIVE_out : std_ulogic;
    signal CFGLINKSTATUSLINKTRAINING_out : std_ulogic;
    signal CFGLINKSTATUSNEGOTIATEDWIDTH_out : std_logic_vector(3 downto 0);
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
    signal CFGRDWRDONEN_out : std_ulogic;
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
    signal DRPDRDY_out : std_ulogic;
    signal LL2BADDLLPERRN_out : std_ulogic;
    signal LL2BADTLPERRN_out : std_ulogic;
    signal LL2PROTOCOLERRN_out : std_ulogic;
    signal LL2REPLAYROERRN_out : std_ulogic;
    signal LL2REPLAYTOERRN_out : std_ulogic;
    signal LL2SUSPENDOKN_out : std_ulogic;
    signal LL2TFCINIT1SEQN_out : std_ulogic;
    signal LL2TFCINIT2SEQN_out : std_ulogic;
    signal LNKCLKEN_out : std_ulogic;
    signal MIMRXRADDR_out : std_logic_vector(12 downto 0);
    signal MIMRXRCE_out : std_ulogic;
    signal MIMRXREN_out : std_ulogic;
    signal MIMRXWADDR_out : std_logic_vector(12 downto 0);
    signal MIMRXWDATA_out : std_logic_vector(67 downto 0);
    signal MIMRXWEN_out : std_ulogic;
    signal MIMTXRADDR_out : std_logic_vector(12 downto 0);
    signal MIMTXRCE_out : std_ulogic;
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
    signal PL2LINKUPN_out : std_ulogic;
    signal PL2RECEIVERERRN_out : std_ulogic;
    signal PL2RECOVERYN_out : std_ulogic;
    signal PL2RXELECIDLE_out : std_ulogic;
    signal PL2SUSPENDOK_out : std_ulogic;
    signal PLDBGVEC_out : std_logic_vector(11 downto 0);
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
    signal TL2ASPMSUSPENDCREDITCHECKOKN_out : std_ulogic;
    signal TL2ASPMSUSPENDREQN_out : std_ulogic;
    signal TL2PPMSUSPENDOKN_out : std_ulogic;
    signal TRNFCCPLD_out : std_logic_vector(11 downto 0);
    signal TRNFCCPLH_out : std_logic_vector(7 downto 0);
    signal TRNFCNPD_out : std_logic_vector(11 downto 0);
    signal TRNFCNPH_out : std_logic_vector(7 downto 0);
    signal TRNFCPD_out : std_logic_vector(11 downto 0);
    signal TRNFCPH_out : std_logic_vector(7 downto 0);
    signal TRNLNKUPN_out : std_ulogic;
    signal TRNRBARHITN_out : std_logic_vector(6 downto 0);
    signal TRNRDLLPDATA_out : std_logic_vector(31 downto 0);
    signal TRNRDLLPSRCRDYN_out : std_ulogic;
    signal TRNRD_out : std_logic_vector(63 downto 0);
    signal TRNRECRCERRN_out : std_ulogic;
    signal TRNREOFN_out : std_ulogic;
    signal TRNRERRFWDN_out : std_ulogic;
    signal TRNRREMN_out : std_ulogic;
    signal TRNRSOFN_out : std_ulogic;
    signal TRNRSRCDSCN_out : std_ulogic;
    signal TRNRSRCRDYN_out : std_ulogic;
    signal TRNTBUFAV_out : std_logic_vector(5 downto 0);
    signal TRNTCFGREQN_out : std_ulogic;
    signal TRNTDLLPDSTRDYN_out : std_ulogic;
    signal TRNTDSTRDYN_out : std_ulogic;
    signal TRNTERRDROPN_out : std_ulogic;
    signal USERRSTN_out : std_ulogic;
    
    signal CFGAERECRCCHECKEN_outdelay : std_ulogic;
    signal CFGAERECRCGENEN_outdelay : std_ulogic;
    signal CFGCOMMANDBUSMASTERENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDINTERRUPTDISABLE_outdelay : std_ulogic;
    signal CFGCOMMANDIOENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDMEMENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDSERREN_outdelay : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTDIS_outdelay : std_ulogic;
    signal CFGDEVCONTROL2CPLTIMEOUTVAL_outdelay : std_logic_vector(3 downto 0);
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
    signal CFGDO_outdelay : std_logic_vector(31 downto 0);
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
    signal CFGLINKSTATUSBANDWITHSTATUS_outdelay : std_ulogic;
    signal CFGLINKSTATUSCURRENTSPEED_outdelay : std_logic_vector(1 downto 0);
    signal CFGLINKSTATUSDLLACTIVE_outdelay : std_ulogic;
    signal CFGLINKSTATUSLINKTRAINING_outdelay : std_ulogic;
    signal CFGLINKSTATUSNEGOTIATEDWIDTH_outdelay : std_logic_vector(3 downto 0);
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
    signal CFGRDWRDONEN_outdelay : std_ulogic;
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
    signal DRPDRDY_outdelay : std_ulogic;
    signal LL2BADDLLPERRN_outdelay : std_ulogic;
    signal LL2BADTLPERRN_outdelay : std_ulogic;
    signal LL2PROTOCOLERRN_outdelay : std_ulogic;
    signal LL2REPLAYROERRN_outdelay : std_ulogic;
    signal LL2REPLAYTOERRN_outdelay : std_ulogic;
    signal LL2SUSPENDOKN_outdelay : std_ulogic;
    signal LL2TFCINIT1SEQN_outdelay : std_ulogic;
    signal LL2TFCINIT2SEQN_outdelay : std_ulogic;
    signal LNKCLKEN_outdelay : std_ulogic;
    signal MIMRXRADDR_outdelay : std_logic_vector(12 downto 0);
    signal MIMRXRCE_outdelay : std_ulogic;
    signal MIMRXREN_outdelay : std_ulogic;
    signal MIMRXWADDR_outdelay : std_logic_vector(12 downto 0);
    signal MIMRXWDATA_outdelay : std_logic_vector(67 downto 0);
    signal MIMRXWEN_outdelay : std_ulogic;
    signal MIMTXRADDR_outdelay : std_logic_vector(12 downto 0);
    signal MIMTXRCE_outdelay : std_ulogic;
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
    signal PL2LINKUPN_outdelay : std_ulogic;
    signal PL2RECEIVERERRN_outdelay : std_ulogic;
    signal PL2RECOVERYN_outdelay : std_ulogic;
    signal PL2RXELECIDLE_outdelay : std_ulogic;
    signal PL2SUSPENDOK_outdelay : std_ulogic;
    signal PLDBGVEC_outdelay : std_logic_vector(11 downto 0);
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
    signal TL2ASPMSUSPENDCREDITCHECKOKN_outdelay : std_ulogic;
    signal TL2ASPMSUSPENDREQN_outdelay : std_ulogic;
    signal TL2PPMSUSPENDOKN_outdelay : std_ulogic;
    signal TRNFCCPLD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCCPLH_outdelay : std_logic_vector(7 downto 0);
    signal TRNFCNPD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCNPH_outdelay : std_logic_vector(7 downto 0);
    signal TRNFCPD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCPH_outdelay : std_logic_vector(7 downto 0);
    signal TRNLNKUPN_outdelay : std_ulogic;
    signal TRNRBARHITN_outdelay : std_logic_vector(6 downto 0);
    signal TRNRDLLPDATA_outdelay : std_logic_vector(31 downto 0);
    signal TRNRDLLPSRCRDYN_outdelay : std_ulogic;
    signal TRNRD_outdelay : std_logic_vector(63 downto 0);
    signal TRNRECRCERRN_outdelay : std_ulogic;
    signal TRNREOFN_outdelay : std_ulogic;
    signal TRNRERRFWDN_outdelay : std_ulogic;
    signal TRNRREMN_outdelay : std_ulogic;
    signal TRNRSOFN_outdelay : std_ulogic;
    signal TRNRSRCDSCN_outdelay : std_ulogic;
    signal TRNRSRCRDYN_outdelay : std_ulogic;
    signal TRNTBUFAV_outdelay : std_logic_vector(5 downto 0);
    signal TRNTCFGREQN_outdelay : std_ulogic;
    signal TRNTDLLPDSTRDYN_outdelay : std_ulogic;
    signal TRNTDSTRDYN_outdelay : std_ulogic;
    signal TRNTERRDROPN_outdelay : std_ulogic;
    signal USERRSTN_outdelay : std_ulogic;
    
    signal CFGBYTEENN_ipd : std_logic_vector(3 downto 0);
    signal CFGDI_ipd : std_logic_vector(31 downto 0);
    signal CFGDSBUSNUMBER_ipd : std_logic_vector(7 downto 0);
    signal CFGDSDEVICENUMBER_ipd : std_logic_vector(4 downto 0);
    signal CFGDSFUNCTIONNUMBER_ipd : std_logic_vector(2 downto 0);
    signal CFGDSN_ipd : std_logic_vector(63 downto 0);
    signal CFGDWADDR_ipd : std_logic_vector(9 downto 0);
    signal CFGERRACSN_ipd : std_ulogic;
    signal CFGERRAERHEADERLOG_ipd : std_logic_vector(127 downto 0);
    signal CFGERRCORN_ipd : std_ulogic;
    signal CFGERRCPLABORTN_ipd : std_ulogic;
    signal CFGERRCPLTIMEOUTN_ipd : std_ulogic;
    signal CFGERRCPLUNEXPECTN_ipd : std_ulogic;
    signal CFGERRECRCN_ipd : std_ulogic;
    signal CFGERRLOCKEDN_ipd : std_ulogic;
    signal CFGERRPOSTEDN_ipd : std_ulogic;
    signal CFGERRTLPCPLHEADER_ipd : std_logic_vector(47 downto 0);
    signal CFGERRURN_ipd : std_ulogic;
    signal CFGINTERRUPTASSERTN_ipd : std_ulogic;
    signal CFGINTERRUPTDI_ipd : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTN_ipd : std_ulogic;
    signal CFGPMDIRECTASPML1N_ipd : std_ulogic;
    signal CFGPMSENDPMACKN_ipd : std_ulogic;
    signal CFGPMSENDPMETON_ipd : std_ulogic;
    signal CFGPMSENDPMNAKN_ipd : std_ulogic;
    signal CFGPMTURNOFFOKN_ipd : std_ulogic;
    signal CFGPMWAKEN_ipd : std_ulogic;
    signal CFGPORTNUMBER_ipd : std_logic_vector(7 downto 0);
    signal CFGRDENN_ipd : std_ulogic;
    signal CFGTRNPENDINGN_ipd : std_ulogic;
    signal CFGWRENN_ipd : std_ulogic;
    signal CFGWRREADONLYN_ipd : std_ulogic;
    signal CFGWRRW1CASRWN_ipd : std_ulogic;
    signal CMRSTN_ipd : std_ulogic;
    signal CMSTICKYRSTN_ipd : std_ulogic;
    signal DBGMODE_ipd : std_logic_vector(1 downto 0);
    signal DBGSUBMODE_ipd : std_ulogic;
    signal DLRSTN_ipd : std_ulogic;
    signal DRPCLK_ipd : std_ulogic;
    signal DRPDADDR_ipd : std_logic_vector(8 downto 0);
    signal DRPDEN_ipd : std_ulogic;
    signal DRPDI_ipd : std_logic_vector(15 downto 0);
    signal DRPDWE_ipd : std_ulogic;
    signal FUNCLVLRSTN_ipd : std_ulogic;
    signal LL2SENDASREQL1N_ipd : std_ulogic;
    signal LL2SENDENTERL1N_ipd : std_ulogic;
    signal LL2SENDENTERL23N_ipd : std_ulogic;
    signal LL2SUSPENDNOWN_ipd : std_ulogic;
    signal LL2TLPRCVN_ipd : std_ulogic;
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
    signal PLDOWNSTREAMDEEMPHSOURCE_ipd : std_ulogic;
    signal PLRSTN_ipd : std_ulogic;
    signal PLTRANSMITHOTRST_ipd : std_ulogic;
    signal PLUPSTREAMPREFERDEEMPH_ipd : std_ulogic;
    signal SYSRSTN_ipd : std_ulogic;
    signal TL2ASPMSUSPENDCREDITCHECKN_ipd : std_ulogic;
    signal TL2PPMSUSPENDREQN_ipd : std_ulogic;
    signal TLRSTN_ipd : std_ulogic;
    signal TRNFCSEL_ipd : std_logic_vector(2 downto 0);
    signal TRNRDSTRDYN_ipd : std_ulogic;
    signal TRNRNPOKN_ipd : std_ulogic;
    signal TRNTCFGGNTN_ipd : std_ulogic;
    signal TRNTDLLPDATA_ipd : std_logic_vector(31 downto 0);
    signal TRNTDLLPSRCRDYN_ipd : std_ulogic;
    signal TRNTD_ipd : std_logic_vector(63 downto 0);
    signal TRNTECRCGENN_ipd : std_ulogic;
    signal TRNTEOFN_ipd : std_ulogic;
    signal TRNTERRFWDN_ipd : std_ulogic;
    signal TRNTREMN_ipd : std_ulogic;
    signal TRNTSOFN_ipd : std_ulogic;
    signal TRNTSRCDSCN_ipd : std_ulogic;
    signal TRNTSRCRDYN_ipd : std_ulogic;
    signal TRNTSTRN_ipd : std_ulogic;
    signal USERCLK_ipd : std_ulogic;
    
    
    signal CFGBYTEENN_indelay : std_logic_vector(3 downto 0);
    signal CFGDI_indelay : std_logic_vector(31 downto 0);
    signal CFGDSBUSNUMBER_indelay : std_logic_vector(7 downto 0);
    signal CFGDSDEVICENUMBER_indelay : std_logic_vector(4 downto 0);
    signal CFGDSFUNCTIONNUMBER_indelay : std_logic_vector(2 downto 0);
    signal CFGDSN_indelay : std_logic_vector(63 downto 0);
    signal CFGDWADDR_indelay : std_logic_vector(9 downto 0);
    signal CFGERRACSN_indelay : std_ulogic;
    signal CFGERRAERHEADERLOG_indelay : std_logic_vector(127 downto 0);
    signal CFGERRCORN_indelay : std_ulogic;
    signal CFGERRCPLABORTN_indelay : std_ulogic;
    signal CFGERRCPLTIMEOUTN_indelay : std_ulogic;
    signal CFGERRCPLUNEXPECTN_indelay : std_ulogic;
    signal CFGERRECRCN_indelay : std_ulogic;
    signal CFGERRLOCKEDN_indelay : std_ulogic;
    signal CFGERRPOSTEDN_indelay : std_ulogic;
    signal CFGERRTLPCPLHEADER_indelay : std_logic_vector(47 downto 0);
    signal CFGERRURN_indelay : std_ulogic;
    signal CFGINTERRUPTASSERTN_indelay : std_ulogic;
    signal CFGINTERRUPTDI_indelay : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTN_indelay : std_ulogic;
    signal CFGPMDIRECTASPML1N_indelay : std_ulogic;
    signal CFGPMSENDPMACKN_indelay : std_ulogic;
    signal CFGPMSENDPMETON_indelay : std_ulogic;
    signal CFGPMSENDPMNAKN_indelay : std_ulogic;
    signal CFGPMTURNOFFOKN_indelay : std_ulogic;
    signal CFGPMWAKEN_indelay : std_ulogic;
    signal CFGPORTNUMBER_indelay : std_logic_vector(7 downto 0);
    signal CFGRDENN_indelay : std_ulogic;
    signal CFGTRNPENDINGN_indelay : std_ulogic;
    signal CFGWRENN_indelay : std_ulogic;
    signal CFGWRREADONLYN_indelay : std_ulogic;
    signal CFGWRRW1CASRWN_indelay : std_ulogic;
    signal CMRSTN_indelay : std_ulogic;
    signal CMSTICKYRSTN_indelay : std_ulogic;
    signal DBGMODE_indelay : std_logic_vector(1 downto 0);
    signal DBGSUBMODE_indelay : std_ulogic;
    signal DLRSTN_indelay : std_ulogic;
    signal DRPCLK_indelay : std_ulogic;
    signal DRPDADDR_indelay : std_logic_vector(8 downto 0);
    signal DRPDEN_indelay : std_ulogic;
    signal DRPDI_indelay : std_logic_vector(15 downto 0);
    signal DRPDWE_indelay : std_ulogic;
    signal FUNCLVLRSTN_indelay : std_ulogic;
    signal LL2SENDASREQL1N_indelay : std_ulogic;
    signal LL2SENDENTERL1N_indelay : std_ulogic;
    signal LL2SENDENTERL23N_indelay : std_ulogic;
    signal LL2SUSPENDNOWN_indelay : std_ulogic;
    signal LL2TLPRCVN_indelay : std_ulogic;
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
    signal PLDOWNSTREAMDEEMPHSOURCE_indelay : std_ulogic;
    signal PLRSTN_indelay : std_ulogic;
    signal PLTRANSMITHOTRST_indelay : std_ulogic;
    signal PLUPSTREAMPREFERDEEMPH_indelay : std_ulogic;
    signal SYSRSTN_indelay : std_ulogic;
    signal TL2ASPMSUSPENDCREDITCHECKN_indelay : std_ulogic;
    signal TL2PPMSUSPENDREQN_indelay : std_ulogic;
    signal TLRSTN_indelay : std_ulogic;
    signal TRNFCSEL_indelay : std_logic_vector(2 downto 0);
    signal TRNRDSTRDYN_indelay : std_ulogic;
    signal TRNRNPOKN_indelay : std_ulogic;
    signal TRNTCFGGNTN_indelay : std_ulogic;
    signal TRNTDLLPDATA_indelay : std_logic_vector(31 downto 0);
    signal TRNTDLLPSRCRDYN_indelay : std_ulogic;
    signal TRNTD_indelay : std_logic_vector(63 downto 0);
    signal TRNTECRCGENN_indelay : std_ulogic;
    signal TRNTEOFN_indelay : std_ulogic;
    signal TRNTERRFWDN_indelay : std_ulogic;
    signal TRNTREMN_indelay : std_ulogic;
    signal TRNTSOFN_indelay : std_ulogic;
    signal TRNTSRCDSCN_indelay : std_ulogic;
    signal TRNTSRCRDYN_indelay : std_ulogic;
    signal TRNTSTRN_indelay : std_ulogic;
    signal USERCLK_indelay : std_ulogic;
    
    begin
        
    CFGAERECRCCHECKEN_out <= CFGAERECRCCHECKEN_outdelay after OUT_DELAY;
    CFGAERECRCGENEN_out <= CFGAERECRCGENEN_outdelay after OUT_DELAY;
    CFGCOMMANDBUSMASTERENABLE_out <= CFGCOMMANDBUSMASTERENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDINTERRUPTDISABLE_out <= CFGCOMMANDINTERRUPTDISABLE_outdelay after OUT_DELAY;
    CFGCOMMANDIOENABLE_out <= CFGCOMMANDIOENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDMEMENABLE_out <= CFGCOMMANDMEMENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDSERREN_out <= CFGCOMMANDSERREN_outdelay after OUT_DELAY;
    CFGDEVCONTROL2CPLTIMEOUTDIS_out <= CFGDEVCONTROL2CPLTIMEOUTDIS_outdelay after OUT_DELAY;
    CFGDEVCONTROL2CPLTIMEOUTVAL_out <= CFGDEVCONTROL2CPLTIMEOUTVAL_outdelay after OUT_DELAY;
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
    CFGDO_out <= CFGDO_outdelay after OUT_DELAY;
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
    CFGLINKSTATUSBANDWITHSTATUS_out <= CFGLINKSTATUSBANDWITHSTATUS_outdelay after OUT_DELAY;
    CFGLINKSTATUSCURRENTSPEED_out <= CFGLINKSTATUSCURRENTSPEED_outdelay after OUT_DELAY;
    CFGLINKSTATUSDLLACTIVE_out <= CFGLINKSTATUSDLLACTIVE_outdelay after OUT_DELAY;
    CFGLINKSTATUSLINKTRAINING_out <= CFGLINKSTATUSLINKTRAINING_outdelay after OUT_DELAY;
    CFGLINKSTATUSNEGOTIATEDWIDTH_out <= CFGLINKSTATUSNEGOTIATEDWIDTH_outdelay after OUT_DELAY;
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
    CFGRDWRDONEN_out <= CFGRDWRDONEN_outdelay after OUT_DELAY;
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
    DRPDRDY_out <= DRPDRDY_outdelay after OUT_DELAY;
    LL2BADDLLPERRN_out <= LL2BADDLLPERRN_outdelay after OUT_DELAY;
    LL2BADTLPERRN_out <= LL2BADTLPERRN_outdelay after OUT_DELAY;
    LL2PROTOCOLERRN_out <= LL2PROTOCOLERRN_outdelay after OUT_DELAY;
    LL2REPLAYROERRN_out <= LL2REPLAYROERRN_outdelay after OUT_DELAY;
    LL2REPLAYTOERRN_out <= LL2REPLAYTOERRN_outdelay after OUT_DELAY;
    LL2SUSPENDOKN_out <= LL2SUSPENDOKN_outdelay after OUT_DELAY;
    LL2TFCINIT1SEQN_out <= LL2TFCINIT1SEQN_outdelay after OUT_DELAY;
    LL2TFCINIT2SEQN_out <= LL2TFCINIT2SEQN_outdelay after OUT_DELAY;
    LNKCLKEN_out <= LNKCLKEN_outdelay after OUT_DELAY;
    MIMRXRADDR_out <= MIMRXRADDR_outdelay after OUT_DELAY;
    MIMRXRCE_out <= MIMRXRCE_outdelay after OUT_DELAY;
    MIMRXREN_out <= MIMRXREN_outdelay after OUT_DELAY;
    MIMRXWADDR_out <= MIMRXWADDR_outdelay after OUT_DELAY;
    MIMRXWDATA_out <= MIMRXWDATA_outdelay after OUT_DELAY;
    MIMRXWEN_out <= MIMRXWEN_outdelay after OUT_DELAY;
    MIMTXRADDR_out <= MIMTXRADDR_outdelay after OUT_DELAY;
    MIMTXRCE_out <= MIMTXRCE_outdelay after OUT_DELAY;
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
    PL2LINKUPN_out <= PL2LINKUPN_outdelay after OUT_DELAY;
    PL2RECEIVERERRN_out <= PL2RECEIVERERRN_outdelay after OUT_DELAY;
    PL2RECOVERYN_out <= PL2RECOVERYN_outdelay after OUT_DELAY;
    PL2RXELECIDLE_out <= PL2RXELECIDLE_outdelay after OUT_DELAY;
    PL2SUSPENDOK_out <= PL2SUSPENDOK_outdelay after OUT_DELAY;
    PLDBGVEC_out <= PLDBGVEC_outdelay after OUT_DELAY;
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
    TL2ASPMSUSPENDCREDITCHECKOKN_out <= TL2ASPMSUSPENDCREDITCHECKOKN_outdelay after OUT_DELAY;
    TL2ASPMSUSPENDREQN_out <= TL2ASPMSUSPENDREQN_outdelay after OUT_DELAY;
    TL2PPMSUSPENDOKN_out <= TL2PPMSUSPENDOKN_outdelay after OUT_DELAY;
    TRNFCCPLD_out <= TRNFCCPLD_outdelay after OUT_DELAY;
    TRNFCCPLH_out <= TRNFCCPLH_outdelay after OUT_DELAY;
    TRNFCNPD_out <= TRNFCNPD_outdelay after OUT_DELAY;
    TRNFCNPH_out <= TRNFCNPH_outdelay after OUT_DELAY;
    TRNFCPD_out <= TRNFCPD_outdelay after OUT_DELAY;
    TRNFCPH_out <= TRNFCPH_outdelay after OUT_DELAY;
    TRNLNKUPN_out <= TRNLNKUPN_outdelay after OUT_DELAY;
    TRNRBARHITN_out <= TRNRBARHITN_outdelay after OUT_DELAY;
    TRNRDLLPDATA_out <= TRNRDLLPDATA_outdelay after OUT_DELAY;
    TRNRDLLPSRCRDYN_out <= TRNRDLLPSRCRDYN_outdelay after OUT_DELAY;
    TRNRD_out <= TRNRD_outdelay after OUT_DELAY;
    TRNRECRCERRN_out <= TRNRECRCERRN_outdelay after OUT_DELAY;
    TRNREOFN_out <= TRNREOFN_outdelay after OUT_DELAY;
    TRNRERRFWDN_out <= TRNRERRFWDN_outdelay after OUT_DELAY;
    TRNRREMN_out <= TRNRREMN_outdelay after OUT_DELAY;
    TRNRSOFN_out <= TRNRSOFN_outdelay after OUT_DELAY;
    TRNRSRCDSCN_out <= TRNRSRCDSCN_outdelay after OUT_DELAY;
    TRNRSRCRDYN_out <= TRNRSRCRDYN_outdelay after OUT_DELAY;
    TRNTBUFAV_out <= TRNTBUFAV_outdelay after OUT_DELAY;
    TRNTCFGREQN_out <= TRNTCFGREQN_outdelay after OUT_DELAY;
    TRNTDLLPDSTRDYN_out <= TRNTDLLPDSTRDYN_outdelay after OUT_DELAY;
    TRNTDSTRDYN_out <= TRNTDSTRDYN_outdelay after OUT_DELAY;
    TRNTERRDROPN_out <= TRNTERRDROPN_outdelay after OUT_DELAY;
    USERRSTN_out <= USERRSTN_outdelay after OUT_DELAY;
    
    DRPCLK_ipd <= DRPCLK;
    PIPECLK_ipd <= PIPECLK;
    USERCLK_ipd <= USERCLK;
    
    CFGBYTEENN_ipd <= CFGBYTEENN;
    CFGDI_ipd <= CFGDI;
    CFGDSBUSNUMBER_ipd <= CFGDSBUSNUMBER;
    CFGDSDEVICENUMBER_ipd <= CFGDSDEVICENUMBER;
    CFGDSFUNCTIONNUMBER_ipd <= CFGDSFUNCTIONNUMBER;
    CFGDSN_ipd <= CFGDSN;
    CFGDWADDR_ipd <= CFGDWADDR;
    CFGERRACSN_ipd <= CFGERRACSN;
    CFGERRAERHEADERLOG_ipd <= CFGERRAERHEADERLOG;
    CFGERRCORN_ipd <= CFGERRCORN;
    CFGERRCPLABORTN_ipd <= CFGERRCPLABORTN;
    CFGERRCPLTIMEOUTN_ipd <= CFGERRCPLTIMEOUTN;
    CFGERRCPLUNEXPECTN_ipd <= CFGERRCPLUNEXPECTN;
    CFGERRECRCN_ipd <= CFGERRECRCN;
    CFGERRLOCKEDN_ipd <= CFGERRLOCKEDN;
    CFGERRPOSTEDN_ipd <= CFGERRPOSTEDN;
    CFGERRTLPCPLHEADER_ipd <= CFGERRTLPCPLHEADER;
    CFGERRURN_ipd <= CFGERRURN;
    CFGINTERRUPTASSERTN_ipd <= CFGINTERRUPTASSERTN;
    CFGINTERRUPTDI_ipd <= CFGINTERRUPTDI;
    CFGINTERRUPTN_ipd <= CFGINTERRUPTN;
    CFGPMDIRECTASPML1N_ipd <= CFGPMDIRECTASPML1N;
    CFGPMSENDPMACKN_ipd <= CFGPMSENDPMACKN;
    CFGPMSENDPMETON_ipd <= CFGPMSENDPMETON;
    CFGPMSENDPMNAKN_ipd <= CFGPMSENDPMNAKN;
    CFGPMTURNOFFOKN_ipd <= CFGPMTURNOFFOKN;
    CFGPMWAKEN_ipd <= CFGPMWAKEN;
    CFGPORTNUMBER_ipd <= CFGPORTNUMBER;
    CFGRDENN_ipd <= CFGRDENN;
    CFGTRNPENDINGN_ipd <= CFGTRNPENDINGN;
    CFGWRENN_ipd <= CFGWRENN;
    CFGWRREADONLYN_ipd <= CFGWRREADONLYN;
    CFGWRRW1CASRWN_ipd <= CFGWRRW1CASRWN;
    CMRSTN_ipd <= CMRSTN;
    CMSTICKYRSTN_ipd <= CMSTICKYRSTN;
    DBGMODE_ipd <= DBGMODE;
    DBGSUBMODE_ipd <= DBGSUBMODE;
    DLRSTN_ipd <= DLRSTN;
    DRPDADDR_ipd <= DRPDADDR;
    DRPDEN_ipd <= DRPDEN;
    DRPDI_ipd <= DRPDI;
    DRPDWE_ipd <= DRPDWE;
    FUNCLVLRSTN_ipd <= FUNCLVLRSTN;
    LL2SENDASREQL1N_ipd <= LL2SENDASREQL1N;
    LL2SENDENTERL1N_ipd <= LL2SENDENTERL1N;
    LL2SENDENTERL23N_ipd <= LL2SENDENTERL23N;
    LL2SUSPENDNOWN_ipd <= LL2SUSPENDNOWN;
    LL2TLPRCVN_ipd <= LL2TLPRCVN;
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
    PLDOWNSTREAMDEEMPHSOURCE_ipd <= PLDOWNSTREAMDEEMPHSOURCE;
    PLRSTN_ipd <= PLRSTN;
    PLTRANSMITHOTRST_ipd <= PLTRANSMITHOTRST;
    PLUPSTREAMPREFERDEEMPH_ipd <= PLUPSTREAMPREFERDEEMPH;
    SYSRSTN_ipd <= SYSRSTN;
    TL2ASPMSUSPENDCREDITCHECKN_ipd <= TL2ASPMSUSPENDCREDITCHECKN;
    TL2PPMSUSPENDREQN_ipd <= TL2PPMSUSPENDREQN;
    TLRSTN_ipd <= TLRSTN;
    TRNFCSEL_ipd <= TRNFCSEL;
    TRNRDSTRDYN_ipd <= TRNRDSTRDYN;
    TRNRNPOKN_ipd <= TRNRNPOKN;
    TRNTCFGGNTN_ipd <= TRNTCFGGNTN;
    TRNTDLLPDATA_ipd <= TRNTDLLPDATA;
    TRNTDLLPSRCRDYN_ipd <= TRNTDLLPSRCRDYN;
    TRNTD_ipd <= TRNTD;
    TRNTECRCGENN_ipd <= TRNTECRCGENN;
    TRNTEOFN_ipd <= TRNTEOFN;
    TRNTERRFWDN_ipd <= TRNTERRFWDN;
    TRNTREMN_ipd <= TRNTREMN;
    TRNTSOFN_ipd <= TRNTSOFN;
    TRNTSRCDSCN_ipd <= TRNTSRCDSCN;
    TRNTSRCRDYN_ipd <= TRNTSRCRDYN;
    TRNTSTRN_ipd <= TRNTSTRN;
    
    DRPCLK_indelay <= DRPCLK_ipd after INCLK_DELAY;
    PIPECLK_indelay <= PIPECLK_ipd after INCLK_DELAY;
    USERCLK_indelay <= USERCLK_ipd after INCLK_DELAY;
    
    CFGBYTEENN_indelay <= CFGBYTEENN_ipd after IN_DELAY;
    CFGDI_indelay <= CFGDI_ipd after IN_DELAY;
    CFGDSBUSNUMBER_indelay <= CFGDSBUSNUMBER_ipd after IN_DELAY;
    CFGDSDEVICENUMBER_indelay <= CFGDSDEVICENUMBER_ipd after IN_DELAY;
    CFGDSFUNCTIONNUMBER_indelay <= CFGDSFUNCTIONNUMBER_ipd after IN_DELAY;
    CFGDSN_indelay <= CFGDSN_ipd after IN_DELAY;
    CFGDWADDR_indelay <= CFGDWADDR_ipd after IN_DELAY;
    CFGERRACSN_indelay <= CFGERRACSN_ipd after IN_DELAY;
    CFGERRAERHEADERLOG_indelay <= CFGERRAERHEADERLOG_ipd after IN_DELAY;
    CFGERRCORN_indelay <= CFGERRCORN_ipd after IN_DELAY;
    CFGERRCPLABORTN_indelay <= CFGERRCPLABORTN_ipd after IN_DELAY;
    CFGERRCPLTIMEOUTN_indelay <= CFGERRCPLTIMEOUTN_ipd after IN_DELAY;
    CFGERRCPLUNEXPECTN_indelay <= CFGERRCPLUNEXPECTN_ipd after IN_DELAY;
    CFGERRECRCN_indelay <= CFGERRECRCN_ipd after IN_DELAY;
    CFGERRLOCKEDN_indelay <= CFGERRLOCKEDN_ipd after IN_DELAY;
    CFGERRPOSTEDN_indelay <= CFGERRPOSTEDN_ipd after IN_DELAY;
    CFGERRTLPCPLHEADER_indelay <= CFGERRTLPCPLHEADER_ipd after IN_DELAY;
    CFGERRURN_indelay <= CFGERRURN_ipd after IN_DELAY;
    CFGINTERRUPTASSERTN_indelay <= CFGINTERRUPTASSERTN_ipd after IN_DELAY;
    CFGINTERRUPTDI_indelay <= CFGINTERRUPTDI_ipd after IN_DELAY;
    CFGINTERRUPTN_indelay <= CFGINTERRUPTN_ipd after IN_DELAY;
    CFGPMDIRECTASPML1N_indelay <= CFGPMDIRECTASPML1N_ipd after IN_DELAY;
    CFGPMSENDPMACKN_indelay <= CFGPMSENDPMACKN_ipd after IN_DELAY;
    CFGPMSENDPMETON_indelay <= CFGPMSENDPMETON_ipd after IN_DELAY;
    CFGPMSENDPMNAKN_indelay <= CFGPMSENDPMNAKN_ipd after IN_DELAY;
    CFGPMTURNOFFOKN_indelay <= CFGPMTURNOFFOKN_ipd after IN_DELAY;
    CFGPMWAKEN_indelay <= CFGPMWAKEN_ipd after IN_DELAY;
    CFGPORTNUMBER_indelay <= CFGPORTNUMBER_ipd after IN_DELAY;
    CFGRDENN_indelay <= CFGRDENN_ipd after IN_DELAY;
    CFGTRNPENDINGN_indelay <= CFGTRNPENDINGN_ipd after IN_DELAY;
    CFGWRENN_indelay <= CFGWRENN_ipd after IN_DELAY;
    CFGWRREADONLYN_indelay <= CFGWRREADONLYN_ipd after IN_DELAY;
    CFGWRRW1CASRWN_indelay <= CFGWRRW1CASRWN_ipd after IN_DELAY;
    CMRSTN_indelay <= CMRSTN_ipd after IN_DELAY;
    CMSTICKYRSTN_indelay <= CMSTICKYRSTN_ipd after IN_DELAY;
    DBGMODE_indelay <= DBGMODE_ipd after IN_DELAY;
    DBGSUBMODE_indelay <= DBGSUBMODE_ipd after IN_DELAY;
    DLRSTN_indelay <= DLRSTN_ipd after IN_DELAY;
    DRPDADDR_indelay <= DRPDADDR_ipd after IN_DELAY;
    DRPDEN_indelay <= DRPDEN_ipd after IN_DELAY;
    DRPDI_indelay <= DRPDI_ipd after IN_DELAY;
    DRPDWE_indelay <= DRPDWE_ipd after IN_DELAY;
    FUNCLVLRSTN_indelay <= FUNCLVLRSTN_ipd after IN_DELAY;
    LL2SENDASREQL1N_indelay <= LL2SENDASREQL1N_ipd after IN_DELAY;
    LL2SENDENTERL1N_indelay <= LL2SENDENTERL1N_ipd after IN_DELAY;
    LL2SENDENTERL23N_indelay <= LL2SENDENTERL23N_ipd after IN_DELAY;
    LL2SUSPENDNOWN_indelay <= LL2SUSPENDNOWN_ipd after IN_DELAY;
    LL2TLPRCVN_indelay <= LL2TLPRCVN_ipd after IN_DELAY;
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
    PLDOWNSTREAMDEEMPHSOURCE_indelay <= PLDOWNSTREAMDEEMPHSOURCE_ipd after IN_DELAY;
    PLRSTN_indelay <= PLRSTN_ipd after IN_DELAY;
    PLTRANSMITHOTRST_indelay <= PLTRANSMITHOTRST_ipd after IN_DELAY;
    PLUPSTREAMPREFERDEEMPH_indelay <= PLUPSTREAMPREFERDEEMPH_ipd after IN_DELAY;
    SYSRSTN_indelay <= SYSRSTN_ipd after IN_DELAY;
    TL2ASPMSUSPENDCREDITCHECKN_indelay <= TL2ASPMSUSPENDCREDITCHECKN_ipd after IN_DELAY;
    TL2PPMSUSPENDREQN_indelay <= TL2PPMSUSPENDREQN_ipd after IN_DELAY;
    TLRSTN_indelay <= TLRSTN_ipd after IN_DELAY;
    TRNFCSEL_indelay <= TRNFCSEL_ipd after IN_DELAY;
    TRNRDSTRDYN_indelay <= TRNRDSTRDYN_ipd after IN_DELAY;
    TRNRNPOKN_indelay <= TRNRNPOKN_ipd after IN_DELAY;
    TRNTCFGGNTN_indelay <= TRNTCFGGNTN_ipd after IN_DELAY;
    TRNTDLLPDATA_indelay <= TRNTDLLPDATA_ipd after IN_DELAY;
    TRNTDLLPSRCRDYN_indelay <= TRNTDLLPSRCRDYN_ipd after IN_DELAY;
    TRNTD_indelay <= TRNTD_ipd after IN_DELAY;
    TRNTECRCGENN_indelay <= TRNTECRCGENN_ipd after IN_DELAY;
    TRNTEOFN_indelay <= TRNTEOFN_ipd after IN_DELAY;
    TRNTERRFWDN_indelay <= TRNTERRFWDN_ipd after IN_DELAY;
    TRNTREMN_indelay <= TRNTREMN_ipd after IN_DELAY;
    TRNTSOFN_indelay <= TRNTSOFN_ipd after IN_DELAY;
    TRNTSRCDSCN_indelay <= TRNTSRCDSCN_ipd after IN_DELAY;
    TRNTSRCRDYN_indelay <= TRNTSRCRDYN_ipd after IN_DELAY;
    TRNTSTRN_indelay <= TRNTSTRN_ipd after IN_DELAY;

    PCIE_2_0_WRAP_INST : PCIE_2_0_WRAP
      generic map (
        AER_BASE_PTR         => AER_BASE_PTR_STRING,
        AER_CAP_ECRC_CHECK_CAPABLE => AER_CAP_ECRC_CHECK_CAPABLE_STRING,
        AER_CAP_ECRC_GEN_CAPABLE => AER_CAP_ECRC_GEN_CAPABLE_STRING,
        AER_CAP_ID           => AER_CAP_ID_STRING,
        AER_CAP_INT_MSG_NUM_MSI => AER_CAP_INT_MSG_NUM_MSI_STRING,
        AER_CAP_INT_MSG_NUM_MSIX => AER_CAP_INT_MSG_NUM_MSIX_STRING,
        AER_CAP_NEXTPTR      => AER_CAP_NEXTPTR_STRING,
        AER_CAP_ON           => AER_CAP_ON_STRING,
        AER_CAP_PERMIT_ROOTERR_UPDATE => AER_CAP_PERMIT_ROOTERR_UPDATE_STRING,
        AER_CAP_VERSION      => AER_CAP_VERSION_STRING,
        ALLOW_X8_GEN2        => ALLOW_X8_GEN2_STRING,
        BAR0                 => BAR0_STRING,
        BAR1                 => BAR1_STRING,
        BAR2                 => BAR2_STRING,
        BAR3                 => BAR3_STRING,
        BAR4                 => BAR4_STRING,
        BAR5                 => BAR5_STRING,
        CAPABILITIES_PTR     => CAPABILITIES_PTR_STRING,
        CARDBUS_CIS_POINTER  => CARDBUS_CIS_POINTER_STRING,
        CLASS_CODE           => CLASS_CODE_STRING,
        CMD_INTX_IMPLEMENTED => CMD_INTX_IMPLEMENTED_STRING,
        CPL_TIMEOUT_DISABLE_SUPPORTED => CPL_TIMEOUT_DISABLE_SUPPORTED_STRING,
        CPL_TIMEOUT_RANGES_SUPPORTED => CPL_TIMEOUT_RANGES_SUPPORTED_STRING,
        CRM_MODULE_RSTS      => CRM_MODULE_RSTS_STRING,
        DEVICE_ID            => DEVICE_ID_STRING,
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE_STRING,
        DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE => DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE_STRING,
        DEV_CAP_ENDPOINT_L0S_LATENCY => DEV_CAP_ENDPOINT_L0S_LATENCY,
        DEV_CAP_ENDPOINT_L1_LATENCY => DEV_CAP_ENDPOINT_L1_LATENCY,
        DEV_CAP_EXT_TAG_SUPPORTED => DEV_CAP_EXT_TAG_SUPPORTED_STRING,
        DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE => DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_STRING,
        DEV_CAP_MAX_PAYLOAD_SUPPORTED => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
        DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT => DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT,
        DEV_CAP_ROLE_BASED_ERROR => DEV_CAP_ROLE_BASED_ERROR_STRING,
        DEV_CAP_RSVD_14_12   => DEV_CAP_RSVD_14_12,
        DEV_CAP_RSVD_17_16   => DEV_CAP_RSVD_17_16,
        DEV_CAP_RSVD_31_29   => DEV_CAP_RSVD_31_29,
        DEV_CONTROL_AUX_POWER_SUPPORTED => DEV_CONTROL_AUX_POWER_SUPPORTED_STRING,
        DISABLE_ASPM_L1_TIMER => DISABLE_ASPM_L1_TIMER_STRING,
        DISABLE_BAR_FILTERING => DISABLE_BAR_FILTERING_STRING,
        DISABLE_ID_CHECK     => DISABLE_ID_CHECK_STRING,
        DISABLE_LANE_REVERSAL => DISABLE_LANE_REVERSAL_STRING,
        DISABLE_RX_TC_FILTER => DISABLE_RX_TC_FILTER_STRING,
        DISABLE_SCRAMBLING   => DISABLE_SCRAMBLING_STRING,
        DNSTREAM_LINK_NUM    => DNSTREAM_LINK_NUM_STRING,
        DSN_BASE_PTR         => DSN_BASE_PTR_STRING,
        DSN_CAP_ID           => DSN_CAP_ID_STRING,
        DSN_CAP_NEXTPTR      => DSN_CAP_NEXTPTR_STRING,
        DSN_CAP_ON           => DSN_CAP_ON_STRING,
        DSN_CAP_VERSION      => DSN_CAP_VERSION_STRING,
        ENABLE_MSG_ROUTE     => ENABLE_MSG_ROUTE_STRING,
        ENABLE_RX_TD_ECRC_TRIM => ENABLE_RX_TD_ECRC_TRIM_STRING,
        ENTER_RVRY_EI_L0     => ENTER_RVRY_EI_L0_STRING,
        EXIT_LOOPBACK_ON_EI  => EXIT_LOOPBACK_ON_EI_STRING,
        EXPANSION_ROM        => EXPANSION_ROM_STRING,
        EXT_CFG_CAP_PTR      => EXT_CFG_CAP_PTR_STRING,
        EXT_CFG_XP_CAP_PTR   => EXT_CFG_XP_CAP_PTR_STRING,
        HEADER_TYPE          => HEADER_TYPE_STRING,
        INFER_EI             => INFER_EI_STRING,
        INTERRUPT_PIN        => INTERRUPT_PIN_STRING,
        IS_SWITCH            => IS_SWITCH_STRING,
        LAST_CONFIG_DWORD    => LAST_CONFIG_DWORD_STRING,
        LINK_CAP_ASPM_SUPPORT => LINK_CAP_ASPM_SUPPORT,
        LINK_CAP_CLOCK_POWER_MANAGEMENT => LINK_CAP_CLOCK_POWER_MANAGEMENT_STRING,
        LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP => LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP_STRING,
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1,
        LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 => LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2,
        LINK_CAP_L0S_EXIT_LATENCY_GEN1 => LINK_CAP_L0S_EXIT_LATENCY_GEN1,
        LINK_CAP_L0S_EXIT_LATENCY_GEN2 => LINK_CAP_L0S_EXIT_LATENCY_GEN2,
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1,
        LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 => LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2,
        LINK_CAP_L1_EXIT_LATENCY_GEN1 => LINK_CAP_L1_EXIT_LATENCY_GEN1,
        LINK_CAP_L1_EXIT_LATENCY_GEN2 => LINK_CAP_L1_EXIT_LATENCY_GEN2,
        LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP => LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP_STRING,
        LINK_CAP_MAX_LINK_SPEED => LINK_CAP_MAX_LINK_SPEED_STRING,
        LINK_CAP_MAX_LINK_WIDTH => LINK_CAP_MAX_LINK_WIDTH_STRING,
        LINK_CAP_RSVD_23_22  => LINK_CAP_RSVD_23_22,
        LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE => LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_STRING,
        LINK_CONTROL_RCB     => LINK_CONTROL_RCB,
        LINK_CTRL2_DEEMPHASIS => LINK_CTRL2_DEEMPHASIS_STRING,
        LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE => LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_STRING,
        LINK_CTRL2_TARGET_LINK_SPEED => LINK_CTRL2_TARGET_LINK_SPEED_STRING,
        LINK_STATUS_SLOT_CLOCK_CONFIG => LINK_STATUS_SLOT_CLOCK_CONFIG_STRING,
        LL_ACK_TIMEOUT       => LL_ACK_TIMEOUT_STRING,
        LL_ACK_TIMEOUT_EN    => LL_ACK_TIMEOUT_EN_STRING,
        LL_ACK_TIMEOUT_FUNC  => LL_ACK_TIMEOUT_FUNC,
        LL_REPLAY_TIMEOUT    => LL_REPLAY_TIMEOUT_STRING,
        LL_REPLAY_TIMEOUT_EN => LL_REPLAY_TIMEOUT_EN_STRING,
        LL_REPLAY_TIMEOUT_FUNC => LL_REPLAY_TIMEOUT_FUNC,
        LTSSM_MAX_LINK_WIDTH => LTSSM_MAX_LINK_WIDTH_STRING,
        MSIX_BASE_PTR        => MSIX_BASE_PTR_STRING,
        MSIX_CAP_ID          => MSIX_CAP_ID_STRING,
        MSIX_CAP_NEXTPTR     => MSIX_CAP_NEXTPTR_STRING,
        MSIX_CAP_ON          => MSIX_CAP_ON_STRING,
        MSIX_CAP_PBA_BIR     => MSIX_CAP_PBA_BIR,
        MSIX_CAP_PBA_OFFSET  => MSIX_CAP_PBA_OFFSET_STRING,
        MSIX_CAP_TABLE_BIR   => MSIX_CAP_TABLE_BIR,
        MSIX_CAP_TABLE_OFFSET => MSIX_CAP_TABLE_OFFSET_STRING,
        MSIX_CAP_TABLE_SIZE  => MSIX_CAP_TABLE_SIZE_STRING,
        MSI_BASE_PTR         => MSI_BASE_PTR_STRING,
        MSI_CAP_64_BIT_ADDR_CAPABLE => MSI_CAP_64_BIT_ADDR_CAPABLE_STRING,
        MSI_CAP_ID           => MSI_CAP_ID_STRING,
        MSI_CAP_MULTIMSGCAP  => MSI_CAP_MULTIMSGCAP,
        MSI_CAP_MULTIMSG_EXTENSION => MSI_CAP_MULTIMSG_EXTENSION,
        MSI_CAP_NEXTPTR      => MSI_CAP_NEXTPTR_STRING,
        MSI_CAP_ON           => MSI_CAP_ON_STRING,
        MSI_CAP_PER_VECTOR_MASKING_CAPABLE => MSI_CAP_PER_VECTOR_MASKING_CAPABLE_STRING,
        N_FTS_COMCLK_GEN1    => N_FTS_COMCLK_GEN1,
        N_FTS_COMCLK_GEN2    => N_FTS_COMCLK_GEN2,
        N_FTS_GEN1           => N_FTS_GEN1,
        N_FTS_GEN2           => N_FTS_GEN2,
        PCIE_BASE_PTR        => PCIE_BASE_PTR_STRING,
        PCIE_CAP_CAPABILITY_ID => PCIE_CAP_CAPABILITY_ID_STRING,
        PCIE_CAP_CAPABILITY_VERSION => PCIE_CAP_CAPABILITY_VERSION_STRING,
        PCIE_CAP_DEVICE_PORT_TYPE => PCIE_CAP_DEVICE_PORT_TYPE_STRING,
        PCIE_CAP_INT_MSG_NUM => PCIE_CAP_INT_MSG_NUM_STRING,
        PCIE_CAP_NEXTPTR     => PCIE_CAP_NEXTPTR_STRING,
        PCIE_CAP_ON          => PCIE_CAP_ON_STRING,
        PCIE_CAP_RSVD_15_14  => PCIE_CAP_RSVD_15_14,
        PCIE_CAP_SLOT_IMPLEMENTED => PCIE_CAP_SLOT_IMPLEMENTED_STRING,
        PCIE_REVISION        => PCIE_REVISION,
        PGL0_LANE            => PGL0_LANE,
        PGL1_LANE            => PGL1_LANE,
        PGL2_LANE            => PGL2_LANE,
        PGL3_LANE            => PGL3_LANE,
        PGL4_LANE            => PGL4_LANE,
        PGL5_LANE            => PGL5_LANE,
        PGL6_LANE            => PGL6_LANE,
        PGL7_LANE            => PGL7_LANE,
        PL_AUTO_CONFIG       => PL_AUTO_CONFIG,
        PL_FAST_TRAIN        => PL_FAST_TRAIN_STRING,
        PM_BASE_PTR          => PM_BASE_PTR_STRING,
        PM_CAP_AUXCURRENT    => PM_CAP_AUXCURRENT,
        PM_CAP_D1SUPPORT     => PM_CAP_D1SUPPORT_STRING,
        PM_CAP_D2SUPPORT     => PM_CAP_D2SUPPORT_STRING,
        PM_CAP_DSI           => PM_CAP_DSI_STRING,
        PM_CAP_ID            => PM_CAP_ID_STRING,
        PM_CAP_NEXTPTR       => PM_CAP_NEXTPTR_STRING,
        PM_CAP_ON            => PM_CAP_ON_STRING,
        PM_CAP_PMESUPPORT    => PM_CAP_PMESUPPORT_STRING,
        PM_CAP_PME_CLOCK     => PM_CAP_PME_CLOCK_STRING,
        PM_CAP_RSVD_04       => PM_CAP_RSVD_04,
        PM_CAP_VERSION       => PM_CAP_VERSION,
        PM_CSR_B2B3          => PM_CSR_B2B3_STRING,
        PM_CSR_BPCCEN        => PM_CSR_BPCCEN_STRING,
        PM_CSR_NOSOFTRST     => PM_CSR_NOSOFTRST_STRING,
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
        RECRC_CHK            => RECRC_CHK,
        RECRC_CHK_TRIM       => RECRC_CHK_TRIM_STRING,
        REVISION_ID          => REVISION_ID_STRING,
        ROOT_CAP_CRS_SW_VISIBILITY => ROOT_CAP_CRS_SW_VISIBILITY_STRING,
        SELECT_DLL_IF        => SELECT_DLL_IF_STRING,
        SIM_VERSION          => SIM_VERSION,
        SLOT_CAP_ATT_BUTTON_PRESENT => SLOT_CAP_ATT_BUTTON_PRESENT_STRING,
        SLOT_CAP_ATT_INDICATOR_PRESENT => SLOT_CAP_ATT_INDICATOR_PRESENT_STRING,
        SLOT_CAP_ELEC_INTERLOCK_PRESENT => SLOT_CAP_ELEC_INTERLOCK_PRESENT_STRING,
        SLOT_CAP_HOTPLUG_CAPABLE => SLOT_CAP_HOTPLUG_CAPABLE_STRING,
        SLOT_CAP_HOTPLUG_SURPRISE => SLOT_CAP_HOTPLUG_SURPRISE_STRING,
        SLOT_CAP_MRL_SENSOR_PRESENT => SLOT_CAP_MRL_SENSOR_PRESENT_STRING,
        SLOT_CAP_NO_CMD_COMPLETED_SUPPORT => SLOT_CAP_NO_CMD_COMPLETED_SUPPORT_STRING,
        SLOT_CAP_PHYSICAL_SLOT_NUM => SLOT_CAP_PHYSICAL_SLOT_NUM_STRING,
        SLOT_CAP_POWER_CONTROLLER_PRESENT => SLOT_CAP_POWER_CONTROLLER_PRESENT_STRING,
        SLOT_CAP_POWER_INDICATOR_PRESENT => SLOT_CAP_POWER_INDICATOR_PRESENT_STRING,
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
        SUBSYSTEM_ID         => SUBSYSTEM_ID_STRING,
        SUBSYSTEM_VENDOR_ID  => SUBSYSTEM_VENDOR_ID_STRING,
        TL_RBYPASS           => TL_RBYPASS_STRING,
        TL_RX_RAM_RADDR_LATENCY => TL_RX_RAM_RADDR_LATENCY,
        TL_RX_RAM_RDATA_LATENCY => TL_RX_RAM_RDATA_LATENCY,
        TL_RX_RAM_WRITE_LATENCY => TL_RX_RAM_WRITE_LATENCY,
        TL_TFC_DISABLE       => TL_TFC_DISABLE_STRING,
        TL_TX_CHECKS_DISABLE => TL_TX_CHECKS_DISABLE_STRING,
        TL_TX_RAM_RADDR_LATENCY => TL_TX_RAM_RADDR_LATENCY,
        TL_TX_RAM_RDATA_LATENCY => TL_TX_RAM_RDATA_LATENCY,
        TL_TX_RAM_WRITE_LATENCY => TL_TX_RAM_WRITE_LATENCY,
        UPCONFIG_CAPABLE     => UPCONFIG_CAPABLE_STRING,
        UPSTREAM_FACING      => UPSTREAM_FACING_STRING,
        UR_INV_REQ           => UR_INV_REQ_STRING,
        USER_CLK_FREQ        => USER_CLK_FREQ,
        VC0_CPL_INFINITE     => VC0_CPL_INFINITE_STRING,
        VC0_RX_RAM_LIMIT     => VC0_RX_RAM_LIMIT_STRING,
        VC0_TOTAL_CREDITS_CD => VC0_TOTAL_CREDITS_CD,
        VC0_TOTAL_CREDITS_CH => VC0_TOTAL_CREDITS_CH,
        VC0_TOTAL_CREDITS_NPH => VC0_TOTAL_CREDITS_NPH,
        VC0_TOTAL_CREDITS_PD => VC0_TOTAL_CREDITS_PD,
        VC0_TOTAL_CREDITS_PH => VC0_TOTAL_CREDITS_PH,
        VC0_TX_LASTPACKET    => VC0_TX_LASTPACKET,
        VC_BASE_PTR          => VC_BASE_PTR_STRING,
        VC_CAP_ID            => VC_CAP_ID_STRING,
        VC_CAP_NEXTPTR       => VC_CAP_NEXTPTR_STRING,
        VC_CAP_ON            => VC_CAP_ON_STRING,
        VC_CAP_REJECT_SNOOP_TRANSACTIONS => VC_CAP_REJECT_SNOOP_TRANSACTIONS_STRING,
        VC_CAP_VERSION       => VC_CAP_VERSION_STRING,
        VENDOR_ID            => VENDOR_ID_STRING,
        VSEC_BASE_PTR        => VSEC_BASE_PTR_STRING,
        VSEC_CAP_HDR_ID      => VSEC_CAP_HDR_ID_STRING,
        VSEC_CAP_HDR_LENGTH  => VSEC_CAP_HDR_LENGTH_STRING,
        VSEC_CAP_HDR_REVISION => VSEC_CAP_HDR_REVISION_STRING,
        VSEC_CAP_ID          => VSEC_CAP_ID_STRING,
        VSEC_CAP_IS_LINK_VISIBLE => VSEC_CAP_IS_LINK_VISIBLE_STRING,
        VSEC_CAP_NEXTPTR     => VSEC_CAP_NEXTPTR_STRING,
        VSEC_CAP_ON          => VSEC_CAP_ON_STRING,
        VSEC_CAP_VERSION     => VSEC_CAP_VERSION_STRING
        )
        port map (
        CFGAERECRCCHECKEN    => CFGAERECRCCHECKEN_outdelay,
        CFGAERECRCGENEN      => CFGAERECRCGENEN_outdelay,
        CFGCOMMANDBUSMASTERENABLE => CFGCOMMANDBUSMASTERENABLE_outdelay,
        CFGCOMMANDINTERRUPTDISABLE => CFGCOMMANDINTERRUPTDISABLE_outdelay,
        CFGCOMMANDIOENABLE   => CFGCOMMANDIOENABLE_outdelay,
        CFGCOMMANDMEMENABLE  => CFGCOMMANDMEMENABLE_outdelay,
        CFGCOMMANDSERREN     => CFGCOMMANDSERREN_outdelay,
        CFGDEVCONTROL2CPLTIMEOUTDIS => CFGDEVCONTROL2CPLTIMEOUTDIS_outdelay,
        CFGDEVCONTROL2CPLTIMEOUTVAL => CFGDEVCONTROL2CPLTIMEOUTVAL_outdelay,
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
        CFGDO                => CFGDO_outdelay,
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
        CFGLINKSTATUSBANDWITHSTATUS => CFGLINKSTATUSBANDWITHSTATUS_outdelay,
        CFGLINKSTATUSCURRENTSPEED => CFGLINKSTATUSCURRENTSPEED_outdelay,
        CFGLINKSTATUSDLLACTIVE => CFGLINKSTATUSDLLACTIVE_outdelay,
        CFGLINKSTATUSLINKTRAINING => CFGLINKSTATUSLINKTRAINING_outdelay,
        CFGLINKSTATUSNEGOTIATEDWIDTH => CFGLINKSTATUSNEGOTIATEDWIDTH_outdelay,
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
        CFGRDWRDONEN         => CFGRDWRDONEN_outdelay,
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
        DRPDRDY              => DRPDRDY_outdelay,
        LL2BADDLLPERRN       => LL2BADDLLPERRN_outdelay,
        LL2BADTLPERRN        => LL2BADTLPERRN_outdelay,
        LL2PROTOCOLERRN      => LL2PROTOCOLERRN_outdelay,
        LL2REPLAYROERRN      => LL2REPLAYROERRN_outdelay,
        LL2REPLAYTOERRN      => LL2REPLAYTOERRN_outdelay,
        LL2SUSPENDOKN        => LL2SUSPENDOKN_outdelay,
        LL2TFCINIT1SEQN      => LL2TFCINIT1SEQN_outdelay,
        LL2TFCINIT2SEQN      => LL2TFCINIT2SEQN_outdelay,
        LNKCLKEN             => LNKCLKEN_outdelay,
        MIMRXRADDR           => MIMRXRADDR_outdelay,
        MIMRXRCE             => MIMRXRCE_outdelay,
        MIMRXREN             => MIMRXREN_outdelay,
        MIMRXWADDR           => MIMRXWADDR_outdelay,
        MIMRXWDATA           => MIMRXWDATA_outdelay,
        MIMRXWEN             => MIMRXWEN_outdelay,
        MIMTXRADDR           => MIMTXRADDR_outdelay,
        MIMTXRCE             => MIMTXRCE_outdelay,
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
        PL2LINKUPN           => PL2LINKUPN_outdelay,
        PL2RECEIVERERRN      => PL2RECEIVERERRN_outdelay,
        PL2RECOVERYN         => PL2RECOVERYN_outdelay,
        PL2RXELECIDLE        => PL2RXELECIDLE_outdelay,
        PL2SUSPENDOK         => PL2SUSPENDOK_outdelay,
        PLDBGVEC             => PLDBGVEC_outdelay,
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
        TL2ASPMSUSPENDCREDITCHECKOKN => TL2ASPMSUSPENDCREDITCHECKOKN_outdelay,
        TL2ASPMSUSPENDREQN   => TL2ASPMSUSPENDREQN_outdelay,
        TL2PPMSUSPENDOKN     => TL2PPMSUSPENDOKN_outdelay,
        TRNFCCPLD            => TRNFCCPLD_outdelay,
        TRNFCCPLH            => TRNFCCPLH_outdelay,
        TRNFCNPD             => TRNFCNPD_outdelay,
        TRNFCNPH             => TRNFCNPH_outdelay,
        TRNFCPD              => TRNFCPD_outdelay,
        TRNFCPH              => TRNFCPH_outdelay,
        TRNLNKUPN            => TRNLNKUPN_outdelay,
        TRNRBARHITN          => TRNRBARHITN_outdelay,
        TRNRD                => TRNRD_outdelay,
        TRNRDLLPDATA         => TRNRDLLPDATA_outdelay,
        TRNRDLLPSRCRDYN      => TRNRDLLPSRCRDYN_outdelay,
        TRNRECRCERRN         => TRNRECRCERRN_outdelay,
        TRNREOFN             => TRNREOFN_outdelay,
        TRNRERRFWDN          => TRNRERRFWDN_outdelay,
        TRNRREMN             => TRNRREMN_outdelay,
        TRNRSOFN             => TRNRSOFN_outdelay,
        TRNRSRCDSCN          => TRNRSRCDSCN_outdelay,
        TRNRSRCRDYN          => TRNRSRCRDYN_outdelay,
        TRNTBUFAV            => TRNTBUFAV_outdelay,
        TRNTCFGREQN          => TRNTCFGREQN_outdelay,
        TRNTDLLPDSTRDYN      => TRNTDLLPDSTRDYN_outdelay,
        TRNTDSTRDYN          => TRNTDSTRDYN_outdelay,
        TRNTERRDROPN         => TRNTERRDROPN_outdelay,
        USERRSTN             => USERRSTN_outdelay,
        CFGBYTEENN           => CFGBYTEENN_indelay,
        CFGDI                => CFGDI_indelay,
        CFGDSBUSNUMBER       => CFGDSBUSNUMBER_indelay,
        CFGDSDEVICENUMBER    => CFGDSDEVICENUMBER_indelay,
        CFGDSFUNCTIONNUMBER  => CFGDSFUNCTIONNUMBER_indelay,
        CFGDSN               => CFGDSN_indelay,
        CFGDWADDR            => CFGDWADDR_indelay,
        CFGERRACSN           => CFGERRACSN_indelay,
        CFGERRAERHEADERLOG   => CFGERRAERHEADERLOG_indelay,
        CFGERRCORN           => CFGERRCORN_indelay,
        CFGERRCPLABORTN      => CFGERRCPLABORTN_indelay,
        CFGERRCPLTIMEOUTN    => CFGERRCPLTIMEOUTN_indelay,
        CFGERRCPLUNEXPECTN   => CFGERRCPLUNEXPECTN_indelay,
        CFGERRECRCN          => CFGERRECRCN_indelay,
        CFGERRLOCKEDN        => CFGERRLOCKEDN_indelay,
        CFGERRPOSTEDN        => CFGERRPOSTEDN_indelay,
        CFGERRTLPCPLHEADER   => CFGERRTLPCPLHEADER_indelay,
        CFGERRURN            => CFGERRURN_indelay,
        CFGINTERRUPTASSERTN  => CFGINTERRUPTASSERTN_indelay,
        CFGINTERRUPTDI       => CFGINTERRUPTDI_indelay,
        CFGINTERRUPTN        => CFGINTERRUPTN_indelay,
        CFGPMDIRECTASPML1N   => CFGPMDIRECTASPML1N_indelay,
        CFGPMSENDPMACKN      => CFGPMSENDPMACKN_indelay,
        CFGPMSENDPMETON      => CFGPMSENDPMETON_indelay,
        CFGPMSENDPMNAKN      => CFGPMSENDPMNAKN_indelay,
        CFGPMTURNOFFOKN      => CFGPMTURNOFFOKN_indelay,
        CFGPMWAKEN           => CFGPMWAKEN_indelay,
        CFGPORTNUMBER        => CFGPORTNUMBER_indelay,
        CFGRDENN             => CFGRDENN_indelay,
        CFGTRNPENDINGN       => CFGTRNPENDINGN_indelay,
        CFGWRENN             => CFGWRENN_indelay,
        CFGWRREADONLYN       => CFGWRREADONLYN_indelay,
        CFGWRRW1CASRWN       => CFGWRRW1CASRWN_indelay,
        CMRSTN               => CMRSTN_indelay,
        CMSTICKYRSTN         => CMSTICKYRSTN_indelay,
        DBGMODE              => DBGMODE_indelay,
        DBGSUBMODE           => DBGSUBMODE_indelay,
        DLRSTN               => DLRSTN_indelay,
        DRPCLK               => DRPCLK_indelay,
        DRPDADDR             => DRPDADDR_indelay,
        DRPDEN               => DRPDEN_indelay,
        DRPDI                => DRPDI_indelay,
        DRPDWE               => DRPDWE_indelay,
        FUNCLVLRSTN          => FUNCLVLRSTN_indelay,
        GSR  =>  GSR_dly,
        LL2SENDASREQL1N      => LL2SENDASREQL1N_indelay,
        LL2SENDENTERL1N      => LL2SENDENTERL1N_indelay,
        LL2SENDENTERL23N     => LL2SENDENTERL23N_indelay,
        LL2SUSPENDNOWN       => LL2SUSPENDNOWN_indelay,
        LL2TLPRCVN           => LL2TLPRCVN_indelay,
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
        PLDOWNSTREAMDEEMPHSOURCE => PLDOWNSTREAMDEEMPHSOURCE_indelay,
        PLRSTN               => PLRSTN_indelay,
        PLTRANSMITHOTRST     => PLTRANSMITHOTRST_indelay,
        PLUPSTREAMPREFERDEEMPH => PLUPSTREAMPREFERDEEMPH_indelay,
        SYSRSTN              => SYSRSTN_indelay,
        TL2ASPMSUSPENDCREDITCHECKN => TL2ASPMSUSPENDCREDITCHECKN_indelay,
        TL2PPMSUSPENDREQN    => TL2PPMSUSPENDREQN_indelay,
        TLRSTN               => TLRSTN_indelay,
        TRNFCSEL             => TRNFCSEL_indelay,
        TRNRDSTRDYN          => TRNRDSTRDYN_indelay,
        TRNRNPOKN            => TRNRNPOKN_indelay,
        TRNTCFGGNTN          => TRNTCFGGNTN_indelay,
        TRNTD                => TRNTD_indelay,
        TRNTDLLPDATA         => TRNTDLLPDATA_indelay,
        TRNTDLLPSRCRDYN      => TRNTDLLPSRCRDYN_indelay,
        TRNTECRCGENN         => TRNTECRCGENN_indelay,
        TRNTEOFN             => TRNTEOFN_indelay,
        TRNTERRFWDN          => TRNTERRFWDN_indelay,
        TRNTREMN             => TRNTREMN_indelay,
        TRNTSOFN             => TRNTSOFN_indelay,
        TRNTSRCDSCN          => TRNTSRCDSCN_indelay,
        TRNTSRCRDYN          => TRNTSRCRDYN_indelay,
        TRNTSTRN             => TRNTSTRN_indelay,
        USERCLK              => USERCLK_indelay        
      );

    GSRPROC : process
    begin
     GSR_dly <= '1', '0' after 100 ns;
    wait;
    end process GSRPROC;

    INIPROC : process

    begin
    case AER_CAP_ECRC_CHECK_CAPABLE is
      when FALSE   =>  AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '0';
      when TRUE    =>  AER_CAP_ECRC_CHECK_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : AER_CAP_ECRC_CHECK_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case AER_CAP_ECRC_GEN_CAPABLE is
      when FALSE   =>  AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '0';
      when TRUE    =>  AER_CAP_ECRC_GEN_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : AER_CAP_ECRC_GEN_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case AER_CAP_ON is
      when FALSE   =>  AER_CAP_ON_BINARY <= '0';
      when TRUE    =>  AER_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : AER_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
    case AER_CAP_PERMIT_ROOTERR_UPDATE is
      when FALSE   =>  AER_CAP_PERMIT_ROOTERR_UPDATE_BINARY <= '0';
      when TRUE    =>  AER_CAP_PERMIT_ROOTERR_UPDATE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : AER_CAP_PERMIT_ROOTERR_UPDATE is neither TRUE nor FALSE." severity error;
    end case;
    case ALLOW_X8_GEN2 is
      when FALSE   =>  ALLOW_X8_GEN2_BINARY <= '0';
      when TRUE    =>  ALLOW_X8_GEN2_BINARY <= '1';
      when others  =>  assert FALSE report "Error : ALLOW_X8_GEN2 is neither TRUE nor FALSE." severity error;
    end case;
    case CMD_INTX_IMPLEMENTED is
      when FALSE   =>  CMD_INTX_IMPLEMENTED_BINARY <= '0';
      when TRUE    =>  CMD_INTX_IMPLEMENTED_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CMD_INTX_IMPLEMENTED is neither TRUE nor FALSE." severity error;
    end case;
    case CPL_TIMEOUT_DISABLE_SUPPORTED is
      when FALSE   =>  CPL_TIMEOUT_DISABLE_SUPPORTED_BINARY <= '0';
      when TRUE    =>  CPL_TIMEOUT_DISABLE_SUPPORTED_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CPL_TIMEOUT_DISABLE_SUPPORTED is neither TRUE nor FALSE." severity error;
    end case;
    case DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE is
      when FALSE   =>  DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE_BINARY <= '0';
      when TRUE    =>  DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CAP_ENABLE_SLOT_PWR_LIMIT_SCALE is neither TRUE nor FALSE." severity error;
    end case;
    case DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE is
      when FALSE   =>  DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE_BINARY <= '0';
      when TRUE    =>  DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CAP_ENABLE_SLOT_PWR_LIMIT_VALUE is neither TRUE nor FALSE." severity error;
    end case;
    case DEV_CAP_EXT_TAG_SUPPORTED is
      when FALSE   =>  DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '0';
      when TRUE    =>  DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CAP_EXT_TAG_SUPPORTED is neither TRUE nor FALSE." severity error;
    end case;
    case DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE is
      when FALSE   =>  DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY <= '0';
      when TRUE    =>  DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case DEV_CAP_ROLE_BASED_ERROR is
      when FALSE   =>  DEV_CAP_ROLE_BASED_ERROR_BINARY <= '0';
      when TRUE    =>  DEV_CAP_ROLE_BASED_ERROR_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CAP_ROLE_BASED_ERROR is neither TRUE nor FALSE." severity error;
    end case;
    case DEV_CONTROL_AUX_POWER_SUPPORTED is
      when FALSE   =>  DEV_CONTROL_AUX_POWER_SUPPORTED_BINARY <= '0';
      when TRUE    =>  DEV_CONTROL_AUX_POWER_SUPPORTED_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CONTROL_AUX_POWER_SUPPORTED is neither TRUE nor FALSE." severity error;
    end case;
    case DISABLE_ASPM_L1_TIMER is
      when FALSE   =>  DISABLE_ASPM_L1_TIMER_BINARY <= '0';
      when TRUE    =>  DISABLE_ASPM_L1_TIMER_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DISABLE_ASPM_L1_TIMER is neither TRUE nor FALSE." severity error;
    end case;
    case DISABLE_BAR_FILTERING is
      when FALSE   =>  DISABLE_BAR_FILTERING_BINARY <= '0';
      when TRUE    =>  DISABLE_BAR_FILTERING_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DISABLE_BAR_FILTERING is neither TRUE nor FALSE." severity error;
    end case;
    case DISABLE_ID_CHECK is
      when FALSE   =>  DISABLE_ID_CHECK_BINARY <= '0';
      when TRUE    =>  DISABLE_ID_CHECK_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DISABLE_ID_CHECK is neither TRUE nor FALSE." severity error;
    end case;
    case DISABLE_LANE_REVERSAL is
      when FALSE   =>  DISABLE_LANE_REVERSAL_BINARY <= '0';
      when TRUE    =>  DISABLE_LANE_REVERSAL_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DISABLE_LANE_REVERSAL is neither TRUE nor FALSE." severity error;
    end case;
    case DISABLE_RX_TC_FILTER is
      when FALSE   =>  DISABLE_RX_TC_FILTER_BINARY <= '0';
      when TRUE    =>  DISABLE_RX_TC_FILTER_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DISABLE_RX_TC_FILTER is neither TRUE nor FALSE." severity error;
    end case;
    case DISABLE_SCRAMBLING is
      when FALSE   =>  DISABLE_SCRAMBLING_BINARY <= '0';
      when TRUE    =>  DISABLE_SCRAMBLING_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DISABLE_SCRAMBLING is neither TRUE nor FALSE." severity error;
    end case;
    case DSN_CAP_ON is
      when FALSE   =>  DSN_CAP_ON_BINARY <= '0';
      when TRUE    =>  DSN_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DSN_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
    case ENABLE_RX_TD_ECRC_TRIM is
      when FALSE   =>  ENABLE_RX_TD_ECRC_TRIM_BINARY <= '0';
      when TRUE    =>  ENABLE_RX_TD_ECRC_TRIM_BINARY <= '1';
      when others  =>  assert FALSE report "Error : ENABLE_RX_TD_ECRC_TRIM is neither TRUE nor FALSE." severity error;
    end case;
    case ENTER_RVRY_EI_L0 is
      when FALSE   =>  ENTER_RVRY_EI_L0_BINARY <= '0';
      when TRUE    =>  ENTER_RVRY_EI_L0_BINARY <= '1';
      when others  =>  assert FALSE report "Error : ENTER_RVRY_EI_L0 is neither TRUE nor FALSE." severity error;
    end case;
    case EXIT_LOOPBACK_ON_EI is
      when FALSE   =>  EXIT_LOOPBACK_ON_EI_BINARY <= '0';
      when TRUE    =>  EXIT_LOOPBACK_ON_EI_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EXIT_LOOPBACK_ON_EI is neither TRUE nor FALSE." severity error;
    end case;
    case IS_SWITCH is
      when FALSE   =>  IS_SWITCH_BINARY <= '0';
      when TRUE    =>  IS_SWITCH_BINARY <= '1';
      when others  =>  assert FALSE report "Error : IS_SWITCH is neither TRUE nor FALSE." severity error;
    end case;
    case LINK_CAP_CLOCK_POWER_MANAGEMENT is
      when FALSE   =>  LINK_CAP_CLOCK_POWER_MANAGEMENT_BINARY <= '0';
      when TRUE    =>  LINK_CAP_CLOCK_POWER_MANAGEMENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CAP_CLOCK_POWER_MANAGEMENT is neither TRUE nor FALSE." severity error;
    end case;
    case LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP is
      when FALSE   =>  LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP_BINARY <= '0';
      when TRUE    =>  LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP is neither TRUE nor FALSE." severity error;
    end case;
    case LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP is
      when FALSE   =>  LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP_BINARY <= '0';
      when TRUE    =>  LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CAP_LINK_BANDWIDTH_NOTIFICATION_CAP is neither TRUE nor FALSE." severity error;
    end case;
    case LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE is
      when FALSE   =>  LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_BINARY <= '0';
      when TRUE    =>  LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CAP_SURPRISE_DOWN_ERROR_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case LINK_CONTROL_RCB is
      when  0   =>  LINK_CONTROL_RCB_BINARY <= '0';
      when  1   =>  LINK_CONTROL_RCB_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CONTROL_RCB is not in range 0 .. 1." severity error;
    end case;
    case LINK_CTRL2_DEEMPHASIS is
      when FALSE   =>  LINK_CTRL2_DEEMPHASIS_BINARY <= '0';
      when TRUE    =>  LINK_CTRL2_DEEMPHASIS_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CTRL2_DEEMPHASIS is neither TRUE nor FALSE." severity error;
    end case;
    case LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE is
      when FALSE   =>  LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_BINARY <= '0';
      when TRUE    =>  LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_CTRL2_HW_AUTONOMOUS_SPEED_DISABLE is neither TRUE nor FALSE." severity error;
    end case;
    case LINK_STATUS_SLOT_CLOCK_CONFIG is
      when FALSE   =>  LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY <= '0';
      when TRUE    =>  LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LINK_STATUS_SLOT_CLOCK_CONFIG is neither TRUE nor FALSE." severity error;
    end case;
    case LL_ACK_TIMEOUT_EN is
      when FALSE   =>  LL_ACK_TIMEOUT_EN_BINARY <= '0';
      when TRUE    =>  LL_ACK_TIMEOUT_EN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LL_ACK_TIMEOUT_EN is neither TRUE nor FALSE." severity error;
    end case;
    case LL_REPLAY_TIMEOUT_EN is
      when FALSE   =>  LL_REPLAY_TIMEOUT_EN_BINARY <= '0';
      when TRUE    =>  LL_REPLAY_TIMEOUT_EN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : LL_REPLAY_TIMEOUT_EN is neither TRUE nor FALSE." severity error;
    end case;
    case MSIX_CAP_ON is
      when FALSE   =>  MSIX_CAP_ON_BINARY <= '0';
      when TRUE    =>  MSIX_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MSIX_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
    case MSI_CAP_64_BIT_ADDR_CAPABLE is
      when FALSE   =>  MSI_CAP_64_BIT_ADDR_CAPABLE_BINARY <= '0';
      when TRUE    =>  MSI_CAP_64_BIT_ADDR_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MSI_CAP_64_BIT_ADDR_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case MSI_CAP_MULTIMSG_EXTENSION is
      when  0   =>  MSI_CAP_MULTIMSG_EXTENSION_BINARY <= '0';
      when  1   =>  MSI_CAP_MULTIMSG_EXTENSION_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MSI_CAP_MULTIMSG_EXTENSION is not in range 0 .. 1." severity error;
    end case;
    case MSI_CAP_ON is
      when FALSE   =>  MSI_CAP_ON_BINARY <= '0';
      when TRUE    =>  MSI_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MSI_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
    case MSI_CAP_PER_VECTOR_MASKING_CAPABLE is
      when FALSE   =>  MSI_CAP_PER_VECTOR_MASKING_CAPABLE_BINARY <= '0';
      when TRUE    =>  MSI_CAP_PER_VECTOR_MASKING_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MSI_CAP_PER_VECTOR_MASKING_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case PCIE_CAP_ON is
      when FALSE   =>  PCIE_CAP_ON_BINARY <= '0';
      when TRUE    =>  PCIE_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PCIE_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
    case PCIE_CAP_SLOT_IMPLEMENTED is
      when FALSE   =>  PCIE_CAP_SLOT_IMPLEMENTED_BINARY <= '0';
      when TRUE    =>  PCIE_CAP_SLOT_IMPLEMENTED_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PCIE_CAP_SLOT_IMPLEMENTED is neither TRUE nor FALSE." severity error;
    end case;
    case PL_FAST_TRAIN is
      when FALSE   =>  PL_FAST_TRAIN_BINARY <= '0';
      when TRUE    =>  PL_FAST_TRAIN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PL_FAST_TRAIN is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CAP_D1SUPPORT is
      when FALSE   =>  PM_CAP_D1SUPPORT_BINARY <= '0';
      when TRUE    =>  PM_CAP_D1SUPPORT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_D1SUPPORT is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CAP_D2SUPPORT is
      when FALSE   =>  PM_CAP_D2SUPPORT_BINARY <= '0';
      when TRUE    =>  PM_CAP_D2SUPPORT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_D2SUPPORT is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CAP_DSI is
      when FALSE   =>  PM_CAP_DSI_BINARY <= '0';
      when TRUE    =>  PM_CAP_DSI_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_DSI is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CAP_ON is
      when FALSE   =>  PM_CAP_ON_BINARY <= '0';
      when TRUE    =>  PM_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CAP_PME_CLOCK is
      when FALSE   =>  PM_CAP_PME_CLOCK_BINARY <= '0';
      when TRUE    =>  PM_CAP_PME_CLOCK_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_PME_CLOCK is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CAP_RSVD_04 is
      when  0   =>  PM_CAP_RSVD_04_BINARY <= '0';
      when  1   =>  PM_CAP_RSVD_04_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_RSVD_04 is not in range 0 .. 1." severity error;
    end case;
    case PM_CSR_B2B3 is
      when FALSE   =>  PM_CSR_B2B3_BINARY <= '0';
      when TRUE    =>  PM_CSR_B2B3_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CSR_B2B3 is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CSR_BPCCEN is
      when FALSE   =>  PM_CSR_BPCCEN_BINARY <= '0';
      when TRUE    =>  PM_CSR_BPCCEN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CSR_BPCCEN is neither TRUE nor FALSE." severity error;
    end case;
    case PM_CSR_NOSOFTRST is
      when FALSE   =>  PM_CSR_NOSOFTRST_BINARY <= '0';
      when TRUE    =>  PM_CSR_NOSOFTRST_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CSR_NOSOFTRST is neither TRUE nor FALSE." severity error;
    end case;
    case RECRC_CHK_TRIM is
      when FALSE   =>  RECRC_CHK_TRIM_BINARY <= '0';
      when TRUE    =>  RECRC_CHK_TRIM_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RECRC_CHK_TRIM is neither TRUE nor FALSE." severity error;
    end case;
    case ROOT_CAP_CRS_SW_VISIBILITY is
      when FALSE   =>  ROOT_CAP_CRS_SW_VISIBILITY_BINARY <= '0';
      when TRUE    =>  ROOT_CAP_CRS_SW_VISIBILITY_BINARY <= '1';
      when others  =>  assert FALSE report "Error : ROOT_CAP_CRS_SW_VISIBILITY is neither TRUE nor FALSE." severity error;
    end case;
    case SELECT_DLL_IF is
      when FALSE   =>  SELECT_DLL_IF_BINARY <= '0';
      when TRUE    =>  SELECT_DLL_IF_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SELECT_DLL_IF is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_ATT_BUTTON_PRESENT is
      when FALSE   =>  SLOT_CAP_ATT_BUTTON_PRESENT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_ATT_BUTTON_PRESENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_ATT_BUTTON_PRESENT is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_ATT_INDICATOR_PRESENT is
      when FALSE   =>  SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_ATT_INDICATOR_PRESENT is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_ELEC_INTERLOCK_PRESENT is
      when FALSE   =>  SLOT_CAP_ELEC_INTERLOCK_PRESENT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_ELEC_INTERLOCK_PRESENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_ELEC_INTERLOCK_PRESENT is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_HOTPLUG_CAPABLE is
      when FALSE   =>  SLOT_CAP_HOTPLUG_CAPABLE_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_HOTPLUG_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_HOTPLUG_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_HOTPLUG_SURPRISE is
      when FALSE   =>  SLOT_CAP_HOTPLUG_SURPRISE_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_HOTPLUG_SURPRISE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_HOTPLUG_SURPRISE is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_MRL_SENSOR_PRESENT is
      when FALSE   =>  SLOT_CAP_MRL_SENSOR_PRESENT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_MRL_SENSOR_PRESENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_MRL_SENSOR_PRESENT is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_NO_CMD_COMPLETED_SUPPORT is
      when FALSE   =>  SLOT_CAP_NO_CMD_COMPLETED_SUPPORT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_NO_CMD_COMPLETED_SUPPORT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_NO_CMD_COMPLETED_SUPPORT is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_POWER_CONTROLLER_PRESENT is
      when FALSE   =>  SLOT_CAP_POWER_CONTROLLER_PRESENT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_POWER_CONTROLLER_PRESENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_POWER_CONTROLLER_PRESENT is neither TRUE nor FALSE." severity error;
    end case;
    case SLOT_CAP_POWER_INDICATOR_PRESENT is
      when FALSE   =>  SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_POWER_INDICATOR_PRESENT is neither TRUE nor FALSE." severity error;
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
    case TL_RBYPASS is
      when FALSE   =>  TL_RBYPASS_BINARY <= '0';
      when TRUE    =>  TL_RBYPASS_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TL_RBYPASS is neither TRUE nor FALSE." severity error;
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
    case TL_TFC_DISABLE is
      when FALSE   =>  TL_TFC_DISABLE_BINARY <= '0';
      when TRUE    =>  TL_TFC_DISABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TL_TFC_DISABLE is neither TRUE nor FALSE." severity error;
    end case;
    case TL_TX_CHECKS_DISABLE is
      when FALSE   =>  TL_TX_CHECKS_DISABLE_BINARY <= '0';
      when TRUE    =>  TL_TX_CHECKS_DISABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TL_TX_CHECKS_DISABLE is neither TRUE nor FALSE." severity error;
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
    case UPCONFIG_CAPABLE is
      when FALSE   =>  UPCONFIG_CAPABLE_BINARY <= '0';
      when TRUE    =>  UPCONFIG_CAPABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : UPCONFIG_CAPABLE is neither TRUE nor FALSE." severity error;
    end case;
    case UPSTREAM_FACING is
      when FALSE   =>  UPSTREAM_FACING_BINARY <= '0';
      when TRUE    =>  UPSTREAM_FACING_BINARY <= '1';
      when others  =>  assert FALSE report "Error : UPSTREAM_FACING is neither TRUE nor FALSE." severity error;
    end case;
    case UR_INV_REQ is
      when FALSE   =>  UR_INV_REQ_BINARY <= '0';
      when TRUE    =>  UR_INV_REQ_BINARY <= '1';
      when others  =>  assert FALSE report "Error : UR_INV_REQ is neither TRUE nor FALSE." severity error;
    end case;
    case VC0_CPL_INFINITE is
      when FALSE   =>  VC0_CPL_INFINITE_BINARY <= '0';
      when TRUE    =>  VC0_CPL_INFINITE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : VC0_CPL_INFINITE is neither TRUE nor FALSE." severity error;
    end case;
    case VC_CAP_ON is
      when FALSE   =>  VC_CAP_ON_BINARY <= '0';
      when TRUE    =>  VC_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : VC_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
    case VC_CAP_REJECT_SNOOP_TRANSACTIONS is
      when FALSE   =>  VC_CAP_REJECT_SNOOP_TRANSACTIONS_BINARY <= '0';
      when TRUE    =>  VC_CAP_REJECT_SNOOP_TRANSACTIONS_BINARY <= '1';
      when others  =>  assert FALSE report "Error : VC_CAP_REJECT_SNOOP_TRANSACTIONS is neither TRUE nor FALSE." severity error;
    end case;
    case VSEC_CAP_IS_LINK_VISIBLE is
      when FALSE   =>  VSEC_CAP_IS_LINK_VISIBLE_BINARY <= '0';
      when TRUE    =>  VSEC_CAP_IS_LINK_VISIBLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : VSEC_CAP_IS_LINK_VISIBLE is neither TRUE nor FALSE." severity error;
    end case;
    case VSEC_CAP_ON is
      when FALSE   =>  VSEC_CAP_ON_BINARY <= '0';
      when TRUE    =>  VSEC_CAP_ON_BINARY <= '1';
      when others  =>  assert FALSE report "Error : VSEC_CAP_ON is neither TRUE nor FALSE." severity error;
    end case;
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
    if ((LINK_CAP_RSVD_23_22 >= 0) and (LINK_CAP_RSVD_23_22 <= 3)) then
      LINK_CAP_RSVD_23_22_BINARY <= CONV_STD_LOGIC_VECTOR(LINK_CAP_RSVD_23_22, 2);
    else
      assert FALSE report "Error : LINK_CAP_RSVD_23_22 is not in range 0 .. 3." severity error;
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
    if ((PGL0_LANE >= 0) and (PGL0_LANE <= 7)) then
      PGL0_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL0_LANE, 3);
    else
      assert FALSE report "Error : PGL0_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PGL1_LANE >= 0) and (PGL1_LANE <= 7)) then
      PGL1_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL1_LANE, 3);
    else
      assert FALSE report "Error : PGL1_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PGL2_LANE >= 0) and (PGL2_LANE <= 7)) then
      PGL2_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL2_LANE, 3);
    else
      assert FALSE report "Error : PGL2_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PGL3_LANE >= 0) and (PGL3_LANE <= 7)) then
      PGL3_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL3_LANE, 3);
    else
      assert FALSE report "Error : PGL3_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PGL4_LANE >= 0) and (PGL4_LANE <= 7)) then
      PGL4_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL4_LANE, 3);
    else
      assert FALSE report "Error : PGL4_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PGL5_LANE >= 0) and (PGL5_LANE <= 7)) then
      PGL5_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL5_LANE, 3);
    else
      assert FALSE report "Error : PGL5_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PGL6_LANE >= 0) and (PGL6_LANE <= 7)) then
      PGL6_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL6_LANE, 3);
    else
      assert FALSE report "Error : PGL6_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PGL7_LANE >= 0) and (PGL7_LANE <= 7)) then
      PGL7_LANE_BINARY <= CONV_STD_LOGIC_VECTOR(PGL7_LANE, 3);
    else
      assert FALSE report "Error : PGL7_LANE is not in range 0 .. 7." severity error;
    end if;
    if ((PL_AUTO_CONFIG >= 0) and (PL_AUTO_CONFIG <= 7)) then
      PL_AUTO_CONFIG_BINARY <= CONV_STD_LOGIC_VECTOR(PL_AUTO_CONFIG, 3);
    else
      assert FALSE report "Error : PL_AUTO_CONFIG is not in range 0 .. 7." severity error;
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
    CFGCOMMANDBUSMASTERENABLE <= CFGCOMMANDBUSMASTERENABLE_out;
    CFGCOMMANDINTERRUPTDISABLE <= CFGCOMMANDINTERRUPTDISABLE_out;
    CFGCOMMANDIOENABLE <= CFGCOMMANDIOENABLE_out;
    CFGCOMMANDMEMENABLE <= CFGCOMMANDMEMENABLE_out;
    CFGCOMMANDSERREN <= CFGCOMMANDSERREN_out;
    CFGDEVCONTROL2CPLTIMEOUTDIS <= CFGDEVCONTROL2CPLTIMEOUTDIS_out;
    CFGDEVCONTROL2CPLTIMEOUTVAL <= CFGDEVCONTROL2CPLTIMEOUTVAL_out;
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
    CFGDO <= CFGDO_out;
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
    CFGLINKSTATUSBANDWITHSTATUS <= CFGLINKSTATUSBANDWITHSTATUS_out;
    CFGLINKSTATUSCURRENTSPEED <= CFGLINKSTATUSCURRENTSPEED_out;
    CFGLINKSTATUSDLLACTIVE <= CFGLINKSTATUSDLLACTIVE_out;
    CFGLINKSTATUSLINKTRAINING <= CFGLINKSTATUSLINKTRAINING_out;
    CFGLINKSTATUSNEGOTIATEDWIDTH <= CFGLINKSTATUSNEGOTIATEDWIDTH_out;
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
    CFGRDWRDONEN <= CFGRDWRDONEN_out;
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
    DRPDRDY <= DRPDRDY_out;
    LL2BADDLLPERRN <= LL2BADDLLPERRN_out;
    LL2BADTLPERRN <= LL2BADTLPERRN_out;
    LL2PROTOCOLERRN <= LL2PROTOCOLERRN_out;
    LL2REPLAYROERRN <= LL2REPLAYROERRN_out;
    LL2REPLAYTOERRN <= LL2REPLAYTOERRN_out;
    LL2SUSPENDOKN <= LL2SUSPENDOKN_out;
    LL2TFCINIT1SEQN <= LL2TFCINIT1SEQN_out;
    LL2TFCINIT2SEQN <= LL2TFCINIT2SEQN_out;
    LNKCLKEN <= LNKCLKEN_out;
    MIMRXRADDR <= MIMRXRADDR_out;
    MIMRXRCE <= MIMRXRCE_out;
    MIMRXREN <= MIMRXREN_out;
    MIMRXWADDR <= MIMRXWADDR_out;
    MIMRXWDATA <= MIMRXWDATA_out;
    MIMRXWEN <= MIMRXWEN_out;
    MIMTXRADDR <= MIMTXRADDR_out;
    MIMTXRCE <= MIMTXRCE_out;
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
    PL2LINKUPN <= PL2LINKUPN_out;
    PL2RECEIVERERRN <= PL2RECEIVERERRN_out;
    PL2RECOVERYN <= PL2RECOVERYN_out;
    PL2RXELECIDLE <= PL2RXELECIDLE_out;
    PL2SUSPENDOK <= PL2SUSPENDOK_out;
    PLDBGVEC <= PLDBGVEC_out;
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
    TL2ASPMSUSPENDCREDITCHECKOKN <= TL2ASPMSUSPENDCREDITCHECKOKN_out;
    TL2ASPMSUSPENDREQN <= TL2ASPMSUSPENDREQN_out;
    TL2PPMSUSPENDOKN <= TL2PPMSUSPENDOKN_out;
    TRNFCCPLD <= TRNFCCPLD_out;
    TRNFCCPLH <= TRNFCCPLH_out;
    TRNFCNPD <= TRNFCNPD_out;
    TRNFCNPH <= TRNFCNPH_out;
    TRNFCPD <= TRNFCPD_out;
    TRNFCPH <= TRNFCPH_out;
    TRNLNKUPN <= TRNLNKUPN_out;
    TRNRBARHITN <= TRNRBARHITN_out;
    TRNRD <= TRNRD_out;
    TRNRDLLPDATA <= TRNRDLLPDATA_out;
    TRNRDLLPSRCRDYN <= TRNRDLLPSRCRDYN_out;
    TRNRECRCERRN <= TRNRECRCERRN_out;
    TRNREOFN <= TRNREOFN_out;
    TRNRERRFWDN <= TRNRERRFWDN_out;
    TRNRREMN <= TRNRREMN_out;
    TRNRSOFN <= TRNRSOFN_out;
    TRNRSRCDSCN <= TRNRSRCDSCN_out;
    TRNRSRCRDYN <= TRNRSRCRDYN_out;
    TRNTBUFAV <= TRNTBUFAV_out;
    TRNTCFGREQN <= TRNTCFGREQN_out;
    TRNTDLLPDSTRDYN <= TRNTDLLPDSTRDYN_out;
    TRNTDSTRDYN <= TRNTDSTRDYN_out;
    TRNTERRDROPN <= TRNTERRDROPN_out;
    USERRSTN <= USERRSTN_out;
  end PCIE_2_0_V;
