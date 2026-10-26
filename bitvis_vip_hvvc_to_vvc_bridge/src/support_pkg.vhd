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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

package support_pkg is

  --==========================================================================================
  -- Methods
  --==========================================================================================
  procedure blocking_send_to_bridge(
    signal   hvvc_to_bridge   : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc   : in t_bridge_to_hvvc;
    constant data_words       : in t_slv_array;
    constant dut_if_field_idx : in integer;
    constant dut_if_field_pos : in t_field_position;
    constant scope            : in string;
    constant msg_id_panel     : in t_msg_id_panel
  );

  procedure blocking_request_from_bridge(
    signal   hvvc_to_bridge   : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc   : in t_bridge_to_hvvc;
    constant num_data_words   : in positive;
    constant dut_if_field_idx : in integer;
    constant dut_if_field_pos : in t_field_position;
    constant scope            : in string;
    constant msg_id_panel     : in t_msg_id_panel
  );

  procedure get_dut_address_config(
    constant dut_if_field_config   : in t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge        : in t_hvvc_to_bridge;
    variable dut_address           : out unsigned;
    variable dut_address_increment : out integer
  );

  procedure get_data_width_config(
    constant dut_if_field_config : in t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge      : in t_hvvc_to_bridge;
    variable data_width          : out positive
  );

end package support_pkg;

package body support_pkg is

  -- Send a data array to the bridge and wait for it to finish
  procedure blocking_send_to_bridge(
    signal   hvvc_to_bridge   : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc   : in t_bridge_to_hvvc;
    constant data_words       : in t_slv_array;
    constant dut_if_field_idx : in integer;
    constant dut_if_field_pos : in t_field_position;
    constant scope            : in string;
    constant msg_id_panel     : in t_msg_id_panel
  ) is
  begin
    hvvc_to_bridge.operation                              <= TRANSMIT;
    hvvc_to_bridge.data_words(0 to data_words'length - 1) <= data_words;
    hvvc_to_bridge.num_data_words                         <= data_words'length;
    hvvc_to_bridge.dut_if_field_idx                       <= dut_if_field_idx;
    hvvc_to_bridge.dut_if_field_pos                       <= dut_if_field_pos;
    hvvc_to_bridge.msg_id_panel                           <= msg_id_panel;
    gen_pulse(hvvc_to_bridge.trigger, 0 ns, "Pulsing hvvc_to_bridge trigger", scope, ID_NEVER);
    wait until bridge_to_hvvc.trigger = true;
    wait for 0 ns;                      -- Wait for a delta cycle to allow gen_pulse() from bridge to finish executing
  end procedure blocking_send_to_bridge;

  -- Request a number of data words from the bridge and wait for it to finish
  procedure blocking_request_from_bridge(
    signal   hvvc_to_bridge   : inout t_hvvc_to_bridge;
    signal   bridge_to_hvvc   : in t_bridge_to_hvvc;
    constant num_data_words   : in positive;
    constant dut_if_field_idx : in integer;
    constant dut_if_field_pos : in t_field_position;
    constant scope            : in string;
    constant msg_id_panel     : in t_msg_id_panel
  ) is
  begin
    hvvc_to_bridge.operation        <= RECEIVE;
    hvvc_to_bridge.num_data_words   <= num_data_words;
    hvvc_to_bridge.dut_if_field_idx <= dut_if_field_idx;
    hvvc_to_bridge.dut_if_field_pos <= dut_if_field_pos;
    hvvc_to_bridge.msg_id_panel     <= msg_id_panel;
    gen_pulse(hvvc_to_bridge.trigger, 0 ns, "Pulsing hvvc_to_bridge trigger", scope, ID_NEVER);
    wait until bridge_to_hvvc.trigger = true;
    wait for 0 ns;                      -- Wait for a delta cycle to allow gen_pulse() from bridge to finish executing
  end procedure blocking_request_from_bridge;

  -- Returns the DUT address config for a specific field
  procedure get_dut_address_config(
    constant dut_if_field_config   : in t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge        : in t_hvvc_to_bridge;
    variable dut_address           : out unsigned;
    variable dut_address_increment : out integer
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
      dut_address           := dut_if_field_config(v_direction)(dut_if_field_config(v_direction)'high).dut_address;
    else
      dut_address_increment := dut_if_field_config(v_direction)(hvvc_to_bridge.dut_if_field_idx).dut_address_increment;
      dut_address           := dut_if_field_config(v_direction)(hvvc_to_bridge.dut_if_field_idx).dut_address;
    end if;
  end procedure get_dut_address_config;

  -- Returns the DUT data width config for a specific field
  procedure get_data_width_config(
    constant dut_if_field_config : in t_dut_if_field_config_direction_array;
    signal   hvvc_to_bridge      : in t_hvvc_to_bridge;
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
