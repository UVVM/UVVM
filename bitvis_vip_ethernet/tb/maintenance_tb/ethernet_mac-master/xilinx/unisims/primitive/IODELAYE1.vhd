-------------------------------------------------------------------------------
-- Copyright (c) 1995/2011 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input and/or Output Fixed or Variable Delay Element
-- /___/   /\     Filename : IODELAYE1.vhd
-- \   \  /  \    Timestamp : Tue Sep  9 23:12:45 PDT 2008
--  \___\/\___\
--
-- Revision:
--    09/10/08 - Initial version.
--    01/31/09 - IR 506083 -- Fixed function InitDelayCount for delay_type=VARIABLE.
--    02/19/09 - CR 508856 -- CNTVALUEOUT fix
--    04/22/09 - CR 519123 -- Changed HIGH_PERFORMANCE_MODE default to FALSE.
--    12/15/09 - CR 541320 -- added CLKIN_dly to the sensitivity list of data_mux 
--    11/30/10 - CR 581733 -- fixed the unisim output timing side with SIM_ODELAY_D
--    09/21/11 - CR 623071 -- Updated REFCLK_FREQUENCY check message
--    12/15/11 - CR 615802 -- Changed Average tap vaules based on REFCLK_FREQUENC
-- End Revision

----- CELL IODELAYE1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity IODELAYE1 is

  generic(

      CINVCTRL_SEL	: boolean	:= FALSE;
      DELAY_SRC		: string	:= "I";
      HIGH_PERFORMANCE_MODE		: boolean	:= FALSE;
      IDELAY_TYPE	: string	:= "DEFAULT";
      IDELAY_VALUE	: integer	:= 0;
      ODELAY_TYPE	: string	:= "FIXED";
      ODELAY_VALUE	: integer	:= 0;
      REFCLK_FREQUENCY	: real		:= 200.0;
      SIGNAL_PATTERN	: string	:= "DATA"
      );

  port(
      CNTVALUEOUT : out std_logic_vector(4 downto 0);
      DATAOUT	  : out std_ulogic;

      C           : in  std_ulogic;
      CE          : in  std_ulogic;
      CINVCTRL    : in std_ulogic;
      CLKIN       : in std_ulogic;
      CNTVALUEIN  : in std_logic_vector(4 downto 0);
      DATAIN	  : in  std_ulogic;
      IDATAIN	  : in  std_ulogic;
      INC         : in  std_ulogic;
      ODATAIN     : in  std_ulogic;
      RST         : in  std_ulogic;
      T           : in  std_ulogic
      );

end IODELAYE1;

architecture IODELAYE1_V OF IODELAYE1 is

  constant	ILEAK_ADJUST		: real := 1.0;
  constant	D_IODELAY_OFFSET	: real := 0.0;


------------------------------------------------
-- function InitDelayCcount
------------------------------------------------

   function InitDelayCount(
                   IoType     : in string;
                   DelayType  : in string;
                   DelayValue : in integer;
                   CounterVal : in  std_logic_vector(4 downto 0)
   ) return integer is

  begin
    if(IoType = "I") then
       if((DelayType = "DEFAULT") OR (DelayType = "FIXED") OR (DelayType = "VARIABLE")) then  
           return DelayValue;
       elsif(DelayType = "VAR_LOADABLE") then
           return SLV_TO_INT(CounterVal); 
       else return 0;
       end if;
    elsif(IoType = "O") then
       if((DelayType = "FIXED") OR (DelayType = "VARIABLE")) then
           return DelayValue;
       elsif(DelayType = "VAR_LOADABLE") then
           return SLV_TO_INT(CounterVal); 
       else return 0;
       end if;
    else 
       return 0;
    end if;
  end;

------------------------------------------------
-- function CalcTapDelay
------------------------------------------------

   function CalcTapDelay(
                   refclk_freqncy     : in real;
                   max_freqncy        : in real;
                   min_freqncy        : in real
   ) return real is
   variable 	 DELAY_PER_TAP           : real := 0.0;
   constant      ILEAK_ADJUST            : real := 1.0;
   constant      D_IODELAY_OFFSET        : real := 0.0;

  begin
-- CR 615802 
--    if((refclk_freqncy <= max_freqncy) and (refclk_freqncy >= min_freqncy)) then
--       return 52;
--    else 
--      return 78;
--    end if;
      DELAY_PER_TAP := ((1.0/refclk_freqncy) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IODELAY_OFFSET ;
      return DELAY_PER_TAP;
  end;
-------------------- constants --------------------------

  constant	MAX_DELAY_COUNT	: integer := 31;
  constant	MIN_DELAY_COUNT	: integer := 0;

  constant	MAX_REFCLK_FREQUENCYL   : real := 210.0;
  constant	MIN_REFCLK_FREQUENCYL   : real := 190.0;

  constant	MAX_REFCLK_FREQUENCYH   : real := 310.0;
  constant	MIN_REFCLK_FREQUENCYH   : real := 290.0;

  constant      INIT_DELAY              : time := 144 ps; 

  signal	C_ipd		: std_ulogic := 'X';
  signal	CE_ipd		: std_ulogic := 'X';
  signal	CINVCTRL_ipd	: std_ulogic := 'X';
  signal	CLKIN_ipd	: std_ulogic := 'X';
  signal	CNTVALUEIN_ipd	: std_logic_vector(4 downto 0) := (others => '0');
  signal GSR            : std_ulogic := '0';
  signal	GSR_ipd		: std_ulogic := 'X';
  signal	DATAIN_ipd	: std_ulogic := 'X';
  signal	IDATAIN_ipd	: std_ulogic := 'X';
  signal	INC_ipd		: std_ulogic := 'X';
  signal	ODATAIN_ipd	: std_ulogic := 'X';
  signal	RST_ipd		: std_ulogic := 'X';
  signal	T_ipd		: std_ulogic := 'X';

  signal	C_dly		: std_ulogic := 'X';
  signal	CE_dly		: std_ulogic := 'X';
  signal	CINVCTRL_dly	: std_ulogic := 'X';
  signal	CLKIN_dly	: std_ulogic := 'X';
  signal        CNTVALUEIN_dly  : std_logic_vector(4 downto 0) := (others => '0');
  signal	GSR_dly		: std_ulogic := '0';
  signal	DATAIN_dly	: std_ulogic := 'X';
  signal	IDATAIN_dly	: std_ulogic := 'X';
  signal	INC_dly		: std_ulogic := 'X';
  signal	ODATAIN_dly	: std_ulogic := 'X';
  signal	RST_dly		: std_ulogic := 'X';
  signal	T_dly		: std_ulogic := 'X';

  signal	C_in		: std_ulogic := 'X';

  signal	IDATAOUT_delayed	: std_ulogic := 'X';
--  signal	IDATAOUT_zd		: std_ulogic := 'X';
--  signal	IDATAOUT_viol		: std_ulogic := 'X';

  signal	ODATAOUT_delayed	: std_ulogic := 'X';
--  signal	ODATAOUT_zd		: std_ulogic := 'X';
--  signal	ODATAOUT_viol		: std_ulogic := 'X';

  signal	DATAOUT_zd		: std_ulogic := 'X';
--  signal	DATAOUT_viol		: std_ulogic := 'X';

  signal        CNTVALUEOUT_zd  : std_logic_vector(4 downto 0) := (others => '0');
  signal	oDelay		: time := 0.0 ps; 

  signal	data_mux	: std_ulogic := 'X';
  signal	Violation	: std_ulogic := '0';

-------------- variable declaration -------------------------

  signal	OneTapDelay        : time := CalcTapDelay(REFCLK_FREQUENCY, MAX_REFCLK_FREQUENCYH, MIN_REFCLK_FREQUENCYH) * 1.0 ps; 
  signal	idelay_count       : integer := InitDelayCount("I", IDELAY_TYPE, IDELAY_VALUE, "00000");
  signal	odelay_count       : integer := InitDelayCount("O", ODELAY_TYPE, ODELAY_VALUE, "00000");
  signal	CNTVALUEIN_INTEGER : integer := 0;
  signal	cntvalueout_pre	   : std_logic_vector(4 downto 0);
  signal	tap_out		   : std_ulogic := 'X';

  signal   delay_chain_0,  delay_chain_1,  delay_chain_2,  delay_chain_3,
           delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
           delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
           delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
           delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
           delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
           delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
           delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31 : std_ulogic;

begin

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  CINVCTRL_dly   	 <= CINVCTRL       	after 0 ps;
  CLKIN_dly      	 <= CLKIN          	after 0 ps;
  CNTVALUEIN_dly 	 <= CNTVALUEIN     	after 0 ps;
  DATAIN_dly     	 <= DATAIN         	after 0 ps;
  IDATAIN_dly    	 <= IDATAIN        	after 0 ps;
  INC_dly        	 <= INC            	after 0 ps;
  ODATAIN_dly    	 <= ODATAIN        	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;
  T_dly          	 <= T              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable TapCount_var   : integer := 0;
  variable IsTapDelay_var : boolean := true; 

  variable idelaytypefixed_var       : boolean := false; 
  variable idelaytypedefault_var     : boolean := false; 
  variable idelaytypevariable_var    : boolean := false;
  variable idelaytypevarloadable_var : boolean := true;

  variable odelaytypefixed_var       : boolean := false; 
  variable odelaytypevariable_var    : boolean := false;
  variable odelaytypevarloadable_var : boolean := true;

  variable tmp_var : boolean := true;

--  variable CALC_TAPDELAY : real := CalcTapDelay(REFCLK_FREQUENCY, MAX_REFCLK_FREQUENCYH, MIN_REFCLK_FREQUENCYH);

  begin
     -------- SIGNAL_PATTERN check
     if((SIGNAL_PATTERN /= "CLOCK") and (SIGNAL_PATTERN /= "DATA"))then
         assert false
         report "Attribute Syntax Error: Legal values for SIGNAL_PATTERN are DATA or CLOCK"
         severity Failure;
     end if;

     -------- HIGH_PERFORMANCE_MODE check

     case HIGH_PERFORMANCE_MODE is
       when true | false => null;
       when others =>
          assert false
          report "Attribute Syntax Error: The attribute HIGH_PERFORMANCE_MODE on IODELAYE1 must be set to either true or false."
          severity Failure;
     end case;

     -------- IDELAY_TYPE check

     if(IDELAY_TYPE = "DEFAULT") then
        idelaytypedefault_var     := true;
        idelaytypefixed_var       := false;
        idelaytypevariable_var    := false;
        idelaytypevarloadable_var := false;
     elsif(IDELAY_TYPE = "FIXED") then
        idelaytypedefault_var     := false;
        idelaytypefixed_var       := true;
        idelaytypevariable_var    := false;
        idelaytypevarloadable_var := false;
     elsif(IDELAY_TYPE = "VARIABLE") then
        idelaytypedefault_var     := false;
        idelaytypefixed_var       := false;
        idelaytypevariable_var    := true;
        idelaytypevarloadable_var := false;
     elsif(IDELAY_TYPE = "VAR_LOADABLE") then
        idelaytypedefault_var     := false;
        idelaytypefixed_var       := false;
        idelaytypevariable_var    := false;
        idelaytypevarloadable_var := true;
     else
       GenericValueCheckMessage
       (  HeaderMsg  => " Attribute Syntax Warning ",
          GenericName => " IDELAY_TYPE ",
          EntityName => "/IODELAYE1",
          GenericValue => IDELAY_TYPE,
          Unit => "",
          ExpectedValueMsg => " The Legal values for this attribute are ",
          ExpectedGenericValue => " DEFAULT, FIXED, VARIABLE or VAR_LOADABLE ",
          TailMsg => "",
          MsgSeverity => failure 
       );
     end if;

     -------- ODELAY_TYPE check

     if(ODELAY_TYPE = "FIXED") then
        odelaytypefixed_var       := true;
        odelaytypevariable_var    := false;
        odelaytypevarloadable_var := false;
     elsif(ODELAY_TYPE = "VARIABLE") then
        odelaytypefixed_var       := false;
        odelaytypevariable_var    := true;
        odelaytypevarloadable_var := false;
     elsif(ODELAY_TYPE = "VAR_LOADABLE") then
        odelaytypefixed_var       := false;
        odelaytypevariable_var    := false;
        odelaytypevarloadable_var := true;
     else
       GenericValueCheckMessage
       (  HeaderMsg  => " Attribute Syntax Warning ",
          GenericName => " ODELAY_TYPE ",
          EntityName => "/IODELAYE1",
          GenericValue => ODELAY_TYPE,
          Unit => "",
          ExpectedValueMsg => " The Legal values for this attribute are ",
          ExpectedGenericValue => " FIXED, VARIABLE or VAR_LOADABLE ",
          TailMsg => "",
          MsgSeverity => failure 
       );
     end if;

     -------- IDELAY_VALUE check

     if((IDELAY_VALUE < MIN_DELAY_COUNT) or (ODELAY_VALUE > MAX_DELAY_COUNT)) then 
        GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Warning ",
           GenericName => " IDELAY_VALUE ",
           EntityName => "/IODELAYE1",
           GenericValue => IDELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 30, 31 ",
           TailMsg => "",
           MsgSeverity => failure 
        );
     end if;

     -------- ODELAY_VALUE check

     if((ODELAY_VALUE < MIN_DELAY_COUNT) or (ODELAY_VALUE > MAX_DELAY_COUNT)) then 
        GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Warning ",
           GenericName => " ODELAY_VALUE ",
           EntityName => "/IODELAYE1",
           GenericValue => ODELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 30, 31 ",
           TailMsg => "",
           MsgSeverity => failure 
        );
     end if;


     -------- REFCLK_FREQUENCY check

     if((REFCLK_FREQUENCY < MIN_REFCLK_FREQUENCYL) or (REFCLK_FREQUENCY > MAX_REFCLK_FREQUENCYH)) then 
         assert false
         report "Attribute Syntax Error: Legal values for REFCLK_FREQUENCY are either between 190.0 and 210.0, or between 290.0 and 310.0"
         severity Failure;
     end if;

--     odelay_count <= ODELAY_VALUE;
--     CALC_TAPDELAY := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IODELAY_OFFSET ;
--     OneTapDelay   <= CALC_TAPDELAY * 1.0 ps; 

     -------- CALC_TAPDELAY check
     
     wait;
  end process prcs_init;
--####################################################################
--#####                Dynamic clock inversion                   #####
--####################################################################
  prcs_dci:process(C_dly , CINVCTRL_dly)
  begin
     if(CINVCTRL_SEL) then
       if(CINVCTRL_dly = '1') then
          C_in <= NOT C_dly;
       else
          C_in <= C_dly;
       end if;
     else
       C_in <= C_dly;
     end if;
  end process prcs_dci;
--####################################################################
--#####                       cntvalueout                        #####
--####################################################################
  prcs_cntvalueout:process(T_dly , idelay_count, odelay_count)
  begin
     if(DELAY_SRC = "IO") then
        if(T_dly = '1') then
           cntvalueout_pre <= CONV_STD_LOGIC_VECTOR(idelay_count, 5);
        elsif(T_dly = '0') then
           cntvalueout_pre <= CONV_STD_LOGIC_VECTOR(odelay_count, 5);
        end if;
     elsif(DELAY_SRC = "O") then
           cntvalueout_pre <= CONV_STD_LOGIC_VECTOR(odelay_count, 5);
     else
           cntvalueout_pre <= CONV_STD_LOGIC_VECTOR(idelay_count, 5);
     end if;
  end process prcs_cntvalueout;
--####################################################################
--#####                  CALCULATE iDelay                        #####
--####################################################################
  prcs_calc_idelay:process(C_in, GSR_dly, RST_dly)
--  variable idelay_count_var : integer := InitDelayCount("I", IDELAY_TYPE, IDELAY_VALUE, CNTVALUEIN);
  variable idelay_count_var : integer := 0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  begin

     if((IDELAY_TYPE = "VARIABLE") OR (IDELAY_TYPE = "VAR_LOADABLE")) then
       if((GSR_dly = '1') or (FIRST_TIME))then
          idelay_count_var := InitDelayCount("I", IDELAY_TYPE, IDELAY_VALUE, CNTVALUEIN);
          FIRST_TIME   := false;
       elsif(GSR_dly = '0') then
          if(rising_edge(C_in)) then
             if(RST_dly = '1') then
               idelay_count_var := InitDelayCount("I", IDELAY_TYPE, IDELAY_VALUE, CNTVALUEIN);
             elsif((RST_dly = '0') and (CE_dly = '1')) then
                  if(INC_dly = '1') then
                     if (idelay_count_var < MAX_DELAY_COUNT) then
                        idelay_count_var := idelay_count_var + 1;
                     else 
                        idelay_count_var := MIN_DELAY_COUNT;
                     end if;
                  elsif(INC_dly = '0') then
                     if (idelay_count_var > MIN_DELAY_COUNT) then
                         idelay_count_var := idelay_count_var - 1;
                     else
                         idelay_count_var := MAX_DELAY_COUNT;
                     end if;
                         
                  end if; -- INC_dly
             end if; -- RST_dly
             idelay_count  <= idelay_count_var;
          end if; -- C_in
       end if; -- GSR_dly

     end if; -- IDELAY_TYPE 
  end process prcs_calc_idelay;

--####################################################################
--#####                  CALCULATE oDelay                        #####
--####################################################################
  prcs_calc_odelay:process(C_in, GSR_dly, RST_dly)
--  variable odelay_count_var : integer := InitDelayCount("O", ODELAY_TYPE, ODELAY_VALUE, CNTVALUEIN);
  variable odelay_count_var : integer := 0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  begin

     if((ODELAY_TYPE = "VARIABLE") OR (ODELAY_TYPE = "VAR_LOADABLE")) then
       if((GSR_dly = '1') or (FIRST_TIME))then
          odelay_count_var := InitDelayCount("O", ODELAY_TYPE, ODELAY_VALUE, CNTVALUEIN);
          FIRST_TIME   := false;
       elsif(GSR_dly = '0') then
          if(rising_edge(C_in)) then
             if(RST_dly = '1') then
               odelay_count_var := InitDelayCount("O", ODELAY_TYPE, ODELAY_VALUE, CNTVALUEIN);
             elsif((RST_dly = '0') and (CE_dly = '1')) then
                  if(INC_dly = '1') then
                     if (odelay_count_var < MAX_DELAY_COUNT) then
                        odelay_count_var := odelay_count_var + 1;
                     else 
                        odelay_count_var := MIN_DELAY_COUNT;
                     end if;
                  elsif(INC_dly = '0') then
                     if (odelay_count_var > MIN_DELAY_COUNT) then
                         odelay_count_var := odelay_count_var - 1;
                     else
                         odelay_count_var := MAX_DELAY_COUNT;
                     end if;
                         
                  end if; -- INC_in
             end if; -- RST_dly
             odelay_count  <= odelay_count_var;
          end if; -- C_in
       end if; -- GSR_dly

     end if; -- IDELAY_TYPE 
  end process prcs_calc_odelay;

--####################################################################
--#####                      SELECT IDATA_MUX                    #####
--####################################################################
-- CR 541320
  prcs_data_mux:process(DATAIN_dly, IDATAIN_dly, ODATAIN_dly, T_dly, CLKIN_dly)
  begin
      if(DELAY_SRC = "I") then 
            data_mux <= IDATAIN_dly;
      elsif(DELAY_SRC = "O") then
            data_mux <= ODATAIN_dly;
      elsif(DELAY_SRC = "IO") then
            data_mux <= (IDATAIN_dly and T_dly) or (ODATAIN_dly and (not T_dly));
      elsif(DELAY_SRC = "DATAIN") then
            data_mux <= DATAIN_dly;
      elsif(DELAY_SRC = "CLKIN") then
            data_mux <= CLKIN_dly;
      else
         assert false
         report "Attribute Syntax Error : Legal values for DELAY_SRC on IODELAYE1 instance are I, O, CLKIN, IO or DATAIN."
         severity Failure;
      end if;
  end process prcs_data_mux;
--####################################################################
--#####                      DELAY BUFFERS                       #####
--####################################################################
delay_chain_0  <= transport data_mux;
delay_chain_1  <= transport delay_chain_0  after OneTapDelay;
delay_chain_2  <= transport delay_chain_1  after OneTapDelay;
delay_chain_3  <= transport delay_chain_2  after OneTapDelay;
delay_chain_4  <= transport delay_chain_3  after OneTapDelay;
delay_chain_5  <= transport delay_chain_4  after OneTapDelay;
delay_chain_6  <= transport delay_chain_5  after OneTapDelay;
delay_chain_7  <= transport delay_chain_6  after OneTapDelay;
delay_chain_8  <= transport delay_chain_7  after OneTapDelay;
delay_chain_9  <= transport delay_chain_8  after OneTapDelay;
delay_chain_10 <= transport delay_chain_9  after OneTapDelay;
delay_chain_11 <= transport delay_chain_10  after OneTapDelay;
delay_chain_12 <= transport delay_chain_11  after OneTapDelay;
delay_chain_13 <= transport delay_chain_12  after OneTapDelay;
delay_chain_14 <= transport delay_chain_13  after OneTapDelay;
delay_chain_15 <= transport delay_chain_14  after OneTapDelay;
delay_chain_16 <= transport delay_chain_15  after OneTapDelay;
delay_chain_17 <= transport delay_chain_16  after OneTapDelay;
delay_chain_18 <= transport delay_chain_17  after OneTapDelay;
delay_chain_19 <= transport delay_chain_18  after OneTapDelay;
delay_chain_20 <= transport delay_chain_19  after OneTapDelay;
delay_chain_21 <= transport delay_chain_20  after OneTapDelay;
delay_chain_22 <= transport delay_chain_21  after OneTapDelay;
delay_chain_23 <= transport delay_chain_22  after OneTapDelay;
delay_chain_24 <= transport delay_chain_23  after OneTapDelay;
delay_chain_25 <= transport delay_chain_24  after OneTapDelay;
delay_chain_26 <= transport delay_chain_25  after OneTapDelay;
delay_chain_27 <= transport delay_chain_26  after OneTapDelay;
delay_chain_28 <= transport delay_chain_27  after OneTapDelay;
delay_chain_29 <= transport delay_chain_28  after OneTapDelay;
delay_chain_30 <= transport delay_chain_29  after OneTapDelay;
delay_chain_31 <= transport delay_chain_30  after OneTapDelay;

--####################################################################
--#####                Assign Tap Delays                         #####
--####################################################################
  prcs_AssignDelays:process
  begin
-- CR 541320
        if(((DELAY_SRC = "IO") and (T_dly = '1')) or (DELAY_SRC = "I")  or  (DELAY_SRC = "DATAIN") or (DELAY_SRC = "CLKIN")) then
             case idelay_count is
                when 0 =>    tap_out <= delay_chain_0;
                when 1 =>    tap_out <= delay_chain_1;
                when 2 =>    tap_out <= delay_chain_2;
                when 3 =>    tap_out <= delay_chain_3;
                when 4 =>    tap_out <= delay_chain_4;
                when 5 =>    tap_out <= delay_chain_5;
                when 6 =>    tap_out <= delay_chain_6;
                when 7 =>    tap_out <= delay_chain_7;
                when 8 =>    tap_out <= delay_chain_8;
                when 9 =>    tap_out <= delay_chain_9;
                when 10 =>   tap_out <= delay_chain_10;
                when 11 =>   tap_out <= delay_chain_11;
                when 12 =>   tap_out <= delay_chain_12;
                when 13 =>   tap_out <= delay_chain_13;
                when 14 =>   tap_out <= delay_chain_14;
                when 15 =>   tap_out <= delay_chain_15;
                when 16 =>   tap_out <= delay_chain_16;
                when 17 =>   tap_out <= delay_chain_17;
                when 18 =>   tap_out <= delay_chain_18;
                when 19 =>   tap_out <= delay_chain_19;
                when 20 =>   tap_out <= delay_chain_20;
                when 21 =>   tap_out <= delay_chain_21;
                when 22 =>   tap_out <= delay_chain_22;
                when 23 =>   tap_out <= delay_chain_23;
                when 24 =>   tap_out <= delay_chain_24;
                when 25 =>   tap_out <= delay_chain_25;
                when 26 =>   tap_out <= delay_chain_26;
                when 27 =>   tap_out <= delay_chain_27;
                when 28 =>   tap_out <= delay_chain_28;
                when 29 =>   tap_out <= delay_chain_29;
                when 30 =>   tap_out <= delay_chain_30;
                when 31 =>   tap_out <= delay_chain_31;
                when others =>
                    tap_out <= delay_chain_0;
             end case;
        elsif(((DELAY_SRC = "IO") and (T_dly = '0')) or (DELAY_SRC = "O")) then
             case odelay_count is
                when 0 =>    tap_out <= delay_chain_0;
                when 1 =>    tap_out <= delay_chain_1;
                when 2 =>    tap_out <= delay_chain_2;
                when 3 =>    tap_out <= delay_chain_3;
                when 4 =>    tap_out <= delay_chain_4;
                when 5 =>    tap_out <= delay_chain_5;
                when 6 =>    tap_out <= delay_chain_6;
                when 7 =>    tap_out <= delay_chain_7;
                when 8 =>    tap_out <= delay_chain_8;
                when 9 =>    tap_out <= delay_chain_9;
                when 10 =>   tap_out <= delay_chain_10;
                when 11 =>   tap_out <= delay_chain_11;
                when 12 =>   tap_out <= delay_chain_12;
                when 13 =>   tap_out <= delay_chain_13;
                when 14 =>   tap_out <= delay_chain_14;
                when 15 =>   tap_out <= delay_chain_15;
                when 16 =>   tap_out <= delay_chain_16;
                when 17 =>   tap_out <= delay_chain_17;
                when 18 =>   tap_out <= delay_chain_18;
                when 19 =>   tap_out <= delay_chain_19;
                when 20 =>   tap_out <= delay_chain_20;
                when 21 =>   tap_out <= delay_chain_21;
                when 22 =>   tap_out <= delay_chain_22;
                when 23 =>   tap_out <= delay_chain_23;
                when 24 =>   tap_out <= delay_chain_24;
                when 25 =>   tap_out <= delay_chain_25;
                when 26 =>   tap_out <= delay_chain_26;
                when 27 =>   tap_out <= delay_chain_27;
                when 28 =>   tap_out <= delay_chain_28;
                when 29 =>   tap_out <= delay_chain_29;
                when 30 =>   tap_out <= delay_chain_30;
                when 31 =>   tap_out <= delay_chain_31;
                when others =>
                    tap_out <= delay_chain_0;
             end case;
        end if;
  wait on  T_dly, idelay_count, odelay_count, delay_chain_0,  delay_chain_1,  delay_chain_2,  delay_chain_3,
           delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
           delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
           delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
           delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
           delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
           delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
           delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31;

  end process prcs_AssignDelays;

--####################################################################
--#####                  CALCULATE oDelay                         #####
--####################################################################
--  prcs_calc_odelay:process(C_in, GSR_dly, RST_dly)
--  variable odelay_count_var : integer :=0;
--  variable FIRST_TIME   : boolean :=true;
--  variable BaseTime_var : time    := 1 ps ;
--  variable CALC_TAPDELAY : real := 0.0;
--  begin
--     if((GSR_dly = '1') or (FIRST_TIME))then
--        odelay_count_var := ODELAY_VALUE; 
--        CALC_TAPDELAY := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IODELAY_OFFSET ;
--        oDelay        <= real(odelay_count_var) * CALC_TAPDELAY * BaseTime_var; 
--        FIRST_TIME   := false;
--     end if;

--  end process prcs_calc_odelay;

--####################################################################
--#####                      OUTPUT  TAP                         #####
--####################################################################

    CNTVALUEOUT_zd <= cntvalueout_pre;
    DATAOUT_zd     <= tap_out after INIT_DELAY ;

--  prcs_tapout:process(tap_out)
--  begin
--      DATAOUT_zd <= tap_out ;
--  end process prcs_tapout;

--####################################################################
--#####                           OUTPUT                         #####
--####################################################################
  prcs_output:process(DATAOUT_zd, CNTVALUEOUT_zd)
  begin
      CNTVALUEOUT    <= CNTVALUEOUT_zd;
      DATAOUT        <= DATAOUT_zd ;
  end process prcs_output;


end IODELAYE1_V;

