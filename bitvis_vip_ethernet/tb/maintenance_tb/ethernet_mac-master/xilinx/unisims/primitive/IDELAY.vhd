-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Delay Line
-- /___/   /\     Filename : IDELAY.vhd
-- \   \  /  \    Timestamp : Thu Mar 17 16:56:02 PST 2005
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    03/17/05 - Changed SIM_TAPDELAY_VALUE to 75 ps from 78 ps -- CR 204824 --FP
--    06/14/05 - Fixed VitalPathDelay constructs  -- CR 209786 --FP
--    08/08/05 - Made tap count to wrap around  -- CR 213995 --FP
--    07/18/06 - CR 234556 fix. Added SIM_DELAY_D --FP
--    12/29/06 - CR 430648 Simprim fix. For fixed/default, delay is annotated via sdf.
--    04/07/08 - CR 469973 -- Header Description fix
--    27/05/08 - CR 472154 Removed Vital GSR constructs
-- End Revision
----- CELL IDELAY -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IDELAY is

  generic(

      IOBDELAY_TYPE  : string := "DEFAULT";
      IOBDELAY_VALUE : integer := 0
      );

  port(
      O      : out std_ulogic;

      C      : in  std_ulogic;
      CE     : in  std_ulogic;
      I      : in  std_ulogic;
      INC    : in  std_ulogic;
      RST    : in  std_ulogic
      );

end IDELAY;

architecture IDELAY_V OF IDELAY is

  constant SIM_TAPDELAY_VALUE : integer := 75;

  ---------------------------------------------------------
  -- Function  str_2_int converts string to integer
  ---------------------------------------------------------
  function str_2_int(str: in string ) return integer is
  variable int : integer;
  variable val : integer := 0;
  variable neg_flg   : boolean := false;
  variable is_it_int : boolean := true;
  begin
    int := 0;
    val := 0;
    is_it_int := true;
    neg_flg   := false;

    for i in  1 to str'length loop
      case str(i) is
         when  '-'
           =>
             if(i = 1) then
                neg_flg := true;
                val := -1;
             end if;
         when  '1'
           =>  val := 1;
         when  '2'
           =>   val := 2;
         when  '3'
           =>   val := 3;
         when  '4'
           =>   val := 4;
         when  '5'
           =>   val := 5;
         when  '6'
           =>   val := 6;
         when  '7'
           =>   val := 7;
         when  '8'
           =>   val := 8;
         when  '9'
           =>   val := 9;
         when  '0'
           =>   val := 0;
         when others
           => is_it_int := false;
        end case;
        if(val /= -1) then
          int := int *10  + val;
        end if;
        val := 0;
    end loop;
    if(neg_flg) then
      int := int * (-1);
    end if;

    if(NOT is_it_int) then
      int := -9999;
    end if;
    return int;
  end;
-----------------------------------------------------------

  constant	SYNC_PATH_DELAY	: time := 0 ps;

  constant	MIN_TAP_COUNT	: integer := 0;
  constant	MAX_TAP_COUNT	: integer := 63;

  signal	C_ipd		: std_ulogic := 'X';
  signal	CE_ipd		: std_ulogic := 'X';
  signal	GSR_ipd		: std_ulogic := 'X';
  signal	I_ipd		: std_ulogic := 'X';
  signal	INC_ipd		: std_ulogic := 'X';
  signal	RST_ipd		: std_ulogic := 'X';

  signal	C_dly		: std_ulogic := 'X';
  signal	CE_dly		: std_ulogic := 'X';
  signal	GSR_dly		: std_ulogic := '0';
  signal	I_dly		: std_ulogic := 'X';
  signal	INC_dly		: std_ulogic := 'X';
  signal	RST_dly		: std_ulogic := 'X';

  signal	O_zd		: std_ulogic := 'X';
  signal	O_viol		: std_ulogic := 'X';

  signal	TapCount	: integer := 0;
  signal	IsTapDelay	: boolean := true; 
  signal	IsTapFixed	: boolean := false; 
  signal	IsTapDefault	: boolean := false; 
  signal	Delay		: time := 0 ps; 

begin

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  I_dly          	 <= I              	after 0 ps;
  INC_dly        	 <= INC            	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable TapCount_var   : integer := 0;
  variable IsTapDelay_var : boolean := true; 
  variable IsTapFixed_var : boolean := false; 
  variable IsTapDefault_var : boolean := false; 
  begin
--     if((IOBDELAY_VALUE = "OFF") or (IOBDELAY_VALUE = "off")) then
--        IsTapDelay_var := false;
--     elsif((IOBDELAY_VALUE = "ON") or (IOBDELAY_VALUE = "on")) then
--        IsTapDelay_var := false;
--     else
--       TapCount_var := str_2_int(IOBDELAY_VALUE); 
       TapCount_var := IOBDELAY_VALUE; 
       If((TapCount_var >= 0) and (TapCount_var <= 63)) then 
         IsTapDelay_var := true;

       else
          GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " IOBDELAY_VALUE ",
             EntityName => "/IOBDELAY_VALUE",
             GenericValue => IOBDELAY_VALUE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " OFF, 1, 2, ..., 62, 63 ",
             TailMsg => "",
             MsgSeverity => failure 
          );
        end if;
--     end if;

     if(IsTapDelay_var) then
        if((IOBDELAY_TYPE = "FIXED") or (IOBDELAY_TYPE = "fixed")) then
           IsTapFixed_var := true;
        elsif((IOBDELAY_TYPE = "VARIABLE") or (IOBDELAY_TYPE = "variable")) then
           IsTapFixed_var := false;
        elsif((IOBDELAY_TYPE = "DEFAULT") or (IOBDELAY_TYPE = "default")) then
           IsTapDefault_var := true;
        else
          GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " IOBDELAY_TYPE ",
             EntityName => "/IOBDELAY_TYPE",
             GenericValue => IOBDELAY_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " FIXED or VARIABLE ",
             TailMsg => "",
             MsgSeverity => failure 
          );
        end if; 
     end if; 

     IsTapDelay   <= IsTapDelay_var;
     IsTapFixed   <= IsTapFixed_var;
     IsTapDefault <= IsTapDefault_var;
     TapCount     <= TapCount_var;

     wait;
  end process prcs_init;
--####################################################################
--#####                  CALCULATE DELAY                         #####
--####################################################################
  prcs_refclk:process(C_dly, GSR_dly, RST_dly)
  variable TapCount_var : integer :=0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable delay_var    : time    := 0 ps ;
  begin
     if(IsTapDelay) then
       if((GSR_dly = '1') or (FIRST_TIME))then
          TapCount_var := TapCount; 
          Delay        <= TapCount_var * SIM_TAPDELAY_VALUE * BaseTime_var; 
          FIRST_TIME   := false;
       elsif(GSR_dly = '0') then
          if(rising_edge(C_dly)) then
             if(RST_dly = '1') then
               TapCount_var := TapCount; 
             elsif((RST_dly = '0') and (CE_dly = '1')) then
-- CR fix CR 213995
                  if(INC_dly = '1') then
                     if (TapCount_var < MAX_TAP_COUNT) then
                        TapCount_var := TapCount_var + 1;
                     else 
                        TapCount_var := MIN_TAP_COUNT;
                     end if;
                  elsif(INC_dly = '0') then
                     if (TapCount_var > MIN_TAP_COUNT) then
                         TapCount_var := TapCount_var - 1;
                     else
                         TapCount_var := MAX_TAP_COUNT;
                     end if;
                         
                  end if; -- INC_dly
             end if; -- RST_dly
             Delay <= TapCount_var *  SIM_TAPDELAY_VALUE * BaseTime_var;
          end if; -- C_dly
       end if; -- GSR_dly

     end if; -- IsTapDelay 
  end process prcs_refclk;


--####################################################################
--#####                      DELAY INPUT                         #####
--####################################################################
  prcs_i:process(I_dly)
  begin
     if(IsTapFixed) then
       O_zd <= transport I_dly after (TapCount *SIM_TAPDELAY_VALUE * 1 ps);
     else
        O_zd <= transport I_dly after delay;
     end if;
  end process prcs_i;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(O_zd)
  begin
      O <= O_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDELAY_V;

