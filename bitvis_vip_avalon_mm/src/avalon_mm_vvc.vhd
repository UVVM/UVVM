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

use work.avalon_mm_bfm_pkg.all;
use work.vvc_methods_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_entity_support_pkg.all;
use work.td_queue_pkg.all;

--=================================================================================================
entity avalon_mm_vvc is
  generic (
    GC_ADDR_WIDTH                           : integer range 1 to C_VVC_CMD_ADDR_MAX_LENGTH := 8;          -- Avalon MM address bus
    GC_DATA_WIDTH                           : integer range 1 to C_VVC_CMD_DATA_MAX_LENGTH := 32;         -- Avalon MM data bus
    GC_INSTANCE_IDX                         : natural                 := 1;                               -- Instance index for this AVALON_MM_VVCT instance
    GC_AVALON_MM_CONFIG                     : t_avalon_mm_bfm_config  := C_AVALON_MM_BFM_CONFIG_DEFAULT;  -- Behavior specification for BFM
    GC_CMD_QUEUE_COUNT_MAX                  : natural                 := 1000; 
    GC_CMD_QUEUE_COUNT_THRESHOLD            : natural                 := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY   : t_alert_level           := WARNING
  );
  port (
    clk                           : in std_logic;
    avalon_mm_vvc_master_if       : inout t_avalon_mm_if := init_avalon_mm_if_signals(GC_ADDR_WIDTH, GC_DATA_WIDTH)
  );
  begin
      -- Check the interface widths to assure that the interface was correctly set up
    assert (avalon_mm_vvc_master_if.address'length = GC_ADDR_WIDTH) report "avalon_mm_vvc_master_if.address'length /= GC_ADDR_WIDTH" severity failure;
    assert (avalon_mm_vvc_master_if.writedata'length = GC_DATA_WIDTH) report "avalon_mm_vvc_master_if.writedata'length /= GC_DATA_WIDTH" severity failure;
    assert (avalon_mm_vvc_master_if.readdata'length = GC_DATA_WIDTH) report "avalon_mm_vvc_master_if.readdata'length /= GC_DATA_WIDTH" severity failure;
    assert (avalon_mm_vvc_master_if.byte_enable'length = GC_DATA_WIDTH/8) report "avalon_mm_vvc_master_if.byte_enable'length /= GC_DATA_WIDTH/8" severity failure;
end entity avalon_mm_vvc;

--=================================================================================================
--=================================================================================================

architecture behave of avalon_mm_vvc is

  constant C_SCOPE      : string        := C_VVC_NAME & "," & to_string(GC_INSTANCE_IDX);
  constant C_VVC_LABELS : t_vvc_labels  := assign_vvc_labels(C_SCOPE, C_VVC_NAME, GC_INSTANCE_IDX, NA);
  
  signal executor_is_busy                 : boolean := false;
  signal queue_is_increasing              : boolean := false;
  signal read_response_is_busy            : boolean := false;
  signal response_queue_is_increasing     : boolean := false;
  signal last_cmd_idx_executed            : natural := 0;
  signal last_read_response_idx_executed  : natural := 0;
  signal terminate_current_cmd            : t_flag_record;

  -- Instantiation of the element dedicated Queue
  shared variable command_queue           : t_generic_queue;
  shared variable command_response_queue  : t_generic_queue;

  alias vvc_config                    : t_vvc_config is shared_avalon_mm_vvc_config(GC_INSTANCE_IDX);
  alias vvc_status                    : t_vvc_status is shared_avalon_mm_vvc_status(GC_INSTANCE_IDX);
  alias transaction_info_for_waveview : t_transaction_info_for_waveview is shared_avalon_mm_transaction_info_for_waveview(GC_INSTANCE_IDX);


begin


--===============================================================================================
-- Constructor
-- - Set up the defaults and show constructor if enabled
--===============================================================================================
  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, GC_AVALON_MM_CONFIG, 
                  GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY);
--===============================================================================================


--===============================================================================================
-- Command interpreter
-- - Interpret, decode and acknowledge commands from the central sequencer
--===============================================================================================
  cmd_interpreter : process

  begin
    
    -- 0. Initialize the process prior to first command
    work.td_vvc_entity_support_pkg.initialize_interpreter(terminate_current_cmd);

    -- Then for every single command from the sequencer
    loop  -- basically as long as new commands are received

      -- 1. wait until command targeted at this VVC. Must match VVC name, instance and channel (if applicable)
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.await_cmd_from_sequencer(C_VVC_LABELS, vvc_config, THIS_VVCT, VVC_BROADCAST, global_vvc_ack, shared_vvc_cmd);


      -- 2a. Put command on the queue if intended for the executor
      -------------------------------------------------------------------------
      if shared_vvc_cmd.command_type = QUEUED then
        work.td_vvc_entity_support_pkg.put_command_on_queue(shared_vvc_cmd, command_queue, vvc_status, queue_is_increasing);


      -- 2b. Otherwise command is intended for immediate response
      -------------------------------------------------------------------------
      elsif  shared_vvc_cmd.command_type = IMMEDIATE then
        case shared_vvc_cmd.operation is

          when AWAIT_COMPLETION =>
            -- Await completion of all commands in the cmd_executor queue
            work.td_vvc_entity_support_pkg.interpreter_await_completion(shared_vvc_cmd, command_queue, vvc_config, executor_is_busy, C_VVC_LABELS, last_cmd_idx_executed,ID_IMMEDIATE_CMD_WAIT,ID_NEVER);
            -- Await completion of all commands in the read_response queue
            work.td_vvc_entity_support_pkg.interpreter_await_completion(shared_vvc_cmd, command_response_queue, vvc_config, read_response_is_busy, C_VVC_LABELS, last_read_response_idx_executed, ID_NEVER, ID_IMMEDIATE_CMD);

          when DISABLE_LOG_MSG =>
            uvvm_util.methods_pkg.disable_log_msg(shared_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(shared_vvc_cmd.msg) & format_command_idx(shared_vvc_cmd), C_SCOPE, shared_vvc_cmd.quietness);

          when ENABLE_LOG_MSG =>
            uvvm_util.methods_pkg.enable_log_msg(shared_vvc_cmd.msg_id, vvc_config.msg_id_panel, to_string(shared_vvc_cmd.msg) & format_command_idx(shared_vvc_cmd), C_SCOPE, shared_vvc_cmd.quietness);

          when FLUSH_COMMAND_QUEUE =>
            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(shared_vvc_cmd, command_queue, vvc_config, vvc_status, C_VVC_LABELS);

          when TERMINATE_CURRENT_COMMAND =>
            work.td_vvc_entity_support_pkg.interpreter_terminate_current_command(shared_vvc_cmd, vvc_config, C_VVC_LABELS, terminate_current_cmd);

          when FETCH_RESULT =>
            work.td_vvc_entity_support_pkg.interpreter_fetch_result(GC_INSTANCE_IDX, shared_vvc_cmd, vvc_config, C_VVC_LABELS, GC_DATA_WIDTH, last_cmd_idx_executed, shared_vvc_response);

          when others =>
            tb_error("Unsupported command received for IMMEDIATE execution: '" & to_string(shared_vvc_cmd.operation) & "'", C_SCOPE);

        end case;
        wait for 0 ns;

      else
        tb_error("command_type is not IMMEDIATE or QUEUED", C_SCOPE);
      end if;

      -- 3. Acknowledge command after runing or queuing the command
      -------------------------------------------------------------------------
      uvvm_vvc_framework.ti_vvc_framework_support_pkg.acknowledge_cmd(global_vvc_ack);

    end loop;
  end process;
--===============================================================================================



--===============================================================================================
-- Command executor
-- - Fetch and execute the commands
--===============================================================================================
  cmd_executor : process
    variable v_cmd                                    : t_vvc_cmd_record;
    variable v_read_data                              : std_logic_vector(GC_DATA_WIDTH-1 downto 0);    
    variable v_timestamp_start_of_current_bfm_access  : time := 0 ns;
    variable v_timestamp_start_of_last_bfm_access     : time := 0 ns;
    variable v_timestamp_end_of_last_bfm_access       : time := 0 ns;
    variable v_command_is_bfm_access                  : boolean;
    variable v_normalised_addr                        : unsigned(GC_ADDR_WIDTH-1 downto 0) := (others => '0');
    variable v_normalised_data                        : std_logic_vector(GC_DATA_WIDTH-1 downto 0) := (others => '0');
    variable v_normalised_byte_ena                    : std_logic_vector((GC_DATA_WIDTH/8)-1 downto 0) := (others => '0');
  begin

    -- 0. Initialize the process prior to first command
    -------------------------------------------------------------------------
    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);

    loop
      
      -- 1. Set defaults, fetch command and log
      -------------------------------------------------------------------------
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing, executor_is_busy, C_VVC_LABELS);
      
      -- Set the transaction info for waveview
      transaction_info_for_waveview           := C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT;
      transaction_info_for_waveview.operation := v_cmd.operation;
      transaction_info_for_waveview.msg       := pad_string(to_string(v_cmd.msg), ' ', transaction_info_for_waveview.msg'length);
      
      -- Check if command is a BFM access
      if v_cmd.operation = WRITE or v_cmd.operation = READ or v_cmd.operation = CHECK or v_cmd.operation = RESET then 
        v_command_is_bfm_access := true;
      else
        v_command_is_bfm_access := false;
      end if;
      
      -- Insert delay if needed
      work.td_vvc_entity_support_pkg.insert_inter_bfm_delay_if_requested(vvc_config               => vvc_config,
                                                               command_is_bfm_access              => v_command_is_bfm_access,
                                                               timestamp_start_of_last_bfm_access => v_timestamp_start_of_last_bfm_access,
                                                               timestamp_end_of_last_bfm_access   => v_timestamp_end_of_last_bfm_access,
                                                               scope                              => C_SCOPE); 
      
      if v_command_is_bfm_access then
        v_timestamp_start_of_current_bfm_access := now;
      end if;
      
      -- 2. Execute the fetched command
      -------------------------------------------------------------------------
      case v_cmd.operation is  -- Only operations in the dedicated record are relevant

        -- VVC dedicated operations
        --===================================
        when WRITE =>
          -- Normalise address and data
          v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalised_addr", "avalon_mm_write() called with to wide address. " & v_cmd.msg);
          v_normalised_data := normalize_and_check(v_cmd.data, v_normalised_data, ALLOW_WIDER_NARROWER, "v_cmd.data", "v_normalised_data", "avalon_mm_write() called with to wide data. " & v_cmd.msg);
          if (v_cmd.byte_enable = (0 to v_cmd.byte_enable'length-1 => '1')) then
            v_normalised_byte_ena := (others => '1');
          else
            v_normalised_byte_ena := normalize_and_check(v_cmd.byte_enable, v_normalised_byte_ena, ALLOW_WIDER_NARROWER, "v_cmd.byte_enable", "v_normalised_byte_ena", "avalon_mm_write() called with to wide byte_enable. " & v_cmd.msg);
          end if;
          transaction_info_for_waveview.data(GC_DATA_WIDTH - 1 downto 0) := v_normalised_data;
          transaction_info_for_waveview.addr(GC_ADDR_WIDTH - 1 downto 0) := v_normalised_addr;
          transaction_info_for_waveview.byte_enable((GC_DATA_WIDTH/8) - 1 downto 0) := v_cmd.byte_enable((GC_DATA_WIDTH/8) - 1 downto 0);
          
          -- Call the corresponding procedure in the BFM package.
          avalon_mm_write(addr_value          => v_normalised_addr,
                          data_value          => v_normalised_data,
                          msg                 => format_msg(v_cmd),
                          clk                 => clk,
                          avalon_mm_if        => avalon_mm_vvc_master_if,
                          byte_enable         => v_cmd.byte_enable((GC_DATA_WIDTH/8)-1 downto 0),
                          scope               => C_SCOPE,
                          msg_id_panel        => vvc_config.msg_id_panel,
                          config              => vvc_config.bfm_config);                  
          
        when READ =>
          -- Normalise address
          v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalised_addr", "avalon_mm_read() called with to wide address. " & v_cmd.msg);
          
          transaction_info_for_waveview.addr(GC_ADDR_WIDTH - 1 downto 0) := v_normalised_addr;
          
          -- Call the corresponding procedure in the BFM package.
          if vvc_config.use_read_pipeline then
            -- Stall until response command queue is no longer full
            while command_response_queue.get_count(VOID) > vvc_config.num_pipeline_stages loop
              wait for vvc_config.bfm_config.clock_period;
            end loop;
            avalon_mm_read_request( addr_value          => v_normalised_addr,
                                    msg                 => format_msg(v_cmd),
                                    clk                 => clk,
                                    avalon_mm_if        => avalon_mm_vvc_master_if,
                                    scope               => C_SCOPE,
                                    msg_id_panel        => vvc_config.msg_id_panel,
                                    config              => vvc_config.bfm_config);
            work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, command_response_queue, vvc_status, response_queue_is_increasing);
            
          else
            avalon_mm_read( addr_value          => v_normalised_addr,
                            data_value          => v_read_data,
                            msg                 => format_msg(v_cmd),
                            clk                 => clk,
                            avalon_mm_if        => avalon_mm_vvc_master_if,
                            scope               => C_SCOPE,
                            msg_id_panel        => vvc_config.msg_id_panel,
                            config              => vvc_config.bfm_config);
            -- Store the result
            work.td_vvc_entity_support_pkg.store_result( instance_idx  => GC_INSTANCE_IDX,
                                               cmd_idx       => v_cmd.cmd_idx,
                                               data          => v_read_data);

          end if;
          
        when CHECK =>
          
          -- Normalise address
          v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, "v_cmd.addr", "v_normalised_addr", "avalon_mm_check() called with to wide address. " & v_cmd.msg);
          v_normalised_data := normalize_and_check(v_cmd.data, v_normalised_data, ALLOW_WIDER_NARROWER, "v_cmd.data", "v_normalised_data", "avalon_mm_check() called with to wide data. " & v_cmd.msg);

          transaction_info_for_waveview.data(GC_DATA_WIDTH - 1 downto 0) := v_normalised_data;
          transaction_info_for_waveview.addr(GC_ADDR_WIDTH - 1 downto 0) := v_normalised_addr;
          -- Call the corresponding procedure in the BFM package.
          if vvc_config.use_read_pipeline then
            -- Wait until response command queue is no longer full
            while command_response_queue.get_count(VOID) > vvc_config.num_pipeline_stages loop
              wait for vvc_config.bfm_config.clock_period;
            end loop;
            
            avalon_mm_read_request( addr_value          => v_normalised_addr,
                                    msg                 => format_msg(v_cmd),
                                    clk                 => clk,
                                    avalon_mm_if        => avalon_mm_vvc_master_if,
                                    scope               => C_SCOPE,
                                    msg_id_panel        => vvc_config.msg_id_panel,
                                    config              => vvc_config.bfm_config);
            work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, command_response_queue, vvc_status, response_queue_is_increasing);                          
          else
            avalon_mm_check(addr_value          => v_normalised_addr,
                            data_exp            => v_normalised_data,
                            alert_level         => v_cmd.alert_level,
                            msg                 => format_msg(v_cmd),
                            clk                 => clk,
                            avalon_mm_if        => avalon_mm_vvc_master_if,
                            scope               => C_SCOPE,
                            msg_id_panel        => vvc_config.msg_id_panel,
                            config              => vvc_config.bfm_config);
          end if;
          
        when RESET =>
          -- Call the corresponding procedure in the BFM package.
          avalon_mm_reset(clk                 => clk,
                          avalon_mm_if        => avalon_mm_vvc_master_if,
                          num_rst_cycles      => v_cmd.gen_integer,
                          msg                 => format_msg(v_cmd),
                          scope               => C_SCOPE,
                          msg_id_panel        => vvc_config.msg_id_panel,
                          config              => vvc_config.bfm_config);
                          
        when LOCK =>
          -- Call the corresponding procedure in the BFM package.
          avalon_mm_lock( avalon_mm_if        => avalon_mm_vvc_master_if,
                          msg                 => format_msg(v_cmd),
                          scope               => C_SCOPE,
                          msg_id_panel        => vvc_config.msg_id_panel,
                          config              => vvc_config.bfm_config);                          

        when UNLOCK =>
          -- Call the corresponding procedure in the BFM package.
          avalon_mm_unlock( avalon_mm_if        => avalon_mm_vvc_master_if,
                          msg                 => format_msg(v_cmd),
                          scope               => C_SCOPE,
                          msg_id_panel        => vvc_config.msg_id_panel,
                          config              => vvc_config.bfm_config);                          
                          
                          
        -- UVVM common operations
        --===================================
        when INSERT_DELAY =>
          log(ID_BFM, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, vvc_config.msg_id_panel);
          wait for v_cmd.gen_integer * vvc_config.bfm_config.clock_period;
          
        when INSERT_DELAY_IN_TIME =>
          log(ID_BFM, "Running: " & to_string(v_cmd.proc_call) & " " & format_command_idx(v_cmd), C_SCOPE, vvc_config.msg_id_panel);
          wait for v_cmd.delay;

        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_SCOPE);
      end case;
      
      if v_command_is_bfm_access then
        v_timestamp_end_of_last_bfm_access := now;
        v_timestamp_start_of_last_bfm_access := v_timestamp_start_of_current_bfm_access;
        if ((vvc_config.inter_bfm_delay.delay_type = TIME_START2START) and 
           ((now - v_timestamp_start_of_current_bfm_access) > vvc_config.inter_bfm_delay.delay_in_time)) then
          alert(vvc_config.inter_bfm_delay.inter_bfm_delay_violation_severity, "BFM access exceeded specified start-to-start inter-bfm delay, " & 
                to_string(vvc_config.inter_bfm_delay.delay_in_time) & ".", C_SCOPE);
        end if; 
      end if;
        
      -- Reset terminate flag if any occurred    
      if (terminate_current_cmd.is_active = '1') then
        log(ID_CMD_EXECUTOR, "Termination request received", C_SCOPE, vvc_config.msg_id_panel);
        uvvm_vvc_framework.ti_vvc_framework_support_pkg.reset_flag(terminate_current_cmd);
      end if;
      
      last_cmd_idx_executed <= v_cmd.cmd_idx;
      -- Reset the transaction info for waveview
      transaction_info_for_waveview   := C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT;

    end loop;
  end process;
  --===============================================================================================

  
  read_response : process
    variable v_cmd                                    : t_vvc_cmd_record;
    variable v_read_data                              : std_logic_vector(GC_DATA_WIDTH-1 downto 0);
    variable v_normalised_addr                        : unsigned(GC_ADDR_WIDTH-1 downto 0) := (others => '0');
    variable v_normalised_data                        : std_logic_vector(GC_DATA_WIDTH-1 downto 0) := (others => '0');
  begin
    -- Set the command response queue up to the same settings as the command queue
    command_response_queue.set_scope(C_SCOPE & ":RQ");
    command_response_queue.set_queue_count_max(vvc_config.cmd_queue_count_max);
    command_response_queue.set_queue_count_threshold(vvc_config.cmd_queue_count_threshold);
    command_response_queue.set_queue_count_threshold_severity(vvc_config.cmd_queue_count_threshold_severity);
    wait for 0 ns;  -- Wait for command response queue to initialize completely
    
    loop
      -- Fetch commands
      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_response_queue, vvc_config, vvc_status, response_queue_is_increasing, read_response_is_busy, C_VVC_LABELS);
      
      -- Normalise address and data
      v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", "Function called with to wide address. " & v_cmd.msg);
      v_normalised_data := normalize_and_check(v_cmd.data, v_normalised_data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", "Function called with to wide data. " & v_cmd.msg);
      
      case v_cmd.operation is
        when READ =>
          -- Initiate read response
          avalon_mm_read_response(addr_value          => v_normalised_addr,
                                  data_value          => v_read_data,
                                  msg                 => format_msg(v_cmd),
                                  clk                 => clk,
                                  avalon_mm_if        => avalon_mm_vvc_master_if,
                                  scope               => C_SCOPE,
                                  msg_id_panel        => vvc_config.msg_id_panel,
                                  config              => vvc_config.bfm_config);
          -- Store the result
          work.td_vvc_entity_support_pkg.store_result(instance_idx  => GC_INSTANCE_IDX,
                                                      cmd_idx       => v_cmd.cmd_idx,
                                                      data          => v_read_data);
        
        when CHECK =>
          -- Initiate check response
          avalon_mm_check_response( addr_value          => v_normalised_addr,
                                    data_exp            => v_normalised_data,
                                    msg                 => format_msg(v_cmd),
                                    clk                 => clk,
                                    avalon_mm_if        => avalon_mm_vvc_master_if,
                                    scope               => C_SCOPE,
                                    msg_id_panel        => vvc_config.msg_id_panel,
                                    config              => vvc_config.bfm_config);
        when others =>
          tb_error("Unsupported local command received for execution: '" & to_string(v_cmd.operation) & "'", C_SCOPE);
      
      end case;
      
      last_read_response_idx_executed <= v_cmd.cmd_idx;
      
    end loop;
    
  end process;
  --===============================================================================================
  
  
  

--===============================================================================================
-- Command termination handler
-- - Handles the termination request record (sets and resets terminate flag on request)
--===============================================================================================
  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd);  -- flag: is_active, set, reset
--===============================================================================================

end behave;



