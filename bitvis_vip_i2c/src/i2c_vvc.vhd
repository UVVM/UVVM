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
------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
--
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.C_SB_CONFIG_DEFAULT;

use work.i2c_bfm_pkg.all;
use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;
use work.transaction_pkg.all;
use work.vvc_sb_support_pkg.all;

--=================================================================================================
entity i2c_vvc is
  generic(
    GC_INSTANCE_IDX                          : natural          := 1; -- Instance index for this I2C_VVCT instance
    GC_MASTER_MODE                           : boolean          := true;
    GC_I2C_CONFIG                            : t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT; -- Behavior specification for BFM
    GC_CMD_QUEUE_COUNT_MAX                   : natural          := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural          := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level    := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural          := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural          := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level    := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
  port(
    i2c_vvc_if : inout t_i2c_if := init_i2c_if_signals(VOID)
  );
end entity i2c_vvc;

--=================================================================================================
--=================================================================================================

architecture behave of i2c_vvc is

  constant C_SCOPE      : string       := get_scope_for_log(C_VVC_NAME, GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);

  signal executor_is_busy      : boolean := false;
  signal queue_is_increasing   : boolean := false;
  signal last_cmd_idx_executed : natural := 0;
  signal terminate_current_cmd : t_flag_record;

  -- Instantiation of the element dedicated Queue
  shared variable command_queue : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable result_queue  : work.td_result_queue_pkg.t_generic_queue;

  alias vvc_config                          : t_vvc_config is shared_i2c_vvc_config(GC_INSTANCE_IDX);
  alias vvc_status                          : t_vvc_status is shared_i2c_vvc_status(GC_INSTANCE_IDX);
  alias transaction_info                    : t_transaction_info is shared_i2c_transaction_info(GC_INSTANCE_IDX);
  -- Transaction info
  alias vvc_transaction_info_trigger        : std_logic is global_i2c_vvc_transaction_trigger(GC_INSTANCE_IDX);
  alias vvc_transaction_info                : t_transaction_group is shared_i2c_vvc_transaction_info(GC_INSTANCE_IDX);
  -- VVC Activity 
  signal entry_num_in_vvc_activity_register : integer;

  --UVVM: temporary fix for HVVC, remove function below in v3.0
  function get_msg_id_panel(
    constant command    : in t_vvc_cmd_record;
    constant vvc_config : in t_vvc_config
  ) return t_msg_id_panel is
  begin
    -- If the parent_msg_id_panel is set then use it,
    -- otherwise use the VVCs msg_id_panel from its config.
    if command.msg(1 to 5) = "HVVC:" then
      return vvc_config.parent_msg_id_panel;
    else
      return vvc_config.msg_id_panel;
    end if;
  end function;

begin

  --===============================================================================================
  -- Constructor
  -- - Set up the defaults and show constructor if enabled
  --===============================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, GC_I2C_CONFIG,
                                                 GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
                                                 GC_RESULT_QUEUE_COUNT_MAX, GC_RESULT_QUEUE_COUNT_THRESHOLD, GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
                                                 C_VVC_MAX_INSTANCE_NUM);
  --===============================================================================================

  --===============================================================================================
  -- Command interpreter
  -- - Interpret, decode and acknowledge commands from the central sequencer
  --===============================================================================================
  cmd_interpreter : process
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

      -- 2a. Put command on the queue if intended for the executor
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

      -- 3. Acknowledge command after runing or queuing the command
      -------------------------------------------------------------------------
      if not v_cmd_has_been_acked then
        work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack, v_local_vvc_cmd.cmd_idx);
      end if;

    end loop;
    wait;
  end process;
  --===============================================================================================

  --===============================================================================================
  -- Command executor
  -- - Fetch and execute the commands
  --===============================================================================================
  cmd_executor : process
    constant C_EXECUTOR_ID                           : natural := 0;
    variable v_cmd                                   : t_vvc_cmd_record;
    variable v_read_data                             : t_vvc_result; -- See vvc_cmd_pkg
    variable v_timestamp_start_of_current_bfm_access : time    := 0 ns;
    variable v_timestamp_start_of_last_bfm_access    : time    := 0 ns;
    variable v_timestamp_end_of_last_bfm_access      : time    := 0 ns;
    variable v_command_is_bfm_access                 : boolean := false;
    variable v_prev_command_was_bfm_access           : boolean := false;
    variable v_msg_id_panel                          : t_msg_id_panel;

  begin
    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    -- Setup I2C scoreboard
    I2C_VVC_SB.set_scope("I2C_VVC_SB");
    I2C_VVC_SB.enable(GC_INSTANCE_IDX, "I2C VVC SB Enabled");
    I2C_VVC_SB.config(GC_INSTANCE_IDX, C_SB_CONFIG_DEFAULT);
    I2C_VVC_SB.enable_log_msg(GC_INSTANCE_IDX, ID_DATA);

    while true loop

      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_cmd_idx_executed, command_queue.is_empty(VOID), C_SCOPE);

      -- 1. Set defaults, fetch command and log
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing, executor_is_busy, C_VVC_LABELS);

      -- update vvc activity
      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register, C_EXECUTOR_ID, last_cmd_idx_executed, command_queue.is_empty(VOID), C_SCOPE);

      -- Set the transaction info for waveview
      transaction_info           := C_TRANSACTION_INFO_DEFAULT;
      transaction_info.operation := v_cmd.operation;
      transaction_info.msg       := pad_string(to_string(v_cmd.msg), ' ', transaction_info.msg'length);

      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the
      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.
      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);

      -- Check if command is a BFM access
      v_prev_command_was_bfm_access := v_command_is_bfm_access; -- save for inter_bfm_delay
      if v_cmd.operation = MASTER_TRANSMIT or v_cmd.operation = MASTER_CHECK or v_cmd.operation = MASTER_RECEIVE or v_cmd.operation = SLAVE_TRANSMIT or v_cmd.operation = SLAVE_CHECK or v_cmd.operation = SLAVE_RECEIVE then
        v_command_is_bfm_access := true;
      else
        v_command_is_bfm_access := false;
      end if;

      -- Insert delay if needed
      work.td_vvc_entity_support_pkg.insert_inter_bfm_delay_if_requested(vvc_config                         => vvc_config,
                                                                         command_is_bfm_access              => v_prev_command_was_bfm_access,
                                                                         timestamp_start_of_last_bfm_access => v_timestamp_start_of_last_bfm_access,
                                                                         timestamp_end_of_last_bfm_access   => v_timestamp_end_of_last_bfm_access,
                                                                         msg_id_panel                       => v_msg_id_panel,
                                                                         scope                              => C_SCOPE);
      if v_command_is_bfm_access then
        v_timestamp_start_of_current_bfm_access := now;
      end if;

      -- 2. Execute the fetched command
      -------------------------------------------------------------------------
      case v_cmd.operation is           -- Only operations in the dedicated record are relevant

        -- VVC dedicated operations
        --===================================
        when MASTER_TRANSMIT =>
          if GC_MASTER_MODE then        -- master transmit
            -- Set vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

            transaction_info.data                         := v_cmd.data;
            transaction_info.num_bytes                    := v_cmd.num_bytes;
            transaction_info.addr                         := v_cmd.addr;
            transaction_info.action_when_transfer_is_done := v_cmd.action_when_transfer_is_done;

            i2c_master_transmit(addr_value                   => v_cmd.addr,
                                data                         => v_cmd.data(0 to v_cmd.num_bytes - 1),
                                msg                          => format_msg(v_cmd),
                                i2c_if                       => i2c_vvc_if,
                                action_when_transfer_is_done => v_cmd.action_when_transfer_is_done,
                                scope                        => C_SCOPE,
                                msg_id_panel                 => v_msg_id_panel,
                                config                       => vvc_config.bfm_config);

            -- Update vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);
          else                          -- attempted master transmit when in slave mode
            alert(error, "Master transmit called when VVC is in slave mode.", C_SCOPE);
          end if;

        when MASTER_RECEIVE =>
          if GC_MASTER_MODE then        -- master receive
            -- Set vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

            transaction_info.addr                         := v_cmd.addr;
            transaction_info.action_when_transfer_is_done := v_cmd.action_when_transfer_is_done;
            transaction_info.num_bytes                    := v_cmd.num_bytes;

            check_value(v_cmd.num_bytes <= C_VVC_CMD_DATA_MAX_LENGTH, error, "Verifying number of bytes to receive.", C_SCOPE, ID_NEVER);

            i2c_master_receive(addr_value                   => v_cmd.addr,
                               data                         => v_read_data(0 to v_cmd.num_bytes - 1),
                               msg                          => format_msg(v_cmd),
                               i2c_if                       => i2c_vvc_if,
                               action_when_transfer_is_done => v_cmd.action_when_transfer_is_done,
                               scope                        => C_SCOPE,
                               msg_id_panel                 => v_msg_id_panel,
                               config                       => vvc_config.bfm_config);

            -- Request SB check result
            if v_cmd.data_routing = TO_SB then
              -- call SB check_received
              for i in 0 to v_cmd.num_bytes - 1 loop
                I2C_VVC_SB.check_received(GC_INSTANCE_IDX, pad_i2c_sb(v_read_data(i)));
              end loop;
            else
              -- Store the result
              work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,
                                                          cmd_idx      => v_cmd.cmd_idx,
                                                          result       => v_read_data);
            end if;

            -- Update vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_read_data, COMPLETED, C_SCOPE);
          else                          -- attempted master receive when in slave mode
            alert(error, "Master receive called when VVC is in slave mode.", C_SCOPE);
          end if;

        when MASTER_CHECK =>
          if GC_MASTER_MODE then        -- master check
            -- Set vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

            transaction_info.data                         := v_cmd.data;
            transaction_info.num_bytes                    := v_cmd.num_bytes;
            transaction_info.addr                         := v_cmd.addr;
            transaction_info.action_when_transfer_is_done := v_cmd.action_when_transfer_is_done;

            i2c_master_check(addr_value                   => v_cmd.addr,
                             data_exp                     => v_cmd.data(0 to v_cmd.num_bytes - 1),
                             msg                          => format_msg(v_cmd),
                             i2c_if                       => i2c_vvc_if,
                             action_when_transfer_is_done => v_cmd.action_when_transfer_is_done,
                             alert_level                  => v_cmd.alert_level,
                             scope                        => C_SCOPE,
                             msg_id_panel                 => v_msg_id_panel,
                             config                       => vvc_config.bfm_config);

            -- Update vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);
          else                          -- attempted master check when in slave mode
            alert(error, "Master check called when VVC is in slave mode.", C_SCOPE);
          end if;

        when MASTER_QUICK_CMD =>
          if GC_MASTER_MODE then        -- master check
            -- Set vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

            transaction_info.addr                         := v_cmd.addr;
            transaction_info.exp_ack                      := v_cmd.exp_ack;
            transaction_info.action_when_transfer_is_done := v_cmd.action_when_transfer_is_done;

            i2c_master_quick_command(addr_value                   => v_cmd.addr,
                                     msg                          => format_msg(v_cmd),
                                     i2c_if                       => i2c_vvc_if,
                                     rw_bit                       => v_cmd.rw_bit,
                                     exp_ack                      => v_cmd.exp_ack,
                                     action_when_transfer_is_done => v_cmd.action_when_transfer_is_done,
                                     alert_level                  => v_cmd.alert_level,
                                     scope                        => C_SCOPE,
                                     msg_id_panel                 => v_msg_id_panel,
                                     config                       => vvc_config.bfm_config);

            -- Update vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);
          else                          -- attempted master quick command when in slave mode
            alert(error, "Master quick command called when VVC is in slave mode.", C_SCOPE);
          end if;

        when SLAVE_TRANSMIT =>
          if not GC_MASTER_MODE then    -- slave transmit
            -- Set vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

            transaction_info.data      := v_cmd.data;
            transaction_info.num_bytes := v_cmd.num_bytes;

            i2c_slave_transmit(data         => v_cmd.data(0 to v_cmd.num_bytes - 1),
                               msg          => format_msg(v_cmd),
                               i2c_if       => i2c_vvc_if,
                               scope        => C_SCOPE,
                               msg_id_panel => v_msg_id_panel,
                               config       => vvc_config.bfm_config);

            -- Update vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);
          else                          -- attempted slave transmit when in master mode
            alert(error, "Slave transmit called when VVC is in master mode.", C_SCOPE);
          end if;

        when SLAVE_RECEIVE =>
          if not GC_MASTER_MODE then    -- requires slave mode
            -- Set vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

            transaction_info.num_bytes := v_cmd.num_bytes;

            check_value(v_cmd.num_bytes <= C_VVC_CMD_DATA_MAX_LENGTH, error, "Verifying number of bytes to receive.", C_SCOPE, ID_NEVER);

            i2c_slave_receive(data         => v_read_data(0 to v_cmd.num_bytes - 1),
                              msg          => format_msg(v_cmd),
                              i2c_if       => i2c_vvc_if,
                              scope        => C_SCOPE,
                              msg_id_panel => v_msg_id_panel,
                              config       => vvc_config.bfm_config);

            -- Request SB check result
            if v_cmd.data_routing = TO_SB then
              -- call SB check_received
              for i in 0 to v_cmd.num_bytes - 1 loop
                I2C_VVC_SB.check_received(GC_INSTANCE_IDX, pad_i2c_sb(v_read_data(i)));
              end loop;
            else
              -- Store the result
              work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,
                                                          cmd_idx      => v_cmd.cmd_idx,
                                                          result       => v_read_data);
            end if;

            -- Update vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_read_data, COMPLETED, C_SCOPE);
          else                          -- wrong mode
            alert(error, "Slave receive called when VVC is in master mode.", C_SCOPE);
          end if;

        when SLAVE_CHECK =>
          if not GC_MASTER_MODE then    -- slave check
            -- Set vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

            transaction_info.data      := v_cmd.data;
            transaction_info.num_bytes := v_cmd.num_bytes;

            i2c_slave_check(data_exp     => v_cmd.data(0 to v_cmd.num_bytes - 1),
                            msg          => format_msg(v_cmd),
                            i2c_if       => i2c_vvc_if,
                            exp_rw_bit   => v_cmd.rw_bit,
                            alert_level  => v_cmd.alert_level,
                            scope        => C_SCOPE,
                            msg_id_panel => v_msg_id_panel,
                            config       => vvc_config.bfm_config);

            -- Update vvc transaction info
            set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);
          else                          -- attempted slave check when in master mode
            alert(error, "Slave check called when VVC is in master mode.", C_SCOPE);
          end if;

        -- UVVM common operations
        --===================================
        when INSERT_DELAY =>
          log(ID_INSERTED_DELAY, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          if v_cmd.gen_integer_array(0) = -1 then
            -- Delay specified using time
            wait until terminate_current_cmd.is_active = '1' for v_cmd.delay;
          else
            -- Delay specified using integer
            wait until terminate_current_cmd.is_active = '1' for v_cmd.gen_integer_array(0) * vvc_config.bfm_config.i2c_bit_time;
          end if;

        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_SCOPE);
      end case;

      if v_command_is_bfm_access then
        v_timestamp_end_of_last_bfm_access   := now;
        v_timestamp_start_of_last_bfm_access := v_timestamp_start_of_current_bfm_access;
        if ((vvc_config.inter_bfm_delay.delay_type = TIME_START2START) and ((now - v_timestamp_start_of_current_bfm_access) > vvc_config.inter_bfm_delay.delay_in_time)) then
          alert(vvc_config.inter_bfm_delay.inter_bfm_delay_violation_severity, "BFM access exceeded specified start-to-start inter-bfm delay, " & to_string(vvc_config.inter_bfm_delay.delay_in_time) & ".", C_SCOPE);
        end if;
      end if;

      -- Reset terminate flag if any occurred
      if (terminate_current_cmd.is_active = '1') then
        log(ID_CMD_EXECUTOR, "Termination request received", C_SCOPE, v_msg_id_panel);
        uvvm_vvc_framework.ti_vvc_framework_support_pkg.reset_flag(terminate_current_cmd);
      end if;

      last_cmd_idx_executed <= v_cmd.cmd_idx;
      -- Reset the transaction info for waveview
      transaction_info      := C_TRANSACTION_INFO_DEFAULT;
      -- Set VVC Transaction Info back to default values
      reset_vvc_transaction_info(vvc_transaction_info, v_cmd);
    end loop;
  end process;
  --===============================================================================================

  --===============================================================================================
  -- Command termination handler
  -- - Handles the termination request record (sets and resets terminate flag on request)
  --===============================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd); -- flag: is_active, set, reset
  --===============================================================================================

  --===============================================================================================
  -- Unwanted activity detection
  -- - Monitors unwanted activity from the DUT
  --===============================================================================================
  p_unwanted_activity : process
  begin
    -- Add a delay to allow the VVC to be registered in the activity register
    wait for std.env.resolution_limit;

    loop
      -- Skip if the vvc is inactive to avoid waiting for an inactive activity register
      if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = ACTIVE then
        -- Wait until the vvc is inactive
        loop
          wait on global_trigger_vvc_activity_register;
          if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = INACTIVE then
            exit;
          end if;
        end loop;
      end if;

      if GC_MASTER_MODE then
        wait on i2c_vvc_if.sda, global_trigger_vvc_activity_register;
      else
        wait on i2c_vvc_if.scl, i2c_vvc_if.sda, global_trigger_vvc_activity_register;
      end if;

      -- Check the changes on the DUT outputs only when the vvc is inactive
      if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = INACTIVE then
        if GC_MASTER_MODE then
          check_unwanted_activity(i2c_vvc_if.sda, vvc_config.unwanted_activity_severity, "sda", C_SCOPE);
        else
          check_unwanted_activity(i2c_vvc_if.scl, vvc_config.unwanted_activity_severity, "This can be caused by multiple slave VVCs with a common bus connected to the same DUT. See documentation.\nscl", C_SCOPE);
          check_unwanted_activity(i2c_vvc_if.sda, vvc_config.unwanted_activity_severity, "This can be caused by multiple slave VVCs with a common bus connected to the same DUT. See documentation.\nsda", C_SCOPE);
        end if;
      end if;
    end loop;
  end process p_unwanted_activity;
  --===============================================================================================

end behave;

