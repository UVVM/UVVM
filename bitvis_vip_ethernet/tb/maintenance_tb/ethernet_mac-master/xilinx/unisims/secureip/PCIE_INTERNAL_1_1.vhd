-------------------------------------------------------------------------------
-- Copyright (c) 1995/2006 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor      : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       PCI Express
-- /___/   /\     Filename    : pcie_internal_1_1.vhd
-- \   \  /  \    Timestamp   : Thu Dec 8 2005
--  \___\/\___\
--
-- Revision:
--    12/08/05 - Initial version.
--    01/09/06 - Added architecture
--    01/23/06 - Parameter MC updates CR#224562
--    01/27/06 - CR#224810 Remove GSR pins
--    02/23/06 - Updated Header
--    04/24/06 - CR#230393 - Updated timing according to the spreadsheets
--    04/28/06 - CR#230712 - Spreadsheet update
--    05/23/06 - CR#231962 - Add buffers for connectivity
--    08/14/06 - CR#421379 - PCIE updated to PCIE_INTERNAL_1_1
--                         - spreadsheet updates on parameter default values
--    10/26/06 -           - replaced ZERO_DELAY with CLK_DELAY to be consistent with writers (PPC440 update)
-- End Revision

----- CELL PCIE_INTERNAL_1_1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity PCIE_INTERNAL_1_1 is
generic (
	ACTIVELANESIN : bit_vector := X"01";
	AERBASEPTR : bit_vector := X"110";
	AERCAPABILITYECRCCHECKCAPABLE : boolean := FALSE;
	AERCAPABILITYECRCGENCAPABLE : boolean := FALSE;
	AERCAPABILITYNEXTPTR : bit_vector := X"138";
	BAR0ADDRWIDTH : integer := 0;
	BAR0EXIST : boolean := TRUE;
	BAR0IOMEMN : integer := 0;
	BAR0MASKWIDTH : bit_vector := X"14";
	BAR0PREFETCHABLE : boolean := TRUE;
	BAR1ADDRWIDTH : integer := 0;
	BAR1EXIST : boolean := FALSE;
	BAR1IOMEMN : integer := 0;
	BAR1MASKWIDTH : bit_vector := X"00";
	BAR1PREFETCHABLE : boolean := FALSE;
	BAR2ADDRWIDTH : integer := 0;
	BAR2EXIST : boolean := FALSE;
	BAR2IOMEMN : integer := 0;
	BAR2MASKWIDTH : bit_vector := X"00";
	BAR2PREFETCHABLE : boolean := FALSE;
	BAR3ADDRWIDTH : integer := 0;
	BAR3EXIST : boolean := FALSE;
	BAR3IOMEMN : integer := 0;
	BAR3MASKWIDTH : bit_vector := X"00";
	BAR3PREFETCHABLE : boolean := FALSE;
	BAR4ADDRWIDTH : integer := 0;
	BAR4EXIST : boolean := FALSE;
	BAR4IOMEMN : integer := 0;
	BAR4MASKWIDTH : bit_vector := X"00";
	BAR4PREFETCHABLE : boolean := FALSE;
	BAR5EXIST : boolean := FALSE;
	BAR5IOMEMN : integer := 0;
	BAR5MASKWIDTH : bit_vector := X"00";
	BAR5PREFETCHABLE : boolean := FALSE;
	CAPABILITIESPOINTER : bit_vector := X"40";
	CARDBUSCISPOINTER : bit_vector := X"00000000";
	CLASSCODE : bit_vector := X"058000";
	CLKDIVIDED : boolean := FALSE;
	CONFIGROUTING : bit_vector := X"1";
	DEVICECAPABILITYENDPOINTL0SLATENCY : bit_vector := X"0";
	DEVICECAPABILITYENDPOINTL1LATENCY : bit_vector := X"0";
	DEVICEID : bit_vector := X"5050";
	DEVICESERIALNUMBER : bit_vector := X"E000000001000A35";
	DSNBASEPTR : bit_vector := X"148";
	DSNCAPABILITYNEXTPTR : bit_vector := X"154";
	DUALCOREENABLE : boolean := FALSE;
	DUALCORESLAVE : boolean := FALSE;
	DUALROLECFGCNTRLROOTEPN : integer := 0;
	EXTCFGCAPPTR : bit_vector := X"00";
	EXTCFGXPCAPPTR : bit_vector := X"000";
	HEADERTYPE : bit_vector := X"00";
	INFINITECOMPLETIONS : boolean := TRUE;
	INTERRUPTPIN : bit_vector := X"00";
	ISSWITCH : boolean := FALSE;
	L0SEXITLATENCY : integer := 7;
	L0SEXITLATENCYCOMCLK : integer := 7;
	L1EXITLATENCY : integer := 7;
	L1EXITLATENCYCOMCLK : integer := 7;
	LINKCAPABILITYASPMSUPPORT : bit_vector := X"1";
	LINKCAPABILITYMAXLINKWIDTH : bit_vector := X"01";
	LINKSTATUSSLOTCLOCKCONFIG : boolean := FALSE;
	LLKBYPASS : boolean := FALSE;
	LOWPRIORITYVCCOUNT : integer := 0;
	MSIBASEPTR : bit_vector := X"048";
	MSICAPABILITYMULTIMSGCAP : bit_vector := X"0";
	MSICAPABILITYNEXTPTR : bit_vector := X"60";
	PBBASEPTR : bit_vector := X"138";
	PBCAPABILITYDW0BASEPOWER : bit_vector := X"00";
	PBCAPABILITYDW0DATASCALE : bit_vector := X"0";
	PBCAPABILITYDW0PMSTATE : bit_vector := X"0";
	PBCAPABILITYDW0PMSUBSTATE : bit_vector := X"0";
	PBCAPABILITYDW0POWERRAIL : bit_vector := X"0";
	PBCAPABILITYDW0TYPE : bit_vector := X"0";
	PBCAPABILITYDW1BASEPOWER : bit_vector := X"00";
	PBCAPABILITYDW1DATASCALE : bit_vector := X"0";
	PBCAPABILITYDW1PMSTATE : bit_vector := X"0";
	PBCAPABILITYDW1PMSUBSTATE : bit_vector := X"0";
	PBCAPABILITYDW1POWERRAIL : bit_vector := X"0";
	PBCAPABILITYDW1TYPE : bit_vector := X"0";
	PBCAPABILITYDW2BASEPOWER : bit_vector := X"00";
	PBCAPABILITYDW2DATASCALE : bit_vector := X"0";
	PBCAPABILITYDW2PMSTATE : bit_vector := X"0";
	PBCAPABILITYDW2PMSUBSTATE : bit_vector := X"0";
	PBCAPABILITYDW2POWERRAIL : bit_vector := X"0";
	PBCAPABILITYDW2TYPE : bit_vector := X"0";
	PBCAPABILITYDW3BASEPOWER : bit_vector := X"00";
	PBCAPABILITYDW3DATASCALE : bit_vector := X"0";
	PBCAPABILITYDW3PMSTATE : bit_vector := X"0";
	PBCAPABILITYDW3PMSUBSTATE : bit_vector := X"0";
	PBCAPABILITYDW3POWERRAIL : bit_vector := X"0";
	PBCAPABILITYDW3TYPE : bit_vector := X"0";
	PBCAPABILITYNEXTPTR : bit_vector := X"148";
	PBCAPABILITYSYSTEMALLOCATED : boolean := FALSE;
	PCIECAPABILITYINTMSGNUM : bit_vector := X"00";
	PCIECAPABILITYNEXTPTR : bit_vector := X"00";
	PCIECAPABILITYSLOTIMPL : boolean := FALSE;
	PCIEREVISION : integer := 1;
	PMBASEPTR : bit_vector := X"040";
	PMCAPABILITYAUXCURRENT : bit_vector := X"0";
	PMCAPABILITYD1SUPPORT : boolean := FALSE;
	PMCAPABILITYD2SUPPORT : boolean := FALSE;
	PMCAPABILITYDSI : boolean := TRUE;
	PMCAPABILITYNEXTPTR : bit_vector := X"60";
	PMCAPABILITYPMESUPPORT : bit_vector := X"00";
	PMDATA0 : bit_vector := X"00";
	PMDATA1 : bit_vector := X"00";
	PMDATA2 : bit_vector := X"00";
	PMDATA3 : bit_vector := X"00";
	PMDATA4 : bit_vector := X"00";
	PMDATA5 : bit_vector := X"00";
	PMDATA6 : bit_vector := X"00";
	PMDATA7 : bit_vector := X"00";
	PMDATA8 : bit_vector := X"00";
	PMDATASCALE0 : integer := 0;
	PMDATASCALE1 : integer := 0;
	PMDATASCALE2 : integer := 0;
	PMDATASCALE3 : integer := 0;
	PMDATASCALE4 : integer := 0;
	PMDATASCALE5 : integer := 0;
	PMDATASCALE6 : integer := 0;
	PMDATASCALE7 : integer := 0;
	PMDATASCALE8 : integer := 0;
	PMSTATUSCONTROLDATASCALE : bit_vector := X"0";
	PORTVCCAPABILITYEXTENDEDVCCOUNT : bit_vector := X"0";
	PORTVCCAPABILITYVCARBCAP : bit_vector := X"00";
	PORTVCCAPABILITYVCARBTABLEOFFSET : bit_vector := X"00";
	RAMSHARETXRX : boolean := FALSE;
	RESETMODE : boolean := FALSE;
	RETRYRAMREADLATENCY : integer := 3;
	RETRYRAMSIZE : bit_vector := X"009";
	RETRYRAMWIDTH : integer := 0;
	RETRYRAMWRITELATENCY : integer := 1;
	RETRYREADADDRPIPE : boolean := FALSE;
	RETRYREADDATAPIPE : boolean := FALSE;
	RETRYWRITEPIPE : boolean := FALSE;
	REVISIONID : bit_vector := X"00";
	RXREADADDRPIPE : boolean := FALSE;
	RXREADDATAPIPE : boolean := FALSE;
	RXWRITEPIPE : boolean := FALSE;
	SELECTASMODE : boolean := FALSE;
	SELECTDLLIF : boolean := FALSE;
	SLOTCAPABILITYATTBUTTONPRESENT : boolean := FALSE;
	SLOTCAPABILITYATTINDICATORPRESENT : boolean := FALSE;
	SLOTCAPABILITYHOTPLUGCAPABLE : boolean := FALSE;
	SLOTCAPABILITYHOTPLUGSURPRISE : boolean := FALSE;
	SLOTCAPABILITYMSLSENSORPRESENT : boolean := FALSE;
	SLOTCAPABILITYPHYSICALSLOTNUM : bit_vector := X"0000";
	SLOTCAPABILITYPOWERCONTROLLERPRESENT : boolean := FALSE;
	SLOTCAPABILITYPOWERINDICATORPRESENT : boolean := FALSE;
	SLOTCAPABILITYSLOTPOWERLIMITSCALE : bit_vector := X"0";
	SLOTCAPABILITYSLOTPOWERLIMITVALUE : bit_vector := X"00";
	SLOTIMPLEMENTED : boolean := FALSE;
	SUBSYSTEMID : bit_vector := X"5050";
	SUBSYSTEMVENDORID : bit_vector := X"10EE";
	TLRAMREADLATENCY : integer := 3;
	TLRAMWIDTH : integer := 0;
	TLRAMWRITELATENCY : integer := 1;
	TXREADADDRPIPE : boolean := FALSE;
	TXREADDATAPIPE : boolean := FALSE;
	TXTSNFTS : integer := 255;
	TXTSNFTSCOMCLK : integer := 255;
	TXWRITEPIPE : boolean := FALSE;
	UPSTREAMFACING : boolean := TRUE;
	VC0RXFIFOBASEC : bit_vector := X"0098";
	VC0RXFIFOBASENP : bit_vector := X"0080";
	VC0RXFIFOBASEP : bit_vector := X"0000";
	VC0RXFIFOLIMITC : bit_vector := X"0117";
	VC0RXFIFOLIMITNP : bit_vector := X"0097";
	VC0RXFIFOLIMITP : bit_vector := X"007f";
	VC0TOTALCREDITSCD : bit_vector := X"000";
	VC0TOTALCREDITSCH : bit_vector := X"00";
	VC0TOTALCREDITSNPH : bit_vector := X"08";
	VC0TOTALCREDITSPD : bit_vector := X"034";
	VC0TOTALCREDITSPH : bit_vector := X"08";
	VC0TXFIFOBASEC : bit_vector := X"0098";
	VC0TXFIFOBASENP : bit_vector := X"0080";
	VC0TXFIFOBASEP : bit_vector := X"0000";
	VC0TXFIFOLIMITC : bit_vector := X"0117";
	VC0TXFIFOLIMITNP : bit_vector := X"0097";
	VC0TXFIFOLIMITP : bit_vector := X"007f";
	VC1RXFIFOBASEC : bit_vector := X"0118";
	VC1RXFIFOBASENP : bit_vector := X"0118";
	VC1RXFIFOBASEP : bit_vector := X"0118";
	VC1RXFIFOLIMITC : bit_vector := X"0118";
	VC1RXFIFOLIMITNP : bit_vector := X"0118";
	VC1RXFIFOLIMITP : bit_vector := X"0118";
	VC1TOTALCREDITSCD : bit_vector := X"000";
	VC1TOTALCREDITSCH : bit_vector := X"00";
	VC1TOTALCREDITSNPH : bit_vector := X"00";
	VC1TOTALCREDITSPD : bit_vector := X"000";
	VC1TOTALCREDITSPH : bit_vector := X"00";
	VC1TXFIFOBASEC : bit_vector := X"0118";
	VC1TXFIFOBASENP : bit_vector := X"0118";
	VC1TXFIFOBASEP : bit_vector := X"0118";
	VC1TXFIFOLIMITC : bit_vector := X"0118";
	VC1TXFIFOLIMITNP : bit_vector := X"0118";
	VC1TXFIFOLIMITP : bit_vector := X"0118";
	VCBASEPTR : bit_vector := X"154";
	VCCAPABILITYNEXTPTR : bit_vector := X"000";
	VENDORID : bit_vector := X"10EE";
	XLINKSUPPORTED : boolean := FALSE;
	XPBASEPTR : bit_vector := X"60";
	XPDEVICEPORTTYPE : bit_vector := X"0";
	XPMAXPAYLOAD : integer := 0;
	XPRCBCONTROL : integer := 0




  );

port (
		BUSMASTERENABLE : out std_ulogic;
		CRMDOHOTRESETN : out std_ulogic;
		CRMPWRSOFTRESETN : out std_ulogic;
		CRMRXHOTRESETN : out std_ulogic;
		DLLTXPMDLLPOUTSTANDING : out std_ulogic;
		INTERRUPTDISABLE : out std_ulogic;
		IOSPACEENABLE : out std_ulogic;
		L0ASAUTONOMOUSINITCOMPLETED : out std_ulogic;
		L0ATTENTIONINDICATORCONTROL : out std_logic_vector(1 downto 0);
		L0CFGLOOPBACKACK : out std_ulogic;
		L0COMPLETERID : out std_logic_vector(12 downto 0);
		L0CORRERRMSGRCVD : out std_ulogic;
		L0DLLASRXSTATE : out std_logic_vector(1 downto 0);
		L0DLLASTXSTATE : out std_ulogic;
		L0DLLERRORVECTOR : out std_logic_vector(6 downto 0);
		L0DLLRXACKOUTSTANDING : out std_ulogic;
		L0DLLTXNONFCOUTSTANDING : out std_ulogic;
		L0DLLTXOUTSTANDING : out std_ulogic;
		L0DLLVCSTATUS : out std_logic_vector(7 downto 0);
		L0DLUPDOWN : out std_logic_vector(7 downto 0);
		L0ERRMSGREQID : out std_logic_vector(15 downto 0);
		L0FATALERRMSGRCVD : out std_ulogic;
		L0FIRSTCFGWRITEOCCURRED : out std_ulogic;
		L0FWDCORRERROUT : out std_ulogic;
		L0FWDFATALERROUT : out std_ulogic;
		L0FWDNONFATALERROUT : out std_ulogic;
		L0LTSSMSTATE : out std_logic_vector(3 downto 0);
		L0MACENTEREDL0 : out std_ulogic;
		L0MACLINKTRAINING : out std_ulogic;
		L0MACLINKUP : out std_ulogic;
		L0MACNEGOTIATEDLINKWIDTH : out std_logic_vector(3 downto 0);
		L0MACNEWSTATEACK : out std_ulogic;
		L0MACRXL0SSTATE : out std_ulogic;
		L0MACUPSTREAMDOWNSTREAM : out std_ulogic;
		L0MCFOUND : out std_logic_vector(2 downto 0);
		L0MSIENABLE0 : out std_ulogic;
		L0MULTIMSGEN0 : out std_logic_vector(2 downto 0);
		L0NONFATALERRMSGRCVD : out std_ulogic;
		L0PMEACK : out std_ulogic;
		L0PMEEN : out std_ulogic;
		L0PMEREQOUT : out std_ulogic;
		L0POWERCONTROLLERCONTROL : out std_ulogic;
		L0POWERINDICATORCONTROL : out std_logic_vector(1 downto 0);
		L0PWRINHIBITTRANSFERS : out std_ulogic;
		L0PWRL1STATE : out std_ulogic;
		L0PWRL23READYDEVICE : out std_ulogic;
		L0PWRL23READYSTATE : out std_ulogic;
		L0PWRSTATE0 : out std_logic_vector(1 downto 0);
		L0PWRTURNOFFREQ : out std_ulogic;
		L0PWRTXL0SSTATE : out std_ulogic;
		L0RECEIVEDASSERTINTALEGACYINT : out std_ulogic;
		L0RECEIVEDASSERTINTBLEGACYINT : out std_ulogic;
		L0RECEIVEDASSERTINTCLEGACYINT : out std_ulogic;
		L0RECEIVEDASSERTINTDLEGACYINT : out std_ulogic;
		L0RECEIVEDDEASSERTINTALEGACYINT : out std_ulogic;
		L0RECEIVEDDEASSERTINTBLEGACYINT : out std_ulogic;
		L0RECEIVEDDEASSERTINTCLEGACYINT : out std_ulogic;
		L0RECEIVEDDEASSERTINTDLEGACYINT : out std_ulogic;
		L0RXBEACON : out std_ulogic;
		L0RXDLLFCCMPLMCCRED : out std_logic_vector(23 downto 0);
		L0RXDLLFCCMPLMCUPDATE : out std_logic_vector(7 downto 0);
		L0RXDLLFCNPOSTBYPCRED : out std_logic_vector(19 downto 0);
		L0RXDLLFCNPOSTBYPUPDATE : out std_logic_vector(7 downto 0);
		L0RXDLLFCPOSTORDCRED : out std_logic_vector(23 downto 0);
		L0RXDLLFCPOSTORDUPDATE : out std_logic_vector(7 downto 0);
		L0RXDLLPM : out std_ulogic;
		L0RXDLLPMTYPE : out std_logic_vector(2 downto 0);
		L0RXDLLSBFCDATA : out std_logic_vector(18 downto 0);
		L0RXDLLSBFCUPDATE : out std_ulogic;
		L0RXDLLTLPECRCOK : out std_ulogic;
		L0RXDLLTLPEND : out std_logic_vector(1 downto 0);
		L0RXMACLINKERROR : out std_logic_vector(1 downto 0);
		L0STATSCFGOTHERRECEIVED : out std_ulogic;
		L0STATSCFGOTHERTRANSMITTED : out std_ulogic;
		L0STATSCFGRECEIVED : out std_ulogic;
		L0STATSCFGTRANSMITTED : out std_ulogic;
		L0STATSDLLPRECEIVED : out std_ulogic;
		L0STATSDLLPTRANSMITTED : out std_ulogic;
		L0STATSOSRECEIVED : out std_ulogic;
		L0STATSOSTRANSMITTED : out std_ulogic;
		L0STATSTLPRECEIVED : out std_ulogic;
		L0STATSTLPTRANSMITTED : out std_ulogic;
		L0TOGGLEELECTROMECHANICALINTERLOCK : out std_ulogic;
		L0TRANSFORMEDVC : out std_logic_vector(2 downto 0);
		L0TXDLLFCCMPLMCUPDATED : out std_logic_vector(7 downto 0);
		L0TXDLLFCNPOSTBYPUPDATED : out std_logic_vector(7 downto 0);
		L0TXDLLFCPOSTORDUPDATED : out std_logic_vector(7 downto 0);
		L0TXDLLPMUPDATED : out std_ulogic;
		L0TXDLLSBFCUPDATED : out std_ulogic;
		L0UCBYPFOUND : out std_logic_vector(3 downto 0);
		L0UCORDFOUND : out std_logic_vector(3 downto 0);
		L0UNLOCKRECEIVED : out std_ulogic;
		LLKRX4DWHEADERN : out std_ulogic;
		LLKRXCHCOMPLETIONAVAILABLEN : out std_logic_vector(7 downto 0);
		LLKRXCHCOMPLETIONPARTIALN : out std_logic_vector(7 downto 0);
		LLKRXCHCONFIGAVAILABLEN : out std_ulogic;
		LLKRXCHCONFIGPARTIALN : out std_ulogic;
		LLKRXCHNONPOSTEDAVAILABLEN : out std_logic_vector(7 downto 0);
		LLKRXCHNONPOSTEDPARTIALN : out std_logic_vector(7 downto 0);
		LLKRXCHPOSTEDAVAILABLEN : out std_logic_vector(7 downto 0);
		LLKRXCHPOSTEDPARTIALN : out std_logic_vector(7 downto 0);
		LLKRXDATA : out std_logic_vector(63 downto 0);
		LLKRXECRCBADN : out std_ulogic;
		LLKRXEOFN : out std_ulogic;
		LLKRXEOPN : out std_ulogic;
		LLKRXPREFERREDTYPE : out std_logic_vector(15 downto 0);
		LLKRXSOFN : out std_ulogic;
		LLKRXSOPN : out std_ulogic;
		LLKRXSRCDSCN : out std_ulogic;
		LLKRXSRCLASTREQN : out std_ulogic;
		LLKRXSRCRDYN : out std_ulogic;
		LLKRXVALIDN : out std_logic_vector(1 downto 0);
		LLKTCSTATUS : out std_logic_vector(7 downto 0);
		LLKTXCHANSPACE : out std_logic_vector(9 downto 0);
		LLKTXCHCOMPLETIONREADYN : out std_logic_vector(7 downto 0);
		LLKTXCHNONPOSTEDREADYN : out std_logic_vector(7 downto 0);
		LLKTXCHPOSTEDREADYN : out std_logic_vector(7 downto 0);
		LLKTXCONFIGREADYN : out std_ulogic;
		LLKTXDSTRDYN : out std_ulogic;
		MAXPAYLOADSIZE : out std_logic_vector(2 downto 0);
		MAXREADREQUESTSIZE : out std_logic_vector(2 downto 0);
		MEMSPACEENABLE : out std_ulogic;
		MGMTPSO : out std_logic_vector(16 downto 0);
		MGMTRDATA : out std_logic_vector(31 downto 0);
		MGMTSTATSCREDIT : out std_logic_vector(11 downto 0);
		MIMDLLBRADD : out std_logic_vector(11 downto 0);
		MIMDLLBREN : out std_ulogic;
		MIMDLLBWADD : out std_logic_vector(11 downto 0);
		MIMDLLBWDATA : out std_logic_vector(63 downto 0);
		MIMDLLBWEN : out std_ulogic;
		MIMRXBRADD : out std_logic_vector(12 downto 0);
		MIMRXBREN : out std_ulogic;
		MIMRXBWADD : out std_logic_vector(12 downto 0);
		MIMRXBWDATA : out std_logic_vector(63 downto 0);
		MIMRXBWEN : out std_ulogic;
		MIMTXBRADD : out std_logic_vector(12 downto 0);
		MIMTXBREN : out std_ulogic;
		MIMTXBWADD : out std_logic_vector(12 downto 0);
		MIMTXBWDATA : out std_logic_vector(63 downto 0);
		MIMTXBWEN : out std_ulogic;
		PARITYERRORRESPONSE : out std_ulogic;
		PIPEDESKEWLANESL0 : out std_ulogic;
		PIPEDESKEWLANESL1 : out std_ulogic;
		PIPEDESKEWLANESL2 : out std_ulogic;
		PIPEDESKEWLANESL3 : out std_ulogic;
		PIPEDESKEWLANESL4 : out std_ulogic;
		PIPEDESKEWLANESL5 : out std_ulogic;
		PIPEDESKEWLANESL6 : out std_ulogic;
		PIPEDESKEWLANESL7 : out std_ulogic;
		PIPEPOWERDOWNL0 : out std_logic_vector(1 downto 0);
		PIPEPOWERDOWNL1 : out std_logic_vector(1 downto 0);
		PIPEPOWERDOWNL2 : out std_logic_vector(1 downto 0);
		PIPEPOWERDOWNL3 : out std_logic_vector(1 downto 0);
		PIPEPOWERDOWNL4 : out std_logic_vector(1 downto 0);
		PIPEPOWERDOWNL5 : out std_logic_vector(1 downto 0);
		PIPEPOWERDOWNL6 : out std_logic_vector(1 downto 0);
		PIPEPOWERDOWNL7 : out std_logic_vector(1 downto 0);
		PIPERESETL0 : out std_ulogic;
		PIPERESETL1 : out std_ulogic;
		PIPERESETL2 : out std_ulogic;
		PIPERESETL3 : out std_ulogic;
		PIPERESETL4 : out std_ulogic;
		PIPERESETL5 : out std_ulogic;
		PIPERESETL6 : out std_ulogic;
		PIPERESETL7 : out std_ulogic;
		PIPERXPOLARITYL0 : out std_ulogic;
		PIPERXPOLARITYL1 : out std_ulogic;
		PIPERXPOLARITYL2 : out std_ulogic;
		PIPERXPOLARITYL3 : out std_ulogic;
		PIPERXPOLARITYL4 : out std_ulogic;
		PIPERXPOLARITYL5 : out std_ulogic;
		PIPERXPOLARITYL6 : out std_ulogic;
		PIPERXPOLARITYL7 : out std_ulogic;
		PIPETXCOMPLIANCEL0 : out std_ulogic;
		PIPETXCOMPLIANCEL1 : out std_ulogic;
		PIPETXCOMPLIANCEL2 : out std_ulogic;
		PIPETXCOMPLIANCEL3 : out std_ulogic;
		PIPETXCOMPLIANCEL4 : out std_ulogic;
		PIPETXCOMPLIANCEL5 : out std_ulogic;
		PIPETXCOMPLIANCEL6 : out std_ulogic;
		PIPETXCOMPLIANCEL7 : out std_ulogic;
		PIPETXDATAKL0 : out std_ulogic;
		PIPETXDATAKL1 : out std_ulogic;
		PIPETXDATAKL2 : out std_ulogic;
		PIPETXDATAKL3 : out std_ulogic;
		PIPETXDATAKL4 : out std_ulogic;
		PIPETXDATAKL5 : out std_ulogic;
		PIPETXDATAKL6 : out std_ulogic;
		PIPETXDATAKL7 : out std_ulogic;
		PIPETXDATAL0 : out std_logic_vector(7 downto 0);
		PIPETXDATAL1 : out std_logic_vector(7 downto 0);
		PIPETXDATAL2 : out std_logic_vector(7 downto 0);
		PIPETXDATAL3 : out std_logic_vector(7 downto 0);
		PIPETXDATAL4 : out std_logic_vector(7 downto 0);
		PIPETXDATAL5 : out std_logic_vector(7 downto 0);
		PIPETXDATAL6 : out std_logic_vector(7 downto 0);
		PIPETXDATAL7 : out std_logic_vector(7 downto 0);
		PIPETXDETECTRXLOOPBACKL0 : out std_ulogic;
		PIPETXDETECTRXLOOPBACKL1 : out std_ulogic;
		PIPETXDETECTRXLOOPBACKL2 : out std_ulogic;
		PIPETXDETECTRXLOOPBACKL3 : out std_ulogic;
		PIPETXDETECTRXLOOPBACKL4 : out std_ulogic;
		PIPETXDETECTRXLOOPBACKL5 : out std_ulogic;
		PIPETXDETECTRXLOOPBACKL6 : out std_ulogic;
		PIPETXDETECTRXLOOPBACKL7 : out std_ulogic;
		PIPETXELECIDLEL0 : out std_ulogic;
		PIPETXELECIDLEL1 : out std_ulogic;
		PIPETXELECIDLEL2 : out std_ulogic;
		PIPETXELECIDLEL3 : out std_ulogic;
		PIPETXELECIDLEL4 : out std_ulogic;
		PIPETXELECIDLEL5 : out std_ulogic;
		PIPETXELECIDLEL6 : out std_ulogic;
		PIPETXELECIDLEL7 : out std_ulogic;
		SERRENABLE : out std_ulogic;
		URREPORTINGENABLE : out std_ulogic;

		AUXPOWER : in std_ulogic;
		CFGNEGOTIATEDLINKWIDTH : in std_logic_vector(5 downto 0);
		COMPLIANCEAVOID : in std_ulogic;
		CRMCFGBRIDGEHOTRESET : in std_ulogic;
		CRMCORECLK : in std_ulogic;
		CRMCORECLKDLO : in std_ulogic;
		CRMCORECLKRXO : in std_ulogic;
		CRMCORECLKTXO : in std_ulogic;
		CRMLINKRSTN : in std_ulogic;
		CRMMACRSTN : in std_ulogic;
		CRMMGMTRSTN : in std_ulogic;
		CRMNVRSTN : in std_ulogic;
		CRMTXHOTRESETN : in std_ulogic;
		CRMURSTN : in std_ulogic;
		CRMUSERCFGRSTN : in std_ulogic;
		CRMUSERCLK : in std_ulogic;
		CRMUSERCLKRXO : in std_ulogic;
		CRMUSERCLKTXO : in std_ulogic;
		CROSSLINKSEED : in std_ulogic;
		L0ACKNAKTIMERADJUSTMENT : in std_logic_vector(11 downto 0);
		L0ALLDOWNPORTSINL1 : in std_ulogic;
		L0ALLDOWNRXPORTSINL0S : in std_ulogic;
		L0ASE : in std_ulogic;
		L0ASPORTCOUNT : in std_logic_vector(7 downto 0);
		L0ASTURNPOOLBITSCONSUMED : in std_logic_vector(2 downto 0);
		L0ATTENTIONBUTTONPRESSED : in std_ulogic;
		L0CFGASSPANTREEOWNEDSTATE : in std_ulogic;
		L0CFGASSTATECHANGECMD : in std_logic_vector(3 downto 0);
		L0CFGDISABLESCRAMBLE : in std_ulogic;
		L0CFGEXTENDEDSYNC : in std_ulogic;
		L0CFGL0SENTRYENABLE : in std_ulogic;
		L0CFGL0SENTRYSUP : in std_ulogic;
		L0CFGL0SEXITLAT : in std_logic_vector(2 downto 0);
		L0CFGLINKDISABLE : in std_ulogic;
		L0CFGLOOPBACKMASTER : in std_ulogic;
		L0CFGNEGOTIATEDMAXP : in std_logic_vector(2 downto 0);
		L0CFGVCENABLE : in std_logic_vector(7 downto 0);
		L0CFGVCID : in std_logic_vector(23 downto 0);
		L0DLLHOLDLINKUP : in std_ulogic;
		L0ELECTROMECHANICALINTERLOCKENGAGED : in std_ulogic;
		L0FWDASSERTINTALEGACYINT : in std_ulogic;
		L0FWDASSERTINTBLEGACYINT : in std_ulogic;
		L0FWDASSERTINTCLEGACYINT : in std_ulogic;
		L0FWDASSERTINTDLEGACYINT : in std_ulogic;
		L0FWDCORRERRIN : in std_ulogic;
		L0FWDDEASSERTINTALEGACYINT : in std_ulogic;
		L0FWDDEASSERTINTBLEGACYINT : in std_ulogic;
		L0FWDDEASSERTINTCLEGACYINT : in std_ulogic;
		L0FWDDEASSERTINTDLEGACYINT : in std_ulogic;
		L0FWDFATALERRIN : in std_ulogic;
		L0FWDNONFATALERRIN : in std_ulogic;
		L0LEGACYINTFUNCT0 : in std_ulogic;
		L0MRLSENSORCLOSEDN : in std_ulogic;
		L0MSIREQUEST0 : in std_logic_vector(3 downto 0);
		L0PACKETHEADERFROMUSER : in std_logic_vector(127 downto 0);
		L0PMEREQIN : in std_ulogic;
		L0PORTNUMBER : in std_logic_vector(7 downto 0);
		L0POWERFAULTDETECTED : in std_ulogic;
		L0PRESENCEDETECTSLOTEMPTYN : in std_ulogic;
		L0PWRNEWSTATEREQ : in std_ulogic;
		L0PWRNEXTLINKSTATE : in std_logic_vector(1 downto 0);
		L0REPLAYTIMERADJUSTMENT : in std_logic_vector(11 downto 0);
		L0ROOTTURNOFFREQ : in std_ulogic;
		L0RXTLTLPNONINITIALIZEDVC : in std_logic_vector(7 downto 0);
		L0SENDUNLOCKMESSAGE : in std_ulogic;
		L0SETCOMPLETERABORTERROR : in std_ulogic;
		L0SETCOMPLETIONTIMEOUTCORRERROR : in std_ulogic;
		L0SETCOMPLETIONTIMEOUTUNCORRERROR : in std_ulogic;
		L0SETDETECTEDCORRERROR : in std_ulogic;
		L0SETDETECTEDFATALERROR : in std_ulogic;
		L0SETDETECTEDNONFATALERROR : in std_ulogic;
		L0SETLINKDETECTEDPARITYERROR : in std_ulogic;
		L0SETLINKMASTERDATAPARITY : in std_ulogic;
		L0SETLINKRECEIVEDMASTERABORT : in std_ulogic;
		L0SETLINKRECEIVEDTARGETABORT : in std_ulogic;
		L0SETLINKSIGNALLEDTARGETABORT : in std_ulogic;
		L0SETLINKSYSTEMERROR : in std_ulogic;
		L0SETUNEXPECTEDCOMPLETIONCORRERROR : in std_ulogic;
		L0SETUNEXPECTEDCOMPLETIONUNCORRERROR : in std_ulogic;
		L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR : in std_ulogic;
		L0SETUNSUPPORTEDREQUESTOTHERERROR : in std_ulogic;
		L0SETUSERDETECTEDPARITYERROR : in std_ulogic;
		L0SETUSERMASTERDATAPARITY : in std_ulogic;
		L0SETUSERRECEIVEDMASTERABORT : in std_ulogic;
		L0SETUSERRECEIVEDTARGETABORT : in std_ulogic;
		L0SETUSERSIGNALLEDTARGETABORT : in std_ulogic;
		L0SETUSERSYSTEMERROR : in std_ulogic;
		L0TLASFCCREDSTARVATION : in std_ulogic;
		L0TLLINKRETRAIN : in std_ulogic;
		L0TRANSACTIONSPENDING : in std_ulogic;
		L0TXBEACON : in std_ulogic;
		L0TXCFGPM : in std_ulogic;
		L0TXCFGPMTYPE : in std_logic_vector(2 downto 0);
		L0TXTLFCCMPLMCCRED : in std_logic_vector(159 downto 0);
		L0TXTLFCCMPLMCUPDATE : in std_logic_vector(15 downto 0);
		L0TXTLFCNPOSTBYPCRED : in std_logic_vector(191 downto 0);
		L0TXTLFCNPOSTBYPUPDATE : in std_logic_vector(15 downto 0);
		L0TXTLFCPOSTORDCRED : in std_logic_vector(159 downto 0);
		L0TXTLFCPOSTORDUPDATE : in std_logic_vector(15 downto 0);
		L0TXTLSBFCDATA : in std_logic_vector(18 downto 0);
		L0TXTLSBFCUPDATE : in std_ulogic;
		L0TXTLTLPDATA : in std_logic_vector(63 downto 0);
		L0TXTLTLPEDB : in std_ulogic;
		L0TXTLTLPENABLE : in std_logic_vector(1 downto 0);
		L0TXTLTLPEND : in std_logic_vector(1 downto 0);
		L0TXTLTLPLATENCY : in std_logic_vector(3 downto 0);
		L0TXTLTLPREQ : in std_ulogic;
		L0TXTLTLPREQEND : in std_ulogic;
		L0TXTLTLPWIDTH : in std_ulogic;
		L0UPSTREAMRXPORTINL0S : in std_ulogic;
		L0VC0PREVIEWEXPAND : in std_ulogic;
		L0WAKEN : in std_ulogic;
		LLKRXCHFIFO : in std_logic_vector(1 downto 0);
		LLKRXCHTC : in std_logic_vector(2 downto 0);
		LLKRXDSTCONTREQN : in std_ulogic;
		LLKRXDSTREQN : in std_ulogic;
		LLKTX4DWHEADERN : in std_ulogic;
		LLKTXCHFIFO : in std_logic_vector(1 downto 0);
		LLKTXCHTC : in std_logic_vector(2 downto 0);
		LLKTXCOMPLETEN : in std_ulogic;
		LLKTXCREATEECRCN : in std_ulogic;
		LLKTXDATA : in std_logic_vector(63 downto 0);
		LLKTXENABLEN : in std_logic_vector(1 downto 0);
		LLKTXEOFN : in std_ulogic;
		LLKTXEOPN : in std_ulogic;
		LLKTXSOFN : in std_ulogic;
		LLKTXSOPN : in std_ulogic;
		LLKTXSRCDSCN : in std_ulogic;
		LLKTXSRCRDYN : in std_ulogic;
		MAINPOWER : in std_ulogic;
		MGMTADDR : in std_logic_vector(10 downto 0);
		MGMTBWREN : in std_logic_vector(3 downto 0);
		MGMTRDEN : in std_ulogic;
		MGMTSTATSCREDITSEL : in std_logic_vector(6 downto 0);
		MGMTWDATA : in std_logic_vector(31 downto 0);
		MGMTWREN : in std_ulogic;
		MIMDLLBRDATA : in std_logic_vector(63 downto 0);
		MIMRXBRDATA : in std_logic_vector(63 downto 0);
		MIMTXBRDATA : in std_logic_vector(63 downto 0);
		PIPEPHYSTATUSL0 : in std_ulogic;
		PIPEPHYSTATUSL1 : in std_ulogic;
		PIPEPHYSTATUSL2 : in std_ulogic;
		PIPEPHYSTATUSL3 : in std_ulogic;
		PIPEPHYSTATUSL4 : in std_ulogic;
		PIPEPHYSTATUSL5 : in std_ulogic;
		PIPEPHYSTATUSL6 : in std_ulogic;
		PIPEPHYSTATUSL7 : in std_ulogic;
		PIPERXCHANISALIGNEDL0 : in std_ulogic;
		PIPERXCHANISALIGNEDL1 : in std_ulogic;
		PIPERXCHANISALIGNEDL2 : in std_ulogic;
		PIPERXCHANISALIGNEDL3 : in std_ulogic;
		PIPERXCHANISALIGNEDL4 : in std_ulogic;
		PIPERXCHANISALIGNEDL5 : in std_ulogic;
		PIPERXCHANISALIGNEDL6 : in std_ulogic;
		PIPERXCHANISALIGNEDL7 : in std_ulogic;
		PIPERXDATAKL0 : in std_ulogic;
		PIPERXDATAKL1 : in std_ulogic;
		PIPERXDATAKL2 : in std_ulogic;
		PIPERXDATAKL3 : in std_ulogic;
		PIPERXDATAKL4 : in std_ulogic;
		PIPERXDATAKL5 : in std_ulogic;
		PIPERXDATAKL6 : in std_ulogic;
		PIPERXDATAKL7 : in std_ulogic;
		PIPERXDATAL0 : in std_logic_vector(7 downto 0);
		PIPERXDATAL1 : in std_logic_vector(7 downto 0);
		PIPERXDATAL2 : in std_logic_vector(7 downto 0);
		PIPERXDATAL3 : in std_logic_vector(7 downto 0);
		PIPERXDATAL4 : in std_logic_vector(7 downto 0);
		PIPERXDATAL5 : in std_logic_vector(7 downto 0);
		PIPERXDATAL6 : in std_logic_vector(7 downto 0);
		PIPERXDATAL7 : in std_logic_vector(7 downto 0);
		PIPERXELECIDLEL0 : in std_ulogic;
		PIPERXELECIDLEL1 : in std_ulogic;
		PIPERXELECIDLEL2 : in std_ulogic;
		PIPERXELECIDLEL3 : in std_ulogic;
		PIPERXELECIDLEL4 : in std_ulogic;
		PIPERXELECIDLEL5 : in std_ulogic;
		PIPERXELECIDLEL6 : in std_ulogic;
		PIPERXELECIDLEL7 : in std_ulogic;
		PIPERXSTATUSL0 : in std_logic_vector(2 downto 0);
		PIPERXSTATUSL1 : in std_logic_vector(2 downto 0);
		PIPERXSTATUSL2 : in std_logic_vector(2 downto 0);
		PIPERXSTATUSL3 : in std_logic_vector(2 downto 0);
		PIPERXSTATUSL4 : in std_logic_vector(2 downto 0);
		PIPERXSTATUSL5 : in std_logic_vector(2 downto 0);
		PIPERXSTATUSL6 : in std_logic_vector(2 downto 0);
		PIPERXSTATUSL7 : in std_logic_vector(2 downto 0);
		PIPERXVALIDL0 : in std_ulogic;
		PIPERXVALIDL1 : in std_ulogic;
		PIPERXVALIDL2 : in std_ulogic;
		PIPERXVALIDL3 : in std_ulogic;
		PIPERXVALIDL4 : in std_ulogic;
		PIPERXVALIDL5 : in std_ulogic;
		PIPERXVALIDL6 : in std_ulogic;
		PIPERXVALIDL7 : in std_ulogic
     );
end PCIE_INTERNAL_1_1;

architecture PCIE_INTERNAL_1_1_V of PCIE_INTERNAL_1_1 is

  component PCIE_INTERNAL_1_1_SWIFT
    port (
      BUSMASTERENABLE      : out std_ulogic;
      CRMDOHOTRESETN       : out std_ulogic;
      CRMPWRSOFTRESETN     : out std_ulogic;
      CRMRXHOTRESETN       : out std_ulogic;
      DLLTXPMDLLPOUTSTANDING : out std_ulogic;
      INTERRUPTDISABLE     : out std_ulogic;
      IOSPACEENABLE        : out std_ulogic;
      L0ASAUTONOMOUSINITCOMPLETED : out std_ulogic;
      L0ATTENTIONINDICATORCONTROL : out std_logic_vector(1 downto 0);
      L0CFGLOOPBACKACK     : out std_ulogic;
      L0COMPLETERID        : out std_logic_vector(12 downto 0);
      L0CORRERRMSGRCVD     : out std_ulogic;
      L0DLLASRXSTATE       : out std_logic_vector(1 downto 0);
      L0DLLASTXSTATE       : out std_ulogic;
      L0DLLERRORVECTOR     : out std_logic_vector(6 downto 0);
      L0DLLRXACKOUTSTANDING : out std_ulogic;
      L0DLLTXNONFCOUTSTANDING : out std_ulogic;
      L0DLLTXOUTSTANDING   : out std_ulogic;
      L0DLLVCSTATUS        : out std_logic_vector(7 downto 0);
      L0DLUPDOWN           : out std_logic_vector(7 downto 0);
      L0ERRMSGREQID        : out std_logic_vector(15 downto 0);
      L0FATALERRMSGRCVD    : out std_ulogic;
      L0FIRSTCFGWRITEOCCURRED : out std_ulogic;
      L0FWDCORRERROUT      : out std_ulogic;
      L0FWDFATALERROUT     : out std_ulogic;
      L0FWDNONFATALERROUT  : out std_ulogic;
      L0LTSSMSTATE         : out std_logic_vector(3 downto 0);
      L0MACENTEREDL0       : out std_ulogic;
      L0MACLINKTRAINING    : out std_ulogic;
      L0MACLINKUP          : out std_ulogic;
      L0MACNEGOTIATEDLINKWIDTH : out std_logic_vector(3 downto 0);
      L0MACNEWSTATEACK     : out std_ulogic;
      L0MACRXL0SSTATE      : out std_ulogic;
      L0MACUPSTREAMDOWNSTREAM : out std_ulogic;
      L0MCFOUND            : out std_logic_vector(2 downto 0);
      L0MSIENABLE0         : out std_ulogic;
      L0MULTIMSGEN0        : out std_logic_vector(2 downto 0);
      L0NONFATALERRMSGRCVD : out std_ulogic;
      L0PMEACK             : out std_ulogic;
      L0PMEEN              : out std_ulogic;
      L0PMEREQOUT          : out std_ulogic;
      L0POWERCONTROLLERCONTROL : out std_ulogic;
      L0POWERINDICATORCONTROL : out std_logic_vector(1 downto 0);
      L0PWRINHIBITTRANSFERS : out std_ulogic;
      L0PWRL1STATE         : out std_ulogic;
      L0PWRL23READYDEVICE  : out std_ulogic;
      L0PWRL23READYSTATE   : out std_ulogic;
      L0PWRSTATE0          : out std_logic_vector(1 downto 0);
      L0PWRTURNOFFREQ      : out std_ulogic;
      L0PWRTXL0SSTATE      : out std_ulogic;
      L0RECEIVEDASSERTINTALEGACYINT : out std_ulogic;
      L0RECEIVEDASSERTINTBLEGACYINT : out std_ulogic;
      L0RECEIVEDASSERTINTCLEGACYINT : out std_ulogic;
      L0RECEIVEDASSERTINTDLEGACYINT : out std_ulogic;
      L0RECEIVEDDEASSERTINTALEGACYINT : out std_ulogic;
      L0RECEIVEDDEASSERTINTBLEGACYINT : out std_ulogic;
      L0RECEIVEDDEASSERTINTCLEGACYINT : out std_ulogic;
      L0RECEIVEDDEASSERTINTDLEGACYINT : out std_ulogic;
      L0RXBEACON           : out std_ulogic;
      L0RXDLLFCCMPLMCCRED  : out std_logic_vector(23 downto 0);
      L0RXDLLFCCMPLMCUPDATE : out std_logic_vector(7 downto 0);
      L0RXDLLFCNPOSTBYPCRED : out std_logic_vector(19 downto 0);
      L0RXDLLFCNPOSTBYPUPDATE : out std_logic_vector(7 downto 0);
      L0RXDLLFCPOSTORDCRED : out std_logic_vector(23 downto 0);
      L0RXDLLFCPOSTORDUPDATE : out std_logic_vector(7 downto 0);
      L0RXDLLPM            : out std_ulogic;
      L0RXDLLPMTYPE        : out std_logic_vector(2 downto 0);
      L0RXDLLSBFCDATA      : out std_logic_vector(18 downto 0);
      L0RXDLLSBFCUPDATE    : out std_ulogic;
      L0RXDLLTLPECRCOK     : out std_ulogic;
      L0RXDLLTLPEND        : out std_logic_vector(1 downto 0);
      L0RXMACLINKERROR     : out std_logic_vector(1 downto 0);
      L0STATSCFGOTHERRECEIVED : out std_ulogic;
      L0STATSCFGOTHERTRANSMITTED : out std_ulogic;
      L0STATSCFGRECEIVED   : out std_ulogic;
      L0STATSCFGTRANSMITTED : out std_ulogic;
      L0STATSDLLPRECEIVED  : out std_ulogic;
      L0STATSDLLPTRANSMITTED : out std_ulogic;
      L0STATSOSRECEIVED    : out std_ulogic;
      L0STATSOSTRANSMITTED : out std_ulogic;
      L0STATSTLPRECEIVED   : out std_ulogic;
      L0STATSTLPTRANSMITTED : out std_ulogic;
      L0TOGGLEELECTROMECHANICALINTERLOCK : out std_ulogic;
      L0TRANSFORMEDVC      : out std_logic_vector(2 downto 0);
      L0TXDLLFCCMPLMCUPDATED : out std_logic_vector(7 downto 0);
      L0TXDLLFCNPOSTBYPUPDATED : out std_logic_vector(7 downto 0);
      L0TXDLLFCPOSTORDUPDATED : out std_logic_vector(7 downto 0);
      L0TXDLLPMUPDATED     : out std_ulogic;
      L0TXDLLSBFCUPDATED   : out std_ulogic;
      L0UCBYPFOUND         : out std_logic_vector(3 downto 0);
      L0UCORDFOUND         : out std_logic_vector(3 downto 0);
      L0UNLOCKRECEIVED     : out std_ulogic;
      LLKRX4DWHEADERN      : out std_ulogic;
      LLKRXCHCOMPLETIONAVAILABLEN : out std_logic_vector(7 downto 0);
      LLKRXCHCOMPLETIONPARTIALN : out std_logic_vector(7 downto 0);
      LLKRXCHCONFIGAVAILABLEN : out std_ulogic;
      LLKRXCHCONFIGPARTIALN : out std_ulogic;
      LLKRXCHNONPOSTEDAVAILABLEN : out std_logic_vector(7 downto 0);
      LLKRXCHNONPOSTEDPARTIALN : out std_logic_vector(7 downto 0);
      LLKRXCHPOSTEDAVAILABLEN : out std_logic_vector(7 downto 0);
      LLKRXCHPOSTEDPARTIALN : out std_logic_vector(7 downto 0);
      LLKRXDATA            : out std_logic_vector(63 downto 0);
      LLKRXECRCBADN        : out std_ulogic;
      LLKRXEOFN            : out std_ulogic;
      LLKRXEOPN            : out std_ulogic;
      LLKRXPREFERREDTYPE   : out std_logic_vector(15 downto 0);
      LLKRXSOFN            : out std_ulogic;
      LLKRXSOPN            : out std_ulogic;
      LLKRXSRCDSCN         : out std_ulogic;
      LLKRXSRCLASTREQN     : out std_ulogic;
      LLKRXSRCRDYN         : out std_ulogic;
      LLKRXVALIDN          : out std_logic_vector(1 downto 0);
      LLKTCSTATUS          : out std_logic_vector(7 downto 0);
      LLKTXCHANSPACE       : out std_logic_vector(9 downto 0);
      LLKTXCHCOMPLETIONREADYN : out std_logic_vector(7 downto 0);
      LLKTXCHNONPOSTEDREADYN : out std_logic_vector(7 downto 0);
      LLKTXCHPOSTEDREADYN  : out std_logic_vector(7 downto 0);
      LLKTXCONFIGREADYN    : out std_ulogic;
      LLKTXDSTRDYN         : out std_ulogic;
      MAXPAYLOADSIZE       : out std_logic_vector(2 downto 0);
      MAXREADREQUESTSIZE   : out std_logic_vector(2 downto 0);
      MEMSPACEENABLE       : out std_ulogic;
      MGMTPSO              : out std_logic_vector(16 downto 0);
      MGMTRDATA            : out std_logic_vector(31 downto 0);
      MGMTSTATSCREDIT      : out std_logic_vector(11 downto 0);
      MIMDLLBRADD          : out std_logic_vector(11 downto 0);
      MIMDLLBREN           : out std_ulogic;
      MIMDLLBWADD          : out std_logic_vector(11 downto 0);
      MIMDLLBWDATA         : out std_logic_vector(63 downto 0);
      MIMDLLBWEN           : out std_ulogic;
      MIMRXBRADD           : out std_logic_vector(12 downto 0);
      MIMRXBREN            : out std_ulogic;
      MIMRXBWADD           : out std_logic_vector(12 downto 0);
      MIMRXBWDATA          : out std_logic_vector(63 downto 0);
      MIMRXBWEN            : out std_ulogic;
      MIMTXBRADD           : out std_logic_vector(12 downto 0);
      MIMTXBREN            : out std_ulogic;
      MIMTXBWADD           : out std_logic_vector(12 downto 0);
      MIMTXBWDATA          : out std_logic_vector(63 downto 0);
      MIMTXBWEN            : out std_ulogic;
      PARITYERRORRESPONSE  : out std_ulogic;
      PIPEDESKEWLANESL0    : out std_ulogic;
      PIPEDESKEWLANESL1    : out std_ulogic;
      PIPEDESKEWLANESL2    : out std_ulogic;
      PIPEDESKEWLANESL3    : out std_ulogic;
      PIPEDESKEWLANESL4    : out std_ulogic;
      PIPEDESKEWLANESL5    : out std_ulogic;
      PIPEDESKEWLANESL6    : out std_ulogic;
      PIPEDESKEWLANESL7    : out std_ulogic;
      PIPEPOWERDOWNL0      : out std_logic_vector(1 downto 0);
      PIPEPOWERDOWNL1      : out std_logic_vector(1 downto 0);
      PIPEPOWERDOWNL2      : out std_logic_vector(1 downto 0);
      PIPEPOWERDOWNL3      : out std_logic_vector(1 downto 0);
      PIPEPOWERDOWNL4      : out std_logic_vector(1 downto 0);
      PIPEPOWERDOWNL5      : out std_logic_vector(1 downto 0);
      PIPEPOWERDOWNL6      : out std_logic_vector(1 downto 0);
      PIPEPOWERDOWNL7      : out std_logic_vector(1 downto 0);
      PIPERESETL0          : out std_ulogic;
      PIPERESETL1          : out std_ulogic;
      PIPERESETL2          : out std_ulogic;
      PIPERESETL3          : out std_ulogic;
      PIPERESETL4          : out std_ulogic;
      PIPERESETL5          : out std_ulogic;
      PIPERESETL6          : out std_ulogic;
      PIPERESETL7          : out std_ulogic;
      PIPERXPOLARITYL0     : out std_ulogic;
      PIPERXPOLARITYL1     : out std_ulogic;
      PIPERXPOLARITYL2     : out std_ulogic;
      PIPERXPOLARITYL3     : out std_ulogic;
      PIPERXPOLARITYL4     : out std_ulogic;
      PIPERXPOLARITYL5     : out std_ulogic;
      PIPERXPOLARITYL6     : out std_ulogic;
      PIPERXPOLARITYL7     : out std_ulogic;
      PIPETXCOMPLIANCEL0   : out std_ulogic;
      PIPETXCOMPLIANCEL1   : out std_ulogic;
      PIPETXCOMPLIANCEL2   : out std_ulogic;
      PIPETXCOMPLIANCEL3   : out std_ulogic;
      PIPETXCOMPLIANCEL4   : out std_ulogic;
      PIPETXCOMPLIANCEL5   : out std_ulogic;
      PIPETXCOMPLIANCEL6   : out std_ulogic;
      PIPETXCOMPLIANCEL7   : out std_ulogic;
      PIPETXDATAKL0        : out std_ulogic;
      PIPETXDATAKL1        : out std_ulogic;
      PIPETXDATAKL2        : out std_ulogic;
      PIPETXDATAKL3        : out std_ulogic;
      PIPETXDATAKL4        : out std_ulogic;
      PIPETXDATAKL5        : out std_ulogic;
      PIPETXDATAKL6        : out std_ulogic;
      PIPETXDATAKL7        : out std_ulogic;
      PIPETXDATAL0         : out std_logic_vector(7 downto 0);
      PIPETXDATAL1         : out std_logic_vector(7 downto 0);
      PIPETXDATAL2         : out std_logic_vector(7 downto 0);
      PIPETXDATAL3         : out std_logic_vector(7 downto 0);
      PIPETXDATAL4         : out std_logic_vector(7 downto 0);
      PIPETXDATAL5         : out std_logic_vector(7 downto 0);
      PIPETXDATAL6         : out std_logic_vector(7 downto 0);
      PIPETXDATAL7         : out std_logic_vector(7 downto 0);
      PIPETXDETECTRXLOOPBACKL0 : out std_ulogic;
      PIPETXDETECTRXLOOPBACKL1 : out std_ulogic;
      PIPETXDETECTRXLOOPBACKL2 : out std_ulogic;
      PIPETXDETECTRXLOOPBACKL3 : out std_ulogic;
      PIPETXDETECTRXLOOPBACKL4 : out std_ulogic;
      PIPETXDETECTRXLOOPBACKL5 : out std_ulogic;
      PIPETXDETECTRXLOOPBACKL6 : out std_ulogic;
      PIPETXDETECTRXLOOPBACKL7 : out std_ulogic;
      PIPETXELECIDLEL0     : out std_ulogic;
      PIPETXELECIDLEL1     : out std_ulogic;
      PIPETXELECIDLEL2     : out std_ulogic;
      PIPETXELECIDLEL3     : out std_ulogic;
      PIPETXELECIDLEL4     : out std_ulogic;
      PIPETXELECIDLEL5     : out std_ulogic;
      PIPETXELECIDLEL6     : out std_ulogic;
      PIPETXELECIDLEL7     : out std_ulogic;
      SERRENABLE           : out std_ulogic;
      URREPORTINGENABLE    : out std_ulogic;

      AUXPOWER             : in std_ulogic;
      CFGNEGOTIATEDLINKWIDTH : in std_logic_vector(5 downto 0);
      COMPLIANCEAVOID      : in std_ulogic;
      CRMCFGBRIDGEHOTRESET : in std_ulogic;
      CRMCORECLK           : in std_ulogic;
      CRMCORECLKDLO        : in std_ulogic;
      CRMCORECLKRXO        : in std_ulogic;
      CRMCORECLKTXO        : in std_ulogic;
      CRMLINKRSTN          : in std_ulogic;
      CRMMACRSTN           : in std_ulogic;
      CRMMGMTRSTN          : in std_ulogic;
      CRMNVRSTN            : in std_ulogic;
      CRMTXHOTRESETN       : in std_ulogic;
      CRMURSTN             : in std_ulogic;
      CRMUSERCFGRSTN       : in std_ulogic;
      CRMUSERCLK           : in std_ulogic;
      CRMUSERCLKRXO        : in std_ulogic;
      CRMUSERCLKTXO        : in std_ulogic;
      CROSSLINKSEED        : in std_ulogic;
      GSR                  : in std_ulogic;
      L0ACKNAKTIMERADJUSTMENT : in std_logic_vector(11 downto 0);
      L0ALLDOWNPORTSINL1   : in std_ulogic;
      L0ALLDOWNRXPORTSINL0S : in std_ulogic;
      L0ASE                : in std_ulogic;
      L0ASPORTCOUNT        : in std_logic_vector(7 downto 0);
      L0ASTURNPOOLBITSCONSUMED : in std_logic_vector(2 downto 0);
      L0ATTENTIONBUTTONPRESSED : in std_ulogic;
      L0CFGASSPANTREEOWNEDSTATE : in std_ulogic;
      L0CFGASSTATECHANGECMD : in std_logic_vector(3 downto 0);
      L0CFGDISABLESCRAMBLE : in std_ulogic;
      L0CFGEXTENDEDSYNC    : in std_ulogic;
      L0CFGL0SENTRYENABLE  : in std_ulogic;
      L0CFGL0SENTRYSUP     : in std_ulogic;
      L0CFGL0SEXITLAT      : in std_logic_vector(2 downto 0);
      L0CFGLINKDISABLE     : in std_ulogic;
      L0CFGLOOPBACKMASTER  : in std_ulogic;
      L0CFGNEGOTIATEDMAXP  : in std_logic_vector(2 downto 0);
      L0CFGVCENABLE        : in std_logic_vector(7 downto 0);
      L0CFGVCID            : in std_logic_vector(23 downto 0);
      L0DLLHOLDLINKUP      : in std_ulogic;
      L0ELECTROMECHANICALINTERLOCKENGAGED : in std_ulogic;
      L0FWDASSERTINTALEGACYINT : in std_ulogic;
      L0FWDASSERTINTBLEGACYINT : in std_ulogic;
      L0FWDASSERTINTCLEGACYINT : in std_ulogic;
      L0FWDASSERTINTDLEGACYINT : in std_ulogic;
      L0FWDCORRERRIN       : in std_ulogic;
      L0FWDDEASSERTINTALEGACYINT : in std_ulogic;
      L0FWDDEASSERTINTBLEGACYINT : in std_ulogic;
      L0FWDDEASSERTINTCLEGACYINT : in std_ulogic;
      L0FWDDEASSERTINTDLEGACYINT : in std_ulogic;
      L0FWDFATALERRIN      : in std_ulogic;
      L0FWDNONFATALERRIN   : in std_ulogic;
      L0LEGACYINTFUNCT0    : in std_ulogic;
      L0MRLSENSORCLOSEDN   : in std_ulogic;
      L0MSIREQUEST0        : in std_logic_vector(3 downto 0);
      L0PACKETHEADERFROMUSER : in std_logic_vector(127 downto 0);
      L0PMEREQIN           : in std_ulogic;
      L0PORTNUMBER         : in std_logic_vector(7 downto 0);
      L0POWERFAULTDETECTED : in std_ulogic;
      L0PRESENCEDETECTSLOTEMPTYN : in std_ulogic;
      L0PWRNEWSTATEREQ     : in std_ulogic;
      L0PWRNEXTLINKSTATE   : in std_logic_vector(1 downto 0);
      L0REPLAYTIMERADJUSTMENT : in std_logic_vector(11 downto 0);
      L0ROOTTURNOFFREQ     : in std_ulogic;
      L0RXTLTLPNONINITIALIZEDVC : in std_logic_vector(7 downto 0);
      L0SENDUNLOCKMESSAGE  : in std_ulogic;
      L0SETCOMPLETERABORTERROR : in std_ulogic;
      L0SETCOMPLETIONTIMEOUTCORRERROR : in std_ulogic;
      L0SETCOMPLETIONTIMEOUTUNCORRERROR : in std_ulogic;
      L0SETDETECTEDCORRERROR : in std_ulogic;
      L0SETDETECTEDFATALERROR : in std_ulogic;
      L0SETDETECTEDNONFATALERROR : in std_ulogic;
      L0SETLINKDETECTEDPARITYERROR : in std_ulogic;
      L0SETLINKMASTERDATAPARITY : in std_ulogic;
      L0SETLINKRECEIVEDMASTERABORT : in std_ulogic;
      L0SETLINKRECEIVEDTARGETABORT : in std_ulogic;
      L0SETLINKSIGNALLEDTARGETABORT : in std_ulogic;
      L0SETLINKSYSTEMERROR : in std_ulogic;
      L0SETUNEXPECTEDCOMPLETIONCORRERROR : in std_ulogic;
      L0SETUNEXPECTEDCOMPLETIONUNCORRERROR : in std_ulogic;
      L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR : in std_ulogic;
      L0SETUNSUPPORTEDREQUESTOTHERERROR : in std_ulogic;
      L0SETUSERDETECTEDPARITYERROR : in std_ulogic;
      L0SETUSERMASTERDATAPARITY : in std_ulogic;
      L0SETUSERRECEIVEDMASTERABORT : in std_ulogic;
      L0SETUSERRECEIVEDTARGETABORT : in std_ulogic;
      L0SETUSERSIGNALLEDTARGETABORT : in std_ulogic;
      L0SETUSERSYSTEMERROR : in std_ulogic;
      L0TLASFCCREDSTARVATION : in std_ulogic;
      L0TLLINKRETRAIN      : in std_ulogic;
      L0TRANSACTIONSPENDING : in std_ulogic;
      L0TXBEACON           : in std_ulogic;
      L0TXCFGPM            : in std_ulogic;
      L0TXCFGPMTYPE        : in std_logic_vector(2 downto 0);
      L0TXTLFCCMPLMCCRED   : in std_logic_vector(159 downto 0);
      L0TXTLFCCMPLMCUPDATE : in std_logic_vector(15 downto 0);
      L0TXTLFCNPOSTBYPCRED : in std_logic_vector(191 downto 0);
      L0TXTLFCNPOSTBYPUPDATE : in std_logic_vector(15 downto 0);
      L0TXTLFCPOSTORDCRED  : in std_logic_vector(159 downto 0);
      L0TXTLFCPOSTORDUPDATE : in std_logic_vector(15 downto 0);
      L0TXTLSBFCDATA       : in std_logic_vector(18 downto 0);
      L0TXTLSBFCUPDATE     : in std_ulogic;
      L0TXTLTLPDATA        : in std_logic_vector(63 downto 0);
      L0TXTLTLPEDB         : in std_ulogic;
      L0TXTLTLPENABLE      : in std_logic_vector(1 downto 0);
      L0TXTLTLPEND         : in std_logic_vector(1 downto 0);
      L0TXTLTLPLATENCY     : in std_logic_vector(3 downto 0);
      L0TXTLTLPREQ         : in std_ulogic;
      L0TXTLTLPREQEND      : in std_ulogic;
      L0TXTLTLPWIDTH       : in std_ulogic;
      L0UPSTREAMRXPORTINL0S : in std_ulogic;
      L0VC0PREVIEWEXPAND   : in std_ulogic;
      L0WAKEN              : in std_ulogic;
      LLKRXCHFIFO          : in std_logic_vector(1 downto 0);
      LLKRXCHTC            : in std_logic_vector(2 downto 0);
      LLKRXDSTCONTREQN     : in std_ulogic;
      LLKRXDSTREQN         : in std_ulogic;
      LLKTX4DWHEADERN      : in std_ulogic;
      LLKTXCHFIFO          : in std_logic_vector(1 downto 0);
      LLKTXCHTC            : in std_logic_vector(2 downto 0);
      LLKTXCOMPLETEN       : in std_ulogic;
      LLKTXCREATEECRCN     : in std_ulogic;
      LLKTXDATA            : in std_logic_vector(63 downto 0);
      LLKTXENABLEN         : in std_logic_vector(1 downto 0);
      LLKTXEOFN            : in std_ulogic;
      LLKTXEOPN            : in std_ulogic;
      LLKTXSOFN            : in std_ulogic;
      LLKTXSOPN            : in std_ulogic;
      LLKTXSRCDSCN         : in std_ulogic;
      LLKTXSRCRDYN         : in std_ulogic;
      MAINPOWER            : in std_ulogic;
      MGMTADDR             : in std_logic_vector(10 downto 0);
      MGMTBWREN            : in std_logic_vector(3 downto 0);
      MGMTRDEN             : in std_ulogic;
      MGMTSTATSCREDITSEL   : in std_logic_vector(6 downto 0);
      MGMTWDATA            : in std_logic_vector(31 downto 0);
      MGMTWREN             : in std_ulogic;
      MIMDLLBRDATA         : in std_logic_vector(63 downto 0);
      MIMRXBRDATA          : in std_logic_vector(63 downto 0);
      MIMTXBRDATA          : in std_logic_vector(63 downto 0);
      PIPEPHYSTATUSL0      : in std_ulogic;
      PIPEPHYSTATUSL1      : in std_ulogic;
      PIPEPHYSTATUSL2      : in std_ulogic;
      PIPEPHYSTATUSL3      : in std_ulogic;
      PIPEPHYSTATUSL4      : in std_ulogic;
      PIPEPHYSTATUSL5      : in std_ulogic;
      PIPEPHYSTATUSL6      : in std_ulogic;
      PIPEPHYSTATUSL7      : in std_ulogic;
      PIPERXCHANISALIGNEDL0 : in std_ulogic;
      PIPERXCHANISALIGNEDL1 : in std_ulogic;
      PIPERXCHANISALIGNEDL2 : in std_ulogic;
      PIPERXCHANISALIGNEDL3 : in std_ulogic;
      PIPERXCHANISALIGNEDL4 : in std_ulogic;
      PIPERXCHANISALIGNEDL5 : in std_ulogic;
      PIPERXCHANISALIGNEDL6 : in std_ulogic;
      PIPERXCHANISALIGNEDL7 : in std_ulogic;
      PIPERXDATAKL0        : in std_ulogic;
      PIPERXDATAKL1        : in std_ulogic;
      PIPERXDATAKL2        : in std_ulogic;
      PIPERXDATAKL3        : in std_ulogic;
      PIPERXDATAKL4        : in std_ulogic;
      PIPERXDATAKL5        : in std_ulogic;
      PIPERXDATAKL6        : in std_ulogic;
      PIPERXDATAKL7        : in std_ulogic;
      PIPERXDATAL0         : in std_logic_vector(7 downto 0);
      PIPERXDATAL1         : in std_logic_vector(7 downto 0);
      PIPERXDATAL2         : in std_logic_vector(7 downto 0);
      PIPERXDATAL3         : in std_logic_vector(7 downto 0);
      PIPERXDATAL4         : in std_logic_vector(7 downto 0);
      PIPERXDATAL5         : in std_logic_vector(7 downto 0);
      PIPERXDATAL6         : in std_logic_vector(7 downto 0);
      PIPERXDATAL7         : in std_logic_vector(7 downto 0);
      PIPERXELECIDLEL0     : in std_ulogic;
      PIPERXELECIDLEL1     : in std_ulogic;
      PIPERXELECIDLEL2     : in std_ulogic;
      PIPERXELECIDLEL3     : in std_ulogic;
      PIPERXELECIDLEL4     : in std_ulogic;
      PIPERXELECIDLEL5     : in std_ulogic;
      PIPERXELECIDLEL6     : in std_ulogic;
      PIPERXELECIDLEL7     : in std_ulogic;
      PIPERXSTATUSL0       : in std_logic_vector(2 downto 0);
      PIPERXSTATUSL1       : in std_logic_vector(2 downto 0);
      PIPERXSTATUSL2       : in std_logic_vector(2 downto 0);
      PIPERXSTATUSL3       : in std_logic_vector(2 downto 0);
      PIPERXSTATUSL4       : in std_logic_vector(2 downto 0);
      PIPERXSTATUSL5       : in std_logic_vector(2 downto 0);
      PIPERXSTATUSL6       : in std_logic_vector(2 downto 0);
      PIPERXSTATUSL7       : in std_logic_vector(2 downto 0);
      PIPERXVALIDL0        : in std_ulogic;
      PIPERXVALIDL1        : in std_ulogic;
      PIPERXVALIDL2        : in std_ulogic;
      PIPERXVALIDL3        : in std_ulogic;
      PIPERXVALIDL4        : in std_ulogic;
      PIPERXVALIDL5        : in std_ulogic;
      PIPERXVALIDL6        : in std_ulogic;
      PIPERXVALIDL7        : in std_ulogic;

      MCACTIVELANESIN             : in std_logic_vector(7 downto 0);
      MCAERBASEPTR                : in std_logic_vector(11 downto 0);
      MCAERCAPABILITYECRCCHECKCAPABLE : in std_ulogic;
      MCAERCAPABILITYECRCGENCAPABLE : in std_ulogic;
      MCAERCAPABILITYNEXTPTR      : in std_logic_vector(11 downto 0);
      MCBAR0ADDRWIDTH             : in std_ulogic;
      MCBAR0EXIST                 : in std_ulogic;
      MCBAR0IOMEMN                : in std_ulogic;
      MCBAR0MASKWIDTH             : in std_logic_vector(5 downto 0);
      MCBAR0PREFETCHABLE          : in std_ulogic;
      MCBAR1ADDRWIDTH             : in std_ulogic;
      MCBAR1EXIST                 : in std_ulogic;
      MCBAR1IOMEMN                : in std_ulogic;
      MCBAR1MASKWIDTH             : in std_logic_vector(5 downto 0);
      MCBAR1PREFETCHABLE          : in std_ulogic;
      MCBAR2ADDRWIDTH             : in std_ulogic;
      MCBAR2EXIST                 : in std_ulogic;
      MCBAR2IOMEMN                : in std_ulogic;
      MCBAR2MASKWIDTH             : in std_logic_vector(5 downto 0);
      MCBAR2PREFETCHABLE          : in std_ulogic;
      MCBAR3ADDRWIDTH             : in std_ulogic;
      MCBAR3EXIST                 : in std_ulogic;
      MCBAR3IOMEMN                : in std_ulogic;
      MCBAR3MASKWIDTH             : in std_logic_vector(5 downto 0);
      MCBAR3PREFETCHABLE          : in std_ulogic;
      MCBAR4ADDRWIDTH             : in std_ulogic;
      MCBAR4EXIST                 : in std_ulogic;
      MCBAR4IOMEMN                : in std_ulogic;
      MCBAR4MASKWIDTH             : in std_logic_vector(5 downto 0);
      MCBAR4PREFETCHABLE          : in std_ulogic;
      MCBAR5ADDRWIDTH             : in std_ulogic;
      MCBAR5EXIST                 : in std_ulogic;
      MCBAR5IOMEMN                : in std_ulogic;
      MCBAR5MASKWIDTH             : in std_logic_vector(5 downto 0);
      MCBAR5PREFETCHABLE          : in std_ulogic;
      MCCAPABILITIESPOINTER       : in std_logic_vector(7 downto 0);
      MCCARDBUSCISPOINTER         : in std_logic_vector(31 downto 0);
      MCCLASSCODE                 : in std_logic_vector(23 downto 0);
--      MCCLKDIVIDED                : in std_ulogic;
      MCCONFIGROUTING             : in std_logic_vector(2 downto 0);
      MCDEVICECAPABILITYENDPOINTL0SLATENCY : in std_logic_vector(2 downto 0);
      MCDEVICECAPABILITYENDPOINTL1LATENCY : in std_logic_vector(2 downto 0);
      MCDEVICEID                  : in std_logic_vector(15 downto 0);
      MCDEVICESERIALNUMBER        : in std_logic_vector(63 downto 0);
      MCDSNBASEPTR                : in std_logic_vector(11 downto 0);
      MCDSNCAPABILITYNEXTPTR      : in std_logic_vector(11 downto 0);
      MCDUALCOREENABLE            : in std_ulogic;
      MCDUALCORESLAVE             : in std_ulogic;
      MCDUALROLECFGCNTRLROOTEPN   : in std_ulogic;
      MCEXTCFGCAPPTR              : in std_logic_vector(7 downto 0);
      MCEXTCFGXPCAPPTR            : in std_logic_vector(11 downto 0);
      MCHEADERTYPE                : in std_logic_vector(7 downto 0);
      MCINFINITECOMPLETIONS       : in std_ulogic;
      MCINTERRUPTPIN              : in std_logic_vector(7 downto 0);
      MCISSWITCH                  : in std_ulogic;
      MCL0SEXITLATENCY            : in std_logic_vector(2 downto 0);
      MCL0SEXITLATENCYCOMCLK      : in std_logic_vector(2 downto 0);
      MCL1EXITLATENCY             : in std_logic_vector(2 downto 0);
      MCL1EXITLATENCYCOMCLK       : in std_logic_vector(2 downto 0);
      MCLINKCAPABILITYASPMSUPPORT : in std_logic_vector(1 downto 0);
      MCLINKCAPABILITYMAXLINKWIDTH : in std_logic_vector(5 downto 0);
      MCLINKSTATUSSLOTCLOCKCONFIG : in std_ulogic;
      MCLLKBYPASS                 : in std_ulogic;
      MCLOWPRIORITYVCCOUNT        : in std_logic_vector(2 downto 0);
      MCMSIBASEPTR                : in std_logic_vector(11 downto 0);
      MCMSICAPABILITYMULTIMSGCAP  : in std_logic_vector(2 downto 0);
      MCMSICAPABILITYNEXTPTR      : in std_logic_vector(7 downto 0);
      MCPBBASEPTR                 : in std_logic_vector(11 downto 0);
      MCPBCAPABILITYDW0BASEPOWER  : in std_logic_vector(7 downto 0);
      MCPBCAPABILITYDW0DATASCALE  : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW0PMSTATE    : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW0PMSUBSTATE : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW0POWERRAIL  : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW0TYPE       : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW1BASEPOWER  : in std_logic_vector(7 downto 0);
      MCPBCAPABILITYDW1DATASCALE  : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW1PMSTATE    : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW1PMSUBSTATE : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW1POWERRAIL  : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW1TYPE       : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW2BASEPOWER  : in std_logic_vector(7 downto 0);
      MCPBCAPABILITYDW2DATASCALE  : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW2PMSTATE    : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW2PMSUBSTATE : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW2POWERRAIL  : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW2TYPE       : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW3BASEPOWER  : in std_logic_vector(7 downto 0);
      MCPBCAPABILITYDW3DATASCALE  : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW3PMSTATE    : in std_logic_vector(1 downto 0);
      MCPBCAPABILITYDW3PMSUBSTATE : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW3POWERRAIL  : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYDW3TYPE       : in std_logic_vector(2 downto 0);
      MCPBCAPABILITYNEXTPTR       : in std_logic_vector(11 downto 0);
      MCPBCAPABILITYSYSTEMALLOCATED : in std_ulogic;
      MCPCIECAPABILITYINTMSGNUM   : in std_logic_vector(4 downto 0);
      MCPCIECAPABILITYNEXTPTR     : in std_logic_vector(7 downto 0);
      MCPCIECAPABILITYSLOTIMPL    : in std_ulogic;
      MCPCIEREVISION              : in std_ulogic;
      MCPMBASEPTR                 : in std_logic_vector(11 downto 0);
      MCPMCAPABILITYAUXCURRENT    : in std_logic_vector(2 downto 0);
      MCPMCAPABILITYD1SUPPORT     : in std_ulogic;
      MCPMCAPABILITYD2SUPPORT     : in std_ulogic;
      MCPMCAPABILITYDSI           : in std_ulogic;
      MCPMCAPABILITYNEXTPTR       : in std_logic_vector(7 downto 0);
      MCPMCAPABILITYPMESUPPORT    : in std_logic_vector(4 downto 0);
      MCPMDATA0                   : in std_logic_vector(7 downto 0);
      MCPMDATA1                   : in std_logic_vector(7 downto 0);
      MCPMDATA2                   : in std_logic_vector(7 downto 0);
      MCPMDATA3                   : in std_logic_vector(7 downto 0);
      MCPMDATA4                   : in std_logic_vector(7 downto 0);
      MCPMDATA5                   : in std_logic_vector(7 downto 0);
      MCPMDATA6                   : in std_logic_vector(7 downto 0);
      MCPMDATA7                   : in std_logic_vector(7 downto 0);
      MCPMDATA8                   : in std_logic_vector(7 downto 0);
      MCPMDATASCALE0              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE1              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE2              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE3              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE4              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE5              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE6              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE7              : in std_logic_vector(1 downto 0);
      MCPMDATASCALE8              : in std_logic_vector(1 downto 0);
      MCPMSTATUSCONTROLDATASCALE  : in std_logic_vector(1 downto 0);
      MCPORTVCCAPABILITYEXTENDEDVCCOUNT : in std_logic_vector(2 downto 0);
      MCPORTVCCAPABILITYVCARBCAP  : in std_logic_vector(7 downto 0);
      MCPORTVCCAPABILITYVCARBTABLEOFFSET : in std_logic_vector(7 downto 0);
      MCRAMSHARETXRX              : in std_ulogic;
      MCRESETMODE                 : in std_ulogic;
      MCRETRYRAMREADLATENCY       : in std_logic_vector(2 downto 0);
      MCRETRYRAMSIZE              : in std_logic_vector(11 downto 0);
      MCRETRYRAMWIDTH             : in std_ulogic;
      MCRETRYRAMWRITELATENCY      : in std_logic_vector(2 downto 0);
      MCRETRYREADADDRPIPE         : in std_ulogic;
      MCRETRYREADDATAPIPE         : in std_ulogic;
      MCRETRYWRITEPIPE            : in std_ulogic;
      MCREVISIONID                : in std_logic_vector(7 downto 0);
      MCRXREADADDRPIPE            : in std_ulogic;
      MCRXREADDATAPIPE            : in std_ulogic;
      MCRXWRITEPIPE               : in std_ulogic;
      MCSELECTASMODE              : in std_ulogic;
      MCSELECTDLLIF               : in std_ulogic;
      MCSLOTCAPABILITYATTBUTTONPRESENT : in std_ulogic;
      MCSLOTCAPABILITYATTINDICATORPRESENT : in std_ulogic;
      MCSLOTCAPABILITYHOTPLUGCAPABLE : in std_ulogic;
      MCSLOTCAPABILITYHOTPLUGSURPRISE : in std_ulogic;
      MCSLOTCAPABILITYMSLSENSORPRESENT : in std_ulogic;
      MCSLOTCAPABILITYPHYSICALSLOTNUM : in std_logic_vector(12 downto 0);
      MCSLOTCAPABILITYPOWERCONTROLLERPRESENT : in std_ulogic;
      MCSLOTCAPABILITYPOWERINDICATORPRESENT : in std_ulogic;
      MCSLOTCAPABILITYSLOTPOWERLIMITSCALE : in std_logic_vector(1 downto 0);
      MCSLOTCAPABILITYSLOTPOWERLIMITVALUE : in std_logic_vector(7 downto 0);
      MCSLOTIMPLEMENTED           : in std_ulogic;
      MCSUBSYSTEMID               : in std_logic_vector(15 downto 0);
      MCSUBSYSTEMVENDORID         : in std_logic_vector(15 downto 0);
      MCTLRAMREADLATENCY          : in std_logic_vector(2 downto 0);
      MCTLRAMWIDTH                : in std_ulogic;
      MCTLRAMWRITELATENCY         : in std_logic_vector(2 downto 0);
      MCTXREADADDRPIPE            : in std_ulogic;
      MCTXREADDATAPIPE            : in std_ulogic;
      MCTXTSNFTS                  : in std_logic_vector(7 downto 0);
      MCTXTSNFTSCOMCLK            : in std_logic_vector(7 downto 0);
      MCTXWRITEPIPE               : in std_ulogic;
      MCUPSTREAMFACING            : in std_ulogic;
      MCVC0RXFIFOBASEC            : in std_logic_vector(12 downto 0);
      MCVC0RXFIFOBASENP           : in std_logic_vector(12 downto 0);
      MCVC0RXFIFOBASEP            : in std_logic_vector(12 downto 0);
      MCVC0RXFIFOLIMITC           : in std_logic_vector(12 downto 0);
      MCVC0RXFIFOLIMITNP          : in std_logic_vector(12 downto 0);
      MCVC0RXFIFOLIMITP           : in std_logic_vector(12 downto 0);
      MCVC0TOTALCREDITSCD         : in std_logic_vector(10 downto 0);
      MCVC0TOTALCREDITSCH         : in std_logic_vector(6 downto 0);
      MCVC0TOTALCREDITSNPH        : in std_logic_vector(6 downto 0);
      MCVC0TOTALCREDITSPD         : in std_logic_vector(10 downto 0);
      MCVC0TOTALCREDITSPH         : in std_logic_vector(6 downto 0);
      MCVC0TXFIFOBASEC            : in std_logic_vector(12 downto 0);
      MCVC0TXFIFOBASENP           : in std_logic_vector(12 downto 0);
      MCVC0TXFIFOBASEP            : in std_logic_vector(12 downto 0);
      MCVC0TXFIFOLIMITC           : in std_logic_vector(12 downto 0);
      MCVC0TXFIFOLIMITNP          : in std_logic_vector(12 downto 0);
      MCVC0TXFIFOLIMITP           : in std_logic_vector(12 downto 0);
      MCVC1RXFIFOBASEC            : in std_logic_vector(12 downto 0);
      MCVC1RXFIFOBASENP           : in std_logic_vector(12 downto 0);
      MCVC1RXFIFOBASEP            : in std_logic_vector(12 downto 0);
      MCVC1RXFIFOLIMITC           : in std_logic_vector(12 downto 0);
      MCVC1RXFIFOLIMITNP          : in std_logic_vector(12 downto 0);
      MCVC1RXFIFOLIMITP           : in std_logic_vector(12 downto 0);
      MCVC1TOTALCREDITSCD         : in std_logic_vector(10 downto 0);
      MCVC1TOTALCREDITSCH         : in std_logic_vector(6 downto 0);
      MCVC1TOTALCREDITSNPH        : in std_logic_vector(6 downto 0);
      MCVC1TOTALCREDITSPD         : in std_logic_vector(10 downto 0);
      MCVC1TOTALCREDITSPH         : in std_logic_vector(6 downto 0);
      MCVC1TXFIFOBASEC            : in std_logic_vector(12 downto 0);
      MCVC1TXFIFOBASENP           : in std_logic_vector(12 downto 0);
      MCVC1TXFIFOBASEP            : in std_logic_vector(12 downto 0);
      MCVC1TXFIFOLIMITC           : in std_logic_vector(12 downto 0);
      MCVC1TXFIFOLIMITNP          : in std_logic_vector(12 downto 0);
      MCVC1TXFIFOLIMITP           : in std_logic_vector(12 downto 0);
      MCVCBASEPTR                 : in std_logic_vector(11 downto 0);
      MCVCCAPABILITYNEXTPTR       : in std_logic_vector(11 downto 0);
      MCVENDORID                  : in std_logic_vector(15 downto 0);
      MCXLINKSUPPORTED            : in std_ulogic;
      MCXPBASEPTR                 : in std_logic_vector(7 downto 0);
      MCXPDEVICEPORTTYPE          : in std_logic_vector(3 downto 0);
      MCXPMAXPAYLOAD              : in std_logic_vector(2 downto 0);
      MCXPRCBCONTROL              : in std_ulogic
    );
  end component;

	constant IN_DELAY : time := 0 ps;
	constant OUT_DELAY : time := 0 ps;
	constant CLK_DELAY : time := 0 ps;

	constant PATH_DELAY : VitalDelayType01 := (100 ps, 100 ps);


	signal   VC0TXFIFOBASEP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0TXFIFOBASEP)(12 downto 0);
	signal   VC0TXFIFOBASENP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0TXFIFOBASENP)(12 downto 0);
	signal   VC0TXFIFOBASEC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0TXFIFOBASEC)(12 downto 0);
	signal   VC0TXFIFOLIMITP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0TXFIFOLIMITP)(12 downto 0);
	signal   VC0TXFIFOLIMITNP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0TXFIFOLIMITNP)(12 downto 0);
	signal   VC0TXFIFOLIMITC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0TXFIFOLIMITC)(12 downto 0);
	signal   VC0TOTALCREDITSPH_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(VC0TOTALCREDITSPH)(6 downto 0);
	signal   VC0TOTALCREDITSNPH_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(VC0TOTALCREDITSNPH)(6 downto 0);
	signal   VC0TOTALCREDITSCH_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(VC0TOTALCREDITSCH)(6 downto 0);
	signal   VC0TOTALCREDITSPD_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(VC0TOTALCREDITSPD)(10 downto 0);
	signal   VC0TOTALCREDITSCD_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(VC0TOTALCREDITSCD)(10 downto 0);
	signal   VC0RXFIFOBASEP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0RXFIFOBASEP)(12 downto 0);
	signal   VC0RXFIFOBASENP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0RXFIFOBASENP)(12 downto 0);
	signal   VC0RXFIFOBASEC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0RXFIFOBASEC)(12 downto 0);
	signal   VC0RXFIFOLIMITP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0RXFIFOLIMITP)(12 downto 0);
	signal   VC0RXFIFOLIMITNP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0RXFIFOLIMITNP)(12 downto 0);
	signal   VC0RXFIFOLIMITC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC0RXFIFOLIMITC)(12 downto 0);
	signal   VC1TXFIFOBASEP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1TXFIFOBASEP)(12 downto 0);
	signal   VC1TXFIFOBASENP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1TXFIFOBASENP)(12 downto 0);
	signal   VC1TXFIFOBASEC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1TXFIFOBASEC)(12 downto 0);
	signal   VC1TXFIFOLIMITP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1TXFIFOLIMITP)(12 downto 0);
	signal   VC1TXFIFOLIMITNP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1TXFIFOLIMITNP)(12 downto 0);
	signal   VC1TXFIFOLIMITC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1TXFIFOLIMITC)(12 downto 0);
	signal   VC1TOTALCREDITSPH_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(VC1TOTALCREDITSPH)(6 downto 0);
	signal   VC1TOTALCREDITSNPH_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(VC1TOTALCREDITSNPH)(6 downto 0);
	signal   VC1TOTALCREDITSCH_BINARY  :  std_logic_vector(6 downto 0) := To_StdLogicVector(VC1TOTALCREDITSCH)(6 downto 0);
	signal   VC1TOTALCREDITSPD_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(VC1TOTALCREDITSPD)(10 downto 0);
	signal   VC1TOTALCREDITSCD_BINARY  :  std_logic_vector(10 downto 0) := To_StdLogicVector(VC1TOTALCREDITSCD)(10 downto 0);
	signal   VC1RXFIFOBASEP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1RXFIFOBASEP)(12 downto 0);
	signal   VC1RXFIFOBASENP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1RXFIFOBASENP)(12 downto 0);
	signal   VC1RXFIFOBASEC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1RXFIFOBASEC)(12 downto 0);
	signal   VC1RXFIFOLIMITP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1RXFIFOLIMITP)(12 downto 0);
	signal   VC1RXFIFOLIMITNP_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1RXFIFOLIMITNP)(12 downto 0);
	signal   VC1RXFIFOLIMITC_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(VC1RXFIFOLIMITC)(12 downto 0);
	signal   ACTIVELANESIN_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(ACTIVELANESIN);
	signal   TXTSNFTS_BINARY  :  std_logic_vector(7 downto 0);
	signal   TXTSNFTSCOMCLK_BINARY  :  std_logic_vector(7 downto 0);
	signal   RETRYRAMREADLATENCY_BINARY  :  std_logic_vector(2 downto 0);
	signal   RETRYRAMWRITELATENCY_BINARY  :  std_logic_vector(2 downto 0);
	signal   RETRYRAMWIDTH_BINARY  :  std_ulogic;
	signal   RETRYRAMSIZE_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(RETRYRAMSIZE);
	signal   RETRYWRITEPIPE_BINARY  :  std_ulogic;
	signal   RETRYREADADDRPIPE_BINARY  :  std_ulogic;
	signal   RETRYREADDATAPIPE_BINARY  :  std_ulogic;
	signal   XLINKSUPPORTED_BINARY  :  std_ulogic;
	signal   INFINITECOMPLETIONS_BINARY  :  std_ulogic;
	signal   TLRAMREADLATENCY_BINARY  :  std_logic_vector(2 downto 0);
	signal   TLRAMWRITELATENCY_BINARY  :  std_logic_vector(2 downto 0);
	signal   TLRAMWIDTH_BINARY  :  std_ulogic;
	signal   RAMSHARETXRX_BINARY  :  std_ulogic;
	signal   L0SEXITLATENCY_BINARY  :  std_logic_vector(2 downto 0);
	signal   L0SEXITLATENCYCOMCLK_BINARY  :  std_logic_vector(2 downto 0);
	signal   L1EXITLATENCY_BINARY  :  std_logic_vector(2 downto 0);
	signal   L1EXITLATENCYCOMCLK_BINARY  :  std_logic_vector(2 downto 0);
	signal   DUALCORESLAVE_BINARY  :  std_ulogic;
	signal   DUALCOREENABLE_BINARY  :  std_ulogic;
	signal   DUALROLECFGCNTRLROOTEPN_BINARY  :  std_ulogic;
	signal   RXREADADDRPIPE_BINARY  :  std_ulogic;
	signal   RXREADDATAPIPE_BINARY  :  std_ulogic;
	signal   TXWRITEPIPE_BINARY  :  std_ulogic;
	signal   TXREADADDRPIPE_BINARY  :  std_ulogic;
	signal   TXREADDATAPIPE_BINARY  :  std_ulogic;
	signal   RXWRITEPIPE_BINARY  :  std_ulogic;
	signal   LLKBYPASS_BINARY  :  std_ulogic;
	signal   PCIEREVISION_BINARY  :  std_ulogic;
	signal   SELECTDLLIF_BINARY  :  std_ulogic;
	signal   SELECTASMODE_BINARY  :  std_ulogic;
	signal   ISSWITCH_BINARY  :  std_ulogic;
	signal   UPSTREAMFACING_BINARY  :  std_ulogic;
	signal   SLOTIMPLEMENTED_BINARY  :  std_ulogic;
	signal   EXTCFGCAPPTR_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(EXTCFGCAPPTR);
	signal   EXTCFGXPCAPPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(EXTCFGXPCAPPTR);
	signal   BAR0EXIST_BINARY  :  std_ulogic;
	signal   BAR1EXIST_BINARY  :  std_ulogic;
	signal   BAR2EXIST_BINARY  :  std_ulogic;
	signal   BAR3EXIST_BINARY  :  std_ulogic;
	signal   BAR4EXIST_BINARY  :  std_ulogic;
	signal   BAR5EXIST_BINARY  :  std_ulogic;
	signal   BAR0ADDRWIDTH_BINARY  :  std_ulogic;
	signal   BAR1ADDRWIDTH_BINARY  :  std_ulogic;
	signal   BAR2ADDRWIDTH_BINARY  :  std_ulogic;
	signal   BAR3ADDRWIDTH_BINARY  :  std_ulogic;
	signal   BAR4ADDRWIDTH_BINARY  :  std_ulogic;
	signal   BAR5ADDRWIDTH_BINARY  :  std_ulogic := '0';
	signal   BAR0PREFETCHABLE_BINARY  :  std_ulogic;
	signal   BAR1PREFETCHABLE_BINARY  :  std_ulogic;
	signal   BAR2PREFETCHABLE_BINARY  :  std_ulogic;
	signal   BAR3PREFETCHABLE_BINARY  :  std_ulogic;
	signal   BAR4PREFETCHABLE_BINARY  :  std_ulogic;
	signal   BAR5PREFETCHABLE_BINARY  :  std_ulogic;
	signal   BAR0IOMEMN_BINARY  :  std_ulogic;
	signal   BAR1IOMEMN_BINARY  :  std_ulogic;
	signal   BAR2IOMEMN_BINARY  :  std_ulogic;
	signal   BAR3IOMEMN_BINARY  :  std_ulogic;
	signal   BAR4IOMEMN_BINARY  :  std_ulogic;
	signal   BAR5IOMEMN_BINARY  :  std_ulogic;
	signal   BAR0MASKWIDTH_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(BAR0MASKWIDTH)(5 downto 0);
	signal   BAR1MASKWIDTH_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(BAR1MASKWIDTH)(5 downto 0);
	signal   BAR2MASKWIDTH_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(BAR2MASKWIDTH)(5 downto 0);
	signal   BAR3MASKWIDTH_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(BAR3MASKWIDTH)(5 downto 0);
	signal   BAR4MASKWIDTH_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(BAR4MASKWIDTH)(5 downto 0);
	signal   BAR5MASKWIDTH_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(BAR5MASKWIDTH)(5 downto 0);
	signal   CONFIGROUTING_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(CONFIGROUTING)(2 downto 0);
	signal   XPDEVICEPORTTYPE_BINARY  :  std_logic_vector(3 downto 0) := To_StdLogicVector(XPDEVICEPORTTYPE);
	signal   HEADERTYPE_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(HEADERTYPE);
	signal   XPMAXPAYLOAD_BINARY  :  std_logic_vector(2 downto 0);
	signal   XPRCBCONTROL_BINARY  :  std_ulogic;
	signal   LOWPRIORITYVCCOUNT_BINARY  :  std_logic_vector(2 downto 0);
	signal   VENDORID_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(VENDORID);
	signal   DEVICEID_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(DEVICEID);
	signal   REVISIONID_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(REVISIONID);
	signal   CLASSCODE_BINARY  :  std_logic_vector(23 downto 0) := To_StdLogicVector(CLASSCODE);
	signal   CARDBUSCISPOINTER_BINARY  :  std_logic_vector(31 downto 0) := To_StdLogicVector(CARDBUSCISPOINTER);
	signal   SUBSYSTEMVENDORID_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(SUBSYSTEMVENDORID);
	signal   SUBSYSTEMID_BINARY  :  std_logic_vector(15 downto 0) := To_StdLogicVector(SUBSYSTEMID);
	signal   CAPABILITIESPOINTER_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(CAPABILITIESPOINTER);
	signal   INTERRUPTPIN_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(INTERRUPTPIN);
	signal   PMCAPABILITYNEXTPTR_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMCAPABILITYNEXTPTR);
	signal   PMCAPABILITYDSI_BINARY  :  std_ulogic;
	signal   PMCAPABILITYAUXCURRENT_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PMCAPABILITYAUXCURRENT)(2 downto 0);
	signal   PMCAPABILITYD1SUPPORT_BINARY  :  std_ulogic;
	signal   PMCAPABILITYD2SUPPORT_BINARY  :  std_ulogic;
	signal   PMCAPABILITYPMESUPPORT_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(PMCAPABILITYPMESUPPORT)(4 downto 0);
	signal   PMSTATUSCONTROLDATASCALE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PMSTATUSCONTROLDATASCALE)(1 downto 0);
	signal   PMDATA0_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA0);
	signal   PMDATA1_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA1);
	signal   PMDATA2_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA2);
	signal   PMDATA3_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA3);
	signal   PMDATA4_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA4);
	signal   PMDATA5_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA5);
	signal   PMDATA6_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA6);
	signal   PMDATA7_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA7);
	signal   PMDATA8_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PMDATA8);
	signal   PMDATASCALE0_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE1_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE2_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE3_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE4_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE5_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE6_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE7_BINARY  :  std_logic_vector(1 downto 0);
	signal   PMDATASCALE8_BINARY  :  std_logic_vector(1 downto 0);
	signal   MSICAPABILITYNEXTPTR_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(MSICAPABILITYNEXTPTR);
	signal   MSICAPABILITYMULTIMSGCAP_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(MSICAPABILITYMULTIMSGCAP)(2 downto 0);
	signal   PCIECAPABILITYNEXTPTR_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PCIECAPABILITYNEXTPTR);
	signal   PCIECAPABILITYSLOTIMPL_BINARY  :  std_ulogic;
	signal   PCIECAPABILITYINTMSGNUM_BINARY  :  std_logic_vector(4 downto 0) := To_StdLogicVector(PCIECAPABILITYINTMSGNUM)(4 downto 0);
	signal   DEVICECAPABILITYENDPOINTL0SLATENCY_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(DEVICECAPABILITYENDPOINTL0SLATENCY)(2 downto 0);
	signal   DEVICECAPABILITYENDPOINTL1LATENCY_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(DEVICECAPABILITYENDPOINTL1LATENCY)(2 downto 0);
	signal   LINKCAPABILITYMAXLINKWIDTH_BINARY  :  std_logic_vector(5 downto 0) := To_StdLogicVector(LINKCAPABILITYMAXLINKWIDTH)(5 downto 0);
	signal   LINKCAPABILITYASPMSUPPORT_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(LINKCAPABILITYASPMSUPPORT)(1 downto 0);
	signal   LINKSTATUSSLOTCLOCKCONFIG_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYATTBUTTONPRESENT_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYPOWERCONTROLLERPRESENT_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYMSLSENSORPRESENT_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYATTINDICATORPRESENT_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYPOWERINDICATORPRESENT_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYHOTPLUGSURPRISE_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYHOTPLUGCAPABLE_BINARY  :  std_ulogic;
	signal   SLOTCAPABILITYSLOTPOWERLIMITVALUE_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(SLOTCAPABILITYSLOTPOWERLIMITVALUE);
	signal   SLOTCAPABILITYSLOTPOWERLIMITSCALE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(SLOTCAPABILITYSLOTPOWERLIMITSCALE)(1 downto 0);
	signal   SLOTCAPABILITYPHYSICALSLOTNUM_BINARY  :  std_logic_vector(12 downto 0) := To_StdLogicVector(SLOTCAPABILITYPHYSICALSLOTNUM)(12 downto 0);
	signal   AERCAPABILITYNEXTPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(AERCAPABILITYNEXTPTR);
	signal   AERCAPABILITYECRCGENCAPABLE_BINARY  :  std_ulogic;
	signal   AERCAPABILITYECRCCHECKCAPABLE_BINARY  :  std_ulogic;
	signal   VCCAPABILITYNEXTPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(VCCAPABILITYNEXTPTR);
	signal   PORTVCCAPABILITYEXTENDEDVCCOUNT_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PORTVCCAPABILITYEXTENDEDVCCOUNT)(2 downto 0);
	signal   PORTVCCAPABILITYVCARBCAP_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PORTVCCAPABILITYVCARBCAP);
	signal   PORTVCCAPABILITYVCARBTABLEOFFSET_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PORTVCCAPABILITYVCARBTABLEOFFSET);
	signal   DSNCAPABILITYNEXTPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(DSNCAPABILITYNEXTPTR);
	signal   DEVICESERIALNUMBER_BINARY  :  std_logic_vector(63 downto 0) := To_StdLogicVector(DEVICESERIALNUMBER);
	signal   PBCAPABILITYNEXTPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(PBCAPABILITYNEXTPTR);
	signal   PBCAPABILITYDW0BASEPOWER_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PBCAPABILITYDW0BASEPOWER);
	signal   PBCAPABILITYDW0DATASCALE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW0DATASCALE)(1 downto 0);
	signal   PBCAPABILITYDW0PMSUBSTATE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW0PMSUBSTATE)(2 downto 0);
	signal   PBCAPABILITYDW0PMSTATE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW0PMSTATE)(1 downto 0);
	signal   PBCAPABILITYDW0TYPE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW0TYPE)(2 downto 0);
	signal   PBCAPABILITYDW0POWERRAIL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW0POWERRAIL)(2 downto 0);
	signal   PBCAPABILITYDW1BASEPOWER_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PBCAPABILITYDW1BASEPOWER);
	signal   PBCAPABILITYDW1DATASCALE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW1DATASCALE)(1 downto 0);
	signal   PBCAPABILITYDW1PMSUBSTATE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW1PMSUBSTATE)(2 downto 0);
	signal   PBCAPABILITYDW1PMSTATE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW1PMSTATE)(1 downto 0);
	signal   PBCAPABILITYDW1TYPE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW1TYPE)(2 downto 0);
	signal   PBCAPABILITYDW1POWERRAIL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW1POWERRAIL)(2 downto 0);
	signal   PBCAPABILITYDW2BASEPOWER_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PBCAPABILITYDW2BASEPOWER);
	signal   PBCAPABILITYDW2DATASCALE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW2DATASCALE)(1 downto 0);
	signal   PBCAPABILITYDW2PMSUBSTATE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW2PMSUBSTATE)(2 downto 0);
	signal   PBCAPABILITYDW2PMSTATE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW2PMSTATE)(1 downto 0);
	signal   PBCAPABILITYDW2TYPE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW2TYPE)(2 downto 0);
	signal   PBCAPABILITYDW2POWERRAIL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW2POWERRAIL)(2 downto 0);
	signal   PBCAPABILITYDW3BASEPOWER_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(PBCAPABILITYDW3BASEPOWER);
	signal   PBCAPABILITYDW3DATASCALE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW3DATASCALE)(1 downto 0);
	signal   PBCAPABILITYDW3PMSUBSTATE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW3PMSUBSTATE)(2 downto 0);
	signal   PBCAPABILITYDW3PMSTATE_BINARY  :  std_logic_vector(1 downto 0) := To_StdLogicVector(PBCAPABILITYDW3PMSTATE)(1 downto 0);
	signal   PBCAPABILITYDW3TYPE_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW3TYPE)(2 downto 0);
	signal   PBCAPABILITYDW3POWERRAIL_BINARY  :  std_logic_vector(2 downto 0) := To_StdLogicVector(PBCAPABILITYDW3POWERRAIL)(2 downto 0);
	signal   PBCAPABILITYSYSTEMALLOCATED_BINARY  :  std_ulogic;
	signal   RESETMODE_BINARY  :  std_ulogic;
	signal   AERBASEPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(AERBASEPTR);
	signal   DSNBASEPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(DSNBASEPTR);
	signal   MSIBASEPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(MSIBASEPTR);
	signal   PBBASEPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(PBBASEPTR);
	signal   PMBASEPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(PMBASEPTR);
	signal   VCBASEPTR_BINARY  :  std_logic_vector(11 downto 0) := To_StdLogicVector(VCBASEPTR);
	signal   XPBASEPTR_BINARY  :  std_logic_vector(7 downto 0) := To_StdLogicVector(XPBASEPTR);
	signal   CLKDIVIDED_BINARY  :  std_ulogic;


	signal   PIPETXDATAL0_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL0_out  :  std_ulogic;
	signal   PIPETXELECIDLEL0_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL0_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL0_out  :  std_ulogic;
	signal   PIPERXPOLARITYL0_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL0_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL0_out  :  std_ulogic;
	signal   PIPERESETL0_out  :  std_ulogic;
	signal   PIPETXDATAL1_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL1_out  :  std_ulogic;
	signal   PIPETXELECIDLEL1_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL1_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL1_out  :  std_ulogic;
	signal   PIPERXPOLARITYL1_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL1_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL1_out  :  std_ulogic;
	signal   PIPERESETL1_out  :  std_ulogic;
	signal   PIPETXDATAL2_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL2_out  :  std_ulogic;
	signal   PIPETXELECIDLEL2_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL2_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL2_out  :  std_ulogic;
	signal   PIPERXPOLARITYL2_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL2_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL2_out  :  std_ulogic;
	signal   PIPERESETL2_out  :  std_ulogic;
	signal   PIPETXDATAL3_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL3_out  :  std_ulogic;
	signal   PIPETXELECIDLEL3_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL3_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL3_out  :  std_ulogic;
	signal   PIPERXPOLARITYL3_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL3_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL3_out  :  std_ulogic;
	signal   PIPERESETL3_out  :  std_ulogic;
	signal   PIPETXDATAL4_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL4_out  :  std_ulogic;
	signal   PIPETXELECIDLEL4_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL4_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL4_out  :  std_ulogic;
	signal   PIPERXPOLARITYL4_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL4_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL4_out  :  std_ulogic;
	signal   PIPERESETL4_out  :  std_ulogic;
	signal   PIPETXDATAL5_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL5_out  :  std_ulogic;
	signal   PIPETXELECIDLEL5_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL5_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL5_out  :  std_ulogic;
	signal   PIPERXPOLARITYL5_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL5_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL5_out  :  std_ulogic;
	signal   PIPERESETL5_out  :  std_ulogic;
	signal   PIPETXDATAL6_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL6_out  :  std_ulogic;
	signal   PIPETXELECIDLEL6_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL6_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL6_out  :  std_ulogic;
	signal   PIPERXPOLARITYL6_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL6_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL6_out  :  std_ulogic;
	signal   PIPERESETL6_out  :  std_ulogic;
	signal   PIPETXDATAL7_out  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL7_out  :  std_ulogic;
	signal   PIPETXELECIDLEL7_out  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL7_out  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL7_out  :  std_ulogic;
	signal   PIPERXPOLARITYL7_out  :  std_ulogic;
	signal   PIPEPOWERDOWNL7_out  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL7_out  :  std_ulogic;
	signal   PIPERESETL7_out  :  std_ulogic;
	signal   MIMRXBWDATA_out  :  std_logic_vector(63 downto 0);
	signal   MIMRXBWADD_out  :  std_logic_vector(12 downto 0);
	signal   MIMRXBRADD_out  :  std_logic_vector(12 downto 0);
	signal   MIMRXBWEN_out  :  std_ulogic;
	signal   MIMRXBREN_out  :  std_ulogic;
	signal   MIMTXBWDATA_out  :  std_logic_vector(63 downto 0);
	signal   MIMTXBWADD_out  :  std_logic_vector(12 downto 0);
	signal   MIMTXBRADD_out  :  std_logic_vector(12 downto 0);
	signal   MIMTXBWEN_out  :  std_ulogic;
	signal   MIMTXBREN_out  :  std_ulogic;
	signal   MIMDLLBWDATA_out  :  std_logic_vector(63 downto 0);
	signal   MIMDLLBWADD_out  :  std_logic_vector(11 downto 0);
	signal   MIMDLLBRADD_out  :  std_logic_vector(11 downto 0);
	signal   MIMDLLBWEN_out  :  std_ulogic;
	signal   MIMDLLBREN_out  :  std_ulogic;
	signal   CRMRXHOTRESETN_out  :  std_ulogic;
	signal   CRMDOHOTRESETN_out  :  std_ulogic;
	signal   CRMPWRSOFTRESETN_out  :  std_ulogic;
	signal   LLKTCSTATUS_out  :  std_logic_vector(7 downto 0);
	signal   LLKTXDSTRDYN_out  :  std_ulogic;
	signal   LLKTXCHANSPACE_out  :  std_logic_vector(9 downto 0);
	signal   LLKTXCHPOSTEDREADYN_out  :  std_logic_vector(7 downto 0);
	signal   LLKTXCHNONPOSTEDREADYN_out  :  std_logic_vector(7 downto 0);
	signal   LLKTXCHCOMPLETIONREADYN_out  :  std_logic_vector(7 downto 0);
	signal   LLKTXCONFIGREADYN_out  :  std_ulogic;
	signal   LLKRXDATA_out  :  std_logic_vector(63 downto 0);
	signal   LLKRXSRCRDYN_out  :  std_ulogic;
	signal   LLKRXSRCLASTREQN_out  :  std_ulogic;
	signal   LLKRXSRCDSCN_out  :  std_ulogic;
	signal   LLKRXSOFN_out  :  std_ulogic;
	signal   LLKRXEOFN_out  :  std_ulogic;
	signal   LLKRXSOPN_out  :  std_ulogic;
	signal   LLKRXEOPN_out  :  std_ulogic;
	signal   LLKRXVALIDN_out  :  std_logic_vector(1 downto 0);
	signal   LLKRXPREFERREDTYPE_out  :  std_logic_vector(15 downto 0);
	signal   LLKRXCHPOSTEDAVAILABLEN_out  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHNONPOSTEDAVAILABLEN_out  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCOMPLETIONAVAILABLEN_out  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCONFIGAVAILABLEN_out  :  std_ulogic;
	signal   LLKRXCHPOSTEDPARTIALN_out  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHNONPOSTEDPARTIALN_out  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCOMPLETIONPARTIALN_out  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCONFIGPARTIALN_out  :  std_ulogic;
	signal   LLKRX4DWHEADERN_out  :  std_ulogic;
	signal   LLKRXECRCBADN_out  :  std_ulogic;
	signal   MGMTRDATA_out  :  std_logic_vector(31 downto 0);
	signal   MGMTPSO_out  :  std_logic_vector(16 downto 0);
	signal   MGMTSTATSCREDIT_out  :  std_logic_vector(11 downto 0);
	signal   L0RXDLLTLPECRCOK_out  :  std_ulogic;
	signal   DLLTXPMDLLPOUTSTANDING_out  :  std_ulogic;
	signal   L0FIRSTCFGWRITEOCCURRED_out  :  std_ulogic;
	signal   L0CFGLOOPBACKACK_out  :  std_ulogic;
	signal   L0MACUPSTREAMDOWNSTREAM_out  :  std_ulogic;
	signal   L0RXMACLINKERROR_out  :  std_logic_vector(1 downto 0);
	signal   L0MACLINKUP_out  :  std_ulogic;
	signal   L0MACNEGOTIATEDLINKWIDTH_out  :  std_logic_vector(3 downto 0);
	signal   L0MACLINKTRAINING_out  :  std_ulogic;
	signal   L0LTSSMSTATE_out  :  std_logic_vector(3 downto 0);
	signal   L0DLLVCSTATUS_out  :  std_logic_vector(7 downto 0);
	signal   L0DLUPDOWN_out  :  std_logic_vector(7 downto 0);
	signal   L0DLLERRORVECTOR_out  :  std_logic_vector(6 downto 0);
	signal   L0DLLASRXSTATE_out  :  std_logic_vector(1 downto 0);
	signal   L0DLLASTXSTATE_out  :  std_ulogic;
	signal   L0ASAUTONOMOUSINITCOMPLETED_out  :  std_ulogic;
	signal   L0COMPLETERID_out  :  std_logic_vector(12 downto 0);
	signal   L0UNLOCKRECEIVED_out  :  std_ulogic;
	signal   L0CORRERRMSGRCVD_out  :  std_ulogic;
	signal   L0FATALERRMSGRCVD_out  :  std_ulogic;
	signal   L0NONFATALERRMSGRCVD_out  :  std_ulogic;
	signal   L0ERRMSGREQID_out  :  std_logic_vector(15 downto 0);
	signal   L0FWDCORRERROUT_out  :  std_ulogic;
	signal   L0FWDFATALERROUT_out  :  std_ulogic;
	signal   L0FWDNONFATALERROUT_out  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTALEGACYINT_out  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTBLEGACYINT_out  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTCLEGACYINT_out  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTDLEGACYINT_out  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTALEGACYINT_out  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTBLEGACYINT_out  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTCLEGACYINT_out  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTDLEGACYINT_out  :  std_ulogic;
	signal   L0MSIENABLE0_out  :  std_ulogic;
	signal   L0MULTIMSGEN0_out  :  std_logic_vector(2 downto 0);
	signal   L0STATSDLLPRECEIVED_out  :  std_ulogic;
	signal   L0STATSDLLPTRANSMITTED_out  :  std_ulogic;
	signal   L0STATSOSRECEIVED_out  :  std_ulogic;
	signal   L0STATSOSTRANSMITTED_out  :  std_ulogic;
	signal   L0STATSTLPRECEIVED_out  :  std_ulogic;
	signal   L0STATSTLPTRANSMITTED_out  :  std_ulogic;
	signal   L0STATSCFGRECEIVED_out  :  std_ulogic;
	signal   L0STATSCFGTRANSMITTED_out  :  std_ulogic;
	signal   L0STATSCFGOTHERRECEIVED_out  :  std_ulogic;
	signal   L0STATSCFGOTHERTRANSMITTED_out  :  std_ulogic;
	signal   MAXPAYLOADSIZE_out  :  std_logic_vector(2 downto 0);
	signal   MAXREADREQUESTSIZE_out  :  std_logic_vector(2 downto 0);
	signal   IOSPACEENABLE_out  :  std_ulogic;
	signal   MEMSPACEENABLE_out  :  std_ulogic;
	signal   L0ATTENTIONINDICATORCONTROL_out  :  std_logic_vector(1 downto 0);
	signal   L0POWERINDICATORCONTROL_out  :  std_logic_vector(1 downto 0);
	signal   L0POWERCONTROLLERCONTROL_out  :  std_ulogic;
	signal   L0TOGGLEELECTROMECHANICALINTERLOCK_out  :  std_ulogic;
	signal   L0RXBEACON_out  :  std_ulogic;
	signal   L0PWRSTATE0_out  :  std_logic_vector(1 downto 0);
	signal   L0PMEACK_out  :  std_ulogic;
	signal   L0PMEREQOUT_out  :  std_ulogic;
	signal   L0PMEEN_out  :  std_ulogic;
	signal   L0PWRINHIBITTRANSFERS_out  :  std_ulogic;
	signal   L0PWRL1STATE_out  :  std_ulogic;
	signal   L0PWRL23READYDEVICE_out  :  std_ulogic;
	signal   L0PWRL23READYSTATE_out  :  std_ulogic;
	signal   L0PWRTXL0SSTATE_out  :  std_ulogic;
	signal   L0PWRTURNOFFREQ_out  :  std_ulogic;
	signal   L0RXDLLPM_out  :  std_ulogic;
	signal   L0RXDLLPMTYPE_out  :  std_logic_vector(2 downto 0);
	signal   L0TXDLLPMUPDATED_out  :  std_ulogic;
	signal   L0MACNEWSTATEACK_out  :  std_ulogic;
	signal   L0MACRXL0SSTATE_out  :  std_ulogic;
	signal   L0MACENTEREDL0_out  :  std_ulogic;
	signal   L0DLLRXACKOUTSTANDING_out  :  std_ulogic;
	signal   L0DLLTXOUTSTANDING_out  :  std_ulogic;
	signal   L0DLLTXNONFCOUTSTANDING_out  :  std_ulogic;
	signal   L0RXDLLTLPEND_out  :  std_logic_vector(1 downto 0);
	signal   L0TXDLLSBFCUPDATED_out  :  std_ulogic;
	signal   L0RXDLLSBFCDATA_out  :  std_logic_vector(18 downto 0);
	signal   L0RXDLLSBFCUPDATE_out  :  std_ulogic;
	signal   L0TXDLLFCNPOSTBYPUPDATED_out  :  std_logic_vector(7 downto 0);
	signal   L0TXDLLFCPOSTORDUPDATED_out  :  std_logic_vector(7 downto 0);
	signal   L0TXDLLFCCMPLMCUPDATED_out  :  std_logic_vector(7 downto 0);
	signal   L0RXDLLFCNPOSTBYPCRED_out  :  std_logic_vector(19 downto 0);
	signal   L0RXDLLFCNPOSTBYPUPDATE_out  :  std_logic_vector(7 downto 0);
	signal   L0RXDLLFCPOSTORDCRED_out  :  std_logic_vector(23 downto 0);
	signal   L0RXDLLFCPOSTORDUPDATE_out  :  std_logic_vector(7 downto 0);
	signal   L0RXDLLFCCMPLMCCRED_out  :  std_logic_vector(23 downto 0);
	signal   L0RXDLLFCCMPLMCUPDATE_out  :  std_logic_vector(7 downto 0);
	signal   L0UCBYPFOUND_out  :  std_logic_vector(3 downto 0);
	signal   L0UCORDFOUND_out  :  std_logic_vector(3 downto 0);
	signal   L0MCFOUND_out  :  std_logic_vector(2 downto 0);
	signal   L0TRANSFORMEDVC_out  :  std_logic_vector(2 downto 0);
	signal   BUSMASTERENABLE_out  :  std_ulogic;
	signal   PARITYERRORRESPONSE_out  :  std_ulogic;
	signal   SERRENABLE_out  :  std_ulogic;
	signal   INTERRUPTDISABLE_out  :  std_ulogic;
	signal   URREPORTINGENABLE_out  :  std_ulogic;


	signal   PIPETXDATAL0_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL0_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL0_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL0_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL0_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL0_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL0_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL0_outdelay  :  std_ulogic;
	signal   PIPERESETL0_outdelay  :  std_ulogic;
	signal   PIPETXDATAL1_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL1_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL1_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL1_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL1_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL1_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL1_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL1_outdelay  :  std_ulogic;
	signal   PIPERESETL1_outdelay  :  std_ulogic;
	signal   PIPETXDATAL2_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL2_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL2_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL2_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL2_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL2_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL2_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL2_outdelay  :  std_ulogic;
	signal   PIPERESETL2_outdelay  :  std_ulogic;
	signal   PIPETXDATAL3_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL3_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL3_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL3_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL3_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL3_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL3_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL3_outdelay  :  std_ulogic;
	signal   PIPERESETL3_outdelay  :  std_ulogic;
	signal   PIPETXDATAL4_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL4_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL4_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL4_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL4_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL4_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL4_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL4_outdelay  :  std_ulogic;
	signal   PIPERESETL4_outdelay  :  std_ulogic;
	signal   PIPETXDATAL5_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL5_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL5_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL5_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL5_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL5_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL5_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL5_outdelay  :  std_ulogic;
	signal   PIPERESETL5_outdelay  :  std_ulogic;
	signal   PIPETXDATAL6_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL6_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL6_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL6_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL6_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL6_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL6_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL6_outdelay  :  std_ulogic;
	signal   PIPERESETL6_outdelay  :  std_ulogic;
	signal   PIPETXDATAL7_outdelay  :  std_logic_vector(7 downto 0);
	signal   PIPETXDATAKL7_outdelay  :  std_ulogic;
	signal   PIPETXELECIDLEL7_outdelay  :  std_ulogic;
	signal   PIPETXDETECTRXLOOPBACKL7_outdelay  :  std_ulogic;
	signal   PIPETXCOMPLIANCEL7_outdelay  :  std_ulogic;
	signal   PIPERXPOLARITYL7_outdelay  :  std_ulogic;
	signal   PIPEPOWERDOWNL7_outdelay  :  std_logic_vector(1 downto 0);
	signal   PIPEDESKEWLANESL7_outdelay  :  std_ulogic;
	signal   PIPERESETL7_outdelay  :  std_ulogic;
	signal   MIMRXBWDATA_outdelay  :  std_logic_vector(63 downto 0);
	signal   MIMRXBWADD_outdelay  :  std_logic_vector(12 downto 0);
	signal   MIMRXBRADD_outdelay  :  std_logic_vector(12 downto 0);
	signal   MIMRXBWEN_outdelay  :  std_ulogic;
	signal   MIMRXBREN_outdelay  :  std_ulogic;
	signal   MIMTXBWDATA_outdelay  :  std_logic_vector(63 downto 0);
	signal   MIMTXBWADD_outdelay  :  std_logic_vector(12 downto 0);
	signal   MIMTXBRADD_outdelay  :  std_logic_vector(12 downto 0);
	signal   MIMTXBWEN_outdelay  :  std_ulogic;
	signal   MIMTXBREN_outdelay  :  std_ulogic;
	signal   MIMDLLBWDATA_outdelay  :  std_logic_vector(63 downto 0);
	signal   MIMDLLBWADD_outdelay  :  std_logic_vector(11 downto 0);
	signal   MIMDLLBRADD_outdelay  :  std_logic_vector(11 downto 0);
	signal   MIMDLLBWEN_outdelay  :  std_ulogic;
	signal   MIMDLLBREN_outdelay  :  std_ulogic;
	signal   CRMRXHOTRESETN_outdelay  :  std_ulogic;
	signal   CRMDOHOTRESETN_outdelay  :  std_ulogic;
	signal   CRMPWRSOFTRESETN_outdelay  :  std_ulogic;
	signal   LLKTCSTATUS_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKTXDSTRDYN_outdelay  :  std_ulogic;
	signal   LLKTXCHANSPACE_outdelay  :  std_logic_vector(9 downto 0);
	signal   LLKTXCHPOSTEDREADYN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKTXCHNONPOSTEDREADYN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKTXCHCOMPLETIONREADYN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKTXCONFIGREADYN_outdelay  :  std_ulogic;
	signal   LLKRXDATA_outdelay  :  std_logic_vector(63 downto 0);
	signal   LLKRXSRCRDYN_outdelay  :  std_ulogic;
	signal   LLKRXSRCLASTREQN_outdelay  :  std_ulogic;
	signal   LLKRXSRCDSCN_outdelay  :  std_ulogic;
	signal   LLKRXSOFN_outdelay  :  std_ulogic;
	signal   LLKRXEOFN_outdelay  :  std_ulogic;
	signal   LLKRXSOPN_outdelay  :  std_ulogic;
	signal   LLKRXEOPN_outdelay  :  std_ulogic;
	signal   LLKRXVALIDN_outdelay  :  std_logic_vector(1 downto 0);
	signal   LLKRXPREFERREDTYPE_outdelay  :  std_logic_vector(15 downto 0);
	signal   LLKRXCHPOSTEDAVAILABLEN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHNONPOSTEDAVAILABLEN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCOMPLETIONAVAILABLEN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCONFIGAVAILABLEN_outdelay  :  std_ulogic;
	signal   LLKRXCHPOSTEDPARTIALN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHNONPOSTEDPARTIALN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCOMPLETIONPARTIALN_outdelay  :  std_logic_vector(7 downto 0);
	signal   LLKRXCHCONFIGPARTIALN_outdelay  :  std_ulogic;
	signal   LLKRX4DWHEADERN_outdelay  :  std_ulogic;
	signal   LLKRXECRCBADN_outdelay  :  std_ulogic;
	signal   MGMTRDATA_outdelay  :  std_logic_vector(31 downto 0);
	signal   MGMTPSO_outdelay  :  std_logic_vector(16 downto 0);
	signal   MGMTSTATSCREDIT_outdelay  :  std_logic_vector(11 downto 0);
	signal   L0RXDLLTLPECRCOK_outdelay  :  std_ulogic;
	signal   DLLTXPMDLLPOUTSTANDING_outdelay  :  std_ulogic;
	signal   L0FIRSTCFGWRITEOCCURRED_outdelay  :  std_ulogic;
	signal   L0CFGLOOPBACKACK_outdelay  :  std_ulogic;
	signal   L0MACUPSTREAMDOWNSTREAM_outdelay  :  std_ulogic;
	signal   L0RXMACLINKERROR_outdelay  :  std_logic_vector(1 downto 0);
	signal   L0MACLINKUP_outdelay  :  std_ulogic;
	signal   L0MACNEGOTIATEDLINKWIDTH_outdelay  :  std_logic_vector(3 downto 0);
	signal   L0MACLINKTRAINING_outdelay  :  std_ulogic;
	signal   L0LTSSMSTATE_outdelay  :  std_logic_vector(3 downto 0);
	signal   L0DLLVCSTATUS_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0DLUPDOWN_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0DLLERRORVECTOR_outdelay  :  std_logic_vector(6 downto 0);
	signal   L0DLLASRXSTATE_outdelay  :  std_logic_vector(1 downto 0);
	signal   L0DLLASTXSTATE_outdelay  :  std_ulogic;
	signal   L0ASAUTONOMOUSINITCOMPLETED_outdelay  :  std_ulogic;
	signal   L0COMPLETERID_outdelay  :  std_logic_vector(12 downto 0);
	signal   L0UNLOCKRECEIVED_outdelay  :  std_ulogic;
	signal   L0CORRERRMSGRCVD_outdelay  :  std_ulogic;
	signal   L0FATALERRMSGRCVD_outdelay  :  std_ulogic;
	signal   L0NONFATALERRMSGRCVD_outdelay  :  std_ulogic;
	signal   L0ERRMSGREQID_outdelay  :  std_logic_vector(15 downto 0);
	signal   L0FWDCORRERROUT_outdelay  :  std_ulogic;
	signal   L0FWDFATALERROUT_outdelay  :  std_ulogic;
	signal   L0FWDNONFATALERROUT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTALEGACYINT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTBLEGACYINT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTCLEGACYINT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDASSERTINTDLEGACYINT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTALEGACYINT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTBLEGACYINT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTCLEGACYINT_outdelay  :  std_ulogic;
	signal   L0RECEIVEDDEASSERTINTDLEGACYINT_outdelay  :  std_ulogic;
	signal   L0MSIENABLE0_outdelay  :  std_ulogic;
	signal   L0MULTIMSGEN0_outdelay  :  std_logic_vector(2 downto 0);
	signal   L0STATSDLLPRECEIVED_outdelay  :  std_ulogic;
	signal   L0STATSDLLPTRANSMITTED_outdelay  :  std_ulogic;
	signal   L0STATSOSRECEIVED_outdelay  :  std_ulogic;
	signal   L0STATSOSTRANSMITTED_outdelay  :  std_ulogic;
	signal   L0STATSTLPRECEIVED_outdelay  :  std_ulogic;
	signal   L0STATSTLPTRANSMITTED_outdelay  :  std_ulogic;
	signal   L0STATSCFGRECEIVED_outdelay  :  std_ulogic;
	signal   L0STATSCFGTRANSMITTED_outdelay  :  std_ulogic;
	signal   L0STATSCFGOTHERRECEIVED_outdelay  :  std_ulogic;
	signal   L0STATSCFGOTHERTRANSMITTED_outdelay  :  std_ulogic;
	signal   MAXPAYLOADSIZE_outdelay  :  std_logic_vector(2 downto 0);
	signal   MAXREADREQUESTSIZE_outdelay  :  std_logic_vector(2 downto 0);
	signal   IOSPACEENABLE_outdelay  :  std_ulogic;
	signal   MEMSPACEENABLE_outdelay  :  std_ulogic;
	signal   L0ATTENTIONINDICATORCONTROL_outdelay  :  std_logic_vector(1 downto 0);
	signal   L0POWERINDICATORCONTROL_outdelay  :  std_logic_vector(1 downto 0);
	signal   L0POWERCONTROLLERCONTROL_outdelay  :  std_ulogic;
	signal   L0TOGGLEELECTROMECHANICALINTERLOCK_outdelay  :  std_ulogic;
	signal   L0RXBEACON_outdelay  :  std_ulogic;
	signal   L0PWRSTATE0_outdelay  :  std_logic_vector(1 downto 0);
	signal   L0PMEACK_outdelay  :  std_ulogic;
	signal   L0PMEREQOUT_outdelay  :  std_ulogic;
	signal   L0PMEEN_outdelay  :  std_ulogic;
	signal   L0PWRINHIBITTRANSFERS_outdelay  :  std_ulogic;
	signal   L0PWRL1STATE_outdelay  :  std_ulogic;
	signal   L0PWRL23READYDEVICE_outdelay  :  std_ulogic;
	signal   L0PWRL23READYSTATE_outdelay  :  std_ulogic;
	signal   L0PWRTXL0SSTATE_outdelay  :  std_ulogic;
	signal   L0PWRTURNOFFREQ_outdelay  :  std_ulogic;
	signal   L0RXDLLPM_outdelay  :  std_ulogic;
	signal   L0RXDLLPMTYPE_outdelay  :  std_logic_vector(2 downto 0);
	signal   L0TXDLLPMUPDATED_outdelay  :  std_ulogic;
	signal   L0MACNEWSTATEACK_outdelay  :  std_ulogic;
	signal   L0MACRXL0SSTATE_outdelay  :  std_ulogic;
	signal   L0MACENTEREDL0_outdelay  :  std_ulogic;
	signal   L0DLLRXACKOUTSTANDING_outdelay  :  std_ulogic;
	signal   L0DLLTXOUTSTANDING_outdelay  :  std_ulogic;
	signal   L0DLLTXNONFCOUTSTANDING_outdelay  :  std_ulogic;
	signal   L0RXDLLTLPEND_outdelay  :  std_logic_vector(1 downto 0);
	signal   L0TXDLLSBFCUPDATED_outdelay  :  std_ulogic;
	signal   L0RXDLLSBFCDATA_outdelay  :  std_logic_vector(18 downto 0);
	signal   L0RXDLLSBFCUPDATE_outdelay  :  std_ulogic;
	signal   L0TXDLLFCNPOSTBYPUPDATED_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0TXDLLFCPOSTORDUPDATED_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0TXDLLFCCMPLMCUPDATED_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0RXDLLFCNPOSTBYPCRED_outdelay  :  std_logic_vector(19 downto 0);
	signal   L0RXDLLFCNPOSTBYPUPDATE_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0RXDLLFCPOSTORDCRED_outdelay  :  std_logic_vector(23 downto 0);
	signal   L0RXDLLFCPOSTORDUPDATE_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0RXDLLFCCMPLMCCRED_outdelay  :  std_logic_vector(23 downto 0);
	signal   L0RXDLLFCCMPLMCUPDATE_outdelay  :  std_logic_vector(7 downto 0);
	signal   L0UCBYPFOUND_outdelay  :  std_logic_vector(3 downto 0);
	signal   L0UCORDFOUND_outdelay  :  std_logic_vector(3 downto 0);
	signal   L0MCFOUND_outdelay  :  std_logic_vector(2 downto 0);
	signal   L0TRANSFORMEDVC_outdelay  :  std_logic_vector(2 downto 0);
	signal   BUSMASTERENABLE_outdelay  :  std_ulogic;
	signal   PARITYERRORRESPONSE_outdelay  :  std_ulogic;
	signal   SERRENABLE_outdelay  :  std_ulogic;
	signal   INTERRUPTDISABLE_outdelay  :  std_ulogic;
	signal   URREPORTINGENABLE_outdelay  :  std_ulogic;

	signal   PIPERXELECIDLEL0_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL0_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL0_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL0_ipd  :  std_ulogic;
	signal   PIPERXDATAKL0_ipd  :  std_ulogic;
	signal   PIPERXVALIDL0_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL0_ipd  :  std_ulogic;
	signal   PIPERXELECIDLEL1_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL1_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL1_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL1_ipd  :  std_ulogic;
	signal   PIPERXDATAKL1_ipd  :  std_ulogic;
	signal   PIPERXVALIDL1_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL1_ipd  :  std_ulogic;
	signal   PIPERXELECIDLEL2_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL2_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL2_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL2_ipd  :  std_ulogic;
	signal   PIPERXDATAKL2_ipd  :  std_ulogic;
	signal   PIPERXVALIDL2_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL2_ipd  :  std_ulogic;
	signal   PIPERXELECIDLEL3_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL3_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL3_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL3_ipd  :  std_ulogic;
	signal   PIPERXDATAKL3_ipd  :  std_ulogic;
	signal   PIPERXVALIDL3_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL3_ipd  :  std_ulogic;
	signal   PIPERXELECIDLEL4_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL4_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL4_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL4_ipd  :  std_ulogic;
	signal   PIPERXDATAKL4_ipd  :  std_ulogic;
	signal   PIPERXVALIDL4_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL4_ipd  :  std_ulogic;
	signal   PIPERXELECIDLEL5_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL5_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL5_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL5_ipd  :  std_ulogic;
	signal   PIPERXDATAKL5_ipd  :  std_ulogic;
	signal   PIPERXVALIDL5_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL5_ipd  :  std_ulogic;
	signal   PIPERXELECIDLEL6_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL6_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL6_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL6_ipd  :  std_ulogic;
	signal   PIPERXDATAKL6_ipd  :  std_ulogic;
	signal   PIPERXVALIDL6_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL6_ipd  :  std_ulogic;
	signal   PIPERXELECIDLEL7_ipd  :  std_ulogic;
	signal   PIPERXSTATUSL7_ipd  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL7_ipd  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL7_ipd  :  std_ulogic;
	signal   PIPERXDATAKL7_ipd  :  std_ulogic;
	signal   PIPERXVALIDL7_ipd  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL7_ipd  :  std_ulogic;
	signal   MIMRXBRDATA_ipd  :  std_logic_vector(63 downto 0);
	signal   CRMCORECLKRXO_ipd  :  std_ulogic;
	signal   CRMUSERCLKRXO_ipd  :  std_ulogic;
	signal   MIMTXBRDATA_ipd  :  std_logic_vector(63 downto 0);
	signal   CRMCORECLKTXO_ipd  :  std_ulogic;
	signal   CRMUSERCLKTXO_ipd  :  std_ulogic;
	signal   MIMDLLBRDATA_ipd  :  std_logic_vector(63 downto 0);
	signal   CRMCORECLKDLO_ipd  :  std_ulogic;
	signal   CRMCORECLK_ipd  :  std_ulogic;
	signal   CRMUSERCLK_ipd  :  std_ulogic;
	signal   CRMURSTN_ipd  :  std_ulogic;
	signal   CRMNVRSTN_ipd  :  std_ulogic;
	signal   CRMMGMTRSTN_ipd  :  std_ulogic;
	signal   CRMUSERCFGRSTN_ipd  :  std_ulogic;
	signal   CRMMACRSTN_ipd  :  std_ulogic;
	signal   CRMLINKRSTN_ipd  :  std_ulogic;
	signal   CRMTXHOTRESETN_ipd  :  std_ulogic;
	signal   CRMCFGBRIDGEHOTRESET_ipd  :  std_ulogic;
	signal   LLKTXDATA_ipd  :  std_logic_vector(63 downto 0);
	signal   LLKTXSRCRDYN_ipd  :  std_ulogic;
	signal   LLKTXSRCDSCN_ipd  :  std_ulogic;
	signal   LLKTXCOMPLETEN_ipd  :  std_ulogic;
	signal   LLKTXSOFN_ipd  :  std_ulogic;
	signal   LLKTXEOFN_ipd  :  std_ulogic;
	signal   LLKTXSOPN_ipd  :  std_ulogic;
	signal   LLKTXEOPN_ipd  :  std_ulogic;
	signal   LLKTXENABLEN_ipd  :  std_logic_vector(1 downto 0);
	signal   LLKTXCHTC_ipd  :  std_logic_vector(2 downto 0);
	signal   LLKTXCHFIFO_ipd  :  std_logic_vector(1 downto 0);
	signal   LLKTXCREATEECRCN_ipd  :  std_ulogic;
	signal   LLKTX4DWHEADERN_ipd  :  std_ulogic;
	signal   LLKRXDSTREQN_ipd  :  std_ulogic;
	signal   LLKRXCHTC_ipd  :  std_logic_vector(2 downto 0);
	signal   LLKRXCHFIFO_ipd  :  std_logic_vector(1 downto 0);
	signal   LLKRXDSTCONTREQN_ipd  :  std_ulogic;
	signal   MGMTWDATA_ipd  :  std_logic_vector(31 downto 0);
	signal   MGMTBWREN_ipd  :  std_logic_vector(3 downto 0);
	signal   MGMTWREN_ipd  :  std_ulogic;
	signal   MGMTADDR_ipd  :  std_logic_vector(10 downto 0);
	signal   MGMTRDEN_ipd  :  std_ulogic;
	signal   MGMTSTATSCREDITSEL_ipd  :  std_logic_vector(6 downto 0);
	signal   MAINPOWER_ipd  :  std_ulogic;
	signal   AUXPOWER_ipd  :  std_ulogic;
	signal   L0TLLINKRETRAIN_ipd  :  std_ulogic;
	signal   CFGNEGOTIATEDLINKWIDTH_ipd  :  std_logic_vector(5 downto 0);
	signal   CROSSLINKSEED_ipd  :  std_ulogic;
	signal   COMPLIANCEAVOID_ipd  :  std_ulogic;
	signal   L0VC0PREVIEWEXPAND_ipd  :  std_ulogic;
	signal   L0CFGVCID_ipd  :  std_logic_vector(23 downto 0);
	signal   L0CFGLOOPBACKMASTER_ipd  :  std_ulogic;
	signal   L0REPLAYTIMERADJUSTMENT_ipd  :  std_logic_vector(11 downto 0);
	signal   L0ACKNAKTIMERADJUSTMENT_ipd  :  std_logic_vector(11 downto 0);
	signal   L0DLLHOLDLINKUP_ipd  :  std_ulogic;
	signal   L0CFGASSTATECHANGECMD_ipd  :  std_logic_vector(3 downto 0);
	signal   L0CFGASSPANTREEOWNEDSTATE_ipd  :  std_ulogic;
	signal   L0ASE_ipd  :  std_ulogic;
	signal   L0ASTURNPOOLBITSCONSUMED_ipd  :  std_logic_vector(2 downto 0);
	signal   L0ASPORTCOUNT_ipd  :  std_logic_vector(7 downto 0);
	signal   L0CFGVCENABLE_ipd  :  std_logic_vector(7 downto 0);
	signal   L0CFGNEGOTIATEDMAXP_ipd  :  std_logic_vector(2 downto 0);
	signal   L0CFGDISABLESCRAMBLE_ipd  :  std_ulogic;
	signal   L0CFGEXTENDEDSYNC_ipd  :  std_ulogic;
	signal   L0CFGLINKDISABLE_ipd  :  std_ulogic;
	signal   L0PORTNUMBER_ipd  :  std_logic_vector(7 downto 0);
	signal   L0SENDUNLOCKMESSAGE_ipd  :  std_ulogic;
	signal   L0ALLDOWNRXPORTSINL0S_ipd  :  std_ulogic;
	signal   L0UPSTREAMRXPORTINL0S_ipd  :  std_ulogic;
	signal   L0TRANSACTIONSPENDING_ipd  :  std_ulogic;
	signal   L0ALLDOWNPORTSINL1_ipd  :  std_ulogic;
	signal   L0FWDCORRERRIN_ipd  :  std_ulogic;
	signal   L0FWDFATALERRIN_ipd  :  std_ulogic;
	signal   L0FWDNONFATALERRIN_ipd  :  std_ulogic;
	signal   L0SETCOMPLETERABORTERROR_ipd  :  std_ulogic;
	signal   L0SETDETECTEDCORRERROR_ipd  :  std_ulogic;
	signal   L0SETDETECTEDFATALERROR_ipd  :  std_ulogic;
	signal   L0SETDETECTEDNONFATALERROR_ipd  :  std_ulogic;
	signal   L0SETLINKDETECTEDPARITYERROR_ipd  :  std_ulogic;
	signal   L0SETLINKMASTERDATAPARITY_ipd  :  std_ulogic;
	signal   L0SETLINKRECEIVEDMASTERABORT_ipd  :  std_ulogic;
	signal   L0SETLINKRECEIVEDTARGETABORT_ipd  :  std_ulogic;
	signal   L0SETLINKSYSTEMERROR_ipd  :  std_ulogic;
	signal   L0SETLINKSIGNALLEDTARGETABORT_ipd  :  std_ulogic;
	signal   L0SETUSERDETECTEDPARITYERROR_ipd  :  std_ulogic;
	signal   L0SETUSERMASTERDATAPARITY_ipd  :  std_ulogic;
	signal   L0SETUSERRECEIVEDMASTERABORT_ipd  :  std_ulogic;
	signal   L0SETUSERRECEIVEDTARGETABORT_ipd  :  std_ulogic;
	signal   L0SETUSERSYSTEMERROR_ipd  :  std_ulogic;
	signal   L0SETUSERSIGNALLEDTARGETABORT_ipd  :  std_ulogic;
	signal   L0SETCOMPLETIONTIMEOUTUNCORRERROR_ipd  :  std_ulogic;
	signal   L0SETCOMPLETIONTIMEOUTCORRERROR_ipd  :  std_ulogic;
	signal   L0SETUNEXPECTEDCOMPLETIONUNCORRERROR_ipd  :  std_ulogic;
	signal   L0SETUNEXPECTEDCOMPLETIONCORRERROR_ipd  :  std_ulogic;
	signal   L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR_ipd  :  std_ulogic;
	signal   L0SETUNSUPPORTEDREQUESTOTHERERROR_ipd  :  std_ulogic;
	signal   L0PACKETHEADERFROMUSER_ipd  :  std_logic_vector(127 downto 0);
	signal   L0LEGACYINTFUNCT0_ipd  :  std_ulogic;
	signal   L0FWDASSERTINTALEGACYINT_ipd  :  std_ulogic;
	signal   L0FWDASSERTINTBLEGACYINT_ipd  :  std_ulogic;
	signal   L0FWDASSERTINTCLEGACYINT_ipd  :  std_ulogic;
	signal   L0FWDASSERTINTDLEGACYINT_ipd  :  std_ulogic;
	signal   L0FWDDEASSERTINTALEGACYINT_ipd  :  std_ulogic;
	signal   L0FWDDEASSERTINTBLEGACYINT_ipd  :  std_ulogic;
	signal   L0FWDDEASSERTINTCLEGACYINT_ipd  :  std_ulogic;
	signal   L0FWDDEASSERTINTDLEGACYINT_ipd  :  std_ulogic;
	signal   L0MSIREQUEST0_ipd  :  std_logic_vector(3 downto 0);
	signal   L0ELECTROMECHANICALINTERLOCKENGAGED_ipd  :  std_ulogic;
	signal   L0MRLSENSORCLOSEDN_ipd  :  std_ulogic;
	signal   L0POWERFAULTDETECTED_ipd  :  std_ulogic;
	signal   L0PRESENCEDETECTSLOTEMPTYN_ipd  :  std_ulogic;
	signal   L0ATTENTIONBUTTONPRESSED_ipd  :  std_ulogic;
	signal   L0TXBEACON_ipd  :  std_ulogic;
	signal   L0WAKEN_ipd  :  std_ulogic;
	signal   L0PMEREQIN_ipd  :  std_ulogic;
	signal   L0ROOTTURNOFFREQ_ipd  :  std_ulogic;
	signal   L0TXCFGPM_ipd  :  std_ulogic;
	signal   L0TXCFGPMTYPE_ipd  :  std_logic_vector(2 downto 0);
	signal   L0PWRNEWSTATEREQ_ipd  :  std_ulogic;
	signal   L0PWRNEXTLINKSTATE_ipd  :  std_logic_vector(1 downto 0);
	signal   L0CFGL0SENTRYSUP_ipd  :  std_ulogic;
	signal   L0CFGL0SENTRYENABLE_ipd  :  std_ulogic;
	signal   L0CFGL0SEXITLAT_ipd  :  std_logic_vector(2 downto 0);
	signal   L0TXTLTLPDATA_ipd  :  std_logic_vector(63 downto 0);
	signal   L0TXTLTLPEND_ipd  :  std_logic_vector(1 downto 0);
	signal   L0TXTLTLPENABLE_ipd  :  std_logic_vector(1 downto 0);
	signal   L0TXTLTLPEDB_ipd  :  std_ulogic;
	signal   L0TXTLTLPREQ_ipd  :  std_ulogic;
	signal   L0TXTLTLPREQEND_ipd  :  std_ulogic;
	signal   L0TXTLTLPWIDTH_ipd  :  std_ulogic;
	signal   L0TXTLTLPLATENCY_ipd  :  std_logic_vector(3 downto 0);
	signal   L0TLASFCCREDSTARVATION_ipd  :  std_ulogic;
	signal   L0TXTLSBFCDATA_ipd  :  std_logic_vector(18 downto 0);
	signal   L0TXTLSBFCUPDATE_ipd  :  std_ulogic;
	signal   L0TXTLFCNPOSTBYPCRED_ipd  :  std_logic_vector(191 downto 0);
	signal   L0TXTLFCNPOSTBYPUPDATE_ipd  :  std_logic_vector(15 downto 0);
	signal   L0TXTLFCPOSTORDCRED_ipd  :  std_logic_vector(159 downto 0);
	signal   L0TXTLFCPOSTORDUPDATE_ipd  :  std_logic_vector(15 downto 0);
	signal   L0TXTLFCCMPLMCCRED_ipd  :  std_logic_vector(159 downto 0);
	signal   L0TXTLFCCMPLMCUPDATE_ipd  :  std_logic_vector(15 downto 0);
	signal   L0RXTLTLPNONINITIALIZEDVC_ipd  :  std_logic_vector(7 downto 0);


	signal   PIPERXELECIDLEL0_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL0_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL0_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL0_indelay  :  std_ulogic;
	signal   PIPERXDATAKL0_indelay  :  std_ulogic;
	signal   PIPERXVALIDL0_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL0_indelay  :  std_ulogic;
	signal   PIPERXELECIDLEL1_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL1_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL1_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL1_indelay  :  std_ulogic;
	signal   PIPERXDATAKL1_indelay  :  std_ulogic;
	signal   PIPERXVALIDL1_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL1_indelay  :  std_ulogic;
	signal   PIPERXELECIDLEL2_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL2_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL2_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL2_indelay  :  std_ulogic;
	signal   PIPERXDATAKL2_indelay  :  std_ulogic;
	signal   PIPERXVALIDL2_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL2_indelay  :  std_ulogic;
	signal   PIPERXELECIDLEL3_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL3_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL3_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL3_indelay  :  std_ulogic;
	signal   PIPERXDATAKL3_indelay  :  std_ulogic;
	signal   PIPERXVALIDL3_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL3_indelay  :  std_ulogic;
	signal   PIPERXELECIDLEL4_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL4_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL4_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL4_indelay  :  std_ulogic;
	signal   PIPERXDATAKL4_indelay  :  std_ulogic;
	signal   PIPERXVALIDL4_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL4_indelay  :  std_ulogic;
	signal   PIPERXELECIDLEL5_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL5_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL5_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL5_indelay  :  std_ulogic;
	signal   PIPERXDATAKL5_indelay  :  std_ulogic;
	signal   PIPERXVALIDL5_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL5_indelay  :  std_ulogic;
	signal   PIPERXELECIDLEL6_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL6_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL6_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL6_indelay  :  std_ulogic;
	signal   PIPERXDATAKL6_indelay  :  std_ulogic;
	signal   PIPERXVALIDL6_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL6_indelay  :  std_ulogic;
	signal   PIPERXELECIDLEL7_indelay  :  std_ulogic;
	signal   PIPERXSTATUSL7_indelay  :  std_logic_vector(2 downto 0);
	signal   PIPERXDATAL7_indelay  :  std_logic_vector(7 downto 0);
	signal   PIPEPHYSTATUSL7_indelay  :  std_ulogic;
	signal   PIPERXDATAKL7_indelay  :  std_ulogic;
	signal   PIPERXVALIDL7_indelay  :  std_ulogic;
	signal   PIPERXCHANISALIGNEDL7_indelay  :  std_ulogic;
	signal   MIMRXBRDATA_indelay  :  std_logic_vector(63 downto 0);
	signal   CRMCORECLKRXO_indelay  :  std_ulogic;
	signal   CRMUSERCLKRXO_indelay  :  std_ulogic;
	signal   MIMTXBRDATA_indelay  :  std_logic_vector(63 downto 0);
	signal   CRMCORECLKTXO_indelay  :  std_ulogic;
	signal   CRMUSERCLKTXO_indelay  :  std_ulogic;
	signal   MIMDLLBRDATA_indelay  :  std_logic_vector(63 downto 0);
	signal   CRMCORECLKDLO_indelay  :  std_ulogic;
	signal   CRMCORECLK_indelay  :  std_ulogic;
	signal   CRMUSERCLK_indelay  :  std_ulogic;
	signal   CRMURSTN_indelay  :  std_ulogic;
	signal   CRMNVRSTN_indelay  :  std_ulogic;
	signal   CRMMGMTRSTN_indelay  :  std_ulogic;
	signal   CRMUSERCFGRSTN_indelay  :  std_ulogic;
	signal   CRMMACRSTN_indelay  :  std_ulogic;
	signal   CRMLINKRSTN_indelay  :  std_ulogic;
	signal   CRMTXHOTRESETN_indelay  :  std_ulogic;
	signal   CRMCFGBRIDGEHOTRESET_indelay  :  std_ulogic;
	signal   LLKTXDATA_indelay  :  std_logic_vector(63 downto 0);
	signal   LLKTXSRCRDYN_indelay  :  std_ulogic;
	signal   LLKTXSRCDSCN_indelay  :  std_ulogic;
	signal   LLKTXCOMPLETEN_indelay  :  std_ulogic;
	signal   LLKTXSOFN_indelay  :  std_ulogic;
	signal   LLKTXEOFN_indelay  :  std_ulogic;
	signal   LLKTXSOPN_indelay  :  std_ulogic;
	signal   LLKTXEOPN_indelay  :  std_ulogic;
	signal   LLKTXENABLEN_indelay  :  std_logic_vector(1 downto 0);
	signal   LLKTXCHTC_indelay  :  std_logic_vector(2 downto 0);
	signal   LLKTXCHFIFO_indelay  :  std_logic_vector(1 downto 0);
	signal   LLKTXCREATEECRCN_indelay  :  std_ulogic;
	signal   LLKTX4DWHEADERN_indelay  :  std_ulogic;
	signal   LLKRXDSTREQN_indelay  :  std_ulogic;
	signal   LLKRXCHTC_indelay  :  std_logic_vector(2 downto 0);
	signal   LLKRXCHFIFO_indelay  :  std_logic_vector(1 downto 0);
	signal   LLKRXDSTCONTREQN_indelay  :  std_ulogic;
	signal   MGMTWDATA_indelay  :  std_logic_vector(31 downto 0);
	signal   MGMTBWREN_indelay  :  std_logic_vector(3 downto 0);
	signal   MGMTWREN_indelay  :  std_ulogic;
	signal   MGMTADDR_indelay  :  std_logic_vector(10 downto 0);
	signal   MGMTRDEN_indelay  :  std_ulogic;
	signal   MGMTSTATSCREDITSEL_indelay  :  std_logic_vector(6 downto 0);
	signal   MAINPOWER_indelay  :  std_ulogic;
	signal   AUXPOWER_indelay  :  std_ulogic;
	signal   L0TLLINKRETRAIN_indelay  :  std_ulogic;
	signal   CFGNEGOTIATEDLINKWIDTH_indelay  :  std_logic_vector(5 downto 0);
	signal   CROSSLINKSEED_indelay  :  std_ulogic;
	signal   COMPLIANCEAVOID_indelay  :  std_ulogic;
	signal   L0VC0PREVIEWEXPAND_indelay  :  std_ulogic;
	signal   L0CFGVCID_indelay  :  std_logic_vector(23 downto 0);
	signal   L0CFGLOOPBACKMASTER_indelay  :  std_ulogic;
	signal   L0REPLAYTIMERADJUSTMENT_indelay  :  std_logic_vector(11 downto 0);
	signal   L0ACKNAKTIMERADJUSTMENT_indelay  :  std_logic_vector(11 downto 0);
	signal   L0DLLHOLDLINKUP_indelay  :  std_ulogic;
	signal   L0CFGASSTATECHANGECMD_indelay  :  std_logic_vector(3 downto 0);
	signal   L0CFGASSPANTREEOWNEDSTATE_indelay  :  std_ulogic;
	signal   L0ASE_indelay  :  std_ulogic;
	signal   L0ASTURNPOOLBITSCONSUMED_indelay  :  std_logic_vector(2 downto 0);
	signal   L0ASPORTCOUNT_indelay  :  std_logic_vector(7 downto 0);
	signal   L0CFGVCENABLE_indelay  :  std_logic_vector(7 downto 0);
	signal   L0CFGNEGOTIATEDMAXP_indelay  :  std_logic_vector(2 downto 0);
	signal   L0CFGDISABLESCRAMBLE_indelay  :  std_ulogic;
	signal   L0CFGEXTENDEDSYNC_indelay  :  std_ulogic;
	signal   L0CFGLINKDISABLE_indelay  :  std_ulogic;
	signal   L0PORTNUMBER_indelay  :  std_logic_vector(7 downto 0);
	signal   L0SENDUNLOCKMESSAGE_indelay  :  std_ulogic;
	signal   L0ALLDOWNRXPORTSINL0S_indelay  :  std_ulogic;
	signal   L0UPSTREAMRXPORTINL0S_indelay  :  std_ulogic;
	signal   L0TRANSACTIONSPENDING_indelay  :  std_ulogic;
	signal   L0ALLDOWNPORTSINL1_indelay  :  std_ulogic;
	signal   L0FWDCORRERRIN_indelay  :  std_ulogic;
	signal   L0FWDFATALERRIN_indelay  :  std_ulogic;
	signal   L0FWDNONFATALERRIN_indelay  :  std_ulogic;
	signal   L0SETCOMPLETERABORTERROR_indelay  :  std_ulogic;
	signal   L0SETDETECTEDCORRERROR_indelay  :  std_ulogic;
	signal   L0SETDETECTEDFATALERROR_indelay  :  std_ulogic;
	signal   L0SETDETECTEDNONFATALERROR_indelay  :  std_ulogic;
	signal   L0SETLINKDETECTEDPARITYERROR_indelay  :  std_ulogic;
	signal   L0SETLINKMASTERDATAPARITY_indelay  :  std_ulogic;
	signal   L0SETLINKRECEIVEDMASTERABORT_indelay  :  std_ulogic;
	signal   L0SETLINKRECEIVEDTARGETABORT_indelay  :  std_ulogic;
	signal   L0SETLINKSYSTEMERROR_indelay  :  std_ulogic;
	signal   L0SETLINKSIGNALLEDTARGETABORT_indelay  :  std_ulogic;
	signal   L0SETUSERDETECTEDPARITYERROR_indelay  :  std_ulogic;
	signal   L0SETUSERMASTERDATAPARITY_indelay  :  std_ulogic;
	signal   L0SETUSERRECEIVEDMASTERABORT_indelay  :  std_ulogic;
	signal   L0SETUSERRECEIVEDTARGETABORT_indelay  :  std_ulogic;
	signal   L0SETUSERSYSTEMERROR_indelay  :  std_ulogic;
	signal   L0SETUSERSIGNALLEDTARGETABORT_indelay  :  std_ulogic;
	signal   L0SETCOMPLETIONTIMEOUTUNCORRERROR_indelay  :  std_ulogic;
	signal   L0SETCOMPLETIONTIMEOUTCORRERROR_indelay  :  std_ulogic;
	signal   L0SETUNEXPECTEDCOMPLETIONUNCORRERROR_indelay  :  std_ulogic;
	signal   L0SETUNEXPECTEDCOMPLETIONCORRERROR_indelay  :  std_ulogic;
	signal   L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR_indelay  :  std_ulogic;
	signal   L0SETUNSUPPORTEDREQUESTOTHERERROR_indelay  :  std_ulogic;
	signal   L0PACKETHEADERFROMUSER_indelay  :  std_logic_vector(127 downto 0);
	signal   L0LEGACYINTFUNCT0_indelay  :  std_ulogic;
	signal   L0FWDASSERTINTALEGACYINT_indelay  :  std_ulogic;
	signal   L0FWDASSERTINTBLEGACYINT_indelay  :  std_ulogic;
	signal   L0FWDASSERTINTCLEGACYINT_indelay  :  std_ulogic;
	signal   L0FWDASSERTINTDLEGACYINT_indelay  :  std_ulogic;
	signal   L0FWDDEASSERTINTALEGACYINT_indelay  :  std_ulogic;
	signal   L0FWDDEASSERTINTBLEGACYINT_indelay  :  std_ulogic;
	signal   L0FWDDEASSERTINTCLEGACYINT_indelay  :  std_ulogic;
	signal   L0FWDDEASSERTINTDLEGACYINT_indelay  :  std_ulogic;
	signal   L0MSIREQUEST0_indelay  :  std_logic_vector(3 downto 0);
	signal   L0ELECTROMECHANICALINTERLOCKENGAGED_indelay  :  std_ulogic;
	signal   L0MRLSENSORCLOSEDN_indelay  :  std_ulogic;
	signal   L0POWERFAULTDETECTED_indelay  :  std_ulogic;
	signal   L0PRESENCEDETECTSLOTEMPTYN_indelay  :  std_ulogic;
	signal   L0ATTENTIONBUTTONPRESSED_indelay  :  std_ulogic;
	signal   L0TXBEACON_indelay  :  std_ulogic;
	signal   L0WAKEN_indelay  :  std_ulogic;
	signal   L0PMEREQIN_indelay  :  std_ulogic;
	signal   L0ROOTTURNOFFREQ_indelay  :  std_ulogic;
	signal   L0TXCFGPM_indelay  :  std_ulogic;
	signal   L0TXCFGPMTYPE_indelay  :  std_logic_vector(2 downto 0);
	signal   L0PWRNEWSTATEREQ_indelay  :  std_ulogic;
	signal   L0PWRNEXTLINKSTATE_indelay  :  std_logic_vector(1 downto 0);
	signal   L0CFGL0SENTRYSUP_indelay  :  std_ulogic;
	signal   L0CFGL0SENTRYENABLE_indelay  :  std_ulogic;
	signal   L0CFGL0SEXITLAT_indelay  :  std_logic_vector(2 downto 0);
	signal   L0TXTLTLPDATA_indelay  :  std_logic_vector(63 downto 0);
	signal   L0TXTLTLPEND_indelay  :  std_logic_vector(1 downto 0);
	signal   L0TXTLTLPENABLE_indelay  :  std_logic_vector(1 downto 0);
	signal   L0TXTLTLPEDB_indelay  :  std_ulogic;
	signal   L0TXTLTLPREQ_indelay  :  std_ulogic;
	signal   L0TXTLTLPREQEND_indelay  :  std_ulogic;
	signal   L0TXTLTLPWIDTH_indelay  :  std_ulogic;
	signal   L0TXTLTLPLATENCY_indelay  :  std_logic_vector(3 downto 0);
	signal   L0TLASFCCREDSTARVATION_indelay  :  std_ulogic;
	signal   L0TXTLSBFCDATA_indelay  :  std_logic_vector(18 downto 0);
	signal   L0TXTLSBFCUPDATE_indelay  :  std_ulogic;
	signal   L0TXTLFCNPOSTBYPCRED_indelay  :  std_logic_vector(191 downto 0);
	signal   L0TXTLFCNPOSTBYPUPDATE_indelay  :  std_logic_vector(15 downto 0);
	signal   L0TXTLFCPOSTORDCRED_indelay  :  std_logic_vector(159 downto 0);
	signal   L0TXTLFCPOSTORDUPDATE_indelay  :  std_logic_vector(15 downto 0);
	signal   L0TXTLFCCMPLMCCRED_indelay  :  std_logic_vector(159 downto 0);
	signal   L0TXTLFCCMPLMCUPDATE_indelay  :  std_logic_vector(15 downto 0);
	signal   L0RXTLTLPNONINITIALIZEDVC_indelay  :  std_logic_vector(7 downto 0);

begin


	BUSMASTERENABLE_out <= BUSMASTERENABLE_outdelay after OUT_DELAY;
	CRMDOHOTRESETN_out <= CRMDOHOTRESETN_outdelay after OUT_DELAY;
	CRMPWRSOFTRESETN_out <= CRMPWRSOFTRESETN_outdelay after OUT_DELAY;
	CRMRXHOTRESETN_out <= CRMRXHOTRESETN_outdelay after OUT_DELAY;
	DLLTXPMDLLPOUTSTANDING_out <= DLLTXPMDLLPOUTSTANDING_outdelay after OUT_DELAY;
	INTERRUPTDISABLE_out <= INTERRUPTDISABLE_outdelay after OUT_DELAY;
	IOSPACEENABLE_out <= IOSPACEENABLE_outdelay after OUT_DELAY;
	L0ASAUTONOMOUSINITCOMPLETED_out <= L0ASAUTONOMOUSINITCOMPLETED_outdelay after OUT_DELAY;
	L0ATTENTIONINDICATORCONTROL_out <= L0ATTENTIONINDICATORCONTROL_outdelay after OUT_DELAY;
	L0CFGLOOPBACKACK_out <= L0CFGLOOPBACKACK_outdelay after OUT_DELAY;
	L0COMPLETERID_out <= L0COMPLETERID_outdelay after OUT_DELAY;
	L0CORRERRMSGRCVD_out <= L0CORRERRMSGRCVD_outdelay after OUT_DELAY;
	L0DLLASRXSTATE_out <= L0DLLASRXSTATE_outdelay after OUT_DELAY;
	L0DLLASTXSTATE_out <= L0DLLASTXSTATE_outdelay after OUT_DELAY;
	L0DLLERRORVECTOR_out <= L0DLLERRORVECTOR_outdelay after OUT_DELAY;
	L0DLLRXACKOUTSTANDING_out <= L0DLLRXACKOUTSTANDING_outdelay after OUT_DELAY;
	L0DLLTXNONFCOUTSTANDING_out <= L0DLLTXNONFCOUTSTANDING_outdelay after OUT_DELAY;
	L0DLLTXOUTSTANDING_out <= L0DLLTXOUTSTANDING_outdelay after OUT_DELAY;
	L0DLLVCSTATUS_out <= L0DLLVCSTATUS_outdelay after OUT_DELAY;
	L0DLUPDOWN_out <= L0DLUPDOWN_outdelay after OUT_DELAY;
	L0ERRMSGREQID_out <= L0ERRMSGREQID_outdelay after OUT_DELAY;
	L0FATALERRMSGRCVD_out <= L0FATALERRMSGRCVD_outdelay after OUT_DELAY;
	L0FIRSTCFGWRITEOCCURRED_out <= L0FIRSTCFGWRITEOCCURRED_outdelay after OUT_DELAY;
	L0FWDCORRERROUT_out <= L0FWDCORRERROUT_outdelay after OUT_DELAY;
	L0FWDFATALERROUT_out <= L0FWDFATALERROUT_outdelay after OUT_DELAY;
	L0FWDNONFATALERROUT_out <= L0FWDNONFATALERROUT_outdelay after OUT_DELAY;
	L0LTSSMSTATE_out <= L0LTSSMSTATE_outdelay after OUT_DELAY;
	L0MACENTEREDL0_out <= L0MACENTEREDL0_outdelay after OUT_DELAY;
	L0MACLINKTRAINING_out <= L0MACLINKTRAINING_outdelay after OUT_DELAY;
	L0MACLINKUP_out <= L0MACLINKUP_outdelay after OUT_DELAY;
	L0MACNEGOTIATEDLINKWIDTH_out <= L0MACNEGOTIATEDLINKWIDTH_outdelay after OUT_DELAY;
	L0MACNEWSTATEACK_out <= L0MACNEWSTATEACK_outdelay after OUT_DELAY;
	L0MACRXL0SSTATE_out <= L0MACRXL0SSTATE_outdelay after OUT_DELAY;
	L0MACUPSTREAMDOWNSTREAM_out <= L0MACUPSTREAMDOWNSTREAM_outdelay after OUT_DELAY;
	L0MCFOUND_out <= L0MCFOUND_outdelay after OUT_DELAY;
	L0MSIENABLE0_out <= L0MSIENABLE0_outdelay after OUT_DELAY;
	L0MULTIMSGEN0_out <= L0MULTIMSGEN0_outdelay after OUT_DELAY;
	L0NONFATALERRMSGRCVD_out <= L0NONFATALERRMSGRCVD_outdelay after OUT_DELAY;
	L0PMEACK_out <= L0PMEACK_outdelay after OUT_DELAY;
	L0PMEEN_out <= L0PMEEN_outdelay after OUT_DELAY;
	L0PMEREQOUT_out <= L0PMEREQOUT_outdelay after OUT_DELAY;
	L0POWERCONTROLLERCONTROL_out <= L0POWERCONTROLLERCONTROL_outdelay after OUT_DELAY;
	L0POWERINDICATORCONTROL_out <= L0POWERINDICATORCONTROL_outdelay after OUT_DELAY;
	L0PWRINHIBITTRANSFERS_out <= L0PWRINHIBITTRANSFERS_outdelay after OUT_DELAY;
	L0PWRL1STATE_out <= L0PWRL1STATE_outdelay after OUT_DELAY;
	L0PWRL23READYDEVICE_out <= L0PWRL23READYDEVICE_outdelay after OUT_DELAY;
	L0PWRL23READYSTATE_out <= L0PWRL23READYSTATE_outdelay after OUT_DELAY;
	L0PWRSTATE0_out <= L0PWRSTATE0_outdelay after OUT_DELAY;
	L0PWRTURNOFFREQ_out <= L0PWRTURNOFFREQ_outdelay after OUT_DELAY;
	L0PWRTXL0SSTATE_out <= L0PWRTXL0SSTATE_outdelay after OUT_DELAY;
	L0RECEIVEDASSERTINTALEGACYINT_out <= L0RECEIVEDASSERTINTALEGACYINT_outdelay after OUT_DELAY;
	L0RECEIVEDASSERTINTBLEGACYINT_out <= L0RECEIVEDASSERTINTBLEGACYINT_outdelay after OUT_DELAY;
	L0RECEIVEDASSERTINTCLEGACYINT_out <= L0RECEIVEDASSERTINTCLEGACYINT_outdelay after OUT_DELAY;
	L0RECEIVEDASSERTINTDLEGACYINT_out <= L0RECEIVEDASSERTINTDLEGACYINT_outdelay after OUT_DELAY;
	L0RECEIVEDDEASSERTINTALEGACYINT_out <= L0RECEIVEDDEASSERTINTALEGACYINT_outdelay after OUT_DELAY;
	L0RECEIVEDDEASSERTINTBLEGACYINT_out <= L0RECEIVEDDEASSERTINTBLEGACYINT_outdelay after OUT_DELAY;
	L0RECEIVEDDEASSERTINTCLEGACYINT_out <= L0RECEIVEDDEASSERTINTCLEGACYINT_outdelay after OUT_DELAY;
	L0RECEIVEDDEASSERTINTDLEGACYINT_out <= L0RECEIVEDDEASSERTINTDLEGACYINT_outdelay after OUT_DELAY;
	L0RXBEACON_out <= L0RXBEACON_outdelay after OUT_DELAY;
	L0RXDLLFCCMPLMCCRED_out <= L0RXDLLFCCMPLMCCRED_outdelay after OUT_DELAY;
	L0RXDLLFCCMPLMCUPDATE_out <= L0RXDLLFCCMPLMCUPDATE_outdelay after OUT_DELAY;
	L0RXDLLFCNPOSTBYPCRED_out <= L0RXDLLFCNPOSTBYPCRED_outdelay after OUT_DELAY;
	L0RXDLLFCNPOSTBYPUPDATE_out <= L0RXDLLFCNPOSTBYPUPDATE_outdelay after OUT_DELAY;
	L0RXDLLFCPOSTORDCRED_out <= L0RXDLLFCPOSTORDCRED_outdelay after OUT_DELAY;
	L0RXDLLFCPOSTORDUPDATE_out <= L0RXDLLFCPOSTORDUPDATE_outdelay after OUT_DELAY;
	L0RXDLLPMTYPE_out <= L0RXDLLPMTYPE_outdelay after OUT_DELAY;
	L0RXDLLPM_out <= L0RXDLLPM_outdelay after OUT_DELAY;
	L0RXDLLSBFCDATA_out <= L0RXDLLSBFCDATA_outdelay after OUT_DELAY;
	L0RXDLLSBFCUPDATE_out <= L0RXDLLSBFCUPDATE_outdelay after OUT_DELAY;
	L0RXDLLTLPECRCOK_out <= L0RXDLLTLPECRCOK_outdelay after OUT_DELAY;
	L0RXDLLTLPEND_out <= L0RXDLLTLPEND_outdelay after OUT_DELAY;
	L0RXMACLINKERROR_out <= L0RXMACLINKERROR_outdelay after OUT_DELAY;
	L0STATSCFGOTHERRECEIVED_out <= L0STATSCFGOTHERRECEIVED_outdelay after OUT_DELAY;
	L0STATSCFGOTHERTRANSMITTED_out <= L0STATSCFGOTHERTRANSMITTED_outdelay after OUT_DELAY;
	L0STATSCFGRECEIVED_out <= L0STATSCFGRECEIVED_outdelay after OUT_DELAY;
	L0STATSCFGTRANSMITTED_out <= L0STATSCFGTRANSMITTED_outdelay after OUT_DELAY;
	L0STATSDLLPRECEIVED_out <= L0STATSDLLPRECEIVED_outdelay after OUT_DELAY;
	L0STATSDLLPTRANSMITTED_out <= L0STATSDLLPTRANSMITTED_outdelay after OUT_DELAY;
	L0STATSOSRECEIVED_out <= L0STATSOSRECEIVED_outdelay after OUT_DELAY;
	L0STATSOSTRANSMITTED_out <= L0STATSOSTRANSMITTED_outdelay after OUT_DELAY;
	L0STATSTLPRECEIVED_out <= L0STATSTLPRECEIVED_outdelay after OUT_DELAY;
	L0STATSTLPTRANSMITTED_out <= L0STATSTLPTRANSMITTED_outdelay after OUT_DELAY;
	L0TOGGLEELECTROMECHANICALINTERLOCK_out <= L0TOGGLEELECTROMECHANICALINTERLOCK_outdelay after OUT_DELAY;
	L0TRANSFORMEDVC_out <= L0TRANSFORMEDVC_outdelay after OUT_DELAY;
	L0TXDLLFCCMPLMCUPDATED_out <= L0TXDLLFCCMPLMCUPDATED_outdelay after OUT_DELAY;
	L0TXDLLFCNPOSTBYPUPDATED_out <= L0TXDLLFCNPOSTBYPUPDATED_outdelay after OUT_DELAY;
	L0TXDLLFCPOSTORDUPDATED_out <= L0TXDLLFCPOSTORDUPDATED_outdelay after OUT_DELAY;
	L0TXDLLPMUPDATED_out <= L0TXDLLPMUPDATED_outdelay after OUT_DELAY;
	L0TXDLLSBFCUPDATED_out <= L0TXDLLSBFCUPDATED_outdelay after OUT_DELAY;
	L0UCBYPFOUND_out <= L0UCBYPFOUND_outdelay after OUT_DELAY;
	L0UCORDFOUND_out <= L0UCORDFOUND_outdelay after OUT_DELAY;
	L0UNLOCKRECEIVED_out <= L0UNLOCKRECEIVED_outdelay after OUT_DELAY;
	LLKRX4DWHEADERN_out <= LLKRX4DWHEADERN_outdelay after OUT_DELAY;
	LLKRXCHCOMPLETIONAVAILABLEN_out <= LLKRXCHCOMPLETIONAVAILABLEN_outdelay after OUT_DELAY;
	LLKRXCHCOMPLETIONPARTIALN_out <= LLKRXCHCOMPLETIONPARTIALN_outdelay after OUT_DELAY;
	LLKRXCHCONFIGAVAILABLEN_out <= LLKRXCHCONFIGAVAILABLEN_outdelay after OUT_DELAY;
	LLKRXCHCONFIGPARTIALN_out <= LLKRXCHCONFIGPARTIALN_outdelay after OUT_DELAY;
	LLKRXCHNONPOSTEDAVAILABLEN_out <= LLKRXCHNONPOSTEDAVAILABLEN_outdelay after OUT_DELAY;
	LLKRXCHNONPOSTEDPARTIALN_out <= LLKRXCHNONPOSTEDPARTIALN_outdelay after OUT_DELAY;
	LLKRXCHPOSTEDAVAILABLEN_out <= LLKRXCHPOSTEDAVAILABLEN_outdelay after OUT_DELAY;
	LLKRXCHPOSTEDPARTIALN_out <= LLKRXCHPOSTEDPARTIALN_outdelay after OUT_DELAY;
	LLKRXDATA_out <= LLKRXDATA_outdelay after OUT_DELAY;
	LLKRXECRCBADN_out <= LLKRXECRCBADN_outdelay after OUT_DELAY;
	LLKRXEOFN_out <= LLKRXEOFN_outdelay after OUT_DELAY;
	LLKRXEOPN_out <= LLKRXEOPN_outdelay after OUT_DELAY;
	LLKRXPREFERREDTYPE_out <= LLKRXPREFERREDTYPE_outdelay after OUT_DELAY;
	LLKRXSOFN_out <= LLKRXSOFN_outdelay after OUT_DELAY;
	LLKRXSOPN_out <= LLKRXSOPN_outdelay after OUT_DELAY;
	LLKRXSRCDSCN_out <= LLKRXSRCDSCN_outdelay after OUT_DELAY;
	LLKRXSRCLASTREQN_out <= LLKRXSRCLASTREQN_outdelay after OUT_DELAY;
	LLKRXSRCRDYN_out <= LLKRXSRCRDYN_outdelay after OUT_DELAY;
	LLKRXVALIDN_out <= LLKRXVALIDN_outdelay after OUT_DELAY;
	LLKTCSTATUS_out <= LLKTCSTATUS_outdelay after OUT_DELAY;
	LLKTXCHANSPACE_out <= LLKTXCHANSPACE_outdelay after OUT_DELAY;
	LLKTXCHCOMPLETIONREADYN_out <= LLKTXCHCOMPLETIONREADYN_outdelay after OUT_DELAY;
	LLKTXCHNONPOSTEDREADYN_out <= LLKTXCHNONPOSTEDREADYN_outdelay after OUT_DELAY;
	LLKTXCHPOSTEDREADYN_out <= LLKTXCHPOSTEDREADYN_outdelay after OUT_DELAY;
	LLKTXCONFIGREADYN_out <= LLKTXCONFIGREADYN_outdelay after OUT_DELAY;
	LLKTXDSTRDYN_out <= LLKTXDSTRDYN_outdelay after OUT_DELAY;
	MAXPAYLOADSIZE_out <= MAXPAYLOADSIZE_outdelay after OUT_DELAY;
	MAXREADREQUESTSIZE_out <= MAXREADREQUESTSIZE_outdelay after OUT_DELAY;
	MEMSPACEENABLE_out <= MEMSPACEENABLE_outdelay after OUT_DELAY;
	MGMTPSO_out <= MGMTPSO_outdelay after OUT_DELAY;
	MGMTRDATA_out <= MGMTRDATA_outdelay after OUT_DELAY;
	MGMTSTATSCREDIT_out <= MGMTSTATSCREDIT_outdelay after OUT_DELAY;
	MIMDLLBRADD_out <= MIMDLLBRADD_outdelay after OUT_DELAY;
	MIMDLLBREN_out <= MIMDLLBREN_outdelay after OUT_DELAY;
	MIMDLLBWADD_out <= MIMDLLBWADD_outdelay after OUT_DELAY;
	MIMDLLBWDATA_out <= MIMDLLBWDATA_outdelay after OUT_DELAY;
	MIMDLLBWEN_out <= MIMDLLBWEN_outdelay after OUT_DELAY;
	MIMRXBRADD_out <= MIMRXBRADD_outdelay after OUT_DELAY;
	MIMRXBREN_out <= MIMRXBREN_outdelay after OUT_DELAY;
	MIMRXBWADD_out <= MIMRXBWADD_outdelay after OUT_DELAY;
	MIMRXBWDATA_out <= MIMRXBWDATA_outdelay after OUT_DELAY;
	MIMRXBWEN_out <= MIMRXBWEN_outdelay after OUT_DELAY;
	MIMTXBRADD_out <= MIMTXBRADD_outdelay after OUT_DELAY;
	MIMTXBREN_out <= MIMTXBREN_outdelay after OUT_DELAY;
	MIMTXBWADD_out <= MIMTXBWADD_outdelay after OUT_DELAY;
	MIMTXBWDATA_out <= MIMTXBWDATA_outdelay after OUT_DELAY;
	MIMTXBWEN_out <= MIMTXBWEN_outdelay after OUT_DELAY;
	PARITYERRORRESPONSE_out <= PARITYERRORRESPONSE_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL0_out <= PIPEDESKEWLANESL0_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL1_out <= PIPEDESKEWLANESL1_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL2_out <= PIPEDESKEWLANESL2_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL3_out <= PIPEDESKEWLANESL3_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL4_out <= PIPEDESKEWLANESL4_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL5_out <= PIPEDESKEWLANESL5_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL6_out <= PIPEDESKEWLANESL6_outdelay after OUT_DELAY;
	PIPEDESKEWLANESL7_out <= PIPEDESKEWLANESL7_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL0_out <= PIPEPOWERDOWNL0_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL1_out <= PIPEPOWERDOWNL1_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL2_out <= PIPEPOWERDOWNL2_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL3_out <= PIPEPOWERDOWNL3_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL4_out <= PIPEPOWERDOWNL4_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL5_out <= PIPEPOWERDOWNL5_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL6_out <= PIPEPOWERDOWNL6_outdelay after OUT_DELAY;
	PIPEPOWERDOWNL7_out <= PIPEPOWERDOWNL7_outdelay after OUT_DELAY;
	PIPERESETL0_out <= PIPERESETL0_outdelay after OUT_DELAY;
	PIPERESETL1_out <= PIPERESETL1_outdelay after OUT_DELAY;
	PIPERESETL2_out <= PIPERESETL2_outdelay after OUT_DELAY;
	PIPERESETL3_out <= PIPERESETL3_outdelay after OUT_DELAY;
	PIPERESETL4_out <= PIPERESETL4_outdelay after OUT_DELAY;
	PIPERESETL5_out <= PIPERESETL5_outdelay after OUT_DELAY;
	PIPERESETL6_out <= PIPERESETL6_outdelay after OUT_DELAY;
	PIPERESETL7_out <= PIPERESETL7_outdelay after OUT_DELAY;
	PIPERXPOLARITYL0_out <= PIPERXPOLARITYL0_outdelay after OUT_DELAY;
	PIPERXPOLARITYL1_out <= PIPERXPOLARITYL1_outdelay after OUT_DELAY;
	PIPERXPOLARITYL2_out <= PIPERXPOLARITYL2_outdelay after OUT_DELAY;
	PIPERXPOLARITYL3_out <= PIPERXPOLARITYL3_outdelay after OUT_DELAY;
	PIPERXPOLARITYL4_out <= PIPERXPOLARITYL4_outdelay after OUT_DELAY;
	PIPERXPOLARITYL5_out <= PIPERXPOLARITYL5_outdelay after OUT_DELAY;
	PIPERXPOLARITYL6_out <= PIPERXPOLARITYL6_outdelay after OUT_DELAY;
	PIPERXPOLARITYL7_out <= PIPERXPOLARITYL7_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL0_out <= PIPETXCOMPLIANCEL0_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL1_out <= PIPETXCOMPLIANCEL1_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL2_out <= PIPETXCOMPLIANCEL2_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL3_out <= PIPETXCOMPLIANCEL3_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL4_out <= PIPETXCOMPLIANCEL4_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL5_out <= PIPETXCOMPLIANCEL5_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL6_out <= PIPETXCOMPLIANCEL6_outdelay after OUT_DELAY;
	PIPETXCOMPLIANCEL7_out <= PIPETXCOMPLIANCEL7_outdelay after OUT_DELAY;
	PIPETXDATAKL0_out <= PIPETXDATAKL0_outdelay after OUT_DELAY;
	PIPETXDATAKL1_out <= PIPETXDATAKL1_outdelay after OUT_DELAY;
	PIPETXDATAKL2_out <= PIPETXDATAKL2_outdelay after OUT_DELAY;
	PIPETXDATAKL3_out <= PIPETXDATAKL3_outdelay after OUT_DELAY;
	PIPETXDATAKL4_out <= PIPETXDATAKL4_outdelay after OUT_DELAY;
	PIPETXDATAKL5_out <= PIPETXDATAKL5_outdelay after OUT_DELAY;
	PIPETXDATAKL6_out <= PIPETXDATAKL6_outdelay after OUT_DELAY;
	PIPETXDATAKL7_out <= PIPETXDATAKL7_outdelay after OUT_DELAY;
	PIPETXDATAL0_out <= PIPETXDATAL0_outdelay after OUT_DELAY;
	PIPETXDATAL1_out <= PIPETXDATAL1_outdelay after OUT_DELAY;
	PIPETXDATAL2_out <= PIPETXDATAL2_outdelay after OUT_DELAY;
	PIPETXDATAL3_out <= PIPETXDATAL3_outdelay after OUT_DELAY;
	PIPETXDATAL4_out <= PIPETXDATAL4_outdelay after OUT_DELAY;
	PIPETXDATAL5_out <= PIPETXDATAL5_outdelay after OUT_DELAY;
	PIPETXDATAL6_out <= PIPETXDATAL6_outdelay after OUT_DELAY;
	PIPETXDATAL7_out <= PIPETXDATAL7_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL0_out <= PIPETXDETECTRXLOOPBACKL0_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL1_out <= PIPETXDETECTRXLOOPBACKL1_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL2_out <= PIPETXDETECTRXLOOPBACKL2_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL3_out <= PIPETXDETECTRXLOOPBACKL3_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL4_out <= PIPETXDETECTRXLOOPBACKL4_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL5_out <= PIPETXDETECTRXLOOPBACKL5_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL6_out <= PIPETXDETECTRXLOOPBACKL6_outdelay after OUT_DELAY;
	PIPETXDETECTRXLOOPBACKL7_out <= PIPETXDETECTRXLOOPBACKL7_outdelay after OUT_DELAY;
	PIPETXELECIDLEL0_out <= PIPETXELECIDLEL0_outdelay after OUT_DELAY;
	PIPETXELECIDLEL1_out <= PIPETXELECIDLEL1_outdelay after OUT_DELAY;
	PIPETXELECIDLEL2_out <= PIPETXELECIDLEL2_outdelay after OUT_DELAY;
	PIPETXELECIDLEL3_out <= PIPETXELECIDLEL3_outdelay after OUT_DELAY;
	PIPETXELECIDLEL4_out <= PIPETXELECIDLEL4_outdelay after OUT_DELAY;
	PIPETXELECIDLEL5_out <= PIPETXELECIDLEL5_outdelay after OUT_DELAY;
	PIPETXELECIDLEL6_out <= PIPETXELECIDLEL6_outdelay after OUT_DELAY;
	PIPETXELECIDLEL7_out <= PIPETXELECIDLEL7_outdelay after OUT_DELAY;
	SERRENABLE_out <= SERRENABLE_outdelay after OUT_DELAY;
	URREPORTINGENABLE_out <= URREPORTINGENABLE_outdelay after OUT_DELAY;

	CRMCORECLKDLO_ipd <= CRMCORECLKDLO after CLK_DELAY;
	CRMCORECLKRXO_ipd <= CRMCORECLKRXO after CLK_DELAY;
	CRMCORECLKTXO_ipd <= CRMCORECLKTXO after CLK_DELAY;
	CRMCORECLK_ipd <= CRMCORECLK after CLK_DELAY;
	CRMUSERCLKRXO_ipd <= CRMUSERCLKRXO after CLK_DELAY;
	CRMUSERCLKTXO_ipd <= CRMUSERCLKTXO after CLK_DELAY;
	CRMUSERCLK_ipd <= CRMUSERCLK after CLK_DELAY;

	AUXPOWER_ipd <= AUXPOWER after CLK_DELAY;
	CFGNEGOTIATEDLINKWIDTH_ipd <= CFGNEGOTIATEDLINKWIDTH after CLK_DELAY;
	COMPLIANCEAVOID_ipd <= COMPLIANCEAVOID after CLK_DELAY;
	CRMCFGBRIDGEHOTRESET_ipd <= CRMCFGBRIDGEHOTRESET after CLK_DELAY;
	CRMLINKRSTN_ipd <= CRMLINKRSTN after CLK_DELAY;
	CRMMACRSTN_ipd <= CRMMACRSTN after CLK_DELAY;
	CRMMGMTRSTN_ipd <= CRMMGMTRSTN after CLK_DELAY;
	CRMNVRSTN_ipd <= CRMNVRSTN after CLK_DELAY;
	CRMTXHOTRESETN_ipd <= CRMTXHOTRESETN after CLK_DELAY;
	CRMURSTN_ipd <= CRMURSTN after CLK_DELAY;
	CRMUSERCFGRSTN_ipd <= CRMUSERCFGRSTN after CLK_DELAY;
	CROSSLINKSEED_ipd <= CROSSLINKSEED after CLK_DELAY;
	L0ACKNAKTIMERADJUSTMENT_ipd <= L0ACKNAKTIMERADJUSTMENT after CLK_DELAY;
	L0ALLDOWNPORTSINL1_ipd <= L0ALLDOWNPORTSINL1 after CLK_DELAY;
	L0ALLDOWNRXPORTSINL0S_ipd <= L0ALLDOWNRXPORTSINL0S after CLK_DELAY;
	L0ASE_ipd <= L0ASE after CLK_DELAY;
	L0ASPORTCOUNT_ipd <= L0ASPORTCOUNT after CLK_DELAY;
	L0ASTURNPOOLBITSCONSUMED_ipd <= L0ASTURNPOOLBITSCONSUMED after CLK_DELAY;
	L0ATTENTIONBUTTONPRESSED_ipd <= L0ATTENTIONBUTTONPRESSED after CLK_DELAY;
	L0CFGASSPANTREEOWNEDSTATE_ipd <= L0CFGASSPANTREEOWNEDSTATE after CLK_DELAY;
	L0CFGASSTATECHANGECMD_ipd <= L0CFGASSTATECHANGECMD after CLK_DELAY;
	L0CFGDISABLESCRAMBLE_ipd <= L0CFGDISABLESCRAMBLE after CLK_DELAY;
	L0CFGEXTENDEDSYNC_ipd <= L0CFGEXTENDEDSYNC after CLK_DELAY;
	L0CFGL0SENTRYENABLE_ipd <= L0CFGL0SENTRYENABLE after CLK_DELAY;
	L0CFGL0SENTRYSUP_ipd <= L0CFGL0SENTRYSUP after CLK_DELAY;
	L0CFGL0SEXITLAT_ipd <= L0CFGL0SEXITLAT after CLK_DELAY;
	L0CFGLINKDISABLE_ipd <= L0CFGLINKDISABLE after CLK_DELAY;
	L0CFGLOOPBACKMASTER_ipd <= L0CFGLOOPBACKMASTER after CLK_DELAY;
	L0CFGNEGOTIATEDMAXP_ipd <= L0CFGNEGOTIATEDMAXP after CLK_DELAY;
	L0CFGVCENABLE_ipd <= L0CFGVCENABLE after CLK_DELAY;
	L0CFGVCID_ipd <= L0CFGVCID after CLK_DELAY;
	L0DLLHOLDLINKUP_ipd <= L0DLLHOLDLINKUP after CLK_DELAY;
	L0ELECTROMECHANICALINTERLOCKENGAGED_ipd <= L0ELECTROMECHANICALINTERLOCKENGAGED after CLK_DELAY;
	L0FWDASSERTINTALEGACYINT_ipd <= L0FWDASSERTINTALEGACYINT after CLK_DELAY;
	L0FWDASSERTINTBLEGACYINT_ipd <= L0FWDASSERTINTBLEGACYINT after CLK_DELAY;
	L0FWDASSERTINTCLEGACYINT_ipd <= L0FWDASSERTINTCLEGACYINT after CLK_DELAY;
	L0FWDASSERTINTDLEGACYINT_ipd <= L0FWDASSERTINTDLEGACYINT after CLK_DELAY;
	L0FWDCORRERRIN_ipd <= L0FWDCORRERRIN after CLK_DELAY;
	L0FWDDEASSERTINTALEGACYINT_ipd <= L0FWDDEASSERTINTALEGACYINT after CLK_DELAY;
	L0FWDDEASSERTINTBLEGACYINT_ipd <= L0FWDDEASSERTINTBLEGACYINT after CLK_DELAY;
	L0FWDDEASSERTINTCLEGACYINT_ipd <= L0FWDDEASSERTINTCLEGACYINT after CLK_DELAY;
	L0FWDDEASSERTINTDLEGACYINT_ipd <= L0FWDDEASSERTINTDLEGACYINT after CLK_DELAY;
	L0FWDFATALERRIN_ipd <= L0FWDFATALERRIN after CLK_DELAY;
	L0FWDNONFATALERRIN_ipd <= L0FWDNONFATALERRIN after CLK_DELAY;
	L0LEGACYINTFUNCT0_ipd <= L0LEGACYINTFUNCT0 after CLK_DELAY;
	L0MRLSENSORCLOSEDN_ipd <= L0MRLSENSORCLOSEDN after CLK_DELAY;
	L0MSIREQUEST0_ipd <= L0MSIREQUEST0 after CLK_DELAY;
	L0PACKETHEADERFROMUSER_ipd <= L0PACKETHEADERFROMUSER after CLK_DELAY;
	L0PMEREQIN_ipd <= L0PMEREQIN after CLK_DELAY;
	L0PORTNUMBER_ipd <= L0PORTNUMBER after CLK_DELAY;
	L0POWERFAULTDETECTED_ipd <= L0POWERFAULTDETECTED after CLK_DELAY;
	L0PRESENCEDETECTSLOTEMPTYN_ipd <= L0PRESENCEDETECTSLOTEMPTYN after CLK_DELAY;
	L0PWRNEWSTATEREQ_ipd <= L0PWRNEWSTATEREQ after CLK_DELAY;
	L0PWRNEXTLINKSTATE_ipd <= L0PWRNEXTLINKSTATE after CLK_DELAY;
	L0REPLAYTIMERADJUSTMENT_ipd <= L0REPLAYTIMERADJUSTMENT after CLK_DELAY;
	L0ROOTTURNOFFREQ_ipd <= L0ROOTTURNOFFREQ after CLK_DELAY;
	L0RXTLTLPNONINITIALIZEDVC_ipd <= L0RXTLTLPNONINITIALIZEDVC after CLK_DELAY;
	L0SENDUNLOCKMESSAGE_ipd <= L0SENDUNLOCKMESSAGE after CLK_DELAY;
	L0SETCOMPLETERABORTERROR_ipd <= L0SETCOMPLETERABORTERROR after CLK_DELAY;
	L0SETCOMPLETIONTIMEOUTCORRERROR_ipd <= L0SETCOMPLETIONTIMEOUTCORRERROR after CLK_DELAY;
	L0SETCOMPLETIONTIMEOUTUNCORRERROR_ipd <= L0SETCOMPLETIONTIMEOUTUNCORRERROR after CLK_DELAY;
	L0SETDETECTEDCORRERROR_ipd <= L0SETDETECTEDCORRERROR after CLK_DELAY;
	L0SETDETECTEDFATALERROR_ipd <= L0SETDETECTEDFATALERROR after CLK_DELAY;
	L0SETDETECTEDNONFATALERROR_ipd <= L0SETDETECTEDNONFATALERROR after CLK_DELAY;
	L0SETLINKDETECTEDPARITYERROR_ipd <= L0SETLINKDETECTEDPARITYERROR after CLK_DELAY;
	L0SETLINKMASTERDATAPARITY_ipd <= L0SETLINKMASTERDATAPARITY after CLK_DELAY;
	L0SETLINKRECEIVEDMASTERABORT_ipd <= L0SETLINKRECEIVEDMASTERABORT after CLK_DELAY;
	L0SETLINKRECEIVEDTARGETABORT_ipd <= L0SETLINKRECEIVEDTARGETABORT after CLK_DELAY;
	L0SETLINKSIGNALLEDTARGETABORT_ipd <= L0SETLINKSIGNALLEDTARGETABORT after CLK_DELAY;
	L0SETLINKSYSTEMERROR_ipd <= L0SETLINKSYSTEMERROR after CLK_DELAY;
	L0SETUNEXPECTEDCOMPLETIONCORRERROR_ipd <= L0SETUNEXPECTEDCOMPLETIONCORRERROR after CLK_DELAY;
	L0SETUNEXPECTEDCOMPLETIONUNCORRERROR_ipd <= L0SETUNEXPECTEDCOMPLETIONUNCORRERROR after CLK_DELAY;
	L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR_ipd <= L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR after CLK_DELAY;
	L0SETUNSUPPORTEDREQUESTOTHERERROR_ipd <= L0SETUNSUPPORTEDREQUESTOTHERERROR after CLK_DELAY;
	L0SETUSERDETECTEDPARITYERROR_ipd <= L0SETUSERDETECTEDPARITYERROR after CLK_DELAY;
	L0SETUSERMASTERDATAPARITY_ipd <= L0SETUSERMASTERDATAPARITY after CLK_DELAY;
	L0SETUSERRECEIVEDMASTERABORT_ipd <= L0SETUSERRECEIVEDMASTERABORT after CLK_DELAY;
	L0SETUSERRECEIVEDTARGETABORT_ipd <= L0SETUSERRECEIVEDTARGETABORT after CLK_DELAY;
	L0SETUSERSIGNALLEDTARGETABORT_ipd <= L0SETUSERSIGNALLEDTARGETABORT after CLK_DELAY;
	L0SETUSERSYSTEMERROR_ipd <= L0SETUSERSYSTEMERROR after CLK_DELAY;
	L0TLASFCCREDSTARVATION_ipd <= L0TLASFCCREDSTARVATION after CLK_DELAY;
	L0TLLINKRETRAIN_ipd <= L0TLLINKRETRAIN after CLK_DELAY;
	L0TRANSACTIONSPENDING_ipd <= L0TRANSACTIONSPENDING after CLK_DELAY;
	L0TXBEACON_ipd <= L0TXBEACON after CLK_DELAY;
	L0TXCFGPMTYPE_ipd <= L0TXCFGPMTYPE after CLK_DELAY;
	L0TXCFGPM_ipd <= L0TXCFGPM after CLK_DELAY;
	L0TXTLFCCMPLMCCRED_ipd <= L0TXTLFCCMPLMCCRED after CLK_DELAY;
	L0TXTLFCCMPLMCUPDATE_ipd <= L0TXTLFCCMPLMCUPDATE after CLK_DELAY;
	L0TXTLFCNPOSTBYPCRED_ipd <= L0TXTLFCNPOSTBYPCRED after CLK_DELAY;
	L0TXTLFCNPOSTBYPUPDATE_ipd <= L0TXTLFCNPOSTBYPUPDATE after CLK_DELAY;
	L0TXTLFCPOSTORDCRED_ipd <= L0TXTLFCPOSTORDCRED after CLK_DELAY;
	L0TXTLFCPOSTORDUPDATE_ipd <= L0TXTLFCPOSTORDUPDATE after CLK_DELAY;
	L0TXTLSBFCDATA_ipd <= L0TXTLSBFCDATA after CLK_DELAY;
	L0TXTLSBFCUPDATE_ipd <= L0TXTLSBFCUPDATE after CLK_DELAY;
	L0TXTLTLPDATA_ipd <= L0TXTLTLPDATA after CLK_DELAY;
	L0TXTLTLPEDB_ipd <= L0TXTLTLPEDB after CLK_DELAY;
	L0TXTLTLPENABLE_ipd <= L0TXTLTLPENABLE after CLK_DELAY;
	L0TXTLTLPEND_ipd <= L0TXTLTLPEND after CLK_DELAY;
	L0TXTLTLPLATENCY_ipd <= L0TXTLTLPLATENCY after CLK_DELAY;
	L0TXTLTLPREQEND_ipd <= L0TXTLTLPREQEND after CLK_DELAY;
	L0TXTLTLPREQ_ipd <= L0TXTLTLPREQ after CLK_DELAY;
	L0TXTLTLPWIDTH_ipd <= L0TXTLTLPWIDTH after CLK_DELAY;
	L0UPSTREAMRXPORTINL0S_ipd <= L0UPSTREAMRXPORTINL0S after CLK_DELAY;
	L0VC0PREVIEWEXPAND_ipd <= L0VC0PREVIEWEXPAND after CLK_DELAY;
	L0WAKEN_ipd <= L0WAKEN after CLK_DELAY;
	LLKRXCHFIFO_ipd <= LLKRXCHFIFO after CLK_DELAY;
	LLKRXCHTC_ipd <= LLKRXCHTC after CLK_DELAY;
	LLKRXDSTCONTREQN_ipd <= LLKRXDSTCONTREQN after CLK_DELAY;
	LLKRXDSTREQN_ipd <= LLKRXDSTREQN after CLK_DELAY;
	LLKTX4DWHEADERN_ipd <= LLKTX4DWHEADERN after CLK_DELAY;
	LLKTXCHFIFO_ipd <= LLKTXCHFIFO after CLK_DELAY;
	LLKTXCHTC_ipd <= LLKTXCHTC after CLK_DELAY;
	LLKTXCOMPLETEN_ipd <= LLKTXCOMPLETEN after CLK_DELAY;
	LLKTXCREATEECRCN_ipd <= LLKTXCREATEECRCN after CLK_DELAY;
	LLKTXDATA_ipd <= LLKTXDATA after CLK_DELAY;
	LLKTXENABLEN_ipd <= LLKTXENABLEN after CLK_DELAY;
	LLKTXEOFN_ipd <= LLKTXEOFN after CLK_DELAY;
	LLKTXEOPN_ipd <= LLKTXEOPN after CLK_DELAY;
	LLKTXSOFN_ipd <= LLKTXSOFN after CLK_DELAY;
	LLKTXSOPN_ipd <= LLKTXSOPN after CLK_DELAY;
	LLKTXSRCDSCN_ipd <= LLKTXSRCDSCN after CLK_DELAY;
	LLKTXSRCRDYN_ipd <= LLKTXSRCRDYN after CLK_DELAY;
	MAINPOWER_ipd <= MAINPOWER after CLK_DELAY;
	MGMTADDR_ipd <= MGMTADDR after CLK_DELAY;
	MGMTBWREN_ipd <= MGMTBWREN after CLK_DELAY;
	MGMTRDEN_ipd <= MGMTRDEN after CLK_DELAY;
	MGMTSTATSCREDITSEL_ipd <= MGMTSTATSCREDITSEL after CLK_DELAY;
	MGMTWDATA_ipd <= MGMTWDATA after CLK_DELAY;
	MGMTWREN_ipd <= MGMTWREN after CLK_DELAY;
	MIMDLLBRDATA_ipd <= MIMDLLBRDATA after CLK_DELAY;
	MIMRXBRDATA_ipd <= MIMRXBRDATA after CLK_DELAY;
	MIMTXBRDATA_ipd <= MIMTXBRDATA after CLK_DELAY;
	PIPEPHYSTATUSL0_ipd <= PIPEPHYSTATUSL0 after CLK_DELAY;
	PIPEPHYSTATUSL1_ipd <= PIPEPHYSTATUSL1 after CLK_DELAY;
	PIPEPHYSTATUSL2_ipd <= PIPEPHYSTATUSL2 after CLK_DELAY;
	PIPEPHYSTATUSL3_ipd <= PIPEPHYSTATUSL3 after CLK_DELAY;
	PIPEPHYSTATUSL4_ipd <= PIPEPHYSTATUSL4 after CLK_DELAY;
	PIPEPHYSTATUSL5_ipd <= PIPEPHYSTATUSL5 after CLK_DELAY;
	PIPEPHYSTATUSL6_ipd <= PIPEPHYSTATUSL6 after CLK_DELAY;
	PIPEPHYSTATUSL7_ipd <= PIPEPHYSTATUSL7 after CLK_DELAY;
	PIPERXCHANISALIGNEDL0_ipd <= PIPERXCHANISALIGNEDL0 after CLK_DELAY;
	PIPERXCHANISALIGNEDL1_ipd <= PIPERXCHANISALIGNEDL1 after CLK_DELAY;
	PIPERXCHANISALIGNEDL2_ipd <= PIPERXCHANISALIGNEDL2 after CLK_DELAY;
	PIPERXCHANISALIGNEDL3_ipd <= PIPERXCHANISALIGNEDL3 after CLK_DELAY;
	PIPERXCHANISALIGNEDL4_ipd <= PIPERXCHANISALIGNEDL4 after CLK_DELAY;
	PIPERXCHANISALIGNEDL5_ipd <= PIPERXCHANISALIGNEDL5 after CLK_DELAY;
	PIPERXCHANISALIGNEDL6_ipd <= PIPERXCHANISALIGNEDL6 after CLK_DELAY;
	PIPERXCHANISALIGNEDL7_ipd <= PIPERXCHANISALIGNEDL7 after CLK_DELAY;
	PIPERXDATAKL0_ipd <= PIPERXDATAKL0 after CLK_DELAY;
	PIPERXDATAKL1_ipd <= PIPERXDATAKL1 after CLK_DELAY;
	PIPERXDATAKL2_ipd <= PIPERXDATAKL2 after CLK_DELAY;
	PIPERXDATAKL3_ipd <= PIPERXDATAKL3 after CLK_DELAY;
	PIPERXDATAKL4_ipd <= PIPERXDATAKL4 after CLK_DELAY;
	PIPERXDATAKL5_ipd <= PIPERXDATAKL5 after CLK_DELAY;
	PIPERXDATAKL6_ipd <= PIPERXDATAKL6 after CLK_DELAY;
	PIPERXDATAKL7_ipd <= PIPERXDATAKL7 after CLK_DELAY;
	PIPERXDATAL0_ipd <= PIPERXDATAL0 after CLK_DELAY;
	PIPERXDATAL1_ipd <= PIPERXDATAL1 after CLK_DELAY;
	PIPERXDATAL2_ipd <= PIPERXDATAL2 after CLK_DELAY;
	PIPERXDATAL3_ipd <= PIPERXDATAL3 after CLK_DELAY;
	PIPERXDATAL4_ipd <= PIPERXDATAL4 after CLK_DELAY;
	PIPERXDATAL5_ipd <= PIPERXDATAL5 after CLK_DELAY;
	PIPERXDATAL6_ipd <= PIPERXDATAL6 after CLK_DELAY;
	PIPERXDATAL7_ipd <= PIPERXDATAL7 after CLK_DELAY;
	PIPERXELECIDLEL0_ipd <= PIPERXELECIDLEL0 after CLK_DELAY;
	PIPERXELECIDLEL1_ipd <= PIPERXELECIDLEL1 after CLK_DELAY;
	PIPERXELECIDLEL2_ipd <= PIPERXELECIDLEL2 after CLK_DELAY;
	PIPERXELECIDLEL3_ipd <= PIPERXELECIDLEL3 after CLK_DELAY;
	PIPERXELECIDLEL4_ipd <= PIPERXELECIDLEL4 after CLK_DELAY;
	PIPERXELECIDLEL5_ipd <= PIPERXELECIDLEL5 after CLK_DELAY;
	PIPERXELECIDLEL6_ipd <= PIPERXELECIDLEL6 after CLK_DELAY;
	PIPERXELECIDLEL7_ipd <= PIPERXELECIDLEL7 after CLK_DELAY;
	PIPERXSTATUSL0_ipd <= PIPERXSTATUSL0 after CLK_DELAY;
	PIPERXSTATUSL1_ipd <= PIPERXSTATUSL1 after CLK_DELAY;
	PIPERXSTATUSL2_ipd <= PIPERXSTATUSL2 after CLK_DELAY;
	PIPERXSTATUSL3_ipd <= PIPERXSTATUSL3 after CLK_DELAY;
	PIPERXSTATUSL4_ipd <= PIPERXSTATUSL4 after CLK_DELAY;
	PIPERXSTATUSL5_ipd <= PIPERXSTATUSL5 after CLK_DELAY;
	PIPERXSTATUSL6_ipd <= PIPERXSTATUSL6 after CLK_DELAY;
	PIPERXSTATUSL7_ipd <= PIPERXSTATUSL7 after CLK_DELAY;
	PIPERXVALIDL0_ipd <= PIPERXVALIDL0 after CLK_DELAY;
	PIPERXVALIDL1_ipd <= PIPERXVALIDL1 after CLK_DELAY;
	PIPERXVALIDL2_ipd <= PIPERXVALIDL2 after CLK_DELAY;
	PIPERXVALIDL3_ipd <= PIPERXVALIDL3 after CLK_DELAY;
	PIPERXVALIDL4_ipd <= PIPERXVALIDL4 after CLK_DELAY;
	PIPERXVALIDL5_ipd <= PIPERXVALIDL5 after CLK_DELAY;
	PIPERXVALIDL6_ipd <= PIPERXVALIDL6 after CLK_DELAY;
	PIPERXVALIDL7_ipd <= PIPERXVALIDL7 after CLK_DELAY;

	CRMCORECLKDLO_indelay <= CRMCORECLKDLO_ipd after CLK_DELAY;
	CRMCORECLKRXO_indelay <= CRMCORECLKRXO_ipd after CLK_DELAY;
	CRMCORECLKTXO_indelay <= CRMCORECLKTXO_ipd after CLK_DELAY;
	CRMCORECLK_indelay <= CRMCORECLK_ipd after CLK_DELAY;
	CRMUSERCLKRXO_indelay <= CRMUSERCLKRXO_ipd after CLK_DELAY;
	CRMUSERCLKTXO_indelay <= CRMUSERCLKTXO_ipd after CLK_DELAY;
	CRMUSERCLK_indelay <= CRMUSERCLK_ipd after CLK_DELAY;

	AUXPOWER_indelay <= AUXPOWER_ipd after IN_DELAY;
	CFGNEGOTIATEDLINKWIDTH_indelay <= CFGNEGOTIATEDLINKWIDTH_ipd after IN_DELAY;
	COMPLIANCEAVOID_indelay <= COMPLIANCEAVOID_ipd after IN_DELAY;
	CRMCFGBRIDGEHOTRESET_indelay <= CRMCFGBRIDGEHOTRESET_ipd after IN_DELAY;
	CRMLINKRSTN_indelay <= CRMLINKRSTN_ipd after IN_DELAY;
	CRMMACRSTN_indelay <= CRMMACRSTN_ipd after IN_DELAY;
	CRMMGMTRSTN_indelay <= CRMMGMTRSTN_ipd after IN_DELAY;
	CRMNVRSTN_indelay <= CRMNVRSTN_ipd after IN_DELAY;
	CRMTXHOTRESETN_indelay <= CRMTXHOTRESETN_ipd after IN_DELAY;
	CRMURSTN_indelay <= CRMURSTN_ipd after IN_DELAY;
	CRMUSERCFGRSTN_indelay <= CRMUSERCFGRSTN_ipd after IN_DELAY;
	CROSSLINKSEED_indelay <= CROSSLINKSEED_ipd after IN_DELAY;
	L0ACKNAKTIMERADJUSTMENT_indelay <= L0ACKNAKTIMERADJUSTMENT_ipd after IN_DELAY;
	L0ALLDOWNPORTSINL1_indelay <= L0ALLDOWNPORTSINL1_ipd after IN_DELAY;
	L0ALLDOWNRXPORTSINL0S_indelay <= L0ALLDOWNRXPORTSINL0S_ipd after IN_DELAY;
	L0ASE_indelay <= L0ASE_ipd after IN_DELAY;
	L0ASPORTCOUNT_indelay <= L0ASPORTCOUNT_ipd after IN_DELAY;
	L0ASTURNPOOLBITSCONSUMED_indelay <= L0ASTURNPOOLBITSCONSUMED_ipd after IN_DELAY;
	L0ATTENTIONBUTTONPRESSED_indelay <= L0ATTENTIONBUTTONPRESSED_ipd after IN_DELAY;
	L0CFGASSPANTREEOWNEDSTATE_indelay <= L0CFGASSPANTREEOWNEDSTATE_ipd after IN_DELAY;
	L0CFGASSTATECHANGECMD_indelay <= L0CFGASSTATECHANGECMD_ipd after IN_DELAY;
	L0CFGDISABLESCRAMBLE_indelay <= L0CFGDISABLESCRAMBLE_ipd after IN_DELAY;
	L0CFGEXTENDEDSYNC_indelay <= L0CFGEXTENDEDSYNC_ipd after IN_DELAY;
	L0CFGL0SENTRYENABLE_indelay <= L0CFGL0SENTRYENABLE_ipd after IN_DELAY;
	L0CFGL0SENTRYSUP_indelay <= L0CFGL0SENTRYSUP_ipd after IN_DELAY;
	L0CFGL0SEXITLAT_indelay <= L0CFGL0SEXITLAT_ipd after IN_DELAY;
	L0CFGLINKDISABLE_indelay <= L0CFGLINKDISABLE_ipd after IN_DELAY;
	L0CFGLOOPBACKMASTER_indelay <= L0CFGLOOPBACKMASTER_ipd after IN_DELAY;
	L0CFGNEGOTIATEDMAXP_indelay <= L0CFGNEGOTIATEDMAXP_ipd after IN_DELAY;
	L0CFGVCENABLE_indelay <= L0CFGVCENABLE_ipd after IN_DELAY;
	L0CFGVCID_indelay <= L0CFGVCID_ipd after IN_DELAY;
	L0DLLHOLDLINKUP_indelay <= L0DLLHOLDLINKUP_ipd after IN_DELAY;
	L0ELECTROMECHANICALINTERLOCKENGAGED_indelay <= L0ELECTROMECHANICALINTERLOCKENGAGED_ipd after IN_DELAY;
	L0FWDASSERTINTALEGACYINT_indelay <= L0FWDASSERTINTALEGACYINT_ipd after IN_DELAY;
	L0FWDASSERTINTBLEGACYINT_indelay <= L0FWDASSERTINTBLEGACYINT_ipd after IN_DELAY;
	L0FWDASSERTINTCLEGACYINT_indelay <= L0FWDASSERTINTCLEGACYINT_ipd after IN_DELAY;
	L0FWDASSERTINTDLEGACYINT_indelay <= L0FWDASSERTINTDLEGACYINT_ipd after IN_DELAY;
	L0FWDCORRERRIN_indelay <= L0FWDCORRERRIN_ipd after IN_DELAY;
	L0FWDDEASSERTINTALEGACYINT_indelay <= L0FWDDEASSERTINTALEGACYINT_ipd after IN_DELAY;
	L0FWDDEASSERTINTBLEGACYINT_indelay <= L0FWDDEASSERTINTBLEGACYINT_ipd after IN_DELAY;
	L0FWDDEASSERTINTCLEGACYINT_indelay <= L0FWDDEASSERTINTCLEGACYINT_ipd after IN_DELAY;
	L0FWDDEASSERTINTDLEGACYINT_indelay <= L0FWDDEASSERTINTDLEGACYINT_ipd after IN_DELAY;
	L0FWDFATALERRIN_indelay <= L0FWDFATALERRIN_ipd after IN_DELAY;
	L0FWDNONFATALERRIN_indelay <= L0FWDNONFATALERRIN_ipd after IN_DELAY;
	L0LEGACYINTFUNCT0_indelay <= L0LEGACYINTFUNCT0_ipd after IN_DELAY;
	L0MRLSENSORCLOSEDN_indelay <= L0MRLSENSORCLOSEDN_ipd after IN_DELAY;
	L0MSIREQUEST0_indelay <= L0MSIREQUEST0_ipd after IN_DELAY;
	L0PACKETHEADERFROMUSER_indelay <= L0PACKETHEADERFROMUSER_ipd after IN_DELAY;
	L0PMEREQIN_indelay <= L0PMEREQIN_ipd after IN_DELAY;
	L0PORTNUMBER_indelay <= L0PORTNUMBER_ipd after IN_DELAY;
	L0POWERFAULTDETECTED_indelay <= L0POWERFAULTDETECTED_ipd after IN_DELAY;
	L0PRESENCEDETECTSLOTEMPTYN_indelay <= L0PRESENCEDETECTSLOTEMPTYN_ipd after IN_DELAY;
	L0PWRNEWSTATEREQ_indelay <= L0PWRNEWSTATEREQ_ipd after IN_DELAY;
	L0PWRNEXTLINKSTATE_indelay <= L0PWRNEXTLINKSTATE_ipd after IN_DELAY;
	L0REPLAYTIMERADJUSTMENT_indelay <= L0REPLAYTIMERADJUSTMENT_ipd after IN_DELAY;
	L0ROOTTURNOFFREQ_indelay <= L0ROOTTURNOFFREQ_ipd after IN_DELAY;
	L0RXTLTLPNONINITIALIZEDVC_indelay <= L0RXTLTLPNONINITIALIZEDVC_ipd after IN_DELAY;
	L0SENDUNLOCKMESSAGE_indelay <= L0SENDUNLOCKMESSAGE_ipd after IN_DELAY;
	L0SETCOMPLETERABORTERROR_indelay <= L0SETCOMPLETERABORTERROR_ipd after IN_DELAY;
	L0SETCOMPLETIONTIMEOUTCORRERROR_indelay <= L0SETCOMPLETIONTIMEOUTCORRERROR_ipd after IN_DELAY;
	L0SETCOMPLETIONTIMEOUTUNCORRERROR_indelay <= L0SETCOMPLETIONTIMEOUTUNCORRERROR_ipd after IN_DELAY;
	L0SETDETECTEDCORRERROR_indelay <= L0SETDETECTEDCORRERROR_ipd after IN_DELAY;
	L0SETDETECTEDFATALERROR_indelay <= L0SETDETECTEDFATALERROR_ipd after IN_DELAY;
	L0SETDETECTEDNONFATALERROR_indelay <= L0SETDETECTEDNONFATALERROR_ipd after IN_DELAY;
	L0SETLINKDETECTEDPARITYERROR_indelay <= L0SETLINKDETECTEDPARITYERROR_ipd after IN_DELAY;
	L0SETLINKMASTERDATAPARITY_indelay <= L0SETLINKMASTERDATAPARITY_ipd after IN_DELAY;
	L0SETLINKRECEIVEDMASTERABORT_indelay <= L0SETLINKRECEIVEDMASTERABORT_ipd after IN_DELAY;
	L0SETLINKRECEIVEDTARGETABORT_indelay <= L0SETLINKRECEIVEDTARGETABORT_ipd after IN_DELAY;
	L0SETLINKSIGNALLEDTARGETABORT_indelay <= L0SETLINKSIGNALLEDTARGETABORT_ipd after IN_DELAY;
	L0SETLINKSYSTEMERROR_indelay <= L0SETLINKSYSTEMERROR_ipd after IN_DELAY;
	L0SETUNEXPECTEDCOMPLETIONCORRERROR_indelay <= L0SETUNEXPECTEDCOMPLETIONCORRERROR_ipd after IN_DELAY;
	L0SETUNEXPECTEDCOMPLETIONUNCORRERROR_indelay <= L0SETUNEXPECTEDCOMPLETIONUNCORRERROR_ipd after IN_DELAY;
	L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR_indelay <= L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR_ipd after IN_DELAY;
	L0SETUNSUPPORTEDREQUESTOTHERERROR_indelay <= L0SETUNSUPPORTEDREQUESTOTHERERROR_ipd after IN_DELAY;
	L0SETUSERDETECTEDPARITYERROR_indelay <= L0SETUSERDETECTEDPARITYERROR_ipd after IN_DELAY;
	L0SETUSERMASTERDATAPARITY_indelay <= L0SETUSERMASTERDATAPARITY_ipd after IN_DELAY;
	L0SETUSERRECEIVEDMASTERABORT_indelay <= L0SETUSERRECEIVEDMASTERABORT_ipd after IN_DELAY;
	L0SETUSERRECEIVEDTARGETABORT_indelay <= L0SETUSERRECEIVEDTARGETABORT_ipd after IN_DELAY;
	L0SETUSERSIGNALLEDTARGETABORT_indelay <= L0SETUSERSIGNALLEDTARGETABORT_ipd after IN_DELAY;
	L0SETUSERSYSTEMERROR_indelay <= L0SETUSERSYSTEMERROR_ipd after IN_DELAY;
	L0TLASFCCREDSTARVATION_indelay <= L0TLASFCCREDSTARVATION_ipd after IN_DELAY;
	L0TLLINKRETRAIN_indelay <= L0TLLINKRETRAIN_ipd after IN_DELAY;
	L0TRANSACTIONSPENDING_indelay <= L0TRANSACTIONSPENDING_ipd after IN_DELAY;
	L0TXBEACON_indelay <= L0TXBEACON_ipd after IN_DELAY;
	L0TXCFGPMTYPE_indelay <= L0TXCFGPMTYPE_ipd after IN_DELAY;
	L0TXCFGPM_indelay <= L0TXCFGPM_ipd after IN_DELAY;
	L0TXTLFCCMPLMCCRED_indelay <= L0TXTLFCCMPLMCCRED_ipd after IN_DELAY;
	L0TXTLFCCMPLMCUPDATE_indelay <= L0TXTLFCCMPLMCUPDATE_ipd after IN_DELAY;
	L0TXTLFCNPOSTBYPCRED_indelay <= L0TXTLFCNPOSTBYPCRED_ipd after IN_DELAY;
	L0TXTLFCNPOSTBYPUPDATE_indelay <= L0TXTLFCNPOSTBYPUPDATE_ipd after IN_DELAY;
	L0TXTLFCPOSTORDCRED_indelay <= L0TXTLFCPOSTORDCRED_ipd after IN_DELAY;
	L0TXTLFCPOSTORDUPDATE_indelay <= L0TXTLFCPOSTORDUPDATE_ipd after IN_DELAY;
	L0TXTLSBFCDATA_indelay <= L0TXTLSBFCDATA_ipd after IN_DELAY;
	L0TXTLSBFCUPDATE_indelay <= L0TXTLSBFCUPDATE_ipd after IN_DELAY;
	L0TXTLTLPDATA_indelay <= L0TXTLTLPDATA_ipd after IN_DELAY;
	L0TXTLTLPEDB_indelay <= L0TXTLTLPEDB_ipd after IN_DELAY;
	L0TXTLTLPENABLE_indelay <= L0TXTLTLPENABLE_ipd after IN_DELAY;
	L0TXTLTLPEND_indelay <= L0TXTLTLPEND_ipd after IN_DELAY;
	L0TXTLTLPLATENCY_indelay <= L0TXTLTLPLATENCY_ipd after IN_DELAY;
	L0TXTLTLPREQEND_indelay <= L0TXTLTLPREQEND_ipd after IN_DELAY;
	L0TXTLTLPREQ_indelay <= L0TXTLTLPREQ_ipd after IN_DELAY;
	L0TXTLTLPWIDTH_indelay <= L0TXTLTLPWIDTH_ipd after IN_DELAY;
	L0UPSTREAMRXPORTINL0S_indelay <= L0UPSTREAMRXPORTINL0S_ipd after IN_DELAY;
	L0VC0PREVIEWEXPAND_indelay <= L0VC0PREVIEWEXPAND_ipd after IN_DELAY;
	L0WAKEN_indelay <= L0WAKEN_ipd after IN_DELAY;
	LLKRXCHFIFO_indelay <= LLKRXCHFIFO_ipd after IN_DELAY;
	LLKRXCHTC_indelay <= LLKRXCHTC_ipd after IN_DELAY;
	LLKRXDSTCONTREQN_indelay <= LLKRXDSTCONTREQN_ipd after IN_DELAY;
	LLKRXDSTREQN_indelay <= LLKRXDSTREQN_ipd after IN_DELAY;
	LLKTX4DWHEADERN_indelay <= LLKTX4DWHEADERN_ipd after IN_DELAY;
	LLKTXCHFIFO_indelay <= LLKTXCHFIFO_ipd after IN_DELAY;
	LLKTXCHTC_indelay <= LLKTXCHTC_ipd after IN_DELAY;
	LLKTXCOMPLETEN_indelay <= LLKTXCOMPLETEN_ipd after IN_DELAY;
	LLKTXCREATEECRCN_indelay <= LLKTXCREATEECRCN_ipd after IN_DELAY;
	LLKTXDATA_indelay <= LLKTXDATA_ipd after IN_DELAY;
	LLKTXENABLEN_indelay <= LLKTXENABLEN_ipd after IN_DELAY;
	LLKTXEOFN_indelay <= LLKTXEOFN_ipd after IN_DELAY;
	LLKTXEOPN_indelay <= LLKTXEOPN_ipd after IN_DELAY;
	LLKTXSOFN_indelay <= LLKTXSOFN_ipd after IN_DELAY;
	LLKTXSOPN_indelay <= LLKTXSOPN_ipd after IN_DELAY;
	LLKTXSRCDSCN_indelay <= LLKTXSRCDSCN_ipd after IN_DELAY;
	LLKTXSRCRDYN_indelay <= LLKTXSRCRDYN_ipd after IN_DELAY;
	MAINPOWER_indelay <= MAINPOWER_ipd after IN_DELAY;
	MGMTADDR_indelay <= MGMTADDR_ipd after IN_DELAY;
	MGMTBWREN_indelay <= MGMTBWREN_ipd after IN_DELAY;
	MGMTRDEN_indelay <= MGMTRDEN_ipd after IN_DELAY;
	MGMTSTATSCREDITSEL_indelay <= MGMTSTATSCREDITSEL_ipd after IN_DELAY;
	MGMTWDATA_indelay <= MGMTWDATA_ipd after IN_DELAY;
	MGMTWREN_indelay <= MGMTWREN_ipd after IN_DELAY;
	MIMDLLBRDATA_indelay <= MIMDLLBRDATA_ipd after IN_DELAY;
	MIMRXBRDATA_indelay <= MIMRXBRDATA_ipd after IN_DELAY;
	MIMTXBRDATA_indelay <= MIMTXBRDATA_ipd after IN_DELAY;
	PIPEPHYSTATUSL0_indelay <= PIPEPHYSTATUSL0_ipd after IN_DELAY;
	PIPEPHYSTATUSL1_indelay <= PIPEPHYSTATUSL1_ipd after IN_DELAY;
	PIPEPHYSTATUSL2_indelay <= PIPEPHYSTATUSL2_ipd after IN_DELAY;
	PIPEPHYSTATUSL3_indelay <= PIPEPHYSTATUSL3_ipd after IN_DELAY;
	PIPEPHYSTATUSL4_indelay <= PIPEPHYSTATUSL4_ipd after IN_DELAY;
	PIPEPHYSTATUSL5_indelay <= PIPEPHYSTATUSL5_ipd after IN_DELAY;
	PIPEPHYSTATUSL6_indelay <= PIPEPHYSTATUSL6_ipd after IN_DELAY;
	PIPEPHYSTATUSL7_indelay <= PIPEPHYSTATUSL7_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL0_indelay <= PIPERXCHANISALIGNEDL0_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL1_indelay <= PIPERXCHANISALIGNEDL1_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL2_indelay <= PIPERXCHANISALIGNEDL2_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL3_indelay <= PIPERXCHANISALIGNEDL3_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL4_indelay <= PIPERXCHANISALIGNEDL4_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL5_indelay <= PIPERXCHANISALIGNEDL5_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL6_indelay <= PIPERXCHANISALIGNEDL6_ipd after IN_DELAY;
	PIPERXCHANISALIGNEDL7_indelay <= PIPERXCHANISALIGNEDL7_ipd after IN_DELAY;
	PIPERXDATAKL0_indelay <= PIPERXDATAKL0_ipd after IN_DELAY;
	PIPERXDATAKL1_indelay <= PIPERXDATAKL1_ipd after IN_DELAY;
	PIPERXDATAKL2_indelay <= PIPERXDATAKL2_ipd after IN_DELAY;
	PIPERXDATAKL3_indelay <= PIPERXDATAKL3_ipd after IN_DELAY;
	PIPERXDATAKL4_indelay <= PIPERXDATAKL4_ipd after IN_DELAY;
	PIPERXDATAKL5_indelay <= PIPERXDATAKL5_ipd after IN_DELAY;
	PIPERXDATAKL6_indelay <= PIPERXDATAKL6_ipd after IN_DELAY;
	PIPERXDATAKL7_indelay <= PIPERXDATAKL7_ipd after IN_DELAY;
	PIPERXDATAL0_indelay <= PIPERXDATAL0_ipd after IN_DELAY;
	PIPERXDATAL1_indelay <= PIPERXDATAL1_ipd after IN_DELAY;
	PIPERXDATAL2_indelay <= PIPERXDATAL2_ipd after IN_DELAY;
	PIPERXDATAL3_indelay <= PIPERXDATAL3_ipd after IN_DELAY;
	PIPERXDATAL4_indelay <= PIPERXDATAL4_ipd after IN_DELAY;
	PIPERXDATAL5_indelay <= PIPERXDATAL5_ipd after IN_DELAY;
	PIPERXDATAL6_indelay <= PIPERXDATAL6_ipd after IN_DELAY;
	PIPERXDATAL7_indelay <= PIPERXDATAL7_ipd after IN_DELAY;
	PIPERXELECIDLEL0_indelay <= PIPERXELECIDLEL0_ipd after IN_DELAY;
	PIPERXELECIDLEL1_indelay <= PIPERXELECIDLEL1_ipd after IN_DELAY;
	PIPERXELECIDLEL2_indelay <= PIPERXELECIDLEL2_ipd after IN_DELAY;
	PIPERXELECIDLEL3_indelay <= PIPERXELECIDLEL3_ipd after IN_DELAY;
	PIPERXELECIDLEL4_indelay <= PIPERXELECIDLEL4_ipd after IN_DELAY;
	PIPERXELECIDLEL5_indelay <= PIPERXELECIDLEL5_ipd after IN_DELAY;
	PIPERXELECIDLEL6_indelay <= PIPERXELECIDLEL6_ipd after IN_DELAY;
	PIPERXELECIDLEL7_indelay <= PIPERXELECIDLEL7_ipd after IN_DELAY;
	PIPERXSTATUSL0_indelay <= PIPERXSTATUSL0_ipd after IN_DELAY;
	PIPERXSTATUSL1_indelay <= PIPERXSTATUSL1_ipd after IN_DELAY;
	PIPERXSTATUSL2_indelay <= PIPERXSTATUSL2_ipd after IN_DELAY;
	PIPERXSTATUSL3_indelay <= PIPERXSTATUSL3_ipd after IN_DELAY;
	PIPERXSTATUSL4_indelay <= PIPERXSTATUSL4_ipd after IN_DELAY;
	PIPERXSTATUSL5_indelay <= PIPERXSTATUSL5_ipd after IN_DELAY;
	PIPERXSTATUSL6_indelay <= PIPERXSTATUSL6_ipd after IN_DELAY;
	PIPERXSTATUSL7_indelay <= PIPERXSTATUSL7_ipd after IN_DELAY;
	PIPERXVALIDL0_indelay <= PIPERXVALIDL0_ipd after IN_DELAY;
	PIPERXVALIDL1_indelay <= PIPERXVALIDL1_ipd after IN_DELAY;
	PIPERXVALIDL2_indelay <= PIPERXVALIDL2_ipd after IN_DELAY;
	PIPERXVALIDL3_indelay <= PIPERXVALIDL3_ipd after IN_DELAY;
	PIPERXVALIDL4_indelay <= PIPERXVALIDL4_ipd after IN_DELAY;
	PIPERXVALIDL5_indelay <= PIPERXVALIDL5_ipd after IN_DELAY;
	PIPERXVALIDL6_indelay <= PIPERXVALIDL6_ipd after IN_DELAY;
	PIPERXVALIDL7_indelay <= PIPERXVALIDL7_ipd after IN_DELAY;


	pcie_internal_1_1_swift_bw_1 : PCIE_INTERNAL_1_1_SWIFT
	port map (
	MCACTIVELANESIN  =>  ACTIVELANESIN_BINARY,
	MCAERBASEPTR  =>  AERBASEPTR_BINARY,
	MCAERCAPABILITYECRCCHECKCAPABLE  =>  AERCAPABILITYECRCCHECKCAPABLE_BINARY,
	MCAERCAPABILITYECRCGENCAPABLE  =>  AERCAPABILITYECRCGENCAPABLE_BINARY,
	MCAERCAPABILITYNEXTPTR  =>  AERCAPABILITYNEXTPTR_BINARY,
	MCBAR0ADDRWIDTH  =>  BAR0ADDRWIDTH_BINARY,
	MCBAR0EXIST  =>  BAR0EXIST_BINARY,
	MCBAR0IOMEMN  =>  BAR0IOMEMN_BINARY,
	MCBAR0MASKWIDTH  =>  BAR0MASKWIDTH_BINARY,
	MCBAR0PREFETCHABLE  =>  BAR0PREFETCHABLE_BINARY,
	MCBAR1ADDRWIDTH  =>  BAR1ADDRWIDTH_BINARY,
	MCBAR1EXIST  =>  BAR1EXIST_BINARY,
	MCBAR1IOMEMN  =>  BAR1IOMEMN_BINARY,
	MCBAR1MASKWIDTH  =>  BAR1MASKWIDTH_BINARY,
	MCBAR1PREFETCHABLE  =>  BAR1PREFETCHABLE_BINARY,
	MCBAR2ADDRWIDTH  =>  BAR2ADDRWIDTH_BINARY,
	MCBAR2EXIST  =>  BAR2EXIST_BINARY,
	MCBAR2IOMEMN  =>  BAR2IOMEMN_BINARY,
	MCBAR2MASKWIDTH  =>  BAR2MASKWIDTH_BINARY,
	MCBAR2PREFETCHABLE  =>  BAR2PREFETCHABLE_BINARY,
	MCBAR3ADDRWIDTH  =>  BAR3ADDRWIDTH_BINARY,
	MCBAR3EXIST  =>  BAR3EXIST_BINARY,
	MCBAR3IOMEMN  =>  BAR3IOMEMN_BINARY,
	MCBAR3MASKWIDTH  =>  BAR3MASKWIDTH_BINARY,
	MCBAR3PREFETCHABLE  =>  BAR3PREFETCHABLE_BINARY,
	MCBAR4ADDRWIDTH  =>  BAR4ADDRWIDTH_BINARY,
	MCBAR4EXIST  =>  BAR4EXIST_BINARY,
	MCBAR4IOMEMN  =>  BAR4IOMEMN_BINARY,
	MCBAR4MASKWIDTH  =>  BAR4MASKWIDTH_BINARY,
	MCBAR4PREFETCHABLE  =>  BAR4PREFETCHABLE_BINARY,
	MCBAR5ADDRWIDTH  =>  BAR5ADDRWIDTH_BINARY,
	MCBAR5EXIST  =>  BAR5EXIST_BINARY,
	MCBAR5IOMEMN  =>  BAR5IOMEMN_BINARY,
	MCBAR5MASKWIDTH  =>  BAR5MASKWIDTH_BINARY,
	MCBAR5PREFETCHABLE  =>  BAR5PREFETCHABLE_BINARY,
	MCCAPABILITIESPOINTER  =>  CAPABILITIESPOINTER_BINARY,
	MCCARDBUSCISPOINTER  =>  CARDBUSCISPOINTER_BINARY,
	MCCLASSCODE  =>  CLASSCODE_BINARY,
--	MCCLKDIVIDED  =>  CLKDIVIDED_BINARY,
	MCCONFIGROUTING  =>  CONFIGROUTING_BINARY,
	MCDEVICECAPABILITYENDPOINTL0SLATENCY  =>  DEVICECAPABILITYENDPOINTL0SLATENCY_BINARY,
	MCDEVICECAPABILITYENDPOINTL1LATENCY  =>  DEVICECAPABILITYENDPOINTL1LATENCY_BINARY,
	MCDEVICEID  =>  DEVICEID_BINARY,
	MCDEVICESERIALNUMBER  =>  DEVICESERIALNUMBER_BINARY,
	MCDSNBASEPTR  =>  DSNBASEPTR_BINARY,
	MCDSNCAPABILITYNEXTPTR  =>  DSNCAPABILITYNEXTPTR_BINARY,
	MCDUALCOREENABLE  =>  DUALCOREENABLE_BINARY,
	MCDUALCORESLAVE  =>  DUALCORESLAVE_BINARY,
	MCDUALROLECFGCNTRLROOTEPN  =>  DUALROLECFGCNTRLROOTEPN_BINARY,
	MCEXTCFGCAPPTR  =>  EXTCFGCAPPTR_BINARY,
	MCEXTCFGXPCAPPTR  =>  EXTCFGXPCAPPTR_BINARY,
	MCHEADERTYPE  =>  HEADERTYPE_BINARY,
	MCINFINITECOMPLETIONS  =>  INFINITECOMPLETIONS_BINARY,
	MCINTERRUPTPIN  =>  INTERRUPTPIN_BINARY,
	MCISSWITCH  =>  ISSWITCH_BINARY,
	MCL0SEXITLATENCY  =>  L0SEXITLATENCY_BINARY,
	MCL0SEXITLATENCYCOMCLK  =>  L0SEXITLATENCYCOMCLK_BINARY,
	MCL1EXITLATENCY  =>  L1EXITLATENCY_BINARY,
	MCL1EXITLATENCYCOMCLK  =>  L1EXITLATENCYCOMCLK_BINARY,
	MCLINKCAPABILITYASPMSUPPORT  =>  LINKCAPABILITYASPMSUPPORT_BINARY,
	MCLINKCAPABILITYMAXLINKWIDTH  =>  LINKCAPABILITYMAXLINKWIDTH_BINARY,
	MCLINKSTATUSSLOTCLOCKCONFIG  =>  LINKSTATUSSLOTCLOCKCONFIG_BINARY,
	MCLLKBYPASS  =>  LLKBYPASS_BINARY,
	MCLOWPRIORITYVCCOUNT  =>  LOWPRIORITYVCCOUNT_BINARY,
	MCMSIBASEPTR  =>  MSIBASEPTR_BINARY,
	MCMSICAPABILITYMULTIMSGCAP  =>  MSICAPABILITYMULTIMSGCAP_BINARY,
	MCMSICAPABILITYNEXTPTR  =>  MSICAPABILITYNEXTPTR_BINARY,
	MCPBBASEPTR  =>  PBBASEPTR_BINARY,
	MCPBCAPABILITYDW0BASEPOWER  =>  PBCAPABILITYDW0BASEPOWER_BINARY,
	MCPBCAPABILITYDW0DATASCALE  =>  PBCAPABILITYDW0DATASCALE_BINARY,
	MCPBCAPABILITYDW0PMSTATE  =>  PBCAPABILITYDW0PMSTATE_BINARY,
	MCPBCAPABILITYDW0PMSUBSTATE  =>  PBCAPABILITYDW0PMSUBSTATE_BINARY,
	MCPBCAPABILITYDW0POWERRAIL  =>  PBCAPABILITYDW0POWERRAIL_BINARY,
	MCPBCAPABILITYDW0TYPE  =>  PBCAPABILITYDW0TYPE_BINARY,
	MCPBCAPABILITYDW1BASEPOWER  =>  PBCAPABILITYDW1BASEPOWER_BINARY,
	MCPBCAPABILITYDW1DATASCALE  =>  PBCAPABILITYDW1DATASCALE_BINARY,
	MCPBCAPABILITYDW1PMSTATE  =>  PBCAPABILITYDW1PMSTATE_BINARY,
	MCPBCAPABILITYDW1PMSUBSTATE  =>  PBCAPABILITYDW1PMSUBSTATE_BINARY,
	MCPBCAPABILITYDW1POWERRAIL  =>  PBCAPABILITYDW1POWERRAIL_BINARY,
	MCPBCAPABILITYDW1TYPE  =>  PBCAPABILITYDW1TYPE_BINARY,
	MCPBCAPABILITYDW2BASEPOWER  =>  PBCAPABILITYDW2BASEPOWER_BINARY,
	MCPBCAPABILITYDW2DATASCALE  =>  PBCAPABILITYDW2DATASCALE_BINARY,
	MCPBCAPABILITYDW2PMSTATE  =>  PBCAPABILITYDW2PMSTATE_BINARY,
	MCPBCAPABILITYDW2PMSUBSTATE  =>  PBCAPABILITYDW2PMSUBSTATE_BINARY,
	MCPBCAPABILITYDW2POWERRAIL  =>  PBCAPABILITYDW2POWERRAIL_BINARY,
	MCPBCAPABILITYDW2TYPE  =>  PBCAPABILITYDW2TYPE_BINARY,
	MCPBCAPABILITYDW3BASEPOWER  =>  PBCAPABILITYDW3BASEPOWER_BINARY,
	MCPBCAPABILITYDW3DATASCALE  =>  PBCAPABILITYDW3DATASCALE_BINARY,
	MCPBCAPABILITYDW3PMSTATE  =>  PBCAPABILITYDW3PMSTATE_BINARY,
	MCPBCAPABILITYDW3PMSUBSTATE  =>  PBCAPABILITYDW3PMSUBSTATE_BINARY,
	MCPBCAPABILITYDW3POWERRAIL  =>  PBCAPABILITYDW3POWERRAIL_BINARY,
	MCPBCAPABILITYDW3TYPE  =>  PBCAPABILITYDW3TYPE_BINARY,
	MCPBCAPABILITYNEXTPTR  =>  PBCAPABILITYNEXTPTR_BINARY,
	MCPBCAPABILITYSYSTEMALLOCATED  =>  PBCAPABILITYSYSTEMALLOCATED_BINARY,
	MCPCIECAPABILITYINTMSGNUM  =>  PCIECAPABILITYINTMSGNUM_BINARY,
	MCPCIECAPABILITYNEXTPTR  =>  PCIECAPABILITYNEXTPTR_BINARY,
	MCPCIECAPABILITYSLOTIMPL  =>  PCIECAPABILITYSLOTIMPL_BINARY,
	MCPCIEREVISION  =>  PCIEREVISION_BINARY,
	MCPMBASEPTR  =>  PMBASEPTR_BINARY,
	MCPMCAPABILITYAUXCURRENT  =>  PMCAPABILITYAUXCURRENT_BINARY,
	MCPMCAPABILITYD1SUPPORT  =>  PMCAPABILITYD1SUPPORT_BINARY,
	MCPMCAPABILITYD2SUPPORT  =>  PMCAPABILITYD2SUPPORT_BINARY,
	MCPMCAPABILITYDSI  =>  PMCAPABILITYDSI_BINARY,
	MCPMCAPABILITYNEXTPTR  =>  PMCAPABILITYNEXTPTR_BINARY,
	MCPMCAPABILITYPMESUPPORT  =>  PMCAPABILITYPMESUPPORT_BINARY,
	MCPMDATA0  =>  PMDATA0_BINARY,
	MCPMDATA1  =>  PMDATA1_BINARY,
	MCPMDATA2  =>  PMDATA2_BINARY,
	MCPMDATA3  =>  PMDATA3_BINARY,
	MCPMDATA4  =>  PMDATA4_BINARY,
	MCPMDATA5  =>  PMDATA5_BINARY,
	MCPMDATA6  =>  PMDATA6_BINARY,
	MCPMDATA7  =>  PMDATA7_BINARY,
	MCPMDATA8  =>  PMDATA8_BINARY,
	MCPMDATASCALE0  =>  PMDATASCALE0_BINARY,
	MCPMDATASCALE1  =>  PMDATASCALE1_BINARY,
	MCPMDATASCALE2  =>  PMDATASCALE2_BINARY,
	MCPMDATASCALE3  =>  PMDATASCALE3_BINARY,
	MCPMDATASCALE4  =>  PMDATASCALE4_BINARY,
	MCPMDATASCALE5  =>  PMDATASCALE5_BINARY,
	MCPMDATASCALE6  =>  PMDATASCALE6_BINARY,
	MCPMDATASCALE7  =>  PMDATASCALE7_BINARY,
	MCPMDATASCALE8  =>  PMDATASCALE8_BINARY,
	MCPMSTATUSCONTROLDATASCALE  =>  PMSTATUSCONTROLDATASCALE_BINARY,
	MCPORTVCCAPABILITYEXTENDEDVCCOUNT  =>  PORTVCCAPABILITYEXTENDEDVCCOUNT_BINARY,
	MCPORTVCCAPABILITYVCARBCAP  =>  PORTVCCAPABILITYVCARBCAP_BINARY,
	MCPORTVCCAPABILITYVCARBTABLEOFFSET  =>  PORTVCCAPABILITYVCARBTABLEOFFSET_BINARY,
	MCRAMSHARETXRX  =>  RAMSHARETXRX_BINARY,
	MCRESETMODE  =>  RESETMODE_BINARY,
	MCRETRYRAMREADLATENCY  =>  RETRYRAMREADLATENCY_BINARY,
	MCRETRYRAMSIZE  =>  RETRYRAMSIZE_BINARY,
	MCRETRYRAMWIDTH  =>  RETRYRAMWIDTH_BINARY,
	MCRETRYRAMWRITELATENCY  =>  RETRYRAMWRITELATENCY_BINARY,
	MCRETRYREADADDRPIPE  =>  RETRYREADADDRPIPE_BINARY,
	MCRETRYREADDATAPIPE  =>  RETRYREADDATAPIPE_BINARY,
	MCRETRYWRITEPIPE  =>  RETRYWRITEPIPE_BINARY,
	MCREVISIONID  =>  REVISIONID_BINARY,
	MCRXREADADDRPIPE  =>  RXREADADDRPIPE_BINARY,
	MCRXREADDATAPIPE  =>  RXREADDATAPIPE_BINARY,
	MCRXWRITEPIPE  =>  RXWRITEPIPE_BINARY,
	MCSELECTASMODE  =>  SELECTASMODE_BINARY,
	MCSELECTDLLIF  =>  SELECTDLLIF_BINARY,
	MCSLOTCAPABILITYATTBUTTONPRESENT  =>  SLOTCAPABILITYATTBUTTONPRESENT_BINARY,
	MCSLOTCAPABILITYATTINDICATORPRESENT  =>  SLOTCAPABILITYATTINDICATORPRESENT_BINARY,
	MCSLOTCAPABILITYHOTPLUGCAPABLE  =>  SLOTCAPABILITYHOTPLUGCAPABLE_BINARY,
	MCSLOTCAPABILITYHOTPLUGSURPRISE  =>  SLOTCAPABILITYHOTPLUGSURPRISE_BINARY,
	MCSLOTCAPABILITYMSLSENSORPRESENT  =>  SLOTCAPABILITYMSLSENSORPRESENT_BINARY,
	MCSLOTCAPABILITYPHYSICALSLOTNUM  =>  SLOTCAPABILITYPHYSICALSLOTNUM_BINARY,
	MCSLOTCAPABILITYPOWERCONTROLLERPRESENT  =>  SLOTCAPABILITYPOWERCONTROLLERPRESENT_BINARY,
	MCSLOTCAPABILITYPOWERINDICATORPRESENT  =>  SLOTCAPABILITYPOWERINDICATORPRESENT_BINARY,
	MCSLOTCAPABILITYSLOTPOWERLIMITSCALE  =>  SLOTCAPABILITYSLOTPOWERLIMITSCALE_BINARY,
	MCSLOTCAPABILITYSLOTPOWERLIMITVALUE  =>  SLOTCAPABILITYSLOTPOWERLIMITVALUE_BINARY,
	MCSLOTIMPLEMENTED  =>  SLOTIMPLEMENTED_BINARY,
	MCSUBSYSTEMID  =>  SUBSYSTEMID_BINARY,
	MCSUBSYSTEMVENDORID  =>  SUBSYSTEMVENDORID_BINARY,
	MCTLRAMREADLATENCY  =>  TLRAMREADLATENCY_BINARY,
	MCTLRAMWIDTH  =>  TLRAMWIDTH_BINARY,
	MCTLRAMWRITELATENCY  =>  TLRAMWRITELATENCY_BINARY,
	MCTXREADADDRPIPE  =>  TXREADADDRPIPE_BINARY,
	MCTXREADDATAPIPE  =>  TXREADDATAPIPE_BINARY,
	MCTXTSNFTS  =>  TXTSNFTS_BINARY,
	MCTXTSNFTSCOMCLK  =>  TXTSNFTSCOMCLK_BINARY,
	MCTXWRITEPIPE  =>  TXWRITEPIPE_BINARY,
	MCUPSTREAMFACING  =>  UPSTREAMFACING_BINARY,
	MCVC0RXFIFOBASEC  =>  VC0RXFIFOBASEC_BINARY,
	MCVC0RXFIFOBASENP  =>  VC0RXFIFOBASENP_BINARY,
	MCVC0RXFIFOBASEP  =>  VC0RXFIFOBASEP_BINARY,
	MCVC0RXFIFOLIMITC  =>  VC0RXFIFOLIMITC_BINARY,
	MCVC0RXFIFOLIMITNP  =>  VC0RXFIFOLIMITNP_BINARY,
	MCVC0RXFIFOLIMITP  =>  VC0RXFIFOLIMITP_BINARY,
	MCVC0TOTALCREDITSCD  =>  VC0TOTALCREDITSCD_BINARY,
	MCVC0TOTALCREDITSCH  =>  VC0TOTALCREDITSCH_BINARY,
	MCVC0TOTALCREDITSNPH  =>  VC0TOTALCREDITSNPH_BINARY,
	MCVC0TOTALCREDITSPD  =>  VC0TOTALCREDITSPD_BINARY,
	MCVC0TOTALCREDITSPH  =>  VC0TOTALCREDITSPH_BINARY,
	MCVC0TXFIFOBASEC  =>  VC0TXFIFOBASEC_BINARY,
	MCVC0TXFIFOBASENP  =>  VC0TXFIFOBASENP_BINARY,
	MCVC0TXFIFOBASEP  =>  VC0TXFIFOBASEP_BINARY,
	MCVC0TXFIFOLIMITC  =>  VC0TXFIFOLIMITC_BINARY,
	MCVC0TXFIFOLIMITNP  =>  VC0TXFIFOLIMITNP_BINARY,
	MCVC0TXFIFOLIMITP  =>  VC0TXFIFOLIMITP_BINARY,
	MCVC1RXFIFOBASEC  =>  VC1RXFIFOBASEC_BINARY,
	MCVC1RXFIFOBASENP  =>  VC1RXFIFOBASENP_BINARY,
	MCVC1RXFIFOBASEP  =>  VC1RXFIFOBASEP_BINARY,
	MCVC1RXFIFOLIMITC  =>  VC1RXFIFOLIMITC_BINARY,
	MCVC1RXFIFOLIMITNP  =>  VC1RXFIFOLIMITNP_BINARY,
	MCVC1RXFIFOLIMITP  =>  VC1RXFIFOLIMITP_BINARY,
	MCVC1TOTALCREDITSCD  =>  VC1TOTALCREDITSCD_BINARY,
	MCVC1TOTALCREDITSCH  =>  VC1TOTALCREDITSCH_BINARY,
	MCVC1TOTALCREDITSNPH  =>  VC1TOTALCREDITSNPH_BINARY,
	MCVC1TOTALCREDITSPD  =>  VC1TOTALCREDITSPD_BINARY,
	MCVC1TOTALCREDITSPH  =>  VC1TOTALCREDITSPH_BINARY,
	MCVC1TXFIFOBASEC  =>  VC1TXFIFOBASEC_BINARY,
	MCVC1TXFIFOBASENP  =>  VC1TXFIFOBASENP_BINARY,
	MCVC1TXFIFOBASEP  =>  VC1TXFIFOBASEP_BINARY,
	MCVC1TXFIFOLIMITC  =>  VC1TXFIFOLIMITC_BINARY,
	MCVC1TXFIFOLIMITNP  =>  VC1TXFIFOLIMITNP_BINARY,
	MCVC1TXFIFOLIMITP  =>  VC1TXFIFOLIMITP_BINARY,
	MCVCBASEPTR  =>  VCBASEPTR_BINARY,
	MCVCCAPABILITYNEXTPTR  =>  VCCAPABILITYNEXTPTR_BINARY,
	MCVENDORID  =>  VENDORID_BINARY,
	MCXLINKSUPPORTED  =>  XLINKSUPPORTED_BINARY,
	MCXPBASEPTR  =>  XPBASEPTR_BINARY,
	MCXPDEVICEPORTTYPE  =>  XPDEVICEPORTTYPE_BINARY,
	MCXPMAXPAYLOAD  =>  XPMAXPAYLOAD_BINARY,
	MCXPRCBCONTROL  =>  XPRCBCONTROL_BINARY,

	BUSMASTERENABLE  =>  BUSMASTERENABLE_outdelay,
	CRMDOHOTRESETN  =>  CRMDOHOTRESETN_outdelay,
	CRMPWRSOFTRESETN  =>  CRMPWRSOFTRESETN_outdelay,
	CRMRXHOTRESETN  =>  CRMRXHOTRESETN_outdelay,
	DLLTXPMDLLPOUTSTANDING  =>  DLLTXPMDLLPOUTSTANDING_outdelay,
	INTERRUPTDISABLE  =>  INTERRUPTDISABLE_outdelay,
	IOSPACEENABLE  =>  IOSPACEENABLE_outdelay,
	L0ASAUTONOMOUSINITCOMPLETED  =>  L0ASAUTONOMOUSINITCOMPLETED_outdelay,
	L0ATTENTIONINDICATORCONTROL  =>  L0ATTENTIONINDICATORCONTROL_outdelay,
	L0CFGLOOPBACKACK  =>  L0CFGLOOPBACKACK_outdelay,
	L0COMPLETERID  =>  L0COMPLETERID_outdelay,
	L0CORRERRMSGRCVD  =>  L0CORRERRMSGRCVD_outdelay,
	L0DLLASRXSTATE  =>  L0DLLASRXSTATE_outdelay,
	L0DLLASTXSTATE  =>  L0DLLASTXSTATE_outdelay,
	L0DLLERRORVECTOR  =>  L0DLLERRORVECTOR_outdelay,
	L0DLLRXACKOUTSTANDING  =>  L0DLLRXACKOUTSTANDING_outdelay,
	L0DLLTXNONFCOUTSTANDING  =>  L0DLLTXNONFCOUTSTANDING_outdelay,
	L0DLLTXOUTSTANDING  =>  L0DLLTXOUTSTANDING_outdelay,
	L0DLLVCSTATUS  =>  L0DLLVCSTATUS_outdelay,
	L0DLUPDOWN  =>  L0DLUPDOWN_outdelay,
	L0ERRMSGREQID  =>  L0ERRMSGREQID_outdelay,
	L0FATALERRMSGRCVD  =>  L0FATALERRMSGRCVD_outdelay,
	L0FIRSTCFGWRITEOCCURRED  =>  L0FIRSTCFGWRITEOCCURRED_outdelay,
	L0FWDCORRERROUT  =>  L0FWDCORRERROUT_outdelay,
	L0FWDFATALERROUT  =>  L0FWDFATALERROUT_outdelay,
	L0FWDNONFATALERROUT  =>  L0FWDNONFATALERROUT_outdelay,
	L0LTSSMSTATE  =>  L0LTSSMSTATE_outdelay,
	L0MACENTEREDL0  =>  L0MACENTEREDL0_outdelay,
	L0MACLINKTRAINING  =>  L0MACLINKTRAINING_outdelay,
	L0MACLINKUP  =>  L0MACLINKUP_outdelay,
	L0MACNEGOTIATEDLINKWIDTH  =>  L0MACNEGOTIATEDLINKWIDTH_outdelay,
	L0MACNEWSTATEACK  =>  L0MACNEWSTATEACK_outdelay,
	L0MACRXL0SSTATE  =>  L0MACRXL0SSTATE_outdelay,
	L0MACUPSTREAMDOWNSTREAM  =>  L0MACUPSTREAMDOWNSTREAM_outdelay,
	L0MCFOUND  =>  L0MCFOUND_outdelay,
	L0MSIENABLE0  =>  L0MSIENABLE0_outdelay,
	L0MULTIMSGEN0  =>  L0MULTIMSGEN0_outdelay,
	L0NONFATALERRMSGRCVD  =>  L0NONFATALERRMSGRCVD_outdelay,
	L0PMEACK  =>  L0PMEACK_outdelay,
	L0PMEEN  =>  L0PMEEN_outdelay,
	L0PMEREQOUT  =>  L0PMEREQOUT_outdelay,
	L0POWERCONTROLLERCONTROL  =>  L0POWERCONTROLLERCONTROL_outdelay,
	L0POWERINDICATORCONTROL  =>  L0POWERINDICATORCONTROL_outdelay,
	L0PWRINHIBITTRANSFERS  =>  L0PWRINHIBITTRANSFERS_outdelay,
	L0PWRL1STATE  =>  L0PWRL1STATE_outdelay,
	L0PWRL23READYDEVICE  =>  L0PWRL23READYDEVICE_outdelay,
	L0PWRL23READYSTATE  =>  L0PWRL23READYSTATE_outdelay,
	L0PWRSTATE0  =>  L0PWRSTATE0_outdelay,
	L0PWRTURNOFFREQ  =>  L0PWRTURNOFFREQ_outdelay,
	L0PWRTXL0SSTATE  =>  L0PWRTXL0SSTATE_outdelay,
	L0RECEIVEDASSERTINTALEGACYINT  =>  L0RECEIVEDASSERTINTALEGACYINT_outdelay,
	L0RECEIVEDASSERTINTBLEGACYINT  =>  L0RECEIVEDASSERTINTBLEGACYINT_outdelay,
	L0RECEIVEDASSERTINTCLEGACYINT  =>  L0RECEIVEDASSERTINTCLEGACYINT_outdelay,
	L0RECEIVEDASSERTINTDLEGACYINT  =>  L0RECEIVEDASSERTINTDLEGACYINT_outdelay,
	L0RECEIVEDDEASSERTINTALEGACYINT  =>  L0RECEIVEDDEASSERTINTALEGACYINT_outdelay,
	L0RECEIVEDDEASSERTINTBLEGACYINT  =>  L0RECEIVEDDEASSERTINTBLEGACYINT_outdelay,
	L0RECEIVEDDEASSERTINTCLEGACYINT  =>  L0RECEIVEDDEASSERTINTCLEGACYINT_outdelay,
	L0RECEIVEDDEASSERTINTDLEGACYINT  =>  L0RECEIVEDDEASSERTINTDLEGACYINT_outdelay,
	L0RXBEACON  =>  L0RXBEACON_outdelay,
	L0RXDLLFCCMPLMCCRED  =>  L0RXDLLFCCMPLMCCRED_outdelay,
	L0RXDLLFCCMPLMCUPDATE  =>  L0RXDLLFCCMPLMCUPDATE_outdelay,
	L0RXDLLFCNPOSTBYPCRED  =>  L0RXDLLFCNPOSTBYPCRED_outdelay,
	L0RXDLLFCNPOSTBYPUPDATE  =>  L0RXDLLFCNPOSTBYPUPDATE_outdelay,
	L0RXDLLFCPOSTORDCRED  =>  L0RXDLLFCPOSTORDCRED_outdelay,
	L0RXDLLFCPOSTORDUPDATE  =>  L0RXDLLFCPOSTORDUPDATE_outdelay,
	L0RXDLLPM  =>  L0RXDLLPM_outdelay,
	L0RXDLLPMTYPE  =>  L0RXDLLPMTYPE_outdelay,
	L0RXDLLSBFCDATA  =>  L0RXDLLSBFCDATA_outdelay,
	L0RXDLLSBFCUPDATE  =>  L0RXDLLSBFCUPDATE_outdelay,
	L0RXDLLTLPECRCOK  =>  L0RXDLLTLPECRCOK_outdelay,
	L0RXDLLTLPEND  =>  L0RXDLLTLPEND_outdelay,
	L0RXMACLINKERROR  =>  L0RXMACLINKERROR_outdelay,
	L0STATSCFGOTHERRECEIVED  =>  L0STATSCFGOTHERRECEIVED_outdelay,
	L0STATSCFGOTHERTRANSMITTED  =>  L0STATSCFGOTHERTRANSMITTED_outdelay,
	L0STATSCFGRECEIVED  =>  L0STATSCFGRECEIVED_outdelay,
	L0STATSCFGTRANSMITTED  =>  L0STATSCFGTRANSMITTED_outdelay,
	L0STATSDLLPRECEIVED  =>  L0STATSDLLPRECEIVED_outdelay,
	L0STATSDLLPTRANSMITTED  =>  L0STATSDLLPTRANSMITTED_outdelay,
	L0STATSOSRECEIVED  =>  L0STATSOSRECEIVED_outdelay,
	L0STATSOSTRANSMITTED  =>  L0STATSOSTRANSMITTED_outdelay,
	L0STATSTLPRECEIVED  =>  L0STATSTLPRECEIVED_outdelay,
	L0STATSTLPTRANSMITTED  =>  L0STATSTLPTRANSMITTED_outdelay,
	L0TOGGLEELECTROMECHANICALINTERLOCK  =>  L0TOGGLEELECTROMECHANICALINTERLOCK_outdelay,
	L0TRANSFORMEDVC  =>  L0TRANSFORMEDVC_outdelay,
	L0TXDLLFCCMPLMCUPDATED  =>  L0TXDLLFCCMPLMCUPDATED_outdelay,
	L0TXDLLFCNPOSTBYPUPDATED  =>  L0TXDLLFCNPOSTBYPUPDATED_outdelay,
	L0TXDLLFCPOSTORDUPDATED  =>  L0TXDLLFCPOSTORDUPDATED_outdelay,
	L0TXDLLPMUPDATED  =>  L0TXDLLPMUPDATED_outdelay,
	L0TXDLLSBFCUPDATED  =>  L0TXDLLSBFCUPDATED_outdelay,
	L0UCBYPFOUND  =>  L0UCBYPFOUND_outdelay,
	L0UCORDFOUND  =>  L0UCORDFOUND_outdelay,
	L0UNLOCKRECEIVED  =>  L0UNLOCKRECEIVED_outdelay,
	LLKRX4DWHEADERN  =>  LLKRX4DWHEADERN_outdelay,
	LLKRXCHCOMPLETIONAVAILABLEN  =>  LLKRXCHCOMPLETIONAVAILABLEN_outdelay,
	LLKRXCHCOMPLETIONPARTIALN  =>  LLKRXCHCOMPLETIONPARTIALN_outdelay,
	LLKRXCHCONFIGAVAILABLEN  =>  LLKRXCHCONFIGAVAILABLEN_outdelay,
	LLKRXCHCONFIGPARTIALN  =>  LLKRXCHCONFIGPARTIALN_outdelay,
	LLKRXCHNONPOSTEDAVAILABLEN  =>  LLKRXCHNONPOSTEDAVAILABLEN_outdelay,
	LLKRXCHNONPOSTEDPARTIALN  =>  LLKRXCHNONPOSTEDPARTIALN_outdelay,
	LLKRXCHPOSTEDAVAILABLEN  =>  LLKRXCHPOSTEDAVAILABLEN_outdelay,
	LLKRXCHPOSTEDPARTIALN  =>  LLKRXCHPOSTEDPARTIALN_outdelay,
	LLKRXDATA  =>  LLKRXDATA_outdelay,
	LLKRXECRCBADN  =>  LLKRXECRCBADN_outdelay,
	LLKRXEOFN  =>  LLKRXEOFN_outdelay,
	LLKRXEOPN  =>  LLKRXEOPN_outdelay,
	LLKRXPREFERREDTYPE  =>  LLKRXPREFERREDTYPE_outdelay,
	LLKRXSOFN  =>  LLKRXSOFN_outdelay,
	LLKRXSOPN  =>  LLKRXSOPN_outdelay,
	LLKRXSRCDSCN  =>  LLKRXSRCDSCN_outdelay,
	LLKRXSRCLASTREQN  =>  LLKRXSRCLASTREQN_outdelay,
	LLKRXSRCRDYN  =>  LLKRXSRCRDYN_outdelay,
	LLKRXVALIDN  =>  LLKRXVALIDN_outdelay,
	LLKTCSTATUS  =>  LLKTCSTATUS_outdelay,
	LLKTXCHANSPACE  =>  LLKTXCHANSPACE_outdelay,
	LLKTXCHCOMPLETIONREADYN  =>  LLKTXCHCOMPLETIONREADYN_outdelay,
	LLKTXCHNONPOSTEDREADYN  =>  LLKTXCHNONPOSTEDREADYN_outdelay,
	LLKTXCHPOSTEDREADYN  =>  LLKTXCHPOSTEDREADYN_outdelay,
	LLKTXCONFIGREADYN  =>  LLKTXCONFIGREADYN_outdelay,
	LLKTXDSTRDYN  =>  LLKTXDSTRDYN_outdelay,
	MAXPAYLOADSIZE  =>  MAXPAYLOADSIZE_outdelay,
	MAXREADREQUESTSIZE  =>  MAXREADREQUESTSIZE_outdelay,
	MEMSPACEENABLE  =>  MEMSPACEENABLE_outdelay,
	MGMTPSO  =>  MGMTPSO_outdelay,
	MGMTRDATA  =>  MGMTRDATA_outdelay,
	MGMTSTATSCREDIT  =>  MGMTSTATSCREDIT_outdelay,
	MIMDLLBRADD  =>  MIMDLLBRADD_outdelay,
	MIMDLLBREN  =>  MIMDLLBREN_outdelay,
	MIMDLLBWADD  =>  MIMDLLBWADD_outdelay,
	MIMDLLBWDATA  =>  MIMDLLBWDATA_outdelay,
	MIMDLLBWEN  =>  MIMDLLBWEN_outdelay,
	MIMRXBRADD  =>  MIMRXBRADD_outdelay,
	MIMRXBREN  =>  MIMRXBREN_outdelay,
	MIMRXBWADD  =>  MIMRXBWADD_outdelay,
	MIMRXBWDATA  =>  MIMRXBWDATA_outdelay,
	MIMRXBWEN  =>  MIMRXBWEN_outdelay,
	MIMTXBRADD  =>  MIMTXBRADD_outdelay,
	MIMTXBREN  =>  MIMTXBREN_outdelay,
	MIMTXBWADD  =>  MIMTXBWADD_outdelay,
	MIMTXBWDATA  =>  MIMTXBWDATA_outdelay,
	MIMTXBWEN  =>  MIMTXBWEN_outdelay,
	PARITYERRORRESPONSE  =>  PARITYERRORRESPONSE_outdelay,
	PIPEDESKEWLANESL0  =>  PIPEDESKEWLANESL0_outdelay,
	PIPEDESKEWLANESL1  =>  PIPEDESKEWLANESL1_outdelay,
	PIPEDESKEWLANESL2  =>  PIPEDESKEWLANESL2_outdelay,
	PIPEDESKEWLANESL3  =>  PIPEDESKEWLANESL3_outdelay,
	PIPEDESKEWLANESL4  =>  PIPEDESKEWLANESL4_outdelay,
	PIPEDESKEWLANESL5  =>  PIPEDESKEWLANESL5_outdelay,
	PIPEDESKEWLANESL6  =>  PIPEDESKEWLANESL6_outdelay,
	PIPEDESKEWLANESL7  =>  PIPEDESKEWLANESL7_outdelay,
	PIPEPOWERDOWNL0  =>  PIPEPOWERDOWNL0_outdelay,
	PIPEPOWERDOWNL1  =>  PIPEPOWERDOWNL1_outdelay,
	PIPEPOWERDOWNL2  =>  PIPEPOWERDOWNL2_outdelay,
	PIPEPOWERDOWNL3  =>  PIPEPOWERDOWNL3_outdelay,
	PIPEPOWERDOWNL4  =>  PIPEPOWERDOWNL4_outdelay,
	PIPEPOWERDOWNL5  =>  PIPEPOWERDOWNL5_outdelay,
	PIPEPOWERDOWNL6  =>  PIPEPOWERDOWNL6_outdelay,
	PIPEPOWERDOWNL7  =>  PIPEPOWERDOWNL7_outdelay,
	PIPERESETL0  =>  PIPERESETL0_outdelay,
	PIPERESETL1  =>  PIPERESETL1_outdelay,
	PIPERESETL2  =>  PIPERESETL2_outdelay,
	PIPERESETL3  =>  PIPERESETL3_outdelay,
	PIPERESETL4  =>  PIPERESETL4_outdelay,
	PIPERESETL5  =>  PIPERESETL5_outdelay,
	PIPERESETL6  =>  PIPERESETL6_outdelay,
	PIPERESETL7  =>  PIPERESETL7_outdelay,
	PIPERXPOLARITYL0  =>  PIPERXPOLARITYL0_outdelay,
	PIPERXPOLARITYL1  =>  PIPERXPOLARITYL1_outdelay,
	PIPERXPOLARITYL2  =>  PIPERXPOLARITYL2_outdelay,
	PIPERXPOLARITYL3  =>  PIPERXPOLARITYL3_outdelay,
	PIPERXPOLARITYL4  =>  PIPERXPOLARITYL4_outdelay,
	PIPERXPOLARITYL5  =>  PIPERXPOLARITYL5_outdelay,
	PIPERXPOLARITYL6  =>  PIPERXPOLARITYL6_outdelay,
	PIPERXPOLARITYL7  =>  PIPERXPOLARITYL7_outdelay,
	PIPETXCOMPLIANCEL0  =>  PIPETXCOMPLIANCEL0_outdelay,
	PIPETXCOMPLIANCEL1  =>  PIPETXCOMPLIANCEL1_outdelay,
	PIPETXCOMPLIANCEL2  =>  PIPETXCOMPLIANCEL2_outdelay,
	PIPETXCOMPLIANCEL3  =>  PIPETXCOMPLIANCEL3_outdelay,
	PIPETXCOMPLIANCEL4  =>  PIPETXCOMPLIANCEL4_outdelay,
	PIPETXCOMPLIANCEL5  =>  PIPETXCOMPLIANCEL5_outdelay,
	PIPETXCOMPLIANCEL6  =>  PIPETXCOMPLIANCEL6_outdelay,
	PIPETXCOMPLIANCEL7  =>  PIPETXCOMPLIANCEL7_outdelay,
	PIPETXDATAKL0  =>  PIPETXDATAKL0_outdelay,
	PIPETXDATAKL1  =>  PIPETXDATAKL1_outdelay,
	PIPETXDATAKL2  =>  PIPETXDATAKL2_outdelay,
	PIPETXDATAKL3  =>  PIPETXDATAKL3_outdelay,
	PIPETXDATAKL4  =>  PIPETXDATAKL4_outdelay,
	PIPETXDATAKL5  =>  PIPETXDATAKL5_outdelay,
	PIPETXDATAKL6  =>  PIPETXDATAKL6_outdelay,
	PIPETXDATAKL7  =>  PIPETXDATAKL7_outdelay,
	PIPETXDATAL0  =>  PIPETXDATAL0_outdelay,
	PIPETXDATAL1  =>  PIPETXDATAL1_outdelay,
	PIPETXDATAL2  =>  PIPETXDATAL2_outdelay,
	PIPETXDATAL3  =>  PIPETXDATAL3_outdelay,
	PIPETXDATAL4  =>  PIPETXDATAL4_outdelay,
	PIPETXDATAL5  =>  PIPETXDATAL5_outdelay,
	PIPETXDATAL6  =>  PIPETXDATAL6_outdelay,
	PIPETXDATAL7  =>  PIPETXDATAL7_outdelay,
	PIPETXDETECTRXLOOPBACKL0  =>  PIPETXDETECTRXLOOPBACKL0_outdelay,
	PIPETXDETECTRXLOOPBACKL1  =>  PIPETXDETECTRXLOOPBACKL1_outdelay,
	PIPETXDETECTRXLOOPBACKL2  =>  PIPETXDETECTRXLOOPBACKL2_outdelay,
	PIPETXDETECTRXLOOPBACKL3  =>  PIPETXDETECTRXLOOPBACKL3_outdelay,
	PIPETXDETECTRXLOOPBACKL4  =>  PIPETXDETECTRXLOOPBACKL4_outdelay,
	PIPETXDETECTRXLOOPBACKL5  =>  PIPETXDETECTRXLOOPBACKL5_outdelay,
	PIPETXDETECTRXLOOPBACKL6  =>  PIPETXDETECTRXLOOPBACKL6_outdelay,
	PIPETXDETECTRXLOOPBACKL7  =>  PIPETXDETECTRXLOOPBACKL7_outdelay,
	PIPETXELECIDLEL0  =>  PIPETXELECIDLEL0_outdelay,
	PIPETXELECIDLEL1  =>  PIPETXELECIDLEL1_outdelay,
	PIPETXELECIDLEL2  =>  PIPETXELECIDLEL2_outdelay,
	PIPETXELECIDLEL3  =>  PIPETXELECIDLEL3_outdelay,
	PIPETXELECIDLEL4  =>  PIPETXELECIDLEL4_outdelay,
	PIPETXELECIDLEL5  =>  PIPETXELECIDLEL5_outdelay,
	PIPETXELECIDLEL6  =>  PIPETXELECIDLEL6_outdelay,
	PIPETXELECIDLEL7  =>  PIPETXELECIDLEL7_outdelay,
	SERRENABLE  =>  SERRENABLE_outdelay,
	URREPORTINGENABLE  =>  URREPORTINGENABLE_outdelay,

	AUXPOWER  =>  AUXPOWER_indelay,
	CFGNEGOTIATEDLINKWIDTH  =>  CFGNEGOTIATEDLINKWIDTH_indelay,
	COMPLIANCEAVOID  =>  COMPLIANCEAVOID_indelay,
	CRMCFGBRIDGEHOTRESET  =>  CRMCFGBRIDGEHOTRESET_indelay,
	CRMCORECLK  =>  CRMCORECLK_indelay,
	CRMCORECLKDLO  =>  CRMCORECLKDLO_indelay,
	CRMCORECLKRXO  =>  CRMCORECLKRXO_indelay,
	CRMCORECLKTXO  =>  CRMCORECLKTXO_indelay,
	CRMLINKRSTN  =>  CRMLINKRSTN_indelay,
	CRMMACRSTN  =>  CRMMACRSTN_indelay,
	CRMMGMTRSTN  =>  CRMMGMTRSTN_indelay,
	CRMNVRSTN  =>  CRMNVRSTN_indelay,
	CRMTXHOTRESETN  =>  CRMTXHOTRESETN_indelay,
	CRMURSTN  =>  CRMURSTN_indelay,
	CRMUSERCFGRSTN  =>  CRMUSERCFGRSTN_indelay,
	CRMUSERCLK  =>  CRMUSERCLK_indelay,
	CRMUSERCLKRXO  =>  CRMUSERCLKRXO_indelay,
	CRMUSERCLKTXO  =>  CRMUSERCLKTXO_indelay,
	CROSSLINKSEED  =>  CROSSLINKSEED_indelay,
	GSR  =>  GSR,
	L0ACKNAKTIMERADJUSTMENT  =>  L0ACKNAKTIMERADJUSTMENT_indelay,
	L0ALLDOWNPORTSINL1  =>  L0ALLDOWNPORTSINL1_indelay,
	L0ALLDOWNRXPORTSINL0S  =>  L0ALLDOWNRXPORTSINL0S_indelay,
	L0ASE  =>  L0ASE_indelay,
	L0ASPORTCOUNT  =>  L0ASPORTCOUNT_indelay,
	L0ASTURNPOOLBITSCONSUMED  =>  L0ASTURNPOOLBITSCONSUMED_indelay,
	L0ATTENTIONBUTTONPRESSED  =>  L0ATTENTIONBUTTONPRESSED_indelay,
	L0CFGASSPANTREEOWNEDSTATE  =>  L0CFGASSPANTREEOWNEDSTATE_indelay,
	L0CFGASSTATECHANGECMD  =>  L0CFGASSTATECHANGECMD_indelay,
	L0CFGDISABLESCRAMBLE  =>  L0CFGDISABLESCRAMBLE_indelay,
	L0CFGEXTENDEDSYNC  =>  L0CFGEXTENDEDSYNC_indelay,
	L0CFGL0SENTRYENABLE  =>  L0CFGL0SENTRYENABLE_indelay,
	L0CFGL0SENTRYSUP  =>  L0CFGL0SENTRYSUP_indelay,
	L0CFGL0SEXITLAT  =>  L0CFGL0SEXITLAT_indelay,
	L0CFGLINKDISABLE  =>  L0CFGLINKDISABLE_indelay,
	L0CFGLOOPBACKMASTER  =>  L0CFGLOOPBACKMASTER_indelay,
	L0CFGNEGOTIATEDMAXP  =>  L0CFGNEGOTIATEDMAXP_indelay,
	L0CFGVCENABLE  =>  L0CFGVCENABLE_indelay,
	L0CFGVCID  =>  L0CFGVCID_indelay,
	L0DLLHOLDLINKUP  =>  L0DLLHOLDLINKUP_indelay,
	L0ELECTROMECHANICALINTERLOCKENGAGED  =>  L0ELECTROMECHANICALINTERLOCKENGAGED_indelay,
	L0FWDASSERTINTALEGACYINT  =>  L0FWDASSERTINTALEGACYINT_indelay,
	L0FWDASSERTINTBLEGACYINT  =>  L0FWDASSERTINTBLEGACYINT_indelay,
	L0FWDASSERTINTCLEGACYINT  =>  L0FWDASSERTINTCLEGACYINT_indelay,
	L0FWDASSERTINTDLEGACYINT  =>  L0FWDASSERTINTDLEGACYINT_indelay,
	L0FWDCORRERRIN  =>  L0FWDCORRERRIN_indelay,
	L0FWDDEASSERTINTALEGACYINT  =>  L0FWDDEASSERTINTALEGACYINT_indelay,
	L0FWDDEASSERTINTBLEGACYINT  =>  L0FWDDEASSERTINTBLEGACYINT_indelay,
	L0FWDDEASSERTINTCLEGACYINT  =>  L0FWDDEASSERTINTCLEGACYINT_indelay,
	L0FWDDEASSERTINTDLEGACYINT  =>  L0FWDDEASSERTINTDLEGACYINT_indelay,
	L0FWDFATALERRIN  =>  L0FWDFATALERRIN_indelay,
	L0FWDNONFATALERRIN  =>  L0FWDNONFATALERRIN_indelay,
	L0LEGACYINTFUNCT0  =>  L0LEGACYINTFUNCT0_indelay,
	L0MRLSENSORCLOSEDN  =>  L0MRLSENSORCLOSEDN_indelay,
	L0MSIREQUEST0  =>  L0MSIREQUEST0_indelay,
	L0PACKETHEADERFROMUSER  =>  L0PACKETHEADERFROMUSER_indelay,
	L0PMEREQIN  =>  L0PMEREQIN_indelay,
	L0PORTNUMBER  =>  L0PORTNUMBER_indelay,
	L0POWERFAULTDETECTED  =>  L0POWERFAULTDETECTED_indelay,
	L0PRESENCEDETECTSLOTEMPTYN  =>  L0PRESENCEDETECTSLOTEMPTYN_indelay,
	L0PWRNEWSTATEREQ  =>  L0PWRNEWSTATEREQ_indelay,
	L0PWRNEXTLINKSTATE  =>  L0PWRNEXTLINKSTATE_indelay,
	L0REPLAYTIMERADJUSTMENT  =>  L0REPLAYTIMERADJUSTMENT_indelay,
	L0ROOTTURNOFFREQ  =>  L0ROOTTURNOFFREQ_indelay,
	L0RXTLTLPNONINITIALIZEDVC  =>  L0RXTLTLPNONINITIALIZEDVC_indelay,
	L0SENDUNLOCKMESSAGE  =>  L0SENDUNLOCKMESSAGE_indelay,
	L0SETCOMPLETERABORTERROR  =>  L0SETCOMPLETERABORTERROR_indelay,
	L0SETCOMPLETIONTIMEOUTCORRERROR  =>  L0SETCOMPLETIONTIMEOUTCORRERROR_indelay,
	L0SETCOMPLETIONTIMEOUTUNCORRERROR  =>  L0SETCOMPLETIONTIMEOUTUNCORRERROR_indelay,
	L0SETDETECTEDCORRERROR  =>  L0SETDETECTEDCORRERROR_indelay,
	L0SETDETECTEDFATALERROR  =>  L0SETDETECTEDFATALERROR_indelay,
	L0SETDETECTEDNONFATALERROR  =>  L0SETDETECTEDNONFATALERROR_indelay,
	L0SETLINKDETECTEDPARITYERROR  =>  L0SETLINKDETECTEDPARITYERROR_indelay,
	L0SETLINKMASTERDATAPARITY  =>  L0SETLINKMASTERDATAPARITY_indelay,
	L0SETLINKRECEIVEDMASTERABORT  =>  L0SETLINKRECEIVEDMASTERABORT_indelay,
	L0SETLINKRECEIVEDTARGETABORT  =>  L0SETLINKRECEIVEDTARGETABORT_indelay,
	L0SETLINKSIGNALLEDTARGETABORT  =>  L0SETLINKSIGNALLEDTARGETABORT_indelay,
	L0SETLINKSYSTEMERROR  =>  L0SETLINKSYSTEMERROR_indelay,
	L0SETUNEXPECTEDCOMPLETIONCORRERROR  =>  L0SETUNEXPECTEDCOMPLETIONCORRERROR_indelay,
	L0SETUNEXPECTEDCOMPLETIONUNCORRERROR  =>  L0SETUNEXPECTEDCOMPLETIONUNCORRERROR_indelay,
	L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR  =>  L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR_indelay,
	L0SETUNSUPPORTEDREQUESTOTHERERROR  =>  L0SETUNSUPPORTEDREQUESTOTHERERROR_indelay,
	L0SETUSERDETECTEDPARITYERROR  =>  L0SETUSERDETECTEDPARITYERROR_indelay,
	L0SETUSERMASTERDATAPARITY  =>  L0SETUSERMASTERDATAPARITY_indelay,
	L0SETUSERRECEIVEDMASTERABORT  =>  L0SETUSERRECEIVEDMASTERABORT_indelay,
	L0SETUSERRECEIVEDTARGETABORT  =>  L0SETUSERRECEIVEDTARGETABORT_indelay,
	L0SETUSERSIGNALLEDTARGETABORT  =>  L0SETUSERSIGNALLEDTARGETABORT_indelay,
	L0SETUSERSYSTEMERROR  =>  L0SETUSERSYSTEMERROR_indelay,
	L0TLASFCCREDSTARVATION  =>  L0TLASFCCREDSTARVATION_indelay,
	L0TLLINKRETRAIN  =>  L0TLLINKRETRAIN_indelay,
	L0TRANSACTIONSPENDING  =>  L0TRANSACTIONSPENDING_indelay,
	L0TXBEACON  =>  L0TXBEACON_indelay,
	L0TXCFGPM  =>  L0TXCFGPM_indelay,
	L0TXCFGPMTYPE  =>  L0TXCFGPMTYPE_indelay,
	L0TXTLFCCMPLMCCRED  =>  L0TXTLFCCMPLMCCRED_indelay,
	L0TXTLFCCMPLMCUPDATE  =>  L0TXTLFCCMPLMCUPDATE_indelay,
	L0TXTLFCNPOSTBYPCRED  =>  L0TXTLFCNPOSTBYPCRED_indelay,
	L0TXTLFCNPOSTBYPUPDATE  =>  L0TXTLFCNPOSTBYPUPDATE_indelay,
	L0TXTLFCPOSTORDCRED  =>  L0TXTLFCPOSTORDCRED_indelay,
	L0TXTLFCPOSTORDUPDATE  =>  L0TXTLFCPOSTORDUPDATE_indelay,
	L0TXTLSBFCDATA  =>  L0TXTLSBFCDATA_indelay,
	L0TXTLSBFCUPDATE  =>  L0TXTLSBFCUPDATE_indelay,
	L0TXTLTLPDATA  =>  L0TXTLTLPDATA_indelay,
	L0TXTLTLPEDB  =>  L0TXTLTLPEDB_indelay,
	L0TXTLTLPENABLE  =>  L0TXTLTLPENABLE_indelay,
	L0TXTLTLPEND  =>  L0TXTLTLPEND_indelay,
	L0TXTLTLPLATENCY  =>  L0TXTLTLPLATENCY_indelay,
	L0TXTLTLPREQ  =>  L0TXTLTLPREQ_indelay,
	L0TXTLTLPREQEND  =>  L0TXTLTLPREQEND_indelay,
	L0TXTLTLPWIDTH  =>  L0TXTLTLPWIDTH_indelay,
	L0UPSTREAMRXPORTINL0S  =>  L0UPSTREAMRXPORTINL0S_indelay,
	L0VC0PREVIEWEXPAND  =>  L0VC0PREVIEWEXPAND_indelay,
	L0WAKEN  =>  L0WAKEN_indelay,
	LLKRXCHFIFO  =>  LLKRXCHFIFO_indelay,
	LLKRXCHTC  =>  LLKRXCHTC_indelay,
	LLKRXDSTCONTREQN  =>  LLKRXDSTCONTREQN_indelay,
	LLKRXDSTREQN  =>  LLKRXDSTREQN_indelay,
	LLKTX4DWHEADERN  =>  LLKTX4DWHEADERN_indelay,
	LLKTXCHFIFO  =>  LLKTXCHFIFO_indelay,
	LLKTXCHTC  =>  LLKTXCHTC_indelay,
	LLKTXCOMPLETEN  =>  LLKTXCOMPLETEN_indelay,
	LLKTXCREATEECRCN  =>  LLKTXCREATEECRCN_indelay,
	LLKTXDATA  =>  LLKTXDATA_indelay,
	LLKTXENABLEN  =>  LLKTXENABLEN_indelay,
	LLKTXEOFN  =>  LLKTXEOFN_indelay,
	LLKTXEOPN  =>  LLKTXEOPN_indelay,
	LLKTXSOFN  =>  LLKTXSOFN_indelay,
	LLKTXSOPN  =>  LLKTXSOPN_indelay,
	LLKTXSRCDSCN  =>  LLKTXSRCDSCN_indelay,
	LLKTXSRCRDYN  =>  LLKTXSRCRDYN_indelay,
	MAINPOWER  =>  MAINPOWER_indelay,
	MGMTADDR  =>  MGMTADDR_indelay,
	MGMTBWREN  =>  MGMTBWREN_indelay,
	MGMTRDEN  =>  MGMTRDEN_indelay,
	MGMTSTATSCREDITSEL  =>  MGMTSTATSCREDITSEL_indelay,
	MGMTWDATA  =>  MGMTWDATA_indelay,
	MGMTWREN  =>  MGMTWREN_indelay,
	MIMDLLBRDATA  =>  MIMDLLBRDATA_indelay,
	MIMRXBRDATA  =>  MIMRXBRDATA_indelay,
	MIMTXBRDATA  =>  MIMTXBRDATA_indelay,
	PIPEPHYSTATUSL0  =>  PIPEPHYSTATUSL0_indelay,
	PIPEPHYSTATUSL1  =>  PIPEPHYSTATUSL1_indelay,
	PIPEPHYSTATUSL2  =>  PIPEPHYSTATUSL2_indelay,
	PIPEPHYSTATUSL3  =>  PIPEPHYSTATUSL3_indelay,
	PIPEPHYSTATUSL4  =>  PIPEPHYSTATUSL4_indelay,
	PIPEPHYSTATUSL5  =>  PIPEPHYSTATUSL5_indelay,
	PIPEPHYSTATUSL6  =>  PIPEPHYSTATUSL6_indelay,
	PIPEPHYSTATUSL7  =>  PIPEPHYSTATUSL7_indelay,
	PIPERXCHANISALIGNEDL0  =>  PIPERXCHANISALIGNEDL0_indelay,
	PIPERXCHANISALIGNEDL1  =>  PIPERXCHANISALIGNEDL1_indelay,
	PIPERXCHANISALIGNEDL2  =>  PIPERXCHANISALIGNEDL2_indelay,
	PIPERXCHANISALIGNEDL3  =>  PIPERXCHANISALIGNEDL3_indelay,
	PIPERXCHANISALIGNEDL4  =>  PIPERXCHANISALIGNEDL4_indelay,
	PIPERXCHANISALIGNEDL5  =>  PIPERXCHANISALIGNEDL5_indelay,
	PIPERXCHANISALIGNEDL6  =>  PIPERXCHANISALIGNEDL6_indelay,
	PIPERXCHANISALIGNEDL7  =>  PIPERXCHANISALIGNEDL7_indelay,
	PIPERXDATAKL0  =>  PIPERXDATAKL0_indelay,
	PIPERXDATAKL1  =>  PIPERXDATAKL1_indelay,
	PIPERXDATAKL2  =>  PIPERXDATAKL2_indelay,
	PIPERXDATAKL3  =>  PIPERXDATAKL3_indelay,
	PIPERXDATAKL4  =>  PIPERXDATAKL4_indelay,
	PIPERXDATAKL5  =>  PIPERXDATAKL5_indelay,
	PIPERXDATAKL6  =>  PIPERXDATAKL6_indelay,
	PIPERXDATAKL7  =>  PIPERXDATAKL7_indelay,
	PIPERXDATAL0  =>  PIPERXDATAL0_indelay,
	PIPERXDATAL1  =>  PIPERXDATAL1_indelay,
	PIPERXDATAL2  =>  PIPERXDATAL2_indelay,
	PIPERXDATAL3  =>  PIPERXDATAL3_indelay,
	PIPERXDATAL4  =>  PIPERXDATAL4_indelay,
	PIPERXDATAL5  =>  PIPERXDATAL5_indelay,
	PIPERXDATAL6  =>  PIPERXDATAL6_indelay,
	PIPERXDATAL7  =>  PIPERXDATAL7_indelay,
	PIPERXELECIDLEL0  =>  PIPERXELECIDLEL0_indelay,
	PIPERXELECIDLEL1  =>  PIPERXELECIDLEL1_indelay,
	PIPERXELECIDLEL2  =>  PIPERXELECIDLEL2_indelay,
	PIPERXELECIDLEL3  =>  PIPERXELECIDLEL3_indelay,
	PIPERXELECIDLEL4  =>  PIPERXELECIDLEL4_indelay,
	PIPERXELECIDLEL5  =>  PIPERXELECIDLEL5_indelay,
	PIPERXELECIDLEL6  =>  PIPERXELECIDLEL6_indelay,
	PIPERXELECIDLEL7  =>  PIPERXELECIDLEL7_indelay,
	PIPERXSTATUSL0  =>  PIPERXSTATUSL0_indelay,
	PIPERXSTATUSL1  =>  PIPERXSTATUSL1_indelay,
	PIPERXSTATUSL2  =>  PIPERXSTATUSL2_indelay,
	PIPERXSTATUSL3  =>  PIPERXSTATUSL3_indelay,
	PIPERXSTATUSL4  =>  PIPERXSTATUSL4_indelay,
	PIPERXSTATUSL5  =>  PIPERXSTATUSL5_indelay,
	PIPERXSTATUSL6  =>  PIPERXSTATUSL6_indelay,
	PIPERXSTATUSL7  =>  PIPERXSTATUSL7_indelay,
	PIPERXVALIDL0  =>  PIPERXVALIDL0_indelay,
	PIPERXVALIDL1  =>  PIPERXVALIDL1_indelay,
	PIPERXVALIDL2  =>  PIPERXVALIDL2_indelay,
	PIPERXVALIDL3  =>  PIPERXVALIDL3_indelay,
	PIPERXVALIDL4  =>  PIPERXVALIDL4_indelay,
	PIPERXVALIDL5  =>  PIPERXVALIDL5_indelay,
	PIPERXVALIDL6  =>  PIPERXVALIDL6_indelay,
	PIPERXVALIDL7  =>  PIPERXVALIDL7_indelay
	);

	INIPROC : process
	begin
       case TXTSNFTS is
           when   0  =>  TXTSNFTS_BINARY <= "00000000";
           when   1  =>  TXTSNFTS_BINARY <= "00000001";
           when   2  =>  TXTSNFTS_BINARY <= "00000010";
           when   3  =>  TXTSNFTS_BINARY <= "00000011";
           when   4  =>  TXTSNFTS_BINARY <= "00000100";
           when   5  =>  TXTSNFTS_BINARY <= "00000101";
           when   6  =>  TXTSNFTS_BINARY <= "00000110";
           when   7  =>  TXTSNFTS_BINARY <= "00000111";
           when   8  =>  TXTSNFTS_BINARY <= "00001000";
           when   9  =>  TXTSNFTS_BINARY <= "00001001";
           when   10  =>  TXTSNFTS_BINARY <= "00001010";
           when   11  =>  TXTSNFTS_BINARY <= "00001011";
           when   12  =>  TXTSNFTS_BINARY <= "00001100";
           when   13  =>  TXTSNFTS_BINARY <= "00001101";
           when   14  =>  TXTSNFTS_BINARY <= "00001110";
           when   15  =>  TXTSNFTS_BINARY <= "00001111";
           when   16  =>  TXTSNFTS_BINARY <= "00010000";
           when   17  =>  TXTSNFTS_BINARY <= "00010001";
           when   18  =>  TXTSNFTS_BINARY <= "00010010";
           when   19  =>  TXTSNFTS_BINARY <= "00010011";
           when   20  =>  TXTSNFTS_BINARY <= "00010100";
           when   21  =>  TXTSNFTS_BINARY <= "00010101";
           when   22  =>  TXTSNFTS_BINARY <= "00010110";
           when   23  =>  TXTSNFTS_BINARY <= "00010111";
           when   24  =>  TXTSNFTS_BINARY <= "00011000";
           when   25  =>  TXTSNFTS_BINARY <= "00011001";
           when   26  =>  TXTSNFTS_BINARY <= "00011010";
           when   27  =>  TXTSNFTS_BINARY <= "00011011";
           when   28  =>  TXTSNFTS_BINARY <= "00011100";
           when   29  =>  TXTSNFTS_BINARY <= "00011101";
           when   30  =>  TXTSNFTS_BINARY <= "00011110";
           when   31  =>  TXTSNFTS_BINARY <= "00011111";
           when   32  =>  TXTSNFTS_BINARY <= "00100000";
           when   33  =>  TXTSNFTS_BINARY <= "00100001";
           when   34  =>  TXTSNFTS_BINARY <= "00100010";
           when   35  =>  TXTSNFTS_BINARY <= "00100011";
           when   36  =>  TXTSNFTS_BINARY <= "00100100";
           when   37  =>  TXTSNFTS_BINARY <= "00100101";
           when   38  =>  TXTSNFTS_BINARY <= "00100110";
           when   39  =>  TXTSNFTS_BINARY <= "00100111";
           when   40  =>  TXTSNFTS_BINARY <= "00101000";
           when   41  =>  TXTSNFTS_BINARY <= "00101001";
           when   42  =>  TXTSNFTS_BINARY <= "00101010";
           when   43  =>  TXTSNFTS_BINARY <= "00101011";
           when   44  =>  TXTSNFTS_BINARY <= "00101100";
           when   45  =>  TXTSNFTS_BINARY <= "00101101";
           when   46  =>  TXTSNFTS_BINARY <= "00101110";
           when   47  =>  TXTSNFTS_BINARY <= "00101111";
           when   48  =>  TXTSNFTS_BINARY <= "00110000";
           when   49  =>  TXTSNFTS_BINARY <= "00110001";
           when   50  =>  TXTSNFTS_BINARY <= "00110010";
           when   51  =>  TXTSNFTS_BINARY <= "00110011";
           when   52  =>  TXTSNFTS_BINARY <= "00110100";
           when   53  =>  TXTSNFTS_BINARY <= "00110101";
           when   54  =>  TXTSNFTS_BINARY <= "00110110";
           when   55  =>  TXTSNFTS_BINARY <= "00110111";
           when   56  =>  TXTSNFTS_BINARY <= "00111000";
           when   57  =>  TXTSNFTS_BINARY <= "00111001";
           when   58  =>  TXTSNFTS_BINARY <= "00111010";
           when   59  =>  TXTSNFTS_BINARY <= "00111011";
           when   60  =>  TXTSNFTS_BINARY <= "00111100";
           when   61  =>  TXTSNFTS_BINARY <= "00111101";
           when   62  =>  TXTSNFTS_BINARY <= "00111110";
           when   63  =>  TXTSNFTS_BINARY <= "00111111";
           when   64  =>  TXTSNFTS_BINARY <= "01000000";
           when   65  =>  TXTSNFTS_BINARY <= "01000001";
           when   66  =>  TXTSNFTS_BINARY <= "01000010";
           when   67  =>  TXTSNFTS_BINARY <= "01000011";
           when   68  =>  TXTSNFTS_BINARY <= "01000100";
           when   69  =>  TXTSNFTS_BINARY <= "01000101";
           when   70  =>  TXTSNFTS_BINARY <= "01000110";
           when   71  =>  TXTSNFTS_BINARY <= "01000111";
           when   72  =>  TXTSNFTS_BINARY <= "01001000";
           when   73  =>  TXTSNFTS_BINARY <= "01001001";
           when   74  =>  TXTSNFTS_BINARY <= "01001010";
           when   75  =>  TXTSNFTS_BINARY <= "01001011";
           when   76  =>  TXTSNFTS_BINARY <= "01001100";
           when   77  =>  TXTSNFTS_BINARY <= "01001101";
           when   78  =>  TXTSNFTS_BINARY <= "01001110";
           when   79  =>  TXTSNFTS_BINARY <= "01001111";
           when   80  =>  TXTSNFTS_BINARY <= "01010000";
           when   81  =>  TXTSNFTS_BINARY <= "01010001";
           when   82  =>  TXTSNFTS_BINARY <= "01010010";
           when   83  =>  TXTSNFTS_BINARY <= "01010011";
           when   84  =>  TXTSNFTS_BINARY <= "01010100";
           when   85  =>  TXTSNFTS_BINARY <= "01010101";
           when   86  =>  TXTSNFTS_BINARY <= "01010110";
           when   87  =>  TXTSNFTS_BINARY <= "01010111";
           when   88  =>  TXTSNFTS_BINARY <= "01011000";
           when   89  =>  TXTSNFTS_BINARY <= "01011001";
           when   90  =>  TXTSNFTS_BINARY <= "01011010";
           when   91  =>  TXTSNFTS_BINARY <= "01011011";
           when   92  =>  TXTSNFTS_BINARY <= "01011100";
           when   93  =>  TXTSNFTS_BINARY <= "01011101";
           when   94  =>  TXTSNFTS_BINARY <= "01011110";
           when   95  =>  TXTSNFTS_BINARY <= "01011111";
           when   96  =>  TXTSNFTS_BINARY <= "01100000";
           when   97  =>  TXTSNFTS_BINARY <= "01100001";
           when   98  =>  TXTSNFTS_BINARY <= "01100010";
           when   99  =>  TXTSNFTS_BINARY <= "01100011";
           when   100  =>  TXTSNFTS_BINARY <= "01100100";
           when   101  =>  TXTSNFTS_BINARY <= "01100101";
           when   102  =>  TXTSNFTS_BINARY <= "01100110";
           when   103  =>  TXTSNFTS_BINARY <= "01100111";
           when   104  =>  TXTSNFTS_BINARY <= "01101000";
           when   105  =>  TXTSNFTS_BINARY <= "01101001";
           when   106  =>  TXTSNFTS_BINARY <= "01101010";
           when   107  =>  TXTSNFTS_BINARY <= "01101011";
           when   108  =>  TXTSNFTS_BINARY <= "01101100";
           when   109  =>  TXTSNFTS_BINARY <= "01101101";
           when   110  =>  TXTSNFTS_BINARY <= "01101110";
           when   111  =>  TXTSNFTS_BINARY <= "01101111";
           when   112  =>  TXTSNFTS_BINARY <= "01110000";
           when   113  =>  TXTSNFTS_BINARY <= "01110001";
           when   114  =>  TXTSNFTS_BINARY <= "01110010";
           when   115  =>  TXTSNFTS_BINARY <= "01110011";
           when   116  =>  TXTSNFTS_BINARY <= "01110100";
           when   117  =>  TXTSNFTS_BINARY <= "01110101";
           when   118  =>  TXTSNFTS_BINARY <= "01110110";
           when   119  =>  TXTSNFTS_BINARY <= "01110111";
           when   120  =>  TXTSNFTS_BINARY <= "01111000";
           when   121  =>  TXTSNFTS_BINARY <= "01111001";
           when   122  =>  TXTSNFTS_BINARY <= "01111010";
           when   123  =>  TXTSNFTS_BINARY <= "01111011";
           when   124  =>  TXTSNFTS_BINARY <= "01111100";
           when   125  =>  TXTSNFTS_BINARY <= "01111101";
           when   126  =>  TXTSNFTS_BINARY <= "01111110";
           when   127  =>  TXTSNFTS_BINARY <= "01111111";
           when   128  =>  TXTSNFTS_BINARY <= "10000000";
           when   129  =>  TXTSNFTS_BINARY <= "10000001";
           when   130  =>  TXTSNFTS_BINARY <= "10000010";
           when   131  =>  TXTSNFTS_BINARY <= "10000011";
           when   132  =>  TXTSNFTS_BINARY <= "10000100";
           when   133  =>  TXTSNFTS_BINARY <= "10000101";
           when   134  =>  TXTSNFTS_BINARY <= "10000110";
           when   135  =>  TXTSNFTS_BINARY <= "10000111";
           when   136  =>  TXTSNFTS_BINARY <= "10001000";
           when   137  =>  TXTSNFTS_BINARY <= "10001001";
           when   138  =>  TXTSNFTS_BINARY <= "10001010";
           when   139  =>  TXTSNFTS_BINARY <= "10001011";
           when   140  =>  TXTSNFTS_BINARY <= "10001100";
           when   141  =>  TXTSNFTS_BINARY <= "10001101";
           when   142  =>  TXTSNFTS_BINARY <= "10001110";
           when   143  =>  TXTSNFTS_BINARY <= "10001111";
           when   144  =>  TXTSNFTS_BINARY <= "10010000";
           when   145  =>  TXTSNFTS_BINARY <= "10010001";
           when   146  =>  TXTSNFTS_BINARY <= "10010010";
           when   147  =>  TXTSNFTS_BINARY <= "10010011";
           when   148  =>  TXTSNFTS_BINARY <= "10010100";
           when   149  =>  TXTSNFTS_BINARY <= "10010101";
           when   150  =>  TXTSNFTS_BINARY <= "10010110";
           when   151  =>  TXTSNFTS_BINARY <= "10010111";
           when   152  =>  TXTSNFTS_BINARY <= "10011000";
           when   153  =>  TXTSNFTS_BINARY <= "10011001";
           when   154  =>  TXTSNFTS_BINARY <= "10011010";
           when   155  =>  TXTSNFTS_BINARY <= "10011011";
           when   156  =>  TXTSNFTS_BINARY <= "10011100";
           when   157  =>  TXTSNFTS_BINARY <= "10011101";
           when   158  =>  TXTSNFTS_BINARY <= "10011110";
           when   159  =>  TXTSNFTS_BINARY <= "10011111";
           when   160  =>  TXTSNFTS_BINARY <= "10100000";
           when   161  =>  TXTSNFTS_BINARY <= "10100001";
           when   162  =>  TXTSNFTS_BINARY <= "10100010";
           when   163  =>  TXTSNFTS_BINARY <= "10100011";
           when   164  =>  TXTSNFTS_BINARY <= "10100100";
           when   165  =>  TXTSNFTS_BINARY <= "10100101";
           when   166  =>  TXTSNFTS_BINARY <= "10100110";
           when   167  =>  TXTSNFTS_BINARY <= "10100111";
           when   168  =>  TXTSNFTS_BINARY <= "10101000";
           when   169  =>  TXTSNFTS_BINARY <= "10101001";
           when   170  =>  TXTSNFTS_BINARY <= "10101010";
           when   171  =>  TXTSNFTS_BINARY <= "10101011";
           when   172  =>  TXTSNFTS_BINARY <= "10101100";
           when   173  =>  TXTSNFTS_BINARY <= "10101101";
           when   174  =>  TXTSNFTS_BINARY <= "10101110";
           when   175  =>  TXTSNFTS_BINARY <= "10101111";
           when   176  =>  TXTSNFTS_BINARY <= "10110000";
           when   177  =>  TXTSNFTS_BINARY <= "10110001";
           when   178  =>  TXTSNFTS_BINARY <= "10110010";
           when   179  =>  TXTSNFTS_BINARY <= "10110011";
           when   180  =>  TXTSNFTS_BINARY <= "10110100";
           when   181  =>  TXTSNFTS_BINARY <= "10110101";
           when   182  =>  TXTSNFTS_BINARY <= "10110110";
           when   183  =>  TXTSNFTS_BINARY <= "10110111";
           when   184  =>  TXTSNFTS_BINARY <= "10111000";
           when   185  =>  TXTSNFTS_BINARY <= "10111001";
           when   186  =>  TXTSNFTS_BINARY <= "10111010";
           when   187  =>  TXTSNFTS_BINARY <= "10111011";
           when   188  =>  TXTSNFTS_BINARY <= "10111100";
           when   189  =>  TXTSNFTS_BINARY <= "10111101";
           when   190  =>  TXTSNFTS_BINARY <= "10111110";
           when   191  =>  TXTSNFTS_BINARY <= "10111111";
           when   192  =>  TXTSNFTS_BINARY <= "11000000";
           when   193  =>  TXTSNFTS_BINARY <= "11000001";
           when   194  =>  TXTSNFTS_BINARY <= "11000010";
           when   195  =>  TXTSNFTS_BINARY <= "11000011";
           when   196  =>  TXTSNFTS_BINARY <= "11000100";
           when   197  =>  TXTSNFTS_BINARY <= "11000101";
           when   198  =>  TXTSNFTS_BINARY <= "11000110";
           when   199  =>  TXTSNFTS_BINARY <= "11000111";
           when   200  =>  TXTSNFTS_BINARY <= "11001000";
           when   201  =>  TXTSNFTS_BINARY <= "11001001";
           when   202  =>  TXTSNFTS_BINARY <= "11001010";
           when   203  =>  TXTSNFTS_BINARY <= "11001011";
           when   204  =>  TXTSNFTS_BINARY <= "11001100";
           when   205  =>  TXTSNFTS_BINARY <= "11001101";
           when   206  =>  TXTSNFTS_BINARY <= "11001110";
           when   207  =>  TXTSNFTS_BINARY <= "11001111";
           when   208  =>  TXTSNFTS_BINARY <= "11010000";
           when   209  =>  TXTSNFTS_BINARY <= "11010001";
           when   210  =>  TXTSNFTS_BINARY <= "11010010";
           when   211  =>  TXTSNFTS_BINARY <= "11010011";
           when   212  =>  TXTSNFTS_BINARY <= "11010100";
           when   213  =>  TXTSNFTS_BINARY <= "11010101";
           when   214  =>  TXTSNFTS_BINARY <= "11010110";
           when   215  =>  TXTSNFTS_BINARY <= "11010111";
           when   216  =>  TXTSNFTS_BINARY <= "11011000";
           when   217  =>  TXTSNFTS_BINARY <= "11011001";
           when   218  =>  TXTSNFTS_BINARY <= "11011010";
           when   219  =>  TXTSNFTS_BINARY <= "11011011";
           when   220  =>  TXTSNFTS_BINARY <= "11011100";
           when   221  =>  TXTSNFTS_BINARY <= "11011101";
           when   222  =>  TXTSNFTS_BINARY <= "11011110";
           when   223  =>  TXTSNFTS_BINARY <= "11011111";
           when   224  =>  TXTSNFTS_BINARY <= "11100000";
           when   225  =>  TXTSNFTS_BINARY <= "11100001";
           when   226  =>  TXTSNFTS_BINARY <= "11100010";
           when   227  =>  TXTSNFTS_BINARY <= "11100011";
           when   228  =>  TXTSNFTS_BINARY <= "11100100";
           when   229  =>  TXTSNFTS_BINARY <= "11100101";
           when   230  =>  TXTSNFTS_BINARY <= "11100110";
           when   231  =>  TXTSNFTS_BINARY <= "11100111";
           when   232  =>  TXTSNFTS_BINARY <= "11101000";
           when   233  =>  TXTSNFTS_BINARY <= "11101001";
           when   234  =>  TXTSNFTS_BINARY <= "11101010";
           when   235  =>  TXTSNFTS_BINARY <= "11101011";
           when   236  =>  TXTSNFTS_BINARY <= "11101100";
           when   237  =>  TXTSNFTS_BINARY <= "11101101";
           when   238  =>  TXTSNFTS_BINARY <= "11101110";
           when   239  =>  TXTSNFTS_BINARY <= "11101111";
           when   240  =>  TXTSNFTS_BINARY <= "11110000";
           when   241  =>  TXTSNFTS_BINARY <= "11110001";
           when   242  =>  TXTSNFTS_BINARY <= "11110010";
           when   243  =>  TXTSNFTS_BINARY <= "11110011";
           when   244  =>  TXTSNFTS_BINARY <= "11110100";
           when   245  =>  TXTSNFTS_BINARY <= "11110101";
           when   246  =>  TXTSNFTS_BINARY <= "11110110";
           when   247  =>  TXTSNFTS_BINARY <= "11110111";
           when   248  =>  TXTSNFTS_BINARY <= "11111000";
           when   249  =>  TXTSNFTS_BINARY <= "11111001";
           when   250  =>  TXTSNFTS_BINARY <= "11111010";
           when   251  =>  TXTSNFTS_BINARY <= "11111011";
           when   252  =>  TXTSNFTS_BINARY <= "11111100";
           when   253  =>  TXTSNFTS_BINARY <= "11111101";
           when   254  =>  TXTSNFTS_BINARY <= "11111110";
           when   255  =>  TXTSNFTS_BINARY <= "11111111";
           when others  =>  assert FALSE report "Error : TXTSNFTS is not in range 0...255." severity error;
       end case;
       case TXTSNFTSCOMCLK is
           when   0  =>  TXTSNFTSCOMCLK_BINARY <= "00000000";
           when   1  =>  TXTSNFTSCOMCLK_BINARY <= "00000001";
           when   2  =>  TXTSNFTSCOMCLK_BINARY <= "00000010";
           when   3  =>  TXTSNFTSCOMCLK_BINARY <= "00000011";
           when   4  =>  TXTSNFTSCOMCLK_BINARY <= "00000100";
           when   5  =>  TXTSNFTSCOMCLK_BINARY <= "00000101";
           when   6  =>  TXTSNFTSCOMCLK_BINARY <= "00000110";
           when   7  =>  TXTSNFTSCOMCLK_BINARY <= "00000111";
           when   8  =>  TXTSNFTSCOMCLK_BINARY <= "00001000";
           when   9  =>  TXTSNFTSCOMCLK_BINARY <= "00001001";
           when   10  =>  TXTSNFTSCOMCLK_BINARY <= "00001010";
           when   11  =>  TXTSNFTSCOMCLK_BINARY <= "00001011";
           when   12  =>  TXTSNFTSCOMCLK_BINARY <= "00001100";
           when   13  =>  TXTSNFTSCOMCLK_BINARY <= "00001101";
           when   14  =>  TXTSNFTSCOMCLK_BINARY <= "00001110";
           when   15  =>  TXTSNFTSCOMCLK_BINARY <= "00001111";
           when   16  =>  TXTSNFTSCOMCLK_BINARY <= "00010000";
           when   17  =>  TXTSNFTSCOMCLK_BINARY <= "00010001";
           when   18  =>  TXTSNFTSCOMCLK_BINARY <= "00010010";
           when   19  =>  TXTSNFTSCOMCLK_BINARY <= "00010011";
           when   20  =>  TXTSNFTSCOMCLK_BINARY <= "00010100";
           when   21  =>  TXTSNFTSCOMCLK_BINARY <= "00010101";
           when   22  =>  TXTSNFTSCOMCLK_BINARY <= "00010110";
           when   23  =>  TXTSNFTSCOMCLK_BINARY <= "00010111";
           when   24  =>  TXTSNFTSCOMCLK_BINARY <= "00011000";
           when   25  =>  TXTSNFTSCOMCLK_BINARY <= "00011001";
           when   26  =>  TXTSNFTSCOMCLK_BINARY <= "00011010";
           when   27  =>  TXTSNFTSCOMCLK_BINARY <= "00011011";
           when   28  =>  TXTSNFTSCOMCLK_BINARY <= "00011100";
           when   29  =>  TXTSNFTSCOMCLK_BINARY <= "00011101";
           when   30  =>  TXTSNFTSCOMCLK_BINARY <= "00011110";
           when   31  =>  TXTSNFTSCOMCLK_BINARY <= "00011111";
           when   32  =>  TXTSNFTSCOMCLK_BINARY <= "00100000";
           when   33  =>  TXTSNFTSCOMCLK_BINARY <= "00100001";
           when   34  =>  TXTSNFTSCOMCLK_BINARY <= "00100010";
           when   35  =>  TXTSNFTSCOMCLK_BINARY <= "00100011";
           when   36  =>  TXTSNFTSCOMCLK_BINARY <= "00100100";
           when   37  =>  TXTSNFTSCOMCLK_BINARY <= "00100101";
           when   38  =>  TXTSNFTSCOMCLK_BINARY <= "00100110";
           when   39  =>  TXTSNFTSCOMCLK_BINARY <= "00100111";
           when   40  =>  TXTSNFTSCOMCLK_BINARY <= "00101000";
           when   41  =>  TXTSNFTSCOMCLK_BINARY <= "00101001";
           when   42  =>  TXTSNFTSCOMCLK_BINARY <= "00101010";
           when   43  =>  TXTSNFTSCOMCLK_BINARY <= "00101011";
           when   44  =>  TXTSNFTSCOMCLK_BINARY <= "00101100";
           when   45  =>  TXTSNFTSCOMCLK_BINARY <= "00101101";
           when   46  =>  TXTSNFTSCOMCLK_BINARY <= "00101110";
           when   47  =>  TXTSNFTSCOMCLK_BINARY <= "00101111";
           when   48  =>  TXTSNFTSCOMCLK_BINARY <= "00110000";
           when   49  =>  TXTSNFTSCOMCLK_BINARY <= "00110001";
           when   50  =>  TXTSNFTSCOMCLK_BINARY <= "00110010";
           when   51  =>  TXTSNFTSCOMCLK_BINARY <= "00110011";
           when   52  =>  TXTSNFTSCOMCLK_BINARY <= "00110100";
           when   53  =>  TXTSNFTSCOMCLK_BINARY <= "00110101";
           when   54  =>  TXTSNFTSCOMCLK_BINARY <= "00110110";
           when   55  =>  TXTSNFTSCOMCLK_BINARY <= "00110111";
           when   56  =>  TXTSNFTSCOMCLK_BINARY <= "00111000";
           when   57  =>  TXTSNFTSCOMCLK_BINARY <= "00111001";
           when   58  =>  TXTSNFTSCOMCLK_BINARY <= "00111010";
           when   59  =>  TXTSNFTSCOMCLK_BINARY <= "00111011";
           when   60  =>  TXTSNFTSCOMCLK_BINARY <= "00111100";
           when   61  =>  TXTSNFTSCOMCLK_BINARY <= "00111101";
           when   62  =>  TXTSNFTSCOMCLK_BINARY <= "00111110";
           when   63  =>  TXTSNFTSCOMCLK_BINARY <= "00111111";
           when   64  =>  TXTSNFTSCOMCLK_BINARY <= "01000000";
           when   65  =>  TXTSNFTSCOMCLK_BINARY <= "01000001";
           when   66  =>  TXTSNFTSCOMCLK_BINARY <= "01000010";
           when   67  =>  TXTSNFTSCOMCLK_BINARY <= "01000011";
           when   68  =>  TXTSNFTSCOMCLK_BINARY <= "01000100";
           when   69  =>  TXTSNFTSCOMCLK_BINARY <= "01000101";
           when   70  =>  TXTSNFTSCOMCLK_BINARY <= "01000110";
           when   71  =>  TXTSNFTSCOMCLK_BINARY <= "01000111";
           when   72  =>  TXTSNFTSCOMCLK_BINARY <= "01001000";
           when   73  =>  TXTSNFTSCOMCLK_BINARY <= "01001001";
           when   74  =>  TXTSNFTSCOMCLK_BINARY <= "01001010";
           when   75  =>  TXTSNFTSCOMCLK_BINARY <= "01001011";
           when   76  =>  TXTSNFTSCOMCLK_BINARY <= "01001100";
           when   77  =>  TXTSNFTSCOMCLK_BINARY <= "01001101";
           when   78  =>  TXTSNFTSCOMCLK_BINARY <= "01001110";
           when   79  =>  TXTSNFTSCOMCLK_BINARY <= "01001111";
           when   80  =>  TXTSNFTSCOMCLK_BINARY <= "01010000";
           when   81  =>  TXTSNFTSCOMCLK_BINARY <= "01010001";
           when   82  =>  TXTSNFTSCOMCLK_BINARY <= "01010010";
           when   83  =>  TXTSNFTSCOMCLK_BINARY <= "01010011";
           when   84  =>  TXTSNFTSCOMCLK_BINARY <= "01010100";
           when   85  =>  TXTSNFTSCOMCLK_BINARY <= "01010101";
           when   86  =>  TXTSNFTSCOMCLK_BINARY <= "01010110";
           when   87  =>  TXTSNFTSCOMCLK_BINARY <= "01010111";
           when   88  =>  TXTSNFTSCOMCLK_BINARY <= "01011000";
           when   89  =>  TXTSNFTSCOMCLK_BINARY <= "01011001";
           when   90  =>  TXTSNFTSCOMCLK_BINARY <= "01011010";
           when   91  =>  TXTSNFTSCOMCLK_BINARY <= "01011011";
           when   92  =>  TXTSNFTSCOMCLK_BINARY <= "01011100";
           when   93  =>  TXTSNFTSCOMCLK_BINARY <= "01011101";
           when   94  =>  TXTSNFTSCOMCLK_BINARY <= "01011110";
           when   95  =>  TXTSNFTSCOMCLK_BINARY <= "01011111";
           when   96  =>  TXTSNFTSCOMCLK_BINARY <= "01100000";
           when   97  =>  TXTSNFTSCOMCLK_BINARY <= "01100001";
           when   98  =>  TXTSNFTSCOMCLK_BINARY <= "01100010";
           when   99  =>  TXTSNFTSCOMCLK_BINARY <= "01100011";
           when   100  =>  TXTSNFTSCOMCLK_BINARY <= "01100100";
           when   101  =>  TXTSNFTSCOMCLK_BINARY <= "01100101";
           when   102  =>  TXTSNFTSCOMCLK_BINARY <= "01100110";
           when   103  =>  TXTSNFTSCOMCLK_BINARY <= "01100111";
           when   104  =>  TXTSNFTSCOMCLK_BINARY <= "01101000";
           when   105  =>  TXTSNFTSCOMCLK_BINARY <= "01101001";
           when   106  =>  TXTSNFTSCOMCLK_BINARY <= "01101010";
           when   107  =>  TXTSNFTSCOMCLK_BINARY <= "01101011";
           when   108  =>  TXTSNFTSCOMCLK_BINARY <= "01101100";
           when   109  =>  TXTSNFTSCOMCLK_BINARY <= "01101101";
           when   110  =>  TXTSNFTSCOMCLK_BINARY <= "01101110";
           when   111  =>  TXTSNFTSCOMCLK_BINARY <= "01101111";
           when   112  =>  TXTSNFTSCOMCLK_BINARY <= "01110000";
           when   113  =>  TXTSNFTSCOMCLK_BINARY <= "01110001";
           when   114  =>  TXTSNFTSCOMCLK_BINARY <= "01110010";
           when   115  =>  TXTSNFTSCOMCLK_BINARY <= "01110011";
           when   116  =>  TXTSNFTSCOMCLK_BINARY <= "01110100";
           when   117  =>  TXTSNFTSCOMCLK_BINARY <= "01110101";
           when   118  =>  TXTSNFTSCOMCLK_BINARY <= "01110110";
           when   119  =>  TXTSNFTSCOMCLK_BINARY <= "01110111";
           when   120  =>  TXTSNFTSCOMCLK_BINARY <= "01111000";
           when   121  =>  TXTSNFTSCOMCLK_BINARY <= "01111001";
           when   122  =>  TXTSNFTSCOMCLK_BINARY <= "01111010";
           when   123  =>  TXTSNFTSCOMCLK_BINARY <= "01111011";
           when   124  =>  TXTSNFTSCOMCLK_BINARY <= "01111100";
           when   125  =>  TXTSNFTSCOMCLK_BINARY <= "01111101";
           when   126  =>  TXTSNFTSCOMCLK_BINARY <= "01111110";
           when   127  =>  TXTSNFTSCOMCLK_BINARY <= "01111111";
           when   128  =>  TXTSNFTSCOMCLK_BINARY <= "10000000";
           when   129  =>  TXTSNFTSCOMCLK_BINARY <= "10000001";
           when   130  =>  TXTSNFTSCOMCLK_BINARY <= "10000010";
           when   131  =>  TXTSNFTSCOMCLK_BINARY <= "10000011";
           when   132  =>  TXTSNFTSCOMCLK_BINARY <= "10000100";
           when   133  =>  TXTSNFTSCOMCLK_BINARY <= "10000101";
           when   134  =>  TXTSNFTSCOMCLK_BINARY <= "10000110";
           when   135  =>  TXTSNFTSCOMCLK_BINARY <= "10000111";
           when   136  =>  TXTSNFTSCOMCLK_BINARY <= "10001000";
           when   137  =>  TXTSNFTSCOMCLK_BINARY <= "10001001";
           when   138  =>  TXTSNFTSCOMCLK_BINARY <= "10001010";
           when   139  =>  TXTSNFTSCOMCLK_BINARY <= "10001011";
           when   140  =>  TXTSNFTSCOMCLK_BINARY <= "10001100";
           when   141  =>  TXTSNFTSCOMCLK_BINARY <= "10001101";
           when   142  =>  TXTSNFTSCOMCLK_BINARY <= "10001110";
           when   143  =>  TXTSNFTSCOMCLK_BINARY <= "10001111";
           when   144  =>  TXTSNFTSCOMCLK_BINARY <= "10010000";
           when   145  =>  TXTSNFTSCOMCLK_BINARY <= "10010001";
           when   146  =>  TXTSNFTSCOMCLK_BINARY <= "10010010";
           when   147  =>  TXTSNFTSCOMCLK_BINARY <= "10010011";
           when   148  =>  TXTSNFTSCOMCLK_BINARY <= "10010100";
           when   149  =>  TXTSNFTSCOMCLK_BINARY <= "10010101";
           when   150  =>  TXTSNFTSCOMCLK_BINARY <= "10010110";
           when   151  =>  TXTSNFTSCOMCLK_BINARY <= "10010111";
           when   152  =>  TXTSNFTSCOMCLK_BINARY <= "10011000";
           when   153  =>  TXTSNFTSCOMCLK_BINARY <= "10011001";
           when   154  =>  TXTSNFTSCOMCLK_BINARY <= "10011010";
           when   155  =>  TXTSNFTSCOMCLK_BINARY <= "10011011";
           when   156  =>  TXTSNFTSCOMCLK_BINARY <= "10011100";
           when   157  =>  TXTSNFTSCOMCLK_BINARY <= "10011101";
           when   158  =>  TXTSNFTSCOMCLK_BINARY <= "10011110";
           when   159  =>  TXTSNFTSCOMCLK_BINARY <= "10011111";
           when   160  =>  TXTSNFTSCOMCLK_BINARY <= "10100000";
           when   161  =>  TXTSNFTSCOMCLK_BINARY <= "10100001";
           when   162  =>  TXTSNFTSCOMCLK_BINARY <= "10100010";
           when   163  =>  TXTSNFTSCOMCLK_BINARY <= "10100011";
           when   164  =>  TXTSNFTSCOMCLK_BINARY <= "10100100";
           when   165  =>  TXTSNFTSCOMCLK_BINARY <= "10100101";
           when   166  =>  TXTSNFTSCOMCLK_BINARY <= "10100110";
           when   167  =>  TXTSNFTSCOMCLK_BINARY <= "10100111";
           when   168  =>  TXTSNFTSCOMCLK_BINARY <= "10101000";
           when   169  =>  TXTSNFTSCOMCLK_BINARY <= "10101001";
           when   170  =>  TXTSNFTSCOMCLK_BINARY <= "10101010";
           when   171  =>  TXTSNFTSCOMCLK_BINARY <= "10101011";
           when   172  =>  TXTSNFTSCOMCLK_BINARY <= "10101100";
           when   173  =>  TXTSNFTSCOMCLK_BINARY <= "10101101";
           when   174  =>  TXTSNFTSCOMCLK_BINARY <= "10101110";
           when   175  =>  TXTSNFTSCOMCLK_BINARY <= "10101111";
           when   176  =>  TXTSNFTSCOMCLK_BINARY <= "10110000";
           when   177  =>  TXTSNFTSCOMCLK_BINARY <= "10110001";
           when   178  =>  TXTSNFTSCOMCLK_BINARY <= "10110010";
           when   179  =>  TXTSNFTSCOMCLK_BINARY <= "10110011";
           when   180  =>  TXTSNFTSCOMCLK_BINARY <= "10110100";
           when   181  =>  TXTSNFTSCOMCLK_BINARY <= "10110101";
           when   182  =>  TXTSNFTSCOMCLK_BINARY <= "10110110";
           when   183  =>  TXTSNFTSCOMCLK_BINARY <= "10110111";
           when   184  =>  TXTSNFTSCOMCLK_BINARY <= "10111000";
           when   185  =>  TXTSNFTSCOMCLK_BINARY <= "10111001";
           when   186  =>  TXTSNFTSCOMCLK_BINARY <= "10111010";
           when   187  =>  TXTSNFTSCOMCLK_BINARY <= "10111011";
           when   188  =>  TXTSNFTSCOMCLK_BINARY <= "10111100";
           when   189  =>  TXTSNFTSCOMCLK_BINARY <= "10111101";
           when   190  =>  TXTSNFTSCOMCLK_BINARY <= "10111110";
           when   191  =>  TXTSNFTSCOMCLK_BINARY <= "10111111";
           when   192  =>  TXTSNFTSCOMCLK_BINARY <= "11000000";
           when   193  =>  TXTSNFTSCOMCLK_BINARY <= "11000001";
           when   194  =>  TXTSNFTSCOMCLK_BINARY <= "11000010";
           when   195  =>  TXTSNFTSCOMCLK_BINARY <= "11000011";
           when   196  =>  TXTSNFTSCOMCLK_BINARY <= "11000100";
           when   197  =>  TXTSNFTSCOMCLK_BINARY <= "11000101";
           when   198  =>  TXTSNFTSCOMCLK_BINARY <= "11000110";
           when   199  =>  TXTSNFTSCOMCLK_BINARY <= "11000111";
           when   200  =>  TXTSNFTSCOMCLK_BINARY <= "11001000";
           when   201  =>  TXTSNFTSCOMCLK_BINARY <= "11001001";
           when   202  =>  TXTSNFTSCOMCLK_BINARY <= "11001010";
           when   203  =>  TXTSNFTSCOMCLK_BINARY <= "11001011";
           when   204  =>  TXTSNFTSCOMCLK_BINARY <= "11001100";
           when   205  =>  TXTSNFTSCOMCLK_BINARY <= "11001101";
           when   206  =>  TXTSNFTSCOMCLK_BINARY <= "11001110";
           when   207  =>  TXTSNFTSCOMCLK_BINARY <= "11001111";
           when   208  =>  TXTSNFTSCOMCLK_BINARY <= "11010000";
           when   209  =>  TXTSNFTSCOMCLK_BINARY <= "11010001";
           when   210  =>  TXTSNFTSCOMCLK_BINARY <= "11010010";
           when   211  =>  TXTSNFTSCOMCLK_BINARY <= "11010011";
           when   212  =>  TXTSNFTSCOMCLK_BINARY <= "11010100";
           when   213  =>  TXTSNFTSCOMCLK_BINARY <= "11010101";
           when   214  =>  TXTSNFTSCOMCLK_BINARY <= "11010110";
           when   215  =>  TXTSNFTSCOMCLK_BINARY <= "11010111";
           when   216  =>  TXTSNFTSCOMCLK_BINARY <= "11011000";
           when   217  =>  TXTSNFTSCOMCLK_BINARY <= "11011001";
           when   218  =>  TXTSNFTSCOMCLK_BINARY <= "11011010";
           when   219  =>  TXTSNFTSCOMCLK_BINARY <= "11011011";
           when   220  =>  TXTSNFTSCOMCLK_BINARY <= "11011100";
           when   221  =>  TXTSNFTSCOMCLK_BINARY <= "11011101";
           when   222  =>  TXTSNFTSCOMCLK_BINARY <= "11011110";
           when   223  =>  TXTSNFTSCOMCLK_BINARY <= "11011111";
           when   224  =>  TXTSNFTSCOMCLK_BINARY <= "11100000";
           when   225  =>  TXTSNFTSCOMCLK_BINARY <= "11100001";
           when   226  =>  TXTSNFTSCOMCLK_BINARY <= "11100010";
           when   227  =>  TXTSNFTSCOMCLK_BINARY <= "11100011";
           when   228  =>  TXTSNFTSCOMCLK_BINARY <= "11100100";
           when   229  =>  TXTSNFTSCOMCLK_BINARY <= "11100101";
           when   230  =>  TXTSNFTSCOMCLK_BINARY <= "11100110";
           when   231  =>  TXTSNFTSCOMCLK_BINARY <= "11100111";
           when   232  =>  TXTSNFTSCOMCLK_BINARY <= "11101000";
           when   233  =>  TXTSNFTSCOMCLK_BINARY <= "11101001";
           when   234  =>  TXTSNFTSCOMCLK_BINARY <= "11101010";
           when   235  =>  TXTSNFTSCOMCLK_BINARY <= "11101011";
           when   236  =>  TXTSNFTSCOMCLK_BINARY <= "11101100";
           when   237  =>  TXTSNFTSCOMCLK_BINARY <= "11101101";
           when   238  =>  TXTSNFTSCOMCLK_BINARY <= "11101110";
           when   239  =>  TXTSNFTSCOMCLK_BINARY <= "11101111";
           when   240  =>  TXTSNFTSCOMCLK_BINARY <= "11110000";
           when   241  =>  TXTSNFTSCOMCLK_BINARY <= "11110001";
           when   242  =>  TXTSNFTSCOMCLK_BINARY <= "11110010";
           when   243  =>  TXTSNFTSCOMCLK_BINARY <= "11110011";
           when   244  =>  TXTSNFTSCOMCLK_BINARY <= "11110100";
           when   245  =>  TXTSNFTSCOMCLK_BINARY <= "11110101";
           when   246  =>  TXTSNFTSCOMCLK_BINARY <= "11110110";
           when   247  =>  TXTSNFTSCOMCLK_BINARY <= "11110111";
           when   248  =>  TXTSNFTSCOMCLK_BINARY <= "11111000";
           when   249  =>  TXTSNFTSCOMCLK_BINARY <= "11111001";
           when   250  =>  TXTSNFTSCOMCLK_BINARY <= "11111010";
           when   251  =>  TXTSNFTSCOMCLK_BINARY <= "11111011";
           when   252  =>  TXTSNFTSCOMCLK_BINARY <= "11111100";
           when   253  =>  TXTSNFTSCOMCLK_BINARY <= "11111101";
           when   254  =>  TXTSNFTSCOMCLK_BINARY <= "11111110";
           when   255  =>  TXTSNFTSCOMCLK_BINARY <= "11111111";
           when others  =>  assert FALSE report "Error : TXTSNFTSCOMCLK is not in range 0...255." severity error;
       end case;
       case RETRYRAMREADLATENCY is
           when   0  =>  RETRYRAMREADLATENCY_BINARY <= "000";
           when   1  =>  RETRYRAMREADLATENCY_BINARY <= "001";
           when   2  =>  RETRYRAMREADLATENCY_BINARY <= "010";
           when   3  =>  RETRYRAMREADLATENCY_BINARY <= "011";
           when   4  =>  RETRYRAMREADLATENCY_BINARY <= "100";
           when   5  =>  RETRYRAMREADLATENCY_BINARY <= "101";
           when   6  =>  RETRYRAMREADLATENCY_BINARY <= "110";
           when   7  =>  RETRYRAMREADLATENCY_BINARY <= "111";
           when others  =>  assert FALSE report "Error : RETRYRAMREADLATENCY is not in range 0...7." severity error;
       end case;
       case RETRYRAMWRITELATENCY is
           when   0  =>  RETRYRAMWRITELATENCY_BINARY <= "000";
           when   1  =>  RETRYRAMWRITELATENCY_BINARY <= "001";
           when   2  =>  RETRYRAMWRITELATENCY_BINARY <= "010";
           when   3  =>  RETRYRAMWRITELATENCY_BINARY <= "011";
           when   4  =>  RETRYRAMWRITELATENCY_BINARY <= "100";
           when   5  =>  RETRYRAMWRITELATENCY_BINARY <= "101";
           when   6  =>  RETRYRAMWRITELATENCY_BINARY <= "110";
           when   7  =>  RETRYRAMWRITELATENCY_BINARY <= "111";
           when others  =>  assert FALSE report "Error : RETRYRAMWRITELATENCY is not in range 0...7." severity error;
       end case;
       case RETRYRAMWIDTH is
           when   0  =>  RETRYRAMWIDTH_BINARY <= '0';
           when   1  =>  RETRYRAMWIDTH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RETRYRAMWIDTH is not in range 0...1." severity error;
       end case;
       case RETRYWRITEPIPE is
           when FALSE   =>  RETRYWRITEPIPE_BINARY <= '0';
           when TRUE    =>  RETRYWRITEPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RETRYWRITEPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case RETRYREADADDRPIPE is
           when FALSE   =>  RETRYREADADDRPIPE_BINARY <= '0';
           when TRUE    =>  RETRYREADADDRPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RETRYREADADDRPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case RETRYREADDATAPIPE is
           when FALSE   =>  RETRYREADDATAPIPE_BINARY <= '0';
           when TRUE    =>  RETRYREADDATAPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RETRYREADDATAPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case XLINKSUPPORTED is
           when FALSE   =>  XLINKSUPPORTED_BINARY <= '0';
           when TRUE    =>  XLINKSUPPORTED_BINARY <= '1';
           when others  =>  assert FALSE report "Error : XLINKSUPPORTED is neither TRUE nor FALSE." severity error;
       end case;
       case INFINITECOMPLETIONS is
           when FALSE   =>  INFINITECOMPLETIONS_BINARY <= '0';
           when TRUE    =>  INFINITECOMPLETIONS_BINARY <= '1';
           when others  =>  assert FALSE report "Error : INFINITECOMPLETIONS is neither TRUE nor FALSE." severity error;
       end case;
       case TLRAMREADLATENCY is
           when   0  =>  TLRAMREADLATENCY_BINARY <= "000";
           when   1  =>  TLRAMREADLATENCY_BINARY <= "001";
           when   2  =>  TLRAMREADLATENCY_BINARY <= "010";
           when   3  =>  TLRAMREADLATENCY_BINARY <= "011";
           when   4  =>  TLRAMREADLATENCY_BINARY <= "100";
           when   5  =>  TLRAMREADLATENCY_BINARY <= "101";
           when   6  =>  TLRAMREADLATENCY_BINARY <= "110";
           when   7  =>  TLRAMREADLATENCY_BINARY <= "111";
           when others  =>  assert FALSE report "Error : TLRAMREADLATENCY is not in range 0...7." severity error;
       end case;
       case TLRAMWRITELATENCY is
           when   0  =>  TLRAMWRITELATENCY_BINARY <= "000";
           when   1  =>  TLRAMWRITELATENCY_BINARY <= "001";
           when   2  =>  TLRAMWRITELATENCY_BINARY <= "010";
           when   3  =>  TLRAMWRITELATENCY_BINARY <= "011";
           when   4  =>  TLRAMWRITELATENCY_BINARY <= "100";
           when   5  =>  TLRAMWRITELATENCY_BINARY <= "101";
           when   6  =>  TLRAMWRITELATENCY_BINARY <= "110";
           when   7  =>  TLRAMWRITELATENCY_BINARY <= "111";
           when others  =>  assert FALSE report "Error : TLRAMWRITELATENCY is not in range 0...7." severity error;
       end case;
       case TLRAMWIDTH is
           when   0  =>  TLRAMWIDTH_BINARY <= '0';
           when   1  =>  TLRAMWIDTH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TLRAMWIDTH is not in range 0...1." severity error;
       end case;
       case RAMSHARETXRX is
           when FALSE   =>  RAMSHARETXRX_BINARY <= '0';
           when TRUE    =>  RAMSHARETXRX_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RAMSHARETXRX is neither TRUE nor FALSE." severity error;
       end case;
       case L0SEXITLATENCY is
           when   0  =>  L0SEXITLATENCY_BINARY <= "000";
           when   1  =>  L0SEXITLATENCY_BINARY <= "001";
           when   2  =>  L0SEXITLATENCY_BINARY <= "010";
           when   3  =>  L0SEXITLATENCY_BINARY <= "011";
           when   4  =>  L0SEXITLATENCY_BINARY <= "100";
           when   5  =>  L0SEXITLATENCY_BINARY <= "101";
           when   6  =>  L0SEXITLATENCY_BINARY <= "110";
           when   7  =>  L0SEXITLATENCY_BINARY <= "111";
           when others  =>  assert FALSE report "Error : L0SEXITLATENCY is not in range 0...7." severity error;
       end case;
       case L0SEXITLATENCYCOMCLK is
           when   0  =>  L0SEXITLATENCYCOMCLK_BINARY <= "000";
           when   1  =>  L0SEXITLATENCYCOMCLK_BINARY <= "001";
           when   2  =>  L0SEXITLATENCYCOMCLK_BINARY <= "010";
           when   3  =>  L0SEXITLATENCYCOMCLK_BINARY <= "011";
           when   4  =>  L0SEXITLATENCYCOMCLK_BINARY <= "100";
           when   5  =>  L0SEXITLATENCYCOMCLK_BINARY <= "101";
           when   6  =>  L0SEXITLATENCYCOMCLK_BINARY <= "110";
           when   7  =>  L0SEXITLATENCYCOMCLK_BINARY <= "111";
           when others  =>  assert FALSE report "Error : L0SEXITLATENCYCOMCLK is not in range 0...7." severity error;
       end case;
       case L1EXITLATENCY is
           when   0  =>  L1EXITLATENCY_BINARY <= "000";
           when   1  =>  L1EXITLATENCY_BINARY <= "001";
           when   2  =>  L1EXITLATENCY_BINARY <= "010";
           when   3  =>  L1EXITLATENCY_BINARY <= "011";
           when   4  =>  L1EXITLATENCY_BINARY <= "100";
           when   5  =>  L1EXITLATENCY_BINARY <= "101";
           when   6  =>  L1EXITLATENCY_BINARY <= "110";
           when   7  =>  L1EXITLATENCY_BINARY <= "111";
           when others  =>  assert FALSE report "Error : L1EXITLATENCY is not in range 0...7." severity error;
       end case;
       case L1EXITLATENCYCOMCLK is
           when   0  =>  L1EXITLATENCYCOMCLK_BINARY <= "000";
           when   1  =>  L1EXITLATENCYCOMCLK_BINARY <= "001";
           when   2  =>  L1EXITLATENCYCOMCLK_BINARY <= "010";
           when   3  =>  L1EXITLATENCYCOMCLK_BINARY <= "011";
           when   4  =>  L1EXITLATENCYCOMCLK_BINARY <= "100";
           when   5  =>  L1EXITLATENCYCOMCLK_BINARY <= "101";
           when   6  =>  L1EXITLATENCYCOMCLK_BINARY <= "110";
           when   7  =>  L1EXITLATENCYCOMCLK_BINARY <= "111";
           when others  =>  assert FALSE report "Error : L1EXITLATENCYCOMCLK is not in range 0...7." severity error;
       end case;
       case DUALCORESLAVE is
           when FALSE   =>  DUALCORESLAVE_BINARY <= '0';
           when TRUE    =>  DUALCORESLAVE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DUALCORESLAVE is neither TRUE nor FALSE." severity error;
       end case;
       case DUALCOREENABLE is
           when FALSE   =>  DUALCOREENABLE_BINARY <= '0';
           when TRUE    =>  DUALCOREENABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DUALCOREENABLE is neither TRUE nor FALSE." severity error;
       end case;
       case DUALROLECFGCNTRLROOTEPN is
           when   0  =>  DUALROLECFGCNTRLROOTEPN_BINARY <= '0';
           when   1  =>  DUALROLECFGCNTRLROOTEPN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : DUALROLECFGCNTRLROOTEPN is not in range 0...1." severity error;
       end case;
       case RXREADADDRPIPE is
           when FALSE   =>  RXREADADDRPIPE_BINARY <= '0';
           when TRUE    =>  RXREADADDRPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RXREADADDRPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case RXREADDATAPIPE is
           when FALSE   =>  RXREADDATAPIPE_BINARY <= '0';
           when TRUE    =>  RXREADDATAPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RXREADDATAPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case TXWRITEPIPE is
           when FALSE   =>  TXWRITEPIPE_BINARY <= '0';
           when TRUE    =>  TXWRITEPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TXWRITEPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case TXREADADDRPIPE is
           when FALSE   =>  TXREADADDRPIPE_BINARY <= '0';
           when TRUE    =>  TXREADADDRPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TXREADADDRPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case TXREADDATAPIPE is
           when FALSE   =>  TXREADDATAPIPE_BINARY <= '0';
           when TRUE    =>  TXREADDATAPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : TXREADDATAPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case RXWRITEPIPE is
           when FALSE   =>  RXWRITEPIPE_BINARY <= '0';
           when TRUE    =>  RXWRITEPIPE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RXWRITEPIPE is neither TRUE nor FALSE." severity error;
       end case;
       case LLKBYPASS is
           when FALSE   =>  LLKBYPASS_BINARY <= '0';
           when TRUE    =>  LLKBYPASS_BINARY <= '1';
           when others  =>  assert FALSE report "Error : LLKBYPASS is neither TRUE nor FALSE." severity error;
       end case;
       case PCIEREVISION is
           when   0  =>  PCIEREVISION_BINARY <= '0';
           when   1  =>  PCIEREVISION_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PCIEREVISION is not in range 0...1." severity error;
       end case;
       case SELECTDLLIF is
           when FALSE   =>  SELECTDLLIF_BINARY <= '0';
           when TRUE    =>  SELECTDLLIF_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SELECTDLLIF is neither TRUE nor FALSE." severity error;
       end case;
       case SELECTASMODE is
           when FALSE   =>  SELECTASMODE_BINARY <= '0';
           when TRUE    =>  SELECTASMODE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SELECTASMODE is neither TRUE nor FALSE." severity error;
       end case;
       case ISSWITCH is
           when FALSE   =>  ISSWITCH_BINARY <= '0';
           when TRUE    =>  ISSWITCH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : ISSWITCH is neither TRUE nor FALSE." severity error;
       end case;
       case UPSTREAMFACING is
           when FALSE   =>  UPSTREAMFACING_BINARY <= '0';
           when TRUE    =>  UPSTREAMFACING_BINARY <= '1';
           when others  =>  assert FALSE report "Error : UPSTREAMFACING is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTIMPLEMENTED is
           when FALSE   =>  SLOTIMPLEMENTED_BINARY <= '0';
           when TRUE    =>  SLOTIMPLEMENTED_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTIMPLEMENTED is neither TRUE nor FALSE." severity error;
       end case;
       case BAR0EXIST is
           when FALSE   =>  BAR0EXIST_BINARY <= '0';
           when TRUE    =>  BAR0EXIST_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR0EXIST is neither TRUE nor FALSE." severity error;
       end case;
       case BAR1EXIST is
           when FALSE   =>  BAR1EXIST_BINARY <= '0';
           when TRUE    =>  BAR1EXIST_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR1EXIST is neither TRUE nor FALSE." severity error;
       end case;
       case BAR2EXIST is
           when FALSE   =>  BAR2EXIST_BINARY <= '0';
           when TRUE    =>  BAR2EXIST_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR2EXIST is neither TRUE nor FALSE." severity error;
       end case;
       case BAR3EXIST is
           when FALSE   =>  BAR3EXIST_BINARY <= '0';
           when TRUE    =>  BAR3EXIST_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR3EXIST is neither TRUE nor FALSE." severity error;
       end case;
       case BAR4EXIST is
           when FALSE   =>  BAR4EXIST_BINARY <= '0';
           when TRUE    =>  BAR4EXIST_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR4EXIST is neither TRUE nor FALSE." severity error;
       end case;
       case BAR5EXIST is
           when FALSE   =>  BAR5EXIST_BINARY <= '0';
           when TRUE    =>  BAR5EXIST_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR5EXIST is neither TRUE nor FALSE." severity error;
       end case;
       case BAR0ADDRWIDTH is
           when   0  =>  BAR0ADDRWIDTH_BINARY <= '0';
           when   1  =>  BAR0ADDRWIDTH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR0ADDRWIDTH is not in range 0...1." severity error;
       end case;
       case BAR1ADDRWIDTH is
           when   0  =>  BAR1ADDRWIDTH_BINARY <= '0';
           when   1  =>  BAR1ADDRWIDTH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR1ADDRWIDTH is not in range 0...1." severity error;
       end case;
       case BAR2ADDRWIDTH is
           when   0  =>  BAR2ADDRWIDTH_BINARY <= '0';
           when   1  =>  BAR2ADDRWIDTH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR2ADDRWIDTH is not in range 0...1." severity error;
       end case;
       case BAR3ADDRWIDTH is
           when   0  =>  BAR3ADDRWIDTH_BINARY <= '0';
           when   1  =>  BAR3ADDRWIDTH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR3ADDRWIDTH is not in range 0...1." severity error;
       end case;
       case BAR4ADDRWIDTH is
           when   0  =>  BAR4ADDRWIDTH_BINARY <= '0';
           when   1  =>  BAR4ADDRWIDTH_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR4ADDRWIDTH is not in range 0...1." severity error;
       end case;
       case BAR0PREFETCHABLE is
           when FALSE   =>  BAR0PREFETCHABLE_BINARY <= '0';
           when TRUE    =>  BAR0PREFETCHABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR0PREFETCHABLE is neither TRUE nor FALSE." severity error;
       end case;
       case BAR1PREFETCHABLE is
           when FALSE   =>  BAR1PREFETCHABLE_BINARY <= '0';
           when TRUE    =>  BAR1PREFETCHABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR1PREFETCHABLE is neither TRUE nor FALSE." severity error;
       end case;
       case BAR2PREFETCHABLE is
           when FALSE   =>  BAR2PREFETCHABLE_BINARY <= '0';
           when TRUE    =>  BAR2PREFETCHABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR2PREFETCHABLE is neither TRUE nor FALSE." severity error;
       end case;
       case BAR3PREFETCHABLE is
           when FALSE   =>  BAR3PREFETCHABLE_BINARY <= '0';
           when TRUE    =>  BAR3PREFETCHABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR3PREFETCHABLE is neither TRUE nor FALSE." severity error;
       end case;
       case BAR4PREFETCHABLE is
           when FALSE   =>  BAR4PREFETCHABLE_BINARY <= '0';
           when TRUE    =>  BAR4PREFETCHABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR4PREFETCHABLE is neither TRUE nor FALSE." severity error;
       end case;
       case BAR5PREFETCHABLE is
           when FALSE   =>  BAR5PREFETCHABLE_BINARY <= '0';
           when TRUE    =>  BAR5PREFETCHABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR5PREFETCHABLE is neither TRUE nor FALSE." severity error;
       end case;
       case BAR0IOMEMN is
           when   0  =>  BAR0IOMEMN_BINARY <= '0';
           when   1  =>  BAR0IOMEMN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR0IOMEMN is not in range 0...1." severity error;
       end case;
       case BAR1IOMEMN is
           when   0  =>  BAR1IOMEMN_BINARY <= '0';
           when   1  =>  BAR1IOMEMN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR1IOMEMN is not in range 0...1." severity error;
       end case;
       case BAR2IOMEMN is
           when   0  =>  BAR2IOMEMN_BINARY <= '0';
           when   1  =>  BAR2IOMEMN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR2IOMEMN is not in range 0...1." severity error;
       end case;
       case BAR3IOMEMN is
           when   0  =>  BAR3IOMEMN_BINARY <= '0';
           when   1  =>  BAR3IOMEMN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR3IOMEMN is not in range 0...1." severity error;
       end case;
       case BAR4IOMEMN is
           when   0  =>  BAR4IOMEMN_BINARY <= '0';
           when   1  =>  BAR4IOMEMN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR4IOMEMN is not in range 0...1." severity error;
       end case;
       case BAR5IOMEMN is
           when   0  =>  BAR5IOMEMN_BINARY <= '0';
           when   1  =>  BAR5IOMEMN_BINARY <= '1';
           when others  =>  assert FALSE report "Error : BAR5IOMEMN is not in range 0...1." severity error;
       end case;
       case XPMAXPAYLOAD is
           when   0  =>  XPMAXPAYLOAD_BINARY <= "000";
           when   1  =>  XPMAXPAYLOAD_BINARY <= "001";
           when   2  =>  XPMAXPAYLOAD_BINARY <= "010";
           when   3  =>  XPMAXPAYLOAD_BINARY <= "011";
           when   4  =>  XPMAXPAYLOAD_BINARY <= "100";
           when   5  =>  XPMAXPAYLOAD_BINARY <= "101";
           when   6  =>  XPMAXPAYLOAD_BINARY <= "110";
           when   7  =>  XPMAXPAYLOAD_BINARY <= "111";
           when others  =>  assert FALSE report "Error : XPMAXPAYLOAD is not in range 0...7." severity error;
       end case;
       case XPRCBCONTROL is
           when   0  =>  XPRCBCONTROL_BINARY <= '0';
           when   1  =>  XPRCBCONTROL_BINARY <= '1';
           when others  =>  assert FALSE report "Error : XPRCBCONTROL is not in range 0...1." severity error;
       end case;
       case LOWPRIORITYVCCOUNT is
           when   0  =>  LOWPRIORITYVCCOUNT_BINARY <= "000";
           when   1  =>  LOWPRIORITYVCCOUNT_BINARY <= "001";
           when   2  =>  LOWPRIORITYVCCOUNT_BINARY <= "010";
           when   3  =>  LOWPRIORITYVCCOUNT_BINARY <= "011";
           when   4  =>  LOWPRIORITYVCCOUNT_BINARY <= "100";
           when   5  =>  LOWPRIORITYVCCOUNT_BINARY <= "101";
           when   6  =>  LOWPRIORITYVCCOUNT_BINARY <= "110";
           when   7  =>  LOWPRIORITYVCCOUNT_BINARY <= "111";
           when others  =>  assert FALSE report "Error : LOWPRIORITYVCCOUNT is not in range 0...7." severity error;
       end case;
       case PMCAPABILITYDSI is
           when FALSE   =>  PMCAPABILITYDSI_BINARY <= '0';
           when TRUE    =>  PMCAPABILITYDSI_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PMCAPABILITYDSI is neither TRUE nor FALSE." severity error;
       end case;
       case PMCAPABILITYD1SUPPORT is
           when FALSE   =>  PMCAPABILITYD1SUPPORT_BINARY <= '0';
           when TRUE    =>  PMCAPABILITYD1SUPPORT_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PMCAPABILITYD1SUPPORT is neither TRUE nor FALSE." severity error;
       end case;
       case PMCAPABILITYD2SUPPORT is
           when FALSE   =>  PMCAPABILITYD2SUPPORT_BINARY <= '0';
           when TRUE    =>  PMCAPABILITYD2SUPPORT_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PMCAPABILITYD2SUPPORT is neither TRUE nor FALSE." severity error;
       end case;
       case PMDATASCALE0 is
           when   0  =>  PMDATASCALE0_BINARY <= "00";
           when   1  =>  PMDATASCALE0_BINARY <= "01";
           when   2  =>  PMDATASCALE0_BINARY <= "10";
           when   3  =>  PMDATASCALE0_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE0 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE1 is
           when   0  =>  PMDATASCALE1_BINARY <= "00";
           when   1  =>  PMDATASCALE1_BINARY <= "01";
           when   2  =>  PMDATASCALE1_BINARY <= "10";
           when   3  =>  PMDATASCALE1_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE1 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE2 is
           when   0  =>  PMDATASCALE2_BINARY <= "00";
           when   1  =>  PMDATASCALE2_BINARY <= "01";
           when   2  =>  PMDATASCALE2_BINARY <= "10";
           when   3  =>  PMDATASCALE2_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE2 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE3 is
           when   0  =>  PMDATASCALE3_BINARY <= "00";
           when   1  =>  PMDATASCALE3_BINARY <= "01";
           when   2  =>  PMDATASCALE3_BINARY <= "10";
           when   3  =>  PMDATASCALE3_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE3 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE4 is
           when   0  =>  PMDATASCALE4_BINARY <= "00";
           when   1  =>  PMDATASCALE4_BINARY <= "01";
           when   2  =>  PMDATASCALE4_BINARY <= "10";
           when   3  =>  PMDATASCALE4_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE4 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE5 is
           when   0  =>  PMDATASCALE5_BINARY <= "00";
           when   1  =>  PMDATASCALE5_BINARY <= "01";
           when   2  =>  PMDATASCALE5_BINARY <= "10";
           when   3  =>  PMDATASCALE5_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE5 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE6 is
           when   0  =>  PMDATASCALE6_BINARY <= "00";
           when   1  =>  PMDATASCALE6_BINARY <= "01";
           when   2  =>  PMDATASCALE6_BINARY <= "10";
           when   3  =>  PMDATASCALE6_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE6 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE7 is
           when   0  =>  PMDATASCALE7_BINARY <= "00";
           when   1  =>  PMDATASCALE7_BINARY <= "01";
           when   2  =>  PMDATASCALE7_BINARY <= "10";
           when   3  =>  PMDATASCALE7_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE7 is not in range 0...3." severity error;
       end case;
       case PMDATASCALE8 is
           when   0  =>  PMDATASCALE8_BINARY <= "00";
           when   1  =>  PMDATASCALE8_BINARY <= "01";
           when   2  =>  PMDATASCALE8_BINARY <= "10";
           when   3  =>  PMDATASCALE8_BINARY <= "11";
           when others  =>  assert FALSE report "Error : PMDATASCALE8 is not in range 0...3." severity error;
       end case;
       case PCIECAPABILITYSLOTIMPL is
           when FALSE   =>  PCIECAPABILITYSLOTIMPL_BINARY <= '0';
           when TRUE    =>  PCIECAPABILITYSLOTIMPL_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PCIECAPABILITYSLOTIMPL is neither TRUE nor FALSE." severity error;
       end case;
       case LINKSTATUSSLOTCLOCKCONFIG is
           when FALSE   =>  LINKSTATUSSLOTCLOCKCONFIG_BINARY <= '0';
           when TRUE    =>  LINKSTATUSSLOTCLOCKCONFIG_BINARY <= '1';
           when others  =>  assert FALSE report "Error : LINKSTATUSSLOTCLOCKCONFIG is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTCAPABILITYATTBUTTONPRESENT is
           when FALSE   =>  SLOTCAPABILITYATTBUTTONPRESENT_BINARY <= '0';
           when TRUE    =>  SLOTCAPABILITYATTBUTTONPRESENT_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTCAPABILITYATTBUTTONPRESENT is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTCAPABILITYPOWERCONTROLLERPRESENT is
           when FALSE   =>  SLOTCAPABILITYPOWERCONTROLLERPRESENT_BINARY <= '0';
           when TRUE    =>  SLOTCAPABILITYPOWERCONTROLLERPRESENT_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTCAPABILITYPOWERCONTROLLERPRESENT is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTCAPABILITYMSLSENSORPRESENT is
           when FALSE   =>  SLOTCAPABILITYMSLSENSORPRESENT_BINARY <= '0';
           when TRUE    =>  SLOTCAPABILITYMSLSENSORPRESENT_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTCAPABILITYMSLSENSORPRESENT is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTCAPABILITYATTINDICATORPRESENT is
           when FALSE   =>  SLOTCAPABILITYATTINDICATORPRESENT_BINARY <= '0';
           when TRUE    =>  SLOTCAPABILITYATTINDICATORPRESENT_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTCAPABILITYATTINDICATORPRESENT is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTCAPABILITYPOWERINDICATORPRESENT is
           when FALSE   =>  SLOTCAPABILITYPOWERINDICATORPRESENT_BINARY <= '0';
           when TRUE    =>  SLOTCAPABILITYPOWERINDICATORPRESENT_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTCAPABILITYPOWERINDICATORPRESENT is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTCAPABILITYHOTPLUGSURPRISE is
           when FALSE   =>  SLOTCAPABILITYHOTPLUGSURPRISE_BINARY <= '0';
           when TRUE    =>  SLOTCAPABILITYHOTPLUGSURPRISE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTCAPABILITYHOTPLUGSURPRISE is neither TRUE nor FALSE." severity error;
       end case;
       case SLOTCAPABILITYHOTPLUGCAPABLE is
           when FALSE   =>  SLOTCAPABILITYHOTPLUGCAPABLE_BINARY <= '0';
           when TRUE    =>  SLOTCAPABILITYHOTPLUGCAPABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : SLOTCAPABILITYHOTPLUGCAPABLE is neither TRUE nor FALSE." severity error;
       end case;
       case AERCAPABILITYECRCGENCAPABLE is
           when FALSE   =>  AERCAPABILITYECRCGENCAPABLE_BINARY <= '0';
           when TRUE    =>  AERCAPABILITYECRCGENCAPABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : AERCAPABILITYECRCGENCAPABLE is neither TRUE nor FALSE." severity error;
       end case;
       case AERCAPABILITYECRCCHECKCAPABLE is
           when FALSE   =>  AERCAPABILITYECRCCHECKCAPABLE_BINARY <= '0';
           when TRUE    =>  AERCAPABILITYECRCCHECKCAPABLE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : AERCAPABILITYECRCCHECKCAPABLE is neither TRUE nor FALSE." severity error;
       end case;
       case PBCAPABILITYSYSTEMALLOCATED is
           when FALSE   =>  PBCAPABILITYSYSTEMALLOCATED_BINARY <= '0';
           when TRUE    =>  PBCAPABILITYSYSTEMALLOCATED_BINARY <= '1';
           when others  =>  assert FALSE report "Error : PBCAPABILITYSYSTEMALLOCATED is neither TRUE nor FALSE." severity error;
       end case;
       case RESETMODE is
           when FALSE   =>  RESETMODE_BINARY <= '0';
           when TRUE    =>  RESETMODE_BINARY <= '1';
           when others  =>  assert FALSE report "Error : RESETMODE is neither TRUE nor FALSE." severity error;
       end case;
       case CLKDIVIDED is
           when FALSE   =>  CLKDIVIDED_BINARY <= '0';
           when TRUE    =>  CLKDIVIDED_BINARY <= '1';
           when others  =>  assert FALSE report "Error : CLKDIVIDED is neither TRUE nor FALSE." severity error;
       end case;
	wait;
	end process INIPROC;

	TIMING : process



	variable  PIPETXDATAL00_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL01_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL02_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL03_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL04_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL05_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL06_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL07_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL0_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL0_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL0_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL0_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL0_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL00_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL01_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL0_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL0_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL10_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL11_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL12_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL13_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL14_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL15_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL16_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL17_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL1_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL1_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL1_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL1_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL1_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL10_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL11_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL1_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL1_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL20_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL21_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL22_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL23_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL24_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL25_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL26_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL27_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL2_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL2_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL2_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL2_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL2_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL20_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL21_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL2_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL2_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL30_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL31_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL32_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL33_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL34_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL35_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL36_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL37_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL3_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL3_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL3_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL3_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL3_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL30_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL31_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL3_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL3_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL40_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL41_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL42_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL43_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL44_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL45_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL46_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL47_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL4_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL4_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL4_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL4_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL4_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL40_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL41_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL4_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL4_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL50_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL51_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL52_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL53_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL54_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL55_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL56_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL57_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL5_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL5_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL5_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL5_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL5_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL50_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL51_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL5_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL5_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL60_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL61_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL62_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL63_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL64_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL65_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL66_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL67_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL6_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL6_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL6_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL6_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL6_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL60_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL61_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL6_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL6_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL70_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL71_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL72_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL73_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL74_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL75_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL76_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAL77_GlitchData : VitalGlitchDataType;
	variable  PIPETXDATAKL7_GlitchData : VitalGlitchDataType;
	variable  PIPETXELECIDLEL7_GlitchData : VitalGlitchDataType;
	variable  PIPETXDETECTRXLOOPBACKL7_GlitchData : VitalGlitchDataType;
	variable  PIPETXCOMPLIANCEL7_GlitchData : VitalGlitchDataType;
	variable  PIPERXPOLARITYL7_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL70_GlitchData : VitalGlitchDataType;
	variable  PIPEPOWERDOWNL71_GlitchData : VitalGlitchDataType;
	variable  PIPEDESKEWLANESL7_GlitchData : VitalGlitchDataType;
	variable  PIPERESETL7_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA0_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA1_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA2_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA3_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA4_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA5_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA6_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA7_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA8_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA9_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA10_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA11_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA12_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA13_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA14_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA15_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA16_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA17_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA18_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA19_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA20_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA21_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA22_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA23_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA24_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA25_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA26_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA27_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA28_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA29_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA30_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA31_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA32_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA33_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA34_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA35_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA36_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA37_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA38_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA39_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA40_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA41_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA42_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA43_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA44_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA45_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA46_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA47_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA48_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA49_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA50_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA51_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA52_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA53_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA54_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA55_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA56_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA57_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA58_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA59_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA60_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA61_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA62_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWDATA63_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD0_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD1_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD2_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD3_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD4_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD5_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD6_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD7_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD8_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD9_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD10_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD11_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWADD12_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD0_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD1_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD2_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD3_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD4_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD5_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD6_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD7_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD8_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD9_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD10_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD11_GlitchData : VitalGlitchDataType;
	variable  MIMRXBRADD12_GlitchData : VitalGlitchDataType;
	variable  MIMRXBWEN_GlitchData : VitalGlitchDataType;
	variable  MIMRXBREN_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA0_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA1_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA2_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA3_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA4_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA5_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA6_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA7_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA8_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA9_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA10_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA11_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA12_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA13_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA14_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA15_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA16_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA17_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA18_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA19_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA20_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA21_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA22_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA23_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA24_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA25_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA26_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA27_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA28_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA29_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA30_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA31_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA32_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA33_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA34_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA35_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA36_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA37_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA38_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA39_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA40_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA41_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA42_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA43_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA44_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA45_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA46_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA47_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA48_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA49_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA50_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA51_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA52_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA53_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA54_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA55_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA56_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA57_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA58_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA59_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA60_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA61_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA62_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWDATA63_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD0_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD1_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD2_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD3_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD4_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD5_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD6_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD7_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD8_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD9_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD10_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD11_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWADD12_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD0_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD1_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD2_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD3_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD4_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD5_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD6_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD7_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD8_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD9_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD10_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD11_GlitchData : VitalGlitchDataType;
	variable  MIMTXBRADD12_GlitchData : VitalGlitchDataType;
	variable  MIMTXBWEN_GlitchData : VitalGlitchDataType;
	variable  MIMTXBREN_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA0_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA1_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA2_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA3_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA4_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA5_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA6_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA7_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA8_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA9_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA10_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA11_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA12_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA13_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA14_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA15_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA16_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA17_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA18_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA19_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA20_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA21_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA22_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA23_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA24_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA25_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA26_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA27_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA28_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA29_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA30_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA31_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA32_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA33_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA34_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA35_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA36_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA37_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA38_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA39_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA40_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA41_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA42_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA43_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA44_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA45_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA46_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA47_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA48_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA49_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA50_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA51_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA52_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA53_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA54_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA55_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA56_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA57_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA58_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA59_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA60_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA61_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA62_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWDATA63_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD0_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD1_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD2_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD3_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD4_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD5_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD6_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD7_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD8_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD9_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD10_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWADD11_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD0_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD1_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD2_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD3_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD4_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD5_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD6_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD7_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD8_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD9_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD10_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBRADD11_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBWEN_GlitchData : VitalGlitchDataType;
	variable  MIMDLLBREN_GlitchData : VitalGlitchDataType;
	variable  CRMRXHOTRESETN_GlitchData : VitalGlitchDataType;
	variable  CRMDOHOTRESETN_GlitchData : VitalGlitchDataType;
	variable  CRMPWRSOFTRESETN_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS0_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS1_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS2_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS3_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS4_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS5_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS6_GlitchData : VitalGlitchDataType;
	variable  LLKTCSTATUS7_GlitchData : VitalGlitchDataType;
	variable  LLKTXDSTRDYN_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE0_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE1_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE2_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE3_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE4_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE5_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE6_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE7_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE8_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHANSPACE9_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN0_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN1_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN2_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN3_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN4_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN5_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN6_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHPOSTEDREADYN7_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN0_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN1_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN2_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN3_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN4_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN5_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN6_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHNONPOSTEDREADYN7_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN0_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN1_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN2_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN3_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN4_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN5_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN6_GlitchData : VitalGlitchDataType;
	variable  LLKTXCHCOMPLETIONREADYN7_GlitchData : VitalGlitchDataType;
	variable  LLKTXCONFIGREADYN_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA0_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA1_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA2_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA3_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA4_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA5_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA6_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA7_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA8_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA9_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA10_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA11_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA12_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA13_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA14_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA15_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA16_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA17_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA18_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA19_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA20_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA21_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA22_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA23_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA24_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA25_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA26_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA27_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA28_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA29_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA30_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA31_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA32_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA33_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA34_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA35_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA36_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA37_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA38_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA39_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA40_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA41_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA42_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA43_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA44_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA45_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA46_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA47_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA48_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA49_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA50_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA51_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA52_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA53_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA54_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA55_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA56_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA57_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA58_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA59_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA60_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA61_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA62_GlitchData : VitalGlitchDataType;
	variable  LLKRXDATA63_GlitchData : VitalGlitchDataType;
	variable  LLKRXSRCRDYN_GlitchData : VitalGlitchDataType;
	variable  LLKRXSRCLASTREQN_GlitchData : VitalGlitchDataType;
	variable  LLKRXSRCDSCN_GlitchData : VitalGlitchDataType;
	variable  LLKRXSOFN_GlitchData : VitalGlitchDataType;
	variable  LLKRXEOFN_GlitchData : VitalGlitchDataType;
	variable  LLKRXSOPN_GlitchData : VitalGlitchDataType;
	variable  LLKRXEOPN_GlitchData : VitalGlitchDataType;
	variable  LLKRXVALIDN0_GlitchData : VitalGlitchDataType;
	variable  LLKRXVALIDN1_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE0_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE1_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE2_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE3_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE4_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE5_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE6_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE7_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE8_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE9_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE10_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE11_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE12_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE13_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE14_GlitchData : VitalGlitchDataType;
	variable  LLKRXPREFERREDTYPE15_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN0_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN1_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN2_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN3_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN4_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN5_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN6_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDAVAILABLEN7_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN0_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN1_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN2_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN3_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN4_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN5_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN6_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDAVAILABLEN7_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN0_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN1_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN2_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN3_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN4_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN5_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN6_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONAVAILABLEN7_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCONFIGAVAILABLEN_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN0_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN1_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN2_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN3_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN4_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN5_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN6_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHPOSTEDPARTIALN7_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN0_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN1_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN2_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN3_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN4_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN5_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN6_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHNONPOSTEDPARTIALN7_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN0_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN1_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN2_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN3_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN4_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN5_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN6_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCOMPLETIONPARTIALN7_GlitchData : VitalGlitchDataType;
	variable  LLKRXCHCONFIGPARTIALN_GlitchData : VitalGlitchDataType;
	variable  LLKRX4DWHEADERN_GlitchData : VitalGlitchDataType;
	variable  LLKRXECRCBADN_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA0_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA1_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA2_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA3_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA4_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA5_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA6_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA7_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA8_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA9_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA10_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA11_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA12_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA13_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA14_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA15_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA16_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA17_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA18_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA19_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA20_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA21_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA22_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA23_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA24_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA25_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA26_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA27_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA28_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA29_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA30_GlitchData : VitalGlitchDataType;
	variable  MGMTRDATA31_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO0_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO1_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO2_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO3_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO4_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO5_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO6_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO7_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO8_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO9_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO10_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO11_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO12_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO13_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO14_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO15_GlitchData : VitalGlitchDataType;
	variable  MGMTPSO16_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT0_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT1_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT2_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT3_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT4_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT5_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT6_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT7_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT8_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT9_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT10_GlitchData : VitalGlitchDataType;
	variable  MGMTSTATSCREDIT11_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLTLPECRCOK_GlitchData : VitalGlitchDataType;
	variable  DLLTXPMDLLPOUTSTANDING_GlitchData : VitalGlitchDataType;
	variable  L0FIRSTCFGWRITEOCCURRED_GlitchData : VitalGlitchDataType;
	variable  L0CFGLOOPBACKACK_GlitchData : VitalGlitchDataType;
	variable  L0MACUPSTREAMDOWNSTREAM_GlitchData : VitalGlitchDataType;
	variable  L0RXMACLINKERROR0_GlitchData : VitalGlitchDataType;
	variable  L0RXMACLINKERROR1_GlitchData : VitalGlitchDataType;
	variable  L0MACLINKUP_GlitchData : VitalGlitchDataType;
	variable  L0MACNEGOTIATEDLINKWIDTH0_GlitchData : VitalGlitchDataType;
	variable  L0MACNEGOTIATEDLINKWIDTH1_GlitchData : VitalGlitchDataType;
	variable  L0MACNEGOTIATEDLINKWIDTH2_GlitchData : VitalGlitchDataType;
	variable  L0MACNEGOTIATEDLINKWIDTH3_GlitchData : VitalGlitchDataType;
	variable  L0MACLINKTRAINING_GlitchData : VitalGlitchDataType;
	variable  L0LTSSMSTATE0_GlitchData : VitalGlitchDataType;
	variable  L0LTSSMSTATE1_GlitchData : VitalGlitchDataType;
	variable  L0LTSSMSTATE2_GlitchData : VitalGlitchDataType;
	variable  L0LTSSMSTATE3_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS0_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS1_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS2_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS3_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS4_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS5_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS6_GlitchData : VitalGlitchDataType;
	variable  L0DLLVCSTATUS7_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN0_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN1_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN2_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN3_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN4_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN5_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN6_GlitchData : VitalGlitchDataType;
	variable  L0DLUPDOWN7_GlitchData : VitalGlitchDataType;
	variable  L0DLLERRORVECTOR0_GlitchData : VitalGlitchDataType;
	variable  L0DLLERRORVECTOR1_GlitchData : VitalGlitchDataType;
	variable  L0DLLERRORVECTOR2_GlitchData : VitalGlitchDataType;
	variable  L0DLLERRORVECTOR3_GlitchData : VitalGlitchDataType;
	variable  L0DLLERRORVECTOR4_GlitchData : VitalGlitchDataType;
	variable  L0DLLERRORVECTOR5_GlitchData : VitalGlitchDataType;
	variable  L0DLLERRORVECTOR6_GlitchData : VitalGlitchDataType;
	variable  L0DLLASRXSTATE0_GlitchData : VitalGlitchDataType;
	variable  L0DLLASRXSTATE1_GlitchData : VitalGlitchDataType;
	variable  L0DLLASTXSTATE_GlitchData : VitalGlitchDataType;
	variable  L0ASAUTONOMOUSINITCOMPLETED_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID0_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID1_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID2_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID3_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID4_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID5_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID6_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID7_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID8_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID9_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID10_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID11_GlitchData : VitalGlitchDataType;
	variable  L0COMPLETERID12_GlitchData : VitalGlitchDataType;
	variable  L0UNLOCKRECEIVED_GlitchData : VitalGlitchDataType;
	variable  L0CORRERRMSGRCVD_GlitchData : VitalGlitchDataType;
	variable  L0FATALERRMSGRCVD_GlitchData : VitalGlitchDataType;
	variable  L0NONFATALERRMSGRCVD_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID0_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID1_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID2_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID3_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID4_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID5_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID6_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID7_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID8_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID9_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID10_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID11_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID12_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID13_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID14_GlitchData : VitalGlitchDataType;
	variable  L0ERRMSGREQID15_GlitchData : VitalGlitchDataType;
	variable  L0FWDCORRERROUT_GlitchData : VitalGlitchDataType;
	variable  L0FWDFATALERROUT_GlitchData : VitalGlitchDataType;
	variable  L0FWDNONFATALERROUT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDASSERTINTALEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDASSERTINTBLEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDASSERTINTCLEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDASSERTINTDLEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDDEASSERTINTALEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDDEASSERTINTBLEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDDEASSERTINTCLEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0RECEIVEDDEASSERTINTDLEGACYINT_GlitchData : VitalGlitchDataType;
	variable  L0MSIENABLE0_GlitchData : VitalGlitchDataType;
	variable  L0MULTIMSGEN00_GlitchData : VitalGlitchDataType;
	variable  L0MULTIMSGEN01_GlitchData : VitalGlitchDataType;
	variable  L0MULTIMSGEN02_GlitchData : VitalGlitchDataType;
	variable  L0STATSDLLPRECEIVED_GlitchData : VitalGlitchDataType;
	variable  L0STATSDLLPTRANSMITTED_GlitchData : VitalGlitchDataType;
	variable  L0STATSOSRECEIVED_GlitchData : VitalGlitchDataType;
	variable  L0STATSOSTRANSMITTED_GlitchData : VitalGlitchDataType;
	variable  L0STATSTLPRECEIVED_GlitchData : VitalGlitchDataType;
	variable  L0STATSTLPTRANSMITTED_GlitchData : VitalGlitchDataType;
	variable  L0STATSCFGRECEIVED_GlitchData : VitalGlitchDataType;
	variable  L0STATSCFGTRANSMITTED_GlitchData : VitalGlitchDataType;
	variable  L0STATSCFGOTHERRECEIVED_GlitchData : VitalGlitchDataType;
	variable  L0STATSCFGOTHERTRANSMITTED_GlitchData : VitalGlitchDataType;
	variable  MAXPAYLOADSIZE0_GlitchData : VitalGlitchDataType;
	variable  MAXPAYLOADSIZE1_GlitchData : VitalGlitchDataType;
	variable  MAXPAYLOADSIZE2_GlitchData : VitalGlitchDataType;
	variable  MAXREADREQUESTSIZE0_GlitchData : VitalGlitchDataType;
	variable  MAXREADREQUESTSIZE1_GlitchData : VitalGlitchDataType;
	variable  MAXREADREQUESTSIZE2_GlitchData : VitalGlitchDataType;
	variable  IOSPACEENABLE_GlitchData : VitalGlitchDataType;
	variable  MEMSPACEENABLE_GlitchData : VitalGlitchDataType;
	variable  L0ATTENTIONINDICATORCONTROL0_GlitchData : VitalGlitchDataType;
	variable  L0ATTENTIONINDICATORCONTROL1_GlitchData : VitalGlitchDataType;
	variable  L0POWERINDICATORCONTROL0_GlitchData : VitalGlitchDataType;
	variable  L0POWERINDICATORCONTROL1_GlitchData : VitalGlitchDataType;
	variable  L0POWERCONTROLLERCONTROL_GlitchData : VitalGlitchDataType;
	variable  L0TOGGLEELECTROMECHANICALINTERLOCK_GlitchData : VitalGlitchDataType;
	variable  L0RXBEACON_GlitchData : VitalGlitchDataType;
	variable  L0PWRSTATE00_GlitchData : VitalGlitchDataType;
	variable  L0PWRSTATE01_GlitchData : VitalGlitchDataType;
	variable  L0PMEACK_GlitchData : VitalGlitchDataType;
	variable  L0PMEREQOUT_GlitchData : VitalGlitchDataType;
	variable  L0PMEEN_GlitchData : VitalGlitchDataType;
	variable  L0PWRINHIBITTRANSFERS_GlitchData : VitalGlitchDataType;
	variable  L0PWRL1STATE_GlitchData : VitalGlitchDataType;
	variable  L0PWRL23READYDEVICE_GlitchData : VitalGlitchDataType;
	variable  L0PWRL23READYSTATE_GlitchData : VitalGlitchDataType;
	variable  L0PWRTXL0SSTATE_GlitchData : VitalGlitchDataType;
	variable  L0PWRTURNOFFREQ_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLPM_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLPMTYPE0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLPMTYPE1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLPMTYPE2_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLPMUPDATED_GlitchData : VitalGlitchDataType;
	variable  L0MACNEWSTATEACK_GlitchData : VitalGlitchDataType;
	variable  L0MACRXL0SSTATE_GlitchData : VitalGlitchDataType;
	variable  L0MACENTEREDL0_GlitchData : VitalGlitchDataType;
	variable  L0DLLRXACKOUTSTANDING_GlitchData : VitalGlitchDataType;
	variable  L0DLLTXOUTSTANDING_GlitchData : VitalGlitchDataType;
	variable  L0DLLTXNONFCOUTSTANDING_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLTLPEND0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLTLPEND1_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLSBFCUPDATED_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA2_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA3_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA4_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA5_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA6_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA7_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA8_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA9_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA10_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA11_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA12_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA13_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA14_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA15_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA16_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA17_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCDATA18_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLSBFCUPDATE_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED0_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED1_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED2_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED3_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED4_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED5_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED6_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCNPOSTBYPUPDATED7_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED0_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED1_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED2_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED3_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED4_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED5_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED6_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCPOSTORDUPDATED7_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED0_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED1_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED2_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED3_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED4_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED5_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED6_GlitchData : VitalGlitchDataType;
	variable  L0TXDLLFCCMPLMCUPDATED7_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED2_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED3_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED4_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED5_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED6_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED7_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED8_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED9_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED10_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED11_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED12_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED13_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED14_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED15_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED16_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED17_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED18_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPCRED19_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE2_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE3_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE4_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE5_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE6_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCNPOSTBYPUPDATE7_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED2_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED3_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED4_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED5_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED6_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED7_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED8_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED9_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED10_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED11_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED12_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED13_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED14_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED15_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED16_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED17_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED18_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED19_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED20_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED21_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED22_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDCRED23_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE2_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE3_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE4_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE5_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE6_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCPOSTORDUPDATE7_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED2_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED3_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED4_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED5_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED6_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED7_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED8_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED9_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED10_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED11_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED12_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED13_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED14_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED15_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED16_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED17_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED18_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED19_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED20_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED21_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED22_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCCRED23_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE0_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE1_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE2_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE3_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE4_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE5_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE6_GlitchData : VitalGlitchDataType;
	variable  L0RXDLLFCCMPLMCUPDATE7_GlitchData : VitalGlitchDataType;
	variable  L0UCBYPFOUND0_GlitchData : VitalGlitchDataType;
	variable  L0UCBYPFOUND1_GlitchData : VitalGlitchDataType;
	variable  L0UCBYPFOUND2_GlitchData : VitalGlitchDataType;
	variable  L0UCBYPFOUND3_GlitchData : VitalGlitchDataType;
	variable  L0UCORDFOUND0_GlitchData : VitalGlitchDataType;
	variable  L0UCORDFOUND1_GlitchData : VitalGlitchDataType;
	variable  L0UCORDFOUND2_GlitchData : VitalGlitchDataType;
	variable  L0UCORDFOUND3_GlitchData : VitalGlitchDataType;
	variable  L0MCFOUND0_GlitchData : VitalGlitchDataType;
	variable  L0MCFOUND1_GlitchData : VitalGlitchDataType;
	variable  L0MCFOUND2_GlitchData : VitalGlitchDataType;
	variable  L0TRANSFORMEDVC0_GlitchData : VitalGlitchDataType;
	variable  L0TRANSFORMEDVC1_GlitchData : VitalGlitchDataType;
	variable  L0TRANSFORMEDVC2_GlitchData : VitalGlitchDataType;
	variable  BUSMASTERENABLE_GlitchData : VitalGlitchDataType;
	variable  PARITYERRORRESPONSE_GlitchData : VitalGlitchDataType;
	variable  SERRENABLE_GlitchData : VitalGlitchDataType;
	variable  INTERRUPTDISABLE_GlitchData : VitalGlitchDataType;
	variable  URREPORTINGENABLE_GlitchData : VitalGlitchDataType;
begin

	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(0),
	GlitchData    => PIPETXDATAL00_GlitchData,
	OutSignalName => "PIPETXDATAL0(0)",
	OutTemp       => PIPETXDATAL0_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(1),
	GlitchData    => PIPETXDATAL01_GlitchData,
	OutSignalName => "PIPETXDATAL0(1)",
	OutTemp       => PIPETXDATAL0_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(2),
	GlitchData    => PIPETXDATAL02_GlitchData,
	OutSignalName => "PIPETXDATAL0(2)",
	OutTemp       => PIPETXDATAL0_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(3),
	GlitchData    => PIPETXDATAL03_GlitchData,
	OutSignalName => "PIPETXDATAL0(3)",
	OutTemp       => PIPETXDATAL0_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(4),
	GlitchData    => PIPETXDATAL04_GlitchData,
	OutSignalName => "PIPETXDATAL0(4)",
	OutTemp       => PIPETXDATAL0_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(5),
	GlitchData    => PIPETXDATAL05_GlitchData,
	OutSignalName => "PIPETXDATAL0(5)",
	OutTemp       => PIPETXDATAL0_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(6),
	GlitchData    => PIPETXDATAL06_GlitchData,
	OutSignalName => "PIPETXDATAL0(6)",
	OutTemp       => PIPETXDATAL0_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL0(7),
	GlitchData    => PIPETXDATAL07_GlitchData,
	OutSignalName => "PIPETXDATAL0(7)",
	OutTemp       => PIPETXDATAL0_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL0,
	GlitchData    => PIPETXDATAKL0_GlitchData,
	OutSignalName => "PIPETXDATAKL0",
	OutTemp       => PIPETXDATAKL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL0,
	GlitchData    => PIPETXELECIDLEL0_GlitchData,
	OutSignalName => "PIPETXELECIDLEL0",
	OutTemp       => PIPETXELECIDLEL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL0,
	GlitchData    => PIPETXDETECTRXLOOPBACKL0_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL0",
	OutTemp       => PIPETXDETECTRXLOOPBACKL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL0,
	GlitchData    => PIPETXCOMPLIANCEL0_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL0",
	OutTemp       => PIPETXCOMPLIANCEL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL0,
	GlitchData    => PIPERXPOLARITYL0_GlitchData,
	OutSignalName => "PIPERXPOLARITYL0",
	OutTemp       => PIPERXPOLARITYL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL0(0),
	GlitchData    => PIPEPOWERDOWNL00_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL0(0)",
	OutTemp       => PIPEPOWERDOWNL0_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL0(0),
	GlitchData    => PIPEPOWERDOWNL00_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL0(0)",
	OutTemp       => PIPEPOWERDOWNL0_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL0(1),
	GlitchData    => PIPEPOWERDOWNL01_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL0(1)",
	OutTemp       => PIPEPOWERDOWNL0_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL0(1),
	GlitchData    => PIPEPOWERDOWNL01_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL0(1)",
	OutTemp       => PIPEPOWERDOWNL0_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL0,
	GlitchData    => PIPEDESKEWLANESL0_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL0",
	OutTemp       => PIPEDESKEWLANESL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL0,
	GlitchData    => PIPERESETL0_GlitchData,
	OutSignalName => "PIPERESETL0",
	OutTemp       => PIPERESETL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(0),
	GlitchData    => PIPETXDATAL10_GlitchData,
	OutSignalName => "PIPETXDATAL1(0)",
	OutTemp       => PIPETXDATAL1_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(1),
	GlitchData    => PIPETXDATAL11_GlitchData,
	OutSignalName => "PIPETXDATAL1(1)",
	OutTemp       => PIPETXDATAL1_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(2),
	GlitchData    => PIPETXDATAL12_GlitchData,
	OutSignalName => "PIPETXDATAL1(2)",
	OutTemp       => PIPETXDATAL1_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(3),
	GlitchData    => PIPETXDATAL13_GlitchData,
	OutSignalName => "PIPETXDATAL1(3)",
	OutTemp       => PIPETXDATAL1_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(4),
	GlitchData    => PIPETXDATAL14_GlitchData,
	OutSignalName => "PIPETXDATAL1(4)",
	OutTemp       => PIPETXDATAL1_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(5),
	GlitchData    => PIPETXDATAL15_GlitchData,
	OutSignalName => "PIPETXDATAL1(5)",
	OutTemp       => PIPETXDATAL1_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(6),
	GlitchData    => PIPETXDATAL16_GlitchData,
	OutSignalName => "PIPETXDATAL1(6)",
	OutTemp       => PIPETXDATAL1_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL1(7),
	GlitchData    => PIPETXDATAL17_GlitchData,
	OutSignalName => "PIPETXDATAL1(7)",
	OutTemp       => PIPETXDATAL1_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL1,
	GlitchData    => PIPETXDATAKL1_GlitchData,
	OutSignalName => "PIPETXDATAKL1",
	OutTemp       => PIPETXDATAKL1_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL1,
	GlitchData    => PIPETXELECIDLEL1_GlitchData,
	OutSignalName => "PIPETXELECIDLEL1",
	OutTemp       => PIPETXELECIDLEL1_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL1,
	GlitchData    => PIPETXDETECTRXLOOPBACKL1_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL1",
	OutTemp       => PIPETXDETECTRXLOOPBACKL1_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL1,
	GlitchData    => PIPETXCOMPLIANCEL1_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL1",
	OutTemp       => PIPETXCOMPLIANCEL1_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL1,
	GlitchData    => PIPERXPOLARITYL1_GlitchData,
	OutSignalName => "PIPERXPOLARITYL1",
	OutTemp       => PIPERXPOLARITYL1_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL1(0),
	GlitchData    => PIPEPOWERDOWNL10_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL1(0)",
	OutTemp       => PIPEPOWERDOWNL1_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL1(0),
	GlitchData    => PIPEPOWERDOWNL10_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL1(0)",
	OutTemp       => PIPEPOWERDOWNL1_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL1(1),
	GlitchData    => PIPEPOWERDOWNL11_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL1(1)",
	OutTemp       => PIPEPOWERDOWNL1_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL1(1),
	GlitchData    => PIPEPOWERDOWNL11_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL1(1)",
	OutTemp       => PIPEPOWERDOWNL1_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL1,
	GlitchData    => PIPEDESKEWLANESL1_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL1",
	OutTemp       => PIPEDESKEWLANESL1_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL1,
	GlitchData    => PIPERESETL1_GlitchData,
	OutSignalName => "PIPERESETL1",
	OutTemp       => PIPERESETL1_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(0),
	GlitchData    => PIPETXDATAL20_GlitchData,
	OutSignalName => "PIPETXDATAL2(0)",
	OutTemp       => PIPETXDATAL2_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(1),
	GlitchData    => PIPETXDATAL21_GlitchData,
	OutSignalName => "PIPETXDATAL2(1)",
	OutTemp       => PIPETXDATAL2_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(2),
	GlitchData    => PIPETXDATAL22_GlitchData,
	OutSignalName => "PIPETXDATAL2(2)",
	OutTemp       => PIPETXDATAL2_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(3),
	GlitchData    => PIPETXDATAL23_GlitchData,
	OutSignalName => "PIPETXDATAL2(3)",
	OutTemp       => PIPETXDATAL2_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(4),
	GlitchData    => PIPETXDATAL24_GlitchData,
	OutSignalName => "PIPETXDATAL2(4)",
	OutTemp       => PIPETXDATAL2_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(5),
	GlitchData    => PIPETXDATAL25_GlitchData,
	OutSignalName => "PIPETXDATAL2(5)",
	OutTemp       => PIPETXDATAL2_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(6),
	GlitchData    => PIPETXDATAL26_GlitchData,
	OutSignalName => "PIPETXDATAL2(6)",
	OutTemp       => PIPETXDATAL2_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL2(7),
	GlitchData    => PIPETXDATAL27_GlitchData,
	OutSignalName => "PIPETXDATAL2(7)",
	OutTemp       => PIPETXDATAL2_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL2,
	GlitchData    => PIPETXDATAKL2_GlitchData,
	OutSignalName => "PIPETXDATAKL2",
	OutTemp       => PIPETXDATAKL2_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL2,
	GlitchData    => PIPETXELECIDLEL2_GlitchData,
	OutSignalName => "PIPETXELECIDLEL2",
	OutTemp       => PIPETXELECIDLEL2_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL2,
	GlitchData    => PIPETXDETECTRXLOOPBACKL2_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL2",
	OutTemp       => PIPETXDETECTRXLOOPBACKL2_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL2,
	GlitchData    => PIPETXCOMPLIANCEL2_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL2",
	OutTemp       => PIPETXCOMPLIANCEL2_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL2,
	GlitchData    => PIPERXPOLARITYL2_GlitchData,
	OutSignalName => "PIPERXPOLARITYL2",
	OutTemp       => PIPERXPOLARITYL2_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL2(0),
	GlitchData    => PIPEPOWERDOWNL20_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL2(0)",
	OutTemp       => PIPEPOWERDOWNL2_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL2(0),
	GlitchData    => PIPEPOWERDOWNL20_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL2(0)",
	OutTemp       => PIPEPOWERDOWNL2_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL2(1),
	GlitchData    => PIPEPOWERDOWNL21_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL2(1)",
	OutTemp       => PIPEPOWERDOWNL2_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL2(1),
	GlitchData    => PIPEPOWERDOWNL21_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL2(1)",
	OutTemp       => PIPEPOWERDOWNL2_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL2,
	GlitchData    => PIPEDESKEWLANESL2_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL2",
	OutTemp       => PIPEDESKEWLANESL2_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL2,
	GlitchData    => PIPERESETL2_GlitchData,
	OutSignalName => "PIPERESETL2",
	OutTemp       => PIPERESETL2_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(0),
	GlitchData    => PIPETXDATAL30_GlitchData,
	OutSignalName => "PIPETXDATAL3(0)",
	OutTemp       => PIPETXDATAL3_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(1),
	GlitchData    => PIPETXDATAL31_GlitchData,
	OutSignalName => "PIPETXDATAL3(1)",
	OutTemp       => PIPETXDATAL3_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(2),
	GlitchData    => PIPETXDATAL32_GlitchData,
	OutSignalName => "PIPETXDATAL3(2)",
	OutTemp       => PIPETXDATAL3_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(3),
	GlitchData    => PIPETXDATAL33_GlitchData,
	OutSignalName => "PIPETXDATAL3(3)",
	OutTemp       => PIPETXDATAL3_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(4),
	GlitchData    => PIPETXDATAL34_GlitchData,
	OutSignalName => "PIPETXDATAL3(4)",
	OutTemp       => PIPETXDATAL3_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(5),
	GlitchData    => PIPETXDATAL35_GlitchData,
	OutSignalName => "PIPETXDATAL3(5)",
	OutTemp       => PIPETXDATAL3_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(6),
	GlitchData    => PIPETXDATAL36_GlitchData,
	OutSignalName => "PIPETXDATAL3(6)",
	OutTemp       => PIPETXDATAL3_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL3(7),
	GlitchData    => PIPETXDATAL37_GlitchData,
	OutSignalName => "PIPETXDATAL3(7)",
	OutTemp       => PIPETXDATAL3_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL3,
	GlitchData    => PIPETXDATAKL3_GlitchData,
	OutSignalName => "PIPETXDATAKL3",
	OutTemp       => PIPETXDATAKL3_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL3,
	GlitchData    => PIPETXELECIDLEL3_GlitchData,
	OutSignalName => "PIPETXELECIDLEL3",
	OutTemp       => PIPETXELECIDLEL3_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL3,
	GlitchData    => PIPETXDETECTRXLOOPBACKL3_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL3",
	OutTemp       => PIPETXDETECTRXLOOPBACKL3_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL3,
	GlitchData    => PIPETXCOMPLIANCEL3_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL3",
	OutTemp       => PIPETXCOMPLIANCEL3_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL3,
	GlitchData    => PIPERXPOLARITYL3_GlitchData,
	OutSignalName => "PIPERXPOLARITYL3",
	OutTemp       => PIPERXPOLARITYL3_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL3(0),
	GlitchData    => PIPEPOWERDOWNL30_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL3(0)",
	OutTemp       => PIPEPOWERDOWNL3_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL3(0),
	GlitchData    => PIPEPOWERDOWNL30_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL3(0)",
	OutTemp       => PIPEPOWERDOWNL3_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL3(1),
	GlitchData    => PIPEPOWERDOWNL31_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL3(1)",
	OutTemp       => PIPEPOWERDOWNL3_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL3(1),
	GlitchData    => PIPEPOWERDOWNL31_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL3(1)",
	OutTemp       => PIPEPOWERDOWNL3_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL3,
	GlitchData    => PIPEDESKEWLANESL3_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL3",
	OutTemp       => PIPEDESKEWLANESL3_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL3,
	GlitchData    => PIPERESETL3_GlitchData,
	OutSignalName => "PIPERESETL3",
	OutTemp       => PIPERESETL3_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(0),
	GlitchData    => PIPETXDATAL40_GlitchData,
	OutSignalName => "PIPETXDATAL4(0)",
	OutTemp       => PIPETXDATAL4_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(1),
	GlitchData    => PIPETXDATAL41_GlitchData,
	OutSignalName => "PIPETXDATAL4(1)",
	OutTemp       => PIPETXDATAL4_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(2),
	GlitchData    => PIPETXDATAL42_GlitchData,
	OutSignalName => "PIPETXDATAL4(2)",
	OutTemp       => PIPETXDATAL4_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(3),
	GlitchData    => PIPETXDATAL43_GlitchData,
	OutSignalName => "PIPETXDATAL4(3)",
	OutTemp       => PIPETXDATAL4_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(4),
	GlitchData    => PIPETXDATAL44_GlitchData,
	OutSignalName => "PIPETXDATAL4(4)",
	OutTemp       => PIPETXDATAL4_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(5),
	GlitchData    => PIPETXDATAL45_GlitchData,
	OutSignalName => "PIPETXDATAL4(5)",
	OutTemp       => PIPETXDATAL4_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(6),
	GlitchData    => PIPETXDATAL46_GlitchData,
	OutSignalName => "PIPETXDATAL4(6)",
	OutTemp       => PIPETXDATAL4_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL4(7),
	GlitchData    => PIPETXDATAL47_GlitchData,
	OutSignalName => "PIPETXDATAL4(7)",
	OutTemp       => PIPETXDATAL4_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL4,
	GlitchData    => PIPETXDATAKL4_GlitchData,
	OutSignalName => "PIPETXDATAKL4",
	OutTemp       => PIPETXDATAKL4_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL4,
	GlitchData    => PIPETXELECIDLEL4_GlitchData,
	OutSignalName => "PIPETXELECIDLEL4",
	OutTemp       => PIPETXELECIDLEL4_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL4,
	GlitchData    => PIPETXDETECTRXLOOPBACKL4_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL4",
	OutTemp       => PIPETXDETECTRXLOOPBACKL4_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL4,
	GlitchData    => PIPETXCOMPLIANCEL4_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL4",
	OutTemp       => PIPETXCOMPLIANCEL4_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL4,
	GlitchData    => PIPERXPOLARITYL4_GlitchData,
	OutSignalName => "PIPERXPOLARITYL4",
	OutTemp       => PIPERXPOLARITYL4_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL4(0),
	GlitchData    => PIPEPOWERDOWNL40_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL4(0)",
	OutTemp       => PIPEPOWERDOWNL4_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL4(0),
	GlitchData    => PIPEPOWERDOWNL40_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL4(0)",
	OutTemp       => PIPEPOWERDOWNL4_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL4(1),
	GlitchData    => PIPEPOWERDOWNL41_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL4(1)",
	OutTemp       => PIPEPOWERDOWNL4_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL4(1),
	GlitchData    => PIPEPOWERDOWNL41_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL4(1)",
	OutTemp       => PIPEPOWERDOWNL4_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL4,
	GlitchData    => PIPEDESKEWLANESL4_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL4",
	OutTemp       => PIPEDESKEWLANESL4_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL4,
	GlitchData    => PIPERESETL4_GlitchData,
	OutSignalName => "PIPERESETL4",
	OutTemp       => PIPERESETL4_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(0),
	GlitchData    => PIPETXDATAL50_GlitchData,
	OutSignalName => "PIPETXDATAL5(0)",
	OutTemp       => PIPETXDATAL5_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(1),
	GlitchData    => PIPETXDATAL51_GlitchData,
	OutSignalName => "PIPETXDATAL5(1)",
	OutTemp       => PIPETXDATAL5_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(2),
	GlitchData    => PIPETXDATAL52_GlitchData,
	OutSignalName => "PIPETXDATAL5(2)",
	OutTemp       => PIPETXDATAL5_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(3),
	GlitchData    => PIPETXDATAL53_GlitchData,
	OutSignalName => "PIPETXDATAL5(3)",
	OutTemp       => PIPETXDATAL5_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(4),
	GlitchData    => PIPETXDATAL54_GlitchData,
	OutSignalName => "PIPETXDATAL5(4)",
	OutTemp       => PIPETXDATAL5_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(5),
	GlitchData    => PIPETXDATAL55_GlitchData,
	OutSignalName => "PIPETXDATAL5(5)",
	OutTemp       => PIPETXDATAL5_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(6),
	GlitchData    => PIPETXDATAL56_GlitchData,
	OutSignalName => "PIPETXDATAL5(6)",
	OutTemp       => PIPETXDATAL5_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL5(7),
	GlitchData    => PIPETXDATAL57_GlitchData,
	OutSignalName => "PIPETXDATAL5(7)",
	OutTemp       => PIPETXDATAL5_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL5,
	GlitchData    => PIPETXDATAKL5_GlitchData,
	OutSignalName => "PIPETXDATAKL5",
	OutTemp       => PIPETXDATAKL5_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL5,
	GlitchData    => PIPETXELECIDLEL5_GlitchData,
	OutSignalName => "PIPETXELECIDLEL5",
	OutTemp       => PIPETXELECIDLEL5_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL5,
	GlitchData    => PIPETXDETECTRXLOOPBACKL5_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL5",
	OutTemp       => PIPETXDETECTRXLOOPBACKL5_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL5,
	GlitchData    => PIPETXCOMPLIANCEL5_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL5",
	OutTemp       => PIPETXCOMPLIANCEL5_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL5,
	GlitchData    => PIPERXPOLARITYL5_GlitchData,
	OutSignalName => "PIPERXPOLARITYL5",
	OutTemp       => PIPERXPOLARITYL5_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL5(0),
	GlitchData    => PIPEPOWERDOWNL50_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL5(0)",
	OutTemp       => PIPEPOWERDOWNL5_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL5(0),
	GlitchData    => PIPEPOWERDOWNL50_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL5(0)",
	OutTemp       => PIPEPOWERDOWNL5_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL5(1),
	GlitchData    => PIPEPOWERDOWNL51_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL5(1)",
	OutTemp       => PIPEPOWERDOWNL5_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL5(1),
	GlitchData    => PIPEPOWERDOWNL51_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL5(1)",
	OutTemp       => PIPEPOWERDOWNL5_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL5,
	GlitchData    => PIPEDESKEWLANESL5_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL5",
	OutTemp       => PIPEDESKEWLANESL5_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL5,
	GlitchData    => PIPERESETL5_GlitchData,
	OutSignalName => "PIPERESETL5",
	OutTemp       => PIPERESETL5_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(0),
	GlitchData    => PIPETXDATAL60_GlitchData,
	OutSignalName => "PIPETXDATAL6(0)",
	OutTemp       => PIPETXDATAL6_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(1),
	GlitchData    => PIPETXDATAL61_GlitchData,
	OutSignalName => "PIPETXDATAL6(1)",
	OutTemp       => PIPETXDATAL6_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(2),
	GlitchData    => PIPETXDATAL62_GlitchData,
	OutSignalName => "PIPETXDATAL6(2)",
	OutTemp       => PIPETXDATAL6_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(3),
	GlitchData    => PIPETXDATAL63_GlitchData,
	OutSignalName => "PIPETXDATAL6(3)",
	OutTemp       => PIPETXDATAL6_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(4),
	GlitchData    => PIPETXDATAL64_GlitchData,
	OutSignalName => "PIPETXDATAL6(4)",
	OutTemp       => PIPETXDATAL6_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(5),
	GlitchData    => PIPETXDATAL65_GlitchData,
	OutSignalName => "PIPETXDATAL6(5)",
	OutTemp       => PIPETXDATAL6_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(6),
	GlitchData    => PIPETXDATAL66_GlitchData,
	OutSignalName => "PIPETXDATAL6(6)",
	OutTemp       => PIPETXDATAL6_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL6(7),
	GlitchData    => PIPETXDATAL67_GlitchData,
	OutSignalName => "PIPETXDATAL6(7)",
	OutTemp       => PIPETXDATAL6_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL6,
	GlitchData    => PIPETXDATAKL6_GlitchData,
	OutSignalName => "PIPETXDATAKL6",
	OutTemp       => PIPETXDATAKL6_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL6,
	GlitchData    => PIPETXELECIDLEL6_GlitchData,
	OutSignalName => "PIPETXELECIDLEL6",
	OutTemp       => PIPETXELECIDLEL6_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL6,
	GlitchData    => PIPETXDETECTRXLOOPBACKL6_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL6",
	OutTemp       => PIPETXDETECTRXLOOPBACKL6_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL6,
	GlitchData    => PIPETXCOMPLIANCEL6_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL6",
	OutTemp       => PIPETXCOMPLIANCEL6_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL6,
	GlitchData    => PIPERXPOLARITYL6_GlitchData,
	OutSignalName => "PIPERXPOLARITYL6",
	OutTemp       => PIPERXPOLARITYL6_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL6(0),
	GlitchData    => PIPEPOWERDOWNL60_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL6(0)",
	OutTemp       => PIPEPOWERDOWNL6_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL6(0),
	GlitchData    => PIPEPOWERDOWNL60_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL6(0)",
	OutTemp       => PIPEPOWERDOWNL6_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL6(1),
	GlitchData    => PIPEPOWERDOWNL61_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL6(1)",
	OutTemp       => PIPEPOWERDOWNL6_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL6(1),
	GlitchData    => PIPEPOWERDOWNL61_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL6(1)",
	OutTemp       => PIPEPOWERDOWNL6_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL6,
	GlitchData    => PIPEDESKEWLANESL6_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL6",
	OutTemp       => PIPEDESKEWLANESL6_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL6,
	GlitchData    => PIPERESETL6_GlitchData,
	OutSignalName => "PIPERESETL6",
	OutTemp       => PIPERESETL6_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(0),
	GlitchData    => PIPETXDATAL70_GlitchData,
	OutSignalName => "PIPETXDATAL7(0)",
	OutTemp       => PIPETXDATAL7_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(1),
	GlitchData    => PIPETXDATAL71_GlitchData,
	OutSignalName => "PIPETXDATAL7(1)",
	OutTemp       => PIPETXDATAL7_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(2),
	GlitchData    => PIPETXDATAL72_GlitchData,
	OutSignalName => "PIPETXDATAL7(2)",
	OutTemp       => PIPETXDATAL7_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(3),
	GlitchData    => PIPETXDATAL73_GlitchData,
	OutSignalName => "PIPETXDATAL7(3)",
	OutTemp       => PIPETXDATAL7_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(4),
	GlitchData    => PIPETXDATAL74_GlitchData,
	OutSignalName => "PIPETXDATAL7(4)",
	OutTemp       => PIPETXDATAL7_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(5),
	GlitchData    => PIPETXDATAL75_GlitchData,
	OutSignalName => "PIPETXDATAL7(5)",
	OutTemp       => PIPETXDATAL7_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(6),
	GlitchData    => PIPETXDATAL76_GlitchData,
	OutSignalName => "PIPETXDATAL7(6)",
	OutTemp       => PIPETXDATAL7_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAL7(7),
	GlitchData    => PIPETXDATAL77_GlitchData,
	OutSignalName => "PIPETXDATAL7(7)",
	OutTemp       => PIPETXDATAL7_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDATAKL7,
	GlitchData    => PIPETXDATAKL7_GlitchData,
	OutSignalName => "PIPETXDATAKL7",
	OutTemp       => PIPETXDATAKL7_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXELECIDLEL7,
	GlitchData    => PIPETXELECIDLEL7_GlitchData,
	OutSignalName => "PIPETXELECIDLEL7",
	OutTemp       => PIPETXELECIDLEL7_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXDETECTRXLOOPBACKL7,
	GlitchData    => PIPETXDETECTRXLOOPBACKL7_GlitchData,
	OutSignalName => "PIPETXDETECTRXLOOPBACKL7",
	OutTemp       => PIPETXDETECTRXLOOPBACKL7_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPETXCOMPLIANCEL7,
	GlitchData    => PIPETXCOMPLIANCEL7_GlitchData,
	OutSignalName => "PIPETXCOMPLIANCEL7",
	OutTemp       => PIPETXCOMPLIANCEL7_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERXPOLARITYL7,
	GlitchData    => PIPERXPOLARITYL7_GlitchData,
	OutSignalName => "PIPERXPOLARITYL7",
	OutTemp       => PIPERXPOLARITYL7_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL7(0),
	GlitchData    => PIPEPOWERDOWNL70_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL7(0)",
	OutTemp       => PIPEPOWERDOWNL7_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL7(0),
	GlitchData    => PIPEPOWERDOWNL70_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL7(0)",
	OutTemp       => PIPEPOWERDOWNL7_OUT(0),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL7(1),
	GlitchData    => PIPEPOWERDOWNL71_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL7(1)",
	OutTemp       => PIPEPOWERDOWNL7_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEPOWERDOWNL7(1),
	GlitchData    => PIPEPOWERDOWNL71_GlitchData,
	OutSignalName => "PIPEPOWERDOWNL7(1)",
	OutTemp       => PIPEPOWERDOWNL7_OUT(1),
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPEDESKEWLANESL7,
	GlitchData    => PIPEDESKEWLANESL7_GlitchData,
	OutSignalName => "PIPEDESKEWLANESL7",
	OutTemp       => PIPEDESKEWLANESL7_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PIPERESETL7,
	GlitchData    => PIPERESETL7_GlitchData,
	OutSignalName => "PIPERESETL7",
	OutTemp       => PIPERESETL7_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(0),
	GlitchData    => MIMRXBWDATA0_GlitchData,
	OutSignalName => "MIMRXBWDATA(0)",
	OutTemp       => MIMRXBWDATA_OUT(0),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(1),
	GlitchData    => MIMRXBWDATA1_GlitchData,
	OutSignalName => "MIMRXBWDATA(1)",
	OutTemp       => MIMRXBWDATA_OUT(1),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(2),
	GlitchData    => MIMRXBWDATA2_GlitchData,
	OutSignalName => "MIMRXBWDATA(2)",
	OutTemp       => MIMRXBWDATA_OUT(2),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(3),
	GlitchData    => MIMRXBWDATA3_GlitchData,
	OutSignalName => "MIMRXBWDATA(3)",
	OutTemp       => MIMRXBWDATA_OUT(3),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(4),
	GlitchData    => MIMRXBWDATA4_GlitchData,
	OutSignalName => "MIMRXBWDATA(4)",
	OutTemp       => MIMRXBWDATA_OUT(4),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(5),
	GlitchData    => MIMRXBWDATA5_GlitchData,
	OutSignalName => "MIMRXBWDATA(5)",
	OutTemp       => MIMRXBWDATA_OUT(5),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(6),
	GlitchData    => MIMRXBWDATA6_GlitchData,
	OutSignalName => "MIMRXBWDATA(6)",
	OutTemp       => MIMRXBWDATA_OUT(6),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(7),
	GlitchData    => MIMRXBWDATA7_GlitchData,
	OutSignalName => "MIMRXBWDATA(7)",
	OutTemp       => MIMRXBWDATA_OUT(7),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(8),
	GlitchData    => MIMRXBWDATA8_GlitchData,
	OutSignalName => "MIMRXBWDATA(8)",
	OutTemp       => MIMRXBWDATA_OUT(8),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(9),
	GlitchData    => MIMRXBWDATA9_GlitchData,
	OutSignalName => "MIMRXBWDATA(9)",
	OutTemp       => MIMRXBWDATA_OUT(9),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(10),
	GlitchData    => MIMRXBWDATA10_GlitchData,
	OutSignalName => "MIMRXBWDATA(10)",
	OutTemp       => MIMRXBWDATA_OUT(10),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(11),
	GlitchData    => MIMRXBWDATA11_GlitchData,
	OutSignalName => "MIMRXBWDATA(11)",
	OutTemp       => MIMRXBWDATA_OUT(11),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(12),
	GlitchData    => MIMRXBWDATA12_GlitchData,
	OutSignalName => "MIMRXBWDATA(12)",
	OutTemp       => MIMRXBWDATA_OUT(12),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(13),
	GlitchData    => MIMRXBWDATA13_GlitchData,
	OutSignalName => "MIMRXBWDATA(13)",
	OutTemp       => MIMRXBWDATA_OUT(13),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(14),
	GlitchData    => MIMRXBWDATA14_GlitchData,
	OutSignalName => "MIMRXBWDATA(14)",
	OutTemp       => MIMRXBWDATA_OUT(14),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(15),
	GlitchData    => MIMRXBWDATA15_GlitchData,
	OutSignalName => "MIMRXBWDATA(15)",
	OutTemp       => MIMRXBWDATA_OUT(15),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(16),
	GlitchData    => MIMRXBWDATA16_GlitchData,
	OutSignalName => "MIMRXBWDATA(16)",
	OutTemp       => MIMRXBWDATA_OUT(16),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(17),
	GlitchData    => MIMRXBWDATA17_GlitchData,
	OutSignalName => "MIMRXBWDATA(17)",
	OutTemp       => MIMRXBWDATA_OUT(17),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(18),
	GlitchData    => MIMRXBWDATA18_GlitchData,
	OutSignalName => "MIMRXBWDATA(18)",
	OutTemp       => MIMRXBWDATA_OUT(18),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(19),
	GlitchData    => MIMRXBWDATA19_GlitchData,
	OutSignalName => "MIMRXBWDATA(19)",
	OutTemp       => MIMRXBWDATA_OUT(19),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(20),
	GlitchData    => MIMRXBWDATA20_GlitchData,
	OutSignalName => "MIMRXBWDATA(20)",
	OutTemp       => MIMRXBWDATA_OUT(20),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(21),
	GlitchData    => MIMRXBWDATA21_GlitchData,
	OutSignalName => "MIMRXBWDATA(21)",
	OutTemp       => MIMRXBWDATA_OUT(21),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(22),
	GlitchData    => MIMRXBWDATA22_GlitchData,
	OutSignalName => "MIMRXBWDATA(22)",
	OutTemp       => MIMRXBWDATA_OUT(22),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(23),
	GlitchData    => MIMRXBWDATA23_GlitchData,
	OutSignalName => "MIMRXBWDATA(23)",
	OutTemp       => MIMRXBWDATA_OUT(23),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(24),
	GlitchData    => MIMRXBWDATA24_GlitchData,
	OutSignalName => "MIMRXBWDATA(24)",
	OutTemp       => MIMRXBWDATA_OUT(24),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(25),
	GlitchData    => MIMRXBWDATA25_GlitchData,
	OutSignalName => "MIMRXBWDATA(25)",
	OutTemp       => MIMRXBWDATA_OUT(25),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(26),
	GlitchData    => MIMRXBWDATA26_GlitchData,
	OutSignalName => "MIMRXBWDATA(26)",
	OutTemp       => MIMRXBWDATA_OUT(26),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(27),
	GlitchData    => MIMRXBWDATA27_GlitchData,
	OutSignalName => "MIMRXBWDATA(27)",
	OutTemp       => MIMRXBWDATA_OUT(27),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(28),
	GlitchData    => MIMRXBWDATA28_GlitchData,
	OutSignalName => "MIMRXBWDATA(28)",
	OutTemp       => MIMRXBWDATA_OUT(28),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(29),
	GlitchData    => MIMRXBWDATA29_GlitchData,
	OutSignalName => "MIMRXBWDATA(29)",
	OutTemp       => MIMRXBWDATA_OUT(29),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(30),
	GlitchData    => MIMRXBWDATA30_GlitchData,
	OutSignalName => "MIMRXBWDATA(30)",
	OutTemp       => MIMRXBWDATA_OUT(30),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(31),
	GlitchData    => MIMRXBWDATA31_GlitchData,
	OutSignalName => "MIMRXBWDATA(31)",
	OutTemp       => MIMRXBWDATA_OUT(31),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(32),
	GlitchData    => MIMRXBWDATA32_GlitchData,
	OutSignalName => "MIMRXBWDATA(32)",
	OutTemp       => MIMRXBWDATA_OUT(32),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(33),
	GlitchData    => MIMRXBWDATA33_GlitchData,
	OutSignalName => "MIMRXBWDATA(33)",
	OutTemp       => MIMRXBWDATA_OUT(33),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(34),
	GlitchData    => MIMRXBWDATA34_GlitchData,
	OutSignalName => "MIMRXBWDATA(34)",
	OutTemp       => MIMRXBWDATA_OUT(34),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(35),
	GlitchData    => MIMRXBWDATA35_GlitchData,
	OutSignalName => "MIMRXBWDATA(35)",
	OutTemp       => MIMRXBWDATA_OUT(35),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(36),
	GlitchData    => MIMRXBWDATA36_GlitchData,
	OutSignalName => "MIMRXBWDATA(36)",
	OutTemp       => MIMRXBWDATA_OUT(36),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(37),
	GlitchData    => MIMRXBWDATA37_GlitchData,
	OutSignalName => "MIMRXBWDATA(37)",
	OutTemp       => MIMRXBWDATA_OUT(37),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(38),
	GlitchData    => MIMRXBWDATA38_GlitchData,
	OutSignalName => "MIMRXBWDATA(38)",
	OutTemp       => MIMRXBWDATA_OUT(38),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(39),
	GlitchData    => MIMRXBWDATA39_GlitchData,
	OutSignalName => "MIMRXBWDATA(39)",
	OutTemp       => MIMRXBWDATA_OUT(39),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(40),
	GlitchData    => MIMRXBWDATA40_GlitchData,
	OutSignalName => "MIMRXBWDATA(40)",
	OutTemp       => MIMRXBWDATA_OUT(40),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(41),
	GlitchData    => MIMRXBWDATA41_GlitchData,
	OutSignalName => "MIMRXBWDATA(41)",
	OutTemp       => MIMRXBWDATA_OUT(41),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(42),
	GlitchData    => MIMRXBWDATA42_GlitchData,
	OutSignalName => "MIMRXBWDATA(42)",
	OutTemp       => MIMRXBWDATA_OUT(42),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(43),
	GlitchData    => MIMRXBWDATA43_GlitchData,
	OutSignalName => "MIMRXBWDATA(43)",
	OutTemp       => MIMRXBWDATA_OUT(43),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(44),
	GlitchData    => MIMRXBWDATA44_GlitchData,
	OutSignalName => "MIMRXBWDATA(44)",
	OutTemp       => MIMRXBWDATA_OUT(44),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(45),
	GlitchData    => MIMRXBWDATA45_GlitchData,
	OutSignalName => "MIMRXBWDATA(45)",
	OutTemp       => MIMRXBWDATA_OUT(45),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(46),
	GlitchData    => MIMRXBWDATA46_GlitchData,
	OutSignalName => "MIMRXBWDATA(46)",
	OutTemp       => MIMRXBWDATA_OUT(46),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(47),
	GlitchData    => MIMRXBWDATA47_GlitchData,
	OutSignalName => "MIMRXBWDATA(47)",
	OutTemp       => MIMRXBWDATA_OUT(47),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(48),
	GlitchData    => MIMRXBWDATA48_GlitchData,
	OutSignalName => "MIMRXBWDATA(48)",
	OutTemp       => MIMRXBWDATA_OUT(48),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(49),
	GlitchData    => MIMRXBWDATA49_GlitchData,
	OutSignalName => "MIMRXBWDATA(49)",
	OutTemp       => MIMRXBWDATA_OUT(49),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(50),
	GlitchData    => MIMRXBWDATA50_GlitchData,
	OutSignalName => "MIMRXBWDATA(50)",
	OutTemp       => MIMRXBWDATA_OUT(50),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(51),
	GlitchData    => MIMRXBWDATA51_GlitchData,
	OutSignalName => "MIMRXBWDATA(51)",
	OutTemp       => MIMRXBWDATA_OUT(51),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(52),
	GlitchData    => MIMRXBWDATA52_GlitchData,
	OutSignalName => "MIMRXBWDATA(52)",
	OutTemp       => MIMRXBWDATA_OUT(52),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(53),
	GlitchData    => MIMRXBWDATA53_GlitchData,
	OutSignalName => "MIMRXBWDATA(53)",
	OutTemp       => MIMRXBWDATA_OUT(53),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(54),
	GlitchData    => MIMRXBWDATA54_GlitchData,
	OutSignalName => "MIMRXBWDATA(54)",
	OutTemp       => MIMRXBWDATA_OUT(54),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(55),
	GlitchData    => MIMRXBWDATA55_GlitchData,
	OutSignalName => "MIMRXBWDATA(55)",
	OutTemp       => MIMRXBWDATA_OUT(55),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(56),
	GlitchData    => MIMRXBWDATA56_GlitchData,
	OutSignalName => "MIMRXBWDATA(56)",
	OutTemp       => MIMRXBWDATA_OUT(56),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(57),
	GlitchData    => MIMRXBWDATA57_GlitchData,
	OutSignalName => "MIMRXBWDATA(57)",
	OutTemp       => MIMRXBWDATA_OUT(57),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(58),
	GlitchData    => MIMRXBWDATA58_GlitchData,
	OutSignalName => "MIMRXBWDATA(58)",
	OutTemp       => MIMRXBWDATA_OUT(58),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(59),
	GlitchData    => MIMRXBWDATA59_GlitchData,
	OutSignalName => "MIMRXBWDATA(59)",
	OutTemp       => MIMRXBWDATA_OUT(59),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(60),
	GlitchData    => MIMRXBWDATA60_GlitchData,
	OutSignalName => "MIMRXBWDATA(60)",
	OutTemp       => MIMRXBWDATA_OUT(60),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(61),
	GlitchData    => MIMRXBWDATA61_GlitchData,
	OutSignalName => "MIMRXBWDATA(61)",
	OutTemp       => MIMRXBWDATA_OUT(61),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(62),
	GlitchData    => MIMRXBWDATA62_GlitchData,
	OutSignalName => "MIMRXBWDATA(62)",
	OutTemp       => MIMRXBWDATA_OUT(62),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWDATA(63),
	GlitchData    => MIMRXBWDATA63_GlitchData,
	OutSignalName => "MIMRXBWDATA(63)",
	OutTemp       => MIMRXBWDATA_OUT(63),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(0),
	GlitchData    => MIMRXBWADD0_GlitchData,
	OutSignalName => "MIMRXBWADD(0)",
	OutTemp       => MIMRXBWADD_OUT(0),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(1),
	GlitchData    => MIMRXBWADD1_GlitchData,
	OutSignalName => "MIMRXBWADD(1)",
	OutTemp       => MIMRXBWADD_OUT(1),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(2),
	GlitchData    => MIMRXBWADD2_GlitchData,
	OutSignalName => "MIMRXBWADD(2)",
	OutTemp       => MIMRXBWADD_OUT(2),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(3),
	GlitchData    => MIMRXBWADD3_GlitchData,
	OutSignalName => "MIMRXBWADD(3)",
	OutTemp       => MIMRXBWADD_OUT(3),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(4),
	GlitchData    => MIMRXBWADD4_GlitchData,
	OutSignalName => "MIMRXBWADD(4)",
	OutTemp       => MIMRXBWADD_OUT(4),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(5),
	GlitchData    => MIMRXBWADD5_GlitchData,
	OutSignalName => "MIMRXBWADD(5)",
	OutTemp       => MIMRXBWADD_OUT(5),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(6),
	GlitchData    => MIMRXBWADD6_GlitchData,
	OutSignalName => "MIMRXBWADD(6)",
	OutTemp       => MIMRXBWADD_OUT(6),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(7),
	GlitchData    => MIMRXBWADD7_GlitchData,
	OutSignalName => "MIMRXBWADD(7)",
	OutTemp       => MIMRXBWADD_OUT(7),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(8),
	GlitchData    => MIMRXBWADD8_GlitchData,
	OutSignalName => "MIMRXBWADD(8)",
	OutTemp       => MIMRXBWADD_OUT(8),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(9),
	GlitchData    => MIMRXBWADD9_GlitchData,
	OutSignalName => "MIMRXBWADD(9)",
	OutTemp       => MIMRXBWADD_OUT(9),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(10),
	GlitchData    => MIMRXBWADD10_GlitchData,
	OutSignalName => "MIMRXBWADD(10)",
	OutTemp       => MIMRXBWADD_OUT(10),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(11),
	GlitchData    => MIMRXBWADD11_GlitchData,
	OutSignalName => "MIMRXBWADD(11)",
	OutTemp       => MIMRXBWADD_OUT(11),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWADD(12),
	GlitchData    => MIMRXBWADD12_GlitchData,
	OutSignalName => "MIMRXBWADD(12)",
	OutTemp       => MIMRXBWADD_OUT(12),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(0),
	GlitchData    => MIMRXBRADD0_GlitchData,
	OutSignalName => "MIMRXBRADD(0)",
	OutTemp       => MIMRXBRADD_OUT(0),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(0),
	GlitchData    => MIMRXBRADD0_GlitchData,
	OutSignalName => "MIMRXBRADD(0)",
	OutTemp       => MIMRXBRADD_OUT(0),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(1),
	GlitchData    => MIMRXBRADD1_GlitchData,
	OutSignalName => "MIMRXBRADD(1)",
	OutTemp       => MIMRXBRADD_OUT(1),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(1),
	GlitchData    => MIMRXBRADD1_GlitchData,
	OutSignalName => "MIMRXBRADD(1)",
	OutTemp       => MIMRXBRADD_OUT(1),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(2),
	GlitchData    => MIMRXBRADD2_GlitchData,
	OutSignalName => "MIMRXBRADD(2)",
	OutTemp       => MIMRXBRADD_OUT(2),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(2),
	GlitchData    => MIMRXBRADD2_GlitchData,
	OutSignalName => "MIMRXBRADD(2)",
	OutTemp       => MIMRXBRADD_OUT(2),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(3),
	GlitchData    => MIMRXBRADD3_GlitchData,
	OutSignalName => "MIMRXBRADD(3)",
	OutTemp       => MIMRXBRADD_OUT(3),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(3),
	GlitchData    => MIMRXBRADD3_GlitchData,
	OutSignalName => "MIMRXBRADD(3)",
	OutTemp       => MIMRXBRADD_OUT(3),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(4),
	GlitchData    => MIMRXBRADD4_GlitchData,
	OutSignalName => "MIMRXBRADD(4)",
	OutTemp       => MIMRXBRADD_OUT(4),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(4),
	GlitchData    => MIMRXBRADD4_GlitchData,
	OutSignalName => "MIMRXBRADD(4)",
	OutTemp       => MIMRXBRADD_OUT(4),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(5),
	GlitchData    => MIMRXBRADD5_GlitchData,
	OutSignalName => "MIMRXBRADD(5)",
	OutTemp       => MIMRXBRADD_OUT(5),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(5),
	GlitchData    => MIMRXBRADD5_GlitchData,
	OutSignalName => "MIMRXBRADD(5)",
	OutTemp       => MIMRXBRADD_OUT(5),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(6),
	GlitchData    => MIMRXBRADD6_GlitchData,
	OutSignalName => "MIMRXBRADD(6)",
	OutTemp       => MIMRXBRADD_OUT(6),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(6),
	GlitchData    => MIMRXBRADD6_GlitchData,
	OutSignalName => "MIMRXBRADD(6)",
	OutTemp       => MIMRXBRADD_OUT(6),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(7),
	GlitchData    => MIMRXBRADD7_GlitchData,
	OutSignalName => "MIMRXBRADD(7)",
	OutTemp       => MIMRXBRADD_OUT(7),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(7),
	GlitchData    => MIMRXBRADD7_GlitchData,
	OutSignalName => "MIMRXBRADD(7)",
	OutTemp       => MIMRXBRADD_OUT(7),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(8),
	GlitchData    => MIMRXBRADD8_GlitchData,
	OutSignalName => "MIMRXBRADD(8)",
	OutTemp       => MIMRXBRADD_OUT(8),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(8),
	GlitchData    => MIMRXBRADD8_GlitchData,
	OutSignalName => "MIMRXBRADD(8)",
	OutTemp       => MIMRXBRADD_OUT(8),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(9),
	GlitchData    => MIMRXBRADD9_GlitchData,
	OutSignalName => "MIMRXBRADD(9)",
	OutTemp       => MIMRXBRADD_OUT(9),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(9),
	GlitchData    => MIMRXBRADD9_GlitchData,
	OutSignalName => "MIMRXBRADD(9)",
	OutTemp       => MIMRXBRADD_OUT(9),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(10),
	GlitchData    => MIMRXBRADD10_GlitchData,
	OutSignalName => "MIMRXBRADD(10)",
	OutTemp       => MIMRXBRADD_OUT(10),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(10),
	GlitchData    => MIMRXBRADD10_GlitchData,
	OutSignalName => "MIMRXBRADD(10)",
	OutTemp       => MIMRXBRADD_OUT(10),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(11),
	GlitchData    => MIMRXBRADD11_GlitchData,
	OutSignalName => "MIMRXBRADD(11)",
	OutTemp       => MIMRXBRADD_OUT(11),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(11),
	GlitchData    => MIMRXBRADD11_GlitchData,
	OutSignalName => "MIMRXBRADD(11)",
	OutTemp       => MIMRXBRADD_OUT(11),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(12),
	GlitchData    => MIMRXBRADD12_GlitchData,
	OutSignalName => "MIMRXBRADD(12)",
	OutTemp       => MIMRXBRADD_OUT(12),
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBRADD(12),
	GlitchData    => MIMRXBRADD12_GlitchData,
	OutSignalName => "MIMRXBRADD(12)",
	OutTemp       => MIMRXBRADD_OUT(12),
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBWEN,
	GlitchData    => MIMRXBWEN_GlitchData,
	OutSignalName => "MIMRXBWEN",
	OutTemp       => MIMRXBWEN_OUT,
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBREN,
	GlitchData    => MIMRXBREN_GlitchData,
	OutSignalName => "MIMRXBREN",
	OutTemp       => MIMRXBREN_OUT,
	Paths         => (0 => (CRMUSERCLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMRXBREN,
	GlitchData    => MIMRXBREN_GlitchData,
	OutSignalName => "MIMRXBREN",
	OutTemp       => MIMRXBREN_OUT,
	Paths         => (0 => (CRMCORECLKRXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(0),
	GlitchData    => MIMTXBWDATA0_GlitchData,
	OutSignalName => "MIMTXBWDATA(0)",
	OutTemp       => MIMTXBWDATA_OUT(0),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(0),
	GlitchData    => MIMTXBWDATA0_GlitchData,
	OutSignalName => "MIMTXBWDATA(0)",
	OutTemp       => MIMTXBWDATA_OUT(0),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(1),
	GlitchData    => MIMTXBWDATA1_GlitchData,
	OutSignalName => "MIMTXBWDATA(1)",
	OutTemp       => MIMTXBWDATA_OUT(1),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(1),
	GlitchData    => MIMTXBWDATA1_GlitchData,
	OutSignalName => "MIMTXBWDATA(1)",
	OutTemp       => MIMTXBWDATA_OUT(1),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(2),
	GlitchData    => MIMTXBWDATA2_GlitchData,
	OutSignalName => "MIMTXBWDATA(2)",
	OutTemp       => MIMTXBWDATA_OUT(2),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(2),
	GlitchData    => MIMTXBWDATA2_GlitchData,
	OutSignalName => "MIMTXBWDATA(2)",
	OutTemp       => MIMTXBWDATA_OUT(2),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(3),
	GlitchData    => MIMTXBWDATA3_GlitchData,
	OutSignalName => "MIMTXBWDATA(3)",
	OutTemp       => MIMTXBWDATA_OUT(3),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(3),
	GlitchData    => MIMTXBWDATA3_GlitchData,
	OutSignalName => "MIMTXBWDATA(3)",
	OutTemp       => MIMTXBWDATA_OUT(3),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(4),
	GlitchData    => MIMTXBWDATA4_GlitchData,
	OutSignalName => "MIMTXBWDATA(4)",
	OutTemp       => MIMTXBWDATA_OUT(4),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(4),
	GlitchData    => MIMTXBWDATA4_GlitchData,
	OutSignalName => "MIMTXBWDATA(4)",
	OutTemp       => MIMTXBWDATA_OUT(4),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(5),
	GlitchData    => MIMTXBWDATA5_GlitchData,
	OutSignalName => "MIMTXBWDATA(5)",
	OutTemp       => MIMTXBWDATA_OUT(5),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(5),
	GlitchData    => MIMTXBWDATA5_GlitchData,
	OutSignalName => "MIMTXBWDATA(5)",
	OutTemp       => MIMTXBWDATA_OUT(5),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(6),
	GlitchData    => MIMTXBWDATA6_GlitchData,
	OutSignalName => "MIMTXBWDATA(6)",
	OutTemp       => MIMTXBWDATA_OUT(6),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(6),
	GlitchData    => MIMTXBWDATA6_GlitchData,
	OutSignalName => "MIMTXBWDATA(6)",
	OutTemp       => MIMTXBWDATA_OUT(6),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(7),
	GlitchData    => MIMTXBWDATA7_GlitchData,
	OutSignalName => "MIMTXBWDATA(7)",
	OutTemp       => MIMTXBWDATA_OUT(7),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(7),
	GlitchData    => MIMTXBWDATA7_GlitchData,
	OutSignalName => "MIMTXBWDATA(7)",
	OutTemp       => MIMTXBWDATA_OUT(7),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(8),
	GlitchData    => MIMTXBWDATA8_GlitchData,
	OutSignalName => "MIMTXBWDATA(8)",
	OutTemp       => MIMTXBWDATA_OUT(8),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(8),
	GlitchData    => MIMTXBWDATA8_GlitchData,
	OutSignalName => "MIMTXBWDATA(8)",
	OutTemp       => MIMTXBWDATA_OUT(8),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(9),
	GlitchData    => MIMTXBWDATA9_GlitchData,
	OutSignalName => "MIMTXBWDATA(9)",
	OutTemp       => MIMTXBWDATA_OUT(9),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(9),
	GlitchData    => MIMTXBWDATA9_GlitchData,
	OutSignalName => "MIMTXBWDATA(9)",
	OutTemp       => MIMTXBWDATA_OUT(9),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(10),
	GlitchData    => MIMTXBWDATA10_GlitchData,
	OutSignalName => "MIMTXBWDATA(10)",
	OutTemp       => MIMTXBWDATA_OUT(10),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(10),
	GlitchData    => MIMTXBWDATA10_GlitchData,
	OutSignalName => "MIMTXBWDATA(10)",
	OutTemp       => MIMTXBWDATA_OUT(10),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(11),
	GlitchData    => MIMTXBWDATA11_GlitchData,
	OutSignalName => "MIMTXBWDATA(11)",
	OutTemp       => MIMTXBWDATA_OUT(11),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(11),
	GlitchData    => MIMTXBWDATA11_GlitchData,
	OutSignalName => "MIMTXBWDATA(11)",
	OutTemp       => MIMTXBWDATA_OUT(11),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(12),
	GlitchData    => MIMTXBWDATA12_GlitchData,
	OutSignalName => "MIMTXBWDATA(12)",
	OutTemp       => MIMTXBWDATA_OUT(12),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(12),
	GlitchData    => MIMTXBWDATA12_GlitchData,
	OutSignalName => "MIMTXBWDATA(12)",
	OutTemp       => MIMTXBWDATA_OUT(12),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(13),
	GlitchData    => MIMTXBWDATA13_GlitchData,
	OutSignalName => "MIMTXBWDATA(13)",
	OutTemp       => MIMTXBWDATA_OUT(13),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(13),
	GlitchData    => MIMTXBWDATA13_GlitchData,
	OutSignalName => "MIMTXBWDATA(13)",
	OutTemp       => MIMTXBWDATA_OUT(13),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(14),
	GlitchData    => MIMTXBWDATA14_GlitchData,
	OutSignalName => "MIMTXBWDATA(14)",
	OutTemp       => MIMTXBWDATA_OUT(14),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(14),
	GlitchData    => MIMTXBWDATA14_GlitchData,
	OutSignalName => "MIMTXBWDATA(14)",
	OutTemp       => MIMTXBWDATA_OUT(14),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(15),
	GlitchData    => MIMTXBWDATA15_GlitchData,
	OutSignalName => "MIMTXBWDATA(15)",
	OutTemp       => MIMTXBWDATA_OUT(15),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(15),
	GlitchData    => MIMTXBWDATA15_GlitchData,
	OutSignalName => "MIMTXBWDATA(15)",
	OutTemp       => MIMTXBWDATA_OUT(15),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(16),
	GlitchData    => MIMTXBWDATA16_GlitchData,
	OutSignalName => "MIMTXBWDATA(16)",
	OutTemp       => MIMTXBWDATA_OUT(16),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(16),
	GlitchData    => MIMTXBWDATA16_GlitchData,
	OutSignalName => "MIMTXBWDATA(16)",
	OutTemp       => MIMTXBWDATA_OUT(16),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(17),
	GlitchData    => MIMTXBWDATA17_GlitchData,
	OutSignalName => "MIMTXBWDATA(17)",
	OutTemp       => MIMTXBWDATA_OUT(17),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(17),
	GlitchData    => MIMTXBWDATA17_GlitchData,
	OutSignalName => "MIMTXBWDATA(17)",
	OutTemp       => MIMTXBWDATA_OUT(17),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(18),
	GlitchData    => MIMTXBWDATA18_GlitchData,
	OutSignalName => "MIMTXBWDATA(18)",
	OutTemp       => MIMTXBWDATA_OUT(18),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(18),
	GlitchData    => MIMTXBWDATA18_GlitchData,
	OutSignalName => "MIMTXBWDATA(18)",
	OutTemp       => MIMTXBWDATA_OUT(18),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(19),
	GlitchData    => MIMTXBWDATA19_GlitchData,
	OutSignalName => "MIMTXBWDATA(19)",
	OutTemp       => MIMTXBWDATA_OUT(19),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(19),
	GlitchData    => MIMTXBWDATA19_GlitchData,
	OutSignalName => "MIMTXBWDATA(19)",
	OutTemp       => MIMTXBWDATA_OUT(19),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(20),
	GlitchData    => MIMTXBWDATA20_GlitchData,
	OutSignalName => "MIMTXBWDATA(20)",
	OutTemp       => MIMTXBWDATA_OUT(20),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(20),
	GlitchData    => MIMTXBWDATA20_GlitchData,
	OutSignalName => "MIMTXBWDATA(20)",
	OutTemp       => MIMTXBWDATA_OUT(20),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(21),
	GlitchData    => MIMTXBWDATA21_GlitchData,
	OutSignalName => "MIMTXBWDATA(21)",
	OutTemp       => MIMTXBWDATA_OUT(21),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(21),
	GlitchData    => MIMTXBWDATA21_GlitchData,
	OutSignalName => "MIMTXBWDATA(21)",
	OutTemp       => MIMTXBWDATA_OUT(21),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(22),
	GlitchData    => MIMTXBWDATA22_GlitchData,
	OutSignalName => "MIMTXBWDATA(22)",
	OutTemp       => MIMTXBWDATA_OUT(22),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(22),
	GlitchData    => MIMTXBWDATA22_GlitchData,
	OutSignalName => "MIMTXBWDATA(22)",
	OutTemp       => MIMTXBWDATA_OUT(22),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(23),
	GlitchData    => MIMTXBWDATA23_GlitchData,
	OutSignalName => "MIMTXBWDATA(23)",
	OutTemp       => MIMTXBWDATA_OUT(23),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(23),
	GlitchData    => MIMTXBWDATA23_GlitchData,
	OutSignalName => "MIMTXBWDATA(23)",
	OutTemp       => MIMTXBWDATA_OUT(23),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(24),
	GlitchData    => MIMTXBWDATA24_GlitchData,
	OutSignalName => "MIMTXBWDATA(24)",
	OutTemp       => MIMTXBWDATA_OUT(24),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(24),
	GlitchData    => MIMTXBWDATA24_GlitchData,
	OutSignalName => "MIMTXBWDATA(24)",
	OutTemp       => MIMTXBWDATA_OUT(24),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(25),
	GlitchData    => MIMTXBWDATA25_GlitchData,
	OutSignalName => "MIMTXBWDATA(25)",
	OutTemp       => MIMTXBWDATA_OUT(25),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(25),
	GlitchData    => MIMTXBWDATA25_GlitchData,
	OutSignalName => "MIMTXBWDATA(25)",
	OutTemp       => MIMTXBWDATA_OUT(25),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(26),
	GlitchData    => MIMTXBWDATA26_GlitchData,
	OutSignalName => "MIMTXBWDATA(26)",
	OutTemp       => MIMTXBWDATA_OUT(26),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(26),
	GlitchData    => MIMTXBWDATA26_GlitchData,
	OutSignalName => "MIMTXBWDATA(26)",
	OutTemp       => MIMTXBWDATA_OUT(26),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(27),
	GlitchData    => MIMTXBWDATA27_GlitchData,
	OutSignalName => "MIMTXBWDATA(27)",
	OutTemp       => MIMTXBWDATA_OUT(27),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(27),
	GlitchData    => MIMTXBWDATA27_GlitchData,
	OutSignalName => "MIMTXBWDATA(27)",
	OutTemp       => MIMTXBWDATA_OUT(27),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(28),
	GlitchData    => MIMTXBWDATA28_GlitchData,
	OutSignalName => "MIMTXBWDATA(28)",
	OutTemp       => MIMTXBWDATA_OUT(28),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(28),
	GlitchData    => MIMTXBWDATA28_GlitchData,
	OutSignalName => "MIMTXBWDATA(28)",
	OutTemp       => MIMTXBWDATA_OUT(28),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(29),
	GlitchData    => MIMTXBWDATA29_GlitchData,
	OutSignalName => "MIMTXBWDATA(29)",
	OutTemp       => MIMTXBWDATA_OUT(29),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(29),
	GlitchData    => MIMTXBWDATA29_GlitchData,
	OutSignalName => "MIMTXBWDATA(29)",
	OutTemp       => MIMTXBWDATA_OUT(29),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(30),
	GlitchData    => MIMTXBWDATA30_GlitchData,
	OutSignalName => "MIMTXBWDATA(30)",
	OutTemp       => MIMTXBWDATA_OUT(30),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(30),
	GlitchData    => MIMTXBWDATA30_GlitchData,
	OutSignalName => "MIMTXBWDATA(30)",
	OutTemp       => MIMTXBWDATA_OUT(30),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(31),
	GlitchData    => MIMTXBWDATA31_GlitchData,
	OutSignalName => "MIMTXBWDATA(31)",
	OutTemp       => MIMTXBWDATA_OUT(31),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(31),
	GlitchData    => MIMTXBWDATA31_GlitchData,
	OutSignalName => "MIMTXBWDATA(31)",
	OutTemp       => MIMTXBWDATA_OUT(31),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(32),
	GlitchData    => MIMTXBWDATA32_GlitchData,
	OutSignalName => "MIMTXBWDATA(32)",
	OutTemp       => MIMTXBWDATA_OUT(32),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(32),
	GlitchData    => MIMTXBWDATA32_GlitchData,
	OutSignalName => "MIMTXBWDATA(32)",
	OutTemp       => MIMTXBWDATA_OUT(32),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(33),
	GlitchData    => MIMTXBWDATA33_GlitchData,
	OutSignalName => "MIMTXBWDATA(33)",
	OutTemp       => MIMTXBWDATA_OUT(33),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(33),
	GlitchData    => MIMTXBWDATA33_GlitchData,
	OutSignalName => "MIMTXBWDATA(33)",
	OutTemp       => MIMTXBWDATA_OUT(33),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(34),
	GlitchData    => MIMTXBWDATA34_GlitchData,
	OutSignalName => "MIMTXBWDATA(34)",
	OutTemp       => MIMTXBWDATA_OUT(34),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(34),
	GlitchData    => MIMTXBWDATA34_GlitchData,
	OutSignalName => "MIMTXBWDATA(34)",
	OutTemp       => MIMTXBWDATA_OUT(34),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(35),
	GlitchData    => MIMTXBWDATA35_GlitchData,
	OutSignalName => "MIMTXBWDATA(35)",
	OutTemp       => MIMTXBWDATA_OUT(35),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(35),
	GlitchData    => MIMTXBWDATA35_GlitchData,
	OutSignalName => "MIMTXBWDATA(35)",
	OutTemp       => MIMTXBWDATA_OUT(35),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(36),
	GlitchData    => MIMTXBWDATA36_GlitchData,
	OutSignalName => "MIMTXBWDATA(36)",
	OutTemp       => MIMTXBWDATA_OUT(36),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(36),
	GlitchData    => MIMTXBWDATA36_GlitchData,
	OutSignalName => "MIMTXBWDATA(36)",
	OutTemp       => MIMTXBWDATA_OUT(36),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(37),
	GlitchData    => MIMTXBWDATA37_GlitchData,
	OutSignalName => "MIMTXBWDATA(37)",
	OutTemp       => MIMTXBWDATA_OUT(37),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(37),
	GlitchData    => MIMTXBWDATA37_GlitchData,
	OutSignalName => "MIMTXBWDATA(37)",
	OutTemp       => MIMTXBWDATA_OUT(37),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(38),
	GlitchData    => MIMTXBWDATA38_GlitchData,
	OutSignalName => "MIMTXBWDATA(38)",
	OutTemp       => MIMTXBWDATA_OUT(38),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(38),
	GlitchData    => MIMTXBWDATA38_GlitchData,
	OutSignalName => "MIMTXBWDATA(38)",
	OutTemp       => MIMTXBWDATA_OUT(38),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(39),
	GlitchData    => MIMTXBWDATA39_GlitchData,
	OutSignalName => "MIMTXBWDATA(39)",
	OutTemp       => MIMTXBWDATA_OUT(39),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(39),
	GlitchData    => MIMTXBWDATA39_GlitchData,
	OutSignalName => "MIMTXBWDATA(39)",
	OutTemp       => MIMTXBWDATA_OUT(39),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(40),
	GlitchData    => MIMTXBWDATA40_GlitchData,
	OutSignalName => "MIMTXBWDATA(40)",
	OutTemp       => MIMTXBWDATA_OUT(40),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(40),
	GlitchData    => MIMTXBWDATA40_GlitchData,
	OutSignalName => "MIMTXBWDATA(40)",
	OutTemp       => MIMTXBWDATA_OUT(40),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(41),
	GlitchData    => MIMTXBWDATA41_GlitchData,
	OutSignalName => "MIMTXBWDATA(41)",
	OutTemp       => MIMTXBWDATA_OUT(41),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(41),
	GlitchData    => MIMTXBWDATA41_GlitchData,
	OutSignalName => "MIMTXBWDATA(41)",
	OutTemp       => MIMTXBWDATA_OUT(41),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(42),
	GlitchData    => MIMTXBWDATA42_GlitchData,
	OutSignalName => "MIMTXBWDATA(42)",
	OutTemp       => MIMTXBWDATA_OUT(42),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(42),
	GlitchData    => MIMTXBWDATA42_GlitchData,
	OutSignalName => "MIMTXBWDATA(42)",
	OutTemp       => MIMTXBWDATA_OUT(42),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(43),
	GlitchData    => MIMTXBWDATA43_GlitchData,
	OutSignalName => "MIMTXBWDATA(43)",
	OutTemp       => MIMTXBWDATA_OUT(43),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(43),
	GlitchData    => MIMTXBWDATA43_GlitchData,
	OutSignalName => "MIMTXBWDATA(43)",
	OutTemp       => MIMTXBWDATA_OUT(43),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(44),
	GlitchData    => MIMTXBWDATA44_GlitchData,
	OutSignalName => "MIMTXBWDATA(44)",
	OutTemp       => MIMTXBWDATA_OUT(44),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(44),
	GlitchData    => MIMTXBWDATA44_GlitchData,
	OutSignalName => "MIMTXBWDATA(44)",
	OutTemp       => MIMTXBWDATA_OUT(44),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(45),
	GlitchData    => MIMTXBWDATA45_GlitchData,
	OutSignalName => "MIMTXBWDATA(45)",
	OutTemp       => MIMTXBWDATA_OUT(45),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(45),
	GlitchData    => MIMTXBWDATA45_GlitchData,
	OutSignalName => "MIMTXBWDATA(45)",
	OutTemp       => MIMTXBWDATA_OUT(45),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(46),
	GlitchData    => MIMTXBWDATA46_GlitchData,
	OutSignalName => "MIMTXBWDATA(46)",
	OutTemp       => MIMTXBWDATA_OUT(46),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(46),
	GlitchData    => MIMTXBWDATA46_GlitchData,
	OutSignalName => "MIMTXBWDATA(46)",
	OutTemp       => MIMTXBWDATA_OUT(46),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(47),
	GlitchData    => MIMTXBWDATA47_GlitchData,
	OutSignalName => "MIMTXBWDATA(47)",
	OutTemp       => MIMTXBWDATA_OUT(47),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(47),
	GlitchData    => MIMTXBWDATA47_GlitchData,
	OutSignalName => "MIMTXBWDATA(47)",
	OutTemp       => MIMTXBWDATA_OUT(47),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(48),
	GlitchData    => MIMTXBWDATA48_GlitchData,
	OutSignalName => "MIMTXBWDATA(48)",
	OutTemp       => MIMTXBWDATA_OUT(48),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(48),
	GlitchData    => MIMTXBWDATA48_GlitchData,
	OutSignalName => "MIMTXBWDATA(48)",
	OutTemp       => MIMTXBWDATA_OUT(48),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(49),
	GlitchData    => MIMTXBWDATA49_GlitchData,
	OutSignalName => "MIMTXBWDATA(49)",
	OutTemp       => MIMTXBWDATA_OUT(49),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(49),
	GlitchData    => MIMTXBWDATA49_GlitchData,
	OutSignalName => "MIMTXBWDATA(49)",
	OutTemp       => MIMTXBWDATA_OUT(49),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(50),
	GlitchData    => MIMTXBWDATA50_GlitchData,
	OutSignalName => "MIMTXBWDATA(50)",
	OutTemp       => MIMTXBWDATA_OUT(50),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(50),
	GlitchData    => MIMTXBWDATA50_GlitchData,
	OutSignalName => "MIMTXBWDATA(50)",
	OutTemp       => MIMTXBWDATA_OUT(50),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(51),
	GlitchData    => MIMTXBWDATA51_GlitchData,
	OutSignalName => "MIMTXBWDATA(51)",
	OutTemp       => MIMTXBWDATA_OUT(51),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(51),
	GlitchData    => MIMTXBWDATA51_GlitchData,
	OutSignalName => "MIMTXBWDATA(51)",
	OutTemp       => MIMTXBWDATA_OUT(51),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(52),
	GlitchData    => MIMTXBWDATA52_GlitchData,
	OutSignalName => "MIMTXBWDATA(52)",
	OutTemp       => MIMTXBWDATA_OUT(52),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(52),
	GlitchData    => MIMTXBWDATA52_GlitchData,
	OutSignalName => "MIMTXBWDATA(52)",
	OutTemp       => MIMTXBWDATA_OUT(52),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(53),
	GlitchData    => MIMTXBWDATA53_GlitchData,
	OutSignalName => "MIMTXBWDATA(53)",
	OutTemp       => MIMTXBWDATA_OUT(53),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(53),
	GlitchData    => MIMTXBWDATA53_GlitchData,
	OutSignalName => "MIMTXBWDATA(53)",
	OutTemp       => MIMTXBWDATA_OUT(53),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(54),
	GlitchData    => MIMTXBWDATA54_GlitchData,
	OutSignalName => "MIMTXBWDATA(54)",
	OutTemp       => MIMTXBWDATA_OUT(54),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(54),
	GlitchData    => MIMTXBWDATA54_GlitchData,
	OutSignalName => "MIMTXBWDATA(54)",
	OutTemp       => MIMTXBWDATA_OUT(54),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(55),
	GlitchData    => MIMTXBWDATA55_GlitchData,
	OutSignalName => "MIMTXBWDATA(55)",
	OutTemp       => MIMTXBWDATA_OUT(55),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(55),
	GlitchData    => MIMTXBWDATA55_GlitchData,
	OutSignalName => "MIMTXBWDATA(55)",
	OutTemp       => MIMTXBWDATA_OUT(55),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(56),
	GlitchData    => MIMTXBWDATA56_GlitchData,
	OutSignalName => "MIMTXBWDATA(56)",
	OutTemp       => MIMTXBWDATA_OUT(56),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(56),
	GlitchData    => MIMTXBWDATA56_GlitchData,
	OutSignalName => "MIMTXBWDATA(56)",
	OutTemp       => MIMTXBWDATA_OUT(56),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(57),
	GlitchData    => MIMTXBWDATA57_GlitchData,
	OutSignalName => "MIMTXBWDATA(57)",
	OutTemp       => MIMTXBWDATA_OUT(57),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(57),
	GlitchData    => MIMTXBWDATA57_GlitchData,
	OutSignalName => "MIMTXBWDATA(57)",
	OutTemp       => MIMTXBWDATA_OUT(57),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(58),
	GlitchData    => MIMTXBWDATA58_GlitchData,
	OutSignalName => "MIMTXBWDATA(58)",
	OutTemp       => MIMTXBWDATA_OUT(58),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(58),
	GlitchData    => MIMTXBWDATA58_GlitchData,
	OutSignalName => "MIMTXBWDATA(58)",
	OutTemp       => MIMTXBWDATA_OUT(58),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(59),
	GlitchData    => MIMTXBWDATA59_GlitchData,
	OutSignalName => "MIMTXBWDATA(59)",
	OutTemp       => MIMTXBWDATA_OUT(59),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(59),
	GlitchData    => MIMTXBWDATA59_GlitchData,
	OutSignalName => "MIMTXBWDATA(59)",
	OutTemp       => MIMTXBWDATA_OUT(59),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(60),
	GlitchData    => MIMTXBWDATA60_GlitchData,
	OutSignalName => "MIMTXBWDATA(60)",
	OutTemp       => MIMTXBWDATA_OUT(60),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(60),
	GlitchData    => MIMTXBWDATA60_GlitchData,
	OutSignalName => "MIMTXBWDATA(60)",
	OutTemp       => MIMTXBWDATA_OUT(60),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(61),
	GlitchData    => MIMTXBWDATA61_GlitchData,
	OutSignalName => "MIMTXBWDATA(61)",
	OutTemp       => MIMTXBWDATA_OUT(61),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(61),
	GlitchData    => MIMTXBWDATA61_GlitchData,
	OutSignalName => "MIMTXBWDATA(61)",
	OutTemp       => MIMTXBWDATA_OUT(61),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(62),
	GlitchData    => MIMTXBWDATA62_GlitchData,
	OutSignalName => "MIMTXBWDATA(62)",
	OutTemp       => MIMTXBWDATA_OUT(62),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(62),
	GlitchData    => MIMTXBWDATA62_GlitchData,
	OutSignalName => "MIMTXBWDATA(62)",
	OutTemp       => MIMTXBWDATA_OUT(62),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(63),
	GlitchData    => MIMTXBWDATA63_GlitchData,
	OutSignalName => "MIMTXBWDATA(63)",
	OutTemp       => MIMTXBWDATA_OUT(63),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWDATA(63),
	GlitchData    => MIMTXBWDATA63_GlitchData,
	OutSignalName => "MIMTXBWDATA(63)",
	OutTemp       => MIMTXBWDATA_OUT(63),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(0),
	GlitchData    => MIMTXBWADD0_GlitchData,
	OutSignalName => "MIMTXBWADD(0)",
	OutTemp       => MIMTXBWADD_OUT(0),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(0),
	GlitchData    => MIMTXBWADD0_GlitchData,
	OutSignalName => "MIMTXBWADD(0)",
	OutTemp       => MIMTXBWADD_OUT(0),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(1),
	GlitchData    => MIMTXBWADD1_GlitchData,
	OutSignalName => "MIMTXBWADD(1)",
	OutTemp       => MIMTXBWADD_OUT(1),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(1),
	GlitchData    => MIMTXBWADD1_GlitchData,
	OutSignalName => "MIMTXBWADD(1)",
	OutTemp       => MIMTXBWADD_OUT(1),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(2),
	GlitchData    => MIMTXBWADD2_GlitchData,
	OutSignalName => "MIMTXBWADD(2)",
	OutTemp       => MIMTXBWADD_OUT(2),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(2),
	GlitchData    => MIMTXBWADD2_GlitchData,
	OutSignalName => "MIMTXBWADD(2)",
	OutTemp       => MIMTXBWADD_OUT(2),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(3),
	GlitchData    => MIMTXBWADD3_GlitchData,
	OutSignalName => "MIMTXBWADD(3)",
	OutTemp       => MIMTXBWADD_OUT(3),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(3),
	GlitchData    => MIMTXBWADD3_GlitchData,
	OutSignalName => "MIMTXBWADD(3)",
	OutTemp       => MIMTXBWADD_OUT(3),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(4),
	GlitchData    => MIMTXBWADD4_GlitchData,
	OutSignalName => "MIMTXBWADD(4)",
	OutTemp       => MIMTXBWADD_OUT(4),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(4),
	GlitchData    => MIMTXBWADD4_GlitchData,
	OutSignalName => "MIMTXBWADD(4)",
	OutTemp       => MIMTXBWADD_OUT(4),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(5),
	GlitchData    => MIMTXBWADD5_GlitchData,
	OutSignalName => "MIMTXBWADD(5)",
	OutTemp       => MIMTXBWADD_OUT(5),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(5),
	GlitchData    => MIMTXBWADD5_GlitchData,
	OutSignalName => "MIMTXBWADD(5)",
	OutTemp       => MIMTXBWADD_OUT(5),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(6),
	GlitchData    => MIMTXBWADD6_GlitchData,
	OutSignalName => "MIMTXBWADD(6)",
	OutTemp       => MIMTXBWADD_OUT(6),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(6),
	GlitchData    => MIMTXBWADD6_GlitchData,
	OutSignalName => "MIMTXBWADD(6)",
	OutTemp       => MIMTXBWADD_OUT(6),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(7),
	GlitchData    => MIMTXBWADD7_GlitchData,
	OutSignalName => "MIMTXBWADD(7)",
	OutTemp       => MIMTXBWADD_OUT(7),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(7),
	GlitchData    => MIMTXBWADD7_GlitchData,
	OutSignalName => "MIMTXBWADD(7)",
	OutTemp       => MIMTXBWADD_OUT(7),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(8),
	GlitchData    => MIMTXBWADD8_GlitchData,
	OutSignalName => "MIMTXBWADD(8)",
	OutTemp       => MIMTXBWADD_OUT(8),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(8),
	GlitchData    => MIMTXBWADD8_GlitchData,
	OutSignalName => "MIMTXBWADD(8)",
	OutTemp       => MIMTXBWADD_OUT(8),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(9),
	GlitchData    => MIMTXBWADD9_GlitchData,
	OutSignalName => "MIMTXBWADD(9)",
	OutTemp       => MIMTXBWADD_OUT(9),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(9),
	GlitchData    => MIMTXBWADD9_GlitchData,
	OutSignalName => "MIMTXBWADD(9)",
	OutTemp       => MIMTXBWADD_OUT(9),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(10),
	GlitchData    => MIMTXBWADD10_GlitchData,
	OutSignalName => "MIMTXBWADD(10)",
	OutTemp       => MIMTXBWADD_OUT(10),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(10),
	GlitchData    => MIMTXBWADD10_GlitchData,
	OutSignalName => "MIMTXBWADD(10)",
	OutTemp       => MIMTXBWADD_OUT(10),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(11),
	GlitchData    => MIMTXBWADD11_GlitchData,
	OutSignalName => "MIMTXBWADD(11)",
	OutTemp       => MIMTXBWADD_OUT(11),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(11),
	GlitchData    => MIMTXBWADD11_GlitchData,
	OutSignalName => "MIMTXBWADD(11)",
	OutTemp       => MIMTXBWADD_OUT(11),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(12),
	GlitchData    => MIMTXBWADD12_GlitchData,
	OutSignalName => "MIMTXBWADD(12)",
	OutTemp       => MIMTXBWADD_OUT(12),
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWADD(12),
	GlitchData    => MIMTXBWADD12_GlitchData,
	OutSignalName => "MIMTXBWADD(12)",
	OutTemp       => MIMTXBWADD_OUT(12),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(0),
	GlitchData    => MIMTXBRADD0_GlitchData,
	OutSignalName => "MIMTXBRADD(0)",
	OutTemp       => MIMTXBRADD_OUT(0),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(1),
	GlitchData    => MIMTXBRADD1_GlitchData,
	OutSignalName => "MIMTXBRADD(1)",
	OutTemp       => MIMTXBRADD_OUT(1),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(2),
	GlitchData    => MIMTXBRADD2_GlitchData,
	OutSignalName => "MIMTXBRADD(2)",
	OutTemp       => MIMTXBRADD_OUT(2),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(3),
	GlitchData    => MIMTXBRADD3_GlitchData,
	OutSignalName => "MIMTXBRADD(3)",
	OutTemp       => MIMTXBRADD_OUT(3),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(4),
	GlitchData    => MIMTXBRADD4_GlitchData,
	OutSignalName => "MIMTXBRADD(4)",
	OutTemp       => MIMTXBRADD_OUT(4),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(5),
	GlitchData    => MIMTXBRADD5_GlitchData,
	OutSignalName => "MIMTXBRADD(5)",
	OutTemp       => MIMTXBRADD_OUT(5),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(6),
	GlitchData    => MIMTXBRADD6_GlitchData,
	OutSignalName => "MIMTXBRADD(6)",
	OutTemp       => MIMTXBRADD_OUT(6),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(7),
	GlitchData    => MIMTXBRADD7_GlitchData,
	OutSignalName => "MIMTXBRADD(7)",
	OutTemp       => MIMTXBRADD_OUT(7),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(8),
	GlitchData    => MIMTXBRADD8_GlitchData,
	OutSignalName => "MIMTXBRADD(8)",
	OutTemp       => MIMTXBRADD_OUT(8),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(9),
	GlitchData    => MIMTXBRADD9_GlitchData,
	OutSignalName => "MIMTXBRADD(9)",
	OutTemp       => MIMTXBRADD_OUT(9),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(10),
	GlitchData    => MIMTXBRADD10_GlitchData,
	OutSignalName => "MIMTXBRADD(10)",
	OutTemp       => MIMTXBRADD_OUT(10),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(11),
	GlitchData    => MIMTXBRADD11_GlitchData,
	OutSignalName => "MIMTXBRADD(11)",
	OutTemp       => MIMTXBRADD_OUT(11),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBRADD(12),
	GlitchData    => MIMTXBRADD12_GlitchData,
	OutSignalName => "MIMTXBRADD(12)",
	OutTemp       => MIMTXBRADD_OUT(12),
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWEN,
	GlitchData    => MIMTXBWEN_GlitchData,
	OutSignalName => "MIMTXBWEN",
	OutTemp       => MIMTXBWEN_OUT,
	Paths         => (0 => (CRMUSERCLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBWEN,
	GlitchData    => MIMTXBWEN_GlitchData,
	OutSignalName => "MIMTXBWEN",
	OutTemp       => MIMTXBWEN_OUT,
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMTXBREN,
	GlitchData    => MIMTXBREN_GlitchData,
	OutSignalName => "MIMTXBREN",
	OutTemp       => MIMTXBREN_OUT,
	Paths         => (0 => (CRMCORECLKTXO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(0),
	GlitchData    => MIMDLLBWDATA0_GlitchData,
	OutSignalName => "MIMDLLBWDATA(0)",
	OutTemp       => MIMDLLBWDATA_OUT(0),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(1),
	GlitchData    => MIMDLLBWDATA1_GlitchData,
	OutSignalName => "MIMDLLBWDATA(1)",
	OutTemp       => MIMDLLBWDATA_OUT(1),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(2),
	GlitchData    => MIMDLLBWDATA2_GlitchData,
	OutSignalName => "MIMDLLBWDATA(2)",
	OutTemp       => MIMDLLBWDATA_OUT(2),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(3),
	GlitchData    => MIMDLLBWDATA3_GlitchData,
	OutSignalName => "MIMDLLBWDATA(3)",
	OutTemp       => MIMDLLBWDATA_OUT(3),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(4),
	GlitchData    => MIMDLLBWDATA4_GlitchData,
	OutSignalName => "MIMDLLBWDATA(4)",
	OutTemp       => MIMDLLBWDATA_OUT(4),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(5),
	GlitchData    => MIMDLLBWDATA5_GlitchData,
	OutSignalName => "MIMDLLBWDATA(5)",
	OutTemp       => MIMDLLBWDATA_OUT(5),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(6),
	GlitchData    => MIMDLLBWDATA6_GlitchData,
	OutSignalName => "MIMDLLBWDATA(6)",
	OutTemp       => MIMDLLBWDATA_OUT(6),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(7),
	GlitchData    => MIMDLLBWDATA7_GlitchData,
	OutSignalName => "MIMDLLBWDATA(7)",
	OutTemp       => MIMDLLBWDATA_OUT(7),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(8),
	GlitchData    => MIMDLLBWDATA8_GlitchData,
	OutSignalName => "MIMDLLBWDATA(8)",
	OutTemp       => MIMDLLBWDATA_OUT(8),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(9),
	GlitchData    => MIMDLLBWDATA9_GlitchData,
	OutSignalName => "MIMDLLBWDATA(9)",
	OutTemp       => MIMDLLBWDATA_OUT(9),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(10),
	GlitchData    => MIMDLLBWDATA10_GlitchData,
	OutSignalName => "MIMDLLBWDATA(10)",
	OutTemp       => MIMDLLBWDATA_OUT(10),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(11),
	GlitchData    => MIMDLLBWDATA11_GlitchData,
	OutSignalName => "MIMDLLBWDATA(11)",
	OutTemp       => MIMDLLBWDATA_OUT(11),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(12),
	GlitchData    => MIMDLLBWDATA12_GlitchData,
	OutSignalName => "MIMDLLBWDATA(12)",
	OutTemp       => MIMDLLBWDATA_OUT(12),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(13),
	GlitchData    => MIMDLLBWDATA13_GlitchData,
	OutSignalName => "MIMDLLBWDATA(13)",
	OutTemp       => MIMDLLBWDATA_OUT(13),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(14),
	GlitchData    => MIMDLLBWDATA14_GlitchData,
	OutSignalName => "MIMDLLBWDATA(14)",
	OutTemp       => MIMDLLBWDATA_OUT(14),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(15),
	GlitchData    => MIMDLLBWDATA15_GlitchData,
	OutSignalName => "MIMDLLBWDATA(15)",
	OutTemp       => MIMDLLBWDATA_OUT(15),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(16),
	GlitchData    => MIMDLLBWDATA16_GlitchData,
	OutSignalName => "MIMDLLBWDATA(16)",
	OutTemp       => MIMDLLBWDATA_OUT(16),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(17),
	GlitchData    => MIMDLLBWDATA17_GlitchData,
	OutSignalName => "MIMDLLBWDATA(17)",
	OutTemp       => MIMDLLBWDATA_OUT(17),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(18),
	GlitchData    => MIMDLLBWDATA18_GlitchData,
	OutSignalName => "MIMDLLBWDATA(18)",
	OutTemp       => MIMDLLBWDATA_OUT(18),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(19),
	GlitchData    => MIMDLLBWDATA19_GlitchData,
	OutSignalName => "MIMDLLBWDATA(19)",
	OutTemp       => MIMDLLBWDATA_OUT(19),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(20),
	GlitchData    => MIMDLLBWDATA20_GlitchData,
	OutSignalName => "MIMDLLBWDATA(20)",
	OutTemp       => MIMDLLBWDATA_OUT(20),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(21),
	GlitchData    => MIMDLLBWDATA21_GlitchData,
	OutSignalName => "MIMDLLBWDATA(21)",
	OutTemp       => MIMDLLBWDATA_OUT(21),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(22),
	GlitchData    => MIMDLLBWDATA22_GlitchData,
	OutSignalName => "MIMDLLBWDATA(22)",
	OutTemp       => MIMDLLBWDATA_OUT(22),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(23),
	GlitchData    => MIMDLLBWDATA23_GlitchData,
	OutSignalName => "MIMDLLBWDATA(23)",
	OutTemp       => MIMDLLBWDATA_OUT(23),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(24),
	GlitchData    => MIMDLLBWDATA24_GlitchData,
	OutSignalName => "MIMDLLBWDATA(24)",
	OutTemp       => MIMDLLBWDATA_OUT(24),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(25),
	GlitchData    => MIMDLLBWDATA25_GlitchData,
	OutSignalName => "MIMDLLBWDATA(25)",
	OutTemp       => MIMDLLBWDATA_OUT(25),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(26),
	GlitchData    => MIMDLLBWDATA26_GlitchData,
	OutSignalName => "MIMDLLBWDATA(26)",
	OutTemp       => MIMDLLBWDATA_OUT(26),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(27),
	GlitchData    => MIMDLLBWDATA27_GlitchData,
	OutSignalName => "MIMDLLBWDATA(27)",
	OutTemp       => MIMDLLBWDATA_OUT(27),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(28),
	GlitchData    => MIMDLLBWDATA28_GlitchData,
	OutSignalName => "MIMDLLBWDATA(28)",
	OutTemp       => MIMDLLBWDATA_OUT(28),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(29),
	GlitchData    => MIMDLLBWDATA29_GlitchData,
	OutSignalName => "MIMDLLBWDATA(29)",
	OutTemp       => MIMDLLBWDATA_OUT(29),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(30),
	GlitchData    => MIMDLLBWDATA30_GlitchData,
	OutSignalName => "MIMDLLBWDATA(30)",
	OutTemp       => MIMDLLBWDATA_OUT(30),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(31),
	GlitchData    => MIMDLLBWDATA31_GlitchData,
	OutSignalName => "MIMDLLBWDATA(31)",
	OutTemp       => MIMDLLBWDATA_OUT(31),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(32),
	GlitchData    => MIMDLLBWDATA32_GlitchData,
	OutSignalName => "MIMDLLBWDATA(32)",
	OutTemp       => MIMDLLBWDATA_OUT(32),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(33),
	GlitchData    => MIMDLLBWDATA33_GlitchData,
	OutSignalName => "MIMDLLBWDATA(33)",
	OutTemp       => MIMDLLBWDATA_OUT(33),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(34),
	GlitchData    => MIMDLLBWDATA34_GlitchData,
	OutSignalName => "MIMDLLBWDATA(34)",
	OutTemp       => MIMDLLBWDATA_OUT(34),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(35),
	GlitchData    => MIMDLLBWDATA35_GlitchData,
	OutSignalName => "MIMDLLBWDATA(35)",
	OutTemp       => MIMDLLBWDATA_OUT(35),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(36),
	GlitchData    => MIMDLLBWDATA36_GlitchData,
	OutSignalName => "MIMDLLBWDATA(36)",
	OutTemp       => MIMDLLBWDATA_OUT(36),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(37),
	GlitchData    => MIMDLLBWDATA37_GlitchData,
	OutSignalName => "MIMDLLBWDATA(37)",
	OutTemp       => MIMDLLBWDATA_OUT(37),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(38),
	GlitchData    => MIMDLLBWDATA38_GlitchData,
	OutSignalName => "MIMDLLBWDATA(38)",
	OutTemp       => MIMDLLBWDATA_OUT(38),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(39),
	GlitchData    => MIMDLLBWDATA39_GlitchData,
	OutSignalName => "MIMDLLBWDATA(39)",
	OutTemp       => MIMDLLBWDATA_OUT(39),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(40),
	GlitchData    => MIMDLLBWDATA40_GlitchData,
	OutSignalName => "MIMDLLBWDATA(40)",
	OutTemp       => MIMDLLBWDATA_OUT(40),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(41),
	GlitchData    => MIMDLLBWDATA41_GlitchData,
	OutSignalName => "MIMDLLBWDATA(41)",
	OutTemp       => MIMDLLBWDATA_OUT(41),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(42),
	GlitchData    => MIMDLLBWDATA42_GlitchData,
	OutSignalName => "MIMDLLBWDATA(42)",
	OutTemp       => MIMDLLBWDATA_OUT(42),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(43),
	GlitchData    => MIMDLLBWDATA43_GlitchData,
	OutSignalName => "MIMDLLBWDATA(43)",
	OutTemp       => MIMDLLBWDATA_OUT(43),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(44),
	GlitchData    => MIMDLLBWDATA44_GlitchData,
	OutSignalName => "MIMDLLBWDATA(44)",
	OutTemp       => MIMDLLBWDATA_OUT(44),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(45),
	GlitchData    => MIMDLLBWDATA45_GlitchData,
	OutSignalName => "MIMDLLBWDATA(45)",
	OutTemp       => MIMDLLBWDATA_OUT(45),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(46),
	GlitchData    => MIMDLLBWDATA46_GlitchData,
	OutSignalName => "MIMDLLBWDATA(46)",
	OutTemp       => MIMDLLBWDATA_OUT(46),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(47),
	GlitchData    => MIMDLLBWDATA47_GlitchData,
	OutSignalName => "MIMDLLBWDATA(47)",
	OutTemp       => MIMDLLBWDATA_OUT(47),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(48),
	GlitchData    => MIMDLLBWDATA48_GlitchData,
	OutSignalName => "MIMDLLBWDATA(48)",
	OutTemp       => MIMDLLBWDATA_OUT(48),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(49),
	GlitchData    => MIMDLLBWDATA49_GlitchData,
	OutSignalName => "MIMDLLBWDATA(49)",
	OutTemp       => MIMDLLBWDATA_OUT(49),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(50),
	GlitchData    => MIMDLLBWDATA50_GlitchData,
	OutSignalName => "MIMDLLBWDATA(50)",
	OutTemp       => MIMDLLBWDATA_OUT(50),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(51),
	GlitchData    => MIMDLLBWDATA51_GlitchData,
	OutSignalName => "MIMDLLBWDATA(51)",
	OutTemp       => MIMDLLBWDATA_OUT(51),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(52),
	GlitchData    => MIMDLLBWDATA52_GlitchData,
	OutSignalName => "MIMDLLBWDATA(52)",
	OutTemp       => MIMDLLBWDATA_OUT(52),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(53),
	GlitchData    => MIMDLLBWDATA53_GlitchData,
	OutSignalName => "MIMDLLBWDATA(53)",
	OutTemp       => MIMDLLBWDATA_OUT(53),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(54),
	GlitchData    => MIMDLLBWDATA54_GlitchData,
	OutSignalName => "MIMDLLBWDATA(54)",
	OutTemp       => MIMDLLBWDATA_OUT(54),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(55),
	GlitchData    => MIMDLLBWDATA55_GlitchData,
	OutSignalName => "MIMDLLBWDATA(55)",
	OutTemp       => MIMDLLBWDATA_OUT(55),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(56),
	GlitchData    => MIMDLLBWDATA56_GlitchData,
	OutSignalName => "MIMDLLBWDATA(56)",
	OutTemp       => MIMDLLBWDATA_OUT(56),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(57),
	GlitchData    => MIMDLLBWDATA57_GlitchData,
	OutSignalName => "MIMDLLBWDATA(57)",
	OutTemp       => MIMDLLBWDATA_OUT(57),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(58),
	GlitchData    => MIMDLLBWDATA58_GlitchData,
	OutSignalName => "MIMDLLBWDATA(58)",
	OutTemp       => MIMDLLBWDATA_OUT(58),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(59),
	GlitchData    => MIMDLLBWDATA59_GlitchData,
	OutSignalName => "MIMDLLBWDATA(59)",
	OutTemp       => MIMDLLBWDATA_OUT(59),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(60),
	GlitchData    => MIMDLLBWDATA60_GlitchData,
	OutSignalName => "MIMDLLBWDATA(60)",
	OutTemp       => MIMDLLBWDATA_OUT(60),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(61),
	GlitchData    => MIMDLLBWDATA61_GlitchData,
	OutSignalName => "MIMDLLBWDATA(61)",
	OutTemp       => MIMDLLBWDATA_OUT(61),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(62),
	GlitchData    => MIMDLLBWDATA62_GlitchData,
	OutSignalName => "MIMDLLBWDATA(62)",
	OutTemp       => MIMDLLBWDATA_OUT(62),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWDATA(63),
	GlitchData    => MIMDLLBWDATA63_GlitchData,
	OutSignalName => "MIMDLLBWDATA(63)",
	OutTemp       => MIMDLLBWDATA_OUT(63),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(0),
	GlitchData    => MIMDLLBWADD0_GlitchData,
	OutSignalName => "MIMDLLBWADD(0)",
	OutTemp       => MIMDLLBWADD_OUT(0),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(1),
	GlitchData    => MIMDLLBWADD1_GlitchData,
	OutSignalName => "MIMDLLBWADD(1)",
	OutTemp       => MIMDLLBWADD_OUT(1),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(2),
	GlitchData    => MIMDLLBWADD2_GlitchData,
	OutSignalName => "MIMDLLBWADD(2)",
	OutTemp       => MIMDLLBWADD_OUT(2),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(3),
	GlitchData    => MIMDLLBWADD3_GlitchData,
	OutSignalName => "MIMDLLBWADD(3)",
	OutTemp       => MIMDLLBWADD_OUT(3),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(4),
	GlitchData    => MIMDLLBWADD4_GlitchData,
	OutSignalName => "MIMDLLBWADD(4)",
	OutTemp       => MIMDLLBWADD_OUT(4),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(5),
	GlitchData    => MIMDLLBWADD5_GlitchData,
	OutSignalName => "MIMDLLBWADD(5)",
	OutTemp       => MIMDLLBWADD_OUT(5),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(6),
	GlitchData    => MIMDLLBWADD6_GlitchData,
	OutSignalName => "MIMDLLBWADD(6)",
	OutTemp       => MIMDLLBWADD_OUT(6),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(7),
	GlitchData    => MIMDLLBWADD7_GlitchData,
	OutSignalName => "MIMDLLBWADD(7)",
	OutTemp       => MIMDLLBWADD_OUT(7),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(8),
	GlitchData    => MIMDLLBWADD8_GlitchData,
	OutSignalName => "MIMDLLBWADD(8)",
	OutTemp       => MIMDLLBWADD_OUT(8),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(9),
	GlitchData    => MIMDLLBWADD9_GlitchData,
	OutSignalName => "MIMDLLBWADD(9)",
	OutTemp       => MIMDLLBWADD_OUT(9),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(10),
	GlitchData    => MIMDLLBWADD10_GlitchData,
	OutSignalName => "MIMDLLBWADD(10)",
	OutTemp       => MIMDLLBWADD_OUT(10),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWADD(11),
	GlitchData    => MIMDLLBWADD11_GlitchData,
	OutSignalName => "MIMDLLBWADD(11)",
	OutTemp       => MIMDLLBWADD_OUT(11),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(0),
	GlitchData    => MIMDLLBRADD0_GlitchData,
	OutSignalName => "MIMDLLBRADD(0)",
	OutTemp       => MIMDLLBRADD_OUT(0),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(1),
	GlitchData    => MIMDLLBRADD1_GlitchData,
	OutSignalName => "MIMDLLBRADD(1)",
	OutTemp       => MIMDLLBRADD_OUT(1),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(2),
	GlitchData    => MIMDLLBRADD2_GlitchData,
	OutSignalName => "MIMDLLBRADD(2)",
	OutTemp       => MIMDLLBRADD_OUT(2),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(3),
	GlitchData    => MIMDLLBRADD3_GlitchData,
	OutSignalName => "MIMDLLBRADD(3)",
	OutTemp       => MIMDLLBRADD_OUT(3),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(4),
	GlitchData    => MIMDLLBRADD4_GlitchData,
	OutSignalName => "MIMDLLBRADD(4)",
	OutTemp       => MIMDLLBRADD_OUT(4),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(5),
	GlitchData    => MIMDLLBRADD5_GlitchData,
	OutSignalName => "MIMDLLBRADD(5)",
	OutTemp       => MIMDLLBRADD_OUT(5),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(6),
	GlitchData    => MIMDLLBRADD6_GlitchData,
	OutSignalName => "MIMDLLBRADD(6)",
	OutTemp       => MIMDLLBRADD_OUT(6),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(7),
	GlitchData    => MIMDLLBRADD7_GlitchData,
	OutSignalName => "MIMDLLBRADD(7)",
	OutTemp       => MIMDLLBRADD_OUT(7),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(8),
	GlitchData    => MIMDLLBRADD8_GlitchData,
	OutSignalName => "MIMDLLBRADD(8)",
	OutTemp       => MIMDLLBRADD_OUT(8),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(9),
	GlitchData    => MIMDLLBRADD9_GlitchData,
	OutSignalName => "MIMDLLBRADD(9)",
	OutTemp       => MIMDLLBRADD_OUT(9),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(10),
	GlitchData    => MIMDLLBRADD10_GlitchData,
	OutSignalName => "MIMDLLBRADD(10)",
	OutTemp       => MIMDLLBRADD_OUT(10),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBRADD(11),
	GlitchData    => MIMDLLBRADD11_GlitchData,
	OutSignalName => "MIMDLLBRADD(11)",
	OutTemp       => MIMDLLBRADD_OUT(11),
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBWEN,
	GlitchData    => MIMDLLBWEN_GlitchData,
	OutSignalName => "MIMDLLBWEN",
	OutTemp       => MIMDLLBWEN_OUT,
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MIMDLLBREN,
	GlitchData    => MIMDLLBREN_GlitchData,
	OutSignalName => "MIMDLLBREN",
	OutTemp       => MIMDLLBREN_OUT,
	Paths         => (0 => (CRMCORECLKDLO_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => CRMRXHOTRESETN,
	GlitchData    => CRMRXHOTRESETN_GlitchData,
	OutSignalName => "CRMRXHOTRESETN",
	OutTemp       => CRMRXHOTRESETN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => CRMDOHOTRESETN,
	GlitchData    => CRMDOHOTRESETN_GlitchData,
	OutSignalName => "CRMDOHOTRESETN",
	OutTemp       => CRMDOHOTRESETN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => CRMPWRSOFTRESETN,
	GlitchData    => CRMPWRSOFTRESETN_GlitchData,
	OutSignalName => "CRMPWRSOFTRESETN",
	OutTemp       => CRMPWRSOFTRESETN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(0),
	GlitchData    => LLKTCSTATUS0_GlitchData,
	OutSignalName => "LLKTCSTATUS(0)",
	OutTemp       => LLKTCSTATUS_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(0),
	GlitchData    => LLKTCSTATUS0_GlitchData,
	OutSignalName => "LLKTCSTATUS(0)",
	OutTemp       => LLKTCSTATUS_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(1),
	GlitchData    => LLKTCSTATUS1_GlitchData,
	OutSignalName => "LLKTCSTATUS(1)",
	OutTemp       => LLKTCSTATUS_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(1),
	GlitchData    => LLKTCSTATUS1_GlitchData,
	OutSignalName => "LLKTCSTATUS(1)",
	OutTemp       => LLKTCSTATUS_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(2),
	GlitchData    => LLKTCSTATUS2_GlitchData,
	OutSignalName => "LLKTCSTATUS(2)",
	OutTemp       => LLKTCSTATUS_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(2),
	GlitchData    => LLKTCSTATUS2_GlitchData,
	OutSignalName => "LLKTCSTATUS(2)",
	OutTemp       => LLKTCSTATUS_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(3),
	GlitchData    => LLKTCSTATUS3_GlitchData,
	OutSignalName => "LLKTCSTATUS(3)",
	OutTemp       => LLKTCSTATUS_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(3),
	GlitchData    => LLKTCSTATUS3_GlitchData,
	OutSignalName => "LLKTCSTATUS(3)",
	OutTemp       => LLKTCSTATUS_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(4),
	GlitchData    => LLKTCSTATUS4_GlitchData,
	OutSignalName => "LLKTCSTATUS(4)",
	OutTemp       => LLKTCSTATUS_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(4),
	GlitchData    => LLKTCSTATUS4_GlitchData,
	OutSignalName => "LLKTCSTATUS(4)",
	OutTemp       => LLKTCSTATUS_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(5),
	GlitchData    => LLKTCSTATUS5_GlitchData,
	OutSignalName => "LLKTCSTATUS(5)",
	OutTemp       => LLKTCSTATUS_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(5),
	GlitchData    => LLKTCSTATUS5_GlitchData,
	OutSignalName => "LLKTCSTATUS(5)",
	OutTemp       => LLKTCSTATUS_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(6),
	GlitchData    => LLKTCSTATUS6_GlitchData,
	OutSignalName => "LLKTCSTATUS(6)",
	OutTemp       => LLKTCSTATUS_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(6),
	GlitchData    => LLKTCSTATUS6_GlitchData,
	OutSignalName => "LLKTCSTATUS(6)",
	OutTemp       => LLKTCSTATUS_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(7),
	GlitchData    => LLKTCSTATUS7_GlitchData,
	OutSignalName => "LLKTCSTATUS(7)",
	OutTemp       => LLKTCSTATUS_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTCSTATUS(7),
	GlitchData    => LLKTCSTATUS7_GlitchData,
	OutSignalName => "LLKTCSTATUS(7)",
	OutTemp       => LLKTCSTATUS_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXDSTRDYN,
	GlitchData    => LLKTXDSTRDYN_GlitchData,
	OutSignalName => "LLKTXDSTRDYN",
	OutTemp       => LLKTXDSTRDYN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXDSTRDYN,
	GlitchData    => LLKTXDSTRDYN_GlitchData,
	OutSignalName => "LLKTXDSTRDYN",
	OutTemp       => LLKTXDSTRDYN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(0),
	GlitchData    => LLKTXCHANSPACE0_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(0)",
	OutTemp       => LLKTXCHANSPACE_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(0),
	GlitchData    => LLKTXCHANSPACE0_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(0)",
	OutTemp       => LLKTXCHANSPACE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(1),
	GlitchData    => LLKTXCHANSPACE1_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(1)",
	OutTemp       => LLKTXCHANSPACE_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(1),
	GlitchData    => LLKTXCHANSPACE1_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(1)",
	OutTemp       => LLKTXCHANSPACE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(2),
	GlitchData    => LLKTXCHANSPACE2_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(2)",
	OutTemp       => LLKTXCHANSPACE_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(2),
	GlitchData    => LLKTXCHANSPACE2_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(2)",
	OutTemp       => LLKTXCHANSPACE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(3),
	GlitchData    => LLKTXCHANSPACE3_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(3)",
	OutTemp       => LLKTXCHANSPACE_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(3),
	GlitchData    => LLKTXCHANSPACE3_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(3)",
	OutTemp       => LLKTXCHANSPACE_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(4),
	GlitchData    => LLKTXCHANSPACE4_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(4)",
	OutTemp       => LLKTXCHANSPACE_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(4),
	GlitchData    => LLKTXCHANSPACE4_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(4)",
	OutTemp       => LLKTXCHANSPACE_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(5),
	GlitchData    => LLKTXCHANSPACE5_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(5)",
	OutTemp       => LLKTXCHANSPACE_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(5),
	GlitchData    => LLKTXCHANSPACE5_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(5)",
	OutTemp       => LLKTXCHANSPACE_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(6),
	GlitchData    => LLKTXCHANSPACE6_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(6)",
	OutTemp       => LLKTXCHANSPACE_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(6),
	GlitchData    => LLKTXCHANSPACE6_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(6)",
	OutTemp       => LLKTXCHANSPACE_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(7),
	GlitchData    => LLKTXCHANSPACE7_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(7)",
	OutTemp       => LLKTXCHANSPACE_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(7),
	GlitchData    => LLKTXCHANSPACE7_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(7)",
	OutTemp       => LLKTXCHANSPACE_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(8),
	GlitchData    => LLKTXCHANSPACE8_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(8)",
	OutTemp       => LLKTXCHANSPACE_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(8),
	GlitchData    => LLKTXCHANSPACE8_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(8)",
	OutTemp       => LLKTXCHANSPACE_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(9),
	GlitchData    => LLKTXCHANSPACE9_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(9)",
	OutTemp       => LLKTXCHANSPACE_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHANSPACE(9),
	GlitchData    => LLKTXCHANSPACE9_GlitchData,
	OutSignalName => "LLKTXCHANSPACE(9)",
	OutTemp       => LLKTXCHANSPACE_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(0),
	GlitchData    => LLKTXCHPOSTEDREADYN0_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(0)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(0),
	GlitchData    => LLKTXCHPOSTEDREADYN0_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(0)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(1),
	GlitchData    => LLKTXCHPOSTEDREADYN1_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(1)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(1),
	GlitchData    => LLKTXCHPOSTEDREADYN1_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(1)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(2),
	GlitchData    => LLKTXCHPOSTEDREADYN2_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(2)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(2),
	GlitchData    => LLKTXCHPOSTEDREADYN2_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(2)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(3),
	GlitchData    => LLKTXCHPOSTEDREADYN3_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(3)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(3),
	GlitchData    => LLKTXCHPOSTEDREADYN3_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(3)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(4),
	GlitchData    => LLKTXCHPOSTEDREADYN4_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(4)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(4),
	GlitchData    => LLKTXCHPOSTEDREADYN4_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(4)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(5),
	GlitchData    => LLKTXCHPOSTEDREADYN5_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(5)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(5),
	GlitchData    => LLKTXCHPOSTEDREADYN5_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(5)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(6),
	GlitchData    => LLKTXCHPOSTEDREADYN6_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(6)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(6),
	GlitchData    => LLKTXCHPOSTEDREADYN6_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(6)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(7),
	GlitchData    => LLKTXCHPOSTEDREADYN7_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(7)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHPOSTEDREADYN(7),
	GlitchData    => LLKTXCHPOSTEDREADYN7_GlitchData,
	OutSignalName => "LLKTXCHPOSTEDREADYN(7)",
	OutTemp       => LLKTXCHPOSTEDREADYN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(0),
	GlitchData    => LLKTXCHNONPOSTEDREADYN0_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(0)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(0),
	GlitchData    => LLKTXCHNONPOSTEDREADYN0_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(0)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(1),
	GlitchData    => LLKTXCHNONPOSTEDREADYN1_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(1)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(1),
	GlitchData    => LLKTXCHNONPOSTEDREADYN1_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(1)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(2),
	GlitchData    => LLKTXCHNONPOSTEDREADYN2_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(2)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(2),
	GlitchData    => LLKTXCHNONPOSTEDREADYN2_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(2)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(3),
	GlitchData    => LLKTXCHNONPOSTEDREADYN3_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(3)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(3),
	GlitchData    => LLKTXCHNONPOSTEDREADYN3_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(3)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(4),
	GlitchData    => LLKTXCHNONPOSTEDREADYN4_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(4)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(4),
	GlitchData    => LLKTXCHNONPOSTEDREADYN4_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(4)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(5),
	GlitchData    => LLKTXCHNONPOSTEDREADYN5_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(5)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(5),
	GlitchData    => LLKTXCHNONPOSTEDREADYN5_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(5)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(6),
	GlitchData    => LLKTXCHNONPOSTEDREADYN6_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(6)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(6),
	GlitchData    => LLKTXCHNONPOSTEDREADYN6_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(6)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(7),
	GlitchData    => LLKTXCHNONPOSTEDREADYN7_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(7)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHNONPOSTEDREADYN(7),
	GlitchData    => LLKTXCHNONPOSTEDREADYN7_GlitchData,
	OutSignalName => "LLKTXCHNONPOSTEDREADYN(7)",
	OutTemp       => LLKTXCHNONPOSTEDREADYN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(0),
	GlitchData    => LLKTXCHCOMPLETIONREADYN0_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(0)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(0),
	GlitchData    => LLKTXCHCOMPLETIONREADYN0_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(0)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(1),
	GlitchData    => LLKTXCHCOMPLETIONREADYN1_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(1)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(1),
	GlitchData    => LLKTXCHCOMPLETIONREADYN1_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(1)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(2),
	GlitchData    => LLKTXCHCOMPLETIONREADYN2_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(2)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(2),
	GlitchData    => LLKTXCHCOMPLETIONREADYN2_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(2)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(3),
	GlitchData    => LLKTXCHCOMPLETIONREADYN3_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(3)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(3),
	GlitchData    => LLKTXCHCOMPLETIONREADYN3_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(3)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(4),
	GlitchData    => LLKTXCHCOMPLETIONREADYN4_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(4)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(4),
	GlitchData    => LLKTXCHCOMPLETIONREADYN4_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(4)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(5),
	GlitchData    => LLKTXCHCOMPLETIONREADYN5_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(5)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(5),
	GlitchData    => LLKTXCHCOMPLETIONREADYN5_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(5)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(6),
	GlitchData    => LLKTXCHCOMPLETIONREADYN6_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(6)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(6),
	GlitchData    => LLKTXCHCOMPLETIONREADYN6_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(6)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(7),
	GlitchData    => LLKTXCHCOMPLETIONREADYN7_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(7)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCHCOMPLETIONREADYN(7),
	GlitchData    => LLKTXCHCOMPLETIONREADYN7_GlitchData,
	OutSignalName => "LLKTXCHCOMPLETIONREADYN(7)",
	OutTemp       => LLKTXCHCOMPLETIONREADYN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCONFIGREADYN,
	GlitchData    => LLKTXCONFIGREADYN_GlitchData,
	OutSignalName => "LLKTXCONFIGREADYN",
	OutTemp       => LLKTXCONFIGREADYN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKTXCONFIGREADYN,
	GlitchData    => LLKTXCONFIGREADYN_GlitchData,
	OutSignalName => "LLKTXCONFIGREADYN",
	OutTemp       => LLKTXCONFIGREADYN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(0),
	GlitchData    => LLKRXDATA0_GlitchData,
	OutSignalName => "LLKRXDATA(0)",
	OutTemp       => LLKRXDATA_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(0),
	GlitchData    => LLKRXDATA0_GlitchData,
	OutSignalName => "LLKRXDATA(0)",
	OutTemp       => LLKRXDATA_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(1),
	GlitchData    => LLKRXDATA1_GlitchData,
	OutSignalName => "LLKRXDATA(1)",
	OutTemp       => LLKRXDATA_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(1),
	GlitchData    => LLKRXDATA1_GlitchData,
	OutSignalName => "LLKRXDATA(1)",
	OutTemp       => LLKRXDATA_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(2),
	GlitchData    => LLKRXDATA2_GlitchData,
	OutSignalName => "LLKRXDATA(2)",
	OutTemp       => LLKRXDATA_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(2),
	GlitchData    => LLKRXDATA2_GlitchData,
	OutSignalName => "LLKRXDATA(2)",
	OutTemp       => LLKRXDATA_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(3),
	GlitchData    => LLKRXDATA3_GlitchData,
	OutSignalName => "LLKRXDATA(3)",
	OutTemp       => LLKRXDATA_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(3),
	GlitchData    => LLKRXDATA3_GlitchData,
	OutSignalName => "LLKRXDATA(3)",
	OutTemp       => LLKRXDATA_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(4),
	GlitchData    => LLKRXDATA4_GlitchData,
	OutSignalName => "LLKRXDATA(4)",
	OutTemp       => LLKRXDATA_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(4),
	GlitchData    => LLKRXDATA4_GlitchData,
	OutSignalName => "LLKRXDATA(4)",
	OutTemp       => LLKRXDATA_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(5),
	GlitchData    => LLKRXDATA5_GlitchData,
	OutSignalName => "LLKRXDATA(5)",
	OutTemp       => LLKRXDATA_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(5),
	GlitchData    => LLKRXDATA5_GlitchData,
	OutSignalName => "LLKRXDATA(5)",
	OutTemp       => LLKRXDATA_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(6),
	GlitchData    => LLKRXDATA6_GlitchData,
	OutSignalName => "LLKRXDATA(6)",
	OutTemp       => LLKRXDATA_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(6),
	GlitchData    => LLKRXDATA6_GlitchData,
	OutSignalName => "LLKRXDATA(6)",
	OutTemp       => LLKRXDATA_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(7),
	GlitchData    => LLKRXDATA7_GlitchData,
	OutSignalName => "LLKRXDATA(7)",
	OutTemp       => LLKRXDATA_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(7),
	GlitchData    => LLKRXDATA7_GlitchData,
	OutSignalName => "LLKRXDATA(7)",
	OutTemp       => LLKRXDATA_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(8),
	GlitchData    => LLKRXDATA8_GlitchData,
	OutSignalName => "LLKRXDATA(8)",
	OutTemp       => LLKRXDATA_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(8),
	GlitchData    => LLKRXDATA8_GlitchData,
	OutSignalName => "LLKRXDATA(8)",
	OutTemp       => LLKRXDATA_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(9),
	GlitchData    => LLKRXDATA9_GlitchData,
	OutSignalName => "LLKRXDATA(9)",
	OutTemp       => LLKRXDATA_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(9),
	GlitchData    => LLKRXDATA9_GlitchData,
	OutSignalName => "LLKRXDATA(9)",
	OutTemp       => LLKRXDATA_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(10),
	GlitchData    => LLKRXDATA10_GlitchData,
	OutSignalName => "LLKRXDATA(10)",
	OutTemp       => LLKRXDATA_OUT(10),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(10),
	GlitchData    => LLKRXDATA10_GlitchData,
	OutSignalName => "LLKRXDATA(10)",
	OutTemp       => LLKRXDATA_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(11),
	GlitchData    => LLKRXDATA11_GlitchData,
	OutSignalName => "LLKRXDATA(11)",
	OutTemp       => LLKRXDATA_OUT(11),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(11),
	GlitchData    => LLKRXDATA11_GlitchData,
	OutSignalName => "LLKRXDATA(11)",
	OutTemp       => LLKRXDATA_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(12),
	GlitchData    => LLKRXDATA12_GlitchData,
	OutSignalName => "LLKRXDATA(12)",
	OutTemp       => LLKRXDATA_OUT(12),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(12),
	GlitchData    => LLKRXDATA12_GlitchData,
	OutSignalName => "LLKRXDATA(12)",
	OutTemp       => LLKRXDATA_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(13),
	GlitchData    => LLKRXDATA13_GlitchData,
	OutSignalName => "LLKRXDATA(13)",
	OutTemp       => LLKRXDATA_OUT(13),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(13),
	GlitchData    => LLKRXDATA13_GlitchData,
	OutSignalName => "LLKRXDATA(13)",
	OutTemp       => LLKRXDATA_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(14),
	GlitchData    => LLKRXDATA14_GlitchData,
	OutSignalName => "LLKRXDATA(14)",
	OutTemp       => LLKRXDATA_OUT(14),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(14),
	GlitchData    => LLKRXDATA14_GlitchData,
	OutSignalName => "LLKRXDATA(14)",
	OutTemp       => LLKRXDATA_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(15),
	GlitchData    => LLKRXDATA15_GlitchData,
	OutSignalName => "LLKRXDATA(15)",
	OutTemp       => LLKRXDATA_OUT(15),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(15),
	GlitchData    => LLKRXDATA15_GlitchData,
	OutSignalName => "LLKRXDATA(15)",
	OutTemp       => LLKRXDATA_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(16),
	GlitchData    => LLKRXDATA16_GlitchData,
	OutSignalName => "LLKRXDATA(16)",
	OutTemp       => LLKRXDATA_OUT(16),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(16),
	GlitchData    => LLKRXDATA16_GlitchData,
	OutSignalName => "LLKRXDATA(16)",
	OutTemp       => LLKRXDATA_OUT(16),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(17),
	GlitchData    => LLKRXDATA17_GlitchData,
	OutSignalName => "LLKRXDATA(17)",
	OutTemp       => LLKRXDATA_OUT(17),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(17),
	GlitchData    => LLKRXDATA17_GlitchData,
	OutSignalName => "LLKRXDATA(17)",
	OutTemp       => LLKRXDATA_OUT(17),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(18),
	GlitchData    => LLKRXDATA18_GlitchData,
	OutSignalName => "LLKRXDATA(18)",
	OutTemp       => LLKRXDATA_OUT(18),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(18),
	GlitchData    => LLKRXDATA18_GlitchData,
	OutSignalName => "LLKRXDATA(18)",
	OutTemp       => LLKRXDATA_OUT(18),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(19),
	GlitchData    => LLKRXDATA19_GlitchData,
	OutSignalName => "LLKRXDATA(19)",
	OutTemp       => LLKRXDATA_OUT(19),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(19),
	GlitchData    => LLKRXDATA19_GlitchData,
	OutSignalName => "LLKRXDATA(19)",
	OutTemp       => LLKRXDATA_OUT(19),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(20),
	GlitchData    => LLKRXDATA20_GlitchData,
	OutSignalName => "LLKRXDATA(20)",
	OutTemp       => LLKRXDATA_OUT(20),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(20),
	GlitchData    => LLKRXDATA20_GlitchData,
	OutSignalName => "LLKRXDATA(20)",
	OutTemp       => LLKRXDATA_OUT(20),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(21),
	GlitchData    => LLKRXDATA21_GlitchData,
	OutSignalName => "LLKRXDATA(21)",
	OutTemp       => LLKRXDATA_OUT(21),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(21),
	GlitchData    => LLKRXDATA21_GlitchData,
	OutSignalName => "LLKRXDATA(21)",
	OutTemp       => LLKRXDATA_OUT(21),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(22),
	GlitchData    => LLKRXDATA22_GlitchData,
	OutSignalName => "LLKRXDATA(22)",
	OutTemp       => LLKRXDATA_OUT(22),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(22),
	GlitchData    => LLKRXDATA22_GlitchData,
	OutSignalName => "LLKRXDATA(22)",
	OutTemp       => LLKRXDATA_OUT(22),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(23),
	GlitchData    => LLKRXDATA23_GlitchData,
	OutSignalName => "LLKRXDATA(23)",
	OutTemp       => LLKRXDATA_OUT(23),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(23),
	GlitchData    => LLKRXDATA23_GlitchData,
	OutSignalName => "LLKRXDATA(23)",
	OutTemp       => LLKRXDATA_OUT(23),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(24),
	GlitchData    => LLKRXDATA24_GlitchData,
	OutSignalName => "LLKRXDATA(24)",
	OutTemp       => LLKRXDATA_OUT(24),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(24),
	GlitchData    => LLKRXDATA24_GlitchData,
	OutSignalName => "LLKRXDATA(24)",
	OutTemp       => LLKRXDATA_OUT(24),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(25),
	GlitchData    => LLKRXDATA25_GlitchData,
	OutSignalName => "LLKRXDATA(25)",
	OutTemp       => LLKRXDATA_OUT(25),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(25),
	GlitchData    => LLKRXDATA25_GlitchData,
	OutSignalName => "LLKRXDATA(25)",
	OutTemp       => LLKRXDATA_OUT(25),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(26),
	GlitchData    => LLKRXDATA26_GlitchData,
	OutSignalName => "LLKRXDATA(26)",
	OutTemp       => LLKRXDATA_OUT(26),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(26),
	GlitchData    => LLKRXDATA26_GlitchData,
	OutSignalName => "LLKRXDATA(26)",
	OutTemp       => LLKRXDATA_OUT(26),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(27),
	GlitchData    => LLKRXDATA27_GlitchData,
	OutSignalName => "LLKRXDATA(27)",
	OutTemp       => LLKRXDATA_OUT(27),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(27),
	GlitchData    => LLKRXDATA27_GlitchData,
	OutSignalName => "LLKRXDATA(27)",
	OutTemp       => LLKRXDATA_OUT(27),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(28),
	GlitchData    => LLKRXDATA28_GlitchData,
	OutSignalName => "LLKRXDATA(28)",
	OutTemp       => LLKRXDATA_OUT(28),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(28),
	GlitchData    => LLKRXDATA28_GlitchData,
	OutSignalName => "LLKRXDATA(28)",
	OutTemp       => LLKRXDATA_OUT(28),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(29),
	GlitchData    => LLKRXDATA29_GlitchData,
	OutSignalName => "LLKRXDATA(29)",
	OutTemp       => LLKRXDATA_OUT(29),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(29),
	GlitchData    => LLKRXDATA29_GlitchData,
	OutSignalName => "LLKRXDATA(29)",
	OutTemp       => LLKRXDATA_OUT(29),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(30),
	GlitchData    => LLKRXDATA30_GlitchData,
	OutSignalName => "LLKRXDATA(30)",
	OutTemp       => LLKRXDATA_OUT(30),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(30),
	GlitchData    => LLKRXDATA30_GlitchData,
	OutSignalName => "LLKRXDATA(30)",
	OutTemp       => LLKRXDATA_OUT(30),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(31),
	GlitchData    => LLKRXDATA31_GlitchData,
	OutSignalName => "LLKRXDATA(31)",
	OutTemp       => LLKRXDATA_OUT(31),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(31),
	GlitchData    => LLKRXDATA31_GlitchData,
	OutSignalName => "LLKRXDATA(31)",
	OutTemp       => LLKRXDATA_OUT(31),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(32),
	GlitchData    => LLKRXDATA32_GlitchData,
	OutSignalName => "LLKRXDATA(32)",
	OutTemp       => LLKRXDATA_OUT(32),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(32),
	GlitchData    => LLKRXDATA32_GlitchData,
	OutSignalName => "LLKRXDATA(32)",
	OutTemp       => LLKRXDATA_OUT(32),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(33),
	GlitchData    => LLKRXDATA33_GlitchData,
	OutSignalName => "LLKRXDATA(33)",
	OutTemp       => LLKRXDATA_OUT(33),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(33),
	GlitchData    => LLKRXDATA33_GlitchData,
	OutSignalName => "LLKRXDATA(33)",
	OutTemp       => LLKRXDATA_OUT(33),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(34),
	GlitchData    => LLKRXDATA34_GlitchData,
	OutSignalName => "LLKRXDATA(34)",
	OutTemp       => LLKRXDATA_OUT(34),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(34),
	GlitchData    => LLKRXDATA34_GlitchData,
	OutSignalName => "LLKRXDATA(34)",
	OutTemp       => LLKRXDATA_OUT(34),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(35),
	GlitchData    => LLKRXDATA35_GlitchData,
	OutSignalName => "LLKRXDATA(35)",
	OutTemp       => LLKRXDATA_OUT(35),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(35),
	GlitchData    => LLKRXDATA35_GlitchData,
	OutSignalName => "LLKRXDATA(35)",
	OutTemp       => LLKRXDATA_OUT(35),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(36),
	GlitchData    => LLKRXDATA36_GlitchData,
	OutSignalName => "LLKRXDATA(36)",
	OutTemp       => LLKRXDATA_OUT(36),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(36),
	GlitchData    => LLKRXDATA36_GlitchData,
	OutSignalName => "LLKRXDATA(36)",
	OutTemp       => LLKRXDATA_OUT(36),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(37),
	GlitchData    => LLKRXDATA37_GlitchData,
	OutSignalName => "LLKRXDATA(37)",
	OutTemp       => LLKRXDATA_OUT(37),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(37),
	GlitchData    => LLKRXDATA37_GlitchData,
	OutSignalName => "LLKRXDATA(37)",
	OutTemp       => LLKRXDATA_OUT(37),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(38),
	GlitchData    => LLKRXDATA38_GlitchData,
	OutSignalName => "LLKRXDATA(38)",
	OutTemp       => LLKRXDATA_OUT(38),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(38),
	GlitchData    => LLKRXDATA38_GlitchData,
	OutSignalName => "LLKRXDATA(38)",
	OutTemp       => LLKRXDATA_OUT(38),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(39),
	GlitchData    => LLKRXDATA39_GlitchData,
	OutSignalName => "LLKRXDATA(39)",
	OutTemp       => LLKRXDATA_OUT(39),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(39),
	GlitchData    => LLKRXDATA39_GlitchData,
	OutSignalName => "LLKRXDATA(39)",
	OutTemp       => LLKRXDATA_OUT(39),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(40),
	GlitchData    => LLKRXDATA40_GlitchData,
	OutSignalName => "LLKRXDATA(40)",
	OutTemp       => LLKRXDATA_OUT(40),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(40),
	GlitchData    => LLKRXDATA40_GlitchData,
	OutSignalName => "LLKRXDATA(40)",
	OutTemp       => LLKRXDATA_OUT(40),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(41),
	GlitchData    => LLKRXDATA41_GlitchData,
	OutSignalName => "LLKRXDATA(41)",
	OutTemp       => LLKRXDATA_OUT(41),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(41),
	GlitchData    => LLKRXDATA41_GlitchData,
	OutSignalName => "LLKRXDATA(41)",
	OutTemp       => LLKRXDATA_OUT(41),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(42),
	GlitchData    => LLKRXDATA42_GlitchData,
	OutSignalName => "LLKRXDATA(42)",
	OutTemp       => LLKRXDATA_OUT(42),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(42),
	GlitchData    => LLKRXDATA42_GlitchData,
	OutSignalName => "LLKRXDATA(42)",
	OutTemp       => LLKRXDATA_OUT(42),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(43),
	GlitchData    => LLKRXDATA43_GlitchData,
	OutSignalName => "LLKRXDATA(43)",
	OutTemp       => LLKRXDATA_OUT(43),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(43),
	GlitchData    => LLKRXDATA43_GlitchData,
	OutSignalName => "LLKRXDATA(43)",
	OutTemp       => LLKRXDATA_OUT(43),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(44),
	GlitchData    => LLKRXDATA44_GlitchData,
	OutSignalName => "LLKRXDATA(44)",
	OutTemp       => LLKRXDATA_OUT(44),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(44),
	GlitchData    => LLKRXDATA44_GlitchData,
	OutSignalName => "LLKRXDATA(44)",
	OutTemp       => LLKRXDATA_OUT(44),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(45),
	GlitchData    => LLKRXDATA45_GlitchData,
	OutSignalName => "LLKRXDATA(45)",
	OutTemp       => LLKRXDATA_OUT(45),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(45),
	GlitchData    => LLKRXDATA45_GlitchData,
	OutSignalName => "LLKRXDATA(45)",
	OutTemp       => LLKRXDATA_OUT(45),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(46),
	GlitchData    => LLKRXDATA46_GlitchData,
	OutSignalName => "LLKRXDATA(46)",
	OutTemp       => LLKRXDATA_OUT(46),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(46),
	GlitchData    => LLKRXDATA46_GlitchData,
	OutSignalName => "LLKRXDATA(46)",
	OutTemp       => LLKRXDATA_OUT(46),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(47),
	GlitchData    => LLKRXDATA47_GlitchData,
	OutSignalName => "LLKRXDATA(47)",
	OutTemp       => LLKRXDATA_OUT(47),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(47),
	GlitchData    => LLKRXDATA47_GlitchData,
	OutSignalName => "LLKRXDATA(47)",
	OutTemp       => LLKRXDATA_OUT(47),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(48),
	GlitchData    => LLKRXDATA48_GlitchData,
	OutSignalName => "LLKRXDATA(48)",
	OutTemp       => LLKRXDATA_OUT(48),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(48),
	GlitchData    => LLKRXDATA48_GlitchData,
	OutSignalName => "LLKRXDATA(48)",
	OutTemp       => LLKRXDATA_OUT(48),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(49),
	GlitchData    => LLKRXDATA49_GlitchData,
	OutSignalName => "LLKRXDATA(49)",
	OutTemp       => LLKRXDATA_OUT(49),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(49),
	GlitchData    => LLKRXDATA49_GlitchData,
	OutSignalName => "LLKRXDATA(49)",
	OutTemp       => LLKRXDATA_OUT(49),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(50),
	GlitchData    => LLKRXDATA50_GlitchData,
	OutSignalName => "LLKRXDATA(50)",
	OutTemp       => LLKRXDATA_OUT(50),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(50),
	GlitchData    => LLKRXDATA50_GlitchData,
	OutSignalName => "LLKRXDATA(50)",
	OutTemp       => LLKRXDATA_OUT(50),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(51),
	GlitchData    => LLKRXDATA51_GlitchData,
	OutSignalName => "LLKRXDATA(51)",
	OutTemp       => LLKRXDATA_OUT(51),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(51),
	GlitchData    => LLKRXDATA51_GlitchData,
	OutSignalName => "LLKRXDATA(51)",
	OutTemp       => LLKRXDATA_OUT(51),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(52),
	GlitchData    => LLKRXDATA52_GlitchData,
	OutSignalName => "LLKRXDATA(52)",
	OutTemp       => LLKRXDATA_OUT(52),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(52),
	GlitchData    => LLKRXDATA52_GlitchData,
	OutSignalName => "LLKRXDATA(52)",
	OutTemp       => LLKRXDATA_OUT(52),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(53),
	GlitchData    => LLKRXDATA53_GlitchData,
	OutSignalName => "LLKRXDATA(53)",
	OutTemp       => LLKRXDATA_OUT(53),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(53),
	GlitchData    => LLKRXDATA53_GlitchData,
	OutSignalName => "LLKRXDATA(53)",
	OutTemp       => LLKRXDATA_OUT(53),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(54),
	GlitchData    => LLKRXDATA54_GlitchData,
	OutSignalName => "LLKRXDATA(54)",
	OutTemp       => LLKRXDATA_OUT(54),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(54),
	GlitchData    => LLKRXDATA54_GlitchData,
	OutSignalName => "LLKRXDATA(54)",
	OutTemp       => LLKRXDATA_OUT(54),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(55),
	GlitchData    => LLKRXDATA55_GlitchData,
	OutSignalName => "LLKRXDATA(55)",
	OutTemp       => LLKRXDATA_OUT(55),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(55),
	GlitchData    => LLKRXDATA55_GlitchData,
	OutSignalName => "LLKRXDATA(55)",
	OutTemp       => LLKRXDATA_OUT(55),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(56),
	GlitchData    => LLKRXDATA56_GlitchData,
	OutSignalName => "LLKRXDATA(56)",
	OutTemp       => LLKRXDATA_OUT(56),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(56),
	GlitchData    => LLKRXDATA56_GlitchData,
	OutSignalName => "LLKRXDATA(56)",
	OutTemp       => LLKRXDATA_OUT(56),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(57),
	GlitchData    => LLKRXDATA57_GlitchData,
	OutSignalName => "LLKRXDATA(57)",
	OutTemp       => LLKRXDATA_OUT(57),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(57),
	GlitchData    => LLKRXDATA57_GlitchData,
	OutSignalName => "LLKRXDATA(57)",
	OutTemp       => LLKRXDATA_OUT(57),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(58),
	GlitchData    => LLKRXDATA58_GlitchData,
	OutSignalName => "LLKRXDATA(58)",
	OutTemp       => LLKRXDATA_OUT(58),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(58),
	GlitchData    => LLKRXDATA58_GlitchData,
	OutSignalName => "LLKRXDATA(58)",
	OutTemp       => LLKRXDATA_OUT(58),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(59),
	GlitchData    => LLKRXDATA59_GlitchData,
	OutSignalName => "LLKRXDATA(59)",
	OutTemp       => LLKRXDATA_OUT(59),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(59),
	GlitchData    => LLKRXDATA59_GlitchData,
	OutSignalName => "LLKRXDATA(59)",
	OutTemp       => LLKRXDATA_OUT(59),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(60),
	GlitchData    => LLKRXDATA60_GlitchData,
	OutSignalName => "LLKRXDATA(60)",
	OutTemp       => LLKRXDATA_OUT(60),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(60),
	GlitchData    => LLKRXDATA60_GlitchData,
	OutSignalName => "LLKRXDATA(60)",
	OutTemp       => LLKRXDATA_OUT(60),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(61),
	GlitchData    => LLKRXDATA61_GlitchData,
	OutSignalName => "LLKRXDATA(61)",
	OutTemp       => LLKRXDATA_OUT(61),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(61),
	GlitchData    => LLKRXDATA61_GlitchData,
	OutSignalName => "LLKRXDATA(61)",
	OutTemp       => LLKRXDATA_OUT(61),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(62),
	GlitchData    => LLKRXDATA62_GlitchData,
	OutSignalName => "LLKRXDATA(62)",
	OutTemp       => LLKRXDATA_OUT(62),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(62),
	GlitchData    => LLKRXDATA62_GlitchData,
	OutSignalName => "LLKRXDATA(62)",
	OutTemp       => LLKRXDATA_OUT(62),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(63),
	GlitchData    => LLKRXDATA63_GlitchData,
	OutSignalName => "LLKRXDATA(63)",
	OutTemp       => LLKRXDATA_OUT(63),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXDATA(63),
	GlitchData    => LLKRXDATA63_GlitchData,
	OutSignalName => "LLKRXDATA(63)",
	OutTemp       => LLKRXDATA_OUT(63),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSRCRDYN,
	GlitchData    => LLKRXSRCRDYN_GlitchData,
	OutSignalName => "LLKRXSRCRDYN",
	OutTemp       => LLKRXSRCRDYN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSRCRDYN,
	GlitchData    => LLKRXSRCRDYN_GlitchData,
	OutSignalName => "LLKRXSRCRDYN",
	OutTemp       => LLKRXSRCRDYN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSRCLASTREQN,
	GlitchData    => LLKRXSRCLASTREQN_GlitchData,
	OutSignalName => "LLKRXSRCLASTREQN",
	OutTemp       => LLKRXSRCLASTREQN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSRCLASTREQN,
	GlitchData    => LLKRXSRCLASTREQN_GlitchData,
	OutSignalName => "LLKRXSRCLASTREQN",
	OutTemp       => LLKRXSRCLASTREQN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSRCDSCN,
	GlitchData    => LLKRXSRCDSCN_GlitchData,
	OutSignalName => "LLKRXSRCDSCN",
	OutTemp       => LLKRXSRCDSCN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSRCDSCN,
	GlitchData    => LLKRXSRCDSCN_GlitchData,
	OutSignalName => "LLKRXSRCDSCN",
	OutTemp       => LLKRXSRCDSCN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSOFN,
	GlitchData    => LLKRXSOFN_GlitchData,
	OutSignalName => "LLKRXSOFN",
	OutTemp       => LLKRXSOFN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSOFN,
	GlitchData    => LLKRXSOFN_GlitchData,
	OutSignalName => "LLKRXSOFN",
	OutTemp       => LLKRXSOFN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXEOFN,
	GlitchData    => LLKRXEOFN_GlitchData,
	OutSignalName => "LLKRXEOFN",
	OutTemp       => LLKRXEOFN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXEOFN,
	GlitchData    => LLKRXEOFN_GlitchData,
	OutSignalName => "LLKRXEOFN",
	OutTemp       => LLKRXEOFN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSOPN,
	GlitchData    => LLKRXSOPN_GlitchData,
	OutSignalName => "LLKRXSOPN",
	OutTemp       => LLKRXSOPN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXSOPN,
	GlitchData    => LLKRXSOPN_GlitchData,
	OutSignalName => "LLKRXSOPN",
	OutTemp       => LLKRXSOPN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXEOPN,
	GlitchData    => LLKRXEOPN_GlitchData,
	OutSignalName => "LLKRXEOPN",
	OutTemp       => LLKRXEOPN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXEOPN,
	GlitchData    => LLKRXEOPN_GlitchData,
	OutSignalName => "LLKRXEOPN",
	OutTemp       => LLKRXEOPN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXVALIDN(0),
	GlitchData    => LLKRXVALIDN0_GlitchData,
	OutSignalName => "LLKRXVALIDN(0)",
	OutTemp       => LLKRXVALIDN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXVALIDN(0),
	GlitchData    => LLKRXVALIDN0_GlitchData,
	OutSignalName => "LLKRXVALIDN(0)",
	OutTemp       => LLKRXVALIDN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXVALIDN(1),
	GlitchData    => LLKRXVALIDN1_GlitchData,
	OutSignalName => "LLKRXVALIDN(1)",
	OutTemp       => LLKRXVALIDN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXVALIDN(1),
	GlitchData    => LLKRXVALIDN1_GlitchData,
	OutSignalName => "LLKRXVALIDN(1)",
	OutTemp       => LLKRXVALIDN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(0),
	GlitchData    => LLKRXPREFERREDTYPE0_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(0)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(0),
	GlitchData    => LLKRXPREFERREDTYPE0_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(0)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(1),
	GlitchData    => LLKRXPREFERREDTYPE1_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(1)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(1),
	GlitchData    => LLKRXPREFERREDTYPE1_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(1)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(2),
	GlitchData    => LLKRXPREFERREDTYPE2_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(2)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(2),
	GlitchData    => LLKRXPREFERREDTYPE2_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(2)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(3),
	GlitchData    => LLKRXPREFERREDTYPE3_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(3)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(3),
	GlitchData    => LLKRXPREFERREDTYPE3_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(3)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(4),
	GlitchData    => LLKRXPREFERREDTYPE4_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(4)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(4),
	GlitchData    => LLKRXPREFERREDTYPE4_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(4)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(5),
	GlitchData    => LLKRXPREFERREDTYPE5_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(5)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(5),
	GlitchData    => LLKRXPREFERREDTYPE5_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(5)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(6),
	GlitchData    => LLKRXPREFERREDTYPE6_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(6)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(6),
	GlitchData    => LLKRXPREFERREDTYPE6_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(6)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(7),
	GlitchData    => LLKRXPREFERREDTYPE7_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(7)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(7),
	GlitchData    => LLKRXPREFERREDTYPE7_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(7)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(8),
	GlitchData    => LLKRXPREFERREDTYPE8_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(8)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(8),
	GlitchData    => LLKRXPREFERREDTYPE8_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(8)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(9),
	GlitchData    => LLKRXPREFERREDTYPE9_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(9)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(9),
	GlitchData    => LLKRXPREFERREDTYPE9_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(9)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(10),
	GlitchData    => LLKRXPREFERREDTYPE10_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(10)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(10),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(10),
	GlitchData    => LLKRXPREFERREDTYPE10_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(10)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(11),
	GlitchData    => LLKRXPREFERREDTYPE11_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(11)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(11),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(11),
	GlitchData    => LLKRXPREFERREDTYPE11_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(11)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(12),
	GlitchData    => LLKRXPREFERREDTYPE12_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(12)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(12),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(12),
	GlitchData    => LLKRXPREFERREDTYPE12_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(12)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(13),
	GlitchData    => LLKRXPREFERREDTYPE13_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(13)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(13),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(13),
	GlitchData    => LLKRXPREFERREDTYPE13_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(13)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(14),
	GlitchData    => LLKRXPREFERREDTYPE14_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(14)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(14),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(14),
	GlitchData    => LLKRXPREFERREDTYPE14_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(14)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(15),
	GlitchData    => LLKRXPREFERREDTYPE15_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(15)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(15),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXPREFERREDTYPE(15),
	GlitchData    => LLKRXPREFERREDTYPE15_GlitchData,
	OutSignalName => "LLKRXPREFERREDTYPE(15)",
	OutTemp       => LLKRXPREFERREDTYPE_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(0),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN0_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(0)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(0),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN0_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(0)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(1),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN1_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(1)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(1),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN1_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(1)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(2),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN2_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(2)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(2),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN2_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(2)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(3),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN3_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(3)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(3),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN3_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(3)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(4),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN4_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(4)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(4),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN4_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(4)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(5),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN5_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(5)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(5),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN5_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(5)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(6),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN6_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(6)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(6),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN6_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(6)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(7),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN7_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(7)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDAVAILABLEN(7),
	GlitchData    => LLKRXCHPOSTEDAVAILABLEN7_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDAVAILABLEN(7)",
	OutTemp       => LLKRXCHPOSTEDAVAILABLEN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(0),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN0_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(0)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(0),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN0_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(0)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(1),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN1_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(1)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(1),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN1_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(1)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(2),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN2_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(2)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(2),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN2_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(2)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(3),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN3_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(3)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(3),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN3_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(3)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(4),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN4_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(4)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(4),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN4_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(4)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(5),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN5_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(5)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(5),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN5_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(5)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(6),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN6_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(6)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(6),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN6_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(6)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(7),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN7_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(7)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDAVAILABLEN(7),
	GlitchData    => LLKRXCHNONPOSTEDAVAILABLEN7_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDAVAILABLEN(7)",
	OutTemp       => LLKRXCHNONPOSTEDAVAILABLEN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(0),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN0_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(0)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(0),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN0_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(0)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(1),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN1_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(1)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(1),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN1_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(1)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(2),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN2_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(2)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(2),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN2_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(2)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(3),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN3_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(3)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(3),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN3_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(3)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(4),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN4_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(4)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(4),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN4_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(4)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(5),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN5_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(5)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(5),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN5_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(5)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(6),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN6_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(6)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(6),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN6_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(6)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(7),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN7_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(7)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONAVAILABLEN(7),
	GlitchData    => LLKRXCHCOMPLETIONAVAILABLEN7_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONAVAILABLEN(7)",
	OutTemp       => LLKRXCHCOMPLETIONAVAILABLEN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCONFIGAVAILABLEN,
	GlitchData    => LLKRXCHCONFIGAVAILABLEN_GlitchData,
	OutSignalName => "LLKRXCHCONFIGAVAILABLEN",
	OutTemp       => LLKRXCHCONFIGAVAILABLEN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCONFIGAVAILABLEN,
	GlitchData    => LLKRXCHCONFIGAVAILABLEN_GlitchData,
	OutSignalName => "LLKRXCHCONFIGAVAILABLEN",
	OutTemp       => LLKRXCHCONFIGAVAILABLEN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(0),
	GlitchData    => LLKRXCHPOSTEDPARTIALN0_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(0)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(0),
	GlitchData    => LLKRXCHPOSTEDPARTIALN0_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(0)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(1),
	GlitchData    => LLKRXCHPOSTEDPARTIALN1_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(1)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(1),
	GlitchData    => LLKRXCHPOSTEDPARTIALN1_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(1)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(2),
	GlitchData    => LLKRXCHPOSTEDPARTIALN2_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(2)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(2),
	GlitchData    => LLKRXCHPOSTEDPARTIALN2_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(2)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(3),
	GlitchData    => LLKRXCHPOSTEDPARTIALN3_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(3)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(3),
	GlitchData    => LLKRXCHPOSTEDPARTIALN3_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(3)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(4),
	GlitchData    => LLKRXCHPOSTEDPARTIALN4_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(4)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(4),
	GlitchData    => LLKRXCHPOSTEDPARTIALN4_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(4)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(5),
	GlitchData    => LLKRXCHPOSTEDPARTIALN5_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(5)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(5),
	GlitchData    => LLKRXCHPOSTEDPARTIALN5_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(5)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(6),
	GlitchData    => LLKRXCHPOSTEDPARTIALN6_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(6)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(6),
	GlitchData    => LLKRXCHPOSTEDPARTIALN6_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(6)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(7),
	GlitchData    => LLKRXCHPOSTEDPARTIALN7_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(7)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHPOSTEDPARTIALN(7),
	GlitchData    => LLKRXCHPOSTEDPARTIALN7_GlitchData,
	OutSignalName => "LLKRXCHPOSTEDPARTIALN(7)",
	OutTemp       => LLKRXCHPOSTEDPARTIALN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(0),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN0_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(0)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(0),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN0_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(0)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(1),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN1_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(1)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(1),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN1_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(1)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(2),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN2_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(2)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(2),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN2_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(2)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(3),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN3_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(3)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(3),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN3_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(3)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(4),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN4_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(4)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(4),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN4_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(4)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(5),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN5_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(5)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(5),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN5_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(5)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(6),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN6_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(6)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(6),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN6_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(6)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(7),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN7_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(7)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHNONPOSTEDPARTIALN(7),
	GlitchData    => LLKRXCHNONPOSTEDPARTIALN7_GlitchData,
	OutSignalName => "LLKRXCHNONPOSTEDPARTIALN(7)",
	OutTemp       => LLKRXCHNONPOSTEDPARTIALN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(0),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN0_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(0)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(0),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN0_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(0)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(1),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN1_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(1)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(1),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN1_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(1)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(2),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN2_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(2)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(2),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN2_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(2)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(3),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN3_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(3)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(3),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN3_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(3)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(4),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN4_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(4)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(4),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN4_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(4)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(5),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN5_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(5)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(5),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN5_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(5)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(6),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN6_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(6)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(6),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN6_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(6)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(7),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN7_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(7)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCOMPLETIONPARTIALN(7),
	GlitchData    => LLKRXCHCOMPLETIONPARTIALN7_GlitchData,
	OutSignalName => "LLKRXCHCOMPLETIONPARTIALN(7)",
	OutTemp       => LLKRXCHCOMPLETIONPARTIALN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCONFIGPARTIALN,
	GlitchData    => LLKRXCHCONFIGPARTIALN_GlitchData,
	OutSignalName => "LLKRXCHCONFIGPARTIALN",
	OutTemp       => LLKRXCHCONFIGPARTIALN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXCHCONFIGPARTIALN,
	GlitchData    => LLKRXCHCONFIGPARTIALN_GlitchData,
	OutSignalName => "LLKRXCHCONFIGPARTIALN",
	OutTemp       => LLKRXCHCONFIGPARTIALN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRX4DWHEADERN,
	GlitchData    => LLKRX4DWHEADERN_GlitchData,
	OutSignalName => "LLKRX4DWHEADERN",
	OutTemp       => LLKRX4DWHEADERN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRX4DWHEADERN,
	GlitchData    => LLKRX4DWHEADERN_GlitchData,
	OutSignalName => "LLKRX4DWHEADERN",
	OutTemp       => LLKRX4DWHEADERN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXECRCBADN,
	GlitchData    => LLKRXECRCBADN_GlitchData,
	OutSignalName => "LLKRXECRCBADN",
	OutTemp       => LLKRXECRCBADN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => LLKRXECRCBADN,
	GlitchData    => LLKRXECRCBADN_GlitchData,
	OutSignalName => "LLKRXECRCBADN",
	OutTemp       => LLKRXECRCBADN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(0),
	GlitchData    => MGMTRDATA0_GlitchData,
	OutSignalName => "MGMTRDATA(0)",
	OutTemp       => MGMTRDATA_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(0),
	GlitchData    => MGMTRDATA0_GlitchData,
	OutSignalName => "MGMTRDATA(0)",
	OutTemp       => MGMTRDATA_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(1),
	GlitchData    => MGMTRDATA1_GlitchData,
	OutSignalName => "MGMTRDATA(1)",
	OutTemp       => MGMTRDATA_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(1),
	GlitchData    => MGMTRDATA1_GlitchData,
	OutSignalName => "MGMTRDATA(1)",
	OutTemp       => MGMTRDATA_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(2),
	GlitchData    => MGMTRDATA2_GlitchData,
	OutSignalName => "MGMTRDATA(2)",
	OutTemp       => MGMTRDATA_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(2),
	GlitchData    => MGMTRDATA2_GlitchData,
	OutSignalName => "MGMTRDATA(2)",
	OutTemp       => MGMTRDATA_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(3),
	GlitchData    => MGMTRDATA3_GlitchData,
	OutSignalName => "MGMTRDATA(3)",
	OutTemp       => MGMTRDATA_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(3),
	GlitchData    => MGMTRDATA3_GlitchData,
	OutSignalName => "MGMTRDATA(3)",
	OutTemp       => MGMTRDATA_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(4),
	GlitchData    => MGMTRDATA4_GlitchData,
	OutSignalName => "MGMTRDATA(4)",
	OutTemp       => MGMTRDATA_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(4),
	GlitchData    => MGMTRDATA4_GlitchData,
	OutSignalName => "MGMTRDATA(4)",
	OutTemp       => MGMTRDATA_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(5),
	GlitchData    => MGMTRDATA5_GlitchData,
	OutSignalName => "MGMTRDATA(5)",
	OutTemp       => MGMTRDATA_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(5),
	GlitchData    => MGMTRDATA5_GlitchData,
	OutSignalName => "MGMTRDATA(5)",
	OutTemp       => MGMTRDATA_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(6),
	GlitchData    => MGMTRDATA6_GlitchData,
	OutSignalName => "MGMTRDATA(6)",
	OutTemp       => MGMTRDATA_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(6),
	GlitchData    => MGMTRDATA6_GlitchData,
	OutSignalName => "MGMTRDATA(6)",
	OutTemp       => MGMTRDATA_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(7),
	GlitchData    => MGMTRDATA7_GlitchData,
	OutSignalName => "MGMTRDATA(7)",
	OutTemp       => MGMTRDATA_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(7),
	GlitchData    => MGMTRDATA7_GlitchData,
	OutSignalName => "MGMTRDATA(7)",
	OutTemp       => MGMTRDATA_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(8),
	GlitchData    => MGMTRDATA8_GlitchData,
	OutSignalName => "MGMTRDATA(8)",
	OutTemp       => MGMTRDATA_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(8),
	GlitchData    => MGMTRDATA8_GlitchData,
	OutSignalName => "MGMTRDATA(8)",
	OutTemp       => MGMTRDATA_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(9),
	GlitchData    => MGMTRDATA9_GlitchData,
	OutSignalName => "MGMTRDATA(9)",
	OutTemp       => MGMTRDATA_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(9),
	GlitchData    => MGMTRDATA9_GlitchData,
	OutSignalName => "MGMTRDATA(9)",
	OutTemp       => MGMTRDATA_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(10),
	GlitchData    => MGMTRDATA10_GlitchData,
	OutSignalName => "MGMTRDATA(10)",
	OutTemp       => MGMTRDATA_OUT(10),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(10),
	GlitchData    => MGMTRDATA10_GlitchData,
	OutSignalName => "MGMTRDATA(10)",
	OutTemp       => MGMTRDATA_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(11),
	GlitchData    => MGMTRDATA11_GlitchData,
	OutSignalName => "MGMTRDATA(11)",
	OutTemp       => MGMTRDATA_OUT(11),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(11),
	GlitchData    => MGMTRDATA11_GlitchData,
	OutSignalName => "MGMTRDATA(11)",
	OutTemp       => MGMTRDATA_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(12),
	GlitchData    => MGMTRDATA12_GlitchData,
	OutSignalName => "MGMTRDATA(12)",
	OutTemp       => MGMTRDATA_OUT(12),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(12),
	GlitchData    => MGMTRDATA12_GlitchData,
	OutSignalName => "MGMTRDATA(12)",
	OutTemp       => MGMTRDATA_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(13),
	GlitchData    => MGMTRDATA13_GlitchData,
	OutSignalName => "MGMTRDATA(13)",
	OutTemp       => MGMTRDATA_OUT(13),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(13),
	GlitchData    => MGMTRDATA13_GlitchData,
	OutSignalName => "MGMTRDATA(13)",
	OutTemp       => MGMTRDATA_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(14),
	GlitchData    => MGMTRDATA14_GlitchData,
	OutSignalName => "MGMTRDATA(14)",
	OutTemp       => MGMTRDATA_OUT(14),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(14),
	GlitchData    => MGMTRDATA14_GlitchData,
	OutSignalName => "MGMTRDATA(14)",
	OutTemp       => MGMTRDATA_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(15),
	GlitchData    => MGMTRDATA15_GlitchData,
	OutSignalName => "MGMTRDATA(15)",
	OutTemp       => MGMTRDATA_OUT(15),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(15),
	GlitchData    => MGMTRDATA15_GlitchData,
	OutSignalName => "MGMTRDATA(15)",
	OutTemp       => MGMTRDATA_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(16),
	GlitchData    => MGMTRDATA16_GlitchData,
	OutSignalName => "MGMTRDATA(16)",
	OutTemp       => MGMTRDATA_OUT(16),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(16),
	GlitchData    => MGMTRDATA16_GlitchData,
	OutSignalName => "MGMTRDATA(16)",
	OutTemp       => MGMTRDATA_OUT(16),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(17),
	GlitchData    => MGMTRDATA17_GlitchData,
	OutSignalName => "MGMTRDATA(17)",
	OutTemp       => MGMTRDATA_OUT(17),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(17),
	GlitchData    => MGMTRDATA17_GlitchData,
	OutSignalName => "MGMTRDATA(17)",
	OutTemp       => MGMTRDATA_OUT(17),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(18),
	GlitchData    => MGMTRDATA18_GlitchData,
	OutSignalName => "MGMTRDATA(18)",
	OutTemp       => MGMTRDATA_OUT(18),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(18),
	GlitchData    => MGMTRDATA18_GlitchData,
	OutSignalName => "MGMTRDATA(18)",
	OutTemp       => MGMTRDATA_OUT(18),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(19),
	GlitchData    => MGMTRDATA19_GlitchData,
	OutSignalName => "MGMTRDATA(19)",
	OutTemp       => MGMTRDATA_OUT(19),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(19),
	GlitchData    => MGMTRDATA19_GlitchData,
	OutSignalName => "MGMTRDATA(19)",
	OutTemp       => MGMTRDATA_OUT(19),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(20),
	GlitchData    => MGMTRDATA20_GlitchData,
	OutSignalName => "MGMTRDATA(20)",
	OutTemp       => MGMTRDATA_OUT(20),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(20),
	GlitchData    => MGMTRDATA20_GlitchData,
	OutSignalName => "MGMTRDATA(20)",
	OutTemp       => MGMTRDATA_OUT(20),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(21),
	GlitchData    => MGMTRDATA21_GlitchData,
	OutSignalName => "MGMTRDATA(21)",
	OutTemp       => MGMTRDATA_OUT(21),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(21),
	GlitchData    => MGMTRDATA21_GlitchData,
	OutSignalName => "MGMTRDATA(21)",
	OutTemp       => MGMTRDATA_OUT(21),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(22),
	GlitchData    => MGMTRDATA22_GlitchData,
	OutSignalName => "MGMTRDATA(22)",
	OutTemp       => MGMTRDATA_OUT(22),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(22),
	GlitchData    => MGMTRDATA22_GlitchData,
	OutSignalName => "MGMTRDATA(22)",
	OutTemp       => MGMTRDATA_OUT(22),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(23),
	GlitchData    => MGMTRDATA23_GlitchData,
	OutSignalName => "MGMTRDATA(23)",
	OutTemp       => MGMTRDATA_OUT(23),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(23),
	GlitchData    => MGMTRDATA23_GlitchData,
	OutSignalName => "MGMTRDATA(23)",
	OutTemp       => MGMTRDATA_OUT(23),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(24),
	GlitchData    => MGMTRDATA24_GlitchData,
	OutSignalName => "MGMTRDATA(24)",
	OutTemp       => MGMTRDATA_OUT(24),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(24),
	GlitchData    => MGMTRDATA24_GlitchData,
	OutSignalName => "MGMTRDATA(24)",
	OutTemp       => MGMTRDATA_OUT(24),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(25),
	GlitchData    => MGMTRDATA25_GlitchData,
	OutSignalName => "MGMTRDATA(25)",
	OutTemp       => MGMTRDATA_OUT(25),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(25),
	GlitchData    => MGMTRDATA25_GlitchData,
	OutSignalName => "MGMTRDATA(25)",
	OutTemp       => MGMTRDATA_OUT(25),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(26),
	GlitchData    => MGMTRDATA26_GlitchData,
	OutSignalName => "MGMTRDATA(26)",
	OutTemp       => MGMTRDATA_OUT(26),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(26),
	GlitchData    => MGMTRDATA26_GlitchData,
	OutSignalName => "MGMTRDATA(26)",
	OutTemp       => MGMTRDATA_OUT(26),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(27),
	GlitchData    => MGMTRDATA27_GlitchData,
	OutSignalName => "MGMTRDATA(27)",
	OutTemp       => MGMTRDATA_OUT(27),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(27),
	GlitchData    => MGMTRDATA27_GlitchData,
	OutSignalName => "MGMTRDATA(27)",
	OutTemp       => MGMTRDATA_OUT(27),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(28),
	GlitchData    => MGMTRDATA28_GlitchData,
	OutSignalName => "MGMTRDATA(28)",
	OutTemp       => MGMTRDATA_OUT(28),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(28),
	GlitchData    => MGMTRDATA28_GlitchData,
	OutSignalName => "MGMTRDATA(28)",
	OutTemp       => MGMTRDATA_OUT(28),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(29),
	GlitchData    => MGMTRDATA29_GlitchData,
	OutSignalName => "MGMTRDATA(29)",
	OutTemp       => MGMTRDATA_OUT(29),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(29),
	GlitchData    => MGMTRDATA29_GlitchData,
	OutSignalName => "MGMTRDATA(29)",
	OutTemp       => MGMTRDATA_OUT(29),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(30),
	GlitchData    => MGMTRDATA30_GlitchData,
	OutSignalName => "MGMTRDATA(30)",
	OutTemp       => MGMTRDATA_OUT(30),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(30),
	GlitchData    => MGMTRDATA30_GlitchData,
	OutSignalName => "MGMTRDATA(30)",
	OutTemp       => MGMTRDATA_OUT(30),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(31),
	GlitchData    => MGMTRDATA31_GlitchData,
	OutSignalName => "MGMTRDATA(31)",
	OutTemp       => MGMTRDATA_OUT(31),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTRDATA(31),
	GlitchData    => MGMTRDATA31_GlitchData,
	OutSignalName => "MGMTRDATA(31)",
	OutTemp       => MGMTRDATA_OUT(31),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(0),
	GlitchData    => MGMTPSO0_GlitchData,
	OutSignalName => "MGMTPSO(0)",
	OutTemp       => MGMTPSO_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(0),
	GlitchData    => MGMTPSO0_GlitchData,
	OutSignalName => "MGMTPSO(0)",
	OutTemp       => MGMTPSO_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(1),
	GlitchData    => MGMTPSO1_GlitchData,
	OutSignalName => "MGMTPSO(1)",
	OutTemp       => MGMTPSO_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(1),
	GlitchData    => MGMTPSO1_GlitchData,
	OutSignalName => "MGMTPSO(1)",
	OutTemp       => MGMTPSO_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(2),
	GlitchData    => MGMTPSO2_GlitchData,
	OutSignalName => "MGMTPSO(2)",
	OutTemp       => MGMTPSO_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(2),
	GlitchData    => MGMTPSO2_GlitchData,
	OutSignalName => "MGMTPSO(2)",
	OutTemp       => MGMTPSO_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(3),
	GlitchData    => MGMTPSO3_GlitchData,
	OutSignalName => "MGMTPSO(3)",
	OutTemp       => MGMTPSO_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(3),
	GlitchData    => MGMTPSO3_GlitchData,
	OutSignalName => "MGMTPSO(3)",
	OutTemp       => MGMTPSO_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(4),
	GlitchData    => MGMTPSO4_GlitchData,
	OutSignalName => "MGMTPSO(4)",
	OutTemp       => MGMTPSO_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(4),
	GlitchData    => MGMTPSO4_GlitchData,
	OutSignalName => "MGMTPSO(4)",
	OutTemp       => MGMTPSO_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(5),
	GlitchData    => MGMTPSO5_GlitchData,
	OutSignalName => "MGMTPSO(5)",
	OutTemp       => MGMTPSO_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(5),
	GlitchData    => MGMTPSO5_GlitchData,
	OutSignalName => "MGMTPSO(5)",
	OutTemp       => MGMTPSO_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(6),
	GlitchData    => MGMTPSO6_GlitchData,
	OutSignalName => "MGMTPSO(6)",
	OutTemp       => MGMTPSO_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(6),
	GlitchData    => MGMTPSO6_GlitchData,
	OutSignalName => "MGMTPSO(6)",
	OutTemp       => MGMTPSO_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(7),
	GlitchData    => MGMTPSO7_GlitchData,
	OutSignalName => "MGMTPSO(7)",
	OutTemp       => MGMTPSO_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(7),
	GlitchData    => MGMTPSO7_GlitchData,
	OutSignalName => "MGMTPSO(7)",
	OutTemp       => MGMTPSO_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(8),
	GlitchData    => MGMTPSO8_GlitchData,
	OutSignalName => "MGMTPSO(8)",
	OutTemp       => MGMTPSO_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(8),
	GlitchData    => MGMTPSO8_GlitchData,
	OutSignalName => "MGMTPSO(8)",
	OutTemp       => MGMTPSO_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(9),
	GlitchData    => MGMTPSO9_GlitchData,
	OutSignalName => "MGMTPSO(9)",
	OutTemp       => MGMTPSO_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(9),
	GlitchData    => MGMTPSO9_GlitchData,
	OutSignalName => "MGMTPSO(9)",
	OutTemp       => MGMTPSO_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(10),
	GlitchData    => MGMTPSO10_GlitchData,
	OutSignalName => "MGMTPSO(10)",
	OutTemp       => MGMTPSO_OUT(10),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(10),
	GlitchData    => MGMTPSO10_GlitchData,
	OutSignalName => "MGMTPSO(10)",
	OutTemp       => MGMTPSO_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(11),
	GlitchData    => MGMTPSO11_GlitchData,
	OutSignalName => "MGMTPSO(11)",
	OutTemp       => MGMTPSO_OUT(11),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(11),
	GlitchData    => MGMTPSO11_GlitchData,
	OutSignalName => "MGMTPSO(11)",
	OutTemp       => MGMTPSO_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(12),
	GlitchData    => MGMTPSO12_GlitchData,
	OutSignalName => "MGMTPSO(12)",
	OutTemp       => MGMTPSO_OUT(12),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(12),
	GlitchData    => MGMTPSO12_GlitchData,
	OutSignalName => "MGMTPSO(12)",
	OutTemp       => MGMTPSO_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(13),
	GlitchData    => MGMTPSO13_GlitchData,
	OutSignalName => "MGMTPSO(13)",
	OutTemp       => MGMTPSO_OUT(13),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(13),
	GlitchData    => MGMTPSO13_GlitchData,
	OutSignalName => "MGMTPSO(13)",
	OutTemp       => MGMTPSO_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(14),
	GlitchData    => MGMTPSO14_GlitchData,
	OutSignalName => "MGMTPSO(14)",
	OutTemp       => MGMTPSO_OUT(14),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(14),
	GlitchData    => MGMTPSO14_GlitchData,
	OutSignalName => "MGMTPSO(14)",
	OutTemp       => MGMTPSO_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(15),
	GlitchData    => MGMTPSO15_GlitchData,
	OutSignalName => "MGMTPSO(15)",
	OutTemp       => MGMTPSO_OUT(15),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(15),
	GlitchData    => MGMTPSO15_GlitchData,
	OutSignalName => "MGMTPSO(15)",
	OutTemp       => MGMTPSO_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(16),
	GlitchData    => MGMTPSO16_GlitchData,
	OutSignalName => "MGMTPSO(16)",
	OutTemp       => MGMTPSO_OUT(16),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTPSO(16),
	GlitchData    => MGMTPSO16_GlitchData,
	OutSignalName => "MGMTPSO(16)",
	OutTemp       => MGMTPSO_OUT(16),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(0),
	GlitchData    => MGMTSTATSCREDIT0_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(0)",
	OutTemp       => MGMTSTATSCREDIT_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(0),
	GlitchData    => MGMTSTATSCREDIT0_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(0)",
	OutTemp       => MGMTSTATSCREDIT_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(1),
	GlitchData    => MGMTSTATSCREDIT1_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(1)",
	OutTemp       => MGMTSTATSCREDIT_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(1),
	GlitchData    => MGMTSTATSCREDIT1_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(1)",
	OutTemp       => MGMTSTATSCREDIT_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(2),
	GlitchData    => MGMTSTATSCREDIT2_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(2)",
	OutTemp       => MGMTSTATSCREDIT_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(2),
	GlitchData    => MGMTSTATSCREDIT2_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(2)",
	OutTemp       => MGMTSTATSCREDIT_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(3),
	GlitchData    => MGMTSTATSCREDIT3_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(3)",
	OutTemp       => MGMTSTATSCREDIT_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(3),
	GlitchData    => MGMTSTATSCREDIT3_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(3)",
	OutTemp       => MGMTSTATSCREDIT_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(4),
	GlitchData    => MGMTSTATSCREDIT4_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(4)",
	OutTemp       => MGMTSTATSCREDIT_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(4),
	GlitchData    => MGMTSTATSCREDIT4_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(4)",
	OutTemp       => MGMTSTATSCREDIT_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(5),
	GlitchData    => MGMTSTATSCREDIT5_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(5)",
	OutTemp       => MGMTSTATSCREDIT_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(5),
	GlitchData    => MGMTSTATSCREDIT5_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(5)",
	OutTemp       => MGMTSTATSCREDIT_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(6),
	GlitchData    => MGMTSTATSCREDIT6_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(6)",
	OutTemp       => MGMTSTATSCREDIT_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(6),
	GlitchData    => MGMTSTATSCREDIT6_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(6)",
	OutTemp       => MGMTSTATSCREDIT_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(7),
	GlitchData    => MGMTSTATSCREDIT7_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(7)",
	OutTemp       => MGMTSTATSCREDIT_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(7),
	GlitchData    => MGMTSTATSCREDIT7_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(7)",
	OutTemp       => MGMTSTATSCREDIT_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(8),
	GlitchData    => MGMTSTATSCREDIT8_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(8)",
	OutTemp       => MGMTSTATSCREDIT_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(8),
	GlitchData    => MGMTSTATSCREDIT8_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(8)",
	OutTemp       => MGMTSTATSCREDIT_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(9),
	GlitchData    => MGMTSTATSCREDIT9_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(9)",
	OutTemp       => MGMTSTATSCREDIT_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(9),
	GlitchData    => MGMTSTATSCREDIT9_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(9)",
	OutTemp       => MGMTSTATSCREDIT_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(10),
	GlitchData    => MGMTSTATSCREDIT10_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(10)",
	OutTemp       => MGMTSTATSCREDIT_OUT(10),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(10),
	GlitchData    => MGMTSTATSCREDIT10_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(10)",
	OutTemp       => MGMTSTATSCREDIT_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(11),
	GlitchData    => MGMTSTATSCREDIT11_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(11)",
	OutTemp       => MGMTSTATSCREDIT_OUT(11),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MGMTSTATSCREDIT(11),
	GlitchData    => MGMTSTATSCREDIT11_GlitchData,
	OutSignalName => "MGMTSTATSCREDIT(11)",
	OutTemp       => MGMTSTATSCREDIT_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLTLPECRCOK,
	GlitchData    => L0RXDLLTLPECRCOK_GlitchData,
	OutSignalName => "L0RXDLLTLPECRCOK",
	OutTemp       => L0RXDLLTLPECRCOK_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => DLLTXPMDLLPOUTSTANDING,
	GlitchData    => DLLTXPMDLLPOUTSTANDING_GlitchData,
	OutSignalName => "DLLTXPMDLLPOUTSTANDING",
	OutTemp       => DLLTXPMDLLPOUTSTANDING_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FIRSTCFGWRITEOCCURRED,
	GlitchData    => L0FIRSTCFGWRITEOCCURRED_GlitchData,
	OutSignalName => "L0FIRSTCFGWRITEOCCURRED",
	OutTemp       => L0FIRSTCFGWRITEOCCURRED_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FIRSTCFGWRITEOCCURRED,
	GlitchData    => L0FIRSTCFGWRITEOCCURRED_GlitchData,
	OutSignalName => "L0FIRSTCFGWRITEOCCURRED",
	OutTemp       => L0FIRSTCFGWRITEOCCURRED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0CFGLOOPBACKACK,
	GlitchData    => L0CFGLOOPBACKACK_GlitchData,
	OutSignalName => "L0CFGLOOPBACKACK",
	OutTemp       => L0CFGLOOPBACKACK_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACUPSTREAMDOWNSTREAM,
	GlitchData    => L0MACUPSTREAMDOWNSTREAM_GlitchData,
	OutSignalName => "L0MACUPSTREAMDOWNSTREAM",
	OutTemp       => L0MACUPSTREAMDOWNSTREAM_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXMACLINKERROR(0),
	GlitchData    => L0RXMACLINKERROR0_GlitchData,
	OutSignalName => "L0RXMACLINKERROR(0)",
	OutTemp       => L0RXMACLINKERROR_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXMACLINKERROR(1),
	GlitchData    => L0RXMACLINKERROR1_GlitchData,
	OutSignalName => "L0RXMACLINKERROR(1)",
	OutTemp       => L0RXMACLINKERROR_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACLINKUP,
	GlitchData    => L0MACLINKUP_GlitchData,
	OutSignalName => "L0MACLINKUP",
	OutTemp       => L0MACLINKUP_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACNEGOTIATEDLINKWIDTH(0),
	GlitchData    => L0MACNEGOTIATEDLINKWIDTH0_GlitchData,
	OutSignalName => "L0MACNEGOTIATEDLINKWIDTH(0)",
	OutTemp       => L0MACNEGOTIATEDLINKWIDTH_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACNEGOTIATEDLINKWIDTH(1),
	GlitchData    => L0MACNEGOTIATEDLINKWIDTH1_GlitchData,
	OutSignalName => "L0MACNEGOTIATEDLINKWIDTH(1)",
	OutTemp       => L0MACNEGOTIATEDLINKWIDTH_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACNEGOTIATEDLINKWIDTH(2),
	GlitchData    => L0MACNEGOTIATEDLINKWIDTH2_GlitchData,
	OutSignalName => "L0MACNEGOTIATEDLINKWIDTH(2)",
	OutTemp       => L0MACNEGOTIATEDLINKWIDTH_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACNEGOTIATEDLINKWIDTH(3),
	GlitchData    => L0MACNEGOTIATEDLINKWIDTH3_GlitchData,
	OutSignalName => "L0MACNEGOTIATEDLINKWIDTH(3)",
	OutTemp       => L0MACNEGOTIATEDLINKWIDTH_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACLINKTRAINING,
	GlitchData    => L0MACLINKTRAINING_GlitchData,
	OutSignalName => "L0MACLINKTRAINING",
	OutTemp       => L0MACLINKTRAINING_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0LTSSMSTATE(0),
	GlitchData    => L0LTSSMSTATE0_GlitchData,
	OutSignalName => "L0LTSSMSTATE(0)",
	OutTemp       => L0LTSSMSTATE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0LTSSMSTATE(1),
	GlitchData    => L0LTSSMSTATE1_GlitchData,
	OutSignalName => "L0LTSSMSTATE(1)",
	OutTemp       => L0LTSSMSTATE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0LTSSMSTATE(2),
	GlitchData    => L0LTSSMSTATE2_GlitchData,
	OutSignalName => "L0LTSSMSTATE(2)",
	OutTemp       => L0LTSSMSTATE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0LTSSMSTATE(3),
	GlitchData    => L0LTSSMSTATE3_GlitchData,
	OutSignalName => "L0LTSSMSTATE(3)",
	OutTemp       => L0LTSSMSTATE_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(0),
	GlitchData    => L0DLLVCSTATUS0_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(0)",
	OutTemp       => L0DLLVCSTATUS_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(1),
	GlitchData    => L0DLLVCSTATUS1_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(1)",
	OutTemp       => L0DLLVCSTATUS_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(2),
	GlitchData    => L0DLLVCSTATUS2_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(2)",
	OutTemp       => L0DLLVCSTATUS_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(3),
	GlitchData    => L0DLLVCSTATUS3_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(3)",
	OutTemp       => L0DLLVCSTATUS_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(4),
	GlitchData    => L0DLLVCSTATUS4_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(4)",
	OutTemp       => L0DLLVCSTATUS_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(5),
	GlitchData    => L0DLLVCSTATUS5_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(5)",
	OutTemp       => L0DLLVCSTATUS_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(6),
	GlitchData    => L0DLLVCSTATUS6_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(6)",
	OutTemp       => L0DLLVCSTATUS_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLVCSTATUS(7),
	GlitchData    => L0DLLVCSTATUS7_GlitchData,
	OutSignalName => "L0DLLVCSTATUS(7)",
	OutTemp       => L0DLLVCSTATUS_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(0),
	GlitchData    => L0DLUPDOWN0_GlitchData,
	OutSignalName => "L0DLUPDOWN(0)",
	OutTemp       => L0DLUPDOWN_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(1),
	GlitchData    => L0DLUPDOWN1_GlitchData,
	OutSignalName => "L0DLUPDOWN(1)",
	OutTemp       => L0DLUPDOWN_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(2),
	GlitchData    => L0DLUPDOWN2_GlitchData,
	OutSignalName => "L0DLUPDOWN(2)",
	OutTemp       => L0DLUPDOWN_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(3),
	GlitchData    => L0DLUPDOWN3_GlitchData,
	OutSignalName => "L0DLUPDOWN(3)",
	OutTemp       => L0DLUPDOWN_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(4),
	GlitchData    => L0DLUPDOWN4_GlitchData,
	OutSignalName => "L0DLUPDOWN(4)",
	OutTemp       => L0DLUPDOWN_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(5),
	GlitchData    => L0DLUPDOWN5_GlitchData,
	OutSignalName => "L0DLUPDOWN(5)",
	OutTemp       => L0DLUPDOWN_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(6),
	GlitchData    => L0DLUPDOWN6_GlitchData,
	OutSignalName => "L0DLUPDOWN(6)",
	OutTemp       => L0DLUPDOWN_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLUPDOWN(7),
	GlitchData    => L0DLUPDOWN7_GlitchData,
	OutSignalName => "L0DLUPDOWN(7)",
	OutTemp       => L0DLUPDOWN_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLERRORVECTOR(0),
	GlitchData    => L0DLLERRORVECTOR0_GlitchData,
	OutSignalName => "L0DLLERRORVECTOR(0)",
	OutTemp       => L0DLLERRORVECTOR_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLERRORVECTOR(1),
	GlitchData    => L0DLLERRORVECTOR1_GlitchData,
	OutSignalName => "L0DLLERRORVECTOR(1)",
	OutTemp       => L0DLLERRORVECTOR_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLERRORVECTOR(2),
	GlitchData    => L0DLLERRORVECTOR2_GlitchData,
	OutSignalName => "L0DLLERRORVECTOR(2)",
	OutTemp       => L0DLLERRORVECTOR_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLERRORVECTOR(3),
	GlitchData    => L0DLLERRORVECTOR3_GlitchData,
	OutSignalName => "L0DLLERRORVECTOR(3)",
	OutTemp       => L0DLLERRORVECTOR_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLERRORVECTOR(4),
	GlitchData    => L0DLLERRORVECTOR4_GlitchData,
	OutSignalName => "L0DLLERRORVECTOR(4)",
	OutTemp       => L0DLLERRORVECTOR_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLERRORVECTOR(5),
	GlitchData    => L0DLLERRORVECTOR5_GlitchData,
	OutSignalName => "L0DLLERRORVECTOR(5)",
	OutTemp       => L0DLLERRORVECTOR_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLERRORVECTOR(6),
	GlitchData    => L0DLLERRORVECTOR6_GlitchData,
	OutSignalName => "L0DLLERRORVECTOR(6)",
	OutTemp       => L0DLLERRORVECTOR_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLASRXSTATE(0),
	GlitchData    => L0DLLASRXSTATE0_GlitchData,
	OutSignalName => "L0DLLASRXSTATE(0)",
	OutTemp       => L0DLLASRXSTATE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLASRXSTATE(1),
	GlitchData    => L0DLLASRXSTATE1_GlitchData,
	OutSignalName => "L0DLLASRXSTATE(1)",
	OutTemp       => L0DLLASRXSTATE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLASTXSTATE,
	GlitchData    => L0DLLASTXSTATE_GlitchData,
	OutSignalName => "L0DLLASTXSTATE",
	OutTemp       => L0DLLASTXSTATE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ASAUTONOMOUSINITCOMPLETED,
	GlitchData    => L0ASAUTONOMOUSINITCOMPLETED_GlitchData,
	OutSignalName => "L0ASAUTONOMOUSINITCOMPLETED",
	OutTemp       => L0ASAUTONOMOUSINITCOMPLETED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(0),
	GlitchData    => L0COMPLETERID0_GlitchData,
	OutSignalName => "L0COMPLETERID(0)",
	OutTemp       => L0COMPLETERID_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(0),
	GlitchData    => L0COMPLETERID0_GlitchData,
	OutSignalName => "L0COMPLETERID(0)",
	OutTemp       => L0COMPLETERID_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(1),
	GlitchData    => L0COMPLETERID1_GlitchData,
	OutSignalName => "L0COMPLETERID(1)",
	OutTemp       => L0COMPLETERID_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(1),
	GlitchData    => L0COMPLETERID1_GlitchData,
	OutSignalName => "L0COMPLETERID(1)",
	OutTemp       => L0COMPLETERID_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(2),
	GlitchData    => L0COMPLETERID2_GlitchData,
	OutSignalName => "L0COMPLETERID(2)",
	OutTemp       => L0COMPLETERID_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(2),
	GlitchData    => L0COMPLETERID2_GlitchData,
	OutSignalName => "L0COMPLETERID(2)",
	OutTemp       => L0COMPLETERID_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(3),
	GlitchData    => L0COMPLETERID3_GlitchData,
	OutSignalName => "L0COMPLETERID(3)",
	OutTemp       => L0COMPLETERID_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(3),
	GlitchData    => L0COMPLETERID3_GlitchData,
	OutSignalName => "L0COMPLETERID(3)",
	OutTemp       => L0COMPLETERID_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(4),
	GlitchData    => L0COMPLETERID4_GlitchData,
	OutSignalName => "L0COMPLETERID(4)",
	OutTemp       => L0COMPLETERID_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(4),
	GlitchData    => L0COMPLETERID4_GlitchData,
	OutSignalName => "L0COMPLETERID(4)",
	OutTemp       => L0COMPLETERID_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(5),
	GlitchData    => L0COMPLETERID5_GlitchData,
	OutSignalName => "L0COMPLETERID(5)",
	OutTemp       => L0COMPLETERID_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(5),
	GlitchData    => L0COMPLETERID5_GlitchData,
	OutSignalName => "L0COMPLETERID(5)",
	OutTemp       => L0COMPLETERID_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(6),
	GlitchData    => L0COMPLETERID6_GlitchData,
	OutSignalName => "L0COMPLETERID(6)",
	OutTemp       => L0COMPLETERID_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(6),
	GlitchData    => L0COMPLETERID6_GlitchData,
	OutSignalName => "L0COMPLETERID(6)",
	OutTemp       => L0COMPLETERID_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(7),
	GlitchData    => L0COMPLETERID7_GlitchData,
	OutSignalName => "L0COMPLETERID(7)",
	OutTemp       => L0COMPLETERID_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(7),
	GlitchData    => L0COMPLETERID7_GlitchData,
	OutSignalName => "L0COMPLETERID(7)",
	OutTemp       => L0COMPLETERID_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(8),
	GlitchData    => L0COMPLETERID8_GlitchData,
	OutSignalName => "L0COMPLETERID(8)",
	OutTemp       => L0COMPLETERID_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(8),
	GlitchData    => L0COMPLETERID8_GlitchData,
	OutSignalName => "L0COMPLETERID(8)",
	OutTemp       => L0COMPLETERID_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(9),
	GlitchData    => L0COMPLETERID9_GlitchData,
	OutSignalName => "L0COMPLETERID(9)",
	OutTemp       => L0COMPLETERID_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(9),
	GlitchData    => L0COMPLETERID9_GlitchData,
	OutSignalName => "L0COMPLETERID(9)",
	OutTemp       => L0COMPLETERID_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(10),
	GlitchData    => L0COMPLETERID10_GlitchData,
	OutSignalName => "L0COMPLETERID(10)",
	OutTemp       => L0COMPLETERID_OUT(10),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(10),
	GlitchData    => L0COMPLETERID10_GlitchData,
	OutSignalName => "L0COMPLETERID(10)",
	OutTemp       => L0COMPLETERID_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(11),
	GlitchData    => L0COMPLETERID11_GlitchData,
	OutSignalName => "L0COMPLETERID(11)",
	OutTemp       => L0COMPLETERID_OUT(11),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(11),
	GlitchData    => L0COMPLETERID11_GlitchData,
	OutSignalName => "L0COMPLETERID(11)",
	OutTemp       => L0COMPLETERID_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(12),
	GlitchData    => L0COMPLETERID12_GlitchData,
	OutSignalName => "L0COMPLETERID(12)",
	OutTemp       => L0COMPLETERID_OUT(12),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0COMPLETERID(12),
	GlitchData    => L0COMPLETERID12_GlitchData,
	OutSignalName => "L0COMPLETERID(12)",
	OutTemp       => L0COMPLETERID_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UNLOCKRECEIVED,
	GlitchData    => L0UNLOCKRECEIVED_GlitchData,
	OutSignalName => "L0UNLOCKRECEIVED",
	OutTemp       => L0UNLOCKRECEIVED_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UNLOCKRECEIVED,
	GlitchData    => L0UNLOCKRECEIVED_GlitchData,
	OutSignalName => "L0UNLOCKRECEIVED",
	OutTemp       => L0UNLOCKRECEIVED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0CORRERRMSGRCVD,
	GlitchData    => L0CORRERRMSGRCVD_GlitchData,
	OutSignalName => "L0CORRERRMSGRCVD",
	OutTemp       => L0CORRERRMSGRCVD_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0CORRERRMSGRCVD,
	GlitchData    => L0CORRERRMSGRCVD_GlitchData,
	OutSignalName => "L0CORRERRMSGRCVD",
	OutTemp       => L0CORRERRMSGRCVD_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FATALERRMSGRCVD,
	GlitchData    => L0FATALERRMSGRCVD_GlitchData,
	OutSignalName => "L0FATALERRMSGRCVD",
	OutTemp       => L0FATALERRMSGRCVD_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FATALERRMSGRCVD,
	GlitchData    => L0FATALERRMSGRCVD_GlitchData,
	OutSignalName => "L0FATALERRMSGRCVD",
	OutTemp       => L0FATALERRMSGRCVD_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0NONFATALERRMSGRCVD,
	GlitchData    => L0NONFATALERRMSGRCVD_GlitchData,
	OutSignalName => "L0NONFATALERRMSGRCVD",
	OutTemp       => L0NONFATALERRMSGRCVD_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0NONFATALERRMSGRCVD,
	GlitchData    => L0NONFATALERRMSGRCVD_GlitchData,
	OutSignalName => "L0NONFATALERRMSGRCVD",
	OutTemp       => L0NONFATALERRMSGRCVD_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(0),
	GlitchData    => L0ERRMSGREQID0_GlitchData,
	OutSignalName => "L0ERRMSGREQID(0)",
	OutTemp       => L0ERRMSGREQID_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(0),
	GlitchData    => L0ERRMSGREQID0_GlitchData,
	OutSignalName => "L0ERRMSGREQID(0)",
	OutTemp       => L0ERRMSGREQID_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(1),
	GlitchData    => L0ERRMSGREQID1_GlitchData,
	OutSignalName => "L0ERRMSGREQID(1)",
	OutTemp       => L0ERRMSGREQID_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(1),
	GlitchData    => L0ERRMSGREQID1_GlitchData,
	OutSignalName => "L0ERRMSGREQID(1)",
	OutTemp       => L0ERRMSGREQID_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(2),
	GlitchData    => L0ERRMSGREQID2_GlitchData,
	OutSignalName => "L0ERRMSGREQID(2)",
	OutTemp       => L0ERRMSGREQID_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(2),
	GlitchData    => L0ERRMSGREQID2_GlitchData,
	OutSignalName => "L0ERRMSGREQID(2)",
	OutTemp       => L0ERRMSGREQID_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(3),
	GlitchData    => L0ERRMSGREQID3_GlitchData,
	OutSignalName => "L0ERRMSGREQID(3)",
	OutTemp       => L0ERRMSGREQID_OUT(3),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(3),
	GlitchData    => L0ERRMSGREQID3_GlitchData,
	OutSignalName => "L0ERRMSGREQID(3)",
	OutTemp       => L0ERRMSGREQID_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(4),
	GlitchData    => L0ERRMSGREQID4_GlitchData,
	OutSignalName => "L0ERRMSGREQID(4)",
	OutTemp       => L0ERRMSGREQID_OUT(4),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(4),
	GlitchData    => L0ERRMSGREQID4_GlitchData,
	OutSignalName => "L0ERRMSGREQID(4)",
	OutTemp       => L0ERRMSGREQID_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(5),
	GlitchData    => L0ERRMSGREQID5_GlitchData,
	OutSignalName => "L0ERRMSGREQID(5)",
	OutTemp       => L0ERRMSGREQID_OUT(5),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(5),
	GlitchData    => L0ERRMSGREQID5_GlitchData,
	OutSignalName => "L0ERRMSGREQID(5)",
	OutTemp       => L0ERRMSGREQID_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(6),
	GlitchData    => L0ERRMSGREQID6_GlitchData,
	OutSignalName => "L0ERRMSGREQID(6)",
	OutTemp       => L0ERRMSGREQID_OUT(6),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(6),
	GlitchData    => L0ERRMSGREQID6_GlitchData,
	OutSignalName => "L0ERRMSGREQID(6)",
	OutTemp       => L0ERRMSGREQID_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(7),
	GlitchData    => L0ERRMSGREQID7_GlitchData,
	OutSignalName => "L0ERRMSGREQID(7)",
	OutTemp       => L0ERRMSGREQID_OUT(7),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(7),
	GlitchData    => L0ERRMSGREQID7_GlitchData,
	OutSignalName => "L0ERRMSGREQID(7)",
	OutTemp       => L0ERRMSGREQID_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(8),
	GlitchData    => L0ERRMSGREQID8_GlitchData,
	OutSignalName => "L0ERRMSGREQID(8)",
	OutTemp       => L0ERRMSGREQID_OUT(8),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(8),
	GlitchData    => L0ERRMSGREQID8_GlitchData,
	OutSignalName => "L0ERRMSGREQID(8)",
	OutTemp       => L0ERRMSGREQID_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(9),
	GlitchData    => L0ERRMSGREQID9_GlitchData,
	OutSignalName => "L0ERRMSGREQID(9)",
	OutTemp       => L0ERRMSGREQID_OUT(9),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(9),
	GlitchData    => L0ERRMSGREQID9_GlitchData,
	OutSignalName => "L0ERRMSGREQID(9)",
	OutTemp       => L0ERRMSGREQID_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(10),
	GlitchData    => L0ERRMSGREQID10_GlitchData,
	OutSignalName => "L0ERRMSGREQID(10)",
	OutTemp       => L0ERRMSGREQID_OUT(10),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(10),
	GlitchData    => L0ERRMSGREQID10_GlitchData,
	OutSignalName => "L0ERRMSGREQID(10)",
	OutTemp       => L0ERRMSGREQID_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(11),
	GlitchData    => L0ERRMSGREQID11_GlitchData,
	OutSignalName => "L0ERRMSGREQID(11)",
	OutTemp       => L0ERRMSGREQID_OUT(11),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(11),
	GlitchData    => L0ERRMSGREQID11_GlitchData,
	OutSignalName => "L0ERRMSGREQID(11)",
	OutTemp       => L0ERRMSGREQID_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(12),
	GlitchData    => L0ERRMSGREQID12_GlitchData,
	OutSignalName => "L0ERRMSGREQID(12)",
	OutTemp       => L0ERRMSGREQID_OUT(12),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(12),
	GlitchData    => L0ERRMSGREQID12_GlitchData,
	OutSignalName => "L0ERRMSGREQID(12)",
	OutTemp       => L0ERRMSGREQID_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(13),
	GlitchData    => L0ERRMSGREQID13_GlitchData,
	OutSignalName => "L0ERRMSGREQID(13)",
	OutTemp       => L0ERRMSGREQID_OUT(13),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(13),
	GlitchData    => L0ERRMSGREQID13_GlitchData,
	OutSignalName => "L0ERRMSGREQID(13)",
	OutTemp       => L0ERRMSGREQID_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(14),
	GlitchData    => L0ERRMSGREQID14_GlitchData,
	OutSignalName => "L0ERRMSGREQID(14)",
	OutTemp       => L0ERRMSGREQID_OUT(14),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(14),
	GlitchData    => L0ERRMSGREQID14_GlitchData,
	OutSignalName => "L0ERRMSGREQID(14)",
	OutTemp       => L0ERRMSGREQID_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(15),
	GlitchData    => L0ERRMSGREQID15_GlitchData,
	OutSignalName => "L0ERRMSGREQID(15)",
	OutTemp       => L0ERRMSGREQID_OUT(15),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ERRMSGREQID(15),
	GlitchData    => L0ERRMSGREQID15_GlitchData,
	OutSignalName => "L0ERRMSGREQID(15)",
	OutTemp       => L0ERRMSGREQID_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FWDCORRERROUT,
	GlitchData    => L0FWDCORRERROUT_GlitchData,
	OutSignalName => "L0FWDCORRERROUT",
	OutTemp       => L0FWDCORRERROUT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FWDCORRERROUT,
	GlitchData    => L0FWDCORRERROUT_GlitchData,
	OutSignalName => "L0FWDCORRERROUT",
	OutTemp       => L0FWDCORRERROUT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FWDFATALERROUT,
	GlitchData    => L0FWDFATALERROUT_GlitchData,
	OutSignalName => "L0FWDFATALERROUT",
	OutTemp       => L0FWDFATALERROUT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FWDFATALERROUT,
	GlitchData    => L0FWDFATALERROUT_GlitchData,
	OutSignalName => "L0FWDFATALERROUT",
	OutTemp       => L0FWDFATALERROUT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FWDNONFATALERROUT,
	GlitchData    => L0FWDNONFATALERROUT_GlitchData,
	OutSignalName => "L0FWDNONFATALERROUT",
	OutTemp       => L0FWDNONFATALERROUT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0FWDNONFATALERROUT,
	GlitchData    => L0FWDNONFATALERROUT_GlitchData,
	OutSignalName => "L0FWDNONFATALERROUT",
	OutTemp       => L0FWDNONFATALERROUT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTALEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTALEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTALEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTALEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTALEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTALEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTALEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTALEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTBLEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTBLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTBLEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTBLEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTBLEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTBLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTBLEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTBLEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTCLEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTCLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTCLEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTCLEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTCLEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTCLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTCLEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTCLEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTDLEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTDLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTDLEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTDLEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDASSERTINTDLEGACYINT,
	GlitchData    => L0RECEIVEDASSERTINTDLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDASSERTINTDLEGACYINT",
	OutTemp       => L0RECEIVEDASSERTINTDLEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTALEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTALEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTALEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTALEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTALEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTALEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTALEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTALEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTBLEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTBLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTBLEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTBLEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTBLEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTBLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTBLEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTBLEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTCLEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTCLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTCLEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTCLEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTCLEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTCLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTCLEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTCLEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTDLEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTDLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTDLEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTDLEGACYINT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RECEIVEDDEASSERTINTDLEGACYINT,
	GlitchData    => L0RECEIVEDDEASSERTINTDLEGACYINT_GlitchData,
	OutSignalName => "L0RECEIVEDDEASSERTINTDLEGACYINT",
	OutTemp       => L0RECEIVEDDEASSERTINTDLEGACYINT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MSIENABLE0,
	GlitchData    => L0MSIENABLE0_GlitchData,
	OutSignalName => "L0MSIENABLE0",
	OutTemp       => L0MSIENABLE0_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MSIENABLE0,
	GlitchData    => L0MSIENABLE0_GlitchData,
	OutSignalName => "L0MSIENABLE0",
	OutTemp       => L0MSIENABLE0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MULTIMSGEN0(0),
	GlitchData    => L0MULTIMSGEN00_GlitchData,
	OutSignalName => "L0MULTIMSGEN0(0)",
	OutTemp       => L0MULTIMSGEN0_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MULTIMSGEN0(0),
	GlitchData    => L0MULTIMSGEN00_GlitchData,
	OutSignalName => "L0MULTIMSGEN0(0)",
	OutTemp       => L0MULTIMSGEN0_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MULTIMSGEN0(1),
	GlitchData    => L0MULTIMSGEN01_GlitchData,
	OutSignalName => "L0MULTIMSGEN0(1)",
	OutTemp       => L0MULTIMSGEN0_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MULTIMSGEN0(1),
	GlitchData    => L0MULTIMSGEN01_GlitchData,
	OutSignalName => "L0MULTIMSGEN0(1)",
	OutTemp       => L0MULTIMSGEN0_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MULTIMSGEN0(2),
	GlitchData    => L0MULTIMSGEN02_GlitchData,
	OutSignalName => "L0MULTIMSGEN0(2)",
	OutTemp       => L0MULTIMSGEN0_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MULTIMSGEN0(2),
	GlitchData    => L0MULTIMSGEN02_GlitchData,
	OutSignalName => "L0MULTIMSGEN0(2)",
	OutTemp       => L0MULTIMSGEN0_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSDLLPRECEIVED,
	GlitchData    => L0STATSDLLPRECEIVED_GlitchData,
	OutSignalName => "L0STATSDLLPRECEIVED",
	OutTemp       => L0STATSDLLPRECEIVED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSDLLPTRANSMITTED,
	GlitchData    => L0STATSDLLPTRANSMITTED_GlitchData,
	OutSignalName => "L0STATSDLLPTRANSMITTED",
	OutTemp       => L0STATSDLLPTRANSMITTED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSOSRECEIVED,
	GlitchData    => L0STATSOSRECEIVED_GlitchData,
	OutSignalName => "L0STATSOSRECEIVED",
	OutTemp       => L0STATSOSRECEIVED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSOSTRANSMITTED,
	GlitchData    => L0STATSOSTRANSMITTED_GlitchData,
	OutSignalName => "L0STATSOSTRANSMITTED",
	OutTemp       => L0STATSOSTRANSMITTED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSTLPRECEIVED,
	GlitchData    => L0STATSTLPRECEIVED_GlitchData,
	OutSignalName => "L0STATSTLPRECEIVED",
	OutTemp       => L0STATSTLPRECEIVED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSTLPTRANSMITTED,
	GlitchData    => L0STATSTLPTRANSMITTED_GlitchData,
	OutSignalName => "L0STATSTLPTRANSMITTED",
	OutTemp       => L0STATSTLPTRANSMITTED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGRECEIVED,
	GlitchData    => L0STATSCFGRECEIVED_GlitchData,
	OutSignalName => "L0STATSCFGRECEIVED",
	OutTemp       => L0STATSCFGRECEIVED_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGRECEIVED,
	GlitchData    => L0STATSCFGRECEIVED_GlitchData,
	OutSignalName => "L0STATSCFGRECEIVED",
	OutTemp       => L0STATSCFGRECEIVED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGTRANSMITTED,
	GlitchData    => L0STATSCFGTRANSMITTED_GlitchData,
	OutSignalName => "L0STATSCFGTRANSMITTED",
	OutTemp       => L0STATSCFGTRANSMITTED_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGTRANSMITTED,
	GlitchData    => L0STATSCFGTRANSMITTED_GlitchData,
	OutSignalName => "L0STATSCFGTRANSMITTED",
	OutTemp       => L0STATSCFGTRANSMITTED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGOTHERRECEIVED,
	GlitchData    => L0STATSCFGOTHERRECEIVED_GlitchData,
	OutSignalName => "L0STATSCFGOTHERRECEIVED",
	OutTemp       => L0STATSCFGOTHERRECEIVED_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGOTHERRECEIVED,
	GlitchData    => L0STATSCFGOTHERRECEIVED_GlitchData,
	OutSignalName => "L0STATSCFGOTHERRECEIVED",
	OutTemp       => L0STATSCFGOTHERRECEIVED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGOTHERTRANSMITTED,
	GlitchData    => L0STATSCFGOTHERTRANSMITTED_GlitchData,
	OutSignalName => "L0STATSCFGOTHERTRANSMITTED",
	OutTemp       => L0STATSCFGOTHERTRANSMITTED_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0STATSCFGOTHERTRANSMITTED,
	GlitchData    => L0STATSCFGOTHERTRANSMITTED_GlitchData,
	OutSignalName => "L0STATSCFGOTHERTRANSMITTED",
	OutTemp       => L0STATSCFGOTHERTRANSMITTED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXPAYLOADSIZE(0),
	GlitchData    => MAXPAYLOADSIZE0_GlitchData,
	OutSignalName => "MAXPAYLOADSIZE(0)",
	OutTemp       => MAXPAYLOADSIZE_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXPAYLOADSIZE(0),
	GlitchData    => MAXPAYLOADSIZE0_GlitchData,
	OutSignalName => "MAXPAYLOADSIZE(0)",
	OutTemp       => MAXPAYLOADSIZE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXPAYLOADSIZE(1),
	GlitchData    => MAXPAYLOADSIZE1_GlitchData,
	OutSignalName => "MAXPAYLOADSIZE(1)",
	OutTemp       => MAXPAYLOADSIZE_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXPAYLOADSIZE(1),
	GlitchData    => MAXPAYLOADSIZE1_GlitchData,
	OutSignalName => "MAXPAYLOADSIZE(1)",
	OutTemp       => MAXPAYLOADSIZE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXPAYLOADSIZE(2),
	GlitchData    => MAXPAYLOADSIZE2_GlitchData,
	OutSignalName => "MAXPAYLOADSIZE(2)",
	OutTemp       => MAXPAYLOADSIZE_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXPAYLOADSIZE(2),
	GlitchData    => MAXPAYLOADSIZE2_GlitchData,
	OutSignalName => "MAXPAYLOADSIZE(2)",
	OutTemp       => MAXPAYLOADSIZE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXREADREQUESTSIZE(0),
	GlitchData    => MAXREADREQUESTSIZE0_GlitchData,
	OutSignalName => "MAXREADREQUESTSIZE(0)",
	OutTemp       => MAXREADREQUESTSIZE_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXREADREQUESTSIZE(0),
	GlitchData    => MAXREADREQUESTSIZE0_GlitchData,
	OutSignalName => "MAXREADREQUESTSIZE(0)",
	OutTemp       => MAXREADREQUESTSIZE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXREADREQUESTSIZE(1),
	GlitchData    => MAXREADREQUESTSIZE1_GlitchData,
	OutSignalName => "MAXREADREQUESTSIZE(1)",
	OutTemp       => MAXREADREQUESTSIZE_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXREADREQUESTSIZE(1),
	GlitchData    => MAXREADREQUESTSIZE1_GlitchData,
	OutSignalName => "MAXREADREQUESTSIZE(1)",
	OutTemp       => MAXREADREQUESTSIZE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXREADREQUESTSIZE(2),
	GlitchData    => MAXREADREQUESTSIZE2_GlitchData,
	OutSignalName => "MAXREADREQUESTSIZE(2)",
	OutTemp       => MAXREADREQUESTSIZE_OUT(2),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MAXREADREQUESTSIZE(2),
	GlitchData    => MAXREADREQUESTSIZE2_GlitchData,
	OutSignalName => "MAXREADREQUESTSIZE(2)",
	OutTemp       => MAXREADREQUESTSIZE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => IOSPACEENABLE,
	GlitchData    => IOSPACEENABLE_GlitchData,
	OutSignalName => "IOSPACEENABLE",
	OutTemp       => IOSPACEENABLE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => IOSPACEENABLE,
	GlitchData    => IOSPACEENABLE_GlitchData,
	OutSignalName => "IOSPACEENABLE",
	OutTemp       => IOSPACEENABLE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MEMSPACEENABLE,
	GlitchData    => MEMSPACEENABLE_GlitchData,
	OutSignalName => "MEMSPACEENABLE",
	OutTemp       => MEMSPACEENABLE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => MEMSPACEENABLE,
	GlitchData    => MEMSPACEENABLE_GlitchData,
	OutSignalName => "MEMSPACEENABLE",
	OutTemp       => MEMSPACEENABLE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ATTENTIONINDICATORCONTROL(0),
	GlitchData    => L0ATTENTIONINDICATORCONTROL0_GlitchData,
	OutSignalName => "L0ATTENTIONINDICATORCONTROL(0)",
	OutTemp       => L0ATTENTIONINDICATORCONTROL_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ATTENTIONINDICATORCONTROL(0),
	GlitchData    => L0ATTENTIONINDICATORCONTROL0_GlitchData,
	OutSignalName => "L0ATTENTIONINDICATORCONTROL(0)",
	OutTemp       => L0ATTENTIONINDICATORCONTROL_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ATTENTIONINDICATORCONTROL(1),
	GlitchData    => L0ATTENTIONINDICATORCONTROL1_GlitchData,
	OutSignalName => "L0ATTENTIONINDICATORCONTROL(1)",
	OutTemp       => L0ATTENTIONINDICATORCONTROL_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0ATTENTIONINDICATORCONTROL(1),
	GlitchData    => L0ATTENTIONINDICATORCONTROL1_GlitchData,
	OutSignalName => "L0ATTENTIONINDICATORCONTROL(1)",
	OutTemp       => L0ATTENTIONINDICATORCONTROL_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0POWERINDICATORCONTROL(0),
	GlitchData    => L0POWERINDICATORCONTROL0_GlitchData,
	OutSignalName => "L0POWERINDICATORCONTROL(0)",
	OutTemp       => L0POWERINDICATORCONTROL_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0POWERINDICATORCONTROL(0),
	GlitchData    => L0POWERINDICATORCONTROL0_GlitchData,
	OutSignalName => "L0POWERINDICATORCONTROL(0)",
	OutTemp       => L0POWERINDICATORCONTROL_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0POWERINDICATORCONTROL(1),
	GlitchData    => L0POWERINDICATORCONTROL1_GlitchData,
	OutSignalName => "L0POWERINDICATORCONTROL(1)",
	OutTemp       => L0POWERINDICATORCONTROL_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0POWERINDICATORCONTROL(1),
	GlitchData    => L0POWERINDICATORCONTROL1_GlitchData,
	OutSignalName => "L0POWERINDICATORCONTROL(1)",
	OutTemp       => L0POWERINDICATORCONTROL_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0POWERCONTROLLERCONTROL,
	GlitchData    => L0POWERCONTROLLERCONTROL_GlitchData,
	OutSignalName => "L0POWERCONTROLLERCONTROL",
	OutTemp       => L0POWERCONTROLLERCONTROL_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0POWERCONTROLLERCONTROL,
	GlitchData    => L0POWERCONTROLLERCONTROL_GlitchData,
	OutSignalName => "L0POWERCONTROLLERCONTROL",
	OutTemp       => L0POWERCONTROLLERCONTROL_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TOGGLEELECTROMECHANICALINTERLOCK,
	GlitchData    => L0TOGGLEELECTROMECHANICALINTERLOCK_GlitchData,
	OutSignalName => "L0TOGGLEELECTROMECHANICALINTERLOCK",
	OutTemp       => L0TOGGLEELECTROMECHANICALINTERLOCK_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TOGGLEELECTROMECHANICALINTERLOCK,
	GlitchData    => L0TOGGLEELECTROMECHANICALINTERLOCK_GlitchData,
	OutSignalName => "L0TOGGLEELECTROMECHANICALINTERLOCK",
	OutTemp       => L0TOGGLEELECTROMECHANICALINTERLOCK_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXBEACON,
	GlitchData    => L0RXBEACON_GlitchData,
	OutSignalName => "L0RXBEACON",
	OutTemp       => L0RXBEACON_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXBEACON,
	GlitchData    => L0RXBEACON_GlitchData,
	OutSignalName => "L0RXBEACON",
	OutTemp       => L0RXBEACON_OUT,
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXBEACON,
	GlitchData    => L0RXBEACON_GlitchData,
	OutSignalName => "L0RXBEACON",
	OutTemp       => L0RXBEACON_OUT,
	Paths         => (0 => (L0WAKEN_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRSTATE0(0),
	GlitchData    => L0PWRSTATE00_GlitchData,
	OutSignalName => "L0PWRSTATE0(0)",
	OutTemp       => L0PWRSTATE0_OUT(0),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRSTATE0(0),
	GlitchData    => L0PWRSTATE00_GlitchData,
	OutSignalName => "L0PWRSTATE0(0)",
	OutTemp       => L0PWRSTATE0_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRSTATE0(1),
	GlitchData    => L0PWRSTATE01_GlitchData,
	OutSignalName => "L0PWRSTATE0(1)",
	OutTemp       => L0PWRSTATE0_OUT(1),
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRSTATE0(1),
	GlitchData    => L0PWRSTATE01_GlitchData,
	OutSignalName => "L0PWRSTATE0(1)",
	OutTemp       => L0PWRSTATE0_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEACK,
	GlitchData    => L0PMEACK_GlitchData,
	OutSignalName => "L0PMEACK",
	OutTemp       => L0PMEACK_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEACK,
	GlitchData    => L0PMEACK_GlitchData,
	OutSignalName => "L0PMEACK",
	OutTemp       => L0PMEACK_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEREQOUT,
	GlitchData    => L0PMEREQOUT_GlitchData,
	OutSignalName => "L0PMEREQOUT",
	OutTemp       => L0PMEREQOUT_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEREQOUT,
	GlitchData    => L0PMEREQOUT_GlitchData,
	OutSignalName => "L0PMEREQOUT",
	OutTemp       => L0PMEREQOUT_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEREQOUT,
	GlitchData    => L0PMEREQOUT_GlitchData,
	OutSignalName => "L0PMEREQOUT",
	OutTemp       => L0PMEREQOUT_OUT,
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEEN,
	GlitchData    => L0PMEEN_GlitchData,
	OutSignalName => "L0PMEEN",
	OutTemp       => L0PMEEN_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEEN,
	GlitchData    => L0PMEEN_GlitchData,
	OutSignalName => "L0PMEEN",
	OutTemp       => L0PMEEN_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PMEEN,
	GlitchData    => L0PMEEN_GlitchData,
	OutSignalName => "L0PMEEN",
	OutTemp       => L0PMEEN_OUT,
	Paths         => (0 => (MAINPOWER_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRINHIBITTRANSFERS,
	GlitchData    => L0PWRINHIBITTRANSFERS_GlitchData,
	OutSignalName => "L0PWRINHIBITTRANSFERS",
	OutTemp       => L0PWRINHIBITTRANSFERS_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRL1STATE,
	GlitchData    => L0PWRL1STATE_GlitchData,
	OutSignalName => "L0PWRL1STATE",
	OutTemp       => L0PWRL1STATE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRL1STATE,
	GlitchData    => L0PWRL1STATE_GlitchData,
	OutSignalName => "L0PWRL1STATE",
	OutTemp       => L0PWRL1STATE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRL23READYDEVICE,
	GlitchData    => L0PWRL23READYDEVICE_GlitchData,
	OutSignalName => "L0PWRL23READYDEVICE",
	OutTemp       => L0PWRL23READYDEVICE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRL23READYDEVICE,
	GlitchData    => L0PWRL23READYDEVICE_GlitchData,
	OutSignalName => "L0PWRL23READYDEVICE",
	OutTemp       => L0PWRL23READYDEVICE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRL23READYSTATE,
	GlitchData    => L0PWRL23READYSTATE_GlitchData,
	OutSignalName => "L0PWRL23READYSTATE",
	OutTemp       => L0PWRL23READYSTATE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRL23READYSTATE,
	GlitchData    => L0PWRL23READYSTATE_GlitchData,
	OutSignalName => "L0PWRL23READYSTATE",
	OutTemp       => L0PWRL23READYSTATE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRTXL0SSTATE,
	GlitchData    => L0PWRTXL0SSTATE_GlitchData,
	OutSignalName => "L0PWRTXL0SSTATE",
	OutTemp       => L0PWRTXL0SSTATE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRTXL0SSTATE,
	GlitchData    => L0PWRTXL0SSTATE_GlitchData,
	OutSignalName => "L0PWRTXL0SSTATE",
	OutTemp       => L0PWRTXL0SSTATE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRTURNOFFREQ,
	GlitchData    => L0PWRTURNOFFREQ_GlitchData,
	OutSignalName => "L0PWRTURNOFFREQ",
	OutTemp       => L0PWRTURNOFFREQ_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0PWRTURNOFFREQ,
	GlitchData    => L0PWRTURNOFFREQ_GlitchData,
	OutSignalName => "L0PWRTURNOFFREQ",
	OutTemp       => L0PWRTURNOFFREQ_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLPM,
	GlitchData    => L0RXDLLPM_GlitchData,
	OutSignalName => "L0RXDLLPM",
	OutTemp       => L0RXDLLPM_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLPMTYPE(0),
	GlitchData    => L0RXDLLPMTYPE0_GlitchData,
	OutSignalName => "L0RXDLLPMTYPE(0)",
	OutTemp       => L0RXDLLPMTYPE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLPMTYPE(1),
	GlitchData    => L0RXDLLPMTYPE1_GlitchData,
	OutSignalName => "L0RXDLLPMTYPE(1)",
	OutTemp       => L0RXDLLPMTYPE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLPMTYPE(2),
	GlitchData    => L0RXDLLPMTYPE2_GlitchData,
	OutSignalName => "L0RXDLLPMTYPE(2)",
	OutTemp       => L0RXDLLPMTYPE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLPMUPDATED,
	GlitchData    => L0TXDLLPMUPDATED_GlitchData,
	OutSignalName => "L0TXDLLPMUPDATED",
	OutTemp       => L0TXDLLPMUPDATED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACNEWSTATEACK,
	GlitchData    => L0MACNEWSTATEACK_GlitchData,
	OutSignalName => "L0MACNEWSTATEACK",
	OutTemp       => L0MACNEWSTATEACK_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACRXL0SSTATE,
	GlitchData    => L0MACRXL0SSTATE_GlitchData,
	OutSignalName => "L0MACRXL0SSTATE",
	OutTemp       => L0MACRXL0SSTATE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MACENTEREDL0,
	GlitchData    => L0MACENTEREDL0_GlitchData,
	OutSignalName => "L0MACENTEREDL0",
	OutTemp       => L0MACENTEREDL0_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLRXACKOUTSTANDING,
	GlitchData    => L0DLLRXACKOUTSTANDING_GlitchData,
	OutSignalName => "L0DLLRXACKOUTSTANDING",
	OutTemp       => L0DLLRXACKOUTSTANDING_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLTXOUTSTANDING,
	GlitchData    => L0DLLTXOUTSTANDING_GlitchData,
	OutSignalName => "L0DLLTXOUTSTANDING",
	OutTemp       => L0DLLTXOUTSTANDING_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0DLLTXNONFCOUTSTANDING,
	GlitchData    => L0DLLTXNONFCOUTSTANDING_GlitchData,
	OutSignalName => "L0DLLTXNONFCOUTSTANDING",
	OutTemp       => L0DLLTXNONFCOUTSTANDING_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLTLPEND(0),
	GlitchData    => L0RXDLLTLPEND0_GlitchData,
	OutSignalName => "L0RXDLLTLPEND(0)",
	OutTemp       => L0RXDLLTLPEND_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLTLPEND(1),
	GlitchData    => L0RXDLLTLPEND1_GlitchData,
	OutSignalName => "L0RXDLLTLPEND(1)",
	OutTemp       => L0RXDLLTLPEND_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLSBFCUPDATED,
	GlitchData    => L0TXDLLSBFCUPDATED_GlitchData,
	OutSignalName => "L0TXDLLSBFCUPDATED",
	OutTemp       => L0TXDLLSBFCUPDATED_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(0),
	GlitchData    => L0RXDLLSBFCDATA0_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(0)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(1),
	GlitchData    => L0RXDLLSBFCDATA1_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(1)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(2),
	GlitchData    => L0RXDLLSBFCDATA2_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(2)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(3),
	GlitchData    => L0RXDLLSBFCDATA3_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(3)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(4),
	GlitchData    => L0RXDLLSBFCDATA4_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(4)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(5),
	GlitchData    => L0RXDLLSBFCDATA5_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(5)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(6),
	GlitchData    => L0RXDLLSBFCDATA6_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(6)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(7),
	GlitchData    => L0RXDLLSBFCDATA7_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(7)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(8),
	GlitchData    => L0RXDLLSBFCDATA8_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(8)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(9),
	GlitchData    => L0RXDLLSBFCDATA9_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(9)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(10),
	GlitchData    => L0RXDLLSBFCDATA10_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(10)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(11),
	GlitchData    => L0RXDLLSBFCDATA11_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(11)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(12),
	GlitchData    => L0RXDLLSBFCDATA12_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(12)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(13),
	GlitchData    => L0RXDLLSBFCDATA13_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(13)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(14),
	GlitchData    => L0RXDLLSBFCDATA14_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(14)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(15),
	GlitchData    => L0RXDLLSBFCDATA15_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(15)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(16),
	GlitchData    => L0RXDLLSBFCDATA16_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(16)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(16),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(17),
	GlitchData    => L0RXDLLSBFCDATA17_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(17)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(17),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCDATA(18),
	GlitchData    => L0RXDLLSBFCDATA18_GlitchData,
	OutSignalName => "L0RXDLLSBFCDATA(18)",
	OutTemp       => L0RXDLLSBFCDATA_OUT(18),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLSBFCUPDATE,
	GlitchData    => L0RXDLLSBFCUPDATE_GlitchData,
	OutSignalName => "L0RXDLLSBFCUPDATE",
	OutTemp       => L0RXDLLSBFCUPDATE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(0),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED0_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(0)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(1),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED1_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(1)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(2),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED2_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(2)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(3),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED3_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(3)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(4),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED4_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(4)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(5),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED5_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(5)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(6),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED6_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(6)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCNPOSTBYPUPDATED(7),
	GlitchData    => L0TXDLLFCNPOSTBYPUPDATED7_GlitchData,
	OutSignalName => "L0TXDLLFCNPOSTBYPUPDATED(7)",
	OutTemp       => L0TXDLLFCNPOSTBYPUPDATED_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(0),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED0_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(0)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(1),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED1_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(1)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(2),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED2_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(2)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(3),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED3_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(3)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(4),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED4_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(4)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(5),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED5_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(5)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(6),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED6_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(6)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCPOSTORDUPDATED(7),
	GlitchData    => L0TXDLLFCPOSTORDUPDATED7_GlitchData,
	OutSignalName => "L0TXDLLFCPOSTORDUPDATED(7)",
	OutTemp       => L0TXDLLFCPOSTORDUPDATED_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(0),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED0_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(0)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(1),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED1_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(1)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(2),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED2_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(2)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(3),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED3_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(3)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(4),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED4_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(4)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(5),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED5_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(5)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(6),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED6_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(6)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TXDLLFCCMPLMCUPDATED(7),
	GlitchData    => L0TXDLLFCCMPLMCUPDATED7_GlitchData,
	OutSignalName => "L0TXDLLFCCMPLMCUPDATED(7)",
	OutTemp       => L0TXDLLFCCMPLMCUPDATED_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(0),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED0_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(0)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(1),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED1_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(1)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(2),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED2_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(2)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(3),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED3_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(3)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(4),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED4_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(4)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(5),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED5_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(5)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(6),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED6_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(6)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(7),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED7_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(7)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(8),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED8_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(8)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(9),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED9_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(9)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(10),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED10_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(10)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(11),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED11_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(11)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(12),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED12_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(12)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(13),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED13_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(13)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(14),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED14_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(14)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(15),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED15_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(15)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(16),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED16_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(16)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(16),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(17),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED17_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(17)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(17),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(18),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED18_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(18)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(18),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPCRED(19),
	GlitchData    => L0RXDLLFCNPOSTBYPCRED19_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPCRED(19)",
	OutTemp       => L0RXDLLFCNPOSTBYPCRED_OUT(19),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(0),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE0_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(0)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(1),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE1_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(1)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(2),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE2_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(2)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(3),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE3_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(3)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(4),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE4_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(4)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(5),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE5_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(5)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(6),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE6_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(6)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCNPOSTBYPUPDATE(7),
	GlitchData    => L0RXDLLFCNPOSTBYPUPDATE7_GlitchData,
	OutSignalName => "L0RXDLLFCNPOSTBYPUPDATE(7)",
	OutTemp       => L0RXDLLFCNPOSTBYPUPDATE_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(0),
	GlitchData    => L0RXDLLFCPOSTORDCRED0_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(0)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(1),
	GlitchData    => L0RXDLLFCPOSTORDCRED1_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(1)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(2),
	GlitchData    => L0RXDLLFCPOSTORDCRED2_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(2)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(3),
	GlitchData    => L0RXDLLFCPOSTORDCRED3_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(3)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(4),
	GlitchData    => L0RXDLLFCPOSTORDCRED4_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(4)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(5),
	GlitchData    => L0RXDLLFCPOSTORDCRED5_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(5)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(6),
	GlitchData    => L0RXDLLFCPOSTORDCRED6_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(6)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(7),
	GlitchData    => L0RXDLLFCPOSTORDCRED7_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(7)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(8),
	GlitchData    => L0RXDLLFCPOSTORDCRED8_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(8)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(9),
	GlitchData    => L0RXDLLFCPOSTORDCRED9_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(9)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(10),
	GlitchData    => L0RXDLLFCPOSTORDCRED10_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(10)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(11),
	GlitchData    => L0RXDLLFCPOSTORDCRED11_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(11)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(12),
	GlitchData    => L0RXDLLFCPOSTORDCRED12_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(12)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(13),
	GlitchData    => L0RXDLLFCPOSTORDCRED13_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(13)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(14),
	GlitchData    => L0RXDLLFCPOSTORDCRED14_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(14)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(15),
	GlitchData    => L0RXDLLFCPOSTORDCRED15_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(15)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(16),
	GlitchData    => L0RXDLLFCPOSTORDCRED16_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(16)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(16),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(17),
	GlitchData    => L0RXDLLFCPOSTORDCRED17_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(17)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(17),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(18),
	GlitchData    => L0RXDLLFCPOSTORDCRED18_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(18)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(18),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(19),
	GlitchData    => L0RXDLLFCPOSTORDCRED19_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(19)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(19),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(20),
	GlitchData    => L0RXDLLFCPOSTORDCRED20_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(20)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(20),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(21),
	GlitchData    => L0RXDLLFCPOSTORDCRED21_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(21)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(21),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(22),
	GlitchData    => L0RXDLLFCPOSTORDCRED22_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(22)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(22),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDCRED(23),
	GlitchData    => L0RXDLLFCPOSTORDCRED23_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDCRED(23)",
	OutTemp       => L0RXDLLFCPOSTORDCRED_OUT(23),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(0),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE0_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(0)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(1),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE1_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(1)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(2),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE2_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(2)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(3),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE3_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(3)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(4),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE4_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(4)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(5),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE5_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(5)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(6),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE6_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(6)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCPOSTORDUPDATE(7),
	GlitchData    => L0RXDLLFCPOSTORDUPDATE7_GlitchData,
	OutSignalName => "L0RXDLLFCPOSTORDUPDATE(7)",
	OutTemp       => L0RXDLLFCPOSTORDUPDATE_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(0),
	GlitchData    => L0RXDLLFCCMPLMCCRED0_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(0)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(1),
	GlitchData    => L0RXDLLFCCMPLMCCRED1_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(1)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(2),
	GlitchData    => L0RXDLLFCCMPLMCCRED2_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(2)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(3),
	GlitchData    => L0RXDLLFCCMPLMCCRED3_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(3)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(4),
	GlitchData    => L0RXDLLFCCMPLMCCRED4_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(4)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(5),
	GlitchData    => L0RXDLLFCCMPLMCCRED5_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(5)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(6),
	GlitchData    => L0RXDLLFCCMPLMCCRED6_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(6)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(7),
	GlitchData    => L0RXDLLFCCMPLMCCRED7_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(7)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(8),
	GlitchData    => L0RXDLLFCCMPLMCCRED8_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(8)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(8),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(9),
	GlitchData    => L0RXDLLFCCMPLMCCRED9_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(9)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(9),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(10),
	GlitchData    => L0RXDLLFCCMPLMCCRED10_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(10)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(10),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(11),
	GlitchData    => L0RXDLLFCCMPLMCCRED11_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(11)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(11),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(12),
	GlitchData    => L0RXDLLFCCMPLMCCRED12_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(12)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(12),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(13),
	GlitchData    => L0RXDLLFCCMPLMCCRED13_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(13)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(13),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(14),
	GlitchData    => L0RXDLLFCCMPLMCCRED14_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(14)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(14),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(15),
	GlitchData    => L0RXDLLFCCMPLMCCRED15_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(15)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(15),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(16),
	GlitchData    => L0RXDLLFCCMPLMCCRED16_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(16)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(16),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(17),
	GlitchData    => L0RXDLLFCCMPLMCCRED17_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(17)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(17),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(18),
	GlitchData    => L0RXDLLFCCMPLMCCRED18_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(18)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(18),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(19),
	GlitchData    => L0RXDLLFCCMPLMCCRED19_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(19)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(19),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(20),
	GlitchData    => L0RXDLLFCCMPLMCCRED20_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(20)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(20),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(21),
	GlitchData    => L0RXDLLFCCMPLMCCRED21_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(21)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(21),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(22),
	GlitchData    => L0RXDLLFCCMPLMCCRED22_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(22)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(22),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCCRED(23),
	GlitchData    => L0RXDLLFCCMPLMCCRED23_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCCRED(23)",
	OutTemp       => L0RXDLLFCCMPLMCCRED_OUT(23),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(0),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE0_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(0)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(1),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE1_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(1)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(2),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE2_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(2)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(3),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE3_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(3)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(4),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE4_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(4)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(4),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(5),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE5_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(5)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(5),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(6),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE6_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(6)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(6),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0RXDLLFCCMPLMCUPDATE(7),
	GlitchData    => L0RXDLLFCCMPLMCUPDATE7_GlitchData,
	OutSignalName => "L0RXDLLFCCMPLMCUPDATE(7)",
	OutTemp       => L0RXDLLFCCMPLMCUPDATE_OUT(7),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCBYPFOUND(0),
	GlitchData    => L0UCBYPFOUND0_GlitchData,
	OutSignalName => "L0UCBYPFOUND(0)",
	OutTemp       => L0UCBYPFOUND_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCBYPFOUND(1),
	GlitchData    => L0UCBYPFOUND1_GlitchData,
	OutSignalName => "L0UCBYPFOUND(1)",
	OutTemp       => L0UCBYPFOUND_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCBYPFOUND(2),
	GlitchData    => L0UCBYPFOUND2_GlitchData,
	OutSignalName => "L0UCBYPFOUND(2)",
	OutTemp       => L0UCBYPFOUND_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCBYPFOUND(3),
	GlitchData    => L0UCBYPFOUND3_GlitchData,
	OutSignalName => "L0UCBYPFOUND(3)",
	OutTemp       => L0UCBYPFOUND_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCORDFOUND(0),
	GlitchData    => L0UCORDFOUND0_GlitchData,
	OutSignalName => "L0UCORDFOUND(0)",
	OutTemp       => L0UCORDFOUND_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCORDFOUND(1),
	GlitchData    => L0UCORDFOUND1_GlitchData,
	OutSignalName => "L0UCORDFOUND(1)",
	OutTemp       => L0UCORDFOUND_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCORDFOUND(2),
	GlitchData    => L0UCORDFOUND2_GlitchData,
	OutSignalName => "L0UCORDFOUND(2)",
	OutTemp       => L0UCORDFOUND_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0UCORDFOUND(3),
	GlitchData    => L0UCORDFOUND3_GlitchData,
	OutSignalName => "L0UCORDFOUND(3)",
	OutTemp       => L0UCORDFOUND_OUT(3),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MCFOUND(0),
	GlitchData    => L0MCFOUND0_GlitchData,
	OutSignalName => "L0MCFOUND(0)",
	OutTemp       => L0MCFOUND_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MCFOUND(1),
	GlitchData    => L0MCFOUND1_GlitchData,
	OutSignalName => "L0MCFOUND(1)",
	OutTemp       => L0MCFOUND_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0MCFOUND(2),
	GlitchData    => L0MCFOUND2_GlitchData,
	OutSignalName => "L0MCFOUND(2)",
	OutTemp       => L0MCFOUND_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TRANSFORMEDVC(0),
	GlitchData    => L0TRANSFORMEDVC0_GlitchData,
	OutSignalName => "L0TRANSFORMEDVC(0)",
	OutTemp       => L0TRANSFORMEDVC_OUT(0),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TRANSFORMEDVC(1),
	GlitchData    => L0TRANSFORMEDVC1_GlitchData,
	OutSignalName => "L0TRANSFORMEDVC(1)",
	OutTemp       => L0TRANSFORMEDVC_OUT(1),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => L0TRANSFORMEDVC(2),
	GlitchData    => L0TRANSFORMEDVC2_GlitchData,
	OutSignalName => "L0TRANSFORMEDVC(2)",
	OutTemp       => L0TRANSFORMEDVC_OUT(2),
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => BUSMASTERENABLE,
	GlitchData    => BUSMASTERENABLE_GlitchData,
	OutSignalName => "BUSMASTERENABLE",
	OutTemp       => BUSMASTERENABLE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => BUSMASTERENABLE,
	GlitchData    => BUSMASTERENABLE_GlitchData,
	OutSignalName => "BUSMASTERENABLE",
	OutTemp       => BUSMASTERENABLE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PARITYERRORRESPONSE,
	GlitchData    => PARITYERRORRESPONSE_GlitchData,
	OutSignalName => "PARITYERRORRESPONSE",
	OutTemp       => PARITYERRORRESPONSE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => PARITYERRORRESPONSE,
	GlitchData    => PARITYERRORRESPONSE_GlitchData,
	OutSignalName => "PARITYERRORRESPONSE",
	OutTemp       => PARITYERRORRESPONSE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => SERRENABLE,
	GlitchData    => SERRENABLE_GlitchData,
	OutSignalName => "SERRENABLE",
	OutTemp       => SERRENABLE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => SERRENABLE,
	GlitchData    => SERRENABLE_GlitchData,
	OutSignalName => "SERRENABLE",
	OutTemp       => SERRENABLE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => INTERRUPTDISABLE,
	GlitchData    => INTERRUPTDISABLE_GlitchData,
	OutSignalName => "INTERRUPTDISABLE",
	OutTemp       => INTERRUPTDISABLE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => INTERRUPTDISABLE,
	GlitchData    => INTERRUPTDISABLE_GlitchData,
	OutSignalName => "INTERRUPTDISABLE",
	OutTemp       => INTERRUPTDISABLE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => URREPORTINGENABLE,
	GlitchData    => URREPORTINGENABLE_GlitchData,
	OutSignalName => "URREPORTINGENABLE",
	OutTemp       => URREPORTINGENABLE_OUT,
	Paths         => (0 => (CRMUSERCLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);
	VitalPathDelay01
	(
	OutSignal     => URREPORTINGENABLE,
	GlitchData    => URREPORTINGENABLE_GlitchData,
	OutSignalName => "URREPORTINGENABLE",
	OutTemp       => URREPORTINGENABLE_OUT,
	Paths         => (0 => (CRMCORECLK_ipd'last_event, PATH_DELAY,TRUE)),
	Mode          => VitalTransport,
	Xon           => false,
	MsgOn         => false,
	MsgSeverity   => WARNING
	);

   wait on
	BUSMASTERENABLE_out,
	CRMDOHOTRESETN_out,
	CRMPWRSOFTRESETN_out,
	CRMRXHOTRESETN_out,
	DLLTXPMDLLPOUTSTANDING_out,
	INTERRUPTDISABLE_out,
	IOSPACEENABLE_out,
	L0ASAUTONOMOUSINITCOMPLETED_out,
	L0ATTENTIONINDICATORCONTROL_out,
	L0CFGLOOPBACKACK_out,
	L0COMPLETERID_out,
	L0CORRERRMSGRCVD_out,
	L0DLLASRXSTATE_out,
	L0DLLASTXSTATE_out,
	L0DLLERRORVECTOR_out,
	L0DLLRXACKOUTSTANDING_out,
	L0DLLTXNONFCOUTSTANDING_out,
	L0DLLTXOUTSTANDING_out,
	L0DLLVCSTATUS_out,
	L0DLUPDOWN_out,
	L0ERRMSGREQID_out,
	L0FATALERRMSGRCVD_out,
	L0FIRSTCFGWRITEOCCURRED_out,
	L0FWDCORRERROUT_out,
	L0FWDFATALERROUT_out,
	L0FWDNONFATALERROUT_out,
	L0LTSSMSTATE_out,
	L0MACENTEREDL0_out,
	L0MACLINKTRAINING_out,
	L0MACLINKUP_out,
	L0MACNEGOTIATEDLINKWIDTH_out,
	L0MACNEWSTATEACK_out,
	L0MACRXL0SSTATE_out,
	L0MACUPSTREAMDOWNSTREAM_out,
	L0MCFOUND_out,
	L0MSIENABLE0_out,
	L0MULTIMSGEN0_out,
	L0NONFATALERRMSGRCVD_out,
	L0PMEACK_out,
	L0PMEEN_out,
	L0PMEREQOUT_out,
	L0POWERCONTROLLERCONTROL_out,
	L0POWERINDICATORCONTROL_out,
	L0PWRINHIBITTRANSFERS_out,
	L0PWRL1STATE_out,
	L0PWRL23READYDEVICE_out,
	L0PWRL23READYSTATE_out,
	L0PWRSTATE0_out,
	L0PWRTURNOFFREQ_out,
	L0PWRTXL0SSTATE_out,
	L0RECEIVEDASSERTINTALEGACYINT_out,
	L0RECEIVEDASSERTINTBLEGACYINT_out,
	L0RECEIVEDASSERTINTCLEGACYINT_out,
	L0RECEIVEDASSERTINTDLEGACYINT_out,
	L0RECEIVEDDEASSERTINTALEGACYINT_out,
	L0RECEIVEDDEASSERTINTBLEGACYINT_out,
	L0RECEIVEDDEASSERTINTCLEGACYINT_out,
	L0RECEIVEDDEASSERTINTDLEGACYINT_out,
	L0RXBEACON_out,
	L0RXDLLFCCMPLMCCRED_out,
	L0RXDLLFCCMPLMCUPDATE_out,
	L0RXDLLFCNPOSTBYPCRED_out,
	L0RXDLLFCNPOSTBYPUPDATE_out,
	L0RXDLLFCPOSTORDCRED_out,
	L0RXDLLFCPOSTORDUPDATE_out,
	L0RXDLLPMTYPE_out,
	L0RXDLLPM_out,
	L0RXDLLSBFCDATA_out,
	L0RXDLLSBFCUPDATE_out,
	L0RXDLLTLPECRCOK_out,
	L0RXDLLTLPEND_out,
	L0RXMACLINKERROR_out,
	L0STATSCFGOTHERRECEIVED_out,
	L0STATSCFGOTHERTRANSMITTED_out,
	L0STATSCFGRECEIVED_out,
	L0STATSCFGTRANSMITTED_out,
	L0STATSDLLPRECEIVED_out,
	L0STATSDLLPTRANSMITTED_out,
	L0STATSOSRECEIVED_out,
	L0STATSOSTRANSMITTED_out,
	L0STATSTLPRECEIVED_out,
	L0STATSTLPTRANSMITTED_out,
	L0TOGGLEELECTROMECHANICALINTERLOCK_out,
	L0TRANSFORMEDVC_out,
	L0TXDLLFCCMPLMCUPDATED_out,
	L0TXDLLFCNPOSTBYPUPDATED_out,
	L0TXDLLFCPOSTORDUPDATED_out,
	L0TXDLLPMUPDATED_out,
	L0TXDLLSBFCUPDATED_out,
	L0UCBYPFOUND_out,
	L0UCORDFOUND_out,
	L0UNLOCKRECEIVED_out,
	LLKRX4DWHEADERN_out,
	LLKRXCHCOMPLETIONAVAILABLEN_out,
	LLKRXCHCOMPLETIONPARTIALN_out,
	LLKRXCHCONFIGAVAILABLEN_out,
	LLKRXCHCONFIGPARTIALN_out,
	LLKRXCHNONPOSTEDAVAILABLEN_out,
	LLKRXCHNONPOSTEDPARTIALN_out,
	LLKRXCHPOSTEDAVAILABLEN_out,
	LLKRXCHPOSTEDPARTIALN_out,
	LLKRXDATA_out,
	LLKRXECRCBADN_out,
	LLKRXEOFN_out,
	LLKRXEOPN_out,
	LLKRXPREFERREDTYPE_out,
	LLKRXSOFN_out,
	LLKRXSOPN_out,
	LLKRXSRCDSCN_out,
	LLKRXSRCLASTREQN_out,
	LLKRXSRCRDYN_out,
	LLKRXVALIDN_out,
	LLKTCSTATUS_out,
	LLKTXCHANSPACE_out,
	LLKTXCHCOMPLETIONREADYN_out,
	LLKTXCHNONPOSTEDREADYN_out,
	LLKTXCHPOSTEDREADYN_out,
	LLKTXCONFIGREADYN_out,
	LLKTXDSTRDYN_out,
	MAXPAYLOADSIZE_out,
	MAXREADREQUESTSIZE_out,
	MEMSPACEENABLE_out,
	MGMTPSO_out,
	MGMTRDATA_out,
	MGMTSTATSCREDIT_out,
	MIMDLLBRADD_out,
	MIMDLLBREN_out,
	MIMDLLBWADD_out,
	MIMDLLBWDATA_out,
	MIMDLLBWEN_out,
	MIMRXBRADD_out,
	MIMRXBREN_out,
	MIMRXBWADD_out,
	MIMRXBWDATA_out,
	MIMRXBWEN_out,
	MIMTXBRADD_out,
	MIMTXBREN_out,
	MIMTXBWADD_out,
	MIMTXBWDATA_out,
	MIMTXBWEN_out,
	PARITYERRORRESPONSE_out,
	PIPEDESKEWLANESL0_out,
	PIPEDESKEWLANESL1_out,
	PIPEDESKEWLANESL2_out,
	PIPEDESKEWLANESL3_out,
	PIPEDESKEWLANESL4_out,
	PIPEDESKEWLANESL5_out,
	PIPEDESKEWLANESL6_out,
	PIPEDESKEWLANESL7_out,
	PIPEPOWERDOWNL0_out,
	PIPEPOWERDOWNL1_out,
	PIPEPOWERDOWNL2_out,
	PIPEPOWERDOWNL3_out,
	PIPEPOWERDOWNL4_out,
	PIPEPOWERDOWNL5_out,
	PIPEPOWERDOWNL6_out,
	PIPEPOWERDOWNL7_out,
	PIPERESETL0_out,
	PIPERESETL1_out,
	PIPERESETL2_out,
	PIPERESETL3_out,
	PIPERESETL4_out,
	PIPERESETL5_out,
	PIPERESETL6_out,
	PIPERESETL7_out,
	PIPERXPOLARITYL0_out,
	PIPERXPOLARITYL1_out,
	PIPERXPOLARITYL2_out,
	PIPERXPOLARITYL3_out,
	PIPERXPOLARITYL4_out,
	PIPERXPOLARITYL5_out,
	PIPERXPOLARITYL6_out,
	PIPERXPOLARITYL7_out,
	PIPETXCOMPLIANCEL0_out,
	PIPETXCOMPLIANCEL1_out,
	PIPETXCOMPLIANCEL2_out,
	PIPETXCOMPLIANCEL3_out,
	PIPETXCOMPLIANCEL4_out,
	PIPETXCOMPLIANCEL5_out,
	PIPETXCOMPLIANCEL6_out,
	PIPETXCOMPLIANCEL7_out,
	PIPETXDATAKL0_out,
	PIPETXDATAKL1_out,
	PIPETXDATAKL2_out,
	PIPETXDATAKL3_out,
	PIPETXDATAKL4_out,
	PIPETXDATAKL5_out,
	PIPETXDATAKL6_out,
	PIPETXDATAKL7_out,
	PIPETXDATAL0_out,
	PIPETXDATAL1_out,
	PIPETXDATAL2_out,
	PIPETXDATAL3_out,
	PIPETXDATAL4_out,
	PIPETXDATAL5_out,
	PIPETXDATAL6_out,
	PIPETXDATAL7_out,
	PIPETXDETECTRXLOOPBACKL0_out,
	PIPETXDETECTRXLOOPBACKL1_out,
	PIPETXDETECTRXLOOPBACKL2_out,
	PIPETXDETECTRXLOOPBACKL3_out,
	PIPETXDETECTRXLOOPBACKL4_out,
	PIPETXDETECTRXLOOPBACKL5_out,
	PIPETXDETECTRXLOOPBACKL6_out,
	PIPETXDETECTRXLOOPBACKL7_out,
	PIPETXELECIDLEL0_out,
	PIPETXELECIDLEL1_out,
	PIPETXELECIDLEL2_out,
	PIPETXELECIDLEL3_out,
	PIPETXELECIDLEL4_out,
	PIPETXELECIDLEL5_out,
	PIPETXELECIDLEL6_out,
	PIPETXELECIDLEL7_out,
	SERRENABLE_out,
	URREPORTINGENABLE_out,

	AUXPOWER_ipd,
	CFGNEGOTIATEDLINKWIDTH_ipd,
	COMPLIANCEAVOID_ipd,
	CRMCFGBRIDGEHOTRESET_ipd,
	CRMCORECLKDLO_ipd,
	CRMCORECLKRXO_ipd,
	CRMCORECLKTXO_ipd,
	CRMCORECLK_ipd,
	CRMLINKRSTN_ipd,
	CRMMACRSTN_ipd,
	CRMMGMTRSTN_ipd,
	CRMNVRSTN_ipd,
	CRMTXHOTRESETN_ipd,
	CRMURSTN_ipd,
	CRMUSERCFGRSTN_ipd,
	CRMUSERCLKRXO_ipd,
	CRMUSERCLKTXO_ipd,
	CRMUSERCLK_ipd,
	CROSSLINKSEED_ipd,
	L0ACKNAKTIMERADJUSTMENT_ipd,
	L0ALLDOWNPORTSINL1_ipd,
	L0ALLDOWNRXPORTSINL0S_ipd,
	L0ASE_ipd,
	L0ASPORTCOUNT_ipd,
	L0ASTURNPOOLBITSCONSUMED_ipd,
	L0ATTENTIONBUTTONPRESSED_ipd,
	L0CFGASSPANTREEOWNEDSTATE_ipd,
	L0CFGASSTATECHANGECMD_ipd,
	L0CFGDISABLESCRAMBLE_ipd,
	L0CFGEXTENDEDSYNC_ipd,
	L0CFGL0SENTRYENABLE_ipd,
	L0CFGL0SENTRYSUP_ipd,
	L0CFGL0SEXITLAT_ipd,
	L0CFGLINKDISABLE_ipd,
	L0CFGLOOPBACKMASTER_ipd,
	L0CFGNEGOTIATEDMAXP_ipd,
	L0CFGVCENABLE_ipd,
	L0CFGVCID_ipd,
	L0DLLHOLDLINKUP_ipd,
	L0ELECTROMECHANICALINTERLOCKENGAGED_ipd,
	L0FWDASSERTINTALEGACYINT_ipd,
	L0FWDASSERTINTBLEGACYINT_ipd,
	L0FWDASSERTINTCLEGACYINT_ipd,
	L0FWDASSERTINTDLEGACYINT_ipd,
	L0FWDCORRERRIN_ipd,
	L0FWDDEASSERTINTALEGACYINT_ipd,
	L0FWDDEASSERTINTBLEGACYINT_ipd,
	L0FWDDEASSERTINTCLEGACYINT_ipd,
	L0FWDDEASSERTINTDLEGACYINT_ipd,
	L0FWDFATALERRIN_ipd,
	L0FWDNONFATALERRIN_ipd,
	L0LEGACYINTFUNCT0_ipd,
	L0MRLSENSORCLOSEDN_ipd,
	L0MSIREQUEST0_ipd,
	L0PACKETHEADERFROMUSER_ipd,
	L0PMEREQIN_ipd,
	L0PORTNUMBER_ipd,
	L0POWERFAULTDETECTED_ipd,
	L0PRESENCEDETECTSLOTEMPTYN_ipd,
	L0PWRNEWSTATEREQ_ipd,
	L0PWRNEXTLINKSTATE_ipd,
	L0REPLAYTIMERADJUSTMENT_ipd,
	L0ROOTTURNOFFREQ_ipd,
	L0RXTLTLPNONINITIALIZEDVC_ipd,
	L0SENDUNLOCKMESSAGE_ipd,
	L0SETCOMPLETERABORTERROR_ipd,
	L0SETCOMPLETIONTIMEOUTCORRERROR_ipd,
	L0SETCOMPLETIONTIMEOUTUNCORRERROR_ipd,
	L0SETDETECTEDCORRERROR_ipd,
	L0SETDETECTEDFATALERROR_ipd,
	L0SETDETECTEDNONFATALERROR_ipd,
	L0SETLINKDETECTEDPARITYERROR_ipd,
	L0SETLINKMASTERDATAPARITY_ipd,
	L0SETLINKRECEIVEDMASTERABORT_ipd,
	L0SETLINKRECEIVEDTARGETABORT_ipd,
	L0SETLINKSIGNALLEDTARGETABORT_ipd,
	L0SETLINKSYSTEMERROR_ipd,
	L0SETUNEXPECTEDCOMPLETIONCORRERROR_ipd,
	L0SETUNEXPECTEDCOMPLETIONUNCORRERROR_ipd,
	L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR_ipd,
	L0SETUNSUPPORTEDREQUESTOTHERERROR_ipd,
	L0SETUSERDETECTEDPARITYERROR_ipd,
	L0SETUSERMASTERDATAPARITY_ipd,
	L0SETUSERRECEIVEDMASTERABORT_ipd,
	L0SETUSERRECEIVEDTARGETABORT_ipd,
	L0SETUSERSIGNALLEDTARGETABORT_ipd,
	L0SETUSERSYSTEMERROR_ipd,
	L0TLASFCCREDSTARVATION_ipd,
	L0TLLINKRETRAIN_ipd,
	L0TRANSACTIONSPENDING_ipd,
	L0TXBEACON_ipd,
	L0TXCFGPMTYPE_ipd,
	L0TXCFGPM_ipd,
	L0TXTLFCCMPLMCCRED_ipd,
	L0TXTLFCCMPLMCUPDATE_ipd,
	L0TXTLFCNPOSTBYPCRED_ipd,
	L0TXTLFCNPOSTBYPUPDATE_ipd,
	L0TXTLFCPOSTORDCRED_ipd,
	L0TXTLFCPOSTORDUPDATE_ipd,
	L0TXTLSBFCDATA_ipd,
	L0TXTLSBFCUPDATE_ipd,
	L0TXTLTLPDATA_ipd,
	L0TXTLTLPEDB_ipd,
	L0TXTLTLPENABLE_ipd,
	L0TXTLTLPEND_ipd,
	L0TXTLTLPLATENCY_ipd,
	L0TXTLTLPREQEND_ipd,
	L0TXTLTLPREQ_ipd,
	L0TXTLTLPWIDTH_ipd,
	L0UPSTREAMRXPORTINL0S_ipd,
	L0VC0PREVIEWEXPAND_ipd,
	L0WAKEN_ipd,
	LLKRXCHFIFO_ipd,
	LLKRXCHTC_ipd,
	LLKRXDSTCONTREQN_ipd,
	LLKRXDSTREQN_ipd,
	LLKTX4DWHEADERN_ipd,
	LLKTXCHFIFO_ipd,
	LLKTXCHTC_ipd,
	LLKTXCOMPLETEN_ipd,
	LLKTXCREATEECRCN_ipd,
	LLKTXDATA_ipd,
	LLKTXENABLEN_ipd,
	LLKTXEOFN_ipd,
	LLKTXEOPN_ipd,
	LLKTXSOFN_ipd,
	LLKTXSOPN_ipd,
	LLKTXSRCDSCN_ipd,
	LLKTXSRCRDYN_ipd,
	MAINPOWER_ipd,
	MGMTADDR_ipd,
	MGMTBWREN_ipd,
	MGMTRDEN_ipd,
	MGMTSTATSCREDITSEL_ipd,
	MGMTWDATA_ipd,
	MGMTWREN_ipd,
	MIMDLLBRDATA_ipd,
	MIMRXBRDATA_ipd,
	MIMTXBRDATA_ipd,
	PIPEPHYSTATUSL0_ipd,
	PIPEPHYSTATUSL1_ipd,
	PIPEPHYSTATUSL2_ipd,
	PIPEPHYSTATUSL3_ipd,
	PIPEPHYSTATUSL4_ipd,
	PIPEPHYSTATUSL5_ipd,
	PIPEPHYSTATUSL6_ipd,
	PIPEPHYSTATUSL7_ipd,
	PIPERXCHANISALIGNEDL0_ipd,
	PIPERXCHANISALIGNEDL1_ipd,
	PIPERXCHANISALIGNEDL2_ipd,
	PIPERXCHANISALIGNEDL3_ipd,
	PIPERXCHANISALIGNEDL4_ipd,
	PIPERXCHANISALIGNEDL5_ipd,
	PIPERXCHANISALIGNEDL6_ipd,
	PIPERXCHANISALIGNEDL7_ipd,
	PIPERXDATAKL0_ipd,
	PIPERXDATAKL1_ipd,
	PIPERXDATAKL2_ipd,
	PIPERXDATAKL3_ipd,
	PIPERXDATAKL4_ipd,
	PIPERXDATAKL5_ipd,
	PIPERXDATAKL6_ipd,
	PIPERXDATAKL7_ipd,
	PIPERXDATAL0_ipd,
	PIPERXDATAL1_ipd,
	PIPERXDATAL2_ipd,
	PIPERXDATAL3_ipd,
	PIPERXDATAL4_ipd,
	PIPERXDATAL5_ipd,
	PIPERXDATAL6_ipd,
	PIPERXDATAL7_ipd,
	PIPERXELECIDLEL0_ipd,
	PIPERXELECIDLEL1_ipd,
	PIPERXELECIDLEL2_ipd,
	PIPERXELECIDLEL3_ipd,
	PIPERXELECIDLEL4_ipd,
	PIPERXELECIDLEL5_ipd,
	PIPERXELECIDLEL6_ipd,
	PIPERXELECIDLEL7_ipd,
	PIPERXSTATUSL0_ipd,
	PIPERXSTATUSL1_ipd,
	PIPERXSTATUSL2_ipd,
	PIPERXSTATUSL3_ipd,
	PIPERXSTATUSL4_ipd,
	PIPERXSTATUSL5_ipd,
	PIPERXSTATUSL6_ipd,
	PIPERXSTATUSL7_ipd,
	PIPERXVALIDL0_ipd,
	PIPERXVALIDL1_ipd,
	PIPERXVALIDL2_ipd,
	PIPERXVALIDL3_ipd,
	PIPERXVALIDL4_ipd,
	PIPERXVALIDL5_ipd,
	PIPERXVALIDL6_ipd,
	PIPERXVALIDL7_ipd;

	end process TIMING;


end PCIE_INTERNAL_1_1_V;
