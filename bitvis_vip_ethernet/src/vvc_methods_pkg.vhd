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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_hvvc_to_vvc_bridge;
use bitvis_vip_hvvc_to_vvc_bridge.support_pkg.all;

use work.support_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.transaction_pkg.all;
use work.vvc_sb_pkg.all;

--==========================================================================================
--==========================================================================================
package vvc_methods_pkg is

  --==========================================================================================
  -- Types and constants for the ETHERNET VVC
  --==========================================================================================
  constant C_VVC_NAME : string := "ETHERNET_VVC";

  signal ETHERNET_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT      : t_vvc_target_record is ETHERNET_VVCT;
  alias t_bfm_config is t_ethernet_protocol_config;

  -- Type found in UVVM-Util types_pkg
  constant C_ETHERNET_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => WARNING
  );

  -- For debugging enable the rest of the msg ids in the test sequencer
  constant C_ETHERNET_VVC_MSG_ID_PANEL_DEFAULT : t_msg_id_panel := (
    ID_PACKET_INITIATE => ENABLED,
    ID_PACKET_COMPLETE => ENABLED,
    ID_PACKET_PREAMBLE => DISABLED,
    ID_PACKET_HDR      => DISABLED,
    ID_PACKET_DATA     => DISABLED,
    ID_PACKET_CHECKSUM => DISABLED,
    ID_PACKET_GAP      => DISABLED,
    others             => DISABLED
  );

  type t_vvc_config is record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between protocol accesses from the VVC. If parameter delay_type is set to NO_DELAY, protocol accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural; -- Maximum pending number in command executor before executor is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural; -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level; -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold.
    result_queue_count_max                : natural;
    result_queue_count_threshold          : natural;
    result_queue_count_threshold_severity : t_alert_level;
    bfm_config                            : t_ethernet_protocol_config; -- Configuration for the VVC protocol. See VVC quick reference.
    msg_id_panel                          : t_msg_id_panel; -- VVC dedicated message ID panel.
  end record;

  type t_vvc_config_array is array (t_channel range <>, natural range <>) of t_vvc_config;

  constant C_ETHERNET_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_ETHERNET_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    bfm_config                            => C_ETHERNET_PROTOCOL_CONFIG_DEFAULT,
    msg_id_panel                          => C_ETHERNET_VVC_MSG_ID_PANEL_DEFAULT
  );

  type t_vvc_status is record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record;

  type t_vvc_status_array is array (t_channel range <>, natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
  );

  shared variable shared_ethernet_vvc_config : t_vvc_config_array(t_channel'left to t_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_ETHERNET_VVC_CONFIG_DEFAULT));
  shared variable shared_ethernet_vvc_status : t_vvc_status_array(t_channel'left to t_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_VVC_STATUS_DEFAULT));
  shared variable ETHERNET_VVC_SB            : t_generic_sb;

  --==========================================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --==========================================================================================
  procedure ethernet_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant mac_source       : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure ethernet_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure ethernet_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure ethernet_receive(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant data_routing     : in t_data_routing;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure ethernet_receive(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure ethernet_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant mac_source       : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant alert_level      : in t_alert_level := ERROR;
    constant scope            : in string        := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure ethernet_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant alert_level      : in t_alert_level := ERROR;
    constant scope            : in string        := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure ethernet_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant alert_level      : in t_alert_level := ERROR;
    constant scope            : in string        := C_VVC_CMD_SCOPE_DEFAULT
  );

  --==========================================================================================
  -- Methods calling the HVVC-to-VVC bridge (for internal HVVC use)
  -- - These procedures are called from the HVVC to execute calls to the HVVC-to-VVC bridge.
  --   The bridge will then transfer the calls to the VVC in the physical layer which will
  --   execute the data transactions.
  --==========================================================================================
  procedure priv_ethernet_transmit_to_bridge(
    constant interpacket_gap_time : in time;
    constant vvc_cmd              : in t_vvc_cmd_record;
    constant dut_if_field_config  : in t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in t_bridge_to_hvvc;
    variable vvc_transaction_info : inout t_transaction_group;
    constant scope                : in string;
    constant msg_id_panel         : in t_msg_id_panel
  );

  procedure priv_ethernet_receive_from_bridge(
    variable received_frame       : out t_ethernet_frame;
    variable fcs_error            : out boolean;
    constant fcs_error_severity   : in t_alert_level;
    constant vvc_cmd              : in t_vvc_cmd_record;
    constant dut_if_field_config  : in t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in t_bridge_to_hvvc;
    variable vvc_transaction_info : inout t_transaction_group;
    constant scope                : in string;
    constant msg_id_panel         : in t_msg_id_panel;
    constant ext_proc_call        : in string := "" -- External proc_call. Overwrite if called from another procedure
  );

  procedure priv_ethernet_expect_from_bridge(
    constant fcs_error_severity   : in t_alert_level;
    constant vvc_cmd              : in t_vvc_cmd_record;
    constant dut_if_field_config  : in t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in t_bridge_to_hvvc;
    variable vvc_transaction_info : inout t_transaction_group;
    constant scope                : in string;
    constant msg_id_panel         : in t_msg_id_panel
  );

  --==============================================================================
  -- Transaction info methods
  --==============================================================================
  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT);

  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_result                   : in t_vvc_result;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT);

  procedure reset_vvc_transaction_info(
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record);

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  --==========================================================================================
  -- Methods dedicated to this VVC
  --==========================================================================================
  procedure ethernet_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant mac_source       : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "ethernet_transmit";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel) -- First part common for all
                                   & ", MAC dest: " & to_string(mac_destination, HEX, AS_IS, INCL_RADIX) & ", MAC src: " & to_string(mac_source, HEX, AS_IS, INCL_RADIX) & ", payload length: " & to_string(payload'length) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, TRANSMIT);
    shared_vvc_cmd.mac_destination                  := mac_destination;
    shared_vvc_cmd.mac_source                       := mac_source;
    shared_vvc_cmd.payload_length                   := payload'length;
    shared_vvc_cmd.payload(0 to payload'length - 1) := payload;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, shared_msg_id_panel);
  end procedure ethernet_transmit;

  procedure ethernet_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    ethernet_transmit(VVCT, vvc_instance_idx, channel, mac_destination,
                      shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_source, payload, msg, scope);
  end procedure ethernet_transmit;

  procedure ethernet_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    ethernet_transmit(VVCT, vvc_instance_idx, channel, shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_destination,
                      shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_source, payload, msg, scope);
  end procedure ethernet_transmit;

  procedure ethernet_receive(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant data_routing     : in t_data_routing;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "ethernet_receive";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, RECEIVE);
    shared_vvc_cmd.data_routing := data_routing;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, shared_msg_id_panel);
  end procedure ethernet_receive;

  procedure ethernet_receive(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    ethernet_receive(VVCT, vvc_instance_idx, channel, NA, msg, scope);
  end procedure ethernet_receive;

  procedure ethernet_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant mac_source       : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant alert_level      : in t_alert_level := ERROR;
    constant scope            : in string        := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "ethernet_expect";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel) -- First part common for all
                                   & ", MAC dest: " & to_string(mac_destination, HEX, AS_IS, INCL_RADIX) & ", MAC src: " & to_string(mac_source, HEX, AS_IS, INCL_RADIX) & ", payload length: " & to_string(payload'length) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, EXPECT);
    shared_vvc_cmd.mac_destination                  := mac_destination;
    shared_vvc_cmd.mac_source                       := mac_source;
    shared_vvc_cmd.payload_length                   := payload'length;
    shared_vvc_cmd.payload(0 to payload'length - 1) := payload;
    shared_vvc_cmd.alert_level                      := alert_level;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, shared_msg_id_panel);
  end procedure ethernet_expect;

  procedure ethernet_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant mac_destination  : in unsigned(47 downto 0);
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant alert_level      : in t_alert_level := ERROR;
    constant scope            : in string        := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    ethernet_expect(VVCT, vvc_instance_idx, channel, mac_destination,
                    shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_destination, payload, msg, alert_level, scope);
  end procedure ethernet_expect;

  procedure ethernet_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant channel          : in t_channel;
    constant payload          : in t_byte_array;
    constant msg              : in string;
    constant alert_level      : in t_alert_level := ERROR;
    constant scope            : in string        := C_VVC_CMD_SCOPE_DEFAULT
  ) is
  begin
    ethernet_expect(VVCT, vvc_instance_idx, channel, shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_source,
                    shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_destination, payload, msg, alert_level, scope);
  end procedure ethernet_expect;

  --==========================================================================================
  -- Methods calling the HVVC-to-VVC bridge (for internal HVVC use)
  --==========================================================================================
  procedure priv_ethernet_transmit_to_bridge(
    constant interpacket_gap_time : in time;
    constant vvc_cmd              : in t_vvc_cmd_record;
    constant dut_if_field_config  : in t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in t_bridge_to_hvvc;
    variable vvc_transaction_info : inout t_transaction_group;
    constant scope                : in string;
    constant msg_id_panel         : in t_msg_id_panel
  ) is
    constant proc_name              : string           := "ethernet_transmit";
    constant proc_call              : string           := proc_name & "(MAC dest: " & to_string(vvc_cmd.mac_destination, HEX, AS_IS, INCL_RADIX) & ", MAC src: " & to_string(vvc_cmd.mac_source, HEX, AS_IS, INCL_RADIX) & ", payload length: " & to_string(vvc_cmd.payload_length) & ")";
    variable v_packet               : t_byte_array(0 to C_MAX_PACKET_LENGTH - 1);
    variable v_frame                : t_ethernet_frame;
    variable v_payload_length       : natural;
    variable v_crc_32               : std_logic_vector(31 downto 0);
    variable v_use_preamble_and_sfd : boolean;
    variable v_use_mac_dest         : boolean;
    variable v_use_mac_source       : boolean;
    variable v_use_payload_length   : boolean;
    variable v_use_payload          : boolean;
    variable v_use_fcs              : boolean;
    variable v_pos_preamble_and_sfd : t_field_position := MIDDLE;
    variable v_pos_mac_dest         : t_field_position := MIDDLE;
    variable v_pos_mac_source       : t_field_position := MIDDLE;
    variable v_pos_payload_length   : t_field_position := MIDDLE;
    variable v_pos_payload          : t_field_position := MIDDLE;
    variable v_pos_fcs              : t_field_position := MIDDLE;

  begin
    -- Preamble (LSb first)
    v_packet(0 to 6) := convert_slv_to_byte_array(C_PREAMBLE, LOWER_BYTE_LEFT);
    -- SFD (LSb first)
    v_packet(7)      := C_SFD;

    -- MAC destination (LSb first)
    v_packet(8 to 13)       := convert_slv_to_byte_array(std_logic_vector(vvc_cmd.mac_destination), LOWER_BYTE_LEFT);
    v_frame.mac_destination := vvc_cmd.mac_destination;
    -- MAC source (LSb first)
    v_packet(14 to 19)      := convert_slv_to_byte_array(std_logic_vector(vvc_cmd.mac_source), LOWER_BYTE_LEFT);
    v_frame.mac_source      := vvc_cmd.mac_source;
    -- Payload length (LSb first)
    v_packet(20 to 21)      := convert_slv_to_byte_array(std_logic_vector(to_unsigned(vvc_cmd.payload_length, 16)), LOWER_BYTE_LEFT);
    v_frame.payload_length  := vvc_cmd.payload_length;
    v_payload_length        := vvc_cmd.payload_length;
    -- Check payload length is within limits
    if vvc_cmd.payload_length > C_MAX_PAYLOAD_LENGTH then
      alert(ERROR, "Payload is larger than maximum allowed length, " & to_string(C_MAX_PAYLOAD_LENGTH) & " octets (bytes).", scope);
    end if;

    -- Payload (LSb first)
    v_packet(22 to 22 + vvc_cmd.payload_length - 1) := vvc_cmd.payload(0 to vvc_cmd.payload_length - 1);
    v_frame.payload                                 := vvc_cmd.payload;
    -- Add padding bytes if payload length is less than C_MIN_PAYLOAD_LENGTH
    if vvc_cmd.payload_length < C_MIN_PAYLOAD_LENGTH then
      v_payload_length                                                   := C_MIN_PAYLOAD_LENGTH;
      v_packet(22 + vvc_cmd.payload_length to 22 + v_payload_length - 1) := (others => (others => '0'));
    end if;

    -- Calculate the FCS with the MAC addresses, payload length and payload data
    v_crc_32                                                         := generate_crc_32(v_packet(8 to 22 + v_payload_length - 1));
    -- Post complement the CRC according to Ethernet standard
    v_crc_32                                                         := not (v_crc_32);
    -- FCS (MSb first). Convert slv to byte_array with MSB first and then reverse the bits in each byte so MSb is transmitted first
    v_packet(22 + v_payload_length to 22 + v_payload_length + 4 - 1) := reverse_vectors_in_array(convert_slv_to_byte_array(v_crc_32, LOWER_BYTE_LEFT));
    v_frame.fcs                                                      := v_crc_32;

    -- Add info to the vvc_transaction_info
    vvc_transaction_info.bt.ethernet_frame.fcs := v_crc_32;

    -- Check which fields should be used (sent or requested to/from the bridge) according to config.
    -- If there's a field which is not configured it will be used by default, e.g. when writing
    -- the whole packet to a FIFO and don't want to specify the address of each field (which is
    -- the same) in the config.
    v_use_preamble_and_sfd := true when C_FIELD_IDX_PREAMBLE_AND_SFD > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_PREAMBLE_AND_SFD).use_field;
    v_use_mac_dest         := true when C_FIELD_IDX_MAC_DESTINATION > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_MAC_DESTINATION).use_field;
    v_use_mac_source       := true when C_FIELD_IDX_MAC_SOURCE > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_MAC_SOURCE).use_field;
    v_use_payload_length   := true when C_FIELD_IDX_PAYLOAD_LENGTH > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_PAYLOAD_LENGTH).use_field;
    v_use_payload          := true when C_FIELD_IDX_PAYLOAD > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_PAYLOAD).use_field;
    v_use_fcs              := true when C_FIELD_IDX_FCS > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_FCS).use_field;

    -- Check which are the first and last used fields in the packet. If there is
    -- only one field then it will be FIRST_AND_LAST.
    if v_use_preamble_and_sfd then
      v_pos_preamble_and_sfd := FIRST;
    elsif v_use_mac_dest then
      v_pos_mac_dest := FIRST;
    elsif v_use_mac_source then
      v_pos_mac_source := FIRST;
    elsif v_use_payload_length then
      v_pos_payload_length := FIRST;
    elsif v_use_payload then
      v_pos_payload := FIRST;
    elsif v_use_fcs then
      v_pos_fcs := FIRST;
    end if;
    if v_use_fcs then
      v_pos_fcs := LAST when v_pos_fcs /= FIRST else FIRST_AND_LAST;
    elsif v_use_payload then
      v_pos_payload := LAST when v_pos_payload /= FIRST else FIRST_AND_LAST;
    elsif v_use_payload_length then
      v_pos_payload_length := LAST when v_pos_payload_length /= FIRST else FIRST_AND_LAST;
    elsif v_use_mac_source then
      v_pos_mac_source := LAST when v_pos_mac_source /= FIRST else FIRST_AND_LAST;
    elsif v_use_mac_dest then
      v_pos_mac_dest := LAST when v_pos_mac_dest /= FIRST else FIRST_AND_LAST;
    elsif v_use_preamble_and_sfd then
      v_pos_preamble_and_sfd := LAST when v_pos_preamble_and_sfd /= FIRST else FIRST_AND_LAST;
    end if;

    log(ID_PACKET_INITIATE, proc_call & ". Start transmitting packet. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);

    -- Send only configured fields to the bridge
    if v_use_preamble_and_sfd then
      log(ID_PACKET_PREAMBLE, proc_call & ". Transmitting preamble. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, v_packet(0 to 7), C_FIELD_IDX_PREAMBLE_AND_SFD,
                              v_pos_preamble_and_sfd, scope, msg_id_panel);
    end if;
    if v_use_mac_dest or v_use_mac_source or v_use_payload_length then
      log(ID_PACKET_HDR, proc_call & ". Transmitting header. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx) & to_string(v_frame, HEADER), scope, msg_id_panel);
    end if;
    if v_use_mac_dest then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, v_packet(8 to 13), C_FIELD_IDX_MAC_DESTINATION,
                              v_pos_mac_dest, scope, msg_id_panel);
    end if;
    if v_use_mac_source then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, v_packet(14 to 19), C_FIELD_IDX_MAC_SOURCE,
                              v_pos_mac_source, scope, msg_id_panel);
    end if;
    if v_use_payload_length then
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, v_packet(20 to 21), C_FIELD_IDX_PAYLOAD_LENGTH,
                              v_pos_payload_length, scope, msg_id_panel);
    end if;
    if v_use_payload then
      log(ID_PACKET_DATA, proc_call & ". Transmitting payload. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx) & to_string(v_frame, PAYLOAD), scope, msg_id_panel);
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, v_packet(22 to 22 + v_payload_length - 1), C_FIELD_IDX_PAYLOAD,
                              v_pos_payload, scope, msg_id_panel);
    end if;
    if v_use_fcs then
      log(ID_PACKET_CHECKSUM, proc_call & ". Transmitting FCS. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx) & to_string(v_frame, CHECKSUM), scope, msg_id_panel);
      blocking_send_to_bridge(hvvc_to_bridge, bridge_to_hvvc, v_packet(22 + v_payload_length to 22 + v_payload_length + 4 - 1), C_FIELD_IDX_FCS,
                              v_pos_fcs, scope, msg_id_panel);
    end if;

    log(ID_PACKET_COMPLETE, proc_call & ". Finished transmitting packet. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);

    -- Interpacket gap
    log(ID_PACKET_GAP, "Waiting for the interpacket gap. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
    wait for interpacket_gap_time;
  end procedure priv_ethernet_transmit_to_bridge;

  procedure priv_ethernet_receive_from_bridge(
    variable received_frame       : out t_ethernet_frame;
    variable fcs_error            : out boolean;
    constant fcs_error_severity   : in t_alert_level;
    constant vvc_cmd              : in t_vvc_cmd_record;
    constant dut_if_field_config  : in t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in t_bridge_to_hvvc;
    variable vvc_transaction_info : inout t_transaction_group;
    constant scope                : in string;
    constant msg_id_panel         : in t_msg_id_panel;
    constant ext_proc_call        : in string := "" -- External proc_call. Overwrite if called from another procedure
  ) is
    constant local_proc_name          : string                        := "ethernet_receive";
    constant local_proc_call          : string                        := local_proc_name & "()";
    variable v_preamble_and_sfd       : std_logic_vector(63 downto 0) := (others => '0');
    variable v_packet                 : t_byte_array(0 to C_MAX_PACKET_LENGTH - 1);
    alias a_bridge_to_hvvc_data_words : t_byte_array(0 to C_MAX_PACKET_LENGTH-1) is bridge_to_hvvc.data_words; -- Temporary fix to bug in Questa Sim 2022.1
    variable v_payload_length         : integer;
    variable v_proc_call              : line; -- Current proc_call, external or local
    variable v_use_preamble_and_sfd   : boolean;
    variable v_use_mac_dest           : boolean;
    variable v_use_mac_source         : boolean;
    variable v_use_payload_length     : boolean;
    variable v_use_payload            : boolean;
    variable v_use_fcs                : boolean;
    variable v_pos_preamble_and_sfd   : t_field_position              := MIDDLE;
    variable v_pos_mac_dest           : t_field_position              := MIDDLE;
    variable v_pos_mac_source         : t_field_position              := MIDDLE;
    variable v_pos_payload_length     : t_field_position              := MIDDLE;
    variable v_pos_payload            : t_field_position              := MIDDLE;
    variable v_pos_fcs                : t_field_position              := MIDDLE;
  begin
    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'ethernet_receive...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another procedure, log 'ext_proc_call while executing ethernet_receive...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    received_frame := C_ETHERNET_FRAME_DEFAULT;

    -- Check which fields should be used (sent or requested to/from the bridge) according to config.
    -- If there's a field which is not configured it will be used by default, e.g. when writing
    -- the whole packet to a FIFO and don't want to specify the address of each field (which is
    -- the same) in the config.
    v_use_preamble_and_sfd := true when C_FIELD_IDX_PREAMBLE_AND_SFD > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_PREAMBLE_AND_SFD).use_field;
    v_use_mac_dest         := true when C_FIELD_IDX_MAC_DESTINATION > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_MAC_DESTINATION).use_field;
    v_use_mac_source       := true when C_FIELD_IDX_MAC_SOURCE > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_MAC_SOURCE).use_field;
    v_use_payload_length   := true when C_FIELD_IDX_PAYLOAD_LENGTH > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_PAYLOAD_LENGTH).use_field;
    v_use_payload          := true when C_FIELD_IDX_PAYLOAD > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_PAYLOAD).use_field;
    v_use_fcs              := true when C_FIELD_IDX_FCS > dut_if_field_config'high else
                              dut_if_field_config(C_FIELD_IDX_FCS).use_field;

    -- Check which are the first and last used fields in the packet. If there is
    -- only one field then it will be FIRST_AND_LAST.
    if v_use_preamble_and_sfd then
      v_pos_preamble_and_sfd := FIRST;
    elsif v_use_mac_dest then
      v_pos_mac_dest := FIRST;
    elsif v_use_mac_source then
      v_pos_mac_source := FIRST;
    elsif v_use_payload_length then
      v_pos_payload_length := FIRST;
    elsif v_use_payload then
      v_pos_payload := FIRST;
    elsif v_use_fcs then
      v_pos_fcs := FIRST;
    end if;
    if v_use_fcs then
      v_pos_fcs := LAST when v_pos_fcs /= FIRST else FIRST_AND_LAST;
    elsif v_use_payload then
      v_pos_payload := LAST when v_pos_payload /= FIRST else FIRST_AND_LAST;
    elsif v_use_payload_length then
      v_pos_payload_length := LAST when v_pos_payload_length /= FIRST else FIRST_AND_LAST;
    elsif v_use_mac_source then
      v_pos_mac_source := LAST when v_pos_mac_source /= FIRST else FIRST_AND_LAST;
    elsif v_use_mac_dest then
      v_pos_mac_dest := LAST when v_pos_mac_dest /= FIRST else FIRST_AND_LAST;
    elsif v_use_preamble_and_sfd then
      v_pos_preamble_and_sfd := LAST when v_pos_preamble_and_sfd /= FIRST else FIRST_AND_LAST;
    end if;

    log(ID_PACKET_INITIATE, v_proc_call.all & ". Waiting for packet. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);

    -- Await preamble and SFD (if configured)
    if v_use_preamble_and_sfd then
      loop
        -- Fetch one byte at the time until SFD is found
        blocking_request_from_bridge(hvvc_to_bridge, bridge_to_hvvc, 1, C_FIELD_IDX_PREAMBLE_AND_SFD, v_pos_preamble_and_sfd, scope, msg_id_panel);
        v_preamble_and_sfd     := v_preamble_and_sfd(55 downto 0) & bridge_to_hvvc.data_words(0);
        if v_preamble_and_sfd = C_PREAMBLE & C_SFD then
          exit;
        end if;
        v_pos_preamble_and_sfd := MIDDLE; -- Avoid repeating the first field log for each byte
      end loop;
      v_packet(0 to 7) := convert_slv_to_byte_array(v_preamble_and_sfd, LOWER_BYTE_LEFT);
      log(ID_PACKET_PREAMBLE, v_proc_call.all & ". Preamble received. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
    end if;

    -- Read MAC destination from bridge (if configured)
    if v_use_mac_dest then
      blocking_request_from_bridge(hvvc_to_bridge, bridge_to_hvvc, 6, C_FIELD_IDX_MAC_DESTINATION, v_pos_mac_dest, scope, msg_id_panel);
      --v_packet(8 to 13)              := bridge_to_hvvc.data_words(0 to 5);
      v_packet(8 to 13)                                      := a_bridge_to_hvvc_data_words(0 to 5); -- Temporary fix for bug in Questa Sim 2022.1
      received_frame.mac_destination                         := unsigned(convert_byte_array_to_slv(v_packet(8 to 13), LOWER_BYTE_LEFT));
      -- Add info to the vvc_transaction_info
      vvc_transaction_info.bt.ethernet_frame.mac_destination := received_frame.mac_destination;
    end if;

    -- Read MAC source from bridge (if configured)
    if v_use_mac_source then
      blocking_request_from_bridge(hvvc_to_bridge, bridge_to_hvvc, 6, C_FIELD_IDX_MAC_SOURCE, v_pos_mac_source, scope, msg_id_panel);
      --v_packet(14 to 19)        := bridge_to_hvvc.data_words(0 to 5);
      v_packet(14 to 19)                                := a_bridge_to_hvvc_data_words(0 to 5); -- Temporary fix for bug in Questa Sim 2022.1
      received_frame.mac_source                         := unsigned(convert_byte_array_to_slv(v_packet(14 to 19), LOWER_BYTE_LEFT));
      -- Add info to the vvc_transaction_info
      vvc_transaction_info.bt.ethernet_frame.mac_source := received_frame.mac_source;
    end if;

    -- Read payload length from bridge (if configured)
    if v_use_payload_length then
      blocking_request_from_bridge(hvvc_to_bridge, bridge_to_hvvc, 2, C_FIELD_IDX_PAYLOAD_LENGTH, v_pos_payload_length, scope, msg_id_panel);
      --v_packet(20 to 21)            := bridge_to_hvvc.data_words(0 to 1);
      v_packet(20 to 21)                                    := a_bridge_to_hvvc_data_words(0 to 1); -- Temporary fix for bug in Questa Sim 2022.1
      received_frame.payload_length                         := to_integer(unsigned(convert_byte_array_to_slv(v_packet(20 to 21), LOWER_BYTE_LEFT)));
      v_payload_length                                      := received_frame.payload_length;
      -- Add info to the vvc_transaction_info
      vvc_transaction_info.bt.ethernet_frame.payload_length := received_frame.payload_length;
    end if;
    if v_use_mac_dest or v_use_mac_source or v_use_payload_length then
      log(ID_PACKET_HDR, v_proc_call.all & ". Header received. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx) & to_string(received_frame, HEADER), scope, msg_id_panel);
    end if;
    -- Check payload length is within limits
    if v_payload_length > C_MAX_PAYLOAD_LENGTH then
      alert(ERROR, "Payload is larger than maximum allowed length, " & to_string(C_MAX_PAYLOAD_LENGTH) & " octets (bytes).", scope);
    end if;

    -- Read payload from bridge (if configured)
    if v_use_payload then
      if v_payload_length < C_MIN_PAYLOAD_LENGTH then
        v_payload_length := C_MIN_PAYLOAD_LENGTH;
      end if;
      blocking_request_from_bridge(hvvc_to_bridge, bridge_to_hvvc, v_payload_length, C_FIELD_IDX_PAYLOAD, v_pos_payload, scope, msg_id_panel);
      v_packet(22 to 22 + v_payload_length - 1)                      := bridge_to_hvvc.data_words(0 to v_payload_length - 1);
      received_frame.payload(0 to received_frame.payload_length - 1) := v_packet(22 to 22 + received_frame.payload_length - 1); -- Discard padding bytes
      -- Add info to the vvc_transaction_info
      vvc_transaction_info.bt.ethernet_frame.payload                 := received_frame.payload;
      log(ID_PACKET_DATA, v_proc_call.all & ". Payload received. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx) & to_string(received_frame, PAYLOAD), scope, msg_id_panel);
    end if;

    -- Read FCS from bridge (if configured)
    if v_use_fcs then
      blocking_request_from_bridge(hvvc_to_bridge, bridge_to_hvvc, 4, C_FIELD_IDX_FCS, v_pos_fcs, scope, msg_id_panel);
      --v_packet(22+v_payload_length to 22+v_payload_length+4-1) := bridge_to_hvvc.data_words(0 to 3);
      v_packet(22 + v_payload_length to 22 + v_payload_length + 4 - 1) := a_bridge_to_hvvc_data_words(0 to 3); -- Temporary fix for bug in Questa Sim 2022.1
      -- For the FCS the MSb is received first, so we need to reverse the bits in each byte
      received_frame.fcs                                               := convert_byte_array_to_slv(reverse_vectors_in_array(v_packet(22 + v_payload_length to 22 + v_payload_length + 4 - 1)), LOWER_BYTE_LEFT);
      -- Add info to the vvc_transaction_info
      vvc_transaction_info.bt.ethernet_frame.fcs                       := received_frame.fcs;
      log(ID_PACKET_CHECKSUM, v_proc_call.all & ". FCS received. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx) & to_string(received_frame, CHECKSUM), scope, msg_id_panel);
      -- Check the CRC of the received frame
      fcs_error                                                        := not check_crc_32(v_packet(8 to 22 + v_payload_length + 4 - 1));
      check_value(fcs_error, false, fcs_error_severity, "Check FCS value", scope, ID_NEVER, msg_id_panel);
    end if;

    if ext_proc_call = "" then
      log(ID_PACKET_COMPLETE, v_proc_call.all & ". Finished receiving packet. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. ethernet_expect)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure priv_ethernet_receive_from_bridge;

  procedure priv_ethernet_expect_from_bridge(
    constant fcs_error_severity   : in t_alert_level;
    constant vvc_cmd              : in t_vvc_cmd_record;
    constant dut_if_field_config  : in t_dut_if_field_config_array;
    signal   hvvc_to_bridge       : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc       : in t_bridge_to_hvvc;
    variable vvc_transaction_info : inout t_transaction_group;
    constant scope                : in string;
    constant msg_id_panel         : in t_msg_id_panel
  ) is
    constant proc_name        : string           := "ethernet_expect";
    constant proc_call        : string           := proc_name & "(MAC dest: " & to_string(vvc_cmd.mac_destination, HEX, AS_IS, INCL_RADIX) & ", MAC src: " & to_string(vvc_cmd.mac_source, HEX, AS_IS, INCL_RADIX) & ", payload length: " & to_string(vvc_cmd.payload_length) & ")";
    variable v_expected_frame : t_ethernet_frame := C_ETHERNET_FRAME_DEFAULT;
    variable v_received_frame : t_ethernet_frame;
    variable v_fcs_error      : boolean;
    variable v_frame_passed   : boolean          := true;
  begin
    v_expected_frame.mac_destination := vvc_cmd.mac_destination;
    v_expected_frame.mac_source      := vvc_cmd.mac_source;
    v_expected_frame.payload_length  := vvc_cmd.payload_length;
    v_expected_frame.payload         := vvc_cmd.payload;

    -- Receive frame
    priv_ethernet_receive_from_bridge(received_frame       => v_received_frame,
                                      fcs_error            => v_fcs_error,
                                      fcs_error_severity   => fcs_error_severity,
                                      vvc_cmd              => vvc_cmd,
                                      dut_if_field_config  => dut_if_field_config,
                                      hvvc_to_bridge       => hvvc_to_bridge,
                                      bridge_to_hvvc       => bridge_to_hvvc,
                                      vvc_transaction_info => vvc_transaction_info,
                                      scope                => scope,
                                      msg_id_panel         => msg_id_panel,
                                      ext_proc_call        => proc_call);

    -- Check received frame against expected frame
    if not check_value(v_received_frame.mac_destination, v_expected_frame.mac_destination, vvc_cmd.alert_level, "Verify MAC destination. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call) then
      v_frame_passed := false;
    end if;
    if not check_value(v_received_frame.mac_source, v_expected_frame.mac_source, vvc_cmd.alert_level, "Verify MAC source. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call) then
      v_frame_passed := false;
    end if;
    if not check_value(v_received_frame.payload_length, v_expected_frame.payload_length, vvc_cmd.alert_level, "Verify payload length. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, ID_NEVER, msg_id_panel, proc_call) then
      v_frame_passed := false;
    end if;
    for i in 0 to v_received_frame.payload_length - 1 loop
      if not check_value(v_received_frame.payload(i), v_expected_frame.payload(i), vvc_cmd.alert_level, "Verify payload byte " & to_string(i) & ". " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call) then
        v_frame_passed := false;
      end if;
    end loop;
    if v_fcs_error then
      v_frame_passed := false;
    end if;

    if v_frame_passed then
      log(ID_PACKET_COMPLETE, proc_call & " => OK. " & add_msg_delimiter(vvc_cmd.msg) & format_command_idx(vvc_cmd.cmd_idx), scope, msg_id_panel);
    end if;
  end procedure priv_ethernet_expect_from_bridge;

  --==============================================================================
  -- Transaction info methods
  --==============================================================================
  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT) is
  begin
    case vvc_cmd.operation is
      when TRANSMIT | RECEIVE | EXPECT =>
        vvc_transaction_info_group.bt.operation                      := vvc_cmd.operation;
        vvc_transaction_info_group.bt.ethernet_frame.mac_destination := vvc_cmd.mac_destination;
        vvc_transaction_info_group.bt.ethernet_frame.mac_source      := vvc_cmd.mac_source;
        vvc_transaction_info_group.bt.ethernet_frame.payload_length  := vvc_cmd.payload_length;
        vvc_transaction_info_group.bt.ethernet_frame.payload         := vvc_cmd.payload;
        vvc_transaction_info_group.bt.vvc_meta.msg                   := vvc_cmd.msg;
        vvc_transaction_info_group.bt.vvc_meta.cmd_idx               := vvc_cmd.cmd_idx;
        vvc_transaction_info_group.bt.transaction_status             := transaction_status;
        gen_pulse(vvc_transaction_info_trigger, 0 ns, "pulsing global vvc transaction info trigger", scope, ID_NEVER);

      when others =>
        alert(TB_ERROR, "VVC operation not recognized", scope);
    end case;

    wait for 0 ns;
  end procedure set_global_vvc_transaction_info;

  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_result                   : in t_vvc_result;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT) is
  begin
    case vvc_cmd.operation is
      when RECEIVE =>
        vvc_transaction_info_group.bt.ethernet_frame     := vvc_result.ethernet_frame;
        vvc_transaction_info_group.bt.transaction_status := transaction_status;
        gen_pulse(vvc_transaction_info_trigger, 0 ns, "pulsing global vvc transaction info trigger", scope, ID_NEVER);

      when others =>
        alert(TB_ERROR, "VVC operation does not update vvc_result", scope);
    end case;

    wait for 0 ns;
  end procedure set_global_vvc_transaction_info;

  procedure reset_vvc_transaction_info(
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record) is
  begin
    case vvc_cmd.operation is
      when TRANSMIT | RECEIVE | EXPECT =>
        vvc_transaction_info_group.bt := C_BASE_TRANSACTION_SET_DEFAULT;

      when others =>
        null;
    end case;

    wait for 0 ns;
  end procedure reset_vvc_transaction_info;

end package body vvc_methods_pkg;
