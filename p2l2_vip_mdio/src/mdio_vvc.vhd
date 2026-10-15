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
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.C_SB_CONFIG_DEFAULT;

use work.mdio_bfm_pkg.all;
use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;
use work.transaction_pkg.all;
use work.vvc_sb_support_pkg.all;

--==========================================================================================
--==========================================================================================
entity mdio_vvc is
  generic (
    GC_INSTANCE_IDX                          : natural;
    GC_STA_MODE                              : boolean; -- true: STA (bus master, drives MDC and the frames), false: PHY (answers frames). No default: every instance states its role.
    GC_MDIO_BFM_CONFIG                       : t_mdio_bfm_config         := C_MDIO_BFM_CONFIG_DEFAULT;
    GC_MDIO_PULLUP                           : boolean                   := false; -- true: the VVC drives a weak pull-up ('H') on mdio (both modes). false (default): the test harness provides it.
    GC_CMD_QUEUE_COUNT_MAX                   : natural                   := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                   := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level             := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural                   := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                   := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level             := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
  port (
    mdio_vvc_if                 : inout t_mdio_if);
end entity mdio_vvc;

--==========================================================================================
--==========================================================================================
architecture behave of mdio_vvc is

  constant C_SCOPE      : string       := get_scope_for_log(C_VVC_NAME, GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);

  signal executor_is_busy       : boolean := false;
  signal queue_is_increasing    : boolean := false;
  signal last_cmd_idx_executed  : natural := 0;
  signal terminate_current_cmd  : t_flag_record;

  -- Bus timing checker: each role checks the other side, its own timing is validated from its config in the BFM
  function get_checked_side(constant sta_mode : boolean) return t_mdio_timing_check is
  begin
    if sta_mode then
      return CHECK_PHY;
    end if;
    return CHECK_STA;
  end function get_checked_side;
  constant C_CHECKED_SIDE : t_mdio_timing_check := get_checked_side(GC_STA_MODE);

  -- Instantiation of the element dedicated executor
  shared variable command_queue : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable result_queue  : work.td_result_queue_pkg.t_generic_queue;

  alias vvc_config : t_vvc_config is shared_mdio_vvc_config(GC_INSTANCE_IDX);
  alias vvc_status : t_vvc_status is shared_mdio_vvc_status(GC_INSTANCE_IDX);
  -- Transaction info
  alias vvc_transaction_info_trigger        : std_logic           is global_mdio_vvc_transaction_trigger(GC_INSTANCE_IDX);
  alias vvc_transaction_info                : t_transaction_group is shared_mdio_vvc_transaction_info(GC_INSTANCE_IDX);
  -- VVC Activity
  signal entry_num_in_vvc_activity_register : integer;

begin

  --==========================================================================================
  -- Constructor
  -- - Set up the defaults and show constructor if enabled
  --==========================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, GC_MDIO_BFM_CONFIG,
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
    variable v_timestamp_start_of_current_bfm_access  : time    := 0 ns;
    variable v_timestamp_start_of_last_bfm_access     : time    := 0 ns;
    variable v_timestamp_end_of_last_bfm_access       : time    := 0 ns;
    variable v_command_is_bfm_access                  : boolean := false;
    variable v_prev_command_was_bfm_access            : boolean := false;
    variable v_msg_id_panel                           : t_msg_id_panel;
    variable v_read_data          : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0) := (others => 'X'); -- STA reads, PHY receives
    variable v_received_reg_addr  : unsigned(C_MDIO_REG_ADDR_WIDTH_C45-1 downto 0);                       -- PHY receive of an address frame
    variable v_result             : t_vvc_result; -- See vvc_cmd_pkg
    variable v_address_ok         : boolean;      -- *_REG commands: the address frame was sent without alert

    -- Result of an STA read or a PHY receive: checked in the scoreboard (TO_SB) or stored for fetch_result()
    procedure route_result(
      constant result : in t_vvc_result) is
    begin
      if v_cmd.data_routing = TO_SB then
        -- no value at all (all 'X': terminated, timed out, wrong opcode - the BFM reported why): nothing is
        -- checked, the expected entry stays pending in the scoreboard
        if result /= (result'range => 'X') then
          mdio_vvc_sb.check_received(GC_INSTANCE_IDX, pad_mdio_sb(result));
        else
          log(ID_DATA, to_string(v_cmd.proc_call) & "=> No data received, nothing sent to the scoreboard " &
              "(the expected entry stays pending). " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
        end if;
      else
        work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue, cmd_idx => v_cmd.cmd_idx, result => result);
      end if;
    end procedure route_result;

  begin

    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);

    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    -- Setup MDIO scoreboard (used by the STA reads and PHY receives with data_routing = TO_SB)
    mdio_vvc_sb.set_scope("MDIO_VVC_SB");
    mdio_vvc_sb.enable(GC_INSTANCE_IDX, "MDIO VVC SB Enabled");
    mdio_vvc_sb.config(GC_INSTANCE_IDX, C_SB_CONFIG_DEFAULT);
    mdio_vvc_sb.enable_log_msg(GC_INSTANCE_IDX, ID_DATA);

    -- STA mode: MDC is driven low from the start, the DUT (PHY) must not see a floating clock.
    -- PHY mode: the DUT (STA) drives MDC.
    if GC_STA_MODE then
      mdio_vvc_if <= (mdc => '0', mdio => 'Z');
    else
      mdio_vvc_if <= (mdc => 'Z', mdio => 'Z');
    end if;

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
      -- Operations of the other role are alerted and not executed (see the role check below)
      v_command_is_bfm_access := (is_phy_operation(v_cmd.operation) and not GC_STA_MODE) or
                                 (is_sta_operation(v_cmd.operation) and GC_STA_MODE);

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
      -- Role check: a PHY operation needs GC_STA_MODE = false, an STA operation GC_STA_MODE = true
      if is_phy_operation(v_cmd.operation) and GC_STA_MODE then
        tb_error("PHY operation " & to_string(v_cmd.operation) & " called when the VVC is in STA mode (GC_STA_MODE = true). " &
                 format_command_idx(v_cmd), C_SCOPE);
        v_cmd.operation := NO_OPERATION;
      elsif is_sta_operation(v_cmd.operation) and not GC_STA_MODE then
        tb_error("STA operation " & to_string(v_cmd.operation) & " called when the VVC is in PHY mode (GC_STA_MODE = false). " &
                 format_command_idx(v_cmd), C_SCOPE);
        v_cmd.operation := NO_OPERATION;
      end if;

      case v_cmd.operation is  -- Only operations in the dedicated record are relevant

        -- VVC dedicated operations
        --===================================

        when PHY_C22_EXPECT_WRITE =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c22_expect_write(
              reg_addr       => v_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0),
              data           => v_cmd.data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when PHY_C22_RECEIVE_WRITE =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c22_receive_write(
              reg_addr       => v_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0),
              data           => v_read_data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Check the received value in the scoreboard (TO_SB) or store the result (fetch_result), and update vvc transaction info
          v_result := v_read_data;
          route_result(v_result);
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);

        when PHY_C22_REPLY_READ =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c22_reply_read(
              reg_addr       => v_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0),
              data           => v_cmd.data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when PHY_C45_EXPECT_ADDRESS =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c45_expect_address(
              dev_addr       => v_cmd.dev_addr,
              reg_addr       => v_cmd.reg_addr,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when PHY_C45_RECEIVE_ADDRESS =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c45_receive_address(
              dev_addr       => v_cmd.dev_addr,
              reg_addr       => v_received_reg_addr,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Check the received value in the scoreboard (TO_SB) or store the result (fetch_result), and update vvc transaction info
          v_result := std_ulogic_vector(v_received_reg_addr); -- the payload of an address frame is the register address
          route_result(v_result);
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);

        when PHY_C45_EXPECT_WRITE =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c45_expect_write(
              dev_addr       => v_cmd.dev_addr,
              data           => v_cmd.data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when PHY_C45_RECEIVE_WRITE =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c45_receive_write(
              dev_addr       => v_cmd.dev_addr,
              data           => v_read_data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Check the received value in the scoreboard (TO_SB) or store the result (fetch_result), and update vvc transaction info
          v_result := v_read_data;
          route_result(v_result);
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);

        when PHY_C45_REPLY_READ =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c45_reply_read(
              dev_addr       => v_cmd.dev_addr,
              data           => v_cmd.data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when PHY_C45_REPLY_POST_READ_INCREMENT =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          -- Call the corresponding procedure in the BFM package.
          mdio_phy_c45_reply_post_read_increment(
              dev_addr       => v_cmd.dev_addr,
              data           => v_cmd.data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              timeout        => v_cmd.timeout,
              alert_level    => v_cmd.alert_level,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        -- STA operations (GC_STA_MODE = true)
        --===================================
        when STA_C22_WRITE =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c22_write(
              phy_addr       => v_cmd.phy_addr,
              reg_addr       => v_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0),
              data           => v_cmd.data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when STA_C22_READ =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          v_read_data := (others => 'X'); -- stays 'X' if the command is terminated
          mdio_sta_c22_read(
              phy_addr       => v_cmd.phy_addr,
              reg_addr       => v_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0),
              data           => v_read_data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Check the data in the scoreboard (TO_SB) or store the result (fetch_result), and update vvc transaction info
          v_result := v_read_data;
          route_result(v_result);
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);

        when STA_C22_CHECK =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c22_check(
              phy_addr       => v_cmd.phy_addr,
              reg_addr       => v_cmd.reg_addr(C_MDIO_REG_ADDR_WIDTH_C22-1 downto 0),
              data_exp       => v_cmd.data,
              alert_level    => v_cmd.alert_level,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when STA_C45_ADDRESS =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c45_address(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              reg_addr       => v_cmd.reg_addr,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when STA_C45_WRITE =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c45_write(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              data           => v_cmd.data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when STA_C45_READ =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          v_read_data := (others => 'X'); -- stays 'X' if the command is terminated
          mdio_sta_c45_read(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              data           => v_read_data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Check the data in the scoreboard (TO_SB) or store the result (fetch_result), and update vvc transaction info
          v_result := v_read_data;
          route_result(v_result);
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);

        when STA_C45_POST_READ_INCREMENT =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          v_read_data := (others => 'X'); -- stays 'X' if the command is terminated
          mdio_sta_c45_post_read_increment(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              data           => v_read_data,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Check the data in the scoreboard (TO_SB) or store the result (fetch_result), and update vvc transaction info
          v_result := v_read_data;
          route_result(v_result);
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);

        when STA_C45_CHECK =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c45_check(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              data_exp       => v_cmd.data,
              alert_level    => v_cmd.alert_level,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when STA_C45_CHECK_POST_READ_INCREMENT =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c45_check_post_read_increment(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              data_exp       => v_cmd.data,
              alert_level    => v_cmd.alert_level,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when STA_C45_WRITE_REG =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c45_address(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              reg_addr       => v_cmd.reg_addr,
              success        => v_address_ok,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);
          -- a failed (alerted) or terminated address frame ends the command, the access frame is not sent
          if v_address_ok then
            mdio_sta_c45_write(
                phy_addr       => v_cmd.phy_addr,
                dev_addr       => v_cmd.dev_addr,
                data           => v_cmd.data,
                msg            => format_msg(v_cmd),
                mdio_if        => mdio_vvc_if,
                terminate_loop => terminate_current_cmd.is_active,
                scope          => C_SCOPE,
                msg_id_panel   => v_msg_id_panel,
                config         => vvc_config.bfm_config);
          else -- the BFM has reported why the address frame failed
            log(vvc_config.bfm_config.id_for_bfm, to_string(v_cmd.proc_call) & "=> Address frame failed, the access frame " &
                  "is not sent. " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          end if;

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when STA_C45_READ_REG =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          v_read_data := (others => 'X'); -- stays 'X' if the command is terminated
          mdio_sta_c45_address(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              reg_addr       => v_cmd.reg_addr,
              success        => v_address_ok,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);
          -- a failed (alerted) or terminated address frame ends the command, the access frame is not sent
          if v_address_ok then
            mdio_sta_c45_read(
                phy_addr       => v_cmd.phy_addr,
                dev_addr       => v_cmd.dev_addr,
                data           => v_read_data,
                msg            => format_msg(v_cmd),
                mdio_if        => mdio_vvc_if,
                terminate_loop => terminate_current_cmd.is_active,
                scope          => C_SCOPE,
                msg_id_panel   => v_msg_id_panel,
                config         => vvc_config.bfm_config);
          else -- the BFM has reported why the address frame failed
            log(vvc_config.bfm_config.id_for_bfm, to_string(v_cmd.proc_call) & "=> Address frame failed, the access frame " &
                  "is not sent. " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          end if;

          -- Check the data in the scoreboard (TO_SB) or store the result (fetch_result), and update vvc transaction info
          v_result := v_read_data;
          route_result(v_result);
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);

        when STA_C45_CHECK_REG =>
          -- Set vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);

          mdio_sta_c45_address(
              phy_addr       => v_cmd.phy_addr,
              dev_addr       => v_cmd.dev_addr,
              reg_addr       => v_cmd.reg_addr,
              success        => v_address_ok,
              msg            => format_msg(v_cmd),
              mdio_if        => mdio_vvc_if,
              terminate_loop => terminate_current_cmd.is_active,
              scope          => C_SCOPE,
              msg_id_panel   => v_msg_id_panel,
              config         => vvc_config.bfm_config);
          -- a failed (alerted) or terminated address frame ends the command, the access frame is not sent
          if v_address_ok then
            mdio_sta_c45_check(
                phy_addr       => v_cmd.phy_addr,
                dev_addr       => v_cmd.dev_addr,
                data_exp       => v_cmd.data,
                alert_level    => v_cmd.alert_level,
                msg            => format_msg(v_cmd),
                mdio_if        => mdio_vvc_if,
                terminate_loop => terminate_current_cmd.is_active,
                scope          => C_SCOPE,
                msg_id_panel   => v_msg_id_panel,
                config         => vvc_config.bfm_config);
          else -- the BFM has reported why the address frame failed
            log(vvc_config.bfm_config.id_for_bfm, to_string(v_cmd.proc_call) & "=> Address frame failed, the access frame " &
                  "is not sent. " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          end if;

          -- Update vvc transaction info
          set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);

        when NO_OPERATION =>
          null; -- operation of the other role, alerted above

        -- UVVM common operations
        --===================================
        when INSERT_DELAY =>
          log(ID_INSERTED_DELAY, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);
          if v_cmd.gen_integer_array(0) = -1 then
            -- Delay specified using time
            wait until terminate_current_cmd.is_active = '1' for v_cmd.delay;
          elsif GC_STA_MODE then
            -- Delay specified using integer: number of MDC periods. The STA's own MDC idles low between commands,
            -- so the delay is a time: n * bfm_config.sta.mdc_period
            if vvc_config.bfm_config.sta.mdc_period > 0 ns then
              wait until terminate_current_cmd.is_active = '1' for v_cmd.gen_integer_array(0) * vvc_config.bfm_config.sta.mdc_period;
            else
              tb_error("insert_delay() with a number of MDC periods needs a positive bfm_config.sta.mdc_period, was " &
                       to_string(vvc_config.bfm_config.sta.mdc_period) & ". No delay inserted.", C_SCOPE);
            end if;
          else
            -- Delay specified using integer: number of rising MDC edges. In PHY mode MDC comes from the STA (DUT),
            -- it only runs during frames, so the delay lasts until the STA has clocked that many bits.
            -- No timeout on purpose: if the STA stops MDC, only terminate_current_command() ends the delay (documented).
            for i in 1 to v_cmd.gen_integer_array(0) loop
              exit when terminate_current_cmd.is_active = '1';
              wait until rising_edge(mdio_vvc_if.mdc) or terminate_current_cmd.is_active = '1';
            end loop;
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
  -- Command termination handler
  -- - Handles the termination request record (sets and resets terminate flag on request)
  --==========================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd);  -- flag: is_active, set, reset
  --==========================================================================================

  --==========================================================================================
  -- Bus timing checker (property checker, controlled by vvc_config.bus_timing_checker)
  -- - Follows the frames on the bus to know who drives each bit, and checks every bit time accordingly with
  --   mdio_check_bit_timing(). vvc_config is read anew for every bit.
  -- - PHY mode: MDC and the bits driven by the STA (the DUT).
  -- - STA mode: the bits driven by a PHY (the DUT). MDC and the STA's own bits are validated from the config in
  --   the BFM, so they can be violated on purpose (config.timing_violation_severity).
  -- - PHY mode, also unwanted activity detection: a frame to this PHY's address that no mdio_phy_* call was
  --   waiting for is reported with vvc_config.unwanted_activity_severity (see the end of the frame header below).
  --==========================================================================================
  p_bus_timing_checker : process is
    variable v_mdc_edges       : t_mdio_mdc_edges;               -- no initialisation needed
    variable v_bit             : std_ulogic;                     -- the last bit sampled
    variable v_ones            : natural := 0;                   -- consecutive '1'/'H' bits (saturating at 32)
    variable v_ones_before_bit : natural;
    variable v_idle_bit_driver : t_mdio_bit_driver := NOT_CHECKED; -- who drives the first bit after a frame
    variable v_header          : t_mdio_header;                  -- ST OP PHYAD/PRTAD REGAD/DEVAD
    variable v_access_bits     : natural := 0;                   -- consecutive bits sampled with a BFM call running

    -- name of a valid frame, for the alert message
    function frame_name(
      constant st : in std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0);
      constant op : in std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0)) return string is
    begin
      if st = C_MDIO_ST_CL22 then
        if op = C_MDIO_OP_CL22_WRITE then
          return "Clause 22 write";
        end if;
        return "Clause 22 read";
      elsif op = C_MDIO_OP_CL45_ADDR then
        return "Clause 45 address";
      elsif op = C_MDIO_OP_CL45_WRITE then
        return "Clause 45 write";
      elsif op = C_MDIO_OP_CL45_READ_INC then
        return "Clause 45 post-read-increment-address";
      end if;
      return "Clause 45 read";
    end function frame_name;

    -- PHY mode: report a frame to this PHY's address that no mdio_phy_* call has seen from its start. Called at the
    -- end of the frame header. The call must have run without a break from the first bit await_start_of_frame() needs
    -- to find the frame (the first of the 32 preamble bits with sync_to_frame_start (default), else the first ST bit)
    -- up to here. A call that ended within the header (terminated) has not handled the frame either.
    procedure check_unwanted_frame is
      constant C_ST          : std_ulogic_vector(C_MDIO_ST_WIDTH-1 downto 0)       := mdio_header_st(v_header);
      constant C_OP          : std_ulogic_vector(C_MDIO_OP_WIDTH-1 downto 0)       := mdio_header_op(v_header);
      constant C_PHY_ADDR    : std_ulogic_vector(C_MDIO_PHY_ADDR_WIDTH-1 downto 0) := mdio_header_phy_addr(v_header);
      variable v_needed_bits : natural := v_header'length; -- bits sampled by the call: ST to the end of the header
    begin
      if GC_STA_MODE or mdio_get_frame_kind(C_ST, C_OP) = FRAME_INVALID or
         C_PHY_ADDR /= std_ulogic_vector(vvc_config.bfm_config.phy.phy_address) then
        return;
      end if;
      if vvc_config.bfm_config.sync_to_frame_start and not vvc_config.bfm_config.suppress_preamble then
        v_needed_bits := C_MDIO_PREAMBLE_LENGTH + v_header'length;
      end if;
      if v_access_bits < v_needed_bits then
        if C_ST = C_MDIO_ST_CL22 then
          alert(vvc_config.unwanted_activity_severity, "Unwanted activity detected. " & frame_name(C_ST, C_OP) &
                " frame to this PHY (PHYAD " & to_string(C_PHY_ADDR, HEX, AS_IS, INCL_RADIX) & ", REGAD " &
                to_string(mdio_header_reg_or_dev_addr(v_header), HEX, AS_IS, INCL_RADIX) & ") while no PHY command was waiting for it.", C_SCOPE);
        else
          alert(vvc_config.unwanted_activity_severity, "Unwanted activity detected. " & frame_name(C_ST, C_OP) &
                " frame to this PHY (PRTAD " & to_string(C_PHY_ADDR, HEX, AS_IS, INCL_RADIX) & ", DEVAD " &
                to_string(mdio_header_reg_or_dev_addr(v_header), HEX, AS_IS, INCL_RADIX) & ") while no PHY command was waiting for it.", C_SCOPE);
        end if;
      end if;
    end procedure check_unwanted_frame;

    -- wait for the next bit and check its timing, 'driver' tells who drives it. Counts the ones for the preamble.
    procedure check_next_bit(constant driver : in t_mdio_bit_driver) is
      variable v_alert_level : t_alert_level := NO_ALERT; -- checker disabled: the frames are still followed
    begin
      if vvc_config.bus_timing_checker.enable then
        v_alert_level := vvc_config.bus_timing_checker.alert_level;
      end if;
      mdio_check_bit_timing(mdio_vvc_if, driver, v_mdc_edges, v_bit, C_CHECKED_SIDE, v_alert_level,
                            C_SCOPE, vvc_config.msg_id_panel, vvc_config.bfm_config);
      if v_bit = '1' or v_bit = 'H' then
        v_ones := minimum(v_ones + 1, C_MDIO_PREAMBLE_LENGTH);
      else
        v_ones := 0;
      end if;
      -- the transaction info is IN_PROGRESS exactly while the executor runs a BFM call
      if vvc_transaction_info.bt.transaction_status = IN_PROGRESS then
        v_access_bits := minimum(v_access_bits + 1, C_MDIO_PREAMBLE_LENGTH + v_header'length);
      else
        v_access_bits := 0;
      end if;
    end procedure check_next_bit;
  begin
    wait for 0 ns; -- give the vvc_constructor time to set the vvc_config

    loop
      -- Idle bus or preamble, until a frame starts with the '0' of ST: after 32 ones, or right away with suppress_preamble
      loop
        v_ones_before_bit := v_ones;
        check_next_bit(v_idle_bit_driver);
        v_idle_bit_driver := STA_DRIVES;
        exit when (v_bit = '0' or v_bit = 'L') and
                  (vvc_config.bfm_config.suppress_preamble or v_ones_before_bit = C_MDIO_PREAMBLE_LENGTH);
      end loop;

      -- Frame: the STA sends the second bit of ST, OP, PHYAD/PRTAD and REGAD/DEVAD
      v_header(v_header'high) := '0';
      for i in v_header'high-1 downto 0 loop
        check_next_bit(STA_DRIVES);
        v_header(i) := to_X01(v_bit);
      end loop;
      check_unwanted_frame;

      case mdio_get_frame_kind(mdio_header_st(v_header), mdio_header_op(v_header)) is
        when FRAME_STA_DRIVEN =>                    -- write / address: the STA sends turnaround "10" and the data
          for i in 1 to C_MDIO_TA_WIDTH + C_MDIO_DATA_WIDTH loop
            check_next_bit(STA_DRIVES);
          end loop;
        when FRAME_PHY_DRIVEN =>                    -- read
          check_next_bit(STA_RELEASES);             -- turnaround bit 1: the STA releases MDIO
          for i in 1 to 1 + C_MDIO_DATA_WIDTH loop  -- turnaround bit 0 and the data, from the PHY
            check_next_bit(PHY_DRIVES);
          end loop;
          v_idle_bit_driver := PHY_RELEASES;        -- the bit after the frame
        when FRAME_INVALID =>                       -- not followed, the rest is checked as an idle bus
          null;
      end case;
    end loop;
  end process p_bus_timing_checker;

  --==========================================================================================
  -- Unwanted activity detection
  -- - Monitors unwanted activity from the DUT
  -- - STA mode: any change on MDIO while the VVC is inactive (here).
  -- - PHY mode: a frame to this PHY's address that no PHY command was waiting for (in p_bus_timing_checker, which
  --   decodes the frames). Other activity of the DUT (STA) is normal bus traffic.
  --==========================================================================================
  p_unwanted_activity : process is
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

      -- STA mode: the DUT (PHY) outputs are MDIO; MDC is generated by the VVC. PHY mode: see above.
      if GC_STA_MODE then
        wait on mdio_vvc_if.mdio, global_trigger_vvc_activity_register;
      else
        wait on global_trigger_vvc_activity_register;
      end if;

      -- Check the changes on the DUT outputs only when the vvc is inactive
      if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = INACTIVE then
        if GC_STA_MODE then
          check_unwanted_activity(mdio_vvc_if.mdio, vvc_config.unwanted_activity_severity, "mdio", C_SCOPE);
        end if;
      end if;
    end loop;
  end process p_unwanted_activity;
  --==========================================================================================

  --==========================================================================================
  -- Weak pull-up on MDIO
  -- - In both modes, only with GC_MDIO_PULLUP = true. By default (false) the test harness provides the pull-up
  --==========================================================================================
  g_mdio_pullup : if GC_MDIO_PULLUP generate
    mdio_vvc_if.mdio <= 'H';
  end generate g_mdio_pullup;
--==========================================================================================
end architecture behave;
-- vim:ts=2:shiftwidth=2:
