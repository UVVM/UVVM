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
use std.textio.all;


use work.types_pkg.all;

package adaptations_pkg is
  constant C_ALERT_FILE_NAME : string := "_Alert.txt";
  constant C_LOG_FILE_NAME   : string := "_Log.txt";

  constant C_SHOW_UVVM_UTILITY_LIBRARY_INFO         : boolean := true;  -- Set this to false when you no longer need the initial info
  constant C_SHOW_UVVM_UTILITY_LIBRARY_RELEASE_INFO : boolean := true;  -- Set this to false when you no longer need the release info

  constant C_UVVM_TIMEOUT    : time := 100 us; -- General timeout for UVVM wait statements

  --------------------------------------------------------------------------------------------------------------------------------
  -- Log format
  --------------------------------------------------------------------------------------------------------------------------------
  --UVVM: [<ID>]  <time>  <Scope>        Msg
  --PPPPPPPPIIIIII TTTTTTTT  SSSSSSSSSSSSSS MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
  constant C_LOG_PREFIX : string := "UVVM: "; -- Note: ': ' is recommended as final characters

  constant C_LOG_PREFIX_WIDTH   : natural := C_LOG_PREFIX'length;
  constant C_LOG_MSG_ID_WIDTH   : natural := 24;
  constant C_LOG_TIME_WIDTH     : natural := 16; -- 3 chars used for unit eg. " ns"
  constant C_LOG_TIME_BASE      : time    := ns; -- Unit in which time is shown in log (ns | ps)
  constant C_LOG_TIME_DECIMALS  : natural := 1; -- Decimals to show for given C_LOG_TIME_BASE
  constant C_LOG_SCOPE_WIDTH    : natural := 30; -- Maximum scope length, has to match C_HIERARCHY_NODE_NAME_LENGTH in types_pkg
  constant C_LOG_LINE_WIDTH     : natural := 175;
  constant C_LOG_INFO_WIDTH     : natural := C_LOG_LINE_WIDTH - C_LOG_PREFIX_WIDTH;

  constant C_USE_BACKSLASH_N_AS_LF : boolean := true; -- If true interprets '\n' as Line feed
  constant C_USE_BACKSLASH_R_AS_LF : boolean := true; -- If true, inserts an empty line if '\r'
                                                      -- is the first character of the string.
                                                      -- All others '\r' will be printed as is.

  constant C_SINGLE_LINE_ALERT  : boolean := false; -- If true prints alerts on a single line.
  constant C_SINGLE_LINE_LOG    : boolean := false; -- If true prints log messages on a single line.

  constant C_TB_SCOPE_DEFAULT       : string := "TB seq."; -- Default scope in test sequencer
  constant C_SCOPE                  : string := C_TB_SCOPE_DEFAULT & "(uvvm)";
  constant C_VVC_CMD_SCOPE_DEFAULT  : string := C_TB_SCOPE_DEFAULT & "(uvvm)"; -- Default scope in VVC commands

  constant C_LOG_TIME_TRUNC_WARNING : boolean := true; -- Yields a single TB_WARNING if time stamp truncated. Otherwise none
  constant C_SHOW_LOG_ID            : boolean := true; -- This constant has replaced the global_show_log_id
  constant C_SHOW_LOG_SCOPE         : boolean := true; -- This constant has replaced the global_show_log_scope

  constant C_WARNING_ON_LOG_ALERT_FILE_RUNTIME_RENAME : boolean := false;

  constant C_USE_STD_STOP_ON_ALERT_STOP_LIMIT : boolean := true; -- true: break using std.env.stop, false: break using failure

  shared variable shared_default_log_destination : t_log_destination := CONSOLE_AND_LOG;

  --------------------------------------------------------------------------------------------------------------------------------
  -- Verbosity control
  -- NOTE: Do not enter new IDs without proper evaluation:
  --       1. Is it - or could it be covered by an existing ID
  --       2. Could it be combined with other needs for a more general new ID
  --       Feel free to suggest new ID for future versions of UVVM Utility Library (support@bitvis.no)
  --------------------------------------------------------------------------------------------------------------------------------
  type t_msg_id is (
    -- Bitvis utility methods
    NO_ID,                    -- Used as default prior to setting actual ID when transfering ID as a field in a record
    ID_UTIL_BURIED,           -- Used for buried log messages where msg and scope cannot be modified from outside
    ID_BITVIS_DEBUG,          -- Bitvis internal ID used for UVVM debugging
    ID_UTIL_SETUP,            -- Used for Utility setup
    ID_LOG_MSG_CTRL,          -- Used inside Utility library only - when enabling/disabling msg IDs.
    ID_ALERT_CTRL,            -- Used inside Utility library only - when setting IGNORE or REGARD on various alerts.
    ID_NEVER,                 -- Used for avoiding log entry. Cannot be enabled.
    ID_FINISH_OR_STOP,        -- Used when terminating the complete simulation - independent of why
    ID_CLOCK_GEN,             -- Used for logging when clock generators are enabled or disabled
    ID_GEN_PULSE,             -- Used for logging when a gen_pulse procedure starts pulsing a signal
    ID_BLOCKING,              -- Used for logging when using synchronisation flags
    ID_WATCHDOG,              -- Used for logging the activity of the watchdog
    -- General
    ID_POS_ACK,               -- To write a positive acknowledge on a check
    -- Directly inside test sequencers
    ID_LOG_HDR,               -- ONLY allowed in test sequencer, Log section headers
    ID_LOG_HDR_LARGE,         -- ONLY allowed in test sequencer, Large log section headers
    ID_LOG_HDR_XL,            -- ONLY allowed in test sequencer, Extra large log section headers
    ID_SEQUENCER,             -- ONLY allowed in test sequencer, Normal log (not log headers)
    ID_SEQUENCER_SUB,         -- ONLY allowed in test sequencer, Subprograms defined in sequencer
    -- BFMs
    ID_BFM,                   -- Used inside a BFM (to log BFM access)
    ID_BFM_WAIT,              -- Used inside a BFM to indicate that it is waiting for something (e.g. for ready)
    ID_BFM_POLL,              -- Used inside a BFM when polling until reading a given value. I.e. to show all reads until expected value found (e.g. for sbi_poll_until())
    ID_BFM_POLL_SUMMARY,      -- Used inside a BFM when showing the summary of data that has been received while waiting for expected data.
    ID_CHANNEL_BFM,           -- Used inside a BFM when the protocol is split into separate channels
    ID_TERMINATE_CMD,         -- Typically used inside a loop in a procedure to end the loop (e.g. for sbi_poll_until() or any looped generation of random stimuli
    -- Packet related data Ids with three levels of granularity, for differentiating between frames, packets and segments.
    -- Segment Ids, finest granularity of packet data
    ID_SEGMENT_INITIATE,      -- Notify that a segment is about to be transmitted or received
    ID_SEGMENT_COMPLETE,      -- Notify that a segment has been transmitted or received
    ID_SEGMENT_HDR,           -- Notify that a segment header has been transmitted or received. It also writes header info
    ID_SEGMENT_DATA,          -- Notify that a segment data has been transmitted or received. It also writes segment data
    -- Packet Ids, medium granularity of packet data
    ID_PACKET_INITIATE,       -- Notify that a packet is about to be transmitted or received
    ID_PACKET_PREAMBLE,       -- Notify that a packet preamble has been transmitted or received
    ID_PACKET_COMPLETE,       -- Notify that a packet has been transmitted or received
    ID_PACKET_HDR,            -- Notify that a packet header has been transmitted or received. It also writes header info
    ID_PACKET_DATA,           -- Notify that a packet data has been transmitted or received. It also writes packet data
    ID_PACKET_CHECKSUM,       -- Notify that a packet checksum has been transmitted or received
    ID_PACKET_GAP,            -- Notify that an interpacket gap is in process
    -- Frame Ids, roughest granularity of packet data
    ID_FRAME_INITIATE,        -- Notify that a frame is about to be transmitted or received
    ID_FRAME_COMPLETE,        -- Notify that a frame has been transmitted or received
    ID_FRAME_HDR,             -- Notify that a frame header has been transmitted or received. It also writes header info
    ID_FRAME_DATA,            -- Notify that a frame data has been transmitted or received. It also writes frame data
    -- OSVVM Ids
    ID_COVERAGE_MAKEBIN,      -- Log messages from MakeBin (IllegalBin/GenBin/IgnoreBin)
    ID_COVERAGE_ADDBIN,       -- Log messages from AddBin/AddCross
    ID_COVERAGE_ICOVER,       -- ICover logging, NB: Very low level debugging. Can result in large amount of data.
    ID_COVERAGE_CONFIG,       -- Logging of configuration in the coverage package
    ID_COVERAGE_SUMMARY,      -- Report logging : Summary of coverage, with both covered bins and holes
    ID_COVERAGE_HOLES,        -- Report logging : Holes only
    -- Distributed command systems
    ID_UVVM_SEND_CMD,         -- Logs the commands sent to the VVC
    ID_UVVM_CMD_ACK,          -- Logs the command's ACKs or timeouts from the VVC
    ID_UVVM_CMD_RESULT,       -- Logs the fetched results from the VVC
    ID_CMD_INTERPRETER,       -- Message from VVC interpreter about correctly received and queued/issued command
    ID_CMD_INTERPRETER_WAIT,  -- Message from VVC interpreter that it is actively waiting for a command
    ID_IMMEDIATE_CMD,         -- Message from VVC interpreter that an IMMEDIATE command has been executed
    ID_IMMEDIATE_CMD_WAIT,    -- Message from VVC interpreter that an IMMEDIATE command is waiting for command to complete
    ID_CMD_EXECUTOR,          -- Message from VVC executor about correctly received command - prior to actual execution
    ID_CMD_EXECUTOR_WAIT,     -- Message from VVC executor that it is actively waiting for a command
    ID_CHANNEL_EXECUTOR,      -- Message from a channel specific VVC executor process
    ID_CHANNEL_EXECUTOR_WAIT, -- Message from a channel specific VVC executor process that it is actively waiting for a command
    ID_NEW_HVVC_CMD_SEQ,      -- Message from a lower level VVC which receives a new command sequence from an HVVC
    ID_INSERTED_DELAY,        -- Message from VVC executor that it is waiting a given delay
    -- Await completion
    ID_OLD_AWAIT_COMPLETION,  -- Temporary log messages related to old await_completion mechanism. Will be removed in v3.0
    ID_AWAIT_COMPLETION,      -- Used for logging the procedure call waiting for completion
    ID_AWAIT_COMPLETION_LIST, -- Used for logging modifications to the list of VVCs waiting for completion
    ID_AWAIT_COMPLETION_WAIT, -- Used for logging when the procedure starts waiting for completion
    ID_AWAIT_COMPLETION_END,  -- Used for logging when the procedure has finished waiting for completion
    -- Distributed data
    ID_UVVM_DATA_QUEUE,       -- Information about UVVM data FIFO/stack (initialization, put, get, etc)
    -- VVC system
    ID_CONSTRUCTOR,           -- Constructor message from VVCs (or other components/process when needed)
    ID_CONSTRUCTOR_SUB,       -- Constructor message for lower level constructor messages (like Queue-information and other limitations)
    ID_VVC_ACTIVITY,
    -- Monitors
    ID_MONITOR,               -- General monitor information
    ID_MONITOR_ERROR,         -- General monitor errors
    -- SB package
    ID_DATA,                  -- To write general handling of data
    ID_CTRL,                  -- To write general control/config information
    -- Specification vs Verification IDs
    ID_FILE_OPEN_CLOSE,       -- Id used when opening / closing file
    ID_FILE_PARSER,           -- Id used in file parsers
    ID_SPEC_COV,              -- Messages from the specification coverage methods
    -- Special purpose - Not really IDs
    ALL_MESSAGES              -- Applies to ALL message ID apart from ID_NEVER
    );
  type t_msg_id_panel is array (t_msg_id'left to t_msg_id'right) of t_enabled;

  constant C_TB_MSG_ID_DEFAULT : t_msg_id := ID_SEQUENCER; -- msg ID used when calling the log method without any msg ID switch.

  -- Default message Id panel to be used for all message Id panels, except:
  --  - VVC message Id panels, see constant C_VVC_MSG_ID_PANEL_DEFAULT
  constant C_MSG_ID_PANEL_DEFAULT : t_msg_id_panel := (
    ID_NEVER            => DISABLED,
    ID_UTIL_BURIED      => DISABLED,
    ID_BITVIS_DEBUG     => DISABLED,
    ID_COVERAGE_MAKEBIN => DISABLED,
    ID_COVERAGE_ADDBIN  => DISABLED,
    ID_COVERAGE_ICOVER  => DISABLED,
    others              => ENABLED
  );

  -- If false, OSVVM uses the default message id panel. If true, it uses a separate message id panel.
  constant C_USE_LOCAL_OSVVM_MSG_ID_PANELS : boolean := TRUE;

  type  t_msg_id_indent is array (t_msg_id'left to t_msg_id'right) of string(1 to 4);
  constant C_MSG_ID_INDENT : t_msg_id_indent := (
    ID_IMMEDIATE_CMD_WAIT    => "  ..",
    ID_CMD_INTERPRETER       => "  "   & NUL & NUL,
    ID_CMD_INTERPRETER_WAIT  => "  ..",
    ID_CMD_EXECUTOR          => "  "   & NUL & NUL,
    ID_CMD_EXECUTOR_WAIT     => "  ..",
    ID_UVVM_SEND_CMD         => "->"   & NUL & NUL,
    ID_UVVM_CMD_ACK          => "    ",
    ID_NEW_HVVC_CMD_SEQ      => "  "   & NUL & NUL,
    ID_AWAIT_COMPLETION_WAIT => ".."   & NUL & NUL,
    ID_AWAIT_COMPLETION_END  => "  "   & NUL & NUL,
    others                   => ""     & NUL & NUL & NUL & NUL
  );

  constant C_MSG_DELIMITER : character := ''';

  --------------------------------------------------------------------------------------------------------------------------------
  -- Alert counters
  --------------------------------------------------------------------------------------------------------------------------------
  -- Default values. These can be overwritten in each sequencer by using
  -- set_alert_attention or set_alert_stop_limit (see quick ref).
  constant C_DEFAULT_ALERT_ATTENTION : t_alert_attention := (others => REGARD);

  -- 0 = Never stop
  constant C_DEFAULT_STOP_LIMIT : t_alert_counters := (note to manual_check => 0,
                                                       others               => 1);

  --------------------------------------------------------------------------------------------------------------------------------
  -- Hierarchical alerts
  --------------------------------------------------------------------------------------------------------------------------------
  constant C_ENABLE_HIERARCHICAL_ALERTS : boolean := false;
  constant C_BASE_HIERARCHY_LEVEL : string(1 to 5) := "Total";

  constant C_EMPTY_NODE : t_hierarchy_node := ("                              ",
                                                (others => (others => 0)),
                                                (others => 0),
                                                (others => true));

  --------------------------------------------------------------------------------------------------------------------------------
  -- Synchronisation
  --------------------------------------------------------------------------------------------------------------------------------
  constant C_NUM_SYNC_FLAGS : positive := 100; -- Maximum number of sync flags

  --------------------------------------------------------------------------------------------------------------------------------
  -- UVVM VVC Framework adaptations
  --------------------------------------------------------------------------------------------------------------------------------
  signal global_show_msg_for_uvvm_cmd  : boolean := true;

  constant C_CMD_QUEUE_COUNT_MAX                     : natural       := 20;  -- (VVC Command queue)  May be overwritten for dedicated VVC
  constant C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY      : t_alert_level := WARNING;
  constant C_CMD_QUEUE_COUNT_THRESHOLD               : natural       := 18;
  constant C_RESULT_QUEUE_COUNT_MAX                  : natural       := 20;  -- (VVC Result queue)  May be overwritten for dedicated VVC
  constant C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY   : t_alert_level := WARNING;
  constant C_RESULT_QUEUE_COUNT_THRESHOLD            : natural       := 18;
  constant C_MAX_VVC_INSTANCE_NUM                    : natural       := 8;
  constant C_MAX_NUM_SEQUENCERS                      : natural       := 10; -- Max number of sequencers
  constant C_MAX_TB_VVC_NUM                          : natural       := 20; -- Max number of VVCs in testbench (including all channels)

  -- Maximum allowed length of VVC names
  constant C_MAX_VVC_NAME_LENGTH                     : positive      := 20;

  -- Minimum width of vvc name and channel displayed in scope.
  -- These combined + the length of instance + 2 (commas), cannot exceed C_LOG_SCOPE_WIDTH.
  constant C_MINIMUM_CHANNEL_SCOPE_WIDTH             : natural       := 10;
  constant C_MINIMUM_VVC_NAME_SCOPE_WIDTH            : natural       := 10;

  constant C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER     : natural := 2048;
  constant C_NUMBER_OF_DATA_BUFFERS                  : natural := 10;

  -- Default message Id panel intended for use in the VVCs
  constant C_VVC_MSG_ID_PANEL_DEFAULT : t_msg_id_panel := (
    ID_NEVER                  => DISABLED,
    ID_UTIL_BURIED            => DISABLED,
    ID_CHANNEL_BFM            => DISABLED,
    ID_CHANNEL_EXECUTOR       => DISABLED,
    ID_CHANNEL_EXECUTOR_WAIT  => DISABLED,
    others                    => ENABLED
  );

  -- Deprecated, will be removed.
  type t_data_source is (
    NA,
    FROM_BUFFER,
    RANDOM,
    RANDOM_TO_BUFFER
  );

  -- Deprecated, will be removed.
  type t_error_injection is (
    NA,
    RANDOM_BIT_ERROR,
    RANDOM_DATA_ERROR,
    RANDOM_ADDRESS_ERROR
  );

  type t_randomisation is (
    NA,
    RANDOM,
    RANDOM_FAVOUR_EDGES
  );

  type t_channel is (
    NA,               -- When channel is not relevant
    ALL_CHANNELS,     -- When command shall be received by all channels
    -- UVVM predefined channels.
    RX, TX
    -- User can add more channels if needed below.
  );

  constant C_NUM_SEMAPHORE_LOCK_TRIES : natural := 500;

    
  constant C_MAX_QUEUE_INSTANCE_NUM : positive  := 100; -- Maximum number of generic queue instances

  --------------------------------------------------------------------------------------------------------------------------------
  -- Scoreboard adaptations
  --------------------------------------------------------------------------------------------------------------------------------
  alias C_MAX_SB_INSTANCE_IDX       is C_MAX_QUEUE_INSTANCE_NUM; -- Maximum number of SB instances
  constant C_SB_TAG_WIDTH           : positive  := 128; -- Number of characters in SB tag
  constant C_SB_SOURCE_WIDTH        : positive  := 128; -- Number of characters in SB source element
  constant C_SB_SLV_WIDTH           : positive  := 128; -- Width of the SLV in the predefined SLV SB

  -- Default message Id panel intended for use in SB
  constant C_SB_MSG_ID_PANEL_DEFAULT : t_msg_id_panel := (
    ID_CTRL => ENABLED,
    ID_DATA => DISABLED,
    others  => DISABLED
  );

  --------------------------------------------------------------------------------------------------------------------------------
  -- Hierarchical-VVCs
  --------------------------------------------------------------------------------------------------------------------------------
  -- HVVC supported interfaces
  type t_interface is (SBI, GMII);

  -- For frame-based communication
  type t_frame_field is (
    HEADER,
    PAYLOAD,
    CHECKSUM
  );

  -- Message Id panel with all IDs as NA
  constant C_UNUSED_MSG_ID_PANEL : t_msg_id_panel := (
    others => NA
  );

  --------------------------------------------------------------------------------------------------------------------------------
  -- CRC
  --------------------------------------------------------------------------------------------------------------------------------
  -- CRC-32 (IEEE 802.3)
  constant C_CRC_32_START_VALUE : std_logic_vector(31 downto 0) := x"FFFFFFFF";
  constant C_CRC_32_POLYNOMIAL  : std_logic_vector(32 downto 0) := (32|26|23|22|16|12|11|10|8|7|5|4|2|1|0 => '1', others => '0'); --0x04C11DB7
  constant C_CRC_32_RESIDUE     : std_logic_vector(31 downto 0) := x"C704DD7B"; -- using left shifting CRC

  --------------------------------------------------------------------------------------------------------------------------------
  -- *****************************************************************************************************************************
  -- WARNING!
  -- The code below is not intended for user modifications!
  -- *****************************************************************************************************************************
  --------------------------------------------------------------------------------------------------------------------------------

  constant C_CMD_IDX_PREFIX       : string := " [";
  constant C_CMD_IDX_SUFFIX       : string := "]";

  constant ALL_INSTANCES          : integer := -2;
  constant ALL_ENABLED_INSTANCES  : integer := -3;


  type t_vvc_id is record
    name      : string(1 to C_MAX_VVC_NAME_LENGTH);
    instance  : natural;
    channel   : t_channel;
  end record;
  constant C_VVC_ID_DEFAULT : t_vvc_id := (
    name      => (others => NUL),
    instance  => 0,
    channel   => NA
  );

  type t_vvc_state is record
    activity                  : t_activity;
    last_cmd_idx_executed     : integer;
    await_selected_supported  : boolean;
  end record;
  constant  C_VVC_STATE_DEFAULT : t_vvc_state := (
    activity                  => INACTIVE,
    last_cmd_idx_executed     => -1,
    await_selected_supported  => true
  );

  -- These values are used to indicate outdated sub-programs
  constant C_DEPRECATE_SETTING : t_deprecate_setting := DEPRECATE_ONCE;
  shared variable deprecated_subprogram_list : t_deprecate_list := (others=>(others => ' '));

end package adaptations_pkg;

package body adaptations_pkg is
end package body adaptations_pkg;