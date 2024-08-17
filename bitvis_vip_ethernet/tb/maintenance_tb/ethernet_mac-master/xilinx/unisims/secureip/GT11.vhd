----- CELL GT11 -----
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  11-Gigabit Transceiver for High-Speed I/O Simulation Model
-- /___/   /\     Filename : GT11.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/16/05 - Changed default values for some parameters and removed two parameters. Fixed CR#207101.
--    08/08/05 - Changed default parameter values for some parameters (CR 214282).
--    02/28/06 - CR#226322 - Addition of new parameters and change of default values for some parameters.
-- End Revision

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity GT11 is
generic (
		IN_DELAY : time := 0 ps;
		OUT_DELAY : VitalDelayType01 := (100 ps, 100 ps);
		ALIGN_COMMA_WORD : integer := 4;
		BANDGAPSEL : boolean := FALSE;
		BIASRESSEL : boolean := FALSE;
		CCCB_ARBITRATOR_DISABLE : boolean := FALSE;
		CHAN_BOND_LIMIT : integer := 16;
		CHAN_BOND_MODE : string := "NONE";
		CHAN_BOND_ONE_SHOT : boolean := FALSE;
		CHAN_BOND_SEQ_1_1 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_1_2 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_1_3 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_1_4 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_1_MASK : bit_vector := "1110";
		CHAN_BOND_SEQ_2_1 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_2_2 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_2_3 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_2_4 : bit_vector := "00000000000";
		CHAN_BOND_SEQ_2_MASK : bit_vector := "1110";
		CHAN_BOND_SEQ_2_USE : boolean := FALSE;
		CHAN_BOND_SEQ_LEN : integer := 1;
		CLK_CORRECT_USE : boolean := FALSE;
		CLK_COR_8B10B_DE : boolean := FALSE;
		CLK_COR_MAX_LAT : integer := 48;
		CLK_COR_MIN_LAT : integer := 36;
		CLK_COR_SEQ_1_1 : bit_vector := "00000000000";
		CLK_COR_SEQ_1_2 : bit_vector := "00000000000";
		CLK_COR_SEQ_1_3 : bit_vector := "00000000000";
		CLK_COR_SEQ_1_4 : bit_vector := "00000000000";
		CLK_COR_SEQ_1_MASK : bit_vector := "1110";
		CLK_COR_SEQ_2_1 : bit_vector := "00000000000";
		CLK_COR_SEQ_2_2 : bit_vector := "00000000000";
		CLK_COR_SEQ_2_3 : bit_vector := "00000000000";
		CLK_COR_SEQ_2_4 : bit_vector := "00000000000";
		CLK_COR_SEQ_2_MASK : bit_vector := "1110";
		CLK_COR_SEQ_2_USE : boolean := FALSE;
		CLK_COR_SEQ_DROP : boolean := FALSE;
		CLK_COR_SEQ_LEN : integer := 1;
		COMMA32 : boolean := FALSE;
		COMMA_10B_MASK : bit_vector := X"3FF";
		CYCLE_LIMIT_SEL : bit_vector := "00";
		DCDR_FILTER : bit_vector := "010";
		DEC_MCOMMA_DETECT : boolean := TRUE;
		DEC_PCOMMA_DETECT : boolean := TRUE;
		DEC_VALID_COMMA_ONLY : boolean := TRUE;
		DIGRX_FWDCLK : bit_vector := "00";
		DIGRX_SYNC_MODE : boolean := FALSE;
		ENABLE_DCDR : boolean := FALSE;
		FDET_HYS_CAL : bit_vector := "010";
		FDET_HYS_SEL : bit_vector := "100";
		FDET_LCK_CAL : bit_vector := "100";
		FDET_LCK_SEL : bit_vector := "001";
		GT11_MODE : string := "DONT_CARE";
		IREFBIASMODE : bit_vector := "11";
		LOOPCAL_WAIT : bit_vector := "00";
		MCOMMA_32B_VALUE : bit_vector := X"00000000";
		MCOMMA_DETECT : boolean := TRUE;
		OPPOSITE_SELECT : boolean := FALSE;
		PCOMMA_32B_VALUE : bit_vector := X"00000000";
		PCOMMA_DETECT : boolean := TRUE;
		PCS_BIT_SLIP : boolean := FALSE;
		PMACLKENABLE : boolean := TRUE;
		PMACOREPWRENABLE : boolean := TRUE;
		PMAIREFTRIM : bit_vector := "0111";
		PMAVBGCTRL : bit_vector := "00000";
		PMAVREFTRIM : bit_vector := "0111";
		PMA_BIT_SLIP : boolean := FALSE;
		POWER_ENABLE : boolean := TRUE;
		REPEATER : boolean := FALSE;
		RXACTST : boolean := FALSE;
		RXAFEEQ : bit_vector := "000000000";
		RXAFEPD : boolean := FALSE;
		RXAFETST : boolean := FALSE;
		RXAPD : boolean := FALSE;
		RXAREGCTRL : bit_vector := "00000";
		RXASYNCDIVIDE : bit_vector := "11";
		RXBY_32 : boolean := FALSE;
		RXCDRLOS : bit_vector := "000000";
		RXCLK0_FORCE_PMACLK : boolean := FALSE;
		RXCLKMODE : bit_vector := "110001";
		RXCLMODE : bit_vector := "00";
		RXCMADJ : bit_vector := "01";
		RXCPSEL : boolean := TRUE;
		RXCPTST : boolean := FALSE;
		RXCRCCLOCKDOUBLE : boolean := FALSE;
		RXCRCENABLE : boolean := FALSE;
		RXCRCINITVAL : bit_vector := X"00000000";
		RXCRCINVERTGEN : boolean := FALSE;
		RXCRCSAMECLOCK : boolean := FALSE;
		RXCTRL1 : bit_vector := X"200";
		RXCYCLE_LIMIT_SEL : bit_vector := "00";
		RXDATA_SEL : bit_vector := "00";
		RXDCCOUPLE : boolean := FALSE;
		RXDIGRESET : boolean := FALSE;
		RXDIGRX : boolean := FALSE;
		RXEQ : bit_vector := X"4000000000000000";
		RXFDCAL_CLOCK_DIVIDE : string := "NONE";
		RXFDET_HYS_CAL : bit_vector := "010";
		RXFDET_HYS_SEL : bit_vector := "100";
		RXFDET_LCK_CAL : bit_vector := "100";
		RXFDET_LCK_SEL : bit_vector := "001";
		RXFECONTROL1 : bit_vector := "00";
		RXFECONTROL2 : bit_vector := "000";
		RXFETUNE : bit_vector := "01";
		RXLB : boolean := FALSE;
		RXLKADJ : bit_vector := "00000";
		RXLKAPD : boolean := FALSE;
		RXLOOPCAL_WAIT : bit_vector := "00";
		RXLOOPFILT : bit_vector := "0111";
		RXMODE : bit_vector := "000000";
		RXOUTDIV2SEL : integer := 1;
		RXPD : boolean := FALSE;
		RXPDDTST : boolean := TRUE;
		RXPLLNDIVSEL : integer := 8;
		RXPMACLKSEL : string := "REFCLK1";
		RXRCPADJ : bit_vector := "011";
		RXRCPPD : boolean := FALSE;
		RXRECCLK1_USE_SYNC : boolean := FALSE;
		RXRIBADJ : bit_vector := "11";
		RXRPDPD : boolean := FALSE;
		RXRSDPD : boolean := FALSE;
		RXSLOWDOWN_CAL : bit_vector := "00";
		RXTUNE : bit_vector := X"0000";
		RXUSRDIVISOR : integer := 1;
		RXVCODAC_INIT : bit_vector := "1010000000";
		RXVCO_CTRL_ENABLE : boolean := FALSE;
		RX_BUFFER_USE : boolean := TRUE;
		RX_CLOCK_DIVIDER : bit_vector := "00";
		SAMPLE_8X : boolean := FALSE;
		SH_CNT_MAX : integer := 64;
		SH_INVALID_CNT_MAX : integer := 16;
		SLOWDOWN_CAL : bit_vector := "00";
		TXABPMACLKSEL : string := "REFCLK1";
		TXAPD : boolean := FALSE;
		TXAREFBIASSEL : boolean := TRUE;
		TXASYNCDIVIDE : bit_vector := "11";
		TXCLK0_FORCE_PMACLK : boolean := FALSE;
		TXCLKMODE : bit_vector := "1001";
		TXCLMODE : bit_vector := "00";
		TXCPSEL : boolean := TRUE;
		TXCRCCLOCKDOUBLE : boolean := FALSE;
		TXCRCENABLE : boolean := FALSE;
		TXCRCINITVAL : bit_vector := X"00000000";
		TXCRCINVERTGEN : boolean := FALSE;
		TXCRCSAMECLOCK : boolean := FALSE;
		TXCTRL1 : bit_vector := X"200";
		TXDATA_SEL : bit_vector := "00";
		TXDAT_PRDRV_DAC : bit_vector := "111";
		TXDAT_TAP_DAC : bit_vector := "10110";
		TXDIGPD : boolean := FALSE;
		TXFDCAL_CLOCK_DIVIDE : string := "NONE";
		TXHIGHSIGNALEN : boolean := TRUE;
		TXLOOPFILT : bit_vector := "0111";
		TXLVLSHFTPD : boolean := FALSE;
		TXOUTCLK1_USE_SYNC : boolean := FALSE;
		TXOUTDIV2SEL : integer := 1;
		TXPD : boolean := FALSE;
		TXPHASESEL : boolean := FALSE;
		TXPLLNDIVSEL : integer := 8;
		TXPOST_PRDRV_DAC : bit_vector := "111";
		TXPOST_TAP_DAC : bit_vector := "01110";
		TXPOST_TAP_PD : boolean := TRUE;
		TXPRE_PRDRV_DAC : bit_vector := "111";
		TXPRE_TAP_DAC : bit_vector := "00000";
		TXPRE_TAP_PD : boolean := TRUE;
		TXSLEWRATE : boolean := FALSE;
		TXTERMTRIM : bit_vector := "1100";
		TXTUNE : bit_vector := X"0000";
		TX_BUFFER_USE : boolean := TRUE;
		TX_CLOCK_DIVIDER : bit_vector := "00";
		VCODAC_INIT : bit_vector := "1010000000";
		VCO_CTRL_ENABLE : boolean := FALSE;
		VREFBIASMODE : bit_vector := "11"


--  clk-to-output path delays

  );

port (
		CHBONDO : out std_logic_vector(4 downto 0);
		COMBUSOUT : out std_logic_vector(15 downto 0);
		DO : out std_logic_vector(15 downto 0);
		DRDY : out std_ulogic;
		RXBUFERR : out std_ulogic;
		RXCALFAIL : out std_ulogic;
		RXCHARISCOMMA : out std_logic_vector(7 downto 0);
		RXCHARISK : out std_logic_vector(7 downto 0);
		RXCOMMADET : out std_ulogic;
		RXCRCOUT : out std_logic_vector(31 downto 0);
		RXCYCLELIMIT : out std_ulogic;
		RXDATA : out std_logic_vector(63 downto 0);
		RXDISPERR : out std_logic_vector(7 downto 0);
		RXLOCK : out std_ulogic;
		RXLOSSOFSYNC : out std_logic_vector(1 downto 0);
		RXMCLK : out std_ulogic;
		RXNOTINTABLE : out std_logic_vector(7 downto 0);
		RXPCSHCLKOUT : out std_ulogic;
		RXREALIGN : out std_ulogic;
		RXRECCLK1 : out std_ulogic;
		RXRECCLK2 : out std_ulogic;
		RXRUNDISP : out std_logic_vector(7 downto 0);
		RXSIGDET : out std_ulogic;
		RXSTATUS : out std_logic_vector(5 downto 0);
		TX1N : out std_ulogic;
		TX1P : out std_ulogic;
		TXBUFERR : out std_ulogic;
		TXCALFAIL : out std_ulogic;
		TXCRCOUT : out std_logic_vector(31 downto 0);
		TXCYCLELIMIT : out std_ulogic;
		TXKERR : out std_logic_vector(7 downto 0);
		TXLOCK : out std_ulogic;
		TXOUTCLK1 : out std_ulogic;
		TXOUTCLK2 : out std_ulogic;
		TXPCSHCLKOUT : out std_ulogic;
		TXRUNDISP : out std_logic_vector(7 downto 0);

		CHBONDI : in std_logic_vector(4 downto 0);
		COMBUSIN : in std_logic_vector(15 downto 0);
		DADDR : in std_logic_vector(7 downto 0);
		DCLK : in std_ulogic;
		DEN : in std_ulogic;
		DI : in std_logic_vector(15 downto 0);
		DWE : in std_ulogic;
		ENCHANSYNC : in std_ulogic;
		ENMCOMMAALIGN : in std_ulogic;
		ENPCOMMAALIGN : in std_ulogic;
		GREFCLK : in std_ulogic;
		LOOPBACK : in std_logic_vector(1 downto 0);
		POWERDOWN : in std_ulogic;
		REFCLK1 : in std_ulogic;
		REFCLK2 : in std_ulogic;
		RX1N : in std_ulogic;
		RX1P : in std_ulogic;
		RXBLOCKSYNC64B66BUSE : in std_ulogic;
		RXCLKSTABLE : in std_ulogic;
		RXCOMMADETUSE : in std_ulogic;
		RXCRCCLK : in std_ulogic;
		RXCRCDATAVALID : in std_ulogic;
		RXCRCDATAWIDTH : in std_logic_vector(2 downto 0);
		RXCRCIN : in std_logic_vector(63 downto 0);
		RXCRCINIT : in std_ulogic;
		RXCRCINTCLK : in std_ulogic;
		RXCRCPD : in std_ulogic;
		RXCRCRESET : in std_ulogic;
		RXDATAWIDTH : in std_logic_vector(1 downto 0);
		RXDEC64B66BUSE : in std_ulogic;
		RXDEC8B10BUSE : in std_ulogic;
		RXDESCRAM64B66BUSE : in std_ulogic;
		RXIGNOREBTF : in std_ulogic;
		RXINTDATAWIDTH : in std_logic_vector(1 downto 0);
		RXPMARESET : in std_ulogic;
		RXPOLARITY : in std_ulogic;
		RXRESET : in std_ulogic;
		RXSLIDE : in std_ulogic;
		RXSYNC : in std_ulogic;
		RXUSRCLK : in std_ulogic;
		RXUSRCLK2 : in std_ulogic;
		TXBYPASS8B10B : in std_logic_vector(7 downto 0);
		TXCHARDISPMODE : in std_logic_vector(7 downto 0);
		TXCHARDISPVAL : in std_logic_vector(7 downto 0);
		TXCHARISK : in std_logic_vector(7 downto 0);
		TXCLKSTABLE : in std_ulogic;
		TXCRCCLK : in std_ulogic;
		TXCRCDATAVALID : in std_ulogic;
		TXCRCDATAWIDTH : in std_logic_vector(2 downto 0);
		TXCRCIN : in std_logic_vector(63 downto 0);
		TXCRCINIT : in std_ulogic;
		TXCRCINTCLK : in std_ulogic;
		TXCRCPD : in std_ulogic;
		TXCRCRESET : in std_ulogic;
		TXDATA : in std_logic_vector(63 downto 0);
		TXDATAWIDTH : in std_logic_vector(1 downto 0);
		TXENC64B66BUSE : in std_ulogic;
		TXENC8B10BUSE : in std_ulogic;
		TXENOOB : in std_ulogic;
		TXGEARBOX64B66BUSE : in std_ulogic;
		TXINHIBIT : in std_ulogic;
		TXINTDATAWIDTH : in std_logic_vector(1 downto 0);
		TXPMARESET : in std_ulogic;
		TXPOLARITY : in std_ulogic;
		TXRESET : in std_ulogic;
		TXSCRAM64B66BUSE : in std_ulogic;
		TXSYNC : in std_ulogic;
		TXUSRCLK : in std_ulogic;
		TXUSRCLK2 : in std_ulogic
     );
end GT11;

-- Architecture body --

architecture GT11_V of GT11 is

  component GT11_SWIFT
    port (
      CHBONDO              : out std_logic_vector(4 downto 0);
      COMBUSOUT            : out std_logic_vector(15 downto 0);
      DO                   : out std_logic_vector(15 downto 0);
      DRDY                 : out std_ulogic;
      RXBUFERR             : out std_ulogic;
      RXCALFAIL            : out std_ulogic;
      RXCHARISCOMMA        : out std_logic_vector(7 downto 0);
      RXCHARISK            : out std_logic_vector(7 downto 0);
      RXCOMMADET           : out std_ulogic;
      RXCRCOUT             : out std_logic_vector(31 downto 0);
      RXCYCLELIMIT         : out std_ulogic;
      RXDATA               : out std_logic_vector(63 downto 0);
      RXDISPERR            : out std_logic_vector(7 downto 0);
      RXLOCK               : out std_ulogic;
      RXLOSSOFSYNC         : out std_logic_vector(1 downto 0);
      RXMCLK               : out std_ulogic;
      RXNOTINTABLE         : out std_logic_vector(7 downto 0);
      RXPCSHCLKOUT         : out std_ulogic;
      RXREALIGN            : out std_ulogic;
      RXRECCLK1            : out std_ulogic;
      RXRECCLK2            : out std_ulogic;
      RXRUNDISP            : out std_logic_vector(7 downto 0);
      RXSIGDET             : out std_ulogic;
      RXSTATUS             : out std_logic_vector(5 downto 0);
      TX1N                 : out std_ulogic;
      TX1P                 : out std_ulogic;
      TXBUFERR             : out std_ulogic;
      TXCALFAIL            : out std_ulogic;
      TXCRCOUT             : out std_logic_vector(31 downto 0);
      TXCYCLELIMIT         : out std_ulogic;
      TXKERR               : out std_logic_vector(7 downto 0);
      TXLOCK               : out std_ulogic;
      TXOUTCLK1            : out std_ulogic;
      TXOUTCLK2            : out std_ulogic;
      TXPCSHCLKOUT         : out std_ulogic;
      TXRUNDISP            : out std_logic_vector(7 downto 0);

      GT11_MODE : in std_logic_vector(1 downto 0);

      PMACFG : in std_logic_vector(63 downto 0);
      PMACFG2 : in std_logic_vector(63 downto 0);
      RXACLCFG : in std_logic_vector(63 downto 0);
      RXAEQCFG : in std_logic_vector(63 downto 0);
      RXAFECFG : in std_logic_vector(63 downto 0);
      synDigCfgChnBnd1 : in std_logic_vector(63 downto 0);
      synDigCfgChnBnd2 : in std_logic_vector(63 downto 0);
      synDigCfgClkCor1 : in std_logic_vector(63 downto 0);
      synDigCfgClkCor2 : in std_logic_vector(63 downto 0);
      synDigCfgComma1 : in std_logic_vector(63 downto 0);
      synDigCfgComma2 : in std_logic_vector(63 downto 0);
      synDigCfgCrc : in std_logic_vector(63 downto 0);
      synDigCfgMisc : in std_logic_vector(63 downto 0);
      synDigCfgSynPmaFD : in std_logic_vector(63 downto 0);
      TXACFG : in std_logic_vector(63 downto 0);
      TXCLCFG : in std_logic_vector(63 downto 0);                  

      CHBONDI              : in std_logic_vector(4 downto 0);
      COMBUSIN             : in std_logic_vector(15 downto 0);
      DADDR                : in std_logic_vector(7 downto 0);
      DCLK                 : in std_ulogic;
      DEN                  : in std_ulogic;
      DI                   : in std_logic_vector(15 downto 0);
      DWE                  : in std_ulogic;
      ENCHANSYNC           : in std_ulogic;
      ENMCOMMAALIGN        : in std_ulogic;
      ENPCOMMAALIGN        : in std_ulogic;
      GREFCLK              : in std_ulogic;
      GSR : in std_ulogic;
      LOOPBACK             : in std_logic_vector(1 downto 0);
      POWERDOWN            : in std_ulogic;
      REFCLK1              : in std_ulogic;
      REFCLK2              : in std_ulogic;
      RX1N                 : in std_ulogic;
      RX1P                 : in std_ulogic;
      RXBLOCKSYNC64B66BUSE : in std_ulogic;
      RXCLKSTABLE          : in std_ulogic;
      RXCOMMADETUSE        : in std_ulogic;
      RXCRCCLK             : in std_ulogic;
      RXCRCDATAVALID       : in std_ulogic;
      RXCRCDATAWIDTH       : in std_logic_vector(2 downto 0);
      RXCRCIN              : in std_logic_vector(63 downto 0);
      RXCRCINIT            : in std_ulogic;
      RXCRCINTCLK          : in std_ulogic;
      RXCRCPD              : in std_ulogic;
      RXCRCRESET           : in std_ulogic;
      RXDATAWIDTH          : in std_logic_vector(1 downto 0);
      RXDEC64B66BUSE       : in std_ulogic;
      RXDEC8B10BUSE        : in std_ulogic;
      RXDESCRAM64B66BUSE   : in std_ulogic;
      RXIGNOREBTF          : in std_ulogic;
      RXINTDATAWIDTH       : in std_logic_vector(1 downto 0);
      RXPMARESET           : in std_ulogic;
      RXPOLARITY           : in std_ulogic;
      RXRESET              : in std_ulogic;
      RXSLIDE              : in std_ulogic;
      RXSYNC               : in std_ulogic;
      RXUSRCLK             : in std_ulogic;
      RXUSRCLK2            : in std_ulogic;
      TXBYPASS8B10B        : in std_logic_vector(7 downto 0);
      TXCHARDISPMODE       : in std_logic_vector(7 downto 0);
      TXCHARDISPVAL        : in std_logic_vector(7 downto 0);
      TXCHARISK            : in std_logic_vector(7 downto 0);
      TXCLKSTABLE          : in std_ulogic;
      TXCRCCLK             : in std_ulogic;
      TXCRCDATAVALID       : in std_ulogic;
      TXCRCDATAWIDTH       : in std_logic_vector(2 downto 0);
      TXCRCIN              : in std_logic_vector(63 downto 0);
      TXCRCINIT            : in std_ulogic;
      TXCRCINTCLK          : in std_ulogic;
      TXCRCPD              : in std_ulogic;
      TXCRCRESET           : in std_ulogic;
      TXDATA               : in std_logic_vector(63 downto 0);
      TXDATAWIDTH          : in std_logic_vector(1 downto 0);
      TXENC64B66BUSE       : in std_ulogic;
      TXENC8B10BUSE        : in std_ulogic;
      TXENOOB              : in std_ulogic;
      TXGEARBOX64B66BUSE   : in std_ulogic;
      TXINHIBIT            : in std_ulogic;
      TXINTDATAWIDTH       : in std_logic_vector(1 downto 0);
      TXPMARESET           : in std_ulogic;
      TXPOLARITY           : in std_ulogic;
      TXRESET              : in std_ulogic;
      TXSCRAM64B66BUSE     : in std_ulogic;
      TXSYNC               : in std_ulogic;
      TXUSRCLK             : in std_ulogic;
      TXUSRCLK2            : in std_ulogic

    );
  end component;

-- Attribute-to-Cell mapping signals
        signal   GT11_MODE_BINARY  :  std_logic_vector(1 downto 0);


-- Input/Output Pin signals

        signal   GSR_ipd  :  std_ulogic;    
        signal   CHBONDI_ipd  :  std_logic_vector(4 downto 0);
        signal   ENCHANSYNC_ipd  :  std_ulogic;
        signal   ENMCOMMAALIGN_ipd  :  std_ulogic;
        signal   ENPCOMMAALIGN_ipd  :  std_ulogic;
        signal   LOOPBACK_ipd  :  std_logic_vector(1 downto 0);
        signal   POWERDOWN_ipd  :  std_ulogic;
        signal   RXBLOCKSYNC64B66BUSE_ipd  :  std_ulogic;
        signal   RXCOMMADETUSE_ipd  :  std_ulogic;
        signal   RXDATAWIDTH_ipd  :  std_logic_vector(1 downto 0);
        signal   RXDEC64B66BUSE_ipd  :  std_ulogic;
        signal   RXDEC8B10BUSE_ipd  :  std_ulogic;
        signal   RXDESCRAM64B66BUSE_ipd  :  std_ulogic;
        signal   RXIGNOREBTF_ipd  :  std_ulogic;
        signal   RXINTDATAWIDTH_ipd  :  std_logic_vector(1 downto 0);
        signal   RXPOLARITY_ipd  :  std_ulogic;
        signal   RXRESET_ipd  :  std_ulogic;
        signal   RXSLIDE_ipd  :  std_ulogic;
        signal   RXUSRCLK_ipd  :  std_ulogic;
        signal   RXUSRCLK2_ipd  :  std_ulogic;
        signal   TXBYPASS8B10B_ipd  :  std_logic_vector(7 downto 0);
        signal   TXCHARDISPMODE_ipd  :  std_logic_vector(7 downto 0);
        signal   TXCHARDISPVAL_ipd  :  std_logic_vector(7 downto 0);
        signal   TXCHARISK_ipd  :  std_logic_vector(7 downto 0);
        signal   TXDATA_ipd  :  std_logic_vector(63 downto 0);
        signal   TXDATAWIDTH_ipd  :  std_logic_vector(1 downto 0);
        signal   TXENC64B66BUSE_ipd  :  std_ulogic;
        signal   TXENC8B10BUSE_ipd  :  std_ulogic;
        signal   TXGEARBOX64B66BUSE_ipd  :  std_ulogic;
        signal   TXINHIBIT_ipd  :  std_ulogic;
        signal   TXINTDATAWIDTH_ipd  :  std_logic_vector(1 downto 0);
        signal   TXPOLARITY_ipd  :  std_ulogic;
        signal   TXRESET_ipd  :  std_ulogic;
        signal   TXSCRAM64B66BUSE_ipd  :  std_ulogic;
        signal   TXUSRCLK_ipd  :  std_ulogic;
        signal   TXUSRCLK2_ipd  :  std_ulogic;
        signal   RXCLKSTABLE_ipd  :  std_ulogic;
        signal   RXPMARESET_ipd  :  std_ulogic;
        signal   TXCLKSTABLE_ipd  :  std_ulogic;
        signal   TXPMARESET_ipd  :  std_ulogic;
        signal   RXCRCIN_ipd  :  std_logic_vector(63 downto 0);
        signal   RXCRCDATAWIDTH_ipd  :  std_logic_vector(2 downto 0);
        signal   RXCRCDATAVALID_ipd  :  std_ulogic;
        signal   RXCRCINIT_ipd  :  std_ulogic;
        signal   RXCRCRESET_ipd  :  std_ulogic;
        signal   RXCRCPD_ipd  :  std_ulogic;
        signal   RXCRCCLK_ipd  :  std_ulogic;
        signal   RXCRCINTCLK_ipd  :  std_ulogic;
        signal   TXCRCIN_ipd  :  std_logic_vector(63 downto 0);
        signal   TXCRCDATAWIDTH_ipd  :  std_logic_vector(2 downto 0);
        signal   TXCRCDATAVALID_ipd  :  std_ulogic;
        signal   TXCRCINIT_ipd  :  std_ulogic;
        signal   TXCRCRESET_ipd  :  std_ulogic;
        signal   TXCRCPD_ipd  :  std_ulogic;
        signal   TXCRCCLK_ipd  :  std_ulogic;
        signal   TXCRCINTCLK_ipd  :  std_ulogic;
        signal   TXSYNC_ipd  :  std_ulogic;
        signal   RXSYNC_ipd  :  std_ulogic;
        signal   TXENOOB_ipd  :  std_ulogic;
        signal   DCLK_ipd  :  std_ulogic;
        signal   DADDR_ipd  :  std_logic_vector(7 downto 0);
        signal   DEN_ipd  :  std_ulogic;
        signal   DWE_ipd  :  std_ulogic;
        signal   DI_ipd  :  std_logic_vector(15 downto 0);
        signal   RX1P_ipd  :  std_ulogic;
        signal   RX1N_ipd  :  std_ulogic;
        signal   GREFCLK_ipd  :  std_ulogic;
        signal   REFCLK1_ipd  :  std_ulogic;
        signal   REFCLK2_ipd  :  std_ulogic;
        signal   COMBUSIN_ipd  :  std_logic_vector(15 downto 0);

        signal   CHBONDO_out  :  std_logic_vector(4 downto 0);
        signal   RXSTATUS_out  :  std_logic_vector(5 downto 0);
        signal   RXCHARISCOMMA_out  :  std_logic_vector(7 downto 0);
        signal   RXCHARISK_out  :  std_logic_vector(7 downto 0);
        signal   RXCOMMADET_out  :  std_ulogic;
        signal   RXDATA_out  :  std_logic_vector(63 downto 0);
        signal   RXDISPERR_out  :  std_logic_vector(7 downto 0);
        signal   RXLOSSOFSYNC_out  :  std_logic_vector(1 downto 0);
        signal   RXNOTINTABLE_out  :  std_logic_vector(7 downto 0);
        signal   RXREALIGN_out  :  std_ulogic;
        signal   RXRUNDISP_out  :  std_logic_vector(7 downto 0);
        signal   RXBUFERR_out  :  std_ulogic;
        signal   TXBUFERR_out  :  std_ulogic;
        signal   TXKERR_out  :  std_logic_vector(7 downto 0);
        signal   TXRUNDISP_out  :  std_logic_vector(7 downto 0);
        signal   RXRECCLK1_out  :  std_ulogic;
        signal   RXRECCLK2_out  :  std_ulogic;
        signal   TXOUTCLK1_out  :  std_ulogic;
        signal   TXOUTCLK2_out  :  std_ulogic;
        signal   RXLOCK_out  :  std_ulogic;
        signal   TXLOCK_out  :  std_ulogic;
        signal   RXCYCLELIMIT_out  :  std_ulogic;
        signal   TXCYCLELIMIT_out  :  std_ulogic;
        signal   RXCALFAIL_out  :  std_ulogic;
        signal   TXCALFAIL_out  :  std_ulogic;
        signal   RXCRCOUT_out  :  std_logic_vector(31 downto 0);
        signal   TXCRCOUT_out  :  std_logic_vector(31 downto 0);
        signal   RXSIGDET_out  :  std_ulogic;
        signal   DRDY_out  :  std_ulogic;
        signal   DO_out  :  std_logic_vector(15 downto 0);
        signal   RXMCLK_out  :  std_ulogic;
        signal   TX1P_out  :  std_ulogic;
        signal   TX1N_out  :  std_ulogic;
        signal   TXPCSHCLKOUT_out  :  std_ulogic;
        signal   RXPCSHCLKOUT_out  :  std_ulogic;
        signal   COMBUSOUT_out  :  std_logic_vector(15 downto 0);

        signal PMACFG : std_logic_vector(63 downto 0);
        signal PMACFG2 : std_logic_vector(63 downto 0);
        signal RXACLCFG : std_logic_vector(63 downto 0);
        signal RXAEQCFG : std_logic_vector(63 downto 0);
        signal RXAFECFG : std_logic_vector(63 downto 0);
        signal TXACFG : std_logic_vector(63 downto 0);
        signal TXCLCFG : std_logic_vector(63 downto 0);
        signal synDigCfgChnBnd1 : std_logic_vector(63 downto 0);
        signal synDigCfgChnBnd2 : std_logic_vector(63 downto 0);
        signal synDigCfgClkCor1 : std_logic_vector(63 downto 0);
        signal synDigCfgClkCor2 : std_logic_vector(63 downto 0);
        signal synDigCfgComma1 : std_logic_vector(63 downto 0);
        signal synDigCfgComma2 : std_logic_vector(63 downto 0);
        signal synDigCfgCrc : std_logic_vector(63 downto 0);
        signal synDigCfgMisc : std_logic_vector(63 downto 0);
        signal synDigCfgSynPmaFD : std_logic_vector(63 downto 0);               


begin

   GSR_ipd <= GSR;  
   CHBONDI_ipd <= CHBONDI after IN_DELAY;
   ENCHANSYNC_ipd <= ENCHANSYNC after IN_DELAY;
   ENMCOMMAALIGN_ipd <= ENMCOMMAALIGN after IN_DELAY;
   ENPCOMMAALIGN_ipd <= ENPCOMMAALIGN after IN_DELAY;
   LOOPBACK_ipd <= LOOPBACK after IN_DELAY;
   POWERDOWN_ipd <= POWERDOWN after IN_DELAY;
   RXBLOCKSYNC64B66BUSE_ipd <= RXBLOCKSYNC64B66BUSE after IN_DELAY;
   RXCOMMADETUSE_ipd <= RXCOMMADETUSE after IN_DELAY;
   RXDATAWIDTH_ipd <= RXDATAWIDTH after IN_DELAY;
   RXDEC64B66BUSE_ipd <= RXDEC64B66BUSE after IN_DELAY;
   RXDEC8B10BUSE_ipd <= RXDEC8B10BUSE after IN_DELAY;
   RXDESCRAM64B66BUSE_ipd <= RXDESCRAM64B66BUSE after IN_DELAY;
   RXIGNOREBTF_ipd <= RXIGNOREBTF after IN_DELAY;
   RXINTDATAWIDTH_ipd <= RXINTDATAWIDTH after IN_DELAY;
   RXPOLARITY_ipd <= RXPOLARITY after IN_DELAY;
   RXRESET_ipd <= RXRESET after IN_DELAY;
   RXSLIDE_ipd <= RXSLIDE after IN_DELAY;
   RXUSRCLK_ipd <= RXUSRCLK after IN_DELAY;
   RXUSRCLK2_ipd <= RXUSRCLK2 after IN_DELAY;
   TXBYPASS8B10B_ipd <= TXBYPASS8B10B after IN_DELAY;
   TXCHARDISPMODE_ipd <= TXCHARDISPMODE after IN_DELAY;
   TXCHARDISPVAL_ipd <= TXCHARDISPVAL after IN_DELAY;
   TXCHARISK_ipd <= TXCHARISK after IN_DELAY;
   TXDATA_ipd <= TXDATA after IN_DELAY;
   TXDATAWIDTH_ipd <= TXDATAWIDTH after IN_DELAY;
   TXENC64B66BUSE_ipd <= TXENC64B66BUSE after IN_DELAY;
   TXENC8B10BUSE_ipd <= TXENC8B10BUSE after IN_DELAY;
   TXGEARBOX64B66BUSE_ipd <= TXGEARBOX64B66BUSE after IN_DELAY;
   TXINHIBIT_ipd <= TXINHIBIT after IN_DELAY;
   TXINTDATAWIDTH_ipd <= TXINTDATAWIDTH after IN_DELAY;
   TXPOLARITY_ipd <= TXPOLARITY after IN_DELAY;
   TXRESET_ipd <= TXRESET after IN_DELAY;
   TXSCRAM64B66BUSE_ipd <= TXSCRAM64B66BUSE after IN_DELAY;
   TXUSRCLK_ipd <= TXUSRCLK after IN_DELAY;
   TXUSRCLK2_ipd <= TXUSRCLK2 after IN_DELAY;
   RXCLKSTABLE_ipd <= RXCLKSTABLE after IN_DELAY;
   RXPMARESET_ipd <= RXPMARESET after IN_DELAY;
   TXCLKSTABLE_ipd <= TXCLKSTABLE after IN_DELAY;
   TXPMARESET_ipd <= TXPMARESET after IN_DELAY;
   RXCRCIN_ipd <= RXCRCIN after IN_DELAY;
   RXCRCDATAWIDTH_ipd <= RXCRCDATAWIDTH after IN_DELAY;
   RXCRCDATAVALID_ipd <= RXCRCDATAVALID after IN_DELAY;
   RXCRCINIT_ipd <= RXCRCINIT after IN_DELAY;
   RXCRCRESET_ipd <= RXCRCRESET after IN_DELAY;
   RXCRCPD_ipd <= RXCRCPD after IN_DELAY;
   RXCRCCLK_ipd <= RXCRCCLK after IN_DELAY;
   RXCRCINTCLK_ipd <= RXCRCINTCLK after IN_DELAY;
   TXCRCIN_ipd <= TXCRCIN after IN_DELAY;
   TXCRCDATAWIDTH_ipd <= TXCRCDATAWIDTH after IN_DELAY;
   TXCRCDATAVALID_ipd <= TXCRCDATAVALID after IN_DELAY;
   TXCRCINIT_ipd <= TXCRCINIT after IN_DELAY;
   TXCRCRESET_ipd <= TXCRCRESET after IN_DELAY;
   TXCRCPD_ipd <= TXCRCPD after IN_DELAY;
   TXCRCCLK_ipd <= TXCRCCLK after IN_DELAY;
   TXCRCINTCLK_ipd <= TXCRCINTCLK after IN_DELAY;
   TXSYNC_ipd <= TXSYNC after IN_DELAY;
   RXSYNC_ipd <= RXSYNC after IN_DELAY;
   TXENOOB_ipd <= TXENOOB after IN_DELAY;
   DCLK_ipd <= DCLK after IN_DELAY;
   DADDR_ipd <= DADDR after IN_DELAY;
   DEN_ipd <= DEN after IN_DELAY;
   DWE_ipd <= DWE after IN_DELAY;
   DI_ipd <= DI after IN_DELAY;
   RX1P_ipd <= RX1P after IN_DELAY;
   RX1N_ipd <= RX1N after IN_DELAY;
   GREFCLK_ipd <= GREFCLK after IN_DELAY;
   REFCLK1_ipd <= REFCLK1 after IN_DELAY;
   REFCLK2_ipd <= REFCLK2 after IN_DELAY;
   COMBUSIN_ipd <= COMBUSIN after IN_DELAY;

   gt11_swift_bw_1 : GT11_SWIFT
      port map (
CHBONDO => CHBONDO_OUT,
COMBUSOUT => COMBUSOUT_OUT,
DO => DO_OUT,
DRDY => DRDY_OUT,
RXBUFERR => RXBUFERR_OUT,
RXCALFAIL => RXCALFAIL_OUT,
RXCHARISCOMMA => RXCHARISCOMMA_OUT,
RXCHARISK => RXCHARISK_OUT,
RXCOMMADET => RXCOMMADET_OUT,
RXCRCOUT => RXCRCOUT_OUT,
RXCYCLELIMIT => RXCYCLELIMIT_OUT,
RXDATA => RXDATA_OUT,
RXDISPERR => RXDISPERR_OUT,
RXLOCK => RXLOCK_OUT,
RXLOSSOFSYNC => RXLOSSOFSYNC_OUT,
RXMCLK => RXMCLK_OUT,
RXNOTINTABLE => RXNOTINTABLE_OUT,
RXPCSHCLKOUT => RXPCSHCLKOUT_OUT,
RXREALIGN => RXREALIGN_OUT,
RXRECCLK1 => RXRECCLK1_OUT,
RXRECCLK2 => RXRECCLK2_OUT,
RXRUNDISP => RXRUNDISP_OUT,
RXSIGDET => RXSIGDET_OUT,
RXSTATUS => RXSTATUS_OUT,
TX1N => TX1N_OUT,
TX1P => TX1P_OUT,
TXBUFERR => TXBUFERR_OUT,
TXCALFAIL => TXCALFAIL_OUT,
TXCRCOUT => TXCRCOUT_OUT,
TXCYCLELIMIT => TXCYCLELIMIT_OUT,
TXKERR => TXKERR_OUT,
TXLOCK => TXLOCK_OUT,
TXOUTCLK1 => TXOUTCLK1_OUT,
TXOUTCLK2 => TXOUTCLK2_OUT,
TXPCSHCLKOUT => TXPCSHCLKOUT_OUT,
TXRUNDISP => TXRUNDISP_OUT,

GT11_MODE => GT11_MODE_BINARY,

PMACFG2 => PMACFG2,
PMACFG => PMACFG,
RXACLCFG => RXACLCFG,
RXAEQCFG => RXAEQCFG,
RXAFECFG => RXAFECFG,
synDigCfgChnBnd1 => synDigCfgChnBnd1,
synDigCfgChnBnd2 => synDigCfgChnBnd2,
synDigCfgClkCor1 => synDigCfgClkCor1,
synDigCfgClkCor2 => synDigCfgClkCor2,
synDigCfgComma1 => synDigCfgComma1,
synDigCfgComma2 => synDigCfgComma2,
synDigCfgCrc => synDigCfgCrc,
synDigCfgMisc => synDigCfgMisc,
synDigCfgSynPmaFD => synDigCfgSynPmaFD,
TXACFG => TXACFG,
TXCLCFG => TXCLCFG,

CHBONDI => CHBONDI_ipd,
COMBUSIN => COMBUSIN_ipd,
DADDR => DADDR_ipd,
DCLK => DCLK_ipd,
DEN => DEN_ipd,
DI => DI_ipd,
DWE => DWE_ipd,
ENCHANSYNC => ENCHANSYNC_ipd,
ENMCOMMAALIGN => ENMCOMMAALIGN_ipd,
ENPCOMMAALIGN => ENPCOMMAALIGN_ipd,
GREFCLK => GREFCLK_ipd,
GSR => GSR_ipd,
LOOPBACK => LOOPBACK_ipd,
POWERDOWN => POWERDOWN_ipd,
REFCLK1 => REFCLK1_ipd,
REFCLK2 => REFCLK2_ipd,
RX1N => RX1N_ipd,
RX1P => RX1P_ipd,
RXBLOCKSYNC64B66BUSE => RXBLOCKSYNC64B66BUSE_ipd,
RXCLKSTABLE => RXCLKSTABLE_ipd,
RXCOMMADETUSE => RXCOMMADETUSE_ipd,
RXCRCCLK => RXCRCCLK_ipd,
RXCRCDATAVALID => RXCRCDATAVALID_ipd,
RXCRCDATAWIDTH => RXCRCDATAWIDTH_ipd,
RXCRCIN => RXCRCIN_ipd,
RXCRCINIT => RXCRCINIT_ipd,
RXCRCINTCLK => RXCRCINTCLK_ipd,
RXCRCPD => RXCRCPD_ipd,
RXCRCRESET => RXCRCRESET_ipd,
RXDATAWIDTH => RXDATAWIDTH_ipd,
RXDEC8B10BUSE => RXDEC8B10BUSE_ipd,
RXDEC64B66BUSE => RXDEC64B66BUSE_ipd,
RXDESCRAM64B66BUSE => RXDESCRAM64B66BUSE_ipd,
RXIGNOREBTF => RXIGNOREBTF_ipd,
RXINTDATAWIDTH => RXINTDATAWIDTH_ipd,
RXPMARESET => RXPMARESET_ipd,
RXPOLARITY => RXPOLARITY_ipd,
RXRESET => RXRESET_ipd,
RXSLIDE => RXSLIDE_ipd,
RXSYNC => RXSYNC_ipd,
RXUSRCLK => RXUSRCLK_ipd,
RXUSRCLK2 => RXUSRCLK2_ipd,
TXBYPASS8B10B => TXBYPASS8B10B_ipd,
TXCHARDISPMODE => TXCHARDISPMODE_ipd,
TXCHARDISPVAL => TXCHARDISPVAL_ipd,
TXCHARISK => TXCHARISK_ipd,
TXCLKSTABLE => TXCLKSTABLE_ipd,
TXCRCCLK => TXCRCCLK_ipd,
TXCRCDATAVALID => TXCRCDATAVALID_ipd,
TXCRCDATAWIDTH => TXCRCDATAWIDTH_ipd,
TXCRCIN => TXCRCIN_ipd,
TXCRCINIT => TXCRCINIT_ipd,
TXCRCINTCLK => TXCRCINTCLK_ipd,
TXCRCPD => TXCRCPD_ipd,
TXCRCRESET => TXCRCRESET_ipd,
TXDATA => TXDATA_ipd,
TXDATAWIDTH => TXDATAWIDTH_ipd,
TXENC8B10BUSE => TXENC8B10BUSE_ipd,
TXENC64B66BUSE => TXENC64B66BUSE_ipd,
TXENOOB => TXENOOB_ipd,
TXGEARBOX64B66BUSE => TXGEARBOX64B66BUSE_ipd,
TXINHIBIT => TXINHIBIT_ipd,
TXINTDATAWIDTH => TXINTDATAWIDTH_ipd,
TXPMARESET => TXPMARESET_ipd,
TXPOLARITY => TXPOLARITY_ipd,
TXRESET => TXRESET_ipd,
TXSCRAM64B66BUSE => TXSCRAM64B66BUSE_ipd,
TXSYNC => TXSYNC_ipd,
TXUSRCLK => TXUSRCLK_ipd,
TXUSRCLK2 => TXUSRCLK2_ipd
      );

   INIPROC : process
        variable   CHAN_BOND_SEQ_1_1_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_1);
        variable   CHAN_BOND_SEQ_1_2_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_2);
        variable   CHAN_BOND_SEQ_1_3_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_3);
        variable   CHAN_BOND_SEQ_1_4_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_4);
        variable   CHAN_BOND_SEQ_1_MASK_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_1_MASK);
        variable   CHAN_BOND_LIMIT_BINARY  :  std_logic_vector(5 downto 0);
        variable   CHAN_BOND_MODE_BINARY  :  std_logic_vector(1 downto 0);
        variable   CHAN_BOND_ONE_SHOT_BINARY  :  std_ulogic;
        variable   CHAN_BOND_SEQ_2_USE_BINARY  :  std_ulogic;
        variable   CHAN_BOND_SEQ_LEN_BINARY  :  std_logic_vector(2 downto 0);
        variable   RX_BUFFER_USE_BINARY  :  std_ulogic;
        variable   TX_BUFFER_USE_BINARY  :  std_ulogic;
        variable   CHAN_BOND_SEQ_2_1_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_1);
        variable   CHAN_BOND_SEQ_2_2_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_2);
        variable   CHAN_BOND_SEQ_2_3_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_3);
        variable   CHAN_BOND_SEQ_2_4_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_4);
        variable   CHAN_BOND_SEQ_2_MASK_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CHAN_BOND_SEQ_2_MASK);
        variable   POWER_ENABLE_BINARY  :  std_ulogic;
        variable   OPPOSITE_SELECT_BINARY  :  std_ulogic;
        variable   CCCB_ARBITRATOR_DISABLE_BINARY  :  std_ulogic;
        variable   CLK_COR_SEQ_1_1_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_1);
        variable   CLK_COR_SEQ_1_2_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_2);
        variable   CLK_COR_SEQ_1_3_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_3);
        variable   CLK_COR_SEQ_1_4_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_4);
        variable   CLK_COR_SEQ_1_MASK_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_1_MASK);
        variable   DIGRX_SYNC_MODE_BINARY  :  std_ulogic;
        variable   DIGRX_FWDCLK_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(DIGRX_FWDCLK);
        variable   PCS_BIT_SLIP_BINARY  :  std_ulogic;
        variable   CLK_COR_MIN_LAT_BINARY  :  std_logic_vector(5 downto 0);
        variable   TXDATA_SEL_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(TXDATA_SEL);
        variable   RXDATA_SEL_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXDATA_SEL);
        variable   CLK_COR_SEQ_2_1_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_1);
        variable   CLK_COR_SEQ_2_2_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_2);
        variable   CLK_COR_SEQ_2_3_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_3);
        variable   CLK_COR_SEQ_2_4_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_4);
        variable   CLK_COR_SEQ_2_MASK_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(CLK_COR_SEQ_2_MASK);
        variable   CLK_COR_MAX_LAT_BINARY  :  std_logic_vector(5 downto 0);
        variable   CLK_COR_SEQ_2_USE_BINARY  :  std_ulogic;
        variable   CLK_COR_SEQ_DROP_BINARY  :  std_ulogic;
        variable   CLK_COR_SEQ_LEN_BINARY  :  std_logic_vector(2 downto 0);
        variable   CLK_CORRECT_USE_BINARY  :  std_ulogic;
        variable   CLK_COR_8B10B_DE_BINARY  :  std_ulogic;
        variable   SH_CNT_MAX_BINARY  :  std_logic_vector(7 downto 0);
        variable   SH_INVALID_CNT_MAX_BINARY  :  std_logic_vector(7 downto 0);
        variable   ALIGN_COMMA_WORD_BINARY  :  std_logic_vector(1 downto 0);
        variable   DEC_MCOMMA_DETECT_BINARY  :  std_ulogic;
        variable   DEC_PCOMMA_DETECT_BINARY  :  std_ulogic;
        variable   DEC_VALID_COMMA_ONLY_BINARY  :  std_ulogic;
        variable   MCOMMA_DETECT_BINARY  :  std_ulogic;
        variable   PCOMMA_DETECT_BINARY  :  std_ulogic;
        variable   COMMA32_BINARY  :  std_ulogic;
        variable   COMMA_10B_MASK_BINARY  :  std_logic_vector(9 downto 0) := (To_StdLogicVector(COMMA_10B_MASK)(9 downto 0));
        variable   MCOMMA_32B_VALUE_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(MCOMMA_32B_VALUE);
        variable   PCOMMA_32B_VALUE_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(PCOMMA_32B_VALUE);
        variable   RXUSRDIVISOR_BINARY  :  std_logic_vector(4 downto 0);
        variable   DCDR_FILTER_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(DCDR_FILTER);
        variable   SAMPLE_8X_BINARY  :  std_ulogic;
        variable   ENABLE_DCDR_BINARY  :  std_ulogic;
        variable   REPEATER_BINARY  :  std_ulogic;
        variable   RXBY_32_BINARY  :  std_ulogic;
        variable   TXFDCAL_CLOCK_DIVIDE_BINARY  :  std_logic_vector(1 downto 0);
        variable   RXFDCAL_CLOCK_DIVIDE_BINARY  :  std_logic_vector(1 downto 0);
        variable   RXCYCLE_LIMIT_SEL_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXCYCLE_LIMIT_SEL);
        variable   RXVCO_CTRL_ENABLE_BINARY  :  std_ulogic;
        variable   RXFDET_LCK_SEL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(RXFDET_LCK_SEL);
        variable   RXFDET_HYS_SEL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(RXFDET_HYS_SEL);
        variable   RXFDET_LCK_CAL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(RXFDET_LCK_CAL);
        variable   RXFDET_HYS_CAL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(RXFDET_HYS_CAL);
        variable   RXLOOPCAL_WAIT_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXLOOPCAL_WAIT);
        variable   RXSLOWDOWN_CAL_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXSLOWDOWN_CAL);
        variable   RXVCODAC_INIT_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(RXVCODAC_INIT);
        variable   CYCLE_LIMIT_SEL_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(CYCLE_LIMIT_SEL);
        variable   VCO_CTRL_ENABLE_BINARY  :  std_ulogic;
        variable   FDET_LCK_SEL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(FDET_LCK_SEL);
        variable   FDET_HYS_SEL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(FDET_HYS_SEL);
        variable   FDET_LCK_CAL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(FDET_LCK_CAL);
        variable   FDET_HYS_CAL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(FDET_HYS_CAL);
        variable   LOOPCAL_WAIT_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(LOOPCAL_WAIT);
        variable   SLOWDOWN_CAL_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(SLOWDOWN_CAL);
        variable   VCODAC_INIT_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(VCODAC_INIT);
        variable   RXCRCCLOCKDOUBLE_BINARY  :  std_ulogic;
        variable   RXCRCINVERTGEN_BINARY  :  std_ulogic;
        variable   RXCRCSAMECLOCK_BINARY  :  std_ulogic;
        variable   RXCRCENABLE_BINARY  :  std_ulogic;
        variable   RXCRCINITVAL_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(RXCRCINITVAL);
        variable   TXCRCCLOCKDOUBLE_BINARY  :  std_ulogic;
        variable   TXCRCINVERTGEN_BINARY  :  std_ulogic;
        variable   TXCRCSAMECLOCK_BINARY  :  std_ulogic;
        variable   TXCRCINITVAL_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(TXCRCINITVAL);
        variable   TXCRCENABLE_BINARY  :  std_ulogic;
        variable   RX_CLOCK_DIVIDER_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RX_CLOCK_DIVIDER);
        variable   TX_CLOCK_DIVIDER_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(TX_CLOCK_DIVIDER);
        variable   RXCLK0_FORCE_PMACLK_BINARY  :  std_ulogic;
        variable   TXCLK0_FORCE_PMACLK_BINARY  :  std_ulogic;
        variable   TXOUTCLK1_USE_SYNC_BINARY  :  std_ulogic;
        variable   RXRECCLK1_USE_SYNC_BINARY  :  std_ulogic;
        variable   RXPMACLKSEL_BINARY  :  std_logic_vector(1 downto 0);
        variable   TXABPMACLKSEL_BINARY  :  std_logic_vector(1 downto 0);
        variable   RXAREGCTRL_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(RXAREGCTRL);
        variable   PMAVBGCTRL_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(PMAVBGCTRL);
        variable   BANDGAPSEL_BINARY  :  std_ulogic;
        variable   PMAIREFTRIM_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(PMAIREFTRIM);
        variable   IREFBIASMODE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(IREFBIASMODE);
        variable   BIASRESSEL_BINARY  :  std_ulogic;
        variable   PMAVREFTRIM_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(PMAVREFTRIM);
        variable   VREFBIASMODE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(VREFBIASMODE);
        variable   TXPHASESEL_BINARY  :  std_ulogic;
        variable   PMACLKENABLE_BINARY  :  std_ulogic;
        variable   PMACOREPWRENABLE_BINARY  :  std_ulogic;
        variable   RXMODE_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(RXMODE);
        variable   PMA_BIT_SLIP_BINARY  :  std_ulogic;
        variable   RXASYNCDIVIDE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXASYNCDIVIDE);
        variable   RXCLKMODE_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(RXCLKMODE);
        variable   RXLB_BINARY  :  std_ulogic;
        variable   RXFETUNE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXFETUNE);
        variable   RXRCPADJ_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(RXRCPADJ);
        variable   RXRIBADJ_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXRIBADJ);
        variable   RXAFEEQ_BINARY  :  std_logic_vector(8 downto 0) := To_StdLogicVector(RXAFEEQ);
        variable   RXCMADJ_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXCMADJ);
        variable   RXCDRLOS_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(RXCDRLOS);
        variable   RXDCCOUPLE_BINARY  :  std_ulogic;
        variable   RXLKADJ_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(RXLKADJ);
        variable   RXDIGRESET_BINARY  :  std_ulogic;
        variable   RXFECONTROL2_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(RXFECONTROL2);
        variable   RXCPTST_BINARY  :  std_ulogic;
        variable   RXPDDTST_BINARY  :  std_ulogic;
        variable   RXACTST_BINARY  :  std_ulogic;
        variable   RXAFETST_BINARY  :  std_ulogic;
        variable   RXFECONTROL1_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXFECONTROL1);
        variable   RXLKAPD_BINARY  :  std_ulogic;
        variable   RXRSDPD_BINARY  :  std_ulogic;
        variable   RXRCPPD_BINARY  :  std_ulogic;
        variable   RXRPDPD_BINARY  :  std_ulogic;
        variable   RXAFEPD_BINARY  :  std_ulogic;
        variable   RXPD_BINARY  :  std_ulogic;
        variable   RXEQ_BINARY  :  std_logic_vector(63 downto 0) := To_StdLogicVector(RXEQ);
        variable   TXOUTDIV2SEL_BINARY  :  std_logic_vector(3 downto 0);
        variable   TXPLLNDIVSEL_BINARY  :  std_logic_vector(3 downto 0);
        variable   TXCLMODE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(TXCLMODE);
        variable   TXLOOPFILT_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(TXLOOPFILT);
        variable   TXTUNE_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(TXTUNE)(12 downto 0);
        variable   TXCPSEL_BINARY  :  std_ulogic;
        variable   TXCTRL1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(TXCTRL1)(9 downto 0);
        variable   TXAPD_BINARY  :  std_ulogic;
        variable   TXLVLSHFTPD_BINARY  :  std_ulogic;
        variable   TXPRE_PRDRV_DAC_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(TXPRE_PRDRV_DAC);
        variable   TXPRE_TAP_PD_BINARY  :  std_ulogic;
        variable   TXPRE_TAP_DAC_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(TXPRE_TAP_DAC);
        variable   TXDIGPD_BINARY  :  std_ulogic;
        variable   TXCLKMODE_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(TXCLKMODE);
        variable   TXHIGHSIGNALEN_BINARY  :  std_ulogic;
        variable   TXAREFBIASSEL_BINARY  :  std_ulogic;
        variable   TXTERMTRIM_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(TXTERMTRIM);
        variable   TXASYNCDIVIDE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(TXASYNCDIVIDE);
        variable   TXSLEWRATE_BINARY  :  std_ulogic;
        variable   TXPOST_PRDRV_DAC_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(TXPOST_PRDRV_DAC);
        variable   TXDAT_PRDRV_DAC_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(TXDAT_PRDRV_DAC);
        variable   TXPOST_TAP_PD_BINARY  :  std_ulogic;
        variable   TXPOST_TAP_DAC_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(TXPOST_TAP_DAC);
        variable   TXDAT_TAP_DAC_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(TXDAT_TAP_DAC);
        variable   TXPD_BINARY  :  std_ulogic;
        variable   RXOUTDIV2SEL_BINARY  :  std_logic_vector(7 downto 0);
        variable   RXPLLNDIVSEL_BINARY  :  std_logic_vector(3 downto 0);
        variable   RXCLMODE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(RXCLMODE);
        variable   RXLOOPFILT_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(RXLOOPFILT);
        variable   RXDIGRX_BINARY  :  std_ulogic;
        variable   RXTUNE_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(RXTUNE)(12 downto 0);
        variable   RXCPSEL_BINARY  :  std_ulogic;
        variable   RXCTRL1_BINARY  :  std_logic_vector(9 downto 0) := To_StdLogicVector(RXCTRL1)(9 downto 0);
        variable   RXAPD_BINARY  :  std_ulogic;     
     begin
--     case GT11_MODE is
           if((GT11_MODE = "B") or (GT11_MODE = "b")) then       
               GT11_MODE_BINARY <= "00";
           elsif((GT11_MODE = "A") or (GT11_MODE = "a")) then
               GT11_MODE_BINARY <= "01";
           elsif((GT11_MODE = "DONT_CARE") or (GT11_MODE = "dont_care")) then
               GT11_MODE_BINARY <= "10";
           elsif((GT11_MODE = "SINGLE") or (GT11_MODE = "single")) then
               GT11_MODE_BINARY <= "11";
           else
             assert FALSE report "Error : GT11_MODE = is not DONT_CARE, A, B, SINGLE." severity error;
           end if;
--     end case;
       case CHAN_BOND_LIMIT is
           when   0  =>  CHAN_BOND_LIMIT_BINARY := "000000";
           when   1  =>  CHAN_BOND_LIMIT_BINARY := "000001";
           when   2  =>  CHAN_BOND_LIMIT_BINARY := "000010";
           when   3  =>  CHAN_BOND_LIMIT_BINARY := "000011";
           when   4  =>  CHAN_BOND_LIMIT_BINARY := "000100";
           when   5  =>  CHAN_BOND_LIMIT_BINARY := "000101";
           when   6  =>  CHAN_BOND_LIMIT_BINARY := "000110";
           when   7  =>  CHAN_BOND_LIMIT_BINARY := "000111";
           when   8  =>  CHAN_BOND_LIMIT_BINARY := "001000";
           when   9  =>  CHAN_BOND_LIMIT_BINARY := "001001";
           when   10  =>  CHAN_BOND_LIMIT_BINARY := "001010";
           when   11  =>  CHAN_BOND_LIMIT_BINARY := "001011";
           when   12  =>  CHAN_BOND_LIMIT_BINARY := "001100";
           when   13  =>  CHAN_BOND_LIMIT_BINARY := "001101";
           when   14  =>  CHAN_BOND_LIMIT_BINARY := "001110";
           when   15  =>  CHAN_BOND_LIMIT_BINARY := "001111";
           when   16  =>  CHAN_BOND_LIMIT_BINARY := "010000";
           when   17  =>  CHAN_BOND_LIMIT_BINARY := "010001";
           when   18  =>  CHAN_BOND_LIMIT_BINARY := "010010";
           when   19  =>  CHAN_BOND_LIMIT_BINARY := "010011";
           when   20  =>  CHAN_BOND_LIMIT_BINARY := "010100";
           when   21  =>  CHAN_BOND_LIMIT_BINARY := "010101";
           when   22  =>  CHAN_BOND_LIMIT_BINARY := "010110";
           when   23  =>  CHAN_BOND_LIMIT_BINARY := "010111";
           when   24  =>  CHAN_BOND_LIMIT_BINARY := "011000";
           when   25  =>  CHAN_BOND_LIMIT_BINARY := "011001";
           when   26  =>  CHAN_BOND_LIMIT_BINARY := "011010";
           when   27  =>  CHAN_BOND_LIMIT_BINARY := "011011";
           when   28  =>  CHAN_BOND_LIMIT_BINARY := "011100";
           when   29  =>  CHAN_BOND_LIMIT_BINARY := "011101";
           when   30  =>  CHAN_BOND_LIMIT_BINARY := "011110";
           when   31  =>  CHAN_BOND_LIMIT_BINARY := "011111";
           when others  =>  assert FALSE report "Error : CHAN_BOND_LIMIT is not in range 0...31." severity error;
       end case;
--     case CHAN_BOND_MODE is
           if((CHAN_BOND_MODE = "NONE") or (CHAN_BOND_MODE = "none")) then
               CHAN_BOND_MODE_BINARY := "00";
           elsif((CHAN_BOND_MODE = "MASTER") or (CHAN_BOND_MODE = "master")) then
               CHAN_BOND_MODE_BINARY := "01";
           elsif((CHAN_BOND_MODE = "SLAVE_1_HOP") or (CHAN_BOND_MODE = "slave_1_hop")) then
               CHAN_BOND_MODE_BINARY := "10";
           elsif((CHAN_BOND_MODE = "SLAVE_2_HOPS") or (CHAN_BOND_MODE = "slave_2_hops")) then
               CHAN_BOND_MODE_BINARY := "11";
           else
             assert FALSE report "Error : CHAN_BOND_MODE = is not NONE, MASTER, SLAVE_1_HOP, SLAVE_2_HOPS." severity error;
           end if;
--     end case;
       case CHAN_BOND_ONE_SHOT is
           when FALSE   =>  CHAN_BOND_ONE_SHOT_BINARY := '0';
           when TRUE    =>  CHAN_BOND_ONE_SHOT_BINARY := '1';
           when others  =>  assert FALSE report "Error : CHAN_BOND_ONE_SHOT is neither TRUE nor FALSE." severity error;
       end case;
       case CHAN_BOND_SEQ_2_USE is
           when FALSE   =>  CHAN_BOND_SEQ_2_USE_BINARY := '0';
           when TRUE    =>  CHAN_BOND_SEQ_2_USE_BINARY := '1';
           when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_2_USE is neither TRUE nor FALSE." severity error;
       end case;
       case CHAN_BOND_SEQ_LEN is
           when   1  =>  CHAN_BOND_SEQ_LEN_BINARY := "000";
           when   2  =>  CHAN_BOND_SEQ_LEN_BINARY := "001";
           when   3  =>  CHAN_BOND_SEQ_LEN_BINARY := "010";
           when   4  =>  CHAN_BOND_SEQ_LEN_BINARY := "011";
           when   8  =>  CHAN_BOND_SEQ_LEN_BINARY := "111";
           when others  =>  assert FALSE report "Error : CHAN_BOND_SEQ_LEN is not in 1, 2, 3, 4, 8." severity error;
       end case;
       case RX_BUFFER_USE is
           when FALSE   =>  RX_BUFFER_USE_BINARY := '0';
           when TRUE    =>  RX_BUFFER_USE_BINARY := '1';
           when others  =>  assert FALSE report "Error : RX_BUFFER_USE is neither TRUE nor FALSE." severity error;
       end case;
       case TX_BUFFER_USE is
           when FALSE   =>  TX_BUFFER_USE_BINARY := '0';
           when TRUE    =>  TX_BUFFER_USE_BINARY := '1';
           when others  =>  assert FALSE report "Error : TX_BUFFER_USE is neither TRUE nor FALSE." severity error;
       end case;
       case POWER_ENABLE is
           when FALSE   =>  POWER_ENABLE_BINARY := '0';
           when TRUE    =>  POWER_ENABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : POWER_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case OPPOSITE_SELECT is
           when FALSE   =>  OPPOSITE_SELECT_BINARY := '0';
           when TRUE    =>  OPPOSITE_SELECT_BINARY := '1';
           when others  =>  assert FALSE report "Error : OPPOSITE_SELECT is neither TRUE nor FALSE." severity error;
       end case;
       case CCCB_ARBITRATOR_DISABLE is
           when FALSE   =>  CCCB_ARBITRATOR_DISABLE_BINARY := '0';
           when TRUE    =>  CCCB_ARBITRATOR_DISABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : CCCB_ARBITRATOR_DISABLE is neither TRUE nor FALSE." severity error;
       end case;
       case DIGRX_SYNC_MODE is
           when FALSE   =>  DIGRX_SYNC_MODE_BINARY := '0';
           when TRUE    =>  DIGRX_SYNC_MODE_BINARY := '1';
           when others  =>  assert FALSE report "Error : DIGRX_SYNC_MODE is neither TRUE nor FALSE." severity error;
       end case;
       case PCS_BIT_SLIP is
           when FALSE   =>  PCS_BIT_SLIP_BINARY := '0';
           when TRUE    =>  PCS_BIT_SLIP_BINARY := '1';
           when others  =>  assert FALSE report "Error : PCS_BIT_SLIP is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_MIN_LAT is
           when   0  =>  CLK_COR_MIN_LAT_BINARY := "000000";
           when   1  =>  CLK_COR_MIN_LAT_BINARY := "000001";
           when   2  =>  CLK_COR_MIN_LAT_BINARY := "000010";
           when   3  =>  CLK_COR_MIN_LAT_BINARY := "000011";
           when   4  =>  CLK_COR_MIN_LAT_BINARY := "000100";
           when   5  =>  CLK_COR_MIN_LAT_BINARY := "000101";
           when   6  =>  CLK_COR_MIN_LAT_BINARY := "000110";
           when   7  =>  CLK_COR_MIN_LAT_BINARY := "000111";
           when   8  =>  CLK_COR_MIN_LAT_BINARY := "001000";
           when   9  =>  CLK_COR_MIN_LAT_BINARY := "001001";
           when   10  =>  CLK_COR_MIN_LAT_BINARY := "001010";
           when   11  =>  CLK_COR_MIN_LAT_BINARY := "001011";
           when   12  =>  CLK_COR_MIN_LAT_BINARY := "001100";
           when   13  =>  CLK_COR_MIN_LAT_BINARY := "001101";
           when   14  =>  CLK_COR_MIN_LAT_BINARY := "001110";
           when   15  =>  CLK_COR_MIN_LAT_BINARY := "001111";
           when   16  =>  CLK_COR_MIN_LAT_BINARY := "010000";
           when   17  =>  CLK_COR_MIN_LAT_BINARY := "010001";
           when   18  =>  CLK_COR_MIN_LAT_BINARY := "010010";
           when   19  =>  CLK_COR_MIN_LAT_BINARY := "010011";
           when   20  =>  CLK_COR_MIN_LAT_BINARY := "010100";
           when   21  =>  CLK_COR_MIN_LAT_BINARY := "010101";
           when   22  =>  CLK_COR_MIN_LAT_BINARY := "010110";
           when   23  =>  CLK_COR_MIN_LAT_BINARY := "010111";
           when   24  =>  CLK_COR_MIN_LAT_BINARY := "011000";
           when   25  =>  CLK_COR_MIN_LAT_BINARY := "011001";
           when   26  =>  CLK_COR_MIN_LAT_BINARY := "011010";
           when   27  =>  CLK_COR_MIN_LAT_BINARY := "011011";
           when   28  =>  CLK_COR_MIN_LAT_BINARY := "011100";
           when   29  =>  CLK_COR_MIN_LAT_BINARY := "011101";
           when   30  =>  CLK_COR_MIN_LAT_BINARY := "011110";
           when   31  =>  CLK_COR_MIN_LAT_BINARY := "011111";
           when   32  =>  CLK_COR_MIN_LAT_BINARY := "100000";
           when   33  =>  CLK_COR_MIN_LAT_BINARY := "100001";
           when   34  =>  CLK_COR_MIN_LAT_BINARY := "100010";
           when   35  =>  CLK_COR_MIN_LAT_BINARY := "100011";
           when   36  =>  CLK_COR_MIN_LAT_BINARY := "100100";
           when   37  =>  CLK_COR_MIN_LAT_BINARY := "100101";
           when   38  =>  CLK_COR_MIN_LAT_BINARY := "100110";
           when   39  =>  CLK_COR_MIN_LAT_BINARY := "100111";
           when   40  =>  CLK_COR_MIN_LAT_BINARY := "101000";
           when   41  =>  CLK_COR_MIN_LAT_BINARY := "101001";
           when   42  =>  CLK_COR_MIN_LAT_BINARY := "101010";
           when   43  =>  CLK_COR_MIN_LAT_BINARY := "101011";
           when   44  =>  CLK_COR_MIN_LAT_BINARY := "101100";
           when   45  =>  CLK_COR_MIN_LAT_BINARY := "101101";
           when   46  =>  CLK_COR_MIN_LAT_BINARY := "101110";
           when   47  =>  CLK_COR_MIN_LAT_BINARY := "101111";
           when   48  =>  CLK_COR_MIN_LAT_BINARY := "110000";
           when   49  =>  CLK_COR_MIN_LAT_BINARY := "110001";
           when   50  =>  CLK_COR_MIN_LAT_BINARY := "110010";
           when   51  =>  CLK_COR_MIN_LAT_BINARY := "110011";
           when   52  =>  CLK_COR_MIN_LAT_BINARY := "110100";
           when   53  =>  CLK_COR_MIN_LAT_BINARY := "110101";
           when   54  =>  CLK_COR_MIN_LAT_BINARY := "110110";
           when   55  =>  CLK_COR_MIN_LAT_BINARY := "110111";
           when   56  =>  CLK_COR_MIN_LAT_BINARY := "111000";
           when   57  =>  CLK_COR_MIN_LAT_BINARY := "111001";
           when   58  =>  CLK_COR_MIN_LAT_BINARY := "111010";
           when   59  =>  CLK_COR_MIN_LAT_BINARY := "111011";
           when   60  =>  CLK_COR_MIN_LAT_BINARY := "111100";
           when   61  =>  CLK_COR_MIN_LAT_BINARY := "111101";
           when   62  =>  CLK_COR_MIN_LAT_BINARY := "111110";
           when   63  =>  CLK_COR_MIN_LAT_BINARY := "111111";
           when others  =>  assert FALSE report "Error : CLK_COR_MIN_LAT is not in range 0...63." severity error;
       end case;
       case CLK_COR_MAX_LAT is
           when   0  =>  CLK_COR_MAX_LAT_BINARY := "000000";
           when   1  =>  CLK_COR_MAX_LAT_BINARY := "000001";
           when   2  =>  CLK_COR_MAX_LAT_BINARY := "000010";
           when   3  =>  CLK_COR_MAX_LAT_BINARY := "000011";
           when   4  =>  CLK_COR_MAX_LAT_BINARY := "000100";
           when   5  =>  CLK_COR_MAX_LAT_BINARY := "000101";
           when   6  =>  CLK_COR_MAX_LAT_BINARY := "000110";
           when   7  =>  CLK_COR_MAX_LAT_BINARY := "000111";
           when   8  =>  CLK_COR_MAX_LAT_BINARY := "001000";
           when   9  =>  CLK_COR_MAX_LAT_BINARY := "001001";
           when   10  =>  CLK_COR_MAX_LAT_BINARY := "001010";
           when   11  =>  CLK_COR_MAX_LAT_BINARY := "001011";
           when   12  =>  CLK_COR_MAX_LAT_BINARY := "001100";
           when   13  =>  CLK_COR_MAX_LAT_BINARY := "001101";
           when   14  =>  CLK_COR_MAX_LAT_BINARY := "001110";
           when   15  =>  CLK_COR_MAX_LAT_BINARY := "001111";
           when   16  =>  CLK_COR_MAX_LAT_BINARY := "010000";
           when   17  =>  CLK_COR_MAX_LAT_BINARY := "010001";
           when   18  =>  CLK_COR_MAX_LAT_BINARY := "010010";
           when   19  =>  CLK_COR_MAX_LAT_BINARY := "010011";
           when   20  =>  CLK_COR_MAX_LAT_BINARY := "010100";
           when   21  =>  CLK_COR_MAX_LAT_BINARY := "010101";
           when   22  =>  CLK_COR_MAX_LAT_BINARY := "010110";
           when   23  =>  CLK_COR_MAX_LAT_BINARY := "010111";
           when   24  =>  CLK_COR_MAX_LAT_BINARY := "011000";
           when   25  =>  CLK_COR_MAX_LAT_BINARY := "011001";
           when   26  =>  CLK_COR_MAX_LAT_BINARY := "011010";
           when   27  =>  CLK_COR_MAX_LAT_BINARY := "011011";
           when   28  =>  CLK_COR_MAX_LAT_BINARY := "011100";
           when   29  =>  CLK_COR_MAX_LAT_BINARY := "011101";
           when   30  =>  CLK_COR_MAX_LAT_BINARY := "011110";
           when   31  =>  CLK_COR_MAX_LAT_BINARY := "011111";
           when   32  =>  CLK_COR_MAX_LAT_BINARY := "100000";
           when   33  =>  CLK_COR_MAX_LAT_BINARY := "100001";
           when   34  =>  CLK_COR_MAX_LAT_BINARY := "100010";
           when   35  =>  CLK_COR_MAX_LAT_BINARY := "100011";
           when   36  =>  CLK_COR_MAX_LAT_BINARY := "100100";
           when   37  =>  CLK_COR_MAX_LAT_BINARY := "100101";
           when   38  =>  CLK_COR_MAX_LAT_BINARY := "100110";
           when   39  =>  CLK_COR_MAX_LAT_BINARY := "100111";
           when   40  =>  CLK_COR_MAX_LAT_BINARY := "101000";
           when   41  =>  CLK_COR_MAX_LAT_BINARY := "101001";
           when   42  =>  CLK_COR_MAX_LAT_BINARY := "101010";
           when   43  =>  CLK_COR_MAX_LAT_BINARY := "101011";
           when   44  =>  CLK_COR_MAX_LAT_BINARY := "101100";
           when   45  =>  CLK_COR_MAX_LAT_BINARY := "101101";
           when   46  =>  CLK_COR_MAX_LAT_BINARY := "101110";
           when   47  =>  CLK_COR_MAX_LAT_BINARY := "101111";
           when   48  =>  CLK_COR_MAX_LAT_BINARY := "110000";
           when   49  =>  CLK_COR_MAX_LAT_BINARY := "110001";
           when   50  =>  CLK_COR_MAX_LAT_BINARY := "110010";
           when   51  =>  CLK_COR_MAX_LAT_BINARY := "110011";
           when   52  =>  CLK_COR_MAX_LAT_BINARY := "110100";
           when   53  =>  CLK_COR_MAX_LAT_BINARY := "110101";
           when   54  =>  CLK_COR_MAX_LAT_BINARY := "110110";
           when   55  =>  CLK_COR_MAX_LAT_BINARY := "110111";
           when   56  =>  CLK_COR_MAX_LAT_BINARY := "111000";
           when   57  =>  CLK_COR_MAX_LAT_BINARY := "111001";
           when   58  =>  CLK_COR_MAX_LAT_BINARY := "111010";
           when   59  =>  CLK_COR_MAX_LAT_BINARY := "111011";
           when   60  =>  CLK_COR_MAX_LAT_BINARY := "111100";
           when   61  =>  CLK_COR_MAX_LAT_BINARY := "111101";
           when   62  =>  CLK_COR_MAX_LAT_BINARY := "111110";
           when   63  =>  CLK_COR_MAX_LAT_BINARY := "111111";
           when others  =>  assert FALSE report "Error : CLK_COR_MAX_LAT is not in range 0...63." severity error;
       end case;
       case CLK_COR_SEQ_2_USE is
           when FALSE   =>  CLK_COR_SEQ_2_USE_BINARY := '0';
           when TRUE    =>  CLK_COR_SEQ_2_USE_BINARY := '1';
           when others  =>  assert FALSE report "Error : CLK_COR_SEQ_2_USE is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_SEQ_DROP is
           when FALSE   =>  CLK_COR_SEQ_DROP_BINARY := '0';
           when TRUE    =>  CLK_COR_SEQ_DROP_BINARY := '1';
           when others  =>  assert FALSE report "Error : CLK_COR_SEQ_DROP is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_SEQ_LEN is
           when   1  =>  CLK_COR_SEQ_LEN_BINARY := "000";
           when   2  =>  CLK_COR_SEQ_LEN_BINARY := "001";
           when   3  =>  CLK_COR_SEQ_LEN_BINARY := "010";
           when   4  =>  CLK_COR_SEQ_LEN_BINARY := "011";
           when   8  =>  CLK_COR_SEQ_LEN_BINARY := "111";
           when others  =>  assert FALSE report "Error : CLK_COR_SEQ_LEN is not in 1, 2, 3, 4, 8." severity error;
       end case;
       case CLK_CORRECT_USE is
           when FALSE   =>  CLK_CORRECT_USE_BINARY := '0';
           when TRUE    =>  CLK_CORRECT_USE_BINARY := '1';
           when others  =>  assert FALSE report "Error : CLK_CORRECT_USE is neither TRUE nor FALSE." severity error;
       end case;
       case CLK_COR_8B10B_DE is
           when FALSE   =>  CLK_COR_8B10B_DE_BINARY := '0';
           when TRUE    =>  CLK_COR_8B10B_DE_BINARY := '1';
           when others  =>  assert FALSE report "Error : CLK_COR_8B10B_DE is neither TRUE nor FALSE." severity error;
       end case;
       case SH_CNT_MAX is
           when   0  =>  SH_CNT_MAX_BINARY := "00000000";
           when   1  =>  SH_CNT_MAX_BINARY := "00000001";
           when   2  =>  SH_CNT_MAX_BINARY := "00000010";
           when   3  =>  SH_CNT_MAX_BINARY := "00000011";
           when   4  =>  SH_CNT_MAX_BINARY := "00000100";
           when   5  =>  SH_CNT_MAX_BINARY := "00000101";
           when   6  =>  SH_CNT_MAX_BINARY := "00000110";
           when   7  =>  SH_CNT_MAX_BINARY := "00000111";
           when   8  =>  SH_CNT_MAX_BINARY := "00001000";
           when   9  =>  SH_CNT_MAX_BINARY := "00001001";
           when   10  =>  SH_CNT_MAX_BINARY := "00001010";
           when   11  =>  SH_CNT_MAX_BINARY := "00001011";
           when   12  =>  SH_CNT_MAX_BINARY := "00001100";
           when   13  =>  SH_CNT_MAX_BINARY := "00001101";
           when   14  =>  SH_CNT_MAX_BINARY := "00001110";
           when   15  =>  SH_CNT_MAX_BINARY := "00001111";
           when   16  =>  SH_CNT_MAX_BINARY := "00010000";
           when   17  =>  SH_CNT_MAX_BINARY := "00010001";
           when   18  =>  SH_CNT_MAX_BINARY := "00010010";
           when   19  =>  SH_CNT_MAX_BINARY := "00010011";
           when   20  =>  SH_CNT_MAX_BINARY := "00010100";
           when   21  =>  SH_CNT_MAX_BINARY := "00010101";
           when   22  =>  SH_CNT_MAX_BINARY := "00010110";
           when   23  =>  SH_CNT_MAX_BINARY := "00010111";
           when   24  =>  SH_CNT_MAX_BINARY := "00011000";
           when   25  =>  SH_CNT_MAX_BINARY := "00011001";
           when   26  =>  SH_CNT_MAX_BINARY := "00011010";
           when   27  =>  SH_CNT_MAX_BINARY := "00011011";
           when   28  =>  SH_CNT_MAX_BINARY := "00011100";
           when   29  =>  SH_CNT_MAX_BINARY := "00011101";
           when   30  =>  SH_CNT_MAX_BINARY := "00011110";
           when   31  =>  SH_CNT_MAX_BINARY := "00011111";
           when   32  =>  SH_CNT_MAX_BINARY := "00100000";
           when   33  =>  SH_CNT_MAX_BINARY := "00100001";
           when   34  =>  SH_CNT_MAX_BINARY := "00100010";
           when   35  =>  SH_CNT_MAX_BINARY := "00100011";
           when   36  =>  SH_CNT_MAX_BINARY := "00100100";
           when   37  =>  SH_CNT_MAX_BINARY := "00100101";
           when   38  =>  SH_CNT_MAX_BINARY := "00100110";
           when   39  =>  SH_CNT_MAX_BINARY := "00100111";
           when   40  =>  SH_CNT_MAX_BINARY := "00101000";
           when   41  =>  SH_CNT_MAX_BINARY := "00101001";
           when   42  =>  SH_CNT_MAX_BINARY := "00101010";
           when   43  =>  SH_CNT_MAX_BINARY := "00101011";
           when   44  =>  SH_CNT_MAX_BINARY := "00101100";
           when   45  =>  SH_CNT_MAX_BINARY := "00101101";
           when   46  =>  SH_CNT_MAX_BINARY := "00101110";
           when   47  =>  SH_CNT_MAX_BINARY := "00101111";
           when   48  =>  SH_CNT_MAX_BINARY := "00110000";
           when   49  =>  SH_CNT_MAX_BINARY := "00110001";
           when   50  =>  SH_CNT_MAX_BINARY := "00110010";
           when   51  =>  SH_CNT_MAX_BINARY := "00110011";
           when   52  =>  SH_CNT_MAX_BINARY := "00110100";
           when   53  =>  SH_CNT_MAX_BINARY := "00110101";
           when   54  =>  SH_CNT_MAX_BINARY := "00110110";
           when   55  =>  SH_CNT_MAX_BINARY := "00110111";
           when   56  =>  SH_CNT_MAX_BINARY := "00111000";
           when   57  =>  SH_CNT_MAX_BINARY := "00111001";
           when   58  =>  SH_CNT_MAX_BINARY := "00111010";
           when   59  =>  SH_CNT_MAX_BINARY := "00111011";
           when   60  =>  SH_CNT_MAX_BINARY := "00111100";
           when   61  =>  SH_CNT_MAX_BINARY := "00111101";
           when   62  =>  SH_CNT_MAX_BINARY := "00111110";
           when   63  =>  SH_CNT_MAX_BINARY := "00111111";
           when   64  =>  SH_CNT_MAX_BINARY := "01000000";
           when   65  =>  SH_CNT_MAX_BINARY := "01000001";
           when   66  =>  SH_CNT_MAX_BINARY := "01000010";
           when   67  =>  SH_CNT_MAX_BINARY := "01000011";
           when   68  =>  SH_CNT_MAX_BINARY := "01000100";
           when   69  =>  SH_CNT_MAX_BINARY := "01000101";
           when   70  =>  SH_CNT_MAX_BINARY := "01000110";
           when   71  =>  SH_CNT_MAX_BINARY := "01000111";
           when   72  =>  SH_CNT_MAX_BINARY := "01001000";
           when   73  =>  SH_CNT_MAX_BINARY := "01001001";
           when   74  =>  SH_CNT_MAX_BINARY := "01001010";
           when   75  =>  SH_CNT_MAX_BINARY := "01001011";
           when   76  =>  SH_CNT_MAX_BINARY := "01001100";
           when   77  =>  SH_CNT_MAX_BINARY := "01001101";
           when   78  =>  SH_CNT_MAX_BINARY := "01001110";
           when   79  =>  SH_CNT_MAX_BINARY := "01001111";
           when   80  =>  SH_CNT_MAX_BINARY := "01010000";
           when   81  =>  SH_CNT_MAX_BINARY := "01010001";
           when   82  =>  SH_CNT_MAX_BINARY := "01010010";
           when   83  =>  SH_CNT_MAX_BINARY := "01010011";
           when   84  =>  SH_CNT_MAX_BINARY := "01010100";
           when   85  =>  SH_CNT_MAX_BINARY := "01010101";
           when   86  =>  SH_CNT_MAX_BINARY := "01010110";
           when   87  =>  SH_CNT_MAX_BINARY := "01010111";
           when   88  =>  SH_CNT_MAX_BINARY := "01011000";
           when   89  =>  SH_CNT_MAX_BINARY := "01011001";
           when   90  =>  SH_CNT_MAX_BINARY := "01011010";
           when   91  =>  SH_CNT_MAX_BINARY := "01011011";
           when   92  =>  SH_CNT_MAX_BINARY := "01011100";
           when   93  =>  SH_CNT_MAX_BINARY := "01011101";
           when   94  =>  SH_CNT_MAX_BINARY := "01011110";
           when   95  =>  SH_CNT_MAX_BINARY := "01011111";
           when   96  =>  SH_CNT_MAX_BINARY := "01100000";
           when   97  =>  SH_CNT_MAX_BINARY := "01100001";
           when   98  =>  SH_CNT_MAX_BINARY := "01100010";
           when   99  =>  SH_CNT_MAX_BINARY := "01100011";
           when   100  =>  SH_CNT_MAX_BINARY := "01100100";
           when   101  =>  SH_CNT_MAX_BINARY := "01100101";
           when   102  =>  SH_CNT_MAX_BINARY := "01100110";
           when   103  =>  SH_CNT_MAX_BINARY := "01100111";
           when   104  =>  SH_CNT_MAX_BINARY := "01101000";
           when   105  =>  SH_CNT_MAX_BINARY := "01101001";
           when   106  =>  SH_CNT_MAX_BINARY := "01101010";
           when   107  =>  SH_CNT_MAX_BINARY := "01101011";
           when   108  =>  SH_CNT_MAX_BINARY := "01101100";
           when   109  =>  SH_CNT_MAX_BINARY := "01101101";
           when   110  =>  SH_CNT_MAX_BINARY := "01101110";
           when   111  =>  SH_CNT_MAX_BINARY := "01101111";
           when   112  =>  SH_CNT_MAX_BINARY := "01110000";
           when   113  =>  SH_CNT_MAX_BINARY := "01110001";
           when   114  =>  SH_CNT_MAX_BINARY := "01110010";
           when   115  =>  SH_CNT_MAX_BINARY := "01110011";
           when   116  =>  SH_CNT_MAX_BINARY := "01110100";
           when   117  =>  SH_CNT_MAX_BINARY := "01110101";
           when   118  =>  SH_CNT_MAX_BINARY := "01110110";
           when   119  =>  SH_CNT_MAX_BINARY := "01110111";
           when   120  =>  SH_CNT_MAX_BINARY := "01111000";
           when   121  =>  SH_CNT_MAX_BINARY := "01111001";
           when   122  =>  SH_CNT_MAX_BINARY := "01111010";
           when   123  =>  SH_CNT_MAX_BINARY := "01111011";
           when   124  =>  SH_CNT_MAX_BINARY := "01111100";
           when   125  =>  SH_CNT_MAX_BINARY := "01111101";
           when   126  =>  SH_CNT_MAX_BINARY := "01111110";
           when   127  =>  SH_CNT_MAX_BINARY := "01111111";
           when   128  =>  SH_CNT_MAX_BINARY := "10000000";
           when   129  =>  SH_CNT_MAX_BINARY := "10000001";
           when   130  =>  SH_CNT_MAX_BINARY := "10000010";
           when   131  =>  SH_CNT_MAX_BINARY := "10000011";
           when   132  =>  SH_CNT_MAX_BINARY := "10000100";
           when   133  =>  SH_CNT_MAX_BINARY := "10000101";
           when   134  =>  SH_CNT_MAX_BINARY := "10000110";
           when   135  =>  SH_CNT_MAX_BINARY := "10000111";
           when   136  =>  SH_CNT_MAX_BINARY := "10001000";
           when   137  =>  SH_CNT_MAX_BINARY := "10001001";
           when   138  =>  SH_CNT_MAX_BINARY := "10001010";
           when   139  =>  SH_CNT_MAX_BINARY := "10001011";
           when   140  =>  SH_CNT_MAX_BINARY := "10001100";
           when   141  =>  SH_CNT_MAX_BINARY := "10001101";
           when   142  =>  SH_CNT_MAX_BINARY := "10001110";
           when   143  =>  SH_CNT_MAX_BINARY := "10001111";
           when   144  =>  SH_CNT_MAX_BINARY := "10010000";
           when   145  =>  SH_CNT_MAX_BINARY := "10010001";
           when   146  =>  SH_CNT_MAX_BINARY := "10010010";
           when   147  =>  SH_CNT_MAX_BINARY := "10010011";
           when   148  =>  SH_CNT_MAX_BINARY := "10010100";
           when   149  =>  SH_CNT_MAX_BINARY := "10010101";
           when   150  =>  SH_CNT_MAX_BINARY := "10010110";
           when   151  =>  SH_CNT_MAX_BINARY := "10010111";
           when   152  =>  SH_CNT_MAX_BINARY := "10011000";
           when   153  =>  SH_CNT_MAX_BINARY := "10011001";
           when   154  =>  SH_CNT_MAX_BINARY := "10011010";
           when   155  =>  SH_CNT_MAX_BINARY := "10011011";
           when   156  =>  SH_CNT_MAX_BINARY := "10011100";
           when   157  =>  SH_CNT_MAX_BINARY := "10011101";
           when   158  =>  SH_CNT_MAX_BINARY := "10011110";
           when   159  =>  SH_CNT_MAX_BINARY := "10011111";
           when   160  =>  SH_CNT_MAX_BINARY := "10100000";
           when   161  =>  SH_CNT_MAX_BINARY := "10100001";
           when   162  =>  SH_CNT_MAX_BINARY := "10100010";
           when   163  =>  SH_CNT_MAX_BINARY := "10100011";
           when   164  =>  SH_CNT_MAX_BINARY := "10100100";
           when   165  =>  SH_CNT_MAX_BINARY := "10100101";
           when   166  =>  SH_CNT_MAX_BINARY := "10100110";
           when   167  =>  SH_CNT_MAX_BINARY := "10100111";
           when   168  =>  SH_CNT_MAX_BINARY := "10101000";
           when   169  =>  SH_CNT_MAX_BINARY := "10101001";
           when   170  =>  SH_CNT_MAX_BINARY := "10101010";
           when   171  =>  SH_CNT_MAX_BINARY := "10101011";
           when   172  =>  SH_CNT_MAX_BINARY := "10101100";
           when   173  =>  SH_CNT_MAX_BINARY := "10101101";
           when   174  =>  SH_CNT_MAX_BINARY := "10101110";
           when   175  =>  SH_CNT_MAX_BINARY := "10101111";
           when   176  =>  SH_CNT_MAX_BINARY := "10110000";
           when   177  =>  SH_CNT_MAX_BINARY := "10110001";
           when   178  =>  SH_CNT_MAX_BINARY := "10110010";
           when   179  =>  SH_CNT_MAX_BINARY := "10110011";
           when   180  =>  SH_CNT_MAX_BINARY := "10110100";
           when   181  =>  SH_CNT_MAX_BINARY := "10110101";
           when   182  =>  SH_CNT_MAX_BINARY := "10110110";
           when   183  =>  SH_CNT_MAX_BINARY := "10110111";
           when   184  =>  SH_CNT_MAX_BINARY := "10111000";
           when   185  =>  SH_CNT_MAX_BINARY := "10111001";
           when   186  =>  SH_CNT_MAX_BINARY := "10111010";
           when   187  =>  SH_CNT_MAX_BINARY := "10111011";
           when   188  =>  SH_CNT_MAX_BINARY := "10111100";
           when   189  =>  SH_CNT_MAX_BINARY := "10111101";
           when   190  =>  SH_CNT_MAX_BINARY := "10111110";
           when   191  =>  SH_CNT_MAX_BINARY := "10111111";
           when   192  =>  SH_CNT_MAX_BINARY := "11000000";
           when   193  =>  SH_CNT_MAX_BINARY := "11000001";
           when   194  =>  SH_CNT_MAX_BINARY := "11000010";
           when   195  =>  SH_CNT_MAX_BINARY := "11000011";
           when   196  =>  SH_CNT_MAX_BINARY := "11000100";
           when   197  =>  SH_CNT_MAX_BINARY := "11000101";
           when   198  =>  SH_CNT_MAX_BINARY := "11000110";
           when   199  =>  SH_CNT_MAX_BINARY := "11000111";
           when   200  =>  SH_CNT_MAX_BINARY := "11001000";
           when   201  =>  SH_CNT_MAX_BINARY := "11001001";
           when   202  =>  SH_CNT_MAX_BINARY := "11001010";
           when   203  =>  SH_CNT_MAX_BINARY := "11001011";
           when   204  =>  SH_CNT_MAX_BINARY := "11001100";
           when   205  =>  SH_CNT_MAX_BINARY := "11001101";
           when   206  =>  SH_CNT_MAX_BINARY := "11001110";
           when   207  =>  SH_CNT_MAX_BINARY := "11001111";
           when   208  =>  SH_CNT_MAX_BINARY := "11010000";
           when   209  =>  SH_CNT_MAX_BINARY := "11010001";
           when   210  =>  SH_CNT_MAX_BINARY := "11010010";
           when   211  =>  SH_CNT_MAX_BINARY := "11010011";
           when   212  =>  SH_CNT_MAX_BINARY := "11010100";
           when   213  =>  SH_CNT_MAX_BINARY := "11010101";
           when   214  =>  SH_CNT_MAX_BINARY := "11010110";
           when   215  =>  SH_CNT_MAX_BINARY := "11010111";
           when   216  =>  SH_CNT_MAX_BINARY := "11011000";
           when   217  =>  SH_CNT_MAX_BINARY := "11011001";
           when   218  =>  SH_CNT_MAX_BINARY := "11011010";
           when   219  =>  SH_CNT_MAX_BINARY := "11011011";
           when   220  =>  SH_CNT_MAX_BINARY := "11011100";
           when   221  =>  SH_CNT_MAX_BINARY := "11011101";
           when   222  =>  SH_CNT_MAX_BINARY := "11011110";
           when   223  =>  SH_CNT_MAX_BINARY := "11011111";
           when   224  =>  SH_CNT_MAX_BINARY := "11100000";
           when   225  =>  SH_CNT_MAX_BINARY := "11100001";
           when   226  =>  SH_CNT_MAX_BINARY := "11100010";
           when   227  =>  SH_CNT_MAX_BINARY := "11100011";
           when   228  =>  SH_CNT_MAX_BINARY := "11100100";
           when   229  =>  SH_CNT_MAX_BINARY := "11100101";
           when   230  =>  SH_CNT_MAX_BINARY := "11100110";
           when   231  =>  SH_CNT_MAX_BINARY := "11100111";
           when   232  =>  SH_CNT_MAX_BINARY := "11101000";
           when   233  =>  SH_CNT_MAX_BINARY := "11101001";
           when   234  =>  SH_CNT_MAX_BINARY := "11101010";
           when   235  =>  SH_CNT_MAX_BINARY := "11101011";
           when   236  =>  SH_CNT_MAX_BINARY := "11101100";
           when   237  =>  SH_CNT_MAX_BINARY := "11101101";
           when   238  =>  SH_CNT_MAX_BINARY := "11101110";
           when   239  =>  SH_CNT_MAX_BINARY := "11101111";
           when   240  =>  SH_CNT_MAX_BINARY := "11110000";
           when   241  =>  SH_CNT_MAX_BINARY := "11110001";
           when   242  =>  SH_CNT_MAX_BINARY := "11110010";
           when   243  =>  SH_CNT_MAX_BINARY := "11110011";
           when   244  =>  SH_CNT_MAX_BINARY := "11110100";
           when   245  =>  SH_CNT_MAX_BINARY := "11110101";
           when   246  =>  SH_CNT_MAX_BINARY := "11110110";
           when   247  =>  SH_CNT_MAX_BINARY := "11110111";
           when   248  =>  SH_CNT_MAX_BINARY := "11111000";
           when   249  =>  SH_CNT_MAX_BINARY := "11111001";
           when   250  =>  SH_CNT_MAX_BINARY := "11111010";
           when   251  =>  SH_CNT_MAX_BINARY := "11111011";
           when   252  =>  SH_CNT_MAX_BINARY := "11111100";
           when   253  =>  SH_CNT_MAX_BINARY := "11111101";
           when   254  =>  SH_CNT_MAX_BINARY := "11111110";
           when   255  =>  SH_CNT_MAX_BINARY := "11111111";
           when others  =>  assert FALSE report "Error : SH_CNT_MAX is not in range 0...255." severity error;
       end case;
       case SH_INVALID_CNT_MAX is
           when   0  =>  SH_INVALID_CNT_MAX_BINARY := "00000000";
           when   1  =>  SH_INVALID_CNT_MAX_BINARY := "00000001";
           when   2  =>  SH_INVALID_CNT_MAX_BINARY := "00000010";
           when   3  =>  SH_INVALID_CNT_MAX_BINARY := "00000011";
           when   4  =>  SH_INVALID_CNT_MAX_BINARY := "00000100";
           when   5  =>  SH_INVALID_CNT_MAX_BINARY := "00000101";
           when   6  =>  SH_INVALID_CNT_MAX_BINARY := "00000110";
           when   7  =>  SH_INVALID_CNT_MAX_BINARY := "00000111";
           when   8  =>  SH_INVALID_CNT_MAX_BINARY := "00001000";
           when   9  =>  SH_INVALID_CNT_MAX_BINARY := "00001001";
           when   10  =>  SH_INVALID_CNT_MAX_BINARY := "00001010";
           when   11  =>  SH_INVALID_CNT_MAX_BINARY := "00001011";
           when   12  =>  SH_INVALID_CNT_MAX_BINARY := "00001100";
           when   13  =>  SH_INVALID_CNT_MAX_BINARY := "00001101";
           when   14  =>  SH_INVALID_CNT_MAX_BINARY := "00001110";
           when   15  =>  SH_INVALID_CNT_MAX_BINARY := "00001111";
           when   16  =>  SH_INVALID_CNT_MAX_BINARY := "00010000";
           when   17  =>  SH_INVALID_CNT_MAX_BINARY := "00010001";
           when   18  =>  SH_INVALID_CNT_MAX_BINARY := "00010010";
           when   19  =>  SH_INVALID_CNT_MAX_BINARY := "00010011";
           when   20  =>  SH_INVALID_CNT_MAX_BINARY := "00010100";
           when   21  =>  SH_INVALID_CNT_MAX_BINARY := "00010101";
           when   22  =>  SH_INVALID_CNT_MAX_BINARY := "00010110";
           when   23  =>  SH_INVALID_CNT_MAX_BINARY := "00010111";
           when   24  =>  SH_INVALID_CNT_MAX_BINARY := "00011000";
           when   25  =>  SH_INVALID_CNT_MAX_BINARY := "00011001";
           when   26  =>  SH_INVALID_CNT_MAX_BINARY := "00011010";
           when   27  =>  SH_INVALID_CNT_MAX_BINARY := "00011011";
           when   28  =>  SH_INVALID_CNT_MAX_BINARY := "00011100";
           when   29  =>  SH_INVALID_CNT_MAX_BINARY := "00011101";
           when   30  =>  SH_INVALID_CNT_MAX_BINARY := "00011110";
           when   31  =>  SH_INVALID_CNT_MAX_BINARY := "00011111";
           when   32  =>  SH_INVALID_CNT_MAX_BINARY := "00100000";
           when   33  =>  SH_INVALID_CNT_MAX_BINARY := "00100001";
           when   34  =>  SH_INVALID_CNT_MAX_BINARY := "00100010";
           when   35  =>  SH_INVALID_CNT_MAX_BINARY := "00100011";
           when   36  =>  SH_INVALID_CNT_MAX_BINARY := "00100100";
           when   37  =>  SH_INVALID_CNT_MAX_BINARY := "00100101";
           when   38  =>  SH_INVALID_CNT_MAX_BINARY := "00100110";
           when   39  =>  SH_INVALID_CNT_MAX_BINARY := "00100111";
           when   40  =>  SH_INVALID_CNT_MAX_BINARY := "00101000";
           when   41  =>  SH_INVALID_CNT_MAX_BINARY := "00101001";
           when   42  =>  SH_INVALID_CNT_MAX_BINARY := "00101010";
           when   43  =>  SH_INVALID_CNT_MAX_BINARY := "00101011";
           when   44  =>  SH_INVALID_CNT_MAX_BINARY := "00101100";
           when   45  =>  SH_INVALID_CNT_MAX_BINARY := "00101101";
           when   46  =>  SH_INVALID_CNT_MAX_BINARY := "00101110";
           when   47  =>  SH_INVALID_CNT_MAX_BINARY := "00101111";
           when   48  =>  SH_INVALID_CNT_MAX_BINARY := "00110000";
           when   49  =>  SH_INVALID_CNT_MAX_BINARY := "00110001";
           when   50  =>  SH_INVALID_CNT_MAX_BINARY := "00110010";
           when   51  =>  SH_INVALID_CNT_MAX_BINARY := "00110011";
           when   52  =>  SH_INVALID_CNT_MAX_BINARY := "00110100";
           when   53  =>  SH_INVALID_CNT_MAX_BINARY := "00110101";
           when   54  =>  SH_INVALID_CNT_MAX_BINARY := "00110110";
           when   55  =>  SH_INVALID_CNT_MAX_BINARY := "00110111";
           when   56  =>  SH_INVALID_CNT_MAX_BINARY := "00111000";
           when   57  =>  SH_INVALID_CNT_MAX_BINARY := "00111001";
           when   58  =>  SH_INVALID_CNT_MAX_BINARY := "00111010";
           when   59  =>  SH_INVALID_CNT_MAX_BINARY := "00111011";
           when   60  =>  SH_INVALID_CNT_MAX_BINARY := "00111100";
           when   61  =>  SH_INVALID_CNT_MAX_BINARY := "00111101";
           when   62  =>  SH_INVALID_CNT_MAX_BINARY := "00111110";
           when   63  =>  SH_INVALID_CNT_MAX_BINARY := "00111111";
           when   64  =>  SH_INVALID_CNT_MAX_BINARY := "01000000";
           when   65  =>  SH_INVALID_CNT_MAX_BINARY := "01000001";
           when   66  =>  SH_INVALID_CNT_MAX_BINARY := "01000010";
           when   67  =>  SH_INVALID_CNT_MAX_BINARY := "01000011";
           when   68  =>  SH_INVALID_CNT_MAX_BINARY := "01000100";
           when   69  =>  SH_INVALID_CNT_MAX_BINARY := "01000101";
           when   70  =>  SH_INVALID_CNT_MAX_BINARY := "01000110";
           when   71  =>  SH_INVALID_CNT_MAX_BINARY := "01000111";
           when   72  =>  SH_INVALID_CNT_MAX_BINARY := "01001000";
           when   73  =>  SH_INVALID_CNT_MAX_BINARY := "01001001";
           when   74  =>  SH_INVALID_CNT_MAX_BINARY := "01001010";
           when   75  =>  SH_INVALID_CNT_MAX_BINARY := "01001011";
           when   76  =>  SH_INVALID_CNT_MAX_BINARY := "01001100";
           when   77  =>  SH_INVALID_CNT_MAX_BINARY := "01001101";
           when   78  =>  SH_INVALID_CNT_MAX_BINARY := "01001110";
           when   79  =>  SH_INVALID_CNT_MAX_BINARY := "01001111";
           when   80  =>  SH_INVALID_CNT_MAX_BINARY := "01010000";
           when   81  =>  SH_INVALID_CNT_MAX_BINARY := "01010001";
           when   82  =>  SH_INVALID_CNT_MAX_BINARY := "01010010";
           when   83  =>  SH_INVALID_CNT_MAX_BINARY := "01010011";
           when   84  =>  SH_INVALID_CNT_MAX_BINARY := "01010100";
           when   85  =>  SH_INVALID_CNT_MAX_BINARY := "01010101";
           when   86  =>  SH_INVALID_CNT_MAX_BINARY := "01010110";
           when   87  =>  SH_INVALID_CNT_MAX_BINARY := "01010111";
           when   88  =>  SH_INVALID_CNT_MAX_BINARY := "01011000";
           when   89  =>  SH_INVALID_CNT_MAX_BINARY := "01011001";
           when   90  =>  SH_INVALID_CNT_MAX_BINARY := "01011010";
           when   91  =>  SH_INVALID_CNT_MAX_BINARY := "01011011";
           when   92  =>  SH_INVALID_CNT_MAX_BINARY := "01011100";
           when   93  =>  SH_INVALID_CNT_MAX_BINARY := "01011101";
           when   94  =>  SH_INVALID_CNT_MAX_BINARY := "01011110";
           when   95  =>  SH_INVALID_CNT_MAX_BINARY := "01011111";
           when   96  =>  SH_INVALID_CNT_MAX_BINARY := "01100000";
           when   97  =>  SH_INVALID_CNT_MAX_BINARY := "01100001";
           when   98  =>  SH_INVALID_CNT_MAX_BINARY := "01100010";
           when   99  =>  SH_INVALID_CNT_MAX_BINARY := "01100011";
           when   100  =>  SH_INVALID_CNT_MAX_BINARY := "01100100";
           when   101  =>  SH_INVALID_CNT_MAX_BINARY := "01100101";
           when   102  =>  SH_INVALID_CNT_MAX_BINARY := "01100110";
           when   103  =>  SH_INVALID_CNT_MAX_BINARY := "01100111";
           when   104  =>  SH_INVALID_CNT_MAX_BINARY := "01101000";
           when   105  =>  SH_INVALID_CNT_MAX_BINARY := "01101001";
           when   106  =>  SH_INVALID_CNT_MAX_BINARY := "01101010";
           when   107  =>  SH_INVALID_CNT_MAX_BINARY := "01101011";
           when   108  =>  SH_INVALID_CNT_MAX_BINARY := "01101100";
           when   109  =>  SH_INVALID_CNT_MAX_BINARY := "01101101";
           when   110  =>  SH_INVALID_CNT_MAX_BINARY := "01101110";
           when   111  =>  SH_INVALID_CNT_MAX_BINARY := "01101111";
           when   112  =>  SH_INVALID_CNT_MAX_BINARY := "01110000";
           when   113  =>  SH_INVALID_CNT_MAX_BINARY := "01110001";
           when   114  =>  SH_INVALID_CNT_MAX_BINARY := "01110010";
           when   115  =>  SH_INVALID_CNT_MAX_BINARY := "01110011";
           when   116  =>  SH_INVALID_CNT_MAX_BINARY := "01110100";
           when   117  =>  SH_INVALID_CNT_MAX_BINARY := "01110101";
           when   118  =>  SH_INVALID_CNT_MAX_BINARY := "01110110";
           when   119  =>  SH_INVALID_CNT_MAX_BINARY := "01110111";
           when   120  =>  SH_INVALID_CNT_MAX_BINARY := "01111000";
           when   121  =>  SH_INVALID_CNT_MAX_BINARY := "01111001";
           when   122  =>  SH_INVALID_CNT_MAX_BINARY := "01111010";
           when   123  =>  SH_INVALID_CNT_MAX_BINARY := "01111011";
           when   124  =>  SH_INVALID_CNT_MAX_BINARY := "01111100";
           when   125  =>  SH_INVALID_CNT_MAX_BINARY := "01111101";
           when   126  =>  SH_INVALID_CNT_MAX_BINARY := "01111110";
           when   127  =>  SH_INVALID_CNT_MAX_BINARY := "01111111";
           when   128  =>  SH_INVALID_CNT_MAX_BINARY := "10000000";
           when   129  =>  SH_INVALID_CNT_MAX_BINARY := "10000001";
           when   130  =>  SH_INVALID_CNT_MAX_BINARY := "10000010";
           when   131  =>  SH_INVALID_CNT_MAX_BINARY := "10000011";
           when   132  =>  SH_INVALID_CNT_MAX_BINARY := "10000100";
           when   133  =>  SH_INVALID_CNT_MAX_BINARY := "10000101";
           when   134  =>  SH_INVALID_CNT_MAX_BINARY := "10000110";
           when   135  =>  SH_INVALID_CNT_MAX_BINARY := "10000111";
           when   136  =>  SH_INVALID_CNT_MAX_BINARY := "10001000";
           when   137  =>  SH_INVALID_CNT_MAX_BINARY := "10001001";
           when   138  =>  SH_INVALID_CNT_MAX_BINARY := "10001010";
           when   139  =>  SH_INVALID_CNT_MAX_BINARY := "10001011";
           when   140  =>  SH_INVALID_CNT_MAX_BINARY := "10001100";
           when   141  =>  SH_INVALID_CNT_MAX_BINARY := "10001101";
           when   142  =>  SH_INVALID_CNT_MAX_BINARY := "10001110";
           when   143  =>  SH_INVALID_CNT_MAX_BINARY := "10001111";
           when   144  =>  SH_INVALID_CNT_MAX_BINARY := "10010000";
           when   145  =>  SH_INVALID_CNT_MAX_BINARY := "10010001";
           when   146  =>  SH_INVALID_CNT_MAX_BINARY := "10010010";
           when   147  =>  SH_INVALID_CNT_MAX_BINARY := "10010011";
           when   148  =>  SH_INVALID_CNT_MAX_BINARY := "10010100";
           when   149  =>  SH_INVALID_CNT_MAX_BINARY := "10010101";
           when   150  =>  SH_INVALID_CNT_MAX_BINARY := "10010110";
           when   151  =>  SH_INVALID_CNT_MAX_BINARY := "10010111";
           when   152  =>  SH_INVALID_CNT_MAX_BINARY := "10011000";
           when   153  =>  SH_INVALID_CNT_MAX_BINARY := "10011001";
           when   154  =>  SH_INVALID_CNT_MAX_BINARY := "10011010";
           when   155  =>  SH_INVALID_CNT_MAX_BINARY := "10011011";
           when   156  =>  SH_INVALID_CNT_MAX_BINARY := "10011100";
           when   157  =>  SH_INVALID_CNT_MAX_BINARY := "10011101";
           when   158  =>  SH_INVALID_CNT_MAX_BINARY := "10011110";
           when   159  =>  SH_INVALID_CNT_MAX_BINARY := "10011111";
           when   160  =>  SH_INVALID_CNT_MAX_BINARY := "10100000";
           when   161  =>  SH_INVALID_CNT_MAX_BINARY := "10100001";
           when   162  =>  SH_INVALID_CNT_MAX_BINARY := "10100010";
           when   163  =>  SH_INVALID_CNT_MAX_BINARY := "10100011";
           when   164  =>  SH_INVALID_CNT_MAX_BINARY := "10100100";
           when   165  =>  SH_INVALID_CNT_MAX_BINARY := "10100101";
           when   166  =>  SH_INVALID_CNT_MAX_BINARY := "10100110";
           when   167  =>  SH_INVALID_CNT_MAX_BINARY := "10100111";
           when   168  =>  SH_INVALID_CNT_MAX_BINARY := "10101000";
           when   169  =>  SH_INVALID_CNT_MAX_BINARY := "10101001";
           when   170  =>  SH_INVALID_CNT_MAX_BINARY := "10101010";
           when   171  =>  SH_INVALID_CNT_MAX_BINARY := "10101011";
           when   172  =>  SH_INVALID_CNT_MAX_BINARY := "10101100";
           when   173  =>  SH_INVALID_CNT_MAX_BINARY := "10101101";
           when   174  =>  SH_INVALID_CNT_MAX_BINARY := "10101110";
           when   175  =>  SH_INVALID_CNT_MAX_BINARY := "10101111";
           when   176  =>  SH_INVALID_CNT_MAX_BINARY := "10110000";
           when   177  =>  SH_INVALID_CNT_MAX_BINARY := "10110001";
           when   178  =>  SH_INVALID_CNT_MAX_BINARY := "10110010";
           when   179  =>  SH_INVALID_CNT_MAX_BINARY := "10110011";
           when   180  =>  SH_INVALID_CNT_MAX_BINARY := "10110100";
           when   181  =>  SH_INVALID_CNT_MAX_BINARY := "10110101";
           when   182  =>  SH_INVALID_CNT_MAX_BINARY := "10110110";
           when   183  =>  SH_INVALID_CNT_MAX_BINARY := "10110111";
           when   184  =>  SH_INVALID_CNT_MAX_BINARY := "10111000";
           when   185  =>  SH_INVALID_CNT_MAX_BINARY := "10111001";
           when   186  =>  SH_INVALID_CNT_MAX_BINARY := "10111010";
           when   187  =>  SH_INVALID_CNT_MAX_BINARY := "10111011";
           when   188  =>  SH_INVALID_CNT_MAX_BINARY := "10111100";
           when   189  =>  SH_INVALID_CNT_MAX_BINARY := "10111101";
           when   190  =>  SH_INVALID_CNT_MAX_BINARY := "10111110";
           when   191  =>  SH_INVALID_CNT_MAX_BINARY := "10111111";
           when   192  =>  SH_INVALID_CNT_MAX_BINARY := "11000000";
           when   193  =>  SH_INVALID_CNT_MAX_BINARY := "11000001";
           when   194  =>  SH_INVALID_CNT_MAX_BINARY := "11000010";
           when   195  =>  SH_INVALID_CNT_MAX_BINARY := "11000011";
           when   196  =>  SH_INVALID_CNT_MAX_BINARY := "11000100";
           when   197  =>  SH_INVALID_CNT_MAX_BINARY := "11000101";
           when   198  =>  SH_INVALID_CNT_MAX_BINARY := "11000110";
           when   199  =>  SH_INVALID_CNT_MAX_BINARY := "11000111";
           when   200  =>  SH_INVALID_CNT_MAX_BINARY := "11001000";
           when   201  =>  SH_INVALID_CNT_MAX_BINARY := "11001001";
           when   202  =>  SH_INVALID_CNT_MAX_BINARY := "11001010";
           when   203  =>  SH_INVALID_CNT_MAX_BINARY := "11001011";
           when   204  =>  SH_INVALID_CNT_MAX_BINARY := "11001100";
           when   205  =>  SH_INVALID_CNT_MAX_BINARY := "11001101";
           when   206  =>  SH_INVALID_CNT_MAX_BINARY := "11001110";
           when   207  =>  SH_INVALID_CNT_MAX_BINARY := "11001111";
           when   208  =>  SH_INVALID_CNT_MAX_BINARY := "11010000";
           when   209  =>  SH_INVALID_CNT_MAX_BINARY := "11010001";
           when   210  =>  SH_INVALID_CNT_MAX_BINARY := "11010010";
           when   211  =>  SH_INVALID_CNT_MAX_BINARY := "11010011";
           when   212  =>  SH_INVALID_CNT_MAX_BINARY := "11010100";
           when   213  =>  SH_INVALID_CNT_MAX_BINARY := "11010101";
           when   214  =>  SH_INVALID_CNT_MAX_BINARY := "11010110";
           when   215  =>  SH_INVALID_CNT_MAX_BINARY := "11010111";
           when   216  =>  SH_INVALID_CNT_MAX_BINARY := "11011000";
           when   217  =>  SH_INVALID_CNT_MAX_BINARY := "11011001";
           when   218  =>  SH_INVALID_CNT_MAX_BINARY := "11011010";
           when   219  =>  SH_INVALID_CNT_MAX_BINARY := "11011011";
           when   220  =>  SH_INVALID_CNT_MAX_BINARY := "11011100";
           when   221  =>  SH_INVALID_CNT_MAX_BINARY := "11011101";
           when   222  =>  SH_INVALID_CNT_MAX_BINARY := "11011110";
           when   223  =>  SH_INVALID_CNT_MAX_BINARY := "11011111";
           when   224  =>  SH_INVALID_CNT_MAX_BINARY := "11100000";
           when   225  =>  SH_INVALID_CNT_MAX_BINARY := "11100001";
           when   226  =>  SH_INVALID_CNT_MAX_BINARY := "11100010";
           when   227  =>  SH_INVALID_CNT_MAX_BINARY := "11100011";
           when   228  =>  SH_INVALID_CNT_MAX_BINARY := "11100100";
           when   229  =>  SH_INVALID_CNT_MAX_BINARY := "11100101";
           when   230  =>  SH_INVALID_CNT_MAX_BINARY := "11100110";
           when   231  =>  SH_INVALID_CNT_MAX_BINARY := "11100111";
           when   232  =>  SH_INVALID_CNT_MAX_BINARY := "11101000";
           when   233  =>  SH_INVALID_CNT_MAX_BINARY := "11101001";
           when   234  =>  SH_INVALID_CNT_MAX_BINARY := "11101010";
           when   235  =>  SH_INVALID_CNT_MAX_BINARY := "11101011";
           when   236  =>  SH_INVALID_CNT_MAX_BINARY := "11101100";
           when   237  =>  SH_INVALID_CNT_MAX_BINARY := "11101101";
           when   238  =>  SH_INVALID_CNT_MAX_BINARY := "11101110";
           when   239  =>  SH_INVALID_CNT_MAX_BINARY := "11101111";
           when   240  =>  SH_INVALID_CNT_MAX_BINARY := "11110000";
           when   241  =>  SH_INVALID_CNT_MAX_BINARY := "11110001";
           when   242  =>  SH_INVALID_CNT_MAX_BINARY := "11110010";
           when   243  =>  SH_INVALID_CNT_MAX_BINARY := "11110011";
           when   244  =>  SH_INVALID_CNT_MAX_BINARY := "11110100";
           when   245  =>  SH_INVALID_CNT_MAX_BINARY := "11110101";
           when   246  =>  SH_INVALID_CNT_MAX_BINARY := "11110110";
           when   247  =>  SH_INVALID_CNT_MAX_BINARY := "11110111";
           when   248  =>  SH_INVALID_CNT_MAX_BINARY := "11111000";
           when   249  =>  SH_INVALID_CNT_MAX_BINARY := "11111001";
           when   250  =>  SH_INVALID_CNT_MAX_BINARY := "11111010";
           when   251  =>  SH_INVALID_CNT_MAX_BINARY := "11111011";
           when   252  =>  SH_INVALID_CNT_MAX_BINARY := "11111100";
           when   253  =>  SH_INVALID_CNT_MAX_BINARY := "11111101";
           when   254  =>  SH_INVALID_CNT_MAX_BINARY := "11111110";
           when   255  =>  SH_INVALID_CNT_MAX_BINARY := "11111111";
           when others  =>  assert FALSE report "Error : SH_INVALID_CNT_MAX is not in range 0...255." severity error;
       end case;
       case ALIGN_COMMA_WORD is
           when   1  =>  ALIGN_COMMA_WORD_BINARY := "00";
           when   2  =>  ALIGN_COMMA_WORD_BINARY := "01";
           when   4  =>  ALIGN_COMMA_WORD_BINARY := "10";
           when others  =>  assert FALSE report "Error : ALIGN_COMMA_WORD is not in 1, 2, 4." severity error;
       end case;
       case DEC_MCOMMA_DETECT is
           when FALSE   =>  DEC_MCOMMA_DETECT_BINARY := '0';
           when TRUE    =>  DEC_MCOMMA_DETECT_BINARY := '1';
           when others  =>  assert FALSE report "Error : DEC_MCOMMA_DETECT is neither TRUE nor FALSE." severity error;
       end case;
       case DEC_PCOMMA_DETECT is
           when FALSE   =>  DEC_PCOMMA_DETECT_BINARY := '0';
           when TRUE    =>  DEC_PCOMMA_DETECT_BINARY := '1';
           when others  =>  assert FALSE report "Error : DEC_PCOMMA_DETECT is neither TRUE nor FALSE." severity error;
       end case;
       case DEC_VALID_COMMA_ONLY is
           when FALSE   =>  DEC_VALID_COMMA_ONLY_BINARY := '0';
           when TRUE    =>  DEC_VALID_COMMA_ONLY_BINARY := '1';
           when others  =>  assert FALSE report "Error : DEC_VALID_COMMA_ONLY is neither TRUE nor FALSE." severity error;
       end case;
       case MCOMMA_DETECT is
           when FALSE   =>  MCOMMA_DETECT_BINARY := '0';
           when TRUE    =>  MCOMMA_DETECT_BINARY := '1';
           when others  =>  assert FALSE report "Error : MCOMMA_DETECT is neither TRUE nor FALSE." severity error;
       end case;
       case PCOMMA_DETECT is
           when FALSE   =>  PCOMMA_DETECT_BINARY := '0';
           when TRUE    =>  PCOMMA_DETECT_BINARY := '1';
           when others  =>  assert FALSE report "Error : PCOMMA_DETECT is neither TRUE nor FALSE." severity error;
       end case;
       case COMMA32 is
           when FALSE   =>  COMMA32_BINARY := '0';
           when TRUE    =>  COMMA32_BINARY := '1';
           when others  =>  assert FALSE report "Error : COMMA32 is neither TRUE nor FALSE." severity error;
       end case;
       case RXUSRDIVISOR is
           when   1  =>  RXUSRDIVISOR_BINARY := "00001";
           when   2  =>  RXUSRDIVISOR_BINARY := "00010";
           when   4  =>  RXUSRDIVISOR_BINARY := "00100";
           when   8  =>  RXUSRDIVISOR_BINARY := "01000";
           when   16  =>  RXUSRDIVISOR_BINARY := "10000";
           when others  =>  assert FALSE report "Error : RXUSRDIVISOR is not in 1, 2, 4, 8, 16." severity error;
       end case;
       case SAMPLE_8X is
           when FALSE   =>  SAMPLE_8X_BINARY := '0';
           when TRUE    =>  SAMPLE_8X_BINARY := '1';
           when others  =>  assert FALSE report "Error : SAMPLE_8X is neither TRUE nor FALSE." severity error;
       end case;
       case ENABLE_DCDR is
           when FALSE   =>  ENABLE_DCDR_BINARY := '0';
           when TRUE    =>  ENABLE_DCDR_BINARY := '1';
           when others  =>  assert FALSE report "Error : ENABLE_DCDR is neither TRUE nor FALSE." severity error;
       end case;
       case REPEATER is
           when FALSE   =>  REPEATER_BINARY := '0';
           when TRUE    =>  REPEATER_BINARY := '1';
           when others  =>  assert FALSE report "Error : REPEATER is neither TRUE nor FALSE." severity error;
       end case;
       case RXBY_32 is
           when FALSE   =>  RXBY_32_BINARY := '0';
           when TRUE    =>  RXBY_32_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXBY_32 is neither TRUE nor FALSE." severity error;
       end case;
--     case TXFDCAL_CLOCK_DIVIDE is
           if((TXFDCAL_CLOCK_DIVIDE = "NONE") or (TXFDCAL_CLOCK_DIVIDE = "none")) then
               TXFDCAL_CLOCK_DIVIDE_BINARY := "00";
           elsif((TXFDCAL_CLOCK_DIVIDE = "TWO") or (TXFDCAL_CLOCK_DIVIDE = "two")) then
               TXFDCAL_CLOCK_DIVIDE_BINARY := "01";
           elsif((TXFDCAL_CLOCK_DIVIDE = "FOUR") or (TXFDCAL_CLOCK_DIVIDE = "four")) then
               TXFDCAL_CLOCK_DIVIDE_BINARY := "10";
           else
             assert FALSE report "Error : TXFDCAL_CLOCK_DIVIDE = is not NONE, TWO, FOUR." severity error;
           end if;
--     end case;
--     case RXFDCAL_CLOCK_DIVIDE is
           if((RXFDCAL_CLOCK_DIVIDE = "NONE") or (RXFDCAL_CLOCK_DIVIDE = "none")) then
               RXFDCAL_CLOCK_DIVIDE_BINARY := "00";
           elsif((RXFDCAL_CLOCK_DIVIDE = "TWO") or (RXFDCAL_CLOCK_DIVIDE = "two")) then
               RXFDCAL_CLOCK_DIVIDE_BINARY := "01";
           elsif((RXFDCAL_CLOCK_DIVIDE = "FOUR") or (RXFDCAL_CLOCK_DIVIDE = "four")) then
               RXFDCAL_CLOCK_DIVIDE_BINARY := "10";
           else
             assert FALSE report "Error : RXFDCAL_CLOCK_DIVIDE = is not NONE, TWO, FOUR." severity error;
           end if;
--     end case;
       case RXVCO_CTRL_ENABLE is
           when FALSE   =>  RXVCO_CTRL_ENABLE_BINARY := '0';
           when TRUE    =>  RXVCO_CTRL_ENABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXVCO_CTRL_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case VCO_CTRL_ENABLE is
           when FALSE   =>  VCO_CTRL_ENABLE_BINARY := '0';
           when TRUE    =>  VCO_CTRL_ENABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : VCO_CTRL_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case RXCRCCLOCKDOUBLE is
           when FALSE   =>  RXCRCCLOCKDOUBLE_BINARY := '0';
           when TRUE    =>  RXCRCCLOCKDOUBLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXCRCCLOCKDOUBLE is neither TRUE nor FALSE." severity error;
       end case;
       case RXCRCINVERTGEN is
           when FALSE   =>  RXCRCINVERTGEN_BINARY := '0';
           when TRUE    =>  RXCRCINVERTGEN_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXCRCINVERTGEN is neither TRUE nor FALSE." severity error;
       end case;
       case RXCRCSAMECLOCK is
           when FALSE   =>  RXCRCSAMECLOCK_BINARY := '0';
           when TRUE    =>  RXCRCSAMECLOCK_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXCRCSAMECLOCK is neither TRUE nor FALSE." severity error;
       end case;
       case RXCRCENABLE is
           when FALSE   =>  RXCRCENABLE_BINARY := '0';
           when TRUE    =>  RXCRCENABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXCRCENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case TXCRCCLOCKDOUBLE is
           when FALSE   =>  TXCRCCLOCKDOUBLE_BINARY := '0';
           when TRUE    =>  TXCRCCLOCKDOUBLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXCRCCLOCKDOUBLE is neither TRUE nor FALSE." severity error;
       end case;
       case TXCRCINVERTGEN is
           when FALSE   =>  TXCRCINVERTGEN_BINARY := '0';
           when TRUE    =>  TXCRCINVERTGEN_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXCRCINVERTGEN is neither TRUE nor FALSE." severity error;
       end case;
       case TXCRCSAMECLOCK is
           when FALSE   =>  TXCRCSAMECLOCK_BINARY := '0';
           when TRUE    =>  TXCRCSAMECLOCK_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXCRCSAMECLOCK is neither TRUE nor FALSE." severity error;
       end case;
       case TXCRCENABLE is
           when FALSE   =>  TXCRCENABLE_BINARY := '0';
           when TRUE    =>  TXCRCENABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXCRCENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case RXCLK0_FORCE_PMACLK is
           when FALSE   =>  RXCLK0_FORCE_PMACLK_BINARY := '0';
           when TRUE    =>  RXCLK0_FORCE_PMACLK_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXCLK0_FORCE_PMACLK is neither TRUE nor FALSE." severity error;
       end case;
       case TXCLK0_FORCE_PMACLK is
           when FALSE   =>  TXCLK0_FORCE_PMACLK_BINARY := '0';
           when TRUE    =>  TXCLK0_FORCE_PMACLK_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXCLK0_FORCE_PMACLK is neither TRUE nor FALSE." severity error;
       end case;
       case TXOUTCLK1_USE_SYNC is
           when FALSE   =>  TXOUTCLK1_USE_SYNC_BINARY := '0';
           when TRUE    =>  TXOUTCLK1_USE_SYNC_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXOUTCLK1_USE_SYNC is neither TRUE nor FALSE." severity error;
       end case;
       case RXRECCLK1_USE_SYNC is
           when FALSE   =>  RXRECCLK1_USE_SYNC_BINARY := '0';
           when TRUE    =>  RXRECCLK1_USE_SYNC_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXRECCLK1_USE_SYNC is neither TRUE nor FALSE." severity error;
       end case;
--     case RXPMACLKSEL is
           if((RXPMACLKSEL = "REFCLK1") or (RXPMACLKSEL = "refclk1")) then
               RXPMACLKSEL_BINARY := "00";
           elsif((RXPMACLKSEL = "REFCLK2") or (RXPMACLKSEL = "refclk2")) then
               RXPMACLKSEL_BINARY := "01";
           elsif((RXPMACLKSEL = "GREFCLK") or (RXPMACLKSEL = "grefclk")) then
               RXPMACLKSEL_BINARY := "10";
           else
             assert FALSE report "Error : RXPMACLKSEL = is not REFCLK1, REFCLK2, GREFCLK." severity error;
           end if;
--     end case;
--     case TXABPMACLKSEL is
           if((TXABPMACLKSEL = "REFCLK1") or (TXABPMACLKSEL = "refclk1")) then
               TXABPMACLKSEL_BINARY := "00";
           elsif((TXABPMACLKSEL = "REFCLK2") or (TXABPMACLKSEL = "refclk2")) then
               TXABPMACLKSEL_BINARY := "01";
           elsif((TXABPMACLKSEL = "GREFCLK") or (TXABPMACLKSEL = "grefclk")) then
               TXABPMACLKSEL_BINARY := "10";
           else
             assert FALSE report "Error : TXABPMACLKSEL = is not REFCLK1, REFCLK2, GREFCLK." severity error;
           end if;
--     end case;
       case BANDGAPSEL is
           when FALSE   =>  BANDGAPSEL_BINARY := '0';
           when TRUE    =>  BANDGAPSEL_BINARY := '1';
           when others  =>  assert FALSE report "Error : BANDGAPSEL is neither TRUE nor FALSE." severity error;
       end case;
       case BIASRESSEL is
           when FALSE   =>  BIASRESSEL_BINARY := '0';
           when TRUE    =>  BIASRESSEL_BINARY := '1';
           when others  =>  assert FALSE report "Error : BIASRESSEL is neither TRUE nor FALSE." severity error;
       end case;
       case TXPHASESEL is
           when FALSE   =>  TXPHASESEL_BINARY := '0';
           when TRUE    =>  TXPHASESEL_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXPHASESEL is neither TRUE nor FALSE." severity error;
       end case;
       case PMACLKENABLE is
           when FALSE   =>  PMACLKENABLE_BINARY := '0';
           when TRUE    =>  PMACLKENABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : PMACLKENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case PMACOREPWRENABLE is
           when FALSE   =>  PMACOREPWRENABLE_BINARY := '0';
           when TRUE    =>  PMACOREPWRENABLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : PMACOREPWRENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case PMA_BIT_SLIP is
           when FALSE   =>  PMA_BIT_SLIP_BINARY := '0';
           when TRUE    =>  PMA_BIT_SLIP_BINARY := '1';
           when others  =>  assert FALSE report "Error : PMA_BIT_SLIP is neither TRUE nor FALSE." severity error;
       end case;
       case RXLB is
           when FALSE   =>  RXLB_BINARY := '0';
           when TRUE    =>  RXLB_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXLB is neither TRUE nor FALSE." severity error;
       end case;
       case RXDCCOUPLE is
           when FALSE   =>  RXDCCOUPLE_BINARY := '0';
           when TRUE    =>  RXDCCOUPLE_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXDCCOUPLE is neither TRUE nor FALSE." severity error;
       end case;
       case RXDIGRESET is
           when FALSE   =>  RXDIGRESET_BINARY := '0';
           when TRUE    =>  RXDIGRESET_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXDIGRESET is neither TRUE nor FALSE." severity error;
       end case;
       case RXCPTST is
           when FALSE   =>  RXCPTST_BINARY := '0';
           when TRUE    =>  RXCPTST_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXCPTST is neither TRUE nor FALSE." severity error;
       end case;
       case RXPDDTST is
           when FALSE   =>  RXPDDTST_BINARY := '0';
           when TRUE    =>  RXPDDTST_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXPDDTST is neither TRUE nor FALSE." severity error;
       end case;
       case RXACTST is
           when FALSE   =>  RXACTST_BINARY := '0';
           when TRUE    =>  RXACTST_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXACTST is neither TRUE nor FALSE." severity error;
       end case;
       case RXAFETST is
           when FALSE   =>  RXAFETST_BINARY := '0';
           when TRUE    =>  RXAFETST_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXAFETST is neither TRUE nor FALSE." severity error;
       end case;
       case RXLKAPD is
           when FALSE   =>  RXLKAPD_BINARY := '0';
           when TRUE    =>  RXLKAPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXLKAPD is neither TRUE nor FALSE." severity error;
       end case;
       case RXRSDPD is
           when FALSE   =>  RXRSDPD_BINARY := '0';
           when TRUE    =>  RXRSDPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXRSDPD is neither TRUE nor FALSE." severity error;
       end case;
       case RXRCPPD is
           when FALSE   =>  RXRCPPD_BINARY := '0';
           when TRUE    =>  RXRCPPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXRCPPD is neither TRUE nor FALSE." severity error;
       end case;
       case RXRPDPD is
           when FALSE   =>  RXRPDPD_BINARY := '0';
           when TRUE    =>  RXRPDPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXRPDPD is neither TRUE nor FALSE." severity error;
       end case;
       case RXAFEPD is
           when FALSE   =>  RXAFEPD_BINARY := '0';
           when TRUE    =>  RXAFEPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXAFEPD is neither TRUE nor FALSE." severity error;
       end case;
       case RXPD is
           when FALSE   =>  RXPD_BINARY := '0';
           when TRUE    =>  RXPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXPD is neither TRUE nor FALSE." severity error;
       end case;
       case TXOUTDIV2SEL is
           when   1  =>  TXOUTDIV2SEL_BINARY := "0001";
           when   2  =>  TXOUTDIV2SEL_BINARY := "0010";
           when   4  =>  TXOUTDIV2SEL_BINARY := "0011";
           when   8  =>  TXOUTDIV2SEL_BINARY := "0100";
           when   16  =>  TXOUTDIV2SEL_BINARY := "0101";
           when   32  =>  TXOUTDIV2SEL_BINARY := "0110";
           when others  =>  assert FALSE report "Error : TXOUTDIV2SEL is not in 1, 2, 4, 8, 16, 32." severity error;
       end case;
       case TXPLLNDIVSEL is
           when   8  =>  TXPLLNDIVSEL_BINARY := "0000";
           when   10  =>  TXPLLNDIVSEL_BINARY := "0010";
           when   16  =>  TXPLLNDIVSEL_BINARY := "0100";
           when   20  =>  TXPLLNDIVSEL_BINARY := "0110";
           when   32  =>  TXPLLNDIVSEL_BINARY := "1000";
           when   40  =>  TXPLLNDIVSEL_BINARY := "1010";
           when others  =>  assert FALSE report "Error : TXPLLNDIVSEL is not in 8, 10, 16, 20, 32, 40." severity error;
       end case;
       case TXCPSEL is
           when FALSE   =>  TXCPSEL_BINARY := '0';
           when TRUE    =>  TXCPSEL_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXCPSEL is neither TRUE nor FALSE." severity error;
       end case;
       case TXAPD is
           when FALSE   =>  TXAPD_BINARY := '0';
           when TRUE    =>  TXAPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXAPD is neither TRUE nor FALSE." severity error;
       end case;
       case TXLVLSHFTPD is
           when FALSE   =>  TXLVLSHFTPD_BINARY := '0';
           when TRUE    =>  TXLVLSHFTPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXLVLSHFTPD is neither TRUE nor FALSE." severity error;
       end case;
       case TXPRE_TAP_PD is
           when FALSE   =>  TXPRE_TAP_PD_BINARY := '0';
           when TRUE    =>  TXPRE_TAP_PD_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXPRE_TAP_PD is neither TRUE nor FALSE." severity error;
       end case;
       case TXDIGPD is
           when FALSE   =>  TXDIGPD_BINARY := '0';
           when TRUE    =>  TXDIGPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXDIGPD is neither TRUE nor FALSE." severity error;
       end case;
       case TXHIGHSIGNALEN is
           when FALSE   =>  TXHIGHSIGNALEN_BINARY := '0';
           when TRUE    =>  TXHIGHSIGNALEN_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXHIGHSIGNALEN is neither TRUE nor FALSE." severity error;
       end case;
       case TXAREFBIASSEL is
           when FALSE   =>  TXAREFBIASSEL_BINARY := '0';
           when TRUE    =>  TXAREFBIASSEL_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXAREFBIASSEL is neither TRUE nor FALSE." severity error;
       end case;
       case TXSLEWRATE is
           when FALSE   =>  TXSLEWRATE_BINARY := '0';
           when TRUE    =>  TXSLEWRATE_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXSLEWRATE is neither TRUE nor FALSE." severity error;
       end case;
       case TXPOST_TAP_PD is
           when FALSE   =>  TXPOST_TAP_PD_BINARY := '0';
           when TRUE    =>  TXPOST_TAP_PD_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXPOST_TAP_PD is neither TRUE nor FALSE." severity error;
       end case;
       case TXPD is
           when FALSE   =>  TXPD_BINARY := '0';
           when TRUE    =>  TXPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : TXPD is neither TRUE nor FALSE." severity error;
       end case;
       case RXOUTDIV2SEL is
           when   1  =>  RXOUTDIV2SEL_BINARY := "00010001";
           when   2  =>  RXOUTDIV2SEL_BINARY := "00100010";
           when   4  =>  RXOUTDIV2SEL_BINARY := "00110011";
           when   8  =>  RXOUTDIV2SEL_BINARY := "01000100";
           when   16  =>  RXOUTDIV2SEL_BINARY := "01010101";
           when   32  =>  RXOUTDIV2SEL_BINARY := "01100110";
           when others  =>  assert FALSE report "Error : RXOUTDIV2SEL is not in 1, 2, 4, 8, 16, 32." severity error;
       end case;
       case RXPLLNDIVSEL is
           when   8  =>  RXPLLNDIVSEL_BINARY := "0000";
           when   10  =>  RXPLLNDIVSEL_BINARY := "0010";
           when   16  =>  RXPLLNDIVSEL_BINARY := "0100";
           when   20  =>  RXPLLNDIVSEL_BINARY := "0110";
           when   32  =>  RXPLLNDIVSEL_BINARY := "1000";
           when   40  =>  RXPLLNDIVSEL_BINARY := "1010";
           when others  =>  assert FALSE report "Error : RXPLLNDIVSEL is not in 8, 10, 16, 20, 32, 40." severity error;
       end case;
       case RXDIGRX is
           when FALSE   =>  RXDIGRX_BINARY := '0';
           when TRUE    =>  RXDIGRX_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXDIGRX is neither TRUE nor FALSE." severity error;
       end case;
       case RXCPSEL is
           when FALSE   =>  RXCPSEL_BINARY := '0';
           when TRUE    =>  RXCPSEL_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXCPSEL is neither TRUE nor FALSE." severity error;
       end case;
       case RXAPD is
           when FALSE   =>  RXAPD_BINARY := '0';
           when TRUE    =>  RXAPD_BINARY := '1';
           when others  =>  assert FALSE report "Error : RXAPD is neither TRUE nor FALSE." severity error;
       end case;

synDigCfgChnBnd1(63) <=	'0';--RESERVED_CB1;  
synDigCfgChnBnd1(62) <=	TX_BUFFER_USE_BINARY;  
synDigCfgChnBnd1(61) <=	RX_BUFFER_USE_BINARY;  
synDigCfgChnBnd1(60 downto 58) <=	CHAN_BOND_SEQ_LEN_BINARY;  
synDigCfgChnBnd1(57) <=	CHAN_BOND_SEQ_2_USE_BINARY;  
synDigCfgChnBnd1(56) <=	CHAN_BOND_ONE_SHOT_BINARY;  
synDigCfgChnBnd1(55 downto 54) <=	CHAN_BOND_MODE_BINARY;  
synDigCfgChnBnd1(53 downto 48) <=	CHAN_BOND_LIMIT_BINARY;  
synDigCfgChnBnd1(47 downto 44) <=	CHAN_BOND_SEQ_1_MASK_BINARY;  
synDigCfgChnBnd1(43 downto 33) <=	CHAN_BOND_SEQ_1_4_BINARY;  
synDigCfgChnBnd1(32 downto 22) <=	CHAN_BOND_SEQ_1_3_BINARY;  
synDigCfgChnBnd1(21 downto 11) <=	CHAN_BOND_SEQ_1_2_BINARY;  
synDigCfgChnBnd1(10 downto 0) <=	CHAN_BOND_SEQ_1_1_BINARY;	 



synDigCfgChnBnd2(63 downto 56) <= "00000000";--	CHAN_BOND_TUNE;  
synDigCfgChnBnd2(55) <=	'0';    -- unused
synDigCfgChnBnd2(54) <=	'0';    -- unused
synDigCfgChnBnd2(53) <=	CCCB_ARBITRATOR_DISABLE_BINARY;
synDigCfgChnBnd2(52) <=	OPPOSITE_SELECT_BINARY;  
synDigCfgChnBnd2(51) <=	POWER_ENABLE_BINARY;
synDigCfgChnBnd2(50 downto 48) <=	"000";  
synDigCfgChnBnd2(47 downto 44) <=	CHAN_BOND_SEQ_2_MASK_BINARY;  
synDigCfgChnBnd2(43 downto 33) <=	CHAN_BOND_SEQ_2_4_BINARY;  
synDigCfgChnBnd2(32 downto 22) <=	CHAN_BOND_SEQ_2_3_BINARY;  
synDigCfgChnBnd2(21 downto 11) <=	CHAN_BOND_SEQ_2_2_BINARY;  
synDigCfgChnBnd2(10 downto 0) <=	CHAN_BOND_SEQ_2_1_BINARY;	 



synDigCfgClkCor1(63 downto 62) <=	RXDATA_SEL_BINARY;
synDigCfgClkCor1(61 downto 60) <=	TXDATA_SEL_BINARY;
synDigCfgClkCor1(59) <=	'0';--RESERVED_CCB;                                                          
synDigCfgClkCor1(58 downto 53) <=	CLK_COR_MIN_LAT_BINARY;  
synDigCfgClkCor1(52) <=	'0';--RESERVED_CCA;
synDigCfgClkCor1(51) <=	PCS_BIT_SLIP_BINARY;
synDigCfgClkCor1(50) <=	DIGRX_SYNC_MODE_BINARY;
synDigCfgClkCor1(49 downto 48) <=	DIGRX_FWDCLK_BINARY;
synDigCfgClkCor1(47 downto 44) <=	CLK_COR_SEQ_1_MASK_BINARY;  
synDigCfgClkCor1(43 downto 33) <=	CLK_COR_SEQ_1_4_BINARY;  
synDigCfgClkCor1(32 downto 22) <=	CLK_COR_SEQ_1_3_BINARY;  
synDigCfgClkCor1(21 downto 11) <=	CLK_COR_SEQ_1_2_BINARY;  
synDigCfgClkCor1(10 downto 0) <=	CLK_COR_SEQ_1_1_BINARY;	 



synDigCfgClkCor2(63 downto 56) <=	"00000000"; --RX_LOS_THRESHOLD_BINARY;  
synDigCfgClkCor2(55 downto 48) <=	"00000000"; --RX_LOS_INVALID_INCR_BINARY;  
synDigCfgClkCor2(47 downto 44) <=	CLK_COR_SEQ_2_MASK_BINARY;  
synDigCfgClkCor2(43 downto 33) <=	CLK_COR_SEQ_2_4_BINARY;  
synDigCfgClkCor2(32 downto 22) <=	CLK_COR_SEQ_2_3_BINARY;  
synDigCfgClkCor2(21 downto 11) <=	CLK_COR_SEQ_2_2_BINARY;  
synDigCfgClkCor2(10 downto 0) <=	CLK_COR_SEQ_2_1_BINARY;	 



synDigCfgMisc(63) <=	RXRECCLK1_USE_SYNC_BINARY;  
synDigCfgMisc(62) <=	TXOUTCLK1_USE_SYNC_BINARY;  
synDigCfgMisc(61) <=	TXCLK0_FORCE_PMACLK_BINARY;  
synDigCfgMisc(60) <=	RXCLK0_FORCE_PMACLK_BINARY;  
synDigCfgMisc(59 downto 58) <=	TX_CLOCK_DIVIDER_BINARY;  
synDigCfgMisc(57 downto 56) <=	RX_CLOCK_DIVIDER_BINARY;  
synDigCfgMisc(55) <=	TXCRCENABLE_BINARY;  
synDigCfgMisc(54) <=	TXCRCSAMECLOCK_BINARY;  
synDigCfgMisc(53) <=	TXCRCINVERTGEN_BINARY;  
synDigCfgMisc(52) <=	TXCRCCLOCKDOUBLE_BINARY;  
synDigCfgMisc(51) <=	RXCRCENABLE_BINARY;  
synDigCfgMisc(50) <=	RXCRCSAMECLOCK_BINARY;  
synDigCfgMisc(49) <=	RXCRCINVERTGEN_BINARY;  
synDigCfgMisc(48) <=	RXCRCCLOCKDOUBLE_BINARY;  
synDigCfgMisc(47 downto 46) <=	RXFDCAL_CLOCK_DIVIDE_BINARY;  
synDigCfgMisc(45 downto 44) <=	TXFDCAL_CLOCK_DIVIDE_BINARY;  
synDigCfgMisc(43) <=	RXBY_32_BINARY;  
synDigCfgMisc(42) <=	REPEATER_BINARY;  
synDigCfgMisc(41) <=	ENABLE_DCDR_BINARY;  
synDigCfgMisc(40) <=	SAMPLE_8X_BINARY;  
synDigCfgMisc(39 downto 37) <=	DCDR_FILTER_BINARY;  
synDigCfgMisc(36 downto 32) <=	RXUSRDIVISOR_BINARY;  
synDigCfgMisc(31 downto 24) <=	SH_INVALID_CNT_MAX_BINARY;  
synDigCfgMisc(23 downto 16) <=	SH_CNT_MAX_BINARY;  
synDigCfgMisc(15) <=	'0';--RESERVED_M2;  
synDigCfgMisc(14) <=	CLK_COR_8B10B_DE_BINARY;  
synDigCfgMisc(13) <=	CLK_CORRECT_USE_BINARY;  
synDigCfgMisc(12 downto 10) <=	CLK_COR_SEQ_LEN_BINARY;  
synDigCfgMisc(9) <=	CLK_COR_SEQ_DROP_BINARY;  
synDigCfgMisc(8) <=	CLK_COR_SEQ_2_USE_BINARY;  
synDigCfgMisc(7) <=	'0';--TXCLK0_INVERT_PMALEAF;  
synDigCfgMisc(6) <=	'0';--RXCLK0_INVERT_PMALEAF;  	 
synDigCfgMisc(5 downto 0) <=	CLK_COR_MAX_LAT_BINARY;	 



synDigCfgComma1(63 downto 42) <=	"0000000000000000000000";--COMMA_32B_MASK;
synDigCfgComma1(41 downto 32) <=	COMMA_10B_MASK_BINARY;
synDigCfgComma1(31 downto 8) <=	"000000000000000000000000";--RESERVED_CM;
synDigCfgComma1(7) <=	COMMA32_BINARY;  
synDigCfgComma1(6) <=	PCOMMA_DETECT_BINARY;  
synDigCfgComma1(5) <=	MCOMMA_DETECT_BINARY;  
synDigCfgComma1(4) <=	DEC_VALID_COMMA_ONLY_BINARY;  
synDigCfgComma1(3) <=	DEC_PCOMMA_DETECT_BINARY;  
synDigCfgComma1(2) <=	DEC_MCOMMA_DETECT_BINARY;  
synDigCfgComma1(1 downto 0) <=	ALIGN_COMMA_WORD_BINARY;	 



synDigCfgComma2(63 downto 32) <=	PCOMMA_32B_VALUE_BINARY;  
synDigCfgComma2(31 downto 0) <=	MCOMMA_32B_VALUE_BINARY;	 



synDigCfgSynPmaFD(63) <=       '1';--  AUTO_CAL;  
synDigCfgSynPmaFD(62 downto 53) <=	VCODAC_INIT_BINARY;  
synDigCfgSynPmaFD(52 downto 51) <=	"00";--SLOWDOWN_CAL;  
synDigCfgSynPmaFD(50) <=	'0';--  BYPASS_FDET;  
synDigCfgSynPmaFD(49 downto 48) <=	LOOPCAL_WAIT_BINARY;  
synDigCfgSynPmaFD(47) <=	'0';--  BYPASS_CAL;  
synDigCfgSynPmaFD(46 downto 44) <=	FDET_HYS_CAL_BINARY;  
synDigCfgSynPmaFD(43 downto 41) <=	FDET_LCK_CAL_BINARY;  
synDigCfgSynPmaFD(40 downto 38) <=	FDET_HYS_SEL_BINARY;  
synDigCfgSynPmaFD(37 downto 35) <=	FDET_LCK_SEL_BINARY;  
synDigCfgSynPmaFD(34) <=	VCO_CTRL_ENABLE_BINARY;  
synDigCfgSynPmaFD(33 downto 32) <=	CYCLE_LIMIT_SEL_BINARY;  
synDigCfgSynPmaFD(31) <=	'1';--  RXAUTO_CAL;  
synDigCfgSynPmaFD(30 downto 21) <=	RXVCODAC_INIT_BINARY;  
synDigCfgSynPmaFD(20 downto 19) <=	RXSLOWDOWN_CAL_BINARY;  
synDigCfgSynPmaFD(18) <=	'0';--  RXBYPASS_FDET;  
synDigCfgSynPmaFD(17 downto 16) <=	RXLOOPCAL_WAIT_BINARY;  
synDigCfgSynPmaFD(15) <=	'0';--  RXBYPASS_CAL;  
synDigCfgSynPmaFD(14 downto 12) <=	RXFDET_HYS_CAL_BINARY;  
synDigCfgSynPmaFD(11 downto 9) <=	RXFDET_LCK_CAL_BINARY;  
synDigCfgSynPmaFD(8 downto 6) <=	RXFDET_HYS_SEL_BINARY;  
synDigCfgSynPmaFD(5 downto 3) <=	RXFDET_LCK_SEL_BINARY;  
synDigCfgSynPmaFD(2) <=	RXVCO_CTRL_ENABLE_BINARY;  
synDigCfgSynPmaFD(1 downto 0) <=	RXCYCLE_LIMIT_SEL_BINARY;	 



synDigCfgCrc(63 downto 32) <=	TXCRCINITVAL_BINARY;  
synDigCfgCrc(31 downto 0) <=	RXCRCINITVAL_BINARY;	 



PMACFG(63 downto 62) <=	"00";  
PMACFG(61 downto 60) <=	RXPMACLKSEL_BINARY;  
PMACFG(59 downto 58) <=	RXPMACLKSEL_BINARY;   
PMACFG(57 downto 56) <=	TXABPMACLKSEL_BINARY;  
PMACFG(55 downto 48) <=	"00000000";  
PMACFG(47) <=	'0';--  PMATUNE;  
PMACFG(46 downto 42) <=	"00000";--  TXREGCTRL;  
PMACFG(41 downto 37) <=	RXAREGCTRL_BINARY;  
PMACFG(36 downto 32) <=	PMAVBGCTRL_BINARY;
PMACFG(31) <=	BANDGAPSEL_BINARY;  
PMACFG(30 downto 27) <=	PMAIREFTRIM_BINARY;  
PMACFG(26 downto 25) <=	IREFBIASMODE_BINARY;  
PMACFG(24) <=	BIASRESSEL_BINARY;  
PMACFG(23 downto 20) <=	PMAVREFTRIM_BINARY;  
PMACFG(19) <=	'0';--VREFSELECT;  
PMACFG(18 downto 17) <=	VREFBIASMODE_BINARY;  
PMACFG(16) <=	'0';--  PMABIASPD;  
PMACFG(15 downto 14) <=	"00";
PMACFG(13) <=	'0';  
PMACFG(12) <=	'0';--  ATBBUMPEN;  
PMACFG(11) <=	'0';--  NATBENABLE;  
PMACFG(10 downto 5) <=	"000000";  
PMACFG(4) <=	TXPHASESEL_BINARY;
PMACFG(3) <=	'0';            --UNUSED
PMACFG(2) <=	'0';--  PMACTRL;                                        
PMACFG(1) <=	PMACLKENABLE_BINARY;--'0';--  PMACLKENABLEPD;  
PMACFG(0) <=	PMACOREPWRENABLE_BINARY;	 

PMACFG2(63 downto 18) <= "0000000000000000000000000000000000000000000000";
PMACFG2(17 downto 0) <= "000000000000000000";

RXAFECFG(63 downto 58) <= RXMODE_BINARY;
RXAFECFG(57) <=	PMA_BIT_SLIP_BINARY;
RXAFECFG(56 downto 55) <=	RXASYNCDIVIDE_BINARY;
RXAFECFG(54 downto 49) <=	RXCLKMODE_BINARY;  
RXAFECFG(48) <=	RXLB_BINARY;  
RXAFECFG(47 downto 46) <=	RXFETUNE_BINARY;  
RXAFECFG(45 downto 43) <=	RXRCPADJ_BINARY;--"00";--  RXRCPADJ;  
RXAFECFG(42 downto 41) <=	RXRIBADJ_BINARY;  
RXAFECFG(40 downto 32) <=	RXAFEEQ_BINARY;  
RXAFECFG(31 downto 30) <=	RXCMADJ_BINARY;  
RXAFECFG(29 downto 24) <=	RXCDRLOS_BINARY;  
RXAFECFG(23) <=	'0';
RXAFECFG(22) <=	RXDCCOUPLE_BINARY;
RXAFECFG(21) <=	'0';  
RXAFECFG(20 downto 16) <=	RXLKADJ_BINARY;  
RXAFECFG(15) <=	RXDIGRESET_BINARY;  
RXAFECFG(14 downto 12) <=	RXFECONTROL2_BINARY;  
RXAFECFG(11) <=	RXCPTST_BINARY;  
RXAFECFG(10) <=	RXPDDTST_BINARY;  
RXAFECFG(9) <=	RXACTST_BINARY;  
RXAFECFG(8) <=	RXAFETST_BINARY;  
RXAFECFG(7 downto 6) <=	RXFECONTROL1_BINARY;  
RXAFECFG(5) <=	RXLKAPD_BINARY;  
RXAFECFG(4) <=	RXRSDPD_BINARY;  
RXAFECFG(3) <=	RXRCPPD_BINARY;  
RXAFECFG(2) <=	RXRPDPD_BINARY;  
RXAFECFG(1) <=	RXAFEPD_BINARY;  
RXAFECFG(0) <=	RXPD_BINARY;	 



RXAEQCFG(63 downto 0) <= RXEQ_BINARY;	 



TXCLCFG(63 downto 60) <=	TXOUTDIV2SEL_BINARY;  
TXCLCFG(59 downto 56) <=	TXPLLNDIVSEL_BINARY;  
TXCLCFG(55 downto 54) <=	TXCLMODE_BINARY;  
TXCLCFG(53 downto 50) <=	TXLOOPFILT_BINARY;  
TXCLCFG(49) <=	'0';--  UNUSED;  
TXCLCFG(48) <=	'0';--  UNUSED;  
TXCLCFG(47 downto 35) <= TXTUNE_BINARY;
TXCLCFG(34) <=	'0';--  UNUSED;  
TXCLCFG(33) <=	'0';--  --UNUSED;  
TXCLCFG(32) <=	TXCPSEL_BINARY;
TXCLCFG(31) <=	'0';            --TXDACTST
TXCLCFG(30 downto 27) <=	TXOUTDIV2SEL_BINARY;
TXCLCFG(26 downto 17) <=	TXCTRL1_BINARY;
TXCLCFG(16) <=	'0';--  TXQPPD;  
TXCLCFG(15) <=	'0';--  TXCMFPD;  
TXCLCFG(14) <=	'0';--  TXVCOPD;  
TXCLCFG(13) <=	'0';--  TXADCADJPD;  
TXCLCFG(12) <=	'0';--  TXDIVPD;  
TXCLCFG(11) <=	'0';--  TXBIASPD;  
TXCLCFG(10) <=	'0';--  TXDIVBUFPD;  
TXCLCFG(9) <=	'0';--  TXVCOBUFPD;  
TXCLCFG(8) <=	TXAPD_BINARY;  
TXCLCFG(7) <=	'0';--  TXAPTST;  
TXCLCFG(6) <=	'0';--  TXCMFTST;  
TXCLCFG(5) <=	'0';--  TXFILTTST;  
TXCLCFG(4) <=	'0';--  TXDIVTST;  
TXCLCFG(3) <=	'0';--  TXPFDTST;  
TXCLCFG(2) <=	'0';--  TXVCOBUFTST;  
TXCLCFG(1) <=	'0';--  TXDIVBUFTST;  
TXCLCFG(0) <=	'0';--  TXVCOTST;	 



TXACFG(63 downto 60) <=	"0000";
TXACFG(59) <=	TXLVLSHFTPD_BINARY;
TXACFG(58 downto 56) <=	TXPRE_PRDRV_DAC_BINARY;
TXACFG(55) <=	TXPRE_TAP_PD_BINARY;
TXACFG(54 downto 53) <=	TXPRE_TAP_DAC_BINARY(4 downto 3);
TXACFG(52) <=	TXDIGPD_BINARY;
TXACFG(51 downto 48) <=	TXCLKMODE_BINARY;  
TXACFG(47 downto 45) <=	TXPRE_TAP_DAC_BINARY(2 downto 0);
TXACFG(44) <=	'0';  
TXACFG(43) <=	TXHIGHSIGNALEN_BINARY;  
TXACFG(42) <=	TXAREFBIASSEL_BINARY;  
TXACFG(41 downto 38) <=	TXTERMTRIM_BINARY;  
TXACFG(37) <=	TXASYNCDIVIDE_BINARY(1);  
TXACFG(36) <=	TXSLEWRATE_BINARY;
TXACFG(35 downto 33) <=	TXPOST_PRDRV_DAC_BINARY;  
TXACFG(32 downto 30) <=	TXDAT_PRDRV_DAC_BINARY;  
TXACFG(29) <=	TXASYNCDIVIDE_BINARY(0);  
TXACFG(28) <=	TXPOST_TAP_PD_BINARY;  
TXACFG(27 downto 23) <=	TXPOST_TAP_DAC_BINARY;  
TXACFG(22 downto 21) <=	"00";--  TXTUNE1;  
TXACFG(20 downto 16) <=	TXDAT_TAP_DAC_BINARY;  
TXACFG(15 downto 1) <=	"000000000000000";--  TXDIG_TST;  
TXACFG(0) <=	TXPD_BINARY;	 



RXACLCFG(63 downto 60) <= RXOUTDIV2SEL_BINARY(7 downto 4);  
RXACLCFG(59 downto 56) <= RXPLLNDIVSEL_BINARY;  
RXACLCFG(55 downto 54) <= RXCLMODE_BINARY;  
RXACLCFG(53 downto 50) <= RXLOOPFILT_BINARY;  
RXACLCFG(49) <=	RXDIGRX_BINARY;  
RXACLCFG(48) <=	'0';--  RXPFDTX;  
RXACLCFG(47 downto 35) <= RXTUNE_BINARY;  
RXACLCFG(34) <=	'0';--  RXSLOSEL;  
RXACLCFG(33) <=	'0';--  RXDACSEL;  
RXACLCFG(32) <=	RXCPSEL_BINARY;  
RXACLCFG(31) <=	'0';--  RXDACTST;  
RXACLCFG(30 downto 27) <= RXOUTDIV2SEL_BINARY(3 downto 0);
RXACLCFG(26 downto 17) <= RXCTRL1_BINARY;
RXACLCFG(16) <=	'0';--  RXQPPD;  
RXACLCFG(15) <=	'1';--  RXCMFPD;  
RXACLCFG(14) <=	'0';--  RXVCOPD;  
RXACLCFG(13) <=	'0';--  RXADCADJPD;  
RXACLCFG(12) <=	'0';--  RXDIVPD;  
RXACLCFG(11) <=	'0';--  RXBIASPD;  
RXACLCFG(10) <=	'0';--  RXVCOBUFPD;  
RXACLCFG(9) <=	'0';--  RXDIVBUFPD;  
RXACLCFG(8) <=	RXAPD_BINARY;  
RXACLCFG(7) <=	'0';--  RXAPTST;  
RXACLCFG(6) <=	'0';--  RXCMFTST;  
RXACLCFG(5) <=	'0';--  RXFILTTST;  
RXACLCFG(4) <=	'0';-- RXDIVTST;  
RXACLCFG(3) <=	'0';--  RXPFDTST;  
RXACLCFG(2) <=	'0';--  RXVCOBUFTST;  
RXACLCFG(1) <=	'0';--  RXDIVBUFTST;  
RXACLCFG(0) <=	'0';--  RXVCOTST	                       
     wait;
   end process INIPROC;

   TIMING : process

--  Pin timing violations (clock input pins)

--  Pin Timing Violations (all input pins)

--  Output Pin glitch declaration
     variable  CHBONDO0_GlitchData : VitalGlitchDataType;
     variable  CHBONDO1_GlitchData : VitalGlitchDataType;
     variable  CHBONDO2_GlitchData : VitalGlitchDataType;
     variable  CHBONDO3_GlitchData : VitalGlitchDataType;
     variable  CHBONDO4_GlitchData : VitalGlitchDataType;
     variable  RXSTATUS0_GlitchData : VitalGlitchDataType;
     variable  RXSTATUS1_GlitchData : VitalGlitchDataType;
     variable  RXSTATUS2_GlitchData : VitalGlitchDataType;
     variable  RXSTATUS3_GlitchData : VitalGlitchDataType;
     variable  RXSTATUS4_GlitchData : VitalGlitchDataType;
     variable  RXSTATUS5_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA0_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA1_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA2_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA3_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA4_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA5_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA6_GlitchData : VitalGlitchDataType;
     variable  RXCHARISCOMMA7_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK0_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK1_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK2_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK3_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK4_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK5_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK6_GlitchData : VitalGlitchDataType;
     variable  RXCHARISK7_GlitchData : VitalGlitchDataType;
     variable  RXCOMMADET_GlitchData : VitalGlitchDataType;
     variable  RXDATA0_GlitchData : VitalGlitchDataType;
     variable  RXDATA1_GlitchData : VitalGlitchDataType;
     variable  RXDATA2_GlitchData : VitalGlitchDataType;
     variable  RXDATA3_GlitchData : VitalGlitchDataType;
     variable  RXDATA4_GlitchData : VitalGlitchDataType;
     variable  RXDATA5_GlitchData : VitalGlitchDataType;
     variable  RXDATA6_GlitchData : VitalGlitchDataType;
     variable  RXDATA7_GlitchData : VitalGlitchDataType;
     variable  RXDATA8_GlitchData : VitalGlitchDataType;
     variable  RXDATA9_GlitchData : VitalGlitchDataType;
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
     variable  RXDATA20_GlitchData : VitalGlitchDataType;
     variable  RXDATA21_GlitchData : VitalGlitchDataType;
     variable  RXDATA22_GlitchData : VitalGlitchDataType;
     variable  RXDATA23_GlitchData : VitalGlitchDataType;
     variable  RXDATA24_GlitchData : VitalGlitchDataType;
     variable  RXDATA25_GlitchData : VitalGlitchDataType;
     variable  RXDATA26_GlitchData : VitalGlitchDataType;
     variable  RXDATA27_GlitchData : VitalGlitchDataType;
     variable  RXDATA28_GlitchData : VitalGlitchDataType;
     variable  RXDATA29_GlitchData : VitalGlitchDataType;
     variable  RXDATA30_GlitchData : VitalGlitchDataType;
     variable  RXDATA31_GlitchData : VitalGlitchDataType;
     variable  RXDATA32_GlitchData : VitalGlitchDataType;
     variable  RXDATA33_GlitchData : VitalGlitchDataType;
     variable  RXDATA34_GlitchData : VitalGlitchDataType;
     variable  RXDATA35_GlitchData : VitalGlitchDataType;
     variable  RXDATA36_GlitchData : VitalGlitchDataType;
     variable  RXDATA37_GlitchData : VitalGlitchDataType;
     variable  RXDATA38_GlitchData : VitalGlitchDataType;
     variable  RXDATA39_GlitchData : VitalGlitchDataType;
     variable  RXDATA40_GlitchData : VitalGlitchDataType;
     variable  RXDATA41_GlitchData : VitalGlitchDataType;
     variable  RXDATA42_GlitchData : VitalGlitchDataType;
     variable  RXDATA43_GlitchData : VitalGlitchDataType;
     variable  RXDATA44_GlitchData : VitalGlitchDataType;
     variable  RXDATA45_GlitchData : VitalGlitchDataType;
     variable  RXDATA46_GlitchData : VitalGlitchDataType;
     variable  RXDATA47_GlitchData : VitalGlitchDataType;
     variable  RXDATA48_GlitchData : VitalGlitchDataType;
     variable  RXDATA49_GlitchData : VitalGlitchDataType;
     variable  RXDATA50_GlitchData : VitalGlitchDataType;
     variable  RXDATA51_GlitchData : VitalGlitchDataType;
     variable  RXDATA52_GlitchData : VitalGlitchDataType;
     variable  RXDATA53_GlitchData : VitalGlitchDataType;
     variable  RXDATA54_GlitchData : VitalGlitchDataType;
     variable  RXDATA55_GlitchData : VitalGlitchDataType;
     variable  RXDATA56_GlitchData : VitalGlitchDataType;
     variable  RXDATA57_GlitchData : VitalGlitchDataType;
     variable  RXDATA58_GlitchData : VitalGlitchDataType;
     variable  RXDATA59_GlitchData : VitalGlitchDataType;
     variable  RXDATA60_GlitchData : VitalGlitchDataType;
     variable  RXDATA61_GlitchData : VitalGlitchDataType;
     variable  RXDATA62_GlitchData : VitalGlitchDataType;
     variable  RXDATA63_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR0_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR1_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR2_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR3_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR4_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR5_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR6_GlitchData : VitalGlitchDataType;
     variable  RXDISPERR7_GlitchData : VitalGlitchDataType;
     variable  RXLOSSOFSYNC0_GlitchData : VitalGlitchDataType;
     variable  RXLOSSOFSYNC1_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE0_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE1_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE2_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE3_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE4_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE5_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE6_GlitchData : VitalGlitchDataType;
     variable  RXNOTINTABLE7_GlitchData : VitalGlitchDataType;
     variable  RXREALIGN_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP0_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP1_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP2_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP3_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP4_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP5_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP6_GlitchData : VitalGlitchDataType;
     variable  RXRUNDISP7_GlitchData : VitalGlitchDataType;
     variable  RXBUFERR_GlitchData : VitalGlitchDataType;
     variable  TXBUFERR_GlitchData : VitalGlitchDataType;
     variable  TXKERR0_GlitchData : VitalGlitchDataType;
     variable  TXKERR1_GlitchData : VitalGlitchDataType;
     variable  TXKERR2_GlitchData : VitalGlitchDataType;
     variable  TXKERR3_GlitchData : VitalGlitchDataType;
     variable  TXKERR4_GlitchData : VitalGlitchDataType;
     variable  TXKERR5_GlitchData : VitalGlitchDataType;
     variable  TXKERR6_GlitchData : VitalGlitchDataType;
     variable  TXKERR7_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP0_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP1_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP2_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP3_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP4_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP5_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP6_GlitchData : VitalGlitchDataType;
     variable  TXRUNDISP7_GlitchData : VitalGlitchDataType;
     variable  RXRECCLK1_GlitchData : VitalGlitchDataType;
     variable  RXRECCLK2_GlitchData : VitalGlitchDataType;
     variable  TXOUTCLK1_GlitchData : VitalGlitchDataType;
     variable  TXOUTCLK2_GlitchData : VitalGlitchDataType;
     variable  RXLOCK_GlitchData : VitalGlitchDataType;
     variable  TXLOCK_GlitchData : VitalGlitchDataType;
     variable  RXCYCLELIMIT_GlitchData : VitalGlitchDataType;
     variable  TXCYCLELIMIT_GlitchData : VitalGlitchDataType;
     variable  RXCALFAIL_GlitchData : VitalGlitchDataType;
     variable  TXCALFAIL_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT0_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT1_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT2_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT3_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT4_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT5_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT6_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT7_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT8_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT9_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT10_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT11_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT12_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT13_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT14_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT15_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT16_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT17_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT18_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT19_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT20_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT21_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT22_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT23_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT24_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT25_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT26_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT27_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT28_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT29_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT30_GlitchData : VitalGlitchDataType;
     variable  RXCRCOUT31_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT0_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT1_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT2_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT3_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT4_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT5_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT6_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT7_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT8_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT9_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT10_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT11_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT12_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT13_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT14_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT15_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT16_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT17_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT18_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT19_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT20_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT21_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT22_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT23_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT24_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT25_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT26_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT27_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT28_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT29_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT30_GlitchData : VitalGlitchDataType;
     variable  TXCRCOUT31_GlitchData : VitalGlitchDataType;
     variable  RXSIGDET_GlitchData : VitalGlitchDataType;
     variable  DRDY_GlitchData : VitalGlitchDataType;
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
     variable  RXMCLK_GlitchData : VitalGlitchDataType;
     variable  TX1P_GlitchData : VitalGlitchDataType;
     variable  TX1N_GlitchData : VitalGlitchDataType;
     variable  TXPCSHCLKOUT_GlitchData : VitalGlitchDataType;
     variable  RXPCSHCLKOUT_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT0_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT1_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT2_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT3_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT4_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT5_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT6_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT7_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT8_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT9_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT10_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT11_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT12_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT13_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT14_GlitchData : VitalGlitchDataType;
     variable  COMBUSOUT15_GlitchData : VitalGlitchDataType;
begin

--  Output-to-Clock path delay
     VitalPathDelay01
       (
         OutSignal     => CHBONDO(0),
         GlitchData    => CHBONDO0_GlitchData,
         OutSignalName => "CHBONDO(0)",
         OutTemp       => CHBONDO_OUT(0),
         Paths         => (0 => (RXUSRCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => CHBONDO(1),
         GlitchData    => CHBONDO1_GlitchData,
         OutSignalName => "CHBONDO(1)",
         OutTemp       => CHBONDO_OUT(1),
         Paths         => (0 => (RXUSRCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => CHBONDO(2),
         GlitchData    => CHBONDO2_GlitchData,
         OutSignalName => "CHBONDO(2)",
         OutTemp       => CHBONDO_OUT(2),
         Paths         => (0 => (RXUSRCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => CHBONDO(3),
         GlitchData    => CHBONDO3_GlitchData,
         OutSignalName => "CHBONDO(3)",
         OutTemp       => CHBONDO_OUT(3),
         Paths         => (0 => (RXUSRCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => CHBONDO(4),
         GlitchData    => CHBONDO4_GlitchData,
         OutSignalName => "CHBONDO(4)",
         OutTemp       => CHBONDO_OUT(4),
         Paths         => (0 => (RXUSRCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXSTATUS(0),
         GlitchData    => RXSTATUS0_GlitchData,
         OutSignalName => "RXSTATUS(0)",
         OutTemp       => RXSTATUS_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXSTATUS(1),
         GlitchData    => RXSTATUS1_GlitchData,
         OutSignalName => "RXSTATUS(1)",
         OutTemp       => RXSTATUS_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXSTATUS(2),
         GlitchData    => RXSTATUS2_GlitchData,
         OutSignalName => "RXSTATUS(2)",
         OutTemp       => RXSTATUS_OUT(2),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXSTATUS(3),
         GlitchData    => RXSTATUS3_GlitchData,
         OutSignalName => "RXSTATUS(3)",
         OutTemp       => RXSTATUS_OUT(3),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXSTATUS(4),
         GlitchData    => RXSTATUS4_GlitchData,
         OutSignalName => "RXSTATUS(4)",
         OutTemp       => RXSTATUS_OUT(4),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXSTATUS(5),
         GlitchData    => RXSTATUS5_GlitchData,
         OutSignalName => "RXSTATUS(5)",
         OutTemp       => RXSTATUS_OUT(5),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(0),
         GlitchData    => RXCHARISCOMMA0_GlitchData,
         OutSignalName => "RXCHARISCOMMA(0)",
         OutTemp       => RXCHARISCOMMA_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(1),
         GlitchData    => RXCHARISCOMMA1_GlitchData,
         OutSignalName => "RXCHARISCOMMA(1)",
         OutTemp       => RXCHARISCOMMA_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(2),
         GlitchData    => RXCHARISCOMMA2_GlitchData,
         OutSignalName => "RXCHARISCOMMA(2)",
         OutTemp       => RXCHARISCOMMA_OUT(2),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(3),
         GlitchData    => RXCHARISCOMMA3_GlitchData,
         OutSignalName => "RXCHARISCOMMA(3)",
         OutTemp       => RXCHARISCOMMA_OUT(3),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(4),
         GlitchData    => RXCHARISCOMMA4_GlitchData,
         OutSignalName => "RXCHARISCOMMA(4)",
         OutTemp       => RXCHARISCOMMA_OUT(4),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(5),
         GlitchData    => RXCHARISCOMMA5_GlitchData,
         OutSignalName => "RXCHARISCOMMA(5)",
         OutTemp       => RXCHARISCOMMA_OUT(5),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(6),
         GlitchData    => RXCHARISCOMMA6_GlitchData,
         OutSignalName => "RXCHARISCOMMA(6)",
         OutTemp       => RXCHARISCOMMA_OUT(6),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISCOMMA(7),
         GlitchData    => RXCHARISCOMMA7_GlitchData,
         OutSignalName => "RXCHARISCOMMA(7)",
         OutTemp       => RXCHARISCOMMA_OUT(7),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(0),
         GlitchData    => RXCHARISK0_GlitchData,
         OutSignalName => "RXCHARISK(0)",
         OutTemp       => RXCHARISK_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(1),
         GlitchData    => RXCHARISK1_GlitchData,
         OutSignalName => "RXCHARISK(1)",
         OutTemp       => RXCHARISK_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(2),
         GlitchData    => RXCHARISK2_GlitchData,
         OutSignalName => "RXCHARISK(2)",
         OutTemp       => RXCHARISK_OUT(2),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(3),
         GlitchData    => RXCHARISK3_GlitchData,
         OutSignalName => "RXCHARISK(3)",
         OutTemp       => RXCHARISK_OUT(3),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(4),
         GlitchData    => RXCHARISK4_GlitchData,
         OutSignalName => "RXCHARISK(4)",
         OutTemp       => RXCHARISK_OUT(4),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(5),
         GlitchData    => RXCHARISK5_GlitchData,
         OutSignalName => "RXCHARISK(5)",
         OutTemp       => RXCHARISK_OUT(5),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(6),
         GlitchData    => RXCHARISK6_GlitchData,
         OutSignalName => "RXCHARISK(6)",
         OutTemp       => RXCHARISK_OUT(6),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCHARISK(7),
         GlitchData    => RXCHARISK7_GlitchData,
         OutSignalName => "RXCHARISK(7)",
         OutTemp       => RXCHARISK_OUT(7),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCOMMADET,
         GlitchData    => RXCOMMADET_GlitchData,
         OutSignalName => "RXCOMMADET",
         OutTemp       => RXCOMMADET_OUT,
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );     
     VitalPathDelay01
       (
         OutSignal     => RXDATA(0),
         GlitchData    => RXDATA0_GlitchData,
         OutSignalName => "RXDATA(0)",
         OutTemp       => RXDATA_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(1),
         GlitchData    => RXDATA1_GlitchData,
         OutSignalName => "RXDATA(1)",
         OutTemp       => RXDATA_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(2),
         GlitchData    => RXDATA2_GlitchData,
         OutSignalName => "RXDATA(2)",
         OutTemp       => RXDATA_OUT(2),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(3),
         GlitchData    => RXDATA3_GlitchData,
         OutSignalName => "RXDATA(3)",
         OutTemp       => RXDATA_OUT(3),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(4),
         GlitchData    => RXDATA4_GlitchData,
         OutSignalName => "RXDATA(4)",
         OutTemp       => RXDATA_OUT(4),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(5),
         GlitchData    => RXDATA5_GlitchData,
         OutSignalName => "RXDATA(5)",
         OutTemp       => RXDATA_OUT(5),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(6),
         GlitchData    => RXDATA6_GlitchData,
         OutSignalName => "RXDATA(6)",
         OutTemp       => RXDATA_OUT(6),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(7),
         GlitchData    => RXDATA7_GlitchData,
         OutSignalName => "RXDATA(7)",
         OutTemp       => RXDATA_OUT(7),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(8),
         GlitchData    => RXDATA8_GlitchData,
         OutSignalName => "RXDATA(8)",
         OutTemp       => RXDATA_OUT(8),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(9),
         GlitchData    => RXDATA9_GlitchData,
         OutSignalName => "RXDATA(9)",
         OutTemp       => RXDATA_OUT(9),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(10),
         GlitchData    => RXDATA10_GlitchData,
         OutSignalName => "RXDATA(10)",
         OutTemp       => RXDATA_OUT(10),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(11),
         GlitchData    => RXDATA11_GlitchData,
         OutSignalName => "RXDATA(11)",
         OutTemp       => RXDATA_OUT(11),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(12),
         GlitchData    => RXDATA12_GlitchData,
         OutSignalName => "RXDATA(12)",
         OutTemp       => RXDATA_OUT(12),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(13),
         GlitchData    => RXDATA13_GlitchData,
         OutSignalName => "RXDATA(13)",
         OutTemp       => RXDATA_OUT(13),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(14),
         GlitchData    => RXDATA14_GlitchData,
         OutSignalName => "RXDATA(14)",
         OutTemp       => RXDATA_OUT(14),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(15),
         GlitchData    => RXDATA15_GlitchData,
         OutSignalName => "RXDATA(15)",
         OutTemp       => RXDATA_OUT(15),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(16),
         GlitchData    => RXDATA16_GlitchData,
         OutSignalName => "RXDATA(16)",
         OutTemp       => RXDATA_OUT(16),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(17),
         GlitchData    => RXDATA17_GlitchData,
         OutSignalName => "RXDATA(17)",
         OutTemp       => RXDATA_OUT(17),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(18),
         GlitchData    => RXDATA18_GlitchData,
         OutSignalName => "RXDATA(18)",
         OutTemp       => RXDATA_OUT(18),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(19),
         GlitchData    => RXDATA19_GlitchData,
         OutSignalName => "RXDATA(19)",
         OutTemp       => RXDATA_OUT(19),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(20),
         GlitchData    => RXDATA20_GlitchData,
         OutSignalName => "RXDATA(20)",
         OutTemp       => RXDATA_OUT(20),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(21),
         GlitchData    => RXDATA21_GlitchData,
         OutSignalName => "RXDATA(21)",
         OutTemp       => RXDATA_OUT(21),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(22),
         GlitchData    => RXDATA22_GlitchData,
         OutSignalName => "RXDATA(22)",
         OutTemp       => RXDATA_OUT(22),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(23),
         GlitchData    => RXDATA23_GlitchData,
         OutSignalName => "RXDATA(23)",
         OutTemp       => RXDATA_OUT(23),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(24),
         GlitchData    => RXDATA24_GlitchData,
         OutSignalName => "RXDATA(24)",
         OutTemp       => RXDATA_OUT(24),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(25),
         GlitchData    => RXDATA25_GlitchData,
         OutSignalName => "RXDATA(25)",
         OutTemp       => RXDATA_OUT(25),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(26),
         GlitchData    => RXDATA26_GlitchData,
         OutSignalName => "RXDATA(26)",
         OutTemp       => RXDATA_OUT(26),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(27),
         GlitchData    => RXDATA27_GlitchData,
         OutSignalName => "RXDATA(27)",
         OutTemp       => RXDATA_OUT(27),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(28),
         GlitchData    => RXDATA28_GlitchData,
         OutSignalName => "RXDATA(28)",
         OutTemp       => RXDATA_OUT(28),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(29),
         GlitchData    => RXDATA29_GlitchData,
         OutSignalName => "RXDATA(29)",
         OutTemp       => RXDATA_OUT(29),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(30),
         GlitchData    => RXDATA30_GlitchData,
         OutSignalName => "RXDATA(30)",
         OutTemp       => RXDATA_OUT(30),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(31),
         GlitchData    => RXDATA31_GlitchData,
         OutSignalName => "RXDATA(31)",
         OutTemp       => RXDATA_OUT(31),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(32),
         GlitchData    => RXDATA32_GlitchData,
         OutSignalName => "RXDATA(32)",
         OutTemp       => RXDATA_OUT(32),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(33),
         GlitchData    => RXDATA33_GlitchData,
         OutSignalName => "RXDATA(33)",
         OutTemp       => RXDATA_OUT(33),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(34),
         GlitchData    => RXDATA34_GlitchData,
         OutSignalName => "RXDATA(34)",
         OutTemp       => RXDATA_OUT(34),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(35),
         GlitchData    => RXDATA35_GlitchData,
         OutSignalName => "RXDATA(35)",
         OutTemp       => RXDATA_OUT(35),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(36),
         GlitchData    => RXDATA36_GlitchData,
         OutSignalName => "RXDATA(36)",
         OutTemp       => RXDATA_OUT(36),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(37),
         GlitchData    => RXDATA37_GlitchData,
         OutSignalName => "RXDATA(37)",
         OutTemp       => RXDATA_OUT(37),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(38),
         GlitchData    => RXDATA38_GlitchData,
         OutSignalName => "RXDATA(38)",
         OutTemp       => RXDATA_OUT(38),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(39),
         GlitchData    => RXDATA39_GlitchData,
         OutSignalName => "RXDATA(39)",
         OutTemp       => RXDATA_OUT(39),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(40),
         GlitchData    => RXDATA40_GlitchData,
         OutSignalName => "RXDATA(40)",
         OutTemp       => RXDATA_OUT(40),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(41),
         GlitchData    => RXDATA41_GlitchData,
         OutSignalName => "RXDATA(41)",
         OutTemp       => RXDATA_OUT(41),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(42),
         GlitchData    => RXDATA42_GlitchData,
         OutSignalName => "RXDATA(42)",
         OutTemp       => RXDATA_OUT(42),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(43),
         GlitchData    => RXDATA43_GlitchData,
         OutSignalName => "RXDATA(43)",
         OutTemp       => RXDATA_OUT(43),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(44),
         GlitchData    => RXDATA44_GlitchData,
         OutSignalName => "RXDATA(44)",
         OutTemp       => RXDATA_OUT(44),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(45),
         GlitchData    => RXDATA45_GlitchData,
         OutSignalName => "RXDATA(45)",
         OutTemp       => RXDATA_OUT(45),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(46),
         GlitchData    => RXDATA46_GlitchData,
         OutSignalName => "RXDATA(46)",
         OutTemp       => RXDATA_OUT(46),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(47),
         GlitchData    => RXDATA47_GlitchData,
         OutSignalName => "RXDATA(47)",
         OutTemp       => RXDATA_OUT(47),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(48),
         GlitchData    => RXDATA48_GlitchData,
         OutSignalName => "RXDATA(48)",
         OutTemp       => RXDATA_OUT(48),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(49),
         GlitchData    => RXDATA49_GlitchData,
         OutSignalName => "RXDATA(49)",
         OutTemp       => RXDATA_OUT(49),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(50),
         GlitchData    => RXDATA50_GlitchData,
         OutSignalName => "RXDATA(50)",
         OutTemp       => RXDATA_OUT(50),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(51),
         GlitchData    => RXDATA51_GlitchData,
         OutSignalName => "RXDATA(51)",
         OutTemp       => RXDATA_OUT(51),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(52),
         GlitchData    => RXDATA52_GlitchData,
         OutSignalName => "RXDATA(52)",
         OutTemp       => RXDATA_OUT(52),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(53),
         GlitchData    => RXDATA53_GlitchData,
         OutSignalName => "RXDATA(53)",
         OutTemp       => RXDATA_OUT(53),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(54),
         GlitchData    => RXDATA54_GlitchData,
         OutSignalName => "RXDATA(54)",
         OutTemp       => RXDATA_OUT(54),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(55),
         GlitchData    => RXDATA55_GlitchData,
         OutSignalName => "RXDATA(55)",
         OutTemp       => RXDATA_OUT(55),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(56),
         GlitchData    => RXDATA56_GlitchData,
         OutSignalName => "RXDATA(56)",
         OutTemp       => RXDATA_OUT(56),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(57),
         GlitchData    => RXDATA57_GlitchData,
         OutSignalName => "RXDATA(57)",
         OutTemp       => RXDATA_OUT(57),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(58),
         GlitchData    => RXDATA58_GlitchData,
         OutSignalName => "RXDATA(58)",
         OutTemp       => RXDATA_OUT(58),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(59),
         GlitchData    => RXDATA59_GlitchData,
         OutSignalName => "RXDATA(59)",
         OutTemp       => RXDATA_OUT(59),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(60),
         GlitchData    => RXDATA60_GlitchData,
         OutSignalName => "RXDATA(60)",
         OutTemp       => RXDATA_OUT(60),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(61),
         GlitchData    => RXDATA61_GlitchData,
         OutSignalName => "RXDATA(61)",
         OutTemp       => RXDATA_OUT(61),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(62),
         GlitchData    => RXDATA62_GlitchData,
         OutSignalName => "RXDATA(62)",
         OutTemp       => RXDATA_OUT(62),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDATA(63),
         GlitchData    => RXDATA63_GlitchData,
         OutSignalName => "RXDATA(63)",
         OutTemp       => RXDATA_OUT(63),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(0),
         GlitchData    => RXDISPERR0_GlitchData,
         OutSignalName => "RXDISPERR(0)",
         OutTemp       => RXDISPERR_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(1),
         GlitchData    => RXDISPERR1_GlitchData,
         OutSignalName => "RXDISPERR(1)",
         OutTemp       => RXDISPERR_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(2),
         GlitchData    => RXDISPERR2_GlitchData,
         OutSignalName => "RXDISPERR(2)",
         OutTemp       => RXDISPERR_OUT(2),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(3),
         GlitchData    => RXDISPERR3_GlitchData,
         OutSignalName => "RXDISPERR(3)",
         OutTemp       => RXDISPERR_OUT(3),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(4),
         GlitchData    => RXDISPERR4_GlitchData,
         OutSignalName => "RXDISPERR(4)",
         OutTemp       => RXDISPERR_OUT(4),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(5),
         GlitchData    => RXDISPERR5_GlitchData,
         OutSignalName => "RXDISPERR(5)",
         OutTemp       => RXDISPERR_OUT(5),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(6),
         GlitchData    => RXDISPERR6_GlitchData,
         OutSignalName => "RXDISPERR(6)",
         OutTemp       => RXDISPERR_OUT(6),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXDISPERR(7),
         GlitchData    => RXDISPERR7_GlitchData,
         OutSignalName => "RXDISPERR(7)",
         OutTemp       => RXDISPERR_OUT(7),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXLOSSOFSYNC(0),
         GlitchData    => RXLOSSOFSYNC0_GlitchData,
         OutSignalName => "RXLOSSOFSYNC(0)",
         OutTemp       => RXLOSSOFSYNC_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXLOSSOFSYNC(1),
         GlitchData    => RXLOSSOFSYNC1_GlitchData,
         OutSignalName => "RXLOSSOFSYNC(1)",
         OutTemp       => RXLOSSOFSYNC_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(0),
         GlitchData    => RXNOTINTABLE0_GlitchData,
         OutSignalName => "RXNOTINTABLE(0)",
         OutTemp       => RXNOTINTABLE_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(1),
         GlitchData    => RXNOTINTABLE1_GlitchData,
         OutSignalName => "RXNOTINTABLE(1)",
         OutTemp       => RXNOTINTABLE_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(2),
         GlitchData    => RXNOTINTABLE2_GlitchData,
         OutSignalName => "RXNOTINTABLE(2)",
         OutTemp       => RXNOTINTABLE_OUT(2),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(3),
         GlitchData    => RXNOTINTABLE3_GlitchData,
         OutSignalName => "RXNOTINTABLE(3)",
         OutTemp       => RXNOTINTABLE_OUT(3),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(4),
         GlitchData    => RXNOTINTABLE4_GlitchData,
         OutSignalName => "RXNOTINTABLE(4)",
         OutTemp       => RXNOTINTABLE_OUT(4),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(5),
         GlitchData    => RXNOTINTABLE5_GlitchData,
         OutSignalName => "RXNOTINTABLE(5)",
         OutTemp       => RXNOTINTABLE_OUT(5),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(6),
         GlitchData    => RXNOTINTABLE6_GlitchData,
         OutSignalName => "RXNOTINTABLE(6)",
         OutTemp       => RXNOTINTABLE_OUT(6),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXNOTINTABLE(7),
         GlitchData    => RXNOTINTABLE7_GlitchData,
         OutSignalName => "RXNOTINTABLE(7)",
         OutTemp       => RXNOTINTABLE_OUT(7),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXREALIGN,
         GlitchData    => RXREALIGN_GlitchData,
         OutSignalName => "RXREALIGN",
         OutTemp       => RXREALIGN_OUT,
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );     
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(0),
         GlitchData    => RXRUNDISP0_GlitchData,
         OutSignalName => "RXRUNDISP(0)",
         OutTemp       => RXRUNDISP_OUT(0),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(1),
         GlitchData    => RXRUNDISP1_GlitchData,
         OutSignalName => "RXRUNDISP(1)",
         OutTemp       => RXRUNDISP_OUT(1),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(2),
         GlitchData    => RXRUNDISP2_GlitchData,
         OutSignalName => "RXRUNDISP(2)",
         OutTemp       => RXRUNDISP_OUT(2),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(3),
         GlitchData    => RXRUNDISP3_GlitchData,
         OutSignalName => "RXRUNDISP(3)",
         OutTemp       => RXRUNDISP_OUT(3),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(4),
         GlitchData    => RXRUNDISP4_GlitchData,
         OutSignalName => "RXRUNDISP(4)",
         OutTemp       => RXRUNDISP_OUT(4),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(5),
         GlitchData    => RXRUNDISP5_GlitchData,
         OutSignalName => "RXRUNDISP(5)",
         OutTemp       => RXRUNDISP_OUT(5),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(6),
         GlitchData    => RXRUNDISP6_GlitchData,
         OutSignalName => "RXRUNDISP(6)",
         OutTemp       => RXRUNDISP_OUT(6),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXRUNDISP(7),
         GlitchData    => RXRUNDISP7_GlitchData,
         OutSignalName => "RXRUNDISP(7)",
         OutTemp       => RXRUNDISP_OUT(7),
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXBUFERR,
         GlitchData    => RXBUFERR_GlitchData,
         OutSignalName => "RXBUFERR",
         OutTemp       => RXBUFERR_OUT,
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXBUFERR,
         GlitchData    => TXBUFERR_GlitchData,
         OutSignalName => "TXBUFERR",
         OutTemp       => TXBUFERR_OUT,
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );     
     VitalPathDelay01
       (
         OutSignal     => TXKERR(0),
         GlitchData    => TXKERR0_GlitchData,
         OutSignalName => "TXKERR(0)",
         OutTemp       => TXKERR_OUT(0),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXKERR(1),
         GlitchData    => TXKERR1_GlitchData,
         OutSignalName => "TXKERR(1)",
         OutTemp       => TXKERR_OUT(1),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXKERR(2),
         GlitchData    => TXKERR2_GlitchData,
         OutSignalName => "TXKERR(2)",
         OutTemp       => TXKERR_OUT(2),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXKERR(3),
         GlitchData    => TXKERR3_GlitchData,
         OutSignalName => "TXKERR(3)",
         OutTemp       => TXKERR_OUT(3),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXKERR(4),
         GlitchData    => TXKERR4_GlitchData,
         OutSignalName => "TXKERR(4)",
         OutTemp       => TXKERR_OUT(4),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXKERR(5),
         GlitchData    => TXKERR5_GlitchData,
         OutSignalName => "TXKERR(5)",
         OutTemp       => TXKERR_OUT(5),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXKERR(6),
         GlitchData    => TXKERR6_GlitchData,
         OutSignalName => "TXKERR(6)",
         OutTemp       => TXKERR_OUT(6),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXKERR(7),
         GlitchData    => TXKERR7_GlitchData,
         OutSignalName => "TXKERR(7)",
         OutTemp       => TXKERR_OUT(7),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(0),
         GlitchData    => TXRUNDISP0_GlitchData,
         OutSignalName => "TXRUNDISP(0)",
         OutTemp       => TXRUNDISP_OUT(0),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(1),
         GlitchData    => TXRUNDISP1_GlitchData,
         OutSignalName => "TXRUNDISP(1)",
         OutTemp       => TXRUNDISP_OUT(1),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(2),
         GlitchData    => TXRUNDISP2_GlitchData,
         OutSignalName => "TXRUNDISP(2)",
         OutTemp       => TXRUNDISP_OUT(2),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(3),
         GlitchData    => TXRUNDISP3_GlitchData,
         OutSignalName => "TXRUNDISP(3)",
         OutTemp       => TXRUNDISP_OUT(3),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(4),
         GlitchData    => TXRUNDISP4_GlitchData,
         OutSignalName => "TXRUNDISP(4)",
         OutTemp       => TXRUNDISP_OUT(4),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(5),
         GlitchData    => TXRUNDISP5_GlitchData,
         OutSignalName => "TXRUNDISP(5)",
         OutTemp       => TXRUNDISP_OUT(5),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(6),
         GlitchData    => TXRUNDISP6_GlitchData,
         OutSignalName => "TXRUNDISP(6)",
         OutTemp       => TXRUNDISP_OUT(6),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXRUNDISP(7),
         GlitchData    => TXRUNDISP7_GlitchData,
         OutSignalName => "TXRUNDISP(7)",
         OutTemp       => TXRUNDISP_OUT(7),
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXLOCK,
         GlitchData    => RXLOCK_GlitchData,
         OutSignalName => "RXLOCK",
         OutTemp       => RXLOCK_OUT,
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXLOCK,
         GlitchData    => TXLOCK_GlitchData,
         OutSignalName => "TXLOCK",
         OutTemp       => TXLOCK_OUT,
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCYCLELIMIT,
         GlitchData    => RXCYCLELIMIT_GlitchData,
         OutSignalName => "RXCYCLELIMIT",
         OutTemp       => RXCYCLELIMIT_OUT,
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCYCLELIMIT,
         GlitchData    => TXCYCLELIMIT_GlitchData,
         OutSignalName => "TXCYCLELIMIT",
         OutTemp       => TXCYCLELIMIT_OUT,
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCALFAIL,
         GlitchData    => RXCALFAIL_GlitchData,
         OutSignalName => "RXCALFAIL",
         OutTemp       => RXCALFAIL_OUT,
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCALFAIL,
         GlitchData    => TXCALFAIL_GlitchData,
         OutSignalName => "TXCALFAIL",
         OutTemp       => TXCALFAIL_OUT,
         Paths         => (0 => (TXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );     
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(0),
         GlitchData    => RXCRCOUT0_GlitchData,
         OutSignalName => "RXCRCOUT(0)",
         OutTemp       => RXCRCOUT_OUT(0),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(1),
         GlitchData    => RXCRCOUT1_GlitchData,
         OutSignalName => "RXCRCOUT(1)",
         OutTemp       => RXCRCOUT_OUT(1),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(2),
         GlitchData    => RXCRCOUT2_GlitchData,
         OutSignalName => "RXCRCOUT(2)",
         OutTemp       => RXCRCOUT_OUT(2),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(3),
         GlitchData    => RXCRCOUT3_GlitchData,
         OutSignalName => "RXCRCOUT(3)",
         OutTemp       => RXCRCOUT_OUT(3),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(4),
         GlitchData    => RXCRCOUT4_GlitchData,
         OutSignalName => "RXCRCOUT(4)",
         OutTemp       => RXCRCOUT_OUT(4),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(5),
         GlitchData    => RXCRCOUT5_GlitchData,
         OutSignalName => "RXCRCOUT(5)",
         OutTemp       => RXCRCOUT_OUT(5),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(6),
         GlitchData    => RXCRCOUT6_GlitchData,
         OutSignalName => "RXCRCOUT(6)",
         OutTemp       => RXCRCOUT_OUT(6),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(7),
         GlitchData    => RXCRCOUT7_GlitchData,
         OutSignalName => "RXCRCOUT(7)",
         OutTemp       => RXCRCOUT_OUT(7),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(8),
         GlitchData    => RXCRCOUT8_GlitchData,
         OutSignalName => "RXCRCOUT(8)",
         OutTemp       => RXCRCOUT_OUT(8),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(9),
         GlitchData    => RXCRCOUT9_GlitchData,
         OutSignalName => "RXCRCOUT(9)",
         OutTemp       => RXCRCOUT_OUT(9),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(10),
         GlitchData    => RXCRCOUT10_GlitchData,
         OutSignalName => "RXCRCOUT(10)",
         OutTemp       => RXCRCOUT_OUT(10),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(11),
         GlitchData    => RXCRCOUT11_GlitchData,
         OutSignalName => "RXCRCOUT(11)",
         OutTemp       => RXCRCOUT_OUT(11),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(12),
         GlitchData    => RXCRCOUT12_GlitchData,
         OutSignalName => "RXCRCOUT(12)",
         OutTemp       => RXCRCOUT_OUT(12),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(13),
         GlitchData    => RXCRCOUT13_GlitchData,
         OutSignalName => "RXCRCOUT(13)",
         OutTemp       => RXCRCOUT_OUT(13),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(14),
         GlitchData    => RXCRCOUT14_GlitchData,
         OutSignalName => "RXCRCOUT(14)",
         OutTemp       => RXCRCOUT_OUT(14),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(15),
         GlitchData    => RXCRCOUT15_GlitchData,
         OutSignalName => "RXCRCOUT(15)",
         OutTemp       => RXCRCOUT_OUT(15),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(16),
         GlitchData    => RXCRCOUT16_GlitchData,
         OutSignalName => "RXCRCOUT(16)",
         OutTemp       => RXCRCOUT_OUT(16),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(17),
         GlitchData    => RXCRCOUT17_GlitchData,
         OutSignalName => "RXCRCOUT(17)",
         OutTemp       => RXCRCOUT_OUT(17),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(18),
         GlitchData    => RXCRCOUT18_GlitchData,
         OutSignalName => "RXCRCOUT(18)",
         OutTemp       => RXCRCOUT_OUT(18),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(19),
         GlitchData    => RXCRCOUT19_GlitchData,
         OutSignalName => "RXCRCOUT(19)",
         OutTemp       => RXCRCOUT_OUT(19),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(20),
         GlitchData    => RXCRCOUT20_GlitchData,
         OutSignalName => "RXCRCOUT(20)",
         OutTemp       => RXCRCOUT_OUT(20),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(21),
         GlitchData    => RXCRCOUT21_GlitchData,
         OutSignalName => "RXCRCOUT(21)",
         OutTemp       => RXCRCOUT_OUT(21),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(22),
         GlitchData    => RXCRCOUT22_GlitchData,
         OutSignalName => "RXCRCOUT(22)",
         OutTemp       => RXCRCOUT_OUT(22),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(23),
         GlitchData    => RXCRCOUT23_GlitchData,
         OutSignalName => "RXCRCOUT(23)",
         OutTemp       => RXCRCOUT_OUT(23),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(24),
         GlitchData    => RXCRCOUT24_GlitchData,
         OutSignalName => "RXCRCOUT(24)",
         OutTemp       => RXCRCOUT_OUT(24),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(25),
         GlitchData    => RXCRCOUT25_GlitchData,
         OutSignalName => "RXCRCOUT(25)",
         OutTemp       => RXCRCOUT_OUT(25),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(26),
         GlitchData    => RXCRCOUT26_GlitchData,
         OutSignalName => "RXCRCOUT(26)",
         OutTemp       => RXCRCOUT_OUT(26),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(27),
         GlitchData    => RXCRCOUT27_GlitchData,
         OutSignalName => "RXCRCOUT(27)",
         OutTemp       => RXCRCOUT_OUT(27),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(28),
         GlitchData    => RXCRCOUT28_GlitchData,
         OutSignalName => "RXCRCOUT(28)",
         OutTemp       => RXCRCOUT_OUT(28),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(29),
         GlitchData    => RXCRCOUT29_GlitchData,
         OutSignalName => "RXCRCOUT(29)",
         OutTemp       => RXCRCOUT_OUT(29),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(30),
         GlitchData    => RXCRCOUT30_GlitchData,
         OutSignalName => "RXCRCOUT(30)",
         OutTemp       => RXCRCOUT_OUT(30),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXCRCOUT(31),
         GlitchData    => RXCRCOUT31_GlitchData,
         OutSignalName => "RXCRCOUT(31)",
         OutTemp       => RXCRCOUT_OUT(31),
         Paths         => (0 => (RXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(0),
         GlitchData    => TXCRCOUT0_GlitchData,
         OutSignalName => "TXCRCOUT(0)",
         OutTemp       => TXCRCOUT_OUT(0),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(1),
         GlitchData    => TXCRCOUT1_GlitchData,
         OutSignalName => "TXCRCOUT(1)",
         OutTemp       => TXCRCOUT_OUT(1),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(2),
         GlitchData    => TXCRCOUT2_GlitchData,
         OutSignalName => "TXCRCOUT(2)",
         OutTemp       => TXCRCOUT_OUT(2),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(3),
         GlitchData    => TXCRCOUT3_GlitchData,
         OutSignalName => "TXCRCOUT(3)",
         OutTemp       => TXCRCOUT_OUT(3),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(4),
         GlitchData    => TXCRCOUT4_GlitchData,
         OutSignalName => "TXCRCOUT(4)",
         OutTemp       => TXCRCOUT_OUT(4),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(5),
         GlitchData    => TXCRCOUT5_GlitchData,
         OutSignalName => "TXCRCOUT(5)",
         OutTemp       => TXCRCOUT_OUT(5),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(6),
         GlitchData    => TXCRCOUT6_GlitchData,
         OutSignalName => "TXCRCOUT(6)",
         OutTemp       => TXCRCOUT_OUT(6),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(7),
         GlitchData    => TXCRCOUT7_GlitchData,
         OutSignalName => "TXCRCOUT(7)",
         OutTemp       => TXCRCOUT_OUT(7),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(8),
         GlitchData    => TXCRCOUT8_GlitchData,
         OutSignalName => "TXCRCOUT(8)",
         OutTemp       => TXCRCOUT_OUT(8),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(9),
         GlitchData    => TXCRCOUT9_GlitchData,
         OutSignalName => "TXCRCOUT(9)",
         OutTemp       => TXCRCOUT_OUT(9),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(10),
         GlitchData    => TXCRCOUT10_GlitchData,
         OutSignalName => "TXCRCOUT(10)",
         OutTemp       => TXCRCOUT_OUT(10),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(11),
         GlitchData    => TXCRCOUT11_GlitchData,
         OutSignalName => "TXCRCOUT(11)",
         OutTemp       => TXCRCOUT_OUT(11),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(12),
         GlitchData    => TXCRCOUT12_GlitchData,
         OutSignalName => "TXCRCOUT(12)",
         OutTemp       => TXCRCOUT_OUT(12),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(13),
         GlitchData    => TXCRCOUT13_GlitchData,
         OutSignalName => "TXCRCOUT(13)",
         OutTemp       => TXCRCOUT_OUT(13),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(14),
         GlitchData    => TXCRCOUT14_GlitchData,
         OutSignalName => "TXCRCOUT(14)",
         OutTemp       => TXCRCOUT_OUT(14),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(15),
         GlitchData    => TXCRCOUT15_GlitchData,
         OutSignalName => "TXCRCOUT(15)",
         OutTemp       => TXCRCOUT_OUT(15),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(16),
         GlitchData    => TXCRCOUT16_GlitchData,
         OutSignalName => "TXCRCOUT(16)",
         OutTemp       => TXCRCOUT_OUT(16),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(17),
         GlitchData    => TXCRCOUT17_GlitchData,
         OutSignalName => "TXCRCOUT(17)",
         OutTemp       => TXCRCOUT_OUT(17),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(18),
         GlitchData    => TXCRCOUT18_GlitchData,
         OutSignalName => "TXCRCOUT(18)",
         OutTemp       => TXCRCOUT_OUT(18),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(19),
         GlitchData    => TXCRCOUT19_GlitchData,
         OutSignalName => "TXCRCOUT(19)",
         OutTemp       => TXCRCOUT_OUT(19),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(20),
         GlitchData    => TXCRCOUT20_GlitchData,
         OutSignalName => "TXCRCOUT(20)",
         OutTemp       => TXCRCOUT_OUT(20),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(21),
         GlitchData    => TXCRCOUT21_GlitchData,
         OutSignalName => "TXCRCOUT(21)",
         OutTemp       => TXCRCOUT_OUT(21),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(22),
         GlitchData    => TXCRCOUT22_GlitchData,
         OutSignalName => "TXCRCOUT(22)",
         OutTemp       => TXCRCOUT_OUT(22),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(23),
         GlitchData    => TXCRCOUT23_GlitchData,
         OutSignalName => "TXCRCOUT(23)",
         OutTemp       => TXCRCOUT_OUT(23),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(24),
         GlitchData    => TXCRCOUT24_GlitchData,
         OutSignalName => "TXCRCOUT(24)",
         OutTemp       => TXCRCOUT_OUT(24),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(25),
         GlitchData    => TXCRCOUT25_GlitchData,
         OutSignalName => "TXCRCOUT(25)",
         OutTemp       => TXCRCOUT_OUT(25),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(26),
         GlitchData    => TXCRCOUT26_GlitchData,
         OutSignalName => "TXCRCOUT(26)",
         OutTemp       => TXCRCOUT_OUT(26),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(27),
         GlitchData    => TXCRCOUT27_GlitchData,
         OutSignalName => "TXCRCOUT(27)",
         OutTemp       => TXCRCOUT_OUT(27),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(28),
         GlitchData    => TXCRCOUT28_GlitchData,
         OutSignalName => "TXCRCOUT(28)",
         OutTemp       => TXCRCOUT_OUT(28),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(29),
         GlitchData    => TXCRCOUT29_GlitchData,
         OutSignalName => "TXCRCOUT(29)",
         OutTemp       => TXCRCOUT_OUT(29),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(30),
         GlitchData    => TXCRCOUT30_GlitchData,
         OutSignalName => "TXCRCOUT(30)",
         OutTemp       => TXCRCOUT_OUT(30),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => TXCRCOUT(31),
         GlitchData    => TXCRCOUT31_GlitchData,
         OutSignalName => "TXCRCOUT(31)",
         OutTemp       => TXCRCOUT_OUT(31),
         Paths         => (0 => (TXCRCINTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => RXSIGDET,
         GlitchData    => RXSIGDET_GlitchData,
         OutSignalName => "RXSIGDET",
         OutTemp       => RXSIGDET_OUT,
         Paths         => (0 => (RXUSRCLK2_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (DCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );

--  Wait signal (input/output pins)
   wait on
     CHBONDO_OUT,
     RXSTATUS_OUT,
     RXCHARISCOMMA_OUT,
     RXCHARISK_OUT,
     RXCOMMADET_OUT,
     RXDATA_OUT,
     RXDISPERR_OUT,
     RXLOSSOFSYNC_OUT,
     RXNOTINTABLE_OUT,
     RXREALIGN_OUT,
     RXRUNDISP_OUT,
     RXBUFERR_OUT,
     TXBUFERR_OUT,
     TXKERR_OUT,
     TXRUNDISP_OUT,
     RXLOCK_OUT,
     TXLOCK_OUT,
     RXCYCLELIMIT_OUT,
     TXCYCLELIMIT_OUT,
     RXCALFAIL_OUT,
     TXCALFAIL_OUT,
     RXCRCOUT_OUT,
     TXCRCOUT_OUT,
     RXSIGDET_OUT,
     DRDY_OUT,
     DO_OUT,
     CHBONDI_ipd,
     ENCHANSYNC_ipd,
     ENMCOMMAALIGN_ipd,
     ENPCOMMAALIGN_ipd,
     LOOPBACK_ipd,
     POWERDOWN_ipd,
     RXBLOCKSYNC64B66BUSE_ipd,
     RXCOMMADETUSE_ipd,
     RXDATAWIDTH_ipd,
     RXDEC64B66BUSE_ipd,
     RXDEC8B10BUSE_ipd,
     RXDESCRAM64B66BUSE_ipd,
     RXIGNOREBTF_ipd,
     RXINTDATAWIDTH_ipd,
     RXPOLARITY_ipd,
     RXRESET_ipd,
     RXSLIDE_ipd,
     RXUSRCLK_ipd,
     RXUSRCLK2_ipd,
     TXBYPASS8B10B_ipd,
     TXCHARDISPMODE_ipd,
     TXCHARDISPVAL_ipd,
     TXCHARISK_ipd,
     TXDATA_ipd,
     TXDATAWIDTH_ipd,
     TXENC64B66BUSE_ipd,
     TXENC8B10BUSE_ipd,
     TXGEARBOX64B66BUSE_ipd,
     TXINHIBIT_ipd,
     TXINTDATAWIDTH_ipd,
     TXPOLARITY_ipd,
     TXRESET_ipd,
     TXSCRAM64B66BUSE_ipd,
     TXUSRCLK_ipd,
     TXUSRCLK2_ipd,
     RXCLKSTABLE_ipd,
     RXPMARESET_ipd,
     TXCLKSTABLE_ipd,
     TXPMARESET_ipd,
     RXCRCIN_ipd,
     RXCRCDATAWIDTH_ipd,
     RXCRCDATAVALID_ipd,
     RXCRCINIT_ipd,
     RXCRCRESET_ipd,
     RXCRCPD_ipd,
     RXCRCCLK_ipd,
     RXCRCINTCLK_ipd,
     TXCRCIN_ipd,
     TXCRCDATAWIDTH_ipd,
     TXCRCDATAVALID_ipd,
     TXCRCINIT_ipd,
     TXCRCRESET_ipd,
     TXCRCPD_ipd,
     TXCRCCLK_ipd,
     TXCRCINTCLK_ipd,
     TXSYNC_ipd,
     RXSYNC_ipd,
     TXENOOB_ipd,
     DCLK_ipd,
     DADDR_ipd,
     DEN_ipd,
     DWE_ipd,
     DI_ipd,
     RX1P_ipd,
     RX1N_ipd,
     GREFCLK_ipd,
     REFCLK1_ipd,
     REFCLK2_ipd,
     COMBUSIN_ipd;


   end process TIMING;
RXPCSHCLKOUT <= RXPCSHCLKOUT_OUT;
TXPCSHCLKOUT <= TXPCSHCLKOUT_OUT;
RXMCLK <= RXMCLK_OUT;
RXRECCLK1 <= RXRECCLK1_OUT;
RXRECCLK2 <= RXRECCLK2_OUT;
TXOUTCLK1 <= TXOUTCLK1_OUT;
TXOUTCLK2 <= TXOUTCLK2_OUT;
TX1N <= TX1N_OUT;
TX1P <= TX1P_OUT;
COMBUSOUT <= COMBUSOUT_OUT;            
end GT11_V;
