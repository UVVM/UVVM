-------------------------------------------------------------------------------
-- Copyright (c) 1995/2005 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Jtag TAP contorller for VIRTEX6 
--  /   /         
-- /___/   /\     Filename : JTAG_SIM_VIRTEX6.vhd
-- \   \  /  \    Timestamp : Thu Jan 29 16:26:40 PST 2009
--  \___\/\___\
--
-- Revision:
--    01/29/09 - Initial version.
--    04/08/09 - CR 528894 -- PART_NAME default value fix for gencomp
--    08/26/09 - CR 530869 -- PART_NAME values updated and default value changed
-- End Revision

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.vpkg.all;
use unisim.Vcomponents.all;



entity JTAG_SIM_VIRTEX6 is

  generic(
      PART_NAME : string := "LX75T"
      );

  port(
      TDO	: out std_ulogic;

      TCK	: in  std_ulogic;
      TDI	: in  std_ulogic;
      TMS	: in  std_ulogic
    );

end JTAG_SIM_VIRTEX6;

architecture JTAG_SIM_VIRTEX6_V OF JTAG_SIM_VIRTEX6 is


  TYPE JtagTapState is (TestLogicReset, RunTestIdle,SelectDRScan, CaptureDR,
                        ShiftDR, Exit1DR, PauseDR, Exit2DR, UPdateDR,
                        SelectIRScan, CaptureIR, ShiftIR, Exit1IR, PauseIR,
                        Exit2IR, UPdateIR);


-------------------------------------------------------------------------------
-----------------  Virtex4 Specific Constants ---------------------------------
-------------------------------------------------------------------------------

  TYPE JtagInstructionType is (UNKNOWN, IR_CAPTURE, BYPASS, IDCODE, USER1, USER2, USER3, USER4);                  

  TYPE PartType            is (HX380T, LX130T, CX240T, LX760, HX250T, LX550T, SX315T, CX195T, LX75T, LX240T, CX75T, CX130T, HX565T, LX365T,                               HX255T, LX195T, SX475T);

  constant IRLength             : integer := 10;
  constant IRLengthMax          : integer := 10;
  constant IDLength             : integer := 32;
  constant RevBitsLength        : integer := 4;

  constant IR_CAPTURE_VAL	: std_logic_vector ((IRLengthMax -1) downto 0) := "1111010001";
  constant BYPASS_INSTR         : std_logic_vector ((IRLengthMax -1) downto 0) := "1111111111";
  constant IDCODE_INSTR         : std_logic_vector ((IRLengthMax -1) downto 0) := "1111001001";
  constant USER1_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "1111000010";
  constant USER2_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "1111000011";
  constant USER3_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "1111100010";
  constant USER4_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "1111100011";



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

  signal jtag_state_name	: JtagTapState		:= TestLogicReset;
  signal jtag_instruction_name	: JtagInstructionType	:= IDCODE;

  signal TCK_ipd		: std_ulogic := 'X';
  signal TDI_ipd		: std_ulogic := 'X';
  signal TMS_ipd		: std_ulogic := 'X';
  signal TRST_ipd		: std_ulogic := 'X';


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
  signal TlrstN_sig             : std_ulogic := '1';

  signal IRegLastBit_sig        : std_ulogic := '0';
  signal IDregLastBit_sig       : std_ulogic := '0';

  signal Rti_sig                : std_ulogic := '0';

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
	if((PART_NAME   = "HX380T") or (PART_NAME = "hx380t")) then
	      PartName_var := HX380T;
	      IDCODE_str   := X"042A8093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX130T") or (PART_NAME = "lx130t")) then
	      PartName_var := LX130T;
	      IDCODE_str   := X"0424A093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "CX240T") or (PART_NAME = "cx240t")) then
	      PartName_var := CX240T;
	      IDCODE_str   := X"042D0093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX760") or (PART_NAME = "lx760")) then
	      PartName_var := LX760;
	      IDCODE_str   := X"0423A093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "HX250T") or (PART_NAME = "hx250t")) then
	      PartName_var := HX250T;
	      IDCODE_str   := X"042A2093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX550T") or (PART_NAME = "lx550t")) then
	      PartName_var := LX550T;
	      IDCODE_str   := X"04256093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "SX315T") or (PART_NAME = "sx315t")) then
	      PartName_var := SX315T;
	      IDCODE_str   := X"04286093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "CX195T") or (PART_NAME = "cx195t")) then
	      PartName_var := CX195T;
	      IDCODE_str   := X"042CC093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX75T") or (PART_NAME = "lx75t")) then
	      PartName_var := LX75T;
	      IDCODE_str   := X"04244093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX240T") or (PART_NAME = "lx240t")) then
	      PartName_var := LX240T;
	      IDCODE_str   := X"04250093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "CX75T") or (PART_NAME = "cx75t")) then
	      PartName_var := CX75T;
	      IDCODE_str   := X"042C4093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "CX130T") or (PART_NAME = "cx130t")) then
	      PartName_var := CX130T;
	      IDCODE_str   := X"042CA093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "HX565T") or (PART_NAME = "hx565t")) then
	      PartName_var := HX565T;
	      IDCODE_str   := X"042AC093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX365T") or (PART_NAME = "lx365t")) then
	      PartName_var := LX365T;
	      IDCODE_str   := X"04252093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "HX255T") or (PART_NAME = "hx255t")) then
	      PartName_var := HX255T;
	      IDCODE_str   := X"042A4093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX195T") or (PART_NAME = "lx195t")) then
	      PartName_var := LX195T;
	      IDCODE_str   := X"0424C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "SX475T") or (PART_NAME = "sx475t")) then
	      PartName_var := SX475T;
	      IDCODE_str   := X"04288093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	else
		assert false
	report "Attribute Syntax Error: The allowed values for PART_NAME are HX380T or LX130T or CX240T or LX760 or HX250T or LX550T or SX315T or CX195T or LX75T or LX240T or CX75T or CX130T or HX565T or LX365T or HX255T or LX195T or SX475T"
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
              
                 if(IRcontent_sig = BYPASS_INSTR((IRLength -1) downto 0)) then
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
         Tlrst_sig     <= '1';
         Rti_sig       <= '0';
         CaptureDR_sig <= '0';
         ShiftDR_sig   <= '0';
         UpdateDR_sig  <= '0';
         ShiftIR_sig   <= '0';
         UpdateIR_sig  <= '0';
     elsif(TRST_dly = '0') then

         case CurrentState is

            when TestLogicReset =>
                          Tlrst_sig     <= '1' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;

            when RunTestIdle =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '1' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;

            when CaptureDR =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '1' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;

            when ShiftDR  =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '1' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;
 
            when UpdateDR =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '1' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;

            when CaptureIR  =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;
                          ClkIR_sig     <= TCK_dly;

 
            when ShiftIR  =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '1' after DELAY_SIG;
                          UpdateIR_sig  <= '0' after DELAY_SIG;
                          ClkIR_sig     <= TCK_dly;

            when UpdateIR =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
                          CaptureDR_sig <= '0' after DELAY_SIG;
                          ShiftDR_sig   <= '0' after DELAY_SIG;
                          UpdateDR_sig  <= '0' after DELAY_SIG;
                          ShiftIR_sig   <= '0' after DELAY_SIG;
                          UpdateIR_sig  <= '1' after DELAY_SIG;

            when others   =>
                          Tlrst_sig     <= '0' after DELAY_SIG;
                          Rti_sig       <= '0' after DELAY_SIG;
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

------------ RESET

  prcs_reset:process(Tlrst_sig)
  begin
      JTAG_RESET_GLBL   <= Tlrst_sig;
  end process  prcs_reset;

------------ RUNTEST
  prcs_rti:process(Rti_sig)
  begin
      JTAG_RUNTEST_GLBL   <= Rti_sig;
  end process  prcs_rti;

--####################################################################
--#####                       JtagIR                             #####
--####################################################################
  prcs_JtagIR:process(ClkIR_sig, ClkUpdateIR_sig, ShiftIR_sig,  TlrstN_sig, TRST_dly)
  variable NextIRreg : std_logic_vector ((IRLength -1) downto 0) := IR_CAPTURE_VAL((IRLength -1) downto 0);
  variable ir_int    : std_logic_vector ((IRLength -1) downto 0) := IR_CAPTURE_VAL((IRLength -1) downto 0);
  begin
     NextIRreg((IRLength -1) downto 0) := (TDI_dly & ir_int((IRLength -1) downto 1)); 

     if((TRST_dly = '1') or (TlrstN_sig = '1'))then
        IRcontent_sig((IRLength -1) downto 0) <= IDCODE_INSTR((IRLength -1) downto 0);  -- IDCODE instruction is loaded into IR reg.
        IRegLastBit_sig <= ir_int(0);
     elsif((TRST_dly = '0') and (TlrstN_sig = '0')) then
        if(rising_edge(ClkIR_sig)) then
           if(ShiftIR_sig = '1') then
              ir_int((IRLength -1) downto 0) := NextIRreg((IRLength -1) downto 0);
              IRegLastBit_sig <= ir_int(0);
           else
               ir_int := IR_CAPTURE_VAL((IRLength -1) downto 0);
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
     if(IRcontent_sig((IRLength -1) downto 0) = IR_CAPTURE_VAL((IRLength-1) downto 0)) then
        JTagInstruction <= IR_CAPTURE;

     elsif(IRcontent_sig((IRLength -1) downto 0) = BYPASS_INSTR((IRLength-1) downto 0)) then
        JTagInstruction <= BYPASS;
        BYPASS_sig <= '1';
        IDCODE_sig <= '0';
        USER1_sig  <= '0';
        USER2_sig  <= '0';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = IDCODE_INSTR((IRLength-1) downto 0)) then
        JTagInstruction <= IDCODE;
        BYPASS_sig <= '0';
        IDCODE_sig <= '1';
        USER1_sig  <= '0';
        USER2_sig  <= '0';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER1_INSTR((IRLength-1) downto 0)) then
        JTagInstruction <= USER1;
        BYPASS_sig <= '0';
        IDCODE_sig <= '0';
        USER1_sig  <= '1';
        USER2_sig  <= '0';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER2_INSTR((IRLength-1) downto 0)) then
        JTagInstruction <= USER2;
        BYPASS_sig <= '0';
        IDCODE_sig <= '0';
        USER1_sig  <= '0';
        USER2_sig  <= '1';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER3_INSTR((IRLength-1) downto 0)) then
        JTagInstruction <= USER3;
        BYPASS_sig <= '0';
        IDCODE_sig <= '0';
        USER1_sig  <= '0';
        USER2_sig  <= '0';
        USER3_sig  <= '1';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER4_INSTR((IRLength-1) downto 0)) then
        JTagInstruction <= USER4;
        BYPASS_sig <= '0';
        IDCODE_sig <= '0';
        USER1_sig  <= '0';
        USER2_sig  <= '0';
        USER3_sig  <= '0';
        USER4_sig  <= '1';

    else
        JTagInstruction <= UNKNOWN;
        NULL; 
     end if;
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

  jtag_state_name       <= CurrentState;
  jtag_instruction_name <= JtagInstruction;

  JTAG_TCK_GLBL  <= TCK_dly;
  JTAG_TDI_GLBL  <= TDI_dly;
  JTAG_TMS_GLBL  <= TMS_dly;
  JTAG_TRST_GLBL <= TRST_dly;

  TDO_latch <= BypassReg
         when ((CurrentState = ShiftDR) and (IRcontent_sig=BYPASS_INSTR((IRLength -1) downto 0)))
       else IRegLastBit_sig
         when (CurrentState = ShiftIR)
       else IDregLastBit_sig
         when ((CurrentState = ShiftDR) and (IRcontent_sig=IDCODE_INSTR((IRLength -1) downto 0)))
       else JTAG_USER_TDO1_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER1_INSTR((IRLength -1) downto 0)))
       else JTAG_USER_TDO2_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER2_INSTR((IRLength -1) downto 0)))
       else JTAG_USER_TDO3_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER3_INSTR((IRLength -1) downto 0)))
       else JTAG_USER_TDO4_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER4_INSTR((IRLength -1) downto 0)))
       else 'Z';
 

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
        HeaderMsg            => "/X_JTAG_SIM_VIRTEX6",
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
        HeaderMsg            => "/X_JTAG_SIM_VIRTEX6",
        Xon                  => Xon,
        MsgOn                => MsgOn,
        MsgSeverity          => warning);

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
  end process;



--####################################################################
--####################################################################


end JTAG_SIM_VIRTEX6_V;
