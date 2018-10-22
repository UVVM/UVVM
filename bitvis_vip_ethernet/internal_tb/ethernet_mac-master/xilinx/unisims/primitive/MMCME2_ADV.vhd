-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/VITAL/MMCME2_ADV.vhd,v 1.28.14.7 2013/09/18 18:11:42 robh Exp $
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
-- /___/   /\     Filename : MMCME2_ADV.vhd
-- \   \  /  \    
--  \___\/\___\
-- Revision:
--    09/09/08 - Initial version.
--    10/30/08 - Clock source switching without reset (CR492263).
--    11/18/08 - Add timing check for DADDR[6] and DADDR[5].
--    11/21/08 - Add init_done to DRP wait list.
--    12/02/08 - Fix bug of Duty cycle calculation (CR498696)
--    12/05/08 - change pll_res according to hardware spreadsheet (CR496137)
--    12/09/08 - Enable output at CLKFBOUT_MULT_F*8 for fraction mode (CR499322) 
--    01/08/09 - Add phase and duty cycle checks for fraction divide (CR501181)
--    01/09/09 - make pll_res same for BANDWIDTH=HIGH and OPTIMIZED (CR496137)
--    01/14/09 - Fine phase shift wrap around to 0 after 56 times;
--             - PSEN to PSDONE change to 12 PSCLK; RST minpusle to 5ns;
--             - add pulldown to PWRDWN pin. (CR503425)
--    01/14/09 - increase clkout_en_time  for fraction mode (CR499322) 
--    01/21/09 - align CLKFBOUT to CLKIN for fraction mode; fix bug in
--               clk0_frac_out (CR504602)
--    01/27/09 - update DRP register address (CR505271)
--    02/02/09 - add mf_product1 and m_product1 (CR506261).
--    02/05/09 - Add ps_in_ps calculation to clkvco_delay when clkfb_fps_en=1.
--               Rround clk_ht clk_lt for duty_cycle (CR506531)
--     02/11/09 - Change VCO_FREQ_MAX and MIN to 1601 and 399 to cover the rounded
--               error (CR507969)
--    02/25/09 - Round clk_ht clk_lt for duty_cycle (CR509386)
--    02/26/09 - fix for clkin and clkfbin stop case (CR503425)
--    03/04/09 - Fix for CLOCK_HOLD (CR510820).
--    03/12/09 - Not divide when CLKOUT_DIVDE=0 (CR511380)
--    03/27/09 - set default 1 to CLKINSEL pin (CR516951)
--    04/09/09 - make psdone_out same as verilog (CR518027)
--    04/13/09 - Check vco range when CLKINSEL is not connected (CR516951)
--    04/22/09 - reset clkinstopped related signals (CR519102)
--    04/27/09 - Make duty cycle of fraction mode 50/50 (CR519505)
--    05/01/09 - Add transport to clkout_ps_mux (CR520076)
--    05/13/09 - Use period_avg for clkvco_delay calculation (CR521120)
--    05/18/09 - check period_avg = 0 in  clock_period_update_p (CR522223)
--    06/02/09 - Not check RST pulse at time 0 (CR523850)
--    06/05/09 - Change clkout_en_time to mf+4 instead of mf+5 (CR524268)
--    06/25/09 - check if divider is 0 (CR525896)
--    07/27/09 - Change DIVCLK_DIVIDE maximum to 80 (CR525904)
--             - Add initial lock setting (CR524523)
--             - Update RES CP setting (CR524522)
--   08/10/09 - Calculate clkin_lost_val after lock_period=1 (CR528520)
--   08/15/09 - Update LFHF (CR524522).
--   08/20/09 - Add lock_period to clkfb_lost_val process (CR531409)
--   08/28/09 - add clkin_period_tmp_t to handle period_avg calculation 
--              when clkin has jitter (CR528520)
--   09/11/09 - Change CLKIN_FREQ_MIN to 10 Mhz (CR532774)
--   10/01/09 - Change CLKIN_FREQ_MAX to 800Mhz (CR535076)
--              Add reset check for clock switchover (CR534900)
--   10/08/09 - Change  CLKIN_FREQ MAX & MIN, CLKPFD_FREQ
--               MAX & MIN to parameter (CR535828)
--    10/14/09 - Add clkin_chk_t1 and clkin_chk_t2 to handle check (CR535662)
--   10/22/09 - Add period_vco_mf for clkvco_delay calculation (CR536951)
--              Add cmpvco to compensate period_vco rounded error (CR537073)
--   12/02/09 - not stop clkvco_lk when jitter (CR538717)
--   12/16/09 - Move deallocate statement before return statement(CR541730)
--   01/05/10 - Use real() for integer to real conversion (CR542934)
--   01/08/10 - Change RST minimum pulse width from 5 ns to 1.5 ns(543875)
--              Add 1 ns delay to locked_out_tmp when RST=1 (CR543857)
--   01/19/10 - make change to clkvoc_lk_tmp to handle M=1 case (CR544970)
--   01/25/10 - Change VCOCLK_FREQ_MIN from 400 to 600 MHz (CR545833)
--   02/12/10 - add rst_in to clkinstop related signals (CR549182)
--   02/23/10 - Not use rst edge in locked_out_tmp (CR549667)
--   03/04/10 - CHange CLKFBOUT_MULT_F range to 5-64 (CR551618)
--   03/22/10 - Change CLKFBOUT_MULT_F default to 5 (554618)
--   03/24/10 - Add SIM_DEVICE attribute
--   04/07/10 - Generate clkvco_ps_tmp2_en correctly when ps_lock_dly rising
--              and clkout_ps=1 case; increase lock_period time to 10 (CR556468)
--   04/19/10 - Using period_fb for period_vco_rm calcuclation (CR555705)
--   05/07/10 - Use period_vco_half_rm1 to reduce jitter (CR558966)
--    07/28/10 - Change ref parameter values (CR569260)
--   08/17/10 - Add Decay output clocks when input clock stopped (CR555324)
--   09/26/10 - Add RST to LOCKED timing path (CR567807)
--   11/18/10 - Add period_vco delay to clkout_en0 (CR583115)
--   02/07/11 - Change boolean type attribute to string
--   03/08/11 - Keep 0.001 resolution for CLKIN period check (CR594003)
--   03/09/11 - Support fraction mode phase shifting with phase parameter
--              setting (CR596402)
--   03/25/11 - Change boolean string back to boolean (CR603298)
--   04/25/11 - Support fraction mode phase shifting with DRP (CR607989) 
--   05/03/11 - only do duty check when clkdiv >=1 (CR608893)
--   05/24/11 - Add initial to clk0_lt_i and clk0_ht_i (CR608893)
--            - Set frac_wf_f to 1 when divide=2.125 (CR611840)
--   06/06/11 - set period_vco_half_rm2 to 0 when period_vco=0 (CR613021) 
--   06/08/11 - Disable clk0 fraction mode when CLKOUT0_DIVIDE_F in range
--              great than 1 and less than 2. Add DRC check for it (608893)
--   09/23/11 - Add clk0_div_fint_odd_v for fraction calculation (CR626524)
--   10/26/11 - Add spectrum attributes. Add DRC check for samples CLKIN 
--              period with parameter setting (CR631150)
--   11/15/11 - Do the check for samples CLKIN period at lock time (CR632943)
--   03/01/12 - fraction enable for m/d (CR 648429)
--   03/07/12 - added vcoflag (CR 638088, CR 636493)
--   03/08/12 - match clk_osc process with verilog (CR 648528)
--   04/25/12 - fix mf_product (CR 642700)
--   05/03/12 - jittery clock (CR 652401)
--   05/03/12 - incorrect period (CR 654950)
--   05/10/12 - fractional divide calculation issue (CR 658151)
--   05/18/12 - fractional divide calculation issue (CR 660657)
--   06/11/12 - update cp and res settings (CR 664278)
--   06/20/12 - modify reset drc (CR 643540)
--   06/21/12 - rounding issue with clk_out_para_cal (CR 654951)
--   09/06/12 - 655711 - modify displayed MAX on CLK_DUTY_CYCLE
--    10/17/12 - 682802 - convert GSR H/L to 1/0
--   04/04/13 - fix clkvco_frac_en for DRP (CR 709093)
--   04/09/13 - Added DRP monitor (CR 695630).
--   04/26/13 - 708790, vcoflag fix
--   05/03/13 - 670208 Fractional clock alignment issue
--   05/31/13 - 720783 - revert clock alignment fix
-- End Revision

----- CELL MMCME2_ADV -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.NUMERIC_STD.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity MMCME2_ADV is
generic (
      BANDWIDTH : string := "OPTIMIZED";
      CLKFBOUT_MULT_F : real := 5.000;
      CLKFBOUT_PHASE : real := 0.000;
      CLKFBOUT_USE_FINE_PS : boolean  := FALSE;
      CLKIN1_PERIOD : real := 0.000;
      CLKIN2_PERIOD : real := 0.000;
      CLKOUT0_DIVIDE_F : real := 1.000;
      CLKOUT0_DUTY_CYCLE : real := 0.500;
      CLKOUT0_PHASE : real := 0.000;
      CLKOUT0_USE_FINE_PS : boolean := FALSE;
      CLKOUT1_DIVIDE : integer := 1;
      CLKOUT1_DUTY_CYCLE : real := 0.500;
      CLKOUT1_PHASE : real := 0.000;
      CLKOUT1_USE_FINE_PS : boolean := FALSE;
      CLKOUT2_DIVIDE : integer := 1;
      CLKOUT2_DUTY_CYCLE : real := 0.500;
      CLKOUT2_PHASE : real := 0.000;
      CLKOUT2_USE_FINE_PS : boolean := FALSE;
      CLKOUT3_DIVIDE : integer := 1;
      CLKOUT3_DUTY_CYCLE : real := 0.500;
      CLKOUT3_PHASE : real := 0.000;
      CLKOUT3_USE_FINE_PS : boolean := FALSE;
      CLKOUT4_CASCADE : boolean := FALSE;
      CLKOUT4_DIVIDE : integer := 1;
      CLKOUT4_DUTY_CYCLE : real := 0.500;
      CLKOUT4_PHASE : real := 0.000;
      CLKOUT4_USE_FINE_PS : boolean := FALSE;
      CLKOUT5_DIVIDE : integer := 1;
      CLKOUT5_DUTY_CYCLE : real := 0.500;
      CLKOUT5_PHASE : real := 0.000;
      CLKOUT5_USE_FINE_PS : boolean := FALSE;
      CLKOUT6_DIVIDE : integer := 1;
      CLKOUT6_DUTY_CYCLE : real := 0.500;
      CLKOUT6_PHASE : real := 0.000;
      CLKOUT6_USE_FINE_PS : boolean := FALSE;
      COMPENSATION : string := "ZHOLD";
      DIVCLK_DIVIDE : integer := 1;
      REF_JITTER1 : real := 0.0;
      REF_JITTER2 : real := 0.0;
      SS_EN : string := "FALSE";
      SS_MODE : string := "CENTER_HIGH";
      SS_MOD_PERIOD : integer := 10000;
      STARTUP_WAIT : boolean := FALSE
  );
port (
      CLKFBOUT             : out std_ulogic := '0';
      CLKFBOUTB            : out std_ulogic := '0';
      CLKFBSTOPPED         : out std_ulogic := '0';
      CLKINSTOPPED         : out std_ulogic := '0';
      CLKOUT0              : out std_ulogic := '0';
      CLKOUT0B             : out std_ulogic := '0';
      CLKOUT1              : out std_ulogic := '0';
      CLKOUT1B             : out std_ulogic := '0';
      CLKOUT2              : out std_ulogic := '0';
      CLKOUT2B             : out std_ulogic := '0';
      CLKOUT3              : out std_ulogic := '0';
      CLKOUT3B             : out std_ulogic := '0';
      CLKOUT4              : out std_ulogic := '0';
      CLKOUT5              : out std_ulogic := '0';
      CLKOUT6              : out std_ulogic := '0';
      DO                   : out std_logic_vector (15 downto 0);
      DRDY                 : out std_ulogic := '0';
      LOCKED               : out std_ulogic := '0';
      PSDONE               : out std_ulogic := '0';
      CLKFBIN              : in std_ulogic;
      CLKIN1               : in std_ulogic;
      CLKIN2               : in std_ulogic;
      CLKINSEL             : in std_ulogic;
      DADDR                : in std_logic_vector(6 downto 0);
      DCLK                 : in std_ulogic;
      DEN                  : in std_ulogic;
      DI                   : in std_logic_vector(15 downto 0);
      DWE                  : in std_ulogic;
      PSCLK                : in std_ulogic;
      PSEN                 : in std_ulogic;
      PSINCDEC             : in std_ulogic;
      PWRDWN               : in std_ulogic;
      RST                  : in std_ulogic
     );
end MMCME2_ADV;


-- Architecture body --

architecture MMCME2_ADV_V of MMCME2_ADV is

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
  -- duplicate of VPKG function - could be removed
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
  if (clkdiv >= 1) then
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
        Write ( Message, string'(" of MMCME2_ADV is set to "));
        Write ( Message, clk_ps);
        Write ( Message, string'(". Required phase shifting can not be reached since it is over the maximum phase shifting ability of MMCME2_ADV"));
        Write ( Message, '.' & LF );
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
        Write ( Message, string'(" of MMCME2_ADV is set to "));
        Write ( Message, clk_ps);
        Write ( Message, string'(". Real phase shifting is "));
        Write ( Message, clk_ps_rl);
        Write ( Message, string'(". Required phase shifting can not be reached"));
        Write ( Message, '.' & LF );
        assert false report Message.all severity warning;
        DEALLOCATE (Message);
    end if;
   end if;
  end procedure clkout_dly_cal;

  procedure clkout_dly_real_cal (clkout_dly : out std_logic_vector(5 downto 0);
                          clkpm_sel : out std_logic_vector(2 downto 0);
                          clkdiv : in real;
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

     clkdiv_real := clkdiv;
     if (clk_ps < 0.0) then
        clk_dly_rl := (360.0 + clk_ps) * clkdiv_real / 360.0;
     else
        clk_dly_rl := clk_ps * clkdiv_real / 360.0;
     end if;
     clk_dly_int := real2int (clk_dly_rl);

     if (clk_dly_int > 63) then
        Write ( Message, string'(" Warning : Attribute "));
        Write ( Message, clk_ps_name );
        Write ( Message, string'(" of MMCME2_ADV is set to "));
        Write ( Message, clk_ps);
        Write ( Message, string'(". Required phase shifting can not be reached since it is over the maximum phase shifting ability of MMCME2_ADV"));
        Write ( Message, '.' & LF );
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
        Write ( Message, string'(" of MMCME2_ADV is set to "));
        Write ( Message, clk_ps);
        Write ( Message, string'(". Real phase shifting is "));
        Write ( Message, clk_ps_rl);
        Write ( Message, string'(". Required phase shifting can not be reached"));
        Write ( Message, '.' & LF );
        assert false report Message.all severity warning;
        DEALLOCATE (Message);
    end if;
  end procedure clkout_dly_real_cal;

  procedure clk_out_para_cal (clk_ht : out std_logic_vector(6 downto 0);
                            clk_lt : out std_logic_vector(6 downto 0);
                            clk_nocnt : out std_ulogic;
                            clk_edge : out std_ulogic;
                            CLKOUT_DIVIDE : in  integer;
                            CLKOUT_DUTY_CYCLE : in  real )
  is 
     variable tmp_value : real;
     variable tmp_value_tmp : real;
     variable tmp_value_r : integer;
     variable tmp_value_r2 : integer;
     variable tmp_value_r3 : real;
     variable tmp_value_r1 : real;
     variable tmp_value_r_0 : real;
     variable tmp_value_rm : real;
     variable tmp_value_rm1 : real;
     variable tmp_value0 : real;
     variable tmp_value_l: real;
     variable tmp_value2 : real;
     variable tmp_value1 : integer;
     variable clk_lt_tmp : real;
     variable clk_ht_i : integer;
     variable clk_lt_i : integer;
     variable CLKOUT_DIVIDE_real : real;
     variable tmp_value_round : integer;
     constant O_MAX_HT_LT_real : real := 64.0;
  begin
     CLKOUT_DIVIDE_real := real(CLKOUT_DIVIDE);
     tmp_value_tmp := CLKOUT_DIVIDE_real * CLKOUT_DUTY_CYCLE;
     tmp_value_r := real2int(tmp_value_tmp);
     tmp_value_r_0 := real(tmp_value_r);
     tmp_value_rm := tmp_value_tmp - tmp_value_r_0;
     if (tmp_value_rm < 0.1) then
       tmp_value := tmp_value_r_0;
     elsif (tmp_value_rm > 0.9) then
       tmp_value :=  tmp_value_r_0 + 1.0;
     else
       tmp_value_r1 := tmp_value_tmp * 2.0;
       tmp_value_r2 := real2int(tmp_value_r1);
       tmp_value_r3 := real(tmp_value_r2);
       tmp_value_rm1 := tmp_value_r1 - tmp_value_r3;
       if (tmp_value_rm1 > 0.995) then
          tmp_value := tmp_value_tmp + 0.002;
       else
          tmp_value := tmp_value_tmp;
       end if;
     end if;
      --tmp_value0 := tmp_value * 2.0;
     tmp_value_round := integer (tmp_value * 2.0);
     tmp_value1 := tmp_value_round mod 2;
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
                           daddr_in : in std_logic_vector(6 downto 0);
                           di_str : string ( 1 to 16);
                           daddr_str : string ( 1 to 7))
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
                           daddr_in : in std_logic_vector(6 downto 0);
                           di_str : string ( 1 to 16);
                           daddr_str : string ( 1 to 7))
  is
     variable  Message : line;
  begin
    if (di_in(12) /= '1')  then
      Write ( Message, string'(" Error : MMCME2_ADV input DI(15 downto 0) is set to"));
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
    variable CLK_DUTY_CYCLE_CHK : real;
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
      CLK_DUTY_CYCLE_MAX := (O_MAX_HT_LT_real      )/CLKOUT_DIVIDE_real;
      CLK_DUTY_CYCLE_CHK := (O_MAX_HT_LT_real + 0.5)/CLKOUT_DIVIDE_real;
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
      CLK_DUTY_CYCLE_CHK := 1.0;
    end if;

    if ((CLKOUT_DUTY_CYCLE > CLK_DUTY_CYCLE_CHK) or (CLKOUT_DUTY_CYCLE < CLK_DUTY_CYCLE_MIN_rnd)) then 
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
      if (abs(tmp_duty_value - CLKOUT_DUTY_CYCLE) < 0.001 and (tmp_duty_value <= CLK_DUTY_CYCLE_CHK)) then
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
        if ( (tmp_duty_value <= CLK_DUTY_CYCLE_CHK) and (tmp_duty_value < 1.0)) then
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

        constant VCOCLK_FREQ_MAX : real := 1600.0;
        constant VCOCLK_FREQ_MIN : real := 600.0;
        constant CLKIN_FREQ_MAX : real := 1066.0;
        constant CLKIN_FREQ_MIN : real := 10.0;
        constant CLKPFD_FREQ_MAX : real := 550.0;
        constant CLKPFD_FREQ_MIN : real := 10.0;
        constant VCOCLK_FREQ_TARGET : real := 1000.0;
        constant O_MAX_HT_LT : integer := 64;
        constant REF_CLK_JITTER_MAX : time := 1000 ps;
        constant REF_CLK_JITTER_SCALE : real := 0.1;
        constant MAX_FEEDBACK_DELAY : time := 10 ns;
        constant MAX_FEEDBACK_DELAY_SCALE : real := 1.0;
        constant M_MAX : real := 64.000;
        constant M_MIN : real := 2.000;
       -- constant D_MAX : integer := 128;
        constant D_MAX : integer := 106;
        constant D_MIN : integer := 1;
        constant ps_max : integer := 55;
        constant OSC_P2 : time := 250 ps;
        constant SIM_DEVICE : string := "E2XXXXX";
        constant MODULE_NAME : string  := "MMCME2_ADV";
        signal CLKFBOUT_MULT_F_RND : real := real(real2int((CLKFBOUT_MULT_F + 0.0625) * 8.0))/ 8.0;
        signal CLKOUT0_DIVIDE_F_RND : real := real(real2int((CLKOUT0_DIVIDE_F + 0.0625) * 8.0))/ 8.0;
 
        signal   pll_lock_time : integer;
        signal   lock_period_time : integer;  

        signal   CLKIN1_ipd  :  std_ulogic;
        signal   CLKIN2_ipd  :  std_ulogic;
        signal   CLKFBIN_ipd  :  std_ulogic;
        signal   RST_ipd  :  std_ulogic;
        signal   CLKINSEL_ipd  :  std_ulogic;
        signal   DADDR_ipd  :  std_logic_vector(6 downto 0);
        signal   DI_ipd  :  std_logic_vector(15 downto 0);
        signal   DWE_ipd  :  std_ulogic;
        signal   DEN_ipd  :  std_ulogic;
        signal   DCLK_ipd  :  std_ulogic;
        signal   PSINCDEC_ipd  :  std_ulogic;
        signal   PSEN_ipd  :  std_ulogic;
        signal   PSCLK_ipd  :  std_ulogic;
        signal   PWRDWN_ipd  :  std_ulogic;
        signal   GSR_dly      : std_ulogic := '0';
        signal   CLKOUT0_out  :  std_ulogic := '0';
        signal   CLKOUT1_out  :  std_ulogic := '0';
        signal   CLKOUT2_out  :  std_ulogic := '0';
        signal   CLKOUT3_out  :  std_ulogic := '0';
        signal   CLKOUT4_out  :  std_ulogic := '0';
        signal   CLKOUT5_out  :  std_ulogic := '0';
        signal   CLKOUT6_out  :  std_ulogic := '0';
        signal   CLKFBSTOPPED_out  :  std_ulogic := '0';
        signal   CLKINSTOPPED_out  :  std_ulogic := '0';
        signal   CLKINSTOPPED_out_dly  :  std_ulogic := '0';
        signal   CLKINSTOPPED_out_dly2  :  std_ulogic := '0';
        signal   clkin_stop_f :  std_ulogic := '0';
        signal   psen_w : std_ulogic := '0';
        signal   period_avg_stpi : time := 0 ps;
        signal   period_avg_stp : time := 0 ps;
        signal   vco_stp_f : std_ulogic := '0';
        signal   pd_stp_p : std_ulogic := '0';
        signal   CLKFBSTOPPED_out1  :  std_ulogic := '0';
        signal   CLKINSTOPPED_out1  :  std_ulogic := '0';
        signal   LOCKED_out  :  std_ulogic := '0';
        signal   LOCKED_out_tmp  :  std_ulogic := '0';
        signal   do_out  :  std_logic_vector(15 downto 0);
        signal   DRDY_out  :  std_ulogic := '0';
        signal   PSDONE_out  :  std_ulogic := '0';
        signal   CLKIN1_dly  :  std_ulogic;
        signal   CLKIN2_dly  :  std_ulogic;
        signal   CLKFBIN_dly  :  std_ulogic;
        signal   RST_dly  :  std_ulogic;
        signal   PWRDEN_dly  :  std_ulogic;
        signal   CLKINSEL_dly  :  std_ulogic;
        signal   DADDR_dly  :  std_logic_vector(6 downto 0);
        signal   DI_dly  :  std_logic_vector(15 downto 0);
        signal   DWE_dly  :  std_ulogic;
        signal   DEN_dly  :  std_ulogic;
        signal   DCLK_dly  :  std_ulogic;
        signal   PSINCDEC_dly  :  std_ulogic;
        signal   PSEN_dly  :  std_ulogic;
        signal   PSCLK_dly  :  std_ulogic;

        signal di_in : std_logic_vector (15 downto 0);
        signal dwe_in : std_ulogic := '0';
        signal den_in : std_ulogic := '0';
        signal dclk_in : std_ulogic := '0';
        signal psincdec_in : std_ulogic := '0';
        signal psen_in : std_ulogic := '0';
        signal psclk_in : std_ulogic := '0';
        signal rst_in : std_ulogic := '0';
        signal rst_in_o : std_ulogic := '0';
        signal pwrdwn_in : std_ulogic := '0';
        signal pwrdwn_in1 : std_ulogic := '0';
        signal pwrdwn_in1_h : std_ulogic := '0';
        signal pwron_int : std_ulogic := '1';
        signal rst_input : std_ulogic := '0';
        signal rst_input_r : std_ulogic := '0';
        signal rst_input_r_h : std_ulogic := '0';
        signal pchk_clr : std_ulogic := '0';
        signal clkinstopped_in : std_ulogic := '0';
        signal clkfbstopped_in : std_ulogic := '0';
        signal clkfb_in : std_ulogic := '0';
        signal clkin1_in : std_ulogic := '0';
        signal clkin1_in_dly : std_ulogic := '0';
        signal clkin2_in : std_ulogic := '0';
        signal clkinsel_in : std_ulogic := '0';
        signal clkinsel_tmp : std_ulogic := '0';
        signal daddr_in :  std_logic_vector(6 downto 0);
        signal daddr_in_lat :  integer := 0;
        signal drp_lock :  std_ulogic := '0';
        signal drp_lock1  :  std_ulogic := '0';
        type   drp_array is array (127 downto 0) of std_logic_vector(15 downto 0);
        signal dr_sram : drp_array;
        
        signal clk0in :  std_ulogic := '0';
        signal clk1in :  std_ulogic := '0';
        signal clk2in :  std_ulogic := '0';
        signal clk3in :  std_ulogic := '0';
        signal clk4in :  std_ulogic := '0';
        signal clk5in :  std_ulogic := '0';
        signal clk6in :  std_ulogic := '0';
        signal clkfbm1in :  std_ulogic := '0';
        signal clkfbm2in :  std_ulogic := '0';
        signal clk0_out :  std_ulogic := '0';
        signal clk1_out :  std_ulogic := '0';
        signal clk2_out :  std_ulogic := '0';
        signal clk3_out :  std_ulogic := '0';
        signal clk4_out :  std_ulogic := '0';
        signal clk5_out :  std_ulogic := '0';
        signal clk6_out :  std_ulogic := '0';
        signal clkfb_out :  std_ulogic := '0';
        signal clkind_out :  std_ulogic := '0';
        signal clkfbm1_out :  std_ulogic := '0';
        signal clkfbm2_out :  std_ulogic := '0';
        signal clkout_en :  std_ulogic := '0';
        signal clkout_en1 :  std_ulogic := '0';
        signal clkout_en0 :  std_ulogic := '0';
        signal clkout_en0_tmp :  std_ulogic := '0';
        signal clkout_en0_tmp1 :  std_ulogic := '0';
        signal clkout_en_t : integer := 0;
        signal clkout_en_val : integer := 0;
        signal clkout_cnt : integer := 0;
        signal clkin_cnt : integer := 0;
        signal clkin_lock_cnt : integer := 0;
        signal clkout_en_time : integer := 12;
        signal locked_en_time : integer := 10;
        signal lock_cnt_max : integer := 30;
        signal clkvco_lk :  std_ulogic := '0';
        signal clkvco_lk_tmp2 :  std_ulogic := '0';
        signal clkvco_lk_dly_tmp :  std_ulogic := '0';
        signal clkvco_lk_en :  std_ulogic := '0';
        signal clkvco_lk_osc :  std_ulogic := '0';
        signal clkvco_lk_rst :  std_ulogic := '0';
        signal clkvco_free :  std_ulogic := '0';
        signal clkvco :  std_ulogic := '0';
        signal fbclk_tmp :  std_ulogic := '0';
        signal dly_tmp_o : time := 0 ps; 
        signal clkfb_div_frac_int : integer := 0;
        signal  clk0_div_frac_int : integer := 0;
        signal clkfb_div_fint     : integer := 0;
        signal clkfb_div_fint_odd     : integer := 0;
        signal clkfbm1_div_t     : real := 1.000;
        signal clk0_div_fint      : integer := 0;
        signal clk0_div_fint_odd      : integer := 0;
        signal clkfb_div_frac     : real := 0.0;
        signal clk0_div_frac      : real := 0.0;
        signal clk0_frac_out      :  std_ulogic := '0';
        signal clkfbm1_frac_out   :  std_ulogic := '0';
        signal clk0_nf_out        :  std_ulogic := '0';
        signal clkfbm1_nf_out     :  std_ulogic := '0';
        signal clk0_frac_en       : integer := 0;        
        signal clk0_frac_en_i       : integer := 0;        
        signal clkfbout_frac_wf_f :  std_ulogic;
        signal clkfbout_frac_wf_r :  std_ulogic;
        signal clk0_frac_wf_f :  std_ulogic;
        signal clk0_frac_wf_r :  std_ulogic;
        signal clkfb_frac_en       : integer := 0;        
        signal clkfb_frac_en_i       : integer := 0;        
        signal clkvco_frac_en      : integer := 0;
        signal clkfb_frac         : integer := 0;
        signal clkfb_frac_i         : integer := 0;
        signal clk0_frac         : integer := 0;
        signal clk0_frac_i         : integer := 0;
        signal ps_in_init         : integer := 0;
        signal init_done          : std_ulogic := '0';
        signal pvco_init_f        : std_ulogic := '0';
        signal clk0_fps_en        : integer := 0;
        signal clk1_fps_en        : integer := 0;
        signal clk2_fps_en        : integer := 0;
        signal clk3_fps_en        : integer := 0;
        signal clk4_fps_en        : integer := 0;
        signal clk5_fps_en        : integer := 0;
        signal clk6_fps_en        : integer := 0;
        signal clkfb_fps_en       : integer := 0;
        signal fps_en             : integer := 0;
        signal clkfb_stop_tmp   :  std_ulogic := '0';
        signal clkin_stop_tmp   :  std_ulogic := '0';
        signal clkinstopped_hold     :  std_ulogic := '0';
        signal clkin_hold_f     :  integer := 0;
        signal ps_in_ps           : integer := 0;
        signal ps_cnt           : integer := 0;
        signal clkout4_cascade_int : integer := 0;
        signal clkout_ps        :  std_ulogic := '0';
        signal clkout_ps_tmp1        :  std_ulogic := '0';
        signal clkout_ps_tmp2        :  std_ulogic := '0';
        signal clkout_ps_t1        :  std_ulogic := '0';
        signal clkout_ps_t2        :  std_ulogic := '0';

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
        signal clkin_period : real_array_usr := (others => 0 ps);
        signal period_vco_en : time := 0 ps;
        signal period_vco : time := 0 ps;
        signal period_vco_frl : time := 0 ps;
        signal period_vco_mf : integer := 0;
        signal period_vco_rm : integer := 0;
        signal period_vco_cmp_cnt : integer := 0;
        signal clkvco_tm_cnt : integer := 0;
        signal period_vco_cmp_flag : integer := 0;
        signal period_vco1 : time := 0 ps;
        signal period_vco2 : time := 0 ps;
        signal period_vco3 : time := 0 ps;
        signal period_vco4 : time := 0 ps;
        signal period_vco5 : time := 0 ps;
        signal period_vco6 : time := 0 ps;
        signal period_vco7 : time := 0 ps;
        signal period_vco_half : time := 0 ps;
        signal period_vco_half1 : time := 0 ps;
        signal period_vco_half_rm : time := 0 ps;
        signal period_vco_half_rm1 : time := 0 ps;
        signal period_vco_half_rm2 : time := 0 ps;
        signal clkvco_pdrm : real := 0.0;
        constant period_vco_max : time :=  1000 ps / VCOCLK_FREQ_MIN;
        constant period_vco_min : time :=  1000 ps / VCOCLK_FREQ_MAX;
        constant period_vco_target : time :=   1000 ps / VCOCLK_FREQ_TARGET;
        constant period_vco_target_half : time :=  500 ps / VCOCLK_FREQ_TARGET;
        signal period_fb : time := 0 ps;
        signal period_avg : time := 0 ps;

        signal clkfb_stop_max : integer := 3;
        signal clkin_stop_max : integer := DIVCLK_DIVIDE + 1;
        signal md_product : integer := 0;
        signal m_product : integer := 0;
        signal m_product1 : integer := 0;
        signal m_product2 : integer := 0;

        signal pll_locked_delay : time := 0 ps;
        signal clkin_dly_t : time := 0 ps;
        signal clkfb_dly_t : time := 0 ps;
        signal clkfb_in_dly : std_ulogic := '0';
        signal pll_unlock : std_ulogic := '0';
        signal pll_unlock1 : std_ulogic := '0';
        signal pll_unlock1_tmp : std_ulogic := '0';
        signal pll_locked_tm : std_ulogic := '0';
        signal pll_locked_tmp1 : std_ulogic := '0';
        signal pll_locked_tmp2 : std_ulogic := '0';
        signal lock_period : std_ulogic := '0';
        signal pll_lock_tm: std_ulogic := '0';
        signal unlock_recover : std_ulogic := '0';
        signal clkin_stopped : std_ulogic := '0';
        signal clkfb_stopped : std_ulogic := '0';
        signal clkpll_jitter_unlock : std_ulogic := '0';
        signal clkin_jit : time := 0 ps;
        constant ref_jitter_max_tmp : time := REF_CLK_JITTER_MAX;
        
        signal clk0ps_en : std_ulogic := '0';
        signal clk1ps_en : std_ulogic := '0';
        signal clk2ps_en : std_ulogic := '0';
        signal clk3ps_en : std_ulogic := '0';
        signal clk4ps_en : std_ulogic := '0';
        signal clk5ps_en : std_ulogic := '0';
        signal clk6ps_en : std_ulogic := '0';
        signal clkfbm1ps_en : std_ulogic := '0';
        signal clkout_mux : std_logic_vector (7 downto 0) := X"00";
        signal clkout_ps_mux : std_logic_vector (7 downto 0) := X"00";
        signal clk0_sel_mux : std_logic_vector (7 downto 0) := X"00";
        signal clkfb_sel_mux : std_logic_vector (7 downto 0) := X"00";
        signal clk0pm_sel : integer := 0;
        signal clk0pm_rsel : integer := 0;
        signal clk0pm_fsel : integer := 0;
        signal clk0pmf_sel : integer := 0;
        signal clk0pmf_sel_i : integer := 0;
        signal clk0pmr_sel : integer := 0;
        signal clk0pmr_sel_i : integer := 0;
        signal clk0pm_sel1 : integer := 0;
        signal clk1pm_sel : integer := 0;
        signal clk2pm_sel : integer := 0;
        signal clk3pm_sel : integer := 0; 
        signal clk4pm_sel : integer := 0;
        signal clk5pm_sel : integer := 0;
        signal clk5fpm_sel : integer := 0;
        signal clk6pm_sel : integer := 0;
        signal clk6fpm_sel : integer := 0;
        signal clk5pm_sel1 : integer := 0;
        signal clk6pm_sel1 : integer := 0;
        signal clkfbm1pm_sel : integer := 0;
        signal clkfbm1pm_sel_int : integer := 0;
        signal clk0pm_sel_int : integer := 0;
        signal clkfbm1pmf_sel : integer := 0;
        signal clkfbpmf_sel_i : integer := 0;
        signal clkfbm1pmr_sel : integer := 0;
        signal clkfbpmr_sel_i : integer := 0;
        signal clkfbm1r_sel : integer := 0;
        signal clkfbm1f_sel : integer := 0;
        signal clkfbm1pm_sel1 : integer := 0;
        signal clkfbm1pm_rl : real := 0.0;
        signal clk0_edge  : std_ulogic := '0';
        signal clk1_edge  : std_ulogic := '0';
        signal clk2_edge  : std_ulogic := '0';
        signal clk3_edge  : std_ulogic := '0';
        signal clk4_edge  : std_ulogic := '0';
        signal clk5_edge  : std_ulogic := '0';
        signal clk6_edge  : std_ulogic := '0';
        signal clkfbm1_edge  : std_ulogic := '0';
        signal clkfbm2_edge  : std_ulogic := '0';
        signal clkind_edge  : std_ulogic := '0';
        signal clk0_nocnt  : std_ulogic := '0';
        signal clk1_nocnt  : std_ulogic := '0';
        signal clk2_nocnt  : std_ulogic := '0';
        signal clk3_nocnt  : std_ulogic := '0';
        signal clk4_nocnt  : std_ulogic := '0';
        signal clk5_nocnt  : std_ulogic := '0';
        signal clk6_nocnt  : std_ulogic := '0';
        signal clkfbm1_nocnt  : std_ulogic := '0';
        signal clkfbm2_nocnt  : std_ulogic := '0';
        signal clkind_nocnt  : std_ulogic := '0';
        signal clk0_dly_cnt : integer := 0;
        signal clk1_dly_cnt : integer := 0;
        signal clk2_dly_cnt : integer := 0;
        signal clk3_dly_cnt : integer := 0;
        signal clk4_dly_cnt : integer := 0;
        signal clk5_dly_cnt : integer := 0;
        signal clk6_dly_cnt : integer := 0;
        signal clkfbm1_dly_cnt : integer := 0;
        signal clk0_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk0_ht_i : integer := 0;
        signal clk1_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk2_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk3_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk4_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk5_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk6_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm1_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm1_ht_i : integer := 0;
        signal clkfbm1_fht : integer := 0;
        signal clkfbm1_flt : integer := 0;
        signal clk0_fht : integer := 0;
        signal clk0_flt : integer := 0;
        signal clkfbm2_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clk0_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk0_lt_i : integer := 0;
        signal clk1_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk2_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk3_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk4_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk5_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk6_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm1_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clkfbm1_lt_i : integer := 0;
        signal clkfbm2_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clkout0_dly : integer := 0;
        signal clkout0_rdly : integer := 0;
        signal clkout0_fdly : integer := 0;
        signal clkout1_dly : integer := 0;
        signal clkout2_dly : integer := 0;
        signal clkout3_dly : integer := 0;
        signal clkout4_dly : integer := 0;
        signal clkout5_dly : integer := 0;
        signal clkout5f_dly : integer := 0;
        signal clkout6_dly : integer := 0;
        signal clkout6f_dly : integer := 0;
        signal clkfbm1_dly : integer := 0;
        signal clkfbm1_rdly : integer := 0;
        signal clkfbm1_fdly : integer := 0;
        signal clkind_ht : std_logic_vector (6 downto 0) := "0000000";
        signal clkind_lt : std_logic_vector (6 downto 0) := "0000000";
        signal clk0_ht1 : integer := 0;
        signal clk1_ht1 : integer := 0;
        signal clk2_ht1 : integer := 0;
        signal clk3_ht1 : integer := 0;
        signal clk4_ht1 : integer := 0;
        signal clk5_ht1 : integer := 0;
        signal clk6_ht1 : integer := 0;
        signal clkfbm1_ht1 : integer := 0;
        signal clkfbm2_ht1 : integer := 0;
        signal clkind_ht1 : integer := 0;
        signal clk0_cnt : integer := 0;
        signal clk1_cnt : integer := 0;
        signal clk2_cnt : integer := 0;
        signal clk3_cnt : integer := 0;
        signal clk4_cnt : integer := 0;
        signal clk5_cnt : integer := 0;
        signal clk6_cnt : integer := 0;
        signal clkind_cnt : integer := 0;
        signal clkfbm1_cnt : integer := 0;
        signal clkfbm2_cnt : integer := 0;
        signal clk0_div : integer := 1;
        signal clk1_div : integer := 1;
        signal clk2_div : integer := 1;
        signal clk3_div : integer := 1;
        signal clk4_div : integer := 1;
        signal clk5_div : integer := 1;
        signal clk6_div : integer := 1;
        signal clkfbm1_div : integer := 1;
        signal clkfbm1_f_div : real := 1.0;
        signal clkfbm2_div : integer := 1;
        signal clk0_div1 : integer := 0;
        signal clk1_div1 : integer := 0;
        signal clk2_div1 : integer := 0;
        signal clk3_div1 : integer := 0;
        signal clk4_div1 : integer := 0;
        signal clk5_div1 : integer := 0;
        signal clk6_div1 : integer := 0;
        signal clkfbm1_div1 : integer := 0;
        signal clkfbm2_div1 : integer := 0;
        signal clkind_div : integer := 1;
        signal clkind_div1 : integer := 0;
        
        signal clkvco_lk_tmp : std_ulogic := '0';
        signal clkinstopped_vco_f : std_ulogic := '0';
        signal clkin_period_tmp : real := 0.0;
        signal clk0_frac_lt : time := 50 ps;
        signal clk0_frac_ht : time := 50 ps;
        signal clkfb_frac_lt : time := 50 ps;
        signal clkfb_frac_ht : time := 50 ps;
        signal clk0_frac_out_en : integer := 0;
        signal clkfb_frac_out_en : integer := 0;
        signal clk0_frac_out_init : std_ulogic := '1';
        signal clkfb_frac_out_init : std_ulogic := '1';
        signal period_ps : time := 0 ps;
        signal period_ps_old : time := 0 ps;
        signal clkvco_ps_tmp2_en : std_ulogic := '0';
        signal clkout_ps_eg : time := 0 ps;
        signal clkout_ps_peg : time := 0 ps;
        signal ps_lock : std_ulogic := '0';
        signal ps_lock_dly : std_ulogic := '0';
        signal mf_product : integer := 0;
        signal mf_product1 : integer := 0;
        signal clkpll_tmp1 : std_ulogic := '0';
        signal clkpll_tmp2 : std_ulogic := '0';
        signal clkpll_tmp3 : std_ulogic := '0';
        signal clkpll : std_ulogic := '0';
        signal clkpll_r : std_ulogic := '0';
        signal orig_rst_in : std_ulogic := '0';
        signal rst_clkinstopped : std_ulogic := '0';
        signal rst_clkinstopped_rc : std_ulogic := '0';
        signal rst_clkinstopped_tm : std_ulogic := '0';
        signal rst_clkfbstopped : std_ulogic := '0';
        signal rst_clkinstopped_lk : std_ulogic := '0';
        signal clkin_lost_cnt : integer := 0; 
        signal clkfb_lost_cnt : integer := 0; 
        signal clk_osc :  std_ulogic := '0';
        signal clkin_p :  std_ulogic := '0';
        signal clkfb_p :  std_ulogic := '0';
        signal clkin_lost_val : integer := 500;
        signal clkfb_lost_val : integer := 500;
        signal clkfb_div_adj : integer := 0;
        signal clkfb_div_check_diff : real := 0.0;
        signal clk0_div_check_diff : real := 0.0;
        signal clk0_div_adj : integer := 0;
        signal rst_clkinsel_flag : std_ulogic := '0';
        signal CLKOUT0_USE_FINE_PS_BINARY : std_ulogic;
        signal CLKOUT1_USE_FINE_PS_BINARY : std_ulogic;
        signal CLKOUT2_USE_FINE_PS_BINARY : std_ulogic;
        signal CLKOUT3_USE_FINE_PS_BINARY : std_ulogic;
        signal CLKOUT4_USE_FINE_PS_BINARY : std_ulogic;
        signal CLKOUT5_USE_FINE_PS_BINARY : std_ulogic;
        signal CLKOUT6_USE_FINE_PS_BINARY : std_ulogic;
        signal CLKOUT4_CASCADE_BINARY : std_ulogic;
        signal CLKFBOUT_USE_FINE_PS_BINARY : std_ulogic;
        signal STARTUP_WAIT_BINARY : std_ulogic;

  begin

        CLKOUT0 <=  clkout0_out;
        CLKOUT1 <=  clkout1_out;
        CLKOUT2 <=  clkout2_out;
        CLKOUT3 <=   clkout3_out;
        CLKOUT4 <=   clkout4_out;
        CLKOUT5 <=   clkout5_out;
        CLKOUT6 <=   clkout6_out;
        CLKFBOUT <=   clkfb_out;
        CLKFBOUTB <=   not clkfb_out;
        CLKOUT0B <=  not clkout0_out;
        CLKOUT1B <=  not clkout1_out;
        CLKOUT2B <=  not clkout2_out;
        CLKOUT3B <=   not clkout3_out;

        unisim.VCOMPONENTS.PLL_LOCKG <= '0' when (STARTUP_WAIT_BINARY = '1' and locked_out_tmp = '0') else 'H';

        DO <=   do_out(15 downto 0);
        DRDY <=   DRDY_out after 100 ps;
        PSDONE <=   psdone_out after 100 ps;
        LOCKED <= locked_out_tmp after 100 ps;
        CLKINSTOPPED <= clkinstopped_out1;
        CLKFBSTOPPED <= clkfbstopped_out1;

        clkin1_in <= CLKIN1;
        clkin2_in <= CLKIN2;
        clkinsel_in <= '1' when CLKINSEL /= '0' else '0';
        clkfb_in <= CLKFBIN;
        clkin1_in_dly <= CLKIN1;
        daddr_in(6 downto 0) <= DADDR(6 downto 0);
        di_in(15 downto 0) <= DI(15 downto 0);
        dwe_in <= DWE;
        den_in <= DEN;
        dclk_in <= DCLK;
        psclk_in <= PSCLK;
        psen_in <= PSEN;
        psincdec_in <= PSINCDEC;
        pwrdwn_in <= PWRDWN;
        rst_input_r <= RST;
        GSR_dly <= TO_X01(GSR);

drp_monitor: process (dclk_in)

     variable drpen_r1 : std_logic := '0';
     variable drpen_r2 : std_logic := '0';
     variable drpwe_r1 : std_logic := '0';
     variable drpwe_r2 : std_logic := '0';
     type statetype is (FSM_IDLE, FSM_WAIT);
     variable sfsm : statetype := FSM_IDLE;

   begin  -- process drp_monitor

     if (rising_edge(dclk_in)) then

       -- pipeline the DEN and DWE
       drpen_r2 := drpen_r1;
       drpwe_r2 := drpwe_r1;
       drpen_r1 := den_in;
       drpwe_r1 := dwe_in;
    
    
       -- Check -  if DEN or DWE is more than 1 DCLK
       if ((drpen_r1 = '1') and (drpen_r2 = '1')) then 
         assert false
           report "DRC Error : DEN is high for more than 1 DCLK."
           severity failure;
       end if;
       
       if ((drpwe_r1 = '1') and (drpwe_r2 = '1')) then 
         assert false
           report "DRC Error : DWE is high for more than 1 DCLK."
           severity failure;
       end if;

       
       -- After the 1st DEN pulse, check the DEN and DRDY.
       case sfsm is
         when FSM_IDLE =>
           if (den_in = '1') then 
             sfsm := FSM_WAIT;
           end if;
           
         when FSM_WAIT =>

           -- After the 1st DEN, 4 cases can happen
           -- DEN DRDY NEXT STATE
           -- 0     0      FSM_WAIT - wait for DRDY
           -- 0     1      FSM_IDLE - normal operation
           -- 1     0      FSM_WAIT - display error and wait for DRDY
           -- 1     1      FSM_WAIT - normal operation. Per UG470, DEN and DRDY can be at the same cycle.;                       
           -- Add the check for another DPREN pulse
           if(den_in = '1' and drdy_out = '0') then 
             assert false
               report "DRC Error :  DEN is enabled before DRDY returns."
               severity failure;
           end if;

           -- Add the check for another DWE pulse
           if ((dwe_in = '1') and (den_in = '0')) then
             assert false
               report "DRC Error :  DWE is enabled before DRDY returns."
               severity failure;
           end if;
                    
           if ((drdy_out = '1') and (den_in = '0')) then
             sfsm := FSM_IDLE;
           end if;
             
               
           if ((drdy_out = '1') and (den_in = '1')) then
             sfsm := FSM_WAIT;
           end if;


         when others =>
           assert false
             report "DRC Error : Default state in DRP FSM."
             severity failure;

       end case;
    
     end if;

   end process drp_monitor;

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
            variable CLKOUT6_DIVIDE_real : real;
            variable tmp_j : real;
            variable tmp_duty_value : real;
            variable clk_ht_i : std_logic_vector(5 downto 0);
            variable clk_lt_i : std_logic_vector(5 downto 0);
            variable clk_nocnt_i : std_ulogic;
            variable clk_edge_i : std_ulogic;
            variable clkfbm1_f_div_v : real := 1.0;
            variable clkfb_div_fint_v : integer := 1;
            variable clkfb_div_fint_v_tmp : integer := 1;
            variable clkfb_div_fint_v1 : real := 1.0;
            variable clkfb_div_frac_v : real := 0.0;
            variable clkfb_div_frac_int_v : integer := 0;
            variable mf_product_v : integer := 0;
            variable clk0_div_fint_v : integer := 1;
            variable clk0_div_fint_v_tmp : integer := 1;
            variable clk0_div_fint_v1 : real := 1.0;
            variable clk0_div_frac_v : real := 0.0;
            variable clkvco_var : real := 1.0;
            variable clk0_div_frac_int_v : integer := 0;
            variable clk0_frac_v : integer := 0;
            variable ps_in_init_v : integer := 0;
            variable lock_en_tmp1_rl : real := 0.0;
            variable lock_en_tmp2_rl : real := 0.0;
            variable lock_en_tmp3_int : integer := 0;
            variable clkfb_fps_eni : integer;
            variable clk0_fps_eni : integer;
            variable clk1_fps_eni : integer;
            variable clk2_fps_eni : integer;
            variable clk3_fps_eni : integer;
            variable clk4_fps_eni : integer;
            variable clk5_fps_eni : integer;
            variable clk6_fps_eni : integer;
            variable clkout_en_time_i : integer;
            variable clkout_en_time_i1 : integer;
            variable clkfb_sdivide : real := 1.0;
            variable clkfb_sdivide_int : integer := 1;
            variable clkfb_sevent_part_high : integer := 1;
            variable clkfb_sevent_part_low : integer := 1;
            variable clkfb_sodd : integer := 0;
            variable clkfb_sodd_and_frac : integer := 0;
            variable clkfb_sfrac_2 : integer := 0;
            variable clk0_sdivide : real := 1.0;
            variable clk0_sdivide_int : integer := 1;
            variable clk0_sevent_part_high : integer := 1;
            variable clk0_sevent_part_low : integer := 1;
            variable clk0_sodd : integer := 0;
            variable clk0_sodd_and_frac : integer := 0;
            variable clk0_sfrac_2 : integer := 0;
            variable clkfb_div_fint_odd_v : integer := 0;
            variable clk0_div_fint_odd_v : integer := 0;
            variable clkfb_frac_v : integer := 0; 
            variable clkfb_frac_en_v : integer := 0;
            variable clk0_frac_en_v : integer := 0;
            variable clkvco_div_fint1 :  real := 0.0;
            variable clkvco_div_fint : integer := 0;
            variable clkvco_div_frac :  real := 0.0;
            variable clkfb_div_check_v : real := 0.0;
            variable clkfb_div_check_diff_v : real := 0.0;
            variable clk0_div_check_v : real :=0.0;
            variable clk0_div_check_diff_v : real :=0.0;
            variable clkfb_div_check_int_v : integer := 0;
            variable clk0_div_check_int_v : integer := 0;
            variable clkfb_div_adj_v : integer := 0;
            variable clk0_div_adj_v : integer := 0;
            
        begin
           if((COMPENSATION /= "ZHOLD") and (COMPENSATION /= "zhold") and
                 (COMPENSATION /= "BUF_IN") and (COMPENSATION /= "buf_in") and
                 (COMPENSATION /= "EXTERNAL") and (COMPENSATION /= "external") and
                 (COMPENSATION /= "INTERNAL") and (COMPENSATION /= "internal")) then 
             assert FALSE report " Attribute Syntax Error : The Attribute COMPENSATION must be set to ZHOLD or BUF_IN or  EXTERNAL or INTERNAL." severity error;
            end if;

           if((BANDWIDTH /= "HIGH") and (BANDWIDTH /= "high") and
                 (BANDWIDTH /= "LOW") and (BANDWIDTH /= "low") and
                 (BANDWIDTH /= "OPTIMIZED") and (BANDWIDTH /= "optimized")) then
             assert FALSE report "Attribute Syntax Error : BANDWIDTH  is not HIGH, LOW, OPTIMIZED." severity error;
            end if;

       if (CLKFBOUT_USE_FINE_PS = FALSE or CLKFBOUT_USE_FINE_PS = false) then
             clkfb_fps_en <= 0;
             clkfb_fps_eni := 0;
       elsif (CLKFBOUT_USE_FINE_PS = TRUE or CLKFBOUT_USE_FINE_PS = true) then
             clkfb_fps_en <= 1;
             clkfb_fps_eni := 1;
       else
             assert FALSE report " Attribute Syntax Error : The Attribute CLKFBOUT_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;

       if (CLKOUT0_USE_FINE_PS = FALSE or CLKOUT0_USE_FINE_PS = false) then
             clk0_fps_en <= 0;
             clk0_fps_eni := 0;
       elsif (CLKOUT0_USE_FINE_PS = TRUE or CLKOUT0_USE_FINE_PS = true) then
             clk0_fps_en <= 1;
             clk0_fps_eni := 1;
       else
            assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT0_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;

       if (CLKOUT1_USE_FINE_PS = FALSE or CLKOUT1_USE_FINE_PS = false) then
             clk1_fps_en <= 0;
             clk1_fps_eni := 0;
       elsif (CLKOUT1_USE_FINE_PS = TRUE or CLKOUT1_USE_FINE_PS = true) then
             clk1_fps_en <= 1;
             clk1_fps_eni := 1;
       else
            assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT1_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;

       if (CLKOUT2_USE_FINE_PS = FALSE or CLKOUT2_USE_FINE_PS = false) then
             clk2_fps_en <= 0;
             clk2_fps_eni := 0;
       elsif (CLKOUT2_USE_FINE_PS = TRUE or CLKOUT2_USE_FINE_PS = true) then
             clk2_fps_en <= 1;
             clk2_fps_eni := 1;
       else
            assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT2_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;

       if (CLKOUT3_USE_FINE_PS = FALSE or CLKOUT3_USE_FINE_PS = false) then
             clk3_fps_en <= 0;
             clk3_fps_eni := 0;
       elsif (CLKOUT3_USE_FINE_PS = TRUE or CLKOUT3_USE_FINE_PS = true) then
             clk3_fps_en <= 1;
             clk3_fps_eni := 1;
       else
            assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT3_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;

       if (CLKOUT4_USE_FINE_PS = FALSE or CLKOUT4_USE_FINE_PS = false) then
             clk4_fps_en <= 0;
             clk4_fps_eni := 0;
       elsif (CLKOUT4_USE_FINE_PS = TRUE or CLKOUT4_USE_FINE_PS = true) then
             clk4_fps_en <= 1;
             clk4_fps_eni := 1;
       else
            assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT4_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;

       if (CLKOUT5_USE_FINE_PS = FALSE or CLKOUT5_USE_FINE_PS = false) then
             clk5_fps_en <= 0;
             clk5_fps_eni := 0;
       elsif (CLKOUT5_USE_FINE_PS = TRUE or CLKOUT5_USE_FINE_PS = true) then
             clk5_fps_en <= 1;
             clk5_fps_eni := 1;
       else
            assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT5_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;

       if (CLKOUT6_USE_FINE_PS = FALSE or CLKOUT6_USE_FINE_PS = false) then
             clk6_fps_en <= 0;
             clk6_fps_eni := 0;
       elsif (CLKOUT6_USE_FINE_PS = TRUE or CLKOUT6_USE_FINE_PS = true) then
             clk6_fps_en <= 1;
             clk6_fps_eni := 1;
       else
            assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT6_USE_FINE_PS must be set to FALSE or TRUE." severity error;
       end if;


       if (clkfb_fps_eni=1 or clk0_fps_eni=1 or clk1_fps_eni=1 or clk2_fps_eni=1
          or clk3_fps_eni=1 or clk4_fps_eni=1 or clk5_fps_eni=1 or clk6_fps_eni=1) then
          fps_en <= 1;
       end if;

       clkin_hold_f <= 0;

--       case CLOCK_HOLD is
--           when FALSE   =>  clkin_hold_f <= 0;
--           when TRUE    =>  clkin_hold_f  <= 1;
--           when others  =>  assert FALSE report " Attribute Syntax Error : The Attribute CLOCK_HOLD must be set to FALSE or TRUE." severity error;
--       end case;

       if (CLKOUT4_CASCADE = FALSE or CLKOUT4_CASCADE = false) then
             clkout4_cascade_int <= 0;
       elsif (CLKOUT4_CASCADE = TRUE or CLKOUT4_CASCADE = true) then
             clkout4_cascade_int  <= 1;
       else
           assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT4_CASCADE must be set to FALSE or TRUE." severity error;
       end if;

      if((STARTUP_WAIT = FALSE) or (STARTUP_WAIT = false)) then
        STARTUP_WAIT_BINARY <= '0';
      elsif((STARTUP_WAIT = TRUE) or (STARTUP_WAIT= true)) then
        STARTUP_WAIT_BINARY <= '1';
      else
        assert FALSE report "Error : STARTUP_WAIT must be set to FALSE, TRUE." severity error;
      end if;

     if (CLKOUT0_DIVIDE_F_RND < CLKOUT0_DIVIDE_F) then
            Write ( Message, string'(" Warning : parameter CLKOUT0_DIVIDE_F of "));
            Write ( Message, MODULE_NAME );
            Write ( Message, STRING'(" instance "));
            Write ( Message, STRING'(MMCME2_ADV'path_name));
            Write ( Message, string'(" is not set to a resolution of 0.125 ("));
            Write ( Message, CLKOUT0_DIVIDE_F);
            Write ( Message, string'(") and is beimg rounded down to ("));
            Write ( Message, CLKOUT0_DIVIDE_F_RND);
            Write ( Message, string'(").") & LF );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
     elsif (CLKOUT0_DIVIDE_F < CLKOUT0_DIVIDE_F_RND) then
            Write ( Message, string'(" Warning : parameter CLKOUT0_DIVIDE_F of "));
            Write ( Message, MODULE_NAME );
            Write ( Message, STRING'(" instance "));
            Write ( Message, STRING'(MMCME2_ADV'path_name));
            Write ( Message, string'(" is not set to a resolution of 0.125 ("));
            Write ( Message, CLKOUT0_DIVIDE_F);
            Write ( Message, string'(") and is beimg rounded up to ("));
            Write ( Message, CLKOUT0_DIVIDE_F_RND);
            Write ( Message, string'(").") & LF );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
     end if;

     if (CLKFBOUT_MULT_F_RND < CLKFBOUT_MULT_F) then
            Write ( Message, string'(" Warning : parameter CLKFBOUT_MULT_F of "));
            Write ( Message, MODULE_NAME );
            Write ( Message, STRING'(" instance "));
            Write ( Message, STRING'(MMCME2_ADV'path_name));
            Write ( Message, string'(" is not set to a resolution of 0.125 ("));
            Write ( Message, CLKFBOUT_MULT_F);
            Write ( Message, string'(") and is beimg rounded down to ("));
            Write ( Message, CLKFBOUT_MULT_F_RND);
            Write ( Message, string'(").") & LF );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
     elsif (CLKFBOUT_MULT_F < CLKFBOUT_MULT_F_RND) then
            Write ( Message, string'(" Warning : parameter CLKFBOUT_MULT_F of "));
            Write ( Message, MODULE_NAME );
            Write ( Message, STRING'(" instance "));
            Write ( Message, STRING'(MMCME2_ADV'path_name));
            Write ( Message, string'(" is not set to a resolution of 0.125 ("));
            Write ( Message, CLKFBOUT_MULT_F);
            Write ( Message, string'(") and is beimg rounded up to ("));
            Write ( Message, CLKFBOUT_MULT_F_RND);
            Write ( Message, string'(").") & LF );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
     end if;
       clkfbm1_f_div_v := CLKFBOUT_MULT_F_RND;
--       clkfbm1_f_div <= clkfbm1_f_div_v;
       clkfb_div_fint_v := real2int(clkfbm1_f_div_v);
       clkfb_div_fint_v_tmp := clkfb_div_fint_v / 2;
       clkfb_div_fint_odd_v := clkfb_div_fint_v - 2 * clkfb_div_fint_v_tmp;
--       clkfb_div_fint_odd <= clkfb_div_fint_v - 2 * clkfb_div_fint_v_tmp;
       clkfb_div_fint_v1 := real(clkfb_div_fint_v);
--       clkfb_div_fint <= clkfb_div_fint_v;
       clkfb_div_frac_v := clkfbm1_f_div_v - clkfb_div_fint_v1;
--       clkfb_div_frac <= clkfb_div_frac_v;

       clkfb_div_check_v := 8.0 * clkfb_div_frac_v;
       clkfb_div_check_int_v := real2int(8.0 * clkfb_div_frac_v);
       clkfb_div_check_diff_v := clkfb_div_check_v - (real(clkfb_div_check_int_v));
       clkfb_div_check_diff <= clkfb_div_check_diff_v;

       if (clkfb_div_frac_v > 0.000) then
              clkfb_frac_en_i <= 1;
              clkfb_frac_en_v := 1;
       else
              clkfb_frac_en_i <= 0;
              clkfb_frac_en_v := 0;
       end if;
       if (clkfb_frac_en_v = 1) then
         if (clkfb_div_check_diff_v = 0.000) then
             clkfb_div_adj_v :=  0;
             clkfb_div_adj   <=  0;
         else
             clkfb_div_adj_v :=  1;
             clkfb_div_adj   <=  1;
    end if;    
       end if;

       clkfb_div_frac_int_v := real2int(8.0 * clkfb_div_frac_v);
--       clkfb_div_frac_int <= clkfb_div_frac_int_v;
       clkfb_sdivide := CLKFBOUT_MULT_F_RND;
       clkfb_sdivide_int := clkfb_div_fint_v;
       clkfb_frac_v := clkfb_div_frac_int_v;
       clkfb_frac_i <= clkfb_div_frac_int_v;
       clkfb_sevent_part_high := clkfb_div_fint_v_tmp;
       clkfb_sevent_part_low := clkfb_sevent_part_high;
       clkfb_sodd := clkfb_div_fint_odd_v;
       clkfb_sodd_and_frac := 8 * clkfb_sodd + clkfb_frac_v;
       if (clkfb_sodd_and_frac > 9) then
          clkfbm1_lt_i <= clkfb_sevent_part_high;
       else
          clkfbm1_lt_i <= clkfb_sevent_part_high - 1;
       end if;
       if (clkfb_sodd_and_frac > 8) then
          clkfbm1_ht_i <= clkfb_sevent_part_low;
       else
          clkfbm1_ht_i <= clkfb_sevent_part_low - 1;
       end if;
       clkfb_sfrac_2 := clkfb_div_frac_int_v / 2;
       clkfbpmf_sel_i <= 4 * clkfb_sodd + clkfb_sfrac_2;
       clkfbpmr_sel_i <= 0;
       if (CLKFBOUT_MULT_F_RND = 2.125) then
          clkfbout_frac_wf_f <= '1';
       else
         if (clkfb_sodd_and_frac >= 2 and clkfb_sodd_and_frac <= 9) then
            clkfbout_frac_wf_f <= '1';
         else
            clkfbout_frac_wf_f <= '0';
         end if;
       end if;
       if (clkfb_sodd_and_frac >= 1 and  clkfb_sodd_and_frac <= 8) then
          clkfbout_frac_wf_r <= '1';
       else
          clkfbout_frac_wf_r <= '0';
       end if;

       mf_product_v := clkfb_div_fint_v * 8 + clkfb_div_frac_int_v;
--       mf_product <= mf_product_v;
--       mf_product1 <= mf_product_v - 1;

       clk0_div_fint_v := real2int(CLKOUT0_DIVIDE_F_RND);
       clk0_div_fint_v1 := real(clk0_div_fint_v);
--       clk0_div_fint <= clk0_div_fint_v;
       clk0_div_fint_v_tmp := clk0_div_fint_v / 2;
       clk0_div_fint_odd_v := clk0_div_fint_v - 2 * clk0_div_fint_v_tmp;
       clk0_div_frac_v  := CLKOUT0_DIVIDE_F_RND - clk0_div_fint_v1;
--       clk0_div_frac <= clk0_div_frac_v;
       if (clk0_div_frac_v > 0.000 and clk0_div_fint_v >= 2) then 
              clk0_frac_en_i <= 1;
              clk0_frac_en_v := 1;
       else
              clk0_frac_en_i <= 0;
              clk0_frac_en_v := 0;
       end if;
       
       clk0_div_check_v := 8.0 * clk0_div_frac_v;
       clk0_div_check_int_v := real2int(8.0 * clk0_div_frac_v);
       clk0_div_check_diff_v := clk0_div_check_v - (real(clk0_div_check_int_v));
       clk0_div_check_diff <= clk0_div_check_diff_v;
       if (clk0_frac_en_v = 1) then
         if(clk0_div_check_diff_v = 0.000) then
              clk0_div_adj_v :=  0;
              clk0_div_adj   <=  0;
         else
              clk0_div_adj_v :=  1;
              clk0_div_adj   <=  1;
    end if;     
       end if;

       clk0_div_frac_int_v := real2int(clk0_div_frac_v * 8.0);
--       clk0_div_frac_int <= clk0_div_frac_int_v;
       clk0_sdivide := CLKOUT0_DIVIDE_F_RND;
       clk0_sdivide_int := clk0_div_fint_v;
       clk0_frac_v := clk0_div_frac_int_v;
       clk0_frac_i <= clk0_div_frac_int_v;
       clk0_sevent_part_high := clk0_div_fint_v_tmp;
       clk0_sevent_part_low := clk0_sevent_part_high;
       clk0_sodd := clk0_div_fint_odd_v;
       clk0_sodd_and_frac := 8 * clk0_sodd + clk0_frac_v;
       if (clk0_sodd_and_frac > 9) then
          clk0_lt_i <= clk0_sevent_part_high;
       else
          clk0_lt_i <= clk0_sevent_part_high - 1;
       end if;
       if (clk0_sodd_and_frac > 8) then
          clk0_ht_i <= clk0_sevent_part_low;
       else
          clk0_ht_i <= clk0_sevent_part_low - 1;
       end if;
       clk0_sfrac_2 := clk0_div_frac_int_v / 2;
       clk0pmf_sel_i <= 4 * clk0_sodd + clk0_sfrac_2;
       clk0pmr_sel_i <= 0;
    if ( CLKOUT0_DIVIDE_F_RND = 2.125) then
       clk0_frac_wf_f <= '1';
    else
      if (clk0_sodd_and_frac >= 2 and clk0_sodd_and_frac <= 9) then
         clk0_frac_wf_f <= '1';
      else
         clk0_frac_wf_f <= '0';
      end if;
    end if;
    if (clk0_sodd_and_frac >= 1 and  clk0_sodd_and_frac <= 8) then
       clk0_frac_wf_r <= '1';
    else
       clk0_frac_wf_r <= '0';
    end if;

       ps_in_init_v := 0;
       ps_in_init <= ps_in_init_v;

--       if (clk0_frac_en_v = 1 and clk0_fps_eni = 1) then
--          assert FALSE report " Attribute Syntax Error : The Attribute CLKOUT0_USE_FINE_PS should be set to FALSE when CLKOUT0_DIVIDE_F has fraction part." severity error;
--       end if;

--       if (clkfb_frac_en_v = 1 and clkfb_fps_eni = 1) then
--          assert FALSE report " Attribute Syntax Error : The Attribute CLKFBOUT_USE_FINE_PS should be set to FALSE when CLKFBOUT_MULT_F has fraction part." severity error;
--       end if;

       if (CLKOUT0_DIVIDE_F_RND < 0.000 or CLKOUT0_DIVIDE_F_RND > 128.000) then
          assert FALSE report "Attribute Syntax Error : CLKOUT0_DIVIDE_F is not in range 1.000 to 128.000." severity error;
       end if;

       if (CLKOUT0_DIVIDE_F_RND > 1.0000 and  CLKOUT0_DIVIDE_F_RND < 2.0000) then
          assert FALSE report "Attribute Syntax Error : CLKOUT0_DIVIDE_F is in range of greater than 1.0000 and less than 2.0000, which is not allowed." severity error;
       end if;

        if ((CLKOUT0_PHASE < -360.0) or (CLKOUT0_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT0_PHASE is not in range -360.0 to 360.0" severity error;
        end if;

       if (clk0_frac_en_v = 0) then
        if ((CLKOUT0_DUTY_CYCLE < 0.001) or (CLKOUT0_DUTY_CYCLE > 0.999)) then
           assert FALSE report "Attribute Syntax Error : CLKOUT0_DUTY_CYCLE is not real in range 0.001 to 0.999 pecentage."severity error;
        end if;
       else
         if (CLKOUT0_DUTY_CYCLE > 0.5 or CLKOUT0_DUTY_CYCLE < 0.5) then
            assert FALSE report "Attribute Syntax Error : CLKOUT0_DUTY_CYCLE should be set to 0.5 when CLKOUT0_DIVIDE_F has fraction part." severity error;
        end if;
       end if;

        case CLKOUT1_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT1_DIVIDE is not in range 1 to 128." severity error;
        end case;

         if ((CLKOUT1_PHASE < -360.0) or (CLKOUT1_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT1_PHASE is not in range -360.0 to 360.0" severity error;
         end if;

         if ((CLKOUT1_DUTY_CYCLE < 0.001) or (CLKOUT1_DUTY_CYCLE > 0.999)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT1_DUTY_CYCLE is not real in range 0.001 to 0.999 pecentage."severity error;
         end if;

         case CLKOUT2_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT2_DIVIDE is not in range 1 to 128." severity error;
         end case;

         if ((CLKOUT2_PHASE < -360.0) or (CLKOUT2_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT2_PHASE is not in range -360.0 to 360.0" severity error;
         end if;

         if ((CLKOUT2_DUTY_CYCLE < 0.001) or (CLKOUT2_DUTY_CYCLE > 0.999)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT2_DUTY_CYCLE is not real in range 0.001 to 0.999 pecentage."severity error;
         end if;

         case CLKOUT3_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT3_DIVIDE is not in range 1...128." severity error;
         end case;

         if ((CLKOUT3_PHASE < -360.0) or (CLKOUT3_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT3_PHASE is not in range -360.0 to 360.0" severity error;
         end if;

         if ((CLKOUT3_DUTY_CYCLE < 0.001) or (CLKOUT3_DUTY_CYCLE > 0.999)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT3_DUTY_CYCLE is not real in range 0.001 to 0.999 pecentage."severity error;
         end if;

         case CLKOUT4_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT4_DIVIDE is not in range 1 to 128." severity error;
         end case;

         if ((CLKOUT4_PHASE < -360.0) or (CLKOUT4_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT4_PHASE is not in range -360.0 to 360.0" severity error;
         end if;

         if ((CLKOUT4_DUTY_CYCLE < 0.001) or (CLKOUT4_DUTY_CYCLE > 0.999)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT4_DUTY_CYCLE is not real in range 0.001 to 0.999 pecentage."severity error;
         end if;

           case CLKOUT5_DIVIDE is
             when   1 to 128 => NULL ;
             when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT5_DIVIDE is not in range 1...128." severity error;
           end case;
           if ((CLKOUT5_PHASE < -360.0) or (CLKOUT5_PHASE > 360.0)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT5_PHASE is not in range 360.0 to 360.0" severity error;
           end if;
           if ((CLKOUT5_DUTY_CYCLE < 0.001) or (CLKOUT5_DUTY_CYCLE > 0.999)) then
             assert FALSE report "Attribute Syntax Error : CLKOUT5_DUTY_CYCLE is not real in range 0.001 to 0.999 pecentage."severity error;
           end if;

         case CLKOUT6_DIVIDE is
           when   1 to 128 => NULL ;
           when others  =>  assert FALSE report "Attribute Syntax Error : CLKOUT6_DIVIDE is not in range 1 to 128." severity error;
         end case;
         if ((CLKOUT6_PHASE < -360.0) or (CLKOUT6_PHASE > 360.0)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT6_PHASE is not in range 360.0 to 360.0" severity error;
         end if;
         if ((CLKOUT6_DUTY_CYCLE < 0.001) or (CLKOUT6_DUTY_CYCLE > 0.999)) then
            assert FALSE report "Attribute Syntax Error : CLKOUT6_DUTY_CYCLE is not real in range 0.0 to 1.0 pecentage."severity error;
         end if;

         if (CLKFBOUT_MULT_F_RND < 2.000 or CLKFBOUT_MULT_F_RND > 64.000) then 
          assert FALSE report "Attribute Syntax Error : CLKFBOUT_MULT is not in range 2.000 to 64.000 ." severity error;
         end if; 

       if ( CLKFBOUT_PHASE < -360.0 or CLKFBOUT_PHASE > 360.0 ) then
             assert FALSE report "Attribute Syntax Error : CLKFBOUT_PHASE is not in range -360.0 to 360.0" severity error;
       end if;

       case DIVCLK_DIVIDE is
         when    1  to 106 => NULL;
         when others  =>  assert FALSE report "Attribute Syntax Error : DIVCLK_DIVIDE is not in range 1 to 106." severity error;
       end case;

       if ((REF_JITTER1 < 0.0) or (REF_JITTER1 > 0.999)) then
         assert FALSE report "Attribute Syntax Error : REF_JITTER1 is not in range 0.0 ... 1.0." severity error;
       end if;

       if ((REF_JITTER2 < 0.0) or (REF_JITTER2 > 0.999)) then
         assert FALSE report "Attribute Syntax Error : REF_JITTER2 is not in range 0.0 ... 1.0." severity error;
       end if;

       O_MAX_HT_LT_real := real(O_MAX_HT_LT);
       CLKOUT0_DIVIDE_real := CLKOUT0_DIVIDE_F_RND;
       CLKOUT1_DIVIDE_real := real(CLKOUT1_DIVIDE);
       CLKOUT2_DIVIDE_real := real(CLKOUT2_DIVIDE);
       CLKOUT3_DIVIDE_real := real(CLKOUT3_DIVIDE);
       CLKOUT4_DIVIDE_real := real(CLKOUT4_DIVIDE);
       CLKOUT5_DIVIDE_real := real(CLKOUT5_DIVIDE);
       CLKOUT6_DIVIDE_real := real(CLKOUT6_DIVIDE);

       if (clk0_frac_en_v = 0) then
         if (clk0_div_fint_v /= 0) then
         chk_ok := clkout_duty_chk (clk0_div_fint_v, CLKOUT0_DUTY_CYCLE, "CLKOUT0_DUTY_CYCLE");
         end if;
       end if;
       if (CLKOUT5_DIVIDE /= 0) then
         chk_ok := clkout_duty_chk (CLKOUT5_DIVIDE, CLKOUT5_DUTY_CYCLE, "CLKOUT5_DUTY_CYCLE");
       end if;
       if (CLKOUT1_DIVIDE /= 0) then
       chk_ok := clkout_duty_chk (CLKOUT1_DIVIDE, CLKOUT1_DUTY_CYCLE, "CLKOUT1_DUTY_CYCLE");
       end if;
       if (CLKOUT2_DIVIDE /= 0) then
       chk_ok := clkout_duty_chk (CLKOUT2_DIVIDE, CLKOUT2_DUTY_CYCLE, "CLKOUT2_DUTY_CYCLE");
       end if;
       if (CLKOUT3_DIVIDE /= 0) then
       chk_ok := clkout_duty_chk (CLKOUT3_DIVIDE, CLKOUT3_DUTY_CYCLE, "CLKOUT3_DUTY_CYCLE");
       end if;
       if (CLKOUT4_DIVIDE /= 0) then
       chk_ok := clkout_duty_chk (CLKOUT4_DIVIDE, CLKOUT4_DUTY_CYCLE, "CLKOUT4_DUTY_CYCLE");
       end if;
         if (CLKOUT6_DIVIDE /= 0) then
         chk_ok := clkout_duty_chk (CLKOUT6_DIVIDE, CLKOUT6_DUTY_CYCLE, "CLKOUT6_DUTY_CYCLE");
         end if;
       lock_en_tmp1_rl := real(DIVCLK_DIVIDE);
       lock_en_tmp2_rl := lock_en_tmp1_rl * CLKFBOUT_MULT_F_RND;
       lock_en_tmp3_int := real2int(lock_en_tmp2_rl);
       if (clkfb_frac_en_v = 1) then

          clkout_en_time_i := mf_product_v + 4;
       else
          clkout_en_time_i := lock_en_tmp3_int;
       end if; 
       pll_lock_time <= 12;
       lock_period_time <= 10;
       clkout_en_time_i1 := clkout_en_time_i + 12;
--       clkout_en_time <= clkout_en_time_i1;
--       locked_en_time <= lock_en_tmp3_int +  clkout_en_time_i1 + 2;
--       lock_cnt_max <= lock_en_tmp3_int +  clkout_en_time_i1 + 16;
       init_done <= '1';

       wait;
    end process INIPROC;


    clkinsel_p : process 
          variable period_clkin : real := 0.0;
          variable clkvco_freq_init_chk : real := 0.0;
          variable Message : line;
          variable tmpreal1 : real := 0.0;
          variable tmpreal2 : real := 0.0;
          variable first_check : boolean := true;
          variable clkin_chk_t1 : real := 0.0;
          variable clkin_chk_t1_tmp1 : real := 0.0;
          variable clkin_chk_t1_tmp2 : real := 0.0;
          variable clkin_chk_t1_tmpi : time := 0 ps;
          variable clkin_chk_t1_tmpi1 : integer := 0;
          variable clkin_chk_t2 : real := 0.0;
          variable clkin_chk_t2_tmp1 : real := 0.0;
          variable clkin_chk_t2_tmp2 : real := 0.0;
          variable clkin_chk_t2_tmpi : time := 0 ps;
          variable clkin_chk_t2_tmpi1 : integer := 0;
          
    begin

      if (first_check = true or rising_edge(clkinsel_in) or falling_edge(clkinsel_in)) then

      if (NOW > 1 ps  and  rst_in = '0' and (clkinsel_tmp = '0' or clkinsel_tmp = '1')) then
          assert false report
            "Input Error : MMCME2_ADV input clock can only be switched when RST=1.  CLKINSEL is changed when RST low, which should be changed at RST high."
          severity error;
      end if;

        if (NOW = 0 ps) then
           wait for 1 ps;
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

          if (((CLKIN1_PERIOD < clkin_chk_t2) or (CLKIN1_PERIOD > clkin_chk_t1)) and  (CLKINSEL /= '0')) then
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

          if (((CLKIN2_PERIOD < clkin_chk_t2) or (CLKIN2_PERIOD > clkin_chk_t1)) and  (CLKINSEL = '0')) then
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

        if ( clkinsel_in /= '0') then
           period_clkin :=  CLKIN1_PERIOD;
        else
           period_clkin := CLKIN2_PERIOD;
        end if;
      
        tmpreal1 := CLKFBOUT_MULT_F_RND;
        tmpreal2 := real(DIVCLK_DIVIDE);
        if (period_clkin > 0.000) then
          clkvco_freq_init_chk :=  (1000.0 * tmpreal1) / ( period_clkin * tmpreal2);
      
          if ((clkvco_freq_init_chk > VCOCLK_FREQ_MAX) or (clkvco_freq_init_chk < VCOCLK_FREQ_MIN)) then
           Write ( Message, string'(" Attribute Syntax Error : The calculation of VCO frequency="));
           Write ( Message, clkvco_freq_init_chk);
           Write ( Message, string'(" Mhz. This exceeds the permitted VCO frequency range of "));
           Write ( Message, VCOCLK_FREQ_MIN);
           Write ( Message, string'(" MHz to "));
           Write ( Message, VCOCLK_FREQ_MAX);
           if (clkinsel_in /= '0') then
             Write ( Message, string'(" MHz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT / (DIVCLK_DIVIDE * CLKIN1_PERIOD)."));
           else
             Write ( Message, string'(" MHz. The VCO frequency is calculated with formula: VCO frequency =  CLKFBOUT_MULT / (DIVCLK_DIVIDE * CLKIN2_PERIOD)."));
           end if;
           Write ( Message, string'(" Please adjust the attributes to the permitted VCO frequency range."));
           assert false report Message.all severity error;
              DEALLOCATE (Message);
          end if;
        end if;   
        first_check := false;
    end if;
      wait on clkinsel_in, clkpll_r;
    end process;

    clkpll_r <= clkin1_in when clkinsel_in = '1' else clkin2_in;
    pwrdwn_in1 <= '1' when pwrdwn_in = '1' else '0'; 
    rst_input <= rst_input_r or pwrdwn_in1;
    rst_in_o <= rst_in or rst_clkfbstopped or rst_clkinstopped;

    RST_SYNC_P : process (clkpll_r, rst_input)
    begin
      if (rst_input = '1') then
        rst_in <= '1';
      elsif (rising_edge (clkpll_r)) then
        rst_in <= rst_input;
      end if;
    end process;

--simprim_rst_h
  pwrdwn_in1_h_p : process(pwrdwn_in1, pchk_clr)
  begin
    if (rising_edge(pwrdwn_in1)) then
       pwrdwn_in1_h <= '1';
    elsif (rising_edge(pchk_clr)) then
       pwrdwn_in1_h <= '0';
    end if;
  end process;

  rst_input_r_h_p : process(rst_input_r, pchk_clr)
  begin
    if (rising_edge(rst_input_r)) then
       rst_input_r_h <= '1';
    elsif (rising_edge(pchk_clr)) then
       rst_input_r_h <= '0';
    end if;
  end process;

    RST_PW_P : process (rst_input)
      variable rst_edge : time := 0 ps;
      variable rst_ht : time := 0 ps;
    begin
      if (rising_edge(rst_input)) then
         rst_edge := NOW;
      elsif ((falling_edge(rst_input)) and rst_edge > 1 ps)  then
         rst_ht := NOW - rst_edge;
         if (rst_ht < 1.5 ns and rst_ht > 0 ps) then
           if (rst_input_r_h = '1' and  pwrdwn_in1_h = '1') then
            assert false report
               "Input Error : RST and PWRDWN must be asserted at least for 1.5 ns."
            severity error;
           elsif (rst_input_r_h = '1' and  pwrdwn_in1_h = '0') then
            assert false report
               "Input Error : RST  must be asserted at least for 1.5 ns."
            severity error;
           elsif (rst_input_r_h = '0' and  pwrdwn_in1_h = '1') then
            assert false report
               "Input Error :  PWRDWN must be asserted at least for 1.5 ns."
            severity error;
           end if;
         end if;
      end if;
    end process;
--endsimprim_rst_h
     
---- 
----  DRP port read and write
----

    do_out <= dr_sram(daddr_in_lat);

    DRP_PROC : process
      variable address : integer;
      variable valid_daddr : boolean := false;
      variable Message : line;
      variable di_str : string (1 to 16);
      variable daddr_str : string ( 1 to 7);
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
      variable clk6_hti : std_logic_vector (6 downto 0);
      variable clkfbm1_hti : std_logic_vector (6 downto 0);
      variable clkfbm2_hti : std_logic_vector (6 downto 0);
      variable clk0_lti : std_logic_vector (6 downto 0);
      variable clk1_lti : std_logic_vector (6 downto 0);
      variable clk2_lti : std_logic_vector (6 downto 0);
      variable clk3_lti : std_logic_vector (6 downto 0);
      variable clk4_lti : std_logic_vector (6 downto 0);
      variable clk5_lti : std_logic_vector (6 downto 0);
      variable clk6_lti : std_logic_vector (6 downto 0);
      variable clkfbm1_lti : std_logic_vector (6 downto 0);
      variable clkfbm2_lti : std_logic_vector (6 downto 0);
      variable clk0_nocnti : std_ulogic;
      variable clk1_nocnti : std_ulogic;
      variable clk2_nocnti : std_ulogic;
      variable clk3_nocnti : std_ulogic;
      variable clk4_nocnti : std_ulogic;
      variable clk5_nocnti : std_ulogic;
      variable clk6_nocnti : std_ulogic;
      variable clkfbm1_nocnti : std_ulogic;
      variable clkfbm2_nocnti : std_ulogic;
      variable clk0_edgei  : std_ulogic;
      variable clk1_edgei  : std_ulogic;
      variable clk2_edgei  : std_ulogic;
      variable clk3_edgei  : std_ulogic;
      variable clk4_edgei  : std_ulogic;
      variable clk5_edgei  : std_ulogic;
      variable clk6_edgei  : std_ulogic;
      variable clkfbm1_edgei  : std_ulogic;
      variable clkfbm2_edgei  : std_ulogic;
      variable clkout0_dly_tmp : integer;
      variable clkout5_dly_tmp : integer;
      variable clkout6_dly_tmp : integer;
      variable clkout5f_dly_tmp : integer;
      variable clkout6f_dly_tmp : integer;
      variable clkfbm1_dly_tmp : integer;
      variable clk5pm_sel_tmp : integer;
      variable clk5fpm_sel_tmp : integer;
      variable clk6pm_sel_tmp : integer;
      variable clk6fpm_sel_tmp : integer;
      variable clkout0_dlyi : std_logic_vector (5 downto 0);
      variable clkout1_dlyi : std_logic_vector (5 downto 0);
      variable clkout2_dlyi : std_logic_vector (5 downto 0);
      variable clkout3_dlyi : std_logic_vector (5 downto 0);
      variable clkout4_dlyi : std_logic_vector (5 downto 0);
      variable clkout5_dlyi : std_logic_vector (5 downto 0);
      variable clkout6_dlyi : std_logic_vector (5 downto 0);
      variable clkout5f_dlyi : std_logic_vector (5 downto 0);
      variable clkout6f_dlyi : std_logic_vector (5 downto 0);
      variable clkfbm1_dlyi : std_logic_vector (5 downto 0);
      variable clkfbm2_dlyi : std_logic_vector (5 downto 0);
      variable clk0pm_seli : std_logic_vector (2 downto 0);
      variable clk1pm_seli : std_logic_vector (2 downto 0);
      variable clk2pm_seli : std_logic_vector (2 downto 0);
      variable clk3pm_seli : std_logic_vector (2 downto 0);
      variable clk4pm_seli : std_logic_vector (2 downto 0);
      variable clk5pm_seli : std_logic_vector (2 downto 0);
      variable clk6pm_seli : std_logic_vector (2 downto 0);
      variable clk5fpm_seli : std_logic_vector (2 downto 0);
      variable clk6fpm_seli : std_logic_vector (2 downto 0);
      variable clkfbm1pm_seli : std_logic_vector (2 downto 0);
      variable clkfbm2pm_seli : std_logic_vector (2 downto 0);
      variable  clkfbm1pm_sel_tmp : integer;
      variable  clk0pm_sel_tmp : integer;
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
    
      variable drp_lock_ref_dly : std_logic_vector (4 downto 0);
      variable drp_lock_fb_dly : std_logic_vector (4 downto 0);
      variable drp_lock_cnt : std_logic_vector (9 downto 0);
      variable drp_unlock_cnt : std_logic_vector (9 downto 0);
      variable drp_lock_sat_high : std_logic_vector (9 downto 0);
      variable tmpadd : std_logic_vector (4 downto 0);
      variable clkfb_frac_en_v : integer;
      variable clk0_frac_en_v : integer;
      variable clkfb_frac_v : std_logic_vector (2 downto 0);
      variable clkfbpmf_sel_v : std_logic_vector (2 downto 0);
      variable clkfbpmr_sel_v : std_logic_vector (2 downto 0);
      variable clk0_frac_v : std_logic_vector (2 downto 0);
      variable clk0pmf_sel_v : std_logic_vector (2 downto 0);
      variable clk0pmr_sel_v : std_logic_vector (2 downto 0);
      variable clkfb_frac_en_vl : std_ulogic;
      variable clk0_frac_en_vl : std_ulogic;
      variable tmp_intfv : integer;
    begin

    if (first_time = true and init_done = '1') then
      clkfb_frac_en <= clkfb_frac_en_i;
      if (clkfb_frac_en_i = 0) then
         clkfb_frac_en_vl := '0';
      else
         clkfb_frac_en_vl := '1';
      end if;
      clkfb_frac_en_v := clkfb_frac_en_i;
      clkfb_frac <= clkfb_frac_i;
      clkfb_frac_v := STD_LOGIC_VECTOR(TO_UNSIGNED(clkfb_frac_i, 3));
      clkfbm1_lti := STD_LOGIC_VECTOR(TO_UNSIGNED(clkfbm1_lt_i, 7));
      clkfbm1_hti := STD_LOGIC_VECTOR(TO_UNSIGNED(clkfbm1_ht_i, 7));
      clkfbpmf_sel_v := STD_LOGIC_VECTOR(TO_UNSIGNED(clkfbpmf_sel_i, 3));
      clkfbm1pmf_sel <= clkfbpmf_sel_i;
      clkfbpmr_sel_v := STD_LOGIC_VECTOR(TO_UNSIGNED(clkfbpmr_sel_i, 3));
      clkfbm1pmr_sel <= clkfbpmr_sel_i;
      clk0_frac_en <= clk0_frac_en_i;
      if (clk0_frac_en_i = 0) then
         clk0_frac_en_vl := '0';
      else
         clk0_frac_en_vl := '1';
      end if;
      clk0_frac_en_v := clk0_frac_en_i;
      clk0_frac <= clk0_frac_i;
      if (clk0_frac_i >= 0) then
        clk0_frac_v := STD_LOGIC_VECTOR(TO_UNSIGNED(clk0_frac_i, 3));
      end if;
      if (clk0_lt_i >= 0) then
        clk0_lti := STD_LOGIC_VECTOR(TO_UNSIGNED(clk0_lt_i, 7));
      end if;
--      clk0_lt <= clk0_lti;
      if (clk0_ht_i >= 0) then
        clk0_hti := STD_LOGIC_VECTOR(TO_UNSIGNED(clk0_ht_i, 7));
      end if;
--      clk0_ht <= clk0_hti;
      if (clk0pmf_sel_i >= 0) then
        clk0pmf_sel_v := STD_LOGIC_VECTOR(TO_UNSIGNED(clk0pmf_sel_i, 3));
      end if;
      clk0pmf_sel <= clk0pmf_sel_i;
      if (clk0pmr_sel_i >= 0) then
        clk0pmr_sel_v := STD_LOGIC_VECTOR(TO_UNSIGNED(clk0pmr_sel_i, 3));
      end if;
      clk0pmr_sel <= clk0pmr_sel_i;
      if (clk0_frac_en_v = 0) then
        tmp_intfv := real2int(CLKOUT0_DIVIDE_F_RND);
        clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, tmp_intfv, CLKOUT0_DUTY_CYCLE);
        clk0_hti := clk_ht;
        clk0_lti := clk_lt;
        clk0_nocnti := clk_nocnt;
        clk0_edgei := clk_edge;
        clk0_ht <= clk0_hti;
        clk0_lt <= clk0_lti;
        clk0_nocnt <= clk0_nocnti;
        clk0_edge <= clk0_edgei;
      else
        clk0_ht <= clk0_hti;
        clk0_lt <= clk0_lti;
      end if;

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

        clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, CLKOUT6_DIVIDE, CLKOUT6_DUTY_CYCLE);
        clk6_hti := clk_ht;
        clk6_lti := clk_lt;
        clk6_nocnti := clk_nocnt;
        clk6_edgei := clk_edge;
        clk6_ht <= clk6_hti;
        clk6_lt <= clk6_lti;
        clk6_nocnt <= clk6_nocnti;
        clk6_edge <= clk6_edgei;

      if (clkfb_frac_en_v = 0) then
       tmp_intfv := real2int(CLKFBOUT_MULT_F_RND); 
        clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, tmp_intfv, 0.50);
        clkfbm1_hti := clk_ht;
        clkfbm1_lti := clk_lt;
        clkfbm1_nocnti := clk_nocnt;
        clkfbm1_edgei := clk_edge;
        clkfbm1_ht <= clkfbm1_hti;
        clkfbm1_lt <= clkfbm1_lti;
        clkfbm1_nocnt <= clkfbm1_nocnti;
        clkfbm1_edge <= clkfbm1_edgei;
      else
        clkfbm1_ht <= clkfbm1_hti;
        clkfbm1_lt <= clkfbm1_lti;
      end if;

      clk_out_para_cal (clk_ht, clk_lt, clk_nocnt, clk_edge, 1, 0.50);
      clkfbm2_hti := clk_ht;
      clkfbm2_lti := clk_lt;
      clkfbm2_nocnti := clk_nocnt;
      clkfbm2_edgei := clk_edge;
      clkfbm2_ht <= clkfbm2_hti;
      clkfbm2_lt <= clkfbm2_lti;
      clkfbm2_nocnt <= clkfbm2_nocnti;
      clkfbm2_edge <= clkfbm2_edgei;

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
      if (clk_div1 > 0) then
        clk0_div1 <= clk_div1;
      else
        clk0_div1 <= 0;
      end if;
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
      clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk6_hti, clk6_lti, clk6_nocnti, clk6_edgei);
      clk6_ht1 <= clk_ht1;
      clk6_div <= clk_div;
      clk6_div1 <= clk_div1;
      clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm1_hti, clkfbm1_lti, clkfbm1_nocnti, clkfbm1_edgei);
      clkfbm1_ht1 <= clk_ht1;
--      if (clkfb_frac_en_v = 1) then
--         clkfbm1_div <= clkfb_div_fint;
--      else
         clkfbm1_div <= clk_div;
--      end if;
      clkfbm1_div1 <= clk_div1;
      clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm2_hti, clkfbm2_lti, clkfbm2_nocnti, clkfbm2_edgei);
      clkfbm2_ht1 <= clk_ht1;
      clkfbm2_div <= clk_div;
      clkfbm2_div1 <= clk_div1;
      clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkind_hti, clkind_lti, clkind_nocnti, '0');
      clkind_ht1 <= clk_ht1;
      clkind_div1 <= clk_div1;
      clkind_div <= clk_div;

      if (clk0_frac_en_v = 1) then
--        clkout0_dly_tmp := clk0_div_fint /2;
--        clk0_fht <= clkout0_dly_tmp;
--        clk0_flt <= clkout0_dly_tmp;
--        if (clk0_div_fint_odd > 0) then
--            clk0pm_sel_tmp := 8 + clk0_div_frac_int - (8 + clk0_div_frac_int) / 2;
--            clk0pm_rsel <= (8 + clk0_div_frac_int) / 2;
--        else
--             clk0pm_sel_tmp :=  clk0_div_frac_int - (clk0_div_frac_int) / 2;
--            clk0pm_rsel <= (clk0_div_frac_int) / 2;
--        end if;
--        clk0pm_fsel <= clk0pm_sel_tmp;
--        clk0pm_seli := STD_LOGIC_VECTOR(TO_UNSIGNED(clk0pm_sel_tmp, 3));
        clkout_dly_real_cal (clkout_dly, clkpm_sel, CLKOUT0_DIVIDE_F_RND, CLKOUT0_PHASE, "CLKOUT0_PHASE");
        clkout0_dly <= SLV_TO_INT(clkout_dly);
        clk0pm_sel <= SLV_TO_INT(clkpm_sel);
        clkout0_dlyi := clkout_dly;
        clk0pm_seli := clkpm_sel;
      else
        clkout_dly_cal (clkout_dly, clkpm_sel, clk0_div_fint, CLKOUT0_PHASE, "CLKOUT0_PHASE");
        clkout0_dly <= SLV_TO_INT(clkout_dly);
        clk0pm_sel <= SLV_TO_INT(clkpm_sel);
        clkout0_dlyi := clkout_dly;
        clk0pm_seli := clkpm_sel;
      end if;
   
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

      clkout_dly_real_cal (clkout_dly, clkpm_sel, CLKFBOUT_MULT_F_RND, CLKFBOUT_PHASE, "CLKFBOUT_PHASE");
--      if (clkfb_frac_en_v = 1) then 
--        clkfbm1_dly_tmp := clkfb_div_fint /2;
--        clkfbm1_fht <= clkfbm1_dly_tmp;
--        clkfbm1_flt <= clkfbm1_dly_tmp;
--        clkfbm1_dlyi := STD_LOGIC_VECTOR(TO_UNSIGNED(clkfbm1_dly_tmp, 6));
--        if (clkfb_div_fint_odd > 0) then
--           clkfbm1pm_sel_tmp := 8 + clkfb_div_frac_int - (8 + clkfb_div_frac_int) / 2;
--           clkfbm1r_sel <= (8 + clkfb_div_frac_int) / 2;
--        else
--           clkfbm1r_sel <= clkfb_div_frac_int / 2;   
--           clkfbm1pm_sel_tmp := clkfb_div_frac_int - clkfb_div_frac_int / 2;
--        end if;
--        clkfbm1f_sel <= clkfbm1pm_sel_tmp;
--        clkfbm1_dly <= SLV_TO_INT(clkout_dly);
--        clkfbm1pm_sel <= SLV_TO_INT(clkpm_sel);
--        clkfbm1_dlyi := clkout_dly;
--        clkfbm1pm_seli := clkpm_sel;
--      else
        clkfbm1_dly <= SLV_TO_INT(clkout_dly);
        clkfbm1pm_sel <= SLV_TO_INT(clkpm_sel);
        clkfbm1_dlyi := clkout_dly;
        clkfbm1pm_seli := clkpm_sel;
--     end if;

      clkout_dly_cal (clkout_dly, clkpm_sel, CLKOUT6_DIVIDE, CLKOUT6_PHASE, "CLKOUT6_PHASE");
      clkout6_dly <= SLV_TO_INT(clkout_dly);
      clk6pm_sel <= SLV_TO_INT(clkpm_sel);
      clkout6_dlyi := clkout_dly;
      clk6pm_seli := clkpm_sel;
   
--  if (BANDWIDTH = "LOW") then
--      pll_lfhf := "11";
--  else
      pll_lfhf := "00";
--  end if;

  if (BANDWIDTH = "LOW") then
    case clkfb_div_fint is
       when 1 => pll_cp := "0010"; pll_res := "1111";
       when 2 => pll_cp := "0010"; pll_res := "1111";
       when 3 => pll_cp := "0010"; pll_res := "1111";
       when 4 => pll_cp := "0010"; pll_res := "1111";
       when 5 => pll_cp := "0010"; pll_res := "0111";
       when 6 => pll_cp := "0010"; pll_res := "1011";
       when 7 => pll_cp := "0010"; pll_res := "1101";
       when 8 => pll_cp := "0010"; pll_res := "0011";
       when 9 => pll_cp := "0010"; pll_res := "0101";
       when 10 => pll_cp := "0010"; pll_res := "0101";
       when 11 => pll_cp := "0010"; pll_res := "1001";
       when 12 => pll_cp := "0010"; pll_res := "1110";
       when 13 => pll_cp := "0010"; pll_res := "1110";
       when 14 => pll_cp := "0010"; pll_res := "1110";
       when 15 => pll_cp := "0010"; pll_res := "1110";
       when 16 => pll_cp := "0010"; pll_res := "0001";
       when 17 => pll_cp := "0010"; pll_res := "0001";
       when 18 => pll_cp := "0010"; pll_res := "0001";
       when 19 => pll_cp := "0010"; pll_res := "0110";
       when 20 => pll_cp := "0010"; pll_res := "0110";
       when 21 => pll_cp := "0010"; pll_res := "0110";
       when 22 => pll_cp := "0010"; pll_res := "0110";
       when 23 => pll_cp := "0010"; pll_res := "0110";
       when 24 => pll_cp := "0010"; pll_res := "0110";
       when 25 => pll_cp := "0010"; pll_res := "0110";
       when 26 => pll_cp := "0010"; pll_res := "1010";
       when 27 => pll_cp := "0010"; pll_res := "1010";
       when 28 => pll_cp := "0010"; pll_res := "1010";
       when 29 => pll_cp := "0010"; pll_res := "1010";
       when 30 => pll_cp := "0010"; pll_res := "1010";
       when 31 => pll_cp := "0010"; pll_res := "1100";
       when 32 => pll_cp := "0010"; pll_res := "1100";
       when 33 => pll_cp := "0010"; pll_res := "1100";
       when 34 => pll_cp := "0010"; pll_res := "1100";
       when 35 => pll_cp := "0010"; pll_res := "1100";
       when 36 => pll_cp := "0010"; pll_res := "1100";
       when 37 => pll_cp := "0010"; pll_res := "1100";
       when 38 => pll_cp := "0010"; pll_res := "1100";
       when 39 => pll_cp := "0010"; pll_res := "1100";
       when 40 => pll_cp := "0010"; pll_res := "1100";
       when 41 => pll_cp := "0010"; pll_res := "1100";
       when 42 => pll_cp := "0010"; pll_res := "1100";
       when 43 => pll_cp := "0010"; pll_res := "1100";
       when 44 => pll_cp := "0010"; pll_res := "1100";
       when 45 => pll_cp := "0010"; pll_res := "1100";
       when 46 => pll_cp := "0010"; pll_res := "1100";
       when 47 => pll_cp := "0010"; pll_res := "1100";
       when 48 => pll_cp := "0010"; pll_res := "0010";
       when 49 => pll_cp := "0010"; pll_res := "0010";
       when 50 => pll_cp := "0010"; pll_res := "0010";
       when 51 => pll_cp := "0010"; pll_res := "0010";
       when 52 => pll_cp := "0010"; pll_res := "0010";
       when 53 => pll_cp := "0010"; pll_res := "0010";
       when 54 => pll_cp := "0010"; pll_res := "0010";
       when 55 => pll_cp := "0010"; pll_res := "0010";
       when 56 => pll_cp := "0010"; pll_res := "0010";
       when 57 => pll_cp := "0010"; pll_res := "0010";
       when 58 => pll_cp := "0010"; pll_res := "0010";
       when 59 => pll_cp := "0010"; pll_res := "0010";
       when 60 => pll_cp := "0010"; pll_res := "0010";
       when 61 => pll_cp := "0010"; pll_res := "0010";
       when 62 => pll_cp := "0010"; pll_res := "0010";
       when 63 => pll_cp := "0010"; pll_res := "0010";
       when 64 => pll_cp := "0010"; pll_res := "0010";
    when others => NULL;
    end case;
  elsif (BANDWIDTH = "HIGH") then
    case clkfb_div_fint is
       when 1 => pll_cp := "0010"; pll_res := "1111";
       when 2 => pll_cp := "0100"; pll_res := "1111";
       when 3 => pll_cp := "0101"; pll_res := "1011";
       when 4 => pll_cp := "0111"; pll_res := "0111";
       when 5 => pll_cp := "1101"; pll_res := "0111";
       when 6 => pll_cp := "1110"; pll_res := "1011";
       when 7 => pll_cp := "1110"; pll_res := "1101";
       when 8 => pll_cp := "1111"; pll_res := "0011";
       when 9 => pll_cp := "1110"; pll_res := "0101";
       when 10 => pll_cp := "1111"; pll_res := "0101";
       when 11 => pll_cp := "1111"; pll_res := "1001";
       when 12 => pll_cp := "1101"; pll_res := "0001";
       when 13 => pll_cp := "1111"; pll_res := "1001";
       when 14 => pll_cp := "1111"; pll_res := "1001";
       when 15 => pll_cp := "1111"; pll_res := "1001";
       when 16 => pll_cp := "1111"; pll_res := "1001";
       when 17 => pll_cp := "1111"; pll_res := "0101";
       when 18 => pll_cp := "1111"; pll_res := "0101";
       when 19 => pll_cp := "1100"; pll_res := "0001";
       when 20 => pll_cp := "1100"; pll_res := "0001";
       when 21 => pll_cp := "1100"; pll_res := "0001";
       when 22 => pll_cp := "0101"; pll_res := "1100";
       when 23 => pll_cp := "0101"; pll_res := "1100";
       when 24 => pll_cp := "0101"; pll_res := "1100";
       when 25 => pll_cp := "0101"; pll_res := "1100";
       when 26 => pll_cp := "0011"; pll_res := "0100";
       when 27 => pll_cp := "0011"; pll_res := "0100";
       when 28 => pll_cp := "0011"; pll_res := "0100";
       when 29 => pll_cp := "0011"; pll_res := "0100";
       when 30 => pll_cp := "0011"; pll_res := "0100";
       when 31 => pll_cp := "0011"; pll_res := "0100";
       when 32 => pll_cp := "0011"; pll_res := "0100";
       when 33 => pll_cp := "0011"; pll_res := "0100";
       when 34 => pll_cp := "0011"; pll_res := "0100";
       when 35 => pll_cp := "0011"; pll_res := "0100";
       when 36 => pll_cp := "0011"; pll_res := "0100";
       when 37 => pll_cp := "0011"; pll_res := "0100";
       when 38 => pll_cp := "0011"; pll_res := "0100";
       when 39 => pll_cp := "0011"; pll_res := "0100";
       when 40 => pll_cp := "0011"; pll_res := "0100";
       when 41 => pll_cp := "0011"; pll_res := "0100";
       when 42 => pll_cp := "0010"; pll_res := "1000";
       when 43 => pll_cp := "0010"; pll_res := "1000";
       when 44 => pll_cp := "0010"; pll_res := "1000";
       when 45 => pll_cp := "0010"; pll_res := "1000";
       when 46 => pll_cp := "0010"; pll_res := "1000";
       when 47 => pll_cp := "0111"; pll_res := "0001";
       when 48 => pll_cp := "0111"; pll_res := "0001";
       when 49 => pll_cp := "0100"; pll_res := "1100";
       when 50 => pll_cp := "0100"; pll_res := "1100";
       when 51 => pll_cp := "0100"; pll_res := "1100";
       when 52 => pll_cp := "0100"; pll_res := "1100";
       when 53 => pll_cp := "0110"; pll_res := "0001";
       when 54 => pll_cp := "0110"; pll_res := "0001";
       when 55 => pll_cp := "0101"; pll_res := "0110";
       when 56 => pll_cp := "0101"; pll_res := "0110";
       when 57 => pll_cp := "0101"; pll_res := "0110";
       when 58 => pll_cp := "0010"; pll_res := "0100";
       when 59 => pll_cp := "0010"; pll_res := "0100";
       when 60 => pll_cp := "0010"; pll_res := "0100";
       when 61 => pll_cp := "0010"; pll_res := "0100";
       when 62 => pll_cp := "0100"; pll_res := "1010";
       when 63 => pll_cp := "0011"; pll_res := "1100";
       when 64 => pll_cp := "0011"; pll_res := "1100";
    when others => NULL;
    end case;
  elsif (BANDWIDTH = "OPTIMIZED") then
    case clkfb_div_fint is
       when 1 => pll_cp := "0010"; pll_res := "1111";
       when 2 => pll_cp := "0100"; pll_res := "1111";
       when 3 => pll_cp := "0101"; pll_res := "1011";
       when 4 => pll_cp := "0111"; pll_res := "0111";
       when 5 => pll_cp := "1101"; pll_res := "0111";
       when 6 => pll_cp := "1110"; pll_res := "1011";
       when 7 => pll_cp := "1110"; pll_res := "1101";
       when 8 => pll_cp := "1111"; pll_res := "0011";
       when 9 => pll_cp := "1110"; pll_res := "0101";
       when 10 => pll_cp := "1111"; pll_res := "0101";
       when 11 => pll_cp := "1111"; pll_res := "1001";
       when 12 => pll_cp := "1101"; pll_res := "0001";
       when 13 => pll_cp := "1111"; pll_res := "1001";
       when 14 => pll_cp := "1111"; pll_res := "1001";
       when 15 => pll_cp := "1111"; pll_res := "1001";
       when 16 => pll_cp := "1111"; pll_res := "1001";
       when 17 => pll_cp := "1111"; pll_res := "0101";
       when 18 => pll_cp := "1111"; pll_res := "0101";
       when 19 => pll_cp := "1100"; pll_res := "0001";
       when 20 => pll_cp := "1100"; pll_res := "0001";
       when 21 => pll_cp := "1100"; pll_res := "0001";
       when 22 => pll_cp := "0101"; pll_res := "1100";
       when 23 => pll_cp := "0101"; pll_res := "1100";
       when 24 => pll_cp := "0101"; pll_res := "1100";
       when 25 => pll_cp := "0101"; pll_res := "1100";
       when 26 => pll_cp := "0011"; pll_res := "0100";
       when 27 => pll_cp := "0011"; pll_res := "0100";
       when 28 => pll_cp := "0011"; pll_res := "0100";
       when 29 => pll_cp := "0011"; pll_res := "0100";
       when 30 => pll_cp := "0011"; pll_res := "0100";
       when 31 => pll_cp := "0011"; pll_res := "0100";
       when 32 => pll_cp := "0011"; pll_res := "0100";
       when 33 => pll_cp := "0011"; pll_res := "0100";
       when 34 => pll_cp := "0011"; pll_res := "0100";
       when 35 => pll_cp := "0011"; pll_res := "0100";
       when 36 => pll_cp := "0011"; pll_res := "0100";
       when 37 => pll_cp := "0011"; pll_res := "0100";
       when 38 => pll_cp := "0011"; pll_res := "0100";
       when 39 => pll_cp := "0011"; pll_res := "0100";
       when 40 => pll_cp := "0011"; pll_res := "0100";
       when 41 => pll_cp := "0011"; pll_res := "0100";
       when 42 => pll_cp := "0010"; pll_res := "1000";
       when 43 => pll_cp := "0010"; pll_res := "1000";
       when 44 => pll_cp := "0010"; pll_res := "1000";
       when 45 => pll_cp := "0010"; pll_res := "1000";
       when 46 => pll_cp := "0010"; pll_res := "1000";
       when 47 => pll_cp := "0111"; pll_res := "0001";
       when 48 => pll_cp := "0111"; pll_res := "0001";
       when 49 => pll_cp := "0100"; pll_res := "1100";
       when 50 => pll_cp := "0100"; pll_res := "1100";
       when 51 => pll_cp := "0100"; pll_res := "1100";
       when 52 => pll_cp := "0100"; pll_res := "1100";
       when 53 => pll_cp := "0110"; pll_res := "0001";
       when 54 => pll_cp := "0110"; pll_res := "0001";
       when 55 => pll_cp := "0101"; pll_res := "0110";
       when 56 => pll_cp := "0101"; pll_res := "0110";
       when 57 => pll_cp := "0101"; pll_res := "0110";
       when 58 => pll_cp := "0010"; pll_res := "0100";
       when 59 => pll_cp := "0010"; pll_res := "0100";
       when 60 => pll_cp := "0010"; pll_res := "0100";
       when 61 => pll_cp := "0010"; pll_res := "0100";
       when 62 => pll_cp := "0100"; pll_res := "1010";
       when 63 => pll_cp := "0011"; pll_res := "1100";
       when 64 => pll_cp := "0011"; pll_res := "1100";
    when others => NULL;
    end case;
  end if;

  case clkfb_div_fint is
     when 1 =>  drp_lock_ref_dly := "00110";
           drp_lock_fb_dly := "00110";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 2 =>  drp_lock_ref_dly := "00110";
           drp_lock_fb_dly := "00110";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 3 =>  drp_lock_ref_dly := "01000";
           drp_lock_fb_dly := "01000";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 4 =>  drp_lock_ref_dly := "01011";
           drp_lock_fb_dly := "01011";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 5 =>  drp_lock_ref_dly := "01110";
           drp_lock_fb_dly := "01110";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 6 =>  drp_lock_ref_dly := "10001";
           drp_lock_fb_dly := "10001";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 7 =>  drp_lock_ref_dly := "10011";
           drp_lock_fb_dly := "10011";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 8 =>  drp_lock_ref_dly := "10110";
           drp_lock_fb_dly := "10110";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 9 =>  drp_lock_ref_dly := "11001";
           drp_lock_fb_dly := "11001";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 10 =>  drp_lock_ref_dly := "11100";
           drp_lock_fb_dly := "11100";
           drp_lock_cnt := "1111101000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 11 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1110000100";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 12 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1100111001";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 13 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1011101110";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 14 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1010111100";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 15 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1010001010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 16 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1001110001";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 17 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1000111111";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 18 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1000100110";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 19 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "1000001101";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 20 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0111110100";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 21 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0111011011";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 22 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0111000010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 23 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0110101001";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 24 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0110010000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 25 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0110010000";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 26 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0101110111";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 27 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0101011110";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 28 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0101011110";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 29 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0101000101";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 30 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0101000101";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 31 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0100101100";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 32 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0100101100";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 33 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0100101100";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 34 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0100010011";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 35 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0100010011";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 36 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0100010011";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 37 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 38 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 39 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 40 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 41 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 42 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 43 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 44 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 45 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 46 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 47 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 48 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 49 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 50 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 51 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 52 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 53 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 54 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 55 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 56 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 57 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 58 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 59 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 60 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 61 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 62 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 63 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
     when 64 =>  drp_lock_ref_dly := "11111";
           drp_lock_fb_dly := "11111";
           drp_lock_cnt := "0011111010";
           drp_lock_sat_high := "1111101001";
           drp_unlock_cnt := "0000000001";
       when others => NULL;
    end case;


      tmpx := ('X' & 'X' & 'X' & 'X' & 'X' & 'X' & '0' & '0' );
      dr_sram(6) <= (clk5pm_seli(2 downto 0) & '1' & clk5_hti(5 downto 0) & clk5_lti(5 downto 0));
      dr_sram(7) <= (tmpx(7 downto 6) & clk0pmf_sel_v(2 downto 0) & clk0_frac_wf_f & tmpx(1 downto 0) & clk5_edgei & clk5_nocnti & clkout5_dlyi(5 downto 0));
      dr_sram(8) <= (clk0pmr_sel_v(2 downto 0) & '1' & clk0_hti(5 downto 0) & clk0_lti(5 downto 0));
      dr_sram(9) <= (tmpx(7) & clk0_frac_v(2 downto 0) & clk0_frac_en_vl & clk0_frac_wf_r & "00" & clk0_edgei & clk0_nocnti & clkout0_dlyi(5 downto 0));
      dr_sram(10) <= (clk1pm_seli(2 downto 0) & '1' & clk1_hti(5 downto 0) & clk1_lti(5 downto 0));
      dr_sram(11) <= (tmpx(7 downto 0) & clk1_edgei & clk1_nocnti & clkout1_dlyi(5 downto 0));
      dr_sram(12) <= (clk2pm_seli(2 downto 0) & '1' & clk2_hti(5 downto 0) & clk2_lti(5 downto 0));
      dr_sram(13) <= (tmpx(7 downto 0) & clk2_edgei & clk2_nocnti & clkout2_dlyi(5 downto 0));
      dr_sram(14) <= (clk3pm_seli(2 downto 0) & '1' & clk3_hti(5 downto 0) & clk3_lti(5 downto 0));
      dr_sram(15) <= (tmpx(7 downto 0) & clk3_edgei & clk3_nocnti & clkout3_dlyi(5 downto 0));
      dr_sram(16) <= (clk4pm_seli(2 downto 0) & '1' & clk4_hti(5 downto 0) & clk4_lti(5 downto 0));
      dr_sram(17) <= (tmpx(7 downto 0) & clk4_edgei & clk4_nocnti & clkout4_dlyi(5 downto 0));
      dr_sram(18) <= (clk6pm_seli(2 downto 0) & '1' & clk6_hti(5 downto 0) & clk6_lti(5 downto 0));
      dr_sram(19) <= (tmpx(7 downto 6) & clkfbpmf_sel_v(2 downto 0) & clkfbout_frac_wf_f & "00" & clk6_edgei & clk6_nocnti & clkout6_dlyi(5 downto 0));
      dr_sram(20) <= (clkfbpmr_sel_v(2 downto 0) & '1' & clkfbm1_hti(5 downto 0) & clkfbm1_lti(5 downto 0));
      dr_sram(21) <= (tmpx(7)  & clkfb_frac_v(2 downto 0) & clkfb_frac_en_vl & clkfbout_frac_wf_r & "00"  & clkfbm1_edgei & clkfbm1_nocnti & clkfbm1_dlyi(5 downto 0));
      dr_sram(22) <= (tmpx(7 downto 6) & clkind_edgei & clkind_nocnti & clkind_hti(5 downto 0) & clkind_lti(5 downto 0));
     dr_sram(24) <= ("XXXXXX" & drp_lock_cnt);
     dr_sram(25) <= ('X' & drp_lock_fb_dly & drp_unlock_cnt);
     dr_sram(26) <= ('X' & drp_lock_ref_dly & drp_lock_sat_high);
      dr_sram(40) <= "1XX11XX11XX11XX1";
      dr_sram(78) <= (pll_cp(3) & "XX" & pll_cp(2) & pll_cp(1) & "XX" & pll_cp(0) & "0XX00XXX");
      dr_sram(79) <= (pll_res(3) & "XX" & pll_res(2) & pll_res(1) & "XX" & pll_res(0) & pll_lfhf(1) & "XX" & pll_lfhf(0) & "XXXX");
      dr_sram(116) <= (tmpx(7 downto 3) & "00000000001" );

      first_time := false;

    end if;

    if (GSR_dly = '1') then
       drp_lock <= '0';
    elsif (rising_edge(dclk_in)) then 
    if (den_in = '1') then
       valid_daddr := addr_is_valid(daddr_in);
       if (valid_daddr) then
         address := slv_to_int(daddr_in);
         daddr_in_lat <= address;
       end if;

       if (drp_lock = '1') then
--          assert false report " Warning : DEN is high at MMCME2_ADV before DRDY high . Need wait for DRDY signal before next read/write operation through DRP. " severity  warning;
       else 
          drp_lock <= '1';
       end if;

       if (valid_daddr and ( address = 116  or address = 78 or address = 79 or
                        (address >= 24 and address <= 26) or
                       address = 40 or  (address >= 6 and address <= 22))) then
       else 
         Write ( Message, string'(" Warning :  Address DADDR="));
         Write ( Message,  address);
         Write ( Message, string'(" on the MMCME2_ADV instance is unsupported") );
         Write ( Message, '.' & LF );
         assert false report Message.all severity warning;
         DEALLOCATE (Message);
       end if;

       if (dwe_in = '1')  then
          if (rst_input = '1') then
             if (valid_daddr and ( address = 116  or address = 78 or address = 79 or
                        (address >= 24 and address <= 26) or
                       address = 40 or  (address >= 6 and address <= 22))) then
                  dr_sram(address) <= di_in;
                  di_str := SLV_TO_STR(di_in);
             end if;

             if (daddr_in = "0001001") then
                 daddr_str := "0001001";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout0_dly <= SLV_TO_INT(clkout_dly);
                 clk0_nocnt <= clk_nocnt;
                 clk0_nocnti := clk_nocnt;
                 clk0_edgei := clk_edge;
                 clk0_edge <= clk_edge;
                 clk0_frac <= SLV_TO_INT(di_in(14 downto 12));
                 if (di_in(11) = '1') then
                    clk0_frac_en <= 1;
                    clk0_frac_en_v := 1;
                 else
                    clk0_frac_en_v := 0;
                    clk0_frac_en <= 0;
                 end if;
             end if;

             if (daddr_in = "0001000") then
                daddr_str := "0001000";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk0_lt <= clk_lt;
                 clk0_ht <= clk_ht;
                 clk0_lti := clk_lt;
                 clk0_hti := clk_ht;
                 clk0pm_sel <=  SLV_TO_INT(clkpm_sel);
                 clk0pmr_sel <= SLV_TO_INT(di_in(15 downto 13));
             end if;

             if (daddr_in = "0001011") then
                 daddr_str := "0001011";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout1_dly <= SLV_TO_INT(clkout_dly);
                 clk1_nocnt <= clk_nocnt;
                 clk1_nocnti := clk_nocnt;
                 clk1_edgei := clk_edge;
                 clk1_edge <= clk_edge;
             end if;


             if (daddr_in = "0001010") then
                 daddr_str := "0001010";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk1_lt <= clk_lt;
                 clk1_ht <= clk_ht;
                 clk1_lti := clk_lt;
                 clk1_hti := clk_ht;
                 clk1pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "0001101") then
                 daddr_str := "0001101";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout2_dly <= SLV_TO_INT(clkout_dly);
                 clk2_nocnt <= clk_nocnt;
                 clk2_nocnti := clk_nocnt;
                 clk2_edgei := clk_edge;
                 clk2_edge <= clk_edge;
             end if;

             if (daddr_in = "0001100") then
                 daddr_str := "0001100";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk2_lt <= clk_lt;
                 clk2_ht <= clk_ht;
                 clk2_lti := clk_lt;
                 clk2_hti := clk_ht;
                 clk2pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "0001111") then
                 daddr_str := "0001111";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout3_dly <= SLV_TO_INT(clkout_dly);
                 clk3_nocnt <= clk_nocnt;
                 clk3_nocnti := clk_nocnt;
                 clk3_edgei := clk_edge;
                 clk3_edge <= clk_edge;
             end if;

             if (daddr_in = "0001110") then
                 daddr_str := "0001110";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk3_lt <= clk_lt;
                 clk3_ht <= clk_ht;
                 clk3_lti := clk_lt;
                 clk3_hti := clk_ht;
                 clk3pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "0010001") then
                 daddr_str := "0010001";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout4_dly <= SLV_TO_INT(clkout_dly);
                 clk4_nocnt <= clk_nocnt;
                 clk4_nocnti := clk_nocnt;
                 clk4_edgei := clk_edge;
                 clk4_edge <= clk_edge;
             end if;

             if (daddr_in = "0010000") then
                 daddr_str := "0010000";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk4_lt <= clk_lt;
                 clk4_ht <= clk_ht;
                 clk4_lti := clk_lt;
                 clk4_hti := clk_ht;
                 clk4pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "0000111") then
                 daddr_str := "0000111";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout5_dly <= SLV_TO_INT(clkout_dly);
                 clk5_nocnt <= clk_nocnt;
                 clk5_nocnti := clk_nocnt;
                 clk5_edgei := clk_edge;
                 clk5_edge <= clk_edge;
                 clk0pmf_sel <= SLV_TO_INT(di_in(13 downto 11));
             end if;

             if (daddr_in = "0000110") then
                 daddr_str := "0000110";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk5_lt <= clk_lt;
                 clk5_lti := clk_lt;
                 clk5_ht <= clk_ht;
                 clk5_hti := clk_ht;
                 clk5pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "0010011") then
                 daddr_str := "0010011";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkout6_dly <= SLV_TO_INT(clkout_dly);
                 clk6_nocnt <= clk_nocnt;
                 clk6_nocnti := clk_nocnt;
                 clk6_edgei := clk_edge;
                 clk6_edge <= clk_edge;
                 clkfbm1pmf_sel <= SLV_TO_INT(di_in(13 downto 11));
             end if;

             if (daddr_in = "0010010") then
                 daddr_str := "0010010";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clk6_lt <= clk_lt;
                 clk6_lti := clk_lt;
                 clk6_ht <= clk_ht;
                 clk6_hti := clk_ht;
                 clk6pm_sel <=  SLV_TO_INT(clkpm_sel);
             end if;

             if (daddr_in = "0010101") then
                 daddr_str := "0010101";
                 clkout_delay_para_drp (clkout_dly, clk_nocnt, clk_edge, di_in, daddr_in, di_str, daddr_str);
                 clkfbm1_dly <= SLV_TO_INT(clkout_dly);
                 clkfbm1_nocnt <= clk_nocnt;
                 clkfbm1_nocnti := clk_nocnt;
                 clkfbm1_edge <= clk_edge;
                 clkfbm1_edgei := clk_edge;
                 clkfb_frac <= SLV_TO_INT(di_in(14 downto 12));
                 if (di_in(11) = '1') then
                    clkfb_frac_en <= 1;
                    clkfb_frac_en_v := 1;
                 else
                    clkfb_frac_en_v := 0;
                 end if;
             end if;

             if (daddr_in = "0010100") then
                 daddr_str := "0010100";
                 clkout_hl_para_drp (clk_lt, clk_ht, clkpm_sel, di_in, daddr_in, di_str, daddr_str);
                 clkfbm1_lt <= clk_lt;
                 clkfbm1_lti := clk_lt;
                 clkfbm1_ht <= clk_ht;
                 clkfbm1_hti := clk_ht;
                 clkfbm1pm_sel <=  SLV_TO_INT(clkpm_sel);
                 clkfbm1pmr_sel <= SLV_TO_INT(di_in(15 downto 13));
             end if;

             if (daddr_in = "0010110") then
                 clkind_lti := ('0' & di_in(11 downto 6));
                 clkind_hti := ('0' & di_in(5 downto 0));
                 clkind_lt <= clkind_lti;
                 clkind_ht <= clkind_hti;
                 clkind_nocnti := di_in(12);
                 clkind_edgei := di_in(13);
              end if;

             if (clk0_frac_en_v = 0) then
              clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk0_hti, clk0_lti, clk0_nocnti, clk0_edgei);
              clk0_ht1 <= clk_ht1;
              clk0_div <= clk_div;
              clk0_div1 <= clk_div1;
             end if;
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
              clkout_pm_cal(clk_ht1, clk_div, clk_div1, clk6_hti, clk6_lti, clk6_nocnti, clk6_edgei);
              clk6_ht1 <= clk_ht1;
              clk6_div <= clk_div;
              clk6_div1 <= clk_div1;
             if (clkfb_frac_en_v = 0) then
              clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm1_hti, clkfbm1_lti, clkfbm1_nocnti, clkfbm1_edgei);
              clkfbm1_ht1 <= clk_ht1;
              clkfbm1_div <= clk_div;
              clkfbm1_div1 <= clk_div1;
                if (clk_div > 64 or clk_div < 2 ) then
                assert false report " Input Error : The sum of DI[11:6] and DI[5:0] Address DADDR=0010100 is CLKFBOUT clock divider of MMCME2_ADV and over the 2 to 64 range." severity error;
                end if;
             end if;
              clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkfbm2_hti, clkfbm2_lti, clkfbm2_nocnti, clkfbm2_edgei);
              clkfbm2_ht1 <= clk_ht1;
              clkfbm2_div <= clk_div;
              clkfbm2_div1 <= clk_div1;
              clkout_pm_cal(clk_ht1, clk_div, clk_div1, clkind_hti, clkind_lti, clkind_nocnti, '0');
              clkind_ht1 <= clk_ht1;
              clkind_div <= clk_div;
              clkind_div1 <= clk_div1;
              if (clk_div > 106 or (clk_div < 1 and clkind_nocnti = '0')) then
                assert false report " Input Error : The sum of DI[11:6] and DI[5:0] Address DADDR=0010110 is input clock divider of MMCME2_ADV and over the 1 to 106 range." severity error;
              end if;

          else 
              assert false report " Error : RST is low at MMCME2_ADV. RST need to be high when change MMCME2_ADV paramters through DRP. " severity error;
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
    end if; -- end GSR_dly

    wait on dclk_in, GSR_dly, init_done;
    end process;


  clkfb_frac_para_p : process (clkfbm1_ht, clkfbm1_lt, clkfb_frac, clkfb_frac_en, clkfbm1pmf_sel)
     variable clkfb_frac_int : integer;
     variable clkfbm1_ht_int : integer;
     variable clkfbm1_lt_int : integer;
     variable clkfbm1_odd_frac_v : integer;
     variable tmp_fbo : real;
     variable tmp_fbq : integer;
     variable tmp_fbp  : real;
     variable clkfbm1_f_div_v : real; 
     variable clkfb_div_fint_v : integer;
     variable clkfb_div_fint_vr : real;
     variable clkfb_div_frac_int : integer;
     variable clkfb_div_frac_v : real;
     variable clkfb_div_fint_tmp1 : integer;
     variable clkfb_div_fint_odd : integer;
     variable clkfbpmf_sel_int : integer;
     variable Message : line;
  begin
    if (clkfb_frac_en = 1) then
     clkfb_frac_int := clkfb_frac;
     clkfbm1_lt_int := SLV_TO_INT(clkfbm1_lt);
     clkfbm1_ht_int := SLV_TO_INT(clkfbm1_ht);
     clkfbpmf_sel_int := clkfbm1pmf_sel;
     if (clkfb_div_adj = 1) then
       if (clkfbpmf_sel_int < 4) then
        clkfbm1_odd_frac_v := clkfb_frac_int;
         tmp_fbo := 0.0;
         tmp_fbq := 2 * clkfbm1_lt_int - clkfbm1_ht_int + 1;
       elsif (clkfbpmf_sel_int > 4 ) then
         clkfbm1_odd_frac_v := clkfb_frac_int + 8;
         tmp_fbo := 1.0;
         tmp_fbq := 2 * clkfbm1_lt_int - clkfbm1_ht_int;
       else 
         clkfbm1_odd_frac_v := clkfb_frac_int + 8;
         tmp_fbo := 1.0;
         tmp_fbq := 2 * clkfbm1_lt_int - clkfbm1_ht_int + 1;
       end if;
     tmp_fbp := real(clkfbm1_odd_frac_v) / 8.0 - tmp_fbo;
     clkfbm1_f_div_v := 2.0 * real(tmp_fbq)  + tmp_fbp + tmp_fbo;
     end if;
     clkfbm1_f_div <= clkfbm1_f_div_v;
     clkfb_div_fint_v := real2int(clkfbm1_f_div_v);
     clkfb_div_fint_vr := real(clkfb_div_fint_v);
     clkfb_div_frac_v := clkfbm1_f_div_v - clkfb_div_fint_vr;
     clkfb_div_frac <= clkfb_div_frac_v;
     clkfb_div_frac_int := real2int(clkfb_div_frac_v * 8.0);
     clkfb_div_fint_tmp1 := clkfb_div_fint_v / 2;
     clkfb_div_fint_odd := clkfb_div_fint_v - clkfb_div_fint_tmp1 -clkfb_div_fint_tmp1;

      clkfbm1_fht <= clkfb_div_fint_v /2;
      clkfbm1_flt <= clkfb_div_fint_v /2;
      if (clkfb_div_fint_odd > 0) then
        clkfbm1r_sel <= (8 + clkfb_div_frac_int) / 2;
        clkfbm1f_sel <= 8 + clkfb_div_frac_int - (8 + clkfb_div_frac_int) / 2 ;
        clkfbm1pm_sel_int <= 8 + clkfb_div_frac_int - (8 + clkfb_div_frac_int) / 2 ;
      else 
         clkfbm1f_sel <= clkfb_div_frac_int - clkfb_div_frac_int / 2;
         clkfbm1pm_sel_int <= clkfb_div_frac_int - clkfb_div_frac_int / 2;
         clkfbm1r_sel <= clkfb_div_frac_int / 2;
      end if;
      mf_product <= real2int(clkfbm1_f_div_v * 8.0 ); 
      mf_product1 <= real2int(clkfbm1_f_div_v * 8.0 ) - 1; 
    else
     clkfbm1_f_div_v := CLKFBOUT_MULT_F_RND;
     mf_product <=  real2int(clkfbm1_f_div_v * 8.0 ); 
     mf_product1 <= real2int(clkfbm1_f_div_v * 8.0 ) - 1; 

    end if;   
  end process;


  clk0_frac_para_p : process (clk0_ht, clk0_lt, clk0_frac, clk0_frac_en, clk0pmf_sel)
     variable clk0_frac_int : integer;
     variable clk0_ht_int : integer;
     variable clk0_lt_int : integer;
     variable clk0_odd_frac_v : integer;
     variable tmp_f0o : real;
     variable tmp_f0q : integer;
     variable tmp_f0p  : real;
     variable clk0_f_div_v : real; 
     variable clk0_div_fint_v : integer;
     variable clk0_div_fint_vr : real;
     variable clk0_div_frac_int : integer;
     variable clk0_div_frac_v : real;
     variable clk0_div_fint_tmp1 : integer;
     variable clk0_div_fint_odd : integer;
     variable clk0pmf_sel_int : integer;
     variable Message : line;
  begin
     clk0_frac_int := clk0_frac;
     clk0_lt_int := SLV_TO_INT(clk0_lt);
     clk0_ht_int := SLV_TO_INT(clk0_ht);
     clk0pmf_sel_int := clk0pmf_sel;
     if (clk0_div_adj = 1) then
       if (clk0pmf_sel_int < 4) then
        clk0_odd_frac_v := clk0_frac_int;
         tmp_f0o := 0.0;
         tmp_f0q := 2 * clk0_lt_int - clk0_ht_int + 1;
       elsif (clk0pmf_sel_int > 4 ) then
         clk0_odd_frac_v := clk0_frac_int + 8;
         tmp_f0o := 1.0;
         tmp_f0q := 2 * clk0_lt_int - clk0_ht_int;
       else 
         clk0_odd_frac_v := clk0_frac_int + 8;
         tmp_f0o := 1.0;
         tmp_f0q := 2 * clk0_lt_int - clk0_ht_int + 1;
       end if;
       tmp_f0p := real(clk0_odd_frac_v) / 8.0 - tmp_f0o;
       clk0_f_div_v := 2.0 * real(tmp_f0q)  + tmp_f0p + tmp_f0o;
--     clk0_f_div <= clk0_f_div_v;
       clk0_div_fint_v := real2int(clk0_f_div_v);
     end if;
     clk0_f_div_v := CLKOUT0_DIVIDE_F_RND;
     clk0_div_fint_v := real2int(clk0_f_div_v);
     clk0_div_fint <= clk0_div_fint_v;
     clk0_div_fint_vr := real(clk0_div_fint_v);
     clk0_div_frac_v := clk0_f_div_v - clk0_div_fint_vr;
--     clk0_div_frac <= clk0_div_frac_v;
     clk0_div_frac_int := real2int(clk0_div_frac_v * 8.0);
     clk0_div_fint_tmp1 := clk0_div_fint_v / 2;
     clk0_div_fint_odd := clk0_div_fint_v - clk0_div_fint_tmp1 -clk0_div_fint_tmp1;

      clk0_fht <= clk0_div_fint_v /2;
      clk0_flt <= clk0_div_fint_v /2;
      if (clk0_div_fint_odd > 0) then
        clk0pm_rsel <= (8 + clk0_div_frac_int) / 2;
        clk0pm_fsel <= 8 + clk0_div_frac_int - (8 + clk0_div_frac_int) / 2 ;
        clk0pm_sel_int <= 8 + clk0_div_frac_int - (8 + clk0_div_frac_int) / 2 ;
      else 
         clk0pm_fsel <= clk0_div_frac_int - clk0_div_frac_int / 2;
         clk0pm_sel_int <= clk0_div_frac_int - clk0_div_frac_int / 2;
         clk0pm_rsel <= clk0_div_frac_int / 2;
      end if;
  end process;


  clkfb_frac_ht_lt_p : process (period_vco_frl, clkfbm1_fht, clkfbm1_flt, clkfbm1r_sel, clkfbm1pm_sel_int) begin
    clkfb_frac_ht <= period_vco_frl * clkfbm1_fht + (period_vco_frl * clkfbm1pm_sel_int) / 8;
    clkfb_frac_lt <= period_vco_frl * clkfbm1_flt + (period_vco_frl * clkfbm1r_sel) / 8;
  end process;

  clk0_frac_ht_lt_p : process(period_vco_frl, clk0_fht, clk0_flt, clk0pm_sel_int, clk0pm_rsel) begin
    clk0_frac_ht <= period_vco_frl * clk0_fht + (period_vco_frl * clk0pm_sel_int) / 8;
    clk0_frac_lt <= period_vco_frl * clk0_flt + (period_vco_frl * clk0pm_rsel) / 8;
  end process;


    lock_tm_p : process ( m_product, md_product, mf_product, clkfb_frac_en, fb_delay_found)
       variable clkout_en_time_v : integer := 0;
       variable locked_en_time_v : integer := 0;
    begin
     if (fb_delay_found = '1') then
        if (clkfb_frac_en = 0) then 
--          clkout_en_val <= m_product;
         
          clkout_en_time_v := md_product + pll_lock_time;
--          locked_en_time_v := md_product +  clkout_en_time_v + 2;
          locked_en_time_v := md_product +  md_product + pll_lock_time + 2;
          clkout_en_time <= clkout_en_time_v;
          locked_en_time <= locked_en_time_v;
          lock_cnt_max <= locked_en_time_v + 16;
        else 
--          clkout_en_val <= mf_product - 2;
          clkout_en_time_v := mf_product + 4 + pll_lock_time;
--          locked_en_time_v := md_product +  clkout_en_time_v + 2;
          locked_en_time_v := md_product +  mf_product + 4 + pll_lock_time + 2;
          clkout_en_time <= clkout_en_time_v;
          locked_en_time <= locked_en_time_v;
          lock_cnt_max <= locked_en_time_v + 16;
      end if;
     end if;
    end process;


    ps_in_ps_p : process(psclk_in, rst_in, init_done)
        variable ps_cnt_neg : integer;
        variable ps_in_ps_neg : integer;
    begin
      if (rising_edge(init_done)) then
        ps_in_ps <= ps_in_init;
        ps_cnt <= 0;
      end if;

      if (rst_in = '1') then
        ps_in_ps <= ps_in_init;
        ps_cnt <= 0;
        psen_w <= '0';
      elsif (rising_edge(psclk_in)) then
        if (fps_en = 1)  then
          if (psen_in = '1')  then
            if (psen_w = '1') then
              assert false report " Error : PSEN on MMCME2_ADV is active more than 1 PSCLK period. PSEN must be active for only one PSCLK period. "
              severity warning;
            end if;
            psen_w <= '1';
            if (ps_lock = '1') then
              assert false report " Warning : Please wait for PSDONE signal before adjusting the Phase Shift. " 
              severity warning;
            elsif (psincdec_in = '1') then
              if (ps_cnt < ps_max) then
                 ps_cnt <= ps_cnt + 1;
              else
                 ps_cnt <= 0;
              end if;
              if (ps_in_ps < ps_max) then
                 ps_in_ps <= ps_in_ps + 1;
              else
                 ps_in_ps <= 0;
              end if;
              ps_lock <= '1';
            elsif (psincdec_in = '0') then
              ps_cnt_neg := (-1) * ps_cnt;
              ps_in_ps_neg := (-1) * ps_in_ps;
              if (ps_cnt_neg < ps_max) then
                ps_cnt <= ps_cnt - 1;
              else
                 ps_cnt <= 0;
              end if;
              if (ps_in_ps_neg < ps_max) then
                 ps_in_ps <= ps_in_ps - 1;
              else
                 ps_in_ps <= 0;
              end if;
              ps_lock <= '1';
            end if;
            else
            psen_w <= '0';
          end if;
          if ( psdone_out = '1') then
             ps_lock <= '0';
          end if;
        end if;
      end if;
    end process;

    psdone_out_p : process
    begin
      if (rising_edge(ps_lock)) then
        if (fps_en = 1) then
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          wait until (rising_edge(psclk_in));
          psdone_out <= '1';
          wait until (rising_edge(psclk_in));
          psdone_out <= '0';
        end if;
      end if;
      wait on ps_lock;
    end process;

    CLOCK_PERIOD_P : process (clkpll_r, rst_in, rst_clkinsel_flag)
      variable  clkin_edge_previous : time := 0 ps;
      variable  clkin_edge_current : time := 0 ps;
      variable  period_clkin_v : time := 0 ps;
    begin
      if (rst_in = '1' or rst_clkinsel_flag = '1') then
        if (clkinsel_in = '0') then
          period_clkin_v := CLKIN2_PERIOD * 1000 ps;
        else
          period_clkin_v := CLKIN1_PERIOD * 1000 ps;
        end if;
        clkin_period(0) <= period_clkin_v;
        clkin_period(1) <= period_clkin_v;
        clkin_period(2) <= period_clkin_v;
        clkin_period(3) <= period_clkin_v;
        clkin_period(4) <= period_clkin_v;
        clkin_jit <= 0 ps;
        clkin_lock_cnt <= 0;
        pll_locked_tm <= '0';
        pll_locked_tmp1 <= '0';
        lock_period <= '0';
        clkout_en0_tmp <= '0';
        unlock_recover <= '0';
        clkin_edge_previous := 0 ps;
      elsif (rising_edge(clkpll_r)) then
        clkin_edge_current := NOW;
        if (clkin_edge_previous /= 0 ps and  clkinstopped_out = '0' and
            rst_clkinsel_flag = '0') then
          clkin_period(4) <= clkin_period(3);
          clkin_period(3) <= clkin_period(2);
          clkin_period(2) <= clkin_period(1);
          clkin_period(1) <= clkin_period(0);
          clkin_period(0) <= clkin_edge_current - clkin_edge_previous;
        end if;

        if (pll_unlock = '0' and clkin_edge_previous /= 0 ps and  clkinstopped_out = '0') then
          clkin_jit <=  clkin_edge_current - clkin_edge_previous - clkin_period(0);
        else
          clkin_jit <= 0 ps;
        end if;

        clkin_edge_previous := clkin_edge_current;

        if ( pll_unlock1 = '0' and  (clkin_lock_cnt < lock_cnt_max) and fb_delay_found = '1' ) then
            clkin_lock_cnt <= clkin_lock_cnt + 1;
        elsif (pll_unlock1 = '1' and pll_locked_tmp1 = '1' ) then
            clkin_lock_cnt <= lock_cnt_max - 6;
            unlock_recover <= '1';
        end if;

        if ( clkin_lock_cnt >= PLL_LOCK_TIME and pll_unlock1 = '0') then
            pll_locked_tm <= '1';
        end if;

        if ( clkin_lock_cnt = lock_period_time ) then
            lock_period <= '1';
        end if;

        if (clkin_lock_cnt >= clkout_en_time and pll_locked_tm = '1') then
            clkout_en0_tmp <= '1';
        end if;
 
        if (clkin_lock_cnt >= locked_en_time and clkout_en = '1') then
            pll_locked_tmp1 <= '1';
        end if;

        if (unlock_recover = '1' and clkin_lock_cnt  >= lock_cnt_max) then
            unlock_recover <= '0';
        end if;

      end if;
    end process;
    

  pchk_p : process(pll_locked_tmp1)
    variable pchk_tmp1 : time;
    variable pchk_tmp2 : time;
  begin
  if (rising_edge(pll_locked_tmp1)) then
    if (clkinsel_in = '0') then
       pchk_tmp1 := CLKIN2_PERIOD * 1100 ps;
       pchk_tmp2 := CLKIN2_PERIOD * 900 ps;
       if (period_avg > pchk_tmp1 or  period_avg < pchk_tmp2) then
         assert false report "Warning : input CLKIN2 period and attribute CLKIN2_PERIOD are not same." severity warning ;
       end if;
    else 
       pchk_tmp1 := CLKIN1_PERIOD * 1100 ps;
       pchk_tmp2 := CLKIN1_PERIOD * 900 ps;
       if (period_avg > pchk_tmp1 or  period_avg < pchk_tmp2) then
         assert false report "Warning : input CLKIN1 period and attribute CLKIN1_PERIOD are not same." severity warning ;
       end if;
    end if;
  end if;
  end process;

    clkout_en_val <= mf_product1 when (clkfb_frac_en = 1) else m_product1;
    clkout_en0_tmp1 <=   clkout_en0_tmp after 1 ps;

    CLKOUT_EN0_P : process (clkout_en0_tmp1, clkout_en_t, clkout_en0_tmp)
    begin
      if (clkout_en0_tmp = '0') then
        clkout_en0 <= '0';
      else
       if (clkfb_frac_en = 1) then
--         if (clkout_en_t > clkout_en_val and  clkout_en0_tmp1 = '1') then
         if (clkout_en_t >= clkout_en_val and  clkout_en0_tmp1 = '1') then
             clkout_en0 <=  transport clkout_en0_tmp1 after (period_vco6);
         end if;
       else
           if (clkout_en_t = clkout_en_val and clkout_en0_tmp1 = '1') then
--             clkout_en0 <=  transport clkout_en0_tmp1 after (period_vco6);
             clkout_en0 <=  transport clkout_en0_tmp1 after (period_vco6 + period_vco);
           end if;
       end if;
      end if;
     end process;
 
    clkout_en1 <=  transport clkout_en0 after clkvco_delay;


    clkout_en_p : process (clkout_en1, rst_in_o)
    begin
      if (rst_in_o = '1') then
        clkout_en <= '0';
      else
          clkout_en <= clkout_en1;
      end if;
    end process;

    PLL_LOCK_P1 : process (pll_locked_tmp1, rst_in)
    begin
      if (rst_in = '1') then
         pll_locked_tmp2 <= '0';
      elsif (pll_locked_tmp1 = '0') then
         pll_locked_tmp2 <=  pll_locked_tmp1;
      else 
         pll_locked_tmp2 <= transport pll_locked_tmp1 after pll_locked_delay;
      end if;
    end process;

    locked_out <= '1' when pll_locked_tm = '1' and pll_locked_tmp2 ='1' and pll_unlock = '0' and unlock_recover = '0' else '0';

    locked_out_tmp_p : process
    begin
      if (rst_in = '1') then
           wait for 1 ns;   -- lock delay simprim only 
           locked_out_tmp <= '0';
      else
         locked_out_tmp <= locked_out;
      end if;
      wait on rst_in, locked_out;
    end process;

 
    CLOCK_PERIOD_AVG_P : process (clkin_period(0), clkin_period(1), clkin_period(2),
                                 clkin_period(3), clkin_period(4), period_avg)
      variable period_avg_tmp : time := 0 ps;
      variable clkin_period_tmp0 : time := 0 ps;
      variable clkin_period_tmp1 : time := 0 ps;
      variable clkin_period_tmp_t : time := 0 ps;
    begin
      clkin_period_tmp0 := clkin_period(0);
      clkin_period_tmp1 := clkin_period(1);
      if (clkin_period_tmp0 > clkin_period_tmp1) then
          clkin_period_tmp_t := clkin_period_tmp0 - clkin_period_tmp1;
      else
          clkin_period_tmp_t := clkin_period_tmp1 - clkin_period_tmp0;
      end if;

      if (clkin_period_tmp0 /= period_avg and (clkin_period_tmp0 < 1.5 * period_avg or clkin_period_tmp_t <= 300 ps)) then
         period_avg_tmp := (clkin_period(0) + clkin_period(1) + clkin_period(2)
                       + clkin_period(3) + clkin_period(4))/5.0;
         period_avg <= period_avg_tmp;
      end if;
    end process;

   clkinstopped_hold_p : process (clkinstopped_out_dly, rst_in)
   begin
     if (rst_in = '1') then
        clkinstopped_hold <= '0';
     else
       if (clkinstopped_out = '1') then
         clkinstopped_hold <=   '1' after 1 ps;
       else
         if (clkin_hold_f = 1) then
            clkinstopped_hold <= '0';
         end if;
       end if;
    end if;
  end process;

  pd_stp_p_p : process
  begin
    if (rst_in = '1') then
       pd_stp_p <=  '0';
    elsif (rising_edge(clkinstopped_out)) then
     period_avg_stpi <= period_avg;
     wait for 1 ps;
     pd_stp_p <=  '1';
     wait until falling_edge(clkvco) or rising_edge(rst_in);
     wait for 1 ps;
      pd_stp_p <=  '0';
    end if;
     wait on clkinstopped_out, rst_in, clkvco;
    end process;

   period_avg_stp_p : process(clkvco,  rst_in,  pd_stp_p)
   begin
   if (rst_in = '1') then
     period_avg_stp <= 1000 ps;
     vco_stp_f <= '0';
   elsif (rising_edge(pd_stp_p)) then
       period_avg_stp <=  period_avg_stpi;
   elsif (falling_edge(clkvco)) then
     if (clkinstopped_out_dly2 = '1' and  clkin_hold_f = 0) then
       if (period_vco > 1739 ps) then
        vco_stp_f <= '1';
       else
          period_avg_stp  <= period_avg_stp + 1 ps;
       end if;
     end if;
   end if;
   end process;

    clk_period_lost_p : process (period_avg,  lock_period, clkind_div)
    begin
     if (period_avg > 500 ps and lock_period = '1') then
       clkin_lost_val <= ((period_avg * 1.5) / 500 ps) - 1;
       clkfb_lost_val <= ((clkind_div * period_avg * 1.5) / 500 ps) - 1;
     end if;
    end process;

    clkfbm1_div_t_p : process (clkfb_frac_en, clkfbm1_f_div, clkfbm1_div)
      variable clkfbm1_div_t_tmp : real;
    begin
      if (clkfb_frac_en = 1) then
         clkfbm1_div_t <= clkfbm1_f_div;
      else
         clkfbm1_div_t_tmp := real(clkfbm1_div);
         clkfbm1_div_t <= clkfbm1_div_t_tmp;
      end if;
    end process;

    CLOCK_PERIOD_UPDATE_P : process (period_avg, period_avg_stp, clkind_div, clkfbm1_div_t, init_done, clkinstopped_hold, fb_delay_found)
      variable period_fb_tmp : time := 0 ps;
      variable period_vco_tmp : time := 0 ps;
      variable period_vco_tmp1 : time := 0 ps;
      variable period_vco_tmp1_i : integer := 0;
      variable period_vco_tmp1_rl : real := 0.0;
      variable tmpreal : real := 0.0;
      variable tmpreal1: real := 0.0;
      variable period_vco_rm_tmp : integer := 0;
      variable period_vco_rm_tmp1 : integer := 0;
      variable clkind_div_rl : real := 0.0;
      variable clkfbm1_div_t_int : integer := 0;
      variable period_fb_tmpint  : integer := 0;
      variable period_fb_tmpreal : real := 0.0;
      variable period_vco_tmpint : integer := 0;
      variable period_vco_tmpint1 : integer := 0;
      variable clk0_frac_ht_tmp : integer := 0;
      variable clk0_frac_lt_tmp : integer := 0;
      variable clkfb_frac_ht_tmp : integer := 0;
      variable clkfb_frac_lt_tmp : integer := 0;
      variable period_vco_tmp0 : real := 0.0;
      variable period_vco_tmp02 : real := 0.0;
      variable period_vco_tmp03 : real := 0.0;
      variable period_vco_half_rm_t : time := 0 ps;
      variable clkvco_var : real := 1.0;
      variable clkvco_div_fint1 : real := 0.0;
      variable clkvco_div_fint : integer := 0;
      variable clkvco_div_frac : real := 0.0;
      variable clkvco_frac_en_v : integer := 0;
       
    begin
      if (init_done = '1' and fb_delay_found = '1') then
       clkind_div_rl := real(clkind_div);
       clkfbm1_div_t_int := real2int(clkfbm1_div_t);
       md_product <= real2int(clkfbm1_div_t * clkind_div_rl);
       m_product <= clkfbm1_div_t_int;
       m_product1 <= clkfbm1_div_t_int - 1;
       m_product2 <= real2int(clkfbm1_div_t / 2.0);
       clkvco_var := clkfbm1_div_t / clkind_div_rl;
       clkvco_div_fint := real2int(clkvco_var);
       clkvco_div_fint1 := real(clkvco_div_fint);
       clkvco_div_frac := clkvco_var - clkvco_div_fint1;
       if (clkvco_div_frac > 0.000) then
         clkvco_frac_en <= 1;
         clkvco_frac_en_v := 1;
       end if;
       period_fb_tmp :=  clkind_div * period_avg;
       if (period_fb_tmp > 0 ps ) then
          period_fb_tmpint := period_fb_tmp / 1 ps;
       else
          period_fb_tmpint := 0;
       end if;
       period_vco_mf <= (period_avg / 1 ps ) * 8;
       period_fb_tmpreal := real(period_fb_tmpint);
       period_vco_tmp0 := (period_fb_tmpreal / clkfbm1_div_t);
       period_vco_frl <= period_vco_tmp0 * 1 ps;
       period_vco_tmpint1 := real2int(period_vco_tmp0);
       period_vco_tmp02 := real(period_vco_tmpint1);
       period_vco_tmp03 := period_vco_tmp0 - period_vco_tmp02;
       if (period_vco_tmp03 > 0.500) then
          period_vco_tmp1 := (1 + period_vco_tmpint1) * 1 ps;
       else
          period_vco_tmp1 := period_vco_tmpint1 * 1 ps;
       end if;
       period_vco_tmp1_i := period_vco_tmp1 / 1 ps; 
       period_vco_tmp1_rl := real(period_vco_tmp1_i);
       clkvco_pdrm <= period_vco_tmp0 - period_vco_tmp1_rl;
       if (clkinstopped_hold = '1') then
         if (clkin_hold_f = 1 and (period_vco_tmp1 < 20000 ps)) then
           period_vco_tmp := ((20000 * period_vco_tmp1) / (20000 ps - period_vco_tmp1)) * 1 ps;
         elsif (clkin_hold_f = 0) then
           period_vco_tmp := period_avg_stp * clkind_div / clkfbm1_div_t_int;
         end if;
       else
         period_vco_tmp := period_vco_tmp1;
       end if;
       if (period_vco_tmp > 0 ps) then
         period_vco_tmpint := period_vco_tmp / 1 ps; 
       else
         period_vco_tmpint := 0;
       end if;
--       period_vco_rm_tmp := period_vco_tmpint mod clkfbm1_div_t_int;
       period_vco_rm_tmp := period_fb_tmpint mod clkfbm1_div_t_int;
       period_vco_rm <= period_vco_rm_tmp;
       if (period_vco_rm_tmp > 1) then
         if (period_vco_rm_tmp > m_product2 and period_vco_rm_tmp < m_product)  then
           period_vco_cmp_cnt <= (m_product / (m_product - period_vco_rm_tmp)) - 1;
           period_vco_cmp_flag <= 2;
         else 
           period_vco_cmp_cnt <= (m_product / period_vco_rm_tmp) - 1;
           period_vco_cmp_flag <= 1;
         end if;
       else 
         period_vco_cmp_cnt <= 0;
         period_vco_cmp_flag <= 0;
       end if;

       period_vco_half <= period_vco_tmp /2;
       if (period_vco_tmp > 0 ps) then
         period_vco_half1 <= ((period_vco_tmp /2) / 1 ps + 1) * 1 ps;
       else
         period_vco_half1 <= 0 ps;
       end if;
       period_vco_half_rm_t := period_vco_tmp - (period_vco_tmp /2);
       period_vco_half_rm <= period_vco_half_rm_t;
       period_vco_half_rm1 <= period_vco_half_rm_t + 1 ps;
       if (period_vco_half_rm_t > 1 ps ) then
         period_vco_half_rm2 <= period_vco_half_rm_t - 1 ps;
       else
         period_vco_half_rm2 <= 0 ps;
       end if;
       pll_locked_delay <= period_fb_tmp * clkfbm1_div_t;
       clkin_dly_t <=  period_avg * clkind_div + period_avg * 1.25;
       clkfb_dly_t <= period_fb_tmp * 2.25; 
       period_fb <= period_fb_tmp;
       period_vco <= period_vco_tmp;
       period_vco1 <= period_vco_tmp / 8.0;
       period_vco2 <= period_vco_tmp / 4.0;
       period_vco3 <= period_vco_tmp * 3.0 / 8.0;
       period_vco4 <= period_vco_tmp / 2.0;
       period_vco5 <= period_vco_tmp * 5.0 / 8.0;
       period_vco6 <= period_vco_tmp * 3.0 / 4.0;
       period_vco7 <= period_vco_tmp * 7.0 / 8.0;
--       period_vco_en <= period_vco_tmp * 2.0  - period_vco_tmp / 4.0;
       period_vco_en <= period_vco_tmp * 2.0  - period_vco_tmp / 4.0;
--       clk0_frac_ht_tmp := period_vco_tmpint * clkout0_fdly + (period_vco_tmpint * clk0pm_fsel) / 8;
--       clk0_frac_ht <= clk0_frac_ht_tmp * 1 ps;
--       clk0_frac_lt_tmp := period_vco_tmpint * clkout0_rdly + (period_vco_tmpint * clk0pm_rsel) / 8;
--       clk0_frac_lt <= clk0_frac_lt_tmp * 1 ps;
--       clkfb_frac_ht_tmp := period_vco_tmpint * clkfbm1_fdly + (period_vco_tmpint * clkfbm1f_sel) / 8;
--       clkfb_frac_ht <= clkfb_frac_ht_tmp * 1 ps;
--       clkfb_frac_lt_tmp := period_vco_tmpint * clkfbm1_rdly + (period_vco_tmpint * clkfbm1r_sel) / 8;
--       clkfb_frac_lt <= clkfb_frac_lt_tmp * 1 ps;
      pvco_init_f <= '1'; 
     end if;
    end process;

    period_vco_p : process(period_vco, ps_in_ps) 
      variable period_vco_ps_tmp1 : integer;
      variable period_vco_ps_tmp2 : integer;
    begin
    if (fps_en = 1 ) then
      period_ps_old <= period_ps;
      period_vco_ps_tmp1 := period_vco / 1 ps;
      period_vco_ps_tmp2 := (period_vco_ps_tmp1 * ps_in_ps) / 56;
      if (ps_in_ps < 0) then
         period_ps <= (period_vco_ps_tmp1 + period_vco_ps_tmp2) * 1 ps;
      elsif (ps_in_ps = 0 and psincdec_in = '0') then
         period_ps <=  period_vco;
      else
         period_ps <= period_vco_ps_tmp2 * 1 ps;
      end if;
    end if;
    end process;

    clkpll_tmp1 <=  transport clkpll_r after period_avg;
    clkpll <=  transport clkpll_tmp1 after period_avg;

    clkinstopped_vco_f_p : process
    begin
      if (rst_in = '1') then
         clkinstopped_vco_f <= '0';
      elsif (rising_edge(clkinstopped_out)) then
        clkinstopped_vco_f <= '1';
        wait until (falling_edge(clkinstopped_out) or rising_edge(rst_in));
        if (rst_in = '1') then
          clkinstopped_vco_f <= '0';
        else
           wait until (rising_edge(clkpll) );
           wait until (rising_edge(clkpll) );
           clkinstopped_vco_f <= '0';
        end if;
      end if;
      wait on clkinstopped_out, rst_in;
    end process;

    rst_clkinstopped_tm <= '1' when ((clkout_en_t >= clkout_en_val - 3) and (clkout_en_t < clkout_en_val)) else '0';
                    
  rst_clkinstopped_p : process
  begin
    if (rst_in = '1') then
        rst_clkinstopped <= '0';
        rst_clkinstopped_rc <= '0';
    elsif (falling_edge(clkinstopped_out)) then
       if (rst_clkinstopped_lk = '0' and clkin_hold_f = 1) then
          wait until rising_edge(rst_clkinstopped_tm) or  rising_edge(rst_in);
          if (rst_in = '0') then
          rst_clkinstopped <= '1' after period_vco4;
          wait until falling_edge(rst_clkinstopped_tm) or  rising_edge(rst_in);
          wait for period_vco5;
          rst_clkinstopped <= '0';
          wait for period_vco1;
          rst_clkinstopped_rc <= '1';
          wait for period_vco1;
          rst_clkinstopped_rc <= '0';
          else
           rst_clkinstopped <= '0';
           rst_clkinstopped_rc <= '0';
          end if;
       end if;
    end if;
    wait on clkinstopped_out, rst_clkinstopped_tm, rst_in;
  end process;

  clkinstopped_out_dly_p : process
  begin
     if (rst_in = '1') then
        clkinstopped_out_dly <= '0';
     elsif (rising_edge(clkinstopped_out)) then
         clkinstopped_out_dly <= '1';
         if (clkin_hold_f  = 1) then
         wait until falling_edge(rst_clkinstopped_rc) or rising_edge(rst_in);
         clkinstopped_out_dly <= '0';
         end if;
     end if;
     wait on clkinstopped_out, rst_clkinstopped_rc, rst_in;
  end process;

  clkinstopped_out_dly2_p :  process (clkinstopped_out, rst_in)
  begin
     if (rst_in = '1') then
       clkinstopped_out_dly2 <= '0';
     else
        clkinstopped_out_dly2 <=  clkinstopped_out after 2 ps;
     end if;
  end process;

  rst_clkinstopped_lk_p : process
  begin
    if (rst_in = '1') then
       rst_clkinstopped_lk <= '0';
    elsif (falling_edge(rst_clkinstopped)) then
       rst_clkinstopped_lk <= '1';
       wait until (rising_edge(locked_out));
       rst_clkinstopped_lk <= '0';
    end if;
    wait on rst_clkinstopped, locked_out, rst_in;
   end process; 

    clkvco_lk_p : process
    begin
      if (rst_in = '1') then
        clkvco_lk <= '0';
      else
        if (clkinstopped_out1 = '1' and  clkin_stop_f = '0') then
          if (period_vco_half > 0 ps) then
            clkvco_lk <= transport not clkvco_lk after period_vco_half;
          end if;
        elsif (clkinstopped_vco_f = '0') then
           clkvco_lk <= clkvco_lk_tmp;
        else
          if (period_vco_half > 0 ps) then
            clkvco_lk <= transport not clkvco_lk after period_vco_half;
          end if;
        end if;
      end if;
      wait on clkinstopped_vco_f, clkvco_lk, clkvco_lk_tmp, rst_in, clkinstopped_out1;
    end process;


    CLKVCO_LK_TMP_P : process
       variable clkvco_rm_cnt : integer;
       variable cmpvco1 : real := 0.0;
       variable cmpvco : real := 0.0;
       variable vcoflag : integer := 0;
    begin
      if (rising_edge(clkpll)) then
        if (clkfb_frac_en = 1 or clkvco_frac_en = 1) then
          if (pll_locked_tm = '1') then
            cmpvco := 0.0;
            clkvco_lk_tmp <= '1';
            for I in 2 to mf_product loop
              wait for period_vco_half;
              clkvco_lk_tmp <= '0';
              if ( cmpvco >= 1.0 ) then
                  wait for period_vco_half_rm1;
                  clkvco_lk_tmp <= '1';
                  cmpvco1 := cmpvco - 1.0 + clkvco_pdrm;
               elsif ( cmpvco <= -1.0 ) then
                  wait for period_vco_half_rm2;
                   clkvco_lk_tmp <= '1';
                  cmpvco1 := cmpvco + 1.0 + clkvco_pdrm;
               else 
                  wait for period_vco_half_rm;
                  clkvco_lk_tmp <= '1';
                  cmpvco1 := cmpvco + clkvco_pdrm;
               end if;
              cmpvco := cmpvco1;
              clkout_en_t <= I - 1;
            end loop;
            wait for period_vco_half;
            clkvco_lk_tmp <= '0';
          end if;
        else 
           if (pll_locked_tm = '1') then
              clkvco_lk_tmp <= '1';
              clkvco_rm_cnt := 0;
              clkout_en_t <= 0;
              if ( period_vco_cmp_flag = 1) then
                  vcoflag := 1;
                for I in 2 to m_product loop
                  clkout_en_t <= I-1;
                  wait for (period_vco_half);
                  clkvco_lk_tmp <=  '0';  
                  if ( clkvco_rm_cnt = 1) then
--                    wait for (period_vco_half1);
                    wait for (period_vco_half_rm1);
                    clkvco_lk_tmp <=  '1';  
                  else
                    wait for (period_vco_half_rm);
                    clkvco_lk_tmp <=  '1';  
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
                  clkout_en_t <= I-1;
                  wait for (period_vco_half);
                  clkvco_lk_tmp <=  '0';
                  if ( clkvco_rm_cnt = 1) then
                    wait for (period_vco_half_rm);
                    clkvco_lk_tmp <=  '1';
                  else
--                    wait for (period_vco_half1);
                    wait for (period_vco_half_rm1);
                    clkvco_lk_tmp <=  '1';
                  end if;

                  if ( clkvco_rm_cnt = period_vco_cmp_cnt) then
                    clkvco_rm_cnt := 0;
                  else
                    clkvco_rm_cnt := clkvco_rm_cnt + 1;
                  end if;
                end loop;
              else
             vcoflag := 1;
--                for I in 2 to md_product loop
                for I in 2 to m_product loop
                  clkout_en_t <= I-1;
                  wait for (period_vco_half);
                  clkvco_lk_tmp <=  '0';
                  wait for (period_vco_half_rm);
                  clkvco_lk_tmp <=  '1';
                end loop;
              end if;
              wait for (period_vco_half);
              clkvco_lk_tmp <= '0';
--              if (clkpll = '1' ) then
              if (clkpll = '1' and m_product > 1 and vcoflag = 0) then
--                 for I in 2 to md_product loop
                 for I in 2 to m_product loop
--                  clkout_en_t <= I-1;
                  wait for (period_vco_half);
                  clkvco_lk_tmp <=  '0';
                  wait for (period_vco_half_rm);
                  clkvco_lk_tmp <=  '1';
                  end loop;
                  wait for (period_vco_half);
                  clkvco_lk_tmp <= '0';
               end if;
            end if;
          end if;
        end if;
        wait on clkpll, clkvco_lk_rst;
    end process;

    CLKVCO_DLY_CAL_P : process ( period_vco, fb_delay, clkfbm1_dly, clkfbm1pm_rl,
                                ps_in_ps, lock_period, period_vco_mf)
        variable val_tmp : integer;
        variable val_tmp2 : integer;
        variable val_tmp3 : integer;
        variable fbm1_comp_delay : integer;
        variable fbm1_comp_delay_rl : real;
        variable period_vco_i : integer;
        variable period_vco_rl : real;
        variable dly_tmp : integer;
        variable dly_tmp1 : integer;
        variable tmp_ps_val1 : integer;
        variable tmp_ps_val2 : integer;
        variable dly_tmp_int : integer;
        variable tmp_rl : real;
      begin
      if (lock_period = '1') then
        if ( period_vco /= 0 ps) then
          period_vco_i := period_vco * 1 / 1 ps;
          period_vco_rl := real(period_vco_i);
          tmp_rl := real(clkfbm1_dly);
          if (clkfb_frac_en = 1) then
--            val_tmp := period_vco_i * mf_product; 
--            val_tmp := period_vco_mf; 
            val_tmp := (period_avg * 1 / 1 ps) * DIVCLK_DIVIDE;
            fbm1_comp_delay := 0;
            fbm1_comp_delay_rl := period_vco_rl *(tmp_rl  + clkfbm1pm_rl );
            fbm1_comp_delay := real2int(fbm1_comp_delay_rl);
          else
--            val_tmp := period_vco_i * md_product;
            val_tmp := (period_avg * 1 / 1 ps) * DIVCLK_DIVIDE;
            fbm1_comp_delay_rl := period_vco_rl *(tmp_rl  + clkfbm1pm_rl );
            fbm1_comp_delay := real2int(fbm1_comp_delay_rl);
          end if;
          val_tmp2 := fb_delay * 1 / 1 ps;
          dly_tmp1 := val_tmp2 + fbm1_comp_delay;
          dly_tmp_int := 1;
          if (clkfb_fps_en = 1) then
              if (ps_in_ps < 0)  then
                 tmp_ps_val1 := -1 * ps_in_ps;
                 tmp_ps_val2 := tmp_ps_val1 * period_vco_i / 56;
                 if (tmp_ps_val2 > dly_tmp1 ) then
                   dly_tmp_int := -1;
                   dly_tmp := tmp_ps_val2 - dly_tmp1;
                 elsif (tmp_ps_val2 =  dly_tmp1 ) then
                   dly_tmp_int := 0;
                   dly_tmp := 0;
                 else 
                   dly_tmp_int := 1;
                   dly_tmp :=  dly_tmp1 - tmp_ps_val2;
                 end if;
              else
                  dly_tmp := dly_tmp1 + ps_in_ps * period_vco_i / 56;
              end if;
          else
              dly_tmp := dly_tmp1;
          end if;
     
          dly_tmp_o <= dly_tmp * 1 ps;

          if (dly_tmp_int < 0) then
            clkvco_delay <= dly_tmp * 1 ps;
          else 
            if (clkfb_frac_en = 1 and  dly_tmp = 0) then
               clkvco_delay <= 0 ps;
            elsif ( dly_tmp < val_tmp) then
               clkvco_delay <= (val_tmp - dly_tmp) * 1 ps;
            else
               clkvco_delay <=  (val_tmp - dly_tmp mod val_tmp) * 1 ps;
            end if;
           end if;
        end if;
      end if;
    end process;

    CLKFB_PS_P : process (clkfbm1pm_sel)
    begin
        case (clkfbm1pm_sel) is
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

      clkvco_lk_dly_tmp <= transport clkvco_lk after clkvco_delay;
      clkvco <= '0' when (pll_locked_tm = '0' or vco_stp_f = '1')  else clkvco_lk when dly_tmp_o = 0 ps else clkvco_lk_dly_tmp;
  
      --clkout_mux(0) <= clkvco when (clkout_en = '1' and rst_in_o = '0') else '0';

      CLKOUT_MUX_P : process (clkvco, clkout_en, rst_in_o) 
      begin
        if (rst_in_o = '1') then
           clkout_mux(7 downto 0) <= "00000000";
        elsif (clkout_en = '1' and clkvco'event) then
           clkout_mux(0) <= clkvco;
           clkout_mux(1) <= transport clkvco after (period_vco1);
           clkout_mux(2) <= transport clkvco after (period_vco2);
           clkout_mux(3) <= transport clkvco after (period_vco3);
           clkout_mux(4) <= transport clkvco after (period_vco4);
           clkout_mux(5) <= transport clkvco after (period_vco5);
           clkout_mux(6) <= transport clkvco after (period_vco6);
           clkout_mux(7) <= transport clkvco after (period_vco7);
        else
           clkout_mux(7 downto 0) <= "00000000";
        end if;
      end process;

      CLKOUT_PS_P : process (clkvco, clkout_en, rst_in_o) 
      begin
        if (rst_in_o = '1') then
           clkout_ps_tmp1 <= '0';
           clkout_ps_tmp2 <= '0';
        elsif (clkout_en = '1' and fps_en = 1) then
           clkout_ps_tmp1 <=  transport clkvco after (period_ps);
           clkout_ps_tmp2 <=  transport clkvco after (period_ps_old);
        end if;
      end process;

   clkout_ps_eg_p : process(clkout_ps)
   begin
    if (falling_edge(clkout_ps)) then
      clkout_ps_eg <= NOW;
    end if;
    if (rising_edge(clkout_ps)) then
      clkout_ps_peg <= NOW;
    end if;
   end process;

   ps_lock_dly <= ps_lock after 1 ps;

   clkvco_ps_tmp2_en_p : process
       variable clkout_ps_w : time := 0 ps;
   begin
   if (rising_edge(ps_lock_dly)) then
     if ((period_ps - period_ps_old) > period_vco_half ) then
        if (clkout_ps = '0') then
           if (clkout_ps_tmp2 = '1') then
              clkout_ps_w := NOW - clkout_ps_eg;
              if (clkout_ps_w > period_vco3) then
                 clkvco_ps_tmp2_en <= '1';
              else
                 wait until falling_edge(clkout_ps_tmp2);
                 clkvco_ps_tmp2_en <= '1';
              end if; 
           else
              clkvco_ps_tmp2_en <= '1';
           end if;
        else
           if (clkout_ps_tmp2 = '0') then
              clkout_ps_w := NOW - clkout_ps_peg;
              if (clkout_ps_w > period_vco3) then
                 clkvco_ps_tmp2_en <= '1';
              else
                 wait until rising_edge(clkout_ps_tmp2);
                 clkvco_ps_tmp2_en <= '1';
              end if;
            else
              clkvco_ps_tmp2_en <= '1';
           end if;
        end if;
        wait until rising_edge(clkout_ps_tmp2);
        wait until falling_edge(clkout_ps_tmp2);
        if (clkout_ps_tmp1 = '0') then
           clkvco_ps_tmp2_en <= '0';
        else
           wait until falling_edge(clkout_ps_tmp1);
           clkvco_ps_tmp2_en <= '0';
        end if;
       end if;
      end if;
      wait on clkout_ps_tmp1, clkout_ps_tmp2, ps_lock_dly;
      end process;

      clkout_ps_mux(0) <=  clkout_ps  when (clkout_en = '1' and rst_in_o = '0') else '0';

      CLKOUT_PS_MUX_P : process (clkout_ps, clkout_en, rst_in_o) 
      begin
        if (rst_in_o = '1') then
           clkout_ps_mux(7 downto 1) <= "0000000";
        elsif (clkout_en = '1' ) then
           clkout_ps_mux(1) <=  transport clkout_ps after (period_vco1);
           clkout_ps_mux(2) <=  transport clkout_ps after (period_vco2);
           clkout_ps_mux(3) <=  transport clkout_ps after (period_vco3);
           clkout_ps_mux(4) <=  transport clkout_ps after (period_vco4);
           clkout_ps_mux(5) <=  transport clkout_ps after (period_vco5);
           clkout_ps_mux(6) <=  transport clkout_ps after (period_vco6);
           clkout_ps_mux(7) <=  transport clkout_ps after (period_vco7);
        else
           clkout_ps_mux(7 downto 1) <= "0000000";
        end if;
      end process;

      clkout_ps1_p : process( clkvco, clkout_ps_tmp1, clkout_ps_tmp2, clkvco_ps_tmp2_en)
          variable clkout_ps_i : std_ulogic := '0';
      begin
      if (fps_en = 1) then
        if (ps_in_ps = 0 ) then
           clkout_ps_i := clkvco;
        elsif (clkvco_ps_tmp2_en = '1') then
           clkout_ps_i := clkout_ps_tmp2;
        else
           clkout_ps_i := clkout_ps_tmp1;
        end if;
        clkout_ps <= clkout_ps_i;
      else
           clkout_ps <= '0';
      end if;
      end process;

      clk0_sel_mux <= clkout_ps_mux when clk0_fps_en = 1 else clkout_mux;
      clkfb_sel_mux <= clkout_ps_mux when clkfb_fps_en = 1 else clkout_mux;
      clk0in <= clkout_ps_mux(clk0pm_sel) when clk0_fps_en = 1 else clkout_mux(clk0pm_sel1);
      clk1in <= clkout_ps_mux(clk1pm_sel) when clk1_fps_en = 1 else clkout_mux(clk1pm_sel);
      clk2in <= clkout_ps_mux(clk2pm_sel) when clk2_fps_en = 1 else clkout_mux(clk2pm_sel);
      clk3in <= clkout_ps_mux(clk3pm_sel) when clk3_fps_en = 1 else clkout_mux(clk3pm_sel);
      clk4in <= clkout_ps_mux(clk4pm_sel) when clk4_fps_en = 1 else clk6_out when (clkout4_cascade_int = 1) else clkout_mux(clk4pm_sel);
      clk5in <= clkout_ps_mux(clk5pm_sel) when clk5_fps_en = 1 else clkout_mux(clk5pm_sel);
      clk6in <= clkout_ps_mux(clk6pm_sel) when clk6_fps_en = 1 else clkout_mux(clk6pm_sel);
      clkfbm1in <= clkout_ps_mux(clkfbm1pm_sel) when clkfb_fps_en = 1 else clkout_mux(clkfbm1pm_sel1);

      clkfbm1pm_sel1 <=  clkfbm1pm_sel;
      clk0pm_sel1 <=  clk0pm_sel;

      clk0ps_en <= clkout_en when clk0_dly_cnt = clkout0_dly else '0';
      clk1ps_en <= clkout_en when clk1_dly_cnt = clkout1_dly else '0';
      clk2ps_en <= clkout_en when clk2_dly_cnt = clkout2_dly else '0';
      clk3ps_en <= clkout_en when clk3_dly_cnt = clkout3_dly else '0';
      clk4ps_en <= clkout_en when clk4_dly_cnt = clkout4_dly else '0';
      clk5ps_en <= clkout_en when clk5_dly_cnt = clkout5_dly else '0';
      clk6ps_en <= clkout_en when clk6_dly_cnt = clkout6_dly else '0';
      clkfbm1ps_en <= clkout_en when clkfbm1_dly_cnt = clkfbm1_dly else '0';


      CLK0_DLY_CNT_P : process(clk0in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clk0_dly_cnt <= 0;
        else
          if (falling_edge(clk0in)) then
--            if (clkout_en = '1' and clk0_frac_en = 0) then
            if (clkout_en = '1') then
              if (clk0_dly_cnt < clkout0_dly) then
                clk0_dly_cnt <= clk0_dly_cnt + 1;
              end if;
            end if;
          end if;
        end if;
      end process;

      CLK1_DLY_CNT_P : process(clk1in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clk1_dly_cnt <= 0;
        else
          if (falling_edge(clk1in)) then
            if ((clk1_dly_cnt < clkout1_dly) and clkout_en = '1') then
              clk1_dly_cnt <= clk1_dly_cnt + 1;
            end if;
          end if;
        end if;
      end process;

      CLK2_DLY_CNT_P : process(clk2in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clk2_dly_cnt <= 0;
        else
          if (falling_edge(clk2in)) then
            if ((clk2_dly_cnt < clkout2_dly) and clkout_en = '1') then
              clk2_dly_cnt <= clk2_dly_cnt + 1;
            end if;
          end if;
        end if;
      end process;

      CLK3_DLY_CNT_P : process(clk3in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clk3_dly_cnt <= 0;
        else
          if (falling_edge(clk3in)) then
            if ((clk3_dly_cnt < clkout3_dly) and clkout_en = '1') then
              clk3_dly_cnt <= clk3_dly_cnt + 1;
            end if;
          end if;
        end if;
      end process;

      CLK4_DLY_CNT_P : process(clk4in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clk4_dly_cnt <= 0;
        else
          if (falling_edge(clk4in)) then
            if ((clk4_dly_cnt < clkout4_dly) and clkout_en = '1') then
              clk4_dly_cnt <= clk4_dly_cnt + 1;
            end if;
          end if;
        end if;
      end process;

      CLK5_DLY_CNT_P : process(clk5in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clk5_dly_cnt <= 0;
        else
          if (falling_edge(clk5in)) then
            if (clkout_en = '1' ) then
              if (clk5_dly_cnt < clkout5_dly) then
                clk5_dly_cnt <= clk5_dly_cnt + 1;
              end if;
            end if;
          end if;
        end if;
      end process;

      CLK6_DLY_CNT_P : process(clk6in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clk6_dly_cnt <= 0;
        else
          if (falling_edge(clk6in)) then
            if (clkout_en = '1' ) then
              if (clk6_dly_cnt < clkout6_dly) then
                clk6_dly_cnt <= clk6_dly_cnt + 1;
              end if;
            end if;
          end if;
        end if;
      end process;

      CLKFB_DLY_CNT_P : process(clkfbm1in, rst_in_o)
      begin
        if (rst_in_o = '1') then
            clkfbm1_dly_cnt <= 0;
        else
          if (falling_edge(clkfbm1in)) then
--            if (clkout_en = '1' and clkfb_frac_en = 0) then
            if (clkout_en = '1') then
              if (clkfbm1_dly_cnt < clkfbm1_dly) then
                clkfbm1_dly_cnt <= clkfbm1_dly_cnt + 1;
              end if;
            end if;
          end if;
        end if;
      end process;

   CLK0_GEN_P : process    begin
     if (rst_in_o = '1') then
         clk0_cnt <= 0;
         clk0_out <= '0';
     else
       if (clk0_frac_en = 0) then
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
       else
         if (clk0_frac_en = 1 and clk0ps_en = '1') then
                clk0_out <= '1';
                for I0 in 1 to 7 loop
                  wait for clk0_frac_ht;
                  clk0_out <= '0';
                  wait for clk0_frac_lt;
                  clk0_out <= '1';
                end loop;
                wait for clk0_frac_ht;
                clk0_out <= '0';
                wait for (clk0_frac_lt - period_vco1);
          end if;
         --if (clk0_frac_en = 1 and clkout_en = '1') then
         --       clk0_out <= '1';
         --       for I0 in 1 to 7 loop
         --         wait for (clk0_frac_ht - 2 ps);
         --         wait until rising_edge(clk0_sel_mux(0)) or rising_edge(clk0_sel_mux(1)) or rising_edge(clk0_sel_mux(2)) or rising_edge(clk0_sel_mux(3)) or rising_edge(clk0_sel_mux(4))
    --     or rising_edge(clk0_sel_mux(5)) or rising_edge(clk0_sel_mux(6)) or rising_edge(clk0_sel_mux(7));
         --         clk0_out <= '0';
         --         wait for (clk0_frac_lt - 2 ps);
         --         wait until rising_edge(clk0_sel_mux(0)) or rising_edge(clk0_sel_mux(1)) or rising_edge(clk0_sel_mux(2)) or rising_edge(clk0_sel_mux(3)) or rising_edge(clk0_sel_mux(4))
    --     or rising_edge(clk0_sel_mux(5)) or rising_edge(clk0_sel_mux(6)) or rising_edge(clk0_sel_mux(7));
         --         clk0_out <= '1';
         --       end loop;
         --       wait for (clk0_frac_ht - 2 ps);
         --       wait until rising_edge(clk0_sel_mux(0)) or rising_edge(clk0_sel_mux(1)) or rising_edge(clk0_sel_mux(2)) or rising_edge(clk0_sel_mux(3)) or rising_edge(clk0_sel_mux(4))
    --   or rising_edge(clk0_sel_mux(5)) or rising_edge(clk0_sel_mux(6)) or rising_edge(clk0_sel_mux(7));
         --       clk0_out <= '0';
         --       wait for (clk0_frac_lt - period_vco1);
         -- end if;
         end if;
      end if;
      wait on clk0in, rst_in_o;
   end process;



   CLK1_GEN_P : process (clk1in, rst_in_o)
   begin
     if (rst_in_o = '1') then
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


   CLK2_GEN_P : process (clk2in, rst_in_o)
   begin
     if (rst_in_o = '1') then
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


   CLK3_GEN_P : process (clk3in, rst_in_o)
   begin
     if (rst_in_o = '1') then
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


   CLK4_GEN_P : process (clk4in, rst_in_o)
   begin
     if (rst_in_o = '1') then
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


   CLK5_GEN_P : process (clk5in, rst_in_o)
   begin
     if (rst_in_o = '1') then
         clk5_cnt <= 0;
         clk5_out <= '0';
     else
        if (rising_edge(clk5in)  or falling_edge(clk5in)) then
            if (clk5ps_en = '1' ) then
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

   CLK6_GEN_P : process (clk6in, rst_in_o)
   begin
     if (rst_in_o = '1') then
         clk6_cnt <= 0;
         clk6_out <= '0';
     else
        if (rising_edge(clk6in)  or falling_edge(clk6in)) then
            if (clk6ps_en = '1' ) then
              if (clk6_cnt < clk6_div1) then
                      clk6_cnt <= clk6_cnt + 1;
               else
                      clk6_cnt <= 0;
               end if;

               if  (clk6_cnt < clk6_ht1) then
                     clk6_out <= '1';
               else
                     clk6_out <= '0';
               end if;
          else
             clk6_out <= '0';
             clk6_cnt <= 0;
          end if;
        end if;
    end if;
   end process;


   CLKFB_GEN_P : process
   begin
     if (rst_in_o = '1') then
         clkfbm1_cnt <= 0;
         clkfbm1_out <= '0';
     else
      if (clkfb_frac_en = 0) then
        if (rising_edge(clkfbm1in) or falling_edge(clkfbm1in)) then
            if (clkfbm1ps_en = '1' and clkfb_frac_en = 0) then
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
      else
        if (clkfb_frac_en = 1 and clkfbm1ps_en = '1') then
                clkfbm1_out <= '1';
                for Ifb in 1 to 7 loop
                  if (clkout_en = '1') then
                    wait for clkfb_frac_ht;
                    clkfbm1_out <= '0';
                    wait for clkfb_frac_lt;
                    clkfbm1_out <= '1';
                  else
                    clkfbm1_out <= '0';
                  end if;
                end loop;
                if (clkout_en = '1') then
                  wait for clkfb_frac_ht;
                  clkfbm1_out <= '0';
                wait for (clkfb_frac_lt - period_vco1);
                else
                  clkfbm1_out <= '0';
                end  if;
          else
                clkfbm1_out <= '0';
          end if;
        --if (clkfb_frac_en = 1 and clkout_en = '1') then
        --        clkfbm1_out <= '1';
        --        for Ifb in 1 to 7 loop
        --          if (clkout_en = '1') then
        --            wait for (clkfb_frac_ht - 2 ps);
        --            wait until rising_edge(clkfb_sel_mux(0)) or rising_edge(clkfb_sel_mux(1)) or rising_edge(clkfb_sel_mux(2)) or rising_edge(clkfb_sel_mux(3)) or rising_edge(clkfb_sel_mux(4))
        --          or rising_edge(clkfb_sel_mux(5)) or rising_edge(clkfb_sel_mux(6)) or rising_edge(clkfb_sel_mux(7));
        --            clkfbm1_out <= '0';
        --            wait for (clkfb_frac_lt - 2 ps);
        --            wait until rising_edge(clkfb_sel_mux(0)) or rising_edge(clkfb_sel_mux(1)) or rising_edge(clkfb_sel_mux(2)) or rising_edge(clkfb_sel_mux(3)) or rising_edge(clkfb_sel_mux(4))
   --       or rising_edge(clkfb_sel_mux(5)) or rising_edge(clkfb_sel_mux(6)) or rising_edge(clkfb_sel_mux(7));
        --            clkfbm1_out <= '1';
        --          else
        --            clkfbm1_out <= '0';
        --          end if;
        --        end loop;
        --        if (clkout_en = '1') then
        --          wait for (clkfb_frac_ht - 2 ps);
        --          wait until rising_edge(clkfb_sel_mux(0)) or rising_edge(clkfb_sel_mux(1)) or rising_edge(clkfb_sel_mux(2)) or rising_edge(clkfb_sel_mux(3)) or rising_edge(clkfb_sel_mux(4))
        --     or rising_edge(clkfb_sel_mux(5)) or rising_edge(clkfb_sel_mux(6)) or rising_edge(clkfb_sel_mux(7));
        --          clkfbm1_out <= '0';
        --        wait for (clkfb_frac_lt - period_vco1);
        --        else
        --          clkfbm1_out <= '0';
        --        end  if;
        --  else
        --        clkfbm1_out <= '0';
        --  end if;
        end if;
      end if;
       wait on clkfbm1in, rst_in_o, clkout_en;
    end process;

   CLKFBM2_GEN_P : process (clkfb_in, rst_in_o)
   begin
     if (rst_in_o = '1') then
         clkfbm2_cnt <= 0;
         clkfbm2_out <= '0';
     else
        if (rising_edge(clkfb_in)  or falling_edge(clkfb_in)) then
            if (clkout_en = '1') then
              if (clkfbm2_cnt < clkfbm2_div1) then
                      clkfbm2_cnt <= clkfbm2_cnt + 1;
               else
                      clkfbm2_cnt <= 0;
               end if;

               if  (clkfbm2_cnt < clkfbm2_ht1) then
                     clkfbm2_out <= '1';
               else
                     clkfbm2_out <= '0';
               end if;
          else
             clkfbm2_out <= '0';
             clkfbm2_cnt <= 0;
          end if;
        end if;
      end if;
    end process;

   CLKIND_GEN_P : process (clkpll_r, rst_in_o)
   begin
     if (rst_in_o = '1') then
         clkind_cnt <= 0;
         clkind_out <= '0';
     else
        if (rising_edge(clkpll_r)  or falling_edge(clkpll_r)) then
            if (clkout_en = '1') then
              if (clkind_cnt < clkind_div1) then
                      clkind_cnt <= clkind_cnt + 1;
               else
                      clkind_cnt <= 0;
               end if;

               if  (clkind_cnt < clkind_ht1) then
                     clkind_out <= '1';
               else
                     clkind_out <= '0';
               end if;
          else
             clkind_out <= '0';
             clkind_cnt <= 0;
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
    clkout6_out <= transport clk6_out  when fb_delay_found = '1' else clkfb_tst;
    clkfb_out <= transport clkfbm1_out  when fb_delay_found = '1' else clkfb_tst;

  --
  -- determine feedback delay
  --
    pwron_int_p : process
    begin
      pwron_int <= '1';
      wait for 100 ns;
      pwron_int <= '0';
      wait;
    end process;


    CLKFB_TST_P : process (clkpll_r, rst_in)
    begin
      if (rst_in = '1') then
         clkfb_tst <= '0';
      elsif (rising_edge(clkpll_r)) then
        if (fb_delay_found_tmp = '0' and pwron_int = '0') then
           clkfb_tst <=   '1';
        else
           clkfb_tst <=   '0';
        end if;
      end if;
    end process;

    FB_DELAY_CAL_P0 : process (clkfb_tst, rst_in)
    begin
      if (rst_in = '1')  then
         delay_edge <= 0 ps;
      elsif (rising_edge(clkfb_tst)) then
        delay_edge <= NOW;
      end if;
    end process;

    FB_DELAY_CAL_P : process (clkfb_in, rst_in)
      variable delay_edge1 : time := 0 ps;
      variable fb_delay_tmp : time := 0 ps;
      variable Message : line;
    begin
      if (rst_in = '1')  then
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
          if (rst_in = '0' and fb_delay_tmp > fb_delay_max) then
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

    fb_delay_found_P : process(fb_delay_found_tmp, clkvco_delay, rst_in)
    begin
      if (rst_in = '1') then
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
    if (rising_edge(clkpll_r) or falling_edge(clkpll_r)) then
      clkin_p <= '1';
      wait for 100 ps;
      clkin_p <= '0';
    end if;
    wait on clkpll_r;
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

  clkin_lost_out_p : process
  begin
    if (rst_in = '1') then
       clkinstopped_out1 <= '0';
    elsif (rising_edge(clkinstopped_out)) then
       clkinstopped_out1 <= '1';
       if (clkin_hold_f = 1) then
         wait until (rising_edge(locked_out) or rising_edge(rst_in));
         clkinstopped_out1 <= '0';
       else
         if (clkinsel_in = '1') then
         assert FALSE  report " Warning : input CLKIN1 of MMCME2_ADV is stopped. Reset is required for MMCME2_ADV when input clock returns." severity error;
         else
         assert FALSE report " Warning : input CLKIN2 of MMCME2_ADV  is stopped. Reset is required for MMCME2_ADV when input clock returns." severity error;
         end if;
       end if;
    end if;
    wait on clkinstopped_out, locked_out, rst_in;
  end process;

  clkfb_lost_out_p : process
  begin
    if (rst_in = '1') then
       clkfbstopped_out1 <= '0';
    elsif (rising_edge(clkfbstopped_out)) then
       clkfbstopped_out1 <= '1';
       wait until (rising_edge(locked_out) or rising_edge(rst_in));
       clkfbstopped_out1 <= '0';
    end if;
    wait on clkfbstopped_out, locked_out, rst_in;
  end process;

 
  clkin_stopped_p : process
  begin
     if (rst_in = '1') then
       clkinstopped_out <= '0';
       clkin_lost_cnt <= 0;
     elsif (clkin_p = '1') then
      if (clkinstopped_out = '1') then
        wait until rising_edge(clkpll_r);
        clkinstopped_out <= '0';
        clkin_lost_cnt <= 0;
      else
        clkinstopped_out <= '0';
        clkin_lost_cnt <= 0;
      end if;
     elsif (rising_edge(clk_osc)) then
       if (lock_period = '1') then
         if (clkin_lost_cnt < clkin_lost_val)  then
           clkin_lost_cnt <= clkin_lost_cnt + 1;
           clkinstopped_out <= '0';
         else
            clkinstopped_out <= '1';
         end if;
       end if;
     end if;
     wait on clk_osc, rst_in, clkin_p;
  end process;


  clkfb_stopped_p : process(clk_osc, rst_in, clkfb_p)
  begin
     if (rst_in = '1' or clkfb_p = '1') then
       clkfbstopped_out <= '0';
       clkfb_lost_cnt <= 0;
     elsif (rising_edge(clk_osc)) then
       if (clkout_en1 = '1') then
         if (clkfb_lost_cnt < clkfb_lost_val)  then
           clkfb_lost_cnt <= clkfb_lost_cnt + 1;
           clkfbstopped_out <= '0';
         else
            clkfbstopped_out <= '1';
         end if;
       end if;
     end if;
    end process;

    CLK_JITTER_P : process (clkin_jit, rst_in)
    begin
      if (rst_in = '1') then
        clkpll_jitter_unlock <= '0';
      else
        if ( pll_locked_tmp2 = '1' and clkfbstopped_out = '0' and clkinstopped_out = '0') then
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
     
    pll_unlock1_p : process
    begin
      if (rst_in = '1') then
         pll_unlock1 <= '0';
      elsif (rising_edge(pll_unlock1_tmp)) then
           pll_unlock1 <= '1';
           wait until (falling_edge(pll_unlock1_tmp));
           if (clkpll_r = '1') then
              pll_unlock1 <= '0';
           else
              wait until (rising_edge(clkpll_r));
              pll_unlock1 <= '0';
           end if;
         end if;
         wait on pll_unlock1_tmp, clkpll_r, rst_in;
    end process;
           
    pll_unlock1_tmp <= '1' when (clkinstopped_out_dly = '1' or
                   clkfbstopped_out = '1' or clkpll_jitter_unlock = '1') else '0';

    pll_unlock <= '1' when ( pll_unlock1 = '1' or unlock_recover = '1') else '0';

  

end MMCME2_ADV_V;

