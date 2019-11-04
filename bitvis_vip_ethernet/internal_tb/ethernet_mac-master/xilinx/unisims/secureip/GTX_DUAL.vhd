-------------------------------------------------------
--  Copyright (c) 1995/2006 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : GTX_DUAL.vhd
-- \   \  /  \     Timestamp   : Tue Jan  9 10:05:31 2007
--  \__ \/\__ \                   
--                                 
--  09/12/06 - CR#423671 - Initial version.
--  12/05/06 - CR#426138 - J.31 spreadsheet update
--  01/23/07 - CR#430426 - J.32 pinTime added
--  02/20/07 - CR#434096 - Parameter default value update PLL_RXDIVSEL_OUT_0/1
--  06/18/07 - CR#441601 - BT1445 - Test attributes made visible 
--  06/18/07 - CR#441576 - BT1488 - Add STEPPING attribute
--  10/05/07 - CR#451343 - BT1514 - Add ES1 (ES1 mapped to 0) as STEPPING value
--  11/05/07 - CR#452590 - BT1514 - Remove STEPPING attribute from unisim/simprim wrapper
--  02/05/08 - CR#459742 - Attribute default changes
--  03/14/08 - CR#468285 - Updated timing checks
--  03/17/08 - CR#467692 - Add SIM_MODE attribute with values LEGACY & FAST model
--  04/24/08 - CR#472011 - OOBDETECT_THRESHOLD_0/1 default from 001 to 110, range changes from 000-111 to 110-111
--  05/13/08 - CR#472931 - OOBDETECT_THRESHOLD_0/1 case statement updates
--  05/19/08 - CR#472395 - Remove LEGACY model
--  05/27/08 - CR#472395 - Set SIM_MODE to FAST, Add DRC checks
-------------------------------------------------------

----- CELL GTX_DUAL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;


library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity GTX_DUAL is
generic (
  	AC_CAP_DIS_0 : boolean := TRUE;
        AC_CAP_DIS_1 : boolean := TRUE;
	ALIGN_COMMA_WORD_0 : integer := 1;
	ALIGN_COMMA_WORD_1 : integer := 1;
	CB2_INH_CC_PERIOD_0 : integer := 8;
	CB2_INH_CC_PERIOD_1 : integer := 8;
	CDR_PH_ADJ_TIME : bit_vector := "01010";
	CHAN_BOND_1_MAX_SKEW_0 : integer := 7;
	CHAN_BOND_1_MAX_SKEW_1 : integer := 7;
	CHAN_BOND_2_MAX_SKEW_0 : integer := 7;
	CHAN_BOND_2_MAX_SKEW_1 : integer := 7;
	CHAN_BOND_KEEP_ALIGN_0 : boolean := FALSE;
	CHAN_BOND_KEEP_ALIGN_1 : boolean := FALSE;
	CHAN_BOND_LEVEL_0 : integer := 0;
	CHAN_BOND_LEVEL_1 : integer := 0;
	CHAN_BOND_MODE_0 : string := "OFF";
	CHAN_BOND_MODE_1 : string := "OFF";
	CHAN_BOND_SEQ_1_1_0 : bit_vector := "0101111100";
	CHAN_BOND_SEQ_1_1_1 : bit_vector := "0101111100";
	CHAN_BOND_SEQ_1_2_0 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_1_2_1 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_1_3_0 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_1_3_1 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_1_4_0 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_1_4_1 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_1_ENABLE_0 : bit_vector := "0001";
	CHAN_BOND_SEQ_1_ENABLE_1 : bit_vector := "0001";
	CHAN_BOND_SEQ_2_1_0 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_1_1 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_2_0 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_2_1 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_3_0 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_3_1 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_4_0 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_4_1 : bit_vector := "0000000000";
	CHAN_BOND_SEQ_2_ENABLE_0 : bit_vector := "0000";
	CHAN_BOND_SEQ_2_ENABLE_1 : bit_vector := "0000";
	CHAN_BOND_SEQ_2_USE_0 : boolean := FALSE;
	CHAN_BOND_SEQ_2_USE_1 : boolean := FALSE;
	CHAN_BOND_SEQ_LEN_0 : integer := 1;
	CHAN_BOND_SEQ_LEN_1 : integer := 1;
	CLK25_DIVIDER : integer := 10;
	CLKINDC_B : boolean := TRUE;
	CLKRCV_TRST : boolean := TRUE;
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
	CLK_COR_SEQ_1_ENABLE_0 : bit_vector := "0001";
	CLK_COR_SEQ_1_ENABLE_1 : bit_vector := "0001";
	CLK_COR_SEQ_2_1_0 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_1_1 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_2_0 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_2_1 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_3_0 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_3_1 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_4_0 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_4_1 : bit_vector := "0000000000";
	CLK_COR_SEQ_2_ENABLE_0 : bit_vector := "0000";
	CLK_COR_SEQ_2_ENABLE_1 : bit_vector := "0000";
	CLK_COR_SEQ_2_USE_0 : boolean := FALSE;
	CLK_COR_SEQ_2_USE_1 : boolean := FALSE;
	CM_TRIM_0 : bit_vector := "10";
	CM_TRIM_1 : bit_vector := "10";
	COMMA_10B_ENABLE_0 : bit_vector := "0001111111";
	COMMA_10B_ENABLE_1 : bit_vector := "0001111111";
	COMMA_DOUBLE_0 : boolean := FALSE;
	COMMA_DOUBLE_1 : boolean := FALSE;
	COM_BURST_VAL_0 : bit_vector := "1111";
	COM_BURST_VAL_1 : bit_vector := "1111";
	DEC_MCOMMA_DETECT_0 : boolean := TRUE;
	DEC_MCOMMA_DETECT_1 : boolean := TRUE;
	DEC_PCOMMA_DETECT_0 : boolean := TRUE;
	DEC_PCOMMA_DETECT_1 : boolean := TRUE;
	DEC_VALID_COMMA_ONLY_0 : boolean := TRUE;
	DEC_VALID_COMMA_ONLY_1 : boolean := TRUE;
	DFE_CAL_TIME : bit_vector := "00110";
	DFE_CFG_0 : bit_vector := "1101111011";
	DFE_CFG_1 : bit_vector := "1101111011";
	GEARBOX_ENDEC_0 : bit_vector := "000";
	GEARBOX_ENDEC_1 : bit_vector := "000";
	MCOMMA_10B_VALUE_0 : bit_vector := "1010000011";
	MCOMMA_10B_VALUE_1 : bit_vector := "1010000011";
	MCOMMA_DETECT_0 : boolean := TRUE;
	MCOMMA_DETECT_1 : boolean := TRUE;
	OOBDETECT_THRESHOLD_0 : bit_vector := "110";
	OOBDETECT_THRESHOLD_1 : bit_vector := "110";
	OOB_CLK_DIVIDER : integer := 6;
	OVERSAMPLE_MODE : boolean := FALSE;
	PCI_EXPRESS_MODE_0 : boolean := FALSE;
	PCI_EXPRESS_MODE_1 : boolean := FALSE;
	PCOMMA_10B_VALUE_0 : bit_vector := "0101111100";
	PCOMMA_10B_VALUE_1 : bit_vector := "0101111100";
	PCOMMA_DETECT_0 : boolean := TRUE;
	PCOMMA_DETECT_1 : boolean := TRUE;
	PLL_COM_CFG : bit_vector := X"21680a";
	PLL_CP_CFG : bit_vector := X"00";
	PLL_DIVSEL_FB : integer := 2;
	PLL_DIVSEL_REF : integer := 1;
	PLL_FB_DCCEN : boolean := FALSE;
	PLL_LKDET_CFG : bit_vector := "101";
	PLL_RXDIVSEL_OUT_0 : integer := 1;
	PLL_RXDIVSEL_OUT_1 : integer := 1;
	PLL_SATA_0 : boolean := FALSE;
	PLL_SATA_1 : boolean := FALSE;
	PLL_TDCC_CFG : bit_vector := "000";
	PLL_TXDIVSEL_OUT_0 : integer := 1;
	PLL_TXDIVSEL_OUT_1 : integer := 1;
	PMA_CDR_SCAN_0 : bit_vector := X"6404035";
	PMA_CDR_SCAN_1 : bit_vector := X"6404035";
	PMA_COM_CFG : bit_vector := X"000000000000000000";
	PMA_RXSYNC_CFG_0 : bit_vector := X"00";
	PMA_RXSYNC_CFG_1 : bit_vector := X"00";
	PMA_RX_CFG_0 : bit_vector := X"0f44089";
	PMA_RX_CFG_1 : bit_vector := X"0f44089";
	PMA_TX_CFG_0 : bit_vector := X"80082";
	PMA_TX_CFG_1 : bit_vector := X"80082";
	PRBS_ERR_THRESHOLD_0 : bit_vector := X"00000001";
	PRBS_ERR_THRESHOLD_1 : bit_vector := X"00000001";
	RCV_TERM_GND_0 : boolean := FALSE;
	RCV_TERM_GND_1 : boolean := FALSE;
	RCV_TERM_VTTRX_0 : boolean := FALSE;
	RCV_TERM_VTTRX_1 : boolean := FALSE;
	RXGEARBOX_USE_0 : boolean := FALSE;
	RXGEARBOX_USE_1 : boolean := FALSE;
	RX_BUFFER_USE_0 : boolean := TRUE;
	RX_BUFFER_USE_1 : boolean := TRUE;
	RX_DECODE_SEQ_MATCH_0 : boolean := TRUE;
	RX_DECODE_SEQ_MATCH_1 : boolean := TRUE;
	RX_EN_IDLE_HOLD_CDR : boolean := FALSE;
	RX_EN_IDLE_HOLD_DFE_0 : boolean := TRUE;
	RX_EN_IDLE_HOLD_DFE_1 : boolean := TRUE;
	RX_EN_IDLE_RESET_BUF_0 : boolean := TRUE;
	RX_EN_IDLE_RESET_BUF_1 : boolean := TRUE;
	RX_EN_IDLE_RESET_FR : boolean := TRUE;
	RX_EN_IDLE_RESET_PH : boolean := TRUE;
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
	SATA_IDLE_VAL_0 : bit_vector := "100";
	SATA_IDLE_VAL_1 : bit_vector := "100";
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
	SIM_GTXRESET_SPEEDUP : integer := 1;
        SIM_MODE : string := "FAST";
	SIM_PLL_PERDIV2 : bit_vector := X"140";
	SIM_RECEIVER_DETECT_PASS_0 : boolean := TRUE;
	SIM_RECEIVER_DETECT_PASS_1 : boolean := TRUE;
	TERMINATION_CTRL : bit_vector := "10100";
	TERMINATION_IMP_0 : integer := 50;
	TERMINATION_IMP_1 : integer := 50;
	TERMINATION_OVRD : boolean := FALSE;
	TRANS_TIME_FROM_P2_0 : bit_vector := X"03c";
	TRANS_TIME_FROM_P2_1 : bit_vector := X"03c";
	TRANS_TIME_NON_P2_0 : bit_vector := X"19";
	TRANS_TIME_NON_P2_1 : bit_vector := X"19";
	TRANS_TIME_TO_P2_0 : bit_vector := X"064";
	TRANS_TIME_TO_P2_1 : bit_vector := X"064";
	TXGEARBOX_USE_0 : boolean := FALSE;
	TXGEARBOX_USE_1 : boolean := FALSE;
	TXRX_INVERT_0 : bit_vector := "011";
	TXRX_INVERT_1 : bit_vector := "011";
	TX_BUFFER_USE_0 : boolean := TRUE;
	TX_BUFFER_USE_1 : boolean := TRUE;
	TX_DETECT_RX_CFG_0 : bit_vector := X"1832";
	TX_DETECT_RX_CFG_1 : bit_vector := X"1832";
	TX_IDLE_DELAY_0 : bit_vector := "010";
	TX_IDLE_DELAY_1 : bit_vector := "010";
	TX_XCLK_SEL_0 : string := "TXOUT";
	TX_XCLK_SEL_1 : string := "TXOUT"



  );

port (
		DFECLKDLYADJMONITOR0 : out std_logic_vector(5 downto 0);
		DFECLKDLYADJMONITOR1 : out std_logic_vector(5 downto 0);
		DFEEYEDACMONITOR0 : out std_logic_vector(4 downto 0);
		DFEEYEDACMONITOR1 : out std_logic_vector(4 downto 0);
		DFESENSCAL0 : out std_logic_vector(2 downto 0);
		DFESENSCAL1 : out std_logic_vector(2 downto 0);
		DFETAP1MONITOR0 : out std_logic_vector(4 downto 0);
		DFETAP1MONITOR1 : out std_logic_vector(4 downto 0);
		DFETAP2MONITOR0 : out std_logic_vector(4 downto 0);
		DFETAP2MONITOR1 : out std_logic_vector(4 downto 0);
		DFETAP3MONITOR0 : out std_logic_vector(3 downto 0);
		DFETAP3MONITOR1 : out std_logic_vector(3 downto 0);
		DFETAP4MONITOR0 : out std_logic_vector(3 downto 0);
		DFETAP4MONITOR1 : out std_logic_vector(3 downto 0);
		DO : out std_logic_vector(15 downto 0);
		DRDY : out std_ulogic;
		PHYSTATUS0 : out std_ulogic;
		PHYSTATUS1 : out std_ulogic;
		PLLLKDET : out std_ulogic;
		REFCLKOUT : out std_ulogic;
		RESETDONE0 : out std_ulogic;
		RESETDONE1 : out std_ulogic;
		RXBUFSTATUS0 : out std_logic_vector(2 downto 0);
		RXBUFSTATUS1 : out std_logic_vector(2 downto 0);
		RXBYTEISALIGNED0 : out std_ulogic;
		RXBYTEISALIGNED1 : out std_ulogic;
		RXBYTEREALIGN0 : out std_ulogic;
		RXBYTEREALIGN1 : out std_ulogic;
		RXCHANBONDSEQ0 : out std_ulogic;
		RXCHANBONDSEQ1 : out std_ulogic;
		RXCHANISALIGNED0 : out std_ulogic;
		RXCHANISALIGNED1 : out std_ulogic;
		RXCHANREALIGN0 : out std_ulogic;
		RXCHANREALIGN1 : out std_ulogic;
		RXCHARISCOMMA0 : out std_logic_vector(3 downto 0);
		RXCHARISCOMMA1 : out std_logic_vector(3 downto 0);
		RXCHARISK0 : out std_logic_vector(3 downto 0);
		RXCHARISK1 : out std_logic_vector(3 downto 0);
		RXCHBONDO0 : out std_logic_vector(3 downto 0);
		RXCHBONDO1 : out std_logic_vector(3 downto 0);
		RXCLKCORCNT0 : out std_logic_vector(2 downto 0);
		RXCLKCORCNT1 : out std_logic_vector(2 downto 0);
		RXCOMMADET0 : out std_ulogic;
		RXCOMMADET1 : out std_ulogic;
		RXDATA0 : out std_logic_vector(31 downto 0);
		RXDATA1 : out std_logic_vector(31 downto 0);
		RXDATAVALID0 : out std_ulogic;
		RXDATAVALID1 : out std_ulogic;
		RXDISPERR0 : out std_logic_vector(3 downto 0);
		RXDISPERR1 : out std_logic_vector(3 downto 0);
		RXELECIDLE0 : out std_ulogic;
		RXELECIDLE1 : out std_ulogic;
		RXHEADER0 : out std_logic_vector(2 downto 0);
		RXHEADER1 : out std_logic_vector(2 downto 0);
		RXHEADERVALID0 : out std_ulogic;
		RXHEADERVALID1 : out std_ulogic;
		RXLOSSOFSYNC0 : out std_logic_vector(1 downto 0);
		RXLOSSOFSYNC1 : out std_logic_vector(1 downto 0);
		RXNOTINTABLE0 : out std_logic_vector(3 downto 0);
		RXNOTINTABLE1 : out std_logic_vector(3 downto 0);
		RXOVERSAMPLEERR0 : out std_ulogic;
		RXOVERSAMPLEERR1 : out std_ulogic;
		RXPRBSERR0 : out std_ulogic;
		RXPRBSERR1 : out std_ulogic;
		RXRECCLK0 : out std_ulogic;
		RXRECCLK1 : out std_ulogic;
		RXRUNDISP0 : out std_logic_vector(3 downto 0);
		RXRUNDISP1 : out std_logic_vector(3 downto 0);
		RXSTARTOFSEQ0 : out std_ulogic;
		RXSTARTOFSEQ1 : out std_ulogic;
		RXSTATUS0 : out std_logic_vector(2 downto 0);
		RXSTATUS1 : out std_logic_vector(2 downto 0);
		RXVALID0 : out std_ulogic;
		RXVALID1 : out std_ulogic;
		TXBUFSTATUS0 : out std_logic_vector(1 downto 0);
		TXBUFSTATUS1 : out std_logic_vector(1 downto 0);
		TXGEARBOXREADY0 : out std_ulogic;
		TXGEARBOXREADY1 : out std_ulogic;
		TXKERR0 : out std_logic_vector(3 downto 0);
		TXKERR1 : out std_logic_vector(3 downto 0);
		TXN0 : out std_ulogic;
		TXN1 : out std_ulogic;
		TXOUTCLK0 : out std_ulogic;
		TXOUTCLK1 : out std_ulogic;
		TXP0 : out std_ulogic;
		TXP1 : out std_ulogic;
		TXRUNDISP0 : out std_logic_vector(3 downto 0);
		TXRUNDISP1 : out std_logic_vector(3 downto 0);

		CLKIN : in std_ulogic;
		DADDR : in std_logic_vector(6 downto 0);
		DCLK : in std_ulogic;
		DEN : in std_ulogic;
		DFECLKDLYADJ0 : in std_logic_vector(5 downto 0);
		DFECLKDLYADJ1 : in std_logic_vector(5 downto 0);
		DFETAP10 : in std_logic_vector(4 downto 0);
		DFETAP11 : in std_logic_vector(4 downto 0);
		DFETAP20 : in std_logic_vector(4 downto 0);
		DFETAP21 : in std_logic_vector(4 downto 0);
		DFETAP30 : in std_logic_vector(3 downto 0);
		DFETAP31 : in std_logic_vector(3 downto 0);
		DFETAP40 : in std_logic_vector(3 downto 0);
		DFETAP41 : in std_logic_vector(3 downto 0);
		DI : in std_logic_vector(15 downto 0);
		DWE : in std_ulogic;
		GTXRESET : in std_ulogic;
		GTXTEST : in std_logic_vector(13 downto 0);
		INTDATAWIDTH : in std_ulogic;
		LOOPBACK0 : in std_logic_vector(2 downto 0);
		LOOPBACK1 : in std_logic_vector(2 downto 0);
		PLLLKDETEN : in std_ulogic;
		PLLPOWERDOWN : in std_ulogic;
		PRBSCNTRESET0 : in std_ulogic;
		PRBSCNTRESET1 : in std_ulogic;
		REFCLKPWRDNB : in std_ulogic;
		RXBUFRESET0 : in std_ulogic;
		RXBUFRESET1 : in std_ulogic;
		RXCDRRESET0 : in std_ulogic;
		RXCDRRESET1 : in std_ulogic;
		RXCHBONDI0 : in std_logic_vector(3 downto 0);
		RXCHBONDI1 : in std_logic_vector(3 downto 0);
		RXCOMMADETUSE0 : in std_ulogic;
		RXCOMMADETUSE1 : in std_ulogic;
		RXDATAWIDTH0 : in std_logic_vector(1 downto 0);
		RXDATAWIDTH1 : in std_logic_vector(1 downto 0);
		RXDEC8B10BUSE0 : in std_ulogic;
		RXDEC8B10BUSE1 : in std_ulogic;
		RXENCHANSYNC0 : in std_ulogic;
		RXENCHANSYNC1 : in std_ulogic;
		RXENEQB0 : in std_ulogic;
		RXENEQB1 : in std_ulogic;
		RXENMCOMMAALIGN0 : in std_ulogic;
		RXENMCOMMAALIGN1 : in std_ulogic;
		RXENPCOMMAALIGN0 : in std_ulogic;
		RXENPCOMMAALIGN1 : in std_ulogic;
		RXENPMAPHASEALIGN0 : in std_ulogic;
		RXENPMAPHASEALIGN1 : in std_ulogic;
		RXENPRBSTST0 : in std_logic_vector(1 downto 0);
		RXENPRBSTST1 : in std_logic_vector(1 downto 0);
		RXENSAMPLEALIGN0 : in std_ulogic;
		RXENSAMPLEALIGN1 : in std_ulogic;
		RXEQMIX0 : in std_logic_vector(1 downto 0);
		RXEQMIX1 : in std_logic_vector(1 downto 0);
		RXEQPOLE0 : in std_logic_vector(3 downto 0);
		RXEQPOLE1 : in std_logic_vector(3 downto 0);
		RXGEARBOXSLIP0 : in std_ulogic;
		RXGEARBOXSLIP1 : in std_ulogic;
		RXN0 : in std_ulogic;
		RXN1 : in std_ulogic;
		RXP0 : in std_ulogic;
		RXP1 : in std_ulogic;
		RXPMASETPHASE0 : in std_ulogic;
		RXPMASETPHASE1 : in std_ulogic;
		RXPOLARITY0 : in std_ulogic;
		RXPOLARITY1 : in std_ulogic;
		RXPOWERDOWN0 : in std_logic_vector(1 downto 0);
		RXPOWERDOWN1 : in std_logic_vector(1 downto 0);
		RXRESET0 : in std_ulogic;
		RXRESET1 : in std_ulogic;
		RXSLIDE0 : in std_ulogic;
		RXSLIDE1 : in std_ulogic;
		RXUSRCLK0 : in std_ulogic;
		RXUSRCLK1 : in std_ulogic;
		RXUSRCLK20 : in std_ulogic;
		RXUSRCLK21 : in std_ulogic;
		TXBUFDIFFCTRL0 : in std_logic_vector(2 downto 0);
		TXBUFDIFFCTRL1 : in std_logic_vector(2 downto 0);
		TXBYPASS8B10B0 : in std_logic_vector(3 downto 0);
		TXBYPASS8B10B1 : in std_logic_vector(3 downto 0);
		TXCHARDISPMODE0 : in std_logic_vector(3 downto 0);
		TXCHARDISPMODE1 : in std_logic_vector(3 downto 0);
		TXCHARDISPVAL0 : in std_logic_vector(3 downto 0);
		TXCHARDISPVAL1 : in std_logic_vector(3 downto 0);
		TXCHARISK0 : in std_logic_vector(3 downto 0);
		TXCHARISK1 : in std_logic_vector(3 downto 0);
		TXCOMSTART0 : in std_ulogic;
		TXCOMSTART1 : in std_ulogic;
		TXCOMTYPE0 : in std_ulogic;
		TXCOMTYPE1 : in std_ulogic;
		TXDATA0 : in std_logic_vector(31 downto 0);
		TXDATA1 : in std_logic_vector(31 downto 0);
		TXDATAWIDTH0 : in std_logic_vector(1 downto 0);
		TXDATAWIDTH1 : in std_logic_vector(1 downto 0);
		TXDETECTRX0 : in std_ulogic;
		TXDETECTRX1 : in std_ulogic;
		TXDIFFCTRL0 : in std_logic_vector(2 downto 0);
		TXDIFFCTRL1 : in std_logic_vector(2 downto 0);
		TXELECIDLE0 : in std_ulogic;
		TXELECIDLE1 : in std_ulogic;
		TXENC8B10BUSE0 : in std_ulogic;
		TXENC8B10BUSE1 : in std_ulogic;
		TXENPMAPHASEALIGN0 : in std_ulogic;
		TXENPMAPHASEALIGN1 : in std_ulogic;
		TXENPRBSTST0 : in std_logic_vector(1 downto 0);
		TXENPRBSTST1 : in std_logic_vector(1 downto 0);
		TXHEADER0 : in std_logic_vector(2 downto 0);
		TXHEADER1 : in std_logic_vector(2 downto 0);
		TXINHIBIT0 : in std_ulogic;
		TXINHIBIT1 : in std_ulogic;
		TXPMASETPHASE0 : in std_ulogic;
		TXPMASETPHASE1 : in std_ulogic;
		TXPOLARITY0 : in std_ulogic;
		TXPOLARITY1 : in std_ulogic;
		TXPOWERDOWN0 : in std_logic_vector(1 downto 0);
		TXPOWERDOWN1 : in std_logic_vector(1 downto 0);
		TXPREEMPHASIS0 : in std_logic_vector(3 downto 0);
		TXPREEMPHASIS1 : in std_logic_vector(3 downto 0);
		TXRESET0 : in std_ulogic;
		TXRESET1 : in std_ulogic;
		TXSEQUENCE0 : in std_logic_vector(6 downto 0);
		TXSEQUENCE1 : in std_logic_vector(6 downto 0);
		TXSTARTSEQ0 : in std_ulogic;
		TXSTARTSEQ1 : in std_ulogic;
		TXUSRCLK0 : in std_ulogic;
		TXUSRCLK1 : in std_ulogic;
		TXUSRCLK20 : in std_ulogic;
		TXUSRCLK21 : in std_ulogic
     );
end GTX_DUAL;

architecture GTX_DUAL_V of GTX_DUAL is

  component GTX_DUAL_FAST
    port (
      DFECLKDLYADJMONITOR0 : out std_logic_vector(5 downto 0);
      DFECLKDLYADJMONITOR1 : out std_logic_vector(5 downto 0);
      DFEEYEDACMONITOR0    : out std_logic_vector(4 downto 0);
      DFEEYEDACMONITOR1    : out std_logic_vector(4 downto 0);
      DFESENSCAL0          : out std_logic_vector(2 downto 0);
      DFESENSCAL1          : out std_logic_vector(2 downto 0);
      DFETAP1MONITOR0      : out std_logic_vector(4 downto 0);
      DFETAP1MONITOR1      : out std_logic_vector(4 downto 0);
      DFETAP2MONITOR0      : out std_logic_vector(4 downto 0);
      DFETAP2MONITOR1      : out std_logic_vector(4 downto 0);
      DFETAP3MONITOR0      : out std_logic_vector(3 downto 0);
      DFETAP3MONITOR1      : out std_logic_vector(3 downto 0);
      DFETAP4MONITOR0      : out std_logic_vector(3 downto 0);
      DFETAP4MONITOR1      : out std_logic_vector(3 downto 0);
      DO                   : out std_logic_vector(15 downto 0);
      DRDY                 : out std_ulogic;
      PHYSTATUS0           : out std_ulogic;
      PHYSTATUS1           : out std_ulogic;
      PLLLKDET             : out std_ulogic;
      REFCLKOUT            : out std_ulogic;
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
      RXCHBONDO0           : out std_logic_vector(3 downto 0);
      RXCHBONDO1           : out std_logic_vector(3 downto 0);
      RXCLKCORCNT0         : out std_logic_vector(2 downto 0);
      RXCLKCORCNT1         : out std_logic_vector(2 downto 0);
      RXCOMMADET0          : out std_ulogic;
      RXCOMMADET1          : out std_ulogic;
      RXDATA0              : out std_logic_vector(31 downto 0);
      RXDATA1              : out std_logic_vector(31 downto 0);
      RXDATAVALID0         : out std_ulogic;
      RXDATAVALID1         : out std_ulogic;
      RXDISPERR0           : out std_logic_vector(3 downto 0);
      RXDISPERR1           : out std_logic_vector(3 downto 0);
      RXELECIDLE0          : out std_ulogic;
      RXELECIDLE1          : out std_ulogic;
      RXHEADER0            : out std_logic_vector(2 downto 0);
      RXHEADER1            : out std_logic_vector(2 downto 0);
      RXHEADERVALID0       : out std_ulogic;
      RXHEADERVALID1       : out std_ulogic;
      RXLOSSOFSYNC0        : out std_logic_vector(1 downto 0);
      RXLOSSOFSYNC1        : out std_logic_vector(1 downto 0);
      RXNOTINTABLE0        : out std_logic_vector(3 downto 0);
      RXNOTINTABLE1        : out std_logic_vector(3 downto 0);
      RXOVERSAMPLEERR0     : out std_ulogic;
      RXOVERSAMPLEERR1     : out std_ulogic;
      RXPRBSERR0           : out std_ulogic;
      RXPRBSERR1           : out std_ulogic;
      RXRECCLK0            : out std_ulogic;
      RXRECCLK1            : out std_ulogic;
      RXRUNDISP0           : out std_logic_vector(3 downto 0);
      RXRUNDISP1           : out std_logic_vector(3 downto 0);
      RXSTARTOFSEQ0        : out std_ulogic;
      RXSTARTOFSEQ1        : out std_ulogic;
      RXSTATUS0            : out std_logic_vector(2 downto 0);
      RXSTATUS1            : out std_logic_vector(2 downto 0);
      RXVALID0             : out std_ulogic;
      RXVALID1             : out std_ulogic;
      TXBUFSTATUS0         : out std_logic_vector(1 downto 0);
      TXBUFSTATUS1         : out std_logic_vector(1 downto 0);
      TXGEARBOXREADY0      : out std_ulogic;
      TXGEARBOXREADY1      : out std_ulogic;
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

      CLKIN                : in std_ulogic;
      DADDR                : in std_logic_vector(6 downto 0);
      DCLK                 : in std_ulogic;
      DEN                  : in std_ulogic;
      DFECLKDLYADJ0        : in std_logic_vector(5 downto 0);
      DFECLKDLYADJ1        : in std_logic_vector(5 downto 0);
      DFETAP10             : in std_logic_vector(4 downto 0);
      DFETAP11             : in std_logic_vector(4 downto 0);
      DFETAP20             : in std_logic_vector(4 downto 0);
      DFETAP21             : in std_logic_vector(4 downto 0);
      DFETAP30             : in std_logic_vector(3 downto 0);
      DFETAP31             : in std_logic_vector(3 downto 0);
      DFETAP40             : in std_logic_vector(3 downto 0);
      DFETAP41             : in std_logic_vector(3 downto 0);
      DI                   : in std_logic_vector(15 downto 0);
      DWE                  : in std_ulogic;
      GSR                  : in std_ulogic;
      GTXRESET             : in std_ulogic;
      GTXTEST              : in std_logic_vector(13 downto 0);
      INTDATAWIDTH         : in std_ulogic;
      LOOPBACK0            : in std_logic_vector(2 downto 0);
      LOOPBACK1            : in std_logic_vector(2 downto 0);
      PLLLKDETEN           : in std_ulogic;
      PLLPOWERDOWN         : in std_ulogic;
      PRBSCNTRESET0        : in std_ulogic;
      PRBSCNTRESET1        : in std_ulogic;
      REFCLKPWRDNB         : in std_ulogic;
      RXBUFRESET0          : in std_ulogic;
      RXBUFRESET1          : in std_ulogic;
      RXCDRRESET0          : in std_ulogic;
      RXCDRRESET1          : in std_ulogic;
      RXCHBONDI0           : in std_logic_vector(3 downto 0);
      RXCHBONDI1           : in std_logic_vector(3 downto 0);
      RXCOMMADETUSE0       : in std_ulogic;
      RXCOMMADETUSE1       : in std_ulogic;
      RXDATAWIDTH0         : in std_logic_vector(1 downto 0);
      RXDATAWIDTH1         : in std_logic_vector(1 downto 0);
      RXDEC8B10BUSE0       : in std_ulogic;
      RXDEC8B10BUSE1       : in std_ulogic;
      RXENCHANSYNC0        : in std_ulogic;
      RXENCHANSYNC1        : in std_ulogic;
      RXENEQB0             : in std_ulogic;
      RXENEQB1             : in std_ulogic;
      RXENMCOMMAALIGN0     : in std_ulogic;
      RXENMCOMMAALIGN1     : in std_ulogic;
      RXENPCOMMAALIGN0     : in std_ulogic;
      RXENPCOMMAALIGN1     : in std_ulogic;
      RXENPMAPHASEALIGN0   : in std_ulogic;
      RXENPMAPHASEALIGN1   : in std_ulogic;
      RXENPRBSTST0         : in std_logic_vector(1 downto 0);
      RXENPRBSTST1         : in std_logic_vector(1 downto 0);
      RXENSAMPLEALIGN0     : in std_ulogic;
      RXENSAMPLEALIGN1     : in std_ulogic;
      RXEQMIX0             : in std_logic_vector(1 downto 0);
      RXEQMIX1             : in std_logic_vector(1 downto 0);
      RXEQPOLE0            : in std_logic_vector(3 downto 0);
      RXEQPOLE1            : in std_logic_vector(3 downto 0);
      RXGEARBOXSLIP0       : in std_ulogic;
      RXGEARBOXSLIP1       : in std_ulogic;
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
      TXDIFFCTRL0          : in std_logic_vector(2 downto 0);
      TXDIFFCTRL1          : in std_logic_vector(2 downto 0);
      TXELECIDLE0          : in std_ulogic;
      TXELECIDLE1          : in std_ulogic;
      TXENC8B10BUSE0       : in std_ulogic;
      TXENC8B10BUSE1       : in std_ulogic;
      TXENPMAPHASEALIGN0   : in std_ulogic;
      TXENPMAPHASEALIGN1   : in std_ulogic;
      TXENPRBSTST0         : in std_logic_vector(1 downto 0);
      TXENPRBSTST1         : in std_logic_vector(1 downto 0);
      TXHEADER0            : in std_logic_vector(2 downto 0);
      TXHEADER1            : in std_logic_vector(2 downto 0);
      TXINHIBIT0           : in std_ulogic;
      TXINHIBIT1           : in std_ulogic;
      TXPMASETPHASE0       : in std_ulogic;
      TXPMASETPHASE1       : in std_ulogic;
      TXPOLARITY0          : in std_ulogic;
      TXPOLARITY1          : in std_ulogic;
      TXPOWERDOWN0         : in std_logic_vector(1 downto 0);
      TXPOWERDOWN1         : in std_logic_vector(1 downto 0);
      TXPREEMPHASIS0       : in std_logic_vector(3 downto 0);
      TXPREEMPHASIS1       : in std_logic_vector(3 downto 0);
      TXRESET0             : in std_ulogic;
      TXRESET1             : in std_ulogic;
      TXSEQUENCE0          : in std_logic_vector(6 downto 0);
      TXSEQUENCE1          : in std_logic_vector(6 downto 0);
      TXSTARTSEQ0          : in std_ulogic;
      TXSTARTSEQ1          : in std_ulogic;
      TXUSRCLK0            : in std_ulogic;
      TXUSRCLK1            : in std_ulogic;
      TXUSRCLK20           : in std_ulogic;
      TXUSRCLK21           : in std_ulogic;

      STEPPING                  : in std_ulogic;
      AC_CAP_DIS_0              : in std_ulogic;
      AC_CAP_DIS_1              : in std_ulogic;
      ALIGN_COMMA_WORD_0        : in std_ulogic;
      ALIGN_COMMA_WORD_1        : in std_ulogic;
      CB2_INH_CC_PERIOD_0       : in std_logic_vector(3 downto 0);
      CB2_INH_CC_PERIOD_1       : in std_logic_vector(3 downto 0);
      CDR_PH_ADJ_TIME           : in std_logic_vector(4 downto 0);
      CHAN_BOND_1_MAX_SKEW_0    : in std_logic_vector(3 downto 0);
      CHAN_BOND_1_MAX_SKEW_1    : in std_logic_vector(3 downto 0);
      CHAN_BOND_2_MAX_SKEW_0    : in std_logic_vector(3 downto 0);
      CHAN_BOND_2_MAX_SKEW_1    : in std_logic_vector(3 downto 0);
      CHAN_BOND_KEEP_ALIGN_0    : in std_ulogic;
      CHAN_BOND_KEEP_ALIGN_1    : in std_ulogic;
      CHAN_BOND_LEVEL_0         : in std_logic_vector(2 downto 0);
      CHAN_BOND_LEVEL_1         : in std_logic_vector(2 downto 0);
      CHAN_BOND_MODE_0          : in std_logic_vector(1 downto 0);
      CHAN_BOND_MODE_1          : in std_logic_vector(1 downto 0);
      CHAN_BOND_SEQ_1_1_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_1_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_2_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_2_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_3_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_3_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_4_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_4_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_1_ENABLE_0  : in std_logic_vector(3 downto 0);
      CHAN_BOND_SEQ_1_ENABLE_1  : in std_logic_vector(3 downto 0);
      CHAN_BOND_SEQ_2_1_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_1_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_2_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_2_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_3_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_3_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_4_0       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_4_1       : in std_logic_vector(9 downto 0);
      CHAN_BOND_SEQ_2_ENABLE_0  : in std_logic_vector(3 downto 0);
      CHAN_BOND_SEQ_2_ENABLE_1  : in std_logic_vector(3 downto 0);
      CHAN_BOND_SEQ_2_USE_0     : in std_ulogic;
      CHAN_BOND_SEQ_2_USE_1     : in std_ulogic;
      CHAN_BOND_SEQ_LEN_0       : in std_logic_vector(1 downto 0);
      CHAN_BOND_SEQ_LEN_1       : in std_logic_vector(1 downto 0);
      CLK25_DIVIDER             : in std_logic_vector(2 downto 0);
      CLKINDC_B                 : in std_ulogic;
      CLKRCV_TRST               : in std_ulogic;
      CLK_CORRECT_USE_0         : in std_ulogic;
      CLK_CORRECT_USE_1         : in std_ulogic;
      CLK_COR_ADJ_LEN_0         : in std_logic_vector(1 downto 0);
      CLK_COR_ADJ_LEN_1         : in std_logic_vector(1 downto 0);
      CLK_COR_DET_LEN_0         : in std_logic_vector(1 downto 0);
      CLK_COR_DET_LEN_1         : in std_logic_vector(1 downto 0);
      CLK_COR_INSERT_IDLE_FLAG_0 : in std_ulogic;
      CLK_COR_INSERT_IDLE_FLAG_1 : in std_ulogic;
      CLK_COR_KEEP_IDLE_0       : in std_ulogic;
      CLK_COR_KEEP_IDLE_1       : in std_ulogic;
      CLK_COR_MAX_LAT_0         : in std_logic_vector(5 downto 0);
      CLK_COR_MAX_LAT_1         : in std_logic_vector(5 downto 0);
      CLK_COR_MIN_LAT_0         : in std_logic_vector(5 downto 0);
      CLK_COR_MIN_LAT_1         : in std_logic_vector(5 downto 0);
      CLK_COR_PRECEDENCE_0      : in std_ulogic;
      CLK_COR_PRECEDENCE_1      : in std_ulogic;
      CLK_COR_REPEAT_WAIT_0     : in std_logic_vector(4 downto 0);
      CLK_COR_REPEAT_WAIT_1     : in std_logic_vector(4 downto 0);
      CLK_COR_SEQ_1_1_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_1_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_2_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_2_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_3_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_3_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_4_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_4_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_1_ENABLE_0    : in std_logic_vector(3 downto 0);
      CLK_COR_SEQ_1_ENABLE_1    : in std_logic_vector(3 downto 0);
      CLK_COR_SEQ_2_1_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_1_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_2_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_2_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_3_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_3_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_4_0         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_4_1         : in std_logic_vector(9 downto 0);
      CLK_COR_SEQ_2_ENABLE_0    : in std_logic_vector(3 downto 0);
      CLK_COR_SEQ_2_ENABLE_1    : in std_logic_vector(3 downto 0);
      CLK_COR_SEQ_2_USE_0       : in std_ulogic;
      CLK_COR_SEQ_2_USE_1       : in std_ulogic;
      CM_TRIM_0                 : in std_logic_vector(1 downto 0);
      CM_TRIM_1                 : in std_logic_vector(1 downto 0);
      COMMA_10B_ENABLE_0        : in std_logic_vector(9 downto 0);
      COMMA_10B_ENABLE_1        : in std_logic_vector(9 downto 0);
      COMMA_DOUBLE_0            : in std_ulogic;
      COMMA_DOUBLE_1            : in std_ulogic;
      COM_BURST_VAL_0           : in std_logic_vector(3 downto 0);
      COM_BURST_VAL_1           : in std_logic_vector(3 downto 0);
      DEC_MCOMMA_DETECT_0       : in std_ulogic;
      DEC_MCOMMA_DETECT_1       : in std_ulogic;
      DEC_PCOMMA_DETECT_0       : in std_ulogic;
      DEC_PCOMMA_DETECT_1       : in std_ulogic;
      DEC_VALID_COMMA_ONLY_0    : in std_ulogic;
      DEC_VALID_COMMA_ONLY_1    : in std_ulogic;
      DFE_CAL_TIME              : in std_logic_vector(4 downto 0);
      DFE_CFG_0                 : in std_logic_vector(9 downto 0);
      DFE_CFG_1                 : in std_logic_vector(9 downto 0);
      GEARBOX_ENDEC_0           : in std_logic_vector(2 downto 0);
      GEARBOX_ENDEC_1           : in std_logic_vector(2 downto 0);
      MCOMMA_10B_VALUE_0        : in std_logic_vector(9 downto 0);
      MCOMMA_10B_VALUE_1        : in std_logic_vector(9 downto 0);
      MCOMMA_DETECT_0           : in std_ulogic;
      MCOMMA_DETECT_1           : in std_ulogic;
      OOBDETECT_THRESHOLD_0     : in std_logic_vector(2 downto 0);
      OOBDETECT_THRESHOLD_1     : in std_logic_vector(2 downto 0);
      OOB_CLK_DIVIDER           : in std_logic_vector(2 downto 0);
      OVERSAMPLE_MODE           : in std_ulogic;
      PCI_EXPRESS_MODE_0        : in std_ulogic;
      PCI_EXPRESS_MODE_1        : in std_ulogic;
      PCOMMA_10B_VALUE_0        : in std_logic_vector(9 downto 0);
      PCOMMA_10B_VALUE_1        : in std_logic_vector(9 downto 0);
      PCOMMA_DETECT_0           : in std_ulogic;
      PCOMMA_DETECT_1           : in std_ulogic;
      PLL_COM_CFG               : in std_logic_vector(23 downto 0);
      PLL_CP_CFG                : in std_logic_vector(7 downto 0);
      PLL_DIVSEL_FB             : in std_logic_vector(4 downto 0);
      PLL_DIVSEL_REF            : in std_logic_vector(5 downto 0);
      PLL_FB_DCCEN              : in std_ulogic;
      PLL_LKDET_CFG             : in std_logic_vector(2 downto 0);
      PLL_RXDIVSEL_OUT_0        : in std_logic_vector(1 downto 0);
      PLL_RXDIVSEL_OUT_1        : in std_logic_vector(1 downto 0);
      PLL_SATA_0                : in std_ulogic;
      PLL_SATA_1                : in std_ulogic;
      PLL_TDCC_CFG              : in std_logic_vector(2 downto 0);
      PLL_TXDIVSEL_OUT_0        : in std_logic_vector(1 downto 0);
      PLL_TXDIVSEL_OUT_1        : in std_logic_vector(1 downto 0);
      PMA_CDR_SCAN_0            : in std_logic_vector(26 downto 0);
      PMA_CDR_SCAN_1            : in std_logic_vector(26 downto 0);
      PMA_COM_CFG               : in std_logic_vector(68 downto 0);
      PMA_RXSYNC_CFG_0          : in std_logic_vector(6 downto 0);
      PMA_RXSYNC_CFG_1          : in std_logic_vector(6 downto 0);
      PMA_RX_CFG_0              : in std_logic_vector(24 downto 0);
      PMA_RX_CFG_1              : in std_logic_vector(24 downto 0);
      PMA_TX_CFG_0              : in std_logic_vector(19 downto 0);
      PMA_TX_CFG_1              : in std_logic_vector(19 downto 0);
      PRBS_ERR_THRESHOLD_0      : in std_logic_vector(31 downto 0);
      PRBS_ERR_THRESHOLD_1      : in std_logic_vector(31 downto 0);
      RCV_TERM_GND_0            : in std_ulogic;
      RCV_TERM_GND_1            : in std_ulogic;
      RCV_TERM_VTTRX_0          : in std_ulogic;
      RCV_TERM_VTTRX_1          : in std_ulogic;
      RXGEARBOX_USE_0           : in std_ulogic;
      RXGEARBOX_USE_1           : in std_ulogic;
      RX_BUFFER_USE_0           : in std_ulogic;
      RX_BUFFER_USE_1           : in std_ulogic;
      RX_DECODE_SEQ_MATCH_0     : in std_ulogic;
      RX_DECODE_SEQ_MATCH_1     : in std_ulogic;
      RX_EN_IDLE_HOLD_CDR       : in std_ulogic;
      RX_EN_IDLE_HOLD_DFE_0     : in std_ulogic;
      RX_EN_IDLE_HOLD_DFE_1     : in std_ulogic;
      RX_EN_IDLE_RESET_BUF_0    : in std_ulogic;
      RX_EN_IDLE_RESET_BUF_1    : in std_ulogic;
      RX_EN_IDLE_RESET_FR       : in std_ulogic;
      RX_EN_IDLE_RESET_PH       : in std_ulogic;
      RX_IDLE_HI_CNT_0          : in std_logic_vector(3 downto 0);
      RX_IDLE_HI_CNT_1          : in std_logic_vector(3 downto 0);
      RX_IDLE_LO_CNT_0          : in std_logic_vector(3 downto 0);
      RX_IDLE_LO_CNT_1          : in std_logic_vector(3 downto 0);
      RX_LOSS_OF_SYNC_FSM_0     : in std_ulogic;
      RX_LOSS_OF_SYNC_FSM_1     : in std_ulogic;
      RX_LOS_INVALID_INCR_0     : in std_logic_vector(2 downto 0);
      RX_LOS_INVALID_INCR_1     : in std_logic_vector(2 downto 0);
      RX_LOS_THRESHOLD_0        : in std_logic_vector(2 downto 0);
      RX_LOS_THRESHOLD_1        : in std_logic_vector(2 downto 0);
      RX_SLIDE_MODE_0           : in std_ulogic;
      RX_SLIDE_MODE_1           : in std_ulogic;
      RX_STATUS_FMT_0           : in std_ulogic;
      RX_STATUS_FMT_1           : in std_ulogic;
      RX_XCLK_SEL_0             : in std_ulogic;
      RX_XCLK_SEL_1             : in std_ulogic;
      SATA_BURST_VAL_0          : in std_logic_vector(2 downto 0);
      SATA_BURST_VAL_1          : in std_logic_vector(2 downto 0);
      SATA_IDLE_VAL_0           : in std_logic_vector(2 downto 0);
      SATA_IDLE_VAL_1           : in std_logic_vector(2 downto 0);
      SATA_MAX_BURST_0          : in std_logic_vector(5 downto 0);
      SATA_MAX_BURST_1          : in std_logic_vector(5 downto 0);
      SATA_MAX_INIT_0           : in std_logic_vector(5 downto 0);
      SATA_MAX_INIT_1           : in std_logic_vector(5 downto 0);
      SATA_MAX_WAKE_0           : in std_logic_vector(5 downto 0);
      SATA_MAX_WAKE_1           : in std_logic_vector(5 downto 0);
      SATA_MIN_BURST_0          : in std_logic_vector(5 downto 0);
      SATA_MIN_BURST_1          : in std_logic_vector(5 downto 0);
      SATA_MIN_INIT_0           : in std_logic_vector(5 downto 0);
      SATA_MIN_INIT_1           : in std_logic_vector(5 downto 0);
      SATA_MIN_WAKE_0           : in std_logic_vector(5 downto 0);
      SATA_MIN_WAKE_1           : in std_logic_vector(5 downto 0);
      SIM_GTXRESET_SPEEDUP      : in std_ulogic;
      SIM_PLL_PERDIV2           : in std_logic_vector(8 downto 0);
      SIM_RECEIVER_DETECT_PASS_0 : in std_ulogic;
      SIM_RECEIVER_DETECT_PASS_1 : in std_ulogic;
      TERMINATION_CTRL          : in std_logic_vector(4 downto 0);
      TERMINATION_IMP_0         : in std_ulogic;
      TERMINATION_IMP_1         : in std_ulogic;
      TERMINATION_OVRD          : in std_ulogic;
      TRANS_TIME_FROM_P2_0      : in std_logic_vector(11 downto 0);
      TRANS_TIME_FROM_P2_1      : in std_logic_vector(11 downto 0);
      TRANS_TIME_NON_P2_0       : in std_logic_vector(7 downto 0);
      TRANS_TIME_NON_P2_1       : in std_logic_vector(7 downto 0);
      TRANS_TIME_TO_P2_0        : in std_logic_vector(9 downto 0);
      TRANS_TIME_TO_P2_1        : in std_logic_vector(9 downto 0);
      TXGEARBOX_USE_0           : in std_ulogic;
      TXGEARBOX_USE_1           : in std_ulogic;
      TXRX_INVERT_0             : in std_logic_vector(2 downto 0);
      TXRX_INVERT_1             : in std_logic_vector(2 downto 0);
      TX_BUFFER_USE_0           : in std_ulogic;
      TX_BUFFER_USE_1           : in std_ulogic;
      TX_DETECT_RX_CFG_0        : in std_logic_vector(13 downto 0);
      TX_DETECT_RX_CFG_1        : in std_logic_vector(13 downto 0);
      TX_IDLE_DELAY_0           : in std_logic_vector(2 downto 0);
      TX_IDLE_DELAY_1           : in std_logic_vector(2 downto 0);
      TX_XCLK_SEL_0             : in std_ulogic;
      TX_XCLK_SEL_1             : in std_ulogic
    );
  end component;

	
	constant IN_DELAY : time := 0 ps;
	constant OUT_DELAY : time := 0 ps;
	constant CLK_DELAY : time := 0 ps;

	constant PATH_DELAY : VitalDelayType01 := (100 ps, 100 ps);


	signal   PLL_TXDIVSEL_OUT_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   PLL_RXDIVSEL_OUT_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   PLL_TXDIVSEL_OUT_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   PLL_RXDIVSEL_OUT_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   PLL_DIVSEL_FB_BINARY  :  std_logic_vector(4 downto 0);
	signal   PLL_DIVSEL_REF_BINARY  :  std_logic_vector(5 downto 0);
	signal   PLL_SATA_0_BINARY  :  std_ulogic;
	signal   PLL_SATA_1_BINARY  :  std_ulogic;
	signal   OOBDETECT_THRESHOLD_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(OOBDETECT_THRESHOLD_0)(2 downto 0);
	signal   OOBDETECT_THRESHOLD_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(OOBDETECT_THRESHOLD_1)(2 downto 0);
	signal   PMA_CDR_SCAN_0_BINARY  :  std_logic_vector(26 downto 0) := To_StdLogicVector(PMA_CDR_SCAN_0)(26 downto 0);
	signal   PMA_CDR_SCAN_1_BINARY  :  std_logic_vector(26 downto 0) := To_StdLogicVector(PMA_CDR_SCAN_1)(26 downto 0);
	signal   PMA_RX_CFG_0_BINARY  :  std_logic_vector(24 downto 0) := To_StdLogicVector(PMA_RX_CFG_0)(24 downto 0);
	signal   PMA_RX_CFG_1_BINARY  :  std_logic_vector(24 downto 0) := To_StdLogicVector(PMA_RX_CFG_1)(24 downto 0);
        signal   PLL_TDCC_CFG_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PLL_TDCC_CFG);
	signal   PMA_COM_CFG_BINARY  :  std_logic_vector(68 downto 0) := To_StdLogicVector(PMA_COM_CFG)(68 downto 0);
        signal   PMA_RXSYNC_CFG_0_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(PMA_RXSYNC_CFG_0)(6 downto 0);
	signal   PMA_RXSYNC_CFG_1_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(PMA_RXSYNC_CFG_1)(6 downto 0);
	signal   OOB_CLK_DIVIDER_BINARY  :  std_logic_vector(2 downto 0);
        signal   STEPPING_BINARY : std_ulogic := '0';
        signal   AC_CAP_DIS_0_BINARY  :  std_ulogic;
	signal   AC_CAP_DIS_1_BINARY  :  std_ulogic;
	signal   RCV_TERM_GND_0_BINARY  :  std_ulogic;
	signal   RCV_TERM_GND_1_BINARY  :  std_ulogic;
	signal   TERMINATION_IMP_0_BINARY  :  std_ulogic;
	signal   TERMINATION_IMP_1_BINARY  :  std_ulogic;
	signal   TERMINATION_OVRD_BINARY  :  std_ulogic;
	signal   TERMINATION_CTRL_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(TERMINATION_CTRL)(4 downto 0);
	signal   RCV_TERM_VTTRX_0_BINARY  :  std_ulogic;
	signal   RCV_TERM_VTTRX_1_BINARY  :  std_ulogic;
	signal   PLL_LKDET_CFG_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PLL_LKDET_CFG);
  signal   TXRX_INVERT_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(TXRX_INVERT_0)(2 downto 0);
	signal   TXRX_INVERT_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(TXRX_INVERT_1)(2 downto 0);
	signal   CLKINDC_B_BINARY  :  std_ulogic;
	signal   PCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   MCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   PCOMMA_10B_VALUE_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(PCOMMA_10B_VALUE_0)(9 downto 0);
	signal   MCOMMA_10B_VALUE_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(MCOMMA_10B_VALUE_0)(9 downto 0);
	signal   COMMA_10B_ENABLE_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(COMMA_10B_ENABLE_0)(9 downto 0);
	signal   COMMA_DOUBLE_0_BINARY  :  std_ulogic;
	signal   ALIGN_COMMA_WORD_0_BINARY  :  std_ulogic;
	signal   DEC_PCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   DEC_MCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   DEC_VALID_COMMA_ONLY_0_BINARY  :  std_ulogic;
	signal   PCOMMA_DETECT_1_BINARY  :  std_ulogic;
	signal   MCOMMA_DETECT_1_BINARY  :  std_ulogic;
	signal   PCOMMA_10B_VALUE_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(PCOMMA_10B_VALUE_1)(9 downto 0);
	signal   MCOMMA_10B_VALUE_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(MCOMMA_10B_VALUE_1)(9 downto 0);
	signal   COMMA_10B_ENABLE_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(COMMA_10B_ENABLE_1)(9 downto 0);
	signal   COMMA_DOUBLE_1_BINARY  :  std_ulogic;
	signal   ALIGN_COMMA_WORD_1_BINARY  :  std_ulogic;
	signal   DEC_PCOMMA_DETECT_1_BINARY  :  std_ulogic;
	signal   DEC_MCOMMA_DETECT_1_BINARY  :  std_ulogic;
	signal   DEC_VALID_COMMA_ONLY_1_BINARY  :  std_ulogic;
	signal   RX_LOSS_OF_SYNC_FSM_0_BINARY  :  std_ulogic;
	signal   RX_LOS_INVALID_INCR_0_BINARY  :  std_logic_vector(2 downto 0);
	signal   RX_LOS_THRESHOLD_0_BINARY  :  std_logic_vector(2 downto 0);
	signal   RX_LOSS_OF_SYNC_FSM_1_BINARY  :  std_ulogic;
	signal   RX_LOS_INVALID_INCR_1_BINARY  :  std_logic_vector(2 downto 0);
	signal   RX_LOS_THRESHOLD_1_BINARY  :  std_logic_vector(2 downto 0);
	signal   RX_BUFFER_USE_0_BINARY  :  std_ulogic;
	signal   RX_DECODE_SEQ_MATCH_0_BINARY  :  std_ulogic;
	signal   RX_BUFFER_USE_1_BINARY  :  std_ulogic;
	signal   RX_DECODE_SEQ_MATCH_1_BINARY  :  std_ulogic;
	signal   CLK_COR_MIN_LAT_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   CLK_COR_MAX_LAT_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   CLK_CORRECT_USE_0_BINARY  :  std_ulogic;
	signal   CLK_COR_PRECEDENCE_0_BINARY  :  std_ulogic;
	signal   CLK_COR_DET_LEN_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   CLK_COR_ADJ_LEN_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   CLK_COR_KEEP_IDLE_0_BINARY  :  std_ulogic;
	signal   CLK_COR_INSERT_IDLE_FLAG_0_BINARY  :  std_ulogic;
	signal   CLK_COR_REPEAT_WAIT_0_BINARY  :  std_logic_vector(4 downto 0);
	signal   CLK_COR_SEQ_2_USE_0_BINARY  :  std_ulogic;
	signal   CLK_COR_SEQ_1_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1_0)(9 downto 0);
	signal   CLK_COR_SEQ_1_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2_0)(9 downto 0);
	signal   CLK_COR_SEQ_1_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3_0)(9 downto 0);
	signal   CLK_COR_SEQ_1_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4_0)(9 downto 0);
	signal   CLK_COR_SEQ_2_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1_0)(9 downto 0);
	signal   CLK_COR_SEQ_2_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2_0)(9 downto 0);
	signal   CLK_COR_SEQ_2_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3_0)(9 downto 0);
	signal   CLK_COR_SEQ_2_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4_0)(9 downto 0);
	signal   CLK_COR_SEQ_1_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_ENABLE_0)(3 downto 0);
	signal   CLK_COR_SEQ_2_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_ENABLE_0)(3 downto 0);
	signal   CLK_COR_MIN_LAT_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   CLK_COR_MAX_LAT_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   CLK_CORRECT_USE_1_BINARY  :  std_ulogic;
	signal   CLK_COR_PRECEDENCE_1_BINARY  :  std_ulogic;
	signal   CLK_COR_DET_LEN_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   CLK_COR_ADJ_LEN_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   CLK_COR_KEEP_IDLE_1_BINARY  :  std_ulogic;
	signal   CLK_COR_INSERT_IDLE_FLAG_1_BINARY  :  std_ulogic;
	signal   CLK_COR_REPEAT_WAIT_1_BINARY  :  std_logic_vector(4 downto 0);
	signal   CLK_COR_SEQ_2_USE_1_BINARY  :  std_ulogic;
	signal   CLK_COR_SEQ_1_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1_1)(9 downto 0);
	signal   CLK_COR_SEQ_1_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2_1)(9 downto 0);
	signal   CLK_COR_SEQ_1_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3_1)(9 downto 0);
	signal   CLK_COR_SEQ_1_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4_1)(9 downto 0);
	signal   CLK_COR_SEQ_2_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1_1)(9 downto 0);
	signal   CLK_COR_SEQ_2_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2_1)(9 downto 0);
	signal   CLK_COR_SEQ_2_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3_1)(9 downto 0);
	signal   CLK_COR_SEQ_2_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4_1)(9 downto 0);
	signal   CLK_COR_SEQ_1_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_ENABLE_1)(3 downto 0);
	signal   CLK_COR_SEQ_2_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_ENABLE_1)(3 downto 0);
	signal   CHAN_BOND_MODE_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_LEVEL_0_BINARY  :  std_logic_vector(2 downto 0);
	signal   CHAN_BOND_SEQ_LEN_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_SEQ_2_USE_0_BINARY  :  std_ulogic;
	signal   CHAN_BOND_SEQ_1_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4_0)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_ENABLE_0)(3 downto 0);
	signal   CHAN_BOND_SEQ_2_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_ENABLE_0)(3 downto 0);
	signal   CHAN_BOND_1_MAX_SKEW_0_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_2_MAX_SKEW_0_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_KEEP_ALIGN_0_BINARY  :  std_ulogic;
	signal   CB2_INH_CC_PERIOD_0_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_MODE_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_LEVEL_1_BINARY  :  std_logic_vector(2 downto 0);
	signal   CHAN_BOND_SEQ_LEN_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_SEQ_2_USE_1_BINARY  :  std_ulogic;
	signal   CHAN_BOND_SEQ_1_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_2_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4_1)(9 downto 0);
	signal   CHAN_BOND_SEQ_1_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_ENABLE_1)(3 downto 0);
	signal   CHAN_BOND_SEQ_2_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_ENABLE_1)(3 downto 0);
	signal   CHAN_BOND_1_MAX_SKEW_1_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_2_MAX_SKEW_1_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_KEEP_ALIGN_1_BINARY  :  std_ulogic;
	signal   CB2_INH_CC_PERIOD_1_BINARY  :  std_logic_vector(3 downto 0);
	signal   PCI_EXPRESS_MODE_0_BINARY  :  std_ulogic;
	signal   TRANS_TIME_FROM_P2_0_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(TRANS_TIME_FROM_P2_0)(11 downto 0);
	signal   TRANS_TIME_NON_P2_0_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(TRANS_TIME_NON_P2_0)(7 downto 0);
	signal   TRANS_TIME_TO_P2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(TRANS_TIME_TO_P2_0)(9 downto 0);
	signal   PCI_EXPRESS_MODE_1_BINARY  :  std_ulogic;
	signal   TRANS_TIME_FROM_P2_1_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(TRANS_TIME_FROM_P2_1)(11 downto 0);
	signal   TRANS_TIME_NON_P2_1_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(TRANS_TIME_NON_P2_1)(7 downto 0);
	signal   TRANS_TIME_TO_P2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(TRANS_TIME_TO_P2_1)(9 downto 0);
	signal   RX_STATUS_FMT_0_BINARY  :  std_ulogic;
	signal   TX_BUFFER_USE_0_BINARY  :  std_ulogic;
	signal   TX_XCLK_SEL_0_BINARY  :  std_ulogic;
	signal   RX_XCLK_SEL_0_BINARY  :  std_ulogic;
	signal   RX_STATUS_FMT_1_BINARY  :  std_ulogic;
	signal   TX_BUFFER_USE_1_BINARY  :  std_ulogic;
	signal   TX_XCLK_SEL_1_BINARY  :  std_ulogic;
	signal   RX_XCLK_SEL_1_BINARY  :  std_ulogic;
	signal   PRBS_ERR_THRESHOLD_0_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(PRBS_ERR_THRESHOLD_0)(31 downto 0);
	signal   RX_SLIDE_MODE_0_BINARY  :  std_ulogic;
	signal   PRBS_ERR_THRESHOLD_1_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(PRBS_ERR_THRESHOLD_1)(31 downto 0);
	signal   RX_SLIDE_MODE_1_BINARY  :  std_ulogic;
	signal   SATA_MIN_BURST_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_BURST_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_INIT_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_INIT_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_WAKE_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_WAKE_0_BINARY  :  std_logic_vector(5 downto 0);
        signal   TX_DETECT_RX_CFG_0_BINARY  :  std_logic_vector(13 downto 0) := To_StdLogicVector(TX_DETECT_RX_CFG_0)(13 downto 0);
  signal   SATA_BURST_VAL_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_BURST_VAL_0)(2 downto 0);
	signal   SATA_IDLE_VAL_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_IDLE_VAL_0)(2 downto 0);
	signal   COM_BURST_VAL_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(COM_BURST_VAL_0)(3 downto 0);
	signal   SATA_MIN_BURST_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_BURST_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_INIT_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_INIT_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_WAKE_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_WAKE_1_BINARY  :  std_logic_vector(5 downto 0);
        signal   TX_DETECT_RX_CFG_1_BINARY  :  std_logic_vector(13 downto 0) := To_StdLogicVector(TX_DETECT_RX_CFG_1)(13 downto 0);
  signal   SATA_BURST_VAL_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_BURST_VAL_1)(2 downto 0);
	signal   SATA_IDLE_VAL_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_IDLE_VAL_1)(2 downto 0);
	signal   COM_BURST_VAL_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(COM_BURST_VAL_1)(3 downto 0);
	signal   CLK25_DIVIDER_BINARY  :  std_logic_vector(2 downto 0);
        signal   PLL_COM_CFG_BINARY  :  std_logic_vector(23 downto 0) := To_StdLogicVector(PLL_COM_CFG);
	signal   PLL_CP_CFG_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PLL_CP_CFG);
        signal   OVERSAMPLE_MODE_BINARY  :  std_ulogic;
	signal   TXGEARBOX_USE_0_BINARY  :  std_ulogic;
	signal   RXGEARBOX_USE_0_BINARY  :  std_ulogic;
	signal   GEARBOX_ENDEC_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(GEARBOX_ENDEC_0)(2 downto 0);
	signal   TXGEARBOX_USE_1_BINARY  :  std_ulogic;
	signal   RXGEARBOX_USE_1_BINARY  :  std_ulogic;
	signal   GEARBOX_ENDEC_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(GEARBOX_ENDEC_1)(2 downto 0);
	signal   DFE_CFG_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(DFE_CFG_0)(9 downto 0);
	signal   DFE_CFG_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(DFE_CFG_1)(9 downto 0);
	signal   PMA_TX_CFG_0_BINARY  :  std_logic_vector(19 downto 0) := To_StdLogicVector(PMA_TX_CFG_0)(19 downto 0);
	signal   CM_TRIM_0_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(CM_TRIM_0)(1 downto 0);
	signal   PMA_TX_CFG_1_BINARY  :  std_logic_vector(19 downto 0) := To_StdLogicVector(PMA_TX_CFG_1)(19 downto 0);
	signal   CM_TRIM_1_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(CM_TRIM_1)(1 downto 0);
	signal   PLL_FB_DCCEN_BINARY  :  std_ulogic;
	signal   CLKRCV_TRST_BINARY  :  std_ulogic;
	signal   TX_IDLE_DELAY_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(TX_IDLE_DELAY_0)(2 downto 0);
	signal   RX_EN_IDLE_HOLD_DFE_0_BINARY  :  std_ulogic;
	signal   RX_EN_IDLE_RESET_BUF_0_BINARY  :  std_ulogic;
	signal   RX_IDLE_HI_CNT_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_HI_CNT_0)(3 downto 0);
	signal   RX_IDLE_LO_CNT_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_LO_CNT_0)(3 downto 0);
	signal   TX_IDLE_DELAY_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(TX_IDLE_DELAY_1)(2 downto 0);
	signal   RX_EN_IDLE_HOLD_DFE_1_BINARY  :  std_ulogic;
	signal   RX_EN_IDLE_RESET_BUF_1_BINARY  :  std_ulogic;
	signal   RX_IDLE_HI_CNT_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_HI_CNT_1)(3 downto 0);
	signal   RX_IDLE_LO_CNT_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_LO_CNT_1)(3 downto 0);
	signal   RX_EN_IDLE_HOLD_CDR_BINARY  :  std_ulogic;
	signal   RX_EN_IDLE_RESET_PH_BINARY  :  std_ulogic;
	signal   RX_EN_IDLE_RESET_FR_BINARY  :  std_ulogic;
	signal   DFE_CAL_TIME_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(DFE_CAL_TIME)(4 downto 0);
	signal   CDR_PH_ADJ_TIME_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(CDR_PH_ADJ_TIME)(4 downto 0);
	signal   SIM_GTXRESET_SPEEDUP_BINARY  :  std_ulogic;
        signal   SIM_MODE_BINARY  :  std_ulogic;
        signal   SIM_PLL_PERDIV2_BINARY  :  std_logic_vector(8 downto 0) := To_StdLogicVector(SIM_PLL_PERDIV2)(8 downto 0);
	signal   SIM_RECEIVER_DETECT_PASS_0_BINARY  :  std_ulogic;
	signal   SIM_RECEIVER_DETECT_PASS_1_BINARY  :  std_ulogic;


	signal   REFCLKOUT_out  :  std_ulogic;
	signal   RXRECCLK0_out  :  std_ulogic;
	signal   TXOUTCLK0_out  :  std_ulogic;
	signal   RXRECCLK1_out  :  std_ulogic;
	signal   TXOUTCLK1_out  :  std_ulogic;
	signal   TXP0_out  :  std_ulogic;
	signal   TXN0_out  :  std_ulogic;
	signal   TXP1_out  :  std_ulogic;
	signal   TXN1_out  :  std_ulogic;
	signal   RXDATA0_out  :  std_logic_vector(31 downto 0);
	signal   RXNOTINTABLE0_out  :  std_logic_vector(3 downto 0);
	signal   RXDISPERR0_out  :  std_logic_vector(3 downto 0);
	signal   RXCHARISK0_out  :  std_logic_vector(3 downto 0);
	signal   RXRUNDISP0_out  :  std_logic_vector(3 downto 0);
	signal   RXCHARISCOMMA0_out  :  std_logic_vector(3 downto 0);
	signal   RXVALID0_out  :  std_ulogic;
	signal   RXDATA1_out  :  std_logic_vector(31 downto 0);
	signal   RXNOTINTABLE1_out  :  std_logic_vector(3 downto 0);
	signal   RXDISPERR1_out  :  std_logic_vector(3 downto 0);
	signal   RXCHARISK1_out  :  std_logic_vector(3 downto 0);
	signal   RXRUNDISP1_out  :  std_logic_vector(3 downto 0);
	signal   RXCHARISCOMMA1_out  :  std_logic_vector(3 downto 0);
	signal   RXVALID1_out  :  std_ulogic;
	signal   RESETDONE0_out  :  std_ulogic;
	signal   RESETDONE1_out  :  std_ulogic;
	signal   TXKERR0_out  :  std_logic_vector(3 downto 0);
	signal   TXRUNDISP0_out  :  std_logic_vector(3 downto 0);
	signal   TXBUFSTATUS0_out  :  std_logic_vector(1 downto 0);
	signal   TXKERR1_out  :  std_logic_vector(3 downto 0);
	signal   TXRUNDISP1_out  :  std_logic_vector(3 downto 0);
	signal   TXBUFSTATUS1_out  :  std_logic_vector(1 downto 0);
	signal   RXCOMMADET0_out  :  std_ulogic;
	signal   RXBYTEREALIGN0_out  :  std_ulogic;
	signal   RXBYTEISALIGNED0_out  :  std_ulogic;
	signal   RXLOSSOFSYNC0_out  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO0_out  :  std_logic_vector(3 downto 0);
	signal   RXCHANBONDSEQ0_out  :  std_ulogic;
	signal   RXCHANREALIGN0_out  :  std_ulogic;
	signal   RXCHANISALIGNED0_out  :  std_ulogic;
	signal   RXBUFSTATUS0_out  :  std_logic_vector(2 downto 0);
	signal   RXCOMMADET1_out  :  std_ulogic;
	signal   RXBYTEREALIGN1_out  :  std_ulogic;
	signal   RXBYTEISALIGNED1_out  :  std_ulogic;
	signal   RXLOSSOFSYNC1_out  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO1_out  :  std_logic_vector(3 downto 0);
	signal   RXCHANBONDSEQ1_out  :  std_ulogic;
	signal   RXCHANREALIGN1_out  :  std_ulogic;
	signal   RXCHANISALIGNED1_out  :  std_ulogic;
	signal   RXBUFSTATUS1_out  :  std_logic_vector(2 downto 0);
	signal   PHYSTATUS0_out  :  std_ulogic;
	signal   PHYSTATUS1_out  :  std_ulogic;
	signal   RXELECIDLE0_out  :  std_ulogic;
	signal   RXSTATUS0_out  :  std_logic_vector(2 downto 0);
	signal   RXCLKCORCNT0_out  :  std_logic_vector(2 downto 0);
	signal   RXELECIDLE1_out  :  std_ulogic;
	signal   RXSTATUS1_out  :  std_logic_vector(2 downto 0);
	signal   RXCLKCORCNT1_out  :  std_logic_vector(2 downto 0);
	signal   PLLLKDET_out  :  std_ulogic;
	signal   RXPRBSERR0_out  :  std_ulogic;
	signal   RXPRBSERR1_out  :  std_ulogic;
	signal   DO_out  :  std_logic_vector(15 downto 0);
	signal   DRDY_out  :  std_ulogic;
	signal   RXOVERSAMPLEERR0_out  :  std_ulogic;
	signal   RXOVERSAMPLEERR1_out  :  std_ulogic;
	signal   TXGEARBOXREADY0_out  :  std_ulogic;
	signal   RXHEADER0_out  :  std_logic_vector(2 downto 0);
	signal   RXHEADERVALID0_out  :  std_ulogic;
	signal   RXDATAVALID0_out  :  std_ulogic;
	signal   RXSTARTOFSEQ0_out  :  std_ulogic;
	signal   TXGEARBOXREADY1_out  :  std_ulogic;
	signal   RXHEADER1_out  :  std_logic_vector(2 downto 0);
	signal   RXHEADERVALID1_out  :  std_ulogic;
	signal   RXDATAVALID1_out  :  std_ulogic;
	signal   RXSTARTOFSEQ1_out  :  std_ulogic;
	signal   DFECLKDLYADJMONITOR0_out  :  std_logic_vector(5 downto 0);
	signal   DFEEYEDACMONITOR0_out  :  std_logic_vector(4 downto 0);
	signal   DFETAP1MONITOR0_out  :  std_logic_vector(4 downto 0);
	signal   DFETAP2MONITOR0_out  :  std_logic_vector(4 downto 0);
	signal   DFETAP3MONITOR0_out  :  std_logic_vector(3 downto 0);
	signal   DFETAP4MONITOR0_out  :  std_logic_vector(3 downto 0);
	signal   DFECLKDLYADJMONITOR1_out  :  std_logic_vector(5 downto 0);
	signal   DFEEYEDACMONITOR1_out  :  std_logic_vector(4 downto 0);
	signal   DFETAP1MONITOR1_out  :  std_logic_vector(4 downto 0);
	signal   DFETAP2MONITOR1_out  :  std_logic_vector(4 downto 0);
	signal   DFETAP3MONITOR1_out  :  std_logic_vector(3 downto 0);
	signal   DFETAP4MONITOR1_out  :  std_logic_vector(3 downto 0);
	signal   DFESENSCAL0_out  :  std_logic_vector(2 downto 0);
	signal   DFESENSCAL1_out  :  std_logic_vector(2 downto 0);

	signal   REFCLKOUT_outdelay  :  std_logic;
	signal   RXRECCLK0_outdelay  :  std_logic;
	signal   TXOUTCLK0_outdelay  :  std_logic;
	signal   RXRECCLK1_outdelay  :  std_logic;
	signal   TXOUTCLK1_outdelay  :  std_logic;
	signal   RXCLKCORCNT0_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXCLKCORCNT1_outdelay  :  std_logic_vector(2 downto 0);
	signal   DFECLKDLYADJMONITOR0_outdelay  :  std_logic_vector(5 downto 0);
	signal   DFECLKDLYADJMONITOR1_outdelay  :  std_logic_vector(5 downto 0);

	signal   TXP0_outdelay  :  std_logic;
	signal   TXN0_outdelay  :  std_logic;
	signal   TXP1_outdelay  :  std_logic;
	signal   TXN1_outdelay  :  std_logic;
	signal   RXDATA0_outdelay  :  std_logic_vector(31 downto 0);
	signal   RXNOTINTABLE0_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXDISPERR0_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXCHARISK0_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXRUNDISP0_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXCHARISCOMMA0_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXVALID0_outdelay  :  std_logic;
	signal   RXDATA1_outdelay  :  std_logic_vector(31 downto 0);
	signal   RXNOTINTABLE1_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXDISPERR1_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXCHARISK1_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXRUNDISP1_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXCHARISCOMMA1_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXVALID1_outdelay  :  std_logic;
	signal   RESETDONE0_outdelay  :  std_logic;
	signal   RESETDONE1_outdelay  :  std_logic;
	signal   TXKERR0_outdelay  :  std_logic_vector(3 downto 0);
	signal   TXRUNDISP0_outdelay  :  std_logic_vector(3 downto 0);
	signal   TXBUFSTATUS0_outdelay  :  std_logic_vector(1 downto 0);
	signal   TXKERR1_outdelay  :  std_logic_vector(3 downto 0);
	signal   TXRUNDISP1_outdelay  :  std_logic_vector(3 downto 0);
	signal   TXBUFSTATUS1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCOMMADET0_outdelay  :  std_logic;
	signal   RXBYTEREALIGN0_outdelay  :  std_logic;
	signal   RXBYTEISALIGNED0_outdelay  :  std_logic;
	signal   RXLOSSOFSYNC0_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO0_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXCHANBONDSEQ0_outdelay  :  std_logic;
	signal   RXCHANREALIGN0_outdelay  :  std_logic;
	signal   RXCHANISALIGNED0_outdelay  :  std_logic;
	signal   RXBUFSTATUS0_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXCOMMADET1_outdelay  :  std_logic;
	signal   RXBYTEREALIGN1_outdelay  :  std_logic;
	signal   RXBYTEISALIGNED1_outdelay  :  std_logic;
	signal   RXLOSSOFSYNC1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO1_outdelay  :  std_logic_vector(3 downto 0);
	signal   RXCHANBONDSEQ1_outdelay  :  std_logic;
	signal   RXCHANREALIGN1_outdelay  :  std_logic;
	signal   RXCHANISALIGNED1_outdelay  :  std_logic;
	signal   RXBUFSTATUS1_outdelay  :  std_logic_vector(2 downto 0);
	signal   PHYSTATUS0_outdelay  :  std_logic;
	signal   PHYSTATUS1_outdelay  :  std_logic;
	signal   RXELECIDLE0_outdelay  :  std_logic;
	signal   RXSTATUS0_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXELECIDLE1_outdelay  :  std_logic;
	signal   RXSTATUS1_outdelay  :  std_logic_vector(2 downto 0);
	signal   PLLLKDET_outdelay  :  std_logic;
	signal   RXPRBSERR0_outdelay  :  std_logic;
	signal   RXPRBSERR1_outdelay  :  std_logic;
	signal   DO_outdelay  :  std_logic_vector(15 downto 0);
	signal   DRDY_outdelay  :  std_logic;
	signal   RXOVERSAMPLEERR0_outdelay  :  std_logic;
	signal   RXOVERSAMPLEERR1_outdelay  :  std_logic;
	signal   TXGEARBOXREADY0_outdelay  :  std_logic;
	signal   RXHEADER0_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXHEADERVALID0_outdelay  :  std_logic;
	signal   RXDATAVALID0_outdelay  :  std_logic;
	signal   RXSTARTOFSEQ0_outdelay  :  std_logic;
	signal   TXGEARBOXREADY1_outdelay  :  std_logic;
	signal   RXHEADER1_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXHEADERVALID1_outdelay  :  std_logic;
	signal   RXDATAVALID1_outdelay  :  std_logic;
	signal   RXSTARTOFSEQ1_outdelay  :  std_logic;
	signal   DFEEYEDACMONITOR0_outdelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP1MONITOR0_outdelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP2MONITOR0_outdelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP3MONITOR0_outdelay  :  std_logic_vector(3 downto 0);
	signal   DFETAP4MONITOR0_outdelay  :  std_logic_vector(3 downto 0);
	signal   DFEEYEDACMONITOR1_outdelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP1MONITOR1_outdelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP2MONITOR1_outdelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP3MONITOR1_outdelay  :  std_logic_vector(3 downto 0);
	signal   DFETAP4MONITOR1_outdelay  :  std_logic_vector(3 downto 0);
	signal   DFESENSCAL0_outdelay  :  std_logic_vector(2 downto 0);
	signal   DFESENSCAL1_outdelay  :  std_logic_vector(2 downto 0);

	signal   CLKIN_ipd  :  std_ulogic;
	signal   TXUSRCLK0_ipd  :  std_ulogic;
	signal   TXUSRCLK20_ipd  :  std_ulogic;
	signal   RXUSRCLK0_ipd  :  std_ulogic;
	signal   RXUSRCLK20_ipd  :  std_ulogic;
	signal   TXUSRCLK1_ipd  :  std_ulogic;
	signal   TXUSRCLK21_ipd  :  std_ulogic;
	signal   RXUSRCLK1_ipd  :  std_ulogic;
	signal   RXUSRCLK21_ipd  :  std_ulogic;
	signal   RXP0_ipd  :  std_ulogic;
	signal   RXN0_ipd  :  std_ulogic;
	signal   TXDATA0_ipd  :  std_logic_vector(31 downto 0);
	signal   TXBYPASS8B10B0_ipd  :  std_logic_vector(3 downto 0);
	signal   TXCHARISK0_ipd  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPMODE0_ipd  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPVAL0_ipd  :  std_logic_vector(3 downto 0);
	signal   RXP1_ipd  :  std_ulogic;
	signal   RXN1_ipd  :  std_ulogic;
	signal   TXDATA1_ipd  :  std_logic_vector(31 downto 0);
	signal   TXBYPASS8B10B1_ipd  :  std_logic_vector(3 downto 0);
	signal   TXCHARISK1_ipd  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPMODE1_ipd  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPVAL1_ipd  :  std_logic_vector(3 downto 0);
	signal   GTXRESET_ipd  :  std_ulogic;
	signal   RXCDRRESET0_ipd  :  std_ulogic;
	signal   TXRESET0_ipd  :  std_ulogic;
	signal   RXRESET0_ipd  :  std_ulogic;
	signal   RXBUFRESET0_ipd  :  std_ulogic;
	signal   RXCDRRESET1_ipd  :  std_ulogic;
	signal   TXRESET1_ipd  :  std_ulogic;
	signal   RXRESET1_ipd  :  std_ulogic;
	signal   RXBUFRESET1_ipd  :  std_ulogic;
	signal   TXPOWERDOWN0_ipd  :  std_logic_vector(1 downto 0);
	signal   RXPOWERDOWN0_ipd  :  std_logic_vector(1 downto 0);
	signal   TXPOWERDOWN1_ipd  :  std_logic_vector(1 downto 0);
	signal   RXPOWERDOWN1_ipd  :  std_logic_vector(1 downto 0);
	signal   PLLPOWERDOWN_ipd  :  std_ulogic;
	signal   REFCLKPWRDNB_ipd  :  std_ulogic;
	signal   LOOPBACK0_ipd  :  std_logic_vector(2 downto 0);
	signal   LOOPBACK1_ipd  :  std_logic_vector(2 downto 0);
	signal   TXDIFFCTRL0_ipd  :  std_logic_vector(2 downto 0);
	signal   TXBUFDIFFCTRL0_ipd  :  std_logic_vector(2 downto 0);
	signal   TXPREEMPHASIS0_ipd  :  std_logic_vector(3 downto 0);
	signal   TXDIFFCTRL1_ipd  :  std_logic_vector(2 downto 0);
	signal   TXBUFDIFFCTRL1_ipd  :  std_logic_vector(2 downto 0);
	signal   TXPREEMPHASIS1_ipd  :  std_logic_vector(3 downto 0);
	signal   RXENEQB0_ipd  :  std_ulogic;
	signal   RXEQMIX0_ipd  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE0_ipd  :  std_logic_vector(3 downto 0);
	signal   RXENEQB1_ipd  :  std_ulogic;
	signal   RXEQMIX1_ipd  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE1_ipd  :  std_logic_vector(3 downto 0);
	signal   INTDATAWIDTH_ipd  :  std_ulogic;
	signal   TXDATAWIDTH0_ipd  :  std_logic_vector(1 downto 0);
	signal   TXDATAWIDTH1_ipd  :  std_logic_vector(1 downto 0);
	signal   TXENPMAPHASEALIGN0_ipd  :  std_ulogic;
	signal   TXPMASETPHASE0_ipd  :  std_ulogic;
	signal   RXENPMAPHASEALIGN0_ipd  :  std_ulogic;
	signal   RXPMASETPHASE0_ipd  :  std_ulogic;
	signal   TXENPMAPHASEALIGN1_ipd  :  std_ulogic;
	signal   TXPMASETPHASE1_ipd  :  std_ulogic;
	signal   RXENPMAPHASEALIGN1_ipd  :  std_ulogic;
	signal   RXPMASETPHASE1_ipd  :  std_ulogic;
	signal   TXENC8B10BUSE0_ipd  :  std_ulogic;
	signal   TXPOLARITY0_ipd  :  std_ulogic;
	signal   TXINHIBIT0_ipd  :  std_ulogic;
	signal   TXENC8B10BUSE1_ipd  :  std_ulogic;
	signal   TXPOLARITY1_ipd  :  std_ulogic;
	signal   TXINHIBIT1_ipd  :  std_ulogic;
	signal   RXPOLARITY0_ipd  :  std_ulogic;
	signal   RXENPCOMMAALIGN0_ipd  :  std_ulogic;
	signal   RXENMCOMMAALIGN0_ipd  :  std_ulogic;
	signal   RXSLIDE0_ipd  :  std_ulogic;
	signal   RXCOMMADETUSE0_ipd  :  std_ulogic;
	signal   RXDEC8B10BUSE0_ipd  :  std_ulogic;
	signal   RXENCHANSYNC0_ipd  :  std_ulogic;
	signal   RXCHBONDI0_ipd  :  std_logic_vector(3 downto 0);
	signal   RXDATAWIDTH0_ipd  :  std_logic_vector(1 downto 0);
	signal   RXPOLARITY1_ipd  :  std_ulogic;
	signal   RXENPCOMMAALIGN1_ipd  :  std_ulogic;
	signal   RXENMCOMMAALIGN1_ipd  :  std_ulogic;
	signal   RXSLIDE1_ipd  :  std_ulogic;
	signal   RXCOMMADETUSE1_ipd  :  std_ulogic;
	signal   RXDEC8B10BUSE1_ipd  :  std_ulogic;
	signal   RXENCHANSYNC1_ipd  :  std_ulogic;
	signal   RXCHBONDI1_ipd  :  std_logic_vector(3 downto 0);
	signal   RXDATAWIDTH1_ipd  :  std_logic_vector(1 downto 0);
	signal   TXELECIDLE0_ipd  :  std_ulogic;
	signal   TXDETECTRX0_ipd  :  std_ulogic;
	signal   TXELECIDLE1_ipd  :  std_ulogic;
	signal   TXDETECTRX1_ipd  :  std_ulogic;
	signal   TXCOMSTART0_ipd  :  std_ulogic;
	signal   TXCOMTYPE0_ipd  :  std_ulogic;
	signal   TXCOMSTART1_ipd  :  std_ulogic;
	signal   TXCOMTYPE1_ipd  :  std_ulogic;
	signal   PLLLKDETEN_ipd  :  std_ulogic;
	signal   TXENPRBSTST0_ipd  :  std_logic_vector(1 downto 0);
	signal   RXENPRBSTST0_ipd  :  std_logic_vector(1 downto 0);
	signal   PRBSCNTRESET0_ipd  :  std_ulogic;
	signal   TXENPRBSTST1_ipd  :  std_logic_vector(1 downto 0);
	signal   RXENPRBSTST1_ipd  :  std_logic_vector(1 downto 0);
	signal   PRBSCNTRESET1_ipd  :  std_ulogic;
	signal   DCLK_ipd  :  std_ulogic;
	signal   DADDR_ipd  :  std_logic_vector(6 downto 0);
	signal   DI_ipd  :  std_logic_vector(15 downto 0);
	signal   DEN_ipd  :  std_ulogic;
	signal   DWE_ipd  :  std_ulogic;
	signal   RXENSAMPLEALIGN0_ipd  :  std_ulogic;
	signal   RXENSAMPLEALIGN1_ipd  :  std_ulogic;
	signal   GTXTEST_ipd  :  std_logic_vector(13 downto 0);
	signal   TXHEADER0_ipd  :  std_logic_vector(2 downto 0);
	signal   TXSEQUENCE0_ipd  :  std_logic_vector(6 downto 0);
	signal   TXSTARTSEQ0_ipd  :  std_ulogic;
	signal   RXGEARBOXSLIP0_ipd  :  std_ulogic;
	signal   TXHEADER1_ipd  :  std_logic_vector(2 downto 0);
	signal   TXSEQUENCE1_ipd  :  std_logic_vector(6 downto 0);
	signal   TXSTARTSEQ1_ipd  :  std_ulogic;
	signal   RXGEARBOXSLIP1_ipd  :  std_ulogic;
	signal   DFECLKDLYADJ0_ipd  :  std_logic_vector(5 downto 0);
	signal   DFETAP10_ipd  :  std_logic_vector(4 downto 0);
	signal   DFETAP20_ipd  :  std_logic_vector(4 downto 0);
	signal   DFETAP30_ipd  :  std_logic_vector(3 downto 0);
	signal   DFETAP40_ipd  :  std_logic_vector(3 downto 0);
	signal   DFECLKDLYADJ1_ipd  :  std_logic_vector(5 downto 0);
	signal   DFETAP11_ipd  :  std_logic_vector(4 downto 0);
	signal   DFETAP21_ipd  :  std_logic_vector(4 downto 0);
	signal   DFETAP31_ipd  :  std_logic_vector(3 downto 0);
	signal   DFETAP41_ipd  :  std_logic_vector(3 downto 0);


	signal   CLKIN_indelay  :  std_ulogic;
	signal   TXUSRCLK0_indelay  :  std_ulogic;
	signal   TXUSRCLK20_indelay  :  std_ulogic;
	signal   RXUSRCLK0_indelay  :  std_ulogic;
	signal   RXUSRCLK20_indelay  :  std_ulogic;
	signal   TXUSRCLK1_indelay  :  std_ulogic;
	signal   TXUSRCLK21_indelay  :  std_ulogic;
	signal   RXUSRCLK1_indelay  :  std_ulogic;
	signal   RXUSRCLK21_indelay  :  std_ulogic;
	signal   RXP0_indelay  :  std_ulogic;
	signal   RXN0_indelay  :  std_ulogic;
	signal   TXDATA0_indelay  :  std_logic_vector(31 downto 0);
	signal   TXBYPASS8B10B0_indelay  :  std_logic_vector(3 downto 0);
	signal   TXCHARISK0_indelay  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPMODE0_indelay  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPVAL0_indelay  :  std_logic_vector(3 downto 0);
	signal   RXP1_indelay  :  std_ulogic;
	signal   RXN1_indelay  :  std_ulogic;
	signal   TXDATA1_indelay  :  std_logic_vector(31 downto 0);
	signal   TXBYPASS8B10B1_indelay  :  std_logic_vector(3 downto 0);
	signal   TXCHARISK1_indelay  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPMODE1_indelay  :  std_logic_vector(3 downto 0);
	signal   TXCHARDISPVAL1_indelay  :  std_logic_vector(3 downto 0);
	signal   GTXRESET_indelay  :  std_ulogic;
	signal   RXCDRRESET0_indelay  :  std_ulogic;
	signal   TXRESET0_indelay  :  std_ulogic;
	signal   RXRESET0_indelay  :  std_ulogic;
	signal   RXBUFRESET0_indelay  :  std_ulogic;
	signal   RXCDRRESET1_indelay  :  std_ulogic;
	signal   TXRESET1_indelay  :  std_ulogic;
	signal   RXRESET1_indelay  :  std_ulogic;
	signal   RXBUFRESET1_indelay  :  std_ulogic;
	signal   TXPOWERDOWN0_indelay  :  std_logic_vector(1 downto 0);
	signal   RXPOWERDOWN0_indelay  :  std_logic_vector(1 downto 0);
	signal   TXPOWERDOWN1_indelay  :  std_logic_vector(1 downto 0);
	signal   RXPOWERDOWN1_indelay  :  std_logic_vector(1 downto 0);
	signal   PLLPOWERDOWN_indelay  :  std_ulogic;
	signal   REFCLKPWRDNB_indelay  :  std_ulogic;
	signal   LOOPBACK0_indelay  :  std_logic_vector(2 downto 0);
	signal   LOOPBACK1_indelay  :  std_logic_vector(2 downto 0);
	signal   TXDIFFCTRL0_indelay  :  std_logic_vector(2 downto 0);
	signal   TXBUFDIFFCTRL0_indelay  :  std_logic_vector(2 downto 0);
	signal   TXPREEMPHASIS0_indelay  :  std_logic_vector(3 downto 0);
	signal   TXDIFFCTRL1_indelay  :  std_logic_vector(2 downto 0);
	signal   TXBUFDIFFCTRL1_indelay  :  std_logic_vector(2 downto 0);
	signal   TXPREEMPHASIS1_indelay  :  std_logic_vector(3 downto 0);
	signal   RXENEQB0_indelay  :  std_ulogic;
	signal   RXEQMIX0_indelay  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE0_indelay  :  std_logic_vector(3 downto 0);
	signal   RXENEQB1_indelay  :  std_ulogic;
	signal   RXEQMIX1_indelay  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE1_indelay  :  std_logic_vector(3 downto 0);
	signal   INTDATAWIDTH_indelay  :  std_ulogic;
	signal   TXDATAWIDTH0_indelay  :  std_logic_vector(1 downto 0);
	signal   TXDATAWIDTH1_indelay  :  std_logic_vector(1 downto 0);
	signal   TXENPMAPHASEALIGN0_indelay  :  std_ulogic;
	signal   TXPMASETPHASE0_indelay  :  std_ulogic;
	signal   RXENPMAPHASEALIGN0_indelay  :  std_ulogic;
	signal   RXPMASETPHASE0_indelay  :  std_ulogic;
	signal   TXENPMAPHASEALIGN1_indelay  :  std_ulogic;
	signal   TXPMASETPHASE1_indelay  :  std_ulogic;
	signal   RXENPMAPHASEALIGN1_indelay  :  std_ulogic;
	signal   RXPMASETPHASE1_indelay  :  std_ulogic;
	signal   TXENC8B10BUSE0_indelay  :  std_ulogic;
	signal   TXPOLARITY0_indelay  :  std_ulogic;
	signal   TXINHIBIT0_indelay  :  std_ulogic;
	signal   TXENC8B10BUSE1_indelay  :  std_ulogic;
	signal   TXPOLARITY1_indelay  :  std_ulogic;
	signal   TXINHIBIT1_indelay  :  std_ulogic;
	signal   RXPOLARITY0_indelay  :  std_ulogic;
	signal   RXENPCOMMAALIGN0_indelay  :  std_ulogic;
	signal   RXENMCOMMAALIGN0_indelay  :  std_ulogic;
	signal   RXSLIDE0_indelay  :  std_ulogic;
	signal   RXCOMMADETUSE0_indelay  :  std_ulogic;
	signal   RXDEC8B10BUSE0_indelay  :  std_ulogic;
	signal   RXENCHANSYNC0_indelay  :  std_ulogic;
	signal   RXCHBONDI0_indelay  :  std_logic_vector(3 downto 0);
	signal   RXDATAWIDTH0_indelay  :  std_logic_vector(1 downto 0);
	signal   RXPOLARITY1_indelay  :  std_ulogic;
	signal   RXENPCOMMAALIGN1_indelay  :  std_ulogic;
	signal   RXENMCOMMAALIGN1_indelay  :  std_ulogic;
	signal   RXSLIDE1_indelay  :  std_ulogic;
	signal   RXCOMMADETUSE1_indelay  :  std_ulogic;
	signal   RXDEC8B10BUSE1_indelay  :  std_ulogic;
	signal   RXENCHANSYNC1_indelay  :  std_ulogic;
	signal   RXCHBONDI1_indelay  :  std_logic_vector(3 downto 0);
	signal   RXDATAWIDTH1_indelay  :  std_logic_vector(1 downto 0);
	signal   TXELECIDLE0_indelay  :  std_ulogic;
	signal   TXDETECTRX0_indelay  :  std_ulogic;
	signal   TXELECIDLE1_indelay  :  std_ulogic;
	signal   TXDETECTRX1_indelay  :  std_ulogic;
	signal   TXCOMSTART0_indelay  :  std_ulogic;
	signal   TXCOMTYPE0_indelay  :  std_ulogic;
	signal   TXCOMSTART1_indelay  :  std_ulogic;
	signal   TXCOMTYPE1_indelay  :  std_ulogic;
	signal   PLLLKDETEN_indelay  :  std_ulogic;
	signal   TXENPRBSTST0_indelay  :  std_logic_vector(1 downto 0);
	signal   RXENPRBSTST0_indelay  :  std_logic_vector(1 downto 0);
	signal   PRBSCNTRESET0_indelay  :  std_ulogic;
	signal   TXENPRBSTST1_indelay  :  std_logic_vector(1 downto 0);
	signal   RXENPRBSTST1_indelay  :  std_logic_vector(1 downto 0);
	signal   PRBSCNTRESET1_indelay  :  std_ulogic;
	signal   DCLK_indelay  :  std_ulogic;
	signal   DADDR_indelay  :  std_logic_vector(6 downto 0);
	signal   DI_indelay  :  std_logic_vector(15 downto 0);
	signal   DEN_indelay  :  std_ulogic;
	signal   DWE_indelay  :  std_ulogic;
	signal   RXENSAMPLEALIGN0_indelay  :  std_ulogic;
	signal   RXENSAMPLEALIGN1_indelay  :  std_ulogic;
	signal   GTXTEST_indelay  :  std_logic_vector(13 downto 0);
	signal   TXHEADER0_indelay  :  std_logic_vector(2 downto 0);
	signal   TXSEQUENCE0_indelay  :  std_logic_vector(6 downto 0);
	signal   TXSTARTSEQ0_indelay  :  std_ulogic;
	signal   RXGEARBOXSLIP0_indelay  :  std_ulogic;
	signal   TXHEADER1_indelay  :  std_logic_vector(2 downto 0);
	signal   TXSEQUENCE1_indelay  :  std_logic_vector(6 downto 0);
	signal   TXSTARTSEQ1_indelay  :  std_ulogic;
	signal   RXGEARBOXSLIP1_indelay  :  std_ulogic;
	signal   DFECLKDLYADJ0_indelay  :  std_logic_vector(5 downto 0);
	signal   DFETAP10_indelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP20_indelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP30_indelay  :  std_logic_vector(3 downto 0);
	signal   DFETAP40_indelay  :  std_logic_vector(3 downto 0);
	signal   DFECLKDLYADJ1_indelay  :  std_logic_vector(5 downto 0);
	signal   DFETAP11_indelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP21_indelay  :  std_logic_vector(4 downto 0);
	signal   DFETAP31_indelay  :  std_logic_vector(3 downto 0);
	signal   DFETAP41_indelay  :  std_logic_vector(3 downto 0);

begin

	DFECLKDLYADJMONITOR0_out <= DFECLKDLYADJMONITOR0_outdelay after CLK_DELAY;
	DFECLKDLYADJMONITOR1_out <= DFECLKDLYADJMONITOR1_outdelay after CLK_DELAY;
	REFCLKOUT_out <= REFCLKOUT_outdelay after CLK_DELAY;
	RXCLKCORCNT0_out <= RXCLKCORCNT0_outdelay after CLK_DELAY;
	RXCLKCORCNT1_out <= RXCLKCORCNT1_outdelay after CLK_DELAY;
	RXRECCLK0_out <= RXRECCLK0_outdelay after CLK_DELAY;
	RXRECCLK1_out <= RXRECCLK1_outdelay after CLK_DELAY;
	TXOUTCLK0_out <= TXOUTCLK0_outdelay after CLK_DELAY;
	TXOUTCLK1_out <= TXOUTCLK1_outdelay after CLK_DELAY;

	DFEEYEDACMONITOR0_out <= DFEEYEDACMONITOR0_outdelay after OUT_DELAY;
	DFEEYEDACMONITOR1_out <= DFEEYEDACMONITOR1_outdelay after OUT_DELAY;
	DFESENSCAL0_out <= DFESENSCAL0_outdelay after OUT_DELAY;
	DFESENSCAL1_out <= DFESENSCAL1_outdelay after OUT_DELAY;
	DFETAP1MONITOR0_out <= DFETAP1MONITOR0_outdelay after OUT_DELAY;
	DFETAP1MONITOR1_out <= DFETAP1MONITOR1_outdelay after OUT_DELAY;
	DFETAP2MONITOR0_out <= DFETAP2MONITOR0_outdelay after OUT_DELAY;
	DFETAP2MONITOR1_out <= DFETAP2MONITOR1_outdelay after OUT_DELAY;
	DFETAP3MONITOR0_out <= DFETAP3MONITOR0_outdelay after OUT_DELAY;
	DFETAP3MONITOR1_out <= DFETAP3MONITOR1_outdelay after OUT_DELAY;
	DFETAP4MONITOR0_out <= DFETAP4MONITOR0_outdelay after OUT_DELAY;
	DFETAP4MONITOR1_out <= DFETAP4MONITOR1_outdelay after OUT_DELAY;
	DO_out <= DO_outdelay after OUT_DELAY;
	DRDY_out <= DRDY_outdelay after OUT_DELAY;
	PHYSTATUS0_out <= PHYSTATUS0_outdelay after OUT_DELAY;
	PHYSTATUS1_out <= PHYSTATUS1_outdelay after OUT_DELAY;
	PLLLKDET_out <= PLLLKDET_outdelay after OUT_DELAY;
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
	RXCHBONDO0_out <= RXCHBONDO0_outdelay after OUT_DELAY;
	RXCHBONDO1_out <= RXCHBONDO1_outdelay after OUT_DELAY;
	RXCOMMADET0_out <= RXCOMMADET0_outdelay after OUT_DELAY;
	RXCOMMADET1_out <= RXCOMMADET1_outdelay after OUT_DELAY;
	RXDATA0_out <= RXDATA0_outdelay after OUT_DELAY;
	RXDATA1_out <= RXDATA1_outdelay after OUT_DELAY;
	RXDATAVALID0_out <= RXDATAVALID0_outdelay after OUT_DELAY;
	RXDATAVALID1_out <= RXDATAVALID1_outdelay after OUT_DELAY;
	RXDISPERR0_out <= RXDISPERR0_outdelay after OUT_DELAY;
	RXDISPERR1_out <= RXDISPERR1_outdelay after OUT_DELAY;
	RXELECIDLE0_out <= RXELECIDLE0_outdelay after OUT_DELAY;
	RXELECIDLE1_out <= RXELECIDLE1_outdelay after OUT_DELAY;
	RXHEADER0_out <= RXHEADER0_outdelay after OUT_DELAY;
	RXHEADER1_out <= RXHEADER1_outdelay after OUT_DELAY;
	RXHEADERVALID0_out <= RXHEADERVALID0_outdelay after OUT_DELAY;
	RXHEADERVALID1_out <= RXHEADERVALID1_outdelay after OUT_DELAY;
	RXLOSSOFSYNC0_out <= RXLOSSOFSYNC0_outdelay after OUT_DELAY;
	RXLOSSOFSYNC1_out <= RXLOSSOFSYNC1_outdelay after OUT_DELAY;
	RXNOTINTABLE0_out <= RXNOTINTABLE0_outdelay after OUT_DELAY;
	RXNOTINTABLE1_out <= RXNOTINTABLE1_outdelay after OUT_DELAY;
	RXOVERSAMPLEERR0_out <= RXOVERSAMPLEERR0_outdelay after OUT_DELAY;
	RXOVERSAMPLEERR1_out <= RXOVERSAMPLEERR1_outdelay after OUT_DELAY;
	RXPRBSERR0_out <= RXPRBSERR0_outdelay after OUT_DELAY;
	RXPRBSERR1_out <= RXPRBSERR1_outdelay after OUT_DELAY;
	RXRUNDISP0_out <= RXRUNDISP0_outdelay after OUT_DELAY;
	RXRUNDISP1_out <= RXRUNDISP1_outdelay after OUT_DELAY;
	RXSTARTOFSEQ0_out <= RXSTARTOFSEQ0_outdelay after OUT_DELAY;
	RXSTARTOFSEQ1_out <= RXSTARTOFSEQ1_outdelay after OUT_DELAY;
	RXSTATUS0_out <= RXSTATUS0_outdelay after OUT_DELAY;
	RXSTATUS1_out <= RXSTATUS1_outdelay after OUT_DELAY;
	RXVALID0_out <= RXVALID0_outdelay after OUT_DELAY;
	RXVALID1_out <= RXVALID1_outdelay after OUT_DELAY;
	TXBUFSTATUS0_out <= TXBUFSTATUS0_outdelay after OUT_DELAY;
	TXBUFSTATUS1_out <= TXBUFSTATUS1_outdelay after OUT_DELAY;
	TXGEARBOXREADY0_out <= TXGEARBOXREADY0_outdelay after OUT_DELAY;
	TXGEARBOXREADY1_out <= TXGEARBOXREADY1_outdelay after OUT_DELAY;
	TXKERR0_out <= TXKERR0_outdelay after OUT_DELAY;
	TXKERR1_out <= TXKERR1_outdelay after OUT_DELAY;
	TXN0_out <= TXN0_outdelay after OUT_DELAY;
	TXN1_out <= TXN1_outdelay after OUT_DELAY;
	TXP0_out <= TXP0_outdelay after OUT_DELAY;
	TXP1_out <= TXP1_outdelay after OUT_DELAY;
	TXRUNDISP0_out <= TXRUNDISP0_outdelay after OUT_DELAY;
	TXRUNDISP1_out <= TXRUNDISP1_outdelay after OUT_DELAY;

	DCLK_ipd <= DCLK after CLK_DELAY;
	RXUSRCLK0_ipd <= RXUSRCLK0 after CLK_DELAY;
	RXUSRCLK1_ipd <= RXUSRCLK1 after CLK_DELAY;
	RXUSRCLK20_ipd <= RXUSRCLK20 after CLK_DELAY;
	RXUSRCLK21_ipd <= RXUSRCLK21 after CLK_DELAY;
	TXUSRCLK0_ipd <= TXUSRCLK0 after CLK_DELAY;
	TXUSRCLK1_ipd <= TXUSRCLK1 after CLK_DELAY;
	TXUSRCLK20_ipd <= TXUSRCLK20 after CLK_DELAY;
	TXUSRCLK21_ipd <= TXUSRCLK21 after CLK_DELAY;

	CLKIN_ipd <= CLKIN after CLK_DELAY;
	DADDR_ipd <= DADDR after CLK_DELAY;
	DEN_ipd <= DEN after CLK_DELAY;
	DFECLKDLYADJ0_ipd <= DFECLKDLYADJ0 after CLK_DELAY;
	DFECLKDLYADJ1_ipd <= DFECLKDLYADJ1 after CLK_DELAY;
	DFETAP10_ipd <= DFETAP10 after CLK_DELAY;
	DFETAP11_ipd <= DFETAP11 after CLK_DELAY;
	DFETAP20_ipd <= DFETAP20 after CLK_DELAY;
	DFETAP21_ipd <= DFETAP21 after CLK_DELAY;
	DFETAP30_ipd <= DFETAP30 after CLK_DELAY;
	DFETAP31_ipd <= DFETAP31 after CLK_DELAY;
	DFETAP40_ipd <= DFETAP40 after CLK_DELAY;
	DFETAP41_ipd <= DFETAP41 after CLK_DELAY;
	DI_ipd <= DI after CLK_DELAY;
	DWE_ipd <= DWE after CLK_DELAY;
	GTXRESET_ipd <= GTXRESET after CLK_DELAY;
	GTXTEST_ipd <= GTXTEST after CLK_DELAY;
	INTDATAWIDTH_ipd <= INTDATAWIDTH after CLK_DELAY;
	LOOPBACK0_ipd <= LOOPBACK0 after CLK_DELAY;
	LOOPBACK1_ipd <= LOOPBACK1 after CLK_DELAY;
	PLLLKDETEN_ipd <= PLLLKDETEN after CLK_DELAY;
	PLLPOWERDOWN_ipd <= PLLPOWERDOWN after CLK_DELAY;
	PRBSCNTRESET0_ipd <= PRBSCNTRESET0 after CLK_DELAY;
	PRBSCNTRESET1_ipd <= PRBSCNTRESET1 after CLK_DELAY;
	REFCLKPWRDNB_ipd <= REFCLKPWRDNB after CLK_DELAY;
	RXBUFRESET0_ipd <= RXBUFRESET0 after CLK_DELAY;
	RXBUFRESET1_ipd <= RXBUFRESET1 after CLK_DELAY;
	RXCDRRESET0_ipd <= RXCDRRESET0 after CLK_DELAY;
	RXCDRRESET1_ipd <= RXCDRRESET1 after CLK_DELAY;
	RXCHBONDI0_ipd <= RXCHBONDI0 after CLK_DELAY;
	RXCHBONDI1_ipd <= RXCHBONDI1 after CLK_DELAY;
	RXCOMMADETUSE0_ipd <= RXCOMMADETUSE0 after CLK_DELAY;
	RXCOMMADETUSE1_ipd <= RXCOMMADETUSE1 after CLK_DELAY;
	RXDATAWIDTH0_ipd <= RXDATAWIDTH0 after CLK_DELAY;
	RXDATAWIDTH1_ipd <= RXDATAWIDTH1 after CLK_DELAY;
	RXDEC8B10BUSE0_ipd <= RXDEC8B10BUSE0 after CLK_DELAY;
	RXDEC8B10BUSE1_ipd <= RXDEC8B10BUSE1 after CLK_DELAY;
	RXENCHANSYNC0_ipd <= RXENCHANSYNC0 after CLK_DELAY;
	RXENCHANSYNC1_ipd <= RXENCHANSYNC1 after CLK_DELAY;
	RXENEQB0_ipd <= RXENEQB0 after CLK_DELAY;
	RXENEQB1_ipd <= RXENEQB1 after CLK_DELAY;
	RXENMCOMMAALIGN0_ipd <= RXENMCOMMAALIGN0 after CLK_DELAY;
	RXENMCOMMAALIGN1_ipd <= RXENMCOMMAALIGN1 after CLK_DELAY;
	RXENPCOMMAALIGN0_ipd <= RXENPCOMMAALIGN0 after CLK_DELAY;
	RXENPCOMMAALIGN1_ipd <= RXENPCOMMAALIGN1 after CLK_DELAY;
	RXENPMAPHASEALIGN0_ipd <= RXENPMAPHASEALIGN0 after CLK_DELAY;
	RXENPMAPHASEALIGN1_ipd <= RXENPMAPHASEALIGN1 after CLK_DELAY;
	RXENPRBSTST0_ipd <= RXENPRBSTST0 after CLK_DELAY;
	RXENPRBSTST1_ipd <= RXENPRBSTST1 after CLK_DELAY;
	RXENSAMPLEALIGN0_ipd <= RXENSAMPLEALIGN0 after CLK_DELAY;
	RXENSAMPLEALIGN1_ipd <= RXENSAMPLEALIGN1 after CLK_DELAY;
	RXEQMIX0_ipd <= RXEQMIX0 after CLK_DELAY;
	RXEQMIX1_ipd <= RXEQMIX1 after CLK_DELAY;
	RXEQPOLE0_ipd <= RXEQPOLE0 after CLK_DELAY;
	RXEQPOLE1_ipd <= RXEQPOLE1 after CLK_DELAY;
	RXGEARBOXSLIP0_ipd <= RXGEARBOXSLIP0 after CLK_DELAY;
	RXGEARBOXSLIP1_ipd <= RXGEARBOXSLIP1 after CLK_DELAY;
	RXN0_ipd <= RXN0 after CLK_DELAY;
	RXN1_ipd <= RXN1 after CLK_DELAY;
	RXP0_ipd <= RXP0 after CLK_DELAY;
	RXP1_ipd <= RXP1 after CLK_DELAY;
	RXPMASETPHASE0_ipd <= RXPMASETPHASE0 after CLK_DELAY;
	RXPMASETPHASE1_ipd <= RXPMASETPHASE1 after CLK_DELAY;
	RXPOLARITY0_ipd <= RXPOLARITY0 after CLK_DELAY;
	RXPOLARITY1_ipd <= RXPOLARITY1 after CLK_DELAY;
	RXPOWERDOWN0_ipd <= RXPOWERDOWN0 after CLK_DELAY;
	RXPOWERDOWN1_ipd <= RXPOWERDOWN1 after CLK_DELAY;
	RXRESET0_ipd <= RXRESET0 after CLK_DELAY;
	RXRESET1_ipd <= RXRESET1 after CLK_DELAY;
	RXSLIDE0_ipd <= RXSLIDE0 after CLK_DELAY;
	RXSLIDE1_ipd <= RXSLIDE1 after CLK_DELAY;
	TXBUFDIFFCTRL0_ipd <= TXBUFDIFFCTRL0 after CLK_DELAY;
	TXBUFDIFFCTRL1_ipd <= TXBUFDIFFCTRL1 after CLK_DELAY;
	TXBYPASS8B10B0_ipd <= TXBYPASS8B10B0 after CLK_DELAY;
	TXBYPASS8B10B1_ipd <= TXBYPASS8B10B1 after CLK_DELAY;
	TXCHARDISPMODE0_ipd <= TXCHARDISPMODE0 after CLK_DELAY;
	TXCHARDISPMODE1_ipd <= TXCHARDISPMODE1 after CLK_DELAY;
	TXCHARDISPVAL0_ipd <= TXCHARDISPVAL0 after CLK_DELAY;
	TXCHARDISPVAL1_ipd <= TXCHARDISPVAL1 after CLK_DELAY;
	TXCHARISK0_ipd <= TXCHARISK0 after CLK_DELAY;
	TXCHARISK1_ipd <= TXCHARISK1 after CLK_DELAY;
	TXCOMSTART0_ipd <= TXCOMSTART0 after CLK_DELAY;
	TXCOMSTART1_ipd <= TXCOMSTART1 after CLK_DELAY;
	TXCOMTYPE0_ipd <= TXCOMTYPE0 after CLK_DELAY;
	TXCOMTYPE1_ipd <= TXCOMTYPE1 after CLK_DELAY;
	TXDATA0_ipd <= TXDATA0 after CLK_DELAY;
	TXDATA1_ipd <= TXDATA1 after CLK_DELAY;
	TXDATAWIDTH0_ipd <= TXDATAWIDTH0 after CLK_DELAY;
	TXDATAWIDTH1_ipd <= TXDATAWIDTH1 after CLK_DELAY;
	TXDETECTRX0_ipd <= TXDETECTRX0 after CLK_DELAY;
	TXDETECTRX1_ipd <= TXDETECTRX1 after CLK_DELAY;
	TXDIFFCTRL0_ipd <= TXDIFFCTRL0 after CLK_DELAY;
	TXDIFFCTRL1_ipd <= TXDIFFCTRL1 after CLK_DELAY;
	TXELECIDLE0_ipd <= TXELECIDLE0 after CLK_DELAY;
	TXELECIDLE1_ipd <= TXELECIDLE1 after CLK_DELAY;
	TXENC8B10BUSE0_ipd <= TXENC8B10BUSE0 after CLK_DELAY;
	TXENC8B10BUSE1_ipd <= TXENC8B10BUSE1 after CLK_DELAY;
	TXENPMAPHASEALIGN0_ipd <= TXENPMAPHASEALIGN0 after CLK_DELAY;
	TXENPMAPHASEALIGN1_ipd <= TXENPMAPHASEALIGN1 after CLK_DELAY;
	TXENPRBSTST0_ipd <= TXENPRBSTST0 after CLK_DELAY;
	TXENPRBSTST1_ipd <= TXENPRBSTST1 after CLK_DELAY;
	TXHEADER0_ipd <= TXHEADER0 after CLK_DELAY;
	TXHEADER1_ipd <= TXHEADER1 after CLK_DELAY;
	TXINHIBIT0_ipd <= TXINHIBIT0 after CLK_DELAY;
	TXINHIBIT1_ipd <= TXINHIBIT1 after CLK_DELAY;
	TXPMASETPHASE0_ipd <= TXPMASETPHASE0 after CLK_DELAY;
	TXPMASETPHASE1_ipd <= TXPMASETPHASE1 after CLK_DELAY;
	TXPOLARITY0_ipd <= TXPOLARITY0 after CLK_DELAY;
	TXPOLARITY1_ipd <= TXPOLARITY1 after CLK_DELAY;
	TXPOWERDOWN0_ipd <= TXPOWERDOWN0 after CLK_DELAY;
	TXPOWERDOWN1_ipd <= TXPOWERDOWN1 after CLK_DELAY;
	TXPREEMPHASIS0_ipd <= TXPREEMPHASIS0 after CLK_DELAY;
	TXPREEMPHASIS1_ipd <= TXPREEMPHASIS1 after CLK_DELAY;
	TXRESET0_ipd <= TXRESET0 after CLK_DELAY;
	TXRESET1_ipd <= TXRESET1 after CLK_DELAY;
	TXSEQUENCE0_ipd <= TXSEQUENCE0 after CLK_DELAY;
	TXSEQUENCE1_ipd <= TXSEQUENCE1 after CLK_DELAY;
	TXSTARTSEQ0_ipd <= TXSTARTSEQ0 after CLK_DELAY;
	TXSTARTSEQ1_ipd <= TXSTARTSEQ1 after CLK_DELAY;

	DCLK_indelay <= DCLK_ipd after CLK_DELAY;
	RXUSRCLK0_indelay <= RXUSRCLK0_ipd after CLK_DELAY;
	RXUSRCLK1_indelay <= RXUSRCLK1_ipd after CLK_DELAY;
	RXUSRCLK20_indelay <= RXUSRCLK20_ipd after CLK_DELAY;
	RXUSRCLK21_indelay <= RXUSRCLK21_ipd after CLK_DELAY;
	TXUSRCLK0_indelay <= TXUSRCLK0_ipd after CLK_DELAY;
	TXUSRCLK1_indelay <= TXUSRCLK1_ipd after CLK_DELAY;
	TXUSRCLK20_indelay <= TXUSRCLK20_ipd after CLK_DELAY;
	TXUSRCLK21_indelay <= TXUSRCLK21_ipd after CLK_DELAY;

	CLKIN_indelay <= CLKIN_ipd after IN_DELAY;
	DADDR_indelay <= DADDR_ipd after IN_DELAY;
	DEN_indelay <= DEN_ipd after IN_DELAY;
	DFECLKDLYADJ0_indelay <= DFECLKDLYADJ0_ipd after IN_DELAY;
	DFECLKDLYADJ1_indelay <= DFECLKDLYADJ1_ipd after IN_DELAY;
	DFETAP10_indelay <= DFETAP10_ipd after IN_DELAY;
	DFETAP11_indelay <= DFETAP11_ipd after IN_DELAY;
	DFETAP20_indelay <= DFETAP20_ipd after IN_DELAY;
	DFETAP21_indelay <= DFETAP21_ipd after IN_DELAY;
	DFETAP30_indelay <= DFETAP30_ipd after IN_DELAY;
	DFETAP31_indelay <= DFETAP31_ipd after IN_DELAY;
	DFETAP40_indelay <= DFETAP40_ipd after IN_DELAY;
	DFETAP41_indelay <= DFETAP41_ipd after IN_DELAY;
	DI_indelay <= DI_ipd after IN_DELAY;
	DWE_indelay <= DWE_ipd after IN_DELAY;
	GTXRESET_indelay <= GTXRESET_ipd after IN_DELAY;
	GTXTEST_indelay <= GTXTEST_ipd after IN_DELAY;
	INTDATAWIDTH_indelay <= INTDATAWIDTH_ipd after IN_DELAY;
	LOOPBACK0_indelay <= LOOPBACK0_ipd after IN_DELAY;
	LOOPBACK1_indelay <= LOOPBACK1_ipd after IN_DELAY;
	PLLLKDETEN_indelay <= PLLLKDETEN_ipd after IN_DELAY;
	PLLPOWERDOWN_indelay <= PLLPOWERDOWN_ipd after IN_DELAY;
	PRBSCNTRESET0_indelay <= PRBSCNTRESET0_ipd after IN_DELAY;
	PRBSCNTRESET1_indelay <= PRBSCNTRESET1_ipd after IN_DELAY;
	REFCLKPWRDNB_indelay <= REFCLKPWRDNB_ipd after IN_DELAY;
	RXBUFRESET0_indelay <= RXBUFRESET0_ipd after IN_DELAY;
	RXBUFRESET1_indelay <= RXBUFRESET1_ipd after IN_DELAY;
	RXCDRRESET0_indelay <= RXCDRRESET0_ipd after IN_DELAY;
	RXCDRRESET1_indelay <= RXCDRRESET1_ipd after IN_DELAY;
	RXCHBONDI0_indelay <= RXCHBONDI0_ipd after IN_DELAY;
	RXCHBONDI1_indelay <= RXCHBONDI1_ipd after IN_DELAY;
	RXCOMMADETUSE0_indelay <= RXCOMMADETUSE0_ipd after IN_DELAY;
	RXCOMMADETUSE1_indelay <= RXCOMMADETUSE1_ipd after IN_DELAY;
	RXDATAWIDTH0_indelay <= RXDATAWIDTH0_ipd after IN_DELAY;
	RXDATAWIDTH1_indelay <= RXDATAWIDTH1_ipd after IN_DELAY;
	RXDEC8B10BUSE0_indelay <= RXDEC8B10BUSE0_ipd after IN_DELAY;
	RXDEC8B10BUSE1_indelay <= RXDEC8B10BUSE1_ipd after IN_DELAY;
	RXENCHANSYNC0_indelay <= RXENCHANSYNC0_ipd after IN_DELAY;
	RXENCHANSYNC1_indelay <= RXENCHANSYNC1_ipd after IN_DELAY;
	RXENEQB0_indelay <= RXENEQB0_ipd after IN_DELAY;
	RXENEQB1_indelay <= RXENEQB1_ipd after IN_DELAY;
	RXENMCOMMAALIGN0_indelay <= RXENMCOMMAALIGN0_ipd after IN_DELAY;
	RXENMCOMMAALIGN1_indelay <= RXENMCOMMAALIGN1_ipd after IN_DELAY;
	RXENPCOMMAALIGN0_indelay <= RXENPCOMMAALIGN0_ipd after IN_DELAY;
	RXENPCOMMAALIGN1_indelay <= RXENPCOMMAALIGN1_ipd after IN_DELAY;
	RXENPMAPHASEALIGN0_indelay <= RXENPMAPHASEALIGN0_ipd after IN_DELAY;
	RXENPMAPHASEALIGN1_indelay <= RXENPMAPHASEALIGN1_ipd after IN_DELAY;
	RXENPRBSTST0_indelay <= RXENPRBSTST0_ipd after IN_DELAY;
	RXENPRBSTST1_indelay <= RXENPRBSTST1_ipd after IN_DELAY;
	RXENSAMPLEALIGN0_indelay <= RXENSAMPLEALIGN0_ipd after IN_DELAY;
	RXENSAMPLEALIGN1_indelay <= RXENSAMPLEALIGN1_ipd after IN_DELAY;
	RXEQMIX0_indelay <= RXEQMIX0_ipd after IN_DELAY;
	RXEQMIX1_indelay <= RXEQMIX1_ipd after IN_DELAY;
	RXEQPOLE0_indelay <= RXEQPOLE0_ipd after IN_DELAY;
	RXEQPOLE1_indelay <= RXEQPOLE1_ipd after IN_DELAY;
	RXGEARBOXSLIP0_indelay <= RXGEARBOXSLIP0_ipd after IN_DELAY;
	RXGEARBOXSLIP1_indelay <= RXGEARBOXSLIP1_ipd after IN_DELAY;
	RXN0_indelay <= RXN0_ipd after IN_DELAY;
	RXN1_indelay <= RXN1_ipd after IN_DELAY;
	RXP0_indelay <= RXP0_ipd after IN_DELAY;
	RXP1_indelay <= RXP1_ipd after IN_DELAY;
	RXPMASETPHASE0_indelay <= RXPMASETPHASE0_ipd after IN_DELAY;
	RXPMASETPHASE1_indelay <= RXPMASETPHASE1_ipd after IN_DELAY;
	RXPOLARITY0_indelay <= RXPOLARITY0_ipd after IN_DELAY;
	RXPOLARITY1_indelay <= RXPOLARITY1_ipd after IN_DELAY;
	RXPOWERDOWN0_indelay <= RXPOWERDOWN0_ipd after IN_DELAY;
	RXPOWERDOWN1_indelay <= RXPOWERDOWN1_ipd after IN_DELAY;
	RXRESET0_indelay <= RXRESET0_ipd after IN_DELAY;
	RXRESET1_indelay <= RXRESET1_ipd after IN_DELAY;
	RXSLIDE0_indelay <= RXSLIDE0_ipd after IN_DELAY;
	RXSLIDE1_indelay <= RXSLIDE1_ipd after IN_DELAY;
	TXBUFDIFFCTRL0_indelay <= TXBUFDIFFCTRL0_ipd after IN_DELAY;
	TXBUFDIFFCTRL1_indelay <= TXBUFDIFFCTRL1_ipd after IN_DELAY;
	TXBYPASS8B10B0_indelay <= TXBYPASS8B10B0_ipd after IN_DELAY;
	TXBYPASS8B10B1_indelay <= TXBYPASS8B10B1_ipd after IN_DELAY;
	TXCHARDISPMODE0_indelay <= TXCHARDISPMODE0_ipd after IN_DELAY;
	TXCHARDISPMODE1_indelay <= TXCHARDISPMODE1_ipd after IN_DELAY;
	TXCHARDISPVAL0_indelay <= TXCHARDISPVAL0_ipd after IN_DELAY;
	TXCHARDISPVAL1_indelay <= TXCHARDISPVAL1_ipd after IN_DELAY;
	TXCHARISK0_indelay <= TXCHARISK0_ipd after IN_DELAY;
	TXCHARISK1_indelay <= TXCHARISK1_ipd after IN_DELAY;
	TXCOMSTART0_indelay <= TXCOMSTART0_ipd after IN_DELAY;
	TXCOMSTART1_indelay <= TXCOMSTART1_ipd after IN_DELAY;
	TXCOMTYPE0_indelay <= TXCOMTYPE0_ipd after IN_DELAY;
	TXCOMTYPE1_indelay <= TXCOMTYPE1_ipd after IN_DELAY;
	TXDATA0_indelay <= TXDATA0_ipd after IN_DELAY;
	TXDATA1_indelay <= TXDATA1_ipd after IN_DELAY;
	TXDATAWIDTH0_indelay <= TXDATAWIDTH0_ipd after IN_DELAY;
	TXDATAWIDTH1_indelay <= TXDATAWIDTH1_ipd after IN_DELAY;
	TXDETECTRX0_indelay <= TXDETECTRX0_ipd after IN_DELAY;
	TXDETECTRX1_indelay <= TXDETECTRX1_ipd after IN_DELAY;
	TXDIFFCTRL0_indelay <= TXDIFFCTRL0_ipd after IN_DELAY;
	TXDIFFCTRL1_indelay <= TXDIFFCTRL1_ipd after IN_DELAY;
	TXELECIDLE0_indelay <= TXELECIDLE0_ipd after IN_DELAY;
	TXELECIDLE1_indelay <= TXELECIDLE1_ipd after IN_DELAY;
	TXENC8B10BUSE0_indelay <= TXENC8B10BUSE0_ipd after IN_DELAY;
	TXENC8B10BUSE1_indelay <= TXENC8B10BUSE1_ipd after IN_DELAY;
	TXENPMAPHASEALIGN0_indelay <= TXENPMAPHASEALIGN0_ipd after IN_DELAY;
	TXENPMAPHASEALIGN1_indelay <= TXENPMAPHASEALIGN1_ipd after IN_DELAY;
	TXENPRBSTST0_indelay <= TXENPRBSTST0_ipd after IN_DELAY;
	TXENPRBSTST1_indelay <= TXENPRBSTST1_ipd after IN_DELAY;
	TXHEADER0_indelay <= TXHEADER0_ipd after IN_DELAY;
	TXHEADER1_indelay <= TXHEADER1_ipd after IN_DELAY;
	TXINHIBIT0_indelay <= TXINHIBIT0_ipd after IN_DELAY;
	TXINHIBIT1_indelay <= TXINHIBIT1_ipd after IN_DELAY;
	TXPMASETPHASE0_indelay <= TXPMASETPHASE0_ipd after IN_DELAY;
	TXPMASETPHASE1_indelay <= TXPMASETPHASE1_ipd after IN_DELAY;
	TXPOLARITY0_indelay <= TXPOLARITY0_ipd after IN_DELAY;
	TXPOLARITY1_indelay <= TXPOLARITY1_ipd after IN_DELAY;
	TXPOWERDOWN0_indelay <= TXPOWERDOWN0_ipd after IN_DELAY;
	TXPOWERDOWN1_indelay <= TXPOWERDOWN1_ipd after IN_DELAY;
	TXPREEMPHASIS0_indelay <= TXPREEMPHASIS0_ipd after IN_DELAY;
	TXPREEMPHASIS1_indelay <= TXPREEMPHASIS1_ipd after IN_DELAY;
	TXRESET0_indelay <= TXRESET0_ipd after IN_DELAY;
	TXRESET1_indelay <= TXRESET1_ipd after IN_DELAY;
	TXSEQUENCE0_indelay <= TXSEQUENCE0_ipd after IN_DELAY;
	TXSEQUENCE1_indelay <= TXSEQUENCE1_ipd after IN_DELAY;
	TXSTARTSEQ0_indelay <= TXSTARTSEQ0_ipd after IN_DELAY;
	TXSTARTSEQ1_indelay <= TXSTARTSEQ1_ipd after IN_DELAY;


  	gtx_dual_fast_bw_1 : GTX_DUAL_FAST
	port map (
        STEPPING   => STEPPING_BINARY,
        AC_CAP_DIS_0  =>  AC_CAP_DIS_0_BINARY,
	AC_CAP_DIS_1  =>  AC_CAP_DIS_1_BINARY,
	ALIGN_COMMA_WORD_0  =>  ALIGN_COMMA_WORD_0_BINARY,
	ALIGN_COMMA_WORD_1  =>  ALIGN_COMMA_WORD_1_BINARY,
	CB2_INH_CC_PERIOD_0  =>  CB2_INH_CC_PERIOD_0_BINARY,
	CB2_INH_CC_PERIOD_1  =>  CB2_INH_CC_PERIOD_1_BINARY,
	CDR_PH_ADJ_TIME  =>  CDR_PH_ADJ_TIME_BINARY,
	CHAN_BOND_1_MAX_SKEW_0  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY,
	CHAN_BOND_1_MAX_SKEW_1  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY,
	CHAN_BOND_2_MAX_SKEW_0  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY,
	CHAN_BOND_2_MAX_SKEW_1  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY,
	CHAN_BOND_KEEP_ALIGN_0  =>  CHAN_BOND_KEEP_ALIGN_0_BINARY,
	CHAN_BOND_KEEP_ALIGN_1  =>  CHAN_BOND_KEEP_ALIGN_1_BINARY,
	CHAN_BOND_LEVEL_0  =>  CHAN_BOND_LEVEL_0_BINARY,
	CHAN_BOND_LEVEL_1  =>  CHAN_BOND_LEVEL_1_BINARY,
	CHAN_BOND_MODE_0  =>  CHAN_BOND_MODE_0_BINARY,
	CHAN_BOND_MODE_1  =>  CHAN_BOND_MODE_1_BINARY,
	CHAN_BOND_SEQ_1_1_0  =>  CHAN_BOND_SEQ_1_1_0_BINARY,
	CHAN_BOND_SEQ_1_1_1  =>  CHAN_BOND_SEQ_1_1_1_BINARY,
	CHAN_BOND_SEQ_1_2_0  =>  CHAN_BOND_SEQ_1_2_0_BINARY,
	CHAN_BOND_SEQ_1_2_1  =>  CHAN_BOND_SEQ_1_2_1_BINARY,
	CHAN_BOND_SEQ_1_3_0  =>  CHAN_BOND_SEQ_1_3_0_BINARY,
	CHAN_BOND_SEQ_1_3_1  =>  CHAN_BOND_SEQ_1_3_1_BINARY,
	CHAN_BOND_SEQ_1_4_0  =>  CHAN_BOND_SEQ_1_4_0_BINARY,
	CHAN_BOND_SEQ_1_4_1  =>  CHAN_BOND_SEQ_1_4_1_BINARY,
	CHAN_BOND_SEQ_1_ENABLE_0  =>  CHAN_BOND_SEQ_1_ENABLE_0_BINARY,
	CHAN_BOND_SEQ_1_ENABLE_1  =>  CHAN_BOND_SEQ_1_ENABLE_1_BINARY,
	CHAN_BOND_SEQ_2_1_0  =>  CHAN_BOND_SEQ_2_1_0_BINARY,
	CHAN_BOND_SEQ_2_1_1  =>  CHAN_BOND_SEQ_2_1_1_BINARY,
	CHAN_BOND_SEQ_2_2_0  =>  CHAN_BOND_SEQ_2_2_0_BINARY,
	CHAN_BOND_SEQ_2_2_1  =>  CHAN_BOND_SEQ_2_2_1_BINARY,
	CHAN_BOND_SEQ_2_3_0  =>  CHAN_BOND_SEQ_2_3_0_BINARY,
	CHAN_BOND_SEQ_2_3_1  =>  CHAN_BOND_SEQ_2_3_1_BINARY,
	CHAN_BOND_SEQ_2_4_0  =>  CHAN_BOND_SEQ_2_4_0_BINARY,
	CHAN_BOND_SEQ_2_4_1  =>  CHAN_BOND_SEQ_2_4_1_BINARY,
	CHAN_BOND_SEQ_2_ENABLE_0  =>  CHAN_BOND_SEQ_2_ENABLE_0_BINARY,
	CHAN_BOND_SEQ_2_ENABLE_1  =>  CHAN_BOND_SEQ_2_ENABLE_1_BINARY,
	CHAN_BOND_SEQ_2_USE_0  =>  CHAN_BOND_SEQ_2_USE_0_BINARY,
	CHAN_BOND_SEQ_2_USE_1  =>  CHAN_BOND_SEQ_2_USE_1_BINARY,
	CHAN_BOND_SEQ_LEN_0  =>  CHAN_BOND_SEQ_LEN_0_BINARY,
	CHAN_BOND_SEQ_LEN_1  =>  CHAN_BOND_SEQ_LEN_1_BINARY,
	CLK25_DIVIDER  =>  CLK25_DIVIDER_BINARY,
	CLKINDC_B  =>  CLKINDC_B_BINARY,
	CLKRCV_TRST  =>  CLKRCV_TRST_BINARY,
	CLK_CORRECT_USE_0  =>  CLK_CORRECT_USE_0_BINARY,
	CLK_CORRECT_USE_1  =>  CLK_CORRECT_USE_1_BINARY,
	CLK_COR_ADJ_LEN_0  =>  CLK_COR_ADJ_LEN_0_BINARY,
	CLK_COR_ADJ_LEN_1  =>  CLK_COR_ADJ_LEN_1_BINARY,
	CLK_COR_DET_LEN_0  =>  CLK_COR_DET_LEN_0_BINARY,
	CLK_COR_DET_LEN_1  =>  CLK_COR_DET_LEN_1_BINARY,
	CLK_COR_INSERT_IDLE_FLAG_0  =>  CLK_COR_INSERT_IDLE_FLAG_0_BINARY,
	CLK_COR_INSERT_IDLE_FLAG_1  =>  CLK_COR_INSERT_IDLE_FLAG_1_BINARY,
	CLK_COR_KEEP_IDLE_0  =>  CLK_COR_KEEP_IDLE_0_BINARY,
	CLK_COR_KEEP_IDLE_1  =>  CLK_COR_KEEP_IDLE_1_BINARY,
	CLK_COR_MAX_LAT_0  =>  CLK_COR_MAX_LAT_0_BINARY,
	CLK_COR_MAX_LAT_1  =>  CLK_COR_MAX_LAT_1_BINARY,
	CLK_COR_MIN_LAT_0  =>  CLK_COR_MIN_LAT_0_BINARY,
	CLK_COR_MIN_LAT_1  =>  CLK_COR_MIN_LAT_1_BINARY,
	CLK_COR_PRECEDENCE_0  =>  CLK_COR_PRECEDENCE_0_BINARY,
	CLK_COR_PRECEDENCE_1  =>  CLK_COR_PRECEDENCE_1_BINARY,
	CLK_COR_REPEAT_WAIT_0  =>  CLK_COR_REPEAT_WAIT_0_BINARY,
	CLK_COR_REPEAT_WAIT_1  =>  CLK_COR_REPEAT_WAIT_1_BINARY,
	CLK_COR_SEQ_1_1_0  =>  CLK_COR_SEQ_1_1_0_BINARY,
	CLK_COR_SEQ_1_1_1  =>  CLK_COR_SEQ_1_1_1_BINARY,
	CLK_COR_SEQ_1_2_0  =>  CLK_COR_SEQ_1_2_0_BINARY,
	CLK_COR_SEQ_1_2_1  =>  CLK_COR_SEQ_1_2_1_BINARY,
	CLK_COR_SEQ_1_3_0  =>  CLK_COR_SEQ_1_3_0_BINARY,
	CLK_COR_SEQ_1_3_1  =>  CLK_COR_SEQ_1_3_1_BINARY,
	CLK_COR_SEQ_1_4_0  =>  CLK_COR_SEQ_1_4_0_BINARY,
	CLK_COR_SEQ_1_4_1  =>  CLK_COR_SEQ_1_4_1_BINARY,
	CLK_COR_SEQ_1_ENABLE_0  =>  CLK_COR_SEQ_1_ENABLE_0_BINARY,
	CLK_COR_SEQ_1_ENABLE_1  =>  CLK_COR_SEQ_1_ENABLE_1_BINARY,
	CLK_COR_SEQ_2_1_0  =>  CLK_COR_SEQ_2_1_0_BINARY,
	CLK_COR_SEQ_2_1_1  =>  CLK_COR_SEQ_2_1_1_BINARY,
	CLK_COR_SEQ_2_2_0  =>  CLK_COR_SEQ_2_2_0_BINARY,
	CLK_COR_SEQ_2_2_1  =>  CLK_COR_SEQ_2_2_1_BINARY,
	CLK_COR_SEQ_2_3_0  =>  CLK_COR_SEQ_2_3_0_BINARY,
	CLK_COR_SEQ_2_3_1  =>  CLK_COR_SEQ_2_3_1_BINARY,
	CLK_COR_SEQ_2_4_0  =>  CLK_COR_SEQ_2_4_0_BINARY,
	CLK_COR_SEQ_2_4_1  =>  CLK_COR_SEQ_2_4_1_BINARY,
	CLK_COR_SEQ_2_ENABLE_0  =>  CLK_COR_SEQ_2_ENABLE_0_BINARY,
	CLK_COR_SEQ_2_ENABLE_1  =>  CLK_COR_SEQ_2_ENABLE_1_BINARY,
	CLK_COR_SEQ_2_USE_0  =>  CLK_COR_SEQ_2_USE_0_BINARY,
	CLK_COR_SEQ_2_USE_1  =>  CLK_COR_SEQ_2_USE_1_BINARY,
	CM_TRIM_0  =>  CM_TRIM_0_BINARY,
	CM_TRIM_1  =>  CM_TRIM_1_BINARY,
	COMMA_10B_ENABLE_0  =>  COMMA_10B_ENABLE_0_BINARY,
	COMMA_10B_ENABLE_1  =>  COMMA_10B_ENABLE_1_BINARY,
	COMMA_DOUBLE_0  =>  COMMA_DOUBLE_0_BINARY,
	COMMA_DOUBLE_1  =>  COMMA_DOUBLE_1_BINARY,
	COM_BURST_VAL_0  =>  COM_BURST_VAL_0_BINARY,
	COM_BURST_VAL_1  =>  COM_BURST_VAL_1_BINARY,
	DEC_MCOMMA_DETECT_0  =>  DEC_MCOMMA_DETECT_0_BINARY,
	DEC_MCOMMA_DETECT_1  =>  DEC_MCOMMA_DETECT_1_BINARY,
	DEC_PCOMMA_DETECT_0  =>  DEC_PCOMMA_DETECT_0_BINARY,
	DEC_PCOMMA_DETECT_1  =>  DEC_PCOMMA_DETECT_1_BINARY,
	DEC_VALID_COMMA_ONLY_0  =>  DEC_VALID_COMMA_ONLY_0_BINARY,
	DEC_VALID_COMMA_ONLY_1  =>  DEC_VALID_COMMA_ONLY_1_BINARY,
	DFE_CAL_TIME  =>  DFE_CAL_TIME_BINARY,
	DFE_CFG_0  =>  DFE_CFG_0_BINARY,
	DFE_CFG_1  =>  DFE_CFG_1_BINARY,
	GEARBOX_ENDEC_0  =>  GEARBOX_ENDEC_0_BINARY,
	GEARBOX_ENDEC_1  =>  GEARBOX_ENDEC_1_BINARY,
	MCOMMA_10B_VALUE_0  =>  MCOMMA_10B_VALUE_0_BINARY,
	MCOMMA_10B_VALUE_1  =>  MCOMMA_10B_VALUE_1_BINARY,
	MCOMMA_DETECT_0  =>  MCOMMA_DETECT_0_BINARY,
	MCOMMA_DETECT_1  =>  MCOMMA_DETECT_1_BINARY,
	OOBDETECT_THRESHOLD_0  =>  OOBDETECT_THRESHOLD_0_BINARY,
	OOBDETECT_THRESHOLD_1  =>  OOBDETECT_THRESHOLD_1_BINARY,
	OOB_CLK_DIVIDER  =>  OOB_CLK_DIVIDER_BINARY,
	OVERSAMPLE_MODE  =>  OVERSAMPLE_MODE_BINARY,
	PCI_EXPRESS_MODE_0  =>  PCI_EXPRESS_MODE_0_BINARY,
	PCI_EXPRESS_MODE_1  =>  PCI_EXPRESS_MODE_1_BINARY,
	PCOMMA_10B_VALUE_0  =>  PCOMMA_10B_VALUE_0_BINARY,
	PCOMMA_10B_VALUE_1  =>  PCOMMA_10B_VALUE_1_BINARY,
	PCOMMA_DETECT_0  =>  PCOMMA_DETECT_0_BINARY,
	PCOMMA_DETECT_1  =>  PCOMMA_DETECT_1_BINARY,
        PLL_COM_CFG  =>  PLL_COM_CFG_BINARY,
	PLL_CP_CFG  =>  PLL_CP_CFG_BINARY,
	PLL_DIVSEL_FB  =>  PLL_DIVSEL_FB_BINARY,
	PLL_DIVSEL_REF  =>  PLL_DIVSEL_REF_BINARY,
	PLL_FB_DCCEN  =>  PLL_FB_DCCEN_BINARY,
        PLL_LKDET_CFG  =>  PLL_LKDET_CFG_BINARY,
	PLL_RXDIVSEL_OUT_0  =>  PLL_RXDIVSEL_OUT_0_BINARY,
	PLL_RXDIVSEL_OUT_1  =>  PLL_RXDIVSEL_OUT_1_BINARY,
	PLL_SATA_0  =>  PLL_SATA_0_BINARY,
	PLL_SATA_1  =>  PLL_SATA_1_BINARY,
        PLL_TDCC_CFG  =>  PLL_TDCC_CFG_BINARY,
	PLL_TXDIVSEL_OUT_0  =>  PLL_TXDIVSEL_OUT_0_BINARY,
	PLL_TXDIVSEL_OUT_1  =>  PLL_TXDIVSEL_OUT_1_BINARY,
	PMA_CDR_SCAN_0  =>  PMA_CDR_SCAN_0_BINARY,
	PMA_CDR_SCAN_1  =>  PMA_CDR_SCAN_1_BINARY,
        PMA_COM_CFG  =>  PMA_COM_CFG_BINARY,
	PMA_RXSYNC_CFG_0  =>  PMA_RXSYNC_CFG_0_BINARY,
	PMA_RXSYNC_CFG_1  =>  PMA_RXSYNC_CFG_1_BINARY,
	PMA_RX_CFG_0  =>  PMA_RX_CFG_0_BINARY,
	PMA_RX_CFG_1  =>  PMA_RX_CFG_1_BINARY,
	PMA_TX_CFG_0  =>  PMA_TX_CFG_0_BINARY,
	PMA_TX_CFG_1  =>  PMA_TX_CFG_1_BINARY,
	PRBS_ERR_THRESHOLD_0  =>  PRBS_ERR_THRESHOLD_0_BINARY,
	PRBS_ERR_THRESHOLD_1  =>  PRBS_ERR_THRESHOLD_1_BINARY,
	RCV_TERM_GND_0  =>  RCV_TERM_GND_0_BINARY,
	RCV_TERM_GND_1  =>  RCV_TERM_GND_1_BINARY,
	RCV_TERM_VTTRX_0  =>  RCV_TERM_VTTRX_0_BINARY,
	RCV_TERM_VTTRX_1  =>  RCV_TERM_VTTRX_1_BINARY,
	RXGEARBOX_USE_0  =>  RXGEARBOX_USE_0_BINARY,
	RXGEARBOX_USE_1  =>  RXGEARBOX_USE_1_BINARY,
	RX_BUFFER_USE_0  =>  RX_BUFFER_USE_0_BINARY,
	RX_BUFFER_USE_1  =>  RX_BUFFER_USE_1_BINARY,
	RX_DECODE_SEQ_MATCH_0  =>  RX_DECODE_SEQ_MATCH_0_BINARY,
	RX_DECODE_SEQ_MATCH_1  =>  RX_DECODE_SEQ_MATCH_1_BINARY,
	RX_EN_IDLE_HOLD_CDR  =>  RX_EN_IDLE_HOLD_CDR_BINARY,
	RX_EN_IDLE_HOLD_DFE_0  =>  RX_EN_IDLE_HOLD_DFE_0_BINARY,
	RX_EN_IDLE_HOLD_DFE_1  =>  RX_EN_IDLE_HOLD_DFE_1_BINARY,
	RX_EN_IDLE_RESET_BUF_0  =>  RX_EN_IDLE_RESET_BUF_0_BINARY,
	RX_EN_IDLE_RESET_BUF_1  =>  RX_EN_IDLE_RESET_BUF_1_BINARY,
	RX_EN_IDLE_RESET_FR  =>  RX_EN_IDLE_RESET_FR_BINARY,
	RX_EN_IDLE_RESET_PH  =>  RX_EN_IDLE_RESET_PH_BINARY,
	RX_IDLE_HI_CNT_0  =>  RX_IDLE_HI_CNT_0_BINARY,
	RX_IDLE_HI_CNT_1  =>  RX_IDLE_HI_CNT_1_BINARY,
	RX_IDLE_LO_CNT_0  =>  RX_IDLE_LO_CNT_0_BINARY,
	RX_IDLE_LO_CNT_1  =>  RX_IDLE_LO_CNT_1_BINARY,
	RX_LOSS_OF_SYNC_FSM_0  =>  RX_LOSS_OF_SYNC_FSM_0_BINARY,
	RX_LOSS_OF_SYNC_FSM_1  =>  RX_LOSS_OF_SYNC_FSM_1_BINARY,
	RX_LOS_INVALID_INCR_0  =>  RX_LOS_INVALID_INCR_0_BINARY,
	RX_LOS_INVALID_INCR_1  =>  RX_LOS_INVALID_INCR_1_BINARY,
	RX_LOS_THRESHOLD_0  =>  RX_LOS_THRESHOLD_0_BINARY,
	RX_LOS_THRESHOLD_1  =>  RX_LOS_THRESHOLD_1_BINARY,
	RX_SLIDE_MODE_0  =>  RX_SLIDE_MODE_0_BINARY,
	RX_SLIDE_MODE_1  =>  RX_SLIDE_MODE_1_BINARY,
	RX_STATUS_FMT_0  =>  RX_STATUS_FMT_0_BINARY,
	RX_STATUS_FMT_1  =>  RX_STATUS_FMT_1_BINARY,
	RX_XCLK_SEL_0  =>  RX_XCLK_SEL_0_BINARY,
	RX_XCLK_SEL_1  =>  RX_XCLK_SEL_1_BINARY,
	SATA_BURST_VAL_0  =>  SATA_BURST_VAL_0_BINARY,
	SATA_BURST_VAL_1  =>  SATA_BURST_VAL_1_BINARY,
	SATA_IDLE_VAL_0  =>  SATA_IDLE_VAL_0_BINARY,
	SATA_IDLE_VAL_1  =>  SATA_IDLE_VAL_1_BINARY,
	SATA_MAX_BURST_0  =>  SATA_MAX_BURST_0_BINARY,
	SATA_MAX_BURST_1  =>  SATA_MAX_BURST_1_BINARY,
	SATA_MAX_INIT_0  =>  SATA_MAX_INIT_0_BINARY,
	SATA_MAX_INIT_1  =>  SATA_MAX_INIT_1_BINARY,
	SATA_MAX_WAKE_0  =>  SATA_MAX_WAKE_0_BINARY,
	SATA_MAX_WAKE_1  =>  SATA_MAX_WAKE_1_BINARY,
	SATA_MIN_BURST_0  =>  SATA_MIN_BURST_0_BINARY,
	SATA_MIN_BURST_1  =>  SATA_MIN_BURST_1_BINARY,
	SATA_MIN_INIT_0  =>  SATA_MIN_INIT_0_BINARY,
	SATA_MIN_INIT_1  =>  SATA_MIN_INIT_1_BINARY,
	SATA_MIN_WAKE_0  =>  SATA_MIN_WAKE_0_BINARY,
	SATA_MIN_WAKE_1  =>  SATA_MIN_WAKE_1_BINARY,
	SIM_GTXRESET_SPEEDUP  =>  SIM_GTXRESET_SPEEDUP_BINARY,
	SIM_PLL_PERDIV2  =>  SIM_PLL_PERDIV2_BINARY,
	SIM_RECEIVER_DETECT_PASS_0  =>  SIM_RECEIVER_DETECT_PASS_0_BINARY,
	SIM_RECEIVER_DETECT_PASS_1  =>  SIM_RECEIVER_DETECT_PASS_1_BINARY,
	TERMINATION_CTRL  =>  TERMINATION_CTRL_BINARY,
	TERMINATION_IMP_0  =>  TERMINATION_IMP_0_BINARY,
	TERMINATION_IMP_1  =>  TERMINATION_IMP_1_BINARY,
	TERMINATION_OVRD  =>  TERMINATION_OVRD_BINARY,
	TRANS_TIME_FROM_P2_0  =>  TRANS_TIME_FROM_P2_0_BINARY,
	TRANS_TIME_FROM_P2_1  =>  TRANS_TIME_FROM_P2_1_BINARY,
	TRANS_TIME_NON_P2_0  =>  TRANS_TIME_NON_P2_0_BINARY,
	TRANS_TIME_NON_P2_1  =>  TRANS_TIME_NON_P2_1_BINARY,
	TRANS_TIME_TO_P2_0  =>  TRANS_TIME_TO_P2_0_BINARY,
	TRANS_TIME_TO_P2_1  =>  TRANS_TIME_TO_P2_1_BINARY,
	TXGEARBOX_USE_0  =>  TXGEARBOX_USE_0_BINARY,
	TXGEARBOX_USE_1  =>  TXGEARBOX_USE_1_BINARY,
	TXRX_INVERT_0  =>  TXRX_INVERT_0_BINARY,
	TXRX_INVERT_1  =>  TXRX_INVERT_1_BINARY,
	TX_BUFFER_USE_0  =>  TX_BUFFER_USE_0_BINARY,
	TX_BUFFER_USE_1  =>  TX_BUFFER_USE_1_BINARY,
       	TX_DETECT_RX_CFG_0  =>  TX_DETECT_RX_CFG_0_BINARY,
	TX_DETECT_RX_CFG_1  =>  TX_DETECT_RX_CFG_1_BINARY,
	TX_IDLE_DELAY_0  =>  TX_IDLE_DELAY_0_BINARY,
	TX_IDLE_DELAY_1  =>  TX_IDLE_DELAY_1_BINARY,
	TX_XCLK_SEL_0  =>  TX_XCLK_SEL_0_BINARY,
	TX_XCLK_SEL_1  =>  TX_XCLK_SEL_1_BINARY,

	DFECLKDLYADJMONITOR0  =>  DFECLKDLYADJMONITOR0_outdelay,
	DFECLKDLYADJMONITOR1  =>  DFECLKDLYADJMONITOR1_outdelay,
	DFEEYEDACMONITOR0  =>  DFEEYEDACMONITOR0_outdelay,
	DFEEYEDACMONITOR1  =>  DFEEYEDACMONITOR1_outdelay,
	DFESENSCAL0  =>  DFESENSCAL0_outdelay,
	DFESENSCAL1  =>  DFESENSCAL1_outdelay,
	DFETAP1MONITOR0  =>  DFETAP1MONITOR0_outdelay,
	DFETAP1MONITOR1  =>  DFETAP1MONITOR1_outdelay,
	DFETAP2MONITOR0  =>  DFETAP2MONITOR0_outdelay,
	DFETAP2MONITOR1  =>  DFETAP2MONITOR1_outdelay,
	DFETAP3MONITOR0  =>  DFETAP3MONITOR0_outdelay,
	DFETAP3MONITOR1  =>  DFETAP3MONITOR1_outdelay,
	DFETAP4MONITOR0  =>  DFETAP4MONITOR0_outdelay,
	DFETAP4MONITOR1  =>  DFETAP4MONITOR1_outdelay,
	DO  =>  DO_outdelay,
	DRDY  =>  DRDY_outdelay,
	PHYSTATUS0  =>  PHYSTATUS0_outdelay,
	PHYSTATUS1  =>  PHYSTATUS1_outdelay,
	PLLLKDET  =>  PLLLKDET_outdelay,
	REFCLKOUT  =>  REFCLKOUT_outdelay,
	RESETDONE0  =>  RESETDONE0_outdelay,
	RESETDONE1  =>  RESETDONE1_outdelay,
	RXBUFSTATUS0  =>  RXBUFSTATUS0_outdelay,
	RXBUFSTATUS1  =>  RXBUFSTATUS1_outdelay,
	RXBYTEISALIGNED0  =>  RXBYTEISALIGNED0_outdelay,
	RXBYTEISALIGNED1  =>  RXBYTEISALIGNED1_outdelay,
	RXBYTEREALIGN0  =>  RXBYTEREALIGN0_outdelay,
	RXBYTEREALIGN1  =>  RXBYTEREALIGN1_outdelay,
	RXCHANBONDSEQ0  =>  RXCHANBONDSEQ0_outdelay,
	RXCHANBONDSEQ1  =>  RXCHANBONDSEQ1_outdelay,
	RXCHANISALIGNED0  =>  RXCHANISALIGNED0_outdelay,
	RXCHANISALIGNED1  =>  RXCHANISALIGNED1_outdelay,
	RXCHANREALIGN0  =>  RXCHANREALIGN0_outdelay,
	RXCHANREALIGN1  =>  RXCHANREALIGN1_outdelay,
	RXCHARISCOMMA0  =>  RXCHARISCOMMA0_outdelay,
	RXCHARISCOMMA1  =>  RXCHARISCOMMA1_outdelay,
	RXCHARISK0  =>  RXCHARISK0_outdelay,
	RXCHARISK1  =>  RXCHARISK1_outdelay,
	RXCHBONDO0  =>  RXCHBONDO0_outdelay,
	RXCHBONDO1  =>  RXCHBONDO1_outdelay,
	RXCLKCORCNT0  =>  RXCLKCORCNT0_outdelay,
	RXCLKCORCNT1  =>  RXCLKCORCNT1_outdelay,
	RXCOMMADET0  =>  RXCOMMADET0_outdelay,
	RXCOMMADET1  =>  RXCOMMADET1_outdelay,
	RXDATA0  =>  RXDATA0_outdelay,
	RXDATA1  =>  RXDATA1_outdelay,
	RXDATAVALID0  =>  RXDATAVALID0_outdelay,
	RXDATAVALID1  =>  RXDATAVALID1_outdelay,
	RXDISPERR0  =>  RXDISPERR0_outdelay,
	RXDISPERR1  =>  RXDISPERR1_outdelay,
	RXELECIDLE0  =>  RXELECIDLE0_outdelay,
	RXELECIDLE1  =>  RXELECIDLE1_outdelay,
	RXHEADER0  =>  RXHEADER0_outdelay,
	RXHEADER1  =>  RXHEADER1_outdelay,
	RXHEADERVALID0  =>  RXHEADERVALID0_outdelay,
	RXHEADERVALID1  =>  RXHEADERVALID1_outdelay,
	RXLOSSOFSYNC0  =>  RXLOSSOFSYNC0_outdelay,
	RXLOSSOFSYNC1  =>  RXLOSSOFSYNC1_outdelay,
	RXNOTINTABLE0  =>  RXNOTINTABLE0_outdelay,
	RXNOTINTABLE1  =>  RXNOTINTABLE1_outdelay,
	RXOVERSAMPLEERR0  =>  RXOVERSAMPLEERR0_outdelay,
	RXOVERSAMPLEERR1  =>  RXOVERSAMPLEERR1_outdelay,
	RXPRBSERR0  =>  RXPRBSERR0_outdelay,
	RXPRBSERR1  =>  RXPRBSERR1_outdelay,
	RXRECCLK0  =>  RXRECCLK0_outdelay,
	RXRECCLK1  =>  RXRECCLK1_outdelay,
	RXRUNDISP0  =>  RXRUNDISP0_outdelay,
	RXRUNDISP1  =>  RXRUNDISP1_outdelay,
	RXSTARTOFSEQ0  =>  RXSTARTOFSEQ0_outdelay,
	RXSTARTOFSEQ1  =>  RXSTARTOFSEQ1_outdelay,
	RXSTATUS0  =>  RXSTATUS0_outdelay,
	RXSTATUS1  =>  RXSTATUS1_outdelay,
	RXVALID0  =>  RXVALID0_outdelay,
	RXVALID1  =>  RXVALID1_outdelay,
	TXBUFSTATUS0  =>  TXBUFSTATUS0_outdelay,
	TXBUFSTATUS1  =>  TXBUFSTATUS1_outdelay,
	TXGEARBOXREADY0  =>  TXGEARBOXREADY0_outdelay,
	TXGEARBOXREADY1  =>  TXGEARBOXREADY1_outdelay,
	TXKERR0  =>  TXKERR0_outdelay,
	TXKERR1  =>  TXKERR1_outdelay,
	TXN0  =>  TXN0_outdelay,
	TXN1  =>  TXN1_outdelay,
	TXOUTCLK0  =>  TXOUTCLK0_outdelay,
	TXOUTCLK1  =>  TXOUTCLK1_outdelay,
	TXP0  =>  TXP0_outdelay,
	TXP1  =>  TXP1_outdelay,
	TXRUNDISP0  =>  TXRUNDISP0_outdelay,
	TXRUNDISP1  =>  TXRUNDISP1_outdelay,

	CLKIN  =>  CLKIN_indelay,
	DADDR  =>  DADDR_indelay,
	DCLK  =>  DCLK_indelay,
	DEN  =>  DEN_indelay,
	DFECLKDLYADJ0  =>  DFECLKDLYADJ0_indelay,
	DFECLKDLYADJ1  =>  DFECLKDLYADJ1_indelay,
	DFETAP10  =>  DFETAP10_indelay,
	DFETAP11  =>  DFETAP11_indelay,
	DFETAP20  =>  DFETAP20_indelay,
	DFETAP21  =>  DFETAP21_indelay,
	DFETAP30  =>  DFETAP30_indelay,
	DFETAP31  =>  DFETAP31_indelay,
	DFETAP40  =>  DFETAP40_indelay,
	DFETAP41  =>  DFETAP41_indelay,
	DI  =>  DI_indelay,
	DWE  =>  DWE_indelay,
	GSR  =>  GSR,
	GTXRESET  =>  GTXRESET_indelay,
	GTXTEST  =>  GTXTEST_indelay,
	INTDATAWIDTH  =>  INTDATAWIDTH_indelay,
	LOOPBACK0  =>  LOOPBACK0_indelay,
	LOOPBACK1  =>  LOOPBACK1_indelay,
	PLLLKDETEN  =>  PLLLKDETEN_indelay,
	PLLPOWERDOWN  =>  PLLPOWERDOWN_indelay,
	PRBSCNTRESET0  =>  PRBSCNTRESET0_indelay,
	PRBSCNTRESET1  =>  PRBSCNTRESET1_indelay,
	REFCLKPWRDNB  =>  REFCLKPWRDNB_indelay,
	RXBUFRESET0  =>  RXBUFRESET0_indelay,
	RXBUFRESET1  =>  RXBUFRESET1_indelay,
	RXCDRRESET0  =>  RXCDRRESET0_indelay,
	RXCDRRESET1  =>  RXCDRRESET1_indelay,
	RXCHBONDI0  =>  RXCHBONDI0_indelay,
	RXCHBONDI1  =>  RXCHBONDI1_indelay,
	RXCOMMADETUSE0  =>  RXCOMMADETUSE0_indelay,
	RXCOMMADETUSE1  =>  RXCOMMADETUSE1_indelay,
	RXDATAWIDTH0  =>  RXDATAWIDTH0_indelay,
	RXDATAWIDTH1  =>  RXDATAWIDTH1_indelay,
	RXDEC8B10BUSE0  =>  RXDEC8B10BUSE0_indelay,
	RXDEC8B10BUSE1  =>  RXDEC8B10BUSE1_indelay,
	RXENCHANSYNC0  =>  RXENCHANSYNC0_indelay,
	RXENCHANSYNC1  =>  RXENCHANSYNC1_indelay,
	RXENEQB0  =>  RXENEQB0_indelay,
	RXENEQB1  =>  RXENEQB1_indelay,
	RXENMCOMMAALIGN0  =>  RXENMCOMMAALIGN0_indelay,
	RXENMCOMMAALIGN1  =>  RXENMCOMMAALIGN1_indelay,
	RXENPCOMMAALIGN0  =>  RXENPCOMMAALIGN0_indelay,
	RXENPCOMMAALIGN1  =>  RXENPCOMMAALIGN1_indelay,
	RXENPMAPHASEALIGN0  =>  RXENPMAPHASEALIGN0_indelay,
	RXENPMAPHASEALIGN1  =>  RXENPMAPHASEALIGN1_indelay,
	RXENPRBSTST0  =>  RXENPRBSTST0_indelay,
	RXENPRBSTST1  =>  RXENPRBSTST1_indelay,
	RXENSAMPLEALIGN0  =>  RXENSAMPLEALIGN0_indelay,
	RXENSAMPLEALIGN1  =>  RXENSAMPLEALIGN1_indelay,
	RXEQMIX0  =>  RXEQMIX0_indelay,
	RXEQMIX1  =>  RXEQMIX1_indelay,
	RXEQPOLE0  =>  RXEQPOLE0_indelay,
	RXEQPOLE1  =>  RXEQPOLE1_indelay,
	RXGEARBOXSLIP0  =>  RXGEARBOXSLIP0_indelay,
	RXGEARBOXSLIP1  =>  RXGEARBOXSLIP1_indelay,
	RXN0  =>  RXN0_indelay,
	RXN1  =>  RXN1_indelay,
	RXP0  =>  RXP0_indelay,
	RXP1  =>  RXP1_indelay,
	RXPMASETPHASE0  =>  RXPMASETPHASE0_indelay,
	RXPMASETPHASE1  =>  RXPMASETPHASE1_indelay,
	RXPOLARITY0  =>  RXPOLARITY0_indelay,
	RXPOLARITY1  =>  RXPOLARITY1_indelay,
	RXPOWERDOWN0  =>  RXPOWERDOWN0_indelay,
	RXPOWERDOWN1  =>  RXPOWERDOWN1_indelay,
	RXRESET0  =>  RXRESET0_indelay,
	RXRESET1  =>  RXRESET1_indelay,
	RXSLIDE0  =>  RXSLIDE0_indelay,
	RXSLIDE1  =>  RXSLIDE1_indelay,
	RXUSRCLK0  =>  RXUSRCLK0_indelay,
	RXUSRCLK1  =>  RXUSRCLK1_indelay,
	RXUSRCLK20  =>  RXUSRCLK20_indelay,
	RXUSRCLK21  =>  RXUSRCLK21_indelay,
	TXBUFDIFFCTRL0  =>  TXBUFDIFFCTRL0_indelay,
	TXBUFDIFFCTRL1  =>  TXBUFDIFFCTRL1_indelay,
	TXBYPASS8B10B0  =>  TXBYPASS8B10B0_indelay,
	TXBYPASS8B10B1  =>  TXBYPASS8B10B1_indelay,
	TXCHARDISPMODE0  =>  TXCHARDISPMODE0_indelay,
	TXCHARDISPMODE1  =>  TXCHARDISPMODE1_indelay,
	TXCHARDISPVAL0  =>  TXCHARDISPVAL0_indelay,
	TXCHARDISPVAL1  =>  TXCHARDISPVAL1_indelay,
	TXCHARISK0  =>  TXCHARISK0_indelay,
	TXCHARISK1  =>  TXCHARISK1_indelay,
	TXCOMSTART0  =>  TXCOMSTART0_indelay,
	TXCOMSTART1  =>  TXCOMSTART1_indelay,
	TXCOMTYPE0  =>  TXCOMTYPE0_indelay,
	TXCOMTYPE1  =>  TXCOMTYPE1_indelay,
	TXDATA0  =>  TXDATA0_indelay,
	TXDATA1  =>  TXDATA1_indelay,
	TXDATAWIDTH0  =>  TXDATAWIDTH0_indelay,
	TXDATAWIDTH1  =>  TXDATAWIDTH1_indelay,
	TXDETECTRX0  =>  TXDETECTRX0_indelay,
	TXDETECTRX1  =>  TXDETECTRX1_indelay,
	TXDIFFCTRL0  =>  TXDIFFCTRL0_indelay,
	TXDIFFCTRL1  =>  TXDIFFCTRL1_indelay,
	TXELECIDLE0  =>  TXELECIDLE0_indelay,
	TXELECIDLE1  =>  TXELECIDLE1_indelay,
	TXENC8B10BUSE0  =>  TXENC8B10BUSE0_indelay,
	TXENC8B10BUSE1  =>  TXENC8B10BUSE1_indelay,
	TXENPMAPHASEALIGN0  =>  TXENPMAPHASEALIGN0_indelay,
	TXENPMAPHASEALIGN1  =>  TXENPMAPHASEALIGN1_indelay,
	TXENPRBSTST0  =>  TXENPRBSTST0_indelay,
	TXENPRBSTST1  =>  TXENPRBSTST1_indelay,
	TXHEADER0  =>  TXHEADER0_indelay,
	TXHEADER1  =>  TXHEADER1_indelay,
	TXINHIBIT0  =>  TXINHIBIT0_indelay,
	TXINHIBIT1  =>  TXINHIBIT1_indelay,
	TXPMASETPHASE0  =>  TXPMASETPHASE0_indelay,
	TXPMASETPHASE1  =>  TXPMASETPHASE1_indelay,
	TXPOLARITY0  =>  TXPOLARITY0_indelay,
	TXPOLARITY1  =>  TXPOLARITY1_indelay,
	TXPOWERDOWN0  =>  TXPOWERDOWN0_indelay,
	TXPOWERDOWN1  =>  TXPOWERDOWN1_indelay,
	TXPREEMPHASIS0  =>  TXPREEMPHASIS0_indelay,
	TXPREEMPHASIS1  =>  TXPREEMPHASIS1_indelay,
	TXRESET0  =>  TXRESET0_indelay,
	TXRESET1  =>  TXRESET1_indelay,
	TXSEQUENCE0  =>  TXSEQUENCE0_indelay,
	TXSEQUENCE1  =>  TXSEQUENCE1_indelay,
	TXSTARTSEQ0  =>  TXSTARTSEQ0_indelay,
	TXSTARTSEQ1  =>  TXSTARTSEQ1_indelay,
	TXUSRCLK0  =>  TXUSRCLK0_indelay,
	TXUSRCLK1  =>  TXUSRCLK1_indelay,
	TXUSRCLK20  =>  TXUSRCLK20_indelay,
	TXUSRCLK21  =>  TXUSRCLK21_indelay
	);


	INIPROC : process
	begin
        case PLL_TXDIVSEL_OUT_0 is
           when   1  =>  PLL_TXDIVSEL_OUT_0_BINARY <= "00";
           when   2  =>  PLL_TXDIVSEL_OUT_0_BINARY <= "01";
           when   4  =>  PLL_TXDIVSEL_OUT_0_BINARY <= "10";
           when others  =>  assert FALSE report "Error : PLL_TXDIVSEL_OUT_0 is not in 1, 2, 4." severity error;
       end case;
       case PLL_RXDIVSEL_OUT_0 is
           when   1  =>  PLL_RXDIVSEL_OUT_0_BINARY <= "00";
           when   2  =>  PLL_RXDIVSEL_OUT_0_BINARY <= "01";
           when   4  =>  PLL_RXDIVSEL_OUT_0_BINARY <= "10";
           when others  =>  assert FALSE report "Error : PLL_RXDIVSEL_OUT_0 is not in 1, 2, 4." severity error;
       end case;
       case PLL_TXDIVSEL_OUT_1 is
           when   1  =>  PLL_TXDIVSEL_OUT_1_BINARY <= "00";
           when   2  =>  PLL_TXDIVSEL_OUT_1_BINARY <= "01";
           when   4  =>  PLL_TXDIVSEL_OUT_1_BINARY <= "10";
           when others  =>  assert FALSE report "Error : PLL_TXDIVSEL_OUT_1 is not in 1, 2, 4." severity error;
       end case;
       case PLL_RXDIVSEL_OUT_1 is
           when   1  =>  PLL_RXDIVSEL_OUT_1_BINARY <= "00";
           when   2  =>  PLL_RXDIVSEL_OUT_1_BINARY <= "01";
           when   4  =>  PLL_RXDIVSEL_OUT_1_BINARY <= "10";
           when others  =>  assert FALSE report "Error : PLL_RXDIVSEL_OUT_1 is not in 1, 2, 4." severity error;
       end case;
       case PLL_DIVSEL_FB is
           when   1  =>  PLL_DIVSEL_FB_BINARY <= "10000";
           when   2  =>  PLL_DIVSEL_FB_BINARY <= "00000";
           when   3  =>  PLL_DIVSEL_FB_BINARY <= "00001";
           when   4  =>  PLL_DIVSEL_FB_BINARY <= "00010";
           when   5  =>  PLL_DIVSEL_FB_BINARY <= "00011";
           when   8  =>  PLL_DIVSEL_FB_BINARY <= "00110";
           when   10  =>  PLL_DIVSEL_FB_BINARY <= "00111";
           when others  =>  assert FALSE report "Error : PLL_DIVSEL_FB is not in 1, 2, 3, 4, 5, 8, 10." severity error;
       end case;
       case PLL_DIVSEL_REF is
           when   1  =>  PLL_DIVSEL_REF_BINARY <= "010000";
           when   2  =>  PLL_DIVSEL_REF_BINARY <= "000000";
           when   3  =>  PLL_DIVSEL_REF_BINARY <= "000001";
           when   4  =>  PLL_DIVSEL_REF_BINARY <= "000010";
           when   5  =>  PLL_DIVSEL_REF_BINARY <= "000011";
           when   6  =>  PLL_DIVSEL_REF_BINARY <= "000101";
           when   8  =>  PLL_DIVSEL_REF_BINARY <= "000110";
           when   10  =>  PLL_DIVSEL_REF_BINARY <= "000111";
           when   12  =>  PLL_DIVSEL_REF_BINARY <= "001101";
           when   16  =>  PLL_DIVSEL_REF_BINARY <= "001110";
           when   20  =>  PLL_DIVSEL_REF_BINARY <= "001111";
           when others  =>  assert FALSE report "Error : PLL_DIVSEL_REF is not in 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20." severity error;
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
       case OOB_CLK_DIVIDER is
           when   1  =>  OOB_CLK_DIVIDER_BINARY <= "000";
           when   2  =>  OOB_CLK_DIVIDER_BINARY <= "001";
           when   4  =>  OOB_CLK_DIVIDER_BINARY <= "010";
           when   6  =>  OOB_CLK_DIVIDER_BINARY <= "011";
           when   8  =>  OOB_CLK_DIVIDER_BINARY <= "100";
           when   10  =>  OOB_CLK_DIVIDER_BINARY <= "101";
           when   12  =>  OOB_CLK_DIVIDER_BINARY <= "110";
           when   14  =>  OOB_CLK_DIVIDER_BINARY <= "111";
           when others  =>  assert FALSE report "Error : OOB_CLK_DIVIDER is not in 1, 2, 4, 6, 8, 10, 12, 14." severity error;
       end case;

          if (OOBDETECT_THRESHOLD_0 = "110") then
           OOBDETECT_THRESHOLD_0_BINARY <= "110";
        elsif (OOBDETECT_THRESHOLD_0 = "111") then
           OOBDETECT_THRESHOLD_0_BINARY <= "111";
        else
           assert FALSE report "Warning : OOBDETECT_THRESHOLD_0 is not in 110, 111." severity warning;
        end if;

        if (OOBDETECT_THRESHOLD_1 = "110") then
           OOBDETECT_THRESHOLD_1_BINARY <= "110";
        elsif (OOBDETECT_THRESHOLD_1 = "111") then
           OOBDETECT_THRESHOLD_1_BINARY <= "111";
        else
           assert FALSE report "Warning : OOBDETECT_THRESHOLD_1 is not in 110, 111." severity warning;
        end if;
                   
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
       case TERMINATION_IMP_0 is
           when   50  =>  TERMINATION_IMP_0_BINARY <= '0';
           when   75  =>  TERMINATION_IMP_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TERMINATION_IMP_0 is not in 50, 75." severity error;
       end case;
       case TERMINATION_IMP_1 is
           when   50  =>  TERMINATION_IMP_1_BINARY <= '0';
           when   75  =>  TERMINATION_IMP_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TERMINATION_IMP_1 is not in 50, 75." severity error;
       end case;
       case TERMINATION_OVRD is
           when FALSE   =>  TERMINATION_OVRD_BINARY <= '0';
           when TRUE    =>  TERMINATION_OVRD_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TERMINATION_OVRD is neither TRUE nor FALSE." severity error;
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
       case CLKINDC_B is
           when FALSE   =>  CLKINDC_B_BINARY <= '0';
           when TRUE    =>  CLKINDC_B_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLKINDC_B is neither TRUE nor FALSE." severity error;
       end case;
       case PCOMMA_DETECT_0 is
           when FALSE   =>  PCOMMA_DETECT_0_BINARY <= '0';
           when TRUE    =>  PCOMMA_DETECT_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
       end case;
       case MCOMMA_DETECT_0 is
           when FALSE   =>  MCOMMA_DETECT_0_BINARY <= '0';
           when TRUE    =>  MCOMMA_DETECT_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : MCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
       end case;
       case COMMA_DOUBLE_0 is
           when FALSE   =>  COMMA_DOUBLE_0_BINARY <= '0';
           when TRUE    =>  COMMA_DOUBLE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : COMMA_DOUBLE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case ALIGN_COMMA_WORD_0 is
           when   1  =>  ALIGN_COMMA_WORD_0_BINARY <= '0';
           when   2  =>  ALIGN_COMMA_WORD_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : ALIGN_COMMA_WORD_0 is not in 1, 2." severity error;
       end case;
       case DEC_PCOMMA_DETECT_0 is
           when FALSE   =>  DEC_PCOMMA_DETECT_0_BINARY <= '0';
           when TRUE    =>  DEC_PCOMMA_DETECT_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DEC_PCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
       end case;
       case DEC_MCOMMA_DETECT_0 is
           when FALSE   =>  DEC_MCOMMA_DETECT_0_BINARY <= '0';
           when TRUE    =>  DEC_MCOMMA_DETECT_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DEC_MCOMMA_DETECT_0 is neither TRUE nor FALSE." severity error;
       end case;
       case DEC_VALID_COMMA_ONLY_0 is
           when FALSE   =>  DEC_VALID_COMMA_ONLY_0_BINARY <= '0';
           when TRUE    =>  DEC_VALID_COMMA_ONLY_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DEC_VALID_COMMA_ONLY_0 is neither TRUE nor FALSE." severity error;
       end case;
       case PCOMMA_DETECT_1 is
           when FALSE   =>  PCOMMA_DETECT_1_BINARY <= '0';
           when TRUE    =>  PCOMMA_DETECT_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
       end case;
       case MCOMMA_DETECT_1 is
           when FALSE   =>  MCOMMA_DETECT_1_BINARY <= '0';
           when TRUE    =>  MCOMMA_DETECT_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : MCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
       end case;
       case COMMA_DOUBLE_1 is
           when FALSE   =>  COMMA_DOUBLE_1_BINARY <= '0';
           when TRUE    =>  COMMA_DOUBLE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : COMMA_DOUBLE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case ALIGN_COMMA_WORD_1 is
           when   1  =>  ALIGN_COMMA_WORD_1_BINARY <= '0';
           when   2  =>  ALIGN_COMMA_WORD_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : ALIGN_COMMA_WORD_1 is not in 1, 2." severity error;
       end case;
       case DEC_PCOMMA_DETECT_1 is
           when FALSE   =>  DEC_PCOMMA_DETECT_1_BINARY <= '0';
           when TRUE    =>  DEC_PCOMMA_DETECT_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DEC_PCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
       end case;
       case DEC_MCOMMA_DETECT_1 is
           when FALSE   =>  DEC_MCOMMA_DETECT_1_BINARY <= '0';
           when TRUE    =>  DEC_MCOMMA_DETECT_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DEC_MCOMMA_DETECT_1 is neither TRUE nor FALSE." severity error;
       end case;
       case DEC_VALID_COMMA_ONLY_1 is
           when FALSE   =>  DEC_VALID_COMMA_ONLY_1_BINARY <= '0';
           when TRUE    =>  DEC_VALID_COMMA_ONLY_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DEC_VALID_COMMA_ONLY_1 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_LOSS_OF_SYNC_FSM_0 is
           when FALSE   =>  RX_LOSS_OF_SYNC_FSM_0_BINARY <= '0';
           when TRUE    =>  RX_LOSS_OF_SYNC_FSM_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_LOSS_OF_SYNC_FSM_0 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_LOS_INVALID_INCR_0 is
           when   1  =>  RX_LOS_INVALID_INCR_0_BINARY <= "000";
           when   2  =>  RX_LOS_INVALID_INCR_0_BINARY <= "001";
           when   4  =>  RX_LOS_INVALID_INCR_0_BINARY <= "010";
           when   8  =>  RX_LOS_INVALID_INCR_0_BINARY <= "011";
           when   16  =>  RX_LOS_INVALID_INCR_0_BINARY <= "100";
           when   32  =>  RX_LOS_INVALID_INCR_0_BINARY <= "101";
           when   64  =>  RX_LOS_INVALID_INCR_0_BINARY <= "110";
           when   128  =>  RX_LOS_INVALID_INCR_0_BINARY <= "111";
           when others  =>  assert FALSE report "Error : RX_LOS_INVALID_INCR_0 is not in 1, 2, 4, 8, 16, 32, 64, 128." severity error;
       end case;
       case RX_LOS_THRESHOLD_0 is
           when   4  =>  RX_LOS_THRESHOLD_0_BINARY <= "000";
           when   8  =>  RX_LOS_THRESHOLD_0_BINARY <= "001";
           when   16  =>  RX_LOS_THRESHOLD_0_BINARY <= "010";
           when   32  =>  RX_LOS_THRESHOLD_0_BINARY <= "011";
           when   64  =>  RX_LOS_THRESHOLD_0_BINARY <= "100";
           when   128  =>  RX_LOS_THRESHOLD_0_BINARY <= "101";
           when   256  =>  RX_LOS_THRESHOLD_0_BINARY <= "110";
           when   512  =>  RX_LOS_THRESHOLD_0_BINARY <= "111";
           when others  =>  assert FALSE report "Error : RX_LOS_THRESHOLD_0 is not in 4, 8, 16, 32, 64, 128, 256, 512." severity error;
       end case;
       case RX_LOSS_OF_SYNC_FSM_1 is
           when FALSE   =>  RX_LOSS_OF_SYNC_FSM_1_BINARY <= '0';
           when TRUE    =>  RX_LOSS_OF_SYNC_FSM_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_LOSS_OF_SYNC_FSM_1 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_LOS_INVALID_INCR_1 is
           when   1  =>  RX_LOS_INVALID_INCR_1_BINARY <= "000";
           when   2  =>  RX_LOS_INVALID_INCR_1_BINARY <= "001";
           when   4  =>  RX_LOS_INVALID_INCR_1_BINARY <= "010";
           when   8  =>  RX_LOS_INVALID_INCR_1_BINARY <= "011";
           when   16  =>  RX_LOS_INVALID_INCR_1_BINARY <= "100";
           when   32  =>  RX_LOS_INVALID_INCR_1_BINARY <= "101";
           when   64  =>  RX_LOS_INVALID_INCR_1_BINARY <= "110";
           when   128  =>  RX_LOS_INVALID_INCR_1_BINARY <= "111";
           when others  =>  assert FALSE report "Error : RX_LOS_INVALID_INCR_1 is not in 1, 2, 4, 8, 16, 32, 64, 128." severity error;
       end case;
       case RX_LOS_THRESHOLD_1 is
           when   4  =>  RX_LOS_THRESHOLD_1_BINARY <= "000";
           when   8  =>  RX_LOS_THRESHOLD_1_BINARY <= "001";
           when   16  =>  RX_LOS_THRESHOLD_1_BINARY <= "010";
           when   32  =>  RX_LOS_THRESHOLD_1_BINARY <= "011";
           when   64  =>  RX_LOS_THRESHOLD_1_BINARY <= "100";
           when   128  =>  RX_LOS_THRESHOLD_1_BINARY <= "101";
           when   256  =>  RX_LOS_THRESHOLD_1_BINARY <= "110";
           when   512  =>  RX_LOS_THRESHOLD_1_BINARY <= "111";
           when others  =>  assert FALSE report "Error : RX_LOS_THRESHOLD_1 is not in 4, 8, 16, 32, 64, 128, 256, 512." severity error;
       end case;
       case RX_BUFFER_USE_0 is
           when FALSE   =>  RX_BUFFER_USE_0_BINARY <= '0';
           when TRUE    =>  RX_BUFFER_USE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_BUFFER_USE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_DECODE_SEQ_MATCH_0 is
           when FALSE   =>  RX_DECODE_SEQ_MATCH_0_BINARY <= '0';
           when TRUE    =>  RX_DECODE_SEQ_MATCH_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_DECODE_SEQ_MATCH_0 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_BUFFER_USE_1 is
           when FALSE   =>  RX_BUFFER_USE_1_BINARY <= '0';
           when TRUE    =>  RX_BUFFER_USE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_BUFFER_USE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_DECODE_SEQ_MATCH_1 is
           when FALSE   =>  RX_DECODE_SEQ_MATCH_1_BINARY <= '0';
           when TRUE    =>  RX_DECODE_SEQ_MATCH_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_DECODE_SEQ_MATCH_1 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_MIN_LAT_0 is
           when   3  =>  CLK_COR_MIN_LAT_0_BINARY <= "000011";
           when   4  =>  CLK_COR_MIN_LAT_0_BINARY <= "000100";
           when   5  =>  CLK_COR_MIN_LAT_0_BINARY <= "000101";
           when   6  =>  CLK_COR_MIN_LAT_0_BINARY <= "000110";
           when   7  =>  CLK_COR_MIN_LAT_0_BINARY <= "000111";
           when   8  =>  CLK_COR_MIN_LAT_0_BINARY <= "001000";
           when   9  =>  CLK_COR_MIN_LAT_0_BINARY <= "001001";
           when   10  =>  CLK_COR_MIN_LAT_0_BINARY <= "001010";
           when   11  =>  CLK_COR_MIN_LAT_0_BINARY <= "001011";
           when   12  =>  CLK_COR_MIN_LAT_0_BINARY <= "001100";
           when   13  =>  CLK_COR_MIN_LAT_0_BINARY <= "001101";
           when   14  =>  CLK_COR_MIN_LAT_0_BINARY <= "001110";
           when   15  =>  CLK_COR_MIN_LAT_0_BINARY <= "001111";
           when   16  =>  CLK_COR_MIN_LAT_0_BINARY <= "010000";
           when   17  =>  CLK_COR_MIN_LAT_0_BINARY <= "010001";
           when   18  =>  CLK_COR_MIN_LAT_0_BINARY <= "010010";
           when   19  =>  CLK_COR_MIN_LAT_0_BINARY <= "010011";
           when   20  =>  CLK_COR_MIN_LAT_0_BINARY <= "010100";
           when   21  =>  CLK_COR_MIN_LAT_0_BINARY <= "010101";
           when   22  =>  CLK_COR_MIN_LAT_0_BINARY <= "010110";
           when   23  =>  CLK_COR_MIN_LAT_0_BINARY <= "010111";
           when   24  =>  CLK_COR_MIN_LAT_0_BINARY <= "011000";
           when   25  =>  CLK_COR_MIN_LAT_0_BINARY <= "011001";
           when   26  =>  CLK_COR_MIN_LAT_0_BINARY <= "011010";
           when   27  =>  CLK_COR_MIN_LAT_0_BINARY <= "011011";
           when   28  =>  CLK_COR_MIN_LAT_0_BINARY <= "011100";
           when   29  =>  CLK_COR_MIN_LAT_0_BINARY <= "011101";
           when   30  =>  CLK_COR_MIN_LAT_0_BINARY <= "011110";
           when   31  =>  CLK_COR_MIN_LAT_0_BINARY <= "011111";
           when   32  =>  CLK_COR_MIN_LAT_0_BINARY <= "100000";
           when   33  =>  CLK_COR_MIN_LAT_0_BINARY <= "100001";
           when   34  =>  CLK_COR_MIN_LAT_0_BINARY <= "100010";
           when   35  =>  CLK_COR_MIN_LAT_0_BINARY <= "100011";
           when   36  =>  CLK_COR_MIN_LAT_0_BINARY <= "100100";
           when   37  =>  CLK_COR_MIN_LAT_0_BINARY <= "100101";
           when   38  =>  CLK_COR_MIN_LAT_0_BINARY <= "100110";
           when   39  =>  CLK_COR_MIN_LAT_0_BINARY <= "100111";
           when   40  =>  CLK_COR_MIN_LAT_0_BINARY <= "101000";
           when   41  =>  CLK_COR_MIN_LAT_0_BINARY <= "101001";
           when   42  =>  CLK_COR_MIN_LAT_0_BINARY <= "101010";
           when   43  =>  CLK_COR_MIN_LAT_0_BINARY <= "101011";
           when   44  =>  CLK_COR_MIN_LAT_0_BINARY <= "101100";
           when   45  =>  CLK_COR_MIN_LAT_0_BINARY <= "101101";
           when   46  =>  CLK_COR_MIN_LAT_0_BINARY <= "101110";
           when   47  =>  CLK_COR_MIN_LAT_0_BINARY <= "101111";
           when   48  =>  CLK_COR_MIN_LAT_0_BINARY <= "110000";
           when others  =>  assert FALSE report "Error : CLK_COR_MIN_LAT_0 is not in range 3...48." severity error;
       end case;
       case CLK_COR_MAX_LAT_0 is
           when   3  =>  CLK_COR_MAX_LAT_0_BINARY <= "000011";
           when   4  =>  CLK_COR_MAX_LAT_0_BINARY <= "000100";
           when   5  =>  CLK_COR_MAX_LAT_0_BINARY <= "000101";
           when   6  =>  CLK_COR_MAX_LAT_0_BINARY <= "000110";
           when   7  =>  CLK_COR_MAX_LAT_0_BINARY <= "000111";
           when   8  =>  CLK_COR_MAX_LAT_0_BINARY <= "001000";
           when   9  =>  CLK_COR_MAX_LAT_0_BINARY <= "001001";
           when   10  =>  CLK_COR_MAX_LAT_0_BINARY <= "001010";
           when   11  =>  CLK_COR_MAX_LAT_0_BINARY <= "001011";
           when   12  =>  CLK_COR_MAX_LAT_0_BINARY <= "001100";
           when   13  =>  CLK_COR_MAX_LAT_0_BINARY <= "001101";
           when   14  =>  CLK_COR_MAX_LAT_0_BINARY <= "001110";
           when   15  =>  CLK_COR_MAX_LAT_0_BINARY <= "001111";
           when   16  =>  CLK_COR_MAX_LAT_0_BINARY <= "010000";
           when   17  =>  CLK_COR_MAX_LAT_0_BINARY <= "010001";
           when   18  =>  CLK_COR_MAX_LAT_0_BINARY <= "010010";
           when   19  =>  CLK_COR_MAX_LAT_0_BINARY <= "010011";
           when   20  =>  CLK_COR_MAX_LAT_0_BINARY <= "010100";
           when   21  =>  CLK_COR_MAX_LAT_0_BINARY <= "010101";
           when   22  =>  CLK_COR_MAX_LAT_0_BINARY <= "010110";
           when   23  =>  CLK_COR_MAX_LAT_0_BINARY <= "010111";
           when   24  =>  CLK_COR_MAX_LAT_0_BINARY <= "011000";
           when   25  =>  CLK_COR_MAX_LAT_0_BINARY <= "011001";
           when   26  =>  CLK_COR_MAX_LAT_0_BINARY <= "011010";
           when   27  =>  CLK_COR_MAX_LAT_0_BINARY <= "011011";
           when   28  =>  CLK_COR_MAX_LAT_0_BINARY <= "011100";
           when   29  =>  CLK_COR_MAX_LAT_0_BINARY <= "011101";
           when   30  =>  CLK_COR_MAX_LAT_0_BINARY <= "011110";
           when   31  =>  CLK_COR_MAX_LAT_0_BINARY <= "011111";
           when   32  =>  CLK_COR_MAX_LAT_0_BINARY <= "100000";
           when   33  =>  CLK_COR_MAX_LAT_0_BINARY <= "100001";
           when   34  =>  CLK_COR_MAX_LAT_0_BINARY <= "100010";
           when   35  =>  CLK_COR_MAX_LAT_0_BINARY <= "100011";
           when   36  =>  CLK_COR_MAX_LAT_0_BINARY <= "100100";
           when   37  =>  CLK_COR_MAX_LAT_0_BINARY <= "100101";
           when   38  =>  CLK_COR_MAX_LAT_0_BINARY <= "100110";
           when   39  =>  CLK_COR_MAX_LAT_0_BINARY <= "100111";
           when   40  =>  CLK_COR_MAX_LAT_0_BINARY <= "101000";
           when   41  =>  CLK_COR_MAX_LAT_0_BINARY <= "101001";
           when   42  =>  CLK_COR_MAX_LAT_0_BINARY <= "101010";
           when   43  =>  CLK_COR_MAX_LAT_0_BINARY <= "101011";
           when   44  =>  CLK_COR_MAX_LAT_0_BINARY <= "101100";
           when   45  =>  CLK_COR_MAX_LAT_0_BINARY <= "101101";
           when   46  =>  CLK_COR_MAX_LAT_0_BINARY <= "101110";
           when   47  =>  CLK_COR_MAX_LAT_0_BINARY <= "101111";
           when   48  =>  CLK_COR_MAX_LAT_0_BINARY <= "110000";
           when others  =>  assert FALSE report "Error : CLK_COR_MAX_LAT_0 is not in range 3...48." severity error;
       end case;
       case CLK_CORRECT_USE_0 is
           when FALSE   =>  CLK_CORRECT_USE_0_BINARY <= '0';
           when TRUE    =>  CLK_CORRECT_USE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_CORRECT_USE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_PRECEDENCE_0 is
           when FALSE   =>  CLK_COR_PRECEDENCE_0_BINARY <= '0';
           when TRUE    =>  CLK_COR_PRECEDENCE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_PRECEDENCE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_DET_LEN_0 is
           when   1  =>  CLK_COR_DET_LEN_0_BINARY <= "00";
           when   2  =>  CLK_COR_DET_LEN_0_BINARY <= "01";
           when   3  =>  CLK_COR_DET_LEN_0_BINARY <= "10";
           when   4  =>  CLK_COR_DET_LEN_0_BINARY <= "11";
           when others  =>  assert FALSE report "Error : CLK_COR_DET_LEN_0 is not in 1, 2, 3, 4." severity error;
       end case;
       case CLK_COR_ADJ_LEN_0 is
           when   1  =>  CLK_COR_ADJ_LEN_0_BINARY <= "00";
           when   2  =>  CLK_COR_ADJ_LEN_0_BINARY <= "01";
           when   3  =>  CLK_COR_ADJ_LEN_0_BINARY <= "10";
           when   4  =>  CLK_COR_ADJ_LEN_0_BINARY <= "11";
           when others  =>  assert FALSE report "Error : CLK_COR_ADJ_LEN_0 is not in 1, 2, 3, 4." severity error;
       end case;
       case CLK_COR_KEEP_IDLE_0 is
           when FALSE   =>  CLK_COR_KEEP_IDLE_0_BINARY <= '0';
           when TRUE    =>  CLK_COR_KEEP_IDLE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_KEEP_IDLE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_INSERT_IDLE_FLAG_0 is
           when FALSE   =>  CLK_COR_INSERT_IDLE_FLAG_0_BINARY <= '0';
           when TRUE    =>  CLK_COR_INSERT_IDLE_FLAG_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_INSERT_IDLE_FLAG_0 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_REPEAT_WAIT_0 is
           when   0  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00000";
           when   1  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00001";
           when   2  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00010";
           when   3  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00011";
           when   4  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00100";
           when   5  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00101";
           when   6  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00110";
           when   7  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "00111";
           when   8  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01000";
           when   9  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01001";
           when   10  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01010";
           when   11  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01011";
           when   12  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01100";
           when   13  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01101";
           when   14  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01110";
           when   15  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "01111";
           when   16  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10000";
           when   17  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10001";
           when   18  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10010";
           when   19  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10011";
           when   20  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10100";
           when   21  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10101";
           when   22  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10110";
           when   23  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "10111";
           when   24  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11000";
           when   25  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11001";
           when   26  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11010";
           when   27  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11011";
           when   28  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11100";
           when   29  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11101";
           when   30  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11110";
           when   31  =>  CLK_COR_REPEAT_WAIT_0_BINARY <= "11111";
           when others  =>  assert FALSE report "Error : CLK_COR_REPEAT_WAIT_0 is not in range 0...31." severity error;
       end case;
       case CLK_COR_SEQ_2_USE_0 is
           when FALSE   =>  CLK_COR_SEQ_2_USE_0_BINARY <= '0';
           when TRUE    =>  CLK_COR_SEQ_2_USE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_SEQ_2_USE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_MIN_LAT_1 is
           when   3  =>  CLK_COR_MIN_LAT_1_BINARY <= "000011";
           when   4  =>  CLK_COR_MIN_LAT_1_BINARY <= "000100";
           when   5  =>  CLK_COR_MIN_LAT_1_BINARY <= "000101";
           when   6  =>  CLK_COR_MIN_LAT_1_BINARY <= "000110";
           when   7  =>  CLK_COR_MIN_LAT_1_BINARY <= "000111";
           when   8  =>  CLK_COR_MIN_LAT_1_BINARY <= "001000";
           when   9  =>  CLK_COR_MIN_LAT_1_BINARY <= "001001";
           when   10  =>  CLK_COR_MIN_LAT_1_BINARY <= "001010";
           when   11  =>  CLK_COR_MIN_LAT_1_BINARY <= "001011";
           when   12  =>  CLK_COR_MIN_LAT_1_BINARY <= "001100";
           when   13  =>  CLK_COR_MIN_LAT_1_BINARY <= "001101";
           when   14  =>  CLK_COR_MIN_LAT_1_BINARY <= "001110";
           when   15  =>  CLK_COR_MIN_LAT_1_BINARY <= "001111";
           when   16  =>  CLK_COR_MIN_LAT_1_BINARY <= "010000";
           when   17  =>  CLK_COR_MIN_LAT_1_BINARY <= "010001";
           when   18  =>  CLK_COR_MIN_LAT_1_BINARY <= "010010";
           when   19  =>  CLK_COR_MIN_LAT_1_BINARY <= "010011";
           when   20  =>  CLK_COR_MIN_LAT_1_BINARY <= "010100";
           when   21  =>  CLK_COR_MIN_LAT_1_BINARY <= "010101";
           when   22  =>  CLK_COR_MIN_LAT_1_BINARY <= "010110";
           when   23  =>  CLK_COR_MIN_LAT_1_BINARY <= "010111";
           when   24  =>  CLK_COR_MIN_LAT_1_BINARY <= "011000";
           when   25  =>  CLK_COR_MIN_LAT_1_BINARY <= "011001";
           when   26  =>  CLK_COR_MIN_LAT_1_BINARY <= "011010";
           when   27  =>  CLK_COR_MIN_LAT_1_BINARY <= "011011";
           when   28  =>  CLK_COR_MIN_LAT_1_BINARY <= "011100";
           when   29  =>  CLK_COR_MIN_LAT_1_BINARY <= "011101";
           when   30  =>  CLK_COR_MIN_LAT_1_BINARY <= "011110";
           when   31  =>  CLK_COR_MIN_LAT_1_BINARY <= "011111";
           when   32  =>  CLK_COR_MIN_LAT_1_BINARY <= "100000";
           when   33  =>  CLK_COR_MIN_LAT_1_BINARY <= "100001";
           when   34  =>  CLK_COR_MIN_LAT_1_BINARY <= "100010";
           when   35  =>  CLK_COR_MIN_LAT_1_BINARY <= "100011";
           when   36  =>  CLK_COR_MIN_LAT_1_BINARY <= "100100";
           when   37  =>  CLK_COR_MIN_LAT_1_BINARY <= "100101";
           when   38  =>  CLK_COR_MIN_LAT_1_BINARY <= "100110";
           when   39  =>  CLK_COR_MIN_LAT_1_BINARY <= "100111";
           when   40  =>  CLK_COR_MIN_LAT_1_BINARY <= "101000";
           when   41  =>  CLK_COR_MIN_LAT_1_BINARY <= "101001";
           when   42  =>  CLK_COR_MIN_LAT_1_BINARY <= "101010";
           when   43  =>  CLK_COR_MIN_LAT_1_BINARY <= "101011";
           when   44  =>  CLK_COR_MIN_LAT_1_BINARY <= "101100";
           when   45  =>  CLK_COR_MIN_LAT_1_BINARY <= "101101";
           when   46  =>  CLK_COR_MIN_LAT_1_BINARY <= "101110";
           when   47  =>  CLK_COR_MIN_LAT_1_BINARY <= "101111";
           when   48  =>  CLK_COR_MIN_LAT_1_BINARY <= "110000";
           when others  =>  assert FALSE report "Error : CLK_COR_MIN_LAT_1 is not in range 3...48." severity error;
       end case;
       case CLK_COR_MAX_LAT_1 is
           when   3  =>  CLK_COR_MAX_LAT_1_BINARY <= "000011";
           when   4  =>  CLK_COR_MAX_LAT_1_BINARY <= "000100";
           when   5  =>  CLK_COR_MAX_LAT_1_BINARY <= "000101";
           when   6  =>  CLK_COR_MAX_LAT_1_BINARY <= "000110";
           when   7  =>  CLK_COR_MAX_LAT_1_BINARY <= "000111";
           when   8  =>  CLK_COR_MAX_LAT_1_BINARY <= "001000";
           when   9  =>  CLK_COR_MAX_LAT_1_BINARY <= "001001";
           when   10  =>  CLK_COR_MAX_LAT_1_BINARY <= "001010";
           when   11  =>  CLK_COR_MAX_LAT_1_BINARY <= "001011";
           when   12  =>  CLK_COR_MAX_LAT_1_BINARY <= "001100";
           when   13  =>  CLK_COR_MAX_LAT_1_BINARY <= "001101";
           when   14  =>  CLK_COR_MAX_LAT_1_BINARY <= "001110";
           when   15  =>  CLK_COR_MAX_LAT_1_BINARY <= "001111";
           when   16  =>  CLK_COR_MAX_LAT_1_BINARY <= "010000";
           when   17  =>  CLK_COR_MAX_LAT_1_BINARY <= "010001";
           when   18  =>  CLK_COR_MAX_LAT_1_BINARY <= "010010";
           when   19  =>  CLK_COR_MAX_LAT_1_BINARY <= "010011";
           when   20  =>  CLK_COR_MAX_LAT_1_BINARY <= "010100";
           when   21  =>  CLK_COR_MAX_LAT_1_BINARY <= "010101";
           when   22  =>  CLK_COR_MAX_LAT_1_BINARY <= "010110";
           when   23  =>  CLK_COR_MAX_LAT_1_BINARY <= "010111";
           when   24  =>  CLK_COR_MAX_LAT_1_BINARY <= "011000";
           when   25  =>  CLK_COR_MAX_LAT_1_BINARY <= "011001";
           when   26  =>  CLK_COR_MAX_LAT_1_BINARY <= "011010";
           when   27  =>  CLK_COR_MAX_LAT_1_BINARY <= "011011";
           when   28  =>  CLK_COR_MAX_LAT_1_BINARY <= "011100";
           when   29  =>  CLK_COR_MAX_LAT_1_BINARY <= "011101";
           when   30  =>  CLK_COR_MAX_LAT_1_BINARY <= "011110";
           when   31  =>  CLK_COR_MAX_LAT_1_BINARY <= "011111";
           when   32  =>  CLK_COR_MAX_LAT_1_BINARY <= "100000";
           when   33  =>  CLK_COR_MAX_LAT_1_BINARY <= "100001";
           when   34  =>  CLK_COR_MAX_LAT_1_BINARY <= "100010";
           when   35  =>  CLK_COR_MAX_LAT_1_BINARY <= "100011";
           when   36  =>  CLK_COR_MAX_LAT_1_BINARY <= "100100";
           when   37  =>  CLK_COR_MAX_LAT_1_BINARY <= "100101";
           when   38  =>  CLK_COR_MAX_LAT_1_BINARY <= "100110";
           when   39  =>  CLK_COR_MAX_LAT_1_BINARY <= "100111";
           when   40  =>  CLK_COR_MAX_LAT_1_BINARY <= "101000";
           when   41  =>  CLK_COR_MAX_LAT_1_BINARY <= "101001";
           when   42  =>  CLK_COR_MAX_LAT_1_BINARY <= "101010";
           when   43  =>  CLK_COR_MAX_LAT_1_BINARY <= "101011";
           when   44  =>  CLK_COR_MAX_LAT_1_BINARY <= "101100";
           when   45  =>  CLK_COR_MAX_LAT_1_BINARY <= "101101";
           when   46  =>  CLK_COR_MAX_LAT_1_BINARY <= "101110";
           when   47  =>  CLK_COR_MAX_LAT_1_BINARY <= "101111";
           when   48  =>  CLK_COR_MAX_LAT_1_BINARY <= "110000";
           when others  =>  assert FALSE report "Error : CLK_COR_MAX_LAT_1 is not in range 3...48." severity error;
       end case;
       case CLK_CORRECT_USE_1 is
           when FALSE   =>  CLK_CORRECT_USE_1_BINARY <= '0';
           when TRUE    =>  CLK_CORRECT_USE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_CORRECT_USE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_PRECEDENCE_1 is
           when FALSE   =>  CLK_COR_PRECEDENCE_1_BINARY <= '0';
           when TRUE    =>  CLK_COR_PRECEDENCE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_PRECEDENCE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_DET_LEN_1 is
           when   1  =>  CLK_COR_DET_LEN_1_BINARY <= "00";
           when   2  =>  CLK_COR_DET_LEN_1_BINARY <= "01";
           when   3  =>  CLK_COR_DET_LEN_1_BINARY <= "10";
           when   4  =>  CLK_COR_DET_LEN_1_BINARY <= "11";
           when others  =>  assert FALSE report "Error : CLK_COR_DET_LEN_1 is not in 1, 2, 3, 4." severity error;
       end case;
       case CLK_COR_ADJ_LEN_1 is
           when   1  =>  CLK_COR_ADJ_LEN_1_BINARY <= "00";
           when   2  =>  CLK_COR_ADJ_LEN_1_BINARY <= "01";
           when   3  =>  CLK_COR_ADJ_LEN_1_BINARY <= "10";
           when   4  =>  CLK_COR_ADJ_LEN_1_BINARY <= "11";
           when others  =>  assert FALSE report "Error : CLK_COR_ADJ_LEN_1 is not in 1, 2, 3, 4." severity error;
       end case;
       case CLK_COR_KEEP_IDLE_1 is
           when FALSE   =>  CLK_COR_KEEP_IDLE_1_BINARY <= '0';
           when TRUE    =>  CLK_COR_KEEP_IDLE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_KEEP_IDLE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_INSERT_IDLE_FLAG_1 is
           when FALSE   =>  CLK_COR_INSERT_IDLE_FLAG_1_BINARY <= '0';
           when TRUE    =>  CLK_COR_INSERT_IDLE_FLAG_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_INSERT_IDLE_FLAG_1 is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_REPEAT_WAIT_1 is
           when   0  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00000";
           when   1  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00001";
           when   2  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00010";
           when   3  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00011";
           when   4  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00100";
           when   5  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00101";
           when   6  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00110";
           when   7  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "00111";
           when   8  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01000";
           when   9  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01001";
           when   10  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01010";
           when   11  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01011";
           when   12  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01100";
           when   13  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01101";
           when   14  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01110";
           when   15  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "01111";
           when   16  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10000";
           when   17  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10001";
           when   18  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10010";
           when   19  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10011";
           when   20  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10100";
           when   21  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10101";
           when   22  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10110";
           when   23  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "10111";
           when   24  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11000";
           when   25  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11001";
           when   26  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11010";
           when   27  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11011";
           when   28  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11100";
           when   29  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11101";
           when   30  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11110";
           when   31  =>  CLK_COR_REPEAT_WAIT_1_BINARY <= "11111";
           when others  =>  assert FALSE report "Error : CLK_COR_REPEAT_WAIT_1 is not in range 0...31." severity error;
       end case;
       case CLK_COR_SEQ_2_USE_1 is
           when FALSE   =>  CLK_COR_SEQ_2_USE_1_BINARY <= '0';
           when TRUE    =>  CLK_COR_SEQ_2_USE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLK_COR_SEQ_2_USE_1 is neither TRUE nor FALSE." severity error;
       end case;
--     case CHAN_BOND_MODE_0 is
           if((CHAN_BOND_MODE_0 = "OFF") or (CHAN_BOND_MODE_0 = "off")) then
               CHAN_BOND_MODE_0_BINARY <= "00";
           elsif((CHAN_BOND_MODE_0 = "MASTER") or (CHAN_BOND_MODE_0 = "master")) then
               CHAN_BOND_MODE_0_BINARY <= "01";
           elsif((CHAN_BOND_MODE_0 = "SLAVE") or (CHAN_BOND_MODE_0 = "slave")) then
               CHAN_BOND_MODE_0_BINARY <= "10";
           else
             assert FALSE report "Error : CHAN_BOND_MODE_0 = is not OFF, MASTER, SLAVE." severity error;
            end if;
--     end case;
       case CHAN_BOND_LEVEL_0 is
           when   0  =>  CHAN_BOND_LEVEL_0_BINARY <= "000";
           when   1  =>  CHAN_BOND_LEVEL_0_BINARY <= "001";
           when   2  =>  CHAN_BOND_LEVEL_0_BINARY <= "010";
           when   3  =>  CHAN_BOND_LEVEL_0_BINARY <= "011";
           when   4  =>  CHAN_BOND_LEVEL_0_BINARY <= "100";
           when   5  =>  CHAN_BOND_LEVEL_0_BINARY <= "101";
           when   6  =>  CHAN_BOND_LEVEL_0_BINARY <= "110";
           when   7  =>  CHAN_BOND_LEVEL_0_BINARY <= "111";
           when others  =>  assert FALSE report "Error : CHAN_BOND_LEVEL_0 is not in range 0...7." severity error;
       end case;
       case CHAN_BOND_SEQ_LEN_0 is
           when   1  =>  CHAN_BOND_SEQ_LEN_0_BINARY <= "00";
           when   2  =>  CHAN_BOND_SEQ_LEN_0_BINARY <= "01";
           when   3  =>  CHAN_BOND_SEQ_LEN_0_BINARY <= "10";
           when   4  =>  CHAN_BOND_SEQ_LEN_0_BINARY <= "11";
           when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_LEN_0 is not in 1, 2, 3, 4." severity error;
       end case;
       case CHAN_BOND_SEQ_2_USE_0 is
           when FALSE   =>  CHAN_BOND_SEQ_2_USE_0_BINARY <= '0';
           when TRUE    =>  CHAN_BOND_SEQ_2_USE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_2_USE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case CHAN_BOND_1_MAX_SKEW_0 is
           when   1  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "0001";
           when   2  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "0010";
           when   3  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "0011";
           when   4  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "0100";
           when   5  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "0101";
           when   6  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "0110";
           when   7  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "0111";
           when   8  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "1000";
           when   9  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "1001";
           when   10  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "1010";
           when   11  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "1011";
           when   12  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "1100";
           when   13  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "1101";
           when   14  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY <= "1110";
           when others  =>  assert FALSE report "Error : CHAN_BOND_1_MAX_SKEW_0 is not in range 1...14." severity error;
       end case;
       case CHAN_BOND_2_MAX_SKEW_0 is
           when   1  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "0001";
           when   2  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "0010";
           when   3  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "0011";
           when   4  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "0100";
           when   5  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "0101";
           when   6  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "0110";
           when   7  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "0111";
           when   8  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "1000";
           when   9  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "1001";
           when   10  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "1010";
           when   11  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "1011";
           when   12  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "1100";
           when   13  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "1101";
           when   14  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY <= "1110";
           when others  =>  assert FALSE report "Error : CHAN_BOND_2_MAX_SKEW_0 is not in range 1...14." severity error;
       end case;
       case CHAN_BOND_KEEP_ALIGN_0 is
           when FALSE   =>  CHAN_BOND_KEEP_ALIGN_0_BINARY <= '0';
           when TRUE    =>  CHAN_BOND_KEEP_ALIGN_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CHAN_BOND_KEEP_ALIGN_0 is neither TRUE nor FALSE." severity error;
       end case;
       case CB2_INH_CC_PERIOD_0 is
           when   0  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0000";
           when   1  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0001";
           when   2  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0010";
           when   3  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0011";
           when   4  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0100";
           when   5  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0101";
           when   6  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0110";
           when   7  =>  CB2_INH_CC_PERIOD_0_BINARY <= "0111";
           when   8  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1000";
           when   9  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1001";
           when   10  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1010";
           when   11  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1011";
           when   12  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1100";
           when   13  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1101";
           when   14  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1110";
           when   15  =>  CB2_INH_CC_PERIOD_0_BINARY <= "1111";
           when others  =>  assert FALSE report "Error : CB2_INH_CC_PERIOD_0 is not in range 0...15." severity error;
       end case;
--     case CHAN_BOND_MODE_1 is
           if((CHAN_BOND_MODE_1 = "OFF") or (CHAN_BOND_MODE_1 = "off")) then
               CHAN_BOND_MODE_1_BINARY <= "00";
           elsif((CHAN_BOND_MODE_1 = "MASTER") or (CHAN_BOND_MODE_1 = "master")) then
               CHAN_BOND_MODE_1_BINARY <= "01";
           elsif((CHAN_BOND_MODE_1 = "SLAVE") or (CHAN_BOND_MODE_1 = "slave")) then
               CHAN_BOND_MODE_1_BINARY <= "10";
           else
             assert FALSE report "Error : CHAN_BOND_MODE_1 = is not OFF, MASTER, SLAVE." severity error;
            end if;
--     end case;
       case CHAN_BOND_LEVEL_1 is
           when   0  =>  CHAN_BOND_LEVEL_1_BINARY <= "000";
           when   1  =>  CHAN_BOND_LEVEL_1_BINARY <= "001";
           when   2  =>  CHAN_BOND_LEVEL_1_BINARY <= "010";
           when   3  =>  CHAN_BOND_LEVEL_1_BINARY <= "011";
           when   4  =>  CHAN_BOND_LEVEL_1_BINARY <= "100";
           when   5  =>  CHAN_BOND_LEVEL_1_BINARY <= "101";
           when   6  =>  CHAN_BOND_LEVEL_1_BINARY <= "110";
           when   7  =>  CHAN_BOND_LEVEL_1_BINARY <= "111";
           when others  =>  assert FALSE report "Error : CHAN_BOND_LEVEL_1 is not in range 0...7." severity error;
       end case;
       case CHAN_BOND_SEQ_LEN_1 is
           when   1  =>  CHAN_BOND_SEQ_LEN_1_BINARY <= "00";
           when   2  =>  CHAN_BOND_SEQ_LEN_1_BINARY <= "01";
           when   3  =>  CHAN_BOND_SEQ_LEN_1_BINARY <= "10";
           when   4  =>  CHAN_BOND_SEQ_LEN_1_BINARY <= "11";
           when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_LEN_1 is not in 1, 2, 3, 4." severity error;
       end case;
       case CHAN_BOND_SEQ_2_USE_1 is
           when FALSE   =>  CHAN_BOND_SEQ_2_USE_1_BINARY <= '0';
           when TRUE    =>  CHAN_BOND_SEQ_2_USE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_2_USE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case CHAN_BOND_1_MAX_SKEW_1 is
           when   1  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "0001";
           when   2  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "0010";
           when   3  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "0011";
           when   4  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "0100";
           when   5  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "0101";
           when   6  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "0110";
           when   7  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "0111";
           when   8  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "1000";
           when   9  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "1001";
           when   10  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "1010";
           when   11  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "1011";
           when   12  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "1100";
           when   13  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "1101";
           when   14  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY <= "1110";
           when others  =>  assert FALSE report "Error : CHAN_BOND_1_MAX_SKEW_1 is not in range 1...14." severity error;
       end case;
       case CHAN_BOND_2_MAX_SKEW_1 is
           when   1  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "0001";
           when   2  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "0010";
           when   3  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "0011";
           when   4  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "0100";
           when   5  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "0101";
           when   6  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "0110";
           when   7  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "0111";
           when   8  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "1000";
           when   9  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "1001";
           when   10  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "1010";
           when   11  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "1011";
           when   12  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "1100";
           when   13  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "1101";
           when   14  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY <= "1110";
           when others  =>  assert FALSE report "Error : CHAN_BOND_2_MAX_SKEW_1 is not in range 1...14." severity error;
       end case;
       case CHAN_BOND_KEEP_ALIGN_1 is
           when FALSE   =>  CHAN_BOND_KEEP_ALIGN_1_BINARY <= '0';
           when TRUE    =>  CHAN_BOND_KEEP_ALIGN_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CHAN_BOND_KEEP_ALIGN_1 is neither TRUE nor FALSE." severity error;
       end case;
       case CB2_INH_CC_PERIOD_1 is
           when   0  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0000";
           when   1  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0001";
           when   2  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0010";
           when   3  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0011";
           when   4  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0100";
           when   5  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0101";
           when   6  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0110";
           when   7  =>  CB2_INH_CC_PERIOD_1_BINARY <= "0111";
           when   8  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1000";
           when   9  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1001";
           when   10  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1010";
           when   11  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1011";
           when   12  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1100";
           when   13  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1101";
           when   14  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1110";
           when   15  =>  CB2_INH_CC_PERIOD_1_BINARY <= "1111";
           when others  =>  assert FALSE report "Error : CB2_INH_CC_PERIOD_1 is not in range 0...15." severity error;
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
--     case RX_STATUS_FMT_0 is
           if((RX_STATUS_FMT_0 = "PCIE") or (RX_STATUS_FMT_0 = "pcie")) then
               RX_STATUS_FMT_0_BINARY <= '0';
           elsif((RX_STATUS_FMT_0 = "SATA") or (RX_STATUS_FMT_0 = "sata")) then
               RX_STATUS_FMT_0_BINARY <= '1';
           else
             assert FALSE report "Error : RX_STATUS_FMT_0 = is not PCIE, SATA." severity error;
            end if;
--     end case;
       case TX_BUFFER_USE_0 is
           when FALSE   =>  TX_BUFFER_USE_0_BINARY <= '0';
           when TRUE    =>  TX_BUFFER_USE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TX_BUFFER_USE_0 is neither TRUE nor FALSE." severity error;
       end case;
--     case TX_XCLK_SEL_0 is
           if((TX_XCLK_SEL_0 = "TXUSR") or (TX_XCLK_SEL_0 = "txusr")) then
               TX_XCLK_SEL_0_BINARY <= '1';
           elsif((TX_XCLK_SEL_0 = "TXOUT") or (TX_XCLK_SEL_0 = "txout")) then
               TX_XCLK_SEL_0_BINARY <= '0';
           else
             assert FALSE report "Error : TX_XCLK_SEL_0 = is not TXUSR, TXOUT." severity error;
            end if;
--     end case;
--     case RX_XCLK_SEL_0 is
           if((RX_XCLK_SEL_0 = "RXREC") or (RX_XCLK_SEL_0 = "rxrec")) then
               RX_XCLK_SEL_0_BINARY <= '0';
           elsif((RX_XCLK_SEL_0 = "RXUSR") or (RX_XCLK_SEL_0 = "rxusr")) then
               RX_XCLK_SEL_0_BINARY <= '1';
           else
             assert FALSE report "Error : RX_XCLK_SEL_0 = is not RXREC, RXUSR." severity error;
            end if;
--     end case;
--     case RX_STATUS_FMT_1 is
           if((RX_STATUS_FMT_1 = "PCIE") or (RX_STATUS_FMT_1 = "pcie")) then
               RX_STATUS_FMT_1_BINARY <= '0';
           elsif((RX_STATUS_FMT_1 = "SATA") or (RX_STATUS_FMT_1 = "sata")) then
               RX_STATUS_FMT_1_BINARY <= '1';
           else
             assert FALSE report "Error : RX_STATUS_FMT_1 = is not PCIE, SATA." severity error;
            end if;
--     end case;
       case TX_BUFFER_USE_1 is
           when FALSE   =>  TX_BUFFER_USE_1_BINARY <= '0';
           when TRUE    =>  TX_BUFFER_USE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TX_BUFFER_USE_1 is neither TRUE nor FALSE." severity error;
       end case;
--     case TX_XCLK_SEL_1 is
           if((TX_XCLK_SEL_1 = "TXUSR") or (TX_XCLK_SEL_1 = "txusr")) then
               TX_XCLK_SEL_1_BINARY <= '1';
           elsif((TX_XCLK_SEL_1 = "TXOUT") or (TX_XCLK_SEL_1 = "txout")) then
               TX_XCLK_SEL_1_BINARY <= '0';
           else
             assert FALSE report "Error : TX_XCLK_SEL_1 = is not TXUSR, TXOUT." severity error;
            end if;
--     end case;
--     case RX_XCLK_SEL_1 is
           if((RX_XCLK_SEL_1 = "RXREC") or (RX_XCLK_SEL_1 = "rxrec")) then
               RX_XCLK_SEL_1_BINARY <= '0';
           elsif((RX_XCLK_SEL_1 = "RXUSR") or (RX_XCLK_SEL_1 = "rxusr")) then
               RX_XCLK_SEL_1_BINARY <= '1';
           else
             assert FALSE report "Error : RX_XCLK_SEL_1 = is not RXREC, RXUSR." severity error;
            end if;
--     end case;
--     case RX_SLIDE_MODE_0 is
           if((RX_SLIDE_MODE_0 = "PCS") or (RX_SLIDE_MODE_0 = "pcs")) then
               RX_SLIDE_MODE_0_BINARY <= '0';
           elsif((RX_SLIDE_MODE_0 = "PMA") or (RX_SLIDE_MODE_0 = "pma")) then
               RX_SLIDE_MODE_0_BINARY <= '1';
           else
             assert FALSE report "Error : RX_SLIDE_MODE_0 = is not PCS, PMA." severity error;
            end if;
--     end case;
--     case RX_SLIDE_MODE_1 is
           if((RX_SLIDE_MODE_1 = "PCS") or (RX_SLIDE_MODE_1 = "pcs")) then
               RX_SLIDE_MODE_1_BINARY <= '0';
           elsif((RX_SLIDE_MODE_1 = "PMA") or (RX_SLIDE_MODE_1 = "pma")) then
               RX_SLIDE_MODE_1_BINARY <= '1';
           else
             assert FALSE report "Error : RX_SLIDE_MODE_1 = is not PCS, PMA." severity error;
            end if;
--     end case;
       case SATA_MIN_BURST_0 is
           when   1  =>  SATA_MIN_BURST_0_BINARY <= "000001";
           when   2  =>  SATA_MIN_BURST_0_BINARY <= "000010";
           when   3  =>  SATA_MIN_BURST_0_BINARY <= "000011";
           when   4  =>  SATA_MIN_BURST_0_BINARY <= "000100";
           when   5  =>  SATA_MIN_BURST_0_BINARY <= "000101";
           when   6  =>  SATA_MIN_BURST_0_BINARY <= "000110";
           when   7  =>  SATA_MIN_BURST_0_BINARY <= "000111";
           when   8  =>  SATA_MIN_BURST_0_BINARY <= "001000";
           when   9  =>  SATA_MIN_BURST_0_BINARY <= "001001";
           when   10  =>  SATA_MIN_BURST_0_BINARY <= "001010";
           when   11  =>  SATA_MIN_BURST_0_BINARY <= "001011";
           when   12  =>  SATA_MIN_BURST_0_BINARY <= "001100";
           when   13  =>  SATA_MIN_BURST_0_BINARY <= "001101";
           when   14  =>  SATA_MIN_BURST_0_BINARY <= "001110";
           when   15  =>  SATA_MIN_BURST_0_BINARY <= "001111";
           when   16  =>  SATA_MIN_BURST_0_BINARY <= "010000";
           when   17  =>  SATA_MIN_BURST_0_BINARY <= "010001";
           when   18  =>  SATA_MIN_BURST_0_BINARY <= "010010";
           when   19  =>  SATA_MIN_BURST_0_BINARY <= "010011";
           when   20  =>  SATA_MIN_BURST_0_BINARY <= "010100";
           when   21  =>  SATA_MIN_BURST_0_BINARY <= "010101";
           when   22  =>  SATA_MIN_BURST_0_BINARY <= "010110";
           when   23  =>  SATA_MIN_BURST_0_BINARY <= "010111";
           when   24  =>  SATA_MIN_BURST_0_BINARY <= "011000";
           when   25  =>  SATA_MIN_BURST_0_BINARY <= "011001";
           when   26  =>  SATA_MIN_BURST_0_BINARY <= "011010";
           when   27  =>  SATA_MIN_BURST_0_BINARY <= "011011";
           when   28  =>  SATA_MIN_BURST_0_BINARY <= "011100";
           when   29  =>  SATA_MIN_BURST_0_BINARY <= "011101";
           when   30  =>  SATA_MIN_BURST_0_BINARY <= "011110";
           when   31  =>  SATA_MIN_BURST_0_BINARY <= "011111";
           when   32  =>  SATA_MIN_BURST_0_BINARY <= "100000";
           when   33  =>  SATA_MIN_BURST_0_BINARY <= "100001";
           when   34  =>  SATA_MIN_BURST_0_BINARY <= "100010";
           when   35  =>  SATA_MIN_BURST_0_BINARY <= "100011";
           when   36  =>  SATA_MIN_BURST_0_BINARY <= "100100";
           when   37  =>  SATA_MIN_BURST_0_BINARY <= "100101";
           when   38  =>  SATA_MIN_BURST_0_BINARY <= "100110";
           when   39  =>  SATA_MIN_BURST_0_BINARY <= "100111";
           when   40  =>  SATA_MIN_BURST_0_BINARY <= "101000";
           when   41  =>  SATA_MIN_BURST_0_BINARY <= "101001";
           when   42  =>  SATA_MIN_BURST_0_BINARY <= "101010";
           when   43  =>  SATA_MIN_BURST_0_BINARY <= "101011";
           when   44  =>  SATA_MIN_BURST_0_BINARY <= "101100";
           when   45  =>  SATA_MIN_BURST_0_BINARY <= "101101";
           when   46  =>  SATA_MIN_BURST_0_BINARY <= "101110";
           when   47  =>  SATA_MIN_BURST_0_BINARY <= "101111";
           when   48  =>  SATA_MIN_BURST_0_BINARY <= "110000";
           when   49  =>  SATA_MIN_BURST_0_BINARY <= "110001";
           when   50  =>  SATA_MIN_BURST_0_BINARY <= "110010";
           when   51  =>  SATA_MIN_BURST_0_BINARY <= "110011";
           when   52  =>  SATA_MIN_BURST_0_BINARY <= "110100";
           when   53  =>  SATA_MIN_BURST_0_BINARY <= "110101";
           when   54  =>  SATA_MIN_BURST_0_BINARY <= "110110";
           when   55  =>  SATA_MIN_BURST_0_BINARY <= "110111";
           when   56  =>  SATA_MIN_BURST_0_BINARY <= "111000";
           when   57  =>  SATA_MIN_BURST_0_BINARY <= "111001";
           when   58  =>  SATA_MIN_BURST_0_BINARY <= "111010";
           when   59  =>  SATA_MIN_BURST_0_BINARY <= "111011";
           when   60  =>  SATA_MIN_BURST_0_BINARY <= "111100";
           when   61  =>  SATA_MIN_BURST_0_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MIN_BURST_0 is not in range 1...61." severity error;
       end case;
       case SATA_MAX_BURST_0 is
           when   1  =>  SATA_MAX_BURST_0_BINARY <= "000001";
           when   2  =>  SATA_MAX_BURST_0_BINARY <= "000010";
           when   3  =>  SATA_MAX_BURST_0_BINARY <= "000011";
           when   4  =>  SATA_MAX_BURST_0_BINARY <= "000100";
           when   5  =>  SATA_MAX_BURST_0_BINARY <= "000101";
           when   6  =>  SATA_MAX_BURST_0_BINARY <= "000110";
           when   7  =>  SATA_MAX_BURST_0_BINARY <= "000111";
           when   8  =>  SATA_MAX_BURST_0_BINARY <= "001000";
           when   9  =>  SATA_MAX_BURST_0_BINARY <= "001001";
           when   10  =>  SATA_MAX_BURST_0_BINARY <= "001010";
           when   11  =>  SATA_MAX_BURST_0_BINARY <= "001011";
           when   12  =>  SATA_MAX_BURST_0_BINARY <= "001100";
           when   13  =>  SATA_MAX_BURST_0_BINARY <= "001101";
           when   14  =>  SATA_MAX_BURST_0_BINARY <= "001110";
           when   15  =>  SATA_MAX_BURST_0_BINARY <= "001111";
           when   16  =>  SATA_MAX_BURST_0_BINARY <= "010000";
           when   17  =>  SATA_MAX_BURST_0_BINARY <= "010001";
           when   18  =>  SATA_MAX_BURST_0_BINARY <= "010010";
           when   19  =>  SATA_MAX_BURST_0_BINARY <= "010011";
           when   20  =>  SATA_MAX_BURST_0_BINARY <= "010100";
           when   21  =>  SATA_MAX_BURST_0_BINARY <= "010101";
           when   22  =>  SATA_MAX_BURST_0_BINARY <= "010110";
           when   23  =>  SATA_MAX_BURST_0_BINARY <= "010111";
           when   24  =>  SATA_MAX_BURST_0_BINARY <= "011000";
           when   25  =>  SATA_MAX_BURST_0_BINARY <= "011001";
           when   26  =>  SATA_MAX_BURST_0_BINARY <= "011010";
           when   27  =>  SATA_MAX_BURST_0_BINARY <= "011011";
           when   28  =>  SATA_MAX_BURST_0_BINARY <= "011100";
           when   29  =>  SATA_MAX_BURST_0_BINARY <= "011101";
           when   30  =>  SATA_MAX_BURST_0_BINARY <= "011110";
           when   31  =>  SATA_MAX_BURST_0_BINARY <= "011111";
           when   32  =>  SATA_MAX_BURST_0_BINARY <= "100000";
           when   33  =>  SATA_MAX_BURST_0_BINARY <= "100001";
           when   34  =>  SATA_MAX_BURST_0_BINARY <= "100010";
           when   35  =>  SATA_MAX_BURST_0_BINARY <= "100011";
           when   36  =>  SATA_MAX_BURST_0_BINARY <= "100100";
           when   37  =>  SATA_MAX_BURST_0_BINARY <= "100101";
           when   38  =>  SATA_MAX_BURST_0_BINARY <= "100110";
           when   39  =>  SATA_MAX_BURST_0_BINARY <= "100111";
           when   40  =>  SATA_MAX_BURST_0_BINARY <= "101000";
           when   41  =>  SATA_MAX_BURST_0_BINARY <= "101001";
           when   42  =>  SATA_MAX_BURST_0_BINARY <= "101010";
           when   43  =>  SATA_MAX_BURST_0_BINARY <= "101011";
           when   44  =>  SATA_MAX_BURST_0_BINARY <= "101100";
           when   45  =>  SATA_MAX_BURST_0_BINARY <= "101101";
           when   46  =>  SATA_MAX_BURST_0_BINARY <= "101110";
           when   47  =>  SATA_MAX_BURST_0_BINARY <= "101111";
           when   48  =>  SATA_MAX_BURST_0_BINARY <= "110000";
           when   49  =>  SATA_MAX_BURST_0_BINARY <= "110001";
           when   50  =>  SATA_MAX_BURST_0_BINARY <= "110010";
           when   51  =>  SATA_MAX_BURST_0_BINARY <= "110011";
           when   52  =>  SATA_MAX_BURST_0_BINARY <= "110100";
           when   53  =>  SATA_MAX_BURST_0_BINARY <= "110101";
           when   54  =>  SATA_MAX_BURST_0_BINARY <= "110110";
           when   55  =>  SATA_MAX_BURST_0_BINARY <= "110111";
           when   56  =>  SATA_MAX_BURST_0_BINARY <= "111000";
           when   57  =>  SATA_MAX_BURST_0_BINARY <= "111001";
           when   58  =>  SATA_MAX_BURST_0_BINARY <= "111010";
           when   59  =>  SATA_MAX_BURST_0_BINARY <= "111011";
           when   60  =>  SATA_MAX_BURST_0_BINARY <= "111100";
           when   61  =>  SATA_MAX_BURST_0_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MAX_BURST_0 is not in range 1...61." severity error;
       end case;
       case SATA_MIN_INIT_0 is
           when   1  =>  SATA_MIN_INIT_0_BINARY <= "000001";
           when   2  =>  SATA_MIN_INIT_0_BINARY <= "000010";
           when   3  =>  SATA_MIN_INIT_0_BINARY <= "000011";
           when   4  =>  SATA_MIN_INIT_0_BINARY <= "000100";
           when   5  =>  SATA_MIN_INIT_0_BINARY <= "000101";
           when   6  =>  SATA_MIN_INIT_0_BINARY <= "000110";
           when   7  =>  SATA_MIN_INIT_0_BINARY <= "000111";
           when   8  =>  SATA_MIN_INIT_0_BINARY <= "001000";
           when   9  =>  SATA_MIN_INIT_0_BINARY <= "001001";
           when   10  =>  SATA_MIN_INIT_0_BINARY <= "001010";
           when   11  =>  SATA_MIN_INIT_0_BINARY <= "001011";
           when   12  =>  SATA_MIN_INIT_0_BINARY <= "001100";
           when   13  =>  SATA_MIN_INIT_0_BINARY <= "001101";
           when   14  =>  SATA_MIN_INIT_0_BINARY <= "001110";
           when   15  =>  SATA_MIN_INIT_0_BINARY <= "001111";
           when   16  =>  SATA_MIN_INIT_0_BINARY <= "010000";
           when   17  =>  SATA_MIN_INIT_0_BINARY <= "010001";
           when   18  =>  SATA_MIN_INIT_0_BINARY <= "010010";
           when   19  =>  SATA_MIN_INIT_0_BINARY <= "010011";
           when   20  =>  SATA_MIN_INIT_0_BINARY <= "010100";
           when   21  =>  SATA_MIN_INIT_0_BINARY <= "010101";
           when   22  =>  SATA_MIN_INIT_0_BINARY <= "010110";
           when   23  =>  SATA_MIN_INIT_0_BINARY <= "010111";
           when   24  =>  SATA_MIN_INIT_0_BINARY <= "011000";
           when   25  =>  SATA_MIN_INIT_0_BINARY <= "011001";
           when   26  =>  SATA_MIN_INIT_0_BINARY <= "011010";
           when   27  =>  SATA_MIN_INIT_0_BINARY <= "011011";
           when   28  =>  SATA_MIN_INIT_0_BINARY <= "011100";
           when   29  =>  SATA_MIN_INIT_0_BINARY <= "011101";
           when   30  =>  SATA_MIN_INIT_0_BINARY <= "011110";
           when   31  =>  SATA_MIN_INIT_0_BINARY <= "011111";
           when   32  =>  SATA_MIN_INIT_0_BINARY <= "100000";
           when   33  =>  SATA_MIN_INIT_0_BINARY <= "100001";
           when   34  =>  SATA_MIN_INIT_0_BINARY <= "100010";
           when   35  =>  SATA_MIN_INIT_0_BINARY <= "100011";
           when   36  =>  SATA_MIN_INIT_0_BINARY <= "100100";
           when   37  =>  SATA_MIN_INIT_0_BINARY <= "100101";
           when   38  =>  SATA_MIN_INIT_0_BINARY <= "100110";
           when   39  =>  SATA_MIN_INIT_0_BINARY <= "100111";
           when   40  =>  SATA_MIN_INIT_0_BINARY <= "101000";
           when   41  =>  SATA_MIN_INIT_0_BINARY <= "101001";
           when   42  =>  SATA_MIN_INIT_0_BINARY <= "101010";
           when   43  =>  SATA_MIN_INIT_0_BINARY <= "101011";
           when   44  =>  SATA_MIN_INIT_0_BINARY <= "101100";
           when   45  =>  SATA_MIN_INIT_0_BINARY <= "101101";
           when   46  =>  SATA_MIN_INIT_0_BINARY <= "101110";
           when   47  =>  SATA_MIN_INIT_0_BINARY <= "101111";
           when   48  =>  SATA_MIN_INIT_0_BINARY <= "110000";
           when   49  =>  SATA_MIN_INIT_0_BINARY <= "110001";
           when   50  =>  SATA_MIN_INIT_0_BINARY <= "110010";
           when   51  =>  SATA_MIN_INIT_0_BINARY <= "110011";
           when   52  =>  SATA_MIN_INIT_0_BINARY <= "110100";
           when   53  =>  SATA_MIN_INIT_0_BINARY <= "110101";
           when   54  =>  SATA_MIN_INIT_0_BINARY <= "110110";
           when   55  =>  SATA_MIN_INIT_0_BINARY <= "110111";
           when   56  =>  SATA_MIN_INIT_0_BINARY <= "111000";
           when   57  =>  SATA_MIN_INIT_0_BINARY <= "111001";
           when   58  =>  SATA_MIN_INIT_0_BINARY <= "111010";
           when   59  =>  SATA_MIN_INIT_0_BINARY <= "111011";
           when   60  =>  SATA_MIN_INIT_0_BINARY <= "111100";
           when   61  =>  SATA_MIN_INIT_0_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MIN_INIT_0 is not in range 1...61." severity error;
       end case;
       case SATA_MAX_INIT_0 is
           when   1  =>  SATA_MAX_INIT_0_BINARY <= "000001";
           when   2  =>  SATA_MAX_INIT_0_BINARY <= "000010";
           when   3  =>  SATA_MAX_INIT_0_BINARY <= "000011";
           when   4  =>  SATA_MAX_INIT_0_BINARY <= "000100";
           when   5  =>  SATA_MAX_INIT_0_BINARY <= "000101";
           when   6  =>  SATA_MAX_INIT_0_BINARY <= "000110";
           when   7  =>  SATA_MAX_INIT_0_BINARY <= "000111";
           when   8  =>  SATA_MAX_INIT_0_BINARY <= "001000";
           when   9  =>  SATA_MAX_INIT_0_BINARY <= "001001";
           when   10  =>  SATA_MAX_INIT_0_BINARY <= "001010";
           when   11  =>  SATA_MAX_INIT_0_BINARY <= "001011";
           when   12  =>  SATA_MAX_INIT_0_BINARY <= "001100";
           when   13  =>  SATA_MAX_INIT_0_BINARY <= "001101";
           when   14  =>  SATA_MAX_INIT_0_BINARY <= "001110";
           when   15  =>  SATA_MAX_INIT_0_BINARY <= "001111";
           when   16  =>  SATA_MAX_INIT_0_BINARY <= "010000";
           when   17  =>  SATA_MAX_INIT_0_BINARY <= "010001";
           when   18  =>  SATA_MAX_INIT_0_BINARY <= "010010";
           when   19  =>  SATA_MAX_INIT_0_BINARY <= "010011";
           when   20  =>  SATA_MAX_INIT_0_BINARY <= "010100";
           when   21  =>  SATA_MAX_INIT_0_BINARY <= "010101";
           when   22  =>  SATA_MAX_INIT_0_BINARY <= "010110";
           when   23  =>  SATA_MAX_INIT_0_BINARY <= "010111";
           when   24  =>  SATA_MAX_INIT_0_BINARY <= "011000";
           when   25  =>  SATA_MAX_INIT_0_BINARY <= "011001";
           when   26  =>  SATA_MAX_INIT_0_BINARY <= "011010";
           when   27  =>  SATA_MAX_INIT_0_BINARY <= "011011";
           when   28  =>  SATA_MAX_INIT_0_BINARY <= "011100";
           when   29  =>  SATA_MAX_INIT_0_BINARY <= "011101";
           when   30  =>  SATA_MAX_INIT_0_BINARY <= "011110";
           when   31  =>  SATA_MAX_INIT_0_BINARY <= "011111";
           when   32  =>  SATA_MAX_INIT_0_BINARY <= "100000";
           when   33  =>  SATA_MAX_INIT_0_BINARY <= "100001";
           when   34  =>  SATA_MAX_INIT_0_BINARY <= "100010";
           when   35  =>  SATA_MAX_INIT_0_BINARY <= "100011";
           when   36  =>  SATA_MAX_INIT_0_BINARY <= "100100";
           when   37  =>  SATA_MAX_INIT_0_BINARY <= "100101";
           when   38  =>  SATA_MAX_INIT_0_BINARY <= "100110";
           when   39  =>  SATA_MAX_INIT_0_BINARY <= "100111";
           when   40  =>  SATA_MAX_INIT_0_BINARY <= "101000";
           when   41  =>  SATA_MAX_INIT_0_BINARY <= "101001";
           when   42  =>  SATA_MAX_INIT_0_BINARY <= "101010";
           when   43  =>  SATA_MAX_INIT_0_BINARY <= "101011";
           when   44  =>  SATA_MAX_INIT_0_BINARY <= "101100";
           when   45  =>  SATA_MAX_INIT_0_BINARY <= "101101";
           when   46  =>  SATA_MAX_INIT_0_BINARY <= "101110";
           when   47  =>  SATA_MAX_INIT_0_BINARY <= "101111";
           when   48  =>  SATA_MAX_INIT_0_BINARY <= "110000";
           when   49  =>  SATA_MAX_INIT_0_BINARY <= "110001";
           when   50  =>  SATA_MAX_INIT_0_BINARY <= "110010";
           when   51  =>  SATA_MAX_INIT_0_BINARY <= "110011";
           when   52  =>  SATA_MAX_INIT_0_BINARY <= "110100";
           when   53  =>  SATA_MAX_INIT_0_BINARY <= "110101";
           when   54  =>  SATA_MAX_INIT_0_BINARY <= "110110";
           when   55  =>  SATA_MAX_INIT_0_BINARY <= "110111";
           when   56  =>  SATA_MAX_INIT_0_BINARY <= "111000";
           when   57  =>  SATA_MAX_INIT_0_BINARY <= "111001";
           when   58  =>  SATA_MAX_INIT_0_BINARY <= "111010";
           when   59  =>  SATA_MAX_INIT_0_BINARY <= "111011";
           when   60  =>  SATA_MAX_INIT_0_BINARY <= "111100";
           when   61  =>  SATA_MAX_INIT_0_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MAX_INIT_0 is not in range 1...61." severity error;
       end case;
       case SATA_MIN_WAKE_0 is
           when   1  =>  SATA_MIN_WAKE_0_BINARY <= "000001";
           when   2  =>  SATA_MIN_WAKE_0_BINARY <= "000010";
           when   3  =>  SATA_MIN_WAKE_0_BINARY <= "000011";
           when   4  =>  SATA_MIN_WAKE_0_BINARY <= "000100";
           when   5  =>  SATA_MIN_WAKE_0_BINARY <= "000101";
           when   6  =>  SATA_MIN_WAKE_0_BINARY <= "000110";
           when   7  =>  SATA_MIN_WAKE_0_BINARY <= "000111";
           when   8  =>  SATA_MIN_WAKE_0_BINARY <= "001000";
           when   9  =>  SATA_MIN_WAKE_0_BINARY <= "001001";
           when   10  =>  SATA_MIN_WAKE_0_BINARY <= "001010";
           when   11  =>  SATA_MIN_WAKE_0_BINARY <= "001011";
           when   12  =>  SATA_MIN_WAKE_0_BINARY <= "001100";
           when   13  =>  SATA_MIN_WAKE_0_BINARY <= "001101";
           when   14  =>  SATA_MIN_WAKE_0_BINARY <= "001110";
           when   15  =>  SATA_MIN_WAKE_0_BINARY <= "001111";
           when   16  =>  SATA_MIN_WAKE_0_BINARY <= "010000";
           when   17  =>  SATA_MIN_WAKE_0_BINARY <= "010001";
           when   18  =>  SATA_MIN_WAKE_0_BINARY <= "010010";
           when   19  =>  SATA_MIN_WAKE_0_BINARY <= "010011";
           when   20  =>  SATA_MIN_WAKE_0_BINARY <= "010100";
           when   21  =>  SATA_MIN_WAKE_0_BINARY <= "010101";
           when   22  =>  SATA_MIN_WAKE_0_BINARY <= "010110";
           when   23  =>  SATA_MIN_WAKE_0_BINARY <= "010111";
           when   24  =>  SATA_MIN_WAKE_0_BINARY <= "011000";
           when   25  =>  SATA_MIN_WAKE_0_BINARY <= "011001";
           when   26  =>  SATA_MIN_WAKE_0_BINARY <= "011010";
           when   27  =>  SATA_MIN_WAKE_0_BINARY <= "011011";
           when   28  =>  SATA_MIN_WAKE_0_BINARY <= "011100";
           when   29  =>  SATA_MIN_WAKE_0_BINARY <= "011101";
           when   30  =>  SATA_MIN_WAKE_0_BINARY <= "011110";
           when   31  =>  SATA_MIN_WAKE_0_BINARY <= "011111";
           when   32  =>  SATA_MIN_WAKE_0_BINARY <= "100000";
           when   33  =>  SATA_MIN_WAKE_0_BINARY <= "100001";
           when   34  =>  SATA_MIN_WAKE_0_BINARY <= "100010";
           when   35  =>  SATA_MIN_WAKE_0_BINARY <= "100011";
           when   36  =>  SATA_MIN_WAKE_0_BINARY <= "100100";
           when   37  =>  SATA_MIN_WAKE_0_BINARY <= "100101";
           when   38  =>  SATA_MIN_WAKE_0_BINARY <= "100110";
           when   39  =>  SATA_MIN_WAKE_0_BINARY <= "100111";
           when   40  =>  SATA_MIN_WAKE_0_BINARY <= "101000";
           when   41  =>  SATA_MIN_WAKE_0_BINARY <= "101001";
           when   42  =>  SATA_MIN_WAKE_0_BINARY <= "101010";
           when   43  =>  SATA_MIN_WAKE_0_BINARY <= "101011";
           when   44  =>  SATA_MIN_WAKE_0_BINARY <= "101100";
           when   45  =>  SATA_MIN_WAKE_0_BINARY <= "101101";
           when   46  =>  SATA_MIN_WAKE_0_BINARY <= "101110";
           when   47  =>  SATA_MIN_WAKE_0_BINARY <= "101111";
           when   48  =>  SATA_MIN_WAKE_0_BINARY <= "110000";
           when   49  =>  SATA_MIN_WAKE_0_BINARY <= "110001";
           when   50  =>  SATA_MIN_WAKE_0_BINARY <= "110010";
           when   51  =>  SATA_MIN_WAKE_0_BINARY <= "110011";
           when   52  =>  SATA_MIN_WAKE_0_BINARY <= "110100";
           when   53  =>  SATA_MIN_WAKE_0_BINARY <= "110101";
           when   54  =>  SATA_MIN_WAKE_0_BINARY <= "110110";
           when   55  =>  SATA_MIN_WAKE_0_BINARY <= "110111";
           when   56  =>  SATA_MIN_WAKE_0_BINARY <= "111000";
           when   57  =>  SATA_MIN_WAKE_0_BINARY <= "111001";
           when   58  =>  SATA_MIN_WAKE_0_BINARY <= "111010";
           when   59  =>  SATA_MIN_WAKE_0_BINARY <= "111011";
           when   60  =>  SATA_MIN_WAKE_0_BINARY <= "111100";
           when   61  =>  SATA_MIN_WAKE_0_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MIN_WAKE_0 is not in range 1...61." severity error;
       end case;
       case SATA_MAX_WAKE_0 is
           when   1  =>  SATA_MAX_WAKE_0_BINARY <= "000001";
           when   2  =>  SATA_MAX_WAKE_0_BINARY <= "000010";
           when   3  =>  SATA_MAX_WAKE_0_BINARY <= "000011";
           when   4  =>  SATA_MAX_WAKE_0_BINARY <= "000100";
           when   5  =>  SATA_MAX_WAKE_0_BINARY <= "000101";
           when   6  =>  SATA_MAX_WAKE_0_BINARY <= "000110";
           when   7  =>  SATA_MAX_WAKE_0_BINARY <= "000111";
           when   8  =>  SATA_MAX_WAKE_0_BINARY <= "001000";
           when   9  =>  SATA_MAX_WAKE_0_BINARY <= "001001";
           when   10  =>  SATA_MAX_WAKE_0_BINARY <= "001010";
           when   11  =>  SATA_MAX_WAKE_0_BINARY <= "001011";
           when   12  =>  SATA_MAX_WAKE_0_BINARY <= "001100";
           when   13  =>  SATA_MAX_WAKE_0_BINARY <= "001101";
           when   14  =>  SATA_MAX_WAKE_0_BINARY <= "001110";
           when   15  =>  SATA_MAX_WAKE_0_BINARY <= "001111";
           when   16  =>  SATA_MAX_WAKE_0_BINARY <= "010000";
           when   17  =>  SATA_MAX_WAKE_0_BINARY <= "010001";
           when   18  =>  SATA_MAX_WAKE_0_BINARY <= "010010";
           when   19  =>  SATA_MAX_WAKE_0_BINARY <= "010011";
           when   20  =>  SATA_MAX_WAKE_0_BINARY <= "010100";
           when   21  =>  SATA_MAX_WAKE_0_BINARY <= "010101";
           when   22  =>  SATA_MAX_WAKE_0_BINARY <= "010110";
           when   23  =>  SATA_MAX_WAKE_0_BINARY <= "010111";
           when   24  =>  SATA_MAX_WAKE_0_BINARY <= "011000";
           when   25  =>  SATA_MAX_WAKE_0_BINARY <= "011001";
           when   26  =>  SATA_MAX_WAKE_0_BINARY <= "011010";
           when   27  =>  SATA_MAX_WAKE_0_BINARY <= "011011";
           when   28  =>  SATA_MAX_WAKE_0_BINARY <= "011100";
           when   29  =>  SATA_MAX_WAKE_0_BINARY <= "011101";
           when   30  =>  SATA_MAX_WAKE_0_BINARY <= "011110";
           when   31  =>  SATA_MAX_WAKE_0_BINARY <= "011111";
           when   32  =>  SATA_MAX_WAKE_0_BINARY <= "100000";
           when   33  =>  SATA_MAX_WAKE_0_BINARY <= "100001";
           when   34  =>  SATA_MAX_WAKE_0_BINARY <= "100010";
           when   35  =>  SATA_MAX_WAKE_0_BINARY <= "100011";
           when   36  =>  SATA_MAX_WAKE_0_BINARY <= "100100";
           when   37  =>  SATA_MAX_WAKE_0_BINARY <= "100101";
           when   38  =>  SATA_MAX_WAKE_0_BINARY <= "100110";
           when   39  =>  SATA_MAX_WAKE_0_BINARY <= "100111";
           when   40  =>  SATA_MAX_WAKE_0_BINARY <= "101000";
           when   41  =>  SATA_MAX_WAKE_0_BINARY <= "101001";
           when   42  =>  SATA_MAX_WAKE_0_BINARY <= "101010";
           when   43  =>  SATA_MAX_WAKE_0_BINARY <= "101011";
           when   44  =>  SATA_MAX_WAKE_0_BINARY <= "101100";
           when   45  =>  SATA_MAX_WAKE_0_BINARY <= "101101";
           when   46  =>  SATA_MAX_WAKE_0_BINARY <= "101110";
           when   47  =>  SATA_MAX_WAKE_0_BINARY <= "101111";
           when   48  =>  SATA_MAX_WAKE_0_BINARY <= "110000";
           when   49  =>  SATA_MAX_WAKE_0_BINARY <= "110001";
           when   50  =>  SATA_MAX_WAKE_0_BINARY <= "110010";
           when   51  =>  SATA_MAX_WAKE_0_BINARY <= "110011";
           when   52  =>  SATA_MAX_WAKE_0_BINARY <= "110100";
           when   53  =>  SATA_MAX_WAKE_0_BINARY <= "110101";
           when   54  =>  SATA_MAX_WAKE_0_BINARY <= "110110";
           when   55  =>  SATA_MAX_WAKE_0_BINARY <= "110111";
           when   56  =>  SATA_MAX_WAKE_0_BINARY <= "111000";
           when   57  =>  SATA_MAX_WAKE_0_BINARY <= "111001";
           when   58  =>  SATA_MAX_WAKE_0_BINARY <= "111010";
           when   59  =>  SATA_MAX_WAKE_0_BINARY <= "111011";
           when   60  =>  SATA_MAX_WAKE_0_BINARY <= "111100";
           when   61  =>  SATA_MAX_WAKE_0_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MAX_WAKE_0 is not in range 1...61." severity error;
       end case;
       case SATA_MIN_BURST_1 is
           when   1  =>  SATA_MIN_BURST_1_BINARY <= "000001";
           when   2  =>  SATA_MIN_BURST_1_BINARY <= "000010";
           when   3  =>  SATA_MIN_BURST_1_BINARY <= "000011";
           when   4  =>  SATA_MIN_BURST_1_BINARY <= "000100";
           when   5  =>  SATA_MIN_BURST_1_BINARY <= "000101";
           when   6  =>  SATA_MIN_BURST_1_BINARY <= "000110";
           when   7  =>  SATA_MIN_BURST_1_BINARY <= "000111";
           when   8  =>  SATA_MIN_BURST_1_BINARY <= "001000";
           when   9  =>  SATA_MIN_BURST_1_BINARY <= "001001";
           when   10  =>  SATA_MIN_BURST_1_BINARY <= "001010";
           when   11  =>  SATA_MIN_BURST_1_BINARY <= "001011";
           when   12  =>  SATA_MIN_BURST_1_BINARY <= "001100";
           when   13  =>  SATA_MIN_BURST_1_BINARY <= "001101";
           when   14  =>  SATA_MIN_BURST_1_BINARY <= "001110";
           when   15  =>  SATA_MIN_BURST_1_BINARY <= "001111";
           when   16  =>  SATA_MIN_BURST_1_BINARY <= "010000";
           when   17  =>  SATA_MIN_BURST_1_BINARY <= "010001";
           when   18  =>  SATA_MIN_BURST_1_BINARY <= "010010";
           when   19  =>  SATA_MIN_BURST_1_BINARY <= "010011";
           when   20  =>  SATA_MIN_BURST_1_BINARY <= "010100";
           when   21  =>  SATA_MIN_BURST_1_BINARY <= "010101";
           when   22  =>  SATA_MIN_BURST_1_BINARY <= "010110";
           when   23  =>  SATA_MIN_BURST_1_BINARY <= "010111";
           when   24  =>  SATA_MIN_BURST_1_BINARY <= "011000";
           when   25  =>  SATA_MIN_BURST_1_BINARY <= "011001";
           when   26  =>  SATA_MIN_BURST_1_BINARY <= "011010";
           when   27  =>  SATA_MIN_BURST_1_BINARY <= "011011";
           when   28  =>  SATA_MIN_BURST_1_BINARY <= "011100";
           when   29  =>  SATA_MIN_BURST_1_BINARY <= "011101";
           when   30  =>  SATA_MIN_BURST_1_BINARY <= "011110";
           when   31  =>  SATA_MIN_BURST_1_BINARY <= "011111";
           when   32  =>  SATA_MIN_BURST_1_BINARY <= "100000";
           when   33  =>  SATA_MIN_BURST_1_BINARY <= "100001";
           when   34  =>  SATA_MIN_BURST_1_BINARY <= "100010";
           when   35  =>  SATA_MIN_BURST_1_BINARY <= "100011";
           when   36  =>  SATA_MIN_BURST_1_BINARY <= "100100";
           when   37  =>  SATA_MIN_BURST_1_BINARY <= "100101";
           when   38  =>  SATA_MIN_BURST_1_BINARY <= "100110";
           when   39  =>  SATA_MIN_BURST_1_BINARY <= "100111";
           when   40  =>  SATA_MIN_BURST_1_BINARY <= "101000";
           when   41  =>  SATA_MIN_BURST_1_BINARY <= "101001";
           when   42  =>  SATA_MIN_BURST_1_BINARY <= "101010";
           when   43  =>  SATA_MIN_BURST_1_BINARY <= "101011";
           when   44  =>  SATA_MIN_BURST_1_BINARY <= "101100";
           when   45  =>  SATA_MIN_BURST_1_BINARY <= "101101";
           when   46  =>  SATA_MIN_BURST_1_BINARY <= "101110";
           when   47  =>  SATA_MIN_BURST_1_BINARY <= "101111";
           when   48  =>  SATA_MIN_BURST_1_BINARY <= "110000";
           when   49  =>  SATA_MIN_BURST_1_BINARY <= "110001";
           when   50  =>  SATA_MIN_BURST_1_BINARY <= "110010";
           when   51  =>  SATA_MIN_BURST_1_BINARY <= "110011";
           when   52  =>  SATA_MIN_BURST_1_BINARY <= "110100";
           when   53  =>  SATA_MIN_BURST_1_BINARY <= "110101";
           when   54  =>  SATA_MIN_BURST_1_BINARY <= "110110";
           when   55  =>  SATA_MIN_BURST_1_BINARY <= "110111";
           when   56  =>  SATA_MIN_BURST_1_BINARY <= "111000";
           when   57  =>  SATA_MIN_BURST_1_BINARY <= "111001";
           when   58  =>  SATA_MIN_BURST_1_BINARY <= "111010";
           when   59  =>  SATA_MIN_BURST_1_BINARY <= "111011";
           when   60  =>  SATA_MIN_BURST_1_BINARY <= "111100";
           when   61  =>  SATA_MIN_BURST_1_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MIN_BURST_1 is not in range 1...61." severity error;
       end case;
       case SATA_MAX_BURST_1 is
           when   1  =>  SATA_MAX_BURST_1_BINARY <= "000001";
           when   2  =>  SATA_MAX_BURST_1_BINARY <= "000010";
           when   3  =>  SATA_MAX_BURST_1_BINARY <= "000011";
           when   4  =>  SATA_MAX_BURST_1_BINARY <= "000100";
           when   5  =>  SATA_MAX_BURST_1_BINARY <= "000101";
           when   6  =>  SATA_MAX_BURST_1_BINARY <= "000110";
           when   7  =>  SATA_MAX_BURST_1_BINARY <= "000111";
           when   8  =>  SATA_MAX_BURST_1_BINARY <= "001000";
           when   9  =>  SATA_MAX_BURST_1_BINARY <= "001001";
           when   10  =>  SATA_MAX_BURST_1_BINARY <= "001010";
           when   11  =>  SATA_MAX_BURST_1_BINARY <= "001011";
           when   12  =>  SATA_MAX_BURST_1_BINARY <= "001100";
           when   13  =>  SATA_MAX_BURST_1_BINARY <= "001101";
           when   14  =>  SATA_MAX_BURST_1_BINARY <= "001110";
           when   15  =>  SATA_MAX_BURST_1_BINARY <= "001111";
           when   16  =>  SATA_MAX_BURST_1_BINARY <= "010000";
           when   17  =>  SATA_MAX_BURST_1_BINARY <= "010001";
           when   18  =>  SATA_MAX_BURST_1_BINARY <= "010010";
           when   19  =>  SATA_MAX_BURST_1_BINARY <= "010011";
           when   20  =>  SATA_MAX_BURST_1_BINARY <= "010100";
           when   21  =>  SATA_MAX_BURST_1_BINARY <= "010101";
           when   22  =>  SATA_MAX_BURST_1_BINARY <= "010110";
           when   23  =>  SATA_MAX_BURST_1_BINARY <= "010111";
           when   24  =>  SATA_MAX_BURST_1_BINARY <= "011000";
           when   25  =>  SATA_MAX_BURST_1_BINARY <= "011001";
           when   26  =>  SATA_MAX_BURST_1_BINARY <= "011010";
           when   27  =>  SATA_MAX_BURST_1_BINARY <= "011011";
           when   28  =>  SATA_MAX_BURST_1_BINARY <= "011100";
           when   29  =>  SATA_MAX_BURST_1_BINARY <= "011101";
           when   30  =>  SATA_MAX_BURST_1_BINARY <= "011110";
           when   31  =>  SATA_MAX_BURST_1_BINARY <= "011111";
           when   32  =>  SATA_MAX_BURST_1_BINARY <= "100000";
           when   33  =>  SATA_MAX_BURST_1_BINARY <= "100001";
           when   34  =>  SATA_MAX_BURST_1_BINARY <= "100010";
           when   35  =>  SATA_MAX_BURST_1_BINARY <= "100011";
           when   36  =>  SATA_MAX_BURST_1_BINARY <= "100100";
           when   37  =>  SATA_MAX_BURST_1_BINARY <= "100101";
           when   38  =>  SATA_MAX_BURST_1_BINARY <= "100110";
           when   39  =>  SATA_MAX_BURST_1_BINARY <= "100111";
           when   40  =>  SATA_MAX_BURST_1_BINARY <= "101000";
           when   41  =>  SATA_MAX_BURST_1_BINARY <= "101001";
           when   42  =>  SATA_MAX_BURST_1_BINARY <= "101010";
           when   43  =>  SATA_MAX_BURST_1_BINARY <= "101011";
           when   44  =>  SATA_MAX_BURST_1_BINARY <= "101100";
           when   45  =>  SATA_MAX_BURST_1_BINARY <= "101101";
           when   46  =>  SATA_MAX_BURST_1_BINARY <= "101110";
           when   47  =>  SATA_MAX_BURST_1_BINARY <= "101111";
           when   48  =>  SATA_MAX_BURST_1_BINARY <= "110000";
           when   49  =>  SATA_MAX_BURST_1_BINARY <= "110001";
           when   50  =>  SATA_MAX_BURST_1_BINARY <= "110010";
           when   51  =>  SATA_MAX_BURST_1_BINARY <= "110011";
           when   52  =>  SATA_MAX_BURST_1_BINARY <= "110100";
           when   53  =>  SATA_MAX_BURST_1_BINARY <= "110101";
           when   54  =>  SATA_MAX_BURST_1_BINARY <= "110110";
           when   55  =>  SATA_MAX_BURST_1_BINARY <= "110111";
           when   56  =>  SATA_MAX_BURST_1_BINARY <= "111000";
           when   57  =>  SATA_MAX_BURST_1_BINARY <= "111001";
           when   58  =>  SATA_MAX_BURST_1_BINARY <= "111010";
           when   59  =>  SATA_MAX_BURST_1_BINARY <= "111011";
           when   60  =>  SATA_MAX_BURST_1_BINARY <= "111100";
           when   61  =>  SATA_MAX_BURST_1_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MAX_BURST_1 is not in range 1...61." severity error;
       end case;
       case SATA_MIN_INIT_1 is
           when   1  =>  SATA_MIN_INIT_1_BINARY <= "000001";
           when   2  =>  SATA_MIN_INIT_1_BINARY <= "000010";
           when   3  =>  SATA_MIN_INIT_1_BINARY <= "000011";
           when   4  =>  SATA_MIN_INIT_1_BINARY <= "000100";
           when   5  =>  SATA_MIN_INIT_1_BINARY <= "000101";
           when   6  =>  SATA_MIN_INIT_1_BINARY <= "000110";
           when   7  =>  SATA_MIN_INIT_1_BINARY <= "000111";
           when   8  =>  SATA_MIN_INIT_1_BINARY <= "001000";
           when   9  =>  SATA_MIN_INIT_1_BINARY <= "001001";
           when   10  =>  SATA_MIN_INIT_1_BINARY <= "001010";
           when   11  =>  SATA_MIN_INIT_1_BINARY <= "001011";
           when   12  =>  SATA_MIN_INIT_1_BINARY <= "001100";
           when   13  =>  SATA_MIN_INIT_1_BINARY <= "001101";
           when   14  =>  SATA_MIN_INIT_1_BINARY <= "001110";
           when   15  =>  SATA_MIN_INIT_1_BINARY <= "001111";
           when   16  =>  SATA_MIN_INIT_1_BINARY <= "010000";
           when   17  =>  SATA_MIN_INIT_1_BINARY <= "010001";
           when   18  =>  SATA_MIN_INIT_1_BINARY <= "010010";
           when   19  =>  SATA_MIN_INIT_1_BINARY <= "010011";
           when   20  =>  SATA_MIN_INIT_1_BINARY <= "010100";
           when   21  =>  SATA_MIN_INIT_1_BINARY <= "010101";
           when   22  =>  SATA_MIN_INIT_1_BINARY <= "010110";
           when   23  =>  SATA_MIN_INIT_1_BINARY <= "010111";
           when   24  =>  SATA_MIN_INIT_1_BINARY <= "011000";
           when   25  =>  SATA_MIN_INIT_1_BINARY <= "011001";
           when   26  =>  SATA_MIN_INIT_1_BINARY <= "011010";
           when   27  =>  SATA_MIN_INIT_1_BINARY <= "011011";
           when   28  =>  SATA_MIN_INIT_1_BINARY <= "011100";
           when   29  =>  SATA_MIN_INIT_1_BINARY <= "011101";
           when   30  =>  SATA_MIN_INIT_1_BINARY <= "011110";
           when   31  =>  SATA_MIN_INIT_1_BINARY <= "011111";
           when   32  =>  SATA_MIN_INIT_1_BINARY <= "100000";
           when   33  =>  SATA_MIN_INIT_1_BINARY <= "100001";
           when   34  =>  SATA_MIN_INIT_1_BINARY <= "100010";
           when   35  =>  SATA_MIN_INIT_1_BINARY <= "100011";
           when   36  =>  SATA_MIN_INIT_1_BINARY <= "100100";
           when   37  =>  SATA_MIN_INIT_1_BINARY <= "100101";
           when   38  =>  SATA_MIN_INIT_1_BINARY <= "100110";
           when   39  =>  SATA_MIN_INIT_1_BINARY <= "100111";
           when   40  =>  SATA_MIN_INIT_1_BINARY <= "101000";
           when   41  =>  SATA_MIN_INIT_1_BINARY <= "101001";
           when   42  =>  SATA_MIN_INIT_1_BINARY <= "101010";
           when   43  =>  SATA_MIN_INIT_1_BINARY <= "101011";
           when   44  =>  SATA_MIN_INIT_1_BINARY <= "101100";
           when   45  =>  SATA_MIN_INIT_1_BINARY <= "101101";
           when   46  =>  SATA_MIN_INIT_1_BINARY <= "101110";
           when   47  =>  SATA_MIN_INIT_1_BINARY <= "101111";
           when   48  =>  SATA_MIN_INIT_1_BINARY <= "110000";
           when   49  =>  SATA_MIN_INIT_1_BINARY <= "110001";
           when   50  =>  SATA_MIN_INIT_1_BINARY <= "110010";
           when   51  =>  SATA_MIN_INIT_1_BINARY <= "110011";
           when   52  =>  SATA_MIN_INIT_1_BINARY <= "110100";
           when   53  =>  SATA_MIN_INIT_1_BINARY <= "110101";
           when   54  =>  SATA_MIN_INIT_1_BINARY <= "110110";
           when   55  =>  SATA_MIN_INIT_1_BINARY <= "110111";
           when   56  =>  SATA_MIN_INIT_1_BINARY <= "111000";
           when   57  =>  SATA_MIN_INIT_1_BINARY <= "111001";
           when   58  =>  SATA_MIN_INIT_1_BINARY <= "111010";
           when   59  =>  SATA_MIN_INIT_1_BINARY <= "111011";
           when   60  =>  SATA_MIN_INIT_1_BINARY <= "111100";
           when   61  =>  SATA_MIN_INIT_1_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MIN_INIT_1 is not in range 1...61." severity error;
       end case;
       case SATA_MAX_INIT_1 is
           when   1  =>  SATA_MAX_INIT_1_BINARY <= "000001";
           when   2  =>  SATA_MAX_INIT_1_BINARY <= "000010";
           when   3  =>  SATA_MAX_INIT_1_BINARY <= "000011";
           when   4  =>  SATA_MAX_INIT_1_BINARY <= "000100";
           when   5  =>  SATA_MAX_INIT_1_BINARY <= "000101";
           when   6  =>  SATA_MAX_INIT_1_BINARY <= "000110";
           when   7  =>  SATA_MAX_INIT_1_BINARY <= "000111";
           when   8  =>  SATA_MAX_INIT_1_BINARY <= "001000";
           when   9  =>  SATA_MAX_INIT_1_BINARY <= "001001";
           when   10  =>  SATA_MAX_INIT_1_BINARY <= "001010";
           when   11  =>  SATA_MAX_INIT_1_BINARY <= "001011";
           when   12  =>  SATA_MAX_INIT_1_BINARY <= "001100";
           when   13  =>  SATA_MAX_INIT_1_BINARY <= "001101";
           when   14  =>  SATA_MAX_INIT_1_BINARY <= "001110";
           when   15  =>  SATA_MAX_INIT_1_BINARY <= "001111";
           when   16  =>  SATA_MAX_INIT_1_BINARY <= "010000";
           when   17  =>  SATA_MAX_INIT_1_BINARY <= "010001";
           when   18  =>  SATA_MAX_INIT_1_BINARY <= "010010";
           when   19  =>  SATA_MAX_INIT_1_BINARY <= "010011";
           when   20  =>  SATA_MAX_INIT_1_BINARY <= "010100";
           when   21  =>  SATA_MAX_INIT_1_BINARY <= "010101";
           when   22  =>  SATA_MAX_INIT_1_BINARY <= "010110";
           when   23  =>  SATA_MAX_INIT_1_BINARY <= "010111";
           when   24  =>  SATA_MAX_INIT_1_BINARY <= "011000";
           when   25  =>  SATA_MAX_INIT_1_BINARY <= "011001";
           when   26  =>  SATA_MAX_INIT_1_BINARY <= "011010";
           when   27  =>  SATA_MAX_INIT_1_BINARY <= "011011";
           when   28  =>  SATA_MAX_INIT_1_BINARY <= "011100";
           when   29  =>  SATA_MAX_INIT_1_BINARY <= "011101";
           when   30  =>  SATA_MAX_INIT_1_BINARY <= "011110";
           when   31  =>  SATA_MAX_INIT_1_BINARY <= "011111";
           when   32  =>  SATA_MAX_INIT_1_BINARY <= "100000";
           when   33  =>  SATA_MAX_INIT_1_BINARY <= "100001";
           when   34  =>  SATA_MAX_INIT_1_BINARY <= "100010";
           when   35  =>  SATA_MAX_INIT_1_BINARY <= "100011";
           when   36  =>  SATA_MAX_INIT_1_BINARY <= "100100";
           when   37  =>  SATA_MAX_INIT_1_BINARY <= "100101";
           when   38  =>  SATA_MAX_INIT_1_BINARY <= "100110";
           when   39  =>  SATA_MAX_INIT_1_BINARY <= "100111";
           when   40  =>  SATA_MAX_INIT_1_BINARY <= "101000";
           when   41  =>  SATA_MAX_INIT_1_BINARY <= "101001";
           when   42  =>  SATA_MAX_INIT_1_BINARY <= "101010";
           when   43  =>  SATA_MAX_INIT_1_BINARY <= "101011";
           when   44  =>  SATA_MAX_INIT_1_BINARY <= "101100";
           when   45  =>  SATA_MAX_INIT_1_BINARY <= "101101";
           when   46  =>  SATA_MAX_INIT_1_BINARY <= "101110";
           when   47  =>  SATA_MAX_INIT_1_BINARY <= "101111";
           when   48  =>  SATA_MAX_INIT_1_BINARY <= "110000";
           when   49  =>  SATA_MAX_INIT_1_BINARY <= "110001";
           when   50  =>  SATA_MAX_INIT_1_BINARY <= "110010";
           when   51  =>  SATA_MAX_INIT_1_BINARY <= "110011";
           when   52  =>  SATA_MAX_INIT_1_BINARY <= "110100";
           when   53  =>  SATA_MAX_INIT_1_BINARY <= "110101";
           when   54  =>  SATA_MAX_INIT_1_BINARY <= "110110";
           when   55  =>  SATA_MAX_INIT_1_BINARY <= "110111";
           when   56  =>  SATA_MAX_INIT_1_BINARY <= "111000";
           when   57  =>  SATA_MAX_INIT_1_BINARY <= "111001";
           when   58  =>  SATA_MAX_INIT_1_BINARY <= "111010";
           when   59  =>  SATA_MAX_INIT_1_BINARY <= "111011";
           when   60  =>  SATA_MAX_INIT_1_BINARY <= "111100";
           when   61  =>  SATA_MAX_INIT_1_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MAX_INIT_1 is not in range 1...61." severity error;
       end case;
       case SATA_MIN_WAKE_1 is
           when   1  =>  SATA_MIN_WAKE_1_BINARY <= "000001";
           when   2  =>  SATA_MIN_WAKE_1_BINARY <= "000010";
           when   3  =>  SATA_MIN_WAKE_1_BINARY <= "000011";
           when   4  =>  SATA_MIN_WAKE_1_BINARY <= "000100";
           when   5  =>  SATA_MIN_WAKE_1_BINARY <= "000101";
           when   6  =>  SATA_MIN_WAKE_1_BINARY <= "000110";
           when   7  =>  SATA_MIN_WAKE_1_BINARY <= "000111";
           when   8  =>  SATA_MIN_WAKE_1_BINARY <= "001000";
           when   9  =>  SATA_MIN_WAKE_1_BINARY <= "001001";
           when   10  =>  SATA_MIN_WAKE_1_BINARY <= "001010";
           when   11  =>  SATA_MIN_WAKE_1_BINARY <= "001011";
           when   12  =>  SATA_MIN_WAKE_1_BINARY <= "001100";
           when   13  =>  SATA_MIN_WAKE_1_BINARY <= "001101";
           when   14  =>  SATA_MIN_WAKE_1_BINARY <= "001110";
           when   15  =>  SATA_MIN_WAKE_1_BINARY <= "001111";
           when   16  =>  SATA_MIN_WAKE_1_BINARY <= "010000";
           when   17  =>  SATA_MIN_WAKE_1_BINARY <= "010001";
           when   18  =>  SATA_MIN_WAKE_1_BINARY <= "010010";
           when   19  =>  SATA_MIN_WAKE_1_BINARY <= "010011";
           when   20  =>  SATA_MIN_WAKE_1_BINARY <= "010100";
           when   21  =>  SATA_MIN_WAKE_1_BINARY <= "010101";
           when   22  =>  SATA_MIN_WAKE_1_BINARY <= "010110";
           when   23  =>  SATA_MIN_WAKE_1_BINARY <= "010111";
           when   24  =>  SATA_MIN_WAKE_1_BINARY <= "011000";
           when   25  =>  SATA_MIN_WAKE_1_BINARY <= "011001";
           when   26  =>  SATA_MIN_WAKE_1_BINARY <= "011010";
           when   27  =>  SATA_MIN_WAKE_1_BINARY <= "011011";
           when   28  =>  SATA_MIN_WAKE_1_BINARY <= "011100";
           when   29  =>  SATA_MIN_WAKE_1_BINARY <= "011101";
           when   30  =>  SATA_MIN_WAKE_1_BINARY <= "011110";
           when   31  =>  SATA_MIN_WAKE_1_BINARY <= "011111";
           when   32  =>  SATA_MIN_WAKE_1_BINARY <= "100000";
           when   33  =>  SATA_MIN_WAKE_1_BINARY <= "100001";
           when   34  =>  SATA_MIN_WAKE_1_BINARY <= "100010";
           when   35  =>  SATA_MIN_WAKE_1_BINARY <= "100011";
           when   36  =>  SATA_MIN_WAKE_1_BINARY <= "100100";
           when   37  =>  SATA_MIN_WAKE_1_BINARY <= "100101";
           when   38  =>  SATA_MIN_WAKE_1_BINARY <= "100110";
           when   39  =>  SATA_MIN_WAKE_1_BINARY <= "100111";
           when   40  =>  SATA_MIN_WAKE_1_BINARY <= "101000";
           when   41  =>  SATA_MIN_WAKE_1_BINARY <= "101001";
           when   42  =>  SATA_MIN_WAKE_1_BINARY <= "101010";
           when   43  =>  SATA_MIN_WAKE_1_BINARY <= "101011";
           when   44  =>  SATA_MIN_WAKE_1_BINARY <= "101100";
           when   45  =>  SATA_MIN_WAKE_1_BINARY <= "101101";
           when   46  =>  SATA_MIN_WAKE_1_BINARY <= "101110";
           when   47  =>  SATA_MIN_WAKE_1_BINARY <= "101111";
           when   48  =>  SATA_MIN_WAKE_1_BINARY <= "110000";
           when   49  =>  SATA_MIN_WAKE_1_BINARY <= "110001";
           when   50  =>  SATA_MIN_WAKE_1_BINARY <= "110010";
           when   51  =>  SATA_MIN_WAKE_1_BINARY <= "110011";
           when   52  =>  SATA_MIN_WAKE_1_BINARY <= "110100";
           when   53  =>  SATA_MIN_WAKE_1_BINARY <= "110101";
           when   54  =>  SATA_MIN_WAKE_1_BINARY <= "110110";
           when   55  =>  SATA_MIN_WAKE_1_BINARY <= "110111";
           when   56  =>  SATA_MIN_WAKE_1_BINARY <= "111000";
           when   57  =>  SATA_MIN_WAKE_1_BINARY <= "111001";
           when   58  =>  SATA_MIN_WAKE_1_BINARY <= "111010";
           when   59  =>  SATA_MIN_WAKE_1_BINARY <= "111011";
           when   60  =>  SATA_MIN_WAKE_1_BINARY <= "111100";
           when   61  =>  SATA_MIN_WAKE_1_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MIN_WAKE_1 is not in range 1...61." severity error;
       end case;
       case SATA_MAX_WAKE_1 is
           when   1  =>  SATA_MAX_WAKE_1_BINARY <= "000001";
           when   2  =>  SATA_MAX_WAKE_1_BINARY <= "000010";
           when   3  =>  SATA_MAX_WAKE_1_BINARY <= "000011";
           when   4  =>  SATA_MAX_WAKE_1_BINARY <= "000100";
           when   5  =>  SATA_MAX_WAKE_1_BINARY <= "000101";
           when   6  =>  SATA_MAX_WAKE_1_BINARY <= "000110";
           when   7  =>  SATA_MAX_WAKE_1_BINARY <= "000111";
           when   8  =>  SATA_MAX_WAKE_1_BINARY <= "001000";
           when   9  =>  SATA_MAX_WAKE_1_BINARY <= "001001";
           when   10  =>  SATA_MAX_WAKE_1_BINARY <= "001010";
           when   11  =>  SATA_MAX_WAKE_1_BINARY <= "001011";
           when   12  =>  SATA_MAX_WAKE_1_BINARY <= "001100";
           when   13  =>  SATA_MAX_WAKE_1_BINARY <= "001101";
           when   14  =>  SATA_MAX_WAKE_1_BINARY <= "001110";
           when   15  =>  SATA_MAX_WAKE_1_BINARY <= "001111";
           when   16  =>  SATA_MAX_WAKE_1_BINARY <= "010000";
           when   17  =>  SATA_MAX_WAKE_1_BINARY <= "010001";
           when   18  =>  SATA_MAX_WAKE_1_BINARY <= "010010";
           when   19  =>  SATA_MAX_WAKE_1_BINARY <= "010011";
           when   20  =>  SATA_MAX_WAKE_1_BINARY <= "010100";
           when   21  =>  SATA_MAX_WAKE_1_BINARY <= "010101";
           when   22  =>  SATA_MAX_WAKE_1_BINARY <= "010110";
           when   23  =>  SATA_MAX_WAKE_1_BINARY <= "010111";
           when   24  =>  SATA_MAX_WAKE_1_BINARY <= "011000";
           when   25  =>  SATA_MAX_WAKE_1_BINARY <= "011001";
           when   26  =>  SATA_MAX_WAKE_1_BINARY <= "011010";
           when   27  =>  SATA_MAX_WAKE_1_BINARY <= "011011";
           when   28  =>  SATA_MAX_WAKE_1_BINARY <= "011100";
           when   29  =>  SATA_MAX_WAKE_1_BINARY <= "011101";
           when   30  =>  SATA_MAX_WAKE_1_BINARY <= "011110";
           when   31  =>  SATA_MAX_WAKE_1_BINARY <= "011111";
           when   32  =>  SATA_MAX_WAKE_1_BINARY <= "100000";
           when   33  =>  SATA_MAX_WAKE_1_BINARY <= "100001";
           when   34  =>  SATA_MAX_WAKE_1_BINARY <= "100010";
           when   35  =>  SATA_MAX_WAKE_1_BINARY <= "100011";
           when   36  =>  SATA_MAX_WAKE_1_BINARY <= "100100";
           when   37  =>  SATA_MAX_WAKE_1_BINARY <= "100101";
           when   38  =>  SATA_MAX_WAKE_1_BINARY <= "100110";
           when   39  =>  SATA_MAX_WAKE_1_BINARY <= "100111";
           when   40  =>  SATA_MAX_WAKE_1_BINARY <= "101000";
           when   41  =>  SATA_MAX_WAKE_1_BINARY <= "101001";
           when   42  =>  SATA_MAX_WAKE_1_BINARY <= "101010";
           when   43  =>  SATA_MAX_WAKE_1_BINARY <= "101011";
           when   44  =>  SATA_MAX_WAKE_1_BINARY <= "101100";
           when   45  =>  SATA_MAX_WAKE_1_BINARY <= "101101";
           when   46  =>  SATA_MAX_WAKE_1_BINARY <= "101110";
           when   47  =>  SATA_MAX_WAKE_1_BINARY <= "101111";
           when   48  =>  SATA_MAX_WAKE_1_BINARY <= "110000";
           when   49  =>  SATA_MAX_WAKE_1_BINARY <= "110001";
           when   50  =>  SATA_MAX_WAKE_1_BINARY <= "110010";
           when   51  =>  SATA_MAX_WAKE_1_BINARY <= "110011";
           when   52  =>  SATA_MAX_WAKE_1_BINARY <= "110100";
           when   53  =>  SATA_MAX_WAKE_1_BINARY <= "110101";
           when   54  =>  SATA_MAX_WAKE_1_BINARY <= "110110";
           when   55  =>  SATA_MAX_WAKE_1_BINARY <= "110111";
           when   56  =>  SATA_MAX_WAKE_1_BINARY <= "111000";
           when   57  =>  SATA_MAX_WAKE_1_BINARY <= "111001";
           when   58  =>  SATA_MAX_WAKE_1_BINARY <= "111010";
           when   59  =>  SATA_MAX_WAKE_1_BINARY <= "111011";
           when   60  =>  SATA_MAX_WAKE_1_BINARY <= "111100";
           when   61  =>  SATA_MAX_WAKE_1_BINARY <= "111101";
           when others  =>  assert FALSE report "Error : SATA_MAX_WAKE_1 is not in range 1...61." severity error;
       end case;
       case CLK25_DIVIDER is
           when   1  =>  CLK25_DIVIDER_BINARY <= "000";
           when   2  =>  CLK25_DIVIDER_BINARY <= "001";
           when   3  =>  CLK25_DIVIDER_BINARY <= "010";
           when   4  =>  CLK25_DIVIDER_BINARY <= "011";
           when   5  =>  CLK25_DIVIDER_BINARY <= "100";
           when   6  =>  CLK25_DIVIDER_BINARY <= "101";
           when   10  =>  CLK25_DIVIDER_BINARY <= "110";
           when   12  =>  CLK25_DIVIDER_BINARY <= "111";
           when others  =>  assert FALSE report "Error : CLK25_DIVIDER is not in 1, 2, 3, 4, 5, 6, 10, 12." severity error;
       end case;
       case OVERSAMPLE_MODE is
           when FALSE   =>  OVERSAMPLE_MODE_BINARY <= '0';
           when TRUE    =>  OVERSAMPLE_MODE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : OVERSAMPLE_MODE is neither TRUE nor FALSE." severity error;
       end case;
       case TXGEARBOX_USE_0 is
           when FALSE   =>  TXGEARBOX_USE_0_BINARY <= '0';
           when TRUE    =>  TXGEARBOX_USE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TXGEARBOX_USE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case RXGEARBOX_USE_0 is
           when FALSE   =>  RXGEARBOX_USE_0_BINARY <= '0';
           when TRUE    =>  RXGEARBOX_USE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RXGEARBOX_USE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case TXGEARBOX_USE_1 is
           when FALSE   =>  TXGEARBOX_USE_1_BINARY <= '0';
           when TRUE    =>  TXGEARBOX_USE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TXGEARBOX_USE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case RXGEARBOX_USE_1 is
           when FALSE   =>  RXGEARBOX_USE_1_BINARY <= '0';
           when TRUE    =>  RXGEARBOX_USE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RXGEARBOX_USE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case PLL_FB_DCCEN is
           when FALSE   =>  PLL_FB_DCCEN_BINARY <= '0';
           when TRUE    =>  PLL_FB_DCCEN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PLL_FB_DCCEN is neither TRUE nor FALSE." severity error;
       end case;
       case CLKRCV_TRST is
           when FALSE   =>  CLKRCV_TRST_BINARY <= '0';
           when TRUE    =>  CLKRCV_TRST_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLKRCV_TRST is neither TRUE nor FALSE." severity error;
       end case;
       case RX_EN_IDLE_HOLD_DFE_0 is
           when FALSE   =>  RX_EN_IDLE_HOLD_DFE_0_BINARY <= '0';
           when TRUE    =>  RX_EN_IDLE_HOLD_DFE_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_EN_IDLE_HOLD_DFE_0 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_EN_IDLE_RESET_BUF_0 is
           when FALSE   =>  RX_EN_IDLE_RESET_BUF_0_BINARY <= '0';
           when TRUE    =>  RX_EN_IDLE_RESET_BUF_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_BUF_0 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_EN_IDLE_HOLD_DFE_1 is
           when FALSE   =>  RX_EN_IDLE_HOLD_DFE_1_BINARY <= '0';
           when TRUE    =>  RX_EN_IDLE_HOLD_DFE_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_EN_IDLE_HOLD_DFE_1 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_EN_IDLE_RESET_BUF_1 is
           when FALSE   =>  RX_EN_IDLE_RESET_BUF_1_BINARY <= '0';
           when TRUE    =>  RX_EN_IDLE_RESET_BUF_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_BUF_1 is neither TRUE nor FALSE." severity error;
       end case;
       case RX_EN_IDLE_HOLD_CDR is
           when FALSE   =>  RX_EN_IDLE_HOLD_CDR_BINARY <= '0';
           when TRUE    =>  RX_EN_IDLE_HOLD_CDR_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_EN_IDLE_HOLD_CDR is neither TRUE nor FALSE." severity error;
       end case;
       case RX_EN_IDLE_RESET_PH is
           when FALSE   =>  RX_EN_IDLE_RESET_PH_BINARY <= '0';
           when TRUE    =>  RX_EN_IDLE_RESET_PH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_PH is neither TRUE nor FALSE." severity error;
       end case;
       case RX_EN_IDLE_RESET_FR is
           when FALSE   =>  RX_EN_IDLE_RESET_FR_BINARY <= '0';
           when TRUE    =>  RX_EN_IDLE_RESET_FR_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_FR is neither TRUE nor FALSE." severity error;
       end case;
       case SIM_GTXRESET_SPEEDUP is
           when   0  =>  SIM_GTXRESET_SPEEDUP_BINARY <= '0';
           when   1  =>  SIM_GTXRESET_SPEEDUP_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SIM_GTXRESET_SPEEDUP is not in 0, 1." severity error;
       end case;
--     case SIM_MODE is
           if((SIM_MODE = "FAST") or (SIM_MODE = "fast")) then
               SIM_MODE_BINARY <= '1';
           elsif ((SIM_MODE = "LEGACY") or (SIM_MODE = "legacy")) then 
             assert FALSE report "Warning : The Attribute SIM_MODE on GTX_DUAL instance is set to LEGACY. The Legacy model is not supported from ISE 11.1 onwards. GTX_DUAL defaults to FAST model. There are no functionality differences between GTX_DUAL LEGACY and GTX_DUAL FAST simulation models. Although, if you want to use the GTX_DUAL LEGACY model, please use an earlier ISE build." severity warning;
            else
              assert FALSE report "Warning : The Attribute SIM_MODE on GTX_DUAL instance is not set to FAST." severity warning;
           end if;
--     end case;
       case SIM_RECEIVER_DETECT_PASS_0 is
           when FALSE   =>  SIM_RECEIVER_DETECT_PASS_0_BINARY <= '0';
           when TRUE    =>  SIM_RECEIVER_DETECT_PASS_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SIM_RECEIVER_DETECT_PASS_0 is neither TRUE nor FALSE." severity error;
       end case;
       case SIM_RECEIVER_DETECT_PASS_1 is
           when FALSE   =>  SIM_RECEIVER_DETECT_PASS_1_BINARY <= '0';
           when TRUE    =>  SIM_RECEIVER_DETECT_PASS_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SIM_RECEIVER_DETECT_PASS_1 is neither TRUE nor FALSE." severity error;
       end case;
	wait;
	end process INIPROC;

	TIMING : process



	variable  REFCLKOUT_GlitchData : VitalGlitchDataType;
	variable  RXRECCLK0_GlitchData : VitalGlitchDataType;
	variable  TXOUTCLK0_GlitchData : VitalGlitchDataType;
	variable  RXRECCLK1_GlitchData : VitalGlitchDataType;
	variable  TXOUTCLK1_GlitchData : VitalGlitchDataType;
	variable  TXP0_GlitchData : VitalGlitchDataType;
	variable  TXN0_GlitchData : VitalGlitchDataType;
	variable  TXP1_GlitchData : VitalGlitchDataType;
	variable  TXN1_GlitchData : VitalGlitchDataType;
	variable  RXDATA00_GlitchData : VitalGlitchDataType;
	variable  RXDATA01_GlitchData : VitalGlitchDataType;
	variable  RXDATA02_GlitchData : VitalGlitchDataType;
	variable  RXDATA03_GlitchData : VitalGlitchDataType;
	variable  RXDATA04_GlitchData : VitalGlitchDataType;
	variable  RXDATA05_GlitchData : VitalGlitchDataType;
	variable  RXDATA06_GlitchData : VitalGlitchDataType;
	variable  RXDATA07_GlitchData : VitalGlitchDataType;
	variable  RXDATA08_GlitchData : VitalGlitchDataType;
	variable  RXDATA09_GlitchData : VitalGlitchDataType;
	variable  RXDATA010_GlitchData : VitalGlitchDataType;
	variable  RXDATA011_GlitchData : VitalGlitchDataType;
	variable  RXDATA012_GlitchData : VitalGlitchDataType;
	variable  RXDATA013_GlitchData : VitalGlitchDataType;
	variable  RXDATA014_GlitchData : VitalGlitchDataType;
	variable  RXDATA015_GlitchData : VitalGlitchDataType;
	variable  RXDATA016_GlitchData : VitalGlitchDataType;
	variable  RXDATA017_GlitchData : VitalGlitchDataType;
	variable  RXDATA018_GlitchData : VitalGlitchDataType;
	variable  RXDATA019_GlitchData : VitalGlitchDataType;
	variable  RXDATA020_GlitchData : VitalGlitchDataType;
	variable  RXDATA021_GlitchData : VitalGlitchDataType;
	variable  RXDATA022_GlitchData : VitalGlitchDataType;
	variable  RXDATA023_GlitchData : VitalGlitchDataType;
	variable  RXDATA024_GlitchData : VitalGlitchDataType;
	variable  RXDATA025_GlitchData : VitalGlitchDataType;
	variable  RXDATA026_GlitchData : VitalGlitchDataType;
	variable  RXDATA027_GlitchData : VitalGlitchDataType;
	variable  RXDATA028_GlitchData : VitalGlitchDataType;
	variable  RXDATA029_GlitchData : VitalGlitchDataType;
	variable  RXDATA030_GlitchData : VitalGlitchDataType;
	variable  RXDATA031_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE00_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE01_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE02_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE03_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR00_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR01_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR02_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR03_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK00_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK01_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK02_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK03_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP00_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP01_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP02_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP03_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA00_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA01_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA02_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA03_GlitchData : VitalGlitchDataType;
	variable  RXVALID0_GlitchData : VitalGlitchDataType;
	variable  RXDATA10_GlitchData : VitalGlitchDataType;
	variable  RXDATA11_GlitchData : VitalGlitchDataType;
	variable  RXDATA12_GlitchData : VitalGlitchDataType;
	variable  RXDATA13_GlitchData : VitalGlitchDataType;
	variable  RXDATA14_GlitchData : VitalGlitchDataType;
	variable  RXDATA15_GlitchData : VitalGlitchDataType;
	variable  RXDATA16_GlitchData : VitalGlitchDataType;
	variable  RXDATA17_GlitchData : VitalGlitchDataType;
	variable  RXDATA18_GlitchData : VitalGlitchDataType;
	variable  RXDATA19_GlitchData : VitalGlitchDataType;
	variable  RXDATA110_GlitchData : VitalGlitchDataType;
	variable  RXDATA111_GlitchData : VitalGlitchDataType;
	variable  RXDATA112_GlitchData : VitalGlitchDataType;
	variable  RXDATA113_GlitchData : VitalGlitchDataType;
	variable  RXDATA114_GlitchData : VitalGlitchDataType;
	variable  RXDATA115_GlitchData : VitalGlitchDataType;
	variable  RXDATA116_GlitchData : VitalGlitchDataType;
	variable  RXDATA117_GlitchData : VitalGlitchDataType;
	variable  RXDATA118_GlitchData : VitalGlitchDataType;
	variable  RXDATA119_GlitchData : VitalGlitchDataType;
	variable  RXDATA120_GlitchData : VitalGlitchDataType;
	variable  RXDATA121_GlitchData : VitalGlitchDataType;
	variable  RXDATA122_GlitchData : VitalGlitchDataType;
	variable  RXDATA123_GlitchData : VitalGlitchDataType;
	variable  RXDATA124_GlitchData : VitalGlitchDataType;
	variable  RXDATA125_GlitchData : VitalGlitchDataType;
	variable  RXDATA126_GlitchData : VitalGlitchDataType;
	variable  RXDATA127_GlitchData : VitalGlitchDataType;
	variable  RXDATA128_GlitchData : VitalGlitchDataType;
	variable  RXDATA129_GlitchData : VitalGlitchDataType;
	variable  RXDATA130_GlitchData : VitalGlitchDataType;
	variable  RXDATA131_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE10_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE11_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE12_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE13_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR10_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR11_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR12_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR13_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK10_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK11_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK12_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK13_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP10_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP11_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP12_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP13_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA10_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA11_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA12_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA13_GlitchData : VitalGlitchDataType;
	variable  RXVALID1_GlitchData : VitalGlitchDataType;
	variable  RESETDONE0_GlitchData : VitalGlitchDataType;
	variable  RESETDONE1_GlitchData : VitalGlitchDataType;
	variable  TXKERR00_GlitchData : VitalGlitchDataType;
	variable  TXKERR01_GlitchData : VitalGlitchDataType;
	variable  TXKERR02_GlitchData : VitalGlitchDataType;
	variable  TXKERR03_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP00_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP01_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP02_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP03_GlitchData : VitalGlitchDataType;
	variable  TXBUFSTATUS00_GlitchData : VitalGlitchDataType;
	variable  TXBUFSTATUS01_GlitchData : VitalGlitchDataType;
	variable  TXKERR10_GlitchData : VitalGlitchDataType;
	variable  TXKERR11_GlitchData : VitalGlitchDataType;
	variable  TXKERR12_GlitchData : VitalGlitchDataType;
	variable  TXKERR13_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP10_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP11_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP12_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP13_GlitchData : VitalGlitchDataType;
	variable  TXBUFSTATUS10_GlitchData : VitalGlitchDataType;
	variable  TXBUFSTATUS11_GlitchData : VitalGlitchDataType;
	variable  RXCOMMADET0_GlitchData : VitalGlitchDataType;
	variable  RXBYTEREALIGN0_GlitchData : VitalGlitchDataType;
	variable  RXBYTEISALIGNED0_GlitchData : VitalGlitchDataType;
	variable  RXLOSSOFSYNC00_GlitchData : VitalGlitchDataType;
	variable  RXLOSSOFSYNC01_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO00_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO01_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO02_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO03_GlitchData : VitalGlitchDataType;
	variable  RXCHANBONDSEQ0_GlitchData : VitalGlitchDataType;
	variable  RXCHANREALIGN0_GlitchData : VitalGlitchDataType;
	variable  RXCHANISALIGNED0_GlitchData : VitalGlitchDataType;
	variable  RXBUFSTATUS00_GlitchData : VitalGlitchDataType;
	variable  RXBUFSTATUS01_GlitchData : VitalGlitchDataType;
	variable  RXBUFSTATUS02_GlitchData : VitalGlitchDataType;
	variable  RXCOMMADET1_GlitchData : VitalGlitchDataType;
	variable  RXBYTEREALIGN1_GlitchData : VitalGlitchDataType;
	variable  RXBYTEISALIGNED1_GlitchData : VitalGlitchDataType;
	variable  RXLOSSOFSYNC10_GlitchData : VitalGlitchDataType;
	variable  RXLOSSOFSYNC11_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO10_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO11_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO12_GlitchData : VitalGlitchDataType;
	variable  RXCHBONDO13_GlitchData : VitalGlitchDataType;
	variable  RXCHANBONDSEQ1_GlitchData : VitalGlitchDataType;
	variable  RXCHANREALIGN1_GlitchData : VitalGlitchDataType;
	variable  RXCHANISALIGNED1_GlitchData : VitalGlitchDataType;
	variable  RXBUFSTATUS10_GlitchData : VitalGlitchDataType;
	variable  RXBUFSTATUS11_GlitchData : VitalGlitchDataType;
	variable  RXBUFSTATUS12_GlitchData : VitalGlitchDataType;
	variable  PHYSTATUS0_GlitchData : VitalGlitchDataType;
	variable  PHYSTATUS1_GlitchData : VitalGlitchDataType;
	variable  RXELECIDLE0_GlitchData : VitalGlitchDataType;
	variable  RXSTATUS00_GlitchData : VitalGlitchDataType;
	variable  RXSTATUS01_GlitchData : VitalGlitchDataType;
	variable  RXSTATUS02_GlitchData : VitalGlitchDataType;
	variable  RXCLKCORCNT00_GlitchData : VitalGlitchDataType;
	variable  RXCLKCORCNT01_GlitchData : VitalGlitchDataType;
	variable  RXCLKCORCNT02_GlitchData : VitalGlitchDataType;
	variable  RXELECIDLE1_GlitchData : VitalGlitchDataType;
	variable  RXSTATUS10_GlitchData : VitalGlitchDataType;
	variable  RXSTATUS11_GlitchData : VitalGlitchDataType;
	variable  RXSTATUS12_GlitchData : VitalGlitchDataType;
	variable  RXCLKCORCNT10_GlitchData : VitalGlitchDataType;
	variable  RXCLKCORCNT11_GlitchData : VitalGlitchDataType;
	variable  RXCLKCORCNT12_GlitchData : VitalGlitchDataType;
	variable  PLLLKDET_GlitchData : VitalGlitchDataType;
	variable  RXPRBSERR0_GlitchData : VitalGlitchDataType;
	variable  RXPRBSERR1_GlitchData : VitalGlitchDataType;
	variable  DO0_GlitchData : VitalGlitchDataType;
	variable  DO1_GlitchData : VitalGlitchDataType;
	variable  DO2_GlitchData : VitalGlitchDataType;
	variable  DO3_GlitchData : VitalGlitchDataType;
	variable  DO4_GlitchData : VitalGlitchDataType;
	variable  DO5_GlitchData : VitalGlitchDataType;
	variable  DO6_GlitchData : VitalGlitchDataType;
	variable  DO7_GlitchData : VitalGlitchDataType;
	variable  DO8_GlitchData : VitalGlitchDataType;
	variable  DO9_GlitchData : VitalGlitchDataType;
	variable  DO10_GlitchData : VitalGlitchDataType;
	variable  DO11_GlitchData : VitalGlitchDataType;
	variable  DO12_GlitchData : VitalGlitchDataType;
	variable  DO13_GlitchData : VitalGlitchDataType;
	variable  DO14_GlitchData : VitalGlitchDataType;
	variable  DO15_GlitchData : VitalGlitchDataType;
	variable  DRDY_GlitchData : VitalGlitchDataType;
	variable  RXOVERSAMPLEERR0_GlitchData : VitalGlitchDataType;
	variable  RXOVERSAMPLEERR1_GlitchData : VitalGlitchDataType;
	variable  TXGEARBOXREADY0_GlitchData : VitalGlitchDataType;
	variable  RXHEADER00_GlitchData : VitalGlitchDataType;
	variable  RXHEADER01_GlitchData : VitalGlitchDataType;
	variable  RXHEADER02_GlitchData : VitalGlitchDataType;
	variable  RXHEADERVALID0_GlitchData : VitalGlitchDataType;
	variable  RXDATAVALID0_GlitchData : VitalGlitchDataType;
	variable  RXSTARTOFSEQ0_GlitchData : VitalGlitchDataType;
	variable  TXGEARBOXREADY1_GlitchData : VitalGlitchDataType;
	variable  RXHEADER10_GlitchData : VitalGlitchDataType;
	variable  RXHEADER11_GlitchData : VitalGlitchDataType;
	variable  RXHEADER12_GlitchData : VitalGlitchDataType;
	variable  RXHEADERVALID1_GlitchData : VitalGlitchDataType;
	variable  RXDATAVALID1_GlitchData : VitalGlitchDataType;
	variable  RXSTARTOFSEQ1_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR00_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR01_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR02_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR03_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR04_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR05_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR00_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR01_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR02_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR03_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR04_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR00_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR01_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR02_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR03_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR04_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR00_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR01_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR02_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR03_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR04_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR00_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR01_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR02_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR03_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR00_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR01_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR02_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR03_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR10_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR11_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR12_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR13_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR14_GlitchData : VitalGlitchDataType;
	variable  DFECLKDLYADJMONITOR15_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR10_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR11_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR12_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR13_GlitchData : VitalGlitchDataType;
	variable  DFEEYEDACMONITOR14_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR10_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR11_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR12_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR13_GlitchData : VitalGlitchDataType;
	variable  DFETAP1MONITOR14_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR10_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR11_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR12_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR13_GlitchData : VitalGlitchDataType;
	variable  DFETAP2MONITOR14_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR10_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR11_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR12_GlitchData : VitalGlitchDataType;
	variable  DFETAP3MONITOR13_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR10_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR11_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR12_GlitchData : VitalGlitchDataType;
	variable  DFETAP4MONITOR13_GlitchData : VitalGlitchDataType;
	variable  DFESENSCAL00_GlitchData : VitalGlitchDataType;
	variable  DFESENSCAL01_GlitchData : VitalGlitchDataType;
	variable  DFESENSCAL02_GlitchData : VitalGlitchDataType;
	variable  DFESENSCAL10_GlitchData : VitalGlitchDataType;
	variable  DFESENSCAL11_GlitchData : VitalGlitchDataType;
	variable  DFESENSCAL12_GlitchData : VitalGlitchDataType;
begin

	VitalPathDelay01
	(
	OutSignal     => REFCLKOUT,
	GlitchData    => REFCLKOUT_GlitchData,
	OutSignalName => "REFCLKOUT",
	OutTemp       => REFCLKOUT_OUT,
	Paths         => (0 => (CLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(0),
	GlitchData    => RXDATA00_GlitchData,
	OutSignalName => "RXDATA0(0)",
	OutTemp       => RXDATA0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(1),
	GlitchData    => RXDATA01_GlitchData,
	OutSignalName => "RXDATA0(1)",
	OutTemp       => RXDATA0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(2),
	GlitchData    => RXDATA02_GlitchData,
	OutSignalName => "RXDATA0(2)",
	OutTemp       => RXDATA0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(3),
	GlitchData    => RXDATA03_GlitchData,
	OutSignalName => "RXDATA0(3)",
	OutTemp       => RXDATA0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(4),
	GlitchData    => RXDATA04_GlitchData,
	OutSignalName => "RXDATA0(4)",
	OutTemp       => RXDATA0_OUT(4),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(5),
	GlitchData    => RXDATA05_GlitchData,
	OutSignalName => "RXDATA0(5)",
	OutTemp       => RXDATA0_OUT(5),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(6),
	GlitchData    => RXDATA06_GlitchData,
	OutSignalName => "RXDATA0(6)",
	OutTemp       => RXDATA0_OUT(6),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(7),
	GlitchData    => RXDATA07_GlitchData,
	OutSignalName => "RXDATA0(7)",
	OutTemp       => RXDATA0_OUT(7),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(8),
	GlitchData    => RXDATA08_GlitchData,
	OutSignalName => "RXDATA0(8)",
	OutTemp       => RXDATA0_OUT(8),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(9),
	GlitchData    => RXDATA09_GlitchData,
	OutSignalName => "RXDATA0(9)",
	OutTemp       => RXDATA0_OUT(9),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(10),
	GlitchData    => RXDATA010_GlitchData,
	OutSignalName => "RXDATA0(10)",
	OutTemp       => RXDATA0_OUT(10),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(11),
	GlitchData    => RXDATA011_GlitchData,
	OutSignalName => "RXDATA0(11)",
	OutTemp       => RXDATA0_OUT(11),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(12),
	GlitchData    => RXDATA012_GlitchData,
	OutSignalName => "RXDATA0(12)",
	OutTemp       => RXDATA0_OUT(12),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(13),
	GlitchData    => RXDATA013_GlitchData,
	OutSignalName => "RXDATA0(13)",
	OutTemp       => RXDATA0_OUT(13),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(14),
	GlitchData    => RXDATA014_GlitchData,
	OutSignalName => "RXDATA0(14)",
	OutTemp       => RXDATA0_OUT(14),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(15),
	GlitchData    => RXDATA015_GlitchData,
	OutSignalName => "RXDATA0(15)",
	OutTemp       => RXDATA0_OUT(15),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(16),
	GlitchData    => RXDATA016_GlitchData,
	OutSignalName => "RXDATA0(16)",
	OutTemp       => RXDATA0_OUT(16),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(17),
	GlitchData    => RXDATA017_GlitchData,
	OutSignalName => "RXDATA0(17)",
	OutTemp       => RXDATA0_OUT(17),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(18),
	GlitchData    => RXDATA018_GlitchData,
	OutSignalName => "RXDATA0(18)",
	OutTemp       => RXDATA0_OUT(18),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(19),
	GlitchData    => RXDATA019_GlitchData,
	OutSignalName => "RXDATA0(19)",
	OutTemp       => RXDATA0_OUT(19),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(20),
	GlitchData    => RXDATA020_GlitchData,
	OutSignalName => "RXDATA0(20)",
	OutTemp       => RXDATA0_OUT(20),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(21),
	GlitchData    => RXDATA021_GlitchData,
	OutSignalName => "RXDATA0(21)",
	OutTemp       => RXDATA0_OUT(21),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(22),
	GlitchData    => RXDATA022_GlitchData,
	OutSignalName => "RXDATA0(22)",
	OutTemp       => RXDATA0_OUT(22),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(23),
	GlitchData    => RXDATA023_GlitchData,
	OutSignalName => "RXDATA0(23)",
	OutTemp       => RXDATA0_OUT(23),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(24),
	GlitchData    => RXDATA024_GlitchData,
	OutSignalName => "RXDATA0(24)",
	OutTemp       => RXDATA0_OUT(24),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(25),
	GlitchData    => RXDATA025_GlitchData,
	OutSignalName => "RXDATA0(25)",
	OutTemp       => RXDATA0_OUT(25),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(26),
	GlitchData    => RXDATA026_GlitchData,
	OutSignalName => "RXDATA0(26)",
	OutTemp       => RXDATA0_OUT(26),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(27),
	GlitchData    => RXDATA027_GlitchData,
	OutSignalName => "RXDATA0(27)",
	OutTemp       => RXDATA0_OUT(27),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(28),
	GlitchData    => RXDATA028_GlitchData,
	OutSignalName => "RXDATA0(28)",
	OutTemp       => RXDATA0_OUT(28),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(29),
	GlitchData    => RXDATA029_GlitchData,
	OutSignalName => "RXDATA0(29)",
	OutTemp       => RXDATA0_OUT(29),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(30),
	GlitchData    => RXDATA030_GlitchData,
	OutSignalName => "RXDATA0(30)",
	OutTemp       => RXDATA0_OUT(30),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA0(31),
	GlitchData    => RXDATA031_GlitchData,
	OutSignalName => "RXDATA0(31)",
	OutTemp       => RXDATA0_OUT(31),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE0(0),
	GlitchData    => RXNOTINTABLE00_GlitchData,
	OutSignalName => "RXNOTINTABLE0(0)",
	OutTemp       => RXNOTINTABLE0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE0(1),
	GlitchData    => RXNOTINTABLE01_GlitchData,
	OutSignalName => "RXNOTINTABLE0(1)",
	OutTemp       => RXNOTINTABLE0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE0(2),
	GlitchData    => RXNOTINTABLE02_GlitchData,
	OutSignalName => "RXNOTINTABLE0(2)",
	OutTemp       => RXNOTINTABLE0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE0(3),
	GlitchData    => RXNOTINTABLE03_GlitchData,
	OutSignalName => "RXNOTINTABLE0(3)",
	OutTemp       => RXNOTINTABLE0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR0(0),
	GlitchData    => RXDISPERR00_GlitchData,
	OutSignalName => "RXDISPERR0(0)",
	OutTemp       => RXDISPERR0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR0(1),
	GlitchData    => RXDISPERR01_GlitchData,
	OutSignalName => "RXDISPERR0(1)",
	OutTemp       => RXDISPERR0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR0(2),
	GlitchData    => RXDISPERR02_GlitchData,
	OutSignalName => "RXDISPERR0(2)",
	OutTemp       => RXDISPERR0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR0(3),
	GlitchData    => RXDISPERR03_GlitchData,
	OutSignalName => "RXDISPERR0(3)",
	OutTemp       => RXDISPERR0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK0(0),
	GlitchData    => RXCHARISK00_GlitchData,
	OutSignalName => "RXCHARISK0(0)",
	OutTemp       => RXCHARISK0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK0(1),
	GlitchData    => RXCHARISK01_GlitchData,
	OutSignalName => "RXCHARISK0(1)",
	OutTemp       => RXCHARISK0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK0(2),
	GlitchData    => RXCHARISK02_GlitchData,
	OutSignalName => "RXCHARISK0(2)",
	OutTemp       => RXCHARISK0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK0(3),
	GlitchData    => RXCHARISK03_GlitchData,
	OutSignalName => "RXCHARISK0(3)",
	OutTemp       => RXCHARISK0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP0(0),
	GlitchData    => RXRUNDISP00_GlitchData,
	OutSignalName => "RXRUNDISP0(0)",
	OutTemp       => RXRUNDISP0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP0(1),
	GlitchData    => RXRUNDISP01_GlitchData,
	OutSignalName => "RXRUNDISP0(1)",
	OutTemp       => RXRUNDISP0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP0(2),
	GlitchData    => RXRUNDISP02_GlitchData,
	OutSignalName => "RXRUNDISP0(2)",
	OutTemp       => RXRUNDISP0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP0(3),
	GlitchData    => RXRUNDISP03_GlitchData,
	OutSignalName => "RXRUNDISP0(3)",
	OutTemp       => RXRUNDISP0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA0(0),
	GlitchData    => RXCHARISCOMMA00_GlitchData,
	OutSignalName => "RXCHARISCOMMA0(0)",
	OutTemp       => RXCHARISCOMMA0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA0(1),
	GlitchData    => RXCHARISCOMMA01_GlitchData,
	OutSignalName => "RXCHARISCOMMA0(1)",
	OutTemp       => RXCHARISCOMMA0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA0(2),
	GlitchData    => RXCHARISCOMMA02_GlitchData,
	OutSignalName => "RXCHARISCOMMA0(2)",
	OutTemp       => RXCHARISCOMMA0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA0(3),
	GlitchData    => RXCHARISCOMMA03_GlitchData,
	OutSignalName => "RXCHARISCOMMA0(3)",
	OutTemp       => RXCHARISCOMMA0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXVALID0,
	GlitchData    => RXVALID0_GlitchData,
	OutSignalName => "RXVALID0",
	OutTemp       => RXVALID0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(0),
	GlitchData    => RXDATA10_GlitchData,
	OutSignalName => "RXDATA1(0)",
	OutTemp       => RXDATA1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(1),
	GlitchData    => RXDATA11_GlitchData,
	OutSignalName => "RXDATA1(1)",
	OutTemp       => RXDATA1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(2),
	GlitchData    => RXDATA12_GlitchData,
	OutSignalName => "RXDATA1(2)",
	OutTemp       => RXDATA1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(3),
	GlitchData    => RXDATA13_GlitchData,
	OutSignalName => "RXDATA1(3)",
	OutTemp       => RXDATA1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(4),
	GlitchData    => RXDATA14_GlitchData,
	OutSignalName => "RXDATA1(4)",
	OutTemp       => RXDATA1_OUT(4),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(5),
	GlitchData    => RXDATA15_GlitchData,
	OutSignalName => "RXDATA1(5)",
	OutTemp       => RXDATA1_OUT(5),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(6),
	GlitchData    => RXDATA16_GlitchData,
	OutSignalName => "RXDATA1(6)",
	OutTemp       => RXDATA1_OUT(6),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(7),
	GlitchData    => RXDATA17_GlitchData,
	OutSignalName => "RXDATA1(7)",
	OutTemp       => RXDATA1_OUT(7),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(8),
	GlitchData    => RXDATA18_GlitchData,
	OutSignalName => "RXDATA1(8)",
	OutTemp       => RXDATA1_OUT(8),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(9),
	GlitchData    => RXDATA19_GlitchData,
	OutSignalName => "RXDATA1(9)",
	OutTemp       => RXDATA1_OUT(9),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(10),
	GlitchData    => RXDATA110_GlitchData,
	OutSignalName => "RXDATA1(10)",
	OutTemp       => RXDATA1_OUT(10),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(11),
	GlitchData    => RXDATA111_GlitchData,
	OutSignalName => "RXDATA1(11)",
	OutTemp       => RXDATA1_OUT(11),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(12),
	GlitchData    => RXDATA112_GlitchData,
	OutSignalName => "RXDATA1(12)",
	OutTemp       => RXDATA1_OUT(12),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(13),
	GlitchData    => RXDATA113_GlitchData,
	OutSignalName => "RXDATA1(13)",
	OutTemp       => RXDATA1_OUT(13),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(14),
	GlitchData    => RXDATA114_GlitchData,
	OutSignalName => "RXDATA1(14)",
	OutTemp       => RXDATA1_OUT(14),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(15),
	GlitchData    => RXDATA115_GlitchData,
	OutSignalName => "RXDATA1(15)",
	OutTemp       => RXDATA1_OUT(15),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(16),
	GlitchData    => RXDATA116_GlitchData,
	OutSignalName => "RXDATA1(16)",
	OutTemp       => RXDATA1_OUT(16),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(17),
	GlitchData    => RXDATA117_GlitchData,
	OutSignalName => "RXDATA1(17)",
	OutTemp       => RXDATA1_OUT(17),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(18),
	GlitchData    => RXDATA118_GlitchData,
	OutSignalName => "RXDATA1(18)",
	OutTemp       => RXDATA1_OUT(18),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(19),
	GlitchData    => RXDATA119_GlitchData,
	OutSignalName => "RXDATA1(19)",
	OutTemp       => RXDATA1_OUT(19),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(20),
	GlitchData    => RXDATA120_GlitchData,
	OutSignalName => "RXDATA1(20)",
	OutTemp       => RXDATA1_OUT(20),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(21),
	GlitchData    => RXDATA121_GlitchData,
	OutSignalName => "RXDATA1(21)",
	OutTemp       => RXDATA1_OUT(21),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(22),
	GlitchData    => RXDATA122_GlitchData,
	OutSignalName => "RXDATA1(22)",
	OutTemp       => RXDATA1_OUT(22),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(23),
	GlitchData    => RXDATA123_GlitchData,
	OutSignalName => "RXDATA1(23)",
	OutTemp       => RXDATA1_OUT(23),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(24),
	GlitchData    => RXDATA124_GlitchData,
	OutSignalName => "RXDATA1(24)",
	OutTemp       => RXDATA1_OUT(24),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(25),
	GlitchData    => RXDATA125_GlitchData,
	OutSignalName => "RXDATA1(25)",
	OutTemp       => RXDATA1_OUT(25),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(26),
	GlitchData    => RXDATA126_GlitchData,
	OutSignalName => "RXDATA1(26)",
	OutTemp       => RXDATA1_OUT(26),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(27),
	GlitchData    => RXDATA127_GlitchData,
	OutSignalName => "RXDATA1(27)",
	OutTemp       => RXDATA1_OUT(27),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(28),
	GlitchData    => RXDATA128_GlitchData,
	OutSignalName => "RXDATA1(28)",
	OutTemp       => RXDATA1_OUT(28),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(29),
	GlitchData    => RXDATA129_GlitchData,
	OutSignalName => "RXDATA1(29)",
	OutTemp       => RXDATA1_OUT(29),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(30),
	GlitchData    => RXDATA130_GlitchData,
	OutSignalName => "RXDATA1(30)",
	OutTemp       => RXDATA1_OUT(30),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATA1(31),
	GlitchData    => RXDATA131_GlitchData,
	OutSignalName => "RXDATA1(31)",
	OutTemp       => RXDATA1_OUT(31),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE1(0),
	GlitchData    => RXNOTINTABLE10_GlitchData,
	OutSignalName => "RXNOTINTABLE1(0)",
	OutTemp       => RXNOTINTABLE1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE1(1),
	GlitchData    => RXNOTINTABLE11_GlitchData,
	OutSignalName => "RXNOTINTABLE1(1)",
	OutTemp       => RXNOTINTABLE1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE1(2),
	GlitchData    => RXNOTINTABLE12_GlitchData,
	OutSignalName => "RXNOTINTABLE1(2)",
	OutTemp       => RXNOTINTABLE1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXNOTINTABLE1(3),
	GlitchData    => RXNOTINTABLE13_GlitchData,
	OutSignalName => "RXNOTINTABLE1(3)",
	OutTemp       => RXNOTINTABLE1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR1(0),
	GlitchData    => RXDISPERR10_GlitchData,
	OutSignalName => "RXDISPERR1(0)",
	OutTemp       => RXDISPERR1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR1(1),
	GlitchData    => RXDISPERR11_GlitchData,
	OutSignalName => "RXDISPERR1(1)",
	OutTemp       => RXDISPERR1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR1(2),
	GlitchData    => RXDISPERR12_GlitchData,
	OutSignalName => "RXDISPERR1(2)",
	OutTemp       => RXDISPERR1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDISPERR1(3),
	GlitchData    => RXDISPERR13_GlitchData,
	OutSignalName => "RXDISPERR1(3)",
	OutTemp       => RXDISPERR1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK1(0),
	GlitchData    => RXCHARISK10_GlitchData,
	OutSignalName => "RXCHARISK1(0)",
	OutTemp       => RXCHARISK1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK1(1),
	GlitchData    => RXCHARISK11_GlitchData,
	OutSignalName => "RXCHARISK1(1)",
	OutTemp       => RXCHARISK1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK1(2),
	GlitchData    => RXCHARISK12_GlitchData,
	OutSignalName => "RXCHARISK1(2)",
	OutTemp       => RXCHARISK1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISK1(3),
	GlitchData    => RXCHARISK13_GlitchData,
	OutSignalName => "RXCHARISK1(3)",
	OutTemp       => RXCHARISK1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP1(0),
	GlitchData    => RXRUNDISP10_GlitchData,
	OutSignalName => "RXRUNDISP1(0)",
	OutTemp       => RXRUNDISP1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP1(1),
	GlitchData    => RXRUNDISP11_GlitchData,
	OutSignalName => "RXRUNDISP1(1)",
	OutTemp       => RXRUNDISP1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP1(2),
	GlitchData    => RXRUNDISP12_GlitchData,
	OutSignalName => "RXRUNDISP1(2)",
	OutTemp       => RXRUNDISP1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXRUNDISP1(3),
	GlitchData    => RXRUNDISP13_GlitchData,
	OutSignalName => "RXRUNDISP1(3)",
	OutTemp       => RXRUNDISP1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA1(0),
	GlitchData    => RXCHARISCOMMA10_GlitchData,
	OutSignalName => "RXCHARISCOMMA1(0)",
	OutTemp       => RXCHARISCOMMA1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA1(1),
	GlitchData    => RXCHARISCOMMA11_GlitchData,
	OutSignalName => "RXCHARISCOMMA1(1)",
	OutTemp       => RXCHARISCOMMA1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA1(2),
	GlitchData    => RXCHARISCOMMA12_GlitchData,
	OutSignalName => "RXCHARISCOMMA1(2)",
	OutTemp       => RXCHARISCOMMA1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHARISCOMMA1(3),
	GlitchData    => RXCHARISCOMMA13_GlitchData,
	OutSignalName => "RXCHARISCOMMA1(3)",
	OutTemp       => RXCHARISCOMMA1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXVALID1,
	GlitchData    => RXVALID1_GlitchData,
	OutSignalName => "RXVALID1",
	OutTemp       => RXVALID1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR0(0),
	GlitchData    => TXKERR00_GlitchData,
	OutSignalName => "TXKERR0(0)",
	OutTemp       => TXKERR0_OUT(0),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR0(1),
	GlitchData    => TXKERR01_GlitchData,
	OutSignalName => "TXKERR0(1)",
	OutTemp       => TXKERR0_OUT(1),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR0(2),
	GlitchData    => TXKERR02_GlitchData,
	OutSignalName => "TXKERR0(2)",
	OutTemp       => TXKERR0_OUT(2),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR0(3),
	GlitchData    => TXKERR03_GlitchData,
	OutSignalName => "TXKERR0(3)",
	OutTemp       => TXKERR0_OUT(3),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP0(0),
	GlitchData    => TXRUNDISP00_GlitchData,
	OutSignalName => "TXRUNDISP0(0)",
	OutTemp       => TXRUNDISP0_OUT(0),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP0(1),
	GlitchData    => TXRUNDISP01_GlitchData,
	OutSignalName => "TXRUNDISP0(1)",
	OutTemp       => TXRUNDISP0_OUT(1),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP0(2),
	GlitchData    => TXRUNDISP02_GlitchData,
	OutSignalName => "TXRUNDISP0(2)",
	OutTemp       => TXRUNDISP0_OUT(2),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP0(3),
	GlitchData    => TXRUNDISP03_GlitchData,
	OutSignalName => "TXRUNDISP0(3)",
	OutTemp       => TXRUNDISP0_OUT(3),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXBUFSTATUS0(0),
	GlitchData    => TXBUFSTATUS00_GlitchData,
	OutSignalName => "TXBUFSTATUS0(0)",
	OutTemp       => TXBUFSTATUS0_OUT(0),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXBUFSTATUS0(1),
	GlitchData    => TXBUFSTATUS01_GlitchData,
	OutSignalName => "TXBUFSTATUS0(1)",
	OutTemp       => TXBUFSTATUS0_OUT(1),
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR1(0),
	GlitchData    => TXKERR10_GlitchData,
	OutSignalName => "TXKERR1(0)",
	OutTemp       => TXKERR1_OUT(0),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR1(1),
	GlitchData    => TXKERR11_GlitchData,
	OutSignalName => "TXKERR1(1)",
	OutTemp       => TXKERR1_OUT(1),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR1(2),
	GlitchData    => TXKERR12_GlitchData,
	OutSignalName => "TXKERR1(2)",
	OutTemp       => TXKERR1_OUT(2),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXKERR1(3),
	GlitchData    => TXKERR13_GlitchData,
	OutSignalName => "TXKERR1(3)",
	OutTemp       => TXKERR1_OUT(3),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP1(0),
	GlitchData    => TXRUNDISP10_GlitchData,
	OutSignalName => "TXRUNDISP1(0)",
	OutTemp       => TXRUNDISP1_OUT(0),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP1(1),
	GlitchData    => TXRUNDISP11_GlitchData,
	OutSignalName => "TXRUNDISP1(1)",
	OutTemp       => TXRUNDISP1_OUT(1),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP1(2),
	GlitchData    => TXRUNDISP12_GlitchData,
	OutSignalName => "TXRUNDISP1(2)",
	OutTemp       => TXRUNDISP1_OUT(2),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXRUNDISP1(3),
	GlitchData    => TXRUNDISP13_GlitchData,
	OutSignalName => "TXRUNDISP1(3)",
	OutTemp       => TXRUNDISP1_OUT(3),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXBUFSTATUS1(0),
	GlitchData    => TXBUFSTATUS10_GlitchData,
	OutSignalName => "TXBUFSTATUS1(0)",
	OutTemp       => TXBUFSTATUS1_OUT(0),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXBUFSTATUS1(1),
	GlitchData    => TXBUFSTATUS11_GlitchData,
	OutSignalName => "TXBUFSTATUS1(1)",
	OutTemp       => TXBUFSTATUS1_OUT(1),
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCOMMADET0,
	GlitchData    => RXCOMMADET0_GlitchData,
	OutSignalName => "RXCOMMADET0",
	OutTemp       => RXCOMMADET0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBYTEREALIGN0,
	GlitchData    => RXBYTEREALIGN0_GlitchData,
	OutSignalName => "RXBYTEREALIGN0",
	OutTemp       => RXBYTEREALIGN0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBYTEISALIGNED0,
	GlitchData    => RXBYTEISALIGNED0_GlitchData,
	OutSignalName => "RXBYTEISALIGNED0",
	OutTemp       => RXBYTEISALIGNED0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXLOSSOFSYNC0(0),
	GlitchData    => RXLOSSOFSYNC00_GlitchData,
	OutSignalName => "RXLOSSOFSYNC0(0)",
	OutTemp       => RXLOSSOFSYNC0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXLOSSOFSYNC0(1),
	GlitchData    => RXLOSSOFSYNC01_GlitchData,
	OutSignalName => "RXLOSSOFSYNC0(1)",
	OutTemp       => RXLOSSOFSYNC0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO0(0),
	GlitchData    => RXCHBONDO00_GlitchData,
	OutSignalName => "RXCHBONDO0(0)",
	OutTemp       => RXCHBONDO0_OUT(0),
	Paths         => (0 => (RXUSRCLK0_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO0(1),
	GlitchData    => RXCHBONDO01_GlitchData,
	OutSignalName => "RXCHBONDO0(1)",
	OutTemp       => RXCHBONDO0_OUT(1),
	Paths         => (0 => (RXUSRCLK0_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO0(2),
	GlitchData    => RXCHBONDO02_GlitchData,
	OutSignalName => "RXCHBONDO0(2)",
	OutTemp       => RXCHBONDO0_OUT(2),
	Paths         => (0 => (RXUSRCLK0_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO0(3),
	GlitchData    => RXCHBONDO03_GlitchData,
	OutSignalName => "RXCHBONDO0(3)",
	OutTemp       => RXCHBONDO0_OUT(3),
	Paths         => (0 => (RXUSRCLK0_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHANBONDSEQ0,
	GlitchData    => RXCHANBONDSEQ0_GlitchData,
	OutSignalName => "RXCHANBONDSEQ0",
	OutTemp       => RXCHANBONDSEQ0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHANREALIGN0,
	GlitchData    => RXCHANREALIGN0_GlitchData,
	OutSignalName => "RXCHANREALIGN0",
	OutTemp       => RXCHANREALIGN0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHANISALIGNED0,
	GlitchData    => RXCHANISALIGNED0_GlitchData,
	OutSignalName => "RXCHANISALIGNED0",
	OutTemp       => RXCHANISALIGNED0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBUFSTATUS0(0),
	GlitchData    => RXBUFSTATUS00_GlitchData,
	OutSignalName => "RXBUFSTATUS0(0)",
	OutTemp       => RXBUFSTATUS0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBUFSTATUS0(1),
	GlitchData    => RXBUFSTATUS01_GlitchData,
	OutSignalName => "RXBUFSTATUS0(1)",
	OutTemp       => RXBUFSTATUS0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBUFSTATUS0(2),
	GlitchData    => RXBUFSTATUS02_GlitchData,
	OutSignalName => "RXBUFSTATUS0(2)",
	OutTemp       => RXBUFSTATUS0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCOMMADET1,
	GlitchData    => RXCOMMADET1_GlitchData,
	OutSignalName => "RXCOMMADET1",
	OutTemp       => RXCOMMADET1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBYTEREALIGN1,
	GlitchData    => RXBYTEREALIGN1_GlitchData,
	OutSignalName => "RXBYTEREALIGN1",
	OutTemp       => RXBYTEREALIGN1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBYTEISALIGNED1,
	GlitchData    => RXBYTEISALIGNED1_GlitchData,
	OutSignalName => "RXBYTEISALIGNED1",
	OutTemp       => RXBYTEISALIGNED1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXLOSSOFSYNC1(0),
	GlitchData    => RXLOSSOFSYNC10_GlitchData,
	OutSignalName => "RXLOSSOFSYNC1(0)",
	OutTemp       => RXLOSSOFSYNC1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXLOSSOFSYNC1(1),
	GlitchData    => RXLOSSOFSYNC11_GlitchData,
	OutSignalName => "RXLOSSOFSYNC1(1)",
	OutTemp       => RXLOSSOFSYNC1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO1(0),
	GlitchData    => RXCHBONDO10_GlitchData,
	OutSignalName => "RXCHBONDO1(0)",
	OutTemp       => RXCHBONDO1_OUT(0),
	Paths         => (0 => (RXUSRCLK1_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO1(1),
	GlitchData    => RXCHBONDO11_GlitchData,
	OutSignalName => "RXCHBONDO1(1)",
	OutTemp       => RXCHBONDO1_OUT(1),
	Paths         => (0 => (RXUSRCLK1_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO1(2),
	GlitchData    => RXCHBONDO12_GlitchData,
	OutSignalName => "RXCHBONDO1(2)",
	OutTemp       => RXCHBONDO1_OUT(2),
	Paths         => (0 => (RXUSRCLK1_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHBONDO1(3),
	GlitchData    => RXCHBONDO13_GlitchData,
	OutSignalName => "RXCHBONDO1(3)",
	OutTemp       => RXCHBONDO1_OUT(3),
	Paths         => (0 => (RXUSRCLK1_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHANBONDSEQ1,
	GlitchData    => RXCHANBONDSEQ1_GlitchData,
	OutSignalName => "RXCHANBONDSEQ1",
	OutTemp       => RXCHANBONDSEQ1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHANREALIGN1,
	GlitchData    => RXCHANREALIGN1_GlitchData,
	OutSignalName => "RXCHANREALIGN1",
	OutTemp       => RXCHANREALIGN1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCHANISALIGNED1,
	GlitchData    => RXCHANISALIGNED1_GlitchData,
	OutSignalName => "RXCHANISALIGNED1",
	OutTemp       => RXCHANISALIGNED1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBUFSTATUS1(0),
	GlitchData    => RXBUFSTATUS10_GlitchData,
	OutSignalName => "RXBUFSTATUS1(0)",
	OutTemp       => RXBUFSTATUS1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBUFSTATUS1(1),
	GlitchData    => RXBUFSTATUS11_GlitchData,
	OutSignalName => "RXBUFSTATUS1(1)",
	OutTemp       => RXBUFSTATUS1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXBUFSTATUS1(2),
	GlitchData    => RXBUFSTATUS12_GlitchData,
	OutSignalName => "RXBUFSTATUS1(2)",
	OutTemp       => RXBUFSTATUS1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
        OutSignal     => PHYSTATUS0,
	GlitchData    => PHYSTATUS0_GlitchData,
	OutSignalName => "PHYSTATUS0",
	OutTemp       => PHYSTATUS0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PHYSTATUS1,
	GlitchData    => PHYSTATUS1_GlitchData,
	OutSignalName => "PHYSTATUS1",
	OutTemp       => PHYSTATUS1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
        OutSignal     => RXSTATUS0(0),
	GlitchData    => RXSTATUS00_GlitchData,
	OutSignalName => "RXSTATUS0(0)",
	OutTemp       => RXSTATUS0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXSTATUS0(1),
	GlitchData    => RXSTATUS01_GlitchData,
	OutSignalName => "RXSTATUS0(1)",
	OutTemp       => RXSTATUS0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXSTATUS0(2),
	GlitchData    => RXSTATUS02_GlitchData,
	OutSignalName => "RXSTATUS0(2)",
	OutTemp       => RXSTATUS0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCLKCORCNT0(0),
	GlitchData    => RXCLKCORCNT00_GlitchData,
	OutSignalName => "RXCLKCORCNT0(0)",
	OutTemp       => RXCLKCORCNT0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCLKCORCNT0(1),
	GlitchData    => RXCLKCORCNT01_GlitchData,
	OutSignalName => "RXCLKCORCNT0(1)",
	OutTemp       => RXCLKCORCNT0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCLKCORCNT0(2),
	GlitchData    => RXCLKCORCNT02_GlitchData,
	OutSignalName => "RXCLKCORCNT0(2)",
	OutTemp       => RXCLKCORCNT0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXSTATUS1(0),
	GlitchData    => RXSTATUS10_GlitchData,
	OutSignalName => "RXSTATUS1(0)",
	OutTemp       => RXSTATUS1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXSTATUS1(1),
	GlitchData    => RXSTATUS11_GlitchData,
	OutSignalName => "RXSTATUS1(1)",
	OutTemp       => RXSTATUS1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXSTATUS1(2),
	GlitchData    => RXSTATUS12_GlitchData,
	OutSignalName => "RXSTATUS1(2)",
	OutTemp       => RXSTATUS1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCLKCORCNT1(0),
	GlitchData    => RXCLKCORCNT10_GlitchData,
	OutSignalName => "RXCLKCORCNT1(0)",
	OutTemp       => RXCLKCORCNT1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCLKCORCNT1(1),
	GlitchData    => RXCLKCORCNT11_GlitchData,
	OutSignalName => "RXCLKCORCNT1(1)",
	OutTemp       => RXCLKCORCNT1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXCLKCORCNT1(2),
	GlitchData    => RXCLKCORCNT12_GlitchData,
	OutSignalName => "RXCLKCORCNT1(2)",
	OutTemp       => RXCLKCORCNT1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXPRBSERR0,
	GlitchData    => RXPRBSERR0_GlitchData,
	OutSignalName => "RXPRBSERR0",
	OutTemp       => RXPRBSERR0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXPRBSERR1,
	GlitchData    => RXPRBSERR1_GlitchData,
	OutSignalName => "RXPRBSERR1",
	OutTemp       => RXPRBSERR1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(0),
	GlitchData    => DO0_GlitchData,
	OutSignalName => "DO(0)",
	OutTemp       => DO_OUT(0),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(1),
	GlitchData    => DO1_GlitchData,
	OutSignalName => "DO(1)",
	OutTemp       => DO_OUT(1),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(2),
	GlitchData    => DO2_GlitchData,
	OutSignalName => "DO(2)",
	OutTemp       => DO_OUT(2),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(3),
	GlitchData    => DO3_GlitchData,
	OutSignalName => "DO(3)",
	OutTemp       => DO_OUT(3),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(4),
	GlitchData    => DO4_GlitchData,
	OutSignalName => "DO(4)",
	OutTemp       => DO_OUT(4),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(5),
	GlitchData    => DO5_GlitchData,
	OutSignalName => "DO(5)",
	OutTemp       => DO_OUT(5),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(6),
	GlitchData    => DO6_GlitchData,
	OutSignalName => "DO(6)",
	OutTemp       => DO_OUT(6),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(7),
	GlitchData    => DO7_GlitchData,
	OutSignalName => "DO(7)",
	OutTemp       => DO_OUT(7),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(8),
	GlitchData    => DO8_GlitchData,
	OutSignalName => "DO(8)",
	OutTemp       => DO_OUT(8),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(9),
	GlitchData    => DO9_GlitchData,
	OutSignalName => "DO(9)",
	OutTemp       => DO_OUT(9),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(10),
	GlitchData    => DO10_GlitchData,
	OutSignalName => "DO(10)",
	OutTemp       => DO_OUT(10),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(11),
	GlitchData    => DO11_GlitchData,
	OutSignalName => "DO(11)",
	OutTemp       => DO_OUT(11),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(12),
	GlitchData    => DO12_GlitchData,
	OutSignalName => "DO(12)",
	OutTemp       => DO_OUT(12),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(13),
	GlitchData    => DO13_GlitchData,
	OutSignalName => "DO(13)",
	OutTemp       => DO_OUT(13),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(14),
	GlitchData    => DO14_GlitchData,
	OutSignalName => "DO(14)",
	OutTemp       => DO_OUT(14),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DO(15),
	GlitchData    => DO15_GlitchData,
	OutSignalName => "DO(15)",
	OutTemp       => DO_OUT(15),
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DRDY,
	GlitchData    => DRDY_GlitchData,
	OutSignalName => "DRDY",
	OutTemp       => DRDY_OUT,
	Paths         => (0 => (DCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXOVERSAMPLEERR0,
	GlitchData    => RXOVERSAMPLEERR0_GlitchData,
	OutSignalName => "RXOVERSAMPLEERR0",
	OutTemp       => RXOVERSAMPLEERR0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXOVERSAMPLEERR1,
	GlitchData    => RXOVERSAMPLEERR1_GlitchData,
	OutSignalName => "RXOVERSAMPLEERR1",
	OutTemp       => RXOVERSAMPLEERR1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXGEARBOXREADY0,
	GlitchData    => TXGEARBOXREADY0_GlitchData,
	OutSignalName => "TXGEARBOXREADY0",
	OutTemp       => TXGEARBOXREADY0_OUT,
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADER0(0),
	GlitchData    => RXHEADER00_GlitchData,
	OutSignalName => "RXHEADER0(0)",
	OutTemp       => RXHEADER0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADER0(1),
	GlitchData    => RXHEADER01_GlitchData,
	OutSignalName => "RXHEADER0(1)",
	OutTemp       => RXHEADER0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADER0(2),
	GlitchData    => RXHEADER02_GlitchData,
	OutSignalName => "RXHEADER0(2)",
	OutTemp       => RXHEADER0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADERVALID0,
	GlitchData    => RXHEADERVALID0_GlitchData,
	OutSignalName => "RXHEADERVALID0",
	OutTemp       => RXHEADERVALID0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATAVALID0,
	GlitchData    => RXDATAVALID0_GlitchData,
	OutSignalName => "RXDATAVALID0",
	OutTemp       => RXDATAVALID0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXSTARTOFSEQ0,
	GlitchData    => RXSTARTOFSEQ0_GlitchData,
	OutSignalName => "RXSTARTOFSEQ0",
	OutTemp       => RXSTARTOFSEQ0_OUT,
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => TXGEARBOXREADY1,
	GlitchData    => TXGEARBOXREADY1_GlitchData,
	OutSignalName => "TXGEARBOXREADY1",
	OutTemp       => TXGEARBOXREADY1_OUT,
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADER1(0),
	GlitchData    => RXHEADER10_GlitchData,
	OutSignalName => "RXHEADER1(0)",
	OutTemp       => RXHEADER1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADER1(1),
	GlitchData    => RXHEADER11_GlitchData,
	OutSignalName => "RXHEADER1(1)",
	OutTemp       => RXHEADER1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADER1(2),
	GlitchData    => RXHEADER12_GlitchData,
	OutSignalName => "RXHEADER1(2)",
	OutTemp       => RXHEADER1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXHEADERVALID1,
	GlitchData    => RXHEADERVALID1_GlitchData,
	OutSignalName => "RXHEADERVALID1",
	OutTemp       => RXHEADERVALID1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXDATAVALID1,
	GlitchData    => RXDATAVALID1_GlitchData,
	OutSignalName => "RXDATAVALID1",
	OutTemp       => RXDATAVALID1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => RXSTARTOFSEQ1,
	GlitchData    => RXSTARTOFSEQ1_GlitchData,
	OutSignalName => "RXSTARTOFSEQ1",
	OutTemp       => RXSTARTOFSEQ1_OUT,
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR0(0),
	GlitchData    => DFECLKDLYADJMONITOR00_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR0(0)",
	OutTemp       => DFECLKDLYADJMONITOR0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR0(1),
	GlitchData    => DFECLKDLYADJMONITOR01_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR0(1)",
	OutTemp       => DFECLKDLYADJMONITOR0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR0(2),
	GlitchData    => DFECLKDLYADJMONITOR02_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR0(2)",
	OutTemp       => DFECLKDLYADJMONITOR0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR0(3),
	GlitchData    => DFECLKDLYADJMONITOR03_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR0(3)",
	OutTemp       => DFECLKDLYADJMONITOR0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR0(4),
	GlitchData    => DFECLKDLYADJMONITOR04_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR0(4)",
	OutTemp       => DFECLKDLYADJMONITOR0_OUT(4),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR0(5),
	GlitchData    => DFECLKDLYADJMONITOR05_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR0(5)",
	OutTemp       => DFECLKDLYADJMONITOR0_OUT(5),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR0(0),
	GlitchData    => DFEEYEDACMONITOR00_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR0(0)",
	OutTemp       => DFEEYEDACMONITOR0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR0(1),
	GlitchData    => DFEEYEDACMONITOR01_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR0(1)",
	OutTemp       => DFEEYEDACMONITOR0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR0(2),
	GlitchData    => DFEEYEDACMONITOR02_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR0(2)",
	OutTemp       => DFEEYEDACMONITOR0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR0(3),
	GlitchData    => DFEEYEDACMONITOR03_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR0(3)",
	OutTemp       => DFEEYEDACMONITOR0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR0(4),
	GlitchData    => DFEEYEDACMONITOR04_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR0(4)",
	OutTemp       => DFEEYEDACMONITOR0_OUT(4),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR0(0),
	GlitchData    => DFETAP1MONITOR00_GlitchData,
	OutSignalName => "DFETAP1MONITOR0(0)",
	OutTemp       => DFETAP1MONITOR0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR0(1),
	GlitchData    => DFETAP1MONITOR01_GlitchData,
	OutSignalName => "DFETAP1MONITOR0(1)",
	OutTemp       => DFETAP1MONITOR0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR0(2),
	GlitchData    => DFETAP1MONITOR02_GlitchData,
	OutSignalName => "DFETAP1MONITOR0(2)",
	OutTemp       => DFETAP1MONITOR0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR0(3),
	GlitchData    => DFETAP1MONITOR03_GlitchData,
	OutSignalName => "DFETAP1MONITOR0(3)",
	OutTemp       => DFETAP1MONITOR0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR0(4),
	GlitchData    => DFETAP1MONITOR04_GlitchData,
	OutSignalName => "DFETAP1MONITOR0(4)",
	OutTemp       => DFETAP1MONITOR0_OUT(4),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR0(0),
	GlitchData    => DFETAP2MONITOR00_GlitchData,
	OutSignalName => "DFETAP2MONITOR0(0)",
	OutTemp       => DFETAP2MONITOR0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR0(1),
	GlitchData    => DFETAP2MONITOR01_GlitchData,
	OutSignalName => "DFETAP2MONITOR0(1)",
	OutTemp       => DFETAP2MONITOR0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR0(2),
	GlitchData    => DFETAP2MONITOR02_GlitchData,
	OutSignalName => "DFETAP2MONITOR0(2)",
	OutTemp       => DFETAP2MONITOR0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR0(3),
	GlitchData    => DFETAP2MONITOR03_GlitchData,
	OutSignalName => "DFETAP2MONITOR0(3)",
	OutTemp       => DFETAP2MONITOR0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR0(4),
	GlitchData    => DFETAP2MONITOR04_GlitchData,
	OutSignalName => "DFETAP2MONITOR0(4)",
	OutTemp       => DFETAP2MONITOR0_OUT(4),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR0(0),
	GlitchData    => DFETAP3MONITOR00_GlitchData,
	OutSignalName => "DFETAP3MONITOR0(0)",
	OutTemp       => DFETAP3MONITOR0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR0(1),
	GlitchData    => DFETAP3MONITOR01_GlitchData,
	OutSignalName => "DFETAP3MONITOR0(1)",
	OutTemp       => DFETAP3MONITOR0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR0(2),
	GlitchData    => DFETAP3MONITOR02_GlitchData,
	OutSignalName => "DFETAP3MONITOR0(2)",
	OutTemp       => DFETAP3MONITOR0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR0(3),
	GlitchData    => DFETAP3MONITOR03_GlitchData,
	OutSignalName => "DFETAP3MONITOR0(3)",
	OutTemp       => DFETAP3MONITOR0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR0(0),
	GlitchData    => DFETAP4MONITOR00_GlitchData,
	OutSignalName => "DFETAP4MONITOR0(0)",
	OutTemp       => DFETAP4MONITOR0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR0(1),
	GlitchData    => DFETAP4MONITOR01_GlitchData,
	OutSignalName => "DFETAP4MONITOR0(1)",
	OutTemp       => DFETAP4MONITOR0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR0(2),
	GlitchData    => DFETAP4MONITOR02_GlitchData,
	OutSignalName => "DFETAP4MONITOR0(2)",
	OutTemp       => DFETAP4MONITOR0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR0(3),
	GlitchData    => DFETAP4MONITOR03_GlitchData,
	OutSignalName => "DFETAP4MONITOR0(3)",
	OutTemp       => DFETAP4MONITOR0_OUT(3),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR1(0),
	GlitchData    => DFECLKDLYADJMONITOR10_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR1(0)",
	OutTemp       => DFECLKDLYADJMONITOR1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR1(1),
	GlitchData    => DFECLKDLYADJMONITOR11_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR1(1)",
	OutTemp       => DFECLKDLYADJMONITOR1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR1(2),
	GlitchData    => DFECLKDLYADJMONITOR12_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR1(2)",
	OutTemp       => DFECLKDLYADJMONITOR1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR1(3),
	GlitchData    => DFECLKDLYADJMONITOR13_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR1(3)",
	OutTemp       => DFECLKDLYADJMONITOR1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR1(4),
	GlitchData    => DFECLKDLYADJMONITOR14_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR1(4)",
	OutTemp       => DFECLKDLYADJMONITOR1_OUT(4),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFECLKDLYADJMONITOR1(5),
	GlitchData    => DFECLKDLYADJMONITOR15_GlitchData,
	OutSignalName => "DFECLKDLYADJMONITOR1(5)",
	OutTemp       => DFECLKDLYADJMONITOR1_OUT(5),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR1(0),
	GlitchData    => DFEEYEDACMONITOR10_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR1(0)",
	OutTemp       => DFEEYEDACMONITOR1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR1(1),
	GlitchData    => DFEEYEDACMONITOR11_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR1(1)",
	OutTemp       => DFEEYEDACMONITOR1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR1(2),
	GlitchData    => DFEEYEDACMONITOR12_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR1(2)",
	OutTemp       => DFEEYEDACMONITOR1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR1(3),
	GlitchData    => DFEEYEDACMONITOR13_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR1(3)",
	OutTemp       => DFEEYEDACMONITOR1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFEEYEDACMONITOR1(4),
	GlitchData    => DFEEYEDACMONITOR14_GlitchData,
	OutSignalName => "DFEEYEDACMONITOR1(4)",
	OutTemp       => DFEEYEDACMONITOR1_OUT(4),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR1(0),
	GlitchData    => DFETAP1MONITOR10_GlitchData,
	OutSignalName => "DFETAP1MONITOR1(0)",
	OutTemp       => DFETAP1MONITOR1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR1(1),
	GlitchData    => DFETAP1MONITOR11_GlitchData,
	OutSignalName => "DFETAP1MONITOR1(1)",
	OutTemp       => DFETAP1MONITOR1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR1(2),
	GlitchData    => DFETAP1MONITOR12_GlitchData,
	OutSignalName => "DFETAP1MONITOR1(2)",
	OutTemp       => DFETAP1MONITOR1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR1(3),
	GlitchData    => DFETAP1MONITOR13_GlitchData,
	OutSignalName => "DFETAP1MONITOR1(3)",
	OutTemp       => DFETAP1MONITOR1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP1MONITOR1(4),
	GlitchData    => DFETAP1MONITOR14_GlitchData,
	OutSignalName => "DFETAP1MONITOR1(4)",
	OutTemp       => DFETAP1MONITOR1_OUT(4),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR1(0),
	GlitchData    => DFETAP2MONITOR10_GlitchData,
	OutSignalName => "DFETAP2MONITOR1(0)",
	OutTemp       => DFETAP2MONITOR1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR1(1),
	GlitchData    => DFETAP2MONITOR11_GlitchData,
	OutSignalName => "DFETAP2MONITOR1(1)",
	OutTemp       => DFETAP2MONITOR1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR1(2),
	GlitchData    => DFETAP2MONITOR12_GlitchData,
	OutSignalName => "DFETAP2MONITOR1(2)",
	OutTemp       => DFETAP2MONITOR1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR1(3),
	GlitchData    => DFETAP2MONITOR13_GlitchData,
	OutSignalName => "DFETAP2MONITOR1(3)",
	OutTemp       => DFETAP2MONITOR1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP2MONITOR1(4),
	GlitchData    => DFETAP2MONITOR14_GlitchData,
	OutSignalName => "DFETAP2MONITOR1(4)",
	OutTemp       => DFETAP2MONITOR1_OUT(4),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR1(0),
	GlitchData    => DFETAP3MONITOR10_GlitchData,
	OutSignalName => "DFETAP3MONITOR1(0)",
	OutTemp       => DFETAP3MONITOR1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR1(1),
	GlitchData    => DFETAP3MONITOR11_GlitchData,
	OutSignalName => "DFETAP3MONITOR1(1)",
	OutTemp       => DFETAP3MONITOR1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR1(2),
	GlitchData    => DFETAP3MONITOR12_GlitchData,
	OutSignalName => "DFETAP3MONITOR1(2)",
	OutTemp       => DFETAP3MONITOR1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP3MONITOR1(3),
	GlitchData    => DFETAP3MONITOR13_GlitchData,
	OutSignalName => "DFETAP3MONITOR1(3)",
	OutTemp       => DFETAP3MONITOR1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR1(0),
	GlitchData    => DFETAP4MONITOR10_GlitchData,
	OutSignalName => "DFETAP4MONITOR1(0)",
	OutTemp       => DFETAP4MONITOR1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR1(1),
	GlitchData    => DFETAP4MONITOR11_GlitchData,
	OutSignalName => "DFETAP4MONITOR1(1)",
	OutTemp       => DFETAP4MONITOR1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR1(2),
	GlitchData    => DFETAP4MONITOR12_GlitchData,
	OutSignalName => "DFETAP4MONITOR1(2)",
	OutTemp       => DFETAP4MONITOR1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFETAP4MONITOR1(3),
	GlitchData    => DFETAP4MONITOR13_GlitchData,
	OutSignalName => "DFETAP4MONITOR1(3)",
	OutTemp       => DFETAP4MONITOR1_OUT(3),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFESENSCAL0(0),
	GlitchData    => DFESENSCAL00_GlitchData,
	OutSignalName => "DFESENSCAL0(0)",
	OutTemp       => DFESENSCAL0_OUT(0),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFESENSCAL0(1),
	GlitchData    => DFESENSCAL01_GlitchData,
	OutSignalName => "DFESENSCAL0(1)",
	OutTemp       => DFESENSCAL0_OUT(1),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFESENSCAL0(2),
	GlitchData    => DFESENSCAL02_GlitchData,
	OutSignalName => "DFESENSCAL0(2)",
	OutTemp       => DFESENSCAL0_OUT(2),
	Paths         => (0 => (RXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFESENSCAL1(0),
	GlitchData    => DFESENSCAL10_GlitchData,
	OutSignalName => "DFESENSCAL1(0)",
	OutTemp       => DFESENSCAL1_OUT(0),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFESENSCAL1(1),
	GlitchData    => DFESENSCAL11_GlitchData,
	OutSignalName => "DFESENSCAL1(1)",
	OutTemp       => DFESENSCAL1_OUT(1),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DFESENSCAL1(2),
	GlitchData    => DFESENSCAL12_GlitchData,
	OutSignalName => "DFESENSCAL1(2)",
	OutTemp       => DFESENSCAL1_OUT(2),
	Paths         => (0 => (RXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);

   wait on
	DFECLKDLYADJMONITOR0_out,
	DFECLKDLYADJMONITOR1_out,
	DFEEYEDACMONITOR0_out,
	DFEEYEDACMONITOR1_out,
	DFESENSCAL0_out,
	DFESENSCAL1_out,
	DFETAP1MONITOR0_out,
	DFETAP1MONITOR1_out,
	DFETAP2MONITOR0_out,
	DFETAP2MONITOR1_out,
	DFETAP3MONITOR0_out,
	DFETAP3MONITOR1_out,
	DFETAP4MONITOR0_out,
	DFETAP4MONITOR1_out,
	DO_out,
	DRDY_out,
	REFCLKOUT_out,
	RXBUFSTATUS0_out,
	RXBUFSTATUS1_out,
	RXBYTEISALIGNED0_out,
	RXBYTEISALIGNED1_out,
	RXBYTEREALIGN0_out,
	RXBYTEREALIGN1_out,
	RXCHANBONDSEQ0_out,
	RXCHANBONDSEQ1_out,
	RXCHANISALIGNED0_out,
	RXCHANISALIGNED1_out,
	RXCHANREALIGN0_out,
	RXCHANREALIGN1_out,
	RXCHARISCOMMA0_out,
	RXCHARISCOMMA1_out,
	RXCHARISK0_out,
	RXCHARISK1_out,
	RXCHBONDO0_out,
	RXCHBONDO1_out,
	RXCLKCORCNT0_out,
	RXCLKCORCNT1_out,
	RXCOMMADET0_out,
	RXCOMMADET1_out,
	RXDATA0_out,
	RXDATA1_out,
	RXDATAVALID0_out,
	RXDATAVALID1_out,
	RXDISPERR0_out,
	RXDISPERR1_out,
	RXHEADER0_out,
	RXHEADER1_out,
	RXHEADERVALID0_out,
	RXHEADERVALID1_out,
	RXLOSSOFSYNC0_out,
	RXLOSSOFSYNC1_out,
	RXNOTINTABLE0_out,
	RXNOTINTABLE1_out,
	RXOVERSAMPLEERR0_out,
	RXOVERSAMPLEERR1_out,
	RXPRBSERR0_out,
	RXPRBSERR1_out,
	RXRUNDISP0_out,
	RXRUNDISP1_out,
	RXSTARTOFSEQ0_out,
	RXSTARTOFSEQ1_out,
	RXSTATUS0_out,
	RXSTATUS1_out,
	RXVALID0_out,
	RXVALID1_out,
	TXBUFSTATUS0_out,
	TXBUFSTATUS1_out,
	TXGEARBOXREADY0_out,
	TXGEARBOXREADY1_out,
	TXKERR0_out,
	TXKERR1_out,
	TXRUNDISP0_out,
	TXRUNDISP1_out,

	CLKIN_ipd,
	DADDR_ipd,
	DCLK_ipd,
	DEN_ipd,
	DFECLKDLYADJ0_ipd,
	DFECLKDLYADJ1_ipd,
	DFETAP10_ipd,
	DFETAP11_ipd,
	DFETAP20_ipd,
	DFETAP21_ipd,
	DFETAP30_ipd,
	DFETAP31_ipd,
	DFETAP40_ipd,
	DFETAP41_ipd,
	DI_ipd,
	DWE_ipd,
	GTXRESET_ipd,
	GTXTEST_ipd,
	INTDATAWIDTH_ipd,
	LOOPBACK0_ipd,
	LOOPBACK1_ipd,
	PLLLKDETEN_ipd,
	PLLPOWERDOWN_ipd,
	PRBSCNTRESET0_ipd,
	PRBSCNTRESET1_ipd,
	REFCLKPWRDNB_ipd,
	RXBUFRESET0_ipd,
	RXBUFRESET1_ipd,
	RXCDRRESET0_ipd,
	RXCDRRESET1_ipd,
	RXCHBONDI0_ipd,
	RXCHBONDI1_ipd,
	RXCOMMADETUSE0_ipd,
	RXCOMMADETUSE1_ipd,
	RXDATAWIDTH0_ipd,
	RXDATAWIDTH1_ipd,
	RXDEC8B10BUSE0_ipd,
	RXDEC8B10BUSE1_ipd,
	RXENCHANSYNC0_ipd,
	RXENCHANSYNC1_ipd,
	RXENEQB0_ipd,
	RXENEQB1_ipd,
	RXENMCOMMAALIGN0_ipd,
	RXENMCOMMAALIGN1_ipd,
	RXENPCOMMAALIGN0_ipd,
	RXENPCOMMAALIGN1_ipd,
	RXENPMAPHASEALIGN0_ipd,
	RXENPMAPHASEALIGN1_ipd,
	RXENPRBSTST0_ipd,
	RXENPRBSTST1_ipd,
	RXENSAMPLEALIGN0_ipd,
	RXENSAMPLEALIGN1_ipd,
	RXEQMIX0_ipd,
	RXEQMIX1_ipd,
	RXEQPOLE0_ipd,
	RXEQPOLE1_ipd,
	RXGEARBOXSLIP0_ipd,
	RXGEARBOXSLIP1_ipd,
	RXN0_ipd,
	RXN1_ipd,
	RXP0_ipd,
	RXP1_ipd,
	RXPMASETPHASE0_ipd,
	RXPMASETPHASE1_ipd,
	RXPOLARITY0_ipd,
	RXPOLARITY1_ipd,
	RXPOWERDOWN0_ipd,
	RXPOWERDOWN1_ipd,
	RXRESET0_ipd,
	RXRESET1_ipd,
	RXSLIDE0_ipd,
	RXSLIDE1_ipd,
	RXUSRCLK0_ipd,
	RXUSRCLK1_ipd,
	RXUSRCLK20_ipd,
	RXUSRCLK21_ipd,
	TXBUFDIFFCTRL0_ipd,
	TXBUFDIFFCTRL1_ipd,
	TXBYPASS8B10B0_ipd,
	TXBYPASS8B10B1_ipd,
	TXCHARDISPMODE0_ipd,
	TXCHARDISPMODE1_ipd,
	TXCHARDISPVAL0_ipd,
	TXCHARDISPVAL1_ipd,
	TXCHARISK0_ipd,
	TXCHARISK1_ipd,
	TXCOMSTART0_ipd,
	TXCOMSTART1_ipd,
	TXCOMTYPE0_ipd,
	TXCOMTYPE1_ipd,
	TXDATA0_ipd,
	TXDATA1_ipd,
	TXDATAWIDTH0_ipd,
	TXDATAWIDTH1_ipd,
	TXDETECTRX0_ipd,
	TXDETECTRX1_ipd,
	TXDIFFCTRL0_ipd,
	TXDIFFCTRL1_ipd,
	TXELECIDLE0_ipd,
	TXELECIDLE1_ipd,
	TXENC8B10BUSE0_ipd,
	TXENC8B10BUSE1_ipd,
	TXENPMAPHASEALIGN0_ipd,
	TXENPMAPHASEALIGN1_ipd,
	TXENPRBSTST0_ipd,
	TXENPRBSTST1_ipd,
	TXHEADER0_ipd,
	TXHEADER1_ipd,
	TXINHIBIT0_ipd,
	TXINHIBIT1_ipd,
	TXPMASETPHASE0_ipd,
	TXPMASETPHASE1_ipd,
	TXPOLARITY0_ipd,
	TXPOLARITY1_ipd,
	TXPOWERDOWN0_ipd,
	TXPOWERDOWN1_ipd,
	TXPREEMPHASIS0_ipd,
	TXPREEMPHASIS1_ipd,
	TXRESET0_ipd,
	TXRESET1_ipd,
	TXSEQUENCE0_ipd,
	TXSEQUENCE1_ipd,
	TXSTARTSEQ0_ipd,
	TXSTARTSEQ1_ipd,
	TXUSRCLK0_ipd,
	TXUSRCLK1_ipd,
	TXUSRCLK20_ipd,
	TXUSRCLK21_ipd;

	end process TIMING;

	PLLLKDET <= PLLLKDET_out;
	RESETDONE0 <= RESETDONE0_out;
	RESETDONE1 <= RESETDONE1_out;
	RXELECIDLE0 <= RXELECIDLE0_out;
	RXELECIDLE1 <= RXELECIDLE1_out;
	RXRECCLK0 <= RXRECCLK0_out;
	RXRECCLK1 <= RXRECCLK1_out;
	TXN0 <= TXN0_out;
	TXN1 <= TXN1_out;
	TXOUTCLK0 <= TXOUTCLK0_out;
	TXOUTCLK1 <= TXOUTCLK1_out;
	TXP0 <= TXP0_out;
	TXP1 <= TXP1_out;

end GTX_DUAL_V;
