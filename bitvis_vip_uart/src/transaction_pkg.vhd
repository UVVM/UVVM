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
  -- - Bitvis defined operations
  --===============================================================================================
  type t_operation is (
    NO_OPERATION,
    AWAIT_COMPLETION,
    AWAIT_ANY_COMPLETION,
    ENABLE_LOG_MSG,
    DISABLE_LOG_MSG,
    FLUSH_COMMAND_QUEUE,
    FETCH_RESULT,
    INSERT_DELAY,
    TERMINATE_CURRENT_COMMAND,
    -- Transaction
    TRANSMIT, RECEIVE, EXPECT);


  constant C_CMD_DATA_MAX_LENGTH   : natural := 8;
  constant C_CMD_STRING_MAX_LENGTH : natural := 300;



  --==========================================================================================
  --
  -- DTT - Direct Transaction Transfer types, constants and global signal
  --
  --==========================================================================================

  -- Transaction status
  --
  --   NA: when no ongoing transaction
  --   IN_PROGRESS: a started transaction
  --   SUCCEEDED: a finished transaction without error - will immediately return to NA
  --   FAILED: a finished transaction with error - will immediately return to NA
  type t_transaction_status is (NA, IN_PROGRESS, SUCCEEDED, FAILED);

  constant C_TRANSACTION_STATUS_DEFAULT : t_transaction_status := NA;

  -- Meta
  --
  --   message: any message sendt together with a VVC command
  --   cmd_idx: VVC command index
  type t_meta is record
    msg     : string(1 to C_CMD_STRING_MAX_LENGTH);
    cmd_idx : integer;
  end record;

  constant C_META_DEFAULT : t_meta := (
    msg     => (others => ' '),
    cmd_idx => -1
    );

  -- Error info
  --
  --    delay_error: error induced on request (read or write) signal
  type t_error_info is record
    parity_error : boolean;
  end record;

  constant C_ERROR_INFO_DEFAULT : t_error_info := (
    parity_error => false
    );

  -- Transaction
  --
  --   operation: BFM operation
  --   data: SBI write data
  --   meta: VVC command message and index
  --   transaction_status: transaction status
  --   error_info: error info
  type t_transaction is record
    operation          : t_operation;
    data               : std_logic_vector(C_CMD_DATA_MAX_LENGTH-1 downto 0);
    meta               : t_meta;
    transaction_status : t_transaction_status;
    error_info         : t_error_info;
  end record;

  constant C_TRANSACTION_INFO_SET_DEFAULT : t_transaction := (
    operation           => NO_OPERATION,
    data                => (others => '0'),
    meta                => C_META_DEFAULT,
    transaction_status  => C_TRANSACTION_STATUS_DEFAULT,
    error_info          => C_ERROR_INFO_DEFAULT
    );

  -- Transaction info group
  --
  --  bt: base transaction info
  --  ct: compound transaction info
  type t_transaction_info_group is record
    bt : t_transaction;
    ct : t_transaction;
  end record;

  constant C_TRANSACTION_INFO_GROUP_DEFAULT : t_transaction_info_group := (
    bt => C_TRANSACTION_INFO_SET_DEFAULT,
    ct => C_TRANSACTION_INFO_SET_DEFAULT
    );


  type t_uart_transaction_info_array is array (t_channel range <>, natural range <>) of t_transaction_info_group;

  signal global_uart_transaction_info : t_uart_transaction_info_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM) :=
                                          (others => (others => C_TRANSACTION_INFO_GROUP_DEFAULT));

  signal global_uart_monitor_transaction_info : t_uart_transaction_info_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM) :=
                                          (others => (others => C_TRANSACTION_INFO_GROUP_DEFAULT));

end package transaction_pkg;




package body transaction_pkg is


end package body transaction_pkg;


