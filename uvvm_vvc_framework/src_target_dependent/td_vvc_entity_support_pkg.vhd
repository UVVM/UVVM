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

use work.td_queue_pkg.all;
use work.vvc_cmd_pkg.all;
use work.vvc_methods_pkg.all;
use work.td_vvc_framework_common_methods_pkg.all;
use work.td_target_support_pkg.all;

--=================================================================================================
--=================================================================================================
--=================================================================================================
package td_vvc_entity_support_pkg is

  type t_vvc_labels is record
    scope        : string(1 to C_LOG_SCOPE_WIDTH);
    vvc_name     : string(1 to C_LOG_SCOPE_WIDTH-2);
    instance_idx : natural;
    channel      : t_channel;
  end record;

  type t_executor_result is record
    cmd_idx       : natural;   -- from UVVM handshake mechanism
    data          : std_logic_vector(C_MAX_VVC_RESPONSE_DATA_WIDTH-1 downto 0);
    value_is_new  : boolean;   -- turn true/false for put/fetch
  end record;

  type t_executor_result_array is array (0 to C_VVC_RESULT_DEFAULT_ARRAY_DEPTH) of t_executor_result;
  type t_shared_vvc_results is array (natural range <>) of t_executor_result_array;
  shared variable shared_vvc_result : t_shared_vvc_results(0 to C_MAX_VVC_INSTANCE_NUM);

  -------------------------------------------
  -- assign_vvc_labels
  -------------------------------------------
  -- This function puts common VVC labels into a record - to reduce the number of procedure parameters
  function assign_vvc_labels(
    scope        : string;
    vvc_name     : string;
    instance_idx : integer;
    channel      : t_channel
    ) return t_vvc_labels;


  -------------------------------------------
  -- format_msg
  -------------------------------------------
  -- Generates a sting containing the command message and index
  -- - Format: Message [index]
  impure function format_msg(
      command    : t_vvc_cmd_record
    ) return string;


  -------------------------------------------
  -- vvc_constructor
  -------------------------------------------
  -- Procedure used as concurrent process in the VVCs
  -- - Sets up the vvc_config and command queue
  -- - Verifies that UVVM has been initialized
  procedure vvc_constructor(
    constant scope                                : in string;
    constant instance_idx                         : in natural;
    variable vvc_config                           : inout t_vvc_config;
    variable command_queue                        : inout t_generic_queue;
    constant bfm_config                           : in t_bfm_config;
    constant cmd_queue_count_max                  : in natural;
    constant cmd_queue_count_threshold            : in natural;
    constant cmd_queue_count_threshold_severity   : in t_alert_level
    );


  -------------------------------------------
  -- initialize_interpreter
  -------------------------------------------
  -- Initialises the VVC interpreter
  -- - Clears terminate_current_cmd.set to '0'
  procedure initialize_interpreter (
    signal terminate_current_cmd  : out t_flag_record
    );


  -------------------------------------------
  -- await_cmd_from_sequencer
  -------------------------------------------
  -- Waits for a command from the central sequencer. Continues on matching VVC, Instance, Name and Channel (unless channel = NA)
  -- - Log at start using ID_CMD_INTERPRETER_WAIT and at the end using ID_CMD_INTERPRETER
  procedure await_cmd_from_sequencer(
    constant vvc_labels       : in t_vvc_labels;
    constant vvc_config       : in t_vvc_config;
    signal VVCT               : in t_vvc_target_record;
    signal VVC_BROADCAST      : in std_logic;
    signal global_vvc_ack     : out std_logic;
    constant shared_vvc_cmd   : in t_vvc_cmd_record
    );


  -------------------------------------------
  -- put_command_on_queue
  -------------------------------------------
  -- Puts the received command (by Interpreter) on the VVC queue (for later retrieval by Executor)
  procedure put_command_on_queue(
    constant command             : in t_vvc_cmd_record;
    variable command_queue       : inout t_generic_queue;
    variable vvc_status          : inout t_vvc_status;
    signal   queue_is_increasing : out   boolean
    );


  -------------------------------------------
  -- interpreter_await_completion
  -------------------------------------------
  -- Immediate command: await_completion (in interpreter)
  -- - Command description in Quick reference for UVVM common methods
  -- - Will wait until given command(s) is completed by the excutor (if not already completed)
  -- - Log using ID_IMMEDIATE_CMD when await completed
  -- - Log using ID_IMMEDIATE_CMD_WAIT if waiting is actually needed
  procedure interpreter_await_completion(
    constant command              : in t_vvc_cmd_record;
    variable command_queue        : inout t_generic_queue;
    constant vvc_config           : in t_vvc_config;
    signal executor_is_busy       : in boolean;
    constant vvc_labels           : in t_vvc_labels;
    signal last_cmd_idx_executed  : in natural;
    constant await_completion_pending_msg_id      : in t_msg_id := ID_IMMEDIATE_CMD_WAIT;
    constant await_completion_finished_msg_id     : in t_msg_id := ID_IMMEDIATE_CMD
    );


  -------------------------------------------
  -- interpreter_flush_command_queue
  -------------------------------------------
  -- Immediate command: flush_command_queue (in interpreter)
  -- - Command description in Quick reference for UVVM common methods
  -- - Log using ID_IMMEDIATE_CMD
  procedure interpreter_flush_command_queue(
    constant command            : in t_vvc_cmd_record;
    variable command_queue      : inout    t_generic_queue;
    constant vvc_config         : in t_vvc_config;
    variable vvc_status         : inout t_vvc_status;
    constant vvc_labels         : in t_vvc_labels
    );


  -------------------------------------------
  -- interpreter_terminate_current_command
  -------------------------------------------
  -- Immediate command: terminate_current_command (in interpreter)
  -- - Command description in Quick reference for UVVM common methods
  -- - Log using ID_IMMEDIATE_CMD
  procedure interpreter_terminate_current_command(
    constant command              : in t_vvc_cmd_record;
    constant vvc_config           : in t_vvc_config;
    constant vvc_labels           : in t_vvc_labels;
    signal terminate_current_cmd  : inout t_flag_record
    );


  -------------------------------------------
  -- interpreter_fetch_result
  -------------------------------------------
  -- Immediate command: interpreter_fetch_result (in interpreter)
  -- - Command description in Quick reference for UVVM common methods
  -- - Log using ID_IMMEDIATE_CMD
  procedure interpreter_fetch_result(
    constant instance_idx           : in natural;
    constant command                : in t_vvc_cmd_record;
    constant vvc_config             : in t_vvc_config;
    constant vvc_labels             : in t_vvc_labels;
    constant data_width             : in natural;
    constant last_cmd_idx_executed  : in natural;
    variable shared_vvc_response    : inout t_vvc_response
    );


  -------------------------------------------
  -- initialize_executor
  -------------------------------------------
  -- Initialises the VVC executor
  -- - Resets terminate_current_cmd.reset flag
  procedure initialize_executor (
    signal terminate_current_cmd  : inout t_flag_record
    );


  -------------------------------------------
  -- fetch_command_and_prepare_executor
  -------------------------------------------
  -- Fetches a command from the queue (waits until available if needed)
  -- - Log command using ID_CMD_EXECUTOR
  -- - Log using ID_CMD_EXECUTOR_WAIT if queue is empty
  -- - Sets relevant flags
  procedure fetch_command_and_prepare_executor(
    variable command              : inout t_vvc_cmd_record;
    variable command_queue        : inout t_generic_queue;
    constant vvc_config           : in t_vvc_config;
    variable vvc_status           : inout t_vvc_status;
    signal queue_is_increasing    : in boolean;
    signal executor_is_busy       : inout boolean;
    constant vvc_labels           : in t_vvc_labels
    );

    
  -------------------------------------------
  -- store_result
  -------------------------------------------
  -- Stores data 'data' and 'cmd_idx' in an array 'shared_vvc_result' 
  -- under index 'instance_idx'. Each index has a variable 'value_is_new', 
  -- which is set true when data is stored.
  procedure store_result(
    constant instance_idx : in natural;
    constant cmd_idx      : in natural;
    constant data         : in std_logic_vector
    );


  -------------------------------------------
  -- insert_inter_bfm_delay_if_requested
  -------------------------------------------
  -- Inserts delay of either START2START or FINISH2START in time, given that
  -- - vvc_config inter-bfm delay type is not set to NO_DELAY
  -- - command_is_bfm_access is set to true
  -- - Both timestamps are not set to 0 ns.
  -- A log message with ID ID_CMD_EXECUTOR is issued when the delay begins and 
  -- when it has finished delaying.
  procedure insert_inter_bfm_delay_if_requested(
    constant vvc_config                           : in t_vvc_config;
    constant command_is_bfm_access                : in boolean;
    constant timestamp_start_of_last_bfm_access   : in time;
    constant timestamp_end_of_last_bfm_access     : in time;
    constant scope                                : in string := C_SCOPE
  );

end package td_vvc_entity_support_pkg;



package body td_vvc_entity_support_pkg is


  function assign_vvc_labels(
    scope        : string;
    vvc_name     : string;
    instance_idx : integer;
    channel      : t_channel
    ) return t_vvc_labels is
    variable vvc_labels : t_vvc_labels;
  begin
    vvc_labels.scope        := pad_string(scope, NUL, vvc_labels.scope'length);
    vvc_labels.vvc_name     := pad_string(vvc_name, NUL, vvc_labels.vvc_name'length);
    vvc_labels.instance_idx := instance_idx;
    vvc_labels.channel      := channel;
    return vvc_labels;
  end;

  
  impure function format_msg(
      command    : t_vvc_cmd_record
    ) return string is
  begin
    return to_string(command.msg) & " " & format_command_idx(command);
  end;

  
  procedure vvc_constructor(
    constant scope                              : in string;
    constant instance_idx                       : in natural;
    variable vvc_config                         : inout t_vvc_config;
    variable command_queue                      : inout t_generic_queue;
    constant bfm_config                         : in t_bfm_config;
    constant cmd_queue_count_max                : in natural;
    constant cmd_queue_count_threshold          : in natural;
    constant cmd_queue_count_threshold_severity : in t_alert_level
  ) is
    variable v_delta_cycle_counter : natural := 0;
  begin

    check_value(instance_idx <= C_MAX_VVC_INSTANCE_NUM, TB_FAILURE, "Generic VVC Instance index =" & to_string(instance_idx) &
                " cannot exceed C_MAX_VVC_INSTANCE_NUM in UVVM adaptations = " & to_string(C_MAX_VVC_INSTANCE_NUM), scope, ID_NEVER);
    vvc_config.bfm_config :=  bfm_config;
    vvc_config.cmd_queue_count_max := cmd_queue_count_max;
    vvc_config.cmd_queue_count_threshold := cmd_queue_count_threshold;
    vvc_config.cmd_queue_count_threshold_severity := cmd_queue_count_threshold_severity;

    log(ID_CONSTRUCTOR, "VVC instantiated.", scope, vvc_config.msg_id_panel);
    command_queue.set_scope(scope & ":Q");
    command_queue.set_queue_count_max(vvc_config.cmd_queue_count_max);
    command_queue.set_queue_count_threshold(vvc_config.cmd_queue_count_threshold);
    command_queue.set_queue_count_threshold_severity(vvc_config.cmd_queue_count_threshold_severity);
    log(ID_CONSTRUCTOR_SUB, "Command queue instantiated with size " & to_string(command_queue.get_queue_count_max(VOID)), command_queue.get_scope(VOID), vvc_config.msg_id_panel);

    if shared_uvvm_state /= PHASE_A then
      loop
        wait for 0 ns;
        v_delta_cycle_counter := v_delta_cycle_counter + 1;
        exit when shared_uvvm_state = PHASE_A;
        check_value((shared_uvvm_state /= IDLE), TB_FAILURE, "UVVM will not work without intitalize_uvvm instantiated as a concurrent procedure in the test harness", scope);
      end loop;
    end if;

    wait;  -- show message only once per VVC instance
   end procedure;


  procedure initialize_interpreter (
    signal terminate_current_cmd  : out t_flag_record
    ) is
  begin
    terminate_current_cmd  <= (set => '0', reset => 'Z', is_active => 'Z');  -- Initialise to avoid undefineds. This process is driving param 1 only.
    wait for 0 ns;  -- delay by 1 delta cycle to allow constructor to finish first
   end procedure;


  procedure await_cmd_from_sequencer(
    constant vvc_labels       : in t_vvc_labels;
    constant vvc_config       : in t_vvc_config;
    signal VVCT               : in t_vvc_target_record;
    signal VVC_BROADCAST      : in std_logic;
    signal global_vvc_ack     : out std_logic;
    constant shared_vvc_cmd   : in t_vvc_cmd_record
    ) is
  begin
    global_vvc_ack <= 'Z';  -- Do not contribute to the acknowledge unless selected

    -- Wait for a new command
    log(ID_CMD_INTERPRETER_WAIT, "Interpreter: Waiting for command", to_string(vvc_labels.scope) , vvc_config.msg_id_panel);

    loop
      wait until VVCT.trigger = '1';
      
      -- Check that the channel is valid
      if (VVCT.vvc_instance_idx = vvc_labels.instance_idx and
          VVCT.vvc_name(1 to valid_length(vvc_labels.vvc_name)) = vvc_labels.vvc_name(1 to valid_length(vvc_labels.vvc_name))) then
        if (VVCT.vvc_channel = NA and (vvc_labels.channel = TX or vvc_labels.channel = RX)) or (vvc_labels.channel = NA and (VVCT.vvc_channel = TX or VVCT.vvc_channel = RX)) then
            tb_warning(to_string(shared_vvc_cmd.proc_call) & " Channel "& to_string(VVCT.vvc_channel) & " not supported on this VVC " & format_command_idx(shared_vvc_cmd), to_string(vvc_labels.scope));
        end if;
      end if;

      exit when VVCT.vvc_instance_idx = vvc_labels.instance_idx
            and ((VVCT.vvc_channel = ALL_CHANNELS) or (VVCT.vvc_channel = vvc_labels.channel)) -- Implement broadcast for both channels, VVCT.vvc_channel = ALL_CHANNELS
            and VVCT.vvc_name(1 to valid_length(vvc_labels.vvc_name)) = vvc_labels.vvc_name(1 to valid_length(vvc_labels.vvc_name));
    end loop;

    global_vvc_ack <= '0';  -- Set ACK to 0 to enforce X if multiple VVCs are receiving the command

    log(ID_CMD_INTERPRETER, to_string(shared_vvc_cmd.proc_call) & ". Command received " & format_command_idx(shared_vvc_cmd), vvc_labels.scope, vvc_config.msg_id_panel);    -- Get and ack the new command
  end procedure;


  procedure put_command_on_queue(
    constant command              : in t_vvc_cmd_record;
    variable command_queue        : inout t_generic_queue;
    variable vvc_status           : inout t_vvc_status;
    signal   queue_is_increasing  : out   boolean
    ) is
  begin
    command_queue.put(command);
    vvc_status.pending_cmd_cnt := command_queue.get_count(VOID);
    queue_is_increasing <= true;
    wait for 0 ns;
    queue_is_increasing <= false;
  end procedure;

  
  procedure interpreter_await_completion(
    constant command              : in t_vvc_cmd_record;
    variable command_queue        : inout    t_generic_queue;
    constant vvc_config           : in t_vvc_config;
    signal executor_is_busy       : in boolean;
    constant vvc_labels           : in t_vvc_labels;
    signal last_cmd_idx_executed  : in natural;
    constant await_completion_pending_msg_id      : in t_msg_id := ID_IMMEDIATE_CMD_WAIT;
    constant await_completion_finished_msg_id     : in t_msg_id := ID_IMMEDIATE_CMD
    ) is
  begin
    if command.gen_integer = -1 then
      -- await completion of all commands
      if command_queue.is_not_empty(VOID) or executor_is_busy then
        log(await_completion_pending_msg_id, "await_completion() - Pending completion " & to_string(command.msg) & " " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command
        loop
          wait until (executor_is_busy = false);
          if command_queue.is_empty(VOID) then
            exit;
          end if;
        end loop;
      end if;
      log(await_completion_finished_msg_id, "await_completion()  => Finished. " & to_string(command.msg) & " " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command

    else -- await specific instruction
      if last_cmd_idx_executed < command.gen_integer then
        log(await_completion_pending_msg_id, "await_completion(" & to_string(command.gen_integer) & ") - Pending selected " & to_string(command.msg) & " "  & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command
        loop
          wait until executor_is_busy = false;
          if last_cmd_idx_executed >= command.gen_integer then
            exit;
          end if;
        end loop;
      end if;
      log(await_completion_finished_msg_id, "await_completion(" & to_string(command.gen_integer) & ") => Finished. " & to_string(command.msg) & " " &  format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel); -- Get & ack the new command
    end if;
  end procedure;


  procedure interpreter_flush_command_queue(
    constant command            : in t_vvc_cmd_record;
    variable command_queue      : inout t_generic_queue;
    constant vvc_config         : in t_vvc_config;
    variable vvc_status         : inout t_vvc_status;
    constant vvc_labels         : in t_vvc_labels
    ) is
  begin
    log(ID_IMMEDIATE_CMD, "Flushing command queue (" & to_string(shared_vvc_cmd.gen_integer) & ") " & format_command_idx(shared_vvc_cmd), to_string(vvc_labels.scope), vvc_config.msg_id_panel);
    command_queue.flush(VOID);
    vvc_status.pending_cmd_cnt := command_queue.get_count(VOID);
  end;


  procedure interpreter_terminate_current_command(
    constant command              : in t_vvc_cmd_record;
    constant vvc_config           : in t_vvc_config;
    constant vvc_labels           : in t_vvc_labels;
    signal terminate_current_cmd  : inout t_flag_record
    ) is
  begin
    log(ID_IMMEDIATE_CMD, "Terminating command in executor", to_string(vvc_labels.scope), vvc_config.msg_id_panel);
    set_flag(terminate_current_cmd);
  end procedure;


  procedure interpreter_fetch_result(
    constant instance_idx           : in natural;
    constant command                : in t_vvc_cmd_record;
    constant vvc_config             : in t_vvc_config;
    constant vvc_labels             : in t_vvc_labels;
    constant data_width             : in natural;
    constant last_cmd_idx_executed  : in natural;
    variable shared_vvc_response           : inout t_vvc_response
    ) is
    variable result_array : t_executor_result_array := shared_vvc_result(instance_idx);
  begin
    shared_vvc_response.fetch_is_accepted := false;  -- default
    if last_cmd_idx_executed < command.gen_integer then
      tb_warning(to_string(command.proc_call) & ". Requested result is not yet available. " & format_command_idx(command), to_string(vvc_labels.scope));
    else
      for i in result_array'range loop
        if result_array(i).cmd_idx = command.gen_integer then
          -- found requested command
          shared_vvc_response.fetch_is_accepted := true;
          shared_vvc_response.data(data_width - 1 downto 0) := result_array(i).data(data_width - 1 downto 0);
          shared_vvc_response.value_is_new := result_array(i).value_is_new;
          shared_vvc_result(instance_idx)(i).value_is_new := false;
          log(ID_IMMEDIATE_CMD, to_string(command.proc_call) & " Requested result is found" & ". " & to_string(command.msg) & " " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel); -- Get and ack the new command
          exit;
        end if;
      end loop;
      if  not shared_vvc_response.fetch_is_accepted then
        tb_warning(to_string(command.proc_call) & ". Requested result was not found. Given command index is not available in this VVC. " & format_command_idx(command), to_string(vvc_labels.scope));
      end if;
    end if;
  end procedure;


  procedure initialize_executor (
    signal terminate_current_cmd  : inout t_flag_record
    ) is
  begin
    reset_flag(terminate_current_cmd);
    wait for 0 ns;  -- delay by 1 delta cycle to allow constructor to finish first
   end procedure;


  procedure fetch_command_and_prepare_executor(
    variable command              : inout t_vvc_cmd_record;
    variable command_queue        : inout t_generic_queue;
    constant vvc_config           : in t_vvc_config;
    variable vvc_status           : inout t_vvc_status;
    signal   queue_is_increasing  : in boolean;
    signal executor_is_busy       : inout boolean;
    constant vvc_labels           : in t_vvc_labels
    ) is
  begin
    executor_is_busy  <= false;
    wait for 0 ns;  -- to allow delta updates in other processes.
    if command_queue.is_empty(VOID) then
      log(ID_CMD_EXECUTOR_WAIT, "Executor: Waiting for command", to_string(vvc_labels.scope), vvc_config.msg_id_panel);
      wait until queue_is_increasing;
    end if;

    -- Queue is now not empty
    executor_is_busy  <= true;
    wait until executor_is_busy;
    vvc_status.previous_cmd_idx := command.cmd_idx;
    command := command_queue.get(VOID);
    log(ID_CMD_EXECUTOR, to_string(command.proc_call) & " - Will be executed " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command
    vvc_status.pending_cmd_cnt := command_queue.get_count(VOID);
    vvc_status.current_cmd_idx := command.cmd_idx;
  end procedure;


  type t_store_results_indexes is array (0 to C_MAX_VVC_INSTANCE_NUM) of natural;
  shared variable store_results_indexes : t_store_results_indexes := (others => 0);


  procedure store_result(
    constant instance_idx : in natural;
    constant cmd_idx      : in natural;
    constant data         : in std_logic_vector
    ) is
  variable results_index : natural := store_results_indexes(instance_idx);
  begin
      shared_vvc_result(instance_idx)(results_index).cmd_idx                      := cmd_idx;
      shared_vvc_result(instance_idx)(results_index).data(data'length-1 downto 0) := data;
      shared_vvc_result(instance_idx)(results_index).value_is_new                 := true;
      store_results_indexes(instance_idx) := (results_index + 1) mod C_VVC_RESULT_DEFAULT_ARRAY_DEPTH;
  end procedure;


  procedure insert_inter_bfm_delay_if_requested(
    constant vvc_config                           : in t_vvc_config;
    constant command_is_bfm_access                : in boolean;
    constant timestamp_start_of_last_bfm_access   : in time;
    constant timestamp_end_of_last_bfm_access     : in time;
    constant scope                                : in string := C_SCOPE
  ) is
  begin
    -- If both timestamps are at 0 ns we interpret this as the first BFM access, hence no delay shall be applied.
    if ((vvc_config.inter_bfm_delay.delay_type /= NO_DELAY) and 
         command_is_bfm_access and 
         not ((timestamp_start_of_last_bfm_access = 0 ns) and (timestamp_end_of_last_bfm_access = 0 ns))) then
      case vvc_config.inter_bfm_delay.delay_type is
        when TIME_FINISH2START =>
          if now < (timestamp_end_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time) then
            log(ID_CMD_EXECUTOR, "Delaying BFM access until time " & to_string(timestamp_end_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time) 
                & ".", scope, vvc_config.msg_id_panel);
            wait for (timestamp_end_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time - now);
          end if;
        when TIME_START2START =>
          if now < (timestamp_start_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time) then
            log(ID_CMD_EXECUTOR, "Delaying BFM access until time " & to_string(timestamp_start_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time) 
                & ".", scope, vvc_config.msg_id_panel);
            wait for (timestamp_start_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time - now);
          end if;
        when others =>
          tb_error("Delay type " & to_upper(to_string(vvc_config.inter_bfm_delay.delay_type)) & " not supported for this VVC.", C_SCOPE);
      end case;
      log(ID_CMD_EXECUTOR, "Finished delaying BFM access", scope, vvc_config.msg_id_panel);
    end if;
  end procedure;

end package body td_vvc_entity_support_pkg;


