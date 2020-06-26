-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input and/or Output Fixed or Variable Delay Element
-- /___/   /\     Filename : IODELAY.vhd
-- \   \  /  \    Timestamp : Wed Aug 10 16:51:05 PDT 2005
--  \___\/\___\
--
-- Revision:
--    08/10/05 - Initial version.
--    01/11/06 - Changed Equation for CALC_TAPDELAY -- FP
--    03/10/06 - CR 227041 -- Added path delays -- FP
--    06/04/06 - Made the model independent of T pin (except in DELAY_SRC=IO mode) -- FP
--    07/21/06 - CR 234556 fix. Added SIM_DELAY_D to Simprims -- FP
--    01/03/07 - For unisims, the fixed Delay value is taken from the sdf.
--    03/26/07 - CR 436199 HIGH_PERFORMANCE_MODE default change -- FP
--    05/03/07 - CR 438921 SIGNAL_PATTERN addition  -- FP
--    06/11/07 - CR 437230 -- added delay buffer chain
--    08/29/07 - CR 445561 -- Replaced D_IOBDELAY_OFFSET with D_IODELAY_OFFSET
--    04/07/08 - CR 469973 -- Header Description fix
--    28/05/08 - CR 472154 Removed Vital GSR constructs
-- End Revision

----- CELL IODELAY -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IODELAY is

  generic(

      DELAY_SRC		: string	:= "I";
      HIGH_PERFORMANCE_MODE		: boolean	:= true;
      IDELAY_TYPE	: string	:= "DEFAULT";
      IDELAY_VALUE	: integer	:= 0;
      ODELAY_VALUE	: integer	:= 0;
      REFCLK_FREQUENCY	: real		:= 200.0;
      SIGNAL_PATTERN	: string	:= "DATA"
      );

  port(
      DATAOUT	: out std_ulogic;

      C		: in  std_ulogic;
      CE	: in  std_ulogic;
      DATAIN	: in  std_ulogic;
      IDATAIN	: in  std_ulogic;
      INC	: in  std_ulogic;
      ODATAIN	: in  std_ulogic;
      RST	: in  std_ulogic;
      T		: in  std_ulogic
      );

end IODELAY;

architecture IODELAY_V OF IODELAY is

  constant	ILEAK_ADJUST		: real := 1.0;
  constant	D_IODELAY_OFFSET	: real := 0.0;

-----------------------------------------------------------

  constant	MAX_IDELAY_COUNT	: integer := 63;
  constant	MIN_IDELAY_COUNT	: integer := 0;
  constant	MAX_ODELAY_COUNT	: integer := 63;
  constant	MIN_ODELAY_COUNT	: integer := 0;

  constant	MAX_REFCLK_FREQUENCY	: real := 225.0;
  constant	MIN_REFCLK_FREQUENCY	: real := 175.0;


  signal	C_ipd		: std_ulogic := 'X';
  signal	CE_ipd		: std_ulogic := 'X';
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
  signal	GSR_dly		: std_ulogic := '0';
  signal	DATAIN_dly	: std_ulogic := 'X';
  signal	IDATAIN_dly	: std_ulogic := 'X';
  signal	INC_dly		: std_ulogic := 'X';
  signal	ODATAIN_dly	: std_ulogic := 'X';
  signal	RST_dly		: std_ulogic := 'X';
  signal	T_dly		: std_ulogic := 'X';

  signal	IDATAOUT_delayed	: std_ulogic := 'X';
--  signal	IDATAOUT_zd		: std_ulogic := 'X';
--  signal	IDATAOUT_viol		: std_ulogic := 'X';

  signal	ODATAOUT_delayed	: std_ulogic := 'X';
--  signal	ODATAOUT_zd		: std_ulogic := 'X';
--  signal	ODATAOUT_viol		: std_ulogic := 'X';

  signal	DATAOUT_zd		: std_ulogic := 'X';
--  signal	DATAOUT_viol		: std_ulogic := 'X';

  signal	iDelay		: time := 0.0 ps; 
  signal	oDelay		: time := 0.0 ps; 

  signal	data_mux	: std_ulogic := 'X';
  signal	Violation	: std_ulogic := '0';

  signal	OneTapDelay	: time := 0.0 ps; 
  signal	idelay_count	: integer := IDELAY_VALUE;
  signal	odelay_count	: integer := 0;
  signal	tap_out		: std_ulogic := 'X';

  signal   delay_chain_0,  delay_chain_1,  delay_chain_2,  delay_chain_3,
           delay_chain_4,  delay_chain_5,  delay_chain_6,  delay_chain_7,
           delay_chain_8,  delay_chain_9,  delay_chain_10, delay_chain_11,
           delay_chain_12, delay_chain_13, delay_chain_14, delay_chain_15,
           delay_chain_16, delay_chain_17, delay_chain_18, delay_chain_19,
           delay_chain_20, delay_chain_21, delay_chain_22, delay_chain_23,
           delay_chain_24, delay_chain_25, delay_chain_26, delay_chain_27,
           delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31,
           delay_chain_32, delay_chain_33, delay_chain_34, delay_chain_35,
           delay_chain_36, delay_chain_37, delay_chain_38, delay_chain_39,
           delay_chain_40, delay_chain_41, delay_chain_42, delay_chain_43,
           delay_chain_44, delay_chain_45, delay_chain_46, delay_chain_47,
           delay_chain_48, delay_chain_49, delay_chain_50, delay_chain_51,
           delay_chain_52, delay_chain_53, delay_chain_54, delay_chain_55,
           delay_chain_56, delay_chain_57, delay_chain_58, delay_chain_59,
           delay_chain_60, delay_chain_61, delay_chain_62, delay_chain_63 : std_ulogic;

begin

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
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
  variable idelaytypefixed_var  : boolean := false; 
  variable idelaytypedefault_var : boolean := false; 
  variable CALC_TAPDELAY : real := 0.0;
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
          report "Attribute Syntax Error: The attribute HIGH_PERFORMANCE_MODE on IODELAY must be set to either true or false."
          severity Failure;
     end case;

     -------- IDELAY_TYPE check

     if(IDELAY_TYPE = "FIXED") then
        idelaytypefixed_var := true;
     elsif(IDELAY_TYPE = "VARIABLE") then
        idelaytypefixed_var := false;
     elsif(IDELAY_TYPE = "DEFAULT") then
        idelaytypedefault_var := true;
        idelaytypefixed_var := false;
     else
       GenericValueCheckMessage
       (  HeaderMsg  => " Attribute Syntax Warning ",
          GenericName => " IDELAY_TYPE ",
          EntityName => "/IODELAY",
          GenericValue => IDELAY_TYPE,
          Unit => "",
          ExpectedValueMsg => " The Legal values for this attribute are ",
          ExpectedGenericValue => " DEFAULT, FIXED or VARIABLE ",
          TailMsg => "",
          MsgSeverity => failure 
       );
     end if;

     -------- IDELAY_VALUE check

     if((IDELAY_VALUE < MIN_IDELAY_COUNT) or (ODELAY_VALUE > MAX_IDELAY_COUNT)) then 
        GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Warning ",
           GenericName => " IDELAY_VALUE ",
           EntityName => "/IODELAY",
           GenericValue => IDELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 62, 63 ",
           TailMsg => "",
           MsgSeverity => failure 
        );
     end if;

     -------- ODELAY_VALUE check

     if((ODELAY_VALUE < MIN_ODELAY_COUNT) or (ODELAY_VALUE > MAX_ODELAY_COUNT)) then 
        GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Warning ",
           GenericName => " ODELAY_VALUE ",
           EntityName => "/IODELAY",
           GenericValue => ODELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 62, 63 ",
           TailMsg => "",
           MsgSeverity => failure 
        );
     end if;

     -------- REFCLK_FREQUENCY check

     if((REFCLK_FREQUENCY < MIN_REFCLK_FREQUENCY) or (REFCLK_FREQUENCY > MAX_REFCLK_FREQUENCY)) then 
         assert false
         report "Attribute Syntax Error: Legal values for REFCLK_FREQUENCY are 175.0 to 225.0"
         severity Failure;
     end if;

     odelay_count <= ODELAY_VALUE;
     CALC_TAPDELAY := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IODELAY_OFFSET ;
     OneTapDelay   <= CALC_TAPDELAY * 1.0 ps; 
     wait;
  end process prcs_init;
--####################################################################
--#####                  CALCULATE iDelay                        #####
--####################################################################
  prcs_calc_idelay:process(C_dly, GSR_dly, RST_dly)
  variable idelay_count_var : integer :=0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
--  variable CALC_TAPDELAY : real := 0.0;
  begin
     if(IDELAY_TYPE = "VARIABLE") then
       if((GSR_dly = '1') or (FIRST_TIME))then
          idelay_count_var := IDELAY_VALUE; 
--          CALC_TAPDELAY := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IODELAY_OFFSET ;
--          iDelay        <= real(idelay_count_var) * CALC_TAPDELAY * BaseTime_var; 
          FIRST_TIME   := false;
       elsif(GSR_dly = '0') then
          if(rising_edge(C_dly)) then
             if(RST_dly = '1') then
               idelay_count_var := IDELAY_VALUE; 
             elsif((RST_dly = '0') and (CE_dly = '1')) then
                  if(INC_dly = '1') then
                     if (idelay_count_var < MAX_IDELAY_COUNT) then
                        idelay_count_var := idelay_count_var + 1;
                     else 
                        idelay_count_var := MIN_IDELAY_COUNT;
                     end if;
                  elsif(INC_dly = '0') then
                     if (idelay_count_var > MIN_IDELAY_COUNT) then
                         idelay_count_var := idelay_count_var - 1;
                     else
                         idelay_count_var := MAX_IDELAY_COUNT;
                     end if;
                         
                  end if; -- INC_dly
             end if; -- RST_dly
--             iDelay <= real(idelay_count_var) *  CALC_TAPDELAY * BaseTime_var;
             idelay_count  <= idelay_count_var;
          end if; -- C_dly
       end if; -- GSR_dly

     end if; -- IDELAY_TYPE 
  end process prcs_calc_idelay;
--####################################################################
--#####                      SELECT IDATA_MUX                    #####
--####################################################################
  prcs_data_mux:process(DATAIN_dly, IDATAIN_dly, ODATAIN_dly, T_dly)
  begin
      if(DELAY_SRC = "I") then 
            data_mux <= IDATAIN_dly;
      elsif(DELAY_SRC = "O") then
            data_mux <= ODATAIN_dly;
      elsif(DELAY_SRC = "IO") then
            data_mux <= (IDATAIN_dly and T_dly) or (ODATAIN_dly and (not T_dly));
      elsif(DELAY_SRC = "DATAIN") then
            data_mux <= DATAIN_dly;
      else
         assert false
         report "Attribute Syntax Error : Legal values for DELAY_SRC on IODELAY instance are I, O, IO or DATAIN."
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
delay_chain_32 <= transport delay_chain_31  after OneTapDelay;
delay_chain_33 <= transport delay_chain_32  after OneTapDelay;
delay_chain_34 <= transport delay_chain_33  after OneTapDelay;
delay_chain_35 <= transport delay_chain_34  after OneTapDelay;
delay_chain_36 <= transport delay_chain_35  after OneTapDelay;
delay_chain_37 <= transport delay_chain_36  after OneTapDelay;
delay_chain_38 <= transport delay_chain_37  after OneTapDelay;
delay_chain_39 <= transport delay_chain_38  after OneTapDelay;
delay_chain_40 <= transport delay_chain_39  after OneTapDelay;
delay_chain_41 <= transport delay_chain_40  after OneTapDelay;
delay_chain_42 <= transport delay_chain_41  after OneTapDelay;
delay_chain_43 <= transport delay_chain_42  after OneTapDelay;
delay_chain_44 <= transport delay_chain_43  after OneTapDelay;
delay_chain_45 <= transport delay_chain_44  after OneTapDelay;
delay_chain_46 <= transport delay_chain_45  after OneTapDelay;
delay_chain_47 <= transport delay_chain_46  after OneTapDelay;
delay_chain_48 <= transport delay_chain_47  after OneTapDelay;
delay_chain_49 <= transport delay_chain_48  after OneTapDelay;
delay_chain_50 <= transport delay_chain_49  after OneTapDelay;
delay_chain_51 <= transport delay_chain_50  after OneTapDelay;
delay_chain_52 <= transport delay_chain_51  after OneTapDelay;
delay_chain_53 <= transport delay_chain_52  after OneTapDelay;
delay_chain_54 <= transport delay_chain_53  after OneTapDelay;
delay_chain_55 <= transport delay_chain_54  after OneTapDelay;
delay_chain_56 <= transport delay_chain_55  after OneTapDelay;
delay_chain_57 <= transport delay_chain_56  after OneTapDelay;
delay_chain_58 <= transport delay_chain_57  after OneTapDelay;
delay_chain_59 <= transport delay_chain_58  after OneTapDelay;
delay_chain_60 <= transport delay_chain_59  after OneTapDelay;
delay_chain_61 <= transport delay_chain_60  after OneTapDelay;
delay_chain_62 <= transport delay_chain_61  after OneTapDelay;
delay_chain_63 <= transport delay_chain_62  after OneTapDelay;

--####################################################################
--#####                Assign Tap Delays                         #####
--####################################################################
  prcs_AssignDelays:process
  begin
        if(((DELAY_SRC = "IO") and (T_dly = '1')) or (DELAY_SRC = "I")  or  (DELAY_SRC = "DATAIN")) then
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
                when 32 =>   tap_out <= delay_chain_32;
                when 33 =>   tap_out <= delay_chain_33;
                when 34 =>   tap_out <= delay_chain_34;
                when 35 =>   tap_out <= delay_chain_35;
                when 36 =>   tap_out <= delay_chain_36;
                when 37 =>   tap_out <= delay_chain_37;
                when 38 =>   tap_out <= delay_chain_38;
                when 39 =>   tap_out <= delay_chain_39;
                when 40 =>   tap_out <= delay_chain_40;
                when 41 =>   tap_out <= delay_chain_41;
                when 42 =>   tap_out <= delay_chain_42;
                when 43 =>   tap_out <= delay_chain_43;
                when 44 =>   tap_out <= delay_chain_44;
                when 45 =>   tap_out <= delay_chain_45;
                when 46 =>   tap_out <= delay_chain_46;
                when 47 =>   tap_out <= delay_chain_47;
                when 48 =>   tap_out <= delay_chain_48;
                when 49 =>   tap_out <= delay_chain_49;
                when 50 =>   tap_out <= delay_chain_50;
                when 51 =>   tap_out <= delay_chain_51;
                when 52 =>   tap_out <= delay_chain_52;
                when 53 =>   tap_out <= delay_chain_53;
                when 54 =>   tap_out <= delay_chain_54;
                when 55 =>   tap_out <= delay_chain_55;
                when 56 =>   tap_out <= delay_chain_56;
                when 57 =>   tap_out <= delay_chain_57;
                when 58 =>   tap_out <= delay_chain_58;
                when 59 =>   tap_out <= delay_chain_59;
                when 60 =>   tap_out <= delay_chain_60;
                when 61 =>   tap_out <= delay_chain_61;
                when 62 =>   tap_out <= delay_chain_62;
                when 63 =>   tap_out <= delay_chain_63;
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
                when 32 =>   tap_out <= delay_chain_32;
                when 33 =>   tap_out <= delay_chain_33;
                when 34 =>   tap_out <= delay_chain_34;
                when 35 =>   tap_out <= delay_chain_35;
                when 36 =>   tap_out <= delay_chain_36;
                when 37 =>   tap_out <= delay_chain_37;
                when 38 =>   tap_out <= delay_chain_38;
                when 39 =>   tap_out <= delay_chain_39;
                when 40 =>   tap_out <= delay_chain_40;
                when 41 =>   tap_out <= delay_chain_41;
                when 42 =>   tap_out <= delay_chain_42;
                when 43 =>   tap_out <= delay_chain_43;
                when 44 =>   tap_out <= delay_chain_44;
                when 45 =>   tap_out <= delay_chain_45;
                when 46 =>   tap_out <= delay_chain_46;
                when 47 =>   tap_out <= delay_chain_47;
                when 48 =>   tap_out <= delay_chain_48;
                when 49 =>   tap_out <= delay_chain_49;
                when 50 =>   tap_out <= delay_chain_50;
                when 51 =>   tap_out <= delay_chain_51;
                when 52 =>   tap_out <= delay_chain_52;
                when 53 =>   tap_out <= delay_chain_53;
                when 54 =>   tap_out <= delay_chain_54;
                when 55 =>   tap_out <= delay_chain_55;
                when 56 =>   tap_out <= delay_chain_56;
                when 57 =>   tap_out <= delay_chain_57;
                when 58 =>   tap_out <= delay_chain_58;
                when 59 =>   tap_out <= delay_chain_59;
                when 60 =>   tap_out <= delay_chain_60;
                when 61 =>   tap_out <= delay_chain_61;
                when 62 =>   tap_out <= delay_chain_62;
                when 63 =>   tap_out <= delay_chain_63;
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
           delay_chain_28, delay_chain_29, delay_chain_30, delay_chain_31,
           delay_chain_32, delay_chain_33, delay_chain_34, delay_chain_35,
           delay_chain_36, delay_chain_37, delay_chain_38, delay_chain_39,
           delay_chain_40, delay_chain_41, delay_chain_42, delay_chain_43,
           delay_chain_44, delay_chain_45, delay_chain_46, delay_chain_47,
           delay_chain_48, delay_chain_49, delay_chain_50, delay_chain_51,
           delay_chain_52, delay_chain_53, delay_chain_54, delay_chain_55,
           delay_chain_56, delay_chain_57, delay_chain_58, delay_chain_59,
           delay_chain_60, delay_chain_61, delay_chain_62, delay_chain_63;

  end process prcs_AssignDelays;

--####################################################################
--#####                  CALCULATE oDelay                         #####
--####################################################################
  prcs_calc_odelay:process(C_dly, GSR_dly, RST_dly)
  variable odelay_count_var : integer :=0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable CALC_TAPDELAY : real := 0.0;
  begin
     if((GSR_dly = '1') or (FIRST_TIME))then
        odelay_count_var := ODELAY_VALUE; 
        CALC_TAPDELAY := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IODELAY_OFFSET ;
        oDelay        <= real(odelay_count_var) * CALC_TAPDELAY * BaseTime_var; 
        FIRST_TIME   := false;
     end if;

  end process prcs_calc_odelay;

--####################################################################
--#####                      OUTPUT  TAP                         #####
--####################################################################
  prcs_tapout:process(tap_out)
  begin
      DATAOUT_zd <= tap_out ;
  end process prcs_tapout;

--####################################################################
--#####                           OUTPUT                         #####
--####################################################################
  prcs_output:process(DATAOUT_zd)
  begin
      DATAOUT <= DATAOUT_zd ;
  end process prcs_output;


end IODELAY_V;

