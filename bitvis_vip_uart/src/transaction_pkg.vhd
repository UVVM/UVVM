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

--=================================================================================================
--=================================================================================================
--=================================================================================================
package transaction_pkg is

  --===============================================================================================
  -- t_operation
  -- - VVC and BFM operations
  --===============================================================================================
  type t_operation is (
    -- UVVM common
    NO_OPERATION,
    AWAIT_COMPLETION,
    AWAIT_ANY_COMPLETION,
    ENABLE_LOG_MSG,
    DISABLE_LOG_MSG,
    FLUSH_COMMAND_QUEUE,
    FETCH_RESULT,
    INSERT_DELAY,
    TERMINATE_CURRENT_COMMAND,
    -- VVC local
    TRANSMIT, RECEIVE, EXPECT
  );

  alias C_VVC_CMD_DATA_MAX_LENGTH is work.uart_bfm_pkg.C_DATA_MAX_LENGTH;

  -- Constants for the maximum sizes to use in this VVC. Can be modified in adaptations_pkg.
  constant C_VVC_CMD_STRING_MAX_LENGTH : natural := C_UART_VVC_CMD_STRING_MAX_LENGTH;
  constant C_VVC_MAX_INSTANCE_NUM      : natural := C_UART_VVC_MAX_INSTANCE_NUM;

  --==========================================================================================
  --
  -- Transaction Info types, constants and global signal
  --
  --==========================================================================================

  -- VVC Meta
  type t_vvc_meta is record
    msg     : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    cmd_idx : integer;
  end record;

  constant C_VVC_META_DEFAULT : t_vvc_meta := (
    msg     => (others => ' '),
    cmd_idx => -1
  );

  -- Error info
  type t_error_info is record
    parity_bit_error : boolean;
    stop_bit_error   : boolean;
  end record;

  constant C_ERROR_INFO_DEFAULT : t_error_info := (
    parity_bit_error => false,
    stop_bit_error   => false
  );

  -- Base transaction
  type t_base_transaction is record
    operation          : t_operation;
    data               : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    vvc_meta           : t_vvc_meta;
    transaction_status : t_transaction_status;
    error_info         : t_error_info;
  end record;

  constant C_BASE_TRANSACTION_SET_DEFAULT : t_base_transaction := (
    operation          => NO_OPERATION,
    data               => (others => '0'),
    vvc_meta           => C_VVC_META_DEFAULT,
    transaction_status => INACTIVE,
    error_info         => C_ERROR_INFO_DEFAULT
  );

  -- Transaction info group
  type t_transaction_group is record
    bt : t_base_transaction;
  end record;

  constant C_TRANSACTION_GROUP_DEFAULT : t_transaction_group := (
    bt => C_BASE_TRANSACTION_SET_DEFAULT
  );

  subtype t_sub_channel is t_channel range RX to TX;

  -- Global transaction info trigger signal
  type t_uart_transaction_trigger_array is array (t_sub_channel range <>, natural range <>) of std_logic;
  signal global_uart_vvc_transaction_trigger : t_uart_transaction_trigger_array(t_sub_channel'left to t_sub_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => '0'));

  -- Shared transaction info variable
  type t_uart_transaction_group_array is array (t_sub_channel range <>, natural range <>) of t_transaction_group;
  shared variable shared_uart_vvc_transaction_info : t_uart_transaction_group_array(t_sub_channel'left to t_sub_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_TRANSACTION_GROUP_DEFAULT));

  -- Global monitor transaction info trigger signal
  signal global_uart_monitor_transaction_trigger : t_uart_transaction_trigger_array(t_sub_channel'left to t_sub_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => '0'));

  -- Shared monitor transaction info variable
  shared variable shared_uart_monitor_transaction_info : t_uart_transaction_group_array(t_sub_channel'left to t_sub_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_TRANSACTION_GROUP_DEFAULT));

  alias t_uart_operation is t_operation;
  alias t_uart_transaction is t_base_transaction;
  alias C_UART_TRANSACTION_INFO_SET_DEFAULT is C_BASE_TRANSACTION_SET_DEFAULT;

end package transaction_pkg;
