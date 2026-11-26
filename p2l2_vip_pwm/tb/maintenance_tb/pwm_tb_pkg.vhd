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
-- Description   : Support package of the PWM maintenance testbenches: an edge log filled by an edge-logger process, a
--                 reference model of the expected edges and stimulus segments for the observation tests. The model does not use pwm_bfm_pkg (only its enum types), so
--                 that a timing error in the BFM is not repeated in the expected values.
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library p2l2_vip_pwm;
use p2l2_vip_pwm.pwm_bfm_pkg.t_pwm_alignment;
use p2l2_vip_pwm.pwm_bfm_pkg.t_pwm_polarity;
use p2l2_vip_pwm.pwm_bfm_pkg.t_pwm_idle_level;

package pwm_tb_pkg is

  type t_edge is record
    time_stamp : time;
    level      : std_ulogic; -- the new level
  end record t_edge;
  type t_edge_array is array (natural range <>) of t_edge;

  -- Parameters of one period of the reference waveform
  type t_period_param is record
    period      : time;
    active_time : time;
  end record t_period_param;
  type t_period_param_array is array (natural range <>) of t_period_param;

  constant C_MAX_EDGES : positive := 8192;

  type t_edge_log is protected
    procedure clear;
    procedure add(
      constant time_stamp : in time;
      constant level      : in std_ulogic);
    impure function count return natural;
    impure function get(
      constant idx : in natural) return t_edge;
  end protected t_edge_log;

  function tb_active_level(
    constant polarity : in t_pwm_polarity) return std_ulogic;

  function tb_idle_value(
    constant polarity   : in t_pwm_polarity;
    constant idle_level : in t_pwm_idle_level) return std_ulogic;

  -- num_periods times the same period
  -- Time in resolution units, as real (time / time is an integer and overflows above 2**31 units)
  function tb_units(
    constant value : in time) return real;

  function repeat_period(
    constant period      : in time;
    constant active_time : in time;
    constant num_periods : in positive) return t_period_param_array;

  -- Edges expected when the periods in 'params' are generated back to back from 'start', starting from
  -- 'initial_level' and returning to 'idle' after the last period (for center alignment, an odd t_off gives the extra unit to the second gap).
  function expected_edges(
    constant start         : in time;
    constant initial_level : in std_ulogic;
    constant params        : in t_period_param_array;
    constant alignment     : in t_pwm_alignment;
    constant active        : in std_ulogic;
    constant idle          : in std_ulogic) return t_edge_array;

  -- Compares the logged edges with the expected edges: number, time and level of each edge. Reports the first
  -- mismatch only and then logs all logged edges.
  procedure check_edges(
    variable edge_log : inout t_edge_log;
    constant expected : in t_edge_array;
    constant msg      : in string;
    constant scope    : in string := C_TB_SCOPE_DEFAULT);

  -- For jittered waveforms: the logged edges must have the number and levels of the ideal edges 'expected', each edge
  -- 0 ns to jitter after its ideal time, and consecutive edges at least one resolution unit apart. Reports the first
  -- failure of each kind and logs the smallest and largest offset found.
  procedure check_jittered_edges(
    variable edge_log : inout t_edge_log;
    constant expected : in t_edge_array;
    constant jitter   : in time;
    constant msg      : in string;
    constant scope    : in string := C_TB_SCOPE_DEFAULT);

  -- Stimulus of the observation tests: segments of a level held for a duration, driven one after the other
  type t_segment is record
    level    : std_ulogic;
    duration : time;
  end record t_segment;
  type t_segment_array is array (natural range <>) of t_segment;

  constant C_MAX_SEGMENTS : positive := 512;

  -- One segment
  function seg(
    constant level    : in std_ulogic;
    constant duration : in time) return t_segment_array;

  -- num_periods left-aligned periods: 'active' for active_time, then the other level for the rest of the period
  function pwm_wave(
    constant period      : in time;
    constant active_time : in time;
    constant num_periods : in positive;
    constant active      : in std_ulogic := '1') return t_segment_array;

end package pwm_tb_pkg;

package body pwm_tb_pkg is

  type t_edge_log is protected body
    variable v_edges : t_edge_array(0 to C_MAX_EDGES - 1);
    variable v_count : natural := 0;

    procedure clear is
    begin
      v_count := 0;
    end procedure;

    procedure add(
      constant time_stamp : in time;
      constant level      : in std_ulogic) is
    begin
      if v_count < C_MAX_EDGES then
        v_edges(v_count) := (time_stamp, level);
      else
        alert(TB_ERROR, "Edge log full (" & to_string(C_MAX_EDGES) & " edges)");
      end if;
      v_count := v_count + 1;
    end procedure;

    impure function count return natural is
    begin
      return v_count;
    end function;

    impure function get(
      constant idx : in natural) return t_edge is
    begin
      return v_edges(idx);
    end function;
  end protected body t_edge_log;

  function tb_active_level(
    constant polarity : in t_pwm_polarity) return std_ulogic is
  begin
    if polarity = ACTIVE_HIGH then
      return '1';
    end if;
    return '0';
  end function;

  function tb_idle_value(
    constant polarity   : in t_pwm_polarity;
    constant idle_level : in t_pwm_idle_level) return std_ulogic is
    constant C_ACTIVE : std_ulogic := tb_active_level(polarity);
  begin
    case idle_level is
      when IDLE_INACTIVE => return not C_ACTIVE;
      when IDLE_ACTIVE   => return C_ACTIVE;
      when IDLE_HIGH_Z   => return 'Z';
    end case;
  end function;

  function tb_units(
    constant value : in time) return real is
    constant C_RESOLUTION : time    := std.env.resolution_limit;
    constant C_NUM_NS     : integer := value / 1 ns;
  begin
    return real(C_NUM_NS) * real(1 ns / C_RESOLUTION) + real((value - C_NUM_NS * 1 ns) / C_RESOLUTION);
  end function;

  function repeat_period(
    constant period      : in time;
    constant active_time : in time;
    constant num_periods : in positive) return t_period_param_array is
    constant C_PARAMS : t_period_param_array(1 to num_periods) := (others => (period, active_time));
  begin
    return C_PARAMS;
  end function;

  function expected_edges(
    constant start         : in time;
    constant initial_level : in std_ulogic;
    constant params        : in t_period_param_array;
    constant alignment     : in t_pwm_alignment;
    constant active        : in std_ulogic;
    constant idle          : in std_ulogic) return t_edge_array is
    constant C_RESOLUTION : time       := std.env.resolution_limit;
    constant C_INACTIVE   : std_ulogic := not active;
    variable v_edges      : t_edge_array(0 to 3 * params'length);
    variable v_num        : natural    := 0;
    variable v_level      : std_ulogic := initial_level;
    variable v_time       : time       := start;
    variable v_off_time   : time;
    variable v_first_gap  : time;

    -- The line is at 'level' for 'duration' from v_time on
    procedure segment(
      constant level    : in std_ulogic;
      constant duration : in time) is
    begin
      if duration > 0 ns then
        if level /= v_level then
          v_edges(v_num) := (v_time, level);
          v_num          := v_num + 1;
          v_level        := level;
        end if;
        v_time := v_time + duration;
      end if;
    end procedure;
  begin
    for i in params'range loop
      v_off_time := params(i).period - params(i).active_time;
      case alignment is
        when LEFT_ALIGNED =>
          segment(active, params(i).active_time);
          segment(C_INACTIVE, v_off_time);
        when RIGHT_ALIGNED =>
          segment(C_INACTIVE, v_off_time);
          segment(active, params(i).active_time);
        when CENTER_ALIGNED =>
          v_first_gap := v_off_time / 2; -- whole resolution units, rounded down
          segment(C_INACTIVE, v_first_gap);
          segment(active, params(i).active_time);
          segment(C_INACTIVE, v_off_time - v_first_gap);
      end case;
    end loop;
    if idle /= v_level then
      v_edges(v_num) := (v_time, idle);
      v_num          := v_num + 1;
    end if;
    return v_edges(0 to v_num - 1);
  end function;

  procedure check_edges(
    variable edge_log : inout t_edge_log;
    constant expected : in t_edge_array;
    constant msg      : in string;
    constant scope    : in string := C_TB_SCOPE_DEFAULT) is
    variable v_ok   : boolean;
    variable v_edge : t_edge;
  begin
    v_ok := check_value(edge_log.count, expected'length, ERROR, "number of edges: " & msg, scope, ID_SEQUENCER_SUB);
    for i in 0 to minimum(edge_log.count, expected'length) - 1 loop
      exit when not v_ok;
      v_edge := edge_log.get(i);
      v_ok   := check_value(v_edge.time_stamp, expected(expected'low + i).time_stamp, ERROR,
                            "time of edge " & to_string(i) & ": " & msg, scope, ID_NEVER);
      if v_ok then
        v_ok := check_value(v_edge.level, expected(expected'low + i).level, MATCH_EXACT, ERROR,
                            "level of edge " & to_string(i) & ": " & msg, scope, ID_NEVER);
      end if;
    end loop;
    if not v_ok then
      for i in 0 to minimum(edge_log.count, C_MAX_EDGES) - 1 loop
        v_edge := edge_log.get(i);
        log(ID_SEQUENCER, "logged edge " & to_string(i) & ": " & to_string(v_edge.time_stamp) & " -> " &
                          to_string(v_edge.level), scope);
      end loop;
    end if;
  end procedure;

  procedure check_jittered_edges(
    variable edge_log : inout t_edge_log;
    constant expected : in t_edge_array;
    constant jitter   : in time;
    constant msg      : in string;
    constant scope    : in string := C_TB_SCOPE_DEFAULT) is
    constant C_RESOLUTION : time := std.env.resolution_limit;
    variable v_edge       : t_edge;
    variable v_prev       : t_edge;
    variable v_offset     : time;
    variable v_min_offset : time    := 0 ns;
    variable v_max_offset : time    := 0 ns;
    variable v_level_ok   : boolean := true;
    variable v_time_ok    : boolean := true;
    variable v_space_ok   : boolean := true;
  begin
    if not check_value(edge_log.count, expected'length, ERROR, "number of edges: " & msg, scope, ID_SEQUENCER_SUB) then
      return;
    end if;
    for i in 0 to expected'length - 1 loop
      v_edge   := edge_log.get(i);
      v_offset := v_edge.time_stamp - expected(expected'low + i).time_stamp;
      v_min_offset := minimum(v_min_offset, v_offset);
      v_max_offset := maximum(v_max_offset, v_offset);
      if v_level_ok then
        v_level_ok := check_value(v_edge.level, expected(expected'low + i).level, MATCH_EXACT, ERROR,
                                  "level of edge " & to_string(i) & ": " & msg, scope, ID_NEVER);
      end if;
      if v_time_ok then
        v_time_ok := check_value_in_range(v_offset, 0 ns, jitter, ERROR,
                                          "offset of edge " & to_string(i) & " from its ideal time: " & msg, scope, ID_NEVER);
      end if;
      if v_space_ok and i > 0 then
        v_space_ok := check_value(v_edge.time_stamp - v_prev.time_stamp >= C_RESOLUTION, ERROR,
                                  "edge " & to_string(i) & " at least one resolution unit after edge " & to_string(i - 1) &
                                  " (" & to_string(v_prev.time_stamp) & " -> " & to_string(v_edge.time_stamp) & "): " & msg,
                                  scope, ID_NEVER);
      end if;
      v_prev := v_edge;
    end loop;
    log(ID_SEQUENCER_SUB, "Edge offsets from the ideal times: " & to_string(v_min_offset) & " to " & to_string(v_max_offset) &
                          ", allowed 0 ns to " & to_string(jitter) & ". '" & msg & "'", scope);
  end procedure;

  function seg(
    constant level    : in std_ulogic;
    constant duration : in time) return t_segment_array is
    constant C_SEGMENT : t_segment_array(0 to 0) := (0 => (level, duration));
  begin
    return C_SEGMENT;
  end function;

  function pwm_wave(
    constant period      : in time;
    constant active_time : in time;
    constant num_periods : in positive;
    constant active      : in std_ulogic := '1') return t_segment_array is
    variable v_segments : t_segment_array(0 to 2 * num_periods - 1);
  begin
    for i in 0 to num_periods - 1 loop
      v_segments(2 * i)     := (active, active_time);
      v_segments(2 * i + 1) := (not active, period - active_time);
    end loop;
    return v_segments;
  end function;

end package body pwm_tb_pkg;

--==========================================================================================
-- Edge log of the test harness. Separate package: a shared variable of a protected type cannot be declared before the
-- protected type body.
--==========================================================================================
use work.pwm_tb_pkg.all;

package pwm_th_pkg is
  -- Filled by the edge loggers in pwm_th (every event on the loopback line and on the second channel), read by pwm_vvc_tb
  shared variable shared_th_edge_log   : t_edge_log;
  shared variable shared_th_edge_log_b : t_edge_log;
end package pwm_th_pkg;
