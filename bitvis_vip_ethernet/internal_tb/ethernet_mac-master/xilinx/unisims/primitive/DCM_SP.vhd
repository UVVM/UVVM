-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/DCM_SP.vhd,v 1.7 2011/08/18 20:24:33 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Digital Clock Manager
-- /___/   /\     Filename : DCM_SP.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:08 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/06/06 - Initial version.
--    05/09/06 - Add clkin_ps_mkup and clkin_ps_mkup_win for phase shifting (CR 229789).
--    06/14/06 - Add period_int2 and period_int3 for multiple cycle phase shifting (CR 233283).
--        07/21/06 - Change range of variable phase shifting to +/- integer of 20*(Period-3ns).
--               Give warning not support initial phase shifting for variable phase shifting.
--               (CR 235216).
--    09/22/06 - Add lock_period and lock_fb to clkfb_div block (CR 418722).
--    12/19/06 - Add clkfb_div_en for clkfb2x divider (CR431210).
--    04/06/07 - Enable the clock out in clock low time after reset in model
--               clock_divide_by_2  (CR 437471).
--    07/10/07 - Remove modulaton of ps_delay_md for none and fixed delay type (CR441155)
--    08/29/07 - Change delay of lock_fb_dly to 0.75*period, same as verilog (CR447628).
--    01/22/08 - Add () to ps_in * period_in of ps_delay_md calculation (CR466293)
--    02/21/08 - Align clk2x to both clk0 pos and neg edges. (CR467858).
--    03/01/08 - Disable alignment of clkfb and clkin_fb check when ps_lock high (CR468893).
--    03/20/08 - Not check clock lost when negative edge period smaller than positive
--               edge period in dcm_adv_clock_lost module (CR469499).
--             - always generate clk2x with even duty cycle regardless CLKIN duty cycle.(CR467858).
--             - Remove -- from LOCKED <= for unisim model. (CR470138).
--    05/13/08 - Change min input clock freq from 1.0Mhz to 0.2Mhz (CR467770)
--    07/16/08 - remove condition for lock_out[0] when 2x feedback (CR476637).
--    04/20/09 - Delay LOCKED (CR518620)
--    12/03/09 - Add STATUS[5]=CLKFX STATUS[7]=CLKIN (CR538362)
--    08/10/11 - change ps_max_range (CR618799).
-- End Revision


----- dcm_sp_clock_divide_by_2 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dcm_sp_clock_divide_by_2 is
  port(
    clock_out : out std_ulogic := '0';

    clock : in std_ulogic;
    clock_type : in integer;
    rst : in std_ulogic
    );
end dcm_sp_clock_divide_by_2;

architecture dcm_sp_clock_divide_by_2_V of dcm_sp_clock_divide_by_2 is
  signal clock_div2 : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0);
  signal clk_src : std_ulogic;
begin

  CLKIN_DIVIDER : process
  begin
    if (rising_edge(clock)) then
      clock_div2 <= not clock_div2;
    end if;
    wait on clock;
  end process CLKIN_DIVIDER;

  gen_reset : process
  begin
    if (rising_edge(clock)) then      
      rst_reg(0) <= rst;
      rst_reg(1) <= rst_reg(0) and rst;
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst;
    end if;      
    wait on clock;    
  end process gen_reset;

  clk_src <= clock_div2 when (clock_type = 1) else clock;

  assign_clkout : process
  begin
    if (rst = '0') then
      clock_out <= clk_src;
    elsif (rst = '1') then
      clock_out <= '0';
      wait until falling_edge(rst_reg(2));
      if (clk_src = '1') then
         wait until falling_edge(clk_src);
      end if;
    end if;
    wait on clk_src, rst, rst_reg;
  end process assign_clkout;
end dcm_sp_clock_divide_by_2_V;

----- dcm_sp_maximum_period_check  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

entity dcm_sp_maximum_period_check is
  generic (
    InstancePath : string := "*";

    clock_name : string := "";
    maximum_period : time);
  port(
    clock : in std_ulogic;
    rst : in std_ulogic
    );
end dcm_sp_maximum_period_check;

architecture dcm_sp_maximum_period_check_V of dcm_sp_maximum_period_check is
begin

  MAX_PERIOD_CHECKER : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;
    variable clock_period : time := 0 ps;
    variable Message : line;
  begin

   if (rising_edge(clock)) then
    clock_edge_previous := clock_edge_current;
    clock_edge_current := NOW;

    if (clock_edge_previous > 0 ps) then
      clock_period := clock_edge_current - clock_edge_previous;
    end if;

    if (clock_period > maximum_period and  rst = '0') then
      Write ( Message, string'(" Warning : Input Clock Period of "));
      Write ( Message, clock_period );
      Write ( Message, string'(" on the ") );
      Write ( Message, clock_name );      
      Write ( Message, string'(" port ") );      
      Write ( Message, string'(" of DCM_SP instance ") );
      Write ( Message, string'(" exceeds allowed value of ") );
      Write ( Message, maximum_period );
      Write ( Message, string'(" at simulation time ") );
      Write ( Message, clock_edge_current );
      Write ( Message, '.' & LF );
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;
   end if;
    wait on clock;
  end process MAX_PERIOD_CHECKER;
end dcm_sp_maximum_period_check_V;

----- dcm_sp_clock_lost  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dcm_sp_clock_lost is
  port(
    lost : out std_ulogic := '0';

    clock : in std_ulogic;
    enable : in boolean := false;
    rst :  in std_ulogic    
    );
end dcm_sp_clock_lost;

architecture dcm_sp_clock_lost_V of dcm_sp_clock_lost is
  signal period : time := 0 ps;
  signal period_neg : time := 0 ps;
  signal period_tmp_win : time := 0 ps;
  signal period_neg_tmp_win : time := 0 ps;
  signal period_chk_win : time := 0 ps;
  signal lost_r : std_ulogic := '0';
  signal lost_f : std_ulogic := '0';
  signal lost_sig : std_ulogic := '0';  
  signal clock_negedge, clock_posedge : integer := 0;
  signal clock_low, clock_high : integer := 0;
  signal clock_second_pos, clock_second_neg : integer := 0;
begin
  determine_period : process(clock,rst)
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;
    variable period_tmp : time := 0 ps;
  begin
      if (rst = '1') then
        period <= 0 ps;
      elsif (rising_edge(clock)) then
        clock_edge_previous := clock_edge_current;
        clock_edge_current := NOW;
        period_tmp := clock_edge_current - clock_edge_previous;
        if (period /= 0 ps and (period_tmp <= period_tmp_win)) then
          period <= period_tmp;
        elsif (period /= 0 ps and (period_tmp > period_tmp_win)) then
          period <= 0 ps;
        elsif ((period = 0 ps) and (clock_edge_previous /= 0 ps) and (clock_second_pos = 1)) then
          period <= period_tmp;
        end if;
      end if;
  end process determine_period;
                                                                                  
  period_15_p : process(period) begin
     period_tmp_win <= 1.5 * period;
     period_chk_win <= (period * 9.1) / 10;
  end process;

  determine_period_neg : process(clock,rst)
    variable clock_edge_neg_previous : time := 0 ps;
    variable clock_edge_neg_current : time := 0 ps;
    variable period_neg_tmp : time := 0 ps;
  begin
      if (rst = '1') then
        period_neg <= 0 ps;
      elsif (falling_edge(clock)) then
        clock_edge_neg_previous := clock_edge_neg_current;
        clock_edge_neg_current := NOW;
        period_neg_tmp := clock_edge_neg_current - clock_edge_neg_previous;
        if (period_neg /= 0 ps and (period_neg_tmp <= period_neg_tmp_win)) then
          period_neg <= period_neg_tmp;
        elsif (period_neg /= 0 ps and (period_neg_tmp > period_neg_tmp_win)) then
          period_neg <= 0 ps;
        elsif ((period_neg = 0 ps) and (clock_edge_neg_previous /= 0 ps) and (clock_second_neg = 1)) then
          period_neg <= period_neg_tmp;
        end if;
      end if;
  end process determine_period_neg;
                                                                                  
  period_15_neg_p : process(period_neg) begin
     period_neg_tmp_win <= 1.5 * period_neg;
  end process;


  CLOCK_LOST_CHECKER : process(clock, rst)
  begin
      if (rst = '1') then
        clock_low <= 0;
        clock_high <= 0;
        clock_posedge <= 0;              
        clock_negedge <= 0;
      else
        if (rising_edge(clock)) then
          clock_low <= 0;
          clock_high <= 1;
          clock_posedge <= 0;              
          clock_negedge <= 1;
        end if;
        if (falling_edge(clock)) then
          clock_high <= 0;
          clock_low <= 1;
          clock_posedge <= 1;
          clock_negedge <= 0;
        end if;
      end if;
  end process CLOCK_LOST_CHECKER;    

  CLOCK_SECOND_P : process(clock, rst)
    begin
      if (rst = '1') then
        clock_second_pos <= 0;
        clock_second_neg <= 0;
    else
      if (rising_edge(clock)) then
        clock_second_pos <= 1;
      end if;
      if (falling_edge(clock)) then
          clock_second_neg <= 1;
      end if;
    end if;
  end process CLOCK_SECOND_P;

  SET_RESET_LOST_R : process
    begin
    if (rst = '1') then
      lost_r <= '0';
    else
      if ((enable = true) and (clock_second_pos = 1))then
        if (rising_edge(clock)) then
          wait for 1 ps;                      
          if (period /= 0 ps) then
            lost_r <= '0';        
          end if;
          wait for (period_chk_win);
          if ((clock_low /= 1) and (clock_posedge /= 1) and (rst = '0')) then
            lost_r <= '1';
          end if;
        end if;
      end if;
    end if;
    wait on clock, rst;    
  end process SET_RESET_LOST_R;

  SET_RESET_LOST_F : process
    begin
      if (rst = '1') then
        lost_f <= '0';
      else
        if ((enable = true) and (clock_second_neg = 1))then
          if (falling_edge(clock)) then
            if (period /= 0 ps) then      
              lost_f <= '0';
            end if;
            wait for (period_chk_win);
            if ((clock_high /= 1) and (clock_negedge /= 1) and (rst = '0') and (period <= period_neg) ) then
              lost_f <= '1';
            end if;      
          end if;        
        end if;
      end if;
    wait on clock, rst;    
  end process SET_RESET_LOST_F;      

  assign_lost : process(lost_r, lost_f)
    begin
      if (enable = true) then
        if (lost_r'event) then
          lost <= lost_r;
        end if;
        if (lost_f'event) then
          lost <= lost_f;
        end if;
      end if;      
    end process assign_lost;
end dcm_sp_clock_lost_V;


----- CELL DCM_SP  -----
library IEEE;
use IEEE.std_logic_1164.all;





library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.VPKG.all;

entity DCM_SP is
  generic (
    TimingChecksOn : boolean := true;
    InstancePath : string := "*";
    Xon : boolean := true;
    MsgOn : boolean := false;
    CLKDV_DIVIDE : real := 2.0;
    CLKFX_DIVIDE : integer := 1;
    CLKFX_MULTIPLY : integer := 4;
    CLKIN_DIVIDE_BY_2 : boolean := false;
    CLKIN_PERIOD : real := 10.0;                         --non-simulatable
    CLKOUT_PHASE_SHIFT : string := "NONE";
    CLK_FEEDBACK : string := "1X";
    DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";     --non-simulatable
    DFS_FREQUENCY_MODE : string := "LOW";
    DLL_FREQUENCY_MODE : string := "LOW";
    DSS_MODE : string := "NONE";                        --non-simulatable
    DUTY_CYCLE_CORRECTION : boolean := true;
    FACTORY_JF : bit_vector := X"C080";                 --non-simulatable


    PHASE_SHIFT : integer := 0;


    STARTUP_WAIT : boolean := false                     --non-simulatable
    );

  port (
    CLK0 : out std_ulogic := '0';
    CLK180 : out std_ulogic := '0';
    CLK270 : out std_ulogic := '0';
    CLK2X : out std_ulogic := '0';
    CLK2X180 : out std_ulogic := '0';
    CLK90 : out std_ulogic := '0';
    CLKDV : out std_ulogic := '0';
    CLKFX : out std_ulogic := '0';
    CLKFX180 : out std_ulogic := '0';
    LOCKED : out std_ulogic := '0';
    PSDONE : out std_ulogic := '0';
    STATUS : out std_logic_vector(7 downto 0) := "00000000";
    
    CLKFB : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0';
    DSSEN : in std_ulogic := '0';
    PSCLK : in std_ulogic := '0';
    PSEN : in std_ulogic := '0';
    PSINCDEC : in std_ulogic := '0';
    RST : in std_ulogic := '0'
    );



end DCM_SP;

architecture DCM_SP_V of DCM_SP is
  

  component dcm_sp_clock_divide_by_2
    port(
      clock_out : out std_ulogic;

      clock : in std_ulogic;
      clock_type : in integer;
      rst : in std_ulogic
      );
  end component;

  component dcm_sp_maximum_period_check
    generic (
      InstancePath : string := "*";

      clock_name : string := "";
      maximum_period : time);
    port(
      clock : in std_ulogic;
      rst : in std_ulogic
      );
  end component;

  component dcm_sp_clock_lost
    port(
      lost : out std_ulogic;

      clock : in std_ulogic;
      enable : in boolean := false;
      rst :  in std_ulogic          
      );    
  end component;

  constant MAXPERCLKIN : time := 1000000 ps;                   
  constant MAXPERPSCLK : time := 100000000 ps;                 
  constant SIM_CLKIN_CYCLE_JITTER : time := 300 ps;
  constant SIM_CLKIN_PERIOD_JITTER : time := 1000 ps;

  signal CLKFB_ipd, CLKIN_ipd, DSSEN_ipd : std_ulogic;
  signal PSCLK_ipd, PSEN_ipd, PSINCDEC_ipd, RST_ipd : std_ulogic;
  signal PSCLK_dly ,PSEN_dly, PSINCDEC_dly : std_ulogic := '0';
  
  signal clk0_out : std_ulogic;
  signal clk2x_out, clkdv_out : std_ulogic := '0';
  signal clkfx_out, locked_out, psdone_out, ps_overflow_out, ps_lock : std_ulogic := '0';
  signal CLKFX_sig : std_ulogic := '0';
  signal locked_out0 : std_ulogic := '0';
  signal locked_out_out : std_ulogic := '0';
  signal LOCKED_sig : std_ulogic := '0';  

  signal clkdv_cnt : integer := 0;
  signal clkfb_type : integer;
  signal divide_type : integer;
  signal clkin_type : integer;
  signal ps_type : integer;
  signal deskew_adjust_mode : integer;
  signal dfs_mode_type : integer;
  signal dll_mode_type : integer;
  signal clk1x_type : integer;


  signal lock_period, lock_delay, lock_clkin, lock_clkfb : std_ulogic := '0';
  signal lock_out : std_logic_vector(1 downto 0) := "00";  
  signal lock_out1_neg : std_ulogic := '0';

  signal lock_fb : std_ulogic := '0';
  signal lock_fb_dly : std_ulogic := '0';
  signal lock_fb_dly_tmp : std_ulogic := '0';
  signal fb_delay_found : std_ulogic := '0';

  signal clkin_div : std_ulogic;
  signal clkin_ps : std_ulogic;
  signal clkin_ps_tmp : std_ulogic;
  signal clkin_ps_mkup : std_ulogic := '0';
  signal clkin_ps_mkup_win : std_ulogic := '0';
  
  signal clkin_fb : std_ulogic;


  signal ps_delay : time := 0 ps;
  signal ps_in_out : integer := 0;
  signal ps_delay_init : time := 0 ps;
  signal ps_delay_md : time := 0 ps;
  signal ps_delay_all : time := 0 ps;
  signal ps_max_range : integer := 0;
  signal ps_acc : integer := 0;
  signal period_int : integer := 0;
  

  type   real_array_usr is array (2 downto 0) of time;
  signal clkin_period_real : real_array_usr := (0.000 ns, 0.000 ns, 0.000 ns);
  signal period : time := 0 ps;
  signal period_25 : time := 0 ps;
  signal period_50 : time := 0 ps;
  signal period_div : time := 0 ps;
  signal period_orig : time := 0 ps;
  signal period_orig1 : time := 0 ps;
  signal period_ps : time := 0 ps;
  signal clkout_delay : time := 0 ps;
  signal fb_delay : time := 0 ps;
  signal period_fx, remain_fx : time := 0 ps;
  signal period_dv_high, period_dv_low : time := 0 ps;
  signal cycle_jitter, period_jitter : time := 0 ps;

  signal clkin_window, clkfb_window : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0) := "000";
  signal rst_flag : std_ulogic := '0';
  signal numerator, denominator, gcd : integer := 1;

  signal clkin_lost_out : std_ulogic := '0';
  signal clkfx_lost_out : std_ulogic := '0';

  signal remain_fx_temp : integer := 0;

  signal clkin_period_real0_temp : time := 0 ps;
  signal ps_lock_reg : std_ulogic := '0';

  signal clk0_sig : std_ulogic := '0';
  signal clk2x_sig : std_ulogic := '0';

  signal no_stop : boolean := false;

  signal clkfx180_en : std_ulogic := '0';

  signal status_out  : std_logic_vector(7 downto 0) := "00000000";

  signal first_time_locked : boolean := false;

  signal en_status : boolean := false;

  signal ps_overflow_out_ext : std_ulogic := '0';  
  signal clkin_lost_out_ext : std_ulogic := '0';
  signal clkfx_lost_out_ext : std_ulogic := '0';

  signal clkfb_div : std_ulogic := '0';
  signal clkfb_div_en : std_ulogic := '0';
  signal clkfb_chk : std_ulogic := '0';

  signal lock_period_dly : std_ulogic := '0';
  signal lock_period_dly1 : std_ulogic := '0';
  signal lock_period_pulse : std_ulogic := '0';  

  signal clock_stopped : std_ulogic := '1';

  signal clkin_chkin, clkfb_chkin : std_ulogic := '0';
  signal chk_enable, chk_rst : std_ulogic := '0';

  signal lock_ps : std_ulogic := '0';
  signal lock_ps_dly : std_ulogic := '0';      
  
  constant PS_STEP : time := 25 ps;

begin
  INITPROC : process
  begin
    detect_resolution
      (model_name => "DCM_SP"
       );
    if (CLKDV_DIVIDE = 1.5) then
      divide_type <= 3;
    elsif (CLKDV_DIVIDE = 2.0) then
      divide_type <= 4;
    elsif (CLKDV_DIVIDE = 2.5) then
      divide_type <= 5;
    elsif (CLKDV_DIVIDE = 3.0) then
      divide_type <= 6;
    elsif (CLKDV_DIVIDE = 3.5) then
      divide_type <= 7;
    elsif (CLKDV_DIVIDE = 4.0) then
      divide_type <= 8;
    elsif (CLKDV_DIVIDE = 4.5) then
      divide_type <= 9;
    elsif (CLKDV_DIVIDE = 5.0) then
      divide_type <= 10;
    elsif (CLKDV_DIVIDE = 5.5) then
      divide_type <= 11;
    elsif (CLKDV_DIVIDE = 6.0) then
      divide_type <= 12;
    elsif (CLKDV_DIVIDE = 6.5) then
      divide_type <= 13;
    elsif (CLKDV_DIVIDE = 7.0) then
      divide_type <= 14;
    elsif (CLKDV_DIVIDE = 7.5) then
      divide_type <= 15;
    elsif (CLKDV_DIVIDE = 8.0) then
      divide_type <= 16;
    elsif (CLKDV_DIVIDE = 9.0) then
      divide_type <= 18;
    elsif (CLKDV_DIVIDE = 10.0) then
      divide_type <= 20;
    elsif (CLKDV_DIVIDE = 11.0) then
      divide_type <= 22;
    elsif (CLKDV_DIVIDE = 12.0) then
      divide_type <= 24;
    elsif (CLKDV_DIVIDE = 13.0) then
      divide_type <= 26;
    elsif (CLKDV_DIVIDE = 14.0) then
      divide_type <= 28;
    elsif (CLKDV_DIVIDE = 15.0) then
      divide_type <= 30;
    elsif (CLKDV_DIVIDE = 16.0) then
      divide_type <= 32;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKDV_DIVIDE",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKDV_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, or 16.0",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((CLKFX_DIVIDE <= 0) or (32 < CLKFX_DIVIDE)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKFX_DIVIDE",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKFX_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1....32",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;
    if ((CLKFX_MULTIPLY <= 1) or (32 < CLKFX_MULTIPLY)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKFX_MULTIPLY",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKFX_MULTIPLY,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 2....32",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;
    case CLKIN_DIVIDE_BY_2 is
      when false => clkin_type <= 0;
      when true => clkin_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "CLKIN_DIVIDE_BY_2",
           EntityName => "DCM_SP",
           InstanceName => InstancePath,
           GenericValue => CLKIN_DIVIDE_BY_2,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;


    if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
      ps_type <= 0;
    elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
      ps_type <= 1;
    elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
      ps_type <= 2;
      if (PHASE_SHIFT /= 0) then
       GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Warning",
         GenericName => "PHASE_SHIFT",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "The maximum variable phase shift range is only valid when initial phase shift PHASE_SHIFT is zero",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => warning  
         );
      end if;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKOUT_PHASE_SHIFT",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKOUT_PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE, FIXED or VARIABLE",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((CLK_FEEDBACK = "none") or (CLK_FEEDBACK = "NONE")) then
      clkfb_type <= 0;
    elsif ((CLK_FEEDBACK = "1x") or (CLK_FEEDBACK = "1X")) then
      clkfb_type <= 1;
    elsif ((CLK_FEEDBACK = "2x") or (CLK_FEEDBACK = "2X")) then
      clkfb_type <= 2;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLK_FEEDBACK",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLK_FEEDBACK,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE, 1X or 2X",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;



    if ((DESKEW_ADJUST = "source_synchronous") or (DESKEW_ADJUST = "SOURCE_SYNCHRONOUS")) then
      DESKEW_ADJUST_mode <= 8;
    elsif ((DESKEW_ADJUST = "system_synchronous") or (DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS")) then
      DESKEW_ADJUST_mode <= 11;
    elsif ((DESKEW_ADJUST = "0")) then
      DESKEW_ADJUST_mode <= 0;
    elsif ((DESKEW_ADJUST = "1")) then
      DESKEW_ADJUST_mode <= 1;
    elsif ((DESKEW_ADJUST = "2")) then
      DESKEW_ADJUST_mode <= 2;
    elsif ((DESKEW_ADJUST = "3")) then
      DESKEW_ADJUST_mode <= 3;
    elsif ((DESKEW_ADJUST = "4")) then
      DESKEW_ADJUST_mode <= 4;
    elsif ((DESKEW_ADJUST = "5")) then
      DESKEW_ADJUST_mode <= 5;
    elsif ((DESKEW_ADJUST = "6")) then
      DESKEW_ADJUST_mode <= 6;
    elsif ((DESKEW_ADJUST = "7")) then
      DESKEW_ADJUST_mode <= 7;
    elsif ((DESKEW_ADJUST = "8")) then
      DESKEW_ADJUST_mode <= 8;
    elsif ((DESKEW_ADJUST = "9")) then
      DESKEW_ADJUST_mode <= 9;
    elsif ((DESKEW_ADJUST = "10")) then
      DESKEW_ADJUST_mode <= 10;
    elsif ((DESKEW_ADJUST = "11")) then
      DESKEW_ADJUST_mode <= 11;
    elsif ((DESKEW_ADJUST = "12")) then
      DESKEW_ADJUST_mode <= 12;
    elsif ((DESKEW_ADJUST = "13")) then
      DESKEW_ADJUST_mode <= 13;
    elsif ((DESKEW_ADJUST = "14")) then
      DESKEW_ADJUST_mode <= 14;
    elsif ((DESKEW_ADJUST = "15")) then
      DESKEW_ADJUST_mode <= 15;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DESKEW_ADJUST_MODE",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DESKEW_ADJUST_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or 1....15",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DFS_FREQUENCY_MODE = "high") or (DFS_FREQUENCY_MODE = "HIGH")) then
      dfs_mode_type <= 1;
    elsif ((DFS_FREQUENCY_MODE = "low") or (DFS_FREQUENCY_MODE = "LOW")) then
      dfs_mode_type <= 0;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DFS_FREQUENCY_MODE",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DFS_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DLL_FREQUENCY_MODE = "high") or (DLL_FREQUENCY_MODE = "HIGH")) then
      dll_mode_type <= 1;
    elsif ((DLL_FREQUENCY_MODE = "low") or (DLL_FREQUENCY_MODE = "LOW")) then
      dll_mode_type <= 0;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DLL_FREQUENCY_MODE",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DLL_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DSS_MODE = "none") or (DSS_MODE = "NONE")) then
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DSS_MODE",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DSS_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    case DUTY_CYCLE_CORRECTION is
      when false => clk1x_type <= 0;
      when true => clk1x_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DUTY_CYCLE_CORRECTION",
           EntityName => "DCM_SP",
           InstanceName => InstancePath,
           GenericValue => DUTY_CYCLE_CORRECTION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    if ((PHASE_SHIFT < -255) or (PHASE_SHIFT > 255)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "PHASE_SHIFT",
         EntityName => "DCM_SP",
         InstanceName => InstancePath,
         GenericValue => PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are -255 ... 255",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    period_jitter <= SIM_CLKIN_PERIOD_JITTER;
    cycle_jitter <= SIM_CLKIN_CYCLE_JITTER;
    
    case STARTUP_WAIT is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "STARTUP_WAIT",
           EntityName => "DCM_SP",
           InstanceName => InstancePath,
           GenericValue => STARTUP_WAIT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

--
-- fx parameters
--    
    gcd <= 1;
    for i in 2 to CLKFX_MULTIPLY loop
      if (((CLKFX_MULTIPLY mod i) = 0) and ((CLKFX_DIVIDE mod i) = 0)) then
        gcd <= i;
      end if;
    end loop;    
    numerator <= CLKFX_MULTIPLY / gcd;
    denominator <= CLKFX_DIVIDE / gcd;          
    wait;
  end process INITPROC;

--
-- input wire delays
--  


   CLKFB_ipd <= CLKFB;
   CLKIN_ipd <= CLKIN;
   DSSEN_ipd <= DSSEN;
   PSCLK_dly <= PSCLK;
   PSEN_dly <= PSEN;
   PSINCDEC_dly <= PSINCDEC;
   RST_ipd <= RST;

  i_clock_divide_by_2 : dcm_sp_clock_divide_by_2
    port map (
      clock => clkin_ipd,
      clock_type => clkin_type,
      rst => rst_ipd,
      clock_out => clkin_div);

  i_max_clkin : dcm_sp_maximum_period_check
    generic map (
      clock_name => "CLKIN",
      maximum_period => MAXPERCLKIN)

    port map (
      clock => clkin_ipd,
      rst => rst_ipd);

  i_max_psclk : dcm_sp_maximum_period_check
    generic map (
      clock_name => "PSCLK",
      maximum_period => MAXPERPSCLK)

    port map (
      clock => psclk_dly,
      rst => rst_ipd);

  i_clkin_lost : dcm_sp_clock_lost
    port map (
      lost  => clkin_lost_out,
      clock => clkin_ipd,
      enable => first_time_locked,
      rst => rst_ipd      
      );

  i_clkfx_lost : dcm_sp_clock_lost
    port map (
      lost  => clkfx_lost_out,
      clock => clkfx_out,
      enable => first_time_locked,
      rst => rst_ipd
      );  

  clkin_ps_tmp <= transport clkin_div after ps_delay_md;  

  clkin_ps <= clkin_ps_mkup when clkin_ps_mkup_win = '1' else clkin_ps_tmp;
  
  clkin_fb <= transport (clkin_ps and lock_fb);


  clkin_ps_tmp_p: process
     variable  ps_delay_last : integer := 0;
     variable  ps_delay_int : integer;
     variable  period_int2  : integer := 0;
     variable  period_int3  : integer := 0;
  begin
   if (ps_type = 2) then
      ps_delay_int := (ps_delay /1 ps ) * 1;
      period_int2 := 2 * period_int;
      period_int3 := 3 * period_int;

     if (rising_edge(clkin_div)) then
       if ((ps_delay_last > 0  and ps_delay_int <= 0 ) or 
        (ps_delay_last >= period_int  and ps_delay_int < period_int) or
        (ps_delay_last >= period_int2 and ps_delay_int < period_int2) or 
        (ps_delay_last >= period_int3  and ps_delay_int < period_int3)) then
        clkin_ps_mkup_win <= '1';
        clkin_ps_mkup <= '1';
        wait until falling_edge(clkin_div);
           clkin_ps_mkup_win <= '1';
           clkin_ps_mkup <= '0';
       else
           clkin_ps_mkup_win <= '0';
           clkin_ps_mkup <= '0';
       end if;
     end if;

     if (falling_edge(clkin_div)) then
        if ((ps_delay_last > 0  and ps_delay_int <= 0 ) or
        (ps_delay_last >= period_int  and ps_delay_int < period_int) or
        (ps_delay_last >= period_int2 and ps_delay_int < period_int2) or
        (ps_delay_last >= period_int3  and ps_delay_int < period_int3)) then
          clkin_ps_mkup <= '0';
          clkin_ps_mkup_win <= '0';
        wait until rising_edge(clkin_div);
           clkin_ps_mkup <= '1';
           clkin_ps_mkup_win <= '1';
         wait until falling_edge(clkin_div);
           clkin_ps_mkup <= '0';
           clkin_ps_mkup_win <= '1';
        else
           clkin_ps_mkup <= '0';
           clkin_ps_mkup_win <= '0';
        end if;
     end if;
        ps_delay_last := ps_delay_int;
   end if;
    wait on clkin_div;
  end process;

  detect_first_time_locked : process
    begin
      if (first_time_locked = false) then
        if (rising_edge(locked_out)) then
          first_time_locked <= true;
        end if;        
      end if;
      wait on locked_out;
  end process detect_first_time_locked;

  set_reset_en_status : process
  begin
    if (rst_ipd = '1') then
      en_status <= false;
    elsif (rising_edge(Locked_sig)) then
      en_status <= true;
    end if;
    wait on rst_ipd, Locked_sig;
  end process set_reset_en_status;    

  gen_clkfb_div_en: process
  begin
    if (rst_ipd = '1') then
      clkfb_div_en <= '0';
    elsif (falling_edge(clkfb_ipd)) then
      if (lock_fb_dly='1' and lock_period='1' and lock_fb = '1' and clkin_ps = '0') then
        clkfb_div_en <= '1';
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process  gen_clkfb_div_en;

   gen_clkfb_div: process
  begin  
    if (rst_ipd = '1') then
      clkfb_div <= '0';      
    elsif (rising_edge(clkfb_ipd)) then
      if (clkfb_div_en = '1') then
        clkfb_div <= not clkfb_div;      
      end if;
    end if;    
    wait on clkfb_ipd, rst_ipd;
  end process  gen_clkfb_div;

  determine_clkfb_chk: process
  begin
    if (clkfb_type = 2) then
      clkfb_chk <= clkfb_div;
    else 
      clkfb_chk <= clkfb_ipd and lock_fb_dly;
    end if;
    wait on clkfb_ipd, clkfb_div;
  end process  determine_clkfb_chk;

  set_reset_clkin_chkin : process
  begin
    if ((rising_edge(clkin_fb)) or (rising_edge(chk_rst))) then
      if (chk_rst = '1') then
        clkin_chkin <= '0';
      else
        clkin_chkin <= '1';
      end if;
    end if;
    wait on clkin_fb, chk_rst;
  end process set_reset_clkin_chkin;

  set_reset_clkfb_chkin : process
  begin
    if ((rising_edge(clkfb_chk)) or (rising_edge(chk_rst))) then
      if (chk_rst = '1') then
        clkfb_chkin <= '0';
      else
        clkfb_chkin <= '1';
      end if;
    end if;
    wait on clkfb_chk, chk_rst;
  end process set_reset_clkfb_chkin;

  
--   assign_chk_rst: process
--   begin
--     if ((rst_ipd = '1') or (clock_stopped = '1')) then
--       chk_rst <= '1';
--     else
--       chk_rst <= '0';  
--     end if;
--     wait on rst_ipd, clock_stopped;
--   end process assign_chk_rst;

  chk_rst <= '1' when ((rst_ipd = '1') or (clock_stopped = '1')) else '0';  

--   assign_chk_enable: process
--   begin
--     if ((clkin_chkin = '1') and (clkfb_chkin = '1')) then
--       chk_enable <= '1';
--     else
--       chk_enable <= '0';  
--     end if;
--   wait on clkin_chkin, clkfb_chkin;  
--   end process  assign_chk_enable;

  chk_enable <= '1' when ((clkin_chkin = '1') and (clkfb_chkin = '1') and (lock_ps = '1') and (lock_fb_dly = '1') and (lock_fb = '1')) else '0';  




  control_status_bits: process
  begin  
    if ((rst_ipd = '1') or (en_status = false)) then
      ps_overflow_out_ext <= '0';
      clkin_lost_out_ext <= '0';
      clkfx_lost_out_ext <= '0';
    else
      ps_overflow_out_ext <= ps_overflow_out;
      clkin_lost_out_ext <= clkin_lost_out;
      clkfx_lost_out_ext <= clkfx_lost_out;
    end if;
    wait on clkfx_lost_out, clkin_lost_out, en_status, ps_overflow_out, rst_ipd;
  end process  control_status_bits;
  
  determine_period_div : process
    variable clkin_div_edge_previous : time := 0 ps; 
    variable clkin_div_edge_current : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_div_edge_previous := 0 ps; 
      clkin_div_edge_current := 0 ps;
      period_div <= 0 ps;
    else
      if (rising_edge(clkin_div)) then
        clkin_div_edge_previous := clkin_div_edge_current;
        clkin_div_edge_current := NOW;
        if ((clkin_div_edge_current - clkin_div_edge_previous) <= (1.5 * period_div)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;
        elsif ((period_div = 0 ps) and (clkin_div_edge_previous /= 0 ps)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;      
        end if;          
      end if;    
    end if;
    wait on clkin_div, rst_ipd;
  end process determine_period_div;

  period_cal_p : process(period)
        variable period_25_tmp : time := 0 ps;
  begin
        period_25_tmp := period / 4;
        period_50 <= 2 * period_25_tmp;
        period_25 <= period_25_tmp;
  end process;

  determine_period_ps : process
    variable clkin_ps_edge_previous : time := 0 ps; 
    variable clkin_ps_edge_current : time := 0 ps;    
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_ps_edge_previous := 0 ps; 
      clkin_ps_edge_current := 0 ps;
      period_ps <= 0 ps;
    else    
      if (rising_edge(clkin_ps)) then
        clkin_ps_edge_previous := clkin_ps_edge_current;
        clkin_ps_edge_current := NOW;
        wait for 0 ps;
        if ((clkin_ps_edge_current - clkin_ps_edge_previous) <= (1.5 * period_ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        elsif ((period_ps = 0 ps) and (clkin_ps_edge_previous /= 0 ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;      
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;    
  end process determine_period_ps;

  assign_lock_ps_fb : process

  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_fb <= '0';
      lock_ps <= '0';
      lock_ps_dly <= '0';                                            
      lock_fb_dly <= '0';
      lock_fb_dly_tmp <= '0';
    else
      if (rising_edge(clkin_ps)) then
        lock_ps <= lock_period;
        lock_ps_dly <= lock_ps;        
        lock_fb <= lock_ps_dly;            
        lock_fb_dly_tmp <= lock_fb;            
      end if;          
      if (falling_edge(clkin_ps)) then
--         lock_fb_dly <= lock_fb_dly_tmp after (period/4);
         lock_fb_dly <= lock_fb_dly_tmp after (period * 0.75);
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process assign_lock_ps_fb;

  calculate_clkout_delay : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkout_delay <= 0 ps;
    else
      if(fb_delay = 0 ps) then
        clkout_delay <= 0 ps;                
      elsif (period'event or fb_delay'event) then
        clkout_delay <= period - fb_delay;        
      end if;
    end if;
    wait on period, fb_delay, rst_ipd;
  end process calculate_clkout_delay;

--
--generate master reset signal
--  

  gen_master_rst : process
  begin
    if (rising_edge(clkin_ipd)) then    
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst_ipd;    
      rst_reg(1) <= rst_reg(0) and rst_ipd;
      rst_reg(0) <= rst_ipd;
    end if;
    wait on clkin_ipd;     
  end process gen_master_rst;

  check_rst_width : process
    variable Message : line;    
    begin
      if (rst_ipd ='1') then
          rst_flag <= '0';
      end if;
      if (falling_edge(rst_ipd)) then
        if ((rst_reg(2) and rst_reg(1) and rst_reg(0)) = '0') then
          rst_flag <= '1';
          Write ( Message, string'(" Input Error : RST on DCM_SP "));
          Write ( Message, string'(" must be asserted for 3 CLKIN clock cycles. "));          
          assert false report Message.all severity error;
          DEALLOCATE (Message);
        end if;        
      end if;

      wait on rst_ipd;
    end process check_rst_width;

--
--phase shift parameters
--  

  ps_max_range_p : process (period)
    variable period_ps_tmp : integer := 0;
  begin
    period_int <= (period/ 1 ps ) * 1;
    if (clkin_type = 1) then
       period_ps_tmp := 2 * (period/ 1 ps );
    else
       period_ps_tmp := (period/ 1 ps ) * 1;
    end if;
   if (period_ps_tmp > 3000) then
     if (period_ps_tmp > 16667) then
       ps_max_range <= (10 * (period_ps_tmp - 3000)) / 1000;
     else
       ps_max_range <= (15 * (period_ps_tmp - 3000)) / 1000;
     end if;
   else
     ps_max_range <= 0;
  end if;
  end process;

  ps_delay_md_p : process (period, ps_delay, fb_delay_found, rst_ipd)
      variable tmp_value : integer;
      variable tmp_value1 : integer;
      variable tmp_value2 : integer;
  begin
      if (rst_ipd = '1') then
           ps_delay_md <= 0 ps;
      elsif (fb_delay_found = '1') then
          tmp_value := (ps_delay / 1 ps ) * 1;
          tmp_value1 := (period / 1 ps) * 1;
          tmp_value2 := tmp_value mod tmp_value1;
          if (ps_type = 2) then
             ps_delay_md <= period + tmp_value2 * 1 ps;
          else
             ps_delay_md <= period + (ps_in_out * period) / 256;
          end if;
      end if;
  end process;


  determine_phase_shift : process
    variable Message : line;
    variable first_time : boolean := true;
    variable ps_in : integer;    
    variable ps_acc : integer := 0;
    variable ps_step_int : integer := 0;
  begin
    if (first_time = true) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;      
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := 256 + PHASE_SHIFT;
      elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
        ps_in := 256 + PHASE_SHIFT;
      end if;
      ps_step_int := (PS_STEP / 1 ps ) * 1;
      ps_in_out <= ps_in;
      ps_lock <= '0';
      ps_overflow_out <= '0';
      ps_delay <= 0 ps;
      ps_acc := 0;
      first_time := false;
    end if;    

    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;      
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := 256 + PHASE_SHIFT;
      elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
        ps_in := 256 + PHASE_SHIFT;
      else
      end if;
      ps_in_out <= ps_in;
      ps_lock <= '0';
      ps_overflow_out <= '0';
      ps_delay <= 0 ps;
      ps_acc := 0;
    elsif (rising_edge(lock_period_pulse)) then
        ps_delay <= (ps_in * period_div / 256);        
    elsif (rising_edge(PSCLK_dly)) then
        if (ps_type = 2) then
          if (psen_dly = '1') then
            if (ps_lock = '1') then
              Write ( Message, string'(" Warning : Please wait for PSDONE signal before adjusting the Phase Shift. "));
              assert false report Message.all severity warning;
              DEALLOCATE (Message);              
            else if (lock_ps = '1') then
              if (psincdec_dly = '1') then
                if (ps_acc > ps_max_range) then
                  ps_overflow_out <= '1';
                else
                  ps_delay <= ps_delay  + PS_STEP;
                  ps_acc := ps_acc + 1;
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                
              elsif (psincdec_dly = '0') then
                if (ps_acc < -ps_max_range) then
                  ps_overflow_out <= '1';
                else
                  ps_delay <= ps_delay - PS_STEP;
                  ps_acc := ps_acc - 1;
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                                
              end if;
            end if;
          end if;
         end if;
        end if;
      end if;
    if (ps_lock_reg'event) then
      ps_lock <= ps_lock_reg;
    end if;
    wait on lock_period_pulse, psclk_dly, ps_lock_reg, rst_ipd;
  end process determine_phase_shift;

  determine_psdone_out : process
  begin
    if (rising_edge(ps_lock)) then
      ps_lock_reg <= '1';      
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(psclk_dly));
      wait until (rising_edge(psclk_dly));
      wait until (rising_edge(psclk_dly));
      psdone_out <= '1';
      wait until (rising_edge(psclk_dly));
      psdone_out <= '0';
      ps_lock_reg <= '0';
    end if;
    wait on ps_lock;
  end process determine_psdone_out;      
  
--
--determine clock period
--    
  determine_clock_period : process
    variable clkin_edge_previous : time := 0 ps; 
    variable clkin_edge_current : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_period_real(0) <= 0 ps;
      clkin_period_real(1) <= 0 ps;
      clkin_period_real(2) <= 0 ps;
      clkin_edge_previous := 0 ps;      
      clkin_edge_current := 0 ps;      
    elsif (rising_edge(clkin_div)) then
      clkin_edge_previous := clkin_edge_current;
      clkin_edge_current := NOW;
      clkin_period_real(2) <= clkin_period_real(1);
      clkin_period_real(1) <= clkin_period_real(0);      
      if (clkin_edge_previous /= 0 ps) then
	clkin_period_real(0) <= clkin_edge_current - clkin_edge_previous;
      end if;
    end if;      
    if (no_stop'event) then
      clkin_period_real(0) <= clkin_period_real0_temp;
    end if;
    wait on clkin_div, no_stop, rst_ipd;
  end process determine_clock_period;
  
  evaluate_clock_period : process
    variable Message : line;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_period <= '0';
      clock_stopped <= '1';
      clkin_period_real0_temp <= 0 ps;                        
    else
      if (falling_edge(clkin_div)) then
        if (lock_period = '0') then
          if ((clkin_period_real(0) /= 0 ps ) and (clkin_period_real(0) - cycle_jitter <= clkin_period_real(1)) and (clkin_period_real(1) <= clkin_period_real(0) + cycle_jitter) and (clkin_period_real(1) - cycle_jitter <= clkin_period_real(2)) and (clkin_period_real(2) <= clkin_period_real(1) + cycle_jitter)) then
            lock_period <= '1';
            period_orig <= (clkin_period_real(0) + clkin_period_real(1) + clkin_period_real(2)) / 3;
            period <= clkin_period_real(0);
          end if;
        elsif (lock_period = '1') then
          if (100000000 ns < clkin_period_real(0)) then
            Write ( Message, string'(" Warning : CLKIN stopped toggling on instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" exceeds "));
            Write ( Message, string'(" 100 ms "));
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0));
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));            
          elsif ((period_orig * 2 < clkin_period_real(0)) and (clock_stopped = '0')) then
              clkin_period_real0_temp <= clkin_period_real(1);            
              no_stop <= not no_stop;
              clock_stopped <= '1';              
          elsif ((clkin_period_real(0) < period_orig - period_jitter) or (period_orig + period_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Warning : Input Clock Period Jitter on instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" exceeds "));
            Write ( Message, period_jitter );
            Write ( Message, string'(" Locked CLKIN Period =  "));
            Write ( Message, period_orig );
            Write ( Message, string'(" Current CLKIN Period =  "));
            Write ( Message, clkin_period_real(0) );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));                                  
          elsif ((clkin_period_real(0) < clkin_period_real(1) - cycle_jitter) or (clkin_period_real(1) + cycle_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Warning : Input Clock Cycle Jitter on on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, cycle_jitter );
            Write ( Message, string'(" Previous CLKIN Period =  "));
            Write ( Message, clkin_period_real(1) );
            Write ( Message, string'(" Current CLKIN Period =  "));
            Write ( Message, clkin_period_real(0) );                    
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          else           
            period <= clkin_period_real(0);
            clock_stopped <= '0';            
          end if;
        end if;  
      end if;          
    end if;
    wait on clkin_div, rst_ipd;
  end process evaluate_clock_period;    

  lock_period_dly1 <= transport lock_period after 1 ps;
  lock_period_dly <= transport lock_period_dly1 after period_50;

  lock_period_pulse <= '1' when ((lock_period = '1') and (lock_period_dly = '0')) else '0';  
  
--
--determine clock delay
--  
  
  determine_clock_delay : process
    variable delay_edge : time := 0 ps;
    variable temp1 : integer := 0;
    variable temp2 : integer := 0;        
    variable temp : integer := 0;
    variable delay_edge_current : time := 0 ps;    
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      fb_delay <= 0 ps;      
      fb_delay_found <= '0';                        
    else
      if (rising_edge(lock_out(0))) then
        if  ((fb_delay_found = '0') and (clkfb_type /= 0)) then
          if (clkfb_type = 1) then
            wait until ((rising_edge(clk0_sig)) or (rst_ipd'event));                    
            delay_edge := NOW;
          elsif (clkfb_type = 2) then
            wait until ((rising_edge(clk2x_sig)) or (rst_ipd'event));
            delay_edge := NOW;
          end if;
          wait until ((rising_edge(clkfb_ipd)) or (rst_ipd'event));
          temp1 := ((NOW*1) - (delay_edge*1))/ (1 ps);
          if (clkfb_type = 2) then
             temp2 := (period_orig * 1)/ (2 ps);
          else
             temp2 := (period_orig * 1)/ (1 ps);
          end if;
          temp := temp1 mod temp2;
          fb_delay <= temp * 1 ps;
          fb_delay_found <= '1';          
        end if;
      end if;
    end if;
    wait on lock_out(0), rst_ipd;
  end process determine_clock_delay;
--
--  determine feedback lock
--  
  GEN_CLKFB_WINDOW : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkfb_window <= '0';  
    else
      if (rising_edge(clkfb_chk)) then
        wait for 0 ps;
        clkfb_window <= '1';
        wait for cycle_jitter;        
        clkfb_window <= '0';
      end if;          
    end if;      
    wait on clkfb_chk, rst_ipd;
  end process GEN_CLKFB_WINDOW;

  GEN_CLKIN_WINDOW : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_window <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 0 ps;
        clkin_window <= '1';
        wait for cycle_jitter;        
        clkin_window <= '0';
      end if;          
    end if;      
    wait on clkin_fb, rst_ipd;
  end process GEN_CLKIN_WINDOW;  

  set_reset_lock_clkin : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_clkin <= '0';                  
    else
      if (rising_edge(clkin_fb)) then
        wait for 1 ps;
        if (((clkfb_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '1') and (lock_out(0) = '1'))) then
          lock_clkin <= '1';
        else
          if (chk_enable = '1' and ps_lock = '0') then
            lock_clkin <= '0';
          end if;
        end if;
      end if;          
    end if;
    wait on clkin_fb, rst_ipd;
  end process set_reset_lock_clkin;

  set_reset_lock_clkfb : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_clkfb <= '0';                  
    else
      if (rising_edge(clkfb_chk)) then
        wait for 1 ps;
        if (((clkin_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '1') and (lock_out(0) = '1')))then
          lock_clkfb <= '1';
        else
          if (chk_enable = '1' and ps_lock = '0') then          
            lock_clkfb <= '0';
          end if;
        end if;
      end if;          
    end if;
    wait on clkfb_chk, rst_ipd;
  end process set_reset_lock_clkfb;

  assign_lock_delay : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_delay <= '0';          
    else
      if (falling_edge(clkin_fb)) then
        lock_delay <= lock_clkin or lock_clkfb;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;    
  end process;

--
--generate lock signal
--  
  
  generate_lock : process(clkin_ps, rst_ipd)
  begin
    if (rst_ipd='1') then
      lock_out <= "00";
      locked_out <= '0';
      locked_out0 <= '0';
      lock_out1_neg <= '0';
    elsif (rising_edge(clkin_ps)) then
        lock_out(0) <= lock_period;
        lock_out(1) <= lock_out(0);
        if (lock_fb_dly_tmp = '1') then
          locked_out0 <= lock_out(1);
          locked_out <= locked_out0;
        end if;
    elsif (falling_edge(clkin_ps)) then
--        lock_out1_neg <= lock_out(1);
        lock_out1_neg <= locked_out0;
    end if;
  end process generate_lock;

--
--generate the clk1x_out
--  
  
  gen_clk1x : process( clkin_ps, rst_ipd)
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clk0_out <= '0';
    elsif (clkin_ps'event) then
      if (clkin_ps = '1' ) then
        if ((clk1x_type = 1) and (lock_out(0) = '1')) then
          clk0_out <= '1', '0' after period_50;
        else
          clk0_out <= '1';
        end if;
      else
        if ((clkin_ps = '0') and ((((clk1x_type = 1) and (lock_out(0) = '1')) = false) or ((lock_out(0) = '1') and (lock_out(1) = '0')))) then                
          clk0_out <= '0';
        end if;
      end if;          
    end if;
  end process gen_clk1x;




  
--
--generate the clk2x_out
--    

                                                                                  
  gen_clk2x : process
  begin
    if (rst_ipd='1') then
       clk2x_out <= '0';
    elsif (rising_edge(clkin_ps)) then
      clk2x_out <= '1';
      wait for period_25;
      clk2x_out <= '0';
      if (lock_out(0) = '1') then
        wait for period_25;
        clk2x_out <= '1';
        wait for period_25;
        clk2x_out <= '0';
      else
        wait for period_50;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process gen_clk2x;

-- 
--generate the clkdv_out
-- 

  gen_clkdv : process (clkin_ps, rst_ipd)
  begin
    if (rst_ipd='1') then
       clkdv_out <= '0';
       clkdv_cnt <= 0;
    elsif ((rising_edge(clkin_ps)) or (falling_edge(clkin_ps))) then
      if (lock_out1_neg = '1') then
         if (clkdv_cnt >= divide_type -1) then
           clkdv_cnt <= 0;
         else
           clkdv_cnt <= clkdv_cnt + 1;
         end if;

         if (clkdv_cnt < divide_type /2) then
            clkdv_out <= '1';
         else
           if ( ((divide_type rem (2)) > 0) and (dll_mode_type = 0)) then
             clkdv_out <= '0' after (period_25);
           else
            clkdv_out <= '0';
           end if;
         end if;
      end if;
    end if;
  end process;

--
-- generate fx output signal
--
  
  calculate_period_fx : process
  begin
    if (lock_period = '1') then
      period_fx <= (period * denominator) / (numerator * 2);
      remain_fx <= (((period/1 ps) * denominator) mod (numerator * 2)) * 1 ps;        
    end if;
    wait on lock_period, period, denominator, numerator;
  end process calculate_period_fx;

  generate_clkfx : process
    variable temp : integer;
  begin
    if (rst_ipd = '1') then
      clkfx_out <= '0';
    elsif (clkin_lost_out_ext = '1') then
       wait until (rising_edge(rst_ipd));
       clkfx_out <= '0';            
      wait until (falling_edge(rst_reg(2)));              
    elsif (rising_edge(clkin_ps)) then
      if (locked_out0 = '1') then
        clkfx_out <= '1';
        temp := numerator * 2 - 1 - 1;
        for p in 0 to temp loop
          wait for (period_fx);
          clkfx_out <= not clkfx_out;
        end loop;
        if (period_fx > (period_50)) then
          wait for (period_fx - (period_50));
        end if;
      end if;
      if (clkin_lost_out_ext = '1') then
        wait until (rising_edge(rst_ipd));
        clkfx_out <= '0';      
        wait until (falling_edge(rst_reg(2)));
      end if;      
    end if;
    wait on clkin_lost_out_ext, clkin_ps, rst_ipd, rst_reg(2);
  end process generate_clkfx;


--
--generate all output signal
--

  STATUS(7) <= CLKIN_ipd;
  STATUS(5) <= CLKFX_sig;

  schedule_p1_outputs : process
  begin
    if (CLK0_out'event) then
      if (clkfb_type /= 0) then
        CLK0 <= transport CLK0_out after clkout_delay;
        clk0_sig <= transport CLK0_out after clkout_delay; 
      end if;                 
      if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
        CLK90 <= transport clk0_out after (clkout_delay + period_25);
      end if;
    end if;

    if (CLK0_out'event or rst_ipd'event)then
      if (rst_ipd = '1') then
        CLK180 <= '0';
        CLK270 <= '0';
      elsif (CLK0_out'event) then 
        if (clkfb_type /= 0) then        
          CLK180 <= transport (not clk0_out) after clkout_delay;
        end if;
        if ((dll_mode_type = 0) and (clkfb_type /= 0)) then        
          CLK270 <= transport (not clk0_out) after (clkout_delay + period_25);
        end if;
      end if;
    end if;

    if (clk2x_out'event) then
      if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
        CLK2X <= transport clk2x_out after clkout_delay;
        clk2x_sig <= transport clk2x_out after clkout_delay;  
      end if;
    end if;

    if (CLK2X_out'event or rst_ipd'event) then
      if (rst_ipd = '1') then
        CLK2X180 <= '0';
      elsif (CLK2X_out'event) then
        if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
          CLK2X180 <= transport (not CLK2X_out) after clkout_delay;  
        end if;
      end if;
    end if;
      

    if (clkdv_out'event) then
      if (clkfb_type /= 0) then                
        CLKDV <= transport clkdv_out after clkout_delay;
      end if;
    end if;

    if (clkfx_out'event or rst_ipd'event) then
      if (rst_ipd = '1') then
        CLKFX <= '0';
      elsif (clkfx_out'event) then
        CLKFX <= transport clkfx_out after clkout_delay;                
        CLKFX_sig <= transport clkfx_out after clkout_delay;                    
      end if;
    end if;

    if (clkfx_out'event or (rising_edge(rst_ipd)) or first_time_locked'event or locked_out'event) then
      if ((rst_ipd = '1') or (not first_time_locked)) then
        CLKFX180 <= '0';
      else
        CLKFX180 <= transport (not clkfx_out) after clkout_delay;  
      end if;
    end if;

    if (status_out(0)'event) then
      status(0) <= status_out(0);
    end if;

    if (status_out(1)'event) then
      status(1) <= status_out(1);
    end if;

    if (status_out(2)'event) then
      status(2) <= status_out(2);
    end if;    
   
   wait on clk0_out, clk2x_out, clkdv_out, clkfx_out, first_time_locked, locked_out, rst_ipd, status_out;
   end process;
 
  assign_status_out : process
    begin
      if (rst_ipd = '1') then
        status_out(0) <= '0';
        status_out(1) <= '0';
        status_out(2) <= '0';
      elsif (ps_overflow_out_ext'event) then
        status_out(0) <= ps_overflow_out_ext;
      elsif (clkin_lost_out_ext'event) then
        status_out(1) <= clkin_lost_out_ext;
      elsif (clkfx_lost_out_ext'event) then
        status_out(2) <= clkfx_lost_out_ext;
      end if;
      wait on clkin_lost_out_ext, clkfx_lost_out_ext, ps_overflow_out_ext, rst_ipd;
    end process assign_status_out;

   locked_out_out <= 'X' when rst_flag = '1' else locked_out after clkout_delay;

   LOCKED <= locked_out_out after 100 ps;
   PSDONE <= psdone_out;
   LOCKED_sig <= locked_out_out after 100 ps;    

end DCM_SP_V;
