--================================================================================================================================
-- Copyright 2020 Bitvis
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
  -- - Bitvis defined BFM operations
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
    WRITE, READ, CHECK);

  constant C_VVC_CMD_DATA_MAX_LENGTH        : natural := 256;
  constant C_VVC_CMD_ADDR_MAX_LENGTH        : natural := 32;
  constant C_VVC_CMD_BYTE_ENABLE_MAX_LENGTH : natural := C_VVC_CMD_DATA_MAX_LENGTH / 8;
  constant C_VVC_CMD_STRING_MAX_LENGTH      : natural := 300;

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
    operation          : t_operation;
    vvc_meta           : t_vvc_meta;
    transaction_status : t_transaction_status;
  end record;

  constant C_BASE_TRANSACTION_SET_DEFAULT : t_base_transaction := (
    operation          => NO_OPERATION,
    vvc_meta           => C_VVC_META_DEFAULT,
    transaction_status => INACTIVE
  );

  type t_arw_transaction is record
    operation          : t_operation;
    arwaddr            : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0);
    vvc_meta           : t_vvc_meta;
    transaction_status : t_transaction_status;
  end record t_arw_transaction;

  constant C_ARW_TRANSACTION_DEFAULT : t_arw_transaction := (
    operation          => NO_OPERATION,
    arwaddr            => (others => '0'),
    vvc_meta           => C_VVC_META_DEFAULT,
    transaction_status => INACTIVE
  );

  type t_w_transaction is record
    operation          : t_operation;
    wdata              : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    wstrb              : std_logic_vector(C_VVC_CMD_BYTE_ENABLE_MAX_LENGTH - 1 downto 0);
    vvc_meta           : t_vvc_meta;
    transaction_status : t_transaction_status;
  end record t_w_transaction;

  constant C_W_TRANSACTION_DEFAULT : t_w_transaction := (
    operation          => NO_OPERATION,
    wdata              => (others => '0'),
    wstrb              => (others => '0'),
    vvc_meta           => C_VVC_META_DEFAULT,
    transaction_status => INACTIVE
  );

  type t_b_transaction is record
    operation          : t_operation;
    vvc_meta           : t_vvc_meta;
    transaction_status : t_transaction_status;
  end record t_b_transaction;

  constant C_B_TRANSACTION_DEFAULT : t_b_transaction := (
    operation          => NO_OPERATION,
    vvc_meta           => C_VVC_META_DEFAULT,
    transaction_status => INACTIVE
  );

  type t_r_transaction is record
    operation          : t_operation;
    rdata              : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    vvc_meta           : t_vvc_meta;
    transaction_status : t_transaction_status;
  end record t_r_transaction;

  constant C_R_TRANSACTION_DEFAULT : t_r_transaction := (
    operation          => NO_OPERATION,
    rdata              => (others => '0'),
    vvc_meta           => C_VVC_META_DEFAULT,
    transaction_status => INACTIVE
  );

  -- Transaction group
  type t_transaction_group is record
    bt_wr : t_base_transaction;
    bt_rd : t_base_transaction;
    st_aw : t_arw_transaction;
    st_w  : t_w_transaction;
    st_b  : t_b_transaction;
    st_ar : t_arw_transaction;
    st_r  : t_r_transaction;
  end record;

  constant C_TRANSACTION_GROUP_DEFAULT : t_transaction_group := (
    bt_wr => C_BASE_TRANSACTION_SET_DEFAULT,
    bt_rd => C_BASE_TRANSACTION_SET_DEFAULT,
    st_aw => C_ARW_TRANSACTION_DEFAULT,
    st_w  => C_W_TRANSACTION_DEFAULT,
    st_b  => C_B_TRANSACTION_DEFAULT,
    st_ar => C_ARW_TRANSACTION_DEFAULT,
    st_r  => C_R_TRANSACTION_DEFAULT
  );

  -- Global transaction info trigger signal
  type t_axilite_transaction_trigger_array is array (natural range <>) of std_logic;
  signal global_axilite_vvc_transaction_trigger : t_axilite_transaction_trigger_array(0 to C_MAX_VVC_INSTANCE_NUM - 1) := (others => '0');

  -- Type is defined as array to coincide with channel based VVCs
  type t_axilite_transaction_group_array is array (natural range <>) of t_transaction_group;
  -- Shared transaction info variable
  shared variable shared_axilite_vvc_transaction_info : t_axilite_transaction_group_array(0 to C_MAX_VVC_INSTANCE_NUM - 1) := (others => C_TRANSACTION_GROUP_DEFAULT);

end package transaction_pkg;
