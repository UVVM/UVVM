--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved.
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

use work.axistream_bfm_pkg.all; 
--========================================================================================================================
--========================================================================================================================
package vvc_cmd_pkg is

  --===============================================================================================
  -- t_operation
  -- - Bitvis defined BFM operations
  --===============================================================================================
  type t_operation is (
    -- UVVM common
    NO_OPERATION,
    AWAIT_COMPLETION,
    ENABLE_LOG_MSG,
    DISABLE_LOG_MSG,
    FLUSH_COMMAND_QUEUE,
    FETCH_RESULT,
    INSERT_DELAY,
    INSERT_DELAY_IN_TIME,
    TERMINATE_CURRENT_COMMAND,
    -- VVC local
    TRANSMIT, 
    RECEIVE, 
    EXPECT
  );

  -- Constants for the maximum sizes to use in this VVC.
  -- You can create VVCs with smaller sizes than these constants, but not larger.
  
  -- Create constants for the maximum sizes to use in this VVC.
  constant C_VVC_CMD_DATA_MAX_BYTES          : natural := 16*1024;
  constant C_VVC_CMD_DATA_MAX_WORDS          : natural := C_VVC_CMD_DATA_MAX_BYTES;
  constant C_VVC_CMD_STRING_MAX_LENGTH        : natural := 300;

  --===============================================================================================
  -- t_vvc_cmd_record
  -- - Record type used for communication with the VVC
  --===============================================================================================
  type t_vvc_cmd_record is record
    -- VVC dedicated fields
    data_array             : t_slv8_array(0 to C_VVC_CMD_DATA_MAX_BYTES-1); 
    data_array_length       : integer range -10 to C_VVC_CMD_DATA_MAX_BYTES; -- Some negative numbers have special meaning in axistreamStartTransmits()
    -- If you need support for more bits per data byte, replace this with a wider type:
    user_array             : t_user_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1); 
    user_array_length       : natural range 1 to C_VVC_CMD_DATA_MAX_WORDS; -- One user_array entry per word (clock cycle)

    -- Common VVC fields
    operation             : t_operation;
    proc_call             : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    msg                   : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    cmd_idx               : natural;
    command_type          : t_immediate_or_queued;
    msg_id                : t_msg_id;
    gen_integer           : integer;
    alert_level           : t_alert_level;
    delay                 : time;
    quietness            : t_quietness;
  end record;

  constant C_VVC_CMD_DEFAULT : t_vvc_cmd_record := (
    data_array             => (others => (others => '0')),
    data_array_length       => 1,
    user_array             => (others => (others => '0')),
    user_array_length       => 1,
    -- Common VVC fields
    operation             => NO_OPERATION,
    proc_call             => (others => NUL),
    msg                   => (others => NUL),
    cmd_idx               => 0,
    command_type          => NO_COMMAND_TYPE,
    msg_id                => NO_ID,
    gen_integer           => -1,
    alert_level           => FAILURE,
    delay               => 0 ns,
    quietness           => NON_QUIET
  );

  --===============================================================================================
  -- shared_vvc_cmd
  -- - Shared variable used for transmitting VVC commands
  --===============================================================================================
  shared variable shared_vvc_cmd : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;

end package vvc_cmd_pkg;


package body vvc_cmd_pkg is
end package body vvc_cmd_pkg;

