--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================
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

use work.i2c_bfm_pkg.all;
use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_vvc_framework_common_methods_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;

--=================================================================================================
entity i2c_vvc is
  generic (
    GC_INSTANCE_IDX                          : natural          := 1;  -- Instance index for this I2C_VVCT instance
    GC_MASTER_MODE                           : boolean          := true;
    GC_I2C_CONFIG                            : t_i2c_bfm_config := C_I2C_BFM_CONFIG_DEFAULT;  -- Behavior specification for BFM
    GC_CMD_QUEUE_COUNT_MAX                   : natural          := 1000;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural          := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level    := warning;
    GC_RESULT_QUEUE_COUNT_MAX                : natural          := 1000;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural          := 950;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level    := warning
    );
  port (
    i2c_vvc_if : inout t_i2c_if := init_i2c_if_signals(VOID)
    );
end entity i2c_vvc;

--=================================================================================================
--=================================================================================================

architecture behave of i2c_vvc is

  constant C_SCOPE      : string       := C_VVC_NAME & "," & to_string(GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);

  signal executor_is_busy      : boolean := false;
  signal queue_is_increasing   : boolean := false;
  signal last_cmd_idx_executed : natural := 0;
  signal terminate_current_cmd : t_flag_record;

  -- Instantiation of the element dedicated Queue
  shared variable command_queue : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable result_queue  : work.td_result_queue_pkg.t_generic_queue;

  alias vvc_config       : t_vvc_config is shared_i2c_vvc_config(GC_INSTANCE_IDX);
  alias vvc_status       : t_vvc_status is shared_i2c_vvc_status(GC_INSTANCE_IDX);
  alias transaction_info : t_transaction_info is shared_i2c_transaction_info(GC_INSTANCE_IDX);

begin


--===============================================================================================
-- Constructor
-- - Set up the defaults and show constructor if enabled
--===============================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, GC_I2C_CONFIG,
                                                 GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
                                                 GC_RESULT_QUEUE_COUNT_MAX, GC_RESULT_QUEUE_COUNT_THRESHOLD, GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY);
--===============================================================================================


--===============================================================================================
-- Command interpreter
-- - Interpret, decode and acknowledge commands from the central sequencer
--===============================================================================================
  cmd_interpreter : process
    variable v_cmd_has_been_acked : boolean;  -- Indicates if acknowledge_cmd() has been called for the current shared_vvc_cmd
    variable v_local_vvc_cmd      : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;
  begin

    -- 0. Initialize the process prior to first command
    work.td_vvc_entity_support_pkg.initialize_interpreter(terminate_current_cmd, global_awaiting_completion);
    -- initialise shared_vvc_last_received_cmd_idx for channel and instance
    shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := 0;

    -- Then for every single command from the sequencer
    loop  -- basically as long as new commands are received

      -- 1. wait until command targeted at this VVC. Must match VVC name, instance and channel (if applicable)
      --    releases global semaphore
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.await_cmd_from_sequencer(C_VVC_LABELS, vvc_config, THIS_VVCT, VVC_BROADCAST, global_vvc_busy, global_vvc_ack, shared_vvc_cmd, v_local_vvc_cmd);
      v_cmd_has_been_acked                                  := false;  -- Clear flag
      -- update shared_vvc_last_received_cmd_idx with received command index
      shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := v_local_vvc_cmd.cmd_idx;


      -- 2a. Put command on the queue if intended for the executor
      -------------------------------------------------------------------------
      if v_local_vvc_cmd.command_type = QUEUED then
        work.td_vvc_entity_support_pkg.put_command_on_queue(v_local_vvc_cmd, command_queue, vvc_status, queue_is_increasing);


      -- 2b. Otherwise command is intended for immediate response
      -------------------------------------------------------------------------
      elsif v_local_vvc_cmd.command_type = IMMEDIATE then
        case v_local_vvc_cmd.operation is

          when AWAIT_COMPLETION =>
            work.td_vvc_entity_support_pkg.interpreter_await_completion(v_local_vvc_cmd, command_queue, vvc_config, executor_is_busy, C_VVC_LABELS, last_cmd_idx_executed);

          when AWAIT_ANY_COMPLETION =>
            if not v_local_vvc_cmd.gen_boolean then
              -- Called with lastness = NOT_LAST: Acknowledge immediately to let the sequencer continue
              work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack, v_local_vvc_cmd.cmd_idx);
              v_cmd_has_been_acked := true;
            end if;
            work.td_vvc_entity_support_pkg.interpreter_await_any_completion(v_local_vvc_cmd, command_queue, vvc_config, executor_is_busy, C_VVC_LABELS, last_cmd_idx_executed, global_awaiting_completion);

          when DISABLE_LOG_MSG =>
            uvvm_util.methods_pkg.disable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when ENABLE_LOG_MSG =>
            uvvm_util.methods_pkg.enable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when FLUSH_COMMAND_QUEUE =>
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, command_queue, vvc_config, vvc_status, C_VVC_LABELS);

          when TERMINATE_CURRENT_COMMAND =>
            work.td_vvc_entity_support_pkg.interpreter_terminate_current_command(v_local_vvc_cmd, vvc_config, C_VVC_LABELS, terminate_current_cmd);

          when FETCH_RESULT =>
            work.td_vvc_entity_support_pkg.interpreter_fetch_result(result_queue, v_local_vvc_cmd, vvc_config, C_VVC_LABELS, last_cmd_idx_executed, shared_vvc_response);

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
  end process;
--===============================================================================================



--===============================================================================================
-- Command executor
-- - Fetch and execute the commands
--===============================================================================================
  cmd_executor : process
    variable v_cmd                                   : t_vvc_cmd_record;
    variable v_read_data                             : t_vvc_result;  -- See vvc_cmd_pkg
    variable v_timestamp_start_of_current_bfm_access : time    := 0 ns;
    variable v_timestamp_start_of_last_bfm_access    : time    := 0 ns;
    variable v_timestamp_end_of_last_bfm_access      : time    := 0 ns;
    variable v_command_is_bfm_access                 : boolean := false;
    variable v_prev_command_was_bfm_access           : boolean := false;
  begin

    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);

    while true loop
      -- 1. Set defaults, fetch command and log
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing, executor_is_busy, C_VVC_LABELS);

      -- Set the transaction info for waveview
      transaction_info           := C_TRANSACTION_INFO_DEFAULT;
      transaction_info.operation := v_cmd.operation;
      transaction_info.msg       := pad_string(to_string(v_cmd.msg), ' ', transaction_info.msg'length);

      -- Check if command is a BFM access
      v_prev_command_was_bfm_access := v_command_is_bfm_access;  -- save for inter_bfm_delay
      if v_cmd.operation = MASTER_TRANSMIT or
        v_cmd.operation = MASTER_CHECK or
        v_cmd.operation = MASTER_RECEIVE or
        v_cmd.operation = SLAVE_TRANSMIT or
        v_cmd.operation = SLAVE_CHECK or
        v_cmd.operation = SLAVE_RECEIVE then
        v_command_is_bfm_access := true;
      else
        v_command_is_bfm_access := false;
      end if;

      -- Insert delay if needed
      work.td_vvc_entity_support_pkg.insert_inter_bfm_delay_if_requested(vvc_config                         => vvc_config,
                                                                         command_is_bfm_access              => v_prev_command_was_bfm_access,
                                                                         timestamp_start_of_last_bfm_access => v_timestamp_start_of_last_bfm_access,
                                                                         timestamp_end_of_last_bfm_access   => v_timestamp_end_of_last_bfm_access,
                                                                         scope                              => C_SCOPE);
      if v_command_is_bfm_access then
        v_timestamp_start_of_current_bfm_access := now;
      end if;

      -- 2. Execute the fetched command
      -------------------------------------------------------------------------
      case v_cmd.operation is  -- Only operations in the dedicated record are relevant

        -- VVC dedicated operations
        --===================================
        when MASTER_TRANSMIT =>
          transaction_info.data      := v_cmd.data;
          transaction_info.num_bytes := v_cmd.num_bytes;

          if GC_MASTER_MODE then        -- master transmit
            transaction_info.addr                         := v_cmd.addr;
            transaction_info.action_when_transfer_is_done := v_cmd.action_when_transfer_is_done;

            i2c_master_transmit(addr_value                   => v_cmd.addr,
                                data                         => v_cmd.data(0 to v_cmd.num_bytes-1),
                                msg                          => format_msg(v_cmd),
                                i2c_if                       => i2c_vvc_if,
                                action_when_transfer_is_done => v_cmd.action_when_transfer_is_done,
                                scope                        => C_SCOPE,
                                msg_id_panel                 => vvc_config.msg_id_panel,
                                config                       => vvc_config.bfm_config);
          else  -- attempted master transmit when in slave mode
            alert(error, "Master transmit called when VVC is in slave mode.", C_SCOPE);
          end if;
        when MASTER_RECEIVE =>

          if GC_MASTER_MODE then        -- master receive
            transaction_info.addr                         := v_cmd.addr;
            transaction_info.action_when_transfer_is_done := v_cmd.action_when_transfer_is_done;
            transaction_info.num_bytes                    := v_cmd.num_bytes;

            check_value(v_cmd.num_bytes <= C_VVC_CMD_DATA_MAX_LENGTH, error, "Verifying number of bytes to receive.", C_SCOPE, ID_NEVER);

            i2c_master_receive(addr_value                   => v_cmd.addr,
                               data                         => v_read_data(0 to v_cmd.num_bytes-1),
                               msg                          => format_msg(v_cmd),
                               i2c_if                       => i2c_vvc_if,
                               action_when_transfer_is_done => v_cmd.action_when_transfer_is_done,
                               scope                        => C_SCOPE,
                               msg_id_panel                 => vvc_config.msg_id_panel,
                               config                       => vvc_config.bfm_config);

            -- Store the result
            work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,
                                                        cmd_idx      => v_cmd.cmd_idx,
                                                        result       => v_read_data);
          else  -- attempted master receive when in slave mode
            alert(error, "Master receive called when VVC is in slave mode.", C_SCOPE);
          end if;

        when MASTER_CHECK =>
          transaction_info.data      := v_cmd.data;
          transaction_info.num_bytes := v_cmd.num_bytes;

          if GC_MASTER_MODE then        -- master check
            transaction_info.addr                         := v_cmd.addr;
            transaction_info.action_when_transfer_is_done := v_cmd.action_when_transfer_is_done;

            i2c_master_check(addr_value                   => v_cmd.addr,
                             data_exp                     => v_cmd.data(0 to v_cmd.num_bytes-1),
                             msg                          => format_msg(v_cmd),
                             i2c_if                       => i2c_vvc_if,
                             action_when_transfer_is_done => v_cmd.action_when_transfer_is_done,
                             alert_level                  => v_cmd.alert_level,
                             scope                        => C_SCOPE,
                             msg_id_panel                 => vvc_config.msg_id_panel,
                             config                       => vvc_config.bfm_config);
          else  -- attempted master check when in slave mode
            alert(error, "Master check called when VVC is in slave mode.", C_SCOPE);
          end if;

        when MASTER_QUICK_CMD =>
          if GC_MASTER_MODE then        -- master check
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
                                     msg_id_panel                 => vvc_config.msg_id_panel,
                                     config                       => vvc_config.bfm_config);
          else  -- attempted master quick command when in slave mode
            alert(error, "Master quick command called when VVC is in slave mode.", C_SCOPE);
          end if;

        when SLAVE_TRANSMIT =>
          transaction_info.data      := v_cmd.data;
          transaction_info.num_bytes := v_cmd.num_bytes;
          if not GC_MASTER_MODE then    -- slave transmit
            i2c_slave_transmit(data         => v_cmd.data(0 to v_cmd.num_bytes-1),
                               msg          => format_msg(v_cmd),
                               i2c_if       => i2c_vvc_if,
                               scope        => C_SCOPE,
                               msg_id_panel => vvc_config.msg_id_panel,
                               config       => vvc_config.bfm_config);
          else  -- attempted slave transmit when in master mode
            alert(error, "Slave transmit called when VVC is in master mode.", C_SCOPE);
          end if;

        when SLAVE_RECEIVE =>
          if not GC_MASTER_MODE then    -- requires slave mode
            transaction_info.num_bytes := v_cmd.num_bytes;

            check_value(v_cmd.num_bytes <= C_VVC_CMD_DATA_MAX_LENGTH, error, "Verifying number of bytes to receive.", C_SCOPE, ID_NEVER);

            i2c_slave_receive(data         => v_read_data(0 to v_cmd.num_bytes-1),
                              msg          => format_msg(v_cmd),
                              i2c_if       => i2c_vvc_if,
                              scope        => C_SCOPE,
                              msg_id_panel => vvc_config.msg_id_panel,
                              config       => vvc_config.bfm_config);

            -- Store the result
            work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,
                                                        cmd_idx      => v_cmd.cmd_idx,
                                                        result       => v_read_data);
          else                          -- wrong mode
            alert(error, "Slave receive called when VVC is in master mode.", C_SCOPE);
          end if;

        when SLAVE_CHECK =>
          transaction_info.data      := v_cmd.data;
          transaction_info.num_bytes := v_cmd.num_bytes;
          if not GC_MASTER_MODE then    -- slave check
            i2c_slave_check(data_exp     => v_cmd.data(0 to v_cmd.num_bytes-1),
                            msg          => format_msg(v_cmd),
                            i2c_if       => i2c_vvc_if,
                            exp_rw_bit   => v_cmd.rw_bit,
                            alert_level  => v_cmd.alert_level,
                            scope        => C_SCOPE,
                            msg_id_panel => vvc_config.msg_id_panel,
                            config       => vvc_config.bfm_config);
          else  -- attempted slave check when in master mode
            alert(error, "Slave check called when VVC is in master mode.", C_SCOPE);
          end if;

        -- UVVM common operations
        --===================================
        when INSERT_DELAY =>
          log(ID_INSERTED_DELAY, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, vvc_config.msg_id_panel);
          if v_cmd.gen_integer_array(0) = -1 then
            -- Delay specified using time
            wait until terminate_current_cmd.is_active = '1'
              for v_cmd.delay;
          else
            -- Delay specified using integer
            wait until terminate_current_cmd.is_active = '1'
              for v_cmd.gen_integer_array(0) * vvc_config.bfm_config.i2c_bit_time;
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
        log(ID_CMD_EXECUTOR, "Termination request received", C_SCOPE, vvc_config.msg_id_panel);
        uvvm_vvc_framework.ti_vvc_framework_support_pkg.reset_flag(terminate_current_cmd);
      end if;

      last_cmd_idx_executed <= v_cmd.cmd_idx;
      -- Reset the transaction info for waveview
      transaction_info      := C_TRANSACTION_INFO_DEFAULT;

    end loop;
  end process;
  --===============================================================================================


--===============================================================================================
-- Command termination handler
-- - Handles the termination request record (sets and resets terminate flag on request)
--===============================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd);  -- flag: is_active, set, reset
--===============================================================================================

end behave;



