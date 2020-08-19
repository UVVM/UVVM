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
  constant C_FLAG_NAME_LENGTH   : positive := 20;

  type t_void is (VOID);

  type t_natural_array  is array (natural range <>) of natural;
  type t_integer_array  is array (natural range <>) of integer;
  type t_slv_array      is array (natural range <>) of std_logic_vector;
  type t_slv_array_ptr  is access t_slv_array;
  type t_signed_array   is array (natural range <>) of signed;
  type t_unsigned_array is array (natural range <>) of unsigned;

  subtype t_byte_array  is t_slv_array(open)(7 downto 0);

  -- Additions to predefined vector types
  type natural_vector  is array (natural range <>) of natural;
  type positive_vector is array (natural range <>) of positive;

  -- Note: Most types below have a matching to_string() in 'string_methods_pkg.vhd'
  type t_info_target is (LOG_INFO, ALERT_INFO, USER_INFO);
  type t_alert_level is (NO_ALERT, NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK, ERROR, TB_ERROR, FAILURE, TB_FAILURE);

  type t_enabled      is (ENABLED, DISABLED, NA);
  type t_attention    is (REGARD, EXPECT, IGNORE);
  type t_radix        is (BIN, HEX, DEC, HEX_BIN_IF_INVALID);
  type t_radix_prefix is (EXCL_RADIX, INCL_RADIX);
  type t_order        is (INTERMEDIATE, FINAL);
  type t_ascii_allow  is (ALLOW_ALL, ALLOW_PRINTABLE_ONLY);
  type t_blocking_mode is (BLOCKING, NON_BLOCKING);
  type t_from_point_in_time is (FROM_NOW, FROM_LAST_EVENT);
  type t_vvc_select   is (ANY_OF, ALL_OF, ALL_VVCS);
  type t_list_action  is (KEEP_LIST, CLEAR_LIST);

  type t_format_zeros  is (AS_IS, KEEP_LEADING_0, SKIP_LEADING_0);  -- AS_IS is deprecated and will be removed. Use KEEP_LEADING_0.
  type t_format_string is (AS_IS, TRUNCATE, SKIP_LEADING_SPACE);    -- Deprecated, will be removed.
  type t_format_spaces is (KEEP_LEADING_SPACE, SKIP_LEADING_SPACE);
  type t_truncate_string is (ALLOW_TRUNCATE, DISALLOW_TRUNCATE);

  type t_log_format is (FORMATTED, UNFORMATTED);
  type t_log_if_block_empty is (WRITE_HDR_IF_BLOCK_EMPTY, SKIP_LOG_IF_BLOCK_EMPTY, NOTIFY_IF_BLOCK_EMPTY);

  type t_log_destination is (CONSOLE_AND_LOG, CONSOLE_ONLY, LOG_ONLY);

  type t_match_strictness is (MATCH_STD, MATCH_STD_INCL_Z, MATCH_EXACT);

  type t_alert_counters  is array (NOTE to t_alert_level'right) of natural;
  type t_alert_attention is array (NOTE to t_alert_level'right) of t_attention;

  type t_attention_counters is array (t_attention'left to t_attention'right) of natural; -- Only used to build below type
  type t_alert_attention_counters is array (NOTE to t_alert_level'right) of t_attention_counters;

  type t_quietness  is (NON_QUIET, QUIET);

  type t_deprecate_setting is (NO_DEPRECATE, DEPRECATE_ONCE, ALWAYS_DEPRECATE);
  type t_deprecate_list is array(0 to 9) of string(1 to 100);

  type t_action_when_transfer_is_done is (RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_AFTER_TRANSFER);
  type t_when_to_start_transfer is (START_TRANSFER_IMMEDIATE, START_TRANSFER_ON_NEXT_SS);
  type t_action_between_words is (RELEASE_LINE_BETWEEN_WORDS, HOLD_LINE_BETWEEN_WORDS);

  type t_byte_endianness is (LOWER_BYTE_LEFT, LOWER_BYTE_RIGHT, LOWER_WORD_LEFT, LOWER_WORD_RIGHT, FIRST_BYTE_LEFT, FIRST_BYTE_RIGHT);
  alias t_word_endianness is t_byte_endianness;

  type t_pulse_continuation is (ALLOW_PULSE_CONTINUATION, NO_PULSE_CONTINUATION_ALLOWED);

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
    flag_name   : string(1 to C_FLAG_NAME_LENGTH);
    is_blocked  : boolean;
  end record;

  constant C_SYNC_FLAG_DEFAULT : t_sync_flag_record := (
    flag_name   => (others => NUL),
    is_blocked  => true
  );

  type t_sync_flag_record_array is array (natural range <>) of t_sync_flag_record;

  type t_watchdog_ctrl is record
    extend      : boolean;
    restart     : boolean;
    terminate   : boolean;
    extension   : time;
    new_timeout : time;
  end record;

  constant C_WATCHDOG_CTRL_DEFAULT : t_watchdog_ctrl := (
    extend      => false,
    restart     => false,
    terminate   => false,
    extension   => 0 ns,
    new_timeout => 0 ns
  );

  -- type for identifying VVC and command index finishing await_any_completion()
  type t_info_on_finishing_await_any_completion is record
    vvc_name                : string(1 to 100); -- VVC name should not exceed this length
    vvc_cmd_idx             : natural;          -- VVC command index
    vvc_time_of_completion  : time;             -- time of completion
  end record;

  type t_uvvm_status is record
    found_unexpected_simulation_warnings_or_worse     : natural range 0 to 1; -- simulation end status: 0=no unexpected, 1=unexpected
    found_unexpected_simulation_errors_or_worse       : natural range 0 to 1; -- simulation end status: 0=no unexpected, 1=unexpected
    mismatch_on_expected_simulation_warnings_or_worse : natural range 0 to 1; -- simulation status: 0=no mismatch, 1=mismatch
    mismatch_on_expected_simulation_errors_or_worse   : natural range 0 to 1; -- simulation status: 0=no mismatch, 1=mismatch
    info_on_finishing_await_any_completion            : t_info_on_finishing_await_any_completion; -- await_any_completion() trigger identifyer
  end record t_uvvm_status;

  -- defaults for t_uvvm_status and t_info_on_finishing_await_any_completion
  constant C_INFO_ON_FINISHING_AWAIT_ANY_COMPLETION_VVC_NAME_DEFAULT : string := "no await_any_completion() finshed yet\n";
  constant C_UVVM_STATUS_DEFAULT : t_uvvm_status := (
    found_unexpected_simulation_warnings_or_worse     => 0,
    found_unexpected_simulation_errors_or_worse       => 0,
    mismatch_on_expected_simulation_warnings_or_worse => 0,
    mismatch_on_expected_simulation_errors_or_worse   => 0,
    info_on_finishing_await_any_completion            => (vvc_name    => (C_INFO_ON_FINISHING_AWAIT_ANY_COMPLETION_VVC_NAME_DEFAULT, others => ' '),
                                                          vvc_cmd_idx => 0,
                                                          vvc_time_of_completion => 0 ns)
  );

  type t_justify_center is (center);

  type t_parity is (
    PARITY_NONE,
    PARITY_ODD,
    PARITY_EVEN
  );

  type t_stop_bits is (
    STOP_BITS_ONE,
    STOP_BITS_ONE_AND_HALF,
    STOP_BITS_TWO
  );


  type t_check_type is (CHECK_VALUE, 
                        CHECK_VALUE_IN_RANGE, 
                        CHECK_STABLE,
                        CHECK_TIME_WINDOW);
  type t_check_counters_array is array (CHECK_VALUE to t_check_type'right) of natural;



  -------------------------------------
  -- BFMs and above
  -------------------------------------
  type t_transaction_result is (ACK, NAK, ERROR);  -- add more when needed

  type t_hierarchy_alert_level_print is array (NOTE to t_alert_level'right) of boolean;
  constant C_HIERARCHY_NODE_NAME_LENGTH : natural := 30; -- Maximum scope length, has to match C_LOG_SCOPE_WIDTH in adaptations_pkg
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

  type t_void_bfm_config is (VOID);
  constant C_VOID_BFM_CONFIG : t_void_bfm_config := VOID;

  type t_data_routing is (
    NA,
    TO_SB,
    TO_BUFFER,
    FROM_BUFFER,
    TO_RECEIVE_BUFFER); -- TO_FILE and FROM_FILE may be added later on

  type t_bfm_sync is (
    SYNC_ON_CLOCK_ONLY,
    SYNC_WITH_SETUP_AND_HOLD
  );

  type t_test_status is (NA, PASS, FAIL);
  
  type t_activity is (ACTIVE, INACTIVE);

  type t_extent_tickoff is (LIST_SINGLE_TICKOFF, LIST_EVERY_TICKOFF);

  
  -------------------------------------
  -- SB
  -------------------------------------
  -- Identifier_option: Typically describes what the next parameter means.
  -- - ENTRY_NUM :
  --     Incremented for each entry added to the queue.
  --     Unlike POSITION, the ENTRY_NUMBER will stay the same for this entry, even if entries are inserted before this entry
  -- - POSITION :
  --     Position of entry in queue, independent of when the entry was inserted.
  type t_identifier_option is (ENTRY_NUM, POSITION);

  type t_range_option is (SINGLE, AND_LOWER, AND_HIGHER);

  type t_tag_usage is (TAG, NO_TAG);

end package types_pkg;

package body types_pkg is
end package body types_pkg;