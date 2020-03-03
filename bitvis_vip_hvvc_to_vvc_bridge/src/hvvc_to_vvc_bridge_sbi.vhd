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

use work.support_pkg.all;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

architecture SBI of hvvc_to_vvc_bridge is
begin

  p_executor : process
    constant c_data_words_width       : natural := hvvc_to_bridge.data_words(hvvc_to_bridge.data_words'low)'length;
    variable v_cmd_idx                : integer;
    variable v_sbi_received_data      : bitvis_vip_sbi.vvc_cmd_pkg.t_vvc_result;
    variable v_sbi_send_data          : std_logic_vector(bitvis_vip_sbi.transaction_pkg.C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    variable v_dut_address            : unsigned(GC_DUT_IF_FIELD_CONFIG(GC_DUT_IF_FIELD_CONFIG'low)(GC_DUT_IF_FIELD_CONFIG(GC_DUT_IF_FIELD_CONFIG'low)'high).dut_address'range);
    variable v_dut_address_increment  : integer;
    variable v_dut_data_width         : positive;
    variable v_num_of_transfers       : integer;
    variable v_word_idx               : natural range 0 to GC_MAX_NUM_WORDS;
    variable v_bit_idx                : natural range 0 to c_data_words_width-1;
    variable v_num_data_bytes         : positive;
    variable v_data_bytes             : t_byte_array(0 to GC_MAX_NUM_WORDS*c_data_words_width/8-1);

  begin

    loop

      -- Await cmd from the HVVC
      wait until hvvc_to_bridge.trigger = true;

      -- Get the next DUT address from the config to write the data
      get_dut_address_config(GC_DUT_IF_FIELD_CONFIG, hvvc_to_bridge, v_dut_address, v_dut_address_increment);
      -- Get the next DUT data width from the config
      get_data_width_config(GC_DUT_IF_FIELD_CONFIG, hvvc_to_bridge, v_dut_data_width);

      -- Calculate number of transfers
      v_num_of_transfers := (hvvc_to_bridge.num_data_words*c_data_words_width)/v_dut_data_width;
      -- Extra transfer if data bits remainder
      if ((hvvc_to_bridge.num_data_words*c_data_words_width) rem v_dut_data_width) /= 0 then
        v_num_of_transfers := v_num_of_transfers+1;
      end if;
      -- Calculate number of bytes for this operation
      v_num_data_bytes := hvvc_to_bridge.num_data_words*c_data_words_width/8;

      -- Execute command
      case hvvc_to_bridge.operation is

        when TRANSMIT =>
          v_word_idx := 0;
          v_bit_idx  := 0;
          -- Loop through transfers
          for i in 0 to v_num_of_transfers-1 loop
            -- Fill the data vector
            v_sbi_send_data := (others => '0');
            for send_data_idx in 0 to v_dut_data_width-1 loop
              if v_word_idx = hvvc_to_bridge.num_data_words then
                exit; -- No more data
              else
                v_sbi_send_data(send_data_idx) := hvvc_to_bridge.data_words(v_word_idx)(v_bit_idx);
              end if;

              if v_bit_idx = c_data_words_width-1 then
                v_word_idx := v_word_idx+1;
                v_bit_idx  := 0;
              else
                v_bit_idx := v_bit_idx+1;
              end if;
            end loop;

            -- Send data over SBI
            sbi_write(SBI_VVCT, GC_INSTANCE_IDX, v_dut_address, v_sbi_send_data(v_dut_data_width-1 downto 0), "Send data over SBI", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
            v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, GC_INSTANCE_IDX, NA, GC_SCOPE);
            if shared_sbi_vvc_config(GC_INSTANCE_IDX).bfm_config.use_ready_signal then
              await_completion(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, GC_PHY_MAX_ACCESS_TIME*2 + hvvc_to_bridge.field_timeout_margin,
                "Wait for write to finish.", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
            else
              await_completion(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, GC_PHY_MAX_ACCESS_TIME + hvvc_to_bridge.field_timeout_margin,
                "Wait for write to finish.", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
            end if;
            v_dut_address := v_dut_address + v_dut_address_increment;
          end loop;

        when RECEIVE =>
          v_word_idx := 0;
          v_bit_idx  := 0;
          -- Loop through bytes
          for i in 0 to v_num_of_transfers-1 loop
            -- Read data over SBI
            sbi_read(SBI_VVCT, GC_INSTANCE_IDX, v_dut_address, "Read data over SBI", TO_RECEIVE_BUFFER, GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
            v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, GC_INSTANCE_IDX, NA, GC_SCOPE);
            if shared_sbi_vvc_config(GC_INSTANCE_IDX).bfm_config.use_ready_signal then
              await_completion(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, GC_PHY_MAX_ACCESS_TIME*2 + hvvc_to_bridge.field_timeout_margin,
                "Wait for read to finish.", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
            else
              await_completion(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, GC_PHY_MAX_ACCESS_TIME + hvvc_to_bridge.field_timeout_margin,
                "Wait for read to finish.", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
            end if;
            fetch_result(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, v_sbi_received_data, "Fetching received data.", TB_ERROR, GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);

            -- Fill data bytes to HVVC
            for receive_data_idx in 0 to v_dut_data_width-1 loop
               if v_word_idx = hvvc_to_bridge.num_data_words then
                exit; -- No more data
              else
                bridge_to_hvvc.data_words(v_word_idx)(v_bit_idx) <= v_sbi_received_data(receive_data_idx);
              end if;

              if v_bit_idx = c_data_words_width-1 then
                v_word_idx := v_word_idx+1;
                v_bit_idx := 0;
              else
                v_bit_idx := v_bit_idx+1;
              end if;
            end loop;
            v_dut_address := v_dut_address + v_dut_address_increment;
          end loop;

        when others =>
          alert(TB_ERROR, "Unsupported operation");

      end case;

      bridge_to_hvvc_trigger(bridge_to_hvvc);
    end loop;

  end process;

end architecture SBI;