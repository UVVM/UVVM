-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/CLKDLLE.vhd,v 1.1 2008/06/19 16:59:23 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Clock Delay Locked Loop for Virtex-E
-- /___/   /\     Filename : CLKDLLE.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:55:21 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/09/05 - Change RST check from 3 clkin cycles to 2 ns (CR200477).
--    05/25/06 - Remove GSR (232012).
--    05/10/07 - Remove Vital timing.
-- End Revision

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;



entity clkdlle_maximum_period_check is
  generic (
    clock_name : string := "";
    maximum_period : time);
  port(
    clock : in std_ulogic;
    rst : in std_ulogic
    );
end clkdlle_maximum_period_check;

architecture clkdlle_maximum_period_check_V of clkdlle_maximum_period_check is
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

      if ((clock_period > maximum_period) and (rst = '0')) then
        Write ( Message, string'(" Error : Input Clock Period of"));
        Write ( Message, clock_period/1000.0 );
        Write ( Message, string'(" on the ") );
        Write ( Message, clock_name );
        Write ( Message, string'(" port ") );
        Write ( Message, string'(" of CLKDLLE  ") );
        Write ( Message, string'(" exceeds allotted value of ") );
        Write ( Message, maximum_period/1000.0 );
        Write ( Message, string'(" at simulation time ") );
        Write ( Message, clock_edge_current/1000.0 );
        Write ( Message, '.' & LF );
        assert false report Message.all severity warning;
        DEALLOCATE (Message);
      end if;
    end if;
    wait on clock;
  end process MAX_PERIOD_CHECKER;
end clkdlle_maximum_period_check_V;

----- CELL CLKDLLE -----
library IEEE;
use IEEE.std_logic_1164.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity CLKDLLE is
  generic (

    CLKDV_DIVIDE : real := 2.0;
    DUTY_CYCLE_CORRECTION : boolean := true;
    FACTORY_JF : bit_vector := X"C080";  --non-simulatable
    STARTUP_WAIT : boolean := false  --non-simulatable
    );

  port (
    CLK0 : out std_ulogic := '0';
    CLK180 : out std_ulogic := '0';
    CLK270 : out std_ulogic := '0';
    CLK2X : out std_ulogic := '0';
    CLK2X180 : out std_ulogic := '0';
    CLK90 : out std_ulogic := '0';
    CLKDV : out std_ulogic := '0';
    LOCKED : out std_ulogic := '0';

    CLKFB : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0';
    RST : in std_ulogic := '0'
    );

end CLKDLLE;

architecture CLKDLLE_V of CLKDLLE is

  component clkdlle_maximum_period_check
    generic (
      clock_name : string := "";
      maximum_period : time);
    port(
      clock : in std_ulogic;
      rst : in std_ulogic
      );
  end component;

  constant MAXPERCLKIN : time := 40000 ps;
  constant SIM_CLKIN_CYCLE_JITTER : time := 300 ps;
  constant SIM_CLKIN_PERIOD_JITTER : time := 1000 ps;

  signal CLKFB_ipd, CLKIN_ipd, RST_ipd : std_ulogic;
  signal clk0_out : std_ulogic;
  signal clk2x_out, clkdv_out, locked_out : std_ulogic := '0';

  signal clkfb_type : integer;
  signal divide_type : integer;
  signal clk1x_type : integer;

  signal lock_period, lock_delay, lock_clkin, lock_clkfb : std_ulogic := '0';
  signal lock_out : std_logic_vector(1 downto 0) := "00";

  signal lock_fb : std_ulogic := '0';
  signal fb_delay_found : std_ulogic := '0';

  signal clkin_ps : std_ulogic;
  signal clkin_fb, clkin_fb0, clkin_fb1, clkin_fb2 : std_ulogic;
  type   real_array_usr is array (2 downto 0) of time;
  signal clkin_period_real : real_array_usr := (0.000 ns, 0.000 ns, 0.000 ns);
  signal period : time := 0 ps;
  signal period_orig : time := 0 ps;
  signal period_ps : time := 0 ps;
  signal clkout_delay : time := 0 ps;
  signal fb_delay : time := 0 ps;
  signal period_dv_high, period_dv_low : time := 0 ps;
  signal cycle_jitter, period_jitter : time := 0 ps;

  signal clkin_window, clkfb_window : std_ulogic := '0';
  signal clkin_5050 : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0) := "000";

  signal clkin_period_real0_temp : time := 0 ps;
  signal ps_lock_temp : std_ulogic := '0';

  signal clk0_temp : std_ulogic := '0';
  signal clk2x_temp : std_ulogic := '0';

  signal no_stop : boolean := false;

begin
  INITPROC : process
  begin
    detect_resolution
      (model_name => "CLKDLLE"
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
         EntityName => "CLKDLLE",
         GenericValue => CLKDV_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, or 16.0",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    clkfb_type <= 2;

    period_jitter <= SIM_CLKIN_PERIOD_JITTER;
    cycle_jitter <= SIM_CLKIN_CYCLE_JITTER;

    case DUTY_CYCLE_CORRECTION is
      when false => clk1x_type <= 0;
      when true => clk1x_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DUTY_CYCLE_CORRECTION",
           EntityName => "CLKDLLE",
           GenericValue => DUTY_CYCLE_CORRECTION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    case STARTUP_WAIT is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "STARTUP_WAIT",
           EntityName => "CLKDLLE",
           GenericValue => STARTUP_WAIT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;
    wait;
  end process INITPROC;

--
-- input wire delays
--

  CLKIN_ipd <= CLKIN;
  CLKFB_ipd <= CLKFB;
  RST_ipd <= RST;
  
  i_max_clkin : clkdlle_maximum_period_check
    generic map (
      clock_name => "CLKIN",
      maximum_period => MAXPERCLKIN)

    port map (
      clock => clkin_ipd,
      rst => rst_ipd);

  assign_clkin_ps : process
  begin
    if (rst_ipd = '0') then
      clkin_ps <= clkin_ipd;
    elsif (rst_ipd = '1') then
      clkin_ps <= '0';      
      wait until (falling_edge(rst_reg(2)));
    end if;
    wait on clkin_ipd, rst_ipd;
  end process assign_clkin_ps;

  clkin_fb0 <= transport (clkin_ps and lock_fb) after period_ps/4;
  clkin_fb1 <= transport clkin_fb0 after period_ps/4;
  clkin_fb2 <= transport clkin_fb1 after period_ps/4;
  clkin_fb <= transport clkin_fb2 after period_ps/4;

  determine_period_ps : process
    variable clkin_ps_edge_previous : time := 0 ps;
    variable clkin_ps_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
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

  assign_lock_fb : process
  begin
    if (rising_edge(clkin_ps)) then
      lock_fb <= lock_period;
    end if;
    wait on clkin_ps;
  end process assign_lock_fb;

  calculate_clkout_delay : process
  begin
    if (rst_ipd'event) then
      clkout_delay <= 0 ps;        
    elsif (period'event or fb_delay'event) then
      clkout_delay <= period - fb_delay;
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
    variable rst_tmp1, rst_tmp2 : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (falling_edge(rst_ipd))) then
      if (rst_ipd = '1') then
        rst_tmp1 := NOW;
      elsif (rst_ipd = '1') then
        rst_tmp2 := NOW - rst_tmp1;
      end if;
      if ((rst_tmp2 < 2000 ps) and (rst_tmp2 /= 0 ps)) then
        Write ( Message, string'(" Error : RST "));
        Write ( Message, string'(" must be asserted atleast for 2 ns. "));
        assert false report Message.all severity error;
        DEALLOCATE (Message);        
      end if;  
    end if;
    wait on rst_ipd;
  end process check_rst_width;

--
--determine clock period
--
  determine_clock_period : process
    variable clkin_edge_previous : time := 0 ps;
    variable clkin_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
      clkin_period_real(0) <= 0 ps;
      clkin_period_real(1) <= 0 ps;
      clkin_period_real(2) <= 0 ps;
    elsif (rising_edge(clkin_ps)) then
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
    wait on clkin_ps, no_stop, rst_ipd;
  end process determine_clock_period;

  evaluate_clock_period : process
    variable clock_stopped : std_ulogic := '1';    
    variable Message : line;
  begin
    if (rst_ipd'event) then
      lock_period <= '0';
      clock_stopped := '1';
      clkin_period_real0_temp <= 0 ps;                        
    else
      if (falling_edge(clkin_ps)) then
        if (lock_period = '0') then
          if ((clkin_period_real(0) /= 0 ps ) and (clkin_period_real(0) - cycle_jitter <= clkin_period_real(1)) and (clkin_period_real(1) <= clkin_period_real(0) + cycle_jitter) and (clkin_period_real(1) - cycle_jitter <= clkin_period_real(2)) and (clkin_period_real(2) <= clkin_period_real(1) + cycle_jitter)) then
            lock_period <= '1';
            period_orig <= (clkin_period_real(0) + clkin_period_real(1) + clkin_period_real(2)) / 3;
            period <= clkin_period_real(0);
          end if;
        elsif (lock_period = '1') then
          if (100000000 ps < clkin_period_real(0)/1000) then
            Write ( Message, string'(" Error : CLKIN stopped toggling "));
            Write ( Message, string'(" exceeds "));
            Write ( Message, string'(" 10000 "));
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, string'(" clkin_period(0) / 10000.0 "));
            Write ( Message, string'(" ns "));
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          elsif ((period_orig * 2 < clkin_period_real(0)) and (clock_stopped = '0')) then
            clkin_period_real0_temp <= clkin_period_real(1);
            no_stop <= not no_stop;
              clock_stopped := '1';            
          elsif ((clkin_period_real(0) < period_orig - period_jitter) or (period_orig + period_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Error : Input Clock Period Jitter  "));
            Write ( Message, string'(" exceeds "));
            Write ( Message, period_jitter / 1000.0 );
            Write ( Message, string'(" Locked CLKIN Period = "));
            Write ( Message, period_orig / 1000.0 );
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0) / 1000.0 );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          elsif ((clkin_period_real(0) < clkin_period_real(1) - cycle_jitter) or (clkin_period_real(1) + cycle_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Error : Input Clock Cycle Jitter  "));
            Write ( Message, string'(" exceeds "));
            Write ( Message, cycle_jitter / 1000.0 );
            Write ( Message, string'(" Previous CLKIN Period = "));
            Write ( Message, clkin_period_real(1) / 1000.0 );
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0) / 1000.0 );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          end if;
        else
          period <= clkin_period_real(0);
          clock_stopped := '0';          
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process evaluate_clock_period;

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
    if (rst_ipd'event) then
      fb_delay <= 0 ps;      
      fb_delay_found <= '0';
    else
      if (rising_edge(lock_period)) then
        if ((lock_period = '1') and (clkfb_type /= 0)) then
          if (clkfb_type = 1) then
            wait until ((rising_edge(clk0_temp)) or (rst_ipd'event));                                
            delay_edge := NOW;
          elsif (clkfb_type = 2) then
            wait until ((rising_edge(clk2x_temp)) or (rst_ipd'event));            
            delay_edge := NOW;
          end if;
          wait until ((rising_edge(clkfb_ipd)) or (rst_ipd'event));          
          temp1 := ((NOW*1) - (delay_edge*1))/ (1 ps);
          temp2 := (period_orig * 1)/ (1 ps);
          temp := temp1 mod temp2;
          fb_delay <= temp * 1 ps;
        end if;
      end if;
      fb_delay_found <= '1';
    end if;
    wait on lock_period, rst_ipd;
  end process determine_clock_delay;
--
-- determine feedback lock
--
  GEN_CLKFB_WINDOW : process
  begin
    if (rst_ipd'event) then
      clkfb_window <= '0';
    else
      if (rising_edge(CLKFB_ipd)) then
        wait for 0 ps;
        clkfb_window <= '1';
        wait for cycle_jitter;
        clkfb_window <= '0';
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process GEN_CLKFB_WINDOW;

  GEN_CLKIN_WINDOW : process
  begin
    if (rst_ipd'event) then
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
    if (rst_ipd'event) then
      lock_clkin <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 1 ps;
        if ((clkfb_window = '1') and (fb_delay_found = '1')) then
          lock_clkin <= '1';
        else
          lock_clkin <= '0';
        end if;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process set_reset_lock_clkin;

  set_reset_lock_clkfb : process
  begin
    if (rst_ipd'event) then
      lock_clkfb <= '0';
    else
      if (rising_edge(clkfb_ipd)) then
        wait for 1 ps;
        if ((clkin_window = '1') and (fb_delay_found = '1')) then
          lock_clkfb <= '1';
        else
          lock_clkfb <= '0';
        end if;
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process set_reset_lock_clkfb;

  assign_lock_delay : process
  begin
    if (rst_ipd'event) then
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

  generate_lock : process
  begin
    if (rst_ipd'event) then
      lock_out <= "00";
      locked_out <= '0';
    else
      if (rising_edge(clkin_ps)) then
        if (clkfb_type = 0) then
          lock_out(0) <= lock_period;
        else
          lock_out(0) <= lock_period and lock_delay and lock_fb;
        end if;
        lock_out(1) <= lock_out(0);
        locked_out <= lock_out(1);

      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process generate_lock;

--
--generate the clk1x_out
--

  gen_clk1x : process
  begin
    if (rst_ipd'event) then
      clkin_5050 <= '0';
    else
      if (rising_edge(clkin_ps)) then
        clkin_5050 <= '1';
        wait for (period/2);
        clkin_5050 <= '0';
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process gen_clk1x;

  clk0_out <= clkin_5050 when (clk1x_type = 1) else clkin_ps;

--
--generate the clk2x_out
--

  gen_clk2x : process
  begin

    if (rising_edge(clkin_ps)) then
      clk2x_out <= '1';
      wait for (period / 4);
      clk2x_out <= '0';
      if (lock_out(0) = '1') then
        wait for (period / 4);
        clk2x_out <= '1';
        wait for (period / 4);
        clk2x_out <= '0';
      else
        wait for (period / 2);
      end if;
    end if;
    wait on clkin_ps;
  end process gen_clk2x;

--
--generate the clkdv_out
--

  determine_clkdv_period : process
  begin
    if (period'event) then
--      period_dv_high <= (period / 2) * (divide_type / 2);
--      period_dv_low <= (period / 2) * (divide_type / 2 + divide_type mod 2);
      period_dv_high <= (period * divide_type)/4;
      period_dv_low <= (period * divide_type)/4;      
    end if;
    wait on period;
  end process determine_clkdv_period;


  gen_clkdv : process
  begin
    if (rising_edge(clkin_ps)) then
      if (lock_out(0) = '1') then
        clkdv_out <= '1';
        wait for (period_dv_high);
        clkdv_out <= '0';
        wait for (period_dv_low);
        clkdv_out <= '1';
        wait for (period_dv_high);
        clkdv_out <= '0';
        wait for (period_dv_low - period/2);
      end if;
    end if;
    wait on clkin_ps;
  end process gen_clkdv;


--
--generate all output signal
--
  schedule_outputs : process
  begin
    if (CLK0_out'event) then
      CLK0 <= transport CLK0_out after clkout_delay;
      clk0_temp <= transport CLK0_out after clkout_delay;
      CLK90 <= transport clk0_out after (clkout_delay + period / 4);
      CLK180 <= transport clk0_out after (clkout_delay + period / 2);
      CLK270 <= transport clk0_out after (clkout_delay + (3 * period) / 4);
    end if;

    if (clk2x_out'event) then
      CLK2X <= transport clk2x_out after clkout_delay;
      clk2x_temp <= transport clk2x_out after clkout_delay;
      CLK2X180 <= transport clk2x_out after (clkout_delay + period/4);
    end if;

    if (clkdv_out'event) then
      CLKDV <= transport clkdv_out after clkout_delay;
    end if;

    LOCKED <= locked_out after 100 ps;
    wait on clk0_out, clk2x_out, clkdv_out, locked_out;
  end process schedule_outputs;

end CLKDLLE_V;

