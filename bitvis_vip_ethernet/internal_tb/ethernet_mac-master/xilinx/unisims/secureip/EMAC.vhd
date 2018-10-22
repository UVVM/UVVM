----- CELL EMAC -----
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Ethernet Media Access Controller
-- /___/   /\     Filename : EMAC.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    10/04/05 - Fixed CR#217767. Fixed connectivity for three output ports EMACDCRACK, EMACDCRDBUS and DCRHOSTDONEIR
--    12/07/07 - Fixed CR#455025. Added delays for 16 bit client mode
--    02/04/08 - Fixed CR#460680. Changed delay to 125ps
--    09/11/08 - Fixed CR#476740. Added 10 ps delay to dcremacclk.
--    01/22/09 - Fixed CR#504192,3. Changed delays to 50,0 ps.
-- End Revision

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity EMAC is
generic (
		IN_DELAY : time := 0 ps;
		OUT_DELAY : VitalDelayType01 := (100 ps, 100 ps)


--  clk-to-output path delays

  );

port (
		DCRHOSTDONEIR : out std_ulogic;
		EMAC0CLIENTANINTERRUPT : out std_ulogic;
		EMAC0CLIENTRXBADFRAME : out std_ulogic;
		EMAC0CLIENTRXCLIENTCLKOUT : out std_ulogic;
		EMAC0CLIENTRXD : out std_logic_vector(15 downto 0);
		EMAC0CLIENTRXDVLD : out std_ulogic;
		EMAC0CLIENTRXDVLDMSW : out std_ulogic;
		EMAC0CLIENTRXDVREG6 : out std_ulogic;
		EMAC0CLIENTRXFRAMEDROP : out std_ulogic;
		EMAC0CLIENTRXGOODFRAME : out std_ulogic;
		EMAC0CLIENTRXSTATS : out std_logic_vector(6 downto 0);
		EMAC0CLIENTRXSTATSBYTEVLD : out std_ulogic;
		EMAC0CLIENTRXSTATSVLD : out std_ulogic;
		EMAC0CLIENTTXACK : out std_ulogic;
		EMAC0CLIENTTXCLIENTCLKOUT : out std_ulogic;
		EMAC0CLIENTTXCOLLISION : out std_ulogic;
		EMAC0CLIENTTXGMIIMIICLKOUT : out std_ulogic;
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
		EMAC1CLIENTANINTERRUPT : out std_ulogic;
		EMAC1CLIENTRXBADFRAME : out std_ulogic;
		EMAC1CLIENTRXCLIENTCLKOUT : out std_ulogic;
		EMAC1CLIENTRXD : out std_logic_vector(15 downto 0);
		EMAC1CLIENTRXDVLD : out std_ulogic;
		EMAC1CLIENTRXDVLDMSW : out std_ulogic;
		EMAC1CLIENTRXDVREG6 : out std_ulogic;
		EMAC1CLIENTRXFRAMEDROP : out std_ulogic;
		EMAC1CLIENTRXGOODFRAME : out std_ulogic;
		EMAC1CLIENTRXSTATS : out std_logic_vector(6 downto 0);
		EMAC1CLIENTRXSTATSBYTEVLD : out std_ulogic;
		EMAC1CLIENTRXSTATSVLD : out std_ulogic;
		EMAC1CLIENTTXACK : out std_ulogic;
		EMAC1CLIENTTXCLIENTCLKOUT : out std_ulogic;
		EMAC1CLIENTTXCOLLISION : out std_ulogic;
		EMAC1CLIENTTXGMIIMIICLKOUT : out std_ulogic;
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
		CLIENTEMAC0TXGMIIMIICLKIN : in std_ulogic;
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
		CLIENTEMAC1TXGMIIMIICLKIN : in std_ulogic;
		CLIENTEMAC1TXIFGDELAY : in std_logic_vector(7 downto 0);
		CLIENTEMAC1TXUNDERRUN : in std_ulogic;
		DCREMACABUS : in std_logic_vector(8 to 9);
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
		RESET : in std_ulogic;
		TIEEMAC0CONFIGVEC : in std_logic_vector(79 downto 0);
		TIEEMAC0UNICASTADDR : in std_logic_vector(47 downto 0);
		TIEEMAC1CONFIGVEC : in std_logic_vector(79 downto 0);
		TIEEMAC1UNICASTADDR : in std_logic_vector(47 downto 0)
     );
end EMAC;

-- Architecture body --

architecture EMAC_V of EMAC is

  component EMAC_SWIFT
    port (
      DCRHOSTDONEIR        : out std_ulogic;
      EMAC0CLIENTANINTERRUPT : out std_ulogic;
      EMAC0CLIENTRXBADFRAME : out std_ulogic;
      EMAC0CLIENTRXCLIENTCLKOUT : out std_ulogic;
      EMAC0CLIENTRXD       : out std_logic_vector(15 downto 0);
      EMAC0CLIENTRXDVLD    : out std_ulogic;
      EMAC0CLIENTRXDVLDMSW : out std_ulogic;
      EMAC0CLIENTRXDVREG6  : out std_ulogic;
      EMAC0CLIENTRXFRAMEDROP : out std_ulogic;
      EMAC0CLIENTRXGOODFRAME : out std_ulogic;
      EMAC0CLIENTRXSTATS   : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSBYTEVLD : out std_ulogic;
      EMAC0CLIENTRXSTATSVLD : out std_ulogic;
      EMAC0CLIENTTXACK     : out std_ulogic;
      EMAC0CLIENTTXCLIENTCLKOUT : out std_ulogic;
      EMAC0CLIENTTXCOLLISION : out std_ulogic;
      EMAC0CLIENTTXGMIIMIICLKOUT : out std_ulogic;
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
      EMAC1CLIENTANINTERRUPT : out std_ulogic;
      EMAC1CLIENTRXBADFRAME : out std_ulogic;
      EMAC1CLIENTRXCLIENTCLKOUT : out std_ulogic;
      EMAC1CLIENTRXD       : out std_logic_vector(15 downto 0);
      EMAC1CLIENTRXDVLD    : out std_ulogic;
      EMAC1CLIENTRXDVLDMSW : out std_ulogic;
      EMAC1CLIENTRXDVREG6  : out std_ulogic;
      EMAC1CLIENTRXFRAMEDROP : out std_ulogic;
      EMAC1CLIENTRXGOODFRAME : out std_ulogic;
      EMAC1CLIENTRXSTATS   : out std_logic_vector(6 downto 0);
      EMAC1CLIENTRXSTATSBYTEVLD : out std_ulogic;
      EMAC1CLIENTRXSTATSVLD : out std_ulogic;
      EMAC1CLIENTTXACK     : out std_ulogic;
      EMAC1CLIENTTXCLIENTCLKOUT : out std_ulogic;
      EMAC1CLIENTTXCOLLISION : out std_ulogic;
      EMAC1CLIENTTXGMIIMIICLKOUT : out std_ulogic;
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
      CLIENTEMAC0TXGMIIMIICLKIN : in std_ulogic;
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
      CLIENTEMAC1TXGMIIMIICLKIN : in std_ulogic;
      CLIENTEMAC1TXIFGDELAY : in std_logic_vector(7 downto 0);
      CLIENTEMAC1TXUNDERRUN : in std_ulogic;
      DCREMACABUS          : in std_logic_vector(8 to 9);
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
      RESET                : in std_ulogic;
      TIEEMAC0CONFIGVEC    : in std_logic_vector(79 downto 0);
      TIEEMAC0UNICASTADDR  : in std_logic_vector(47 downto 0);
      TIEEMAC1CONFIGVEC    : in std_logic_vector(79 downto 0);
      TIEEMAC1UNICASTADDR  : in std_logic_vector(47 downto 0)

    );
  end component;

        -- CR 455025 -- Delay wrapper for 16-bit client mode
        signal PHYEMAC0MIITXCLK_delay : std_ulogic;
        signal CLIENTEMAC0TXD_delay : std_logic_vector(15 downto 0);
        signal CLIENTEMAC0TXDVLD_delay : std_ulogic;
        signal CLIENTEMAC0TXDVLDMSW_delay : std_ulogic;
        signal PHYEMAC0MIITXCLK_skewed : std_ulogic;
        signal CLIENTEMAC0TXD_client16_delay : std_logic_vector(15 downto 0);
        signal CLIENTEMAC0TXDVLD_client16_delay : std_ulogic;
        signal CLIENTEMAC0TXDVLDMSW_client16_delay : std_ulogic;

        signal PHYEMAC1MIITXCLK_delay : std_ulogic;
        signal CLIENTEMAC1TXD_delay : std_logic_vector(15 downto 0);
        signal CLIENTEMAC1TXDVLD_delay : std_ulogic;
        signal CLIENTEMAC1TXDVLDMSW_delay : std_ulogic;
        signal PHYEMAC1MIITXCLK_skewed : std_ulogic;
        signal CLIENTEMAC1TXD_client16_delay : std_logic_vector(15 downto 0);
        signal CLIENTEMAC1TXDVLD_client16_delay : std_ulogic;
        signal CLIENTEMAC1TXDVLDMSW_client16_delay : std_ulogic;

        constant client_in_delay : time := 50 ps;
        constant miitxclk_delay : time := 0 ps; 

        signal dcremacclk_delay : std_ulogic;
-- Attribute-to-Cell mapping signals

-- Input/Output Pin signals

        signal   CLIENTEMAC0DCMLOCKED_ipd  :  std_ulogic;
        signal   CLIENTEMAC0PAUSEREQ_ipd  :  std_ulogic;
        signal   CLIENTEMAC0PAUSEVAL_ipd  :  std_logic_vector(15 downto 0);
        signal   CLIENTEMAC0RXCLIENTCLKIN_ipd  :  std_ulogic;
        signal   CLIENTEMAC0TXCLIENTCLKIN_ipd  :  std_ulogic;
        signal   CLIENTEMAC0TXD_ipd  :  std_logic_vector(15 downto 0);
        signal   CLIENTEMAC0TXDVLD_ipd  :  std_ulogic;
        signal   CLIENTEMAC0TXDVLDMSW_ipd  :  std_ulogic;
        signal   CLIENTEMAC0TXFIRSTBYTE_ipd  :  std_ulogic;
        signal   CLIENTEMAC0TXGMIIMIICLKIN_ipd  :  std_ulogic;
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
        signal   CLIENTEMAC1TXGMIIMIICLKIN_ipd  :  std_ulogic;
        signal   CLIENTEMAC1TXIFGDELAY_ipd  :  std_logic_vector(7 downto 0);
        signal   CLIENTEMAC1TXUNDERRUN_ipd  :  std_ulogic;
        signal   DCREMACENABLE_ipd  :  std_ulogic;
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
        signal   TIEEMAC0CONFIGVEC_ipd  :  std_logic_vector(79 downto 0);
        signal   TIEEMAC0UNICASTADDR_ipd  :  std_logic_vector(47 downto 0);
        signal   TIEEMAC1CONFIGVEC_ipd  :  std_logic_vector(79 downto 0);
        signal   TIEEMAC1UNICASTADDR_ipd  :  std_logic_vector(47 downto 0);
        signal   DCREMACWRITE_ipd  :  std_ulogic;
        signal   DCREMACREAD_ipd  :  std_ulogic;
        signal   DCREMACDBUS_ipd  :  std_logic_vector(0 to 31);
        signal   DCREMACABUS_ipd  :  std_logic_vector(8 to 9);
        signal   DCREMACCLK_ipd  :  std_ulogic;

        signal   DCRHOSTDONEIR_out  :  std_ulogic;
        signal   EMAC0CLIENTANINTERRUPT_out  :  std_ulogic;
        signal   EMAC0CLIENTRXBADFRAME_out  :  std_ulogic;
        signal   EMAC0CLIENTRXCLIENTCLKOUT_out  :  std_ulogic;
        signal   EMAC0CLIENTRXD_out  :  std_logic_vector(15 downto 0);
        signal   EMAC0CLIENTRXDVLD_out  :  std_ulogic;
        signal   EMAC0CLIENTRXDVLDMSW_out  :  std_ulogic;
        signal   EMAC0CLIENTRXDVREG6_out  :  std_ulogic;
        signal   EMAC0CLIENTRXFRAMEDROP_out  :  std_ulogic;
        signal   EMAC0CLIENTRXGOODFRAME_out  :  std_ulogic;
        signal   EMAC0CLIENTRXSTATS_out  :  std_logic_vector(6 downto 0);
        signal   EMAC0CLIENTRXSTATSBYTEVLD_out  :  std_ulogic;
        signal   EMAC0CLIENTRXSTATSVLD_out  :  std_ulogic;
        signal   EMAC0CLIENTTXACK_out  :  std_ulogic;
        signal   EMAC0CLIENTTXCLIENTCLKOUT_out  :  std_ulogic;
        signal   EMAC0CLIENTTXCOLLISION_out  :  std_ulogic;
        signal   EMAC0CLIENTTXGMIIMIICLKOUT_out  :  std_ulogic;
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
        signal   EMAC1CLIENTANINTERRUPT_out  :  std_ulogic;
        signal   EMAC1CLIENTRXBADFRAME_out  :  std_ulogic;
        signal   EMAC1CLIENTRXCLIENTCLKOUT_out  :  std_ulogic;
        signal   EMAC1CLIENTRXD_out  :  std_logic_vector(15 downto 0);
        signal   EMAC1CLIENTRXDVLD_out  :  std_ulogic;
        signal   EMAC1CLIENTRXDVLDMSW_out  :  std_ulogic;
        signal   EMAC1CLIENTRXDVREG6_out  :  std_ulogic;
        signal   EMAC1CLIENTRXFRAMEDROP_out  :  std_ulogic;
        signal   EMAC1CLIENTRXGOODFRAME_out  :  std_ulogic;
        signal   EMAC1CLIENTRXSTATS_out  :  std_logic_vector(6 downto 0);
        signal   EMAC1CLIENTRXSTATSBYTEVLD_out  :  std_ulogic;
        signal   EMAC1CLIENTRXSTATSVLD_out  :  std_ulogic;
        signal   EMAC1CLIENTTXACK_out  :  std_ulogic;
        signal   EMAC1CLIENTTXCLIENTCLKOUT_out  :  std_ulogic;
        signal   EMAC1CLIENTTXCOLLISION_out  :  std_ulogic;
        signal   EMAC1CLIENTTXGMIIMIICLKOUT_out  :  std_ulogic;
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
        signal   HOSTMIIMRDY_out  :  std_ulogic;
        signal   HOSTRDDATA_out  :  std_logic_vector(31 downto 0);
        signal   EMACDCRDBUS_out  :  std_logic_vector(0 to 31);
        signal   EMACDCRACK_out  :  std_ulogic;


begin
   
   CLIENTEMAC0DCMLOCKED_ipd <= CLIENTEMAC0DCMLOCKED after IN_DELAY;
   CLIENTEMAC0PAUSEREQ_ipd <= CLIENTEMAC0PAUSEREQ after IN_DELAY;
   CLIENTEMAC0PAUSEVAL_ipd <= CLIENTEMAC0PAUSEVAL after IN_DELAY;
   CLIENTEMAC0RXCLIENTCLKIN_ipd <= CLIENTEMAC0RXCLIENTCLKIN after IN_DELAY;
   CLIENTEMAC0TXCLIENTCLKIN_ipd <= CLIENTEMAC0TXCLIENTCLKIN after IN_DELAY;
   CLIENTEMAC0TXD_ipd <= CLIENTEMAC0TXD after IN_DELAY;
   CLIENTEMAC0TXDVLD_ipd <= CLIENTEMAC0TXDVLD after IN_DELAY;
   CLIENTEMAC0TXDVLDMSW_ipd <= CLIENTEMAC0TXDVLDMSW after IN_DELAY;
   CLIENTEMAC0TXFIRSTBYTE_ipd <= CLIENTEMAC0TXFIRSTBYTE after IN_DELAY;
   CLIENTEMAC0TXGMIIMIICLKIN_ipd <= CLIENTEMAC0TXGMIIMIICLKIN after IN_DELAY;
   CLIENTEMAC0TXIFGDELAY_ipd <= CLIENTEMAC0TXIFGDELAY after IN_DELAY;
   CLIENTEMAC0TXUNDERRUN_ipd <= CLIENTEMAC0TXUNDERRUN after IN_DELAY;
   CLIENTEMAC1DCMLOCKED_ipd <= CLIENTEMAC1DCMLOCKED after IN_DELAY;
   CLIENTEMAC1PAUSEREQ_ipd <= CLIENTEMAC1PAUSEREQ after IN_DELAY;
   CLIENTEMAC1PAUSEVAL_ipd <= CLIENTEMAC1PAUSEVAL after IN_DELAY;
   CLIENTEMAC1RXCLIENTCLKIN_ipd <= CLIENTEMAC1RXCLIENTCLKIN after IN_DELAY;
   CLIENTEMAC1TXCLIENTCLKIN_ipd <= CLIENTEMAC1TXCLIENTCLKIN after IN_DELAY;
   CLIENTEMAC1TXD_ipd <= CLIENTEMAC1TXD after IN_DELAY;
   CLIENTEMAC1TXDVLD_ipd <= CLIENTEMAC1TXDVLD after IN_DELAY;
   CLIENTEMAC1TXDVLDMSW_ipd <= CLIENTEMAC1TXDVLDMSW after IN_DELAY;
   CLIENTEMAC1TXFIRSTBYTE_ipd <= CLIENTEMAC1TXFIRSTBYTE after IN_DELAY;
   CLIENTEMAC1TXGMIIMIICLKIN_ipd <= CLIENTEMAC1TXGMIIMIICLKIN after IN_DELAY;
   CLIENTEMAC1TXIFGDELAY_ipd <= CLIENTEMAC1TXIFGDELAY after IN_DELAY;
   CLIENTEMAC1TXUNDERRUN_ipd <= CLIENTEMAC1TXUNDERRUN after IN_DELAY;
   DCREMACENABLE_ipd <= DCREMACENABLE after IN_DELAY;
   HOSTADDR_ipd <= HOSTADDR after IN_DELAY;
   HOSTCLK_ipd <= HOSTCLK after IN_DELAY;
   HOSTEMAC1SEL_ipd <= HOSTEMAC1SEL after IN_DELAY;
   HOSTMIIMSEL_ipd <= HOSTMIIMSEL after IN_DELAY;
   HOSTOPCODE_ipd <= HOSTOPCODE after IN_DELAY;
   HOSTREQ_ipd <= HOSTREQ after IN_DELAY;
   HOSTWRDATA_ipd <= HOSTWRDATA after IN_DELAY;
   PHYEMAC0COL_ipd <= PHYEMAC0COL after IN_DELAY;
   PHYEMAC0CRS_ipd <= PHYEMAC0CRS after IN_DELAY;
   PHYEMAC0GTXCLK_ipd <= PHYEMAC0GTXCLK after IN_DELAY;
   PHYEMAC0MCLKIN_ipd <= PHYEMAC0MCLKIN after IN_DELAY;
   PHYEMAC0MDIN_ipd <= PHYEMAC0MDIN after IN_DELAY;
   PHYEMAC0MIITXCLK_ipd <= PHYEMAC0MIITXCLK after IN_DELAY;
   PHYEMAC0PHYAD_ipd <= PHYEMAC0PHYAD after IN_DELAY;
   PHYEMAC0RXBUFERR_ipd <= PHYEMAC0RXBUFERR after IN_DELAY;
   PHYEMAC0RXBUFSTATUS_ipd <= PHYEMAC0RXBUFSTATUS after IN_DELAY;
   PHYEMAC0RXCHARISCOMMA_ipd <= PHYEMAC0RXCHARISCOMMA after IN_DELAY;
   PHYEMAC0RXCHARISK_ipd <= PHYEMAC0RXCHARISK after IN_DELAY;
   PHYEMAC0RXCHECKINGCRC_ipd <= PHYEMAC0RXCHECKINGCRC after IN_DELAY;
   PHYEMAC0RXCLK_ipd <= PHYEMAC0RXCLK after IN_DELAY;
   PHYEMAC0RXCLKCORCNT_ipd <= PHYEMAC0RXCLKCORCNT after IN_DELAY;
   PHYEMAC0RXCOMMADET_ipd <= PHYEMAC0RXCOMMADET after IN_DELAY;
   PHYEMAC0RXD_ipd <= PHYEMAC0RXD after IN_DELAY;
   PHYEMAC0RXDISPERR_ipd <= PHYEMAC0RXDISPERR after IN_DELAY;
   PHYEMAC0RXDV_ipd <= PHYEMAC0RXDV after IN_DELAY;
   PHYEMAC0RXER_ipd <= PHYEMAC0RXER after IN_DELAY;
   PHYEMAC0RXLOSSOFSYNC_ipd <= PHYEMAC0RXLOSSOFSYNC after IN_DELAY;
   PHYEMAC0RXNOTINTABLE_ipd <= PHYEMAC0RXNOTINTABLE after IN_DELAY;
   PHYEMAC0RXRUNDISP_ipd <= PHYEMAC0RXRUNDISP after IN_DELAY;
   PHYEMAC0SIGNALDET_ipd <= PHYEMAC0SIGNALDET after IN_DELAY;
   PHYEMAC0TXBUFERR_ipd <= PHYEMAC0TXBUFERR after IN_DELAY;
   PHYEMAC1COL_ipd <= PHYEMAC1COL after IN_DELAY;
   PHYEMAC1CRS_ipd <= PHYEMAC1CRS after IN_DELAY;
   PHYEMAC1GTXCLK_ipd <= PHYEMAC1GTXCLK after IN_DELAY;
   PHYEMAC1MCLKIN_ipd <= PHYEMAC1MCLKIN after IN_DELAY;
   PHYEMAC1MDIN_ipd <= PHYEMAC1MDIN after IN_DELAY;
   PHYEMAC1MIITXCLK_ipd <= PHYEMAC1MIITXCLK after IN_DELAY;
   PHYEMAC1PHYAD_ipd <= PHYEMAC1PHYAD after IN_DELAY;
   PHYEMAC1RXBUFERR_ipd <= PHYEMAC1RXBUFERR after IN_DELAY;
   PHYEMAC1RXBUFSTATUS_ipd <= PHYEMAC1RXBUFSTATUS after IN_DELAY;
   PHYEMAC1RXCHARISCOMMA_ipd <= PHYEMAC1RXCHARISCOMMA after IN_DELAY;
   PHYEMAC1RXCHARISK_ipd <= PHYEMAC1RXCHARISK after IN_DELAY;
   PHYEMAC1RXCHECKINGCRC_ipd <= PHYEMAC1RXCHECKINGCRC after IN_DELAY;
   PHYEMAC1RXCLK_ipd <= PHYEMAC1RXCLK after IN_DELAY;
   PHYEMAC1RXCLKCORCNT_ipd <= PHYEMAC1RXCLKCORCNT after IN_DELAY;
   PHYEMAC1RXCOMMADET_ipd <= PHYEMAC1RXCOMMADET after IN_DELAY;
   PHYEMAC1RXD_ipd <= PHYEMAC1RXD after IN_DELAY;
   PHYEMAC1RXDISPERR_ipd <= PHYEMAC1RXDISPERR after IN_DELAY;
   PHYEMAC1RXDV_ipd <= PHYEMAC1RXDV after IN_DELAY;
   PHYEMAC1RXER_ipd <= PHYEMAC1RXER after IN_DELAY;
   PHYEMAC1RXLOSSOFSYNC_ipd <= PHYEMAC1RXLOSSOFSYNC after IN_DELAY;
   PHYEMAC1RXNOTINTABLE_ipd <= PHYEMAC1RXNOTINTABLE after IN_DELAY;
   PHYEMAC1RXRUNDISP_ipd <= PHYEMAC1RXRUNDISP after IN_DELAY;
   PHYEMAC1SIGNALDET_ipd <= PHYEMAC1SIGNALDET after IN_DELAY;
   PHYEMAC1TXBUFERR_ipd <= PHYEMAC1TXBUFERR after IN_DELAY;
   RESET_ipd <= RESET after IN_DELAY;
   TIEEMAC0CONFIGVEC_ipd <= TIEEMAC0CONFIGVEC after IN_DELAY;
   TIEEMAC0UNICASTADDR_ipd <= TIEEMAC0UNICASTADDR after IN_DELAY;
   TIEEMAC1CONFIGVEC_ipd <= TIEEMAC1CONFIGVEC after IN_DELAY;
   TIEEMAC1UNICASTADDR_ipd <= TIEEMAC1UNICASTADDR after IN_DELAY;
   DCREMACWRITE_ipd <= DCREMACWRITE after IN_DELAY;
   DCREMACREAD_ipd <= DCREMACREAD after IN_DELAY;
   DCREMACDBUS_ipd <= DCREMACDBUS after IN_DELAY;
   DCREMACABUS_ipd <= DCREMACABUS after IN_DELAY;
   DCREMACCLK_ipd <= DCREMACCLK after IN_DELAY;

   -- CR 455025 Delay EMAC# client input signals in 16-bit client mode
   -- EMAC0
   CLIENTEMAC0TXD_delay <= CLIENTEMAC0TXD_ipd after client_in_delay;
   CLIENTEMAC0TXDVLD_delay <= CLIENTEMAC0TXDVLD_ipd after client_in_delay;
   CLIENTEMAC0TXDVLDMSW_delay <= CLIENTEMAC0TXDVLDMSW_ipd after client_in_delay;

   CLIENTEMAC0TXD_client16_delay       <= CLIENTEMAC0TXD_delay when TIEEMAC0CONFIGVEC(66) = '1' else CLIENTEMAC0TXD_ipd;        -- CONFIGVEC[66] is 16-bit Tx client 
   CLIENTEMAC0TXDVLD_client16_delay    <= CLIENTEMAC0TXDVLD_delay when TIEEMAC0CONFIGVEC(66) = '1' else CLIENTEMAC0TXDVLD_ipd;  
   CLIENTEMAC0TXDVLDMSW_client16_delay <= CLIENTEMAC0TXDVLDMSW_delay when TIEEMAC0CONFIGVEC(66) = '1' else CLIENTEMAC0TXDVLDMSW_ipd;  

   -- EMAC1
   CLIENTEMAC1TXD_delay <= CLIENTEMAC1TXD_ipd after client_in_delay;
   CLIENTEMAC1TXDVLD_delay <= CLIENTEMAC1TXDVLD_ipd after client_in_delay;
   CLIENTEMAC1TXDVLDMSW_delay <= CLIENTEMAC1TXDVLDMSW_ipd after client_in_delay;

   CLIENTEMAC1TXD_client16_delay       <= CLIENTEMAC1TXD_delay when TIEEMAC1CONFIGVEC(66) = '1' else CLIENTEMAC1TXD_ipd;        -- CONFIGVEC[66] is 16-bit Tx client 
   CLIENTEMAC1TXDVLD_client16_delay    <= CLIENTEMAC1TXDVLD_delay when TIEEMAC1CONFIGVEC(66) = '1' else CLIENTEMAC1TXDVLD_ipd;  
   CLIENTEMAC1TXDVLDMSW_client16_delay <= CLIENTEMAC1TXDVLDMSW_delay when TIEEMAC1CONFIGVEC(66) = '1' else CLIENTEMAC1TXDVLDMSW_ipd;  

  --Skew 125 MHz clock EMAC#MIITXCLK against 250 MHz clock in 16-bit client mode
   PHYEMAC0MIITXCLK_delay <= PHYEMAC0MIITXCLK_ipd after miitxclk_delay;
   PHYEMAC0MIITXCLK_skewed <= PHYEMAC0MIITXCLK_delay when TIEEMAC0CONFIGVEC(66) = '1' else PHYEMAC0MIITXCLK_ipd; -- In TXCLIENT16 mode

   PHYEMAC1MIITXCLK_delay <= PHYEMAC1MIITXCLK_ipd after miitxclk_delay;
   PHYEMAC1MIITXCLK_skewed <= PHYEMAC1MIITXCLK_delay when TIEEMAC1CONFIGVEC(66) = '1' else PHYEMAC1MIITXCLK_ipd; -- In TXCLIENT16 mode 

   dcremacclk_delay <= DCREMACCLK_ipd after 10 ps;

   emac_swift_bw_1 : EMAC_SWIFT
      port map (
          CLIENTEMAC0DCMLOCKED  =>  CLIENTEMAC0DCMLOCKED_ipd,
          CLIENTEMAC0PAUSEREQ  =>  CLIENTEMAC0PAUSEREQ_ipd,
          CLIENTEMAC0PAUSEVAL  =>  CLIENTEMAC0PAUSEVAL_ipd,
          CLIENTEMAC0RXCLIENTCLKIN  =>  CLIENTEMAC0RXCLIENTCLKIN_ipd,
          CLIENTEMAC0TXCLIENTCLKIN  =>  CLIENTEMAC0TXCLIENTCLKIN_ipd,
          CLIENTEMAC0TXD  =>  CLIENTEMAC0TXD_client16_delay,
          CLIENTEMAC0TXDVLD  =>  CLIENTEMAC0TXDVLD_client16_delay,
          CLIENTEMAC0TXDVLDMSW  =>  CLIENTEMAC0TXDVLDMSW_client16_delay,
          CLIENTEMAC0TXFIRSTBYTE  =>  CLIENTEMAC0TXFIRSTBYTE_ipd,
          CLIENTEMAC0TXGMIIMIICLKIN  =>  CLIENTEMAC0TXGMIIMIICLKIN_ipd,
          CLIENTEMAC0TXIFGDELAY  =>  CLIENTEMAC0TXIFGDELAY_ipd,
          CLIENTEMAC0TXUNDERRUN  =>  CLIENTEMAC0TXUNDERRUN_ipd,
          CLIENTEMAC1DCMLOCKED  =>  CLIENTEMAC1DCMLOCKED_ipd,
          CLIENTEMAC1PAUSEREQ  =>  CLIENTEMAC1PAUSEREQ_ipd,
          CLIENTEMAC1PAUSEVAL  =>  CLIENTEMAC1PAUSEVAL_ipd,
          CLIENTEMAC1RXCLIENTCLKIN  =>  CLIENTEMAC1RXCLIENTCLKIN_ipd,
          CLIENTEMAC1TXCLIENTCLKIN  =>  CLIENTEMAC1TXCLIENTCLKIN_ipd,
          CLIENTEMAC1TXD  =>  CLIENTEMAC1TXD_client16_delay,
          CLIENTEMAC1TXDVLD  =>  CLIENTEMAC1TXDVLD_client16_delay,
          CLIENTEMAC1TXDVLDMSW  =>  CLIENTEMAC1TXDVLDMSW_client16_delay,
          CLIENTEMAC1TXFIRSTBYTE  =>  CLIENTEMAC1TXFIRSTBYTE_ipd,
          CLIENTEMAC1TXGMIIMIICLKIN  =>  CLIENTEMAC1TXGMIIMIICLKIN_ipd,
          CLIENTEMAC1TXIFGDELAY  =>  CLIENTEMAC1TXIFGDELAY_ipd,
          CLIENTEMAC1TXUNDERRUN  =>  CLIENTEMAC1TXUNDERRUN_ipd,
          DCREMACABUS  =>  DCREMACABUS_ipd,
          DCREMACCLK  =>  dcremacclk_delay,
          DCREMACDBUS  =>  DCREMACDBUS_ipd,
          DCREMACENABLE  =>  DCREMACENABLE_ipd,
          DCREMACREAD  =>  DCREMACREAD_ipd,
          DCREMACWRITE  =>  DCREMACWRITE_ipd,
          DCRHOSTDONEIR  =>  DCRHOSTDONEIR_out,
          EMAC0CLIENTANINTERRUPT  =>  EMAC0CLIENTANINTERRUPT_out,
          EMAC0CLIENTRXBADFRAME  =>  EMAC0CLIENTRXBADFRAME_out,
          EMAC0CLIENTRXCLIENTCLKOUT  =>  EMAC0CLIENTRXCLIENTCLKOUT_out,
          EMAC0CLIENTRXD  =>  EMAC0CLIENTRXD_out,
          EMAC0CLIENTRXDVLD  =>  EMAC0CLIENTRXDVLD_out,
          EMAC0CLIENTRXDVLDMSW  =>  EMAC0CLIENTRXDVLDMSW_out,
          EMAC0CLIENTRXDVREG6  =>  EMAC0CLIENTRXDVREG6_out,
          EMAC0CLIENTRXFRAMEDROP  =>  EMAC0CLIENTRXFRAMEDROP_out,
          EMAC0CLIENTRXGOODFRAME  =>  EMAC0CLIENTRXGOODFRAME_out,
          EMAC0CLIENTRXSTATS  =>  EMAC0CLIENTRXSTATS_out,
          EMAC0CLIENTRXSTATSBYTEVLD  =>  EMAC0CLIENTRXSTATSBYTEVLD_out,
          EMAC0CLIENTRXSTATSVLD  =>  EMAC0CLIENTRXSTATSVLD_out,
          EMAC0CLIENTTXACK  =>  EMAC0CLIENTTXACK_out,
          EMAC0CLIENTTXCLIENTCLKOUT  =>  EMAC0CLIENTTXCLIENTCLKOUT_out,
          EMAC0CLIENTTXCOLLISION  =>  EMAC0CLIENTTXCOLLISION_out,
          EMAC0CLIENTTXGMIIMIICLKOUT  =>  EMAC0CLIENTTXGMIIMIICLKOUT_out,
          EMAC0CLIENTTXRETRANSMIT  =>  EMAC0CLIENTTXRETRANSMIT_out,
          EMAC0CLIENTTXSTATS  =>  EMAC0CLIENTTXSTATS_out,
          EMAC0CLIENTTXSTATSBYTEVLD  =>  EMAC0CLIENTTXSTATSBYTEVLD_out,
          EMAC0CLIENTTXSTATSVLD  =>  EMAC0CLIENTTXSTATSVLD_out,
          EMAC0PHYENCOMMAALIGN  =>  EMAC0PHYENCOMMAALIGN_out,
          EMAC0PHYLOOPBACKMSB  =>  EMAC0PHYLOOPBACKMSB_out,
          EMAC0PHYMCLKOUT  =>  EMAC0PHYMCLKOUT_out,
          EMAC0PHYMDOUT  =>  EMAC0PHYMDOUT_out,
          EMAC0PHYMDTRI  =>  EMAC0PHYMDTRI_out,
          EMAC0PHYMGTRXRESET  =>  EMAC0PHYMGTRXRESET_out,
          EMAC0PHYMGTTXRESET  =>  EMAC0PHYMGTTXRESET_out,
          EMAC0PHYPOWERDOWN  =>  EMAC0PHYPOWERDOWN_out,
          EMAC0PHYSYNCACQSTATUS  =>  EMAC0PHYSYNCACQSTATUS_out,
          EMAC0PHYTXCHARDISPMODE  =>  EMAC0PHYTXCHARDISPMODE_out,
          EMAC0PHYTXCHARDISPVAL  =>  EMAC0PHYTXCHARDISPVAL_out,
          EMAC0PHYTXCHARISK  =>  EMAC0PHYTXCHARISK_out,
          EMAC0PHYTXCLK  =>  EMAC0PHYTXCLK_out,
          EMAC0PHYTXD  =>  EMAC0PHYTXD_out,
          EMAC0PHYTXEN  =>  EMAC0PHYTXEN_out,
          EMAC0PHYTXER  =>  EMAC0PHYTXER_out,
          EMAC1CLIENTANINTERRUPT  =>  EMAC1CLIENTANINTERRUPT_out,
          EMAC1CLIENTRXBADFRAME  =>  EMAC1CLIENTRXBADFRAME_out,
          EMAC1CLIENTRXCLIENTCLKOUT  =>  EMAC1CLIENTRXCLIENTCLKOUT_out,
          EMAC1CLIENTRXD  =>  EMAC1CLIENTRXD_out,
          EMAC1CLIENTRXDVLD  =>  EMAC1CLIENTRXDVLD_out,
          EMAC1CLIENTRXDVLDMSW  =>  EMAC1CLIENTRXDVLDMSW_out,
          EMAC1CLIENTRXDVREG6  =>  EMAC1CLIENTRXDVREG6_out,
          EMAC1CLIENTRXFRAMEDROP  =>  EMAC1CLIENTRXFRAMEDROP_out,
          EMAC1CLIENTRXGOODFRAME  =>  EMAC1CLIENTRXGOODFRAME_out,
          EMAC1CLIENTRXSTATS  =>  EMAC1CLIENTRXSTATS_out,
          EMAC1CLIENTRXSTATSBYTEVLD  =>  EMAC1CLIENTRXSTATSBYTEVLD_out,
          EMAC1CLIENTRXSTATSVLD  =>  EMAC1CLIENTRXSTATSVLD_out,
          EMAC1CLIENTTXACK  =>  EMAC1CLIENTTXACK_out,
          EMAC1CLIENTTXCLIENTCLKOUT  =>  EMAC1CLIENTTXCLIENTCLKOUT_out,
          EMAC1CLIENTTXCOLLISION  =>  EMAC1CLIENTTXCOLLISION_out,
          EMAC1CLIENTTXGMIIMIICLKOUT  =>  EMAC1CLIENTTXGMIIMIICLKOUT_out,
          EMAC1CLIENTTXRETRANSMIT  =>  EMAC1CLIENTTXRETRANSMIT_out,
          EMAC1CLIENTTXSTATS  =>  EMAC1CLIENTTXSTATS_out,
          EMAC1CLIENTTXSTATSBYTEVLD  =>  EMAC1CLIENTTXSTATSBYTEVLD_out,
          EMAC1CLIENTTXSTATSVLD  =>  EMAC1CLIENTTXSTATSVLD_out,
          EMAC1PHYENCOMMAALIGN  =>  EMAC1PHYENCOMMAALIGN_out,
          EMAC1PHYLOOPBACKMSB  =>  EMAC1PHYLOOPBACKMSB_out,
          EMAC1PHYMCLKOUT  =>  EMAC1PHYMCLKOUT_out,
          EMAC1PHYMDOUT  =>  EMAC1PHYMDOUT_out,
          EMAC1PHYMDTRI  =>  EMAC1PHYMDTRI_out,
          EMAC1PHYMGTRXRESET  =>  EMAC1PHYMGTRXRESET_out,
          EMAC1PHYMGTTXRESET  =>  EMAC1PHYMGTTXRESET_out,
          EMAC1PHYPOWERDOWN  =>  EMAC1PHYPOWERDOWN_out,
          EMAC1PHYSYNCACQSTATUS  =>  EMAC1PHYSYNCACQSTATUS_out,
          EMAC1PHYTXCHARDISPMODE  =>  EMAC1PHYTXCHARDISPMODE_out,
          EMAC1PHYTXCHARDISPVAL  =>  EMAC1PHYTXCHARDISPVAL_out,
          EMAC1PHYTXCHARISK  =>  EMAC1PHYTXCHARISK_out,
          EMAC1PHYTXCLK  =>  EMAC1PHYTXCLK_out,
          EMAC1PHYTXD  =>  EMAC1PHYTXD_out,
          EMAC1PHYTXEN  =>  EMAC1PHYTXEN_out,
          EMAC1PHYTXER  =>  EMAC1PHYTXER_out,
          EMACDCRACK  =>  EMACDCRACK_out,
          EMACDCRDBUS  =>  EMACDCRDBUS_out,
          HOSTADDR  =>  HOSTADDR_ipd,
          HOSTCLK  =>  HOSTCLK_ipd,
          HOSTEMAC1SEL  =>  HOSTEMAC1SEL_ipd,
          HOSTMIIMRDY  =>  HOSTMIIMRDY_out,
          HOSTMIIMSEL  =>  HOSTMIIMSEL_ipd,
          HOSTOPCODE  =>  HOSTOPCODE_ipd,
          HOSTRDDATA  =>  HOSTRDDATA_out,
          HOSTREQ  =>  HOSTREQ_ipd,
          HOSTWRDATA  =>  HOSTWRDATA_ipd,
          PHYEMAC0COL  =>  PHYEMAC0COL_ipd,
          PHYEMAC0CRS  =>  PHYEMAC0CRS_ipd,
          PHYEMAC0GTXCLK  =>  PHYEMAC0GTXCLK_ipd,
          PHYEMAC0MCLKIN  =>  PHYEMAC0MCLKIN_ipd,
          PHYEMAC0MDIN  =>  PHYEMAC0MDIN_ipd,
          PHYEMAC0MIITXCLK  =>  PHYEMAC0MIITXCLK_skewed,
          PHYEMAC0PHYAD  =>  PHYEMAC0PHYAD_ipd,
          PHYEMAC0RXBUFERR  =>  PHYEMAC0RXBUFERR_ipd,
          PHYEMAC0RXBUFSTATUS  =>  PHYEMAC0RXBUFSTATUS_ipd,
          PHYEMAC0RXCHARISCOMMA  =>  PHYEMAC0RXCHARISCOMMA_ipd,
          PHYEMAC0RXCHARISK  =>  PHYEMAC0RXCHARISK_ipd,
          PHYEMAC0RXCHECKINGCRC  =>  PHYEMAC0RXCHECKINGCRC_ipd,
          PHYEMAC0RXCLK  =>  PHYEMAC0RXCLK_ipd,
          PHYEMAC0RXCLKCORCNT  =>  PHYEMAC0RXCLKCORCNT_ipd,
          PHYEMAC0RXCOMMADET  =>  PHYEMAC0RXCOMMADET_ipd,
          PHYEMAC0RXD  =>  PHYEMAC0RXD_ipd,
          PHYEMAC0RXDISPERR  =>  PHYEMAC0RXDISPERR_ipd,
          PHYEMAC0RXDV  =>  PHYEMAC0RXDV_ipd,
          PHYEMAC0RXER  =>  PHYEMAC0RXER_ipd,
          PHYEMAC0RXLOSSOFSYNC  =>  PHYEMAC0RXLOSSOFSYNC_ipd,
          PHYEMAC0RXNOTINTABLE  =>  PHYEMAC0RXNOTINTABLE_ipd,
          PHYEMAC0RXRUNDISP  =>  PHYEMAC0RXRUNDISP_ipd,
          PHYEMAC0SIGNALDET  =>  PHYEMAC0SIGNALDET_ipd,
          PHYEMAC0TXBUFERR  =>  PHYEMAC0TXBUFERR_ipd,
          PHYEMAC1COL  =>  PHYEMAC1COL_ipd,
          PHYEMAC1CRS  =>  PHYEMAC1CRS_ipd,
          PHYEMAC1GTXCLK  =>  PHYEMAC1GTXCLK_ipd,
          PHYEMAC1MCLKIN  =>  PHYEMAC1MCLKIN_ipd,
          PHYEMAC1MDIN  =>  PHYEMAC1MDIN_ipd,
          PHYEMAC1MIITXCLK  =>  PHYEMAC1MIITXCLK_skewed,
          PHYEMAC1PHYAD  =>  PHYEMAC1PHYAD_ipd,
          PHYEMAC1RXBUFERR  =>  PHYEMAC1RXBUFERR_ipd,
          PHYEMAC1RXBUFSTATUS  =>  PHYEMAC1RXBUFSTATUS_ipd,
          PHYEMAC1RXCHARISCOMMA  =>  PHYEMAC1RXCHARISCOMMA_ipd,
          PHYEMAC1RXCHARISK  =>  PHYEMAC1RXCHARISK_ipd,
          PHYEMAC1RXCHECKINGCRC  =>  PHYEMAC1RXCHECKINGCRC_ipd,
          PHYEMAC1RXCLK  =>  PHYEMAC1RXCLK_ipd,
          PHYEMAC1RXCLKCORCNT  =>  PHYEMAC1RXCLKCORCNT_ipd,
          PHYEMAC1RXCOMMADET  =>  PHYEMAC1RXCOMMADET_ipd,
          PHYEMAC1RXD  =>  PHYEMAC1RXD_ipd,
          PHYEMAC1RXDISPERR  =>  PHYEMAC1RXDISPERR_ipd,
          PHYEMAC1RXDV  =>  PHYEMAC1RXDV_ipd,
          PHYEMAC1RXER  =>  PHYEMAC1RXER_ipd,
          PHYEMAC1RXLOSSOFSYNC  =>  PHYEMAC1RXLOSSOFSYNC_ipd,
          PHYEMAC1RXNOTINTABLE  =>  PHYEMAC1RXNOTINTABLE_ipd,
          PHYEMAC1RXRUNDISP  =>  PHYEMAC1RXRUNDISP_ipd,
          PHYEMAC1SIGNALDET  =>  PHYEMAC1SIGNALDET_ipd,
          PHYEMAC1TXBUFERR  =>  PHYEMAC1TXBUFERR_ipd,
          RESET  =>  RESET_ipd,
          TIEEMAC0CONFIGVEC  =>  TIEEMAC0CONFIGVEC_ipd,
          TIEEMAC0UNICASTADDR  =>  TIEEMAC0UNICASTADDR_ipd,
          TIEEMAC1CONFIGVEC  =>  TIEEMAC1CONFIGVEC_ipd,
          TIEEMAC1UNICASTADDR  =>  TIEEMAC1UNICASTADDR_ipd

      );



   TIMING : process

--  Pin timing violations (clock input pins)

--  Pin Timing Violations (all input pins)

--  Output Pin glitch declaration
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
     variable  EMAC0CLIENTRXDVREG6_GlitchData : VitalGlitchDataType;
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
     variable  EMAC0CLIENTTXGMIIMIICLKOUT_GlitchData : VitalGlitchDataType;
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
     variable  EMAC1CLIENTRXDVREG6_GlitchData : VitalGlitchDataType;
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
     variable  EMAC1CLIENTTXGMIIMIICLKOUT_GlitchData : VitalGlitchDataType;
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
     variable  EMACDCRACK_GlitchData : VitalGlitchDataType;
begin

    EMACDCRACK <= EMACDCRACK_out;
    EMACDCRDBUS <= EMACDCRDBUS_out;
    DCRHOSTDONEIR <= DCRHOSTDONEIR_out;

--  Output-to-Clock path delay
     VitalPathDelay01
       (
         OutSignal     => EMAC0CLIENTANINTERRUPT,
         GlitchData    => EMAC0CLIENTANINTERRUPT_GlitchData,
         OutSignalName => "EMAC0CLIENTANINTERRUPT",
         OutTemp       => EMAC0CLIENTANINTERRUPT_OUT,
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EMAC0CLIENTRXDVREG6,
         GlitchData    => EMAC0CLIENTRXDVREG6_GlitchData,
         OutSignalName => "EMAC0CLIENTRXDVREG6",
         OutTemp       => EMAC0CLIENTRXDVREG6_OUT,
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EMAC0CLIENTTXGMIIMIICLKOUT,
         GlitchData    => EMAC0CLIENTTXGMIIMIICLKOUT_GlitchData,
         OutSignalName => "EMAC0CLIENTTXGMIIMIICLKOUT",
         OutTemp       => EMAC0CLIENTTXGMIIMIICLKOUT_OUT,
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC0GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC0TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EMAC1CLIENTRXDVREG6,
         GlitchData    => EMAC1CLIENTRXDVREG6_GlitchData,
         OutSignalName => "EMAC1CLIENTRXDVREG6",
         OutTemp       => EMAC1CLIENTRXDVREG6_OUT,
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1RXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EMAC1CLIENTTXGMIIMIICLKOUT,
         GlitchData    => EMAC1CLIENTTXGMIIMIICLKOUT_GlitchData,
         OutSignalName => "EMAC1CLIENTTXGMIIMIICLKOUT",
         OutTemp       => EMAC1CLIENTTXGMIIMIICLKOUT_OUT,
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXCLIENTCLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (PHYEMAC1GTXCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (CLIENTEMAC1TXGMIIMIICLKIN_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
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
         Paths         => (0 => (HOSTCLK_ipd'last_event, OUT_DELAY,TRUE)),
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );

--  Wait signal (input/output pins)
   wait on
     CLIENTEMAC0DCMLOCKED_ipd,
     CLIENTEMAC0PAUSEREQ_ipd,
     CLIENTEMAC0PAUSEVAL_ipd,
     CLIENTEMAC0RXCLIENTCLKIN_ipd,
     CLIENTEMAC0TXCLIENTCLKIN_ipd,
     CLIENTEMAC0TXD_client16_delay,
     CLIENTEMAC0TXDVLD_client16_delay,
     CLIENTEMAC0TXDVLDMSW_client16_delay,
     CLIENTEMAC0TXFIRSTBYTE_ipd,
     CLIENTEMAC0TXGMIIMIICLKIN_ipd,
     CLIENTEMAC0TXIFGDELAY_ipd,
     CLIENTEMAC0TXUNDERRUN_ipd,
     CLIENTEMAC1DCMLOCKED_ipd,
     CLIENTEMAC1PAUSEREQ_ipd,
     CLIENTEMAC1PAUSEVAL_ipd,
     CLIENTEMAC1RXCLIENTCLKIN_ipd,
     CLIENTEMAC1TXCLIENTCLKIN_ipd,
     CLIENTEMAC1TXD_client16_delay,
     CLIENTEMAC1TXDVLD_client16_delay,
     CLIENTEMAC1TXDVLDMSW_client16_delay,
     CLIENTEMAC1TXFIRSTBYTE_ipd,
     CLIENTEMAC1TXGMIIMIICLKIN_ipd,
     CLIENTEMAC1TXIFGDELAY_ipd,
     CLIENTEMAC1TXUNDERRUN_ipd,
     DCREMACENABLE_ipd,
     DCRHOSTDONEIR_OUT,
     EMAC0CLIENTANINTERRUPT_OUT,
     EMAC0CLIENTRXBADFRAME_OUT,
     EMAC0CLIENTRXCLIENTCLKOUT_OUT,
     EMAC0CLIENTRXD_OUT,
     EMAC0CLIENTRXDVLD_OUT,
     EMAC0CLIENTRXDVLDMSW_OUT,
     EMAC0CLIENTRXDVREG6_OUT,
     EMAC0CLIENTRXFRAMEDROP_OUT,
     EMAC0CLIENTRXGOODFRAME_OUT,
     EMAC0CLIENTRXSTATS_OUT,
     EMAC0CLIENTRXSTATSBYTEVLD_OUT,
     EMAC0CLIENTRXSTATSVLD_OUT,
     EMAC0CLIENTTXACK_OUT,
     EMAC0CLIENTTXCLIENTCLKOUT_OUT,
     EMAC0CLIENTTXCOLLISION_OUT,
     EMAC0CLIENTTXGMIIMIICLKOUT_OUT,
     EMAC0CLIENTTXRETRANSMIT_OUT,
     EMAC0CLIENTTXSTATS_OUT,
     EMAC0CLIENTTXSTATSBYTEVLD_OUT,
     EMAC0CLIENTTXSTATSVLD_OUT,
     EMAC0PHYENCOMMAALIGN_OUT,
     EMAC0PHYLOOPBACKMSB_OUT,
     EMAC0PHYMCLKOUT_OUT,
     EMAC0PHYMDOUT_OUT,
     EMAC0PHYMDTRI_OUT,
     EMAC0PHYMGTRXRESET_OUT,
     EMAC0PHYMGTTXRESET_OUT,
     EMAC0PHYPOWERDOWN_OUT,
     EMAC0PHYSYNCACQSTATUS_OUT,
     EMAC0PHYTXCHARDISPMODE_OUT,
     EMAC0PHYTXCHARDISPVAL_OUT,
     EMAC0PHYTXCHARISK_OUT,
     EMAC0PHYTXCLK_OUT,
     EMAC0PHYTXD_OUT,
     EMAC0PHYTXEN_OUT,
     EMAC0PHYTXER_OUT,
     EMAC1CLIENTANINTERRUPT_OUT,
     EMAC1CLIENTRXBADFRAME_OUT,
     EMAC1CLIENTRXCLIENTCLKOUT_OUT,
     EMAC1CLIENTRXD_OUT,
     EMAC1CLIENTRXDVLD_OUT,
     EMAC1CLIENTRXDVLDMSW_OUT,
     EMAC1CLIENTRXDVREG6_OUT,
     EMAC1CLIENTRXFRAMEDROP_OUT,
     EMAC1CLIENTRXGOODFRAME_OUT,
     EMAC1CLIENTRXSTATS_OUT,
     EMAC1CLIENTRXSTATSBYTEVLD_OUT,
     EMAC1CLIENTRXSTATSVLD_OUT,
     EMAC1CLIENTTXACK_OUT,
     EMAC1CLIENTTXCLIENTCLKOUT_OUT,
     EMAC1CLIENTTXCOLLISION_OUT,
     EMAC1CLIENTTXGMIIMIICLKOUT_OUT,
     EMAC1CLIENTTXRETRANSMIT_OUT,
     EMAC1CLIENTTXSTATS_OUT,
     EMAC1CLIENTTXSTATSBYTEVLD_OUT,
     EMAC1CLIENTTXSTATSVLD_OUT,
     EMAC1PHYENCOMMAALIGN_OUT,
     EMAC1PHYLOOPBACKMSB_OUT,
     EMAC1PHYMCLKOUT_OUT,
     EMAC1PHYMDOUT_OUT,
     EMAC1PHYMDTRI_OUT,
     EMAC1PHYMGTRXRESET_OUT,
     EMAC1PHYMGTTXRESET_OUT,
     EMAC1PHYPOWERDOWN_OUT,
     EMAC1PHYSYNCACQSTATUS_OUT,
     EMAC1PHYTXCHARDISPMODE_OUT,
     EMAC1PHYTXCHARDISPVAL_OUT,
     EMAC1PHYTXCHARISK_OUT,
     EMAC1PHYTXCLK_OUT,
     EMAC1PHYTXD_OUT,
     EMAC1PHYTXEN_OUT,
     EMAC1PHYTXER_OUT,
     HOSTADDR_ipd,
     HOSTCLK_ipd,
     HOSTEMAC1SEL_ipd,
     HOSTMIIMRDY_OUT,
     HOSTMIIMSEL_ipd,
     HOSTOPCODE_ipd,
     HOSTRDDATA_OUT,
     HOSTREQ_ipd,
     HOSTWRDATA_ipd,
     PHYEMAC0COL_ipd,
     PHYEMAC0CRS_ipd,
     PHYEMAC0GTXCLK_ipd,
     PHYEMAC0MCLKIN_ipd,
     PHYEMAC0MDIN_ipd,
     PHYEMAC0MIITXCLK_skewed,
     PHYEMAC0PHYAD_ipd,
     PHYEMAC0RXBUFERR_ipd,
     PHYEMAC0RXBUFSTATUS_ipd,
     PHYEMAC0RXCHARISCOMMA_ipd,
     PHYEMAC0RXCHARISK_ipd,
     PHYEMAC0RXCHECKINGCRC_ipd,
     PHYEMAC0RXCLK_ipd,
     PHYEMAC0RXCLKCORCNT_ipd,
     PHYEMAC0RXCOMMADET_ipd,
     PHYEMAC0RXD_ipd,
     PHYEMAC0RXDISPERR_ipd,
     PHYEMAC0RXDV_ipd,
     PHYEMAC0RXER_ipd,
     PHYEMAC0RXLOSSOFSYNC_ipd,
     PHYEMAC0RXNOTINTABLE_ipd,
     PHYEMAC0RXRUNDISP_ipd,
     PHYEMAC0SIGNALDET_ipd,
     PHYEMAC0TXBUFERR_ipd,
     PHYEMAC1COL_ipd,
     PHYEMAC1CRS_ipd,
     PHYEMAC1GTXCLK_ipd,
     PHYEMAC1MCLKIN_ipd,
     PHYEMAC1MDIN_ipd,
     PHYEMAC1MIITXCLK_skewed,
     PHYEMAC1PHYAD_ipd,
     PHYEMAC1RXBUFERR_ipd,
     PHYEMAC1RXBUFSTATUS_ipd,
     PHYEMAC1RXCHARISCOMMA_ipd,
     PHYEMAC1RXCHARISK_ipd,
     PHYEMAC1RXCHECKINGCRC_ipd,
     PHYEMAC1RXCLK_ipd,
     PHYEMAC1RXCLKCORCNT_ipd,
     PHYEMAC1RXCOMMADET_ipd,
     PHYEMAC1RXD_ipd,
     PHYEMAC1RXDISPERR_ipd,
     PHYEMAC1RXDV_ipd,
     PHYEMAC1RXER_ipd,
     PHYEMAC1RXLOSSOFSYNC_ipd,
     PHYEMAC1RXNOTINTABLE_ipd,
     PHYEMAC1RXRUNDISP_ipd,
     PHYEMAC1SIGNALDET_ipd,
     PHYEMAC1TXBUFERR_ipd,
     RESET_ipd,
     TIEEMAC0CONFIGVEC_ipd,
     TIEEMAC0UNICASTADDR_ipd,
     TIEEMAC1CONFIGVEC_ipd,
     TIEEMAC1UNICASTADDR_ipd,
     DCREMACWRITE_ipd,
     DCREMACREAD_ipd,
     DCREMACDBUS_ipd,
     DCREMACABUS_ipd,
     DCREMACCLK_ipd,
     EMACDCRDBUS_OUT,     
     EMACDCRACK_OUT;

   end process TIMING;


       
end EMAC_V;
