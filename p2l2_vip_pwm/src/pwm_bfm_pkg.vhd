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
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--==========================================================================================
package pwm_bfm_pkg is

  --==========================================================================================
  -- Types and constants for PWM BFM
  --==========================================================================================
  constant C_BFM_SCOPE : string := "PWM BFM";

  constant C_PWM_DECIMAL_DIGITS : positive := 6; -- Decimals of real values (duty cycles, tolerances) in logs and alerts

  type t_pwm_role       is (GENERATOR, OBSERVER);
  type t_pwm_polarity   is (ACTIVE_HIGH, ACTIVE_LOW);
  type t_pwm_alignment  is (LEFT_ALIGNED, RIGHT_ALIGNED, CENTER_ALIGNED);
  type t_pwm_idle_level is (IDLE_INACTIVE, IDLE_ACTIVE, IDLE_HIGH_Z);

  -- Configuration record to be assigned in the test harness.
  type t_pwm_bfm_config is record
    polarity                : t_pwm_polarity;    -- Active level of the line (both roles)
    alignment               : t_pwm_alignment;   -- Position of the pulse within the period (generator)
    idle_level              : t_pwm_idle_level;  -- Line level when no waveform is generated (generator)
    jitter                  : time;              -- Max. random delay of each generated edge, 0 ns = off (generator)
    jitter_seed1            : positive;          -- Seeds of the jitter randomization (generator)
    jitter_seed2            : positive;
    period_tolerance        : time;              -- Absolute tolerance on the checked period (observer)
    active_time_tolerance   : time;              -- Absolute tolerance on the checked active time (observer)
    duty_tolerance          : real;              -- Absolute tolerance on the checked duty cycle (observer)
    min_pulse_width         : time;              -- Shorter pulses/gaps are reported as glitches, 0 ns = off (observer)
    timeout                 : time;              -- Max. time of an observation, C_UNDEFINED_TIME = not set, 0 ns = no timeout (observer)
    timeout_severity        : t_alert_level;     -- Alert level of missing activity at the timeout (observer)
    constant_level_severity : t_alert_level;     -- Alert level when pwm_measure() sees a constant level (observer)
    id_for_bfm              : t_msg_id;          -- The message ID used as a general message ID in the PWM BFM
  end record t_pwm_bfm_config;

  -- Define the default value for the BFM config
  constant C_PWM_BFM_CONFIG_DEFAULT : t_pwm_bfm_config := (
    polarity                => ACTIVE_HIGH,
    alignment               => LEFT_ALIGNED,
    idle_level              => IDLE_INACTIVE,
    jitter                  => 0 ns,
    jitter_seed1            => C_RAND_INIT_SEED_1,
    jitter_seed2            => C_RAND_INIT_SEED_2,
    period_tolerance        => 0 ns,
    active_time_tolerance   => 0 ns,
    duty_tolerance          => 0.0,
    min_pulse_width         => 0 ns,
    timeout                 => C_UNDEFINED_TIME,
    timeout_severity        => ERROR,
    constant_level_severity => NO_ALERT,
    id_for_bfm              => ID_BFM
  );

  -- Result of pwm_measure()
  -- The mean values are rounded to the nearest resolution unit; the minimum and maximum values are exact.
  type t_pwm_measurement is record
    period          : time;       -- Mean of active-going edge to active-going edge, 0 ns when is_constant
    active_time     : time;       -- Mean of active-going edge to inactive-going edge, 0 ns when is_constant
    duty_cycle      : real;       -- Sum of the active times / sum of the periods; 0.0 or 1.0 when is_constant
    min_period      : time;       -- Shortest period, 0 ns when is_constant
    max_period      : time;       -- Longest period, 0 ns when is_constant
    min_active_time : time;       -- Shortest active time, 0 ns when is_constant
    max_active_time : time;       -- Longest active time, 0 ns when is_constant
    min_duty_cycle  : real;       -- Smallest duty cycle of a single period; as duty_cycle when is_constant
    max_duty_cycle  : real;       -- Largest duty cycle of a single period; as duty_cycle when is_constant
    is_constant     : boolean;    -- No edge within the timeout: the line held constant_level for the whole measurement
    constant_level  : std_ulogic; -- Line level when is_constant ('L'/'H' as '0'/'1'), else 'U'
  end record t_pwm_measurement;

  -- Also the result after a missing-activity alert
  constant C_PWM_MEASUREMENT_DEFAULT : t_pwm_measurement := (
    period          => 0 ns,
    active_time     => 0 ns,
    duty_cycle      => 0.0,
    min_period      => 0 ns,
    max_period      => 0 ns,
    min_active_time => 0 ns,
    max_active_time => 0 ns,
    min_duty_cycle  => 0.0,
    max_duty_cycle  => 0.0,
    is_constant     => false,
    constant_level  => 'U'
  );

  --==========================================================================================
  -- Duty conversion functions
  -- The generate and check procedures take the active time; these give it from a duty cycle
  -- or a counter value.
  --==========================================================================================
  -- Returns duty * period, rounded to the nearest simulator resolution unit (half a unit is rounded up).
  -- Requires 0.0 <= duty <= 1.0 and period > 0 ns; other values give an active time that the procedures reject.
  function pwm_duty_to_active_time(
    constant duty   : in real;
    constant period : in time
  ) return time;

  -- Returns (count / resolution) * period, rounded as pwm_duty_to_active_time().
  -- Requires count <= resolution and period > 0 ns; other values give an active time that the procedures reject.
  function pwm_count_to_active_time(
    constant count      : in natural;
    constant resolution : in positive;
    constant period     : in time
  ) return time;

  --==========================================================================================
  -- Line level and parameter check functions
  --==========================================================================================
  -- Returns the value driven on the line when idle, given by config.idle_level and config.polarity ('Z' for IDLE_HIGH_Z)
  function pwm_idle_value(
    constant config : in t_pwm_bfm_config
  ) return std_ulogic;

  -- Returns true if period > 0 ns, 0 ns <= active_time <= period, num_periods >= 1 and jitter >= 0 ns. Otherwise
  -- raises one TB_ERROR naming proc_call and returns false. The defaults of num_periods and jitter are valid values.
  -- Used by the generate and check procedures and by the VVC.
  impure function pwm_generation_is_valid(
    constant period      : in time;
    constant active_time : in time;
    constant proc_call   : in string;
    constant msg         : in string;
    constant scope       : in string  := C_BFM_SCOPE;
    constant num_periods : in integer := 1;
    constant jitter      : in time    := 0 ns
  ) return boolean;

  --==========================================================================================
  -- BFM procedures
  --==========================================================================================

  ---------------------------------------------------------------------------------
  -- drive idle
  ---------------------------------------------------------------------------------
  -- Drives the idle level given by config.idle_level and config.polarity.
  procedure pwm_drive_idle(
    constant msg          : in string;
    signal   pwm          : inout std_ulogic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------
  -- drive period
  ---------------------------------------------------------------------------------
  -- Drives one complete period according to config.polarity and config.alignment and returns at the end of the period.
  -- The line is not returned to idle, so consecutive calls give a continuous waveform. 0 ns and period as active_time
  -- give a constant level without edges. Invalid parameters (see pwm_generation_is_valid()) raise a TB_ERROR and
  -- return at once.
  -- With config.jitter > 0 ns, every edge is delayed by a random offset in [0, jitter] from its ideal time, drawn with
  -- seed1/seed2, which are updated. Every pulse and gap stays at least one resolution unit long.
  -- Returns at once with aborted = true when 'abort' has an event during the period. The line keeps its level; the
  -- caller drives the idle level. Used by the VVC for pwm_abort() and terminate_current_command.
  procedure pwm_drive_period(
    constant period       : in time;
    constant active_time  : in time;
    variable seed1        : inout positive;
    variable seed2        : inout positive;
    variable aborted      : out boolean;
    constant msg          : in string;
    signal   pwm          : inout std_ulogic;
    signal   abort        : in boolean;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------
  -- generate
  ---------------------------------------------------------------------------------
  -- Generates num_periods complete periods as pwm_drive_period(), then drives the idle level. Returns at the end of the
  -- last period. The jitter randomization starts from config.jitter_seed1/2 in every call, so a call is reproducible.
  procedure pwm_generate(
    constant period       : in time;
    constant active_time  : in time;
    constant num_periods  : in integer;
    constant msg          : in string;
    signal   pwm          : inout std_ulogic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------
  -- Observation: common rules
  ---------------------------------------------------------------------------------
  -- * A period is measured from the first active-going edge after the call; a period in progress is ignored.
  -- * The timeout is the maximum time of the whole observation, from the call. The per-call timeout overrides
  --   config.timeout; C_UNDEFINED_TIME means "not set" and 0 ns means "no timeout". If neither is set, pwm_expect() with
  --   a period uses (num_periods + 2) * (period + config.period_tolerance); pwm_measure() and pwm_expect() with duty
  --   raise a TB_ERROR and return at once, as they have no period to derive a timeout from (as gpio_expect()). Give
  --   0 ns to wait without limit.
  -- * Periods not complete at the timeout raise a missing-activity alert at config.timeout_severity.
  -- * terminate_loop = '1' ends the observation at once, without an alert (logged with ID_TERMINATE_CMD);
  --   pwm_measure() then returns C_PWM_MEASUREMENT_DEFAULT. Without a VVC, pass a signal that stays '0'.
  -- * The weak levels 'L' and 'H' are read as '0' and '1', e.g. on a line with a pull resistor.
  -- * While waiting for the first active-going edge, the line may be 'Z' if config.idle_level = IDLE_HIGH_Z. Any other
  --   value than '0'/'1'/'L'/'H' raises an alert each time the line changes to it; edges are changes between '0' and '1'.
  -- * With config.min_pulse_width > 0 ns, every measured pulse or gap shorter than it raises an alert.

  ---------------------------------------------------------------------------------
  -- measure
  ---------------------------------------------------------------------------------
  -- Measures num_periods complete periods and returns the mean period and active time (each rounded to the nearest
  -- simulator resolution unit) and the duty cycle of the sums. If the line has no edge before the timeout, the
  -- result is the constant level (0 % or 100 %), with an alert at config.constant_level_severity (default NO_ALERT).
  -- The timeout must be set (see above); with 0 ns, pwm_measure() waits until the periods are complete, on a constant
  -- line for ever. Fewer
  -- complete periods at the timeout, also an inactive-going edge without a following active-going edge, raise a
  -- missing-activity alert and return C_PWM_MEASUREMENT_DEFAULT. Invalid
  -- levels and pulses shorter than config.min_pulse_width raise an ERROR.
  procedure pwm_measure(
    variable result         : out t_pwm_measurement;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant num_periods    : in integer          := 1;
    constant timeout        : in time             := C_UNDEFINED_TIME;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------
  -- check
  ---------------------------------------------------------------------------------
  -- Checks num_periods consecutive periods against period and active_time, within config.period_tolerance and
  -- config.active_time_tolerance (inclusive). Each failing period raises one alert at alert_level, naming its index.
  -- active_time = 0 ns or = period checks that the line holds the inactive or active level for num_periods * period;
  -- the timeout is not used then. Periods not complete at the timeout raise a missing-activity alert at
  -- config.timeout_severity and end the check.
  procedure pwm_expect(
    constant period         : in time;
    constant active_time    : in time;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant num_periods    : in integer          := 1;
    constant timeout        : in time             := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level    := ERROR;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  );

  -- Checks the duty cycle of num_periods consecutive periods within config.duty_tolerance (inclusive), independent
  -- of the period. The timeout must be set (see above). duty = 0.0 or 1.0 checks that the line holds the constant
  -- level for the timeout, which must then be > 0 ns.
  procedure pwm_expect(
    constant duty           : in real;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant num_periods    : in integer          := 1;
    constant timeout        : in time             := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level    := ERROR;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  );

end package pwm_bfm_pkg;

--==========================================================================================
--==========================================================================================
package body pwm_bfm_pkg is

  -- Deadline of an observation without a timeout
  constant C_NO_DEADLINE : time := time'high;

  -- Added to config.duty_tolerance in the duty check against real rounding, e.g. 0.26 - 0.25 > 0.01
  constant C_DUTY_ROUNDING_MARGIN : real := 1.0e-12;

  ---------------------------------------------------------------------------------
  -- Internal: conversion between time and a number of resolution units.
  -- Time is split into two parts so that the time / time divisions stay within
  -- the 32-bit integer range for long times and fine resolutions.
  ---------------------------------------------------------------------------------
  constant C_UNITS_SPLIT : positive := 2**30;

  function time_to_units(
    constant value : in time
  ) return real is
    constant C_RESOLUTION : time := std.env.resolution_limit;
    constant C_HIGH_UNIT  : time := C_RESOLUTION * C_UNITS_SPLIT;
    variable v_high       : integer;
  begin
    v_high := value / C_HIGH_UNIT;
    return real(v_high) * real(C_UNITS_SPLIT) + real((value - v_high * C_HIGH_UNIT) / C_RESOLUTION);
  end function;

  -- Rounds to the nearest whole number of resolution units, half a unit up
  function units_to_time(
    constant num_units : in real
  ) return time is
    constant C_RESOLUTION : time := std.env.resolution_limit;
    constant C_HIGH_UNIT  : time := C_RESOLUTION * C_UNITS_SPLIT;
    variable v_high       : integer;
    variable v_low        : real;
  begin
    -- floor() only on values below 2**31: some math_real implementations (GHDL) return larger values unchanged
    v_high := integer(floor(num_units / real(C_UNITS_SPLIT)));
    v_low  := floor(num_units - real(v_high) * real(C_UNITS_SPLIT) + 0.5);
    return v_high * C_HIGH_UNIT + integer(v_low) * C_RESOLUTION;
  end function;

  ---------------------------------------------------------------------------------
  -- Internal: line levels
  ---------------------------------------------------------------------------------
  function active_level(
    constant config : in t_pwm_bfm_config
  ) return std_ulogic is
  begin
    if config.polarity = ACTIVE_HIGH then
      return '1';
    else
      return '0';
    end if;
  end function;

  function inactive_level(
    constant config : in t_pwm_bfm_config
  ) return std_ulogic is
  begin
    return not active_level(config);
  end function;

  -- The logic level of a line value: 'L'/'H' as '0'/'1', every other value than '0'/'1' as 'X'
  function line_level(
    constant value : in std_ulogic
  ) return std_ulogic is
  begin
    return to_x01(value);
  end function;

  function is_valid_level(
    constant value : in std_ulogic
  ) return boolean is
  begin
    return line_level(value) /= 'X';
  end function;

  -- The level of a constant line: active for 100 % (is_full), else inactive for 0 %
  function constant_level(
    constant is_full : in boolean;
    constant config  : in t_pwm_bfm_config
  ) return std_ulogic is
  begin
    if is_full then
      return active_level(config);
    else
      return inactive_level(config);
    end if;
  end function;

  function pwm_idle_value(
    constant config : in t_pwm_bfm_config
  ) return std_ulogic is
  begin
    case config.idle_level is
      when IDLE_INACTIVE => return inactive_level(config);
      when IDLE_ACTIVE   => return active_level(config);
      when IDLE_HIGH_Z   => return 'Z';
    end case;
  end function;

  ---------------------------------------------------------------------------------
  -- Parameter check of generation and of the period check
  ---------------------------------------------------------------------------------
  impure function pwm_generation_is_valid(
    constant period      : in time;
    constant active_time : in time;
    constant proc_call   : in string;
    constant msg         : in string;
    constant scope       : in string  := C_BFM_SCOPE;
    constant num_periods : in integer := 1;
    constant jitter      : in time    := 0 ns
  ) return boolean is
    constant C_FAILED : string := proc_call & "=> Failed. ";
  begin
    if period <= 0 ns then
      alert(TB_ERROR, C_FAILED & "period must be > 0 ns, was " & to_string(period, ns) & "." & add_msg_delimiter(msg), scope);
    elsif active_time < 0 ns then
      alert(TB_ERROR, C_FAILED & "active_time must be >= 0 ns, was " & to_string(active_time, ns) & "." & add_msg_delimiter(msg), scope);
    elsif active_time > period then
      alert(TB_ERROR, C_FAILED & "active_time (" & to_string(active_time, ns) & ") must not exceed period (" & to_string(period, ns) & ")." &
            add_msg_delimiter(msg), scope);
    elsif num_periods < 1 then
      alert(TB_ERROR, C_FAILED & "num_periods must be >= 1, was " & to_string(num_periods) & "." & add_msg_delimiter(msg), scope);
    elsif jitter < 0 ns then
      alert(TB_ERROR, C_FAILED & "config.jitter must be >= 0 ns, was " & to_string(jitter, ns) & "." & add_msg_delimiter(msg), scope);
    else
      return true;
    end if;
    return false;
  end function;

  ---------------------------------------------------------------------------------
  -- Internal: timing core of pwm_drive_period() and pwm_generate()
  ---------------------------------------------------------------------------------
  -- One assignment to the line: its time relative to the period start and its level
  type t_assignment is record
    offset : time;
    level  : std_ulogic;
  end record t_assignment;

  type t_period_plan is array (0 to 2) of t_assignment;

  -- Plans the assignments 0 to 'last' of one period. The first one is at the period boundary (an edge only if
  -- 'level_before', the line level before the period, differs). 0 % and 100 % give one assignment of a constant
  -- level, so no edges and no jitter. With config.jitter > 0 ns the offsets are already jittered.
  procedure plan_period(
    constant period       : in time;
    constant active_time  : in time;
    constant config       : in t_pwm_bfm_config;
    constant level_before : in std_ulogic;
    variable seed1        : inout positive;
    variable seed2        : inout positive;
    variable plan         : out t_period_plan;
    variable last         : out natural
  ) is
    constant C_RESOLUTION : time       := std.env.resolution_limit;
    constant C_ACTIVE     : std_ulogic := active_level(config);
    constant C_INACTIVE   : std_ulogic := inactive_level(config);
    constant C_OFF_TIME   : time       := period - active_time;
    variable v_plan       : t_period_plan;
    variable v_last       : natural;
    variable v_first_gap  : time;
    variable v_offset     : time;
    variable v_time       : time;
    variable v_earliest   : time       := 0 ns; -- earliest time of the next edge
  begin
    if active_time = 0 ns then
      plan(0) := (0 ns, C_INACTIVE);
      last    := 0;
      return;
    elsif active_time = period then
      plan(0) := (0 ns, C_ACTIVE);
      last    := 0;
      return;
    end if;

    case config.alignment is
      when LEFT_ALIGNED =>
        v_plan(0 to 1) := ((0 ns, C_ACTIVE), (active_time, C_INACTIVE));
        v_last         := 1;
      when RIGHT_ALIGNED =>
        v_plan(0 to 1) := ((0 ns, C_INACTIVE), (C_OFF_TIME, C_ACTIVE));
        v_last         := 1;
      when CENTER_ALIGNED =>
        -- An odd number of resolution units in the off time: the extra unit goes to the second gap
        v_first_gap := C_OFF_TIME / 2; -- whole resolution units, rounded down
        v_plan      := ((0 ns, C_INACTIVE), (v_first_gap, C_ACTIVE), (v_first_gap + active_time, C_INACTIVE));
        v_last      := 2;
    end case;

    for i in 0 to v_last loop
      -- No edge at the period start if the line is already at its level (e.g. center-aligned after center-aligned):
      -- not jittered, and it does not delay the next edge
      if config.jitter > 0 ns and not (i = 0 and to_x01(level_before) = v_plan(0).level) then
        -- Delay relative to the ideal time, so the jitter does not accumulate. Every edge gets the same distribution,
        -- so the mean period and the mean active time stay exact, and no edge moves before the start of its period.
        -- Clamped so that the edges keep their order, every pulse and gap is at least one resolution unit and every
        -- edge stays within its period; a clamped edge is still within [0, jitter] of its ideal time.
        random(0 ns, config.jitter, C_RESOLUTION, seed1, seed2, v_offset, "pwm_drive_period");
        v_time           := maximum(v_plan(i).offset + v_offset, v_earliest);
        v_time           := minimum(v_time, period - (v_last + 1 - i) * C_RESOLUTION);
        v_plan(i).offset := v_time;
        v_earliest       := v_time + C_RESOLUTION;
      end if;
    end loop;
    plan := v_plan;
    last := v_last;
  end procedure;

  -- Drives one period, without parameter check and log. pwm_generate() has no abort signal, so this core exists
  -- twice: with and without 'abort'.
  procedure drive_period_core(
    constant period      : in time;
    constant active_time : in time;
    signal   pwm         : inout std_ulogic;
    constant config      : in t_pwm_bfm_config;
    variable seed1       : inout positive;
    variable seed2       : inout positive
  ) is
    variable v_plan : t_period_plan;
    variable v_last : natural;
    variable v_now  : time := 0 ns;
  begin
    plan_period(period, active_time, config, pwm, seed1, seed2, v_plan, v_last);
    for i in 0 to v_last loop
      if v_plan(i).offset > v_now then
        wait for v_plan(i).offset - v_now;
      end if;
      pwm   <= v_plan(i).level;
      v_now := v_plan(i).offset;
    end loop;
    wait for period - v_now;
  end procedure;

  procedure drive_period_core(
    constant period      : in time;
    constant active_time : in time;
    signal   pwm         : inout std_ulogic;
    constant config      : in t_pwm_bfm_config;
    variable seed1       : inout positive;
    variable seed2       : inout positive;
    signal   abort       : in boolean;
    variable aborted     : out boolean
  ) is
    variable v_plan : t_period_plan;
    variable v_last : natural;
    variable v_now  : time := 0 ns;
  begin
    aborted := false;
    plan_period(period, active_time, config, pwm, seed1, seed2, v_plan, v_last);
    for i in 0 to v_last loop
      if v_plan(i).offset > v_now then
        wait on abort for v_plan(i).offset - v_now;
        if abort'event then
          aborted := true;
          return;
        end if;
      end if;
      pwm   <= v_plan(i).level;
      v_now := v_plan(i).offset;
    end loop;
    wait on abort for period - v_now;
    aborted := abort'event;
  end procedure;

  ---------------------------------------------------------------------------------
  -- Internal: observation
  ---------------------------------------------------------------------------------
  -- The observation timeout: the per-call value, else config.timeout, else for a check with a period (period > 0 ns)
  -- one period to reach the first active-going edge, the periods themselves and one period of margin, each with the
  -- period tolerance; else C_UNDEFINED_TIME, which check_observe_parameters() rejects. Call only with num_periods >= 1.
  function resolve_timeout(
    constant timeout     : in time;
    constant period      : in time;
    constant num_periods : in positive;
    constant config      : in t_pwm_bfm_config
  ) return time is
    constant C_MARGIN_PERIODS : natural := 2; -- reaching the first active-going edge, plus one period of margin
  begin
    if timeout /= C_UNDEFINED_TIME then
      return timeout;
    elsif config.timeout /= C_UNDEFINED_TIME then
      return config.timeout;
    elsif period > 0 ns then
      return (num_periods + C_MARGIN_PERIODS) * (period + config.period_tolerance);
    else
      return C_UNDEFINED_TIME;
    end if;
  end function;

  -- The end of an observation: now + timeout, or C_NO_DEADLINE without a timeout (0 ns)
  impure function deadline_of(
    constant timeout : in time
  ) return time is
  begin
    if timeout = 0 ns then
      return C_NO_DEADLINE;
    else
      return now + timeout;
    end if;
  end function;

  -- A period of 0 ns (a zero-width glitch, e.g. in delta cycles) has no active time either: duty cycle 0.0
  function duty_of(
    constant active_time : in time;
    constant period      : in time
  ) return real is
  begin
    if period = 0 ns then
      return 0.0;
    end if;
    return time_to_units(active_time) / time_to_units(period);
  end function;

  -- Parameter check of the observation procedures, after the procedure-specific checks. Raises at most one alert.
  procedure check_observe_parameters(
    constant proc_call      : in string;
    constant timeout        : in time;    -- resolved
    constant needs_window   : in boolean; -- constant-level check of the duty overload: the timeout is the window
    constant time_tolerance : in boolean; -- the period/active time tolerances are used
    constant duty_tolerance : in boolean; -- the duty tolerance is used
    constant config         : in t_pwm_bfm_config;
    constant msg            : in string;
    constant scope          : in string;
    variable valid          : out boolean
  ) is
  begin
    valid := false;
    if timeout < 0 ns and timeout /= C_UNDEFINED_TIME then
      alert(TB_ERROR, proc_call & "=> Failed. timeout must be >= 0 ns, was " & to_string(timeout, ns) & "." & add_msg_delimiter(msg), scope);
    elsif timeout = C_UNDEFINED_TIME then
      alert(TB_ERROR, proc_call & "=> Failed. No timeout set: give one per call or in config.timeout, 0 ns to wait without limit." &
            add_msg_delimiter(msg), scope);
    elsif needs_window and timeout = 0 ns then
      alert(TB_ERROR, proc_call & "=> Failed. A constant-level check of the duty cycle needs a timeout > 0 ns as observation window, " &
            "per call or in config.timeout." & add_msg_delimiter(msg), scope);
    elsif config.min_pulse_width < 0 ns then
      alert(TB_ERROR, proc_call & "=> Failed. config.min_pulse_width must be >= 0 ns, was " & to_string(config.min_pulse_width, ns) & "." &
            add_msg_delimiter(msg), scope);
    elsif time_tolerance and config.period_tolerance < 0 ns then
      alert(TB_ERROR, proc_call & "=> Failed. config.period_tolerance must be >= 0 ns, was " & to_string(config.period_tolerance, ns) & "." &
            add_msg_delimiter(msg), scope);
    elsif time_tolerance and config.active_time_tolerance < 0 ns then
      alert(TB_ERROR, proc_call & "=> Failed. config.active_time_tolerance must be >= 0 ns, was " &
            to_string(config.active_time_tolerance, ns) & "." & add_msg_delimiter(msg), scope);
    elsif duty_tolerance and (config.duty_tolerance < 0.0 or config.duty_tolerance > 1.0) then
      alert(TB_ERROR, proc_call & "=> Failed. config.duty_tolerance must be within 0.0 to 1.0, was " & to_string(config.duty_tolerance, C_PWM_DECIMAL_DIGITS) &
            "." & add_msg_delimiter(msg), scope);
    else
      valid := true;
    end if;
  end procedure;

  -- Waits for the next edge: a change of the valid level ('0'/'1', 'L'/'H' read as '0'/'1') of pwm, until 'deadline'
  -- (C_NO_DEADLINE = no limit) or terminate_loop = '1'.
  -- 'level' is the last valid level ('U' = none yet) and is updated. A change to any other value raises an alert at
  -- alert_level, except 'Z' when allow_z is true. timed_out is true if no edge came before the deadline.
  procedure await_edge(
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant deadline       : in time;
    constant allow_z        : in boolean;
    constant alert_level    : in t_alert_level;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    variable level          : inout std_ulogic;
    variable timed_out      : out boolean;
    variable terminated     : out boolean
  ) is
  begin
    timed_out  := false;
    terminated := false;
    loop
      if terminate_loop = '1' then
        terminated := true;
        return;
      elsif now >= deadline then
        timed_out := true;
        return;
      end if;
      if deadline = C_NO_DEADLINE then
        wait on pwm, terminate_loop;
      else
        wait on pwm, terminate_loop for deadline - now;
      end if;
      if pwm'event then
        if is_valid_level(pwm) then
          if line_level(pwm) /= level then
            level := line_level(pwm);
            return;
          end if;
        elsif not (allow_z and pwm = 'Z') then
          alert(alert_level, proc_call & "=> Failed. Invalid level '" & to_string(pwm) & "' on the line." & add_msg_delimiter(msg), scope);
        end if;
      end if;
    end loop;
  end procedure;

  -- Waits for the next active-going edge; a period in progress is ignored.
  -- timed_out is true if no active-going edge came before the deadline. inactive_edge is true if the line went from the
  -- active to the inactive level while waiting (the first valid level after an invalid one or 'Z' is no edge).
  procedure await_period_start(
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant deadline       : in time;
    constant alert_level    : in t_alert_level;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant config         : in t_pwm_bfm_config;
    variable timed_out      : out boolean;
    variable terminated     : out boolean;
    variable inactive_edge  : out boolean
  ) is
    variable v_level      : std_ulogic := 'U';
    variable v_previous   : std_ulogic;
    variable v_timed_out  : boolean;
    variable v_terminated : boolean;
  begin
    inactive_edge := false;
    if is_valid_level(pwm) then
      v_level := line_level(pwm);
    end if;
    loop
      v_previous := v_level;
      await_edge(pwm, terminate_loop, deadline, config.idle_level = IDLE_HIGH_Z, alert_level, proc_call, msg, scope, v_level,
                 v_timed_out, v_terminated);
      exit when v_timed_out or v_terminated or v_level = active_level(config);
      if v_previous = active_level(config) then
        inactive_edge := true;
      end if;
    end loop;
    timed_out  := v_timed_out;
    terminated := v_terminated;
  end procedure;

  -- Raises an alert if a pulse or gap ('kind') that ended now is shorter than config.min_pulse_width
  procedure check_min_pulse_width(
    constant duration    : in time;
    constant kind        : in string;
    constant alert_level : in t_alert_level;
    constant proc_call   : in string;
    constant msg         : in string;
    constant scope       : in string;
    constant config      : in t_pwm_bfm_config
  ) is
  begin
    if config.min_pulse_width > 0 ns and duration < config.min_pulse_width then
      alert(alert_level, proc_call & "=> Failed. " & kind & " of " & to_string(duration, ns) & " ending at " & to_string(now, ns) &
            " is shorter than config.min_pulse_width (" & to_string(config.min_pulse_width, ns) & ")." & add_msg_delimiter(msg), scope);
    end if;
  end procedure;

  -- Measures the period that starts with the active-going edge just seen (now): waits for the inactive-going and the
  -- next active-going edge before the deadline. timed_out = true if the period is not complete at the deadline; the
  -- caller raises the missing-activity alert.
  procedure measure_period(
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant deadline       : in time;
    constant alert_level    : in t_alert_level;
    constant proc_call      : in string;
    constant msg            : in string;
    constant scope          : in string;
    constant config         : in t_pwm_bfm_config;
    variable period         : out time;
    variable active_time    : out time;
    variable timed_out      : out boolean;
    variable terminated     : out boolean
  ) is
    constant C_START      : time       := now;
    variable v_level      : std_ulogic := active_level(config);
    variable v_inactive   : time;
    variable v_timed_out  : boolean;
    variable v_terminated : boolean;
  begin
    await_edge(pwm, terminate_loop, deadline, false, alert_level, proc_call, msg, scope, v_level, v_timed_out, v_terminated);
    timed_out  := v_timed_out;
    terminated := v_terminated;
    if v_timed_out or v_terminated then
      return;
    end if;
    v_inactive := now;
    check_min_pulse_width(v_inactive - C_START, "Pulse", alert_level, proc_call, msg, scope, config);

    await_edge(pwm, terminate_loop, deadline, false, alert_level, proc_call, msg, scope, v_level, v_timed_out, v_terminated);
    timed_out  := v_timed_out;
    terminated := v_terminated;
    if v_timed_out or v_terminated then
      return;
    end if;
    check_min_pulse_width(now - v_inactive, "Gap", alert_level, proc_call, msg, scope, config);

    period      := now - C_START;
    active_time := v_inactive - C_START;
  end procedure;

  -- Missing-activity alert at the timeout: 'num_complete' of 'num_periods' periods were complete
  procedure alert_missing_activity(
    constant num_complete : in natural;
    constant num_periods  : in positive;
    constant timeout      : in time;
    constant proc_call    : in string;
    constant msg          : in string;
    signal   pwm          : in std_ulogic;
    constant scope        : in string;
    constant config       : in t_pwm_bfm_config
  ) is
  begin
    alert(config.timeout_severity, proc_call & "=> Failed. Missing activity: " & to_string(num_complete) & " of " & to_string(num_periods) &
          " period(s) complete within the timeout of " & to_string(timeout, ns) & " (line at '" & to_string(pwm) & "')." &
          add_msg_delimiter(msg), scope);
  end procedure;

  procedure log_terminated(
    constant proc_call    : in string;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel
  ) is
  begin
    log(ID_TERMINATE_CMD, proc_call & "=> terminated." & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  -- Checks that the line holds 'expected' (0 % or 100 %) without any change for 'window'. Raises at most one alert and
  -- returns at the first violation. Logs the termination by terminate_loop.
  procedure check_constant_level(
    constant expected       : in std_ulogic;
    constant window         : in time;
    constant alert_level    : in t_alert_level;
    constant proc_call      : in string;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_pwm_bfm_config
  ) is
    constant C_START : time := now;
  begin
    if line_level(pwm) /= expected then
      alert(alert_level, proc_call & "=> Failed. Expected the constant level '" & to_string(expected) & "', the line was '" &
            to_string(pwm) & "'." & add_msg_delimiter(msg), scope);
      return;
    end if;
    while now - C_START < window loop
      if terminate_loop = '1' then
        log_terminated(proc_call, msg, scope, msg_id_panel);
        return;
      end if;
      wait on pwm, terminate_loop for window - (now - C_START);
      -- A change between a strong and a weak value of the same level (e.g. '1' to 'H') keeps the level
      if pwm'event and line_level(pwm) /= expected then
        alert(alert_level, proc_call & "=> Failed. Expected the constant level '" & to_string(expected) & "' for " & to_string(window, ns) &
              ", the line changed to '" & to_string(pwm) & "' after " & to_string(now - C_START, ns) & "." & add_msg_delimiter(msg), scope);
        return;
      end if;
    end loop;
    log(config.id_for_bfm, proc_call & "=> OK, constant level '" & to_string(expected) & "' for " & to_string(window, ns) & "." &
        add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  function time_mismatch(
    constant name     : in string;
    constant measured : in time;
    constant expected : in time;
    constant tol      : in time
  ) return string is
  begin
    return name & " was " & to_string(measured, ns) & ", expected " & to_string(expected, ns) & " +-" & to_string(tol, ns);
  end function;

  -- The failing parts of one checked period: "T ...", "t_on ..." or both
  function period_mismatch(
    constant period_ok            : in boolean;
    constant active_ok            : in boolean;
    constant period               : in time;
    constant active_time          : in time;
    constant expected_period      : in time;
    constant expected_active_time : in time;
    constant config               : in t_pwm_bfm_config
  ) return string is
    constant C_PERIOD : string := time_mismatch("T", period, expected_period, config.period_tolerance);
    constant C_ACTIVE : string := time_mismatch("t_on", active_time, expected_active_time, config.active_time_tolerance);
  begin
    if not period_ok and not active_ok then
      return C_PERIOD & "; " & C_ACTIVE;
    elsif not period_ok then
      return C_PERIOD;
    else
      return C_ACTIVE;
    end if;
  end function;

  -- Checks num_periods consecutive periods: period and active_time, or the duty cycle if check_duty is true.
  -- 'timeout' is resolved; periods not complete at the timeout raise one missing-activity alert. Logs the termination
  -- by terminate_loop.
  procedure check_periods(
    constant period         : in time;
    constant active_time    : in time;
    constant duty           : in real;
    constant check_duty     : in boolean;
    constant num_periods    : in positive;
    constant timeout        : in time;
    constant alert_level    : in t_alert_level;
    constant proc_call      : in string;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant scope          : in string;
    constant msg_id_panel   : in t_msg_id_panel;
    constant config         : in t_pwm_bfm_config
  ) is
    constant C_DEADLINE    : time    := deadline_of(timeout);
    constant C_FAILED_IN   : string  := proc_call & "=> Failed in period ";
    variable v_timed_out   : boolean;
    variable v_terminated  : boolean;
    variable v_inactive_edge : boolean; -- not used: a check without a complete period is missing activity anyway
    variable v_period      : time;
    variable v_active_time : time;
    variable v_duty        : real;
    variable v_period_ok   : boolean;
    variable v_active_ok   : boolean;
    variable v_num_failed  : natural := 0;
  begin
    await_period_start(pwm, terminate_loop, C_DEADLINE, alert_level, proc_call, msg, scope, config, v_timed_out, v_terminated,
                       v_inactive_edge);
    if v_terminated then
      log_terminated(proc_call, msg, scope, msg_id_panel);
      return;
    elsif v_timed_out then
      alert_missing_activity(0, num_periods, timeout, proc_call, msg, pwm, scope, config);
      return;
    end if;

    for i in 1 to num_periods loop
      measure_period(pwm, terminate_loop, C_DEADLINE, alert_level, proc_call, msg, scope, config, v_period, v_active_time, v_timed_out,
                     v_terminated);
      if v_terminated then
        log_terminated(proc_call, msg, scope, msg_id_panel);
        return;
      elsif v_timed_out then
        alert_missing_activity(i - 1, num_periods, timeout, proc_call, msg, pwm, scope, config);
        return;
      end if;
      if check_duty then
        v_duty := duty_of(v_active_time, v_period);
        if abs (v_duty - duty) > config.duty_tolerance + C_DUTY_ROUNDING_MARGIN then
          alert(alert_level, C_FAILED_IN & to_string(i) & "/" & to_string(num_periods) & ". Duty cycle was " &
                to_string(v_duty, C_PWM_DECIMAL_DIGITS) & " (t_on " & to_string(v_active_time, ns) & ", T " & to_string(v_period, ns) & "), expected " &
                to_string(duty, C_PWM_DECIMAL_DIGITS) & " +-" & to_string(config.duty_tolerance, C_PWM_DECIMAL_DIGITS) & "." & add_msg_delimiter(msg), scope);
          v_num_failed := v_num_failed + 1;
        end if;
      else
        v_period_ok := abs (v_period - period) <= config.period_tolerance;
        v_active_ok := abs (v_active_time - active_time) <= config.active_time_tolerance;
        if not (v_period_ok and v_active_ok) then
          alert(alert_level, C_FAILED_IN & to_string(i) & "/" & to_string(num_periods) & ". " &
                period_mismatch(v_period_ok, v_active_ok, v_period, v_active_time, period, active_time, config) & "." & add_msg_delimiter(msg),
                scope);
          v_num_failed := v_num_failed + 1;
        end if;
      end if;
    end loop;

    if v_num_failed = 0 and check_duty then
      log(config.id_for_bfm, proc_call & "=> OK, " & to_string(num_periods) & " period(s) checked (duty +-" &
          to_string(config.duty_tolerance, C_PWM_DECIMAL_DIGITS) & ")." & add_msg_delimiter(msg), scope, msg_id_panel);
    elsif v_num_failed = 0 then
      log(config.id_for_bfm, proc_call & "=> OK, " & to_string(num_periods) & " period(s) checked (T +-" &
          to_string(config.period_tolerance, ns) & ", t_on +-" & to_string(config.active_time_tolerance, ns) & ")." &
          add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  --==========================================================================================
  -- Duty conversion functions
  --==========================================================================================
  function pwm_duty_to_active_time(
    constant duty   : in real;
    constant period : in time
  ) return time is
  begin
    return units_to_time(duty * time_to_units(period));
  end function;

  function pwm_count_to_active_time(
    constant count      : in natural;
    constant resolution : in positive;
    constant period     : in time
  ) return time is
  begin
    return units_to_time(time_to_units(period) * real(count) / real(resolution));
  end function;

  --==========================================================================================
  -- BFM procedures
  --==========================================================================================
  procedure pwm_drive_idle(
    constant msg          : in string;
    signal   pwm          : inout std_ulogic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_NAME : string     := "pwm_drive_idle()";
    constant C_VALUE     : std_ulogic := pwm_idle_value(config);
  begin
    pwm <= C_VALUE;
    log(config.id_for_bfm, C_PROC_NAME & "=> line at '" & to_string(C_VALUE) & "' (" & to_upper(to_string(config.idle_level)) & ")." &
        add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  procedure pwm_drive_period(
    constant period       : in time;
    constant active_time  : in time;
    variable seed1        : inout positive;
    variable seed2        : inout positive;
    variable aborted      : out boolean;
    constant msg          : in string;
    signal   pwm          : inout std_ulogic;
    signal   abort        : in boolean;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_NAME : string := "pwm_drive_period(" & to_string(period, ns) & ", " & to_string(active_time, ns) & ")";
    variable v_aborted   : boolean;
  begin
    aborted := false;
    if not pwm_generation_is_valid(period, active_time, C_PROC_NAME, msg, scope, jitter => config.jitter) then
      return;
    end if;
    drive_period_core(period, active_time, pwm, config, seed1, seed2, abort, v_aborted);
    aborted := v_aborted;
    if v_aborted then
      log(config.id_for_bfm, C_PROC_NAME & " aborted." & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      log(config.id_for_bfm, C_PROC_NAME & " completed." & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  procedure pwm_generate(
    constant period       : in time;
    constant active_time  : in time;
    constant num_periods  : in integer;
    constant msg          : in string;
    signal   pwm          : inout std_ulogic;
    constant scope        : in string           := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_NAME : string := "pwm_generate(" & to_string(period, ns) & ", " & to_string(active_time, ns) & ", " &
                                     to_string(num_periods) & ")";
    variable v_seed1     : positive := config.jitter_seed1;
    variable v_seed2     : positive := config.jitter_seed2;
  begin
    if not pwm_generation_is_valid(period, active_time, C_PROC_NAME, msg, scope, num_periods, config.jitter) then
      return;
    end if;
    for i in 1 to num_periods loop
      drive_period_core(period, active_time, pwm, config, v_seed1, v_seed2);
    end loop;
    pwm <= pwm_idle_value(config);
    log(config.id_for_bfm, C_PROC_NAME & " completed (" & to_upper(to_string(config.polarity)) & ", " & to_upper(to_string(config.alignment)) & ")." &
        add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------
  -- Observation procedures
  ---------------------------------------------------------------------------------
  procedure pwm_measure(
    variable result         : out t_pwm_measurement;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant num_periods    : in integer          := 1;
    constant timeout        : in time             := C_UNDEFINED_TIME;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_NAME   : string := "pwm_measure(" & to_string(num_periods) & ")";
    variable v_timeout     : time;
    variable v_deadline    : time;
    variable v_valid       : boolean;
    variable v_timed_out   : boolean;
    variable v_terminated  : boolean;
    variable v_inactive_edge : boolean;
    variable v_period      : time;
    variable v_active_time : time;
    variable v_sum_period  : time := 0 ns;
    variable v_sum_active  : time := 0 ns;
    variable v_duty        : real;
    variable v_result      : t_pwm_measurement := C_PWM_MEASUREMENT_DEFAULT;
  begin
    result := C_PWM_MEASUREMENT_DEFAULT;
    if num_periods < 1 then
      alert(TB_ERROR, C_PROC_NAME & "=> Failed. num_periods must be >= 1, was " & to_string(num_periods) & "." & add_msg_delimiter(msg), scope);
      return;
    end if;
    v_timeout := resolve_timeout(timeout, 0 ns, num_periods, config);
    check_observe_parameters(proc_call      => C_PROC_NAME,
                             timeout        => v_timeout,
                             needs_window   => false,
                             time_tolerance => false,
                             duty_tolerance => false,
                             config         => config,
                             msg            => msg,
                             scope          => scope,
                             valid          => v_valid);
    if not v_valid then
      return;
    end if;
    v_deadline := deadline_of(v_timeout);

    await_period_start(pwm, terminate_loop, v_deadline, ERROR, C_PROC_NAME, msg, scope, config, v_timed_out, v_terminated,
                       v_inactive_edge);
    if v_terminated then
      log_terminated(C_PROC_NAME, msg, scope, msg_id_panel);
      return;
    elsif v_timed_out and v_inactive_edge then
      -- The line changed level but no period began: activity without a complete period, not a constant level
      alert_missing_activity(0, num_periods, v_timeout, C_PROC_NAME, msg, pwm, scope, config);
      return;
    elsif v_timed_out then
      -- No edge within the timeout: a constant level, reported as result
      v_result.is_constant := true;
      if is_valid_level(pwm) then
        v_result.constant_level := line_level(pwm);
      else
        v_result.constant_level := pwm;
      end if;
      if line_level(pwm) = active_level(config) then
        v_result.duty_cycle     := 1.0;
        v_result.min_duty_cycle := 1.0;
        v_result.max_duty_cycle := 1.0;
      elsif not (is_valid_level(pwm) or (pwm = 'Z' and config.idle_level = IDLE_HIGH_Z)) then
        alert(ERROR, C_PROC_NAME & "=> Failed. Invalid constant level '" & to_string(pwm) & "' on the line." & add_msg_delimiter(msg), scope);
      end if;
      result := v_result;
      alert(config.constant_level_severity, C_PROC_NAME & "=> Constant level '" & to_string(pwm) & "': no edge within " &
            to_string(v_timeout, ns) & "." & add_msg_delimiter(msg), scope);
      log(config.id_for_bfm, C_PROC_NAME & "=> constant level '" & to_string(pwm) & "' (no edge within " &
          to_string(v_timeout, ns) & "), duty cycle " & to_string(v_result.duty_cycle, C_PWM_DECIMAL_DIGITS) & "." & add_msg_delimiter(msg), scope, msg_id_panel);
      return;
    end if;

    -- Start values of the minimum and maximum, replaced by the first period
    v_result.min_period      := time'high;
    v_result.max_period      := 0 ns;
    v_result.min_active_time := time'high;
    v_result.max_active_time := 0 ns;
    v_result.min_duty_cycle  := 1.0;
    v_result.max_duty_cycle  := 0.0;
    for i in 1 to num_periods loop
      measure_period(pwm, terminate_loop, v_deadline, ERROR, C_PROC_NAME, msg, scope, config, v_period, v_active_time, v_timed_out,
                     v_terminated);
      if v_terminated then
        log_terminated(C_PROC_NAME, msg, scope, msg_id_panel);
        return;
      elsif v_timed_out then
        alert_missing_activity(i - 1, num_periods, v_timeout, C_PROC_NAME, msg, pwm, scope, config);
        return;
      end if;
      v_sum_period             := v_sum_period + v_period;
      v_sum_active             := v_sum_active + v_active_time;
      v_duty                   := duty_of(v_active_time, v_period);
      v_result.min_period      := minimum(v_result.min_period, v_period);
      v_result.max_period      := maximum(v_result.max_period, v_period);
      v_result.min_active_time := minimum(v_result.min_active_time, v_active_time);
      v_result.max_active_time := maximum(v_result.max_active_time, v_active_time);
      v_result.min_duty_cycle  := minimum(v_result.min_duty_cycle, v_duty);
      v_result.max_duty_cycle  := maximum(v_result.max_duty_cycle, v_duty);
    end loop;
    -- Mean values rounded to the nearest resolution unit; the duty cycle from the sums
    v_result.period      := units_to_time(time_to_units(v_sum_period) / real(num_periods));
    v_result.active_time := units_to_time(time_to_units(v_sum_active) / real(num_periods));
    v_result.duty_cycle  := duty_of(v_sum_active, v_sum_period);
    result               := v_result;
    -- Equal periods in the short form, as to_string() of the VVC result
    if v_result.min_period = v_result.max_period and v_result.min_active_time = v_result.max_active_time then
      log(config.id_for_bfm, C_PROC_NAME & "=> T " & to_string(v_result.period, ns) & ", t_on " & to_string(v_result.active_time, ns) &
          ", duty cycle " & to_string(v_result.duty_cycle, C_PWM_DECIMAL_DIGITS) & "." & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      log(config.id_for_bfm, C_PROC_NAME & "=> mean (min..max): T " & to_string(v_result.period, ns) & " (" &
          to_string(v_result.min_period, ns) & ".." & to_string(v_result.max_period, ns) & "), t_on " & to_string(v_result.active_time, ns) &
          " (" & to_string(v_result.min_active_time, ns) & ".." & to_string(v_result.max_active_time, ns) & "), duty cycle " &
          to_string(v_result.duty_cycle, C_PWM_DECIMAL_DIGITS) & " (" & to_string(v_result.min_duty_cycle, C_PWM_DECIMAL_DIGITS) & ".." & to_string(v_result.max_duty_cycle, C_PWM_DECIMAL_DIGITS) &
          ")." & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  procedure pwm_expect(
    constant period         : in time;
    constant active_time    : in time;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant num_periods    : in integer          := 1;
    constant timeout        : in time             := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level    := ERROR;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_NAME : string  := "pwm_expect(" & to_string(period, ns) & ", " & to_string(active_time, ns) & ", " & to_string(num_periods) & ")";
    constant C_CONSTANT  : boolean := active_time = 0 ns or active_time = period;
    variable v_timeout   : time;
    variable v_valid     : boolean;
  begin
    if not pwm_generation_is_valid(period, active_time, C_PROC_NAME, msg, scope, num_periods) then
      return;
    end if;
    v_timeout := resolve_timeout(timeout, period, num_periods, config);
    check_observe_parameters(proc_call      => C_PROC_NAME,
                             timeout        => v_timeout,
                             needs_window   => false,
                             time_tolerance => not C_CONSTANT,
                             duty_tolerance => false,
                             config         => config,
                             msg            => msg,
                             scope          => scope,
                             valid          => v_valid);
    if not v_valid then
      return;
    end if;

    if C_CONSTANT then
      -- A constant level is checked for num_periods periods; the timeout is not used
      check_constant_level(constant_level(active_time = period, config), num_periods * period, alert_level, C_PROC_NAME, msg, pwm,
                           terminate_loop, scope, msg_id_panel, config);
    else
      check_periods(period         => period,
                    active_time    => active_time,
                    duty           => 0.0,
                    check_duty     => false,
                    num_periods    => num_periods,
                    timeout        => v_timeout,
                    alert_level    => alert_level,
                    proc_call      => C_PROC_NAME,
                    msg            => msg,
                    pwm            => pwm,
                    terminate_loop => terminate_loop,
                    scope          => scope,
                    msg_id_panel   => msg_id_panel,
                    config         => config);
    end if;
  end procedure;

  procedure pwm_expect(
    constant duty           : in real;
    constant msg            : in string;
    signal   pwm            : in std_ulogic;
    signal   terminate_loop : in std_ulogic;
    constant num_periods    : in integer          := 1;
    constant timeout        : in time             := C_UNDEFINED_TIME;
    constant alert_level    : in t_alert_level    := ERROR;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_pwm_bfm_config := C_PWM_BFM_CONFIG_DEFAULT
  ) is
    constant C_PROC_NAME : string  := "pwm_expect(duty " & to_string(duty, C_PWM_DECIMAL_DIGITS) & ", " & to_string(num_periods) & ")";
    constant C_CONSTANT  : boolean := duty = 0.0 or duty = 1.0;
    variable v_timeout   : time;
    variable v_valid     : boolean;
  begin
    if duty < 0.0 or duty > 1.0 then
      alert(TB_ERROR, C_PROC_NAME & "=> Failed. duty must be within 0.0 to 1.0." & add_msg_delimiter(msg), scope);
      return;
    elsif num_periods < 1 then
      alert(TB_ERROR, C_PROC_NAME & "=> Failed. num_periods must be >= 1, was " & to_string(num_periods) & "." & add_msg_delimiter(msg), scope);
      return;
    end if;
    v_timeout := resolve_timeout(timeout, 0 ns, num_periods, config);
    check_observe_parameters(proc_call      => C_PROC_NAME,
                             timeout        => v_timeout,
                             needs_window   => C_CONSTANT,
                             time_tolerance => false,
                             duty_tolerance => not C_CONSTANT,
                             config         => config,
                             msg            => msg,
                             scope          => scope,
                             valid          => v_valid);
    if not v_valid then
      return;
    end if;

    if C_CONSTANT then
      -- A constant level is checked for the timeout as window
      check_constant_level(constant_level(duty = 1.0, config), v_timeout, alert_level, C_PROC_NAME, msg, pwm, terminate_loop, scope,
                           msg_id_panel, config);
    else
      check_periods(period         => 0 ns,
                    active_time    => 0 ns,
                    duty           => duty,
                    check_duty     => true,
                    num_periods    => num_periods,
                    timeout        => v_timeout,
                    alert_level    => alert_level,
                    proc_call      => C_PROC_NAME,
                    msg            => msg,
                    pwm            => pwm,
                    terminate_loop => terminate_loop,
                    scope          => scope,
                    msg_id_panel   => msg_id_panel,
                    config         => config);
    end if;
  end procedure;

end package body pwm_bfm_pkg;
