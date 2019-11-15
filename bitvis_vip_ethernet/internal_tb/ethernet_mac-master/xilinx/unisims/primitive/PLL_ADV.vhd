-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/PLL_ADV.vhd,v 1.32.30.1 2013/05/03 21:24:00 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                 Phase Lock Loop Clock 
-- /___/   /\     Filename : PLL_ADV.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:19 PST 2004
--  \___\/\___\
-- Revision:
--     10/02/08 - Initial version
--     11/21/08 - Add wait on init_done to DRP process.
--    12/02/08 - Fix bug of Duty cycle calculation (CR498696)
--    12/04/08 - make clkfb_tst at least 1 ns wide (CR499318)
--    12/05/08 - change pll_res according to hardware spreadsheet (CR496137)
--    01/09/09 - make pll_res same for BANDWIDTH=HIGH and OPTIMIZED (CR496137)
--    02/02/09 - Add drp_init_done (CR506382)
--    02/10/09 - Change error to warning for phase check (CR507632)
--    02/11/09 - Change VCO_FREQ_MAX and MIN to 1441 and 399 to cover the rounded
--               error (CR507969)
--    05/13/09 - Use period_avg for clkvco_delay calculation (CR521120)
--    06/02/09 - Not check RST pulse at time 0 (CR523850)
--    06/11/09 - When calculate clk0_div1, set clk0_nocnt to 1 if CLKOUT0 as feedback (CR524704)
--    09/02/09 - Add SIM_DEVICE attribute (CR532327)
--    09/16/09 - Add DRP support for Spartan6 (CR532327)
--    10/08/09 - Change  CLKIN_FREQ MAX & MIN, CLKPFD_FREQ
--               MAX & MIN to parameter (CR535828)
--    10/14/09 - Add clkin_chk_t1 and clkin_chk_t2 to handle check (CR535662)
--    12/02/09 - not stop clkvco_lk when jitter (CR538717)
--   12/16/09 - Move deallocate statement before return statement(CR541730)
--    01/05/10 - Use real() for integer to real conversion (CR542934)
--    01/10/10 - Add VCO frequency check for CLKOUT0 feedback case (544278)
--    02/09/10 - Divide clk0 when CLKOUT0 as feedback (CR548329)
--             - Add global PLL_LOCKG support (CR547918)
--    05/07/10 - Use period_vco_half_rm1 to reduce jitter (CR558966)
--             - Support CLK_FEEDBACK=CLKOUT0 and CLKOUT0_PHASE set(CR559360)
--    03/08/11 - Keep 0.001 resolution for CLKIN period check (CR594003)
--    08/25/11 - Fix typo error for VIRTEX (CR621971)
--    02/13/12 - 639574 - correct clk to out delay with non 50/50 duty cycle clkin
--    03/07/12 - added vcoflag (CR 638088, CR 636493)
--    04/19/13 - 652888 - lock after reset
--   05/03/12 - jittery clock (CR 652401)
--   05/03/12 - incorrect period (CR 654951)
--   08/15/12 - 673328 - remove 1 ps jitter in clockout period.
--   04/26/13 - 708790, vcoflag fix
-- End Revision

----- CELL PLL_ADV -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library STD;
use STD.TEXTIO.all;


library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity PLL_ADV is
generic (

                BANDWIDTH : string := "OPTIMIZED";
                CLK_FEEDBACK : string := "CLKFBOUT";
                CLKFBOUT_DESKEW_ADJUST : string := "NONE";
                CLKFBOUT_MULT : integer := 1;
                CLKFBOUT_PHASE : real := 0.0;
                CLKIN1_PERIOD : real := 0.000;
                CLKIN2_PERIOD : real := 0.000;
                CLKOUT0_DESKEW_ADJUST : string := "NONE";
                CLKOUT0_DIVIDE : integer := 1;
                CLKOUT0_DUTY_CYCLE : real := 0.5;
                CLKOUT0_PHASE : real := 0.0;
                CLKOUT1_DESKEW_ADJUST : string := "NONE";
                CLKOUT1_DIVIDE : integer := 1;
                CLKOUT1_DUTY_CYCLE : real := 0.5;
                CLKOUT1_PHASE : real := 0.0;
                CLKOUT2_DESKEW_ADJUST : string := "NONE";
                CLKOUT2_DIVIDE : integer := 1;
                CLKOUT2_DUTY_CYCLE : real := 0.5;
                CLKOUT2_PHASE : real := 0.0;
                CLKOUT3_DESKEW_ADJUST : string := "NONE";
                CLKOUT3_DIVIDE : integer := 1;
                CLKOUT3_DUTY_CYCLE : real := 0.5;
                CLKOUT3_PHASE : real := 0.0;
                CLKOUT4_DESKEW_ADJUST : string := "NONE";
                CLKOUT4_DIVIDE : integer := 1;
                CLKOUT4_DUTY_CYCLE : real := 0.5;
                CLKOUT4_PHASE : real := 0.0;
                CLKOUT5_DESKEW_ADJUST : string := "NONE";
                CLKOUT5_DIVIDE : integer := 1;
                CLKOUT5_DUTY_CYCLE : real := 0.5;
                CLKOUT5_PHASE : real := 0.0;
                COMPENSATION : string := "SYSTEM_SYNCHRONOUS";
                DIVCLK_DIVIDE : integer := 1;
                EN_REL : boolean := FALSE;
                PLL_PMCD_MODE : boolean := FALSE;
                REF_JITTER : real := 0.100;
                RESET_ON_LOSS_OF_LOCK : boolean := FALSE;
                RST_DEASSERT_CLK : string := "CLKIN1";
                SIM_DEVICE : string := "VIRTEX5"

  );
port (
                CLKFBDCM : out std_ulogic := '0';
                CLKFBOUT : out std_ulogic := '0';
                CLKOUT0 : out std_ulogic := '0';
                CLKOUT1 : out std_ulogic := '0';
                CLKOUT2 : out std_ulogic := '0';
                CLKOUT3 : out std_ulogic := '0';
                CLKOUT4 : out std_ulogic := '0';
                CLKOUT5 : out std_ulogic := '0';
                CLKOUTDCM0 : out std_ulogic := '0';
                CLKOUTDCM1 : out std_ulogic := '0';
                CLKOUTDCM2 : out std_ulogic := '0';
                CLKOUTDCM3 : out std_ulogic := '0';
                CLKOUTDCM4 : out std_ulogic := '0';
                CLKOUTDCM5 : out std_ulogic := '0';
                DO : out std_logic_vector(15 downto 0);
                DRDY : out std_ulogic := '0';
                LOCKED : out std_ulogic := '0';
                CLKFBIN : in std_ulogic;
                CLKIN1 : in std_ulogic;
                CLKIN2 : in std_ulogic;
                CLKINSEL : in std_ulogic;
                DADDR : in std_logic_vector(4 downto 0);
                DCLK : in std_ulogic;
                DEN : in std_ulogic;
                DI : in std_logic_vector(15 downto 0);
                DWE : in std_ulogic;
                REL : in std_ulogic;
                RST : in std_ulogic
     );
end PLL_ADV;


-- Architecture body --

architecture PLL_ADV_V of PLL_ADV is

  ---------------------------------------------------------------------------
  -- Function SLV_TO_INT converts a std_logic_vector TO INTEGER
  ---------------------------------------------------------------------------
  function SLV_TO_INT(SLV: in std_logic_vector
                      ) return integer is

    variable int : integer;
  begin
    int := 0;
    for i in SLV'high downto SLV'low loop
      int := int * 2;
      if SLV(i) = '1' then
        int := int + 1;
      end if;
    end loop;
    return int;
  end;

  ---------------------------------------------------------------------------
  -- Function ADDR_IS_VALID checks for the validity of the argument. A FALSE
  -- is returned if any argument bit is other than a '0' or '1'.
  ---------------------------------------------------------------------------
  function ADDR_IS_VALID (
    SLV : in std_logic_vector
    ) return boolean is

    variable IS_VALID : boolean := TRUE;

  begin
    for I in SLV'high downto SLV'low loop
      if (SLV(I) /= '0' AND SLV(I) /= '1') then
        IS_VALID := FALSE;
      end if;
    end loop;
    return IS_VALID;
  end ADDR_IS_VALID;

  function real2int( real_in : in real) return integer is
    variable int_value : integer;
    variable int_value1 : integer;
    variable tmps : time := 1 ps;
    variable tmps1 : real;
    
  begin
    if (real_in < 1.00000 and real_in > -1.00000) then
        int_value1 := 0;
    else
      tmps := real_in * 1 ns;
      int_value := tmps / 1 ns;
      tmps1 := real (int_value);
      if ( tmps1 > real_in) then
        int_value1 := int_value - 1 ;
      else
        int_value1 := int_value;
      end if;
    end if;
    return int_value1;
  end real2int;

  
  procedure clkout_dly_cal (clkout_dly : out std_logic_vector(5 downto 0);
                          clkpm_sel : out std_logic_vector(2 downto 0);
                          clkdiv : in integer;
                          clk_ps : in real;
                          clk_ps_name : in string )
  is
    variable clk_dly_rl : real;
    variable clk_dly_rem : real;
    variable clk_dly_int : integer;
    variable clk_dly_int_rl : real;
    variable clkdiv_real : real;
    variable clkpm_sel_rl : real;
    variable clk_ps_rl : real;
    variable  Message : line;
  begin

     clkdiv_real := real(clkdiv);
     if (clk_ps < 0.0) then
        clk_dly_rl := (360.0 + clk_ps) * clkdiv_real / 360.0;
     else
        clk_dly_rl := clk_ps * clkdiv_real / 360.0;
     end if;
     clk_dly_int := real2int (clk_dly_rl);

     if (clk_dly_int > 63) then
        Write ( Message, string'(" Warning : Attribute "));
        Write ( Message, clk_ps_name );
        Write ( Message, string'(" of PLL_ADV is set to "));
        Write ( Message, clk_ps);
        Write ( Message, string'(". Required phase shifting can not be reached since it is over the maximum phase shifting ability of PLL_ADV"));
        Write ( Message, '.' & LF );
--        assert false report Message.all severity error;
        assert false report Message.all severity warning;
        DEALLOCATE (Message);
        clkout_dly := "111111";
     else
       clkout_dly := STD_LOGIC_VECTOR(TO_UNSIGNED(clk_dly_int, 6));
     end if;

     clk_dly_int_rl := real (clk_dly_int);
     clk_dly_rem := clk_dly_rl - clk_dly_int_rl;

    if (clk_dly_rem < 0.125) then
        clkpm_sel :=  "000";
        clkpm_sel_rl := 0.0;
    elsif (clk_dly_rem >=  0.125 and  clk_dly_rem < 0.25) then
        clkpm_sel(2 downto 0) :=  "001";
        clkpm_sel_rl := 1.0;
    elsif (clk_dly_rem >=  0.25 and clk_dly_rem < 0.375) then
        clkpm_sel :=  "010";
        clkpm_sel_rl := 2.0;
    elsif (clk_dly_rem >=  0.375 and clk_dly_rem < 0.5) then
        clkpm_sel :=  "011";
        clkpm_sel_rl := 3.0;
    elsif (clk_dly_rem >=  0.5 and clk_dly_rem < 0.625) then
        clkpm_sel :=  "100";
        clkpm_sel_rl := 4.0;
    elsif (clk_dly_rem >=  0.625 and clk_dly_rem < 0.75) then
        clkpm_sel :=  "101";
        clkpm_sel_rl := 5.0;
    elsif (clk_dly_rem >=  0.75 and clk_dly_rem < 0.875) then
        clkpm_sel :=  "110";
        clkpm_sel_rl := 6.0;
    elsif (clk_dly_rem >=  0.875 ) then
        clkpm_sel :=  "111";
        clkpm_sel_rl := 7.0;
    end if;

    if (clk_ps < 0.0) then
       clk_ps_rl := (clk_dly_int_rl + 0.125 * clkpm_sel_rl) * 360.0 / clkdiv_real - 360.0;
    else
       clk_ps_rl := (clk_dly_int_rl + 0.125 * clkpm_sel_rl) * 360.0 / clkdiv_real;
    end if;

    if (((clk_ps_rl- clk_ps) > 0.001) or ((clk_ps_rl- clk_ps) < -0.001)) then
        Write ( Message, string'(" Warning : Attribute "));
        Write ( Message, clk_ps_name );
        Write ( Message, string'(" of PLL_ADV is set to "));
        Write ( Message, clk_ps);
        Write ( Message, string'(". Real phase shifting is "));
        Write ( Message, clk_ps_rl);
        Write ( Message, string'(". Required phase shifting can not be reached"));
        Write ( Message, '.' & LF );
        assert false report Message.all severity warning;
        DEALLOCATE (Message);
    end if;
  end procedure clkout_dly_cal;

procedure clk_out_para_cal (clk_ht : out std_logic_vector(6 downto 0);
                            clk_lt : out std_logic_vector(6 downto 0);
                            clk_nocnt : out std_ulogic;
                            clk_edge : out std_ulogic;
                            CLKOUT_DIVIDE : in  integer;
                            CLKOUT_DUTY_CYCLE : in  real )
  is 
     variable tmp_value : real;
     variable tmp_value0 : real;
     variable tmp_value_l: real;
     variable tmp_value2 : real;
     variable tmp_value1 : integer;
     variable clk_lt_tmp : real;
     variable clk_ht_i : integer;
     variable clk_lt_i : integer;
     variable CLKOUT_DIVIDE_real : real;
     constant O_MAX_HT_LT_real : real := 64.0;
  begin
     CLKOUT_DIVIDE_real := real(CLKOUT_DIVIDE);
     tmp_value := CLKOUT_DIVIDE_real * CLKOUT_DUTY_CYCLE;
     tmp_value0 := tmp_value * 2.0;
     tmp_value1 := real2int(tmp_value0) mod 2;
     tmp_value2 := CLKOUT_DIVIDE_real - tmp_value;

     if ((tmp_value2) >= O_MAX_HT_LT_real) then
       clk_lt_tmp := 64.0;
       clk_lt := "1000000";
     else
       if (tmp_value2 < 1.0) then
           clk_lt := "0000001";
           clk_lt_tmp := 1.0;
       else
           if (tmp_value1 /= 0) then
             clk_lt_i := real2int(tmp_value2) + 1;
           else
             clk_lt_i := real2int(tmp_value2);
           end if;
           clk_lt := STD_LOGIC_VECTOR(TO_UNSIGNED(clk_lt_i, 7));
           clk_lt_tmp := real(clk_lt_i);
       end if;
     end if;

   tmp_value_l := CLKOUT_DIVIDE_real -  clk_lt_tmp;

   if ( tmp_value_l >= O_MAX_HT_LT_real) then
       clk_ht := "1000000";
   else
      clk_ht_i := real2int(tmp_value_l);
      clk_ht :=  STD_LOGIC_VECTOR(TO_UNSIGNED(clk_ht_i, 7));
   end if;

   if (CLKOUT_DIVIDE = 1) then
      clk_nocnt := '1';
   else
      clk_nocnt := '0';
   end if;

   if (tmp_value < 1.0) then
      clk_edge := '1';
   elsif (tmp_value1 /= 0) then
      clk_edge := '1';
   else
      clk_edge := '0';
   end if;

  end procedure clk_out_para_cal;

 procedure clkout_pm_cal ( clk_ht1 : out integer ;
                           clk_div : out integer;
                           clk_div1 : out integer;
                           clk_ht : in std_logic_vector(6 downto 0);
                           clk_lt : in std_logic_vector(6 downto 0);
                           clk_nocnt : in std_ulogic;
                           clk_edge : in std_ulogic )
  is 
     variable clk_div_tmp : integer;
  begin
    if (clk_nocnt = '1') then
        clk_div := 1;
        clk_div1 := 1;
        clk_ht1 := 1;
    else 
      if (clk_edge = '1') then
           clk_ht1 := 2 * SLV_TO_INT(clk_ht) + 1;
      else
           clk_ht1 :=  2 * SLV_TO_INT(clk_ht);
      end if;
       clk_div_tmp := SLV_TO_INT(clk_ht) + SLV_TO_INT(clk_lt);
       clk_div := clk_div_tmp;
       clk_div1 :=  2 * clk_div_tmp - 1;
    end if;

  end procedure clkout_pm_cal;

 procedure clkout_delay_para_drp ( clkout_dly : out std_logic_vector(5 downto 0);
                           clk_nocnt : out std_ulogic;
                           clk_edge : out std_ulogic;
                           di_in : in std_logic_vector(15 downto 0);
                           daddr_in : in std_logic_vector(4 downto 0);
                           di_str : string ( 1 to 16);
                           daddr_str : string ( 1 to 5))
  is
     variable  Message : line;
  begin
     clkout_dly := di_in(5 downto 0);
     clk_nocnt := di_in(6);
     clk_edge := di_in(7);
 end procedure clkout_delay_para_drp;
                           
procedure clkout_hl_para_drp ( clk_lt : out std_logic_vector(6 downto 0) ;
                               clk_ht : out std_logic_vector(6 downto 0) ;
                               clkpm_sel : out std_logic_vector(2 downto 0) ;
                           di_in : in std_logic_vector(15 downto 0);
                           daddr_in : in std_logic_vector(4 downto 0);
                           di_str : string ( 1 to 16);
                           daddr_str : string ( 1 to 5))
  is
     variable  Message : line;
  begin
     if (di_in(12) /= '1')  then
      Write ( Message, string'(" Error : PLL_ADV input DI(15 downto 0) is set to"));
      Write ( Message, di_str);
      Write ( Message, string'(" at address DADDR = "));
      Write ( Message, daddr_str );
      Write ( Message, string'(". The bit 12 need to be set to 1."));
      Write ( Message, '.' & LF );
      assert false report Message.all severity error;
      DEALLOCATE (Message);
     end if;
  
    if ( di_in(5 downto 0) = "000000") then
       clk_lt := "1000000";
    else
       clk_lt := ( '0' & di_in(5 downto 0));
    end if;
    if (  di_in(11 downto 6) = "000000") then
      clk_ht := "1000000";
    else
      clk_ht := ( '0' & di_in(11 downto 6));
    end if;
    clkpm_sel := di_in(15 downto 13);
end procedure clkout_hl_para_drp;

  function clkout_duty_chk (CLKOUT_DIVIDE : in integer;
                            CLKOUT_DUTY_CYCLE : in real;
                            CLKOUT_DUTY_CYCLE_N : in string)
                          return std_ulogic is
   constant O_MAX_HT_LT_real : real := 64.0;
   variable CLKOUT_DIVIDE_real : real;
   variable CLK_DUTY_CYCLE_MIN : real;
   variable CLK_DUTY_CYCLE_MIN_rnd : real;
   variable CLK_DUTY_CYCLE_MAX : real;
   variable CLK_DUTY_CYCLE_STEP : real;
   variable clk_duty_tmp_int : integer;
   variable  duty_cycle_valid : std_ulogic;
   variable tmp_duty_value : real;
   variable  tmp_j : real; 
   variable Message : line;
   variable step_round_tmp : integer;
   variable step_round_tmp1 : real;

  begin
   CLKOUT_DIVIDE_real := real(CLKOUT_DIVIDE);
   step_round_tmp := 1000 /CLKOUT_DIVIDE;
   step_round_tmp1 := real(step_round_tmp);
   if (CLKOUT_DIVIDE_real > O_MAX_HT_LT_real) then 
      CLK_DUTY_CYCLE_MIN := (CLKOUT_DIVIDE_real - O_MAX_HT_LT_real)/CLKOUT_DIVIDE_real;
      CLK_DUTY_CYCLE_MAX := (O_MAX_HT_LT_real + 0.5)/CLKOUT_DIVIDE_real;
      CLK_DUTY_CYCLE_MIN_rnd := CLK_DUTY_CYCLE_MIN;
   else  
      if (CLKOUT_DIVIDE = 1) then
          CLK_DUTY_CYCLE_MIN_rnd := 0.0;
          CLK_DUTY_CYCLE_MIN := 0.0;
      else
          CLK_DUTY_CYCLE_MIN_rnd := step_round_tmp1 / 1000.00;
          CLK_DUTY_CYCLE_MIN := 1.0 / CLKOUT_DIVIDE_real;
      end if;
      CLK_DUTY_CYCLE_MAX := 1.0;
   end if;

   if ((CLKOUT_DUTY_CYCLE > CLK_DUTY_CYCLE_MAX) or (CLKOUT_DUTY_CYCLE < CLK_DUTY_CYCLE_MIN_rnd)) then 
     Write ( Message, string'(" Attribute Syntax Warning : "));
     Write ( Message, CLKOUT_DUTY_CYCLE_N);
     Write ( Message, string'(" is set to "));
     Write ( Message, CLKOUT_DUTY_CYCLE);
     Write ( Message, string'(" and is not in the allowed range "));
     Write ( Message, CLK_DUTY_CYCLE_MIN);
     Write ( Message, string'("  to "));
     Write ( Message, CLK_DUTY_CYCLE_MAX);
     Write ( Message, '.' & LF );
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
     end if;

    CLK_DUTY_CYCLE_STEP := 0.5 / CLKOUT_DIVIDE_real;
    tmp_j := 0.0;
    duty_cycle_valid := '0';
    clk_duty_tmp_int := 0;
    for j in 0 to  (2 * CLKOUT_DIVIDE ) loop
      tmp_duty_value := CLK_DUTY_CYCLE_MIN + CLK_DUTY_CYCLE_STEP * tmp_j;
      if (abs(tmp_duty_value - CLKOUT_DUTY_CYCLE) < 0.001 and (tmp_duty_value <= CLK_DUTY_CYCLE_MAX)) then
          duty_cycle_valid := '1';
      end if;
      tmp_j := tmp_j + 1.0;
    end loop;

   if (duty_cycle_valid /= '1') then
    Write ( Message, string'(" Attribute Syntax Warning : "));
    Write ( Message, CLKOUT_DUTY_CYCLE_N);
    Write ( Message, string'(" =  "));
    Write ( Message, CLKOUT_DUTY_CYCLE);
    Write ( Message, string'(" which is  not an allowed value. Allowed value s are: "));
    Write ( Message,  LF );
    tmp_j := 0.0;
    for j in 0 to  (2 * CLKOUT_DIVIDE ) loop
      tmp_duty_value := CLK_DUTY_CYCLE_MIN + CLK_DUTY_CYCLE_STEP * tmp_j;
      if ( (tmp_duty_value <= CLK_DUTY_CYCLE_MAX) and (tmp_duty_value < 1.0)) then
       Write ( Message,  tmp_duty_value);
       Write ( Message,  LF );
      end if;
      tmp_j := tmp_j + 1.0;
    end loop;
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
  end if;
    return duty_cycle_valid;
  end function clkout_duty_chk;

-- Input/Output Pin signals

        constant VCOCLK_FREQ_MAX : real := 1440.0;
        constant VCOCLK_FREQ_MIN : real := 400.0;
        constant CLKIN_FREQ_MAX : real := 710.0;
        constant CLKIN_FREQ_MIN : real := 19.0;   
        constant CLKPFD_FREQ_MAX : real := 550.0;
        constant CLKPFD_FREQ_MIN : real := 19.0; 
        constant VCOCLK_FREQ_TARGET : real := 800.0;
        constant O_MAX_HT_LT : integer := 64;
        constant REF_CLK_JITTER_MAX : time := 1000 ps;
        constant REF_CLK_JITTER_SCALE : real := 0.1;
        constant MAX_FEEDBACK_DELAY : time := 10 ns;
        constant MAX_FEEDBACK_DELAY_SCALE : real := 1.0;

        constant  PLL_LOCK_TIME : integer := 7;
        constant OSC_P2 : time := 250 ps;

        signal   CLKIN1_ipd  :  std_ulogic;
        signal   CLKIN2_ipd  :  std_ulogic;
        signal   CLKFBIN_ipd  :  std_ulogic;
        signal   RST_ipd  :  std_ulogic;
        signal   REL_ipd  :  std_ulogic;
        signal   CLKINSEL_ipd  :  std_ulogic;
        signal   DADDR_ipd  :  std_logic_vector(4 downto 0);
        signal   DI_ipd  :  std_logic_vector(15 downto 0);
        signal   DWE_ipd  :  std_ulogic;
        signal   DEN_ipd  :  std_ulogic;
        signal   DCLK_ipd  :  std_ulogic;
--        signal   GSR          : std_ulogic := '0';
        signal   CLKOUT0_out  :  std_ulogic := '0';
        signal   CLKOUT1_out  :  std_ulogic := '0';
        signal   CLKOUT2_out  :  std_ulogic := '0';
        signal   CLKOUT3_out  :  std_ulogic := '0';
        signal   CLKOUT4_out  :  std_ulogic := '0';
        signal   CLKOUT5_out  :  std_ulogic := '0';
        signal   CLKFBOUT_out  :  std_ulogic := '0';
        signal   LOCKED_out  :  std_ulogic := '0';
        signal   do_out  :  std_logic_vector(15 downto 0);
        signal   DRDY_out  :  std_ulogic := '0';
        signal   CLKIN1_dly  :  std_ulogic;
        signal   CLKIN2_dly  :  std_ulogic;
        signal   CLKFBIN_dly  :  std_ulogic;
        signal   RST_dly  :  std_ulogic;
        signal   REL_dly  :  std_ulogic;
        signal   CLKINSEL_dly1  :  std_ulogic;
        signal   CLKINSEL_dly2  :  std_ulogic;
        signal   DADDR_dly  :  std_logic_vector(4 downto 0);
        signal   DI_dly  :  std_logic_vector(15 downto 0);
        signal   DWE_dly  :  std_ulogic;
        signal   DEN_dly  :  std_ulogic;
        signal   DCLK_dly  :  std_ulogic;

        signal sim_d : std_ulogic := '0';
        signal di_in : std_logic_vector (15 downto 0);
        signal dwe_in : std_ulogic := '0';
        signal den_in : std_ulogic := '0';
        signal dclk_in : std_ulogic := '0';
        signal rst_in : std_ulogic := '0';
        signal rst_input : std_ulogic := '0';
        signal rel_in : std_ulogic := '0';
        signal clkfb_in : std_ulogic := '0';
        signal clkin1_in : std_ulogic := '0';
        signal clkin1_in_dly : std_ulogic := '0';
        signal clkin2_in : std_ulogic := '0';
        signal clkinsel_in : std_ulogic := '0';
        signal clkinsel_tmp : std_ulogic := '0';
        signal daddr_in :  std_logic_vector(4 downto 0);
        signal daddr_in_lat :  integer := 0;
        signal drp_lock :  std_ulogic := '0';
        signal drp_lock1  :  std_ulogic := '0';
        type   drp_array is array (31 downto 0) of std_logic_vector(15 downto 0);
        signal dr_sram : drp_array;
        signal clk_osc :  std_ulogic := '0';
        signal clkin_p :  std_ulogic := '0';
        signal clkfb_p :  std_ulogic := '0';
        signal clkin_lost_val : integer := 0;
        signal clkfb_lost_val : integer := 0;
        signal clkin_stopped :  std_ulogic := '0';
        signal clkfb_stopped :  std_ulogic := '0';
        signal clkin_lost_cnt : integer := 0;
        signal clkfb_lost_cnt : integer := 0;
         
        signal clk0in :  std_ulogic := '0';
        signal clk1in :  std_ulogic := '0';
        signal clk2in :  std_ulogic := '0';
        signal clk3in :  std_ulogic := '0';
        signal clk4in :  std_ulogic := '0';
        signal clk5in :  std_ulogic := '0';
        signal clkfbm1in :  std_ulogic := '0';
        signal clk0_out :  std_ulogic := '0';
        signal clk1_out :  std_ulogic := '0';
        signal clk2_out :  std_ulogic := '0';
        signal clk3_out :  std_ulogic := '0';
        signal clk4_out :  std_ulogic := '0';
        signal clk5_out :  std_ulogic := '0';
        signal clkfb_out :  std_ulogic := '0';
        signal clkfbm1_out :  std_ulogic := '0';
        signal clkout_en :  std_ulogic := '0';
        signal clkout_en1 :  std_ulogic := '0';
        signal clkout_en0 :  std_ulogic := '0';
        signal clkout_en0_tmp :  std_ulogic := '0';
        signal clkout_cnt : integer := 0;
        signal clkin_cnt : integer := 0;
        signal clkin_lock_cnt : integer := 0;
        signal clkout_en_time : integer := PLL_LOCK_TIME + 2;
        signal locked_en_time : integer := 0;
        signal lock_cnt_max : integer := 0;
        signal clkvco_lk :  std_ulogic := '0';
        signal clkvco_lk_rst :  std_ulogic := '0';
        signal clkvco_free :  std_ulogic := '0';
        signal clkvco :  std_ulogic := '0';
        signal clkfb_mult_tl : integer;
        signal fbclk_tmp :  std_ulogic := '0';
        signal clkfb_src :  integer;

        signal rst_in1 :  std_ulogic := '0';
        signal rst_unlock :  std_ulogic := '0';
        signal rst_on_loss :  std_ulogic := '0';
        signal rst_edge : time := 0 ps;
        signal rst_ht : time := 0 ps;
        signal fb_delay_found :  std_ulogic := '0';
        signal fb_delay_found_tmp :  std_ulogic := '0';
        signal clkfb_tst :  std_ulogic := '0';
        constant fb_delay_max : time := MAX_FEEDBACK_DELAY * MAX_FEEDBACK_DELAY_SCALE;
        signal fb_delay : time := 0 ps;
        signal clkvco_delay : time := 0 ps;
        signal val_tmp : time := 0 ps;
        signal clkin_edge : time := 0 ps;
        signal delay_edge : time := 0 ps;

        type   real_array_usr is array (4 downto 0) of time;
        signal clkin_period : real_array_usr := (others => 0.0 ns);
        signal period_vco : time := 0.000 ns;
        signal period_vco_rm : integer := 0;
        signal period_vco_cmp_cnt : integer := 0;
        signal clkvco_tm_cnt : integer := 0;
        signal period_vco_cmp_flag : integer := 0;
        signal period_vco1 : time := 0.000 ns;
        signal period_vco2 : time := 0.000 ns;
        signal period_vco3 : time := 0.000 ns;
        signal period_vco4 : time := 0.000 ns;
        signal period_vco5 : time := 0.000 ns;
        signal period_vco6 : time := 0.000 ns;
        signal period_vco7 : time := 0.000 ns;
        signal period_vco_half : time := 0.000 ns;
        signal period_vco_half1 : time := 0.000 ns;
        signal period_vco_half_rm : time := 0.000 ns;
        signal period_vco_half_rm1 : time := 0.000 ns;
        signal period_vco_half_rm2 : time := 0.000 ns;
        constant period_vco_max : time := 1 ns * 1000 / VCOCLK_FREQ_MIN;
        constant period_vco_min : time := 1 ns * 1000 / VCOCLK_FREQ_MAX;
        constant period_vco_target : time := 1 ns * 1000 / VCOCLK_FREQ_TARGET;
        constant period_vco_target_half : time := 1 ns * 500 / VCOCLK_FREQ_TARGET;
        signal period_fb : time := 0.000 ns;
        signal period_avg : time := 0.000 ns;

        signal clkvco_freq_init_chk : real := 0.0;
        signal md_product : integer := CLKFBOUT_MULT * DIVCLK_DIVIDE;
        signal m_product : integer := CLKFBOUT_MULT;
        signal m_product2 : integer := CLKFBOUT_MULT / 2;
        signal drp_init_done : integer := 0;

        signal pll_locked_delay : time := 0 ps;
        signal clkin_dly_t : time := 0 ps;
        signal clkfb_dly_t : time := 0 ps;
        signal clkpll : std_ulogic := '0';
        signal clkpll_dly : std_ulogic := '0';
        signal clkfb_in_dly : std_ulogic := '0';
        signal pll_unlock : std_ulogic := '0';
        signal pll_locked_tm : std_ulogic := '0';
        signal pll_locked_tmp1 : std_ulogic := '0';
        signal pll_locked_tmp2 : std_ulogic := '0';
        signal lock_period : std_ulogic := '0';
        signal pll_lock_tm: std_ulogic := '0';
        signal unlock_recover : std_ulogic := '0';
        signal clkpll_jitter_unlock : std_ulogic := '0';
        signal clkin_jit : time := 0 ps;
        constant ref_jitter_max_tmp : time := REF_CLK_JITTER_MAX;
        
        signal clka1_out : std_ulogic := '0';
        signal clkb1_out : std_ulogic := '0';
        signal clka1d2_out : std_ulogic := '0';
        signal clka1d4_out : std_ulogic := '0';
        signal clka1d8_out : std_ulogic := '0';
        signal clkdiv_rel_rst : std_ulogic := '0';
        signal qrel_o_reg1 : std_ulogic := '0';
        signal qrel_o_reg2 : std_ulogic := '0';
        signal qrel_o_reg3 : std_ulogic := '0';
        signal rel_o_mux_sel : std_ulogic := '0';
        signal pmcd_mode : std_ulogic := '0';
        signal rel_rst_o : std_ulogic := '0';
        signal rel_o_mux_clk : std_ulogic := '0';
        signal rel_o_mux_clk_tmp : std_ulogic := '0';
        signal clka1_in : std_ulogic := '0';
        signal clkb1_in : std_ulogic := '0';
        signal clkout0_out_out : std_ulogic := '0';
        signal clkout1_out_out : std_ulogic := '0';
        signal clkout2_out_out : std_ulogic := '0';
        signal clkout3_out_out : std_ulogic := '0';
        signal clkout4_out_out : std_ulogic := '0';
        signal clkout5_out_out : std_ulogic := '0';
        signal clkfbout_out_out : std_ulogic := '0';
        signal clk0ps_en : std_ulogic := '0';
        signal clk1ps_en : std_ulogic := '0';
        signal clk2ps_en : std_ulogic := '0';
        signal clk3ps_en : std_ulogic := '0';
        signal clk4ps_en : std_ulogic := '0';
        signal clk5ps_en : std_ulogic := '0';
        signal clkfbm1ps_en : std_ulogic := '0';
        signal clkout_mux : std_logic_vector (7 downto 0) := X"00";
        signal clk0pm_sel : integer := 0;
        signal clk1pm_sel : integer := 0;
        signal clk2pm_sel : integer := 0;
        signal clk3pm_sel : integer := 0; 
        signal clk4pm_sel : integer := 0;
        signal clk5pm_sel : integer := 0;
        signal clkfbm1pm_sel : integer := 0;
        signal clkfbmpm_sel : integer := 0;
        signal clkfbm2pm_sel : integer := 0;
        signal clkfbm1pm_rl : real := 0.0;
        signal clkfbm2pm_rl : real := 0.0;
        signal clk0_edge  : std_ulogic := '0';
        signal clk1_edge  : std_ulogic := '0';
        signal clk2_edge  : std_ulogic := '0';
        signal clk3_edge  : std_ulogic := '0';
        signal clk4_edge  : std_ulogic := '0';
        signal clk5_edge  : std_ulogic := '0';
        signal clkfbm1_edge  : std_ulogic := '0';
        signal clkfbm2_edge  : std_ulogic := '0';
        signal clkind_edge  : std_ulogic := '0';
        signal clk0_nocnt  : std_ulogic := '0';
        signal clk1_nocnt  : std_ulogic := '0';
        signal clk2_nocnt  : std_ulogic := '0';
        signal clk3_nocnt  : std_ulogic := '0';
        signal clk4_nocnt  : std_ulogic := '0';
        signal clk5_nocnt  : std_ulogic := '0';
        signal clkfbm1_nocnt  : std_ulogic := '0';
        signal clkfbm2_nocnt  : std_ulogic := '0';
        signal clkind_nocnt  : std_ulogic := '0';
        signal clk0_dly_cnt : integer := 0;
        signal clk1_dly_cnt : integer := 0;
        signal clk2_dly_cnt : integer := 0;
        signal clk3_dly_cnt : integer := 0;
        signal clk4_dly_cnt : integer := 0;
        signal clk5_dly_cnt : integer := 0;
        signal clkfbm1_dly_cnt : integer := 0;
        signal clkfbm2_dly_cnt : integer := 0;
        signal clk0_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk1_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk2_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk3_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk4_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk5_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm1_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm2_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk0_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk1_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk2_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk3_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk4_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk5_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm1_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm2_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk0_dlyi : std_logic_vector (5 downto 0);
        signal clk1_dlyi : std_logic_vector (5 downto 0);
        signal clk2_dlyi : std_logic_vector (5 downto 0);
        signal clk3_dlyi : std_logic_vector (5 downto 0);
        signal clk4_dlyi : std_logic_vector (5 downto 0);
        signal clk5_dlyi : std_logic_vector (5 downto 0);
        signal clkfbm1_dlyi : std_logic_vector (5 downto 0);
        signal clkfbm2_dlyi : std_logic_vector (5 downto 0);
        signal clkout0_dly : integer := 0;
        signal clkout1_dly : integer := 0;
        signal clkout2_dly : integer := 0;
        signal clkout3_dly : integer := 0;
        signal clkout4_dly : integer := 0;
        signal clkout5_dly : integer := 0;
        signal clkfbm1_dly : integer := 0;
        signal clkfbm2_dly : integer := 0;
        signal clkfbm_dly : integer := 0;
        signal clkind_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clkind_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk0_ht1 : integer := 0;
        signal clk1_ht1 : integer := 0;
        signal clk2_ht1 : integer := 0;
        signal clk3_ht1 : integer := 0;
        signal clk4_ht1 : integer := 0;
        signal clk5_ht1 : integer := 0;
        signal clkfbm1_ht1 : integer := 0;
        signal clkfbm2_ht1 : integer := 0;
        signal clk0_cnt : integer := 0;
        signal clk1_cnt : integer := 0;
        signal clk2_cnt : integer := 0;
        signal clk3_cnt : integer := 0;
        signal clk4_cnt : integer := 0;
        signal clk5_cnt : integer := 0;
        signal clkfbm1_cnt : integer := 0;
        signal clkfbm2_cnt : integer := 0;
        signal clk0_div : integer := 0;
        signal clk1_div : integer := 0;
        signal clk2_div : integer := 0;
        signal clk3_div : integer := 0;
        signal clk4_div : integer := 0;
        signal clk5_div : integer := 0;
        signal clkfbm1_div : integer := 1;
        signal clkfbm2_div : integer := 1;
        signal clk0_div1 : integer := 0;
        signal clk1_div1 : integer := 0;
        signal clk2_div1 : integer := 0;
        signal clk3_div1 : integer := 0;
        signal clk4_div1 : integer := 0;
        signal clk5_div1 : integer := 0;
        signal clkfbm1_div1 : integer := 0;
        signal clkfbm2_div1 : integer := 0;
        signal clkfbm_div1 : integer := 0;
        signal clkfbm_div : integer := 0;
        signal clkind_div : integer := 0;
        signal init_done : integer := 0;

begin

        CLKOUT0 <=  clkout0_out_out;
        CLKOUT1 <=  clkout1_out_out;
        CLKOUT2 <=  clkout2_out_out;
        CLKOUT3 <=   clkout3_out_out;
        CLKOUT4 <=   clkout4_out_out;
        CLKOUT5 <=   clkout5_out_out;
        CLKFBOUT <=   clkfbout_out_out;
        CLKOUTDCM0 <=  clkout0_out_out;
        CLKOUTDCM1 <=  clkout1_out_out;
        CLKOUTDCM2 <=  clkout2_out_out;
        CLKOUTDCM3 <=  clkout3_out_out;
        CLKOUTDCM4 <=  clkout4_out_out;
        CLKOUTDCM5 <=  clkout5_out_out;
        CLKFBDCM <=   clkfbout_out_out;
        unisim.VCOMPONENTS.PLL_LOCKG <= '0' when (locked_out = '0') else 'H';

        DO <=   do_out(15 downto 0) after 100 ps;
        DRDY <=   DRDY_out after 100 ps;
        LOCKED <= locked_out after 100 ps;
        clkin1_in <= CLKIN1;
        clkin2_in <= CLKIN2;
        clkinsel_in <= CLKINSEL;
        clkfb_in <= CLKFBIN;
        rst_input <= RST;
        rel_in <= REL;
        clkin1_in_dly <= CLKIN1;
        daddr_in(4 downto 0) <= DADDR(4 downto 0);
        di_in(15 downto 0) <= DI(15 downto 0);
        dwe_in <= DWE;
        den_in <= DEN;
        dclk_in <= DCLK;

        INIPROC : process
            variable Message : line;
            variable con_line : line;
            variable tmpvalue : real;
            variable chk_ok : std_ulogic;
            variable tmp_string : string(1 to 18);
            variable skipspace : character;
            variable CLK_DUTY_CYCLE_MIN : real;
            variable CLK_DUTY_CYCLE_MAX : real;
            variable  CLK_DUTY_CYCLE_STEP : real;
            variable O_MAX_HT_LT_real : real;
            variable duty_cycle_valid : std_ulogic;
            variable CLKOUT0_DIVIDE_real : real;
            variable CLKOUT1_DIVIDE_real : real;
            variable CLKOUT2_DIVIDE_real : real;
            variable CLKOUT3_DIVIDE_real : real;
            variable CLKOUT4_DIVIDE_real : real;
            variable CLKOUT5_DIVIDE_real : real;
            variable tmp_j : real;
            variable tmp_duty_value : real;
            variable clk_ht_i : std_logic_vector(5 downto 0);
            variable clk_lt_i : std_logic_vector(5 downto 0);
            variable clk_nocnt_i : std_ulogic;
            variable clk_edge_i : std_ulogic;
            variable clkfb_src_tmp : integer;
            variable clkfb_mult_tl_tmp : integer;
            variable clkin_chk_t1 : real;
            variable clkin_chk_t1_tmp1 : real;
            variable clkin_chk_t1_tmp2 : real;
            variable clkin_chk_t1_tmpi : time;
            variable clkin_chk_t1_tmpi1 : integer;
            variable clkin_chk_t2 : real;
            variable clkin_chk_t2_tmp1 : real;
            variable clkin_chk_t2_tmp2 : real;
            variable clkin_chk_t2_tmpi : time;
            variable clkin_chk_t2_tmpi1 : integer;
            
        begin
           if (SIM_DEVICE = "SPARTAN6" or SIM_DEVICE = "spartan6") then
              sim_d <= '1';
           elsif (SIM_DEVICE = "VIRTEX5" or SIM_DEVICE = "virtex5") then
              sim_d <= '0';
           else
              sim_d <= '0';
             assert FALSE report "Attribute Syntax Error : SIM_DEVICE is not VIRTEX5 or SPARTAN6." severity error;
           end if;

           if((BANDWIDTH /= "HIGH") and (BANDWIDTH /= "high") and
                 (BANDWIDTH /= "LOW") and (BANDWIDTH /= "low") and
                 (BANDWIDTH /= "OPTIMIZED") and (BANDWIDTH /= "optimized")) then
             assert FALSE report "Attribute Syntax Error : BANDWIDTH  is not HIGH, LOW, OPTIMIZED." severity error;
            end if;

           if((COMPENSATION /= "INTERNAL") and (COMPENSATION /= "internal") and
                 (COMPENSATION /= "EXTERNAL") and (COMPENSATION /= "external") and
                 (COMPENSATION /= "SYSTEM_SYNCHRONOUS") and (COMPENSATION /= "system_synchronous") and
                 (COMPENSATION /= "SOURCE_SYNCHRONOUS") and (COMPENSATION /= "source_synchronous") and
                 (COMPENSATION /= "DCM2PLL") and (COMPENSATION /= "dcm2pll") and
                 (COMPENSATION /= "PLL2DCM") and (COMPENSATION /= "pll2dcm")) then 
             assert FALSE report "Attribute Syntax Error : COMPENSATION  is not INTERNAL, EXTERNAL, SYSTEM_SYNCHRONOUS, SOURCE_SYNCHRONOUS , DCM2PLL, PLL2DCM." severity error;
            end if;

           if((BANDWIDTH /= "HIGH") and (BANDWIDTH /= "high") and
                 (BANDWIDTH /= "LOW") and (BANDWIDTH /= "low") and
                 (BANDWIDTH /= "OPTIMIZED") and (BANDWIDTH /= "optimized")) then
             assert FALSE report "Attribute Syntax Error : BANDWIDTH  is not HIGH, LOW, OPTIMIZED." severity error;
            end if;

           if (CLK_FEEDBACK = "CLKFBOUT" or CLK_FEEDBACK = "clkfbout") then
                clkfb_src_tmp := 0;
                clkfb_mult_tl_tmp := CLKFBOUT_MULT;
                clkfb_mult_tl <= clkfb_mult_tl_tmp;
                clkfb_src <= clkfb_src_tmp;
           elsif (CLK_FEEDBACK = "CLKOUT0" or CLK_FEEDBACK = "clkout0") then
                clkfb_src_tmp := 1;
                clkfb_mult_tl_tmp := CLKFBOUT_MULT * CLKOUT0_DIVIDE;
                clkfb_mult_tl <= clkfb_mult_tl_tmp;
                clkfb_src <= clkfb_src_tmp;
           else
             assert FALSE report "Attribute Syntax Error : CLK_FEEDBACK  is not CLKFBOUT or CLKOUT0.";
           end if;


       if ((CLKOUT0_DESKEW_ADJUST /= "NONE") and (CLKOUT0_DESKEW_ADJUST /= "none")
            and (CLKOUT0_DESKEW_ADJUST /= "PPC") and (CLKOUT0_DESKEW_ADJUST /= "ppc")
            ) then 
          assert FALSE report "Error : CLKOUT0_DESKEW_ADJUST is not NONE or PPC." severity error;
       end if;  

       if ((CLKOUT1_DESKEW_ADJUST /= "NONE") and (CLKOUT1_DESKEW_ADJUST /= "none")
            and (CLKOUT1_DESKEW_ADJUST /= "PPC") and (CLKOUT1_DESKEW_ADJUST /= "ppc")
            ) then
          assert FALSE report "Error : CLKOUT1_DESKEW_ADJUST is not NONE or PPC." severity error;
       end if;  

       if ((CLKOUT2_DESKEW_ADJUST /= "NONE") and (CLKOUT2_DESKEW_ADJUST /= "none")
            and (CLKOUT2_DESKEW_ADJUST /= "PPC") and (CLKOUT2_DESKEW_ADJUST /= "ppc")
            ) then
          assert FALSE report "Error : CLKOUT2_DESKEW_ADJUST is not NONE or PPC." severity error;
       end if;  

       if ((CLKOUT3_DESKEW_ADJUST /= "NONE") and (CLKOUT3_DESKEW_ADJUST /= "none")
            and (CLKOUT3_DESKEW_ADJUST /= "PPC") and (CLKOUT3_DESKEW_ADJUST /= "ppc")
            ) then
          assert FALSE report "Error : CLKOUT3_DESKEW_ADJUST is not NONE or PPC." severity error;
       end if;  

       if ((CLKOUT4_DESKEW_ADJUST /= "NONE") and (CLKOUT4_DESKEW_ADJUST /= "none")
            and (CLKOUT4_DESKEW_ADJUST /= "PPC") and (CLKOUT4_DESKEW_ADJUST /= "ppc")
            ) then
          assert FALSE report "Error : CLKOUT4_DESKEW_ADJUST is not NONE or PPC." severity error;
       end if;  

       if ((CLKOUT5_DESKEW_ADJUST /= "NONE") and (CLKOUT5_DESKEW_ADJUST /= "none")
            and (CLKOUT5_DESKEW_ADJUST /= "PPC") and (CLKOUT5_DESKEW_ADJUST /= "ppc")
            ) then
          assert FALSE report "Error : CLKOUT5_DESKEW_ADJUST is not NONE or PPC." severity error;
       end if;  

       if ((CLKFBOUT_DESKEW_ADJUST /= "NONE") and (CLKFBOUT_DESKEW_ADJUST /= "none")
            and (CLKFBOUT_DESKEW_ADJUST /= "PPC") and (CLKFBOUT_DESKEW_ADJUST /= "ppc")
            ) then
          assert FALSE report "Error : CLKFBOUT_DESKEW_ADJUST is not NONE or PPC." severity error;
       end if;  

       case PLL_PMCD_MODE is
          when TRUE => pmcd_mode <= '1';
          when FALSE => pmcd_mode <= '0';
           when others  =>  assert FALSE report "Attribute Syntax Error : PLL_PMCD_MODE is not TRUE or FALSE." severity error;
       end case;

       case CLKOUT0_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT0_DIVIDE is not in range 1...128." severity error;
       end case;

        if ((CLKOUT0_PHASE < -360.0) or (CLKOUT0_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT0_PHASE is not in range -360.0 to 360.0" severity error;
        elsif (pmcd_mode = '1' and CLKOUT0_PHASE /= 0.0) then
           assert FALSE report "Attribute Syntax Error : CLKOUT0_PHASE need set to 0.0 when attribute PLL_PMCD_MODE is set to TRUE." severity error; 
        end if;

        if ((CLKOUT0_DUTY_CYCLE < 0.0) or (CLKOUT0_DUTY_CYCLE > 1.0)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT0_DUTY_CYCLE is not real in range 0.0 to 1.0 pecentage."severity error;
        elsif (pmcd_mode = '1' and CLKOUT0_DUTY_CYCLE /= 0.5) then
             assert FALSE report "Attribute Syntax Error : CLKOUT0_DUTY_CYCLE need set to 0.5 when attribute PLL_PMCD_MODE is set to TRUE." severity error;
        end if;

       case CLKOUT1_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT1_DIVIDE is not in range 1...128." severity error;
       end case;

        if ((CLKOUT1_PHASE < -360.0) or (CLKOUT1_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT1_PHASE is not in range -360.0 to 360.0" severity error;
        elsif (pmcd_mode = '1' and CLKOUT1_PHASE /= 0.0) then
           assert FALSE report "Attribute Syntax Error : CLKOUT1_PHASE need set to 0.0 when attribute PLL_PMCD_MODE is set to TRUE." severity error; 
        end if;

        if ((CLKOUT1_DUTY_CYCLE < 0.0) or (CLKOUT1_DUTY_CYCLE > 1.0)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT1_DUTY_CYCLE is not real in range 0.0 to 1.0 pecentage."severity error;
        elsif (pmcd_mode = '1' and CLKOUT1_DUTY_CYCLE /= 0.5) then
             assert FALSE report "Attribute Syntax Error : CLKOUT1_DUTY_CYCLE need set to 0.5 when attribute PLL_PMCD_MODE is set to TRUE." severity error;
        end if;

       case CLKOUT2_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT2_DIVIDE is not in range 1...128." severity error;
       end case;

        if ((CLKOUT2_PHASE < -360.0) or (CLKOUT2_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT2_PHASE is not in range -360.0 to 360.0" severity error;
        elsif (pmcd_mode = '1' and CLKOUT2_PHASE /= 0.0) then
           assert FALSE report "Attribute Syntax Error : CLKOUT2_PHASE need set to 0.0 when attribute PLL_PMCD_MODE is set to TRUE." severity error; 
        end if;

        if ((CLKOUT2_DUTY_CYCLE < 0.0) or (CLKOUT2_DUTY_CYCLE > 1.0)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT2_DUTY_CYCLE is not real in range 0.0 to 1.0 pecentage."severity error;
        elsif (pmcd_mode = '1' and CLKOUT2_DUTY_CYCLE /= 0.5) then
             assert FALSE report "Attribute Syntax Error : CLKOUT2_DUTY_CYCLE need set to 0.5 when attribute PLL_PMCD_MODE is set to TRUE." severity error;
        end if;


       case CLKOUT3_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT3_DIVIDE is not in range 1...128." severity error;
       end case;

        if ((CLKOUT3_PHASE < -360.0) or (CLKOUT3_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT3_PHASE is not in range -360.0 to 360.0" severity error;
        elsif (pmcd_mode = '1' and CLKOUT3_PHASE /= 0.0) then
           assert FALSE report "Attribute Syntax Error : CLKOUT3_PHASE need set to 0.0 when attribute PLL_PMCD_MODE is set to TRUE." severity error; 
        end if;

        if ((CLKOUT3_DUTY_CYCLE < 0.0) or (CLKOUT3_DUTY_CYCLE > 1.0)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT3_DUTY_CYCLE is not real in range 0.0 to 1.0 pecentage."severity error;
        elsif (pmcd_mode = '1' and CLKOUT3_DUTY_CYCLE /= 0.5) then
             assert FALSE report "Attribute Syntax Error : CLKOUT3_DUTY_CYCLE need set to 0.5 when attribute PLL_PMCD_MODE is set to TRUE." severity error;
        end if;


       case CLKOUT4_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT4_DIVIDE is not in range 1...128." severity error;
       end case;

        if ((CLKOUT4_PHASE < -360.0) or (CLKOUT4_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT4_PHASE is not in range -360.0 to 360.0" severity error;
        end if;

        if ((CLKOUT4_DUTY_CYCLE < 0.0) or (CLKOUT4_DUTY_CYCLE > 1.0)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT4_DUTY_CYCLE is not real in range 0.0 to 1.0 pecentage."severity error;
        end if;

       case CLKOUT5_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT5_DIVIDE is not in range 1...128." severity error;
       end case;

        if ((CLKOUT5_PHASE < -360.0) or (CLKOUT5_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT5_PHASE is not in range 360.0 to 360.0" severity error;
        end if;

        if ((CLKOUT5_DUTY_CYCLE < 0.0) or (CLKOUT5_DUTY_CYCLE > 1.0)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT5_DUTY_CYCLE is not real in range 0.0 to 1.0 pecentage."severity error;
        end if;


       case CLKFBOUT_MULT is
           when   1 to 74 =>  NULL;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKFBOUT_MULT is not in range 1...74." severity error;
       end case;

          if (clkfb_src = 1) then
             if (CLKFBOUT_PHASE > 0.001 or CLKFBOUT_PHASE < -0.001) then
              assert FALSE report "Attribute Syntax Error : The Attribute CLKFBOUT_PHASE should be set to 0.0 when attribute CLKFB_FEEDBACK set to CLKOUT0." severity error;
             end if;
        else
             if ( CLKFBOUT_PHASE < -360.0 or CLKFBOUT_PHASE > 360.0 ) then
             assert FALSE report "Attribute Syntax Error : CLKFBOUT_PHASE is not in range -360.0 to 360.0" severity error;
             elsif (pmcd_mode = '1' and CLKFBOUT_PHASE /= 0.0) then
           assert FALSE report "Attribute Syntax Error : CLKFBOUT_PHASE need set to 0.0 when attribute PLL_PMCD_MODE is set to TRUE." severity error; 
             end if;
       end if;

       case DIVCLK_DIVIDE is
       when    1  to 52 => NULL;

           when others  =>  assert FALSE report "Attribute Syntax Error : DIVCLK_DIVIDE is not in range 1...52." severity error;
       end case;

           if ((REF_JITTER < 0.0) or (REF_JITTER > 0.999)) then
             assert FALSE report "Attribute Syntax Error : REF_JITTER is not in range 0.0 ... 1.0." severity error;
           end if;
           
           clkin_chk_t1_tmp1 := 1000.0 / CLKIN_FREQ_MIN;
           clkin_chk_t1_tmp2 := 1000.0 * clkin_chk_t1_tmp1;
           clkin_chk_t1_tmpi := clkin_chk_t1_tmp2 * 1 ps;
           clkin_chk_t1_tmpi1 := clkin_chk_t1_tmpi / 1 ps;
           clkin_chk_t1 := real(clkin_chk_t1_tmpi1) / 1000.0;
 
           clkin_chk_t2_tmp1 := 1000.0 / CLKIN_FREQ_MAX;
           clkin_chk_t2_tmp2 := 1000.0 * clkin_chk_t2_tmp1;
           clkin_chk_t2_tmpi := clkin_chk_t2_tmp2 * 1 ps;
           clkin_chk_t2_tmpi1 := clkin_chk_t2_tmpi / 1 ps;
           clkin_chk_t2 := real(clkin_chk_t2_tmpi1) / 1000.0;
           
          if (((CLKIN1_PERIOD < clkin_chk_t2) or (CLKIN1_PERIOD > clkin_chk_t1)) and (pmcd_mode = '0') and (CLKINSEL = '1')) then
        Write ( Message, string'(" Attribute Syntax Error : The attribute CLKIN1_PERIOD is set to "));
        Write ( Message, CLKIN1_PERIOD);
        Write ( Message, string'(" ns and out the allowed range "));
        Write ( Message, clkin_chk_t2);
        Write ( Message, string'(" ns to "));
        Write ( Message, clkin_chk_t1);
        Write ( Message, string'(" ns" ));
        Write ( Message, '.' & LF );
        assert false report Message.all severity error;
        DEALLOCATE (Message);
          end if;

          if (((CLKIN2_PERIOD < clkin_chk_t2) or (CLKIN2_PERIOD > clkin_chk_t1)) and (pmcd_mode = '0') and (CLKINSEL = '0')) then
        Write ( Message, string'(" Attribute Syntax Error : The attribute CLKIN2_PERIOD is set to "));
        Write ( Message, CLKIN2_PERIOD);
        Write ( Message, string'(" ns and out the allowed range "));
        Write ( Message, clkin_chk_t2);
        Write ( Message, string'(" ns to ")); 
        Write ( Message, clkin_chk_t1);
        Write ( Message, string'(" ns"));
        Write ( Message, '.' & LF );
        assert false report Message.all severity error; 
        DEALLOCATE (Message);
          end if;

       case RESET_ON_LOSS_OF_LOCK is
           when FALSE   =>  rst_on_loss <= '0';
--           when TRUE    =>  rst_on_loss <= '1';
           when others  =>  assert FALSE report " Attribute Syntax Error : generic RESET_ON_LOSS_OF_LOCK must be set to FALSE for PLL_ADV to function correctly. Please correct the setting for the attribute and re-run the simulation." severity error;
       end case;

   write (con_line, O_MAX_HT_LT);
   write (con_line, string'(".0 "));
   write (con_line, CLKOUT0_DIVIDE);
   write (con_line, string'(".0 "));
   write (con_line, CLKOUT1_DIVIDE);
   write (con_line, string'(".0 "));
   write (con_line, CLKOUT2_DIVIDE);
   write (con_line, string'(".0 "));
   write (con_line, CLKOUT3_DIVIDE);
   write (con_line, string'(".0 "));
   write (con_line, CLKOUT4_DIVIDE);
   write (con_line, string'(".0 "));
   write (con_line, CLKOUT5_DIVIDE);
   write (con_line, string'(".0 "));
   read (con_line, tmpvalue);
   O_MAX_HT_LT_real := tmpvalue;
   read (con_line, skipspace);
   read (con_line, tmpvalue);
   CLKOUT0_DIVIDE_real := tmpvalue;
   read (con_line, skipspace);
   read (con_line, tmpvalue);
   CLKOUT1_DIVIDE_real := tmpvalue;
   read (con_line, skipspace);
   read (con_line, tmpvalue);
   CLKOUT2_DIVIDE_real := tmpvalue;
   read (con_line, skipspace);
   read (con_line, tmpvalue);
   CLKOUT3_DIVIDE_real := tmpvalue;
   read (con_line, skipspace);
   read (con_line, tmpvalue);
   CLKOUT4_DIVIDE_real := tmpvalue;
   read (con_line, skipspace);
   read (con_line, tmpvalue);
   CLKOUT5_DIVIDE_real := tmpvalue;
   DEALLOCATE (con_line);

    chk_ok := clkout_duty_chk (CLKOUT0_DIVIDE, CLKOUT0_DUTY_CYCLE, "CLKOUT0_DUTY_CYCLE");
    chk_ok := clkout_duty_chk (CLKOUT1_DIVIDE, CLKOUT1_DUTY_CYCLE, "CLKOUT1_DUTY_CYCLE");
    chk_ok := clkout_duty_chk (CLKOUT2_DIVIDE, CLKOUT2_DUTY_CYCLE, "CLKOUT2_DUTY_CYCLE");
    chk_ok := clkout_duty_chk (CLKOUT3_DIVIDE, CLKOUT3_DUTY_CYCLE, "CLKOUT3_DUTY_CYCLE");
    chk_ok := clkout_duty_chk (CLKOUT4_DIVIDE, CLKOUT4_DUTY_CYCLE, "CLKOUT4_DUTY_CYCLE");
    chk_ok := clkout_duty_chk (CLKOUT5_DIVIDE, CLKOUT5_DUTY_CYCLE, "CLKOUT5_DUTY_CYCLE");

   locked_en_time <= clkfb_mult_tl_tmp * DIVCLK_DIVIDE +  clkout_en_time + 2;
   lock_cnt_max <= clkfb_mult_tl_tmp * DIVCLK_DIVIDE +  clkout_en_time + 10 + CLKFBOUT_MULT;
   init_done <= 1;

--------PMCD --------------

    if (RST_DEASSERT_CLK = "CLKIN1") then
         rel_o_mux_sel <= '1';
    elsif (RST_DEASSERT_CLK = "CLKFBIN") then
         rel_o_mux_sel <= '0';
    else
     assert false report "Attribute Syntax Error : The attribute RST_DEASSERT_CLK on PLL_ADV should be CLKIN1 or CLKFBIN." severity error;
     end if;

        case EN_REL is
          when FALSE => clkdiv_rel_rst <= '0';
          when TRUE => clkdiv_rel_rst <= '1';
          when others   => assert false report "Attribute Syntax Error : The attribute EN_REL on PLL_ADV should be TRUE or FALSE." severity error;
        end case;

     wait;
  end process INIPROC;


--
-- PMCD function
--

-- *** Clocks MUX
--   rel_o_mux_clk_tmp <= clkin1_in when rel_o_mux_sel = '1' else clkfb_in;
   rel_o_mux_clk_tmp <= clkin1_in_dly when rel_o_mux_sel = '1' else clkfb_in;
   rel_o_mux_clk <= rel_o_mux_clk_tmp when (pmcd_mode = '1') else '0';
   clka1_in <= clkin1_in when (pmcd_mode = '1') else '0';
   clkb1_in <= clkfb_in when (pmcd_mode = '1')  else '0';

--*** Rel and Rst
    rel_rst_P : process(rel_o_mux_clk, rst_input)
    begin
      if (rst_input = '1') then
         qrel_o_reg1 <= '1';
         qrel_o_reg2 <= '1';
      else
         if (rising_edge(rel_o_mux_clk)) then
            qrel_o_reg1 <= '0';
         end if;

         if (falling_edge(rel_o_mux_clk)) then
            qrel_o_reg2 <= qrel_o_reg1;
          end if;
      end if;
   end process;

    qrel_o_reg3_P : process ( rel_in, rst_input)
    begin
      if (rst_input = '1') then
          qrel_o_reg3 <= '1';
      elsif (rising_edge(rel_in)) then
            qrel_o_reg3 <= '0';
      end if;
    end process;

    rel_rst_o <= (qrel_o_reg3 or qrel_o_reg1) when clkdiv_rel_rst = '1' else qrel_o_reg1;

--*** CLKA
    clka1_out_P : process (clka1_in, qrel_o_reg2)
    begin
        if (qrel_o_reg2 = '1') then
            clka1_out <= '0';
        elsif (qrel_o_reg2 = '0') then
            clka1_out <= clka1_in;
        end if;
    end process;

---** CLKB
    clkb1_out_P : process (clkb1_in, qrel_o_reg2)
    begin
        if (qrel_o_reg2 = '1') then
            clkb1_out <= '0';
        elsif (qrel_o_reg2 = '0') then
            clkb1_out <= clkb1_in;
        end if;
    end process;

--*** Clock divider
    clka1d2_out_P : process(clka1_in, rel_rst_o) 
    begin
        if (rel_rst_o = '1') then
            clka1d2_out <= '0';
        elsif (rising_edge(clka1_in)) then
            clka1d2_out <= not clka1d2_out;
       end if;
    end process;

    clka1d4_out_P : process (clka1d2_out, rel_rst_o) 
    begin
        if (rel_rst_o = '1') then
            clka1d4_out <= '0';
        elsif (rising_edge(clka1d2_out)) then
            clka1d4_out <= not clka1d4_out;
       end if;
    end process;

    clka1d8_out_P : process (clka1d4_out, rel_rst_o)
     begin
        if (rel_rst_o = '1') then
            clka1d8_out <= '0';
        elsif (rising_edge(clka1d4_out)) then
            clka1d8_out <= not clka1d8_out;
        end if;
    end process;

          clkout5_out_out <=  '0' when (pmcd_mode = '1') else clkout5_out;
          clkout4_out_out <= '0' when (pmcd_mode = '1') else clkout4_out;
          clkout3_out_out <= clka1_out  when (pmcd_mode = '1') else clkout3_out;
          clkout2_out_out <= clka1d2_out when (pmcd_mode = '1') else clkout2_out;
          clkout1_out_out <=  clka1d4_out when (pmcd_mode = '1') else  clkout1_out;
          clkout0_out_out <= clka1d8_out when (pmcd_mode = '1') else clkout0_out;
          clkfbout_out_out <=  clkb1_out when (pmcd_mode = '1') else clkfb_out;

--
-- PLL  function start
--  

    clkinsel_tmp <= clkinsel_in after 1 ps;

    clkinsel_p : process 
          variable period_clkin : real;
          variable clkvco_freq_init_chk : real;
          variable Message : line;
          variable tmpreal1 : real;
          variable tmpreal2 : real;
          variable tmpva1 : integer;
          variable tmpva1r : real;

    begin
      if (NOW > 1 ps  and  rst_in = '0' and (clkinsel_tmp = '0' or clkinsel_tmp = '1')) then
          assert false report
            "Input Error : PLL input clock can only be switched when RST=1.  CLKINSEL is changed when RST low, should be changed at RST high." 
          severity error;
      end if;

      if (NOW = 0 ps) then
         wait for 1 ps;
      end if;

      if ( clkinsel_in='1') then
         period_clkin :=  CLKIN1_PERIOD;
      else
         period_clkin := CLKIN2_PERIOD;
      end if;
      tmpva1 := CLKFBOUT_MULT * CLKOUT0_DIVIDE;
      tmpva1r := real(tmpva1); 
      tmpreal1 := real(CLKFBOUT_MULT);
      tmpreal2 := real(DIVCLK_DIVIDE);
      if (clkfb_src = 1) then
      clkvco_freq_init_chk :=  (tmpva1r / ( period_clkin * tmpreal2)) * 1000.0;
      else
      clkvco_freq_init_chk :=  (tmpreal1 / ( period_clkin * tmpreal2)) * 1000.0;
      end if;
      
      if ((clkvco_freq_init_chk > VCOCLK_FREQ_MAX) or (clkvco_freq_init_chk < VCOCLK_FREQ_MIN)) then
         Write ( Message, string'(" Attribute Syntax Error : The calculation of VCO frequency="));
         Write ( Message, clkvco_freq_init_chk);
         Write ( Message, string'(" Mhz. This exceeds the permitted VCO frequency range of "));
         Write ( Message, VCOCLK_FREQ_MIN);
          Write ( Message, string'(" MHz to "));
          Write ( Message, VCOCLK_FREQ_MAX);
          if (clkfb_src = 1) then
          Write ( Message, string'(" MHz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT * CLKOUT0_DIVIDE / (DIVCLK_DIVIDE * CLKIN_PERIOD)."));
          else
          Write ( Message, string'(" MHz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT / (DIVCLK_DIVIDE * CLKIN_PERIOD)."));
          end if;
         Write ( Message, string'(" Please adjust the attributes to the permitted VCO frequency range."));
          assert false report Message.all severity error;
              DEALLOCATE (Message);
      end if;   

     wait on clkinsel_in;
     end process;

   clkpll <= clkin1_in when clkinsel_in = '1' else clkin2_in;
   
   RST_SYNC_P : process (clkpll, rst_input)
   begin
     if (rst_input = '1') then
        rst_in1 <= '1';
     elsif (rising_edge (clkpll)) then
        rst_in1 <= rst_input;
     end if;
   end process;

   rst_in <= rst_in1 or rst_unlock;

   RST_ON_LOSS_P : process (pll_unlock)
   begin
     if (rising_edge(pll_unlock)) then
      if (rst_on_loss = '1' and locked_out = '1') then
          rst_unlock <= '1', '0' after 10 ns;
      end if;
     end if;
   end process;

   RST_PW_P : process (rst_input)
      variable rst_edge : time := 0 ps;
      variable rst_ht : time := 0 ps;
   begin
      if (rising_edge(rst_input)) then
         rst_edge := NOW;
      elsif ((falling_edge(rst_input)) and (rst_edge > 1 ps)) then
         rst_ht := NOW - rst_edge;
         if (rst_ht < 10 ns and rst_ht > 0 ps) then
            assert false report
               "Input Error : RST must be asserted at least for 10 ns."
            severity error;
         end if;
      end if;
   end process;
     
---- 
----  DRP port read and write
----

   do_out <= dr_sram(daddr_in_lat);

  DRP_PROC : process
    variable address : integer;
    variable valid_daddr : boolean := false;
    variable Message : line;
    variable di_str : string (1 to 16);
    variable daddr_str : string ( 1 to 5);
    variable first_time : boolean := true;
    variable clk_ht : std_logic_vector (6 downto 0);
    variable tmp_ht : std_logic_vector (6 downto 0);
    variable clk_lt : std_logic_vector (6 downto 0);
    variable tmp_lt : std_logic_vector (6 downto 0);
    variable clk_nocnt : std_ulogic;
    variable clk_edge : std_ulogic;
    variable clkout_dly : std_logic_vector (5 downto 0);
    variable clkpm_sel : std_logic_vector (2 downto 0);
    variable tmpx : std_logic_vector (7 downto 0);
    variable clk0_hti : std_logic_vector (6 downto 0);
    variable clk1_hti : std_logic_vector (6 downto 0);
    variable clk2_hti : std_logic_vector (6 downto 0);
    variable clk3_hti : std_logic_vector (6 downto 0);
    variable clk4_hti : std_logic_vector (6 downto 0);
    variable clk5_hti : std_logic_vector (6 downto 0);
    variable clkfbm1_hti : std_logic_vector (6 downto 0);
    variable clkfbm2_hti : std_logic_vector (6 downto 0);
    variable clk0_lti : std_logic_vector (6 downto 0);
    variable clk1_lti : std_logic_vector (6 downto 0);
    variable clk2_lti : std_logic_vector (6 downto 0);
    variable clk3_lti : std_logic_vector (6 downto 0);
    variable clk4_lti : std_logic_vector (6 downto 0);
    variable clk5_lti : std_logic_vector (6 downto 0);
    variable clkfbm1_lti : std_logic_vector (6 downto 0);
    variable clkfbm2_lti : std_logic_vector (6 downto 0);
    variable clk0_nocnti : std_ulogic;
    variable clk1_nocnti : std_ulogic;
    variable clk2_nocnti : std_ulogic;
    variable clk3_nocnti : std_ulogic;
    variable clk4_nocnti : std_ulogic;
    variable clk5_nocnti : std_ulogic;
    variable clkfbm1_nocnti : std_ulogic;
    variable clkfbm2_nocnti : std_ulogic;
    variable clk0_edgei  : std_ulogic;
    variable clk1_edgei  : std_ulogic;
    variable clk2_edgei  : std_ulogic;
    variable clk3_edgei  : std_ulogic;
    variable clk4_edgei  : std_ulogic;
    variable clk5_edgei  : std_ulogic;
    variable clkfbm1_edgei  : std_ulogic;
    variable clkfbm2_edgei  : std_ulogic;
    variable clkout0_dlyi : std_logic_vector (5 downto 0);
    variable clkout1_dlyi : std_logic_vector (5 downto 0);
    variable clkout2_dlyi : std_logic_vector (5 downto 0);
    variable clkout3_dlyi : std_logic_vector (5 downto 0);
    variable clkout4_dlyi : std_logic_vector (5 downto 0);
    variable clkout5_dlyi : std_logic_vector (5 downto 0);
    variable clkfbm1_dlyi : std_logic_vector (5 downto 0);
    variable clkfbm2_dlyi : std_logic_vector (5 downto 0);
    variable clk0pm_seli : std_logic_vector (2 downto 0);
    variable clk1pm_seli : std_logic_vector (2 downto 0);
    variable clk2pm_seli : std_logic_vector (2 downto 0);
    variable clk3pm_seli : std_logic_vector (2 downto 0);
    variable clk4pm_seli : std_logic_vector (2 downto 0);
    variable clk5pm_seli : std_logic_vector (2 downto 0);
    variable clkfbm1pm_seli : std_logic_vector (2 downto 0);
    variable clkfbm2pm_seli : std_logic_vector (2 downto 0);
    variable clk_ht1 : integer;
    variable clk_div : integer;
    variable  clk_div1 : integer;
    variable clkind_hti : std_logic_vector (6 downto 0);
    variable clkind_lti : std_logic_vector (6 downto 0);
    variable clkind_nocnti : std_ulogic;
    variable clkind_edgei : std_ulogic;
    variable pll_cp : std_logic_vector (3 downto 0);
    variable pll_res : std_logic_vector (3 downto 0);
    variable pll_lfhf : std_logic_vector (1 downto 0);
    variable pll_cpres : std_logic_vector (1 downto 0) := "01";
    variable tmpadd : std_logic_vector (4 downto 0);
    variable clkout0_ps_tmp : real;
  begin

   if (first_time = true and init_done = 1) then
   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKOUT0_DIVIDE, CLKOUT0_DUTY_CYCLE);
   clk0_hti := clk_ht;
   clk0_lti := clk_lt;
   clk0_nocnti := clk_nocnt;
   clk0_edgei := clk_edge;
   clk0_ht <= clk0_hti;
   clk0_lt <= clk0_lti;
   clk0_nocnt <= clk0_nocnti;
   clk0_edge <= clk0_edgei;

   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKOUT1_DIVIDE, CLKOUT1_DUTY_CYCLE);
   clk1_hti := clk_ht;
   clk1_lti := clk_lt;
   clk1_nocnti := clk_nocnt;
   clk1_edgei := clk_edge;
   clk1_ht <= clk1_hti;
   clk1_lt <= clk1_lti;
   clk1_nocnt <= clk1_nocnti;
   clk1_edge <= clk1_edgei;

   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKOUT2_DIVIDE, CLKOUT2_DUTY_CYCLE);
   clk2_hti := clk_ht;
   clk2_lti := clk_lt;
   clk2_nocnti := clk_nocnt;
   clk2_edgei := clk_edge;
   clk2_ht <= clk2_hti;
   clk2_lt <= clk2_lti;
   clk2_nocnt <= clk2_nocnti;
   clk2_edge <= clk2_edgei;

   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKOUT3_DIVIDE, CLKOUT3_DUTY_CYCLE);
   clk3_hti := clk_ht;
   clk3_lti := clk_lt;
   clk3_nocnti := clk_nocnt;
   clk3_edgei := clk_edge;
   clk3_ht <= clk3_hti;
   clk3_lt <= clk3_lti;
   clk3_nocnt <= clk3_nocnti;
   clk3_edge <= clk3_edgei;

   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKOUT4_DIVIDE, CLKOUT4_DUTY_CYCLE);
   clk4_hti := clk_ht;
   clk4_lti := clk_lt;
   clk4_nocnti := clk_nocnt;
   clk4_edgei := clk_edge;
   clk4_ht <= clk4_hti;
   clk4_lt <= clk4_lti;
   clk4_nocnt <= clk4_nocnti;
   clk4_edge <= clk4_edgei;

   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKOUT5_DIVIDE, CLKOUT5_DUTY_CYCLE);
   clk5_hti := clk_ht;
   clk5_lti := clk_lt;
   clk5_nocnti := clk_nocnt;
   clk5_edgei := clk_edge;
   clk5_ht <= clk5_hti;
   clk5_lt <= clk5_lti;
   clk5_nocnt <= clk5_nocnti;
   clk5_edge <= clk5_edgei;

   if (clkfb_src = 1) then
   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKFBOUT_MULT, 0.50);
   clkfbm2_hti := clk_ht;
   clkfbm2_lti := clk_lt;
   clkfbm2_nocnti := clk_nocnt;
   clkfbm2_edgei := clk_edge;
   clkfbm2_ht <= clkfbm2_hti;
   clkfbm2_lt <= clkfbm2_lti;
   clkfbm2_nocnt <= clkfbm2_nocnti;
   clkfbm2_edge <= clkfbm2_edgei;
   clkout0_ps_tmp := CLKOUT0_PHASE;
   clkfbm1_ht <= "0000000";
   clkfbm1_lt <= "0000000";
   clkfbm1_nocnt <= '1';
   clkfbm1_edge <= '0';
  else
   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKFBOUT_MULT, 0.50);
   clkfbm1_hti := clk_ht;
   clkfbm1_lti := clk_lt;
   clkfbm1_nocnti := clk_nocnt;
   clkfbm1_edgei := clk_edge;
   clkfbm1_ht <= clkfbm1_hti;
   clkfbm1_lt <= clkfbm1_lti;
   clkfbm1_nocnt <= clkfbm1_nocnti;
   clkfbm1_edge <= clkfbm1_edgei;
   clkout0_ps_tmp := CLKOUT0_PHASE;
   clkfbm2_ht <= "0000000";
   clkfbm2_lt <= "0000000";
   clkfbm2_nocnt <= '1';
   clkfbm2_edge <= '0';
   end if;

   clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, DIVCLK_DIVIDE, 0.50);
   clkind_hti := clk_ht;
   clkind_lti := clk_lt;
   clkind_nocnti := clk_nocnt;
   clkind_edgei := clk_edge;
   clkind_ht <= clkind_hti;
   clkind_lt <= clkind_lti;

   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk0_hti, clk0_lti, clk0_nocnti, clk0_edgei);
   clk0_ht1 <= clk_ht1;
   clk0_div <= clk_div;
   clk0_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk1_hti, clk1_lti, clk1_nocnti, clk1_edgei);
   clk1_ht1 <= clk_ht1;
   clk1_div <= clk_div;
   clk1_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk2_hti, clk2_lti, clk2_nocnti, clk2_edgei);
   clk2_ht1 <= clk_ht1;
   clk2_div <= clk_div;
   clk2_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk3_hti, clk3_lti, clk3_nocnti, clk3_edgei);
   clk3_ht1 <= clk_ht1;
   clk3_div <= clk_div;
   clk3_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk4_hti, clk4_lti, clk4_nocnti, clk4_edgei);
   clk4_ht1 <= clk_ht1;
   clk4_div <= clk_div;
   clk4_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk5_hti, clk5_lti, clk5_nocnti, clk5_edgei);
   clk5_ht1 <= clk_ht1;
   clk5_div <= clk_div;
   clk5_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm1_hti, clkfbm1_lti, clkfbm1_nocnti, clkfbm1_edgei);
   clkfbm1_ht1 <= clk_ht1;
   clkfbm1_div <= clk_div;
   clkfbm1_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm2_hti, clkfbm2_lti, clkfbm2_nocnti, clkfbm2_edgei);
   clkfbm2_ht1 <= clk_ht1;
   clkfbm2_div <= clk_div;
   clkfbm2_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkind_hti, clkind_lti, clkind_nocnti, '0');
   clkind_div <= clk_div;

   clkout_dly_cal (clkout_dly, clkpm_sel, CLKOUT0_DIVIDE, clkout0_ps_tmp, "CLKOUT0_PHASE");
   clkout0_dly <= SLV_TO_INT(clkout_dly);
   clk0pm_sel <= SLV_TO_INT(clkpm_sel);
   clkout0_dlyi := clkout_dly;
   clk0pm_seli := clkpm_sel;
   
   clkout_dly_cal (clkout_dly, clkpm_sel, CLKOUT1_DIVIDE, CLKOUT1_PHASE, "CLKOUT1_PHASE");
   clkout1_dly <= SLV_TO_INT(clkout_dly);
   clk1pm_sel <= SLV_TO_INT(clkpm_sel);
   clkout1_dlyi := clkout_dly;
   clk1pm_seli := clkpm_sel;

   clkout_dly_cal (clkout_dly, clkpm_sel, CLKOUT2_DIVIDE, CLKOUT2_PHASE, "CLKOUT2_PHASE");
   clkout2_dly <= SLV_TO_INT(clkout_dly);
   clk2pm_sel <= SLV_TO_INT(clkpm_sel);
   clkout2_dlyi := clkout_dly;
   clk2pm_seli := clkpm_sel;
   clkout_dly_cal (clkout_dly, clkpm_sel, CLKOUT3_DIVIDE, CLKOUT3_PHASE, "CLKOUT3_PHASE");
   clkout3_dly <= SLV_TO_INT(clkout_dly);
   clk3pm_sel <= SLV_TO_INT(clkpm_sel);
   clkout3_dlyi := clkout_dly;
   clk3pm_seli := clkpm_sel;
   clkout_dly_cal (clkout_dly, clkpm_sel, CLKOUT4_DIVIDE, CLKOUT4_PHASE, "CLKOUT4_PHASE");
   clkout4_dly <= SLV_TO_INT(clkout_dly);
   clk4pm_sel <= SLV_TO_INT(clkpm_sel);
   clkout4_dlyi := clkout_dly;
   clk4pm_seli := clkpm_sel;
   clkout_dly_cal (clkout_dly, clkpm_sel, CLKOUT5_DIVIDE, CLKOUT5_PHASE, "CLKOUT5_PHASE");
   clkout5_dly <= SLV_TO_INT(clkout_dly);
   clk5pm_sel <= SLV_TO_INT(clkpm_sel);
   clkout5_dlyi := clkout_dly;
   clk5pm_seli := clkpm_sel;
   if (clkfb_src = 1) then
   clkfbm1_dlyi := "000000";
   clkfbm1pm_seli := "000";
   clkfbm2_dlyi := "000000";
   clkfbm2pm_seli := "000";
   clkfbm1_dly <= 0;
   clkfbm1pm_sel <= 0;
   clkfbm2_dly <= 0;
   clkfbm2pm_sel <= 0;
   else
   clkout_dly_cal (clkout_dly, clkpm_sel, CLKFBOUT_MULT, CLKFBOUT_PHASE, "CLKFBOUT_PHASE");
   clkfbm1_dly <= SLV_TO_INT(clkout_dly);
   clkfbm1pm_sel <= SLV_TO_INT(clkpm_sel);
   clkfbm1_dlyi := clkout_dly;
   clkfbm1pm_seli := clkpm_sel;
   clkfbm2_dlyi := "000000";
   clkfbm2pm_seli := "000";
   clkfbm2_dly <= 0;
   clkfbm2pm_sel <= 0;
   end if;


   if (clkfb_src = 1 and clkfb_mult_tl > 64 ) then
      Write ( Message, string'(" Attribute Syntax Error :  The Attributes CLKFBOUT_MULT and CLKOUT0_DIVIDE are set to "));
      Write ( Message, CLKFBOUT_MULT);
      Write ( Message, string'(" and "));
      Write ( Message, CLKOUT0_DIVIDE);
      Write ( Message, string'(".  The product of CLKFBOUT_MULT and CLKOUT0_DIVIDE is ") );
      Write ( Message, clkfb_mult_tl);
      Write ( Message, string'(", which is over the 64 limit"));
      Write ( Message, '.' & LF );
      assert false report Message.all severity error;
      DEALLOCATE (Message);
   end if;
  
   pll_lfhf := "11";
 
   case clkfb_mult_tl is
when 1 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1011";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1101"; end if;
when 2 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0101"; pll_res := "1111";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1110"; end if;
when 3 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1100"; pll_res := "1111";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0110"; end if;
when 4 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1111";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1010"; end if;
when 5 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "0111";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1100"; end if;
when 6 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1101";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1100"; end if;
when 7 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "0011";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1100"; end if;
when 8 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "0101";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0010"; end if;
when 9 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1001";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0010"; end if;
when 10 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1110"; pll_res := "1110";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 11 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1110";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 12 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1110";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 13 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "0001";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 14 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "0001";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 15 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "0001";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 16 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1110"; pll_res := "0110";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 17 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1110"; pll_res := "0110";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 18 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "0110";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "0100"; end if;
when 19 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1110"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 20 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1110"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 21 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 22 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 23 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 24 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 25 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 26 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 27 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1101"; pll_res := "1100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 28 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1101"; pll_res := "1100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 29 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1101"; pll_res := "1100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 30 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1110"; pll_res := "1100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0001"; pll_res := "1000"; end if;
when 31 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1101"; pll_res := "1100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "0100"; end if;
when 32 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1100"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "0100"; end if;
when 33 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "1111"; pll_res := "1010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "0100"; end if;
when 34 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0111"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "0100"; end if;
when 35 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0111"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "0100"; end if;
when 36 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0111"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "0100"; end if;
when 37 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0110"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "0100"; end if;
when 38 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0110"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 39 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0110"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 40 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0110"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 41 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0110"; pll_res := "0010";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 42 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0100"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 43 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0100"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 44 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0100"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 45 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 46 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 47 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 48 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 49 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 50 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 51 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 52 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 53 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 54 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 55 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 56 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0011"; pll_res := "0100";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 57 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 58 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 59 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 60 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 61 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 62 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 63 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when 64 => if (BANDWIDTH = "HIGH" or BANDWIDTH = "OPTIMIZED") then pll_cp := "0010"; pll_res := "1000";
  elsif (BANDWIDTH = "LOW") then pll_cp := "0010"; pll_res := "1000"; end if;
when others => pll_cp := "0000"; pll_res := "0000";
  end case;

  if (sim_d = '1') then
   dr_sram(5) <= (clkout0_dlyi(5) & 'X' & clkout0_dlyi(4) & 'X' & clkout0_dlyi(2) & clkout0_dlyi(3) & clkout0_dlyi(1) & clkout0_dlyi(0) & "XXXXXXXX");
   dr_sram(6) <= (clk1_lti(4) & clk1_lti(5) & clk1_lti(3) & clk1_nocnti & clk1_lti(1) &  clk1_lti(2) & clkout1_dlyi(5) & 'X' & clkout1_dlyi(3) & clkout1_dlyi(2) &  clkout1_dlyi(0) & clkout1_dlyi(1) & 'X' & clk0_edgei & "XX");

   dr_sram(7) <= ("1XX" & clk1_hti(5) & clk1_hti(3) & clk1_hti(4) & clk1_hti(2 downto 0)
                  & clk1pm_seli(0) & 'X' & clk1_edgei & "1X" & clk1pm_seli(1) & clk1pm_seli(2));

   dr_sram(8) <= (clk2pm_seli(2) & '1' & clk2_lti(5) & clk2pm_seli(1) & clk2_nocnti
                 & clk2_lti(4) & clk2_lti(3) & clk2_lti(2) & clk2_lti(0)
                 & clkout2_dlyi(5) & clkout2_dlyi(3) & clkout2_dlyi(4)
                 & clkout2_dlyi(1) & clkout2_dlyi(2) & clkout2_dlyi(0) & 'X');
   dr_sram(9) <= (clkout3_dlyi(0) & clkout3_dlyi(1) & clk0pm_seli(1)
                   & clk0pm_seli(2) & "XX" & clk2_hti(4) & 'X' & clk2_hti(3)
                  & clk2_hti(2) & clk2_hti(0) & clk2_hti(1) & clk2_edgei
                  & clk2pm_seli(0) & "XX");

   dr_sram(10) <= ('X' & clk3_edgei & "1X" & clk3pm_seli(1)
                   & clk3pm_seli(2) &  clk3_lti(5) &  clk3_lti(4) &  clk3_nocnti
                  & clk3_lti(2) &  clk3_lti(0) &  clk3_lti(1) &  clkout3_dlyi(4)
                   & clkout3_dlyi(5) & clkout3_dlyi(3) & 'X');

   dr_sram(11) <= (clk0_lti(5) & clkout4_dlyi(5) & clkout4_dlyi(0)
                   & clkout4_dlyi(3) & clkout4_dlyi(1) & clkout4_dlyi(2)
                  &  clk0_lti(4) & 'X' & clk3_hti(5 downto 3) & 'X' & clk3_hti(1)
                  &  clk3_hti(2) & clk3pm_seli(0) & clk3_hti(0));

   dr_sram(12) <= (clk4_hti(1) & clk4_hti(2) & clk4pm_seli(0) & clk4_hti(0)
                  & 'X' & clk4_edgei & 'X' & '1' & clk4pm_seli(2) & clk4pm_seli(1)
                  & clk4_lti(4) & clk4_lti(5) & clk4_lti(3) & clk4_nocnti
                  & clk4_lti(1) & clk4_lti(2));

   dr_sram(13) <= (clk5_lti(2) & clk5_lti(3) & clk5_lti(0) & clk5_lti(1)
                  &  clkout5_dlyi(4) & clkout5_dlyi(5) & clkout5_dlyi(3)
                  &  clkout5_dlyi(2) & clkout5_dlyi(1) & clk0_lti(3)
                  &  clk0_lti(0) & clk0_lti(2) & 'X' & clk4_hti(5)
                   & clk4_hti(3) & clk4_hti(4));

   dr_sram(14) <= (clk5_hti(4) & clk5_hti(5) & clk5_hti(2) & clk5_hti(3)
                  &  clk5_hti(0) & clk5_hti(1) & clk5pm_seli(0) & clk5_edgei
                   & "XX" & clk5pm_seli(2) & '1' & clk5_lti(5) & clk5pm_seli(1)
                   & clk5_nocnti & clk5_lti(4));

   dr_sram(15) <= (clkfbm1_lti(4) & clkfbm1_lti(5) & clkfbm1_lti(3)
                  & clkfbm1_nocnti & clkfbm1_lti(1) & clkfbm1_lti(2) & clkfbm1_lti(0)
                  & clkfbm1_dlyi(5) & clkfbm1_dlyi(4) & clkfbm1_dlyi(3)
                  & clkfbm1_dlyi(1) & clkfbm1_dlyi(2) & clk0_nocnti & clk0_lti(1) & "XX");
   dr_sram(16) <= ('X' & clk0_hti(3) & clk0_hti(5) & clk0_hti(4) & clkfbm1_hti(4)
                  & clkfbm1_hti(5) & clkfbm1_hti(3 downto 0) & clkfbm1_edgei
                  & clkfbm1pm_seli(0) & "1X" & clkfbm1pm_seli(1) & clkfbm1pm_seli(2));
   dr_sram(17) <= (clkfbm2_lti(0) & clkfbm2_dlyi(3) & clkfbm2_hti(2) & clkfbm2_hti(1) &
                  clkfbm2_lti(1) & clkfbm2_hti(4) & clk3_lti(3) & clkout3_dlyi(2)
               &   clk2_hti(5) & clk2_lti(1) & clkout1_dlyi(4) & clk1_lti(0)
               &   clk0_hti(0) & clk0pm_seli(0) & clk0_hti(2) & clk0_hti(1));
   dr_sram(18) <= ("XXXX" & clkout5_dlyi(0) & clkfbm1_dlyi(0) & clk4_lti(0) &
                  clkout4_dlyi(4) & "XXXX" & clkfbm2_nocnti & 'X' & clkfbm2_dlyi(2)
                     &   clkfbm2_lti(4));
   dr_sram(19) <= (clkind_hti(5) & clkfbm2_hti(3) & clkind_hti(4) & 'X'
                   & clkind_hti(1) & clkind_hti(2) & clkind_lti(0) & 'X'
                   & clkind_lti(5) & clkind_lti(2) & 'X' & clkind_edgei & "XXXX");
  dr_sram(20) <= ("XXXXXXX" &  pll_cpres(0) & pll_cpres(1) & clkfbm1_dlyi(1)
                  & clkfbm2_lti(3) & clkfbm2_hti(0) & clkfbm1_dlyi(4)
                  & clkfbm1_dlyi(0) & clkfbm1_dlyi(5) & clkfbm2_hti(5));
   dr_sram(21) <= ('X' & clkind_nocnti & "XXXXXXX" & clkfbm2_edgei & clkfbm2_lti(5)
                    &    clkfbm2_lti(2) & "XXXX");
   dr_sram(22) <= ("XXXX" & pll_lfhf(0) & "XX" & clkind_hti(3) & clkind_lti(1)
                   & 'X' & clkind_hti(0) & 'X' & clkind_lti(3) & 'X'
                    & clkind_lt(4) & 'X');
   dr_sram(23) <= ("XXXXXX" & pll_lfhf(1) & "XXXXXXXXX");
   dr_sram(24) <= (pll_res(0) & pll_res(1) & pll_cp(0) & 'X' & pll_cp(2) 
                  & pll_cp(1) & pll_cp(3) & pll_res(3) & pll_res(2) & "XXXXXXX");
  else
   tmpx := ('X' & 'X' & 'X' & 'X' & 'X' & 'X' & 'X' & 'X' );
   tmpadd := "11100";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clk0_edgei & clk0_nocnti & clkout0_dlyi(5 downto 0));
   tmpadd := "11011";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (clk0pm_seli(2 downto 0) & '1' & clk0_hti(5 downto 0) & clk0_lti(5 downto 0));
   tmpadd := "11010";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clk1_edgei & clk1_nocnti & clkout1_dlyi(5 downto 0));
   tmpadd := "11001";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (clk1pm_seli(2 downto 0) & '1' & clk1_hti(5 downto 0) & clk1_lti(5 downto 0));
   tmpadd := "10111";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clk2_edgei & clk2_nocnti & clkout2_dlyi(5 downto 0));
   tmpadd := "10110";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (clk2pm_seli(2 downto 0) & '1' & clk2_hti(5 downto 0) & clk2_lti(5 downto 0));
   tmpadd := "10101";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clk3_edgei & clk3_nocnti & clkout3_dlyi(5 downto 0));
   tmpadd := "10100";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (clk3pm_seli(2 downto 0) & '1' & clk3_hti(5 downto 0) & clk3_lti(5 downto 0));
   tmpadd := "10011";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clk4_edgei & clk4_nocnti & clkout4_dlyi(5 downto 0));
   tmpadd := "10010";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (clk4pm_seli(2 downto 0) & '1' & clk4_hti(5 downto 0) & clk4_lti(5 downto 0));
   tmpadd := "01111";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clk5_edgei & clk5_nocnti & clkout5_dlyi(5 downto 0));
   tmpadd := "01110";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (clk5pm_seli(2 downto 0) & '1' & clk5_hti(5 downto 0) & clk5_lti(5 downto 0));
   tmpadd := "01101";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clkfbm1_edgei & clkfbm1_nocnti & clkfbm1_dlyi(5 downto 0));
   tmpadd := "01100";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (clkfbm1pm_seli(2 downto 0) & '1' & clkfbm1_hti(5 downto 0) & clkfbm1_lti(5 downto 0));
   tmpadd := "01010";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & clkfbm2_edgei & clkfbm2_nocnti & clkfbm2_dlyi(5 downto 0));
   tmpadd := "01001";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(3 downto 0) & clkfbm2_hti(5 downto 0) & clkfbm2_lti(5 downto 0));
   tmpadd := "00110";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(1 downto 0) & clkind_edgei & clkind_nocnti & clkind_hti(5 downto 0) & clkind_lti(5 downto 0));
   tmpadd := "00001";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(7 downto 0) & pll_lfhf & pll_cpres & pll_cp);
   tmpadd := "00000";
   address := slv_to_int(tmpadd);
   dr_sram(address) <= (tmpx(5 downto 0) & pll_res & tmpx(5 downto 0));
   end if;
   first_time := false;
   drp_init_done <= 1;
   end if;


    if (GSR = '1') then
       drp_lock <= '0';
    elsif (rising_edge(dclk_in)) then 
     if (den_in = '1') then
       valid_daddr := addr_is_valid(daddr_in);
       if (valid_daddr) then
         address := slv_to_int(daddr_in);
         daddr_in_lat <= address;
       end if;

        if (drp_lock = '1') then
          assert false report " Warning : DEN is high at PLL_ADV before DRDY high . Need wait for DRDY signal before next read/write operation through DRP. " severity  warning;
        else 
          drp_lock <= '1';
        end if;
        if (sim_d = '1') then
          if (valid_daddr and (address >= 5 and address <= 24)) then
          else 
                Write ( Message, string'(" Warning :  Address DADDR="));
                Write ( Message,  address);
                Write ( Message, string'(" on the PLL_ADV instance is unsupported") );
                Write ( Message, '.' & LF );
                assert false report Message.all severity warning;
                DEALLOCATE (Message);
          end if;
        else
          if (valid_daddr and ( address = 6  or address = 0 or address = 1 or 
              address = 10 or address = 9 or
             ((address >= 12 and address <= 28) and address /= 16 and 
               address /= 17 and address /= 24))) then
              else 
                Write ( Message, string'(" Warning :  Address DADDR="));
                Write ( Message,  address);
                Write ( Message, string'(" on the PLL_ADV instance is unsupported") );
                Write ( Message, '.' & LF );
                assert false report Message.all severity warning;
                DEALLOCATE (Message);
               end if;
        end if;

        if (dwe_in = '1')  then
          if (rst_input = '1') then
             dr_sram(address) <= di_in;
             di_str := SLV_TO_STR(di_in);
          
            if (sim_d  =  '1') then
              if (daddr_in  =  "00101") then
                clkout0_dlyi(5) := di_in(15);
                clkout0_dlyi(4) := di_in(13);
                clkout0_dlyi(2) := di_in(11);
                clkout0_dlyi(3) := di_in(10);
                clkout0_dlyi(1) := di_in(9);
                clkout0_dlyi(0) := di_in(8);
              end if;
              if (daddr_in  =  "00110") then
                clk1_lti(4) := di_in(15);
                clk1_lti(5) := di_in(14);
                clk1_lti(3) := di_in(13);
                clk1_nocnti := di_in(12);
                clk1_lti(1) := di_in(11);
                clk1_lti(2) := di_in(10);
                clkout1_dlyi(5) := di_in(9);
                clkout1_dlyi(3) := di_in(7);
                clkout1_dlyi(2) := di_in(6);
                clkout1_dlyi(0) := di_in(5);
                clkout1_dlyi(1) := di_in(4);
                clk0_edgei := di_in(2);
              end if;
              if (daddr_in  =  "00111") then
                clk1_hti(5) := di_in(12);
                clk1_hti(3) := di_in(11);
                 clk1_hti(4) := di_in(10);
                clk1_hti(2 downto 0) := di_in(9 downto 7);
                clk1pm_seli(0) := di_in(6);
                clk1_edgei := di_in(4);
                clk1pm_seli(1) := di_in(1);
                clk1pm_seli(2) := di_in(0);
              end if;
              if (daddr_in  =  "01000") then
                clk2pm_seli(2) := di_in(15);
                clk2_lti(5) := di_in(13);
                clk2pm_seli(1) := di_in(12);
                clk2_nocnti := di_in(11);
                clk2_lti(4) := di_in(10);
                clk2_lti(3) := di_in(9);
                clk2_lti(2) := di_in(8);
                clk2_lti(0) := di_in(7);
                clkout5_dlyi(5) := di_in(6);
                clkout5_dlyi(3) := di_in(5);
                clkout5_dlyi(4) := di_in(4);
                clkout5_dlyi(1) := di_in(3);
                clkout5_dlyi(2) := di_in(2);
                clkout5_dlyi(0) := di_in(1);
              end if;
              if (daddr_in  =  "01001") then
                clkout3_dlyi(0) := di_in(15);
                clkout3_dlyi(1) := di_in(14);
                clk3pm_seli(1) := di_in(13);
                clk3pm_seli(2) := di_in(12);
                clk2_hti(4) := di_in(9);
                clk2_hti(3) := di_in(7);
                clk2_hti(2) := di_in(6);
                clk2_hti(0) := di_in(5);
                clk2_hti(1) := di_in(4);
                clk2_edgei := di_in(3);
                clk2pm_seli(0) := di_in(2);
              end if;
              if (daddr_in  =  "01010") then
                clk3_edgei := di_in(14);
                clk3pm_seli(1) := di_in(11);
                clk3pm_seli(2) := di_in(10);
                clk3_lti(5) := di_in(9);
                clk3_lti(4) := di_in(8);
                clk3_nocnti := di_in(7);
                clk3_lti(2) := di_in(6);
                clk3_lti(0) := di_in(5);
                clk3_lti(1) := di_in(4);
                clkout3_dlyi(4) := di_in(3);
                clkout3_dlyi(5) := di_in(2);
                clkout3_dlyi(3) := di_in(1);
              end if;
              if (daddr_in  =  "01011") then
                clk0_lti(5) := di_in(15);
                clkout4_dlyi(5) := di_in(14);
                clkout4_dlyi(0) := di_in(13);
                clkout4_dlyi(3) := di_in(12);
                clkout4_dlyi(1) := di_in(11);
                clkout4_dlyi(2) := di_in(10);
                clk0_lti(4) := di_in(9);
                clk3_hti(5 downto 3) := di_in(7 downto 5);
                clk3_hti(1) := di_in(3);
                clk3_hti(2) := di_in(2);
                clk3pm_seli(0) := di_in(1);
                clk3_hti(0)  := di_in(0);
              end if;
              if (daddr_in  =  "01100") then
                clk4_hti(1) := di_in(15);
                clk4_hti(2) := di_in(14);
                clk4pm_seli(0) := di_in(13);
                clk4_hti(0) := di_in(12);
                clk4_edgei := di_in(10);
                clk4pm_seli(2) := di_in(7);
                clk4pm_seli(1) := di_in(6);
                clk4_lti(4) := di_in(5);
                clk4_lti(5) := di_in(4);
                clk4_lti(3) := di_in(3);
                clk4_nocnti := di_in(2);
                clk4_lti(1) := di_in(1);
                clk4_lti(2) := di_in(0);
              end if;
              if (daddr_in  =  "01101") then
                clk5_lti(2) := di_in(15);
                clk5_lti(3) := di_in(14);
                clk5_lti(0) := di_in(13);
                clk5_lti(1) := di_in(12);
                clkout5_dlyi(4) := di_in(11);
                clkout5_dlyi(5) := di_in(10);
                clkout5_dlyi(3) := di_in(9);
                clkout5_dlyi(2) := di_in(8);
                clkout5_dlyi(1) := di_in(7);
                clk0_lti(3) := di_in(6);
                clk0_lti(0) := di_in(5);
                clk0_lti(2) := di_in(4);
                clk4_hti(5) := di_in(2);
                clk4_hti(3) := di_in(1);
                clk4_hti(4) := di_in(0);
              end if;
              if (daddr_in  =  "01110") then
                clk5_hti(4) := di_in(15);
                clk5_hti(5) := di_in(14);
                clk5_hti(2) := di_in(13);
                clk5_hti(3) := di_in(12);
                clk5_hti(0) := di_in(11);
                clk5_hti(1) := di_in(10);
                clk5pm_seli(0) := di_in(9);
                clk5_edgei := di_in(8);
                clk5pm_seli(2) := di_in(5);
                clk5_lti(5) := di_in(3);
                clk5pm_seli(1) := di_in(2);
                clk5_nocnti := di_in(1);
                clk5_lti(4) := di_in(0);
              end if;
              if (daddr_in  =  "01111") then
                clkfbm1_lti(4) := di_in(15);
                clkfbm1_lti(5) := di_in(14);
                clkfbm1_lti(3) := di_in(13);
                clkfbm1_nocnti := di_in(12);
                clkfbm1_lti(1) := di_in(11);
                clkfbm1_lti(2) := di_in(10);
                clkfbm1_lti(0) := di_in(9);
                clkfbm1_dlyi(5) := di_in(8);
                clkfbm1_dlyi(4) := di_in(7);
                clkfbm1_dlyi(3) := di_in(6);
                clkfbm1_dlyi(1) := di_in(5);
                clkfbm1_dlyi(2) := di_in(4);
                clk0_nocnti := di_in(3);
                clk0_lti(1) := di_in(2);
              end if;
              if (daddr_in  =  "10000") then
                clk0_hti(3) := di_in(14);
                clk0_hti(5) := di_in(13);
                clk0_hti(4) := di_in(12);
                clkfbm1_hti(4) := di_in(11);
                clkfbm1_hti(5) := di_in(10);
                clkfbm1_hti(3 downto 0) := di_in(9 downto 6);
                clkfbm1_edgei := di_in(5);
                clkfbm1pm_seli(0) := di_in(4);
                clkfbm1pm_seli(1) := di_in(1);
                clkfbm1pm_seli(2) := di_in(0);
              end if;
              if (daddr_in  =  "10001") then
                clkfbm2_lti(0) := di_in(15);
                clkfbm2_dlyi(3) := di_in(14);
                clkfbm2_hti(2) := di_in(13);
                clkfbm2_hti(1) := di_in(12);
                clkfbm2_lti(1) := di_in(11);
                clkfbm2_hti(4) := di_in(10);
                clk3_lti(3) := di_in(9);
                clkout3_dlyi(2) := di_in(8);
                clk2_hti(5) := di_in(7);
                clk2_lti(1) := di_in(6);
                clkout1_dlyi(4) := di_in(5);
                clk1_lti(0) := di_in(4);
                clk0_hti(0) := di_in(3);
                clk0pm_seli(0) := di_in(2);
                clk0_hti(2) := di_in(1);
                clk0_hti(1) := di_in(0);
              end if;
              if (daddr_in  =  "10010") then
                clkout5_dlyi(0) := di_in(11);
                clkfbm1_dlyi(0) := di_in(10);
                clk4_lti(0) := di_in(9);
                clkout4_dlyi(4) := di_in(8);
                clkfbm2_nocnti := di_in(3);
                clkfbm2_dlyi(2) := di_in(1);
                clkfbm2_lti(4) := di_in(0);
              end if;
              if (daddr_in  =  "10011") then
                clkind_hti(5) := di_in(15);
                clkfbm2_hti(3) := di_in(14);
                clkind_hti(4) := di_in(13);
                clkind_hti(1) := di_in(11);
                clkind_hti(2) := di_in(10);
                clkind_lti(0) := di_in(9);
                clkind_lti(5) := di_in(7);
                clkind_lti(2) := di_in(6);
                clkind_edgei := di_in(4);
              end if;
              if (daddr_in  =  "10100") then
                pll_res(2) := di_in(13);
                pll_res(1) := di_in(11);
                pll_res(3) := di_in(10);
                pll_res(0) := di_in(9);
                pll_cpres(0) := di_in(8);
                pll_cpres(1) := di_in(7);
                clkfbm1_dlyi(1) := di_in(6);
                clkfbm2_lti(3) := di_in(5);
                clkfbm2_hti(0) := di_in(4);
                clkfbm1_dlyi(4) := di_in(3);
                clkfbm1_dlyi(0) := di_in(2);
                clkfbm1_dlyi(5) := di_in(1);
                clkfbm2_hti(5) := di_in(0);
              end if;
              if (daddr_in  =  "10101")  then
                clkind_nocnti := di_in(14);
                clkfbm2_edgei := di_in(6);
                clkfbm2_lti(5) := di_in(5);
                clkfbm2_lti(2) := di_in(4);
              end if;
              if (daddr_in  =  "10110") then
                pll_lfhf(0) := di_in(11);
                clkind_hti(3) := di_in(8);
                clkind_lti(1) := di_in(7);
                clkind_hti(0) := di_in(5);
                clkind_lti(3) := di_in(3);
                clkind_lti(4) := di_in(1);
              end if;
              if (daddr_in  =  "10111") then
                pll_lfhf(1) := di_in(9);
              end if;
              if (daddr_in  =  "11000") then
                pll_cp(0) := di_in(13);
                pll_cp(2) := di_in(11);
                pll_cp(1) := di_in(10);
                pll_cp(0) := di_in(9);
              end if;

              clk0_ht <= clk0_hti;
              clk1_ht <= clk1_hti;
              clk2_ht <= clk2_hti;
              clk3_ht <= clk3_hti;
              clk4_ht <= clk4_hti;
              clk5_ht <= clk5_hti;
              clkfbm1_ht <= clkfbm1_hti;
              clkfbm2_ht <= clkfbm2_hti;
              clkind_ht <= ( '0' & clkind_hti(5 downto 0));
              clk0_lt <= clk0_lti;
              clk1_lt <= clk1_lti;
              clk2_lt <= clk2_lti;
              clk3_lt <= clk3_lti;
              clk4_lt <= clk4_lti;
              clk5_lt <= clk5_lti;
              clkfbm1_lt <= clkfbm1_lti;
              clkfbm2_lt <= clkfbm2_lti;
              clkind_lt <= ( '0' & clkind_lti(5 downto 0));
              clk0_nocnt <= clk0_nocnti;
              clk1_nocnt <= clk1_nocnti;
              clk2_nocnt <= clk2_nocnti;
              clk3_nocnt <= clk3_nocnti;
              clk4_nocnt <= clk4_nocnti;
              clk5_nocnt <= clk5_nocnti;
              clkfbm1_nocnt <= clkfbm1_nocnti;
              clkfbm2_nocnt <= clkfbm2_nocnti;
              clkind_nocnt <= clkind_nocnti;
              clk0_edge <= clk0_edgei;
              clk1_edge <= clk1_edgei;
              clk2_edge <= clk2_edgei;
              clk3_edge <= clk3_edgei;
              clk4_edge <= clk4_edgei;
              clk5_edge <= clk5_edgei;
              clkfbm1_edge <= clkfbm1_edgei;
              clkfbm2_edge <= clkfbm2_edgei;
              clkind_edge <= clkind_edgei;
              clkout0_dly <= SLV_TO_INT(clk0_dlyi);
              clkout1_dly <= SLV_TO_INT(clk1_dlyi);
              clkout2_dly <= SLV_TO_INT(clk2_dlyi);
              clkout3_dly <= SLV_TO_INT(clk3_dlyi);
              clkout4_dly <= SLV_TO_INT(clk4_dlyi);
              clkout5_dly <= SLV_TO_INT(clk5_dlyi);
              clkfbm1_dly <= SLV_TO_INT(clkfbm1_dlyi);
              clkfbm2_dly <= SLV_TO_INT(clkfbm2_dlyi);
              clk0pm_sel <=  SLV_TO_INT(clk0pm_seli);
              clk1pm_sel <=  SLV_TO_INT(clk1pm_seli);
              clk2pm_sel <=  SLV_TO_INT(clk2pm_seli);
              clk3pm_sel <=  SLV_TO_INT(clk3pm_seli);
              clk4pm_sel <=  SLV_TO_INT(clk4pm_seli);
              clk5pm_sel <=  SLV_TO_INT(clk5pm_seli);
              clkfbm1pm_sel <=  SLV_TO_INT(clkfbm1pm_seli);
              clkfbm2pm_sel <=  0;

            else
             if (daddr_in = "11100") then
                 daddr_str := "11100";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout0_dly <= SLV_TO_INT(clkout_dly);
                 clk0_nocnt <= clk_nocnt;
                 clk0_nocnti := clk_nocnt;
                 clk0_edgei := clk_edge;
                 clk0_edge <= clk_edge;
             end if;

             if (daddr_in = "11011") then
                daddr_str := "11011";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk0_lt <= clk_lt;
                 clk0_ht <= clk_ht;
                 clk0_lti := clk_lt;
                 clk0_hti := clk_ht;
                 clk0pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "11010") then
                 daddr_str := "11010";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout1_dly <= SLV_TO_INT(clkout_dly);
                 clk1_nocnt <= clk_nocnt;
                 clk1_nocnti := clk_nocnt;
                 clk1_edgei := clk_edge;
                 clk1_edge <= clk_edge;
             end if;


             if (daddr_in = "11001") then
                 daddr_str := "11001";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk1_lt <= clk_lt;
                 clk1_ht <= clk_ht;
                 clk1_lti := clk_lt;
                 clk1_hti := clk_ht;
                 clk1pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "10111") then
                 daddr_str := "10111";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout2_dly <= SLV_TO_INT(clkout_dly);
                 clk2_nocnt <= clk_nocnt;
                 clk2_nocnti := clk_nocnt;
                 clk2_edgei := clk_edge;
                 clk2_edge <= clk_edge;
             end if;

             if (daddr_in = "10110") then
                 daddr_str := "10110";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk2_lt <= clk_lt;
                 clk2_ht <= clk_ht;
                 clk2_lti := clk_lt;
                 clk2_hti := clk_ht;
                 clk2pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "10101") then
                 daddr_str := "10101";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout3_dly <= SLV_TO_INT(clkout_dly);
                 clk3_nocnt <= clk_nocnt;
                 clk3_nocnti := clk_nocnt;
                 clk3_edgei := clk_edge;
                 clk3_edge <= clk_edge;
             end if;

             if (daddr_in = "10100") then
                 daddr_str := "10100";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk3_lt <= clk_lt;
                 clk3_ht <= clk_ht;
                 clk3_lti := clk_lt;
                 clk3_hti := clk_ht;
                 clk3pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "10011") then
                 daddr_str := "10011";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout4_dly <= SLV_TO_INT(clkout_dly);
                 clk4_nocnt <= clk_nocnt;
                 clk4_nocnti := clk_nocnt;
                 clk4_edgei := clk_edge;
                 clk4_edge <= clk_edge;
             end if;

             if (daddr_in = "10010") then
                 daddr_str := "10010";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk4_lt <= clk_lt;
                 clk4_ht <= clk_ht;
                 clk4_lti := clk_lt;
                 clk4_hti := clk_ht;
                 clk4pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "01111") then
                 daddr_str := "01111";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout5_dly <= SLV_TO_INT(clkout_dly);
                 clk5_nocnt <= clk_nocnt;
                 clk5_nocnti := clk_nocnt;
                 clk5_edgei := clk_edge;
                 clk5_edge <= clk_edge;
             end if;

             if (daddr_in = "01110") then
                 daddr_str := "01110";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk5_lt <= clk_lt;
                 clk5_lti := clk_lt;
                 clk5_ht <= clk_ht;
                 clk5_hti := clk_ht;
                 clk5pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "01101") then
                 daddr_str := "01101";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkfbm1_dly <= SLV_TO_INT(clkout_dly);
                 clkfbm1_nocnt <= clk_nocnt;
                 clkfbm1_nocnti := clk_nocnt;
                 clkfbm1_edge <= clk_edge;
                 clkfbm1_edgei := clk_edge;
             end if;

             if (daddr_in = "01100") then
                 daddr_str := "01100";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clkfbm1_lt <= clk_lt;
                 clkfbm1_lti := clk_lt;
                 clkfbm1_ht <= clk_ht;
                 clkfbm1_hti := clk_ht;
                 clkfbm1pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "01010") then
                 daddr_str := "01010";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkfbm2_dly <= SLV_TO_INT(clkout_dly);
                 clkfbm2_nocnt <= clk_nocnt;
                 clkfbm2_nocnti := clk_nocnt;
                 clkfbm2_edge <= clk_edge;
                 clkfbm2_edgei := clk_edge;
             end if;

             if (daddr_in = "01001") then
                 daddr_str := "01001";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clkfbm2_lt <= clk_lt;
                 clkfbm2_lti := clk_lt;
                 clkfbm2_ht <= clk_ht;
                 clkfbm2_hti := clk_ht;
                 clkfbm2pm_sel <=  0;
             end if;

             if (daddr_in = "00110") then
                 clkind_lti := ('0' & di_in(11 downto 6));
                 clkind_hti := ('0' & di_in(5 downto 0));
                  clkind_lt <= clkind_lti;
                  clkind_ht <= clkind_hti;
                 clkind_nocnti := di_in(12);
                 clkind_edgei := di_in(13);
              end if;
           end if;

   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk0_hti, clk0_lti, clk0_nocnti, clk0_edgei);
   clk0_ht1 <= clk_ht1;
   clk0_div <= clk_div;
   clk0_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk1_hti, clk1_lti, clk1_nocnti, clk1_edgei);
   clk1_ht1 <= clk_ht1;
   clk1_div <= clk_div;
   clk1_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk2_hti, clk2_lti, clk2_nocnti, clk2_edgei);
   clk2_ht1 <= clk_ht1;
   clk2_div <= clk_div;
   clk2_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk3_hti, clk3_lti, clk3_nocnti, clk3_edgei);
   clk3_ht1 <= clk_ht1;
   clk3_div <= clk_div;
   clk3_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk4_hti, clk4_lti, clk4_nocnti, clk4_edgei);
   clk4_ht1 <= clk_ht1;
   clk4_div <= clk_div;
   clk4_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk5_hti, clk5_lti, clk5_nocnti, clk5_edgei);
   clk5_ht1 <= clk_ht1;
   clk5_div <= clk_div;
   clk5_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm2_hti, clkfbm2_lti, clkfbm2_nocnti, clkfbm2_edgei);
   clkfbm2_ht1 <= clk_ht1;
   clkfbm2_div <= clk_div;
   clkfbm2_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm1_hti, clkfbm1_lti, clkfbm1_nocnti, clkfbm1_edgei);
   clkfbm1_ht1 <= clk_ht1;
   clkfbm1_div <= clk_div;
   clkfbm1_div1 <= clk_div1;
   clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkind_hti, clkind_lti, clkind_nocnti, '0');
   clkind_div <= clk_div;
    if (clk_div > 52 or (clk_div < 1 and clkind_nocnti = '0')) then
      assert false report " Input Error : The sum of DI[11:6] and DI[5:0] Address DADDR=00110 is input clock divider of PLL_ADV and over the 1 to 52 range." severity error;
    end if;

          else 
                 assert false report " Error : RST is low at PLL_ADV. RST need to be high when change PLL_ADV paramters through DRP. " severity error;
          end if; -- end rst

        end if; --DWE
    end if;  --DEN

    if ( drp_lock = '1') then
          drp_lock <= '0';
          drp_lock1 <= '1';
    end if;
    if (drp_lock1 = '1') then
         drp_lock1 <= '0';
         drdy_out <= '1';
    end if;
    if (drdy_out = '1') then
        drdy_out <= '0';
    end if;
 end if; -- end GSR

  wait on dclk_in, GSR, init_done;

  end process;

  process (clkfbm1_div, clkfbm2_div, clk0_div) 
  begin
      if (clkfb_src = 1) then
           clkfbm_div <= clkfbm2_div * clk0_div;
      else
          clkfbm_div <= clkfbm1_div;
      end if;
  end process;


   clkfbm_dly <= clkout0_dly when (clkfb_src = 1) else clkfbm1_dly;
   clkfbmpm_sel <= clk0pm_sel when (clkfb_src = 1) else clkfbm1pm_sel;


   CLOCK_PERIOD_P : process (clkpll, rst_in)
      variable  clkin_edge_previous : time := 0 ps;
      variable  clkin_edge_current : time := 0 ps;
   begin
     if (rst_in = '1') then
        clkin_period(0) <= period_vco_target;
        clkin_period(1) <= period_vco_target;
        clkin_period(2) <= period_vco_target;
        clkin_period(3) <= period_vco_target;
        clkin_period(4) <= period_vco_target;
        clkin_jit <= 0 ps;
        clkin_lock_cnt <= 0;
        pll_locked_tm <= '0';
        pll_locked_tmp1 <= '0';
        lock_period <= '0';
        clkout_en0_tmp <= '0';
        unlock_recover <= '0';
        clkin_edge_previous := 0 ps;
     elsif (rising_edge(clkpll)) then
       clkin_edge_current := NOW;
       clkin_period(4) <= clkin_period(3);
       clkin_period(3) <= clkin_period(2);
       clkin_period(2) <= clkin_period(1);
       clkin_period(1) <= clkin_period(0);
       if (clkin_edge_previous /= 0 ps and  clkin_stopped = '0') then
          clkin_period(0) <= clkin_edge_current - clkin_edge_previous;
       end if;

       if (pll_unlock = '0') then
          clkin_jit <=  clkin_edge_current - clkin_edge_previous - clkin_period(0);
       else
          clkin_jit <= 0 ps;
       end if;

          clkin_edge_previous := clkin_edge_current;

      if ( pll_unlock = '0' and  (clkin_lock_cnt < lock_cnt_max) and fb_delay_found = '1' ) then
            clkin_lock_cnt <= clkin_lock_cnt + 1;
      elsif (pll_unlock = '1' and rst_on_loss = '0' and pll_locked_tmp1 = '1' ) then
            clkin_lock_cnt <= locked_en_time;
            unlock_recover <= '1';
      end if;

      if ( clkin_lock_cnt >= PLL_LOCK_TIME and pll_unlock = '0') then
        pll_locked_tm <= '1';
      end if;

      if ( clkin_lock_cnt = 6 ) then
        lock_period <= '1';
      end if;

      if (clkin_lock_cnt >= clkout_en_time) then
          clkout_en0_tmp <= '1';
      end if;
 
      if (clkin_lock_cnt >= locked_en_time) then
          pll_locked_tmp1 <= '1';
      end if;

      if (unlock_recover = '1' and clkin_lock_cnt  >= lock_cnt_max) then
          unlock_recover <= '0';
      end if;

    end if;
   end process;

   CLKOUT_EN_P : process 
   begin
      if (clkout_en0_tmp = '0') then
         clkout_en0 <= '0';
      else
         clkout_en0 <= clkout_en0_tmp after clkin_period(0);
      end if;
     wait on clkout_en0_tmp;
   end process;

   PLL_LOCK_P1 : process (pll_locked_tmp1, rst_in)
   begin
     if (rst_in = '1') then
         pll_locked_tmp2 <= '0';
     elsif (pll_locked_tmp1 = '0') then
         pll_locked_tmp2 <=  pll_locked_tmp1;
     else 
--          wait until (rising_edge(clkvco));
          pll_locked_tmp2 <= pll_locked_tmp1 after pll_locked_delay;
     end if;
   end process;

   locked_out <= '1' when pll_locked_tm = '1' and pll_locked_tmp2 ='1' and pll_unlock = '0'
                         and unlock_recover = '0' else '0';

   CLOCK_PERIOD_AVG_P : process (clkin_period(0), clkin_period(1), clkin_period(2),
                                 clkin_period(3), clkin_period(4), period_avg)
      variable period_avg_tmp : time := 0.000 ps;
      variable clkin_period_tmp0 : time := 0.000 ps;
   begin
      clkin_period_tmp0 := clkin_period(0);
     if (clkin_period_tmp0 /= period_avg) then
         period_avg_tmp := (clkin_period(0) + clkin_period(1) + clkin_period(2)
                       + clkin_period(3) + clkin_period(4))/5.0;
         period_avg <= period_avg_tmp;
     end if;
   end process;

   CLOCK_PERIOD_UPDATE_P : process (period_avg, clkind_div, clkfbm_div, init_done, drp_init_done)
      variable period_fb_var : time;
      variable period_vco_var : time;
      variable tmpreal : real;
      variable tmpreal1: real;
      variable period_vco_rm_var : integer;
      variable period_vco_rm_var1 : integer;
      variable period_vco_half_rm_t : time;
      variable first_time : boolean := true;
      variable md_product_var : integer;
      variable m_product_var : integer;
      variable m_product2_var : integer;
   begin
   if (first_time = true and init_done = 1) then
       md_product_var := clkfb_mult_tl * DIVCLK_DIVIDE;
       m_product_var := clkfb_mult_tl;
       m_product2_var := clkfb_mult_tl / 2;
       md_product <= md_product_var;
       m_product <= m_product_var;
       m_product2 <= m_product2_var;
       first_time := false;
   end if;
   if ( drp_init_done = 1) then
       md_product_var := clkfbm_div * clkind_div;
       m_product_var := clkfbm_div;
       m_product2_var := clkfbm_div / 2;
       md_product <= md_product_var;
       m_product <= m_product_var;
       m_product2 <= m_product2_var;
       period_fb_var :=  clkind_div * period_avg;
       period_vco_var := period_fb_var / clkfbm_div;
       period_vco_rm_var1 := period_fb_var / 1 ps;
       period_vco_rm_var := period_vco_rm_var1 mod clkfbm_div;
       period_vco_rm <= period_vco_rm_var;
       clkin_lost_val <= (period_avg * 2) / 500 ps;
       clkfb_lost_val <= (period_fb_var * 2) / 500 ps;
       if (period_vco_rm_var > 1) then
          if (period_vco_rm_var > m_product2_var)  then
             period_vco_cmp_cnt <= (m_product_var / (m_product_var - period_vco_rm_var)) - 1;
             period_vco_cmp_flag <= 2;
          else 
             period_vco_cmp_cnt <= (m_product_var / period_vco_rm_var) - 1;
             period_vco_cmp_flag <= 1;
          end if;
       else 
          period_vco_cmp_cnt <= 0;
          period_vco_cmp_flag <= 0;
       end if;

       period_vco_half <= period_vco_var /2;
       period_vco_half1 <= ((period_vco_var /2) / 1 ps + 1) * 1 ps;
       period_vco_half_rm_t := period_vco_var - (period_vco_var /2);
       period_vco_half_rm <= period_vco_half_rm_t;
       period_vco_half_rm1 <= period_vco_half_rm_t + 1 ps;
       period_vco_half_rm2 <= period_vco_half_rm_t - 1 ps;
       pll_locked_delay <= period_fb_var * clkfbm_div;
       clkin_dly_t <=  period_avg * clkind_div + period_avg * 1.25;
       clkfb_dly_t <= period_fb_var * 2.25; 
       period_fb <= period_fb_var;
       period_vco <= period_vco_var;
       period_vco1 <= period_vco_var / 8.0;
       period_vco2 <= period_vco_var / 4.0;
       period_vco3 <= period_vco_var * 3.0 / 8.0;
       period_vco4 <= period_vco_var / 2.0;
       period_vco5 <= period_vco_var * 5.0 / 8.0;
       period_vco6 <= period_vco_var * 3.0 / 4.0;
       period_vco7 <= period_vco_var * 7.0 / 8.0;
   end if;
   end process;

   clkvco_lk_rst <=  '1' when ( rst_in = '1' or  pll_unlock = '1' or  pll_locked_tm = '0') else '0';

   CLKVCO_LK_P : process
       variable clkvco_rm_cnt : integer;
       variable vcoflag : integer := 0;
   begin
   if ( clkvco_lk_rst = '1') then
        clkvco_lk <= '0';
   else
     if (rising_edge(clkpll)) then
       if (pll_locked_tm = '1') then
          clkvco_lk <= '1';
          clkvco_rm_cnt := 0;
       if ( period_vco_cmp_flag = 1) then
          vcoflag := 1;
          for I in 2 to m_product loop
               wait for (period_vco_half);
               clkvco_lk <=  '0';  
               if ( clkvco_rm_cnt = 1) then
                   wait for (period_vco_half_rm1);
                   clkvco_lk <=  '1';  
               else
                   wait for (period_vco_half_rm);
                   clkvco_lk <=  '1';  
               end if;

               if ( clkvco_rm_cnt = period_vco_cmp_cnt) then
                  clkvco_rm_cnt := 0;
               else
                   clkvco_rm_cnt := clkvco_rm_cnt + 1;
               end if;
          end loop;
       elsif ( period_vco_cmp_flag = 2) then
          vcoflag := 1;
          for I in 2 to m_product loop
               wait for (period_vco_half);
               clkvco_lk <=  '0';
               if ( clkvco_rm_cnt = 1) then
                   wait for (period_vco_half_rm);
                   clkvco_lk <=  '1';
               else
                   wait for (period_vco_half_rm1);
                   clkvco_lk <=  '1';
               end if;

               if ( clkvco_rm_cnt = period_vco_cmp_cnt) then
                  clkvco_rm_cnt := 0;
               else
                   clkvco_rm_cnt := clkvco_rm_cnt + 1;
               end if;
          end loop;
       else
          vcoflag := 1;
          for I in 2 to md_product loop
           wait for (period_vco_half);
           clkvco_lk <=  '0';

           wait for (period_vco_half_rm);
           clkvco_lk <=  '1';
          end loop;
       end if;

       wait for (period_vco_half);
       clkvco_lk <= '0';
  
       if (clkpll = '1' and vcoflag = 0) then
          for I in 2 to md_product loop
           wait for (period_vco_half);
           clkvco_lk <=  '0';

           wait for (period_vco_half_rm);
           clkvco_lk <=  '1';
          end loop;
          wait for (period_vco_half);
          clkvco_lk <= '0';
        end if;
      end if;
     end if;
   end if;
   wait on clkpll, rst_in ,  pll_unlock;
  end process;

  CLKVCO_DLY_CAL_P : process ( period_vco, fb_delay, clkfbm_dly, clkfbm1pm_rl)
    variable val_tmp : integer;
    variable val_tmp2 : integer;
    variable val_tmp3 : integer;
    variable fbm1_comp_delay : integer;
    variable fbm1_comp_delay_rl : real;
    variable period_vco_i : integer;
    variable period_vco_rl : real;
    variable dly_tmp : integer;
    variable tmp_rl : real;
  begin
   if (period_vco /= 0 ps) then
    period_vco_i := period_vco * 1 / 1 ps;
    period_vco_rl := real(period_vco_i);
    tmp_rl := real(clkfbm_dly);
--    val_tmp := period_vco_i * md_product;
    val_tmp := (period_avg * 1 / 1 ps ) * DIVCLK_DIVIDE;
    if (clkfb_src = 1) then
       fbm1_comp_delay_rl := period_vco_rl *(tmp_rl  + clkfbm1pm_rl );
    else
       fbm1_comp_delay_rl := period_vco_rl *(tmp_rl  + clkfbm1pm_rl );
    end if;
    fbm1_comp_delay := real2int(fbm1_comp_delay_rl);
    val_tmp2 := fb_delay * 1 / 1 ps;
    dly_tmp := val_tmp2 + fbm1_comp_delay;
    if ( dly_tmp < val_tmp) then
       clkvco_delay <= (val_tmp - dly_tmp) * 1 ps;
    else
       clkvco_delay <=  (val_tmp - dly_tmp mod val_tmp) * 1 ps;
    end if;
   end if;
  end process;

  CLKFB_PS_P : process (clkfbmpm_sel)
  begin
    case (clkfbmpm_sel) is
       when 0 => clkfbm1pm_rl <= 0.0;
       when 1 => clkfbm1pm_rl <= 0.125;
       when 2 => clkfbm1pm_rl <= 0.25;
       when 3 => clkfbm1pm_rl <= 0.375;
       when 4 => clkfbm1pm_rl <= 0.50;
       when 5 => clkfbm1pm_rl <= 0.625;
       when 6 => clkfbm1pm_rl <= 0.75;
       when 7 => clkfbm1pm_rl <= 0.875;
       when others => clkfbm1pm_rl <= 0.0;
    end case;
   end process;

   CLKVCO_FREE_P : process 
   begin
      if (pmcd_mode /= '1' and pll_locked_tm = '0') then
          wait for period_vco_target_half;
          clkvco_free <= not clkvco_free;
      end if;
      wait on clkvco_free;
   end process;
  
   CLKVCO_GEN_P : process ( pll_locked_tm, clkvco_lk, clkvco_free)
   begin
     if (pll_locked_tm = '1') then
          clkvco <= transport clkvco_lk after clkvco_delay;
     else
          clkvco <= transport clkvco_free after clkvco_delay;
     end if;
   end process;

   clkout_en <=  clkout_en0 after clkvco_delay;


  CLKOUT_MUX_P : process (clkvco, clkout_en, rst_in) 
  begin
   if (rst_in = '1') then
       clkout_mux <= "00000000";
   elsif (clkout_en = '1' and clkvco'event) then
       clkout_mux(0) <= clkvco;
       clkout_mux(1) <= transport clkvco after (period_vco1);
       clkout_mux(2) <= transport clkvco after (period_vco2);
       clkout_mux(3) <= transport clkvco after (period_vco3);
       clkout_mux(4) <= transport clkvco after (period_vco4);
       clkout_mux(5) <= transport clkvco after (period_vco5);
       clkout_mux(6) <= transport clkvco after (period_vco6);
       clkout_mux(7) <= transport clkvco after (period_vco7);
  end if;
  end process;

   clk0in <= clkout_mux(clk0pm_sel);
   clk1in <= clkout_mux(clk1pm_sel);
   clk2in <= clkout_mux(clk2pm_sel);
   clk3in <= clkout_mux(clk3pm_sel);
   clk4in <= clkout_mux(clk4pm_sel);
   clk5in <= clkout_mux(clk5pm_sel);
   clkfbm1in <= clkout_mux(clkfbm1pm_sel);

   clk0ps_en <= clkout_en when clk0_dly_cnt = clkout0_dly else '0';
   clk1ps_en <= clkout_en when clk1_dly_cnt = clkout1_dly else '0';
   clk2ps_en <= clkout_en when clk2_dly_cnt = clkout2_dly else '0';
   clk3ps_en <= clkout_en when clk3_dly_cnt = clkout3_dly else '0';
   clk4ps_en <= clkout_en when clk4_dly_cnt = clkout4_dly else '0';
   clk5ps_en <= clkout_en when clk5_dly_cnt = clkout5_dly else '0';
   clkfbm1ps_en <= clkout_en when clkfbm1_dly_cnt = clkfbm1_dly else '0';

   CLK_DLY_CNT_P : process(clk0in, clk1in, clk2in, clk3in, clk4in, clk5in, clkfbm1in,
                    rst_in)
   begin
     if (rst_in = '1') then
         clk0_dly_cnt <= 0;
         clk1_dly_cnt <= 0;
         clk2_dly_cnt <= 0;
         clk3_dly_cnt <= 0;
         clk4_dly_cnt <= 0;
         clk5_dly_cnt <= 0;
         clkfbm1_dly_cnt <= 0;
     else
       if (falling_edge(clk0in)) then
          if ((clk0_dly_cnt < clkout0_dly) and clkout_en = '1') then
            clk0_dly_cnt <= clk0_dly_cnt + 1;
          end if;
        end if;

       if (falling_edge(clk1in)) then
          if ((clk1_dly_cnt < clkout1_dly) and clkout_en = '1') then
            clk1_dly_cnt <= clk1_dly_cnt + 1;
          end if;
        end if;

       if (falling_edge(clk2in)) then
          if ((clk2_dly_cnt < clkout2_dly) and clkout_en = '1') then
            clk2_dly_cnt <= clk2_dly_cnt + 1;
          end if;
        end if;

       if (falling_edge(clk3in)) then
          if ((clk3_dly_cnt < clkout3_dly) and clkout_en = '1') then
            clk3_dly_cnt <= clk3_dly_cnt + 1;
          end if;
        end if;

       if (falling_edge(clk4in)) then
         if ((clk4_dly_cnt < clkout4_dly) and clkout_en = '1') then
            clk4_dly_cnt <= clk4_dly_cnt + 1;
         end if;
        end if;

       if (falling_edge(clk5in)) then
          if ((clk5_dly_cnt < clkout5_dly) and clkout_en = '1') then
            clk5_dly_cnt <= clk5_dly_cnt + 1;
          end if;
        end if;

       if (falling_edge(clkfbm1in)) then
          if ((clkfbm1_dly_cnt < clkfbm1_dly) and clkout_en = '1') then
            clkfbm1_dly_cnt <= clkfbm1_dly_cnt + 1;
          end if;
        end if;

    end if;
   end process;


   CLK0_GEN_P : process (clk0in, rst_in)
   begin
     if (rst_in = '1') then
         clk0_cnt <= 0;
         clk0_out <= '0';
     else
        if (rising_edge(clk0in) or falling_edge(clk0in)) then
            if (clk0ps_en = '1') then

              if (clk0_cnt < clk0_div1) then
                      clk0_cnt <= clk0_cnt + 1;
               else
                      clk0_cnt <= 0;
               end if;

               if  (clk0_cnt < clk0_ht1) then
                     clk0_out <= '1';
               else
                     clk0_out <= '0';
               end if;
          else
             clk0_out <= '0';
             clk0_cnt <= 0;
          end if;
        end if;
    end if;
   end process;
              
   CLK1_GEN_P : process (clk1in, rst_in)
   begin
     if (rst_in = '1') then
         clk1_cnt <= 0;
         clk1_out <= '0';
     else
        if (rising_edge(clk1in)  or falling_edge(clk1in)) then
            if (clk1ps_en = '1') then
              if (clk1_cnt < clk1_div1) then
                      clk1_cnt <= clk1_cnt + 1;
               else
                      clk1_cnt <= 0;
               end if;

               if  (clk1_cnt < clk1_ht1) then
                     clk1_out <= '1';
               else
                     clk1_out <= '0';
               end if;
          else
             clk1_out <= '0';
             clk1_cnt <= 0;
          end if;
        end if;
    end if;
   end process;


   CLK2_GEN_P : process (clk2in, rst_in)
   begin
     if (rst_in = '1') then
         clk2_cnt <= 0;
         clk2_out <= '0';
     else
        if (rising_edge(clk2in)  or falling_edge(clk2in)) then
            if (clk2ps_en = '1') then
              if (clk2_cnt < clk2_div1) then
                      clk2_cnt <= clk2_cnt + 1;
               else
                      clk2_cnt <= 0;
               end if;

               if  (clk2_cnt < clk2_ht1) then
                     clk2_out <= '1';
               else
                     clk2_out <= '0';
               end if;
          else
             clk2_out <= '0';
             clk2_cnt <= 0;
          end if;
        end if;
    end if;
   end process;


   CLK3_GEN_P : process (clk3in, rst_in)
   begin
     if (rst_in = '1') then
         clk3_cnt <= 0;
         clk3_out <= '0';
     else
        if (rising_edge(clk3in)  or falling_edge(clk3in)) then
            if (clk3ps_en = '1') then
               if  (clk3_cnt < clk3_ht1) then
                     clk3_out <= '1';
               else
                     clk3_out <= '0';
               end if;

              if (clk3_cnt < clk3_div1) then
                      clk3_cnt <= clk3_cnt + 1;
               else
                      clk3_cnt <= 0;
               end if;
          else
             clk3_out <= '0';
             clk3_cnt <= 0;
          end if;
        end if;
    end if;
   end process;


   CLK4_GEN_P : process (clk4in, rst_in)
   begin
     if (rst_in = '1') then
         clk4_cnt <= 0;
         clk4_out <= '0';
     else
        if (rising_edge(clk4in)  or falling_edge(clk4in)) then
            if (clk4ps_en = '1') then
              if (clk4_cnt < clk4_div1) then
                      clk4_cnt <= clk4_cnt + 1;
               else
                      clk4_cnt <= 0;
               end if;

               if  (clk4_cnt < clk4_ht1) then
                     clk4_out <= '1';
               else
                     clk4_out <= '0';
               end if;
          else
             clk4_out <= '0';
             clk4_cnt <= 0;
          end if;
        end if;
    end if;
   end process;


   CLK5_GEN_P : process (clk5in, rst_in)
   begin
     if (rst_in = '1') then
         clk5_cnt <= 0;
         clk5_out <= '0';
     else
        if (rising_edge(clk5in)  or falling_edge(clk5in)) then
            if (clk5ps_en = '1') then
              if (clk5_cnt < clk5_div1) then
                      clk5_cnt <= clk5_cnt + 1;
               else
                      clk5_cnt <= 0;
               end if;

               if  (clk5_cnt < clk5_ht1) then
                     clk5_out <= '1';
               else
                     clk5_out <= '0';
               end if;
          else
             clk5_out <= '0';
             clk5_cnt <= 0;
          end if;
        end if;
    end if;
   end process;


   CLKFB_GEN_P : process (clkfbm1in, rst_in)
   begin
     if (rst_in = '1') then
         clkfbm1_cnt <= 0;
         clkfbm1_out <= '0';
     else
        if (rising_edge(clkfbm1in)  or falling_edge(clkfbm1in)) then
            if (clkfbm1ps_en = '1') then
              if (clkfbm1_cnt < clkfbm1_div1) then
                      clkfbm1_cnt <= clkfbm1_cnt + 1;
               else
                      clkfbm1_cnt <= 0;
               end if;

               if  (clkfbm1_cnt < clkfbm1_ht1) then
                     clkfbm1_out <= '1';
               else
                     clkfbm1_out <= '0';
               end if;
          else
             clkfbm1_out <= '0';
             clkfbm1_cnt <= 0;
          end if;
        end if;
    end if;
   end process;

              
    clkout0_out <= transport clk0_out  when fb_delay_found = '1' else clkfb_tst;
    clkout1_out <= transport clk1_out  when fb_delay_found = '1' else clkfb_tst;
    clkout2_out <= transport clk2_out  when fb_delay_found = '1' else clkfb_tst;
    clkout3_out <= transport clk3_out  when fb_delay_found = '1' else clkfb_tst;
    clkout4_out <= transport clk4_out  when fb_delay_found = '1' else clkfb_tst;
    clkout5_out <= transport clk5_out  when fb_delay_found = '1' else clkfb_tst;
    clkfb_out <= transport clkfbm1_out  when fb_delay_found = '1' else clkfb_tst;

--
-- determine feedback delay
--

  CLKFB_TST_P : process (clkpll, rst_in1)
  begin
  if (rst_in1 = '1') then
       clkfb_tst <= '0';
  elsif (rising_edge(clkpll)) then
    if (fb_delay_found_tmp = '0' and GSR = '0') then
       clkfb_tst <=   '1';
     else
       clkfb_tst <=   '0';
    end if;
  end if;
  end process;

  FB_DELAY_CAL_P0 : process (clkfb_tst, rst_in1)
  begin
     if (rst_in1 = '1')  then
         delay_edge <= 0 ps;
     elsif (rising_edge(clkfb_tst)) then
        delay_edge <= NOW;
     end if;
  end process;

  FB_DELAY_CAL_P : process (clkfb_in, rst_in1)
      variable delay_edge1 : time := 0 ps;
      variable fb_delay_tmp : time := 0 ps;
      variable Message : line;
  begin
  if (rst_in1 = '1')  then
    fb_delay  <= 0 ps;
    fb_delay_found_tmp <= '0';
    delay_edge1 := 0 ps;
    fb_delay_tmp := 0 ps;
  elsif (clkfb_in'event and clkfb_in = '1') then
     if (fb_delay_found_tmp = '0') then
         if (delay_edge /= 0 ps) then
           delay_edge1 := NOW;
           fb_delay_tmp := delay_edge1 - delay_edge;
         else
           fb_delay_tmp := 0 ps;
        end if;
        fb_delay <= fb_delay_tmp;
        fb_delay_found_tmp <= '1';
        if (rst_in1 = '0' and fb_delay_tmp > fb_delay_max) then
            Write ( Message, string'(" Warning : The feedback delay is "));
            Write ( Message, fb_delay_tmp);
            Write ( Message, string'(". It is over the maximun value "));
            Write ( Message, fb_delay_max);
            Write ( Message, '.' & LF );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
         end if;
    end if;
  end if;
  end process;

    fb_delay_found_P : process(fb_delay_found_tmp, clkvco_delay, rst_in1)
    begin
      if (rst_in1 = '1') then
        fb_delay_found <= '0';
      elsif (clkvco_delay = 0 ps) then
        fb_delay_found <= fb_delay_found_tmp after 1 ns;
      else
        fb_delay_found <= fb_delay_found_tmp after clkvco_delay;
      end if;
    end process;

--
-- generate unlock signal
--

  clk_osc_p : process(clk_osc, rst_in)
  begin
    if (rst_in = '1') then
      clk_osc <= '0';
    else
      clk_osc <= not clk_osc after OSC_P2;
    end if;
  end process;

  clkin_p_p : process 
  begin
    if (rising_edge(clkpll) or falling_edge(clkpll)) then
      clkin_p <= '1';
      wait for 100 ps;
      clkin_p <= '0';
    end if;
    wait on clkpll;
  end process;

  clkfb_p_p : process 
  begin
    if (rising_edge(clkfb_in) or falling_edge(clkfb_in)) then
      clkfb_p <= '1';
      wait for 100 ps;
      clkfb_p <= '0';
    end if;
    wait on clkfb_in;
  end process;

  clkin_stopped_p : process(clk_osc, rst_in, clkin_p)
  begin
     if (rst_in = '1' or clkin_p = '1') then
       clkin_stopped <= '0';
       clkin_lost_cnt <= 0;
     elsif (rising_edge(clk_osc)) then 
       if (locked_out = '1' and  pmcd_mode = '0') then
         if (clkin_lost_cnt < clkin_lost_val)  then
           clkin_lost_cnt <= clkin_lost_cnt + 1;
           clkin_stopped <= '0';
         else
            clkin_stopped <= '1';
         end if;
       end if;
     end if;
  end process;

  clkfb_stopped_p : process(clk_osc, rst_in, clkfb_p)
  begin
     if (rst_in = '1' or clkfb_p = '1') then
       clkfb_stopped <= '0';
       clkfb_lost_cnt <= 0;
     elsif (rising_edge(clk_osc)) then 
       --if (locked_out = '1' and  pmcd_mode = '0') then
       if (clkout_en = '1') then
         if (clkfb_lost_cnt < clkfb_lost_val)  then
           clkfb_lost_cnt <= clkfb_lost_cnt + 1;
           clkfb_stopped <= '0';
         else
            clkfb_stopped <= '1';
         end if;
       end if;
     end if;
  end process;


  CLK_JITTER_P : process (clkin_jit, rst_in)
  begin
  if (rst_in = '1') then
      clkpll_jitter_unlock <= '0';
  else
   if ( locked_out = '1' and clkfb_stopped = '0' and clkin_stopped = '0') then
      if  (ABS(clkin_jit) > ref_jitter_max_tmp) then
        clkpll_jitter_unlock <= '1';
      else
         clkpll_jitter_unlock <= '0';
      end if;
   else
         clkpll_jitter_unlock <= '0';
   end if;
  end if;
  end process;
     

   pll_unlock <= clkin_stopped or clkfb_stopped or clkpll_jitter_unlock;

  

end PLL_ADV_V;

