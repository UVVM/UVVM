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
-- /___/   /\     Filename    : pcie_ep.vhd
-- \   \  /  \    Timestamp   : Thu Dec 8 2005
--  \___\/\___\
--
-- Revision:
-- 08/14/06 - CR#421379 - Initial version.
-- 08/31/06 - BVT#1001  - Added PCIE_INTERNAL_1_1 component
-- 08/13/06 - CR#423912 - Added zero vectors (std_logic_vector)
-- 10/16/06 - CR#427095 - Modified generic map SWIFT instantiation to match spreadsheets
-- 12/05/06 - CR#420518 - Added input pin LLKRXDSTCONTREQN
-- 12/05/06 - CR#420518 - Added input pin LLKRXDSTCONTREQN
-- 03/13/07 - CR#435993 - Add LLKTXCONFIGREADYN
-- End Revision

----- CELL PCIE_EP -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity PCIE_EP is
generic (
	ACTIVELANESIN : bit_vector := X"01";
	AERBASEPTR : bit_vector := X"110";
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
	DEVICECAPABILITYENDPOINTL0SLATENCY : bit_vector := X"0";
	DEVICECAPABILITYENDPOINTL1LATENCY : bit_vector := X"0";
	DEVICEID : bit_vector := X"5050";
	DEVICESERIALNUMBER : bit_vector := X"E000000001000A35";
	DSNBASEPTR : bit_vector := X"148";
	DSNCAPABILITYNEXTPTR : bit_vector := X"154";
	INFINITECOMPLETIONS : boolean := TRUE;
	INTERRUPTPIN : bit_vector := X"00";
	L0SEXITLATENCY : integer := 7;
	L0SEXITLATENCYCOMCLK : integer := 7;
	L1EXITLATENCY : integer := 7;
	L1EXITLATENCYCOMCLK : integer := 7;
	LINKCAPABILITYASPMSUPPORT : bit_vector := X"1";
	LINKCAPABILITYMAXLINKWIDTH : bit_vector := X"01";
	LINKSTATUSSLOTCLOCKCONFIG : boolean := FALSE;
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
	PCIECAPABILITYNEXTPTR : bit_vector := X"00";
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
	PMDATASCALE0 : integer := 0;
	PMDATASCALE1 : integer := 0;
	PMDATASCALE2 : integer := 0;
	PMDATASCALE3 : integer := 0;
	PMDATASCALE4 : integer := 0;
	PMDATASCALE5 : integer := 0;
	PMDATASCALE6 : integer := 0;
	PMDATASCALE7 : integer := 0;
	PORTVCCAPABILITYEXTENDEDVCCOUNT : bit_vector := X"0";
	PORTVCCAPABILITYVCARBCAP : bit_vector := X"00";
	PORTVCCAPABILITYVCARBTABLEOFFSET : bit_vector := X"00";
	RESETMODE : boolean := FALSE;
	RETRYRAMREADLATENCY : integer := 3;
	RETRYRAMSIZE : bit_vector := X"009";
	RETRYRAMWRITELATENCY : integer := 1;
	REVISIONID : bit_vector := X"00";
	SUBSYSTEMID : bit_vector := X"5050";
	SUBSYSTEMVENDORID : bit_vector := X"10EE";
	TLRAMREADLATENCY : integer := 3;
	TLRAMWRITELATENCY : integer := 1;
	TXTSNFTS : integer := 255;
	TXTSNFTSCOMCLK : integer := 255;
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
	XPBASEPTR : bit_vector := X"60";
	XPDEVICEPORTTYPE : bit_vector := X"0";
	XPMAXPAYLOAD : integer := 0
  );

port (
		BUSMASTERENABLE : out std_ulogic;
		CRMDOHOTRESETN : out std_ulogic;
		CRMPWRSOFTRESETN : out std_ulogic;
		DLLTXPMDLLPOUTSTANDING : out std_ulogic;
		INTERRUPTDISABLE : out std_ulogic;
		IOSPACEENABLE : out std_ulogic;
		L0CFGLOOPBACKACK : out std_ulogic;
		L0COMPLETERID : out std_logic_vector(12 downto 0);
		L0DLLERRORVECTOR : out std_logic_vector(6 downto 0);
		L0DLLRXACKOUTSTANDING : out std_ulogic;
		L0DLLTXNONFCOUTSTANDING : out std_ulogic;
		L0DLLTXOUTSTANDING : out std_ulogic;
		L0DLLVCSTATUS : out std_logic_vector(7 downto 0);
		L0DLUPDOWN : out std_logic_vector(7 downto 0);
		L0FIRSTCFGWRITEOCCURRED : out std_ulogic;
		L0LTSSMSTATE : out std_logic_vector(3 downto 0);
		L0MACENTEREDL0 : out std_ulogic;
		L0MACLINKTRAINING : out std_ulogic;
		L0MACLINKUP : out std_ulogic;
		L0MACNEGOTIATEDLINKWIDTH : out std_logic_vector(3 downto 0);
		L0MACNEWSTATEACK : out std_ulogic;
		L0MACRXL0SSTATE : out std_ulogic;
		L0MSIENABLE0 : out std_ulogic;
		L0MULTIMSGEN0 : out std_logic_vector(2 downto 0);
		L0PMEACK : out std_ulogic;
		L0PMEEN : out std_ulogic;
		L0PMEREQOUT : out std_ulogic;
		L0PWRL1STATE : out std_ulogic;
		L0PWRL23READYSTATE : out std_ulogic;
		L0PWRSTATE0 : out std_logic_vector(1 downto 0);
		L0PWRTURNOFFREQ : out std_ulogic;
		L0PWRTXL0SSTATE : out std_ulogic;
		L0RXDLLPM : out std_ulogic;
		L0RXDLLPMTYPE : out std_logic_vector(2 downto 0);
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
		L0UNLOCKRECEIVED : out std_ulogic;
		LLKRXCHCOMPLETIONAVAILABLEN : out std_logic_vector(7 downto 0);
		LLKRXCHNONPOSTEDAVAILABLEN : out std_logic_vector(7 downto 0);
		LLKRXCHPOSTEDAVAILABLEN : out std_logic_vector(7 downto 0);
		LLKRXDATA : out std_logic_vector(63 downto 0);
		LLKRXEOFN : out std_ulogic;
		LLKRXEOPN : out std_ulogic;
		LLKRXPREFERREDTYPE : out std_logic_vector(15 downto 0);
		LLKRXSOFN : out std_ulogic;
		LLKRXSOPN : out std_ulogic;
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
		COMPLIANCEAVOID : in std_ulogic;
		CRMCORECLK : in std_ulogic;
		CRMCORECLKDLO : in std_ulogic;
		CRMCORECLKRXO : in std_ulogic;
		CRMCORECLKTXO : in std_ulogic;
		CRMLINKRSTN : in std_ulogic;
		CRMMACRSTN : in std_ulogic;
		CRMMGMTRSTN : in std_ulogic;
		CRMNVRSTN : in std_ulogic;
		CRMURSTN : in std_ulogic;
		CRMUSERCFGRSTN : in std_ulogic;
		CRMUSERCLK : in std_ulogic;
		CRMUSERCLKRXO : in std_ulogic;
		CRMUSERCLKTXO : in std_ulogic;
		L0CFGDISABLESCRAMBLE : in std_ulogic;
		L0CFGLOOPBACKMASTER : in std_ulogic;
		L0LEGACYINTFUNCT0 : in std_ulogic;
		L0MSIREQUEST0 : in std_logic_vector(3 downto 0);
		L0PACKETHEADERFROMUSER : in std_logic_vector(127 downto 0);
		L0PMEREQIN : in std_ulogic;
		L0SETCOMPLETERABORTERROR : in std_ulogic;
		L0SETCOMPLETIONTIMEOUTCORRERROR : in std_ulogic;
		L0SETCOMPLETIONTIMEOUTUNCORRERROR : in std_ulogic;
		L0SETDETECTEDCORRERROR : in std_ulogic;
		L0SETDETECTEDFATALERROR : in std_ulogic;
		L0SETDETECTEDNONFATALERROR : in std_ulogic;
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
		L0TRANSACTIONSPENDING : in std_ulogic;
		LLKRXCHFIFO : in std_logic_vector(1 downto 0);
		LLKRXCHTC : in std_logic_vector(2 downto 0);
                LLKRXDSTCONTREQN : in std_ulogic;
		LLKRXDSTREQN : in std_ulogic;
		LLKTXCHFIFO : in std_logic_vector(1 downto 0);
		LLKTXCHTC : in std_logic_vector(2 downto 0);
		LLKTXDATA : in std_logic_vector(63 downto 0);
		LLKTXENABLEN : in std_logic_vector(1 downto 0);
		LLKTXEOFN : in std_ulogic;
		LLKTXEOPN : in std_ulogic;
		LLKTXSOFN : in std_ulogic;
		LLKTXSOPN : in std_ulogic;
		LLKTXSRCDSCN : in std_ulogic;
		LLKTXSRCRDYN : in std_ulogic;
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
end PCIE_EP;

architecture PCIE_EP_V of PCIE_EP is

  component PCIE_INTERNAL_1_1
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
  end component;

signal  OPEN1 : std_logic;
signal  OPEN8 : std_logic_vector(7 downto 0);
signal  OPEN2 : std_logic_vector(1 downto 0);
signal  OPEN16 : std_logic_vector(15 downto 0);
signal  OPEN19 : std_logic_vector(18 downto 0);
signal  OPEN20 : std_logic_vector(19 downto 0);
signal  OPEN24 : std_logic_vector(23 downto 0);
signal  OPEN4 : std_logic_vector(3 downto 0);
signal  OPEN3 : std_logic_vector(2 downto 0);

signal  z1_0 : std_logic := '0';
signal  z1_1 : std_logic := '1';
signal  z2 : std_logic_vector(1 downto 0) := "00";
signal  z3 : std_logic_vector(2 downto 0) := "000";
signal  z4 : std_logic_vector(3 downto 0) := "0000";
signal  z6 : std_logic_vector(5 downto 0) := "000000";
signal  z8 : std_logic_vector(7 downto 0) :=  "00000000";

signal  z12 : std_logic_vector(11 downto 0) := "000000000000";
signal  z16 : std_logic_vector(15 downto 0) := "0000000000000000";
signal  z19 : std_logic_vector(18 downto 0) :=  "0000000000000000000";
signal  z24 : std_logic_vector(23 downto 0) :=  "000000000000000000000000";
signal  z64 : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000";
signal  z160 : std_logic_vector(159 downto 0) :=  "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
signal  z192 : std_logic_vector(191 downto 0) :=  "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

begin
PCIE_INTERNAL_1_1_inst : PCIE_INTERNAL_1_1
	generic map (
        ACTIVELANESIN => ACTIVELANESIN,
        AERBASEPTR => AERBASEPTR,
        AERCAPABILITYECRCCHECKCAPABLE => FALSE,
        AERCAPABILITYECRCGENCAPABLE => FALSE,
        AERCAPABILITYNEXTPTR => AERCAPABILITYNEXTPTR,
        BAR0ADDRWIDTH => BAR0ADDRWIDTH,
        BAR0EXIST => BAR0EXIST,
        BAR0IOMEMN => BAR0IOMEMN,
        BAR0MASKWIDTH => BAR0MASKWIDTH,
        BAR0PREFETCHABLE => BAR0PREFETCHABLE,
        BAR1ADDRWIDTH => BAR1ADDRWIDTH,
        BAR1EXIST => BAR1EXIST,
        BAR1IOMEMN => BAR1IOMEMN,
        BAR1MASKWIDTH => BAR1MASKWIDTH,
        BAR1PREFETCHABLE => BAR1PREFETCHABLE,
        BAR2ADDRWIDTH => BAR2ADDRWIDTH,
        BAR2EXIST => BAR2EXIST,
        BAR2IOMEMN => BAR2IOMEMN,
        BAR2MASKWIDTH => BAR2MASKWIDTH,
        BAR2PREFETCHABLE => BAR2PREFETCHABLE,
        BAR3ADDRWIDTH => BAR3ADDRWIDTH,
        BAR3EXIST => BAR3EXIST,
        BAR3IOMEMN => BAR3IOMEMN,
        BAR3MASKWIDTH => BAR3MASKWIDTH,
        BAR3PREFETCHABLE => BAR3PREFETCHABLE,
        BAR4ADDRWIDTH => BAR4ADDRWIDTH,
        BAR4EXIST => BAR4EXIST,
        BAR4IOMEMN => BAR4IOMEMN,
        BAR4MASKWIDTH => BAR4MASKWIDTH,
        BAR4PREFETCHABLE => BAR4PREFETCHABLE,
        BAR5EXIST => BAR5EXIST,
        BAR5IOMEMN => BAR5IOMEMN,
        BAR5MASKWIDTH => BAR5MASKWIDTH,
        BAR5PREFETCHABLE => BAR5PREFETCHABLE,
        CAPABILITIESPOINTER => CAPABILITIESPOINTER,
        CARDBUSCISPOINTER => CARDBUSCISPOINTER,
        CLASSCODE => CLASSCODE,
        CLKDIVIDED => CLKDIVIDED,
        CONFIGROUTING => "001",
        DEVICECAPABILITYENDPOINTL0SLATENCY => DEVICECAPABILITYENDPOINTL0SLATENCY,
        DEVICECAPABILITYENDPOINTL1LATENCY => DEVICECAPABILITYENDPOINTL1LATENCY,
        DEVICEID => DEVICEID,
        DEVICESERIALNUMBER => DEVICESERIALNUMBER,
        DSNBASEPTR => DSNBASEPTR,
        DSNCAPABILITYNEXTPTR => DSNCAPABILITYNEXTPTR,
        DUALCOREENABLE => FALSE,
        DUALCORESLAVE => FALSE,
        DUALROLECFGCNTRLROOTEPN => 0,
        EXTCFGCAPPTR => X"00",
        EXTCFGXPCAPPTR => X"000",
        HEADERTYPE => X"00",
        INFINITECOMPLETIONS => INFINITECOMPLETIONS,
        INTERRUPTPIN => INTERRUPTPIN,
        ISSWITCH => FALSE,
        L0SEXITLATENCY => L0SEXITLATENCY,
        L0SEXITLATENCYCOMCLK => L0SEXITLATENCYCOMCLK,
        L1EXITLATENCY => L1EXITLATENCY,
        L1EXITLATENCYCOMCLK => L1EXITLATENCYCOMCLK,
        LINKCAPABILITYASPMSUPPORT => LINKCAPABILITYASPMSUPPORT,
        LINKCAPABILITYMAXLINKWIDTH => LINKCAPABILITYMAXLINKWIDTH,
        LINKSTATUSSLOTCLOCKCONFIG => LINKSTATUSSLOTCLOCKCONFIG,
        LLKBYPASS => FALSE,
        LOWPRIORITYVCCOUNT => LOWPRIORITYVCCOUNT,
        MSIBASEPTR => MSIBASEPTR,
        MSICAPABILITYMULTIMSGCAP => MSICAPABILITYMULTIMSGCAP,
        MSICAPABILITYNEXTPTR => MSICAPABILITYNEXTPTR,
        PBBASEPTR => PBBASEPTR,
        PBCAPABILITYDW0BASEPOWER => PBCAPABILITYDW0BASEPOWER,
        PBCAPABILITYDW0DATASCALE => PBCAPABILITYDW0DATASCALE,
        PBCAPABILITYDW0PMSTATE => PBCAPABILITYDW0PMSTATE,
        PBCAPABILITYDW0PMSUBSTATE => PBCAPABILITYDW0PMSUBSTATE,
        PBCAPABILITYDW0POWERRAIL => PBCAPABILITYDW0POWERRAIL,
        PBCAPABILITYDW0TYPE => PBCAPABILITYDW0TYPE,
        PBCAPABILITYDW1BASEPOWER => PBCAPABILITYDW1BASEPOWER,
        PBCAPABILITYDW1DATASCALE => PBCAPABILITYDW1DATASCALE,
        PBCAPABILITYDW1PMSTATE => PBCAPABILITYDW1PMSTATE,
        PBCAPABILITYDW1PMSUBSTATE => PBCAPABILITYDW1PMSUBSTATE,
        PBCAPABILITYDW1POWERRAIL => PBCAPABILITYDW1POWERRAIL,
        PBCAPABILITYDW1TYPE => PBCAPABILITYDW1TYPE,
        PBCAPABILITYDW2BASEPOWER => PBCAPABILITYDW2BASEPOWER,
        PBCAPABILITYDW2DATASCALE => PBCAPABILITYDW2DATASCALE,
        PBCAPABILITYDW2PMSTATE => PBCAPABILITYDW2PMSTATE,
        PBCAPABILITYDW2PMSUBSTATE => PBCAPABILITYDW2PMSUBSTATE,
        PBCAPABILITYDW2POWERRAIL => PBCAPABILITYDW2POWERRAIL,
        PBCAPABILITYDW2TYPE => PBCAPABILITYDW2TYPE,
        PBCAPABILITYDW3BASEPOWER => PBCAPABILITYDW3BASEPOWER,
        PBCAPABILITYDW3DATASCALE => PBCAPABILITYDW3DATASCALE,
        PBCAPABILITYDW3PMSTATE => PBCAPABILITYDW3PMSTATE,
        PBCAPABILITYDW3PMSUBSTATE => PBCAPABILITYDW3PMSUBSTATE,
        PBCAPABILITYDW3POWERRAIL => PBCAPABILITYDW3POWERRAIL,
        PBCAPABILITYDW3TYPE => PBCAPABILITYDW3TYPE,
        PBCAPABILITYNEXTPTR => PBCAPABILITYNEXTPTR,
        PBCAPABILITYSYSTEMALLOCATED => PBCAPABILITYSYSTEMALLOCATED,
        PCIECAPABILITYINTMSGNUM => "00000",
        PCIECAPABILITYNEXTPTR => PCIECAPABILITYNEXTPTR,
        PCIECAPABILITYSLOTIMPL => FALSE,
        PCIEREVISION => 1,
        PMBASEPTR => PMBASEPTR,
        PMCAPABILITYAUXCURRENT => PMCAPABILITYAUXCURRENT,
        PMCAPABILITYD1SUPPORT => PMCAPABILITYD1SUPPORT,
        PMCAPABILITYD2SUPPORT => PMCAPABILITYD2SUPPORT,
        PMCAPABILITYDSI => PMCAPABILITYDSI,
        PMCAPABILITYNEXTPTR => PMCAPABILITYNEXTPTR,
        PMCAPABILITYPMESUPPORT => PMCAPABILITYPMESUPPORT,
        PMDATA0 => PMDATA0,
        PMDATA1 => PMDATA1,
        PMDATA2 => PMDATA2,
        PMDATA3 => PMDATA3,
        PMDATA4 => PMDATA4,
        PMDATA5 => PMDATA5,
        PMDATA6 => PMDATA6,
        PMDATA7 => PMDATA7,
        PMDATA8 => X"00",
        PMDATASCALE0 => PMDATASCALE0,
        PMDATASCALE1 => PMDATASCALE1,
        PMDATASCALE2 => PMDATASCALE2,
        PMDATASCALE3 => PMDATASCALE3,
        PMDATASCALE4 => PMDATASCALE4,
        PMDATASCALE5 => PMDATASCALE5,
        PMDATASCALE6 => PMDATASCALE6,
        PMDATASCALE7 => PMDATASCALE7,
        PMDATASCALE8 => 0,
        PMSTATUSCONTROLDATASCALE => "00",
        PORTVCCAPABILITYEXTENDEDVCCOUNT => PORTVCCAPABILITYEXTENDEDVCCOUNT,
        PORTVCCAPABILITYVCARBCAP => PORTVCCAPABILITYVCARBCAP,
        PORTVCCAPABILITYVCARBTABLEOFFSET => PORTVCCAPABILITYVCARBTABLEOFFSET,
        RAMSHARETXRX => FALSE,
        RESETMODE => RESETMODE,
        RETRYRAMREADLATENCY => RETRYRAMREADLATENCY,
        RETRYRAMSIZE => RETRYRAMSIZE,
        RETRYRAMWIDTH => 0,
        RETRYRAMWRITELATENCY => RETRYRAMWRITELATENCY,
        RETRYREADADDRPIPE => FALSE,
        RETRYREADDATAPIPE => FALSE,
        RETRYWRITEPIPE => FALSE,
        REVISIONID => REVISIONID,
        RXREADADDRPIPE => FALSE,
        RXREADDATAPIPE => FALSE,
        RXWRITEPIPE => FALSE,
        SELECTASMODE => FALSE,
        SELECTDLLIF => FALSE,
        SLOTCAPABILITYATTBUTTONPRESENT => FALSE,
        SLOTCAPABILITYATTINDICATORPRESENT => FALSE,
        SLOTCAPABILITYHOTPLUGCAPABLE => FALSE,
        SLOTCAPABILITYHOTPLUGSURPRISE => FALSE,
        SLOTCAPABILITYMSLSENSORPRESENT => FALSE,
        SLOTCAPABILITYPHYSICALSLOTNUM => "0000000000000",
        SLOTCAPABILITYPOWERCONTROLLERPRESENT => FALSE,
        SLOTCAPABILITYPOWERINDICATORPRESENT => FALSE,
        SLOTCAPABILITYSLOTPOWERLIMITSCALE => "00",
        SLOTCAPABILITYSLOTPOWERLIMITVALUE => X"00",
        SLOTIMPLEMENTED => FALSE,
        SUBSYSTEMID => SUBSYSTEMID,
        SUBSYSTEMVENDORID => SUBSYSTEMVENDORID,
        TLRAMREADLATENCY => TLRAMREADLATENCY,
        TLRAMWIDTH => 0,
        TLRAMWRITELATENCY => TLRAMWRITELATENCY,
        TXREADADDRPIPE => FALSE,
        TXREADDATAPIPE => FALSE,
        TXTSNFTS => TXTSNFTS,
        TXTSNFTSCOMCLK => TXTSNFTSCOMCLK,
        TXWRITEPIPE => FALSE,
        UPSTREAMFACING => TRUE,
        VC0RXFIFOBASEC => VC0RXFIFOBASEC,
        VC0RXFIFOBASENP => VC0RXFIFOBASENP,
        VC0RXFIFOBASEP => VC0RXFIFOBASEP,
        VC0RXFIFOLIMITC => VC0RXFIFOLIMITC,
        VC0RXFIFOLIMITNP => VC0RXFIFOLIMITNP,
        VC0RXFIFOLIMITP => VC0RXFIFOLIMITP,
        VC0TOTALCREDITSCD => VC0TOTALCREDITSCD,
        VC0TOTALCREDITSCH => VC0TOTALCREDITSCH,
        VC0TOTALCREDITSNPH => VC0TOTALCREDITSNPH,
        VC0TOTALCREDITSPD => VC0TOTALCREDITSPD,
        VC0TOTALCREDITSPH => VC0TOTALCREDITSPH,
        VC0TXFIFOBASEC => VC0TXFIFOBASEC,
        VC0TXFIFOBASENP => VC0TXFIFOBASENP,
        VC0TXFIFOBASEP => VC0TXFIFOBASEP,
        VC0TXFIFOLIMITC => VC0TXFIFOLIMITC,
        VC0TXFIFOLIMITNP => VC0TXFIFOLIMITNP,
        VC0TXFIFOLIMITP => VC0TXFIFOLIMITP,
        VC1RXFIFOBASEC => VC1RXFIFOBASEC,
        VC1RXFIFOBASENP => VC1RXFIFOBASENP,
        VC1RXFIFOBASEP => VC1RXFIFOBASEP,
        VC1RXFIFOLIMITC => VC1RXFIFOLIMITC,
        VC1RXFIFOLIMITNP => VC1RXFIFOLIMITNP,
        VC1RXFIFOLIMITP => VC1RXFIFOLIMITP,
        VC1TOTALCREDITSCD => VC1TOTALCREDITSCD,
        VC1TOTALCREDITSCH => VC1TOTALCREDITSCH,
        VC1TOTALCREDITSNPH => VC1TOTALCREDITSNPH,
        VC1TOTALCREDITSPD => VC1TOTALCREDITSPD,
        VC1TOTALCREDITSPH => VC1TOTALCREDITSPH,
        VC1TXFIFOBASEC => VC1TXFIFOBASEC,
        VC1TXFIFOBASENP => VC1TXFIFOBASENP,
        VC1TXFIFOBASEP => VC1TXFIFOBASEP,
        VC1TXFIFOLIMITC => VC1TXFIFOLIMITC,
        VC1TXFIFOLIMITNP => VC1TXFIFOLIMITNP,
        VC1TXFIFOLIMITP => VC1TXFIFOLIMITP,
        VCBASEPTR => VCBASEPTR,
        VCCAPABILITYNEXTPTR => VCCAPABILITYNEXTPTR,
        VENDORID => VENDORID,
        XLINKSUPPORTED => FALSE,
        XPBASEPTR => XPBASEPTR,
        XPDEVICEPORTTYPE => XPDEVICEPORTTYPE,
        XPMAXPAYLOAD => XPMAXPAYLOAD,
        XPRCBCONTROL => 0
)

port map (
		AUXPOWER => AUXPOWER,
		BUSMASTERENABLE => BUSMASTERENABLE,
		CFGNEGOTIATEDLINKWIDTH => z6,
		COMPLIANCEAVOID => COMPLIANCEAVOID,
		CRMCFGBRIDGEHOTRESET => z1_0,
		CRMCORECLK => CRMCORECLK,
		CRMCORECLKDLO => CRMCORECLKDLO,
		CRMCORECLKRXO => CRMCORECLKRXO,
		CRMCORECLKTXO => CRMCORECLKTXO,
		CRMDOHOTRESETN => CRMDOHOTRESETN,
		CRMLINKRSTN => CRMLINKRSTN,
		CRMMACRSTN => CRMMACRSTN,
		CRMMGMTRSTN => CRMMGMTRSTN,
		CRMNVRSTN => CRMNVRSTN,
		CRMPWRSOFTRESETN => CRMPWRSOFTRESETN,
		CRMRXHOTRESETN => OPEN1,
		CRMTXHOTRESETN => z1_1,
		CRMURSTN => CRMURSTN,
		CRMUSERCFGRSTN => CRMUSERCFGRSTN,
		CRMUSERCLK => CRMUSERCLK,
		CRMUSERCLKRXO => CRMUSERCLKRXO,
		CRMUSERCLKTXO => CRMUSERCLKTXO,
		CROSSLINKSEED => z1_1,
		DLLTXPMDLLPOUTSTANDING => DLLTXPMDLLPOUTSTANDING,
		INTERRUPTDISABLE => INTERRUPTDISABLE,
		IOSPACEENABLE => IOSPACEENABLE,
		L0ACKNAKTIMERADJUSTMENT => z12,
		L0ALLDOWNPORTSINL1 => z1_0,
		L0ALLDOWNRXPORTSINL0S => z1_0,
		L0ASAUTONOMOUSINITCOMPLETED => OPEN1,
		L0ASE => z1_0,
		L0ASPORTCOUNT => z8,
		L0ASTURNPOOLBITSCONSUMED => z3,
		L0ATTENTIONBUTTONPRESSED => z1_0,
		L0ATTENTIONINDICATORCONTROL => OPEN2,
		L0CFGASSPANTREEOWNEDSTATE => z1_0,
		L0CFGASSTATECHANGECMD => z4,
		L0CFGDISABLESCRAMBLE => L0CFGDISABLESCRAMBLE,
		L0CFGEXTENDEDSYNC => z1_0,
		L0CFGL0SENTRYENABLE => z1_0,
		L0CFGL0SENTRYSUP => z1_0,
		L0CFGL0SEXITLAT => z3,
		L0CFGLINKDISABLE => z1_0,
		L0CFGLOOPBACKACK => L0CFGLOOPBACKACK,
		L0CFGLOOPBACKMASTER => L0CFGLOOPBACKMASTER,
		L0CFGNEGOTIATEDMAXP => z3,
		L0CFGVCENABLE => z8,
		L0CFGVCID => z24,
		L0COMPLETERID => L0COMPLETERID,
		L0CORRERRMSGRCVD => OPEN1,
		L0DLLASRXSTATE => OPEN2,
		L0DLLASTXSTATE => OPEN1,
		L0DLLERRORVECTOR => L0DLLERRORVECTOR,
		L0DLLHOLDLINKUP => z1_0,
		L0DLLRXACKOUTSTANDING => L0DLLRXACKOUTSTANDING,
		L0DLLTXNONFCOUTSTANDING => L0DLLTXNONFCOUTSTANDING,
		L0DLLTXOUTSTANDING => L0DLLTXOUTSTANDING,
		L0DLLVCSTATUS => L0DLLVCSTATUS,
		L0DLUPDOWN => L0DLUPDOWN,
		L0ELECTROMECHANICALINTERLOCKENGAGED => z1_0,
		L0ERRMSGREQID => OPEN16,
		L0FATALERRMSGRCVD => OPEN1,
		L0FIRSTCFGWRITEOCCURRED => L0FIRSTCFGWRITEOCCURRED,
		L0FWDASSERTINTALEGACYINT => z1_0,
		L0FWDASSERTINTBLEGACYINT => z1_0,
		L0FWDASSERTINTCLEGACYINT => z1_0,
		L0FWDASSERTINTDLEGACYINT => z1_0,
		L0FWDCORRERRIN => z1_0,
		L0FWDCORRERROUT => OPEN1,
		L0FWDDEASSERTINTALEGACYINT => z1_0,
		L0FWDDEASSERTINTBLEGACYINT => z1_0,
		L0FWDDEASSERTINTCLEGACYINT => z1_0,
		L0FWDDEASSERTINTDLEGACYINT => z1_0,
		L0FWDFATALERRIN => z1_0,
		L0FWDFATALERROUT => OPEN1,
		L0FWDNONFATALERRIN => z1_0,
		L0FWDNONFATALERROUT => OPEN1,
		L0LEGACYINTFUNCT0 => L0LEGACYINTFUNCT0,
		L0LTSSMSTATE => L0LTSSMSTATE,
		L0MACENTEREDL0 => L0MACENTEREDL0,
		L0MACLINKTRAINING => L0MACLINKTRAINING,
		L0MACLINKUP => L0MACLINKUP,
		L0MACNEGOTIATEDLINKWIDTH => L0MACNEGOTIATEDLINKWIDTH,
		L0MACNEWSTATEACK => L0MACNEWSTATEACK,
		L0MACRXL0SSTATE => L0MACRXL0SSTATE,
		L0MACUPSTREAMDOWNSTREAM => OPEN1,
		L0MCFOUND => OPEN3,
		L0MRLSENSORCLOSEDN => z1_0,
		L0MSIENABLE0 => L0MSIENABLE0,
		L0MSIREQUEST0 => L0MSIREQUEST0,
		L0MULTIMSGEN0 => L0MULTIMSGEN0,
		L0NONFATALERRMSGRCVD => OPEN1,
		L0PACKETHEADERFROMUSER => L0PACKETHEADERFROMUSER,
		L0PMEACK => L0PMEACK,
		L0PMEEN => L0PMEEN,
		L0PMEREQIN => L0PMEREQIN,
		L0PMEREQOUT => L0PMEREQOUT,
		L0PORTNUMBER => z8,
		L0POWERCONTROLLERCONTROL => OPEN1,
		L0POWERFAULTDETECTED => z1_0,
		L0POWERINDICATORCONTROL => OPEN2,
		L0PRESENCEDETECTSLOTEMPTYN => z1_0,
		L0PWRINHIBITTRANSFERS => OPEN1,
		L0PWRL1STATE => L0PWRL1STATE,
		L0PWRL23READYDEVICE => OPEN1,
		L0PWRL23READYSTATE => L0PWRL23READYSTATE,
		L0PWRNEWSTATEREQ => z1_0,
		L0PWRNEXTLINKSTATE => z2,
		L0PWRSTATE0 => L0PWRSTATE0,
		L0PWRTURNOFFREQ => L0PWRTURNOFFREQ,
		L0PWRTXL0SSTATE => L0PWRTXL0SSTATE,
		L0RECEIVEDASSERTINTALEGACYINT => OPEN1,
		L0RECEIVEDASSERTINTBLEGACYINT => OPEN1,
		L0RECEIVEDASSERTINTCLEGACYINT => OPEN1,
		L0RECEIVEDASSERTINTDLEGACYINT => OPEN1,
		L0RECEIVEDDEASSERTINTALEGACYINT => OPEN1,
		L0RECEIVEDDEASSERTINTBLEGACYINT => OPEN1,
		L0RECEIVEDDEASSERTINTCLEGACYINT => OPEN1,
		L0RECEIVEDDEASSERTINTDLEGACYINT => OPEN1,
		L0REPLAYTIMERADJUSTMENT => z12,
		L0ROOTTURNOFFREQ => z1_0,
		L0RXBEACON => OPEN1,
		L0RXDLLFCCMPLMCCRED => OPEN24,
		L0RXDLLFCCMPLMCUPDATE => OPEN8,
		L0RXDLLFCNPOSTBYPCRED => OPEN20,
		L0RXDLLFCNPOSTBYPUPDATE => OPEN8,
		L0RXDLLFCPOSTORDCRED => OPEN24,
		L0RXDLLFCPOSTORDUPDATE => OPEN8,
		L0RXDLLPM => L0RXDLLPM,
		L0RXDLLPMTYPE => L0RXDLLPMTYPE,
		L0RXDLLSBFCDATA => OPEN19,
		L0RXDLLSBFCUPDATE => OPEN1,
		L0RXDLLTLPECRCOK => OPEN1,
		L0RXDLLTLPEND => OPEN2,
		L0RXMACLINKERROR => L0RXMACLINKERROR,
		L0RXTLTLPNONINITIALIZEDVC => z8,
		L0SENDUNLOCKMESSAGE => z1_0,
		L0SETCOMPLETERABORTERROR => L0SETCOMPLETERABORTERROR,
		L0SETCOMPLETIONTIMEOUTCORRERROR => L0SETCOMPLETIONTIMEOUTCORRERROR,
		L0SETCOMPLETIONTIMEOUTUNCORRERROR => L0SETCOMPLETIONTIMEOUTUNCORRERROR,
		L0SETDETECTEDCORRERROR => L0SETDETECTEDCORRERROR,
		L0SETDETECTEDFATALERROR => L0SETDETECTEDFATALERROR,
		L0SETDETECTEDNONFATALERROR => L0SETDETECTEDNONFATALERROR,
		L0SETLINKDETECTEDPARITYERROR => z1_0,
		L0SETLINKMASTERDATAPARITY => z1_0,
		L0SETLINKRECEIVEDMASTERABORT => z1_0,
		L0SETLINKRECEIVEDTARGETABORT => z1_0,
		L0SETLINKSIGNALLEDTARGETABORT => z1_0,
		L0SETLINKSYSTEMERROR => z1_0,
		L0SETUNEXPECTEDCOMPLETIONCORRERROR => L0SETUNEXPECTEDCOMPLETIONCORRERROR,
		L0SETUNEXPECTEDCOMPLETIONUNCORRERROR => L0SETUNEXPECTEDCOMPLETIONUNCORRERROR,
		L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR => L0SETUNSUPPORTEDREQUESTNONPOSTEDERROR,
		L0SETUNSUPPORTEDREQUESTOTHERERROR => L0SETUNSUPPORTEDREQUESTOTHERERROR,
		L0SETUSERDETECTEDPARITYERROR => L0SETUSERDETECTEDPARITYERROR,
		L0SETUSERMASTERDATAPARITY => L0SETUSERMASTERDATAPARITY,
		L0SETUSERRECEIVEDMASTERABORT => L0SETUSERRECEIVEDMASTERABORT,
		L0SETUSERRECEIVEDTARGETABORT => L0SETUSERRECEIVEDTARGETABORT,
		L0SETUSERSIGNALLEDTARGETABORT => L0SETUSERSIGNALLEDTARGETABORT,
		L0SETUSERSYSTEMERROR => L0SETUSERSYSTEMERROR,
		L0STATSCFGOTHERRECEIVED => L0STATSCFGOTHERRECEIVED,
		L0STATSCFGOTHERTRANSMITTED => L0STATSCFGOTHERTRANSMITTED,
		L0STATSCFGRECEIVED => L0STATSCFGRECEIVED,
		L0STATSCFGTRANSMITTED => L0STATSCFGTRANSMITTED,
		L0STATSDLLPRECEIVED => L0STATSDLLPRECEIVED,
		L0STATSDLLPTRANSMITTED => L0STATSDLLPTRANSMITTED,
		L0STATSOSRECEIVED => L0STATSOSRECEIVED,
		L0STATSOSTRANSMITTED => L0STATSOSTRANSMITTED,
		L0STATSTLPRECEIVED => L0STATSTLPRECEIVED,
		L0STATSTLPTRANSMITTED => L0STATSTLPTRANSMITTED,
		L0TLASFCCREDSTARVATION => z1_0,
		L0TLLINKRETRAIN => z1_0,
		L0TOGGLEELECTROMECHANICALINTERLOCK => OPEN1,
		L0TRANSACTIONSPENDING => L0TRANSACTIONSPENDING,
		L0TRANSFORMEDVC => OPEN3,
		L0TXBEACON => z1_0,
		L0TXCFGPM => z1_0,
		L0TXCFGPMTYPE => z3,
		L0TXDLLFCCMPLMCUPDATED => OPEN8,
		L0TXDLLFCNPOSTBYPUPDATED => OPEN8,
		L0TXDLLFCPOSTORDUPDATED => OPEN8,
		L0TXDLLPMUPDATED => OPEN1,
		L0TXDLLSBFCUPDATED => OPEN1,
		L0TXTLFCCMPLMCCRED => z160,
		L0TXTLFCCMPLMCUPDATE => z16,
		L0TXTLFCNPOSTBYPCRED => z192,
		L0TXTLFCNPOSTBYPUPDATE => z16,
		L0TXTLFCPOSTORDCRED => z160,
		L0TXTLFCPOSTORDUPDATE => z16,
		L0TXTLSBFCDATA => z19,
		L0TXTLSBFCUPDATE => z1_0,
		L0TXTLTLPDATA => z64,
		L0TXTLTLPEDB => z1_0,
		L0TXTLTLPENABLE => z2,
		L0TXTLTLPEND => z2,
		L0TXTLTLPLATENCY => z4,
		L0TXTLTLPREQ => z1_0,
		L0TXTLTLPREQEND => z1_0,
		L0TXTLTLPWIDTH => z1_0,
		L0UCBYPFOUND => OPEN4,
		L0UCORDFOUND => OPEN4,
		L0UNLOCKRECEIVED => L0UNLOCKRECEIVED,
		L0UPSTREAMRXPORTINL0S => z1_0,
		L0VC0PREVIEWEXPAND => z1_0,
		L0WAKEN => z1_1,
		LLKRX4DWHEADERN => OPEN1,
		LLKRXCHCOMPLETIONAVAILABLEN => LLKRXCHCOMPLETIONAVAILABLEN,
		LLKRXCHCOMPLETIONPARTIALN => OPEN8,
		LLKRXCHCONFIGAVAILABLEN => OPEN1,
		LLKRXCHCONFIGPARTIALN => OPEN1,
		LLKRXCHFIFO => LLKRXCHFIFO,
		LLKRXCHNONPOSTEDAVAILABLEN => LLKRXCHNONPOSTEDAVAILABLEN,
		LLKRXCHNONPOSTEDPARTIALN => OPEN8,
		LLKRXCHPOSTEDAVAILABLEN => LLKRXCHPOSTEDAVAILABLEN,
		LLKRXCHPOSTEDPARTIALN => OPEN8,
		LLKRXCHTC => LLKRXCHTC,
		LLKRXDATA => LLKRXDATA,
                LLKRXDSTCONTREQN => LLKRXDSTCONTREQN,
		LLKRXDSTREQN => LLKRXDSTREQN,
		LLKRXECRCBADN => OPEN1,
		LLKRXEOFN => LLKRXEOFN,
		LLKRXEOPN => LLKRXEOPN,
		LLKRXPREFERREDTYPE => LLKRXPREFERREDTYPE,
		LLKRXSOFN => LLKRXSOFN,
		LLKRXSOPN => LLKRXSOPN,
		LLKRXSRCDSCN => OPEN1,
		LLKRXSRCLASTREQN => LLKRXSRCLASTREQN,
		LLKRXSRCRDYN => LLKRXSRCRDYN,
		LLKRXVALIDN => LLKRXVALIDN,
		LLKTCSTATUS => LLKTCSTATUS,
		LLKTX4DWHEADERN => z1_1,
		LLKTXCHANSPACE => LLKTXCHANSPACE,
		LLKTXCHCOMPLETIONREADYN => LLKTXCHCOMPLETIONREADYN,
		LLKTXCHFIFO => LLKTXCHFIFO,
		LLKTXCHNONPOSTEDREADYN => LLKTXCHNONPOSTEDREADYN,
		LLKTXCHPOSTEDREADYN => LLKTXCHPOSTEDREADYN,
		LLKTXCHTC => LLKTXCHTC,
		LLKTXCOMPLETEN => z1_1,
		LLKTXCONFIGREADYN => LLKTXCONFIGREADYN,
		LLKTXCREATEECRCN => z1_1,
		LLKTXDATA => LLKTXDATA,
		LLKTXDSTRDYN => LLKTXDSTRDYN,
		LLKTXENABLEN => LLKTXENABLEN,
		LLKTXEOFN => LLKTXEOFN,
		LLKTXEOPN => LLKTXEOPN,
		LLKTXSOFN => LLKTXSOFN,
		LLKTXSOPN => LLKTXSOPN,
		LLKTXSRCDSCN => LLKTXSRCDSCN,
		LLKTXSRCRDYN => LLKTXSRCRDYN,
		MAINPOWER => z1_1,
		MAXPAYLOADSIZE => MAXPAYLOADSIZE,
		MAXREADREQUESTSIZE => MAXREADREQUESTSIZE,
		MEMSPACEENABLE => MEMSPACEENABLE,
		MGMTADDR => MGMTADDR,
		MGMTBWREN => MGMTBWREN,
		MGMTPSO => MGMTPSO,
		MGMTRDATA => MGMTRDATA,
		MGMTRDEN => MGMTRDEN,
		MGMTSTATSCREDIT => MGMTSTATSCREDIT,
		MGMTSTATSCREDITSEL => MGMTSTATSCREDITSEL,
		MGMTWDATA => MGMTWDATA,
		MGMTWREN => MGMTWREN,
		MIMDLLBRADD => MIMDLLBRADD,
		MIMDLLBRDATA => MIMDLLBRDATA,
		MIMDLLBREN => MIMDLLBREN,
		MIMDLLBWADD => MIMDLLBWADD,
		MIMDLLBWDATA => MIMDLLBWDATA,
		MIMDLLBWEN => MIMDLLBWEN,
		MIMRXBRADD => MIMRXBRADD,
		MIMRXBRDATA => MIMRXBRDATA,
		MIMRXBREN => MIMRXBREN,
		MIMRXBWADD => MIMRXBWADD,
		MIMRXBWDATA => MIMRXBWDATA,
		MIMRXBWEN => MIMRXBWEN,
		MIMTXBRADD => MIMTXBRADD,
		MIMTXBRDATA => MIMTXBRDATA,
		MIMTXBREN => MIMTXBREN,
		MIMTXBWADD => MIMTXBWADD,
		MIMTXBWDATA => MIMTXBWDATA,
		MIMTXBWEN => MIMTXBWEN,
		PARITYERRORRESPONSE => PARITYERRORRESPONSE,
		PIPEDESKEWLANESL0 => PIPEDESKEWLANESL0,
		PIPEDESKEWLANESL1 => PIPEDESKEWLANESL1,
		PIPEDESKEWLANESL2 => PIPEDESKEWLANESL2,
		PIPEDESKEWLANESL3 => PIPEDESKEWLANESL3,
		PIPEDESKEWLANESL4 => PIPEDESKEWLANESL4,
		PIPEDESKEWLANESL5 => PIPEDESKEWLANESL5,
		PIPEDESKEWLANESL6 => PIPEDESKEWLANESL6,
		PIPEDESKEWLANESL7 => PIPEDESKEWLANESL7,
		PIPEPHYSTATUSL0 => PIPEPHYSTATUSL0,
		PIPEPHYSTATUSL1 => PIPEPHYSTATUSL1,
		PIPEPHYSTATUSL2 => PIPEPHYSTATUSL2,
		PIPEPHYSTATUSL3 => PIPEPHYSTATUSL3,
		PIPEPHYSTATUSL4 => PIPEPHYSTATUSL4,
		PIPEPHYSTATUSL5 => PIPEPHYSTATUSL5,
		PIPEPHYSTATUSL6 => PIPEPHYSTATUSL6,
		PIPEPHYSTATUSL7 => PIPEPHYSTATUSL7,
		PIPEPOWERDOWNL0 => PIPEPOWERDOWNL0,
		PIPEPOWERDOWNL1 => PIPEPOWERDOWNL1,
		PIPEPOWERDOWNL2 => PIPEPOWERDOWNL2,
		PIPEPOWERDOWNL3 => PIPEPOWERDOWNL3,
		PIPEPOWERDOWNL4 => PIPEPOWERDOWNL4,
		PIPEPOWERDOWNL5 => PIPEPOWERDOWNL5,
		PIPEPOWERDOWNL6 => PIPEPOWERDOWNL6,
		PIPEPOWERDOWNL7 => PIPEPOWERDOWNL7,
		PIPERESETL0 => PIPERESETL0,
		PIPERESETL1 => PIPERESETL1,
		PIPERESETL2 => PIPERESETL2,
		PIPERESETL3 => PIPERESETL3,
		PIPERESETL4 => PIPERESETL4,
		PIPERESETL5 => PIPERESETL5,
		PIPERESETL6 => PIPERESETL6,
		PIPERESETL7 => PIPERESETL7,
		PIPERXCHANISALIGNEDL0 => PIPERXCHANISALIGNEDL0,
		PIPERXCHANISALIGNEDL1 => PIPERXCHANISALIGNEDL1,
		PIPERXCHANISALIGNEDL2 => PIPERXCHANISALIGNEDL2,
		PIPERXCHANISALIGNEDL3 => PIPERXCHANISALIGNEDL3,
		PIPERXCHANISALIGNEDL4 => PIPERXCHANISALIGNEDL4,
		PIPERXCHANISALIGNEDL5 => PIPERXCHANISALIGNEDL5,
		PIPERXCHANISALIGNEDL6 => PIPERXCHANISALIGNEDL6,
		PIPERXCHANISALIGNEDL7 => PIPERXCHANISALIGNEDL7,
		PIPERXDATAKL0 => PIPERXDATAKL0,
		PIPERXDATAKL1 => PIPERXDATAKL1,
		PIPERXDATAKL2 => PIPERXDATAKL2,
		PIPERXDATAKL3 => PIPERXDATAKL3,
		PIPERXDATAKL4 => PIPERXDATAKL4,
		PIPERXDATAKL5 => PIPERXDATAKL5,
		PIPERXDATAKL6 => PIPERXDATAKL6,
		PIPERXDATAKL7 => PIPERXDATAKL7,
		PIPERXDATAL0 => PIPERXDATAL0,
		PIPERXDATAL1 => PIPERXDATAL1,
		PIPERXDATAL2 => PIPERXDATAL2,
		PIPERXDATAL3 => PIPERXDATAL3,
		PIPERXDATAL4 => PIPERXDATAL4,
		PIPERXDATAL5 => PIPERXDATAL5,
		PIPERXDATAL6 => PIPERXDATAL6,
		PIPERXDATAL7 => PIPERXDATAL7,
		PIPERXELECIDLEL0 => PIPERXELECIDLEL0,
		PIPERXELECIDLEL1 => PIPERXELECIDLEL1,
		PIPERXELECIDLEL2 => PIPERXELECIDLEL2,
		PIPERXELECIDLEL3 => PIPERXELECIDLEL3,
		PIPERXELECIDLEL4 => PIPERXELECIDLEL4,
		PIPERXELECIDLEL5 => PIPERXELECIDLEL5,
		PIPERXELECIDLEL6 => PIPERXELECIDLEL6,
		PIPERXELECIDLEL7 => PIPERXELECIDLEL7,
		PIPERXPOLARITYL0 => PIPERXPOLARITYL0,
		PIPERXPOLARITYL1 => PIPERXPOLARITYL1,
		PIPERXPOLARITYL2 => PIPERXPOLARITYL2,
		PIPERXPOLARITYL3 => PIPERXPOLARITYL3,
		PIPERXPOLARITYL4 => PIPERXPOLARITYL4,
		PIPERXPOLARITYL5 => PIPERXPOLARITYL5,
		PIPERXPOLARITYL6 => PIPERXPOLARITYL6,
		PIPERXPOLARITYL7 => PIPERXPOLARITYL7,
		PIPERXSTATUSL0 => PIPERXSTATUSL0,
		PIPERXSTATUSL1 => PIPERXSTATUSL1,
		PIPERXSTATUSL2 => PIPERXSTATUSL2,
		PIPERXSTATUSL3 => PIPERXSTATUSL3,
		PIPERXSTATUSL4 => PIPERXSTATUSL4,
		PIPERXSTATUSL5 => PIPERXSTATUSL5,
		PIPERXSTATUSL6 => PIPERXSTATUSL6,
		PIPERXSTATUSL7 => PIPERXSTATUSL7,
		PIPERXVALIDL0 => PIPERXVALIDL0,
		PIPERXVALIDL1 => PIPERXVALIDL1,
		PIPERXVALIDL2 => PIPERXVALIDL2,
		PIPERXVALIDL3 => PIPERXVALIDL3,
		PIPERXVALIDL4 => PIPERXVALIDL4,
		PIPERXVALIDL5 => PIPERXVALIDL5,
		PIPERXVALIDL6 => PIPERXVALIDL6,
		PIPERXVALIDL7 => PIPERXVALIDL7,
		PIPETXCOMPLIANCEL0 => PIPETXCOMPLIANCEL0,
		PIPETXCOMPLIANCEL1 => PIPETXCOMPLIANCEL1,
		PIPETXCOMPLIANCEL2 => PIPETXCOMPLIANCEL2,
		PIPETXCOMPLIANCEL3 => PIPETXCOMPLIANCEL3,
		PIPETXCOMPLIANCEL4 => PIPETXCOMPLIANCEL4,
		PIPETXCOMPLIANCEL5 => PIPETXCOMPLIANCEL5,
		PIPETXCOMPLIANCEL6 => PIPETXCOMPLIANCEL6,
		PIPETXCOMPLIANCEL7 => PIPETXCOMPLIANCEL7,
		PIPETXDATAKL0 => PIPETXDATAKL0,
		PIPETXDATAKL1 => PIPETXDATAKL1,
		PIPETXDATAKL2 => PIPETXDATAKL2,
		PIPETXDATAKL3 => PIPETXDATAKL3,
		PIPETXDATAKL4 => PIPETXDATAKL4,
		PIPETXDATAKL5 => PIPETXDATAKL5,
		PIPETXDATAKL6 => PIPETXDATAKL6,
		PIPETXDATAKL7 => PIPETXDATAKL7,
		PIPETXDATAL0 => PIPETXDATAL0,
		PIPETXDATAL1 => PIPETXDATAL1,
		PIPETXDATAL2 => PIPETXDATAL2,
		PIPETXDATAL3 => PIPETXDATAL3,
		PIPETXDATAL4 => PIPETXDATAL4,
		PIPETXDATAL5 => PIPETXDATAL5,
		PIPETXDATAL6 => PIPETXDATAL6,
		PIPETXDATAL7 => PIPETXDATAL7,
                PIPETXDETECTRXLOOPBACKL0 => PIPETXDETECTRXLOOPBACKL0,
		PIPETXDETECTRXLOOPBACKL1 => PIPETXDETECTRXLOOPBACKL1,
		PIPETXDETECTRXLOOPBACKL2 => PIPETXDETECTRXLOOPBACKL2,
		PIPETXDETECTRXLOOPBACKL3 => PIPETXDETECTRXLOOPBACKL3,
		PIPETXDETECTRXLOOPBACKL4 => PIPETXDETECTRXLOOPBACKL4,
		PIPETXDETECTRXLOOPBACKL5 => PIPETXDETECTRXLOOPBACKL5,
		PIPETXDETECTRXLOOPBACKL6 => PIPETXDETECTRXLOOPBACKL6,
		PIPETXDETECTRXLOOPBACKL7 => PIPETXDETECTRXLOOPBACKL7,
		PIPETXELECIDLEL0 => PIPETXELECIDLEL0,
		PIPETXELECIDLEL1 => PIPETXELECIDLEL1,
		PIPETXELECIDLEL2 => PIPETXELECIDLEL2,
		PIPETXELECIDLEL3 => PIPETXELECIDLEL3,
		PIPETXELECIDLEL4 => PIPETXELECIDLEL4,
		PIPETXELECIDLEL5 => PIPETXELECIDLEL5,
		PIPETXELECIDLEL6 => PIPETXELECIDLEL6,
		PIPETXELECIDLEL7 => PIPETXELECIDLEL7,
		SERRENABLE => SERRENABLE,
		URREPORTINGENABLE => URREPORTINGENABLE

);

end PCIE_EP_V;
