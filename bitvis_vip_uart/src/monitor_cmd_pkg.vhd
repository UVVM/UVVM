--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
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
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

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
    bit_time         : time;
    num_data_bits    : positive range 7 to 8;
    parity           : t_parity;
    num_stop_bits    : t_stop_bits;
  end record t_uart_interface_config;

  constant C_UART_MONITOR_INTERFACE_CONFIG_DEFAULT : t_uart_interface_config := (
    bit_time         => 0 ns,
    num_data_bits    => 8,
    parity           => PARITY_ODD,
    num_stop_bits    => STOP_BITS_ONE
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
    constant monitor_config        : in  t_uart_monitor_config;
    variable shared_monitor_config : out t_uart_monitor_config
  );

  -- Monitor
  shared variable shared_uart_monitor_config : t_uart_monitor_config_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM-1) 
                  := (others => (others => C_UART_MONITOR_CONFIG_DEFAULT));

end package monitor_cmd_pkg;

package body monitor_cmd_pkg is

  procedure monitor_constructor(
    constant monitor_config        : in  t_uart_monitor_config;
    variable shared_monitor_config : out t_uart_monitor_config
  ) is
  begin
    shared_monitor_config := monitor_config;
  end procedure monitor_constructor;

end package body monitor_cmd_pkg;