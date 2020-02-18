--================================================================================================================================
-- Copyright (c) 2020 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

library bitvis_vip_hvvc_to_vvc_bridge;
use bitvis_vip_hvvc_to_vvc_bridge.common_methods_pkg.all;

use work.ethernet_bfm_pkg.all;
use work.ethernet_sb_pkg.all;
use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;
use work.transaction_pkg.all;

--==========================================================================================
entity ethernet_receive_vvc is
  generic(
    GC_INSTANCE_IDX                          : natural;
    GC_CHANNEL                               : t_channel;
    GC_INTERFACE                             : t_interface;
    GC_VVC_INSTANCE_IDX                      : natural;
    GC_DUT_IF_FIELD_CONFIG                   : t_dut_if_field_config_direction_array;
    GC_ETHERNET_BFM_CONFIG                   : t_ethernet_bfm_config := C_ETHERNET_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural               := 1000;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural               := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level         := WARNING;
    GC_RESULT_QUEUE_COUNT_MAX                : natural               := 1000;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural               := 950;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level         := WARNING
  );
end entity ethernet_receive_vvc;

--==========================================================================================
--==========================================================================================
architecture behave of ethernet_receive_vvc is

  constant C_SCOPE      : string        := C_VVC_NAME & "," & to_string(GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels  := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, GC_CHANNEL);

  signal executor_is_busy       : boolean := false;
  signal queue_is_increasing    : boolean := false;
  signal last_cmd_idx_executed  : natural := 0;
  signal terminate_current_cmd  : t_flag_record;
  signal hvvc_to_bridge         : t_hvvc_to_bridge(data_bytes(0 to C_MAX_PACKET_LENGTH-1));
  signal bridge_to_hvvc         : t_bridge_to_hvvc(data_bytes(0 to C_MAX_PACKET_LENGTH-1));

  -- Instantiation of the element dedicated executor
  shared variable command_queue : work.td_cmd_queue_pkg.t_generic_queue;
  shared variable result_queue  : work.td_result_queue_pkg.t_generic_queue;

  alias vvc_config       : t_vvc_config       is shared_ethernet_vvc_config(GC_CHANNEL, GC_INSTANCE_IDX);
  alias vvc_status       : t_vvc_status       is shared_ethernet_vvc_status(GC_CHANNEL, GC_INSTANCE_IDX);
  alias transaction_info : t_transaction_info is shared_ethernet_transaction_info(GC_CHANNEL, GC_INSTANCE_IDX);
    -- DTT
  alias dtt_trigger      : std_logic           is global_ethernet_vvc_transaction_trigger(GC_CHANNEL, GC_INSTANCE_IDX);
  alias dtt_info         : t_transaction_group is shared_ethernet_vvc_transaction_info(GC_CHANNEL, GC_INSTANCE_IDX);
  -- Activity Watchdog
  signal vvc_idx_for_activity_watchdog : integer;

begin

--==========================================================================================
-- HVVC-to-VVC Bridge
--==========================================================================================
  i_hvvc_to_vvc_bridge : entity bitvis_vip_hvvc_to_vvc_bridge.hvvc_to_vvc_bridge
    generic map(
      GC_INTERFACE           => GC_INTERFACE,
      GC_INSTANCE_IDX        => GC_VVC_INSTANCE_IDX,
      GC_DUT_IF_FIELD_CONFIG => GC_DUT_IF_FIELD_CONFIG,
      GC_MAX_NUM_BYTES       => C_MAX_PACKET_LENGTH,
      GC_SCOPE               => C_SCOPE
    )
    port map(
      hvvc_to_bridge => hvvc_to_bridge,
      bridge_to_hvvc => bridge_to_hvvc
    );


--==========================================================================================
-- Constructor
-- - Set up the defaults and show constructor if enabled
--==========================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, GC_ETHERNET_BFM_CONFIG,
                  GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
                  GC_RESULT_QUEUE_COUNT_MAX, GC_RESULT_QUEUE_COUNT_THRESHOLD, GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY);
--==========================================================================================


--==========================================================================================
-- Command interpreter
-- - Interpret, decode and acknowledge commands from the central sequencer
--==========================================================================================
  cmd_interpreter : process
     variable v_cmd_has_been_acked : boolean; -- Indicates if acknowledge_cmd() has been called for the current shared_vvc_cmd
     variable v_local_vvc_cmd      : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;
     variable v_msg_id_panel       : t_msg_id_panel;
  begin

    -- 0. Initialize the process prior to first command
    work.td_vvc_entity_support_pkg.initialize_interpreter(terminate_current_cmd, global_awaiting_completion);
    -- initialise shared_vvc_last_received_cmd_idx for channel and instance
    shared_vvc_last_received_cmd_idx(GC_CHANNEL, GC_INSTANCE_IDX) := 0;

    -- Register VVC in activity watchdog register
    vvc_idx_for_activity_watchdog <= shared_activity_watchdog.priv_register_vvc(name      => "ETHERNET",
                                                                                channel   => GC_CHANNEL,
                                                                                instance  => GC_INSTANCE_IDX);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    -- Then for every single command from the sequencer
    loop  -- basically as long as new commands are received

      -- 1. wait until command targeted at this VVC. Must match VVC name, instance and channel (if applicable)
      --    releases global semaphore
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.await_cmd_from_sequencer(C_VVC_LABELS, vvc_config, THIS_VVCT, VVC_BROADCAST, global_vvc_busy, global_vvc_ack, v_local_vvc_cmd, v_msg_id_panel);
      v_cmd_has_been_acked := false; -- Clear flag
      -- Update shared_vvc_last_received_cmd_idx with received command index
      shared_vvc_last_received_cmd_idx(GC_CHANNEL, GC_INSTANCE_IDX) := v_local_vvc_cmd.cmd_idx;
      -- Update v_msg_id_panel
      v_msg_id_panel := get_msg_id_panel(v_local_vvc_cmd, vvc_config);

      -- 2a. Put command on the executor if intended for the executor
      -------------------------------------------------------------------------
      if v_local_vvc_cmd.command_type = QUEUED then
        work.td_vvc_entity_support_pkg.put_command_on_queue(v_local_vvc_cmd, command_queue, vvc_status, queue_is_increasing);

      -- 2b. Otherwise command is intended for immediate response
      -------------------------------------------------------------------------
      elsif v_local_vvc_cmd.command_type = IMMEDIATE then
        case v_local_vvc_cmd.operation is

          when AWAIT_COMPLETION =>
            -- Await completion of all commands in the cmd_executor executor
            work.td_vvc_entity_support_pkg.interpreter_await_completion(v_local_vvc_cmd, command_queue, vvc_config, executor_is_busy, C_VVC_LABELS, last_cmd_idx_executed);

          when AWAIT_ANY_COMPLETION =>
            if not v_local_vvc_cmd.gen_boolean then
              -- Called with lastness = NOT_LAST: Acknowledge immediately to let the sequencer continue
              work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack,v_local_vvc_cmd.cmd_idx);
              v_cmd_has_been_acked := true;
            end if;
            work.td_vvc_entity_support_pkg.interpreter_await_any_completion(v_local_vvc_cmd, command_queue, vvc_config, executor_is_busy, C_VVC_LABELS, last_cmd_idx_executed, global_awaiting_completion);

          when DISABLE_LOG_MSG =>
            uvvm_util.methods_pkg.disable_log_msg(v_local_vvc_cmd.msg_id, v_msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when ENABLE_LOG_MSG =>
            uvvm_util.methods_pkg.enable_log_msg(v_local_vvc_cmd.msg_id, v_msg_id_panel, to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);

          when FLUSH_COMMAND_QUEUE =>
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, command_queue, vvc_config, vvc_status, C_VVC_LABELS);

          when TERMINATE_CURRENT_COMMAND =>
            work.td_vvc_entity_support_pkg.interpreter_terminate_current_command(v_local_vvc_cmd, vvc_config, C_VVC_LABELS, terminate_current_cmd, executor_is_busy);

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
        work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack,v_local_vvc_cmd.cmd_idx);
      end if;

    end loop;
  end process;
--==========================================================================================



--==========================================================================================
-- Command executor
-- - Fetch and execute the commands
--==========================================================================================
  cmd_executor : process
    constant C_RECEIVE_PROC_CALL : string := "Ethernet receive";
    constant C_EXPECT_PROC_CALL  : string := "Ethernet expect";

    variable v_cmd                                   : work.vvc_cmd_pkg.t_vvc_cmd_record;
    variable v_result                                : work.vvc_cmd_pkg.t_vvc_result; -- See vvc_cmd_pkg
    variable v_received_data                         : t_ethernet_frame;
    variable v_expected_data                         : t_ethernet_frame;
    variable v_fcs_error                             : boolean;
    variable v_timestamp_start_of_current_bfm_access : time := 0 ns;
    variable v_timestamp_start_of_last_bfm_access    : time := 0 ns;
    variable v_timestamp_end_of_last_bfm_access      : time := 0 ns;
    variable v_command_is_bfm_access                 : boolean := false;
    variable v_prev_command_was_bfm_access           : boolean := false;
    variable v_msg_id_panel                          : t_msg_id_panel;
    variable v_ethernet_packet_raw                   : t_byte_array(0 to C_MAX_PACKET_LENGTH-1);
    variable v_payload_length                        : integer;
    variable v_preamble_sfd                          : std_logic_vector(63 downto 0) := (others => '0');
    variable v_frame_passed                          : boolean;

    -- Local overload
    procedure blocking_send_to_bridge(
      constant num_data_bytes            : in positive;
      constant dut_if_field_idx          : in integer
    ) is
      constant C_CURRENT_BYTE_IDX_IN_FIELD : natural := 0;
    begin
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, RECEIVE, num_data_bytes, dut_if_field_idx, C_CURRENT_BYTE_IDX_IN_FIELD, v_msg_id_panel, vvc_config.field_timeout_margin);
    end procedure blocking_send_to_bridge;

    procedure receive_ethernet_packet(
      constant proc_call : in string
    ) is
    begin
      v_received_data := C_ETHERNET_FRAME_DEFAULT;
      -- Await preamble and SFD
      while true loop
        -- Fetch one byte at the time until SFD is found
        blocking_send_to_bridge(1, C_IF_FIELD_NUM_ETHERNET_PREAMBLE_SFD);
        v_preamble_sfd := v_preamble_sfd(55 downto 0) & bridge_to_hvvc.data_bytes(0);
        v_ethernet_packet_raw(1 to 7) := v_ethernet_packet_raw(0 to 6);
        v_ethernet_packet_raw(0)      := bridge_to_hvvc.data_bytes(0);
        if v_preamble_sfd = C_PREAMBLE & C_SFD then
          exit;
        end if;
      end loop;

      -- Read MAC destination
      -- Send to bridge
      blocking_send_to_bridge(6, C_IF_FIELD_NUM_ETHERNET_MAC_DESTINATION);
      v_ethernet_packet_raw(8 to 13)  := bridge_to_hvvc.data_bytes(0 to 5);
      v_received_data.mac_destination := unsigned(to_slv(v_ethernet_packet_raw( 8 to 13)));
      -- Add info to the transaction_for_waveview_struct
      transaction_info.ethernet_frame.mac_destination := v_received_data.mac_destination;

      -- Read MAC source
      -- Send to bridge
      blocking_send_to_bridge(6, C_IF_FIELD_NUM_ETHERNET_MAC_SOURCE);
      v_ethernet_packet_raw(14 to 19) := bridge_to_hvvc.data_bytes(0 to 5);
      v_received_data.mac_source      := unsigned(to_slv(v_ethernet_packet_raw(14 to 19)));
      -- Add info to the transaction_for_waveview_struct
      transaction_info.ethernet_frame.mac_source := v_received_data.mac_source;

      -- Read length
      -- Send to bridge
      blocking_send_to_bridge(2, C_IF_FIELD_NUM_ETHERNET_LENTGTH);
      v_ethernet_packet_raw(20 to 21) := bridge_to_hvvc.data_bytes(0 to 1);
      v_received_data.length          := to_integer(unsigned(to_slv(v_ethernet_packet_raw(20 to 21))));
      -- Add info to the transaction_for_waveview_struct
      transaction_info.ethernet_frame.length := v_received_data.length;

      log(ID_PACKET_HDR, proc_call & ": Packet header received." & format_command_idx(v_cmd.cmd_idx) & hdr_to_string(v_received_data), C_SCOPE, v_msg_id_panel);

      -- Check length and if payload is padded
      if v_received_data.length > C_MAX_PAYLOAD_LENGTH then
        alert(ERROR, "Payload is larger than maximum alowed length, " & to_string(C_MAX_PAYLOAD_LENGTH) & " octets (bytes).", C_SCOPE);
      end if;
      if v_received_data.length < C_MIN_PAYLOAD_LENGTH then
        v_payload_length := C_MIN_PAYLOAD_LENGTH;
      else
        v_payload_length := v_received_data.length;
      end if;

      -- Read payload
      blocking_send_to_bridge(v_payload_length, C_IF_FIELD_NUM_ETHERNET_PAYLOAD);
      v_ethernet_packet_raw(22 to 22+v_payload_length-1) := bridge_to_hvvc.data_bytes(0 to v_payload_length-1);
      v_received_data.payload                            := (others => (others => '-')); -- Riviera pro don't allow non-static and others in aggregates
      v_received_data.payload(0 to v_payload_length-1)   := v_ethernet_packet_raw(22 to 22+v_payload_length-1);
      -- Add info to the transaction_for_waveview_struct
      transaction_info.ethernet_frame.payload := v_received_data.payload;

      log(ID_PACKET_DATA, proc_call & ": Packet data received." & format_command_idx(v_cmd.cmd_idx) & data_to_string(v_received_data), C_SCOPE, v_msg_id_panel);

      -- Read FCS
      blocking_send_to_bridge(4, C_IF_FIELD_NUM_ETHERNET_FCS);
      v_ethernet_packet_raw(22+v_payload_length to 22+v_payload_length+4-1) := bridge_to_hvvc.data_bytes(0 to 3);
      v_received_data.fcs                                                   := to_slv(reverse_vectors_in_array(v_ethernet_packet_raw(22+v_payload_length to 22+v_payload_length+4-1)));
      transaction_info.ethernet_frame.fcs                                   := v_received_data.fcs;
      v_fcs_error                                                           := not check_crc_32(reverse_vectors_in_array(v_ethernet_packet_raw(8 to 22+v_payload_length+4-1)));
      log(ID_PACKET_COMPLETE, proc_call & ": Packet received. " & complete_to_string(v_received_data) & format_command_idx(v_cmd.cmd_idx), C_SCOPE, v_msg_id_panel);
      check_value(v_fcs_error, false, vvc_config.bfm_config.fcs_error_severity, "Check FCS value", C_SCOPE, ID_NEVER, v_msg_id_panel);
    end procedure receive_ethernet_packet;

  begin

    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);

    -- Setup ETHERNET scoreboard
    shared_ethernet_sb.set_scope("ETHERNET VVC");
    shared_ethernet_sb.enable(GC_INSTANCE_IDX, "SB ETHERNET Enabled");
    shared_ethernet_sb.config(GC_INSTANCE_IDX, C_SB_CONFIG_DEFAULT);
    shared_ethernet_sb.enable_log_msg(ID_DATA);
    -- Set initial value of v_msg_id_panel to msg_id_panel in config
    v_msg_id_panel := vvc_config.msg_id_panel;

    loop

      -- Notify activity watchdog
      activity_watchdog_register_vvc_state(global_trigger_activity_watchdog, false, vvc_idx_for_activity_watchdog, last_cmd_idx_executed, C_SCOPE);

      -- 1. Set defaults, fetch command and log
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing, executor_is_busy, C_VVC_LABELS, v_msg_id_panel);

      -- Notify activity watchdog
      activity_watchdog_register_vvc_state(global_trigger_activity_watchdog, true, vvc_idx_for_activity_watchdog, last_cmd_idx_executed, C_SCOPE);

      -- Reset the transaction info for waveview
      transaction_info := C_TRANSACTION_INFO_DEFAULT;
      transaction_info.operation := v_cmd.operation;
      transaction_info.msg := pad_string(to_string(v_cmd.msg), ' ', transaction_info.msg'length);

      -- Update v_msg_id_panel
      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);

      -- Check if command is a BFM access
      v_prev_command_was_bfm_access := v_command_is_bfm_access; -- save for inter_bfm_delay
      if v_cmd.operation = RECEIVE or v_cmd.operation = EXPECT then
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
        when RECEIVE =>
          log(ID_PACKET_INITIATE, C_RECEIVE_PROC_CALL & ": Await ethernet packet." & format_command_idx(v_cmd.cmd_idx), C_SCOPE, v_msg_id_panel);

          -- Receive Ethernet packet
          receive_ethernet_packet(C_RECEIVE_PROC_CALL);

          v_result.ethernet_frame                  := v_received_data;
          v_result.ethernet_frame_status.fcs_error := v_fcs_error;

          if v_cmd.data_routing = TO_SB then
            -- Send result to scoreboard
            shared_ethernet_sb.check_received(GC_INSTANCE_IDX, v_result.ethernet_frame);
          else
            -- Store the result
            work.td_vvc_entity_support_pkg.store_result(result_queue  => result_queue,
                                                        cmd_idx       => v_cmd.cmd_idx,
                                                        result        => v_result);
          end if;

        when EXPECT =>
          -- For FCS calculation
          v_ethernet_packet_raw( 8 to 13)                := to_byte_array(std_logic_vector(v_cmd.mac_destination));
          v_ethernet_packet_raw(14 to 19)                := to_byte_array(std_logic_vector(v_cmd.mac_source));
          v_ethernet_packet_raw(20 to 21)                := to_byte_array(std_logic_vector(to_unsigned(v_cmd.length, 16)));
          v_ethernet_packet_raw(22 to 22+v_cmd.length-1) := v_cmd.payload(0 to v_cmd.length-1);
          if v_cmd.length < C_MIN_PAYLOAD_LENGTH then
            v_payload_length := C_MIN_PAYLOAD_LENGTH;
            v_ethernet_packet_raw(22+v_cmd.length to 22+v_payload_length) := (others => (others => '0'));
          else
            v_payload_length := v_cmd.length;
          end if;

          v_expected_data                 := C_ETHERNET_FRAME_DEFAULT;
          v_expected_data.mac_destination := v_cmd.mac_destination;
          v_expected_data.mac_source      := v_cmd.mac_source;
          v_expected_data.length          := v_cmd.length;
          v_expected_data.payload         := v_cmd.payload;
          v_expected_data.fcs             := not generate_crc_32_complete(reverse_vectors_in_array(v_ethernet_packet_raw(8 to 22+v_payload_length-1)));

          log(ID_PACKET_INITIATE, C_EXPECT_PROC_CALL & ": Expecting ethernet packet. " & complete_to_string(v_expected_data) & format_command_idx(v_cmd.cmd_idx), C_SCOPE, v_msg_id_panel);

          receive_ethernet_packet(C_EXPECT_PROC_CALL);

          -- Check received frame against expected frame
          v_frame_passed := compare_ethernet_frames(v_received_data, v_expected_data, v_cmd.alert_level, format_msg(v_cmd), C_SCOPE, v_msg_id_panel, C_EXPECT_PROC_CALL);

          if v_frame_passed then
            log(ID_PACKET_COMPLETE, C_EXPECT_PROC_CALL & " => OK. " & add_msg_delimiter(v_cmd.msg) & format_command_idx(v_cmd.cmd_idx), C_SCOPE, v_msg_id_panel);
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
            --<USER_INPUT> Uncomment if BFM has clock_period config
            -- check_value(vvc_config.bfm_config.clock_period > -1 ns, TB_ERROR, "Check that clock_period is configured when using insert_delay().",
            --             C_SCOPE, ID_NEVER, v_msg_id_panel);
            -- wait until terminate_current_cmd.is_active = '1' for v_cmd.gen_integer_array(0) * vvc_config.bfm_config.clock_period;
          end if;

        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_SCOPE);
      end case;

      if v_command_is_bfm_access then
        v_timestamp_end_of_last_bfm_access := now;
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
      -- Reset the transaction info for waveview
      transaction_info   := C_TRANSACTION_INFO_DEFAULT;

      -- Set DTT back to default values
      reset_dtt_info(dtt_info, v_cmd);

    end loop;
  end process;
--==========================================================================================



--==========================================================================================
-- Command termination handler
-- - Handles the termination request record (sets and resets terminate flag on request)
--==========================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd);  -- flag: is_active, set, reset
--==========================================================================================


end behave;