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

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

architecture SBI of hvvc_to_vvc_bridge is
begin

  p_executor : process
    constant c_data_words_width          : natural := hvvc_to_bridge.data_words(hvvc_to_bridge.data_words'low)'length;
    variable v_cmd_idx                   : integer;
    variable v_sbi_received_data         : bitvis_vip_sbi.vvc_cmd_pkg.t_vvc_result;
    variable v_dut_address               : unsigned(GC_DUT_IF_FIELD_CONFIG(GC_DUT_IF_FIELD_CONFIG'low)(GC_DUT_IF_FIELD_CONFIG(GC_DUT_IF_FIELD_CONFIG'low)'high).dut_address'range);
    variable v_dut_address_increment     : integer;
    variable v_dut_data_width            : positive;
    variable v_num_transfers             : integer;
    variable v_data_slv                  : std_logic_vector(GC_MAX_NUM_WORDS * c_data_words_width - 1 downto 0);
    variable v_dut_if_field_pos_is_first : boolean;
    variable v_dut_if_field_pos_is_last  : boolean;
    variable v_disabled_msg_id_int_wait  : boolean;
    variable v_disabled_msg_id_exe_wait  : boolean;
    --UVVM: temporary fix for HVVC, remove 2 lines below in v3.0
    variable v_disabled_msg_id_int       : boolean;
    variable v_disabled_msg_id_exe       : boolean;

    -- Converts a t_slv_array to a std_logic_vector (word endianness is LOWER_WORD_RIGHT)
    function convert_slv_array_to_slv(
      constant slv_array : t_slv_array
    ) return std_logic_vector is
      constant c_num_words : integer := slv_array'length;
      constant c_word_len  : integer := slv_array(slv_array'low)'length;
      variable v_slv       : std_logic_vector(c_num_words * c_word_len - 1 downto 0);
    begin
      for word_idx in 0 to c_num_words - 1 loop
        v_slv(c_word_len * (word_idx + 1) - 1 downto c_word_len * word_idx) := slv_array(word_idx);
      end loop;
      return v_slv;
    end function;

    -- Converts a std_logic_vector to a t_slv_array (word endianness is LOWER_WORD_RIGHT)
    function convert_slv_to_slv_array(
      constant slv      : std_logic_vector;
      constant word_len : integer
    ) return t_slv_array is
      constant c_num_words : integer := slv'length / word_len;
      variable v_slv_array : t_slv_array(0 to c_num_words - 1)(word_len - 1 downto 0);
    begin
      for word_idx in 0 to c_num_words - 1 loop
        v_slv_array(word_idx) := slv(word_len * (word_idx + 1) - 1 downto word_len * word_idx);
      end loop;
      return v_slv_array;
    end function;

    -- Disables a previously enabled msg_id in the VVC's shared config
    impure function disable_sbi_vvc_msg_id(
      constant instance_idx : integer;
      constant msg_id       : t_msg_id
    ) return boolean is
      variable v_disable_id : boolean := false;
    begin
      if shared_sbi_vvc_config(instance_idx).msg_id_panel(msg_id) = ENABLED then
        shared_sbi_vvc_config(instance_idx).msg_id_panel(msg_id) := DISABLED;
        v_disable_id                                             := true;
      end if;
      return v_disable_id;
    end function;

  begin
    loop

      -- Await cmd from the HVVC
      wait until hvvc_to_bridge.trigger = true;

      -- Check the field position in the packet
      v_dut_if_field_pos_is_first := hvvc_to_bridge.dut_if_field_pos = FIRST or hvvc_to_bridge.dut_if_field_pos = FIRST_AND_LAST;
      v_dut_if_field_pos_is_last  := hvvc_to_bridge.dut_if_field_pos = LAST or hvvc_to_bridge.dut_if_field_pos = FIRST_AND_LAST;

      if v_dut_if_field_pos_is_first then
        log(ID_NEW_HVVC_CMD_SEQ, "VVC is busy while executing an HVVC command", "SBI_VVC," & to_string(GC_INSTANCE_IDX), shared_sbi_vvc_config(GC_INSTANCE_IDX).msg_id_panel);
        -- Disable the interpreter and executor waiting logs during the HVVC command
        v_disabled_msg_id_int_wait := disable_sbi_vvc_msg_id(GC_INSTANCE_IDX, ID_CMD_INTERPRETER_WAIT);
        v_disabled_msg_id_exe_wait := disable_sbi_vvc_msg_id(GC_INSTANCE_IDX, ID_CMD_EXECUTOR_WAIT);
        --UVVM: temporary fix for HVVC, remove 2 lines below in v3.0
        v_disabled_msg_id_int      := disable_sbi_vvc_msg_id(GC_INSTANCE_IDX, ID_CMD_INTERPRETER);
        v_disabled_msg_id_exe      := disable_sbi_vvc_msg_id(GC_INSTANCE_IDX, ID_CMD_EXECUTOR);
      end if;

      -- Get the next DUT address from the config to write the data
      get_dut_address_config(GC_DUT_IF_FIELD_CONFIG, hvvc_to_bridge, v_dut_address, v_dut_address_increment);
      -- Get the next DUT data width from the config
      get_data_width_config(GC_DUT_IF_FIELD_CONFIG, hvvc_to_bridge, v_dut_data_width);

      -- Calculate number of transfers
      v_num_transfers := (hvvc_to_bridge.num_data_words * c_data_words_width) / v_dut_data_width;
      -- Extra transfer if data bits remainder
      if ((hvvc_to_bridge.num_data_words * c_data_words_width) rem v_dut_data_width) /= 0 then
        v_num_transfers := v_num_transfers + 1;
      end if;

      -- Execute command
      case hvvc_to_bridge.operation is

        when TRANSMIT =>
          --UVVM: temporary fix for HVVC, remove line below in v3.0
          shared_sbi_vvc_config(GC_INSTANCE_IDX).parent_msg_id_panel := hvvc_to_bridge.msg_id_panel;

          -- Convert from t_slv_array to std_logic_vector (word endianness is LOWER_WORD_RIGHT)
          v_data_slv(hvvc_to_bridge.num_data_words * c_data_words_width - 1 downto 0) := convert_slv_array_to_slv(hvvc_to_bridge.data_words(0 to hvvc_to_bridge.num_data_words - 1));

          -- Loop through transfers
          for i in 0 to v_num_transfers - 1 loop
            sbi_write(SBI_VVCT, GC_INSTANCE_IDX, v_dut_address, v_data_slv(v_dut_data_width * (i + 1) - 1 downto v_dut_data_width * i),
                      "HVVC: Write data via SBI.", GC_SCOPE, hvvc_to_bridge.msg_id_panel);
            -- Enable the executor waiting log after receiving its last command
            if v_disabled_msg_id_exe_wait and v_dut_if_field_pos_is_last and i = v_num_transfers - 1 then
              shared_sbi_vvc_config(GC_INSTANCE_IDX).msg_id_panel(ID_CMD_EXECUTOR_WAIT) := ENABLED;
            end if;
            v_cmd_idx     := get_last_received_cmd_idx(SBI_VVCT, GC_INSTANCE_IDX, NA, GC_SCOPE);
            await_completion(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, GC_MAX_NUM_WORDS * GC_PHY_MAX_ACCESS_TIME, "HVVC: Wait for write to finish.", GC_SCOPE, hvvc_to_bridge.msg_id_panel);
            v_dut_address := v_dut_address + v_dut_address_increment;
          end loop;

        when RECEIVE =>
          --UVVM: temporary fix for HVVC, remove line below in v3.0
          shared_sbi_vvc_config(GC_INSTANCE_IDX).parent_msg_id_panel := hvvc_to_bridge.msg_id_panel;

          -- Loop through transfers
          for i in 0 to v_num_transfers - 1 loop
            sbi_read(SBI_VVCT, GC_INSTANCE_IDX, v_dut_address, "HVVC: Read data via SBI.", GC_SCOPE, hvvc_to_bridge.msg_id_panel);
            -- Enable the executor waiting log after receiving its last command
            if v_disabled_msg_id_exe_wait and v_dut_if_field_pos_is_last and i = v_num_transfers - 1 then
              shared_sbi_vvc_config(GC_INSTANCE_IDX).msg_id_panel(ID_CMD_EXECUTOR_WAIT) := ENABLED;
            end if;
            v_cmd_idx                                                              := get_last_received_cmd_idx(SBI_VVCT, GC_INSTANCE_IDX, NA, GC_SCOPE);
            await_completion(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, GC_MAX_NUM_WORDS * GC_PHY_MAX_ACCESS_TIME, "HVVC: Wait for read to finish.", GC_SCOPE, hvvc_to_bridge.msg_id_panel);
            fetch_result(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, v_sbi_received_data, "HVVC: Fetching received data.", TB_ERROR, GC_SCOPE, hvvc_to_bridge.msg_id_panel);
            v_data_slv(v_dut_data_width * (i + 1) - 1 downto v_dut_data_width * i) := v_sbi_received_data(v_dut_data_width - 1 downto 0);
            v_dut_address                                                          := v_dut_address + v_dut_address_increment;
          end loop;

          -- Convert from std_logic_vector to t_slv_array (word endianness is LOWER_WORD_RIGHT)
          bridge_to_hvvc.data_words(0 to hvvc_to_bridge.num_data_words - 1) <= convert_slv_to_slv_array(v_data_slv(hvvc_to_bridge.num_data_words * c_data_words_width - 1 downto 0), c_data_words_width);

        when others =>
          alert(TB_ERROR, "Unsupported operation");

      end case;

      -- Enable the interpreter waiting log after receiving its last command
      if v_disabled_msg_id_int_wait and v_dut_if_field_pos_is_last then
        shared_sbi_vvc_config(GC_INSTANCE_IDX).msg_id_panel(ID_CMD_INTERPRETER_WAIT) := ENABLED;
      end if;
      --UVVM: temporary fix for HVVC, remove 4 lines below in v3.0
      if v_dut_if_field_pos_is_last then
        shared_sbi_vvc_config(GC_INSTANCE_IDX).msg_id_panel(ID_CMD_INTERPRETER) := ENABLED when v_disabled_msg_id_int;
        shared_sbi_vvc_config(GC_INSTANCE_IDX).msg_id_panel(ID_CMD_EXECUTOR)    := ENABLED when v_disabled_msg_id_exe;
      end if;

      gen_pulse(bridge_to_hvvc.trigger, 0 ns, "Pulsing bridge_to_hvvc trigger", GC_SCOPE, ID_NEVER);
    end loop;

  end process;

end architecture SBI;
