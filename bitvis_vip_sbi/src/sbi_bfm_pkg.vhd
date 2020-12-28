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
--
-- Important     : For systems not using 'ready' a dummy signal must be declared and set to '1'
--                 For systems not using 'terminate' a dummy signal must be declared and set to '1' if using sbi_poll_until()
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================
package sbi_bfm_pkg is

  --===============================================================================================
  -- Types and constants for SBI BFMs
  --===============================================================================================
  constant C_SCOPE : string := "SBI BFM";

  type t_sbi_if is record
    cs    : std_logic;                  -- to dut
    addr  : unsigned;                   -- to dut
    rena  : std_logic;                  -- to dut
    wena  : std_logic;                  -- to dut
    wdata : std_logic_vector;           -- to dut
    ready : std_logic;                  -- from dut
    rdata : std_logic_vector;           -- from dut
  end record;


  -- Configuration record to be assigned in the test harness.
  type t_sbi_bfm_config is
  record
    max_wait_cycles             : integer;            -- The maximum number of clock cycles to wait for the DUT ready signal before reporting a timeout alert.
    max_wait_cycles_severity    : t_alert_level;      -- The above timeout will have this severity
    use_fixed_wait_cycles_read  : boolean;            -- When true, wait 'fixed_wait_cycles_read' after asserting rena, before sampling rdata
    fixed_wait_cycles_read      : natural;            -- Number of clock cycles to wait after asserting rd signal, before sampling rdata from DUT.
    clock_period                : time;               -- Period of the clock signal
    clock_period_margin         : time;               -- Input clock period margin to specified clock_period.
                                                      -- When not possible to measure complete period the clock period margin is applied in full on the half period.
    clock_margin_severity       : t_alert_level;      -- The above margin will have this severity
    setup_time                  : time;               -- Generated signals setup time, set to clock_period/4
    hold_time                   : time;               -- Generated signals hold time, set to clock_period/4
    bfm_sync                    : t_bfm_sync;         -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness            : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm                  : t_msg_id;           -- The message ID used as a general message ID in the SBI BFM
    id_for_bfm_wait             : t_msg_id;           -- The message ID used for logging waits in the SBI BFM
    id_for_bfm_poll             : t_msg_id;           -- The message ID used for logging polling in the SBI BFM
    use_ready_signal            : boolean;            -- Whether or not to use the interface �ready� signal
  end record;

  constant C_SBI_BFM_CONFIG_DEFAULT : t_sbi_bfm_config := (
    max_wait_cycles             => 10,
    max_wait_cycles_severity    => failure,
    use_fixed_wait_cycles_read  => false,
    fixed_wait_cycles_read      => 0,
    clock_period                => -1 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => -1 ns,
    hold_time                   => -1 ns,
    bfm_sync                    => SYNC_ON_CLOCK_ONLY,
    match_strictness            => MATCH_EXACT,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL,
    use_ready_signal            => true
    );


  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  ------------------------------------------
  -- init_sbi_if_signals
  ------------------------------------------
  -- - This function returns an SBI interface with initialized signals.
  -- - All SBI input signals are initialized to 0
  -- - All SBI output signals are initialized to Z
  function init_sbi_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_sbi_if;


  ------------------------------------------
  -- sbi_write
  ------------------------------------------
  -- - This procedure writes data to the SBI DUT
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_write (
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal cs             : inout std_logic;
    signal addr           : inout unsigned;
    signal rena           : inout std_logic;
    signal wena           : inout std_logic;
    signal ready          : in    std_logic;
    signal wdata          : inout std_logic_vector;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- sbi_write
  ------------------------------------------
  -- - This procedure writes data 'data_value' to the SBI DUT address 'addr_value'
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_write (
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal sbi_if         : inout t_sbi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- sbi_read
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and
  --   returns the read data in the output 'data_value'
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_read (
    constant addr_value    : in    unsigned;
    variable data_value    : out   std_logic_vector;
    constant msg           : in    string;
    signal clk             : in    std_logic;
    signal cs              : inout std_logic;
    signal addr            : inout unsigned;
    signal rena            : inout std_logic;
    signal wena            : inout std_logic;
    signal ready           : in    std_logic;
    signal rdata           : in    std_logic_vector;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call. Overwrite if called from another BFM procedure

    );

  ------------------------------------------
  -- sbi_read
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and returns
  --   the read data in the output 'data_value'
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_read (
    constant addr_value    : in    unsigned;
    variable data_value    : out   std_logic_vector;
    constant msg           : in    string;
    signal clk             : in    std_logic;
    signal sbi_if          : inout t_sbi_if;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call. Overwrite if called from another BFM procedure
    );


  ------------------------------------------
  -- sbi_check
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, an alert with
  --   severity 'alert_level' is triggered.
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal cs             : inout std_logic;
    signal addr           : inout unsigned;
    signal rena           : inout std_logic;
    signal wena           : inout std_logic;
    signal ready          : in    std_logic;
    signal rdata          : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- sbi_check
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, an alert with
  --   severity 'alert_level' is triggered.
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal sbi_if         : inout t_sbi_if;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- sbi_poll_until
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, a new read
  --   will be performed, and the new read data will be compared with the
  --   'data_exp'. This process will continue until one of the following
  --   conditions are met:
  --     a) The read data is equal to the expected data
  --     b) The number of reads equal 'max_polls'
  --     c) The time spent polling is equal to the 'timeout'
  -- - If 'timeout' is set to 0, it will be interpreted as no timeout
  -- - If 'max_polls' is set to 0, it will be interpreted as no limitation on number of polls
  -- - The SBI interface in this procedure is given as individual signals
  procedure sbi_poll_until (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant max_polls    : in    integer          := 1;
    constant timeout      : in    time             := 0 ns;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal cs             : inout std_logic;
    signal addr           : inout unsigned;
    signal rena           : inout std_logic;
    signal wena           : inout std_logic;
    signal ready          : in    std_logic;
    signal rdata          : in    std_logic_vector;
    signal terminate_loop : in    std_logic;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    );


  ------------------------------------------
  -- sbi_poll_until
  ------------------------------------------
  -- - This procedure reads data from the SBI DUT address 'addr_value' and
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, a new read
  --   will be performed, and the new read data will be compared with the
  --   'data_exp'. This process will continue until one of the following
  --   conditions are met:
  --     a) The read data is equal to the expected data
  --     b) The number of reads equal 'max_polls'
  --     c) The time spent polling is equal to the 'timeout'
  -- - If 'timeout' is set to 0, it will be interpreted as no timeout
  -- - If 'max_polls' is set to 0, it will be interpreted as no limitation on number of polls
  -- - The SBI interface in this procedure is given as a t_sbi_if signal record
  procedure sbi_poll_until (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant max_polls    : in    integer          := 1;
    constant timeout      : in    time             := 0 ns;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal sbi_if         : inout t_sbi_if;
    signal terminate_loop : in    std_logic;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    );

end package sbi_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body sbi_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- initialize sbi to dut signals
  ---------------------------------------------------------------------------------

  function init_sbi_if_signals(
    addr_width : natural;
    data_width : natural
    ) return t_sbi_if is
    variable result : t_sbi_if(addr(addr_width - 1 downto 0),
                               wdata(data_width - 1 downto 0),
                               rdata(data_width - 1 downto 0));
  begin
    result.cs    := '0';
    result.rena  := '0';
    result.wena  := '0';
    result.addr  := (result.addr'range  => '0');
    result.wdata := (result.wdata'range => '0');
    result.ready := 'Z';
    result.rdata := (result.rdata'range => 'Z');
    return result;
  end function;

  ---------------------------------------------------------------------------------
  -- write
  ---------------------------------------------------------------------------------
  procedure sbi_write (
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal cs             : inout std_logic;
    signal addr           : inout unsigned;
    signal rena           : inout std_logic;
    signal wena           : inout std_logic;
    signal ready          : in    std_logic;
    signal wdata          : inout std_logic_vector;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "sbi_write";
    constant proc_call : string := "sbi_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- Normalise to the DUT addr/data widths
    variable v_normalised_addr : unsigned(addr'length-1 downto 0) :=
      normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    variable v_normalised_data : std_logic_vector(wdata'length-1 downto 0) :=
      normalize_and_check(data_value, wdata, ALLOW_NARROWER, "data_value", "sbi_core_in.wdata", msg);
    variable v_clk_cycles_waited      : natural := 0;
    variable v_clk_was_high           : boolean := false;  -- clk high/low status on BFM call
    variable v_time_of_rising_edge    : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns;  -- time stamp for clk period checking

    begin

    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    end if;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    cs    <= '1';
    wena  <= '1';
    rena  <= '0';
    addr  <= v_normalised_addr;
    wdata <= v_normalised_data;

    if config.use_ready_signal then
      check_value(ready = '1' or ready = '0', failure, "Verifying that ready signal is set to either '1' or '0' when in use", scope, ID_NEVER, msg_id_panel);
    end if;
  
    wait until rising_edge(clk);

    check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, config.clock_period, config.clock_period_margin, config.clock_margin_severity);

    while (config.use_ready_signal and ready = '0') loop
      if v_clk_cycles_waited = 0 then
        log(config.id_for_bfm_wait, proc_call & " waiting for response (sbi ready=0) " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
      wait until rising_edge(clk);

      v_clk_cycles_waited := v_clk_cycles_waited + 1;
      check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                  ": Timeout while waiting for sbi ready", scope, ID_NEVER, msg_id_panel, proc_call);
    end loop;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

    cs   <= '0';
    wena <= '0';
    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  procedure sbi_write (
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal sbi_if         : inout t_sbi_if;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    ) is
  begin
    sbi_write(addr_value, data_value, msg, clk, sbi_if.cs, sbi_if.addr,
              sbi_if.rena, sbi_if.wena, sbi_if.ready, sbi_if.wdata,
              scope, msg_id_panel, config);
  end procedure;


  ---------------------------------------------------------------------------------
  -- sbi_read
  ---------------------------------------------------------------------------------
  procedure sbi_read (
    constant addr_value    : in    unsigned;
    variable data_value    : out   std_logic_vector;
    constant msg           : in    string;
    signal clk             : in    std_logic;
    signal cs              : inout std_logic;
    signal addr            : inout unsigned;
    signal rena            : inout std_logic;
    signal wena            : inout std_logic;
    signal ready           : in    std_logic;
    signal rdata           : in    std_logic_vector;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call. Overwrite if called from another BFM procedure
    ) is
    -- local_proc_* used if called from sequencer or VVC
    constant local_proc_name : string := "sbi_read";
    constant local_proc_call : string := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- Normalize to the DUT addr/data widths
    variable v_normalised_addr        : unsigned(addr'length-1 downto 0) :=
                                                normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    variable v_data_value             : std_logic_vector(data_value'range);
    variable v_clk_cycles_waited      : natural := 0;
    variable v_proc_call              : line;
    variable v_clk_was_high           : boolean := false; -- clk high/low status on BFM call
    variable v_time_of_rising_edge    : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time := -1 ns;  -- time stamp for clk period checking

  begin
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
    end if;

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'sbi_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing sbi_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    cs   <= '1';
    wena <= '0';
    rena <= '1';
    addr <= v_normalised_addr;

    if config.use_ready_signal then
      check_value(ready = '1' or ready = '0', failure, "Verifying that ready signal is set to either '1' or '0' when in use", scope, ID_NEVER, msg_id_panel);
    end if;

    wait until rising_edge(clk);
    v_time_of_rising_edge := now;

    check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                              config.clock_period, config.clock_period_margin, config.clock_margin_severity);

    if config.use_fixed_wait_cycles_read then
      -- Wait for a fixed number of clk cycles
      for i in 1 to config.fixed_wait_cycles_read loop
        v_clk_cycles_waited := v_clk_cycles_waited + 1;
        wait until rising_edge(clk);
      end loop;
    else
      -- If configured, wait for ready = '1'
      while (config.use_ready_signal and ready = '0') loop
        if v_clk_cycles_waited = 0 then
          log(config.id_for_bfm_wait, v_proc_call.all & " waiting for response (sbi ready=0) " & add_msg_delimiter(msg), scope, msg_id_panel);
        end if;
        wait until rising_edge(clk);
        v_clk_cycles_waited := v_clk_cycles_waited + 1;
        check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                    ": Timeout while waiting for sbi ready", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      end loop;
    end if;

    v_data_value := rdata;
    data_value   := v_data_value;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
 
    cs   <= '0';
    rena <= '0';
    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      -- Log will be handled by calling procedure (e.g. sbi_check)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure;

  procedure sbi_read (
    constant addr_value    : in    unsigned;
    variable data_value    : out   std_logic_vector;
    constant msg           : in    string;
    signal clk             : in    std_logic;
    signal sbi_if          : inout t_sbi_if;
    constant scope         : in    string           := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config        : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string           := ""  -- External proc_call. Overwrite if called from another BFM procedure
    ) is
  begin
    sbi_read(addr_value, data_value, msg, clk, sbi_if.cs, sbi_if.addr,
             sbi_if.rena, sbi_if.wena, sbi_if.ready, sbi_if.rdata,
             scope, msg_id_panel, config, ext_proc_call);
  end procedure;


  ---------------------------------------------------------------------------------
  -- sbi_check
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the POLL_UNTILed value.
  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal cs             : inout std_logic;
    signal addr           : inout unsigned;
    signal rena           : inout std_logic;
    signal wena           : inout std_logic;
    signal ready          : in    std_logic;
    signal rdata          : in    std_logic_vector;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "sbi_check";
    constant proc_call : string := "sbi_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Normalize to the DUT addr/data widths
    variable v_normalised_addr : unsigned(addr'length-1 downto 0) :=
      normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    variable v_normalized_data : std_logic_vector(rdata'length-1 downto 0) :=
      normalize_and_check(data_exp, rdata, ALLOW_WIDER_NARROWER, "data_exp", "sbi_core_in.rdata", msg);
    -- Helper variables
    variable v_data_value        : std_logic_vector(rdata'length - 1 downto 0);
    variable v_check_ok          : boolean := true;
    variable v_alert_radix       : t_radix;
  begin
    sbi_read(addr_value, v_data_value, msg, clk, cs, addr, rena, wena, ready, rdata, scope, msg_id_panel, config, proc_call);

    for i in v_normalized_data'range loop
      -- Allow don't care in expected value and use match strictness from config for comparison
      if v_normalized_data(i) = '-' or check_value(v_data_value(i), v_normalized_data(i), config.match_strictness, NO_ALERT, msg) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_value, v_normalized_data, MATCH_STD, NO_ALERT, msg) else HEX;
      alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_data_value, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  procedure sbi_check (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal sbi_if         : inout t_sbi_if;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    ) is
  begin
    sbi_check(addr_value, data_exp, msg, clk, sbi_if.cs, sbi_if.addr,
              sbi_if.rena, sbi_if.wena, sbi_if.ready, sbi_if.rdata,
              alert_level, scope, msg_id_panel, config);
  end procedure;


  ---------------------------------------------------------------------------------
  -- sbi_poll_until
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the POLL_UNTILed value.
  -- The checking is repeated until timeout or N occurrences (reads) without POLL_UNTILed data.
  procedure sbi_poll_until (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant max_polls    : in    integer          := 1;
    constant timeout      : in    time             := 0 ns;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal cs             : inout std_logic;
    signal addr           : inout unsigned;
    signal rena           : inout std_logic;
    signal wena           : inout std_logic;
    signal ready          : in    std_logic;
    signal rdata          : in    std_logic_vector;
    signal terminate_loop : in    std_logic;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "sbi_poll_until";
    constant proc_call : string := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ", " & to_string(max_polls) & ", " & to_string(timeout, ns) & ")";
    constant start_time        : time := now;
    -- Normalise to the DUT addr/data widths
    variable v_normalised_addr : unsigned(addr'length-1 downto 0) :=
      normalize_and_check(addr_value, addr, ALLOW_WIDER_NARROWER, "addr_value", "sbi_core_in.addr", msg);
    -- Helper variables
    variable v_data_value            : std_logic_vector(rdata'length - 1 downto 0);
    variable v_check_ok              : boolean;
    variable v_timeout_ok            : boolean;
    variable v_num_of_occurrences_ok : boolean;
    variable v_num_of_occurrences    : integer          := 0;
    variable v_clk_cycles_waited     : natural          := 0;
    variable v_config                : t_sbi_bfm_config := config;

  begin
    -- Check for timeout = 0 and max_polls = 0. This combination can result in an infinite loop if the POLL_UNTILed data does not appear.
    if max_polls = 0 and timeout = 0 ns then
      alert(TB_WARNING, proc_name & " called with timeout=0 and max_polls=0. This can result in an infinite loop. " & add_msg_delimiter(msg), scope);
    end if;

    -- Initial status of the checks
    v_check_ok              := false;
    v_timeout_ok            := true;
    v_num_of_occurrences_ok := true;
    v_config.id_for_bfm     := ID_BFM_POLL;

    while not v_check_ok and v_timeout_ok and v_num_of_occurrences_ok and (terminate_loop = '0') loop
      -- Read data on SBI register
      sbi_read(v_normalised_addr, v_data_value, "As a part of " & proc_call & ". " & add_msg_delimiter(msg), clk, cs, addr, rena, wena, ready, rdata, scope, msg_id_panel, v_config,
               return_string1_if_true_otherwise_string2("", proc_call, is_log_msg_enabled(ID_BFM_POLL, msg_id_panel)));  -- ID_BFM_POLL will allow the logging inside sbi_read to be executed

      -- Evaluate data
      v_check_ok := matching_values(v_data_value, data_exp);

      -- Evaluate number of occurrences, if limited by user
      v_num_of_occurrences := v_num_of_occurrences + 1;
      if max_polls > 0 then
        v_num_of_occurrences_ok := v_num_of_occurrences < max_polls;
      end if;

      -- Evaluate timeout, if specified by user
      if timeout = 0 ns then
        v_timeout_ok := true;
      else
        v_timeout_ok := (now - start_time) < timeout;
      end if;

    end loop;


    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & " after " & to_string(v_num_of_occurrences) & " occurrences and " & to_string((now - start_time), ns) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    elsif not v_timeout_ok then
      alert(alert_level, proc_call & "=> Failed due to timeout. Did not get POLL_UNTILed value " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & " before time " & to_string(timeout, ns) & ". " & add_msg_delimiter(msg), scope);
    elsif terminate_loop = '1' then
      log(ID_TERMINATE_CMD, proc_call & " Terminated from outside this BFM. " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
      alert(alert_level, proc_call & "=> Failed. POLL_UNTILed value " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & " did not appear within " & to_string(max_polls) & " occurrences. " & add_msg_delimiter(msg), scope);
    end if;
  end procedure;


  procedure sbi_poll_until (
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant max_polls    : in    integer          := 1;
    constant timeout      : in    time             := 0 ns;
    constant msg          : in    string;
    signal clk            : in    std_logic;
    signal sbi_if         : inout t_sbi_if;
    signal terminate_loop : in    std_logic;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    ) is
  begin
    sbi_poll_until(addr_value, data_exp, max_polls, timeout, msg, clk, sbi_if.cs, sbi_if.addr,
                   sbi_if.rena, sbi_if.wena, sbi_if.ready, sbi_if.rdata,
                   terminate_loop, alert_level, scope, msg_id_panel, config);
  end procedure;
end package body sbi_bfm_pkg;
