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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library std;
use std.textio.all;

--================================================================================================================================
--================================================================================================================================
package gmii_bfm_pkg is

  --==========================================================================================
  -- Types and constants for GMII BFM 
  --==========================================================================================
  constant C_SCOPE : string := "GMII BFM";

  -- Interface record for BFM signals to DUT
  type t_gmii_tx_if is record
    gtxclk : std_logic;
    txd    : std_logic_vector(7 downto 0);
    txen   : std_logic;
  end record;
  -- Interface record for BFM signals from DUT
  type t_gmii_rx_if is record
    rxclk  : std_logic;
    rxd    : std_logic_vector(7 downto 0);
    rxdv   : std_logic;
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_gmii_bfm_config is
  record
    max_wait_cycles          : integer;            -- Used for setting the maximum cycles to wait before an alert is issued when
                                                   -- waiting for signals from the DUT.
    max_wait_cycles_severity : t_alert_level;      -- Severity if max_wait_cycles expires.
    clock_period             : time;               -- Period of the clock signal.
    clock_period_margin      : time;               -- Input clock period margin to specified clock_period
    clock_margin_severity    : t_alert_level;      -- The above margin will have this severity
    setup_time               : time;               -- Setup time for generated signals, set to clock_period/4
    hold_time                : time;               -- Hold time for generated signals, set to clock_period/4
    bfm_sync                 : t_bfm_sync;         -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness         : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm               : t_msg_id;           -- The message ID used as a general message ID in the BFM
  end record;

  -- Define the default value for the BFM config
  constant C_GMII_BFM_CONFIG_DEFAULT : t_gmii_bfm_config := (
    max_wait_cycles          => 12, -- Standard minimum interpacket gap (Gigabith Ethernet)
    max_wait_cycles_severity => ERROR,
    clock_period             => -1 ns,
    clock_period_margin      => 0 ns,
    clock_margin_severity    => TB_ERROR,
    setup_time               => -1 ns,
    hold_time                => -1 ns,
    bfm_sync                 => SYNC_ON_CLOCK_ONLY,
    match_strictness         => MATCH_EXACT,
    id_for_bfm               => ID_BFM
  );

  --==========================================================================================
  -- BFM procedures 
  --==========================================================================================
  -- This function returns a GMII interface with initialized signals.
  -- All input signals are initialized to 0
  -- All output signals are initialized to Z
  function init_gmii_if_signals
    return t_gmii_tx_if;

  function init_gmii_if_signals
    return t_gmii_rx_if;

  ---------------------------------------------------------------------------------------------
  -- GMII Write
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure gmii_write (
    constant data_array   : in    t_slv_array;
    constant msg          : in    string            := "";
    signal   gmii_tx_if   : inout t_gmii_tx_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------------------
  -- GMII Read
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure gmii_read (
    variable data_array    : out   t_slv_array;
    variable data_len      : out   natural;
    constant msg           : in    string            := "";
    signal   gmii_rx_if    : inout t_gmii_rx_if;
    constant scope         : in    string            := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config        : in    t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string := ""  -- External proc_call. Overwrite if called from another BFM procedure
  );

  ---------------------------------------------------------------------------------------------
  -- GMII Expect
  ---------------------------------------------------------------------------------------------
  procedure gmii_expect (
    constant data_exp     : in    t_slv_array;
    constant msg          : in    string            := "";
    signal   gmii_rx_if   : inout t_gmii_rx_if;
    constant alert_level  : in    t_alert_level     := ERROR;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT
  );

end package gmii_bfm_pkg;


--================================================================================================================================
--================================================================================================================================
package body gmii_bfm_pkg is

  function init_gmii_if_signals
      return t_gmii_tx_if is
    variable init_if : t_gmii_tx_if;
  begin
    init_if.gtxclk := 'Z';
    init_if.txd    := (init_if.txd'range => '0');
    init_if.txen   := '0';
    return init_if;
  end function;

  function init_gmii_if_signals
      return t_gmii_rx_if is
    variable init_if : t_gmii_rx_if;
  begin
    init_if.rxclk := 'Z';
    init_if.rxd   := (init_if.rxd'range => 'Z');
    init_if.rxdv  := 'Z';
    return init_if;
  end function;

  ---------------------------------------------------------------------------------------------
  -- GMII Write
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure gmii_write(
    constant data_array   : in    t_slv_array;
    constant msg          : in    string            := "";
    signal   gmii_tx_if   : inout t_gmii_tx_if;
    constant scope        : in    string            := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config       : in    t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name              : string := "gmii_write";
    constant proc_call              : string := proc_name & "(" & to_string(data_array'length) & " bytes)";
    variable v_time_of_rising_edge  : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge : time := -1 ns;  -- time stamp for clk period checking

  begin
    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, proc_call);
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    end if;

    gmii_tx_if <= init_gmii_if_signals;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(gmii_tx_if.gtxclk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
    log(config.id_for_bfm, proc_call & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    -- Write all the bytes in the data_array
    for i in data_array'range loop
      gmii_tx_if.txd  <= data_array(i);
      gmii_tx_if.txen <= '1';
      -- Check the clock margin
      wait until rising_edge(gmii_tx_if.gtxclk);
      if v_time_of_rising_edge < 0 ns then
        v_time_of_rising_edge := now;
      end if;
      check_clock_period_margin(gmii_tx_if.gtxclk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, 
                                config.clock_period, config.clock_period_margin, config.clock_margin_severity);
      -- Wait according to config.bfm_sync setup
      wait_on_bfm_exit(gmii_tx_if.gtxclk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
    end loop;

    gmii_tx_if <= init_gmii_if_signals;
    log(config.id_for_bfm, proc_call & " DONE. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- GMII Read
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure gmii_read(
    variable data_array    : out   t_slv_array;
    variable data_len      : out   natural;
    constant msg           : in    string            := "";
    signal   gmii_rx_if    : inout t_gmii_rx_if;
    constant scope         : in    string            := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel    := shared_msg_id_panel;
    constant config        : in    t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string := ""  -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name        : string := "gmii_read"; -- Internal proc_name; Used if called from sequencer or VVC
    constant local_proc_call        : string := local_proc_name & "(" & to_string(data_array'length) & " bytes)";
    variable v_proc_call            : line; -- Current proc_call, external or local
    variable v_normalized_data      : t_slv_array(0 to data_array'length-1)(7 downto 0);
    variable v_time_of_rising_edge  : time := -1 ns;  -- time stamp for clk period checking
    variable v_time_of_falling_edge : time := -1 ns;  -- time stamp for clk period checking
    variable v_byte_cnt             : natural := 0;
    variable v_done                 : boolean := false;
    variable v_timeout              : boolean := false;
    variable v_wait_cycles          : natural := 0;

  begin
    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'gmii_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing gmii_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
      check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    end if;

    gmii_rx_if <= init_gmii_if_signals;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(gmii_rx_if.rxclk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
    log(config.id_for_bfm, v_proc_call.all & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    -- Wait for the first rising edge to sample the data and check the clock margin
    wait until rising_edge(gmii_rx_if.rxclk);
    v_time_of_rising_edge := now;
    check_clock_period_margin(gmii_rx_if.rxclk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                              config.clock_period, config.clock_period_margin, config.clock_margin_severity);

    -- Wait for data valid to be active
    while gmii_rx_if.rxdv /= '1' and v_wait_cycles < config.max_wait_cycles loop
      wait_on_bfm_sync_start(gmii_rx_if.rxclk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
      wait until rising_edge(gmii_rx_if.rxclk);
      v_wait_cycles := v_wait_cycles + 1;
    end loop;
    if gmii_rx_if.rxdv /= '1' then
      v_timeout := true;
      v_done    := true;
    end if;

    -- Sample the data
    while not(v_done) loop
      if gmii_rx_if.rxdv = '1' then
        v_normalized_data(v_byte_cnt) := gmii_rx_if.rxd;

        if v_byte_cnt = v_normalized_data'length-1 then
          v_done := true;
        else
          wait_on_bfm_exit(gmii_rx_if.rxclk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
          wait until rising_edge(gmii_rx_if.rxclk);
        end if;
        v_byte_cnt := v_byte_cnt + 1;
      else
        -- Data valid went low
        v_done := true;
      end if;
    end loop;

    data_array := v_normalized_data;
    data_len   := v_byte_cnt;

    -- Wait according to bfm_sync config
    if not(v_timeout) then
      wait_on_bfm_exit(gmii_rx_if.rxclk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
    end if;

    -- Done. Check if there was a timeout or it was successful
    if v_timeout then
      alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout while waiting for valid data. " &
        add_msg_delimiter(msg), scope);
    else
      if ext_proc_call = "" then
        log(config.id_for_bfm, v_proc_call.all & " DONE. " & add_msg_delimiter(msg), scope, msg_id_panel);
      else
        -- Log will be handled by calling procedure (e.g. gmii_expect)
      end if;
    end if;

    DEALLOCATE(v_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- GMII Expect
  ---------------------------------------------------------------------------------------------
  procedure gmii_expect (
    constant data_exp     : in    t_slv_array;
    constant msg          : in    string             := "";
    signal   gmii_rx_if   : inout t_gmii_rx_if;
    constant alert_level  : in    t_alert_level      := ERROR;
    constant scope        : in    string             := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in    t_gmii_bfm_config  := C_GMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name          : string := "gmii_expect";
    constant proc_call          : string := proc_name & "(" & to_string(data_exp'length) & " bytes)";
    variable v_normalized_data  : t_slv_array(0 to data_exp'length-1)(7 downto 0) := data_exp;
    variable v_rx_data_array    : t_slv_array(v_normalized_data'range)(7 downto 0);
    variable v_rx_data_len      : natural;
    variable v_length_error     : boolean := false;
    variable v_data_error_cnt   : natural := 0;
    variable v_first_wrong_byte : natural;
    variable v_alert_radix      : t_radix;
  begin

    check_value(data_exp'ascending, TB_FAILURE, "Sanity check: Check that data_exp is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, proc_call);

    -- Read data
    gmii_read(v_rx_data_array, v_rx_data_len, msg, gmii_rx_if, scope, msg_id_panel, config, proc_call);

    -- Check the length of the received data
    if v_rx_data_len /= v_normalized_data'length then
      v_length_error := true;
    end if;

    -- Check if each received bit matches the expected.
    -- Report the first wrong byte (iterate from the last to the first)
    for byte in v_rx_data_array'high downto 0 loop
      for i in v_rx_data_array(byte)'range loop
        -- Allow don't care in expected value and use match strictness from config for comparison
        if v_normalized_data(byte)(i) = '-' or check_value(v_rx_data_array(byte)(i), v_normalized_data(byte)(i), config.match_strictness, NO_ALERT, msg) then
          -- Check is OK
        else
          -- Received byte doesn't match
          v_data_error_cnt   := v_data_error_cnt + 1;
          v_first_wrong_byte := byte;
        end if;
      end loop;
    end loop;

    -- Done. Report result
    if v_length_error then
      alert(alert_level, proc_call & "=> Failed. Mismatch in received data length. Was " & to_string(v_rx_data_len) &
        ". Expected " & to_string(v_normalized_data'length) & "." & LF & add_msg_delimiter(msg), scope);
    elsif v_data_error_cnt /= 0 then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_data_array(v_first_wrong_byte), v_normalized_data(v_first_wrong_byte), MATCH_STD, NO_ALERT, msg) else HEX;
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_data_error_cnt) & " data bits. First mismatch in byte# " &
        to_string(v_first_wrong_byte) & ". Was " & to_string(v_rx_data_array(v_first_wrong_byte), v_alert_radix, AS_IS, INCL_RADIX) &
        ". Expected " & to_string(v_normalized_data(v_first_wrong_byte), v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & " bytes. " &
        add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

end package body gmii_bfm_pkg;