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

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

architecture GMII of hvvc_to_vvc_bridge is
begin

  p_executor : process
    variable v_cmd_idx             : integer;
    variable v_gmii_received_data  : bitvis_vip_gmii.vvc_cmd_pkg.t_vvc_result;
    variable v_num_of_transfers    : integer;
    variable v_data_width          : positive;
  begin

    loop

      -- Await cmd from the HVVC
      wait until hvvc_to_bridge.trigger = true;

      -- Get the next DUT data width from the config
      get_data_width_config(GC_DUT_IF_FIELD_CONFIG, hvvc_to_bridge, v_data_width);

      -- Calculate number of transfers
      v_num_of_transfers := (hvvc_to_bridge.num_data_bytes*8)/v_data_width;
      -- Extra transfer if data bits remainder
      if ((hvvc_to_bridge.num_data_bytes*8) rem v_data_width) /= 0 then
        v_num_of_transfers := v_num_of_transfers+1;
      end if;

      -- Execute command
      case hvvc_to_bridge.operation is

        when TRANSMIT =>
          --gmii_write(GMII_VVCT, GC_INSTANCE_IDX, TX, hvvc_to_bridge.data_bytes(0 to hvvc_to_bridge.num_data_bytes-1), "Send data over GMII", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
          gmii_write(GMII_VVCT, GC_INSTANCE_IDX, TX, hvvc_to_bridge.data_bytes(0 to hvvc_to_bridge.num_data_bytes-1), "Send data over GMII", GC_SCOPE);
          v_cmd_idx := get_last_received_cmd_idx(GMII_VVCT, GC_INSTANCE_IDX, TX, GC_SCOPE);
          await_completion(GMII_VVCT, GC_INSTANCE_IDX, TX, v_cmd_idx, v_num_of_transfers*GC_PHY_MAX_ACCESS_TIME + hvvc_to_bridge.field_timeout_margin,
            "Wait for write to finish.", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);

        when RECEIVE =>
          --gmii_read(GMII_VVCT, GC_INSTANCE_IDX, RX, hvvc_to_bridge.num_data_bytes, "Read data over GMII", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
          gmii_read(GMII_VVCT, GC_INSTANCE_IDX, RX, hvvc_to_bridge.num_data_bytes, "Read data over GMII", GC_SCOPE);
          v_cmd_idx := get_last_received_cmd_idx(GMII_VVCT, GC_INSTANCE_IDX, RX, GC_SCOPE);
          await_completion(GMII_VVCT, GC_INSTANCE_IDX, RX, v_cmd_idx, v_num_of_transfers*GC_PHY_MAX_ACCESS_TIME + hvvc_to_bridge.field_timeout_margin,
            "Wait for read to finish.", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
          fetch_result(GMII_VVCT, GC_INSTANCE_IDX, RX, v_cmd_idx, v_gmii_received_data, "Fetching received data.", TB_ERROR, GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, hvvc_to_bridge.msg_id_panel);
          bridge_to_hvvc.data_bytes(0 to hvvc_to_bridge.num_data_bytes-1) <= v_gmii_received_data.data_array(0 to hvvc_to_bridge.num_data_bytes-1);

        when others =>
          alert(TB_ERROR, "Unsupported operation");

      end case;

      bridge_to_hvvc_trigger(bridge_to_hvvc);
    end loop;

  end process;

end architecture GMII;