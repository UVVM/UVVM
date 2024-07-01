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

--=================================================================================================
--=================================================================================================
--=================================================================================================
package vvc_cmd_pkg is

  alias t_operation is work.transaction_pkg.t_operation;

  --===============================================================================================
  -- t_vvc_cmd_record
  -- - Record type used for communication with the VVC
  --===============================================================================================
  type t_vvc_cmd_record is record
    -- Common UVVM fields  (Used by td_vvc_framework_common_methods_pkg procedures, and thus mandatory)
    operation           : t_operation;
    proc_call           : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    msg                 : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    data_routing        : t_data_routing;
    cmd_idx             : natural;
    command_type        : t_immediate_or_queued; -- QUEUED/IMMEDIATE
    msg_id              : t_msg_id;
    gen_integer_array   : t_integer_array(0 to 1); -- Increase array length if needed
    gen_boolean         : boolean;      -- Generic boolean
    timeout             : time;
    alert_level         : t_alert_level;
    delay               : time;
    quietness           : t_quietness;
    parent_msg_id_panel : t_msg_id_panel;
    -- VVC dedicated fields
    addr                : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0); -- Max width may be increased if required
    data                : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    byte_enable         : std_logic_vector(C_VVC_CMD_BYTE_ENABLE_MAX_LENGTH - 1 downto 0);
  end record;

  constant C_VVC_CMD_DEFAULT : t_vvc_cmd_record := (
    operation           => NO_OPERATION, -- Default unless overwritten by a common operation
    addr                => (others => '0'),
    data                => (others => '0'),
    byte_enable         => (others => '1'),
    alert_level         => failure,
    proc_call           => (others => NUL),
    msg                 => (others => NUL),
    data_routing        => NA,
    cmd_idx             => 0,
    command_type        => NO_command_type,
    msg_id              => NO_ID,
    gen_integer_array   => (others => -1),
    gen_boolean         => false,
    timeout             => 0 ns,
    delay               => 0 ns,
    quietness           => NON_QUIET,
    parent_msg_id_panel => C_UNUSED_MSG_ID_PANEL
  );

  --===============================================================================================
  -- shared_vvc_cmd
  --  - Shared variable used for transmitting VVC commands
  --===============================================================================================
  shared variable shared_vvc_cmd : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;

  --===============================================================================================
  -- t_vvc_result, t_vvc_result_queue_element, t_vvc_response and shared_vvc_response :
  --
  -- - Used for storing the result of a BFM procedure called by the VVC,
  --   so that the result can be transported from the VVC to for example a sequencer via
  --   fetch_result() as described in VVC_Framework_common_methods_QuickRef
  --
  -- - t_vvc_result includes the return value of the procedure in the BFM.
  --   It can also be defined as a record if multiple values shall be transported from the BFM
  --===============================================================================================
  subtype t_vvc_result is std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);

  type t_vvc_result_queue_element is record
    cmd_idx : natural;                  -- from UVVM handshake mechanism
    result  : t_vvc_result;
  end record;

  type t_vvc_response is record
    fetch_is_accepted  : boolean;
    transaction_result : t_transaction_result;
    result             : t_vvc_result;
  end record;

  shared variable shared_vvc_response : t_vvc_response;

  --===============================================================================================
  -- t_last_received_cmd_idx :
  -- - Used to store the last queued cmd in vvc interpreter.
  --===============================================================================================
  type t_last_received_cmd_idx is array (t_channel range <>, natural range <>) of integer;

  --===============================================================================================
  -- shared_vvc_last_received_cmd_idx
  --  - Shared variable used to get last queued index from vvc to sequencer
  --===============================================================================================
  shared variable shared_vvc_last_received_cmd_idx : t_last_received_cmd_idx(t_channel'left to t_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => -1));

end package vvc_cmd_pkg;

package body vvc_cmd_pkg is
end package body vvc_cmd_pkg;

