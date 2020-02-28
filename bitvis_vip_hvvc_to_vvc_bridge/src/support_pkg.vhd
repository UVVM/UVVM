--================================================================================================================================
-- Copyright 2020 Bitvis and Inventas AS
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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

package support_pkg is

  --==========================================================================================
  -- Methods
  --==========================================================================================
  procedure hvvc_to_bridge_trigger(
    signal hvvc_to_bridge : out t_hvvc_to_bridge
  );

  procedure bridge_to_hvvc_trigger(
    signal bridge_to_hvvc : out t_bridge_to_hvvc
  );

  procedure send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    constant operation                 : in  t_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  );

  procedure send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    constant operation                 : in  t_vvc_operation;
    constant num_data_bytes            : in  positive;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  );

  procedure blocking_send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    signal   bridge_to_hvvc            : in  t_bridge_to_hvvc;
    constant operation                 : in  t_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  );

  procedure blocking_send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    signal   bridge_to_hvvc            : in  t_bridge_to_hvvc;
    constant operation                 : in  t_vvc_operation;
    constant num_data_bytes            : in  positive;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  );

  procedure get_dut_address_config(
    constant dut_if_field_config    : in  t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge         : in  t_hvvc_to_bridge;
    variable dut_address            : out unsigned;
    variable dut_address_increment  : out integer
  );

  procedure get_data_width_config(
    constant dut_if_field_config : in  t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge      : in  t_hvvc_to_bridge;
    variable data_width          : out positive
  );

end package support_pkg;


package body support_pkg is

  -- Sends a delta cycle pulse in the hvvc_to_bridge.trigger signal
  procedure hvvc_to_bridge_trigger(
    signal hvvc_to_bridge : out t_hvvc_to_bridge
  ) is
  begin
    hvvc_to_bridge.trigger <= true;
    wait for 0 ns;
    hvvc_to_bridge.trigger <= false;
  end procedure hvvc_to_bridge_trigger;

  -- Sends a delta cycle pulse in the bridge_to_hvvc.trigger signal
  procedure bridge_to_hvvc_trigger(
    signal bridge_to_hvvc : out t_bridge_to_hvvc
  ) is
  begin
    bridge_to_hvvc.trigger <= true;
    wait for 0 ns;
    bridge_to_hvvc.trigger <= false;
  end procedure bridge_to_hvvc_trigger;

  -- Send an operation to the bridge using a data array
  procedure send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    constant operation                 : in  t_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  ) is
    -- Need to normalize array range or Riviera Pro fails with error code: 'DAGGEN ERROR DAGGEN_0700: "Fatal error : INTERNAL CODE GENERATOR ERROR"'
    constant C_NORMALIZED_DATA_BYTES : t_byte_array(0 to data_bytes'length-1) := data_bytes;
  begin
    hvvc_to_bridge.operation                            <= operation;
    hvvc_to_bridge.num_data_bytes                       <= data_bytes'length;
    hvvc_to_bridge.data_bytes(0 to data_bytes'length-1) <= C_NORMALIZED_DATA_BYTES;
    hvvc_to_bridge.dut_if_field_idx                     <= dut_if_field_idx;
    hvvc_to_bridge.current_byte_idx_in_field            <= current_byte_idx_in_field;
    hvvc_to_bridge.msg_id_panel                         <= msg_id_panel;
    hvvc_to_bridge.field_timeout_margin                 <= field_timeout_margin;
    hvvc_to_bridge_trigger(hvvc_to_bridge);
  end procedure send_to_bridge;

  -- Send an operation to the bridge using number of data bytes
  procedure send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    constant operation                 : in  t_vvc_operation;
    constant num_data_bytes            : in  positive;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  ) is
  begin
    hvvc_to_bridge.operation                            <= operation;
    hvvc_to_bridge.num_data_bytes                       <= num_data_bytes;
    hvvc_to_bridge.dut_if_field_idx                     <= dut_if_field_idx;
    hvvc_to_bridge.current_byte_idx_in_field            <= current_byte_idx_in_field;
    hvvc_to_bridge.msg_id_panel                         <= msg_id_panel;
    hvvc_to_bridge.field_timeout_margin                 <= field_timeout_margin;
    hvvc_to_bridge_trigger(hvvc_to_bridge);
  end procedure send_to_bridge;

  -- Send an operation to the bridge using a data array and wait for bridge to finish
  procedure blocking_send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    signal   bridge_to_hvvc            : in  t_bridge_to_hvvc;
    constant operation                 : in  t_vvc_operation;
    constant data_bytes                : in  t_byte_array;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  ) is
  begin
    send_to_bridge(hvvc_to_bridge, operation, data_bytes, dut_if_field_idx, current_byte_idx_in_field, msg_id_panel, field_timeout_margin);
    wait until bridge_to_hvvc.trigger = true;
  end procedure blocking_send_to_bridge;

  -- Send an operation to the bridge using number of data bytes and wait for bridge to finish
  procedure blocking_send_to_bridge(
    signal   hvvc_to_bridge            : out t_hvvc_to_bridge;
    signal   bridge_to_hvvc            : in  t_bridge_to_hvvc;
    constant operation                 : in  t_vvc_operation;
    constant num_data_bytes            : in  positive;
    constant dut_if_field_idx          : in  integer;
    constant current_byte_idx_in_field : in  natural;
    constant msg_id_panel              : in  t_msg_id_panel;
    constant field_timeout_margin      : in  time
  ) is
  begin
    send_to_bridge(hvvc_to_bridge, operation, num_data_bytes, dut_if_field_idx, current_byte_idx_in_field, msg_id_panel, field_timeout_margin);
    wait until bridge_to_hvvc.trigger = true;
  end procedure blocking_send_to_bridge;

  -- Returns the DUT address config for a specific field
  procedure get_dut_address_config(
    constant dut_if_field_config    : in  t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge         : in  t_hvvc_to_bridge;
    variable dut_address            : out unsigned;
    variable dut_address_increment  : out integer
  ) is
    variable v_direction : t_direction;
  begin
    if hvvc_to_bridge.operation = TRANSMIT then -- Expand if other operations
      v_direction := TRANSMIT;
    else
      v_direction := RECEIVE;
    end if;

    -- If no configs are defined for all fields the last config is used
    if hvvc_to_bridge.dut_if_field_idx > dut_if_field_config(v_direction)'high then
      dut_address_increment := dut_if_field_config(v_direction)(dut_if_field_config(v_direction)'high).dut_address_increment;
      dut_address := dut_if_field_config(v_direction)(dut_if_field_config(v_direction)'high).dut_address +
        (hvvc_to_bridge.current_byte_idx_in_field*dut_address_increment);
    else
      dut_address_increment := dut_if_field_config(v_direction)(hvvc_to_bridge.dut_if_field_idx).dut_address_increment;
      dut_address := dut_if_field_config(v_direction)(hvvc_to_bridge.dut_if_field_idx).dut_address +
        (hvvc_to_bridge.current_byte_idx_in_field*dut_address_increment);
    end if;
  end procedure get_dut_address_config;

  -- Returns the DUT data width config for a specific field
  procedure get_data_width_config(
    constant dut_if_field_config : in  t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge      : in  t_hvvc_to_bridge;
    variable data_width          : out positive
  ) is
    variable v_direction : t_direction;
  begin
    if hvvc_to_bridge.operation = TRANSMIT then -- Expand if other operations
      v_direction := TRANSMIT;
    else
      v_direction := RECEIVE;
    end if;

    -- If no configs are defined for all fields the last config is used
    if hvvc_to_bridge.dut_if_field_idx > dut_if_field_config(v_direction)'high then
      data_width := dut_if_field_config(v_direction)(dut_if_field_config(v_direction)'high).data_width;
    else
      data_width := dut_if_field_config(v_direction)(hvvc_to_bridge.dut_if_field_idx).data_width;
    end if;
  end procedure get_data_width_config;

end package body support_pkg;