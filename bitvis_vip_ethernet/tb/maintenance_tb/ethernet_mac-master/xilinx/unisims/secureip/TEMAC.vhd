-------------------------------------------------------------------------------
-- Copyright (c) 1995/2006 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor      : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       Tri-Mode Ethernet MAC
-- /___/   /\     Filename    : temac.vhd
-- \   \  /  \    Timestamp   : Thu Dec 8 2005
--  \___\/\___\
--
-- Revision:
--    12/08/05 - Initial version.
--    01/09/06 - Added architecture
--    02/06/06 - pinTime updates
--    02/23/06 - Updated Header
--    03/10/06 - CR#226740. Changed generic type of some of the generics from
--    string to boolean
--    03/27/06 - Updated TEMAC smartmodel to version number 00.002 for following changes
--			CR#224695 - 
--				1. TEMAC smartmodel 16 bit client interface problem.
--				2. Compiled smartmodel with `delay_mode_zero directive
--			CR#226083 - 
--				1. Loopback attributes don't work in Verilog TEMAC smartmodel.
--			CR#224695 - 
--				1 . Added 50 ps input delay to all inputs(except clocks) going into temac swift model
--    04/11/06 - CR#228762 - Added some missing path delays to timing block.
--    04/27/06 - CR#230105 - Fixed connectivity for CLK
--    05/23/06 - CR#231962 - Add buffers for connectivity
--    09/15/06 - CR#423162 - Timing updates
--    10/26/06 -           - replaced ZERO_DELAY with CLK_DELAY to be consistent with writers (PPC440 update)
--    06/08/07 - CR#440717 - Add constant EMAC0MIITXCLK_DELAY & EMAC1MIITXCLK_DELAY
--    08/28/07 - CR#447575 - Path Delay updates due to pinDev/pinTime updates
-- End Revision


----- CELL TEMAC -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity TEMAC is
generic (
	EMAC0_1000BASEX_ENABLE : boolean := FALSE;
	EMAC0_ADDRFILTER_ENABLE : boolean := FALSE;
	EMAC0_BYTEPHY : boolean := FALSE;
	EMAC0_CONFIGVEC_79 : boolean := FALSE;
	EMAC0_DCRBASEADDR : bit_vector := X"00";
	EMAC0_GTLOOPBACK : boolean := FALSE;
	EMAC0_HOST_ENABLE : boolean := FALSE;
	EMAC0_LINKTIMERVAL : bit_vector := X"000";
	EMAC0_LTCHECK_DISABLE : boolean := FALSE;
	EMAC0_MDIO_ENABLE : boolean := FALSE;
	EMAC0_PAUSEADDR : bit_vector := X"000000000000";
	EMAC0_PHYINITAUTONEG_ENABLE : boolean := FALSE;
	EMAC0_PHYISOLATE : boolean := FALSE;
	EMAC0_PHYLOOPBACKMSB : boolean := FALSE;
	EMAC0_PHYPOWERDOWN : boolean := FALSE;
	EMAC0_PHYRESET : boolean := FALSE;
	EMAC0_RGMII_ENABLE : boolean := FALSE;
	EMAC0_RX16BITCLIENT_ENABLE : boolean := FALSE;
	EMAC0_RXFLOWCTRL_ENABLE : boolean := FALSE;
	EMAC0_RXHALFDUPLEX : boolean := FALSE;
	EMAC0_RXINBANDFCS_ENABLE : boolean := FALSE;
	EMAC0_RXJUMBOFRAME_ENABLE : boolean := FALSE;
	EMAC0_RXRESET : boolean := FALSE;
	EMAC0_RXVLAN_ENABLE : boolean := FALSE;
	EMAC0_RX_ENABLE : boolean := FALSE;
	EMAC0_SGMII_ENABLE : boolean := FALSE;
	EMAC0_SPEED_LSB : boolean := FALSE;
	EMAC0_SPEED_MSB : boolean := FALSE;
	EMAC0_TX16BITCLIENT_ENABLE : boolean := FALSE;
	EMAC0_TXFLOWCTRL_ENABLE : boolean := FALSE;
	EMAC0_TXHALFDUPLEX : boolean := FALSE;
	EMAC0_TXIFGADJUST_ENABLE : boolean := FALSE;
	EMAC0_TXINBANDFCS_ENABLE : boolean := FALSE;
	EMAC0_TXJUMBOFRAME_ENABLE : boolean := FALSE;
	EMAC0_TXRESET : boolean := FALSE;
	EMAC0_TXVLAN_ENABLE : boolean := FALSE;
	EMAC0_TX_ENABLE : boolean := FALSE;
	EMAC0_UNICASTADDR : bit_vector := X"000000000000";
	EMAC0_UNIDIRECTION_ENABLE : boolean := FALSE;
	EMAC0_USECLKEN : boolean := FALSE;
	EMAC1_1000BASEX_ENABLE : boolean := FALSE;
	EMAC1_ADDRFILTER_ENABLE : boolean := FALSE;
	EMAC1_BYTEPHY : boolean := FALSE;
	EMAC1_CONFIGVEC_79 : boolean := FALSE;
	EMAC1_DCRBASEADDR : bit_vector := X"00";
	EMAC1_GTLOOPBACK : boolean := FALSE;
	EMAC1_HOST_ENABLE : boolean := FALSE;
	EMAC1_LINKTIMERVAL : bit_vector := X"000";
	EMAC1_LTCHECK_DISABLE : boolean := FALSE;
	EMAC1_MDIO_ENABLE : boolean := FALSE;
	EMAC1_PAUSEADDR : bit_vector := X"000000000000";
	EMAC1_PHYINITAUTONEG_ENABLE : boolean := FALSE;
	EMAC1_PHYISOLATE : boolean := FALSE;
	EMAC1_PHYLOOPBACKMSB : boolean := FALSE;
	EMAC1_PHYPOWERDOWN : boolean := FALSE;
	EMAC1_PHYRESET : boolean := FALSE;
	EMAC1_RGMII_ENABLE : boolean := FALSE;
	EMAC1_RX16BITCLIENT_ENABLE : boolean := FALSE;
	EMAC1_RXFLOWCTRL_ENABLE : boolean := FALSE;
	EMAC1_RXHALFDUPLEX : boolean := FALSE;
	EMAC1_RXINBANDFCS_ENABLE : boolean := FALSE;
	EMAC1_RXJUMBOFRAME_ENABLE : boolean := FALSE;
	EMAC1_RXRESET : boolean := FALSE;
	EMAC1_RXVLAN_ENABLE : boolean := FALSE;
	EMAC1_RX_ENABLE : boolean := FALSE;
	EMAC1_SGMII_ENABLE : boolean := FALSE;
	EMAC1_SPEED_LSB : boolean := FALSE;
	EMAC1_SPEED_MSB : boolean := FALSE;
	EMAC1_TX16BITCLIENT_ENABLE : boolean := FALSE;
	EMAC1_TXFLOWCTRL_ENABLE : boolean := FALSE;
	EMAC1_TXHALFDUPLEX : boolean := FALSE;
	EMAC1_TXIFGADJUST_ENABLE : boolean := FALSE;
	EMAC1_TXINBANDFCS_ENABLE : boolean := FALSE;
	EMAC1_TXJUMBOFRAME_ENABLE : boolean := FALSE;
	EMAC1_TXRESET : boolean := FALSE;
	EMAC1_TXVLAN_ENABLE : boolean := FALSE;
	EMAC1_TX_ENABLE : boolean := FALSE;
	EMAC1_UNICASTADDR : bit_vector := X"000000000000";
	EMAC1_UNIDIRECTION_ENABLE : boolean := FALSE;
	EMAC1_USECLKEN : boolean := FALSE
  );

port (
		DCRHOSTDONEIR : out std_ulogic;
		EMAC0CLIENTANINTERRUPT : out std_ulogic;
		EMAC0CLIENTRXBADFRAME : out std_ulogic;
		EMAC0CLIENTRXCLIENTCLKOUT : out std_ulogic;
		EMAC0CLIENTRXD : out std_logic_vector(15 downto 0);
		EMAC0CLIENTRXDVLD : out std_ulogic;
		EMAC0CLIENTRXDVLDMSW : out std_ulogic;
		EMAC0CLIENTRXFRAMEDROP : out std_ulogic;
		EMAC0CLIENTRXGOODFRAME : out std_ulogic;
		EMAC0CLIENTRXSTATS : out std_logic_vector(6 downto 0);
		EMAC0CLIENTRXSTATSBYTEVLD : out std_ulogic;
		EMAC0CLIENTRXSTATSVLD : out std_ulogic;
		EMAC0CLIENTTXACK : out std_ulogic;
		EMAC0CLIENTTXCLIENTCLKOUT : out std_ulogic;
		EMAC0CLIENTTXCOLLISION : out std_ulogic;
		EMAC0CLIENTTXRETRANSMIT : out std_ulogic;
		EMAC0CLIENTTXSTATS : out std_ulogic;
		EMAC0CLIENTTXSTATSBYTEVLD : out std_ulogic;
		EMAC0CLIENTTXSTATSVLD : out std_ulogic;
		EMAC0PHYENCOMMAALIGN : out std_ulogic;
		EMAC0PHYLOOPBACKMSB : out std_ulogic;
		EMAC0PHYMCLKOUT : out std_ulogic;
		EMAC0PHYMDOUT : out std_ulogic;
		EMAC0PHYMDTRI : out std_ulogic;
		EMAC0PHYMGTRXRESET : out std_ulogic;
		EMAC0PHYMGTTXRESET : out std_ulogic;
		EMAC0PHYPOWERDOWN : out std_ulogic;
		EMAC0PHYSYNCACQSTATUS : out std_ulogic;
		EMAC0PHYTXCHARDISPMODE : out std_ulogic;
		EMAC0PHYTXCHARDISPVAL : out std_ulogic;
		EMAC0PHYTXCHARISK : out std_ulogic;
		EMAC0PHYTXCLK : out std_ulogic;
		EMAC0PHYTXD : out std_logic_vector(7 downto 0);
		EMAC0PHYTXEN : out std_ulogic;
		EMAC0PHYTXER : out std_ulogic;
		EMAC0PHYTXGMIIMIICLKOUT : out std_ulogic;
		EMAC0SPEEDIS10100 : out std_ulogic;
		EMAC1CLIENTANINTERRUPT : out std_ulogic;
		EMAC1CLIENTRXBADFRAME : out std_ulogic;
		EMAC1CLIENTRXCLIENTCLKOUT : out std_ulogic;
		EMAC1CLIENTRXD : out std_logic_vector(15 downto 0);
		EMAC1CLIENTRXDVLD : out std_ulogic;
		EMAC1CLIENTRXDVLDMSW : out std_ulogic;
		EMAC1CLIENTRXFRAMEDROP : out std_ulogic;
		EMAC1CLIENTRXGOODFRAME : out std_ulogic;
		EMAC1CLIENTRXSTATS : out std_logic_vector(6 downto 0);
		EMAC1CLIENTRXSTATSBYTEVLD : out std_ulogic;
		EMAC1CLIENTRXSTATSVLD : out std_ulogic;
		EMAC1CLIENTTXACK : out std_ulogic;
		EMAC1CLIENTTXCLIENTCLKOUT : out std_ulogic;
		EMAC1CLIENTTXCOLLISION : out std_ulogic;
		EMAC1CLIENTTXRETRANSMIT : out std_ulogic;
		EMAC1CLIENTTXSTATS : out std_ulogic;
		EMAC1CLIENTTXSTATSBYTEVLD : out std_ulogic;
		EMAC1CLIENTTXSTATSVLD : out std_ulogic;
		EMAC1PHYENCOMMAALIGN : out std_ulogic;
		EMAC1PHYLOOPBACKMSB : out std_ulogic;
		EMAC1PHYMCLKOUT : out std_ulogic;
		EMAC1PHYMDOUT : out std_ulogic;
		EMAC1PHYMDTRI : out std_ulogic;
		EMAC1PHYMGTRXRESET : out std_ulogic;
		EMAC1PHYMGTTXRESET : out std_ulogic;
		EMAC1PHYPOWERDOWN : out std_ulogic;
		EMAC1PHYSYNCACQSTATUS : out std_ulogic;
		EMAC1PHYTXCHARDISPMODE : out std_ulogic;
		EMAC1PHYTXCHARDISPVAL : out std_ulogic;
		EMAC1PHYTXCHARISK : out std_ulogic;
		EMAC1PHYTXCLK : out std_ulogic;
		EMAC1PHYTXD : out std_logic_vector(7 downto 0);
		EMAC1PHYTXEN : out std_ulogic;
		EMAC1PHYTXER : out std_ulogic;
		EMAC1PHYTXGMIIMIICLKOUT : out std_ulogic;
		EMAC1SPEEDIS10100 : out std_ulogic;
		EMACDCRACK : out std_ulogic;
		EMACDCRDBUS : out std_logic_vector(0 to 31);
		HOSTMIIMRDY : out std_ulogic;
		HOSTRDDATA : out std_logic_vector(31 downto 0);

		CLIENTEMAC0DCMLOCKED : in std_ulogic;
		CLIENTEMAC0PAUSEREQ : in std_ulogic;
		CLIENTEMAC0PAUSEVAL : in std_logic_vector(15 downto 0);
		CLIENTEMAC0RXCLIENTCLKIN : in std_ulogic;
		CLIENTEMAC0TXCLIENTCLKIN : in std_ulogic;
		CLIENTEMAC0TXD : in std_logic_vector(15 downto 0);
		CLIENTEMAC0TXDVLD : in std_ulogic;
		CLIENTEMAC0TXDVLDMSW : in std_ulogic;
		CLIENTEMAC0TXFIRSTBYTE : in std_ulogic;
		CLIENTEMAC0TXIFGDELAY : in std_logic_vector(7 downto 0);
		CLIENTEMAC0TXUNDERRUN : in std_ulogic;
		CLIENTEMAC1DCMLOCKED : in std_ulogic;
		CLIENTEMAC1PAUSEREQ : in std_ulogic;
		CLIENTEMAC1PAUSEVAL : in std_logic_vector(15 downto 0);
		CLIENTEMAC1RXCLIENTCLKIN : in std_ulogic;
		CLIENTEMAC1TXCLIENTCLKIN : in std_ulogic;
		CLIENTEMAC1TXD : in std_logic_vector(15 downto 0);
		CLIENTEMAC1TXDVLD : in std_ulogic;
		CLIENTEMAC1TXDVLDMSW : in std_ulogic;
		CLIENTEMAC1TXFIRSTBYTE : in std_ulogic;
		CLIENTEMAC1TXIFGDELAY : in std_logic_vector(7 downto 0);
		CLIENTEMAC1TXUNDERRUN : in std_ulogic;
		DCREMACABUS : in std_logic_vector(0 to 9);
		DCREMACCLK : in std_ulogic;
		DCREMACDBUS : in std_logic_vector(0 to 31);
		DCREMACENABLE : in std_ulogic;
		DCREMACREAD : in std_ulogic;
		DCREMACWRITE : in std_ulogic;
		HOSTADDR : in std_logic_vector(9 downto 0);
		HOSTCLK : in std_ulogic;
		HOSTEMAC1SEL : in std_ulogic;
		HOSTMIIMSEL : in std_ulogic;
		HOSTOPCODE : in std_logic_vector(1 downto 0);
		HOSTREQ : in std_ulogic;
		HOSTWRDATA : in std_logic_vector(31 downto 0);
		PHYEMAC0COL : in std_ulogic;
		PHYEMAC0CRS : in std_ulogic;
		PHYEMAC0GTXCLK : in std_ulogic;
		PHYEMAC0MCLKIN : in std_ulogic;
		PHYEMAC0MDIN : in std_ulogic;
		PHYEMAC0MIITXCLK : in std_ulogic;
		PHYEMAC0PHYAD : in std_logic_vector(4 downto 0);
		PHYEMAC0RXBUFERR : in std_ulogic;
		PHYEMAC0RXBUFSTATUS : in std_logic_vector(1 downto 0);
		PHYEMAC0RXCHARISCOMMA : in std_ulogic;
		PHYEMAC0RXCHARISK : in std_ulogic;
		PHYEMAC0RXCHECKINGCRC : in std_ulogic;
		PHYEMAC0RXCLK : in std_ulogic;
		PHYEMAC0RXCLKCORCNT : in std_logic_vector(2 downto 0);
		PHYEMAC0RXCOMMADET : in std_ulogic;
		PHYEMAC0RXD : in std_logic_vector(7 downto 0);
		PHYEMAC0RXDISPERR : in std_ulogic;
		PHYEMAC0RXDV : in std_ulogic;
		PHYEMAC0RXER : in std_ulogic;
		PHYEMAC0RXLOSSOFSYNC : in std_logic_vector(1 downto 0);
		PHYEMAC0RXNOTINTABLE : in std_ulogic;
		PHYEMAC0RXRUNDISP : in std_ulogic;
		PHYEMAC0SIGNALDET : in std_ulogic;
		PHYEMAC0TXBUFERR : in std_ulogic;
		PHYEMAC0TXGMIIMIICLKIN : in std_ulogic;
		PHYEMAC1COL : in std_ulogic;
		PHYEMAC1CRS : in std_ulogic;
		PHYEMAC1GTXCLK : in std_ulogic;
		PHYEMAC1MCLKIN : in std_ulogic;
		PHYEMAC1MDIN : in std_ulogic;
		PHYEMAC1MIITXCLK : in std_ulogic;
		PHYEMAC1PHYAD : in std_logic_vector(4 downto 0);
		PHYEMAC1RXBUFERR : in std_ulogic;
		PHYEMAC1RXBUFSTATUS : in std_logic_vector(1 downto 0);
		PHYEMAC1RXCHARISCOMMA : in std_ulogic;
		PHYEMAC1RXCHARISK : in std_ulogic;
		PHYEMAC1RXCHECKINGCRC : in std_ulogic;
		PHYEMAC1RXCLK : in std_ulogic;
		PHYEMAC1RXCLKCORCNT : in std_logic_vector(2 downto 0);
		PHYEMAC1RXCOMMADET : in std_ulogic;
		PHYEMAC1RXD : in std_logic_vector(7 downto 0);
		PHYEMAC1RXDISPERR : in std_ulogic;
		PHYEMAC1RXDV : in std_ulogic;
		PHYEMAC1RXER : in std_ulogic;
		PHYEMAC1RXLOSSOFSYNC : in std_logic_vector(1 downto 0);
		PHYEMAC1RXNOTINTABLE : in std_ulogic;
		PHYEMAC1RXRUNDISP : in std_ulogic;
		PHYEMAC1SIGNALDET : in std_ulogic;
		PHYEMAC1TXBUFERR : in std_ulogic;
		PHYEMAC1TXGMIIMIICLKIN : in std_ulogic;
		RESET : in std_ulogic
     );
end TEMAC;

architecture TEMAC_V of TEMAC is

  
             
  component TEMAC_SWIFT
    port (
      DCRHOSTDONEIR        : out std_ulogic;
      EMAC0CLIENTANINTERRUPT : out std_ulogic;
      EMAC0CLIENTRXBADFRAME : out std_ulogic;
      EMAC0CLIENTRXCLIENTCLKOUT : out std_ulogic;
      EMAC0CLIENTRXD       : out std_logic_vector(15 downto 0);
      EMAC0CLIENTRXDVLD    : out std_ulogic;
      EMAC0CLIENTRXDVLDMSW : out std_ulogic;
      EMAC0CLIENTRXFRAMEDROP : out std_ulogic;
      EMAC0CLIENTRXGOODFRAME : out std_ulogic;
      EMAC0CLIENTRXSTATS   : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSBYTEVLD : out std_ulogic;
      EMAC0CLIENTRXSTATSVLD : out std_ulogic;
      EMAC0CLIENTTXACK     : out std_ulogic;
      EMAC0CLIENTTXCLIENTCLKOUT : out std_ulogic;
      EMAC0CLIENTTXCOLLISION : out std_ulogic;
      EMAC0CLIENTTXRETRANSMIT : out std_ulogic;
      EMAC0CLIENTTXSTATS   : out std_ulogic;
      EMAC0CLIENTTXSTATSBYTEVLD : out std_ulogic;
      EMAC0CLIENTTXSTATSVLD : out std_ulogic;
      EMAC0PHYENCOMMAALIGN : out std_ulogic;
      EMAC0PHYLOOPBACKMSB  : out std_ulogic;
      EMAC0PHYMCLKOUT      : out std_ulogic;
      EMAC0PHYMDOUT        : out std_ulogic;
      EMAC0PHYMDTRI        : out std_ulogic;
      EMAC0PHYMGTRXRESET   : out std_ulogic;
      EMAC0PHYMGTTXRESET   : out std_ulogic;
      EMAC0PHYPOWERDOWN    : out std_ulogic;
      EMAC0PHYSYNCACQSTATUS : out std_ulogic;
      EMAC0PHYTXCHARDISPMODE : out std_ulogic;
      EMAC0PHYTXCHARDISPVAL : out std_ulogic;
      EMAC0PHYTXCHARISK    : out std_ulogic;
      EMAC0PHYTXCLK        : out std_ulogic;
      EMAC0PHYTXD          : out std_logic_vector(7 downto 0);
      EMAC0PHYTXEN         : out std_ulogic;
      EMAC0PHYTXER         : out std_ulogic;
      EMAC0PHYTXGMIIMIICLKOUT : out std_ulogic;
      EMAC0SPEEDIS10100    : out std_ulogic;
      EMAC1CLIENTANINTERRUPT : out std_ulogic;
      EMAC1CLIENTRXBADFRAME : out std_ulogic;
      EMAC1CLIENTRXCLIENTCLKOUT : out std_ulogic;
      EMAC1CLIENTRXD       : out std_logic_vector(15 downto 0);
      EMAC1CLIENTRXDVLD    : out std_ulogic;
      EMAC1CLIENTRXDVLDMSW : out std_ulogic;
      EMAC1CLIENTRXFRAMEDROP : out std_ulogic;
      EMAC1CLIENTRXGOODFRAME : out std_ulogic;
      EMAC1CLIENTRXSTATS   : out std_logic_vector(6 downto 0);
      EMAC1CLIENTRXSTATSBYTEVLD : out std_ulogic;
      EMAC1CLIENTRXSTATSVLD : out std_ulogic;
      EMAC1CLIENTTXACK     : out std_ulogic;
      EMAC1CLIENTTXCLIENTCLKOUT : out std_ulogic;
      EMAC1CLIENTTXCOLLISION : out std_ulogic;
      EMAC1CLIENTTXRETRANSMIT : out std_ulogic;
      EMAC1CLIENTTXSTATS   : out std_ulogic;
      EMAC1CLIENTTXSTATSBYTEVLD : out std_ulogic;
      EMAC1CLIENTTXSTATSVLD : out std_ulogic;
      EMAC1PHYENCOMMAALIGN : out std_ulogic;
      EMAC1PHYLOOPBACKMSB  : out std_ulogic;
      EMAC1PHYMCLKOUT      : out std_ulogic;
      EMAC1PHYMDOUT        : out std_ulogic;
      EMAC1PHYMDTRI        : out std_ulogic;
      EMAC1PHYMGTRXRESET   : out std_ulogic;
      EMAC1PHYMGTTXRESET   : out std_ulogic;
      EMAC1PHYPOWERDOWN    : out std_ulogic;
      EMAC1PHYSYNCACQSTATUS : out std_ulogic;
      EMAC1PHYTXCHARDISPMODE : out std_ulogic;
      EMAC1PHYTXCHARDISPVAL : out std_ulogic;
      EMAC1PHYTXCHARISK    : out std_ulogic;
      EMAC1PHYTXCLK        : out std_ulogic;
      EMAC1PHYTXD          : out std_logic_vector(7 downto 0);
      EMAC1PHYTXEN         : out std_ulogic;
      EMAC1PHYTXER         : out std_ulogic;
      EMAC1PHYTXGMIIMIICLKOUT : out std_ulogic;
      EMAC1SPEEDIS10100    : out std_ulogic;
      EMACDCRACK           : out std_ulogic;
      EMACDCRDBUS          : out std_logic_vector(0 to 31);
      HOSTMIIMRDY          : out std_ulogic;
      HOSTRDDATA           : out std_logic_vector(31 downto 0);

      CLIENTEMAC0DCMLOCKED : in std_ulogic;
      CLIENTEMAC0PAUSEREQ  : in std_ulogic;
      CLIENTEMAC0PAUSEVAL  : in std_logic_vector(15 downto 0);
      CLIENTEMAC0RXCLIENTCLKIN : in std_ulogic;
      CLIENTEMAC0TXCLIENTCLKIN : in std_ulogic;
      CLIENTEMAC0TXD       : in std_logic_vector(15 downto 0);
      CLIENTEMAC0TXDVLD    : in std_ulogic;
      CLIENTEMAC0TXDVLDMSW : in std_ulogic;
      CLIENTEMAC0TXFIRSTBYTE : in std_ulogic;
      CLIENTEMAC0TXIFGDELAY : in std_logic_vector(7 downto 0);
      CLIENTEMAC0TXUNDERRUN : in std_ulogic;
      CLIENTEMAC1DCMLOCKED : in std_ulogic;
      CLIENTEMAC1PAUSEREQ  : in std_ulogic;
      CLIENTEMAC1PAUSEVAL  : in std_logic_vector(15 downto 0);
      CLIENTEMAC1RXCLIENTCLKIN : in std_ulogic;
      CLIENTEMAC1TXCLIENTCLKIN : in std_ulogic;
      CLIENTEMAC1TXD       : in std_logic_vector(15 downto 0);
      CLIENTEMAC1TXDVLD    : in std_ulogic;
      CLIENTEMAC1TXDVLDMSW : in std_ulogic;
      CLIENTEMAC1TXFIRSTBYTE : in std_ulogic;
      CLIENTEMAC1TXIFGDELAY : in std_logic_vector(7 downto 0);
      CLIENTEMAC1TXUNDERRUN : in std_ulogic;
      DCREMACABUS          : in std_logic_vector(0 to 9);
      DCREMACCLK           : in std_ulogic;
      DCREMACDBUS          : in std_logic_vector(0 to 31);
      DCREMACENABLE        : in std_ulogic;
      DCREMACREAD          : in std_ulogic;
      DCREMACWRITE         : in std_ulogic;
      HOSTADDR             : in std_logic_vector(9 downto 0);
      HOSTCLK              : in std_ulogic;
      HOSTEMAC1SEL         : in std_ulogic;
      HOSTMIIMSEL          : in std_ulogic;
      HOSTOPCODE           : in std_logic_vector(1 downto 0);
      HOSTREQ              : in std_ulogic;
      HOSTWRDATA           : in std_logic_vector(31 downto 0);
      PHYEMAC0COL          : in std_ulogic;
      PHYEMAC0CRS          : in std_ulogic;
      PHYEMAC0GTXCLK       : in std_ulogic;
      PHYEMAC0MCLKIN       : in std_ulogic;
      PHYEMAC0MDIN         : in std_ulogic;
      PHYEMAC0MIITXCLK     : in std_ulogic;
      PHYEMAC0PHYAD        : in std_logic_vector(4 downto 0);
      PHYEMAC0RXBUFERR     : in std_ulogic;
      PHYEMAC0RXBUFSTATUS  : in std_logic_vector(1 downto 0);
      PHYEMAC0RXCHARISCOMMA : in std_ulogic;
      PHYEMAC0RXCHARISK    : in std_ulogic;
      PHYEMAC0RXCHECKINGCRC : in std_ulogic;
      PHYEMAC0RXCLK        : in std_ulogic;
      PHYEMAC0RXCLKCORCNT  : in std_logic_vector(2 downto 0);
      PHYEMAC0RXCOMMADET   : in std_ulogic;
      PHYEMAC0RXD          : in std_logic_vector(7 downto 0);
      PHYEMAC0RXDISPERR    : in std_ulogic;
      PHYEMAC0RXDV         : in std_ulogic;
      PHYEMAC0RXER         : in std_ulogic;
      PHYEMAC0RXLOSSOFSYNC : in std_logic_vector(1 downto 0);
      PHYEMAC0RXNOTINTABLE : in std_ulogic;
      PHYEMAC0RXRUNDISP    : in std_ulogic;
      PHYEMAC0SIGNALDET    : in std_ulogic;
      PHYEMAC0TXBUFERR     : in std_ulogic;
      PHYEMAC0TXGMIIMIICLKIN : in std_ulogic;
      PHYEMAC1COL          : in std_ulogic;
      PHYEMAC1CRS          : in std_ulogic;
      PHYEMAC1GTXCLK       : in std_ulogic;
      PHYEMAC1MCLKIN       : in std_ulogic;
      PHYEMAC1MDIN         : in std_ulogic;
      PHYEMAC1MIITXCLK     : in std_ulogic;
      PHYEMAC1PHYAD        : in std_logic_vector(4 downto 0);
      PHYEMAC1RXBUFERR     : in std_ulogic;
      PHYEMAC1RXBUFSTATUS  : in std_logic_vector(1 downto 0);
      PHYEMAC1RXCHARISCOMMA : in std_ulogic;
      PHYEMAC1RXCHARISK    : in std_ulogic;
      PHYEMAC1RXCHECKINGCRC : in std_ulogic;
      PHYEMAC1RXCLK        : in std_ulogic;
      PHYEMAC1RXCLKCORCNT  : in std_logic_vector(2 downto 0);
      PHYEMAC1RXCOMMADET   : in std_ulogic;
      PHYEMAC1RXD          : in std_logic_vector(7 downto 0);
      PHYEMAC1RXDISPERR    : in std_ulogic;
      PHYEMAC1RXDV         : in std_ulogic;
      PHYEMAC1RXER         : in std_ulogic;
      PHYEMAC1RXLOSSOFSYNC : in std_logic_vector(1 downto 0);
      PHYEMAC1RXNOTINTABLE : in std_ulogic;
      PHYEMAC1RXRUNDISP    : in std_ulogic;
      PHYEMAC1SIGNALDET    : in std_ulogic;
      PHYEMAC1TXBUFERR     : in std_ulogic;
      PHYEMAC1TXGMIIMIICLKIN : in std_ulogic;
      RESET                : in std_ulogic;

      EMAC0_1000BASEX_ENABLE    : in std_ulogic;
      EMAC0_ADDRFILTER_ENABLE   : in std_ulogic;
      EMAC0_BYTEPHY             : in std_ulogic;
      EMAC0_CONFIGVEC_79        : in std_ulogic;
      EMAC0_DCRBASEADDR         : in std_logic_vector(0 to 7);
      EMAC0_GTLOOPBACK          : in std_ulogic;
      EMAC0_HOST_ENABLE         : in std_ulogic;
      EMAC0_LINKTIMERVAL        : in std_logic_vector(8 downto 0);
      EMAC0_LTCHECK_DISABLE     : in std_ulogic;
      EMAC0_MDIO_ENABLE         : in std_ulogic;
      EMAC0_PAUSEADDR           : in std_logic_vector(47 downto 0);
      EMAC0_PHYINITAUTONEG_ENABLE : in std_ulogic;
      EMAC0_PHYISOLATE          : in std_ulogic;
      EMAC0_PHYLOOPBACKMSB      : in std_ulogic;
      EMAC0_PHYPOWERDOWN        : in std_ulogic;
      EMAC0_PHYRESET            : in std_ulogic;
      EMAC0_RGMII_ENABLE        : in std_ulogic;
      EMAC0_RX16BITCLIENT_ENABLE : in std_ulogic;
      EMAC0_RXFLOWCTRL_ENABLE   : in std_ulogic;
      EMAC0_RXHALFDUPLEX        : in std_ulogic;
      EMAC0_RXINBANDFCS_ENABLE  : in std_ulogic;
      EMAC0_RXJUMBOFRAME_ENABLE : in std_ulogic;
      EMAC0_RXRESET             : in std_ulogic;
      EMAC0_RXVLAN_ENABLE       : in std_ulogic;
      EMAC0_RX_ENABLE           : in std_ulogic;
      EMAC0_SGMII_ENABLE        : in std_ulogic;
      EMAC0_SPEED_LSB           : in std_ulogic;
      EMAC0_SPEED_MSB           : in std_ulogic;
      EMAC0_TX16BITCLIENT_ENABLE : in std_ulogic;
      EMAC0_TXFLOWCTRL_ENABLE   : in std_ulogic;
      EMAC0_TXHALFDUPLEX        : in std_ulogic;
      EMAC0_TXIFGADJUST_ENABLE  : in std_ulogic;
      EMAC0_TXINBANDFCS_ENABLE  : in std_ulogic;
      EMAC0_TXJUMBOFRAME_ENABLE : in std_ulogic;
      EMAC0_TXRESET             : in std_ulogic;
      EMAC0_TXVLAN_ENABLE       : in std_ulogic;
      EMAC0_TX_ENABLE           : in std_ulogic;
      EMAC0_UNICASTADDR         : in std_logic_vector(47 downto 0);
      EMAC0_UNIDIRECTION_ENABLE : in std_ulogic;
      EMAC0_USECLKEN            : in std_ulogic;
      EMAC1_1000BASEX_ENABLE    : in std_ulogic;
      EMAC1_ADDRFILTER_ENABLE   : in std_ulogic;
      EMAC1_BYTEPHY             : in std_ulogic;
      EMAC1_CONFIGVEC_79        : in std_ulogic;
      EMAC1_DCRBASEADDR         : in std_logic_vector(0 to 7);
      EMAC1_GTLOOPBACK          : in std_ulogic;
      EMAC1_HOST_ENABLE         : in std_ulogic;
      EMAC1_LINKTIMERVAL        : in std_logic_vector(8 downto 0);
      EMAC1_LTCHECK_DISABLE     : in std_ulogic;
      EMAC1_MDIO_ENABLE         : in std_ulogic;
      EMAC1_PAUSEADDR           : in std_logic_vector(47 downto 0);
      EMAC1_PHYINITAUTONEG_ENABLE : in std_ulogic;
      EMAC1_PHYISOLATE          : in std_ulogic;
      EMAC1_PHYLOOPBACKMSB      : in std_ulogic;
      EMAC1_PHYPOWERDOWN        : in std_ulogic;
      EMAC1_PHYRESET            : in std_ulogic;
      EMAC1_RGMII_ENABLE        : in std_ulogic;
      EMAC1_RX16BITCLIENT_ENABLE : in std_ulogic;
      EMAC1_RXFLOWCTRL_ENABLE   : in std_ulogic;
      EMAC1_RXHALFDUPLEX        : in std_ulogic;
      EMAC1_RXINBANDFCS_ENABLE  : in std_ulogic;
      EMAC1_RXJUMBOFRAME_ENABLE : in std_ulogic;
      EMAC1_RXRESET             : in std_ulogic;
      EMAC1_RXVLAN_ENABLE       : in std_ulogic;
      EMAC1_RX_ENABLE           : in std_ulogic;
      EMAC1_SGMII_ENABLE        : in std_ulogic;
      EMAC1_SPEED_LSB           : in std_ulogic;
      EMAC1_SPEED_MSB           : in std_ulogic;
      EMAC1_TX16BITCLIENT_ENABLE : in std_ulogic;
      EMAC1_TXFLOWCTRL_ENABLE   : in std_ulogic;
      EMAC1_TXHALFDUPLEX        : in std_ulogic;
      EMAC1_TXIFGADJUST_ENABLE  : in std_ulogic;
      EMAC1_TXINBANDFCS_ENABLE  : in std_ulogic;
      EMAC1_TXJUMBOFRAME_ENABLE : in std_ulogic;
      EMAC1_TXRESET             : in std_ulogic;
      EMAC1_TXVLAN_ENABLE       : in std_ulogic;
      EMAC1_TX_ENABLE           : in std_ulogic;
      EMAC1_UNICASTADDR         : in std_logic_vector(47 downto 0);
      EMAC1_UNIDIRECTION_ENABLE : in std_ulogic;
      EMAC1_USECLKEN            : in std_ulogic
    );
  end component;


  function GetValue_EMAC0 (
    EMAC0_TX16BITCLIENT_ENABLE : in boolean
    )  return time is 
    variable delay_time : time;
  begin 
    case EMAC0_TX16BITCLIENT_ENABLE is 
      when TRUE => delay_time := 25 ps;
      when FALSE => delay_time := 0 ps;
    end case;
    return delay_time;
  end;

  function GetValue_EMAC1 (
    EMAC1_TX16BITCLIENT_ENABLE : in boolean
    )  return time is 
    variable delay_time : time;
  begin 
    case EMAC1_TX16BITCLIENT_ENABLE is 
      when TRUE => delay_time := 25 ps;
      when FALSE => delay_time := 0 ps;
    end case;
    return delay_time;
  end;
        constant IN_DELAY : time := 50 ps;
	constant OUT_DELAY : time := 0 ps;
        constant CLK_DELAY : time := 0 ps;
        constant EMAC0MIITXCLK_DELAY : time := GetValue_EMAC0(EMAC0_TX16BITCLIENT_ENABLE);
        constant EMAC1MIITXCLK_DELAY : time := GetValue_EMAC1(EMAC1_TX16BITCLIENT_ENABLE);

	constant PATH_DELAY : VitalDelayType01 := (100 ps, 100 ps);  

       	signal   EMAC0_PAUSEADDR_BINARY  :  std_logic_vector(47 downto 0) := To_StdLogicVector(EMAC0_PAUSEADDR);
	signal   EMAC0_RXHALFDUPLEX_BINARY  :  std_ulogic;
	signal   EMAC0_RXVLAN_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_RX_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_RXINBANDFCS_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_RXJUMBOFRAME_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_RXRESET_BINARY  :  std_ulogic;
	signal   EMAC0_TXIFGADJUST_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_TXHALFDUPLEX_BINARY  :  std_ulogic;
	signal   EMAC0_TXVLAN_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_TX_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_TXINBANDFCS_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_TXJUMBOFRAME_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_TXRESET_BINARY  :  std_ulogic;
	signal   EMAC0_TXFLOWCTRL_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_RXFLOWCTRL_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_LTCHECK_DISABLE_BINARY  :  std_ulogic;
	signal   EMAC0_ADDRFILTER_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_RX16BITCLIENT_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_TX16BITCLIENT_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_HOST_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_1000BASEX_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_SGMII_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_RGMII_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_SPEED_LSB_BINARY  :  std_ulogic;
	signal   EMAC0_SPEED_MSB_BINARY  :  std_ulogic;
	signal   EMAC0_MDIO_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_PHYLOOPBACKMSB_BINARY  :  std_ulogic;
	signal   EMAC0_PHYPOWERDOWN_BINARY  :  std_ulogic;
	signal   EMAC0_PHYISOLATE_BINARY  :  std_ulogic;
	signal   EMAC0_PHYINITAUTONEG_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_PHYRESET_BINARY  :  std_ulogic;
	signal   EMAC0_CONFIGVEC_79_BINARY  :  std_ulogic;
	signal   EMAC0_UNIDIRECTION_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC0_GTLOOPBACK_BINARY  :  std_ulogic;
	signal   EMAC0_UNICASTADDR_BINARY  :  std_logic_vector(47 downto 0) := To_StdLogicVector(EMAC0_UNICASTADDR);
	signal   EMAC0_LINKTIMERVAL_BINARY  :  std_logic_vector(8 downto 0) := To_StdLogicVector(EMAC0_LINKTIMERVAL)(8 downto 0);
	signal   EMAC0_BYTEPHY_BINARY  :  std_ulogic;
	signal   EMAC0_USECLKEN_BINARY  :  std_ulogic;
	signal   EMAC0_DCRBASEADDR_BINARY  :  std_logic_vector(0 to 7) := To_StdLogicVector(EMAC0_DCRBASEADDR);
	signal   EMAC1_PAUSEADDR_BINARY  :  std_logic_vector(47 downto 0) := To_StdLogicVector(EMAC1_PAUSEADDR);
	signal   EMAC1_RXHALFDUPLEX_BINARY  :  std_ulogic;
	signal   EMAC1_RXVLAN_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_RX_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_RXINBANDFCS_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_RXJUMBOFRAME_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_RXRESET_BINARY  :  std_ulogic;
	signal   EMAC1_TXIFGADJUST_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_TXHALFDUPLEX_BINARY  :  std_ulogic;
	signal   EMAC1_TXVLAN_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_TX_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_TXINBANDFCS_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_TXJUMBOFRAME_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_TXRESET_BINARY  :  std_ulogic;
	signal   EMAC1_TXFLOWCTRL_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_RXFLOWCTRL_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_LTCHECK_DISABLE_BINARY  :  std_ulogic;
	signal   EMAC1_ADDRFILTER_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_RX16BITCLIENT_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_TX16BITCLIENT_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_HOST_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_1000BASEX_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_SGMII_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_RGMII_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_SPEED_LSB_BINARY  :  std_ulogic;
	signal   EMAC1_SPEED_MSB_BINARY  :  std_ulogic;
	signal   EMAC1_MDIO_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_PHYLOOPBACKMSB_BINARY  :  std_ulogic;
	signal   EMAC1_PHYPOWERDOWN_BINARY  :  std_ulogic;
	signal   EMAC1_PHYISOLATE_BINARY  :  std_ulogic;
	signal   EMAC1_PHYINITAUTONEG_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_PHYRESET_BINARY  :  std_ulogic;
	signal   EMAC1_CONFIGVEC_79_BINARY  :  std_ulogic;
	signal   EMAC1_UNIDIRECTION_ENABLE_BINARY  :  std_ulogic;
	signal   EMAC1_GTLOOPBACK_BINARY  :  std_ulogic;
	signal   EMAC1_UNICASTADDR_BINARY  :  std_logic_vector(47 downto 0) := To_StdLogicVector(EMAC1_UNICASTADDR);
	signal   EMAC1_LINKTIMERVAL_BINARY  :  std_logic_vector(8 downto 0) := To_StdLogicVector(EMAC1_LINKTIMERVAL)(8 downto 0);
	signal   EMAC1_BYTEPHY_BINARY  :  std_ulogic;
	signal   EMAC1_USECLKEN_BINARY  :  std_ulogic;
	signal   EMAC1_DCRBASEADDR_BINARY  :  std_logic_vector(0 to 7) := To_StdLogicVector(EMAC1_DCRBASEADDR);

	signal   DCRHOSTDONEIR_out  :  std_ulogic;
	signal   EMAC0CLIENTANINTERRUPT_out  :  std_ulogic;
	signal   EMAC0CLIENTRXBADFRAME_out  :  std_ulogic;
	signal   EMAC0CLIENTRXCLIENTCLKOUT_out  :  std_ulogic;
	signal   EMAC0CLIENTRXD_out  :  std_logic_vector(15 downto 0);
	signal   EMAC0CLIENTRXDVLD_out  :  std_ulogic;
	signal   EMAC0CLIENTRXDVLDMSW_out  :  std_ulogic;
	signal   EMAC0CLIENTRXFRAMEDROP_out  :  std_ulogic;
	signal   EMAC0CLIENTRXGOODFRAME_out  :  std_ulogic;
	signal   EMAC0CLIENTRXSTATS_out  :  std_logic_vector(6 downto 0);
	signal   EMAC0CLIENTRXSTATSBYTEVLD_out  :  std_ulogic;
	signal   EMAC0CLIENTRXSTATSVLD_out  :  std_ulogic;
	signal   EMAC0CLIENTTXACK_out  :  std_ulogic;
	signal   EMAC0CLIENTTXCLIENTCLKOUT_out  :  std_ulogic;
	signal   EMAC0CLIENTTXCOLLISION_out  :  std_ulogic;
	signal   EMAC0PHYTXGMIIMIICLKOUT_out  :  std_ulogic;
	signal   EMAC0CLIENTTXRETRANSMIT_out  :  std_ulogic;
	signal   EMAC0CLIENTTXSTATS_out  :  std_ulogic;
	signal   EMAC0CLIENTTXSTATSBYTEVLD_out  :  std_ulogic;
	signal   EMAC0CLIENTTXSTATSVLD_out  :  std_ulogic;
	signal   EMAC0PHYENCOMMAALIGN_out  :  std_ulogic;
	signal   EMAC0PHYLOOPBACKMSB_out  :  std_ulogic;
	signal   EMAC0PHYMCLKOUT_out  :  std_ulogic;
	signal   EMAC0PHYMDOUT_out  :  std_ulogic;
	signal   EMAC0PHYMDTRI_out  :  std_ulogic;
	signal   EMAC0PHYMGTRXRESET_out  :  std_ulogic;
	signal   EMAC0PHYMGTTXRESET_out  :  std_ulogic;
	signal   EMAC0PHYPOWERDOWN_out  :  std_ulogic;
	signal   EMAC0PHYSYNCACQSTATUS_out  :  std_ulogic;
	signal   EMAC0PHYTXCHARDISPMODE_out  :  std_ulogic;
	signal   EMAC0PHYTXCHARDISPVAL_out  :  std_ulogic;
	signal   EMAC0PHYTXCHARISK_out  :  std_ulogic;
	signal   EMAC0PHYTXCLK_out  :  std_ulogic;
	signal   EMAC0PHYTXD_out  :  std_logic_vector(7 downto 0);
	signal   EMAC0PHYTXEN_out  :  std_ulogic;
	signal   EMAC0PHYTXER_out  :  std_ulogic;
	signal   EMAC0SPEEDIS10100_out  :  std_ulogic;
	signal   EMAC1CLIENTANINTERRUPT_out  :  std_ulogic;
	signal   EMAC1CLIENTRXBADFRAME_out  :  std_ulogic;
	signal   EMAC1CLIENTRXCLIENTCLKOUT_out  :  std_ulogic;
	signal   EMAC1CLIENTRXD_out  :  std_logic_vector(15 downto 0);
	signal   EMAC1CLIENTRXDVLD_out  :  std_ulogic;
	signal   EMAC1CLIENTRXDVLDMSW_out  :  std_ulogic;
	signal   EMAC1CLIENTRXFRAMEDROP_out  :  std_ulogic;
	signal   EMAC1CLIENTRXGOODFRAME_out  :  std_ulogic;
	signal   EMAC1CLIENTRXSTATS_out  :  std_logic_vector(6 downto 0);
	signal   EMAC1CLIENTRXSTATSBYTEVLD_out  :  std_ulogic;
	signal   EMAC1CLIENTRXSTATSVLD_out  :  std_ulogic;
	signal   EMAC1CLIENTTXACK_out  :  std_ulogic;
	signal   EMAC1CLIENTTXCLIENTCLKOUT_out  :  std_ulogic;
	signal   EMAC1CLIENTTXCOLLISION_out  :  std_ulogic;
	signal   EMAC1PHYTXGMIIMIICLKOUT_out  :  std_ulogic;
	signal   EMAC1CLIENTTXRETRANSMIT_out  :  std_ulogic;
	signal   EMAC1CLIENTTXSTATS_out  :  std_ulogic;
	signal   EMAC1CLIENTTXSTATSBYTEVLD_out  :  std_ulogic;
	signal   EMAC1CLIENTTXSTATSVLD_out  :  std_ulogic;
	signal   EMAC1PHYENCOMMAALIGN_out  :  std_ulogic;
	signal   EMAC1PHYLOOPBACKMSB_out  :  std_ulogic;
	signal   EMAC1PHYMCLKOUT_out  :  std_ulogic;
	signal   EMAC1PHYMDOUT_out  :  std_ulogic;
	signal   EMAC1PHYMDTRI_out  :  std_ulogic;
	signal   EMAC1PHYMGTRXRESET_out  :  std_ulogic;
	signal   EMAC1PHYMGTTXRESET_out  :  std_ulogic;
	signal   EMAC1PHYPOWERDOWN_out  :  std_ulogic;
	signal   EMAC1PHYSYNCACQSTATUS_out  :  std_ulogic;
	signal   EMAC1PHYTXCHARDISPMODE_out  :  std_ulogic;
	signal   EMAC1PHYTXCHARDISPVAL_out  :  std_ulogic;
	signal   EMAC1PHYTXCHARISK_out  :  std_ulogic;
	signal   EMAC1PHYTXCLK_out  :  std_ulogic;
	signal   EMAC1PHYTXD_out  :  std_logic_vector(7 downto 0);
	signal   EMAC1PHYTXEN_out  :  std_ulogic;
	signal   EMAC1PHYTXER_out  :  std_ulogic;
	signal   EMAC1SPEEDIS10100_out  :  std_ulogic;
	signal   EMACDCRACK_out  :  std_ulogic;
	signal   EMACDCRDBUS_out  :  std_logic_vector(0 to 31);
	signal   HOSTMIIMRDY_out  :  std_ulogic;
	signal   HOSTRDDATA_out  :  std_logic_vector(31 downto 0);

	signal   EMAC0CLIENTRXCLIENTCLKOUT_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTTXCLIENTCLKOUT_outdelay  :  std_ulogic;
	signal   EMAC0PHYTXGMIIMIICLKOUT_outdelay  :  std_ulogic;
	signal   EMAC0PHYMCLKOUT_outdelay  :  std_ulogic;
	signal   EMAC0PHYTXCLK_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXCLIENTCLKOUT_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTTXCLIENTCLKOUT_outdelay  :  std_ulogic;
	signal   EMAC1PHYTXGMIIMIICLKOUT_outdelay  :  std_ulogic;
	signal   EMAC1PHYMCLKOUT_outdelay  :  std_ulogic;
	signal   EMAC1PHYTXCLK_outdelay  :  std_ulogic;

	signal   DCRHOSTDONEIR_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTANINTERRUPT_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTRXBADFRAME_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTRXD_outdelay  :  std_logic_vector(15 downto 0);
	signal   EMAC0CLIENTRXDVLD_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTRXDVLDMSW_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTRXFRAMEDROP_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTRXGOODFRAME_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTRXSTATS_outdelay  :  std_logic_vector(6 downto 0);
	signal   EMAC0CLIENTRXSTATSBYTEVLD_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTRXSTATSVLD_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTTXACK_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTTXCOLLISION_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTTXRETRANSMIT_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTTXSTATS_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTTXSTATSBYTEVLD_outdelay  :  std_ulogic;
	signal   EMAC0CLIENTTXSTATSVLD_outdelay  :  std_ulogic;
	signal   EMAC0PHYENCOMMAALIGN_outdelay  :  std_ulogic;
	signal   EMAC0PHYLOOPBACKMSB_outdelay  :  std_ulogic;
	signal   EMAC0PHYMDOUT_outdelay  :  std_ulogic;
	signal   EMAC0PHYMDTRI_outdelay  :  std_ulogic;
	signal   EMAC0PHYMGTRXRESET_outdelay  :  std_ulogic;
	signal   EMAC0PHYMGTTXRESET_outdelay  :  std_ulogic;
	signal   EMAC0PHYPOWERDOWN_outdelay  :  std_ulogic;
	signal   EMAC0PHYSYNCACQSTATUS_outdelay  :  std_ulogic;
	signal   EMAC0PHYTXCHARDISPMODE_outdelay  :  std_ulogic;
	signal   EMAC0PHYTXCHARDISPVAL_outdelay  :  std_ulogic;
	signal   EMAC0PHYTXCHARISK_outdelay  :  std_ulogic;
	signal   EMAC0PHYTXD_outdelay  :  std_logic_vector(7 downto 0);
	signal   EMAC0PHYTXEN_outdelay  :  std_ulogic;
	signal   EMAC0PHYTXER_outdelay  :  std_ulogic;
	signal   EMAC0SPEEDIS10100_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTANINTERRUPT_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXBADFRAME_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXD_outdelay  :  std_logic_vector(15 downto 0);
	signal   EMAC1CLIENTRXDVLD_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXDVLDMSW_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXFRAMEDROP_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXGOODFRAME_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXSTATS_outdelay  :  std_logic_vector(6 downto 0);
	signal   EMAC1CLIENTRXSTATSBYTEVLD_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTRXSTATSVLD_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTTXACK_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTTXCOLLISION_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTTXRETRANSMIT_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTTXSTATS_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTTXSTATSBYTEVLD_outdelay  :  std_ulogic;
	signal   EMAC1CLIENTTXSTATSVLD_outdelay  :  std_ulogic;
	signal   EMAC1PHYENCOMMAALIGN_outdelay  :  std_ulogic;
	signal   EMAC1PHYLOOPBACKMSB_outdelay  :  std_ulogic;
	signal   EMAC1PHYMDOUT_outdelay  :  std_ulogic;
	signal   EMAC1PHYMDTRI_outdelay  :  std_ulogic;
	signal   EMAC1PHYMGTRXRESET_outdelay  :  std_ulogic;
	signal   EMAC1PHYMGTTXRESET_outdelay  :  std_ulogic;
	signal   EMAC1PHYPOWERDOWN_outdelay  :  std_ulogic;
	signal   EMAC1PHYSYNCACQSTATUS_outdelay  :  std_ulogic;
	signal   EMAC1PHYTXCHARDISPMODE_outdelay  :  std_ulogic;
	signal   EMAC1PHYTXCHARDISPVAL_outdelay  :  std_ulogic;
	signal   EMAC1PHYTXCHARISK_outdelay  :  std_ulogic;
	signal   EMAC1PHYTXD_outdelay  :  std_logic_vector(7 downto 0);
	signal   EMAC1PHYTXEN_outdelay  :  std_ulogic;
	signal   EMAC1PHYTXER_outdelay  :  std_ulogic;
	signal   EMAC1SPEEDIS10100_outdelay  :  std_ulogic;
	signal   EMACDCRACK_outdelay  :  std_ulogic;
	signal   EMACDCRDBUS_outdelay  :  std_logic_vector(0 to 31);
	signal   HOSTMIIMRDY_outdelay  :  std_ulogic;
	signal   HOSTRDDATA_outdelay  :  std_logic_vector(31 downto 0);

	signal   CLIENTEMAC0DCMLOCKED_ipd  :  std_ulogic;
	signal   CLIENTEMAC0PAUSEREQ_ipd  :  std_ulogic;
	signal   CLIENTEMAC0PAUSEVAL_ipd  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC0RXCLIENTCLKIN_ipd  :  std_ulogic;
	signal   CLIENTEMAC0TXCLIENTCLKIN_ipd  :  std_ulogic;
	signal   CLIENTEMAC0TXD_ipd  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC0TXDVLD_ipd  :  std_ulogic;
	signal   CLIENTEMAC0TXDVLDMSW_ipd  :  std_ulogic;
	signal   CLIENTEMAC0TXFIRSTBYTE_ipd  :  std_ulogic;
	signal   PHYEMAC0TXGMIIMIICLKIN_ipd  :  std_ulogic;
	signal   CLIENTEMAC0TXIFGDELAY_ipd  :  std_logic_vector(7 downto 0);
	signal   CLIENTEMAC0TXUNDERRUN_ipd  :  std_ulogic;
	signal   CLIENTEMAC1DCMLOCKED_ipd  :  std_ulogic;
	signal   CLIENTEMAC1PAUSEREQ_ipd  :  std_ulogic;
	signal   CLIENTEMAC1PAUSEVAL_ipd  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC1RXCLIENTCLKIN_ipd  :  std_ulogic;
	signal   CLIENTEMAC1TXCLIENTCLKIN_ipd  :  std_ulogic;
	signal   CLIENTEMAC1TXD_ipd  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC1TXDVLD_ipd  :  std_ulogic;
	signal   CLIENTEMAC1TXDVLDMSW_ipd  :  std_ulogic;
	signal   CLIENTEMAC1TXFIRSTBYTE_ipd  :  std_ulogic;
	signal   PHYEMAC1TXGMIIMIICLKIN_ipd  :  std_ulogic;
	signal   CLIENTEMAC1TXIFGDELAY_ipd  :  std_logic_vector(7 downto 0);
	signal   CLIENTEMAC1TXUNDERRUN_ipd  :  std_ulogic;
	signal   DCREMACABUS_ipd  :  std_logic_vector(0 to 9);
	signal   DCREMACCLK_ipd  :  std_ulogic;
	signal   DCREMACDBUS_ipd  :  std_logic_vector(0 to 31);
	signal   DCREMACENABLE_ipd  :  std_ulogic;
	signal   DCREMACREAD_ipd  :  std_ulogic;
	signal   DCREMACWRITE_ipd  :  std_ulogic;
	signal   HOSTADDR_ipd  :  std_logic_vector(9 downto 0);
	signal   HOSTCLK_ipd  :  std_ulogic;
	signal   HOSTEMAC1SEL_ipd  :  std_ulogic;
	signal   HOSTMIIMSEL_ipd  :  std_ulogic;
	signal   HOSTOPCODE_ipd  :  std_logic_vector(1 downto 0);
	signal   HOSTREQ_ipd  :  std_ulogic;
	signal   HOSTWRDATA_ipd  :  std_logic_vector(31 downto 0);
	signal   PHYEMAC0COL_ipd  :  std_ulogic;
	signal   PHYEMAC0CRS_ipd  :  std_ulogic;
	signal   PHYEMAC0GTXCLK_ipd  :  std_ulogic;
	signal   PHYEMAC0MCLKIN_ipd  :  std_ulogic;
	signal   PHYEMAC0MDIN_ipd  :  std_ulogic;
	signal   PHYEMAC0MIITXCLK_ipd  :  std_ulogic;
	signal   PHYEMAC0PHYAD_ipd  :  std_logic_vector(4 downto 0);
	signal   PHYEMAC0RXBUFERR_ipd  :  std_ulogic;
	signal   PHYEMAC0RXBUFSTATUS_ipd  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC0RXCHARISCOMMA_ipd  :  std_ulogic;
	signal   PHYEMAC0RXCHARISK_ipd  :  std_ulogic;
	signal   PHYEMAC0RXCHECKINGCRC_ipd  :  std_ulogic;
	signal   PHYEMAC0RXCLK_ipd  :  std_ulogic;
	signal   PHYEMAC0RXCLKCORCNT_ipd  :  std_logic_vector(2 downto 0);
	signal   PHYEMAC0RXCOMMADET_ipd  :  std_ulogic;
	signal   PHYEMAC0RXD_ipd  :  std_logic_vector(7 downto 0);
	signal   PHYEMAC0RXDISPERR_ipd  :  std_ulogic;
	signal   PHYEMAC0RXDV_ipd  :  std_ulogic;
	signal   PHYEMAC0RXER_ipd  :  std_ulogic;
	signal   PHYEMAC0RXLOSSOFSYNC_ipd  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC0RXNOTINTABLE_ipd  :  std_ulogic;
	signal   PHYEMAC0RXRUNDISP_ipd  :  std_ulogic;
	signal   PHYEMAC0SIGNALDET_ipd  :  std_ulogic;
	signal   PHYEMAC0TXBUFERR_ipd  :  std_ulogic;
	signal   PHYEMAC1COL_ipd  :  std_ulogic;
	signal   PHYEMAC1CRS_ipd  :  std_ulogic;
	signal   PHYEMAC1GTXCLK_ipd  :  std_ulogic;
	signal   PHYEMAC1MCLKIN_ipd  :  std_ulogic;
	signal   PHYEMAC1MDIN_ipd  :  std_ulogic;
	signal   PHYEMAC1MIITXCLK_ipd  :  std_ulogic;
	signal   PHYEMAC1PHYAD_ipd  :  std_logic_vector(4 downto 0);
	signal   PHYEMAC1RXBUFERR_ipd  :  std_ulogic;
	signal   PHYEMAC1RXBUFSTATUS_ipd  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC1RXCHARISCOMMA_ipd  :  std_ulogic;
	signal   PHYEMAC1RXCHARISK_ipd  :  std_ulogic;
	signal   PHYEMAC1RXCHECKINGCRC_ipd  :  std_ulogic;
	signal   PHYEMAC1RXCLK_ipd  :  std_ulogic;
	signal   PHYEMAC1RXCLKCORCNT_ipd  :  std_logic_vector(2 downto 0);
	signal   PHYEMAC1RXCOMMADET_ipd  :  std_ulogic;
	signal   PHYEMAC1RXD_ipd  :  std_logic_vector(7 downto 0);
	signal   PHYEMAC1RXDISPERR_ipd  :  std_ulogic;
	signal   PHYEMAC1RXDV_ipd  :  std_ulogic;
	signal   PHYEMAC1RXER_ipd  :  std_ulogic;
	signal   PHYEMAC1RXLOSSOFSYNC_ipd  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC1RXNOTINTABLE_ipd  :  std_ulogic;
	signal   PHYEMAC1RXRUNDISP_ipd  :  std_ulogic;
	signal   PHYEMAC1SIGNALDET_ipd  :  std_ulogic;
	signal   PHYEMAC1TXBUFERR_ipd  :  std_ulogic;
	signal   RESET_ipd  :  std_ulogic;

	signal   CLIENTEMAC0DCMLOCKED_indelay  :  std_ulogic;
	signal   CLIENTEMAC0PAUSEREQ_indelay  :  std_ulogic;
	signal   CLIENTEMAC0PAUSEVAL_indelay  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC0RXCLIENTCLKIN_indelay  :  std_ulogic;
	signal   CLIENTEMAC0TXCLIENTCLKIN_indelay  :  std_ulogic;
	signal   CLIENTEMAC0TXD_indelay  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC0TXDVLD_indelay  :  std_ulogic;
	signal   CLIENTEMAC0TXDVLDMSW_indelay  :  std_ulogic;
	signal   CLIENTEMAC0TXFIRSTBYTE_indelay  :  std_ulogic;
	signal   PHYEMAC0TXGMIIMIICLKIN_indelay  :  std_ulogic;
	signal   CLIENTEMAC0TXIFGDELAY_indelay  :  std_logic_vector(7 downto 0);
	signal   CLIENTEMAC0TXUNDERRUN_indelay  :  std_ulogic;
	signal   CLIENTEMAC1DCMLOCKED_indelay  :  std_ulogic;
	signal   CLIENTEMAC1PAUSEREQ_indelay  :  std_ulogic;
	signal   CLIENTEMAC1PAUSEVAL_indelay  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC1RXCLIENTCLKIN_indelay  :  std_ulogic;
	signal   CLIENTEMAC1TXCLIENTCLKIN_indelay  :  std_ulogic;
	signal   CLIENTEMAC1TXD_indelay  :  std_logic_vector(15 downto 0);
	signal   CLIENTEMAC1TXDVLD_indelay  :  std_ulogic;
	signal   CLIENTEMAC1TXDVLDMSW_indelay  :  std_ulogic;
	signal   CLIENTEMAC1TXFIRSTBYTE_indelay  :  std_ulogic;
	signal   PHYEMAC1TXGMIIMIICLKIN_indelay  :  std_ulogic;
	signal   CLIENTEMAC1TXIFGDELAY_indelay  :  std_logic_vector(7 downto 0);
	signal   CLIENTEMAC1TXUNDERRUN_indelay  :  std_ulogic;
	signal   DCREMACABUS_indelay  :  std_logic_vector(0 to 9);
	signal   DCREMACCLK_indelay  :  std_ulogic;
	signal   DCREMACDBUS_indelay  :  std_logic_vector(0 to 31);
	signal   DCREMACENABLE_indelay  :  std_ulogic;
	signal   DCREMACREAD_indelay  :  std_ulogic;
	signal   DCREMACWRITE_indelay  :  std_ulogic;
	signal   HOSTADDR_indelay  :  std_logic_vector(9 downto 0);
	signal   HOSTCLK_indelay  :  std_ulogic;
	signal   HOSTEMAC1SEL_indelay  :  std_ulogic;
	signal   HOSTMIIMSEL_indelay  :  std_ulogic;
	signal   HOSTOPCODE_indelay  :  std_logic_vector(1 downto 0);
	signal   HOSTREQ_indelay  :  std_ulogic;
	signal   HOSTWRDATA_indelay  :  std_logic_vector(31 downto 0);
	signal   PHYEMAC0COL_indelay  :  std_ulogic;
	signal   PHYEMAC0CRS_indelay  :  std_ulogic;
	signal   PHYEMAC0GTXCLK_indelay  :  std_ulogic;
	signal   PHYEMAC0MCLKIN_indelay  :  std_ulogic;
	signal   PHYEMAC0MDIN_indelay  :  std_ulogic;
	signal   PHYEMAC0MIITXCLK_indelay  :  std_ulogic;
	signal   PHYEMAC0PHYAD_indelay  :  std_logic_vector(4 downto 0);
	signal   PHYEMAC0RXBUFERR_indelay  :  std_ulogic;
	signal   PHYEMAC0RXBUFSTATUS_indelay  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC0RXCHARISCOMMA_indelay  :  std_ulogic;
	signal   PHYEMAC0RXCHARISK_indelay  :  std_ulogic;
	signal   PHYEMAC0RXCHECKINGCRC_indelay  :  std_ulogic;
	signal   PHYEMAC0RXCLK_indelay  :  std_ulogic;
	signal   PHYEMAC0RXCLKCORCNT_indelay  :  std_logic_vector(2 downto 0);
	signal   PHYEMAC0RXCOMMADET_indelay  :  std_ulogic;
	signal   PHYEMAC0RXD_indelay  :  std_logic_vector(7 downto 0);
	signal   PHYEMAC0RXDISPERR_indelay  :  std_ulogic;
	signal   PHYEMAC0RXDV_indelay  :  std_ulogic;
	signal   PHYEMAC0RXER_indelay  :  std_ulogic;
	signal   PHYEMAC0RXLOSSOFSYNC_indelay  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC0RXNOTINTABLE_indelay  :  std_ulogic;
	signal   PHYEMAC0RXRUNDISP_indelay  :  std_ulogic;
	signal   PHYEMAC0SIGNALDET_indelay  :  std_ulogic;
	signal   PHYEMAC0TXBUFERR_indelay  :  std_ulogic;
	signal   PHYEMAC1COL_indelay  :  std_ulogic;
	signal   PHYEMAC1CRS_indelay  :  std_ulogic;
	signal   PHYEMAC1GTXCLK_indelay  :  std_ulogic;
	signal   PHYEMAC1MCLKIN_indelay  :  std_ulogic;
	signal   PHYEMAC1MDIN_indelay  :  std_ulogic;
	signal   PHYEMAC1MIITXCLK_indelay  :  std_ulogic;
	signal   PHYEMAC1PHYAD_indelay  :  std_logic_vector(4 downto 0);
	signal   PHYEMAC1RXBUFERR_indelay  :  std_ulogic;
	signal   PHYEMAC1RXBUFSTATUS_indelay  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC1RXCHARISCOMMA_indelay  :  std_ulogic;
	signal   PHYEMAC1RXCHARISK_indelay  :  std_ulogic;
	signal   PHYEMAC1RXCHECKINGCRC_indelay  :  std_ulogic;
	signal   PHYEMAC1RXCLK_indelay  :  std_ulogic;
	signal   PHYEMAC1RXCLKCORCNT_indelay  :  std_logic_vector(2 downto 0);
	signal   PHYEMAC1RXCOMMADET_indelay  :  std_ulogic;
	signal   PHYEMAC1RXD_indelay  :  std_logic_vector(7 downto 0);
	signal   PHYEMAC1RXDISPERR_indelay  :  std_ulogic;
	signal   PHYEMAC1RXDV_indelay  :  std_ulogic;
	signal   PHYEMAC1RXER_indelay  :  std_ulogic;
	signal   PHYEMAC1RXLOSSOFSYNC_indelay  :  std_logic_vector(1 downto 0);
	signal   PHYEMAC1RXNOTINTABLE_indelay  :  std_ulogic;
	signal   PHYEMAC1RXRUNDISP_indelay  :  std_ulogic;
	signal   PHYEMAC1SIGNALDET_indelay  :  std_ulogic;
	signal   PHYEMAC1TXBUFERR_indelay  :  std_ulogic;
	signal   RESET_indelay  :  std_ulogic;
 
 begin 
  
        EMAC0CLIENTRXCLIENTCLKOUT_out <= EMAC0CLIENTRXCLIENTCLKOUT_outdelay after CLK_DELAY;
        EMAC0CLIENTTXCLIENTCLKOUT_out <= EMAC0CLIENTTXCLIENTCLKOUT_outdelay after CLK_DELAY;
        EMAC0PHYMCLKOUT_out <= EMAC0PHYMCLKOUT_outdelay after CLK_DELAY;
        EMAC0PHYTXCLK_out <= EMAC0PHYTXCLK_outdelay after CLK_DELAY;
        EMAC0PHYTXGMIIMIICLKOUT_out <= EMAC0PHYTXGMIIMIICLKOUT_outdelay after CLK_DELAY;
        EMAC1CLIENTRXCLIENTCLKOUT_out <= EMAC1CLIENTRXCLIENTCLKOUT_outdelay after CLK_DELAY;
        EMAC1CLIENTTXCLIENTCLKOUT_out <= EMAC1CLIENTTXCLIENTCLKOUT_outdelay after CLK_DELAY;
        EMAC1PHYMCLKOUT_out <= EMAC1PHYMCLKOUT_outdelay after CLK_DELAY;
        EMAC1PHYTXCLK_out <= EMAC1PHYTXCLK_outdelay after CLK_DELAY;
        EMAC1PHYTXGMIIMIICLKOUT_out <= EMAC1PHYTXGMIIMIICLKOUT_outdelay after CLK_DELAY;

        DCRHOSTDONEIR_out <= DCRHOSTDONEIR_outdelay after OUT_DELAY;
        EMAC0CLIENTANINTERRUPT_out <= EMAC0CLIENTANINTERRUPT_outdelay after OUT_DELAY;
        EMAC0CLIENTRXBADFRAME_out <= EMAC0CLIENTRXBADFRAME_outdelay after OUT_DELAY;
        EMAC0CLIENTRXDVLDMSW_out <= EMAC0CLIENTRXDVLDMSW_outdelay after OUT_DELAY;
        EMAC0CLIENTRXDVLD_out <= EMAC0CLIENTRXDVLD_outdelay after OUT_DELAY;
        EMAC0CLIENTRXD_out <= EMAC0CLIENTRXD_outdelay after OUT_DELAY;
        EMAC0CLIENTRXFRAMEDROP_out <= EMAC0CLIENTRXFRAMEDROP_outdelay after OUT_DELAY;
        EMAC0CLIENTRXGOODFRAME_out <= EMAC0CLIENTRXGOODFRAME_outdelay after OUT_DELAY;
        EMAC0CLIENTRXSTATSBYTEVLD_out <= EMAC0CLIENTRXSTATSBYTEVLD_outdelay after OUT_DELAY;
        EMAC0CLIENTRXSTATSVLD_out <= EMAC0CLIENTRXSTATSVLD_outdelay after OUT_DELAY;
        EMAC0CLIENTRXSTATS_out <= EMAC0CLIENTRXSTATS_outdelay after OUT_DELAY;
        EMAC0CLIENTTXACK_out <= EMAC0CLIENTTXACK_outdelay after OUT_DELAY;
        EMAC0CLIENTTXCOLLISION_out <= EMAC0CLIENTTXCOLLISION_outdelay after OUT_DELAY;
        EMAC0CLIENTTXRETRANSMIT_out <= EMAC0CLIENTTXRETRANSMIT_outdelay after OUT_DELAY;
        EMAC0CLIENTTXSTATSBYTEVLD_out <= EMAC0CLIENTTXSTATSBYTEVLD_outdelay after OUT_DELAY;
        EMAC0CLIENTTXSTATSVLD_out <= EMAC0CLIENTTXSTATSVLD_outdelay after OUT_DELAY;
        EMAC0CLIENTTXSTATS_out <= EMAC0CLIENTTXSTATS_outdelay after OUT_DELAY;
        EMAC0PHYENCOMMAALIGN_out <= EMAC0PHYENCOMMAALIGN_outdelay after OUT_DELAY;
        EMAC0PHYLOOPBACKMSB_out <= EMAC0PHYLOOPBACKMSB_outdelay after OUT_DELAY;
        EMAC0PHYMDOUT_out <= EMAC0PHYMDOUT_outdelay after OUT_DELAY;
        EMAC0PHYMDTRI_out <= EMAC0PHYMDTRI_outdelay after OUT_DELAY;
        EMAC0PHYMGTRXRESET_out <= EMAC0PHYMGTRXRESET_outdelay after OUT_DELAY;
        EMAC0PHYMGTTXRESET_out <= EMAC0PHYMGTTXRESET_outdelay after OUT_DELAY;
        EMAC0PHYPOWERDOWN_out <= EMAC0PHYPOWERDOWN_outdelay after OUT_DELAY;
        EMAC0PHYSYNCACQSTATUS_out <= EMAC0PHYSYNCACQSTATUS_outdelay after OUT_DELAY;
        EMAC0PHYTXCHARDISPMODE_out <= EMAC0PHYTXCHARDISPMODE_outdelay after OUT_DELAY;
        EMAC0PHYTXCHARDISPVAL_out <= EMAC0PHYTXCHARDISPVAL_outdelay after OUT_DELAY;
        EMAC0PHYTXCHARISK_out <= EMAC0PHYTXCHARISK_outdelay after OUT_DELAY;
        EMAC0PHYTXD_out <= EMAC0PHYTXD_outdelay after OUT_DELAY;
        EMAC0PHYTXEN_out <= EMAC0PHYTXEN_outdelay after OUT_DELAY;
        EMAC0PHYTXER_out <= EMAC0PHYTXER_outdelay after OUT_DELAY;
        EMAC0SPEEDIS10100_out <= EMAC0SPEEDIS10100_outdelay after OUT_DELAY;
        EMAC1CLIENTANINTERRUPT_out <= EMAC1CLIENTANINTERRUPT_outdelay after OUT_DELAY;
        EMAC1CLIENTRXBADFRAME_out <= EMAC1CLIENTRXBADFRAME_outdelay after OUT_DELAY;
        EMAC1CLIENTRXDVLDMSW_out <= EMAC1CLIENTRXDVLDMSW_outdelay after OUT_DELAY;
        EMAC1CLIENTRXDVLD_out <= EMAC1CLIENTRXDVLD_outdelay after OUT_DELAY;
        EMAC1CLIENTRXD_out <= EMAC1CLIENTRXD_outdelay after OUT_DELAY;
        EMAC1CLIENTRXFRAMEDROP_out <= EMAC1CLIENTRXFRAMEDROP_outdelay after OUT_DELAY;
        EMAC1CLIENTRXGOODFRAME_out <= EMAC1CLIENTRXGOODFRAME_outdelay after OUT_DELAY;
        EMAC1CLIENTRXSTATSBYTEVLD_out <= EMAC1CLIENTRXSTATSBYTEVLD_outdelay after OUT_DELAY;
        EMAC1CLIENTRXSTATSVLD_out <= EMAC1CLIENTRXSTATSVLD_outdelay after OUT_DELAY;
        EMAC1CLIENTRXSTATS_out <= EMAC1CLIENTRXSTATS_outdelay after OUT_DELAY;
        EMAC1CLIENTTXACK_out <= EMAC1CLIENTTXACK_outdelay after OUT_DELAY;
        EMAC1CLIENTTXCOLLISION_out <= EMAC1CLIENTTXCOLLISION_outdelay after OUT_DELAY;
        EMAC1CLIENTTXRETRANSMIT_out <= EMAC1CLIENTTXRETRANSMIT_outdelay after OUT_DELAY;
        EMAC1CLIENTTXSTATSBYTEVLD_out <= EMAC1CLIENTTXSTATSBYTEVLD_outdelay after OUT_DELAY;
        EMAC1CLIENTTXSTATSVLD_out <= EMAC1CLIENTTXSTATSVLD_outdelay after OUT_DELAY;
        EMAC1CLIENTTXSTATS_out <= EMAC1CLIENTTXSTATS_outdelay after OUT_DELAY;
        EMAC1PHYENCOMMAALIGN_out <= EMAC1PHYENCOMMAALIGN_outdelay after OUT_DELAY;
        EMAC1PHYLOOPBACKMSB_out <= EMAC1PHYLOOPBACKMSB_outdelay after OUT_DELAY;
        EMAC1PHYMDOUT_out <= EMAC1PHYMDOUT_outdelay after OUT_DELAY;
        EMAC1PHYMDTRI_out <= EMAC1PHYMDTRI_outdelay after OUT_DELAY;
        EMAC1PHYMGTRXRESET_out <= EMAC1PHYMGTRXRESET_outdelay after OUT_DELAY;
        EMAC1PHYMGTTXRESET_out <= EMAC1PHYMGTTXRESET_outdelay after OUT_DELAY;
        EMAC1PHYPOWERDOWN_out <= EMAC1PHYPOWERDOWN_outdelay after OUT_DELAY;
        EMAC1PHYSYNCACQSTATUS_out <= EMAC1PHYSYNCACQSTATUS_outdelay after OUT_DELAY;
        EMAC1PHYTXCHARDISPMODE_out <= EMAC1PHYTXCHARDISPMODE_outdelay after OUT_DELAY;
        EMAC1PHYTXCHARDISPVAL_out <= EMAC1PHYTXCHARDISPVAL_outdelay after OUT_DELAY;
        EMAC1PHYTXCHARISK_out <= EMAC1PHYTXCHARISK_outdelay after OUT_DELAY;
        EMAC1PHYTXD_out <= EMAC1PHYTXD_outdelay after OUT_DELAY;
        EMAC1PHYTXEN_out <= EMAC1PHYTXEN_outdelay after OUT_DELAY;
        EMAC1PHYTXER_out <= EMAC1PHYTXER_outdelay after OUT_DELAY;
        EMAC1SPEEDIS10100_out <= EMAC1SPEEDIS10100_outdelay after OUT_DELAY;
        EMACDCRACK_out <= EMACDCRACK_outdelay after OUT_DELAY;
        EMACDCRDBUS_out <= EMACDCRDBUS_outdelay after OUT_DELAY;
        HOSTMIIMRDY_out <= HOSTMIIMRDY_outdelay after OUT_DELAY;
        HOSTRDDATA_out <= HOSTRDDATA_outdelay after OUT_DELAY;

        CLIENTEMAC0RXCLIENTCLKIN_ipd <= CLIENTEMAC0RXCLIENTCLKIN after CLK_DELAY;
        CLIENTEMAC0TXCLIENTCLKIN_ipd <= CLIENTEMAC0TXCLIENTCLKIN after CLK_DELAY;
        CLIENTEMAC1RXCLIENTCLKIN_ipd <= CLIENTEMAC1RXCLIENTCLKIN after CLK_DELAY;
        CLIENTEMAC1TXCLIENTCLKIN_ipd <= CLIENTEMAC1TXCLIENTCLKIN after CLK_DELAY;
        DCREMACCLK_ipd <= DCREMACCLK after CLK_DELAY;
        HOSTCLK_ipd <= HOSTCLK after CLK_DELAY;
        PHYEMAC0GTXCLK_ipd <= PHYEMAC0GTXCLK after CLK_DELAY;
        PHYEMAC0MCLKIN_ipd <= PHYEMAC0MCLKIN after CLK_DELAY;
        PHYEMAC0MIITXCLK_ipd <= PHYEMAC0MIITXCLK after EMAC0MIITXCLK_DELAY;
        PHYEMAC0RXCLK_ipd <= PHYEMAC0RXCLK after CLK_DELAY;
        PHYEMAC0TXGMIIMIICLKIN_ipd <= PHYEMAC0TXGMIIMIICLKIN after CLK_DELAY;
        PHYEMAC1GTXCLK_ipd <= PHYEMAC1GTXCLK after CLK_DELAY;
        PHYEMAC1MCLKIN_ipd <= PHYEMAC1MCLKIN after CLK_DELAY;
        PHYEMAC1MIITXCLK_ipd <= PHYEMAC1MIITXCLK after EMAC1MIITXCLK_DELAY;
        PHYEMAC1RXCLK_ipd <= PHYEMAC1RXCLK after CLK_DELAY;
        PHYEMAC1TXGMIIMIICLKIN_ipd <= PHYEMAC1TXGMIIMIICLKIN after CLK_DELAY;

        CLIENTEMAC0DCMLOCKED_ipd <= CLIENTEMAC0DCMLOCKED after CLK_DELAY;
        CLIENTEMAC0PAUSEREQ_ipd <= CLIENTEMAC0PAUSEREQ after CLK_DELAY;
        CLIENTEMAC0PAUSEVAL_ipd <= CLIENTEMAC0PAUSEVAL after CLK_DELAY;
        CLIENTEMAC0TXDVLDMSW_ipd <= CLIENTEMAC0TXDVLDMSW after CLK_DELAY;
        CLIENTEMAC0TXDVLD_ipd <= CLIENTEMAC0TXDVLD after CLK_DELAY;
        CLIENTEMAC0TXD_ipd <= CLIENTEMAC0TXD after CLK_DELAY;
        CLIENTEMAC0TXFIRSTBYTE_ipd <= CLIENTEMAC0TXFIRSTBYTE after CLK_DELAY;
        CLIENTEMAC0TXIFGDELAY_ipd <= CLIENTEMAC0TXIFGDELAY after CLK_DELAY;
        CLIENTEMAC0TXUNDERRUN_ipd <= CLIENTEMAC0TXUNDERRUN after CLK_DELAY;
        CLIENTEMAC1DCMLOCKED_ipd <= CLIENTEMAC1DCMLOCKED after CLK_DELAY;
        CLIENTEMAC1PAUSEREQ_ipd <= CLIENTEMAC1PAUSEREQ after CLK_DELAY;
        CLIENTEMAC1PAUSEVAL_ipd <= CLIENTEMAC1PAUSEVAL after CLK_DELAY;
        CLIENTEMAC1TXDVLDMSW_ipd <= CLIENTEMAC1TXDVLDMSW after CLK_DELAY;
        CLIENTEMAC1TXDVLD_ipd <= CLIENTEMAC1TXDVLD after CLK_DELAY;
        CLIENTEMAC1TXD_ipd <= CLIENTEMAC1TXD after CLK_DELAY;
        CLIENTEMAC1TXFIRSTBYTE_ipd <= CLIENTEMAC1TXFIRSTBYTE after CLK_DELAY;
        CLIENTEMAC1TXIFGDELAY_ipd <= CLIENTEMAC1TXIFGDELAY after CLK_DELAY;
        CLIENTEMAC1TXUNDERRUN_ipd <= CLIENTEMAC1TXUNDERRUN after CLK_DELAY;
        DCREMACABUS_ipd <= DCREMACABUS after CLK_DELAY;
        DCREMACDBUS_ipd <= DCREMACDBUS after CLK_DELAY;
        DCREMACENABLE_ipd <= DCREMACENABLE after CLK_DELAY;
        DCREMACREAD_ipd <= DCREMACREAD after CLK_DELAY;
        DCREMACWRITE_ipd <= DCREMACWRITE after CLK_DELAY;
        HOSTADDR_ipd <= HOSTADDR after CLK_DELAY;
        HOSTEMAC1SEL_ipd <= HOSTEMAC1SEL after CLK_DELAY;
        HOSTMIIMSEL_ipd <= HOSTMIIMSEL after CLK_DELAY;
        HOSTOPCODE_ipd <= HOSTOPCODE after CLK_DELAY;
        HOSTREQ_ipd <= HOSTREQ after CLK_DELAY;
        HOSTWRDATA_ipd <= HOSTWRDATA after CLK_DELAY;
        PHYEMAC0COL_ipd <= PHYEMAC0COL after CLK_DELAY;
        PHYEMAC0CRS_ipd <= PHYEMAC0CRS after CLK_DELAY;
        PHYEMAC0MDIN_ipd <= PHYEMAC0MDIN after CLK_DELAY;
        PHYEMAC0PHYAD_ipd <= PHYEMAC0PHYAD after CLK_DELAY;
        PHYEMAC0RXBUFERR_ipd <= PHYEMAC0RXBUFERR after CLK_DELAY;
        PHYEMAC0RXBUFSTATUS_ipd <= PHYEMAC0RXBUFSTATUS after CLK_DELAY;
        PHYEMAC0RXCHARISCOMMA_ipd <= PHYEMAC0RXCHARISCOMMA after CLK_DELAY;
        PHYEMAC0RXCHARISK_ipd <= PHYEMAC0RXCHARISK after CLK_DELAY;
        PHYEMAC0RXCHECKINGCRC_ipd <= PHYEMAC0RXCHECKINGCRC after CLK_DELAY;
        PHYEMAC0RXCLKCORCNT_ipd <= PHYEMAC0RXCLKCORCNT after CLK_DELAY;
        PHYEMAC0RXCOMMADET_ipd <= PHYEMAC0RXCOMMADET after CLK_DELAY;
        PHYEMAC0RXDISPERR_ipd <= PHYEMAC0RXDISPERR after CLK_DELAY;
        PHYEMAC0RXDV_ipd <= PHYEMAC0RXDV after CLK_DELAY;
        PHYEMAC0RXD_ipd <= PHYEMAC0RXD after CLK_DELAY;
        PHYEMAC0RXER_ipd <= PHYEMAC0RXER after CLK_DELAY;
        PHYEMAC0RXLOSSOFSYNC_ipd <= PHYEMAC0RXLOSSOFSYNC after CLK_DELAY;
        PHYEMAC0RXNOTINTABLE_ipd <= PHYEMAC0RXNOTINTABLE after CLK_DELAY;
        PHYEMAC0RXRUNDISP_ipd <= PHYEMAC0RXRUNDISP after CLK_DELAY;
        PHYEMAC0SIGNALDET_ipd <= PHYEMAC0SIGNALDET after CLK_DELAY;
        PHYEMAC0TXBUFERR_ipd <= PHYEMAC0TXBUFERR after CLK_DELAY;
        PHYEMAC1COL_ipd <= PHYEMAC1COL after CLK_DELAY;
        PHYEMAC1CRS_ipd <= PHYEMAC1CRS after CLK_DELAY;
        PHYEMAC1MDIN_ipd <= PHYEMAC1MDIN after CLK_DELAY;
        PHYEMAC1PHYAD_ipd <= PHYEMAC1PHYAD after CLK_DELAY;
        PHYEMAC1RXBUFERR_ipd <= PHYEMAC1RXBUFERR after CLK_DELAY;
        PHYEMAC1RXBUFSTATUS_ipd <= PHYEMAC1RXBUFSTATUS after CLK_DELAY;
        PHYEMAC1RXCHARISCOMMA_ipd <= PHYEMAC1RXCHARISCOMMA after CLK_DELAY;
        PHYEMAC1RXCHARISK_ipd <= PHYEMAC1RXCHARISK after CLK_DELAY;
        PHYEMAC1RXCHECKINGCRC_ipd <= PHYEMAC1RXCHECKINGCRC after CLK_DELAY;
        PHYEMAC1RXCLKCORCNT_ipd <= PHYEMAC1RXCLKCORCNT after CLK_DELAY;
        PHYEMAC1RXCOMMADET_ipd <= PHYEMAC1RXCOMMADET after CLK_DELAY;
        PHYEMAC1RXDISPERR_ipd <= PHYEMAC1RXDISPERR after CLK_DELAY;
        PHYEMAC1RXDV_ipd <= PHYEMAC1RXDV after CLK_DELAY;
        PHYEMAC1RXD_ipd <= PHYEMAC1RXD after CLK_DELAY;
        PHYEMAC1RXER_ipd <= PHYEMAC1RXER after CLK_DELAY;
        PHYEMAC1RXLOSSOFSYNC_ipd <= PHYEMAC1RXLOSSOFSYNC after CLK_DELAY;
        PHYEMAC1RXNOTINTABLE_ipd <= PHYEMAC1RXNOTINTABLE after CLK_DELAY;
        PHYEMAC1RXRUNDISP_ipd <= PHYEMAC1RXRUNDISP after CLK_DELAY;
        PHYEMAC1SIGNALDET_ipd <= PHYEMAC1SIGNALDET after CLK_DELAY;
        PHYEMAC1TXBUFERR_ipd <= PHYEMAC1TXBUFERR after CLK_DELAY;
        RESET_ipd <= RESET after CLK_DELAY;

        CLIENTEMAC0RXCLIENTCLKIN_indelay <= CLIENTEMAC0RXCLIENTCLKIN_ipd after CLK_DELAY;
        CLIENTEMAC0TXCLIENTCLKIN_indelay <= CLIENTEMAC0TXCLIENTCLKIN_ipd after CLK_DELAY;
        CLIENTEMAC1RXCLIENTCLKIN_indelay <= CLIENTEMAC1RXCLIENTCLKIN_ipd after CLK_DELAY;
        CLIENTEMAC1TXCLIENTCLKIN_indelay <= CLIENTEMAC1TXCLIENTCLKIN_ipd after CLK_DELAY;
        DCREMACCLK_indelay <= DCREMACCLK_ipd after CLK_DELAY;
        HOSTCLK_indelay <= HOSTCLK_ipd after CLK_DELAY;
        PHYEMAC0GTXCLK_indelay <= PHYEMAC0GTXCLK_ipd after CLK_DELAY;
        PHYEMAC0MCLKIN_indelay <= PHYEMAC0MCLKIN_ipd after CLK_DELAY;
        PHYEMAC0MIITXCLK_indelay <= PHYEMAC0MIITXCLK_ipd after EMAC0MIITXCLK_DELAY;
        PHYEMAC0RXCLK_indelay <= PHYEMAC0RXCLK_ipd after CLK_DELAY;
        PHYEMAC0TXGMIIMIICLKIN_indelay <= PHYEMAC0TXGMIIMIICLKIN_ipd after CLK_DELAY;
        PHYEMAC1GTXCLK_indelay <= PHYEMAC1GTXCLK_ipd after CLK_DELAY;
        PHYEMAC1MCLKIN_indelay <= PHYEMAC1MCLKIN_ipd after CLK_DELAY;
        PHYEMAC1MIITXCLK_indelay <= PHYEMAC1MIITXCLK_ipd after EMAC1MIITXCLK_DELAY;
        PHYEMAC1RXCLK_indelay <= PHYEMAC1RXCLK_ipd after CLK_DELAY;
        PHYEMAC1TXGMIIMIICLKIN_indelay <= PHYEMAC1TXGMIIMIICLKIN_ipd after CLK_DELAY;

        CLIENTEMAC0DCMLOCKED_indelay <= CLIENTEMAC0DCMLOCKED_ipd after IN_DELAY;
        CLIENTEMAC0PAUSEREQ_indelay <= CLIENTEMAC0PAUSEREQ_ipd after IN_DELAY;
        CLIENTEMAC0PAUSEVAL_indelay <= CLIENTEMAC0PAUSEVAL_ipd after IN_DELAY;
        CLIENTEMAC0TXDVLDMSW_indelay <= CLIENTEMAC0TXDVLDMSW_ipd after IN_DELAY;
        CLIENTEMAC0TXDVLD_indelay <= CLIENTEMAC0TXDVLD_ipd after IN_DELAY;
        CLIENTEMAC0TXD_indelay <= CLIENTEMAC0TXD_ipd after IN_DELAY;
        CLIENTEMAC0TXFIRSTBYTE_indelay <= CLIENTEMAC0TXFIRSTBYTE_ipd after IN_DELAY;
        CLIENTEMAC0TXIFGDELAY_indelay <= CLIENTEMAC0TXIFGDELAY_ipd after IN_DELAY;
        CLIENTEMAC0TXUNDERRUN_indelay <= CLIENTEMAC0TXUNDERRUN_ipd after IN_DELAY;
        CLIENTEMAC1DCMLOCKED_indelay <= CLIENTEMAC1DCMLOCKED_ipd after IN_DELAY;
        CLIENTEMAC1PAUSEREQ_indelay <= CLIENTEMAC1PAUSEREQ_ipd after IN_DELAY;
        CLIENTEMAC1PAUSEVAL_indelay <= CLIENTEMAC1PAUSEVAL_ipd after IN_DELAY;
        CLIENTEMAC1TXDVLDMSW_indelay <= CLIENTEMAC1TXDVLDMSW_ipd after IN_DELAY;
        CLIENTEMAC1TXDVLD_indelay <= CLIENTEMAC1TXDVLD_ipd after IN_DELAY;
        CLIENTEMAC1TXD_indelay <= CLIENTEMAC1TXD_ipd after IN_DELAY;
        CLIENTEMAC1TXFIRSTBYTE_indelay <= CLIENTEMAC1TXFIRSTBYTE_ipd after IN_DELAY;
        CLIENTEMAC1TXIFGDELAY_indelay <= CLIENTEMAC1TXIFGDELAY_ipd after IN_DELAY;
        CLIENTEMAC1TXUNDERRUN_indelay <= CLIENTEMAC1TXUNDERRUN_ipd after IN_DELAY;
        DCREMACABUS_indelay <= DCREMACABUS_ipd after IN_DELAY;
        DCREMACDBUS_indelay <= DCREMACDBUS_ipd after IN_DELAY;
        DCREMACENABLE_indelay <= DCREMACENABLE_ipd after IN_DELAY;
        DCREMACREAD_indelay <= DCREMACREAD_ipd after IN_DELAY;
        DCREMACWRITE_indelay <= DCREMACWRITE_ipd after IN_DELAY;
        HOSTADDR_indelay <= HOSTADDR_ipd after IN_DELAY;
        HOSTEMAC1SEL_indelay <= HOSTEMAC1SEL_ipd after IN_DELAY;
        HOSTMIIMSEL_indelay <= HOSTMIIMSEL_ipd after IN_DELAY;
        HOSTOPCODE_indelay <= HOSTOPCODE_ipd after IN_DELAY;
        HOSTREQ_indelay <= HOSTREQ_ipd after IN_DELAY;
        HOSTWRDATA_indelay <= HOSTWRDATA_ipd after IN_DELAY;
        PHYEMAC0COL_indelay <= PHYEMAC0COL_ipd after IN_DELAY;
        PHYEMAC0CRS_indelay <= PHYEMAC0CRS_ipd after IN_DELAY;
        PHYEMAC0MDIN_indelay <= PHYEMAC0MDIN_ipd after IN_DELAY;
        PHYEMAC0PHYAD_indelay <= PHYEMAC0PHYAD_ipd after IN_DELAY;
        PHYEMAC0RXBUFERR_indelay <= PHYEMAC0RXBUFERR_ipd after IN_DELAY;
        PHYEMAC0RXBUFSTATUS_indelay <= PHYEMAC0RXBUFSTATUS_ipd after IN_DELAY;
        PHYEMAC0RXCHARISCOMMA_indelay <= PHYEMAC0RXCHARISCOMMA_ipd after IN_DELAY;
        PHYEMAC0RXCHARISK_indelay <= PHYEMAC0RXCHARISK_ipd after IN_DELAY;
        PHYEMAC0RXCHECKINGCRC_indelay <= PHYEMAC0RXCHECKINGCRC_ipd after IN_DELAY;
        PHYEMAC0RXCLKCORCNT_indelay <= PHYEMAC0RXCLKCORCNT_ipd after IN_DELAY;
        PHYEMAC0RXCOMMADET_indelay <= PHYEMAC0RXCOMMADET_ipd after IN_DELAY;
        PHYEMAC0RXDISPERR_indelay <= PHYEMAC0RXDISPERR_ipd after IN_DELAY;
        PHYEMAC0RXDV_indelay <= PHYEMAC0RXDV_ipd after IN_DELAY;
        PHYEMAC0RXD_indelay <= PHYEMAC0RXD_ipd after IN_DELAY;
        PHYEMAC0RXER_indelay <= PHYEMAC0RXER_ipd after IN_DELAY;
        PHYEMAC0RXLOSSOFSYNC_indelay <= PHYEMAC0RXLOSSOFSYNC_ipd after IN_DELAY;
        PHYEMAC0RXNOTINTABLE_indelay <= PHYEMAC0RXNOTINTABLE_ipd after IN_DELAY;
        PHYEMAC0RXRUNDISP_indelay <= PHYEMAC0RXRUNDISP_ipd after IN_DELAY;
        PHYEMAC0SIGNALDET_indelay <= PHYEMAC0SIGNALDET_ipd after IN_DELAY;
        PHYEMAC0TXBUFERR_indelay <= PHYEMAC0TXBUFERR_ipd after IN_DELAY;
        PHYEMAC1COL_indelay <= PHYEMAC1COL_ipd after IN_DELAY;
        PHYEMAC1CRS_indelay <= PHYEMAC1CRS_ipd after IN_DELAY;
        PHYEMAC1MDIN_indelay <= PHYEMAC1MDIN_ipd after IN_DELAY;
        PHYEMAC1PHYAD_indelay <= PHYEMAC1PHYAD_ipd after IN_DELAY;
        PHYEMAC1RXBUFERR_indelay <= PHYEMAC1RXBUFERR_ipd after IN_DELAY;
        PHYEMAC1RXBUFSTATUS_indelay <= PHYEMAC1RXBUFSTATUS_ipd after IN_DELAY;
        PHYEMAC1RXCHARISCOMMA_indelay <= PHYEMAC1RXCHARISCOMMA_ipd after IN_DELAY;
        PHYEMAC1RXCHARISK_indelay <= PHYEMAC1RXCHARISK_ipd after IN_DELAY;
        PHYEMAC1RXCHECKINGCRC_indelay <= PHYEMAC1RXCHECKINGCRC_ipd after IN_DELAY;
        PHYEMAC1RXCLKCORCNT_indelay <= PHYEMAC1RXCLKCORCNT_ipd after IN_DELAY;
        PHYEMAC1RXCOMMADET_indelay <= PHYEMAC1RXCOMMADET_ipd after IN_DELAY;
        PHYEMAC1RXDISPERR_indelay <= PHYEMAC1RXDISPERR_ipd after IN_DELAY;
        PHYEMAC1RXDV_indelay <= PHYEMAC1RXDV_ipd after IN_DELAY;
        PHYEMAC1RXD_indelay <= PHYEMAC1RXD_ipd after IN_DELAY;
        PHYEMAC1RXER_indelay <= PHYEMAC1RXER_ipd after IN_DELAY;
        PHYEMAC1RXLOSSOFSYNC_indelay <= PHYEMAC1RXLOSSOFSYNC_ipd after IN_DELAY;
        PHYEMAC1RXNOTINTABLE_indelay <= PHYEMAC1RXNOTINTABLE_ipd after IN_DELAY;
        PHYEMAC1RXRUNDISP_indelay <= PHYEMAC1RXRUNDISP_ipd after IN_DELAY;
        PHYEMAC1SIGNALDET_indelay <= PHYEMAC1SIGNALDET_ipd after IN_DELAY;
        PHYEMAC1TXBUFERR_indelay <= PHYEMAC1TXBUFERR_ipd after IN_DELAY;
        RESET_indelay <= RESET_ipd after IN_DELAY;

	temac_swift_bw_1 : TEMAC_SWIFT
	port map (
	EMAC0_1000BASEX_ENABLE  =>  EMAC0_1000BASEX_ENABLE_BINARY,
	EMAC0_ADDRFILTER_ENABLE  =>  EMAC0_ADDRFILTER_ENABLE_BINARY,
	EMAC0_BYTEPHY  =>  EMAC0_BYTEPHY_BINARY,
	EMAC0_CONFIGVEC_79  =>  EMAC0_CONFIGVEC_79_BINARY,
	EMAC0_DCRBASEADDR  =>  EMAC0_DCRBASEADDR_BINARY,
	EMAC0_GTLOOPBACK  =>  EMAC0_GTLOOPBACK_BINARY,
	EMAC0_HOST_ENABLE  =>  EMAC0_HOST_ENABLE_BINARY,
	EMAC0_LINKTIMERVAL  =>  EMAC0_LINKTIMERVAL_BINARY,
	EMAC0_LTCHECK_DISABLE  =>  EMAC0_LTCHECK_DISABLE_BINARY,
	EMAC0_MDIO_ENABLE  =>  EMAC0_MDIO_ENABLE_BINARY,
	EMAC0_PAUSEADDR  =>  EMAC0_PAUSEADDR_BINARY,
	EMAC0_PHYINITAUTONEG_ENABLE  =>  EMAC0_PHYINITAUTONEG_ENABLE_BINARY,
	EMAC0_PHYISOLATE  =>  EMAC0_PHYISOLATE_BINARY,
	EMAC0_PHYLOOPBACKMSB  =>  EMAC0_PHYLOOPBACKMSB_BINARY,
	EMAC0_PHYPOWERDOWN  =>  EMAC0_PHYPOWERDOWN_BINARY,
	EMAC0_PHYRESET  =>  EMAC0_PHYRESET_BINARY,
	EMAC0_RGMII_ENABLE  =>  EMAC0_RGMII_ENABLE_BINARY,
	EMAC0_RX16BITCLIENT_ENABLE  =>  EMAC0_RX16BITCLIENT_ENABLE_BINARY,
	EMAC0_RXFLOWCTRL_ENABLE  =>  EMAC0_RXFLOWCTRL_ENABLE_BINARY,
	EMAC0_RXHALFDUPLEX  =>  EMAC0_RXHALFDUPLEX_BINARY,
	EMAC0_RXINBANDFCS_ENABLE  =>  EMAC0_RXINBANDFCS_ENABLE_BINARY,
	EMAC0_RXJUMBOFRAME_ENABLE  =>  EMAC0_RXJUMBOFRAME_ENABLE_BINARY,
	EMAC0_RXRESET  =>  EMAC0_RXRESET_BINARY,
	EMAC0_RXVLAN_ENABLE  =>  EMAC0_RXVLAN_ENABLE_BINARY,
	EMAC0_RX_ENABLE  =>  EMAC0_RX_ENABLE_BINARY,
	EMAC0_SGMII_ENABLE  =>  EMAC0_SGMII_ENABLE_BINARY,
	EMAC0_SPEED_LSB  =>  EMAC0_SPEED_LSB_BINARY,
	EMAC0_SPEED_MSB  =>  EMAC0_SPEED_MSB_BINARY,
	EMAC0_TX16BITCLIENT_ENABLE  =>  EMAC0_TX16BITCLIENT_ENABLE_BINARY,
	EMAC0_TXFLOWCTRL_ENABLE  =>  EMAC0_TXFLOWCTRL_ENABLE_BINARY,
	EMAC0_TXHALFDUPLEX  =>  EMAC0_TXHALFDUPLEX_BINARY,
	EMAC0_TXIFGADJUST_ENABLE  =>  EMAC0_TXIFGADJUST_ENABLE_BINARY,
	EMAC0_TXINBANDFCS_ENABLE  =>  EMAC0_TXINBANDFCS_ENABLE_BINARY,
	EMAC0_TXJUMBOFRAME_ENABLE  =>  EMAC0_TXJUMBOFRAME_ENABLE_BINARY,
	EMAC0_TXRESET  =>  EMAC0_TXRESET_BINARY,
	EMAC0_TXVLAN_ENABLE  =>  EMAC0_TXVLAN_ENABLE_BINARY,
	EMAC0_TX_ENABLE  =>  EMAC0_TX_ENABLE_BINARY,
	EMAC0_UNICASTADDR  =>  EMAC0_UNICASTADDR_BINARY,
	EMAC0_UNIDIRECTION_ENABLE  =>  EMAC0_UNIDIRECTION_ENABLE_BINARY,
	EMAC0_USECLKEN  =>  EMAC0_USECLKEN_BINARY,
	EMAC1_1000BASEX_ENABLE  =>  EMAC1_1000BASEX_ENABLE_BINARY,
	EMAC1_ADDRFILTER_ENABLE  =>  EMAC1_ADDRFILTER_ENABLE_BINARY,
	EMAC1_BYTEPHY  =>  EMAC1_BYTEPHY_BINARY,
	EMAC1_CONFIGVEC_79  =>  EMAC1_CONFIGVEC_79_BINARY,
	EMAC1_DCRBASEADDR  =>  EMAC1_DCRBASEADDR_BINARY,
	EMAC1_GTLOOPBACK  =>  EMAC1_GTLOOPBACK_BINARY,
	EMAC1_HOST_ENABLE  =>  EMAC1_HOST_ENABLE_BINARY,
	EMAC1_LINKTIMERVAL  =>  EMAC1_LINKTIMERVAL_BINARY,
	EMAC1_LTCHECK_DISABLE  =>  EMAC1_LTCHECK_DISABLE_BINARY,
	EMAC1_MDIO_ENABLE  =>  EMAC1_MDIO_ENABLE_BINARY,
	EMAC1_PAUSEADDR  =>  EMAC1_PAUSEADDR_BINARY,
	EMAC1_PHYINITAUTONEG_ENABLE  =>  EMAC1_PHYINITAUTONEG_ENABLE_BINARY,
	EMAC1_PHYISOLATE  =>  EMAC1_PHYISOLATE_BINARY,
	EMAC1_PHYLOOPBACKMSB  =>  EMAC1_PHYLOOPBACKMSB_BINARY,
	EMAC1_PHYPOWERDOWN  =>  EMAC1_PHYPOWERDOWN_BINARY,
	EMAC1_PHYRESET  =>  EMAC1_PHYRESET_BINARY,
	EMAC1_RGMII_ENABLE  =>  EMAC1_RGMII_ENABLE_BINARY,
	EMAC1_RX16BITCLIENT_ENABLE  =>  EMAC1_RX16BITCLIENT_ENABLE_BINARY,
	EMAC1_RXFLOWCTRL_ENABLE  =>  EMAC1_RXFLOWCTRL_ENABLE_BINARY,
	EMAC1_RXHALFDUPLEX  =>  EMAC1_RXHALFDUPLEX_BINARY,
	EMAC1_RXINBANDFCS_ENABLE  =>  EMAC1_RXINBANDFCS_ENABLE_BINARY,
	EMAC1_RXJUMBOFRAME_ENABLE  =>  EMAC1_RXJUMBOFRAME_ENABLE_BINARY,
	EMAC1_RXRESET  =>  EMAC1_RXRESET_BINARY,
	EMAC1_RXVLAN_ENABLE  =>  EMAC1_RXVLAN_ENABLE_BINARY,
	EMAC1_RX_ENABLE  =>  EMAC1_RX_ENABLE_BINARY,
	EMAC1_SGMII_ENABLE  =>  EMAC1_SGMII_ENABLE_BINARY,
	EMAC1_SPEED_LSB  =>  EMAC1_SPEED_LSB_BINARY,
	EMAC1_SPEED_MSB  =>  EMAC1_SPEED_MSB_BINARY,
	EMAC1_TX16BITCLIENT_ENABLE  =>  EMAC1_TX16BITCLIENT_ENABLE_BINARY,
	EMAC1_TXFLOWCTRL_ENABLE  =>  EMAC1_TXFLOWCTRL_ENABLE_BINARY,
	EMAC1_TXHALFDUPLEX  =>  EMAC1_TXHALFDUPLEX_BINARY,
	EMAC1_TXIFGADJUST_ENABLE  =>  EMAC1_TXIFGADJUST_ENABLE_BINARY,
	EMAC1_TXINBANDFCS_ENABLE  =>  EMAC1_TXINBANDFCS_ENABLE_BINARY,
	EMAC1_TXJUMBOFRAME_ENABLE  =>  EMAC1_TXJUMBOFRAME_ENABLE_BINARY,
	EMAC1_TXRESET  =>  EMAC1_TXRESET_BINARY,
	EMAC1_TXVLAN_ENABLE  =>  EMAC1_TXVLAN_ENABLE_BINARY,
	EMAC1_TX_ENABLE  =>  EMAC1_TX_ENABLE_BINARY,
	EMAC1_UNICASTADDR  =>  EMAC1_UNICASTADDR_BINARY,
	EMAC1_UNIDIRECTION_ENABLE  =>  EMAC1_UNIDIRECTION_ENABLE_BINARY,
	EMAC1_USECLKEN  =>  EMAC1_USECLKEN_BINARY,

	DCRHOSTDONEIR  =>  DCRHOSTDONEIR_outdelay,
	EMAC0CLIENTANINTERRUPT  =>  EMAC0CLIENTANINTERRUPT_outdelay,
	EMAC0CLIENTRXBADFRAME  =>  EMAC0CLIENTRXBADFRAME_outdelay,
	EMAC0CLIENTRXCLIENTCLKOUT  =>  EMAC0CLIENTRXCLIENTCLKOUT_outdelay,
	EMAC0CLIENTRXD  =>  EMAC0CLIENTRXD_outdelay,
	EMAC0CLIENTRXDVLD  =>  EMAC0CLIENTRXDVLD_outdelay,
	EMAC0CLIENTRXDVLDMSW  =>  EMAC0CLIENTRXDVLDMSW_outdelay,
	EMAC0CLIENTRXFRAMEDROP  =>  EMAC0CLIENTRXFRAMEDROP_outdelay,
	EMAC0CLIENTRXGOODFRAME  =>  EMAC0CLIENTRXGOODFRAME_outdelay,
	EMAC0CLIENTRXSTATS  =>  EMAC0CLIENTRXSTATS_outdelay,
	EMAC0CLIENTRXSTATSBYTEVLD  =>  EMAC0CLIENTRXSTATSBYTEVLD_outdelay,
	EMAC0CLIENTRXSTATSVLD  =>  EMAC0CLIENTRXSTATSVLD_outdelay,
	EMAC0CLIENTTXACK  =>  EMAC0CLIENTTXACK_outdelay,
	EMAC0CLIENTTXCLIENTCLKOUT  =>  EMAC0CLIENTTXCLIENTCLKOUT_outdelay,
	EMAC0CLIENTTXCOLLISION  =>  EMAC0CLIENTTXCOLLISION_outdelay,
	EMAC0CLIENTTXRETRANSMIT  =>  EMAC0CLIENTTXRETRANSMIT_outdelay,
	EMAC0CLIENTTXSTATS  =>  EMAC0CLIENTTXSTATS_outdelay,
	EMAC0CLIENTTXSTATSBYTEVLD  =>  EMAC0CLIENTTXSTATSBYTEVLD_outdelay,
	EMAC0CLIENTTXSTATSVLD  =>  EMAC0CLIENTTXSTATSVLD_outdelay,
	EMAC0PHYENCOMMAALIGN  =>  EMAC0PHYENCOMMAALIGN_outdelay,
	EMAC0PHYLOOPBACKMSB  =>  EMAC0PHYLOOPBACKMSB_outdelay,
	EMAC0PHYMCLKOUT  =>  EMAC0PHYMCLKOUT_outdelay,
	EMAC0PHYMDOUT  =>  EMAC0PHYMDOUT_outdelay,
	EMAC0PHYMDTRI  =>  EMAC0PHYMDTRI_outdelay,
	EMAC0PHYMGTRXRESET  =>  EMAC0PHYMGTRXRESET_outdelay,
	EMAC0PHYMGTTXRESET  =>  EMAC0PHYMGTTXRESET_outdelay,
	EMAC0PHYPOWERDOWN  =>  EMAC0PHYPOWERDOWN_outdelay,
	EMAC0PHYSYNCACQSTATUS  =>  EMAC0PHYSYNCACQSTATUS_outdelay,
	EMAC0PHYTXCHARDISPMODE  =>  EMAC0PHYTXCHARDISPMODE_outdelay,
	EMAC0PHYTXCHARDISPVAL  =>  EMAC0PHYTXCHARDISPVAL_outdelay,
	EMAC0PHYTXCHARISK  =>  EMAC0PHYTXCHARISK_outdelay,
	EMAC0PHYTXCLK  =>  EMAC0PHYTXCLK_outdelay,
	EMAC0PHYTXD  =>  EMAC0PHYTXD_outdelay,
	EMAC0PHYTXEN  =>  EMAC0PHYTXEN_outdelay,
	EMAC0PHYTXER  =>  EMAC0PHYTXER_outdelay,
	EMAC0PHYTXGMIIMIICLKOUT  =>  EMAC0PHYTXGMIIMIICLKOUT_outdelay,
	EMAC0SPEEDIS10100  =>  EMAC0SPEEDIS10100_outdelay,
	EMAC1CLIENTANINTERRUPT  =>  EMAC1CLIENTANINTERRUPT_outdelay,
	EMAC1CLIENTRXBADFRAME  =>  EMAC1CLIENTRXBADFRAME_outdelay,
	EMAC1CLIENTRXCLIENTCLKOUT  =>  EMAC1CLIENTRXCLIENTCLKOUT_outdelay,
	EMAC1CLIENTRXD  =>  EMAC1CLIENTRXD_outdelay,
	EMAC1CLIENTRXDVLD  =>  EMAC1CLIENTRXDVLD_outdelay,
	EMAC1CLIENTRXDVLDMSW  =>  EMAC1CLIENTRXDVLDMSW_outdelay,
	EMAC1CLIENTRXFRAMEDROP  =>  EMAC1CLIENTRXFRAMEDROP_outdelay,
	EMAC1CLIENTRXGOODFRAME  =>  EMAC1CLIENTRXGOODFRAME_outdelay,
	EMAC1CLIENTRXSTATS  =>  EMAC1CLIENTRXSTATS_outdelay,
	EMAC1CLIENTRXSTATSBYTEVLD  =>  EMAC1CLIENTRXSTATSBYTEVLD_outdelay,
	EMAC1CLIENTRXSTATSVLD  =>  EMAC1CLIENTRXSTATSVLD_outdelay,
	EMAC1CLIENTTXACK  =>  EMAC1CLIENTTXACK_outdelay,
	EMAC1CLIENTTXCLIENTCLKOUT  =>  EMAC1CLIENTTXCLIENTCLKOUT_outdelay,
	EMAC1CLIENTTXCOLLISION  =>  EMAC1CLIENTTXCOLLISION_outdelay,
	EMAC1CLIENTTXRETRANSMIT  =>  EMAC1CLIENTTXRETRANSMIT_outdelay,
	EMAC1CLIENTTXSTATS  =>  EMAC1CLIENTTXSTATS_outdelay,
	EMAC1CLIENTTXSTATSBYTEVLD  =>  EMAC1CLIENTTXSTATSBYTEVLD_outdelay,
	EMAC1CLIENTTXSTATSVLD  =>  EMAC1CLIENTTXSTATSVLD_outdelay,
	EMAC1PHYENCOMMAALIGN  =>  EMAC1PHYENCOMMAALIGN_outdelay,
	EMAC1PHYLOOPBACKMSB  =>  EMAC1PHYLOOPBACKMSB_outdelay,
	EMAC1PHYMCLKOUT  =>  EMAC1PHYMCLKOUT_outdelay,
	EMAC1PHYMDOUT  =>  EMAC1PHYMDOUT_outdelay,
	EMAC1PHYMDTRI  =>  EMAC1PHYMDTRI_outdelay,
	EMAC1PHYMGTRXRESET  =>  EMAC1PHYMGTRXRESET_outdelay,
	EMAC1PHYMGTTXRESET  =>  EMAC1PHYMGTTXRESET_outdelay,
	EMAC1PHYPOWERDOWN  =>  EMAC1PHYPOWERDOWN_outdelay,
	EMAC1PHYSYNCACQSTATUS  =>  EMAC1PHYSYNCACQSTATUS_outdelay,
	EMAC1PHYTXCHARDISPMODE  =>  EMAC1PHYTXCHARDISPMODE_outdelay,
	EMAC1PHYTXCHARDISPVAL  =>  EMAC1PHYTXCHARDISPVAL_outdelay,
	EMAC1PHYTXCHARISK  =>  EMAC1PHYTXCHARISK_outdelay,
	EMAC1PHYTXCLK  =>  EMAC1PHYTXCLK_outdelay,
	EMAC1PHYTXD  =>  EMAC1PHYTXD_outdelay,
	EMAC1PHYTXEN  =>  EMAC1PHYTXEN_outdelay,
	EMAC1PHYTXER  =>  EMAC1PHYTXER_outdelay,
	EMAC1PHYTXGMIIMIICLKOUT  =>  EMAC1PHYTXGMIIMIICLKOUT_outdelay,
	EMAC1SPEEDIS10100  =>  EMAC1SPEEDIS10100_outdelay,
	EMACDCRACK  =>  EMACDCRACK_outdelay,
	EMACDCRDBUS  =>  EMACDCRDBUS_outdelay,
	HOSTMIIMRDY  =>  HOSTMIIMRDY_outdelay,
	HOSTRDDATA  =>  HOSTRDDATA_outdelay,        
        
	CLIENTEMAC0DCMLOCKED  =>  CLIENTEMAC0DCMLOCKED_indelay,
	CLIENTEMAC0PAUSEREQ  =>  CLIENTEMAC0PAUSEREQ_indelay,
	CLIENTEMAC0PAUSEVAL  =>  CLIENTEMAC0PAUSEVAL_indelay,
	CLIENTEMAC0RXCLIENTCLKIN  =>  CLIENTEMAC0RXCLIENTCLKIN_indelay,
	CLIENTEMAC0TXCLIENTCLKIN  =>  CLIENTEMAC0TXCLIENTCLKIN_indelay,
	CLIENTEMAC0TXD  =>  CLIENTEMAC0TXD_indelay,
	CLIENTEMAC0TXDVLD  =>  CLIENTEMAC0TXDVLD_indelay,
	CLIENTEMAC0TXDVLDMSW  =>  CLIENTEMAC0TXDVLDMSW_indelay,
	CLIENTEMAC0TXFIRSTBYTE  =>  CLIENTEMAC0TXFIRSTBYTE_indelay,
	CLIENTEMAC0TXIFGDELAY  =>  CLIENTEMAC0TXIFGDELAY_indelay,
	CLIENTEMAC0TXUNDERRUN  =>  CLIENTEMAC0TXUNDERRUN_indelay,
	CLIENTEMAC1DCMLOCKED  =>  CLIENTEMAC1DCMLOCKED_indelay,
	CLIENTEMAC1PAUSEREQ  =>  CLIENTEMAC1PAUSEREQ_indelay,
	CLIENTEMAC1PAUSEVAL  =>  CLIENTEMAC1PAUSEVAL_indelay,
	CLIENTEMAC1RXCLIENTCLKIN  =>  CLIENTEMAC1RXCLIENTCLKIN_indelay,
	CLIENTEMAC1TXCLIENTCLKIN  =>  CLIENTEMAC1TXCLIENTCLKIN_indelay,
	CLIENTEMAC1TXD  =>  CLIENTEMAC1TXD_indelay,
	CLIENTEMAC1TXDVLD  =>  CLIENTEMAC1TXDVLD_indelay,
	CLIENTEMAC1TXDVLDMSW  =>  CLIENTEMAC1TXDVLDMSW_indelay,
	CLIENTEMAC1TXFIRSTBYTE  =>  CLIENTEMAC1TXFIRSTBYTE_indelay,
	CLIENTEMAC1TXIFGDELAY  =>  CLIENTEMAC1TXIFGDELAY_indelay,
	CLIENTEMAC1TXUNDERRUN  =>  CLIENTEMAC1TXUNDERRUN_indelay,
	DCREMACABUS  =>  DCREMACABUS_indelay,
	DCREMACCLK  =>  DCREMACCLK_indelay,
	DCREMACDBUS  =>  DCREMACDBUS_indelay,
	DCREMACENABLE  =>  DCREMACENABLE_indelay,
	DCREMACREAD  =>  DCREMACREAD_indelay,
	DCREMACWRITE  =>  DCREMACWRITE_indelay,
	HOSTADDR  =>  HOSTADDR_indelay,
	HOSTCLK  =>  HOSTCLK_indelay,
	HOSTEMAC1SEL  =>  HOSTEMAC1SEL_indelay,
	HOSTMIIMSEL  =>  HOSTMIIMSEL_indelay,
	HOSTOPCODE  =>  HOSTOPCODE_indelay,
	HOSTREQ  =>  HOSTREQ_indelay,
	HOSTWRDATA  =>  HOSTWRDATA_indelay,
	PHYEMAC0COL  =>  PHYEMAC0COL_indelay,
	PHYEMAC0CRS  =>  PHYEMAC0CRS_indelay,
	PHYEMAC0GTXCLK  =>  PHYEMAC0GTXCLK_indelay,
	PHYEMAC0MCLKIN  =>  PHYEMAC0MCLKIN_indelay,
	PHYEMAC0MDIN  =>  PHYEMAC0MDIN_indelay,
	PHYEMAC0MIITXCLK  =>  PHYEMAC0MIITXCLK_indelay,
	PHYEMAC0PHYAD  =>  PHYEMAC0PHYAD_indelay,
	PHYEMAC0RXBUFERR  =>  PHYEMAC0RXBUFERR_indelay,
	PHYEMAC0RXBUFSTATUS  =>  PHYEMAC0RXBUFSTATUS_indelay,
	PHYEMAC0RXCHARISCOMMA  =>  PHYEMAC0RXCHARISCOMMA_indelay,
	PHYEMAC0RXCHARISK  =>  PHYEMAC0RXCHARISK_indelay,
	PHYEMAC0RXCHECKINGCRC  =>  PHYEMAC0RXCHECKINGCRC_indelay,
	PHYEMAC0RXCLK  =>  PHYEMAC0RXCLK_indelay,
	PHYEMAC0RXCLKCORCNT  =>  PHYEMAC0RXCLKCORCNT_indelay,
	PHYEMAC0RXCOMMADET  =>  PHYEMAC0RXCOMMADET_indelay,
	PHYEMAC0RXD  =>  PHYEMAC0RXD_indelay,
	PHYEMAC0RXDISPERR  =>  PHYEMAC0RXDISPERR_indelay,
	PHYEMAC0RXDV  =>  PHYEMAC0RXDV_indelay,
	PHYEMAC0RXER  =>  PHYEMAC0RXER_indelay,
	PHYEMAC0RXLOSSOFSYNC  =>  PHYEMAC0RXLOSSOFSYNC_indelay,
	PHYEMAC0RXNOTINTABLE  =>  PHYEMAC0RXNOTINTABLE_indelay,
	PHYEMAC0RXRUNDISP  =>  PHYEMAC0RXRUNDISP_indelay,
	PHYEMAC0SIGNALDET  =>  PHYEMAC0SIGNALDET_indelay,
	PHYEMAC0TXBUFERR  =>  PHYEMAC0TXBUFERR_indelay,
	PHYEMAC0TXGMIIMIICLKIN  =>  PHYEMAC0TXGMIIMIICLKIN_indelay,
	PHYEMAC1COL  =>  PHYEMAC1COL_indelay,
	PHYEMAC1CRS  =>  PHYEMAC1CRS_indelay,
	PHYEMAC1GTXCLK  =>  PHYEMAC1GTXCLK_indelay,
	PHYEMAC1MCLKIN  =>  PHYEMAC1MCLKIN_indelay,
	PHYEMAC1MDIN  =>  PHYEMAC1MDIN_indelay,
	PHYEMAC1MIITXCLK  =>  PHYEMAC1MIITXCLK_indelay,
	PHYEMAC1PHYAD  =>  PHYEMAC1PHYAD_indelay,
	PHYEMAC1RXBUFERR  =>  PHYEMAC1RXBUFERR_indelay,
	PHYEMAC1RXBUFSTATUS  =>  PHYEMAC1RXBUFSTATUS_indelay,
	PHYEMAC1RXCHARISCOMMA  =>  PHYEMAC1RXCHARISCOMMA_indelay,
	PHYEMAC1RXCHARISK  =>  PHYEMAC1RXCHARISK_indelay,
	PHYEMAC1RXCHECKINGCRC  =>  PHYEMAC1RXCHECKINGCRC_indelay,
	PHYEMAC1RXCLK  =>  PHYEMAC1RXCLK_indelay,
	PHYEMAC1RXCLKCORCNT  =>  PHYEMAC1RXCLKCORCNT_indelay,
	PHYEMAC1RXCOMMADET  =>  PHYEMAC1RXCOMMADET_indelay,
	PHYEMAC1RXD  =>  PHYEMAC1RXD_indelay,
	PHYEMAC1RXDISPERR  =>  PHYEMAC1RXDISPERR_indelay,
	PHYEMAC1RXDV  =>  PHYEMAC1RXDV_indelay,
	PHYEMAC1RXER  =>  PHYEMAC1RXER_indelay,
	PHYEMAC1RXLOSSOFSYNC  =>  PHYEMAC1RXLOSSOFSYNC_indelay,
	PHYEMAC1RXNOTINTABLE  =>  PHYEMAC1RXNOTINTABLE_indelay,
	PHYEMAC1RXRUNDISP  =>  PHYEMAC1RXRUNDISP_indelay,
	PHYEMAC1SIGNALDET  =>  PHYEMAC1SIGNALDET_indelay,
	PHYEMAC1TXBUFERR  =>  PHYEMAC1TXBUFERR_indelay,
	PHYEMAC1TXGMIIMIICLKIN  =>  PHYEMAC1TXGMIIMIICLKIN_indelay,
	RESET  =>  RESET_indelay
	);

	INIPROC : process
	begin
       case EMAC0_RXHALFDUPLEX is
           when FALSE   =>  EMAC0_RXHALFDUPLEX_BINARY <= '0';
           when TRUE    =>  EMAC0_RXHALFDUPLEX_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RXHALFDUPLEX is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RXVLAN_ENABLE is
           when FALSE   =>  EMAC0_RXVLAN_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_RXVLAN_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RXVLAN_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RX_ENABLE is
           when FALSE   =>  EMAC0_RX_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_RX_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RX_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RXINBANDFCS_ENABLE is
           when FALSE   =>  EMAC0_RXINBANDFCS_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_RXINBANDFCS_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RXINBANDFCS_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RXJUMBOFRAME_ENABLE is
           when FALSE   =>  EMAC0_RXJUMBOFRAME_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_RXJUMBOFRAME_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RXJUMBOFRAME_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RXRESET is
           when FALSE   =>  EMAC0_RXRESET_BINARY <= '0';
           when TRUE    =>  EMAC0_RXRESET_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RXRESET is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TXIFGADJUST_ENABLE is
           when FALSE   =>  EMAC0_TXIFGADJUST_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_TXIFGADJUST_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TXIFGADJUST_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TXHALFDUPLEX is
           when FALSE   =>  EMAC0_TXHALFDUPLEX_BINARY <= '0';
           when TRUE    =>  EMAC0_TXHALFDUPLEX_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TXHALFDUPLEX is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TXVLAN_ENABLE is
           when FALSE   =>  EMAC0_TXVLAN_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_TXVLAN_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TXVLAN_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TX_ENABLE is
           when FALSE   =>  EMAC0_TX_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_TX_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TX_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TXINBANDFCS_ENABLE is
           when FALSE   =>  EMAC0_TXINBANDFCS_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_TXINBANDFCS_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TXINBANDFCS_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TXJUMBOFRAME_ENABLE is
           when FALSE   =>  EMAC0_TXJUMBOFRAME_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_TXJUMBOFRAME_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TXJUMBOFRAME_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TXRESET is
           when FALSE   =>  EMAC0_TXRESET_BINARY <= '0';
           when TRUE    =>  EMAC0_TXRESET_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TXRESET is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TXFLOWCTRL_ENABLE is
           when FALSE   =>  EMAC0_TXFLOWCTRL_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_TXFLOWCTRL_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TXFLOWCTRL_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RXFLOWCTRL_ENABLE is
           when FALSE   =>  EMAC0_RXFLOWCTRL_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_RXFLOWCTRL_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RXFLOWCTRL_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_LTCHECK_DISABLE is
           when FALSE   =>  EMAC0_LTCHECK_DISABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_LTCHECK_DISABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_LTCHECK_DISABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_ADDRFILTER_ENABLE is
           when FALSE   =>  EMAC0_ADDRFILTER_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_ADDRFILTER_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_ADDRFILTER_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RX16BITCLIENT_ENABLE is
           when FALSE   =>  EMAC0_RX16BITCLIENT_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_RX16BITCLIENT_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RX16BITCLIENT_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_TX16BITCLIENT_ENABLE is
           when FALSE   =>  EMAC0_TX16BITCLIENT_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_TX16BITCLIENT_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_TX16BITCLIENT_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_HOST_ENABLE is
           when FALSE   =>  EMAC0_HOST_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_HOST_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_HOST_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_1000BASEX_ENABLE is
           when FALSE   =>  EMAC0_1000BASEX_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_1000BASEX_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_1000BASEX_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_SGMII_ENABLE is
           when FALSE   =>  EMAC0_SGMII_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_SGMII_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_SGMII_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_RGMII_ENABLE is
           when FALSE   =>  EMAC0_RGMII_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_RGMII_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_RGMII_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_SPEED_LSB is
           when FALSE   =>  EMAC0_SPEED_LSB_BINARY <= '0';
           when TRUE    =>  EMAC0_SPEED_LSB_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_SPEED_LSB is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_SPEED_MSB is
           when FALSE   =>  EMAC0_SPEED_MSB_BINARY <= '0';
           when TRUE    =>  EMAC0_SPEED_MSB_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_SPEED_MSB is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_MDIO_ENABLE is
           when FALSE   =>  EMAC0_MDIO_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_MDIO_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_MDIO_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_PHYLOOPBACKMSB is
           when FALSE   =>  EMAC0_PHYLOOPBACKMSB_BINARY <= '0';
           when TRUE    =>  EMAC0_PHYLOOPBACKMSB_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_PHYLOOPBACKMSB is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_PHYPOWERDOWN is
           when FALSE   =>  EMAC0_PHYPOWERDOWN_BINARY <= '0';
           when TRUE    =>  EMAC0_PHYPOWERDOWN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_PHYPOWERDOWN is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_PHYISOLATE is
           when FALSE   =>  EMAC0_PHYISOLATE_BINARY <= '0';
           when TRUE    =>  EMAC0_PHYISOLATE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_PHYISOLATE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_PHYINITAUTONEG_ENABLE is
           when FALSE   =>  EMAC0_PHYINITAUTONEG_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_PHYINITAUTONEG_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_PHYINITAUTONEG_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_PHYRESET is
           when FALSE   =>  EMAC0_PHYRESET_BINARY <= '0';
           when TRUE    =>  EMAC0_PHYRESET_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_PHYRESET is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_CONFIGVEC_79 is
           when FALSE   =>  EMAC0_CONFIGVEC_79_BINARY <= '0';
           when TRUE    =>  EMAC0_CONFIGVEC_79_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_CONFIGVEC_79 is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_UNIDIRECTION_ENABLE is
           when FALSE   =>  EMAC0_UNIDIRECTION_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC0_UNIDIRECTION_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_UNIDIRECTION_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_GTLOOPBACK is
           when FALSE   =>  EMAC0_GTLOOPBACK_BINARY <= '0';
           when TRUE    =>  EMAC0_GTLOOPBACK_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_GTLOOPBACK is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_BYTEPHY is
           when FALSE   =>  EMAC0_BYTEPHY_BINARY <= '0';
           when TRUE    =>  EMAC0_BYTEPHY_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_BYTEPHY is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC0_USECLKEN is
           when FALSE   =>  EMAC0_USECLKEN_BINARY <= '0';
           when TRUE    =>  EMAC0_USECLKEN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC0_USECLKEN is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RXHALFDUPLEX is
           when FALSE   =>  EMAC1_RXHALFDUPLEX_BINARY <= '0';
           when TRUE    =>  EMAC1_RXHALFDUPLEX_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RXHALFDUPLEX is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RXVLAN_ENABLE is
           when FALSE   =>  EMAC1_RXVLAN_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_RXVLAN_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RXVLAN_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RX_ENABLE is
           when FALSE   =>  EMAC1_RX_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_RX_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RX_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RXINBANDFCS_ENABLE is
           when FALSE   =>  EMAC1_RXINBANDFCS_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_RXINBANDFCS_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RXINBANDFCS_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RXJUMBOFRAME_ENABLE is
           when FALSE   =>  EMAC1_RXJUMBOFRAME_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_RXJUMBOFRAME_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RXJUMBOFRAME_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RXRESET is
           when FALSE   =>  EMAC1_RXRESET_BINARY <= '0';
           when TRUE    =>  EMAC1_RXRESET_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RXRESET is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TXIFGADJUST_ENABLE is
           when FALSE   =>  EMAC1_TXIFGADJUST_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_TXIFGADJUST_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TXIFGADJUST_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TXHALFDUPLEX is
           when FALSE   =>  EMAC1_TXHALFDUPLEX_BINARY <= '0';
           when TRUE    =>  EMAC1_TXHALFDUPLEX_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TXHALFDUPLEX is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TXVLAN_ENABLE is
           when FALSE   =>  EMAC1_TXVLAN_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_TXVLAN_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TXVLAN_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TX_ENABLE is
           when FALSE   =>  EMAC1_TX_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_TX_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TX_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TXINBANDFCS_ENABLE is
           when FALSE   =>  EMAC1_TXINBANDFCS_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_TXINBANDFCS_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TXINBANDFCS_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TXJUMBOFRAME_ENABLE is
           when FALSE   =>  EMAC1_TXJUMBOFRAME_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_TXJUMBOFRAME_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TXJUMBOFRAME_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TXRESET is
           when FALSE   =>  EMAC1_TXRESET_BINARY <= '0';
           when TRUE    =>  EMAC1_TXRESET_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TXRESET is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TXFLOWCTRL_ENABLE is
           when FALSE   =>  EMAC1_TXFLOWCTRL_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_TXFLOWCTRL_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TXFLOWCTRL_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RXFLOWCTRL_ENABLE is
           when FALSE   =>  EMAC1_RXFLOWCTRL_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_RXFLOWCTRL_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RXFLOWCTRL_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_LTCHECK_DISABLE is
           when FALSE   =>  EMAC1_LTCHECK_DISABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_LTCHECK_DISABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_LTCHECK_DISABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_ADDRFILTER_ENABLE is
           when FALSE   =>  EMAC1_ADDRFILTER_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_ADDRFILTER_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_ADDRFILTER_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RX16BITCLIENT_ENABLE is
           when FALSE   =>  EMAC1_RX16BITCLIENT_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_RX16BITCLIENT_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RX16BITCLIENT_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_TX16BITCLIENT_ENABLE is
           when FALSE   =>  EMAC1_TX16BITCLIENT_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_TX16BITCLIENT_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_TX16BITCLIENT_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_HOST_ENABLE is
           when FALSE   =>  EMAC1_HOST_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_HOST_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_HOST_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_1000BASEX_ENABLE is
           when FALSE   =>  EMAC1_1000BASEX_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_1000BASEX_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_1000BASEX_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_SGMII_ENABLE is
           when FALSE   =>  EMAC1_SGMII_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_SGMII_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_SGMII_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_RGMII_ENABLE is
           when FALSE   =>  EMAC1_RGMII_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_RGMII_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_RGMII_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_SPEED_LSB is
           when FALSE   =>  EMAC1_SPEED_LSB_BINARY <= '0';
           when TRUE    =>  EMAC1_SPEED_LSB_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_SPEED_LSB is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_SPEED_MSB is
           when FALSE   =>  EMAC1_SPEED_MSB_BINARY <= '0';
           when TRUE    =>  EMAC1_SPEED_MSB_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_SPEED_MSB is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_MDIO_ENABLE is
           when FALSE   =>  EMAC1_MDIO_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_MDIO_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_MDIO_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_PHYLOOPBACKMSB is
           when FALSE   =>  EMAC1_PHYLOOPBACKMSB_BINARY <= '0';
           when TRUE    =>  EMAC1_PHYLOOPBACKMSB_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_PHYLOOPBACKMSB is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_PHYPOWERDOWN is
           when FALSE   =>  EMAC1_PHYPOWERDOWN_BINARY <= '0';
           when TRUE    =>  EMAC1_PHYPOWERDOWN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_PHYPOWERDOWN is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_PHYISOLATE is
           when FALSE   =>  EMAC1_PHYISOLATE_BINARY <= '0';
           when TRUE    =>  EMAC1_PHYISOLATE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_PHYISOLATE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_PHYINITAUTONEG_ENABLE is
           when FALSE   =>  EMAC1_PHYINITAUTONEG_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_PHYINITAUTONEG_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_PHYINITAUTONEG_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_PHYRESET is
           when FALSE   =>  EMAC1_PHYRESET_BINARY <= '0';
           when TRUE    =>  EMAC1_PHYRESET_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_PHYRESET is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_CONFIGVEC_79 is
           when FALSE   =>  EMAC1_CONFIGVEC_79_BINARY <= '0';
           when TRUE    =>  EMAC1_CONFIGVEC_79_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_CONFIGVEC_79 is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_UNIDIRECTION_ENABLE is
           when FALSE   =>  EMAC1_UNIDIRECTION_ENABLE_BINARY <= '0';
           when TRUE    =>  EMAC1_UNIDIRECTION_ENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_UNIDIRECTION_ENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_GTLOOPBACK is
           when FALSE   =>  EMAC1_GTLOOPBACK_BINARY <= '0';
           when TRUE    =>  EMAC1_GTLOOPBACK_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_GTLOOPBACK is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_BYTEPHY is
           when FALSE   =>  EMAC1_BYTEPHY_BINARY <= '0';
           when TRUE    =>  EMAC1_BYTEPHY_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_BYTEPHY is neither TRUE nor FALSE." severity error;
       end case;
       case EMAC1_USECLKEN is
           when FALSE   =>  EMAC1_USECLKEN_BINARY <= '0';
           when TRUE    =>  EMAC1_USECLKEN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : EMAC1_USECLKEN is neither TRUE nor FALSE." severity error;
       end case;
	wait;
	end process INIPROC;

	TIMING : process

	variable  DCRHOSTDONEIR_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTANINTERRUPT_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXBADFRAME_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXCLIENTCLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD0_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD1_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD2_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD3_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD4_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD5_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD6_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD7_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD8_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD9_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD10_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD11_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD12_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD13_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD14_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXD15_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXDVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXDVLDMSW_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXFRAMEDROP_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXGOODFRAME_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATS0_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATS1_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATS2_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATS3_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATS4_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATS5_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATS6_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATSBYTEVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTRXSTATSVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTTXACK_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTTXCLIENTCLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTTXCOLLISION_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXGMIIMIICLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTTXRETRANSMIT_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTTXSTATS_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTTXSTATSBYTEVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC0CLIENTTXSTATSVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYENCOMMAALIGN_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYLOOPBACKMSB_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYMCLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYMDOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYMDTRI_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYMGTRXRESET_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYMGTTXRESET_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYPOWERDOWN_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYSYNCACQSTATUS_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXCHARDISPMODE_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXCHARDISPVAL_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXCHARISK_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXCLK_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD0_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD1_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD2_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD3_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD4_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD5_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD6_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXD7_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXEN_GlitchData : VitalGlitchDataType;
	variable  EMAC0PHYTXER_GlitchData : VitalGlitchDataType;
	variable  EMAC0SPEEDIS10100_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTANINTERRUPT_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXBADFRAME_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXCLIENTCLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD0_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD1_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD2_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD3_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD4_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD5_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD6_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD7_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD8_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD9_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD10_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD11_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD12_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD13_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD14_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXD15_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXDVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXDVLDMSW_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXFRAMEDROP_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXGOODFRAME_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATS0_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATS1_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATS2_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATS3_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATS4_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATS5_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATS6_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATSBYTEVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTRXSTATSVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTTXACK_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTTXCLIENTCLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTTXCOLLISION_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXGMIIMIICLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTTXRETRANSMIT_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTTXSTATS_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTTXSTATSBYTEVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC1CLIENTTXSTATSVLD_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYENCOMMAALIGN_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYLOOPBACKMSB_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYMCLKOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYMDOUT_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYMDTRI_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYMGTRXRESET_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYMGTTXRESET_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYPOWERDOWN_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYSYNCACQSTATUS_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXCHARDISPMODE_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXCHARDISPVAL_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXCHARISK_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXCLK_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD0_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD1_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD2_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD3_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD4_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD5_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD6_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXD7_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXEN_GlitchData : VitalGlitchDataType;
	variable  EMAC1PHYTXER_GlitchData : VitalGlitchDataType;
	variable  EMAC1SPEEDIS10100_GlitchData : VitalGlitchDataType;
	variable  EMACDCRACK_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS0_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS1_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS2_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS3_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS4_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS5_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS6_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS7_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS8_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS9_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS10_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS11_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS12_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS13_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS14_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS15_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS16_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS17_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS18_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS19_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS20_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS21_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS22_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS23_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS24_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS25_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS26_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS27_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS28_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS29_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS30_GlitchData : VitalGlitchDataType;
	variable  EMACDCRDBUS31_GlitchData : VitalGlitchDataType;
	variable  HOSTMIIMRDY_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA0_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA1_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA2_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA3_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA4_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA5_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA6_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA7_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA8_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA9_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA10_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA11_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA12_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA13_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA14_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA15_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA16_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA17_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA18_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA19_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA20_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA21_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA22_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA23_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA24_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA25_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA26_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA27_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA28_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA29_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA30_GlitchData : VitalGlitchDataType;
	variable  HOSTRDDATA31_GlitchData : VitalGlitchDataType;
begin
  
	VitalPathDelay01
	(
	OutSignal     => DCRHOSTDONEIR,
	GlitchData    => DCRHOSTDONEIR_GlitchData,
	OutSignalName => "DCRHOSTDONEIR",
	OutTemp       => DCRHOSTDONEIR_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTANINTERRUPT,
	GlitchData    => EMAC0CLIENTANINTERRUPT_GlitchData,
	OutSignalName => "EMAC0CLIENTANINTERRUPT",
	OutTemp       => EMAC0CLIENTANINTERRUPT_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXBADFRAME,
	GlitchData    => EMAC0CLIENTRXBADFRAME_GlitchData,
	OutSignalName => "EMAC0CLIENTRXBADFRAME",
	OutTemp       => EMAC0CLIENTRXBADFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXBADFRAME,
	GlitchData    => EMAC0CLIENTRXBADFRAME_GlitchData,
	OutSignalName => "EMAC0CLIENTRXBADFRAME",
	OutTemp       => EMAC0CLIENTRXBADFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXBADFRAME,
	GlitchData    => EMAC0CLIENTRXBADFRAME_GlitchData,
	OutSignalName => "EMAC0CLIENTRXBADFRAME",
	OutTemp       => EMAC0CLIENTRXBADFRAME_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC0CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC0CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC0CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC0CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC0CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC0CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC0CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC0CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC0CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC0CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC0CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC0CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(0),
	GlitchData    => EMAC0CLIENTRXD0_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(0)",
	OutTemp       => EMAC0CLIENTRXD_OUT(0),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(0),
	GlitchData    => EMAC0CLIENTRXD0_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(0)",
	OutTemp       => EMAC0CLIENTRXD_OUT(0),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(0),
	GlitchData    => EMAC0CLIENTRXD0_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(0)",
	OutTemp       => EMAC0CLIENTRXD_OUT(0),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(1),
	GlitchData    => EMAC0CLIENTRXD1_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(1)",
	OutTemp       => EMAC0CLIENTRXD_OUT(1),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(1),
	GlitchData    => EMAC0CLIENTRXD1_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(1)",
	OutTemp       => EMAC0CLIENTRXD_OUT(1),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(1),
	GlitchData    => EMAC0CLIENTRXD1_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(1)",
	OutTemp       => EMAC0CLIENTRXD_OUT(1),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(2),
	GlitchData    => EMAC0CLIENTRXD2_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(2)",
	OutTemp       => EMAC0CLIENTRXD_OUT(2),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(2),
	GlitchData    => EMAC0CLIENTRXD2_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(2)",
	OutTemp       => EMAC0CLIENTRXD_OUT(2),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(2),
	GlitchData    => EMAC0CLIENTRXD2_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(2)",
	OutTemp       => EMAC0CLIENTRXD_OUT(2),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(3),
	GlitchData    => EMAC0CLIENTRXD3_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(3)",
	OutTemp       => EMAC0CLIENTRXD_OUT(3),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(3),
	GlitchData    => EMAC0CLIENTRXD3_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(3)",
	OutTemp       => EMAC0CLIENTRXD_OUT(3),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(3),
	GlitchData    => EMAC0CLIENTRXD3_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(3)",
	OutTemp       => EMAC0CLIENTRXD_OUT(3),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(4),
	GlitchData    => EMAC0CLIENTRXD4_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(4)",
	OutTemp       => EMAC0CLIENTRXD_OUT(4),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(4),
	GlitchData    => EMAC0CLIENTRXD4_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(4)",
	OutTemp       => EMAC0CLIENTRXD_OUT(4),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(4),
	GlitchData    => EMAC0CLIENTRXD4_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(4)",
	OutTemp       => EMAC0CLIENTRXD_OUT(4),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(5),
	GlitchData    => EMAC0CLIENTRXD5_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(5)",
	OutTemp       => EMAC0CLIENTRXD_OUT(5),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(5),
	GlitchData    => EMAC0CLIENTRXD5_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(5)",
	OutTemp       => EMAC0CLIENTRXD_OUT(5),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(5),
	GlitchData    => EMAC0CLIENTRXD5_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(5)",
	OutTemp       => EMAC0CLIENTRXD_OUT(5),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(6),
	GlitchData    => EMAC0CLIENTRXD6_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(6)",
	OutTemp       => EMAC0CLIENTRXD_OUT(6),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(6),
	GlitchData    => EMAC0CLIENTRXD6_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(6)",
	OutTemp       => EMAC0CLIENTRXD_OUT(6),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(6),
	GlitchData    => EMAC0CLIENTRXD6_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(6)",
	OutTemp       => EMAC0CLIENTRXD_OUT(6),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(7),
	GlitchData    => EMAC0CLIENTRXD7_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(7)",
	OutTemp       => EMAC0CLIENTRXD_OUT(7),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(7),
	GlitchData    => EMAC0CLIENTRXD7_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(7)",
	OutTemp       => EMAC0CLIENTRXD_OUT(7),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(7),
	GlitchData    => EMAC0CLIENTRXD7_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(7)",
	OutTemp       => EMAC0CLIENTRXD_OUT(7),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(8),
	GlitchData    => EMAC0CLIENTRXD8_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(8)",
	OutTemp       => EMAC0CLIENTRXD_OUT(8),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(8),
	GlitchData    => EMAC0CLIENTRXD8_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(8)",
	OutTemp       => EMAC0CLIENTRXD_OUT(8),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(8),
	GlitchData    => EMAC0CLIENTRXD8_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(8)",
	OutTemp       => EMAC0CLIENTRXD_OUT(8),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(9),
	GlitchData    => EMAC0CLIENTRXD9_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(9)",
	OutTemp       => EMAC0CLIENTRXD_OUT(9),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(9),
	GlitchData    => EMAC0CLIENTRXD9_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(9)",
	OutTemp       => EMAC0CLIENTRXD_OUT(9),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(9),
	GlitchData    => EMAC0CLIENTRXD9_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(9)",
	OutTemp       => EMAC0CLIENTRXD_OUT(9),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(10),
	GlitchData    => EMAC0CLIENTRXD10_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(10)",
	OutTemp       => EMAC0CLIENTRXD_OUT(10),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(10),
	GlitchData    => EMAC0CLIENTRXD10_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(10)",
	OutTemp       => EMAC0CLIENTRXD_OUT(10),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(10),
	GlitchData    => EMAC0CLIENTRXD10_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(10)",
	OutTemp       => EMAC0CLIENTRXD_OUT(10),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(11),
	GlitchData    => EMAC0CLIENTRXD11_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(11)",
	OutTemp       => EMAC0CLIENTRXD_OUT(11),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(11),
	GlitchData    => EMAC0CLIENTRXD11_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(11)",
	OutTemp       => EMAC0CLIENTRXD_OUT(11),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(11),
	GlitchData    => EMAC0CLIENTRXD11_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(11)",
	OutTemp       => EMAC0CLIENTRXD_OUT(11),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(12),
	GlitchData    => EMAC0CLIENTRXD12_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(12)",
	OutTemp       => EMAC0CLIENTRXD_OUT(12),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(12),
	GlitchData    => EMAC0CLIENTRXD12_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(12)",
	OutTemp       => EMAC0CLIENTRXD_OUT(12),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(12),
	GlitchData    => EMAC0CLIENTRXD12_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(12)",
	OutTemp       => EMAC0CLIENTRXD_OUT(12),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(13),
	GlitchData    => EMAC0CLIENTRXD13_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(13)",
	OutTemp       => EMAC0CLIENTRXD_OUT(13),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(13),
	GlitchData    => EMAC0CLIENTRXD13_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(13)",
	OutTemp       => EMAC0CLIENTRXD_OUT(13),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(13),
	GlitchData    => EMAC0CLIENTRXD13_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(13)",
	OutTemp       => EMAC0CLIENTRXD_OUT(13),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(14),
	GlitchData    => EMAC0CLIENTRXD14_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(14)",
	OutTemp       => EMAC0CLIENTRXD_OUT(14),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(14),
	GlitchData    => EMAC0CLIENTRXD14_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(14)",
	OutTemp       => EMAC0CLIENTRXD_OUT(14),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(14),
	GlitchData    => EMAC0CLIENTRXD14_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(14)",
	OutTemp       => EMAC0CLIENTRXD_OUT(14),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(15),
	GlitchData    => EMAC0CLIENTRXD15_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(15)",
	OutTemp       => EMAC0CLIENTRXD_OUT(15),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(15),
	GlitchData    => EMAC0CLIENTRXD15_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(15)",
	OutTemp       => EMAC0CLIENTRXD_OUT(15),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXD(15),
	GlitchData    => EMAC0CLIENTRXD15_GlitchData,
	OutSignalName => "EMAC0CLIENTRXD(15)",
	OutTemp       => EMAC0CLIENTRXD_OUT(15),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXDVLD,
	GlitchData    => EMAC0CLIENTRXDVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXDVLD",
	OutTemp       => EMAC0CLIENTRXDVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXDVLD,
	GlitchData    => EMAC0CLIENTRXDVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXDVLD",
	OutTemp       => EMAC0CLIENTRXDVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXDVLD,
	GlitchData    => EMAC0CLIENTRXDVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXDVLD",
	OutTemp       => EMAC0CLIENTRXDVLD_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXDVLDMSW,
	GlitchData    => EMAC0CLIENTRXDVLDMSW_GlitchData,
	OutSignalName => "EMAC0CLIENTRXDVLDMSW",
	OutTemp       => EMAC0CLIENTRXDVLDMSW_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXDVLDMSW,
	GlitchData    => EMAC0CLIENTRXDVLDMSW_GlitchData,
	OutSignalName => "EMAC0CLIENTRXDVLDMSW",
	OutTemp       => EMAC0CLIENTRXDVLDMSW_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXDVLDMSW,
	GlitchData    => EMAC0CLIENTRXDVLDMSW_GlitchData,
	OutSignalName => "EMAC0CLIENTRXDVLDMSW",
	OutTemp       => EMAC0CLIENTRXDVLDMSW_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXFRAMEDROP,
	GlitchData    => EMAC0CLIENTRXFRAMEDROP_GlitchData,
	OutSignalName => "EMAC0CLIENTRXFRAMEDROP",
	OutTemp       => EMAC0CLIENTRXFRAMEDROP_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXFRAMEDROP,
	GlitchData    => EMAC0CLIENTRXFRAMEDROP_GlitchData,
	OutSignalName => "EMAC0CLIENTRXFRAMEDROP",
	OutTemp       => EMAC0CLIENTRXFRAMEDROP_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXFRAMEDROP,
	GlitchData    => EMAC0CLIENTRXFRAMEDROP_GlitchData,
	OutSignalName => "EMAC0CLIENTRXFRAMEDROP",
	OutTemp       => EMAC0CLIENTRXFRAMEDROP_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXGOODFRAME,
	GlitchData    => EMAC0CLIENTRXGOODFRAME_GlitchData,
	OutSignalName => "EMAC0CLIENTRXGOODFRAME",
	OutTemp       => EMAC0CLIENTRXGOODFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXGOODFRAME,
	GlitchData    => EMAC0CLIENTRXGOODFRAME_GlitchData,
	OutSignalName => "EMAC0CLIENTRXGOODFRAME",
	OutTemp       => EMAC0CLIENTRXGOODFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXGOODFRAME,
	GlitchData    => EMAC0CLIENTRXGOODFRAME_GlitchData,
	OutSignalName => "EMAC0CLIENTRXGOODFRAME",
	OutTemp       => EMAC0CLIENTRXGOODFRAME_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(0),
	GlitchData    => EMAC0CLIENTRXSTATS0_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(0)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(0),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(0),
	GlitchData    => EMAC0CLIENTRXSTATS0_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(0)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(0),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(0),
	GlitchData    => EMAC0CLIENTRXSTATS0_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(0)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(0),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(1),
	GlitchData    => EMAC0CLIENTRXSTATS1_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(1)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(1),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(1),
	GlitchData    => EMAC0CLIENTRXSTATS1_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(1)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(1),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(1),
	GlitchData    => EMAC0CLIENTRXSTATS1_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(1)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(1),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(2),
	GlitchData    => EMAC0CLIENTRXSTATS2_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(2)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(2),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(2),
	GlitchData    => EMAC0CLIENTRXSTATS2_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(2)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(2),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(2),
	GlitchData    => EMAC0CLIENTRXSTATS2_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(2)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(2),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(3),
	GlitchData    => EMAC0CLIENTRXSTATS3_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(3)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(3),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(3),
	GlitchData    => EMAC0CLIENTRXSTATS3_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(3)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(3),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(3),
	GlitchData    => EMAC0CLIENTRXSTATS3_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(3)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(3),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(4),
	GlitchData    => EMAC0CLIENTRXSTATS4_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(4)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(4),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(4),
	GlitchData    => EMAC0CLIENTRXSTATS4_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(4)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(4),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(4),
	GlitchData    => EMAC0CLIENTRXSTATS4_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(4)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(4),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(5),
	GlitchData    => EMAC0CLIENTRXSTATS5_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(5)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(5),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(5),
	GlitchData    => EMAC0CLIENTRXSTATS5_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(5)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(5),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(5),
	GlitchData    => EMAC0CLIENTRXSTATS5_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(5)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(5),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(6),
	GlitchData    => EMAC0CLIENTRXSTATS6_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(6)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(6),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(6),
	GlitchData    => EMAC0CLIENTRXSTATS6_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(6)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(6),
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATS(6),
	GlitchData    => EMAC0CLIENTRXSTATS6_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATS(6)",
	OutTemp       => EMAC0CLIENTRXSTATS_OUT(6),
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATSBYTEVLD,
	GlitchData    => EMAC0CLIENTRXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATSBYTEVLD",
	OutTemp       => EMAC0CLIENTRXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATSBYTEVLD,
	GlitchData    => EMAC0CLIENTRXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATSBYTEVLD",
	OutTemp       => EMAC0CLIENTRXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATSBYTEVLD,
	GlitchData    => EMAC0CLIENTRXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATSBYTEVLD",
	OutTemp       => EMAC0CLIENTRXSTATSBYTEVLD_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATSVLD,
	GlitchData    => EMAC0CLIENTRXSTATSVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATSVLD",
	OutTemp       => EMAC0CLIENTRXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATSVLD,
	GlitchData    => EMAC0CLIENTRXSTATSVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATSVLD",
	OutTemp       => EMAC0CLIENTRXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTRXSTATSVLD,
	GlitchData    => EMAC0CLIENTRXSTATSVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTRXSTATSVLD",
	OutTemp       => EMAC0CLIENTRXSTATSVLD_OUT,
	Paths         => (0 => (PHYEMAC0RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXACK,
	GlitchData    => EMAC0CLIENTTXACK_GlitchData,
	OutSignalName => "EMAC0CLIENTTXACK",
	OutTemp       => EMAC0CLIENTTXACK_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXACK,
	GlitchData    => EMAC0CLIENTTXACK_GlitchData,
	OutSignalName => "EMAC0CLIENTTXACK",
	OutTemp       => EMAC0CLIENTTXACK_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXACK,
	GlitchData    => EMAC0CLIENTTXACK_GlitchData,
	OutSignalName => "EMAC0CLIENTTXACK",
	OutTemp       => EMAC0CLIENTTXACK_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXCLIENTCLKOUT,
	GlitchData    => EMAC0CLIENTTXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC0CLIENTTXCLIENTCLKOUT",
	OutTemp       => EMAC0CLIENTTXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXCLIENTCLKOUT,
	GlitchData    => EMAC0CLIENTTXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC0CLIENTTXCLIENTCLKOUT",
	OutTemp       => EMAC0CLIENTTXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0MIITXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXCLIENTCLKOUT,
	GlitchData    => EMAC0CLIENTTXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC0CLIENTTXCLIENTCLKOUT",
	OutTemp       => EMAC0CLIENTTXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXCOLLISION,
	GlitchData    => EMAC0CLIENTTXCOLLISION_GlitchData,
	OutSignalName => "EMAC0CLIENTTXCOLLISION",
	OutTemp       => EMAC0CLIENTTXCOLLISION_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXCOLLISION,
	GlitchData    => EMAC0CLIENTTXCOLLISION_GlitchData,
	OutSignalName => "EMAC0CLIENTTXCOLLISION",
	OutTemp       => EMAC0CLIENTTXCOLLISION_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXCOLLISION,
	GlitchData    => EMAC0CLIENTTXCOLLISION_GlitchData,
	OutSignalName => "EMAC0CLIENTTXCOLLISION",
	OutTemp       => EMAC0CLIENTTXCOLLISION_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXGMIIMIICLKOUT,
	GlitchData    => EMAC0PHYTXGMIIMIICLKOUT_GlitchData,
	OutSignalName => "EMAC0PHYTXGMIIMIICLKOUT",
	OutTemp       => EMAC0PHYTXGMIIMIICLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXGMIIMIICLKOUT,
	GlitchData    => EMAC0PHYTXGMIIMIICLKOUT_GlitchData,
	OutSignalName => "EMAC0PHYTXGMIIMIICLKOUT",
	OutTemp       => EMAC0PHYTXGMIIMIICLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0MIITXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXRETRANSMIT,
	GlitchData    => EMAC0CLIENTTXRETRANSMIT_GlitchData,
	OutSignalName => "EMAC0CLIENTTXRETRANSMIT",
	OutTemp       => EMAC0CLIENTTXRETRANSMIT_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXRETRANSMIT,
	GlitchData    => EMAC0CLIENTTXRETRANSMIT_GlitchData,
	OutSignalName => "EMAC0CLIENTTXRETRANSMIT",
	OutTemp       => EMAC0CLIENTTXRETRANSMIT_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXRETRANSMIT,
	GlitchData    => EMAC0CLIENTTXRETRANSMIT_GlitchData,
	OutSignalName => "EMAC0CLIENTTXRETRANSMIT",
	OutTemp       => EMAC0CLIENTTXRETRANSMIT_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATS,
	GlitchData    => EMAC0CLIENTTXSTATS_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATS",
	OutTemp       => EMAC0CLIENTTXSTATS_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATS,
	GlitchData    => EMAC0CLIENTTXSTATS_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATS",
	OutTemp       => EMAC0CLIENTTXSTATS_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATS,
	GlitchData    => EMAC0CLIENTTXSTATS_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATS",
	OutTemp       => EMAC0CLIENTTXSTATS_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATSBYTEVLD,
	GlitchData    => EMAC0CLIENTTXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATSBYTEVLD",
	OutTemp       => EMAC0CLIENTTXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATSBYTEVLD,
	GlitchData    => EMAC0CLIENTTXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATSBYTEVLD",
	OutTemp       => EMAC0CLIENTTXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATSBYTEVLD,
	GlitchData    => EMAC0CLIENTTXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATSBYTEVLD",
	OutTemp       => EMAC0CLIENTTXSTATSBYTEVLD_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATSVLD,
	GlitchData    => EMAC0CLIENTTXSTATSVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATSVLD",
	OutTemp       => EMAC0CLIENTTXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATSVLD,
	GlitchData    => EMAC0CLIENTTXSTATSVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATSVLD",
	OutTemp       => EMAC0CLIENTTXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0CLIENTTXSTATSVLD,
	GlitchData    => EMAC0CLIENTTXSTATSVLD_GlitchData,
	OutSignalName => "EMAC0CLIENTTXSTATSVLD",
	OutTemp       => EMAC0CLIENTTXSTATSVLD_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYENCOMMAALIGN,
	GlitchData    => EMAC0PHYENCOMMAALIGN_GlitchData,
	OutSignalName => "EMAC0PHYENCOMMAALIGN",
	OutTemp       => EMAC0PHYENCOMMAALIGN_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYLOOPBACKMSB,
	GlitchData    => EMAC0PHYLOOPBACKMSB_GlitchData,
	OutSignalName => "EMAC0PHYLOOPBACKMSB",
	OutTemp       => EMAC0PHYLOOPBACKMSB_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMCLKOUT,
	GlitchData    => EMAC0PHYMCLKOUT_GlitchData,
	OutSignalName => "EMAC0PHYMCLKOUT",
	OutTemp       => EMAC0PHYMCLKOUT_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMCLKOUT,
	GlitchData    => EMAC0PHYMCLKOUT_GlitchData,
	OutSignalName => "EMAC0PHYMCLKOUT",
	OutTemp       => EMAC0PHYMCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC0MCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMDOUT,
	GlitchData    => EMAC0PHYMDOUT_GlitchData,
	OutSignalName => "EMAC0PHYMDOUT",
	OutTemp       => EMAC0PHYMDOUT_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMDOUT,
	GlitchData    => EMAC0PHYMDOUT_GlitchData,
	OutSignalName => "EMAC0PHYMDOUT",
	OutTemp       => EMAC0PHYMDOUT_OUT,
	Paths         => (0 => (PHYEMAC0MCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMDTRI,
	GlitchData    => EMAC0PHYMDTRI_GlitchData,
	OutSignalName => "EMAC0PHYMDTRI",
	OutTemp       => EMAC0PHYMDTRI_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMDTRI,
	GlitchData    => EMAC0PHYMDTRI_GlitchData,
	OutSignalName => "EMAC0PHYMDTRI",
	OutTemp       => EMAC0PHYMDTRI_OUT,
	Paths         => (0 => (PHYEMAC0MCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMGTRXRESET,
	GlitchData    => EMAC0PHYMGTRXRESET_GlitchData,
	OutSignalName => "EMAC0PHYMGTRXRESET",
	OutTemp       => EMAC0PHYMGTRXRESET_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYMGTTXRESET,
	GlitchData    => EMAC0PHYMGTTXRESET_GlitchData,
	OutSignalName => "EMAC0PHYMGTTXRESET",
	OutTemp       => EMAC0PHYMGTTXRESET_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYPOWERDOWN,
	GlitchData    => EMAC0PHYPOWERDOWN_GlitchData,
	OutSignalName => "EMAC0PHYPOWERDOWN",
	OutTemp       => EMAC0PHYPOWERDOWN_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYSYNCACQSTATUS,
	GlitchData    => EMAC0PHYSYNCACQSTATUS_GlitchData,
	OutSignalName => "EMAC0PHYSYNCACQSTATUS",
	OutTemp       => EMAC0PHYSYNCACQSTATUS_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYSYNCACQSTATUS,
	GlitchData    => EMAC0PHYSYNCACQSTATUS_GlitchData,
	OutSignalName => "EMAC0PHYSYNCACQSTATUS",
	OutTemp       => EMAC0PHYSYNCACQSTATUS_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYSYNCACQSTATUS,
	GlitchData    => EMAC0PHYSYNCACQSTATUS_GlitchData,
	OutSignalName => "EMAC0PHYSYNCACQSTATUS",
	OutTemp       => EMAC0PHYSYNCACQSTATUS_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARDISPMODE,
	GlitchData    => EMAC0PHYTXCHARDISPMODE_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARDISPMODE",
	OutTemp       => EMAC0PHYTXCHARDISPMODE_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARDISPMODE,
	GlitchData    => EMAC0PHYTXCHARDISPMODE_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARDISPMODE",
	OutTemp       => EMAC0PHYTXCHARDISPMODE_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARDISPMODE,
	GlitchData    => EMAC0PHYTXCHARDISPMODE_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARDISPMODE",
	OutTemp       => EMAC0PHYTXCHARDISPMODE_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARDISPVAL,
	GlitchData    => EMAC0PHYTXCHARDISPVAL_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARDISPVAL",
	OutTemp       => EMAC0PHYTXCHARDISPVAL_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARDISPVAL,
	GlitchData    => EMAC0PHYTXCHARDISPVAL_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARDISPVAL",
	OutTemp       => EMAC0PHYTXCHARDISPVAL_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARDISPVAL,
	GlitchData    => EMAC0PHYTXCHARDISPVAL_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARDISPVAL",
	OutTemp       => EMAC0PHYTXCHARDISPVAL_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARISK,
	GlitchData    => EMAC0PHYTXCHARISK_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARISK",
	OutTemp       => EMAC0PHYTXCHARISK_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARISK,
	GlitchData    => EMAC0PHYTXCHARISK_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARISK",
	OutTemp       => EMAC0PHYTXCHARISK_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCHARISK,
	GlitchData    => EMAC0PHYTXCHARISK_GlitchData,
	OutSignalName => "EMAC0PHYTXCHARISK",
	OutTemp       => EMAC0PHYTXCHARISK_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCLK,
	GlitchData    => EMAC0PHYTXCLK_GlitchData,
	OutSignalName => "EMAC0PHYTXCLK",
	OutTemp       => EMAC0PHYTXCLK_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCLK,
	GlitchData    => EMAC0PHYTXCLK_GlitchData,
	OutSignalName => "EMAC0PHYTXCLK",
	OutTemp       => EMAC0PHYTXCLK_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXCLK,
	GlitchData    => EMAC0PHYTXCLK_GlitchData,
	OutSignalName => "EMAC0PHYTXCLK",
	OutTemp       => EMAC0PHYTXCLK_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(0),
	GlitchData    => EMAC0PHYTXD0_GlitchData,
	OutSignalName => "EMAC0PHYTXD(0)",
	OutTemp       => EMAC0PHYTXD_OUT(0),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(0),
	GlitchData    => EMAC0PHYTXD0_GlitchData,
	OutSignalName => "EMAC0PHYTXD(0)",
	OutTemp       => EMAC0PHYTXD_OUT(0),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(0),
	GlitchData    => EMAC0PHYTXD0_GlitchData,
	OutSignalName => "EMAC0PHYTXD(0)",
	OutTemp       => EMAC0PHYTXD_OUT(0),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(1),
	GlitchData    => EMAC0PHYTXD1_GlitchData,
	OutSignalName => "EMAC0PHYTXD(1)",
	OutTemp       => EMAC0PHYTXD_OUT(1),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(1),
	GlitchData    => EMAC0PHYTXD1_GlitchData,
	OutSignalName => "EMAC0PHYTXD(1)",
	OutTemp       => EMAC0PHYTXD_OUT(1),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(1),
	GlitchData    => EMAC0PHYTXD1_GlitchData,
	OutSignalName => "EMAC0PHYTXD(1)",
	OutTemp       => EMAC0PHYTXD_OUT(1),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(2),
	GlitchData    => EMAC0PHYTXD2_GlitchData,
	OutSignalName => "EMAC0PHYTXD(2)",
	OutTemp       => EMAC0PHYTXD_OUT(2),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(2),
	GlitchData    => EMAC0PHYTXD2_GlitchData,
	OutSignalName => "EMAC0PHYTXD(2)",
	OutTemp       => EMAC0PHYTXD_OUT(2),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(2),
	GlitchData    => EMAC0PHYTXD2_GlitchData,
	OutSignalName => "EMAC0PHYTXD(2)",
	OutTemp       => EMAC0PHYTXD_OUT(2),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(3),
	GlitchData    => EMAC0PHYTXD3_GlitchData,
	OutSignalName => "EMAC0PHYTXD(3)",
	OutTemp       => EMAC0PHYTXD_OUT(3),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(3),
	GlitchData    => EMAC0PHYTXD3_GlitchData,
	OutSignalName => "EMAC0PHYTXD(3)",
	OutTemp       => EMAC0PHYTXD_OUT(3),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(3),
	GlitchData    => EMAC0PHYTXD3_GlitchData,
	OutSignalName => "EMAC0PHYTXD(3)",
	OutTemp       => EMAC0PHYTXD_OUT(3),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(4),
	GlitchData    => EMAC0PHYTXD4_GlitchData,
	OutSignalName => "EMAC0PHYTXD(4)",
	OutTemp       => EMAC0PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(4),
	GlitchData    => EMAC0PHYTXD4_GlitchData,
	OutSignalName => "EMAC0PHYTXD(4)",
	OutTemp       => EMAC0PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(4),
	GlitchData    => EMAC0PHYTXD4_GlitchData,
	OutSignalName => "EMAC0PHYTXD(4)",
	OutTemp       => EMAC0PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(4),
	GlitchData    => EMAC0PHYTXD4_GlitchData,
	OutSignalName => "EMAC0PHYTXD(4)",
	OutTemp       => EMAC0PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(5),
	GlitchData    => EMAC0PHYTXD5_GlitchData,
	OutSignalName => "EMAC0PHYTXD(5)",
	OutTemp       => EMAC0PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(5),
	GlitchData    => EMAC0PHYTXD5_GlitchData,
	OutSignalName => "EMAC0PHYTXD(5)",
	OutTemp       => EMAC0PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(5),
	GlitchData    => EMAC0PHYTXD5_GlitchData,
	OutSignalName => "EMAC0PHYTXD(5)",
	OutTemp       => EMAC0PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(5),
	GlitchData    => EMAC0PHYTXD5_GlitchData,
	OutSignalName => "EMAC0PHYTXD(5)",
	OutTemp       => EMAC0PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(6),
	GlitchData    => EMAC0PHYTXD6_GlitchData,
	OutSignalName => "EMAC0PHYTXD(6)",
	OutTemp       => EMAC0PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(6),
	GlitchData    => EMAC0PHYTXD6_GlitchData,
	OutSignalName => "EMAC0PHYTXD(6)",
	OutTemp       => EMAC0PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(6),
	GlitchData    => EMAC0PHYTXD6_GlitchData,
	OutSignalName => "EMAC0PHYTXD(6)",
	OutTemp       => EMAC0PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(6),
	GlitchData    => EMAC0PHYTXD6_GlitchData,
	OutSignalName => "EMAC0PHYTXD(6)",
	OutTemp       => EMAC0PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(7),
	GlitchData    => EMAC0PHYTXD7_GlitchData,
	OutSignalName => "EMAC0PHYTXD(7)",
	OutTemp       => EMAC0PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(7),
	GlitchData    => EMAC0PHYTXD7_GlitchData,
	OutSignalName => "EMAC0PHYTXD(7)",
	OutTemp       => EMAC0PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(7),
	GlitchData    => EMAC0PHYTXD7_GlitchData,
	OutSignalName => "EMAC0PHYTXD(7)",
	OutTemp       => EMAC0PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXD(7),
	GlitchData    => EMAC0PHYTXD7_GlitchData,
	OutSignalName => "EMAC0PHYTXD(7)",
	OutTemp       => EMAC0PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXEN,
	GlitchData    => EMAC0PHYTXEN_GlitchData,
	OutSignalName => "EMAC0PHYTXEN",
	OutTemp       => EMAC0PHYTXEN_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXEN,
	GlitchData    => EMAC0PHYTXEN_GlitchData,
	OutSignalName => "EMAC0PHYTXEN",
	OutTemp       => EMAC0PHYTXEN_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXEN,
	GlitchData    => EMAC0PHYTXEN_GlitchData,
	OutSignalName => "EMAC0PHYTXEN",
	OutTemp       => EMAC0PHYTXEN_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXER,
	GlitchData    => EMAC0PHYTXER_GlitchData,
	OutSignalName => "EMAC0PHYTXER",
	OutTemp       => EMAC0PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXER,
	GlitchData    => EMAC0PHYTXER_GlitchData,
	OutSignalName => "EMAC0PHYTXER",
	OutTemp       => EMAC0PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXER,
	GlitchData    => EMAC0PHYTXER_GlitchData,
	OutSignalName => "EMAC0PHYTXER",
	OutTemp       => EMAC0PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0PHYTXER,
	GlitchData    => EMAC0PHYTXER_GlitchData,
	OutSignalName => "EMAC0PHYTXER",
	OutTemp       => EMAC0PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC0TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC0SPEEDIS10100,
	GlitchData    => EMAC0SPEEDIS10100_GlitchData,
	OutSignalName => "EMAC0SPEEDIS10100",
	OutTemp       => EMAC0SPEEDIS10100_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTANINTERRUPT,
	GlitchData    => EMAC1CLIENTANINTERRUPT_GlitchData,
	OutSignalName => "EMAC1CLIENTANINTERRUPT",
	OutTemp       => EMAC1CLIENTANINTERRUPT_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXBADFRAME,
	GlitchData    => EMAC1CLIENTRXBADFRAME_GlitchData,
	OutSignalName => "EMAC1CLIENTRXBADFRAME",
	OutTemp       => EMAC1CLIENTRXBADFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXBADFRAME,
	GlitchData    => EMAC1CLIENTRXBADFRAME_GlitchData,
	OutSignalName => "EMAC1CLIENTRXBADFRAME",
	OutTemp       => EMAC1CLIENTRXBADFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXBADFRAME,
	GlitchData    => EMAC1CLIENTRXBADFRAME_GlitchData,
	OutSignalName => "EMAC1CLIENTRXBADFRAME",
	OutTemp       => EMAC1CLIENTRXBADFRAME_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC1CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC1CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC1CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC1CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC1CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC1CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC1CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC1CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC1CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXCLIENTCLKOUT,
	GlitchData    => EMAC1CLIENTRXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC1CLIENTRXCLIENTCLKOUT",
	OutTemp       => EMAC1CLIENTRXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(0),
	GlitchData    => EMAC1CLIENTRXD0_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(0)",
	OutTemp       => EMAC1CLIENTRXD_OUT(0),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(0),
	GlitchData    => EMAC1CLIENTRXD0_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(0)",
	OutTemp       => EMAC1CLIENTRXD_OUT(0),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(0),
	GlitchData    => EMAC1CLIENTRXD0_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(0)",
	OutTemp       => EMAC1CLIENTRXD_OUT(0),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(1),
	GlitchData    => EMAC1CLIENTRXD1_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(1)",
	OutTemp       => EMAC1CLIENTRXD_OUT(1),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(1),
	GlitchData    => EMAC1CLIENTRXD1_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(1)",
	OutTemp       => EMAC1CLIENTRXD_OUT(1),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(1),
	GlitchData    => EMAC1CLIENTRXD1_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(1)",
	OutTemp       => EMAC1CLIENTRXD_OUT(1),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(2),
	GlitchData    => EMAC1CLIENTRXD2_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(2)",
	OutTemp       => EMAC1CLIENTRXD_OUT(2),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(2),
	GlitchData    => EMAC1CLIENTRXD2_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(2)",
	OutTemp       => EMAC1CLIENTRXD_OUT(2),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(2),
	GlitchData    => EMAC1CLIENTRXD2_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(2)",
	OutTemp       => EMAC1CLIENTRXD_OUT(2),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(3),
	GlitchData    => EMAC1CLIENTRXD3_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(3)",
	OutTemp       => EMAC1CLIENTRXD_OUT(3),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(3),
	GlitchData    => EMAC1CLIENTRXD3_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(3)",
	OutTemp       => EMAC1CLIENTRXD_OUT(3),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(3),
	GlitchData    => EMAC1CLIENTRXD3_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(3)",
	OutTemp       => EMAC1CLIENTRXD_OUT(3),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(4),
	GlitchData    => EMAC1CLIENTRXD4_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(4)",
	OutTemp       => EMAC1CLIENTRXD_OUT(4),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(4),
	GlitchData    => EMAC1CLIENTRXD4_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(4)",
	OutTemp       => EMAC1CLIENTRXD_OUT(4),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(4),
	GlitchData    => EMAC1CLIENTRXD4_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(4)",
	OutTemp       => EMAC1CLIENTRXD_OUT(4),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(5),
	GlitchData    => EMAC1CLIENTRXD5_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(5)",
	OutTemp       => EMAC1CLIENTRXD_OUT(5),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(5),
	GlitchData    => EMAC1CLIENTRXD5_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(5)",
	OutTemp       => EMAC1CLIENTRXD_OUT(5),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(5),
	GlitchData    => EMAC1CLIENTRXD5_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(5)",
	OutTemp       => EMAC1CLIENTRXD_OUT(5),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(6),
	GlitchData    => EMAC1CLIENTRXD6_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(6)",
	OutTemp       => EMAC1CLIENTRXD_OUT(6),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(6),
	GlitchData    => EMAC1CLIENTRXD6_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(6)",
	OutTemp       => EMAC1CLIENTRXD_OUT(6),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(6),
	GlitchData    => EMAC1CLIENTRXD6_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(6)",
	OutTemp       => EMAC1CLIENTRXD_OUT(6),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(7),
	GlitchData    => EMAC1CLIENTRXD7_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(7)",
	OutTemp       => EMAC1CLIENTRXD_OUT(7),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(7),
	GlitchData    => EMAC1CLIENTRXD7_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(7)",
	OutTemp       => EMAC1CLIENTRXD_OUT(7),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(7),
	GlitchData    => EMAC1CLIENTRXD7_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(7)",
	OutTemp       => EMAC1CLIENTRXD_OUT(7),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(8),
	GlitchData    => EMAC1CLIENTRXD8_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(8)",
	OutTemp       => EMAC1CLIENTRXD_OUT(8),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(8),
	GlitchData    => EMAC1CLIENTRXD8_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(8)",
	OutTemp       => EMAC1CLIENTRXD_OUT(8),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(8),
	GlitchData    => EMAC1CLIENTRXD8_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(8)",
	OutTemp       => EMAC1CLIENTRXD_OUT(8),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(9),
	GlitchData    => EMAC1CLIENTRXD9_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(9)",
	OutTemp       => EMAC1CLIENTRXD_OUT(9),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(9),
	GlitchData    => EMAC1CLIENTRXD9_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(9)",
	OutTemp       => EMAC1CLIENTRXD_OUT(9),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(9),
	GlitchData    => EMAC1CLIENTRXD9_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(9)",
	OutTemp       => EMAC1CLIENTRXD_OUT(9),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(10),
	GlitchData    => EMAC1CLIENTRXD10_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(10)",
	OutTemp       => EMAC1CLIENTRXD_OUT(10),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(10),
	GlitchData    => EMAC1CLIENTRXD10_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(10)",
	OutTemp       => EMAC1CLIENTRXD_OUT(10),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(10),
	GlitchData    => EMAC1CLIENTRXD10_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(10)",
	OutTemp       => EMAC1CLIENTRXD_OUT(10),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(11),
	GlitchData    => EMAC1CLIENTRXD11_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(11)",
	OutTemp       => EMAC1CLIENTRXD_OUT(11),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(11),
	GlitchData    => EMAC1CLIENTRXD11_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(11)",
	OutTemp       => EMAC1CLIENTRXD_OUT(11),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(11),
	GlitchData    => EMAC1CLIENTRXD11_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(11)",
	OutTemp       => EMAC1CLIENTRXD_OUT(11),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(12),
	GlitchData    => EMAC1CLIENTRXD12_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(12)",
	OutTemp       => EMAC1CLIENTRXD_OUT(12),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(12),
	GlitchData    => EMAC1CLIENTRXD12_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(12)",
	OutTemp       => EMAC1CLIENTRXD_OUT(12),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(12),
	GlitchData    => EMAC1CLIENTRXD12_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(12)",
	OutTemp       => EMAC1CLIENTRXD_OUT(12),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(13),
	GlitchData    => EMAC1CLIENTRXD13_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(13)",
	OutTemp       => EMAC1CLIENTRXD_OUT(13),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(13),
	GlitchData    => EMAC1CLIENTRXD13_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(13)",
	OutTemp       => EMAC1CLIENTRXD_OUT(13),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(13),
	GlitchData    => EMAC1CLIENTRXD13_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(13)",
	OutTemp       => EMAC1CLIENTRXD_OUT(13),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(14),
	GlitchData    => EMAC1CLIENTRXD14_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(14)",
	OutTemp       => EMAC1CLIENTRXD_OUT(14),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(14),
	GlitchData    => EMAC1CLIENTRXD14_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(14)",
	OutTemp       => EMAC1CLIENTRXD_OUT(14),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(14),
	GlitchData    => EMAC1CLIENTRXD14_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(14)",
	OutTemp       => EMAC1CLIENTRXD_OUT(14),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(15),
	GlitchData    => EMAC1CLIENTRXD15_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(15)",
	OutTemp       => EMAC1CLIENTRXD_OUT(15),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(15),
	GlitchData    => EMAC1CLIENTRXD15_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(15)",
	OutTemp       => EMAC1CLIENTRXD_OUT(15),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXD(15),
	GlitchData    => EMAC1CLIENTRXD15_GlitchData,
	OutSignalName => "EMAC1CLIENTRXD(15)",
	OutTemp       => EMAC1CLIENTRXD_OUT(15),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXDVLD,
	GlitchData    => EMAC1CLIENTRXDVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXDVLD",
	OutTemp       => EMAC1CLIENTRXDVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXDVLD,
	GlitchData    => EMAC1CLIENTRXDVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXDVLD",
	OutTemp       => EMAC1CLIENTRXDVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXDVLD,
	GlitchData    => EMAC1CLIENTRXDVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXDVLD",
	OutTemp       => EMAC1CLIENTRXDVLD_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXDVLDMSW,
	GlitchData    => EMAC1CLIENTRXDVLDMSW_GlitchData,
	OutSignalName => "EMAC1CLIENTRXDVLDMSW",
	OutTemp       => EMAC1CLIENTRXDVLDMSW_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXDVLDMSW,
	GlitchData    => EMAC1CLIENTRXDVLDMSW_GlitchData,
	OutSignalName => "EMAC1CLIENTRXDVLDMSW",
	OutTemp       => EMAC1CLIENTRXDVLDMSW_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXDVLDMSW,
	GlitchData    => EMAC1CLIENTRXDVLDMSW_GlitchData,
	OutSignalName => "EMAC1CLIENTRXDVLDMSW",
	OutTemp       => EMAC1CLIENTRXDVLDMSW_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXFRAMEDROP,
	GlitchData    => EMAC1CLIENTRXFRAMEDROP_GlitchData,
	OutSignalName => "EMAC1CLIENTRXFRAMEDROP",
	OutTemp       => EMAC1CLIENTRXFRAMEDROP_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXFRAMEDROP,
	GlitchData    => EMAC1CLIENTRXFRAMEDROP_GlitchData,
	OutSignalName => "EMAC1CLIENTRXFRAMEDROP",
	OutTemp       => EMAC1CLIENTRXFRAMEDROP_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXFRAMEDROP,
	GlitchData    => EMAC1CLIENTRXFRAMEDROP_GlitchData,
	OutSignalName => "EMAC1CLIENTRXFRAMEDROP",
	OutTemp       => EMAC1CLIENTRXFRAMEDROP_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXGOODFRAME,
	GlitchData    => EMAC1CLIENTRXGOODFRAME_GlitchData,
	OutSignalName => "EMAC1CLIENTRXGOODFRAME",
	OutTemp       => EMAC1CLIENTRXGOODFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXGOODFRAME,
	GlitchData    => EMAC1CLIENTRXGOODFRAME_GlitchData,
	OutSignalName => "EMAC1CLIENTRXGOODFRAME",
	OutTemp       => EMAC1CLIENTRXGOODFRAME_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXGOODFRAME,
	GlitchData    => EMAC1CLIENTRXGOODFRAME_GlitchData,
	OutSignalName => "EMAC1CLIENTRXGOODFRAME",
	OutTemp       => EMAC1CLIENTRXGOODFRAME_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(0),
	GlitchData    => EMAC1CLIENTRXSTATS0_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(0)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(0),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(0),
	GlitchData    => EMAC1CLIENTRXSTATS0_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(0)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(0),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(0),
	GlitchData    => EMAC1CLIENTRXSTATS0_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(0)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(0),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(1),
	GlitchData    => EMAC1CLIENTRXSTATS1_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(1)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(1),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(1),
	GlitchData    => EMAC1CLIENTRXSTATS1_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(1)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(1),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(1),
	GlitchData    => EMAC1CLIENTRXSTATS1_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(1)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(1),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(2),
	GlitchData    => EMAC1CLIENTRXSTATS2_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(2)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(2),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(2),
	GlitchData    => EMAC1CLIENTRXSTATS2_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(2)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(2),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(2),
	GlitchData    => EMAC1CLIENTRXSTATS2_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(2)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(2),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(3),
	GlitchData    => EMAC1CLIENTRXSTATS3_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(3)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(3),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(3),
	GlitchData    => EMAC1CLIENTRXSTATS3_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(3)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(3),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(3),
	GlitchData    => EMAC1CLIENTRXSTATS3_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(3)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(3),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(4),
	GlitchData    => EMAC1CLIENTRXSTATS4_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(4)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(4),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(4),
	GlitchData    => EMAC1CLIENTRXSTATS4_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(4)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(4),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(4),
	GlitchData    => EMAC1CLIENTRXSTATS4_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(4)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(4),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(5),
	GlitchData    => EMAC1CLIENTRXSTATS5_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(5)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(5),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(5),
	GlitchData    => EMAC1CLIENTRXSTATS5_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(5)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(5),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(5),
	GlitchData    => EMAC1CLIENTRXSTATS5_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(5)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(5),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(6),
	GlitchData    => EMAC1CLIENTRXSTATS6_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(6)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(6),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(6),
	GlitchData    => EMAC1CLIENTRXSTATS6_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(6)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(6),
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATS(6),
	GlitchData    => EMAC1CLIENTRXSTATS6_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATS(6)",
	OutTemp       => EMAC1CLIENTRXSTATS_OUT(6),
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATSBYTEVLD,
	GlitchData    => EMAC1CLIENTRXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATSBYTEVLD",
	OutTemp       => EMAC1CLIENTRXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATSBYTEVLD,
	GlitchData    => EMAC1CLIENTRXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATSBYTEVLD",
	OutTemp       => EMAC1CLIENTRXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATSBYTEVLD,
	GlitchData    => EMAC1CLIENTRXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATSBYTEVLD",
	OutTemp       => EMAC1CLIENTRXSTATSBYTEVLD_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATSVLD,
	GlitchData    => EMAC1CLIENTRXSTATSVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATSVLD",
	OutTemp       => EMAC1CLIENTRXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATSVLD,
	GlitchData    => EMAC1CLIENTRXSTATSVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATSVLD",
	OutTemp       => EMAC1CLIENTRXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTRXSTATSVLD,
	GlitchData    => EMAC1CLIENTRXSTATSVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTRXSTATSVLD",
	OutTemp       => EMAC1CLIENTRXSTATSVLD_OUT,
	Paths         => (0 => (PHYEMAC1RXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXACK,
	GlitchData    => EMAC1CLIENTTXACK_GlitchData,
	OutSignalName => "EMAC1CLIENTTXACK",
	OutTemp       => EMAC1CLIENTTXACK_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXACK,
	GlitchData    => EMAC1CLIENTTXACK_GlitchData,
	OutSignalName => "EMAC1CLIENTTXACK",
	OutTemp       => EMAC1CLIENTTXACK_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXACK,
	GlitchData    => EMAC1CLIENTTXACK_GlitchData,
	OutSignalName => "EMAC1CLIENTTXACK",
	OutTemp       => EMAC1CLIENTTXACK_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXCLIENTCLKOUT,
	GlitchData    => EMAC1CLIENTTXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC1CLIENTTXCLIENTCLKOUT",
	OutTemp       => EMAC1CLIENTTXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXCLIENTCLKOUT,
	GlitchData    => EMAC1CLIENTTXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC1CLIENTTXCLIENTCLKOUT",
	OutTemp       => EMAC1CLIENTTXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1MIITXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXCLIENTCLKOUT,
	GlitchData    => EMAC1CLIENTTXCLIENTCLKOUT_GlitchData,
	OutSignalName => "EMAC1CLIENTTXCLIENTCLKOUT",
	OutTemp       => EMAC1CLIENTTXCLIENTCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXCOLLISION,
	GlitchData    => EMAC1CLIENTTXCOLLISION_GlitchData,
	OutSignalName => "EMAC1CLIENTTXCOLLISION",
	OutTemp       => EMAC1CLIENTTXCOLLISION_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXCOLLISION,
	GlitchData    => EMAC1CLIENTTXCOLLISION_GlitchData,
	OutSignalName => "EMAC1CLIENTTXCOLLISION",
	OutTemp       => EMAC1CLIENTTXCOLLISION_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXCOLLISION,
	GlitchData    => EMAC1CLIENTTXCOLLISION_GlitchData,
	OutSignalName => "EMAC1CLIENTTXCOLLISION",
	OutTemp       => EMAC1CLIENTTXCOLLISION_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXGMIIMIICLKOUT,
	GlitchData    => EMAC1PHYTXGMIIMIICLKOUT_GlitchData,
	OutSignalName => "EMAC1PHYTXGMIIMIICLKOUT",
	OutTemp       => EMAC1PHYTXGMIIMIICLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXGMIIMIICLKOUT,
	GlitchData    => EMAC1PHYTXGMIIMIICLKOUT_GlitchData,
	OutSignalName => "EMAC1PHYTXGMIIMIICLKOUT",
	OutTemp       => EMAC1PHYTXGMIIMIICLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1MIITXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXRETRANSMIT,
	GlitchData    => EMAC1CLIENTTXRETRANSMIT_GlitchData,
	OutSignalName => "EMAC1CLIENTTXRETRANSMIT",
	OutTemp       => EMAC1CLIENTTXRETRANSMIT_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXRETRANSMIT,
	GlitchData    => EMAC1CLIENTTXRETRANSMIT_GlitchData,
	OutSignalName => "EMAC1CLIENTTXRETRANSMIT",
	OutTemp       => EMAC1CLIENTTXRETRANSMIT_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXRETRANSMIT,
	GlitchData    => EMAC1CLIENTTXRETRANSMIT_GlitchData,
	OutSignalName => "EMAC1CLIENTTXRETRANSMIT",
	OutTemp       => EMAC1CLIENTTXRETRANSMIT_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATS,
	GlitchData    => EMAC1CLIENTTXSTATS_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATS",
	OutTemp       => EMAC1CLIENTTXSTATS_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATS,
	GlitchData    => EMAC1CLIENTTXSTATS_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATS",
	OutTemp       => EMAC1CLIENTTXSTATS_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATS,
	GlitchData    => EMAC1CLIENTTXSTATS_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATS",
	OutTemp       => EMAC1CLIENTTXSTATS_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATSBYTEVLD,
	GlitchData    => EMAC1CLIENTTXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATSBYTEVLD",
	OutTemp       => EMAC1CLIENTTXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATSBYTEVLD,
	GlitchData    => EMAC1CLIENTTXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATSBYTEVLD",
	OutTemp       => EMAC1CLIENTTXSTATSBYTEVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATSBYTEVLD,
	GlitchData    => EMAC1CLIENTTXSTATSBYTEVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATSBYTEVLD",
	OutTemp       => EMAC1CLIENTTXSTATSBYTEVLD_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATSVLD,
	GlitchData    => EMAC1CLIENTTXSTATSVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATSVLD",
	OutTemp       => EMAC1CLIENTTXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATSVLD,
	GlitchData    => EMAC1CLIENTTXSTATSVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATSVLD",
	OutTemp       => EMAC1CLIENTTXSTATSVLD_OUT,
	Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1CLIENTTXSTATSVLD,
	GlitchData    => EMAC1CLIENTTXSTATSVLD_GlitchData,
	OutSignalName => "EMAC1CLIENTTXSTATSVLD",
	OutTemp       => EMAC1CLIENTTXSTATSVLD_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYENCOMMAALIGN,
	GlitchData    => EMAC1PHYENCOMMAALIGN_GlitchData,
	OutSignalName => "EMAC1PHYENCOMMAALIGN",
	OutTemp       => EMAC1PHYENCOMMAALIGN_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYLOOPBACKMSB,
	GlitchData    => EMAC1PHYLOOPBACKMSB_GlitchData,
	OutSignalName => "EMAC1PHYLOOPBACKMSB",
	OutTemp       => EMAC1PHYLOOPBACKMSB_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMCLKOUT,
	GlitchData    => EMAC1PHYMCLKOUT_GlitchData,
	OutSignalName => "EMAC1PHYMCLKOUT",
	OutTemp       => EMAC1PHYMCLKOUT_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMCLKOUT,
	GlitchData    => EMAC1PHYMCLKOUT_GlitchData,
	OutSignalName => "EMAC1PHYMCLKOUT",
	OutTemp       => EMAC1PHYMCLKOUT_OUT,
	Paths         => (0 => (PHYEMAC1MCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMDOUT,
	GlitchData    => EMAC1PHYMDOUT_GlitchData,
	OutSignalName => "EMAC1PHYMDOUT",
	OutTemp       => EMAC1PHYMDOUT_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMDOUT,
	GlitchData    => EMAC1PHYMDOUT_GlitchData,
	OutSignalName => "EMAC1PHYMDOUT",
	OutTemp       => EMAC1PHYMDOUT_OUT,
	Paths         => (0 => (PHYEMAC1MCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMDTRI,
	GlitchData    => EMAC1PHYMDTRI_GlitchData,
	OutSignalName => "EMAC1PHYMDTRI",
	OutTemp       => EMAC1PHYMDTRI_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMDTRI,
	GlitchData    => EMAC1PHYMDTRI_GlitchData,
	OutSignalName => "EMAC1PHYMDTRI",
	OutTemp       => EMAC1PHYMDTRI_OUT,
	Paths         => (0 => (PHYEMAC1MCLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMGTRXRESET,
	GlitchData    => EMAC1PHYMGTRXRESET_GlitchData,
	OutSignalName => "EMAC1PHYMGTRXRESET",
	OutTemp       => EMAC1PHYMGTRXRESET_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYMGTTXRESET,
	GlitchData    => EMAC1PHYMGTTXRESET_GlitchData,
	OutSignalName => "EMAC1PHYMGTTXRESET",
	OutTemp       => EMAC1PHYMGTTXRESET_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYPOWERDOWN,
	GlitchData    => EMAC1PHYPOWERDOWN_GlitchData,
	OutSignalName => "EMAC1PHYPOWERDOWN",
	OutTemp       => EMAC1PHYPOWERDOWN_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYSYNCACQSTATUS,
	GlitchData    => EMAC1PHYSYNCACQSTATUS_GlitchData,
	OutSignalName => "EMAC1PHYSYNCACQSTATUS",
	OutTemp       => EMAC1PHYSYNCACQSTATUS_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYSYNCACQSTATUS,
	GlitchData    => EMAC1PHYSYNCACQSTATUS_GlitchData,
	OutSignalName => "EMAC1PHYSYNCACQSTATUS",
	OutTemp       => EMAC1PHYSYNCACQSTATUS_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYSYNCACQSTATUS,
	GlitchData    => EMAC1PHYSYNCACQSTATUS_GlitchData,
	OutSignalName => "EMAC1PHYSYNCACQSTATUS",
	OutTemp       => EMAC1PHYSYNCACQSTATUS_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARDISPMODE,
	GlitchData    => EMAC1PHYTXCHARDISPMODE_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARDISPMODE",
	OutTemp       => EMAC1PHYTXCHARDISPMODE_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARDISPMODE,
	GlitchData    => EMAC1PHYTXCHARDISPMODE_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARDISPMODE",
	OutTemp       => EMAC1PHYTXCHARDISPMODE_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARDISPMODE,
	GlitchData    => EMAC1PHYTXCHARDISPMODE_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARDISPMODE",
	OutTemp       => EMAC1PHYTXCHARDISPMODE_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARDISPVAL,
	GlitchData    => EMAC1PHYTXCHARDISPVAL_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARDISPVAL",
	OutTemp       => EMAC1PHYTXCHARDISPVAL_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARDISPVAL,
	GlitchData    => EMAC1PHYTXCHARDISPVAL_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARDISPVAL",
	OutTemp       => EMAC1PHYTXCHARDISPVAL_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARDISPVAL,
	GlitchData    => EMAC1PHYTXCHARDISPVAL_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARDISPVAL",
	OutTemp       => EMAC1PHYTXCHARDISPVAL_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARISK,
	GlitchData    => EMAC1PHYTXCHARISK_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARISK",
	OutTemp       => EMAC1PHYTXCHARISK_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARISK,
	GlitchData    => EMAC1PHYTXCHARISK_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARISK",
	OutTemp       => EMAC1PHYTXCHARISK_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCHARISK,
	GlitchData    => EMAC1PHYTXCHARISK_GlitchData,
	OutSignalName => "EMAC1PHYTXCHARISK",
	OutTemp       => EMAC1PHYTXCHARISK_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCLK,
	GlitchData    => EMAC1PHYTXCLK_GlitchData,
	OutSignalName => "EMAC1PHYTXCLK",
	OutTemp       => EMAC1PHYTXCLK_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCLK,
	GlitchData    => EMAC1PHYTXCLK_GlitchData,
	OutSignalName => "EMAC1PHYTXCLK",
	OutTemp       => EMAC1PHYTXCLK_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXCLK,
	GlitchData    => EMAC1PHYTXCLK_GlitchData,
	OutSignalName => "EMAC1PHYTXCLK",
	OutTemp       => EMAC1PHYTXCLK_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(0),
	GlitchData    => EMAC1PHYTXD0_GlitchData,
	OutSignalName => "EMAC1PHYTXD(0)",
	OutTemp       => EMAC1PHYTXD_OUT(0),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(0),
	GlitchData    => EMAC1PHYTXD0_GlitchData,
	OutSignalName => "EMAC1PHYTXD(0)",
	OutTemp       => EMAC1PHYTXD_OUT(0),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(0),
	GlitchData    => EMAC1PHYTXD0_GlitchData,
	OutSignalName => "EMAC1PHYTXD(0)",
	OutTemp       => EMAC1PHYTXD_OUT(0),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(1),
	GlitchData    => EMAC1PHYTXD1_GlitchData,
	OutSignalName => "EMAC1PHYTXD(1)",
	OutTemp       => EMAC1PHYTXD_OUT(1),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(1),
	GlitchData    => EMAC1PHYTXD1_GlitchData,
	OutSignalName => "EMAC1PHYTXD(1)",
	OutTemp       => EMAC1PHYTXD_OUT(1),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(1),
	GlitchData    => EMAC1PHYTXD1_GlitchData,
	OutSignalName => "EMAC1PHYTXD(1)",
	OutTemp       => EMAC1PHYTXD_OUT(1),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(2),
	GlitchData    => EMAC1PHYTXD2_GlitchData,
	OutSignalName => "EMAC1PHYTXD(2)",
	OutTemp       => EMAC1PHYTXD_OUT(2),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(2),
	GlitchData    => EMAC1PHYTXD2_GlitchData,
	OutSignalName => "EMAC1PHYTXD(2)",
	OutTemp       => EMAC1PHYTXD_OUT(2),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(2),
	GlitchData    => EMAC1PHYTXD2_GlitchData,
	OutSignalName => "EMAC1PHYTXD(2)",
	OutTemp       => EMAC1PHYTXD_OUT(2),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(3),
	GlitchData    => EMAC1PHYTXD3_GlitchData,
	OutSignalName => "EMAC1PHYTXD(3)",
	OutTemp       => EMAC1PHYTXD_OUT(3),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(3),
	GlitchData    => EMAC1PHYTXD3_GlitchData,
	OutSignalName => "EMAC1PHYTXD(3)",
	OutTemp       => EMAC1PHYTXD_OUT(3),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(3),
	GlitchData    => EMAC1PHYTXD3_GlitchData,
	OutSignalName => "EMAC1PHYTXD(3)",
	OutTemp       => EMAC1PHYTXD_OUT(3),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(4),
	GlitchData    => EMAC1PHYTXD4_GlitchData,
	OutSignalName => "EMAC1PHYTXD(4)",
	OutTemp       => EMAC1PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(4),
	GlitchData    => EMAC1PHYTXD4_GlitchData,
	OutSignalName => "EMAC1PHYTXD(4)",
	OutTemp       => EMAC1PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(4),
	GlitchData    => EMAC1PHYTXD4_GlitchData,
	OutSignalName => "EMAC1PHYTXD(4)",
	OutTemp       => EMAC1PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(4),
	GlitchData    => EMAC1PHYTXD4_GlitchData,
	OutSignalName => "EMAC1PHYTXD(4)",
	OutTemp       => EMAC1PHYTXD_OUT(4),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(5),
	GlitchData    => EMAC1PHYTXD5_GlitchData,
	OutSignalName => "EMAC1PHYTXD(5)",
	OutTemp       => EMAC1PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(5),
	GlitchData    => EMAC1PHYTXD5_GlitchData,
	OutSignalName => "EMAC1PHYTXD(5)",
	OutTemp       => EMAC1PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(5),
	GlitchData    => EMAC1PHYTXD5_GlitchData,
	OutSignalName => "EMAC1PHYTXD(5)",
	OutTemp       => EMAC1PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(5),
	GlitchData    => EMAC1PHYTXD5_GlitchData,
	OutSignalName => "EMAC1PHYTXD(5)",
	OutTemp       => EMAC1PHYTXD_OUT(5),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(6),
	GlitchData    => EMAC1PHYTXD6_GlitchData,
	OutSignalName => "EMAC1PHYTXD(6)",
	OutTemp       => EMAC1PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(6),
	GlitchData    => EMAC1PHYTXD6_GlitchData,
	OutSignalName => "EMAC1PHYTXD(6)",
	OutTemp       => EMAC1PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(6),
	GlitchData    => EMAC1PHYTXD6_GlitchData,
	OutSignalName => "EMAC1PHYTXD(6)",
	OutTemp       => EMAC1PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(6),
	GlitchData    => EMAC1PHYTXD6_GlitchData,
	OutSignalName => "EMAC1PHYTXD(6)",
	OutTemp       => EMAC1PHYTXD_OUT(6),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(7),
	GlitchData    => EMAC1PHYTXD7_GlitchData,
	OutSignalName => "EMAC1PHYTXD(7)",
	OutTemp       => EMAC1PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(7),
	GlitchData    => EMAC1PHYTXD7_GlitchData,
	OutSignalName => "EMAC1PHYTXD(7)",
	OutTemp       => EMAC1PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(7),
	GlitchData    => EMAC1PHYTXD7_GlitchData,
	OutSignalName => "EMAC1PHYTXD(7)",
	OutTemp       => EMAC1PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXD(7),
	GlitchData    => EMAC1PHYTXD7_GlitchData,
	OutSignalName => "EMAC1PHYTXD(7)",
	OutTemp       => EMAC1PHYTXD_OUT(7),
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXEN,
	GlitchData    => EMAC1PHYTXEN_GlitchData,
	OutSignalName => "EMAC1PHYTXEN",
	OutTemp       => EMAC1PHYTXEN_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXEN,
	GlitchData    => EMAC1PHYTXEN_GlitchData,
	OutSignalName => "EMAC1PHYTXEN",
	OutTemp       => EMAC1PHYTXEN_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXEN,
	GlitchData    => EMAC1PHYTXEN_GlitchData,
	OutSignalName => "EMAC1PHYTXEN",
	OutTemp       => EMAC1PHYTXEN_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXER,
	GlitchData    => EMAC1PHYTXER_GlitchData,
	OutSignalName => "EMAC1PHYTXER",
	OutTemp       => EMAC1PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXER,
	GlitchData    => EMAC1PHYTXER_GlitchData,
	OutSignalName => "EMAC1PHYTXER",
	OutTemp       => EMAC1PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXER,
	GlitchData    => EMAC1PHYTXER_GlitchData,
	OutSignalName => "EMAC1PHYTXER",
	OutTemp       => EMAC1PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1PHYTXER,
	GlitchData    => EMAC1PHYTXER_GlitchData,
	OutSignalName => "EMAC1PHYTXER",
	OutTemp       => EMAC1PHYTXER_OUT,
	Paths         => (0 => (PHYEMAC1TXGMIIMIICLKIN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMAC1SPEEDIS10100,
	GlitchData    => EMAC1SPEEDIS10100_GlitchData,
	OutSignalName => "EMAC1SPEEDIS10100",
	OutTemp       => EMAC1SPEEDIS10100_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRACK,
	GlitchData    => EMACDCRACK_GlitchData,
	OutSignalName => "EMACDCRACK",
	OutTemp       => EMACDCRACK_OUT,
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(0),
	GlitchData    => EMACDCRDBUS0_GlitchData,
	OutSignalName => "EMACDCRDBUS(0)",
	OutTemp       => EMACDCRDBUS_OUT(0),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(1),
	GlitchData    => EMACDCRDBUS1_GlitchData,
	OutSignalName => "EMACDCRDBUS(1)",
	OutTemp       => EMACDCRDBUS_OUT(1),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(2),
	GlitchData    => EMACDCRDBUS2_GlitchData,
	OutSignalName => "EMACDCRDBUS(2)",
	OutTemp       => EMACDCRDBUS_OUT(2),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(3),
	GlitchData    => EMACDCRDBUS3_GlitchData,
	OutSignalName => "EMACDCRDBUS(3)",
	OutTemp       => EMACDCRDBUS_OUT(3),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(4),
	GlitchData    => EMACDCRDBUS4_GlitchData,
	OutSignalName => "EMACDCRDBUS(4)",
	OutTemp       => EMACDCRDBUS_OUT(4),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(5),
	GlitchData    => EMACDCRDBUS5_GlitchData,
	OutSignalName => "EMACDCRDBUS(5)",
	OutTemp       => EMACDCRDBUS_OUT(5),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(6),
	GlitchData    => EMACDCRDBUS6_GlitchData,
	OutSignalName => "EMACDCRDBUS(6)",
	OutTemp       => EMACDCRDBUS_OUT(6),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(7),
	GlitchData    => EMACDCRDBUS7_GlitchData,
	OutSignalName => "EMACDCRDBUS(7)",
	OutTemp       => EMACDCRDBUS_OUT(7),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(8),
	GlitchData    => EMACDCRDBUS8_GlitchData,
	OutSignalName => "EMACDCRDBUS(8)",
	OutTemp       => EMACDCRDBUS_OUT(8),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(9),
	GlitchData    => EMACDCRDBUS9_GlitchData,
	OutSignalName => "EMACDCRDBUS(9)",
	OutTemp       => EMACDCRDBUS_OUT(9),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(10),
	GlitchData    => EMACDCRDBUS10_GlitchData,
	OutSignalName => "EMACDCRDBUS(10)",
	OutTemp       => EMACDCRDBUS_OUT(10),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(11),
	GlitchData    => EMACDCRDBUS11_GlitchData,
	OutSignalName => "EMACDCRDBUS(11)",
	OutTemp       => EMACDCRDBUS_OUT(11),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(12),
	GlitchData    => EMACDCRDBUS12_GlitchData,
	OutSignalName => "EMACDCRDBUS(12)",
	OutTemp       => EMACDCRDBUS_OUT(12),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(13),
	GlitchData    => EMACDCRDBUS13_GlitchData,
	OutSignalName => "EMACDCRDBUS(13)",
	OutTemp       => EMACDCRDBUS_OUT(13),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(14),
	GlitchData    => EMACDCRDBUS14_GlitchData,
	OutSignalName => "EMACDCRDBUS(14)",
	OutTemp       => EMACDCRDBUS_OUT(14),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(15),
	GlitchData    => EMACDCRDBUS15_GlitchData,
	OutSignalName => "EMACDCRDBUS(15)",
	OutTemp       => EMACDCRDBUS_OUT(15),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(16),
	GlitchData    => EMACDCRDBUS16_GlitchData,
	OutSignalName => "EMACDCRDBUS(16)",
	OutTemp       => EMACDCRDBUS_OUT(16),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(17),
	GlitchData    => EMACDCRDBUS17_GlitchData,
	OutSignalName => "EMACDCRDBUS(17)",
	OutTemp       => EMACDCRDBUS_OUT(17),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(18),
	GlitchData    => EMACDCRDBUS18_GlitchData,
	OutSignalName => "EMACDCRDBUS(18)",
	OutTemp       => EMACDCRDBUS_OUT(18),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(19),
	GlitchData    => EMACDCRDBUS19_GlitchData,
	OutSignalName => "EMACDCRDBUS(19)",
	OutTemp       => EMACDCRDBUS_OUT(19),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(20),
	GlitchData    => EMACDCRDBUS20_GlitchData,
	OutSignalName => "EMACDCRDBUS(20)",
	OutTemp       => EMACDCRDBUS_OUT(20),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(21),
	GlitchData    => EMACDCRDBUS21_GlitchData,
	OutSignalName => "EMACDCRDBUS(21)",
	OutTemp       => EMACDCRDBUS_OUT(21),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(22),
	GlitchData    => EMACDCRDBUS22_GlitchData,
	OutSignalName => "EMACDCRDBUS(22)",
	OutTemp       => EMACDCRDBUS_OUT(22),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(23),
	GlitchData    => EMACDCRDBUS23_GlitchData,
	OutSignalName => "EMACDCRDBUS(23)",
	OutTemp       => EMACDCRDBUS_OUT(23),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(24),
	GlitchData    => EMACDCRDBUS24_GlitchData,
	OutSignalName => "EMACDCRDBUS(24)",
	OutTemp       => EMACDCRDBUS_OUT(24),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(25),
	GlitchData    => EMACDCRDBUS25_GlitchData,
	OutSignalName => "EMACDCRDBUS(25)",
	OutTemp       => EMACDCRDBUS_OUT(25),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(26),
	GlitchData    => EMACDCRDBUS26_GlitchData,
	OutSignalName => "EMACDCRDBUS(26)",
	OutTemp       => EMACDCRDBUS_OUT(26),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(27),
	GlitchData    => EMACDCRDBUS27_GlitchData,
	OutSignalName => "EMACDCRDBUS(27)",
	OutTemp       => EMACDCRDBUS_OUT(27),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(28),
	GlitchData    => EMACDCRDBUS28_GlitchData,
	OutSignalName => "EMACDCRDBUS(28)",
	OutTemp       => EMACDCRDBUS_OUT(28),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(29),
	GlitchData    => EMACDCRDBUS29_GlitchData,
	OutSignalName => "EMACDCRDBUS(29)",
	OutTemp       => EMACDCRDBUS_OUT(29),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(30),
	GlitchData    => EMACDCRDBUS30_GlitchData,
	OutSignalName => "EMACDCRDBUS(30)",
	OutTemp       => EMACDCRDBUS_OUT(30),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => EMACDCRDBUS(31),
	GlitchData    => EMACDCRDBUS31_GlitchData,
	OutSignalName => "EMACDCRDBUS(31)",
	OutTemp       => EMACDCRDBUS_OUT(31),
	Paths         => (0 => (DCREMACCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTMIIMRDY,
	GlitchData    => HOSTMIIMRDY_GlitchData,
	OutSignalName => "HOSTMIIMRDY",
	OutTemp       => HOSTMIIMRDY_OUT,
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(0),
	GlitchData    => HOSTRDDATA0_GlitchData,
	OutSignalName => "HOSTRDDATA(0)",
	OutTemp       => HOSTRDDATA_OUT(0),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(1),
	GlitchData    => HOSTRDDATA1_GlitchData,
	OutSignalName => "HOSTRDDATA(1)",
	OutTemp       => HOSTRDDATA_OUT(1),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(2),
	GlitchData    => HOSTRDDATA2_GlitchData,
	OutSignalName => "HOSTRDDATA(2)",
	OutTemp       => HOSTRDDATA_OUT(2),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(3),
	GlitchData    => HOSTRDDATA3_GlitchData,
	OutSignalName => "HOSTRDDATA(3)",
	OutTemp       => HOSTRDDATA_OUT(3),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(4),
	GlitchData    => HOSTRDDATA4_GlitchData,
	OutSignalName => "HOSTRDDATA(4)",
	OutTemp       => HOSTRDDATA_OUT(4),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(5),
	GlitchData    => HOSTRDDATA5_GlitchData,
	OutSignalName => "HOSTRDDATA(5)",
	OutTemp       => HOSTRDDATA_OUT(5),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(6),
	GlitchData    => HOSTRDDATA6_GlitchData,
	OutSignalName => "HOSTRDDATA(6)",
	OutTemp       => HOSTRDDATA_OUT(6),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(7),
	GlitchData    => HOSTRDDATA7_GlitchData,
	OutSignalName => "HOSTRDDATA(7)",
	OutTemp       => HOSTRDDATA_OUT(7),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(8),
	GlitchData    => HOSTRDDATA8_GlitchData,
	OutSignalName => "HOSTRDDATA(8)",
	OutTemp       => HOSTRDDATA_OUT(8),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(9),
	GlitchData    => HOSTRDDATA9_GlitchData,
	OutSignalName => "HOSTRDDATA(9)",
	OutTemp       => HOSTRDDATA_OUT(9),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(10),
	GlitchData    => HOSTRDDATA10_GlitchData,
	OutSignalName => "HOSTRDDATA(10)",
	OutTemp       => HOSTRDDATA_OUT(10),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(11),
	GlitchData    => HOSTRDDATA11_GlitchData,
	OutSignalName => "HOSTRDDATA(11)",
	OutTemp       => HOSTRDDATA_OUT(11),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(12),
	GlitchData    => HOSTRDDATA12_GlitchData,
	OutSignalName => "HOSTRDDATA(12)",
	OutTemp       => HOSTRDDATA_OUT(12),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(13),
	GlitchData    => HOSTRDDATA13_GlitchData,
	OutSignalName => "HOSTRDDATA(13)",
	OutTemp       => HOSTRDDATA_OUT(13),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(14),
	GlitchData    => HOSTRDDATA14_GlitchData,
	OutSignalName => "HOSTRDDATA(14)",
	OutTemp       => HOSTRDDATA_OUT(14),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(15),
	GlitchData    => HOSTRDDATA15_GlitchData,
	OutSignalName => "HOSTRDDATA(15)",
	OutTemp       => HOSTRDDATA_OUT(15),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(16),
	GlitchData    => HOSTRDDATA16_GlitchData,
	OutSignalName => "HOSTRDDATA(16)",
	OutTemp       => HOSTRDDATA_OUT(16),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(17),
	GlitchData    => HOSTRDDATA17_GlitchData,
	OutSignalName => "HOSTRDDATA(17)",
	OutTemp       => HOSTRDDATA_OUT(17),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(18),
	GlitchData    => HOSTRDDATA18_GlitchData,
	OutSignalName => "HOSTRDDATA(18)",
	OutTemp       => HOSTRDDATA_OUT(18),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(19),
	GlitchData    => HOSTRDDATA19_GlitchData,
	OutSignalName => "HOSTRDDATA(19)",
	OutTemp       => HOSTRDDATA_OUT(19),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(20),
	GlitchData    => HOSTRDDATA20_GlitchData,
	OutSignalName => "HOSTRDDATA(20)",
	OutTemp       => HOSTRDDATA_OUT(20),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(21),
	GlitchData    => HOSTRDDATA21_GlitchData,
	OutSignalName => "HOSTRDDATA(21)",
	OutTemp       => HOSTRDDATA_OUT(21),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(22),
	GlitchData    => HOSTRDDATA22_GlitchData,
	OutSignalName => "HOSTRDDATA(22)",
	OutTemp       => HOSTRDDATA_OUT(22),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(23),
	GlitchData    => HOSTRDDATA23_GlitchData,
	OutSignalName => "HOSTRDDATA(23)",
	OutTemp       => HOSTRDDATA_OUT(23),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(24),
	GlitchData    => HOSTRDDATA24_GlitchData,
	OutSignalName => "HOSTRDDATA(24)",
	OutTemp       => HOSTRDDATA_OUT(24),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(25),
	GlitchData    => HOSTRDDATA25_GlitchData,
	OutSignalName => "HOSTRDDATA(25)",
	OutTemp       => HOSTRDDATA_OUT(25),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(26),
	GlitchData    => HOSTRDDATA26_GlitchData,
	OutSignalName => "HOSTRDDATA(26)",
	OutTemp       => HOSTRDDATA_OUT(26),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(27),
	GlitchData    => HOSTRDDATA27_GlitchData,
	OutSignalName => "HOSTRDDATA(27)",
	OutTemp       => HOSTRDDATA_OUT(27),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(28),
	GlitchData    => HOSTRDDATA28_GlitchData,
	OutSignalName => "HOSTRDDATA(28)",
	OutTemp       => HOSTRDDATA_OUT(28),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(29),
	GlitchData    => HOSTRDDATA29_GlitchData,
	OutSignalName => "HOSTRDDATA(29)",
	OutTemp       => HOSTRDDATA_OUT(29),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(30),
	GlitchData    => HOSTRDDATA30_GlitchData,
	OutSignalName => "HOSTRDDATA(30)",
	OutTemp       => HOSTRDDATA_OUT(30),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => HOSTRDDATA(31),
	GlitchData    => HOSTRDDATA31_GlitchData,
	OutSignalName => "HOSTRDDATA(31)",
	OutTemp       => HOSTRDDATA_OUT(31),
	Paths         => (0 => (HOSTCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);


  wait on
     	DCRHOSTDONEIR_out,
	EMAC0CLIENTANINTERRUPT_out,
	EMAC0CLIENTRXBADFRAME_out,
	EMAC0CLIENTRXCLIENTCLKOUT_out,
	EMAC0CLIENTRXDVLDMSW_out,
	EMAC0CLIENTRXDVLD_out,
	EMAC0CLIENTRXD_out,
	EMAC0CLIENTRXFRAMEDROP_out,
	EMAC0CLIENTRXGOODFRAME_out,
	EMAC0CLIENTRXSTATSBYTEVLD_out,
	EMAC0CLIENTRXSTATSVLD_out,
	EMAC0CLIENTRXSTATS_out,
	EMAC0CLIENTTXACK_out,
	EMAC0CLIENTTXCLIENTCLKOUT_out,
	EMAC0CLIENTTXCOLLISION_out,
	EMAC0CLIENTTXRETRANSMIT_out,
	EMAC0CLIENTTXSTATSBYTEVLD_out,
	EMAC0CLIENTTXSTATSVLD_out,
	EMAC0CLIENTTXSTATS_out,
	EMAC0PHYENCOMMAALIGN_out,
	EMAC0PHYLOOPBACKMSB_out,
	EMAC0PHYMCLKOUT_out,
	EMAC0PHYMDOUT_out,
	EMAC0PHYMDTRI_out,
	EMAC0PHYMGTRXRESET_out,
	EMAC0PHYMGTTXRESET_out,
	EMAC0PHYPOWERDOWN_out,
	EMAC0PHYSYNCACQSTATUS_out,
	EMAC0PHYTXCHARDISPMODE_out,
	EMAC0PHYTXCHARDISPVAL_out,
	EMAC0PHYTXCHARISK_out,
	EMAC0PHYTXCLK_out,
	EMAC0PHYTXD_out,
	EMAC0PHYTXEN_out,
	EMAC0PHYTXER_out,
	EMAC0PHYTXGMIIMIICLKOUT_out,
	EMAC0SPEEDIS10100_out,
	EMAC1CLIENTANINTERRUPT_out,
	EMAC1CLIENTRXBADFRAME_out,
	EMAC1CLIENTRXCLIENTCLKOUT_out,
	EMAC1CLIENTRXDVLDMSW_out,
	EMAC1CLIENTRXDVLD_out,
	EMAC1CLIENTRXD_out,
	EMAC1CLIENTRXFRAMEDROP_out,
	EMAC1CLIENTRXGOODFRAME_out,
	EMAC1CLIENTRXSTATSBYTEVLD_out,
	EMAC1CLIENTRXSTATSVLD_out,
	EMAC1CLIENTRXSTATS_out,
	EMAC1CLIENTTXACK_out,
	EMAC1CLIENTTXCLIENTCLKOUT_out,
	EMAC1CLIENTTXCOLLISION_out,
	EMAC1CLIENTTXRETRANSMIT_out,
	EMAC1CLIENTTXSTATSBYTEVLD_out,
	EMAC1CLIENTTXSTATSVLD_out,
	EMAC1CLIENTTXSTATS_out,
	EMAC1PHYENCOMMAALIGN_out,
	EMAC1PHYLOOPBACKMSB_out,
	EMAC1PHYMCLKOUT_out,
	EMAC1PHYMDOUT_out,
	EMAC1PHYMDTRI_out,
	EMAC1PHYMGTRXRESET_out,
	EMAC1PHYMGTTXRESET_out,
	EMAC1PHYPOWERDOWN_out,
	EMAC1PHYSYNCACQSTATUS_out,
	EMAC1PHYTXCHARDISPMODE_out,
	EMAC1PHYTXCHARDISPVAL_out,
	EMAC1PHYTXCHARISK_out,
	EMAC1PHYTXCLK_out,
	EMAC1PHYTXD_out,
	EMAC1PHYTXEN_out,
	EMAC1PHYTXER_out,
	EMAC1PHYTXGMIIMIICLKOUT_out,
	EMAC1SPEEDIS10100_out,
	EMACDCRACK_out,
	EMACDCRDBUS_out,
	HOSTMIIMRDY_out,
	HOSTRDDATA_out,

	CLIENTEMAC0DCMLOCKED_ipd,
	CLIENTEMAC0PAUSEREQ_ipd,
	CLIENTEMAC0PAUSEVAL_ipd,
	CLIENTEMAC0RXCLIENTCLKIN_ipd,
	CLIENTEMAC0TXCLIENTCLKIN_ipd,
	CLIENTEMAC0TXDVLDMSW_ipd,
	CLIENTEMAC0TXDVLD_ipd,
	CLIENTEMAC0TXD_ipd,
	CLIENTEMAC0TXFIRSTBYTE_ipd,
	CLIENTEMAC0TXIFGDELAY_ipd,
	CLIENTEMAC0TXUNDERRUN_ipd,
	CLIENTEMAC1DCMLOCKED_ipd,
	CLIENTEMAC1PAUSEREQ_ipd,
	CLIENTEMAC1PAUSEVAL_ipd,
	CLIENTEMAC1RXCLIENTCLKIN_ipd,
	CLIENTEMAC1TXCLIENTCLKIN_ipd,
	CLIENTEMAC1TXDVLDMSW_ipd,
	CLIENTEMAC1TXDVLD_ipd,
	CLIENTEMAC1TXD_ipd,
	CLIENTEMAC1TXFIRSTBYTE_ipd,
	CLIENTEMAC1TXIFGDELAY_ipd,
	CLIENTEMAC1TXUNDERRUN_ipd,
	DCREMACABUS_ipd,
	DCREMACCLK_ipd,
	DCREMACDBUS_ipd,
	DCREMACENABLE_ipd,
	DCREMACREAD_ipd,
	DCREMACWRITE_ipd,
	HOSTADDR_ipd,
	HOSTCLK_ipd,
	HOSTEMAC1SEL_ipd,
	HOSTMIIMSEL_ipd,
	HOSTOPCODE_ipd,
	HOSTREQ_ipd,
	HOSTWRDATA_ipd,
	PHYEMAC0COL_ipd,
	PHYEMAC0CRS_ipd,
	PHYEMAC0GTXCLK_ipd,
	PHYEMAC0MCLKIN_ipd,
	PHYEMAC0MDIN_ipd,
	PHYEMAC0MIITXCLK_ipd,
	PHYEMAC0PHYAD_ipd,
	PHYEMAC0RXBUFERR_ipd,
	PHYEMAC0RXBUFSTATUS_ipd,
	PHYEMAC0RXCHARISCOMMA_ipd,
	PHYEMAC0RXCHARISK_ipd,
	PHYEMAC0RXCHECKINGCRC_ipd,
	PHYEMAC0RXCLKCORCNT_ipd,
	PHYEMAC0RXCLK_ipd,
	PHYEMAC0RXCOMMADET_ipd,
	PHYEMAC0RXDISPERR_ipd,
	PHYEMAC0RXDV_ipd,
	PHYEMAC0RXD_ipd,
	PHYEMAC0RXER_ipd,
	PHYEMAC0RXLOSSOFSYNC_ipd,
	PHYEMAC0RXNOTINTABLE_ipd,
	PHYEMAC0RXRUNDISP_ipd,
	PHYEMAC0SIGNALDET_ipd,
	PHYEMAC0TXBUFERR_ipd,
	PHYEMAC0TXGMIIMIICLKIN_ipd,
	PHYEMAC1COL_ipd,
	PHYEMAC1CRS_ipd,
	PHYEMAC1GTXCLK_ipd,
	PHYEMAC1MCLKIN_ipd,
	PHYEMAC1MDIN_ipd,
	PHYEMAC1MIITXCLK_ipd,
	PHYEMAC1PHYAD_ipd,
	PHYEMAC1RXBUFERR_ipd,
	PHYEMAC1RXBUFSTATUS_ipd,
	PHYEMAC1RXCHARISCOMMA_ipd,
	PHYEMAC1RXCHARISK_ipd,
	PHYEMAC1RXCHECKINGCRC_ipd,
	PHYEMAC1RXCLKCORCNT_ipd,
	PHYEMAC1RXCLK_ipd,
	PHYEMAC1RXCOMMADET_ipd,
	PHYEMAC1RXDISPERR_ipd,
	PHYEMAC1RXDV_ipd,
	PHYEMAC1RXD_ipd,
	PHYEMAC1RXER_ipd,
	PHYEMAC1RXLOSSOFSYNC_ipd,
	PHYEMAC1RXNOTINTABLE_ipd,
	PHYEMAC1RXRUNDISP_ipd,
	PHYEMAC1SIGNALDET_ipd,
	PHYEMAC1TXBUFERR_ipd,
	PHYEMAC1TXGMIIMIICLKIN_ipd,
	RESET_ipd;

	end process TIMING;
end TEMAC_V;
