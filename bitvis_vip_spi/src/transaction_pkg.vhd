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
    MASTER_TRANSMIT_AND_RECEIVE, MASTER_TRANSMIT_AND_CHECK, MASTER_TRANSMIT_ONLY, MASTER_RECEIVE_ONLY, MASTER_CHECK_ONLY,
    SLAVE_TRANSMIT_AND_RECEIVE, SLAVE_TRANSMIT_AND_CHECK, SLAVE_TRANSMIT_ONLY, SLAVE_RECEIVE_ONLY, SLAVE_CHECK_ONLY);

  -- Constants for the maximum sizes to use in this VVC. Can be modified in adaptations_pkg.
  constant C_VVC_CMD_DATA_MAX_LENGTH   : natural := C_SPI_VVC_CMD_DATA_MAX_LENGTH;
  constant C_VVC_CMD_MAX_WORDS         : natural := C_SPI_VVC_DATA_ARRAY_WIDTH;
  constant C_VVC_CMD_STRING_MAX_LENGTH : natural := C_SPI_VVC_CMD_STRING_MAX_LENGTH;
  constant C_VVC_MAX_INSTANCE_NUM      : natural := C_SPI_VVC_MAX_INSTANCE_NUM;

  --==========================================================================================
  --
  -- Transaction info types, constants and global signal
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

  -- Base transaction
  type t_base_transaction is record
    operation                    : t_operation;
    data                         : t_slv_array(C_VVC_CMD_MAX_WORDS - 1 downto 0)(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    data_exp                     : t_slv_array(C_VVC_CMD_MAX_WORDS - 1 downto 0)(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    num_words                    : natural;
    word_length                  : natural;
    when_to_start_transfer       : t_when_to_start_transfer;
    action_when_transfer_is_done : t_action_when_transfer_is_done;
    action_between_words         : t_action_between_words;
    vvc_meta                     : t_vvc_meta;
    transaction_status           : t_transaction_status;
  end record;

  constant C_BASE_TRANSACTION_SET_DEFAULT : t_base_transaction := (
    operation                    => NO_OPERATION,
    data                         => (others => (others => '0')),
    data_exp                     => (others => (others => '0')),
    num_words                    => 0,
    word_length                  => 0,
    when_to_start_transfer       => START_TRANSFER_IMMEDIATE,
    action_when_transfer_is_done => RELEASE_LINE_AFTER_TRANSFER,
    action_between_words         => HOLD_LINE_BETWEEN_WORDS,
    vvc_meta                     => C_VVC_META_DEFAULT,
    transaction_status           => INACTIVE
  );

  -- Transaction group
  type t_transaction_group is record
    bt : t_base_transaction;
  end record;

  constant C_TRANSACTION_GROUP_DEFAULT : t_transaction_group := (
    bt => C_BASE_TRANSACTION_SET_DEFAULT
  );

  -- Global transaction info trigger signal
  type t_spi_transaction_trigger_array is array (natural range <>) of std_logic;
  signal global_spi_vvc_transaction_trigger : t_spi_transaction_trigger_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => '0');

  -- Type is defined as array to coincide with channel based VVCs
  type t_spi_transaction_group_array is array (natural range <>) of t_transaction_group;
  -- Shared transaction info variable
  shared variable shared_spi_vvc_transaction_info : t_spi_transaction_group_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_TRANSACTION_GROUP_DEFAULT);

end package transaction_pkg;
