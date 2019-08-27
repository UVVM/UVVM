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
-- Note: This entity will be compiled into every single VVC library.
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

-- Make address and data width configurable

entity hvvc_to_vvc_bridge is
  generic(
    GC_INTERFACE           : t_interface;
    GC_INSTANCE_IDX        : integer;
    GC_CHANNEL             : t_channel;
    GC_DUT_IF_FIELD_CONFIG : t_dut_if_field_config_channel_array;
    GC_SCOPE               : string
    );
  port(
    hvvc_to_vvc : in  t_hvvc_to_vvc;
    vvc_to_hvvc : out t_vvc_to_hvvc
  );
end entity hvvc_to_vvc_bridge;

architecture func of hvvc_to_vvc_bridge is
  constant C_UNSUPPORTED_OPERATION   : string         := "Unsupported operation";
  constant C_UNSUPPORTED_INTERFACE   : string         := "Unsupported interface";
  constant C_INTERFACE_CONFIG_LENGTH : positive       := GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)'length;
  constant C_MSG_ID_PANEL            : t_msg_id_panel := C_SUB_VVC_MSG_ID_PANEL_DEFAULT;
begin

  p_executor : process
    variable v_cmd_idx               : integer;
    variable v_gmii_received_data    : t_byte_array(0 to 1549);
    variable v_sbi_received_data     : std_logic_vector(bitvis_vip_sbi.vvc_cmd_pkg.C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    variable v_interface_config_idx  : natural := 0;
    variable v_dut_address           : unsigned(GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)(GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)'high).dut_address'range);
    variable v_dut_address_increment : integer;
  begin

    loop

      -- Await cmd
      wait until hvvc_to_vvc.trigger = '1';

      -- If not configs are defined for all fields the last config is used
      if hvvc_to_vvc.dut_if_field_idx > GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)'high then
        v_dut_address_increment := GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)(GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)'high).dut_address_increment;
        v_dut_address := GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)(GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)'high).dut_address +
            (hvvc_to_vvc.current_byte_idx_in_field*v_dut_address_increment);
      else
        v_dut_address_increment := GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)(hvvc_to_vvc.dut_if_field_idx).dut_address_increment;
        v_dut_address := GC_DUT_IF_FIELD_CONFIG(GC_CHANNEL)(hvvc_to_vvc.dut_if_field_idx).dut_address +
            (hvvc_to_vvc.current_byte_idx_in_field*v_dut_address_increment);
      end if;

      -- Execute cmd
      case GC_INTERFACE is

        -------------------------------------
        -- GMII
        -------------------------------------
        when GMII =>

          case hvvc_to_vvc.operation is

            when SEND =>
              gmii_write(GMII_VVCT, GC_INSTANCE_IDX, TRANSMITTER, hvvc_to_vvc.data_bytes(0 to hvvc_to_vvc.num_data_bytes-1), "Send data over GMII", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, C_MSG_ID_PANEL);

            when RECEIVE =>
              gmii_read(GMII_VVCT, GC_INSTANCE_IDX, GC_CHANNEL, hvvc_to_vvc.num_data_bytes, "Read data over GMII", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, C_MSG_ID_PANEL);
              v_cmd_idx := get_last_received_cmd_idx(GMII_VVCT, GC_INSTANCE_IDX, GC_CHANNEL, "", GC_SCOPE);
              await_completion(GMII_VVCT, GC_INSTANCE_IDX, GC_CHANNEL, v_cmd_idx, 1 ms, "Wait for read to finish.", GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, C_MSG_ID_PANEL);
              fetch_result(GMII_VVCT, GC_INSTANCE_IDX, GC_CHANNEL, v_cmd_idx, v_gmii_received_data, "Fetching received data.", TB_ERROR, GC_SCOPE, USE_PROVIDED_MSG_ID_PANEL, C_MSG_ID_PANEL);
              vvc_to_hvvc.data_bytes(0 to hvvc_to_vvc.num_data_bytes-1) <= v_gmii_received_data(0 to hvvc_to_vvc.num_data_bytes-1);

            when others =>
              alert(TB_ERROR, C_UNSUPPORTED_OPERATION);

          end case;

        -------------------------------------
        -- SBI
        -------------------------------------
        when SBI =>

          case hvvc_to_vvc.operation is

            when SEND =>
              -- Loop through bytes
              for i in 0 to hvvc_to_vvc.num_data_bytes-1 loop
                -- Send data over SBI
                sbi_write(SBI_VVCT, GC_INSTANCE_IDX, v_dut_address, hvvc_to_vvc.data_bytes(i), "Send data over SBI");
                v_dut_address := v_dut_address + v_dut_address_increment;
              end loop;


            when RECEIVE =>
              -- Loop through bytes
              for i in 0 to hvvc_to_vvc.num_data_bytes-1 loop
                -- Read data over SBI
                sbi_read(SBI_VVCT, GC_INSTANCE_IDX, v_dut_address, "Read data over SBI");
                v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, GC_INSTANCE_IDX);
                await_completion(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, 1 ms, "Wait for read to finish.");
                fetch_result(SBI_VVCT, GC_INSTANCE_IDX, v_cmd_idx, v_sbi_received_data, "Fetching received data.");
                vvc_to_hvvc.data_bytes(i) <= v_sbi_received_data(7 downto 0);
                v_dut_address := v_dut_address + v_dut_address_increment;
              end loop;


            when others =>
              alert(TB_ERROR, C_UNSUPPORTED_OPERATION);

          end case;

        when others =>
          alert(TB_ERROR, C_UNSUPPORTED_INTERFACE);

      end case;

      vvc_to_hvvc.trigger <= '1';
      wait for 0 ns;
      vvc_to_hvvc.trigger <= '0';

    end loop;

  end process;

--  p_deactivate_log : process
--  begin
--    await_uvvm_initialization(VOID);
--    disable_log_msg(SBI_VVCT, GC_INSTANCE_IDX, ALL_MESSAGES);
--    wait;
--  end process;

end architecture func;