--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------
--========================================================================================================================
-- This VVC was generated with Bitvis VVC Generator
--========================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;

--========================================================================================================================
entity clock_generator_vvc is
  generic(
    GC_INSTANCE_IDX                          : natural       := 1;
    GC_CLOCK_NAME                            : string        := "clk";
    GC_CLOCK_PERIOD                          : time          := 10 ns;
    GC_CLOCK_HIGH_TIME                       : time          := 5 ns;
    GC_CMD_QUEUE_COUNT_MAX                   : natural       := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural       := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural       := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural       := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
  port(
    clk : out std_logic
  );
begin
  assert (GC_CLOCK_NAME'length <= C_MAX_VVC_NAME_LENGTH) report "Clock name is too long (max " & to_string(C_MAX_VVC_NAME_LENGTH) & " characters)" severity ERROR;
end entity clock_generator_vvc;

--========================================================================================================================
--========================================================================================================================
architecture behave of clock_generator_vvc is

  constant C_SCOPE      : string       := get_scope_for_log(C_VVC_NAME, GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);

  signal executor_is_busy                   : boolean := false;
  signal queue_is_increasing                : boolean := false;
  signal last_cmd_idx_executed              : natural := 0;
  signal terminate_current_cmd              : t_flag_record;
  signal clock_ena                          : boolean := false;
  -- VVC Activity 
  signal entry_num_in_vvc_activity_register : integer;

  -- Instantiation of the element dedicated executor
  shared variable command_queue : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable result_queue  : work.td_result_queue_pkg.t_generic_queue;

  alias vvc_config       : t_vvc_config is shared_clock_generator_vvc_config(GC_INSTANCE_IDX);
  alias vvc_status       : t_vvc_status is shared_clock_generator_vvc_status(GC_INSTANCE_IDX);
  alias transaction_info : t_transaction_info is shared_clock_generator_transaction_info(GC_INSTANCE_IDX);

  alias clock_name      : string is vvc_config.clock_name;
  alias clock_period    : time is vvc_config.clock_period;
  alias clock_high_time : time is vvc_config.clock_high_time;

  impure function get_clock_name
  return string is
  begin
    return clock_name(1 to pos_of_leftmost(NUL, clock_name, clock_name'length));
  end function;

begin

  --========================================================================================================================
  -- Constructor
  -- - Set up the defaults and show constructor if enabled
  --========================================================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, C_VOID_BFM_CONFIG,
                                                 GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
                                                 GC_RESULT_QUEUE_COUNT_MAX, GC_RESULT_QUEUE_COUNT_THRESHOLD, GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
                                                 C_VVC_MAX_INSTANCE_NUM);
  --========================================================================================================================

  --========================================================================================================================
  -- Config initializer
  -- - Set up the VVC specific config fields
  --========================================================================================================================
  config_initializer : process
  begin
    loop
      wait for 0 ns;
      exit when shared_uvvm_state = PHASE_B;
    end loop;
    clock_name(1 to vvc_config.clock_name'length) := (others => NUL);
    clock_name(1 to GC_CLOCK_NAME'length)         := GC_CLOCK_NAME;
    clock_period                                  := GC_CLOCK_PERIOD;
    clock_high_time                               := GC_CLOCK_HIGH_TIME;
    wait;
  end process;
  --========================================================================================================================

  --========================================================================================================================
  -- Command interpreter
  -- - Interpret, decode and acknowledge commands from the central sequencer
  --========================================================================================================================
  cmd_interpreter : process
    variable v_cmd_has_been_acked : boolean; -- Indicates if acknowledge_cmd() has been called for the current shared_vvc_cmd
    variable v_local_vvc_cmd      : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;
    variable v_msg_id_panel       : t_msg_id_panel;
  begin
    -- 0. Initialize the process prior to first command
    work.td_vvc_entity_support_pkg.initialize_interpreter(terminate_current_cmd, global_awaiting_completion);
    -- initialise shared_vvc_last_received_cmd_idx for channel and instance
    shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := 0;
    -- Register VVC in vvc activity register
    entry_num_in_vvc_activity_register                    <= shared_vvc_activity_register.priv_register_vvc(name     => C_VVC_NAME,
                                                                                                            instance => GC_INSTANCE_IDX);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel                                        := vvc_config.msg_id_panel;

    -- Then for every single command from the sequencer
    loop                                -- basically as long as new commands are received

      -- 1. wait until command targeted at this VVC. Must match VVC name, instance and channel (if applicable)
      --    releases global semaphore
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.await_cmd_from_sequencer(C_VVC_LABELS, vvc_config, THIS_VVCT, VVC_BROADCAST, global_vvc_busy, global_vvc_ack, v_local_vvc_cmd);
      v_cmd_has_been_acked                                  := false; -- Clear flag
      -- update shared_vvc_last_received_cmd_idx with received command index
      shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := v_local_vvc_cmd.cmd_idx;
      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel                                        := get_msg_id_panel(v_local_vvc_cmd, vvc_config);

      -- 2a. Put command on the executor if intended for the executor
      -------------------------------------------------------------------------
      if v_local_vvc_cmd.command_type = QUEUED then
        work.td_vvc_entity_support_pkg.put_command_on_queue(v_local_vvc_cmd, command_queue, vvc_status, queue_is_increasing);

      -- 2b. Otherwise command is intended for immediate response
      -------------------------------------------------------------------------
      elsif v_local_vvc_cmd.command_type = IMMEDIATE then
        case v_local_vvc_cmd.operation is

          when DISABLE_LOG_MSG =>
            uvvm_util.methods_pkg.disable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when ENABLE_LOG_MSG =>
            uvvm_util.methods_pkg.enable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when FLUSH_COMMAND_QUEUE =>
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, command_queue, vvc_config, vvc_status, C_VVC_LABELS);

          when TERMINATE_CURRENT_COMMAND =>
            work.td_vvc_entity_support_pkg.interpreter_terminate_current_command(v_local_vvc_cmd, vvc_config, C_VVC_LABELS, terminate_current_cmd, executor_is_busy);

          when others =>
            tb_error("Unsupported command received for IMMEDIATE execution: '" & to_string(v_local_vvc_cmd.operation) & "'", C_SCOPE);

        end case;

      else
        tb_error("command_type is not IMMEDIATE or QUEUED", C_SCOPE);
      end if;

      -- 3. Acknowledge command after runing or queuing the command
      -------------------------------------------------------------------------
      if not v_cmd_has_been_acked then
        work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack, v_local_vvc_cmd.cmd_idx);
      end if;

    end loop;
    wait;
  end process;
  --========================================================================================================================

  --========================================================================================================================
  -- Command executor
  -- - Fetch and execute the commands
  --========================================================================================================================
  cmd_executor : process
    variable v_cmd          : t_vvc_cmd_record;
    variable v_msg_id_panel : t_msg_id_panel;

  begin
    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop

      -- update vvc activity -> Note that clock generator VVC activity is not included in the resetting of the VVC activity register!

      -- 1. Set defaults, fetch command and log
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing, executor_is_busy, C_VVC_LABELS);

      -- update vvc activity -> Note that clock generator VVC activity is not included in the resetting of the VVC activity register!

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);

      -- 2. Execute the fetched command
      -------------------------------------------------------------------------
      case v_cmd.operation is           -- Only operations in the dedicated record are relevant

        -- VVC dedicated operations
        --===================================

        when START_CLOCK =>
          if clock_ena then
            tb_error("Clock " & clock_name & " already running. " & format_msg(v_cmd), C_SCOPE);
          else
            clock_ena <= true;
            wait for 0 ns;
            log(ID_CLOCK_GEN, "Clock '" & clock_name & "' started", C_SCOPE);
          end if;

        when STOP_CLOCK =>
          if not clock_ena then
            tb_error("Clock '" & clock_name & "' already stopped. " & format_msg(v_cmd), C_SCOPE);
          else
            clock_ena <= false;
            if clk then
              wait until not clk;
            end if;
            log(ID_CLOCK_GEN, "Clock '" & clock_name & "' stopped", C_SCOPE);
          end if;

        when SET_CLOCK_PERIOD =>
          clock_period := v_cmd.clock_period;
          log(ID_CLOCK_GEN, "Clock '" & clock_name & "' period set to " & to_string(clock_period), C_SCOPE);

        when SET_CLOCK_HIGH_TIME =>
          clock_high_time := v_cmd.clock_high_time;
          log(ID_CLOCK_GEN, "Clock '" & clock_name & "' high time set to " & to_string(clock_high_time), C_SCOPE);

        -- UVVM common operations
        --===================================
        when INSERT_DELAY =>
          log(ID_INSERTED_DELAY, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          if v_cmd.gen_integer_array(0) = -1 then
            -- Delay specified using time
            wait until terminate_current_cmd.is_active = '1' for v_cmd.delay;
          else
            -- Delay specified using integer
            wait until terminate_current_cmd.is_active = '1' for v_cmd.gen_integer_array(0) * vvc_config.clock_period;
          end if;

        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_SCOPE);
      end case;

      -- Reset terminate flag if any occurred
      if (terminate_current_cmd.is_active = '1') then
        log(ID_CMD_EXECUTOR, "Termination request received", C_SCOPE, v_msg_id_panel);
        uvvm_vvc_framework.ti_vvc_framework_support_pkg.reset_flag(terminate_current_cmd);
      end if;

      last_cmd_idx_executed <= v_cmd.cmd_idx;
      -- Reset the transaction info for waveview
      transaction_info      := C_TRANSACTION_INFO_DEFAULT;

    end loop;
  end process;
  --========================================================================================================================

  --========================================================================================================================
  -- Command termination handler
  -- - Handles the termination request record (sets and resets terminate flag on request)
  --========================================================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd); -- flag: is_active, set, reset
  --========================================================================================================================

  --========================================================================================================================
  -- Clock Generator process
  -- - Process that generates the clock signal
  --========================================================================================================================
  clock_generator : process
    variable v_clock_period    : time;
    variable v_clock_high_time : time;
  begin
    wait for 0 ns;                      -- wait for clock_ena to be set
    loop

      if not clock_ena then
        clk <= '0';
        wait until clock_ena;
      end if;

      -- Clock period is sampled so it won't change during a clock cycle and potentialy introduce negative time in
      -- last wait statement
      v_clock_period    := clock_period;
      v_clock_high_time := clock_high_time;

      if v_clock_high_time >= v_clock_period then
        tb_error(clock_name & ": clock period must be larger than clock high time; clock period: " & to_string(v_clock_period) & ", clock high time: " & to_string(clock_high_time), C_SCOPE);
      end if;

      clk <= '1';
      wait for v_clock_high_time;
      clk <= '0';
      wait for (v_clock_period - v_clock_high_time);
    end loop;
  end process;
  --========================================================================================================================

end architecture behave;

