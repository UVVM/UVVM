--================================================================================================================================
-- Copyright 2026 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Include Verification IPs
library p2l2_vip_pwm;
use p2l2_vip_pwm.pwm_bfm_pkg.all;

use work.pwm_tb_pkg.all;

--hdlregression:tb
-- Test case entity
-- BFM TB without VVCs: p_main calls the BFM procedures on 'pwm', p_edge_logger records every event on 'pwm'. The
-- expected edges come from the reference model in pwm_tb_pkg. For the observation tests, p_stimulus drives 'pwm_obs'
-- with segments or the generator BFM, and p_main observes it.
entity pwm_bfm_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of pwm_bfm_tb is

  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;
  constant C_RESOLUTION : time   := std.env.resolution_limit;

  type t_time_array is array (natural range <>) of time;
  constant C_PERIODS : t_time_array := (10 ns, 1 us, 1 ms);

  signal pwm : std_ulogic := 'U';

  shared variable shared_edge_log : t_edge_log;

  -- Observation tests: the line and the stimulus requests from p_main to p_stimulus
  signal pwm_obs          : std_ulogic := '0';
  signal terminate_loop   : std_ulogic := '0'; -- terminate signal of the observation procedures, never set here
  signal abort_drive      : boolean    := false; -- abort signal of pwm_drive_period(), never toggled here
  signal stim_start       : boolean    := false; -- toggled by p_main, starts a new stimulus (also during one)
  signal stim_busy        : boolean    := false;
  signal stim_segments    : t_segment_array(0 to C_MAX_SEGMENTS - 1);
  signal stim_count       : natural    := 0;
  signal stim_final       : std_ulogic := '0';   -- level after the segments
  signal stim_use_bfm     : boolean    := false; -- generate with pwm_generate() instead of segments
  signal stim_period      : time       := 0 ns;
  signal stim_active_time : time       := 0 ns;
  signal stim_num_periods : natural    := 0;
  signal stim_config      : t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT;

begin

  p_edge_logger : process is
  begin
    wait on pwm;
    shared_edge_log.add(now, pwm);
  end process p_edge_logger;

  -- Drives the stimulus requested by p_main on pwm_obs. A new request ends a segment stimulus at once.
  p_stimulus : process is
    variable v_restart : boolean;
  begin
    wait on stim_start;
    loop
      stim_busy <= true;
      v_restart := false;
      if stim_use_bfm then
        pwm_generate(stim_period, stim_active_time, stim_num_periods, "stimulus", pwm_obs, "STIMULUS", shared_msg_id_panel,
                     stim_config);
      else
        for i in 0 to stim_count - 1 loop
          pwm_obs <= stim_segments(i).level;
          wait on stim_start for stim_segments(i).duration;
          if stim_start'event then
            v_restart := true;
            exit;
          end if;
        end loop;
        if not v_restart then
          pwm_obs <= stim_final;
        end if;
      end if;
      if not v_restart then
        stim_busy <= false;
        wait on stim_start;
      end if;
    end loop;
  end process p_stimulus;

  p_main : process is
    variable v_config : t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT;
    variable v_seed1  : positive;
    variable v_seed2  : positive;
    variable v_aborted : boolean;
    variable v_start  : time;
    variable v_level  : std_ulogic;
    variable v_edges_a : t_edge_array(0 to 1999);
    variable v_edges_b : t_edge_array(0 to 1999);
    variable v_first   : time;
    variable v_last    : time;
    variable v_differs : boolean;
    variable v_sum     : time;

    -- Lets the last assignment to 'pwm' take effect and p_edge_logger record it
    procedure settle is
    begin
      wait for 0 ns;
      wait for 0 ns;
    end procedure;

    -- Rounds units * count / resolution to whole resolution units, half a unit up (integer arithmetic, independent of
    -- the real arithmetic in the BFM)
    function rounded_units(
      constant period     : time;
      constant count      : natural;
      constant resolution : positive) return time is
    begin
      return (2 * count * period + resolution * C_RESOLUTION) / (2 * resolution);
    end function;

    -- Starts a new edge log at the current time, with the line idle
    procedure start_test is
    begin
      settle;
      v_level := pwm;
      shared_edge_log.clear;
      v_start := now;
    end procedure;

    -- Checks the completion time and the final idle level of a pwm_generate() call started by start_test, and the
    -- edges against the reference model for 'params'
    procedure check_generated(
      constant params : t_period_param_array;
      constant msg    : string) is
      variable v_end : time := v_start;
    begin
      for i in params'range loop
        v_end := v_end + params(i).period;
      end loop;
      check_value(now, v_end, ERROR, "completion time: " & msg, C_SCOPE, ID_SEQUENCER_SUB);
      settle;
      check_value(pwm, tb_idle_value(v_config.polarity, v_config.idle_level), MATCH_EXACT, ERROR, "idle after: " & msg, C_SCOPE,
                  ID_SEQUENCER_SUB);
      check_edges(shared_edge_log, expected_edges(v_start, v_level, params, v_config.alignment,
                                           tb_active_level(v_config.polarity),
                                           tb_idle_value(v_config.polarity, v_config.idle_level)), msg, C_SCOPE);
    end procedure;

    -- Generates num_periods periods with pwm_generate(active_time) and checks them
    procedure test_generate(
      constant period      : time;
      constant active_time : time;
      constant num_periods : positive;
      constant msg         : string) is
    begin
      start_test;
      pwm_generate(period, active_time, num_periods, msg, pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(period, active_time, num_periods), msg);
    end procedure;

    -- Checks the logged edges against a hard-coded list, relative to v_start
    procedure check_edges_rel(
      constant times  : t_time_array;
      constant levels : std_ulogic_vector;
      constant msg    : string) is
      variable v_expected : t_edge_array(times'range);
    begin
      for i in times'range loop
        v_expected(i) := (v_start + times(i), levels(levels'low + i - times'low));
      end loop;
      check_edges(shared_edge_log, v_expected, msg, C_SCOPE);
    end procedure;

    -- Checks an invalid call of a generate procedure: called right after start_test, it must not use time or touch
    -- the line. The TB_ERROR is expected by the caller.
    procedure check_rejected(
      constant msg : string) is
    begin
      check_value(now, v_start, ERROR, "no time used: " & msg, C_SCOPE, ID_SEQUENCER_SUB);
      settle;
      check_value(shared_edge_log.count, 0, ERROR, "line unchanged: " & msg, C_SCOPE, ID_SEQUENCER_SUB);
    end procedure;

    -- All periods with the active times 1 unit, T/4, T/2, T - 1 unit
    procedure test_period_set(
      constant msg : string) is
    begin
      for i in C_PERIODS'range loop
        test_generate(C_PERIODS(i), C_RESOLUTION, 3, msg & ", T=" & to_string(C_PERIODS(i)) & ", t_on=1 unit");
        test_generate(C_PERIODS(i), C_PERIODS(i) / 4, 3, msg & ", T=" & to_string(C_PERIODS(i)) & ", t_on=T/4");
        test_generate(C_PERIODS(i), C_PERIODS(i) / 2, 3, msg & ", T=" & to_string(C_PERIODS(i)) & ", t_on=T/2");
        test_generate(C_PERIODS(i), C_PERIODS(i) - C_RESOLUTION, 3, msg & ", T=" & to_string(C_PERIODS(i)) & ", t_on=T-1 unit");
      end loop;
    end procedure;

    -- The periods given back to back with pwm_drive_period(), no idle in between
    procedure test_drive_periods(
      constant params : t_period_param_array;
      constant msg    : string) is
    begin
      start_test;
      v_seed1 := v_config.jitter_seed1;
      v_seed2 := v_config.jitter_seed2;
      for i in params'range loop
        pwm_drive_period(params(i).period, params(i).active_time, v_seed1, v_seed2, v_aborted, msg, pwm, abort_drive, C_SCOPE, shared_msg_id_panel, v_config);
      end loop;
      pwm_drive_idle("", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(params, msg);
    end procedure;

    -- Generates num_periods periods with jitter and checks them against the ideal (unjittered) edges
    procedure test_jitter(
      constant period      : time;
      constant active_time : time;
      constant num_periods : positive;
      constant msg         : string) is
    begin
      start_test;
      pwm_generate(period, active_time, num_periods, msg, pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_value(now, v_start + num_periods * period, ERROR, "completion time: " & msg, C_SCOPE, ID_SEQUENCER_SUB);
      settle;
      check_jittered_edges(shared_edge_log, expected_edges(v_start, v_level, repeat_period(period, active_time, num_periods),
                                                    v_config.alignment, tb_active_level(v_config.polarity),
                                                    tb_idle_value(v_config.polarity, v_config.idle_level)),
                           v_config.jitter, msg, C_SCOPE);
    end procedure;

    -- The logged edges relative to v_start
    procedure save_edges(
      variable edges : out t_edge_array) is
      variable v_edge : t_edge;
    begin
      for i in 0 to minimum(shared_edge_log.count, edges'length) - 1 loop
        v_edge := shared_edge_log.get(i);
        edges(edges'low + i) := (v_edge.time_stamp - v_start, v_edge.level);
      end loop;
    end procedure;

    -- Jitter must not bias the waveform: the mean of the logged pulses (active-going edge 2i to edge 2i+1) is within
    -- active_time +- config.jitter/10 (plus one resolution unit). The bound is several standard deviations of the mean
    -- for the number of periods used here, and well below the j/4 of a one-sided clamp at the period start.
    procedure check_mean_active_time(
      constant active_time : time;
      constant num_periods : positive;
      constant msg         : string) is
      variable v_sum : time := 0 ns;
    begin
      for i in 0 to num_periods - 1 loop
        v_sum := v_sum + shared_edge_log.get(2 * i + 1).time_stamp - shared_edge_log.get(2 * i).time_stamp;
      end loop;
      log(ID_SEQUENCER, "Mean active time over " & to_string(num_periods) & " periods: " & to_string(v_sum / num_periods) &
                        ". '" & msg & "'", C_SCOPE);
      check_value_in_range(v_sum / num_periods, active_time - v_config.jitter / 10 - C_RESOLUTION,
                           active_time + v_config.jitter / 10 + C_RESOLUTION, ERROR, "mean active time: " & msg, C_SCOPE);
    end procedure;

    constant C_DUTY_SEQUENCE : t_period_param_array := ((10 ns, 5 ns), (10 ns, 0 ns), (10 ns, 5 ns), (10 ns, 10 ns), (10 ns, 5 ns));

    variable v_result : t_pwm_measurement;

    -- Observation tests: starts p_stimulus with the segments, then 'final_level'. The first segment starts now.
    procedure stimulate(
      constant segments    : t_segment_array;
      constant final_level : std_ulogic := '0') is
    begin
      stim_use_bfm                            <= false;
      stim_segments(0 to segments'length - 1) <= segments;
      stim_count                              <= segments'length;
      stim_final                              <= final_level;
      stim_start                              <= not stim_start;
      v_start                                 := now;
    end procedure;

    -- Observation tests: starts pwm_generate() in p_stimulus now
    procedure stimulate_bfm(
      constant period      : time;
      constant active_time : time;
      constant num_periods : positive;
      constant config      : t_pwm_bfm_config) is
    begin
      stim_use_bfm     <= true;
      stim_period      <= period;
      stim_active_time <= active_time;
      stim_num_periods <= num_periods;
      stim_config      <= config;
      stim_start       <= not stim_start;
      v_start          := now;
    end procedure;

    -- Lets the stimulus end
    procedure await_stimulus is
    begin
      settle;
      if stim_busy then
        wait until not stim_busy;
      end if;
    end procedure;

    -- Sets pwm_obs to a constant level and waits 10 ns
    procedure set_line(
      constant level : std_ulogic) is
    begin
      stimulate(seg(level, 0 ns), level);
      wait for 10 ns;
    end procedure;

    procedure check_measurement(
      constant period      : time;
      constant active_time : time;
      constant msg         : string) is
      constant C_DUTY : real := tb_units(active_time) / tb_units(period);
    begin
      check_value(v_result.is_constant, false, ERROR, "is_constant: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.period, period, ERROR, "period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.active_time, active_time, ERROR, "active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value_in_range(v_result.duty_cycle, C_DUTY - 1.0e-9, C_DUTY + 1.0e-9, ERROR, "duty_cycle: " & msg, C_SCOPE, ID_NEVER);
      -- One period: minimum and maximum equal the measured values
      check_value(v_result.min_period, v_result.period, ERROR, "min_period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_period, v_result.period, ERROR, "max_period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.min_active_time, v_result.active_time, ERROR, "min_active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_active_time, v_result.active_time, ERROR, "max_active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.min_duty_cycle, v_result.duty_cycle, ERROR, "min_duty_cycle: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_duty_cycle, v_result.duty_cycle, ERROR, "max_duty_cycle: " & msg, C_SCOPE, ID_NEVER);
    end procedure;

    procedure check_constant_result(
      constant level : std_ulogic;
      constant duty  : real;
      constant msg   : string) is
    begin
      check_value(v_result.is_constant, true, ERROR, "is_constant: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.constant_level, level, MATCH_EXACT, ERROR, "constant_level: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.duty_cycle, duty, ERROR, "duty_cycle: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.period, 0 ns, ERROR, "period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.active_time, 0 ns, ERROR, "active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.min_period, 0 ns, ERROR, "min_period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_period, 0 ns, ERROR, "max_period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.min_active_time, 0 ns, ERROR, "min_active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_active_time, 0 ns, ERROR, "max_active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.min_duty_cycle, duty, ERROR, "min_duty_cycle: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_duty_cycle, duty, ERROR, "max_duty_cycle: " & msg, C_SCOPE, ID_NEVER);
    end procedure;

    -- Minimum and maximum of a multi-period measurement; the duty extremes from the given active time / period pairs
    procedure check_spread(
      constant min_period      : time;
      constant max_period      : time;
      constant min_active_time : time;
      constant max_active_time : time;
      constant min_duty        : real;
      constant max_duty        : real;
      constant msg             : string) is
    begin
      check_value(v_result.min_period, min_period, ERROR, "min_period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_period, max_period, ERROR, "max_period: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.min_active_time, min_active_time, ERROR, "min_active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value(v_result.max_active_time, max_active_time, ERROR, "max_active_time: " & msg, C_SCOPE, ID_NEVER);
      check_value_in_range(v_result.min_duty_cycle, min_duty - 1.0e-9, min_duty + 1.0e-9, ERROR, "min_duty_cycle: " & msg, C_SCOPE, ID_NEVER);
      check_value_in_range(v_result.max_duty_cycle, max_duty - 1.0e-9, max_duty + 1.0e-9, ERROR, "max_duty_cycle: " & msg, C_SCOPE, ID_NEVER);
    end procedure;

    -- The observation call returned 'delay' after v_start
    procedure check_completion(
      constant delay : time;
      constant msg   : string) is
    begin
      check_value(now, v_start + delay, ERROR, "completion time: " & msg, C_SCOPE, ID_SEQUENCER_SUB);
    end procedure;

    -- Measures the output of pwm_generate() (3 periods) and checks the result and the completion time
    procedure test_measure_generated(
      constant period      : time;
      constant active_time : time;
      constant msg         : string) is
      constant C_OFF_TIME : time := period - active_time;
      variable v_first    : time; -- first active-going edge after v_start
    begin
      stimulate_bfm(period, active_time, 3, v_config);
      pwm_measure(v_result, msg, pwm_obs, terminate_loop, 1, 3 * period, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(period, active_time, msg);
      case v_config.alignment is
        when LEFT_ALIGNED   => v_first := 0 ns;
        when RIGHT_ALIGNED  => v_first := C_OFF_TIME;
        when CENTER_ALIGNED => v_first := C_OFF_TIME / 2; -- whole resolution units, rounded down
      end case;
      check_completion(v_first + period, msg);
      await_stimulus;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Verbosity control
    enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_POS_ACK);

    log(ID_LOG_HDR_LARGE, "Simulating " & GC_TESTCASE & ", resolution " & to_string(C_RESOLUTION), C_SCOPE);

    pwm_drive_idle("", pwm, C_SCOPE, shared_msg_id_panel, v_config);
    settle;

    --============================================================================================================================
    if GC_TESTCASE = "left_aligned_active_high_timing" then
      -- Left-aligned, active-high
      --============================================================================================================================
      log(ID_LOG_HDR, "Left-aligned, active-high, exact edge times", C_SCOPE);
      test_period_set("active-high");

      log(ID_LOG_HDR, "K=1 and k=5 periods, hard-coded edges", C_SCOPE);
      start_test;
      pwm_generate(10 ns, 3 ns, 1, "k=1", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((0 ns, 3 ns), "10", "k=1");
      start_test;
      pwm_generate(10 ns, 3 ns, 5, "k=5", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_value(now, v_start + 50 ns, ERROR, "k=5 completion time", C_SCOPE, ID_SEQUENCER_SUB);
      settle;
      check_edges_rel((0 ns, 3 ns, 10 ns, 13 ns, 20 ns, 23 ns, 30 ns, 33 ns, 40 ns, 43 ns), "1010101010", "k=5");

    --============================================================================================================================
    elsif GC_TESTCASE = "duty_formats_and_rounding" then
      -- Active time and the active times converted from a ratio and a counter value give the same waveform
      --============================================================================================================================
      log(ID_LOG_HDR, "T_on 25 ns, D 0.25 and 64/256 at T 100 ns", C_SCOPE);
      start_test;
      pwm_generate(100 ns, 25 ns, 2, "t_on", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((0 ns, 25 ns, 100 ns, 125 ns), "1010", "t_on 25 ns");
      start_test;
      pwm_generate(100 ns, pwm_duty_to_active_time(0.25, 100 ns), 2, "duty", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((0 ns, 25 ns, 100 ns, 125 ns), "1010", "D 0.25");
      start_test;
      pwm_generate(100 ns, pwm_count_to_active_time(64, 256, 100 ns), 2, "count", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((0 ns, 25 ns, 100 ns, 125 ns), "1010", "64/256");

      log(ID_LOG_HDR, "Rounding to the nearest resolution unit", C_SCOPE);
      -- Periods of a few resolution units give time stamps with more decimals than the log shows: UVVM warns once
      increment_expected_alerts(TB_WARNING, 1, "log time stamp truncated");
      start_test;
      pwm_generate(10 ns, pwm_duty_to_active_time(1.0 / 3.0, 10 ns), 2, "D 1/3", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(10 ns, rounded_units(10 ns, 1, 3), 2), "D 1/3 at T 10 ns");
      start_test;
      pwm_generate(10 ns, pwm_count_to_active_time(1, 3, 10 ns), 2, "1/3", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(10 ns, rounded_units(10 ns, 1, 3), 2), "count 1/3 at T 10 ns");
      start_test;
      pwm_generate(100 ns, pwm_duty_to_active_time(0.29, 100 ns), 2, "D 0.29", pwm, C_SCOPE, shared_msg_id_panel, v_config); -- 0.29 is not exact in binary
      check_generated(repeat_period(100 ns, 29 ns, 2), "D 0.29 at T 100 ns");
      start_test;
      pwm_generate(10 * C_RESOLUTION, pwm_count_to_active_time(1, 4, 10 * C_RESOLUTION), 2, "1/4 of 10 units", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(10 * C_RESOLUTION, 3 * C_RESOLUTION, 2), "count 1/4 of 10 units: 2.5 rounds up to 3");
      -- More than 2**31 resolution units in the period
      start_test;
      pwm_generate(4 ms, pwm_duty_to_active_time(1.0 / 3.0, 4 ms), 1, "D 1/3", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(4 ms, rounded_units(4 ms, 1, 3), 1), "D 1/3 at T 4 ms");
      start_test;
      pwm_generate(4 ms, pwm_count_to_active_time(1, 3, 4 ms), 1, "1/3", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(4 ms, rounded_units(4 ms, 1, 3), 1), "count 1/3 at T 4 ms");
      start_test;
      pwm_generate(4 ms, pwm_count_to_active_time(2, 3, 4 ms), 1, "2/3", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(4 ms, rounded_units(4 ms, 2, 3), 1), "count 2/3 at T 4 ms");
      start_test;
      pwm_generate(10 ns, pwm_count_to_active_time(0, 8, 10 ns), 2, "0/8", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(10 ns, 0 ns, 2), "count 0/8");
      start_test;
      pwm_generate(10 ns, pwm_count_to_active_time(8, 8, 10 ns), 2, "8/8", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(10 ns, 10 ns, 2), "count 8/8");
      start_test;
      pwm_generate(10 ns, pwm_duty_to_active_time(1.0, 10 ns), 2, "D 1.0", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_generated(repeat_period(10 ns, 10 ns, 2), "D 1.0");

    --============================================================================================================================
    elsif GC_TESTCASE = "invalid_generation_parameters" then
      -- Invalid generation parameters, one TB_ERROR each, line unchanged
      --============================================================================================================================
      log(ID_LOG_HDR, "Invalid generation parameters", C_SCOPE);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "period 0 ns");
      start_test;
      pwm_generate(0 ns, 0 ns, 1, "period 0 ns", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("period 0 ns");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "period < 0 ns");
      start_test;
      pwm_generate(-1 ns, 0 ns, 1, "period -1 ns", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("period -1 ns");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "t_on < 0 ns");
      start_test;
      pwm_generate(10 ns, -1 ns, 1, "t_on -1 ns", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("t_on -1 ns");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "t_on > T");
      start_test;
      pwm_generate(10 ns, 10 ns + C_RESOLUTION, 1, "t_on > T", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("t_on > T");

      -- Ratios and counter values outside their range give an active time outside 0 ns to period
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "D < 0");
      start_test;
      pwm_generate(10 ns, pwm_duty_to_active_time(-0.1, 10 ns), 1, "D -0.1", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("D -0.1");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "D > 1");
      start_test;
      pwm_generate(10 ns, pwm_duty_to_active_time(1.1, 10 ns), 1, "D 1.1", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("D 1.1");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "n > N");
      start_test;
      pwm_generate(10 ns, pwm_count_to_active_time(5, 4, 10 ns), 1, "n 5 of 4", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("n 5 of 4");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "k < 1");
      start_test;
      pwm_generate(10 ns, 5 ns, 0, "k 0", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("k 0");

      log(ID_LOG_HDR, "Invalid pwm_drive_period() parameters", C_SCOPE);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "pwm_drive_period() period 0 ns");
      start_test;
      pwm_drive_period(0 ns, 0 ns, v_seed1, v_seed2, v_aborted, "period 0 ns", pwm, abort_drive, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("pwm_drive_period() period 0 ns");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "pwm_drive_period() t_on > T");
      start_test;
      pwm_drive_period(10 ns, 10 ns + C_RESOLUTION, v_seed1, v_seed2, v_aborted, "t_on > T", pwm, abort_drive, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("pwm_drive_period() t_on > T");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "pwm_drive_period() jitter < 0 ns");
      v_config.jitter := -1 ns;
      start_test;
      pwm_drive_period(10 ns, 5 ns, v_seed1, v_seed2, v_aborted, "jitter -1 ns", pwm, abort_drive, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("pwm_drive_period() jitter -1 ns");
      v_config.jitter := 0 ns;

      log(ID_LOG_HDR, "A valid call afterwards still works", C_SCOPE);
      test_generate(10 ns, 5 ns, 2, "valid after invalid");

    --============================================================================================================================
    elsif GC_TESTCASE = "active_low_polarity" then
      -- Active-low
      --============================================================================================================================
      log(ID_LOG_HDR, "Active-low, idle level inverted", C_SCOPE);
      v_config.polarity := ACTIVE_LOW;
      pwm_drive_idle("", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_value(pwm, '1', MATCH_EXACT, ERROR, "active-low idle", C_SCOPE);
      test_period_set("active-low");
      start_test;
      pwm_generate(10 ns, 3 ns, 2, "hard-coded", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((0 ns, 3 ns, 10 ns, 13 ns), "0101", "active-low hard-coded");

    --============================================================================================================================
    elsif GC_TESTCASE = "right_and_center_alignment" then
      -- Right- and center-aligned
      --============================================================================================================================
      log(ID_LOG_HDR, "Right-aligned", C_SCOPE);
      v_config.alignment := RIGHT_ALIGNED;
      start_test;
      pwm_generate(10 ns, 3 ns, 2, "right", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((7 ns, 10 ns, 17 ns, 20 ns), "1010", "right-aligned T 10 ns, t_on 3 ns");
      test_period_set("right-aligned");

      log(ID_LOG_HDR, "Center-aligned", C_SCOPE);
      -- Periods of a few resolution units give time stamps with more decimals than the log shows: UVVM warns once
      increment_expected_alerts(TB_WARNING, 1, "log time stamp truncated");
      v_config.alignment := CENTER_ALIGNED;
      start_test;
      pwm_generate(10 ns, 4 ns, 1, "center", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((3 ns, 7 ns), "10", "center-aligned T 10 ns, t_on 4 ns");
      start_test;
      pwm_generate(10 * C_RESOLUTION, 3 * C_RESOLUTION, 1, "center odd", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      check_edges_rel((3 * C_RESOLUTION, 6 * C_RESOLUTION), "10", "center-aligned, odd t_off: extra unit in the second gap");
      start_test;
      pwm_generate(10 ns, 3 ns, 1, "center T 10 ns, t_on 3 ns", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      settle;
      if C_RESOLUTION <= 100 ps then
        check_edges_rel((3.5 ns, 6.5 ns), "10", "center-aligned T 10 ns, t_on 3 ns");
      end if;
      test_period_set("center-aligned");

      log(ID_LOG_HDR, "Right- and center-aligned, active-low", C_SCOPE);
      v_config.polarity  := ACTIVE_LOW;
      v_config.alignment := RIGHT_ALIGNED;
      pwm_drive_idle("", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      test_generate(10 ns, 3 ns, 3, "right-aligned active-low");
      v_config.alignment := CENTER_ALIGNED;
      test_generate(10 ns, 3 ns, 3, "center-aligned active-low");

    --============================================================================================================================
    elsif GC_TESTCASE = "constant_levels_without_glitches" then
      -- 0 % and 100 %, no glitches when switching
      --============================================================================================================================
      for alignment in t_pwm_alignment loop
        v_config.alignment := alignment;
        log(ID_LOG_HDR, "0 % and 100 % for 10 periods, " & to_string(alignment), C_SCOPE);
        start_test;
        pwm_generate(10 ns, 0 ns, 10, "0 %", pwm, C_SCOPE, shared_msg_id_panel, v_config);
        check_generated(repeat_period(10 ns, 0 ns, 10), "0 % " & to_string(alignment));
        check_value(shared_edge_log.count, 0, ERROR, "0 %: no edges", C_SCOPE);
        start_test;
        pwm_generate(10 ns, 10 ns, 10, "100 %", pwm, C_SCOPE, shared_msg_id_panel, v_config);
        check_generated(repeat_period(10 ns, 10 ns, 10), "100 % " & to_string(alignment));
        check_value(shared_edge_log.count, 2, ERROR, "100 %: only the edges from and to idle", C_SCOPE);

        log(ID_LOG_HDR, "50 % -> 0 % -> 50 % -> 100 % -> 50 % back to back, " & to_string(alignment), C_SCOPE);
        test_drive_periods(C_DUTY_SEQUENCE, "duty sequence " & to_string(alignment));
      end loop;

      log(ID_LOG_HDR, "Duty sequence, hard-coded edges", C_SCOPE);
      v_config.alignment := LEFT_ALIGNED;
      test_drive_periods(C_DUTY_SEQUENCE, "duty sequence left");
      check_edges_rel((0 ns, 5 ns, 20 ns, 25 ns, 30 ns, 45 ns), "101010", "duty sequence left, hard-coded");
      v_config.alignment := RIGHT_ALIGNED;
      test_drive_periods(C_DUTY_SEQUENCE, "duty sequence right");
      check_edges_rel((5 ns, 10 ns, 25 ns, 40 ns, 45 ns, 50 ns), "101010", "duty sequence right, hard-coded");

    --============================================================================================================================
    elsif GC_TESTCASE = "idle_level_options" then
      -- Idle level options (BFM part; initial and after-abort idle are tested on the VVC)
      --============================================================================================================================
      for polarity in t_pwm_polarity loop
        for idle_level in t_pwm_idle_level loop
          log(ID_LOG_HDR, "" & to_string(polarity) & ", " & to_string(idle_level), C_SCOPE);
          v_config.polarity   := polarity;
          v_config.idle_level := idle_level;
          pwm_drive_idle("", pwm, C_SCOPE, shared_msg_id_panel, v_config);
          settle;
          check_value(pwm, tb_idle_value(polarity, idle_level), MATCH_EXACT, ERROR, "pwm_drive_idle()", C_SCOPE);
          test_generate(10 ns, 3 ns, 2, "idle after generate, " & to_string(polarity) & ", " & to_string(idle_level));
        end loop;
      end loop;

    --============================================================================================================================
    elsif GC_TESTCASE = "jitter" then
      -- Bounded, non-accumulating, reproducible jitter
      --============================================================================================================================
      log(ID_LOG_HDR, "J = 5 ns, T = 100 ns, t_on = 50 ns, 1000 periods", C_SCOPE);
      v_config.jitter := 5 ns;
      test_jitter(100 ns, 50 ns, 1000, "j 5 ns");
      check_mean_active_time(50 ns, 1000, "j 5 ns");
      save_edges(v_edges_a);
      -- No drift: the mean period between the first and the last active-going edge. Each edge is within [0, j] of its
      -- ideal time, so the mean of 999 periods can differ from T by at most j/999 (plus rounding).
      v_first := v_edges_a(0).time_stamp;
      v_last  := v_edges_a(1998).time_stamp;
      log(ID_SEQUENCER, "Mean period over 999 periods: " & to_string((v_last - v_first) / 999), C_SCOPE);
      check_value_in_range((v_last - v_first) / 999, 100 ns - 5 ns / 999 - C_RESOLUTION,
                           100 ns + 5 ns / 999 + C_RESOLUTION, ERROR, "mean period (no drift)", C_SCOPE);
      -- The jitter is random: at least two different offsets
      v_differs := false;
      for i in 1 to 1999 loop
        v_differs := v_differs or (v_edges_a(i).time_stamp - v_edges_a(0).time_stamp /= (i / 2) * 100 ns + (i mod 2) * 50 ns);
      end loop;
      check_value(v_differs, ERROR, "at least two different edge offsets", C_SCOPE);

      log(ID_LOG_HDR, "The same seeds give the same waveform, other seeds a different one", C_SCOPE);
      test_jitter(100 ns, 50 ns, 1000, "j 5 ns, same seeds");
      save_edges(v_edges_b);
      check_value(v_edges_a = v_edges_b, ERROR, "same seeds: identical edges", C_SCOPE);
      v_config.jitter_seed1 := 12345;
      test_jitter(100 ns, 50 ns, 1000, "j 5 ns, other seeds");
      save_edges(v_edges_b);
      check_value(v_edges_a /= v_edges_b, ERROR, "other seeds: different edges", C_SCOPE);
      v_config.jitter_seed1 := C_PWM_BFM_CONFIG_DEFAULT.jitter_seed1;

      log(ID_LOG_HDR, "J = 30 ns with t_on = 50 ns: no pulse or gap below 1 unit, no missing pulse", C_SCOPE);
      v_config.jitter := 30 ns;
      test_jitter(100 ns, 50 ns, 1000, "j 30 ns");

      log(ID_LOG_HDR, "Jitter larger than the pulse and the gap", C_SCOPE);
      v_config.jitter := 5 ns;
      test_jitter(100 ns, C_RESOLUTION, 500, "j 5 ns, t_on 1 unit");
      test_jitter(100 ns, 100 ns - C_RESOLUTION, 500, "j 5 ns, t_on T - 1 unit");
      -- 501 periods of 10 units end at a time stamp with more decimals than the log shows (ps and fs resolution)
      increment_expected_alerts(TB_WARNING, 1, "log time stamp truncated");
      test_jitter(10 * C_RESOLUTION, 5 * C_RESOLUTION, 501, "j 5 ns, T 10 units");

      log(ID_LOG_HDR, "Right- and center-aligned, active-low", C_SCOPE);
      for alignment in RIGHT_ALIGNED to CENTER_ALIGNED loop
        v_config.alignment := alignment;
        test_jitter(100 ns, 30 ns, 500, "j 5 ns, " & to_string(alignment));
        check_mean_active_time(30 ns, 500, "j 5 ns, " & to_string(alignment));
      end loop;

      -- Center-aligned periods start without an edge (the line is already inactive). That period start is not jittered,
      -- so it does not delay the active-going edge. With a first gap of 1 unit, the active-going edge keeps its own offset
      -- distribution, uniform in [0, j] with mean j/2. A jittered period start would push it to the later of two offsets
      -- (mean 2j/3), which the bound j/2 +- j/10 rejects.
      log(ID_LOG_HDR, "Center-aligned, first gap 1 unit: the period start does not delay the active-going edge", C_SCOPE);
      test_jitter(100 ns, 100 ns - 2 * C_RESOLUTION, 500, "j 5 ns, center-aligned, first gap 1 unit");
      save_edges(v_edges_a);
      v_sum := 0 ns;
      for i in 0 to 499 loop
        -- Edge 2i is the active-going edge of period i, ideally at i * T + 1 unit
        v_sum := v_sum + v_edges_a(2 * i).time_stamp - (i * 100 ns + C_RESOLUTION);
      end loop;
      log(ID_SEQUENCER, "Mean offset of the active-going edges: " & to_string(v_sum / 500), C_SCOPE);
      check_value_in_range(v_sum / 500, 5 ns / 2 - 5 ns / 10, 5 ns / 2 + 5 ns / 10, ERROR,
                           "mean offset of the active-going edges", C_SCOPE);
      v_config.polarity := ACTIVE_LOW;
      pwm_drive_idle("", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      test_jitter(100 ns, 30 ns, 500, "j 5 ns, center-aligned, active-low");
      v_config := C_PWM_BFM_CONFIG_DEFAULT;
      pwm_drive_idle("", pwm, C_SCOPE, shared_msg_id_panel, v_config);

      log(ID_LOG_HDR, "0 % and 100 % are not affected by jitter", C_SCOPE);
      v_config.jitter := 5 ns;
      test_generate(100 ns, 0 ns, 10, "j 5 ns, 0 %");
      test_generate(100 ns, 100 ns, 10, "j 5 ns, 100 %");

      log(ID_LOG_HDR, "J = 0 ns gives exact edges", C_SCOPE);
      v_config.jitter := 0 ns;
      test_generate(100 ns, 50 ns, 10, "j 0 ns");

      log(ID_LOG_HDR, "J < 0 ns is rejected", C_SCOPE);
      v_config.jitter := -1 ns;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "jitter < 0 ns");
      start_test;
      pwm_generate(100 ns, 50 ns, 1, "j -1 ns", pwm, C_SCOPE, shared_msg_id_panel, v_config);
      check_rejected("j -1 ns");

    --============================================================================================================================
    elsif GC_TESTCASE = "measure_one_period" then
      -- Measure one complete period, starting at the next active-going edge
      --============================================================================================================================
      -- Periods of a few resolution units give time stamps with more decimals than the log shows: UVVM warns once
      increment_expected_alerts(TB_WARNING, 1, "log time stamp truncated");
      for alignment in t_pwm_alignment loop
        v_config.alignment := alignment;
        log(ID_LOG_HDR, "Measure the generator BFM output, " & to_string(alignment), C_SCOPE);
        for i in C_PERIODS'range loop
          test_measure_generated(C_PERIODS(i), C_RESOLUTION, "T=" & to_string(C_PERIODS(i)) & ", t_on=1 unit, " & to_string(alignment));
          test_measure_generated(C_PERIODS(i), C_PERIODS(i) / 4, "T=" & to_string(C_PERIODS(i)) & ", t_on=T/4, " & to_string(alignment));
          test_measure_generated(C_PERIODS(i), C_PERIODS(i) / 2, "T=" & to_string(C_PERIODS(i)) & ", t_on=T/2, " & to_string(alignment));
          test_measure_generated(C_PERIODS(i), C_PERIODS(i) - C_RESOLUTION, "T=" & to_string(C_PERIODS(i)) & ", t_on=T-1 unit, " &
                                 to_string(alignment));
        end loop;
      end loop;
      v_config.alignment := LEFT_ALIGNED;

      log(ID_LOG_HDR, "Request mid-pulse and mid-gap: the period in progress is ignored", C_SCOPE);
      -- Three different periods: 40/100, 30/100, 20/100
      stimulate(seg('1', 40 ns) & seg('0', 60 ns) & seg('1', 30 ns) & seg('0', 70 ns) & seg('1', 20 ns) & seg('0', 80 ns));
      wait for 10 ns;
      pwm_measure(v_result, "mid-pulse", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 30 ns, "request mid-pulse");
      check_completion(200 ns, "request mid-pulse");
      stimulate(seg('1', 40 ns) & seg('0', 60 ns) & seg('1', 30 ns) & seg('0', 70 ns) & seg('1', 20 ns) & seg('0', 80 ns));
      wait for 50 ns;
      pwm_measure(v_result, "mid-gap", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 30 ns, "request mid-gap");
      check_completion(200 ns, "request mid-gap");
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "measure_mean_of_periods" then
      -- Mean values over num_periods periods
      --============================================================================================================================
      log(ID_LOG_HDR, "Mean of 4 unequal periods: T 100/200/100/200 ns, t_on 20/60/20/60 ns", C_SCOPE);
      stimulate(pwm_wave(100 ns, 20 ns, 1) & pwm_wave(200 ns, 60 ns, 1) & pwm_wave(100 ns, 20 ns, 1) & pwm_wave(200 ns, 60 ns, 1) &
                seg('1', 20 ns));
      pwm_measure(v_result, "4 periods", pwm_obs, terminate_loop, 4, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_value(v_result.period, 150 ns, ERROR, "mean period", C_SCOPE);
      check_value(v_result.active_time, 40 ns, ERROR, "mean active time", C_SCOPE);
      -- The duty cycle of the sums: 160 ns / 600 ns
      check_value_in_range(v_result.duty_cycle, 160.0 / 600.0 - 1.0e-9, 160.0 / 600.0 + 1.0e-9, ERROR, "duty cycle of the sums", C_SCOPE);
      -- Single periods: 20/100 = 0.2 and 60/200 = 0.3
      check_spread(100 ns, 200 ns, 20 ns, 60 ns, 0.2, 0.3, "4 periods");
      check_completion(600 ns, "mean of 4 periods");
      await_stimulus;

      log(ID_LOG_HDR, "Mean T of 100 ns and 100 ns + 1 unit: rounded half up to 100 ns + 1 unit", C_SCOPE);
      -- An edge at 100 ns + 1 unit gives time stamps with more decimals than the log shows: UVVM warns once
      increment_expected_alerts(TB_WARNING, 1, "log time stamp truncated");
      stimulate(pwm_wave(100 ns, 25 ns, 1) & pwm_wave(100 ns + C_RESOLUTION, 25 ns, 1) & seg('1', 25 ns));
      pwm_measure(v_result, "2 periods", pwm_obs, terminate_loop, 2, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_value(v_result.period, 100 ns + C_RESOLUTION, ERROR, "mean period rounded half up", C_SCOPE);
      check_value(v_result.active_time, 25 ns, ERROR, "mean active time", C_SCOPE);
      -- The duty cycle comes from the sums: 50 ns / (200 ns + 1 unit)
      check_value_in_range(v_result.duty_cycle, tb_units(50 ns) / tb_units(200 ns + C_RESOLUTION) - 1.0e-9,
                           tb_units(50 ns) / tb_units(200 ns + C_RESOLUTION) + 1.0e-9, ERROR, "duty cycle of the sums", C_SCOPE);
      check_spread(100 ns, 100 ns + C_RESOLUTION, 25 ns, 25 ns, tb_units(25 ns) / tb_units(100 ns + C_RESOLUTION), 0.25, "2 periods");
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "measure_active_low" then
      -- Measurement respects the polarity
      --============================================================================================================================
      log(ID_LOG_HDR, "Active-low gives the same T and t_on as active-high", C_SCOPE);
      v_config.polarity := ACTIVE_LOW;
      set_line('1');
      for i in C_PERIODS'range loop
        test_measure_generated(C_PERIODS(i), C_PERIODS(i) / 4, "active-low, T=" & to_string(C_PERIODS(i)) & ", t_on=T/4");
      end loop;
      v_config.alignment := CENTER_ALIGNED;
      test_measure_generated(100 ns, 30 ns, "active-low, center-aligned");
      v_config.alignment := LEFT_ALIGNED;

      log(ID_LOG_HDR, "An active-low signal measured as active-high gives t_on = T - t_on", C_SCOPE);
      stimulate_bfm(100 ns, 30 ns, 3, v_config);
      v_config.polarity := ACTIVE_HIGH;
      pwm_measure(v_result, "active-low line, active-high config", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 70 ns, "active-low line, active-high config");
      check_completion(130 ns, "active-low line, active-high config");
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "constant_level_measure_and_expect" then
      -- Constant level (0 % / 100 %)
      --============================================================================================================================
      log(ID_LOG_HDR, "Pwm_measure() on a constant line reports the constant level, no alert", C_SCOPE);
      set_line('0');
      v_start := now;
      pwm_measure(v_result, "constant 0", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('0', 0.0, "constant 0");
      check_completion(500 ns, "constant 0");
      set_line('1');
      v_start := now;
      pwm_measure(v_result, "constant 1", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('1', 1.0, "constant 1");
      check_completion(500 ns, "constant 1");
      v_config.polarity := ACTIVE_LOW;
      set_line('0');
      pwm_measure(v_result, "constant 0, active-low", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('0', 1.0, "constant 0, active-low");
      v_config.polarity := ACTIVE_HIGH;
      -- A falling edge before the call, then constant: no edge during the measurement
      stimulate(seg('1', 50 ns), '0');
      wait for 60 ns;
      v_start := now;
      pwm_measure(v_result, "1 then constant 0", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('0', 0.0, "1 then constant 0");
      check_completion(500 ns, "1 then constant 0");
      -- A falling edge during the measurement, then constant: not constant, but no period began
      set_line('1');
      stimulate(seg('1', 50 ns), '0');
      -- Missing activity at WARNING, so that it cannot be confused with a failing check of the result
      v_config.timeout_severity := WARNING;
      increment_expected_alerts(WARNING, 1, "falling edge during the measurement");
      v_start := now;
      pwm_measure(v_result, "falling edge, then constant 0", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_value(v_result = C_PWM_MEASUREMENT_DEFAULT, ERROR, "default result: falling edge, then constant 0", C_SCOPE);
      check_completion(500 ns, "falling edge, then constant 0");
      v_config.timeout_severity := ERROR;

      log(ID_LOG_HDR, "Config.constant_level_severity ERROR: the constant result also raises an ERROR", C_SCOPE);
      set_line('0');
      v_config.constant_level_severity := ERROR;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "constant 0, constant_level_severity ERROR");
      pwm_measure(v_result, "constant 0, severity ERROR", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('0', 0.0, "constant 0, severity ERROR");
      v_config.constant_level_severity := NO_ALERT;

      log(ID_LOG_HDR, "Constant 'Z' is a result if idle_level is IDLE_HIGH_Z, else an ERROR", C_SCOPE);
      set_line('Z');
      v_config.idle_level := IDLE_HIGH_Z;
      pwm_measure(v_result, "constant Z, IDLE_HIGH_Z", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('Z', 0.0, "constant Z, IDLE_HIGH_Z");
      v_config.idle_level := IDLE_INACTIVE;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "constant Z, IDLE_INACTIVE");
      pwm_measure(v_result, "constant Z, IDLE_INACTIVE", pwm_obs, terminate_loop, 1, 500 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('Z', 0.0, "constant Z, IDLE_INACTIVE");

      log(ID_LOG_HDR, "Pwm_check() with active_time: window num_periods * period, the timeout is not used", C_SCOPE);
      set_line('0');
      v_start := now;
      pwm_expect(100 ns, 0 ns, "0 % on 0", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(100 ns, "0 % on 0, 1 period");
      v_start := now;
      pwm_expect(100 ns, 0 ns, "0 % on 0, 3 periods", pwm_obs, terminate_loop, 3, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "0 % on 0, 3 periods");
      log(ID_LOG_HDR, "Pwm_check() with duty: window = timeout", C_SCOPE);
      v_start := now;
      pwm_expect(0.0, "D 0.0 on 0", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(500 ns, "D 0.0 on 0");
      set_line('1');
      pwm_expect(100 ns, 100 ns, "100 % on 1", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      pwm_expect(1.0, "D 1.0 on 1", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.polarity := ACTIVE_LOW;
      pwm_expect(100 ns, 0 ns, "0 % on 1, active-low", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.polarity := ACTIVE_HIGH;

      log(ID_LOG_HDR, "Wrong level and an edge inside the window raise one alert each", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "0 % on 1");
      v_start := now;
      pwm_expect(100 ns, 0 ns, "0 % on 1", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(0 ns, "0 % on 1: returns at once");
      increment_expected_alerts_and_stop_limit(ERROR, 1, "D 0.0 on 1");
      pwm_expect(0.0, "D 0.0 on 1", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts(WARNING, 1, "0 % on 1, alert_level WARNING");
      pwm_expect(100 ns, 0 ns, "0 % on 1", pwm_obs, terminate_loop, 1, 500 ns, WARNING, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "edge inside the window");
      stimulate(seg('0', 100 ns), '1');
      settle; -- the line is '1' before the stimulus
      pwm_expect(100 ns, 0 ns, "0 %, edge after 100 ns", pwm_obs, terminate_loop, 3, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(100 ns, "0 %, edge after 100 ns");
      increment_expected_alerts_and_stop_limit(ERROR, 1, "edge in the last of 5 periods");
      stimulate(seg('0', 450 ns), '1');
      settle;
      pwm_expect(100 ns, 0 ns, "0 % for 5 periods, edge after 450 ns", pwm_obs, terminate_loop, 5, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(450 ns, "0 % for 5 periods, edge after 450 ns");
      increment_expected_alerts_and_stop_limit(ERROR, 1, "edge inside the window, D 1.0");
      stimulate(seg('1', 100 ns), '0');
      pwm_expect(1.0, "D 1.0, edge after 100 ns", pwm_obs, terminate_loop, 1, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(100 ns, "D 1.0, edge after 100 ns");

    --============================================================================================================================
    elsif GC_TESTCASE = "expect_period_and_active_time_tolerances" then
      -- Check T and t_on with inclusive tolerances
      --============================================================================================================================
      log(ID_LOG_HDR, "Correct signal, no alert", C_SCOPE);
      stimulate(pwm_wave(100 ns, 25 ns, 3) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "exact", pwm_obs, terminate_loop, 3, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "exact, k=3");
      await_stimulus;

      log(ID_LOG_HDR, "num_periods defaults to one period", C_SCOPE);
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "exact, default num_periods", pwm_obs, terminate_loop, config => v_config);
      check_completion(100 ns, "default num_periods = 1");
      await_stimulus;

      log(ID_LOG_HDR, "Counter value converted to t_on", C_SCOPE);
      stimulate(pwm_wave(100 ns, 25 ns, 3) & seg('1', 25 ns));
      pwm_expect(100 ns, pwm_count_to_active_time(1, 4, 100 ns), "count 1/4", pwm_obs, terminate_loop, 3, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "count 1/4, k=3");
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "count 3/10 on t_on 25 ns");
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, pwm_count_to_active_time(3, 10, 100 ns), "count 3/10", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(100 ns, "count 3/10");
      await_stimulus;

      log(ID_LOG_HDR, "T off by more than the tolerance", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "T 101 ns, tolerance 0 ns");
      stimulate(pwm_wave(101 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "T 101 ns, tolerance 0 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(101 ns, "T 101 ns");
      await_stimulus;
      increment_expected_alerts(WARNING, 1, "T 101 ns, alert_level WARNING");
      stimulate(pwm_wave(101 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "T 101 ns, WARNING", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, WARNING, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

      log(ID_LOG_HDR, "Period tolerance 1 ns: +-1 ns passes, +-(1 ns + 1 unit) fails", C_SCOPE);
      -- Edges 1 resolution unit off give time stamps with more decimals than the log shows: UVVM warns once
      increment_expected_alerts(TB_WARNING, 1, "log time stamp truncated");
      v_config.period_tolerance := 1 ns;
      stimulate(pwm_wave(101 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "T 101 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      stimulate(pwm_wave(99 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "T 99 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "T 101 ns + 1 unit");
      stimulate(pwm_wave(101 ns + C_RESOLUTION, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "T 101 ns + 1 unit", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "T 99 ns - 1 unit");
      stimulate(pwm_wave(99 ns - C_RESOLUTION, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "T 99 ns - 1 unit", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      v_config.period_tolerance := 0 ns;

      log(ID_LOG_HDR, "Active time tolerance 1 ns: +-1 ns passes, +-(1 ns + 1 unit) fails", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "t_on 26 ns, tolerance 0 ns");
      stimulate(pwm_wave(100 ns, 26 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "t_on 26 ns, tolerance 0 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      v_config.active_time_tolerance := 1 ns;
      stimulate(pwm_wave(100 ns, 26 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "t_on 26 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      stimulate(pwm_wave(100 ns, 24 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "t_on 24 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "t_on 26 ns + 1 unit");
      stimulate(pwm_wave(100 ns, 26 ns + C_RESOLUTION, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "t_on 26 ns + 1 unit", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "t_on 24 ns - 1 unit");
      stimulate(pwm_wave(100 ns, 24 ns - C_RESOLUTION, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "t_on 24 ns - 1 unit", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      v_config.active_time_tolerance := 0 ns;

      log(ID_LOG_HDR, "T and t_on wrong in the same period: one alert", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "T and t_on wrong");
      stimulate(pwm_wave(110 ns, 30 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "T 110 ns, t_on 30 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "expect_multiple_periods" then
      -- K consecutive periods, one alert per failing period
      --============================================================================================================================
      log(ID_LOG_HDR, "K=5, all correct", C_SCOPE);
      stimulate(pwm_wave(100 ns, 25 ns, 5) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "k=5 correct", pwm_obs, terminate_loop, 5, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(500 ns, "k=5 correct");
      await_stimulus;

      log(ID_LOG_HDR, "K=5, T of period 3 wrong: one alert naming period 3/5", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "period 3/5");
      stimulate(pwm_wave(100 ns, 25 ns, 2) & pwm_wave(110 ns, 25 ns, 1) & pwm_wave(100 ns, 25 ns, 2) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "k=5, period 3 wrong", pwm_obs, terminate_loop, 5, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(510 ns, "k=5, period 3 wrong");
      await_stimulus;

      log(ID_LOG_HDR, "K=5, t_on of periods 2 and 5 wrong: two alerts", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 2, "periods 2/5 and 5/5");
      stimulate(pwm_wave(100 ns, 25 ns, 1) & pwm_wave(100 ns, 30 ns, 1) & pwm_wave(100 ns, 25 ns, 2) & pwm_wave(100 ns, 20 ns, 1) &
                seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "k=5, periods 2 and 5 wrong", pwm_obs, terminate_loop, 5, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "invalid_levels_during_observation" then
      -- Invalid levels during a measurement
      --============================================================================================================================
      log(ID_LOG_HDR, "1 ns of X, U, Z, W, - inside the pulse: one ERROR each, timing unaffected", C_SCOPE);
      for value in std_ulogic loop
        -- 'L' and 'H' are valid levels: see weak_levels_during_observation
        if value /= '0' and value /= '1' and value /= 'L' and value /= 'H' then
          increment_expected_alerts_and_stop_limit(ERROR, 1, "'" & to_string(value) & "' inside the pulse");
          stimulate(seg('1', 10 ns) & seg(value, 1 ns) & seg('1', 14 ns) & seg('0', 75 ns) & seg('1', 25 ns));
          pwm_measure(v_result, "'" & to_string(value) & "' inside the pulse", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
          check_measurement(100 ns, 25 ns, "'" & to_string(value) & "' inside the pulse");
          await_stimulus;
        end if;
      end loop;

      log(ID_LOG_HDR, "X inside the gap, and inside a pwm_expect() at alert_level WARNING", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "X inside the gap");
      stimulate(seg('1', 25 ns) & seg('0', 30 ns) & seg('X', 1 ns) & seg('0', 44 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "X inside the gap", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 25 ns, "X inside the gap");
      await_stimulus;
      increment_expected_alerts(WARNING, 1, "X inside period 2 of a check");
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 10 ns) & seg('X', 1 ns) & seg('1', 14 ns) & seg('0', 75 ns) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "X in period 2", pwm_obs, terminate_loop, 2, C_UNDEFINED_TIME, WARNING, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

      log(ID_LOG_HDR, "Before the first active-going edge, 'Z' is legal only with IDLE_HIGH_Z", C_SCOPE);
      v_config.idle_level := IDLE_HIGH_Z;
      set_line('Z');
      stimulate(seg('0', 10 ns) & seg('Z', 10 ns) & pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns), 'Z');
      pwm_measure(v_result, "Z before the period, IDLE_HIGH_Z", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 25 ns, "Z before the period, IDLE_HIGH_Z");
      await_stimulus;
      v_config.idle_level := IDLE_INACTIVE;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "Z before the period, IDLE_INACTIVE");
      stimulate(seg('0', 10 ns) & seg('Z', 10 ns) & pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_measure(v_result, "Z before the period, IDLE_INACTIVE", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 25 ns, "Z before the period, IDLE_INACTIVE");
      await_stimulus;
      log(ID_LOG_HDR, "'Z' inside the period is an ERROR also with IDLE_HIGH_Z", C_SCOPE);
      v_config.idle_level := IDLE_HIGH_Z;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "Z inside the pulse, IDLE_HIGH_Z");
      stimulate(seg('1', 10 ns) & seg('Z', 1 ns) & seg('1', 14 ns) & seg('0', 75 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "Z inside the pulse, IDLE_HIGH_Z", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 25 ns, "Z inside the pulse, IDLE_HIGH_Z");
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "weak_levels_during_observation" then
      -- The weak levels 'L' and 'H' are read as '0' and '1', e.g. on a line with a pull resistor
      --============================================================================================================================
      log(ID_LOG_HDR, "A period of 'L' and 'H' only", C_SCOPE);
      set_line('0');
      stimulate(seg('L', 10 ns) & seg('H', 25 ns) & seg('L', 75 ns) & seg('H', 25 ns), 'L');
      pwm_measure(v_result, "L/H period", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 25 ns, "L/H period");
      await_stimulus;

      log(ID_LOG_HDR, "Changes between '1' and 'H' or '0' and 'L' are no edges and raise no alert", C_SCOPE);
      set_line('0');
      stimulate(seg('0', 10 ns) & seg('1', 10 ns) & seg('H', 15 ns) & seg('L', 40 ns) & seg('0', 35 ns) &
                seg('H', 25 ns) & seg('L', 75 ns) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "strong and weak levels mixed", pwm_obs, terminate_loop, 2, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

      log(ID_LOG_HDR, "A constant 'H' or 'L' is the constant level '1' or '0'", C_SCOPE);
      set_line('H');
      pwm_measure(v_result, "constant H", pwm_obs, terminate_loop, 1, 200 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('1', 1.0, "constant H");
      set_line('L');
      pwm_measure(v_result, "constant L", pwm_obs, terminate_loop, 1, 200 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_constant_result('0', 0.0, "constant L");

      log(ID_LOG_HDR, "Constant-level checks: '0'/'L' and '1'/'H' are the same level", C_SCOPE);
      set_line('0');
      stimulate(seg('0', 50 ns) & seg('L', 50 ns) & seg('0', 50 ns) & seg('L', 50 ns), 'L');
      pwm_expect(100 ns, 0 ns, "0 % on 0/L", pwm_obs, terminate_loop, 2, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      set_line('1');
      stimulate(seg('1', 50 ns) & seg('H', 50 ns) & seg('1', 50 ns), 'H');
      pwm_expect(1.0, "100 % on 1/H", pwm_obs, terminate_loop, 1, 200 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

      log(ID_LOG_HDR, "'W' is no weak level of '0' or '1': an ERROR", C_SCOPE);
      set_line('0');
      increment_expected_alerts_and_stop_limit(ERROR, 1, "W during a 0 % check");
      stimulate(seg('0', 50 ns) & seg('W', 50 ns), '0');
      pwm_expect(100 ns, 0 ns, "W during a 0 % check", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "runt_pulses_and_gaps" then
      -- Runt pulses and gaps
      --============================================================================================================================
      log(ID_LOG_HDR, "Min_pulse_width 2 ns: 1 ns gap and 1 ns pulse raise one ERROR each, 2 ns none", C_SCOPE);
      v_config.min_pulse_width := 2 ns;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "1 ns gap");
      stimulate(seg('1', 10 ns) & seg('0', 1 ns) & seg('1', 14 ns) & seg('0', 75 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "1 ns gap", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(11 ns, 10 ns, "1 ns gap");
      await_stimulus;
      stimulate(seg('1', 10 ns) & seg('0', 2 ns) & seg('1', 14 ns) & seg('0', 75 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "2 ns gap", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(12 ns, 10 ns, "2 ns gap");
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "1 ns pulse");
      stimulate(seg('1', 1 ns) & seg('0', 99 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "1 ns pulse", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 1 ns, "1 ns pulse");
      await_stimulus;
      stimulate(seg('1', 2 ns) & seg('0', 98 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "2 ns pulse", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 2 ns, "2 ns pulse");
      await_stimulus;

      log(ID_LOG_HDR, "Runt in a pwm_expect() at alert_level WARNING (the timing mismatch is a second WARNING)", C_SCOPE);
      increment_expected_alerts(WARNING, 2, "1 ns pulse in a check");
      stimulate(seg('1', 1 ns) & seg('0', 99 ns) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "1 ns pulse", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, WARNING, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

      log(ID_LOG_HDR, "Min_pulse_width 0 ns: detection off", C_SCOPE);
      v_config.min_pulse_width := 0 ns;
      stimulate(seg('1', 10 ns) & seg('0', 1 ns) & seg('1', 14 ns) & seg('0', 75 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "1 ns gap, detection off", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(11 ns, 10 ns, "1 ns gap, detection off");
      await_stimulus;

      log(ID_LOG_HDR, "Zero-width glitch (pulse and gap in delta cycles): a period of 0 ns with duty cycle 0.0", C_SCOPE);
      -- Period 1: 0 ns (glitch), period 2: 100 ns with 30 ns active
      stimulate(seg('1', 0 ns) & seg('0', 0 ns) & seg('1', 30 ns) & seg('0', 70 ns) & seg('1', 25 ns));
      pwm_measure(v_result, "zero-width glitch", pwm_obs, terminate_loop, 2, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      check_value(v_result.min_period, 0 ns, ERROR, "min_period: zero-width glitch", C_SCOPE);
      check_value(v_result.min_active_time, 0 ns, ERROR, "min_active_time: zero-width glitch", C_SCOPE);
      check_value(v_result.min_duty_cycle, 0.0, ERROR, "min_duty_cycle: zero-width glitch", C_SCOPE);
      check_value(v_result.period, 50 ns, ERROR, "mean period: zero-width glitch", C_SCOPE);
      check_value_in_range(v_result.duty_cycle, 0.3 - 1.0e-9, 0.3 + 1.0e-9, ERROR, "duty cycle from the sums: zero-width glitch", C_SCOPE);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "zero-width glitch in a duty check");
      stimulate(seg('1', 0 ns) & seg('0', 0 ns) & seg('1', 30 ns) & seg('0', 70 ns) & seg('1', 25 ns));
      pwm_expect(0.3, "zero-width glitch", pwm_obs, terminate_loop, 2, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "zero-width glitch in a period check");
      stimulate(seg('1', 0 ns) & seg('0', 0 ns) & seg('1', 30 ns) & seg('0', 70 ns) & seg('1', 25 ns));
      pwm_expect(100 ns, 30 ns, "zero-width glitch", pwm_obs, terminate_loop, 2, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "missing_activity" then
      -- Missing activity
      --============================================================================================================================
      log(ID_LOG_HDR, "Line stuck after period 1 of 3: one ERROR at the timeout", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "stuck after period 1");
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "stuck after period 1", pwm_obs, terminate_loop, 3, 400 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(400 ns, "stuck after period 1");

      log(ID_LOG_HDR, "Line stuck from the request: missing activity, not 0 % / 100 %", C_SCOPE);
      set_line('0');
      increment_expected_alerts_and_stop_limit(ERROR, 1, "stuck at 0");
      v_start := now;
      pwm_expect(100 ns, 25 ns, "stuck at 0", pwm_obs, terminate_loop, 1, 300 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "stuck at 0");
      increment_expected_alerts_and_stop_limit(ERROR, 1, "stuck at 0, default timeout (1 + 2) * T");
      v_start := now;
      pwm_expect(100 ns, 25 ns, "stuck at 0, default timeout", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "stuck at 0, default timeout (1 + 2) * T");
      increment_expected_alerts_and_stop_limit(ERROR, 1, "stuck at 0, pwm_expect() with duty");
      v_start := now;
      pwm_expect(0.25, "stuck at 0", pwm_obs, terminate_loop, 1, 300 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "stuck at 0, pwm_expect() with duty");
      set_line('1');
      increment_expected_alerts_and_stop_limit(ERROR, 1, "stuck at 1");
      v_start := now;
      pwm_expect(100 ns, 25 ns, "stuck at 1", pwm_obs, terminate_loop, 1, 300 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "stuck at 1");

      log(ID_LOG_HDR, "Timeout_severity WARNING", C_SCOPE);
      v_config.timeout_severity := WARNING;
      increment_expected_alerts(WARNING, 1, "stuck at 1, timeout_severity WARNING");
      pwm_expect(100 ns, 25 ns, "stuck at 1", pwm_obs, terminate_loop, 1, 300 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.timeout_severity := ERROR;

      log(ID_LOG_HDR, "Pwm_measure() with the line stuck after the active-going edge", C_SCOPE);
      set_line('0');
      increment_expected_alerts_and_stop_limit(ERROR, 1, "measure, stuck active");
      stimulate(seg('1', 0 ns), '1');
      pwm_measure(v_result, "stuck active", pwm_obs, terminate_loop, 1, 200 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(200 ns, "measure, stuck active");
      check_value(v_result = C_PWM_MEASUREMENT_DEFAULT, ERROR, "measure, stuck active: default result", C_SCOPE);

      log(ID_LOG_HDR, "Pwm_measure() of 3 periods, the line stops after period 1", C_SCOPE);
      set_line('0');
      increment_expected_alerts_and_stop_limit(ERROR, 1, "measure 3 periods, stuck after period 1");
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_measure(v_result, "3 periods, stuck after period 1", pwm_obs, terminate_loop, 3, 400 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(400 ns, "measure 3 periods, stuck after period 1");
      check_value(v_result = C_PWM_MEASUREMENT_DEFAULT, ERROR, "measure 3 periods, stuck: default result", C_SCOPE);

      log(ID_LOG_HDR, "The next call runs normally", C_SCOPE);
      set_line('0');
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "after missing activity", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "invalid_observation_parameters" then
      -- Invalid observation parameters, one TB_ERROR each, no time used
      --============================================================================================================================
      log(ID_LOG_HDR, "Invalid observation parameters", C_SCOPE);
      v_start := now;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "measure, num_periods 0");
      pwm_measure(v_result, "num_periods 0", pwm_obs, terminate_loop, 0, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "measure, timeout < 0 ns");
      pwm_measure(v_result, "timeout -2 ns", pwm_obs, terminate_loop, 1, -2 ns, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "measure without timeout");
      pwm_measure(v_result, "no timeout", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.min_pulse_width := -1 ns;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "measure, min_pulse_width < 0 ns");
      pwm_measure(v_result, "min_pulse_width -1 ns", pwm_obs, terminate_loop, 1, 1 us, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.min_pulse_width := 0 ns;

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, T 0 ns");
      pwm_expect(0 ns, 0 ns, "T 0 ns", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, T < 0 ns");
      pwm_expect(-1 ns, 0 ns, "T -1 ns", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, t_on < 0 ns");
      pwm_expect(100 ns, -1 ns, "t_on -1 ns", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, t_on > T");
      pwm_expect(100 ns, 100 ns + C_RESOLUTION, "t_on > T", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, k 0");
      pwm_expect(100 ns, 25 ns, "k 0", pwm_obs, terminate_loop, 0, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, count > resolution");
      pwm_expect(100 ns, pwm_count_to_active_time(5, 4, 100 ns), "count 5 of 4", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, timeout < 0 ns");
      pwm_expect(100 ns, 25 ns, "timeout -2 ns", pwm_obs, terminate_loop, 1, -2 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.period_tolerance := -1 ns;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, period_tolerance < 0 ns");
      pwm_expect(100 ns, 25 ns, "period_tolerance -1 ns", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.period_tolerance := 0 ns;
      v_config.active_time_tolerance := -1 ns;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect, active_time_tolerance < 0 ns");
      pwm_expect(100 ns, 25 ns, "active_time_tolerance -1 ns", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.active_time_tolerance := 0 ns;

      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty, D < 0");
      pwm_expect(-0.1, "D -0.1", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty, D > 1");
      pwm_expect(1.1, "D 1.1", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty, k 0");
      pwm_expect(0.5, "k 0", pwm_obs, terminate_loop, 0, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty without timeout");
      pwm_expect(0.25, "D 0.25, no timeout", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty 0.0 without timeout");
      pwm_expect(0.0, "D 0.0, no timeout", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty 1.0, timeout 0 ns");
      pwm_expect(1.0, "D 1.0, timeout 0 ns", pwm_obs, terminate_loop, 1, 0 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.duty_tolerance := -0.1;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty, duty_tolerance < 0");
      pwm_expect(0.5, "duty_tolerance -0.1", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.duty_tolerance := 1.1;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "expect_duty, duty_tolerance > 1");
      pwm_expect(0.5, "duty_tolerance 1.1", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.duty_tolerance := 0.0;
      check_completion(0 ns, "rejected calls use no time");

      log(ID_LOG_HDR, "A valid call afterwards still works", C_SCOPE);
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "valid after invalid", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "duty_expect" then
      -- Duty cycle check, independent of the period
      --============================================================================================================================
      log(ID_LOG_HDR, "D = 0.25 +-0.01", C_SCOPE);
      v_config.duty_tolerance := 0.01;
      stimulate(pwm_wave(100 ns, 25 ns, 3) & seg('1', 25 ns));
      pwm_expect(0.25, "25/100 ns", pwm_obs, terminate_loop, 3, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(300 ns, "25/100 ns, k=3");
      await_stimulus;
      stimulate(pwm_wave(1 us, 250 ns, 3) & seg('1', 25 ns));
      pwm_expect(0.25, "250 ns/1 us", pwm_obs, terminate_loop, 3, 5 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      stimulate(pwm_wave(100 ns, 26 ns, 1) & seg('1', 25 ns));
      pwm_expect(0.25, "26/100 ns: deviation equal to the tolerance", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      stimulate(pwm_wave(100 ns, 24 ns, 1) & seg('1', 25 ns));
      pwm_expect(0.25, "24/100 ns: deviation equal to the tolerance", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "27/100 ns");
      stimulate(pwm_wave(100 ns, 27 ns, 1) & seg('1', 25 ns));
      pwm_expect(0.25, "27/100 ns", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "24 ns - 1 unit");
      stimulate(pwm_wave(100 ns, 24 ns - C_RESOLUTION, 1) & seg('1', 25 ns));
      pwm_expect(0.25, "24 ns - 1 unit", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      increment_expected_alerts(WARNING, 1, "27/100 ns in period 2/3, WARNING");
      stimulate(pwm_wave(100 ns, 25 ns, 1) & pwm_wave(100 ns, 27 ns, 1) & pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(0.25, "period 2 wrong", pwm_obs, terminate_loop, 3, 1 us, WARNING, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

      log(ID_LOG_HDR, "Tolerance 0.0: exact duty passes", C_SCOPE);
      v_config.duty_tolerance := 0.0;
      stimulate(pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(0.25, "exact", pwm_obs, terminate_loop, 1, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

      log(ID_LOG_HDR, "Active-low", C_SCOPE);
      v_config.polarity := ACTIVE_LOW;
      set_line('1');
      stimulate(pwm_wave(100 ns, 25 ns, 2, '0') & seg('0', 25 ns), '1');
      pwm_expect(0.25, "active-low", pwm_obs, terminate_loop, 2, 1 us, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;

    --============================================================================================================================
    elsif GC_TESTCASE = "timeout_and_terminate" then
      -- The timeout is the maximum time of the whole observation: per call, config.timeout, derived default, 0 ns
      --============================================================================================================================
      log(ID_LOG_HDR, "Config.timeout 150 ns is too short for 2 periods; the per-call 400 ns overrides it", C_SCOPE);
      v_config.timeout := 150 ns;
      increment_expected_alerts_and_stop_limit(ERROR, 1, "config.timeout 150 ns");
      stimulate(pwm_wave(100 ns, 25 ns, 2) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "config.timeout 150 ns", pwm_obs, terminate_loop, 2, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(150 ns, "config.timeout 150 ns: ends at the timeout");
      await_stimulus;
      stimulate(pwm_wave(100 ns, 25 ns, 2) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "per-call 400 ns", pwm_obs, terminate_loop, 2, 400 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      v_config.timeout := 400 ns;
      stimulate(pwm_wave(100 ns, 25 ns, 2) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "config.timeout 400 ns", pwm_obs, terminate_loop, 2, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      v_config.timeout := C_UNDEFINED_TIME;

      log(ID_LOG_HDR, "The timeout covers the whole check: k=10, T=100 ns, timeout 500 ns", C_SCOPE);
      increment_expected_alerts_and_stop_limit(ERROR, 1, "k=10 within 500 ns");
      stimulate(pwm_wave(100 ns, 25 ns, 10) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "k=10, timeout 500 ns", pwm_obs, terminate_loop, 10, 500 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(500 ns, "k=10, timeout 500 ns");
      await_stimulus;

      log(ID_LOG_HDR, "Derived default (k + 2) * (T + period_tolerance): k=100 passes", C_SCOPE);
      stimulate(pwm_wave(1 us, 250 ns, 100) & seg('1', 250 ns));
      pwm_expect(1 us, 250 ns, "k=100, derived timeout", pwm_obs, terminate_loop, 100, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(100 us, "k=100, derived timeout");
      await_stimulus;
      -- 50 periods of 105 ns take 5250 ns: more than (50 + 2) * 100 ns, within (50 + 2) * (100 ns + 5 ns)
      v_config.period_tolerance := 5 ns;
      stimulate(pwm_wave(105 ns, 25 ns, 50) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "k=50 of 105 ns, tolerance 5 ns", pwm_obs, terminate_loop, 50, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      await_stimulus;
      set_line('0');
      increment_expected_alerts_and_stop_limit(ERROR, 1, "stuck, derived timeout with tolerance");
      v_start := now;
      pwm_expect(100 ns, 25 ns, "stuck, derived timeout", pwm_obs, terminate_loop, 3, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion((3 + 2) * 105 ns, "stuck, derived timeout (3 + 2) * (100 ns + 5 ns)");
      v_config.period_tolerance := 0 ns;

      log(ID_LOG_HDR, "With timeout 0 ns pwm_measure() and pwm_expect() wait without limit (10 us of constant level first)", C_SCOPE);
      stimulate(seg('0', 10 us) & pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_measure(v_result, "timeout 0 ns", pwm_obs, terminate_loop, 1, 0 ns, C_SCOPE, shared_msg_id_panel, v_config);
      check_measurement(100 ns, 25 ns, "timeout 0 ns");
      check_completion(10.1 us, "timeout 0 ns");
      await_stimulus;
      stimulate(seg('0', 10 us) & pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(0.25, "duty, timeout 0 ns", pwm_obs, terminate_loop, 1, 0 ns, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(10.1 us, "duty, timeout 0 ns");
      await_stimulus;
      v_config.timeout := 0 ns;
      stimulate(seg('0', 10 us) & pwm_wave(100 ns, 25 ns, 1) & seg('1', 25 ns));
      pwm_expect(100 ns, 25 ns, "config.timeout 0 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      check_completion(10.1 us, "config.timeout 0 ns");
      await_stimulus;
      v_config.timeout := C_UNDEFINED_TIME;

      log(ID_LOG_HDR, "Negative timeout", C_SCOPE);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "timeout -5 ns");
      pwm_measure(v_result, "timeout -5 ns", pwm_obs, terminate_loop, 1, -5 ns, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.timeout := -5 ns;
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "config.timeout -5 ns");
      pwm_expect(100 ns, 25 ns, "config.timeout -5 ns", pwm_obs, terminate_loop, 1, C_UNDEFINED_TIME, ERROR, C_SCOPE, shared_msg_id_panel, v_config);
      v_config.timeout := C_UNDEFINED_TIME;

    else
      alert(TB_ERROR, "Unsupported test case: " & GC_TESTCASE, C_SCOPE);
    end if;

    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_main;

end architecture func;
