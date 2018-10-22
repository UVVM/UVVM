-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/DCM_ADV.vhd,v 1.3 2011/03/10 20:26:38 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Digital Clock Manager with Advanced Features
-- /___/   /\     Filename : DCM_ADV.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:23 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    04/22/05 - Change DRP set clkfx M/D value effected on RST=1, not rising
--               edge. (CR 206731)
--    05/03/05 - Made changes for speed improvement: seperate process for output
--               clocks; Use senstivity list instead of wait on; remove vital 
--               timing check related code.
--    05/11/05 - Add attribute DCM_AUTOCALIBRATION (CR 208095).
--               Add clkin alignment check control to remove the glitch when
--               clkin stopped. (CR207409).
--    05/25/05 - Seperate clock_second_pos and neg to another process due to 
--               wait caused unreset. (CR 208771)
--    06/03/05 - Use after instead wait for clk0_out(CR209283). 
--               Update error message (CR 209076).
--    07/05/05 - Use counter to generate clkdv_out to align with clk0_out. (CR211465). 
--    07/25/05 - Set CLKIN_PERIOD default to 10.0ns to (CR 213190).
--    08/30/05 - Change reset for CLK270, CLK180, etc (CR 213641).
--    09/08/05 - Add positive edge trig to dcm_maximum_period_check_v. (CR 216828).
--    12/05/05 - Add warning for  un-used DRP address use. (CR 221885)
--    12/22/05 - LOCKED = x when RST less than 3 clock cycles (CR 222795)
--    01/06/06 - Remove GSR from 3 cycle check. (223099).
--    01/12/06 - Remove GSR from reset logic. (223099).
--    01/26/06 - Add reset to maximum period check module (CR 224287).
--    02/28/06 - remove 1 ps in clkfx_out block to support fs resolution. (CR222390)
--               Add SIM_DEVICE generic to support V5 and V4 M and D for CLKFX (BT#1003).
--               Connect DO bit 4 to 15 to 0. (CR 226209)
--    08/10/06 - Set PSDONE to 0 when CLKOUT_PHASE_SHIFT=FIXED (CR 227018).
--    03/07/07 - Change DRP CLKFX Multiplier to bit 15 to 8 and Divider to bit 7 to 0.
--               (CR 435600).
--    04/06/07 - Enable the clock out in clock low time after reset in model
--               clock_divide_by_2  (CR 437471).
--    09/20/07 - Use 1.5 factor for clock stopped check when CLKIN divide by 2 set(CR446707).
--    11/01/07 - Add DRP DFS_FREQUENCY_MODE and DLL_FREQUENCY_MODE read/write support (CR435651)
--    12/20/07 - Add DRP CLKIN_DIV_BY_2 read/write support (CR457282)
--    02/21/08 - Align clk2x to both clk0 pos and neg edges. (CR467858).
--    03/01/08 - Disable alignment of clkfb and clkin_fb check when ps_lock high (CR468893).
--    03/11/08 - Not check clock lost when negative edge period smaller than positive edge
--               period in dcm_adv_clock_lost module (CR469499).
--    03/12/08 - always generate clk2x with even duty cycle regardless CLKIN duty cycle.(CR467858).
--    10/02/08 - Reset ps_kick_off_cmd after drp phase shifting (CR490447).
--    03/09/11 - set period and period_fx to 0 when rst (CR595385)
-- End Revision


----- dcm_adv_clock_divide_by_2 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dcm_adv_clock_divide_by_2 is
  port(
    clock_out : out std_ulogic := '0';

    clock : in std_ulogic;
    clock_type : in std_ulogic;
    rst : in std_ulogic
    );
end dcm_adv_clock_divide_by_2;

architecture dcm_adv_clock_divide_by_2_V of dcm_adv_clock_divide_by_2 is
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

  clk_src <= clock_div2 when (clock_type = '1') else clock;

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

end dcm_adv_clock_divide_by_2_V;

----- dcm_adv_maximum_period_check  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

entity dcm_adv_maximum_period_check is
  generic (
    InstancePath : string := " ";

    clock_name : string := "";
    maximum_period : time);
  port(
    clock : in std_ulogic;
    rst : in std_ulogic
    );
end dcm_adv_maximum_period_check;

architecture dcm_adv_maximum_period_check_V of dcm_adv_maximum_period_check is
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

    if (clock_edge_previous > 0 ps ) then
      clock_period := clock_edge_current - clock_edge_previous;
    end if;

    if (clock_period > maximum_period and rst = '0') then
      Write ( Message, string'(" Warning : Input Clock Period of "));
      Write ( Message, clock_period );
      Write ( Message, string'(" on the ") );
      Write ( Message, clock_name );      
      Write ( Message, string'(" port ") );      
      Write ( Message, string'(" of DCM_ADV instance ") );
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
end dcm_adv_maximum_period_check_V;

----- dcm_adv_clock_lost  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity dcm_adv_clock_lost is
  port(
    lost : out std_ulogic := '0';

    clock : in std_ulogic;
    enable : in boolean := false;
    rst :  in std_ulogic    
    );
end dcm_adv_clock_lost;

architecture dcm_adv_clock_lost_V of dcm_adv_clock_lost is
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

  CLOCK_LOST_CHECKER : process

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
          clock_low <= 1;
          clock_high <= 0;
          clock_posedge <= 1;
          clock_negedge <= 0;
        end if;
      end if;

    wait on clock, rst;
  end process CLOCK_LOST_CHECKER;    
 
  CLOCK_SECOND_P : process
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
    wait on clock, rst;
  end process CLOCK_SECOND_P;


  SET_RESET_LOST_R : process
    begin
    if (rst = '1') then
      lost_r <= '0';
    else
      if ((enable = true) and (clock_second_pos = 1))then
        if (rising_edge(clock)) then
          wait for 0 ps;
          wait for 0 ps;
          wait for 0 ps;                      
          if (period /= 0 ps) then
            lost_r <= '0';        
          end if;
          wait for period_chk_win;
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
              wait for period_chk_win;
              if ((clock_high /= 1) and (clock_negedge /= 1) and (rst = '0') and (period <= period_neg)) then
                lost_f <= '1';
              end if;      
            end if;        
          end if;
      end if;
    wait on clock, rst;    
  end process SET_RESET_LOST_F;      

  assign_lost : process
    begin
      if (enable = true) then
        if (lost_r'event) then
          lost <= lost_r;
        end if;
        if (lost_f'event) then
          lost <= lost_f;
        end if;
      end if;      
      wait on lost_r, lost_f;
    end process assign_lost;
end dcm_adv_clock_lost_V;



----- CELL DCM_ADV  -----
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;




library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity DCM_ADV is
  generic (
    TimingChecksOn : boolean := true;
    InstancePath : string := " ";
    Xon : boolean := true;
    MsgOn : boolean := false;

    CLKDV_DIVIDE : real := 2.0;
    CLKFX_DIVIDE : integer := 1;
    CLKFX_MULTIPLY : integer := 4;
    CLKIN_DIVIDE_BY_2 : boolean := false;
    CLKIN_PERIOD : real := 10.0;                         --non-simulatable
    CLKOUT_PHASE_SHIFT : string := "NONE";
    CLK_FEEDBACK : string := "1X";
    DCM_AUTOCALIBRATION : boolean := true;
    DCM_PERFORMANCE_MODE : string := "MAX_SPEED";	-- non-simulatable    
    DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";     --non-simulatable
    DFS_FREQUENCY_MODE : string := "LOW";
    DLL_FREQUENCY_MODE : string := "LOW";
    DUTY_CYCLE_CORRECTION : boolean := true;
    FACTORY_JF : bit_vector := X"F0F0";                 --non-simulatable


    PHASE_SHIFT : integer := 0;


    SIM_DEVICE : string := "VIRTEX4";
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
    DO : out std_logic_vector(15 downto 0) := "0000000000000000";
    DRDY : out std_ulogic := '0';    
    LOCKED : out std_ulogic := '0';
    PSDONE : out std_ulogic := '0';

    
    CLKFB : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0';
    DADDR : in std_logic_vector(6 downto 0) := "0000000";
    DCLK : in std_ulogic := '0';    
    DEN : in std_ulogic := '0';
    DI : in std_logic_vector(15 downto 0) := "0000000000000000";
    DWE : in std_ulogic := '0';
    PSCLK : in std_ulogic := '0';
    PSEN : in std_ulogic := '0';
    PSINCDEC : in std_ulogic := '0';
    RST : in std_ulogic := '0'
    );



end DCM_ADV;

architecture DCM_ADV_V of DCM_ADV is
  

  component dcm_adv_clock_divide_by_2
    port(
      clock_out : out std_ulogic;

      clock : in std_ulogic;
      clock_type : in std_ulogic;
      rst : in std_ulogic
      );
  end component;

  component dcm_adv_maximum_period_check
    generic (
      InstancePath : string := " ";

      clock_name : string := "";
      maximum_period : time);
    port(
      clock : in std_ulogic;
      rst : in std_ulogic
      );
  end component;

  component dcm_adv_clock_lost
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

  signal clkfb_ipd : std_ulogic;
  signal clkin_ipd : std_ulogic;
  signal daddr_ipd : std_logic_vector(6 downto 0);
  signal dclk_ipd : std_ulogic;
  signal den_ipd : std_ulogic;
  signal di_ipd : std_logic_vector(15 downto 0);  
  signal dwe_ipd : std_ulogic;
  signal psclk_ipd : std_ulogic;
  signal psen_ipd : std_ulogic;
  signal psincdec_ipd : std_ulogic;
  signal rst_ipd : std_ulogic;

  signal   CLKIN_dly  :  std_ulogic;
  signal   CLKFB_dly  :  std_ulogic;
  signal   RST_dly  :  std_ulogic;
  signal   PSINCDEC_dly  :  std_ulogic;
  signal   PSEN_dly  :  std_ulogic;
  signal   PSCLK_dly  :  std_ulogic;
  signal   DADDR_dly  :  std_logic_vector(6 downto 0);
  signal   DI_dly  :  std_logic_vector(15 downto 0);
  signal   DWE_dly  :  std_ulogic;
  signal   DEN_dly  :  std_ulogic;
  signal   DCLK_dly  :  std_ulogic;    
  signal   GSR_dly   :  std_ulogic := '0';
  
  signal clk0_out : std_ulogic := '0';
  signal clk2x_out : std_ulogic := '0';
  signal clkdv_out : std_ulogic := '0';
  signal clkfx_out : std_ulogic := '0';
  signal drdy_out : std_ulogic := '0';
  signal do_out  : std_logic_vector(15 downto 0) := "0000000000000000";
  signal do_out_reg  : std_logic_vector(15 downto 0) := "0000000000000000";   
  signal do_out_s  : std_logic_vector(15 downto 0) := "0000000000000000";   
  signal do_out_drp  : std_logic_vector(15 downto 0) := "0000000000000000";   
  signal do_out_drp1  : std_logic_vector(15 downto 0) := "0000000000000000";   
  signal do_stat_en : std_ulogic := '1';
  signal clkfx_md_reg : std_logic_vector(15 downto 0);
  signal daddr_in_lat : std_logic_vector(6 downto 0); 
  signal clkdv_cnt : integer := 0;
  signal locked_out : std_ulogic := '0';
  signal psdone_out : std_ulogic := '0';

  signal locked_out_tmp : std_ulogic;

  signal locked_pulse : std_ulogic;      
  
  signal ps_overflow_out, ps_lock : std_ulogic := '0';

  signal clkfb_type : integer;
  signal divide_type : integer;
  signal clkin_type : std_ulogic := '0';
  signal ps_type : integer;
  signal deskew_adjust_mode : integer;
  signal dfs_mode_type : std_ulogic;
  signal dll_mode_type : std_logic_vector(1 downto 0);
  signal dfs_mode_reg : std_logic_vector(15 downto 0);
  signal dll_mode_reg : std_logic_vector(15 downto 0);
  signal clkin_div2_reg : std_logic_vector(15 downto 0);
  signal sim_device_type : std_ulogic;
  signal clk1x_type : integer;
  signal ps_in_current, ps_min, ps_max : integer;

  signal lock_period, lock_delay, lock_clkin, lock_clkfb : std_ulogic := '0';
  signal lock_out : std_logic_vector(1 downto 0) := "00";  
  signal lock_out1_neg : std_ulogic := '0';
  signal locked_out_out : std_ulogic := '0';

  signal lock_fb, lock_ps, lock_ps_dly : std_ulogic := '0';
  signal fb_delay_found : std_ulogic := '0';

  signal clkin_div : std_ulogic;
  signal clkin_ps : std_ulogic;
  signal clkin_fb : std_ulogic;


  signal ps_delay : time := 0 ps;


  type   real_array_usr is array (2 downto 0) of time; 
  signal clkin_period_real : real_array_usr := (0.000 ns, 0.000 ns, 0.000 ns);
  signal period : time := 0 ps;
  signal period_25 : time := 0 ps;
  signal period_50 : time := 0 ps;
  signal period_div : time := 0 ps;
  signal period_orig : time := 0 ps;
  signal period_stop_ck : time := 0 ps;
  signal period_ps : time := 0 ps;
  signal clkout_delay : time := 0 ps;
  signal fb_delay : time := 0 ps;
  signal period_fx, remain_fx : time := 0 ps;
  signal period_dv_high, period_dv_low : time := 0 ps;
  signal cycle_jitter, period_jitter : time := 0 ps;

  signal clkin_window, clkfb_window : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0) := "000";
  signal rst_flag : std_ulogic := '0';

  signal numerator : integer := CLKFX_MULTIPLY;
  signal denominator : integer := CLKFX_DIVIDE;    
  signal gcd : integer := 1;    

  signal clkin_lost_out : std_ulogic := '0';
  signal clkfx_lost_out : std_ulogic := '0';
  signal clkfb_lost_out : std_ulogic := '0';  

  signal remain_fx_temp : integer := 0;


  signal clk0_sig : std_ulogic := '0';
  signal clk2x_sig : std_ulogic := '0';
  signal clkfx_sig : std_ulogic := '0';    

  signal first_time_locked : boolean := false;

  signal mem : std_logic_vector(1521 downto 0);    

  signal drp_lock : std_ulogic := '0';
  signal drp_lock1 : std_ulogic := '0';

  constant CLKFX_MULTIPLY_ADDR : integer := 80;
  constant CLKFX_DIVIDE_ADDR : integer := 82;
  constant PHASE_SHIFT_ADDR : integer := 85;
  constant DFS_FREQ_MODE_ADDR : integer := 65;
  constant DLL_FREQ_MODE_ADDR : integer := 81;
  constant CLKIN_DIV_BY2_ADDR : integer := 68;

  constant PHASE_SHIFT_KICK_OFF_ADDR : integer := 17;
  
  constant DCM_DEFAULT_STATUS_ADDR : integer := 0;

  signal clkfx_multiply_drp : integer := CLKFX_MULTIPLY;
  signal clkfx_divide_drp : integer := CLKFX_DIVIDE;
  signal ps_in_drp, ps_drp : integer := 0;


  signal single_step_done : std_ulogic := '0';

  signal ps_drp_lock : std_ulogic := '0';
  signal ps_kick_off_cmd : std_ulogic := '0';  

  signal clock_stopped : std_ulogic := '1';
  signal clock_stopped_factor : real := 2.0;

  signal inc_dec : std_ulogic;

  signal tap_delay_step : time;

  signal en_status : boolean := false;

  signal ps_overflow_out_ext : std_ulogic := '0';  
  signal clkin_lost_out_ext : std_ulogic := '0';
  signal clkfx_lost_out_ext : std_ulogic := '0';
  signal clkfb_lost_out_ext : std_ulogic := '0';

  signal lock_period_dly : std_ulogic := '0';
  signal lock_period_pulse : std_ulogic := '0';

  signal clkin_chkin, clkfb_chkin : std_ulogic := '0';
  signal chk_enable, chk_rst : std_ulogic := '0';

  signal rst_input : std_ulogic;  

  
begin
  INITPROC : process
    variable Message : line;

    variable FACTORY_JF_slv : std_logic_vector(15 downto 0) := To_StdLogicVector(FACTORY_JF);    
  begin
    detect_resolution
      (model_name => "DCM_ADV"
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
         EntityName => "DCM_ADV",
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
         EntityName => "DCM_ADV",
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
         EntityName => "DCM_ADV",
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
      when false => clock_stopped_factor <= 2.0;
      when true => clock_stopped_factor <= 1.5;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "CLKIN_DIVIDE_BY_2",
           EntityName => "DCM_ADV",
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
      if ((PHASE_SHIFT < -255) or (PHASE_SHIFT > 255)) then
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "PHASE_SHIFT",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => PHASE_SHIFT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are -255 ... 255",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
      end if;      
    elsif ((CLKOUT_PHASE_SHIFT = "variable_positive") or (CLKOUT_PHASE_SHIFT = "VARIABLE_POSITIVE")) then
      ps_type <= 3;
      if ((PHASE_SHIFT < 0) or (PHASE_SHIFT > 255)) then
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "PHASE_SHIFT",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => PHASE_SHIFT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are 0 ... 255",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
      end if;
    elsif ((CLKOUT_PHASE_SHIFT = "variable_center") or (CLKOUT_PHASE_SHIFT = "VARIABLE_CENTER")) then
      ps_type <= 4;
      if ((PHASE_SHIFT < -255) or (PHASE_SHIFT > 255)) then
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "PHASE_SHIFT",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => PHASE_SHIFT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are -255 ... 255",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
      end if;
    elsif ((CLKOUT_PHASE_SHIFT = "direct") or (CLKOUT_PHASE_SHIFT = "DIRECT")) then
      ps_type <= 5;
      if ((PHASE_SHIFT < 0) or (PHASE_SHIFT > 1023))then
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "PHASE_SHIFT",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => PHASE_SHIFT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are 0 ... 1023",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
      end if;                        
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKOUT_PHASE_SHIFT",
         EntityName => "DCM_ADV",
         InstanceName => InstancePath,
         GenericValue => CLKOUT_PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE, FIXED, VARIABLE_POSITIVE, VARIABLE_CENTER OR DIRECT",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((CLK_FEEDBACK = "none") or (CLK_FEEDBACK = "NONE")) then
      clkfb_type <= 0;
      Write ( Message, string'(" Attribute CLK_FEEDBACK is set to value NONE."));
      Write ( Message, string'(" In this mode, the output ports CLK0, CLK180, CLK270, CLK2X, CLK2X180, CLK90 and  CLKDV can have any random phase relation w.r.t. input port CLKIN"));
      Write ( Message, '.' & LF );
      assert false report Message.all severity note;
      DEALLOCATE (Message);            
    elsif ((CLK_FEEDBACK = "1x") or (CLK_FEEDBACK = "1X")) then
      clkfb_type <= 1;
--    elsif ((CLK_FEEDBACK = "2x") or (CLK_FEEDBACK = "2X")) then
--      clkfb_type <= 2;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLK_FEEDBACK",
         EntityName => "DCM_ADV",
         InstanceName => InstancePath,
         GenericValue => CLK_FEEDBACK,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE or 1X",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if (DCM_PERFORMANCE_MODE = "MAX_SPEED") then
      tap_delay_step <= 11 ps;
    elsif (DCM_PERFORMANCE_MODE = "MAX_RANGE") then
      tap_delay_step <= 18 ps;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DCM_PERFORMANCE_MODE",
         EntityName => "DCM_ADV",
         InstanceName => InstancePath,
         GenericValue => DCM_PERFORMANCE_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are MAX_SPEED or MAX_RANGE",
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
    elsif ((DESKEW_ADJUST = "16")) then
      DESKEW_ADJUST_mode <= 16;
    elsif ((DESKEW_ADJUST = "17")) then
      DESKEW_ADJUST_mode <= 17;
    elsif ((DESKEW_ADJUST = "18")) then
      DESKEW_ADJUST_mode <= 18;
    elsif ((DESKEW_ADJUST = "19")) then
      DESKEW_ADJUST_mode <= 19;
    elsif ((DESKEW_ADJUST = "20")) then
      DESKEW_ADJUST_mode <= 20;
    elsif ((DESKEW_ADJUST = "21")) then
      DESKEW_ADJUST_mode <= 21;
    elsif ((DESKEW_ADJUST = "22")) then
      DESKEW_ADJUST_mode <= 22;
    elsif ((DESKEW_ADJUST = "23")) then
      DESKEW_ADJUST_mode <= 23;
    elsif ((DESKEW_ADJUST = "24")) then
      DESKEW_ADJUST_mode <= 24;
    elsif ((DESKEW_ADJUST = "25")) then
      DESKEW_ADJUST_mode <= 25;
    elsif ((DESKEW_ADJUST = "26")) then
      DESKEW_ADJUST_mode <= 26;
    elsif ((DESKEW_ADJUST = "27")) then
      DESKEW_ADJUST_mode <= 27;
    elsif ((DESKEW_ADJUST = "28")) then
      DESKEW_ADJUST_mode <= 28;
    elsif ((DESKEW_ADJUST = "29")) then
      DESKEW_ADJUST_mode <= 29;
    elsif ((DESKEW_ADJUST = "30")) then
      DESKEW_ADJUST_mode <= 30;
    elsif ((DESKEW_ADJUST = "31")) then
      DESKEW_ADJUST_mode <= 31;      
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DESKEW_ADJUST_MODE",
         EntityName => "DCM_ADV",
         InstanceName => InstancePath,
         GenericValue => DESKEW_ADJUST_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or 1....15",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DFS_FREQUENCY_MODE /= "HIGH") and (DFS_FREQUENCY_MODE /= "LOW")) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DFS_FREQUENCY_MODE",
         EntityName => "DCM_ADV",
         InstanceName => InstancePath,
         GenericValue => DFS_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DLL_FREQUENCY_MODE /= "HIGH") and  (DLL_FREQUENCY_MODE /= "LOW")) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DLL_FREQUENCY_MODE",
         EntityName => "DCM_ADV",
         InstanceName => InstancePath,
         GenericValue => DLL_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    case DUTY_CYCLE_CORRECTION is
      when false => if (SIM_DEVICE = "VIRTEX4") then
                       clk1x_type <= 0;
                    else 
                       clk1x_type <= 1;
                    end if;
      when true => clk1x_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DUTY_CYCLE_CORRECTION",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => DUTY_CYCLE_CORRECTION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    if (FACTORY_JF = X"F0F0") then
    else
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Warning",
           GenericName => "FACTORY_JF",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => SLV_TO_STR(FACTORY_JF_slv),
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute is F0F0 hex",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => warning
           );                          
    end  if;    
    
    period_jitter <= SIM_CLKIN_PERIOD_JITTER;
    cycle_jitter <= SIM_CLKIN_CYCLE_JITTER;
    
    case STARTUP_WAIT is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "STARTUP_WAIT",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => STARTUP_WAIT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    case DCM_AUTOCALIBRATION is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DCM_AUTOCALIBRATION",
           EntityName => "DCM_ADV",
           InstanceName => InstancePath,
           GenericValue => DCM_AUTOCALIBRATION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    if ( SIM_DEVICE = "VIRTEX4") then  
         sim_device_type <= '0';
    elsif (SIM_DEVICE = "VIRTEX5") then
         sim_device_type <= '1';
    else
      Write ( Message, string'("Attribute Syntax Error : The Attribute SIM_DEVICE on DCM_ADV is set to "));
      Write ( Message, SIM_DEVICE);
      Write ( Message, string'(".  Legal values for this attribute are VIRTEX4 or VIRTEX5") );
      Write ( Message, '.' & LF );
      assert false report Message.all severity error;
      DEALLOCATE (Message);
     end if;

    wait;
  end process INITPROC;

--
-- input wire delays
--  

   CLKFB_ipd <= CLKFB;
   CLKIN_ipd <= CLKIN;
   DADDR_dly(6 downto 0) <= DADDR(6 downto 0);
   DCLK_dly <= DCLK;
   DEN_dly <= DEN;
   DI_dly(15 downto 0) <= DI(15 downto 0);
   DWE_dly <= DWE;
   PSCLK_dly <= PSCLK;
   PSEN_dly <= PSEN;
   PSINCDEC_dly <= PSINCDEC;
   rst_input <= RST;

  rst_ipd <= rst_input;

  i_clock_divide_by_2 : dcm_adv_clock_divide_by_2
    port map (
      clock => clkin_ipd,
      clock_type => clkin_type,
      rst => rst_ipd,
      clock_out => clkin_div);

  i_max_clkin : dcm_adv_maximum_period_check
    generic map (
      clock_name => "CLKIN",
      maximum_period => MAXPERCLKIN)

    port map (
      clock => clkin_ipd,
      rst => rst_ipd );

  i_max_psclk : dcm_adv_maximum_period_check
    generic map (
      clock_name => "PSCLK",
      maximum_period => MAXPERPSCLK)

    port map (
      clock => PSCLK_dly,
      rst => rst_ipd );

  i_clkin_lost : dcm_adv_clock_lost
    port map (
      lost  => clkin_lost_out,
      clock => clkin_ipd,
      enable => first_time_locked,
      rst => rst_ipd      
      ); 

  i_clkfx_lost : dcm_adv_clock_lost
    port map (
      lost  => clkfx_lost_out,
      clock => clkfx_out,
      enable => first_time_locked,
      rst => rst_ipd
      );

  i_clkfb_lost : dcm_adv_clock_lost
    port map (
      lost  => clkfb_lost_out,
      clock => clkfb_ipd,
      enable => first_time_locked,
      rst => rst_ipd
      );   

  
  clkin_ps <= transport clkin_div after ps_delay;  

  clkin_fb <= transport  (clkin_ps and lock_fb);

  determine_period_div : process(clkin_div, rst_ipd)
    variable clkin_div_edge_previous : time := 0 ps; 
    variable clkin_div_edge_current : time := 0 ps;
  begin
    if (rst_ipd = '1') then
      clkin_div_edge_previous := 0 ps; 
      clkin_div_edge_current := 0 ps;
      period_div <= 0 ps;
    elsif (rising_edge(clkin_div)) then
        clkin_div_edge_previous := clkin_div_edge_current;
        clkin_div_edge_current := NOW;
        if ((clkin_div_edge_current - clkin_div_edge_previous) <= (1.5 * period_div)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;
        elsif ((period_div = 0 ps) and (clkin_div_edge_previous /= 0 ps)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;      
        end if;          
    end if;
  end process determine_period_div;

  determine_period_ps : process(clkin_ps, rst_ipd)
    variable clkin_ps_edge_previous : time := 0 ps; 
    variable clkin_ps_edge_current : time := 0 ps;    
  begin
    if  (rst_ipd = '1') then
      clkin_ps_edge_previous := 0 ps; 
      clkin_ps_edge_current := 0 ps;
      period_ps <= 0 ps;
    elsif (rising_edge(clkin_ps)) then
        clkin_ps_edge_previous := clkin_ps_edge_current;
        clkin_ps_edge_current := NOW;
        if ((clkin_ps_edge_current - clkin_ps_edge_previous) <= (1.5 * period_ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        elsif ((period_ps = 0 ps) and (clkin_ps_edge_previous /= 0 ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;      
        end if;
    end if;
  end process determine_period_ps;

  assign_lock_ps_fb : process(clkin_ps, rst_ipd)
  begin
    if  (rst_ipd = '1') then
      lock_fb <= '0';
      lock_ps <= '0';
      lock_ps_dly <= '0';                                                  
    elsif (rising_edge(clkin_ps)) then
        lock_ps <= lock_period;
        lock_ps_dly <= lock_ps;                
        lock_fb <= lock_ps_dly;            
    end if;
  end process assign_lock_ps_fb;

  calculate_clkout_delay : process(period, fb_delay, rst_ipd)
  begin
    if (rst_ipd = '1') then
      clkout_delay <= 0 ps;
    elsif (fb_delay = 0 ps) then
      clkout_delay <= 0 ps;                
    else
      clkout_delay <= period - fb_delay;        
    end if;
  end process calculate_clkout_delay;

--
--generate master reset signal
--  

  gen_master_rst : process(clkin_ipd)
  begin
    if (rising_edge(clkin_ipd)) then    
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst_input;    
      rst_reg(1) <= rst_reg(0) and rst_input;
      rst_reg(0) <= rst_input;
    end if;
  end process gen_master_rst;

  check_rst_width : process(rst_input)
    variable Message : line;    
    begin
      if (rst_input = '1') then
         rst_flag <= '0';
      end if;
      if (falling_edge(rst_input)) then
        if ((rst_reg(2) and rst_reg(1) and rst_reg(0)) = '0') then
          rst_flag <= '1';
        Write ( Message, string'(" Input Error : RST on instance "));
        Write ( Message, Instancepath );                    
          Write ( Message, string'(" must be asserted for 3 CLKIN clock cycles. "));          
          assert false report Message.all severity error;
          DEALLOCATE (Message);
        end if;        
      end if;
    end process check_rst_width;

--
--phase shift parameters
--  

  determine_phase_shift : process
    variable Message : line;
    variable FINE_SHIFT_RANGE : time;
    variable first_time : boolean := true;
    variable ps_in : integer;                
    variable single_step_lock : std_ulogic := '0';    
  begin
    if (first_time = true) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;        
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := PHASE_SHIFT + 256;
        ps_max <= 255 + 256;
        ps_min <= -255 + 256;
        if (DCM_PERFORMANCE_MODE = "MAX_SPEED") then
          FINE_SHIFT_RANGE := 7000 ps;        
        elsif (DCM_PERFORMANCE_MODE = "MAX_RANGE") then
          FINE_SHIFT_RANGE := 10000 ps;        
        end if;        
      elsif ((CLKOUT_PHASE_SHIFT = "variable_positive") or (CLKOUT_PHASE_SHIFT = "VARIABLE_POSITIVE")) then
        ps_in := PHASE_SHIFT + 256;
        ps_max <= 255 + 256;
        ps_min <= 0 + 256;
        if (DCM_PERFORMANCE_MODE = "MAX_SPEED") then
          FINE_SHIFT_RANGE := 7000 ps;        
        elsif (DCM_PERFORMANCE_MODE = "MAX_RANGE") then
          FINE_SHIFT_RANGE := 10000 ps;        
        end if;        
      elsif ((CLKOUT_PHASE_SHIFT = "variable_center") or (CLKOUT_PHASE_SHIFT = "VARIABLE_CENTER")) then
        ps_in := PHASE_SHIFT + 256;
        ps_max <= 255 + 256;
        ps_min <= -255 + 256;
        if (DCM_PERFORMANCE_MODE = "MAX_SPEED") then
          FINE_SHIFT_RANGE := 3500 ps;        
        elsif (DCM_PERFORMANCE_MODE = "MAX_RANGE") then
          FINE_SHIFT_RANGE := 5000 ps;        
        end if;        
      elsif ((CLKOUT_PHASE_SHIFT = "direct") or (CLKOUT_PHASE_SHIFT = "DIRECT")) then
        ps_max <= 1023;
        ps_min <= 0;         
        if (DCM_PERFORMANCE_MODE = "MAX_SPEED") then
          FINE_SHIFT_RANGE := 7000 ps;        
        elsif (DCM_PERFORMANCE_MODE = "MAX_RANGE") then
          FINE_SHIFT_RANGE := 10000 ps;        
        end if;
        ps_in := PHASE_SHIFT;
      end if;
      first_time := false;
    end if;
    
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;        
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := PHASE_SHIFT + 256;
      elsif ((CLKOUT_PHASE_SHIFT = "variable_positive") or (CLKOUT_PHASE_SHIFT = "VARIABLE_POSITIVE")) then
        ps_in := PHASE_SHIFT + 256;
      elsif ((CLKOUT_PHASE_SHIFT = "variable_center") or (CLKOUT_PHASE_SHIFT = "VARIABLE_CENTER")) then
        ps_in := PHASE_SHIFT + 256;
      elsif ((CLKOUT_PHASE_SHIFT = "direct") or (CLKOUT_PHASE_SHIFT = "DIRECT")) then
        ps_in := PHASE_SHIFT;
      end if;
      ps_lock <= '0';
      ps_overflow_out <= '0';
      ps_delay <= 0 ps;      
    else
      if (rising_edge(lock_period_pulse)) then
        if ((ps_type = 0) or (ps_type = 1) or (ps_type = 3) or (ps_type = 4))  then        
          ps_delay <= (ps_in * period_div / 256);        
        elsif  (ps_type = 5) then 
          ps_delay <= ps_in * tap_delay_step;
        end if;
      end if;      
      if (rising_edge (lock_period)) then
        if ((ps_type = 0) or (ps_type = 1) or (ps_type = 3) or (ps_type = 4))  then
          if (PHASE_SHIFT > 0) then
            if (((ps_in * period_orig) / 256) > (period_orig + FINE_SHIFT_RANGE)) then
            Write ( Message, string'(" Function Error : Instance "));
            Write ( Message, Instancepath );          
              Write ( Message, string'(" Requested Phase Shift = "));

              Write ( Message, string'(" PHASE_SHIFT * PERIOD/256 = "));
              Write ( Message, PHASE_SHIFT);
              Write ( Message, string'(" * "));
              Write ( Message, period_orig /256);
              Write ( Message, string'(" = "));            
              Write ( Message, (PHASE_SHIFT) * period_orig / 256 );                      
              Write ( Message, string'(" This exceeds the FINE_SHIFT_RANGE of "));            
              Write ( Message, FINE_SHIFT_RANGE);
              assert false report Message.all severity error;
              DEALLOCATE (Message);          
            end if;
          elsif (PHASE_SHIFT < 0) then
            if ((period_orig > FINE_SHIFT_RANGE) and ((ps_in * period_orig / 256) < period_orig - FINE_SHIFT_RANGE)) then
          Write ( Message, string'(" Function Error : Instance "));
          Write ( Message, Instancepath );          
            Write ( Message, string'(" Requested Phase Shift = "));

            Write ( Message, string'(" PHASE_SHIFT * PERIOD/256 = "));
            Write ( Message, PHASE_SHIFT);
            Write ( Message, string'(" * "));
            Write ( Message, period_orig /256);
            Write ( Message, string'(" = "));            
            Write ( Message, (-PHASE_SHIFT) * period_orig / 256);                      
            Write ( Message, string'(" This exceeds the FINE_SHIFT_RANGE of "));            
            Write ( Message, FINE_SHIFT_RANGE);                                      
              assert false report Message.all severity error;
              DEALLOCATE (Message);                  
            end if;
          end if;          
        end if;
        if (ps_type = 5) then
            if ((ps_in * tap_delay_step) > FINE_SHIFT_RANGE) then
            Write ( Message, string'(" Functional Error : Allowed FINE_SHIFT_RANGE on instance "));
            Write ( Message, Instancepath );          
              Write ( Message, string'(" is between 0 to "));
              Write ( Message, FINE_SHIFT_RANGE/tap_delay_step);
              assert false report Message.all severity error;
              DEALLOCATE (Message);          
            end if;          
        end if;
      end if;
      
      if (rising_edge(PSCLK_dly)) then
        if ((ps_type = 3) or (ps_type = 4)) then
          if (PSEN_dly = '1') then
            if (ps_lock = '1') then
              Write ( Message, string'(" Warning : Please wait for PSDONE signal before adjusting the Phase Shift. "));
              assert false report Message.all severity warning;
              DEALLOCATE (Message);              
            else
              if (PSINCDEC_dly = '1') then
                if (ps_in = ps_max) then
                  ps_overflow_out <= '1';
                elsif (((ps_in + 1) * period_orig / 256) > period_orig + FINE_SHIFT_RANGE) then
                  ps_overflow_out <= '1';
                else
                  ps_in := ps_in + 1;
                  ps_delay <= (ps_in * period_div / 256);
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                
              elsif (PSINCDEC_dly = '0') then
                if (ps_in = ps_min) then
                  ps_overflow_out <= '1';
                elsif ((period_orig > FINE_SHIFT_RANGE) and (((ps_in - 1) * period_orig / 256) < period_orig - FINE_SHIFT_RANGE)) then
                  ps_overflow_out <= '1';
                else
                  ps_in := ps_in - 1;
                  ps_delay <= (ps_in * period_div / 256);
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                                
              end if;
            end if;
          end if;
        end if;
      end if;

      if (rising_edge(PSCLK_dly)) then
        if (ps_type = 5) then
          if (PSEN_dly = '1') then
            if (ps_lock = '1') then
              Write ( Message, string'(" Warning : Please wait for PSDONE signal before adjusting the Phase Shift. "));
              assert false report Message.all severity warning;
              DEALLOCATE (Message);              
            else
              if (PSINCDEC_dly = '1') then
                if (ps_in = ps_max) then
                  ps_overflow_out <= '1';
                elsif (ps_in * tap_delay_step > FINE_SHIFT_RANGE) then
                  ps_overflow_out <= '1';
                else
                  ps_in := ps_in + 1;
                  ps_delay <= ps_in * tap_delay_step;
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                
              elsif (PSINCDEC_dly = '0') then
                if (ps_in = ps_min) then
                  ps_overflow_out <= '1';
                elsif (ps_in * tap_delay_step > FINE_SHIFT_RANGE) then
                  ps_overflow_out <= '1';
                else
                  ps_in := ps_in - 1;
                  ps_delay <= ps_in * tap_delay_step;
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                                
              end if;
            end if;
          end if;
        end if;
      end if;

      if (rising_edge(clkin_ps)) then
        if (ps_type = 5) then      
          if (ps_drp_lock = '1') then
            if (inc_dec = '1') then
              if (ps_in < ps_in_drp) then
                if (single_step_lock = '0')  then                
                  single_step_lock := '1';
                  ps_in := ps_in + 1;
                  ps_delay <= ps_delay + tap_delay_step;            
                end if;
              elsif (ps_in = ps_in_drp) then
                ps_drp_lock <= '0';
              end if;
            elsif (inc_dec = '0') then
              if (ps_in > ps_in_drp) then              
                if (single_step_lock = '0')  then
                  single_step_lock := '1';
                  ps_in := ps_in - 1;
                  ps_delay <= ps_delay - tap_delay_step;            
                end if;
              elsif (ps_in = ps_in_drp) then
                ps_drp_lock <= '0';
              end if;                
            end if;  
          end if;
        end if;
      end if;
    end if;      

    ps_in_current <= ps_in;    
    if (falling_edge(psdone_out)) then
      ps_lock <= '0';
    end if;

    if (single_step_lock = '1') then
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      single_step_lock := '0';         
    end if;

    if (rising_edge(ps_kick_off_cmd)) then
      wait until (rising_edge(DCLK_dly));
      wait until (rising_edge(DCLK_dly));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      ps_drp_lock <= '1';
    end if;
   wait on clkin_ps, lock_period, lock_period_pulse, PSCLK_dly, rst_ipd, ps_kick_off_cmd, psdone_out;
  end process determine_phase_shift;


  drive_psdone_out : process
  begin
   if (ps_type /= 0 and ps_type /= 1) then
    if (rising_edge(ps_lock)) then
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(clkin_ps));      
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(psclk_dly));
      wait until (rising_edge(psclk_dly));
      psdone_out <= '1';
      wait until (rising_edge(psclk_dly));
      psdone_out <= '0';
    end if;    

    if (falling_edge(ps_drp_lock)) then
        if (ps_type = 5) then
          wait until (rising_edge(clkin_ps));
          wait until (rising_edge(clkin_ps));
          wait until (rising_edge(clkin_ps));
          wait until (rising_edge(clkin_ps));          
          wait until (rising_edge(PSCLK_dly));
          wait until (rising_edge(PSCLK_dly));
          psdone_out <= '1';
          wait until (rising_edge(PSCLK_dly));
          psdone_out <= '0';
        end if;
      end if;    
   end if;
   wait on ps_lock, ps_drp_lock;
  end process drive_psdone_out;

--
--determine clock period
--    
  process (period_orig) begin
     period_stop_ck <= period_orig * clock_stopped_factor;
  end process;

  determine_clock_period : process(clkin_div, rst_ipd)
    variable clkin_edge_previous : time := 0 ps; 
    variable clkin_edge_current : time := 0 ps;
  begin
    if  (rst_ipd = '1') then
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
    elsif (falling_edge(clkin_div) ) then
      if (lock_period = '1') then
        if (100000000 ps < clkin_period_real(0)/1000) then
        elsif ((period_stop_ck <= clkin_period_real(0)) and (clock_stopped = '0')) then
          clkin_period_real(0) <= clkin_period_real(1);              
        end if;
     end if;
    end if;
  end process determine_clock_period;
  
  evaluate_clock_period : process
    variable Message : line;
  begin
    if  (rst_ipd = '1') then
      lock_period <= '0';
      clock_stopped <= '1';
      period_orig <= 0 ps;
      period <= 0 ps;
    elsif (falling_edge(clkin_div) ) then
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
            Write ( Message,  clkin_period_real(0));
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));            
          elsif ((period_stop_ck <= clkin_period_real(0)) and (clock_stopped = '0')) then
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
    wait on clkin_div, rst_ipd;
  end process evaluate_clock_period;

  period_cal_p : process(period) 
        variable period_25_tmp : time := 0 ps;
  begin
        period_25_tmp := period / 4;
        period_50 <= 2 * period_25_tmp;
        period_25 <= period_25_tmp;
  end process;

  lock_period_dly <= transport lock_period after period_50;

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
    if (rst_ipd = '1') then
      fb_delay <= 0 ps;      
      fb_delay_found <= '0';                        
    elsif (rising_edge(lock_ps_dly)) then
        if  ((lock_period = '1') and (clkfb_type /= 0)) then
          if (clkfb_type = 1) then
            wait until ((rising_edge(clk0_sig)) or (rst_ipd'event));                                
            delay_edge := NOW;
          elsif (clkfb_type = 2) then
            wait until ((rising_edge(clk2x_sig)) or (rst_ipd'event));            
            delay_edge := NOW;
          end if;
          wait until ((rising_edge(clkfb_ipd)) or (rst_ipd'event));          
          temp1 := ((NOW*1) - (delay_edge*1))/ (1 ps);
          temp2 := (period_orig * 1)/ (1 ps);
          temp := temp1 mod temp2;
          fb_delay <= temp * 1 ps;
          fb_delay_found <= '1';          
        end if;
    end if;
    wait on lock_ps_dly, rst_ipd;
  end process determine_clock_delay;
--
--  determine feedback lock
--  
  GEN_CLKFB_WINDOW : process
  begin
    if  (rst_ipd = '1') then
      clkfb_window <= '0';  
    elsif (rising_edge(CLKFB_ipd)) then
        wait for 0 ps;
        clkfb_window <= '1';
        wait for cycle_jitter;        
        clkfb_window <= '0';
    end if;      
    wait on clkfb_ipd, rst_ipd;
  end process GEN_CLKFB_WINDOW;

  GEN_CLKIN_WINDOW : process
  begin
    if  (rst_ipd = '1') then
      clkin_window <= '0';
    elsif (rising_edge(clkin_fb)) then
        wait for 0 ps;
        clkin_window <= '1';
        wait for cycle_jitter;        
        clkin_window <= '0';
    end if;      
    wait on clkin_fb, rst_ipd;
  end process GEN_CLKIN_WINDOW;  

  set_reset_lock_clkin : process
  begin
    if  (rst_ipd = '1') then
      lock_clkin <= '0';                  
    elsif (rising_edge(clkin_fb)) then
        wait for 1 ps;
        if (((clkfb_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '0') and (lock_out(0) = '1'))) then
          lock_clkin <= '1';
        else
--          if (chk_enable = '1') then          
          if (chk_enable = '1' and ps_lock = '0') then          
            lock_clkin <= '0';
          end if;
        end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process set_reset_lock_clkin;

  set_reset_lock_clkfb : process
  begin
    if  (rst_ipd = '1') then
      lock_clkfb <= '0';                  
    elsif (rising_edge(clkfb_ipd)) then
        wait for 1 ps;
        if (((clkin_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '0') and (lock_out(0) = '1'))) then
          lock_clkfb <= '1';
        else
--          if (chk_enable = '1') then                    
          if (chk_enable = '1' and ps_lock = '0') then                    
            lock_clkfb <= '0';
          end if;
        end if;
    end if;          
    wait on clkfb_ipd, rst_ipd;
  end process set_reset_lock_clkfb;

  assign_lock_delay : process(clkin_fb, rst_ipd)
  begin
    if (rst_ipd = '1') then
      lock_delay <= '0';          
    elsif (falling_edge(clkin_fb)) then
        lock_delay <= lock_clkin or lock_clkfb;
    end if;
  end process;

--
--generate lock signal
--  
  
  
  generate_lock : process(clkin_ps, rst_ipd)
  begin
    if (rst_ipd='1') then
      lock_out <= "00";
      locked_out <= '0';      
      lock_out1_neg <= '0';
    elsif (rising_edge(clkin_ps)) then
        if (clkfb_type = 0) then
          lock_out(0) <= lock_period;
        else
          lock_out(0) <= lock_period and lock_delay and lock_fb;
        end if;                           
        lock_out(1) <= lock_out(0);
        locked_out <= lock_out(1);          
    elsif (falling_edge(clkin_ps)) then
        lock_out1_neg <= lock_out(1);
    end if;
  end process generate_lock;

  locked_out_tmp <= locked_out after period_fx;
  locked_pulse <= '1' when ((locked_out = '1') and (locked_out_tmp = '0')) else '0';  


--
--generate the clk1x_out
--  
  
  gen_clk1x : process (clkin_ps, rst_ipd)
  begin
    if (rst_ipd = '1') then
        clk0_out <= '0';
    elsif (rising_edge(clkin_ps)) then
        if ((clk1x_type = 1) and (lock_out(0) = '1')) then
          clk0_out <= '1', '0' after period/2;
        else
          clk0_out <= '1';
        end if;
    elsif (falling_edge(clkin_ps)) then
        if ((((clk1x_type = 1) and (lock_out(0) = '1')) = false) or ((lock_out(0) = '1') and (lock_out(1) = '0'))) then        
          clk0_out <= '0';
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
           if ( ((divide_type rem (2)) > 0) and (dll_mode_type = "00")) then
             clkdv_out <= '0' after (period/4);
           else
            clkdv_out <= '0';
           end if;
         end if;
      end if;
    end if;
  end process;


  determine_clkfx_divide_multiply : process(rst_ipd, clkfx_multiply_drp, clkfx_divide_drp)
  begin
      if (rst_ipd = '1') then    
        numerator <= clkfx_multiply_drp;
        denominator <= clkfx_divide_drp;
      end if;
  end process determine_clkfx_divide_multiply;

--
-- generate fx output signal
--
  
--  calculate_period_fx : process(lock_period, period)
  calculate_period_fx : process(lock_ps, period, rst_ipd)
  begin
    if (rst_ipd = '1') then
      period_fx <= 0 ps;
      remain_fx <= 0 ps;
    elsif (lock_ps = '1') then
      period_fx <= (period * denominator) / (numerator * 2);
      remain_fx <= (((period/1 ps) * denominator) mod (numerator * 2)) * 1 ps;        
    end if;
  end process calculate_period_fx;

  
  generate_clkfx : process
     variable temp : integer;    
  begin
     if (rst_ipd = '1') then
       clkfx_out <= '0';
     elsif (clkin_lost_out_ext = '1') then
       if (locked_out = '1') then
         wait until (falling_edge(rst_reg(2)));  
       end if;
     elsif (rising_edge(clkin_ps)) then
       if (lock_out(1) = '1') then
         clkfx_out <= '1';
         temp := numerator * 2 - 1 - 1;
         for p in 0 to temp loop
           wait for (period_fx);
           clkfx_out <= not clkfx_out;
         end loop;
         if (period_fx > (period / 2)) then
           wait for (period_fx - (period / 2));
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

  detect_first_time_locked : process
    begin
      if (first_time_locked = false) then
        if (rising_edge(locked_out)) then
          first_time_locked <= true;
        end if;        
      end if;
      wait on locked_out;
  end process detect_first_time_locked;  

  control_status_bits: process(clkfb_lost_out, clkfx_lost_out, clkin_lost_out, en_status, ps_overflow_out, rst_ipd)
  begin  
    if ((rst_ipd = '1') or (en_status = false)) then
      ps_overflow_out_ext <= '0';
      clkin_lost_out_ext <= '0';
      clkfx_lost_out_ext <= '0';
      clkfb_lost_out_ext <= '0';      
    else
      ps_overflow_out_ext <= ps_overflow_out;
      clkin_lost_out_ext <= clkin_lost_out;
      clkfx_lost_out_ext <= clkfx_lost_out;
      clkfb_lost_out_ext <= clkfb_lost_out;      
    end if;
  end process  control_status_bits;      

  do_out_s(0) <= ps_overflow_out_ext;
  do_out_s(1) <= clkin_lost_out_ext;
  do_out_s(2) <= clkfx_lost_out_ext;
  do_out_s(3) <= clkfb_lost_out_ext;            

  set_reset_en_status : process (locked_out, rst_ipd)
  begin
    if (rst_ipd='1') then
      en_status <= false;
    elsif (rising_edge(locked_out)) then
      en_status <= true;
    end if;
  end process set_reset_en_status;

  set_reset_clkin_chkin : process (clkin_fb, chk_rst)
  begin
    if (chk_rst='1') then
       clkin_chkin <= '0';
    elsif (rising_edge(clkin_fb)) then
       clkin_chkin <= '1';
    end if;
  end process set_reset_clkin_chkin;

  set_reset_clkfb_chkin : process(clkfb_ipd, chk_rst)
  begin
    if (chk_rst='1') then
       clkfb_chkin <= '0';
    elsif (rising_edge(clkfb_ipd)) then
       clkfb_chkin <= '1';
    end if;
  end process set_reset_clkfb_chkin;

  chk_rst <= '1' when ((rst_ipd = '1') or (clock_stopped = '1')) else '0';
  chk_enable <= '1' when ((clkin_chkin = '1') and (clkfb_chkin = '1') and (lock_ps = '1') and (lock_fb = '1')) else '0';      


   do_out <= do_out_drp1 when (do_stat_en = '0') else do_out_s;

    drp : process
    variable first_time : boolean := true;
    variable address : integer;
    variable valid_daddr : boolean := false;
--    variable ps_drp : integer := 0;
    variable  dfs_mode_type_i : std_ulogic;
    variable  clkin_type_i : std_ulogic;
    variable  dll_mode_type_i : std_logic_vector(1 downto 0);
    variable  clkfx_m_reg : std_logic_vector(7 downto 0);
    variable  clkfx_d_reg : std_logic_vector(7 downto 0);

    variable Message : line;    

  begin
      if (first_time = true) then
        clkfx_multiply_drp <= CLKFX_MULTIPLY;
        clkfx_divide_drp <= CLKFX_DIVIDE;
        clkfx_m_reg := STD_LOGIC_VECTOR(TO_UNSIGNED(CLKFX_MULTIPLY, 8));
        clkfx_d_reg := STD_LOGIC_VECTOR(TO_UNSIGNED(CLKFX_DIVIDE, 8));
        clkfx_md_reg <= (clkfx_m_reg & clkfx_d_reg);
        if (DFS_FREQUENCY_MODE = "HIGH") then
            dfs_mode_type_i := '1';
            dfs_mode_type <= '1';
        else
            dfs_mode_type_i := '0';
            dfs_mode_type <= '0';
        end if;
        if (DLL_FREQUENCY_MODE = "HIGH") then
            dll_mode_type_i := "11";
            dll_mode_type <= "11";
        else
            dll_mode_type_i := "00";
            dll_mode_type <= "00";
        end if;
        if (CLKIN_DIVIDE_BY_2 = TRUE) then
            clkin_type_i := '1';
            clkin_type <= '1';
        else
            clkin_type_i := '0';
            clkin_type <= '0';
        end if;
        dfs_mode_reg <= ("XXXXXXXXXXXXX" & dfs_mode_type_i & "XX");
        dll_mode_reg <= ("XXXXXXXXXXXX" & dll_mode_type_i & "XX");
        clkin_div2_reg <= ("XXXXX" & clkin_type_i & "XXXXXXXXXX");
        
        do_stat_en <= '1';
        first_time := false;
      end if;
    
    valid_daddr := addr_is_valid(DADDR_dly);
    if (valid_daddr) then
      address := slv_to_int(DADDR_dly);
    end if;
    
    if (GSR_dly = '1') then
       drp_lock <= '0';
       ps_in_drp <= 0;
       ps_kick_off_cmd <= '0';
       do_out_drp <= "0000000000000000";
       do_out_drp1 <= "0000000000000000";
       do_stat_en <= '1';
       drdy_out <= '0';
    elsif (rising_edge(DCLK_dly))  then
      if (DEN_dly = '1') then
        if (drp_lock = '1') then
          Write ( Message, string'(" Warning : DEN is high. Please wait for DRDY signal before next read/write operation through DRP. "));
          assert false report Message.all severity warning;
          DEALLOCATE (Message);              
        else
          drp_lock <= '1';
          if (DWE_dly = '0') then 
            if (valid_daddr) then
              if (SIM_DEVICE = "VIRTEX5") then
                 if (address = DCM_DEFAULT_STATUS_ADDR) then
                     do_stat_en <= '1';
                 else 
                     do_stat_en <= '0';
                     if (address  = DFS_FREQ_MODE_ADDR) then
                         do_out_drp <= dfs_mode_reg;
                     elsif (address  = DLL_FREQ_MODE_ADDR) then
                         do_out_drp <= dll_mode_reg;
                     elsif (address  = CLKFX_MULTIPLY_ADDR) then
                         do_out_drp <= clkfx_md_reg;
                     elsif (address  = CLKIN_DIV_BY2_ADDR) then
                         do_out_drp <= clkin_div2_reg;
                     else
                         do_out_drp <= "0000000000000000";
                     end if;
                 end if;
               end if;
             end if;
          end if;  -- DWE_dly = '0'

          if (DWE_dly = '1') then
            if (valid_daddr) then
              if (address = CLKFX_MULTIPLY_ADDR) then
                if (sim_device_type = '1') then
                  clkfx_divide_drp <= slv_to_int(DI_dly(7 downto 0)) + 1;
                  clkfx_multiply_drp <= slv_to_int(DI_dly(15 downto 8)) + 1;
                  clkfx_md_reg <= DI_dly;
                else 
                   clkfx_multiply_drp <= slv_to_int(DI_dly(4 downto 0)) + 1;
                end if;
              elsif (address = CLKFX_DIVIDE_ADDR and sim_device_type = '0') then
                clkfx_divide_drp <= slv_to_int(DI_dly(4 downto 0)) + 1;
              elsif (address = PHASE_SHIFT_ADDR) then
--                ps_drp := slv_to_int(DI_dly(10 downto 0));
                ps_drp <= slv_to_int(DI_dly(10 downto 0));
              elsif (address = PHASE_SHIFT_KICK_OFF_ADDR) then
                if (ps_kick_off_cmd = '0') then
                  ps_kick_off_cmd <= '1';
                  ps_in_drp <= ps_drp;
                  if (ps_in_current < ps_drp) then
                    inc_dec <= '1';
                  elsif (ps_in_current > ps_drp) then
                    inc_dec <= '0';
                  end if;
                end if;
             elsif ((address = DFS_FREQ_MODE_ADDR) and (sim_device_type = '1')) then
                  dfs_mode_reg <= DI_dly;
                  dfs_mode_type <= DI_dly(2);
             elsif ((address = DLL_FREQ_MODE_ADDR) and (sim_device_type = '1')) then
                  dll_mode_reg <= DI_dly;
                  dll_mode_type <= DI_dly(3 downto 2);
             elsif ((address = CLKIN_DIV_BY2_ADDR) and (sim_device_type = '1')) then
                  clkin_div2_reg <= DI_dly;
                  clkin_type <= DI_dly(10);
             else
      Write ( Message, string'(" Warning :  Address DADDR="));
      Write ( Message,  address);
      Write ( Message, string'(" on the DCM_ADV instance is unsupported") );
      Write ( Message, '.' & LF );
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
              end if;
            end if;                          
          end if; -- DWE = 1
--        end if;
      end if;
    end if;        
    if (drp_lock = '1') then
         drp_lock1 <= '1';
    end if;
    if (drp_lock1 = '1') then
      drp_lock <= '0';      
      drp_lock1 <= '0';      
      drdy_out <= '1';
      do_out_drp1 <= do_out_drp;
      do_out_drp <= "0000000000000000";
    end if;
    
    if (drdy_out = '1') then
      drdy_out <= '0';
       do_out_drp1 <= "0000000000000000";
    end if;

    end if;  -- GSR_dly 
    if (falling_edge(ps_drp_lock)) then
      if (ps_kick_off_cmd = '1') then
        ps_kick_off_cmd <= '0';  
      end if;
    end if;

    wait on DCLK_dly, ps_drp_lock, GSR_dly;
    
    end process drp;


--   drive_drdy_out : process
--     begin
--     if (falling_edge(drp_lock)) then
--       wait until (rising_edge(DCLK_dly));       
--       drdy_out <= '1';
--       wait until (rising_edge(DCLK_dly));
--       drdy_out <= '0';
--     end if;      
--   wait on drp_lock;    
--   end process drive_drdy_out;

--
--generate all output signal
--

  schedule_clk0 : process(clk0_out, rst_ipd)
  begin
      if (rst_ipd = '1') then
        CLK180 <= '0';
        CLK270 <= '0';
        clk0_sig <= '0';
        CLK90 <= '0';
        CLK0 <= '0'; 
      elsif (CLK0_out'event) then
        CLK0 <= transport CLK0_out after clkout_delay;
        clk0_sig <= transport CLK0_out after clkout_delay;
        CLK90 <= transport clk0_out after (clkout_delay + period / 4);
        CLK180 <= transport clk0_out after (clkout_delay + period/2);
        CLK270 <= transport (not clk0_out) after (clkout_delay + period/4);
      end if;
  end process schedule_clk0;

  schedule_clk2x : process (CLK2X_out, rst_ipd)
  begin
    if (rst_ipd = '1') then
        CLK2X180 <= '0';
        CLK2X <= '0';
        clk2x_sig <= '0';
      elsif (clk2x_out'event) then
        CLK2X <= transport clk2x_out after clkout_delay;
        clk2x_sig <= transport clk2x_out after clkout_delay;
        CLK2X180 <= transport (not CLK2X_out) after clkout_delay;  
    end if;
  end process schedule_clk2x;

   CLKDV <= transport clkdv_out after clkout_delay;

  schedule_clkfx : process
  begin
      if (rst_ipd = '1') then
        CLKFX <= '0';
      elsif (clkfx_out'event) then
        CLKFX <= transport clkfx_out after clkout_delay;                          
      end if;

      if ((rst_ipd = '1') or (not first_time_locked)) then
        CLKFX180 <= '0';
      elsif (clkfx_out'event or (first_time_locked'event and first_time_locked = true)
             or locked_out'event) then
        CLKFX180 <= transport (not clkfx_out) after clkout_delay;  
      end if;
    wait on clkfx_out, rst_ipd, first_time_locked, locked_out;
  end process schedule_clkfx;

 
  DO <= do_out;
  locked_out_out <= 'X' when rst_flag = '1' else locked_out;

   DRDY <= drdy_out;
   LOCKED <= locked_out_out;
   PSDONE <= psdone_out;

  

end DCM_ADV_V;

