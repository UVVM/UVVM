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

use work.support_pkg.all;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

architecture GMII of hvvc_to_vvc_bridge is
begin

  p_executor : process
    constant c_data_words_width             : natural   := hvvc_to_bridge.data_words(hvvc_to_bridge.data_words'low)'length;
    variable v_byte_endianness              : t_byte_endianness;
    variable v_cmd_idx                      : integer;
    variable v_gmii_received_data           : bitvis_vip_gmii.vvc_cmd_pkg.t_vvc_result;
    variable v_dut_data_width               : positive;
    variable v_num_transfers                : integer;
    variable v_num_data_bytes               : positive;
    variable v_data_bytes                   : t_byte_array(0 to GC_MAX_NUM_WORDS * c_data_words_width / 8 - 1);
    variable v_channel                      : t_channel := NA;
    variable v_dut_if_field_pos_is_first    : boolean;
    variable v_dut_if_field_pos_is_last     : boolean;
    variable v_disabled_msg_id_int_wait     : boolean;
    variable v_disabled_msg_id_exe_wait     : boolean;
    variable v_action_when_transfer_is_done : t_action_when_transfer_is_done;
    --UVVM: temporary fix for HVVC, remove 2 lines below in v3.0
    variable v_disabled_msg_id_int          : boolean;
    variable v_disabled_msg_id_exe          : boolean;

    -- Disables a previously enabled msg_id in the VVC's shared config
    impure function disable_gmii_vvc_msg_id(
      constant channel      : t_channel;
      constant instance_idx : integer;
      constant msg_id       : t_msg_id
    ) return boolean is
      variable v_disable_id : boolean := false;
    begin
      if shared_gmii_vvc_config(channel, instance_idx).msg_id_panel(msg_id) = ENABLED then
        shared_gmii_vvc_config(channel, instance_idx).msg_id_panel(msg_id) := DISABLED;
        v_disable_id                                                       := true;
      end if;
      return v_disable_id;
    end function;

  begin
    if GC_WORD_ENDIANNESS = LOWER_WORD_LEFT or GC_WORD_ENDIANNESS = LOWER_BYTE_LEFT then
      v_byte_endianness := LOWER_BYTE_LEFT;
    else
      v_byte_endianness := LOWER_BYTE_RIGHT;
    end if;

    loop

      -- Await cmd from the HVVC
      wait until hvvc_to_bridge.trigger = true;

      -- Check the field position in the packet
      v_dut_if_field_pos_is_first := hvvc_to_bridge.dut_if_field_pos = FIRST or hvvc_to_bridge.dut_if_field_pos = FIRST_AND_LAST;
      v_dut_if_field_pos_is_last  := hvvc_to_bridge.dut_if_field_pos = LAST or hvvc_to_bridge.dut_if_field_pos = FIRST_AND_LAST;

      if hvvc_to_bridge.operation = TRANSMIT then
        v_channel := TX;
      elsif hvvc_to_bridge.operation = RECEIVE then
        v_channel := RX;
      end if;

      if v_dut_if_field_pos_is_first then
        log(ID_NEW_HVVC_CMD_SEQ, "VVC is busy while executing an HVVC command", "GMII_VVC," & to_string(GC_INSTANCE_IDX), shared_gmii_vvc_config(v_channel, GC_INSTANCE_IDX).msg_id_panel);
        -- Disable the interpreter and executor waiting logs during the HVVC command
        v_disabled_msg_id_int_wait := disable_gmii_vvc_msg_id(v_channel, GC_INSTANCE_IDX, ID_CMD_INTERPRETER_WAIT);
        v_disabled_msg_id_exe_wait := disable_gmii_vvc_msg_id(v_channel, GC_INSTANCE_IDX, ID_CMD_EXECUTOR_WAIT);
        --UVVM: temporary fix for HVVC, remove 2 lines below in v3.0
        v_disabled_msg_id_int      := disable_gmii_vvc_msg_id(v_channel, GC_INSTANCE_IDX, ID_CMD_INTERPRETER);
        v_disabled_msg_id_exe      := disable_gmii_vvc_msg_id(v_channel, GC_INSTANCE_IDX, ID_CMD_EXECUTOR);
      end if;

      -- Get the next DUT data width from the config
      get_data_width_config(GC_DUT_IF_FIELD_CONFIG, hvvc_to_bridge, v_dut_data_width);

      -- Calculate number of transfers
      v_num_transfers  := (hvvc_to_bridge.num_data_words * c_data_words_width) / v_dut_data_width;
      -- Extra transfer if data bits remainder
      if ((hvvc_to_bridge.num_data_words * c_data_words_width) rem v_dut_data_width) /= 0 then
        v_num_transfers := v_num_transfers + 1;
      end if;
      -- Calculate number of bytes for this operation
      v_num_data_bytes := hvvc_to_bridge.num_data_words * c_data_words_width / 8;

      -- Execute command
      case hvvc_to_bridge.operation is

        when TRANSMIT =>
          --UVVM: temporary fix for HVVC, remove line below in v3.0
          shared_gmii_vvc_config(TX, GC_INSTANCE_IDX).parent_msg_id_panel := hvvc_to_bridge.msg_id_panel;

          -- Convert from t_slv_array to t_byte_array
          v_data_bytes(0 to v_num_data_bytes - 1) := convert_slv_array_to_byte_array(hvvc_to_bridge.data_words(0 to hvvc_to_bridge.num_data_words - 1), v_byte_endianness);

          v_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER when v_dut_if_field_pos_is_last else HOLD_LINE_AFTER_TRANSFER;

          gmii_write(GMII_VVCT, GC_INSTANCE_IDX, TX, v_data_bytes(0 to v_num_data_bytes - 1), "HVVC: Write data via GMII.", v_action_when_transfer_is_done, GC_SCOPE, hvvc_to_bridge.msg_id_panel);
          -- Enable the executor waiting log after receiving its last command
          if v_disabled_msg_id_exe_wait and v_dut_if_field_pos_is_last then
            shared_gmii_vvc_config(TX, GC_INSTANCE_IDX).msg_id_panel(ID_CMD_EXECUTOR_WAIT) := ENABLED;
          end if;
          v_cmd_idx := get_last_received_cmd_idx(GMII_VVCT, GC_INSTANCE_IDX, TX, GC_SCOPE);
          await_completion(GMII_VVCT, GC_INSTANCE_IDX, TX, v_cmd_idx, (GC_MAX_NUM_WORDS + v_num_transfers) * GC_PHY_MAX_ACCESS_TIME, "HVVC: Wait for write to finish.", GC_SCOPE, hvvc_to_bridge.msg_id_panel);

        when RECEIVE =>
          --UVVM: temporary fix for HVVC, remove line below in v3.0
          shared_gmii_vvc_config(RX, GC_INSTANCE_IDX).parent_msg_id_panel := hvvc_to_bridge.msg_id_panel;

          gmii_read(GMII_VVCT, GC_INSTANCE_IDX, RX, v_num_data_bytes, "HVVC: Read data via GMII.", GC_SCOPE, hvvc_to_bridge.msg_id_panel);
          -- Enable the executor waiting log after receiving its last command
          if v_disabled_msg_id_exe_wait and v_dut_if_field_pos_is_last then
            shared_gmii_vvc_config(RX, GC_INSTANCE_IDX).msg_id_panel(ID_CMD_EXECUTOR_WAIT) := ENABLED;
          end if;
          v_cmd_idx := get_last_received_cmd_idx(GMII_VVCT, GC_INSTANCE_IDX, RX, GC_SCOPE);
          await_completion(GMII_VVCT, GC_INSTANCE_IDX, RX, v_cmd_idx, (GC_MAX_NUM_WORDS + v_num_transfers) * GC_PHY_MAX_ACCESS_TIME, "HVVC: Wait for read to finish.", GC_SCOPE, hvvc_to_bridge.msg_id_panel);
          fetch_result(GMII_VVCT, GC_INSTANCE_IDX, RX, v_cmd_idx, v_gmii_received_data, "HVVC: Fetching received data.", TB_ERROR, GC_SCOPE, hvvc_to_bridge.msg_id_panel);

          -- Convert from t_byte_array back to t_slv_array
          bridge_to_hvvc.data_words(0 to hvvc_to_bridge.num_data_words - 1) <= convert_byte_array_to_slv_array(v_gmii_received_data.data_array(0 to v_num_data_bytes - 1), c_data_words_width / 8, v_byte_endianness);

        when others =>
          alert(TB_ERROR, "Unsupported operation");

      end case;

      -- Enable the interpreter waiting log after receiving its last command
      if v_disabled_msg_id_int_wait and v_dut_if_field_pos_is_last then
        shared_gmii_vvc_config(v_channel, GC_INSTANCE_IDX).msg_id_panel(ID_CMD_INTERPRETER_WAIT) := ENABLED;
      end if;
      --UVVM: temporary fix for HVVC, remove 4 lines below in v3.0
      if v_dut_if_field_pos_is_last then
        shared_gmii_vvc_config(v_channel, GC_INSTANCE_IDX).msg_id_panel(ID_CMD_INTERPRETER) := ENABLED when v_disabled_msg_id_int;
        shared_gmii_vvc_config(v_channel, GC_INSTANCE_IDX).msg_id_panel(ID_CMD_EXECUTOR)    := ENABLED when v_disabled_msg_id_exe;
      end if;

      gen_pulse(bridge_to_hvvc.trigger, 0 ns, "Pulsing bridge_to_hvvc trigger", GC_SCOPE, ID_NEVER);
    end loop;

  end process;

end architecture GMII;
