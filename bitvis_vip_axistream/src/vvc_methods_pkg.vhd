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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.axistream_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;

--========================================================================================================================
--========================================================================================================================
package vvc_methods_pkg is

  --========================================================================================================================
  -- Types and constants for the AXISTREAM VVC
  --========================================================================================================================
  constant C_VVC_NAME : string := "AXISTREAM_VVC";

  signal AXISTREAM_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT       : t_vvc_target_record is AXISTREAM_VVCT;
  alias t_bfm_config is t_axistream_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_AXISTREAM_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => warning
    );

  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay;           -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;                     -- Maximum pending number in command queue before queue is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;                     -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command queue exceeds this count. Used for early warning if command queue is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;               -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold
    result_queue_count_max                : natural;                  -- Maximum number of unfetched results before result_queue is full.
    result_queue_count_threshold_severity : t_alert_level;            -- An alert with severity 'result_queue_count_threshold_severity' will be issued if command queue exceeds this count. Used for early warning if result queue is almost full. Will be ignored if set to 0.
    result_queue_count_threshold          : natural;                  -- Severity of alert to be initiated if exceeding result_queue_count_threshold
    bfm_config                            : t_axistream_bfm_config;      -- Configuration for the BFM. See BFM quick reference
    msg_id_panel                          : t_msg_id_panel;              -- VVC dedicated message ID panel
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_AXISTREAM_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_AXISTREAM_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_AXISTREAM_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT
    );

  type t_vvc_status is
  record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record;

  type t_vvc_status_array is array (natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
    );

  type t_transaction_info is
  record
    operation      : t_operation;
    numPacketsSent : natural;
    msg            : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
  end record;

  type t_transaction_info_array is array (natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    operation      => NO_OPERATION,
    numPacketsSent => 0,
    msg            => (others => ' ')
    );


  shared variable shared_axistream_vvc_config       : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM-1)       := (others => C_AXISTREAM_VVC_CONFIG_DEFAULT);
  shared variable shared_axistream_vvc_status       : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM-1)       := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_axistream_transaction_info : t_transaction_info_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_TRANSACTION_INFO_DEFAULT);


  --========================================================================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order to queue BFM calls
  --   in the VVC command queue. The VVC will store and forward these calls to the
  --   AXISTREAM BFM when the command is at the from of the VVC command queue.
  --========================================================================================================================

  --------------------------------------------------------
  --
  -- AXIStream Transmit
  --
  --------------------------------------------------------

  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_user_array
    constant strb_array       : in    t_strb_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_strb_array
    constant id_array         : in    t_id_array;    -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_id_array
    constant dest_array       : in    t_dest_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_dest_array
    constant msg              : in    string
    );
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_user_array
    constant strb_array       : in    t_strb_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_strb_array
    constant id_array         : in    t_id_array;    -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_id_array
    constant dest_array       : in    t_dest_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_dest_array
    constant msg              : in    string
    );
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_user_array
    constant strb_array       : in    t_strb_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_strb_array
    constant id_array         : in    t_id_array;    -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_id_array
    constant dest_array       : in    t_dest_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_dest_array
    constant msg              : in    string
    );

  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, replace this with a wider type:
    constant msg              : in    string
    );
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, replace this with a wider type:
    constant msg              : in    string
    );
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, replace this with a wider type:
    constant msg              : in    string
    );

  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant msg              : in    string
    );
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant msg              : in    string
    );
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant msg              : in    string
    );


  --------------------------------------------------------
  --
  -- AXIStream Receive
  --
  --------------------------------------------------------
  procedure axistream_receive_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant msg              : in    string
    );
  procedure axistream_receive(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant msg              : in    string
    );


  --------------------------------------------------------
  --
  -- AXIStream Expect
  --
  --------------------------------------------------------

  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;
    constant strb_array       : in    t_strb_array;
    constant id_array         : in    t_id_array;
    constant dest_array       : in    t_dest_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;
    constant strb_array       : in    t_strb_array;
    constant id_array         : in    t_id_array;
    constant dest_array       : in    t_dest_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;
    constant strb_array       : in    t_strb_array;
    constant id_array         : in    t_id_array;
    constant dest_array       : in    t_dest_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );

  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );

  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );


end package vvc_methods_pkg;


package body vvc_methods_pkg is


  --========================================================================================================================
  -- Methods dedicated to this VVC
  --========================================================================================================================



  --------------------------------------------------------
  --
  -- AXIStream Transmit
  --
  --------------------------------------------------------

  -- These procedures will be used to forward commands to the VVC executor, which will
  -- call the corresponding BFM procedures.

  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_user_array
    constant strb_array       : in    t_strb_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_strb_array
    constant id_array         : in    t_id_array;    -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_id_array
    constant dest_array       : in    t_dest_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_dest_array
    constant msg              : in    string
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                   & ", " & to_string(data_array'length, 5) & " bytes)";
  begin
    -- DEPRECATE: data_array as t_byte_array will be removed in next major release
    deprecate(proc_name, "data_array as t_byte_array has been deprecated. Use data_array as t_slv_array.");

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, TRANSMIT);
    -- Sanity check to avoid confusing fatal error
    check_value(data_array'length > 0, TB_ERROR, proc_call & "data_array length must be > 0", "VVC");
    -- Generate cmd record
    shared_vvc_cmd.data_array(0 to data_array'high) := data_array;
    shared_vvc_cmd.user_array(0 to user_array'high) := user_array;
    shared_vvc_cmd.strb_array(0 to strb_array'high) := strb_array;
    shared_vvc_cmd.id_array(0 to id_array'high)     := id_array;
    shared_vvc_cmd.dest_array(0 to dest_array'high) := dest_array;
    shared_vvc_cmd.data_array_length                := data_array'length;
    shared_vvc_cmd.user_array_length                := user_array'length;
    shared_vvc_cmd.strb_array_length                := strb_array'length;
    shared_vvc_cmd.id_array_length                  := id_array'length;
    shared_vvc_cmd.dest_array_length                := dest_array'length;

    -- Send command record
    send_command_to_vvc(VVCT);
  end procedure;
  -- t_slv_array overload
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_user_array
    constant strb_array       : in    t_strb_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_strb_array
    constant id_array         : in    t_id_array;    -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_id_array
    constant dest_array       : in    t_dest_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_dest_array
    constant msg              : in    string
    ) is
    -- helper variables
    variable v_bytes_in_word    : integer := (data_array(0)'length/8);
    variable v_num_bytes        : integer := (data_array'length) * v_bytes_in_word;
    variable v_data_array       : t_byte_array(0 to v_num_bytes-1);
    variable v_data_array_idx   : integer := 0;
    variable v_check_ok         : boolean := false;
    variable v_byte_endianness  : t_byte_endianness := shared_axistream_vvc_config(vvc_instance_idx).bfm_config.byte_endianness;
  begin
    -- t_slv_array sanity check
    v_check_ok := check_value(data_array(0)'length mod 8 = 0, TB_ERROR, "Sanity check: Check that data_array word is N*byte");

    if v_check_ok then
      -- copy byte(s) from t_slv_array to t_byte_array
      v_data_array := convert_slv_array_to_byte_array(data_array, true, v_byte_endianness); -- data_array is ascending, data_array(0 to N)()
      -- call t_byte_array overloaded procedure
      axistream_transmit_bytes(VVCT, vvc_instance_idx, v_data_array, user_array, strb_array, id_array, dest_array, msg);
    end if;
  end procedure;
  -- std_logic_vector overload
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_user_array
    constant strb_array       : in    t_strb_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_strb_array
    constant id_array         : in    t_id_array;    -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_id_array
    constant dest_array       : in    t_dest_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_dest_array
    constant msg              : in    string
    ) is
    -- helper variables
    variable v_check_ok         : boolean := false;
    variable v_data_array       : t_slv_array(0 to 0)(data_array'length-1 downto 0);
  begin
    -- std_logic_vector sanity check
    v_check_ok := check_value(data_array'length mod 8 = 0, TB_ERROR, "Sanity check: Check that data_array word is N*byte");
    if v_check_ok then
      v_data_array(0) := data_array;
      axistream_transmit(VVCT, vvc_instance_idx, v_data_array, user_array, strb_array, id_array, dest_array, msg);
    end if;
  end procedure;

  -- Overload, without the strb_array, id_array, dest_array  arguments
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string
    ) is
    -- Default user data : We don't know c_user_array length (how many words to send), so assume worst case: tdata = 8 bits (one data_array byte per word)
    constant c_strb_array : t_strb_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
    constant c_id_array   : t_id_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1)   := (others => (others => '0'));
    constant c_dest_array : t_dest_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
  begin
    axistream_transmit_bytes(VVCT, vvc_instance_idx, data_array, user_array, c_strb_array, c_id_array, c_dest_array, msg);
  end procedure;
  -- t_slv_array overload
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string
    ) is
    -- Default user data : We don't know c_user_array length (how many words to send), so assume worst case: tdata = 8 bits (one data_array byte per word)
    constant c_strb_array : t_strb_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
    constant c_id_array   : t_id_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1)   := (others => (others => '0'));
    constant c_dest_array : t_dest_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
  begin
    axistream_transmit(VVCT, vvc_instance_idx, data_array, user_array, c_strb_array, c_id_array, c_dest_array, msg);
  end procedure;
  -- std_logic_vector overload
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;
    constant msg              : in    string
    ) is
    -- Default user data : We don't know c_user_array length (how many words to send), so assume worst case: tdata = 8 bits (one data_array byte per word)
    constant c_strb_array : t_strb_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
    constant c_id_array   : t_id_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1)   := (others => (others => '0'));
    constant c_dest_array : t_dest_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
  begin
    axistream_transmit(VVCT, vvc_instance_idx, data_array, user_array, c_strb_array, c_id_array, c_dest_array, msg);
  end procedure;


  -- Overload, without the user_array, strb_array, id_array, dest_array  arguments
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_transmit_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant msg              : in    string
    ) is
    -- Default user data : We don't know c_user_array length (how many words to send), so assume tdata = 8 bits (one data_array byte per word)
    constant c_user_array : t_user_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
  begin
    -- Use another overload to fill in the rest
    axistream_transmit_bytes(VVCT, vvc_instance_idx, data_array, c_user_array, msg);
  end procedure;
  -- t_slv_array overload
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant msg              : in    string
    ) is
    -- Default user data : We don't know c_user_array length (how many words to send), so assume tdata = 8 bits (one data_array byte per word)
    constant c_user_array : t_user_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
  begin
    -- Use another overload to fill in the rest
    axistream_transmit(VVCT, vvc_instance_idx, data_array, c_user_array, msg);
  end procedure;
  -- std_logic_vector overload
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant msg              : in    string
    ) is
    -- Default user data : We don't know c_user_array length (how many words to send), so assume tdata = 8 bits (one data_array byte per word)
    constant c_user_array : t_user_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
  begin
    -- Use another overload to fill in the rest
    axistream_transmit(VVCT, vvc_instance_idx, data_array, c_user_array, msg);
  end procedure;




  --------------------------------------------------------
  --
  -- AXIStream Receive
  --
  --------------------------------------------------------
  procedure axistream_receive_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant msg              : in    string
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "()";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, RECEIVE);
    send_command_to_vvc(VVCT);
  end procedure axistream_receive_bytes;
  -- Overloading procedure
  procedure axistream_receive(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant msg              : in    string
  ) is
  begin
    -- Call overloaded procedure
    axistream_receive_bytes(VVCT, vvc_instance_idx, msg);
  end procedure axistream_receive;


  --------------------------------------------------------
  --
  -- AXIStream Expect
  --
  --------------------------------------------------------

  -- Expect, receive and compare to specified data_array, user_array, strb_array, id_array, dest_array
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;
    constant strb_array       : in    t_strb_array;
    constant id_array         : in    t_id_array;
    constant dest_array       : in    t_dest_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                   & ", " & to_string(data_array'length) & "B)";
  begin
    -- DEPRECATE: data_array as t_byte_array will be removed in next major release
    deprecate(proc_name, "data_array as t_byte_array has been deprecated. Use data_array as t_slv_array.");

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, EXPECT);
    -- Generate cmd record
    shared_vvc_cmd.data_array(0 to data_array'high) := data_array;
    shared_vvc_cmd.user_array(0 to user_array'high) := user_array;  -- user_array Length = data_array_length
    shared_vvc_cmd.strb_array(0 to strb_array'high) := strb_array;
    shared_vvc_cmd.id_array(0 to id_array'high)     := id_array;
    shared_vvc_cmd.dest_array(0 to dest_array'high) := dest_array;
    shared_vvc_cmd.data_array_length                := data_array'length;
    shared_vvc_cmd.user_array_length                := user_array'length;
    shared_vvc_cmd.strb_array_length                := strb_array'length;
    shared_vvc_cmd.id_array_length                  := id_array'length;
    shared_vvc_cmd.dest_array_length                := dest_array'length;
    shared_vvc_cmd.alert_level := alert_level;
    send_command_to_vvc(VVCT);
  end procedure;
  -- t_slv_array overload
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;
    constant strb_array       : in    t_strb_array;
    constant id_array         : in    t_id_array;
    constant dest_array       : in    t_dest_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- helper variables
    variable v_bytes_in_word    : integer := (data_array(0)'length/8);
    variable v_num_bytes        : integer := (data_array'length) * v_bytes_in_word;
    variable v_data_array       : t_byte_array(0 to v_num_bytes-1);
    variable v_data_array_idx   : integer := 0;
    variable v_check_ok         : boolean := false;
    variable v_byte_endianness  : t_byte_endianness := shared_axistream_vvc_config(vvc_instance_idx).bfm_config.byte_endianness;
  begin
    -- t_slv_array sanity check
    v_check_ok := check_value(data_array(0)'length mod 8 = 0, TB_ERROR, "Sanity check: Check that data_array word is N*byte");

    if v_check_ok then
      -- copy byte(s) from t_slv_array to t_byte_array
      v_data_array := convert_slv_array_to_byte_array(data_array, true, v_byte_endianness); -- data_array is ascending, data_array(0 to N)()
      -- call t_byte_array overloaded procedure
      axistream_expect_bytes(VVCT, vvc_instance_idx, v_data_array, user_array, strb_array, id_array, dest_array, msg, alert_level);
    end if;
  end procedure;
  -- std_logic_vector overload
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;
    constant strb_array       : in    t_strb_array;
    constant id_array         : in    t_id_array;
    constant dest_array       : in    t_dest_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- helper variables
    variable v_data_array       : t_slv_array(0 to 0)(data_array'length-1 downto 0);
    variable v_check_ok         : boolean := false;
  begin
    -- std_logic_vector sanity check
    v_check_ok := check_value(data_array'length mod 8 = 0, TB_ERROR, "Sanity check: Check that data_array word is N*byte");
    if v_check_ok then
      v_data_array(0) := data_array;
      axistream_expect(VVCT, vvc_instance_idx, v_data_array, user_array, strb_array, id_array, dest_array, msg, alert_level);
    end if;
  end procedure;

  -- Overload for calling axiStreamExpect() without a value for strb_array, id_array, dest_array
  -- (will be set to don't care)
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- Default expected strb, id, dest
    -- Don't know #bytes in AXIStream tdata, so *_array length is unknown.
    -- Make the array as short as possible for best simulation time during the check performed in the BFM.
    constant c_strb_array : t_strb_array(0 downto 0) := (others => (others => '-'));
    constant c_id_array   : t_id_array(0 downto 0) := (others => (others => '-'));
    constant c_dest_array : t_dest_array(0 downto 0) := (others => (others => '-'));
  begin
    axistream_expect_bytes(VVCT, vvc_instance_idx, data_array, user_array, c_strb_array, c_id_array, c_dest_array, msg, alert_level);
  end procedure;
  -- t_slv_array overload
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- Default expected strb, id, dest
    -- Don't know #bytes in AXIStream tdata, so *_array length is unknown.
    -- Make the array as short as possible for best simulation time during the check performed in the BFM.
    constant c_strb_array : t_strb_array(0 downto 0) := (others => (others => '-'));
    constant c_id_array   : t_id_array(0 downto 0) := (others => (others => '-'));
    constant c_dest_array : t_dest_array(0 downto 0) := (others => (others => '-'));
  begin
    axistream_expect(VVCT, vvc_instance_idx, data_array, user_array, c_strb_array, c_id_array, c_dest_array, msg, alert_level);
  end procedure;
  -- std_logic_vector overload
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- Default expected strb, id, dest
    -- Don't know #bytes in AXIStream tdata, so *_array length is unknown.
    -- Make the array as short as possible for best simulation time during the check performed in the BFM.
    constant c_strb_array : t_strb_array(0 downto 0) := (others => (others => '-'));
    constant c_id_array   : t_id_array(0 downto 0) := (others => (others => '-'));
    constant c_dest_array : t_dest_array(0 downto 0) := (others => (others => '-'));
  begin
    axistream_expect(VVCT, vvc_instance_idx, data_array, user_array, c_strb_array, c_id_array, c_dest_array, msg, alert_level);
  end procedure;


  -- Overload, without the user_array, strb_array, id_array, dest_array  arguments
  -- DEPRECATE: procedure with data_array as t_byte_array will be removed in next major release
  procedure axistream_expect_bytes(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_byte_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- Default user data
    -- Don't know #bytes in AXIStream tdata, so user_array length is unknown.
    -- Make the array as short as possible for best simulation time during the check performed in the BFM.
    constant c_user_array : t_user_array(0 downto 0) := (others => (others => '-'));
  begin
    -- Use another overload to fill in the rest: strb_array, id_array, dest_array
    axistream_expect_bytes(VVCT, vvc_instance_idx, data_array, c_user_array, msg, alert_level);
  end procedure;
  -- t_slv_array overload
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- Default user data
    -- Don't know #bytes in AXIStream tdata, so user_array length is unknown.
    -- Make the array as short as possible for best simulation time during the check performed in the BFM.
    constant c_user_array : t_user_array(0 downto 0) := (others => (others => '-'));
  begin
    -- Use another overload to fill in the rest: strb_array, id_array, dest_array
    axistream_expect(VVCT, vvc_instance_idx, data_array, c_user_array, msg, alert_level);
  end procedure;
  -- std_logic_vector overload
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    std_logic_vector;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    -- Default user data
    -- Don't know #bytes in AXIStream tdata, so user_array length is unknown.
    -- Make the array as short as possible for best simulation time during the check performed in the BFM.
    constant c_user_array : t_user_array(0 downto 0) := (others => (others => '-'));
  begin
    -- Use another overload to fill in the rest: strb_array, id_array, dest_array
    axistream_expect(VVCT, vvc_instance_idx, data_array, c_user_array, msg, alert_level);
  end procedure;


end package body vvc_methods_pkg;
