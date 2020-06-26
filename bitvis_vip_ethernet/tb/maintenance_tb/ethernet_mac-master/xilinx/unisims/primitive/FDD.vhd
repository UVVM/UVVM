-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/cpld/VITAL/FDD.vhd,v 1.1 2008/06/19 16:59:21 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Dual Edge Triggered D Flip-Flop
-- /___/   /\     Filename : FDD.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:22 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL FDD -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity FDD is
   generic(
      TimingChecksOn: Boolean := TRUE;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := False;
      INIT                           :  bit := '0'  ;
      tpd_C_Q : VitalDelayType01 := (0.1 ns, 0.1 ns);
      tsetup_D_C_posedge_posedge : VitalDelayType := 0.000 ns;
      tsetup_D_C_negedge_posedge : VitalDelayType := 0.000 ns;
      thold_D_C_posedge_posedge : VitalDelayType := 0.000 ns;
      thold_D_C_negedge_posedge : VitalDelayType := 0.000 ns;
      tpw_C_posedge : VitalDelayType := 0.000 ns;
      tpw_C_negedge : VitalDelayType := 0.000 ns;
      tipd_D : VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_C : VitalDelayType01 := (0.000 ns, 0.000 ns)
      );

   port(
      Q                              :  out   STD_ULOGIC;

      C                              :  in    STD_ULOGIC;
      D                              :  in    STD_ULOGIC      
      );
attribute VITAL_LEVEL0 of FDD : entity is TRUE;
end FDD;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
library UNISIM;
use unisim.VPKG.all;
architecture FDD_V of FDD is
   --attribute VITAL_LEVEL1 of FDD_V : architecture is TRUE;

   SIGNAL D_ipd  : STD_ULOGIC := 'X';
   SIGNAL C_ipd  : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (D_ipd, D, tipd_D);
   VitalWireDelay (C_ipd, C, tipd_C);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process 

   -- timing check results
   VARIABLE Tviol_D_C_posedge   : STD_ULOGIC := '0';
   VARIABLE Tmkr_D_C_posedge    : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Pviol_C     : STD_ULOGIC := '0';
   VARIABLE PInfo_C     : VitalPeriodDataType := VitalPeriodDataInit;

   -- functionality results
   VARIABLE Violation : STD_ULOGIC := '0';
   VARIABLE PrevData_Q : STD_LOGIC_VECTOR(0 to 2);
   VARIABLE D_delayed : STD_ULOGIC := 'X';
   VARIABLE C_delayed : STD_ULOGIC := 'X';
   --VARIABLE Results : STD_LOGIC_VECTOR(1 to 1) := (others => 'X');
   VARIABLE Q_zd : STD_ULOGIC := TO_X01(INIT);
   VARIABLE FIRST_TIME : boolean := True ;

   -- output glitch detection variables
   VARIABLE Q_GlitchData        : VitalGlitchDataType;

   begin

    if (FIRST_TIME = TRUE) then

       Q <= Q_zd ;

       wait until (rising_edge(c_ipd) );

       C_delayed := C_ipd'last_value;
       D_delayed := D_ipd;


       FIRST_TIME := FALSE;
    end if;

      ------------------------
      --  Timing Check Section
      ------------------------
      if (TimingChecksOn) then
         VitalSetupHoldCheck (
          Violation               => Tviol_D_C_posedge,
          TimingData              => Tmkr_D_C_posedge,
          TestSignal              => D_ipd,
          TestSignalName          => "D",
          TestDelay               => 0 ns,
          RefSignal               => C_ipd,
          RefSignalName          => "C",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_D_C_posedge_posedge,
          SetupLow                => tsetup_D_C_negedge_posedge,
          HoldLow                => thold_D_C_posedge_posedge,
          HoldHigh                 => thold_D_C_negedge_posedge,
          CheckEnabled            => 
                           TRUE,
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/FDD",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalPeriodPulseCheck (
          Violation               => Pviol_C,
          PeriodData              => PInfo_C,
          TestSignal              => C_ipd,
          TestSignalName          => "C",
          TestDelay               => 0 ns,
          Period                  => 0 ns,
          PulseWidthHigh          => tpw_C_posedge,
          PulseWidthLow           => tpw_C_negedge,
          CheckEnabled            =>  TRUE,
          HeaderMsg               => InstancePath &"/FDD",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
      end if;

      -------------------------
      --  Functionality Section
      -------------------------
      Violation := Tviol_D_C_posedge or Pviol_C;
      VitalStateTable(
        Result => Q_zd,
        PreviousDataIn => PrevData_Q,
        StateTable => FDD_Q_tab,
        DataIn => (
               C_delayed, D_delayed, C_ipd));
      Q_zd := Violation XOR Q_zd;
      D_delayed := D_ipd;
      C_delayed := C_ipd;

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => Q,
       GlitchData => Q_GlitchData,
       OutSignalName => "Q",
       OutTemp => Q_zd,
       Paths => (0 => (C_ipd'last_event, tpd_C_Q, TRUE)),
       Mode => OnEvent,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

   wait on D_ipd, C_ipd;
end process;

end FDD_V;


