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
    ENABLE_LOG_MSG,
    DISABLE_LOG_MSG,
    FLUSH_COMMAND_QUEUE,
    FETCH_RESULT,
    INSERT_DELAY,
    INSERT_DELAY_IN_TIME,
    TERMINATE_CURRENT_COMMAND,
    -- VVC local
    MASTER_TRANSMIT, MASTER_CHECK, SLAVE_TRANSMIT, SLAVE_CHECK);

  --===============================================================================================
  -- to_string
  -- - Function for retrieving the string equivalent of a t_operation value 
  --===============================================================================================
  function to_string(
    value : t_operation
    ) return string;

  constant C_VVC_CMD_STRING_MAX_LENGTH : natural := 300;
  constant C_VVC_CMD_DATA_MAX_LENGTH   : natural := 64;
  constant C_VVC_CMD_ADDR_MAX_LENGTH   : natural := 10;

  --===============================================================================================
  -- t_vvc_cmd_record
  -- - Record type used for communication with the VVC
  --===============================================================================================
  type t_vvc_cmd_record is record
    -- VVC dedicated fields
    addr         : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0);
    data         : t_byte_array(0 to C_VVC_CMD_DATA_MAX_LENGTH-1);
    num_bytes    : natural;
    continue     : boolean;
    -- Common VVC fields  (Used by td_vvc_framework_common_methods_pkg procedures, and thus mandatory)
    operation    : t_operation;
    proc_call    : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    msg          : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    cmd_idx      : natural;
    command_type : t_immediate_or_queued;  -- QUEUED/IMMEDIATE
    msg_id       : t_msg_id;
    gen_integer  : integer;
    alert_level  : t_alert_level;
    delay        : time;
    quietness    : t_quietness;
  end record;

  constant C_VVC_CMD_DEFAULT : t_vvc_cmd_record := (
    addr         => (others => '0'),
    data         => (others => (others => '0')),
    num_bytes    => 0,
    continue     => true,
    -- Common VVC fields
    operation    => NO_OPERATION,
    proc_call    => (others => NUL),
    msg          => (others => NUL),
    cmd_idx      => 0,
    command_type => NO_COMMAND_TYPE,
    msg_id       => NO_ID,
    gen_integer  => -1,
    alert_level  => failure,
    delay        => 0 ns,
    quietness    => NON_QUIET
    );

  --===============================================================================================
  -- shared_vvc_cmd
  --  - Shared variable used for transmitting VVC commands
  --===============================================================================================
  shared variable shared_vvc_cmd : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;

end package vvc_cmd_pkg;


--=================================================================================================
--=================================================================================================


package body vvc_cmd_pkg is

  function to_string(
    value : t_operation
    ) return string is
  begin
    return t_operation'image(value);
  end;


end package body vvc_cmd_pkg;


