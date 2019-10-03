-------------------------------------------------------------------------------
-- Copyright (c) 1995/2010 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Jtag TAP contorller for VIRTEX7 
--  /   /         
-- /___/   /\     Filename : JTAG_SIME2.vhd
-- \   \  /  \    Timestamp : Mon May 17 17:32:40 PDT 2010
--  \___\/\___\
--
-- Revision:
--    05/17/10 - Initial version.
--    11/30/11 - 632642 - Updated supported devices and corresponding IDCODES
--    07/05/12 - Updated the simulation model (CR 667100).
--    09/20/12 - Fixed IDCODE and instruction range (CR 678295).
-- End Revision

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;
use unisim.Vcomponents.all;



entity JTAG_SIME2_SUBMOD is

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

end JTAG_SIME2_SUBMOD;

architecture JTAG_SIME2_SUBMOD_V OF JTAG_SIME2_SUBMOD is


  TYPE JtagTapState is (TestLogicReset, RunTestIdle,SelectDRScan, CaptureDR,
                        ShiftDR, Exit1DR, PauseDR, Exit2DR, UPdateDR,
                        SelectIRScan, CaptureIR, ShiftIR, Exit1IR, PauseIR,
                        Exit2IR, UPdateIR);


-------------------------------------------------------------------------------
-----------------  Virtex4 Specific Constants ---------------------------------
-------------------------------------------------------------------------------

  TYPE JtagInstructionType is (UNKNOWN, IR_CAPTURE, BYPASS, IDCODE, USER1, USER2, USER3, USER4);                  

  TYPE PartType            is (XC7A8,XC7A15, XC7A20, XC7A30T, XC7A50T, XC7A100T, XC7A200T, XC7A350T, XC7K30T, XC7K70T, XC7K125T, XC7K160T, XC7K235T, XC7K290T, XC7K325T, XC7K355T, XC7K410T, XC7K420T, XC7K480T, XC7V160T, XC7V450T, XC7V585T, XC7V855T, XC7VX80T, XC7VX82T, XC7VX330T, XC7VX410T, XC7VX415T, XC7VX485T, XC7VX550T, XC7VX690T, XC7VX980T, XC7VX1140, XC7V1500, XC7V2000, XC7Z010, XC7Z020, XC7Z030, XC7Z045);

  constant IRLengthMax          : integer := 24;
  constant IDLength             : integer := 32;
  constant RevBitsLength        : integer := 4;

  constant IR_CAPTURE_VAL	: std_logic_vector ((IRLengthMax -1) downto 0) := "010001010001010001010001";
  constant BYPASS_INSTR         : std_logic_vector ((IRLengthMax -1) downto 0) := "111111111111111111111111";
  constant IDCODE_INSTR         : std_logic_vector ((IRLengthMax -1) downto 0) := "001001001001001001001001";
  constant USER1_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "000010100100100100100100";
  constant USER2_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "000011100100100100100100";
  constant USER3_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "100010100100100100100100";
  constant USER4_INSTR          : std_logic_vector ((IRLengthMax -1) downto 0) := "100011100100100100100100";


  constant TCK_TDO_delay        : time := 6.0 ns;
--------------------------------------------------------

  constant DELAY_SIG     : time := 1 ps;

  signal CurrentState    : JtagTapState := TestLogicReset;
  signal JtagInstruction : JtagInstructionType := IDCODE;

  signal jtag_state_name	: JtagTapState		:= TestLogicReset;
  signal jtag_instruction_name	: JtagInstructionType	:= IDCODE;

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
	if((PART_NAME   = "7A8") or (PART_NAME = "7a8")) then
	      PartName_var := XC7A8;
	      IDCODE_str   := X"03628093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7A15") or (PART_NAME = "7a15")) then
	      PartName_var := XC7A15;
	      IDCODE_str   := X"03627093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7A20") or (PART_NAME = "7a20")) then
	      PartName_var := XC7A20;
	      IDCODE_str   := X"03622093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7A30T") or (PART_NAME = "7a30t")) then
	      PartName_var := XC7A30T;
	      IDCODE_str   := X"0362D093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7A50T") or (PART_NAME = "7a50t")) then
	      PartName_var := XC7A50T;
	      IDCODE_str   := X"0362C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7A100T") or (PART_NAME = "7a100t")) then
	      PartName_var := XC7A100T;
	      IDCODE_str   := X"03631093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7A200T") or (PART_NAME = "7a200t")) then
	      PartName_var := XC7A200T;
	      IDCODE_str   := X"03636093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7A350T") or (PART_NAME = "7a350t")) then
	      PartName_var := XC7A350T;
	      IDCODE_str   := X"0363B093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K30T") or (PART_NAME = "7k30t")) then
	      PartName_var := XC7K30T;
	      IDCODE_str   := X"03642093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K70T") or (PART_NAME = "7k70t")) then
	      PartName_var := XC7K70T;
	      IDCODE_str   := X"03647093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K125T") or (PART_NAME = "7k125t")) then
	      PartName_var := XC7K125T;
	      IDCODE_str   := X"0365C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K160T") or (PART_NAME = "7k160t")) then
	      PartName_var := XC7K160T;
	      IDCODE_str   := X"0364C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K235T") or (PART_NAME = "7k235t")) then
	      PartName_var := XC7K235T;
	      IDCODE_str   := X"0365B093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K290T") or (PART_NAME = "7k290t")) then
	      PartName_var := XC7K290T;
	      IDCODE_str   := X"0365D093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K325T") or (PART_NAME = "7k325t")) then
	      PartName_var := XC7K325T;
	      IDCODE_str   := X"03651093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K355T") or (PART_NAME = "7k355t")) then
	      PartName_var := XC7K355T;
	      IDCODE_str   := X"03747093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K410T") or (PART_NAME = "7k410t")) then
	      PartName_var := XC7K410T;
	      IDCODE_str   := X"03656093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K420T") or (PART_NAME = "7k420t")) then
	      PartName_var := XC7K420T;
	      IDCODE_str   := X"03752093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K480T") or (PART_NAME = "7k480t")) then
	      PartName_var := XC7K480T;
	      IDCODE_str   := X"03751093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7K480T") or (PART_NAME = "7k480t")) then
	      PartName_var := XC7K480T;
	      IDCODE_str   := X"03751093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7V160T") or (PART_NAME = "7v160t")) then
	      PartName_var := XC7V160T;
	      IDCODE_str   := X"03662093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7V450T") or (PART_NAME = "7v450t")) then
	      PartName_var := XC7V450T;
	      IDCODE_str   := X"0366C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7V585T") or (PART_NAME = "7v585t")) then
	      PartName_var := XC7V585T;
	      IDCODE_str   := X"03671093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7V855T") or (PART_NAME = "7v855t")) then
	      PartName_var := XC7V855T;
	      IDCODE_str   := X"03676093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX80T") or (PART_NAME = "7vx80t")) then
	      PartName_var := XC7VX80T;
	      IDCODE_str   := X"03680093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX82T") or (PART_NAME = "7vx82t")) then
	      PartName_var := XC7VX82T;
	      IDCODE_str   := X"03681093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX330T") or (PART_NAME = "7vx330t")) then
	      PartName_var := XC7VX330T;
	      IDCODE_str   := X"03667093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX410T") or (PART_NAME = "7vx410t")) then
	      PartName_var := XC7VX410T;
	      IDCODE_str   := X"0369B093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX415T") or (PART_NAME = "7vx415t")) then
	      PartName_var := XC7VX415T;
	      IDCODE_str   := X"03682093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX485T") or (PART_NAME = "7vx485t")) then
	      PartName_var := XC7VX485T;
	      IDCODE_str   := X"03687093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX550T") or (PART_NAME = "7vx550t")) then
	      PartName_var := XC7VX550T;
	      IDCODE_str   := X"03692093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX690T") or (PART_NAME = "7vx690t")) then
	      PartName_var := XC7VX690T;
	      IDCODE_str   := X"03691093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX980T") or (PART_NAME = "7vx980t")) then
	      PartName_var := XC7VX980T;
	      IDCODE_str   := X"03696093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX980T") or (PART_NAME = "7vx980t")) then
	      PartName_var := XC7VX980T;
	      IDCODE_str   := X"03696093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7VX1140") or (PART_NAME = "7vx1140")) then
	      PartName_var := XC7VX1140;
	      IDCODE_str   := X"036D5093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7V1500") or (PART_NAME = "7v1500")) then
	      PartName_var := XC7V1500;
	      IDCODE_str   := X"036B1093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7V2000") or (PART_NAME = "7v2000")) then
	      PartName_var := XC7V2000;
	      IDCODE_str   := X"036B3093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7Z010") or (PART_NAME = "7z010")) then
	      PartName_var := XC7Z010;
	      IDCODE_str   := X"03722093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7Z020") or (PART_NAME = "7z020")) then
	      PartName_var := XC7Z020;
	      IDCODE_str   := X"03727093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7Z030") or (PART_NAME = "7z030")) then
	      PartName_var := XC7Z030;
	      IDCODE_str   := X"0372C093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	elsif((PART_NAME   = "7Z045") or (PART_NAME = "7z045")) then
	      PartName_var := XC7Z045;
	      IDCODE_str   := X"03731093";
	      IDCODEval_sig <= To_StdLogicVector(IDCODE_str);
	else
		assert false
	report "Attribute Syntax Error: The allowed values for PART_NAME are 7A8, 7A15, 7A20, 7A30T, 7A50T, 7A100T, 7A200T, 7A350T, 7K30T, 7K70T, 7K125T, 7K160T, 7K235T, 7K290T, 7K325T, 7K355T, 7K410T, 7K420T, 7K480T, 7K480T, 7V160T, 7V450T, 7V585T, 7V855T, 7VX80T, 7VX82T, 7VX330T, 7VX410T, 7VX415T, 7VX485T, 7VX550T, 7VX690T, 7VX980T, 7VX980T, 7VX1140, 7V1500, 7V2000, 7Z010, 7Z020, 7Z030 or 7Z045, "
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
       if(TCK_dly'event and TCK_dly = '1') then
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
              
                 if(IRcontent_sig = BYPASS_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
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
        IRcontent_sig((IRLength -1) downto 0) <= IDCODE_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength));  -- IDCODE instruction is loaded into IR reg.
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
     if(IRcontent_sig((IRLength -1) downto 0) = IR_CAPTURE_VAL((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
        JTagInstruction <= IR_CAPTURE;

     elsif(IRcontent_sig((IRLength -1) downto 0) = BYPASS_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
        JTagInstruction <= BYPASS;
        BYPASS_sig <= '1';
        IDCODE_sig <= '0';
        USER1_sig  <= '0';
        USER2_sig  <= '0';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = IDCODE_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
        JTagInstruction <= IDCODE;
        BYPASS_sig <= '0';
        IDCODE_sig <= '1';
        USER1_sig  <= '0';
        USER2_sig  <= '0';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER1_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
        JTagInstruction <= USER1;
        BYPASS_sig <= '0';
        IDCODE_sig <= '0';
        USER1_sig  <= '1';
        USER2_sig  <= '0';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER2_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
        JTagInstruction <= USER2;
        BYPASS_sig <= '0';
        IDCODE_sig <= '0';
        USER1_sig  <= '0';
        USER2_sig  <= '1';
        USER3_sig  <= '0';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER3_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
        JTagInstruction <= USER3;
        BYPASS_sig <= '0';
        IDCODE_sig <= '0';
        USER1_sig  <= '0';
        USER2_sig  <= '0';
        USER3_sig  <= '1';
        USER4_sig  <= '0';

     elsif(IRcontent_sig((IRLength -1) downto 0) = USER4_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))) then
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
         when ((CurrentState = ShiftDR) and (IRcontent_sig=BYPASS_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))))
       else IRegLastBit_sig
         when (CurrentState = ShiftIR)
       else IDregLastBit_sig
         when ((CurrentState = ShiftDR) and (IRcontent_sig=IDCODE_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))))
       else JTAG_USER_TDO1_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER1_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))))
       else JTAG_USER_TDO2_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER2_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))))
       else JTAG_USER_TDO3_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER3_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))))
       else JTAG_USER_TDO4_GLBL
         when ((CurrentState = ShiftDR) and (IRcontent_sig=USER4_INSTR((IRLengthMax - 1) downto (IRLengthMax - IRLength))))
       else 'Z';
 

--####################################################################
--#####                         Timing                           #####
--####################################################################
  prcs_output                    : process (TDO_latch)
  begin
     TDO <= TDO_latch after TCK_TDO_delay; 
  end process;


--####################################################################
--####################################################################

end JTAG_SIME2_SUBMOD_V;

----- CELL JTAG_SIME2  -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;
use unisim.Vcomponents.all;

entity JTAG_SIME2 is

  generic(
      PART_NAME : string := "7A8"
      );

  port(
      TDO	: out std_ulogic;

      TCK	: in  std_ulogic;
      TDI	: in  std_ulogic;
      TMS	: in  std_ulogic
    );

end JTAG_SIME2;

architecture JTAG_SIME2_V OF JTAG_SIME2 is

  component JTAG_SIME2_SUBMOD
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

  signal TCK_dly		: std_ulogic := 'X';
  signal TDI_dly		: std_ulogic := 'X';
  signal TMS_dly		: std_ulogic := 'X';
  signal TRST_dly		: std_ulogic := '0';

  signal TDO_zd			: std_ulogic := 'X';
  signal TDO_viol		: std_ulogic := 'X';

  signal TDO1_zd                : std_ulogic := 'X';
  signal TDO2_zd                : std_ulogic := 'X';

  signal IRLen6, IRLen12, IRLen18, IRLen24  : boolean := false;

--  signal IR_LENGTH : integer := get_IRLength(PART_NAME);  
------------------------------------------------
-- function get_IRLength
------------------------------------------------

  function get_IRLength(
     PartName     : in string
   ) return integer is

  begin
    if((PartName = "7A8") OR (PartName = "7A15") OR (PartName = "7A20") OR
       (PartName = "7A30T") OR (PartName = "7A50T") OR (PartName = "7A100T") OR
       (PartName = "7A200T") OR (PartName = "7A350T") OR (PartName = "7K30T") OR
       (PartName = "7K70T") OR (PartName = "7K125T") OR (PartName = "7K160T") OR
       (PartName = "7K235T") OR (PartName = "7K290T") OR (PartName = "7K325T") OR
       (PartName = "7K355T") OR (PartName = "7Z010") OR (PartName = "7Z020") OR
       (PartName = "7Z030") OR (PartName = "7Z045") OR
       (PartName = "7a8") OR (PartName = "7a15") OR (PartName = "7a20") OR
       (PartName = "7a30t") OR (PartName = "7a50t") OR (PartName = "7a100t") OR
       (PartName = "7a200t") OR (PartName = "7a350t") OR (PartName = "7k30t") OR
       (PartName = "7k70t") OR (PartName = "7k125t") OR (PartName = "7k160t") OR
       (PartName = "7k235t") OR (PartName = "7k290t") OR (PartName = "7k325t") OR
       (PartName = "7k355t") OR (PartName = "7z010") OR (PartName = "7z020") OR
       (PartName = "7z030") OR (PartName = "7z045")


       ) then
      return 6;
    elsif((PartName = "7K410T") OR (PartName = "7K420T") OR (PartName = "7K480T") OR
          (PartName = "7V160T") OR (PartName = "7V450T") OR (PartName = "7V585T") OR
          (PartName = "7V855T") OR (PartName = "7VX80T") OR (PartName = "7VX82T") OR
          (PartName = "7VX330T") OR (PartName = "7VX410T") OR (PartName = "7VX415T") OR
          (PartName = "7VX485T") OR (PartName = "7VX550T") OR (PartName = "7VX690T") OR
          (PartName = "7VX980T") OR
          (PartName = "7k410t") OR (PartName = "7k420t") OR (PartName = "7k480t") OR
          (PartName = "7v160t") OR (PartName = "7v450t") OR (PartName = "7v585t") OR
          (PartName = "7v855t") OR (PartName = "7vx80t") OR (PartName = "7vx82t") OR
          (PartName = "7vx330t") OR (PartName = "7vx410t") OR (PartName = "7vx415t") OR
          (PartName = "7vx485t") OR (PartName = "7vx550t") OR (PartName = "7vx690t") OR
          (PartName = "7vx980t")) then
      return 18;
    elsif((PartName = "7VX1140") OR (PartName = "7V1500") OR (PartName = "7V2000") OR
          (PartName = "7vx1140") OR (PartName = "7v1500") OR (PartName = "7v2000")) then
      return 24;
    else
      return 0;
    end if;
  end;

  
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
          IRLen6 <= true;
      elsif((PART_NAME   = "FX40") or (PART_NAME = "fx40") or
         (PART_NAME   = "FX60") or (PART_NAME = "fx60") or
         (PART_NAME   = "FX100") or (PART_NAME = "fx100") or
         (PART_NAME   = "FX140") or (PART_NAME = "fx140") or
         (PART_NAME   = "FX200") or (PART_NAME = "fx200")) then
          IRLen12 <= true;
      end if;

      wait;

  end process prcs_init;

--####################################################################
--#####                       Generate                           #####
--####################################################################
        JTAG_INST : JTAG_SIME2_SUBMOD
          generic map (
            PART_NAME => PART_NAME,
            IRLength  => get_IRLength(PART_NAME) 
          )
          port map (
            TDO => TDO1_zd,
            TCK => TCK_dly,
            TDI => TDI_dly,
            TMS => TMS_dly
          );

         
--####################################################################

  TDO <= TDO1_zd;

end JTAG_SIME2_V;
