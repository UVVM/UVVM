-------------------------------------------------------
--  Copyright (c) 2010 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Simulation Library Component
--  /   /                      : Gigabit Transciever
-- /___/   /\      Filename    : GTXE1.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  10/24/08 - CR1014 - Initial version
--  11/14/08 - CR495047 - Add DRC checks
--  11/17/08 - CR496295 - Convert parameter type bit_vector to string to support VHDL simulation
--  11/19/08 - CR497301 - YML update for parameter default value 
--  02/11/09 - CR507680 - GTXE1 Attribute default changes
--  03/11/09 - CR511750 - Update attribute value to upper case
--  03/24/09 - CR514739 - PMA attribute default update
--  05/05/09 - CR520565 - Update OUT_DELAY from 100ps to 0ps
--  05/13/09 - CR521563 - Attribute POWER_SAVE default change
--  07/28/09 - CR528324 - Default Attribute YML updates
--  08/13/09 - CR530897 - writer bug, update TX_PMADATA_OPT bit_vector to bit
--  09/22/09 - CR532191 - YML update to add RXPRBSERR_LOOPBACK, SIM_VERSION updated to "2.0", add input RXDLYALIGNMONENB/TXDLYALIGNMONENB
--  10/13/09 - CR535495 - Add default value for new pins RXDLYALIGNMONENB/TXDLYALIGNMONENB
--  03/04/10 - CR552249 - Attribute updates - YML & RTL updated
--  03/16/10 - CR552250 - Additional DRC checks added
--  05/11/10 - CR552250 - DRC check bug fixed
--  06/03/10 - CR562405 - POWER_SAVE DRC checks updated to _BINARY
--  12/02/10 - CR585350 - DRC check added for POWER_SAVE[5:4]
--  01/06/10 - CR589037 - DRC checks updated
-------------------------------------------------------

----- CELL GTXE1 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all; 
use unisim.vpkg.all;

library secureip;
use secureip.all;


  entity GTXE1 is
    generic (
      AC_CAP_DIS : boolean := TRUE;
      ALIGN_COMMA_WORD : integer := 1;
      BGTEST_CFG : bit_vector := "00";
      BIAS_CFG : bit_vector := X"00000";
      CDR_PH_ADJ_TIME : bit_vector := "10100";
      CHAN_BOND_1_MAX_SKEW : integer := 7;
      CHAN_BOND_2_MAX_SKEW : integer := 1;
      CHAN_BOND_KEEP_ALIGN : boolean := FALSE;
      CHAN_BOND_SEQ_1_1 : bit_vector := "0101111100";
      CHAN_BOND_SEQ_1_2 : bit_vector := "0001001010";
      CHAN_BOND_SEQ_1_3 : bit_vector := "0001001010";
      CHAN_BOND_SEQ_1_4 : bit_vector := "0110111100";
      CHAN_BOND_SEQ_1_ENABLE : bit_vector := "1111";
      CHAN_BOND_SEQ_2_1 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_2 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_3 : bit_vector := "0110111100";
      CHAN_BOND_SEQ_2_4 : bit_vector := "0100111100";
      CHAN_BOND_SEQ_2_CFG : bit_vector := "00000";
      CHAN_BOND_SEQ_2_ENABLE : bit_vector := "1111";
      CHAN_BOND_SEQ_2_USE : boolean := FALSE;
      CHAN_BOND_SEQ_LEN : integer := 1;
      CLK_CORRECT_USE : boolean := TRUE;
      CLK_COR_ADJ_LEN : integer := 1;
      CLK_COR_DET_LEN : integer := 1;
      CLK_COR_INSERT_IDLE_FLAG : boolean := FALSE;
      CLK_COR_KEEP_IDLE : boolean := FALSE;
      CLK_COR_MAX_LAT : integer := 20;
      CLK_COR_MIN_LAT : integer := 18;
      CLK_COR_PRECEDENCE : boolean := TRUE;
      CLK_COR_REPEAT_WAIT : integer := 0;
      CLK_COR_SEQ_1_1 : bit_vector := "0100011100";
      CLK_COR_SEQ_1_2 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_3 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_4 : bit_vector := "0000000000";
      CLK_COR_SEQ_1_ENABLE : bit_vector := "1111";
      CLK_COR_SEQ_2_1 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_2 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_3 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_4 : bit_vector := "0000000000";
      CLK_COR_SEQ_2_ENABLE : bit_vector := "1111";
      CLK_COR_SEQ_2_USE : boolean := FALSE;
      CM_TRIM : bit_vector := "01";
      COMMA_10B_ENABLE : bit_vector := "1111111111";
      COMMA_DOUBLE : boolean := FALSE;
      COM_BURST_VAL : bit_vector := "1111";
      DEC_MCOMMA_DETECT : boolean := TRUE;
      DEC_PCOMMA_DETECT : boolean := TRUE;
      DEC_VALID_COMMA_ONLY : boolean := TRUE;
      DFE_CAL_TIME : bit_vector := "01100";
      DFE_CFG : bit_vector := "00011011";
      GEARBOX_ENDEC : bit_vector := "000";
      GEN_RXUSRCLK : boolean := TRUE;
      GEN_TXUSRCLK : boolean := TRUE;
      GTX_CFG_PWRUP : boolean := TRUE;
      MCOMMA_10B_VALUE : bit_vector := "1010000011";
      MCOMMA_DETECT : boolean := TRUE;
      OOBDETECT_THRESHOLD : bit_vector := "011";
      PCI_EXPRESS_MODE : boolean := FALSE;
      PCOMMA_10B_VALUE : bit_vector := "0101111100";
      PCOMMA_DETECT : boolean := TRUE;
      PMA_CAS_CLK_EN : boolean := FALSE;
      PMA_CDR_SCAN : bit_vector := X"640404C";
      PMA_CFG : bit_vector :=  X"0040000040000000003";
      PMA_RXSYNC_CFG : bit_vector := X"00";
      PMA_RX_CFG : bit_vector := X"05CE048";
      PMA_TX_CFG : bit_vector := X"00082";
      POWER_SAVE : bit_vector := "0000110100";
      RCV_TERM_GND : boolean := FALSE;
      RCV_TERM_VTTRX : boolean := TRUE;
      RXGEARBOX_USE : boolean := FALSE;
      RXPLL_COM_CFG : bit_vector := X"21680A";
      RXPLL_CP_CFG : bit_vector := X"00";
      RXPLL_DIVSEL45_FB : integer := 5;
      RXPLL_DIVSEL_FB : integer := 2;
      RXPLL_DIVSEL_OUT : integer := 1;
      RXPLL_DIVSEL_REF : integer := 1;
      RXPLL_LKDET_CFG : bit_vector := "111";
      RXPRBSERR_LOOPBACK : bit := '0';
      RXRECCLK_CTRL : string := "RXRECCLKPCS";
      RXRECCLK_DLY : bit_vector := "0000000000";
      RXUSRCLK_DLY : bit_vector := X"0000";
      RX_BUFFER_USE : boolean := TRUE;
      RX_CLK25_DIVIDER : integer := 6;
      RX_DATA_WIDTH : integer := 20;
      RX_DECODE_SEQ_MATCH : boolean := TRUE;
      RX_DLYALIGN_CTRINC : bit_vector := "0100";
      RX_DLYALIGN_EDGESET : bit_vector := "00110";
      RX_DLYALIGN_LPFINC : bit_vector := "0111";
      RX_DLYALIGN_MONSEL : bit_vector := "000";
      RX_DLYALIGN_OVRDSETTING : bit_vector := "00000000";
      RX_EN_IDLE_HOLD_CDR : boolean := FALSE;
      RX_EN_IDLE_HOLD_DFE : boolean := TRUE;
      RX_EN_IDLE_RESET_BUF : boolean := TRUE;
      RX_EN_IDLE_RESET_FR : boolean := TRUE;
      RX_EN_IDLE_RESET_PH : boolean := TRUE;
      RX_EN_MODE_RESET_BUF : boolean := TRUE;
      RX_EN_RATE_RESET_BUF : boolean := TRUE;
      RX_EN_REALIGN_RESET_BUF : boolean := FALSE;
      RX_EN_REALIGN_RESET_BUF2 : boolean := FALSE;
      RX_EYE_OFFSET : bit_vector := X"4C";
      RX_EYE_SCANMODE : bit_vector := "00";
      RX_FIFO_ADDR_MODE : string := "FULL";
      RX_IDLE_HI_CNT : bit_vector := "1000";
      RX_IDLE_LO_CNT : bit_vector := "0000";
      RX_LOSS_OF_SYNC_FSM : boolean := FALSE;
      RX_LOS_INVALID_INCR : integer := 1;
      RX_LOS_THRESHOLD : integer := 4;
      RX_OVERSAMPLE_MODE : boolean := FALSE;
      RX_SLIDE_AUTO_WAIT : integer := 5;
      RX_SLIDE_MODE : string := "OFF";
      RX_XCLK_SEL : string := "RXREC";
      SAS_MAX_COMSAS : integer := 52;
      SAS_MIN_COMSAS : integer := 40;
      SATA_BURST_VAL : bit_vector := "100";
      SATA_IDLE_VAL : bit_vector := "100";
      SATA_MAX_BURST : integer := 7;
      SATA_MAX_INIT : integer := 22;
      SATA_MAX_WAKE : integer := 7;
      SATA_MIN_BURST : integer := 4;
      SATA_MIN_INIT : integer := 12;
      SATA_MIN_WAKE : integer := 4;
      SHOW_REALIGN_COMMA : boolean := TRUE;
      SIM_GTXRESET_SPEEDUP : integer := 1;
      SIM_RECEIVER_DETECT_PASS : boolean := TRUE;
      SIM_RXREFCLK_SOURCE : bit_vector := "000";
      SIM_TXREFCLK_SOURCE : bit_vector := "000";
      SIM_TX_ELEC_IDLE_LEVEL : string := "X";
      SIM_VERSION : string := "2.0";
      TERMINATION_CTRL : bit_vector := "10100";
      TERMINATION_OVRD : boolean := FALSE;
      TRANS_TIME_FROM_P2 : bit_vector := X"03C";
      TRANS_TIME_NON_P2 : bit_vector := X"19";
      TRANS_TIME_RATE : bit_vector := X"0E";
      TRANS_TIME_TO_P2 : bit_vector := X"064";
      TST_ATTR : bit_vector := X"00000000";
      TXDRIVE_LOOPBACK_HIZ : boolean := FALSE;
      TXDRIVE_LOOPBACK_PD : boolean := FALSE;
      TXGEARBOX_USE : boolean := FALSE;
      TXOUTCLK_CTRL : string := "TXOUTCLKPCS";
      TXOUTCLK_DLY : bit_vector := "0000000000";
      TXPLL_COM_CFG : bit_vector := X"21680A";
      TXPLL_CP_CFG : bit_vector := X"00";
      TXPLL_DIVSEL45_FB : integer := 5;
      TXPLL_DIVSEL_FB : integer := 2;
      TXPLL_DIVSEL_OUT : integer := 1;
      TXPLL_DIVSEL_REF : integer := 1;
      TXPLL_LKDET_CFG : bit_vector := "111";
      TXPLL_SATA : bit_vector := "00";
      TX_BUFFER_USE : boolean := TRUE;
      TX_BYTECLK_CFG : bit_vector := X"00";
      TX_CLK25_DIVIDER : integer := 6;
      TX_CLK_SOURCE : string := "RXPLL";
      TX_DATA_WIDTH : integer := 20;
      TX_DEEMPH_0 : bit_vector := "11010";
      TX_DEEMPH_1 : bit_vector := "10000";
      TX_DETECT_RX_CFG : bit_vector := X"1832";
      TX_DLYALIGN_CTRINC : bit_vector := "0100";
      TX_DLYALIGN_LPFINC : bit_vector := "0110";
      TX_DLYALIGN_MONSEL : bit_vector := "000";
      TX_DLYALIGN_OVRDSETTING : bit_vector := "10000000";
      TX_DRIVE_MODE : string := "DIRECT";
      TX_EN_RATE_RESET_BUF : boolean := TRUE;
      TX_IDLE_ASSERT_DELAY : bit_vector := "100";
      TX_IDLE_DEASSERT_DELAY : bit_vector := "010";
      TX_MARGIN_FULL_0 : bit_vector := "1001110";
      TX_MARGIN_FULL_1 : bit_vector := "1001001";
      TX_MARGIN_FULL_2 : bit_vector := "1000101";
      TX_MARGIN_FULL_3 : bit_vector := "1000010";
      TX_MARGIN_FULL_4 : bit_vector := "1000000";
      TX_MARGIN_LOW_0 : bit_vector := "1000110";
      TX_MARGIN_LOW_1 : bit_vector := "1000100";
      TX_MARGIN_LOW_2 : bit_vector := "1000010";
      TX_MARGIN_LOW_3 : bit_vector := "1000000";
      TX_MARGIN_LOW_4 : bit_vector := "1000000";
      TX_OVERSAMPLE_MODE : boolean := FALSE;
      TX_PMADATA_OPT : bit := '0';
      TX_TDCC_CFG : bit_vector := "11";
      TX_USRCLK_CFG : bit_vector := X"00";
      TX_XCLK_SEL : string := "TXUSR"
    );

    port (
      COMFINISH            : out std_ulogic;
      COMINITDET           : out std_ulogic;
      COMSASDET            : out std_ulogic;
      COMWAKEDET           : out std_ulogic;
      DFECLKDLYADJMON      : out std_logic_vector(5 downto 0);
      DFEEYEDACMON         : out std_logic_vector(4 downto 0);
      DFESENSCAL           : out std_logic_vector(2 downto 0);
      DFETAP1MONITOR       : out std_logic_vector(4 downto 0);
      DFETAP2MONITOR       : out std_logic_vector(4 downto 0);
      DFETAP3MONITOR       : out std_logic_vector(3 downto 0);
      DFETAP4MONITOR       : out std_logic_vector(3 downto 0);
      DRDY                 : out std_ulogic;
      DRPDO                : out std_logic_vector(15 downto 0);
      MGTREFCLKFAB         : out std_logic_vector(1 downto 0);
      PHYSTATUS            : out std_ulogic;
      RXBUFSTATUS          : out std_logic_vector(2 downto 0);
      RXBYTEISALIGNED      : out std_ulogic;
      RXBYTEREALIGN        : out std_ulogic;
      RXCHANBONDSEQ        : out std_ulogic;
      RXCHANISALIGNED      : out std_ulogic;
      RXCHANREALIGN        : out std_ulogic;
      RXCHARISCOMMA        : out std_logic_vector(3 downto 0);
      RXCHARISK            : out std_logic_vector(3 downto 0);
      RXCHBONDO            : out std_logic_vector(3 downto 0);
      RXCLKCORCNT          : out std_logic_vector(2 downto 0);
      RXCOMMADET           : out std_ulogic;
      RXDATA               : out std_logic_vector(31 downto 0);
      RXDATAVALID          : out std_ulogic;
      RXDISPERR            : out std_logic_vector(3 downto 0);
      RXDLYALIGNMONITOR    : out std_logic_vector(7 downto 0);
      RXELECIDLE           : out std_ulogic;
      RXHEADER             : out std_logic_vector(2 downto 0);
      RXHEADERVALID        : out std_ulogic;
      RXLOSSOFSYNC         : out std_logic_vector(1 downto 0);
      RXNOTINTABLE         : out std_logic_vector(3 downto 0);
      RXOVERSAMPLEERR      : out std_ulogic;
      RXPLLLKDET           : out std_ulogic;
      RXPRBSERR            : out std_ulogic;
      RXRATEDONE           : out std_ulogic;
      RXRECCLK             : out std_ulogic;
      RXRECCLKPCS          : out std_ulogic;
      RXRESETDONE          : out std_ulogic;
      RXRUNDISP            : out std_logic_vector(3 downto 0);
      RXSTARTOFSEQ         : out std_ulogic;
      RXSTATUS             : out std_logic_vector(2 downto 0);
      RXVALID              : out std_ulogic;
      TSTOUT               : out std_logic_vector(9 downto 0);
      TXBUFSTATUS          : out std_logic_vector(1 downto 0);
      TXDLYALIGNMONITOR    : out std_logic_vector(7 downto 0);
      TXGEARBOXREADY       : out std_ulogic;
      TXKERR               : out std_logic_vector(3 downto 0);
      TXN                  : out std_ulogic;
      TXOUTCLK             : out std_ulogic;
      TXOUTCLKPCS          : out std_ulogic;
      TXP                  : out std_ulogic;
      TXPLLLKDET           : out std_ulogic;
      TXRATEDONE           : out std_ulogic;
      TXRESETDONE          : out std_ulogic;
      TXRUNDISP            : out std_logic_vector(3 downto 0);

      
      DADDR                : in std_logic_vector(7 downto 0);
      DCLK                 : in std_ulogic;
      DEN                  : in std_ulogic;
      DFECLKDLYADJ         : in std_logic_vector(5 downto 0);
      DFEDLYOVRD           : in std_ulogic;
      DFETAP1              : in std_logic_vector(4 downto 0);
      DFETAP2              : in std_logic_vector(4 downto 0);
      DFETAP3              : in std_logic_vector(3 downto 0);
      DFETAP4              : in std_logic_vector(3 downto 0);
      DFETAPOVRD           : in std_ulogic;
      DI                   : in std_logic_vector(15 downto 0);
      DWE                  : in std_ulogic;
      GATERXELECIDLE       : in std_ulogic;
      GREFCLKRX            : in std_ulogic;
      GREFCLKTX            : in std_ulogic;
      GTXRXRESET           : in std_ulogic;
      GTXTEST              : in std_logic_vector(12 downto 0);
      GTXTXRESET           : in std_ulogic;
      IGNORESIGDET         : in std_ulogic;
      LOOPBACK             : in std_logic_vector(2 downto 0);
      MGTREFCLKRX          : in std_logic_vector(1 downto 0);
      MGTREFCLKTX          : in std_logic_vector(1 downto 0);
      NORTHREFCLKRX        : in std_logic_vector(1 downto 0);
      NORTHREFCLKTX        : in std_logic_vector(1 downto 0);
      PERFCLKRX            : in std_ulogic;
      PERFCLKTX            : in std_ulogic;
      PLLRXRESET           : in std_ulogic;
      PLLTXRESET           : in std_ulogic;
      PRBSCNTRESET         : in std_ulogic;
      RXBUFRESET           : in std_ulogic;
      RXCDRRESET           : in std_ulogic;
      RXCHBONDI            : in std_logic_vector(3 downto 0);
      RXCHBONDLEVEL        : in std_logic_vector(2 downto 0);
      RXCHBONDMASTER       : in std_ulogic;
      RXCHBONDSLAVE        : in std_ulogic;
      RXCOMMADETUSE        : in std_ulogic;
      RXDEC8B10BUSE        : in std_ulogic;
      RXDLYALIGNDISABLE    : in std_ulogic;
      RXDLYALIGNMONENB     : in std_ulogic := 'H';
      RXDLYALIGNOVERRIDE   : in std_ulogic;
      RXDLYALIGNRESET      : in std_ulogic;
      RXDLYALIGNSWPPRECURB : in std_ulogic;
      RXDLYALIGNUPDSW      : in std_ulogic;
      RXENCHANSYNC         : in std_ulogic;
      RXENMCOMMAALIGN      : in std_ulogic;
      RXENPCOMMAALIGN      : in std_ulogic;
      RXENPMAPHASEALIGN    : in std_ulogic;
      RXENPRBSTST          : in std_logic_vector(2 downto 0);
      RXENSAMPLEALIGN      : in std_ulogic;
      RXEQMIX              : in std_logic_vector(9 downto 0);
      RXGEARBOXSLIP        : in std_ulogic;
      RXN                  : in std_ulogic;
      RXP                  : in std_ulogic;
      RXPLLLKDETEN         : in std_ulogic;
      RXPLLPOWERDOWN       : in std_ulogic;
      RXPLLREFSELDY        : in std_logic_vector(2 downto 0);
      RXPMASETPHASE        : in std_ulogic;
      RXPOLARITY           : in std_ulogic;
      RXPOWERDOWN          : in std_logic_vector(1 downto 0);
      RXRATE               : in std_logic_vector(1 downto 0);
      RXRESET              : in std_ulogic;
      RXSLIDE              : in std_ulogic;
      RXUSRCLK             : in std_ulogic;
      RXUSRCLK2            : in std_ulogic;
      SOUTHREFCLKRX        : in std_logic_vector(1 downto 0);
      SOUTHREFCLKTX        : in std_logic_vector(1 downto 0);
      TSTCLK0              : in std_ulogic;
      TSTCLK1              : in std_ulogic;
      TSTIN                : in std_logic_vector(19 downto 0);
      TXBUFDIFFCTRL        : in std_logic_vector(2 downto 0);
      TXBYPASS8B10B        : in std_logic_vector(3 downto 0);
      TXCHARDISPMODE       : in std_logic_vector(3 downto 0);
      TXCHARDISPVAL        : in std_logic_vector(3 downto 0);
      TXCHARISK            : in std_logic_vector(3 downto 0);
      TXCOMINIT            : in std_ulogic;
      TXCOMSAS             : in std_ulogic;
      TXCOMWAKE            : in std_ulogic;
      TXDATA               : in std_logic_vector(31 downto 0);
      TXDEEMPH             : in std_ulogic;
      TXDETECTRX           : in std_ulogic;
      TXDIFFCTRL           : in std_logic_vector(3 downto 0);
      TXDLYALIGNDISABLE    : in std_ulogic;
      TXDLYALIGNMONENB     : in std_ulogic := 'H';
      TXDLYALIGNOVERRIDE   : in std_ulogic;
      TXDLYALIGNRESET      : in std_ulogic;
      TXDLYALIGNUPDSW      : in std_ulogic;
      TXELECIDLE           : in std_ulogic;
      TXENC8B10BUSE        : in std_ulogic;
      TXENPMAPHASEALIGN    : in std_ulogic;
      TXENPRBSTST          : in std_logic_vector(2 downto 0);
      TXHEADER             : in std_logic_vector(2 downto 0);
      TXINHIBIT            : in std_ulogic;
      TXMARGIN             : in std_logic_vector(2 downto 0);
      TXPDOWNASYNCH        : in std_ulogic;
      TXPLLLKDETEN         : in std_ulogic;
      TXPLLPOWERDOWN       : in std_ulogic;
      TXPLLREFSELDY        : in std_logic_vector(2 downto 0);
      TXPMASETPHASE        : in std_ulogic;
      TXPOLARITY           : in std_ulogic;
      TXPOSTEMPHASIS       : in std_logic_vector(4 downto 0);
      TXPOWERDOWN          : in std_logic_vector(1 downto 0);
      TXPRBSFORCEERR       : in std_ulogic;
      TXPREEMPHASIS        : in std_logic_vector(3 downto 0);
      TXRATE               : in std_logic_vector(1 downto 0);
      TXRESET              : in std_ulogic;
      TXSEQUENCE           : in std_logic_vector(6 downto 0);
      TXSTARTSEQ           : in std_ulogic;
      TXSWING              : in std_ulogic;
      TXUSRCLK             : in std_ulogic;
      TXUSRCLK2            : in std_ulogic;
      USRCODEERR           : in std_ulogic      
    );
  end GTXE1;

  architecture GTXE1_V of GTXE1 is
    component GTXE1_WRAP
      generic (
        AC_CAP_DIS : string;
        ALIGN_COMMA_WORD : integer;
        BGTEST_CFG : string;
        BIAS_CFG : string;
        CDR_PH_ADJ_TIME : string;
        CHAN_BOND_1_MAX_SKEW : integer;
        CHAN_BOND_2_MAX_SKEW : integer;
        CHAN_BOND_KEEP_ALIGN : string;
        CHAN_BOND_SEQ_1_1 : string;
        CHAN_BOND_SEQ_1_2 : string;
        CHAN_BOND_SEQ_1_3 : string;
        CHAN_BOND_SEQ_1_4 : string;
        CHAN_BOND_SEQ_1_ENABLE : string;
        CHAN_BOND_SEQ_2_1 : string;
        CHAN_BOND_SEQ_2_2 : string;
        CHAN_BOND_SEQ_2_3 : string;
        CHAN_BOND_SEQ_2_4 : string;
        CHAN_BOND_SEQ_2_CFG :string;
        CHAN_BOND_SEQ_2_ENABLE : string;
        CHAN_BOND_SEQ_2_USE : string;
        CHAN_BOND_SEQ_LEN : integer;
        CLK_CORRECT_USE : string;
        CLK_COR_ADJ_LEN : integer;
        CLK_COR_DET_LEN : integer;
        CLK_COR_INSERT_IDLE_FLAG : string;
        CLK_COR_KEEP_IDLE : string;
        CLK_COR_MAX_LAT : integer;
        CLK_COR_MIN_LAT : integer;
        CLK_COR_PRECEDENCE :  string;
        CLK_COR_REPEAT_WAIT : integer;
        CLK_COR_SEQ_1_1 : string;
        CLK_COR_SEQ_1_2 : string;
        CLK_COR_SEQ_1_3 : string;
        CLK_COR_SEQ_1_4 : string;
        CLK_COR_SEQ_1_ENABLE : string;
        CLK_COR_SEQ_2_1 : string;
        CLK_COR_SEQ_2_2 : string;
        CLK_COR_SEQ_2_3 : string;
        CLK_COR_SEQ_2_4 : string;
        CLK_COR_SEQ_2_ENABLE : string;
        CLK_COR_SEQ_2_USE : string;
        CM_TRIM : string;
        COMMA_10B_ENABLE : string; 
        COMMA_DOUBLE : string;
        COM_BURST_VAL : string;
        DEC_MCOMMA_DETECT : string;
        DEC_PCOMMA_DETECT : string;
        DEC_VALID_COMMA_ONLY : string;
        DFE_CAL_TIME : string;
        DFE_CFG : string;
        GEARBOX_ENDEC : string;
        GEN_RXUSRCLK : string;
        GEN_TXUSRCLK : string;
        GTX_CFG_PWRUP : string;
        MCOMMA_10B_VALUE : string;
        MCOMMA_DETECT : string;
        OOBDETECT_THRESHOLD : string;
        PCI_EXPRESS_MODE : string;
        PCOMMA_10B_VALUE :string;
        PCOMMA_DETECT : string;
        PMA_CAS_CLK_EN : string;
        PMA_CDR_SCAN : string;
        PMA_CFG : string;
        PMA_RXSYNC_CFG : string;
        PMA_RX_CFG : string;
        PMA_TX_CFG : string;
        POWER_SAVE : string;
        RCV_TERM_GND : string;
        RCV_TERM_VTTRX : string;
        RXGEARBOX_USE : string;
        RXPLL_COM_CFG : string;
        RXPLL_CP_CFG : string;
        RXPLL_DIVSEL45_FB : integer;
        RXPLL_DIVSEL_FB : integer;
        RXPLL_DIVSEL_OUT : integer;
        RXPLL_DIVSEL_REF : integer;
        RXPLL_LKDET_CFG :string;
        RXPRBSERR_LOOPBACK : string;
        RXRECCLK_CTRL : string;
        RXRECCLK_DLY : string;
        RXUSRCLK_DLY : string;
        RX_BUFFER_USE : string;
        RX_CLK25_DIVIDER : integer;
        RX_DATA_WIDTH : integer;
        RX_DECODE_SEQ_MATCH : string;
        RX_DLYALIGN_CTRINC : string;
        RX_DLYALIGN_EDGESET : string;
        RX_DLYALIGN_LPFINC : string;
        RX_DLYALIGN_MONSEL : string;
        RX_DLYALIGN_OVRDSETTING : string;
        RX_EN_IDLE_HOLD_CDR : string;
        RX_EN_IDLE_HOLD_DFE : string;
        RX_EN_IDLE_RESET_BUF : string;
        RX_EN_IDLE_RESET_FR : string;
        RX_EN_IDLE_RESET_PH : string;
        RX_EN_MODE_RESET_BUF : string;
        RX_EN_RATE_RESET_BUF : string;
        RX_EN_REALIGN_RESET_BUF : string;
        RX_EN_REALIGN_RESET_BUF2 : string;
        RX_EYE_OFFSET : string;
        RX_EYE_SCANMODE : string;
        RX_FIFO_ADDR_MODE : string;
        RX_IDLE_HI_CNT : string;
        RX_IDLE_LO_CNT : string;
        RX_LOSS_OF_SYNC_FSM : string;
        RX_LOS_INVALID_INCR : integer;
        RX_LOS_THRESHOLD : integer;
        RX_OVERSAMPLE_MODE : string;
        RX_SLIDE_AUTO_WAIT : integer;
        RX_SLIDE_MODE : string;
        RX_XCLK_SEL : string;
        SAS_MAX_COMSAS : integer;
        SAS_MIN_COMSAS : integer;
        SATA_BURST_VAL : string;
        SATA_IDLE_VAL : string;
        SATA_MAX_BURST : integer;
        SATA_MAX_INIT : integer;
        SATA_MAX_WAKE : integer;
        SATA_MIN_BURST : integer;
        SATA_MIN_INIT : integer;
        SATA_MIN_WAKE : integer;
        SHOW_REALIGN_COMMA : string;
        SIM_GTXRESET_SPEEDUP : integer;
        SIM_RECEIVER_DETECT_PASS : string;
        SIM_RXREFCLK_SOURCE : string;
        SIM_TXREFCLK_SOURCE : string;
        SIM_TX_ELEC_IDLE_LEVEL : string;
        SIM_VERSION : string;
        TERMINATION_CTRL : string;
        TERMINATION_OVRD : string;
        TRANS_TIME_FROM_P2 : string;
        TRANS_TIME_NON_P2 : string;
        TRANS_TIME_RATE : string;
        TRANS_TIME_TO_P2 : string;
        TST_ATTR : string;
        TXDRIVE_LOOPBACK_HIZ : string;
        TXDRIVE_LOOPBACK_PD : string;
        TXGEARBOX_USE : string;
        TXOUTCLK_CTRL : string;
        TXOUTCLK_DLY : string;
        TXPLL_COM_CFG : string;
        TXPLL_CP_CFG : string;
        TXPLL_DIVSEL45_FB : integer;
        TXPLL_DIVSEL_FB : integer;
        TXPLL_DIVSEL_OUT : integer;
        TXPLL_DIVSEL_REF : integer;
        TXPLL_LKDET_CFG : string;
        TXPLL_SATA :string;
        TX_BUFFER_USE : string;
        TX_BYTECLK_CFG : string;
        TX_CLK25_DIVIDER : integer;
        TX_CLK_SOURCE : string;
        TX_DATA_WIDTH : integer;
        TX_DEEMPH_0 : string;
        TX_DEEMPH_1 : string;
        TX_DETECT_RX_CFG : string;
        TX_DLYALIGN_CTRINC : string;
        TX_DLYALIGN_LPFINC : string;
        TX_DLYALIGN_MONSEL : string;
        TX_DLYALIGN_OVRDSETTING :string;
        TX_DRIVE_MODE : string;
        TX_EN_RATE_RESET_BUF : string;
        TX_IDLE_ASSERT_DELAY : string;
        TX_IDLE_DEASSERT_DELAY : string;
        TX_MARGIN_FULL_0 : string;
        TX_MARGIN_FULL_1 : string;
        TX_MARGIN_FULL_2 : string;
        TX_MARGIN_FULL_3 : string;
        TX_MARGIN_FULL_4 : string;
        TX_MARGIN_LOW_0 : string;
        TX_MARGIN_LOW_1 : string;
        TX_MARGIN_LOW_2 : string;
        TX_MARGIN_LOW_3 : string;
        TX_MARGIN_LOW_4 : string;
        TX_OVERSAMPLE_MODE : string;
        TX_PMADATA_OPT : string;
        TX_TDCC_CFG : string;
        TX_USRCLK_CFG : string;
        TX_XCLK_SEL : string        
      );
      
      port (
        COMFINISH            : out std_ulogic;
        COMINITDET           : out std_ulogic;
        COMSASDET            : out std_ulogic;
        COMWAKEDET           : out std_ulogic;
        DFECLKDLYADJMON      : out std_logic_vector(5 downto 0);
        DFEEYEDACMON         : out std_logic_vector(4 downto 0);
        DFESENSCAL           : out std_logic_vector(2 downto 0);
        DFETAP1MONITOR       : out std_logic_vector(4 downto 0);
        DFETAP2MONITOR       : out std_logic_vector(4 downto 0);
        DFETAP3MONITOR       : out std_logic_vector(3 downto 0);
        DFETAP4MONITOR       : out std_logic_vector(3 downto 0);
        DRDY                 : out std_ulogic;
        DRPDO                : out std_logic_vector(15 downto 0);
        MGTREFCLKFAB         : out std_logic_vector(1 downto 0);
        PHYSTATUS            : out std_ulogic;
        RXBUFSTATUS          : out std_logic_vector(2 downto 0);
        RXBYTEISALIGNED      : out std_ulogic;
        RXBYTEREALIGN        : out std_ulogic;
        RXCHANBONDSEQ        : out std_ulogic;
        RXCHANISALIGNED      : out std_ulogic;
        RXCHANREALIGN        : out std_ulogic;
        RXCHARISCOMMA        : out std_logic_vector(3 downto 0);
        RXCHARISK            : out std_logic_vector(3 downto 0);
        RXCHBONDO            : out std_logic_vector(3 downto 0);
        RXCLKCORCNT          : out std_logic_vector(2 downto 0);
        RXCOMMADET           : out std_ulogic;
        RXDATA               : out std_logic_vector(31 downto 0);
        RXDATAVALID          : out std_ulogic;
        RXDISPERR            : out std_logic_vector(3 downto 0);
        RXDLYALIGNMONITOR    : out std_logic_vector(7 downto 0);
        RXELECIDLE           : out std_ulogic;
        RXHEADER             : out std_logic_vector(2 downto 0);
        RXHEADERVALID        : out std_ulogic;
        RXLOSSOFSYNC         : out std_logic_vector(1 downto 0);
        RXNOTINTABLE         : out std_logic_vector(3 downto 0);
        RXOVERSAMPLEERR      : out std_ulogic;
        RXPLLLKDET           : out std_ulogic;
        RXPRBSERR            : out std_ulogic;
        RXRATEDONE           : out std_ulogic;
        RXRECCLK             : out std_ulogic;
        RXRECCLKPCS          : out std_ulogic;
        RXRESETDONE          : out std_ulogic;
        RXRUNDISP            : out std_logic_vector(3 downto 0);
        RXSTARTOFSEQ         : out std_ulogic;
        RXSTATUS             : out std_logic_vector(2 downto 0);
        RXVALID              : out std_ulogic;
        TSTOUT               : out std_logic_vector(9 downto 0);
        TXBUFSTATUS          : out std_logic_vector(1 downto 0);
        TXDLYALIGNMONITOR    : out std_logic_vector(7 downto 0);
        TXGEARBOXREADY       : out std_ulogic;
        TXKERR               : out std_logic_vector(3 downto 0);
        TXN                  : out std_ulogic;
        TXOUTCLK             : out std_ulogic;
        TXOUTCLKPCS          : out std_ulogic;
        TXP                  : out std_ulogic;
        TXPLLLKDET           : out std_ulogic;
        TXRATEDONE           : out std_ulogic;
        TXRESETDONE          : out std_ulogic;
        TXRUNDISP            : out std_logic_vector(3 downto 0);

        GSR                  : in std_ulogic;
        DADDR                : in std_logic_vector(7 downto 0);
        DCLK                 : in std_ulogic;
        DEN                  : in std_ulogic;
        DFECLKDLYADJ         : in std_logic_vector(5 downto 0);
        DFEDLYOVRD           : in std_ulogic;
        DFETAP1              : in std_logic_vector(4 downto 0);
        DFETAP2              : in std_logic_vector(4 downto 0);
        DFETAP3              : in std_logic_vector(3 downto 0);
        DFETAP4              : in std_logic_vector(3 downto 0);
        DFETAPOVRD           : in std_ulogic;
        DI                   : in std_logic_vector(15 downto 0);
        DWE                  : in std_ulogic;
        GATERXELECIDLE       : in std_ulogic;
        GREFCLKRX            : in std_ulogic;
        GREFCLKTX            : in std_ulogic;
        GTXRXRESET           : in std_ulogic;
        GTXTEST              : in std_logic_vector(12 downto 0);
        GTXTXRESET           : in std_ulogic;
        IGNORESIGDET         : in std_ulogic;
        LOOPBACK             : in std_logic_vector(2 downto 0);
        MGTREFCLKRX          : in std_logic_vector(1 downto 0);
        MGTREFCLKTX          : in std_logic_vector(1 downto 0);
        NORTHREFCLKRX        : in std_logic_vector(1 downto 0);
        NORTHREFCLKTX        : in std_logic_vector(1 downto 0);
        PERFCLKRX            : in std_ulogic;
        PERFCLKTX            : in std_ulogic;
        PLLRXRESET           : in std_ulogic;
        PLLTXRESET           : in std_ulogic;
        PRBSCNTRESET         : in std_ulogic;
        RXBUFRESET           : in std_ulogic;
        RXCDRRESET           : in std_ulogic;
        RXCHBONDI            : in std_logic_vector(3 downto 0);
        RXCHBONDLEVEL        : in std_logic_vector(2 downto 0);
        RXCHBONDMASTER       : in std_ulogic;
        RXCHBONDSLAVE        : in std_ulogic;
        RXCOMMADETUSE        : in std_ulogic;
        RXDEC8B10BUSE        : in std_ulogic;
        RXDLYALIGNDISABLE    : in std_ulogic;
        RXDLYALIGNMONENB     : in std_ulogic;
        RXDLYALIGNOVERRIDE   : in std_ulogic;
        RXDLYALIGNRESET      : in std_ulogic;
        RXDLYALIGNSWPPRECURB : in std_ulogic;
        RXDLYALIGNUPDSW      : in std_ulogic;
        RXENCHANSYNC         : in std_ulogic;
        RXENMCOMMAALIGN      : in std_ulogic;
        RXENPCOMMAALIGN      : in std_ulogic;
        RXENPMAPHASEALIGN    : in std_ulogic;
        RXENPRBSTST          : in std_logic_vector(2 downto 0);
        RXENSAMPLEALIGN      : in std_ulogic;
        RXEQMIX              : in std_logic_vector(9 downto 0);
        RXGEARBOXSLIP        : in std_ulogic;
        RXN                  : in std_ulogic;
        RXP                  : in std_ulogic;
        RXPLLLKDETEN         : in std_ulogic;
        RXPLLPOWERDOWN       : in std_ulogic;
        RXPLLREFSELDY        : in std_logic_vector(2 downto 0);
        RXPMASETPHASE        : in std_ulogic;
        RXPOLARITY           : in std_ulogic;
        RXPOWERDOWN          : in std_logic_vector(1 downto 0);
        RXRATE               : in std_logic_vector(1 downto 0);
        RXRESET              : in std_ulogic;
        RXSLIDE              : in std_ulogic;
        RXUSRCLK             : in std_ulogic;
        RXUSRCLK2            : in std_ulogic;
        SOUTHREFCLKRX        : in std_logic_vector(1 downto 0);
        SOUTHREFCLKTX        : in std_logic_vector(1 downto 0);
        TSTCLK0              : in std_ulogic;
        TSTCLK1              : in std_ulogic;
        TSTIN                : in std_logic_vector(19 downto 0);
        TXBUFDIFFCTRL        : in std_logic_vector(2 downto 0);
        TXBYPASS8B10B        : in std_logic_vector(3 downto 0);
        TXCHARDISPMODE       : in std_logic_vector(3 downto 0);
        TXCHARDISPVAL        : in std_logic_vector(3 downto 0);
        TXCHARISK            : in std_logic_vector(3 downto 0);
        TXCOMINIT            : in std_ulogic;
        TXCOMSAS             : in std_ulogic;
        TXCOMWAKE            : in std_ulogic;
        TXDATA               : in std_logic_vector(31 downto 0);
        TXDEEMPH             : in std_ulogic;
        TXDETECTRX           : in std_ulogic;
        TXDIFFCTRL           : in std_logic_vector(3 downto 0);
        TXDLYALIGNDISABLE    : in std_ulogic;
        TXDLYALIGNMONENB     : in std_ulogic;
        TXDLYALIGNOVERRIDE   : in std_ulogic;
        TXDLYALIGNRESET      : in std_ulogic;
        TXDLYALIGNUPDSW      : in std_ulogic;
        TXELECIDLE           : in std_ulogic;
        TXENC8B10BUSE        : in std_ulogic;
        TXENPMAPHASEALIGN    : in std_ulogic;
        TXENPRBSTST          : in std_logic_vector(2 downto 0);
        TXHEADER             : in std_logic_vector(2 downto 0);
        TXINHIBIT            : in std_ulogic;
        TXMARGIN             : in std_logic_vector(2 downto 0);
        TXPDOWNASYNCH        : in std_ulogic;
        TXPLLLKDETEN         : in std_ulogic;
        TXPLLPOWERDOWN       : in std_ulogic;
        TXPLLREFSELDY        : in std_logic_vector(2 downto 0);
        TXPMASETPHASE        : in std_ulogic;
        TXPOLARITY           : in std_ulogic;
        TXPOSTEMPHASIS       : in std_logic_vector(4 downto 0);
        TXPOWERDOWN          : in std_logic_vector(1 downto 0);
        TXPRBSFORCEERR       : in std_ulogic;
        TXPREEMPHASIS        : in std_logic_vector(3 downto 0);
        TXRATE               : in std_logic_vector(1 downto 0);
        TXRESET              : in std_ulogic;
        TXSEQUENCE           : in std_logic_vector(6 downto 0);
        TXSTARTSEQ           : in std_ulogic;
        TXSWING              : in std_ulogic;
        TXUSRCLK             : in std_ulogic;
        TXUSRCLK2            : in std_ulogic;
        USRCODEERR           : in std_ulogic        
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
    constant BGTEST_CFG_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(BGTEST_CFG)(1 downto 0);
    constant BIAS_CFG_BINARY : std_logic_vector(16 downto 0) := To_StdLogicVector(BIAS_CFG)(16 downto 0);
    constant CDR_PH_ADJ_TIME_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(CDR_PH_ADJ_TIME)(4 downto 0);
    constant CHAN_BOND_SEQ_1_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1)(9 downto 0);
    constant CHAN_BOND_SEQ_1_2_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2)(9 downto 0);
    constant CHAN_BOND_SEQ_1_3_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3)(9 downto 0);
    constant CHAN_BOND_SEQ_1_4_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4)(9 downto 0);
    constant CHAN_BOND_SEQ_1_ENABLE_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_ENABLE)(3 downto 0);
    constant CHAN_BOND_SEQ_2_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1)(9 downto 0);
    constant CHAN_BOND_SEQ_2_2_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2)(9 downto 0);
    constant CHAN_BOND_SEQ_2_3_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3)(9 downto 0);
    constant CHAN_BOND_SEQ_2_4_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4)(9 downto 0);
    constant CHAN_BOND_SEQ_2_CFG_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_CFG)(4 downto 0);
    constant CHAN_BOND_SEQ_2_ENABLE_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_ENABLE)(3 downto 0);
    constant CLK_COR_SEQ_1_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1)(9 downto 0);
    constant CLK_COR_SEQ_1_2_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2)(9 downto 0);
    constant CLK_COR_SEQ_1_3_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3)(9 downto 0);
    constant CLK_COR_SEQ_1_4_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4)(9 downto 0);
    constant CLK_COR_SEQ_1_ENABLE_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_ENABLE)(3 downto 0);
    constant CLK_COR_SEQ_2_1_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1)(9 downto 0);
    constant CLK_COR_SEQ_2_2_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2)(9 downto 0);
    constant CLK_COR_SEQ_2_3_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3)(9 downto 0);
    constant CLK_COR_SEQ_2_4_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4)(9 downto 0);
    constant CLK_COR_SEQ_2_ENABLE_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_ENABLE)(3 downto 0);
    constant CM_TRIM_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(CM_TRIM)(1 downto 0);
    constant COMMA_10B_ENABLE_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(COMMA_10B_ENABLE)(9 downto 0);
    constant COM_BURST_VAL_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(COM_BURST_VAL)(3 downto 0);
    constant DFE_CAL_TIME_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(DFE_CAL_TIME)(4 downto 0);
    constant DFE_CFG_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(DFE_CFG)(7 downto 0);
    constant GEARBOX_ENDEC_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(GEARBOX_ENDEC)(2 downto 0);
    constant MCOMMA_10B_VALUE_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(MCOMMA_10B_VALUE)(9 downto 0) ;
    constant OOBDETECT_THRESHOLD_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(OOBDETECT_THRESHOLD)(2 downto 0);
    constant PCOMMA_10B_VALUE_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(PCOMMA_10B_VALUE)(9 downto 0);
    constant PMA_CDR_SCAN_BINARY : std_logic_vector(26 downto 0) := To_StdLogicVector(PMA_CDR_SCAN)(26 downto 0);
    constant PMA_CFG_BINARY : std_logic_vector(75 downto 0) := To_StdLogicVector(PMA_CFG)(75 downto 0) ;
    constant PMA_RXSYNC_CFG_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(PMA_RXSYNC_CFG)(6 downto 0);
    constant PMA_RX_CFG_BINARY : std_logic_vector(24 downto 0) := To_StdLogicVector(PMA_RX_CFG)(24 downto 0);
    constant PMA_TX_CFG_BINARY : std_logic_vector(19 downto 0) := To_StdLogicVector(PMA_TX_CFG)(19 downto 0);
    constant POWER_SAVE_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(POWER_SAVE)(9 downto 0) ;
    constant RXPLL_COM_CFG_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(RXPLL_COM_CFG)(23 downto 0);
    constant RXPLL_CP_CFG_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(RXPLL_CP_CFG)(7 downto 0);
    constant RXPLL_LKDET_CFG_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RXPLL_LKDET_CFG)(2 downto 0);
    constant RXPRBSERR_LOOPBACK_BINARY : std_ulogic := To_StduLogic(RXPRBSERR_LOOPBACK);
    constant RXRECCLK_DLY_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(RXRECCLK_DLY)(9 downto 0);
    constant RXUSRCLK_DLY_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RXUSRCLK_DLY)(15 downto 0);
    constant RX_DLYALIGN_CTRINC_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_DLYALIGN_CTRINC)(3 downto 0);
    constant RX_DLYALIGN_EDGESET_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(RX_DLYALIGN_EDGESET)(4 downto 0);
    constant RX_DLYALIGN_LPFINC_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_DLYALIGN_LPFINC)(3 downto 0);
    constant RX_DLYALIGN_MONSEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(RX_DLYALIGN_MONSEL)(2 downto 0);
    constant RX_DLYALIGN_OVRDSETTING_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(RX_DLYALIGN_OVRDSETTING)(7 downto 0);
    constant RX_EYE_OFFSET_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(RX_EYE_OFFSET)(7 downto 0);
    constant RX_EYE_SCANMODE_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(RX_EYE_SCANMODE)(1 downto 0);
    constant RX_IDLE_HI_CNT_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_HI_CNT)(3 downto 0);
    constant RX_IDLE_LO_CNT_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(RX_IDLE_LO_CNT)(3 downto 0);
    constant SATA_BURST_VAL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_BURST_VAL)(2 downto 0);
    constant SATA_IDLE_VAL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SATA_IDLE_VAL)(2 downto 0);
    constant SIM_RXREFCLK_SOURCE_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SIM_RXREFCLK_SOURCE)(2 downto 0);
    constant SIM_TXREFCLK_SOURCE_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(SIM_TXREFCLK_SOURCE)(2 downto 0);
    constant TERMINATION_CTRL_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(TERMINATION_CTRL)(4 downto 0);
    constant TRANS_TIME_FROM_P2_BINARY : std_logic_vector(11 downto 0) := To_StdLogicVector(TRANS_TIME_FROM_P2)(11 downto 0);
    constant TRANS_TIME_NON_P2_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TRANS_TIME_NON_P2)(7 downto 0);
    constant TRANS_TIME_RATE_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TRANS_TIME_RATE)(7 downto 0);
    constant TRANS_TIME_TO_P2_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(TRANS_TIME_TO_P2)(9 downto 0);
    constant TST_ATTR_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(TST_ATTR)(31 downto 0);
    constant TXOUTCLK_DLY_BINARY : std_logic_vector(9 downto 0) := To_StdLogicVector(TXOUTCLK_DLY)(9 downto 0);
    constant TXPLL_COM_CFG_BINARY : std_logic_vector(23 downto 0) := To_StdLogicVector(TXPLL_COM_CFG)(23 downto 0);
    constant TXPLL_CP_CFG_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TXPLL_CP_CFG)(7 downto 0);
    constant TXPLL_LKDET_CFG_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TXPLL_LKDET_CFG)(2 downto 0);
    constant TXPLL_SATA_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(TXPLL_SATA)(1 downto 0);
    constant TX_BYTECLK_CFG_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(TX_BYTECLK_CFG)(5 downto 0);
    constant TX_DEEMPH_0_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(TX_DEEMPH_0)(4 downto 0);
    constant TX_DEEMPH_1_BINARY : std_logic_vector(4 downto 0) := To_StdLogicVector(TX_DEEMPH_1)(4 downto 0);
    constant TX_DETECT_RX_CFG_BINARY : std_logic_vector(13 downto 0) := To_StdLogicVector(TX_DETECT_RX_CFG)(13 downto 0);
    constant TX_DLYALIGN_CTRINC_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(TX_DLYALIGN_CTRINC)(3 downto 0);
    constant TX_DLYALIGN_LPFINC_BINARY : std_logic_vector(3 downto 0) := To_StdLogicVector(TX_DLYALIGN_LPFINC)(3 downto 0);
    constant TX_DLYALIGN_MONSEL_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TX_DLYALIGN_MONSEL)(2 downto 0);
    constant TX_DLYALIGN_OVRDSETTING_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(TX_DLYALIGN_OVRDSETTING)(7 downto 0);
    constant TX_IDLE_ASSERT_DELAY_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TX_IDLE_ASSERT_DELAY)(2 downto 0);
    constant TX_IDLE_DEASSERT_DELAY_BINARY : std_logic_vector(2 downto 0) := To_StdLogicVector(TX_IDLE_DEASSERT_DELAY)(2 downto 0);
    constant TX_MARGIN_FULL_0_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_FULL_0)(6 downto 0);
    constant TX_MARGIN_FULL_1_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_FULL_1)(6 downto 0);
    constant TX_MARGIN_FULL_2_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_FULL_2)(6 downto 0);
    constant TX_MARGIN_FULL_3_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_FULL_3)(6 downto 0);
    constant TX_MARGIN_FULL_4_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_FULL_4)(6 downto 0);
    constant TX_MARGIN_LOW_0_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_LOW_0)(6 downto 0);
    constant TX_MARGIN_LOW_1_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_LOW_1)(6 downto 0);
    constant TX_MARGIN_LOW_2_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_LOW_2)(6 downto 0);
    constant TX_MARGIN_LOW_3_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_LOW_3)(6 downto 0);
    constant TX_MARGIN_LOW_4_BINARY : std_logic_vector(6 downto 0) := To_StdLogicVector(TX_MARGIN_LOW_4)(6 downto 0);
    constant TX_PMADATA_OPT_BINARY : std_ulogic := To_StduLogic(TX_PMADATA_OPT);
    constant TX_TDCC_CFG_BINARY : std_logic_vector(1 downto 0) := To_StdLogicVector(TX_TDCC_CFG)(1 downto 0) ;
    constant TX_USRCLK_CFG_BINARY : std_logic_vector(5 downto 0) := To_StdLogicVector(TX_USRCLK_CFG)(5 downto 0) ;

     -- Get String Length 
    constant BIAS_CFG_STRLEN : integer := getstrlength(BIAS_CFG_BINARY);
    constant PMA_CDR_SCAN_STRLEN : integer := getstrlength(PMA_CDR_SCAN_BINARY);
    constant PMA_CFG_STRLEN : integer := getstrlength(PMA_CFG_BINARY);
    constant PMA_RXSYNC_CFG_STRLEN : integer := getstrlength(PMA_RXSYNC_CFG_BINARY);
    constant PMA_RX_CFG_STRLEN : integer := getstrlength(PMA_RX_CFG_BINARY);
    constant PMA_TX_CFG_STRLEN : integer := getstrlength(PMA_TX_CFG_BINARY);
    constant RXPLL_COM_CFG_STRLEN : integer := getstrlength(RXPLL_COM_CFG_BINARY);
    constant RXPLL_CP_CFG_STRLEN : integer := getstrlength(RXPLL_CP_CFG_BINARY);
    constant RXUSRCLK_DLY_STRLEN : integer := getstrlength(RXUSRCLK_DLY_BINARY);
    constant RX_EYE_OFFSET_STRLEN : integer := getstrlength(RX_EYE_OFFSET_BINARY);
    constant TRANS_TIME_FROM_P2_STRLEN : integer := getstrlength(TRANS_TIME_FROM_P2_BINARY);
    constant TRANS_TIME_NON_P2_STRLEN : integer := getstrlength(TRANS_TIME_NON_P2_BINARY);
    constant TRANS_TIME_RATE_STRLEN : integer := getstrlength(TRANS_TIME_RATE_BINARY);
    constant TRANS_TIME_TO_P2_STRLEN : integer := getstrlength(TRANS_TIME_TO_P2_BINARY);
    constant TST_ATTR_STRLEN : integer := getstrlength(TST_ATTR_BINARY);
    constant TXPLL_COM_CFG_STRLEN : integer := getstrlength(TXPLL_COM_CFG_BINARY);
    constant TXPLL_CP_CFG_STRLEN : integer := getstrlength(TXPLL_CP_CFG_BINARY);
    constant TX_BYTECLK_CFG_STRLEN : integer := getstrlength(TX_BYTECLK_CFG_BINARY);
    constant TX_DETECT_RX_CFG_STRLEN : integer := getstrlength(TX_DETECT_RX_CFG_BINARY);
    constant TX_USRCLK_CFG_STRLEN : integer := getstrlength(TX_USRCLK_CFG_BINARY);
      
    -- Convert std_logic_vector to string
    constant BGTEST_CFG_STRING : string := SLV_TO_STR(BGTEST_CFG_BINARY);
    constant BIAS_CFG_STRING : string := SLV_TO_HEX(BIAS_CFG_BINARY, BIAS_CFG_STRLEN);
    constant CDR_PH_ADJ_TIME_STRING : string := SLV_TO_STR(CDR_PH_ADJ_TIME_BINARY);
    constant CHAN_BOND_SEQ_1_1_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_1_1_BINARY);
    constant CHAN_BOND_SEQ_1_2_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_1_2_BINARY);
    constant CHAN_BOND_SEQ_1_3_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_1_3_BINARY);
    constant CHAN_BOND_SEQ_1_4_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_1_4_BINARY);
    constant CHAN_BOND_SEQ_1_ENABLE_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_1_ENABLE_BINARY);
    constant CHAN_BOND_SEQ_2_1_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_2_1_BINARY);
    constant CHAN_BOND_SEQ_2_2_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_2_2_BINARY);
    constant CHAN_BOND_SEQ_2_3_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_2_3_BINARY);
    constant CHAN_BOND_SEQ_2_4_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_2_4_BINARY);
    constant CHAN_BOND_SEQ_2_CFG_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_2_CFG_BINARY);
    constant CHAN_BOND_SEQ_2_ENABLE_STRING : string := SLV_TO_STR(CHAN_BOND_SEQ_2_ENABLE_BINARY);
    constant CLK_COR_SEQ_1_1_STRING : string := SLV_TO_STR(CLK_COR_SEQ_1_1_BINARY);
    constant CLK_COR_SEQ_1_2_STRING : string := SLV_TO_STR(CLK_COR_SEQ_1_2_BINARY);
    constant CLK_COR_SEQ_1_3_STRING : string := SLV_TO_STR(CLK_COR_SEQ_1_3_BINARY);
    constant CLK_COR_SEQ_1_4_STRING : string := SLV_TO_STR(CLK_COR_SEQ_1_4_BINARY);
    constant CLK_COR_SEQ_1_ENABLE_STRING : string := SLV_TO_STR(CLK_COR_SEQ_1_ENABLE_BINARY);
    constant CLK_COR_SEQ_2_1_STRING : string := SLV_TO_STR(CLK_COR_SEQ_2_1_BINARY);
    constant CLK_COR_SEQ_2_2_STRING : string := SLV_TO_STR(CLK_COR_SEQ_2_2_BINARY);
    constant CLK_COR_SEQ_2_3_STRING : string := SLV_TO_STR(CLK_COR_SEQ_2_3_BINARY);
    constant CLK_COR_SEQ_2_4_STRING : string := SLV_TO_STR(CLK_COR_SEQ_2_4_BINARY);
    constant CLK_COR_SEQ_2_ENABLE_STRING : string := SLV_TO_STR(CLK_COR_SEQ_2_ENABLE_BINARY);
    constant CM_TRIM_STRING : string := SLV_TO_STR(CM_TRIM_BINARY);
    constant COMMA_10B_ENABLE_STRING : string := SLV_TO_STR(COMMA_10B_ENABLE_BINARY);
    constant COM_BURST_VAL_STRING : string := SLV_TO_STR(COM_BURST_VAL_BINARY);
    constant DFE_CAL_TIME_STRING : string := SLV_TO_STR(DFE_CAL_TIME_BINARY);
    constant DFE_CFG_STRING : string := SLV_TO_STR(DFE_CFG_BINARY);
    constant GEARBOX_ENDEC_STRING : string := SLV_TO_STR(GEARBOX_ENDEC_BINARY);
    constant MCOMMA_10B_VALUE_STRING : string := SLV_TO_STR(MCOMMA_10B_VALUE_BINARY);
    constant OOBDETECT_THRESHOLD_STRING : string := SLV_TO_STR(OOBDETECT_THRESHOLD_BINARY);
    constant PCOMMA_10B_VALUE_STRING : string := SLV_TO_STR(PCOMMA_10B_VALUE_BINARY);
    constant PMA_CDR_SCAN_STRING : string := SLV_TO_HEX(PMA_CDR_SCAN_BINARY,PMA_CDR_SCAN_STRLEN);
    constant PMA_CFG_STRING : string := SLV_TO_HEX(PMA_CFG_BINARY,PMA_CFG_STRLEN);
    constant PMA_RXSYNC_CFG_STRING : string := SLV_TO_HEX(PMA_RXSYNC_CFG_BINARY,PMA_RXSYNC_CFG_STRLEN);
    constant PMA_RX_CFG_STRING : string := SLV_TO_HEX(PMA_RX_CFG_BINARY,PMA_RX_CFG_STRLEN);
    constant PMA_TX_CFG_STRING : string := SLV_TO_HEX(PMA_TX_CFG_BINARY,PMA_TX_CFG_STRLEN);
    constant POWER_SAVE_STRING : string := SLV_TO_STR(POWER_SAVE_BINARY);
    constant RXPLL_COM_CFG_STRING : string := SLV_TO_HEX(RXPLL_COM_CFG_BINARY,RXPLL_COM_CFG_STRLEN);
    constant RXPLL_CP_CFG_STRING : string := SLV_TO_HEX(RXPLL_CP_CFG_BINARY,RXPLL_CP_CFG_STRLEN);
    constant RXPLL_LKDET_CFG_STRING : string := SLV_TO_STR(RXPLL_LKDET_CFG_BINARY);
    constant RXPRBSERR_LOOPBACK_STRING : string := SUL_TO_STR(RXPRBSERR_LOOPBACK_BINARY);
    constant RXRECCLK_DLY_STRING : string := SLV_TO_STR(RXRECCLK_DLY_BINARY);
    constant RXUSRCLK_DLY_STRING : string := SLV_TO_HEX(RXUSRCLK_DLY_BINARY,RXUSRCLK_DLY_STRLEN);
    constant RX_DLYALIGN_CTRINC_STRING : string := SLV_TO_STR(RX_DLYALIGN_CTRINC_BINARY);
    constant RX_DLYALIGN_EDGESET_STRING : string := SLV_TO_STR(RX_DLYALIGN_EDGESET_BINARY);
    constant RX_DLYALIGN_LPFINC_STRING : string := SLV_TO_STR(RX_DLYALIGN_LPFINC_BINARY);
    constant RX_DLYALIGN_MONSEL_STRING : string := SLV_TO_STR(RX_DLYALIGN_MONSEL_BINARY);
    constant RX_DLYALIGN_OVRDSETTING_STRING : string := SLV_TO_STR(RX_DLYALIGN_OVRDSETTING_BINARY);
    constant RX_EYE_OFFSET_STRING : string := SLV_TO_HEX(RX_EYE_OFFSET_BINARY,RX_EYE_OFFSET_STRLEN);
    constant RX_EYE_SCANMODE_STRING : string := SLV_TO_STR(RX_EYE_SCANMODE_BINARY);
    constant RX_IDLE_HI_CNT_STRING : string := SLV_TO_STR(RX_IDLE_HI_CNT_BINARY);
    constant RX_IDLE_LO_CNT_STRING : string := SLV_TO_STR(RX_IDLE_LO_CNT_BINARY);
    constant SATA_BURST_VAL_STRING : string := SLV_TO_STR(SATA_BURST_VAL_BINARY);
    constant SATA_IDLE_VAL_STRING : string := SLV_TO_STR(SATA_IDLE_VAL_BINARY);
    constant SIM_RXREFCLK_SOURCE_STRING : string := SLV_TO_STR(SIM_RXREFCLK_SOURCE_BINARY);
    constant SIM_TXREFCLK_SOURCE_STRING : string := SLV_TO_STR(SIM_TXREFCLK_SOURCE_BINARY);
    constant TERMINATION_CTRL_STRING : string := SLV_TO_STR(TERMINATION_CTRL_BINARY);
    constant TRANS_TIME_FROM_P2_STRING : string := SLV_TO_HEX(TRANS_TIME_FROM_P2_BINARY,TRANS_TIME_FROM_P2_STRLEN);
    constant TRANS_TIME_NON_P2_STRING : string := SLV_TO_HEX(TRANS_TIME_NON_P2_BINARY,TRANS_TIME_NON_P2_STRLEN);
    constant TRANS_TIME_RATE_STRING : string := SLV_TO_HEX(TRANS_TIME_RATE_BINARY,TRANS_TIME_RATE_STRLEN);
    constant TRANS_TIME_TO_P2_STRING : string := SLV_TO_HEX(TRANS_TIME_TO_P2_BINARY,TRANS_TIME_TO_P2_STRLEN);
    constant TST_ATTR_STRING : string := SLV_TO_HEX(TST_ATTR_BINARY,TST_ATTR_STRLEN);
    constant TXOUTCLK_DLY_STRING : string := SLV_TO_STR(TXOUTCLK_DLY_BINARY);
    constant TXPLL_COM_CFG_STRING : string := SLV_TO_HEX(TXPLL_COM_CFG_BINARY,TXPLL_COM_CFG_STRLEN);
    constant TXPLL_CP_CFG_STRING : string := SLV_TO_HEX(TXPLL_CP_CFG_BINARY,TXPLL_CP_CFG_STRLEN);
    constant TXPLL_LKDET_CFG_STRING : string := SLV_TO_STR(TXPLL_LKDET_CFG_BINARY);
    constant TXPLL_SATA_STRING : string := SLV_TO_STR(TXPLL_SATA_BINARY);
    constant TX_BYTECLK_CFG_STRING : string := SLV_TO_HEX(TX_BYTECLK_CFG_BINARY,TX_BYTECLK_CFG_STRLEN);
    constant TX_DEEMPH_0_STRING : string := SLV_TO_STR(TX_DEEMPH_0_BINARY);
    constant TX_DEEMPH_1_STRING : string := SLV_TO_STR(TX_DEEMPH_1_BINARY);
    constant TX_DETECT_RX_CFG_STRING : string := SLV_TO_HEX(TX_DETECT_RX_CFG_BINARY, TX_DETECT_RX_CFG_STRLEN);
    constant TX_DLYALIGN_CTRINC_STRING : string := SLV_TO_STR(TX_DLYALIGN_CTRINC_BINARY);
    constant TX_DLYALIGN_LPFINC_STRING : string := SLV_TO_STR(TX_DLYALIGN_LPFINC_BINARY);
    constant TX_DLYALIGN_MONSEL_STRING : string := SLV_TO_STR(TX_DLYALIGN_MONSEL_BINARY);
    constant TX_DLYALIGN_OVRDSETTING_STRING : string := SLV_TO_STR(TX_DLYALIGN_OVRDSETTING_BINARY);
    constant TX_IDLE_ASSERT_DELAY_STRING : string := SLV_TO_STR(TX_IDLE_ASSERT_DELAY_BINARY);
    constant TX_IDLE_DEASSERT_DELAY_STRING : string := SLV_TO_STR(TX_IDLE_DEASSERT_DELAY_BINARY);
    constant TX_MARGIN_FULL_0_STRING : string := SLV_TO_STR(TX_MARGIN_FULL_0_BINARY);
    constant TX_MARGIN_FULL_1_STRING : string := SLV_TO_STR(TX_MARGIN_FULL_1_BINARY);
    constant TX_MARGIN_FULL_2_STRING : string := SLV_TO_STR(TX_MARGIN_FULL_2_BINARY);
    constant TX_MARGIN_FULL_3_STRING : string := SLV_TO_STR(TX_MARGIN_FULL_3_BINARY);
    constant TX_MARGIN_FULL_4_STRING : string := SLV_TO_STR(TX_MARGIN_FULL_4_BINARY);
    constant TX_MARGIN_LOW_0_STRING : string := SLV_TO_STR(TX_MARGIN_LOW_0_BINARY);
    constant TX_MARGIN_LOW_1_STRING : string := SLV_TO_STR(TX_MARGIN_LOW_1_BINARY);
    constant TX_MARGIN_LOW_2_STRING : string := SLV_TO_STR(TX_MARGIN_LOW_2_BINARY);
    constant TX_MARGIN_LOW_3_STRING : string := SLV_TO_STR(TX_MARGIN_LOW_3_BINARY);
    constant TX_MARGIN_LOW_4_STRING : string := SLV_TO_STR(TX_MARGIN_LOW_4_BINARY);
    constant TX_PMADATA_OPT_STRING : string := SUL_TO_STR(TX_PMADATA_OPT_BINARY);
    constant TX_TDCC_CFG_STRING : string := SLV_TO_STR(TX_TDCC_CFG_BINARY);
    constant TX_USRCLK_CFG_STRING : string := SLV_TO_HEX(TX_USRCLK_CFG_BINARY,TX_USRCLK_CFG_STRLEN);
    
    -- Convert boolean to string
    constant AC_CAP_DIS_STRING : string := boolean_to_string(AC_CAP_DIS);
    constant CHAN_BOND_KEEP_ALIGN_STRING : string := boolean_to_string(CHAN_BOND_KEEP_ALIGN);
    constant CHAN_BOND_SEQ_2_USE_STRING : string := boolean_to_string(CHAN_BOND_SEQ_2_USE);
    constant CLK_CORRECT_USE_STRING : string := boolean_to_string(CLK_CORRECT_USE);
    constant CLK_COR_INSERT_IDLE_FLAG_STRING : string := boolean_to_string(CLK_COR_INSERT_IDLE_FLAG);
    constant CLK_COR_KEEP_IDLE_STRING : string := boolean_to_string(CLK_COR_KEEP_IDLE);
    constant CLK_COR_PRECEDENCE_STRING : string := boolean_to_string(CLK_COR_PRECEDENCE);
    constant CLK_COR_SEQ_2_USE_STRING : string := boolean_to_string(CLK_COR_SEQ_2_USE);
    constant COMMA_DOUBLE_STRING : string := boolean_to_string(COMMA_DOUBLE);
    constant DEC_MCOMMA_DETECT_STRING : string := boolean_to_string(DEC_MCOMMA_DETECT);
    constant DEC_PCOMMA_DETECT_STRING : string := boolean_to_string(DEC_PCOMMA_DETECT);
    constant DEC_VALID_COMMA_ONLY_STRING : string := boolean_to_string(DEC_VALID_COMMA_ONLY);
    constant GEN_RXUSRCLK_STRING : string := boolean_to_string(GEN_RXUSRCLK);
    constant GEN_TXUSRCLK_STRING : string := boolean_to_string(GEN_TXUSRCLK);
    constant GTX_CFG_PWRUP_STRING : string := boolean_to_string(GTX_CFG_PWRUP);
    constant MCOMMA_DETECT_STRING : string := boolean_to_string(MCOMMA_DETECT);
    constant PCI_EXPRESS_MODE_STRING : string := boolean_to_string(PCI_EXPRESS_MODE);
    constant PCOMMA_DETECT_STRING : string := boolean_to_string(PCOMMA_DETECT);
    constant PMA_CAS_CLK_EN_STRING : string := boolean_to_string(PMA_CAS_CLK_EN);
    constant RCV_TERM_GND_STRING : string := boolean_to_string(RCV_TERM_GND);
    constant RCV_TERM_VTTRX_STRING : string := boolean_to_string(RCV_TERM_VTTRX);
    constant RXGEARBOX_USE_STRING : string := boolean_to_string(RXGEARBOX_USE);
    constant RX_BUFFER_USE_STRING : string := boolean_to_string(RX_BUFFER_USE);
    constant RX_DECODE_SEQ_MATCH_STRING : string := boolean_to_string(RX_DECODE_SEQ_MATCH);
    constant RX_EN_IDLE_HOLD_CDR_STRING : string := boolean_to_string(RX_EN_IDLE_HOLD_CDR);
    constant RX_EN_IDLE_HOLD_DFE_STRING : string := boolean_to_string(RX_EN_IDLE_HOLD_DFE);
    constant RX_EN_IDLE_RESET_BUF_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_BUF);
    constant RX_EN_IDLE_RESET_FR_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_FR);
    constant RX_EN_IDLE_RESET_PH_STRING : string := boolean_to_string(RX_EN_IDLE_RESET_PH);
    constant RX_EN_MODE_RESET_BUF_STRING : string := boolean_to_string(RX_EN_MODE_RESET_BUF);
    constant RX_EN_RATE_RESET_BUF_STRING : string := boolean_to_string(RX_EN_RATE_RESET_BUF);
    constant RX_EN_REALIGN_RESET_BUF2_STRING : string := boolean_to_string(RX_EN_REALIGN_RESET_BUF2);
    constant RX_EN_REALIGN_RESET_BUF_STRING : string := boolean_to_string(RX_EN_REALIGN_RESET_BUF);
    constant RX_LOSS_OF_SYNC_FSM_STRING : string := boolean_to_string(RX_LOSS_OF_SYNC_FSM);
    constant RX_OVERSAMPLE_MODE_STRING : string := boolean_to_string(RX_OVERSAMPLE_MODE);
    constant SHOW_REALIGN_COMMA_STRING : string := boolean_to_string(SHOW_REALIGN_COMMA);
    constant SIM_RECEIVER_DETECT_PASS_STRING : string := boolean_to_string(SIM_RECEIVER_DETECT_PASS);
    constant TERMINATION_OVRD_STRING : string := boolean_to_string(TERMINATION_OVRD);
    constant TXDRIVE_LOOPBACK_HIZ_STRING : string := boolean_to_string(TXDRIVE_LOOPBACK_HIZ);
    constant TXDRIVE_LOOPBACK_PD_STRING : string := boolean_to_string(TXDRIVE_LOOPBACK_PD);
    constant TXGEARBOX_USE_STRING : string := boolean_to_string(TXGEARBOX_USE);
    constant TX_BUFFER_USE_STRING : string := boolean_to_string(TX_BUFFER_USE);
    constant TX_EN_RATE_RESET_BUF_STRING : string := boolean_to_string(TX_EN_RATE_RESET_BUF);
    constant TX_OVERSAMPLE_MODE_STRING : string := boolean_to_string(TX_OVERSAMPLE_MODE);
    
    signal AC_CAP_DIS_BINARY : std_ulogic;
    signal ALIGN_COMMA_WORD_BINARY : std_ulogic;
    signal CHAN_BOND_1_MAX_SKEW_BINARY : std_logic_vector(3 downto 0);
    signal CHAN_BOND_2_MAX_SKEW_BINARY : std_logic_vector(3 downto 0);
    signal CHAN_BOND_KEEP_ALIGN_BINARY : std_ulogic;
    signal CHAN_BOND_SEQ_2_USE_BINARY : std_ulogic;
    signal CHAN_BOND_SEQ_LEN_BINARY : std_logic_vector(1 downto 0);
    signal CLK_CORRECT_USE_BINARY : std_ulogic;
    signal CLK_COR_ADJ_LEN_BINARY : std_logic_vector(1 downto 0);
    signal CLK_COR_DET_LEN_BINARY : std_logic_vector(1 downto 0);
    signal CLK_COR_INSERT_IDLE_FLAG_BINARY : std_ulogic;
    signal CLK_COR_KEEP_IDLE_BINARY : std_ulogic;
    signal CLK_COR_MAX_LAT_BINARY : std_logic_vector(5 downto 0);
    signal CLK_COR_MIN_LAT_BINARY : std_logic_vector(5 downto 0);
    signal CLK_COR_PRECEDENCE_BINARY : std_ulogic;
    signal CLK_COR_REPEAT_WAIT_BINARY : std_logic_vector(4 downto 0);
    signal CLK_COR_SEQ_2_USE_BINARY : std_ulogic;
    signal COMMA_DOUBLE_BINARY : std_ulogic;
    signal DEC_MCOMMA_DETECT_BINARY : std_ulogic;
    signal DEC_PCOMMA_DETECT_BINARY : std_ulogic;
    signal DEC_VALID_COMMA_ONLY_BINARY : std_ulogic;
    signal GEN_RXUSRCLK_BINARY : std_ulogic;
    signal GEN_TXUSRCLK_BINARY : std_ulogic;
    signal GTX_CFG_PWRUP_BINARY : std_ulogic;
    signal MCOMMA_DETECT_BINARY : std_ulogic;
    signal PCI_EXPRESS_MODE_BINARY : std_ulogic;
    signal PCOMMA_DETECT_BINARY : std_ulogic;
    signal PMA_CAS_CLK_EN_BINARY : std_ulogic;
    signal RCV_TERM_GND_BINARY : std_ulogic;
    signal RCV_TERM_VTTRX_BINARY : std_ulogic;
    signal RXGEARBOX_USE_BINARY : std_ulogic;
    signal RXPLL_DIVSEL45_FB_BINARY : std_ulogic;
    signal RXPLL_DIVSEL_FB_BINARY : std_logic_vector(4 downto 0);
    signal RXPLL_DIVSEL_OUT_BINARY : std_logic_vector(1 downto 0);
    signal RXPLL_DIVSEL_REF_BINARY : std_logic_vector(4 downto 0);
    signal RXRECCLK_CTRL_BINARY : std_logic_vector(2 downto 0);
    signal RX_BUFFER_USE_BINARY : std_ulogic;
    signal RX_CLK25_DIVIDER_BINARY : std_logic_vector(4 downto 0);
    signal RX_DATA_WIDTH_BINARY : std_logic_vector(2 downto 0);
    signal RX_DECODE_SEQ_MATCH_BINARY : std_ulogic;
    signal RX_EN_IDLE_HOLD_CDR_BINARY : std_ulogic;
    signal RX_EN_IDLE_HOLD_DFE_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_BUF_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_FR_BINARY : std_ulogic;
    signal RX_EN_IDLE_RESET_PH_BINARY : std_ulogic;
    signal RX_EN_MODE_RESET_BUF_BINARY : std_ulogic;
    signal RX_EN_RATE_RESET_BUF_BINARY : std_ulogic;
    signal RX_EN_REALIGN_RESET_BUF2_BINARY : std_ulogic;
    signal RX_EN_REALIGN_RESET_BUF_BINARY : std_ulogic;
    signal RX_FIFO_ADDR_MODE_BINARY : std_ulogic;
    signal RX_LOSS_OF_SYNC_FSM_BINARY : std_ulogic;
    signal RX_LOS_INVALID_INCR_BINARY : std_logic_vector(2 downto 0);
    signal RX_LOS_THRESHOLD_BINARY : std_logic_vector(2 downto 0);
    signal RX_OVERSAMPLE_MODE_BINARY : std_ulogic;
    signal RX_SLIDE_AUTO_WAIT_BINARY : std_logic_vector(3 downto 0);
    signal RX_SLIDE_MODE_BINARY : std_logic_vector(1 downto 0);
    signal RX_XCLK_SEL_BINARY : std_ulogic;
    signal SAS_MAX_COMSAS_BINARY : std_logic_vector(5 downto 0);
    signal SAS_MIN_COMSAS_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_BURST_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_INIT_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MAX_WAKE_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_BURST_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_INIT_BINARY : std_logic_vector(5 downto 0);
    signal SATA_MIN_WAKE_BINARY : std_logic_vector(5 downto 0);
    signal SHOW_REALIGN_COMMA_BINARY : std_ulogic;
    signal SIM_GTXRESET_SPEEDUP_BINARY : std_ulogic;
    signal SIM_RECEIVER_DETECT_PASS_BINARY : std_ulogic;
    signal SIM_TX_ELEC_IDLE_LEVEL_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    signal TERMINATION_OVRD_BINARY : std_ulogic;
    signal TXDRIVE_LOOPBACK_HIZ_BINARY : std_ulogic;
    signal TXDRIVE_LOOPBACK_PD_BINARY : std_ulogic;
    signal TXGEARBOX_USE_BINARY : std_ulogic;
    signal TXOUTCLK_CTRL_BINARY : std_logic_vector(2 downto 0);
    signal TXPLL_DIVSEL45_FB_BINARY : std_ulogic;
    signal TXPLL_DIVSEL_FB_BINARY : std_logic_vector(4 downto 0);
    signal TXPLL_DIVSEL_OUT_BINARY : std_logic_vector(1 downto 0);
    signal TXPLL_DIVSEL_REF_BINARY : std_logic_vector(4 downto 0);
    signal TX_BUFFER_USE_BINARY : std_ulogic;
    signal TX_CLK25_DIVIDER_BINARY : std_logic_vector(4 downto 0);
    signal TX_CLK_SOURCE_BINARY : std_ulogic;
    signal TX_DATA_WIDTH_BINARY : std_logic_vector(2 downto 0);
    signal TX_DRIVE_MODE_BINARY : std_ulogic;
    signal TX_EN_RATE_RESET_BUF_BINARY : std_ulogic;
    signal TX_OVERSAMPLE_MODE_BINARY : std_ulogic;
    signal TX_XCLK_SEL_BINARY : std_ulogic;
    
    signal COMFINISH_out : std_ulogic;
    signal COMINITDET_out : std_ulogic;
    signal COMSASDET_out : std_ulogic;
    signal COMWAKEDET_out : std_ulogic;
    signal DFECLKDLYADJMON_out : std_logic_vector(5 downto 0);
    signal DFEEYEDACMON_out : std_logic_vector(4 downto 0);
    signal DFESENSCAL_out : std_logic_vector(2 downto 0);
    signal DFETAP1MONITOR_out : std_logic_vector(4 downto 0);
    signal DFETAP2MONITOR_out : std_logic_vector(4 downto 0);
    signal DFETAP3MONITOR_out : std_logic_vector(3 downto 0);
    signal DFETAP4MONITOR_out : std_logic_vector(3 downto 0);
    signal DRDY_out : std_ulogic;
    signal DRPDO_out : std_logic_vector(15 downto 0);
    signal MGTREFCLKFAB_out : std_logic_vector(1 downto 0);
    signal PHYSTATUS_out : std_ulogic;
    signal RXBUFSTATUS_out : std_logic_vector(2 downto 0);
    signal RXBYTEISALIGNED_out : std_ulogic;
    signal RXBYTEREALIGN_out : std_ulogic;
    signal RXCHANBONDSEQ_out : std_ulogic;
    signal RXCHANISALIGNED_out : std_ulogic;
    signal RXCHANREALIGN_out : std_ulogic;
    signal RXCHARISCOMMA_out : std_logic_vector(3 downto 0);
    signal RXCHARISK_out : std_logic_vector(3 downto 0);
    signal RXCHBONDO_out : std_logic_vector(3 downto 0);
    signal RXCLKCORCNT_out : std_logic_vector(2 downto 0);
    signal RXCOMMADET_out : std_ulogic;
    signal RXDATAVALID_out : std_ulogic;
    signal RXDATA_out : std_logic_vector(31 downto 0);
    signal RXDISPERR_out : std_logic_vector(3 downto 0);
    signal RXDLYALIGNMONITOR_out : std_logic_vector(7 downto 0);
    signal RXELECIDLE_out : std_ulogic;
    signal RXHEADERVALID_out : std_ulogic;
    signal RXHEADER_out : std_logic_vector(2 downto 0);
    signal RXLOSSOFSYNC_out : std_logic_vector(1 downto 0);
    signal RXNOTINTABLE_out : std_logic_vector(3 downto 0);
    signal RXOVERSAMPLEERR_out : std_ulogic;
    signal RXPLLLKDET_out : std_ulogic;
    signal RXPRBSERR_out : std_ulogic;
    signal RXRATEDONE_out : std_ulogic;
    signal RXRECCLKPCS_out : std_ulogic;
    signal RXRECCLK_out : std_ulogic;
    signal RXRESETDONE_out : std_ulogic;
    signal RXRUNDISP_out : std_logic_vector(3 downto 0);
    signal RXSTARTOFSEQ_out : std_ulogic;
    signal RXSTATUS_out : std_logic_vector(2 downto 0);
    signal RXVALID_out : std_ulogic;
    signal TSTOUT_out : std_logic_vector(9 downto 0);
    signal TXBUFSTATUS_out : std_logic_vector(1 downto 0);
    signal TXDLYALIGNMONITOR_out : std_logic_vector(7 downto 0);
    signal TXGEARBOXREADY_out : std_ulogic;
    signal TXKERR_out : std_logic_vector(3 downto 0);
    signal TXN_out : std_ulogic;
    signal TXOUTCLKPCS_out : std_ulogic;
    signal TXOUTCLK_out : std_ulogic;
    signal TXPLLLKDET_out : std_ulogic;
    signal TXP_out : std_ulogic;
    signal TXRATEDONE_out : std_ulogic;
    signal TXRESETDONE_out : std_ulogic;
    signal TXRUNDISP_out : std_logic_vector(3 downto 0);
    
    signal COMFINISH_outdelay : std_ulogic;
    signal COMINITDET_outdelay : std_ulogic;
    signal COMSASDET_outdelay : std_ulogic;
    signal COMWAKEDET_outdelay : std_ulogic;
    signal DFECLKDLYADJMON_outdelay : std_logic_vector(5 downto 0);
    signal DFEEYEDACMON_outdelay : std_logic_vector(4 downto 0);
    signal DFESENSCAL_outdelay : std_logic_vector(2 downto 0);
    signal DFETAP1MONITOR_outdelay : std_logic_vector(4 downto 0);
    signal DFETAP2MONITOR_outdelay : std_logic_vector(4 downto 0);
    signal DFETAP3MONITOR_outdelay : std_logic_vector(3 downto 0);
    signal DFETAP4MONITOR_outdelay : std_logic_vector(3 downto 0);
    signal DRDY_outdelay : std_ulogic;
    signal DRPDO_outdelay : std_logic_vector(15 downto 0);
    signal MGTREFCLKFAB_outdelay : std_logic_vector(1 downto 0);
    signal PHYSTATUS_outdelay : std_ulogic;
    signal RXBUFSTATUS_outdelay : std_logic_vector(2 downto 0);
    signal RXBYTEISALIGNED_outdelay : std_ulogic;
    signal RXBYTEREALIGN_outdelay : std_ulogic;
    signal RXCHANBONDSEQ_outdelay : std_ulogic;
    signal RXCHANISALIGNED_outdelay : std_ulogic;
    signal RXCHANREALIGN_outdelay : std_ulogic;
    signal RXCHARISCOMMA_outdelay : std_logic_vector(3 downto 0);
    signal RXCHARISK_outdelay : std_logic_vector(3 downto 0);
    signal RXCHBONDO_outdelay : std_logic_vector(3 downto 0);
    signal RXCLKCORCNT_outdelay : std_logic_vector(2 downto 0);
    signal RXCOMMADET_outdelay : std_ulogic;
    signal RXDATAVALID_outdelay : std_ulogic;
    signal RXDATA_outdelay : std_logic_vector(31 downto 0);
    signal RXDISPERR_outdelay : std_logic_vector(3 downto 0);
    signal RXDLYALIGNMONITOR_outdelay : std_logic_vector(7 downto 0);
    signal RXELECIDLE_outdelay : std_ulogic;
    signal RXHEADERVALID_outdelay : std_ulogic;
    signal RXHEADER_outdelay : std_logic_vector(2 downto 0);
    signal RXLOSSOFSYNC_outdelay : std_logic_vector(1 downto 0);
    signal RXNOTINTABLE_outdelay : std_logic_vector(3 downto 0);
    signal RXOVERSAMPLEERR_outdelay : std_ulogic;
    signal RXPLLLKDET_outdelay : std_ulogic;
    signal RXPRBSERR_outdelay : std_ulogic;
    signal RXRATEDONE_outdelay : std_ulogic;
    signal RXRECCLKPCS_outdelay : std_ulogic;
    signal RXRECCLK_outdelay : std_ulogic;
    signal RXRESETDONE_outdelay : std_ulogic;
    signal RXRUNDISP_outdelay : std_logic_vector(3 downto 0);
    signal RXSTARTOFSEQ_outdelay : std_ulogic;
    signal RXSTATUS_outdelay : std_logic_vector(2 downto 0);
    signal RXVALID_outdelay : std_ulogic;
    signal TSTOUT_outdelay : std_logic_vector(9 downto 0);
    signal TXBUFSTATUS_outdelay : std_logic_vector(1 downto 0);
    signal TXDLYALIGNMONITOR_outdelay : std_logic_vector(7 downto 0);
    signal TXGEARBOXREADY_outdelay : std_ulogic;
    signal TXKERR_outdelay : std_logic_vector(3 downto 0);
    signal TXN_outdelay : std_ulogic;
    signal TXOUTCLKPCS_outdelay : std_ulogic;
    signal TXOUTCLK_outdelay : std_ulogic;
    signal TXPLLLKDET_outdelay : std_ulogic;
    signal TXP_outdelay : std_ulogic;
    signal TXRATEDONE_outdelay : std_ulogic;
    signal TXRESETDONE_outdelay : std_ulogic;
    signal TXRUNDISP_outdelay : std_logic_vector(3 downto 0);
    
    signal DADDR_ipd : std_logic_vector(7 downto 0);
    signal DCLK_ipd : std_ulogic;
    signal DEN_ipd : std_ulogic;
    signal DFECLKDLYADJ_ipd : std_logic_vector(5 downto 0);
    signal DFEDLYOVRD_ipd : std_ulogic;
    signal DFETAP1_ipd : std_logic_vector(4 downto 0);
    signal DFETAP2_ipd : std_logic_vector(4 downto 0);
    signal DFETAP3_ipd : std_logic_vector(3 downto 0);
    signal DFETAP4_ipd : std_logic_vector(3 downto 0);
    signal DFETAPOVRD_ipd : std_ulogic;
    signal DI_ipd : std_logic_vector(15 downto 0);
    signal DWE_ipd : std_ulogic;
    signal GATERXELECIDLE_ipd : std_ulogic;
    signal GREFCLKRX_ipd : std_ulogic;
    signal GREFCLKTX_ipd : std_ulogic;
    signal GTXRXRESET_ipd : std_ulogic;
    signal GTXTEST_ipd : std_logic_vector(12 downto 0);
    signal GTXTXRESET_ipd : std_ulogic;
    signal IGNORESIGDET_ipd : std_ulogic;
    signal LOOPBACK_ipd : std_logic_vector(2 downto 0);
    signal MGTREFCLKRX_ipd : std_logic_vector(1 downto 0);
    signal MGTREFCLKTX_ipd : std_logic_vector(1 downto 0);
    signal NORTHREFCLKRX_ipd : std_logic_vector(1 downto 0);
    signal NORTHREFCLKTX_ipd : std_logic_vector(1 downto 0);
    signal PERFCLKRX_ipd : std_ulogic;
    signal PERFCLKTX_ipd : std_ulogic;
    signal PLLRXRESET_ipd : std_ulogic;
    signal PLLTXRESET_ipd : std_ulogic;
    signal PRBSCNTRESET_ipd : std_ulogic;
    signal RXBUFRESET_ipd : std_ulogic;
    signal RXCDRRESET_ipd : std_ulogic;
    signal RXCHBONDI_ipd : std_logic_vector(3 downto 0);
    signal RXCHBONDLEVEL_ipd : std_logic_vector(2 downto 0);
    signal RXCHBONDMASTER_ipd : std_ulogic;
    signal RXCHBONDSLAVE_ipd : std_ulogic;
    signal RXCOMMADETUSE_ipd : std_ulogic;
    signal RXDEC8B10BUSE_ipd : std_ulogic;
    signal RXDLYALIGNDISABLE_ipd : std_ulogic;
    signal RXDLYALIGNMONENB_ipd : std_ulogic;
    signal RXDLYALIGNOVERRIDE_ipd : std_ulogic;
    signal RXDLYALIGNRESET_ipd : std_ulogic;
    signal RXDLYALIGNSWPPRECURB_ipd : std_ulogic;
    signal RXDLYALIGNUPDSW_ipd : std_ulogic;
    signal RXENCHANSYNC_ipd : std_ulogic;
    signal RXENMCOMMAALIGN_ipd : std_ulogic;
    signal RXENPCOMMAALIGN_ipd : std_ulogic;
    signal RXENPMAPHASEALIGN_ipd : std_ulogic;
    signal RXENPRBSTST_ipd : std_logic_vector(2 downto 0);
    signal RXENSAMPLEALIGN_ipd : std_ulogic;
    signal RXEQMIX_ipd : std_logic_vector(9 downto 0);
    signal RXGEARBOXSLIP_ipd : std_ulogic;
    signal RXN_ipd : std_ulogic;
    signal RXPLLLKDETEN_ipd : std_ulogic;
    signal RXPLLPOWERDOWN_ipd : std_ulogic;
    signal RXPLLREFSELDY_ipd : std_logic_vector(2 downto 0);
    signal RXPMASETPHASE_ipd : std_ulogic;
    signal RXPOLARITY_ipd : std_ulogic;
    signal RXPOWERDOWN_ipd : std_logic_vector(1 downto 0);
    signal RXP_ipd : std_ulogic;
    signal RXRATE_ipd : std_logic_vector(1 downto 0);
    signal RXRESET_ipd : std_ulogic;
    signal RXSLIDE_ipd : std_ulogic;
    signal RXUSRCLK2_ipd : std_ulogic;
    signal RXUSRCLK_ipd : std_ulogic;
    signal SOUTHREFCLKRX_ipd : std_logic_vector(1 downto 0);
    signal SOUTHREFCLKTX_ipd : std_logic_vector(1 downto 0);
    signal TSTCLK0_ipd : std_ulogic;
    signal TSTCLK1_ipd : std_ulogic;
    signal TSTIN_ipd : std_logic_vector(19 downto 0);
    signal TXBUFDIFFCTRL_ipd : std_logic_vector(2 downto 0);
    signal TXBYPASS8B10B_ipd : std_logic_vector(3 downto 0);
    signal TXCHARDISPMODE_ipd : std_logic_vector(3 downto 0);
    signal TXCHARDISPVAL_ipd : std_logic_vector(3 downto 0);
    signal TXCHARISK_ipd : std_logic_vector(3 downto 0);
    signal TXCOMINIT_ipd : std_ulogic;
    signal TXCOMSAS_ipd : std_ulogic;
    signal TXCOMWAKE_ipd : std_ulogic;
    signal TXDATA_ipd : std_logic_vector(31 downto 0);
    signal TXDEEMPH_ipd : std_ulogic;
    signal TXDETECTRX_ipd : std_ulogic;
    signal TXDIFFCTRL_ipd : std_logic_vector(3 downto 0);
    signal TXDLYALIGNDISABLE_ipd : std_ulogic;
    signal TXDLYALIGNMONENB_ipd : std_ulogic;
    signal TXDLYALIGNOVERRIDE_ipd : std_ulogic;
    signal TXDLYALIGNRESET_ipd : std_ulogic;
    signal TXDLYALIGNUPDSW_ipd : std_ulogic;
    signal TXELECIDLE_ipd : std_ulogic;
    signal TXENC8B10BUSE_ipd : std_ulogic;
    signal TXENPMAPHASEALIGN_ipd : std_ulogic;
    signal TXENPRBSTST_ipd : std_logic_vector(2 downto 0);
    signal TXHEADER_ipd : std_logic_vector(2 downto 0);
    signal TXINHIBIT_ipd : std_ulogic;
    signal TXMARGIN_ipd : std_logic_vector(2 downto 0);
    signal TXPDOWNASYNCH_ipd : std_ulogic;
    signal TXPLLLKDETEN_ipd : std_ulogic;
    signal TXPLLPOWERDOWN_ipd : std_ulogic;
    signal TXPLLREFSELDY_ipd : std_logic_vector(2 downto 0);
    signal TXPMASETPHASE_ipd : std_ulogic;
    signal TXPOLARITY_ipd : std_ulogic;
    signal TXPOSTEMPHASIS_ipd : std_logic_vector(4 downto 0);
    signal TXPOWERDOWN_ipd : std_logic_vector(1 downto 0);
    signal TXPRBSFORCEERR_ipd : std_ulogic;
    signal TXPREEMPHASIS_ipd : std_logic_vector(3 downto 0);
    signal TXRATE_ipd : std_logic_vector(1 downto 0);
    signal TXRESET_ipd : std_ulogic;
    signal TXSEQUENCE_ipd : std_logic_vector(6 downto 0);
    signal TXSTARTSEQ_ipd : std_ulogic;
    signal TXSWING_ipd : std_ulogic;
    signal TXUSRCLK2_ipd : std_ulogic;
    signal TXUSRCLK_ipd : std_ulogic;
    signal USRCODEERR_ipd : std_ulogic;
    
    signal DADDR_indelay : std_logic_vector(7 downto 0);
    signal DCLK_indelay : std_ulogic;
    signal DEN_indelay : std_ulogic;
    signal DFECLKDLYADJ_indelay : std_logic_vector(5 downto 0);
    signal DFEDLYOVRD_indelay : std_ulogic;
    signal DFETAP1_indelay : std_logic_vector(4 downto 0);
    signal DFETAP2_indelay : std_logic_vector(4 downto 0);
    signal DFETAP3_indelay : std_logic_vector(3 downto 0);
    signal DFETAP4_indelay : std_logic_vector(3 downto 0);
    signal DFETAPOVRD_indelay : std_ulogic;
    signal DI_indelay : std_logic_vector(15 downto 0);
    signal DWE_indelay : std_ulogic;
    signal GATERXELECIDLE_indelay : std_ulogic;
    signal GREFCLKRX_indelay : std_ulogic;
    signal GREFCLKTX_indelay : std_ulogic;
    signal GTXRXRESET_indelay : std_ulogic;
    signal GTXTEST_indelay : std_logic_vector(12 downto 0);
    signal GTXTXRESET_indelay : std_ulogic;
    signal IGNORESIGDET_indelay : std_ulogic;
    signal LOOPBACK_indelay : std_logic_vector(2 downto 0);
    signal MGTREFCLKRX_indelay : std_logic_vector(1 downto 0);
    signal MGTREFCLKTX_indelay : std_logic_vector(1 downto 0);
    signal NORTHREFCLKRX_indelay : std_logic_vector(1 downto 0);
    signal NORTHREFCLKTX_indelay : std_logic_vector(1 downto 0);
    signal PERFCLKRX_indelay : std_ulogic;
    signal PERFCLKTX_indelay : std_ulogic;
    signal PLLRXRESET_indelay : std_ulogic;
    signal PLLTXRESET_indelay : std_ulogic;
    signal PRBSCNTRESET_indelay : std_ulogic;
    signal RXBUFRESET_indelay : std_ulogic;
    signal RXCDRRESET_indelay : std_ulogic;
    signal RXCHBONDI_indelay : std_logic_vector(3 downto 0);
    signal RXCHBONDLEVEL_indelay : std_logic_vector(2 downto 0);
    signal RXCHBONDMASTER_indelay : std_ulogic;
    signal RXCHBONDSLAVE_indelay : std_ulogic;
    signal RXCOMMADETUSE_indelay : std_ulogic;
    signal RXDEC8B10BUSE_indelay : std_ulogic;
    signal RXDLYALIGNDISABLE_indelay : std_ulogic;
    signal RXDLYALIGNMONENB_indelay : std_ulogic;
    signal RXDLYALIGNOVERRIDE_indelay : std_ulogic;
    signal RXDLYALIGNRESET_indelay : std_ulogic;
    signal RXDLYALIGNSWPPRECURB_indelay : std_ulogic;
    signal RXDLYALIGNUPDSW_indelay : std_ulogic;
    signal RXENCHANSYNC_indelay : std_ulogic;
    signal RXENMCOMMAALIGN_indelay : std_ulogic;
    signal RXENPCOMMAALIGN_indelay : std_ulogic;
    signal RXENPMAPHASEALIGN_indelay : std_ulogic;
    signal RXENPRBSTST_indelay : std_logic_vector(2 downto 0);
    signal RXENSAMPLEALIGN_indelay : std_ulogic;
    signal RXEQMIX_indelay : std_logic_vector(9 downto 0);
    signal RXGEARBOXSLIP_indelay : std_ulogic;
    signal RXN_indelay : std_ulogic;
    signal RXPLLLKDETEN_indelay : std_ulogic;
    signal RXPLLPOWERDOWN_indelay : std_ulogic;
    signal RXPLLREFSELDY_indelay : std_logic_vector(2 downto 0);
    signal RXPMASETPHASE_indelay : std_ulogic;
    signal RXPOLARITY_indelay : std_ulogic;
    signal RXPOWERDOWN_indelay : std_logic_vector(1 downto 0);
    signal RXP_indelay : std_ulogic;
    signal RXRATE_indelay : std_logic_vector(1 downto 0);
    signal RXRESET_indelay : std_ulogic;
    signal RXSLIDE_indelay : std_ulogic;
    signal RXUSRCLK2_indelay : std_ulogic;
    signal RXUSRCLK_indelay : std_ulogic;
    signal SOUTHREFCLKRX_indelay : std_logic_vector(1 downto 0);
    signal SOUTHREFCLKTX_indelay : std_logic_vector(1 downto 0);
    signal TSTCLK0_indelay : std_ulogic;
    signal TSTCLK1_indelay : std_ulogic;
    signal TSTIN_indelay : std_logic_vector(19 downto 0);
    signal TXBUFDIFFCTRL_indelay : std_logic_vector(2 downto 0);
    signal TXBYPASS8B10B_indelay : std_logic_vector(3 downto 0);
    signal TXCHARDISPMODE_indelay : std_logic_vector(3 downto 0);
    signal TXCHARDISPVAL_indelay : std_logic_vector(3 downto 0);
    signal TXCHARISK_indelay : std_logic_vector(3 downto 0);
    signal TXCOMINIT_indelay : std_ulogic;
    signal TXCOMSAS_indelay : std_ulogic;
    signal TXCOMWAKE_indelay : std_ulogic;
    signal TXDATA_indelay : std_logic_vector(31 downto 0);
    signal TXDEEMPH_indelay : std_ulogic;
    signal TXDETECTRX_indelay : std_ulogic;
    signal TXDIFFCTRL_indelay : std_logic_vector(3 downto 0);
    signal TXDLYALIGNDISABLE_indelay : std_ulogic;
    signal TXDLYALIGNMONENB_indelay : std_ulogic;
    signal TXDLYALIGNOVERRIDE_indelay : std_ulogic;
    signal TXDLYALIGNRESET_indelay : std_ulogic;
    signal TXDLYALIGNUPDSW_indelay : std_ulogic;
    signal TXELECIDLE_indelay : std_ulogic;
    signal TXENC8B10BUSE_indelay : std_ulogic;
    signal TXENPMAPHASEALIGN_indelay : std_ulogic;
    signal TXENPRBSTST_indelay : std_logic_vector(2 downto 0);
    signal TXHEADER_indelay : std_logic_vector(2 downto 0);
    signal TXINHIBIT_indelay : std_ulogic;
    signal TXMARGIN_indelay : std_logic_vector(2 downto 0);
    signal TXPDOWNASYNCH_indelay : std_ulogic;
    signal TXPLLLKDETEN_indelay : std_ulogic;
    signal TXPLLPOWERDOWN_indelay : std_ulogic;
    signal TXPLLREFSELDY_indelay : std_logic_vector(2 downto 0);
    signal TXPMASETPHASE_indelay : std_ulogic;
    signal TXPOLARITY_indelay : std_ulogic;
    signal TXPOSTEMPHASIS_indelay : std_logic_vector(4 downto 0);
    signal TXPOWERDOWN_indelay : std_logic_vector(1 downto 0);
    signal TXPRBSFORCEERR_indelay : std_ulogic;
    signal TXPREEMPHASIS_indelay : std_logic_vector(3 downto 0);
    signal TXRATE_indelay : std_logic_vector(1 downto 0);
    signal TXRESET_indelay : std_ulogic;
    signal TXSEQUENCE_indelay : std_logic_vector(6 downto 0);
    signal TXSTARTSEQ_indelay : std_ulogic;
    signal TXSWING_indelay : std_ulogic;
    signal TXUSRCLK2_indelay : std_ulogic;
    signal TXUSRCLK_indelay : std_ulogic;
    signal USRCODEERR_indelay : std_ulogic;
    
    begin
    MGTREFCLKFAB_out <= MGTREFCLKFAB_outdelay after OUTCLK_DELAY;
    RXRECCLKPCS_out <= RXRECCLKPCS_outdelay after OUTCLK_DELAY;
    RXRECCLK_out <= RXRECCLK_outdelay after OUTCLK_DELAY;
    TXOUTCLKPCS_out <= TXOUTCLKPCS_outdelay after OUTCLK_DELAY;
    TXOUTCLK_out <= TXOUTCLK_outdelay after OUTCLK_DELAY;
    
    COMFINISH_out <= COMFINISH_outdelay after OUT_DELAY;
    COMINITDET_out <= COMINITDET_outdelay after OUT_DELAY;
    COMSASDET_out <= COMSASDET_outdelay after OUT_DELAY;
    COMWAKEDET_out <= COMWAKEDET_outdelay after OUT_DELAY;
    DFECLKDLYADJMON_out <= DFECLKDLYADJMON_outdelay after OUT_DELAY;
    DFEEYEDACMON_out <= DFEEYEDACMON_outdelay after OUT_DELAY;
    DFESENSCAL_out <= DFESENSCAL_outdelay after OUT_DELAY;
    DFETAP1MONITOR_out <= DFETAP1MONITOR_outdelay after OUT_DELAY;
    DFETAP2MONITOR_out <= DFETAP2MONITOR_outdelay after OUT_DELAY;
    DFETAP3MONITOR_out <= DFETAP3MONITOR_outdelay after OUT_DELAY;
    DFETAP4MONITOR_out <= DFETAP4MONITOR_outdelay after OUT_DELAY;
    DRDY_out <= DRDY_outdelay after OUT_DELAY;
    DRPDO_out <= DRPDO_outdelay after OUT_DELAY;
    PHYSTATUS_out <= PHYSTATUS_outdelay after OUT_DELAY;
    RXBUFSTATUS_out <= RXBUFSTATUS_outdelay after OUT_DELAY;
    RXBYTEISALIGNED_out <= RXBYTEISALIGNED_outdelay after OUT_DELAY;
    RXBYTEREALIGN_out <= RXBYTEREALIGN_outdelay after OUT_DELAY;
    RXCHANBONDSEQ_out <= RXCHANBONDSEQ_outdelay after OUT_DELAY;
    RXCHANISALIGNED_out <= RXCHANISALIGNED_outdelay after OUT_DELAY;
    RXCHANREALIGN_out <= RXCHANREALIGN_outdelay after OUT_DELAY;
    RXCHARISCOMMA_out <= RXCHARISCOMMA_outdelay after OUT_DELAY;
    RXCHARISK_out <= RXCHARISK_outdelay after OUT_DELAY;
    RXCHBONDO_out <= RXCHBONDO_outdelay after OUT_DELAY;
    RXCLKCORCNT_out <= RXCLKCORCNT_outdelay after OUT_DELAY;
    RXCOMMADET_out <= RXCOMMADET_outdelay after OUT_DELAY;
    RXDATAVALID_out <= RXDATAVALID_outdelay after OUT_DELAY;
    RXDATA_out <= RXDATA_outdelay after OUT_DELAY;
    RXDISPERR_out <= RXDISPERR_outdelay after OUT_DELAY;
    RXDLYALIGNMONITOR_out <= RXDLYALIGNMONITOR_outdelay after OUT_DELAY;
    RXELECIDLE_out <= RXELECIDLE_outdelay after OUT_DELAY;
    RXHEADERVALID_out <= RXHEADERVALID_outdelay after OUT_DELAY;
    RXHEADER_out <= RXHEADER_outdelay after OUT_DELAY;
    RXLOSSOFSYNC_out <= RXLOSSOFSYNC_outdelay after OUT_DELAY;
    RXNOTINTABLE_out <= RXNOTINTABLE_outdelay after OUT_DELAY;
    RXOVERSAMPLEERR_out <= RXOVERSAMPLEERR_outdelay after OUT_DELAY;
    RXPLLLKDET_out <= RXPLLLKDET_outdelay after OUT_DELAY;
    RXPRBSERR_out <= RXPRBSERR_outdelay after OUT_DELAY;
    RXRATEDONE_out <= RXRATEDONE_outdelay after OUT_DELAY;
    RXRESETDONE_out <= RXRESETDONE_outdelay after OUT_DELAY;
    RXRUNDISP_out <= RXRUNDISP_outdelay after OUT_DELAY;
    RXSTARTOFSEQ_out <= RXSTARTOFSEQ_outdelay after OUT_DELAY;
    RXSTATUS_out <= RXSTATUS_outdelay after OUT_DELAY;
    RXVALID_out <= RXVALID_outdelay after OUT_DELAY;
    TSTOUT_out <= TSTOUT_outdelay after OUT_DELAY;
    TXBUFSTATUS_out <= TXBUFSTATUS_outdelay after OUT_DELAY;
    TXDLYALIGNMONITOR_out <= TXDLYALIGNMONITOR_outdelay after OUT_DELAY;
    TXGEARBOXREADY_out <= TXGEARBOXREADY_outdelay after OUT_DELAY;
    TXKERR_out <= TXKERR_outdelay after OUT_DELAY;
    TXN_out <= TXN_outdelay after OUT_DELAY;
    TXPLLLKDET_out <= TXPLLLKDET_outdelay after OUT_DELAY;
    TXP_out <= TXP_outdelay after OUT_DELAY;
    TXRATEDONE_out <= TXRATEDONE_outdelay after OUT_DELAY;
    TXRESETDONE_out <= TXRESETDONE_outdelay after OUT_DELAY;
    TXRUNDISP_out <= TXRUNDISP_outdelay after OUT_DELAY;
    
    DCLK_ipd <= DCLK;
    GREFCLKRX_ipd <= GREFCLKRX;
    GREFCLKTX_ipd <= GREFCLKTX;
    MGTREFCLKRX_ipd <= MGTREFCLKRX;
    MGTREFCLKTX_ipd <= MGTREFCLKTX;
    NORTHREFCLKRX_ipd <= NORTHREFCLKRX;
    NORTHREFCLKTX_ipd <= NORTHREFCLKTX;
    PERFCLKRX_ipd <= PERFCLKRX;
    PERFCLKTX_ipd <= PERFCLKTX;
    RXUSRCLK2_ipd <= RXUSRCLK2;
    RXUSRCLK_ipd <= RXUSRCLK;
    SOUTHREFCLKRX_ipd <= SOUTHREFCLKRX;
    SOUTHREFCLKTX_ipd <= SOUTHREFCLKTX;
    TSTCLK0_ipd <= TSTCLK0;
    TSTCLK1_ipd <= TSTCLK1;
    TXUSRCLK2_ipd <= TXUSRCLK2;
    TXUSRCLK_ipd <= TXUSRCLK;
    
    DADDR_ipd <= DADDR;
    DEN_ipd <= DEN;
    DFECLKDLYADJ_ipd <= DFECLKDLYADJ;
    DFEDLYOVRD_ipd <= DFEDLYOVRD;
    DFETAP1_ipd <= DFETAP1;
    DFETAP2_ipd <= DFETAP2;
    DFETAP3_ipd <= DFETAP3;
    DFETAP4_ipd <= DFETAP4;
    DFETAPOVRD_ipd <= DFETAPOVRD;
    DI_ipd <= DI;
    DWE_ipd <= DWE;
    GATERXELECIDLE_ipd <= GATERXELECIDLE;
    GTXRXRESET_ipd <= GTXRXRESET;
    GTXTEST_ipd <= GTXTEST;
    GTXTXRESET_ipd <= GTXTXRESET;
    IGNORESIGDET_ipd <= IGNORESIGDET;
    LOOPBACK_ipd <= LOOPBACK;
    PLLRXRESET_ipd <= PLLRXRESET;
    PLLTXRESET_ipd <= PLLTXRESET;
    PRBSCNTRESET_ipd <= PRBSCNTRESET;
    RXBUFRESET_ipd <= RXBUFRESET;
    RXCDRRESET_ipd <= RXCDRRESET;
    RXCHBONDI_ipd <= RXCHBONDI;
    RXCHBONDLEVEL_ipd <= RXCHBONDLEVEL;
    RXCHBONDMASTER_ipd <= RXCHBONDMASTER;
    RXCHBONDSLAVE_ipd <= RXCHBONDSLAVE;
    RXCOMMADETUSE_ipd <= RXCOMMADETUSE;
    RXDEC8B10BUSE_ipd <= RXDEC8B10BUSE;
    RXDLYALIGNDISABLE_ipd <= RXDLYALIGNDISABLE;
    RXDLYALIGNMONENB_ipd <= RXDLYALIGNMONENB;
    RXDLYALIGNOVERRIDE_ipd <= RXDLYALIGNOVERRIDE;
    RXDLYALIGNRESET_ipd <= RXDLYALIGNRESET;
    RXDLYALIGNSWPPRECURB_ipd <= RXDLYALIGNSWPPRECURB;
    RXDLYALIGNUPDSW_ipd <= RXDLYALIGNUPDSW;
    RXENCHANSYNC_ipd <= RXENCHANSYNC;
    RXENMCOMMAALIGN_ipd <= RXENMCOMMAALIGN;
    RXENPCOMMAALIGN_ipd <= RXENPCOMMAALIGN;
    RXENPMAPHASEALIGN_ipd <= RXENPMAPHASEALIGN;
    RXENPRBSTST_ipd <= RXENPRBSTST;
    RXENSAMPLEALIGN_ipd <= RXENSAMPLEALIGN;
    RXEQMIX_ipd <= RXEQMIX;
    RXGEARBOXSLIP_ipd <= RXGEARBOXSLIP;
    RXN_ipd <= RXN;
    RXPLLLKDETEN_ipd <= RXPLLLKDETEN;
    RXPLLPOWERDOWN_ipd <= RXPLLPOWERDOWN;
    RXPLLREFSELDY_ipd <= RXPLLREFSELDY;
    RXPMASETPHASE_ipd <= RXPMASETPHASE;
    RXPOLARITY_ipd <= RXPOLARITY;
    RXPOWERDOWN_ipd <= RXPOWERDOWN;
    RXP_ipd <= RXP;
    RXRATE_ipd <= RXRATE;
    RXRESET_ipd <= RXRESET;
    RXSLIDE_ipd <= RXSLIDE;
    TSTIN_ipd <= TSTIN;
    TXBUFDIFFCTRL_ipd <= TXBUFDIFFCTRL;
    TXBYPASS8B10B_ipd <= TXBYPASS8B10B;
    TXCHARDISPMODE_ipd <= TXCHARDISPMODE;
    TXCHARDISPVAL_ipd <= TXCHARDISPVAL;
    TXCHARISK_ipd <= TXCHARISK;
    TXCOMINIT_ipd <= TXCOMINIT;
    TXCOMSAS_ipd <= TXCOMSAS;
    TXCOMWAKE_ipd <= TXCOMWAKE;
    TXDATA_ipd <= TXDATA;
    TXDEEMPH_ipd <= TXDEEMPH;
    TXDETECTRX_ipd <= TXDETECTRX;
    TXDIFFCTRL_ipd <= TXDIFFCTRL;
    TXDLYALIGNDISABLE_ipd <= TXDLYALIGNDISABLE;
    TXDLYALIGNMONENB_ipd <= TXDLYALIGNMONENB;
    TXDLYALIGNOVERRIDE_ipd <= TXDLYALIGNOVERRIDE;
    TXDLYALIGNRESET_ipd <= TXDLYALIGNRESET;
    TXDLYALIGNUPDSW_ipd <= TXDLYALIGNUPDSW;
    TXELECIDLE_ipd <= TXELECIDLE;
    TXENC8B10BUSE_ipd <= TXENC8B10BUSE;
    TXENPMAPHASEALIGN_ipd <= TXENPMAPHASEALIGN;
    TXENPRBSTST_ipd <= TXENPRBSTST;
    TXHEADER_ipd <= TXHEADER;
    TXINHIBIT_ipd <= TXINHIBIT;
    TXMARGIN_ipd <= TXMARGIN;
    TXPDOWNASYNCH_ipd <= TXPDOWNASYNCH;
    TXPLLLKDETEN_ipd <= TXPLLLKDETEN;
    TXPLLPOWERDOWN_ipd <= TXPLLPOWERDOWN;
    TXPLLREFSELDY_ipd <= TXPLLREFSELDY;
    TXPMASETPHASE_ipd <= TXPMASETPHASE;
    TXPOLARITY_ipd <= TXPOLARITY;
    TXPOSTEMPHASIS_ipd <= TXPOSTEMPHASIS;
    TXPOWERDOWN_ipd <= TXPOWERDOWN;
    TXPRBSFORCEERR_ipd <= TXPRBSFORCEERR;
    TXPREEMPHASIS_ipd <= TXPREEMPHASIS;
    TXRATE_ipd <= TXRATE;
    TXRESET_ipd <= TXRESET;
    TXSEQUENCE_ipd <= TXSEQUENCE;
    TXSTARTSEQ_ipd <= TXSTARTSEQ;
    TXSWING_ipd <= TXSWING;
    USRCODEERR_ipd <= USRCODEERR;
    
    DCLK_indelay <= DCLK_ipd after INCLK_DELAY;
    GREFCLKRX_indelay <= GREFCLKRX_ipd after INCLK_DELAY;
    GREFCLKTX_indelay <= GREFCLKTX_ipd after INCLK_DELAY;
    MGTREFCLKRX_indelay <= MGTREFCLKRX_ipd after INCLK_DELAY;
    MGTREFCLKTX_indelay <= MGTREFCLKTX_ipd after INCLK_DELAY;
    NORTHREFCLKRX_indelay <= NORTHREFCLKRX_ipd after INCLK_DELAY;
    NORTHREFCLKTX_indelay <= NORTHREFCLKTX_ipd after INCLK_DELAY;
    PERFCLKRX_indelay <= PERFCLKRX_ipd after INCLK_DELAY;
    PERFCLKTX_indelay <= PERFCLKTX_ipd after INCLK_DELAY;
    RXUSRCLK2_indelay <= RXUSRCLK2_ipd after INCLK_DELAY;
    RXUSRCLK_indelay <= RXUSRCLK_ipd after INCLK_DELAY;
    SOUTHREFCLKRX_indelay <= SOUTHREFCLKRX_ipd after INCLK_DELAY;
    SOUTHREFCLKTX_indelay <= SOUTHREFCLKTX_ipd after INCLK_DELAY;
    TSTCLK0_indelay <= TSTCLK0_ipd after INCLK_DELAY;
    TSTCLK1_indelay <= TSTCLK1_ipd after INCLK_DELAY;
    TXUSRCLK2_indelay <= TXUSRCLK2_ipd after INCLK_DELAY;
    TXUSRCLK_indelay <= TXUSRCLK_ipd after INCLK_DELAY;
    
    DADDR_indelay <= DADDR_ipd after IN_DELAY;
    DEN_indelay <= DEN_ipd after IN_DELAY;
    DFECLKDLYADJ_indelay <= DFECLKDLYADJ_ipd after IN_DELAY;
    DFEDLYOVRD_indelay <= DFEDLYOVRD_ipd after IN_DELAY;
    DFETAP1_indelay <= DFETAP1_ipd after IN_DELAY;
    DFETAP2_indelay <= DFETAP2_ipd after IN_DELAY;
    DFETAP3_indelay <= DFETAP3_ipd after IN_DELAY;
    DFETAP4_indelay <= DFETAP4_ipd after IN_DELAY;
    DFETAPOVRD_indelay <= DFETAPOVRD_ipd after IN_DELAY;
    DI_indelay <= DI_ipd after IN_DELAY;
    DWE_indelay <= DWE_ipd after IN_DELAY;
    GATERXELECIDLE_indelay <= GATERXELECIDLE_ipd after IN_DELAY;
    GTXRXRESET_indelay <= GTXRXRESET_ipd after IN_DELAY;
    GTXTEST_indelay <= GTXTEST_ipd after IN_DELAY;
    GTXTXRESET_indelay <= GTXTXRESET_ipd after IN_DELAY;
    IGNORESIGDET_indelay <= IGNORESIGDET_ipd after IN_DELAY;
    LOOPBACK_indelay <= LOOPBACK_ipd after IN_DELAY;
    PLLRXRESET_indelay <= PLLRXRESET_ipd after IN_DELAY;
    PLLTXRESET_indelay <= PLLTXRESET_ipd after IN_DELAY;
    PRBSCNTRESET_indelay <= PRBSCNTRESET_ipd after IN_DELAY;
    RXBUFRESET_indelay <= RXBUFRESET_ipd after IN_DELAY;
    RXCDRRESET_indelay <= RXCDRRESET_ipd after IN_DELAY;
    RXCHBONDI_indelay <= RXCHBONDI_ipd after IN_DELAY;
    RXCHBONDLEVEL_indelay <= RXCHBONDLEVEL_ipd after IN_DELAY;
    RXCHBONDMASTER_indelay <= RXCHBONDMASTER_ipd after IN_DELAY;
    RXCHBONDSLAVE_indelay <= RXCHBONDSLAVE_ipd after IN_DELAY;
    RXCOMMADETUSE_indelay <= RXCOMMADETUSE_ipd after IN_DELAY;
    RXDEC8B10BUSE_indelay <= RXDEC8B10BUSE_ipd after IN_DELAY;
    RXDLYALIGNDISABLE_indelay <= RXDLYALIGNDISABLE_ipd after IN_DELAY;
    RXDLYALIGNMONENB_indelay <= RXDLYALIGNMONENB_ipd after IN_DELAY;
    RXDLYALIGNOVERRIDE_indelay <= RXDLYALIGNOVERRIDE_ipd after IN_DELAY;
    RXDLYALIGNRESET_indelay <= RXDLYALIGNRESET_ipd after IN_DELAY;
    RXDLYALIGNSWPPRECURB_indelay <= RXDLYALIGNSWPPRECURB_ipd after IN_DELAY;
    RXDLYALIGNUPDSW_indelay <= RXDLYALIGNUPDSW_ipd after IN_DELAY;
    RXENCHANSYNC_indelay <= RXENCHANSYNC_ipd after IN_DELAY;
    RXENMCOMMAALIGN_indelay <= RXENMCOMMAALIGN_ipd after IN_DELAY;
    RXENPCOMMAALIGN_indelay <= RXENPCOMMAALIGN_ipd after IN_DELAY;
    RXENPMAPHASEALIGN_indelay <= RXENPMAPHASEALIGN_ipd after IN_DELAY;
    RXENPRBSTST_indelay <= RXENPRBSTST_ipd after IN_DELAY;
    RXENSAMPLEALIGN_indelay <= RXENSAMPLEALIGN_ipd after IN_DELAY;
    RXEQMIX_indelay <= RXEQMIX_ipd after IN_DELAY;
    RXGEARBOXSLIP_indelay <= RXGEARBOXSLIP_ipd after IN_DELAY;
    RXN_indelay <= RXN_ipd after IN_DELAY;
    RXPLLLKDETEN_indelay <= RXPLLLKDETEN_ipd after IN_DELAY;
    RXPLLPOWERDOWN_indelay <= RXPLLPOWERDOWN_ipd after IN_DELAY;
    RXPLLREFSELDY_indelay <= RXPLLREFSELDY_ipd after IN_DELAY;
    RXPMASETPHASE_indelay <= RXPMASETPHASE_ipd after IN_DELAY;
    RXPOLARITY_indelay <= RXPOLARITY_ipd after IN_DELAY;
    RXPOWERDOWN_indelay <= RXPOWERDOWN_ipd after IN_DELAY;
    RXP_indelay <= RXP_ipd after IN_DELAY;
    RXRATE_indelay <= RXRATE_ipd after IN_DELAY;
    RXRESET_indelay <= RXRESET_ipd after IN_DELAY;
    RXSLIDE_indelay <= RXSLIDE_ipd after IN_DELAY;
    TSTIN_indelay <= TSTIN_ipd after IN_DELAY;
    TXBUFDIFFCTRL_indelay <= TXBUFDIFFCTRL_ipd after IN_DELAY;
    TXBYPASS8B10B_indelay <= TXBYPASS8B10B_ipd after IN_DELAY;
    TXCHARDISPMODE_indelay <= TXCHARDISPMODE_ipd after IN_DELAY;
    TXCHARDISPVAL_indelay <= TXCHARDISPVAL_ipd after IN_DELAY;
    TXCHARISK_indelay <= TXCHARISK_ipd after IN_DELAY;
    TXCOMINIT_indelay <= TXCOMINIT_ipd after IN_DELAY;
    TXCOMSAS_indelay <= TXCOMSAS_ipd after IN_DELAY;
    TXCOMWAKE_indelay <= TXCOMWAKE_ipd after IN_DELAY;
    TXDATA_indelay <= TXDATA_ipd after IN_DELAY;
    TXDEEMPH_indelay <= TXDEEMPH_ipd after IN_DELAY;
    TXDETECTRX_indelay <= TXDETECTRX_ipd after IN_DELAY;
    TXDIFFCTRL_indelay <= TXDIFFCTRL_ipd after IN_DELAY;
    TXDLYALIGNDISABLE_indelay <= TXDLYALIGNDISABLE_ipd after IN_DELAY;
    TXDLYALIGNMONENB_indelay <= TXDLYALIGNMONENB_ipd after IN_DELAY;
    TXDLYALIGNOVERRIDE_indelay <= TXDLYALIGNOVERRIDE_ipd after IN_DELAY;
    TXDLYALIGNRESET_indelay <= TXDLYALIGNRESET_ipd after IN_DELAY;
    TXDLYALIGNUPDSW_indelay <= TXDLYALIGNUPDSW_ipd after IN_DELAY;
    TXELECIDLE_indelay <= TXELECIDLE_ipd after IN_DELAY;
    TXENC8B10BUSE_indelay <= TXENC8B10BUSE_ipd after IN_DELAY;
    TXENPMAPHASEALIGN_indelay <= TXENPMAPHASEALIGN_ipd after IN_DELAY;
    TXENPRBSTST_indelay <= TXENPRBSTST_ipd after IN_DELAY;
    TXHEADER_indelay <= TXHEADER_ipd after IN_DELAY;
    TXINHIBIT_indelay <= TXINHIBIT_ipd after IN_DELAY;
    TXMARGIN_indelay <= TXMARGIN_ipd after IN_DELAY;
    TXPDOWNASYNCH_indelay <= TXPDOWNASYNCH_ipd after IN_DELAY;
    TXPLLLKDETEN_indelay <= TXPLLLKDETEN_ipd after IN_DELAY;
    TXPLLPOWERDOWN_indelay <= TXPLLPOWERDOWN_ipd after IN_DELAY;
    TXPLLREFSELDY_indelay <= TXPLLREFSELDY_ipd after IN_DELAY;
    TXPMASETPHASE_indelay <= TXPMASETPHASE_ipd after IN_DELAY;
    TXPOLARITY_indelay <= TXPOLARITY_ipd after IN_DELAY;
    TXPOSTEMPHASIS_indelay <= TXPOSTEMPHASIS_ipd after IN_DELAY;
    TXPOWERDOWN_indelay <= TXPOWERDOWN_ipd after IN_DELAY;
    TXPRBSFORCEERR_indelay <= TXPRBSFORCEERR_ipd after IN_DELAY;
    TXPREEMPHASIS_indelay <= TXPREEMPHASIS_ipd after IN_DELAY;
    TXRATE_indelay <= TXRATE_ipd after IN_DELAY;
    TXRESET_indelay <= TXRESET_ipd after IN_DELAY;
    TXSEQUENCE_indelay <= TXSEQUENCE_ipd after IN_DELAY;
    TXSTARTSEQ_indelay <= TXSTARTSEQ_ipd after IN_DELAY;
    TXSWING_indelay <= TXSWING_ipd after IN_DELAY;
    USRCODEERR_indelay <= USRCODEERR_ipd after IN_DELAY;
    
    GTXE1_WRAP_INST : GTXE1_WRAP
      generic map (
        AC_CAP_DIS           => AC_CAP_DIS_STRING,
        ALIGN_COMMA_WORD     => ALIGN_COMMA_WORD,
        BGTEST_CFG           => BGTEST_CFG_STRING,
        BIAS_CFG             => BIAS_CFG_STRING,
        CDR_PH_ADJ_TIME      => CDR_PH_ADJ_TIME_STRING,
        CHAN_BOND_1_MAX_SKEW => CHAN_BOND_1_MAX_SKEW,
        CHAN_BOND_2_MAX_SKEW => CHAN_BOND_2_MAX_SKEW,
        CHAN_BOND_KEEP_ALIGN => CHAN_BOND_KEEP_ALIGN_STRING,
        CHAN_BOND_SEQ_1_1    => CHAN_BOND_SEQ_1_1_STRING,
        CHAN_BOND_SEQ_1_2    => CHAN_BOND_SEQ_1_2_STRING,
        CHAN_BOND_SEQ_1_3    => CHAN_BOND_SEQ_1_3_STRING,
        CHAN_BOND_SEQ_1_4    => CHAN_BOND_SEQ_1_4_STRING,
        CHAN_BOND_SEQ_1_ENABLE => CHAN_BOND_SEQ_1_ENABLE_STRING,
        CHAN_BOND_SEQ_2_1    => CHAN_BOND_SEQ_2_1_STRING,
        CHAN_BOND_SEQ_2_2    => CHAN_BOND_SEQ_2_2_STRING,
        CHAN_BOND_SEQ_2_3    => CHAN_BOND_SEQ_2_3_STRING,
        CHAN_BOND_SEQ_2_4    => CHAN_BOND_SEQ_2_4_STRING,
        CHAN_BOND_SEQ_2_CFG  => CHAN_BOND_SEQ_2_CFG_STRING,
        CHAN_BOND_SEQ_2_ENABLE => CHAN_BOND_SEQ_2_ENABLE_STRING,
        CHAN_BOND_SEQ_2_USE  => CHAN_BOND_SEQ_2_USE_STRING,
        CHAN_BOND_SEQ_LEN    => CHAN_BOND_SEQ_LEN,
        CLK_CORRECT_USE      => CLK_CORRECT_USE_STRING,
        CLK_COR_ADJ_LEN      => CLK_COR_ADJ_LEN,
        CLK_COR_DET_LEN      => CLK_COR_DET_LEN,
        CLK_COR_INSERT_IDLE_FLAG => CLK_COR_INSERT_IDLE_FLAG_STRING,
        CLK_COR_KEEP_IDLE    => CLK_COR_KEEP_IDLE_STRING,
        CLK_COR_MAX_LAT      => CLK_COR_MAX_LAT,
        CLK_COR_MIN_LAT      => CLK_COR_MIN_LAT,
        CLK_COR_PRECEDENCE   => CLK_COR_PRECEDENCE_STRING,
        CLK_COR_REPEAT_WAIT  => CLK_COR_REPEAT_WAIT,
        CLK_COR_SEQ_1_1      => CLK_COR_SEQ_1_1_STRING,
        CLK_COR_SEQ_1_2      => CLK_COR_SEQ_1_2_STRING,
        CLK_COR_SEQ_1_3      => CLK_COR_SEQ_1_3_STRING,
        CLK_COR_SEQ_1_4      => CLK_COR_SEQ_1_4_STRING,
        CLK_COR_SEQ_1_ENABLE => CLK_COR_SEQ_1_ENABLE_STRING,
        CLK_COR_SEQ_2_1      => CLK_COR_SEQ_2_1_STRING,
        CLK_COR_SEQ_2_2      => CLK_COR_SEQ_2_2_STRING,
        CLK_COR_SEQ_2_3      => CLK_COR_SEQ_2_3_STRING,
        CLK_COR_SEQ_2_4      => CLK_COR_SEQ_2_4_STRING,
        CLK_COR_SEQ_2_ENABLE => CLK_COR_SEQ_2_ENABLE_STRING,
        CLK_COR_SEQ_2_USE    => CLK_COR_SEQ_2_USE_STRING,
        CM_TRIM              => CM_TRIM_STRING,
        COMMA_10B_ENABLE     => COMMA_10B_ENABLE_STRING,
        COMMA_DOUBLE         => COMMA_DOUBLE_STRING,
        COM_BURST_VAL        => COM_BURST_VAL_STRING,
        DEC_MCOMMA_DETECT    => DEC_MCOMMA_DETECT_STRING,
        DEC_PCOMMA_DETECT    => DEC_PCOMMA_DETECT_STRING,
        DEC_VALID_COMMA_ONLY => DEC_VALID_COMMA_ONLY_STRING,
        DFE_CAL_TIME         => DFE_CAL_TIME_STRING,
        DFE_CFG              => DFE_CFG_STRING,
        GEARBOX_ENDEC        => GEARBOX_ENDEC_STRING,
        GEN_RXUSRCLK         => GEN_RXUSRCLK_STRING,
        GEN_TXUSRCLK         => GEN_TXUSRCLK_STRING,
        GTX_CFG_PWRUP        => GTX_CFG_PWRUP_STRING,
        MCOMMA_10B_VALUE     => MCOMMA_10B_VALUE_STRING,
        MCOMMA_DETECT        => MCOMMA_DETECT_STRING,
        OOBDETECT_THRESHOLD  => OOBDETECT_THRESHOLD_STRING,
        PCI_EXPRESS_MODE     => PCI_EXPRESS_MODE_STRING,
        PCOMMA_10B_VALUE     => PCOMMA_10B_VALUE_STRING,
        PCOMMA_DETECT        => PCOMMA_DETECT_STRING,
        PMA_CAS_CLK_EN       => PMA_CAS_CLK_EN_STRING,
        PMA_CDR_SCAN         => PMA_CDR_SCAN_STRING,
        PMA_CFG              => PMA_CFG_STRING,
        PMA_RXSYNC_CFG       => PMA_RXSYNC_CFG_STRING,
        PMA_RX_CFG           => PMA_RX_CFG_STRING,
        PMA_TX_CFG           => PMA_TX_CFG_STRING,
        POWER_SAVE           => POWER_SAVE_STRING,
        RCV_TERM_GND         => RCV_TERM_GND_STRING,
        RCV_TERM_VTTRX       => RCV_TERM_VTTRX_STRING,
        RXGEARBOX_USE        => RXGEARBOX_USE_STRING,
        RXPLL_COM_CFG        => RXPLL_COM_CFG_STRING,
        RXPLL_CP_CFG         => RXPLL_CP_CFG_STRING,
        RXPLL_DIVSEL45_FB    => RXPLL_DIVSEL45_FB,
        RXPLL_DIVSEL_FB      => RXPLL_DIVSEL_FB,
        RXPLL_DIVSEL_OUT     => RXPLL_DIVSEL_OUT,
        RXPLL_DIVSEL_REF     => RXPLL_DIVSEL_REF,
        RXPLL_LKDET_CFG      => RXPLL_LKDET_CFG_STRING,
        RXPRBSERR_LOOPBACK   => RXPRBSERR_LOOPBACK_STRING,
        RXRECCLK_CTRL        => RXRECCLK_CTRL,
        RXRECCLK_DLY         => RXRECCLK_DLY_STRING,
        RXUSRCLK_DLY         => RXUSRCLK_DLY_STRING,
        RX_BUFFER_USE        => RX_BUFFER_USE_STRING,
        RX_CLK25_DIVIDER     => RX_CLK25_DIVIDER,
        RX_DATA_WIDTH        => RX_DATA_WIDTH,
        RX_DECODE_SEQ_MATCH  => RX_DECODE_SEQ_MATCH_STRING,
        RX_DLYALIGN_CTRINC   => RX_DLYALIGN_CTRINC_STRING,
        RX_DLYALIGN_EDGESET  => RX_DLYALIGN_EDGESET_STRING,
        RX_DLYALIGN_LPFINC   => RX_DLYALIGN_LPFINC_STRING,
        RX_DLYALIGN_MONSEL   => RX_DLYALIGN_MONSEL_STRING,
        RX_DLYALIGN_OVRDSETTING => RX_DLYALIGN_OVRDSETTING_STRING,
        RX_EN_IDLE_HOLD_CDR  => RX_EN_IDLE_HOLD_CDR_STRING,
        RX_EN_IDLE_HOLD_DFE  => RX_EN_IDLE_HOLD_DFE_STRING,
        RX_EN_IDLE_RESET_BUF => RX_EN_IDLE_RESET_BUF_STRING,
        RX_EN_IDLE_RESET_FR  => RX_EN_IDLE_RESET_FR_STRING,
        RX_EN_IDLE_RESET_PH  => RX_EN_IDLE_RESET_PH_STRING,
        RX_EN_MODE_RESET_BUF => RX_EN_MODE_RESET_BUF_STRING,
        RX_EN_RATE_RESET_BUF => RX_EN_RATE_RESET_BUF_STRING,
        RX_EN_REALIGN_RESET_BUF => RX_EN_REALIGN_RESET_BUF_STRING,
        RX_EN_REALIGN_RESET_BUF2 => RX_EN_REALIGN_RESET_BUF2_STRING,
        RX_EYE_OFFSET        => RX_EYE_OFFSET_STRING,
        RX_EYE_SCANMODE      => RX_EYE_SCANMODE_STRING,
        RX_FIFO_ADDR_MODE    => RX_FIFO_ADDR_MODE,
        RX_IDLE_HI_CNT       => RX_IDLE_HI_CNT_STRING,
        RX_IDLE_LO_CNT       => RX_IDLE_LO_CNT_STRING,
        RX_LOSS_OF_SYNC_FSM  => RX_LOSS_OF_SYNC_FSM_STRING,
        RX_LOS_INVALID_INCR  => RX_LOS_INVALID_INCR,
        RX_LOS_THRESHOLD     => RX_LOS_THRESHOLD,
        RX_OVERSAMPLE_MODE   => RX_OVERSAMPLE_MODE_STRING,
        RX_SLIDE_AUTO_WAIT   => RX_SLIDE_AUTO_WAIT,
        RX_SLIDE_MODE        => RX_SLIDE_MODE,
        RX_XCLK_SEL          => RX_XCLK_SEL,
        SAS_MAX_COMSAS       => SAS_MAX_COMSAS,
        SAS_MIN_COMSAS       => SAS_MIN_COMSAS,
        SATA_BURST_VAL       => SATA_BURST_VAL_STRING,
        SATA_IDLE_VAL        => SATA_IDLE_VAL_STRING,
        SATA_MAX_BURST       => SATA_MAX_BURST,
        SATA_MAX_INIT        => SATA_MAX_INIT,
        SATA_MAX_WAKE        => SATA_MAX_WAKE,
        SATA_MIN_BURST       => SATA_MIN_BURST,
        SATA_MIN_INIT        => SATA_MIN_INIT,
        SATA_MIN_WAKE        => SATA_MIN_WAKE,
        SHOW_REALIGN_COMMA   => SHOW_REALIGN_COMMA_STRING,
        SIM_GTXRESET_SPEEDUP => SIM_GTXRESET_SPEEDUP,
        SIM_RECEIVER_DETECT_PASS => SIM_RECEIVER_DETECT_PASS_STRING,
        SIM_RXREFCLK_SOURCE  => SIM_RXREFCLK_SOURCE_STRING,
        SIM_TXREFCLK_SOURCE  => SIM_TXREFCLK_SOURCE_STRING,
        SIM_TX_ELEC_IDLE_LEVEL => SIM_TX_ELEC_IDLE_LEVEL,
        SIM_VERSION          => SIM_VERSION,
        TERMINATION_CTRL     => TERMINATION_CTRL_STRING,
        TERMINATION_OVRD     => TERMINATION_OVRD_STRING,
        TRANS_TIME_FROM_P2   => TRANS_TIME_FROM_P2_STRING,
        TRANS_TIME_NON_P2    => TRANS_TIME_NON_P2_STRING,
        TRANS_TIME_RATE      => TRANS_TIME_RATE_STRING,
        TRANS_TIME_TO_P2     => TRANS_TIME_TO_P2_STRING,
        TST_ATTR             => TST_ATTR_STRING,
        TXDRIVE_LOOPBACK_HIZ => TXDRIVE_LOOPBACK_HIZ_STRING,
        TXDRIVE_LOOPBACK_PD  => TXDRIVE_LOOPBACK_PD_STRING,
        TXGEARBOX_USE        => TXGEARBOX_USE_STRING,
        TXOUTCLK_CTRL        => TXOUTCLK_CTRL,
        TXOUTCLK_DLY         => TXOUTCLK_DLY_STRING,
        TXPLL_COM_CFG        => TXPLL_COM_CFG_STRING,
        TXPLL_CP_CFG         => TXPLL_CP_CFG_STRING,
        TXPLL_DIVSEL45_FB    => TXPLL_DIVSEL45_FB,
        TXPLL_DIVSEL_FB      => TXPLL_DIVSEL_FB,
        TXPLL_DIVSEL_OUT     => TXPLL_DIVSEL_OUT,
        TXPLL_DIVSEL_REF     => TXPLL_DIVSEL_REF,
        TXPLL_LKDET_CFG      => TXPLL_LKDET_CFG_STRING,
        TXPLL_SATA           => TXPLL_SATA_STRING,
        TX_BUFFER_USE        => TX_BUFFER_USE_STRING,
        TX_BYTECLK_CFG       => TX_BYTECLK_CFG_STRING,
        TX_CLK25_DIVIDER     => TX_CLK25_DIVIDER,
        TX_CLK_SOURCE        => TX_CLK_SOURCE,
        TX_DATA_WIDTH        => TX_DATA_WIDTH,
        TX_DEEMPH_0          => TX_DEEMPH_0_STRING,
        TX_DEEMPH_1          => TX_DEEMPH_1_STRING,
        TX_DETECT_RX_CFG     => TX_DETECT_RX_CFG_STRING,
        TX_DLYALIGN_CTRINC   => TX_DLYALIGN_CTRINC_STRING,
        TX_DLYALIGN_LPFINC   => TX_DLYALIGN_LPFINC_STRING,
        TX_DLYALIGN_MONSEL   => TX_DLYALIGN_MONSEL_STRING,
        TX_DLYALIGN_OVRDSETTING => TX_DLYALIGN_OVRDSETTING_STRING,
        TX_DRIVE_MODE        => TX_DRIVE_MODE,
        TX_EN_RATE_RESET_BUF => TX_EN_RATE_RESET_BUF_STRING,
        TX_IDLE_ASSERT_DELAY => TX_IDLE_ASSERT_DELAY_STRING,
        TX_IDLE_DEASSERT_DELAY => TX_IDLE_DEASSERT_DELAY_STRING,
        TX_MARGIN_FULL_0     => TX_MARGIN_FULL_0_STRING,
        TX_MARGIN_FULL_1     => TX_MARGIN_FULL_1_STRING,
        TX_MARGIN_FULL_2     => TX_MARGIN_FULL_2_STRING,
        TX_MARGIN_FULL_3     => TX_MARGIN_FULL_3_STRING,
        TX_MARGIN_FULL_4     => TX_MARGIN_FULL_4_STRING,
        TX_MARGIN_LOW_0      => TX_MARGIN_LOW_0_STRING,
        TX_MARGIN_LOW_1      => TX_MARGIN_LOW_1_STRING,
        TX_MARGIN_LOW_2      => TX_MARGIN_LOW_2_STRING,
        TX_MARGIN_LOW_3      => TX_MARGIN_LOW_3_STRING,
        TX_MARGIN_LOW_4      => TX_MARGIN_LOW_4_STRING,
        TX_OVERSAMPLE_MODE   => TX_OVERSAMPLE_MODE_STRING,
        TX_PMADATA_OPT       => TX_PMADATA_OPT_STRING,
        TX_TDCC_CFG          => TX_TDCC_CFG_STRING,
        TX_USRCLK_CFG        => TX_USRCLK_CFG_STRING,
        TX_XCLK_SEL          => TX_XCLK_SEL
      )
      
      port map (
        GSR                  => GSR,
        COMFINISH            => COMFINISH_outdelay,
        COMINITDET           => COMINITDET_outdelay,
        COMSASDET            => COMSASDET_outdelay,
        COMWAKEDET           => COMWAKEDET_outdelay,
        DFECLKDLYADJMON      => DFECLKDLYADJMON_outdelay,
        DFEEYEDACMON         => DFEEYEDACMON_outdelay,
        DFESENSCAL           => DFESENSCAL_outdelay,
        DFETAP1MONITOR       => DFETAP1MONITOR_outdelay,
        DFETAP2MONITOR       => DFETAP2MONITOR_outdelay,
        DFETAP3MONITOR       => DFETAP3MONITOR_outdelay,
        DFETAP4MONITOR       => DFETAP4MONITOR_outdelay,
        DRDY                 => DRDY_outdelay,
        DRPDO                => DRPDO_outdelay,
        MGTREFCLKFAB         => MGTREFCLKFAB_outdelay,
        PHYSTATUS            => PHYSTATUS_outdelay,
        RXBUFSTATUS          => RXBUFSTATUS_outdelay,
        RXBYTEISALIGNED      => RXBYTEISALIGNED_outdelay,
        RXBYTEREALIGN        => RXBYTEREALIGN_outdelay,
        RXCHANBONDSEQ        => RXCHANBONDSEQ_outdelay,
        RXCHANISALIGNED      => RXCHANISALIGNED_outdelay,
        RXCHANREALIGN        => RXCHANREALIGN_outdelay,
        RXCHARISCOMMA        => RXCHARISCOMMA_outdelay,
        RXCHARISK            => RXCHARISK_outdelay,
        RXCHBONDO            => RXCHBONDO_outdelay,
        RXCLKCORCNT          => RXCLKCORCNT_outdelay,
        RXCOMMADET           => RXCOMMADET_outdelay,
        RXDATA               => RXDATA_outdelay,
        RXDATAVALID          => RXDATAVALID_outdelay,
        RXDISPERR            => RXDISPERR_outdelay,
        RXDLYALIGNMONITOR    => RXDLYALIGNMONITOR_outdelay,
        RXELECIDLE           => RXELECIDLE_outdelay,
        RXHEADER             => RXHEADER_outdelay,
        RXHEADERVALID        => RXHEADERVALID_outdelay,
        RXLOSSOFSYNC         => RXLOSSOFSYNC_outdelay,
        RXNOTINTABLE         => RXNOTINTABLE_outdelay,
        RXOVERSAMPLEERR      => RXOVERSAMPLEERR_outdelay,
        RXPLLLKDET           => RXPLLLKDET_outdelay,
        RXPRBSERR            => RXPRBSERR_outdelay,
        RXRATEDONE           => RXRATEDONE_outdelay,
        RXRECCLK             => RXRECCLK_outdelay,
        RXRECCLKPCS          => RXRECCLKPCS_outdelay,
        RXRESETDONE          => RXRESETDONE_outdelay,
        RXRUNDISP            => RXRUNDISP_outdelay,
        RXSTARTOFSEQ         => RXSTARTOFSEQ_outdelay,
        RXSTATUS             => RXSTATUS_outdelay,
        RXVALID              => RXVALID_outdelay,
        TSTOUT               => TSTOUT_outdelay,
        TXBUFSTATUS          => TXBUFSTATUS_outdelay,
        TXDLYALIGNMONITOR    => TXDLYALIGNMONITOR_outdelay,
        TXGEARBOXREADY       => TXGEARBOXREADY_outdelay,
        TXKERR               => TXKERR_outdelay,
        TXN                  => TXN_outdelay,
        TXOUTCLK             => TXOUTCLK_outdelay,
        TXOUTCLKPCS          => TXOUTCLKPCS_outdelay,
        TXP                  => TXP_outdelay,
        TXPLLLKDET           => TXPLLLKDET_outdelay,
        TXRATEDONE           => TXRATEDONE_outdelay,
        TXRESETDONE          => TXRESETDONE_outdelay,
        TXRUNDISP            => TXRUNDISP_outdelay,
        DADDR                => DADDR_indelay,
        DCLK                 => DCLK_indelay,
        DEN                  => DEN_indelay,
        DFECLKDLYADJ         => DFECLKDLYADJ_indelay,
        DFEDLYOVRD           => DFEDLYOVRD_indelay,
        DFETAP1              => DFETAP1_indelay,
        DFETAP2              => DFETAP2_indelay,
        DFETAP3              => DFETAP3_indelay,
        DFETAP4              => DFETAP4_indelay,
        DFETAPOVRD           => DFETAPOVRD_indelay,
        DI                   => DI_indelay,
        DWE                  => DWE_indelay,
        GATERXELECIDLE       => GATERXELECIDLE_indelay,
        GREFCLKRX            => GREFCLKRX_indelay,
        GREFCLKTX            => GREFCLKTX_indelay,
        GTXRXRESET           => GTXRXRESET_indelay,
        GTXTEST              => GTXTEST_indelay,
        GTXTXRESET           => GTXTXRESET_indelay,
        IGNORESIGDET         => IGNORESIGDET_indelay,
        LOOPBACK             => LOOPBACK_indelay,
        MGTREFCLKRX          => MGTREFCLKRX_indelay,
        MGTREFCLKTX          => MGTREFCLKTX_indelay,
        NORTHREFCLKRX        => NORTHREFCLKRX_indelay,
        NORTHREFCLKTX        => NORTHREFCLKTX_indelay,
        PERFCLKRX            => PERFCLKRX_indelay,
        PERFCLKTX            => PERFCLKTX_indelay,
        PLLRXRESET           => PLLRXRESET_indelay,
        PLLTXRESET           => PLLTXRESET_indelay,
        PRBSCNTRESET         => PRBSCNTRESET_indelay,
        RXBUFRESET           => RXBUFRESET_indelay,
        RXCDRRESET           => RXCDRRESET_indelay,
        RXCHBONDI            => RXCHBONDI_indelay,
        RXCHBONDLEVEL        => RXCHBONDLEVEL_indelay,
        RXCHBONDMASTER       => RXCHBONDMASTER_indelay,
        RXCHBONDSLAVE        => RXCHBONDSLAVE_indelay,
        RXCOMMADETUSE        => RXCOMMADETUSE_indelay,
        RXDEC8B10BUSE        => RXDEC8B10BUSE_indelay,
        RXDLYALIGNDISABLE    => RXDLYALIGNDISABLE_indelay,
        RXDLYALIGNMONENB     => RXDLYALIGNMONENB_indelay,
        RXDLYALIGNOVERRIDE   => RXDLYALIGNOVERRIDE_indelay,
        RXDLYALIGNRESET      => RXDLYALIGNRESET_indelay,
        RXDLYALIGNSWPPRECURB => RXDLYALIGNSWPPRECURB_indelay,
        RXDLYALIGNUPDSW      => RXDLYALIGNUPDSW_indelay,
        RXENCHANSYNC         => RXENCHANSYNC_indelay,
        RXENMCOMMAALIGN      => RXENMCOMMAALIGN_indelay,
        RXENPCOMMAALIGN      => RXENPCOMMAALIGN_indelay,
        RXENPMAPHASEALIGN    => RXENPMAPHASEALIGN_indelay,
        RXENPRBSTST          => RXENPRBSTST_indelay,
        RXENSAMPLEALIGN      => RXENSAMPLEALIGN_indelay,
        RXEQMIX              => RXEQMIX_indelay,
        RXGEARBOXSLIP        => RXGEARBOXSLIP_indelay,
        RXN                  => RXN_indelay,
        RXP                  => RXP_indelay,
        RXPLLLKDETEN         => RXPLLLKDETEN_indelay,
        RXPLLPOWERDOWN       => RXPLLPOWERDOWN_indelay,
        RXPLLREFSELDY        => RXPLLREFSELDY_indelay,
        RXPMASETPHASE        => RXPMASETPHASE_indelay,
        RXPOLARITY           => RXPOLARITY_indelay,
        RXPOWERDOWN          => RXPOWERDOWN_indelay,
        RXRATE               => RXRATE_indelay,
        RXRESET              => RXRESET_indelay,
        RXSLIDE              => RXSLIDE_indelay,
        RXUSRCLK             => RXUSRCLK_indelay,
        RXUSRCLK2            => RXUSRCLK2_indelay,
        SOUTHREFCLKRX        => SOUTHREFCLKRX_indelay,
        SOUTHREFCLKTX        => SOUTHREFCLKTX_indelay,
        TSTCLK0              => TSTCLK0_indelay,
        TSTCLK1              => TSTCLK1_indelay,
        TSTIN                => TSTIN_indelay,
        TXBUFDIFFCTRL        => TXBUFDIFFCTRL_indelay,
        TXBYPASS8B10B        => TXBYPASS8B10B_indelay,
        TXCHARDISPMODE       => TXCHARDISPMODE_indelay,
        TXCHARDISPVAL        => TXCHARDISPVAL_indelay,
        TXCHARISK            => TXCHARISK_indelay,
        TXCOMINIT            => TXCOMINIT_indelay,
        TXCOMSAS             => TXCOMSAS_indelay,
        TXCOMWAKE            => TXCOMWAKE_indelay,
        TXDATA               => TXDATA_indelay,
        TXDEEMPH             => TXDEEMPH_indelay,
        TXDETECTRX           => TXDETECTRX_indelay,
        TXDIFFCTRL           => TXDIFFCTRL_indelay,
        TXDLYALIGNDISABLE    => TXDLYALIGNDISABLE_indelay,
        TXDLYALIGNMONENB     => TXDLYALIGNMONENB_indelay,
        TXDLYALIGNOVERRIDE   => TXDLYALIGNOVERRIDE_indelay,
        TXDLYALIGNRESET      => TXDLYALIGNRESET_indelay,
        TXDLYALIGNUPDSW      => TXDLYALIGNUPDSW_indelay,
        TXELECIDLE           => TXELECIDLE_indelay,
        TXENC8B10BUSE        => TXENC8B10BUSE_indelay,
        TXENPMAPHASEALIGN    => TXENPMAPHASEALIGN_indelay,
        TXENPRBSTST          => TXENPRBSTST_indelay,
        TXHEADER             => TXHEADER_indelay,
        TXINHIBIT            => TXINHIBIT_indelay,
        TXMARGIN             => TXMARGIN_indelay,
        TXPDOWNASYNCH        => TXPDOWNASYNCH_indelay,
        TXPLLLKDETEN         => TXPLLLKDETEN_indelay,
        TXPLLPOWERDOWN       => TXPLLPOWERDOWN_indelay,
        TXPLLREFSELDY        => TXPLLREFSELDY_indelay,
        TXPMASETPHASE        => TXPMASETPHASE_indelay,
        TXPOLARITY           => TXPOLARITY_indelay,
        TXPOSTEMPHASIS       => TXPOSTEMPHASIS_indelay,
        TXPOWERDOWN          => TXPOWERDOWN_indelay,
        TXPRBSFORCEERR       => TXPRBSFORCEERR_indelay,
        TXPREEMPHASIS        => TXPREEMPHASIS_indelay,
        TXRATE               => TXRATE_indelay,
        TXRESET              => TXRESET_indelay,
        TXSEQUENCE           => TXSEQUENCE_indelay,
        TXSTARTSEQ           => TXSTARTSEQ_indelay,
        TXSWING              => TXSWING_indelay,
        TXUSRCLK             => TXUSRCLK_indelay,
        TXUSRCLK2            => TXUSRCLK2_indelay,
        USRCODEERR           => USRCODEERR_indelay        
      );
    
    INIPROC : process
    begin

   -- Start DRC Checks

        if (CHAN_BOND_2_MAX_SKEW > CHAN_BOND_1_MAX_SKEW) then
        assert false
          report "DRC Error : The value of CHAN_BOND_2_MAX_SKEW must be less than or equal to the value of CHAN_BOND_1_MAX_SKEW for instance GTXE1."
          severity failure;
        end if;

        if (CLK_COR_MIN_LAT > CLK_COR_MAX_LAT) then
        assert false
          report "DRC Error : The value of CLK_COR_MIN_LAT must be less than or equal to the value of CLK_COR_MAX_LAT for instance GTXE1."
          severity failure;
        end if;

        if (SATA_MIN_BURST > SATA_MAX_BURST) then
        assert false
          report "DRC Error : The value of SATA_MIN_BURST must be less than or equal to the value of SATA_MAX_BURST for instance GTXE1."
          severity failure;
        end if;

        if (SATA_MIN_INIT > SATA_MAX_INIT) then
        assert false
          report "DRC Error : The value of SATA_MIN_INIT must be less than or equal to the value of SATA_MAX_INIT for instance GTXE1."
          severity failure;
        end if;

        
        if (SATA_MIN_WAKE > SATA_MAX_WAKE) then
        assert false
          report "DRC Error : The value of SATA_MIN_WAKE must be less than or equal to the value of SATA_MAX_WAKE for instance GTXE1."
          severity failure;
        end if;

        if (SAS_MIN_COMSAS > SAS_MAX_COMSAS) then
        assert false
          report "DRC Error : The value of SAS_MIN_COMSAS must be less than or equal to the value of SAS_MAX_COMSAS for instance GTXE1."
          severity failure;
        end if;

        if (RX_DATA_WIDTH = 16 and GEN_RXUSRCLK = FALSE) or (RX_DATA_WIDTH = 20 and GEN_RXUSRCLK = FALSE) then
        assert false
          report "DRC Error : If RX_DATA_WIDTH is set to 8 or 10 (and channel bonding is not used) or if RX_DATA_WIDTH is set to 16 or 20 then set GEN_RXUSRCLK to TRUE for instance GTXE1."
          severity failure;
        end if;

        if (RX_DATA_WIDTH = 32 and GEN_RXUSRCLK = TRUE) or (RX_DATA_WIDTH = 40 and GEN_RXUSRCLK = TRUE) then
        assert false
          report "DRC Error : If RX_DATA_WIDTH is set 32 or 40 then set GEN_RXUSRCLK to FALSE for instance GTXE1."
          severity failure;
        end if;

        if (TX_DATA_WIDTH = 16 and GEN_TXUSRCLK = FALSE) or (TX_DATA_WIDTH = 20 and GEN_TXUSRCLK = FALSE) then
        assert false
          report "DRC Error : If TX_DATA_WIDTH is set to 8 or 10 (and channel bonding is not used) or if TX_DATA_WIDTH is set to 16 or 20 then set GEN_TXUSRCLK to TRUE for instance GTXE1."
          severity failure;
        end if;

        if (TX_DATA_WIDTH = 32 and GEN_TXUSRCLK = TRUE) or (TX_DATA_WIDTH = 40 and GEN_TXUSRCLK = TRUE) then
        assert false
          report "DRC Error : If TX_DATA_WIDTH is set 32 or 40 then set GEN_TXUSRCLK to FALSE for instance GTXE1."
          severity failure;
        end if;

        if (CLK_CORRECT_USE = TRUE) and (RX_FIFO_ADDR_MODE = "FAST") then
        assert false
          report "DRC Error : If CLK_CORRECT_USE is set to TRUE then set RX_FIFO_ADDR_MODE to FULL for instance GTXE1."
          severity failure;
        end if;

        if ((RX_SLIDE_MODE = "PMA") and (SHOW_REALIGN_COMMA = TRUE)) or ((RX_SLIDE_MODE = "AUTO") and (SHOW_REALIGN_COMMA = TRUE)) then
        assert false
          report "DRC Error : If RX_SLIDE_MODE is set to PMA or AUTO then set SHOW_REALIGN_COMMA to FALSE for instance GTXE1."
          severity failure;
        end if;

        if (TXOUTCLK_CTRL = "CLKTESTSIG0") then
        assert false
          report "DRC Error : TXOUTCLK_CTRL cannot be set to CLKTESTSIG0 for instance GTXE1."
	  severity failure;
        end if;

        if (RXRECCLK_CTRL = "CLKTESTSIG1") then
        assert false
          report "DRC Error : RXRECCLK_CTRL cannot be set to CLKTESTSIG1 for instance GTXE1."
	  severity failure;
        end if;
     
        if (TXOUTCLK_CTRL = "OFF_LOW") then
        assert false
          report "DRC Error : TXOUTCLK_CTRL cannot be set to OFF_LOW for instance GTXE1."
	  severity failure;
        end if;

        if (RXRECCLK_CTRL = "OFF_LOW") then
         assert false
          report "DRC Error : RXRECCLK_CTRL cannot be set to OFF_LOW for instance GTXE1."
	  severity failure;
        end if;

        if (TXOUTCLK_CTRL = "OFF_HIGH") then
        assert false
          report "DRC Error : TXOUTCLK_CTRL cannot be set to OFF_HIGH for instance GTXE1."
	  severity failure;
        end if;

        if (RXRECCLK_CTRL = "OFF_HIGH") then
        assert false
          report "DRC Error : RXRECCLK_CTRL cannot be set to OFF_HIGH for instance GTXE1."
	  severity failure;
        end if;

       if ((RX_BUFFER_USE = TRUE) and (POWER_SAVE_BINARY(5) /= '1')) then
      	assert false
          report "DRC Error : If value of RX_BUFFER_USE is set to TRUE then value of POWER_SAVE(5) has to be set to 1 for instance GTXE1."
          severity failure;
       end if;

       if (POWER_SAVE_BINARY(4) /= '1') then
       	assert false
         report "DRC Error: Value of POWER_SAVE(4) has to be set to 1 for instance GTXE1."
         severity failure;
       end if;
          
   -- End DRC Checks

      -- case RXRECCLK_CTRL is
      if((RXRECCLK_CTRL = "RXRECCLKPCS") or (RXRECCLK_CTRL = "rxrecclkpcs")) then
        RXRECCLK_CTRL_BINARY <= "000";
      elsif((RXRECCLK_CTRL = "RXPLLREFCLK_DIV1") or (RXRECCLK_CTRL= "rxpllrefclk_div1")) then
        RXRECCLK_CTRL_BINARY <= "011";
      elsif((RXRECCLK_CTRL = "RXPLLREFCLK_DIV2") or (RXRECCLK_CTRL= "rxpllrefclk_div2")) then
        RXRECCLK_CTRL_BINARY <= "100";
      elsif((RXRECCLK_CTRL = "RXRECCLKPMA_DIV1") or (RXRECCLK_CTRL= "rxrecclkpma_div1")) then
        RXRECCLK_CTRL_BINARY <= "001";
      elsif((RXRECCLK_CTRL = "RXRECCLKPMA_DIV2") or (RXRECCLK_CTRL= "rxrecclkpma_div2")) then
        RXRECCLK_CTRL_BINARY <= "010";
      else
        assert FALSE report "Error : RXRECCLK_CTRL = is not RXRECCLKPCS, RXPLLREFCLK_DIV1, RXPLLREFCLK_DIV2, RXRECCLKPMA_DIV1, RXRECCLKPMA_DIV2." severity error;
      end if;
    -- end case;
    -- case RX_FIFO_ADDR_MODE is
      if((RX_FIFO_ADDR_MODE = "FULL") or (RX_FIFO_ADDR_MODE = "full")) then
        RX_FIFO_ADDR_MODE_BINARY <= '0';
      elsif((RX_FIFO_ADDR_MODE = "FAST") or (RX_FIFO_ADDR_MODE= "fast")) then
        RX_FIFO_ADDR_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : RX_FIFO_ADDR_MODE = is not FULL, FAST." severity error;
      end if;
    -- end case;
    -- case RX_SLIDE_MODE is
      if((RX_SLIDE_MODE = "OFF") or (RX_SLIDE_MODE = "off")) then
        RX_SLIDE_MODE_BINARY <= "00";
      elsif((RX_SLIDE_MODE = "AUTO") or (RX_SLIDE_MODE= "auto")) then
        RX_SLIDE_MODE_BINARY <= "01";
      elsif((RX_SLIDE_MODE = "PCS") or (RX_SLIDE_MODE= "pcs")) then
        RX_SLIDE_MODE_BINARY <= "10";
      elsif((RX_SLIDE_MODE = "PMA") or (RX_SLIDE_MODE= "pma")) then
        RX_SLIDE_MODE_BINARY <= "11";
      else
        assert FALSE report "Error : RX_SLIDE_MODE = is not OFF, AUTO, PCS, PMA." severity error;
      end if;
    -- end case;
    -- case RX_XCLK_SEL is
      if((RX_XCLK_SEL = "RXREC") or (RX_XCLK_SEL = "rxrec")) then
        RX_XCLK_SEL_BINARY <= '0';
      elsif((RX_XCLK_SEL = "RXUSR") or (RX_XCLK_SEL= "rxusr")) then
        RX_XCLK_SEL_BINARY <= '1';
      else
        assert FALSE report "Error : RX_XCLK_SEL = is not RXREC, RXUSR." severity error;
      end if;
    -- end case;
    -- case TXOUTCLK_CTRL is
      if((TXOUTCLK_CTRL = "TXOUTCLKPCS") or (TXOUTCLK_CTRL = "txoutclkpcs")) then
        TXOUTCLK_CTRL_BINARY <= "000";
      elsif((TXOUTCLK_CTRL = "TXOUTCLKPMA_DIV1") or (TXOUTCLK_CTRL= "txoutclkpma_div1")) then
        TXOUTCLK_CTRL_BINARY <= "001";
      elsif((TXOUTCLK_CTRL = "TXOUTCLKPMA_DIV2") or (TXOUTCLK_CTRL= "txoutclkpma_div2")) then
        TXOUTCLK_CTRL_BINARY <= "010";
      elsif((TXOUTCLK_CTRL = "TXPLLREFCLK_DIV1") or (TXOUTCLK_CTRL= "txpllrefclk_div1")) then
        TXOUTCLK_CTRL_BINARY <= "011";
      elsif((TXOUTCLK_CTRL = "TXPLLREFCLK_DIV2") or (TXOUTCLK_CTRL= "txpllrefclk_div2")) then
        TXOUTCLK_CTRL_BINARY <= "100";
      else
        assert FALSE report "Error : TXOUTCLK_CTRL = is not TXOUTCLKPCS, TXOUTCLKPMA_DIV1, TXOUTCLKPMA_DIV2, TXPLLREFCLK_DIV1, TXPLLREFCLK_DIV2." severity error;
      end if;
    -- end case;
    -- case TX_CLK_SOURCE is
      if((TX_CLK_SOURCE = "RXPLL") or (TX_CLK_SOURCE = "rxpll")) then
        TX_CLK_SOURCE_BINARY <= '1';
      elsif((TX_CLK_SOURCE = "TXPLL") or (TX_CLK_SOURCE= "txpll")) then
        TX_CLK_SOURCE_BINARY <= '0';
      else
        assert FALSE report "Error : TX_CLK_SOURCE = is not RXPLL, TXPLL." severity error;
      end if;
    -- end case;
    -- case TX_DRIVE_MODE is
      if((TX_DRIVE_MODE = "DIRECT") or (TX_DRIVE_MODE = "direct")) then
        TX_DRIVE_MODE_BINARY <= '0';
      elsif((TX_DRIVE_MODE = "PIPE") or (TX_DRIVE_MODE= "pipe")) then
        TX_DRIVE_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : TX_DRIVE_MODE = is not DIRECT, PIPE." severity error;
      end if;
    -- end case;
    -- case TX_XCLK_SEL is
      if((TX_XCLK_SEL = "TXUSR") or (TX_XCLK_SEL = "txusr")) then
        TX_XCLK_SEL_BINARY <= '1';
      elsif((TX_XCLK_SEL = "TXOUT") or (TX_XCLK_SEL= "txout")) then
        TX_XCLK_SEL_BINARY <= '0';
      else
        assert FALSE report "Error : TX_XCLK_SEL = is not TXUSR, TXOUT." severity error;
      end if;
    -- end case;
    case AC_CAP_DIS is
      when FALSE   =>  AC_CAP_DIS_BINARY <= '0';
      when TRUE    =>  AC_CAP_DIS_BINARY <= '1';
      when others  =>  assert FALSE report "Error : AC_CAP_DIS is neither TRUE nor FALSE." severity error;
    end case;
    case ALIGN_COMMA_WORD is
      when  1   =>  ALIGN_COMMA_WORD_BINARY <= '0';
      when  2   =>  ALIGN_COMMA_WORD_BINARY <= '1';
      when others  =>  assert FALSE report "Error : ALIGN_COMMA_WORD is not in range 1 .. 2." severity error;
    end case;
    case CHAN_BOND_KEEP_ALIGN is
      when FALSE   =>  CHAN_BOND_KEEP_ALIGN_BINARY <= '0';
      when TRUE    =>  CHAN_BOND_KEEP_ALIGN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CHAN_BOND_KEEP_ALIGN is neither TRUE nor FALSE." severity error;
    end case;
    case CHAN_BOND_SEQ_2_USE is
      when FALSE   =>  CHAN_BOND_SEQ_2_USE_BINARY <= '0';
      when TRUE    =>  CHAN_BOND_SEQ_2_USE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_2_USE is neither TRUE nor FALSE." severity error;
    end case;
    case CLK_CORRECT_USE is
      when FALSE   =>  CLK_CORRECT_USE_BINARY <= '0';
      when TRUE    =>  CLK_CORRECT_USE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CLK_CORRECT_USE is neither TRUE nor FALSE." severity error;
    end case;
    case CLK_COR_INSERT_IDLE_FLAG is
      when FALSE   =>  CLK_COR_INSERT_IDLE_FLAG_BINARY <= '0';
      when TRUE    =>  CLK_COR_INSERT_IDLE_FLAG_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CLK_COR_INSERT_IDLE_FLAG is neither TRUE nor FALSE." severity error;
    end case;
    case CLK_COR_KEEP_IDLE is
      when FALSE   =>  CLK_COR_KEEP_IDLE_BINARY <= '0';
      when TRUE    =>  CLK_COR_KEEP_IDLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CLK_COR_KEEP_IDLE is neither TRUE nor FALSE." severity error;
    end case;
    case CLK_COR_PRECEDENCE is
      when FALSE   =>  CLK_COR_PRECEDENCE_BINARY <= '0';
      when TRUE    =>  CLK_COR_PRECEDENCE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CLK_COR_PRECEDENCE is neither TRUE nor FALSE." severity error;
    end case;
    case CLK_COR_SEQ_2_USE is
      when FALSE   =>  CLK_COR_SEQ_2_USE_BINARY <= '0';
      when TRUE    =>  CLK_COR_SEQ_2_USE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : CLK_COR_SEQ_2_USE is neither TRUE nor FALSE." severity error;
    end case;
    case COMMA_DOUBLE is
      when FALSE   =>  COMMA_DOUBLE_BINARY <= '0';
      when TRUE    =>  COMMA_DOUBLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : COMMA_DOUBLE is neither TRUE nor FALSE." severity error;
    end case;
    case DEC_MCOMMA_DETECT is
      when FALSE   =>  DEC_MCOMMA_DETECT_BINARY <= '0';
      when TRUE    =>  DEC_MCOMMA_DETECT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEC_MCOMMA_DETECT is neither TRUE nor FALSE." severity error;
    end case;
    case DEC_PCOMMA_DETECT is
      when FALSE   =>  DEC_PCOMMA_DETECT_BINARY <= '0';
      when TRUE    =>  DEC_PCOMMA_DETECT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEC_PCOMMA_DETECT is neither TRUE nor FALSE." severity error;
    end case;
    case DEC_VALID_COMMA_ONLY is
      when FALSE   =>  DEC_VALID_COMMA_ONLY_BINARY <= '0';
      when TRUE    =>  DEC_VALID_COMMA_ONLY_BINARY <= '1';
      when others  =>  assert FALSE report "Error : DEC_VALID_COMMA_ONLY is neither TRUE nor FALSE." severity error;
    end case;
    case GEN_RXUSRCLK is
      when FALSE   =>  GEN_RXUSRCLK_BINARY <= '0';
      when TRUE    =>  GEN_RXUSRCLK_BINARY <= '1';
      when others  =>  assert FALSE report "Error : GEN_RXUSRCLK is neither TRUE nor FALSE." severity error;
    end case;
    case GEN_TXUSRCLK is
      when FALSE   =>  GEN_TXUSRCLK_BINARY <= '0';
      when TRUE    =>  GEN_TXUSRCLK_BINARY <= '1';
      when others  =>  assert FALSE report "Error : GEN_TXUSRCLK is neither TRUE nor FALSE." severity error;
    end case;
    case GTX_CFG_PWRUP is
      when FALSE   =>  GTX_CFG_PWRUP_BINARY <= '0';
      when TRUE    =>  GTX_CFG_PWRUP_BINARY <= '1';
      when others  =>  assert FALSE report "Error : GTX_CFG_PWRUP is neither TRUE nor FALSE." severity error;
    end case;
    case MCOMMA_DETECT is
      when FALSE   =>  MCOMMA_DETECT_BINARY <= '0';
      when TRUE    =>  MCOMMA_DETECT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : MCOMMA_DETECT is neither TRUE nor FALSE." severity error;
    end case;
    case PCI_EXPRESS_MODE is
      when FALSE   =>  PCI_EXPRESS_MODE_BINARY <= '0';
      when TRUE    =>  PCI_EXPRESS_MODE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PCI_EXPRESS_MODE is neither TRUE nor FALSE." severity error;
    end case;
    case PCOMMA_DETECT is
      when FALSE   =>  PCOMMA_DETECT_BINARY <= '0';
      when TRUE    =>  PCOMMA_DETECT_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PCOMMA_DETECT is neither TRUE nor FALSE." severity error;
    end case;
    case PMA_CAS_CLK_EN is
      when FALSE   =>  PMA_CAS_CLK_EN_BINARY <= '0';
      when TRUE    =>  PMA_CAS_CLK_EN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : PMA_CAS_CLK_EN is neither TRUE nor FALSE." severity error;
    end case;
    case RCV_TERM_GND is
      when FALSE   =>  RCV_TERM_GND_BINARY <= '0';
      when TRUE    =>  RCV_TERM_GND_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RCV_TERM_GND is neither TRUE nor FALSE." severity error;
    end case;
    case RCV_TERM_VTTRX is
      when FALSE   =>  RCV_TERM_VTTRX_BINARY <= '0';
      when TRUE    =>  RCV_TERM_VTTRX_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RCV_TERM_VTTRX is neither TRUE nor FALSE." severity error;
    end case;
    case RXGEARBOX_USE is
      when FALSE   =>  RXGEARBOX_USE_BINARY <= '0';
      when TRUE    =>  RXGEARBOX_USE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RXGEARBOX_USE is neither TRUE nor FALSE." severity error;
    end case;
    case RXPLL_DIVSEL45_FB is
      when  5   =>  RXPLL_DIVSEL45_FB_BINARY <= '1';
      when  4   =>  RXPLL_DIVSEL45_FB_BINARY <= '0';
      when others  =>  assert FALSE report "Error : RXPLL_DIVSEL45_FB is not in range 5 .. 4." severity error;
    end case;
    case RX_BUFFER_USE is
      when FALSE   =>  RX_BUFFER_USE_BINARY <= '0';
      when TRUE    =>  RX_BUFFER_USE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_BUFFER_USE is neither TRUE nor FALSE." severity error;
    end case;
    case RX_DECODE_SEQ_MATCH is
      when FALSE   =>  RX_DECODE_SEQ_MATCH_BINARY <= '0';
      when TRUE    =>  RX_DECODE_SEQ_MATCH_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_DECODE_SEQ_MATCH is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_IDLE_HOLD_CDR is
      when FALSE   =>  RX_EN_IDLE_HOLD_CDR_BINARY <= '0';
      when TRUE    =>  RX_EN_IDLE_HOLD_CDR_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_IDLE_HOLD_CDR is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_IDLE_HOLD_DFE is
      when FALSE   =>  RX_EN_IDLE_HOLD_DFE_BINARY <= '0';
      when TRUE    =>  RX_EN_IDLE_HOLD_DFE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_IDLE_HOLD_DFE is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_IDLE_RESET_BUF is
      when FALSE   =>  RX_EN_IDLE_RESET_BUF_BINARY <= '0';
      when TRUE    =>  RX_EN_IDLE_RESET_BUF_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_BUF is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_IDLE_RESET_FR is
      when FALSE   =>  RX_EN_IDLE_RESET_FR_BINARY <= '0';
      when TRUE    =>  RX_EN_IDLE_RESET_FR_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_FR is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_IDLE_RESET_PH is
      when FALSE   =>  RX_EN_IDLE_RESET_PH_BINARY <= '0';
      when TRUE    =>  RX_EN_IDLE_RESET_PH_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_IDLE_RESET_PH is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_MODE_RESET_BUF is
      when FALSE   =>  RX_EN_MODE_RESET_BUF_BINARY <= '0';
      when TRUE    =>  RX_EN_MODE_RESET_BUF_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_MODE_RESET_BUF is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_RATE_RESET_BUF is
      when FALSE   =>  RX_EN_RATE_RESET_BUF_BINARY <= '0';
      when TRUE    =>  RX_EN_RATE_RESET_BUF_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_RATE_RESET_BUF is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_REALIGN_RESET_BUF is
      when FALSE   =>  RX_EN_REALIGN_RESET_BUF_BINARY <= '0';
      when TRUE    =>  RX_EN_REALIGN_RESET_BUF_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_REALIGN_RESET_BUF is neither TRUE nor FALSE." severity error;
    end case;
    case RX_EN_REALIGN_RESET_BUF2 is
      when FALSE   =>  RX_EN_REALIGN_RESET_BUF2_BINARY <= '0';
      when TRUE    =>  RX_EN_REALIGN_RESET_BUF2_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_EN_REALIGN_RESET_BUF2 is neither TRUE nor FALSE." severity error;
    end case;
    case RX_LOSS_OF_SYNC_FSM is
      when FALSE   =>  RX_LOSS_OF_SYNC_FSM_BINARY <= '0';
      when TRUE    =>  RX_LOSS_OF_SYNC_FSM_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_LOSS_OF_SYNC_FSM is neither TRUE nor FALSE." severity error;
    end case;
    case RX_OVERSAMPLE_MODE is
      when FALSE   =>  RX_OVERSAMPLE_MODE_BINARY <= '0';
      when TRUE    =>  RX_OVERSAMPLE_MODE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : RX_OVERSAMPLE_MODE is neither TRUE nor FALSE." severity error;
    end case;
    case SHOW_REALIGN_COMMA is
      when FALSE   =>  SHOW_REALIGN_COMMA_BINARY <= '0';
      when TRUE    =>  SHOW_REALIGN_COMMA_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SHOW_REALIGN_COMMA is neither TRUE nor FALSE." severity error;
    end case;
    case SIM_GTXRESET_SPEEDUP is
      when  1   =>  SIM_GTXRESET_SPEEDUP_BINARY <= '1';
      when  0   =>  SIM_GTXRESET_SPEEDUP_BINARY <= '0';
      when others  =>  assert FALSE report "Error : SIM_GTXRESET_SPEEDUP is not in range 0 .. 1." severity error;
    end case;
    case SIM_RECEIVER_DETECT_PASS is
      when FALSE   =>  SIM_RECEIVER_DETECT_PASS_BINARY <= '0';
      when TRUE    =>  SIM_RECEIVER_DETECT_PASS_BINARY <= '1';
      when others  =>  assert FALSE report "Error : SIM_RECEIVER_DETECT_PASS is neither TRUE nor FALSE." severity error;
    end case; 
    case TERMINATION_OVRD is
      when FALSE   =>  TERMINATION_OVRD_BINARY <= '0';
      when TRUE    =>  TERMINATION_OVRD_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TERMINATION_OVRD is neither TRUE nor FALSE." severity error;
    end case;
    case TXDRIVE_LOOPBACK_HIZ is
      when FALSE   =>  TXDRIVE_LOOPBACK_HIZ_BINARY <= '0';
      when TRUE    =>  TXDRIVE_LOOPBACK_HIZ_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TXDRIVE_LOOPBACK_HIZ is neither TRUE nor FALSE." severity error;
    end case;
    case TXDRIVE_LOOPBACK_PD is
      when FALSE   =>  TXDRIVE_LOOPBACK_PD_BINARY <= '0';
      when TRUE    =>  TXDRIVE_LOOPBACK_PD_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TXDRIVE_LOOPBACK_PD is neither TRUE nor FALSE." severity error;
    end case;
    case TXGEARBOX_USE is
      when FALSE   =>  TXGEARBOX_USE_BINARY <= '0';
      when TRUE    =>  TXGEARBOX_USE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TXGEARBOX_USE is neither TRUE nor FALSE." severity error;
    end case;
    case TXPLL_DIVSEL45_FB is
      when  5   =>  TXPLL_DIVSEL45_FB_BINARY <= '1';
      when  4   =>  TXPLL_DIVSEL45_FB_BINARY <= '0';
      when others  =>  assert FALSE report "Error : TXPLL_DIVSEL45_FB is not in range 5 .. 4." severity error;
    end case;
    case TX_BUFFER_USE is
      when FALSE   =>  TX_BUFFER_USE_BINARY <= '0';
      when TRUE    =>  TX_BUFFER_USE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TX_BUFFER_USE is neither TRUE nor FALSE." severity error;
    end case;
    case TX_EN_RATE_RESET_BUF is
      when FALSE   =>  TX_EN_RATE_RESET_BUF_BINARY <= '0';
      when TRUE    =>  TX_EN_RATE_RESET_BUF_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TX_EN_RATE_RESET_BUF is neither TRUE nor FALSE." severity error;
    end case;
    case TX_OVERSAMPLE_MODE is
      when FALSE   =>  TX_OVERSAMPLE_MODE_BINARY <= '0';
      when TRUE    =>  TX_OVERSAMPLE_MODE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : TX_OVERSAMPLE_MODE is neither TRUE nor FALSE." severity error;
    end case;
    if ((CHAN_BOND_1_MAX_SKEW >= 1) and (CHAN_BOND_1_MAX_SKEW <= 14)) then
      CHAN_BOND_1_MAX_SKEW_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_1_MAX_SKEW, 4);
    else
      assert FALSE report "Error : CHAN_BOND_1_MAX_SKEW is not in range 1 .. 14." severity error;
    end if;
    if ((CHAN_BOND_2_MAX_SKEW >= 1) and (CHAN_BOND_2_MAX_SKEW <= 14)) then
      CHAN_BOND_2_MAX_SKEW_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_2_MAX_SKEW, 4);
    else
      assert FALSE report "Error : CHAN_BOND_2_MAX_SKEW is not in range 1 .. 14." severity error;
    end if;
    if ((CHAN_BOND_SEQ_LEN >= 1) and (CHAN_BOND_SEQ_LEN <= 4)) then
      CHAN_BOND_SEQ_LEN_BINARY <= CONV_STD_LOGIC_VECTOR(CHAN_BOND_SEQ_LEN, 2);
    else
      assert FALSE report "Error : CHAN_BOND_SEQ_LEN is not in range 1 .. 4." severity error;
    end if;
    if ((CLK_COR_ADJ_LEN >= 1) and (CLK_COR_ADJ_LEN <= 4)) then
      CLK_COR_ADJ_LEN_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_ADJ_LEN, 2);
    else
      assert FALSE report "Error : CLK_COR_ADJ_LEN is not in range 1 .. 4." severity error;
    end if;
    if ((CLK_COR_DET_LEN >= 1) and (CLK_COR_DET_LEN <= 4)) then
      CLK_COR_DET_LEN_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_DET_LEN, 2);
    else
      assert FALSE report "Error : CLK_COR_DET_LEN is not in range 1 .. 4." severity error;
    end if;
    if ((CLK_COR_MAX_LAT >= 3) and (CLK_COR_MAX_LAT <= 48)) then
      CLK_COR_MAX_LAT_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_MAX_LAT, 6);
    else
      assert FALSE report "Error : CLK_COR_MAX_LAT is not in range 3 .. 48." severity error;
    end if;
    if ((CLK_COR_MIN_LAT >= 3) and (CLK_COR_MIN_LAT <= 48)) then
      CLK_COR_MIN_LAT_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_MIN_LAT, 6);
    else
      assert FALSE report "Error : CLK_COR_MIN_LAT is not in range 3 .. 48." severity error;
    end if;
    if ((CLK_COR_REPEAT_WAIT >= 0) and (CLK_COR_REPEAT_WAIT <= 31)) then
      CLK_COR_REPEAT_WAIT_BINARY <= CONV_STD_LOGIC_VECTOR(CLK_COR_REPEAT_WAIT, 5);
    else
      assert FALSE report "Error : CLK_COR_REPEAT_WAIT is not in range 0 .. 31." severity error;
    end if;
    if ((RXPLL_DIVSEL_FB >= 1) and (RXPLL_DIVSEL_FB <= 20)) then
      RXPLL_DIVSEL_FB_BINARY <= CONV_STD_LOGIC_VECTOR(RXPLL_DIVSEL_FB, 5);
    else
      assert FALSE report "Error : RXPLL_DIVSEL_FB is not in range 1 .. 20." severity error;
    end if;
    if ((RXPLL_DIVSEL_OUT >= 1) and (RXPLL_DIVSEL_OUT <= 4)) then
      RXPLL_DIVSEL_OUT_BINARY <= CONV_STD_LOGIC_VECTOR(RXPLL_DIVSEL_OUT, 2);
    else
      assert FALSE report "Error : RXPLL_DIVSEL_OUT is not in range 1 .. 4." severity error;
    end if;
    if ((RXPLL_DIVSEL_REF >= 1) and (RXPLL_DIVSEL_REF <= 20)) then
      RXPLL_DIVSEL_REF_BINARY <= CONV_STD_LOGIC_VECTOR(RXPLL_DIVSEL_REF, 5);
    else
      assert FALSE report "Error : RXPLL_DIVSEL_REF is not in range 1 .. 20." severity error;
    end if;
    if ((RX_CLK25_DIVIDER >= 1) and (RX_CLK25_DIVIDER <= 32)) then
      RX_CLK25_DIVIDER_BINARY <= CONV_STD_LOGIC_VECTOR(RX_CLK25_DIVIDER, 5);
    else
      assert FALSE report "Error : RX_CLK25_DIVIDER is not in range 1 .. 32." severity error;
    end if;
    if ((RX_DATA_WIDTH >= 8) and (RX_DATA_WIDTH <= 40)) then
      RX_DATA_WIDTH_BINARY <= CONV_STD_LOGIC_VECTOR(RX_DATA_WIDTH, 3);
    else
      assert FALSE report "Error : RX_DATA_WIDTH is not in range 8 .. 40." severity error;
    end if;
    if ((RX_LOS_INVALID_INCR >= 1) and (RX_LOS_INVALID_INCR <= 128)) then
      RX_LOS_INVALID_INCR_BINARY <= CONV_STD_LOGIC_VECTOR(RX_LOS_INVALID_INCR, 3);
    else
      assert FALSE report "Error : RX_LOS_INVALID_INCR is not in range 1 .. 128." severity error;
    end if;
    if ((RX_LOS_THRESHOLD >= 4) and (RX_LOS_THRESHOLD <= 512)) then
      RX_LOS_THRESHOLD_BINARY <= CONV_STD_LOGIC_VECTOR(RX_LOS_THRESHOLD, 3);
    else
      assert FALSE report "Error : RX_LOS_THRESHOLD is not in range 4 .. 512." severity error;
    end if;
    if ((RX_SLIDE_AUTO_WAIT >= 0) and (RX_SLIDE_AUTO_WAIT <= 15)) then
      RX_SLIDE_AUTO_WAIT_BINARY <= CONV_STD_LOGIC_VECTOR(RX_SLIDE_AUTO_WAIT, 4);
    else
      assert FALSE report "Error : RX_SLIDE_AUTO_WAIT is not in range 0 .. 15." severity error;
    end if;
    if ((SAS_MAX_COMSAS >= 1) and (SAS_MAX_COMSAS <= 61)) then
      SAS_MAX_COMSAS_BINARY <= CONV_STD_LOGIC_VECTOR(SAS_MAX_COMSAS, 6);
    else
      assert FALSE report "Error : SAS_MAX_COMSAS is not in range 1 .. 61." severity error;
    end if;
    if ((SAS_MIN_COMSAS >= 1) and (SAS_MIN_COMSAS <= 61)) then
      SAS_MIN_COMSAS_BINARY <= CONV_STD_LOGIC_VECTOR(SAS_MIN_COMSAS, 6);
    else
      assert FALSE report "Error : SAS_MIN_COMSAS is not in range 1 .. 61." severity error;
    end if;
    if ((SATA_MAX_BURST >= 1) and (SATA_MAX_BURST <= 61)) then
      SATA_MAX_BURST_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_BURST, 6);
    else
      assert FALSE report "Error : SATA_MAX_BURST is not in range 1 .. 61." severity error;
    end if;
    if ((SATA_MAX_INIT >= 1) and (SATA_MAX_INIT <= 61)) then
      SATA_MAX_INIT_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_INIT, 6);
    else
      assert FALSE report "Error : SATA_MAX_INIT is not in range 1 .. 61." severity error;
    end if;
    if ((SATA_MAX_WAKE >= 1) and (SATA_MAX_WAKE <= 61)) then
      SATA_MAX_WAKE_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MAX_WAKE, 6);
    else
      assert FALSE report "Error : SATA_MAX_WAKE is not in range 1 .. 61." severity error;
    end if;
    if ((SATA_MIN_BURST >= 1) and (SATA_MIN_BURST <= 61)) then
      SATA_MIN_BURST_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_BURST, 6);
    else
      assert FALSE report "Error : SATA_MIN_BURST is not in range 1 .. 61." severity error;
    end if;
    if ((SATA_MIN_INIT >= 1) and (SATA_MIN_INIT <= 61)) then
      SATA_MIN_INIT_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_INIT, 6);
    else
      assert FALSE report "Error : SATA_MIN_INIT is not in range 1 .. 61." severity error;
    end if;
    if ((SATA_MIN_WAKE >= 1) and (SATA_MIN_WAKE <= 61)) then
      SATA_MIN_WAKE_BINARY <= CONV_STD_LOGIC_VECTOR(SATA_MIN_WAKE, 6);
    else
      assert FALSE report "Error : SATA_MIN_WAKE is not in range 1 .. 61." severity error;
    end if;
    if ((TXPLL_DIVSEL_FB >= 1) and (TXPLL_DIVSEL_FB <= 20)) then
      TXPLL_DIVSEL_FB_BINARY <= CONV_STD_LOGIC_VECTOR(TXPLL_DIVSEL_FB, 5);
    else
      assert FALSE report "Error : TXPLL_DIVSEL_FB is not in range 1 .. 20." severity error;
    end if;
    if ((TXPLL_DIVSEL_OUT >= 1) and (TXPLL_DIVSEL_OUT <= 4)) then
      TXPLL_DIVSEL_OUT_BINARY <= CONV_STD_LOGIC_VECTOR(TXPLL_DIVSEL_OUT, 2);
    else
      assert FALSE report "Error : TXPLL_DIVSEL_OUT is not in range 1 .. 4." severity error;
    end if;
    if ((TXPLL_DIVSEL_REF >= 1) and (TXPLL_DIVSEL_REF <= 20)) then
      TXPLL_DIVSEL_REF_BINARY <= CONV_STD_LOGIC_VECTOR(TXPLL_DIVSEL_REF, 5);
    else
      assert FALSE report "Error : TXPLL_DIVSEL_REF is not in range 1 .. 20." severity error;
    end if;
    if ((TX_CLK25_DIVIDER >= 1) and (TX_CLK25_DIVIDER <= 32)) then
      TX_CLK25_DIVIDER_BINARY <= CONV_STD_LOGIC_VECTOR(TX_CLK25_DIVIDER, 5);
    else
      assert FALSE report "Error : TX_CLK25_DIVIDER is not in range 1 .. 32." severity error;
    end if;
    if ((TX_DATA_WIDTH >= 8) and (TX_DATA_WIDTH <= 40)) then
      TX_DATA_WIDTH_BINARY <= CONV_STD_LOGIC_VECTOR(TX_DATA_WIDTH, 3);
    else
      assert FALSE report "Error : TX_DATA_WIDTH is not in range 8 .. 40." severity error;
    end if;
    wait;
    end process INIPROC;

    COMFINISH <= COMFINISH_out;
    COMINITDET <= COMINITDET_out;
    COMSASDET <= COMSASDET_out;
    COMWAKEDET <= COMWAKEDET_out;
    DFECLKDLYADJMON <= DFECLKDLYADJMON_out;
    DFEEYEDACMON <= DFEEYEDACMON_out;
    DFESENSCAL <= DFESENSCAL_out;
    DFETAP1MONITOR <= DFETAP1MONITOR_out;
    DFETAP2MONITOR <= DFETAP2MONITOR_out;
    DFETAP3MONITOR <= DFETAP3MONITOR_out;
    DFETAP4MONITOR <= DFETAP4MONITOR_out;
    DRDY <= DRDY_out;
    DRPDO <= DRPDO_out;
    MGTREFCLKFAB <= MGTREFCLKFAB_out;
    PHYSTATUS <= PHYSTATUS_out;
    RXBUFSTATUS <= RXBUFSTATUS_out;
    RXBYTEISALIGNED <= RXBYTEISALIGNED_out;
    RXBYTEREALIGN <= RXBYTEREALIGN_out;
    RXCHANBONDSEQ <= RXCHANBONDSEQ_out;
    RXCHANISALIGNED <= RXCHANISALIGNED_out;
    RXCHANREALIGN <= RXCHANREALIGN_out;
    RXCHARISCOMMA <= RXCHARISCOMMA_out;
    RXCHARISK <= RXCHARISK_out;
    RXCHBONDO <= RXCHBONDO_out;
    RXCLKCORCNT <= RXCLKCORCNT_out;
    RXCOMMADET <= RXCOMMADET_out;
    RXDATA <= RXDATA_out;
    RXDATAVALID <= RXDATAVALID_out;
    RXDISPERR <= RXDISPERR_out;
    RXDLYALIGNMONITOR <= RXDLYALIGNMONITOR_out;
    RXELECIDLE <= RXELECIDLE_out;
    RXHEADER <= RXHEADER_out;
    RXHEADERVALID <= RXHEADERVALID_out;
    RXLOSSOFSYNC <= RXLOSSOFSYNC_out;
    RXNOTINTABLE <= RXNOTINTABLE_out;
    RXOVERSAMPLEERR <= RXOVERSAMPLEERR_out;
    RXPLLLKDET <= RXPLLLKDET_out;
    RXPRBSERR <= RXPRBSERR_out;
    RXRATEDONE <= RXRATEDONE_out;
    RXRECCLK <= RXRECCLK_out;
    RXRECCLKPCS <= RXRECCLKPCS_out;
    RXRESETDONE <= RXRESETDONE_out;
    RXRUNDISP <= RXRUNDISP_out;
    RXSTARTOFSEQ <= RXSTARTOFSEQ_out;
    RXSTATUS <= RXSTATUS_out;
    RXVALID <= RXVALID_out;
    TSTOUT <= TSTOUT_out;
    TXBUFSTATUS <= TXBUFSTATUS_out;
    TXDLYALIGNMONITOR <= TXDLYALIGNMONITOR_out;
    TXGEARBOXREADY <= TXGEARBOXREADY_out;
    TXKERR <= TXKERR_out;
    TXN <= TXN_out;
    TXOUTCLK <= TXOUTCLK_out;
    TXOUTCLKPCS <= TXOUTCLKPCS_out;
    TXP <= TXP_out;
    TXPLLLKDET <= TXPLLLKDET_out;
    TXRATEDONE <= TXRATEDONE_out;
    TXRESETDONE <= TXRESETDONE_out;
    TXRUNDISP <= TXRUNDISP_out;
  end GTXE1_V;
