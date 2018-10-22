-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       Dynamically Adjustable Input Delay Buffer
-- /___/   /\     Filename : IBUF_DLY_ADJ.vhd
-- \   \  /  \    Timestamp : Tue Apr 19 08:18:20 PST 2005
--  \___\/\___\
--
-- Revision:
--    04/19/05 - Initial version.
--    06/30/06 - CR 233887 -- Corrected generic ordering
--    08/08/07 - CR 439320 -- Simprim fix -- Added attributes SIM_DELAY0, ... SIM_DELAY16 to fix timing issues
--    09/11/07 - CR 447604 -- When S[2:0]=0, it should correlate to 1 tap
--    04/07/08 - CR 469973 -- Header Description fix
-- End Revision


----- CELL IBUF_DLY_ADJ -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IBUF_DLY_ADJ is

  generic(

      DELAY_OFFSET : string := "OFF";
      IOSTANDARD : string := "DEFAULT"
      );

  port(
      O      : out std_ulogic;

      I      : in  std_ulogic;
      S      : in  std_logic_vector (2 downto 0)
      );

end IBUF_DLY_ADJ;

architecture IBUF_DLY_ADJ_V OF IBUF_DLY_ADJ is

  constant SIM_TAPDELAY_VALUE : integer := 200;
  constant SPECTRUM_OFFSET_DELAY : time := 1600 ps;

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

  constant      MAX_S		: integer := 3;
  constant      MAX_TAP		: integer := 7;
  constant      MIN_TAP		: integer := 0;

  constant      MSB_S		: integer := MAX_S -1;
  constant      LSB_S		: integer := 0;

  constant	SYNC_PATH_DELAY	: time := 0 ps;


  signal	O_zd		: std_ulogic := 'X';
  signal	O_viol		: std_ulogic := 'X';

  signal	I_ipd		: std_ulogic := 'X';
  signal        S_ipd           : std_logic_vector(MSB_S downto LSB_S);

  signal	INITIAL_DELAY	: time  := 0 ps;
  signal	DELAY   	: time  := 0 ps;

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  I_ipd          	 <= I              	after 0 ps;
  S_ipd          	 <= S              	after 0 ps;

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
     if((DELAY_OFFSET /= "ON") and (DELAY_OFFSET /= "on") and 
        (DELAY_OFFSET /= "OFF") and (DELAY_OFFSET /= "off")) then
           GenericValueCheckMessage
           (  HeaderMsg  => " Attribute Syntax Warning ",
              GenericName => " DELAY_OFFSET ",
              EntityName => "/IBUF_DLY_ADJ",
              GenericValue => DELAY_OFFSET,
              Unit => "",
              ExpectedValueMsg => " The Legal values for this attribute are ",
              ExpectedGenericValue => " ON or  OFF ",
              TailMsg => "",
              MsgSeverity => failure 
           );
     end if; 

     if((DELAY_OFFSET = "ON") or (DELAY_OFFSET = "on")) then  
-- CR 447604
--        INITIAL_DELAY <= SPECTRUM_OFFSET_DELAY;
        INITIAL_DELAY <= SPECTRUM_OFFSET_DELAY + (SIM_TAPDELAY_VALUE * 1 ps);
     else
--        INITIAL_DELAY <=  0 ps;
        INITIAL_DELAY <=  SIM_TAPDELAY_VALUE * 1 ps;
     end if;
     wait;
  end process prcs_init;
--####################################################################
--#####                  CALCULATE DELAY                         #####
--####################################################################
  prcs_s:process(S_ipd)
  variable TapCount_var : integer := 0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable delay_var    : time    := 0 ps ;
  variable S_int_var    : integer := 0;
  begin
     S_int_var := SLV_TO_INT(S_ipd);

     if((S_int_var >= MIN_TAP) and (S_int_var <= MAX_TAP)) then
         Delay        <= S_int_var * SIM_TAPDELAY_VALUE * BaseTime_var + INITIAL_DELAY;
     end if;
  end process prcs_s;

--####################################################################
--#####                      DELAY INPUT                         #####
--####################################################################
  prcs_i:process(I_ipd)
  begin
      O_zd <= transport I_ipd after delay; 
  end process prcs_i;


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(O_zd)
  begin
      O <= O_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IBUF_DLY_ADJ_V;

