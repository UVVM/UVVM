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

use work.transaction_pkg.all;
use work.vvc_cmd_pkg.all;

--=================================================================================================
--=================================================================================================
--=================================================================================================
package monitor_cmd_pkg is

  constant C_MAX_BITS_IN_DATA : positive := 8;

  constant C_UART_MONITOR_MSG_ID_PANEL_DEFAULT : t_msg_id_panel := (
    ID_MONITOR => ENABLED,
    others     => DISABLED
  );

  --===============================================================================================
  -- t_uart_interface_config
  -- - Record type which holds the configurations of the UART interface
  --===============================================================================================
  type t_uart_interface_config is record
    bit_time      : time;
    num_data_bits : positive range 7 to 8;
    parity        : t_parity;
    num_stop_bits : t_stop_bits;
  end record t_uart_interface_config;

  constant C_UART_MONITOR_INTERFACE_CONFIG_DEFAULT : t_uart_interface_config := (
    bit_time      => 0 ns,
    num_data_bits => 8,
    parity        => PARITY_ODD,
    num_stop_bits => STOP_BITS_ONE
  );

  --===============================================================================================
  -- t_uart_monitor_config
  -- - Record type which holds the general configurations of the monitor
  --===============================================================================================
  type t_uart_monitor_config is record
    scope_name               : string(1 to C_LOG_SCOPE_WIDTH);
    msg_id_panel             : t_msg_id_panel;
    interface_config         : t_uart_interface_config;
    transaction_display_time : time;
  end record t_uart_monitor_config;

  type t_uart_monitor_config_array is array (t_channel range <>, natural range <>) of t_uart_monitor_config;

  constant C_UART_MONITOR_CONFIG_DEFAULT : t_uart_monitor_config := (
    scope_name               => (1 to 14 => "set scope name", others => NUL),
    msg_id_panel             => C_UART_MONITOR_MSG_ID_PANEL_DEFAULT,
    interface_config         => C_UART_MONITOR_INTERFACE_CONFIG_DEFAULT,
    transaction_display_time => 0 ns
  );

  procedure monitor_constructor(
    constant monitor_config        : in t_uart_monitor_config;
    variable shared_monitor_config : out t_uart_monitor_config
  );

  -- Monitor
  shared variable shared_uart_monitor_config : t_uart_monitor_config_array(t_channel'left to t_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_UART_MONITOR_CONFIG_DEFAULT));

end package monitor_cmd_pkg;

package body monitor_cmd_pkg is

  procedure monitor_constructor(
    constant monitor_config        : in t_uart_monitor_config;
    variable shared_monitor_config : out t_uart_monitor_config
  ) is
  begin
    shared_monitor_config := monitor_config;
  end procedure monitor_constructor;

end package body monitor_cmd_pkg;
