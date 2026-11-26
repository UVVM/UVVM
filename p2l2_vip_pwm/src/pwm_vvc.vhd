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
use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;
use work.transaction_pkg.all;

--==========================================================================================
--==========================================================================================
entity pwm_vvc is
  generic (
    GC_INSTANCE_IDX                          : natural                   := 1;
    GC_ROLE                                  : t_pwm_role                := GENERATOR; -- Fixed at elaboration
    GC_PWM_BFM_CONFIG                        : t_pwm_bfm_config          := C_PWM_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural                   := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                   := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level             := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural                   := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                   := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level             := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
  port (
    -- GENERATOR: driven with the idle level from time 0 and the waveform. OBSERVER: always driven 'Z', only read.
    pwm_vvc_if                  : inout std_logic := 'Z'
  );
end entity pwm_vvc;

--==========================================================================================
--==========================================================================================
architecture behave of pwm_vvc is

  constant C_SCOPE      : string       := get_scope_for_log(C_VVC_NAME, GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);

  signal executor_is_busy                   : boolean := false;
  signal queue_is_increasing                : boolean := false;
  signal last_cmd_idx_executed              : natural := 0;
  signal terminate_current_cmd              : t_flag_record;
  signal entry_num_in_vvc_activity_register : integer;

  -- Generator role: run state shared by the executor and p_waveform
  type t_run_mode is (IDLE, BOUNDED, CONTINUOUS);
  type t_run_request is record
    idx         : natural;              -- incremented with every request
    period      : time;
    active_time : time;
    num_periods : natural;              -- 0: continuous
  end record t_run_request;
  constant C_RUN_REQUEST_DEFAULT : t_run_request := (0, 0 ns, 0 ns, 0);

  -- Executor -> p_waveform
  signal start_req     : t_run_request := C_RUN_REQUEST_DEFAULT; -- GENERATE_PERIODS, START
  signal update_req    : t_run_request := C_RUN_REQUEST_DEFAULT; -- UPDATE, latched at the next period boundary
  signal update_cancel : natural       := 0;     -- idx of an update request withdrawn by terminate_current_command
  signal stop_req      : natural       := 0;     -- incremented by STOP, checked at the period boundaries
  signal stop_cancel   : natural       := 0;     -- value of stop_req whose stop was withdrawn by terminate_current_command
  signal abort_req     : boolean       := false; -- toggled by ABORT and terminate_current_command
  signal idle_req      : natural       := 0;     -- incremented by DRIVE_IDLE
  -- p_waveform -> executor
  signal run_mode      : t_run_mode    := IDLE;
  signal start_ack     : natural       := 0;     -- idx of the last start request whose first period has begun
  signal update_ack    : natural       := 0;     -- idx of the last update request latched at a period boundary
  signal idle_ack      : natural       := 0;     -- value of the last idle_req served
  signal idle_driven   : std_ulogic    := 'U';   -- the idle value last driven, to detect a config change since

  -- Instantiation of the element dedicated executor
  shared variable command_queue : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable result_queue  : work.td_result_queue_pkg.t_generic_queue;

  alias vvc_config : t_vvc_config is shared_pwm_vvc_config(GC_INSTANCE_IDX);
  alias vvc_status : t_vvc_status is shared_pwm_vvc_status(GC_INSTANCE_IDX);
  -- Transaction info
  alias vvc_transaction_info_trigger        : std_logic           is global_pwm_vvc_transaction_trigger(GC_INSTANCE_IDX);
  alias vvc_transaction_info                : t_transaction_group is shared_pwm_vvc_transaction_info(GC_INSTANCE_IDX);

begin

  --==========================================================================================
  -- Constructor
  -- - Set up the defaults and show constructor if enabled
  --==========================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, GC_PWM_BFM_CONFIG,
                  GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
                  GC_RESULT_QUEUE_COUNT_MAX, GC_RESULT_QUEUE_COUNT_THRESHOLD, GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
                  C_VVC_MAX_INSTANCE_NUM);
  --==========================================================================================

  --==========================================================================================
  -- Command interpreter
  -- - Interpret, decode and acknowledge commands from the central sequencer
  --==========================================================================================
  p_cmd_interpreter : process is
    variable v_cmd_has_been_acked : boolean; -- Indicates if acknowledge_cmd() has been called for the current shared_vvc_cmd
    variable v_local_vvc_cmd      : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;
    variable v_msg_id_panel       : t_msg_id_panel;
    variable v_temp_msg_id_panel  : t_msg_id_panel; --UVVM: temporary fix for HVVC, remove in v3.0
  begin

    -- 0. Initialize the process prior to first command
    work.td_vvc_entity_support_pkg.initialize_interpreter(terminate_current_cmd, global_awaiting_completion);
    -- initialise shared_vvc_last_received_cmd_idx for channel and instance
    shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := 0;

    -- Register VVC in vvc activity register
    entry_num_in_vvc_activity_register <= shared_vvc_activity_register.priv_register_vvc(name     => C_VVC_NAME,
                                                                                         instance => GC_INSTANCE_IDX);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    -- Then for every single command from the sequencer
    loop  -- basically as long as new commands are received

      -- 1. wait until command targeted at this VVC. Must match VVC name, instance and channel (if applicable)
      --    releases global semaphore
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.await_cmd_from_sequencer(C_VVC_LABELS, vvc_config, THIS_VVCT, VVC_BROADCAST, global_vvc_busy, global_vvc_ack, v_local_vvc_cmd);
      v_cmd_has_been_acked := false; -- Clear flag
      -- Update shared_vvc_last_received_cmd_idx with received command index
      shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := v_local_vvc_cmd.cmd_idx;
      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel := get_msg_id_panel(v_local_vvc_cmd, vvc_config);

      -- 2a. Put command on the executor if intended for the executor
      -------------------------------------------------------------------------
      if v_local_vvc_cmd.command_type = QUEUED then
        work.td_vvc_entity_support_pkg.put_command_on_queue(v_local_vvc_cmd, command_queue, vvc_status, queue_is_increasing);

      -- 2b. Otherwise command is intended for immediate response
      -------------------------------------------------------------------------
      elsif v_local_vvc_cmd.command_type = IMMEDIATE then

        --UVVM: temporary fix for HVVC, remove two lines below in v3.0
        if v_local_vvc_cmd.operation /= DISABLE_LOG_MSG and v_local_vvc_cmd.operation /= ENABLE_LOG_MSG then
          v_temp_msg_id_panel     := vvc_config.msg_id_panel;
          vvc_config.msg_id_panel := v_msg_id_panel;
        end if;

        case v_local_vvc_cmd.operation is

          when DISABLE_LOG_MSG =>
            uvvm_util.methods_pkg.disable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when ENABLE_LOG_MSG =>
            uvvm_util.methods_pkg.enable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when FLUSH_COMMAND_QUEUE =>
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, command_queue, vvc_config, vvc_status, C_VVC_LABELS);

          when TERMINATE_CURRENT_COMMAND =>
            work.td_vvc_entity_support_pkg.interpreter_terminate_current_command(v_local_vvc_cmd, vvc_config, C_VVC_LABELS, terminate_current_cmd, executor_is_busy);

          when FETCH_RESULT =>
            work.td_vvc_entity_support_pkg.interpreter_fetch_result(result_queue, entry_num_in_vvc_activity_register, v_local_vvc_cmd, vvc_config, C_VVC_LABELS, shared_vvc_response);

          when others =>
            tb_error("Unsupported command received for IMMEDIATE execution: '" & to_string(v_local_vvc_cmd.operation) & "'", C_SCOPE);

        end case;

        --UVVM: temporary fix for HVVC, remove line below in v3.0
        if v_local_vvc_cmd.operation /= DISABLE_LOG_MSG and v_local_vvc_cmd.operation /= ENABLE_LOG_MSG then
          vvc_config.msg_id_panel := v_temp_msg_id_panel;
        end if;

      else
        tb_error("command_type is not IMMEDIATE or QUEUED", C_SCOPE);
      end if;

      -- 3. Acknowledge command after running or queuing the command
      -------------------------------------------------------------------------
      if not v_cmd_has_been_acked then
        work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack, v_local_vvc_cmd.cmd_idx);
      end if;

    end loop;
    wait;
  end process p_cmd_interpreter;
  --==========================================================================================

  --==========================================================================================
  -- Command executor
  -- - Fetch and execute the commands
  --==========================================================================================
  p_cmd_executor : process is
    constant C_EXECUTOR_ID                            : natural := 0;
    variable v_cmd                                    : t_vvc_cmd_record;
    variable v_result                                 : t_vvc_result; -- See vvc_cmd_pkg
    variable v_timestamp_start_of_current_bfm_access  : time    := 0 ns;
    variable v_timestamp_start_of_last_bfm_access     : time    := 0 ns;
    variable v_timestamp_end_of_last_bfm_access       : time    := 0 ns;
    variable v_command_is_bfm_access                  : boolean := false;
    variable v_prev_command_was_bfm_access            : boolean := false;
    variable v_msg_id_panel                           : t_msg_id_panel;
    variable v_request_idx                            : natural;

    -- Wrong role: an ERROR, and the command is skipped (as I2C master commands in slave mode)
    impure function role_is(
      constant role : t_pwm_role
    ) return boolean is
    begin
      if GC_ROLE /= role then
        alert(ERROR, to_string(v_cmd.proc_call) & " called when VVC is in " & to_upper(to_string(GC_ROLE)) & " role." & format_msg(v_cmd), C_SCOPE);
        return false;
      end if;
      return true;
    end function;

    -- Run-state error: a TB_ERROR, and the command is skipped
    impure function run_mode_is(
      constant expected : t_run_mode;
      constant problem  : string
    ) return boolean is
    begin
      if run_mode /= expected then
        alert(TB_ERROR, to_string(v_cmd.proc_call) & "=> Failed. " & problem & format_msg(v_cmd), C_SCOPE);
        return false;
      end if;
      return true;
    end function;

    -- Parameter check of GENERATE_PERIODS, START and UPDATE with the BFM rules. Raises at most one TB_ERROR.
    -- The defaults are valid values, i.e. not checked.
    impure function parameters_are_valid(
      constant num_periods : integer := 1;
      constant jitter      : time    := 0 ns
    ) return boolean is
    begin
      return pwm_generation_is_valid(v_cmd.period, v_cmd.active_time, to_string(v_cmd.proc_call), format_msg(v_cmd), C_SCOPE, num_periods,
                                     jitter);
    end function;

    -- Generator settings for the log
    impure function config_to_string return string is
    begin
      return to_upper(to_string(vvc_config.bfm_config.polarity)) & ", " & to_upper(to_string(vvc_config.bfm_config.alignment)) & ", " &
             to_upper(to_string(vvc_config.bfm_config.idle_level)) & ", jitter " & to_string(vvc_config.bfm_config.jitter, ns);
    end function;

    -- Starts a run in p_waveform and waits until its first period has begun
    procedure start_run(
      constant num_periods : natural
    ) is
    begin
      v_request_idx := start_req.idx + 1;
      start_req     <= (v_request_idx, v_cmd.period, v_cmd.active_time, num_periods);
      wait until start_ack = v_request_idx;
    end procedure;

    -- Aborts the run in p_waveform: idle level at once
    procedure abort_run is
    begin
      abort_req <= not abort_req;
      wait until run_mode = IDLE;
    end procedure;

    -- Transaction info of the current command
    procedure set_transaction_info(
      constant status : t_transaction_status
    ) is
    begin
      set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, status, C_SCOPE);
    end procedure;

    procedure log_command(
      constant result : string
    ) is
    begin
      log(vvc_config.bfm_config.id_for_bfm, to_string(v_cmd.proc_call) & " " & result & "." & format_msg(v_cmd), C_SCOPE, v_msg_id_panel);
    end procedure;

    -- As the BFM logs a terminated observation
    procedure log_terminated is
    begin
      log(ID_TERMINATE_CMD, to_string(v_cmd.proc_call) & "=> terminated." & format_msg(v_cmd), C_SCOPE, v_msg_id_panel);
    end procedure;

    -- Warns if polarity or idle_level changed since the idle level was last driven: the line is not at the idle level
    -- of the current config, so the first edge of the run may be missing
    procedure check_idle_level is
      constant C_IDLE : std_ulogic := pwm_idle_value(vvc_config.bfm_config);
    begin
      if idle_driven /= C_IDLE then
        alert(WARNING, to_string(v_cmd.proc_call) & "=> The line is at the idle level '" & to_string(idle_driven) &
              "' of an earlier config, the current config has '" & to_string(C_IDLE) &
              "'. Call pwm_drive_idle() after changing polarity or idle_level." & format_msg(v_cmd), C_SCOPE);
      end if;
    end procedure;

  begin

    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);

    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop

      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_cmd_idx_executed, command_queue.is_empty(VOID), C_SCOPE);

      -- 1. Set defaults, fetch command and log
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing, executor_is_busy, C_VVC_LABELS);

      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_cmd_idx_executed, command_queue.is_empty(VOID), C_SCOPE);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);

      -- Check if command is a BFM access
      v_prev_command_was_bfm_access := v_command_is_bfm_access; -- save for inter_bfm_delay
      -- UPDATE, STOP and ABORT act on a running generation and DRIVE_IDLE only on the idle level; they are not delayed
      if v_cmd.operation = GENERATE_PERIODS or v_cmd.operation = START or v_cmd.operation = MEASURE or
         v_cmd.operation = EXPECT or v_cmd.operation = EXPECT_DUTY then
        v_command_is_bfm_access := true;
      else
        v_command_is_bfm_access := false;
      end if;

      -- Insert delay if needed
      work.td_vvc_entity_support_pkg.insert_inter_bfm_delay_if_requested(vvc_config                         => vvc_config,
                                                                         command_is_bfm_access              => v_prev_command_was_bfm_access,
                                                                         timestamp_start_of_last_bfm_access => v_timestamp_start_of_last_bfm_access,
                                                                         timestamp_end_of_last_bfm_access   => v_timestamp_end_of_last_bfm_access,
                                                                         scope                              => C_SCOPE,
                                                                         msg_id_panel                       => v_msg_id_panel);

      if v_command_is_bfm_access then
        v_timestamp_start_of_current_bfm_access := now;
      end if;

      -- 2. Execute the fetched command
      -------------------------------------------------------------------------
      case v_cmd.operation is  -- Only operations in the dedicated record are relevant

        -- VVC dedicated operations
        --===================================

        -- Generator role. The waveform is driven by p_waveform; the executor only requests and awaits.
        when GENERATE_PERIODS =>
          if role_is(GENERATOR) and run_mode_is(IDLE, "Not allowed while a continuous generation is active.") and
             parameters_are_valid(v_cmd.num_periods, vvc_config.bfm_config.jitter) then
            set_transaction_info(IN_PROGRESS);
            check_idle_level;
            start_run(v_cmd.num_periods);
            log_command("started (" & config_to_string & ")");
            wait until run_mode = IDLE or terminate_current_cmd.is_active = '1';
            if run_mode /= IDLE then
              -- terminate_current_command: idle level at once
              abort_run;
              log_terminated;
            else
              log_command("completed");
            end if;
            set_transaction_info(COMPLETED);
          end if;

        when START =>
          if role_is(GENERATOR) and run_mode_is(IDLE, "A continuous generation is already active.") and
             parameters_are_valid(jitter => vvc_config.bfm_config.jitter) then
            set_transaction_info(IN_PROGRESS);
            check_idle_level;
            start_run(0);
            log_command("started (" & config_to_string & ")");
            set_transaction_info(COMPLETED);
          end if;

        -- terminate_current_command withdraws a pending UPDATE or STOP. Unless the period boundary has taken the request
        -- in the same delta cycle: then the command completed, which shows after one delta cycle.
        -- UPDATE does not check config.jitter: a running generation keeps its config while the jitter is invalid.
        when UPDATE =>
          if role_is(GENERATOR) and run_mode_is(CONTINUOUS, "No continuous generation is active.") and
             parameters_are_valid then
            set_transaction_info(IN_PROGRESS);
            v_request_idx := update_req.idx + 1;
            update_req    <= (v_request_idx, v_cmd.period, v_cmd.active_time, 0);
            wait until update_ack = v_request_idx or terminate_current_cmd.is_active = '1';
            if update_ack /= v_request_idx then
              update_cancel <= v_request_idx;
              wait for 0 ns;
            end if;
            if update_ack = v_request_idx then
              log_command("took effect");
            else
              log_terminated;
            end if;
            set_transaction_info(COMPLETED);
          end if;

        when STOP =>
          if role_is(GENERATOR) and run_mode_is(CONTINUOUS, "No continuous generation is active.") then
            set_transaction_info(IN_PROGRESS);
            v_request_idx := stop_req + 1;
            stop_req      <= v_request_idx;
            wait until run_mode = IDLE or terminate_current_cmd.is_active = '1';
            if run_mode /= IDLE then
              stop_cancel <= v_request_idx;
              wait for 0 ns;
            end if;
            if run_mode = IDLE then
              log_command("completed");
            else
              log_terminated;
            end if;
            set_transaction_info(COMPLETED);
          end if;

        when ABORT =>
          if role_is(GENERATOR) and run_mode_is(CONTINUOUS, "No continuous generation is active.") then
            set_transaction_info(IN_PROGRESS);
            abort_run;
            log_command("completed");
            set_transaction_info(COMPLETED);
          end if;

        when DRIVE_IDLE =>
          if role_is(GENERATOR) and run_mode_is(IDLE, "Not allowed while a continuous generation is active.") then
            set_transaction_info(IN_PROGRESS);
            v_request_idx := idle_req + 1;
            idle_req      <= v_request_idx;
            wait until idle_ack = v_request_idx;
            log(vvc_config.bfm_config.id_for_bfm, to_string(v_cmd.proc_call) & "=> line at '" & to_string(idle_driven) & "' (" &
                to_upper(to_string(vvc_config.bfm_config.idle_level)) & ")." & format_msg(v_cmd), C_SCOPE, v_msg_id_panel);
            set_transaction_info(COMPLETED);
          end if;

        -- Observer role: the BFM procedures observe the line directly
        when MEASURE =>
          if role_is(OBSERVER) then
            set_transaction_info(IN_PROGRESS);
            pwm_measure(result         => v_result,
                        msg            => format_msg(v_cmd),
                        pwm            => pwm_vvc_if,
                        terminate_loop => terminate_current_cmd.is_active,
                        num_periods    => v_cmd.num_periods,
                        timeout        => v_cmd.timeout,
                        scope          => C_SCOPE,
                        msg_id_panel   => v_msg_id_panel,
                        config         => vvc_config.bfm_config);
            work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,
                                                        cmd_idx      => v_cmd.cmd_idx,
                                                        result       => v_result);
            set_transaction_info(COMPLETED);
          end if;

        when EXPECT =>
          if role_is(OBSERVER) then
            set_transaction_info(IN_PROGRESS);
            pwm_expect(period         => v_cmd.period,
                      active_time    => v_cmd.active_time,
                      msg            => format_msg(v_cmd),
                      pwm            => pwm_vvc_if,
                      terminate_loop => terminate_current_cmd.is_active,
                      num_periods    => v_cmd.num_periods,
                      timeout        => v_cmd.timeout,
                      alert_level    => v_cmd.alert_level,
                      scope          => C_SCOPE,
                      msg_id_panel   => v_msg_id_panel,
                      config         => vvc_config.bfm_config);
            set_transaction_info(COMPLETED);
          end if;

        when EXPECT_DUTY =>
          if role_is(OBSERVER) then
            set_transaction_info(IN_PROGRESS);
            pwm_expect(duty           => v_cmd.duty,
                      msg            => format_msg(v_cmd),
                      pwm            => pwm_vvc_if,
                      terminate_loop => terminate_current_cmd.is_active,
                      num_periods    => v_cmd.num_periods,
                      timeout        => v_cmd.timeout,
                      alert_level    => v_cmd.alert_level,
                      scope          => C_SCOPE,
                      msg_id_panel   => v_msg_id_panel,
                      config         => vvc_config.bfm_config);
            set_transaction_info(COMPLETED);
          end if;

        -- UVVM common operations
        --===================================
        when INSERT_DELAY =>
          log(ID_INSERTED_DELAY, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          if v_cmd.gen_integer_array(0) = -1 then
            -- Delay specified using time
            wait until terminate_current_cmd.is_active = '1' for v_cmd.delay;
          else
            -- Delay specified using integer: there is no clock
            alert(TB_ERROR, "insert_delay() with a number of clock cycles is not supported, the PWM VVC has no clock. Use a time." &
                  format_msg(v_cmd), C_SCOPE);
          end if;

        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_SCOPE);
      end case;

      if v_command_is_bfm_access then
        v_timestamp_end_of_last_bfm_access   := now;
        v_timestamp_start_of_last_bfm_access := v_timestamp_start_of_current_bfm_access;
        if ((vvc_config.inter_bfm_delay.delay_type = TIME_START2START) and
           ((now - v_timestamp_start_of_current_bfm_access) > vvc_config.inter_bfm_delay.delay_in_time)) then
          alert(vvc_config.inter_bfm_delay.inter_bfm_delay_violation_severity, "BFM access exceeded specified start-to-start inter-bfm delay, " &
                to_string(vvc_config.inter_bfm_delay.delay_in_time) & ".", C_SCOPE);
        end if;
      end if;

      -- Reset terminate flag if any occurred
      if (terminate_current_cmd.is_active = '1') then
        log(ID_CMD_EXECUTOR, "Termination request received", C_SCOPE, v_msg_id_panel);
        uvvm_vvc_framework.ti_vvc_framework_support_pkg.reset_flag(terminate_current_cmd);
      end if;

      last_cmd_idx_executed <= v_cmd.cmd_idx;

      -- Set vvc_transaction_info back to default values
      reset_vvc_transaction_info(vvc_transaction_info, v_cmd);

    end loop;
  end process p_cmd_executor;
  --==========================================================================================

  --==========================================================================================
  -- Waveform generator (GENERATOR role)
  -- - Drives the idle level from time 0, at the end of each run and on DRIVE_IDLE, and runs the generation requested
  --   by the executor, period by period, so that the executor stays free for UPDATE, STOP and ABORT during a
  --   continuous generation.
  -- - Latches update_req (unless withdrawn) and vvc_config.bfm_config at every period boundary.
  -- - Every run starts from the configured jitter seeds, seed 1 shifted by GC_INSTANCE_IDX, so that a run is
  --   reproducible and instances with the same configuration jitter independently.
  -- - The BFM log of each period and of the idle level is disabled (config.id_for_bfm); the executor logs the commands.
  -- OBSERVER role: drives 'Z' permanently.
  --==========================================================================================
  p_waveform : process is
    variable v_config         : t_pwm_bfm_config;
    variable v_period         : time;
    variable v_active_time    : time;
    variable v_continuous     : boolean;
    variable v_remaining      : natural;
    variable v_update_idx     : natural := 0;
    variable v_stop_idx       : natural := 0;
    variable v_seed1          : positive;
    variable v_seed2          : positive;
    variable v_aborted        : boolean;
    variable v_jitter_alerted : boolean;

    constant C_UNIFORM_SEED1_MAX : positive := 2147483562; -- Largest seed 1 accepted by ieee.math_real.uniform

    -- The configured seed 1 shifted by GC_INSTANCE_IDX, wrapped within 1 to C_UNIFORM_SEED1_MAX without an overflow
    function instance_seed1(
      constant seed1 : in positive
    ) return positive is
      constant C_OFFSET : natural := (seed1 - 1) mod C_UNIFORM_SEED1_MAX;
    begin
      if C_OFFSET >= C_UNIFORM_SEED1_MAX - GC_INSTANCE_IDX then
        return C_OFFSET - (C_UNIFORM_SEED1_MAX - GC_INSTANCE_IDX) + 1;
      else
        return C_OFFSET + GC_INSTANCE_IDX + 1;
      end if;
    end function;

    -- vvc_config.msg_id_panel without the BFM log of every period
    impure function waveform_msg_id_panel(
      constant id_for_bfm : in t_msg_id
    ) return t_msg_id_panel is
      variable v_msg_id_panel : t_msg_id_panel := vvc_config.msg_id_panel;
    begin
      v_msg_id_panel(id_for_bfm) := DISABLED;
      return v_msg_id_panel;
    end function;

    -- Drives the idle level of 'config' and records it for the executor's check_idle_level
    procedure drive_idle(
      constant config : in t_pwm_bfm_config
    ) is
    begin
      pwm_drive_idle("", pwm_vvc_if, C_SCOPE, waveform_msg_id_panel(config.id_for_bfm), config);
      idle_driven <= pwm_idle_value(config);
    end procedure;

  begin
    if GC_ROLE = OBSERVER then
      pwm_vvc_if <= 'Z';
      wait;
    end if;

    -- From the generic: vvc_config may not be set up yet at time 0
    drive_idle(GC_PWM_BFM_CONFIG);

    loop
      wait on start_req, idle_req;
      if idle_req'event then
        -- DRIVE_IDLE, only while no run is active
        drive_idle(vvc_config.bfm_config);
        idle_ack <= idle_req;
        next;
      end if;

      v_period         := start_req.period;
      v_active_time    := start_req.active_time;
      v_continuous     := start_req.num_periods = 0;
      v_remaining      := start_req.num_periods;
      v_update_idx     := update_req.idx;
      v_stop_idx       := stop_req;
      v_config         := vvc_config.bfm_config;
      -- Every run starts from the configured seeds, so it is reproducible; seed 1 differs per instance
      v_seed1          := instance_seed1(v_config.jitter_seed1);
      v_seed2          := v_config.jitter_seed2;
      v_jitter_alerted := false;
      if v_continuous then
        run_mode <= CONTINUOUS;
      else
        run_mode <= BOUNDED;
      end if;
      start_ack <= start_req.idx;

      loop
        pwm_drive_period(v_period, v_active_time, v_seed1, v_seed2, v_aborted, "", pwm_vvc_if, abort_req, C_SCOPE,
                         waveform_msg_id_panel(v_config.id_for_bfm), v_config);
        exit when v_aborted;
        if not v_continuous then
          v_remaining := v_remaining - 1;
          exit when v_remaining = 0;
        end if;
        exit when stop_req /= v_stop_idx and stop_req /= stop_cancel;

        -- Period boundary: latch a pending update (unless withdrawn) and the config. A config with an invalid jitter
        -- is not latched: the BFM would return at once, and the loop would not advance time.
        if update_req.idx /= v_update_idx then
          v_update_idx := update_req.idx;
          if update_req.idx /= update_cancel then
            v_period      := update_req.period;
            v_active_time := update_req.active_time;
            update_ack    <= v_update_idx;
          end if;
        end if;
        if vvc_config.bfm_config.jitter >= 0 ns then
          v_config := vvc_config.bfm_config;
        elsif not v_jitter_alerted then
          alert(TB_ERROR, "config.jitter must be >= 0 ns, was " & to_string(vvc_config.bfm_config.jitter, ns) &
                ". The generation continues with the previous config.", C_SCOPE);
          v_jitter_alerted := true;
        end if;
      end loop;

      drive_idle(vvc_config.bfm_config);
      run_mode <= IDLE;
    end loop;
  end process p_waveform;
  --==========================================================================================

  --==========================================================================================
  -- Command termination handler
  -- - Handles the termination request record (sets and resets terminate flag on request)
  --==========================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd);  -- flag: is_active, set, reset
--==========================================================================================

end architecture behave;
