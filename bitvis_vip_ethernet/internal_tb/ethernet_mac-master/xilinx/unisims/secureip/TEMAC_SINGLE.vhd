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
--  /   /                      : Tri-Mode Ethernet MAC
-- /___/   /\      Filename    : temac_single.vhd
-- \   \  /  \     
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  11/05/07 - CR453443 - Initial version.
--  05/30/08 - CR1014 - Added parameter
--  06/06/08 - CR1014 - added component instantiation
--  08/05/08 - CR1014 - yml updates - EMAC_MDIO_IGNORE_PHYADZERO string to boolean, EMAC_DCRBASEADDR updated from [7:0] to [0:7]
--  10/02/08 - CR491285 - Publish complete TEMAC_SINGLE VHDL unisim wrapper
--  10/05/08 - CR491285 - Added conversion functions bv_to_integer,boolean_to_string to support vhdl mixed-mode simulation
--  10/24/08 - CR1014 - updated in_delay from 0 to 50
--  10/28/08 - CR494036 - remove Vitalpathdelay, set OUT_DELAY to 100ps
--  11/11/08 - CR493972 - Add SIM_VERSION
--  11/11/08 - CR496295 - Convert parameter type bit_vector to string to support VHDL simulation
--  04/03/09 - CR515882 - Fix for 16 bit client mode
--  09/01/09 - CR532335 - Delay YML update, specify block update
------------------------------------------------------

----- CELL TEMAC_SINGLE -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all; 
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity TEMAC_SINGLE is
    generic (
      EMAC_1000BASEX_ENABLE : boolean := FALSE;
      EMAC_ADDRFILTER_ENABLE : boolean := FALSE;
      EMAC_BYTEPHY : boolean := FALSE;
      EMAC_CTRLLENCHECK_DISABLE : boolean := FALSE;
      EMAC_DCRBASEADDR : bit_vector := X"00";
      EMAC_GTLOOPBACK : boolean := FALSE;
      EMAC_HOST_ENABLE : boolean := FALSE;
      EMAC_LINKTIMERVAL : bit_vector := X"000";
      EMAC_LTCHECK_DISABLE : boolean := FALSE;
      EMAC_MDIO_ENABLE : boolean := FALSE;
      EMAC_MDIO_IGNORE_PHYADZERO : boolean := FALSE;
      EMAC_PAUSEADDR : bit_vector := X"000000000000";
      EMAC_PHYINITAUTONEG_ENABLE : boolean := FALSE;
      EMAC_PHYISOLATE : boolean := FALSE;
      EMAC_PHYLOOPBACKMSB : boolean := FALSE;
      EMAC_PHYPOWERDOWN : boolean := FALSE;
      EMAC_PHYRESET : boolean := FALSE;
      EMAC_RGMII_ENABLE : boolean := FALSE;
      EMAC_RX16BITCLIENT_ENABLE : boolean := FALSE;
      EMAC_RXFLOWCTRL_ENABLE : boolean := FALSE;
      EMAC_RXHALFDUPLEX : boolean := FALSE;
      EMAC_RXINBANDFCS_ENABLE : boolean := FALSE;
      EMAC_RXJUMBOFRAME_ENABLE : boolean := FALSE;
      EMAC_RXRESET : boolean := FALSE;
      EMAC_RXVLAN_ENABLE : boolean := FALSE;
      EMAC_RX_ENABLE : boolean := TRUE;
      EMAC_SGMII_ENABLE : boolean := FALSE;
      EMAC_SPEED_LSB : boolean := FALSE;
      EMAC_SPEED_MSB : boolean := FALSE;
      EMAC_TX16BITCLIENT_ENABLE : boolean := FALSE;
      EMAC_TXFLOWCTRL_ENABLE : boolean := FALSE;
      EMAC_TXHALFDUPLEX : boolean := FALSE;
      EMAC_TXIFGADJUST_ENABLE : boolean := FALSE;
      EMAC_TXINBANDFCS_ENABLE : boolean := FALSE;
      EMAC_TXJUMBOFRAME_ENABLE : boolean := FALSE;
      EMAC_TXRESET : boolean := FALSE;
      EMAC_TXVLAN_ENABLE : boolean := FALSE;
      EMAC_TX_ENABLE : boolean := TRUE;
      EMAC_UNICASTADDR : bit_vector := X"000000000000";
      EMAC_UNIDIRECTION_ENABLE : boolean := FALSE;
      EMAC_USECLKEN : boolean := FALSE;
      SIM_VERSION : string := "1.0"
    );

    port (
      DCRHOSTDONEIR        : out std_ulogic;
      EMACCLIENTANINTERRUPT : out std_ulogic;
      EMACCLIENTRXBADFRAME : out std_ulogic;
      EMACCLIENTRXCLIENTCLKOUT : out std_ulogic;
      EMACCLIENTRXD        : out std_logic_vector(15 downto 0);
      EMACCLIENTRXDVLD     : out std_ulogic;
      EMACCLIENTRXDVLDMSW  : out std_ulogic;
      EMACCLIENTRXFRAMEDROP : out std_ulogic;
      EMACCLIENTRXGOODFRAME : out std_ulogic;
      EMACCLIENTRXSTATS    : out std_logic_vector(6 downto 0);
      EMACCLIENTRXSTATSBYTEVLD : out std_ulogic;
      EMACCLIENTRXSTATSVLD : out std_ulogic;
      EMACCLIENTTXACK      : out std_ulogic;
      EMACCLIENTTXCLIENTCLKOUT : out std_ulogic;
      EMACCLIENTTXCOLLISION : out std_ulogic;
      EMACCLIENTTXRETRANSMIT : out std_ulogic;
      EMACCLIENTTXSTATS    : out std_ulogic;
      EMACCLIENTTXSTATSBYTEVLD : out std_ulogic;
      EMACCLIENTTXSTATSVLD : out std_ulogic;
      EMACDCRACK           : out std_ulogic;
      EMACDCRDBUS          : out std_logic_vector(0 to 31);
      EMACPHYENCOMMAALIGN  : out std_ulogic;
      EMACPHYLOOPBACKMSB   : out std_ulogic;
      EMACPHYMCLKOUT       : out std_ulogic;
      EMACPHYMDOUT         : out std_ulogic;
      EMACPHYMDTRI         : out std_ulogic;
      EMACPHYMGTRXRESET    : out std_ulogic;
      EMACPHYMGTTXRESET    : out std_ulogic;
      EMACPHYPOWERDOWN     : out std_ulogic;
      EMACPHYSYNCACQSTATUS : out std_ulogic;
      EMACPHYTXCHARDISPMODE : out std_ulogic;
      EMACPHYTXCHARDISPVAL : out std_ulogic;
      EMACPHYTXCHARISK     : out std_ulogic;
      EMACPHYTXCLK         : out std_ulogic;
      EMACPHYTXD           : out std_logic_vector(7 downto 0);
      EMACPHYTXEN          : out std_ulogic;
      EMACPHYTXER          : out std_ulogic;
      EMACPHYTXGMIIMIICLKOUT : out std_ulogic;
      EMACSPEEDIS10100     : out std_ulogic;
      HOSTMIIMRDY          : out std_ulogic;
      HOSTRDDATA           : out std_logic_vector(31 downto 0);
      CLIENTEMACDCMLOCKED  : in std_ulogic;
      CLIENTEMACPAUSEREQ   : in std_ulogic;
      CLIENTEMACPAUSEVAL   : in std_logic_vector(15 downto 0);
      CLIENTEMACRXCLIENTCLKIN : in std_ulogic;
      CLIENTEMACTXCLIENTCLKIN : in std_ulogic;
      CLIENTEMACTXD        : in std_logic_vector(15 downto 0);
      CLIENTEMACTXDVLD     : in std_ulogic;
      CLIENTEMACTXDVLDMSW  : in std_ulogic;
      CLIENTEMACTXFIRSTBYTE : in std_ulogic;
      CLIENTEMACTXIFGDELAY : in std_logic_vector(7 downto 0);
      CLIENTEMACTXUNDERRUN : in std_ulogic;
      DCREMACABUS          : in std_logic_vector(0 to 9);
      DCREMACCLK           : in std_ulogic;
      DCREMACDBUS          : in std_logic_vector(0 to 31);
      DCREMACENABLE        : in std_ulogic;
      DCREMACREAD          : in std_ulogic;
      DCREMACWRITE         : in std_ulogic;
      HOSTADDR             : in std_logic_vector(9 downto 0);
      HOSTCLK              : in std_ulogic;
      HOSTMIIMSEL          : in std_ulogic;
      HOSTOPCODE           : in std_logic_vector(1 downto 0);
      HOSTREQ              : in std_ulogic;
      HOSTWRDATA           : in std_logic_vector(31 downto 0);
      PHYEMACCOL           : in std_ulogic;
      PHYEMACCRS           : in std_ulogic;
      PHYEMACGTXCLK        : in std_ulogic;
      PHYEMACMCLKIN        : in std_ulogic;
      PHYEMACMDIN          : in std_ulogic;
      PHYEMACMIITXCLK      : in std_ulogic;
      PHYEMACPHYAD         : in std_logic_vector(4 downto 0);
      PHYEMACRXBUFSTATUS   : in std_logic_vector(1 downto 0);
      PHYEMACRXCHARISCOMMA : in std_ulogic;
      PHYEMACRXCHARISK     : in std_ulogic;
      PHYEMACRXCLK         : in std_ulogic;
      PHYEMACRXCLKCORCNT   : in std_logic_vector(2 downto 0);
      PHYEMACRXD           : in std_logic_vector(7 downto 0);
      PHYEMACRXDISPERR     : in std_ulogic;
      PHYEMACRXDV          : in std_ulogic;
      PHYEMACRXER          : in std_ulogic;
      PHYEMACRXNOTINTABLE  : in std_ulogic;
      PHYEMACRXRUNDISP     : in std_ulogic;
      PHYEMACSIGNALDET     : in std_ulogic;
      PHYEMACTXBUFERR      : in std_ulogic;
      PHYEMACTXGMIIMIICLKIN : in std_ulogic;
      RESET                : in std_ulogic      
    );
  end TEMAC_SINGLE;

  architecture TEMAC_SINGLE_V of TEMAC_SINGLE is
    component TEMAC_SINGLE_WRAP
      generic (
      EMAC_1000BASEX_ENABLE : string;
      EMAC_ADDRFILTER_ENABLE : string;
      EMAC_BYTEPHY : string;
      EMAC_CTRLLENCHECK_DISABLE : string;
      EMAC_DCRBASEADDR : string;
      EMAC_GTLOOPBACK : string;
      EMAC_HOST_ENABLE : string;
      EMAC_LINKTIMERVAL : string;
      EMAC_LTCHECK_DISABLE : string;
      EMAC_MDIO_ENABLE : string;
      EMAC_MDIO_IGNORE_PHYADZERO : string;
      EMAC_PAUSEADDR : string;
      EMAC_PHYINITAUTONEG_ENABLE : string;
      EMAC_PHYISOLATE : string;
      EMAC_PHYLOOPBACKMSB : string;
      EMAC_PHYPOWERDOWN : string;
      EMAC_PHYRESET : string;
      EMAC_RGMII_ENABLE : string;
      EMAC_RX16BITCLIENT_ENABLE : string;
      EMAC_RXFLOWCTRL_ENABLE : string;
      EMAC_RXHALFDUPLEX : string;
      EMAC_RXINBANDFCS_ENABLE : string;
      EMAC_RXJUMBOFRAME_ENABLE : string;
      EMAC_RXRESET : string;
      EMAC_RXVLAN_ENABLE : string;
      EMAC_RX_ENABLE : string;
      EMAC_SGMII_ENABLE : string;
      EMAC_SPEED_LSB : string;
      EMAC_SPEED_MSB : string;
      EMAC_TX16BITCLIENT_ENABLE : string;
      EMAC_TXFLOWCTRL_ENABLE : string;
      EMAC_TXHALFDUPLEX : string;
      EMAC_TXIFGADJUST_ENABLE : string;
      EMAC_TXINBANDFCS_ENABLE : string;
      EMAC_TXJUMBOFRAME_ENABLE : string;
      EMAC_TXRESET : string;
      EMAC_TXVLAN_ENABLE : string;
      EMAC_TX_ENABLE : string;
      EMAC_UNICASTADDR : string;
      EMAC_UNIDIRECTION_ENABLE : string;
      EMAC_USECLKEN : string
    );

    port (
        DCRHOSTDONEIR        : out std_ulogic;
        EMACCLIENTANINTERRUPT : out std_ulogic;
        EMACCLIENTRXBADFRAME : out std_ulogic;
        EMACCLIENTRXCLIENTCLKOUT : out std_ulogic;
        EMACCLIENTRXD        : out std_logic_vector(15 downto 0);
        EMACCLIENTRXDVLD     : out std_ulogic;
        EMACCLIENTRXDVLDMSW  : out std_ulogic;
        EMACCLIENTRXFRAMEDROP : out std_ulogic;
        EMACCLIENTRXGOODFRAME : out std_ulogic;
        EMACCLIENTRXSTATS    : out std_logic_vector(6 downto 0);
        EMACCLIENTRXSTATSBYTEVLD : out std_ulogic;
        EMACCLIENTRXSTATSVLD : out std_ulogic;
        EMACCLIENTTXACK      : out std_ulogic;
        EMACCLIENTTXCLIENTCLKOUT : out std_ulogic;
        EMACCLIENTTXCOLLISION : out std_ulogic;
        EMACCLIENTTXRETRANSMIT : out std_ulogic;
        EMACCLIENTTXSTATS    : out std_ulogic;
        EMACCLIENTTXSTATSBYTEVLD : out std_ulogic;
        EMACCLIENTTXSTATSVLD : out std_ulogic;
        EMACDCRACK           : out std_ulogic;
        EMACDCRDBUS          : out std_logic_vector(0 to 31);
        EMACPHYENCOMMAALIGN  : out std_ulogic;
        EMACPHYLOOPBACKMSB   : out std_ulogic;
        EMACPHYMCLKOUT       : out std_ulogic;
        EMACPHYMDOUT         : out std_ulogic;
        EMACPHYMDTRI         : out std_ulogic;
        EMACPHYMGTRXRESET    : out std_ulogic;
        EMACPHYMGTTXRESET    : out std_ulogic;
        EMACPHYPOWERDOWN     : out std_ulogic;
        EMACPHYSYNCACQSTATUS : out std_ulogic;
        EMACPHYTXCHARDISPMODE : out std_ulogic;
        EMACPHYTXCHARDISPVAL : out std_ulogic;
        EMACPHYTXCHARISK     : out std_ulogic;
        EMACPHYTXCLK         : out std_ulogic;
        EMACPHYTXD           : out std_logic_vector(7 downto 0);
        EMACPHYTXEN          : out std_ulogic;
        EMACPHYTXER          : out std_ulogic;
        EMACPHYTXGMIIMIICLKOUT : out std_ulogic;
        EMACSPEEDIS10100     : out std_ulogic;
        HOSTMIIMRDY          : out std_ulogic;
        HOSTRDDATA           : out std_logic_vector(31 downto 0);

        GSR                  : in std_ulogic;  
        CLIENTEMACDCMLOCKED  : in std_ulogic;
        CLIENTEMACPAUSEREQ   : in std_ulogic;
        CLIENTEMACPAUSEVAL   : in std_logic_vector(15 downto 0);
        CLIENTEMACRXCLIENTCLKIN : in std_ulogic;
        CLIENTEMACTXCLIENTCLKIN : in std_ulogic;
        CLIENTEMACTXD        : in std_logic_vector(15 downto 0);
        CLIENTEMACTXDVLD     : in std_ulogic;
        CLIENTEMACTXDVLDMSW  : in std_ulogic;
        CLIENTEMACTXFIRSTBYTE : in std_ulogic;
        CLIENTEMACTXIFGDELAY : in std_logic_vector(7 downto 0);
        CLIENTEMACTXUNDERRUN : in std_ulogic;
        DCREMACABUS          : in std_logic_vector(0 to 9);
        DCREMACCLK           : in std_ulogic;
        DCREMACDBUS          : in std_logic_vector(0 to 31);
        DCREMACENABLE        : in std_ulogic;
        DCREMACREAD          : in std_ulogic;
        DCREMACWRITE         : in std_ulogic;
        HOSTADDR             : in std_logic_vector(9 downto 0);
        HOSTCLK              : in std_ulogic;
        HOSTMIIMSEL          : in std_ulogic;
        HOSTOPCODE           : in std_logic_vector(1 downto 0);
        HOSTREQ              : in std_ulogic;
        HOSTWRDATA           : in std_logic_vector(31 downto 0);
        PHYEMACCOL           : in std_ulogic;
        PHYEMACCRS           : in std_ulogic;
        PHYEMACGTXCLK        : in std_ulogic;
        PHYEMACMCLKIN        : in std_ulogic;
        PHYEMACMDIN          : in std_ulogic;
        PHYEMACMIITXCLK      : in std_ulogic;
        PHYEMACPHYAD         : in std_logic_vector(4 downto 0);
        PHYEMACRXBUFSTATUS   : in std_logic_vector(1 downto 0);
        PHYEMACRXCHARISCOMMA : in std_ulogic;
        PHYEMACRXCHARISK     : in std_ulogic;
        PHYEMACRXCLK         : in std_ulogic;
        PHYEMACRXCLKCORCNT   : in std_logic_vector(2 downto 0);
        PHYEMACRXD           : in std_logic_vector(7 downto 0);
        PHYEMACRXDISPERR     : in std_ulogic;
        PHYEMACRXDV          : in std_ulogic;
        PHYEMACRXER          : in std_ulogic;
        PHYEMACRXNOTINTABLE  : in std_ulogic;
        PHYEMACRXRUNDISP     : in std_ulogic;
        PHYEMACSIGNALDET     : in std_ulogic;
        PHYEMACTXBUFERR      : in std_ulogic;
        PHYEMACTXGMIIMIICLKIN : in std_ulogic;
        RESET                : in std_ulogic
      );
    end component;

    function GetValue_EMAC (
    EMAC_TX16BITCLIENT_ENABLE : in boolean
    )  return time is 
    variable delay_time : time;
  begin 
    case EMAC_TX16BITCLIENT_ENABLE is 
      when TRUE => delay_time := 25 ps;
      when FALSE => delay_time := 0 ps;
    end case;
    return delay_time;
  end;

    constant IN_DELAY : time := 50 ps;
    constant OUT_DELAY : time := 100 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    constant EMACMIITXCLK_DELAY : time := GetValue_EMAC(EMAC_TX16BITCLIENT_ENABLE);
  
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

    
 -- Convert bit_vector to std_logic_vector
    constant EMAC_DCRBASEADDR_BINARY : std_logic_vector(7 downto 0) := To_StdLogicVector(EMAC_DCRBASEADDR)(7 downto 0);
    constant EMAC_LINKTIMERVAL_BINARY : std_logic_vector(8 downto 0) := To_StdLogicVector(EMAC_LINKTIMERVAL)(8 downto 0);
    constant EMAC_PAUSEADDR_BINARY : std_logic_vector(47 downto 0) := To_StdLogicVector(EMAC_PAUSEADDR)(47 downto 0);
    constant EMAC_UNICASTADDR_BINARY : std_logic_vector(47 downto 0) := To_StdLogicVector(EMAC_UNICASTADDR)(47 downto 0);
    
    -- Get String Length
    constant EMAC_DCRBASEADDR_STRLEN : integer := getstrlength(EMAC_DCRBASEADDR_BINARY);
    constant EMAC_LINKTIMERVAL_STRLEN : integer := getstrlength(EMAC_LINKTIMERVAL_BINARY);
    constant EMAC_PAUSEADDR_STRLEN : integer := getstrlength(EMAC_PAUSEADDR_BINARY);
    constant EMAC_UNICASTADDR_STRLEN : integer := getstrlength(EMAC_UNICASTADDR_BINARY);
    
    -- Convert std_logic_vector to string
    constant EMAC_DCRBASEADDR_STRING : string := SLV_TO_HEX(EMAC_DCRBASEADDR_BINARY, EMAC_DCRBASEADDR_STRLEN);
    constant EMAC_LINKTIMERVAL_STRING : string := SLV_TO_HEX(EMAC_LINKTIMERVAL_BINARY, EMAC_LINKTIMERVAL_STRLEN);
    constant EMAC_PAUSEADDR_STRING : string := SLV_TO_HEX(EMAC_PAUSEADDR_BINARY, EMAC_PAUSEADDR_STRLEN);
    constant EMAC_UNICASTADDR_STRING : string := SLV_TO_HEX(EMAC_UNICASTADDR_BINARY, EMAC_UNICASTADDR_STRLEN);
    
      -- Convert boolean to string
      constant EMAC_1000BASEX_ENABLE_STRING : string  := boolean_to_string(EMAC_1000BASEX_ENABLE);
      constant EMAC_ADDRFILTER_ENABLE_STRING : string := boolean_to_string(EMAC_ADDRFILTER_ENABLE);
      constant EMAC_BYTEPHY_STRING : string := boolean_to_string(EMAC_BYTEPHY);
      constant EMAC_CTRLLENCHECK_DISABLE_STRING : string:= boolean_to_string(EMAC_CTRLLENCHECK_DISABLE); 
      constant EMAC_GTLOOPBACK_STRING : string := boolean_to_string(EMAC_GTLOOPBACK);
      constant EMAC_HOST_ENABLE_STRING : string := boolean_to_string(EMAC_HOST_ENABLE);
      constant EMAC_LTCHECK_DISABLE_STRING : string := boolean_to_string(EMAC_LTCHECK_DISABLE);
      constant EMAC_MDIO_ENABLE_STRING : string := boolean_to_string(EMAC_MDIO_ENABLE);
      constant EMAC_MDIO_IGNORE_PHYADZERO_STRING : string := boolean_to_string(EMAC_MDIO_IGNORE_PHYADZERO);
      constant EMAC_PHYINITAUTONEG_ENABLE_STRING : string := boolean_to_string(EMAC_PHYINITAUTONEG_ENABLE);
      constant EMAC_PHYISOLATE_STRING : string := boolean_to_string(EMAC_PHYISOLATE);
      constant EMAC_PHYLOOPBACKMSB_STRING : string := boolean_to_string(EMAC_PHYLOOPBACKMSB);
      constant EMAC_PHYPOWERDOWN_STRING : string := boolean_to_string(EMAC_PHYPOWERDOWN);
      constant EMAC_PHYRESET_STRING : string := boolean_to_string(EMAC_PHYRESET);
      constant EMAC_RGMII_ENABLE_STRING : string := boolean_to_string(EMAC_RGMII_ENABLE);
      constant EMAC_RX16BITCLIENT_ENABLE_STRING : string := boolean_to_string(EMAC_RX16BITCLIENT_ENABLE);
      constant EMAC_RXFLOWCTRL_ENABLE_STRING : string := boolean_to_string(EMAC_RXFLOWCTRL_ENABLE);
      constant EMAC_RXHALFDUPLEX_STRING : string := boolean_to_string(EMAC_RXHALFDUPLEX);
      constant EMAC_RXINBANDFCS_ENABLE_STRING : string := boolean_to_string(EMAC_RXINBANDFCS_ENABLE);
      constant EMAC_RXJUMBOFRAME_ENABLE_STRING : string := boolean_to_string(EMAC_RXJUMBOFRAME_ENABLE);
      constant EMAC_RXRESET_STRING : string := boolean_to_string(EMAC_RXRESET);
      constant EMAC_RXVLAN_ENABLE_STRING : string := boolean_to_string(EMAC_RXVLAN_ENABLE);
      constant EMAC_RX_ENABLE_STRING : string := boolean_to_string(EMAC_RX_ENABLE);
      constant EMAC_SGMII_ENABLE_STRING : string := boolean_to_string(EMAC_SGMII_ENABLE);
      constant EMAC_SPEED_LSB_STRING : string := boolean_to_string(EMAC_SPEED_LSB);
      constant EMAC_SPEED_MSB_STRING : string := boolean_to_string(EMAC_SPEED_MSB);
      constant EMAC_TX16BITCLIENT_ENABLE_STRING : string := boolean_to_string(EMAC_TX16BITCLIENT_ENABLE);
      constant EMAC_TXFLOWCTRL_ENABLE_STRING : string := boolean_to_string(EMAC_TXFLOWCTRL_ENABLE);
      constant EMAC_TXHALFDUPLEX_STRING : string := boolean_to_string(EMAC_TXHALFDUPLEX);
      constant EMAC_TXIFGADJUST_ENABLE_STRING : string := boolean_to_string(EMAC_TXIFGADJUST_ENABLE);
      constant EMAC_TXINBANDFCS_ENABLE_STRING : string := boolean_to_string(EMAC_TXINBANDFCS_ENABLE);
      constant EMAC_TXJUMBOFRAME_ENABLE_STRING : string := boolean_to_string(EMAC_TXJUMBOFRAME_ENABLE);
      constant EMAC_TXRESET_STRING : string := boolean_to_string(EMAC_TXRESET);
      constant EMAC_TXVLAN_ENABLE_STRING : string := boolean_to_string(EMAC_TXVLAN_ENABLE);
      constant EMAC_TX_ENABLE_STRING : string := boolean_to_string(EMAC_TX_ENABLE);
      constant EMAC_UNIDIRECTION_ENABLE_STRING : string := boolean_to_string(EMAC_UNIDIRECTION_ENABLE);
      constant EMAC_USECLKEN_STRING : string := boolean_to_string(EMAC_USECLKEN);
      
    signal EMAC_1000BASEX_ENABLE_BINARY : std_ulogic;
    signal EMAC_ADDRFILTER_ENABLE_BINARY : std_ulogic;
    signal EMAC_BYTEPHY_BINARY : std_ulogic;
    signal EMAC_CTRLLENCHECK_DISABLE_BINARY : std_ulogic; 
    signal EMAC_GTLOOPBACK_BINARY : std_ulogic;
    signal EMAC_HOST_ENABLE_BINARY : std_ulogic;
    signal EMAC_LTCHECK_DISABLE_BINARY : std_ulogic;
    signal EMAC_MDIO_ENABLE_BINARY : std_ulogic;
    signal EMAC_MDIO_IGNORE_PHYADZERO_BINARY : std_ulogic;
    signal EMAC_PHYINITAUTONEG_ENABLE_BINARY : std_ulogic;
    signal EMAC_PHYISOLATE_BINARY : std_ulogic;
    signal EMAC_PHYLOOPBACKMSB_BINARY : std_ulogic;
    signal EMAC_PHYPOWERDOWN_BINARY : std_ulogic;
    signal EMAC_PHYRESET_BINARY : std_ulogic;
    signal EMAC_RGMII_ENABLE_BINARY : std_ulogic;
    signal EMAC_RX16BITCLIENT_ENABLE_BINARY : std_ulogic;
    signal EMAC_RXFLOWCTRL_ENABLE_BINARY : std_ulogic;
    signal EMAC_RXHALFDUPLEX_BINARY : std_ulogic;
    signal EMAC_RXINBANDFCS_ENABLE_BINARY : std_ulogic;
    signal EMAC_RXJUMBOFRAME_ENABLE_BINARY : std_ulogic;
    signal EMAC_RXRESET_BINARY : std_ulogic;
    signal EMAC_RXVLAN_ENABLE_BINARY : std_ulogic;
    signal EMAC_RX_ENABLE_BINARY : std_ulogic;
    signal EMAC_SGMII_ENABLE_BINARY : std_ulogic;
    signal EMAC_SPEED_LSB_BINARY : std_ulogic;
    signal EMAC_SPEED_MSB_BINARY : std_ulogic;
    signal EMAC_TX16BITCLIENT_ENABLE_BINARY : std_ulogic;
    signal EMAC_TXFLOWCTRL_ENABLE_BINARY : std_ulogic;
    signal EMAC_TXHALFDUPLEX_BINARY : std_ulogic;
    signal EMAC_TXIFGADJUST_ENABLE_BINARY : std_ulogic;
    signal EMAC_TXINBANDFCS_ENABLE_BINARY : std_ulogic;
    signal EMAC_TXJUMBOFRAME_ENABLE_BINARY : std_ulogic;
    signal EMAC_TXRESET_BINARY : std_ulogic;
    signal EMAC_TXVLAN_ENABLE_BINARY : std_ulogic;
    signal EMAC_TX_ENABLE_BINARY : std_ulogic;
    
    signal EMAC_UNIDIRECTION_ENABLE_BINARY : std_ulogic;
    signal EMAC_USECLKEN_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    
    signal DCRHOSTDONEIR_out : std_ulogic;
    signal EMACCLIENTANINTERRUPT_out : std_ulogic;
    signal EMACCLIENTRXBADFRAME_out : std_ulogic;
    signal EMACCLIENTRXCLIENTCLKOUT_out : std_ulogic;
    signal EMACCLIENTRXDVLDMSW_out : std_ulogic;
    signal EMACCLIENTRXDVLD_out : std_ulogic;
    signal EMACCLIENTRXD_out : std_logic_vector(15 downto 0);
    signal EMACCLIENTRXFRAMEDROP_out : std_ulogic;
    signal EMACCLIENTRXGOODFRAME_out : std_ulogic;
    signal EMACCLIENTRXSTATSBYTEVLD_out : std_ulogic;
    signal EMACCLIENTRXSTATSVLD_out : std_ulogic;
    signal EMACCLIENTRXSTATS_out : std_logic_vector(6 downto 0);
    signal EMACCLIENTTXACK_out : std_ulogic;
    signal EMACCLIENTTXCLIENTCLKOUT_out : std_ulogic;
    signal EMACCLIENTTXCOLLISION_out : std_ulogic;
    signal EMACCLIENTTXRETRANSMIT_out : std_ulogic;
    signal EMACCLIENTTXSTATSBYTEVLD_out : std_ulogic;
    signal EMACCLIENTTXSTATSVLD_out : std_ulogic;
    signal EMACCLIENTTXSTATS_out : std_ulogic;
    signal EMACDCRACK_out : std_ulogic;
    signal EMACDCRDBUS_out : std_logic_vector(0 to 31);
    signal EMACPHYENCOMMAALIGN_out : std_ulogic;
    signal EMACPHYLOOPBACKMSB_out : std_ulogic;
    signal EMACPHYMCLKOUT_out : std_ulogic;
    signal EMACPHYMDOUT_out : std_ulogic;
    signal EMACPHYMDTRI_out : std_ulogic;
    signal EMACPHYMGTRXRESET_out : std_ulogic;
    signal EMACPHYMGTTXRESET_out : std_ulogic;
    signal EMACPHYPOWERDOWN_out : std_ulogic;
    signal EMACPHYSYNCACQSTATUS_out : std_ulogic;
    signal EMACPHYTXCHARDISPMODE_out : std_ulogic;
    signal EMACPHYTXCHARDISPVAL_out : std_ulogic;
    signal EMACPHYTXCHARISK_out : std_ulogic;
    signal EMACPHYTXCLK_out : std_ulogic;
    signal EMACPHYTXD_out : std_logic_vector(7 downto 0);
    signal EMACPHYTXEN_out : std_ulogic;
    signal EMACPHYTXER_out : std_ulogic;
    signal EMACPHYTXGMIIMIICLKOUT_out : std_ulogic;
    signal EMACSPEEDIS10100_out : std_ulogic;
    signal HOSTMIIMRDY_out : std_ulogic;
    signal HOSTRDDATA_out : std_logic_vector(31 downto 0);
    
    signal DCRHOSTDONEIR_outdelay : std_ulogic;
    signal EMACCLIENTANINTERRUPT_outdelay : std_ulogic;
    signal EMACCLIENTRXBADFRAME_outdelay : std_ulogic;
    signal EMACCLIENTRXCLIENTCLKOUT_outdelay : std_ulogic;
    signal EMACCLIENTRXDVLDMSW_outdelay : std_ulogic;
    signal EMACCLIENTRXDVLD_outdelay : std_ulogic;
    signal EMACCLIENTRXD_outdelay : std_logic_vector(15 downto 0);
    signal EMACCLIENTRXFRAMEDROP_outdelay : std_ulogic;
    signal EMACCLIENTRXGOODFRAME_outdelay : std_ulogic;
    signal EMACCLIENTRXSTATSBYTEVLD_outdelay : std_ulogic;
    signal EMACCLIENTRXSTATSVLD_outdelay : std_ulogic;
    signal EMACCLIENTRXSTATS_outdelay : std_logic_vector(6 downto 0);
    signal EMACCLIENTTXACK_outdelay : std_ulogic;
    signal EMACCLIENTTXCLIENTCLKOUT_outdelay : std_ulogic;
    signal EMACCLIENTTXCOLLISION_outdelay : std_ulogic;
    signal EMACCLIENTTXRETRANSMIT_outdelay : std_ulogic;
    signal EMACCLIENTTXSTATSBYTEVLD_outdelay : std_ulogic;
    signal EMACCLIENTTXSTATSVLD_outdelay : std_ulogic;
    signal EMACCLIENTTXSTATS_outdelay : std_ulogic;
    signal EMACDCRACK_outdelay : std_ulogic;
    signal EMACDCRDBUS_outdelay : std_logic_vector(0 to 31);
    signal EMACPHYENCOMMAALIGN_outdelay : std_ulogic;
    signal EMACPHYLOOPBACKMSB_outdelay : std_ulogic;
    signal EMACPHYMCLKOUT_outdelay : std_ulogic;
    signal EMACPHYMDOUT_outdelay : std_ulogic;
    signal EMACPHYMDTRI_outdelay : std_ulogic;
    signal EMACPHYMGTRXRESET_outdelay : std_ulogic;
    signal EMACPHYMGTTXRESET_outdelay : std_ulogic;
    signal EMACPHYPOWERDOWN_outdelay : std_ulogic;
    signal EMACPHYSYNCACQSTATUS_outdelay : std_ulogic;
    signal EMACPHYTXCHARDISPMODE_outdelay : std_ulogic;
    signal EMACPHYTXCHARDISPVAL_outdelay : std_ulogic;
    signal EMACPHYTXCHARISK_outdelay : std_ulogic;
    signal EMACPHYTXCLK_outdelay : std_ulogic;
    signal EMACPHYTXD_outdelay : std_logic_vector(7 downto 0);
    signal EMACPHYTXEN_outdelay : std_ulogic;
    signal EMACPHYTXER_outdelay : std_ulogic;
    signal EMACPHYTXGMIIMIICLKOUT_outdelay : std_ulogic;
    signal EMACSPEEDIS10100_outdelay : std_ulogic;
    signal HOSTMIIMRDY_outdelay : std_ulogic;
    signal HOSTRDDATA_outdelay : std_logic_vector(31 downto 0);
    
    signal CLIENTEMACDCMLOCKED_ipd : std_ulogic;
    signal CLIENTEMACPAUSEREQ_ipd : std_ulogic;
    signal CLIENTEMACPAUSEVAL_ipd : std_logic_vector(15 downto 0);
    signal CLIENTEMACRXCLIENTCLKIN_ipd : std_ulogic;
    signal CLIENTEMACTXCLIENTCLKIN_ipd : std_ulogic;
    signal CLIENTEMACTXDVLDMSW_ipd : std_ulogic;
    signal CLIENTEMACTXDVLD_ipd : std_ulogic;
    signal CLIENTEMACTXD_ipd : std_logic_vector(15 downto 0);
    signal CLIENTEMACTXFIRSTBYTE_ipd : std_ulogic;
    signal CLIENTEMACTXIFGDELAY_ipd : std_logic_vector(7 downto 0);
    signal CLIENTEMACTXUNDERRUN_ipd : std_ulogic;
    signal DCREMACABUS_ipd : std_logic_vector(0 to 9);
    signal DCREMACCLK_ipd : std_ulogic;
    signal DCREMACDBUS_ipd : std_logic_vector(0 to 31);
    signal DCREMACENABLE_ipd : std_ulogic;
    signal DCREMACREAD_ipd : std_ulogic;
    signal DCREMACWRITE_ipd : std_ulogic;
    signal HOSTADDR_ipd : std_logic_vector(9 downto 0);
    signal HOSTCLK_ipd : std_ulogic;
    signal HOSTMIIMSEL_ipd : std_ulogic;
    signal HOSTOPCODE_ipd : std_logic_vector(1 downto 0);
    signal HOSTREQ_ipd : std_ulogic;
    signal HOSTWRDATA_ipd : std_logic_vector(31 downto 0);
    signal PHYEMACCOL_ipd : std_ulogic;
    signal PHYEMACCRS_ipd : std_ulogic;
    signal PHYEMACGTXCLK_ipd : std_ulogic;
    signal PHYEMACMCLKIN_ipd : std_ulogic;
    signal PHYEMACMDIN_ipd : std_ulogic;
    signal PHYEMACMIITXCLK_ipd : std_ulogic;
    signal PHYEMACPHYAD_ipd : std_logic_vector(4 downto 0);
    signal PHYEMACRXBUFSTATUS_ipd : std_logic_vector(1 downto 0);
    signal PHYEMACRXCHARISCOMMA_ipd : std_ulogic;
    signal PHYEMACRXCHARISK_ipd : std_ulogic;
    signal PHYEMACRXCLKCORCNT_ipd : std_logic_vector(2 downto 0);
    signal PHYEMACRXCLK_ipd : std_ulogic;
    signal PHYEMACRXDISPERR_ipd : std_ulogic;
    signal PHYEMACRXDV_ipd : std_ulogic;
    signal PHYEMACRXD_ipd : std_logic_vector(7 downto 0);
    signal PHYEMACRXER_ipd : std_ulogic;
    signal PHYEMACRXNOTINTABLE_ipd : std_ulogic;
    signal PHYEMACRXRUNDISP_ipd : std_ulogic;
    signal PHYEMACSIGNALDET_ipd : std_ulogic;
    signal PHYEMACTXBUFERR_ipd : std_ulogic;
    signal PHYEMACTXGMIIMIICLKIN_ipd : std_ulogic;
    signal RESET_ipd : std_ulogic;
    
    
    signal CLIENTEMACDCMLOCKED_indelay : std_ulogic;
    signal CLIENTEMACPAUSEREQ_indelay : std_ulogic;
    signal CLIENTEMACPAUSEVAL_indelay : std_logic_vector(15 downto 0);
    signal CLIENTEMACRXCLIENTCLKIN_indelay : std_ulogic;
    signal CLIENTEMACTXCLIENTCLKIN_indelay : std_ulogic;
    signal CLIENTEMACTXDVLDMSW_indelay : std_ulogic;
    signal CLIENTEMACTXDVLD_indelay : std_ulogic;
    signal CLIENTEMACTXD_indelay : std_logic_vector(15 downto 0);
    signal CLIENTEMACTXFIRSTBYTE_indelay : std_ulogic;
    signal CLIENTEMACTXIFGDELAY_indelay : std_logic_vector(7 downto 0);
    signal CLIENTEMACTXUNDERRUN_indelay : std_ulogic;
    signal DCREMACABUS_indelay : std_logic_vector(0 to 9);
    signal DCREMACCLK_indelay : std_ulogic;
    signal DCREMACDBUS_indelay : std_logic_vector(0 to 31);
    signal DCREMACENABLE_indelay : std_ulogic;
    signal DCREMACREAD_indelay : std_ulogic;
    signal DCREMACWRITE_indelay : std_ulogic;
    signal HOSTADDR_indelay : std_logic_vector(9 downto 0);
    signal HOSTCLK_indelay : std_ulogic;
    signal HOSTMIIMSEL_indelay : std_ulogic;
    signal HOSTOPCODE_indelay : std_logic_vector(1 downto 0);
    signal HOSTREQ_indelay : std_ulogic;
    signal HOSTWRDATA_indelay : std_logic_vector(31 downto 0);
    signal PHYEMACCOL_indelay : std_ulogic;
    signal PHYEMACCRS_indelay : std_ulogic;
    signal PHYEMACGTXCLK_indelay : std_ulogic;
    signal PHYEMACMCLKIN_indelay : std_ulogic;
    signal PHYEMACMDIN_indelay : std_ulogic;
    signal PHYEMACMIITXCLK_indelay : std_ulogic;
    signal PHYEMACPHYAD_indelay : std_logic_vector(4 downto 0);
    signal PHYEMACRXBUFSTATUS_indelay : std_logic_vector(1 downto 0);
    signal PHYEMACRXCHARISCOMMA_indelay : std_ulogic;
    signal PHYEMACRXCHARISK_indelay : std_ulogic;
    signal PHYEMACRXCLKCORCNT_indelay : std_logic_vector(2 downto 0);
    signal PHYEMACRXCLK_indelay : std_ulogic;
    signal PHYEMACRXDISPERR_indelay : std_ulogic;
    signal PHYEMACRXDV_indelay : std_ulogic;
    signal PHYEMACRXD_indelay : std_logic_vector(7 downto 0);
    signal PHYEMACRXER_indelay : std_ulogic;
    signal PHYEMACRXNOTINTABLE_indelay : std_ulogic;
    signal PHYEMACRXRUNDISP_indelay : std_ulogic;
    signal PHYEMACSIGNALDET_indelay : std_ulogic;
    signal PHYEMACTXBUFERR_indelay : std_ulogic;
    signal PHYEMACTXGMIIMIICLKIN_indelay : std_ulogic;
    signal RESET_indelay : std_ulogic;
    
    begin
    
    DCRHOSTDONEIR_out <= DCRHOSTDONEIR_outdelay after OUT_DELAY;
    EMACCLIENTANINTERRUPT_out <= EMACCLIENTANINTERRUPT_outdelay after OUT_DELAY;
    EMACCLIENTRXBADFRAME_out <= EMACCLIENTRXBADFRAME_outdelay after OUT_DELAY;
    EMACCLIENTRXCLIENTCLKOUT_out <= EMACCLIENTRXCLIENTCLKOUT_outdelay after OUT_DELAY;
    EMACCLIENTRXDVLDMSW_out <= EMACCLIENTRXDVLDMSW_outdelay after OUT_DELAY;
    EMACCLIENTRXDVLD_out <= EMACCLIENTRXDVLD_outdelay after OUT_DELAY;
    EMACCLIENTRXD_out <= EMACCLIENTRXD_outdelay after OUT_DELAY;
    EMACCLIENTRXFRAMEDROP_out <= EMACCLIENTRXFRAMEDROP_outdelay after OUT_DELAY;
    EMACCLIENTRXGOODFRAME_out <= EMACCLIENTRXGOODFRAME_outdelay after OUT_DELAY;
    EMACCLIENTRXSTATSBYTEVLD_out <= EMACCLIENTRXSTATSBYTEVLD_outdelay after OUT_DELAY;
    EMACCLIENTRXSTATSVLD_out <= EMACCLIENTRXSTATSVLD_outdelay after OUT_DELAY;
    EMACCLIENTRXSTATS_out <= EMACCLIENTRXSTATS_outdelay after OUT_DELAY;
    EMACCLIENTTXACK_out <= EMACCLIENTTXACK_outdelay after OUT_DELAY;
    EMACCLIENTTXCLIENTCLKOUT_out <= EMACCLIENTTXCLIENTCLKOUT_outdelay after OUT_DELAY;
    EMACCLIENTTXCOLLISION_out <= EMACCLIENTTXCOLLISION_outdelay after OUT_DELAY;
    EMACCLIENTTXRETRANSMIT_out <= EMACCLIENTTXRETRANSMIT_outdelay after OUT_DELAY;
    EMACCLIENTTXSTATSBYTEVLD_out <= EMACCLIENTTXSTATSBYTEVLD_outdelay after OUT_DELAY;
    EMACCLIENTTXSTATSVLD_out <= EMACCLIENTTXSTATSVLD_outdelay after OUT_DELAY;
    EMACCLIENTTXSTATS_out <= EMACCLIENTTXSTATS_outdelay after OUT_DELAY;
    EMACDCRACK_out <= EMACDCRACK_outdelay after OUT_DELAY;
    EMACDCRDBUS_out <= EMACDCRDBUS_outdelay after OUT_DELAY;
    EMACPHYENCOMMAALIGN_out <= EMACPHYENCOMMAALIGN_outdelay after OUT_DELAY;
    EMACPHYLOOPBACKMSB_out <= EMACPHYLOOPBACKMSB_outdelay after OUT_DELAY;
    EMACPHYMCLKOUT_out <= EMACPHYMCLKOUT_outdelay after OUT_DELAY;
    EMACPHYMDOUT_out <= EMACPHYMDOUT_outdelay after OUT_DELAY;
    EMACPHYMDTRI_out <= EMACPHYMDTRI_outdelay after OUT_DELAY;
    EMACPHYMGTRXRESET_out <= EMACPHYMGTRXRESET_outdelay after OUT_DELAY;
    EMACPHYMGTTXRESET_out <= EMACPHYMGTTXRESET_outdelay after OUT_DELAY;
    EMACPHYPOWERDOWN_out <= EMACPHYPOWERDOWN_outdelay after OUT_DELAY;
    EMACPHYSYNCACQSTATUS_out <= EMACPHYSYNCACQSTATUS_outdelay after OUT_DELAY;
    EMACPHYTXCHARDISPMODE_out <= EMACPHYTXCHARDISPMODE_outdelay after OUT_DELAY;
    EMACPHYTXCHARDISPVAL_out <= EMACPHYTXCHARDISPVAL_outdelay after OUT_DELAY;
    EMACPHYTXCHARISK_out <= EMACPHYTXCHARISK_outdelay after OUT_DELAY;
    EMACPHYTXCLK_out <= EMACPHYTXCLK_outdelay after OUT_DELAY;
    EMACPHYTXD_out <= EMACPHYTXD_outdelay after OUT_DELAY;
    EMACPHYTXEN_out <= EMACPHYTXEN_outdelay after OUT_DELAY;
    EMACPHYTXER_out <= EMACPHYTXER_outdelay after OUT_DELAY;
    EMACPHYTXGMIIMIICLKOUT_out <= EMACPHYTXGMIIMIICLKOUT_outdelay after OUT_DELAY;
    EMACSPEEDIS10100_out <= EMACSPEEDIS10100_outdelay after OUT_DELAY;
    HOSTMIIMRDY_out <= HOSTMIIMRDY_outdelay after OUT_DELAY;
    HOSTRDDATA_out <= HOSTRDDATA_outdelay after OUT_DELAY;
    
    CLIENTEMACRXCLIENTCLKIN_ipd <= CLIENTEMACRXCLIENTCLKIN;
    CLIENTEMACTXCLIENTCLKIN_ipd <= CLIENTEMACTXCLIENTCLKIN;
    DCREMACCLK_ipd <= DCREMACCLK;
    HOSTCLK_ipd <= HOSTCLK;
    PHYEMACGTXCLK_ipd <= PHYEMACGTXCLK;
    PHYEMACMCLKIN_ipd <= PHYEMACMCLKIN;
    PHYEMACMIITXCLK_ipd <= PHYEMACMIITXCLK;
    PHYEMACRXCLK_ipd <= PHYEMACRXCLK;
    PHYEMACTXGMIIMIICLKIN_ipd <= PHYEMACTXGMIIMIICLKIN;
    
    CLIENTEMACDCMLOCKED_ipd <= CLIENTEMACDCMLOCKED;
    CLIENTEMACPAUSEREQ_ipd <= CLIENTEMACPAUSEREQ;
    CLIENTEMACPAUSEVAL_ipd <= CLIENTEMACPAUSEVAL;
    CLIENTEMACTXDVLDMSW_ipd <= CLIENTEMACTXDVLDMSW;
    CLIENTEMACTXDVLD_ipd <= CLIENTEMACTXDVLD;
    CLIENTEMACTXD_ipd <= CLIENTEMACTXD;
    CLIENTEMACTXFIRSTBYTE_ipd <= CLIENTEMACTXFIRSTBYTE;
    CLIENTEMACTXIFGDELAY_ipd <= CLIENTEMACTXIFGDELAY;
    CLIENTEMACTXUNDERRUN_ipd <= CLIENTEMACTXUNDERRUN;
    DCREMACABUS_ipd <= DCREMACABUS;
    DCREMACDBUS_ipd <= DCREMACDBUS;
    DCREMACENABLE_ipd <= DCREMACENABLE;
    DCREMACREAD_ipd <= DCREMACREAD;
    DCREMACWRITE_ipd <= DCREMACWRITE;
    HOSTADDR_ipd <= HOSTADDR;
    HOSTMIIMSEL_ipd <= HOSTMIIMSEL;
    HOSTOPCODE_ipd <= HOSTOPCODE;
    HOSTREQ_ipd <= HOSTREQ;
    HOSTWRDATA_ipd <= HOSTWRDATA;
    PHYEMACCOL_ipd <= PHYEMACCOL;
    PHYEMACCRS_ipd <= PHYEMACCRS;
    PHYEMACMDIN_ipd <= PHYEMACMDIN;
    PHYEMACPHYAD_ipd <= PHYEMACPHYAD;
    PHYEMACRXBUFSTATUS_ipd <= PHYEMACRXBUFSTATUS;
    PHYEMACRXCHARISCOMMA_ipd <= PHYEMACRXCHARISCOMMA;
    PHYEMACRXCHARISK_ipd <= PHYEMACRXCHARISK;
    PHYEMACRXCLKCORCNT_ipd <= PHYEMACRXCLKCORCNT;
    PHYEMACRXDISPERR_ipd <= PHYEMACRXDISPERR;
    PHYEMACRXDV_ipd <= PHYEMACRXDV;
    PHYEMACRXD_ipd <= PHYEMACRXD;
    PHYEMACRXER_ipd <= PHYEMACRXER;
    PHYEMACRXNOTINTABLE_ipd <= PHYEMACRXNOTINTABLE;
    PHYEMACRXRUNDISP_ipd <= PHYEMACRXRUNDISP;
    PHYEMACSIGNALDET_ipd <= PHYEMACSIGNALDET;
    PHYEMACTXBUFERR_ipd <= PHYEMACTXBUFERR;
    RESET_ipd <= RESET;
    
    CLIENTEMACRXCLIENTCLKIN_indelay <= CLIENTEMACRXCLIENTCLKIN_ipd after INCLK_DELAY;
    CLIENTEMACTXCLIENTCLKIN_indelay <= CLIENTEMACTXCLIENTCLKIN_ipd after INCLK_DELAY;
    DCREMACCLK_indelay <= DCREMACCLK_ipd after INCLK_DELAY;
    HOSTCLK_indelay <= HOSTCLK_ipd after INCLK_DELAY;
    PHYEMACGTXCLK_indelay <= PHYEMACGTXCLK_ipd after INCLK_DELAY;
    PHYEMACMCLKIN_indelay <= PHYEMACMCLKIN_ipd after INCLK_DELAY;
    PHYEMACMIITXCLK_indelay <= PHYEMACMIITXCLK_ipd after EMACMIITXCLK_DELAY;
    PHYEMACRXCLK_indelay <= PHYEMACRXCLK_ipd after INCLK_DELAY;
    PHYEMACTXGMIIMIICLKIN_indelay <= PHYEMACTXGMIIMIICLKIN_ipd after INCLK_DELAY;
    
    CLIENTEMACDCMLOCKED_indelay <= CLIENTEMACDCMLOCKED_ipd after IN_DELAY;
    CLIENTEMACPAUSEREQ_indelay <= CLIENTEMACPAUSEREQ_ipd after IN_DELAY;
    CLIENTEMACPAUSEVAL_indelay <= CLIENTEMACPAUSEVAL_ipd after IN_DELAY;
    CLIENTEMACTXDVLDMSW_indelay <= CLIENTEMACTXDVLDMSW_ipd after IN_DELAY;
    CLIENTEMACTXDVLD_indelay <= CLIENTEMACTXDVLD_ipd after IN_DELAY;
    CLIENTEMACTXD_indelay <= CLIENTEMACTXD_ipd after IN_DELAY;
    CLIENTEMACTXFIRSTBYTE_indelay <= CLIENTEMACTXFIRSTBYTE_ipd after IN_DELAY;
    CLIENTEMACTXIFGDELAY_indelay <= CLIENTEMACTXIFGDELAY_ipd after IN_DELAY;
    CLIENTEMACTXUNDERRUN_indelay <= CLIENTEMACTXUNDERRUN_ipd after IN_DELAY;
    DCREMACABUS_indelay <= DCREMACABUS_ipd after IN_DELAY;
    DCREMACDBUS_indelay <= DCREMACDBUS_ipd after IN_DELAY;
    DCREMACENABLE_indelay <= DCREMACENABLE_ipd after IN_DELAY;
    DCREMACREAD_indelay <= DCREMACREAD_ipd after IN_DELAY;
    DCREMACWRITE_indelay <= DCREMACWRITE_ipd after IN_DELAY;
    HOSTADDR_indelay <= HOSTADDR_ipd after IN_DELAY;
    HOSTMIIMSEL_indelay <= HOSTMIIMSEL_ipd after IN_DELAY;
    HOSTOPCODE_indelay <= HOSTOPCODE_ipd after IN_DELAY;
    HOSTREQ_indelay <= HOSTREQ_ipd after IN_DELAY;
    HOSTWRDATA_indelay <= HOSTWRDATA_ipd after IN_DELAY;
    PHYEMACCOL_indelay <= PHYEMACCOL_ipd after IN_DELAY;
    PHYEMACCRS_indelay <= PHYEMACCRS_ipd after IN_DELAY;
    PHYEMACMDIN_indelay <= PHYEMACMDIN_ipd after IN_DELAY;
    PHYEMACPHYAD_indelay <= PHYEMACPHYAD_ipd after IN_DELAY;
    PHYEMACRXBUFSTATUS_indelay <= PHYEMACRXBUFSTATUS_ipd after IN_DELAY;
    PHYEMACRXCHARISCOMMA_indelay <= PHYEMACRXCHARISCOMMA_ipd after IN_DELAY;
    PHYEMACRXCHARISK_indelay <= PHYEMACRXCHARISK_ipd after IN_DELAY;
    PHYEMACRXCLKCORCNT_indelay <= PHYEMACRXCLKCORCNT_ipd after IN_DELAY;
    PHYEMACRXDISPERR_indelay <= PHYEMACRXDISPERR_ipd after IN_DELAY;
    PHYEMACRXDV_indelay <= PHYEMACRXDV_ipd after IN_DELAY;
    PHYEMACRXD_indelay <= PHYEMACRXD_ipd after IN_DELAY;
    PHYEMACRXER_indelay <= PHYEMACRXER_ipd after IN_DELAY;
    PHYEMACRXNOTINTABLE_indelay <= PHYEMACRXNOTINTABLE_ipd after IN_DELAY;
    PHYEMACRXRUNDISP_indelay <= PHYEMACRXRUNDISP_ipd after IN_DELAY;
    PHYEMACSIGNALDET_indelay <= PHYEMACSIGNALDET_ipd after IN_DELAY;
    PHYEMACTXBUFERR_indelay <= PHYEMACTXBUFERR_ipd after IN_DELAY;
    RESET_indelay <= RESET_ipd after IN_DELAY;

      
    TEMAC_SINGLE_INST : TEMAC_SINGLE_WRAP
      generic map (
        EMAC_1000BASEX_ENABLE => EMAC_1000BASEX_ENABLE_STRING,
        EMAC_ADDRFILTER_ENABLE => EMAC_ADDRFILTER_ENABLE_STRING,
        EMAC_BYTEPHY         => EMAC_BYTEPHY_STRING,
        EMAC_CTRLLENCHECK_DISABLE => EMAC_CTRLLENCHECK_DISABLE_STRING,
        EMAC_DCRBASEADDR     => EMAC_DCRBASEADDR_STRING,
        EMAC_GTLOOPBACK      => EMAC_GTLOOPBACK_STRING,
        EMAC_HOST_ENABLE     => EMAC_HOST_ENABLE_STRING,
        EMAC_LINKTIMERVAL    => EMAC_LINKTIMERVAL_STRING,
        EMAC_LTCHECK_DISABLE => EMAC_LTCHECK_DISABLE_STRING,
        EMAC_MDIO_ENABLE     => EMAC_MDIO_ENABLE_STRING,
        EMAC_MDIO_IGNORE_PHYADZERO => EMAC_MDIO_IGNORE_PHYADZERO_STRING,
        EMAC_PAUSEADDR       => EMAC_PAUSEADDR_STRING,
        EMAC_PHYINITAUTONEG_ENABLE => EMAC_PHYINITAUTONEG_ENABLE_STRING,
        EMAC_PHYISOLATE      => EMAC_PHYISOLATE_STRING,
        EMAC_PHYLOOPBACKMSB  => EMAC_PHYLOOPBACKMSB_STRING,
        EMAC_PHYPOWERDOWN    => EMAC_PHYPOWERDOWN_STRING,
        EMAC_PHYRESET        => EMAC_PHYRESET_STRING,
        EMAC_RGMII_ENABLE    => EMAC_RGMII_ENABLE_STRING,
        EMAC_RX16BITCLIENT_ENABLE => EMAC_RX16BITCLIENT_ENABLE_STRING,
        EMAC_RXFLOWCTRL_ENABLE => EMAC_RXFLOWCTRL_ENABLE_STRING,
        EMAC_RXHALFDUPLEX    => EMAC_RXHALFDUPLEX_STRING,
        EMAC_RXINBANDFCS_ENABLE => EMAC_RXINBANDFCS_ENABLE_STRING,
        EMAC_RXJUMBOFRAME_ENABLE => EMAC_RXJUMBOFRAME_ENABLE_STRING,
        EMAC_RXRESET         => EMAC_RXRESET_STRING,
        EMAC_RXVLAN_ENABLE   => EMAC_RXVLAN_ENABLE_STRING,
        EMAC_RX_ENABLE       => EMAC_RX_ENABLE_STRING,
        EMAC_SGMII_ENABLE    => EMAC_SGMII_ENABLE_STRING,
        EMAC_SPEED_LSB       => EMAC_SPEED_LSB_STRING,
        EMAC_SPEED_MSB       => EMAC_SPEED_MSB_STRING,
        EMAC_TX16BITCLIENT_ENABLE => EMAC_TX16BITCLIENT_ENABLE_STRING,
        EMAC_TXFLOWCTRL_ENABLE => EMAC_TXFLOWCTRL_ENABLE_STRING,
        EMAC_TXHALFDUPLEX    => EMAC_TXHALFDUPLEX_STRING,
        EMAC_TXIFGADJUST_ENABLE => EMAC_TXIFGADJUST_ENABLE_STRING,
        EMAC_TXINBANDFCS_ENABLE => EMAC_TXINBANDFCS_ENABLE_STRING,
        EMAC_TXJUMBOFRAME_ENABLE => EMAC_TXJUMBOFRAME_ENABLE_STRING,
        EMAC_TXRESET         => EMAC_TXRESET_STRING,
        EMAC_TXVLAN_ENABLE   => EMAC_TXVLAN_ENABLE_STRING,
        EMAC_TX_ENABLE       => EMAC_TX_ENABLE_STRING,
        EMAC_UNICASTADDR     => EMAC_UNICASTADDR_STRING,
        EMAC_UNIDIRECTION_ENABLE => EMAC_UNIDIRECTION_ENABLE_STRING,
        EMAC_USECLKEN        => EMAC_USECLKEN_STRING
         )
        port map (
        GSR => GSR,
        DCRHOSTDONEIR        => DCRHOSTDONEIR_outdelay,
        EMACCLIENTANINTERRUPT => EMACCLIENTANINTERRUPT_outdelay,
        EMACCLIENTRXBADFRAME => EMACCLIENTRXBADFRAME_outdelay,
        EMACCLIENTRXCLIENTCLKOUT => EMACCLIENTRXCLIENTCLKOUT_outdelay,
        EMACCLIENTRXD        => EMACCLIENTRXD_outdelay,
        EMACCLIENTRXDVLD     => EMACCLIENTRXDVLD_outdelay,
        EMACCLIENTRXDVLDMSW  => EMACCLIENTRXDVLDMSW_outdelay,
        EMACCLIENTRXFRAMEDROP => EMACCLIENTRXFRAMEDROP_outdelay,
        EMACCLIENTRXGOODFRAME => EMACCLIENTRXGOODFRAME_outdelay,
        EMACCLIENTRXSTATS    => EMACCLIENTRXSTATS_outdelay,
        EMACCLIENTRXSTATSBYTEVLD => EMACCLIENTRXSTATSBYTEVLD_outdelay,
        EMACCLIENTRXSTATSVLD => EMACCLIENTRXSTATSVLD_outdelay,
        EMACCLIENTTXACK      => EMACCLIENTTXACK_outdelay,
        EMACCLIENTTXCLIENTCLKOUT => EMACCLIENTTXCLIENTCLKOUT_outdelay,
        EMACCLIENTTXCOLLISION => EMACCLIENTTXCOLLISION_outdelay,
        EMACCLIENTTXRETRANSMIT => EMACCLIENTTXRETRANSMIT_outdelay,
        EMACCLIENTTXSTATS    => EMACCLIENTTXSTATS_outdelay,
        EMACCLIENTTXSTATSBYTEVLD => EMACCLIENTTXSTATSBYTEVLD_outdelay,
        EMACCLIENTTXSTATSVLD => EMACCLIENTTXSTATSVLD_outdelay,
        EMACDCRACK           => EMACDCRACK_outdelay,
        EMACDCRDBUS          => EMACDCRDBUS_outdelay,
        EMACPHYENCOMMAALIGN  => EMACPHYENCOMMAALIGN_outdelay,
        EMACPHYLOOPBACKMSB   => EMACPHYLOOPBACKMSB_outdelay,
        EMACPHYMCLKOUT       => EMACPHYMCLKOUT_outdelay,
        EMACPHYMDOUT         => EMACPHYMDOUT_outdelay,
        EMACPHYMDTRI         => EMACPHYMDTRI_outdelay,
        EMACPHYMGTRXRESET    => EMACPHYMGTRXRESET_outdelay,
        EMACPHYMGTTXRESET    => EMACPHYMGTTXRESET_outdelay,
        EMACPHYPOWERDOWN     => EMACPHYPOWERDOWN_outdelay,
        EMACPHYSYNCACQSTATUS => EMACPHYSYNCACQSTATUS_outdelay,
        EMACPHYTXCHARDISPMODE => EMACPHYTXCHARDISPMODE_outdelay,
        EMACPHYTXCHARDISPVAL => EMACPHYTXCHARDISPVAL_outdelay,
        EMACPHYTXCHARISK     => EMACPHYTXCHARISK_outdelay,
        EMACPHYTXCLK         => EMACPHYTXCLK_outdelay,
        EMACPHYTXD           => EMACPHYTXD_outdelay,
        EMACPHYTXEN          => EMACPHYTXEN_outdelay,
        EMACPHYTXER          => EMACPHYTXER_outdelay,
        EMACPHYTXGMIIMIICLKOUT => EMACPHYTXGMIIMIICLKOUT_outdelay,
        EMACSPEEDIS10100     => EMACSPEEDIS10100_outdelay,
        HOSTMIIMRDY          => HOSTMIIMRDY_outdelay,
        HOSTRDDATA           => HOSTRDDATA_outdelay,
        CLIENTEMACDCMLOCKED  => CLIENTEMACDCMLOCKED_indelay,
        CLIENTEMACPAUSEREQ   => CLIENTEMACPAUSEREQ_indelay,
        CLIENTEMACPAUSEVAL   => CLIENTEMACPAUSEVAL_indelay,
        CLIENTEMACRXCLIENTCLKIN => CLIENTEMACRXCLIENTCLKIN_indelay,
        CLIENTEMACTXCLIENTCLKIN => CLIENTEMACTXCLIENTCLKIN_indelay,
        CLIENTEMACTXD        => CLIENTEMACTXD_indelay,
        CLIENTEMACTXDVLD     => CLIENTEMACTXDVLD_indelay,
        CLIENTEMACTXDVLDMSW  => CLIENTEMACTXDVLDMSW_indelay,
        CLIENTEMACTXFIRSTBYTE => CLIENTEMACTXFIRSTBYTE_indelay,
        CLIENTEMACTXIFGDELAY => CLIENTEMACTXIFGDELAY_indelay,
        CLIENTEMACTXUNDERRUN => CLIENTEMACTXUNDERRUN_indelay,
        DCREMACABUS          => DCREMACABUS_indelay,
        DCREMACCLK           => DCREMACCLK_indelay,
        DCREMACDBUS          => DCREMACDBUS_indelay,
        DCREMACENABLE        => DCREMACENABLE_indelay,
        DCREMACREAD          => DCREMACREAD_indelay,
        DCREMACWRITE         => DCREMACWRITE_indelay,
        HOSTADDR             => HOSTADDR_indelay,
        HOSTCLK              => HOSTCLK_indelay,
        HOSTMIIMSEL          => HOSTMIIMSEL_indelay,
        HOSTOPCODE           => HOSTOPCODE_indelay,
        HOSTREQ              => HOSTREQ_indelay,
        HOSTWRDATA           => HOSTWRDATA_indelay,
        PHYEMACCOL           => PHYEMACCOL_indelay,
        PHYEMACCRS           => PHYEMACCRS_indelay,
        PHYEMACGTXCLK        => PHYEMACGTXCLK_indelay,
        PHYEMACMCLKIN        => PHYEMACMCLKIN_indelay,
        PHYEMACMDIN          => PHYEMACMDIN_indelay,
        PHYEMACMIITXCLK      => PHYEMACMIITXCLK_indelay,
        PHYEMACPHYAD         => PHYEMACPHYAD_indelay,
        PHYEMACRXBUFSTATUS   => PHYEMACRXBUFSTATUS_indelay,
        PHYEMACRXCHARISCOMMA => PHYEMACRXCHARISCOMMA_indelay,
        PHYEMACRXCHARISK     => PHYEMACRXCHARISK_indelay,
        PHYEMACRXCLK         => PHYEMACRXCLK_indelay,
        PHYEMACRXCLKCORCNT   => PHYEMACRXCLKCORCNT_indelay,
        PHYEMACRXD           => PHYEMACRXD_indelay,
        PHYEMACRXDISPERR     => PHYEMACRXDISPERR_indelay,
        PHYEMACRXDV          => PHYEMACRXDV_indelay,
        PHYEMACRXER          => PHYEMACRXER_indelay,
        PHYEMACRXNOTINTABLE  => PHYEMACRXNOTINTABLE_indelay,
        PHYEMACRXRUNDISP     => PHYEMACRXRUNDISP_indelay,
        PHYEMACSIGNALDET     => PHYEMACSIGNALDET_indelay,
        PHYEMACTXBUFERR      => PHYEMACTXBUFERR_indelay,
        PHYEMACTXGMIIMIICLKIN => PHYEMACTXGMIIMIICLKIN_indelay,
        RESET                => RESET_indelay        
      );

    
    INIPROC : process
    begin
    case EMAC_1000BASEX_ENABLE is
      when FALSE   =>  EMAC_1000BASEX_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_1000BASEX_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_1000BASEX_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_ADDRFILTER_ENABLE is
      when FALSE   =>  EMAC_ADDRFILTER_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_ADDRFILTER_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_ADDRFILTER_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_BYTEPHY is
      when FALSE   =>  EMAC_BYTEPHY_BINARY <= '0';
      when TRUE    =>  EMAC_BYTEPHY_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_BYTEPHY is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_CTRLLENCHECK_DISABLE is
      when FALSE   =>  EMAC_CTRLLENCHECK_DISABLE_BINARY <= '0';
      when TRUE    =>  EMAC_CTRLLENCHECK_DISABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_CTRLLENCHECK_DISABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_GTLOOPBACK is
      when FALSE   =>  EMAC_GTLOOPBACK_BINARY <= '0';
      when TRUE    =>  EMAC_GTLOOPBACK_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_GTLOOPBACK is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_HOST_ENABLE is
      when FALSE   =>  EMAC_HOST_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_HOST_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_HOST_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_LTCHECK_DISABLE is
      when FALSE   =>  EMAC_LTCHECK_DISABLE_BINARY <= '0';
      when TRUE    =>  EMAC_LTCHECK_DISABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_LTCHECK_DISABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_MDIO_ENABLE is
      when FALSE   =>  EMAC_MDIO_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_MDIO_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_MDIO_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_MDIO_IGNORE_PHYADZERO is
      when FALSE   =>  EMAC_MDIO_IGNORE_PHYADZERO_BINARY <= '0';
      when TRUE    =>  EMAC_MDIO_IGNORE_PHYADZERO_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_MDIO_IGNORE_PHYADZERO is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_PHYINITAUTONEG_ENABLE is
      when FALSE   =>  EMAC_PHYINITAUTONEG_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_PHYINITAUTONEG_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_PHYINITAUTONEG_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_PHYISOLATE is
      when FALSE   =>  EMAC_PHYISOLATE_BINARY <= '0';
      when TRUE    =>  EMAC_PHYISOLATE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_PHYISOLATE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_PHYLOOPBACKMSB is
      when FALSE   =>  EMAC_PHYLOOPBACKMSB_BINARY <= '0';
      when TRUE    =>  EMAC_PHYLOOPBACKMSB_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_PHYLOOPBACKMSB is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_PHYPOWERDOWN is
      when FALSE   =>  EMAC_PHYPOWERDOWN_BINARY <= '0';
      when TRUE    =>  EMAC_PHYPOWERDOWN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_PHYPOWERDOWN is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_PHYRESET is
      when FALSE   =>  EMAC_PHYRESET_BINARY <= '0';
      when TRUE    =>  EMAC_PHYRESET_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_PHYRESET is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RGMII_ENABLE is
      when FALSE   =>  EMAC_RGMII_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_RGMII_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RGMII_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RX16BITCLIENT_ENABLE is
      when FALSE   =>  EMAC_RX16BITCLIENT_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_RX16BITCLIENT_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RX16BITCLIENT_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RXFLOWCTRL_ENABLE is
      when FALSE   =>  EMAC_RXFLOWCTRL_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_RXFLOWCTRL_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RXFLOWCTRL_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RXHALFDUPLEX is
      when FALSE   =>  EMAC_RXHALFDUPLEX_BINARY <= '0';
      when TRUE    =>  EMAC_RXHALFDUPLEX_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RXHALFDUPLEX is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RXINBANDFCS_ENABLE is
      when FALSE   =>  EMAC_RXINBANDFCS_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_RXINBANDFCS_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RXINBANDFCS_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RXJUMBOFRAME_ENABLE is
      when FALSE   =>  EMAC_RXJUMBOFRAME_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_RXJUMBOFRAME_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RXJUMBOFRAME_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RXRESET is
      when FALSE   =>  EMAC_RXRESET_BINARY <= '0';
      when TRUE    =>  EMAC_RXRESET_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RXRESET is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RXVLAN_ENABLE is
      when FALSE   =>  EMAC_RXVLAN_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_RXVLAN_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RXVLAN_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_RX_ENABLE is
      when FALSE   =>  EMAC_RX_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_RX_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_RX_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_SGMII_ENABLE is
      when FALSE   =>  EMAC_SGMII_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_SGMII_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_SGMII_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_SPEED_LSB is
      when FALSE   =>  EMAC_SPEED_LSB_BINARY <= '0';
      when TRUE    =>  EMAC_SPEED_LSB_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_SPEED_LSB is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_SPEED_MSB is
      when FALSE   =>  EMAC_SPEED_MSB_BINARY <= '0';
      when TRUE    =>  EMAC_SPEED_MSB_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_SPEED_MSB is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TX16BITCLIENT_ENABLE is
      when FALSE   =>  EMAC_TX16BITCLIENT_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_TX16BITCLIENT_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TX16BITCLIENT_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TXFLOWCTRL_ENABLE is
      when FALSE   =>  EMAC_TXFLOWCTRL_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_TXFLOWCTRL_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TXFLOWCTRL_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TXHALFDUPLEX is
      when FALSE   =>  EMAC_TXHALFDUPLEX_BINARY <= '0';
      when TRUE    =>  EMAC_TXHALFDUPLEX_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TXHALFDUPLEX is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TXIFGADJUST_ENABLE is
      when FALSE   =>  EMAC_TXIFGADJUST_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_TXIFGADJUST_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TXIFGADJUST_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TXINBANDFCS_ENABLE is
      when FALSE   =>  EMAC_TXINBANDFCS_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_TXINBANDFCS_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TXINBANDFCS_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TXJUMBOFRAME_ENABLE is
      when FALSE   =>  EMAC_TXJUMBOFRAME_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_TXJUMBOFRAME_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TXJUMBOFRAME_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TXRESET is
      when FALSE   =>  EMAC_TXRESET_BINARY <= '0';
      when TRUE    =>  EMAC_TXRESET_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TXRESET is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TXVLAN_ENABLE is
      when FALSE   =>  EMAC_TXVLAN_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_TXVLAN_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TXVLAN_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_TX_ENABLE is
      when FALSE   =>  EMAC_TX_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_TX_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_TX_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_UNIDIRECTION_ENABLE is
      when FALSE   =>  EMAC_UNIDIRECTION_ENABLE_BINARY <= '0';
      when TRUE    =>  EMAC_UNIDIRECTION_ENABLE_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_UNIDIRECTION_ENABLE is neither TRUE nor FALSE." severity error;
    end case;
    case EMAC_USECLKEN is
      when FALSE   =>  EMAC_USECLKEN_BINARY <= '0';
      when TRUE    =>  EMAC_USECLKEN_BINARY <= '1';
      when others  =>  assert FALSE report "Error : EMAC_USECLKEN is neither TRUE nor FALSE." severity error;
    end case;
    wait;
    end process INIPROC;
    DCRHOSTDONEIR <= DCRHOSTDONEIR_out;
    EMACCLIENTANINTERRUPT <= EMACCLIENTANINTERRUPT_out;
    EMACCLIENTRXBADFRAME <= EMACCLIENTRXBADFRAME_out;
    EMACCLIENTRXCLIENTCLKOUT <= EMACCLIENTRXCLIENTCLKOUT_out;
    EMACCLIENTRXD <= EMACCLIENTRXD_out;
    EMACCLIENTRXDVLD <= EMACCLIENTRXDVLD_out;
    EMACCLIENTRXDVLDMSW <= EMACCLIENTRXDVLDMSW_out;
    EMACCLIENTRXFRAMEDROP <= EMACCLIENTRXFRAMEDROP_out;
    EMACCLIENTRXGOODFRAME <= EMACCLIENTRXGOODFRAME_out;
    EMACCLIENTRXSTATS <= EMACCLIENTRXSTATS_out;
    EMACCLIENTRXSTATSBYTEVLD <= EMACCLIENTRXSTATSBYTEVLD_out;
    EMACCLIENTRXSTATSVLD <= EMACCLIENTRXSTATSVLD_out;
    EMACCLIENTTXACK <= EMACCLIENTTXACK_out;
    EMACCLIENTTXCLIENTCLKOUT <= EMACCLIENTTXCLIENTCLKOUT_out;
    EMACCLIENTTXCOLLISION <= EMACCLIENTTXCOLLISION_out;
    EMACCLIENTTXRETRANSMIT <= EMACCLIENTTXRETRANSMIT_out;
    EMACCLIENTTXSTATS <= EMACCLIENTTXSTATS_out;
    EMACCLIENTTXSTATSBYTEVLD <= EMACCLIENTTXSTATSBYTEVLD_out;
    EMACCLIENTTXSTATSVLD <= EMACCLIENTTXSTATSVLD_out;
    EMACDCRACK <= EMACDCRACK_out;
    EMACDCRDBUS <= EMACDCRDBUS_out;
    EMACPHYENCOMMAALIGN <= EMACPHYENCOMMAALIGN_out;
    EMACPHYLOOPBACKMSB <= EMACPHYLOOPBACKMSB_out;
    EMACPHYMCLKOUT <= EMACPHYMCLKOUT_out;
    EMACPHYMDOUT <= EMACPHYMDOUT_out;
    EMACPHYMDTRI <= EMACPHYMDTRI_out;
    EMACPHYMGTRXRESET <= EMACPHYMGTRXRESET_out;
    EMACPHYMGTTXRESET <= EMACPHYMGTTXRESET_out;
    EMACPHYPOWERDOWN <= EMACPHYPOWERDOWN_out;
    EMACPHYSYNCACQSTATUS <= EMACPHYSYNCACQSTATUS_out;
    EMACPHYTXCHARDISPMODE <= EMACPHYTXCHARDISPMODE_out;
    EMACPHYTXCHARDISPVAL <= EMACPHYTXCHARDISPVAL_out;
    EMACPHYTXCHARISK <= EMACPHYTXCHARISK_out;
    EMACPHYTXCLK <= EMACPHYTXCLK_out;
    EMACPHYTXD <= EMACPHYTXD_out;
    EMACPHYTXEN <= EMACPHYTXEN_out;
    EMACPHYTXER <= EMACPHYTXER_out;
    EMACPHYTXGMIIMIICLKOUT <= EMACPHYTXGMIIMIICLKOUT_out;
    EMACSPEEDIS10100 <= EMACSPEEDIS10100_out;
    HOSTMIIMRDY <= HOSTMIIMRDY_out;
    HOSTRDDATA <= HOSTRDDATA_out;      
  end TEMAC_SINGLE_V;

    
