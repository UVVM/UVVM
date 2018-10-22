----- CELL GT11_CUSTOM -----
-------------------------------------------------------------------------------
-- Copyright (c) 1995-2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  11-Gigabit Transceiver for High-Speed I/O CUSTOM Simulation Model
-- /___/   /\     Filename : GT11_CUSTOM.vhd
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

entity GT11_CUSTOM is
generic (
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


  );

port (
		CHBONDO : out std_logic_vector(4 downto 0);
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
end GT11_CUSTOM;

-- Architecture body --

architecture GT11_CUSTOM_V of GT11_CUSTOM is

signal  z16 : std_logic_vector(15 downto 0) := "0000000000000000";
signal  OPEN16 : std_logic_vector(15 downto 0);

begin


-- GT11 Instatiation (port map, generic map)
GT11_inst : GT11
	generic map (
		GT11_MODE => "SINGLE",
		CHAN_BOND_SEQ_1_1 => CHAN_BOND_SEQ_1_1,
		CHAN_BOND_SEQ_1_2 => CHAN_BOND_SEQ_1_2,
		CHAN_BOND_SEQ_1_3 => CHAN_BOND_SEQ_1_3,
		CHAN_BOND_SEQ_1_4 => CHAN_BOND_SEQ_1_4,
		CHAN_BOND_SEQ_1_MASK => CHAN_BOND_SEQ_1_MASK,
		CHAN_BOND_LIMIT => CHAN_BOND_LIMIT,
		CHAN_BOND_MODE => CHAN_BOND_MODE,
		CHAN_BOND_ONE_SHOT => CHAN_BOND_ONE_SHOT,
		CHAN_BOND_SEQ_2_USE => CHAN_BOND_SEQ_2_USE,
		CHAN_BOND_SEQ_LEN => CHAN_BOND_SEQ_LEN,
		RX_BUFFER_USE => RX_BUFFER_USE,
		TX_BUFFER_USE => TX_BUFFER_USE,
		CHAN_BOND_SEQ_2_1 => CHAN_BOND_SEQ_2_1,
		CHAN_BOND_SEQ_2_2 => CHAN_BOND_SEQ_2_2,
		CHAN_BOND_SEQ_2_3 => CHAN_BOND_SEQ_2_3,
		CHAN_BOND_SEQ_2_4 => CHAN_BOND_SEQ_2_4,
		CHAN_BOND_SEQ_2_MASK => CHAN_BOND_SEQ_2_MASK,
		POWER_ENABLE => POWER_ENABLE,
		OPPOSITE_SELECT => OPPOSITE_SELECT,
		CCCB_ARBITRATOR_DISABLE => CCCB_ARBITRATOR_DISABLE,
		CLK_COR_SEQ_1_1 => CLK_COR_SEQ_1_1,
		CLK_COR_SEQ_1_2 => CLK_COR_SEQ_1_2,
		CLK_COR_SEQ_1_3 => CLK_COR_SEQ_1_3,
		CLK_COR_SEQ_1_4 => CLK_COR_SEQ_1_4,
		CLK_COR_SEQ_1_MASK => CLK_COR_SEQ_1_MASK,
		DIGRX_SYNC_MODE => DIGRX_SYNC_MODE,
		DIGRX_FWDCLK => DIGRX_FWDCLK,
		PCS_BIT_SLIP => PCS_BIT_SLIP,
		CLK_COR_MIN_LAT => CLK_COR_MIN_LAT,
		TXDATA_SEL => TXDATA_SEL,
		RXDATA_SEL => RXDATA_SEL,
		CLK_COR_SEQ_2_1 => CLK_COR_SEQ_2_1,
		CLK_COR_SEQ_2_2 => CLK_COR_SEQ_2_2,
		CLK_COR_SEQ_2_3 => CLK_COR_SEQ_2_3,
		CLK_COR_SEQ_2_4 => CLK_COR_SEQ_2_4,
		CLK_COR_SEQ_2_MASK => CLK_COR_SEQ_2_MASK,
		CLK_COR_MAX_LAT => CLK_COR_MAX_LAT,
		CLK_COR_SEQ_2_USE => CLK_COR_SEQ_2_USE,
		CLK_COR_SEQ_DROP => CLK_COR_SEQ_DROP,
		CLK_COR_SEQ_LEN => CLK_COR_SEQ_LEN,
		CLK_CORRECT_USE => CLK_CORRECT_USE,
		CLK_COR_8B10B_DE => CLK_COR_8B10B_DE,
		SH_CNT_MAX => SH_CNT_MAX,
		SH_INVALID_CNT_MAX => SH_INVALID_CNT_MAX,
		ALIGN_COMMA_WORD => ALIGN_COMMA_WORD,
		DEC_MCOMMA_DETECT => DEC_MCOMMA_DETECT,
		DEC_PCOMMA_DETECT => DEC_PCOMMA_DETECT,
		DEC_VALID_COMMA_ONLY => DEC_VALID_COMMA_ONLY,
		MCOMMA_DETECT => MCOMMA_DETECT,
		PCOMMA_DETECT => PCOMMA_DETECT,
		COMMA32 => COMMA32,
		COMMA_10B_MASK => COMMA_10B_MASK,
		MCOMMA_32B_VALUE => MCOMMA_32B_VALUE,
		PCOMMA_32B_VALUE => PCOMMA_32B_VALUE,
		RXUSRDIVISOR => RXUSRDIVISOR,
		DCDR_FILTER => DCDR_FILTER,
		SAMPLE_8X => SAMPLE_8X,
		ENABLE_DCDR => ENABLE_DCDR,
		REPEATER => REPEATER,
		RXBY_32 => RXBY_32,
		TXFDCAL_CLOCK_DIVIDE => TXFDCAL_CLOCK_DIVIDE,
		RXFDCAL_CLOCK_DIVIDE => RXFDCAL_CLOCK_DIVIDE,
		RXCYCLE_LIMIT_SEL => RXCYCLE_LIMIT_SEL,
		RXVCO_CTRL_ENABLE => RXVCO_CTRL_ENABLE,
		RXFDET_LCK_SEL => RXFDET_LCK_SEL,
		RXFDET_HYS_SEL => RXFDET_HYS_SEL,
		RXFDET_LCK_CAL => RXFDET_LCK_CAL,
		RXFDET_HYS_CAL => RXFDET_HYS_CAL,
		RXLOOPCAL_WAIT => RXLOOPCAL_WAIT,
		RXSLOWDOWN_CAL => RXSLOWDOWN_CAL,
		RXVCODAC_INIT => RXVCODAC_INIT,
		CYCLE_LIMIT_SEL => CYCLE_LIMIT_SEL,
		VCO_CTRL_ENABLE => VCO_CTRL_ENABLE,
		FDET_LCK_SEL => FDET_LCK_SEL,
		FDET_HYS_SEL => FDET_HYS_SEL,
		FDET_LCK_CAL => FDET_LCK_CAL,
		FDET_HYS_CAL => FDET_HYS_CAL,
		LOOPCAL_WAIT => LOOPCAL_WAIT,
		SLOWDOWN_CAL => SLOWDOWN_CAL,
		VCODAC_INIT => VCODAC_INIT,
		RXCRCCLOCKDOUBLE => RXCRCCLOCKDOUBLE,
		RXCRCINVERTGEN => RXCRCINVERTGEN,
		RXCRCSAMECLOCK => RXCRCSAMECLOCK,
		RXCRCENABLE => RXCRCENABLE,
		RXCRCINITVAL => RXCRCINITVAL,
		TXCRCCLOCKDOUBLE => TXCRCCLOCKDOUBLE,
		TXCRCINVERTGEN => TXCRCINVERTGEN,
		TXCRCSAMECLOCK => TXCRCSAMECLOCK,
		TXCRCINITVAL => TXCRCINITVAL,
		TXCRCENABLE => TXCRCENABLE,
		RX_CLOCK_DIVIDER => RX_CLOCK_DIVIDER,
		TX_CLOCK_DIVIDER => TX_CLOCK_DIVIDER,
		RXCLK0_FORCE_PMACLK => RXCLK0_FORCE_PMACLK,
		TXCLK0_FORCE_PMACLK => TXCLK0_FORCE_PMACLK,
		TXOUTCLK1_USE_SYNC => TXOUTCLK1_USE_SYNC,
		RXRECCLK1_USE_SYNC => RXRECCLK1_USE_SYNC,
		RXPMACLKSEL => RXPMACLKSEL,
		TXABPMACLKSEL => TXABPMACLKSEL,
		RXAREGCTRL => RXAREGCTRL,
		PMAVBGCTRL => PMAVBGCTRL,
		BANDGAPSEL => BANDGAPSEL,
		PMAIREFTRIM => PMAIREFTRIM,
		IREFBIASMODE => IREFBIASMODE,
		BIASRESSEL => BIASRESSEL,
		PMAVREFTRIM => PMAVREFTRIM,
		VREFBIASMODE => VREFBIASMODE,
		TXPHASESEL => TXPHASESEL,
		PMACLKENABLE => PMACLKENABLE,
		PMACOREPWRENABLE => PMACOREPWRENABLE,
		RXMODE => RXMODE,
		PMA_BIT_SLIP => PMA_BIT_SLIP,
		RXASYNCDIVIDE => RXASYNCDIVIDE,
		RXCLKMODE => RXCLKMODE,
		RXLB => RXLB,
		RXFETUNE => RXFETUNE,
		RXRCPADJ => RXRCPADJ,
		RXRIBADJ => RXRIBADJ,
		RXAFEEQ => RXAFEEQ,
		RXCMADJ => RXCMADJ,
		RXCDRLOS => RXCDRLOS,
		RXDCCOUPLE => RXDCCOUPLE,
		RXLKADJ => RXLKADJ,
		RXDIGRESET => RXDIGRESET,
		RXFECONTROL2 => RXFECONTROL2,
		RXCPTST => RXCPTST,
		RXPDDTST => RXPDDTST,
		RXACTST => RXACTST,
		RXAFETST => RXAFETST,
		RXFECONTROL1 => RXFECONTROL1,
		RXLKAPD => RXLKAPD,
		RXRSDPD => RXRSDPD,
		RXRCPPD => RXRCPPD,
		RXRPDPD => RXRPDPD,
		RXAFEPD => RXAFEPD,
		RXPD => RXPD,
		RXEQ => RXEQ,
		TXOUTDIV2SEL => TXOUTDIV2SEL,
		TXPLLNDIVSEL => TXPLLNDIVSEL,
		TXCLMODE => TXCLMODE,
		TXLOOPFILT => TXLOOPFILT,
		TXTUNE => TXTUNE,
		TXCPSEL => TXCPSEL,
		TXCTRL1 => TXCTRL1,
		TXAPD => TXAPD,
		TXLVLSHFTPD => TXLVLSHFTPD,
		TXPRE_PRDRV_DAC => TXPRE_PRDRV_DAC,
		TXPRE_TAP_PD => TXPRE_TAP_PD,
		TXPRE_TAP_DAC => TXPRE_TAP_DAC,
		TXDIGPD => TXDIGPD,
		TXCLKMODE => TXCLKMODE,
		TXHIGHSIGNALEN => TXHIGHSIGNALEN,
		TXAREFBIASSEL => TXAREFBIASSEL,
		TXTERMTRIM => TXTERMTRIM,
		TXASYNCDIVIDE => TXASYNCDIVIDE,
		TXSLEWRATE => TXSLEWRATE,
		TXPOST_PRDRV_DAC => TXPOST_PRDRV_DAC,
		TXDAT_PRDRV_DAC => TXDAT_PRDRV_DAC,
		TXPOST_TAP_PD => TXPOST_TAP_PD,
		TXPOST_TAP_DAC => TXPOST_TAP_DAC,
		TXDAT_TAP_DAC => TXDAT_TAP_DAC,
		TXPD => TXPD,
		RXOUTDIV2SEL => RXOUTDIV2SEL,
		RXPLLNDIVSEL => RXPLLNDIVSEL,
		RXCLMODE => RXCLMODE,
		RXLOOPFILT => RXLOOPFILT,
		RXDIGRX => RXDIGRX,
		RXTUNE => RXTUNE,
		RXCPSEL => RXCPSEL,
		RXCTRL1 => RXCTRL1,
		RXAPD => RXAPD
)
port map (
		COMBUSIN => z16,
		COMBUSOUT => OPEN16,
		CHBONDO => CHBONDO,
		RXSTATUS => RXSTATUS,
		RXCHARISCOMMA => RXCHARISCOMMA,
		RXCHARISK => RXCHARISK,
		RXCOMMADET => RXCOMMADET,
		RXDATA => RXDATA,
		RXDISPERR => RXDISPERR,
		RXLOSSOFSYNC => RXLOSSOFSYNC,
		RXNOTINTABLE => RXNOTINTABLE,
		RXREALIGN => RXREALIGN,
		RXRUNDISP => RXRUNDISP,
		RXBUFERR => RXBUFERR,
		TXBUFERR => TXBUFERR,
		TXKERR => TXKERR,
		TXRUNDISP => TXRUNDISP,
		RXRECCLK1 => RXRECCLK1,
		RXRECCLK2 => RXRECCLK2,
		TXOUTCLK1 => TXOUTCLK1,
		TXOUTCLK2 => TXOUTCLK2,
		RXLOCK => RXLOCK,
		TXLOCK => TXLOCK,
		RXCYCLELIMIT => RXCYCLELIMIT,
		TXCYCLELIMIT => TXCYCLELIMIT,
		RXCALFAIL => RXCALFAIL,
		TXCALFAIL => TXCALFAIL,
		RXCRCOUT => RXCRCOUT,
		TXCRCOUT => TXCRCOUT,
		RXSIGDET => RXSIGDET,
		DRDY => DRDY,
		DO => DO,
		CHBONDI => CHBONDI,
		ENCHANSYNC => ENCHANSYNC,
		ENMCOMMAALIGN => ENMCOMMAALIGN,
		ENPCOMMAALIGN => ENPCOMMAALIGN,
		LOOPBACK => LOOPBACK,
		POWERDOWN => POWERDOWN,
		RXBLOCKSYNC64B66BUSE => RXBLOCKSYNC64B66BUSE,
		RXCOMMADETUSE => RXCOMMADETUSE,
		RXDATAWIDTH => RXDATAWIDTH,
		RXDEC64B66BUSE => RXDEC64B66BUSE,
		RXDEC8B10BUSE => RXDEC8B10BUSE,
		RXDESCRAM64B66BUSE => RXDESCRAM64B66BUSE,
		RXIGNOREBTF => RXIGNOREBTF,
		RXINTDATAWIDTH => RXINTDATAWIDTH,
		RXPOLARITY => RXPOLARITY,
		RXRESET => RXRESET,
		RXSLIDE => RXSLIDE,
		RXUSRCLK => RXUSRCLK,
		RXUSRCLK2 => RXUSRCLK2,
		TXBYPASS8B10B => TXBYPASS8B10B,
		TXCHARDISPMODE => TXCHARDISPMODE,
		TXCHARDISPVAL => TXCHARDISPVAL,
		TXCHARISK => TXCHARISK,
		TXDATA => TXDATA,
		TXDATAWIDTH => TXDATAWIDTH,
		TXENC64B66BUSE => TXENC64B66BUSE,
		TXENC8B10BUSE => TXENC8B10BUSE,
		TXGEARBOX64B66BUSE => TXGEARBOX64B66BUSE,
		TXINHIBIT => TXINHIBIT,
		TXINTDATAWIDTH => TXINTDATAWIDTH,
		TXPOLARITY => TXPOLARITY,
		TXRESET => TXRESET,
		TXSCRAM64B66BUSE => TXSCRAM64B66BUSE,
		TXUSRCLK => TXUSRCLK,
		TXUSRCLK2 => TXUSRCLK2,
		RXCLKSTABLE => RXCLKSTABLE,
		RXPMARESET => RXPMARESET,
		TXCLKSTABLE => TXCLKSTABLE,
		TXPMARESET => TXPMARESET,
		RXCRCIN => RXCRCIN,
		RXCRCDATAWIDTH => RXCRCDATAWIDTH,
		RXCRCDATAVALID => RXCRCDATAVALID,
		RXCRCINIT => RXCRCINIT,
		RXCRCRESET => RXCRCRESET,
		RXCRCPD => RXCRCPD,
		RXCRCCLK => RXCRCCLK,
		RXCRCINTCLK => RXCRCINTCLK,
		TXCRCIN => TXCRCIN,
		TXCRCDATAWIDTH => TXCRCDATAWIDTH,
		TXCRCDATAVALID => TXCRCDATAVALID,
		TXCRCINIT => TXCRCINIT,
		TXCRCRESET => TXCRCRESET,
		TXCRCPD => TXCRCPD,
		TXCRCCLK => TXCRCCLK,
		TXCRCINTCLK => TXCRCINTCLK,
		TXSYNC => TXSYNC,
		RXSYNC => RXSYNC,
		TXENOOB => TXENOOB,
		DCLK => DCLK,
		DADDR => DADDR,
		DEN => DEN,
		DWE => DWE,
		DI => DI,
		RXMCLK => RXMCLK,
		TX1P => TX1P,
		TX1N => TX1N,
		RX1P => RX1P,
		RX1N => RX1N,
		GREFCLK => GREFCLK,
		REFCLK1 => REFCLK1,
		REFCLK2 => REFCLK2,
		TXPCSHCLKOUT => TXPCSHCLKOUT,
		RXPCSHCLKOUT => RXPCSHCLKOUT

);

end GT11_CUSTOM_V;
