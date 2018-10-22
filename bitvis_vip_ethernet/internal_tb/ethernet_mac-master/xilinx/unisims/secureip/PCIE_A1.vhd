-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/SMODEL/PCIE_A1.vhd,v 1.10 2010/02/03 23:43:26 robh Exp $
-------------------------------------------------------
--  Copyright (c) 2008 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : PCI Express Secure IP Functional Wrapper
--  /   /                      
-- /___/   /\      Filename    : PCIE_A1.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
-- Revision:
--       1.0:  08/21/08 - Initial version.
--       1.1:  11/24/08 - Updates to include secureip
--       1.2:  12/01/08 - parameter conversion width mismatch
--       1.3:  02/03/10:  525925 add skew and period checks.

-- End Revision
-------------------------------------------------------

----- CELL PCIE_A1 -----

library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.all;

library secureip;
use secureip.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity PCIE_A1 is
    generic (
      BAR0 : bit_vector := X"00000000";
      BAR1 : bit_vector := X"00000000";
      BAR2 : bit_vector := X"00000000";
      BAR3 : bit_vector := X"00000000";
      BAR4 : bit_vector := X"00000000";
      BAR5 : bit_vector := X"00000000";
      CARDBUS_CIS_POINTER : bit_vector := X"00000000";
      CLASS_CODE : bit_vector := X"000000";
      DEV_CAP_ENDPOINT_L0S_LATENCY : integer := 7;
      DEV_CAP_ENDPOINT_L1_LATENCY : integer := 7;
      DEV_CAP_EXT_TAG_SUPPORTED : boolean := FALSE;
      DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer := 2;
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer := 0;
      DEV_CAP_ROLE_BASED_ERROR : boolean := TRUE;
      DISABLE_BAR_FILTERING : boolean := FALSE;
      DISABLE_ID_CHECK : boolean := FALSE;
      DISABLE_SCRAMBLING : boolean := FALSE;
      ENABLE_RX_TD_ECRC_TRIM : boolean := FALSE;
      EXPANSION_ROM : bit_vector := X"000000";
      FAST_TRAIN : boolean := FALSE;
      GTP_SEL : integer := 0;
      LINK_CAP_ASPM_SUPPORT : integer := 1;
      LINK_CAP_L0S_EXIT_LATENCY : integer := 7;
      LINK_CAP_L1_EXIT_LATENCY : integer := 7;
      LINK_STATUS_SLOT_CLOCK_CONFIG : boolean := FALSE;
      LL_ACK_TIMEOUT : bit_vector := X"0204";
      LL_ACK_TIMEOUT_EN : boolean := FALSE;
      LL_REPLAY_TIMEOUT : bit_vector := X"060D";
      LL_REPLAY_TIMEOUT_EN : boolean := FALSE;
      MSI_CAP_MULTIMSGCAP : integer := 0;
      MSI_CAP_MULTIMSG_EXTENSION : integer := 0;
      PCIE_CAP_CAPABILITY_VERSION : bit_vector := X"1";
      PCIE_CAP_DEVICE_PORT_TYPE : bit_vector := X"0";
      PCIE_CAP_INT_MSG_NUM : bit_vector := "00000";
      PCIE_CAP_SLOT_IMPLEMENTED : boolean := FALSE;
      PCIE_GENERIC : bit_vector := X"000";
      PLM_AUTO_CONFIG : boolean := FALSE;
      PM_CAP_AUXCURRENT : integer := 0;
      PM_CAP_D1SUPPORT : boolean := TRUE;
      PM_CAP_D2SUPPORT : boolean := TRUE;
      PM_CAP_DSI : boolean := FALSE;
      PM_CAP_PMESUPPORT : bit_vector := "01111";
      PM_CAP_PME_CLOCK : boolean := FALSE;
      PM_CAP_VERSION : integer := 3;
      PM_DATA0 : bit_vector := X"1E";
      PM_DATA1 : bit_vector := X"1E";
      PM_DATA2 : bit_vector := X"1E";
      PM_DATA3 : bit_vector := X"1E";
      PM_DATA4 : bit_vector := X"1E";
      PM_DATA5 : bit_vector := X"1E";
      PM_DATA6 : bit_vector := X"1E";
      PM_DATA7 : bit_vector := X"1E";
      PM_DATA_SCALE0 : bit_vector := "01";
      PM_DATA_SCALE1 : bit_vector := "01";
      PM_DATA_SCALE2 : bit_vector := "01";
      PM_DATA_SCALE3 : bit_vector := "01";
      PM_DATA_SCALE4 : bit_vector := "01";
      PM_DATA_SCALE5 : bit_vector := "01";
      PM_DATA_SCALE6 : bit_vector := "01";
      PM_DATA_SCALE7 : bit_vector := "01";
      SIM_VERSION : string := "1.0";
      SLOT_CAP_ATT_BUTTON_PRESENT : boolean := FALSE;
      SLOT_CAP_ATT_INDICATOR_PRESENT : boolean := FALSE;
      SLOT_CAP_POWER_INDICATOR_PRESENT : boolean := FALSE;
      TL_RX_RAM_RADDR_LATENCY : integer := 1;
      TL_RX_RAM_RDATA_LATENCY : integer := 2;
      TL_RX_RAM_WRITE_LATENCY : integer := 0;
      TL_TFC_DISABLE : boolean := FALSE;
      TL_TX_CHECKS_DISABLE : boolean := FALSE;
      TL_TX_RAM_RADDR_LATENCY : integer := 0;
      TL_TX_RAM_RDATA_LATENCY : integer := 2;
      USR_CFG : boolean := FALSE;
      USR_EXT_CFG : boolean := FALSE;
      VC0_CPL_INFINITE : boolean := TRUE;
      VC0_RX_RAM_LIMIT : bit_vector := X"01E";
      VC0_TOTAL_CREDITS_CD : integer := 104;
      VC0_TOTAL_CREDITS_CH : integer := 36;
      VC0_TOTAL_CREDITS_NPH : integer := 8;
      VC0_TOTAL_CREDITS_PD : integer := 288;
      VC0_TOTAL_CREDITS_PH : integer := 32;
      VC0_TX_LASTPACKET : integer := 31
    );

    port (
      CFGBUSNUMBER         : out std_logic_vector(7 downto 0);
      CFGCOMMANDBUSMASTERENABLE : out std_ulogic;
      CFGCOMMANDINTERRUPTDISABLE : out std_ulogic;
      CFGCOMMANDIOENABLE   : out std_ulogic;
      CFGCOMMANDMEMENABLE  : out std_ulogic;
      CFGCOMMANDSERREN     : out std_ulogic;
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
      CFGDEVICENUMBER      : out std_logic_vector(4 downto 0);
      CFGDEVSTATUSCORRERRDETECTED : out std_ulogic;
      CFGDEVSTATUSFATALERRDETECTED : out std_ulogic;
      CFGDEVSTATUSNONFATALERRDETECTED : out std_ulogic;
      CFGDEVSTATUSURDETECTED : out std_ulogic;
      CFGDO                : out std_logic_vector(31 downto 0);
      CFGERRCPLRDYN        : out std_ulogic;
      CFGFUNCTIONNUMBER    : out std_logic_vector(2 downto 0);
      CFGINTERRUPTDO       : out std_logic_vector(7 downto 0);
      CFGINTERRUPTMMENABLE : out std_logic_vector(2 downto 0);
      CFGINTERRUPTMSIENABLE : out std_ulogic;
      CFGINTERRUPTRDYN     : out std_ulogic;
      CFGLINKCONTOLRCB     : out std_ulogic;
      CFGLINKCONTROLASPMCONTROL : out std_logic_vector(1 downto 0);
      CFGLINKCONTROLCOMMONCLOCK : out std_ulogic;
      CFGLINKCONTROLEXTENDEDSYNC : out std_ulogic;
      CFGLTSSMSTATE        : out std_logic_vector(4 downto 0);
      CFGPCIELINKSTATEN    : out std_logic_vector(2 downto 0);
      CFGRDWRDONEN         : out std_ulogic;
      CFGTOTURNOFFN        : out std_ulogic;
      DBGBADDLLPSTATUS     : out std_ulogic;
      DBGBADTLPLCRC        : out std_ulogic;
      DBGBADTLPSEQNUM      : out std_ulogic;
      DBGBADTLPSTATUS      : out std_ulogic;
      DBGDLPROTOCOLSTATUS  : out std_ulogic;
      DBGFCPROTOCOLERRSTATUS : out std_ulogic;
      DBGMLFRMDLENGTH      : out std_ulogic;
      DBGMLFRMDMPS         : out std_ulogic;
      DBGMLFRMDTCVC        : out std_ulogic;
      DBGMLFRMDTLPSTATUS   : out std_ulogic;
      DBGMLFRMDUNRECTYPE   : out std_ulogic;
      DBGPOISTLPSTATUS     : out std_ulogic;
      DBGRCVROVERFLOWSTATUS : out std_ulogic;
      DBGREGDETECTEDCORRECTABLE : out std_ulogic;
      DBGREGDETECTEDFATAL  : out std_ulogic;
      DBGREGDETECTEDNONFATAL : out std_ulogic;
      DBGREGDETECTEDUNSUPPORTED : out std_ulogic;
      DBGRPLYROLLOVERSTATUS : out std_ulogic;
      DBGRPLYTIMEOUTSTATUS : out std_ulogic;
      DBGURNOBARHIT        : out std_ulogic;
      DBGURPOISCFGWR       : out std_ulogic;
      DBGURSTATUS          : out std_ulogic;
      DBGURUNSUPMSG        : out std_ulogic;
      MIMRXRADDR           : out std_logic_vector(11 downto 0);
      MIMRXREN             : out std_ulogic;
      MIMRXWADDR           : out std_logic_vector(11 downto 0);
      MIMRXWDATA           : out std_logic_vector(34 downto 0);
      MIMRXWEN             : out std_ulogic;
      MIMTXRADDR           : out std_logic_vector(11 downto 0);
      MIMTXREN             : out std_ulogic;
      MIMTXWADDR           : out std_logic_vector(11 downto 0);
      MIMTXWDATA           : out std_logic_vector(35 downto 0);
      MIMTXWEN             : out std_ulogic;
      PIPEGTPOWERDOWNA     : out std_logic_vector(1 downto 0);
      PIPEGTPOWERDOWNB     : out std_logic_vector(1 downto 0);
      PIPEGTTXELECIDLEA    : out std_ulogic;
      PIPEGTTXELECIDLEB    : out std_ulogic;
      PIPERXPOLARITYA      : out std_ulogic;
      PIPERXPOLARITYB      : out std_ulogic;
      PIPERXRESETA         : out std_ulogic;
      PIPERXRESETB         : out std_ulogic;
      PIPETXCHARDISPMODEA  : out std_logic_vector(1 downto 0);
      PIPETXCHARDISPMODEB  : out std_logic_vector(1 downto 0);
      PIPETXCHARDISPVALA   : out std_logic_vector(1 downto 0);
      PIPETXCHARDISPVALB   : out std_logic_vector(1 downto 0);
      PIPETXCHARISKA       : out std_logic_vector(1 downto 0);
      PIPETXCHARISKB       : out std_logic_vector(1 downto 0);
      PIPETXDATAA          : out std_logic_vector(15 downto 0);
      PIPETXDATAB          : out std_logic_vector(15 downto 0);
      PIPETXRCVRDETA       : out std_ulogic;
      PIPETXRCVRDETB       : out std_ulogic;
      RECEIVEDHOTRESET     : out std_ulogic;
      TRNFCCPLD            : out std_logic_vector(11 downto 0);
      TRNFCCPLH            : out std_logic_vector(7 downto 0);
      TRNFCNPD             : out std_logic_vector(11 downto 0);
      TRNFCNPH             : out std_logic_vector(7 downto 0);
      TRNFCPD              : out std_logic_vector(11 downto 0);
      TRNFCPH              : out std_logic_vector(7 downto 0);
      TRNLNKUPN            : out std_ulogic;
      TRNRBARHITN          : out std_logic_vector(6 downto 0);
      TRNRD                : out std_logic_vector(31 downto 0);
      TRNREOFN             : out std_ulogic;
      TRNRERRFWDN          : out std_ulogic;
      TRNRSOFN             : out std_ulogic;
      TRNRSRCDSCN          : out std_ulogic;
      TRNRSRCRDYN          : out std_ulogic;
      TRNTBUFAV            : out std_logic_vector(5 downto 0);
      TRNTCFGREQN          : out std_ulogic;
      TRNTDSTRDYN          : out std_ulogic;
      TRNTERRDROPN         : out std_ulogic;
      USERRSTN             : out std_ulogic;
      CFGDEVID             : in std_logic_vector(15 downto 0);
      CFGDSN               : in std_logic_vector(63 downto 0);
      CFGDWADDR            : in std_logic_vector(9 downto 0);
      CFGERRCORN           : in std_ulogic := 'L';
      CFGERRCPLABORTN      : in std_ulogic := 'L';
      CFGERRCPLTIMEOUTN    : in std_ulogic := 'L';
      CFGERRECRCN          : in std_ulogic := 'L';
      CFGERRLOCKEDN        : in std_ulogic := 'L';
      CFGERRPOSTEDN        : in std_ulogic := 'L';
      CFGERRTLPCPLHEADER   : in std_logic_vector(47 downto 0);
      CFGERRURN            : in std_ulogic := 'L';
      CFGINTERRUPTASSERTN  : in std_ulogic := 'L';
      CFGINTERRUPTDI       : in std_logic_vector(7 downto 0);
      CFGINTERRUPTN        : in std_ulogic := 'L';
      CFGPMWAKEN           : in std_ulogic := 'L';
      CFGRDENN             : in std_ulogic := 'L';
      CFGREVID             : in std_logic_vector(7 downto 0);
      CFGSUBSYSID          : in std_logic_vector(15 downto 0);
      CFGSUBSYSVENID       : in std_logic_vector(15 downto 0);
      CFGTRNPENDINGN       : in std_ulogic := 'L';
      CFGTURNOFFOKN        : in std_ulogic := 'L';
      CFGVENID             : in std_logic_vector(15 downto 0);
      CLOCKLOCKED          : in std_ulogic := 'L';
      MGTCLK               : in std_ulogic := 'L';
      MIMRXRDATA           : in std_logic_vector(34 downto 0);
      MIMTXRDATA           : in std_logic_vector(35 downto 0);
      PIPEGTRESETDONEA     : in std_ulogic := 'L';
      PIPEGTRESETDONEB     : in std_ulogic := 'L';
      PIPEPHYSTATUSA       : in std_ulogic := 'L';
      PIPEPHYSTATUSB       : in std_ulogic := 'L';
      PIPERXCHARISKA       : in std_logic_vector(1 downto 0);
      PIPERXCHARISKB       : in std_logic_vector(1 downto 0);
      PIPERXDATAA          : in std_logic_vector(15 downto 0);
      PIPERXDATAB          : in std_logic_vector(15 downto 0);
      PIPERXENTERELECIDLEA : in std_ulogic := 'L';
      PIPERXENTERELECIDLEB : in std_ulogic := 'L';
      PIPERXSTATUSA        : in std_logic_vector(2 downto 0);
      PIPERXSTATUSB        : in std_logic_vector(2 downto 0);
      SYSRESETN            : in std_ulogic := 'L';
      TRNFCSEL             : in std_logic_vector(2 downto 0);
      TRNRDSTRDYN          : in std_ulogic := 'L';
      TRNRNPOKN            : in std_ulogic := 'L';
      TRNTCFGGNTN          : in std_ulogic := 'L';
      TRNTD                : in std_logic_vector(31 downto 0);
      TRNTEOFN             : in std_ulogic := 'L';
      TRNTERRFWDN          : in std_ulogic := 'L';
      TRNTSOFN             : in std_ulogic := 'L';
      TRNTSRCDSCN          : in std_ulogic := 'L';
      TRNTSRCRDYN          : in std_ulogic := 'L';
      TRNTSTRN             : in std_ulogic := 'L';
      USERCLK              : in std_ulogic := 'L'      
    );
  end PCIE_A1;

  architecture PCIE_A1_V of PCIE_A1 is
    component PCIE_A1_WRAP
      generic (
        BAR0 : string;
        BAR1 : string;
        BAR2 : string;
        BAR3 : string;
        BAR4 : string;
        BAR5 : string;
        CARDBUS_CIS_POINTER : string;
        CLASS_CODE : string;
        DEV_CAP_ENDPOINT_L0S_LATENCY : integer;
        DEV_CAP_ENDPOINT_L1_LATENCY : integer;
        DEV_CAP_EXT_TAG_SUPPORTED : string;
        DEV_CAP_MAX_PAYLOAD_SUPPORTED : integer;
        DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer;
        DEV_CAP_ROLE_BASED_ERROR : string;
        DISABLE_BAR_FILTERING : string;
        DISABLE_ID_CHECK : string;
        DISABLE_SCRAMBLING : string;
        ENABLE_RX_TD_ECRC_TRIM : string;
        EXPANSION_ROM : string;
        FAST_TRAIN : string;
        GTP_SEL : integer;
        LINK_CAP_ASPM_SUPPORT : integer;
        LINK_CAP_L0S_EXIT_LATENCY : integer;
        LINK_CAP_L1_EXIT_LATENCY : integer;
        LINK_STATUS_SLOT_CLOCK_CONFIG : string;
        LL_ACK_TIMEOUT : string;
        LL_ACK_TIMEOUT_EN : string;
        LL_REPLAY_TIMEOUT : string;
        LL_REPLAY_TIMEOUT_EN : string;
        MSI_CAP_MULTIMSGCAP : integer;
        MSI_CAP_MULTIMSG_EXTENSION : integer;
        PCIE_CAP_CAPABILITY_VERSION : string;
        PCIE_CAP_DEVICE_PORT_TYPE : string;
        PCIE_CAP_INT_MSG_NUM : string;
        PCIE_CAP_SLOT_IMPLEMENTED : string;
        PCIE_GENERIC : string;
        PLM_AUTO_CONFIG : string;
        PM_CAP_AUXCURRENT : integer;
        PM_CAP_D1SUPPORT : string;
        PM_CAP_D2SUPPORT : string;
        PM_CAP_DSI : string;
        PM_CAP_PMESUPPORT : string;
        PM_CAP_PME_CLOCK : string;
        PM_CAP_VERSION : integer;
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
        SIM_VERSION : string;
        SLOT_CAP_ATT_BUTTON_PRESENT : string;
        SLOT_CAP_ATT_INDICATOR_PRESENT : string;
        SLOT_CAP_POWER_INDICATOR_PRESENT : string;
        TL_RX_RAM_RADDR_LATENCY : integer;
        TL_RX_RAM_RDATA_LATENCY : integer;
        TL_RX_RAM_WRITE_LATENCY : integer;
        TL_TFC_DISABLE : string;
        TL_TX_CHECKS_DISABLE : string;
        TL_TX_RAM_RADDR_LATENCY : integer;
        TL_TX_RAM_RDATA_LATENCY : integer;
        USR_CFG : string;
        USR_EXT_CFG : string;
        VC0_CPL_INFINITE : string;
        VC0_RX_RAM_LIMIT : string;
        VC0_TOTAL_CREDITS_CD : integer;
        VC0_TOTAL_CREDITS_CH : integer;
        VC0_TOTAL_CREDITS_NPH : integer;
        VC0_TOTAL_CREDITS_PD : integer;
        VC0_TOTAL_CREDITS_PH : integer;
        VC0_TX_LASTPACKET : integer        
      );
      
      port (
        CFGBUSNUMBER         : out std_logic_vector(7 downto 0);
        CFGCOMMANDBUSMASTERENABLE : out std_ulogic;
        CFGCOMMANDINTERRUPTDISABLE : out std_ulogic;
        CFGCOMMANDIOENABLE   : out std_ulogic;
        CFGCOMMANDMEMENABLE  : out std_ulogic;
        CFGCOMMANDSERREN     : out std_ulogic;
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
        CFGDEVICENUMBER      : out std_logic_vector(4 downto 0);
        CFGDEVSTATUSCORRERRDETECTED : out std_ulogic;
        CFGDEVSTATUSFATALERRDETECTED : out std_ulogic;
        CFGDEVSTATUSNONFATALERRDETECTED : out std_ulogic;
        CFGDEVSTATUSURDETECTED : out std_ulogic;
        CFGDO                : out std_logic_vector(31 downto 0);
        CFGERRCPLRDYN        : out std_ulogic;
        CFGFUNCTIONNUMBER    : out std_logic_vector(2 downto 0);
        CFGINTERRUPTDO       : out std_logic_vector(7 downto 0);
        CFGINTERRUPTMMENABLE : out std_logic_vector(2 downto 0);
        CFGINTERRUPTMSIENABLE : out std_ulogic;
        CFGINTERRUPTRDYN     : out std_ulogic;
        CFGLINKCONTOLRCB     : out std_ulogic;
        CFGLINKCONTROLASPMCONTROL : out std_logic_vector(1 downto 0);
        CFGLINKCONTROLCOMMONCLOCK : out std_ulogic;
        CFGLINKCONTROLEXTENDEDSYNC : out std_ulogic;
        CFGLTSSMSTATE        : out std_logic_vector(4 downto 0);
        CFGPCIELINKSTATEN    : out std_logic_vector(2 downto 0);
        CFGRDWRDONEN         : out std_ulogic;
        CFGTOTURNOFFN        : out std_ulogic;
        DBGBADDLLPSTATUS     : out std_ulogic;
        DBGBADTLPLCRC        : out std_ulogic;
        DBGBADTLPSEQNUM      : out std_ulogic;
        DBGBADTLPSTATUS      : out std_ulogic;
        DBGDLPROTOCOLSTATUS  : out std_ulogic;
        DBGFCPROTOCOLERRSTATUS : out std_ulogic;
        DBGMLFRMDLENGTH      : out std_ulogic;
        DBGMLFRMDMPS         : out std_ulogic;
        DBGMLFRMDTCVC        : out std_ulogic;
        DBGMLFRMDTLPSTATUS   : out std_ulogic;
        DBGMLFRMDUNRECTYPE   : out std_ulogic;
        DBGPOISTLPSTATUS     : out std_ulogic;
        DBGRCVROVERFLOWSTATUS : out std_ulogic;
        DBGREGDETECTEDCORRECTABLE : out std_ulogic;
        DBGREGDETECTEDFATAL  : out std_ulogic;
        DBGREGDETECTEDNONFATAL : out std_ulogic;
        DBGREGDETECTEDUNSUPPORTED : out std_ulogic;
        DBGRPLYROLLOVERSTATUS : out std_ulogic;
        DBGRPLYTIMEOUTSTATUS : out std_ulogic;
        DBGURNOBARHIT        : out std_ulogic;
        DBGURPOISCFGWR       : out std_ulogic;
        DBGURSTATUS          : out std_ulogic;
        DBGURUNSUPMSG        : out std_ulogic;
        MIMRXRADDR           : out std_logic_vector(11 downto 0);
        MIMRXREN             : out std_ulogic;
        MIMRXWADDR           : out std_logic_vector(11 downto 0);
        MIMRXWDATA           : out std_logic_vector(34 downto 0);
        MIMRXWEN             : out std_ulogic;
        MIMTXRADDR           : out std_logic_vector(11 downto 0);
        MIMTXREN             : out std_ulogic;
        MIMTXWADDR           : out std_logic_vector(11 downto 0);
        MIMTXWDATA           : out std_logic_vector(35 downto 0);
        MIMTXWEN             : out std_ulogic;
        PIPEGTPOWERDOWNA     : out std_logic_vector(1 downto 0);
        PIPEGTPOWERDOWNB     : out std_logic_vector(1 downto 0);
        PIPEGTTXELECIDLEA    : out std_ulogic;
        PIPEGTTXELECIDLEB    : out std_ulogic;
        PIPERXPOLARITYA      : out std_ulogic;
        PIPERXPOLARITYB      : out std_ulogic;
        PIPERXRESETA         : out std_ulogic;
        PIPERXRESETB         : out std_ulogic;
        PIPETXCHARDISPMODEA  : out std_logic_vector(1 downto 0);
        PIPETXCHARDISPMODEB  : out std_logic_vector(1 downto 0);
        PIPETXCHARDISPVALA   : out std_logic_vector(1 downto 0);
        PIPETXCHARDISPVALB   : out std_logic_vector(1 downto 0);
        PIPETXCHARISKA       : out std_logic_vector(1 downto 0);
        PIPETXCHARISKB       : out std_logic_vector(1 downto 0);
        PIPETXDATAA          : out std_logic_vector(15 downto 0);
        PIPETXDATAB          : out std_logic_vector(15 downto 0);
        PIPETXRCVRDETA       : out std_ulogic;
        PIPETXRCVRDETB       : out std_ulogic;
        RECEIVEDHOTRESET     : out std_ulogic;
        TRNFCCPLD            : out std_logic_vector(11 downto 0);
        TRNFCCPLH            : out std_logic_vector(7 downto 0);
        TRNFCNPD             : out std_logic_vector(11 downto 0);
        TRNFCNPH             : out std_logic_vector(7 downto 0);
        TRNFCPD              : out std_logic_vector(11 downto 0);
        TRNFCPH              : out std_logic_vector(7 downto 0);
        TRNLNKUPN            : out std_ulogic;
        TRNRBARHITN          : out std_logic_vector(6 downto 0);
        TRNRD                : out std_logic_vector(31 downto 0);
        TRNREOFN             : out std_ulogic;
        TRNRERRFWDN          : out std_ulogic;
        TRNRSOFN             : out std_ulogic;
        TRNRSRCDSCN          : out std_ulogic;
        TRNRSRCRDYN          : out std_ulogic;
        TRNTBUFAV            : out std_logic_vector(5 downto 0);
        TRNTCFGREQN          : out std_ulogic;
        TRNTDSTRDYN          : out std_ulogic;
        TRNTERRDROPN         : out std_ulogic;
        USERRSTN             : out std_ulogic;
        GSR                  : in std_ulogic;
        CFGDEVID             : in std_logic_vector(15 downto 0);
        CFGDSN               : in std_logic_vector(63 downto 0);
        CFGDWADDR            : in std_logic_vector(9 downto 0);
        CFGERRCORN           : in std_ulogic;
        CFGERRCPLABORTN      : in std_ulogic;
        CFGERRCPLTIMEOUTN    : in std_ulogic;
        CFGERRECRCN          : in std_ulogic;
        CFGERRLOCKEDN        : in std_ulogic;
        CFGERRPOSTEDN        : in std_ulogic;
        CFGERRTLPCPLHEADER   : in std_logic_vector(47 downto 0);
        CFGERRURN            : in std_ulogic;
        CFGINTERRUPTASSERTN  : in std_ulogic;
        CFGINTERRUPTDI       : in std_logic_vector(7 downto 0);
        CFGINTERRUPTN        : in std_ulogic;
        CFGPMWAKEN           : in std_ulogic;
        CFGRDENN             : in std_ulogic;
        CFGREVID             : in std_logic_vector(7 downto 0);
        CFGSUBSYSID          : in std_logic_vector(15 downto 0);
        CFGSUBSYSVENID       : in std_logic_vector(15 downto 0);
        CFGTRNPENDINGN       : in std_ulogic;
        CFGTURNOFFOKN        : in std_ulogic;
        CFGVENID             : in std_logic_vector(15 downto 0);
        CLOCKLOCKED          : in std_ulogic;
        MGTCLK               : in std_ulogic;
        MIMRXRDATA           : in std_logic_vector(34 downto 0);
        MIMTXRDATA           : in std_logic_vector(35 downto 0);
        PIPEGTRESETDONEA     : in std_ulogic;
        PIPEGTRESETDONEB     : in std_ulogic;
        PIPEPHYSTATUSA       : in std_ulogic;
        PIPEPHYSTATUSB       : in std_ulogic;
        PIPERXCHARISKA       : in std_logic_vector(1 downto 0);
        PIPERXCHARISKB       : in std_logic_vector(1 downto 0);
        PIPERXDATAA          : in std_logic_vector(15 downto 0);
        PIPERXDATAB          : in std_logic_vector(15 downto 0);
        PIPERXENTERELECIDLEA : in std_ulogic;
        PIPERXENTERELECIDLEB : in std_ulogic;
        PIPERXSTATUSA        : in std_logic_vector(2 downto 0);
        PIPERXSTATUSB        : in std_logic_vector(2 downto 0);
        SYSRESETN            : in std_ulogic;
        TRNFCSEL             : in std_logic_vector(2 downto 0);
        TRNRDSTRDYN          : in std_ulogic;
        TRNRNPOKN            : in std_ulogic;
        TRNTCFGGNTN          : in std_ulogic;
        TRNTD                : in std_logic_vector(31 downto 0);
        TRNTEOFN             : in std_ulogic;
        TRNTERRFWDN          : in std_ulogic;
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

    function boolean_to_string(bool: boolean)
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

    -- Convert bit_vector to std_logic_vector
    constant BAR0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR0)(31 downto 0);
    constant BAR1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR1)(31 downto 0);
    constant BAR2_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR2)(31 downto 0);
    constant BAR3_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR3)(31 downto 0);
    constant BAR4_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR4)(31 downto 0);
    constant BAR5_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(BAR5)(31 downto 0);
    constant CARDBUS_CIS_POINTER_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(CARDBUS_CIS_POINTER)(31 downto 0);
    constant CLASS_CODE_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(CLASS_CODE)(23 downto 0);
    constant EXPANSION_ROM_BINARY : std_logic_vector(21 downto 0) := To_StdLogicVector(EXPANSION_ROM)(21 downto 0);
    constant LL_ACK_TIMEOUT_BINARY : std_logic_vector(14 downto 0) := To_StdLogicVector(LL_ACK_TIMEOUT)(14 downto 0);
    constant LL_REPLAY_TIMEOUT_BINARY : std_logic_vector(14 downto 0) := To_StdLogicVector(LL_REPLAY_TIMEOUT)(14 downto 0);
    constant PCIE_CAP_CAPABILITY_VERSION_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PCIE_CAP_CAPABILITY_VERSION)(3 downto 0);
    constant PCIE_CAP_DEVICE_PORT_TYPE_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(PCIE_CAP_DEVICE_PORT_TYPE)(3 downto 0);
    constant PCIE_CAP_INT_MSG_NUM_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(PCIE_CAP_INT_MSG_NUM)(4 downto 0);
    constant PCIE_GENERIC_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(PCIE_GENERIC)(11 downto 0);
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
    constant VC0_RX_RAM_LIMIT_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(VC0_RX_RAM_LIMIT)(11 downto 0);
    constant BAR0_STRLEN : integer := getstrlength(BAR0_BINARY);
    constant BAR1_STRLEN : integer := getstrlength(BAR1_BINARY);
    constant BAR2_STRLEN : integer := getstrlength(BAR2_BINARY);
    constant BAR3_STRLEN : integer := getstrlength(BAR3_BINARY);
    constant BAR4_STRLEN : integer := getstrlength(BAR4_BINARY);
    constant BAR5_STRLEN : integer := getstrlength(BAR5_BINARY);
    constant CARDBUS_CIS_POINTER_STRLEN : integer := getstrlength(CARDBUS_CIS_POINTER_BINARY);
    constant CLASS_CODE_STRLEN : integer := getstrlength(CLASS_CODE_BINARY);
    constant EXPANSION_ROM_STRLEN : integer := getstrlength(EXPANSION_ROM_BINARY);
    constant LL_ACK_TIMEOUT_STRLEN : integer := getstrlength(LL_ACK_TIMEOUT_BINARY);
    constant LL_REPLAY_TIMEOUT_STRLEN : integer := getstrlength(LL_REPLAY_TIMEOUT_BINARY);
    constant PCIE_CAP_CAPABILITY_VERSION_STRLEN : integer := getstrlength(PCIE_CAP_CAPABILITY_VERSION_BINARY);
    constant PCIE_CAP_DEVICE_PORT_TYPE_STRLEN : integer := getstrlength(PCIE_CAP_DEVICE_PORT_TYPE_BINARY);
    constant PCIE_CAP_INT_MSG_NUM_STRLEN : integer := getstrlength(PCIE_CAP_INT_MSG_NUM_BINARY);
    constant PCIE_GENERIC_STRLEN : integer := getstrlength(PCIE_GENERIC_BINARY);
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
    constant VC0_RX_RAM_LIMIT_STRLEN : integer := getstrlength(VC0_RX_RAM_LIMIT_BINARY);
    -- Convert std_logic_vector to string
    constant BAR0_STRING : string := SLV_TO_HEX(BAR0_BINARY, BAR0_STRLEN);
    constant BAR1_STRING : string := SLV_TO_HEX(BAR1_BINARY, BAR1_STRLEN);
    constant BAR2_STRING : string := SLV_TO_HEX(BAR2_BINARY, BAR2_STRLEN);
    constant BAR3_STRING : string := SLV_TO_HEX(BAR3_BINARY, BAR3_STRLEN);
    constant BAR4_STRING : string := SLV_TO_HEX(BAR4_BINARY, BAR4_STRLEN);
    constant BAR5_STRING : string := SLV_TO_HEX(BAR5_BINARY, BAR5_STRLEN);
    constant CARDBUS_CIS_POINTER_STRING : string := SLV_TO_HEX(CARDBUS_CIS_POINTER_BINARY, CARDBUS_CIS_POINTER_STRLEN);
    constant CLASS_CODE_STRING : string := SLV_TO_HEX(CLASS_CODE_BINARY, CLASS_CODE_STRLEN);
    constant EXPANSION_ROM_STRING : string := SLV_TO_HEX(EXPANSION_ROM_BINARY, EXPANSION_ROM_STRLEN);
    constant LL_ACK_TIMEOUT_STRING : string := SLV_TO_HEX(LL_ACK_TIMEOUT_BINARY, LL_ACK_TIMEOUT_STRLEN);
    constant LL_REPLAY_TIMEOUT_STRING : string := SLV_TO_HEX(LL_REPLAY_TIMEOUT_BINARY, LL_REPLAY_TIMEOUT_STRLEN);
    constant PCIE_CAP_CAPABILITY_VERSION_STRING : string := SLV_TO_HEX(PCIE_CAP_CAPABILITY_VERSION_BINARY, PCIE_CAP_CAPABILITY_VERSION_STRLEN);
    constant PCIE_CAP_DEVICE_PORT_TYPE_STRING : string := SLV_TO_HEX(PCIE_CAP_DEVICE_PORT_TYPE_BINARY, PCIE_CAP_DEVICE_PORT_TYPE_STRLEN);
    constant PCIE_CAP_INT_MSG_NUM_STRING : string := SLV_TO_HEX(PCIE_CAP_INT_MSG_NUM_BINARY, PCIE_CAP_INT_MSG_NUM_STRLEN);
    constant PCIE_GENERIC_STRING : string := SLV_TO_HEX(PCIE_GENERIC_BINARY, PCIE_GENERIC_STRLEN);
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
    constant VC0_RX_RAM_LIMIT_STRING : string := SLV_TO_HEX(VC0_RX_RAM_LIMIT_BINARY, VC0_RX_RAM_LIMIT_STRLEN);
    
    -- Convert boolean to string
    constant DEV_CAP_EXT_TAG_SUPPORTED_STRING : string := boolean_to_string(DEV_CAP_EXT_TAG_SUPPORTED);
    constant DEV_CAP_ROLE_BASED_ERROR_STRING : string := boolean_to_string(DEV_CAP_ROLE_BASED_ERROR);
    constant DISABLE_BAR_FILTERING_STRING : string := boolean_to_string(DISABLE_BAR_FILTERING);
    constant DISABLE_ID_CHECK_STRING : string := boolean_to_string(DISABLE_ID_CHECK);
    constant DISABLE_SCRAMBLING_STRING : string := boolean_to_string(DISABLE_SCRAMBLING);
    constant ENABLE_RX_TD_ECRC_TRIM_STRING : string := boolean_to_string(ENABLE_RX_TD_ECRC_TRIM);
    constant FAST_TRAIN_STRING : string := boolean_to_string(FAST_TRAIN);
    constant LINK_STATUS_SLOT_CLOCK_CONFIG_STRING : string := boolean_to_string(LINK_STATUS_SLOT_CLOCK_CONFIG);
    constant LL_ACK_TIMEOUT_EN_STRING : string := boolean_to_string(LL_ACK_TIMEOUT_EN);
    constant LL_REPLAY_TIMEOUT_EN_STRING : string := boolean_to_string(LL_REPLAY_TIMEOUT_EN);
    constant PCIE_CAP_SLOT_IMPLEMENTED_STRING : string := boolean_to_string(PCIE_CAP_SLOT_IMPLEMENTED);
    constant PLM_AUTO_CONFIG_STRING : string := boolean_to_string(PLM_AUTO_CONFIG);
    constant PM_CAP_D1SUPPORT_STRING : string := boolean_to_string(PM_CAP_D1SUPPORT);
    constant PM_CAP_D2SUPPORT_STRING : string := boolean_to_string(PM_CAP_D2SUPPORT);
    constant PM_CAP_DSI_STRING : string := boolean_to_string(PM_CAP_DSI);
    constant PM_CAP_PME_CLOCK_STRING : string := boolean_to_string(PM_CAP_PME_CLOCK);
    constant SLOT_CAP_ATT_BUTTON_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_ATT_BUTTON_PRESENT);
    constant SLOT_CAP_ATT_INDICATOR_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_ATT_INDICATOR_PRESENT);
    constant SLOT_CAP_POWER_INDICATOR_PRESENT_STRING : string := boolean_to_string(SLOT_CAP_POWER_INDICATOR_PRESENT);
    constant TL_TFC_DISABLE_STRING : string := boolean_to_string(TL_TFC_DISABLE);
    constant TL_TX_CHECKS_DISABLE_STRING : string := boolean_to_string(TL_TX_CHECKS_DISABLE);
    constant USR_CFG_STRING : string := boolean_to_string(USR_CFG);
    constant USR_EXT_CFG_STRING : string := boolean_to_string(USR_EXT_CFG);
    constant VC0_CPL_INFINITE_STRING : string := boolean_to_string(VC0_CPL_INFINITE);
    
    signal DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CAP_ENDPOINT_L1_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CAP_EXT_TAG_SUPPORTED_BINARY : std_ulogic;
    signal DEV_CAP_MAX_PAYLOAD_SUPPORTED_BINARY : std_logic_vector(2 downto 0);
    signal DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT_BINARY : std_logic_vector(1 downto 0);
    signal DEV_CAP_ROLE_BASED_ERROR_BINARY : std_ulogic;
    signal DISABLE_BAR_FILTERING_BINARY : std_ulogic;
    signal DISABLE_ID_CHECK_BINARY : std_ulogic;
    signal DISABLE_SCRAMBLING_BINARY : std_ulogic;
    signal ENABLE_RX_TD_ECRC_TRIM_BINARY : std_ulogic;
    signal FAST_TRAIN_BINARY : std_ulogic;
    signal GTP_SEL_BINARY : std_ulogic;
    signal LINK_CAP_ASPM_SUPPORT_BINARY : std_logic_vector(1 downto 0);
    signal LINK_CAP_L0S_EXIT_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal LINK_CAP_L1_EXIT_LATENCY_BINARY : std_logic_vector(2 downto 0);
    signal LINK_STATUS_SLOT_CLOCK_CONFIG_BINARY : std_ulogic;
    signal LL_ACK_TIMEOUT_EN_BINARY : std_ulogic;
    signal LL_REPLAY_TIMEOUT_EN_BINARY : std_ulogic;
    signal MSI_CAP_MULTIMSGCAP_BINARY : std_logic_vector(2 downto 0);
    signal MSI_CAP_MULTIMSG_EXTENSION_BINARY : std_ulogic;
    signal PCIE_CAP_SLOT_IMPLEMENTED_BINARY : std_ulogic;
    signal PLM_AUTO_CONFIG_BINARY : std_ulogic;
    signal PM_CAP_AUXCURRENT_BINARY : std_logic_vector(2 downto 0);
    signal PM_CAP_D1SUPPORT_BINARY : std_ulogic;
    signal PM_CAP_D2SUPPORT_BINARY : std_ulogic;
    signal PM_CAP_DSI_BINARY : std_ulogic;
    signal PM_CAP_PME_CLOCK_BINARY : std_ulogic;
    signal PM_CAP_VERSION_BINARY : std_logic_vector(2 downto 0);
    signal SIM_VERSION_BINARY : std_ulogic;
    signal SLOT_CAP_ATT_BUTTON_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_ATT_INDICATOR_PRESENT_BINARY : std_ulogic;
    signal SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY : std_ulogic;
    signal TL_RX_RAM_RADDR_LATENCY_BINARY : std_ulogic;
    signal TL_RX_RAM_RDATA_LATENCY_BINARY : std_logic_vector(1 downto 0);
    signal TL_RX_RAM_WRITE_LATENCY_BINARY : std_ulogic;
    signal TL_TFC_DISABLE_BINARY : std_ulogic;
    signal TL_TX_CHECKS_DISABLE_BINARY : std_ulogic;
    signal TL_TX_RAM_RADDR_LATENCY_BINARY : std_ulogic;
    signal TL_TX_RAM_RDATA_LATENCY_BINARY : std_logic_vector(1 downto 0);
    signal USR_CFG_BINARY : std_ulogic;
    signal USR_EXT_CFG_BINARY : std_ulogic;
    signal VC0_CPL_INFINITE_BINARY : std_ulogic;
    signal VC0_TOTAL_CREDITS_CD_BINARY : std_logic_vector(10 downto 0);
    signal VC0_TOTAL_CREDITS_CH_BINARY : std_logic_vector(6 downto 0);
    signal VC0_TOTAL_CREDITS_NPH_BINARY : std_logic_vector(6 downto 0);
    signal VC0_TOTAL_CREDITS_PD_BINARY : std_logic_vector(10 downto 0);
    signal VC0_TOTAL_CREDITS_PH_BINARY : std_logic_vector(6 downto 0);
    signal VC0_TX_LASTPACKET_BINARY : std_logic_vector(4 downto 0);
    
    signal CFGBUSNUMBER_out : std_logic_vector(7 downto 0);
    signal CFGCOMMANDBUSMASTERENABLE_out : std_ulogic;
    signal CFGCOMMANDINTERRUPTDISABLE_out : std_ulogic;
    signal CFGCOMMANDIOENABLE_out : std_ulogic;
    signal CFGCOMMANDMEMENABLE_out : std_ulogic;
    signal CFGCOMMANDSERREN_out : std_ulogic;
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
    signal CFGDEVICENUMBER_out : std_logic_vector(4 downto 0);
    signal CFGDEVSTATUSCORRERRDETECTED_out : std_ulogic;
    signal CFGDEVSTATUSFATALERRDETECTED_out : std_ulogic;
    signal CFGDEVSTATUSNONFATALERRDETECTED_out : std_ulogic;
    signal CFGDEVSTATUSURDETECTED_out : std_ulogic;
    signal CFGDO_out : std_logic_vector(31 downto 0);
    signal CFGERRCPLRDYN_out : std_ulogic;
    signal CFGFUNCTIONNUMBER_out : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTDO_out : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTMMENABLE_out : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIENABLE_out : std_ulogic;
    signal CFGINTERRUPTRDYN_out : std_ulogic;
    signal CFGLINKCONTOLRCB_out : std_ulogic;
    signal CFGLINKCONTROLASPMCONTROL_out : std_logic_vector(1 downto 0);
    signal CFGLINKCONTROLCOMMONCLOCK_out : std_ulogic;
    signal CFGLINKCONTROLEXTENDEDSYNC_out : std_ulogic;
    signal CFGLTSSMSTATE_out : std_logic_vector(4 downto 0);
    signal CFGPCIELINKSTATEN_out : std_logic_vector(2 downto 0);
    signal CFGRDWRDONEN_out : std_ulogic;
    signal CFGTOTURNOFFN_out : std_ulogic;
    signal DBGBADDLLPSTATUS_out : std_ulogic;
    signal DBGBADTLPLCRC_out : std_ulogic;
    signal DBGBADTLPSEQNUM_out : std_ulogic;
    signal DBGBADTLPSTATUS_out : std_ulogic;
    signal DBGDLPROTOCOLSTATUS_out : std_ulogic;
    signal DBGFCPROTOCOLERRSTATUS_out : std_ulogic;
    signal DBGMLFRMDLENGTH_out : std_ulogic;
    signal DBGMLFRMDMPS_out : std_ulogic;
    signal DBGMLFRMDTCVC_out : std_ulogic;
    signal DBGMLFRMDTLPSTATUS_out : std_ulogic;
    signal DBGMLFRMDUNRECTYPE_out : std_ulogic;
    signal DBGPOISTLPSTATUS_out : std_ulogic;
    signal DBGRCVROVERFLOWSTATUS_out : std_ulogic;
    signal DBGREGDETECTEDCORRECTABLE_out : std_ulogic;
    signal DBGREGDETECTEDFATAL_out : std_ulogic;
    signal DBGREGDETECTEDNONFATAL_out : std_ulogic;
    signal DBGREGDETECTEDUNSUPPORTED_out : std_ulogic;
    signal DBGRPLYROLLOVERSTATUS_out : std_ulogic;
    signal DBGRPLYTIMEOUTSTATUS_out : std_ulogic;
    signal DBGURNOBARHIT_out : std_ulogic;
    signal DBGURPOISCFGWR_out : std_ulogic;
    signal DBGURSTATUS_out : std_ulogic;
    signal DBGURUNSUPMSG_out : std_ulogic;
    signal MIMRXRADDR_out : std_logic_vector(11 downto 0);
    signal MIMRXREN_out : std_ulogic;
    signal MIMRXWADDR_out : std_logic_vector(11 downto 0);
    signal MIMRXWDATA_out : std_logic_vector(34 downto 0);
    signal MIMRXWEN_out : std_ulogic;
    signal MIMTXRADDR_out : std_logic_vector(11 downto 0);
    signal MIMTXREN_out : std_ulogic;
    signal MIMTXWADDR_out : std_logic_vector(11 downto 0);
    signal MIMTXWDATA_out : std_logic_vector(35 downto 0);
    signal MIMTXWEN_out : std_ulogic;
    signal PIPEGTPOWERDOWNA_out : std_logic_vector(1 downto 0);
    signal PIPEGTPOWERDOWNB_out : std_logic_vector(1 downto 0);
    signal PIPEGTTXELECIDLEA_out : std_ulogic;
    signal PIPEGTTXELECIDLEB_out : std_ulogic;
    signal PIPERXPOLARITYA_out : std_ulogic;
    signal PIPERXPOLARITYB_out : std_ulogic;
    signal PIPERXRESETA_out : std_ulogic;
    signal PIPERXRESETB_out : std_ulogic;
    signal PIPETXCHARDISPMODEA_out : std_logic_vector(1 downto 0);
    signal PIPETXCHARDISPMODEB_out : std_logic_vector(1 downto 0);
    signal PIPETXCHARDISPVALA_out : std_logic_vector(1 downto 0);
    signal PIPETXCHARDISPVALB_out : std_logic_vector(1 downto 0);
    signal PIPETXCHARISKA_out : std_logic_vector(1 downto 0);
    signal PIPETXCHARISKB_out : std_logic_vector(1 downto 0);
    signal PIPETXDATAA_out : std_logic_vector(15 downto 0);
    signal PIPETXDATAB_out : std_logic_vector(15 downto 0);
    signal PIPETXRCVRDETA_out : std_ulogic;
    signal PIPETXRCVRDETB_out : std_ulogic;
    signal RECEIVEDHOTRESET_out : std_ulogic;
    signal TRNFCCPLD_out : std_logic_vector(11 downto 0);
    signal TRNFCCPLH_out : std_logic_vector(7 downto 0);
    signal TRNFCNPD_out : std_logic_vector(11 downto 0);
    signal TRNFCNPH_out : std_logic_vector(7 downto 0);
    signal TRNFCPD_out : std_logic_vector(11 downto 0);
    signal TRNFCPH_out : std_logic_vector(7 downto 0);
    signal TRNLNKUPN_out : std_ulogic;
    signal TRNRBARHITN_out : std_logic_vector(6 downto 0);
    signal TRNRD_out : std_logic_vector(31 downto 0);
    signal TRNREOFN_out : std_ulogic;
    signal TRNRERRFWDN_out : std_ulogic;
    signal TRNRSOFN_out : std_ulogic;
    signal TRNRSRCDSCN_out : std_ulogic;
    signal TRNRSRCRDYN_out : std_ulogic;
    signal TRNTBUFAV_out : std_logic_vector(5 downto 0);
    signal TRNTCFGREQN_out : std_ulogic;
    signal TRNTDSTRDYN_out : std_ulogic;
    signal TRNTERRDROPN_out : std_ulogic;
    signal USERRSTN_out : std_ulogic;
    
    signal CFGBUSNUMBER_outdelay : std_logic_vector(7 downto 0);
    signal CFGCOMMANDBUSMASTERENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDINTERRUPTDISABLE_outdelay : std_ulogic;
    signal CFGCOMMANDIOENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDMEMENABLE_outdelay : std_ulogic;
    signal CFGCOMMANDSERREN_outdelay : std_ulogic;
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
    signal CFGDEVICENUMBER_outdelay : std_logic_vector(4 downto 0);
    signal CFGDEVSTATUSCORRERRDETECTED_outdelay : std_ulogic;
    signal CFGDEVSTATUSFATALERRDETECTED_outdelay : std_ulogic;
    signal CFGDEVSTATUSNONFATALERRDETECTED_outdelay : std_ulogic;
    signal CFGDEVSTATUSURDETECTED_outdelay : std_ulogic;
    signal CFGDO_outdelay : std_logic_vector(31 downto 0);
    signal CFGERRCPLRDYN_outdelay : std_ulogic;
    signal CFGFUNCTIONNUMBER_outdelay : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTDO_outdelay : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTMMENABLE_outdelay : std_logic_vector(2 downto 0);
    signal CFGINTERRUPTMSIENABLE_outdelay : std_ulogic;
    signal CFGINTERRUPTRDYN_outdelay : std_ulogic;
    signal CFGLINKCONTOLRCB_outdelay : std_ulogic;
    signal CFGLINKCONTROLASPMCONTROL_outdelay : std_logic_vector(1 downto 0);
    signal CFGLINKCONTROLCOMMONCLOCK_outdelay : std_ulogic;
    signal CFGLINKCONTROLEXTENDEDSYNC_outdelay : std_ulogic;
    signal CFGLTSSMSTATE_outdelay : std_logic_vector(4 downto 0);
    signal CFGPCIELINKSTATEN_outdelay : std_logic_vector(2 downto 0);
    signal CFGRDWRDONEN_outdelay : std_ulogic;
    signal CFGTOTURNOFFN_outdelay : std_ulogic;
    signal DBGBADDLLPSTATUS_outdelay : std_ulogic;
    signal DBGBADTLPLCRC_outdelay : std_ulogic;
    signal DBGBADTLPSEQNUM_outdelay : std_ulogic;
    signal DBGBADTLPSTATUS_outdelay : std_ulogic;
    signal DBGDLPROTOCOLSTATUS_outdelay : std_ulogic;
    signal DBGFCPROTOCOLERRSTATUS_outdelay : std_ulogic;
    signal DBGMLFRMDLENGTH_outdelay : std_ulogic;
    signal DBGMLFRMDMPS_outdelay : std_ulogic;
    signal DBGMLFRMDTCVC_outdelay : std_ulogic;
    signal DBGMLFRMDTLPSTATUS_outdelay : std_ulogic;
    signal DBGMLFRMDUNRECTYPE_outdelay : std_ulogic;
    signal DBGPOISTLPSTATUS_outdelay : std_ulogic;
    signal DBGRCVROVERFLOWSTATUS_outdelay : std_ulogic;
    signal DBGREGDETECTEDCORRECTABLE_outdelay : std_ulogic;
    signal DBGREGDETECTEDFATAL_outdelay : std_ulogic;
    signal DBGREGDETECTEDNONFATAL_outdelay : std_ulogic;
    signal DBGREGDETECTEDUNSUPPORTED_outdelay : std_ulogic;
    signal DBGRPLYROLLOVERSTATUS_outdelay : std_ulogic;
    signal DBGRPLYTIMEOUTSTATUS_outdelay : std_ulogic;
    signal DBGURNOBARHIT_outdelay : std_ulogic;
    signal DBGURPOISCFGWR_outdelay : std_ulogic;
    signal DBGURSTATUS_outdelay : std_ulogic;
    signal DBGURUNSUPMSG_outdelay : std_ulogic;
    signal MIMRXRADDR_outdelay : std_logic_vector(11 downto 0);
    signal MIMRXREN_outdelay : std_ulogic;
    signal MIMRXWADDR_outdelay : std_logic_vector(11 downto 0);
    signal MIMRXWDATA_outdelay : std_logic_vector(34 downto 0);
    signal MIMRXWEN_outdelay : std_ulogic;
    signal MIMTXRADDR_outdelay : std_logic_vector(11 downto 0);
    signal MIMTXREN_outdelay : std_ulogic;
    signal MIMTXWADDR_outdelay : std_logic_vector(11 downto 0);
    signal MIMTXWDATA_outdelay : std_logic_vector(35 downto 0);
    signal MIMTXWEN_outdelay : std_ulogic;
    signal PIPEGTPOWERDOWNA_outdelay : std_logic_vector(1 downto 0);
    signal PIPEGTPOWERDOWNB_outdelay : std_logic_vector(1 downto 0);
    signal PIPEGTTXELECIDLEA_outdelay : std_ulogic;
    signal PIPEGTTXELECIDLEB_outdelay : std_ulogic;
    signal PIPERXPOLARITYA_outdelay : std_ulogic;
    signal PIPERXPOLARITYB_outdelay : std_ulogic;
    signal PIPERXRESETA_outdelay : std_ulogic;
    signal PIPERXRESETB_outdelay : std_ulogic;
    signal PIPETXCHARDISPMODEA_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXCHARDISPMODEB_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXCHARDISPVALA_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXCHARDISPVALB_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXCHARISKA_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXCHARISKB_outdelay : std_logic_vector(1 downto 0);
    signal PIPETXDATAA_outdelay : std_logic_vector(15 downto 0);
    signal PIPETXDATAB_outdelay : std_logic_vector(15 downto 0);
    signal PIPETXRCVRDETA_outdelay : std_ulogic;
    signal PIPETXRCVRDETB_outdelay : std_ulogic;
    signal RECEIVEDHOTRESET_outdelay : std_ulogic;
    signal TRNFCCPLD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCCPLH_outdelay : std_logic_vector(7 downto 0);
    signal TRNFCNPD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCNPH_outdelay : std_logic_vector(7 downto 0);
    signal TRNFCPD_outdelay : std_logic_vector(11 downto 0);
    signal TRNFCPH_outdelay : std_logic_vector(7 downto 0);
    signal TRNLNKUPN_outdelay : std_ulogic;
    signal TRNRBARHITN_outdelay : std_logic_vector(6 downto 0);
    signal TRNRD_outdelay : std_logic_vector(31 downto 0);
    signal TRNREOFN_outdelay : std_ulogic;
    signal TRNRERRFWDN_outdelay : std_ulogic;
    signal TRNRSOFN_outdelay : std_ulogic;
    signal TRNRSRCDSCN_outdelay : std_ulogic;
    signal TRNRSRCRDYN_outdelay : std_ulogic;
    signal TRNTBUFAV_outdelay : std_logic_vector(5 downto 0);
    signal TRNTCFGREQN_outdelay : std_ulogic;
    signal TRNTDSTRDYN_outdelay : std_ulogic;
    signal TRNTERRDROPN_outdelay : std_ulogic;
    signal USERRSTN_outdelay : std_ulogic;
    
    signal CFGDEVID_ipd : std_logic_vector(15 downto 0);
    signal CFGDSN_ipd : std_logic_vector(63 downto 0);
    signal CFGDWADDR_ipd : std_logic_vector(9 downto 0);
    signal CFGERRCORN_ipd : std_ulogic;
    signal CFGERRCPLABORTN_ipd : std_ulogic;
    signal CFGERRCPLTIMEOUTN_ipd : std_ulogic;
    signal CFGERRECRCN_ipd : std_ulogic;
    signal CFGERRLOCKEDN_ipd : std_ulogic;
    signal CFGERRPOSTEDN_ipd : std_ulogic;
    signal CFGERRTLPCPLHEADER_ipd : std_logic_vector(47 downto 0);
    signal CFGERRURN_ipd : std_ulogic;
    signal CFGINTERRUPTASSERTN_ipd : std_ulogic;
    signal CFGINTERRUPTDI_ipd : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTN_ipd : std_ulogic;
    signal CFGPMWAKEN_ipd : std_ulogic;
    signal CFGRDENN_ipd : std_ulogic;
    signal CFGREVID_ipd : std_logic_vector(7 downto 0);
    signal CFGSUBSYSID_ipd : std_logic_vector(15 downto 0);
    signal CFGSUBSYSVENID_ipd : std_logic_vector(15 downto 0);
    signal CFGTRNPENDINGN_ipd : std_ulogic;
    signal CFGTURNOFFOKN_ipd : std_ulogic;
    signal CFGVENID_ipd : std_logic_vector(15 downto 0);
    signal CLOCKLOCKED_ipd : std_ulogic;
    signal MGTCLK_ipd : std_ulogic;
    signal MIMRXRDATA_ipd : std_logic_vector(34 downto 0);
    signal MIMTXRDATA_ipd : std_logic_vector(35 downto 0);
    signal PIPEGTRESETDONEA_ipd : std_ulogic;
    signal PIPEGTRESETDONEB_ipd : std_ulogic;
    signal PIPEPHYSTATUSA_ipd : std_ulogic;
    signal PIPEPHYSTATUSB_ipd : std_ulogic;
    signal PIPERXCHARISKA_ipd : std_logic_vector(1 downto 0);
    signal PIPERXCHARISKB_ipd : std_logic_vector(1 downto 0);
    signal PIPERXDATAA_ipd : std_logic_vector(15 downto 0);
    signal PIPERXDATAB_ipd : std_logic_vector(15 downto 0);
    signal PIPERXENTERELECIDLEA_ipd : std_ulogic;
    signal PIPERXENTERELECIDLEB_ipd : std_ulogic;
    signal PIPERXSTATUSA_ipd : std_logic_vector(2 downto 0);
    signal PIPERXSTATUSB_ipd : std_logic_vector(2 downto 0);
    signal SYSRESETN_ipd : std_ulogic;
    signal TRNFCSEL_ipd : std_logic_vector(2 downto 0);
    signal TRNRDSTRDYN_ipd : std_ulogic;
    signal TRNRNPOKN_ipd : std_ulogic;
    signal TRNTCFGGNTN_ipd : std_ulogic;
    signal TRNTD_ipd : std_logic_vector(31 downto 0);
    signal TRNTEOFN_ipd : std_ulogic;
    signal TRNTERRFWDN_ipd : std_ulogic;
    signal TRNTSOFN_ipd : std_ulogic;
    signal TRNTSRCDSCN_ipd : std_ulogic;
    signal TRNTSRCRDYN_ipd : std_ulogic;
    signal TRNTSTRN_ipd : std_ulogic;
    signal USERCLK_ipd : std_ulogic;
    
    signal CFGDEVID_indelay : std_logic_vector(15 downto 0);
    signal CFGDSN_indelay : std_logic_vector(63 downto 0);
    signal CFGDWADDR_indelay : std_logic_vector(9 downto 0);
    signal CFGERRCORN_indelay : std_ulogic;
    signal CFGERRCPLABORTN_indelay : std_ulogic;
    signal CFGERRCPLTIMEOUTN_indelay : std_ulogic;
    signal CFGERRECRCN_indelay : std_ulogic;
    signal CFGERRLOCKEDN_indelay : std_ulogic;
    signal CFGERRPOSTEDN_indelay : std_ulogic;
    signal CFGERRTLPCPLHEADER_indelay : std_logic_vector(47 downto 0);
    signal CFGERRURN_indelay : std_ulogic;
    signal CFGINTERRUPTASSERTN_indelay : std_ulogic;
    signal CFGINTERRUPTDI_indelay : std_logic_vector(7 downto 0);
    signal CFGINTERRUPTN_indelay : std_ulogic;
    signal CFGPMWAKEN_indelay : std_ulogic;
    signal CFGRDENN_indelay : std_ulogic;
    signal CFGREVID_indelay : std_logic_vector(7 downto 0);
    signal CFGSUBSYSID_indelay : std_logic_vector(15 downto 0);
    signal CFGSUBSYSVENID_indelay : std_logic_vector(15 downto 0);
    signal CFGTRNPENDINGN_indelay : std_ulogic;
    signal CFGTURNOFFOKN_indelay : std_ulogic;
    signal CFGVENID_indelay : std_logic_vector(15 downto 0);
    signal CLOCKLOCKED_indelay : std_ulogic;
    signal MGTCLK_indelay : std_ulogic;
    signal MIMRXRDATA_indelay : std_logic_vector(34 downto 0);
    signal MIMTXRDATA_indelay : std_logic_vector(35 downto 0);
    signal PIPEGTRESETDONEA_indelay : std_ulogic;
    signal PIPEGTRESETDONEB_indelay : std_ulogic;
    signal PIPEPHYSTATUSA_indelay : std_ulogic;
    signal PIPEPHYSTATUSB_indelay : std_ulogic;
    signal PIPERXCHARISKA_indelay : std_logic_vector(1 downto 0);
    signal PIPERXCHARISKB_indelay : std_logic_vector(1 downto 0);
    signal PIPERXDATAA_indelay : std_logic_vector(15 downto 0);
    signal PIPERXDATAB_indelay : std_logic_vector(15 downto 0);
    signal PIPERXENTERELECIDLEA_indelay : std_ulogic;
    signal PIPERXENTERELECIDLEB_indelay : std_ulogic;
    signal PIPERXSTATUSA_indelay : std_logic_vector(2 downto 0);
    signal PIPERXSTATUSB_indelay : std_logic_vector(2 downto 0);
    signal SYSRESETN_indelay : std_ulogic;
    signal TRNFCSEL_indelay : std_logic_vector(2 downto 0);
    signal TRNRDSTRDYN_indelay : std_ulogic;
    signal TRNRNPOKN_indelay : std_ulogic;
    signal TRNTCFGGNTN_indelay : std_ulogic;
    signal TRNTD_indelay : std_logic_vector(31 downto 0);
    signal TRNTEOFN_indelay : std_ulogic;
    signal TRNTERRFWDN_indelay : std_ulogic;
    signal TRNTSOFN_indelay : std_ulogic;
    signal TRNTSRCDSCN_indelay : std_ulogic;
    signal TRNTSRCRDYN_indelay : std_ulogic;
    signal TRNTSTRN_indelay : std_ulogic;
    signal USERCLK_indelay : std_ulogic;
    
    signal GSR_dly : std_ulogic := '0';

    begin
    GSR_dly <= GSR;

  CFGBUSNUMBER_out <= CFGBUSNUMBER_outdelay after OUT_DELAY;
    CFGCOMMANDBUSMASTERENABLE_out <= CFGCOMMANDBUSMASTERENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDINTERRUPTDISABLE_out <= CFGCOMMANDINTERRUPTDISABLE_outdelay after OUT_DELAY;
    CFGCOMMANDIOENABLE_out <= CFGCOMMANDIOENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDMEMENABLE_out <= CFGCOMMANDMEMENABLE_outdelay after OUT_DELAY;
    CFGCOMMANDSERREN_out <= CFGCOMMANDSERREN_outdelay after OUT_DELAY;
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
    CFGDEVICENUMBER_out <= CFGDEVICENUMBER_outdelay after OUT_DELAY;
    CFGDEVSTATUSCORRERRDETECTED_out <= CFGDEVSTATUSCORRERRDETECTED_outdelay after OUT_DELAY;
    CFGDEVSTATUSFATALERRDETECTED_out <= CFGDEVSTATUSFATALERRDETECTED_outdelay after OUT_DELAY;
    CFGDEVSTATUSNONFATALERRDETECTED_out <= CFGDEVSTATUSNONFATALERRDETECTED_outdelay after OUT_DELAY;
    CFGDEVSTATUSURDETECTED_out <= CFGDEVSTATUSURDETECTED_outdelay after OUT_DELAY;
    CFGDO_out <= CFGDO_outdelay after OUT_DELAY;
    CFGERRCPLRDYN_out <= CFGERRCPLRDYN_outdelay after OUT_DELAY;
    CFGFUNCTIONNUMBER_out <= CFGFUNCTIONNUMBER_outdelay after OUT_DELAY;
    CFGINTERRUPTDO_out <= CFGINTERRUPTDO_outdelay after OUT_DELAY;
    CFGINTERRUPTMMENABLE_out <= CFGINTERRUPTMMENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTMSIENABLE_out <= CFGINTERRUPTMSIENABLE_outdelay after OUT_DELAY;
    CFGINTERRUPTRDYN_out <= CFGINTERRUPTRDYN_outdelay after OUT_DELAY;
    CFGLINKCONTOLRCB_out <= CFGLINKCONTOLRCB_outdelay after OUT_DELAY;
    CFGLINKCONTROLASPMCONTROL_out <= CFGLINKCONTROLASPMCONTROL_outdelay after OUT_DELAY;
    CFGLINKCONTROLCOMMONCLOCK_out <= CFGLINKCONTROLCOMMONCLOCK_outdelay after OUT_DELAY;
    CFGLINKCONTROLEXTENDEDSYNC_out <= CFGLINKCONTROLEXTENDEDSYNC_outdelay after OUT_DELAY;
    CFGLTSSMSTATE_out <= CFGLTSSMSTATE_outdelay after OUT_DELAY;
    CFGPCIELINKSTATEN_out <= CFGPCIELINKSTATEN_outdelay after OUT_DELAY;
    CFGRDWRDONEN_out <= CFGRDWRDONEN_outdelay after OUT_DELAY;
    CFGTOTURNOFFN_out <= CFGTOTURNOFFN_outdelay after OUT_DELAY;
    DBGBADDLLPSTATUS_out <= DBGBADDLLPSTATUS_outdelay after OUT_DELAY;
    DBGBADTLPLCRC_out <= DBGBADTLPLCRC_outdelay after OUT_DELAY;
    DBGBADTLPSEQNUM_out <= DBGBADTLPSEQNUM_outdelay after OUT_DELAY;
    DBGBADTLPSTATUS_out <= DBGBADTLPSTATUS_outdelay after OUT_DELAY;
    DBGDLPROTOCOLSTATUS_out <= DBGDLPROTOCOLSTATUS_outdelay after OUT_DELAY;
    DBGFCPROTOCOLERRSTATUS_out <= DBGFCPROTOCOLERRSTATUS_outdelay after OUT_DELAY;
    DBGMLFRMDLENGTH_out <= DBGMLFRMDLENGTH_outdelay after OUT_DELAY;
    DBGMLFRMDMPS_out <= DBGMLFRMDMPS_outdelay after OUT_DELAY;
    DBGMLFRMDTCVC_out <= DBGMLFRMDTCVC_outdelay after OUT_DELAY;
    DBGMLFRMDTLPSTATUS_out <= DBGMLFRMDTLPSTATUS_outdelay after OUT_DELAY;
    DBGMLFRMDUNRECTYPE_out <= DBGMLFRMDUNRECTYPE_outdelay after OUT_DELAY;
    DBGPOISTLPSTATUS_out <= DBGPOISTLPSTATUS_outdelay after OUT_DELAY;
    DBGRCVROVERFLOWSTATUS_out <= DBGRCVROVERFLOWSTATUS_outdelay after OUT_DELAY;
    DBGREGDETECTEDCORRECTABLE_out <= DBGREGDETECTEDCORRECTABLE_outdelay after OUT_DELAY;
    DBGREGDETECTEDFATAL_out <= DBGREGDETECTEDFATAL_outdelay after OUT_DELAY;
    DBGREGDETECTEDNONFATAL_out <= DBGREGDETECTEDNONFATAL_outdelay after OUT_DELAY;
    DBGREGDETECTEDUNSUPPORTED_out <= DBGREGDETECTEDUNSUPPORTED_outdelay after OUT_DELAY;
    DBGRPLYROLLOVERSTATUS_out <= DBGRPLYROLLOVERSTATUS_outdelay after OUT_DELAY;
    DBGRPLYTIMEOUTSTATUS_out <= DBGRPLYTIMEOUTSTATUS_outdelay after OUT_DELAY;
    DBGURNOBARHIT_out <= DBGURNOBARHIT_outdelay after OUT_DELAY;
    DBGURPOISCFGWR_out <= DBGURPOISCFGWR_outdelay after OUT_DELAY;
    DBGURSTATUS_out <= DBGURSTATUS_outdelay after OUT_DELAY;
    DBGURUNSUPMSG_out <= DBGURUNSUPMSG_outdelay after OUT_DELAY;
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
    PIPEGTPOWERDOWNA_out <= PIPEGTPOWERDOWNA_outdelay after OUT_DELAY;
    PIPEGTPOWERDOWNB_out <= PIPEGTPOWERDOWNB_outdelay after OUT_DELAY;
    PIPEGTTXELECIDLEA_out <= PIPEGTTXELECIDLEA_outdelay after OUT_DELAY;
    PIPEGTTXELECIDLEB_out <= PIPEGTTXELECIDLEB_outdelay after OUT_DELAY;
    PIPERXPOLARITYA_out <= PIPERXPOLARITYA_outdelay after OUT_DELAY;
    PIPERXPOLARITYB_out <= PIPERXPOLARITYB_outdelay after OUT_DELAY;
    PIPERXRESETA_out <= PIPERXRESETA_outdelay after OUT_DELAY;
    PIPERXRESETB_out <= PIPERXRESETB_outdelay after OUT_DELAY;
    PIPETXCHARDISPMODEA_out <= PIPETXCHARDISPMODEA_outdelay after OUT_DELAY;
    PIPETXCHARDISPMODEB_out <= PIPETXCHARDISPMODEB_outdelay after OUT_DELAY;
    PIPETXCHARDISPVALA_out <= PIPETXCHARDISPVALA_outdelay after OUT_DELAY;
    PIPETXCHARDISPVALB_out <= PIPETXCHARDISPVALB_outdelay after OUT_DELAY;
    PIPETXCHARISKA_out <= PIPETXCHARISKA_outdelay after OUT_DELAY;
    PIPETXCHARISKB_out <= PIPETXCHARISKB_outdelay after OUT_DELAY;
    PIPETXDATAA_out <= PIPETXDATAA_outdelay after OUT_DELAY;
    PIPETXDATAB_out <= PIPETXDATAB_outdelay after OUT_DELAY;
    PIPETXRCVRDETA_out <= PIPETXRCVRDETA_outdelay after OUT_DELAY;
    PIPETXRCVRDETB_out <= PIPETXRCVRDETB_outdelay after OUT_DELAY;
    RECEIVEDHOTRESET_out <= RECEIVEDHOTRESET_outdelay after OUT_DELAY;
    TRNFCCPLD_out <= TRNFCCPLD_outdelay after OUT_DELAY;
    TRNFCCPLH_out <= TRNFCCPLH_outdelay after OUT_DELAY;
    TRNFCNPD_out <= TRNFCNPD_outdelay after OUT_DELAY;
    TRNFCNPH_out <= TRNFCNPH_outdelay after OUT_DELAY;
    TRNFCPD_out <= TRNFCPD_outdelay after OUT_DELAY;
    TRNFCPH_out <= TRNFCPH_outdelay after OUT_DELAY;
    TRNLNKUPN_out <= TRNLNKUPN_outdelay after OUT_DELAY;
    TRNRBARHITN_out <= TRNRBARHITN_outdelay after OUT_DELAY;
    TRNRD_out <= TRNRD_outdelay after OUT_DELAY;
    TRNREOFN_out <= TRNREOFN_outdelay after OUT_DELAY;
    TRNRERRFWDN_out <= TRNRERRFWDN_outdelay after OUT_DELAY;
    TRNRSOFN_out <= TRNRSOFN_outdelay after OUT_DELAY;
    TRNRSRCDSCN_out <= TRNRSRCDSCN_outdelay after OUT_DELAY;
    TRNRSRCRDYN_out <= TRNRSRCRDYN_outdelay after OUT_DELAY;
    TRNTBUFAV_out <= TRNTBUFAV_outdelay after OUT_DELAY;
    TRNTCFGREQN_out <= TRNTCFGREQN_outdelay after OUT_DELAY;
    TRNTDSTRDYN_out <= TRNTDSTRDYN_outdelay after OUT_DELAY;
    TRNTERRDROPN_out <= TRNTERRDROPN_outdelay after OUT_DELAY;
    USERRSTN_out <= USERRSTN_outdelay after OUT_DELAY;
    
    MGTCLK_ipd <= MGTCLK;
    USERCLK_ipd <= USERCLK;
    
    CFGDEVID_ipd <= CFGDEVID;
    CFGDSN_ipd <= CFGDSN;
    CFGDWADDR_ipd <= CFGDWADDR;
    CFGERRCORN_ipd <= CFGERRCORN;
    CFGERRCPLABORTN_ipd <= CFGERRCPLABORTN;
    CFGERRCPLTIMEOUTN_ipd <= CFGERRCPLTIMEOUTN;
    CFGERRECRCN_ipd <= CFGERRECRCN;
    CFGERRLOCKEDN_ipd <= CFGERRLOCKEDN;
    CFGERRPOSTEDN_ipd <= CFGERRPOSTEDN;
    CFGERRTLPCPLHEADER_ipd <= CFGERRTLPCPLHEADER;
    CFGERRURN_ipd <= CFGERRURN;
    CFGINTERRUPTASSERTN_ipd <= CFGINTERRUPTASSERTN;
    CFGINTERRUPTDI_ipd <= CFGINTERRUPTDI;
    CFGINTERRUPTN_ipd <= CFGINTERRUPTN;
    CFGPMWAKEN_ipd <= CFGPMWAKEN;
    CFGRDENN_ipd <= CFGRDENN;
    CFGREVID_ipd <= CFGREVID;
    CFGSUBSYSID_ipd <= CFGSUBSYSID;
    CFGSUBSYSVENID_ipd <= CFGSUBSYSVENID;
    CFGTRNPENDINGN_ipd <= CFGTRNPENDINGN;
    CFGTURNOFFOKN_ipd <= CFGTURNOFFOKN;
    CFGVENID_ipd <= CFGVENID;
    CLOCKLOCKED_ipd <= CLOCKLOCKED;
    MIMRXRDATA_ipd <= MIMRXRDATA;
    MIMTXRDATA_ipd <= MIMTXRDATA;
    PIPEGTRESETDONEA_ipd <= PIPEGTRESETDONEA;
    PIPEGTRESETDONEB_ipd <= PIPEGTRESETDONEB;
    PIPEPHYSTATUSA_ipd <= PIPEPHYSTATUSA;
    PIPEPHYSTATUSB_ipd <= PIPEPHYSTATUSB;
    PIPERXCHARISKA_ipd <= PIPERXCHARISKA;
    PIPERXCHARISKB_ipd <= PIPERXCHARISKB;
    PIPERXDATAA_ipd <= PIPERXDATAA;
    PIPERXDATAB_ipd <= PIPERXDATAB;
    PIPERXENTERELECIDLEA_ipd <= PIPERXENTERELECIDLEA;
    PIPERXENTERELECIDLEB_ipd <= PIPERXENTERELECIDLEB;
    PIPERXSTATUSA_ipd <= PIPERXSTATUSA;
    PIPERXSTATUSB_ipd <= PIPERXSTATUSB;
    SYSRESETN_ipd <= SYSRESETN;
    TRNFCSEL_ipd <= TRNFCSEL;
    TRNRDSTRDYN_ipd <= TRNRDSTRDYN;
    TRNRNPOKN_ipd <= TRNRNPOKN;
    TRNTCFGGNTN_ipd <= TRNTCFGGNTN;
    TRNTD_ipd <= TRNTD;
    TRNTEOFN_ipd <= TRNTEOFN;
    TRNTERRFWDN_ipd <= TRNTERRFWDN;
    TRNTSOFN_ipd <= TRNTSOFN;
    TRNTSRCDSCN_ipd <= TRNTSRCDSCN;
    TRNTSRCRDYN_ipd <= TRNTSRCRDYN;
    TRNTSTRN_ipd <= TRNTSTRN;
    
    MGTCLK_indelay <= MGTCLK_ipd after INCLK_DELAY;
    USERCLK_indelay <= USERCLK_ipd after INCLK_DELAY;
    
    CFGDEVID_indelay <= CFGDEVID_ipd after IN_DELAY;
    CFGDSN_indelay <= CFGDSN_ipd after IN_DELAY;
    CFGDWADDR_indelay <= CFGDWADDR_ipd after IN_DELAY;
    CFGERRCORN_indelay <= CFGERRCORN_ipd after IN_DELAY;
    CFGERRCPLABORTN_indelay <= CFGERRCPLABORTN_ipd after IN_DELAY;
    CFGERRCPLTIMEOUTN_indelay <= CFGERRCPLTIMEOUTN_ipd after IN_DELAY;
    CFGERRECRCN_indelay <= CFGERRECRCN_ipd after IN_DELAY;
    CFGERRLOCKEDN_indelay <= CFGERRLOCKEDN_ipd after IN_DELAY;
    CFGERRPOSTEDN_indelay <= CFGERRPOSTEDN_ipd after IN_DELAY;
    CFGERRTLPCPLHEADER_indelay <= CFGERRTLPCPLHEADER_ipd after IN_DELAY;
    CFGERRURN_indelay <= CFGERRURN_ipd after IN_DELAY;
    CFGINTERRUPTASSERTN_indelay <= CFGINTERRUPTASSERTN_ipd after IN_DELAY;
    CFGINTERRUPTDI_indelay <= CFGINTERRUPTDI_ipd after IN_DELAY;
    CFGINTERRUPTN_indelay <= CFGINTERRUPTN_ipd after IN_DELAY;
    CFGPMWAKEN_indelay <= CFGPMWAKEN_ipd after IN_DELAY;
    CFGRDENN_indelay <= CFGRDENN_ipd after IN_DELAY;
    CFGREVID_indelay <= CFGREVID_ipd after IN_DELAY;
    CFGSUBSYSID_indelay <= CFGSUBSYSID_ipd after IN_DELAY;
    CFGSUBSYSVENID_indelay <= CFGSUBSYSVENID_ipd after IN_DELAY;
    CFGTRNPENDINGN_indelay <= CFGTRNPENDINGN_ipd after IN_DELAY;
    CFGTURNOFFOKN_indelay <= CFGTURNOFFOKN_ipd after IN_DELAY;
    CFGVENID_indelay <= CFGVENID_ipd after IN_DELAY;
    CLOCKLOCKED_indelay <= CLOCKLOCKED_ipd after IN_DELAY;
    MIMRXRDATA_indelay <= MIMRXRDATA_ipd after IN_DELAY;
    MIMTXRDATA_indelay <= MIMTXRDATA_ipd after IN_DELAY;
    PIPEGTRESETDONEA_indelay <= PIPEGTRESETDONEA_ipd after IN_DELAY;
    PIPEGTRESETDONEB_indelay <= PIPEGTRESETDONEB_ipd after IN_DELAY;
    PIPEPHYSTATUSA_indelay <= PIPEPHYSTATUSA_ipd after IN_DELAY;
    PIPEPHYSTATUSB_indelay <= PIPEPHYSTATUSB_ipd after IN_DELAY;
    PIPERXCHARISKA_indelay <= PIPERXCHARISKA_ipd after IN_DELAY;
    PIPERXCHARISKB_indelay <= PIPERXCHARISKB_ipd after IN_DELAY;
    PIPERXDATAA_indelay <= PIPERXDATAA_ipd after IN_DELAY;
    PIPERXDATAB_indelay <= PIPERXDATAB_ipd after IN_DELAY;
    PIPERXENTERELECIDLEA_indelay <= PIPERXENTERELECIDLEA_ipd after IN_DELAY;
    PIPERXENTERELECIDLEB_indelay <= PIPERXENTERELECIDLEB_ipd after IN_DELAY;
    PIPERXSTATUSA_indelay <= PIPERXSTATUSA_ipd after IN_DELAY;
    PIPERXSTATUSB_indelay <= PIPERXSTATUSB_ipd after IN_DELAY;
    SYSRESETN_indelay <= SYSRESETN_ipd after IN_DELAY;
    TRNFCSEL_indelay <= TRNFCSEL_ipd after IN_DELAY;
    TRNRDSTRDYN_indelay <= TRNRDSTRDYN_ipd after IN_DELAY;
    TRNRNPOKN_indelay <= TRNRNPOKN_ipd after IN_DELAY;
    TRNTCFGGNTN_indelay <= TRNTCFGGNTN_ipd after IN_DELAY;
    TRNTD_indelay <= TRNTD_ipd after IN_DELAY;
    TRNTEOFN_indelay <= TRNTEOFN_ipd after IN_DELAY;
    TRNTERRFWDN_indelay <= TRNTERRFWDN_ipd after IN_DELAY;
    TRNTSOFN_indelay <= TRNTSOFN_ipd after IN_DELAY;
    TRNTSRCDSCN_indelay <= TRNTSRCDSCN_ipd after IN_DELAY;
    TRNTSRCRDYN_indelay <= TRNTSRCRDYN_ipd after IN_DELAY;
    TRNTSTRN_indelay <= TRNTSTRN_ipd after IN_DELAY;
    
    
    PCIE_A1_WRAP_INST : PCIE_A1_WRAP
      generic map (
        BAR0                 => BAR0_STRING,
        BAR1                 => BAR1_STRING,
        BAR2                 => BAR2_STRING,
        BAR3                 => BAR3_STRING,
        BAR4                 => BAR4_STRING,
        BAR5                 => BAR5_STRING,
        CARDBUS_CIS_POINTER  => CARDBUS_CIS_POINTER_STRING,
        CLASS_CODE           => CLASS_CODE_STRING,
        DEV_CAP_ENDPOINT_L0S_LATENCY => DEV_CAP_ENDPOINT_L0S_LATENCY,
        DEV_CAP_ENDPOINT_L1_LATENCY => DEV_CAP_ENDPOINT_L1_LATENCY,
        DEV_CAP_EXT_TAG_SUPPORTED => DEV_CAP_EXT_TAG_SUPPORTED_STRING,
        DEV_CAP_MAX_PAYLOAD_SUPPORTED => DEV_CAP_MAX_PAYLOAD_SUPPORTED,
        DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT => DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT,
        DEV_CAP_ROLE_BASED_ERROR => DEV_CAP_ROLE_BASED_ERROR_STRING,
        DISABLE_BAR_FILTERING => DISABLE_BAR_FILTERING_STRING,
        DISABLE_ID_CHECK     => DISABLE_ID_CHECK_STRING,
        DISABLE_SCRAMBLING   => DISABLE_SCRAMBLING_STRING,
        ENABLE_RX_TD_ECRC_TRIM => ENABLE_RX_TD_ECRC_TRIM_STRING,
        EXPANSION_ROM        => EXPANSION_ROM_STRING,
        FAST_TRAIN           => FAST_TRAIN_STRING,
        GTP_SEL              => GTP_SEL,
        LINK_CAP_ASPM_SUPPORT => LINK_CAP_ASPM_SUPPORT,
        LINK_CAP_L0S_EXIT_LATENCY => LINK_CAP_L0S_EXIT_LATENCY,
        LINK_CAP_L1_EXIT_LATENCY => LINK_CAP_L1_EXIT_LATENCY,
        LINK_STATUS_SLOT_CLOCK_CONFIG => LINK_STATUS_SLOT_CLOCK_CONFIG_STRING,
        LL_ACK_TIMEOUT       => LL_ACK_TIMEOUT_STRING,
        LL_ACK_TIMEOUT_EN    => LL_ACK_TIMEOUT_EN_STRING,
        LL_REPLAY_TIMEOUT    => LL_REPLAY_TIMEOUT_STRING,
        LL_REPLAY_TIMEOUT_EN => LL_REPLAY_TIMEOUT_EN_STRING,
        MSI_CAP_MULTIMSGCAP  => MSI_CAP_MULTIMSGCAP,
        MSI_CAP_MULTIMSG_EXTENSION => MSI_CAP_MULTIMSG_EXTENSION,
        PCIE_CAP_CAPABILITY_VERSION => PCIE_CAP_CAPABILITY_VERSION_STRING,
        PCIE_CAP_DEVICE_PORT_TYPE => PCIE_CAP_DEVICE_PORT_TYPE_STRING,
        PCIE_CAP_INT_MSG_NUM => PCIE_CAP_INT_MSG_NUM_STRING,
        PCIE_CAP_SLOT_IMPLEMENTED => PCIE_CAP_SLOT_IMPLEMENTED_STRING,
        PCIE_GENERIC         => PCIE_GENERIC_STRING,
        PLM_AUTO_CONFIG      => PLM_AUTO_CONFIG_STRING,
        PM_CAP_AUXCURRENT    => PM_CAP_AUXCURRENT,
        PM_CAP_D1SUPPORT     => PM_CAP_D1SUPPORT_STRING,
        PM_CAP_D2SUPPORT     => PM_CAP_D2SUPPORT_STRING,
        PM_CAP_DSI           => PM_CAP_DSI_STRING,
        PM_CAP_PMESUPPORT    => PM_CAP_PMESUPPORT_STRING,
        PM_CAP_PME_CLOCK     => PM_CAP_PME_CLOCK_STRING,
        PM_CAP_VERSION       => PM_CAP_VERSION,
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
        SIM_VERSION          => SIM_VERSION,
        SLOT_CAP_ATT_BUTTON_PRESENT => SLOT_CAP_ATT_BUTTON_PRESENT_STRING,
        SLOT_CAP_ATT_INDICATOR_PRESENT => SLOT_CAP_ATT_INDICATOR_PRESENT_STRING,
        SLOT_CAP_POWER_INDICATOR_PRESENT => SLOT_CAP_POWER_INDICATOR_PRESENT_STRING,
        TL_RX_RAM_RADDR_LATENCY => TL_RX_RAM_RADDR_LATENCY,
        TL_RX_RAM_RDATA_LATENCY => TL_RX_RAM_RDATA_LATENCY,
        TL_RX_RAM_WRITE_LATENCY => TL_RX_RAM_WRITE_LATENCY,
        TL_TFC_DISABLE       => TL_TFC_DISABLE_STRING,
        TL_TX_CHECKS_DISABLE => TL_TX_CHECKS_DISABLE_STRING,
        TL_TX_RAM_RADDR_LATENCY => TL_TX_RAM_RADDR_LATENCY,
        TL_TX_RAM_RDATA_LATENCY => TL_TX_RAM_RDATA_LATENCY,
        USR_CFG              => USR_CFG_STRING,
        USR_EXT_CFG          => USR_EXT_CFG_STRING,
        VC0_CPL_INFINITE     => VC0_CPL_INFINITE_STRING,
        VC0_RX_RAM_LIMIT     => VC0_RX_RAM_LIMIT_STRING,
        VC0_TOTAL_CREDITS_CD => VC0_TOTAL_CREDITS_CD,
        VC0_TOTAL_CREDITS_CH => VC0_TOTAL_CREDITS_CH,
        VC0_TOTAL_CREDITS_NPH => VC0_TOTAL_CREDITS_NPH,
        VC0_TOTAL_CREDITS_PD => VC0_TOTAL_CREDITS_PD,
        VC0_TOTAL_CREDITS_PH => VC0_TOTAL_CREDITS_PH,
        VC0_TX_LASTPACKET    => VC0_TX_LASTPACKET
      )
      
      port map (
        CFGBUSNUMBER         => CFGBUSNUMBER_outdelay,
        CFGCOMMANDBUSMASTERENABLE => CFGCOMMANDBUSMASTERENABLE_outdelay,
        CFGCOMMANDINTERRUPTDISABLE => CFGCOMMANDINTERRUPTDISABLE_outdelay,
        CFGCOMMANDIOENABLE   => CFGCOMMANDIOENABLE_outdelay,
        CFGCOMMANDMEMENABLE  => CFGCOMMANDMEMENABLE_outdelay,
        CFGCOMMANDSERREN     => CFGCOMMANDSERREN_outdelay,
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
        CFGDEVICENUMBER      => CFGDEVICENUMBER_outdelay,
        CFGDEVSTATUSCORRERRDETECTED => CFGDEVSTATUSCORRERRDETECTED_outdelay,
        CFGDEVSTATUSFATALERRDETECTED => CFGDEVSTATUSFATALERRDETECTED_outdelay,
        CFGDEVSTATUSNONFATALERRDETECTED => CFGDEVSTATUSNONFATALERRDETECTED_outdelay,
        CFGDEVSTATUSURDETECTED => CFGDEVSTATUSURDETECTED_outdelay,
        CFGDO                => CFGDO_outdelay,
        CFGERRCPLRDYN        => CFGERRCPLRDYN_outdelay,
        CFGFUNCTIONNUMBER    => CFGFUNCTIONNUMBER_outdelay,
        CFGINTERRUPTDO       => CFGINTERRUPTDO_outdelay,
        CFGINTERRUPTMMENABLE => CFGINTERRUPTMMENABLE_outdelay,
        CFGINTERRUPTMSIENABLE => CFGINTERRUPTMSIENABLE_outdelay,
        CFGINTERRUPTRDYN     => CFGINTERRUPTRDYN_outdelay,
        CFGLINKCONTOLRCB     => CFGLINKCONTOLRCB_outdelay,
        CFGLINKCONTROLASPMCONTROL => CFGLINKCONTROLASPMCONTROL_outdelay,
        CFGLINKCONTROLCOMMONCLOCK => CFGLINKCONTROLCOMMONCLOCK_outdelay,
        CFGLINKCONTROLEXTENDEDSYNC => CFGLINKCONTROLEXTENDEDSYNC_outdelay,
        CFGLTSSMSTATE        => CFGLTSSMSTATE_outdelay,
        CFGPCIELINKSTATEN    => CFGPCIELINKSTATEN_outdelay,
        CFGRDWRDONEN         => CFGRDWRDONEN_outdelay,
        CFGTOTURNOFFN        => CFGTOTURNOFFN_outdelay,
        DBGBADDLLPSTATUS     => DBGBADDLLPSTATUS_outdelay,
        DBGBADTLPLCRC        => DBGBADTLPLCRC_outdelay,
        DBGBADTLPSEQNUM      => DBGBADTLPSEQNUM_outdelay,
        DBGBADTLPSTATUS      => DBGBADTLPSTATUS_outdelay,
        DBGDLPROTOCOLSTATUS  => DBGDLPROTOCOLSTATUS_outdelay,
        DBGFCPROTOCOLERRSTATUS => DBGFCPROTOCOLERRSTATUS_outdelay,
        DBGMLFRMDLENGTH      => DBGMLFRMDLENGTH_outdelay,
        DBGMLFRMDMPS         => DBGMLFRMDMPS_outdelay,
        DBGMLFRMDTCVC        => DBGMLFRMDTCVC_outdelay,
        DBGMLFRMDTLPSTATUS   => DBGMLFRMDTLPSTATUS_outdelay,
        DBGMLFRMDUNRECTYPE   => DBGMLFRMDUNRECTYPE_outdelay,
        DBGPOISTLPSTATUS     => DBGPOISTLPSTATUS_outdelay,
        DBGRCVROVERFLOWSTATUS => DBGRCVROVERFLOWSTATUS_outdelay,
        DBGREGDETECTEDCORRECTABLE => DBGREGDETECTEDCORRECTABLE_outdelay,
        DBGREGDETECTEDFATAL  => DBGREGDETECTEDFATAL_outdelay,
        DBGREGDETECTEDNONFATAL => DBGREGDETECTEDNONFATAL_outdelay,
        DBGREGDETECTEDUNSUPPORTED => DBGREGDETECTEDUNSUPPORTED_outdelay,
        DBGRPLYROLLOVERSTATUS => DBGRPLYROLLOVERSTATUS_outdelay,
        DBGRPLYTIMEOUTSTATUS => DBGRPLYTIMEOUTSTATUS_outdelay,
        DBGURNOBARHIT        => DBGURNOBARHIT_outdelay,
        DBGURPOISCFGWR       => DBGURPOISCFGWR_outdelay,
        DBGURSTATUS          => DBGURSTATUS_outdelay,
        DBGURUNSUPMSG        => DBGURUNSUPMSG_outdelay,
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
        PIPEGTPOWERDOWNA     => PIPEGTPOWERDOWNA_outdelay,
        PIPEGTPOWERDOWNB     => PIPEGTPOWERDOWNB_outdelay,
        PIPEGTTXELECIDLEA    => PIPEGTTXELECIDLEA_outdelay,
        PIPEGTTXELECIDLEB    => PIPEGTTXELECIDLEB_outdelay,
        PIPERXPOLARITYA      => PIPERXPOLARITYA_outdelay,
        PIPERXPOLARITYB      => PIPERXPOLARITYB_outdelay,
        PIPERXRESETA         => PIPERXRESETA_outdelay,
        PIPERXRESETB         => PIPERXRESETB_outdelay,
        PIPETXCHARDISPMODEA  => PIPETXCHARDISPMODEA_outdelay,
        PIPETXCHARDISPMODEB  => PIPETXCHARDISPMODEB_outdelay,
        PIPETXCHARDISPVALA   => PIPETXCHARDISPVALA_outdelay,
        PIPETXCHARDISPVALB   => PIPETXCHARDISPVALB_outdelay,
        PIPETXCHARISKA       => PIPETXCHARISKA_outdelay,
        PIPETXCHARISKB       => PIPETXCHARISKB_outdelay,
        PIPETXDATAA          => PIPETXDATAA_outdelay,
        PIPETXDATAB          => PIPETXDATAB_outdelay,
        PIPETXRCVRDETA       => PIPETXRCVRDETA_outdelay,
        PIPETXRCVRDETB       => PIPETXRCVRDETB_outdelay,
        RECEIVEDHOTRESET     => RECEIVEDHOTRESET_outdelay,
        TRNFCCPLD            => TRNFCCPLD_outdelay,
        TRNFCCPLH            => TRNFCCPLH_outdelay,
        TRNFCNPD             => TRNFCNPD_outdelay,
        TRNFCNPH             => TRNFCNPH_outdelay,
        TRNFCPD              => TRNFCPD_outdelay,
        TRNFCPH              => TRNFCPH_outdelay,
        TRNLNKUPN            => TRNLNKUPN_outdelay,
        TRNRBARHITN          => TRNRBARHITN_outdelay,
        TRNRD                => TRNRD_outdelay,
        TRNREOFN             => TRNREOFN_outdelay,
        TRNRERRFWDN          => TRNRERRFWDN_outdelay,
        TRNRSOFN             => TRNRSOFN_outdelay,
        TRNRSRCDSCN          => TRNRSRCDSCN_outdelay,
        TRNRSRCRDYN          => TRNRSRCRDYN_outdelay,
        TRNTBUFAV            => TRNTBUFAV_outdelay,
        TRNTCFGREQN          => TRNTCFGREQN_outdelay,
        TRNTDSTRDYN          => TRNTDSTRDYN_outdelay,
        TRNTERRDROPN         => TRNTERRDROPN_outdelay,
        USERRSTN             => USERRSTN_outdelay,
        GSR                  => GSR_dly,
        CFGDEVID             => CFGDEVID_indelay,
        CFGDSN               => CFGDSN_indelay,
        CFGDWADDR            => CFGDWADDR_indelay,
        CFGERRCORN           => CFGERRCORN_indelay,
        CFGERRCPLABORTN      => CFGERRCPLABORTN_indelay,
        CFGERRCPLTIMEOUTN    => CFGERRCPLTIMEOUTN_indelay,
        CFGERRECRCN          => CFGERRECRCN_indelay,
        CFGERRLOCKEDN        => CFGERRLOCKEDN_indelay,
        CFGERRPOSTEDN        => CFGERRPOSTEDN_indelay,
        CFGERRTLPCPLHEADER   => CFGERRTLPCPLHEADER_indelay,
        CFGERRURN            => CFGERRURN_indelay,
        CFGINTERRUPTASSERTN  => CFGINTERRUPTASSERTN_indelay,
        CFGINTERRUPTDI       => CFGINTERRUPTDI_indelay,
        CFGINTERRUPTN        => CFGINTERRUPTN_indelay,
        CFGPMWAKEN           => CFGPMWAKEN_indelay,
        CFGRDENN             => CFGRDENN_indelay,
        CFGREVID             => CFGREVID_indelay,
        CFGSUBSYSID          => CFGSUBSYSID_indelay,
        CFGSUBSYSVENID       => CFGSUBSYSVENID_indelay,
        CFGTRNPENDINGN       => CFGTRNPENDINGN_indelay,
        CFGTURNOFFOKN        => CFGTURNOFFOKN_indelay,
        CFGVENID             => CFGVENID_indelay,
        CLOCKLOCKED          => CLOCKLOCKED_indelay,
        MGTCLK               => MGTCLK_indelay,
        MIMRXRDATA           => MIMRXRDATA_indelay,
        MIMTXRDATA           => MIMTXRDATA_indelay,
        PIPEGTRESETDONEA     => PIPEGTRESETDONEA_indelay,
        PIPEGTRESETDONEB     => PIPEGTRESETDONEB_indelay,
        PIPEPHYSTATUSA       => PIPEPHYSTATUSA_indelay,
        PIPEPHYSTATUSB       => PIPEPHYSTATUSB_indelay,
        PIPERXCHARISKA       => PIPERXCHARISKA_indelay,
        PIPERXCHARISKB       => PIPERXCHARISKB_indelay,
        PIPERXDATAA          => PIPERXDATAA_indelay,
        PIPERXDATAB          => PIPERXDATAB_indelay,
        PIPERXENTERELECIDLEA => PIPERXENTERELECIDLEA_indelay,
        PIPERXENTERELECIDLEB => PIPERXENTERELECIDLEB_indelay,
        PIPERXSTATUSA        => PIPERXSTATUSA_indelay,
        PIPERXSTATUSB        => PIPERXSTATUSB_indelay,
        SYSRESETN            => SYSRESETN_indelay,
        TRNFCSEL             => TRNFCSEL_indelay,
        TRNRDSTRDYN          => TRNRDSTRDYN_indelay,
        TRNRNPOKN            => TRNRNPOKN_indelay,
        TRNTCFGGNTN          => TRNTCFGGNTN_indelay,
        TRNTD                => TRNTD_indelay,
        TRNTEOFN             => TRNTEOFN_indelay,
        TRNTERRFWDN          => TRNTERRFWDN_indelay,
        TRNTSOFN             => TRNTSOFN_indelay,
        TRNTSRCDSCN          => TRNTSRCDSCN_indelay,
        TRNTSRCRDYN          => TRNTSRCRDYN_indelay,
        TRNTSTRN             => TRNTSTRN_indelay,
        USERCLK              => USERCLK_indelay        
      );

  --------------------
  --  BEHAVIOR SECTION
  --------------------
--####################################################################
--#####                     Initialize                           #####
--####################################################################
    INIPROC : process
    begin
  -- case SIM_VERSION is
    if((SIM_VERSION = "1.0") or (SIM_VERSION = "1.0")) then
      SIM_VERSION_BINARY <= '0';
    elsif((SIM_VERSION = "2.0") or (SIM_VERSION= "2.0")) then
      SIM_VERSION_BINARY <= '0';
    elsif((SIM_VERSION = "3.0") or (SIM_VERSION= "3.0")) then
      SIM_VERSION_BINARY <= '0';
    elsif((SIM_VERSION = "4.0") or (SIM_VERSION= "4.0")) then
      SIM_VERSION_BINARY <= '0';
    elsif((SIM_VERSION = "5.0") or (SIM_VERSION= "5.0")) then
      SIM_VERSION_BINARY <= '0';
    elsif((SIM_VERSION = "6.0") or (SIM_VERSION= "6.0")) then
      SIM_VERSION_BINARY <= '0';
    else
      assert FALSE report "Error : SIM_VERSION = is not 1.0, 2.0, 3.0, 4.0, 5.0, 6.0." severity error;
    end if;
  -- end case;
    case DEV_CAP_EXT_TAG_SUPPORTED is
      when FALSE   =>  DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '0';
      when TRUE    =>  DEV_CAP_EXT_TAG_SUPPORTED_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CAP_EXT_TAG_SUPPORTED is neither TRUE nor FALSE." severity error;
    end case;
    case DEV_CAP_ROLE_BASED_ERROR is
      when FALSE   =>  DEV_CAP_ROLE_BASED_ERROR_BINARY <= '0';
      when TRUE    =>  DEV_CAP_ROLE_BASED_ERROR_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEV_CAP_ROLE_BASED_ERROR is neither TRUE nor FALSE." severity error;
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
    case DISABLE_SCRAMBLING is
      when FALSE   =>  DISABLE_SCRAMBLING_BINARY <= '0';
      when TRUE    =>  DISABLE_SCRAMBLING_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DISABLE_SCRAMBLING is neither TRUE nor FALSE." severity error;
    end case;
    case ENABLE_RX_TD_ECRC_TRIM is
      when FALSE   =>  ENABLE_RX_TD_ECRC_TRIM_BINARY <= '0';
      when TRUE    =>  ENABLE_RX_TD_ECRC_TRIM_BINARY <= '1';
      when others  =>  assert FALSE report "Error : ENABLE_RX_TD_ECRC_TRIM is neither TRUE nor FALSE." severity error;
    end case;
    case FAST_TRAIN is
      when FALSE   =>  FAST_TRAIN_BINARY <= '0';
      when TRUE    =>  FAST_TRAIN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : FAST_TRAIN is neither TRUE nor FALSE." severity error;
    end case;
    case GTP_SEL is
      when  0   =>  GTP_SEL_BINARY <= '0';
      when  1   =>  GTP_SEL_BINARY <= '1';
      when others  =>  assert FALSE report "Error : GTP_SEL is not in range 0 .. 1." severity error;
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
    case MSI_CAP_MULTIMSG_EXTENSION is
      when  0   =>  MSI_CAP_MULTIMSG_EXTENSION_BINARY <= '0';
      when  1   =>  MSI_CAP_MULTIMSG_EXTENSION_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MSI_CAP_MULTIMSG_EXTENSION is not in range 0 .. 1." severity error;
    end case;
    case PCIE_CAP_SLOT_IMPLEMENTED is
      when FALSE   =>  PCIE_CAP_SLOT_IMPLEMENTED_BINARY <= '0';
      when TRUE    =>  PCIE_CAP_SLOT_IMPLEMENTED_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PCIE_CAP_SLOT_IMPLEMENTED is neither TRUE nor FALSE." severity error;
    end case;
    case PLM_AUTO_CONFIG is
      when FALSE   =>  PLM_AUTO_CONFIG_BINARY <= '0';
      when TRUE    =>  PLM_AUTO_CONFIG_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PLM_AUTO_CONFIG is neither TRUE nor FALSE." severity error;
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
    case PM_CAP_PME_CLOCK is
      when FALSE   =>  PM_CAP_PME_CLOCK_BINARY <= '0';
      when TRUE    =>  PM_CAP_PME_CLOCK_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PM_CAP_PME_CLOCK is neither TRUE nor FALSE." severity error;
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
    case SLOT_CAP_POWER_INDICATOR_PRESENT is
      when FALSE   =>  SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY <= '0';
      when TRUE    =>  SLOT_CAP_POWER_INDICATOR_PRESENT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SLOT_CAP_POWER_INDICATOR_PRESENT is neither TRUE nor FALSE." severity error;
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
    case USR_CFG is
      when FALSE   =>  USR_CFG_BINARY <= '0';
      when TRUE    =>  USR_CFG_BINARY <= '1';
      when others  =>  assert FALSE report "Error : USR_CFG is neither TRUE nor FALSE." severity error;
    end case;
    case USR_EXT_CFG is
      when FALSE   =>  USR_EXT_CFG_BINARY <= '0';
      when TRUE    =>  USR_EXT_CFG_BINARY <= '1';
      when others  =>  assert FALSE report "Error : USR_EXT_CFG is neither TRUE nor FALSE." severity error;
    end case;
    case VC0_CPL_INFINITE is
      when FALSE   =>  VC0_CPL_INFINITE_BINARY <= '0';
      when TRUE    =>  VC0_CPL_INFINITE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : VC0_CPL_INFINITE is neither TRUE nor FALSE." severity error;
    end case;
    if ((DEV_CAP_ENDPOINT_L0S_LATENCY >= 0) and (DEV_CAP_ENDPOINT_L0S_LATENCY <= 7)) then
      DEV_CAP_ENDPOINT_L0S_LATENCY_BINARY <= std_logic_vector(to_unsigned(DEV_CAP_ENDPOINT_L0S_LATENCY, 3));
    else
      assert FALSE report "Error : DEV_CAP_ENDPOINT_L0S_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((DEV_CAP_ENDPOINT_L1_LATENCY >= 0) and (DEV_CAP_ENDPOINT_L1_LATENCY <= 7)) then
      DEV_CAP_ENDPOINT_L1_LATENCY_BINARY <= std_logic_vector(to_unsigned(DEV_CAP_ENDPOINT_L1_LATENCY, 3));
    else
      assert FALSE report "Error : DEV_CAP_ENDPOINT_L1_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((DEV_CAP_MAX_PAYLOAD_SUPPORTED >= 0) and (DEV_CAP_MAX_PAYLOAD_SUPPORTED <= 7)) then
      DEV_CAP_MAX_PAYLOAD_SUPPORTED_BINARY <= std_logic_vector(to_unsigned(DEV_CAP_MAX_PAYLOAD_SUPPORTED, 3));
    else
      assert FALSE report "Error : DEV_CAP_MAX_PAYLOAD_SUPPORTED is not in range 0 .. 7." severity error;
    end if;
    if ((DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT >= 0) and (DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT <= 3)) then
      DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT_BINARY <= std_logic_vector(to_unsigned(DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT, 2));
    else
      assert FALSE report "Error : DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT is not in range 0 .. 3." severity error;
    end if;
    if ((LINK_CAP_ASPM_SUPPORT >= 0) and (LINK_CAP_ASPM_SUPPORT <= 3)) then
      LINK_CAP_ASPM_SUPPORT_BINARY <= std_logic_vector(to_unsigned(LINK_CAP_ASPM_SUPPORT, 2));
    else
      assert FALSE report "Error : LINK_CAP_ASPM_SUPPORT is not in range 0 .. 3." severity error;
    end if;
    if ((LINK_CAP_L0S_EXIT_LATENCY >= 0) and (LINK_CAP_L0S_EXIT_LATENCY <= 7)) then
      LINK_CAP_L0S_EXIT_LATENCY_BINARY <= std_logic_vector(to_unsigned(LINK_CAP_L0S_EXIT_LATENCY, 3));
    else
      assert FALSE report "Error : LINK_CAP_L0S_EXIT_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((LINK_CAP_L1_EXIT_LATENCY >= 0) and (LINK_CAP_L1_EXIT_LATENCY <= 7)) then
      LINK_CAP_L1_EXIT_LATENCY_BINARY <= std_logic_vector(to_unsigned(LINK_CAP_L1_EXIT_LATENCY, 3));
    else
      assert FALSE report "Error : LINK_CAP_L1_EXIT_LATENCY is not in range 0 .. 7." severity error;
    end if;
    if ((MSI_CAP_MULTIMSGCAP >= 0) and (MSI_CAP_MULTIMSGCAP <= 7)) then
      MSI_CAP_MULTIMSGCAP_BINARY <= std_logic_vector(to_unsigned(MSI_CAP_MULTIMSGCAP, 3));
    else
      assert FALSE report "Error : MSI_CAP_MULTIMSGCAP is not in range 0 .. 7." severity error;
    end if;
  if ((PCIE_CAP_INT_MSG_NUM >= "00000") and (PCIE_CAP_INT_MSG_NUM <= "11111")) then
--    PCIE_CAP_INT_MSG_NUM_BINARY <= std_logic_vector(to_unsigned(PCIE_CAP_INT_MSG_NUM, 5));
  else
    assert FALSE report "Error : PCIE_CAP_INT_MSG_NUM is not in range 0 .. 31." severity error;
  end if;
    if ((PM_CAP_AUXCURRENT >= 0) and (PM_CAP_AUXCURRENT <= 7)) then
      PM_CAP_AUXCURRENT_BINARY <= std_logic_vector(to_unsigned(PM_CAP_AUXCURRENT, 3));
    else
      assert FALSE report "Error : PM_CAP_AUXCURRENT is not in range 0 .. 7." severity error;
    end if;
  if ((PM_CAP_PMESUPPORT >= "00000") and (PM_CAP_PMESUPPORT <= "11111")) then
--    PM_CAP_PMESUPPORT_BINARY <= std_logic_vector(to_unsigned(PM_CAP_PMESUPPORT, 5));
  else
    assert FALSE report "Error : PM_CAP_PMESUPPORT is not in range 0 .. 31." severity error;
  end if;
    if ((PM_CAP_VERSION >= 0) and (PM_CAP_VERSION <= 7)) then
      PM_CAP_VERSION_BINARY <= std_logic_vector(to_unsigned(PM_CAP_VERSION, 3));
    else
      assert FALSE report "Error : PM_CAP_VERSION is not in range 0 .. 7." severity error;
    end if;
  if ((PM_DATA_SCALE0 >= "00") and (PM_DATA_SCALE0 <= "11")) then
--    PM_DATA_SCALE0_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE0, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE0 is not in range 0 .. 3." severity error;
  end if;
  if ((PM_DATA_SCALE1 >= "00") and (PM_DATA_SCALE1 <= "11")) then
--    PM_DATA_SCALE1_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE1, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE1 is not in range 0 .. 3." severity error;
  end if;
  if ((PM_DATA_SCALE2 >= "00") and (PM_DATA_SCALE2 <= "11")) then
--    PM_DATA_SCALE2_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE2, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE2 is not in range 0 .. 3." severity error;
  end if;
  if ((PM_DATA_SCALE3 >= "00") and (PM_DATA_SCALE3 <= "11")) then
--    PM_DATA_SCALE3_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE3, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE3 is not in range 0 .. 3." severity error;
  end if;
  if ((PM_DATA_SCALE4 >= "00") and (PM_DATA_SCALE4 <= "11")) then
--    PM_DATA_SCALE4_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE4, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE4 is not in range 0 .. 3." severity error;
  end if;
  if ((PM_DATA_SCALE5 >= "00") and (PM_DATA_SCALE5 <= "11")) then
--    PM_DATA_SCALE5_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE5, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE5 is not in range 0 .. 3." severity error;
  end if;
  if ((PM_DATA_SCALE6 >= "00") and (PM_DATA_SCALE6 <= "11")) then
--    PM_DATA_SCALE6_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE6, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE6 is not in range 0 .. 3." severity error;
  end if;
  if ((PM_DATA_SCALE7 >= "00") and (PM_DATA_SCALE7 <= "11")) then
--    PM_DATA_SCALE7_BINARY <= std_logic_vector(to_unsigned(PM_DATA_SCALE7, 2));
  else
    assert FALSE report "Error : PM_DATA_SCALE7 is not in range 0 .. 3." severity error;
  end if;
    if ((TL_RX_RAM_RDATA_LATENCY >= 0) and (TL_RX_RAM_RDATA_LATENCY <= 3)) then
      TL_RX_RAM_RDATA_LATENCY_BINARY <= std_logic_vector(to_unsigned(TL_RX_RAM_RDATA_LATENCY, 2));
    else
      assert FALSE report "Error : TL_RX_RAM_RDATA_LATENCY is not in range 0 .. 3." severity error;
    end if;
    if ((TL_TX_RAM_RDATA_LATENCY >= 0) and (TL_TX_RAM_RDATA_LATENCY <= 3)) then
      TL_TX_RAM_RDATA_LATENCY_BINARY <= std_logic_vector(to_unsigned(TL_TX_RAM_RDATA_LATENCY, 2));
    else
      assert FALSE report "Error : TL_TX_RAM_RDATA_LATENCY is not in range 0 .. 3." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_CD >= 0) and (VC0_TOTAL_CREDITS_CD <= 2047)) then
      VC0_TOTAL_CREDITS_CD_BINARY <= std_logic_vector(to_unsigned(VC0_TOTAL_CREDITS_CD, 11));
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_CD is not in range 0 .. 2047." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_CH >= 0) and (VC0_TOTAL_CREDITS_CH <= 127)) then
      VC0_TOTAL_CREDITS_CH_BINARY <= std_logic_vector(to_unsigned(VC0_TOTAL_CREDITS_CH, 7));
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_CH is not in range 0 .. 127." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_NPH >= 0) and (VC0_TOTAL_CREDITS_NPH <= 127)) then
      VC0_TOTAL_CREDITS_NPH_BINARY <= std_logic_vector(to_unsigned(VC0_TOTAL_CREDITS_NPH, 7));
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_NPH is not in range 0 .. 127." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_PD >= 0) and (VC0_TOTAL_CREDITS_PD <= 2047)) then
      VC0_TOTAL_CREDITS_PD_BINARY <= std_logic_vector(to_unsigned(VC0_TOTAL_CREDITS_PD, 11));
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_PD is not in range 0 .. 2047." severity error;
    end if;
    if ((VC0_TOTAL_CREDITS_PH >= 0) and (VC0_TOTAL_CREDITS_PH <= 127)) then
      VC0_TOTAL_CREDITS_PH_BINARY <= std_logic_vector(to_unsigned(VC0_TOTAL_CREDITS_PH, 7));
    else
      assert FALSE report "Error : VC0_TOTAL_CREDITS_PH is not in range 0 .. 127." severity error;
    end if;
    if ((VC0_TX_LASTPACKET >= 0) and (VC0_TX_LASTPACKET <= 31)) then
      VC0_TX_LASTPACKET_BINARY <= std_logic_vector(to_unsigned(VC0_TX_LASTPACKET, 5));
    else
      assert FALSE report "Error : VC0_TX_LASTPACKET is not in range 0 .. 31." severity error;
    end if;
    wait;
    end process INIPROC;
--####################################################################
--#####                          OUTPUT                          #####
--####################################################################
    CFGBUSNUMBER <= CFGBUSNUMBER_out;
    CFGCOMMANDBUSMASTERENABLE <= CFGCOMMANDBUSMASTERENABLE_out;
    CFGCOMMANDINTERRUPTDISABLE <= CFGCOMMANDINTERRUPTDISABLE_out;
    CFGCOMMANDIOENABLE <= CFGCOMMANDIOENABLE_out;
    CFGCOMMANDMEMENABLE <= CFGCOMMANDMEMENABLE_out;
    CFGCOMMANDSERREN <= CFGCOMMANDSERREN_out;
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
    CFGDEVICENUMBER <= CFGDEVICENUMBER_out;
    CFGDEVSTATUSCORRERRDETECTED <= CFGDEVSTATUSCORRERRDETECTED_out;
    CFGDEVSTATUSFATALERRDETECTED <= CFGDEVSTATUSFATALERRDETECTED_out;
    CFGDEVSTATUSNONFATALERRDETECTED <= CFGDEVSTATUSNONFATALERRDETECTED_out;
    CFGDEVSTATUSURDETECTED <= CFGDEVSTATUSURDETECTED_out;
    CFGDO <= CFGDO_out;
    CFGERRCPLRDYN <= CFGERRCPLRDYN_out;
    CFGFUNCTIONNUMBER <= CFGFUNCTIONNUMBER_out;
    CFGINTERRUPTDO <= CFGINTERRUPTDO_out;
    CFGINTERRUPTMMENABLE <= CFGINTERRUPTMMENABLE_out;
    CFGINTERRUPTMSIENABLE <= CFGINTERRUPTMSIENABLE_out;
    CFGINTERRUPTRDYN <= CFGINTERRUPTRDYN_out;
    CFGLINKCONTOLRCB <= CFGLINKCONTOLRCB_out;
    CFGLINKCONTROLASPMCONTROL <= CFGLINKCONTROLASPMCONTROL_out;
    CFGLINKCONTROLCOMMONCLOCK <= CFGLINKCONTROLCOMMONCLOCK_out;
    CFGLINKCONTROLEXTENDEDSYNC <= CFGLINKCONTROLEXTENDEDSYNC_out;
    CFGLTSSMSTATE <= CFGLTSSMSTATE_out;
    CFGPCIELINKSTATEN <= CFGPCIELINKSTATEN_out;
    CFGRDWRDONEN <= CFGRDWRDONEN_out;
    CFGTOTURNOFFN <= CFGTOTURNOFFN_out;
    DBGBADDLLPSTATUS <= DBGBADDLLPSTATUS_out;
    DBGBADTLPLCRC <= DBGBADTLPLCRC_out;
    DBGBADTLPSEQNUM <= DBGBADTLPSEQNUM_out;
    DBGBADTLPSTATUS <= DBGBADTLPSTATUS_out;
    DBGDLPROTOCOLSTATUS <= DBGDLPROTOCOLSTATUS_out;
    DBGFCPROTOCOLERRSTATUS <= DBGFCPROTOCOLERRSTATUS_out;
    DBGMLFRMDLENGTH <= DBGMLFRMDLENGTH_out;
    DBGMLFRMDMPS <= DBGMLFRMDMPS_out;
    DBGMLFRMDTCVC <= DBGMLFRMDTCVC_out;
    DBGMLFRMDTLPSTATUS <= DBGMLFRMDTLPSTATUS_out;
    DBGMLFRMDUNRECTYPE <= DBGMLFRMDUNRECTYPE_out;
    DBGPOISTLPSTATUS <= DBGPOISTLPSTATUS_out;
    DBGRCVROVERFLOWSTATUS <= DBGRCVROVERFLOWSTATUS_out;
    DBGREGDETECTEDCORRECTABLE <= DBGREGDETECTEDCORRECTABLE_out;
    DBGREGDETECTEDFATAL <= DBGREGDETECTEDFATAL_out;
    DBGREGDETECTEDNONFATAL <= DBGREGDETECTEDNONFATAL_out;
    DBGREGDETECTEDUNSUPPORTED <= DBGREGDETECTEDUNSUPPORTED_out;
    DBGRPLYROLLOVERSTATUS <= DBGRPLYROLLOVERSTATUS_out;
    DBGRPLYTIMEOUTSTATUS <= DBGRPLYTIMEOUTSTATUS_out;
    DBGURNOBARHIT <= DBGURNOBARHIT_out;
    DBGURPOISCFGWR <= DBGURPOISCFGWR_out;
    DBGURSTATUS <= DBGURSTATUS_out;
    DBGURUNSUPMSG <= DBGURUNSUPMSG_out;
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
    PIPEGTPOWERDOWNA <= PIPEGTPOWERDOWNA_out;
    PIPEGTPOWERDOWNB <= PIPEGTPOWERDOWNB_out;
    PIPEGTTXELECIDLEA <= PIPEGTTXELECIDLEA_out;
    PIPEGTTXELECIDLEB <= PIPEGTTXELECIDLEB_out;
    PIPERXPOLARITYA <= PIPERXPOLARITYA_out;
    PIPERXPOLARITYB <= PIPERXPOLARITYB_out;
    PIPERXRESETA <= PIPERXRESETA_out;
    PIPERXRESETB <= PIPERXRESETB_out;
    PIPETXCHARDISPMODEA <= PIPETXCHARDISPMODEA_out;
    PIPETXCHARDISPMODEB <= PIPETXCHARDISPMODEB_out;
    PIPETXCHARDISPVALA <= PIPETXCHARDISPVALA_out;
    PIPETXCHARDISPVALB <= PIPETXCHARDISPVALB_out;
    PIPETXCHARISKA <= PIPETXCHARISKA_out;
    PIPETXCHARISKB <= PIPETXCHARISKB_out;
    PIPETXDATAA <= PIPETXDATAA_out;
    PIPETXDATAB <= PIPETXDATAB_out;
    PIPETXRCVRDETA <= PIPETXRCVRDETA_out;
    PIPETXRCVRDETB <= PIPETXRCVRDETB_out;
    RECEIVEDHOTRESET <= RECEIVEDHOTRESET_out;
    TRNFCCPLD <= TRNFCCPLD_out;
    TRNFCCPLH <= TRNFCCPLH_out;
    TRNFCNPD <= TRNFCNPD_out;
    TRNFCNPH <= TRNFCNPH_out;
    TRNFCPD <= TRNFCPD_out;
    TRNFCPH <= TRNFCPH_out;
    TRNLNKUPN <= TRNLNKUPN_out;
    TRNRBARHITN <= TRNRBARHITN_out;
    TRNRD <= TRNRD_out;
    TRNREOFN <= TRNREOFN_out;
    TRNRERRFWDN <= TRNRERRFWDN_out;
    TRNRSOFN <= TRNRSOFN_out;
    TRNRSRCDSCN <= TRNRSRCDSCN_out;
    TRNRSRCRDYN <= TRNRSRCRDYN_out;
    TRNTBUFAV <= TRNTBUFAV_out;
    TRNTCFGREQN <= TRNTCFGREQN_out;
    TRNTDSTRDYN <= TRNTDSTRDYN_out;
    TRNTERRDROPN <= TRNTERRDROPN_out;
    USERRSTN <= USERRSTN_out;
  end PCIE_A1_V;
