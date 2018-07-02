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

use work.td_cmd_queue_pkg.all;
use work.td_result_queue_pkg.all;
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
  -- - Sets up the vvc_config, command queue and result_queue
  -- - Verifies that UVVM has been initialized
  procedure vvc_constructor(
    constant scope                                 : in string;
    constant instance_idx                          : in natural;
    variable vvc_config                            : inout t_vvc_config;
    variable command_queue                         : inout work.td_cmd_queue_pkg.t_generic_queue;
    variable result_queue                          : inout work.td_result_queue_pkg.t_generic_queue;
    constant bfm_config                            : in t_bfm_config;
    constant cmd_queue_count_max                   : in natural;
    constant cmd_queue_count_threshold             : in natural;
    constant cmd_queue_count_threshold_severity    : in t_alert_level;
    constant result_queue_count_max                : in natural;
    constant result_queue_count_threshold          : in natural;
    constant result_queue_count_threshold_severity : in t_alert_level
  );

  -------------------------------------------
  -- initialize_interpreter
  -------------------------------------------
  -- Initialises the VVC interpreter
  -- - Clears terminate_current_cmd.set to '0'
  procedure initialize_interpreter (
    signal terminate_current_cmd      : out t_flag_record;
    signal global_awaiting_completion : out std_logic_vector(C_MAX_NUM_SEQUENCERS-1 downto 0)
    );


  -------------------------------------------
  -- await_cmd_from_sequencer
  -------------------------------------------
  -- Waits for a command from the central sequencer. Continues on matching VVC, Instance, Name and Channel (unless channel = NA)
  -- - Log at start using ID_CMD_INTERPRETER_WAIT and at the end using ID_CMD_INTERPRETER
  procedure await_cmd_from_sequencer(
    constant vvc_labels        : in t_vvc_labels;
    constant vvc_config        : in t_vvc_config;
    signal VVCT                : in t_vvc_target_record;
    signal VVC_BROADCAST       : inout std_logic;
    signal global_vvc_busy : inout std_logic;
    signal vvc_ack             : out std_logic;
    constant shared_vvc_cmd    : in t_vvc_cmd_record;
    variable output_vvc_cmd    : out t_vvc_cmd_record
    );


  -------------------------------------------
  -- put_command_on_queue
  -------------------------------------------
  -- Puts the received command (by Interpreter) on the VVC queue (for later retrieval by Executor)
  procedure put_command_on_queue(
    constant command             : in t_vvc_cmd_record;
    variable command_queue       : inout work.td_cmd_queue_pkg.t_generic_queue;
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
    constant command                              : in t_vvc_cmd_record;
    variable command_queue                        : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config                           : in t_vvc_config;
    signal executor_is_busy                       : in boolean;
    constant vvc_labels                           : in t_vvc_labels;
    signal last_cmd_idx_executed                  : in natural;
    constant await_completion_pending_msg_id      : in t_msg_id := ID_IMMEDIATE_CMD_WAIT;
    constant await_completion_finished_msg_id     : in t_msg_id := ID_IMMEDIATE_CMD
    );

  -------------------------------------------
  -- interpreter_await_any_completion
  -------------------------------------------
  -- Immediate command: await_any_completion() (in interpreter)
  -- - This procedure is called by the interpreter if sequencer calls await_any_completion()
  --    - It waits for the first of the following :
  --      'await_completion' of this VVC, or
  --      until global_awaiting_completion(idx) /= '1' (any of the other involved VVCs completed).
  -- - Refer to description in Quick reference for UVVM common methods
  -- - Log using ID_IMMEDIATE_CMD when the wait completed
  -- - Log using ID_IMMEDIATE_CMD_WAIT if waiting is actually needed
  procedure interpreter_await_any_completion(
    constant command                              : in t_vvc_cmd_record;
    variable command_queue                        : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config                           : in t_vvc_config;
    signal executor_is_busy                       : in boolean;
    constant vvc_labels                           : in t_vvc_labels;
    signal last_cmd_idx_executed                  : in natural;
    signal global_awaiting_completion             : inout std_logic_vector; -- Handshake with other VVCs performing await_any_completion
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
    variable command_queue      : inout work.td_cmd_queue_pkg.t_generic_queue;
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
  -- t_vvc_response is specific to each VVC,
  -- so the BFM can return any type which is then transported from the VVC to the sequencer via a fetch_result() call
  procedure interpreter_fetch_result(
    variable result_queue           : inout work.td_result_queue_pkg.t_generic_queue;
    constant command                : in t_vvc_cmd_record;
    constant vvc_config             : in t_vvc_config;
    constant vvc_labels             : in t_vvc_labels;
    constant last_cmd_idx_executed  : in natural;
    variable shared_vvc_response    : inout work.vvc_cmd_pkg.t_vvc_response
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
    variable command_queue        : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config           : in t_vvc_config;
    variable vvc_status           : inout t_vvc_status;
    signal queue_is_increasing    : in boolean;
    signal executor_is_busy       : inout boolean;
    constant vvc_labels           : in t_vvc_labels
    );


  -------------------------------------------
  -- store_result
  -------------------------------------------
  -- Store result from BFM in the VVC's result_queue
  -- The result_queue is used to store a generic type that is returned from
  -- a read/expect BFM procedure.
  -- It can be fetched later using fetch_result() to return it from the VVC to sequencer
  procedure store_result(
    variable result_queue  : inout work.td_result_queue_pkg.t_generic_queue;
    constant cmd_idx       : in natural;
    constant result          : in t_vvc_result
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


  function broadcast_cmd_to_shared_cmd (
    constant broadcast_cmd : t_broadcastable_cmd
  ) return t_operation;

  function get_command_type_from_operation (
    constant broadcast_cmd : t_broadcastable_cmd
  ) return t_immediate_or_queued;


  procedure populate_shared_vvc_cmd_with_broadcast (
    variable output_vvc_cmd   : out t_vvc_cmd_record
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
    return add_msg_delimiter(to_string(command.msg)) & " " & format_command_idx(command);
  end;

  procedure vvc_constructor(
    constant scope                                 : in string;
    constant instance_idx                          : in natural;
    variable vvc_config                            : inout t_vvc_config;
    variable command_queue                         : inout work.td_cmd_queue_pkg.t_generic_queue;
    variable result_queue                          : inout work.td_result_queue_pkg.t_generic_queue;
    constant bfm_config                            : in t_bfm_config;
    constant cmd_queue_count_max                   : in natural;
    constant cmd_queue_count_threshold             : in natural;
    constant cmd_queue_count_threshold_severity    : in t_alert_level;
    constant result_queue_count_max                : in natural;
    constant result_queue_count_threshold          : in natural;
    constant result_queue_count_threshold_severity : in t_alert_level
  ) is
    variable v_delta_cycle_counter  : natural := 0;
    variable v_comma_number     : natural := 0;
  begin
    check_value(instance_idx <= C_MAX_VVC_INSTANCE_NUM, TB_FAILURE, "Generic VVC Instance index =" & to_string(instance_idx) &
                " cannot exceed C_MAX_VVC_INSTANCE_NUM in UVVM adaptations = " & to_string(C_MAX_VVC_INSTANCE_NUM), C_SCOPE, ID_NEVER);
    vvc_config.bfm_config :=  bfm_config;
    vvc_config.cmd_queue_count_max := cmd_queue_count_max;
    vvc_config.cmd_queue_count_threshold := cmd_queue_count_threshold;
    vvc_config.cmd_queue_count_threshold_severity := cmd_queue_count_threshold_severity;
    vvc_config.result_queue_count_max := result_queue_count_max;
    vvc_config.result_queue_count_threshold := result_queue_count_threshold;
    vvc_config.result_queue_count_threshold_severity := result_queue_count_threshold_severity;

    -- compose log message based on the number of channels in scope string
    if pos_of_leftmost(',', scope, 1) = pos_of_rightmost(',', scope, 1) then
      log(ID_CONSTRUCTOR, "VVC instantiated.", scope, vvc_config.msg_id_panel);
    else
      for idx in scope'range loop
        if (scope(idx) = ',') and (v_comma_number < 2) then -- locate 2nd comma in string
          v_comma_number := v_comma_number + 1;
        end if;
        if v_comma_number = 2 then -- rest of string is channel name
          log(ID_CONSTRUCTOR, "VVC instantiated for channel " & scope((idx+1) to scope'length) , scope, vvc_config.msg_id_panel);
          exit;
        end if;
      end loop;
    end if;
    command_queue.set_scope(scope);
    command_queue.set_name("cmd_queue");
    command_queue.set_queue_count_max(cmd_queue_count_max);
    command_queue.set_queue_count_threshold(cmd_queue_count_threshold);
    command_queue.set_queue_count_threshold_severity(cmd_queue_count_threshold_severity);
    log(ID_CONSTRUCTOR_SUB, "Command queue instantiated and will give a warning when reaching " & to_string(command_queue.get_queue_count_max(VOID))
                            & " elements in queue.", scope, vvc_config.msg_id_panel);

    result_queue.set_scope(scope);
    result_queue.set_name("result_queue");
    result_queue.set_queue_count_max(result_queue_count_max);
    result_queue.set_queue_count_threshold(result_queue_count_threshold);
    result_queue.set_queue_count_threshold_severity(result_queue_count_threshold_severity);
    log(ID_CONSTRUCTOR_SUB, "Result queue instantiated and will give a warning when reaching " & to_string(result_queue.get_queue_count_max(VOID))
                            & " elements in queue.", scope, vvc_config.msg_id_panel);


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
    signal terminate_current_cmd      : out t_flag_record;
    signal global_awaiting_completion : out std_logic_vector(C_MAX_NUM_SEQUENCERS-1 downto 0)
    ) is
  begin
    terminate_current_cmd  <= (set => '0', reset => 'Z', is_active => 'Z');  -- Initialise to avoid undefineds. This process is driving param 1 only.
    wait for 0 ns;  -- delay by 1 delta cycle to allow constructor to finish first

    global_awaiting_completion <= (others => 'Z'); -- Avoid driving until the VVC is involved in await_any_completion()
   end procedure;

  function broadcast_cmd_to_shared_cmd (
    constant broadcast_cmd : t_broadcastable_cmd
  ) return t_operation is
  begin
    case broadcast_cmd is
      when AWAIT_COMPLETION          => return AWAIT_COMPLETION;
      when ENABLE_LOG_MSG            => return ENABLE_LOG_MSG;
      when DISABLE_LOG_MSG           => return DISABLE_LOG_MSG;
      when FLUSH_COMMAND_QUEUE       => return FLUSH_COMMAND_QUEUE;
      when INSERT_DELAY              => return INSERT_DELAY;
      when TERMINATE_CURRENT_COMMAND => return TERMINATE_CURRENT_COMMAND;
      when others                    => return NO_OPERATION;
    end case;
  end function;


  function get_command_type_from_operation (
    constant broadcast_cmd : t_broadcastable_cmd
  ) return t_immediate_or_queued is
  begin
    case broadcast_cmd is
      when AWAIT_COMPLETION           => return IMMEDIATE;
      when ENABLE_LOG_MSG             => return IMMEDIATE;
      when DISABLE_LOG_MSG            => return IMMEDIATE;
      when FLUSH_COMMAND_QUEUE        => return IMMEDIATE;
      when TERMINATE_CURRENT_COMMAND  => return IMMEDIATE;
      when INSERT_DELAY               => return QUEUED;
      when others                     => return NO_command_type;
    end case;
  end function;

  procedure populate_shared_vvc_cmd_with_broadcast (
    variable output_vvc_cmd   : out t_vvc_cmd_record
  ) is
  begin

    -- Increment the shared command index. This is normally done in the CDM, but for broadcast commands it is done by the VVC itself.
    check_value((shared_uvvm_state /= IDLE), TB_FAILURE, "UVVM will not work without uvvm_vvc_framework.ti_uvvm_engine instantiated in the test harness", C_SCOPE, ID_NEVER);
    await_semaphore_in_delta_cycles(protected_broadcast_semaphore);
    shared_cmd_idx := shared_cmd_idx + 1;

    -- Populate the shared VVC command record
    output_vvc_cmd.operation    := broadcast_cmd_to_shared_cmd(shared_vvc_broadcast_cmd.operation);
    output_vvc_cmd.msg_id       := shared_vvc_broadcast_cmd.msg_id;
    output_vvc_cmd.msg          := shared_vvc_broadcast_cmd.msg;
    output_vvc_cmd.quietness    := shared_vvc_broadcast_cmd.quietness;
    output_vvc_cmd.delay        := shared_vvc_broadcast_cmd.delay;
    output_vvc_cmd.timeout      := shared_vvc_broadcast_cmd.timeout;
    output_vvc_cmd.gen_integer_array(0)  := shared_vvc_broadcast_cmd.gen_integer;
    output_vvc_cmd.proc_call    := shared_vvc_broadcast_cmd.proc_call;
    output_vvc_cmd.cmd_idx      := shared_cmd_idx;
    output_vvc_cmd.command_type := get_command_type_from_operation(shared_vvc_broadcast_cmd.operation);

    if global_show_msg_for_uvvm_cmd then
      log(ID_UVVM_SEND_CMD, to_string(shared_vvc_cmd.proc_call) & ": " & add_msg_delimiter(to_string(shared_vvc_cmd.msg)) & "."
          & format_command_idx(shared_cmd_idx), C_SCOPE);
    else
      log(ID_UVVM_SEND_CMD, to_string(shared_vvc_cmd.proc_call)
          & format_command_idx(shared_cmd_idx), C_SCOPE);
    end if;
    release_semaphore(protected_broadcast_semaphore);

  end procedure;

  procedure await_cmd_from_sequencer(
    constant vvc_labels        : in t_vvc_labels;
    constant vvc_config        : in t_vvc_config;
    signal VVCT                : in t_vvc_target_record;
    signal VVC_BROADCAST       : inout std_logic;
    signal global_vvc_busy : inout std_logic;
    signal vvc_ack             : out std_logic;
    constant shared_vvc_cmd    : in t_vvc_cmd_record;
    variable output_vvc_cmd    : out t_vvc_cmd_record
    ) is
    variable v_was_broadcast : boolean := false;
  begin
    vvc_ack <= 'Z';  -- Do not contribute to the acknowledge unless selected
    -- Wait for a new command
    log(ID_CMD_INTERPRETER_WAIT, "Interpreter: Waiting for command", to_string(vvc_labels.scope) , vvc_config.msg_id_panel);

    loop
      VVC_BROADCAST <= 'Z';
      global_vvc_busy <= 'L';
      wait until (VVCT.trigger = '1' or VVC_BROADCAST = '1');
      if VVC_BROADCAST'event and VVC_BROADCAST = '1' then
        v_was_broadcast := true;
        VVC_BROADCAST <= '1';
        populate_shared_vvc_cmd_with_broadcast(output_vvc_cmd);
      else
        -- set VVC_BROADCAST to 0 to force a broadcast to wait for that VVC
        VVC_BROADCAST <= '0';
        global_vvc_busy   <= '1';
        -- copy shared_vvc_cmd to release the semaphore
        output_vvc_cmd := shared_vvc_cmd;
      end if;

      -- Check that the channel is valid
      if (not v_was_broadcast) then
        if (VVCT.vvc_instance_idx = vvc_labels.instance_idx and
            VVCT.vvc_name(1 to valid_length(vvc_labels.vvc_name)) = vvc_labels.vvc_name(1 to valid_length(vvc_labels.vvc_name))) then
          if ((VVCT.vvc_channel = NA and vvc_labels.channel /= NA) or
             (vvc_labels.channel = NA and (VVCT.vvc_channel /= NA and VVCT.vvc_channel /= ALL_CHANNELS))) then
              tb_warning(to_string(output_vvc_cmd.proc_call) & " Channel "& to_string(VVCT.vvc_channel) & " not supported on this VVC " & format_command_idx(output_vvc_cmd), to_string(vvc_labels.scope));
              -- only release semaphore and stay in loop forcing a timeout too
              release_semaphore(protected_semaphore);
          end if;
        end if;
      end if;

      exit when (v_was_broadcast or                                                                                                     -- Broadcast, or
                (((VVCT.vvc_instance_idx = vvc_labels.instance_idx) or (VVCT.vvc_instance_idx = ALL_INSTANCES)) and              -- Index is correct or broadcast index
                ((VVCT.vvc_channel = ALL_CHANNELS) or (VVCT.vvc_channel = vvc_labels.channel)) and                                      -- Channel is correct or broadcast channel
                VVCT.vvc_name(1 to valid_length(vvc_labels.vvc_name)) = vvc_labels.vvc_name(1 to valid_length(vvc_labels.vvc_name))));  -- Name is correct
    end loop;
    if ((VVCT.vvc_instance_idx = ALL_INSTANCES) or (VVCT.vvc_channel = ALL_CHANNELS) ) then
      -- in case of a multicast block the global acknowledge until all vvc receiving the message processed it
      vvc_ack <= '0';
    end if;

    wait for 0 ns;
    if not v_was_broadcast then
      -- release the semaphore if it was not a broadcast
      release_semaphore(protected_semaphore);
    end if;

    log(ID_CMD_INTERPRETER, to_string(output_vvc_cmd.proc_call) & ". Command received " & format_command_idx(output_vvc_cmd), vvc_labels.scope, vvc_config.msg_id_panel);    -- Get and ack the new command
  end procedure;


  procedure put_command_on_queue(
    constant command              : in t_vvc_cmd_record;
    variable command_queue        : inout work.td_cmd_queue_pkg.t_generic_queue;
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
    variable command_queue        : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config           : in t_vvc_config;
    signal executor_is_busy       : in boolean;
    constant vvc_labels           : in t_vvc_labels;
    signal last_cmd_idx_executed  : in natural;
    constant await_completion_pending_msg_id      : in t_msg_id := ID_IMMEDIATE_CMD_WAIT;
    constant await_completion_finished_msg_id     : in t_msg_id := ID_IMMEDIATE_CMD
    ) is

    alias wanted_idx              : integer is command.gen_integer_array(0); -- generic integer used as wanted command idx to wait for

  begin
    if wanted_idx = -1 then
      -- await completion of all commands
      if not command_queue.is_empty(VOID) or executor_is_busy then
        log(await_completion_pending_msg_id, "await_completion() - Pending completion " & to_string(command.msg) & " " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command
        loop
          if command.timeout = 0 ns then
            wait until executor_is_busy = false;
          else
            wait until (executor_is_busy = false) for command.timeout;
          end if;
          if command_queue.is_empty(VOID) or not executor_is_busy'event then
            exit;
          end if;
        end loop;
      end if;
      log(await_completion_finished_msg_id, "await_completion()  => Finished. " & to_string(command.msg) & " " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command

    else -- await specific instruction
      if last_cmd_idx_executed < wanted_idx then
        log(await_completion_pending_msg_id, "await_completion(" & to_string(wanted_idx) & ") - Pending selected " & to_string(command.msg) & " "  & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command
        loop
          if command.timeout = 0 ns then
            wait until executor_is_busy = false;
          else
            wait until executor_is_busy = false for command.timeout;
          end if;
          if last_cmd_idx_executed >= wanted_idx  or not executor_is_busy'event then
            exit;
          end if;
        end loop;
      end if;
      log(await_completion_finished_msg_id, "await_completion(" & to_string(wanted_idx) & ") => Finished. " & to_string(command.msg) & " " &  format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel); -- Get & ack the new command
    end if;
  end procedure;

  ------------------------------------------------------------------------------------------
  -- Wait for any of the following :
  --   await_completion of this VVC, or
  --   until global_awaiting_completion /= '1' (any of the other involved VVCs completed).
  ------------------------------------------------------------------------------------------
  procedure interpreter_await_any_completion(
    constant command                              : in t_vvc_cmd_record;
    variable command_queue                        : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config                           : in t_vvc_config;
    signal executor_is_busy                       : in boolean;
    constant vvc_labels                           : in t_vvc_labels;
    signal last_cmd_idx_executed                  : in natural;
    signal global_awaiting_completion             : inout std_logic_vector; -- Handshake from other VVCs performing await_any_completion
    constant await_completion_pending_msg_id      : in t_msg_id := ID_IMMEDIATE_CMD_WAIT;
    constant await_completion_finished_msg_id     : in t_msg_id := ID_IMMEDIATE_CMD
    ) is

    alias wanted_idx              : integer is command.gen_integer_array(0); -- generic integer used as wanted command idx to wait for
    alias awaiting_completion_idx : integer is command.gen_integer_array(1); -- generic integer used as awaiting_completion_idx

    variable v_done               : boolean := false; -- Whether we're done waiting

    -----------------------------------------------
    -- Local function
    -- Return whether if this VVC has completed
    -----------------------------------------------
    impure function this_vvc_completed (
      dummy : t_void
    ) return boolean is
    begin
      if wanted_idx = -1 then
        -- All commands must be completed (i.e. not just a selected command index)
        return (executor_is_busy = false and command_queue.is_empty(VOID));
      else
        -- await a SPECIFIC command in this VVC
        return (last_cmd_idx_executed >= wanted_idx);
      end if;
    end;

  begin

    --
    -- Signal that this VVC is participating in the await_any_completion group by driving global_awaiting_completion
    --
    if not command.gen_boolean then -- NOT_LAST
      -- If this is a NOT_LAST call: Wait for delta cycles until the LAST call sets it to '1',
      -- then set it to '1' here.
      -- Purpose of waiting : synchronize the LAST VVC with all the NOT_LAST VVCs, so that it doesn't have to wait a magic number of delta cycles
      while global_awaiting_completion(awaiting_completion_idx) = 'Z' loop
        wait for 0 ns;
      end loop;
      global_awaiting_completion(awaiting_completion_idx) <= '1';
    else
      -- If this is a LAST call: Set to '1' for at least one delta cycle, so that all NOT_LAST calls detects it.
      global_awaiting_completion(awaiting_completion_idx) <= '1';
      wait for 0 ns;
    end if;

    -- This VVC already completed?
    if this_vvc_completed(VOID) then
      v_done := true;
    end if;

    -- Any of the other involved VVCs already completed?
    if (global_awaiting_completion(awaiting_completion_idx) = 'X' or global_awaiting_completion(awaiting_completion_idx) = '0') then
      v_done := true;
    end if;

    if not v_done then
      -- Start waiting for the first of this VVC or other VVC
      log(await_completion_pending_msg_id, to_string(command.proc_call) & " - Pending completion " & to_string(command.msg) & " " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);

      loop
        wait until ((executor_is_busy = false) or (global_awaiting_completion(awaiting_completion_idx) /= '1')) for command.timeout;

        if this_vvc_completed(VOID) then                   -- This VVC is done
          log(await_completion_finished_msg_id, "This VVC initiated completion of " & to_string(command.proc_call), to_string(vvc_labels.scope), vvc_config.msg_id_panel);

          -- update shared_uvvm_status with the VVC name and cmd index that initiated the completion
          shared_uvvm_status.info_on_finishing_await_any_completion.vvc_name(1 to vvc_labels.vvc_name'length) := vvc_labels.vvc_name;
          shared_uvvm_status.info_on_finishing_await_any_completion.vvc_cmd_idx := last_cmd_idx_executed;
          shared_uvvm_status.info_on_finishing_await_any_completion.vvc_time_of_completion := now;
          exit;
        end if;

        if global_awaiting_completion(awaiting_completion_idx) = '0' or   -- All other involved VVCs are done
           global_awaiting_completion(awaiting_completion_idx) = 'X' then -- Some other involved VVCs are done
          exit;
        end if;


        if not ((executor_is_busy'event) or (global_awaiting_completion(awaiting_completion_idx) /= '1')) then  -- Indicates timeout
          -- When NOT_LAST (command.gen_boolean = false): Timeout must be reported here instead of in send_command_to_vvc()
          -- becuase the command is always acknowledged immediately by the VVC to allow the sequencer to continue
          if not command.gen_boolean then
            tb_error("Timeout during " & to_string(command.proc_call) & "=> " & format_msg(command), to_string(vvc_labels.scope));
          end if;

          exit;
        end if;

      end loop;
    end if;

      global_awaiting_completion(awaiting_completion_idx) <= '0'; -- Signal that we're done waiting

      -- Handshake : Wait until every involved VVC notice the value is 'X' or '0', and all agree to being done ('0')
      if global_awaiting_completion(awaiting_completion_idx) /= '0' then
        wait until (global_awaiting_completion(awaiting_completion_idx) = '0');
      end if;

      global_awaiting_completion(awaiting_completion_idx) <= 'Z'; -- Idle

      log(await_completion_finished_msg_id, to_string(command.proc_call) & "=> Finished. " & format_msg(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel); -- Get & ack the new command

  end procedure;

  procedure interpreter_flush_command_queue(
    constant command            : in t_vvc_cmd_record;
    variable command_queue      : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config         : in t_vvc_config;
    variable vvc_status         : inout t_vvc_status;
    constant vvc_labels         : in t_vvc_labels
    ) is
  begin
    log(ID_IMMEDIATE_CMD, "Flushing command queue (" & to_string(shared_vvc_cmd.gen_integer_array(0)) & ") " & format_command_idx(shared_vvc_cmd), to_string(vvc_labels.scope), vvc_config.msg_id_panel);
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
    variable result_queue           : inout work.td_result_queue_pkg.t_generic_queue;
    constant command                : in t_vvc_cmd_record;
    constant vvc_config             : in t_vvc_config;
    constant vvc_labels             : in t_vvc_labels;
    constant last_cmd_idx_executed  : in natural;
    variable shared_vvc_response    : inout work.vvc_cmd_pkg.t_vvc_response
    ) is
    variable v_current_element    : work.vvc_cmd_pkg.t_vvc_result_queue_element;
    variable v_local_result_queue : work.td_result_queue_pkg.t_generic_queue;
  begin
    v_local_result_queue.set_scope(to_string(vvc_labels.scope));

    shared_vvc_response.fetch_is_accepted := false;  -- default
    if last_cmd_idx_executed < command.gen_integer_array(0) then
      tb_warning(to_string(command.proc_call) & ". Requested result is not yet available. " & format_command_idx(command), to_string(vvc_labels.scope));
    else
      -- Search for the command idx among the elements of the queue.
      -- Easiest method of doing this is to pop elements, and pushing them again
      -- if the cmd idx does not match. Not very efficient, but an OK initial implementation.

      -- Pop the element. Compare cmd idx. If it does not match, push to local result queue.
      -- If an index matches, set shared_vvc_response.result. (Don't push element back to result queue)
      while result_queue.get_count(VOID) > 0 loop
        v_current_element := result_queue.get(VOID);
        if v_current_element.cmd_idx = command.gen_integer_array(0) then
          shared_vvc_response.fetch_is_accepted := true;
          shared_vvc_response.result              := v_current_element.result;
          log(ID_IMMEDIATE_CMD, to_string(command.proc_call) & " Requested result is found" & ". " & to_string(command.msg) & " " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel); -- Get and ack the new command
          exit;
        else
          -- No match for element: put in local result queue
          v_local_result_queue.put(v_current_element);
        end if;
      end loop;

      -- Pop each element of local result queue and push to result queue.
      -- This is to clear the local result queue and restore the result
      -- queue to its original state (except that the matched element is not put back).
      while v_local_result_queue.get_count(VOID) > 0 loop
        result_queue.put(v_local_result_queue.get(VOID));
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
    variable command_queue        : inout work.td_cmd_queue_pkg.t_generic_queue;
    constant vvc_config           : in t_vvc_config;
    variable vvc_status           : inout t_vvc_status;
    signal   queue_is_increasing  : in boolean;
    signal executor_is_busy       : inout boolean;
    constant vvc_labels           : in t_vvc_labels
    ) is
  begin
    executor_is_busy            <= false;
    vvc_status.previous_cmd_idx := command.cmd_idx;

    wait for 0 ns;  -- to allow delta updates in other processes.
    if command_queue.is_empty(VOID) then
      log(ID_CMD_EXECUTOR_WAIT, "Executor: Waiting for command", to_string(vvc_labels.scope), vvc_config.msg_id_panel);
      wait until queue_is_increasing;
    end if;

    -- Queue is now not empty
    executor_is_busy  <= true;
    wait until executor_is_busy;
    command := command_queue.get(VOID);
    log(ID_CMD_EXECUTOR, to_string(command.proc_call) & " - Will be executed " & format_command_idx(command), to_string(vvc_labels.scope), vvc_config.msg_id_panel);    -- Get and ack the new command
    vvc_status.pending_cmd_cnt := command_queue.get_count(VOID);
    vvc_status.current_cmd_idx := command.cmd_idx;
  end procedure;

  -- The result_queue is used so that whatever type defined in the VVC can be stored,
  -- and later fetched with fetch_result()
  procedure store_result(
    variable result_queue  : inout work.td_result_queue_pkg.t_generic_queue;
    constant cmd_idx       : in natural;
    constant result          : in t_vvc_result
    ) is
    variable v_result_queue_element : t_vvc_result_queue_element;
  begin
    v_result_queue_element.cmd_idx := cmd_idx;
    v_result_queue_element.result := result;
    result_queue.put(v_result_queue_element);
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
            log(ID_INSERTED_DELAY, "Delaying BFM access until time " & to_string(timestamp_end_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time)
                & ".", scope, vvc_config.msg_id_panel);
            wait for (timestamp_end_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time - now);
          end if;
        when TIME_START2START =>
          if now < (timestamp_start_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time) then
            log(ID_INSERTED_DELAY, "Delaying BFM access until time " & to_string(timestamp_start_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time)
                & ".", scope, vvc_config.msg_id_panel);
            wait for (timestamp_start_of_last_bfm_access + vvc_config.inter_bfm_delay.delay_in_time - now);
          end if;
        when others =>
          tb_error("Delay type " & to_upper(to_string(vvc_config.inter_bfm_delay.delay_type)) & " not supported for this VVC.", C_SCOPE);
      end case;
      log(ID_INSERTED_DELAY, "Finished delaying BFM access", scope, vvc_config.msg_id_panel);
    end if;
  end procedure;

end package body td_vvc_entity_support_pkg;


