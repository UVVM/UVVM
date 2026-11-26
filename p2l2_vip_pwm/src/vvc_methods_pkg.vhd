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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.pwm_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.transaction_pkg.all;

--==========================================================================================
--==========================================================================================
package vvc_methods_pkg is

  --==========================================================================================
  -- Types and constants for the PWM VVC
  --==========================================================================================
  constant C_VVC_NAME     : string := "PWM_VVC";

  signal PWM_VVCT          : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT         : t_vvc_target_record is PWM_VVCT;
  alias  t_bfm_config is t_pwm_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_PWM_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => WARNING
  );

  type t_vvc_config is record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;           -- DEPRECATED: will be removed in v3. Use entity generic constants instead.
    cmd_queue_count_threshold             : natural;           -- DEPRECATED: will be removed in v3. Use entity generic constants instead.
    cmd_queue_count_threshold_severity    : t_alert_level;     -- DEPRECATED: will be removed in v3. Use entity generic constants instead.
    result_queue_count_max                : natural;           -- DEPRECATED: will be removed in v3. Use entity generic constants instead.
    result_queue_count_threshold          : natural;           -- DEPRECATED: will be removed in v3. Use entity generic constants instead.
    result_queue_count_threshold_severity : t_alert_level;     -- DEPRECATED: will be removed in v3. Use entity generic constants instead.
    bfm_config                            : t_bfm_config;      -- Configuration for the BFM. See BFM quick reference.
    msg_id_panel                          : t_msg_id_panel;    -- VVC dedicated message ID panel.
  end record t_vvc_config;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_PWM_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_PWM_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    bfm_config                            => C_PWM_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT
  );

  type t_vvc_status is record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record t_vvc_status;

  type t_vvc_status_array is array (natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
  );

  shared variable shared_pwm_vvc_config : t_vvc_config_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_PWM_VVC_CONFIG_DEFAULT);
  shared variable shared_pwm_vvc_status : t_vvc_status_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_VVC_STATUS_DEFAULT);

  --==========================================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --==========================================================================================

  -- Generator role: generates num_periods complete periods, then drives the idle level. Completes at the end of the
  -- last period. A duty cycle or counter value is converted with pwm_duty_to_active_time() or pwm_count_to_active_time().
  procedure pwm_generate(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant num_periods         : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Generator role: starts continuous generation. Completes when the first period begins.
  procedure pwm_start(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Generator role: changes period and duty cycle of the continuous generation. Completes when the new values took
  -- effect at the next period boundary. terminate_current_command() withdraws an update that has not taken effect.
  procedure pwm_update(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Generator role: ends the continuous generation at the next period boundary, then drives the idle level.
  -- terminate_current_command() withdraws the stop request; the generation continues.
  procedure pwm_stop(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Generator role: ends a continuous run at once and drives the idle level. Queued like every command, so it cuts
  -- the waveform at once only if no command is queued before it. terminate_current_command() ends a pwm_generate().
  procedure pwm_abort(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Generator role: drives the idle level of the current config at once. Not allowed during a continuous generation.
  -- The VVC drives the idle level by itself only at time 0 (from GC_PWM_BFM_CONFIG) and at the end of each run, so call
  -- this after changing polarity or idle_level in shared_pwm_vvc_config, before the next run.
  procedure pwm_drive_idle(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Observer role: measures num_periods complete periods and returns their mean values (BFM pwm_measure()). The result
  -- is fetched with fetch_result().
  procedure pwm_measure(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant num_periods         : in    integer        := 1;
    constant timeout             : in    time           := C_UNDEFINED_TIME;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Observer role: checks num_periods consecutive periods against period and active_time (BFM pwm_expect())
  procedure pwm_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant msg                 : in    string;
    constant num_periods         : in    integer        := 1;
    constant timeout             : in    time           := C_UNDEFINED_TIME;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- Observer role: checks the duty cycle of num_periods consecutive periods (BFM pwm_expect() with duty)
  procedure pwm_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant duty                : in    real;
    constant msg                 : in    string;
    constant num_periods         : in    integer        := 1;
    constant timeout             : in    time           := C_UNDEFINED_TIME;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  --==========================================================================================
  -- Transaction info methods
  --==========================================================================================
  procedure set_global_vvc_transaction_info (
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure reset_vvc_transaction_info (
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record
  );

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  --==========================================================================================
  -- Methods dedicated to this VVC
  --==========================================================================================

  -- Internal: queues a command. Fields a command does not use keep their defaults.
  procedure send_command(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant proc_call           : in    string;
    constant operation           : in    t_operation;
    constant msg                 : in    string;
    constant scope               : in    string;
    constant parent_msg_id_panel : in    t_msg_id_panel;
    constant period              : in    time          := 0 ns;
    constant active_time         : in    time          := 0 ns;
    constant duty                : in    real          := 0.0;
    constant num_periods         : in    integer       := 0;
    constant timeout             : in    time          := C_UNDEFINED_TIME;
    constant alert_level         : in    t_alert_level := ERROR
  ) is
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, operation);
    shared_vvc_cmd.period              := period;
    shared_vvc_cmd.active_time         := active_time;
    shared_vvc_cmd.duty                := duty;
    shared_vvc_cmd.num_periods         := num_periods;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  -- Internal: the timeout argument for C_PROC_CALL ("" when not set)
  function timeout_to_string(
    constant timeout : time
  ) return string is
  begin
    if timeout = C_UNDEFINED_TIME then
      return "";
    end if;
    return ", timeout " & to_string(timeout, ns);
  end function;

  procedure pwm_generate(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant num_periods         : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_generate";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ", " & to_string(period, ns) & ", " &
                                     to_string(active_time, ns) & ", " & to_string(num_periods) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, GENERATE_PERIODS, msg, scope, parent_msg_id_panel,
                 period      => period,
                 active_time => active_time,
                 num_periods => num_periods);
  end procedure;

  procedure pwm_start(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_start";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ", " & to_string(period, ns) & ", " &
                                     to_string(active_time, ns) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, START, msg, scope, parent_msg_id_panel,
                 period      => period,
                 active_time => active_time);
  end procedure;

  procedure pwm_update(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_update";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ", " & to_string(period, ns) & ", " &
                                     to_string(active_time, ns) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, UPDATE, msg, scope, parent_msg_id_panel,
                 period      => period,
                 active_time => active_time);
  end procedure;

  procedure pwm_stop(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_stop";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, STOP, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure pwm_abort(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_abort";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, ABORT, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure pwm_drive_idle(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_drive_idle";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, DRIVE_IDLE, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure pwm_measure(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant msg                 : in    string;
    constant num_periods         : in    integer        := 1;
    constant timeout             : in    time           := C_UNDEFINED_TIME;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_measure";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ", " & to_string(num_periods) &
                                     timeout_to_string(timeout) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, MEASURE, msg, scope, parent_msg_id_panel,
                 num_periods => num_periods,
                 timeout     => timeout);
  end procedure;

  procedure pwm_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant period              : in    time;
    constant active_time         : in    time;
    constant msg                 : in    string;
    constant num_periods         : in    integer        := 1;
    constant timeout             : in    time           := C_UNDEFINED_TIME;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_expect";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ", " & to_string(period, ns) & ", " &
                                     to_string(active_time, ns) & ", " & to_string(num_periods) & timeout_to_string(timeout) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, EXPECT, msg, scope, parent_msg_id_panel,
                 period      => period,
                 active_time => active_time,
                 num_periods => num_periods,
                 timeout     => timeout,
                 alert_level => alert_level);
  end procedure;

  procedure pwm_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in    integer;
    constant duty                : in    real;
    constant msg                 : in    string;
    constant num_periods         : in    integer        := 1;
    constant timeout             : in    time           := C_UNDEFINED_TIME;
    constant alert_level         : in    t_alert_level  := ERROR;
    constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant C_PROC_NAME : string := "pwm_expect";
    constant C_PROC_CALL : string := C_PROC_NAME & "(" & to_string(VVCT, vvc_instance_idx) & ", duty " & to_string(duty, C_PWM_DECIMAL_DIGITS) & ", " &
                                     to_string(num_periods) & timeout_to_string(timeout) & ")";
  begin
    send_command(VVCT, vvc_instance_idx, C_PROC_CALL, EXPECT_DUTY, msg, scope, parent_msg_id_panel,
                 duty        => duty,
                 num_periods => num_periods,
                 timeout     => timeout,
                 alert_level => alert_level);
  end procedure;

  --==========================================================================================
  -- Transaction info methods
  --==========================================================================================
  procedure set_global_vvc_transaction_info (
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    case vvc_cmd.operation is
      when GENERATE_PERIODS | START | UPDATE | STOP | ABORT | DRIVE_IDLE | MEASURE | EXPECT | EXPECT_DUTY =>
        vvc_transaction_info_group.bt.operation          := vvc_cmd.operation;
        vvc_transaction_info_group.bt.period             := vvc_cmd.period;
        vvc_transaction_info_group.bt.active_time        := vvc_cmd.active_time;
        vvc_transaction_info_group.bt.duty               := vvc_cmd.duty;
        vvc_transaction_info_group.bt.num_periods        := vvc_cmd.num_periods;
        vvc_transaction_info_group.bt.vvc_meta.msg       := vvc_cmd.msg;
        vvc_transaction_info_group.bt.vvc_meta.cmd_idx   := vvc_cmd.cmd_idx;
        vvc_transaction_info_group.bt.transaction_status := transaction_status;
        gen_pulse(vvc_transaction_info_trigger, 0 ns, "pulsing global vvc transaction info trigger", scope, ID_NEVER);

      when others =>
        alert(TB_ERROR, "VVC operation not recognized", scope);
    end case;

    wait for 0 ns;
  end procedure set_global_vvc_transaction_info;

  procedure reset_vvc_transaction_info (
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record
  ) is
  begin
    case vvc_cmd.operation is
      when GENERATE_PERIODS | START | UPDATE | STOP | ABORT | DRIVE_IDLE | MEASURE | EXPECT | EXPECT_DUTY =>
        vvc_transaction_info_group.bt := C_BASE_TRANSACTION_SET_DEFAULT;

      when others =>
        null;
    end case;

    wait for 0 ns;
  end procedure reset_vvc_transaction_info;

end package body vvc_methods_pkg;
