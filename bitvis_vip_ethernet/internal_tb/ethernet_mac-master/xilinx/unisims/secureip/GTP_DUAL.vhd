-------------------------------------------------------------------------------
-- Copyright (c) 1995/2006 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor      : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       Multi-Gigabit Transceiver
-- /___/   /\     Filename    : gtp_dual.vhd
-- \   \  /  \    Timestamp   : Thu Dec 8 2005
--  \___\/\___\
--
-- Revision:
--    12/08/05 - Initial version.
--    01/09/06 - Added architecture
--    01/27/06 - Updated ONE_UI[10:0] to ONE_UI[31:0]
--               CR#22431 - Remove GSR pin
--    02/23/06 - Updated Header
--    03/29/06 - CR#226744 - Fixed output connectivity.
--    03/29/06 - CR#225541 - Updated GTP_DUAL smartmodel version to 0.006 for following updates
--		     - GTP_DUAL smartmodel not generating DO output on the DRP port properly	 
--		     - Renamed some of the ports.	
--		     - Removed some of the attributes.
--		     - Renamed some of the attributes.		
--    04/24/06 - CR#230306 - CLKIN => REFCLKOUT delay added
--    04/27/06 - CR#230648 - REFCLKOUT removed from wait on
--             - CR#230642 - Spreadsheet updates for I.31
--    05/22/06 - CR#231412 - SIM_RECEIVER_DETECT_PASS0/1 attributes added
--    05/23/06 - CR#231962 - Add buffers for connectivity
--    10/26/06 -           - replaced ZERO_DELAY with CLK_DELAY to be consistent with writers (PPC440 update)
--                         - PBS_ERR_THRESHOLD_0 default value X"11111111" to X"00000001
--    05/23/07 - CR#439780 - Default attribute value change - PMA_CDR_SCAN0/1, PMA_RX_CFG_0/1, TX_DIFF_BOOST_0/1
--                         - PCS_COM_CFG is a user visible attribute
--    05/23/07 - CR#440008 - Specify block timing update - RXCHBONDO0/1 synchronous to RXUSRCLK0,  RXCHBONDI0/1 synchronous to RXUSRCLK1
--    02/21/08 - CR#467686 - Add SIM_MODE attribute with values LEGACY & FAST model
--    05/19/08 - CR#472395 - Remove LEGACY model
--    05/27/08 - CR#472395 - Set SIM_MODE to FAST, Add DRC checks
--    07/20/09 - CR#524927 - Adding RXUSRCLK20_PHYSTATUS0 path
--    06/04/10 - CR#563818 - Adding RXUSRCLK21_PHYSTATUS1 path
-- End Revision

----- CELL GTP_DUAL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity GTP_DUAL is
generic (
        AC_CAP_DIS_0 : boolean := TRUE;
	AC_CAP_DIS_1 : boolean := TRUE;
	ALIGN_COMMA_WORD_0 : integer := 1;
	ALIGN_COMMA_WORD_1 : integer := 1;
	CHAN_BOND_1_MAX_SKEW_0 : integer := 7;
	CHAN_BOND_1_MAX_SKEW_1 : integer := 7;
	CHAN_BOND_2_MAX_SKEW_0 : integer := 1;
	CHAN_BOND_2_MAX_SKEW_1 : integer := 1;
	CHAN_BOND_LEVEL_0 : integer := 0;
	CHAN_BOND_LEVEL_1 : integer := 0;
	CHAN_BOND_MODE_0 : string := "OFF";
	CHAN_BOND_MODE_1 : string := "OFF";
	CHAN_BOND_SEQ_1_1_0 : bit_vector := "0001001010";
	CHAN_BOND_SEQ_1_1_1 : bit_vector := "0001001010";
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
	CHAN_BOND_SEQ_2_USE_0 : boolean := TRUE;
	CHAN_BOND_SEQ_2_USE_1 : boolean := TRUE;
	CHAN_BOND_SEQ_LEN_0 : integer := 4;
	CHAN_BOND_SEQ_LEN_1 : integer := 4;
	CLK25_DIVIDER : integer := 4;
	CLKINDC_B : boolean := TRUE;
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
	CLK_COR_MAX_LAT_0 : integer := 18;
	CLK_COR_MAX_LAT_1 : integer := 18;
	CLK_COR_MIN_LAT_0 : integer := 16;
	CLK_COR_MIN_LAT_1 : integer := 16;
	CLK_COR_PRECEDENCE_0 : boolean := TRUE;
	CLK_COR_PRECEDENCE_1 : boolean := TRUE;
	CLK_COR_REPEAT_WAIT_0 : integer := 5;
	CLK_COR_REPEAT_WAIT_1 : integer := 5;
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
	COMMA_10B_ENABLE_0 : bit_vector := "1111111111";
	COMMA_10B_ENABLE_1 : bit_vector := "1111111111";
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
	MCOMMA_10B_VALUE_0 : bit_vector := "1010000011";
	MCOMMA_10B_VALUE_1 : bit_vector := "1010000011";
	MCOMMA_DETECT_0 : boolean := TRUE;
	MCOMMA_DETECT_1 : boolean := TRUE;
	OOBDETECT_THRESHOLD_0 : bit_vector := "001";
	OOBDETECT_THRESHOLD_1 : bit_vector := "001";
	OOB_CLK_DIVIDER : integer := 4;
	OVERSAMPLE_MODE : boolean := FALSE;
	PCI_EXPRESS_MODE_0 : boolean := TRUE;
	PCI_EXPRESS_MODE_1 : boolean := TRUE;
	PCOMMA_10B_VALUE_0 : bit_vector := "0101111100";
	PCOMMA_10B_VALUE_1 : bit_vector := "0101111100";
	PCOMMA_DETECT_0 : boolean := TRUE;
	PCOMMA_DETECT_1 : boolean := TRUE;
        PCS_COM_CFG : bit_vector := X"1680a0e";
	PLL_DIVSEL_FB : integer := 5;
	PLL_DIVSEL_REF : integer := 2;
	PLL_RXDIVSEL_OUT_0 : integer := 1;
	PLL_RXDIVSEL_OUT_1 : integer := 1;
	PLL_SATA_0 : boolean := FALSE;
	PLL_SATA_1 : boolean := FALSE;
	PLL_TXDIVSEL_COMM_OUT : integer := 1;
	PLL_TXDIVSEL_OUT_0 : integer := 1;
	PLL_TXDIVSEL_OUT_1 : integer := 1;
	PMA_CDR_SCAN_0 : bit_vector := X"6c07640";
	PMA_CDR_SCAN_1 : bit_vector := X"6c07640";
        PMA_RX_CFG_0 : bit_vector := X"09f0089";
	PMA_RX_CFG_1 : bit_vector := X"09f0089";
	PRBS_ERR_THRESHOLD_0 : bit_vector := X"00000001";
	PRBS_ERR_THRESHOLD_1 : bit_vector := X"00000001";
	RCV_TERM_GND_0 : boolean := TRUE;
	RCV_TERM_GND_1 : boolean := TRUE;
	RCV_TERM_MID_0 : boolean := FALSE;
	RCV_TERM_MID_1 : boolean := FALSE;
	RCV_TERM_VTTRX_0 : boolean := FALSE;
	RCV_TERM_VTTRX_1 : boolean := FALSE;
	RX_BUFFER_USE_0 : boolean := TRUE;
	RX_BUFFER_USE_1 : boolean := TRUE;
	RX_DECODE_SEQ_MATCH_0 : boolean := TRUE;
	RX_DECODE_SEQ_MATCH_1 : boolean := TRUE;
	RX_LOSS_OF_SYNC_FSM_0 : boolean := FALSE;
	RX_LOSS_OF_SYNC_FSM_1 : boolean := FALSE;
	RX_LOS_INVALID_INCR_0 : integer := 8;
	RX_LOS_INVALID_INCR_1 : integer := 8;
	RX_LOS_THRESHOLD_0 : integer := 128;
	RX_LOS_THRESHOLD_1 : integer := 128;
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
        SIM_MODE : string := "FAST";
        SIM_PLL_PERDIV2 : bit_vector := X"190";
       	SIM_RECEIVER_DETECT_PASS0 : boolean := FALSE;
	SIM_RECEIVER_DETECT_PASS1 : boolean := FALSE;
	TERMINATION_CTRL : bit_vector := "10100";
	TERMINATION_IMP_0 : integer := 50;
	TERMINATION_IMP_1 : integer := 50;
	TERMINATION_OVRD : boolean := FALSE;
	TRANS_TIME_FROM_P2_0 : bit_vector := X"003c";
	TRANS_TIME_FROM_P2_1 : bit_vector := X"003c";
	TRANS_TIME_NON_P2_0 : bit_vector := X"0019";
	TRANS_TIME_NON_P2_1 : bit_vector := X"0019";
	TRANS_TIME_TO_P2_0 : bit_vector := X"0064";
	TRANS_TIME_TO_P2_1 : bit_vector := X"0064";
	TXRX_INVERT_0 : bit_vector := "00000";
	TXRX_INVERT_1 : bit_vector := "00000";
	TX_BUFFER_USE_0 : boolean := TRUE;
	TX_BUFFER_USE_1 : boolean := TRUE;
	TX_DIFF_BOOST_0 : boolean := TRUE;
	TX_DIFF_BOOST_1 : boolean := TRUE;
	TX_SYNC_FILTERB : integer := 1;
	TX_XCLK_SEL_0 : string := "TXUSR";
	TX_XCLK_SEL_1 : string := "TXUSR"
  );

port (
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
		RXCHARISCOMMA0 : out std_logic_vector(1 downto 0);
		RXCHARISCOMMA1 : out std_logic_vector(1 downto 0);
		RXCHARISK0 : out std_logic_vector(1 downto 0);
		RXCHARISK1 : out std_logic_vector(1 downto 0);
		RXCHBONDO0 : out std_logic_vector(2 downto 0);
		RXCHBONDO1 : out std_logic_vector(2 downto 0);
		RXCLKCORCNT0 : out std_logic_vector(2 downto 0);
		RXCLKCORCNT1 : out std_logic_vector(2 downto 0);
		RXCOMMADET0 : out std_ulogic;
		RXCOMMADET1 : out std_ulogic;
		RXDATA0 : out std_logic_vector(15 downto 0);
		RXDATA1 : out std_logic_vector(15 downto 0);
		RXDISPERR0 : out std_logic_vector(1 downto 0);
		RXDISPERR1 : out std_logic_vector(1 downto 0);
		RXELECIDLE0 : out std_ulogic;
		RXELECIDLE1 : out std_ulogic;
		RXLOSSOFSYNC0 : out std_logic_vector(1 downto 0);
		RXLOSSOFSYNC1 : out std_logic_vector(1 downto 0);
		RXNOTINTABLE0 : out std_logic_vector(1 downto 0);
		RXNOTINTABLE1 : out std_logic_vector(1 downto 0);
		RXOVERSAMPLEERR0 : out std_ulogic;
		RXOVERSAMPLEERR1 : out std_ulogic;
		RXPRBSERR0 : out std_ulogic;
		RXPRBSERR1 : out std_ulogic;
		RXRECCLK0 : out std_ulogic;
		RXRECCLK1 : out std_ulogic;
		RXRUNDISP0 : out std_logic_vector(1 downto 0);
		RXRUNDISP1 : out std_logic_vector(1 downto 0);
		RXSTATUS0 : out std_logic_vector(2 downto 0);
		RXSTATUS1 : out std_logic_vector(2 downto 0);
		RXVALID0 : out std_ulogic;
		RXVALID1 : out std_ulogic;
		TXBUFSTATUS0 : out std_logic_vector(1 downto 0);
		TXBUFSTATUS1 : out std_logic_vector(1 downto 0);
		TXKERR0 : out std_logic_vector(1 downto 0);
		TXKERR1 : out std_logic_vector(1 downto 0);
		TXN0 : out std_ulogic;
		TXN1 : out std_ulogic;
		TXOUTCLK0 : out std_ulogic;
		TXOUTCLK1 : out std_ulogic;
		TXP0 : out std_ulogic;
		TXP1 : out std_ulogic;
		TXRUNDISP0 : out std_logic_vector(1 downto 0);
		TXRUNDISP1 : out std_logic_vector(1 downto 0);

		CLKIN : in std_ulogic;
		DADDR : in std_logic_vector(6 downto 0);
		DCLK : in std_ulogic;
		DEN : in std_ulogic;
		DI : in std_logic_vector(15 downto 0);
		DWE : in std_ulogic;
		GTPRESET : in std_ulogic;
                GTPTEST : in std_logic_vector(3 downto 0);
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
		RXCHBONDI0 : in std_logic_vector(2 downto 0);
		RXCHBONDI1 : in std_logic_vector(2 downto 0);
		RXCOMMADETUSE0 : in std_ulogic;
		RXCOMMADETUSE1 : in std_ulogic;
		RXDATAWIDTH0 : in std_ulogic;
		RXDATAWIDTH1 : in std_ulogic;
		RXDEC8B10BUSE0 : in std_ulogic;
		RXDEC8B10BUSE1 : in std_ulogic;
                RXELECIDLERESET0 : in std_ulogic;
		RXELECIDLERESET1 : in std_ulogic;
		RXENCHANSYNC0 : in std_ulogic;
		RXENCHANSYNC1 : in std_ulogic;
                RXENELECIDLERESETB : in std_ulogic;
		RXENEQB0 : in std_ulogic;
		RXENEQB1 : in std_ulogic;
		RXENMCOMMAALIGN0 : in std_ulogic;
		RXENMCOMMAALIGN1 : in std_ulogic;
		RXENPCOMMAALIGN0 : in std_ulogic;
		RXENPCOMMAALIGN1 : in std_ulogic;
		RXENPRBSTST0 : in std_logic_vector(1 downto 0);
		RXENPRBSTST1 : in std_logic_vector(1 downto 0);
		RXENSAMPLEALIGN0 : in std_ulogic;
		RXENSAMPLEALIGN1 : in std_ulogic;
		RXEQMIX0 : in std_logic_vector(1 downto 0);
		RXEQMIX1 : in std_logic_vector(1 downto 0);
		RXEQPOLE0 : in std_logic_vector(3 downto 0);
		RXEQPOLE1 : in std_logic_vector(3 downto 0);
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
		TXBYPASS8B10B0 : in std_logic_vector(1 downto 0);
		TXBYPASS8B10B1 : in std_logic_vector(1 downto 0);
		TXCHARDISPMODE0 : in std_logic_vector(1 downto 0);
		TXCHARDISPMODE1 : in std_logic_vector(1 downto 0);
		TXCHARDISPVAL0 : in std_logic_vector(1 downto 0);
		TXCHARDISPVAL1 : in std_logic_vector(1 downto 0);
		TXCHARISK0 : in std_logic_vector(1 downto 0);
		TXCHARISK1 : in std_logic_vector(1 downto 0);
		TXCOMSTART0 : in std_ulogic;
		TXCOMSTART1 : in std_ulogic;
		TXCOMTYPE0 : in std_ulogic;
		TXCOMTYPE1 : in std_ulogic;
		TXDATA0 : in std_logic_vector(15 downto 0);
		TXDATA1 : in std_logic_vector(15 downto 0);
		TXDATAWIDTH0 : in std_ulogic;
		TXDATAWIDTH1 : in std_ulogic;
		TXDETECTRX0 : in std_ulogic;
		TXDETECTRX1 : in std_ulogic;
		TXDIFFCTRL0 : in std_logic_vector(2 downto 0);
		TXDIFFCTRL1 : in std_logic_vector(2 downto 0);
		TXELECIDLE0 : in std_ulogic;
		TXELECIDLE1 : in std_ulogic;
		TXENC8B10BUSE0 : in std_ulogic;
		TXENC8B10BUSE1 : in std_ulogic;
		TXENPMAPHASEALIGN : in std_ulogic;
		TXENPRBSTST0 : in std_logic_vector(1 downto 0);
		TXENPRBSTST1 : in std_logic_vector(1 downto 0);
		TXINHIBIT0 : in std_ulogic;
		TXINHIBIT1 : in std_ulogic;
		TXPMASETPHASE : in std_ulogic;
		TXPOLARITY0 : in std_ulogic;
		TXPOLARITY1 : in std_ulogic;
		TXPOWERDOWN0 : in std_logic_vector(1 downto 0);
		TXPOWERDOWN1 : in std_logic_vector(1 downto 0);
		TXPREEMPHASIS0 : in std_logic_vector(2 downto 0);
		TXPREEMPHASIS1 : in std_logic_vector(2 downto 0);
		TXRESET0 : in std_ulogic;
		TXRESET1 : in std_ulogic;
		TXUSRCLK0 : in std_ulogic;
		TXUSRCLK1 : in std_ulogic;
		TXUSRCLK20 : in std_ulogic;
		TXUSRCLK21 : in std_ulogic
     );
end GTP_DUAL;

architecture GTP_DUAL_V of GTP_DUAL is

  component GTP_DUAL_FAST
    port (
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
      RXCHARISCOMMA0       : out std_logic_vector(1 downto 0);
      RXCHARISCOMMA1       : out std_logic_vector(1 downto 0);
      RXCHARISK0           : out std_logic_vector(1 downto 0);
      RXCHARISK1           : out std_logic_vector(1 downto 0);
      RXCHBONDO0           : out std_logic_vector(2 downto 0);
      RXCHBONDO1           : out std_logic_vector(2 downto 0);
      RXCLKCORCNT0         : out std_logic_vector(2 downto 0);
      RXCLKCORCNT1         : out std_logic_vector(2 downto 0);
      RXCOMMADET0          : out std_ulogic;
      RXCOMMADET1          : out std_ulogic;
      RXDATA0              : out std_logic_vector(15 downto 0);
      RXDATA1              : out std_logic_vector(15 downto 0);
      RXDISPERR0           : out std_logic_vector(1 downto 0);
      RXDISPERR1           : out std_logic_vector(1 downto 0);
      RXELECIDLE0          : out std_ulogic;
      RXELECIDLE1          : out std_ulogic;
      RXLOSSOFSYNC0        : out std_logic_vector(1 downto 0);
      RXLOSSOFSYNC1        : out std_logic_vector(1 downto 0);
      RXNOTINTABLE0        : out std_logic_vector(1 downto 0);
      RXNOTINTABLE1        : out std_logic_vector(1 downto 0);
      RXOVERSAMPLEERR0     : out std_ulogic;
      RXOVERSAMPLEERR1     : out std_ulogic;
      RXPRBSERR0           : out std_ulogic;
      RXPRBSERR1           : out std_ulogic;
      RXRECCLK0            : out std_ulogic;
      RXRECCLK1            : out std_ulogic;
      RXRUNDISP0           : out std_logic_vector(1 downto 0);
      RXRUNDISP1           : out std_logic_vector(1 downto 0);
      RXSTATUS0            : out std_logic_vector(2 downto 0);
      RXSTATUS1            : out std_logic_vector(2 downto 0);
      RXVALID0             : out std_ulogic;
      RXVALID1             : out std_ulogic;
      TXBUFSTATUS0         : out std_logic_vector(1 downto 0);
      TXBUFSTATUS1         : out std_logic_vector(1 downto 0);
      TXKERR0              : out std_logic_vector(1 downto 0);
      TXKERR1              : out std_logic_vector(1 downto 0);
      TXN0                 : out std_ulogic;
      TXN1                 : out std_ulogic;
      TXOUTCLK0            : out std_ulogic;
      TXOUTCLK1            : out std_ulogic;
      TXP0                 : out std_ulogic;
      TXP1                 : out std_ulogic;
      TXRUNDISP0           : out std_logic_vector(1 downto 0);
      TXRUNDISP1           : out std_logic_vector(1 downto 0);

      CLKIN                : in std_ulogic;
      DADDR                : in std_logic_vector(6 downto 0);
      DCLK                 : in std_ulogic;
      DEN                  : in std_ulogic;
      DI                   : in std_logic_vector(15 downto 0);
      DWE                  : in std_ulogic;
      GSR                  : in std_ulogic;      
      GTPRESET             : in std_ulogic;
      GTPTEST              : in std_logic_vector(3 downto 0);
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
      RXCHBONDI0           : in std_logic_vector(2 downto 0);
      RXCHBONDI1           : in std_logic_vector(2 downto 0);
      RXCOMMADETUSE0       : in std_ulogic;
      RXCOMMADETUSE1       : in std_ulogic;
      RXDATAWIDTH0         : in std_ulogic;
      RXDATAWIDTH1         : in std_ulogic;
      RXDEC8B10BUSE0       : in std_ulogic;
      RXDEC8B10BUSE1       : in std_ulogic;
      RXELECIDLERESET0     : in std_ulogic;
      RXELECIDLERESET1     : in std_ulogic;
      RXENCHANSYNC0        : in std_ulogic;
      RXENCHANSYNC1        : in std_ulogic;
      RXENELECIDLERESETB   : in std_ulogic;
      RXENEQB0             : in std_ulogic;
      RXENEQB1             : in std_ulogic;
      RXENMCOMMAALIGN0     : in std_ulogic;
      RXENMCOMMAALIGN1     : in std_ulogic;
      RXENPCOMMAALIGN0     : in std_ulogic;
      RXENPCOMMAALIGN1     : in std_ulogic;
      RXENPRBSTST0         : in std_logic_vector(1 downto 0);
      RXENPRBSTST1         : in std_logic_vector(1 downto 0);
      RXENSAMPLEALIGN0     : in std_ulogic;
      RXENSAMPLEALIGN1     : in std_ulogic;
      RXEQMIX0             : in std_logic_vector(1 downto 0);
      RXEQMIX1             : in std_logic_vector(1 downto 0);
      RXEQPOLE0            : in std_logic_vector(3 downto 0);
      RXEQPOLE1            : in std_logic_vector(3 downto 0);
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
      TXBYPASS8B10B0       : in std_logic_vector(1 downto 0);
      TXBYPASS8B10B1       : in std_logic_vector(1 downto 0);
      TXCHARDISPMODE0      : in std_logic_vector(1 downto 0);
      TXCHARDISPMODE1      : in std_logic_vector(1 downto 0);
      TXCHARDISPVAL0       : in std_logic_vector(1 downto 0);
      TXCHARDISPVAL1       : in std_logic_vector(1 downto 0);
      TXCHARISK0           : in std_logic_vector(1 downto 0);
      TXCHARISK1           : in std_logic_vector(1 downto 0);
      TXCOMSTART0          : in std_ulogic;
      TXCOMSTART1          : in std_ulogic;
      TXCOMTYPE0           : in std_ulogic;
      TXCOMTYPE1           : in std_ulogic;
      TXDATA0              : in std_logic_vector(15 downto 0);
      TXDATA1              : in std_logic_vector(15 downto 0);
      TXDATAWIDTH0         : in std_ulogic;
      TXDATAWIDTH1         : in std_ulogic;
      TXDETECTRX0          : in std_ulogic;
      TXDETECTRX1          : in std_ulogic;
      TXDIFFCTRL0          : in std_logic_vector(2 downto 0);
      TXDIFFCTRL1          : in std_logic_vector(2 downto 0);
      TXELECIDLE0          : in std_ulogic;
      TXELECIDLE1          : in std_ulogic;
      TXENC8B10BUSE0       : in std_ulogic;
      TXENC8B10BUSE1       : in std_ulogic;
      TXENPMAPHASEALIGN    : in std_ulogic;
      TXENPRBSTST0         : in std_logic_vector(1 downto 0);
      TXENPRBSTST1         : in std_logic_vector(1 downto 0);
      TXINHIBIT0           : in std_ulogic;
      TXINHIBIT1           : in std_ulogic;
      TXPMASETPHASE        : in std_ulogic;
      TXPOLARITY0          : in std_ulogic;
      TXPOLARITY1          : in std_ulogic;
      TXPOWERDOWN0         : in std_logic_vector(1 downto 0);
      TXPOWERDOWN1         : in std_logic_vector(1 downto 0);
      TXPREEMPHASIS0       : in std_logic_vector(2 downto 0);
      TXPREEMPHASIS1       : in std_logic_vector(2 downto 0);
      TXRESET0             : in std_ulogic;
      TXRESET1             : in std_ulogic;
      TXUSRCLK0            : in std_ulogic;
      TXUSRCLK1            : in std_ulogic;
      TXUSRCLK20           : in std_ulogic;
      TXUSRCLK21           : in std_ulogic;

      AC_CAP_DIS_0              : in std_ulogic;
      AC_CAP_DIS_1              : in std_ulogic;
      ALIGN_COMMA_WORD_0        : in std_ulogic;
      ALIGN_COMMA_WORD_1        : in std_ulogic;
      CHAN_BOND_1_MAX_SKEW_0    : in std_logic_vector(3 downto 0);
      CHAN_BOND_1_MAX_SKEW_1    : in std_logic_vector(3 downto 0);
      CHAN_BOND_2_MAX_SKEW_0    : in std_logic_vector(3 downto 0);
      CHAN_BOND_2_MAX_SKEW_1    : in std_logic_vector(3 downto 0);
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
      PCS_COM_CFG               : in std_logic_vector(27 downto 0);
      PLL_DIVSEL_FB             : in std_logic_vector(4 downto 0);
      PLL_DIVSEL_REF            : in std_logic_vector(5 downto 0);
      PLL_RXDIVSEL_OUT_0        : in std_logic_vector(1 downto 0);
      PLL_RXDIVSEL_OUT_1        : in std_logic_vector(1 downto 0);
      PLL_SATA_0                : in std_ulogic;
      PLL_SATA_1                : in std_ulogic;
      PLL_TXDIVSEL_COMM_OUT     : in std_logic_vector(1 downto 0);
      PLL_TXDIVSEL_OUT_0        : in std_logic_vector(1 downto 0);
      PLL_TXDIVSEL_OUT_1        : in std_logic_vector(1 downto 0);
      PMA_CDR_SCAN_0            : in std_logic_vector(26 downto 0);
      PMA_CDR_SCAN_1            : in std_logic_vector(26 downto 0);
      PMA_RX_CFG_0              : in std_logic_vector(24 downto 0);
      PMA_RX_CFG_1              : in std_logic_vector(24 downto 0);
      PRBS_ERR_THRESHOLD_0      : in std_logic_vector(31 downto 0);
      PRBS_ERR_THRESHOLD_1      : in std_logic_vector(31 downto 0);
      RCV_TERM_GND_0            : in std_ulogic;
      RCV_TERM_GND_1            : in std_ulogic;
      RCV_TERM_MID_0            : in std_ulogic;
      RCV_TERM_MID_1            : in std_ulogic;
      RCV_TERM_VTTRX_0          : in std_ulogic;
      RCV_TERM_VTTRX_1          : in std_ulogic;
      RX_BUFFER_USE_0           : in std_ulogic;
      RX_BUFFER_USE_1           : in std_ulogic;
      RX_DECODE_SEQ_MATCH_0     : in std_ulogic;
      RX_DECODE_SEQ_MATCH_1     : in std_ulogic;
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
      SIM_GTPRESET_SPEEDUP      : in std_ulogic;
      SIM_PLL_PERDIV2           : in std_logic_vector(8 downto 0);
      SIM_RECEIVER_DETECT_PASS0 : in std_ulogic;
      SIM_RECEIVER_DETECT_PASS1 : in std_ulogic;
      TERMINATION_CTRL          : in std_logic_vector(4 downto 0);
      TERMINATION_IMP_0         : in std_ulogic;
      TERMINATION_IMP_1         : in std_ulogic;
      TERMINATION_OVRD          : in std_ulogic;
      TRANS_TIME_FROM_P2_0      : in std_logic_vector(15 downto 0);
      TRANS_TIME_FROM_P2_1      : in std_logic_vector(15 downto 0);
      TRANS_TIME_NON_P2_0       : in std_logic_vector(15 downto 0);
      TRANS_TIME_NON_P2_1       : in std_logic_vector(15 downto 0);
      TRANS_TIME_TO_P2_0        : in std_logic_vector(15 downto 0);
      TRANS_TIME_TO_P2_1        : in std_logic_vector(15 downto 0);
      TXRX_INVERT_0             : in std_logic_vector(4 downto 0);
      TXRX_INVERT_1             : in std_logic_vector(4 downto 0);
      TX_BUFFER_USE_0           : in std_ulogic;
      TX_BUFFER_USE_1           : in std_ulogic;
      TX_DIFF_BOOST_0           : in std_ulogic;
      TX_DIFF_BOOST_1           : in std_ulogic;
      TX_SYNC_FILTERB           : in std_ulogic;
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
	signal   PLL_TXDIVSEL_COMM_OUT_BINARY  :  std_logic_vector(1 downto 0);
	signal   PLL_SATA_0_BINARY  :  std_ulogic;
	signal   PLL_SATA_1_BINARY  :  std_ulogic;
	signal   TX_DIFF_BOOST_0_BINARY  :  std_ulogic;
	signal   OOBDETECT_THRESHOLD_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(OOBDETECT_THRESHOLD_0);
	signal   TX_DIFF_BOOST_1_BINARY  :  std_ulogic;
	signal   OOBDETECT_THRESHOLD_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(OOBDETECT_THRESHOLD_1);
	signal   PMA_CDR_SCAN_0_BINARY  :  std_logic_vector(26 downto 0) := To_StdLogicVector(PMA_CDR_SCAN_0)(26 downto 0);
	signal   PMA_CDR_SCAN_1_BINARY  :  std_logic_vector(26 downto 0) := To_StdLogicVector(PMA_CDR_SCAN_1)(26 downto 0);
	signal   PMA_RX_CFG_0_BINARY  :  std_logic_vector(24 downto 0) := To_StdLogicVector(PMA_RX_CFG_0)(24 downto 0);
	signal   PMA_RX_CFG_1_BINARY  :  std_logic_vector(24 downto 0) := To_StdLogicVector(PMA_RX_CFG_1)(24 downto 0);
	signal   OOB_CLK_DIVIDER_BINARY  :  std_logic_vector(2 downto 0);
	signal   TX_SYNC_FILTERB_BINARY  :  std_ulogic;
	signal   AC_CAP_DIS_0_BINARY  :  std_ulogic;
	signal   AC_CAP_DIS_1_BINARY  :  std_ulogic;
	signal   RCV_TERM_GND_0_BINARY  :  std_ulogic;
	signal   RCV_TERM_GND_1_BINARY  :  std_ulogic;
	signal   RCV_TERM_MID_0_BINARY  :  std_ulogic;
	signal   RCV_TERM_MID_1_BINARY  :  std_ulogic;
	signal   TERMINATION_IMP_0_BINARY  :  std_ulogic;
	signal   TERMINATION_IMP_1_BINARY  :  std_ulogic;
	signal   TERMINATION_OVRD_BINARY  :  std_ulogic;
	signal   TERMINATION_CTRL_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(TERMINATION_CTRL);
	signal   RCV_TERM_VTTRX_0_BINARY  :  std_ulogic;
	signal   RCV_TERM_VTTRX_1_BINARY  :  std_ulogic;
	signal   TXRX_INVERT_0_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(TXRX_INVERT_0);
	signal   TXRX_INVERT_1_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(TXRX_INVERT_1);
	signal   CLKINDC_B_BINARY  :  std_ulogic;
	signal   PCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   MCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   PCOMMA_10B_VALUE_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(PCOMMA_10B_VALUE_0);
	signal   MCOMMA_10B_VALUE_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(MCOMMA_10B_VALUE_0);
	signal   COMMA_10B_ENABLE_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(COMMA_10B_ENABLE_0);
	signal   COMMA_DOUBLE_0_BINARY  :  std_ulogic;
	signal   ALIGN_COMMA_WORD_0_BINARY  :  std_ulogic;
	signal   DEC_PCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   DEC_MCOMMA_DETECT_0_BINARY  :  std_ulogic;
	signal   DEC_VALID_COMMA_ONLY_0_BINARY  :  std_ulogic;
	signal   PCOMMA_DETECT_1_BINARY  :  std_ulogic;
	signal   MCOMMA_DETECT_1_BINARY  :  std_ulogic;
	signal   PCOMMA_10B_VALUE_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(PCOMMA_10B_VALUE_1);
	signal   MCOMMA_10B_VALUE_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(MCOMMA_10B_VALUE_1);
	signal   COMMA_10B_ENABLE_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(COMMA_10B_ENABLE_1);
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
	signal   CLK_COR_SEQ_1_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1_0);
	signal   CLK_COR_SEQ_1_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2_0);
	signal   CLK_COR_SEQ_1_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3_0);
	signal   CLK_COR_SEQ_1_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4_0);
	signal   CLK_COR_SEQ_2_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1_0);
	signal   CLK_COR_SEQ_2_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2_0);
	signal   CLK_COR_SEQ_2_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3_0);
	signal   CLK_COR_SEQ_2_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4_0);
	signal   CLK_COR_SEQ_1_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_ENABLE_0);
	signal   CLK_COR_SEQ_2_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_ENABLE_0);
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
	signal   CLK_COR_SEQ_1_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1_1);
	signal   CLK_COR_SEQ_1_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2_1);
	signal   CLK_COR_SEQ_1_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3_1);
	signal   CLK_COR_SEQ_1_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4_1);
	signal   CLK_COR_SEQ_2_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1_1);
	signal   CLK_COR_SEQ_2_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2_1);
	signal   CLK_COR_SEQ_2_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3_1);
	signal   CLK_COR_SEQ_2_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4_1);
	signal   CLK_COR_SEQ_1_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_ENABLE_1);
	signal   CLK_COR_SEQ_2_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_ENABLE_1);
	signal   CHAN_BOND_MODE_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_LEVEL_0_BINARY  :  std_logic_vector(2 downto 0);
	signal   CHAN_BOND_SEQ_LEN_0_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_SEQ_2_USE_0_BINARY  :  std_ulogic;
	signal   CHAN_BOND_SEQ_1_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1_0);
	signal   CHAN_BOND_SEQ_1_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2_0);
	signal   CHAN_BOND_SEQ_1_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3_0);
	signal   CHAN_BOND_SEQ_1_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4_0);
	signal   CHAN_BOND_SEQ_2_1_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1_0);
	signal   CHAN_BOND_SEQ_2_2_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2_0);
	signal   CHAN_BOND_SEQ_2_3_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3_0);
	signal   CHAN_BOND_SEQ_2_4_0_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4_0);
	signal   CHAN_BOND_SEQ_1_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_ENABLE_0);
	signal   CHAN_BOND_SEQ_2_ENABLE_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_ENABLE_0);
	signal   CHAN_BOND_1_MAX_SKEW_0_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_2_MAX_SKEW_0_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_MODE_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_LEVEL_1_BINARY  :  std_logic_vector(2 downto 0);
	signal   CHAN_BOND_SEQ_LEN_1_BINARY  :  std_logic_vector(1 downto 0);
	signal   CHAN_BOND_SEQ_2_USE_1_BINARY  :  std_ulogic;
	signal   CHAN_BOND_SEQ_1_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1_1);
	signal   CHAN_BOND_SEQ_1_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2_1);
	signal   CHAN_BOND_SEQ_1_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3_1);
	signal   CHAN_BOND_SEQ_1_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4_1);
	signal   CHAN_BOND_SEQ_2_1_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1_1);
	signal   CHAN_BOND_SEQ_2_2_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2_1);
	signal   CHAN_BOND_SEQ_2_3_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3_1);
	signal   CHAN_BOND_SEQ_2_4_1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4_1);
	signal   CHAN_BOND_SEQ_1_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_ENABLE_1);
	signal   CHAN_BOND_SEQ_2_ENABLE_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_ENABLE_1);
	signal   CHAN_BOND_1_MAX_SKEW_1_BINARY  :  std_logic_vector(3 downto 0);
	signal   CHAN_BOND_2_MAX_SKEW_1_BINARY  :  std_logic_vector(3 downto 0);
	signal   PCI_EXPRESS_MODE_0_BINARY  :  std_ulogic;
	signal   TRANS_TIME_FROM_P2_0_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(TRANS_TIME_FROM_P2_0);
	signal   TRANS_TIME_NON_P2_0_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(TRANS_TIME_NON_P2_0);
	signal   TRANS_TIME_TO_P2_0_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(TRANS_TIME_TO_P2_0);
	signal   PCI_EXPRESS_MODE_1_BINARY  :  std_ulogic;
	signal   TRANS_TIME_FROM_P2_1_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(TRANS_TIME_FROM_P2_1);
	signal   TRANS_TIME_NON_P2_1_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(TRANS_TIME_NON_P2_1);
	signal   TRANS_TIME_TO_P2_1_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(TRANS_TIME_TO_P2_1);
	signal   RX_STATUS_FMT_0_BINARY  :  std_ulogic;
	signal   TX_BUFFER_USE_0_BINARY  :  std_ulogic;
	signal   TX_XCLK_SEL_0_BINARY  :  std_ulogic;
	signal   RX_XCLK_SEL_0_BINARY  :  std_ulogic;
	signal   RX_STATUS_FMT_1_BINARY  :  std_ulogic;
	signal   TX_BUFFER_USE_1_BINARY  :  std_ulogic;
	signal   TX_XCLK_SEL_1_BINARY  :  std_ulogic;
	signal   RX_XCLK_SEL_1_BINARY  :  std_ulogic;
	signal   PRBS_ERR_THRESHOLD_0_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(PRBS_ERR_THRESHOLD_0);
	signal   RX_SLIDE_MODE_0_BINARY  :  std_ulogic;
	signal   PRBS_ERR_THRESHOLD_1_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(PRBS_ERR_THRESHOLD_1);
	signal   RX_SLIDE_MODE_1_BINARY  :  std_ulogic;
	signal   SATA_MIN_BURST_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_BURST_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_INIT_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_INIT_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_WAKE_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_WAKE_0_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_BURST_VAL_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_BURST_VAL_0);
	signal   SATA_IDLE_VAL_0_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_IDLE_VAL_0);
	signal   COM_BURST_VAL_0_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(COM_BURST_VAL_0);
	signal   SATA_MIN_BURST_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_BURST_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_INIT_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_INIT_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MIN_WAKE_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_MAX_WAKE_1_BINARY  :  std_logic_vector(5 downto 0);
	signal   SATA_BURST_VAL_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_BURST_VAL_1);
	signal   SATA_IDLE_VAL_1_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_IDLE_VAL_1);
	signal   COM_BURST_VAL_1_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(COM_BURST_VAL_1);
	signal   CLK25_DIVIDER_BINARY  :  std_logic_vector(2 downto 0);
        signal   PCS_COM_CFG_BINARY  :  std_logic_vector(27 downto 0) := To_StdLogicVector(PCS_COM_CFG);
	signal   OVERSAMPLE_MODE_BINARY  :  std_ulogic;
	signal   SIM_GTPRESET_SPEEDUP_BINARY  :  std_ulogic;
        signal   SIM_MODE_BINARY  :  std_ulogic;
	signal   SIM_PLL_PERDIV2_BINARY  :  std_logic_vector(8 downto 0) := To_StdLogicVector(SIM_PLL_PERDIV2)(8 downto 0);
	signal   SIM_RECEIVER_DETECT_PASS0_BINARY  :  std_ulogic;
	signal   SIM_RECEIVER_DETECT_PASS1_BINARY  :  std_ulogic;

       	signal   REFCLKOUT_out  :  std_ulogic;
	signal   RXRECCLK0_out  :  std_ulogic;
	signal   TXOUTCLK0_out  :  std_ulogic;
	signal   RXRECCLK1_out  :  std_ulogic;
	signal   TXOUTCLK1_out  :  std_ulogic;
	signal   TXP0_out  :  std_ulogic;
	signal   TXN0_out  :  std_ulogic;
	signal   TXP1_out  :  std_ulogic;
	signal   TXN1_out  :  std_ulogic;
	signal   RXDATA0_out  :  std_logic_vector(15 downto 0);
	signal   RXNOTINTABLE0_out  :  std_logic_vector(1 downto 0);
	signal   RXDISPERR0_out  :  std_logic_vector(1 downto 0);
	signal   RXCHARISK0_out  :  std_logic_vector(1 downto 0);
	signal   RXRUNDISP0_out  :  std_logic_vector(1 downto 0);
	signal   RXCHARISCOMMA0_out  :  std_logic_vector(1 downto 0);
	signal   RXVALID0_out  :  std_ulogic;
	signal   RXDATA1_out  :  std_logic_vector(15 downto 0);
	signal   RXNOTINTABLE1_out  :  std_logic_vector(1 downto 0);
	signal   RXDISPERR1_out  :  std_logic_vector(1 downto 0);
	signal   RXCHARISK1_out  :  std_logic_vector(1 downto 0);
	signal   RXRUNDISP1_out  :  std_logic_vector(1 downto 0);
	signal   RXCHARISCOMMA1_out  :  std_logic_vector(1 downto 0);
	signal   RXVALID1_out  :  std_ulogic;
	signal   RESETDONE0_out  :  std_ulogic;
	signal   RESETDONE1_out  :  std_ulogic;
	signal   TXKERR0_out  :  std_logic_vector(1 downto 0);
	signal   TXRUNDISP0_out  :  std_logic_vector(1 downto 0);
	signal   TXBUFSTATUS0_out  :  std_logic_vector(1 downto 0);
	signal   TXKERR1_out  :  std_logic_vector(1 downto 0);
	signal   TXRUNDISP1_out  :  std_logic_vector(1 downto 0);
	signal   TXBUFSTATUS1_out  :  std_logic_vector(1 downto 0);
	signal   RXCOMMADET0_out  :  std_ulogic;
	signal   RXBYTEREALIGN0_out  :  std_ulogic;
	signal   RXBYTEISALIGNED0_out  :  std_ulogic;
	signal   RXLOSSOFSYNC0_out  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO0_out  :  std_logic_vector(2 downto 0);
	signal   RXCHANBONDSEQ0_out  :  std_ulogic;
	signal   RXCHANREALIGN0_out  :  std_ulogic;
	signal   RXCHANISALIGNED0_out  :  std_ulogic;
	signal   RXBUFSTATUS0_out  :  std_logic_vector(2 downto 0);
	signal   RXCOMMADET1_out  :  std_ulogic;
	signal   RXBYTEREALIGN1_out  :  std_ulogic;
	signal   RXBYTEISALIGNED1_out  :  std_ulogic;
	signal   RXLOSSOFSYNC1_out  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO1_out  :  std_logic_vector(2 downto 0);
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
	signal   REFCLKOUT_outdelay  :  std_logic;
	signal   RXRECCLK0_outdelay  :  std_logic;
	signal   TXOUTCLK0_outdelay  :  std_logic;
	signal   RXRECCLK1_outdelay  :  std_logic;
	signal   TXOUTCLK1_outdelay  :  std_logic;
	signal   RXCLKCORCNT0_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXCLKCORCNT1_outdelay  :  std_logic_vector(2 downto 0);
	signal   TXP0_outdelay  :  std_logic;
	signal   TXN0_outdelay  :  std_logic;
	signal   TXP1_outdelay  :  std_logic;
	signal   TXN1_outdelay  :  std_logic;
	signal   RXDATA0_outdelay  :  std_logic_vector(15 downto 0);
	signal   RXNOTINTABLE0_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXDISPERR0_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHARISK0_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXRUNDISP0_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHARISCOMMA0_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXVALID0_outdelay  :  std_logic;
	signal   RXDATA1_outdelay  :  std_logic_vector(15 downto 0);
	signal   RXNOTINTABLE1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXDISPERR1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHARISK1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXRUNDISP1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHARISCOMMA1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXVALID1_outdelay  :  std_logic;
	signal   RESETDONE0_outdelay  :  std_logic;
	signal   RESETDONE1_outdelay  :  std_logic;
	signal   TXKERR0_outdelay  :  std_logic_vector(1 downto 0);
	signal   TXRUNDISP0_outdelay  :  std_logic_vector(1 downto 0);
	signal   TXBUFSTATUS0_outdelay  :  std_logic_vector(1 downto 0);
	signal   TXKERR1_outdelay  :  std_logic_vector(1 downto 0);
	signal   TXRUNDISP1_outdelay  :  std_logic_vector(1 downto 0);
	signal   TXBUFSTATUS1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCOMMADET0_outdelay  :  std_logic;
	signal   RXBYTEREALIGN0_outdelay  :  std_logic;
	signal   RXBYTEISALIGNED0_outdelay  :  std_logic;
	signal   RXLOSSOFSYNC0_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO0_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXCHANBONDSEQ0_outdelay  :  std_logic;
	signal   RXCHANREALIGN0_outdelay  :  std_logic;
	signal   RXCHANISALIGNED0_outdelay  :  std_logic;
	signal   RXBUFSTATUS0_outdelay  :  std_logic_vector(2 downto 0);
	signal   RXCOMMADET1_outdelay  :  std_logic;
	signal   RXBYTEREALIGN1_outdelay  :  std_logic;
	signal   RXBYTEISALIGNED1_outdelay  :  std_logic;
	signal   RXLOSSOFSYNC1_outdelay  :  std_logic_vector(1 downto 0);
	signal   RXCHBONDO1_outdelay  :  std_logic_vector(2 downto 0);
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
	signal   TXDATA0_ipd  :  std_logic_vector(15 downto 0);
	signal   TXBYPASS8B10B0_ipd  :  std_logic_vector(1 downto 0);
	signal   TXCHARISK0_ipd  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPMODE0_ipd  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPVAL0_ipd  :  std_logic_vector(1 downto 0);
	signal   RXP1_ipd  :  std_ulogic;
	signal   RXN1_ipd  :  std_ulogic;
	signal   TXDATA1_ipd  :  std_logic_vector(15 downto 0);
	signal   TXBYPASS8B10B1_ipd  :  std_logic_vector(1 downto 0);
	signal   TXCHARISK1_ipd  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPMODE1_ipd  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPVAL1_ipd  :  std_logic_vector(1 downto 0);
	signal   GTPRESET_ipd  :  std_ulogic;
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
	signal   TXPREEMPHASIS0_ipd  :  std_logic_vector(2 downto 0);
	signal   TXDIFFCTRL1_ipd  :  std_logic_vector(2 downto 0);
	signal   TXBUFDIFFCTRL1_ipd  :  std_logic_vector(2 downto 0);
	signal   TXPREEMPHASIS1_ipd  :  std_logic_vector(2 downto 0);
	signal   RXENEQB0_ipd  :  std_ulogic;
	signal   RXEQMIX0_ipd  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE0_ipd  :  std_logic_vector(3 downto 0);
	signal   RXENEQB1_ipd  :  std_ulogic;
	signal   RXEQMIX1_ipd  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE1_ipd  :  std_logic_vector(3 downto 0);
	signal   INTDATAWIDTH_ipd  :  std_ulogic;
	signal   TXDATAWIDTH0_ipd  :  std_ulogic;
	signal   TXDATAWIDTH1_ipd  :  std_ulogic;
	signal   TXENPMAPHASEALIGN_ipd  :  std_ulogic;
	signal   TXPMASETPHASE_ipd  :  std_ulogic;
	signal   RXPMASETPHASE0_ipd  :  std_ulogic;
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
	signal   RXCHBONDI0_ipd  :  std_logic_vector(2 downto 0);
	signal   RXDATAWIDTH0_ipd  :  std_ulogic;
	signal   RXPOLARITY1_ipd  :  std_ulogic;
	signal   RXENPCOMMAALIGN1_ipd  :  std_ulogic;
	signal   RXENMCOMMAALIGN1_ipd  :  std_ulogic;
	signal   RXSLIDE1_ipd  :  std_ulogic;
	signal   RXCOMMADETUSE1_ipd  :  std_ulogic;
	signal   RXDEC8B10BUSE1_ipd  :  std_ulogic;
	signal   RXENCHANSYNC1_ipd  :  std_ulogic;
	signal   RXCHBONDI1_ipd  :  std_logic_vector(2 downto 0);
	signal   RXDATAWIDTH1_ipd  :  std_ulogic;
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
	signal   RXELECIDLERESET0_ipd  :  std_ulogic;
	signal   RXELECIDLERESET1_ipd  :  std_ulogic;
	signal   RXENELECIDLERESETB_ipd  :  std_ulogic;
	signal   GTPTEST_ipd  :  std_logic_vector(3 downto 0);

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
	signal   TXDATA0_indelay  :  std_logic_vector(15 downto 0);
	signal   TXBYPASS8B10B0_indelay  :  std_logic_vector(1 downto 0);
	signal   TXCHARISK0_indelay  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPMODE0_indelay  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPVAL0_indelay  :  std_logic_vector(1 downto 0);
	signal   RXP1_indelay  :  std_ulogic;
	signal   RXN1_indelay  :  std_ulogic;
	signal   TXDATA1_indelay  :  std_logic_vector(15 downto 0);
	signal   TXBYPASS8B10B1_indelay  :  std_logic_vector(1 downto 0);
	signal   TXCHARISK1_indelay  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPMODE1_indelay  :  std_logic_vector(1 downto 0);
	signal   TXCHARDISPVAL1_indelay  :  std_logic_vector(1 downto 0);
	signal   GTPRESET_indelay  :  std_ulogic;
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
	signal   TXPREEMPHASIS0_indelay  :  std_logic_vector(2 downto 0);
	signal   TXDIFFCTRL1_indelay  :  std_logic_vector(2 downto 0);
	signal   TXBUFDIFFCTRL1_indelay  :  std_logic_vector(2 downto 0);
	signal   TXPREEMPHASIS1_indelay  :  std_logic_vector(2 downto 0);
	signal   RXENEQB0_indelay  :  std_ulogic;
	signal   RXEQMIX0_indelay  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE0_indelay  :  std_logic_vector(3 downto 0);
	signal   RXENEQB1_indelay  :  std_ulogic;
	signal   RXEQMIX1_indelay  :  std_logic_vector(1 downto 0);
	signal   RXEQPOLE1_indelay  :  std_logic_vector(3 downto 0);
	signal   INTDATAWIDTH_indelay  :  std_ulogic;
	signal   TXDATAWIDTH0_indelay  :  std_ulogic;
	signal   TXDATAWIDTH1_indelay  :  std_ulogic;
	signal   TXENPMAPHASEALIGN_indelay  :  std_ulogic;
	signal   TXPMASETPHASE_indelay  :  std_ulogic;
	signal   RXPMASETPHASE0_indelay  :  std_ulogic;
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
	signal   RXCHBONDI0_indelay  :  std_logic_vector(2 downto 0);
	signal   RXDATAWIDTH0_indelay  :  std_ulogic;
	signal   RXPOLARITY1_indelay  :  std_ulogic;
	signal   RXENPCOMMAALIGN1_indelay  :  std_ulogic;
	signal   RXENMCOMMAALIGN1_indelay  :  std_ulogic;
	signal   RXSLIDE1_indelay  :  std_ulogic;
	signal   RXCOMMADETUSE1_indelay  :  std_ulogic;
	signal   RXDEC8B10BUSE1_indelay  :  std_ulogic;
	signal   RXENCHANSYNC1_indelay  :  std_ulogic;
	signal   RXCHBONDI1_indelay  :  std_logic_vector(2 downto 0);
	signal   RXDATAWIDTH1_indelay  :  std_ulogic;
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
	signal   RXELECIDLERESET0_indelay  :  std_ulogic;
	signal   RXELECIDLERESET1_indelay  :  std_ulogic;
	signal   RXENELECIDLERESETB_indelay  :  std_ulogic;
  signal   GTPTEST_indelay  :  std_logic_vector(3 downto 0);

begin
  
  REFCLKOUT_out <= REFCLKOUT_outdelay after CLK_DELAY;
  RXCLKCORCNT0_out <= RXCLKCORCNT0_outdelay after CLK_DELAY;
  RXCLKCORCNT1_out <= RXCLKCORCNT1_outdelay after CLK_DELAY;
  RXRECCLK0_out <= RXRECCLK0_outdelay after CLK_DELAY;
  RXRECCLK1_out <= RXRECCLK1_outdelay after CLK_DELAY;
  TXOUTCLK0_out <= TXOUTCLK0_outdelay after CLK_DELAY;
  TXOUTCLK1_out <= TXOUTCLK1_outdelay after CLK_DELAY;
  
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
  RXDISPERR0_out <= RXDISPERR0_outdelay after OUT_DELAY;
  RXDISPERR1_out <= RXDISPERR1_outdelay after OUT_DELAY;
  RXELECIDLE0_out <= RXELECIDLE0_outdelay after OUT_DELAY;
  RXELECIDLE1_out <= RXELECIDLE1_outdelay after OUT_DELAY;
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
  RXSTATUS0_out <= RXSTATUS0_outdelay after OUT_DELAY;
  RXSTATUS1_out <= RXSTATUS1_outdelay after OUT_DELAY;
  RXVALID0_out <= RXVALID0_outdelay after OUT_DELAY;
  RXVALID1_out <= RXVALID1_outdelay after OUT_DELAY;
  TXBUFSTATUS0_out <= TXBUFSTATUS0_outdelay after OUT_DELAY;
  TXBUFSTATUS1_out <= TXBUFSTATUS1_outdelay after OUT_DELAY;
  TXKERR0_out <= TXKERR0_outdelay after OUT_DELAY;
  TXKERR1_out <= TXKERR1_outdelay after OUT_DELAY;
  TXN0_out <= TXN0_outdelay after OUT_DELAY;
  TXN1_out <= TXN1_outdelay after OUT_DELAY;
  TXP0_out <= TXP0_outdelay after OUT_DELAY;
  TXP1_out <= TXP1_outdelay after OUT_DELAY;
  TXRUNDISP0_out <= TXRUNDISP0_outdelay after OUT_DELAY;
  TXRUNDISP1_out <= TXRUNDISP1_outdelay after OUT_DELAY;
  
  CLKIN_ipd <= CLKIN after CLK_DELAY;
  DCLK_ipd <= DCLK after CLK_DELAY;
  RXUSRCLK0_ipd <= RXUSRCLK0 after CLK_DELAY;
  RXUSRCLK1_ipd <= RXUSRCLK1 after CLK_DELAY;
  RXUSRCLK20_ipd <= RXUSRCLK20 after CLK_DELAY;
  RXUSRCLK21_ipd <= RXUSRCLK21 after CLK_DELAY;
  TXUSRCLK0_ipd <= TXUSRCLK0 after CLK_DELAY;
  TXUSRCLK1_ipd <= TXUSRCLK1 after CLK_DELAY;
  TXUSRCLK20_ipd <= TXUSRCLK20 after CLK_DELAY;
  TXUSRCLK21_ipd <= TXUSRCLK21 after CLK_DELAY;
  
  DADDR_ipd <= DADDR after CLK_DELAY;
  DEN_ipd <= DEN after CLK_DELAY;
  DI_ipd <= DI after CLK_DELAY;
  DWE_ipd <= DWE after CLK_DELAY;
  GTPRESET_ipd <= GTPRESET after CLK_DELAY;
  GTPTEST_ipd <= GTPTEST after CLK_DELAY;
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
  RXELECIDLERESET0_ipd <= RXELECIDLERESET0 after CLK_DELAY;
  RXELECIDLERESET1_ipd <= RXELECIDLERESET1 after CLK_DELAY;
  RXENCHANSYNC0_ipd <= RXENCHANSYNC0 after CLK_DELAY;
  RXENCHANSYNC1_ipd <= RXENCHANSYNC1 after CLK_DELAY;
  RXENELECIDLERESETB_ipd <= RXENELECIDLERESETB after CLK_DELAY;
  RXENEQB0_ipd <= RXENEQB0 after CLK_DELAY;
  RXENEQB1_ipd <= RXENEQB1 after CLK_DELAY;
  RXENMCOMMAALIGN0_ipd <= RXENMCOMMAALIGN0 after CLK_DELAY;
  RXENMCOMMAALIGN1_ipd <= RXENMCOMMAALIGN1 after CLK_DELAY;
  RXENPCOMMAALIGN0_ipd <= RXENPCOMMAALIGN0 after CLK_DELAY;
  RXENPCOMMAALIGN1_ipd <= RXENPCOMMAALIGN1 after CLK_DELAY;
  RXENPRBSTST0_ipd <= RXENPRBSTST0 after CLK_DELAY;
  RXENPRBSTST1_ipd <= RXENPRBSTST1 after CLK_DELAY;
  RXENSAMPLEALIGN0_ipd <= RXENSAMPLEALIGN0 after CLK_DELAY;
  RXENSAMPLEALIGN1_ipd <= RXENSAMPLEALIGN1 after CLK_DELAY;
  RXEQMIX0_ipd <= RXEQMIX0 after CLK_DELAY;
  RXEQMIX1_ipd <= RXEQMIX1 after CLK_DELAY;
  RXEQPOLE0_ipd <= RXEQPOLE0 after CLK_DELAY;
  RXEQPOLE1_ipd <= RXEQPOLE1 after CLK_DELAY;
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
  TXENPMAPHASEALIGN_ipd <= TXENPMAPHASEALIGN after CLK_DELAY;
  TXENPRBSTST0_ipd <= TXENPRBSTST0 after CLK_DELAY;
  TXENPRBSTST1_ipd <= TXENPRBSTST1 after CLK_DELAY;
  TXINHIBIT0_ipd <= TXINHIBIT0 after CLK_DELAY;
  TXINHIBIT1_ipd <= TXINHIBIT1 after CLK_DELAY;
  TXPMASETPHASE_ipd <= TXPMASETPHASE after CLK_DELAY;
  TXPOLARITY0_ipd <= TXPOLARITY0 after CLK_DELAY;
  TXPOLARITY1_ipd <= TXPOLARITY1 after CLK_DELAY;
  TXPOWERDOWN0_ipd <= TXPOWERDOWN0 after CLK_DELAY;
  TXPOWERDOWN1_ipd <= TXPOWERDOWN1 after CLK_DELAY;
  TXPREEMPHASIS0_ipd <= TXPREEMPHASIS0 after CLK_DELAY;
  TXPREEMPHASIS1_ipd <= TXPREEMPHASIS1 after CLK_DELAY;
  TXRESET0_ipd <= TXRESET0 after CLK_DELAY;
  TXRESET1_ipd <= TXRESET1 after CLK_DELAY;
  
  CLKIN_indelay <= CLKIN_ipd after CLK_DELAY;
  DCLK_indelay <= DCLK_ipd after CLK_DELAY;
  RXUSRCLK0_indelay <= RXUSRCLK0_ipd after CLK_DELAY;
  RXUSRCLK1_indelay <= RXUSRCLK1_ipd after CLK_DELAY;
  RXUSRCLK20_indelay <= RXUSRCLK20_ipd after CLK_DELAY;
  RXUSRCLK21_indelay <= RXUSRCLK21_ipd after CLK_DELAY;
  TXUSRCLK0_indelay <= TXUSRCLK0_ipd after CLK_DELAY;
  TXUSRCLK1_indelay <= TXUSRCLK1_ipd after CLK_DELAY;
  TXUSRCLK20_indelay <= TXUSRCLK20_ipd after CLK_DELAY;
  TXUSRCLK21_indelay <= TXUSRCLK21_ipd after CLK_DELAY;
  
  DADDR_indelay <= DADDR_ipd after IN_DELAY;
  DEN_indelay <= DEN_ipd after IN_DELAY;
  DI_indelay <= DI_ipd after IN_DELAY;
  DWE_indelay <= DWE_ipd after IN_DELAY;
  GTPRESET_indelay <= GTPRESET_ipd after IN_DELAY;
  GTPTEST_indelay <= GTPTEST_ipd after IN_DELAY;
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
  RXELECIDLERESET0_indelay <= RXELECIDLERESET0_ipd after IN_DELAY;
  RXELECIDLERESET1_indelay <= RXELECIDLERESET1_ipd after IN_DELAY;
  RXENCHANSYNC0_indelay <= RXENCHANSYNC0_ipd after IN_DELAY;
  RXENCHANSYNC1_indelay <= RXENCHANSYNC1_ipd after IN_DELAY;
  RXENELECIDLERESETB_indelay <= RXENELECIDLERESETB_ipd after IN_DELAY;
  RXENEQB0_indelay <= RXENEQB0_ipd after IN_DELAY;
  RXENEQB1_indelay <= RXENEQB1_ipd after IN_DELAY;
  RXENMCOMMAALIGN0_indelay <= RXENMCOMMAALIGN0_ipd after IN_DELAY;
  RXENMCOMMAALIGN1_indelay <= RXENMCOMMAALIGN1_ipd after IN_DELAY;
  RXENPCOMMAALIGN0_indelay <= RXENPCOMMAALIGN0_ipd after IN_DELAY;
  RXENPCOMMAALIGN1_indelay <= RXENPCOMMAALIGN1_ipd after IN_DELAY;
  RXENPRBSTST0_indelay <= RXENPRBSTST0_ipd after IN_DELAY;
  RXENPRBSTST1_indelay <= RXENPRBSTST1_ipd after IN_DELAY;
  RXENSAMPLEALIGN0_indelay <= RXENSAMPLEALIGN0_ipd after IN_DELAY;
  RXENSAMPLEALIGN1_indelay <= RXENSAMPLEALIGN1_ipd after IN_DELAY;
  RXEQMIX0_indelay <= RXEQMIX0_ipd after IN_DELAY;
  RXEQMIX1_indelay <= RXEQMIX1_ipd after IN_DELAY;
  RXEQPOLE0_indelay <= RXEQPOLE0_ipd after IN_DELAY;
  RXEQPOLE1_indelay <= RXEQPOLE1_ipd after IN_DELAY;
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
  TXENPMAPHASEALIGN_indelay <= TXENPMAPHASEALIGN_ipd after IN_DELAY;
  TXENPRBSTST0_indelay <= TXENPRBSTST0_ipd after IN_DELAY;
  TXENPRBSTST1_indelay <= TXENPRBSTST1_ipd after IN_DELAY;
  TXINHIBIT0_indelay <= TXINHIBIT0_ipd after IN_DELAY;
  TXINHIBIT1_indelay <= TXINHIBIT1_ipd after IN_DELAY;
  TXPMASETPHASE_indelay <= TXPMASETPHASE_ipd after IN_DELAY;
  TXPOLARITY0_indelay <= TXPOLARITY0_ipd after IN_DELAY;
  TXPOLARITY1_indelay <= TXPOLARITY1_ipd after IN_DELAY;
  TXPOWERDOWN0_indelay <= TXPOWERDOWN0_ipd after IN_DELAY;
  TXPOWERDOWN1_indelay <= TXPOWERDOWN1_ipd after IN_DELAY;
  TXPREEMPHASIS0_indelay <= TXPREEMPHASIS0_ipd after IN_DELAY;
  TXPREEMPHASIS1_indelay <= TXPREEMPHASIS1_ipd after IN_DELAY;
  TXRESET0_indelay <= TXRESET0_ipd after IN_DELAY;
  TXRESET1_indelay <= TXRESET1_ipd after IN_DELAY;

  	gtp_dual_fast_bw_1 : GTP_DUAL_FAST
	port map (
	AC_CAP_DIS_0  =>  AC_CAP_DIS_0_BINARY,
	AC_CAP_DIS_1  =>  AC_CAP_DIS_1_BINARY,
	ALIGN_COMMA_WORD_0  =>  ALIGN_COMMA_WORD_0_BINARY,
	ALIGN_COMMA_WORD_1  =>  ALIGN_COMMA_WORD_1_BINARY,
	CHAN_BOND_1_MAX_SKEW_0  =>  CHAN_BOND_1_MAX_SKEW_0_BINARY,
	CHAN_BOND_1_MAX_SKEW_1  =>  CHAN_BOND_1_MAX_SKEW_1_BINARY,
	CHAN_BOND_2_MAX_SKEW_0  =>  CHAN_BOND_2_MAX_SKEW_0_BINARY,
	CHAN_BOND_2_MAX_SKEW_1  =>  CHAN_BOND_2_MAX_SKEW_1_BINARY,
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
        PCS_COM_CFG      => PCS_COM_CFG_BINARY,
	PLL_DIVSEL_FB  =>  PLL_DIVSEL_FB_BINARY,
	PLL_DIVSEL_REF  =>  PLL_DIVSEL_REF_BINARY,
	PLL_RXDIVSEL_OUT_0  =>  PLL_RXDIVSEL_OUT_0_BINARY,
	PLL_RXDIVSEL_OUT_1  =>  PLL_RXDIVSEL_OUT_1_BINARY,
	PLL_SATA_0  =>  PLL_SATA_0_BINARY,
	PLL_SATA_1  =>  PLL_SATA_1_BINARY,
	PLL_TXDIVSEL_COMM_OUT  =>  PLL_TXDIVSEL_COMM_OUT_BINARY,
	PLL_TXDIVSEL_OUT_0  =>  PLL_TXDIVSEL_OUT_0_BINARY,
	PLL_TXDIVSEL_OUT_1  =>  PLL_TXDIVSEL_OUT_1_BINARY,
	PMA_CDR_SCAN_0  =>  PMA_CDR_SCAN_0_BINARY,
	PMA_CDR_SCAN_1  =>  PMA_CDR_SCAN_1_BINARY,
	PMA_RX_CFG_0  =>  PMA_RX_CFG_0_BINARY,
	PMA_RX_CFG_1  =>  PMA_RX_CFG_1_BINARY,
	PRBS_ERR_THRESHOLD_0  =>  PRBS_ERR_THRESHOLD_0_BINARY,
	PRBS_ERR_THRESHOLD_1  =>  PRBS_ERR_THRESHOLD_1_BINARY,
	RCV_TERM_GND_0  =>  RCV_TERM_GND_0_BINARY,
	RCV_TERM_GND_1  =>  RCV_TERM_GND_1_BINARY,
	RCV_TERM_MID_0  =>  RCV_TERM_MID_0_BINARY,
	RCV_TERM_MID_1  =>  RCV_TERM_MID_1_BINARY,
	RCV_TERM_VTTRX_0  =>  RCV_TERM_VTTRX_0_BINARY,
	RCV_TERM_VTTRX_1  =>  RCV_TERM_VTTRX_1_BINARY,
	RX_BUFFER_USE_0  =>  RX_BUFFER_USE_0_BINARY,
	RX_BUFFER_USE_1  =>  RX_BUFFER_USE_1_BINARY,
	RX_DECODE_SEQ_MATCH_0  =>  RX_DECODE_SEQ_MATCH_0_BINARY,
	RX_DECODE_SEQ_MATCH_1  =>  RX_DECODE_SEQ_MATCH_1_BINARY,
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
	SIM_GTPRESET_SPEEDUP  =>  SIM_GTPRESET_SPEEDUP_BINARY,
	SIM_PLL_PERDIV2  =>  SIM_PLL_PERDIV2_BINARY,
        SIM_RECEIVER_DETECT_PASS0  =>  SIM_RECEIVER_DETECT_PASS0_BINARY,
	SIM_RECEIVER_DETECT_PASS1  =>  SIM_RECEIVER_DETECT_PASS1_BINARY,
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
	TXRX_INVERT_0  =>  TXRX_INVERT_0_BINARY,
	TXRX_INVERT_1  =>  TXRX_INVERT_1_BINARY,
	TX_BUFFER_USE_0  =>  TX_BUFFER_USE_0_BINARY,
	TX_BUFFER_USE_1  =>  TX_BUFFER_USE_1_BINARY,
	TX_DIFF_BOOST_0  =>  TX_DIFF_BOOST_0_BINARY,
	TX_DIFF_BOOST_1  =>  TX_DIFF_BOOST_1_BINARY,
	TX_SYNC_FILTERB  =>  TX_SYNC_FILTERB_BINARY,
	TX_XCLK_SEL_0  =>  TX_XCLK_SEL_0_BINARY,
	TX_XCLK_SEL_1  =>  TX_XCLK_SEL_1_BINARY,
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
	RXDISPERR0  =>  RXDISPERR0_outdelay,
	RXDISPERR1  =>  RXDISPERR1_outdelay,
	RXELECIDLE0  =>  RXELECIDLE0_outdelay,
	RXELECIDLE1  =>  RXELECIDLE1_outdelay,
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
	RXSTATUS0  =>  RXSTATUS0_outdelay,
	RXSTATUS1  =>  RXSTATUS1_outdelay,
	RXVALID0  =>  RXVALID0_outdelay,
	RXVALID1  =>  RXVALID1_outdelay,
	TXBUFSTATUS0  =>  TXBUFSTATUS0_outdelay,
	TXBUFSTATUS1  =>  TXBUFSTATUS1_outdelay,
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
	DI  =>  DI_indelay,
	DWE  =>  DWE_indelay,
        GSR => GSR,
	GTPRESET  =>  GTPRESET_indelay,
	GTPTEST  =>  GTPTEST_indelay,
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
	RXELECIDLERESET0  =>  RXELECIDLERESET0_indelay,
	RXELECIDLERESET1  =>  RXELECIDLERESET1_indelay,
	RXENCHANSYNC0  =>  RXENCHANSYNC0_indelay,
	RXENCHANSYNC1  =>  RXENCHANSYNC1_indelay,
	RXENELECIDLERESETB  =>  RXENELECIDLERESETB_indelay,
	RXENEQB0  =>  RXENEQB0_indelay,
	RXENEQB1  =>  RXENEQB1_indelay,
	RXENMCOMMAALIGN0  =>  RXENMCOMMAALIGN0_indelay,
	RXENMCOMMAALIGN1  =>  RXENMCOMMAALIGN1_indelay,
	RXENPCOMMAALIGN0  =>  RXENPCOMMAALIGN0_indelay,
	RXENPCOMMAALIGN1  =>  RXENPCOMMAALIGN1_indelay,
	RXENPRBSTST0  =>  RXENPRBSTST0_indelay,
	RXENPRBSTST1  =>  RXENPRBSTST1_indelay,
	RXENSAMPLEALIGN0  =>  RXENSAMPLEALIGN0_indelay,
	RXENSAMPLEALIGN1  =>  RXENSAMPLEALIGN1_indelay,
	RXEQMIX0  =>  RXEQMIX0_indelay,
	RXEQMIX1  =>  RXEQMIX1_indelay,
	RXEQPOLE0  =>  RXEQPOLE0_indelay,
	RXEQPOLE1  =>  RXEQPOLE1_indelay,
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
	TXENPMAPHASEALIGN  =>  TXENPMAPHASEALIGN_indelay,
	TXENPRBSTST0  =>  TXENPRBSTST0_indelay,
	TXENPRBSTST1  =>  TXENPRBSTST1_indelay,
	TXINHIBIT0  =>  TXINHIBIT0_indelay,
	TXINHIBIT1  =>  TXINHIBIT1_indelay,
	TXPMASETPHASE  =>  TXPMASETPHASE_indelay,
	TXPOLARITY0  =>  TXPOLARITY0_indelay,
	TXPOLARITY1  =>  TXPOLARITY1_indelay,
	TXPOWERDOWN0  =>  TXPOWERDOWN0_indelay,
	TXPOWERDOWN1  =>  TXPOWERDOWN1_indelay,
	TXPREEMPHASIS0  =>  TXPREEMPHASIS0_indelay,
	TXPREEMPHASIS1  =>  TXPREEMPHASIS1_indelay,
	TXRESET0  =>  TXRESET0_indelay,
	TXRESET1  =>  TXRESET1_indelay,
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
       case PLL_TXDIVSEL_COMM_OUT is
           when   1  =>  PLL_TXDIVSEL_COMM_OUT_BINARY <= "00";
           when   2  =>  PLL_TXDIVSEL_COMM_OUT_BINARY <= "01";
           when   4  =>  PLL_TXDIVSEL_COMM_OUT_BINARY <= "10";
           when others  =>  assert FALSE report "Error : PLL_TXDIVSEL_COMM_OUT is not in 1, 2, 4." severity error;
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
       case TX_DIFF_BOOST_0 is
           when FALSE   =>  TX_DIFF_BOOST_0_BINARY <= '0';
           when TRUE    =>  TX_DIFF_BOOST_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TX_DIFF_BOOST_0 is neither TRUE nor FALSE." severity error;
       end case;
       case TX_DIFF_BOOST_1 is
           when FALSE   =>  TX_DIFF_BOOST_1_BINARY <= '0';
           when TRUE    =>  TX_DIFF_BOOST_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TX_DIFF_BOOST_1 is neither TRUE nor FALSE." severity error;
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
       case TX_SYNC_FILTERB is
           when   0  =>  TX_SYNC_FILTERB_BINARY <= '0';
           when   1  =>  TX_SYNC_FILTERB_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TX_SYNC_FILTERB is not in 0, 1." severity error;
       end case;
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
       case RCV_TERM_MID_0 is
           when FALSE   =>  RCV_TERM_MID_0_BINARY <= '0';
           when TRUE    =>  RCV_TERM_MID_0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RCV_TERM_MID_0 is neither TRUE nor FALSE." severity error;
       end case;
       case RCV_TERM_MID_1 is
           when FALSE   =>  RCV_TERM_MID_1_BINARY <= '0';
           when TRUE    =>  RCV_TERM_MID_1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RCV_TERM_MID_1 is neither TRUE nor FALSE." severity error;
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
       case SIM_GTPRESET_SPEEDUP is
           when   0  =>  SIM_GTPRESET_SPEEDUP_BINARY <= '0';
           when   1  =>  SIM_GTPRESET_SPEEDUP_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SIM_GTPRESET_SPEEDUP is not in 0, 1." severity error;
       end case;
--     case SIM_MODE is
           if((SIM_MODE = "FAST") or (SIM_MODE = "fast")) then
               SIM_MODE_BINARY <= '1';
           elsif ((SIM_MODE = "LEGACY") or (SIM_MODE = "legacy")) then
             assert FALSE report "Warning : The Attribute SIM_MODE on GTP_DUAL instance is set to LEGACY. The Legacy model is not supported from ISE 11.1 onwards. GTP_DUAL defaults to FAST model. There are no functionality differences between GTP_DUAL LEGACY and GTP_DUAL FAST simulation models. Although, if you want to use the GTP_DUAL LEGACY model, please use an earlier ISE build." severity warning;
           else
             assert FALSE report "Warning : SIM_MODE is not set to FAST." severity warning;
            end if;
--     end case;
       case SIM_RECEIVER_DETECT_PASS0 is
           when FALSE   =>  SIM_RECEIVER_DETECT_PASS0_BINARY <= '0';
           when TRUE    =>  SIM_RECEIVER_DETECT_PASS0_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SIM_RECEIVER_DETECT_PASS0 is neither TRUE nor FALSE." severity error;
       end case;
       case SIM_RECEIVER_DETECT_PASS1 is
           when FALSE   =>  SIM_RECEIVER_DETECT_PASS1_BINARY <= '0';
           when TRUE    =>  SIM_RECEIVER_DETECT_PASS1_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SIM_RECEIVER_DETECT_PASS1 is neither TRUE nor FALSE." severity error;
       end case;     
	wait;
	end process INIPROC;

	TIMING : process

--  Pin timing violations (clock input pins)

--  Pin Timing Violations (all input pins)

--  Output Pin glitch declaration
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
	variable  RXNOTINTABLE00_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE01_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR00_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR01_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK00_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK01_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP00_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP01_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA00_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA01_GlitchData : VitalGlitchDataType;
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
	variable  RXNOTINTABLE10_GlitchData : VitalGlitchDataType;
	variable  RXNOTINTABLE11_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR10_GlitchData : VitalGlitchDataType;
	variable  RXDISPERR11_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK10_GlitchData : VitalGlitchDataType;
	variable  RXCHARISK11_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP10_GlitchData : VitalGlitchDataType;
	variable  RXRUNDISP11_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA10_GlitchData : VitalGlitchDataType;
	variable  RXCHARISCOMMA11_GlitchData : VitalGlitchDataType;
	variable  RXVALID1_GlitchData : VitalGlitchDataType;
	variable  RESETDONE0_GlitchData : VitalGlitchDataType;
	variable  RESETDONE1_GlitchData : VitalGlitchDataType;
	variable  TXKERR00_GlitchData : VitalGlitchDataType;
	variable  TXKERR01_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP00_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP01_GlitchData : VitalGlitchDataType;
	variable  TXBUFSTATUS00_GlitchData : VitalGlitchDataType;
	variable  TXBUFSTATUS01_GlitchData : VitalGlitchDataType;
	variable  TXKERR10_GlitchData : VitalGlitchDataType;
	variable  TXKERR11_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP10_GlitchData : VitalGlitchDataType;
	variable  TXRUNDISP11_GlitchData : VitalGlitchDataType;
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
begin

--  Output-to-Clock path delay
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
	Paths         => (0 => (TXUSRCLK20_ipd'last_event, PATH_DELAY,TRUE)),
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
	Paths         => (0 => (TXUSRCLK21_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);

  
--  Wait signal (input/output pins)
   wait on
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
	RXDISPERR0_out,
	RXDISPERR1_out,
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
	RXSTATUS0_out,
	RXSTATUS1_out,
	RXVALID0_out,
	RXVALID1_out,
	TXBUFSTATUS0_out,
	TXBUFSTATUS1_out,
	TXKERR0_out,
	TXKERR1_out,
	TXRUNDISP0_out,
	TXRUNDISP1_out,

	CLKIN_ipd,
	DADDR_ipd,
	DCLK_ipd,
	DEN_ipd,
	DI_ipd,
	DWE_ipd,
	GTPRESET_ipd,
	GTPTEST_ipd,
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
	RXELECIDLERESET0_ipd,
	RXELECIDLERESET1_ipd,
	RXENCHANSYNC0_ipd,
	RXENCHANSYNC1_ipd,
	RXENELECIDLERESETB_ipd,
	RXENEQB0_ipd,
	RXENEQB1_ipd,
	RXENMCOMMAALIGN0_ipd,
	RXENMCOMMAALIGN1_ipd,
	RXENPCOMMAALIGN0_ipd,
	RXENPCOMMAALIGN1_ipd,
	RXENPRBSTST0_ipd,
	RXENPRBSTST1_ipd,
	RXENSAMPLEALIGN0_ipd,
	RXENSAMPLEALIGN1_ipd,
	RXEQMIX0_ipd,
	RXEQMIX1_ipd,
	RXEQPOLE0_ipd,
	RXEQPOLE1_ipd,
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
	TXENPMAPHASEALIGN_ipd,
	TXENPRBSTST0_ipd,
	TXENPRBSTST1_ipd,
	TXINHIBIT0_ipd,
	TXINHIBIT1_ipd,
	TXPMASETPHASE_ipd,
	TXPOLARITY0_ipd,
	TXPOLARITY1_ipd,
	TXPOWERDOWN0_ipd,
	TXPOWERDOWN1_ipd,
	TXPREEMPHASIS0_ipd,
	TXPREEMPHASIS1_ipd,
	TXRESET0_ipd,
	TXRESET1_ipd,
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

end GTP_DUAL_V;
