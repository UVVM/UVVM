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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

--=================================================================================================
--=================================================================================================
--=================================================================================================
package vvc_cmd_pkg is

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
    MASTER_TRANSMIT_AND_RECEIVE, MASTER_TRANSMIT_AND_CHECK, MASTER_TRANSMIT_ONLY, MASTER_RECEIVE_ONLY, MASTER_CHECK_ONLY,
    SLAVE_TRANSMIT_AND_RECEIVE, SLAVE_TRANSMIT_AND_CHECK, SLAVE_TRANSMIT_ONLY, SLAVE_RECEIVE_ONLY, SLAVE_CHECK_ONLY);


  constant C_VVC_CMD_STRING_MAX_LENGTH : natural := 300;
  constant C_VVC_CMD_DATA_MAX_LENGTH   : natural := 32;
  constant C_VVC_CMD_MAX_WORDS         : natural := 8;


  --===============================================================================================
  -- t_vvc_cmd_record
  -- - Record type used for communication with the VVC
  --===============================================================================================
  type t_vvc_cmd_record is record
    -- VVC dedicated fields
    data                         : t_slv_array(C_VVC_CMD_MAX_WORDS-1 downto 0)(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    data_exp                     : t_slv_array(C_VVC_CMD_MAX_WORDS-1 downto 0)(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    num_words                    : natural;
    word_length                  : natural;
    when_to_start_transfer       : t_when_to_start_transfer;
    action_when_transfer_is_done : t_action_when_transfer_is_done;
    action_between_words         : t_action_between_words;
    -- Common VVC fields  (Used by td_vvc_framework_common_methods_pkg procedures, and thus mandatory)
    operation                    : t_operation;
    proc_call                    : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    msg                          : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    cmd_idx                      : natural;
    command_type                 : t_immediate_or_queued;  -- QUEUED/IMMEDIATE
    msg_id                       : t_msg_id;
    gen_integer_array            : t_integer_array(0 to 1);  -- Increase array length if needed
    gen_boolean                  : boolean;                -- Generic boolean
    timeout                      : time;
    alert_level                  : t_alert_level;
    delay                        : time;
    quietness                    : t_quietness;
  end record;

  constant C_VVC_CMD_DEFAULT : t_vvc_cmd_record := (
    data                         => (others => (others => '0')),
    data_exp                     => (others => (others => '0')),
    num_words                    => 0,
    word_length                  => 0,
    when_to_start_transfer       => START_TRANSFER_IMMEDIATE,
    action_when_transfer_is_done => RELEASE_LINE_AFTER_TRANSFER,
    action_between_words         => HOLD_LINE_BETWEEN_WORDS,
    -- Common VVC fields
    operation                    => NO_OPERATION,
    proc_call                    => (others => NUL),
    msg                          => (others => NUL),
    cmd_idx                      => 0,
    command_type                 => NO_COMMAND_TYPE,
    msg_id                       => NO_ID,
    gen_integer_array            => (others => -1),
    gen_boolean                  => false,
    timeout                      => 0 ns,
    alert_level                  => failure,
    delay                        => 0 ns,
    quietness                    => NON_QUIET
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
  subtype t_vvc_result is std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);

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
  shared variable shared_vvc_last_received_cmd_idx : t_last_received_cmd_idx(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM) := (others => (others => -1));

end package vvc_cmd_pkg;


--=================================================================================================
--=================================================================================================


package body vvc_cmd_pkg is


end package body vvc_cmd_pkg;


