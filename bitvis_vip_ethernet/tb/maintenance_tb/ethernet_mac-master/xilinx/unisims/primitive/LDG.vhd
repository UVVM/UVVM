-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/LDG.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Transparent Datagate Latch
-- /___/   /\     Filename : LDG.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:00 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL LDG -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity LDG is
   generic(
      TimingChecksOn: Boolean := TRUE;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := False;
      INIT                           :  bit := '0'  ;
      tpd_D_Q : VitalDelayType01 := (0.100 ns, 0.100 ns);
      tpd_G_Q : VitalDelayType01 := (0.100 ns, 0.100 ns);
      tsetup_D_G_posedge_negedge : VitalDelayType := 0.000 ns;
      tsetup_D_G_negedge_negedge : VitalDelayType := 0.000 ns;
      thold_D_G_posedge_negedge : VitalDelayType := 0.000 ns;
      thold_D_G_negedge_negedge : VitalDelayType := 0.000 ns;
      tpw_G_posedge : VitalDelayType := 0.000 ns;
      tpw_G_negedge : VitalDelayType := 0.000 ns;
      tipd_D : VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_G : VitalDelayType01 := (0.000 ns, 0.000 ns)
      );

   port(
      Q                              :	out   STD_ULOGIC;
      D                              :	in    STD_ULOGIC;
      G                              :	in    STD_ULOGIC
      );
attribute VITAL_LEVEL0 of LDG : entity is TRUE;
end LDG;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
library UNISIM;
use UNISIM.VPKG.all;
architecture LDG_V of LDG is
   --attribute VITAL_LEVEL1 of LDG_V : architecture is TRUE;

   SIGNAL D_ipd	 : STD_ULOGIC := 'X';
   SIGNAL G_ipd	 : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (D_ipd, D, tipd_D);
   VitalWireDelay (G_ipd, G, tipd_G);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process 

   -- timing check results
   VARIABLE Tviol_D_G_negedge	: STD_ULOGIC := '0';
   VARIABLE Tmkr_D_G_negedge	: VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Pviol_G	: STD_ULOGIC := '0';
   VARIABLE PInfo_G	: VitalPeriodDataType := VitalPeriodDataInit;

   -- functionality results
   VARIABLE Violation : STD_ULOGIC := '0';
   VARIABLE PrevData_Q : STD_LOGIC_VECTOR(0 to 1);
   --VARIABLE Results : STD_LOGIC_VECTOR(1 to 1) := (others => 'X');
   VARIABLE Q_zd : STD_ULOGIC := TO_X01(INIT);
   VARIABLE FIRST_TIME : boolean := True ;
   --ALIAS Q_zd : STD_LOGIC is Results(1);

   -- output glitch detection variables
   VARIABLE Q_GlitchData	: VitalGlitchDataType;

   begin

   if (FIRST_TIME = TRUE) then

       Q <= Q_zd ;

       wait until (G_ipd = '0' or G_ipd = '1');
                  

       FIRST_TIME := FALSE;
    end if;


      ------------------------
      --  Timing Check Section
      ------------------------
      if (TimingChecksOn) then
         VitalSetupHoldCheck (
          Violation               => Tviol_D_G_negedge,
          TimingData              => Tmkr_D_G_negedge,
          TestSignal              => D_ipd,
          TestSignalName          => "D",
          TestDelay               => 0 ns,
          RefSignal               => G_ipd,
          RefSignalName           => "G",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_D_G_posedge_negedge,
          SetupLow                => tsetup_D_G_negedge_negedge,
          HoldHigh                => thold_D_G_posedge_negedge,
          HoldLow                 => thold_D_G_negedge_negedge,
          CheckEnabled            => TRUE,
          RefTransition           => 'F',
          HeaderMsg               => InstancePath & "/LD",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalPeriodPulseCheck (
          Violation               => Pviol_G,
          PeriodData              => PInfo_G,
          TestSignal              => G_ipd,
          TestSignalName          => "G",
          TestDelay               => 0 ns,
          Period                  => 0 ns,
          PulseWidthHigh          => tpw_G_posedge,
          PulseWidthLow           => tpw_G_negedge,
          CheckEnabled            => TRUE,
          HeaderMsg               => InstancePath &"/LD",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
      end if;

      -------------------------
      --  Functionality Section
      -------------------------
      Violation := Tviol_D_G_negedge or Pviol_G;
      VitalStateTable(
        Result => Q_zd,
        PreviousDataIn => PrevData_Q,
        StateTable => ILDI_1_Q_tab,
        DataIn => (
               G_ipd, D_ipd));
      Q_zd := Violation XOR Q_zd;

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => Q,
       GlitchData => Q_GlitchData,
       OutSignalName => "Q",
       OutTemp => Q_zd,
       Paths => (0 => (D_ipd'last_event, tpd_D_Q, TRUE),
                 1 => (G_ipd'last_event, tpd_G_Q, TRUE)),
       Mode => OnEvent,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

wait on D_ipd, G_ipd;
end process;

end LDG_V;



