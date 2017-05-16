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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;


package types_pkg is
  file ALERT_FILE : text;
  file LOG_FILE : text;
  
  constant C_LOG_HDR_FOR_WAVEVIEW_WIDTH : natural := 100; -- For string in waveview indicating last log header
  constant C_NUM_SYNC_FLAGS     : positive := 10;
  constant C_FLAG_NAME_LENGTH   : positive := 20;
  
  type t_void is (VOID);

  type t_natural_array is array (natural range <>) of natural;
  type t_integer_array is array (natural range <>) of integer;
  type t_byte_array    is array (natural range <>) of std_logic_vector(7 downto 0);


  -- Note: Most types below have a matching to_string() in 'string_methods_pkg.vhd'

  type t_info_target is (LOG_INFO, ALERT_INFO, USER_INFO);
  type t_alert_level is (NO_ALERT, NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK, ERROR, TB_ERROR, FAILURE, TB_FAILURE);

  type t_enabled      is (ENABLED, DISABLED);
  type t_attention    is (REGARD, EXPECT, IGNORE);
  type t_radix        is (BIN, HEX, DEC, HEX_BIN_IF_INVALID);
  type t_radix_prefix is (EXCL_RADIX, INCL_RADIX);
  type t_order        is (INTERMEDIATE, FINAL);
  type t_ascii_allow  is (ALLOW_ALL, ALLOW_PRINTABLE_ONLY); 
  type t_blocking_mode is (BLOCKING, NON_BLOCKING);
  type t_from_point_in_time is (FROM_NOW, FROM_LAST_EVENT);

  type t_format_zeros  is (AS_IS, KEEP_LEADING_0, SKIP_LEADING_0);  -- AS_IS is deprecated and will be removed. Use KEEP_LEADING_0.
  type t_format_string is (AS_IS, TRUNCATE, SKIP_LEADING_SPACE);    -- Deprecated, will be removed.
  type t_format_spaces is (KEEP_LEADING_SPACE, SKIP_LEADING_SPACE);
  type t_truncate_string is (ALLOW_TRUNCATE, DISALLOW_TRUNCATE);
  
  type t_log_format is (FORMATTED, UNFORMATTED);
  type t_log_if_block_empty is (WRITE_HDR_IF_BLOCK_EMPTY, SKIP_LOG_IF_BLOCK_EMPTY, NOTIFY_IF_BLOCK_EMPTY);

  type t_log_destination is (CONSOLE_AND_LOG, CONSOLE_ONLY, LOG_ONLY);
  
  type t_match_strictness is (MATCH_STD, MATCH_EXACT);
  
  type t_alert_counters  is array (NOTE to t_alert_level'right) of natural;
  type t_alert_attention is array (NOTE to t_alert_level'right) of t_attention;

  type t_attention_counters is array (t_attention'left to t_attention'right) of natural; -- Only used to build below type
  type t_alert_attention_counters is array (NOTE to t_alert_level'right) of t_attention_counters;
  
  type t_quietness  is (NON_QUIET, QUIET);
  
  type t_deprecate_setting is (NO_DEPRECATE, DEPRECATE_ONCE, ALWAYS_DEPRECATE);
  type t_deprecate_list is array(0 to 9) of string(1 to 100);

  type t_action_when_transfer_is_done is (RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_AFTER_TRANSFER);
  
  type t_global_ctrl is record
    attention  : t_alert_attention;
    stop_limit : t_alert_counters;
  end record;
  
  type t_current_log_hdr is record
    normal     : string(1 to C_LOG_HDR_FOR_WAVEVIEW_WIDTH);
    large      : string(1 to C_LOG_HDR_FOR_WAVEVIEW_WIDTH);
    xl         : string(1 to C_LOG_HDR_FOR_WAVEVIEW_WIDTH);
  end record;


  -- type for await_unblock_flag whether the method should set the flag back to blocked or not
  type t_flag_returning is (KEEP_UNBLOCKED, RETURN_TO_BLOCK); -- value after unblock

  type t_sync_flag_record is record
    flag_name  : string(1 to C_FLAG_NAME_LENGTH);
    is_active  : boolean;
  end record;
  
  constant C_SYNC_FLAG_DEFAULT : t_sync_flag_record := (
    flag_name  => (others => ' '),
    is_active  => true
  );
  type t_sync_flag_record_array is array (1 to C_NUM_SYNC_FLAGS) of t_sync_flag_record;


  type t_uvvm_status is record
    no_unexpected_simulation_warnings_or_worse  : natural range 0 to 1;
    no_unexpected_simulation_errors_or_worse    : natural range 0 to 1;
  end record t_uvvm_status;


  -------------------------------------
  -- BFMs and above
  -------------------------------------
  type t_transaction_result is (ACK, NAK, ERROR);  -- add more when needed
  
  type t_hierarchy_alert_level_print is array (NOTE to t_alert_level'right) of boolean;
  constant C_HIERARCHY_NODE_NAME_LENGTH : natural := 20;
  type t_hierarchy_node is 
      record
        name : string(1 to C_HIERARCHY_NODE_NAME_LENGTH);
        alert_attention_counters : t_alert_attention_counters;
        alert_stop_limit : t_alert_counters;
        alert_level_print : t_hierarchy_alert_level_print;
      end record;
  
  
  type t_bfm_delay_type is (NO_DELAY, TIME_FINISH2START, TIME_START2START);
  
  type t_inter_bfm_delay is
  record
    delay_type                          : t_bfm_delay_type;
    delay_in_time                       : time;
    inter_bfm_delay_violation_severity  : t_alert_level;
  end record;


end package types_pkg;

package body types_pkg is
end package body types_pkg;
