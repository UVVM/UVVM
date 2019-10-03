-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/SMODEL/PPC405_ADV.vhd,v 1.2 2010/06/23 21:46:18 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Power PC Core
-- /___/   /\     Filename : PPC405_ADV.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:02 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.



-------------------------------------------------------------------------------
-- Model for fpga_startup_virtex4 (for simulation only)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity fpga_startup_virtex4 is

    port (
          bus_reset : out std_ulogic;
          ghigh_b : out std_ulogic;
          done : out std_ulogic;
          gsr : out std_ulogic;
          gwe : out std_ulogic;
          gts_b : out std_ulogic;

          shutdown : in std_ulogic;
          cclk : in std_ulogic;
          por : in std_ulogic
          );
end fpga_startup_virtex4;

architecture fpga_startup_virtex4_v of fpga_startup_virtex4 is
    signal count_changed : boolean := false;
begin
set_output:process(cclk, por)
  variable abus_reset : std_ulogic := '0';
  variable aghigh_b : std_ulogic := '0';
  variable agsr : std_ulogic := '0';
  variable adone : std_ulogic := '0'; 
  variable agwe : std_ulogic := '0';    
  variable agts_b : std_ulogic := '0';
  variable count : integer := 0;
  variable count_last_value : integer := 0;

begin
  if (((cclk'event) and (cclk = '1') and (cclk'last_value = '0')) or ((por'event) and (por = '1') and (por'last_value = '0')))then
    
          count_last_value := count;
    if (por = '1') then
      count := 0;
    elsif ((shutdown ='1') and (count > 0)) then
      count := count - 1;
    elsif ((shutdown ='0') and (count < 255)) then
      count := count + 1;
    end if;
   if(count_last_value /= count) then
     count_changed <= true;
   end if;  


    if (por = '1') then
      bus_reset <= '0';
      ghigh_b <=  '0';
      gsr <= '0';
      done <= '0'; 
      gwe <= '0';
      gts_b <= '0'; 
 
    else

      bus_reset <= abus_reset;
      ghigh_b <=  aghigh_b;
      gsr <= agsr;
      done <= adone; 
      gwe <= agwe;
      gts_b <= agts_b;

    end if;
  end if;
    if(count_last_value /= count) then
      abus_reset := '1';
      aghigh_b := '0';
      agsr := '0';
      adone := '0';
      agwe := '0';
      agts_b := '0';     
     if (count >= 02) then
       abus_reset := '0';
     end if;  
     if ((count = 23) or (count = 24)) then
       agsr := '1';
     end if;  
     if (count > 39) then
         aghigh_b := '1';
     end if;
     if (count > 49) then
        adone := '1';   
     end if;

     if ((count = 51) or (count = 52)) then
       agsr := '1';
     end if;        
     if (count > 54) then
        agwe := '1';   
     end if;
     if (count > 55) then
        agts_b := '1';   
     end if;
    end if;      
end process set_output;


end fpga_startup_virtex4_v;

----- CELL PPC405_ADV -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.VCOMPONENTS.all;

library secureip;
use secureip.all;

entity PPC405_ADV is
generic (
               in_delay : time := 1 ps;
               out_delay : VitalDelayType01 := (100 ps, 100 ps)
--  clk-to-output path delays
        );  
port (
		APUFCMDECODED : out std_ulogic;
		APUFCMDECUDI : out std_logic_vector(0 to 2);
		APUFCMDECUDIVALID : out std_ulogic;
		APUFCMENDIAN : out std_ulogic;
		APUFCMFLUSH : out std_ulogic;
		APUFCMINSTRUCTION : out std_logic_vector(0 to 31);
		APUFCMINSTRVALID : out std_ulogic;
		APUFCMLOADBYTEEN : out std_logic_vector(0 to 3);
		APUFCMLOADDATA : out std_logic_vector(0 to 31);
		APUFCMLOADDVALID : out std_ulogic;
		APUFCMOPERANDVALID : out std_ulogic;
		APUFCMRADATA : out std_logic_vector(0 to 31);
		APUFCMRBDATA : out std_logic_vector(0 to 31);
		APUFCMWRITEBACKOK : out std_ulogic;
		APUFCMXERCA : out std_ulogic;
		C405CPMCORESLEEPREQ : out std_ulogic;
		C405CPMMSRCE : out std_ulogic;
		C405CPMMSREE : out std_ulogic;
		C405CPMTIMERIRQ : out std_ulogic;
		C405CPMTIMERRESETREQ : out std_ulogic;
		C405DBGLOADDATAONAPUDBUS : out std_ulogic;
		C405DBGMSRWE : out std_ulogic;
		C405DBGSTOPACK : out std_ulogic;
		C405DBGWBCOMPLETE : out std_ulogic;
		C405DBGWBFULL : out std_ulogic;
		C405DBGWBIAR : out std_logic_vector(0 to 29);
		C405JTGCAPTUREDR : out std_ulogic;
		C405JTGEXTEST : out std_ulogic;
		C405JTGPGMOUT : out std_ulogic;
		C405JTGSHIFTDR : out std_ulogic;
		C405JTGTDO : out std_ulogic;
		C405JTGTDOEN : out std_ulogic;
		C405JTGUPDATEDR : out std_ulogic;
		C405PLBDCUABORT : out std_ulogic;
		C405PLBDCUABUS : out std_logic_vector(0 to 31);
		C405PLBDCUBE : out std_logic_vector(0 to 7);
		C405PLBDCUCACHEABLE : out std_ulogic;
		C405PLBDCUGUARDED : out std_ulogic;
		C405PLBDCUPRIORITY : out std_logic_vector(0 to 1);
		C405PLBDCUREQUEST : out std_ulogic;
		C405PLBDCURNW : out std_ulogic;
		C405PLBDCUSIZE2 : out std_ulogic;
		C405PLBDCUU0ATTR : out std_ulogic;
		C405PLBDCUWRDBUS : out std_logic_vector(0 to 63);
		C405PLBDCUWRITETHRU : out std_ulogic;
		C405PLBICUABORT : out std_ulogic;
		C405PLBICUABUS : out std_logic_vector(0 to 29);
		C405PLBICUCACHEABLE : out std_ulogic;
		C405PLBICUPRIORITY : out std_logic_vector(0 to 1);
		C405PLBICUREQUEST : out std_ulogic;
		C405PLBICUSIZE : out std_logic_vector(2 to 3);
		C405PLBICUU0ATTR : out std_ulogic;
		C405RSTCHIPRESETREQ : out std_ulogic;
		C405RSTCORERESETREQ : out std_ulogic;
		C405RSTSYSRESETREQ : out std_ulogic;
		C405TRCCYCLE : out std_ulogic;
		C405TRCEVENEXECUTIONSTATUS : out std_logic_vector(0 to 1);
		C405TRCODDEXECUTIONSTATUS : out std_logic_vector(0 to 1);
		C405TRCTRACESTATUS : out std_logic_vector(0 to 3);
		C405TRCTRIGGEREVENTOUT : out std_ulogic;
		C405TRCTRIGGEREVENTTYPE : out std_logic_vector(0 to 10);
		C405XXXMACHINECHECK : out std_ulogic;
		DCREMACABUS : out std_logic_vector(8 to 9);
		DCREMACCLK : out std_ulogic;
		DCREMACDBUS : out std_logic_vector(0 to 31);
		DCREMACENABLER : out std_ulogic;
		DCREMACREAD : out std_ulogic;
		DCREMACWRITE : out std_ulogic;
		DSOCMBRAMABUS : out std_logic_vector(8 to 29);
		DSOCMBRAMBYTEWRITE : out std_logic_vector(0 to 3);
		DSOCMBRAMEN : out std_ulogic;
		DSOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
		DSOCMBUSY : out std_ulogic;
		DSOCMRDADDRVALID : out std_ulogic;
		DSOCMWRADDRVALID : out std_ulogic;
		EXTDCRABUS : out std_logic_vector(0 to 9);
		EXTDCRDBUSOUT : out std_logic_vector(0 to 31);
		EXTDCRREAD : out std_ulogic;
		EXTDCRWRITE : out std_ulogic;
		ISOCMBRAMEN : out std_ulogic;
		ISOCMBRAMEVENWRITEEN : out std_ulogic;
		ISOCMBRAMODDWRITEEN : out std_ulogic;
		ISOCMBRAMRDABUS : out std_logic_vector(8 to 28);
		ISOCMBRAMWRABUS : out std_logic_vector(8 to 28);
		ISOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
		ISOCMDCRBRAMEVENEN : out std_ulogic;
		ISOCMDCRBRAMODDEN : out std_ulogic;
		ISOCMDCRBRAMRDSELECT : out std_ulogic;

		BRAMDSOCMCLK : in std_ulogic;
		BRAMDSOCMRDDBUS : in std_logic_vector(0 to 31);
		BRAMISOCMCLK : in std_ulogic;
		BRAMISOCMDCRRDDBUS : in std_logic_vector(0 to 31);
		BRAMISOCMRDDBUS : in std_logic_vector(0 to 63);
		CPMC405CLOCK : in std_ulogic;
		CPMC405CORECLKINACTIVE : in std_ulogic;
		CPMC405CPUCLKEN : in std_ulogic;
		CPMC405JTAGCLKEN : in std_ulogic;
		CPMC405SYNCBYPASS : in std_ulogic;
		CPMC405TIMERCLKEN : in std_ulogic;
		CPMC405TIMERTICK : in std_ulogic;
		CPMDCRCLK : in std_ulogic;
		CPMFCMCLK : in std_ulogic;
		DBGC405DEBUGHALT : in std_ulogic;
		DBGC405EXTBUSHOLDACK : in std_ulogic;
		DBGC405UNCONDDEBUGEVENT : in std_ulogic;
		DSARCVALUE : in std_logic_vector(0 to 7);
		DSCNTLVALUE : in std_logic_vector(0 to 7);
		DSOCMRWCOMPLETE : in std_ulogic;
		EICC405CRITINPUTIRQ : in std_ulogic;
		EICC405EXTINPUTIRQ : in std_ulogic;
		EMACDCRACK : in std_ulogic;
		EMACDCRDBUS : in std_logic_vector(0 to 31);
		EXTDCRACK : in std_ulogic;
		EXTDCRDBUSIN : in std_logic_vector(0 to 31);
		FCMAPUCR : in std_logic_vector(0 to 3);
		FCMAPUDCDCREN : in std_ulogic;
		FCMAPUDCDFORCEALIGN : in std_ulogic;
		FCMAPUDCDFORCEBESTEERING : in std_ulogic;
		FCMAPUDCDFPUOP : in std_ulogic;
		FCMAPUDCDGPRWRITE : in std_ulogic;
		FCMAPUDCDLDSTBYTE : in std_ulogic;
		FCMAPUDCDLDSTDW : in std_ulogic;
		FCMAPUDCDLDSTHW : in std_ulogic;
		FCMAPUDCDLDSTQW : in std_ulogic;
		FCMAPUDCDLDSTWD : in std_ulogic;
		FCMAPUDCDLOAD : in std_ulogic;
		FCMAPUDCDPRIVOP : in std_ulogic;
		FCMAPUDCDRAEN : in std_ulogic;
		FCMAPUDCDRBEN : in std_ulogic;
		FCMAPUDCDSTORE : in std_ulogic;
		FCMAPUDCDTRAPBE : in std_ulogic;
		FCMAPUDCDTRAPLE : in std_ulogic;
		FCMAPUDCDUPDATE : in std_ulogic;
		FCMAPUDCDXERCAEN : in std_ulogic;
		FCMAPUDCDXEROVEN : in std_ulogic;
		FCMAPUDECODEBUSY : in std_ulogic;
		FCMAPUDONE : in std_ulogic;
		FCMAPUEXCEPTION : in std_ulogic;
		FCMAPUEXEBLOCKINGMCO : in std_ulogic;
		FCMAPUEXECRFIELD : in std_logic_vector(0 to 2);
		FCMAPUEXENONBLOCKINGMCO : in std_ulogic;
		FCMAPUINSTRACK : in std_ulogic;
		FCMAPULOADWAIT : in std_ulogic;
		FCMAPURESULT : in std_logic_vector(0 to 31);
		FCMAPURESULTVALID : in std_ulogic;
		FCMAPUSLEEPNOTREADY : in std_ulogic;
		FCMAPUXERCA : in std_ulogic;
		FCMAPUXEROV : in std_ulogic;
		ISARCVALUE : in std_logic_vector(0 to 7);
		ISCNTLVALUE : in std_logic_vector(0 to 7);
		JTGC405BNDSCANTDO : in std_ulogic;
		JTGC405TCK : in std_ulogic;
		JTGC405TDI : in std_ulogic;
		JTGC405TMS : in std_ulogic;
		JTGC405TRSTNEG : in std_ulogic;
		MCBCPUCLKEN : in std_ulogic;
		MCBJTAGEN : in std_ulogic;
		MCBTIMEREN : in std_ulogic;
		MCPPCRST : in std_ulogic;
		PLBC405DCUADDRACK : in std_ulogic;
		PLBC405DCUBUSY : in std_ulogic;
		PLBC405DCUERR : in std_ulogic;
		PLBC405DCURDDACK : in std_ulogic;
		PLBC405DCURDDBUS : in std_logic_vector(0 to 63);
		PLBC405DCURDWDADDR : in std_logic_vector(1 to 3);
		PLBC405DCUSSIZE1 : in std_ulogic;
		PLBC405DCUWRDACK : in std_ulogic;
		PLBC405ICUADDRACK : in std_ulogic;
		PLBC405ICUBUSY : in std_ulogic;
		PLBC405ICUERR : in std_ulogic;
		PLBC405ICURDDACK : in std_ulogic;
		PLBC405ICURDDBUS : in std_logic_vector(0 to 63);
		PLBC405ICURDWDADDR : in std_logic_vector(1 to 3);
		PLBC405ICUSSIZE1 : in std_ulogic;
		PLBCLK : in std_ulogic;
		RSTC405RESETCHIP : in std_ulogic;
		RSTC405RESETCORE : in std_ulogic;
		RSTC405RESETSYS : in std_ulogic;
		TIEAPUCONTROL : in std_logic_vector(0 to 15);
		TIEAPUUDI1 : in std_logic_vector(0 to 23);
		TIEAPUUDI2 : in std_logic_vector(0 to 23);
		TIEAPUUDI3 : in std_logic_vector(0 to 23);
		TIEAPUUDI4 : in std_logic_vector(0 to 23);
		TIEAPUUDI5 : in std_logic_vector(0 to 23);
		TIEAPUUDI6 : in std_logic_vector(0 to 23);
		TIEAPUUDI7 : in std_logic_vector(0 to 23);
		TIEAPUUDI8 : in std_logic_vector(0 to 23);
		TIEC405DETERMINISTICMULT : in std_ulogic;
		TIEC405DISOPERANDFWD : in std_ulogic;
		TIEC405MMUEN : in std_ulogic;
		TIEDCRADDR : in std_logic_vector(0 to 5);
		TIEPVRBIT10 : in std_ulogic;
		TIEPVRBIT11 : in std_ulogic;
		TIEPVRBIT28 : in std_ulogic;
		TIEPVRBIT29 : in std_ulogic;
		TIEPVRBIT30 : in std_ulogic;
		TIEPVRBIT31 : in std_ulogic;
		TIEPVRBIT8 : in std_ulogic;
		TIEPVRBIT9 : in std_ulogic;
		TRCC405TRACEDISABLE : in std_ulogic;
		TRCC405TRIGGEREVENTIN : in std_ulogic
     );
end PPC405_ADV;

architecture PPC405_ADV_V of PPC405_ADV is
   component PPC405_ADV_SWIFT
     port ( CFG_MCLK : in std_logic;
            BUS_RESET : in std_logic;
            GSR : in std_logic;
            GWE : in std_logic;
            GHIGHB : in std_logic;
            CPMC405CPUCLKEN : in std_logic;
            CPMC405JTAGCLKEN : in std_logic;
            CPMC405TIMERCLKEN : in std_logic;
            C405JTGPGMOUT : out std_logic;
            MCBCPUCLKEN : in std_logic;
            MCBJTAGEN : in std_logic;
            MCBTIMEREN : in std_logic;
            MCPPCRST : in std_logic;
            C405TRCODDEXECUTIONSTATUS : out std_logic_vector(0 to 1);
            C405TRCEVENEXECUTIONSTATUS : out std_logic_vector(0 to 1); 
            CPMC405CLOCK : in std_logic;
            CPMC405CORECLKINACTIVE : in std_logic;
            PLBCLK : in std_logic;
            CPMFCMCLK : in std_logic;
            CPMDCRCLK : in std_logic;
            CPMC405SYNCBYPASS : in std_logic;
            CPMC405TIMERTICK : in std_logic;
            C405CPMMSREE : out std_logic;
            C405CPMMSRCE : out std_logic;
            C405CPMTIMERIRQ : out std_logic;
            C405CPMTIMERRESETREQ : out std_logic;
            C405CPMCORESLEEPREQ : out std_logic;
            TIEC405DISOPERANDFWD : in std_logic;
            TIEC405DETERMINISTICMULT : in std_logic;
            TIEC405MMUEN : in std_logic;
            TIEPVRBIT8 : in std_logic;
            TIEPVRBIT9 : in std_logic;
            TIEPVRBIT10 : in std_logic;
            TIEPVRBIT11 : in std_logic;
            TIEPVRBIT28 : in std_logic;
            TIEPVRBIT29 : in std_logic;
            TIEPVRBIT30 : in std_logic;
            TIEPVRBIT31 : in std_logic;
            C405XXXMACHINECHECK : out std_logic;
            DCREMACENABLER : out std_logic;
            DCREMACCLK : out std_logic;
            DCREMACWRITE : out std_logic;
            DCREMACREAD : out std_logic;
            DCREMACDBUS : out std_logic_vector(0 to 31);
            DCREMACABUS : out std_logic_vector(8 to 9);
            EMACDCRDBUS : in std_logic_vector(0 to 31);
            EMACDCRACK : in std_logic;
            C405RSTCHIPRESETREQ : out std_logic;
            C405RSTCORERESETREQ : out std_logic;
            C405RSTSYSRESETREQ : out std_logic;
            RSTC405RESETCHIP : in std_logic;
            RSTC405RESETCORE : in std_logic;
            RSTC405RESETSYS : in std_logic;
            C405PLBICUREQUEST : out std_logic;
            C405PLBICUPRIORITY : out std_logic_vector(0 to 1);
            C405PLBICUCACHEABLE : out std_logic;
            C405PLBICUABUS : out std_logic_vector(0 to 29);
            C405PLBICUSIZE : out std_logic_vector(2 to 3);
            C405PLBICUABORT : out std_logic;
            C405PLBICUU0ATTR : out std_logic;
            PLBC405ICUADDRACK : in std_logic;
            PLBC405ICUBUSY : in std_logic;
            PLBC405ICUERR : in std_logic;
            PLBC405ICURDDACK : in std_logic;
            PLBC405ICURDDBUS :in std_logic_vector(0 to 63);
            PLBC405ICUSSIZE1 : in std_logic;
            PLBC405ICURDWDADDR : in std_logic_vector(1 to 3);
            C405PLBDCUREQUEST : out std_logic;
            C405PLBDCURNW : out std_logic;
            C405PLBDCUABUS : out std_logic_vector(0 to 31);
            C405PLBDCUBE : out std_logic_vector(0 to 7);
            C405PLBDCUCACHEABLE : out std_logic;
            C405PLBDCUGUARDED : out std_logic;
            C405PLBDCUPRIORITY : out std_logic_vector(0 to 1);
            C405PLBDCUSIZE2 : out std_logic;
            C405PLBDCUABORT : out std_logic;
            C405PLBDCUWRDBUS : out std_logic_vector(0 to 63);
            C405PLBDCUU0ATTR : out std_logic;
            C405PLBDCUWRITETHRU : out std_logic;
            PLBC405DCUADDRACK : in std_logic;
            PLBC405DCUBUSY : in std_logic;
            PLBC405DCUERR : in std_logic;
            PLBC405DCURDDACK : in std_logic;
            PLBC405DCURDDBUS : in std_logic_vector(0 to 63);
            PLBC405DCURDWDADDR : in std_logic_vector(1 to 3);
            PLBC405DCUSSIZE1 : in std_logic;
            PLBC405DCUWRDACK : in std_logic;
            ISOCMBRAMRDABUS : out std_logic_vector(8 to 28);
            ISOCMBRAMWRABUS : out std_logic_vector(8 to 28);
            ISOCMBRAMEN : out std_logic;
            ISOCMBRAMODDWRITEEN : out std_logic;
            ISOCMBRAMEVENWRITEEN : out std_logic;
            ISOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
            ISOCMDCRBRAMEVENEN : out std_logic;
            ISOCMDCRBRAMODDEN : out std_logic;
            ISOCMDCRBRAMRDSELECT : out std_logic;
            BRAMISOCMDCRRDDBUS : in std_logic_vector(0 to 31);
            BRAMISOCMRDDBUS : in std_logic_vector(0 to 63);
            ISARCVALUE : in std_logic_vector(0 to 7);
            ISCNTLVALUE : in std_logic_vector(0 to 7); 
            BRAMISOCMCLK : in std_logic;
            DSOCMBRAMABUS : out std_logic_vector(8 to 29);
            DSOCMBRAMBYTEWRITE : out std_logic_vector(0 to 3);
            DSOCMBRAMEN : out std_logic;
            DSOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
            BRAMDSOCMRDDBUS : in std_logic_vector(0 to 31);
            DSOCMRWCOMPLETE : in std_logic;
            DSOCMBUSY : out std_logic;
            DSOCMWRADDRVALID : out std_logic;
            DSOCMRDADDRVALID : out std_logic;
            TIEDCRADDR : in std_logic_vector(0 to 5);
            DSARCVALUE : in std_logic_vector(0 to 7);
            DSCNTLVALUE : in std_logic_vector(0 to 7);
            BRAMDSOCMCLK : in std_logic;
            EXTDCRREAD : out std_logic;
            EXTDCRWRITE : out std_logic;
            EXTDCRABUS : out std_logic_vector(0 to 9);
            EXTDCRDBUSOUT : out std_logic_vector(0 to 31);
            EXTDCRACK : in std_logic;
            EXTDCRDBUSIN : in std_logic_vector(0 to 31);
            EICC405EXTINPUTIRQ : in std_logic;
            EICC405CRITINPUTIRQ : in std_logic;
            JTGC405BNDSCANTDO : in std_logic;
            JTGC405TCK : in std_logic;
            JTGC405TDI : in std_logic;
            JTGC405TMS : in std_logic;
            JTGC405TRSTNEG : in std_logic;
            C405JTGTDO : out std_logic;
            C405JTGTDOEN : out std_logic;
            C405JTGEXTEST : out std_logic;
            C405JTGCAPTUREDR : out std_logic;
            C405JTGSHIFTDR : out std_logic;
            C405JTGUPDATEDR : out std_logic;
            DBGC405DEBUGHALT : in std_logic;
            DBGC405UNCONDDEBUGEVENT : in std_logic;
            DBGC405EXTBUSHOLDACK : in std_logic;
            C405DBGMSRWE : out std_logic;
            C405DBGSTOPACK : out std_logic;
            C405DBGWBCOMPLETE : out std_logic;
            C405DBGWBFULL : out std_logic;
            C405DBGWBIAR : out std_logic_vector(0 to 29);
            C405TRCTRIGGEREVENTOUT : out std_logic;
            C405TRCTRIGGEREVENTTYPE : out std_logic_vector(0 to 10);
            C405TRCCYCLE : out std_logic;
            C405TRCTRACESTATUS : out std_logic_vector(0 to 3);
            TRCC405TRACEDISABLE : in std_logic;
            TRCC405TRIGGEREVENTIN : in std_logic;
            C405DBGLOADDATAONAPUDBUS : out std_logic;
            APUFCMINSTRUCTION : out std_logic_vector(0 to 31);
            APUFCMRADATA : out std_logic_vector(0 to 31);
            APUFCMRBDATA : out std_logic_vector(0 to 31);
            APUFCMINSTRVALID : out std_logic;
            APUFCMLOADDATA : out std_logic_vector(0 to 31);
            APUFCMOPERANDVALID : out std_logic;
            APUFCMLOADDVALID : out std_logic;
            APUFCMFLUSH : out std_logic;
            APUFCMWRITEBACKOK : out std_logic;
            APUFCMLOADBYTEEN : out std_logic_vector(0 to 3);
            APUFCMENDIAN : out std_logic;
            APUFCMXERCA : out std_logic;
            APUFCMDECODED : out std_logic;
            APUFCMDECUDI : out std_logic_vector(0 to 2);
            APUFCMDECUDIVALID : out std_logic;
            FCMAPUDONE : in std_logic;
            FCMAPURESULT : in std_logic_vector(0 to 31);
            FCMAPURESULTVALID : in std_logic;
            FCMAPUINSTRACK : in std_logic;
            FCMAPUEXCEPTION : in std_logic;
            FCMAPUXERCA : in std_logic;
            FCMAPUXEROV : in std_logic;
            FCMAPUCR : in std_logic_vector(0 to 3);
            FCMAPUDCDFPUOP : in std_logic;
            FCMAPUDCDGPRWRITE : in std_logic;
            FCMAPUDCDRAEN : in std_logic;
            FCMAPUDCDRBEN : in std_logic;
            FCMAPUDCDLOAD : in std_logic;
            FCMAPUDCDSTORE : in std_logic;
            FCMAPUDCDXERCAEN : in std_logic;
            FCMAPUDCDXEROVEN : in std_logic;
            FCMAPUDCDPRIVOP : in std_logic;
            FCMAPUDCDCREN : in std_logic;
            FCMAPUEXECRFIELD : in std_logic_vector(0 to 2);
            FCMAPUDCDUPDATE : in std_logic;
            FCMAPUDCDFORCEALIGN : in std_logic;
            FCMAPUDCDFORCEBESTEERING : in std_logic;
            FCMAPUDCDLDSTBYTE : in std_logic;
            FCMAPUDCDLDSTHW : in std_logic;
            FCMAPUDCDLDSTWD : in std_logic;
            FCMAPUDCDLDSTDW : in std_logic;
            FCMAPUDCDLDSTQW : in std_logic;
            FCMAPUDCDTRAPBE : in std_logic;
            FCMAPUDCDTRAPLE : in std_logic;
            FCMAPUEXEBLOCKINGMCO : in std_logic;
            FCMAPUEXENONBLOCKINGMCO : in std_logic;
            FCMAPUSLEEPNOTREADY : in std_logic;
            FCMAPULOADWAIT : in std_logic;
            FCMAPUDECODEBUSY : in std_logic;
            TIEAPUCONTROL : in std_logic_vector(0 to 15);
            TIEAPUUDI1 : in std_logic_vector(0 to 23);
            TIEAPUUDI2 : in std_logic_vector(0 to 23);
            TIEAPUUDI3 : in std_logic_vector(0 to 23);
            TIEAPUUDI4 : in std_logic_vector(0 to 23);
            TIEAPUUDI5 : in std_logic_vector(0 to 23);
            TIEAPUUDI6 : in std_logic_vector(0 to 23);
            TIEAPUUDI7 : in std_logic_vector(0 to 23);
            TIEAPUUDI8 : in std_logic_vector(0 to 23)
 );  
   end component;
----- component fpga_startup_virtex4            -----
component fpga_startup_virtex4
  port (
    bus_reset : out std_ulogic;
    done      : out std_ulogic;
    ghigh_b   : out std_ulogic;
    gsr       : out std_ulogic;
    gts_b     : out std_ulogic;
    gwe       : out std_ulogic;

    cclk      : in  std_ulogic;
    por       : in  std_ulogic;
    shutdown  : in  std_ulogic
    );
end component;



        signal   APUFCMDECODED_out  :  std_ulogic;
        signal   APUFCMDECUDI_out  :  std_logic_vector(0 to 2);
        signal   APUFCMDECUDIVALID_out  :  std_ulogic;
        signal   APUFCMENDIAN_out  :  std_ulogic;
        signal   APUFCMFLUSH_out  :  std_ulogic;
        signal   APUFCMINSTRUCTION_out  :  std_logic_vector(0 to 31);
        signal   APUFCMINSTRVALID_out  :  std_ulogic;
        signal   APUFCMLOADBYTEEN_out  :  std_logic_vector(0 to 3);
        signal   APUFCMLOADDATA_out  :  std_logic_vector(0 to 31);
        signal   APUFCMLOADDVALID_out  :  std_ulogic;
        signal   APUFCMOPERANDVALID_out  :  std_ulogic;
        signal   APUFCMRADATA_out  :  std_logic_vector(0 to 31);
        signal   APUFCMRBDATA_out  :  std_logic_vector(0 to 31);
        signal   APUFCMWRITEBACKOK_out  :  std_ulogic;
        signal   APUFCMXERCA_out  :  std_ulogic;
        signal   C405CPMCORESLEEPREQ_out  :  std_ulogic;
        signal   C405CPMMSRCE_out  :  std_ulogic;
        signal   C405CPMMSREE_out  :  std_ulogic;
        signal   C405CPMTIMERIRQ_out  :  std_ulogic;
        signal   C405CPMTIMERRESETREQ_out  :  std_ulogic;
        signal   C405DBGLOADDATAONAPUDBUS_out  :  std_ulogic;
        signal   C405DBGMSRWE_out  :  std_ulogic;
        signal   C405DBGSTOPACK_out  :  std_ulogic;
        signal   C405DBGWBCOMPLETE_out  :  std_ulogic;
        signal   C405DBGWBFULL_out  :  std_ulogic;
        signal   C405DBGWBIAR_out  :  std_logic_vector(0 to 29);
        signal   C405JTGCAPTUREDR_out  :  std_ulogic;
        signal   C405JTGEXTEST_out  :  std_ulogic;
        signal   C405JTGPGMOUT_out  :  std_ulogic;
        signal   C405JTGSHIFTDR_out  :  std_ulogic;
        signal   C405JTGTDO_out  :  std_ulogic;
        signal   C405JTGTDOEN_out  :  std_ulogic;
        signal   C405JTGUPDATEDR_out  :  std_ulogic;
        signal   C405PLBDCUABORT_out  :  std_ulogic;
        signal   C405PLBDCUABUS_out  :  std_logic_vector(0 to 31);
        signal   C405PLBDCUBE_out  :  std_logic_vector(0 to 7);
        signal   C405PLBDCUCACHEABLE_out  :  std_ulogic;
        signal   C405PLBDCUGUARDED_out  :  std_ulogic;
        signal   C405PLBDCUPRIORITY_out  :  std_logic_vector(0 to 1);
        signal   C405PLBDCUREQUEST_out  :  std_ulogic;
        signal   C405PLBDCURNW_out  :  std_ulogic;
        signal   C405PLBDCUSIZE2_out  :  std_ulogic;
        signal   C405PLBDCUU0ATTR_out  :  std_ulogic;
        signal   C405PLBDCUWRDBUS_out  :  std_logic_vector(0 to 63);
        signal   C405PLBDCUWRITETHRU_out  :  std_ulogic;
        signal   C405PLBICUABORT_out  :  std_ulogic;
        signal   C405PLBICUABUS_out  :  std_logic_vector(0 to 29);
        signal   C405PLBICUCACHEABLE_out  :  std_ulogic;
        signal   C405PLBICUPRIORITY_out  :  std_logic_vector(0 to 1);
        signal   C405PLBICUREQUEST_out  :  std_ulogic;
        signal   C405PLBICUSIZE_out  :  std_logic_vector(2 to 3);
        signal   C405PLBICUU0ATTR_out  :  std_ulogic;
        signal   C405RSTCHIPRESETREQ_out  :  std_ulogic;
        signal   C405RSTCORERESETREQ_out  :  std_ulogic;
        signal   C405RSTSYSRESETREQ_out  :  std_ulogic;
        signal   C405TRCCYCLE_out  :  std_ulogic;
        signal   C405TRCEVENEXECUTIONSTATUS_out  :  std_logic_vector(0 to 1);
        signal   C405TRCODDEXECUTIONSTATUS_out  :  std_logic_vector(0 to 1);
        signal   C405TRCTRACESTATUS_out  :  std_logic_vector(0 to 3);
        signal   C405TRCTRIGGEREVENTOUT_out  :  std_ulogic;
        signal   C405TRCTRIGGEREVENTTYPE_out  :  std_logic_vector(0 to 10);
        signal   C405XXXMACHINECHECK_out  :  std_ulogic;
        signal   DCREMACENABLER_out  :  std_ulogic;
        signal   DSOCMBRAMABUS_out  :  std_logic_vector(8 to 29);
        signal   DSOCMBRAMBYTEWRITE_out  :  std_logic_vector(0 to 3);
        signal   DSOCMBRAMEN_out  :  std_ulogic;
        signal   DSOCMBRAMWRDBUS_out  :  std_logic_vector(0 to 31);
        signal   DSOCMBUSY_out  :  std_ulogic;
        signal   DSOCMRDADDRVALID_out  :  std_ulogic;
        signal   DSOCMWRADDRVALID_out  :  std_ulogic;
        signal   EXTDCRABUS_out  :  std_logic_vector(0 to 9);
        signal   EXTDCRDBUSOUT_out  :  std_logic_vector(0 to 31);
        signal   EXTDCRREAD_out  :  std_ulogic;
        signal   EXTDCRWRITE_out  :  std_ulogic;
        signal   ISOCMBRAMEN_out  :  std_ulogic;
        signal   ISOCMBRAMEVENWRITEEN_out  :  std_ulogic;
        signal   ISOCMBRAMODDWRITEEN_out  :  std_ulogic;
        signal   ISOCMBRAMRDABUS_out  :  std_logic_vector(8 to 28);
        signal   ISOCMBRAMWRABUS_out  :  std_logic_vector(8 to 28);
        signal   ISOCMBRAMWRDBUS_out  :  std_logic_vector(0 to 31);
        signal   ISOCMDCRBRAMEVENEN_out  :  std_ulogic;
        signal   ISOCMDCRBRAMODDEN_out  :  std_ulogic;
        signal   ISOCMDCRBRAMRDSELECT_out  :  std_ulogic;
        signal   DCREMACWRITE_out  :  std_ulogic;
        signal   DCREMACREAD_out  :  std_ulogic;
        signal   DCREMACDBUS_out  :  std_logic_vector(0 to 31);
        signal   DCREMACABUS_out  :  std_logic_vector(8 to 9);
        signal   DCREMACCLK_out  :  std_ulogic;

        signal   GSR_ipd  :  std_ulogic;
        signal   BRAMDSOCMCLK_ipd  :  std_ulogic;
        signal   BRAMDSOCMRDDBUS_ipd  :  std_logic_vector(0 to 31);
        signal   BRAMISOCMCLK_ipd  :  std_ulogic;
        signal   BRAMISOCMDCRRDDBUS_ipd  :  std_logic_vector(0 to 31);
        signal   BRAMISOCMRDDBUS_ipd  :  std_logic_vector(0 to 63);
        signal   CPMC405CLOCK_ipd  :  std_ulogic;
        signal   CPMC405CORECLKINACTIVE_ipd  :  std_ulogic;
        signal   CPMC405CPUCLKEN_ipd  :  std_ulogic;
        signal   CPMC405JTAGCLKEN_ipd  :  std_ulogic;
        signal   CPMC405SYNCBYPASS_ipd  :  std_ulogic;
        signal   CPMC405TIMERCLKEN_ipd  :  std_ulogic;
        signal   CPMC405TIMERTICK_ipd  :  std_ulogic;
        signal   CPMDCRCLK_ipd  :  std_ulogic;
        signal   CPMFCMCLK_ipd  :  std_ulogic;
        signal   DBGC405DEBUGHALT_ipd  :  std_ulogic;
        signal   DBGC405EXTBUSHOLDACK_ipd  :  std_ulogic;
        signal   DBGC405UNCONDDEBUGEVENT_ipd  :  std_ulogic;
        signal   DSARCVALUE_ipd  :  std_logic_vector(0 to 7);
        signal   DSCNTLVALUE_ipd  :  std_logic_vector(0 to 7);
        signal   DSOCMRWCOMPLETE_ipd  :  std_ulogic;
        signal   EICC405CRITINPUTIRQ_ipd  :  std_ulogic;
        signal   EICC405EXTINPUTIRQ_ipd  :  std_ulogic;
        signal   EXTDCRACK_ipd  :  std_ulogic;
        signal   EXTDCRDBUSIN_ipd  :  std_logic_vector(0 to 31);
        signal   FCMAPUCR_ipd  :  std_logic_vector(0 to 3);
        signal   FCMAPUDCDCREN_ipd  :  std_ulogic;
        signal   FCMAPUDCDFORCEALIGN_ipd  :  std_ulogic;
        signal   FCMAPUDCDFORCEBESTEERING_ipd  :  std_ulogic;
        signal   FCMAPUDCDFPUOP_ipd  :  std_ulogic;
        signal   FCMAPUDCDGPRWRITE_ipd  :  std_ulogic;
        signal   FCMAPUDCDLDSTBYTE_ipd  :  std_ulogic;
        signal   FCMAPUDCDLDSTDW_ipd  :  std_ulogic;
        signal   FCMAPUDCDLDSTHW_ipd  :  std_ulogic;
        signal   FCMAPUDCDLDSTQW_ipd  :  std_ulogic;
        signal   FCMAPUDCDLDSTWD_ipd  :  std_ulogic;
        signal   FCMAPUDCDLOAD_ipd  :  std_ulogic;
        signal   FCMAPUDCDPRIVOP_ipd  :  std_ulogic;
        signal   FCMAPUDCDRAEN_ipd  :  std_ulogic;
        signal   FCMAPUDCDRBEN_ipd  :  std_ulogic;
        signal   FCMAPUDCDSTORE_ipd  :  std_ulogic;
        signal   FCMAPUDCDTRAPBE_ipd  :  std_ulogic;
        signal   FCMAPUDCDTRAPLE_ipd  :  std_ulogic;
        signal   FCMAPUDCDUPDATE_ipd  :  std_ulogic;
        signal   FCMAPUDCDXERCAEN_ipd  :  std_ulogic;
        signal   FCMAPUDCDXEROVEN_ipd  :  std_ulogic;
        signal   FCMAPUDECODEBUSY_ipd  :  std_ulogic;
        signal   FCMAPUDONE_ipd  :  std_ulogic;
        signal   FCMAPUEXCEPTION_ipd  :  std_ulogic;
        signal   FCMAPUEXEBLOCKINGMCO_ipd  :  std_ulogic;
        signal   FCMAPUEXECRFIELD_ipd  :  std_logic_vector(0 to 2);
        signal   FCMAPUEXENONBLOCKINGMCO_ipd  :  std_ulogic;
        signal   FCMAPUINSTRACK_ipd  :  std_ulogic;
        signal   FCMAPULOADWAIT_ipd  :  std_ulogic;
        signal   FCMAPURESULT_ipd  :  std_logic_vector(0 to 31);
        signal   FCMAPURESULTVALID_ipd  :  std_ulogic;
        signal   FCMAPUSLEEPNOTREADY_ipd  :  std_ulogic;
        signal   FCMAPUXERCA_ipd  :  std_ulogic;
        signal   FCMAPUXEROV_ipd  :  std_ulogic;
        signal   ISARCVALUE_ipd  :  std_logic_vector(0 to 7);
        signal   ISCNTLVALUE_ipd  :  std_logic_vector(0 to 7);
        signal   JTGC405BNDSCANTDO_ipd  :  std_ulogic;
        signal   JTGC405TCK_ipd  :  std_ulogic;
        signal   JTGC405TDI_ipd  :  std_ulogic;
        signal   JTGC405TMS_ipd  :  std_ulogic;
        signal   JTGC405TRSTNEG_ipd  :  std_ulogic;
        signal   MCBCPUCLKEN_ipd  :  std_ulogic;
        signal   MCBJTAGEN_ipd  :  std_ulogic;
        signal   MCBTIMEREN_ipd  :  std_ulogic;
        signal   MCPPCRST_ipd  :  std_ulogic;
        signal   PLBC405DCUADDRACK_ipd  :  std_ulogic;
        signal   PLBC405DCUBUSY_ipd  :  std_ulogic;
        signal   PLBC405DCUERR_ipd  :  std_ulogic;
        signal   PLBC405DCURDDACK_ipd  :  std_ulogic;
        signal   PLBC405DCURDDBUS_ipd  :  std_logic_vector(0 to 63);
        signal   PLBC405DCURDWDADDR_ipd  :  std_logic_vector(1 to 3);
        signal   PLBC405DCUSSIZE1_ipd  :  std_ulogic;
        signal   PLBC405DCUWRDACK_ipd  :  std_ulogic;
        signal   PLBC405ICUADDRACK_ipd  :  std_ulogic;
        signal   PLBC405ICUBUSY_ipd  :  std_ulogic;
        signal   PLBC405ICUERR_ipd  :  std_ulogic;
        signal   PLBC405ICURDDACK_ipd  :  std_ulogic;
        signal   PLBC405ICURDDBUS_ipd  :  std_logic_vector(0 to 63);
        signal   PLBC405ICURDWDADDR_ipd  :  std_logic_vector(1 to 3);
        signal   PLBC405ICUSSIZE1_ipd  :  std_ulogic;
        signal   PLBCLK_ipd  :  std_ulogic;
        signal   RSTC405RESETCHIP_ipd  :  std_ulogic;
        signal   RSTC405RESETCORE_ipd  :  std_ulogic;
        signal   RSTC405RESETSYS_ipd  :  std_ulogic;
        signal   TIEAPUCONTROL_ipd  :  std_logic_vector(0 to 15);
        signal   TIEAPUUDI1_ipd  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI2_ipd  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI3_ipd  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI4_ipd  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI5_ipd  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI6_ipd  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI7_ipd  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI8_ipd  :  std_logic_vector(0 to 23);
        signal   TIEC405DETERMINISTICMULT_ipd  :  std_ulogic;
        signal   TIEC405DISOPERANDFWD_ipd  :  std_ulogic;
        signal   TIEC405MMUEN_ipd  :  std_ulogic;
        signal   TIEDCRADDR_ipd  :  std_logic_vector(0 to 5);
        signal   TIEPVRBIT10_ipd  :  std_ulogic;
        signal   TIEPVRBIT11_ipd  :  std_ulogic;
        signal   TIEPVRBIT28_ipd  :  std_ulogic;
        signal   TIEPVRBIT29_ipd  :  std_ulogic;
        signal   TIEPVRBIT30_ipd  :  std_ulogic;
        signal   TIEPVRBIT31_ipd  :  std_ulogic;
        signal   TIEPVRBIT8_ipd  :  std_ulogic;
        signal   TIEPVRBIT9_ipd  :  std_ulogic;
        signal   TRCC405TRACEDISABLE_ipd  :  std_ulogic;
        signal   TRCC405TRIGGEREVENTIN_ipd  :  std_ulogic;
        signal   EMACDCRDBUS_ipd  :  std_logic_vector(0 to 31);
        signal   EMACDCRACK_ipd  :  std_ulogic;

        signal   GSR_ipd_1  :  std_ulogic;
        signal   BRAMDSOCMCLK_ipd_1  :  std_ulogic;
        signal   BRAMDSOCMRDDBUS_ipd_1  :  std_logic_vector(0 to 31);
        signal   BRAMISOCMCLK_ipd_1  :  std_ulogic;
        signal   BRAMISOCMDCRRDDBUS_ipd_1  :  std_logic_vector(0 to 31);
        signal   BRAMISOCMRDDBUS_ipd_1  :  std_logic_vector(0 to 63);
        signal   CPMC405CLOCK_ipd_1  :  std_ulogic;
        signal   CPMC405CORECLKINACTIVE_ipd_1  :  std_ulogic;
        signal   CPMC405CPUCLKEN_ipd_1  :  std_ulogic;
        signal   CPMC405JTAGCLKEN_ipd_1  :  std_ulogic;
        signal   CPMC405SYNCBYPASS_ipd_1  :  std_ulogic;
        signal   CPMC405TIMERCLKEN_ipd_1  :  std_ulogic;
        signal   CPMC405TIMERTICK_ipd_1  :  std_ulogic;
        signal   CPMDCRCLK_ipd_1  :  std_ulogic;
        signal   CPMFCMCLK_ipd_1  :  std_ulogic;
        signal   DBGC405DEBUGHALT_ipd_1  :  std_ulogic;
        signal   DBGC405EXTBUSHOLDACK_ipd_1  :  std_ulogic;
        signal   DBGC405UNCONDDEBUGEVENT_ipd_1  :  std_ulogic;
        signal   DSARCVALUE_ipd_1  :  std_logic_vector(0 to 7);
        signal   DSCNTLVALUE_ipd_1  :  std_logic_vector(0 to 7);
        signal   DSOCMRWCOMPLETE_ipd_1  :  std_ulogic;
        signal   EICC405CRITINPUTIRQ_ipd_1  :  std_ulogic;
        signal   EICC405EXTINPUTIRQ_ipd_1  :  std_ulogic;
        signal   EXTDCRACK_ipd_1  :  std_ulogic;
        signal   EXTDCRDBUSIN_ipd_1  :  std_logic_vector(0 to 31);
        signal   FCMAPUCR_ipd_1  :  std_logic_vector(0 to 3);
        signal   FCMAPUDCDCREN_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDFORCEALIGN_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDFORCEBESTEERING_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDFPUOP_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDGPRWRITE_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDLDSTBYTE_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDLDSTDW_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDLDSTHW_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDLDSTQW_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDLDSTWD_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDLOAD_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDPRIVOP_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDRAEN_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDRBEN_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDSTORE_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDTRAPBE_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDTRAPLE_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDUPDATE_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDXERCAEN_ipd_1  :  std_ulogic;
        signal   FCMAPUDCDXEROVEN_ipd_1  :  std_ulogic;
        signal   FCMAPUDECODEBUSY_ipd_1  :  std_ulogic;
        signal   FCMAPUDONE_ipd_1  :  std_ulogic;
        signal   FCMAPUEXCEPTION_ipd_1  :  std_ulogic;
        signal   FCMAPUEXEBLOCKINGMCO_ipd_1  :  std_ulogic;
        signal   FCMAPUEXECRFIELD_ipd_1  :  std_logic_vector(0 to 2);
        signal   FCMAPUEXENONBLOCKINGMCO_ipd_1  :  std_ulogic;
        signal   FCMAPUINSTRACK_ipd_1  :  std_ulogic;
        signal   FCMAPULOADWAIT_ipd_1  :  std_ulogic;
        signal   FCMAPURESULT_ipd_1  :  std_logic_vector(0 to 31);
        signal   FCMAPURESULTVALID_ipd_1  :  std_ulogic;
        signal   FCMAPUSLEEPNOTREADY_ipd_1  :  std_ulogic;
        signal   FCMAPUXERCA_ipd_1  :  std_ulogic;
        signal   FCMAPUXEROV_ipd_1  :  std_ulogic;
        signal   ISARCVALUE_ipd_1  :  std_logic_vector(0 to 7);
        signal   ISCNTLVALUE_ipd_1  :  std_logic_vector(0 to 7);
        signal   JTGC405BNDSCANTDO_ipd_1  :  std_ulogic;
        signal   JTGC405TCK_ipd_1  :  std_ulogic;
        signal   JTGC405TDI_ipd_1  :  std_ulogic;
        signal   JTGC405TMS_ipd_1  :  std_ulogic;
        signal   JTGC405TRSTNEG_ipd_1  :  std_ulogic;
        signal   MCBCPUCLKEN_ipd_1  :  std_ulogic;
        signal   MCBJTAGEN_ipd_1  :  std_ulogic;
        signal   MCBTIMEREN_ipd_1  :  std_ulogic;
        signal   MCPPCRST_ipd_1  :  std_ulogic;
        signal   PLBC405DCUADDRACK_ipd_1  :  std_ulogic;
        signal   PLBC405DCUBUSY_ipd_1  :  std_ulogic;
        signal   PLBC405DCUERR_ipd_1  :  std_ulogic;
        signal   PLBC405DCURDDACK_ipd_1  :  std_ulogic;
        signal   PLBC405DCURDDBUS_ipd_1  :  std_logic_vector(0 to 63);
        signal   PLBC405DCURDWDADDR_ipd_1  :  std_logic_vector(1 to 3);
        signal   PLBC405DCUSSIZE1_ipd_1  :  std_ulogic;
        signal   PLBC405DCUWRDACK_ipd_1  :  std_ulogic;
        signal   PLBC405ICUADDRACK_ipd_1  :  std_ulogic;
        signal   PLBC405ICUBUSY_ipd_1  :  std_ulogic;
        signal   PLBC405ICUERR_ipd_1  :  std_ulogic;
        signal   PLBC405ICURDDACK_ipd_1  :  std_ulogic;
        signal   PLBC405ICURDDBUS_ipd_1  :  std_logic_vector(0 to 63);
        signal   PLBC405ICURDWDADDR_ipd_1  :  std_logic_vector(1 to 3);
        signal   PLBC405ICUSSIZE1_ipd_1  :  std_ulogic;
        signal   PLBCLK_ipd_1  :  std_ulogic;
        signal   RSTC405RESETCHIP_ipd_1  :  std_ulogic;
        signal   RSTC405RESETCORE_ipd_1  :  std_ulogic;
        signal   RSTC405RESETSYS_ipd_1  :  std_ulogic;
        signal   TIEAPUCONTROL_ipd_1  :  std_logic_vector(0 to 15);
        signal   TIEAPUUDI1_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI2_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI3_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI4_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI5_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI6_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI7_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEAPUUDI8_ipd_1  :  std_logic_vector(0 to 23);
        signal   TIEC405DETERMINISTICMULT_ipd_1  :  std_ulogic;
        signal   TIEC405DISOPERANDFWD_ipd_1  :  std_ulogic;
        signal   TIEC405MMUEN_ipd_1  :  std_ulogic;
        signal   TIEDCRADDR_ipd_1  :  std_logic_vector(0 to 5);
        signal   TIEPVRBIT10_ipd_1  :  std_ulogic;
        signal   TIEPVRBIT11_ipd_1  :  std_ulogic;
        signal   TIEPVRBIT28_ipd_1  :  std_ulogic;
        signal   TIEPVRBIT29_ipd_1  :  std_ulogic;
        signal   TIEPVRBIT30_ipd_1  :  std_ulogic;
        signal   TIEPVRBIT31_ipd_1  :  std_ulogic;
        signal   TIEPVRBIT8_ipd_1  :  std_ulogic;
        signal   TIEPVRBIT9_ipd_1  :  std_ulogic;
        signal   TRCC405TRACEDISABLE_ipd_1  :  std_ulogic;
        signal   TRCC405TRIGGEREVENTIN_ipd_1  :  std_ulogic;
        signal   EMACDCRDBUS_ipd_1  :  std_logic_vector(0 to 31);
        signal   EMACDCRACK_ipd_1  :  std_ulogic;

        signal open_sig : std_ulogic;
        signal VCC_sig : std_ulogic := '1';
        signal GND_sig : std_ulogic := '0';

        signal FPGA_CCLK : std_ulogic := '0';
        signal FPGA_POR : std_ulogic := '1';
        signal FPGA_BUS_RESET : std_ulogic := '0';
        signal FPGA_GWE : std_ulogic := '0';
        signal FPGA_GHIGHB : std_ulogic := '0';
        signal FPGA_GSR  : std_ulogic := '0';
        signal GSR_OR : std_ulogic := '0';
        signal GSR  : std_ulogic := '0';
        signal FPGA_SHUTDOWN  : std_ulogic := '0';

        signal FPGA_CCLK_delay : std_ulogic := '0';
        signal FPGA_BUS_RESET_delay : std_ulogic := '0';
        signal GSR_delay  : std_ulogic := '0';
        signal FPGA_GWE_delay : std_ulogic := '0';
        signal FPGA_GHIGHB_delay : std_ulogic := '0';
        signal FPGA_CCLK_reg : std_ulogic := '0';
          
--        signal ppcuser_binary : std_logic_vector(0 to 3) := PPCUSER;  


begin
		BRAMDSOCMCLK_ipd <= BRAMDSOCMCLK;
		BRAMDSOCMRDDBUS_ipd <= BRAMDSOCMRDDBUS after 0 ps;
		BRAMISOCMCLK_ipd <= BRAMISOCMCLK;
		BRAMISOCMDCRRDDBUS_ipd <= BRAMISOCMDCRRDDBUS after 0 ps;
		BRAMISOCMRDDBUS_ipd <= BRAMISOCMRDDBUS after 0 ps;
		CPMC405CLOCK_ipd <= CPMC405CLOCK;
		CPMC405CORECLKINACTIVE_ipd <= CPMC405CORECLKINACTIVE after 0 ps;
		CPMC405CPUCLKEN_ipd <= CPMC405CPUCLKEN after 0 ps;
		CPMC405JTAGCLKEN_ipd <= CPMC405JTAGCLKEN after 0 ps;
		CPMC405SYNCBYPASS_ipd <= CPMC405SYNCBYPASS after 0 ps;
		CPMC405TIMERCLKEN_ipd <= CPMC405TIMERCLKEN after 0 ps;
		CPMC405TIMERTICK_ipd <= CPMC405TIMERTICK after 0 ps;
		CPMDCRCLK_ipd <= CPMDCRCLK;
		CPMFCMCLK_ipd <= CPMFCMCLK;
		DBGC405DEBUGHALT_ipd <= DBGC405DEBUGHALT after 0 ps;
		DBGC405EXTBUSHOLDACK_ipd <= DBGC405EXTBUSHOLDACK after 0 ps;
		DBGC405UNCONDDEBUGEVENT_ipd <= DBGC405UNCONDDEBUGEVENT after 0 ps;
		DSARCVALUE_ipd <= DSARCVALUE after 0 ps;
		DSCNTLVALUE_ipd <= DSCNTLVALUE after 0 ps;
		DSOCMRWCOMPLETE_ipd <= DSOCMRWCOMPLETE after 0 ps;
		EICC405CRITINPUTIRQ_ipd <= EICC405CRITINPUTIRQ after 0 ps;
		EICC405EXTINPUTIRQ_ipd <= EICC405EXTINPUTIRQ after 0 ps;
		EMACDCRACK_ipd <= EMACDCRACK after 0 ps;
		EMACDCRDBUS_ipd <= EMACDCRDBUS after 0 ps;
		EXTDCRACK_ipd <= EXTDCRACK after 0 ps;
		EXTDCRDBUSIN_ipd <= EXTDCRDBUSIN after 0 ps;
		FCMAPUCR_ipd <= FCMAPUCR after 0 ps;
		FCMAPUDCDCREN_ipd <= FCMAPUDCDCREN after 0 ps;
		FCMAPUDCDFORCEALIGN_ipd <= FCMAPUDCDFORCEALIGN after 0 ps;
		FCMAPUDCDFORCEBESTEERING_ipd <= FCMAPUDCDFORCEBESTEERING after 0 ps;
		FCMAPUDCDFPUOP_ipd <= FCMAPUDCDFPUOP after 0 ps;
		FCMAPUDCDGPRWRITE_ipd <= FCMAPUDCDGPRWRITE after 0 ps;
		FCMAPUDCDLDSTBYTE_ipd <= FCMAPUDCDLDSTBYTE after 0 ps;
		FCMAPUDCDLDSTDW_ipd <= FCMAPUDCDLDSTDW after 0 ps;
		FCMAPUDCDLDSTHW_ipd <= FCMAPUDCDLDSTHW after 0 ps;
		FCMAPUDCDLDSTQW_ipd <= FCMAPUDCDLDSTQW after 0 ps;
		FCMAPUDCDLDSTWD_ipd <= FCMAPUDCDLDSTWD after 0 ps;
		FCMAPUDCDLOAD_ipd <= FCMAPUDCDLOAD after 0 ps;
		FCMAPUDCDPRIVOP_ipd <= FCMAPUDCDPRIVOP after 0 ps;
		FCMAPUDCDRAEN_ipd <= FCMAPUDCDRAEN after 0 ps;
		FCMAPUDCDRBEN_ipd <= FCMAPUDCDRBEN after 0 ps;
		FCMAPUDCDSTORE_ipd <= FCMAPUDCDSTORE after 0 ps;
		FCMAPUDCDTRAPBE_ipd <= FCMAPUDCDTRAPBE after 0 ps;
		FCMAPUDCDTRAPLE_ipd <= FCMAPUDCDTRAPLE after 0 ps;
		FCMAPUDCDUPDATE_ipd <= FCMAPUDCDUPDATE after 0 ps;
		FCMAPUDCDXERCAEN_ipd <= FCMAPUDCDXERCAEN after 0 ps;
		FCMAPUDCDXEROVEN_ipd <= FCMAPUDCDXEROVEN after 0 ps;
		FCMAPUDECODEBUSY_ipd <= FCMAPUDECODEBUSY after 0 ps;
		FCMAPUDONE_ipd <= FCMAPUDONE after 0 ps;
		FCMAPUEXCEPTION_ipd <= FCMAPUEXCEPTION after 0 ps;
		FCMAPUEXEBLOCKINGMCO_ipd <= FCMAPUEXEBLOCKINGMCO after 0 ps;
		FCMAPUEXECRFIELD_ipd <= FCMAPUEXECRFIELD after 0 ps;
		FCMAPUEXENONBLOCKINGMCO_ipd <= FCMAPUEXENONBLOCKINGMCO after 0 ps;
		FCMAPUINSTRACK_ipd <= FCMAPUINSTRACK after 0 ps;
		FCMAPULOADWAIT_ipd <= FCMAPULOADWAIT after 0 ps;
		FCMAPURESULT_ipd <= FCMAPURESULT after 0 ps;
		FCMAPURESULTVALID_ipd <= FCMAPURESULTVALID after 0 ps;
		FCMAPUSLEEPNOTREADY_ipd <= FCMAPUSLEEPNOTREADY after 0 ps;
		FCMAPUXERCA_ipd <= FCMAPUXERCA after 0 ps;
		FCMAPUXEROV_ipd <= FCMAPUXEROV after 0 ps;
		ISARCVALUE_ipd <= ISARCVALUE after 0 ps;
		ISCNTLVALUE_ipd <= ISCNTLVALUE after 0 ps;
		JTGC405BNDSCANTDO_ipd <= JTGC405BNDSCANTDO after 0 ps;
		JTGC405TCK_ipd <= JTGC405TCK;
		JTGC405TDI_ipd <= JTGC405TDI after 0 ps;
		JTGC405TMS_ipd <= JTGC405TMS after 0 ps;
		JTGC405TRSTNEG_ipd <= JTGC405TRSTNEG after 0 ps;
		MCBCPUCLKEN_ipd <= MCBCPUCLKEN after 0 ps;
		MCBJTAGEN_ipd <= MCBJTAGEN after 0 ps;
		MCBTIMEREN_ipd <= MCBTIMEREN after 0 ps;
		MCPPCRST_ipd <= MCPPCRST after 0 ps;
		PLBC405DCUADDRACK_ipd <= PLBC405DCUADDRACK after 0 ps;
		PLBC405DCUBUSY_ipd <= PLBC405DCUBUSY after 0 ps;
		PLBC405DCUERR_ipd <= PLBC405DCUERR after 0 ps;
		PLBC405DCURDDACK_ipd <= PLBC405DCURDDACK after 0 ps;
		PLBC405DCURDDBUS_ipd <= PLBC405DCURDDBUS after 0 ps;
		PLBC405DCURDWDADDR_ipd <= PLBC405DCURDWDADDR after 0 ps;
		PLBC405DCUSSIZE1_ipd <= PLBC405DCUSSIZE1 after 0 ps;
		PLBC405DCUWRDACK_ipd <= PLBC405DCUWRDACK after 0 ps;
		PLBC405ICUADDRACK_ipd <= PLBC405ICUADDRACK after 0 ps;
		PLBC405ICUBUSY_ipd <= PLBC405ICUBUSY after 0 ps;
		PLBC405ICUERR_ipd <= PLBC405ICUERR after 0 ps;
		PLBC405ICURDDACK_ipd <= PLBC405ICURDDACK after 0 ps;
		PLBC405ICURDDBUS_ipd <= PLBC405ICURDDBUS after 0 ps;
		PLBC405ICURDWDADDR_ipd <= PLBC405ICURDWDADDR after 0 ps;
		PLBC405ICUSSIZE1_ipd <= PLBC405ICUSSIZE1 after 0 ps;
		PLBCLK_ipd <= PLBCLK;
		RSTC405RESETCHIP_ipd <= RSTC405RESETCHIP after 0 ps;
		RSTC405RESETCORE_ipd <= RSTC405RESETCORE after 0 ps;
		RSTC405RESETSYS_ipd <= RSTC405RESETSYS after 0 ps;
		TIEAPUCONTROL_ipd <= TIEAPUCONTROL after 0 ps;
		TIEAPUUDI1_ipd <= TIEAPUUDI1 after 0 ps;
		TIEAPUUDI2_ipd <= TIEAPUUDI2 after 0 ps;
		TIEAPUUDI3_ipd <= TIEAPUUDI3 after 0 ps;
		TIEAPUUDI4_ipd <= TIEAPUUDI4 after 0 ps;
		TIEAPUUDI5_ipd <= TIEAPUUDI5 after 0 ps;
		TIEAPUUDI6_ipd <= TIEAPUUDI6 after 0 ps;
		TIEAPUUDI7_ipd <= TIEAPUUDI7 after 0 ps;
		TIEAPUUDI8_ipd <= TIEAPUUDI8 after 0 ps;
		TIEC405DETERMINISTICMULT_ipd <= TIEC405DETERMINISTICMULT after 0 ps;
		TIEC405DISOPERANDFWD_ipd <= TIEC405DISOPERANDFWD after 0 ps;
		TIEC405MMUEN_ipd <= TIEC405MMUEN after 0 ps;
		TIEDCRADDR_ipd <= TIEDCRADDR after 0 ps;
		TIEPVRBIT10_ipd <= TIEPVRBIT10 after 0 ps;
		TIEPVRBIT11_ipd <= TIEPVRBIT11 after 0 ps;
		TIEPVRBIT28_ipd <= TIEPVRBIT28 after 0 ps;
		TIEPVRBIT29_ipd <= TIEPVRBIT29 after 0 ps;
		TIEPVRBIT30_ipd <= TIEPVRBIT30 after 0 ps;
		TIEPVRBIT31_ipd <= TIEPVRBIT31 after 0 ps;
		TIEPVRBIT8_ipd <= TIEPVRBIT8 after 0 ps;
		TIEPVRBIT9_ipd <= TIEPVRBIT9 after 0 ps;
		TRCC405TRACEDISABLE_ipd <= TRCC405TRACEDISABLE after 0 ps;
		TRCC405TRIGGEREVENTIN_ipd <= TRCC405TRIGGEREVENTIN after 0 ps;

		BRAMDSOCMCLK_ipd_1 <= BRAMDSOCMCLK_ipd;
		BRAMDSOCMRDDBUS_ipd_1 <= BRAMDSOCMRDDBUS_ipd after in_delay;
		BRAMISOCMCLK_ipd_1 <= BRAMISOCMCLK_ipd;
		BRAMISOCMDCRRDDBUS_ipd_1 <= BRAMISOCMDCRRDDBUS_ipd after in_delay;
		BRAMISOCMRDDBUS_ipd_1 <= BRAMISOCMRDDBUS_ipd after in_delay;
		CPMC405CLOCK_ipd_1 <= CPMC405CLOCK_ipd;
		CPMC405CORECLKINACTIVE_ipd_1 <= CPMC405CORECLKINACTIVE_ipd after in_delay;
		CPMC405CPUCLKEN_ipd_1 <= CPMC405CPUCLKEN_ipd after in_delay;
		CPMC405JTAGCLKEN_ipd_1 <= CPMC405JTAGCLKEN_ipd after in_delay;
		CPMC405SYNCBYPASS_ipd_1 <= CPMC405SYNCBYPASS_ipd after in_delay;
		CPMC405TIMERCLKEN_ipd_1 <= CPMC405TIMERCLKEN_ipd after in_delay;
		CPMC405TIMERTICK_ipd_1 <= CPMC405TIMERTICK_ipd after in_delay;
		CPMDCRCLK_ipd_1 <= CPMDCRCLK_ipd;
		CPMFCMCLK_ipd_1 <= CPMFCMCLK_ipd;
		DBGC405DEBUGHALT_ipd_1 <= DBGC405DEBUGHALT_ipd after in_delay;
		DBGC405EXTBUSHOLDACK_ipd_1 <= DBGC405EXTBUSHOLDACK_ipd after in_delay;
		DBGC405UNCONDDEBUGEVENT_ipd_1 <= DBGC405UNCONDDEBUGEVENT_ipd after in_delay;
		DSARCVALUE_ipd_1 <= DSARCVALUE_ipd after in_delay;
		DSCNTLVALUE_ipd_1 <= DSCNTLVALUE_ipd after in_delay;
		DSOCMRWCOMPLETE_ipd_1 <= DSOCMRWCOMPLETE_ipd after in_delay;
		EICC405CRITINPUTIRQ_ipd_1 <= EICC405CRITINPUTIRQ_ipd after in_delay;
		EICC405EXTINPUTIRQ_ipd_1 <= EICC405EXTINPUTIRQ_ipd after in_delay;
		EMACDCRACK_ipd_1 <= EMACDCRACK_ipd after in_delay;
		EMACDCRDBUS_ipd_1 <= EMACDCRDBUS_ipd after in_delay;
		EXTDCRACK_ipd_1 <= EXTDCRACK_ipd after in_delay;
		EXTDCRDBUSIN_ipd_1 <= EXTDCRDBUSIN_ipd after in_delay;
		FCMAPUCR_ipd_1 <= FCMAPUCR_ipd after in_delay;
		FCMAPUDCDCREN_ipd_1 <= FCMAPUDCDCREN_ipd after in_delay;
		FCMAPUDCDFORCEALIGN_ipd_1 <= FCMAPUDCDFORCEALIGN_ipd after in_delay;
		FCMAPUDCDFORCEBESTEERING_ipd_1 <= FCMAPUDCDFORCEBESTEERING_ipd after in_delay;
		FCMAPUDCDFPUOP_ipd_1 <= FCMAPUDCDFPUOP_ipd after in_delay;
		FCMAPUDCDGPRWRITE_ipd_1 <= FCMAPUDCDGPRWRITE_ipd after in_delay;
		FCMAPUDCDLDSTBYTE_ipd_1 <= FCMAPUDCDLDSTBYTE_ipd after in_delay;
		FCMAPUDCDLDSTDW_ipd_1 <= FCMAPUDCDLDSTDW_ipd after in_delay;
		FCMAPUDCDLDSTHW_ipd_1 <= FCMAPUDCDLDSTHW_ipd after in_delay;
		FCMAPUDCDLDSTQW_ipd_1 <= FCMAPUDCDLDSTQW_ipd after in_delay;
		FCMAPUDCDLDSTWD_ipd_1 <= FCMAPUDCDLDSTWD_ipd after in_delay;
		FCMAPUDCDLOAD_ipd_1 <= FCMAPUDCDLOAD_ipd after in_delay;
		FCMAPUDCDPRIVOP_ipd_1 <= FCMAPUDCDPRIVOP_ipd after in_delay;
		FCMAPUDCDRAEN_ipd_1 <= FCMAPUDCDRAEN_ipd after in_delay;
		FCMAPUDCDRBEN_ipd_1 <= FCMAPUDCDRBEN_ipd after in_delay;
		FCMAPUDCDSTORE_ipd_1 <= FCMAPUDCDSTORE_ipd after in_delay;
		FCMAPUDCDTRAPBE_ipd_1 <= FCMAPUDCDTRAPBE_ipd after in_delay;
		FCMAPUDCDTRAPLE_ipd_1 <= FCMAPUDCDTRAPLE_ipd after in_delay;
		FCMAPUDCDUPDATE_ipd_1 <= FCMAPUDCDUPDATE_ipd after in_delay;
		FCMAPUDCDXERCAEN_ipd_1 <= FCMAPUDCDXERCAEN_ipd after in_delay;
		FCMAPUDCDXEROVEN_ipd_1 <= FCMAPUDCDXEROVEN_ipd after in_delay;
		FCMAPUDECODEBUSY_ipd_1 <= FCMAPUDECODEBUSY_ipd after in_delay;
		FCMAPUDONE_ipd_1 <= FCMAPUDONE_ipd after in_delay;
		FCMAPUEXCEPTION_ipd_1 <= FCMAPUEXCEPTION_ipd after in_delay;
		FCMAPUEXEBLOCKINGMCO_ipd_1 <= FCMAPUEXEBLOCKINGMCO_ipd after in_delay;
		FCMAPUEXECRFIELD_ipd_1 <= FCMAPUEXECRFIELD_ipd after in_delay;
		FCMAPUEXENONBLOCKINGMCO_ipd_1 <= FCMAPUEXENONBLOCKINGMCO_ipd after in_delay;
		FCMAPUINSTRACK_ipd_1 <= FCMAPUINSTRACK_ipd after in_delay;
		FCMAPULOADWAIT_ipd_1 <= FCMAPULOADWAIT_ipd after in_delay;
		FCMAPURESULT_ipd_1 <= FCMAPURESULT_ipd after in_delay;
		FCMAPURESULTVALID_ipd_1 <= FCMAPURESULTVALID_ipd after in_delay;
		FCMAPUSLEEPNOTREADY_ipd_1 <= FCMAPUSLEEPNOTREADY_ipd after in_delay;
		FCMAPUXERCA_ipd_1 <= FCMAPUXERCA_ipd after in_delay;
		FCMAPUXEROV_ipd_1 <= FCMAPUXEROV_ipd after in_delay;
		ISARCVALUE_ipd_1 <= ISARCVALUE_ipd after in_delay;
		ISCNTLVALUE_ipd_1 <= ISCNTLVALUE_ipd after in_delay;
		JTGC405BNDSCANTDO_ipd_1 <= JTGC405BNDSCANTDO_ipd after in_delay;
		JTGC405TCK_ipd_1 <= JTGC405TCK_ipd;
		JTGC405TDI_ipd_1 <= JTGC405TDI_ipd after in_delay;
		JTGC405TMS_ipd_1 <= JTGC405TMS_ipd after in_delay;
		JTGC405TRSTNEG_ipd_1 <= JTGC405TRSTNEG_ipd after in_delay;
		MCBCPUCLKEN_ipd_1 <= MCBCPUCLKEN_ipd after in_delay;
		MCBJTAGEN_ipd_1 <= MCBJTAGEN_ipd after in_delay;
		MCBTIMEREN_ipd_1 <= MCBTIMEREN_ipd after in_delay;
		MCPPCRST_ipd_1 <= MCPPCRST_ipd after in_delay;
		PLBC405DCUADDRACK_ipd_1 <= PLBC405DCUADDRACK_ipd after in_delay;
		PLBC405DCUBUSY_ipd_1 <= PLBC405DCUBUSY_ipd after in_delay;
		PLBC405DCUERR_ipd_1 <= PLBC405DCUERR_ipd after in_delay;
		PLBC405DCURDDACK_ipd_1 <= PLBC405DCURDDACK_ipd after in_delay;
		PLBC405DCURDDBUS_ipd_1 <= PLBC405DCURDDBUS_ipd after in_delay;
		PLBC405DCURDWDADDR_ipd_1 <= PLBC405DCURDWDADDR_ipd after in_delay;
		PLBC405DCUSSIZE1_ipd_1 <= PLBC405DCUSSIZE1_ipd after in_delay;
		PLBC405DCUWRDACK_ipd_1 <= PLBC405DCUWRDACK_ipd after in_delay;
		PLBC405ICUADDRACK_ipd_1 <= PLBC405ICUADDRACK_ipd after in_delay;
		PLBC405ICUBUSY_ipd_1 <= PLBC405ICUBUSY_ipd after in_delay;
		PLBC405ICUERR_ipd_1 <= PLBC405ICUERR_ipd after in_delay;
		PLBC405ICURDDACK_ipd_1 <= PLBC405ICURDDACK_ipd after in_delay;
		PLBC405ICURDDBUS_ipd_1 <= PLBC405ICURDDBUS_ipd after in_delay;
		PLBC405ICURDWDADDR_ipd_1 <= PLBC405ICURDWDADDR_ipd after in_delay;
		PLBC405ICUSSIZE1_ipd_1 <= PLBC405ICUSSIZE1_ipd after in_delay;
		PLBCLK_ipd_1 <= PLBCLK_ipd;
		RSTC405RESETCHIP_ipd_1 <= RSTC405RESETCHIP_ipd after in_delay;
		RSTC405RESETCORE_ipd_1 <= RSTC405RESETCORE_ipd after in_delay;
		RSTC405RESETSYS_ipd_1 <= RSTC405RESETSYS_ipd after in_delay;
		TIEAPUCONTROL_ipd_1 <= TIEAPUCONTROL_ipd after in_delay;
		TIEAPUUDI1_ipd_1 <= TIEAPUUDI1_ipd after in_delay;
		TIEAPUUDI2_ipd_1 <= TIEAPUUDI2_ipd after in_delay;
		TIEAPUUDI3_ipd_1 <= TIEAPUUDI3_ipd after in_delay;
		TIEAPUUDI4_ipd_1 <= TIEAPUUDI4_ipd after in_delay;
		TIEAPUUDI5_ipd_1 <= TIEAPUUDI5_ipd after in_delay;
		TIEAPUUDI6_ipd_1 <= TIEAPUUDI6_ipd after in_delay;
		TIEAPUUDI7_ipd_1 <= TIEAPUUDI7_ipd after in_delay;
		TIEAPUUDI8_ipd_1 <= TIEAPUUDI8_ipd after in_delay;
		TIEC405DETERMINISTICMULT_ipd_1 <= TIEC405DETERMINISTICMULT_ipd after in_delay;
		TIEC405DISOPERANDFWD_ipd_1 <= TIEC405DISOPERANDFWD_ipd after in_delay;
		TIEC405MMUEN_ipd_1 <= TIEC405MMUEN_ipd after in_delay;
		TIEDCRADDR_ipd_1 <= TIEDCRADDR_ipd after in_delay;
		TIEPVRBIT10_ipd_1 <= TIEPVRBIT10_ipd after in_delay;
		TIEPVRBIT11_ipd_1 <= TIEPVRBIT11_ipd after in_delay;
		TIEPVRBIT28_ipd_1 <= TIEPVRBIT28_ipd after in_delay;
		TIEPVRBIT29_ipd_1 <= TIEPVRBIT29_ipd after in_delay;
		TIEPVRBIT30_ipd_1 <= TIEPVRBIT30_ipd after in_delay;
		TIEPVRBIT31_ipd_1 <= TIEPVRBIT31_ipd after in_delay;
		TIEPVRBIT8_ipd_1 <= TIEPVRBIT8_ipd after in_delay;
		TIEPVRBIT9_ipd_1 <= TIEPVRBIT9_ipd after in_delay;
		TRCC405TRACEDISABLE_ipd_1 <= TRCC405TRACEDISABLE_ipd after in_delay;
		TRCC405TRIGGEREVENTIN_ipd_1 <= TRCC405TRIGGEREVENTIN_ipd after in_delay;                
  
   ppc405_adv_swift_bw_1 : PPC405_ADV_SWIFT
      port map (
            CFG_MCLK => FPGA_CCLK,
            BUS_RESET => FPGA_BUS_RESET_delay,
            GSR => GSR_delay,
            GWE => FPGA_GWE_delay,
            GHIGHB => FPGA_GHIGHB_delay,
            
            CPMC405CPUCLKEN => CPMC405CPUCLKEN_ipd_1,
            CPMC405JTAGCLKEN => CPMC405JTAGCLKEN_ipd_1,
            CPMC405TIMERCLKEN => CPMC405TIMERCLKEN_ipd_1,
            C405JTGPGMOUT => C405JTGPGMOUT_out,
            MCBCPUCLKEN => MCBCPUCLKEN_ipd_1,
            MCBJTAGEN => MCBJTAGEN_ipd_1,
            MCBTIMEREN => MCBTIMEREN_ipd_1,
            MCPPCRST => MCPPCRST_ipd_1,
            C405TRCODDEXECUTIONSTATUS => C405TRCODDEXECUTIONSTATUS_out,
            C405TRCEVENEXECUTIONSTATUS => C405TRCEVENEXECUTIONSTATUS_out,
            CPMC405CLOCK => CPMC405CLOCK_ipd_1,
            CPMC405CORECLKINACTIVE => CPMC405CORECLKINACTIVE_ipd_1,
            PLBCLK => PLBCLK_ipd_1,
            CPMFCMCLK => CPMFCMCLK_ipd_1,
            CPMDCRCLK => CPMDCRCLK_ipd_1,
            CPMC405SYNCBYPASS => CPMC405SYNCBYPASS_ipd_1,
            CPMC405TIMERTICK => CPMC405TIMERTICK_ipd_1,
            C405CPMMSREE => C405CPMMSREE_out,
            C405CPMMSRCE => C405CPMMSRCE_out,
            C405CPMTIMERIRQ => C405CPMTIMERIRQ_out,
            C405CPMTIMERRESETREQ => C405CPMTIMERRESETREQ_out,
            C405CPMCORESLEEPREQ => C405CPMCORESLEEPREQ_out,
            TIEC405DISOPERANDFWD => TIEC405DISOPERANDFWD_ipd_1,
            TIEC405DETERMINISTICMULT => TIEC405DETERMINISTICMULT_ipd_1,
            TIEC405MMUEN => TIEC405MMUEN_ipd_1,
            TIEPVRBIT8 => TIEPVRBIT8_ipd_1,
            TIEPVRBIT9 => TIEPVRBIT9_ipd_1,
            TIEPVRBIT10 => TIEPVRBIT10_ipd_1,
            TIEPVRBIT11 => TIEPVRBIT11_ipd_1,
            TIEPVRBIT28 => TIEPVRBIT28_ipd_1,
            TIEPVRBIT29 => TIEPVRBIT29_ipd_1,
            TIEPVRBIT30 => TIEPVRBIT30_ipd_1,
            TIEPVRBIT31 => TIEPVRBIT31_ipd_1,
            C405XXXMACHINECHECK => C405XXXMACHINECHECK_out,
            DCREMACENABLER => DCREMACENABLER_out,
            DCREMACCLK => DCREMACCLK_out,
            DCREMACWRITE => DCREMACWRITE_out,
            DCREMACREAD => DCREMACREAD_out,
            DCREMACDBUS => DCREMACDBUS_out,
            DCREMACABUS => DCREMACABUS_out,
            EMACDCRDBUS => EMACDCRDBUS_ipd_1,
            EMACDCRACK => EMACDCRACK_ipd_1,
            C405RSTCHIPRESETREQ => C405RSTCHIPRESETREQ_out,
            C405RSTCORERESETREQ => C405RSTCORERESETREQ_out,
            C405RSTSYSRESETREQ => C405RSTSYSRESETREQ_out,
            RSTC405RESETCHIP => RSTC405RESETCHIP_ipd_1,
            RSTC405RESETCORE => RSTC405RESETCORE_ipd_1,
            RSTC405RESETSYS => RSTC405RESETSYS_ipd_1,
            C405PLBICUREQUEST => C405PLBICUREQUEST_out,
            C405PLBICUPRIORITY => C405PLBICUPRIORITY_out,
            C405PLBICUCACHEABLE => C405PLBICUCACHEABLE_out,
            C405PLBICUABUS => C405PLBICUABUS_out,
            C405PLBICUSIZE => C405PLBICUSIZE_out,
            C405PLBICUABORT => C405PLBICUABORT_out,
            C405PLBICUU0ATTR => C405PLBICUU0ATTR_out,
            PLBC405ICUADDRACK => PLBC405ICUADDRACK_ipd_1,
            PLBC405ICUBUSY => PLBC405ICUBUSY_ipd_1,
            PLBC405ICUERR => PLBC405ICUERR_ipd_1,
            PLBC405ICURDDACK => PLBC405ICURDDACK_ipd_1,
            PLBC405ICURDDBUS => PLBC405ICURDDBUS_ipd_1,
            PLBC405ICUSSIZE1 => PLBC405ICUSSIZE1_ipd_1,
            PLBC405ICURDWDADDR => PLBC405ICURDWDADDR_ipd_1,
            C405PLBDCUREQUEST => C405PLBDCUREQUEST_out,
            C405PLBDCURNW => C405PLBDCURNW_out,
            C405PLBDCUABUS => C405PLBDCUABUS_out,
            C405PLBDCUBE => C405PLBDCUBE_out,
            C405PLBDCUCACHEABLE => C405PLBDCUCACHEABLE_out,
            C405PLBDCUGUARDED => C405PLBDCUGUARDED_out,
            C405PLBDCUPRIORITY => C405PLBDCUPRIORITY_out,
            C405PLBDCUSIZE2 => C405PLBDCUSIZE2_out,
            C405PLBDCUABORT => C405PLBDCUABORT_out,
            C405PLBDCUWRDBUS => C405PLBDCUWRDBUS_out,
            C405PLBDCUU0ATTR => C405PLBDCUU0ATTR_out,
            C405PLBDCUWRITETHRU => C405PLBDCUWRITETHRU_out,
            PLBC405DCUADDRACK => PLBC405DCUADDRACK_ipd_1,
            PLBC405DCUBUSY => PLBC405DCUBUSY_ipd_1,
            PLBC405DCUERR => PLBC405DCUERR_ipd_1,
            PLBC405DCURDDACK => PLBC405DCURDDACK_ipd_1,
            PLBC405DCURDDBUS => PLBC405DCURDDBUS_ipd_1,
            PLBC405DCURDWDADDR => PLBC405DCURDWDADDR_ipd_1,
            PLBC405DCUSSIZE1 => PLBC405DCUSSIZE1_ipd_1,
            PLBC405DCUWRDACK => PLBC405DCUWRDACK_ipd_1,
            ISOCMBRAMRDABUS => ISOCMBRAMRDABUS_out,
            ISOCMBRAMWRABUS => ISOCMBRAMWRABUS_out,
            ISOCMBRAMEN => ISOCMBRAMEN_out,
            ISOCMBRAMODDWRITEEN => ISOCMBRAMODDWRITEEN_out,
            ISOCMBRAMEVENWRITEEN => ISOCMBRAMEVENWRITEEN_out,
            ISOCMBRAMWRDBUS => ISOCMBRAMWRDBUS_out,
            ISOCMDCRBRAMEVENEN => ISOCMDCRBRAMEVENEN_out,
            ISOCMDCRBRAMODDEN => ISOCMDCRBRAMODDEN_out,
            ISOCMDCRBRAMRDSELECT => ISOCMDCRBRAMRDSELECT_out,
            BRAMISOCMDCRRDDBUS => BRAMISOCMDCRRDDBUS_ipd_1,
            BRAMISOCMRDDBUS => BRAMISOCMRDDBUS_ipd_1,
            ISARCVALUE => ISARCVALUE_ipd_1,
            ISCNTLVALUE => ISCNTLVALUE_ipd_1,
            BRAMISOCMCLK => BRAMISOCMCLK_ipd_1,
            DSOCMBRAMABUS => DSOCMBRAMABUS_out,
            DSOCMBRAMBYTEWRITE => DSOCMBRAMBYTEWRITE_out,
            DSOCMBRAMEN => DSOCMBRAMEN_out,
            DSOCMBRAMWRDBUS => DSOCMBRAMWRDBUS_out,
            BRAMDSOCMRDDBUS => BRAMDSOCMRDDBUS_ipd_1,
            DSOCMRWCOMPLETE => DSOCMRWCOMPLETE_ipd_1,
            DSOCMBUSY => DSOCMBUSY_out,
            DSOCMWRADDRVALID => DSOCMWRADDRVALID_out,
            DSOCMRDADDRVALID => DSOCMRDADDRVALID_out,
            TIEDCRADDR => TIEDCRADDR_ipd_1,
            DSARCVALUE => DSARCVALUE_ipd_1,
            DSCNTLVALUE => DSCNTLVALUE_ipd_1,
            BRAMDSOCMCLK => BRAMDSOCMCLK_ipd_1,
            EXTDCRREAD => EXTDCRREAD_out,
            EXTDCRWRITE => EXTDCRWRITE_out,
            EXTDCRABUS => EXTDCRABUS_out,
            EXTDCRDBUSOUT => EXTDCRDBUSOUT_out,
            EXTDCRACK => EXTDCRACK_ipd_1,
            EXTDCRDBUSIN => EXTDCRDBUSIN_ipd_1,
            EICC405EXTINPUTIRQ => EICC405EXTINPUTIRQ_ipd_1,
            EICC405CRITINPUTIRQ => EICC405CRITINPUTIRQ_ipd_1,
            JTGC405BNDSCANTDO => JTGC405BNDSCANTDO_ipd_1,
            JTGC405TCK => JTGC405TCK_ipd_1,
            JTGC405TDI => JTGC405TDI_ipd_1,
            JTGC405TMS => JTGC405TMS,
            JTGC405TRSTNEG => JTGC405TRSTNEG_ipd_1,
            C405JTGTDO => C405JTGTDO_out,
            C405JTGTDOEN => C405JTGTDOEN_out,
            C405JTGEXTEST => C405JTGEXTEST_out,
            C405JTGCAPTUREDR => C405JTGCAPTUREDR_out,
            C405JTGSHIFTDR => C405JTGSHIFTDR_out,
            C405JTGUPDATEDR => C405JTGUPDATEDR_out,
            DBGC405DEBUGHALT => DBGC405DEBUGHALT_ipd_1,
            DBGC405UNCONDDEBUGEVENT => DBGC405UNCONDDEBUGEVENT_ipd_1,
            DBGC405EXTBUSHOLDACK => DBGC405EXTBUSHOLDACK_ipd_1,
            C405DBGMSRWE => C405DBGMSRWE_out,
            C405DBGSTOPACK => C405DBGSTOPACK_out,
            C405DBGWBCOMPLETE => C405DBGWBCOMPLETE_out,
            C405DBGWBFULL => C405DBGWBFULL_out,
            C405DBGWBIAR => C405DBGWBIAR_out,
            C405TRCTRIGGEREVENTOUT => C405TRCTRIGGEREVENTOUT_out,
            C405TRCTRIGGEREVENTTYPE => C405TRCTRIGGEREVENTTYPE_out,
            C405TRCCYCLE => C405TRCCYCLE_out,
            C405TRCTRACESTATUS => C405TRCTRACESTATUS_out,
            TRCC405TRACEDISABLE => TRCC405TRACEDISABLE_ipd_1,
            TRCC405TRIGGEREVENTIN => TRCC405TRIGGEREVENTIN_ipd_1,
            C405DBGLOADDATAONAPUDBUS => C405DBGLOADDATAONAPUDBUS_out,
            APUFCMINSTRUCTION => APUFCMINSTRUCTION_out,
            APUFCMRADATA => APUFCMRADATA_out,
            APUFCMRBDATA => APUFCMRBDATA_out,
            APUFCMINSTRVALID => APUFCMINSTRVALID_out,
            APUFCMLOADDATA => APUFCMLOADDATA_out,
            APUFCMOPERANDVALID => APUFCMOPERANDVALID_out,
            APUFCMLOADDVALID => APUFCMLOADDVALID_out,
            APUFCMFLUSH => APUFCMFLUSH_out,
            APUFCMWRITEBACKOK => APUFCMWRITEBACKOK_out,
            APUFCMLOADBYTEEN => APUFCMLOADBYTEEN_out,
            APUFCMENDIAN => APUFCMENDIAN_out,
            APUFCMXERCA => APUFCMXERCA_out,
            APUFCMDECODED => APUFCMDECODED_out,
            APUFCMDECUDI => APUFCMDECUDI_out,
            APUFCMDECUDIVALID => APUFCMDECUDIVALID_out,
            FCMAPUDONE => FCMAPUDONE_ipd_1,
            FCMAPURESULT => FCMAPURESULT_ipd_1,
            FCMAPURESULTVALID => FCMAPURESULTVALID_ipd_1,
            FCMAPUINSTRACK => FCMAPUINSTRACK_ipd_1,
            FCMAPUEXCEPTION => FCMAPUEXCEPTION_ipd_1,
            FCMAPUXERCA => FCMAPUXERCA_ipd_1,
            FCMAPUXEROV => FCMAPUXEROV_ipd_1,
            FCMAPUCR => FCMAPUCR_ipd_1,
            FCMAPUDCDFPUOP => FCMAPUDCDFPUOP_ipd_1,
            FCMAPUDCDGPRWRITE => FCMAPUDCDGPRWRITE_ipd_1,
            FCMAPUDCDRAEN => FCMAPUDCDRAEN_ipd_1,
            FCMAPUDCDRBEN => FCMAPUDCDRBEN_ipd_1,
            FCMAPUDCDLOAD => FCMAPUDCDLOAD_ipd_1,
            FCMAPUDCDSTORE => FCMAPUDCDSTORE_ipd_1,
            FCMAPUDCDXERCAEN => FCMAPUDCDXERCAEN_ipd_1,
            FCMAPUDCDXEROVEN => FCMAPUDCDXEROVEN_ipd_1,
            FCMAPUDCDPRIVOP => FCMAPUDCDPRIVOP_ipd_1,
            FCMAPUDCDCREN => FCMAPUDCDCREN_ipd_1,
            FCMAPUEXECRFIELD => FCMAPUEXECRFIELD_ipd_1,
            FCMAPUDCDUPDATE => FCMAPUDCDUPDATE_ipd_1,
            FCMAPUDCDFORCEALIGN => FCMAPUDCDFORCEALIGN_ipd_1,
            FCMAPUDCDFORCEBESTEERING => FCMAPUDCDFORCEBESTEERING_ipd_1,
            FCMAPUDCDLDSTBYTE => FCMAPUDCDLDSTBYTE_ipd_1,
            FCMAPUDCDLDSTHW => FCMAPUDCDLDSTHW_ipd_1,
            FCMAPUDCDLDSTWD => FCMAPUDCDLDSTWD_ipd_1,
            FCMAPUDCDLDSTDW => FCMAPUDCDLDSTDW_ipd_1,
            FCMAPUDCDLDSTQW => FCMAPUDCDLDSTQW_ipd_1,
            FCMAPUDCDTRAPBE => FCMAPUDCDTRAPBE_ipd_1,
            FCMAPUDCDTRAPLE => FCMAPUDCDTRAPLE_ipd_1,
            FCMAPUEXEBLOCKINGMCO => FCMAPUEXEBLOCKINGMCO_ipd_1,
            FCMAPUEXENONBLOCKINGMCO => FCMAPUEXENONBLOCKINGMCO_ipd_1,
            FCMAPUSLEEPNOTREADY => FCMAPUSLEEPNOTREADY_ipd_1,
            FCMAPULOADWAIT => FCMAPULOADWAIT_ipd_1,
            FCMAPUDECODEBUSY => FCMAPUDECODEBUSY_ipd_1,
            TIEAPUCONTROL => TIEAPUCONTROL_ipd_1,
            TIEAPUUDI1 => TIEAPUUDI1_ipd_1,
            TIEAPUUDI2 => TIEAPUUDI2_ipd_1,
            TIEAPUUDI3 => TIEAPUUDI3_ipd_1,
            TIEAPUUDI4 => TIEAPUUDI4_ipd_1,
            TIEAPUUDI5 => TIEAPUUDI5_ipd_1,
            TIEAPUUDI6 => TIEAPUUDI6_ipd_1,
            TIEAPUUDI7 => TIEAPUUDI7_ipd_1,
            TIEAPUUDI8 => TIEAPUUDI8_ipd_1

      );
   
start_blk : fpga_startup_virtex4

  port map (
    bus_reset => FPGA_BUS_RESET,
    ghigh_b => FPGA_GHIGHB,
    gsr => FPGA_GSR,
    gwe => FPGA_GWE,
    shutdown => FPGA_SHUTDOWN,
    
    cclk => FPGA_CCLK,
    por => FPGA_POR);

  GSR_OR <= FPGA_GSR or GSR;
  FPGA_POR <= '0' after 1000 ps;
  FPGA_CCLK <= NOT(FPGA_CCLK) after 5000 ps;                                

        FPGA_BUS_RESET_delay <= FPGA_BUS_RESET after 10 ps ;
        GSR_delay <= GSR_OR after 10 ps;
        FPGA_GWE_delay <= FPGA_GWE after 10 ps;
        FPGA_GHIGHB_delay <= FPGA_GHIGHB after 10 ps;


   TIMING : process
     variable  APUFCMDECODED_GlitchData : VitalGlitchDataType;
     variable  APUFCMDECUDI0_GlitchData : VitalGlitchDataType;
     variable  APUFCMDECUDI1_GlitchData : VitalGlitchDataType;
     variable  APUFCMDECUDI2_GlitchData : VitalGlitchDataType;
     variable  APUFCMDECUDIVALID_GlitchData : VitalGlitchDataType;
     variable  APUFCMENDIAN_GlitchData : VitalGlitchDataType;
     variable  APUFCMFLUSH_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION0_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION1_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION2_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION3_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION4_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION5_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION6_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION7_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION8_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION9_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION10_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION11_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION12_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION13_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION14_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION15_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION16_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION17_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION18_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION19_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION20_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION21_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION22_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION23_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION24_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION25_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION26_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION27_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION28_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION29_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION30_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRUCTION31_GlitchData : VitalGlitchDataType;
     variable  APUFCMINSTRVALID_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADBYTEEN0_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADBYTEEN1_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADBYTEEN2_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADBYTEEN3_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA0_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA1_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA2_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA3_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA4_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA5_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA6_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA7_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA8_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA9_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA10_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA11_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA12_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA13_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA14_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA15_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA16_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA17_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA18_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA19_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA20_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA21_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA22_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA23_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA24_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA25_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA26_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA27_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA28_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA29_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA30_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDATA31_GlitchData : VitalGlitchDataType;
     variable  APUFCMLOADDVALID_GlitchData : VitalGlitchDataType;
     variable  APUFCMOPERANDVALID_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA0_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA1_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA2_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA3_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA4_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA5_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA6_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA7_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA8_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA9_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA10_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA11_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA12_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA13_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA14_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA15_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA16_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA17_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA18_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA19_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA20_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA21_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA22_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA23_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA24_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA25_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA26_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA27_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA28_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA29_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA30_GlitchData : VitalGlitchDataType;
     variable  APUFCMRADATA31_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA0_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA1_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA2_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA3_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA4_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA5_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA6_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA7_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA8_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA9_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA10_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA11_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA12_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA13_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA14_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA15_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA16_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA17_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA18_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA19_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA20_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA21_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA22_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA23_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA24_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA25_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA26_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA27_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA28_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA29_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA30_GlitchData : VitalGlitchDataType;
     variable  APUFCMRBDATA31_GlitchData : VitalGlitchDataType;
     variable  APUFCMWRITEBACKOK_GlitchData : VitalGlitchDataType;
     variable  APUFCMXERCA_GlitchData : VitalGlitchDataType;
     variable  C405CPMCORESLEEPREQ_GlitchData : VitalGlitchDataType;
     variable  C405CPMMSRCE_GlitchData : VitalGlitchDataType;
     variable  C405CPMMSREE_GlitchData : VitalGlitchDataType;
     variable  C405CPMTIMERIRQ_GlitchData : VitalGlitchDataType;
     variable  C405CPMTIMERRESETREQ_GlitchData : VitalGlitchDataType;
     variable  C405DBGLOADDATAONAPUDBUS_GlitchData : VitalGlitchDataType;
     variable  C405DBGMSRWE_GlitchData : VitalGlitchDataType;
     variable  C405DBGSTOPACK_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBCOMPLETE_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBFULL_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR0_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR1_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR2_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR3_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR4_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR5_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR6_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR7_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR8_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR9_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR10_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR11_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR12_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR13_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR14_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR15_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR16_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR17_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR18_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR19_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR20_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR21_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR22_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR23_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR24_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR25_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR26_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR27_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR28_GlitchData : VitalGlitchDataType;
     variable  C405DBGWBIAR29_GlitchData : VitalGlitchDataType;
     variable  C405JTGCAPTUREDR_GlitchData : VitalGlitchDataType;
     variable  C405JTGEXTEST_GlitchData : VitalGlitchDataType;
     variable  C405JTGPGMOUT_GlitchData : VitalGlitchDataType;
     variable  C405JTGSHIFTDR_GlitchData : VitalGlitchDataType;
     variable  C405JTGTDO_GlitchData : VitalGlitchDataType;
     variable  C405JTGTDOEN_GlitchData : VitalGlitchDataType;
     variable  C405JTGUPDATEDR_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABORT_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS0_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS1_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS2_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS3_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS4_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS5_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS6_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS7_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS8_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS9_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS10_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS11_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS12_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS13_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS14_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS15_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS16_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS17_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS18_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS19_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS20_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS21_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS22_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS23_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS24_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS25_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS26_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS27_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS28_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS29_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS30_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUABUS31_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE0_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE1_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE2_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE3_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE4_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE5_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE6_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUBE7_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUCACHEABLE_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUGUARDED_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUPRIORITY0_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUPRIORITY1_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUREQUEST_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCURNW_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUSIZE2_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUU0ATTR_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS0_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS1_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS2_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS3_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS4_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS5_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS6_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS7_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS8_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS9_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS10_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS11_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS12_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS13_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS14_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS15_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS16_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS17_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS18_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS19_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS20_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS21_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS22_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS23_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS24_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS25_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS26_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS27_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS28_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS29_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS30_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS31_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS32_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS33_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS34_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS35_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS36_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS37_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS38_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS39_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS40_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS41_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS42_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS43_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS44_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS45_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS46_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS47_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS48_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS49_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS50_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS51_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS52_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS53_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS54_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS55_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS56_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS57_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS58_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS59_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS60_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS61_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS62_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRDBUS63_GlitchData : VitalGlitchDataType;
     variable  C405PLBDCUWRITETHRU_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABORT_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS0_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS1_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS2_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS3_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS4_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS5_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS6_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS7_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS8_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS9_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS10_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS11_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS12_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS13_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS14_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS15_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS16_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS17_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS18_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS19_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS20_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS21_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS22_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS23_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS24_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS25_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS26_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS27_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS28_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUABUS29_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUCACHEABLE_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUPRIORITY0_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUPRIORITY1_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUREQUEST_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUSIZE2_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUSIZE3_GlitchData : VitalGlitchDataType;
     variable  C405PLBICUU0ATTR_GlitchData : VitalGlitchDataType;
     variable  C405RSTCHIPRESETREQ_GlitchData : VitalGlitchDataType;
     variable  C405RSTCORERESETREQ_GlitchData : VitalGlitchDataType;
     variable  C405RSTSYSRESETREQ_GlitchData : VitalGlitchDataType;
     variable  C405TRCCYCLE_GlitchData : VitalGlitchDataType;
     variable  C405TRCEVENEXECUTIONSTATUS0_GlitchData : VitalGlitchDataType;
     variable  C405TRCEVENEXECUTIONSTATUS1_GlitchData : VitalGlitchDataType;
     variable  C405TRCODDEXECUTIONSTATUS0_GlitchData : VitalGlitchDataType;
     variable  C405TRCODDEXECUTIONSTATUS1_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRACESTATUS0_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRACESTATUS1_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRACESTATUS2_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRACESTATUS3_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTOUT_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE0_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE1_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE2_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE3_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE4_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE5_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE6_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE7_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE8_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE9_GlitchData : VitalGlitchDataType;
     variable  C405TRCTRIGGEREVENTTYPE10_GlitchData : VitalGlitchDataType;
     variable  C405XXXMACHINECHECK_GlitchData : VitalGlitchDataType;
     variable  DCREMACENABLER_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS8_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS9_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS10_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS11_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS12_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS13_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS14_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS15_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS16_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS17_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS18_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS19_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS20_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS21_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS22_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS23_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS24_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS25_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS26_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS27_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS28_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMABUS29_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMBYTEWRITE0_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMBYTEWRITE1_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMBYTEWRITE2_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMBYTEWRITE3_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMEN_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS0_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS1_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS2_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS3_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS4_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS5_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS6_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS7_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS8_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS9_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS10_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS11_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS12_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS13_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS14_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS15_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS16_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS17_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS18_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS19_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS20_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS21_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS22_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS23_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS24_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS25_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS26_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS27_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS28_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS29_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS30_GlitchData : VitalGlitchDataType;
     variable  DSOCMBRAMWRDBUS31_GlitchData : VitalGlitchDataType;
     variable  DSOCMBUSY_GlitchData : VitalGlitchDataType;
     variable  DSOCMRDADDRVALID_GlitchData : VitalGlitchDataType;
     variable  DSOCMWRADDRVALID_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS0_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS1_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS2_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS3_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS4_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS5_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS6_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS7_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS8_GlitchData : VitalGlitchDataType;
     variable  EXTDCRABUS9_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT0_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT1_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT2_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT3_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT4_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT5_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT6_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT7_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT8_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT9_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT10_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT11_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT12_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT13_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT14_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT15_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT16_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT17_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT18_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT19_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT20_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT21_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT22_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT23_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT24_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT25_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT26_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT27_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT28_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT29_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT30_GlitchData : VitalGlitchDataType;
     variable  EXTDCRDBUSOUT31_GlitchData : VitalGlitchDataType;
     variable  EXTDCRREAD_GlitchData : VitalGlitchDataType;
     variable  EXTDCRWRITE_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMEN_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMEVENWRITEEN_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMODDWRITEEN_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS8_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS9_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS10_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS11_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS12_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS13_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS14_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS15_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS16_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS17_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS18_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS19_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS20_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS21_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS22_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS23_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS24_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS25_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS26_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS27_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMRDABUS28_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS8_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS9_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS10_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS11_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS12_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS13_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS14_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS15_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS16_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS17_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS18_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS19_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS20_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS21_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS22_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS23_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS24_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS25_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS26_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS27_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRABUS28_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS0_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS1_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS2_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS3_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS4_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS5_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS6_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS7_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS8_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS9_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS10_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS11_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS12_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS13_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS14_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS15_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS16_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS17_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS18_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS19_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS20_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS21_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS22_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS23_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS24_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS25_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS26_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS27_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS28_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS29_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS30_GlitchData : VitalGlitchDataType;
     variable  ISOCMBRAMWRDBUS31_GlitchData : VitalGlitchDataType;
     variable  ISOCMDCRBRAMEVENEN_GlitchData : VitalGlitchDataType;
     variable  ISOCMDCRBRAMODDEN_GlitchData : VitalGlitchDataType;
     variable  ISOCMDCRBRAMRDSELECT_GlitchData : VitalGlitchDataType;
     variable  DCREMACWRITE_GlitchData : VitalGlitchDataType;
     variable  DCREMACREAD_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS0_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS1_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS2_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS3_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS4_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS5_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS6_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS7_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS8_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS9_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS10_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS11_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS12_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS13_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS14_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS15_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS16_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS17_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS18_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS19_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS20_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS21_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS22_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS23_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS24_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS25_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS26_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS27_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS28_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS29_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS30_GlitchData : VitalGlitchDataType;
     variable  DCREMACDBUS31_GlitchData : VitalGlitchDataType;
     variable  DCREMACABUS8_GlitchData : VitalGlitchDataType;
     variable  DCREMACABUS9_GlitchData : VitalGlitchDataType;
     variable  DCREMACCLK_GlitchData : VitalGlitchDataType;
begin


--  Output-to-Clock path delay
     VitalPathDelay01
       (
         OutSignal     => APUFCMDECODED,
         GlitchData    => APUFCMDECODED_GlitchData,
         OutSignalName => "APUFCMDECODED",
         OutTemp       => APUFCMDECODED_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMDECUDIVALID,
         GlitchData    => APUFCMDECUDIVALID_GlitchData,
         OutSignalName => "APUFCMDECUDIVALID",
         OutTemp       => APUFCMDECUDIVALID_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMENDIAN,
         GlitchData    => APUFCMENDIAN_GlitchData,
         OutSignalName => "APUFCMENDIAN",
         OutTemp       => APUFCMENDIAN_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMFLUSH,
         GlitchData    => APUFCMFLUSH_GlitchData,
         OutSignalName => "APUFCMFLUSH",
         OutTemp       => APUFCMFLUSH_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRVALID,
         GlitchData    => APUFCMINSTRVALID_GlitchData,
         OutSignalName => "APUFCMINSTRVALID",
         OutTemp       => APUFCMINSTRVALID_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDVALID,
         GlitchData    => APUFCMLOADDVALID_GlitchData,
         OutSignalName => "APUFCMLOADDVALID",
         OutTemp       => APUFCMLOADDVALID_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMOPERANDVALID,
         GlitchData    => APUFCMOPERANDVALID_GlitchData,
         OutSignalName => "APUFCMOPERANDVALID",
         OutTemp       => APUFCMOPERANDVALID_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMWRITEBACKOK,
         GlitchData    => APUFCMWRITEBACKOK_GlitchData,
         OutSignalName => "APUFCMWRITEBACKOK",
         OutTemp       => APUFCMWRITEBACKOK_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMXERCA,
         GlitchData    => APUFCMXERCA_GlitchData,
         OutSignalName => "APUFCMXERCA",
         OutTemp       => APUFCMXERCA_OUT,
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405CPMCORESLEEPREQ,
         GlitchData    => C405CPMCORESLEEPREQ_GlitchData,
         OutSignalName => "C405CPMCORESLEEPREQ",
         OutTemp       => C405CPMCORESLEEPREQ_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405CPMMSRCE,
         GlitchData    => C405CPMMSRCE_GlitchData,
         OutSignalName => "C405CPMMSRCE",
         OutTemp       => C405CPMMSRCE_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405CPMMSREE,
         GlitchData    => C405CPMMSREE_GlitchData,
         OutSignalName => "C405CPMMSREE",
         OutTemp       => C405CPMMSREE_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405CPMTIMERIRQ,
         GlitchData    => C405CPMTIMERIRQ_GlitchData,
         OutSignalName => "C405CPMTIMERIRQ",
         OutTemp       => C405CPMTIMERIRQ_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405CPMTIMERRESETREQ,
         GlitchData    => C405CPMTIMERRESETREQ_GlitchData,
         OutSignalName => "C405CPMTIMERRESETREQ",
         OutTemp       => C405CPMTIMERRESETREQ_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGLOADDATAONAPUDBUS,
         GlitchData    => C405DBGLOADDATAONAPUDBUS_GlitchData,
         OutSignalName => "C405DBGLOADDATAONAPUDBUS",
         OutTemp       => C405DBGLOADDATAONAPUDBUS_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGMSRWE,
         GlitchData    => C405DBGMSRWE_GlitchData,
         OutSignalName => "C405DBGMSRWE",
         OutTemp       => C405DBGMSRWE_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGSTOPACK,
         GlitchData    => C405DBGSTOPACK_GlitchData,
         OutSignalName => "C405DBGSTOPACK",
         OutTemp       => C405DBGSTOPACK_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBCOMPLETE,
         GlitchData    => C405DBGWBCOMPLETE_GlitchData,
         OutSignalName => "C405DBGWBCOMPLETE",
         OutTemp       => C405DBGWBCOMPLETE_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBFULL,
         GlitchData    => C405DBGWBFULL_GlitchData,
         OutSignalName => "C405DBGWBFULL",
         OutTemp       => C405DBGWBFULL_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405JTGCAPTUREDR,
         GlitchData    => C405JTGCAPTUREDR_GlitchData,
         OutSignalName => "C405JTGCAPTUREDR",
         OutTemp       => C405JTGCAPTUREDR_OUT,
         Paths         => (0 => (JTGC405TCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405JTGEXTEST,
         GlitchData    => C405JTGEXTEST_GlitchData,
         OutSignalName => "C405JTGEXTEST",
         OutTemp       => C405JTGEXTEST_OUT,
         Paths         => (0 => (JTGC405TCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405JTGPGMOUT,
         GlitchData    => C405JTGPGMOUT_GlitchData,
         OutSignalName => "C405JTGPGMOUT",
         OutTemp       => C405JTGPGMOUT_OUT,
         Paths         => (0 => (JTGC405TCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405JTGSHIFTDR,
         GlitchData    => C405JTGSHIFTDR_GlitchData,
         OutSignalName => "C405JTGSHIFTDR",
         OutTemp       => C405JTGSHIFTDR_OUT,
         Paths         => (0 => (JTGC405TCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405JTGTDO,
         GlitchData    => C405JTGTDO_GlitchData,
         OutSignalName => "C405JTGTDO",
         OutTemp       => C405JTGTDO_OUT,
         Paths         => (0 => (JTGC405TCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405JTGTDOEN,
         GlitchData    => C405JTGTDOEN_GlitchData,
         OutSignalName => "C405JTGTDOEN",
         OutTemp       => C405JTGTDOEN_OUT,
         Paths         => (0 => (JTGC405TCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405JTGUPDATEDR,
         GlitchData    => C405JTGUPDATEDR_GlitchData,
         OutSignalName => "C405JTGUPDATEDR",
         OutTemp       => C405JTGUPDATEDR_OUT,
         Paths         => (0 => (JTGC405TCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABORT,
         GlitchData    => C405PLBDCUABORT_GlitchData,
         OutSignalName => "C405PLBDCUABORT",
         OutTemp       => C405PLBDCUABORT_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUCACHEABLE,
         GlitchData    => C405PLBDCUCACHEABLE_GlitchData,
         OutSignalName => "C405PLBDCUCACHEABLE",
         OutTemp       => C405PLBDCUCACHEABLE_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUGUARDED,
         GlitchData    => C405PLBDCUGUARDED_GlitchData,
         OutSignalName => "C405PLBDCUGUARDED",
         OutTemp       => C405PLBDCUGUARDED_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUREQUEST,
         GlitchData    => C405PLBDCUREQUEST_GlitchData,
         OutSignalName => "C405PLBDCUREQUEST",
         OutTemp       => C405PLBDCUREQUEST_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCURNW,
         GlitchData    => C405PLBDCURNW_GlitchData,
         OutSignalName => "C405PLBDCURNW",
         OutTemp       => C405PLBDCURNW_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUSIZE2,
         GlitchData    => C405PLBDCUSIZE2_GlitchData,
         OutSignalName => "C405PLBDCUSIZE2",
         OutTemp       => C405PLBDCUSIZE2_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUU0ATTR,
         GlitchData    => C405PLBDCUU0ATTR_GlitchData,
         OutSignalName => "C405PLBDCUU0ATTR",
         OutTemp       => C405PLBDCUU0ATTR_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRITETHRU,
         GlitchData    => C405PLBDCUWRITETHRU_GlitchData,
         OutSignalName => "C405PLBDCUWRITETHRU",
         OutTemp       => C405PLBDCUWRITETHRU_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABORT,
         GlitchData    => C405PLBICUABORT_GlitchData,
         OutSignalName => "C405PLBICUABORT",
         OutTemp       => C405PLBICUABORT_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUCACHEABLE,
         GlitchData    => C405PLBICUCACHEABLE_GlitchData,
         OutSignalName => "C405PLBICUCACHEABLE",
         OutTemp       => C405PLBICUCACHEABLE_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUREQUEST,
         GlitchData    => C405PLBICUREQUEST_GlitchData,
         OutSignalName => "C405PLBICUREQUEST",
         OutTemp       => C405PLBICUREQUEST_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUU0ATTR,
         GlitchData    => C405PLBICUU0ATTR_GlitchData,
         OutSignalName => "C405PLBICUU0ATTR",
         OutTemp       => C405PLBICUU0ATTR_OUT,
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405RSTCHIPRESETREQ,
         GlitchData    => C405RSTCHIPRESETREQ_GlitchData,
         OutSignalName => "C405RSTCHIPRESETREQ",
         OutTemp       => C405RSTCHIPRESETREQ_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405RSTCORERESETREQ,
         GlitchData    => C405RSTCORERESETREQ_GlitchData,
         OutSignalName => "C405RSTCORERESETREQ",
         OutTemp       => C405RSTCORERESETREQ_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405RSTSYSRESETREQ,
         GlitchData    => C405RSTSYSRESETREQ_GlitchData,
         OutSignalName => "C405RSTSYSRESETREQ",
         OutTemp       => C405RSTSYSRESETREQ_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCCYCLE,
         GlitchData    => C405TRCCYCLE_GlitchData,
         OutSignalName => "C405TRCCYCLE",
         OutTemp       => C405TRCCYCLE_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTOUT,
         GlitchData    => C405TRCTRIGGEREVENTOUT_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTOUT",
         OutTemp       => C405TRCTRIGGEREVENTOUT_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405XXXMACHINECHECK,
         GlitchData    => C405XXXMACHINECHECK_GlitchData,
         OutSignalName => "C405XXXMACHINECHECK",
         OutTemp       => C405XXXMACHINECHECK_OUT,
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMEN,
         GlitchData    => DSOCMBRAMEN_GlitchData,
         OutSignalName => "DSOCMBRAMEN",
         OutTemp       => DSOCMBRAMEN_OUT,
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBUSY,
         GlitchData    => DSOCMBUSY_GlitchData,
         OutSignalName => "DSOCMBUSY",
         OutTemp       => DSOCMBUSY_OUT,
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMRDADDRVALID,
         GlitchData    => DSOCMRDADDRVALID_GlitchData,
         OutSignalName => "DSOCMRDADDRVALID",
         OutTemp       => DSOCMRDADDRVALID_OUT,
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMWRADDRVALID,
         GlitchData    => DSOCMWRADDRVALID_GlitchData,
         OutSignalName => "DSOCMWRADDRVALID",
         OutTemp       => DSOCMWRADDRVALID_OUT,
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRREAD,
         GlitchData    => EXTDCRREAD_GlitchData,
         OutSignalName => "EXTDCRREAD",
         OutTemp       => EXTDCRREAD_OUT,
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRWRITE,
         GlitchData    => EXTDCRWRITE_GlitchData,
         OutSignalName => "EXTDCRWRITE",
         OutTemp       => EXTDCRWRITE_OUT,
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMEN,
         GlitchData    => ISOCMBRAMEN_GlitchData,
         OutSignalName => "ISOCMBRAMEN",
         OutTemp       => ISOCMBRAMEN_OUT,
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMEVENWRITEEN,
         GlitchData    => ISOCMBRAMEVENWRITEEN_GlitchData,
         OutSignalName => "ISOCMBRAMEVENWRITEEN",
         OutTemp       => ISOCMBRAMEVENWRITEEN_OUT,
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMODDWRITEEN,
         GlitchData    => ISOCMBRAMODDWRITEEN_GlitchData,
         OutSignalName => "ISOCMBRAMODDWRITEEN",
         OutTemp       => ISOCMBRAMODDWRITEEN_OUT,
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMDCRBRAMEVENEN,
         GlitchData    => ISOCMDCRBRAMEVENEN_GlitchData,
         OutSignalName => "ISOCMDCRBRAMEVENEN",
         OutTemp       => ISOCMDCRBRAMEVENEN_OUT,
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMDCRBRAMODDEN,
         GlitchData    => ISOCMDCRBRAMODDEN_GlitchData,
         OutSignalName => "ISOCMDCRBRAMODDEN",
         OutTemp       => ISOCMDCRBRAMODDEN_OUT,
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMDCRBRAMRDSELECT,
         GlitchData    => ISOCMDCRBRAMRDSELECT_GlitchData,
         OutSignalName => "ISOCMDCRBRAMRDSELECT",
         OutTemp       => ISOCMDCRBRAMRDSELECT_OUT,
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );

----- bused outputs
     VitalPathDelay01
       (
         OutSignal     => APUFCMDECUDI(0),
         GlitchData    => APUFCMDECUDI0_GlitchData,
         OutSignalName => "APUFCMDECUDI(0)",
         OutTemp       => APUFCMDECUDI_OUT(0),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMDECUDI(1),
         GlitchData    => APUFCMDECUDI1_GlitchData,
         OutSignalName => "APUFCMDECUDI(1)",
         OutTemp       => APUFCMDECUDI_OUT(1),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMDECUDI(2),
         GlitchData    => APUFCMDECUDI2_GlitchData,
         OutSignalName => "APUFCMDECUDI(2)",
         OutTemp       => APUFCMDECUDI_OUT(2),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(0),
         GlitchData    => APUFCMINSTRUCTION0_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(0)",
         OutTemp       => APUFCMINSTRUCTION_OUT(0),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(1),
         GlitchData    => APUFCMINSTRUCTION1_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(1)",
         OutTemp       => APUFCMINSTRUCTION_OUT(1),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(2),
         GlitchData    => APUFCMINSTRUCTION2_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(2)",
         OutTemp       => APUFCMINSTRUCTION_OUT(2),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(3),
         GlitchData    => APUFCMINSTRUCTION3_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(3)",
         OutTemp       => APUFCMINSTRUCTION_OUT(3),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(4),
         GlitchData    => APUFCMINSTRUCTION4_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(4)",
         OutTemp       => APUFCMINSTRUCTION_OUT(4),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(5),
         GlitchData    => APUFCMINSTRUCTION5_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(5)",
         OutTemp       => APUFCMINSTRUCTION_OUT(5),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(6),
         GlitchData    => APUFCMINSTRUCTION6_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(6)",
         OutTemp       => APUFCMINSTRUCTION_OUT(6),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(7),
         GlitchData    => APUFCMINSTRUCTION7_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(7)",
         OutTemp       => APUFCMINSTRUCTION_OUT(7),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(8),
         GlitchData    => APUFCMINSTRUCTION8_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(8)",
         OutTemp       => APUFCMINSTRUCTION_OUT(8),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(9),
         GlitchData    => APUFCMINSTRUCTION9_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(9)",
         OutTemp       => APUFCMINSTRUCTION_OUT(9),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(10),
         GlitchData    => APUFCMINSTRUCTION10_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(10)",
         OutTemp       => APUFCMINSTRUCTION_OUT(10),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(11),
         GlitchData    => APUFCMINSTRUCTION11_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(11)",
         OutTemp       => APUFCMINSTRUCTION_OUT(11),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(12),
         GlitchData    => APUFCMINSTRUCTION12_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(12)",
         OutTemp       => APUFCMINSTRUCTION_OUT(12),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(13),
         GlitchData    => APUFCMINSTRUCTION13_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(13)",
         OutTemp       => APUFCMINSTRUCTION_OUT(13),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(14),
         GlitchData    => APUFCMINSTRUCTION14_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(14)",
         OutTemp       => APUFCMINSTRUCTION_OUT(14),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(15),
         GlitchData    => APUFCMINSTRUCTION15_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(15)",
         OutTemp       => APUFCMINSTRUCTION_OUT(15),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(16),
         GlitchData    => APUFCMINSTRUCTION16_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(16)",
         OutTemp       => APUFCMINSTRUCTION_OUT(16),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(17),
         GlitchData    => APUFCMINSTRUCTION17_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(17)",
         OutTemp       => APUFCMINSTRUCTION_OUT(17),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(18),
         GlitchData    => APUFCMINSTRUCTION18_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(18)",
         OutTemp       => APUFCMINSTRUCTION_OUT(18),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(19),
         GlitchData    => APUFCMINSTRUCTION19_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(19)",
         OutTemp       => APUFCMINSTRUCTION_OUT(19),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(20),
         GlitchData    => APUFCMINSTRUCTION20_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(20)",
         OutTemp       => APUFCMINSTRUCTION_OUT(20),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(21),
         GlitchData    => APUFCMINSTRUCTION21_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(21)",
         OutTemp       => APUFCMINSTRUCTION_OUT(21),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(22),
         GlitchData    => APUFCMINSTRUCTION22_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(22)",
         OutTemp       => APUFCMINSTRUCTION_OUT(22),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(23),
         GlitchData    => APUFCMINSTRUCTION23_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(23)",
         OutTemp       => APUFCMINSTRUCTION_OUT(23),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(24),
         GlitchData    => APUFCMINSTRUCTION24_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(24)",
         OutTemp       => APUFCMINSTRUCTION_OUT(24),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(25),
         GlitchData    => APUFCMINSTRUCTION25_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(25)",
         OutTemp       => APUFCMINSTRUCTION_OUT(25),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(26),
         GlitchData    => APUFCMINSTRUCTION26_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(26)",
         OutTemp       => APUFCMINSTRUCTION_OUT(26),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(27),
         GlitchData    => APUFCMINSTRUCTION27_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(27)",
         OutTemp       => APUFCMINSTRUCTION_OUT(27),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(28),
         GlitchData    => APUFCMINSTRUCTION28_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(28)",
         OutTemp       => APUFCMINSTRUCTION_OUT(28),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(29),
         GlitchData    => APUFCMINSTRUCTION29_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(29)",
         OutTemp       => APUFCMINSTRUCTION_OUT(29),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(30),
         GlitchData    => APUFCMINSTRUCTION30_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(30)",
         OutTemp       => APUFCMINSTRUCTION_OUT(30),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMINSTRUCTION(31),
         GlitchData    => APUFCMINSTRUCTION31_GlitchData,
         OutSignalName => "APUFCMINSTRUCTION(31)",
         OutTemp       => APUFCMINSTRUCTION_OUT(31),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADBYTEEN(0),
         GlitchData    => APUFCMLOADBYTEEN0_GlitchData,
         OutSignalName => "APUFCMLOADBYTEEN(0)",
         OutTemp       => APUFCMLOADBYTEEN_OUT(0),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADBYTEEN(1),
         GlitchData    => APUFCMLOADBYTEEN1_GlitchData,
         OutSignalName => "APUFCMLOADBYTEEN(1)",
         OutTemp       => APUFCMLOADBYTEEN_OUT(1),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADBYTEEN(2),
         GlitchData    => APUFCMLOADBYTEEN2_GlitchData,
         OutSignalName => "APUFCMLOADBYTEEN(2)",
         OutTemp       => APUFCMLOADBYTEEN_OUT(2),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADBYTEEN(3),
         GlitchData    => APUFCMLOADBYTEEN3_GlitchData,
         OutSignalName => "APUFCMLOADBYTEEN(3)",
         OutTemp       => APUFCMLOADBYTEEN_OUT(3),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(0),
         GlitchData    => APUFCMLOADDATA0_GlitchData,
         OutSignalName => "APUFCMLOADDATA(0)",
         OutTemp       => APUFCMLOADDATA_OUT(0),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(1),
         GlitchData    => APUFCMLOADDATA1_GlitchData,
         OutSignalName => "APUFCMLOADDATA(1)",
         OutTemp       => APUFCMLOADDATA_OUT(1),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(2),
         GlitchData    => APUFCMLOADDATA2_GlitchData,
         OutSignalName => "APUFCMLOADDATA(2)",
         OutTemp       => APUFCMLOADDATA_OUT(2),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(3),
         GlitchData    => APUFCMLOADDATA3_GlitchData,
         OutSignalName => "APUFCMLOADDATA(3)",
         OutTemp       => APUFCMLOADDATA_OUT(3),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(4),
         GlitchData    => APUFCMLOADDATA4_GlitchData,
         OutSignalName => "APUFCMLOADDATA(4)",
         OutTemp       => APUFCMLOADDATA_OUT(4),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(5),
         GlitchData    => APUFCMLOADDATA5_GlitchData,
         OutSignalName => "APUFCMLOADDATA(5)",
         OutTemp       => APUFCMLOADDATA_OUT(5),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(6),
         GlitchData    => APUFCMLOADDATA6_GlitchData,
         OutSignalName => "APUFCMLOADDATA(6)",
         OutTemp       => APUFCMLOADDATA_OUT(6),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(7),
         GlitchData    => APUFCMLOADDATA7_GlitchData,
         OutSignalName => "APUFCMLOADDATA(7)",
         OutTemp       => APUFCMLOADDATA_OUT(7),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(8),
         GlitchData    => APUFCMLOADDATA8_GlitchData,
         OutSignalName => "APUFCMLOADDATA(8)",
         OutTemp       => APUFCMLOADDATA_OUT(8),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(9),
         GlitchData    => APUFCMLOADDATA9_GlitchData,
         OutSignalName => "APUFCMLOADDATA(9)",
         OutTemp       => APUFCMLOADDATA_OUT(9),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(10),
         GlitchData    => APUFCMLOADDATA10_GlitchData,
         OutSignalName => "APUFCMLOADDATA(10)",
         OutTemp       => APUFCMLOADDATA_OUT(10),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(11),
         GlitchData    => APUFCMLOADDATA11_GlitchData,
         OutSignalName => "APUFCMLOADDATA(11)",
         OutTemp       => APUFCMLOADDATA_OUT(11),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(12),
         GlitchData    => APUFCMLOADDATA12_GlitchData,
         OutSignalName => "APUFCMLOADDATA(12)",
         OutTemp       => APUFCMLOADDATA_OUT(12),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(13),
         GlitchData    => APUFCMLOADDATA13_GlitchData,
         OutSignalName => "APUFCMLOADDATA(13)",
         OutTemp       => APUFCMLOADDATA_OUT(13),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(14),
         GlitchData    => APUFCMLOADDATA14_GlitchData,
         OutSignalName => "APUFCMLOADDATA(14)",
         OutTemp       => APUFCMLOADDATA_OUT(14),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(15),
         GlitchData    => APUFCMLOADDATA15_GlitchData,
         OutSignalName => "APUFCMLOADDATA(15)",
         OutTemp       => APUFCMLOADDATA_OUT(15),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(16),
         GlitchData    => APUFCMLOADDATA16_GlitchData,
         OutSignalName => "APUFCMLOADDATA(16)",
         OutTemp       => APUFCMLOADDATA_OUT(16),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(17),
         GlitchData    => APUFCMLOADDATA17_GlitchData,
         OutSignalName => "APUFCMLOADDATA(17)",
         OutTemp       => APUFCMLOADDATA_OUT(17),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(18),
         GlitchData    => APUFCMLOADDATA18_GlitchData,
         OutSignalName => "APUFCMLOADDATA(18)",
         OutTemp       => APUFCMLOADDATA_OUT(18),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(19),
         GlitchData    => APUFCMLOADDATA19_GlitchData,
         OutSignalName => "APUFCMLOADDATA(19)",
         OutTemp       => APUFCMLOADDATA_OUT(19),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(20),
         GlitchData    => APUFCMLOADDATA20_GlitchData,
         OutSignalName => "APUFCMLOADDATA(20)",
         OutTemp       => APUFCMLOADDATA_OUT(20),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(21),
         GlitchData    => APUFCMLOADDATA21_GlitchData,
         OutSignalName => "APUFCMLOADDATA(21)",
         OutTemp       => APUFCMLOADDATA_OUT(21),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(22),
         GlitchData    => APUFCMLOADDATA22_GlitchData,
         OutSignalName => "APUFCMLOADDATA(22)",
         OutTemp       => APUFCMLOADDATA_OUT(22),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(23),
         GlitchData    => APUFCMLOADDATA23_GlitchData,
         OutSignalName => "APUFCMLOADDATA(23)",
         OutTemp       => APUFCMLOADDATA_OUT(23),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(24),
         GlitchData    => APUFCMLOADDATA24_GlitchData,
         OutSignalName => "APUFCMLOADDATA(24)",
         OutTemp       => APUFCMLOADDATA_OUT(24),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(25),
         GlitchData    => APUFCMLOADDATA25_GlitchData,
         OutSignalName => "APUFCMLOADDATA(25)",
         OutTemp       => APUFCMLOADDATA_OUT(25),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(26),
         GlitchData    => APUFCMLOADDATA26_GlitchData,
         OutSignalName => "APUFCMLOADDATA(26)",
         OutTemp       => APUFCMLOADDATA_OUT(26),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(27),
         GlitchData    => APUFCMLOADDATA27_GlitchData,
         OutSignalName => "APUFCMLOADDATA(27)",
         OutTemp       => APUFCMLOADDATA_OUT(27),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(28),
         GlitchData    => APUFCMLOADDATA28_GlitchData,
         OutSignalName => "APUFCMLOADDATA(28)",
         OutTemp       => APUFCMLOADDATA_OUT(28),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(29),
         GlitchData    => APUFCMLOADDATA29_GlitchData,
         OutSignalName => "APUFCMLOADDATA(29)",
         OutTemp       => APUFCMLOADDATA_OUT(29),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(30),
         GlitchData    => APUFCMLOADDATA30_GlitchData,
         OutSignalName => "APUFCMLOADDATA(30)",
         OutTemp       => APUFCMLOADDATA_OUT(30),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMLOADDATA(31),
         GlitchData    => APUFCMLOADDATA31_GlitchData,
         OutSignalName => "APUFCMLOADDATA(31)",
         OutTemp       => APUFCMLOADDATA_OUT(31),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(0),
         GlitchData    => APUFCMRADATA0_GlitchData,
         OutSignalName => "APUFCMRADATA(0)",
         OutTemp       => APUFCMRADATA_OUT(0),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(1),
         GlitchData    => APUFCMRADATA1_GlitchData,
         OutSignalName => "APUFCMRADATA(1)",
         OutTemp       => APUFCMRADATA_OUT(1),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(2),
         GlitchData    => APUFCMRADATA2_GlitchData,
         OutSignalName => "APUFCMRADATA(2)",
         OutTemp       => APUFCMRADATA_OUT(2),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(3),
         GlitchData    => APUFCMRADATA3_GlitchData,
         OutSignalName => "APUFCMRADATA(3)",
         OutTemp       => APUFCMRADATA_OUT(3),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(4),
         GlitchData    => APUFCMRADATA4_GlitchData,
         OutSignalName => "APUFCMRADATA(4)",
         OutTemp       => APUFCMRADATA_OUT(4),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(5),
         GlitchData    => APUFCMRADATA5_GlitchData,
         OutSignalName => "APUFCMRADATA(5)",
         OutTemp       => APUFCMRADATA_OUT(5),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(6),
         GlitchData    => APUFCMRADATA6_GlitchData,
         OutSignalName => "APUFCMRADATA(6)",
         OutTemp       => APUFCMRADATA_OUT(6),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(7),
         GlitchData    => APUFCMRADATA7_GlitchData,
         OutSignalName => "APUFCMRADATA(7)",
         OutTemp       => APUFCMRADATA_OUT(7),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(8),
         GlitchData    => APUFCMRADATA8_GlitchData,
         OutSignalName => "APUFCMRADATA(8)",
         OutTemp       => APUFCMRADATA_OUT(8),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(9),
         GlitchData    => APUFCMRADATA9_GlitchData,
         OutSignalName => "APUFCMRADATA(9)",
         OutTemp       => APUFCMRADATA_OUT(9),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(10),
         GlitchData    => APUFCMRADATA10_GlitchData,
         OutSignalName => "APUFCMRADATA(10)",
         OutTemp       => APUFCMRADATA_OUT(10),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(11),
         GlitchData    => APUFCMRADATA11_GlitchData,
         OutSignalName => "APUFCMRADATA(11)",
         OutTemp       => APUFCMRADATA_OUT(11),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(12),
         GlitchData    => APUFCMRADATA12_GlitchData,
         OutSignalName => "APUFCMRADATA(12)",
         OutTemp       => APUFCMRADATA_OUT(12),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(13),
         GlitchData    => APUFCMRADATA13_GlitchData,
         OutSignalName => "APUFCMRADATA(13)",
         OutTemp       => APUFCMRADATA_OUT(13),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(14),
         GlitchData    => APUFCMRADATA14_GlitchData,
         OutSignalName => "APUFCMRADATA(14)",
         OutTemp       => APUFCMRADATA_OUT(14),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(15),
         GlitchData    => APUFCMRADATA15_GlitchData,
         OutSignalName => "APUFCMRADATA(15)",
         OutTemp       => APUFCMRADATA_OUT(15),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(16),
         GlitchData    => APUFCMRADATA16_GlitchData,
         OutSignalName => "APUFCMRADATA(16)",
         OutTemp       => APUFCMRADATA_OUT(16),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(17),
         GlitchData    => APUFCMRADATA17_GlitchData,
         OutSignalName => "APUFCMRADATA(17)",
         OutTemp       => APUFCMRADATA_OUT(17),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(18),
         GlitchData    => APUFCMRADATA18_GlitchData,
         OutSignalName => "APUFCMRADATA(18)",
         OutTemp       => APUFCMRADATA_OUT(18),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(19),
         GlitchData    => APUFCMRADATA19_GlitchData,
         OutSignalName => "APUFCMRADATA(19)",
         OutTemp       => APUFCMRADATA_OUT(19),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(20),
         GlitchData    => APUFCMRADATA20_GlitchData,
         OutSignalName => "APUFCMRADATA(20)",
         OutTemp       => APUFCMRADATA_OUT(20),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(21),
         GlitchData    => APUFCMRADATA21_GlitchData,
         OutSignalName => "APUFCMRADATA(21)",
         OutTemp       => APUFCMRADATA_OUT(21),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(22),
         GlitchData    => APUFCMRADATA22_GlitchData,
         OutSignalName => "APUFCMRADATA(22)",
         OutTemp       => APUFCMRADATA_OUT(22),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(23),
         GlitchData    => APUFCMRADATA23_GlitchData,
         OutSignalName => "APUFCMRADATA(23)",
         OutTemp       => APUFCMRADATA_OUT(23),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(24),
         GlitchData    => APUFCMRADATA24_GlitchData,
         OutSignalName => "APUFCMRADATA(24)",
         OutTemp       => APUFCMRADATA_OUT(24),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(25),
         GlitchData    => APUFCMRADATA25_GlitchData,
         OutSignalName => "APUFCMRADATA(25)",
         OutTemp       => APUFCMRADATA_OUT(25),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(26),
         GlitchData    => APUFCMRADATA26_GlitchData,
         OutSignalName => "APUFCMRADATA(26)",
         OutTemp       => APUFCMRADATA_OUT(26),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(27),
         GlitchData    => APUFCMRADATA27_GlitchData,
         OutSignalName => "APUFCMRADATA(27)",
         OutTemp       => APUFCMRADATA_OUT(27),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(28),
         GlitchData    => APUFCMRADATA28_GlitchData,
         OutSignalName => "APUFCMRADATA(28)",
         OutTemp       => APUFCMRADATA_OUT(28),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(29),
         GlitchData    => APUFCMRADATA29_GlitchData,
         OutSignalName => "APUFCMRADATA(29)",
         OutTemp       => APUFCMRADATA_OUT(29),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(30),
         GlitchData    => APUFCMRADATA30_GlitchData,
         OutSignalName => "APUFCMRADATA(30)",
         OutTemp       => APUFCMRADATA_OUT(30),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRADATA(31),
         GlitchData    => APUFCMRADATA31_GlitchData,
         OutSignalName => "APUFCMRADATA(31)",
         OutTemp       => APUFCMRADATA_OUT(31),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(0),
         GlitchData    => APUFCMRBDATA0_GlitchData,
         OutSignalName => "APUFCMRBDATA(0)",
         OutTemp       => APUFCMRBDATA_OUT(0),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(1),
         GlitchData    => APUFCMRBDATA1_GlitchData,
         OutSignalName => "APUFCMRBDATA(1)",
         OutTemp       => APUFCMRBDATA_OUT(1),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(2),
         GlitchData    => APUFCMRBDATA2_GlitchData,
         OutSignalName => "APUFCMRBDATA(2)",
         OutTemp       => APUFCMRBDATA_OUT(2),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(3),
         GlitchData    => APUFCMRBDATA3_GlitchData,
         OutSignalName => "APUFCMRBDATA(3)",
         OutTemp       => APUFCMRBDATA_OUT(3),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(4),
         GlitchData    => APUFCMRBDATA4_GlitchData,
         OutSignalName => "APUFCMRBDATA(4)",
         OutTemp       => APUFCMRBDATA_OUT(4),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(5),
         GlitchData    => APUFCMRBDATA5_GlitchData,
         OutSignalName => "APUFCMRBDATA(5)",
         OutTemp       => APUFCMRBDATA_OUT(5),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(6),
         GlitchData    => APUFCMRBDATA6_GlitchData,
         OutSignalName => "APUFCMRBDATA(6)",
         OutTemp       => APUFCMRBDATA_OUT(6),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(7),
         GlitchData    => APUFCMRBDATA7_GlitchData,
         OutSignalName => "APUFCMRBDATA(7)",
         OutTemp       => APUFCMRBDATA_OUT(7),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(8),
         GlitchData    => APUFCMRBDATA8_GlitchData,
         OutSignalName => "APUFCMRBDATA(8)",
         OutTemp       => APUFCMRBDATA_OUT(8),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(9),
         GlitchData    => APUFCMRBDATA9_GlitchData,
         OutSignalName => "APUFCMRBDATA(9)",
         OutTemp       => APUFCMRBDATA_OUT(9),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(10),
         GlitchData    => APUFCMRBDATA10_GlitchData,
         OutSignalName => "APUFCMRBDATA(10)",
         OutTemp       => APUFCMRBDATA_OUT(10),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(11),
         GlitchData    => APUFCMRBDATA11_GlitchData,
         OutSignalName => "APUFCMRBDATA(11)",
         OutTemp       => APUFCMRBDATA_OUT(11),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(12),
         GlitchData    => APUFCMRBDATA12_GlitchData,
         OutSignalName => "APUFCMRBDATA(12)",
         OutTemp       => APUFCMRBDATA_OUT(12),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(13),
         GlitchData    => APUFCMRBDATA13_GlitchData,
         OutSignalName => "APUFCMRBDATA(13)",
         OutTemp       => APUFCMRBDATA_OUT(13),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(14),
         GlitchData    => APUFCMRBDATA14_GlitchData,
         OutSignalName => "APUFCMRBDATA(14)",
         OutTemp       => APUFCMRBDATA_OUT(14),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(15),
         GlitchData    => APUFCMRBDATA15_GlitchData,
         OutSignalName => "APUFCMRBDATA(15)",
         OutTemp       => APUFCMRBDATA_OUT(15),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(16),
         GlitchData    => APUFCMRBDATA16_GlitchData,
         OutSignalName => "APUFCMRBDATA(16)",
         OutTemp       => APUFCMRBDATA_OUT(16),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(17),
         GlitchData    => APUFCMRBDATA17_GlitchData,
         OutSignalName => "APUFCMRBDATA(17)",
         OutTemp       => APUFCMRBDATA_OUT(17),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(18),
         GlitchData    => APUFCMRBDATA18_GlitchData,
         OutSignalName => "APUFCMRBDATA(18)",
         OutTemp       => APUFCMRBDATA_OUT(18),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(19),
         GlitchData    => APUFCMRBDATA19_GlitchData,
         OutSignalName => "APUFCMRBDATA(19)",
         OutTemp       => APUFCMRBDATA_OUT(19),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(20),
         GlitchData    => APUFCMRBDATA20_GlitchData,
         OutSignalName => "APUFCMRBDATA(20)",
         OutTemp       => APUFCMRBDATA_OUT(20),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(21),
         GlitchData    => APUFCMRBDATA21_GlitchData,
         OutSignalName => "APUFCMRBDATA(21)",
         OutTemp       => APUFCMRBDATA_OUT(21),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(22),
         GlitchData    => APUFCMRBDATA22_GlitchData,
         OutSignalName => "APUFCMRBDATA(22)",
         OutTemp       => APUFCMRBDATA_OUT(22),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(23),
         GlitchData    => APUFCMRBDATA23_GlitchData,
         OutSignalName => "APUFCMRBDATA(23)",
         OutTemp       => APUFCMRBDATA_OUT(23),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(24),
         GlitchData    => APUFCMRBDATA24_GlitchData,
         OutSignalName => "APUFCMRBDATA(24)",
         OutTemp       => APUFCMRBDATA_OUT(24),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(25),
         GlitchData    => APUFCMRBDATA25_GlitchData,
         OutSignalName => "APUFCMRBDATA(25)",
         OutTemp       => APUFCMRBDATA_OUT(25),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(26),
         GlitchData    => APUFCMRBDATA26_GlitchData,
         OutSignalName => "APUFCMRBDATA(26)",
         OutTemp       => APUFCMRBDATA_OUT(26),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(27),
         GlitchData    => APUFCMRBDATA27_GlitchData,
         OutSignalName => "APUFCMRBDATA(27)",
         OutTemp       => APUFCMRBDATA_OUT(27),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(28),
         GlitchData    => APUFCMRBDATA28_GlitchData,
         OutSignalName => "APUFCMRBDATA(28)",
         OutTemp       => APUFCMRBDATA_OUT(28),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(29),
         GlitchData    => APUFCMRBDATA29_GlitchData,
         OutSignalName => "APUFCMRBDATA(29)",
         OutTemp       => APUFCMRBDATA_OUT(29),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(30),
         GlitchData    => APUFCMRBDATA30_GlitchData,
         OutSignalName => "APUFCMRBDATA(30)",
         OutTemp       => APUFCMRBDATA_OUT(30),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => APUFCMRBDATA(31),
         GlitchData    => APUFCMRBDATA31_GlitchData,
         OutSignalName => "APUFCMRBDATA(31)",
         OutTemp       => APUFCMRBDATA_OUT(31),
         Paths         => (0 => (CPMFCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(0),
         GlitchData    => C405DBGWBIAR0_GlitchData,
         OutSignalName => "C405DBGWBIAR(0)",
         OutTemp       => C405DBGWBIAR_OUT(0),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(1),
         GlitchData    => C405DBGWBIAR1_GlitchData,
         OutSignalName => "C405DBGWBIAR(1)",
         OutTemp       => C405DBGWBIAR_OUT(1),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(2),
         GlitchData    => C405DBGWBIAR2_GlitchData,
         OutSignalName => "C405DBGWBIAR(2)",
         OutTemp       => C405DBGWBIAR_OUT(2),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(3),
         GlitchData    => C405DBGWBIAR3_GlitchData,
         OutSignalName => "C405DBGWBIAR(3)",
         OutTemp       => C405DBGWBIAR_OUT(3),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(4),
         GlitchData    => C405DBGWBIAR4_GlitchData,
         OutSignalName => "C405DBGWBIAR(4)",
         OutTemp       => C405DBGWBIAR_OUT(4),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(5),
         GlitchData    => C405DBGWBIAR5_GlitchData,
         OutSignalName => "C405DBGWBIAR(5)",
         OutTemp       => C405DBGWBIAR_OUT(5),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(6),
         GlitchData    => C405DBGWBIAR6_GlitchData,
         OutSignalName => "C405DBGWBIAR(6)",
         OutTemp       => C405DBGWBIAR_OUT(6),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(7),
         GlitchData    => C405DBGWBIAR7_GlitchData,
         OutSignalName => "C405DBGWBIAR(7)",
         OutTemp       => C405DBGWBIAR_OUT(7),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(8),
         GlitchData    => C405DBGWBIAR8_GlitchData,
         OutSignalName => "C405DBGWBIAR(8)",
         OutTemp       => C405DBGWBIAR_OUT(8),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(9),
         GlitchData    => C405DBGWBIAR9_GlitchData,
         OutSignalName => "C405DBGWBIAR(9)",
         OutTemp       => C405DBGWBIAR_OUT(9),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(10),
         GlitchData    => C405DBGWBIAR10_GlitchData,
         OutSignalName => "C405DBGWBIAR(10)",
         OutTemp       => C405DBGWBIAR_OUT(10),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(11),
         GlitchData    => C405DBGWBIAR11_GlitchData,
         OutSignalName => "C405DBGWBIAR(11)",
         OutTemp       => C405DBGWBIAR_OUT(11),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(12),
         GlitchData    => C405DBGWBIAR12_GlitchData,
         OutSignalName => "C405DBGWBIAR(12)",
         OutTemp       => C405DBGWBIAR_OUT(12),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(13),
         GlitchData    => C405DBGWBIAR13_GlitchData,
         OutSignalName => "C405DBGWBIAR(13)",
         OutTemp       => C405DBGWBIAR_OUT(13),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(14),
         GlitchData    => C405DBGWBIAR14_GlitchData,
         OutSignalName => "C405DBGWBIAR(14)",
         OutTemp       => C405DBGWBIAR_OUT(14),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(15),
         GlitchData    => C405DBGWBIAR15_GlitchData,
         OutSignalName => "C405DBGWBIAR(15)",
         OutTemp       => C405DBGWBIAR_OUT(15),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(16),
         GlitchData    => C405DBGWBIAR16_GlitchData,
         OutSignalName => "C405DBGWBIAR(16)",
         OutTemp       => C405DBGWBIAR_OUT(16),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(17),
         GlitchData    => C405DBGWBIAR17_GlitchData,
         OutSignalName => "C405DBGWBIAR(17)",
         OutTemp       => C405DBGWBIAR_OUT(17),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(18),
         GlitchData    => C405DBGWBIAR18_GlitchData,
         OutSignalName => "C405DBGWBIAR(18)",
         OutTemp       => C405DBGWBIAR_OUT(18),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(19),
         GlitchData    => C405DBGWBIAR19_GlitchData,
         OutSignalName => "C405DBGWBIAR(19)",
         OutTemp       => C405DBGWBIAR_OUT(19),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(20),
         GlitchData    => C405DBGWBIAR20_GlitchData,
         OutSignalName => "C405DBGWBIAR(20)",
         OutTemp       => C405DBGWBIAR_OUT(20),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(21),
         GlitchData    => C405DBGWBIAR21_GlitchData,
         OutSignalName => "C405DBGWBIAR(21)",
         OutTemp       => C405DBGWBIAR_OUT(21),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(22),
         GlitchData    => C405DBGWBIAR22_GlitchData,
         OutSignalName => "C405DBGWBIAR(22)",
         OutTemp       => C405DBGWBIAR_OUT(22),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(23),
         GlitchData    => C405DBGWBIAR23_GlitchData,
         OutSignalName => "C405DBGWBIAR(23)",
         OutTemp       => C405DBGWBIAR_OUT(23),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(24),
         GlitchData    => C405DBGWBIAR24_GlitchData,
         OutSignalName => "C405DBGWBIAR(24)",
         OutTemp       => C405DBGWBIAR_OUT(24),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(25),
         GlitchData    => C405DBGWBIAR25_GlitchData,
         OutSignalName => "C405DBGWBIAR(25)",
         OutTemp       => C405DBGWBIAR_OUT(25),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(26),
         GlitchData    => C405DBGWBIAR26_GlitchData,
         OutSignalName => "C405DBGWBIAR(26)",
         OutTemp       => C405DBGWBIAR_OUT(26),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(27),
         GlitchData    => C405DBGWBIAR27_GlitchData,
         OutSignalName => "C405DBGWBIAR(27)",
         OutTemp       => C405DBGWBIAR_OUT(27),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(28),
         GlitchData    => C405DBGWBIAR28_GlitchData,
         OutSignalName => "C405DBGWBIAR(28)",
         OutTemp       => C405DBGWBIAR_OUT(28),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405DBGWBIAR(29),
         GlitchData    => C405DBGWBIAR29_GlitchData,
         OutSignalName => "C405DBGWBIAR(29)",
         OutTemp       => C405DBGWBIAR_OUT(29),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(0),
         GlitchData    => C405PLBDCUABUS0_GlitchData,
         OutSignalName => "C405PLBDCUABUS(0)",
         OutTemp       => C405PLBDCUABUS_OUT(0),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(1),
         GlitchData    => C405PLBDCUABUS1_GlitchData,
         OutSignalName => "C405PLBDCUABUS(1)",
         OutTemp       => C405PLBDCUABUS_OUT(1),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(2),
         GlitchData    => C405PLBDCUABUS2_GlitchData,
         OutSignalName => "C405PLBDCUABUS(2)",
         OutTemp       => C405PLBDCUABUS_OUT(2),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(3),
         GlitchData    => C405PLBDCUABUS3_GlitchData,
         OutSignalName => "C405PLBDCUABUS(3)",
         OutTemp       => C405PLBDCUABUS_OUT(3),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(4),
         GlitchData    => C405PLBDCUABUS4_GlitchData,
         OutSignalName => "C405PLBDCUABUS(4)",
         OutTemp       => C405PLBDCUABUS_OUT(4),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(5),
         GlitchData    => C405PLBDCUABUS5_GlitchData,
         OutSignalName => "C405PLBDCUABUS(5)",
         OutTemp       => C405PLBDCUABUS_OUT(5),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(6),
         GlitchData    => C405PLBDCUABUS6_GlitchData,
         OutSignalName => "C405PLBDCUABUS(6)",
         OutTemp       => C405PLBDCUABUS_OUT(6),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(7),
         GlitchData    => C405PLBDCUABUS7_GlitchData,
         OutSignalName => "C405PLBDCUABUS(7)",
         OutTemp       => C405PLBDCUABUS_OUT(7),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(8),
         GlitchData    => C405PLBDCUABUS8_GlitchData,
         OutSignalName => "C405PLBDCUABUS(8)",
         OutTemp       => C405PLBDCUABUS_OUT(8),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(9),
         GlitchData    => C405PLBDCUABUS9_GlitchData,
         OutSignalName => "C405PLBDCUABUS(9)",
         OutTemp       => C405PLBDCUABUS_OUT(9),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(10),
         GlitchData    => C405PLBDCUABUS10_GlitchData,
         OutSignalName => "C405PLBDCUABUS(10)",
         OutTemp       => C405PLBDCUABUS_OUT(10),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(11),
         GlitchData    => C405PLBDCUABUS11_GlitchData,
         OutSignalName => "C405PLBDCUABUS(11)",
         OutTemp       => C405PLBDCUABUS_OUT(11),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(12),
         GlitchData    => C405PLBDCUABUS12_GlitchData,
         OutSignalName => "C405PLBDCUABUS(12)",
         OutTemp       => C405PLBDCUABUS_OUT(12),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(13),
         GlitchData    => C405PLBDCUABUS13_GlitchData,
         OutSignalName => "C405PLBDCUABUS(13)",
         OutTemp       => C405PLBDCUABUS_OUT(13),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(14),
         GlitchData    => C405PLBDCUABUS14_GlitchData,
         OutSignalName => "C405PLBDCUABUS(14)",
         OutTemp       => C405PLBDCUABUS_OUT(14),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(15),
         GlitchData    => C405PLBDCUABUS15_GlitchData,
         OutSignalName => "C405PLBDCUABUS(15)",
         OutTemp       => C405PLBDCUABUS_OUT(15),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(16),
         GlitchData    => C405PLBDCUABUS16_GlitchData,
         OutSignalName => "C405PLBDCUABUS(16)",
         OutTemp       => C405PLBDCUABUS_OUT(16),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(17),
         GlitchData    => C405PLBDCUABUS17_GlitchData,
         OutSignalName => "C405PLBDCUABUS(17)",
         OutTemp       => C405PLBDCUABUS_OUT(17),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(18),
         GlitchData    => C405PLBDCUABUS18_GlitchData,
         OutSignalName => "C405PLBDCUABUS(18)",
         OutTemp       => C405PLBDCUABUS_OUT(18),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(19),
         GlitchData    => C405PLBDCUABUS19_GlitchData,
         OutSignalName => "C405PLBDCUABUS(19)",
         OutTemp       => C405PLBDCUABUS_OUT(19),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(20),
         GlitchData    => C405PLBDCUABUS20_GlitchData,
         OutSignalName => "C405PLBDCUABUS(20)",
         OutTemp       => C405PLBDCUABUS_OUT(20),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(21),
         GlitchData    => C405PLBDCUABUS21_GlitchData,
         OutSignalName => "C405PLBDCUABUS(21)",
         OutTemp       => C405PLBDCUABUS_OUT(21),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(22),
         GlitchData    => C405PLBDCUABUS22_GlitchData,
         OutSignalName => "C405PLBDCUABUS(22)",
         OutTemp       => C405PLBDCUABUS_OUT(22),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(23),
         GlitchData    => C405PLBDCUABUS23_GlitchData,
         OutSignalName => "C405PLBDCUABUS(23)",
         OutTemp       => C405PLBDCUABUS_OUT(23),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(24),
         GlitchData    => C405PLBDCUABUS24_GlitchData,
         OutSignalName => "C405PLBDCUABUS(24)",
         OutTemp       => C405PLBDCUABUS_OUT(24),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(25),
         GlitchData    => C405PLBDCUABUS25_GlitchData,
         OutSignalName => "C405PLBDCUABUS(25)",
         OutTemp       => C405PLBDCUABUS_OUT(25),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(26),
         GlitchData    => C405PLBDCUABUS26_GlitchData,
         OutSignalName => "C405PLBDCUABUS(26)",
         OutTemp       => C405PLBDCUABUS_OUT(26),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(27),
         GlitchData    => C405PLBDCUABUS27_GlitchData,
         OutSignalName => "C405PLBDCUABUS(27)",
         OutTemp       => C405PLBDCUABUS_OUT(27),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(28),
         GlitchData    => C405PLBDCUABUS28_GlitchData,
         OutSignalName => "C405PLBDCUABUS(28)",
         OutTemp       => C405PLBDCUABUS_OUT(28),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(29),
         GlitchData    => C405PLBDCUABUS29_GlitchData,
         OutSignalName => "C405PLBDCUABUS(29)",
         OutTemp       => C405PLBDCUABUS_OUT(29),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(30),
         GlitchData    => C405PLBDCUABUS30_GlitchData,
         OutSignalName => "C405PLBDCUABUS(30)",
         OutTemp       => C405PLBDCUABUS_OUT(30),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUABUS(31),
         GlitchData    => C405PLBDCUABUS31_GlitchData,
         OutSignalName => "C405PLBDCUABUS(31)",
         OutTemp       => C405PLBDCUABUS_OUT(31),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(0),
         GlitchData    => C405PLBDCUBE0_GlitchData,
         OutSignalName => "C405PLBDCUBE(0)",
         OutTemp       => C405PLBDCUBE_OUT(0),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(1),
         GlitchData    => C405PLBDCUBE1_GlitchData,
         OutSignalName => "C405PLBDCUBE(1)",
         OutTemp       => C405PLBDCUBE_OUT(1),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(2),
         GlitchData    => C405PLBDCUBE2_GlitchData,
         OutSignalName => "C405PLBDCUBE(2)",
         OutTemp       => C405PLBDCUBE_OUT(2),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(3),
         GlitchData    => C405PLBDCUBE3_GlitchData,
         OutSignalName => "C405PLBDCUBE(3)",
         OutTemp       => C405PLBDCUBE_OUT(3),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(4),
         GlitchData    => C405PLBDCUBE4_GlitchData,
         OutSignalName => "C405PLBDCUBE(4)",
         OutTemp       => C405PLBDCUBE_OUT(4),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(5),
         GlitchData    => C405PLBDCUBE5_GlitchData,
         OutSignalName => "C405PLBDCUBE(5)",
         OutTemp       => C405PLBDCUBE_OUT(5),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(6),
         GlitchData    => C405PLBDCUBE6_GlitchData,
         OutSignalName => "C405PLBDCUBE(6)",
         OutTemp       => C405PLBDCUBE_OUT(6),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUBE(7),
         GlitchData    => C405PLBDCUBE7_GlitchData,
         OutSignalName => "C405PLBDCUBE(7)",
         OutTemp       => C405PLBDCUBE_OUT(7),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUPRIORITY(0),
         GlitchData    => C405PLBDCUPRIORITY0_GlitchData,
         OutSignalName => "C405PLBDCUPRIORITY(0)",
         OutTemp       => C405PLBDCUPRIORITY_OUT(0),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUPRIORITY(1),
         GlitchData    => C405PLBDCUPRIORITY1_GlitchData,
         OutSignalName => "C405PLBDCUPRIORITY(1)",
         OutTemp       => C405PLBDCUPRIORITY_OUT(1),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(0),
         GlitchData    => C405PLBDCUWRDBUS0_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(0)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(0),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(1),
         GlitchData    => C405PLBDCUWRDBUS1_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(1)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(1),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(2),
         GlitchData    => C405PLBDCUWRDBUS2_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(2)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(2),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(3),
         GlitchData    => C405PLBDCUWRDBUS3_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(3)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(3),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(4),
         GlitchData    => C405PLBDCUWRDBUS4_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(4)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(4),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(5),
         GlitchData    => C405PLBDCUWRDBUS5_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(5)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(5),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(6),
         GlitchData    => C405PLBDCUWRDBUS6_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(6)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(6),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(7),
         GlitchData    => C405PLBDCUWRDBUS7_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(7)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(7),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(8),
         GlitchData    => C405PLBDCUWRDBUS8_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(8)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(8),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(9),
         GlitchData    => C405PLBDCUWRDBUS9_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(9)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(9),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(10),
         GlitchData    => C405PLBDCUWRDBUS10_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(10)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(10),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(11),
         GlitchData    => C405PLBDCUWRDBUS11_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(11)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(11),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(12),
         GlitchData    => C405PLBDCUWRDBUS12_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(12)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(12),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(13),
         GlitchData    => C405PLBDCUWRDBUS13_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(13)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(13),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(14),
         GlitchData    => C405PLBDCUWRDBUS14_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(14)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(14),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(15),
         GlitchData    => C405PLBDCUWRDBUS15_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(15)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(15),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(16),
         GlitchData    => C405PLBDCUWRDBUS16_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(16)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(16),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(17),
         GlitchData    => C405PLBDCUWRDBUS17_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(17)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(17),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(18),
         GlitchData    => C405PLBDCUWRDBUS18_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(18)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(18),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(19),
         GlitchData    => C405PLBDCUWRDBUS19_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(19)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(19),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(20),
         GlitchData    => C405PLBDCUWRDBUS20_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(20)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(20),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(21),
         GlitchData    => C405PLBDCUWRDBUS21_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(21)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(21),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(22),
         GlitchData    => C405PLBDCUWRDBUS22_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(22)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(22),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(23),
         GlitchData    => C405PLBDCUWRDBUS23_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(23)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(23),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(24),
         GlitchData    => C405PLBDCUWRDBUS24_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(24)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(24),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(25),
         GlitchData    => C405PLBDCUWRDBUS25_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(25)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(25),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(26),
         GlitchData    => C405PLBDCUWRDBUS26_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(26)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(26),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(27),
         GlitchData    => C405PLBDCUWRDBUS27_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(27)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(27),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(28),
         GlitchData    => C405PLBDCUWRDBUS28_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(28)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(28),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(29),
         GlitchData    => C405PLBDCUWRDBUS29_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(29)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(29),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(30),
         GlitchData    => C405PLBDCUWRDBUS30_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(30)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(30),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(31),
         GlitchData    => C405PLBDCUWRDBUS31_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(31)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(31),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(32),
         GlitchData    => C405PLBDCUWRDBUS32_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(32)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(32),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(33),
         GlitchData    => C405PLBDCUWRDBUS33_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(33)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(33),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(34),
         GlitchData    => C405PLBDCUWRDBUS34_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(34)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(34),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(35),
         GlitchData    => C405PLBDCUWRDBUS35_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(35)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(35),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(36),
         GlitchData    => C405PLBDCUWRDBUS36_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(36)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(36),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(37),
         GlitchData    => C405PLBDCUWRDBUS37_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(37)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(37),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(38),
         GlitchData    => C405PLBDCUWRDBUS38_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(38)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(38),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(39),
         GlitchData    => C405PLBDCUWRDBUS39_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(39)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(39),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(40),
         GlitchData    => C405PLBDCUWRDBUS40_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(40)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(40),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(41),
         GlitchData    => C405PLBDCUWRDBUS41_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(41)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(41),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(42),
         GlitchData    => C405PLBDCUWRDBUS42_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(42)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(42),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(43),
         GlitchData    => C405PLBDCUWRDBUS43_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(43)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(43),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(44),
         GlitchData    => C405PLBDCUWRDBUS44_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(44)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(44),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(45),
         GlitchData    => C405PLBDCUWRDBUS45_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(45)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(45),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(46),
         GlitchData    => C405PLBDCUWRDBUS46_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(46)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(46),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(47),
         GlitchData    => C405PLBDCUWRDBUS47_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(47)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(47),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(48),
         GlitchData    => C405PLBDCUWRDBUS48_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(48)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(48),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(49),
         GlitchData    => C405PLBDCUWRDBUS49_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(49)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(49),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(50),
         GlitchData    => C405PLBDCUWRDBUS50_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(50)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(50),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(51),
         GlitchData    => C405PLBDCUWRDBUS51_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(51)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(51),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(52),
         GlitchData    => C405PLBDCUWRDBUS52_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(52)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(52),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(53),
         GlitchData    => C405PLBDCUWRDBUS53_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(53)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(53),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(54),
         GlitchData    => C405PLBDCUWRDBUS54_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(54)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(54),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(55),
         GlitchData    => C405PLBDCUWRDBUS55_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(55)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(55),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(56),
         GlitchData    => C405PLBDCUWRDBUS56_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(56)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(56),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(57),
         GlitchData    => C405PLBDCUWRDBUS57_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(57)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(57),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(58),
         GlitchData    => C405PLBDCUWRDBUS58_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(58)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(58),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(59),
         GlitchData    => C405PLBDCUWRDBUS59_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(59)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(59),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(60),
         GlitchData    => C405PLBDCUWRDBUS60_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(60)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(60),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(61),
         GlitchData    => C405PLBDCUWRDBUS61_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(61)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(61),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(62),
         GlitchData    => C405PLBDCUWRDBUS62_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(62)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(62),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBDCUWRDBUS(63),
         GlitchData    => C405PLBDCUWRDBUS63_GlitchData,
         OutSignalName => "C405PLBDCUWRDBUS(63)",
         OutTemp       => C405PLBDCUWRDBUS_OUT(63),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(0),
         GlitchData    => C405PLBICUABUS0_GlitchData,
         OutSignalName => "C405PLBICUABUS(0)",
         OutTemp       => C405PLBICUABUS_OUT(0),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(1),
         GlitchData    => C405PLBICUABUS1_GlitchData,
         OutSignalName => "C405PLBICUABUS(1)",
         OutTemp       => C405PLBICUABUS_OUT(1),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(2),
         GlitchData    => C405PLBICUABUS2_GlitchData,
         OutSignalName => "C405PLBICUABUS(2)",
         OutTemp       => C405PLBICUABUS_OUT(2),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(3),
         GlitchData    => C405PLBICUABUS3_GlitchData,
         OutSignalName => "C405PLBICUABUS(3)",
         OutTemp       => C405PLBICUABUS_OUT(3),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(4),
         GlitchData    => C405PLBICUABUS4_GlitchData,
         OutSignalName => "C405PLBICUABUS(4)",
         OutTemp       => C405PLBICUABUS_OUT(4),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(5),
         GlitchData    => C405PLBICUABUS5_GlitchData,
         OutSignalName => "C405PLBICUABUS(5)",
         OutTemp       => C405PLBICUABUS_OUT(5),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(6),
         GlitchData    => C405PLBICUABUS6_GlitchData,
         OutSignalName => "C405PLBICUABUS(6)",
         OutTemp       => C405PLBICUABUS_OUT(6),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(7),
         GlitchData    => C405PLBICUABUS7_GlitchData,
         OutSignalName => "C405PLBICUABUS(7)",
         OutTemp       => C405PLBICUABUS_OUT(7),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(8),
         GlitchData    => C405PLBICUABUS8_GlitchData,
         OutSignalName => "C405PLBICUABUS(8)",
         OutTemp       => C405PLBICUABUS_OUT(8),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(9),
         GlitchData    => C405PLBICUABUS9_GlitchData,
         OutSignalName => "C405PLBICUABUS(9)",
         OutTemp       => C405PLBICUABUS_OUT(9),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(10),
         GlitchData    => C405PLBICUABUS10_GlitchData,
         OutSignalName => "C405PLBICUABUS(10)",
         OutTemp       => C405PLBICUABUS_OUT(10),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(11),
         GlitchData    => C405PLBICUABUS11_GlitchData,
         OutSignalName => "C405PLBICUABUS(11)",
         OutTemp       => C405PLBICUABUS_OUT(11),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(12),
         GlitchData    => C405PLBICUABUS12_GlitchData,
         OutSignalName => "C405PLBICUABUS(12)",
         OutTemp       => C405PLBICUABUS_OUT(12),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(13),
         GlitchData    => C405PLBICUABUS13_GlitchData,
         OutSignalName => "C405PLBICUABUS(13)",
         OutTemp       => C405PLBICUABUS_OUT(13),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(14),
         GlitchData    => C405PLBICUABUS14_GlitchData,
         OutSignalName => "C405PLBICUABUS(14)",
         OutTemp       => C405PLBICUABUS_OUT(14),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(15),
         GlitchData    => C405PLBICUABUS15_GlitchData,
         OutSignalName => "C405PLBICUABUS(15)",
         OutTemp       => C405PLBICUABUS_OUT(15),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(16),
         GlitchData    => C405PLBICUABUS16_GlitchData,
         OutSignalName => "C405PLBICUABUS(16)",
         OutTemp       => C405PLBICUABUS_OUT(16),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(17),
         GlitchData    => C405PLBICUABUS17_GlitchData,
         OutSignalName => "C405PLBICUABUS(17)",
         OutTemp       => C405PLBICUABUS_OUT(17),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(18),
         GlitchData    => C405PLBICUABUS18_GlitchData,
         OutSignalName => "C405PLBICUABUS(18)",
         OutTemp       => C405PLBICUABUS_OUT(18),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(19),
         GlitchData    => C405PLBICUABUS19_GlitchData,
         OutSignalName => "C405PLBICUABUS(19)",
         OutTemp       => C405PLBICUABUS_OUT(19),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(20),
         GlitchData    => C405PLBICUABUS20_GlitchData,
         OutSignalName => "C405PLBICUABUS(20)",
         OutTemp       => C405PLBICUABUS_OUT(20),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(21),
         GlitchData    => C405PLBICUABUS21_GlitchData,
         OutSignalName => "C405PLBICUABUS(21)",
         OutTemp       => C405PLBICUABUS_OUT(21),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(22),
         GlitchData    => C405PLBICUABUS22_GlitchData,
         OutSignalName => "C405PLBICUABUS(22)",
         OutTemp       => C405PLBICUABUS_OUT(22),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(23),
         GlitchData    => C405PLBICUABUS23_GlitchData,
         OutSignalName => "C405PLBICUABUS(23)",
         OutTemp       => C405PLBICUABUS_OUT(23),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(24),
         GlitchData    => C405PLBICUABUS24_GlitchData,
         OutSignalName => "C405PLBICUABUS(24)",
         OutTemp       => C405PLBICUABUS_OUT(24),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(25),
         GlitchData    => C405PLBICUABUS25_GlitchData,
         OutSignalName => "C405PLBICUABUS(25)",
         OutTemp       => C405PLBICUABUS_OUT(25),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(26),
         GlitchData    => C405PLBICUABUS26_GlitchData,
         OutSignalName => "C405PLBICUABUS(26)",
         OutTemp       => C405PLBICUABUS_OUT(26),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(27),
         GlitchData    => C405PLBICUABUS27_GlitchData,
         OutSignalName => "C405PLBICUABUS(27)",
         OutTemp       => C405PLBICUABUS_OUT(27),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(28),
         GlitchData    => C405PLBICUABUS28_GlitchData,
         OutSignalName => "C405PLBICUABUS(28)",
         OutTemp       => C405PLBICUABUS_OUT(28),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUABUS(29),
         GlitchData    => C405PLBICUABUS29_GlitchData,
         OutSignalName => "C405PLBICUABUS(29)",
         OutTemp       => C405PLBICUABUS_OUT(29),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUPRIORITY(0),
         GlitchData    => C405PLBICUPRIORITY0_GlitchData,
         OutSignalName => "C405PLBICUPRIORITY(0)",
         OutTemp       => C405PLBICUPRIORITY_OUT(0),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUPRIORITY(1),
         GlitchData    => C405PLBICUPRIORITY1_GlitchData,
         OutSignalName => "C405PLBICUPRIORITY(1)",
         OutTemp       => C405PLBICUPRIORITY_OUT(1),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUSIZE(2),
         GlitchData    => C405PLBICUSIZE2_GlitchData,
         OutSignalName => "C405PLBICUSIZE(2)",
         OutTemp       => C405PLBICUSIZE_OUT(2),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405PLBICUSIZE(3),
         GlitchData    => C405PLBICUSIZE3_GlitchData,
         OutSignalName => "C405PLBICUSIZE(3)",
         OutTemp       => C405PLBICUSIZE_OUT(3),
         Paths         => (0 => (PLBCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCEVENEXECUTIONSTATUS(0),
         GlitchData    => C405TRCEVENEXECUTIONSTATUS0_GlitchData,
         OutSignalName => "C405TRCEVENEXECUTIONSTATUS(0)",
         OutTemp       => C405TRCEVENEXECUTIONSTATUS_OUT(0),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCEVENEXECUTIONSTATUS(1),
         GlitchData    => C405TRCEVENEXECUTIONSTATUS1_GlitchData,
         OutSignalName => "C405TRCEVENEXECUTIONSTATUS(1)",
         OutTemp       => C405TRCEVENEXECUTIONSTATUS_OUT(1),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCODDEXECUTIONSTATUS(0),
         GlitchData    => C405TRCODDEXECUTIONSTATUS0_GlitchData,
         OutSignalName => "C405TRCODDEXECUTIONSTATUS(0)",
         OutTemp       => C405TRCODDEXECUTIONSTATUS_OUT(0),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCODDEXECUTIONSTATUS(1),
         GlitchData    => C405TRCODDEXECUTIONSTATUS1_GlitchData,
         OutSignalName => "C405TRCODDEXECUTIONSTATUS(1)",
         OutTemp       => C405TRCODDEXECUTIONSTATUS_OUT(1),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRACESTATUS(0),
         GlitchData    => C405TRCTRACESTATUS0_GlitchData,
         OutSignalName => "C405TRCTRACESTATUS(0)",
         OutTemp       => C405TRCTRACESTATUS_OUT(0),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRACESTATUS(1),
         GlitchData    => C405TRCTRACESTATUS1_GlitchData,
         OutSignalName => "C405TRCTRACESTATUS(1)",
         OutTemp       => C405TRCTRACESTATUS_OUT(1),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRACESTATUS(2),
         GlitchData    => C405TRCTRACESTATUS2_GlitchData,
         OutSignalName => "C405TRCTRACESTATUS(2)",
         OutTemp       => C405TRCTRACESTATUS_OUT(2),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRACESTATUS(3),
         GlitchData    => C405TRCTRACESTATUS3_GlitchData,
         OutSignalName => "C405TRCTRACESTATUS(3)",
         OutTemp       => C405TRCTRACESTATUS_OUT(3),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(0),
         GlitchData    => C405TRCTRIGGEREVENTTYPE0_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(0)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(0),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(1),
         GlitchData    => C405TRCTRIGGEREVENTTYPE1_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(1)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(1),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(2),
         GlitchData    => C405TRCTRIGGEREVENTTYPE2_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(2)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(2),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(3),
         GlitchData    => C405TRCTRIGGEREVENTTYPE3_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(3)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(3),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(4),
         GlitchData    => C405TRCTRIGGEREVENTTYPE4_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(4)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(4),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(5),
         GlitchData    => C405TRCTRIGGEREVENTTYPE5_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(5)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(5),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(6),
         GlitchData    => C405TRCTRIGGEREVENTTYPE6_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(6)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(6),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(7),
         GlitchData    => C405TRCTRIGGEREVENTTYPE7_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(7)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(7),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(8),
         GlitchData    => C405TRCTRIGGEREVENTTYPE8_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(8)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(8),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(9),
         GlitchData    => C405TRCTRIGGEREVENTTYPE9_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(9)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(9),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => C405TRCTRIGGEREVENTTYPE(10),
         GlitchData    => C405TRCTRIGGEREVENTTYPE10_GlitchData,
         OutSignalName => "C405TRCTRIGGEREVENTTYPE(10)",
         OutTemp       => C405TRCTRIGGEREVENTTYPE_OUT(10),
         Paths         => (0 => (CPMC405CLOCK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(8),
         GlitchData    => DSOCMBRAMABUS8_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(8)",
         OutTemp       => DSOCMBRAMABUS_OUT(8),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(9),
         GlitchData    => DSOCMBRAMABUS9_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(9)",
         OutTemp       => DSOCMBRAMABUS_OUT(9),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(10),
         GlitchData    => DSOCMBRAMABUS10_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(10)",
         OutTemp       => DSOCMBRAMABUS_OUT(10),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(11),
         GlitchData    => DSOCMBRAMABUS11_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(11)",
         OutTemp       => DSOCMBRAMABUS_OUT(11),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(12),
         GlitchData    => DSOCMBRAMABUS12_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(12)",
         OutTemp       => DSOCMBRAMABUS_OUT(12),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(13),
         GlitchData    => DSOCMBRAMABUS13_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(13)",
         OutTemp       => DSOCMBRAMABUS_OUT(13),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(14),
         GlitchData    => DSOCMBRAMABUS14_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(14)",
         OutTemp       => DSOCMBRAMABUS_OUT(14),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(15),
         GlitchData    => DSOCMBRAMABUS15_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(15)",
         OutTemp       => DSOCMBRAMABUS_OUT(15),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(16),
         GlitchData    => DSOCMBRAMABUS16_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(16)",
         OutTemp       => DSOCMBRAMABUS_OUT(16),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(17),
         GlitchData    => DSOCMBRAMABUS17_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(17)",
         OutTemp       => DSOCMBRAMABUS_OUT(17),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(18),
         GlitchData    => DSOCMBRAMABUS18_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(18)",
         OutTemp       => DSOCMBRAMABUS_OUT(18),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(19),
         GlitchData    => DSOCMBRAMABUS19_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(19)",
         OutTemp       => DSOCMBRAMABUS_OUT(19),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(20),
         GlitchData    => DSOCMBRAMABUS20_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(20)",
         OutTemp       => DSOCMBRAMABUS_OUT(20),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(21),
         GlitchData    => DSOCMBRAMABUS21_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(21)",
         OutTemp       => DSOCMBRAMABUS_OUT(21),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(22),
         GlitchData    => DSOCMBRAMABUS22_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(22)",
         OutTemp       => DSOCMBRAMABUS_OUT(22),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(23),
         GlitchData    => DSOCMBRAMABUS23_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(23)",
         OutTemp       => DSOCMBRAMABUS_OUT(23),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(24),
         GlitchData    => DSOCMBRAMABUS24_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(24)",
         OutTemp       => DSOCMBRAMABUS_OUT(24),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(25),
         GlitchData    => DSOCMBRAMABUS25_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(25)",
         OutTemp       => DSOCMBRAMABUS_OUT(25),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(26),
         GlitchData    => DSOCMBRAMABUS26_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(26)",
         OutTemp       => DSOCMBRAMABUS_OUT(26),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(27),
         GlitchData    => DSOCMBRAMABUS27_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(27)",
         OutTemp       => DSOCMBRAMABUS_OUT(27),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(28),
         GlitchData    => DSOCMBRAMABUS28_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(28)",
         OutTemp       => DSOCMBRAMABUS_OUT(28),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMABUS(29),
         GlitchData    => DSOCMBRAMABUS29_GlitchData,
         OutSignalName => "DSOCMBRAMABUS(29)",
         OutTemp       => DSOCMBRAMABUS_OUT(29),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMBYTEWRITE(0),
         GlitchData    => DSOCMBRAMBYTEWRITE0_GlitchData,
         OutSignalName => "DSOCMBRAMBYTEWRITE(0)",
         OutTemp       => DSOCMBRAMBYTEWRITE_OUT(0),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMBYTEWRITE(1),
         GlitchData    => DSOCMBRAMBYTEWRITE1_GlitchData,
         OutSignalName => "DSOCMBRAMBYTEWRITE(1)",
         OutTemp       => DSOCMBRAMBYTEWRITE_OUT(1),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMBYTEWRITE(2),
         GlitchData    => DSOCMBRAMBYTEWRITE2_GlitchData,
         OutSignalName => "DSOCMBRAMBYTEWRITE(2)",
         OutTemp       => DSOCMBRAMBYTEWRITE_OUT(2),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMBYTEWRITE(3),
         GlitchData    => DSOCMBRAMBYTEWRITE3_GlitchData,
         OutSignalName => "DSOCMBRAMBYTEWRITE(3)",
         OutTemp       => DSOCMBRAMBYTEWRITE_OUT(3),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(0),
         GlitchData    => DSOCMBRAMWRDBUS0_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(0)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(0),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(1),
         GlitchData    => DSOCMBRAMWRDBUS1_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(1)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(1),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(2),
         GlitchData    => DSOCMBRAMWRDBUS2_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(2)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(2),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(3),
         GlitchData    => DSOCMBRAMWRDBUS3_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(3)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(3),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(4),
         GlitchData    => DSOCMBRAMWRDBUS4_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(4)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(4),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(5),
         GlitchData    => DSOCMBRAMWRDBUS5_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(5)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(5),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(6),
         GlitchData    => DSOCMBRAMWRDBUS6_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(6)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(6),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(7),
         GlitchData    => DSOCMBRAMWRDBUS7_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(7)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(7),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(8),
         GlitchData    => DSOCMBRAMWRDBUS8_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(8)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(8),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(9),
         GlitchData    => DSOCMBRAMWRDBUS9_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(9)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(9),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(10),
         GlitchData    => DSOCMBRAMWRDBUS10_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(10)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(10),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(11),
         GlitchData    => DSOCMBRAMWRDBUS11_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(11)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(11),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(12),
         GlitchData    => DSOCMBRAMWRDBUS12_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(12)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(12),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(13),
         GlitchData    => DSOCMBRAMWRDBUS13_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(13)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(13),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(14),
         GlitchData    => DSOCMBRAMWRDBUS14_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(14)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(14),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(15),
         GlitchData    => DSOCMBRAMWRDBUS15_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(15)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(15),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(16),
         GlitchData    => DSOCMBRAMWRDBUS16_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(16)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(16),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(17),
         GlitchData    => DSOCMBRAMWRDBUS17_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(17)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(17),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(18),
         GlitchData    => DSOCMBRAMWRDBUS18_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(18)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(18),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(19),
         GlitchData    => DSOCMBRAMWRDBUS19_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(19)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(19),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(20),
         GlitchData    => DSOCMBRAMWRDBUS20_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(20)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(20),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(21),
         GlitchData    => DSOCMBRAMWRDBUS21_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(21)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(21),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(22),
         GlitchData    => DSOCMBRAMWRDBUS22_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(22)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(22),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(23),
         GlitchData    => DSOCMBRAMWRDBUS23_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(23)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(23),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(24),
         GlitchData    => DSOCMBRAMWRDBUS24_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(24)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(24),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(25),
         GlitchData    => DSOCMBRAMWRDBUS25_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(25)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(25),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(26),
         GlitchData    => DSOCMBRAMWRDBUS26_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(26)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(26),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(27),
         GlitchData    => DSOCMBRAMWRDBUS27_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(27)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(27),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(28),
         GlitchData    => DSOCMBRAMWRDBUS28_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(28)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(28),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(29),
         GlitchData    => DSOCMBRAMWRDBUS29_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(29)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(29),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(30),
         GlitchData    => DSOCMBRAMWRDBUS30_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(30)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(30),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => DSOCMBRAMWRDBUS(31),
         GlitchData    => DSOCMBRAMWRDBUS31_GlitchData,
         OutSignalName => "DSOCMBRAMWRDBUS(31)",
         OutTemp       => DSOCMBRAMWRDBUS_OUT(31),
         Paths         => (0 => (BRAMDSOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(0),
         GlitchData    => EXTDCRABUS0_GlitchData,
         OutSignalName => "EXTDCRABUS(0)",
         OutTemp       => EXTDCRABUS_OUT(0),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(1),
         GlitchData    => EXTDCRABUS1_GlitchData,
         OutSignalName => "EXTDCRABUS(1)",
         OutTemp       => EXTDCRABUS_OUT(1),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(2),
         GlitchData    => EXTDCRABUS2_GlitchData,
         OutSignalName => "EXTDCRABUS(2)",
         OutTemp       => EXTDCRABUS_OUT(2),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(3),
         GlitchData    => EXTDCRABUS3_GlitchData,
         OutSignalName => "EXTDCRABUS(3)",
         OutTemp       => EXTDCRABUS_OUT(3),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(4),
         GlitchData    => EXTDCRABUS4_GlitchData,
         OutSignalName => "EXTDCRABUS(4)",
         OutTemp       => EXTDCRABUS_OUT(4),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(5),
         GlitchData    => EXTDCRABUS5_GlitchData,
         OutSignalName => "EXTDCRABUS(5)",
         OutTemp       => EXTDCRABUS_OUT(5),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(6),
         GlitchData    => EXTDCRABUS6_GlitchData,
         OutSignalName => "EXTDCRABUS(6)",
         OutTemp       => EXTDCRABUS_OUT(6),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(7),
         GlitchData    => EXTDCRABUS7_GlitchData,
         OutSignalName => "EXTDCRABUS(7)",
         OutTemp       => EXTDCRABUS_OUT(7),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(8),
         GlitchData    => EXTDCRABUS8_GlitchData,
         OutSignalName => "EXTDCRABUS(8)",
         OutTemp       => EXTDCRABUS_OUT(8),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRABUS(9),
         GlitchData    => EXTDCRABUS9_GlitchData,
         OutSignalName => "EXTDCRABUS(9)",
         OutTemp       => EXTDCRABUS_OUT(9),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(0),
         GlitchData    => EXTDCRDBUSOUT0_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(0)",
         OutTemp       => EXTDCRDBUSOUT_OUT(0),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(1),
         GlitchData    => EXTDCRDBUSOUT1_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(1)",
         OutTemp       => EXTDCRDBUSOUT_OUT(1),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(2),
         GlitchData    => EXTDCRDBUSOUT2_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(2)",
         OutTemp       => EXTDCRDBUSOUT_OUT(2),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(3),
         GlitchData    => EXTDCRDBUSOUT3_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(3)",
         OutTemp       => EXTDCRDBUSOUT_OUT(3),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(4),
         GlitchData    => EXTDCRDBUSOUT4_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(4)",
         OutTemp       => EXTDCRDBUSOUT_OUT(4),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(5),
         GlitchData    => EXTDCRDBUSOUT5_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(5)",
         OutTemp       => EXTDCRDBUSOUT_OUT(5),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(6),
         GlitchData    => EXTDCRDBUSOUT6_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(6)",
         OutTemp       => EXTDCRDBUSOUT_OUT(6),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(7),
         GlitchData    => EXTDCRDBUSOUT7_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(7)",
         OutTemp       => EXTDCRDBUSOUT_OUT(7),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(8),
         GlitchData    => EXTDCRDBUSOUT8_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(8)",
         OutTemp       => EXTDCRDBUSOUT_OUT(8),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(9),
         GlitchData    => EXTDCRDBUSOUT9_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(9)",
         OutTemp       => EXTDCRDBUSOUT_OUT(9),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(10),
         GlitchData    => EXTDCRDBUSOUT10_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(10)",
         OutTemp       => EXTDCRDBUSOUT_OUT(10),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(11),
         GlitchData    => EXTDCRDBUSOUT11_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(11)",
         OutTemp       => EXTDCRDBUSOUT_OUT(11),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(12),
         GlitchData    => EXTDCRDBUSOUT12_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(12)",
         OutTemp       => EXTDCRDBUSOUT_OUT(12),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(13),
         GlitchData    => EXTDCRDBUSOUT13_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(13)",
         OutTemp       => EXTDCRDBUSOUT_OUT(13),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(14),
         GlitchData    => EXTDCRDBUSOUT14_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(14)",
         OutTemp       => EXTDCRDBUSOUT_OUT(14),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(15),
         GlitchData    => EXTDCRDBUSOUT15_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(15)",
         OutTemp       => EXTDCRDBUSOUT_OUT(15),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(16),
         GlitchData    => EXTDCRDBUSOUT16_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(16)",
         OutTemp       => EXTDCRDBUSOUT_OUT(16),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(17),
         GlitchData    => EXTDCRDBUSOUT17_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(17)",
         OutTemp       => EXTDCRDBUSOUT_OUT(17),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(18),
         GlitchData    => EXTDCRDBUSOUT18_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(18)",
         OutTemp       => EXTDCRDBUSOUT_OUT(18),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(19),
         GlitchData    => EXTDCRDBUSOUT19_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(19)",
         OutTemp       => EXTDCRDBUSOUT_OUT(19),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(20),
         GlitchData    => EXTDCRDBUSOUT20_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(20)",
         OutTemp       => EXTDCRDBUSOUT_OUT(20),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(21),
         GlitchData    => EXTDCRDBUSOUT21_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(21)",
         OutTemp       => EXTDCRDBUSOUT_OUT(21),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(22),
         GlitchData    => EXTDCRDBUSOUT22_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(22)",
         OutTemp       => EXTDCRDBUSOUT_OUT(22),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(23),
         GlitchData    => EXTDCRDBUSOUT23_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(23)",
         OutTemp       => EXTDCRDBUSOUT_OUT(23),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(24),
         GlitchData    => EXTDCRDBUSOUT24_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(24)",
         OutTemp       => EXTDCRDBUSOUT_OUT(24),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(25),
         GlitchData    => EXTDCRDBUSOUT25_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(25)",
         OutTemp       => EXTDCRDBUSOUT_OUT(25),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(26),
         GlitchData    => EXTDCRDBUSOUT26_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(26)",
         OutTemp       => EXTDCRDBUSOUT_OUT(26),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(27),
         GlitchData    => EXTDCRDBUSOUT27_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(27)",
         OutTemp       => EXTDCRDBUSOUT_OUT(27),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(28),
         GlitchData    => EXTDCRDBUSOUT28_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(28)",
         OutTemp       => EXTDCRDBUSOUT_OUT(28),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(29),
         GlitchData    => EXTDCRDBUSOUT29_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(29)",
         OutTemp       => EXTDCRDBUSOUT_OUT(29),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(30),
         GlitchData    => EXTDCRDBUSOUT30_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(30)",
         OutTemp       => EXTDCRDBUSOUT_OUT(30),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => EXTDCRDBUSOUT(31),
         GlitchData    => EXTDCRDBUSOUT31_GlitchData,
         OutSignalName => "EXTDCRDBUSOUT(31)",
         OutTemp       => EXTDCRDBUSOUT_OUT(31),
         Paths         => (0 => (CPMDCRCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(8),
         GlitchData    => ISOCMBRAMRDABUS8_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(8)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(8),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(9),
         GlitchData    => ISOCMBRAMRDABUS9_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(9)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(9),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(10),
         GlitchData    => ISOCMBRAMRDABUS10_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(10)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(10),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(11),
         GlitchData    => ISOCMBRAMRDABUS11_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(11)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(11),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(12),
         GlitchData    => ISOCMBRAMRDABUS12_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(12)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(12),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(13),
         GlitchData    => ISOCMBRAMRDABUS13_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(13)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(13),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(14),
         GlitchData    => ISOCMBRAMRDABUS14_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(14)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(14),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(15),
         GlitchData    => ISOCMBRAMRDABUS15_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(15)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(15),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(16),
         GlitchData    => ISOCMBRAMRDABUS16_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(16)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(16),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(17),
         GlitchData    => ISOCMBRAMRDABUS17_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(17)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(17),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(18),
         GlitchData    => ISOCMBRAMRDABUS18_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(18)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(18),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(19),
         GlitchData    => ISOCMBRAMRDABUS19_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(19)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(19),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(20),
         GlitchData    => ISOCMBRAMRDABUS20_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(20)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(20),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(21),
         GlitchData    => ISOCMBRAMRDABUS21_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(21)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(21),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(22),
         GlitchData    => ISOCMBRAMRDABUS22_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(22)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(22),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(23),
         GlitchData    => ISOCMBRAMRDABUS23_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(23)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(23),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(24),
         GlitchData    => ISOCMBRAMRDABUS24_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(24)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(24),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(25),
         GlitchData    => ISOCMBRAMRDABUS25_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(25)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(25),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(26),
         GlitchData    => ISOCMBRAMRDABUS26_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(26)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(26),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(27),
         GlitchData    => ISOCMBRAMRDABUS27_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(27)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(27),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMRDABUS(28),
         GlitchData    => ISOCMBRAMRDABUS28_GlitchData,
         OutSignalName => "ISOCMBRAMRDABUS(28)",
         OutTemp       => ISOCMBRAMRDABUS_OUT(28),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(8),
         GlitchData    => ISOCMBRAMWRABUS8_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(8)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(8),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(9),
         GlitchData    => ISOCMBRAMWRABUS9_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(9)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(9),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(10),
         GlitchData    => ISOCMBRAMWRABUS10_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(10)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(10),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(11),
         GlitchData    => ISOCMBRAMWRABUS11_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(11)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(11),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(12),
         GlitchData    => ISOCMBRAMWRABUS12_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(12)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(12),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(13),
         GlitchData    => ISOCMBRAMWRABUS13_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(13)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(13),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(14),
         GlitchData    => ISOCMBRAMWRABUS14_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(14)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(14),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(15),
         GlitchData    => ISOCMBRAMWRABUS15_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(15)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(15),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(16),
         GlitchData    => ISOCMBRAMWRABUS16_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(16)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(16),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(17),
         GlitchData    => ISOCMBRAMWRABUS17_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(17)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(17),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(18),
         GlitchData    => ISOCMBRAMWRABUS18_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(18)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(18),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(19),
         GlitchData    => ISOCMBRAMWRABUS19_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(19)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(19),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(20),
         GlitchData    => ISOCMBRAMWRABUS20_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(20)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(20),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(21),
         GlitchData    => ISOCMBRAMWRABUS21_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(21)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(21),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(22),
         GlitchData    => ISOCMBRAMWRABUS22_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(22)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(22),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(23),
         GlitchData    => ISOCMBRAMWRABUS23_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(23)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(23),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(24),
         GlitchData    => ISOCMBRAMWRABUS24_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(24)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(24),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(25),
         GlitchData    => ISOCMBRAMWRABUS25_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(25)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(25),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(26),
         GlitchData    => ISOCMBRAMWRABUS26_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(26)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(26),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(27),
         GlitchData    => ISOCMBRAMWRABUS27_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(27)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(27),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRABUS(28),
         GlitchData    => ISOCMBRAMWRABUS28_GlitchData,
         OutSignalName => "ISOCMBRAMWRABUS(28)",
         OutTemp       => ISOCMBRAMWRABUS_OUT(28),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(0),
         GlitchData    => ISOCMBRAMWRDBUS0_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(0)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(0),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(1),
         GlitchData    => ISOCMBRAMWRDBUS1_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(1)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(1),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(2),
         GlitchData    => ISOCMBRAMWRDBUS2_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(2)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(2),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(3),
         GlitchData    => ISOCMBRAMWRDBUS3_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(3)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(3),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(4),
         GlitchData    => ISOCMBRAMWRDBUS4_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(4)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(4),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(5),
         GlitchData    => ISOCMBRAMWRDBUS5_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(5)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(5),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(6),
         GlitchData    => ISOCMBRAMWRDBUS6_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(6)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(6),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(7),
         GlitchData    => ISOCMBRAMWRDBUS7_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(7)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(7),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(8),
         GlitchData    => ISOCMBRAMWRDBUS8_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(8)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(8),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(9),
         GlitchData    => ISOCMBRAMWRDBUS9_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(9)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(9),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(10),
         GlitchData    => ISOCMBRAMWRDBUS10_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(10)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(10),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(11),
         GlitchData    => ISOCMBRAMWRDBUS11_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(11)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(11),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(12),
         GlitchData    => ISOCMBRAMWRDBUS12_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(12)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(12),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(13),
         GlitchData    => ISOCMBRAMWRDBUS13_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(13)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(13),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(14),
         GlitchData    => ISOCMBRAMWRDBUS14_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(14)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(14),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(15),
         GlitchData    => ISOCMBRAMWRDBUS15_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(15)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(15),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(16),
         GlitchData    => ISOCMBRAMWRDBUS16_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(16)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(16),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(17),
         GlitchData    => ISOCMBRAMWRDBUS17_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(17)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(17),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(18),
         GlitchData    => ISOCMBRAMWRDBUS18_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(18)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(18),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(19),
         GlitchData    => ISOCMBRAMWRDBUS19_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(19)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(19),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(20),
         GlitchData    => ISOCMBRAMWRDBUS20_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(20)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(20),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(21),
         GlitchData    => ISOCMBRAMWRDBUS21_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(21)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(21),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(22),
         GlitchData    => ISOCMBRAMWRDBUS22_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(22)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(22),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(23),
         GlitchData    => ISOCMBRAMWRDBUS23_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(23)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(23),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(24),
         GlitchData    => ISOCMBRAMWRDBUS24_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(24)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(24),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(25),
         GlitchData    => ISOCMBRAMWRDBUS25_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(25)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(25),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(26),
         GlitchData    => ISOCMBRAMWRDBUS26_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(26)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(26),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(27),
         GlitchData    => ISOCMBRAMWRDBUS27_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(27)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(27),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(28),
         GlitchData    => ISOCMBRAMWRDBUS28_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(28)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(28),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(29),
         GlitchData    => ISOCMBRAMWRDBUS29_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(29)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(29),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(30),
         GlitchData    => ISOCMBRAMWRDBUS30_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(30)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(30),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );
     VitalPathDelay01
       (
         OutSignal     => ISOCMBRAMWRDBUS(31),
         GlitchData    => ISOCMBRAMWRDBUS31_GlitchData,
         OutSignalName => "ISOCMBRAMWRDBUS(31)",
         OutTemp       => ISOCMBRAMWRDBUS_OUT(31),
         Paths         => (0 => (BRAMISOCMCLK_ipd_1'last_event, OUT_DELAY,TRUE)),
	 DefaultDelay  => OUT_DELAY, 
         Mode          => VitalTransport,
         Xon           => false,
         MsgOn         => false,
         MsgSeverity   => WARNING
       );

--  Wait signal (input/output pins)
   wait on
     APUFCMDECODED_OUT,
     APUFCMDECUDI_OUT,
     APUFCMDECUDIVALID_OUT,
     APUFCMENDIAN_OUT,
     APUFCMFLUSH_OUT,
     APUFCMINSTRUCTION_OUT,
     APUFCMINSTRVALID_OUT,
     APUFCMLOADBYTEEN_OUT,
     APUFCMLOADDATA_OUT,
     APUFCMLOADDVALID_OUT,
     APUFCMOPERANDVALID_OUT,
     APUFCMRADATA_OUT,
     APUFCMRBDATA_OUT,
     APUFCMWRITEBACKOK_OUT,
     APUFCMXERCA_OUT,
     BRAMDSOCMCLK_ipd_1,
     BRAMDSOCMRDDBUS_ipd_1,
     BRAMISOCMCLK_ipd_1,
     BRAMISOCMDCRRDDBUS_ipd_1,
     BRAMISOCMRDDBUS_ipd_1,
     C405CPMCORESLEEPREQ_OUT,
     C405CPMMSRCE_OUT,
     C405CPMMSREE_OUT,
     C405CPMTIMERIRQ_OUT,
     C405CPMTIMERRESETREQ_OUT,
     C405DBGLOADDATAONAPUDBUS_OUT,
     C405DBGMSRWE_OUT,
     C405DBGSTOPACK_OUT,
     C405DBGWBCOMPLETE_OUT,
     C405DBGWBFULL_OUT,
     C405DBGWBIAR_OUT,
     C405JTGCAPTUREDR_OUT,
     C405JTGEXTEST_OUT,
     C405JTGPGMOUT_OUT,
     C405JTGSHIFTDR_OUT,
     C405JTGTDO_OUT,
     C405JTGTDOEN_OUT,
     C405JTGUPDATEDR_OUT,
     C405PLBDCUABORT_OUT,
     C405PLBDCUABUS_OUT,
     C405PLBDCUBE_OUT,
     C405PLBDCUCACHEABLE_OUT,
     C405PLBDCUGUARDED_OUT,
     C405PLBDCUPRIORITY_OUT,
     C405PLBDCUREQUEST_OUT,
     C405PLBDCURNW_OUT,
     C405PLBDCUSIZE2_OUT,
     C405PLBDCUU0ATTR_OUT,
     C405PLBDCUWRDBUS_OUT,
     C405PLBDCUWRITETHRU_OUT,
     C405PLBICUABORT_OUT,
     C405PLBICUABUS_OUT,
     C405PLBICUCACHEABLE_OUT,
     C405PLBICUPRIORITY_OUT,
     C405PLBICUREQUEST_OUT,
     C405PLBICUSIZE_OUT,
     C405PLBICUU0ATTR_OUT,
     C405RSTCHIPRESETREQ_OUT,
     C405RSTCORERESETREQ_OUT,
     C405RSTSYSRESETREQ_OUT,
     C405TRCCYCLE_OUT,
     C405TRCEVENEXECUTIONSTATUS_OUT,
     C405TRCODDEXECUTIONSTATUS_OUT,
     C405TRCTRACESTATUS_OUT,
     C405TRCTRIGGEREVENTOUT_OUT,
     C405TRCTRIGGEREVENTTYPE_OUT,
     C405XXXMACHINECHECK_OUT,
     CPMC405CLOCK_ipd_1,
     CPMC405CORECLKINACTIVE_ipd_1,
     CPMC405CPUCLKEN_ipd_1,
     CPMC405JTAGCLKEN_ipd_1,
     CPMC405SYNCBYPASS_ipd_1,
     CPMC405TIMERCLKEN_ipd_1,
     CPMC405TIMERTICK_ipd_1,
     CPMDCRCLK_ipd_1,
     CPMFCMCLK_ipd_1,
     DBGC405DEBUGHALT_ipd_1,
     DBGC405EXTBUSHOLDACK_ipd_1,
     DBGC405UNCONDDEBUGEVENT_ipd_1,
     DCREMACENABLER_OUT,
     DSARCVALUE_ipd_1,
     DSCNTLVALUE_ipd_1,
     DSOCMBRAMABUS_OUT,
     DSOCMBRAMBYTEWRITE_OUT,
     DSOCMBRAMEN_OUT,
     DSOCMBRAMWRDBUS_OUT,
     DSOCMBUSY_OUT,
     DSOCMRDADDRVALID_OUT,
     DSOCMRWCOMPLETE_ipd_1,
     DSOCMWRADDRVALID_OUT,
     EICC405CRITINPUTIRQ_ipd_1,
     EICC405EXTINPUTIRQ_ipd_1,
     EXTDCRABUS_OUT,
     EXTDCRACK_ipd_1,
     EXTDCRDBUSIN_ipd_1,
     EXTDCRDBUSOUT_OUT,
     EXTDCRREAD_OUT,
     EXTDCRWRITE_OUT,
     FCMAPUCR_ipd_1,
     FCMAPUDCDCREN_ipd_1,
     FCMAPUDCDFORCEALIGN_ipd_1,
     FCMAPUDCDFORCEBESTEERING_ipd_1,
     FCMAPUDCDFPUOP_ipd_1,
     FCMAPUDCDGPRWRITE_ipd_1,
     FCMAPUDCDLDSTBYTE_ipd_1,
     FCMAPUDCDLDSTDW_ipd_1,
     FCMAPUDCDLDSTHW_ipd_1,
     FCMAPUDCDLDSTQW_ipd_1,
     FCMAPUDCDLDSTWD_ipd_1,
     FCMAPUDCDLOAD_ipd_1,
     FCMAPUDCDPRIVOP_ipd_1,
     FCMAPUDCDRAEN_ipd_1,
     FCMAPUDCDRBEN_ipd_1,
     FCMAPUDCDSTORE_ipd_1,
     FCMAPUDCDTRAPBE_ipd_1,
     FCMAPUDCDTRAPLE_ipd_1,
     FCMAPUDCDUPDATE_ipd_1,
     FCMAPUDCDXERCAEN_ipd_1,
     FCMAPUDCDXEROVEN_ipd_1,
     FCMAPUDECODEBUSY_ipd_1,
     FCMAPUDONE_ipd_1,
     FCMAPUEXCEPTION_ipd_1,
     FCMAPUEXEBLOCKINGMCO_ipd_1,
     FCMAPUEXECRFIELD_ipd_1,
     FCMAPUEXENONBLOCKINGMCO_ipd_1,
     FCMAPUINSTRACK_ipd_1,
     FCMAPULOADWAIT_ipd_1,
     FCMAPURESULT_ipd_1,
     FCMAPURESULTVALID_ipd_1,
     FCMAPUSLEEPNOTREADY_ipd_1,
     FCMAPUXERCA_ipd_1,
     FCMAPUXEROV_ipd_1,
     ISARCVALUE_ipd_1,
     ISCNTLVALUE_ipd_1,
     ISOCMBRAMEN_OUT,
     ISOCMBRAMEVENWRITEEN_OUT,
     ISOCMBRAMODDWRITEEN_OUT,
     ISOCMBRAMRDABUS_OUT,
     ISOCMBRAMWRABUS_OUT,
     ISOCMBRAMWRDBUS_OUT,
     ISOCMDCRBRAMEVENEN_OUT,
     ISOCMDCRBRAMODDEN_OUT,
     ISOCMDCRBRAMRDSELECT_OUT,
     JTGC405BNDSCANTDO_ipd_1,
     JTGC405TCK_ipd_1,
     JTGC405TDI_ipd_1,
     JTGC405TMS_ipd_1,
     JTGC405TRSTNEG_ipd_1,
     MCBCPUCLKEN_ipd_1,
     MCBJTAGEN_ipd_1,
     MCBTIMEREN_ipd_1,
     MCPPCRST_ipd_1,
     PLBC405DCUADDRACK_ipd_1,
     PLBC405DCUBUSY_ipd_1,
     PLBC405DCUERR_ipd_1,
     PLBC405DCURDDACK_ipd_1,
     PLBC405DCURDDBUS_ipd_1,
     PLBC405DCURDWDADDR_ipd_1,
     PLBC405DCUSSIZE1_ipd_1,
     PLBC405DCUWRDACK_ipd_1,
     PLBC405ICUADDRACK_ipd_1,
     PLBC405ICUBUSY_ipd_1,
     PLBC405ICUERR_ipd_1,
     PLBC405ICURDDACK_ipd_1,
     PLBC405ICURDDBUS_ipd_1,
     PLBC405ICURDWDADDR_ipd_1,
     PLBC405ICUSSIZE1_ipd_1,
     PLBCLK_ipd_1,
     RSTC405RESETCHIP_ipd_1,
     RSTC405RESETCORE_ipd_1,
     RSTC405RESETSYS_ipd_1,
     TIEAPUCONTROL_ipd_1,
     TIEAPUUDI1_ipd_1,
     TIEAPUUDI2_ipd_1,
     TIEAPUUDI3_ipd_1,
     TIEAPUUDI4_ipd_1,
     TIEAPUUDI5_ipd_1,
     TIEAPUUDI6_ipd_1,
     TIEAPUUDI7_ipd_1,
     TIEAPUUDI8_ipd_1,
     TIEC405DETERMINISTICMULT_ipd_1,
     TIEC405DISOPERANDFWD_ipd_1,
     TIEC405MMUEN_ipd_1,
     TIEDCRADDR_ipd_1,
     TIEPVRBIT10_ipd_1,
     TIEPVRBIT11_ipd_1,
     TIEPVRBIT28_ipd_1,
     TIEPVRBIT29_ipd_1,
     TIEPVRBIT30_ipd_1,
     TIEPVRBIT31_ipd_1,
     TIEPVRBIT8_ipd_1,
     TIEPVRBIT9_ipd_1,
     TRCC405TRACEDISABLE_ipd_1,
     TRCC405TRIGGEREVENTIN_ipd_1,
     DCREMACWRITE_OUT,
     DCREMACREAD_OUT,
     DCREMACDBUS_OUT,
     DCREMACABUS_OUT,
     DCREMACCLK_OUT,
     EMACDCRDBUS_ipd_1,
     EMACDCRACK_ipd_1;

   end process TIMING;
--C405PLBICUSIZE <= C405PLBICUSIZE_OUT after OUT_DELAY(tr01);
DCREMACABUS <= DCREMACABUS_OUT;
DCREMACCLK <= DCREMACCLK_OUT;
DCREMACDBUS <= DCREMACDBUS_OUT;
DCREMACENABLER <= DCREMACENABLER_OUT;
DCREMACREAD <= DCREMACREAD_OUT;
DCREMACWRITE <= DCREMACWRITE_OUT;
--DSOCMBRAMABUS <= DSOCMBRAMABUS_OUT after OUT_DELAY(tr01);
--ISOCMBRAMRDABUS <= ISOCMBRAMRDABUS_OUT after OUT_DELAY(tr01);
--ISOCMBRAMWRABUS   <= ISOCMBRAMWRABUS_OUT after OUT_DELAY(tr01);     
end PPC405_ADV_V;


