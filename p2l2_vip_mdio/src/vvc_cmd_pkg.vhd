--================================================================================================================================
-- Copyright 2026 UVVM
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

use work.mdio_bfm_pkg.all;
use work.transaction_pkg.all;

--==========================================================================================
--==========================================================================================
package vvc_cmd_pkg is

  alias t_operation is work.transaction_pkg.t_operation;

  --==========================================================================================
  -- t_vvc_cmd_record
  -- - Record type used for communication with the VVC
  --==========================================================================================
  type t_vvc_cmd_record is record
    -- VVC dedicated fields
    data                      : std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0); -- data written / expected
    dev_addr                  : unsigned(C_VVC_CMD_DEV_ADDR_LENGTH-1 downto 0);     -- clause 45: target MMD within the PHY
    phy_addr                  : unsigned(C_VVC_CMD_PHY_ADDR_LENGTH-1 downto 0);     -- STA: bus address of the target PHY (PHYAD / PRTAD)
    reg_addr                  : unsigned(C_VVC_CMD_REG_ADDR_LENGTH-1 downto 0);     -- register address: REGAD (clause 22, zero-extended) or clause 45 register address
    -- Common VVC fields
    operation                 : t_operation;
    proc_call                 : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    msg                       : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    data_routing              : t_data_routing;
    cmd_idx                   : natural;
    command_type              : t_immediate_or_queued;
    msg_id                    : t_msg_id;
    gen_integer_array         : t_integer_array(0 to 1); -- Increase array length if needed
    gen_boolean               : boolean; -- Generic boolean
    timeout                   : time;
    alert_level               : t_alert_level;
    delay                     : time;
    quietness                 : t_quietness;
    parent_msg_id_panel       : t_msg_id_panel;
  end record t_vvc_cmd_record;

  constant C_VVC_CMD_DEFAULT : t_vvc_cmd_record := (
    data                      => (others => '0'),
    dev_addr                  => (others => '0'),
    phy_addr                  => (others => '0'),
    reg_addr                  => (others => '0'),
    -- Common VVC fields
    operation                 => NO_OPERATION,
    proc_call                 => (others => NUL),
    msg                       => (others => NUL),
    data_routing              => NA,
    cmd_idx                   => 0,
    command_type              => NO_COMMAND_TYPE,
    msg_id                    => NO_ID,
    gen_integer_array         => (others => -1),
    gen_boolean               => false,
    timeout                   => C_UNDEFINED_TIME, -- use bfm_config default
    alert_level               => FAILURE,
    delay                     => 0 ns,
    quietness                 => NON_QUIET,
    parent_msg_id_panel       => C_UNUSED_MSG_ID_PANEL
  );

  --==========================================================================================
  -- shared_vvc_cmd
  -- - Shared variable used for transmitting VVC commands
  --==========================================================================================
  shared variable shared_vvc_cmd : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;

  --==========================================================================================
  -- t_vvc_result, t_vvc_result_queue_element, t_vvc_response and shared_vvc_response :
  --
  -- - Used for storing the result of a BFM procedure called by the VVC,
  --   so that the result can be transported from the VVC to for example a sequencer via
  --   fetch_result() as described in uvvm_vvc_framework/Common_VVC_Methods QuickRef.
  -- - t_vvc_result includes the return value of the procedure in the BFM. It can also
  --   be defined as a record if multiple values shall be transported from the BFM
  --==========================================================================================
  subtype  t_vvc_result is std_ulogic_vector(C_VVC_CMD_DATA_LENGTH-1 downto 0); -- the 16 bits read by an STA read or received by a PHY receive

  type t_vvc_result_queue_element is record
    cmd_idx       : natural;   -- from UVVM handshake mechanism
    result        : t_vvc_result;
  end record t_vvc_result_queue_element;

  type t_vvc_response is record
    fetch_is_accepted    : boolean;
    transaction_result   : t_transaction_result;
    result               : t_vvc_result;
  end record t_vvc_response;

  shared variable shared_vvc_response : t_vvc_response;

  --==========================================================================================
  -- t_last_received_cmd_idx :
  -- - Used to store the last queued cmd in VVC interpreter.
  --==========================================================================================
  type t_last_received_cmd_idx is array (t_channel range <>, natural range <>) of integer;

  --==========================================================================================
  -- shared_vvc_last_received_cmd_idx
  --  - Shared variable used to get last queued index from VVC to sequencer
  --==========================================================================================
  shared variable shared_vvc_last_received_cmd_idx : t_last_received_cmd_idx(t_channel'left to t_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => -1));

end package vvc_cmd_pkg;
