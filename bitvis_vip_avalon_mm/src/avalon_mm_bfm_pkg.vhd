--================================================================================================================================
-- Copyright 2024 UVVM
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================

package avalon_mm_bfm_pkg is

  ----------------------------------------------------
  -- Types for Avalon BFM
  ----------------------------------------------------
  constant C_BFM_SCOPE : string := "AVALON MM BFM";

  -- Avalon Interface signals
  type t_avalon_mm_if is record
    -- Avalon MM BFM to DUT signals
    reset         : std_logic;
    address       : std_logic_vector;
    begintransfer : std_logic;          -- optional, Altera recommends not to use
    byte_enable   : std_logic_vector;
    chipselect    : std_logic;
    write         : std_logic;
    writedata     : std_logic_vector;
    read          : std_logic;
    lock          : std_logic;

    -- Avalon MM DUT to BFM signals
    readdata      : std_logic_vector;
    response      : std_logic_vector(1 downto 0); -- Set use_response_signal to false if not in use
    waitrequest   : std_logic;
    readdatavalid : std_logic;          -- might be used, might not.. If not used, fixed latency is a given
                                        -- (same for read and write), unless waitrequest is used.
    irq           : std_logic;
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_avalon_mm_bfm_config is record
    max_wait_cycles          : integer; -- Sets the maximum number of wait cycles before an alert occurs when waiting for readdatavalid or stalling because of waitrequest
    max_wait_cycles_severity : t_alert_level; -- The above timeout will have this severity
    clock_period             : time;    -- Period of the clock signal.
    clock_period_margin      : time;    -- Input clock period accuracy margin to specified clock_period
    clock_margin_severity    : t_alert_level; -- The above margin will have this severity
    setup_time               : time;    -- Setup time for generated signals, set to clock_period/4
    hold_time                : time;    -- Hold time for generated signals, set to clock_period/4
    bfm_sync                 : t_bfm_sync; -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness         : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    num_wait_states_read     : natural; -- use_waitrequest = false -> this controls the (fixed) latency for read
    num_wait_states_write    : natural; -- use_waitrequest = false -> this controls the (fixed) latency for write
    use_waitrequest          : boolean; -- slave uses waitrequest
    use_readdatavalid        : boolean; -- slave uses readdatavalid (variable latency)
    use_response_signal      : boolean; -- Whether or not to check the response signal on read
    use_begintransfer        : boolean; -- Whether or not to assert begintransfer on start of transfer (Altera recommends not to use)
    id_for_bfm               : t_msg_id; -- The message ID used as a general message ID in the Avalon BFM
    id_for_bfm_wait          : t_msg_id; -- The message ID used for logging waits in the Avalon BFM    -- DEPRECATE: will be removed
    id_for_bfm_poll          : t_msg_id; -- The message ID used for logging polling in the Avalon BFM  -- DEPRECATE: will be removed
  end record;

  constant C_AVALON_MM_BFM_CONFIG_DEFAULT : t_avalon_mm_bfm_config := (
    max_wait_cycles          => 10,
    max_wait_cycles_severity => TB_FAILURE,
    clock_period             => -1 ns,
    clock_period_margin      => 0 ns,
    clock_margin_severity    => TB_ERROR,
    setup_time               => -1 ns,
    hold_time                => -1 ns,
    bfm_sync                 => SYNC_ON_CLOCK_ONLY,
    match_strictness         => MATCH_EXACT,
    num_wait_states_read     => 0,
    num_wait_states_write    => 0,
    use_waitrequest          => true,
    use_readdatavalid        => false,
    use_response_signal      => true,
    use_begintransfer        => false,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL
  );

  type t_avalon_mm_response_status is (OKAY, RESERVED, SLAVEERROR, DECODEERROR);

  type t_avalon_clock_period is record
    time_of_rising_edge  : time;
    time_of_falling_edge : time;
  end record;
  constant C_AVALON_CLOCK_PERIOD_DEFAULT : t_avalon_clock_period := (
    time_of_rising_edge  => -1 ns,
    time_of_falling_edge => -1 ns
  );

  -- Used for detecting clock period for BFM exit, updated by Write request and Read Request procedures.
  shared variable shared_avalon_clock_period : t_avalon_clock_period := C_AVALON_CLOCK_PERIOD_DEFAULT;
  shared variable shared_avalon_last_response_timestamp : time := -1 ns;

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------
  -- This function returns an Avalon-MM interface with initialized signals.
  -- All BFM output signals are initialized to 0
  -- All BFM input signals are initialized to Z
  function init_avalon_mm_if_signals(
    addr_width : natural;
    data_width : natural;
    lock_value : std_logic := '0'
  ) return t_avalon_mm_if;

  -- This procedure could be called from an a simple testbench or
  -- from an executor where there are concurrent BFMs - where
  -- all BFMs could have different configs and msg_id_panels.
  -- From a simplified testbench it is not necessary to use arguments
  -- where defaults are given, e.g.:
  -- avalon_mm_write(addr, data, msg, clk, avalon_mm_if);

  -- avalon_mm_write overload without byte_enable
  procedure avalon_mm_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

  -- avalon_mm_write with byte_enable
  procedure avalon_mm_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant byte_enable  : in std_logic_vector;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

  procedure avalon_mm_read(
    constant addr_value   : in unsigned;
    variable data_value   : out std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name    : in string                 := "avalon_mm_read" -- Overwrite if called from another procedure
  );

  procedure avalon_mm_check(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

  procedure avalon_mm_reset(
    signal   clk            : in std_logic;
    signal   avalon_mm_if   : inout t_avalon_mm_if;
    constant num_rst_cycles : in integer;
    constant msg            : in string;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

  procedure avalon_mm_read_request(
    constant addr_value    : in unsigned;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   avalon_mm_if  : inout t_avalon_mm_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  procedure avalon_mm_read_response(
    constant addr_value   : in unsigned;
    variable data_value   : out std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : in t_avalon_mm_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name    : in string                 := "avalon_mm_read_response" -- Overwrite if called from another procedure
  );

  procedure avalon_mm_check_response(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : in t_avalon_mm_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

  procedure avalon_mm_lock(
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant msg          : in string;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

  procedure avalon_mm_unlock(
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant msg          : in string;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

end package avalon_mm_bfm_pkg;

--=================================================================================================
--=================================================================================================

package body avalon_mm_bfm_pkg is

  function init_avalon_mm_if_signals(
    addr_width : natural;
    data_width : natural;
    lock_value : std_logic := '0'
  ) return t_avalon_mm_if is
    variable result : t_avalon_mm_if(address(addr_width - 1 downto 0),
                                     byte_enable((data_width / 8) - 1 downto 0),
                                     writedata(data_width - 1 downto 0),
                                     readdata(data_width - 1 downto 0));
  begin
    -- BFM to DUT signals
    result.reset         := '0';
    result.address       := (result.address'range => '0');
    result.begintransfer := '0';
    result.byte_enable   := (result.byte_enable'range => '1');
    result.chipselect    := '0';
    result.write         := '0';
    result.writedata     := (result.writedata'range => '0');
    result.read          := '0';
    result.lock          := lock_value;

    -- DUT to BFM signals
    result.readdata      := (result.readdata'range => 'Z');
    result.response      := (result.response'range => 'Z');
    result.waitrequest   := 'Z';
    result.readdatavalid := 'Z';
    result.irq           := 'Z';

    return result;
  end function;

  function to_avalon_mm_response_status(
    constant response     : in std_logic_vector(1 downto 0);
    constant scope        : in string         := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  ) return t_avalon_mm_response_status is
  begin
    case response is
      when "00" =>
        return OKAY;
      when "10" =>
        return RESERVED;
      when "11" =>
        return SLAVEERROR;
      when others =>
        return DECODEERROR;
    end case;
  end function;

  -- avalon_mm_write overload without byte_enable
  procedure avalon_mm_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    variable v_byte_enable : std_logic_vector((avalon_mm_if.writedata'length / 8) - 1 downto 0) := (others => '1');
  begin
    avalon_mm_write(addr_value, data_value, msg, clk, avalon_mm_if, v_byte_enable, scope, msg_id_panel, config);
  end procedure;

  procedure avalon_mm_write(
    constant addr_value   : in unsigned;
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant byte_enable  : in std_logic_vector;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name         : string                                                       := "avalon_mm_write";
    constant proc_call         : string                                                       := "avalon_mm_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length - 1 downto 0)   := normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "address", "avalon_mm_if.address", msg);
    variable v_normalized_data : std_logic_vector(avalon_mm_if.writedata'length - 1 downto 0) := normalize_and_check(data_value, avalon_mm_if.writedata, ALLOW_NARROWER, "data", "avalon_mm_if.writedata", msg);

    variable v_time_of_rising_edge  : time    := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time    := -1 ns; -- time stamp for clk period checking
    variable v_timeout              : boolean := false;

  begin
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_name);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    end if;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    avalon_mm_if.writedata   <= v_normalized_data;
    avalon_mm_if.byte_enable <= byte_enable;
    avalon_mm_if.write       <= '1';
    avalon_mm_if.chipselect  <= '1';
    avalon_mm_if.address     <= v_normalized_addr;

    if config.use_begintransfer then
      avalon_mm_if.begintransfer <= '1';
    end if;

    wait until rising_edge(clk);        -- wait for DUT update of signal
    v_time_of_rising_edge := now;

    check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                              config.clock_period, config.clock_period_margin, config.clock_margin_severity);
    -- Set the clock period for avalon_mm_read_response()
    shared_avalon_clock_period.time_of_falling_edge := v_time_of_falling_edge;
    shared_avalon_clock_period.time_of_rising_edge  := v_time_of_rising_edge;

    -- Release the begintransfer signal after one clock cycle, if waitrequest is in use
    if config.use_begintransfer then
      avalon_mm_if.begintransfer <= '0';
    end if;

    -- use wait request?
    if config.use_waitrequest then
      for cycle in 1 to config.max_wait_cycles loop
        if avalon_mm_if.waitrequest = '1' then
          wait until rising_edge(clk);
        else
          exit;
        end if;
        if cycle = config.max_wait_cycles then
          v_timeout := true;
        end if;
      end loop;

      -- did we v_timeout?
      if v_timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for waitrequest " & add_msg_delimiter(msg), scope);
      end if;

    else                                -- not waitrequest. num_wait_states_write will be used as number of wait cycles in fixed wait-states
      for cycle in 1 to config.num_wait_states_write loop
        wait until rising_edge(clk);
      end loop;
    end if;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length, avalon_mm_if.lock);

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure avalon_mm_write;

  function is_readdatavalid_active(
    signal   avalon_mm_if : in t_avalon_mm_if;
    constant config       : in t_avalon_mm_bfm_config
  ) return boolean is
  begin
    if (config.use_readdatavalid and avalon_mm_if.readdatavalid = '1') then
      return true;
    end if;
    return false;
  end function is_readdatavalid_active;

  function is_waitrequest_active(
    signal   avalon_mm_if : in t_avalon_mm_if;
    constant config       : in t_avalon_mm_bfm_config
  ) return boolean is
  begin
    if (config.use_waitrequest and avalon_mm_if.waitrequest = '1') then
      return true;
    end if;
    return false;
  end function is_waitrequest_active;

  procedure avalon_mm_read(
    constant addr_value   : in unsigned;
    variable data_value   : out std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name    : in string                 := "avalon_mm_read" -- Overwrite if called from another procedure
  ) is
  begin
    avalon_mm_read_request(addr_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_name);
    avalon_mm_read_response(addr_value, data_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_name);
  end procedure avalon_mm_read;

  procedure avalon_mm_check(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "avalon_mm_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    avalon_mm_read_request(addr_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_call);
    avalon_mm_check_response(addr_value, data_exp, msg, clk, avalon_mm_if, alert_level, scope, msg_id_panel, config);
  end procedure avalon_mm_check;

  procedure avalon_mm_reset(
    signal   clk            : in std_logic;
    signal   avalon_mm_if   : inout t_avalon_mm_if;
    constant num_rst_cycles : in integer;
    constant msg            : in string;
    constant scope          : in string                 := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "avalon_mm_reset(num_rst_cycles=" & to_string(num_rst_cycles) & ")";
  begin
    log(config.id_for_bfm, proc_call & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    avalon_mm_if       <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length);
    avalon_mm_if.reset <= '1';
    for i in 1 to num_rst_cycles loop
      wait until rising_edge(clk);
    end loop;

    avalon_mm_if.reset <= '0';

    wait until rising_edge(clk);
  end procedure avalon_mm_reset;

  -- NOTE: This procedure returns as soon as the read command has been accepted. To retreive the response, use
  -- avalon_mm_read_response or avalon_mm_check_response.
  procedure avalon_mm_read_request(
    constant addr_value    : in unsigned;
    constant msg           : in string;
    signal   clk           : in std_logic;
    signal   avalon_mm_if  : inout t_avalon_mm_if;
    constant scope         : in string                 := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel         := shared_msg_id_panel;
    constant config        : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string                 := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    -- local_proc_* used if called from sequencer or VVC
    constant local_proc_name   : string                                                     := "avalon_mm_read_request";
    constant local_proc_call   : string                                                     := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_timeout         : boolean                                                    := false;
    variable v_proc_call       : line;  -- Current proc_call, external or local
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length - 1 downto 0) := normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "addr", "avalon_mm_if.address", msg);

    variable v_time_of_rising_edge    : time := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns; -- time stamp for clk period checking
    variable v_clock_period           : time := -1 ns;
    variable v_add_wait_request_delay : boolean := false;
  begin
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, local_proc_name);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_name);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_name);
    end if;

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'avalon_mm_read_request...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing avalon_mm_read_request...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    -- start the read
    avalon_mm_if.address                                                   <= v_normalized_addr;
    avalon_mm_if.read                                                      <= '1';
    avalon_mm_if.byte_enable(avalon_mm_if.byte_enable'length - 1 downto 0) <= (others => '1'); -- always all bytes for reads
    avalon_mm_if.chipselect                                                <= '1';

    wait until rising_edge(clk);        -- wait for DUT update of signal
    v_time_of_rising_edge := now;

    check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                              config.clock_period, config.clock_period_margin, config.clock_margin_severity);

    -- Get the clock period from the clk signal in case it is not configured
    v_clock_period := abs (v_time_of_rising_edge - v_time_of_falling_edge) * 2;

    -- Set the clock period for avalon_mm_read_response()
    shared_avalon_clock_period.time_of_falling_edge := v_time_of_falling_edge;
    shared_avalon_clock_period.time_of_rising_edge  := v_time_of_rising_edge;

    -- Handle read with waitrequests
    if config.use_waitrequest then
      for cycle in 1 to config.max_wait_cycles loop
        if is_waitrequest_active(avalon_mm_if, config) then
          wait until rising_edge(clk);
        else
          if cycle = 1 then
            v_add_wait_request_delay := true;
          end if;
          exit;
        end if;
        if cycle = config.max_wait_cycles then
          v_timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if v_timeout then
        alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout waiting for waitrequest" & add_msg_delimiter(msg), scope);
      end if;

    else                                -- not waitrequest - issue read, wait num_wait_states_read before finishing the read
      for cycle in 1 to config.num_wait_states_read loop
        wait until rising_edge(clk);
      end loop;
    end if;

    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length, avalon_mm_if.lock);

    -- If wait request is not asserted on the first cycle, wait until the next
    -- rising edge until data becomes available by the agent
    if v_add_wait_request_delay then
      wait until rising_edge(clk);
    end if;

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. avalon_mm_check)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure avalon_mm_read_request;

  procedure avalon_mm_read_response(
    constant addr_value   : in unsigned;
    variable data_value   : out std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : in t_avalon_mm_if;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name    : in string                 := "avalon_mm_read_response" -- Overwrite if called from another procedure
  ) is
    constant proc_call : string := "avalon_mm_read_response(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_data      : std_logic_vector(avalon_mm_if.readdata'length - 1 downto 0) := normalize_and_check(data_value, avalon_mm_if.readdata, ALLOW_NARROWER, "data", "avalon_mm_if.readdata", msg);
    -- Helper variables
    variable v_time_of_rising_edge  : time                                                        := shared_avalon_clock_period.time_of_rising_edge; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                                        := shared_avalon_clock_period.time_of_falling_edge; -- time stamp for clk period checking
    variable v_timeout              : boolean                                                     := false;

  begin
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_name);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    end if;

    -- If a new read response starts at the same time as the last read response
    -- finished, wait until the next clock cycle to sample a new data value
    if shared_avalon_last_response_timestamp = now then
      wait until rising_edge(clk);
    end if;

    -- Handle read with readdatavalid.
    if config.use_readdatavalid then
      for cycle in 1 to config.max_wait_cycles loop
        -- Check for readdatavalid
        if is_readdatavalid_active(avalon_mm_if, config) then
          log(config.id_for_bfm, "readdatavalid was active after " & to_string(cycle) & " clock cycles", scope, msg_id_panel);
          exit;

        else
          wait until rising_edge(clk);
        end if;

        if cycle = config.max_wait_cycles then
          v_timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if v_timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for readdatavalid. " & add_msg_delimiter(msg), scope);
      end if;
    end if;

    if config.use_response_signal = true and to_avalon_mm_response_status(avalon_mm_if.response) /= OKAY then
      error("Avalon MM read response was not OKAY, got " & to_string(avalon_mm_if.response), scope);
    end if;

    v_normalized_data := avalon_mm_if.readdata;
    data_value        := v_normalized_data(data_value'length - 1 downto 0);

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
    shared_avalon_last_response_timestamp := now;

    if proc_name = "avalon_mm_read_response" then
      log(config.id_for_bfm, proc_call & "=> " & to_string(data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure avalon_mm_read_response;

  procedure avalon_mm_check_response(
    constant addr_value   : in unsigned;
    constant data_exp     : in std_logic_vector;
    constant msg          : in string;
    signal   clk          : in std_logic;
    signal   avalon_mm_if : in t_avalon_mm_if;
    constant alert_level  : in t_alert_level          := error;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string := "avalon_mm_check_response";
    constant proc_call : string := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(avalon_mm_if.readdata'length - 1 downto 0) := normalize_and_check(data_exp, avalon_mm_if.readdata, ALLOW_NARROWER, "data", "avalon_mm_if.readdata", msg);

    -- Helper variables
    variable v_data_value  : std_logic_vector(avalon_mm_if.readdata'length - 1 downto 0) := (others => '0');
    variable v_check_ok    : boolean                                                     := true;
    variable v_alert_radix : t_radix;
  begin

    avalon_mm_read_response(addr_value, v_data_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_name);

    for i in v_normalized_data'range loop
      -- Allow don't care in expected value and use match strictness from config for comparison
      if v_normalized_data(i) = '-' or check_value(v_data_value(i), v_normalized_data(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_value, v_normalized_data, MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_data_value, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure avalon_mm_check_response;

  procedure avalon_mm_lock(
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant msg          : in string;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "avalon_mm_lock()";
  begin
    log(config.id_for_bfm, proc_call & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    avalon_mm_if.lock <= '1';
  end procedure avalon_mm_lock;

  procedure avalon_mm_unlock(
    signal   avalon_mm_if : inout t_avalon_mm_if;
    constant msg          : in string;
    constant scope        : in string                 := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "avalon_mm_unlock()";
  begin
    log(config.id_for_bfm, proc_call & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    avalon_mm_if.lock <= '0';
  end procedure avalon_mm_unlock;

end package body avalon_mm_bfm_pkg;
