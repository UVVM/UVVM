-------------------------------------------------------------------------------
-- Copyright (c) 1995/2005 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Jtag TAP contorller 
--  /   /         
-- /___/   /\     Filename : JTAG_SIM_VIRTEX5.vhd
-- \   \  /  \    Timestamp : Thu Nov 10 17:26:14 PST 2005
--  \___\/\___\
--
-- Revision:
--    11/10/05 - Initial version.
--    02/17/09 - - CR 508358 -- Added support for SXT, FXT and TXT devices
-- End Revision

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.vpkg.all;
use unisim.Vcomponents.all;



entity JTAG_SIM_VIRTEX5_SUBMOD is

  generic(
      PART_NAME : string;
      IRLength  : integer
      );

  port(
      TDO	: out std_ulogic;

      TCK	: in  std_ulogic;
      TDI	: in  std_ulogic;
      TMS	: in  std_ulogic
    );

end JTAG_SIM_VIRTEX5_SUBMOD;

architecture JTAG_SIM_VIRTEX5_SUBMOD_V OF JTAG_SIM_VIRTEX5_SUBMOD is


  TYPE JtagTapState is (TestLogicReset, RunTestIdle,SelectDRScan, CaptureDR,
                        ShiftDR, Exit1DR, PauseDR, Exit2DR, UPdateDR,
                        SelectIRScan, CaptureIR, ShiftIR, Exit1IR, PauseIR,
                        Exit2IR, UPdateIR);


-------------------------------------------------------------------------------
-----------------  Virtex4 Specific Constants ---------------------------------
-------------------------------------------------------------------------------

  TYPE JtagInstructionType is (UNKNOWN, IR_CAPTURE, BYPASS, IDCODE, USER1, USER2, USER3, USER4);                  

  TYPE PartType            is (FX100T, FX130T, FX200T, FX30T, FX70T, LX110, 
                               LX110T, LX155, LX155T, LX20T, LX220, LX220T, 
                               LX30, LX30T, LX330, LX330T, LX50, LX50T, LX85, 
                               LX85T, SX240T, SX35T, SX50T, SX95T, TX150T, TX240T);

  constant IRLengthMax          : integer := 14;
  constant IDLength             : integer := 32;
  constant RevBitsLength        : integer := 4;

  constant IR_CAPTURE_VAL	: std_logic_vector ((IRLengthMax -1) downto 0) := "11111111010001";
  constant BYPASS_INSTR         : std_logic_vector ((IRLengthMax -1) downto 0) := "11111111111111";
  constant IDCODE_INSTR         : std_logic_vector ((IRLengthMax -1) downto 0) := "11111111001001";
  constant USER1_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "11111111000010";
  constant USER2_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "11111111000011";
  constant USER3_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "11111111100010";
  constant USER4_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "11111111100011";



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
	if((PART_NAME   = "FX100T") or (PART_NAME = "fx100t")) then
	      PartName_var := FX100T;
	      IDCODE_str   := X"032D8093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "FX130T") or (PART_NAME = "fx130t")) then
	      PartName_var := FX130T;
	      IDCODE_str   := X"03300093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "FX200T") or (PART_NAME = "fx200t")) then
	      PartName_var := FX200T;
	      IDCODE_str   := X"03334093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "FX30T") or (PART_NAME = "fx30t")) then
	      PartName_var := FX30T;
	      IDCODE_str   := X"03276093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "FX70T") or (PART_NAME = "fx70t")) then
	      PartName_var := FX70T;
	      IDCODE_str   := X"032C6093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX110") or (PART_NAME = "lx110")) then
	      PartName_var := LX110;
	      IDCODE_str   := X"028D6093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX110T") or (PART_NAME = "lx110t")) then
	      PartName_var := LX110T;
	      IDCODE_str   := X"02AD6093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX155") or (PART_NAME = "lx155")) then
	      PartName_var := LX155;
	      IDCODE_str   := X"028EC093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX155T") or (PART_NAME = "lx155t")) then
	      PartName_var := LX155T;
	      IDCODE_str   := X"02AEC093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX20T") or (PART_NAME = "lx20t")) then
	      PartName_var := LX20T;
	      IDCODE_str   := X"02A56093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX220") or (PART_NAME = "lx220")) then
	      PartName_var := LX220;
	      IDCODE_str   := X"0290C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX220T") or (PART_NAME = "lx220t")) then
	      PartName_var := LX220T;
	      IDCODE_str   := X"02B0C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX30") or (PART_NAME = "lx30")) then
	      PartName_var := LX30;
	      IDCODE_str   := X"0286E093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX30T") or (PART_NAME = "lx30t")) then
	      PartName_var := LX30T;
	      IDCODE_str   := X"02A6E093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX330") or (PART_NAME = "lx330")) then
	      PartName_var := LX330;
	      IDCODE_str   := X"0295C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX330T") or (PART_NAME = "lx330t")) then
	      PartName_var := LX330T;
	      IDCODE_str   := X"02B5C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX50") or (PART_NAME = "lx50")) then
	      PartName_var := LX50;
	      IDCODE_str   := X"02896093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX50T") or (PART_NAME = "lx50t")) then
	      PartName_var := LX50T;
	      IDCODE_str   := X"02A96093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX85") or (PART_NAME = "lx85")) then
	      PartName_var := LX85;
	      IDCODE_str   := X"028AE093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "LX85T") or (PART_NAME = "lx85t")) then
	      PartName_var := LX85T;
	      IDCODE_str   := X"02AAE093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "SX240T") or (PART_NAME = "sx240t")) then
	      PartName_var := SX240T;
	      IDCODE_str   := X"02F3E093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "SX35T") or (PART_NAME = "sx35t")) then
	      PartName_var := SX35T;
	      IDCODE_str   := X"02E72093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "SX50T") or (PART_NAME = "sx50t")) then
	      PartName_var := SX50T;
	      IDCODE_str   := X"02E9A093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "SX95T") or (PART_NAME = "sx95t")) then
	      PartName_var := SX95T;
	      IDCODE_str   := X"02ECE093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "TX150T") or (PART_NAME = "tx150t")) then
	      PartName_var := TX150T;
	      IDCODE_str   := X"04502093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "TX240T") or (PART_NAME = "tx240t")) then
	      PartName_var := TX240T;
	      IDCODE_str   := X"0453E093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	else
		assert false
	report "Attribute Syntax Error: The allowed values for PART_NAME are FX100T, FX130T, FX200T, FX30T, FX70T, LX110, LX110T, LX155, LX155T, LX20T, LX220, LX220T, LX30, LX30T, LX330, LX330T, LX50, LX50T, LX85, LX85T, SX240T, SX35T, SX50T, SX95T, TX150T or TX240T"
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
 
-- CR 212040 -- added timing        
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
        HeaderMsg            => "/X_JTAG_SIM_VIRTEX5",
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
        HeaderMsg            => "/X_JTAG_SIM_VIRTEX5",
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


end JTAG_SIM_VIRTEX5_SUBMOD_V;


----- CELL JTAG_SIM_VIRTEX5  -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;
use unisim.Vcomponents.all;

entity JTAG_SIM_VIRTEX5 is

  generic(
      PART_NAME : string := "LX50"
      );

  port(
      TDO	: out std_ulogic;

      TCK	: in  std_ulogic;
      TDI	: in  std_ulogic;
      TMS	: in  std_ulogic
    );

end JTAG_SIM_VIRTEX5;

architecture JTAG_SIM_VIRTEX5_V OF JTAG_SIM_VIRTEX5 is

  component JTAG_SIM_VIRTEX5_SUBMOD
     generic(
         PART_NAME : string;
         IRLength  : integer
         );

     port(
         TDO       : out std_ulogic;

         TCK       : in  std_ulogic;
         TDI       : in  std_ulogic;
         TMS       : in  std_ulogic
       );
  end component;

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

  signal TDO1_zd                : std_ulogic := 'X';
  signal TDO2_zd                : std_ulogic := 'X';

  signal IRLen10, IRLen14       : boolean := false;




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
--#####                   Initialization                         #####
--####################################################################
  prcs_init:process
  begin
      if((PART_NAME   = "LX30") or (PART_NAME = "lx30") or
         (PART_NAME   = "LX50") or (PART_NAME = "lx50") or
         (PART_NAME   = "LX85") or (PART_NAME = "lx85") or
         (PART_NAME   = "LX110") or (PART_NAME = "lx110") or
         (PART_NAME   = "LX220") or (PART_NAME = "lx220") or
         (PART_NAME   = "LX330") or (PART_NAME = "lx330") or
         (PART_NAME   = "LX30T") or (PART_NAME = "lx30t") or
         (PART_NAME   = "LX50T") or (PART_NAME = "lx50t") or
         (PART_NAME   = "LX85T") or (PART_NAME = "lx85t") or
         (PART_NAME   = "LX110T") or (PART_NAME = "lx110t") or
         (PART_NAME   = "LX220T") or (PART_NAME = "lx220t") or
         (PART_NAME   = "LX330T") or (PART_NAME = "lx330t")) then
          IRLen10 <= true;
      elsif((PART_NAME   = "FX40") or (PART_NAME = "fx40") or
         (PART_NAME   = "FX60") or (PART_NAME = "fx60") or
         (PART_NAME   = "FX100") or (PART_NAME = "fx100") or
         (PART_NAME   = "FX140") or (PART_NAME = "fx140") or
         (PART_NAME   = "FX200") or (PART_NAME = "fx200")) then
          IRLen14 <= true;
      end if;

      wait;

  end process prcs_init;

--####################################################################
--#####                       Generate                           #####
--####################################################################
  G1: if((PART_NAME  = "FX30T")	 or (PART_NAME   = "fx30t")  or
	(PART_NAME   = "FX70T")	 or (PART_NAME   = "fx70t")  or
	(PART_NAME   = "LX110")	 or (PART_NAME   = "lx110")  or
	(PART_NAME   = "LX110T") or (PART_NAME   = "lx110t") or
	(PART_NAME   = "LX155")	 or (PART_NAME   = "lx155")  or
	(PART_NAME   = "LX155T") or (PART_NAME   = "lx155t") or
	(PART_NAME   = "LX20T")	 or (PART_NAME   = "lx20t")  or
	(PART_NAME   = "LX220")	 or (PART_NAME   = "lx220")  or
	(PART_NAME   = "LX220T") or (PART_NAME   = "lx220t") or
	(PART_NAME   = "LX30")	 or (PART_NAME   = "lx30")   or
	(PART_NAME   = "LX30T")	 or (PART_NAME   = "lx30t")  or
	(PART_NAME   = "LX330")	 or (PART_NAME   = "lx330")  or
	(PART_NAME   = "LX330T") or (PART_NAME   = "lx330t") or
	(PART_NAME   = "LX50")	 or (PART_NAME   = "lx50")   or
	(PART_NAME   = "LX50T")	 or (PART_NAME   = "lx50t")  or
	(PART_NAME   = "LX85")	 or (PART_NAME   = "lx85")   or
	(PART_NAME   = "LX85T")	 or (PART_NAME   = "lx85t")  or
	(PART_NAME   = "SX240T") or (PART_NAME   = "sx240t") or
	(PART_NAME   = "SX35T")	 or (PART_NAME   = "sx35t")  or
	(PART_NAME   = "SX50T")	 or (PART_NAME   = "sx50t")  or
	(PART_NAME   = "SX95T")	 or (PART_NAME   = "sx95t")  or
	(PART_NAME   = "TX150T") or (PART_NAME   = "tx150t") or
	(PART_NAME   = "TX240T") or (PART_NAME   = "tx240t")) generate

        JTAG_INST : JTAG_SIM_VIRTEX5_SUBMOD
          generic map (
            PART_NAME => PART_NAME,
            IRLength  => 10
          )
          port map (
            TDO => TDO1_zd,
            TCK => TCK_dly,
            TDI => TDI_dly,
            TMS => TMS_dly
          );

  end generate;   

  G2: if((PART_NAME  = "FX100T") or (PART_NAME   = "fx100t") or 
	(PART_NAME   = "FX130T") or (PART_NAME   = "fx130t") or 
	(PART_NAME   = "FX200T") or (PART_NAME   = "fx200t")) generate

        JTAG_INST : JTAG_SIM_VIRTEX5_SUBMOD
          generic map (
            PART_NAME => PART_NAME,
            IRLength  => 14
          )
          port map (
            TDO => TDO2_zd,
            TCK => TCK_dly,
            TDI => TDI_dly,
            TMS => TMS_dly
          );

  end generate;   


         
--####################################################################

  TDO <= TDO1_zd when IRLen10 else
         TDO2_zd when IRLen14;


end JTAG_SIM_VIRTEX5_V;

