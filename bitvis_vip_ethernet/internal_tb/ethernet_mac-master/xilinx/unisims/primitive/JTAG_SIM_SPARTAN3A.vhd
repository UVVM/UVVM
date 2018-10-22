-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Jtag TAP contorller for SPARTAN3A 
--  /   /         
-- /___/   /\     Filename : JTAG_SIM_SPARTAN3A.vhd
-- \   \  /  \    Timestamp : Mon Aug  8 18:09:16 PDT 2005
--  \___\/\___\
--
-- Revision:
--    08/08/05 - Initial version.
--    03/04/09 - CR 508358 -- Added XCS3AN and XCS3D device support
-- End Revision

----- CELL JTAG_SIM_SPARTAN3A  -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;
use IEEE.VITAL_Primitives.all;

library unisim;
use unisim.vpkg.all;
use unisim.Vcomponents.all;



entity JTAG_SIM_SPARTAN3A is

  generic(
      PART_NAME : string := "3S200A"
      );

  port(
      TDO	: out std_ulogic;

      TCK	: in  std_ulogic;
      TDI	: in  std_ulogic;
      TMS	: in  std_ulogic
    );

end JTAG_SIM_SPARTAN3A;

architecture JTAG_SIM_SPARTAN3A_V OF JTAG_SIM_SPARTAN3A is


  TYPE JtagTapState is (TestLogicReset, RunTestIdle,SelectDRScan, CaptureDR,
                        ShiftDR, Exit1DR, PauseDR, Exit2DR, UPdateDR,
                        SelectIRScan, CaptureIR, ShiftIR, Exit1IR, PauseIR,
                        Exit2IR, UPdateIR);


-------------------------------------------------------------------------------
-----------------  Virtex4 Specific Constants ---------------------------------
-------------------------------------------------------------------------------

  TYPE JtagInstructionType is (UNKNOWN, IR_CAPTURE, BYPASS, IDCODE, USER1, USER2, USER3, USER4);                  

  TYPE PartType            is (XC3S700AN, XC3S400AN, XC3S200A, XC3S1400A, XC3S700A, XC3S50A, XC3SD3400A, XC3S200AN, XC3S1400AN, XC3S400A, XC3SD1800A, XC3S50AN);

  constant IRLength             : integer := 6;
  constant IDLength             : integer := 32;

  constant IR_CAPTURE_VAL	: std_logic_vector ((IRLength -1) downto 0) := "010001";

  constant BYPASS_INSTR		: std_logic_vector ((IRLength -1) downto 0) := "111111";
  constant IDCODE_INSTR		: std_logic_vector ((IRLength -1) downto 0) := "001001";
  constant USER1_INSTR		: std_logic_vector ((IRLength -1) downto 0) := "000010";
  constant USER2_INSTR		: std_logic_vector ((IRLength -1) downto 0) := "000011";
  constant USER3_INSTR		: std_logic_vector ((IRLength -1) downto 0) := "XXXXXX";
  constant USER4_INSTR		: std_logic_vector ((IRLength -1) downto 0) := "ZXXXXX";

--------------------------------------------------------

  constant DELAY_SIG     : time := 1 ps;

  constant Xon : boolean := true;
  constant MsgOn : boolean := true;

  signal ticd_TCK     : VitalDelayType := 0.0 ns;

  signal tisd_TDI_TCK : VitalDelayType := 0.0 ns;
  signal tisd_TMS_TCK : VitalDelayType := 0.0 ns;

  signal tsetup_TMS_TCK_posedge_posedge : VitalDelayType := 1.0 ns;
  signal tsetup_TMS_TCK_negedge_posedge : VitalDelayType := 1.0 ns;

  signal tsetup_TDI_TCK_posedge_posedge : VitalDelayType := 1.0 ns;
  signal tsetup_TDI_TCK_negedge_posedge : VitalDelayType := 1.0 ns;

  signal thold_TMS_TCK_posedge_posedge : VitalDelayType := 2.0 ns;
  signal thold_TMS_TCK_negedge_posedge : VitalDelayType := 2.0 ns;

  signal thold_TDI_TCK_posedge_posedge : VitalDelayType := 2.0 ns;
  signal thold_TDI_TCK_negedge_posedge : VitalDelayType := 2.0 ns;

  signal tpd_TCK_TDO : VitalDelayType01 := (6.0 ns, 6.0 ns);

  signal CurrentState    : JtagTapState := TestLogicReset;
  signal JtagInstruction : JtagInstructionType := IDCODE;

  signal TCK_ipd		: std_ulogic := 'X';
  signal TDI_ipd		: std_ulogic := 'X';
  signal TMS_ipd		: std_ulogic := 'X';
  signal TRST_ipd		: std_ulogic := '0';


  signal TCK_dly		: std_ulogic := 'X';
  signal TDI_dly		: std_ulogic := 'X';
  signal TMS_dly		: std_ulogic := 'X';
  signal TRST_dly		: std_ulogic := '0';

  signal TDO_zd			: std_ulogic := 'X';
  signal TDO_viol		: std_ulogic := 'X';

-----------     signal declaration    -------------------

  signal CaptureDR_sig          : std_ulogic := '0';
  signal RESET_sig              : std_ulogic := '0';
  signal ShiftDR_sig            : std_ulogic := '0';
  signal UpdateDR_sig           : std_ulogic := '0';

  signal ClkIR_active           : std_ulogic := '0';

  signal ClkIR_sig		: std_ulogic := '0';
  signal ClkID_sig		: std_ulogic := '0';
  signal ShiftIR_sig		: std_ulogic := 'X';
  signal UpdateIR_sig		: std_ulogic := 'X';
  signal ClkUpdateIR_sig	: std_ulogic := '0';
  signal IRcontent_sig		: std_logic_vector ((IRLength -1) downto 0) := (others => 'X');
  signal IDCODEval_sig		: std_logic_vector ((IDLength -1) downto 0) := (others => 'X');

  signal BypassReg		: std_ulogic := '0';
  signal BYPASS_sig		: std_ulogic := '0';
  signal IDCODE_sig		: std_ulogic := '0';
  signal USER1_sig		: std_ulogic := '0';
  signal USER2_sig		: std_ulogic := '0';
  signal USER3_sig		: std_ulogic := '0';
  signal USER4_sig		: std_ulogic := '0';

  signal TDO_latch              : std_ulogic := 'Z';

  signal Tlrst_sig              : std_ulogic := '1';
  signal TlrstN_sig              : std_ulogic := '1';

  signal IRegLastBit_sig        : std_ulogic := '0';
  signal IDregLastBit_sig       : std_ulogic := '0';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  TCK_dly        	 <= TCK            	after 0 ps;
  TDI_dly        	 <= TDI            	after 0 ps;
  TMS_dly        	 <= TMS            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable PartName_var        : PartType;
  variable IDCODE_str          : std_ulogic_vector ((IDLength -1) downto 0) := (others => 'X');
  begin
	if((PART_NAME   = "3S700AN") or (PART_NAME = "3s700an")) then
	      PartName_var := XC3S700AN;
	      IDCODE_str   := X"02628093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S400AN") or (PART_NAME = "3s400an")) then
	      PartName_var := XC3S400AN;
	      IDCODE_str   := X"02620093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S200A") or (PART_NAME = "3s200a")) then
	      PartName_var := XC3S200A;
	      IDCODE_str   := X"02218093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S1400A") or (PART_NAME = "3s1400a")) then
	      PartName_var := XC3S1400A;
	      IDCODE_str   := X"02230093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S700A") or (PART_NAME = "3s700a")) then
	      PartName_var := XC3S700A;
	      IDCODE_str   := X"02228093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S50A") or (PART_NAME = "3s50a")) then
	      PartName_var := XC3S50A;
	      IDCODE_str   := X"02210093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3SD3400A") or (PART_NAME = "3sd3400a")) then
	      PartName_var := XC3SD3400A;
	      IDCODE_str   := X"0384E093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S200AN") or (PART_NAME = "3s200an")) then
	      PartName_var := XC3S200AN;
	      IDCODE_str   := X"02618093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S1400AN") or (PART_NAME = "3s1400an")) then
	      PartName_var := XC3S1400AN;
	      IDCODE_str   := X"02630093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S400A") or (PART_NAME = "3s400a")) then
	      PartName_var := XC3S400A;
	      IDCODE_str   := X"02220093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3SD1800A") or (PART_NAME = "3sd1800a")) then
	      PartName_var := XC3SD1800A;
	      IDCODE_str   := X"03840093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "3S50AN") or (PART_NAME = "3s50an")) then
	      PartName_var := XC3S50AN;
	      IDCODE_str   := X"02610093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	else
		assert false
	report "Attribute Syntax Error: The allowed values for PART_NAME are 3S700AN, 3S400AN, 3S200A, 3S1400A, 3S700A, 3S50A, 3SD3400A, 3S200AN, 3S1400AN, 3S400A, 3SD1800A or 3S50AN"
		severity Failure;
	end if;
	wait;
  end process prcs_init;
--####################################################################
--#####                     JtagTapSM                            #####
--####################################################################
  prcs_JtagTapSM:process(TCK_dly, TRST_dly)
  begin

     if(TRST_dly = '1') then
         CurrentState <= TestLogicReset; 
     elsif(TRST_dly = '0') then
        if(rising_edge(TCK_dly)) then
           case CurrentState is
              -------------------------------
              ----  Reset path ---------------
              -------------------------------
              when TestLogicReset =>
                 if(TMS_dly = '0') then 
                    CurrentState <= RunTestIdle;
                 end if;
              when RunTestIdle => 
                 if(TMS_dly = '1') then 
                    CurrentState <= SelectDRScan;
                 end if;
              -------------------------------
              ------  DR path ---------------
              -------------------------------
              when SelectDRScan => 
                 if(TMS_dly = '0') then 
                    CurrentState <= CaptureDR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= SelectIRScan;
                 end if;
              when CaptureDR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= ShiftDR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= Exit1DR;
                 end if;
              when ShiftDR => 
                 if(TMS_dly = '1') then 
                    CurrentState <= Exit1DR;
                 end if;
              
                 if(IRcontent_sig = BYPASS_INSTR) then
                    BypassReg <= TDI_dly;
                 end if;

              when Exit1DR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= PauseDR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= UpdateDR;
                 end if;
              when PauseDR => 
                 if(TMS_dly = '1') then 
                    CurrentState <= Exit2DR;
                 end if;
              when Exit2DR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= ShiftDR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= UpdateDR;
                 end if;
              when UpdateDR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= RunTestIdle;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= SelectDRScan;
                 end if;
              -------------------------------
              ------  IR path ---------------
              -------------------------------
              when SelectIRScan => 
                 if(TMS_dly = '0') then 
                    CurrentState <= CaptureIR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= TestLogicReset;
                 end if;
              when CaptureIR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= ShiftIR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= Exit1IR;
                 end if;
              when ShiftIR => 
                 if(TMS_dly = '1') then 
                    CurrentState <= Exit1IR;
                 end if;
              when Exit1IR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= PauseIR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= UpdateIR;
                 end if;
              when PauseIR => 
                 if(TMS_dly = '1') then 
                    CurrentState <= Exit2IR;
                 end if;
              when Exit2IR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= ShiftIR;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= UpdateIR;
                 end if;
              when UpdateIR => 
                 if(TMS_dly = '0') then 
                    CurrentState <= RunTestIdle;
                 elsif(TMS_dly = '1') then 
                    CurrentState <= SelectDRScan;
                 end if;
           end case;
        end if;
     end if;
  end process  prcs_JtagTapSM;

--####################################################################
--#####                     CurrentState                         #####
--####################################################################

  prcs_CurrentState:process(TCK_dly, CurrentState, TRST_dly)
  begin

     ClkIR_sig <= '1';

     if(TRST_dly = '1') then
         CaptureDR_sig <= '0';
         ShiftDR_sig   <= '0';
         UpdateDR_sig  <= '0';
         ShiftIR_sig   <= '0';
         UpdateIR_sig  <= '0';
     elsif(TRST_dly = '0') then

         case CurrentState is

            when TestLogicReset =>
                          Tlrst_sig     <= '1' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;

            when CaptureDR =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '1' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;

            when ShiftDR  =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '1' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;
 
            when UpdateDR =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '1' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;

            when CaptureIR  =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;
                          ClkIR_sig     <= TCK_dly;

 
            when ShiftIR  =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '1' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;
                          ClkIR_sig     <= TCK_dly;

            when UpdateIR =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '1' after DELAY_SIG;

            when others   =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;
         end case;
     end if;
 
  end process  prcs_CurrentState;

------------- ?? TCK  NEGATIVE EDGE activities ----------

  prcs_ClkIR:process(TCK_dly)
  begin
--     ClkIR_sig <= ShiftIR_sig and TCK_dly;
     CLkUpdateIR_sig <= UpdateIR_sig and not TCK_dly;
  end process  prcs_ClkIR;

  prcs_ClkID:process(TCK_dly)
  begin
     ClkID_sig <= IDCODE_sig and TCK_dly;
  end process  prcs_ClkID;

  prcs_glblsigs:process(TCK_dly, UpdateDR_sig)
  begin
    if(falling_edge(TCK_dly)) then
       JTAG_CAPTURE_GLBL <= CaptureDR_sig;
       -- CR 211337 Reset should go high as soon as it gets to State Trlst
       --  JTAG_RESET_GLBL   <= Tlrst_sig;
       JTAG_SHIFT_GLBL   <= ShiftDR_sig;
       JTAG_UPDATE_GLBL  <= UpdateDR_sig;
       TlrstN_sig        <= Tlrst_sig;
    end if;
  
    if(falling_edge(UpdateDR_sig))then
      JTAG_UPDATE_GLBL  <= UpdateDR_sig;
    end if; 

  end process  prcs_glblsigs;

-- CR 211337
  prcs_reset:process(Tlrst_sig)
  begin
      JTAG_RESET_GLBL   <= Tlrst_sig;
  end process  prcs_reset;

--####################################################################
--#####                       JtagIR                             #####
--####################################################################
  prcs_JtagIR:process(ClkIR_sig, ClkUpdateIR_sig, ShiftIR_sig,  TlrstN_sig, TRST_dly)
  variable NextIRreg : std_logic_vector ((IRLength -1) downto 0) := IR_CAPTURE_VAL;
  variable ir_int    : std_logic_vector ((IRLength -1) downto 0) := IR_CAPTURE_VAL;
  begin
     NextIRreg((IRLength -1) downto 0) := (TDI_dly & ir_int((IRLength -1) downto 1)); 

     if((TRST_dly = '1') or (TlrstN_sig = '1'))then
        IRcontent_sig((IRLength -1) downto 0) <= IDCODE_INSTR;  -- IDCODE instruction is loaded into IR reg.
        IRegLastBit_sig <= ir_int(0);
     elsif((TRST_dly = '0') and (TlrstN_sig = '0')) then
        if(rising_edge(ClkIR_sig)) then
           if(ShiftIR_sig = '1') then
              ir_int((IRLength -1) downto 0) := NextIRreg((IRLength -1) downto 0);
              IRegLastBit_sig <= ir_int(0);
           else
               ir_int := IR_CAPTURE_VAL ;
               IRegLastBit_sig <= ir_int(0);
           end if;
        end if;
        if(rising_edge(ClkUpdateIR_sig)) then
           if(UpdateIR_sig = '1') then
              IRcontent_sig <= ir_int;
           end if;
        end if;
     end if;
  end process  prcs_JtagIR;
--####################################################################
--#####                       JtagDecodeIR                       #####
--####################################################################
  prcs_JtagDecodeIR:process(IRcontent_sig)
  begin
     case IRcontent_sig is

        when IR_CAPTURE_VAL =>
           JTagInstruction <= IR_CAPTURE;

        when BYPASS_INSTR =>
           JTagInstruction <= BYPASS;
           BYPASS_sig <= '1';
           IDCODE_sig <= '0';
           USER1_sig  <= '0';
           USER2_sig  <= '0';
           USER3_sig  <= '0';
           USER4_sig  <= '0';

        when IDCODE_INSTR =>
           JTagInstruction <= IDCODE;
           BYPASS_sig <= '0';
           IDCODE_sig <= '1';
           USER1_sig  <= '0';
           USER2_sig  <= '0';
           USER3_sig  <= '0';
           USER4_sig  <= '0';

        when USER1_INSTR =>
           JTagInstruction <= USER1;
           BYPASS_sig <= '0';
           IDCODE_sig <= '0';
           USER1_sig  <= '1';
           USER2_sig  <= '0';
           USER3_sig  <= '0';
           USER4_sig  <= '0';

        when USER2_INSTR => 
           JTagInstruction <= USER2;
           BYPASS_sig <= '0';
           IDCODE_sig <= '0';
           USER1_sig  <= '0';
           USER2_sig  <= '1';
           USER3_sig  <= '0';
           USER4_sig  <= '0';

        when USER3_INSTR => 
           JTagInstruction <= USER3;
           BYPASS_sig <= '0';
           IDCODE_sig <= '0';
           USER1_sig  <= '0';
           USER2_sig  <= '0';
           USER3_sig  <= '1';
           USER4_sig  <= '0';

        when USER4_INSTR => 
           JTagInstruction <= USER4;
           BYPASS_sig <= '0';
           IDCODE_sig <= '0';
           USER1_sig  <= '0';
           USER2_sig  <= '0';
           USER3_sig  <= '0';
           USER4_sig  <= '1';
        when others =>
           JTagInstruction <= UNKNOWN;
           NULL; 
     end case;
  end process prcs_JtagDecodeIR;
--####################################################################
--#####                       JtagIDCODE                         #####
--####################################################################
  prcs_JtagIDCODE:process(ClkID_sig)
  variable IDreg : bit_vector ((IDLength -1) downto 0);
  begin
     if(rising_edge(ClkID_sig)) then
        if(ShiftDR_sig = '1') then
          IDreg := IDreg sra 1;
          IDreg(IDLength -1) := TO_BIT(TDI_dly);
        else
          IDreg := TO_BITVECTOR(IDCODEval_sig);
        end if;
     end if;

     IDregLastBit_sig <= TO_STDULOGIC(IDreg(0));

  end process  prcs_JtagIDCODE;
--####################################################################
--####################################################################
--#####                    JtagSetGlobalSignals                  #####
--####################################################################
  prcs_JtagSetGlobalSignals:process(ClkUpdateIR_sig, Tlrst_sig, USER1_sig, USER2_sig, USER3_sig, USER4_sig)
  begin
     if(rising_edge(USER1_sig)) then
         JTAG_SEL1_GLBL     <= '1';
         JTAG_SEL2_GLBL     <= '0';
         JTAG_SEL3_GLBL     <= '0';
         JTAG_SEL4_GLBL     <= '0';
     elsif(rising_edge(USER2_sig)) then
         JTAG_SEL1_GLBL     <= '0';
         JTAG_SEL2_GLBL     <= '1';
         JTAG_SEL3_GLBL     <= '0';
         JTAG_SEL4_GLBL     <= '0';
     elsif(rising_edge(USER3_sig)) then
         JTAG_SEL1_GLBL     <= '0';
         JTAG_SEL2_GLBL     <= '0';
         JTAG_SEL3_GLBL     <= '1';
         JTAG_SEL4_GLBL     <= '0';
     elsif(rising_edge(USER4_sig)) then
         JTAG_SEL1_GLBL     <= '0';
         JTAG_SEL2_GLBL     <= '0';
         JTAG_SEL3_GLBL     <= '0';
         JTAG_SEL4_GLBL     <= '1';
     elsif(rising_edge(ClkUpdateIR_sig)) then
         JTAG_SEL1_GLBL     <= '0';
         JTAG_SEL2_GLBL     <= '0';
         JTAG_SEL3_GLBL     <= '0';
         JTAG_SEL4_GLBL     <= '0';
     elsif(rising_edge(Tlrst_sig)) then
         JTAG_SEL1_GLBL     <= '0';
         JTAG_SEL2_GLBL     <= '0';
         JTAG_SEL3_GLBL     <= '0';
         JTAG_SEL4_GLBL     <= '0';
     end if;

  end process prcs_JtagSetGlobalSignals;
      
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################

  JTAG_TCK_GLBL  <= TCK_dly;
  JTAG_TDI_GLBL  <= TDI_dly;
  JTAG_TMS_GLBL  <= TMS_dly;
  JTAG_TRST_GLBL <= TRST_dly;

  TDO_latch <= BypassReg
         when ((CurrentState = ShiftDR) and (IRcontent_sig=BYPASS_INSTR))
       else IRegLastBit_sig
         when (CurrentState = ShiftIR)
       else IDregLastBit_sig
         when ((CurrentState = ShiftDR) and (IRcontent_sig=IDCODE_INSTR))
       else JTAG_USER_TDO1_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER1_INSTR))
       else JTAG_USER_TDO2_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER2_INSTR))
       else JTAG_USER_TDO3_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER3_INSTR))
       else JTAG_USER_TDO4_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER4_INSTR))
       else 'Z';

--  prcs_TDO:process(TCK_dly)
--  begin
--    if(falling_edge(TCK_dly)) then
--       TDO <= TDO_latch;
--    end if;
--  end process  prcs_TDO;

--####################################################################
--#####                         Timing                           #####
--####################################################################
  VITALBehavior                    : process (TCK_dly, TDI_dly, TMS_dly)

    variable PInfo_TCK           : VitalPeriodDataType := VitalPeriodDataInit;
    variable Pviol_TCK           : std_ulogic          := '0';

    variable Tmkr_TDI_TCK_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tviol_TDI_TCK_posedge : std_ulogic          := '0';

    variable Tmkr_TMS_TCK_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tviol_TMS_TCK_posedge : std_ulogic          := '0';

    variable Violation : std_ulogic := '0';

    variable TDO_GlitchData : VitalGlitchDataType;


  begin
      VitalSetupHoldCheck (
        Violation            => Tviol_TDI_TCK_posedge,
        TimingData           => Tmkr_TDI_TCK_posedge,
        TestSignal           => TDI_dly,
        TestSignalName       => "TDI",
        TestDelay            => tisd_TDI_TCK,
        RefSignal            => TCK_dly,
        RefSignalName        => "TCK",
        RefDelay             => ticd_TCK,
        SetupHigh            => tsetup_TDI_TCK_posedge_posedge,
        SetupLow             => tsetup_TDI_TCK_negedge_posedge,
        HoldLow              => thold_TDI_TCK_posedge_posedge,
        HoldHigh             => thold_TDI_TCK_negedge_posedge,
        CheckEnabled         => TO_X01(TRST_dly) = '0',
        RefTransition        => 'R',
        HeaderMsg            => "/X_JTAG_SIM_VIRTEX4",
        Xon                  => Xon,
        MsgOn                => MsgOn,
        MsgSeverity          => warning);

      VitalSetupHoldCheck (
        Violation            => Tviol_TMS_TCK_posedge,
        TimingData           => Tmkr_TMS_TCK_posedge,
        TestSignal           => TMS_dly,
        TestSignalName       => "TMS",
        TestDelay            => tisd_TMS_TCK,
        RefSignal            => TCK_dly,
        RefSignalName        => "TCK",
        RefDelay             => ticd_TCK,
        SetupHigh            => tsetup_TMS_TCK_posedge_posedge,
        SetupLow             => tsetup_TMS_TCK_negedge_posedge,
        HoldLow              => thold_TMS_TCK_posedge_posedge,
        HoldHigh             => thold_TMS_TCK_negedge_posedge,
        CheckEnabled         => TO_X01(TRST_dly) = '0',
        RefTransition        => 'R',
        HeaderMsg            => "/X_JTAG_SIM_VIRTEX4",
        Xon                  => Xon,
        MsgOn                => MsgOn,
        MsgSeverity          => warning);

      if(falling_edge(TCK_dly)) then
         VitalPathDelay01 (
           OutSignal              => TDO,
           GlitchData             => TDO_GlitchData,
           OutSignalName          => "TDO",
           OutTemp                => TDO_latch,
           Paths                  => (0 => (TCK_dly'last_event, tpd_TCK_TDO, TRST_dly = '0')),
           Mode                   => VitalTransport,
           Xon                    => Xon,
           MsgOn                  => MsgOn,
           MsgSeverity            => warning);
      end if;
  end process;

--####################################################################
--####################################################################


end JTAG_SIM_SPARTAN3A_V;

