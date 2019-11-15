-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/SMODEL/GTPA1_DUAL.vhd,v 1.19 2010/06/07 19:02:04 robh Exp $
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
--  /   /                        Multi-Gigabit Tranceiver Port Secure IP
-- /___/   /\      Filename    : GTPA1_DUAL.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
-- Revision:
--       1.0:  08/18/08 - Initial version.
--       1.1:  11/25/08 - Update to include secureip call
--       1.2   12/01/08 - parameter conversion width mismatch
--       1.3   01/22/09 - updates for VCS, NCSIM
--       1.4   01/29/09 - remove commented code
--       1.5   03/12/09 - CR511750 upper case parameter defaults
--       1.6   04/09/09 - CR516873 - yml, rtl update
--       1.7   09/02/09 - CR532550 - yml update
--       1.8:  10/01/09:  CR533370 - yml update
--       1.9:  10/20/09:  CR536553 - RXPRBSERR_LOOPBACK_* type bit not bit_vector
--       1.10: 06/07/10:  CR563488 - yml update


-- End Revision
-------------------------------------------------------

----- CELL GTPA1_DUAL -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity GTPA1_DUAL is
    generic (
      AC_CAP_DIS_0 : boolean := TRUE;
      AC_CAP_DIS_1 : boolean := TRUE;
      ALIGN_COMMA_WORD_0 : integer := 1;
      ALIGN_COMMA_WORD_1 : integer := 1;
      CB2_INH_CC_PERIOD_0 : integer := 8;
      CB2_INH_CC_PERIOD_1 : integer := 8;
      CDR_PH_ADJ_TIME_0 : bit_vector := "01010";
      CDR_PH_ADJ_TIME_1 : bit_vector := "01010";
      CHAN_BOND_1_MAX_SKEW_0 : integer := 7;
      CHAN_BOND_1_MAX_SKEW_1 : integer := 7;
      CHAN_BOND_2_MAX_SKEW_0 : integer := 1;
      CHAN_BOND_2_MAX_SKEW_1 : integer := 1;
      CHAN_BOND_KEEP_ALIGN_0 : boolean := FALSE;
      CHAN_BOND_KEEP_ALIGN_1 : boolean := FALSE;
      CHAN_BOND_SEQ_1_1_0 : bit_vector := "0101111100";
      CHAN_BOND_SEQ_1_1_1 : bit_vector := "0101111100";
      CHAN_BOND_SEQ_1_2_0 : bit_vector := "0001001010";
      CHAN_BOND_SEQ_1_2_1 : bit_vector := "0001001010";
      CHAN_BOND_SEQ_1_3_0 : bit_vector := "0001001010";
      CHAN_BOND_SEQ_1_3_1 : bit_vector := "0001001010";
      CHAN_BOND_SEQ_1_4_0 : bit_vector := "0110111100";
      CHAN_BOND_SEQ_1_4_1 : bit_vector := "0110111100";
      CHAN_BOND_SEQ_1_ENABLE_0 : bit_vector := "1111";
      CHAN_BOND_SEQ_1_ENABLE_1 : bit_vector := "1111";
      CHAN_BOND_SEQ_2_1_0 : bit_vector := "0110111100";
      CHAN_BOND_SEQ_2_1_1 : bit_vector := "0110111100";
      CHAN_BOND_SEQ_2_2_0 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_2_1 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_3_0 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_3_1 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_4_0 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_4_1 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_ENABLE_0 : bit_vector := "1111";
      CHAN_BOND_SEQ_2_ENABLE_1 : bit_vector := "1111";
      CHAN_BOND_SEQ_2_USE_0 : boolean := FALSE;
      CHAN_BOND_SEQ_2_USE_1 : boolean := FALSE;
      CHAN_BOND_SEQ_LEN_0 : integer := 1;
      CHAN_BOND_SEQ_LEN_1 : integer := 1;
      CLK25_DIVIDER_0 : integer := 4;
      CLK25_DIVIDER_1 : integer := 4;
      CLKINDC_B_0 : boolean := TRUE;
      CLKINDC_B_1 : boolean := TRUE;
      CLKRCV_TRST_0 : boolean := TRUE;
      CLKRCV_TRST_1 : boolean := TRUE;
      CLK_CORRECT_USE_0 : boolean := TRUE;
      CLK_CORRECT_USE_1 : boolean := TRUE;
      CLK_COR_ADJ_LEN_0 : integer := 1;
      CLK_COR_ADJ_LEN_1 : integer := 1;
      CLK_COR_DET_LEN_0 : integer := 1;
      CLK_COR_DET_LEN_1 : integer := 1;
      CLK_COR_INSERT_IDLE_FLAG_0 : boolean := FALSE;
      CLK_COR_INSERT_IDLE_FLAG_1 : boolean := FALSE;
      CLK_COR_KEEP_IDLE_0 : boolean := FALSE;
      CLK_COR_KEEP_IDLE_1 : boolean := FALSE;
      CLK_COR_MAX_LAT_0 : integer := 20;
      CLK_COR_MAX_LAT_1 : integer := 20;
      CLK_COR_MIN_LAT_0 : integer := 18;
      CLK_COR_MIN_LAT_1 : integer := 18;
      CLK_COR_PRECEDENCE_0 : boolean := TRUE;
      CLK_COR_PRECEDENCE_1 : boolean := TRUE;
      CLK_COR_REPEAT_WAIT_0 : integer := 0;
      CLK_COR_REPEAT_WAIT_1 : integer := 0;
      CLK_COR_SEQ_1_1_0 : bit_vector := "0100011100";
      CLK_COR_SEQ_1_1_1 : bit_vector := "0100011100";
      CLK_COR_SEQ_1_2_0 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_2_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_3_0 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_3_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_4_0 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_4_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_ENABLE_0 : bit_vector := "1111";
      CLK_COR_SEQ_1_ENABLE_1 : bit_vector := "1111";
      CLK_COR_SEQ_2_1_0 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_1_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_2_0 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_2_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_3_0 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_3_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_4_0 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_4_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_ENABLE_0 : bit_vector := "1111";
      CLK_COR_SEQ_2_ENABLE_1 : bit_vector := "1111";
      CLK_COR_SEQ_2_USE_0 : boolean := FALSE;
      CLK_COR_SEQ_2_USE_1 : boolean := FALSE;
      CLK_OUT_GTP_SEL_0 : string := "REFCLKPLL0";
      CLK_OUT_GTP_SEL_1 : string := "REFCLKPLL1";
      CM_TRIM_0 : bit_vector := "00";
      CM_TRIM_1 : bit_vector := "00";
      COMMA_10B_ENABLE_0 : bit_vector := "1111111111";
      COMMA_10B_ENABLE_1 : bit_vector := "1111111111";
      COM_BURST_VAL_0 : bit_vector := "1111";
      COM_BURST_VAL_1 : bit_vector := "1111";
      DEC_MCOMMA_DETECT_0 : boolean := TRUE;
      DEC_MCOMMA_DETECT_1 : boolean := TRUE;
      DEC_PCOMMA_DETECT_0 : boolean := TRUE;
      DEC_PCOMMA_DETECT_1 : boolean := TRUE;
      DEC_VALID_COMMA_ONLY_0 : boolean := TRUE;
      DEC_VALID_COMMA_ONLY_1 : boolean := TRUE;
      GTP_CFG_PWRUP_0 : boolean := TRUE;
      GTP_CFG_PWRUP_1 : boolean := TRUE;
      MCOMMA_10B_VALUE_0 : bit_vector := "1010000011";
      MCOMMA_10B_VALUE_1 : bit_vector := "1010000011";
      MCOMMA_DETECT_0 : boolean := TRUE;
      MCOMMA_DETECT_1 : boolean := TRUE;
      OOBDETECT_THRESHOLD_0 : bit_vector := "110";
      OOBDETECT_THRESHOLD_1 : bit_vector := "110";
      OOB_CLK_DIVIDER_0 : integer := 4;
      OOB_CLK_DIVIDER_1 : integer := 4;
      PCI_EXPRESS_MODE_0 : boolean := FALSE;
      PCI_EXPRESS_MODE_1 : boolean := FALSE;
      PCOMMA_10B_VALUE_0 : bit_vector := "0101111100";
      PCOMMA_10B_VALUE_1 : bit_vector := "0101111100";
      PCOMMA_DETECT_0 : boolean := TRUE;
      PCOMMA_DETECT_1 : boolean := TRUE;
      PLLLKDET_CFG_0 : bit_vector := "101";
      PLLLKDET_CFG_1 : bit_vector := "101";
      PLL_COM_CFG_0 : bit_vector := X"21680A";
      PLL_COM_CFG_1 : bit_vector := X"21680A";
      PLL_CP_CFG_0 : bit_vector := X"00";
      PLL_CP_CFG_1 : bit_vector := X"00";
      PLL_DIVSEL_FB_0 : integer := 5;
      PLL_DIVSEL_FB_1 : integer := 5;
      PLL_DIVSEL_REF_0 : integer := 2;
      PLL_DIVSEL_REF_1 : integer := 2;
      PLL_RXDIVSEL_OUT_0 : integer := 1;
      PLL_RXDIVSEL_OUT_1 : integer := 1;
      PLL_SATA_0 : boolean := FALSE;
      PLL_SATA_1 : boolean := FALSE;
      PLL_SOURCE_0 : string := "PLL0";
      PLL_SOURCE_1 : string := "PLL0";
      PLL_TXDIVSEL_OUT_0 : integer := 1;
      PLL_TXDIVSEL_OUT_1 : integer := 1;
      PMA_CDR_SCAN_0 : bit_vector := X"6404040";
      PMA_CDR_SCAN_1 : bit_vector := X"6404040";
      PMA_COM_CFG_EAST : bit_vector := X"000008000";
      PMA_COM_CFG_WEST : bit_vector := X"00000A000";
      PMA_RXSYNC_CFG_0 : bit_vector := X"00";
      PMA_RXSYNC_CFG_1 : bit_vector := X"00";
      PMA_RX_CFG_0 : bit_vector := X"05CE048";
      PMA_RX_CFG_1 : bit_vector := X"05CE048";
      PMA_TX_CFG_0 : bit_vector := X"00082";
      PMA_TX_CFG_1 : bit_vector := X"00082";
      RCV_TERM_GND_0 : boolean := FALSE;
      RCV_TERM_GND_1 : boolean := FALSE;
      RCV_TERM_VTTRX_0 : boolean := TRUE;
      RCV_TERM_VTTRX_1 : boolean := TRUE;
      RXEQ_CFG_0 : bit_vector := "01111011";
      RXEQ_CFG_1 : bit_vector := "01111011";
      RXPRBSERR_LOOPBACK_0 : bit := '0';
      RXPRBSERR_LOOPBACK_1 : bit := '0';
      RX_BUFFER_USE_0 : boolean := TRUE;
      RX_BUFFER_USE_1 : boolean := TRUE;
      RX_DECODE_SEQ_MATCH_0 : boolean := TRUE;
      RX_DECODE_SEQ_MATCH_1 : boolean := TRUE;
      RX_EN_IDLE_HOLD_CDR_0 : boolean := FALSE;
      RX_EN_IDLE_HOLD_CDR_1 : boolean := FALSE;
      RX_EN_IDLE_RESET_BUF_0 : boolean := TRUE;
      RX_EN_IDLE_RESET_BUF_1 : boolean := TRUE;
      RX_EN_IDLE_RESET_FR_0 : boolean := TRUE;
      RX_EN_IDLE_RESET_FR_1 : boolean := TRUE;
      RX_EN_IDLE_RESET_PH_0 : boolean := TRUE;
      RX_EN_IDLE_RESET_PH_1 : boolean := TRUE;
      RX_EN_MODE_RESET_BUF_0 : boolean := TRUE;
      RX_EN_MODE_RESET_BUF_1 : boolean := TRUE;
      RX_IDLE_HI_CNT_0 : bit_vector := "1000";
      RX_IDLE_HI_CNT_1 : bit_vector := "1000";
      RX_IDLE_LO_CNT_0 : bit_vector := "0000";
      RX_IDLE_LO_CNT_1 : bit_vector := "0000";
      RX_LOSS_OF_SYNC_FSM_0 : boolean := FALSE;
      RX_LOSS_OF_SYNC_FSM_1 : boolean := FALSE;
      RX_LOS_INVALID_INCR_0 : integer := 1;
      RX_LOS_INVALID_INCR_1 : integer := 1;
      RX_LOS_THRESHOLD_0 : integer := 4;
      RX_LOS_THRESHOLD_1 : integer := 4;
      RX_SLIDE_MODE_0 : string := "PCS";
      RX_SLIDE_MODE_1 : string := "PCS";
      RX_STATUS_FMT_0 : string := "PCIE";
      RX_STATUS_FMT_1 : string := "PCIE";
      RX_XCLK_SEL_0 : string := "RXREC";
      RX_XCLK_SEL_1 : string := "RXREC";
      SATA_BURST_VAL_0 : bit_vector := "100";
      SATA_BURST_VAL_1 : bit_vector := "100";
      SATA_IDLE_VAL_0 : bit_vector := "011";
      SATA_IDLE_VAL_1 : bit_vector := "011";
      SATA_MAX_BURST_0 : integer := 7;
      SATA_MAX_BURST_1 : integer := 7;
      SATA_MAX_INIT_0 : integer := 22;
      SATA_MAX_INIT_1 : integer := 22;
      SATA_MAX_WAKE_0 : integer := 7;
      SATA_MAX_WAKE_1 : integer := 7;
      SATA_MIN_BURST_0 : integer := 4;
      SATA_MIN_BURST_1 : integer := 4;
      SATA_MIN_INIT_0 : integer := 12;
      SATA_MIN_INIT_1 : integer := 12;
      SATA_MIN_WAKE_0 : integer := 4;
      SATA_MIN_WAKE_1 : integer := 4;
      SIM_GTPRESET_SPEEDUP : integer := 0;
      SIM_RECEIVER_DETECT_PASS : boolean := FALSE;
      SIM_REFCLK0_SOURCE : bit_vector := "000";
      SIM_REFCLK1_SOURCE : bit_vector := "000";
      SIM_TX_ELEC_IDLE_LEVEL : string := "X";
      SIM_VERSION : string := "2.0";
      TERMINATION_CTRL_0 : bit_vector := "10100";
      TERMINATION_CTRL_1 : bit_vector := "10100";
      TERMINATION_OVRD_0 : boolean := FALSE;
      TERMINATION_OVRD_1 : boolean := FALSE;
      TRANS_TIME_FROM_P2_0 : bit_vector := X"03C";
      TRANS_TIME_FROM_P2_1 : bit_vector := X"03C";
      TRANS_TIME_NON_P2_0 : bit_vector := X"19";
      TRANS_TIME_NON_P2_1 : bit_vector := X"19";
      TRANS_TIME_TO_P2_0 : bit_vector := X"064";
      TRANS_TIME_TO_P2_1 : bit_vector := X"064";
      TST_ATTR_0 : bit_vector := X"00000000";
      TST_ATTR_1 : bit_vector := X"00000000";
      TXRX_INVERT_0 : bit_vector := "011";
      TXRX_INVERT_1 : bit_vector := "011";
      TX_BUFFER_USE_0 : boolean := FALSE;
      TX_BUFFER_USE_1 : boolean := FALSE;
      TX_DETECT_RX_CFG_0 : bit_vector := X"1832";
      TX_DETECT_RX_CFG_1 : bit_vector := X"1832";
      TX_IDLE_DELAY_0 : bit_vector := "011";
      TX_IDLE_DELAY_1 : bit_vector := "011";
      TX_TDCC_CFG_0 : bit_vector := "00";
      TX_TDCC_CFG_1 : bit_vector := "00";
      TX_XCLK_SEL_0 : string := "TXUSR";
      TX_XCLK_SEL_1 : string := "TXUSR"
    );

    port (
      DRDY                 : out std_ulogic;
      DRPDO                : out std_logic_vector(15 downto 0);
      GTPCLKFBEAST         : out std_logic_vector(1 downto 0);
      GTPCLKFBWEST         : out std_logic_vector(1 downto 0);
      GTPCLKOUT0           : out std_logic_vector(1 downto 0);
      GTPCLKOUT1           : out std_logic_vector(1 downto 0);
      PHYSTATUS0           : out std_ulogic;
      PHYSTATUS1           : out std_ulogic;
      PLLLKDET0            : out std_ulogic;
      PLLLKDET1            : out std_ulogic;
      RCALOUTEAST          : out std_logic_vector(4 downto 0);
      RCALOUTWEST          : out std_logic_vector(4 downto 0);
      REFCLKOUT0           : out std_ulogic;
      REFCLKOUT1           : out std_ulogic;
      REFCLKPLL0           : out std_ulogic;
      REFCLKPLL1           : out std_ulogic;
      RESETDONE0           : out std_ulogic;
      RESETDONE1           : out std_ulogic;
      RXBUFSTATUS0         : out std_logic_vector(2 downto 0);
      RXBUFSTATUS1         : out std_logic_vector(2 downto 0);
      RXBYTEISALIGNED0     : out std_ulogic;
      RXBYTEISALIGNED1     : out std_ulogic;
      RXBYTEREALIGN0       : out std_ulogic;
      RXBYTEREALIGN1       : out std_ulogic;
      RXCHANBONDSEQ0       : out std_ulogic;
      RXCHANBONDSEQ1       : out std_ulogic;
      RXCHANISALIGNED0     : out std_ulogic;
      RXCHANISALIGNED1     : out std_ulogic;
      RXCHANREALIGN0       : out std_ulogic;
      RXCHANREALIGN1       : out std_ulogic;
      RXCHARISCOMMA0       : out std_logic_vector(3 downto 0);
      RXCHARISCOMMA1       : out std_logic_vector(3 downto 0);
      RXCHARISK0           : out std_logic_vector(3 downto 0);
      RXCHARISK1           : out std_logic_vector(3 downto 0);
      RXCHBONDO            : out std_logic_vector(2 downto 0);
      RXCLKCORCNT0         : out std_logic_vector(2 downto 0);
      RXCLKCORCNT1         : out std_logic_vector(2 downto 0);
      RXCOMMADET0          : out std_ulogic;
      RXCOMMADET1          : out std_ulogic;
      RXDATA0              : out std_logic_vector(31 downto 0);
      RXDATA1              : out std_logic_vector(31 downto 0);
      RXDISPERR0           : out std_logic_vector(3 downto 0);
      RXDISPERR1           : out std_logic_vector(3 downto 0);
      RXELECIDLE0          : out std_ulogic;
      RXELECIDLE1          : out std_ulogic;
      RXLOSSOFSYNC0        : out std_logic_vector(1 downto 0);
      RXLOSSOFSYNC1        : out std_logic_vector(1 downto 0);
      RXNOTINTABLE0        : out std_logic_vector(3 downto 0);
      RXNOTINTABLE1        : out std_logic_vector(3 downto 0);
      RXPRBSERR0           : out std_ulogic;
      RXPRBSERR1           : out std_ulogic;
      RXRECCLK0            : out std_ulogic;
      RXRECCLK1            : out std_ulogic;
      RXRUNDISP0           : out std_logic_vector(3 downto 0);
      RXRUNDISP1           : out std_logic_vector(3 downto 0);
      RXSTATUS0            : out std_logic_vector(2 downto 0);
      RXSTATUS1            : out std_logic_vector(2 downto 0);
      RXVALID0             : out std_ulogic;
      RXVALID1             : out std_ulogic;
      TSTOUT0              : out std_logic_vector(4 downto 0);
      TSTOUT1              : out std_logic_vector(4 downto 0);
      TXBUFSTATUS0         : out std_logic_vector(1 downto 0);
      TXBUFSTATUS1         : out std_logic_vector(1 downto 0);
      TXKERR0              : out std_logic_vector(3 downto 0);
      TXKERR1              : out std_logic_vector(3 downto 0);
      TXN0                 : out std_ulogic;
      TXN1                 : out std_ulogic;
      TXOUTCLK0            : out std_ulogic;
      TXOUTCLK1            : out std_ulogic;
      TXP0                 : out std_ulogic;
      TXP1                 : out std_ulogic;
      TXRUNDISP0           : out std_logic_vector(3 downto 0);
      TXRUNDISP1           : out std_logic_vector(3 downto 0);
      CLK00                : in std_ulogic;
      CLK01                : in std_ulogic;
      CLK10                : in std_ulogic;
      CLK11                : in std_ulogic;
      CLKINEAST0           : in std_ulogic;
      CLKINEAST1           : in std_ulogic;
      CLKINWEST0           : in std_ulogic;
      CLKINWEST1           : in std_ulogic;
      DADDR                : in std_logic_vector(7 downto 0);
      DCLK                 : in std_ulogic;
      DEN                  : in std_ulogic;
      DI                   : in std_logic_vector(15 downto 0);
      DWE                  : in std_ulogic;
      GATERXELECIDLE0      : in std_ulogic;
      GATERXELECIDLE1      : in std_ulogic;
      GCLK00               : in std_ulogic;
      GCLK01               : in std_ulogic;
      GCLK10               : in std_ulogic;
      GCLK11               : in std_ulogic;
      GTPCLKFBSEL0EAST     : in std_logic_vector(1 downto 0);
      GTPCLKFBSEL0WEST     : in std_logic_vector(1 downto 0);
      GTPCLKFBSEL1EAST     : in std_logic_vector(1 downto 0);
      GTPCLKFBSEL1WEST     : in std_logic_vector(1 downto 0);
      GTPRESET0            : in std_ulogic;
      GTPRESET1            : in std_ulogic;
      GTPTEST0             : in std_logic_vector(7 downto 0);
      GTPTEST1             : in std_logic_vector(7 downto 0);
      IGNORESIGDET0        : in std_ulogic;
      IGNORESIGDET1        : in std_ulogic;
      INTDATAWIDTH0        : in std_ulogic;
      INTDATAWIDTH1        : in std_ulogic;
      LOOPBACK0            : in std_logic_vector(2 downto 0);
      LOOPBACK1            : in std_logic_vector(2 downto 0);
      PLLCLK00             : in std_ulogic;
      PLLCLK01             : in std_ulogic;
      PLLCLK10             : in std_ulogic;
      PLLCLK11             : in std_ulogic;
      PLLLKDETEN0          : in std_ulogic;
      PLLLKDETEN1          : in std_ulogic;
      PLLPOWERDOWN0        : in std_ulogic;
      PLLPOWERDOWN1        : in std_ulogic;
      PRBSCNTRESET0        : in std_ulogic;
      PRBSCNTRESET1        : in std_ulogic;
      RCALINEAST           : in std_logic_vector(4 downto 0);
      RCALINWEST           : in std_logic_vector(4 downto 0);
      REFCLKPWRDNB0        : in std_ulogic;
      REFCLKPWRDNB1        : in std_ulogic;
      REFSELDYPLL0         : in std_logic_vector(2 downto 0);
      REFSELDYPLL1         : in std_logic_vector(2 downto 0);
      RXBUFRESET0          : in std_ulogic;
      RXBUFRESET1          : in std_ulogic;
      RXCDRRESET0          : in std_ulogic;
      RXCDRRESET1          : in std_ulogic;
      RXCHBONDI            : in std_logic_vector(2 downto 0);
      RXCHBONDMASTER0      : in std_ulogic;
      RXCHBONDMASTER1      : in std_ulogic;
      RXCHBONDSLAVE0       : in std_ulogic;
      RXCHBONDSLAVE1       : in std_ulogic;
      RXCOMMADETUSE0       : in std_ulogic;
      RXCOMMADETUSE1       : in std_ulogic;
      RXDATAWIDTH0         : in std_logic_vector(1 downto 0);
      RXDATAWIDTH1         : in std_logic_vector(1 downto 0);
      RXDEC8B10BUSE0       : in std_ulogic;
      RXDEC8B10BUSE1       : in std_ulogic;
      RXENCHANSYNC0        : in std_ulogic;
      RXENCHANSYNC1        : in std_ulogic;
      RXENMCOMMAALIGN0     : in std_ulogic;
      RXENMCOMMAALIGN1     : in std_ulogic;
      RXENPCOMMAALIGN0     : in std_ulogic;
      RXENPCOMMAALIGN1     : in std_ulogic;
      RXENPMAPHASEALIGN0   : in std_ulogic;
      RXENPMAPHASEALIGN1   : in std_ulogic;
      RXENPRBSTST0         : in std_logic_vector(2 downto 0);
      RXENPRBSTST1         : in std_logic_vector(2 downto 0);
      RXEQMIX0             : in std_logic_vector(1 downto 0);
      RXEQMIX1             : in std_logic_vector(1 downto 0);
      RXN0                 : in std_ulogic;
      RXN1                 : in std_ulogic;
      RXP0                 : in std_ulogic;
      RXP1                 : in std_ulogic;
      RXPMASETPHASE0       : in std_ulogic;
      RXPMASETPHASE1       : in std_ulogic;
      RXPOLARITY0          : in std_ulogic;
      RXPOLARITY1          : in std_ulogic;
      RXPOWERDOWN0         : in std_logic_vector(1 downto 0);
      RXPOWERDOWN1         : in std_logic_vector(1 downto 0);
      RXRESET0             : in std_ulogic;
      RXRESET1             : in std_ulogic;
      RXSLIDE0             : in std_ulogic;
      RXSLIDE1             : in std_ulogic;
      RXUSRCLK0            : in std_ulogic;
      RXUSRCLK1            : in std_ulogic;
      RXUSRCLK20           : in std_ulogic;
      RXUSRCLK21           : in std_ulogic;
      TSTCLK0              : in std_ulogic;
      TSTCLK1              : in std_ulogic;
      TSTIN0               : in std_logic_vector(11 downto 0);
      TSTIN1               : in std_logic_vector(11 downto 0);
      TXBUFDIFFCTRL0       : in std_logic_vector(2 downto 0);
      TXBUFDIFFCTRL1       : in std_logic_vector(2 downto 0);
      TXBYPASS8B10B0       : in std_logic_vector(3 downto 0);
      TXBYPASS8B10B1       : in std_logic_vector(3 downto 0);
      TXCHARDISPMODE0      : in std_logic_vector(3 downto 0);
      TXCHARDISPMODE1      : in std_logic_vector(3 downto 0);
      TXCHARDISPVAL0       : in std_logic_vector(3 downto 0);
      TXCHARDISPVAL1       : in std_logic_vector(3 downto 0);
      TXCHARISK0           : in std_logic_vector(3 downto 0);
      TXCHARISK1           : in std_logic_vector(3 downto 0);
      TXCOMSTART0          : in std_ulogic;
      TXCOMSTART1          : in std_ulogic;
      TXCOMTYPE0           : in std_ulogic;
      TXCOMTYPE1           : in std_ulogic;
      TXDATA0              : in std_logic_vector(31 downto 0);
      TXDATA1              : in std_logic_vector(31 downto 0);
      TXDATAWIDTH0         : in std_logic_vector(1 downto 0);
      TXDATAWIDTH1         : in std_logic_vector(1 downto 0);
      TXDETECTRX0          : in std_ulogic;
      TXDETECTRX1          : in std_ulogic;
      TXDIFFCTRL0          : in std_logic_vector(3 downto 0);
      TXDIFFCTRL1          : in std_logic_vector(3 downto 0);
      TXELECIDLE0          : in std_ulogic;
      TXELECIDLE1          : in std_ulogic;
      TXENC8B10BUSE0       : in std_ulogic;
      TXENC8B10BUSE1       : in std_ulogic;
      TXENPMAPHASEALIGN0   : in std_ulogic;
      TXENPMAPHASEALIGN1   : in std_ulogic;
      TXENPRBSTST0         : in std_logic_vector(2 downto 0);
      TXENPRBSTST1         : in std_logic_vector(2 downto 0);
      TXINHIBIT0           : in std_ulogic;
      TXINHIBIT1           : in std_ulogic;
      TXPDOWNASYNCH0       : in std_ulogic;
      TXPDOWNASYNCH1       : in std_ulogic;
      TXPMASETPHASE0       : in std_ulogic;
      TXPMASETPHASE1       : in std_ulogic;
      TXPOLARITY0          : in std_ulogic;
      TXPOLARITY1          : in std_ulogic;
      TXPOWERDOWN0         : in std_logic_vector(1 downto 0);
      TXPOWERDOWN1         : in std_logic_vector(1 downto 0);
      TXPRBSFORCEERR0      : in std_ulogic;
      TXPRBSFORCEERR1      : in std_ulogic;
      TXPREEMPHASIS0       : in std_logic_vector(2 downto 0);
      TXPREEMPHASIS1       : in std_logic_vector(2 downto 0);
      TXRESET0             : in std_ulogic;
      TXRESET1             : in std_ulogic;
      TXUSRCLK0            : in std_ulogic;
      TXUSRCLK1            : in std_ulogic;
      TXUSRCLK20           : in std_ulogic;
      TXUSRCLK21           : in std_ulogic;
      USRCODEERR0          : in std_ulogic;
      USRCODEERR1          : in std_ulogic      
    );
  end GTPA1_DUAL;

  architecture GTPA1_DUAL_V of GTPA1_DUAL is
    component GTPA1_DUAL_WRAP
      generic (
        AC_CAP_DIS_0 : string;
        AC_CAP_DIS_1 : string;
        ALIGN_COMMA_WORD_0 : integer;
        ALIGN_COMMA_WORD_1 : integer;
        CB2_INH_CC_PERIOD_0 : integer;
        CB2_INH_CC_PERIOD_1 : integer;
        CDR_PH_ADJ_TIME_0 : string;
        CDR_PH_ADJ_TIME_1 : string;
        CHAN_BOND_1_MAX_SKEW_0 : integer;
        CHAN_BOND_1_MAX_SKEW_1 : integer;
        CHAN_BOND_2_MAX_SKEW_0 : integer;
        CHAN_BOND_2_MAX_SKEW_1 : integer;
        CHAN_BOND_KEEP_ALIGN_0 : string;
        CHAN_BOND_KEEP_ALIGN_1 : string;
        CHAN_BOND_SEQ_1_1_0 : string;
        CHAN_BOND_SEQ_1_1_1 : string;
        CHAN_BOND_SEQ_1_2_0 : string;
        CHAN_BOND_SEQ_1_2_1 : string;
        CHAN_BOND_SEQ_1_3_0 : string;
        CHAN_BOND_SEQ_1_3_1 : string;
        CHAN_BOND_SEQ_1_4_0 : string;
        CHAN_BOND_SEQ_1_4_1 : string;
        CHAN_BOND_SEQ_1_ENABLE_0 : string;
        CHAN_BOND_SEQ_1_ENABLE_1 : string;
        CHAN_BOND_SEQ_2_1_0 : string;
        CHAN_BOND_SEQ_2_1_1 : string;
        CHAN_BOND_SEQ_2_2_0 : string;
        CHAN_BOND_SEQ_2_2_1 : string;
        CHAN_BOND_SEQ_2_3_0 : string;
        CHAN_BOND_SEQ_2_3_1 : string;
        CHAN_BOND_SEQ_2_4_0 : string;
        CHAN_BOND_SEQ_2_4_1 : string;
        CHAN_BOND_SEQ_2_ENABLE_0 : string;
        CHAN_BOND_SEQ_2_ENABLE_1 : string;
        CHAN_BOND_SEQ_2_USE_0 : string;
        CHAN_BOND_SEQ_2_USE_1 : string;
        CHAN_BOND_SEQ_LEN_0 : integer;
        CHAN_BOND_SEQ_LEN_1 : integer;
        CLK25_DIVIDER_0 : integer;
        CLK25_DIVIDER_1 : integer;
        CLKINDC_B_0 : string;
        CLKINDC_B_1 : string;
        CLKRCV_TRST_0 : string;
        CLKRCV_TRST_1 : string;
        CLK_CORRECT_USE_0 : string;
        CLK_CORRECT_USE_1 : string;
        CLK_COR_ADJ_LEN_0 : integer;
        CLK_COR_ADJ_LEN_1 : integer;
        CLK_COR_DET_LEN_0 : integer;
        CLK_COR_DET_LEN_1 : integer;
        CLK_COR_INSERT_IDLE_FLAG_0 : string;
        CLK_COR_INSERT_IDLE_FLAG_1 : string;
        CLK_COR_KEEP_IDLE_0 : string;
        CLK_COR_KEEP_IDLE_1 : string;
        CLK_COR_MAX_LAT_0 : integer;
        CLK_COR_MAX_LAT_1 : integer;
        CLK_COR_MIN_LAT_0 : integer;
        CLK_COR_MIN_LAT_1 : integer;
        CLK_COR_PRECEDENCE_0 : string;
        CLK_COR_PRECEDENCE_1 : string;
        CLK_COR_REPEAT_WAIT_0 : integer;
        CLK_COR_REPEAT_WAIT_1 : integer;
        CLK_COR_SEQ_1_1_0 : string;
        CLK_COR_SEQ_1_1_1 : string;
        CLK_COR_SEQ_1_2_0 : string;
        CLK_COR_SEQ_1_2_1 : string;
        CLK_COR_SEQ_1_3_0 : string;
        CLK_COR_SEQ_1_3_1 : string;
        CLK_COR_SEQ_1_4_0 : string;
        CLK_COR_SEQ_1_4_1 : string;
        CLK_COR_SEQ_1_ENABLE_0 : string;
        CLK_COR_SEQ_1_ENABLE_1 : string;
        CLK_COR_SEQ_2_1_0 : string;
        CLK_COR_SEQ_2_1_1 : string;
        CLK_COR_SEQ_2_2_0 : string;
        CLK_COR_SEQ_2_2_1 : string;
        CLK_COR_SEQ_2_3_0 : string;
        CLK_COR_SEQ_2_3_1 : string;
        CLK_COR_SEQ_2_4_0 : string;
        CLK_COR_SEQ_2_4_1 : string;
        CLK_COR_SEQ_2_ENABLE_0 : string;
        CLK_COR_SEQ_2_ENABLE_1 : string;
        CLK_COR_SEQ_2_USE_0 : string;
        CLK_COR_SEQ_2_USE_1 : string;
        CLK_OUT_GTP_SEL_0 : string;
        CLK_OUT_GTP_SEL_1 : string;
        CM_TRIM_0 : string;
        CM_TRIM_1 : string;
        COMMA_10B_ENABLE_0 : string;
        COMMA_10B_ENABLE_1 : string;
        COM_BURST_VAL_0 : string;
        COM_BURST_VAL_1 : string;
        DEC_MCOMMA_DETECT_0 : string;
        DEC_MCOMMA_DETECT_1 : string;
        DEC_PCOMMA_DETECT_0 : string;
        DEC_PCOMMA_DETECT_1 : string;
        DEC_VALID_COMMA_ONLY_0 : string;
        DEC_VALID_COMMA_ONLY_1 : string;
        GTP_CFG_PWRUP_0 : string;
        GTP_CFG_PWRUP_1 : string;
        MCOMMA_10B_VALUE_0 : string;
        MCOMMA_10B_VALUE_1 : string;
        MCOMMA_DETECT_0 : string;
        MCOMMA_DETECT_1 : string;
        OOBDETECT_THRESHOLD_0 : string;
        OOBDETECT_THRESHOLD_1 : string;
        OOB_CLK_DIVIDER_0 : integer;
        OOB_CLK_DIVIDER_1 : integer;
        PCI_EXPRESS_MODE_0 : string;
        PCI_EXPRESS_MODE_1 : string;
        PCOMMA_10B_VALUE_0 : string;
        PCOMMA_10B_VALUE_1 : string;
        PCOMMA_DETECT_0 : string;
        PCOMMA_DETECT_1 : string;
        PLLLKDET_CFG_0 : string;
        PLLLKDET_CFG_1 : string;
        PLL_COM_CFG_0 : string;
        PLL_COM_CFG_1 : string;
        PLL_CP_CFG_0 : string;
        PLL_CP_CFG_1 : string;
        PLL_DIVSEL_FB_0 : integer;
        PLL_DIVSEL_FB_1 : integer;
        PLL_DIVSEL_REF_0 : integer;
        PLL_DIVSEL_REF_1 : integer;
        PLL_RXDIVSEL_OUT_0 : integer;
        PLL_RXDIVSEL_OUT_1 : integer;
        PLL_SATA_0 : string;
        PLL_SATA_1 : string;
        PLL_SOURCE_0 : string;
        PLL_SOURCE_1 : string;
        PLL_TXDIVSEL_OUT_0 : integer;
        PLL_TXDIVSEL_OUT_1 : integer;
        PMA_CDR_SCAN_0 : string;
        PMA_CDR_SCAN_1 : string;
        PMA_COM_CFG_EAST : string;
        PMA_COM_CFG_WEST : string;
        PMA_RXSYNC_CFG_0 : string;
        PMA_RXSYNC_CFG_1 : string;
        PMA_RX_CFG_0 : string;
        PMA_RX_CFG_1 : string;
        PMA_TX_CFG_0 : string;
        PMA_TX_CFG_1 : string;
        RCV_TERM_GND_0 : string;
        RCV_TERM_GND_1 : string;
        RCV_TERM_VTTRX_0 : string;
        RCV_TERM_VTTRX_1 : string;
        RXEQ_CFG_0 : string;
        RXEQ_CFG_1 : string;
        RXPRBSERR_LOOPBACK_0 : string;
        RXPRBSERR_LOOPBACK_1 : string;
        RX_BUFFER_USE_0 : string;
        RX_BUFFER_USE_1 : string;
        RX_DECODE_SEQ_MATCH_0 : string;
        RX_DECODE_SEQ_MATCH_1 : string;
        RX_EN_IDLE_HOLD_CDR_0 : string;
        RX_EN_IDLE_HOLD_CDR_1 : string;
        RX_EN_IDLE_RESET_BUF_0 : string;
        RX_EN_IDLE_RESET_BUF_1 : string;
        RX_EN_IDLE_RESET_FR_0 : string;
        RX_EN_IDLE_RESET_FR_1 : string;
        RX_EN_IDLE_RESET_PH_0 : string;
        RX_EN_IDLE_RESET_PH_1 : string;
        RX_EN_MODE_RESET_BUF_0 : string;
        RX_EN_MODE_RESET_BUF_1 : string;
        RX_IDLE_HI_CNT_0 : string;
        RX_IDLE_HI_CNT_1 : string;
        RX_IDLE_LO_CNT_0 : string;
        RX_IDLE_LO_CNT_1 : string;
        RX_LOSS_OF_SYNC_FSM_0 : string;
        RX_LOSS_OF_SYNC_FSM_1 : string;
        RX_LOS_INVALID_INCR_0 : integer;
        RX_LOS_INVALID_INCR_1 : integer;
        RX_LOS_THRESHOLD_0 : integer;
        RX_LOS_THRESHOLD_1 : integer;
        RX_SLIDE_MODE_0 : string;
        RX_SLIDE_MODE_1 : string;
        RX_STATUS_FMT_0 : string;
        RX_STATUS_FMT_1 : string;
        RX_XCLK_SEL_0 : string;
        RX_XCLK_SEL_1 : string;
        SATA_BURST_VAL_0 : string;
        SATA_BURST_VAL_1 : string;
        SATA_IDLE_VAL_0 : string;
        SATA_IDLE_VAL_1 : string;
        SATA_MAX_BURST_0 : integer;
        SATA_MAX_BURST_1 : integer;
        SATA_MAX_INIT_0 : integer;
        SATA_MAX_INIT_1 : integer;
        SATA_MAX_WAKE_0 : integer;
        SATA_MAX_WAKE_1 : integer;
        SATA_MIN_BURST_0 : integer;
        SATA_MIN_BURST_1 : integer;
        SATA_MIN_INIT_0 : integer;
        SATA_MIN_INIT_1 : integer;
        SATA_MIN_WAKE_0 : integer;
        SATA_MIN_WAKE_1 : integer;
        SIM_GTPRESET_SPEEDUP : integer;
        SIM_RECEIVER_DETECT_PASS : string;
        SIM_REFCLK0_SOURCE : string;
        SIM_REFCLK1_SOURCE : string;
        SIM_TX_ELEC_IDLE_LEVEL : string;
        SIM_VERSION : string;
        TERMINATION_CTRL_0 : string;
        TERMINATION_CTRL_1 : string;
        TERMINATION_OVRD_0 : string;
        TERMINATION_OVRD_1 : string;
        TRANS_TIME_FROM_P2_0 : string;
        TRANS_TIME_FROM_P2_1 : string;
        TRANS_TIME_NON_P2_0 : string;
        TRANS_TIME_NON_P2_1 : string;
        TRANS_TIME_TO_P2_0 : string;
        TRANS_TIME_TO_P2_1 : string;
        TST_ATTR_0 : string;
        TST_ATTR_1 : string;
        TXRX_INVERT_0 : string;
        TXRX_INVERT_1 : string;
        TX_BUFFER_USE_0 : string;
        TX_BUFFER_USE_1 : string;
        TX_DETECT_RX_CFG_0 : string;
        TX_DETECT_RX_CFG_1 : string;
        TX_IDLE_DELAY_0 : string;
        TX_IDLE_DELAY_1 : string;
        TX_TDCC_CFG_0 : string;
        TX_TDCC_CFG_1 : string;
        TX_XCLK_SEL_0 : string;
        TX_XCLK_SEL_1 : string        
      );
      
      port (
        DRDY                 : out std_ulogic;
        DRPDO                : out std_logic_vector(15 downto 0);
        GTPCLKFBEAST         : out std_logic_vector(1 downto 0);
        GTPCLKFBWEST         : out std_logic_vector(1 downto 0);
        GTPCLKOUT0           : out std_logic_vector(1 downto 0);
        GTPCLKOUT1           : out std_logic_vector(1 downto 0);
        PHYSTATUS0           : out std_ulogic;
        PHYSTATUS1           : out std_ulogic;
        PLLLKDET0            : out std_ulogic;
        PLLLKDET1            : out std_ulogic;
        RCALOUTEAST          : out std_logic_vector(4 downto 0);
        RCALOUTWEST          : out std_logic_vector(4 downto 0);
        REFCLKOUT0           : out std_ulogic;
        REFCLKOUT1           : out std_ulogic;
        REFCLKPLL0           : out std_ulogic;
        REFCLKPLL1           : out std_ulogic;
        RESETDONE0           : out std_ulogic;
        RESETDONE1           : out std_ulogic;
        RXBUFSTATUS0         : out std_logic_vector(2 downto 0);
        RXBUFSTATUS1         : out std_logic_vector(2 downto 0);
        RXBYTEISALIGNED0     : out std_ulogic;
        RXBYTEISALIGNED1     : out std_ulogic;
        RXBYTEREALIGN0       : out std_ulogic;
        RXBYTEREALIGN1       : out std_ulogic;
        RXCHANBONDSEQ0       : out std_ulogic;
        RXCHANBONDSEQ1       : out std_ulogic;
        RXCHANISALIGNED0     : out std_ulogic;
        RXCHANISALIGNED1     : out std_ulogic;
        RXCHANREALIGN0       : out std_ulogic;
        RXCHANREALIGN1       : out std_ulogic;
        RXCHARISCOMMA0       : out std_logic_vector(3 downto 0);
        RXCHARISCOMMA1       : out std_logic_vector(3 downto 0);
        RXCHARISK0           : out std_logic_vector(3 downto 0);
        RXCHARISK1           : out std_logic_vector(3 downto 0);
        RXCHBONDO            : out std_logic_vector(2 downto 0);
        RXCLKCORCNT0         : out std_logic_vector(2 downto 0);
        RXCLKCORCNT1         : out std_logic_vector(2 downto 0);
        RXCOMMADET0          : out std_ulogic;
        RXCOMMADET1          : out std_ulogic;
        RXDATA0              : out std_logic_vector(31 downto 0);
        RXDATA1              : out std_logic_vector(31 downto 0);
        RXDISPERR0           : out std_logic_vector(3 downto 0);
        RXDISPERR1           : out std_logic_vector(3 downto 0);
        RXELECIDLE0          : out std_ulogic;
        RXELECIDLE1          : out std_ulogic;
        RXLOSSOFSYNC0        : out std_logic_vector(1 downto 0);
        RXLOSSOFSYNC1        : out std_logic_vector(1 downto 0);
        RXNOTINTABLE0        : out std_logic_vector(3 downto 0);
        RXNOTINTABLE1        : out std_logic_vector(3 downto 0);
        RXPRBSERR0           : out std_ulogic;
        RXPRBSERR1           : out std_ulogic;
        RXRECCLK0            : out std_ulogic;
        RXRECCLK1            : out std_ulogic;
        RXRUNDISP0           : out std_logic_vector(3 downto 0);
        RXRUNDISP1           : out std_logic_vector(3 downto 0);
        RXSTATUS0            : out std_logic_vector(2 downto 0);
        RXSTATUS1            : out std_logic_vector(2 downto 0);
        RXVALID0             : out std_ulogic;
        RXVALID1             : out std_ulogic;
        TSTOUT0              : out std_logic_vector(4 downto 0);
        TSTOUT1              : out std_logic_vector(4 downto 0);
        TXBUFSTATUS0         : out std_logic_vector(1 downto 0);
        TXBUFSTATUS1         : out std_logic_vector(1 downto 0);
        TXKERR0              : out std_logic_vector(3 downto 0);
        TXKERR1              : out std_logic_vector(3 downto 0);
        TXN0                 : out std_ulogic;
        TXN1                 : out std_ulogic;
        TXOUTCLK0            : out std_ulogic;
        TXOUTCLK1            : out std_ulogic;
        TXP0                 : out std_ulogic;
        TXP1                 : out std_ulogic;
        TXRUNDISP0           : out std_logic_vector(3 downto 0);
        TXRUNDISP1           : out std_logic_vector(3 downto 0);
        GSR                  : in std_ulogic;
        CLK00                : in std_ulogic;
        CLK01                : in std_ulogic;
        CLK10                : in std_ulogic;
        CLK11                : in std_ulogic;
        CLKINEAST0           : in std_ulogic;
        CLKINEAST1           : in std_ulogic;
        CLKINWEST0           : in std_ulogic;
        CLKINWEST1           : in std_ulogic;
        DADDR                : in std_logic_vector(7 downto 0);
        DCLK                 : in std_ulogic;
        DEN                  : in std_ulogic;
        DI                   : in std_logic_vector(15 downto 0);
        DWE                  : in std_ulogic;
        GATERXELECIDLE0      : in std_ulogic;
        GATERXELECIDLE1      : in std_ulogic;
        GCLK00               : in std_ulogic;
        GCLK01               : in std_ulogic;
        GCLK10               : in std_ulogic;
        GCLK11               : in std_ulogic;
        GTPCLKFBSEL0EAST     : in std_logic_vector(1 downto 0);
        GTPCLKFBSEL0WEST     : in std_logic_vector(1 downto 0);
        GTPCLKFBSEL1EAST     : in std_logic_vector(1 downto 0);
        GTPCLKFBSEL1WEST     : in std_logic_vector(1 downto 0);
        GTPRESET0            : in std_ulogic;
        GTPRESET1            : in std_ulogic;
        GTPTEST0             : in std_logic_vector(7 downto 0);
        GTPTEST1             : in std_logic_vector(7 downto 0);
        IGNORESIGDET0        : in std_ulogic;
        IGNORESIGDET1        : in std_ulogic;
        INTDATAWIDTH0        : in std_ulogic;
        INTDATAWIDTH1        : in std_ulogic;
        LOOPBACK0            : in std_logic_vector(2 downto 0);
        LOOPBACK1            : in std_logic_vector(2 downto 0);
        PLLCLK00             : in std_ulogic;
        PLLCLK01             : in std_ulogic;
        PLLCLK10             : in std_ulogic;
        PLLCLK11             : in std_ulogic;
        PLLLKDETEN0          : in std_ulogic;
        PLLLKDETEN1          : in std_ulogic;
        PLLPOWERDOWN0        : in std_ulogic;
        PLLPOWERDOWN1        : in std_ulogic;
        PRBSCNTRESET0        : in std_ulogic;
        PRBSCNTRESET1        : in std_ulogic;
        RCALINEAST           : in std_logic_vector(4 downto 0);
        RCALINWEST           : in std_logic_vector(4 downto 0);
        REFCLKPWRDNB0        : in std_ulogic;
        REFCLKPWRDNB1        : in std_ulogic;
        REFSELDYPLL0         : in std_logic_vector(2 downto 0);
        REFSELDYPLL1         : in std_logic_vector(2 downto 0);
        RXBUFRESET0          : in std_ulogic;
        RXBUFRESET1          : in std_ulogic;
        RXCDRRESET0          : in std_ulogic;
        RXCDRRESET1          : in std_ulogic;
        RXCHBONDI            : in std_logic_vector(2 downto 0);
        RXCHBONDMASTER0      : in std_ulogic;
        RXCHBONDMASTER1      : in std_ulogic;
        RXCHBONDSLAVE0       : in std_ulogic;
        RXCHBONDSLAVE1       : in std_ulogic;
        RXCOMMADETUSE0       : in std_ulogic;
        RXCOMMADETUSE1       : in std_ulogic;
        RXDATAWIDTH0         : in std_logic_vector(1 downto 0);
        RXDATAWIDTH1         : in std_logic_vector(1 downto 0);
        RXDEC8B10BUSE0       : in std_ulogic;
        RXDEC8B10BUSE1       : in std_ulogic;
        RXENCHANSYNC0        : in std_ulogic;
        RXENCHANSYNC1        : in std_ulogic;
        RXENMCOMMAALIGN0     : in std_ulogic;
        RXENMCOMMAALIGN1     : in std_ulogic;
        RXENPCOMMAALIGN0     : in std_ulogic;
        RXENPCOMMAALIGN1     : in std_ulogic;
        RXENPMAPHASEALIGN0   : in std_ulogic;
        RXENPMAPHASEALIGN1   : in std_ulogic;
        RXENPRBSTST0         : in std_logic_vector(2 downto 0);
        RXENPRBSTST1         : in std_logic_vector(2 downto 0);
        RXEQMIX0             : in std_logic_vector(1 downto 0);
        RXEQMIX1             : in std_logic_vector(1 downto 0);
        RXN0                 : in std_ulogic;
        RXN1                 : in std_ulogic;
        RXP0                 : in std_ulogic;
        RXP1                 : in std_ulogic;
        RXPMASETPHASE0       : in std_ulogic;
        RXPMASETPHASE1       : in std_ulogic;
        RXPOLARITY0          : in std_ulogic;
        RXPOLARITY1          : in std_ulogic;
        RXPOWERDOWN0         : in std_logic_vector(1 downto 0);
        RXPOWERDOWN1         : in std_logic_vector(1 downto 0);
        RXRESET0             : in std_ulogic;
        RXRESET1             : in std_ulogic;
        RXSLIDE0             : in std_ulogic;
        RXSLIDE1             : in std_ulogic;
        RXUSRCLK0            : in std_ulogic;
        RXUSRCLK1            : in std_ulogic;
        RXUSRCLK20           : in std_ulogic;
        RXUSRCLK21           : in std_ulogic;
        TSTCLK0              : in std_ulogic;
        TSTCLK1              : in std_ulogic;
        TSTIN0               : in std_logic_vector(11 downto 0);
        TSTIN1               : in std_logic_vector(11 downto 0);
        TXBUFDIFFCTRL0       : in std_logic_vector(2 downto 0);
        TXBUFDIFFCTRL1       : in std_logic_vector(2 downto 0);
        TXBYPASS8B10B0       : in std_logic_vector(3 downto 0);
        TXBYPASS8B10B1       : in std_logic_vector(3 downto 0);
        TXCHARDISPMODE0      : in std_logic_vector(3 downto 0);
        TXCHARDISPMODE1      : in std_logic_vector(3 downto 0);
        TXCHARDISPVAL0       : in std_logic_vector(3 downto 0);
        TXCHARDISPVAL1       : in std_logic_vector(3 downto 0);
        TXCHARISK0           : in std_logic_vector(3 downto 0);
        TXCHARISK1           : in std_logic_vector(3 downto 0);
        TXCOMSTART0          : in std_ulogic;
        TXCOMSTART1          : in std_ulogic;
        TXCOMTYPE0           : in std_ulogic;
        TXCOMTYPE1           : in std_ulogic;
        TXDATA0              : in std_logic_vector(31 downto 0);
        TXDATA1              : in std_logic_vector(31 downto 0);
        TXDATAWIDTH0         : in std_logic_vector(1 downto 0);
        TXDATAWIDTH1         : in std_logic_vector(1 downto 0);
        TXDETECTRX0          : in std_ulogic;
        TXDETECTRX1          : in std_ulogic;
        TXDIFFCTRL0          : in std_logic_vector(3 downto 0);
        TXDIFFCTRL1          : in std_logic_vector(3 downto 0);
        TXELECIDLE0          : in std_ulogic;
        TXELECIDLE1          : in std_ulogic;
        TXENC8B10BUSE0       : in std_ulogic;
        TXENC8B10BUSE1       : in std_ulogic;
        TXENPMAPHASEALIGN0   : in std_ulogic;
        TXENPMAPHASEALIGN1   : in std_ulogic;
        TXENPRBSTST0         : in std_logic_vector(2 downto 0);
        TXENPRBSTST1         : in std_logic_vector(2 downto 0);
        TXINHIBIT0           : in std_ulogic;
        TXINHIBIT1           : in std_ulogic;
        TXPDOWNASYNCH0       : in std_ulogic;
        TXPDOWNASYNCH1       : in std_ulogic;
        TXPMASETPHASE0       : in std_ulogic;
        TXPMASETPHASE1       : in std_ulogic;
        TXPOLARITY0          : in std_ulogic;
        TXPOLARITY1          : in std_ulogic;
        TXPOWERDOWN0         : in std_logic_vector(1 downto 0);
        TXPOWERDOWN1         : in std_logic_vector(1 downto 0);
        TXPRBSFORCEERR0      : in std_ulogic;
        TXPRBSFORCEERR1      : in std_ulogic;
        TXPREEMPHASIS0       : in std_logic_vector(2 downto 0);
        TXPREEMPHASIS1       : in std_logic_vector(2 downto 0);
        TXRESET0             : in std_ulogic;
        TXRESET1             : in std_ulogic;
        TXUSRCLK0            : in std_ulogic;
        TXUSRCLK1            : in std_ulogic;
        TXUSRCLK20           : in std_ulogic;
        TXUSRCLK21           : in std_ulogic;
        USRCODEERR0          : in std_ulogic;
        USRCODEERR1          : in std_ulogic        
      );
    end component;
    
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;
    constant MODULE_NAME : string  := "GTPA1_DUAL";

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
    constant CDR_PH_ADJ_TIME_0_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(CDR_PH_ADJ_TIME_0)(4 downto 0);
    constant CDR_PH_ADJ_TIME_1_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(CDR_PH_ADJ_TIME_1)(4 downto 0);
    constant CHAN_BOND_SEQ_1_1_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1_0)(9 downto 0);
    constant CHAN_BOND_SEQ_1_1_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1_1)(9 downto 0);
    constant CHAN_BOND_SEQ_1_2_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2_0)(9 downto 0);
    constant CHAN_BOND_SEQ_1_2_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2_1)(9 downto 0);
    constant CHAN_BOND_SEQ_1_3_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3_0)(9 downto 0);
    constant CHAN_BOND_SEQ_1_3_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3_1)(9 downto 0);
    constant CHAN_BOND_SEQ_1_4_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4_0)(9 downto 0);
    constant CHAN_BOND_SEQ_1_4_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4_1)(9 downto 0);
    constant CHAN_BOND_SEQ_1_ENABLE_0_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_ENABLE_0)(3 downto 0);
    constant CHAN_BOND_SEQ_1_ENABLE_1_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_ENABLE_1)(3 downto 0);
    constant CHAN_BOND_SEQ_2_1_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1_0)(9 downto 0);
    constant CHAN_BOND_SEQ_2_1_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1_1)(9 downto 0);
    constant CHAN_BOND_SEQ_2_2_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2_0)(9 downto 0);
    constant CHAN_BOND_SEQ_2_2_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2_1)(9 downto 0);
    constant CHAN_BOND_SEQ_2_3_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3_0)(9 downto 0);
    constant CHAN_BOND_SEQ_2_3_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3_1)(9 downto 0);
    constant CHAN_BOND_SEQ_2_4_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4_0)(9 downto 0);
    constant CHAN_BOND_SEQ_2_4_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4_1)(9 downto 0);
    constant CHAN_BOND_SEQ_2_ENABLE_0_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_ENABLE_0)(3 downto 0);
    constant CHAN_BOND_SEQ_2_ENABLE_1_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_ENABLE_1)(3 downto 0);
    constant CLK_COR_SEQ_1_1_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1_0)(9 downto 0);
    constant CLK_COR_SEQ_1_1_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1_1)(9 downto 0);
    constant CLK_COR_SEQ_1_2_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2_0)(9 downto 0);
    constant CLK_COR_SEQ_1_2_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2_1)(9 downto 0);
    constant CLK_COR_SEQ_1_3_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3_0)(9 downto 0);
    constant CLK_COR_SEQ_1_3_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3_1)(9 downto 0);
    constant CLK_COR_SEQ_1_4_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4_0)(9 downto 0);
    constant CLK_COR_SEQ_1_4_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4_1)(9 downto 0);
    constant CLK_COR_SEQ_1_ENABLE_0_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_ENABLE_0)(3 downto 0);
    constant CLK_COR_SEQ_1_ENABLE_1_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_ENABLE_1)(3 downto 0);
    constant CLK_COR_SEQ_2_1_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1_0)(9 downto 0);
    constant CLK_COR_SEQ_2_1_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1_1)(9 downto 0);
    constant CLK_COR_SEQ_2_2_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2_0)(9 downto 0);
    constant CLK_COR_SEQ_2_2_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2_1)(9 downto 0);
    constant CLK_COR_SEQ_2_3_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3_0)(9 downto 0);
    constant CLK_COR_SEQ_2_3_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3_1)(9 downto 0);
    constant CLK_COR_SEQ_2_4_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4_0)(9 downto 0);
    constant CLK_COR_SEQ_2_4_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4_1)(9 downto 0);
    constant CLK_COR_SEQ_2_ENABLE_0_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_ENABLE_0)(3 downto 0);
    constant CLK_COR_SEQ_2_ENABLE_1_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_ENABLE_1)(3 downto 0);
    constant CM_TRIM_0_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(CM_TRIM_0)(1 downto 0);
    constant CM_TRIM_1_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(CM_TRIM_1)(1 downto 0);
    constant COMMA_10B_ENABLE_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(COMMA_10B_ENABLE_0)(9 downto 0);
    constant COMMA_10B_ENABLE_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(COMMA_10B_ENABLE_1)(9 downto 0);
    constant COM_BURST_VAL_0_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(COM_BURST_VAL_0)(3 downto 0);
    constant COM_BURST_VAL_1_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(COM_BURST_VAL_1)(3 downto 0);
    constant MCOMMA_10B_VALUE_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(MCOMMA_10B_VALUE_0)(9 downto 0);
    constant MCOMMA_10B_VALUE_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(MCOMMA_10B_VALUE_1)(9 downto 0);
    constant OOBDETECT_THRESHOLD_0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(OOBDETECT_THRESHOLD_0)(2 downto 0);
    constant OOBDETECT_THRESHOLD_1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(OOBDETECT_THRESHOLD_1)(2 downto 0);
    constant PCOMMA_10B_VALUE_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(PCOMMA_10B_VALUE_0)(9 downto 0);
    constant PCOMMA_10B_VALUE_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(PCOMMA_10B_VALUE_1)(9 downto 0);
    constant PLLLKDET_CFG_0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PLLLKDET_CFG_0)(2 downto 0);
    constant PLLLKDET_CFG_1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(PLLLKDET_CFG_1)(2 downto 0);
    constant PLL_COM_CFG_0_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(PLL_COM_CFG_0)(23 downto 0);
    constant PLL_COM_CFG_1_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(PLL_COM_CFG_1)(23 downto 0);
    constant PLL_CP_CFG_0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PLL_CP_CFG_0)(7 downto 0);
    constant PLL_CP_CFG_1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(PLL_CP_CFG_1)(7 downto 0);
    constant PMA_CDR_SCAN_0_BINARY : std_logic_vector(26 downto 0) := To_StdLogicVector(PMA_CDR_SCAN_0)(26 downto 0);
    constant PMA_CDR_SCAN_1_BINARY : std_logic_vector(26 downto 0) := To_StdLogicVector(PMA_CDR_SCAN_1)(26 downto 0);
    constant PMA_COM_CFG_EAST_BINARY : std_logic_vector(35 downto 0) := To_StdLogicVector(PMA_COM_CFG_EAST)(35 downto 0);
    constant PMA_COM_CFG_WEST_BINARY : std_logic_vector(35 downto 0) := To_StdLogicVector(PMA_COM_CFG_WEST)(35 downto 0);
    constant PMA_RXSYNC_CFG_0_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(PMA_RXSYNC_CFG_0)(6 downto 0);
    constant PMA_RXSYNC_CFG_1_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(PMA_RXSYNC_CFG_1)(6 downto 0);
    constant PMA_RX_CFG_0_BINARY : std_logic_vector(24 downto 0) := To_StdLogicVector(PMA_RX_CFG_0)(24 downto 0);
    constant PMA_RX_CFG_1_BINARY : std_logic_vector(24 downto 0) := To_StdLogicVector(PMA_RX_CFG_1)(24 downto 0);
    constant PMA_TX_CFG_0_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PMA_TX_CFG_0)(19 downto 0);
    constant PMA_TX_CFG_1_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PMA_TX_CFG_1)(19 downto 0);
    constant RXEQ_CFG_0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(RXEQ_CFG_0)(7 downto 0);
    constant RXEQ_CFG_1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(RXEQ_CFG_1)(7 downto 0);
    constant RXPRBSERR_LOOPBACK_0_BINARY : std_ulogic := To_StduLogic(RXPRBSERR_LOOPBACK_0);
    constant RXPRBSERR_LOOPBACK_1_BINARY : std_ulogic := To_StduLogic(RXPRBSERR_LOOPBACK_1);
    constant RX_IDLE_HI_CNT_0_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_HI_CNT_0)(3 downto 0);
    constant RX_IDLE_HI_CNT_1_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_HI_CNT_1)(3 downto 0);
    constant RX_IDLE_LO_CNT_0_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_LO_CNT_0)(3 downto 0);
    constant RX_IDLE_LO_CNT_1_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_LO_CNT_1)(3 downto 0);
    constant SATA_BURST_VAL_0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_BURST_VAL_0)(2 downto 0);
    constant SATA_BURST_VAL_1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_BURST_VAL_1)(2 downto 0);
    constant SATA_IDLE_VAL_0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_IDLE_VAL_0)(2 downto 0);
    constant SATA_IDLE_VAL_1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_IDLE_VAL_1)(2 downto 0);
    constant SIM_REFCLK0_SOURCE_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SIM_REFCLK0_SOURCE)(2 downto 0);
    constant SIM_REFCLK1_SOURCE_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SIM_REFCLK1_SOURCE)(2 downto 0);
    constant TERMINATION_CTRL_0_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(TERMINATION_CTRL_0)(4 downto 0);
    constant TERMINATION_CTRL_1_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(TERMINATION_CTRL_1)(4 downto 0);
    constant TRANS_TIME_FROM_P2_0_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(TRANS_TIME_FROM_P2_0)(11 downto 0);
    constant TRANS_TIME_FROM_P2_1_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(TRANS_TIME_FROM_P2_1)(11 downto 0);
    constant TRANS_TIME_NON_P2_0_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TRANS_TIME_NON_P2_0)(7 downto 0);
    constant TRANS_TIME_NON_P2_1_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TRANS_TIME_NON_P2_1)(7 downto 0);
    constant TRANS_TIME_TO_P2_0_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(TRANS_TIME_TO_P2_0)(9 downto 0);
    constant TRANS_TIME_TO_P2_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(TRANS_TIME_TO_P2_1)(9 downto 0);
    constant TST_ATTR_0_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(TST_ATTR_0)(31 downto 0);
    constant TST_ATTR_1_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(TST_ATTR_1)(31 downto 0);
    constant TXRX_INVERT_0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TXRX_INVERT_0)(2 downto 0);
    constant TXRX_INVERT_1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TXRX_INVERT_1)(2 downto 0);
    constant TX_DETECT_RX_CFG_0_BINARY : std_logic_vector(13 downto 0) := To_StdLogicVector(TX_DETECT_RX_CFG_0)(13 downto 0);
    constant TX_DETECT_RX_CFG_1_BINARY : std_logic_vector(13 downto 0) := To_StdLogicVector(TX_DETECT_RX_CFG_1)(13 downto 0);
    constant TX_IDLE_DELAY_0_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TX_IDLE_DELAY_0)(2 downto 0);
    constant TX_IDLE_DELAY_1_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TX_IDLE_DELAY_1)(2 downto 0);
    constant TX_TDCC_CFG_0_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(TX_TDCC_CFG_0)(1 downto 0);
    constant TX_TDCC_CFG_1_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(TX_TDCC_CFG_1)(1 downto 0);
    -- Get String Length
    constant CDR_PH_ADJ_TIME_0_STRLEN : integer := getstrlength(CDR_PH_ADJ_TIME_0_BINARY);
    constant CDR_PH_ADJ_TIME_1_STRLEN : integer := getstrlength(CDR_PH_ADJ_TIME_1_BINARY);
    constant CHAN_BOND_SEQ_1_1_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_1_0_BINARY);
    constant CHAN_BOND_SEQ_1_1_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_1_1_BINARY);
    constant CHAN_BOND_SEQ_1_2_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_2_0_BINARY);
    constant CHAN_BOND_SEQ_1_2_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_2_1_BINARY);
    constant CHAN_BOND_SEQ_1_3_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_3_0_BINARY);
    constant CHAN_BOND_SEQ_1_3_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_3_1_BINARY);
    constant CHAN_BOND_SEQ_1_4_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_4_0_BINARY);
    constant CHAN_BOND_SEQ_1_4_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_4_1_BINARY);
    constant CHAN_BOND_SEQ_1_ENABLE_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_ENABLE_0_BINARY);
    constant CHAN_BOND_SEQ_1_ENABLE_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_1_ENABLE_1_BINARY);
    constant CHAN_BOND_SEQ_2_1_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_1_0_BINARY);
    constant CHAN_BOND_SEQ_2_1_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_1_1_BINARY);
    constant CHAN_BOND_SEQ_2_2_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_2_0_BINARY);
    constant CHAN_BOND_SEQ_2_2_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_2_1_BINARY);
    constant CHAN_BOND_SEQ_2_3_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_3_0_BINARY);
    constant CHAN_BOND_SEQ_2_3_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_3_1_BINARY);
    constant CHAN_BOND_SEQ_2_4_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_4_0_BINARY);
    constant CHAN_BOND_SEQ_2_4_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_4_1_BINARY);
    constant CHAN_BOND_SEQ_2_ENABLE_0_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_ENABLE_0_BINARY);
    constant CHAN_BOND_SEQ_2_ENABLE_1_STRLEN : integer := getstrlength(CHAN_BOND_SEQ_2_ENABLE_1_BINARY);
    constant CLK_COR_SEQ_1_1_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_1_0_BINARY);
    constant CLK_COR_SEQ_1_1_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_1_1_BINARY);
    constant CLK_COR_SEQ_1_2_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_2_0_BINARY);
    constant CLK_COR_SEQ_1_2_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_2_1_BINARY);
    constant CLK_COR_SEQ_1_3_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_3_0_BINARY);
    constant CLK_COR_SEQ_1_3_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_3_1_BINARY);
    constant CLK_COR_SEQ_1_4_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_4_0_BINARY);
    constant CLK_COR_SEQ_1_4_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_4_1_BINARY);
    constant CLK_COR_SEQ_1_ENABLE_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_ENABLE_0_BINARY);
    constant CLK_COR_SEQ_1_ENABLE_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_1_ENABLE_1_BINARY);
    constant CLK_COR_SEQ_2_1_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_1_0_BINARY);
    constant CLK_COR_SEQ_2_1_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_1_1_BINARY);
    constant CLK_COR_SEQ_2_2_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_2_0_BINARY);
    constant CLK_COR_SEQ_2_2_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_2_1_BINARY);
    constant CLK_COR_SEQ_2_3_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_3_0_BINARY);
    constant CLK_COR_SEQ_2_3_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_3_1_BINARY);
    constant CLK_COR_SEQ_2_4_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_4_0_BINARY);
    constant CLK_COR_SEQ_2_4_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_4_1_BINARY);
    constant CLK_COR_SEQ_2_ENABLE_0_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_ENABLE_0_BINARY);
    constant CLK_COR_SEQ_2_ENABLE_1_STRLEN : integer := getstrlength(CLK_COR_SEQ_2_ENABLE_1_BINARY);
    constant CM_TRIM_0_STRLEN : integer := getstrlength(CM_TRIM_0_BINARY);
    constant CM_TRIM_1_STRLEN : integer := getstrlength(CM_TRIM_1_BINARY);
    constant COMMA_10B_ENABLE_0_STRLEN : integer := getstrlength(COMMA_10B_ENABLE_0_BINARY);
    constant COMMA_10B_ENABLE_1_STRLEN : integer := getstrlength(COMMA_10B_ENABLE_1_BINARY);
    constant COM_BURST_VAL_0_STRLEN : integer := getstrlength(COM_BURST_VAL_0_BINARY);
    constant COM_BURST_VAL_1_STRLEN : integer := getstrlength(COM_BURST_VAL_1_BINARY);
    constant MCOMMA_10B_VALUE_0_STRLEN : integer := getstrlength(MCOMMA_10B_VALUE_0_BINARY);
    constant MCOMMA_10B_VALUE_1_STRLEN : integer := getstrlength(MCOMMA_10B_VALUE_1_BINARY);
    constant OOBDETECT_THRESHOLD_0_STRLEN : integer := getstrlength(OOBDETECT_THRESHOLD_0_BINARY);
    constant OOBDETECT_THRESHOLD_1_STRLEN : integer := getstrlength(OOBDETECT_THRESHOLD_1_BINARY);
    constant PCOMMA_10B_VALUE_0_STRLEN : integer := getstrlength(PCOMMA_10B_VALUE_0_BINARY);
    constant PCOMMA_10B_VALUE_1_STRLEN : integer := getstrlength(PCOMMA_10B_VALUE_1_BINARY);
    constant PLLLKDET_CFG_0_STRLEN : integer := getstrlength(PLLLKDET_CFG_0_BINARY);
    constant PLLLKDET_CFG_1_STRLEN : integer := getstrlength(PLLLKDET_CFG_1_BINARY);
    constant PLL_COM_CFG_0_STRLEN : integer := getstrlength(PLL_COM_CFG_0_BINARY);
    constant PLL_COM_CFG_1_STRLEN : integer := getstrlength(PLL_COM_CFG_1_BINARY);
    constant PLL_CP_CFG_0_STRLEN : integer := getstrlength(PLL_CP_CFG_0_BINARY);
    constant PLL_CP_CFG_1_STRLEN : integer := getstrlength(PLL_CP_CFG_1_BINARY);
    constant PMA_CDR_SCAN_0_STRLEN : integer := getstrlength(PMA_CDR_SCAN_0_BINARY);
    constant PMA_CDR_SCAN_1_STRLEN : integer := getstrlength(PMA_CDR_SCAN_1_BINARY);
    constant PMA_COM_CFG_EAST_STRLEN : integer := getstrlength(PMA_COM_CFG_EAST_BINARY);
    constant PMA_COM_CFG_WEST_STRLEN : integer := getstrlength(PMA_COM_CFG_WEST_BINARY);
    constant PMA_RXSYNC_CFG_0_STRLEN : integer := getstrlength(PMA_RXSYNC_CFG_0_BINARY);
    constant PMA_RXSYNC_CFG_1_STRLEN : integer := getstrlength(PMA_RXSYNC_CFG_1_BINARY);
    constant PMA_RX_CFG_0_STRLEN : integer := getstrlength(PMA_RX_CFG_0_BINARY);
    constant PMA_RX_CFG_1_STRLEN : integer := getstrlength(PMA_RX_CFG_1_BINARY);
    constant PMA_TX_CFG_0_STRLEN : integer := getstrlength(PMA_TX_CFG_0_BINARY);
    constant PMA_TX_CFG_1_STRLEN : integer := getstrlength(PMA_TX_CFG_1_BINARY);
    constant RXEQ_CFG_0_STRLEN : integer := getstrlength(RXEQ_CFG_0_BINARY);
    constant RXEQ_CFG_1_STRLEN : integer := getstrlength(RXEQ_CFG_1_BINARY);
    constant RX_IDLE_HI_CNT_0_STRLEN : integer := getstrlength(RX_IDLE_HI_CNT_0_BINARY);
    constant RX_IDLE_HI_CNT_1_STRLEN : integer := getstrlength(RX_IDLE_HI_CNT_1_BINARY);
    constant RX_IDLE_LO_CNT_0_STRLEN : integer := getstrlength(RX_IDLE_LO_CNT_0_BINARY);
    constant RX_IDLE_LO_CNT_1_STRLEN : integer := getstrlength(RX_IDLE_LO_CNT_1_BINARY);
    constant SATA_BURST_VAL_0_STRLEN : integer := getstrlength(SATA_BURST_VAL_0_BINARY);
    constant SATA_BURST_VAL_1_STRLEN : integer := getstrlength(SATA_BURST_VAL_1_BINARY);
    constant SATA_IDLE_VAL_0_STRLEN : integer := getstrlength(SATA_IDLE_VAL_0_BINARY);
    constant SATA_IDLE_VAL_1_STRLEN : integer := getstrlength(SATA_IDLE_VAL_1_BINARY);
    constant SIM_REFCLK0_SOURCE_STRLEN : integer := getstrlength(SIM_REFCLK0_SOURCE_BINARY);
    constant SIM_REFCLK1_SOURCE_STRLEN : integer := getstrlength(SIM_REFCLK1_SOURCE_BINARY);
    constant TERMINATION_CTRL_0_STRLEN : integer := getstrlength(TERMINATION_CTRL_0_BINARY);
    constant TERMINATION_CTRL_1_STRLEN : integer := getstrlength(TERMINATION_CTRL_1_BINARY);
    constant TRANS_TIME_FROM_P2_0_STRLEN : integer := getstrlength(TRANS_TIME_FROM_P2_0_BINARY);
    constant TRANS_TIME_FROM_P2_1_STRLEN : integer := getstrlength(TRANS_TIME_FROM_P2_1_BINARY);
    constant TRANS_TIME_NON_P2_0_STRLEN : integer := getstrlength(TRANS_TIME_NON_P2_0_BINARY);
    constant TRANS_TIME_NON_P2_1_STRLEN : integer := getstrlength(TRANS_TIME_NON_P2_1_BINARY);
    constant TRANS_TIME_TO_P2_0_STRLEN : integer := getstrlength(TRANS_TIME_TO_P2_0_BINARY);
    constant TRANS_TIME_TO_P2_1_STRLEN : integer := getstrlength(TRANS_TIME_TO_P2_1_BINARY);
    constant TST_ATTR_0_STRLEN : integer := getstrlength(TST_ATTR_0_BINARY);
    constant TST_ATTR_1_STRLEN : integer := getstrlength(TST_ATTR_1_BINARY);
    constant TXRX_INVERT_0_STRLEN : integer := getstrlength(TXRX_INVERT_0_BINARY);
    constant TXRX_INVERT_1_STRLEN : integer := getstrlength(TXRX_INVERT_1_BINARY);
    constant TX_DETECT_RX_CFG_0_STRLEN : integer := getstrlength(TX_DETECT_RX_CFG_0_BINARY);
    constant TX_DETECT_RX_CFG_1_STRLEN : integer := getstrlength(TX_DETECT_RX_CFG_1_BINARY);
    constant TX_IDLE_DELAY_0_STRLEN : integer := getstrlength(TX_IDLE_DELAY_0_BINARY);
    constant TX_IDLE_DELAY_1_STRLEN : integer := getstrlength(TX_IDLE_DELAY_1_BINARY);
    constant TX_TDCC_CFG_0_STRLEN : integer := getstrlength(TX_TDCC_CFG_0_BINARY);
    constant TX_TDCC_CFG_1_STRLEN : integer := getstrlength(TX_TDCC_CFG_1_BINARY);
    
    -- Convert std_logic_vector to string
    constant CDR_PH_ADJ_TIME_0_STRING : string := SLV_TO_HEX(CDR_PH_ADJ_TIME_0_BINARY, CDR_PH_ADJ_TIME_0_STRLEN);
    constant CDR_PH_ADJ_TIME_1_STRING : string := SLV_TO_HEX(CDR_PH_ADJ_TIME_1_BINARY, CDR_PH_ADJ_TIME_1_STRLEN);
    constant CHAN_BOND_SEQ_1_1_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_1_0_BINARY, CHAN_BOND_SEQ_1_1_0_STRLEN);
    constant CHAN_BOND_SEQ_1_1_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_1_1_BINARY, CHAN_BOND_SEQ_1_1_1_STRLEN);
    constant CHAN_BOND_SEQ_1_2_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_2_0_BINARY, CHAN_BOND_SEQ_1_2_0_STRLEN);
    constant CHAN_BOND_SEQ_1_2_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_2_1_BINARY, CHAN_BOND_SEQ_1_2_1_STRLEN);
    constant CHAN_BOND_SEQ_1_3_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_3_0_BINARY, CHAN_BOND_SEQ_1_3_0_STRLEN);
    constant CHAN_BOND_SEQ_1_3_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_3_1_BINARY, CHAN_BOND_SEQ_1_3_1_STRLEN);
    constant CHAN_BOND_SEQ_1_4_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_4_0_BINARY, CHAN_BOND_SEQ_1_4_0_STRLEN);
    constant CHAN_BOND_SEQ_1_4_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_4_1_BINARY, CHAN_BOND_SEQ_1_4_1_STRLEN);
    constant CHAN_BOND_SEQ_1_ENABLE_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_ENABLE_0_BINARY, CHAN_BOND_SEQ_1_ENABLE_0_STRLEN);
    constant CHAN_BOND_SEQ_1_ENABLE_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_1_ENABLE_1_BINARY, CHAN_BOND_SEQ_1_ENABLE_1_STRLEN);
    constant CHAN_BOND_SEQ_2_1_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_1_0_BINARY, CHAN_BOND_SEQ_2_1_0_STRLEN);
    constant CHAN_BOND_SEQ_2_1_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_1_1_BINARY, CHAN_BOND_SEQ_2_1_1_STRLEN);
    constant CHAN_BOND_SEQ_2_2_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_2_0_BINARY, CHAN_BOND_SEQ_2_2_0_STRLEN);
    constant CHAN_BOND_SEQ_2_2_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_2_1_BINARY, CHAN_BOND_SEQ_2_2_1_STRLEN);
    constant CHAN_BOND_SEQ_2_3_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_3_0_BINARY, CHAN_BOND_SEQ_2_3_0_STRLEN);
    constant CHAN_BOND_SEQ_2_3_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_3_1_BINARY, CHAN_BOND_SEQ_2_3_1_STRLEN);
    constant CHAN_BOND_SEQ_2_4_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_4_0_BINARY, CHAN_BOND_SEQ_2_4_0_STRLEN);
    constant CHAN_BOND_SEQ_2_4_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_4_1_BINARY, CHAN_BOND_SEQ_2_4_1_STRLEN);
    constant CHAN_BOND_SEQ_2_ENABLE_0_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_ENABLE_0_BINARY, CHAN_BOND_SEQ_2_ENABLE_0_STRLEN);
    constant CHAN_BOND_SEQ_2_ENABLE_1_STRING : string := SLV_TO_HEX(CHAN_BOND_SEQ_2_ENABLE_1_BINARY, CHAN_BOND_SEQ_2_ENABLE_1_STRLEN);
    constant CLK_COR_SEQ_1_1_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_1_0_BINARY, CLK_COR_SEQ_1_1_0_STRLEN);
    constant CLK_COR_SEQ_1_1_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_1_1_BINARY, CLK_COR_SEQ_1_1_1_STRLEN);
    constant CLK_COR_SEQ_1_2_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_2_0_BINARY, CLK_COR_SEQ_1_2_0_STRLEN);
    constant CLK_COR_SEQ_1_2_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_2_1_BINARY, CLK_COR_SEQ_1_2_1_STRLEN);
    constant CLK_COR_SEQ_1_3_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_3_0_BINARY, CLK_COR_SEQ_1_3_0_STRLEN);
    constant CLK_COR_SEQ_1_3_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_3_1_BINARY, CLK_COR_SEQ_1_3_1_STRLEN);
    constant CLK_COR_SEQ_1_4_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_4_0_BINARY, CLK_COR_SEQ_1_4_0_STRLEN);
    constant CLK_COR_SEQ_1_4_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_4_1_BINARY, CLK_COR_SEQ_1_4_1_STRLEN);
    constant CLK_COR_SEQ_1_ENABLE_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_ENABLE_0_BINARY, CLK_COR_SEQ_1_ENABLE_0_STRLEN);
    constant CLK_COR_SEQ_1_ENABLE_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_1_ENABLE_1_BINARY, CLK_COR_SEQ_1_ENABLE_1_STRLEN);
    constant CLK_COR_SEQ_2_1_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_1_0_BINARY, CLK_COR_SEQ_2_1_0_STRLEN);
    constant CLK_COR_SEQ_2_1_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_1_1_BINARY, CLK_COR_SEQ_2_1_1_STRLEN);
    constant CLK_COR_SEQ_2_2_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_2_0_BINARY, CLK_COR_SEQ_2_2_0_STRLEN);
    constant CLK_COR_SEQ_2_2_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_2_1_BINARY, CLK_COR_SEQ_2_2_1_STRLEN);
    constant CLK_COR_SEQ_2_3_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_3_0_BINARY, CLK_COR_SEQ_2_3_0_STRLEN);
    constant CLK_COR_SEQ_2_3_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_3_1_BINARY, CLK_COR_SEQ_2_3_1_STRLEN);
    constant CLK_COR_SEQ_2_4_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_4_0_BINARY, CLK_COR_SEQ_2_4_0_STRLEN);
    constant CLK_COR_SEQ_2_4_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_4_1_BINARY, CLK_COR_SEQ_2_4_1_STRLEN);
    constant CLK_COR_SEQ_2_ENABLE_0_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_ENABLE_0_BINARY, CLK_COR_SEQ_2_ENABLE_0_STRLEN);
    constant CLK_COR_SEQ_2_ENABLE_1_STRING : string := SLV_TO_HEX(CLK_COR_SEQ_2_ENABLE_1_BINARY, CLK_COR_SEQ_2_ENABLE_1_STRLEN);
    constant CM_TRIM_0_STRING : string := SLV_TO_HEX(CM_TRIM_0_BINARY, CM_TRIM_0_STRLEN);
    constant CM_TRIM_1_STRING : string := SLV_TO_HEX(CM_TRIM_1_BINARY, CM_TRIM_1_STRLEN);
    constant COMMA_10B_ENABLE_0_STRING : string := SLV_TO_HEX(COMMA_10B_ENABLE_0_BINARY, COMMA_10B_ENABLE_0_STRLEN);
    constant COMMA_10B_ENABLE_1_STRING : string := SLV_TO_HEX(COMMA_10B_ENABLE_1_BINARY, COMMA_10B_ENABLE_1_STRLEN);
    constant COM_BURST_VAL_0_STRING : string := SLV_TO_HEX(COM_BURST_VAL_0_BINARY, COM_BURST_VAL_0_STRLEN);
    constant COM_BURST_VAL_1_STRING : string := SLV_TO_HEX(COM_BURST_VAL_1_BINARY, COM_BURST_VAL_1_STRLEN);
    constant MCOMMA_10B_VALUE_0_STRING : string := SLV_TO_HEX(MCOMMA_10B_VALUE_0_BINARY, MCOMMA_10B_VALUE_0_STRLEN);
    constant MCOMMA_10B_VALUE_1_STRING : string := SLV_TO_HEX(MCOMMA_10B_VALUE_1_BINARY, MCOMMA_10B_VALUE_1_STRLEN);
    constant OOBDETECT_THRESHOLD_0_STRING : string := SLV_TO_HEX(OOBDETECT_THRESHOLD_0_BINARY, OOBDETECT_THRESHOLD_0_STRLEN);
    constant OOBDETECT_THRESHOLD_1_STRING : string := SLV_TO_HEX(OOBDETECT_THRESHOLD_1_BINARY, OOBDETECT_THRESHOLD_1_STRLEN);
    constant PCOMMA_10B_VALUE_0_STRING : string := SLV_TO_HEX(PCOMMA_10B_VALUE_0_BINARY, PCOMMA_10B_VALUE_0_STRLEN);
    constant PCOMMA_10B_VALUE_1_STRING : string := SLV_TO_HEX(PCOMMA_10B_VALUE_1_BINARY, PCOMMA_10B_VALUE_1_STRLEN);
    constant PLLLKDET_CFG_0_STRING : string := SLV_TO_HEX(PLLLKDET_CFG_0_BINARY, PLLLKDET_CFG_0_STRLEN);
    constant PLLLKDET_CFG_1_STRING : string := SLV_TO_HEX(PLLLKDET_CFG_1_BINARY, PLLLKDET_CFG_1_STRLEN);
    constant PLL_COM_CFG_0_STRING : string := SLV_TO_HEX(PLL_COM_CFG_0_BINARY, PLL_COM_CFG_0_STRLEN);
    constant PLL_COM_CFG_1_STRING : string := SLV_TO_HEX(PLL_COM_CFG_1_BINARY, PLL_COM_CFG_1_STRLEN);
    constant PLL_CP_CFG_0_STRING : string := SLV_TO_HEX(PLL_CP_CFG_0_BINARY, PLL_CP_CFG_0_STRLEN);
    constant PLL_CP_CFG_1_STRING : string := SLV_TO_HEX(PLL_CP_CFG_1_BINARY, PLL_CP_CFG_1_STRLEN);
    constant PMA_CDR_SCAN_0_STRING : string := SLV_TO_HEX(PMA_CDR_SCAN_0_BINARY, PMA_CDR_SCAN_0_STRLEN);
    constant PMA_CDR_SCAN_1_STRING : string := SLV_TO_HEX(PMA_CDR_SCAN_1_BINARY, PMA_CDR_SCAN_1_STRLEN);
    constant PMA_COM_CFG_EAST_STRING : string := SLV_TO_HEX(PMA_COM_CFG_EAST_BINARY, PMA_COM_CFG_EAST_STRLEN);
    constant PMA_COM_CFG_WEST_STRING : string := SLV_TO_HEX(PMA_COM_CFG_WEST_BINARY, PMA_COM_CFG_WEST_STRLEN);
    constant PMA_RXSYNC_CFG_0_STRING : string := SLV_TO_HEX(PMA_RXSYNC_CFG_0_BINARY, PMA_RXSYNC_CFG_0_STRLEN);
    constant PMA_RXSYNC_CFG_1_STRING : string := SLV_TO_HEX(PMA_RXSYNC_CFG_1_BINARY, PMA_RXSYNC_CFG_1_STRLEN);
    constant PMA_RX_CFG_0_STRING : string := SLV_TO_HEX(PMA_RX_CFG_0_BINARY, PMA_RX_CFG_0_STRLEN);
    constant PMA_RX_CFG_1_STRING : string := SLV_TO_HEX(PMA_RX_CFG_1_BINARY, PMA_RX_CFG_1_STRLEN);
    constant PMA_TX_CFG_0_STRING : string := SLV_TO_HEX(PMA_TX_CFG_0_BINARY, PMA_TX_CFG_0_STRLEN);
    constant PMA_TX_CFG_1_STRING : string := SLV_TO_HEX(PMA_TX_CFG_1_BINARY, PMA_TX_CFG_1_STRLEN);
    constant RXEQ_CFG_0_STRING : string := SLV_TO_HEX(RXEQ_CFG_0_BINARY, RXEQ_CFG_0_STRLEN);
    constant RXEQ_CFG_1_STRING : string := SLV_TO_HEX(RXEQ_CFG_1_BINARY, RXEQ_CFG_1_STRLEN);
    constant RXPRBSERR_LOOPBACK_0_STRING : string := SUL_TO_STR(RXPRBSERR_LOOPBACK_0_BINARY);
    constant RXPRBSERR_LOOPBACK_1_STRING : string := SUL_TO_STR(RXPRBSERR_LOOPBACK_1_BINARY);
    constant RX_IDLE_HI_CNT_0_STRING : string := SLV_TO_HEX(RX_IDLE_HI_CNT_0_BINARY, RX_IDLE_HI_CNT_0_STRLEN);
    constant RX_IDLE_HI_CNT_1_STRING : string := SLV_TO_HEX(RX_IDLE_HI_CNT_1_BINARY, RX_IDLE_HI_CNT_1_STRLEN);
    constant RX_IDLE_LO_CNT_0_STRING : string := SLV_TO_HEX(RX_IDLE_LO_CNT_0_BINARY, RX_IDLE_LO_CNT_0_STRLEN);
    constant RX_IDLE_LO_CNT_1_STRING : string := SLV_TO_HEX(RX_IDLE_LO_CNT_1_BINARY, RX_IDLE_LO_CNT_1_STRLEN);
    constant SATA_BURST_VAL_0_STRING : string := SLV_TO_HEX(SATA_BURST_VAL_0_BINARY, SATA_BURST_VAL_0_STRLEN);
    constant SATA_BURST_VAL_1_STRING : string := SLV_TO_HEX(SATA_BURST_VAL_1_BINARY, SATA_BURST_VAL_1_STRLEN);
    constant SATA_IDLE_VAL_0_STRING : string := SLV_TO_HEX(SATA_IDLE_VAL_0_BINARY, SATA_IDLE_VAL_0_STRLEN);
    constant SATA_IDLE_VAL_1_STRING : string := SLV_TO_HEX(SATA_IDLE_VAL_1_BINARY, SATA_IDLE_VAL_1_STRLEN);
    constant SIM_REFCLK0_SOURCE_STRING : string := SLV_TO_HEX(SIM_REFCLK0_SOURCE_BINARY, SIM_REFCLK0_SOURCE_STRLEN);
    constant SIM_REFCLK1_SOURCE_STRING : string := SLV_TO_HEX(SIM_REFCLK1_SOURCE_BINARY, SIM_REFCLK1_SOURCE_STRLEN);
    constant TERMINATION_CTRL_0_STRING : string := SLV_TO_HEX(TERMINATION_CTRL_0_BINARY, TERMINATION_CTRL_0_STRLEN);
    constant TERMINATION_CTRL_1_STRING : string := SLV_TO_HEX(TERMINATION_CTRL_1_BINARY, TERMINATION_CTRL_1_STRLEN);
    constant TRANS_TIME_FROM_P2_0_STRING : string := SLV_TO_HEX(TRANS_TIME_FROM_P2_0_BINARY, TRANS_TIME_FROM_P2_0_STRLEN);
    constant TRANS_TIME_FROM_P2_1_STRING : string := SLV_TO_HEX(TRANS_TIME_FROM_P2_1_BINARY, TRANS_TIME_FROM_P2_1_STRLEN);
    constant TRANS_TIME_NON_P2_0_STRING : string := SLV_TO_HEX(TRANS_TIME_NON_P2_0_BINARY, TRANS_TIME_NON_P2_0_STRLEN);
    constant TRANS_TIME_NON_P2_1_STRING : string := SLV_TO_HEX(TRANS_TIME_NON_P2_1_BINARY, TRANS_TIME_NON_P2_1_STRLEN);
    constant TRANS_TIME_TO_P2_0_STRING : string := SLV_TO_HEX(TRANS_TIME_TO_P2_0_BINARY, TRANS_TIME_TO_P2_0_STRLEN);
    constant TRANS_TIME_TO_P2_1_STRING : string := SLV_TO_HEX(TRANS_TIME_TO_P2_1_BINARY, TRANS_TIME_TO_P2_1_STRLEN);
    constant TST_ATTR_0_STRING : string := SLV_TO_HEX(TST_ATTR_0_BINARY, TST_ATTR_0_STRLEN);
    constant TST_ATTR_1_STRING : string := SLV_TO_HEX(TST_ATTR_1_BINARY, TST_ATTR_1_STRLEN);
    constant TXRX_INVERT_0_STRING : string := SLV_TO_HEX(TXRX_INVERT_0_BINARY, TXRX_INVERT_0_STRLEN);
    constant TXRX_INVERT_1_STRING : string := SLV_TO_HEX(TXRX_INVERT_1_BINARY, TXRX_INVERT_1_STRLEN);
    constant TX_DETECT_RX_CFG_0_STRING : string := SLV_TO_HEX(TX_DETECT_RX_CFG_0_BINARY, TX_DETECT_RX_CFG_0_STRLEN);
    constant TX_DETECT_RX_CFG_1_STRING : string := SLV_TO_HEX(TX_DETECT_RX_CFG_1_BINARY, TX_DETECT_RX_CFG_1_STRLEN);
    constant TX_IDLE_DELAY_0_STRING : string := SLV_TO_HEX(TX_IDLE_DELAY_0_BINARY, TX_IDLE_DELAY_0_STRLEN);
    constant TX_IDLE_DELAY_1_STRING : string := SLV_TO_HEX(TX_IDLE_DELAY_1_BINARY, TX_IDLE_DELAY_1_STRLEN);
    constant TX_TDCC_CFG_0_STRING : string := SLV_TO_HEX(TX_TDCC_CFG_0_BINARY, TX_TDCC_CFG_0_STRLEN);
    constant TX_TDCC_CFG_1_STRING : string := SLV_TO_HEX(TX_TDCC_CFG_1_BINARY, TX_TDCC_CFG_1_STRLEN);
    
    -- Convert boolean to string
    constant AC_CAP_DIS_0_STRING : string := boolean_to_string(AC_CAP_DIS_0);
    constant AC_CAP_DIS_1_STRING : string := boolean_to_string(AC_CAP_DIS_1);
    constant CHAN_BOND_KEEP_ALIGN_0_STRING : string := boolean_to_string(CHAN_BOND_KEEP_ALIGN_0);
    constant CHAN_BOND_KEEP_ALIGN_1_STRING : string := boolean_to_string(CHAN_BOND_KEEP_ALIGN_1);
    constant CHAN_BOND_SEQ_2_USE_0_STRING : string := boolean_to_string(CHAN_BOND_SEQ_2_USE_0);
    constant CHAN_BOND_SEQ_2_USE_1_STRING : string := boolean_to_string(CHAN_BOND_SEQ_2_USE_1);
    constant CLKINDC_B_0_STRING : string := boolean_to_string(CLKINDC_B_0);
    constant CLKINDC_B_1_STRING : string := boolean_to_string(CLKINDC_B_1);
    constant CLKRCV_TRST_0_STRING : string := boolean_to_string(CLKRCV_TRST_0);
    constant CLKRCV_TRST_1_STRING : string := boolean_to_string(CLKRCV_TRST_1);
    constant CLK_CORRECT_USE_0_STRING : string := boolean_to_string(CLK_CORRECT_USE_0);
    constant CLK_CORRECT_USE_1_STRING : string := boolean_to_string(CLK_CORRECT_USE_1);
    constant CLK_COR_INSERT_IDLE_FLAG_0_STRING : string := boolean_to_string(CLK_COR_INSERT_IDLE_FLAG_0);
    constant CLK_COR_INSERT_IDLE_FLAG_1_STRING : string := boolean_to_string(CLK_COR_INSERT_IDLE_FLAG_1);
    constant CLK_COR_KEEP_IDLE_0_STRING : string := boolean_to_string(CLK_COR_KEEP_IDLE_0);
    constant CLK_COR_KEEP_IDLE_1_STRING : string := boolean_to_string(CLK_COR_KEEP_IDLE_1);
    constant CLK_COR_PRECEDENCE_0_STRING : string := boolean_to_string(CLK_COR_PRECEDENCE_0);
    constant CLK_COR_PRECEDENCE_1_STRING : string := boolean_to_string(CLK_COR_PRECEDENCE_1);
    constant CLK_COR_SEQ_2_USE_0_STRING : string := boolean_to_string(CLK_COR_SEQ_2_USE_0);
    constant CLK_COR_SEQ_2_USE_1_STRING : string := boolean_to_string(CLK_COR_SEQ_2_USE_1);
    constant DEC_MCOMMA_DETECT_0_STRING : string := boolean_to_string(DEC_MCOMMA_DETECT_0);
    constant DEC_MCOMMA_DETECT_1_STRING : string := boolean_to_string(DEC_MCOMMA_DETECT_1);
    constant DEC_PCOMMA_DETECT_0_STRING : string := boolean_to_string(DEC_PCOMMA_DETECT_0);
    constant DEC_PCOMMA_DETECT_1_STRING : string := boolean_to_string(DEC_PCOMMA_DETECT_1);
    constant DEC_VALID_COMMA_ONLY_0_STRING : string := boolean_to_string(DEC_VALID_COMMA_ONLY_0);
    constant DEC_VALID_COMMA_ONLY_1_STRING : string := boolean_to_string(DEC_VALID_COMMA_ONLY_1);
    constant GTP_CFG_PWRUP_0_STRING : string := boolean_to_string(GTP_CFG_PWRUP_0);
    constant GTP_CFG_PWRUP_1_STRING : string := boolean_to_string(GTP_CFG_PWRUP_1);
    constant MCOMMA_DETECT_0_STRING : string := boolean_to_string(MCOMMA_DETECT_0);
    constant MCOMMA_DETECT_1_STRING : string := boolean_to_string(MCOMMA_DETECT_1);
    constant PCI_EXPRESS_MODE_0_STRING : string := boolean_to_string(PCI_EXPRESS_MODE_0);
    constant PCI_EXPRESS_MODE_1_STRING : string := boolean_to_string(PCI_EXPRESS_MODE_1);
    constant PCOMMA_DETECT_0_STRING : string := boolean_to_string(PCOMMA_DETECT_0);
    constant PCOMMA_DETECT_1_STRING : string := boolean_to_string(PCOMMA_DETECT_1);
    constant PLL_SATA_0_STRING : string := boolean_to_string(PLL_SATA_0);
    constant PLL_SATA_1_STRING : string := boolean_to_string(PLL_SATA_1);
    constant RCV_TERM_GND_0_STRING : string := boolean_to_string(RCV_TERM_GND_0);
    constant RCV_TERM_GND_1_STRING : string := boolean_to_string(RCV_TERM_GND_1);
    constant RCV_TERM_VTTRX_0_STRING : string := boolean_to_string(RCV_TERM_VTTRX_0);
    constant RCV_TERM_VTTRX_1_STRING : string := boolean_to_string(RCV_TERM_VTTRX_1);
    constant RX_BUFFER_USE_0_STRING : string := boolean_to_string(RX_BUFFER_USE_0);
    constant RX_BUFFER_USE_1_STRING : string := boolean_to_string(RX_BUFFER_USE_1);
    constant RX_DECODE_SEQ_MATCH_0_STRING : string := boolean_to_string(RX_DECODE_SEQ_MATCH_0);
    constant RX_DECODE_SEQ_MATCH_1_STRING : string := boolean_to_string(RX_DECODE_SEQ_MATCH_1);
    constant RX_EN_IDLE_HOLD_CDR_0_STRING : string := boolean_to_string(RX_EN_IDLE_HOLD_CDR_0);
    constant RX_EN_IDLE_HOLD_CDR_1_STRING : string := boolean_to_string(RX_EN_IDLE_HOLD_CDR_1);
    constant RX_EN_IDLE_RESET_BUF_0_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_BUF_0);
    constant RX_EN_IDLE_RESET_BUF_1_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_BUF_1);
    constant RX_EN_IDLE_RESET_FR_0_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_FR_0);
    constant RX_EN_IDLE_RESET_FR_1_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_FR_1);
    constant RX_EN_IDLE_RESET_PH_0_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_PH_0);
    constant RX_EN_IDLE_RESET_PH_1_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_PH_1);
    constant RX_EN_MODE_RESET_BUF_0_STRING : string := boolean_to_string(RX_EN_MODE_RESET_BUF_0);
    constant RX_EN_MODE_RESET_BUF_1_STRING : string := boolean_to_string(RX_EN_MODE_RESET_BUF_1);
    constant RX_LOSS_OF_SYNC_FSM_0_STRING : string := boolean_to_string(RX_LOSS_OF_SYNC_FSM_0);
    constant RX_LOSS_OF_SYNC_FSM_1_STRING : string := boolean_to_string(RX_LOSS_OF_SYNC_FSM_1);
    constant SIM_RECEIVER_DETECT_PASS_STRING : string := boolean_to_string(SIM_RECEIVER_DETECT_PASS);
    constant TERMINATION_OVRD_0_STRING : string := boolean_to_string(TERMINATION_OVRD_0);
    constant TERMINATION_OVRD_1_STRING : string := boolean_to_string(TERMINATION_OVRD_1);
    constant TX_BUFFER_USE_0_STRING : string := boolean_to_string(TX_BUFFER_USE_0);
    constant TX_BUFFER_USE_1_STRING : string := boolean_to_string(TX_BUFFER_USE_1);
    
    signal AC_CAP_DIS_0_BINARY : std_ulogic;
    signal AC_CAP_DIS_1_BINARY : std_ulogic;
    signal ALIGN_COMMA_WORD_0_BINARY : std_ulogic;
    signal ALIGN_COMMA_WORD_1_BINARY : std_ulogic;
    signal CB2_INH_CC_PERIOD_0_BINARY : std_logic_vector(3 downto 0);
    signal CB2_INH_CC_PERIOD_1_BINARY : std_logic_vector(3 downto 0);
    signal CHAN_BOND_1_MAX_SKEW_0_BINARY : std_logic_vector(3 downto 0);
    signal CHAN_BOND_1_MAX_SKEW_1_BINARY : std_logic_vector(3 downto 0);
    signal CHAN_BOND_2_MAX_SKEW_0_BINARY : std_logic_vector(3 downto 0);
    signal CHAN_BOND_2_MAX_SKEW_1_BINARY : std_logic_vector(3 downto 0);
    signal CHAN_BOND_KEEP_ALIGN_0_BINARY : std_ulogic;
    signal CHAN_BOND_KEEP_ALIGN_1_BINARY : std_ulogic;
    signal CHAN_BOND_SEQ_2_USE_0_BINARY : std_ulogic;
    signal CHAN_BOND_SEQ_2_USE_1_BINARY : std_ulogic;
    signal CHAN_BOND_SEQ_LEN_0_BINARY : std_logic_vector(1 downto 0);
    signal CHAN_BOND_SEQ_LEN_1_BINARY : std_logic_vector(1 downto 0);
    signal CLK25_DIVIDER_0_BINARY : std_logic_vector(2 downto 0);
    signal CLK25_DIVIDER_1_BINARY : std_logic_vector(2 downto 0);
    signal CLKINDC_B_0_BINARY : std_ulogic;
    signal CLKINDC_B_1_BINARY : std_ulogic;
    signal CLKRCV_TRST_0_BINARY : std_ulogic;
    signal CLKRCV_TRST_1_BINARY : std_ulogic;
    signal CLK_CORRECT_USE_0_BINARY : std_ulogic;
    signal CLK_CORRECT_USE_1_BINARY : std_ulogic;
    signal CLK_COR_ADJ_LEN_0_BINARY : std_logic_vector(1 downto 0);
    signal CLK_COR_ADJ_LEN_1_BINARY : std_logic_vector(1 downto 0);
    signal CLK_COR_DET_LEN_0_BINARY : std_logic_vector(1 downto 0);
    signal CLK_COR_DET_LEN_1_BINARY : std_logic_vector(1 downto 0);
    signal CLK_COR_INSERT_IDLE_FLAG_0_BINARY : std_ulogic;
    signal CLK_COR_INSERT_IDLE_FLAG_1_BINARY : std_ulogic;
    signal CLK_COR_KEEP_IDLE_0_BINARY : std_ulogic;
    signal CLK_COR_KEEP_IDLE_1_BINARY : std_ulogic;
    signal CLK_COR_MAX_LAT_0_BINARY : std_logic_vector(5 downto 0);
    signal CLK_COR_MAX_LAT_1_BINARY : std_logic_vector(5 downto 0);
    signal CLK_COR_MIN_LAT_0_BINARY : std_logic_vector(5 downto 0);
    signal CLK_COR_MIN_LAT_1_BINARY : std_logic_vector(5 downto 0);
    signal CLK_COR_PRECEDENCE_0_BINARY : std_ulogic;
    signal CLK_COR_PRECEDENCE_1_BINARY : std_ulogic;
    signal CLK_COR_REPEAT_WAIT_0_BINARY : std_logic_vector(4 downto 0);
    signal CLK_COR_REPEAT_WAIT_1_BINARY : std_logic_vector(4 downto 0);
    signal CLK_COR_SEQ_2_USE_0_BINARY : std_ulogic;
    signal CLK_COR_SEQ_2_USE_1_BINARY : std_ulogic;
    signal CLK_OUT_GTP_SEL_0_BINARY : std_ulogic;
    signal CLK_OUT_GTP_SEL_1_BINARY : std_ulogic;
    signal DEC_MCOMMA_DETECT_0_BINARY : std_ulogic;
    signal DEC_MCOMMA_DETECT_1_BINARY : std_ulogic;
    signal DEC_PCOMMA_DETECT_0_BINARY : std_ulogic;
    signal DEC_PCOMMA_DETECT_1_BINARY : std_ulogic;
    signal DEC_VALID_COMMA_ONLY_0_BINARY : std_ulogic;
    signal DEC_VALID_COMMA_ONLY_1_BINARY : std_ulogic;
    signal GTP_CFG_PWRUP_0_BINARY : std_ulogic;
    signal GTP_CFG_PWRUP_1_BINARY : std_ulogic;
    signal MCOMMA_DETECT_0_BINARY : std_ulogic;
    signal MCOMMA_DETECT_1_BINARY : std_ulogic;
    signal OOB_CLK_DIVIDER_0_BINARY : std_logic_vector(2 downto 0);
    signal OOB_CLK_DIVIDER_1_BINARY : std_logic_vector(2 downto 0);
    signal PCI_EXPRESS_MODE_0_BINARY : std_ulogic;
    signal PCI_EXPRESS_MODE_1_BINARY : std_ulogic;
    signal PCOMMA_DETECT_0_BINARY : std_ulogic;
    signal PCOMMA_DETECT_1_BINARY : std_ulogic;
    signal PLL_DIVSEL_FB_0_BINARY : std_logic_vector(4 downto 0);
    signal PLL_DIVSEL_FB_1_BINARY : std_logic_vector(4 downto 0);
    signal PLL_DIVSEL_REF_0_BINARY : std_logic_vector(5 downto 0);
    signal PLL_DIVSEL_REF_1_BINARY : std_logic_vector(5 downto 0);
    signal PLL_RXDIVSEL_OUT_0_BINARY : std_logic_vector(1 downto 0);
    signal PLL_RXDIVSEL_OUT_1_BINARY : std_logic_vector(1 downto 0);
    signal PLL_SATA_0_BINARY : std_ulogic;
    signal PLL_SATA_1_BINARY : std_ulogic;
    signal PLL_SOURCE_0_BINARY : std_ulogic;
    signal PLL_SOURCE_1_BINARY : std_ulogic;
    signal PLL_TXDIVSEL_OUT_0_BINARY : std_logic_vector(1 downto 0);
    signal PLL_TXDIVSEL_OUT_1_BINARY : std_logic_vector(1 downto 0);
    signal RCV_TERM_GND_0_BINARY : std_ulogic;
    signal RCV_TERM_GND_1_BINARY : std_ulogic;
    signal RCV_TERM_VTTRX_0_BINARY : std_ulogic;
    signal RCV_TERM_VTTRX_1_BINARY : std_ulogic;
    signal RX_BUFFER_USE_0_BINARY : std_ulogic;
    signal RX_BUFFER_USE_1_BINARY : std_ulogic;
    signal RX_DECODE_SEQ_MATCH_0_BINARY : std_ulogic;
    signal RX_DECODE_SEQ_MATCH_1_BINARY : std_ulogic;
    signal RX_EN_IDLE_HOLD_CDR_0_BINARY : std_ulogic;
    signal RX_EN_IDLE_HOLD_CDR_1_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_BUF_0_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_BUF_1_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_FR_0_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_FR_1_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_PH_0_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_PH_1_BINARY : std_ulogic;
    signal RX_EN_MODE_RESET_BUF_0_BINARY : std_ulogic;
    signal RX_EN_MODE_RESET_BUF_1_BINARY : std_ulogic;
    signal RX_LOSS_OF_SYNC_FSM_0_BINARY : std_ulogic;
    signal RX_LOSS_OF_SYNC_FSM_1_BINARY : std_ulogic;
    signal RX_LOS_INVALID_INCR_0_BINARY : std_logic_vector(2 downto 0);
    signal RX_LOS_INVALID_INCR_1_BINARY : std_logic_vector(2 downto 0);
    signal RX_LOS_THRESHOLD_0_BINARY : std_logic_vector(2 downto 0);
    signal RX_LOS_THRESHOLD_1_BINARY : std_logic_vector(2 downto 0);
    signal RX_SLIDE_MODE_0_BINARY : std_ulogic;
    signal RX_SLIDE_MODE_1_BINARY : std_ulogic;
    signal RX_STATUS_FMT_0_BINARY : std_ulogic;
    signal RX_STATUS_FMT_1_BINARY : std_ulogic;
    signal RX_XCLK_SEL_0_BINARY : std_ulogic;
    signal RX_XCLK_SEL_1_BINARY : std_ulogic;
    signal SATA_MAX_BURST_0_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_BURST_1_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_INIT_0_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_INIT_1_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_WAKE_0_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_WAKE_1_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_BURST_0_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_BURST_1_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_INIT_0_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_INIT_1_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_WAKE_0_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_WAKE_1_BINARY : std_logic_vector(5 downto 0);
    signal SIM_GTPRESET_SPEEDUP_BINARY : std_ulogic;
    signal SIM_RECEIVER_DETECT_PASS_BINARY : std_ulogic;
    signal SIM_TX_ELEC_IDLE_LEVEL_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    signal TERMINATION_OVRD_0_BINARY : std_ulogic;
    signal TERMINATION_OVRD_1_BINARY : std_ulogic;
    signal TX_BUFFER_USE_0_BINARY : std_ulogic;
    signal TX_BUFFER_USE_1_BINARY : std_ulogic;
    signal TX_XCLK_SEL_0_BINARY : std_ulogic;
    signal TX_XCLK_SEL_1_BINARY : std_ulogic;
    
    signal DRDY_out : std_ulogic;
    signal DRPDO_out : std_logic_vector(15 downto 0);
    signal GTPCLKFBEAST_out : std_logic_vector(1 downto 0);
    signal GTPCLKFBWEST_out : std_logic_vector(1 downto 0);
    signal GTPCLKOUT0_out : std_logic_vector(1 downto 0);
    signal GTPCLKOUT1_out : std_logic_vector(1 downto 0);
    signal PHYSTATUS0_out : std_ulogic;
    signal PHYSTATUS1_out : std_ulogic;
    signal PLLLKDET0_out : std_ulogic;
    signal PLLLKDET1_out : std_ulogic;
    signal RCALOUTEAST_out : std_logic_vector(4 downto 0);
    signal RCALOUTWEST_out : std_logic_vector(4 downto 0);
    signal REFCLKOUT0_out : std_ulogic;
    signal REFCLKOUT1_out : std_ulogic;
    signal REFCLKPLL0_out : std_ulogic;
    signal REFCLKPLL1_out : std_ulogic;
    signal RESETDONE0_out : std_ulogic;
    signal RESETDONE1_out : std_ulogic;
    signal RXBUFSTATUS0_out : std_logic_vector(2 downto 0);
    signal RXBUFSTATUS1_out : std_logic_vector(2 downto 0);
    signal RXBYTEISALIGNED0_out : std_ulogic;
    signal RXBYTEISALIGNED1_out : std_ulogic;
    signal RXBYTEREALIGN0_out : std_ulogic;
    signal RXBYTEREALIGN1_out : std_ulogic;
    signal RXCHANBONDSEQ0_out : std_ulogic;
    signal RXCHANBONDSEQ1_out : std_ulogic;
    signal RXCHANISALIGNED0_out : std_ulogic;
    signal RXCHANISALIGNED1_out : std_ulogic;
    signal RXCHANREALIGN0_out : std_ulogic;
    signal RXCHANREALIGN1_out : std_ulogic;
    signal RXCHARISCOMMA0_out : std_logic_vector(3 downto 0);
    signal RXCHARISCOMMA1_out : std_logic_vector(3 downto 0);
    signal RXCHARISK0_out : std_logic_vector(3 downto 0);
    signal RXCHARISK1_out : std_logic_vector(3 downto 0);
    signal RXCHBONDO_out : std_logic_vector(2 downto 0);
    signal RXCLKCORCNT0_out : std_logic_vector(2 downto 0);
    signal RXCLKCORCNT1_out : std_logic_vector(2 downto 0);
    signal RXCOMMADET0_out : std_ulogic;
    signal RXCOMMADET1_out : std_ulogic;
    signal RXDATA0_out : std_logic_vector(31 downto 0);
    signal RXDATA1_out : std_logic_vector(31 downto 0);
    signal RXDISPERR0_out : std_logic_vector(3 downto 0);
    signal RXDISPERR1_out : std_logic_vector(3 downto 0);
    signal RXELECIDLE0_out : std_ulogic;
    signal RXELECIDLE1_out : std_ulogic;
    signal RXLOSSOFSYNC0_out : std_logic_vector(1 downto 0);
    signal RXLOSSOFSYNC1_out : std_logic_vector(1 downto 0);
    signal RXNOTINTABLE0_out : std_logic_vector(3 downto 0);
    signal RXNOTINTABLE1_out : std_logic_vector(3 downto 0);
    signal RXPRBSERR0_out : std_ulogic;
    signal RXPRBSERR1_out : std_ulogic;
    signal RXRECCLK0_out : std_ulogic;
    signal RXRECCLK1_out : std_ulogic;
    signal RXRUNDISP0_out : std_logic_vector(3 downto 0);
    signal RXRUNDISP1_out : std_logic_vector(3 downto 0);
    signal RXSTATUS0_out : std_logic_vector(2 downto 0);
    signal RXSTATUS1_out : std_logic_vector(2 downto 0);
    signal RXVALID0_out : std_ulogic;
    signal RXVALID1_out : std_ulogic;
    signal TSTOUT0_out : std_logic_vector(4 downto 0);
    signal TSTOUT1_out : std_logic_vector(4 downto 0);
    signal TXBUFSTATUS0_out : std_logic_vector(1 downto 0);
    signal TXBUFSTATUS1_out : std_logic_vector(1 downto 0);
    signal TXKERR0_out : std_logic_vector(3 downto 0);
    signal TXKERR1_out : std_logic_vector(3 downto 0);
    signal TXN0_out : std_ulogic;
    signal TXN1_out : std_ulogic;
    signal TXOUTCLK0_out : std_ulogic;
    signal TXOUTCLK1_out : std_ulogic;
    signal TXP0_out : std_ulogic;
    signal TXP1_out : std_ulogic;
    signal TXRUNDISP0_out : std_logic_vector(3 downto 0);
    signal TXRUNDISP1_out : std_logic_vector(3 downto 0);
    
    signal DRDY_outdelay : std_ulogic;
    signal DRPDO_outdelay : std_logic_vector(15 downto 0);
    signal GTPCLKFBEAST_outdelay : std_logic_vector(1 downto 0);
    signal GTPCLKFBWEST_outdelay : std_logic_vector(1 downto 0);
    signal GTPCLKOUT0_outdelay : std_logic_vector(1 downto 0);
    signal GTPCLKOUT1_outdelay : std_logic_vector(1 downto 0);
    signal PHYSTATUS0_outdelay : std_ulogic;
    signal PHYSTATUS1_outdelay : std_ulogic;
    signal PLLLKDET0_outdelay : std_ulogic;
    signal PLLLKDET1_outdelay : std_ulogic;
    signal RCALOUTEAST_outdelay : std_logic_vector(4 downto 0);
    signal RCALOUTWEST_outdelay : std_logic_vector(4 downto 0);
    signal REFCLKOUT0_outdelay : std_ulogic;
    signal REFCLKOUT1_outdelay : std_ulogic;
    signal REFCLKPLL0_outdelay : std_ulogic;
    signal REFCLKPLL1_outdelay : std_ulogic;
    signal RESETDONE0_outdelay : std_ulogic;
    signal RESETDONE1_outdelay : std_ulogic;
    signal RXBUFSTATUS0_outdelay : std_logic_vector(2 downto 0);
    signal RXBUFSTATUS1_outdelay : std_logic_vector(2 downto 0);
    signal RXBYTEISALIGNED0_outdelay : std_ulogic;
    signal RXBYTEISALIGNED1_outdelay : std_ulogic;
    signal RXBYTEREALIGN0_outdelay : std_ulogic;
    signal RXBYTEREALIGN1_outdelay : std_ulogic;
    signal RXCHANBONDSEQ0_outdelay : std_ulogic;
    signal RXCHANBONDSEQ1_outdelay : std_ulogic;
    signal RXCHANISALIGNED0_outdelay : std_ulogic;
    signal RXCHANISALIGNED1_outdelay : std_ulogic;
    signal RXCHANREALIGN0_outdelay : std_ulogic;
    signal RXCHANREALIGN1_outdelay : std_ulogic;
    signal RXCHARISCOMMA0_outdelay : std_logic_vector(3 downto 0);
    signal RXCHARISCOMMA1_outdelay : std_logic_vector(3 downto 0);
    signal RXCHARISK0_outdelay : std_logic_vector(3 downto 0);
    signal RXCHARISK1_outdelay : std_logic_vector(3 downto 0);
    signal RXCHBONDO_outdelay : std_logic_vector(2 downto 0);
    signal RXCLKCORCNT0_outdelay : std_logic_vector(2 downto 0);
    signal RXCLKCORCNT1_outdelay : std_logic_vector(2 downto 0);
    signal RXCOMMADET0_outdelay : std_ulogic;
    signal RXCOMMADET1_outdelay : std_ulogic;
    signal RXDATA0_outdelay : std_logic_vector(31 downto 0);
    signal RXDATA1_outdelay : std_logic_vector(31 downto 0);
    signal RXDISPERR0_outdelay : std_logic_vector(3 downto 0);
    signal RXDISPERR1_outdelay : std_logic_vector(3 downto 0);
    signal RXELECIDLE0_outdelay : std_ulogic;
    signal RXELECIDLE1_outdelay : std_ulogic;
    signal RXLOSSOFSYNC0_outdelay : std_logic_vector(1 downto 0);
    signal RXLOSSOFSYNC1_outdelay : std_logic_vector(1 downto 0);
    signal RXNOTINTABLE0_outdelay : std_logic_vector(3 downto 0);
    signal RXNOTINTABLE1_outdelay : std_logic_vector(3 downto 0);
    signal RXPRBSERR0_outdelay : std_ulogic;
    signal RXPRBSERR1_outdelay : std_ulogic;
    signal RXRECCLK0_outdelay : std_ulogic;
    signal RXRECCLK1_outdelay : std_ulogic;
    signal RXRUNDISP0_outdelay : std_logic_vector(3 downto 0);
    signal RXRUNDISP1_outdelay : std_logic_vector(3 downto 0);
    signal RXSTATUS0_outdelay : std_logic_vector(2 downto 0);
    signal RXSTATUS1_outdelay : std_logic_vector(2 downto 0);
    signal RXVALID0_outdelay : std_ulogic;
    signal RXVALID1_outdelay : std_ulogic;
    signal TSTOUT0_outdelay : std_logic_vector(4 downto 0);
    signal TSTOUT1_outdelay : std_logic_vector(4 downto 0);
    signal TXBUFSTATUS0_outdelay : std_logic_vector(1 downto 0);
    signal TXBUFSTATUS1_outdelay : std_logic_vector(1 downto 0);
    signal TXKERR0_outdelay : std_logic_vector(3 downto 0);
    signal TXKERR1_outdelay : std_logic_vector(3 downto 0);
    signal TXN0_outdelay : std_ulogic;
    signal TXN1_outdelay : std_ulogic;
    signal TXOUTCLK0_outdelay : std_ulogic;
    signal TXOUTCLK1_outdelay : std_ulogic;
    signal TXP0_outdelay : std_ulogic;
    signal TXP1_outdelay : std_ulogic;
    signal TXRUNDISP0_outdelay : std_logic_vector(3 downto 0);
    signal TXRUNDISP1_outdelay : std_logic_vector(3 downto 0);
    
    signal CLK00_in : std_ulogic;
    signal CLK01_in : std_ulogic;
    signal CLK10_in : std_ulogic;
    signal CLK11_in : std_ulogic;
    signal CLKINEAST0_in : std_ulogic;
    signal CLKINEAST1_in : std_ulogic;
    signal CLKINWEST0_in : std_ulogic;
    signal CLKINWEST1_in : std_ulogic;
    signal DADDR_in : std_logic_vector(7 downto 0);
    signal DCLK_in : std_ulogic;
    signal DEN_in : std_ulogic;
    signal DI_in : std_logic_vector(15 downto 0);
    signal DWE_in : std_ulogic;
    signal GATERXELECIDLE0_in : std_ulogic;
    signal GATERXELECIDLE1_in : std_ulogic;
    signal GCLK00_in : std_ulogic;
    signal GCLK01_in : std_ulogic;
    signal GCLK10_in : std_ulogic;
    signal GCLK11_in : std_ulogic;
    signal GTPCLKFBSEL0EAST_in : std_logic_vector(1 downto 0);
    signal GTPCLKFBSEL0WEST_in : std_logic_vector(1 downto 0);
    signal GTPCLKFBSEL1EAST_in : std_logic_vector(1 downto 0);
    signal GTPCLKFBSEL1WEST_in : std_logic_vector(1 downto 0);
    signal GTPRESET0_in : std_ulogic;
    signal GTPRESET1_in : std_ulogic;
    signal GTPTEST0_in : std_logic_vector(7 downto 0);
    signal GTPTEST1_in : std_logic_vector(7 downto 0);
    signal IGNORESIGDET0_in : std_ulogic;
    signal IGNORESIGDET1_in : std_ulogic;
    signal INTDATAWIDTH0_in : std_ulogic;
    signal INTDATAWIDTH1_in : std_ulogic;
    signal LOOPBACK0_in : std_logic_vector(2 downto 0);
    signal LOOPBACK1_in : std_logic_vector(2 downto 0);
    signal PLLCLK00_in : std_ulogic;
    signal PLLCLK01_in : std_ulogic;
    signal PLLCLK10_in : std_ulogic;
    signal PLLCLK11_in : std_ulogic;
    signal PLLLKDETEN0_in : std_ulogic;
    signal PLLLKDETEN1_in : std_ulogic;
    signal PLLPOWERDOWN0_in : std_ulogic;
    signal PLLPOWERDOWN1_in : std_ulogic;
    signal PRBSCNTRESET0_in : std_ulogic;
    signal PRBSCNTRESET1_in : std_ulogic;
    signal RCALINEAST_in : std_logic_vector(4 downto 0);
    signal RCALINWEST_in : std_logic_vector(4 downto 0);
    signal REFCLKPWRDNB0_in : std_ulogic;
    signal REFCLKPWRDNB1_in : std_ulogic;
    signal REFSELDYPLL0_in : std_logic_vector(2 downto 0);
    signal REFSELDYPLL1_in : std_logic_vector(2 downto 0);
    signal RXBUFRESET0_in : std_ulogic;
    signal RXBUFRESET1_in : std_ulogic;
    signal RXCDRRESET0_in : std_ulogic;
    signal RXCDRRESET1_in : std_ulogic;
    signal RXCHBONDI_in : std_logic_vector(2 downto 0);
    signal RXCHBONDMASTER0_in : std_ulogic;
    signal RXCHBONDMASTER1_in : std_ulogic;
    signal RXCHBONDSLAVE0_in : std_ulogic;
    signal RXCHBONDSLAVE1_in : std_ulogic;
    signal RXCOMMADETUSE0_in : std_ulogic;
    signal RXCOMMADETUSE1_in : std_ulogic;
    signal RXDATAWIDTH0_in : std_logic_vector(1 downto 0);
    signal RXDATAWIDTH1_in : std_logic_vector(1 downto 0);
    signal RXDEC8B10BUSE0_in : std_ulogic;
    signal RXDEC8B10BUSE1_in : std_ulogic;
    signal RXENCHANSYNC0_in : std_ulogic;
    signal RXENCHANSYNC1_in : std_ulogic;
    signal RXENMCOMMAALIGN0_in : std_ulogic;
    signal RXENMCOMMAALIGN1_in : std_ulogic;
    signal RXENPCOMMAALIGN0_in : std_ulogic;
    signal RXENPCOMMAALIGN1_in : std_ulogic;
    signal RXENPMAPHASEALIGN0_in : std_ulogic;
    signal RXENPMAPHASEALIGN1_in : std_ulogic;
    signal RXENPRBSTST0_in : std_logic_vector(2 downto 0);
    signal RXENPRBSTST1_in : std_logic_vector(2 downto 0);
    signal RXEQMIX0_in : std_logic_vector(1 downto 0);
    signal RXEQMIX1_in : std_logic_vector(1 downto 0);
    signal RXN0_in : std_ulogic;
    signal RXN1_in : std_ulogic;
    signal RXP0_in : std_ulogic;
    signal RXP1_in : std_ulogic;
    signal RXPMASETPHASE0_in : std_ulogic;
    signal RXPMASETPHASE1_in : std_ulogic;
    signal RXPOLARITY0_in : std_ulogic;
    signal RXPOLARITY1_in : std_ulogic;
    signal RXPOWERDOWN0_in : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN1_in : std_logic_vector(1 downto 0);
    signal RXRESET0_in : std_ulogic;
    signal RXRESET1_in : std_ulogic;
    signal RXSLIDE0_in : std_ulogic;
    signal RXSLIDE1_in : std_ulogic;
    signal RXUSRCLK0_in : std_ulogic;
    signal RXUSRCLK1_in : std_ulogic;
    signal RXUSRCLK20_in : std_ulogic;
    signal RXUSRCLK21_in : std_ulogic;
    signal TSTCLK0_in : std_ulogic;
    signal TSTCLK1_in : std_ulogic;
    signal TSTIN0_in : std_logic_vector(11 downto 0);
    signal TSTIN1_in : std_logic_vector(11 downto 0);
    signal TXBUFDIFFCTRL0_in : std_logic_vector(2 downto 0);
    signal TXBUFDIFFCTRL1_in : std_logic_vector(2 downto 0);
    signal TXBYPASS8B10B0_in : std_logic_vector(3 downto 0);
    signal TXBYPASS8B10B1_in : std_logic_vector(3 downto 0);
    signal TXCHARDISPMODE0_in : std_logic_vector(3 downto 0);
    signal TXCHARDISPMODE1_in : std_logic_vector(3 downto 0);
    signal TXCHARDISPVAL0_in : std_logic_vector(3 downto 0);
    signal TXCHARDISPVAL1_in : std_logic_vector(3 downto 0);
    signal TXCHARISK0_in : std_logic_vector(3 downto 0);
    signal TXCHARISK1_in : std_logic_vector(3 downto 0);
    signal TXCOMSTART0_in : std_ulogic;
    signal TXCOMSTART1_in : std_ulogic;
    signal TXCOMTYPE0_in : std_ulogic;
    signal TXCOMTYPE1_in : std_ulogic;
    signal TXDATA0_in : std_logic_vector(31 downto 0);
    signal TXDATA1_in : std_logic_vector(31 downto 0);
    signal TXDATAWIDTH0_in : std_logic_vector(1 downto 0);
    signal TXDATAWIDTH1_in : std_logic_vector(1 downto 0);
    signal TXDETECTRX0_in : std_ulogic;
    signal TXDETECTRX1_in : std_ulogic;
    signal TXDIFFCTRL0_in : std_logic_vector(3 downto 0);
    signal TXDIFFCTRL1_in : std_logic_vector(3 downto 0);
    signal TXELECIDLE0_in : std_ulogic;
    signal TXELECIDLE1_in : std_ulogic;
    signal TXENC8B10BUSE0_in : std_ulogic;
    signal TXENC8B10BUSE1_in : std_ulogic;
    signal TXENPMAPHASEALIGN0_in : std_ulogic;
    signal TXENPMAPHASEALIGN1_in : std_ulogic;
    signal TXENPRBSTST0_in : std_logic_vector(2 downto 0);
    signal TXENPRBSTST1_in : std_logic_vector(2 downto 0);
    signal TXINHIBIT0_in : std_ulogic;
    signal TXINHIBIT1_in : std_ulogic;
    signal TXPDOWNASYNCH0_in : std_ulogic;
    signal TXPDOWNASYNCH1_in : std_ulogic;
    signal TXPMASETPHASE0_in : std_ulogic;
    signal TXPMASETPHASE1_in : std_ulogic;
    signal TXPOLARITY0_in : std_ulogic;
    signal TXPOLARITY1_in : std_ulogic;
    signal TXPOWERDOWN0_in : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN1_in : std_logic_vector(1 downto 0);
    signal TXPRBSFORCEERR0_in : std_ulogic;
    signal TXPRBSFORCEERR1_in : std_ulogic;
    signal TXPREEMPHASIS0_in : std_logic_vector(2 downto 0);
    signal TXPREEMPHASIS1_in : std_logic_vector(2 downto 0);
    signal TXRESET0_in : std_ulogic;
    signal TXRESET1_in : std_ulogic;
    signal TXUSRCLK0_in : std_ulogic;
    signal TXUSRCLK1_in : std_ulogic;
    signal TXUSRCLK20_in : std_ulogic;
    signal TXUSRCLK21_in : std_ulogic;
    signal USRCODEERR0_in : std_ulogic;
    signal USRCODEERR1_in : std_ulogic;
    
    signal CLK00_indelay : std_ulogic;
    signal CLK01_indelay : std_ulogic;
    signal CLK10_indelay : std_ulogic;
    signal CLK11_indelay : std_ulogic;
    signal CLKINEAST0_indelay : std_ulogic;
    signal CLKINEAST1_indelay : std_ulogic;
    signal CLKINWEST0_indelay : std_ulogic;
    signal CLKINWEST1_indelay : std_ulogic;
    signal DADDR_indelay : std_logic_vector(7 downto 0);
    signal DCLK_indelay : std_ulogic;
    signal DEN_indelay : std_ulogic;
    signal DI_indelay : std_logic_vector(15 downto 0);
    signal DWE_indelay : std_ulogic;
    signal GATERXELECIDLE0_indelay : std_ulogic;
    signal GATERXELECIDLE1_indelay : std_ulogic;
    signal GCLK00_indelay : std_ulogic;
    signal GCLK01_indelay : std_ulogic;
    signal GCLK10_indelay : std_ulogic;
    signal GCLK11_indelay : std_ulogic;
    signal GTPCLKFBSEL0EAST_indelay : std_logic_vector(1 downto 0);
    signal GTPCLKFBSEL0WEST_indelay : std_logic_vector(1 downto 0);
    signal GTPCLKFBSEL1EAST_indelay : std_logic_vector(1 downto 0);
    signal GTPCLKFBSEL1WEST_indelay : std_logic_vector(1 downto 0);
    signal GTPRESET0_indelay : std_ulogic;
    signal GTPRESET1_indelay : std_ulogic;
    signal GTPTEST0_indelay : std_logic_vector(7 downto 0);
    signal GTPTEST1_indelay : std_logic_vector(7 downto 0);
    signal IGNORESIGDET0_indelay : std_ulogic;
    signal IGNORESIGDET1_indelay : std_ulogic;
    signal INTDATAWIDTH0_indelay : std_ulogic;
    signal INTDATAWIDTH1_indelay : std_ulogic;
    signal LOOPBACK0_indelay : std_logic_vector(2 downto 0);
    signal LOOPBACK1_indelay : std_logic_vector(2 downto 0);
    signal PLLCLK00_indelay : std_ulogic;
    signal PLLCLK01_indelay : std_ulogic;
    signal PLLCLK10_indelay : std_ulogic;
    signal PLLCLK11_indelay : std_ulogic;
    signal PLLLKDETEN0_indelay : std_ulogic;
    signal PLLLKDETEN1_indelay : std_ulogic;
    signal PLLPOWERDOWN0_indelay : std_ulogic;
    signal PLLPOWERDOWN1_indelay : std_ulogic;
    signal PRBSCNTRESET0_indelay : std_ulogic;
    signal PRBSCNTRESET1_indelay : std_ulogic;
    signal RCALINEAST_indelay : std_logic_vector(4 downto 0);
    signal RCALINWEST_indelay : std_logic_vector(4 downto 0);
    signal REFCLKPWRDNB0_indelay : std_ulogic;
    signal REFCLKPWRDNB1_indelay : std_ulogic;
    signal REFSELDYPLL0_indelay : std_logic_vector(2 downto 0);
    signal REFSELDYPLL1_indelay : std_logic_vector(2 downto 0);
    signal RXBUFRESET0_indelay : std_ulogic;
    signal RXBUFRESET1_indelay : std_ulogic;
    signal RXCDRRESET0_indelay : std_ulogic;
    signal RXCDRRESET1_indelay : std_ulogic;
    signal RXCHBONDI_indelay : std_logic_vector(2 downto 0);
    signal RXCHBONDMASTER0_indelay : std_ulogic;
    signal RXCHBONDMASTER1_indelay : std_ulogic;
    signal RXCHBONDSLAVE0_indelay : std_ulogic;
    signal RXCHBONDSLAVE1_indelay : std_ulogic;
    signal RXCOMMADETUSE0_indelay : std_ulogic;
    signal RXCOMMADETUSE1_indelay : std_ulogic;
    signal RXDATAWIDTH0_indelay : std_logic_vector(1 downto 0);
    signal RXDATAWIDTH1_indelay : std_logic_vector(1 downto 0);
    signal RXDEC8B10BUSE0_indelay : std_ulogic;
    signal RXDEC8B10BUSE1_indelay : std_ulogic;
    signal RXENCHANSYNC0_indelay : std_ulogic;
    signal RXENCHANSYNC1_indelay : std_ulogic;
    signal RXENMCOMMAALIGN0_indelay : std_ulogic;
    signal RXENMCOMMAALIGN1_indelay : std_ulogic;
    signal RXENPCOMMAALIGN0_indelay : std_ulogic;
    signal RXENPCOMMAALIGN1_indelay : std_ulogic;
    signal RXENPMAPHASEALIGN0_indelay : std_ulogic;
    signal RXENPMAPHASEALIGN1_indelay : std_ulogic;
    signal RXENPRBSTST0_indelay : std_logic_vector(2 downto 0);
    signal RXENPRBSTST1_indelay : std_logic_vector(2 downto 0);
    signal RXEQMIX0_indelay : std_logic_vector(1 downto 0);
    signal RXEQMIX1_indelay : std_logic_vector(1 downto 0);
    signal RXN0_indelay : std_ulogic;
    signal RXN1_indelay : std_ulogic;
    signal RXP0_indelay : std_ulogic;
    signal RXP1_indelay : std_ulogic;
    signal RXPMASETPHASE0_indelay : std_ulogic;
    signal RXPMASETPHASE1_indelay : std_ulogic;
    signal RXPOLARITY0_indelay : std_ulogic;
    signal RXPOLARITY1_indelay : std_ulogic;
    signal RXPOWERDOWN0_indelay : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN1_indelay : std_logic_vector(1 downto 0);
    signal RXRESET0_indelay : std_ulogic;
    signal RXRESET1_indelay : std_ulogic;
    signal RXSLIDE0_indelay : std_ulogic;
    signal RXSLIDE1_indelay : std_ulogic;
    signal RXUSRCLK0_indelay : std_ulogic;
    signal RXUSRCLK1_indelay : std_ulogic;
    signal RXUSRCLK20_indelay : std_ulogic;
    signal RXUSRCLK21_indelay : std_ulogic;
    signal TSTCLK0_indelay : std_ulogic;
    signal TSTCLK1_indelay : std_ulogic;
    signal TSTIN0_indelay : std_logic_vector(11 downto 0);
    signal TSTIN1_indelay : std_logic_vector(11 downto 0);
    signal TXBUFDIFFCTRL0_indelay : std_logic_vector(2 downto 0);
    signal TXBUFDIFFCTRL1_indelay : std_logic_vector(2 downto 0);
    signal TXBYPASS8B10B0_indelay : std_logic_vector(3 downto 0);
    signal TXBYPASS8B10B1_indelay : std_logic_vector(3 downto 0);
    signal TXCHARDISPMODE0_indelay : std_logic_vector(3 downto 0);
    signal TXCHARDISPMODE1_indelay : std_logic_vector(3 downto 0);
    signal TXCHARDISPVAL0_indelay : std_logic_vector(3 downto 0);
    signal TXCHARDISPVAL1_indelay : std_logic_vector(3 downto 0);
    signal TXCHARISK0_indelay : std_logic_vector(3 downto 0);
    signal TXCHARISK1_indelay : std_logic_vector(3 downto 0);
    signal TXCOMSTART0_indelay : std_ulogic;
    signal TXCOMSTART1_indelay : std_ulogic;
    signal TXCOMTYPE0_indelay : std_ulogic;
    signal TXCOMTYPE1_indelay : std_ulogic;
    signal TXDATA0_indelay : std_logic_vector(31 downto 0);
    signal TXDATA1_indelay : std_logic_vector(31 downto 0);
    signal TXDATAWIDTH0_indelay : std_logic_vector(1 downto 0);
    signal TXDATAWIDTH1_indelay : std_logic_vector(1 downto 0);
    signal TXDETECTRX0_indelay : std_ulogic;
    signal TXDETECTRX1_indelay : std_ulogic;
    signal TXDIFFCTRL0_indelay : std_logic_vector(3 downto 0);
    signal TXDIFFCTRL1_indelay : std_logic_vector(3 downto 0);
    signal TXELECIDLE0_indelay : std_ulogic;
    signal TXELECIDLE1_indelay : std_ulogic;
    signal TXENC8B10BUSE0_indelay : std_ulogic;
    signal TXENC8B10BUSE1_indelay : std_ulogic;
    signal TXENPMAPHASEALIGN0_indelay : std_ulogic;
    signal TXENPMAPHASEALIGN1_indelay : std_ulogic;
    signal TXENPRBSTST0_indelay : std_logic_vector(2 downto 0);
    signal TXENPRBSTST1_indelay : std_logic_vector(2 downto 0);
    signal TXINHIBIT0_indelay : std_ulogic;
    signal TXINHIBIT1_indelay : std_ulogic;
    signal TXPDOWNASYNCH0_indelay : std_ulogic;
    signal TXPDOWNASYNCH1_indelay : std_ulogic;
    signal TXPMASETPHASE0_indelay : std_ulogic;
    signal TXPMASETPHASE1_indelay : std_ulogic;
    signal TXPOLARITY0_indelay : std_ulogic;
    signal TXPOLARITY1_indelay : std_ulogic;
    signal TXPOWERDOWN0_indelay : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN1_indelay : std_logic_vector(1 downto 0);
    signal TXPRBSFORCEERR0_indelay : std_ulogic;
    signal TXPRBSFORCEERR1_indelay : std_ulogic;
    signal TXPREEMPHASIS0_indelay : std_logic_vector(2 downto 0);
    signal TXPREEMPHASIS1_indelay : std_logic_vector(2 downto 0);
    signal TXRESET0_indelay : std_ulogic;
    signal TXRESET1_indelay : std_ulogic;
    signal TXUSRCLK0_indelay : std_ulogic;
    signal TXUSRCLK1_indelay : std_ulogic;
    signal TXUSRCLK20_indelay : std_ulogic;
    signal TXUSRCLK21_indelay : std_ulogic;
    signal USRCODEERR0_indelay : std_ulogic;
    signal USRCODEERR1_indelay : std_ulogic;
    
    signal GSR_dly : std_ulogic := '0';

    begin
    GTPCLKOUT0_out <= GTPCLKOUT0_outdelay after OUTCLK_DELAY;
    GTPCLKOUT1_out <= GTPCLKOUT1_outdelay after OUTCLK_DELAY;
    REFCLKPLL0_out <= REFCLKPLL0_outdelay after OUTCLK_DELAY;
    REFCLKPLL1_out <= REFCLKPLL1_outdelay after OUTCLK_DELAY;
    
    DRDY_out <= DRDY_outdelay after OUT_DELAY;
    DRPDO_out <= DRPDO_outdelay after OUT_DELAY;
    GTPCLKFBEAST_out <= GTPCLKFBEAST_outdelay after OUT_DELAY;
    GTPCLKFBWEST_out <= GTPCLKFBWEST_outdelay after OUT_DELAY;
    PHYSTATUS0_out <= PHYSTATUS0_outdelay after OUT_DELAY;
    PHYSTATUS1_out <= PHYSTATUS1_outdelay after OUT_DELAY;
    PLLLKDET0_out <= PLLLKDET0_outdelay after OUT_DELAY;
    PLLLKDET1_out <= PLLLKDET1_outdelay after OUT_DELAY;
    RCALOUTEAST_out <= RCALOUTEAST_outdelay after OUT_DELAY;
    RCALOUTWEST_out <= RCALOUTWEST_outdelay after OUT_DELAY;
    REFCLKOUT0_out <= REFCLKOUT0_outdelay after OUT_DELAY;
    REFCLKOUT1_out <= REFCLKOUT1_outdelay after OUT_DELAY;
    RESETDONE0_out <= RESETDONE0_outdelay after OUT_DELAY;
    RESETDONE1_out <= RESETDONE1_outdelay after OUT_DELAY;
    RXBUFSTATUS0_out <= RXBUFSTATUS0_outdelay after OUT_DELAY;
    RXBUFSTATUS1_out <= RXBUFSTATUS1_outdelay after OUT_DELAY;
    RXBYTEISALIGNED0_out <= RXBYTEISALIGNED0_outdelay after OUT_DELAY;
    RXBYTEISALIGNED1_out <= RXBYTEISALIGNED1_outdelay after OUT_DELAY;
    RXBYTEREALIGN0_out <= RXBYTEREALIGN0_outdelay after OUT_DELAY;
    RXBYTEREALIGN1_out <= RXBYTEREALIGN1_outdelay after OUT_DELAY;
    RXCHANBONDSEQ0_out <= RXCHANBONDSEQ0_outdelay after OUT_DELAY;
    RXCHANBONDSEQ1_out <= RXCHANBONDSEQ1_outdelay after OUT_DELAY;
    RXCHANISALIGNED0_out <= RXCHANISALIGNED0_outdelay after OUT_DELAY;
    RXCHANISALIGNED1_out <= RXCHANISALIGNED1_outdelay after OUT_DELAY;
    RXCHANREALIGN0_out <= RXCHANREALIGN0_outdelay after OUT_DELAY;
    RXCHANREALIGN1_out <= RXCHANREALIGN1_outdelay after OUT_DELAY;
    RXCHARISCOMMA0_out <= RXCHARISCOMMA0_outdelay after OUT_DELAY;
    RXCHARISCOMMA1_out <= RXCHARISCOMMA1_outdelay after OUT_DELAY;
    RXCHARISK0_out <= RXCHARISK0_outdelay after OUT_DELAY;
    RXCHARISK1_out <= RXCHARISK1_outdelay after OUT_DELAY;
    RXCHBONDO_out <= RXCHBONDO_outdelay after OUT_DELAY;
    RXCLKCORCNT0_out <= RXCLKCORCNT0_outdelay after OUT_DELAY;
    RXCLKCORCNT1_out <= RXCLKCORCNT1_outdelay after OUT_DELAY;
    RXCOMMADET0_out <= RXCOMMADET0_outdelay after OUT_DELAY;
    RXCOMMADET1_out <= RXCOMMADET1_outdelay after OUT_DELAY;
    RXDATA0_out <= RXDATA0_outdelay after OUT_DELAY;
    RXDATA1_out <= RXDATA1_outdelay after OUT_DELAY;
    RXDISPERR0_out <= RXDISPERR0_outdelay after OUT_DELAY;
    RXDISPERR1_out <= RXDISPERR1_outdelay after OUT_DELAY;
    RXELECIDLE0_out <= RXELECIDLE0_outdelay after OUT_DELAY;
    RXELECIDLE1_out <= RXELECIDLE1_outdelay after OUT_DELAY;
    RXLOSSOFSYNC0_out <= RXLOSSOFSYNC0_outdelay after OUT_DELAY;
    RXLOSSOFSYNC1_out <= RXLOSSOFSYNC1_outdelay after OUT_DELAY;
    RXNOTINTABLE0_out <= RXNOTINTABLE0_outdelay after OUT_DELAY;
    RXNOTINTABLE1_out <= RXNOTINTABLE1_outdelay after OUT_DELAY;
    RXPRBSERR0_out <= RXPRBSERR0_outdelay after OUT_DELAY;
    RXPRBSERR1_out <= RXPRBSERR1_outdelay after OUT_DELAY;
    RXRECCLK0_out <= RXRECCLK0_outdelay after OUT_DELAY;
    RXRECCLK1_out <= RXRECCLK1_outdelay after OUT_DELAY;
    RXRUNDISP0_out <= RXRUNDISP0_outdelay after OUT_DELAY;
    RXRUNDISP1_out <= RXRUNDISP1_outdelay after OUT_DELAY;
    RXSTATUS0_out <= RXSTATUS0_outdelay after OUT_DELAY;
    RXSTATUS1_out <= RXSTATUS1_outdelay after OUT_DELAY;
    RXVALID0_out <= RXVALID0_outdelay after OUT_DELAY;
    RXVALID1_out <= RXVALID1_outdelay after OUT_DELAY;
    TSTOUT0_out <= TSTOUT0_outdelay after OUT_DELAY;
    TSTOUT1_out <= TSTOUT1_outdelay after OUT_DELAY;
    TXBUFSTATUS0_out <= TXBUFSTATUS0_outdelay after OUT_DELAY;
    TXBUFSTATUS1_out <= TXBUFSTATUS1_outdelay after OUT_DELAY;
    TXKERR0_out <= TXKERR0_outdelay after OUT_DELAY;
    TXKERR1_out <= TXKERR1_outdelay after OUT_DELAY;
    TXN0_out <= TXN0_outdelay after OUT_DELAY;
    TXN1_out <= TXN1_outdelay after OUT_DELAY;
    TXOUTCLK0_out <= TXOUTCLK0_outdelay after OUT_DELAY;
    TXOUTCLK1_out <= TXOUTCLK1_outdelay after OUT_DELAY;
    TXP0_out <= TXP0_outdelay after OUT_DELAY;
    TXP1_out <= TXP1_outdelay after OUT_DELAY;
    TXRUNDISP0_out <= TXRUNDISP0_outdelay after OUT_DELAY;
    TXRUNDISP1_out <= TXRUNDISP1_outdelay after OUT_DELAY;
    
    CLK00_in <= CLK00;
    CLK01_in <= CLK01;
    CLK10_in <= CLK10;
    CLK11_in <= CLK11;
    CLKINEAST0_in <= CLKINEAST0;
    CLKINEAST1_in <= CLKINEAST1;
    CLKINWEST0_in <= CLKINWEST0;
    CLKINWEST1_in <= CLKINWEST1;
    DCLK_in <= DCLK;
    GCLK00_in <= GCLK00;
    GCLK01_in <= GCLK01;
    GCLK10_in <= GCLK10;
    GCLK11_in <= GCLK11;
    PLLCLK00_in <= PLLCLK00;
    PLLCLK01_in <= PLLCLK01;
    PLLCLK10_in <= PLLCLK10;
    PLLCLK11_in <= PLLCLK11;
    RXUSRCLK0_in <= RXUSRCLK0;
    RXUSRCLK1_in <= RXUSRCLK1;
    RXUSRCLK20_in <= RXUSRCLK20;
    RXUSRCLK21_in <= RXUSRCLK21;
    TSTCLK0_in <= TSTCLK0;
    TSTCLK1_in <= TSTCLK1;
    TXUSRCLK0_in <= TXUSRCLK0;
    TXUSRCLK1_in <= TXUSRCLK1;
    TXUSRCLK20_in <= TXUSRCLK20;
    TXUSRCLK21_in <= TXUSRCLK21;
    
    DADDR_in <= DADDR;
    DEN_in <= DEN;
    DI_in <= DI;
    DWE_in <= DWE;
    GATERXELECIDLE0_in <= GATERXELECIDLE0;
    GATERXELECIDLE1_in <= GATERXELECIDLE1;
    GTPCLKFBSEL0EAST_in <= GTPCLKFBSEL0EAST;
    GTPCLKFBSEL0WEST_in <= GTPCLKFBSEL0WEST;
    GTPCLKFBSEL1EAST_in <= GTPCLKFBSEL1EAST;
    GTPCLKFBSEL1WEST_in <= GTPCLKFBSEL1WEST;
    GTPRESET0_in <= GTPRESET0;
    GTPRESET1_in <= GTPRESET1;
    GTPTEST0_in <= GTPTEST0;
    GTPTEST1_in <= GTPTEST1;
    IGNORESIGDET0_in <= IGNORESIGDET0;
    IGNORESIGDET1_in <= IGNORESIGDET1;
    INTDATAWIDTH0_in <= INTDATAWIDTH0;
    INTDATAWIDTH1_in <= INTDATAWIDTH1;
    LOOPBACK0_in <= LOOPBACK0;
    LOOPBACK1_in <= LOOPBACK1;
    PLLLKDETEN0_in <= PLLLKDETEN0;
    PLLLKDETEN1_in <= PLLLKDETEN1;
    PLLPOWERDOWN0_in <= PLLPOWERDOWN0;
    PLLPOWERDOWN1_in <= PLLPOWERDOWN1;
    PRBSCNTRESET0_in <= PRBSCNTRESET0;
    PRBSCNTRESET1_in <= PRBSCNTRESET1;
    RCALINEAST_in <= RCALINEAST;
    RCALINWEST_in <= RCALINWEST;
    REFCLKPWRDNB0_in <= REFCLKPWRDNB0;
    REFCLKPWRDNB1_in <= REFCLKPWRDNB1;
    REFSELDYPLL0_in <= REFSELDYPLL0;
    REFSELDYPLL1_in <= REFSELDYPLL1;
    RXBUFRESET0_in <= RXBUFRESET0;
    RXBUFRESET1_in <= RXBUFRESET1;
    RXCDRRESET0_in <= RXCDRRESET0;
    RXCDRRESET1_in <= RXCDRRESET1;
    RXCHBONDI_in <= RXCHBONDI;
    RXCHBONDMASTER0_in <= RXCHBONDMASTER0;
    RXCHBONDMASTER1_in <= RXCHBONDMASTER1;
    RXCHBONDSLAVE0_in <= RXCHBONDSLAVE0;
    RXCHBONDSLAVE1_in <= RXCHBONDSLAVE1;
    RXCOMMADETUSE0_in <= RXCOMMADETUSE0;
    RXCOMMADETUSE1_in <= RXCOMMADETUSE1;
    RXDATAWIDTH0_in <= RXDATAWIDTH0;
    RXDATAWIDTH1_in <= RXDATAWIDTH1;
    RXDEC8B10BUSE0_in <= RXDEC8B10BUSE0;
    RXDEC8B10BUSE1_in <= RXDEC8B10BUSE1;
    RXENCHANSYNC0_in <= RXENCHANSYNC0;
    RXENCHANSYNC1_in <= RXENCHANSYNC1;
    RXENMCOMMAALIGN0_in <= RXENMCOMMAALIGN0;
    RXENMCOMMAALIGN1_in <= RXENMCOMMAALIGN1;
    RXENPCOMMAALIGN0_in <= RXENPCOMMAALIGN0;
    RXENPCOMMAALIGN1_in <= RXENPCOMMAALIGN1;
    RXENPMAPHASEALIGN0_in <= RXENPMAPHASEALIGN0;
    RXENPMAPHASEALIGN1_in <= RXENPMAPHASEALIGN1;
    RXENPRBSTST0_in <= RXENPRBSTST0;
    RXENPRBSTST1_in <= RXENPRBSTST1;
    RXEQMIX0_in <= RXEQMIX0;
    RXEQMIX1_in <= RXEQMIX1;
    RXN0_in <= RXN0;
    RXN1_in <= RXN1;
    RXP0_in <= RXP0;
    RXP1_in <= RXP1;
    RXPMASETPHASE0_in <= RXPMASETPHASE0;
    RXPMASETPHASE1_in <= RXPMASETPHASE1;
    RXPOLARITY0_in <= RXPOLARITY0;
    RXPOLARITY1_in <= RXPOLARITY1;
    RXPOWERDOWN0_in <= RXPOWERDOWN0;
    RXPOWERDOWN1_in <= RXPOWERDOWN1;
    RXRESET0_in <= RXRESET0;
    RXRESET1_in <= RXRESET1;
    RXSLIDE0_in <= RXSLIDE0;
    RXSLIDE1_in <= RXSLIDE1;
    TSTIN0_in <= TSTIN0;
    TSTIN1_in <= TSTIN1;
    TXBUFDIFFCTRL0_in <= TXBUFDIFFCTRL0;
    TXBUFDIFFCTRL1_in <= TXBUFDIFFCTRL1;
    TXBYPASS8B10B0_in <= TXBYPASS8B10B0;
    TXBYPASS8B10B1_in <= TXBYPASS8B10B1;
    TXCHARDISPMODE0_in <= TXCHARDISPMODE0;
    TXCHARDISPMODE1_in <= TXCHARDISPMODE1;
    TXCHARDISPVAL0_in <= TXCHARDISPVAL0;
    TXCHARDISPVAL1_in <= TXCHARDISPVAL1;
    TXCHARISK0_in <= TXCHARISK0;
    TXCHARISK1_in <= TXCHARISK1;
    TXCOMSTART0_in <= TXCOMSTART0;
    TXCOMSTART1_in <= TXCOMSTART1;
    TXCOMTYPE0_in <= TXCOMTYPE0;
    TXCOMTYPE1_in <= TXCOMTYPE1;
    TXDATA0_in <= TXDATA0;
    TXDATA1_in <= TXDATA1;
    TXDATAWIDTH0_in <= TXDATAWIDTH0;
    TXDATAWIDTH1_in <= TXDATAWIDTH1;
    TXDETECTRX0_in <= TXDETECTRX0;
    TXDETECTRX1_in <= TXDETECTRX1;
    TXDIFFCTRL0_in <= TXDIFFCTRL0;
    TXDIFFCTRL1_in <= TXDIFFCTRL1;
    TXELECIDLE0_in <= TXELECIDLE0;
    TXELECIDLE1_in <= TXELECIDLE1;
    TXENC8B10BUSE0_in <= TXENC8B10BUSE0;
    TXENC8B10BUSE1_in <= TXENC8B10BUSE1;
    TXENPMAPHASEALIGN0_in <= TXENPMAPHASEALIGN0;
    TXENPMAPHASEALIGN1_in <= TXENPMAPHASEALIGN1;
    TXENPRBSTST0_in <= TXENPRBSTST0;
    TXENPRBSTST1_in <= TXENPRBSTST1;
    TXINHIBIT0_in <= TXINHIBIT0;
    TXINHIBIT1_in <= TXINHIBIT1;
    TXPDOWNASYNCH0_in <= TXPDOWNASYNCH0;
    TXPDOWNASYNCH1_in <= TXPDOWNASYNCH1;
    TXPMASETPHASE0_in <= TXPMASETPHASE0;
    TXPMASETPHASE1_in <= TXPMASETPHASE1;
    TXPOLARITY0_in <= TXPOLARITY0;
    TXPOLARITY1_in <= TXPOLARITY1;
    TXPOWERDOWN0_in <= TXPOWERDOWN0;
    TXPOWERDOWN1_in <= TXPOWERDOWN1;
    TXPRBSFORCEERR0_in <= TXPRBSFORCEERR0;
    TXPRBSFORCEERR1_in <= TXPRBSFORCEERR1;
    TXPREEMPHASIS0_in <= TXPREEMPHASIS0;
    TXPREEMPHASIS1_in <= TXPREEMPHASIS1;
    TXRESET0_in <= TXRESET0;
    TXRESET1_in <= TXRESET1;
    USRCODEERR0_in <= USRCODEERR0;
    USRCODEERR1_in <= USRCODEERR1;
    
    CLK00_indelay <= CLK00_in after INCLK_DELAY;
    CLK01_indelay <= CLK01_in after INCLK_DELAY;
    CLK10_indelay <= CLK10_in after INCLK_DELAY;
    CLK11_indelay <= CLK11_in after INCLK_DELAY;
    CLKINEAST0_indelay <= CLKINEAST0_in after INCLK_DELAY;
    CLKINEAST1_indelay <= CLKINEAST1_in after INCLK_DELAY;
    CLKINWEST0_indelay <= CLKINWEST0_in after INCLK_DELAY;
    CLKINWEST1_indelay <= CLKINWEST1_in after INCLK_DELAY;
    DCLK_indelay <= DCLK_in after INCLK_DELAY;
    GCLK00_indelay <= GCLK00_in after INCLK_DELAY;
    GCLK01_indelay <= GCLK01_in after INCLK_DELAY;
    GCLK10_indelay <= GCLK10_in after INCLK_DELAY;
    GCLK11_indelay <= GCLK11_in after INCLK_DELAY;
    PLLCLK00_indelay <= PLLCLK00_in after INCLK_DELAY;
    PLLCLK01_indelay <= PLLCLK01_in after INCLK_DELAY;
    PLLCLK10_indelay <= PLLCLK10_in after INCLK_DELAY;
    PLLCLK11_indelay <= PLLCLK11_in after INCLK_DELAY;
    RXUSRCLK0_indelay <= RXUSRCLK0_in after INCLK_DELAY;
    RXUSRCLK1_indelay <= RXUSRCLK1_in after INCLK_DELAY;
    RXUSRCLK20_indelay <= RXUSRCLK20_in after INCLK_DELAY;
    RXUSRCLK21_indelay <= RXUSRCLK21_in after INCLK_DELAY;
    TSTCLK0_indelay <= TSTCLK0_in after INCLK_DELAY;
    TSTCLK1_indelay <= TSTCLK1_in after INCLK_DELAY;
    TXUSRCLK0_indelay <= TXUSRCLK0_in after INCLK_DELAY;
    TXUSRCLK1_indelay <= TXUSRCLK1_in after INCLK_DELAY;
    TXUSRCLK20_indelay <= TXUSRCLK20_in after INCLK_DELAY;
    TXUSRCLK21_indelay <= TXUSRCLK21_in after INCLK_DELAY;
    
    DADDR_indelay <= DADDR_in after IN_DELAY;
    DEN_indelay <= DEN_in after IN_DELAY;
    DI_indelay <= DI_in after IN_DELAY;
    DWE_indelay <= DWE_in after IN_DELAY;
    GATERXELECIDLE0_indelay <= GATERXELECIDLE0_in after IN_DELAY;
    GATERXELECIDLE1_indelay <= GATERXELECIDLE1_in after IN_DELAY;
    GTPCLKFBSEL0EAST_indelay <= GTPCLKFBSEL0EAST_in after IN_DELAY;
    GTPCLKFBSEL0WEST_indelay <= GTPCLKFBSEL0WEST_in after IN_DELAY;
    GTPCLKFBSEL1EAST_indelay <= GTPCLKFBSEL1EAST_in after IN_DELAY;
    GTPCLKFBSEL1WEST_indelay <= GTPCLKFBSEL1WEST_in after IN_DELAY;
    GTPRESET0_indelay <= GTPRESET0_in after IN_DELAY;
    GTPRESET1_indelay <= GTPRESET1_in after IN_DELAY;
    GTPTEST0_indelay <= GTPTEST0_in after IN_DELAY;
    GTPTEST1_indelay <= GTPTEST1_in after IN_DELAY;
    IGNORESIGDET0_indelay <= IGNORESIGDET0_in after IN_DELAY;
    IGNORESIGDET1_indelay <= IGNORESIGDET1_in after IN_DELAY;
    INTDATAWIDTH0_indelay <= INTDATAWIDTH0_in after IN_DELAY;
    INTDATAWIDTH1_indelay <= INTDATAWIDTH1_in after IN_DELAY;
    LOOPBACK0_indelay <= LOOPBACK0_in after IN_DELAY;
    LOOPBACK1_indelay <= LOOPBACK1_in after IN_DELAY;
    PLLLKDETEN0_indelay <= PLLLKDETEN0_in after IN_DELAY;
    PLLLKDETEN1_indelay <= PLLLKDETEN1_in after IN_DELAY;
    PLLPOWERDOWN0_indelay <= PLLPOWERDOWN0_in after IN_DELAY;
    PLLPOWERDOWN1_indelay <= PLLPOWERDOWN1_in after IN_DELAY;
    PRBSCNTRESET0_indelay <= PRBSCNTRESET0_in after IN_DELAY;
    PRBSCNTRESET1_indelay <= PRBSCNTRESET1_in after IN_DELAY;
    RCALINEAST_indelay <= RCALINEAST_in after IN_DELAY;
    RCALINWEST_indelay <= RCALINWEST_in after IN_DELAY;
    REFCLKPWRDNB0_indelay <= REFCLKPWRDNB0_in after IN_DELAY;
    REFCLKPWRDNB1_indelay <= REFCLKPWRDNB1_in after IN_DELAY;
    REFSELDYPLL0_indelay <= REFSELDYPLL0_in after IN_DELAY;
    REFSELDYPLL1_indelay <= REFSELDYPLL1_in after IN_DELAY;
    RXBUFRESET0_indelay <= RXBUFRESET0_in after IN_DELAY;
    RXBUFRESET1_indelay <= RXBUFRESET1_in after IN_DELAY;
    RXCDRRESET0_indelay <= RXCDRRESET0_in after IN_DELAY;
    RXCDRRESET1_indelay <= RXCDRRESET1_in after IN_DELAY;
    RXCHBONDI_indelay <= RXCHBONDI_in after IN_DELAY;
    RXCHBONDMASTER0_indelay <= RXCHBONDMASTER0_in after IN_DELAY;
    RXCHBONDMASTER1_indelay <= RXCHBONDMASTER1_in after IN_DELAY;
    RXCHBONDSLAVE0_indelay <= RXCHBONDSLAVE0_in after IN_DELAY;
    RXCHBONDSLAVE1_indelay <= RXCHBONDSLAVE1_in after IN_DELAY;
    RXCOMMADETUSE0_indelay <= RXCOMMADETUSE0_in after IN_DELAY;
    RXCOMMADETUSE1_indelay <= RXCOMMADETUSE1_in after IN_DELAY;
    RXDATAWIDTH0_indelay <= RXDATAWIDTH0_in after IN_DELAY;
    RXDATAWIDTH1_indelay <= RXDATAWIDTH1_in after IN_DELAY;
    RXDEC8B10BUSE0_indelay <= RXDEC8B10BUSE0_in after IN_DELAY;
    RXDEC8B10BUSE1_indelay <= RXDEC8B10BUSE1_in after IN_DELAY;
    RXENCHANSYNC0_indelay <= RXENCHANSYNC0_in after IN_DELAY;
    RXENCHANSYNC1_indelay <= RXENCHANSYNC1_in after IN_DELAY;
    RXENMCOMMAALIGN0_indelay <= RXENMCOMMAALIGN0_in after IN_DELAY;
    RXENMCOMMAALIGN1_indelay <= RXENMCOMMAALIGN1_in after IN_DELAY;
    RXENPCOMMAALIGN0_indelay <= RXENPCOMMAALIGN0_in after IN_DELAY;
    RXENPCOMMAALIGN1_indelay <= RXENPCOMMAALIGN1_in after IN_DELAY;
    RXENPMAPHASEALIGN0_indelay <= RXENPMAPHASEALIGN0_in after IN_DELAY;
    RXENPMAPHASEALIGN1_indelay <= RXENPMAPHASEALIGN1_in after IN_DELAY;
    RXENPRBSTST0_indelay <= RXENPRBSTST0_in after IN_DELAY;
    RXENPRBSTST1_indelay <= RXENPRBSTST1_in after IN_DELAY;
    RXEQMIX0_indelay <= RXEQMIX0_in after IN_DELAY;
    RXEQMIX1_indelay <= RXEQMIX1_in after IN_DELAY;
    RXN0_indelay <= RXN0_in after IN_DELAY;
    RXN1_indelay <= RXN1_in after IN_DELAY;
    RXP0_indelay <= RXP0_in after IN_DELAY;
    RXP1_indelay <= RXP1_in after IN_DELAY;
    RXPMASETPHASE0_indelay <= RXPMASETPHASE0_in after IN_DELAY;
    RXPMASETPHASE1_indelay <= RXPMASETPHASE1_in after IN_DELAY;
    RXPOLARITY0_indelay <= RXPOLARITY0_in after IN_DELAY;
    RXPOLARITY1_indelay <= RXPOLARITY1_in after IN_DELAY;
    RXPOWERDOWN0_indelay <= RXPOWERDOWN0_in after IN_DELAY;
    RXPOWERDOWN1_indelay <= RXPOWERDOWN1_in after IN_DELAY;
    RXRESET0_indelay <= RXRESET0_in after IN_DELAY;
    RXRESET1_indelay <= RXRESET1_in after IN_DELAY;
    RXSLIDE0_indelay <= RXSLIDE0_in after IN_DELAY;
    RXSLIDE1_indelay <= RXSLIDE1_in after IN_DELAY;
    TSTIN0_indelay <= TSTIN0_in after IN_DELAY;
    TSTIN1_indelay <= TSTIN1_in after IN_DELAY;
    TXBUFDIFFCTRL0_indelay <= TXBUFDIFFCTRL0_in after IN_DELAY;
    TXBUFDIFFCTRL1_indelay <= TXBUFDIFFCTRL1_in after IN_DELAY;
    TXBYPASS8B10B0_indelay <= TXBYPASS8B10B0_in after IN_DELAY;
    TXBYPASS8B10B1_indelay <= TXBYPASS8B10B1_in after IN_DELAY;
    TXCHARDISPMODE0_indelay <= TXCHARDISPMODE0_in after IN_DELAY;
    TXCHARDISPMODE1_indelay <= TXCHARDISPMODE1_in after IN_DELAY;
    TXCHARDISPVAL0_indelay <= TXCHARDISPVAL0_in after IN_DELAY;
    TXCHARDISPVAL1_indelay <= TXCHARDISPVAL1_in after IN_DELAY;
    TXCHARISK0_indelay <= TXCHARISK0_in after IN_DELAY;
    TXCHARISK1_indelay <= TXCHARISK1_in after IN_DELAY;
    TXCOMSTART0_indelay <= TXCOMSTART0_in after IN_DELAY;
    TXCOMSTART1_indelay <= TXCOMSTART1_in after IN_DELAY;
    TXCOMTYPE0_indelay <= TXCOMTYPE0_in after IN_DELAY;
    TXCOMTYPE1_indelay <= TXCOMTYPE1_in after IN_DELAY;
    TXDATA0_indelay <= TXDATA0_in after IN_DELAY;
    TXDATA1_indelay <= TXDATA1_in after IN_DELAY;
    TXDATAWIDTH0_indelay <= TXDATAWIDTH0_in after IN_DELAY;
    TXDATAWIDTH1_indelay <= TXDATAWIDTH1_in after IN_DELAY;
    TXDETECTRX0_indelay <= TXDETECTRX0_in after IN_DELAY;
    TXDETECTRX1_indelay <= TXDETECTRX1_in after IN_DELAY;
    TXDIFFCTRL0_indelay <= TXDIFFCTRL0_in after IN_DELAY;
    TXDIFFCTRL1_indelay <= TXDIFFCTRL1_in after IN_DELAY;
    TXELECIDLE0_indelay <= TXELECIDLE0_in after IN_DELAY;
    TXELECIDLE1_indelay <= TXELECIDLE1_in after IN_DELAY;
    TXENC8B10BUSE0_indelay <= TXENC8B10BUSE0_in after IN_DELAY;
    TXENC8B10BUSE1_indelay <= TXENC8B10BUSE1_in after IN_DELAY;
    TXENPMAPHASEALIGN0_indelay <= TXENPMAPHASEALIGN0_in after IN_DELAY;
    TXENPMAPHASEALIGN1_indelay <= TXENPMAPHASEALIGN1_in after IN_DELAY;
    TXENPRBSTST0_indelay <= TXENPRBSTST0_in after IN_DELAY;
    TXENPRBSTST1_indelay <= TXENPRBSTST1_in after IN_DELAY;
    TXINHIBIT0_indelay <= TXINHIBIT0_in after IN_DELAY;
    TXINHIBIT1_indelay <= TXINHIBIT1_in after IN_DELAY;
    TXPDOWNASYNCH0_indelay <= TXPDOWNASYNCH0_in after IN_DELAY;
    TXPDOWNASYNCH1_indelay <= TXPDOWNASYNCH1_in after IN_DELAY;
    TXPMASETPHASE0_indelay <= TXPMASETPHASE0_in after IN_DELAY;
    TXPMASETPHASE1_indelay <= TXPMASETPHASE1_in after IN_DELAY;
    TXPOLARITY0_indelay <= TXPOLARITY0_in after IN_DELAY;
    TXPOLARITY1_indelay <= TXPOLARITY1_in after IN_DELAY;
    TXPOWERDOWN0_indelay <= TXPOWERDOWN0_in after IN_DELAY;
    TXPOWERDOWN1_indelay <= TXPOWERDOWN1_in after IN_DELAY;
    TXPRBSFORCEERR0_indelay <= TXPRBSFORCEERR0_in after IN_DELAY;
    TXPRBSFORCEERR1_indelay <= TXPRBSFORCEERR1_in after IN_DELAY;
    TXPREEMPHASIS0_indelay <= TXPREEMPHASIS0_in after IN_DELAY;
    TXPREEMPHASIS1_indelay <= TXPREEMPHASIS1_in after IN_DELAY;
    TXRESET0_indelay <= TXRESET0_in after IN_DELAY;
    TXRESET1_indelay <= TXRESET1_in after IN_DELAY;
    USRCODEERR0_indelay <= USRCODEERR0_in after IN_DELAY;
    USRCODEERR1_indelay <= USRCODEERR1_in after IN_DELAY;
    
    GSR_dly <= GSR;
  
    GTPA1_DUAL_WRAP_INST : GTPA1_DUAL_WRAP
      generic map (
        AC_CAP_DIS_0         => AC_CAP_DIS_0_STRING,
        AC_CAP_DIS_1         => AC_CAP_DIS_1_STRING,
        ALIGN_COMMA_WORD_0   => ALIGN_COMMA_WORD_0,
        ALIGN_COMMA_WORD_1   => ALIGN_COMMA_WORD_1,
        CB2_INH_CC_PERIOD_0  => CB2_INH_CC_PERIOD_0,
        CB2_INH_CC_PERIOD_1  => CB2_INH_CC_PERIOD_1,
        CDR_PH_ADJ_TIME_0    => CDR_PH_ADJ_TIME_0_STRING,
        CDR_PH_ADJ_TIME_1    => CDR_PH_ADJ_TIME_1_STRING,
        CHAN_BOND_1_MAX_SKEW_0 => CHAN_BOND_1_MAX_SKEW_0,
        CHAN_BOND_1_MAX_SKEW_1 => CHAN_BOND_1_MAX_SKEW_1,
        CHAN_BOND_2_MAX_SKEW_0 => CHAN_BOND_2_MAX_SKEW_0,
        CHAN_BOND_2_MAX_SKEW_1 => CHAN_BOND_2_MAX_SKEW_1,
        CHAN_BOND_KEEP_ALIGN_0 => CHAN_BOND_KEEP_ALIGN_0_STRING,
        CHAN_BOND_KEEP_ALIGN_1 => CHAN_BOND_KEEP_ALIGN_1_STRING,
        CHAN_BOND_SEQ_1_1_0  => CHAN_BOND_SEQ_1_1_0_STRING,
        CHAN_BOND_SEQ_1_1_1  => CHAN_BOND_SEQ_1_1_1_STRING,
        CHAN_BOND_SEQ_1_2_0  => CHAN_BOND_SEQ_1_2_0_STRING,
        CHAN_BOND_SEQ_1_2_1  => CHAN_BOND_SEQ_1_2_1_STRING,
        CHAN_BOND_SEQ_1_3_0  => CHAN_BOND_SEQ_1_3_0_STRING,
        CHAN_BOND_SEQ_1_3_1  => CHAN_BOND_SEQ_1_3_1_STRING,
        CHAN_BOND_SEQ_1_4_0  => CHAN_BOND_SEQ_1_4_0_STRING,
        CHAN_BOND_SEQ_1_4_1  => CHAN_BOND_SEQ_1_4_1_STRING,
        CHAN_BOND_SEQ_1_ENABLE_0 => CHAN_BOND_SEQ_1_ENABLE_0_STRING,
        CHAN_BOND_SEQ_1_ENABLE_1 => CHAN_BOND_SEQ_1_ENABLE_1_STRING,
        CHAN_BOND_SEQ_2_1_0  => CHAN_BOND_SEQ_2_1_0_STRING,
        CHAN_BOND_SEQ_2_1_1  => CHAN_BOND_SEQ_2_1_1_STRING,
        CHAN_BOND_SEQ_2_2_0  => CHAN_BOND_SEQ_2_2_0_STRING,
        CHAN_BOND_SEQ_2_2_1  => CHAN_BOND_SEQ_2_2_1_STRING,
        CHAN_BOND_SEQ_2_3_0  => CHAN_BOND_SEQ_2_3_0_STRING,
        CHAN_BOND_SEQ_2_3_1  => CHAN_BOND_SEQ_2_3_1_STRING,
        CHAN_BOND_SEQ_2_4_0  => CHAN_BOND_SEQ_2_4_0_STRING,
        CHAN_BOND_SEQ_2_4_1  => CHAN_BOND_SEQ_2_4_1_STRING,
        CHAN_BOND_SEQ_2_ENABLE_0 => CHAN_BOND_SEQ_2_ENABLE_0_STRING,
        CHAN_BOND_SEQ_2_ENABLE_1 => CHAN_BOND_SEQ_2_ENABLE_1_STRING,
        CHAN_BOND_SEQ_2_USE_0 => CHAN_BOND_SEQ_2_USE_0_STRING,
        CHAN_BOND_SEQ_2_USE_1 => CHAN_BOND_SEQ_2_USE_1_STRING,
        CHAN_BOND_SEQ_LEN_0  => CHAN_BOND_SEQ_LEN_0,
        CHAN_BOND_SEQ_LEN_1  => CHAN_BOND_SEQ_LEN_1,
        CLK25_DIVIDER_0      => CLK25_DIVIDER_0,
        CLK25_DIVIDER_1      => CLK25_DIVIDER_1,
        CLKINDC_B_0          => CLKINDC_B_0_STRING,
        CLKINDC_B_1          => CLKINDC_B_1_STRING,
        CLKRCV_TRST_0        => CLKRCV_TRST_0_STRING,
        CLKRCV_TRST_1        => CLKRCV_TRST_1_STRING,
        CLK_CORRECT_USE_0    => CLK_CORRECT_USE_0_STRING,
        CLK_CORRECT_USE_1    => CLK_CORRECT_USE_1_STRING,
        CLK_COR_ADJ_LEN_0    => CLK_COR_ADJ_LEN_0,
        CLK_COR_ADJ_LEN_1    => CLK_COR_ADJ_LEN_1,
        CLK_COR_DET_LEN_0    => CLK_COR_DET_LEN_0,
        CLK_COR_DET_LEN_1    => CLK_COR_DET_LEN_1,
        CLK_COR_INSERT_IDLE_FLAG_0 => CLK_COR_INSERT_IDLE_FLAG_0_STRING,
        CLK_COR_INSERT_IDLE_FLAG_1 => CLK_COR_INSERT_IDLE_FLAG_1_STRING,
        CLK_COR_KEEP_IDLE_0  => CLK_COR_KEEP_IDLE_0_STRING,
        CLK_COR_KEEP_IDLE_1  => CLK_COR_KEEP_IDLE_1_STRING,
        CLK_COR_MAX_LAT_0    => CLK_COR_MAX_LAT_0,
        CLK_COR_MAX_LAT_1    => CLK_COR_MAX_LAT_1,
        CLK_COR_MIN_LAT_0    => CLK_COR_MIN_LAT_0,
        CLK_COR_MIN_LAT_1    => CLK_COR_MIN_LAT_1,
        CLK_COR_PRECEDENCE_0 => CLK_COR_PRECEDENCE_0_STRING,
        CLK_COR_PRECEDENCE_1 => CLK_COR_PRECEDENCE_1_STRING,
        CLK_COR_REPEAT_WAIT_0 => CLK_COR_REPEAT_WAIT_0,
        CLK_COR_REPEAT_WAIT_1 => CLK_COR_REPEAT_WAIT_1,
        CLK_COR_SEQ_1_1_0    => CLK_COR_SEQ_1_1_0_STRING,
        CLK_COR_SEQ_1_1_1    => CLK_COR_SEQ_1_1_1_STRING,
        CLK_COR_SEQ_1_2_0    => CLK_COR_SEQ_1_2_0_STRING,
        CLK_COR_SEQ_1_2_1    => CLK_COR_SEQ_1_2_1_STRING,
        CLK_COR_SEQ_1_3_0    => CLK_COR_SEQ_1_3_0_STRING,
        CLK_COR_SEQ_1_3_1    => CLK_COR_SEQ_1_3_1_STRING,
        CLK_COR_SEQ_1_4_0    => CLK_COR_SEQ_1_4_0_STRING,
        CLK_COR_SEQ_1_4_1    => CLK_COR_SEQ_1_4_1_STRING,
        CLK_COR_SEQ_1_ENABLE_0 => CLK_COR_SEQ_1_ENABLE_0_STRING,
        CLK_COR_SEQ_1_ENABLE_1 => CLK_COR_SEQ_1_ENABLE_1_STRING,
        CLK_COR_SEQ_2_1_0    => CLK_COR_SEQ_2_1_0_STRING,
        CLK_COR_SEQ_2_1_1    => CLK_COR_SEQ_2_1_1_STRING,
        CLK_COR_SEQ_2_2_0    => CLK_COR_SEQ_2_2_0_STRING,
        CLK_COR_SEQ_2_2_1    => CLK_COR_SEQ_2_2_1_STRING,
        CLK_COR_SEQ_2_3_0    => CLK_COR_SEQ_2_3_0_STRING,
        CLK_COR_SEQ_2_3_1    => CLK_COR_SEQ_2_3_1_STRING,
        CLK_COR_SEQ_2_4_0    => CLK_COR_SEQ_2_4_0_STRING,
        CLK_COR_SEQ_2_4_1    => CLK_COR_SEQ_2_4_1_STRING,
        CLK_COR_SEQ_2_ENABLE_0 => CLK_COR_SEQ_2_ENABLE_0_STRING,
        CLK_COR_SEQ_2_ENABLE_1 => CLK_COR_SEQ_2_ENABLE_1_STRING,
        CLK_COR_SEQ_2_USE_0  => CLK_COR_SEQ_2_USE_0_STRING,
        CLK_COR_SEQ_2_USE_1  => CLK_COR_SEQ_2_USE_1_STRING,
        CLK_OUT_GTP_SEL_0    => CLK_OUT_GTP_SEL_0,
        CLK_OUT_GTP_SEL_1    => CLK_OUT_GTP_SEL_1,
        CM_TRIM_0            => CM_TRIM_0_STRING,
        CM_TRIM_1            => CM_TRIM_1_STRING,
        COMMA_10B_ENABLE_0   => COMMA_10B_ENABLE_0_STRING,
        COMMA_10B_ENABLE_1   => COMMA_10B_ENABLE_1_STRING,
        COM_BURST_VAL_0      => COM_BURST_VAL_0_STRING,
        COM_BURST_VAL_1      => COM_BURST_VAL_1_STRING,
        DEC_MCOMMA_DETECT_0  => DEC_MCOMMA_DETECT_0_STRING,
        DEC_MCOMMA_DETECT_1  => DEC_MCOMMA_DETECT_1_STRING,
        DEC_PCOMMA_DETECT_0  => DEC_PCOMMA_DETECT_0_STRING,
        DEC_PCOMMA_DETECT_1  => DEC_PCOMMA_DETECT_1_STRING,
        DEC_VALID_COMMA_ONLY_0 => DEC_VALID_COMMA_ONLY_0_STRING,
        DEC_VALID_COMMA_ONLY_1 => DEC_VALID_COMMA_ONLY_1_STRING,
        GTP_CFG_PWRUP_0      => GTP_CFG_PWRUP_0_STRING,
        GTP_CFG_PWRUP_1      => GTP_CFG_PWRUP_1_STRING,
        MCOMMA_10B_VALUE_0   => MCOMMA_10B_VALUE_0_STRING,
        MCOMMA_10B_VALUE_1   => MCOMMA_10B_VALUE_1_STRING,
        MCOMMA_DETECT_0      => MCOMMA_DETECT_0_STRING,
        MCOMMA_DETECT_1      => MCOMMA_DETECT_1_STRING,
        OOBDETECT_THRESHOLD_0 => OOBDETECT_THRESHOLD_0_STRING,
        OOBDETECT_THRESHOLD_1 => OOBDETECT_THRESHOLD_1_STRING,
        OOB_CLK_DIVIDER_0    => OOB_CLK_DIVIDER_0,
        OOB_CLK_DIVIDER_1    => OOB_CLK_DIVIDER_1,
        PCI_EXPRESS_MODE_0   => PCI_EXPRESS_MODE_0_STRING,
        PCI_EXPRESS_MODE_1   => PCI_EXPRESS_MODE_1_STRING,
        PCOMMA_10B_VALUE_0   => PCOMMA_10B_VALUE_0_STRING,
        PCOMMA_10B_VALUE_1   => PCOMMA_10B_VALUE_1_STRING,
        PCOMMA_DETECT_0      => PCOMMA_DETECT_0_STRING,
        PCOMMA_DETECT_1      => PCOMMA_DETECT_1_STRING,
        PLLLKDET_CFG_0       => PLLLKDET_CFG_0_STRING,
        PLLLKDET_CFG_1       => PLLLKDET_CFG_1_STRING,
        PLL_COM_CFG_0        => PLL_COM_CFG_0_STRING,
        PLL_COM_CFG_1        => PLL_COM_CFG_1_STRING,
        PLL_CP_CFG_0         => PLL_CP_CFG_0_STRING,
        PLL_CP_CFG_1         => PLL_CP_CFG_1_STRING,
        PLL_DIVSEL_FB_0      => PLL_DIVSEL_FB_0,
        PLL_DIVSEL_FB_1      => PLL_DIVSEL_FB_1,
        PLL_DIVSEL_REF_0     => PLL_DIVSEL_REF_0,
        PLL_DIVSEL_REF_1     => PLL_DIVSEL_REF_1,
        PLL_RXDIVSEL_OUT_0   => PLL_RXDIVSEL_OUT_0,
        PLL_RXDIVSEL_OUT_1   => PLL_RXDIVSEL_OUT_1,
        PLL_SATA_0           => PLL_SATA_0_STRING,
        PLL_SATA_1           => PLL_SATA_1_STRING,
        PLL_SOURCE_0         => PLL_SOURCE_0,
        PLL_SOURCE_1         => PLL_SOURCE_1,
        PLL_TXDIVSEL_OUT_0   => PLL_TXDIVSEL_OUT_0,
        PLL_TXDIVSEL_OUT_1   => PLL_TXDIVSEL_OUT_1,
        PMA_CDR_SCAN_0       => PMA_CDR_SCAN_0_STRING,
        PMA_CDR_SCAN_1       => PMA_CDR_SCAN_1_STRING,
        PMA_COM_CFG_EAST     => PMA_COM_CFG_EAST_STRING,
        PMA_COM_CFG_WEST     => PMA_COM_CFG_WEST_STRING,
        PMA_RXSYNC_CFG_0     => PMA_RXSYNC_CFG_0_STRING,
        PMA_RXSYNC_CFG_1     => PMA_RXSYNC_CFG_1_STRING,
        PMA_RX_CFG_0         => PMA_RX_CFG_0_STRING,
        PMA_RX_CFG_1         => PMA_RX_CFG_1_STRING,
        PMA_TX_CFG_0         => PMA_TX_CFG_0_STRING,
        PMA_TX_CFG_1         => PMA_TX_CFG_1_STRING,
        RCV_TERM_GND_0       => RCV_TERM_GND_0_STRING,
        RCV_TERM_GND_1       => RCV_TERM_GND_1_STRING,
        RCV_TERM_VTTRX_0     => RCV_TERM_VTTRX_0_STRING,
        RCV_TERM_VTTRX_1     => RCV_TERM_VTTRX_1_STRING,
        RXEQ_CFG_0           => RXEQ_CFG_0_STRING,
        RXEQ_CFG_1           => RXEQ_CFG_1_STRING,
        RXPRBSERR_LOOPBACK_0 => RXPRBSERR_LOOPBACK_0_STRING,
        RXPRBSERR_LOOPBACK_1 => RXPRBSERR_LOOPBACK_1_STRING,
        RX_BUFFER_USE_0      => RX_BUFFER_USE_0_STRING,
        RX_BUFFER_USE_1      => RX_BUFFER_USE_1_STRING,
        RX_DECODE_SEQ_MATCH_0 => RX_DECODE_SEQ_MATCH_0_STRING,
        RX_DECODE_SEQ_MATCH_1 => RX_DECODE_SEQ_MATCH_1_STRING,
        RX_EN_IDLE_HOLD_CDR_0 => RX_EN_IDLE_HOLD_CDR_0_STRING,
        RX_EN_IDLE_HOLD_CDR_1 => RX_EN_IDLE_HOLD_CDR_1_STRING,
        RX_EN_IDLE_RESET_BUF_0 => RX_EN_IDLE_RESET_BUF_0_STRING,
        RX_EN_IDLE_RESET_BUF_1 => RX_EN_IDLE_RESET_BUF_1_STRING,
        RX_EN_IDLE_RESET_FR_0 => RX_EN_IDLE_RESET_FR_0_STRING,
        RX_EN_IDLE_RESET_FR_1 => RX_EN_IDLE_RESET_FR_1_STRING,
        RX_EN_IDLE_RESET_PH_0 => RX_EN_IDLE_RESET_PH_0_STRING,
        RX_EN_IDLE_RESET_PH_1 => RX_EN_IDLE_RESET_PH_1_STRING,
        RX_EN_MODE_RESET_BUF_0 => RX_EN_MODE_RESET_BUF_0_STRING,
        RX_EN_MODE_RESET_BUF_1 => RX_EN_MODE_RESET_BUF_1_STRING,
        RX_IDLE_HI_CNT_0     => RX_IDLE_HI_CNT_0_STRING,
        RX_IDLE_HI_CNT_1     => RX_IDLE_HI_CNT_1_STRING,
        RX_IDLE_LO_CNT_0     => RX_IDLE_LO_CNT_0_STRING,
        RX_IDLE_LO_CNT_1     => RX_IDLE_LO_CNT_1_STRING,
        RX_LOSS_OF_SYNC_FSM_0 => RX_LOSS_OF_SYNC_FSM_0_STRING,
        RX_LOSS_OF_SYNC_FSM_1 => RX_LOSS_OF_SYNC_FSM_1_STRING,
        RX_LOS_INVALID_INCR_0 => RX_LOS_INVALID_INCR_0,
        RX_LOS_INVALID_INCR_1 => RX_LOS_INVALID_INCR_1,
        RX_LOS_THRESHOLD_0   => RX_LOS_THRESHOLD_0,
        RX_LOS_THRESHOLD_1   => RX_LOS_THRESHOLD_1,
        RX_SLIDE_MODE_0      => RX_SLIDE_MODE_0,
        RX_SLIDE_MODE_1      => RX_SLIDE_MODE_1,
        RX_STATUS_FMT_0      => RX_STATUS_FMT_0,
        RX_STATUS_FMT_1      => RX_STATUS_FMT_1,
        RX_XCLK_SEL_0        => RX_XCLK_SEL_0,
        RX_XCLK_SEL_1        => RX_XCLK_SEL_1,
        SATA_BURST_VAL_0     => SATA_BURST_VAL_0_STRING,
        SATA_BURST_VAL_1     => SATA_BURST_VAL_1_STRING,
        SATA_IDLE_VAL_0      => SATA_IDLE_VAL_0_STRING,
        SATA_IDLE_VAL_1      => SATA_IDLE_VAL_1_STRING,
        SATA_MAX_BURST_0     => SATA_MAX_BURST_0,
        SATA_MAX_BURST_1     => SATA_MAX_BURST_1,
        SATA_MAX_INIT_0      => SATA_MAX_INIT_0,
        SATA_MAX_INIT_1      => SATA_MAX_INIT_1,
        SATA_MAX_WAKE_0      => SATA_MAX_WAKE_0,
        SATA_MAX_WAKE_1      => SATA_MAX_WAKE_1,
        SATA_MIN_BURST_0     => SATA_MIN_BURST_0,
        SATA_MIN_BURST_1     => SATA_MIN_BURST_1,
        SATA_MIN_INIT_0      => SATA_MIN_INIT_0,
        SATA_MIN_INIT_1      => SATA_MIN_INIT_1,
        SATA_MIN_WAKE_0      => SATA_MIN_WAKE_0,
        SATA_MIN_WAKE_1      => SATA_MIN_WAKE_1,
        SIM_GTPRESET_SPEEDUP => SIM_GTPRESET_SPEEDUP,
        SIM_RECEIVER_DETECT_PASS => SIM_RECEIVER_DETECT_PASS_STRING,
        SIM_REFCLK0_SOURCE   => SIM_REFCLK0_SOURCE_STRING,
        SIM_REFCLK1_SOURCE   => SIM_REFCLK1_SOURCE_STRING,
        SIM_TX_ELEC_IDLE_LEVEL => SIM_TX_ELEC_IDLE_LEVEL,
        SIM_VERSION          => SIM_VERSION,
        TERMINATION_CTRL_0   => TERMINATION_CTRL_0_STRING,
        TERMINATION_CTRL_1   => TERMINATION_CTRL_1_STRING,
        TERMINATION_OVRD_0   => TERMINATION_OVRD_0_STRING,
        TERMINATION_OVRD_1   => TERMINATION_OVRD_1_STRING,
        TRANS_TIME_FROM_P2_0 => TRANS_TIME_FROM_P2_0_STRING,
        TRANS_TIME_FROM_P2_1 => TRANS_TIME_FROM_P2_1_STRING,
        TRANS_TIME_NON_P2_0  => TRANS_TIME_NON_P2_0_STRING,
        TRANS_TIME_NON_P2_1  => TRANS_TIME_NON_P2_1_STRING,
        TRANS_TIME_TO_P2_0   => TRANS_TIME_TO_P2_0_STRING,
        TRANS_TIME_TO_P2_1   => TRANS_TIME_TO_P2_1_STRING,
        TST_ATTR_0           => TST_ATTR_0_STRING,
        TST_ATTR_1           => TST_ATTR_1_STRING,
        TXRX_INVERT_0        => TXRX_INVERT_0_STRING,
        TXRX_INVERT_1        => TXRX_INVERT_1_STRING,
        TX_BUFFER_USE_0      => TX_BUFFER_USE_0_STRING,
        TX_BUFFER_USE_1      => TX_BUFFER_USE_1_STRING,
        TX_DETECT_RX_CFG_0   => TX_DETECT_RX_CFG_0_STRING,
        TX_DETECT_RX_CFG_1   => TX_DETECT_RX_CFG_1_STRING,
        TX_IDLE_DELAY_0      => TX_IDLE_DELAY_0_STRING,
        TX_IDLE_DELAY_1      => TX_IDLE_DELAY_1_STRING,
        TX_TDCC_CFG_0        => TX_TDCC_CFG_0_STRING,
        TX_TDCC_CFG_1        => TX_TDCC_CFG_1_STRING,
        TX_XCLK_SEL_0        => TX_XCLK_SEL_0,
        TX_XCLK_SEL_1        => TX_XCLK_SEL_1
      )
      
      port map (
        DRDY                 => DRDY_outdelay,
        DRPDO                => DRPDO_outdelay,
        GTPCLKFBEAST         => GTPCLKFBEAST_outdelay,
        GTPCLKFBWEST         => GTPCLKFBWEST_outdelay,
        GTPCLKOUT0           => GTPCLKOUT0_outdelay,
        GTPCLKOUT1           => GTPCLKOUT1_outdelay,
        PHYSTATUS0           => PHYSTATUS0_outdelay,
        PHYSTATUS1           => PHYSTATUS1_outdelay,
        PLLLKDET0            => PLLLKDET0_outdelay,
        PLLLKDET1            => PLLLKDET1_outdelay,
        RCALOUTEAST          => RCALOUTEAST_outdelay,
        RCALOUTWEST          => RCALOUTWEST_outdelay,
        REFCLKOUT0           => REFCLKOUT0_outdelay,
        REFCLKOUT1           => REFCLKOUT1_outdelay,
        REFCLKPLL0           => REFCLKPLL0_outdelay,
        REFCLKPLL1           => REFCLKPLL1_outdelay,
        RESETDONE0           => RESETDONE0_outdelay,
        RESETDONE1           => RESETDONE1_outdelay,
        RXBUFSTATUS0         => RXBUFSTATUS0_outdelay,
        RXBUFSTATUS1         => RXBUFSTATUS1_outdelay,
        RXBYTEISALIGNED0     => RXBYTEISALIGNED0_outdelay,
        RXBYTEISALIGNED1     => RXBYTEISALIGNED1_outdelay,
        RXBYTEREALIGN0       => RXBYTEREALIGN0_outdelay,
        RXBYTEREALIGN1       => RXBYTEREALIGN1_outdelay,
        RXCHANBONDSEQ0       => RXCHANBONDSEQ0_outdelay,
        RXCHANBONDSEQ1       => RXCHANBONDSEQ1_outdelay,
        RXCHANISALIGNED0     => RXCHANISALIGNED0_outdelay,
        RXCHANISALIGNED1     => RXCHANISALIGNED1_outdelay,
        RXCHANREALIGN0       => RXCHANREALIGN0_outdelay,
        RXCHANREALIGN1       => RXCHANREALIGN1_outdelay,
        RXCHARISCOMMA0       => RXCHARISCOMMA0_outdelay,
        RXCHARISCOMMA1       => RXCHARISCOMMA1_outdelay,
        RXCHARISK0           => RXCHARISK0_outdelay,
        RXCHARISK1           => RXCHARISK1_outdelay,
        RXCHBONDO            => RXCHBONDO_outdelay,
        RXCLKCORCNT0         => RXCLKCORCNT0_outdelay,
        RXCLKCORCNT1         => RXCLKCORCNT1_outdelay,
        RXCOMMADET0          => RXCOMMADET0_outdelay,
        RXCOMMADET1          => RXCOMMADET1_outdelay,
        RXDATA0              => RXDATA0_outdelay,
        RXDATA1              => RXDATA1_outdelay,
        RXDISPERR0           => RXDISPERR0_outdelay,
        RXDISPERR1           => RXDISPERR1_outdelay,
        RXELECIDLE0          => RXELECIDLE0_outdelay,
        RXELECIDLE1          => RXELECIDLE1_outdelay,
        RXLOSSOFSYNC0        => RXLOSSOFSYNC0_outdelay,
        RXLOSSOFSYNC1        => RXLOSSOFSYNC1_outdelay,
        RXNOTINTABLE0        => RXNOTINTABLE0_outdelay,
        RXNOTINTABLE1        => RXNOTINTABLE1_outdelay,
        RXPRBSERR0           => RXPRBSERR0_outdelay,
        RXPRBSERR1           => RXPRBSERR1_outdelay,
        RXRECCLK0            => RXRECCLK0_outdelay,
        RXRECCLK1            => RXRECCLK1_outdelay,
        RXRUNDISP0           => RXRUNDISP0_outdelay,
        RXRUNDISP1           => RXRUNDISP1_outdelay,
        RXSTATUS0            => RXSTATUS0_outdelay,
        RXSTATUS1            => RXSTATUS1_outdelay,
        RXVALID0             => RXVALID0_outdelay,
        RXVALID1             => RXVALID1_outdelay,
        TSTOUT0              => TSTOUT0_outdelay,
        TSTOUT1              => TSTOUT1_outdelay,
        TXBUFSTATUS0         => TXBUFSTATUS0_outdelay,
        TXBUFSTATUS1         => TXBUFSTATUS1_outdelay,
        TXKERR0              => TXKERR0_outdelay,
        TXKERR1              => TXKERR1_outdelay,
        TXN0                 => TXN0_outdelay,
        TXN1                 => TXN1_outdelay,
        TXOUTCLK0            => TXOUTCLK0_outdelay,
        TXOUTCLK1            => TXOUTCLK1_outdelay,
        TXP0                 => TXP0_outdelay,
        TXP1                 => TXP1_outdelay,
        TXRUNDISP0           => TXRUNDISP0_outdelay,
        TXRUNDISP1           => TXRUNDISP1_outdelay,
        CLK00                => CLK00_indelay,
        CLK01                => CLK01_indelay,
        CLK10                => CLK10_indelay,
        CLK11                => CLK11_indelay,
        CLKINEAST0           => CLKINEAST0_indelay,
        CLKINEAST1           => CLKINEAST1_indelay,
        CLKINWEST0           => CLKINWEST0_indelay,
        CLKINWEST1           => CLKINWEST1_indelay,
        DADDR                => DADDR_indelay,
        DCLK                 => DCLK_indelay,
        DEN                  => DEN_indelay,
        DI                   => DI_indelay,
        DWE                  => DWE_indelay,
        GATERXELECIDLE0      => GATERXELECIDLE0_indelay,
        GATERXELECIDLE1      => GATERXELECIDLE1_indelay,
        GCLK00               => GCLK00_indelay,
        GCLK01               => GCLK01_indelay,
        GCLK10               => GCLK10_indelay,
        GCLK11               => GCLK11_indelay,
        GTPCLKFBSEL0EAST     => GTPCLKFBSEL0EAST_indelay,
        GTPCLKFBSEL0WEST     => GTPCLKFBSEL0WEST_indelay,
        GTPCLKFBSEL1EAST     => GTPCLKFBSEL1EAST_indelay,
        GTPCLKFBSEL1WEST     => GTPCLKFBSEL1WEST_indelay,
        GTPRESET0            => GTPRESET0_indelay,
        GTPRESET1            => GTPRESET1_indelay,
        GTPTEST0             => GTPTEST0_indelay,
        GTPTEST1             => GTPTEST1_indelay,
        IGNORESIGDET0        => IGNORESIGDET0_indelay,
        IGNORESIGDET1        => IGNORESIGDET1_indelay,
        INTDATAWIDTH0        => INTDATAWIDTH0_indelay,
        INTDATAWIDTH1        => INTDATAWIDTH1_indelay,
        LOOPBACK0            => LOOPBACK0_indelay,
        LOOPBACK1            => LOOPBACK1_indelay,
        PLLCLK00             => PLLCLK00_indelay,
        PLLCLK01             => PLLCLK01_indelay,
        PLLCLK10             => PLLCLK10_indelay,
        PLLCLK11             => PLLCLK11_indelay,
        PLLLKDETEN0          => PLLLKDETEN0_indelay,
        PLLLKDETEN1          => PLLLKDETEN1_indelay,
        PLLPOWERDOWN0        => PLLPOWERDOWN0_indelay,
        PLLPOWERDOWN1        => PLLPOWERDOWN1_indelay,
        PRBSCNTRESET0        => PRBSCNTRESET0_indelay,
        PRBSCNTRESET1        => PRBSCNTRESET1_indelay,
        RCALINEAST           => RCALINEAST_indelay,
        RCALINWEST           => RCALINWEST_indelay,
        REFCLKPWRDNB0        => REFCLKPWRDNB0_indelay,
        REFCLKPWRDNB1        => REFCLKPWRDNB1_indelay,
        REFSELDYPLL0         => REFSELDYPLL0_indelay,
        REFSELDYPLL1         => REFSELDYPLL1_indelay,
        RXBUFRESET0          => RXBUFRESET0_indelay,
        RXBUFRESET1          => RXBUFRESET1_indelay,
        RXCDRRESET0          => RXCDRRESET0_indelay,
        RXCDRRESET1          => RXCDRRESET1_indelay,
        RXCHBONDI            => RXCHBONDI_indelay,
        RXCHBONDMASTER0      => RXCHBONDMASTER0_indelay,
        RXCHBONDMASTER1      => RXCHBONDMASTER1_indelay,
        RXCHBONDSLAVE0       => RXCHBONDSLAVE0_indelay,
        RXCHBONDSLAVE1       => RXCHBONDSLAVE1_indelay,
        RXCOMMADETUSE0       => RXCOMMADETUSE0_indelay,
        RXCOMMADETUSE1       => RXCOMMADETUSE1_indelay,
        RXDATAWIDTH0         => RXDATAWIDTH0_indelay,
        RXDATAWIDTH1         => RXDATAWIDTH1_indelay,
        RXDEC8B10BUSE0       => RXDEC8B10BUSE0_indelay,
        RXDEC8B10BUSE1       => RXDEC8B10BUSE1_indelay,
        RXENCHANSYNC0        => RXENCHANSYNC0_indelay,
        RXENCHANSYNC1        => RXENCHANSYNC1_indelay,
        RXENMCOMMAALIGN0     => RXENMCOMMAALIGN0_indelay,
        RXENMCOMMAALIGN1     => RXENMCOMMAALIGN1_indelay,
        RXENPCOMMAALIGN0     => RXENPCOMMAALIGN0_indelay,
        RXENPCOMMAALIGN1     => RXENPCOMMAALIGN1_indelay,
        RXENPMAPHASEALIGN0   => RXENPMAPHASEALIGN0_indelay,
        RXENPMAPHASEALIGN1   => RXENPMAPHASEALIGN1_indelay,
        RXENPRBSTST0         => RXENPRBSTST0_indelay,
        RXENPRBSTST1         => RXENPRBSTST1_indelay,
        RXEQMIX0             => RXEQMIX0_indelay,
        RXEQMIX1             => RXEQMIX1_indelay,
        RXN0                 => RXN0_indelay,
        RXN1                 => RXN1_indelay,
        RXP0                 => RXP0_indelay,
        RXP1                 => RXP1_indelay,
        RXPMASETPHASE0       => RXPMASETPHASE0_indelay,
        RXPMASETPHASE1       => RXPMASETPHASE1_indelay,
        RXPOLARITY0          => RXPOLARITY0_indelay,
        RXPOLARITY1          => RXPOLARITY1_indelay,
        RXPOWERDOWN0         => RXPOWERDOWN0_indelay,
        RXPOWERDOWN1         => RXPOWERDOWN1_indelay,
        RXRESET0             => RXRESET0_indelay,
        RXRESET1             => RXRESET1_indelay,
        RXSLIDE0             => RXSLIDE0_indelay,
        RXSLIDE1             => RXSLIDE1_indelay,
        RXUSRCLK0            => RXUSRCLK0_indelay,
        RXUSRCLK1            => RXUSRCLK1_indelay,
        RXUSRCLK20           => RXUSRCLK20_indelay,
        RXUSRCLK21           => RXUSRCLK21_indelay,
        TSTCLK0              => TSTCLK0_indelay,
        TSTCLK1              => TSTCLK1_indelay,
        TSTIN0               => TSTIN0_indelay,
        TSTIN1               => TSTIN1_indelay,
        TXBUFDIFFCTRL0       => TXBUFDIFFCTRL0_indelay,
        TXBUFDIFFCTRL1       => TXBUFDIFFCTRL1_indelay,
        TXBYPASS8B10B0       => TXBYPASS8B10B0_indelay,
        TXBYPASS8B10B1       => TXBYPASS8B10B1_indelay,
        TXCHARDISPMODE0      => TXCHARDISPMODE0_indelay,
        TXCHARDISPMODE1      => TXCHARDISPMODE1_indelay,
        TXCHARDISPVAL0       => TXCHARDISPVAL0_indelay,
        TXCHARDISPVAL1       => TXCHARDISPVAL1_indelay,
        TXCHARISK0           => TXCHARISK0_indelay,
        TXCHARISK1           => TXCHARISK1_indelay,
        TXCOMSTART0          => TXCOMSTART0_indelay,
        TXCOMSTART1          => TXCOMSTART1_indelay,
        TXCOMTYPE0           => TXCOMTYPE0_indelay,
        TXCOMTYPE1           => TXCOMTYPE1_indelay,
        TXDATA0              => TXDATA0_indelay,
        TXDATA1              => TXDATA1_indelay,
        TXDATAWIDTH0         => TXDATAWIDTH0_indelay,
        TXDATAWIDTH1         => TXDATAWIDTH1_indelay,
        TXDETECTRX0          => TXDETECTRX0_indelay,
        TXDETECTRX1          => TXDETECTRX1_indelay,
        TXDIFFCTRL0          => TXDIFFCTRL0_indelay,
        TXDIFFCTRL1          => TXDIFFCTRL1_indelay,
        TXELECIDLE0          => TXELECIDLE0_indelay,
        TXELECIDLE1          => TXELECIDLE1_indelay,
        TXENC8B10BUSE0       => TXENC8B10BUSE0_indelay,
        TXENC8B10BUSE1       => TXENC8B10BUSE1_indelay,
        TXENPMAPHASEALIGN0   => TXENPMAPHASEALIGN0_indelay,
        TXENPMAPHASEALIGN1   => TXENPMAPHASEALIGN1_indelay,
        TXENPRBSTST0         => TXENPRBSTST0_indelay,
        TXENPRBSTST1         => TXENPRBSTST1_indelay,
        TXINHIBIT0           => TXINHIBIT0_indelay,
        TXINHIBIT1           => TXINHIBIT1_indelay,
        TXPDOWNASYNCH0       => TXPDOWNASYNCH0_indelay,
        TXPDOWNASYNCH1       => TXPDOWNASYNCH1_indelay,
        TXPMASETPHASE0       => TXPMASETPHASE0_indelay,
        TXPMASETPHASE1       => TXPMASETPHASE1_indelay,
        TXPOLARITY0          => TXPOLARITY0_indelay,
        TXPOLARITY1          => TXPOLARITY1_indelay,
        TXPOWERDOWN0         => TXPOWERDOWN0_indelay,
        TXPOWERDOWN1         => TXPOWERDOWN1_indelay,
        TXPRBSFORCEERR0      => TXPRBSFORCEERR0_indelay,
        TXPRBSFORCEERR1      => TXPRBSFORCEERR1_indelay,
        TXPREEMPHASIS0       => TXPREEMPHASIS0_indelay,
        TXPREEMPHASIS1       => TXPREEMPHASIS1_indelay,
        TXRESET0             => TXRESET0_indelay,
        TXRESET1             => TXRESET1_indelay,
        TXUSRCLK0            => TXUSRCLK0_indelay,
        TXUSRCLK1            => TXUSRCLK1_indelay,
        TXUSRCLK20           => TXUSRCLK20_indelay,
        TXUSRCLK21           => TXUSRCLK21_indelay,
        USRCODEERR0          => USRCODEERR0_indelay,
        USRCODEERR1          => USRCODEERR1_indelay,
        GSR                  => GSR_dly
      );
    
    INIPROC : process
    begin
    -- case CLK_OUT_GTP_SEL_0 is
      if((CLK_OUT_GTP_SEL_0 = "REFCLKPLL0") or (CLK_OUT_GTP_SEL_0 = "refclkpll0")) then
        CLK_OUT_GTP_SEL_0_BINARY <= '1';
      elsif((CLK_OUT_GTP_SEL_0 = "TXOUTCLK0") or (CLK_OUT_GTP_SEL_0= "txoutclk0")) then
        CLK_OUT_GTP_SEL_0_BINARY <= '0';
      else
        assert FALSE report "Error : CLK_OUT_GTP_SEL_0 = is not REFCLKPLL0, TXOUTCLK0." severity error;
      end if;
    -- end case;
    -- case CLK_OUT_GTP_SEL_1 is
      if((CLK_OUT_GTP_SEL_1 = "REFCLKPLL1") or (CLK_OUT_GTP_SEL_1 = "refclkpll1")) then
        CLK_OUT_GTP_SEL_1_BINARY <= '1';
      elsif((CLK_OUT_GTP_SEL_1 = "TXOUTCLK1") or (CLK_OUT_GTP_SEL_1= "txoutclk1")) then
        CLK_OUT_GTP_SEL_1_BINARY <= '0';
      else
        assert FALSE report "Error : CLK_OUT_GTP_SEL_1 = is not REFCLKPLL1, TXOUTCLK1." severity error;
      end if;
    -- end case;
    -- case PLL_SOURCE_0 is
      if((PLL_SOURCE_0 = "PLL0") or (PLL_SOURCE_0 = "pll0")) then
        PLL_SOURCE_0_BINARY <= '0';
      elsif((PLL_SOURCE_0 = "PLL1") or (PLL_SOURCE_0= "pll1")) then
        PLL_SOURCE_0_BINARY <= '1';
      else
        assert FALSE report "Error : PLL_SOURCE_0 = is not PLL0, PLL1." severity error;
      end if;
    -- end case;
    -- case PLL_SOURCE_1 is
      if((PLL_SOURCE_1 = "PLL0") or (PLL_SOURCE_1 = "pll0")) then
        PLL_SOURCE_1_BINARY <= '0';
      elsif((PLL_SOURCE_1 = "PLL1") or (PLL_SOURCE_1= "pll1")) then
        PLL_SOURCE_1_BINARY <= '1';
      else
        assert FALSE report "Error : PLL_SOURCE_1 = is not PLL0, PLL1." severity error;
      end if;
    -- end case;
    -- case RX_SLIDE_MODE_0 is
      if((RX_SLIDE_MODE_0 = "PCS") or (RX_SLIDE_MODE_0 = "pcs")) then
        RX_SLIDE_MODE_0_BINARY <= '0';
      elsif((RX_SLIDE_MODE_0 = "PMA") or (RX_SLIDE_MODE_0= "pma")) then
        RX_SLIDE_MODE_0_BINARY <= '1';
      else
        assert FALSE report "Error : RX_SLIDE_MODE_0 = is not PCS, PMA." severity error;
      end if;
    -- end case;
    -- case RX_SLIDE_MODE_1 is
      if((RX_SLIDE_MODE_1 = "PCS") or (RX_SLIDE_MODE_1 = "pcs")) then
        RX_SLIDE_MODE_1_BINARY <= '0';
      elsif((RX_SLIDE_MODE_1 = "PMA") or (RX_SLIDE_MODE_1= "pma")) then
        RX_SLIDE_MODE_1_BINARY <= '1';
      else
        assert FALSE report "Error : RX_SLIDE_MODE_1 = is not PCS, PMA." severity error;
      end if;
    -- end case;
    -- case RX_STATUS_FMT_0 is
      if((RX_STATUS_FMT_0 = "PCIE") or (RX_STATUS_FMT_0 = "pcie")) then
        RX_STATUS_FMT_0_BINARY <= '0';
      elsif((RX_STATUS_FMT_0 = "SATA") or (RX_STATUS_FMT_0= "sata")) then
        RX_STATUS_FMT_0_BINARY <= '1';
      else
        assert FALSE report "Error : RX_STATUS_FMT_0 = is not PCIE, SATA." severity error;
      end if;
    -- end case;
    -- case RX_STATUS_FMT_1 is
      if((RX_STATUS_FMT_1 = "PCIE") or (RX_STATUS_FMT_1 = "pcie")) then
        RX_STATUS_FMT_1_BINARY <= '0';
      elsif((RX_STATUS_FMT_1 = "SATA") or (RX_STATUS_FMT_1= "sata")) then
        RX_STATUS_FMT_1_BINARY <= '1';
      else
        assert FALSE report "Error : RX_STATUS_FMT_1 = is not PCIE, SATA." severity error;
      end if;
    -- end case;
    -- case RX_XCLK_SEL_0 is
      if((RX_XCLK_SEL_0 = "RXREC") or (RX_XCLK_SEL_0 = "rxrec")) then
        RX_XCLK_SEL_0_BINARY <= '0';
      elsif((RX_XCLK_SEL_0 = "RXUSR") or (RX_XCLK_SEL_0= "rxusr")) then
        RX_XCLK_SEL_0_BINARY <= '1';
      else
        assert FALSE report "Error : RX_XCLK_SEL_0 = is not RXREC, RXUSR." severity error;
      end if;
    -- end case;
    -- case RX_XCLK_SEL_1 is
      if((RX_XCLK_SEL_1 = "RXREC") or (RX_XCLK_SEL_1 = "rxrec")) then
        RX_XCLK_SEL_1_BINARY <= '0';
      elsif((RX_XCLK_SEL_1 = "RXUSR") or (RX_XCLK_SEL_1= "rxusr")) then
        RX_XCLK_SEL_1_BINARY <= '1';
      else
        assert FALSE report "Error : RX_XCLK_SEL_1 = is not RXREC, RXUSR." severity error;
      end if;
    -- end case;
    -- case SIM_TX_ELEC_IDLE_LEVEL is
      if((SIM_TX_ELEC_IDLE_LEVEL = "X") or (SIM_TX_ELEC_IDLE_LEVEL = "x")) then
        SIM_TX_ELEC_IDLE_LEVEL_BINARY <= '0';
      elsif((SIM_TX_ELEC_IDLE_LEVEL = "0") or (SIM_TX_ELEC_IDLE_LEVEL= "0")) then
        SIM_TX_ELEC_IDLE_LEVEL_BINARY <= '0';
      elsif((SIM_TX_ELEC_IDLE_LEVEL = "1") or (SIM_TX_ELEC_IDLE_LEVEL= "1")) then
        SIM_TX_ELEC_IDLE_LEVEL_BINARY <= '0';
      elsif((SIM_TX_ELEC_IDLE_LEVEL = "Z") or (SIM_TX_ELEC_IDLE_LEVEL= "z")) then
        SIM_TX_ELEC_IDLE_LEVEL_BINARY <= '0';
      else
        assert FALSE report "Error : SIM_TX_ELEC_IDLE_LEVEL = is not X, 0, 1, Z." severity error;
      end if;
    -- end case;
    -- case SIM_VERSION is
      if(SIM_VERSION = "2.0") then
        SIM_VERSION_BINARY <= '1';
      elsif(SIM_VERSION = "1.0") then
        SIM_VERSION_BINARY <= '0';
      else
        assert FALSE report "Error : SIM_VERSION = is not 2.0 or 1.0." severity error;
      end if;
    -- end case;
    -- case TX_XCLK_SEL_0 is
      if((TX_XCLK_SEL_0 = "TXUSR") or (TX_XCLK_SEL_0 = "txusr")) then
        TX_XCLK_SEL_0_BINARY <= '1';
      elsif((TX_XCLK_SEL_0 = "TXOUT") or (TX_XCLK_SEL_0= "txout")) then
        TX_XCLK_SEL_0_BINARY <= '0';
      else
        assert FALSE report "Error : TX_XCLK_SEL_0 = is not TXUSR, TXOUT." severity error;
      end if;
    -- end case;
    -- case TX_XCLK_SEL_1 is
      if((TX_XCLK_SEL_1 = "TXUSR") or (TX_XCLK_SEL_1 = "txusr")) then
        TX_XCLK_SEL_1_BINARY <= '1';
      elsif((TX_XCLK_SEL_1 = "TXOUT") or (TX_XCLK_SEL_1= "txout")) then
        TX_XCLK_SEL_1_BINARY <= '0';
      else
        assert FALSE report "Error : TX_XCLK_SEL_1 = is not TXUSR, TXOUT." severity error;
      end if;
    -- end case;
    -- case RXPRBSERR_LOOPBACK_0 is
      if ((RXPRBSERR_LOOPBACK_0 /= '0') and (RXPRBSERR_LOOPBACK_0 /= '1')) then
        assert FALSE report "Error : RXPRBSERR_LOOPBACK_0 is neither 0 or 1." severity error;
      end if;
    -- end case;
    -- case RXPRBSERR_LOOPBACK_1 is
      if ((RXPRBSERR_LOOPBACK_1 /= '0') and (RXPRBSERR_LOOPBACK_1 /= '1')) then
        assert FALSE report "Error : RXPRBSERR_LOOPBACK_1 is neither 0 or 1." severity error;
      end if;
    -- end case;
    case AC_CAP_DIS_0 is
      when FALSE   =>  AC_CAP_DIS_0_BINARY <= '0';
      when TRUE    =>  AC_CAP_DIS_0_BINARY <= '1';
      when others  =>  assert FALSE report "Error : AC_CAP_DIS_0 is neither TRUE nor FALSE." severity error;
    end case;
      case AC_CAP_DIS_1 is
        when FALSE   =>  AC_CAP_DIS_1_BINARY <= '0';
        when TRUE    =>  AC_CAP_DIS_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : AC_CAP_DIS_1 is neither TRUE nor FALSE." severity error;
      end case;
      case ALIGN_COMMA_WORD_0 is
        when  1   =>  ALIGN_COMMA_WORD_0_BINARY <= '0';
        when  2   =>  ALIGN_COMMA_WORD_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : ALIGN_COMMA_WORD_0 is not in range 1 .. 2." severity error;
      end case;
      case ALIGN_COMMA_WORD_1 is
        when  1   =>  ALIGN_COMMA_WORD_1_BINARY <= '0';
        when  2   =>  ALIGN_COMMA_WORD_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : ALIGN_COMMA_WORD_1 is not in range 1 .. 2." severity error;
      end case;
      case CHAN_BOND_KEEP_ALIGN_0 is
        when FALSE   =>  CHAN_BOND_KEEP_ALIGN_0_BINARY <= '0';
        when TRUE    =>  CHAN_BOND_KEEP_ALIGN_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CHAN_BOND_KEEP_ALIGN_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CHAN_BOND_KEEP_ALIGN_1 is
        when FALSE   =>  CHAN_BOND_KEEP_ALIGN_1_BINARY <= '0';
        when TRUE    =>  CHAN_BOND_KEEP_ALIGN_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CHAN_BOND_KEEP_ALIGN_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CHAN_BOND_SEQ_2_USE_0 is
        when FALSE   =>  CHAN_BOND_SEQ_2_USE_0_BINARY <= '0';
        when TRUE    =>  CHAN_BOND_SEQ_2_USE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_2_USE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CHAN_BOND_SEQ_2_USE_1 is
        when FALSE   =>  CHAN_BOND_SEQ_2_USE_1_BINARY <= '0';
        when TRUE    =>  CHAN_BOND_SEQ_2_USE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_2_USE_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CLKINDC_B_0 is
        when FALSE   =>  CLKINDC_B_0_BINARY <= '0';
        when TRUE    =>  CLKINDC_B_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLKINDC_B_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CLKINDC_B_1 is
        when FALSE   =>  CLKINDC_B_1_BINARY <= '0';
        when TRUE    =>  CLKINDC_B_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLKINDC_B_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CLKRCV_TRST_0 is
        when FALSE   =>  CLKRCV_TRST_0_BINARY <= '0';
        when TRUE    =>  CLKRCV_TRST_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLKRCV_TRST_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CLKRCV_TRST_1 is
        when FALSE   =>  CLKRCV_TRST_1_BINARY <= '0';
        when TRUE    =>  CLKRCV_TRST_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLKRCV_TRST_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_CORRECT_USE_0 is
        when FALSE   =>  CLK_CORRECT_USE_0_BINARY <= '0';
        when TRUE    =>  CLK_CORRECT_USE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_CORRECT_USE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_CORRECT_USE_1 is
        when FALSE   =>  CLK_CORRECT_USE_1_BINARY <= '0';
        when TRUE    =>  CLK_CORRECT_USE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_CORRECT_USE_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_INSERT_IDLE_FLAG_0 is
        when FALSE   =>  CLK_COR_INSERT_IDLE_FLAG_0_BINARY <= '0';
        when TRUE    =>  CLK_COR_INSERT_IDLE_FLAG_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_INSERT_IDLE_FLAG_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_INSERT_IDLE_FLAG_1 is
        when FALSE   =>  CLK_COR_INSERT_IDLE_FLAG_1_BINARY <= '0';
        when TRUE    =>  CLK_COR_INSERT_IDLE_FLAG_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_INSERT_IDLE_FLAG_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_KEEP_IDLE_0 is
        when FALSE   =>  CLK_COR_KEEP_IDLE_0_BINARY <= '0';
        when TRUE    =>  CLK_COR_KEEP_IDLE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_KEEP_IDLE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_KEEP_IDLE_1 is
        when FALSE   =>  CLK_COR_KEEP_IDLE_1_BINARY <= '0';
        when TRUE    =>  CLK_COR_KEEP_IDLE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_KEEP_IDLE_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_PRECEDENCE_0 is
        when FALSE   =>  CLK_COR_PRECEDENCE_0_BINARY <= '0';
        when TRUE    =>  CLK_COR_PRECEDENCE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_PRECEDENCE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_PRECEDENCE_1 is
        when FALSE   =>  CLK_COR_PRECEDENCE_1_BINARY <= '0';
        when TRUE    =>  CLK_COR_PRECEDENCE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_PRECEDENCE_1 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_SEQ_2_USE_0 is
        when FALSE   =>  CLK_COR_SEQ_2_USE_0_BINARY <= '0';
        when TRUE    =>  CLK_COR_SEQ_2_USE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_SEQ_2_USE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case CLK_COR_SEQ_2_USE_1 is
        when FALSE   =>  CLK_COR_SEQ_2_USE_1_BINARY <= '0';
        when TRUE    =>  CLK_COR_SEQ_2_USE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : CLK_COR_SEQ_2_USE_1 is neither TRUE nor FALSE." severity error;
      end case;
      case DEC_MCOMMA_DETECT_0 is
        when FALSE   =>  DEC_MCOMMA_DETECT_0_BINARY <= '0';
        when TRUE    =>  DEC_MCOMMA_DETECT_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : DEC_MCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
      end case;
      case DEC_MCOMMA_DETECT_1 is
        when FALSE   =>  DEC_MCOMMA_DETECT_1_BINARY <= '0';
        when TRUE    =>  DEC_MCOMMA_DETECT_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : DEC_MCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
      end case;
      case DEC_PCOMMA_DETECT_0 is
        when FALSE   =>  DEC_PCOMMA_DETECT_0_BINARY <= '0';
        when TRUE    =>  DEC_PCOMMA_DETECT_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : DEC_PCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
      end case;
      case DEC_PCOMMA_DETECT_1 is
        when FALSE   =>  DEC_PCOMMA_DETECT_1_BINARY <= '0';
        when TRUE    =>  DEC_PCOMMA_DETECT_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : DEC_PCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
      end case;
      case DEC_VALID_COMMA_ONLY_0 is
        when FALSE   =>  DEC_VALID_COMMA_ONLY_0_BINARY <= '0';
        when TRUE    =>  DEC_VALID_COMMA_ONLY_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : DEC_VALID_COMMA_ONLY_0 is neither TRUE nor FALSE." severity error;
      end case;
      case DEC_VALID_COMMA_ONLY_1 is
        when FALSE   =>  DEC_VALID_COMMA_ONLY_1_BINARY <= '0';
        when TRUE    =>  DEC_VALID_COMMA_ONLY_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : DEC_VALID_COMMA_ONLY_1 is neither TRUE nor FALSE." severity error;
      end case;
      case GTP_CFG_PWRUP_0 is
        when FALSE   =>  GTP_CFG_PWRUP_0_BINARY <= '0';
        when TRUE    =>  GTP_CFG_PWRUP_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : GTP_CFG_PWRUP_0 is neither TRUE nor FALSE." severity error;
      end case;
      case GTP_CFG_PWRUP_1 is
        when FALSE   =>  GTP_CFG_PWRUP_1_BINARY <= '0';
        when TRUE    =>  GTP_CFG_PWRUP_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : GTP_CFG_PWRUP_1 is neither TRUE nor FALSE." severity error;
      end case;
      case MCOMMA_DETECT_0 is
        when FALSE   =>  MCOMMA_DETECT_0_BINARY <= '0';
        when TRUE    =>  MCOMMA_DETECT_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : MCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
      end case;
      case MCOMMA_DETECT_1 is
        when FALSE   =>  MCOMMA_DETECT_1_BINARY <= '0';
        when TRUE    =>  MCOMMA_DETECT_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : MCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
      end case;
      case PCI_EXPRESS_MODE_0 is
        when FALSE   =>  PCI_EXPRESS_MODE_0_BINARY <= '0';
        when TRUE    =>  PCI_EXPRESS_MODE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : PCI_EXPRESS_MODE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case PCI_EXPRESS_MODE_1 is
        when FALSE   =>  PCI_EXPRESS_MODE_1_BINARY <= '0';
        when TRUE    =>  PCI_EXPRESS_MODE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : PCI_EXPRESS_MODE_1 is neither TRUE nor FALSE." severity error;
      end case;
      case PCOMMA_DETECT_0 is
        when FALSE   =>  PCOMMA_DETECT_0_BINARY <= '0';
        when TRUE    =>  PCOMMA_DETECT_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : PCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
      end case;
      case PCOMMA_DETECT_1 is
        when FALSE   =>  PCOMMA_DETECT_1_BINARY <= '0';
        when TRUE    =>  PCOMMA_DETECT_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : PCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
      end case;
      case PLL_SATA_0 is
        when FALSE   =>  PLL_SATA_0_BINARY <= '0';
        when TRUE    =>  PLL_SATA_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : PLL_SATA_0 is neither TRUE nor FALSE." severity error;
      end case;
      case PLL_SATA_1 is
        when FALSE   =>  PLL_SATA_1_BINARY <= '0';
        when TRUE    =>  PLL_SATA_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : PLL_SATA_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RCV_TERM_GND_0 is
        when FALSE   =>  RCV_TERM_GND_0_BINARY <= '0';
        when TRUE    =>  RCV_TERM_GND_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RCV_TERM_GND_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RCV_TERM_GND_1 is
        when FALSE   =>  RCV_TERM_GND_1_BINARY <= '0';
        when TRUE    =>  RCV_TERM_GND_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RCV_TERM_GND_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RCV_TERM_VTTRX_0 is
        when FALSE   =>  RCV_TERM_VTTRX_0_BINARY <= '0';
        when TRUE    =>  RCV_TERM_VTTRX_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RCV_TERM_VTTRX_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RCV_TERM_VTTRX_1 is
        when FALSE   =>  RCV_TERM_VTTRX_1_BINARY <= '0';
        when TRUE    =>  RCV_TERM_VTTRX_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RCV_TERM_VTTRX_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_BUFFER_USE_0 is
        when FALSE   =>  RX_BUFFER_USE_0_BINARY <= '0';
        when TRUE    =>  RX_BUFFER_USE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_BUFFER_USE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_BUFFER_USE_1 is
        when FALSE   =>  RX_BUFFER_USE_1_BINARY <= '0';
        when TRUE    =>  RX_BUFFER_USE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_BUFFER_USE_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_DECODE_SEQ_MATCH_0 is
        when FALSE   =>  RX_DECODE_SEQ_MATCH_0_BINARY <= '0';
        when TRUE    =>  RX_DECODE_SEQ_MATCH_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_DECODE_SEQ_MATCH_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_DECODE_SEQ_MATCH_1 is
        when FALSE   =>  RX_DECODE_SEQ_MATCH_1_BINARY <= '0';
        when TRUE    =>  RX_DECODE_SEQ_MATCH_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_DECODE_SEQ_MATCH_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_HOLD_CDR_0 is
        when FALSE   =>  RX_EN_IDLE_HOLD_CDR_0_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_HOLD_CDR_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_HOLD_CDR_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_HOLD_CDR_1 is
        when FALSE   =>  RX_EN_IDLE_HOLD_CDR_1_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_HOLD_CDR_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_HOLD_CDR_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_RESET_BUF_0 is
        when FALSE   =>  RX_EN_IDLE_RESET_BUF_0_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_RESET_BUF_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_BUF_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_RESET_BUF_1 is
        when FALSE   =>  RX_EN_IDLE_RESET_BUF_1_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_RESET_BUF_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_BUF_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_RESET_FR_0 is
        when FALSE   =>  RX_EN_IDLE_RESET_FR_0_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_RESET_FR_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_FR_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_RESET_FR_1 is
        when FALSE   =>  RX_EN_IDLE_RESET_FR_1_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_RESET_FR_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_FR_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_RESET_PH_0 is
        when FALSE   =>  RX_EN_IDLE_RESET_PH_0_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_RESET_PH_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_PH_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_IDLE_RESET_PH_1 is
        when FALSE   =>  RX_EN_IDLE_RESET_PH_1_BINARY <= '0';
        when TRUE    =>  RX_EN_IDLE_RESET_PH_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_PH_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_MODE_RESET_BUF_0 is
        when FALSE   =>  RX_EN_MODE_RESET_BUF_0_BINARY <= '0';
        when TRUE    =>  RX_EN_MODE_RESET_BUF_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_MODE_RESET_BUF_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_EN_MODE_RESET_BUF_1 is
        when FALSE   =>  RX_EN_MODE_RESET_BUF_1_BINARY <= '0';
        when TRUE    =>  RX_EN_MODE_RESET_BUF_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_EN_MODE_RESET_BUF_1 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_LOSS_OF_SYNC_FSM_0 is
        when FALSE   =>  RX_LOSS_OF_SYNC_FSM_0_BINARY <= '0';
        when TRUE    =>  RX_LOSS_OF_SYNC_FSM_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_LOSS_OF_SYNC_FSM_0 is neither TRUE nor FALSE." severity error;
      end case;
      case RX_LOSS_OF_SYNC_FSM_1 is
        when FALSE   =>  RX_LOSS_OF_SYNC_FSM_1_BINARY <= '0';
        when TRUE    =>  RX_LOSS_OF_SYNC_FSM_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : RX_LOSS_OF_SYNC_FSM_1 is neither TRUE nor FALSE." severity error;
      end case;
    case SIM_GTPRESET_SPEEDUP is
      when  0   =>  SIM_GTPRESET_SPEEDUP_BINARY <= '0';
      when  1   =>  SIM_GTPRESET_SPEEDUP_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SIM_GTPRESET_SPEEDUP is not in range 0 .. 1." severity error;
    end case;
    case SIM_RECEIVER_DETECT_PASS is
      when FALSE   =>  SIM_RECEIVER_DETECT_PASS_BINARY <= '0';
      when TRUE    =>  SIM_RECEIVER_DETECT_PASS_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SIM_RECEIVER_DETECT_PASS is neither TRUE nor FALSE." severity error;
    end case;
      case TERMINATION_OVRD_0 is
        when FALSE   =>  TERMINATION_OVRD_0_BINARY <= '0';
        when TRUE    =>  TERMINATION_OVRD_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : TERMINATION_OVRD_0 is neither TRUE nor FALSE." severity error;
      end case;
      case TERMINATION_OVRD_1 is
        when FALSE   =>  TERMINATION_OVRD_1_BINARY <= '0';
        when TRUE    =>  TERMINATION_OVRD_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : TERMINATION_OVRD_1 is neither TRUE nor FALSE." severity error;
      end case;
      case TX_BUFFER_USE_0 is
        when FALSE   =>  TX_BUFFER_USE_0_BINARY <= '0';
        when TRUE    =>  TX_BUFFER_USE_0_BINARY <= '1';
        when others  =>  assert FALSE report "Error : TX_BUFFER_USE_0 is neither TRUE nor FALSE." severity error;
      end case;
      case TX_BUFFER_USE_1 is
        when FALSE   =>  TX_BUFFER_USE_1_BINARY <= '0';
        when TRUE    =>  TX_BUFFER_USE_1_BINARY <= '1';
        when others  =>  assert FALSE report "Error : TX_BUFFER_USE_1 is neither TRUE nor FALSE." severity error;
      end case;
      if ((CB2_INH_CC_PERIOD_0 >= 0) and (CB2_INH_CC_PERIOD_0 <= 15)) then
        CB2_INH_CC_PERIOD_0_BINARY <= CONV_STD_LOGIC_VECTOR(CB2_INH_CC_PERIOD_0, 4);
      else
        assert FALSE report "Error : CB2_INH_CC_PERIOD_0 is not in range 0 .. 15." severity error;
      end if;
      if ((CB2_INH_CC_PERIOD_1 >= 0) and (CB2_INH_CC_PERIOD_1 <= 15)) then
        CB2_INH_CC_PERIOD_1_BINARY <= CONV_STD_LOGIC_VECTOR(CB2_INH_CC_PERIOD_1, 4);
      else
        assert FALSE report "Error : CB2_INH_CC_PERIOD_1 is not in range 0 .. 15." severity error;
      end if;
    if ((CDR_PH_ADJ_TIME_0 < "00000") or (CDR_PH_ADJ_TIME_0 > "11111")) then
      assert FALSE report "Error : CDR_PH_ADJ_TIME_0 is not in range 0 .. 31." severity error;
    end if;
    if ((CDR_PH_ADJ_TIME_1 < "00000") or (CDR_PH_ADJ_TIME_1 > "11111")) then
      assert FALSE report "Error : CDR_PH_ADJ_TIME_1 is not in range 0 .. 31." severity error;
    end if;
      if ((CHAN_BOND_1_MAX_SKEW_0 >= 1) and (CHAN_BOND_1_MAX_SKEW_0 <= 14)) then
        CHAN_BOND_1_MAX_SKEW_0_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_1_MAX_SKEW_0, 4);
      else
        assert FALSE report "Error : CHAN_BOND_1_MAX_SKEW_0 is not in range 1 .. 14." severity error;
      end if;
      if ((CHAN_BOND_1_MAX_SKEW_1 >= 1) and (CHAN_BOND_1_MAX_SKEW_1 <= 14)) then
        CHAN_BOND_1_MAX_SKEW_1_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_1_MAX_SKEW_1, 4);
      else
        assert FALSE report "Error : CHAN_BOND_1_MAX_SKEW_1 is not in range 1 .. 14." severity error;
      end if;
      if ((CHAN_BOND_2_MAX_SKEW_0 >= 1) and (CHAN_BOND_2_MAX_SKEW_0 <= 14)) then
        CHAN_BOND_2_MAX_SKEW_0_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_2_MAX_SKEW_0, 4);
      else
        assert FALSE report "Error : CHAN_BOND_2_MAX_SKEW_0 is not in range 1 .. 14." severity error;
      end if;
      if ((CHAN_BOND_2_MAX_SKEW_1 >= 1) and (CHAN_BOND_2_MAX_SKEW_1 <= 14)) then
        CHAN_BOND_2_MAX_SKEW_1_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_2_MAX_SKEW_1, 4);
      else
        assert FALSE report "Error : CHAN_BOND_2_MAX_SKEW_1 is not in range 1 .. 14." severity error;
      end if;
      if (CHAN_BOND_2_MAX_SKEW_0 > CHAN_BOND_1_MAX_SKEW_0) then
        assert FALSE report "Error : CHAN_BOND_2_MAX_SKEW_0 must be less than or equal to CHAN_BOND_1_MAX_SKEW_0 ." severity error;
      end if;
      if (CHAN_BOND_2_MAX_SKEW_1 > CHAN_BOND_1_MAX_SKEW_1) then
        assert FALSE report "Error : CHAN_BOND_2_MAX_SKEW_1 must be less than or equal to CHAN_BOND_1_MAX_SKEW_0 ." severity error;
      end if;
    if ((CHAN_BOND_SEQ_1_1_0 < "0000000000") or (CHAN_BOND_SEQ_1_1_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_1_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_1_1 < "0000000000") or (CHAN_BOND_SEQ_1_1_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_1_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_2_0 < "0000000000") or (CHAN_BOND_SEQ_1_2_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_2_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_2_1 < "0000000000") or (CHAN_BOND_SEQ_1_2_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_2_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_3_0 < "0000000000") or (CHAN_BOND_SEQ_1_3_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_3_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_3_1 < "0000000000") or (CHAN_BOND_SEQ_1_3_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_3_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_4_0 < "0000000000") or (CHAN_BOND_SEQ_1_4_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_4_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_4_1 < "0000000000") or (CHAN_BOND_SEQ_1_4_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_4_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_ENABLE_0 < "0000") or (CHAN_BOND_SEQ_1_ENABLE_0 > "1111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_ENABLE_0 is not in range 0 .. 15." severity error;
    end if;
    if ((CHAN_BOND_SEQ_1_ENABLE_1 < "0000") or (CHAN_BOND_SEQ_1_ENABLE_1 > "1111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_1_ENABLE_1 is not in range 0 .. 15." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_1_0 < "0000000000") or (CHAN_BOND_SEQ_2_1_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_1_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_1_1 < "0000000000") or (CHAN_BOND_SEQ_2_1_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_1_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_2_0 < "0000000000") or (CHAN_BOND_SEQ_2_2_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_2_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_2_1 < "0000000000") or (CHAN_BOND_SEQ_2_2_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_2_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_3_0 < "0000000000") or (CHAN_BOND_SEQ_2_3_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_3_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_3_1 < "0000000000") or (CHAN_BOND_SEQ_2_3_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_3_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_4_0 < "0000000000") or (CHAN_BOND_SEQ_2_4_0 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_4_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_4_1 < "0000000000") or (CHAN_BOND_SEQ_2_4_1 > "1111111111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_4_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_ENABLE_0 < "0000") or (CHAN_BOND_SEQ_2_ENABLE_0 > "1111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_ENABLE_0 is not in range 0 .. 15." severity error;
    end if;
    if ((CHAN_BOND_SEQ_2_ENABLE_1 < "0000") or (CHAN_BOND_SEQ_2_ENABLE_1 > "1111")) then
      assert FALSE report "Error : CHAN_BOND_SEQ_2_ENABLE_1 is not in range 0 .. 15." severity error;
      end if;
      if ((CHAN_BOND_SEQ_LEN_0 >= 1) and (CHAN_BOND_SEQ_LEN_0 <= 4)) then
        CHAN_BOND_SEQ_LEN_0_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_SEQ_LEN_0 - 1, 2);
      else
        assert FALSE report "Error : CHAN_BOND_SEQ_LEN_0 is not in range 1 .. 4." severity error;
      end if;
      if ((CHAN_BOND_SEQ_LEN_1 >= 1) and (CHAN_BOND_SEQ_LEN_1 <= 4)) then
        CHAN_BOND_SEQ_LEN_1_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_SEQ_LEN_1 - 1, 2);
      else
        assert FALSE report "Error : CHAN_BOND_SEQ_LEN_1 is not in range 1 .. 4." severity error;
      end if;
      case CLK25_DIVIDER_0 is
        when  1   =>  CLK25_DIVIDER_0_BINARY <= "000";
        when  2   =>  CLK25_DIVIDER_0_BINARY <= "001";
        when  3   =>  CLK25_DIVIDER_0_BINARY <= "010";
        when  4   =>  CLK25_DIVIDER_0_BINARY <= "011";
        when  5   =>  CLK25_DIVIDER_0_BINARY <= "100";
        when  6   =>  CLK25_DIVIDER_0_BINARY <= "101";
        when  10  =>  CLK25_DIVIDER_0_BINARY <= "110";
        when  12  =>  CLK25_DIVIDER_0_BINARY <= "111";
        when others  =>  assert FALSE report "Error : CLK25_DIVIDER_0 is not 1, 2, 3, 4, 5, 6, 10 or 12." severity error;
      end case;
      case CLK25_DIVIDER_1 is
        when  1   =>  CLK25_DIVIDER_1_BINARY <= "000";
        when  2   =>  CLK25_DIVIDER_1_BINARY <= "001";
        when  3   =>  CLK25_DIVIDER_1_BINARY <= "010";
        when  4   =>  CLK25_DIVIDER_1_BINARY <= "011";
        when  5   =>  CLK25_DIVIDER_1_BINARY <= "100";
        when  6   =>  CLK25_DIVIDER_1_BINARY <= "101";
        when  10  =>  CLK25_DIVIDER_1_BINARY <= "110";
        when  12  =>  CLK25_DIVIDER_1_BINARY <= "111";
        when others  =>  assert FALSE report "Error : CLK25_DIVIDER_1 is not 1, 2, 3, 4, 5, 6, 10 or 12." severity error;
      end case;
      if ((CLK_COR_ADJ_LEN_0 >= 1) and (CLK_COR_ADJ_LEN_0 <= 4)) then
        CLK_COR_ADJ_LEN_0_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_ADJ_LEN_0 - 1, 2);
      else
        assert FALSE report "Error : CLK_COR_ADJ_LEN_0 is not in range 1 .. 4." severity error;
      end if;
      if ((CLK_COR_ADJ_LEN_1 >= 1) and (CLK_COR_ADJ_LEN_1 <= 4)) then
        CLK_COR_ADJ_LEN_1_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_ADJ_LEN_1 - 1, 2);
      else
        assert FALSE report "Error : CLK_COR_ADJ_LEN_1 is not in range 1 .. 4." severity error;
      end if;
      if ((CLK_COR_DET_LEN_0 >= 1) and (CLK_COR_DET_LEN_0 <= 4)) then
        CLK_COR_DET_LEN_0_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_DET_LEN_0 - 1, 2);
      else
        assert FALSE report "Error : CLK_COR_DET_LEN_0 is not in range 1 .. 4." severity error;
      end if;
      if ((CLK_COR_DET_LEN_1 >= 1) and (CLK_COR_DET_LEN_1 <= 4)) then
        CLK_COR_DET_LEN_1_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_DET_LEN_1 - 1, 2);
      else
        assert FALSE report "Error : CLK_COR_DET_LEN_1 is not in range 1 .. 4." severity error;
      end if;
      if ((CLK_COR_MAX_LAT_0 >= 3) and (CLK_COR_MAX_LAT_0 <= 48)) then
        CLK_COR_MAX_LAT_0_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_MAX_LAT_0, 6);
      else
        assert FALSE report "Error : CLK_COR_MAX_LAT_0 is not in range 3 .. 48." severity error;
      end if;
      if ((CLK_COR_MAX_LAT_1 >= 3) and (CLK_COR_MAX_LAT_1 <= 48)) then
        CLK_COR_MAX_LAT_1_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_MAX_LAT_1, 6);
      else
        assert FALSE report "Error : CLK_COR_MAX_LAT_1 is not in range 3 .. 48." severity error;
      end if;
      if ((CLK_COR_MIN_LAT_0 >= 3) and (CLK_COR_MIN_LAT_0 <= 48)) then
        CLK_COR_MIN_LAT_0_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_MIN_LAT_0, 6);
      else
        assert FALSE report "Error : CLK_COR_MIN_LAT_0 is not in range 3 .. 48." severity error;
      end if;
      if ((CLK_COR_MIN_LAT_1 >= 3) and (CLK_COR_MIN_LAT_1 <= 48)) then
        CLK_COR_MIN_LAT_1_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_MIN_LAT_1, 6);
      else
        assert FALSE report "Error : CLK_COR_MIN_LAT_1 is not in range 3 .. 48." severity error;
      end if;
      if ((CLK_COR_REPEAT_WAIT_0 >= 0) and (CLK_COR_REPEAT_WAIT_0 <= 31)) then
        CLK_COR_REPEAT_WAIT_0_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_REPEAT_WAIT_0, 5);
      else
        assert FALSE report "Error : CLK_COR_REPEAT_WAIT_0 is not in range 0 .. 31." severity error;
      end if;
      if ((CLK_COR_REPEAT_WAIT_1 >= 0) and (CLK_COR_REPEAT_WAIT_1 <= 31)) then
        CLK_COR_REPEAT_WAIT_1_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_REPEAT_WAIT_1, 5);
      else
        assert FALSE report "Error : CLK_COR_REPEAT_WAIT_1 is not in range 0 .. 31." severity error;
      end if;
    if ((CLK_COR_SEQ_1_1_0 < "0000000000") or (CLK_COR_SEQ_1_1_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_1_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_1_1 < "0000000000") or (CLK_COR_SEQ_1_1_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_1_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_2_0 < "0000000000") or (CLK_COR_SEQ_1_2_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_2_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_2_1 < "0000000000") or (CLK_COR_SEQ_1_2_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_2_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_3_0 < "0000000000") or (CLK_COR_SEQ_1_3_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_3_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_3_1 < "0000000000") or (CLK_COR_SEQ_1_3_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_3_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_4_0 < "0000000000") or (CLK_COR_SEQ_1_4_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_4_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_4_1 < "0000000000") or (CLK_COR_SEQ_1_4_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_4_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_1_ENABLE_0 < "0000") or (CLK_COR_SEQ_1_ENABLE_0 > "1111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_ENABLE_0 is not in range 0 .. 15." severity error;
    end if;
    if ((CLK_COR_SEQ_1_ENABLE_1 < "0000") or (CLK_COR_SEQ_1_ENABLE_1 > "1111")) then
      assert FALSE report "Error : CLK_COR_SEQ_1_ENABLE_1 is not in range 0 .. 15." severity error;
    end if;
    if ((CLK_COR_SEQ_2_1_0 < "0000000000") or (CLK_COR_SEQ_2_1_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_1_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_1_1 < "0000000000") or (CLK_COR_SEQ_2_1_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_1_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_2_0 < "0000000000") or (CLK_COR_SEQ_2_2_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_2_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_2_1 < "0000000000") or (CLK_COR_SEQ_2_2_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_2_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_3_0 < "0000000000") or (CLK_COR_SEQ_2_3_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_3_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_3_1 < "0000000000") or (CLK_COR_SEQ_2_3_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_3_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_4_0 < "0000000000") or (CLK_COR_SEQ_2_4_0 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_4_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_4_1 < "0000000000") or (CLK_COR_SEQ_2_4_1 > "1111111111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_4_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((CLK_COR_SEQ_2_ENABLE_0 < "0000") or (CLK_COR_SEQ_2_ENABLE_0 > "1111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_ENABLE_0 is not in range 0 .. 15." severity error;
    end if;
    if ((CLK_COR_SEQ_2_ENABLE_1 < "0000") or (CLK_COR_SEQ_2_ENABLE_1 > "1111")) then
      assert FALSE report "Error : CLK_COR_SEQ_2_ENABLE_1 is not in range 0 .. 15." severity error;
    end if;
    if ((CM_TRIM_0 < "00") or (CM_TRIM_0 > "11")) then
      assert FALSE report "Error : CM_TRIM_0 is not in range 0 .. 3." severity error;
    end if;
    if ((CM_TRIM_1 < "00") or (CM_TRIM_1 > "11")) then
      assert FALSE report "Error : CM_TRIM_1 is not in range 0 .. 3." severity error;
    end if;
    if ((COMMA_10B_ENABLE_0 < "0000000000") or (COMMA_10B_ENABLE_0 > "1111111111")) then
      assert FALSE report "Error : COMMA_10B_ENABLE_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((COMMA_10B_ENABLE_1 < "0000000000") or (COMMA_10B_ENABLE_1 > "1111111111")) then
      assert FALSE report "Error : COMMA_10B_ENABLE_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((COM_BURST_VAL_0 < "0000") or (COM_BURST_VAL_0 > "1111")) then
      assert FALSE report "Error : COM_BURST_VAL_0 is not in range 0 .. 15." severity error;
    end if;
    if ((COM_BURST_VAL_1 < "0000") or (COM_BURST_VAL_1 > "1111")) then
      assert FALSE report "Error : COM_BURST_VAL_1 is not in range 0 .. 15." severity error;
    end if;
    if ((MCOMMA_10B_VALUE_0 < "0000000000") or (MCOMMA_10B_VALUE_0 > "1111111111")) then
      assert FALSE report "Error : MCOMMA_10B_VALUE_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((MCOMMA_10B_VALUE_1 < "0000000000") or (MCOMMA_10B_VALUE_1 > "1111111111")) then
      assert FALSE report "Error : MCOMMA_10B_VALUE_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((OOBDETECT_THRESHOLD_0 < "000") or (OOBDETECT_THRESHOLD_0 > "111")) then
      assert FALSE report "Error : OOBDETECT_THRESHOLD_0 is not in range 0 .. 7." severity error;
    end if;
    if ((OOBDETECT_THRESHOLD_1 < "000") or (OOBDETECT_THRESHOLD_1 > "111")) then
      assert FALSE report "Error : OOBDETECT_THRESHOLD_1 is not in range 0 .. 7." severity error;
    end if;
      case OOB_CLK_DIVIDER_0 is
        when  1   =>  OOB_CLK_DIVIDER_0_BINARY <= "000";
        when  2   =>  OOB_CLK_DIVIDER_0_BINARY <= "001";
        when  4   =>  OOB_CLK_DIVIDER_0_BINARY <= "010";
        when  6   =>  OOB_CLK_DIVIDER_0_BINARY <= "011";
        when  8   =>  OOB_CLK_DIVIDER_0_BINARY <= "100";
        when  10   =>  OOB_CLK_DIVIDER_0_BINARY <= "101";
        when  12   =>  OOB_CLK_DIVIDER_0_BINARY <= "110";
        when  14   =>  OOB_CLK_DIVIDER_0_BINARY <= "111";
        when others  =>  assert FALSE report "Error : OOB_CLK_DIVIDER_0 is not in range 1, 2, 4, 6, 8, 10, 12 or 14." severity error;
      end case;
      case OOB_CLK_DIVIDER_1 is
        when  1   =>  OOB_CLK_DIVIDER_1_BINARY <= "000";
        when  2   =>  OOB_CLK_DIVIDER_1_BINARY <= "001";
        when  4   =>  OOB_CLK_DIVIDER_1_BINARY <= "010";
        when  6   =>  OOB_CLK_DIVIDER_1_BINARY <= "011";
        when  8   =>  OOB_CLK_DIVIDER_1_BINARY <= "100";
        when  10   =>  OOB_CLK_DIVIDER_1_BINARY <= "101";
        when  12   =>  OOB_CLK_DIVIDER_1_BINARY <= "110";
        when  14   =>  OOB_CLK_DIVIDER_1_BINARY <= "111";
        when others  =>  assert FALSE report "Error : OOB_CLK_DIVIDER_1 is not 1, 2, 4, 6, 8, 10, 12 or 14." severity error;
      end case;
    if ((PCOMMA_10B_VALUE_0 < "0000000000") or (PCOMMA_10B_VALUE_0 > "1111111111")) then
      assert FALSE report "Error : PCOMMA_10B_VALUE_0 is not in range 0 .. 1023." severity error;
    end if;
    if ((PCOMMA_10B_VALUE_1 < "0000000000") or (PCOMMA_10B_VALUE_1 > "1111111111")) then
      assert FALSE report "Error : PCOMMA_10B_VALUE_1 is not in range 0 .. 1023." severity error;
    end if;
    if ((PLLLKDET_CFG_0 < "000") or (PLLLKDET_CFG_0 > "111")) then
      assert FALSE report "Error : PLLLKDET_CFG_0 is not in range 0 .. 7." severity error;
    end if;
    if ((PLLLKDET_CFG_1 < "000") or (PLLLKDET_CFG_1 > "111")) then
      assert FALSE report "Error : PLLLKDET_CFG_1 is not in range 0 .. 7." severity error;
    end if;
      case PLL_DIVSEL_FB_0 is
        when  1   =>  PLL_DIVSEL_FB_0_BINARY <= "10000";
        when  2   =>  PLL_DIVSEL_FB_0_BINARY <= "00000";
        when  3   =>  PLL_DIVSEL_FB_0_BINARY <= "00001";
        when  4   =>  PLL_DIVSEL_FB_0_BINARY <= "00010";
        when  5   =>  PLL_DIVSEL_FB_0_BINARY <= "00011";
        when  8   =>  PLL_DIVSEL_FB_0_BINARY <= "00110";
        when  10   =>  PLL_DIVSEL_FB_0_BINARY <= "00111";
        when others  =>  assert FALSE report "Error : PLL_DIVSEL_FB_0 is not in range 1 to 5 or 8 or 10." severity error;
      end case;
      case PLL_DIVSEL_FB_1 is
        when  1   =>  PLL_DIVSEL_FB_1_BINARY <= "10000";
        when  2   =>  PLL_DIVSEL_FB_1_BINARY <= "00000";
        when  3   =>  PLL_DIVSEL_FB_1_BINARY <= "00001";
        when  4   =>  PLL_DIVSEL_FB_1_BINARY <= "00010";
        when  5   =>  PLL_DIVSEL_FB_1_BINARY <= "00011";
        when  8   =>  PLL_DIVSEL_FB_1_BINARY <= "00110";
        when  10   =>  PLL_DIVSEL_FB_1_BINARY <= "00111";
        when others  =>  assert FALSE report "Error : PLL_DIVSEL_FB_1 is not in range 1 to 5 or 8 or 10." severity error;
      end case;
      case PLL_DIVSEL_REF_0 is
        when  1   =>  PLL_DIVSEL_REF_0_BINARY <= "010000";
        when  2   =>  PLL_DIVSEL_REF_0_BINARY <= "000000";
        when  3   =>  PLL_DIVSEL_REF_0_BINARY <= "000001";
        when  4   =>  PLL_DIVSEL_REF_0_BINARY <= "000010";
        when  5   =>  PLL_DIVSEL_REF_0_BINARY <= "000011";
        when  6   =>  PLL_DIVSEL_REF_0_BINARY <= "000101";
        when  8   =>  PLL_DIVSEL_REF_0_BINARY <= "000110";
        when  10   =>  PLL_DIVSEL_REF_0_BINARY <= "000111";
        when  12   =>  PLL_DIVSEL_REF_0_BINARY <= "001101";
        when  16   =>  PLL_DIVSEL_REF_0_BINARY <= "001110";
        when  20   =>  PLL_DIVSEL_REF_0_BINARY <= "001111";
        when others  =>  assert FALSE report "Error : PLL_DIVSEL_REF_0 is not in range 1 to 6 or 8, 10 ,12, 16 or 20." severity error;
      end case;
      case PLL_DIVSEL_REF_1 is
        when  1   =>  PLL_DIVSEL_REF_1_BINARY <= "010000";
        when  2   =>  PLL_DIVSEL_REF_1_BINARY <= "000000";
        when  3   =>  PLL_DIVSEL_REF_1_BINARY <= "000001";
        when  4   =>  PLL_DIVSEL_REF_1_BINARY <= "000010";
        when  5   =>  PLL_DIVSEL_REF_1_BINARY <= "000011";
        when  6   =>  PLL_DIVSEL_REF_1_BINARY <= "000101";
        when  8   =>  PLL_DIVSEL_REF_1_BINARY <= "000110";
        when  10   =>  PLL_DIVSEL_REF_1_BINARY <= "000111";
        when  12   =>  PLL_DIVSEL_REF_1_BINARY <= "001101";
        when  16   =>  PLL_DIVSEL_REF_1_BINARY <= "001110";
        when  20   =>  PLL_DIVSEL_REF_1_BINARY <= "001111";
        when others  =>  assert FALSE report "Error : PLL_DIVSEL_REF_1 is not in range 1 to 6 or 8, 10 ,12, 16 or 20." severity error;
      end case;
      case PLL_RXDIVSEL_OUT_0 is
        when  1   =>  PLL_RXDIVSEL_OUT_0_BINARY <= "00";
        when  2   =>  PLL_RXDIVSEL_OUT_0_BINARY <= "01";
        when  4   =>  PLL_RXDIVSEL_OUT_0_BINARY <= "10";
        when others  =>  assert FALSE report "Error : PLL_RXDIVSEL_OUT_0 is not in range 1, 2 or 4." severity error;
      end case;
      case PLL_RXDIVSEL_OUT_1 is
        when  1   =>  PLL_RXDIVSEL_OUT_1_BINARY <= "00";
        when  2   =>  PLL_RXDIVSEL_OUT_1_BINARY <= "01";
        when  4   =>  PLL_RXDIVSEL_OUT_1_BINARY <= "10";
        when others  =>  assert FALSE report "Error : PLL_RXDIVSEL_OUT_1 is not in range 1, 2 or 4." severity error;
      end case;
      case PLL_TXDIVSEL_OUT_0 is
        when  1   =>  PLL_TXDIVSEL_OUT_0_BINARY <= "00";
        when  2   =>  PLL_TXDIVSEL_OUT_0_BINARY <= "01";
        when  4   =>  PLL_TXDIVSEL_OUT_0_BINARY <= "10";
        when others  =>  assert FALSE report "Error : PLL_TXDIVSEL_OUT_0 is not in range 1, 2 or 4." severity error;
      end case;
      case PLL_TXDIVSEL_OUT_1 is
        when  1   =>  PLL_TXDIVSEL_OUT_1_BINARY <= "00";
        when  2   =>  PLL_TXDIVSEL_OUT_1_BINARY <= "01";
        when  4   =>  PLL_TXDIVSEL_OUT_1_BINARY <= "10";
        when others  =>  assert FALSE report "Error : PLL_TXDIVSEL_OUT_1 is not in range 1, 2 or 4." severity error;
      end case;
    if ((RXEQ_CFG_0 < "00000000") or (RXEQ_CFG_0 > "11111111")) then
      assert FALSE report "Error : RXEQ_CFG_0 is not in range 0 .. 255." severity error;
    end if;
    if ((RXEQ_CFG_1 < "00000000") or (RXEQ_CFG_1 > "11111111")) then
      assert FALSE report "Error : RXEQ_CFG_1 is not in range 0 .. 255." severity error;
    end if;
    if ((RX_IDLE_HI_CNT_0 < "0000") or (RX_IDLE_HI_CNT_0 > "1111")) then
      assert FALSE report "Error : RX_IDLE_HI_CNT_0 is not in range 0 .. 15." severity error;
    end if;
    if ((RX_IDLE_HI_CNT_1 < "0000") or (RX_IDLE_HI_CNT_1 > "1111")) then
      assert FALSE report "Error : RX_IDLE_HI_CNT_1 is not in range 0 .. 15." severity error;
    end if;
    if ((RX_IDLE_LO_CNT_0 < "0000") or (RX_IDLE_LO_CNT_0 > "1111")) then
      assert FALSE report "Error : RX_IDLE_LO_CNT_0 is not in range 0 .. 15." severity error;
    end if;
    if ((RX_IDLE_LO_CNT_1 < "0000") or (RX_IDLE_LO_CNT_1 > "1111")) then
      assert FALSE report "Error : RX_IDLE_LO_CNT_1 is not in range 0 .. 15." severity error;
    end if;
      case RX_LOS_INVALID_INCR_0 is
        when  1   =>  RX_LOS_INVALID_INCR_0_BINARY <= "000";
        when  2   =>  RX_LOS_INVALID_INCR_0_BINARY <= "001";
        when  4   =>  RX_LOS_INVALID_INCR_0_BINARY <= "010";
        when  8   =>  RX_LOS_INVALID_INCR_0_BINARY <= "011";
        when  16   =>  RX_LOS_INVALID_INCR_0_BINARY <= "100";
        when  32   =>  RX_LOS_INVALID_INCR_0_BINARY <= "101";
        when  64   =>  RX_LOS_INVALID_INCR_0_BINARY <= "110";
        when  128   =>  RX_LOS_INVALID_INCR_0_BINARY <= "111";
        when others  =>  assert FALSE report "Error : RX_LOS_INVALID_INCR_0 is not 1, 2, 4, 8, 16, 32, 64 or 128." severity error;
      end case;
      case RX_LOS_INVALID_INCR_1 is
        when  1   =>  RX_LOS_INVALID_INCR_1_BINARY <= "000";
        when  2   =>  RX_LOS_INVALID_INCR_1_BINARY <= "001";
        when  4   =>  RX_LOS_INVALID_INCR_1_BINARY <= "010";
        when  8   =>  RX_LOS_INVALID_INCR_1_BINARY <= "011";
        when  16   =>  RX_LOS_INVALID_INCR_1_BINARY <= "100";
        when  32   =>  RX_LOS_INVALID_INCR_1_BINARY <= "101";
        when  64   =>  RX_LOS_INVALID_INCR_1_BINARY <= "110";
        when  128   =>  RX_LOS_INVALID_INCR_1_BINARY <= "111";
        when others  =>  assert FALSE report "Error : RX_LOS_INVALID_INCR_1 is not 1, 2, 4, 8, 16, 32, 64 or 128." severity error;
      end case;
      case RX_LOS_THRESHOLD_0 is
        when  4   =>  RX_LOS_THRESHOLD_0_BINARY <= "000";
        when  8   =>  RX_LOS_THRESHOLD_0_BINARY <= "001";
        when  16   =>  RX_LOS_THRESHOLD_0_BINARY <= "010";
        when  32   =>  RX_LOS_THRESHOLD_0_BINARY <= "011";
        when  64   =>  RX_LOS_THRESHOLD_0_BINARY <= "100";
        when  128   =>  RX_LOS_THRESHOLD_0_BINARY <= "101";
        when  256   =>  RX_LOS_THRESHOLD_0_BINARY <= "110";
        when  512   =>  RX_LOS_THRESHOLD_0_BINARY <= "111";
        when others  =>  assert FALSE report "Error : RX_LOS_THRESHOLD_0 is not 4, 8, 16, 32, 64, 128, 256 or 512." severity error;
      end case;
      case RX_LOS_THRESHOLD_1 is
        when  4   =>  RX_LOS_THRESHOLD_1_BINARY <= "000";
        when  8   =>  RX_LOS_THRESHOLD_1_BINARY <= "001";
        when  16   =>  RX_LOS_THRESHOLD_1_BINARY <= "010";
        when  32   =>  RX_LOS_THRESHOLD_1_BINARY <= "011";
        when  64   =>  RX_LOS_THRESHOLD_1_BINARY <= "100";
        when  128   =>  RX_LOS_THRESHOLD_1_BINARY <= "101";
        when  256   =>  RX_LOS_THRESHOLD_1_BINARY <= "110";
        when  512   =>  RX_LOS_THRESHOLD_1_BINARY <= "111";
        when others  =>  assert FALSE report "Error : RX_LOS_THRESHOLD_1 is not 4, 8, 16, 32, 64, 128, 256 or 512." severity error;
        end case;
    if ((SATA_BURST_VAL_0 < "000") or (SATA_BURST_VAL_0 > "111")) then
      assert FALSE report "Error : SATA_BURST_VAL_0 is not in range 0 .. 7." severity error;
    end if;
    if ((SATA_BURST_VAL_1 < "000") or (SATA_BURST_VAL_1 > "111")) then
      assert FALSE report "Error : SATA_BURST_VAL_1 is not in range 0 .. 7." severity error;
    end if;
    if ((SATA_IDLE_VAL_0 < "000") or (SATA_IDLE_VAL_0 > "111")) then
      assert FALSE report "Error : SATA_IDLE_VAL_0 is not in range 0 .. 7." severity error;
    end if;
    if ((SATA_IDLE_VAL_1 < "000") or (SATA_IDLE_VAL_1 > "111")) then
      assert FALSE report "Error : SATA_IDLE_VAL_1 is not in range 0 .. 7." severity error;
    end if;
      if ((SATA_MAX_BURST_0 >= 1) and (SATA_MAX_BURST_0 <= 61)) then
        SATA_MAX_BURST_0_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_BURST_0, 6);
      else
        assert FALSE report "Error : SATA_MAX_BURST_0 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MAX_BURST_1 >= 1) and (SATA_MAX_BURST_1 <= 61)) then
        SATA_MAX_BURST_1_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_BURST_1, 6);
      else
        assert FALSE report "Error : SATA_MAX_BURST_1 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MAX_INIT_0 >= 1) and (SATA_MAX_INIT_0 <= 61)) then
        SATA_MAX_INIT_0_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_INIT_0, 6);
      else
        assert FALSE report "Error : SATA_MAX_INIT_0 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MAX_INIT_1 >= 1) and (SATA_MAX_INIT_1 <= 61)) then
        SATA_MAX_INIT_1_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_INIT_1, 6);
      else
        assert FALSE report "Error : SATA_MAX_INIT_1 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MAX_WAKE_0 >= 1) and (SATA_MAX_WAKE_0 <= 61)) then
        SATA_MAX_WAKE_0_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_WAKE_0, 6);
      else
        assert FALSE report "Error : SATA_MAX_WAKE_0 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MAX_WAKE_1 >= 1) and (SATA_MAX_WAKE_1 <= 61)) then
        SATA_MAX_WAKE_1_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_WAKE_1, 6);
      else
        assert FALSE report "Error : SATA_MAX_WAKE_1 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MIN_BURST_0 >= 1) and (SATA_MIN_BURST_0 <= 61)) then
        SATA_MIN_BURST_0_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_BURST_0, 6);
      else
        assert FALSE report "Error : SATA_MIN_BURST_0 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MIN_BURST_1 >= 1) and (SATA_MIN_BURST_1 <= 61)) then
        SATA_MIN_BURST_1_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_BURST_1, 6);
      else
        assert FALSE report "Error : SATA_MIN_BURST_1 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MIN_INIT_0 >= 1) and (SATA_MIN_INIT_0 <= 61)) then
        SATA_MIN_INIT_0_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_INIT_0, 6);
      else
        assert FALSE report "Error : SATA_MIN_INIT_0 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MIN_INIT_1 >= 1) and (SATA_MIN_INIT_1 <= 61)) then
        SATA_MIN_INIT_1_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_INIT_1, 6);
      else
        assert FALSE report "Error : SATA_MIN_INIT_1 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MIN_WAKE_0 >= 1) and (SATA_MIN_WAKE_0 <= 61)) then
        SATA_MIN_WAKE_0_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_WAKE_0, 6);
      else
        assert FALSE report "Error : SATA_MIN_WAKE_0 is not in range 1 .. 61." severity error;
      end if;
      if ((SATA_MIN_WAKE_1 >= 1) and (SATA_MIN_WAKE_1 <= 61)) then
        SATA_MIN_WAKE_1_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_WAKE_1, 6);
      else
        assert FALSE report "Error : SATA_MIN_WAKE_1 is not in range 1 .. 61." severity error;
      end if;
    if ((SIM_REFCLK0_SOURCE < "000") or (SIM_REFCLK0_SOURCE > "111")) then
      assert FALSE report "Error : SIM_REFCLK0_SOURCE is not in range 0 .. 7." severity error;
    end if;
    if ((SIM_REFCLK1_SOURCE < "000") or (SIM_REFCLK1_SOURCE > "111")) then
      assert FALSE report "Error : SIM_REFCLK1_SOURCE is not in range 0 .. 7." severity error;
    end if;
    if ((TERMINATION_CTRL_0 < "00000") or (TERMINATION_CTRL_0 > "11111")) then
      assert FALSE report "Error : TERMINATION_CTRL_0 is not in range 0 .. 31." severity error;
    end if;
    if ((TERMINATION_CTRL_1 < "00000") or (TERMINATION_CTRL_1 > "11111")) then
      assert FALSE report "Error : TERMINATION_CTRL_1 is not in range 0 .. 31." severity error;
    end if;
    if ((TXRX_INVERT_0 < "000") or (TXRX_INVERT_0 > "111")) then
      assert FALSE report "Error : TXRX_INVERT_0 is not in range 0 .. 7." severity error;
    end if;
    if ((TXRX_INVERT_1 < "000") or (TXRX_INVERT_1 > "111")) then
      assert FALSE report "Error : TXRX_INVERT_1 is not in range 0 .. 7." severity error;
    end if;
    if ((TX_IDLE_DELAY_0 < "000") or (TX_IDLE_DELAY_0 > "111")) then
      assert FALSE report "Error : TX_IDLE_DELAY_0 is not in range 0 .. 7." severity error;
    end if;
    if ((TX_IDLE_DELAY_1 < "000") or (TX_IDLE_DELAY_1 > "111")) then
      assert FALSE report "Error : TX_IDLE_DELAY_1 is not in range 0 .. 7." severity error;
    end if;
    if ((TX_TDCC_CFG_0 < "00") or (TX_TDCC_CFG_0 > "11")) then
      assert FALSE report "Error : TX_TDCC_CFG_0 is not in range 0 .. 3." severity error;
    end if;
    if ((TX_TDCC_CFG_1 < "00") or (TX_TDCC_CFG_1 > "11")) then
      assert FALSE report "Error : TX_TDCC_CFG_1 is not in range 0 .. 3." severity error;
    end if;
      wait;
      end process INIPROC;
      
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
    
    DRDY <= DRDY_out;
    DRPDO <= DRPDO_out;
    GTPCLKFBEAST <= GTPCLKFBEAST_out;
    GTPCLKFBWEST <= GTPCLKFBWEST_out;
    GTPCLKOUT0 <= GTPCLKOUT0_out;
    GTPCLKOUT1 <= GTPCLKOUT1_out;
    PHYSTATUS0 <= PHYSTATUS0_out;
    PHYSTATUS1 <= PHYSTATUS1_out;
    PLLLKDET0 <= PLLLKDET0_out;
    PLLLKDET1 <= PLLLKDET1_out;
    RCALOUTEAST <= RCALOUTEAST_out;
    RCALOUTWEST <= RCALOUTWEST_out;
    REFCLKOUT0 <= REFCLKOUT0_out;
    REFCLKOUT1 <= REFCLKOUT1_out;
    REFCLKPLL0 <= REFCLKPLL0_out;
    REFCLKPLL1 <= REFCLKPLL1_out;
    RESETDONE0 <= RESETDONE0_out;
    RESETDONE1 <= RESETDONE1_out;
    RXBUFSTATUS0 <= RXBUFSTATUS0_out;
    RXBUFSTATUS1 <= RXBUFSTATUS1_out;
    RXBYTEISALIGNED0 <= RXBYTEISALIGNED0_out;
    RXBYTEISALIGNED1 <= RXBYTEISALIGNED1_out;
    RXBYTEREALIGN0 <= RXBYTEREALIGN0_out;
    RXBYTEREALIGN1 <= RXBYTEREALIGN1_out;
    RXCHANBONDSEQ0 <= RXCHANBONDSEQ0_out;
    RXCHANBONDSEQ1 <= RXCHANBONDSEQ1_out;
    RXCHANISALIGNED0 <= RXCHANISALIGNED0_out;
    RXCHANISALIGNED1 <= RXCHANISALIGNED1_out;
    RXCHANREALIGN0 <= RXCHANREALIGN0_out;
    RXCHANREALIGN1 <= RXCHANREALIGN1_out;
    RXCHARISCOMMA0 <= RXCHARISCOMMA0_out;
    RXCHARISCOMMA1 <= RXCHARISCOMMA1_out;
    RXCHARISK0 <= RXCHARISK0_out;
    RXCHARISK1 <= RXCHARISK1_out;
    RXCHBONDO <= RXCHBONDO_out;
    RXCLKCORCNT0 <= RXCLKCORCNT0_out;
    RXCLKCORCNT1 <= RXCLKCORCNT1_out;
    RXCOMMADET0 <= RXCOMMADET0_out;
    RXCOMMADET1 <= RXCOMMADET1_out;
    RXDATA0 <= RXDATA0_out;
    RXDATA1 <= RXDATA1_out;
    RXDISPERR0 <= RXDISPERR0_out;
    RXDISPERR1 <= RXDISPERR1_out;
    RXELECIDLE0 <= RXELECIDLE0_out;
    RXELECIDLE1 <= RXELECIDLE1_out;
    RXLOSSOFSYNC0 <= RXLOSSOFSYNC0_out;
    RXLOSSOFSYNC1 <= RXLOSSOFSYNC1_out;
    RXNOTINTABLE0 <= RXNOTINTABLE0_out;
    RXNOTINTABLE1 <= RXNOTINTABLE1_out;
    RXPRBSERR0 <= RXPRBSERR0_out;
    RXPRBSERR1 <= RXPRBSERR1_out;
    RXRECCLK0 <= RXRECCLK0_out;
    RXRECCLK1 <= RXRECCLK1_out;
    RXRUNDISP0 <= RXRUNDISP0_out;
    RXRUNDISP1 <= RXRUNDISP1_out;
    RXSTATUS0 <= RXSTATUS0_out;
    RXSTATUS1 <= RXSTATUS1_out;
    RXVALID0 <= RXVALID0_out;
    RXVALID1 <= RXVALID1_out;
    TSTOUT0 <= TSTOUT0_out;
    TSTOUT1 <= TSTOUT1_out;
    TXBUFSTATUS0 <= TXBUFSTATUS0_out;
    TXBUFSTATUS1 <= TXBUFSTATUS1_out;
    TXKERR0 <= TXKERR0_out;
    TXKERR1 <= TXKERR1_out;
    TXN0 <= TXN0_out;
    TXN1 <= TXN1_out;
    TXOUTCLK0 <= TXOUTCLK0_out;
    TXOUTCLK1 <= TXOUTCLK1_out;
    TXP0 <= TXP0_out;
    TXP1 <= TXP1_out;
    TXRUNDISP0 <= TXRUNDISP0_out;
    TXRUNDISP1 <= TXRUNDISP1_out;
  end GTPA1_DUAL_V;
