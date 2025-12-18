--================================================================================================================================
-- Copyright 2025 UVVM
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
-- Important     : For systems not using 'terminate' a dummy signal must be declared and set to '1' if using apb_poll_until()
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package apb_bfm_pkg is
  constant C_BFM_SCOPE : string := "APB BFM";

  type t_apb_if is record
    pclk    : std_logic;
    paddr   : std_logic_vector;
    pprot   : std_logic_vector(2 downto 0);
    psel    : std_logic;
    penable : std_logic;
    pwrite  : std_logic;
    pwdata  : std_logic_vector;
    pstrb   : std_logic_vector;
    prdata  : std_logic_vector;
    pready  : std_logic;
    pslverr : std_logic;
  end record;

  type t_apb_bfm_config is record
    max_wait_cycles           : integer;            -- The maximum number of clock cycles to wait for the DUT ready signal before reporting a timeout alert.
    max_wait_cycles_severity  : t_alert_level;      -- The above timeout will have this severity
    clock_period              : time;
    clock_period_margin       : time;               -- Input clock period margin to specified clock_period.
                                                    -- When not possible to measure complete period the clock period margin is applied in full on the half period.
    clock_margin_severity     : t_alert_level;      -- The above margin will have this severity
    setup_time                : time;               -- Generated signals setup time, set to clock_period/4
    hold_time                 : time;               -- Generated signals hold time, set to clock_period/4
    bfm_sync                  : t_bfm_sync;         -- Synchronisation of the BFM procedures, i.e. using clock signals, using setup_time and hold_time.
    match_strictness          : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm                : t_msg_id;           -- The message ID used as a general message ID in the APB BFM
    id_for_bfm_wait           : t_msg_id;           -- The message ID used for logging waits in the APB BFM
  end record;

  constant C_APB_BFM_CONFIG_DEFAULT : t_apb_bfm_config := (
    max_wait_cycles           => 10,
    max_wait_cycles_severity  => failure,
    clock_period              => -1 ns,
    clock_period_margin       => 0 ns,
    clock_margin_severity     => TB_ERROR,
    setup_time                => -1 ns,
    hold_time                 => -1 ns,
    bfm_sync                  => SYNC_ON_CLOCK_ONLY,
    match_strictness          => MATCH_EXACT,
    id_for_bfm                => ID_BFM,
    id_for_bfm_wait           => ID_BFM_WAIT
  );

  --===============================================================================================
  -- BFM procedures
  --===============================================================================================

  ------------------------------------------
  -- init_apb_if_signals
  ------------------------------------------
  -- This function returns an APB interface with initialized signals.
  -- All BFM output signals are initialized to 0
  -- All BFM input signals are initialized to Z
  function init_apb_if_signals(
    addr_width : natural;
    data_width : natural
  ) return t_apb_if;

  ------------------------------------------
  -- apb_write
  ------------------------------------------
  -- - This procedure writes data to the APB DUT
  -- - The APB interface in this procedure is given as individual signals
  procedure apb_write(
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant byte_enable  : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal pclk           : in    std_logic;
    signal paddr          : inout std_logic_vector;
    signal pprot          : inout std_logic_vector(2 downto 0);
    signal psel           : inout std_logic;
    signal penable        : inout std_logic;
    signal pwrite         : inout std_logic;
    signal pwdata         : inout std_logic_vector;
    signal pstrb          : inout std_logic_vector;
    signal pready         : in    std_logic;
    signal pslverr        : in    std_logic;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- apb_write
  ------------------------------------------
  -- - This procedure writes data 'data_value' to the APB DUT address 'addr_value'
  -- - The APB interface in this procedure is given as a t_apb_if signal record
  procedure apb_write(
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant byte_enable  : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal   apb_if       : inout t_apb_if;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- apb_read
  ------------------------------------------
  -- - This procedure reads data from the APB DUT address 'addr_value' and
  --   returns the read data in the output 'data_value'
  -- - The APB interface in this procedure is given as individual signals
  procedure apb_read(
    constant addr_value     : in    unsigned;
    variable data_value     : out   std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant msg            : in    string;
    signal pclk             : in    std_logic;
    signal paddr            : inout std_logic_vector;
    signal pprot            : inout std_logic_vector(2 downto 0);
    signal psel             : inout std_logic;
    signal penable          : inout std_logic;
    signal pwrite           : inout std_logic;
    signal prdata           : in    std_logic_vector;
    signal pstrb            : inout std_logic_vector;
    signal pready           : in    std_logic;
    signal pslverr          : in    std_logic;
    constant scope          : in    string           := C_BFM_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in    string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- apb_read
  ------------------------------------------
  -- - This procedure reads data from the APB DUT address 'addr_value' and returns
  --   the read data in the output 'data_value'
  -- - The APB interface in this procedure is given as a t_apb_if signal record
  procedure apb_read(
    constant addr_value     : in    unsigned;
    variable data_value     : out   std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant msg            : in    string;
    signal   apb_if         : inout t_apb_if;
    constant scope          : in    string           := C_BFM_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in    string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- apb_check
  ------------------------------------------
  -- - This procedure reads data from the APB DUT address 'addr_value' and
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, an alert with
  --   severity 'alert_level' is triggered.
  -- - The APB interface in this procedure is given as individual signals
  procedure apb_check(
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal pclk           : in    std_logic;
    signal paddr          : inout std_logic_vector;
    signal pprot          : inout std_logic_vector(2 downto 0);
    signal psel           : inout std_logic;
    signal penable        : inout std_logic;
    signal pwrite         : inout std_logic;
    signal prdata         : in    std_logic_vector;
    signal pstrb          : inout std_logic_vector;
    signal pready         : in    std_logic;
    signal pslverr        : in    std_logic;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- apb_check
  ------------------------------------------
  -- - This procedure reads data from the APB DUT address 'addr_value' and
  --   compares the read data to the expected data in 'data_exp'.
  -- - If the read data is inconsistent with the expected data, an alert with
  --   severity 'alert_level' is triggered.
  -- - The APB interface in this procedure is given as a t_apb_if signal record
  procedure apb_check(
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal   apb_if       : inout t_apb_if;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- apb_poll_until
  ------------------------------------------
  -- - This procedure reads data from the APB DUT address 'addr_value' and
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
  -- - The APB interface in this procedure is given as individual signals
  procedure apb_poll_until(
    constant addr_value     : in    unsigned;
    constant data_exp       : in    std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant max_polls      : in    integer          := 1;
    constant timeout        : in    time             := 0 ns;
    constant msg            : in    string;
    signal   pclk           : in    std_logic;
    signal   paddr          : inout std_logic_vector;
    signal   pprot          : inout std_logic_vector(2 downto 0);
    signal   psel           : inout std_logic;
    signal   penable        : inout std_logic;
    signal   pwrite         : inout std_logic;
    signal   prdata         : in    std_logic_vector;
    signal   pstrb          : inout std_logic_vector;
    signal   pready         : in    std_logic;
    signal   pslverr        : in    std_logic;
    signal   terminate_loop : in    std_logic;
    constant alert_level    : in    t_alert_level    := error;
    constant scope          : in    string           := C_BFM_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  );

  ------------------------------------------
  -- apb_poll_until
  ------------------------------------------
  -- - This procedure reads data from the APB DUT address 'addr_value' and
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
  -- - The APB interface in this procedure is given as a t_apb_if signal record
  procedure apb_poll_until(
    constant addr_value     : in    unsigned;
    constant data_exp       : in    std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant max_polls      : in    integer          := 1;
    constant timeout        : in    time             := 0 ns;
    constant msg            : in    string;
    signal   apb_if         : inout t_apb_if;
    signal   terminate_loop : in    std_logic;
    constant alert_level    : in    t_alert_level    := error;
    constant scope          : in    string           := C_BFM_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  );

end package apb_bfm_pkg;

--=================================================================================================
--=================================================================================================

package body apb_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- initialize APB to dut signals
  ---------------------------------------------------------------------------------

  function init_apb_if_signals(
    addr_width : natural;
    data_width : natural
  ) return t_apb_if is
    variable v_result : t_apb_if(paddr(addr_width - 1 downto 0),
                                 pwdata(data_width - 1 downto 0),
                                 prdata(data_width - 1 downto 0),
                                 pstrb((data_width/8) - 1 downto 0)
                                );
  begin
    v_result.pclk     := 'Z';
    v_result.paddr    := (v_result.paddr'range => '0');
    v_result.pprot    := "000";
    v_result.psel     := '0';
    v_result.penable  := '0';
    v_result.pwrite   := '0';
    v_result.pwdata   := (v_result.pwdata'range => '0');
    v_result.pstrb    := (v_result.pstrb'range => '0');
    v_result.prdata   := (v_result.prdata'range => 'Z');
    v_result.pready   := 'Z';
    v_result.pslverr  := 'Z';
    return v_result;
  end function;

  ---------------------------------------------------------------------------------
  -- write
  ---------------------------------------------------------------------------------

  procedure apb_write(
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant byte_enable  : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal pclk           : in    std_logic;
    signal paddr          : inout std_logic_vector;
    signal pprot          : inout std_logic_vector(2 downto 0);
    signal psel           : inout std_logic;
    signal penable        : inout std_logic;
    signal pwrite         : inout std_logic;
    signal pwdata         : inout std_logic_vector;
    signal pstrb          : inout std_logic_vector;
    signal pready         : in    std_logic;
    signal pslverr        : in    std_logic;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call                : string                                        := "apb_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_addr        : std_logic_vector(paddr'length - 1 downto 0)   := normalize_and_check(std_logic_vector(addr_value), paddr, ALLOW_WIDER_NARROWER, "addr_value", "paddr", msg);
    variable v_normalised_data        : std_logic_vector(pwdata'length - 1 downto 0)  := normalize_and_check(data_value, pwdata, ALLOW_WIDER_NARROWER, "data_value", "pwdata", msg);
    variable v_normalised_byte_enable : std_logic_vector(pstrb'length - 1 downto 0)   := normalize_and_check(byte_enable, pstrb, ALLOW_WIDER_NARROWER, "pstrb", "pstrb", msg);
    variable v_clk_cycles_waited      : natural                                       := 0;
    variable v_time_of_rising_edge    : time                                          := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time                                          := -1 ns; -- time stamp for clk period checking
  begin

    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    end if;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(pclk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    -- Setup Phase
    paddr   <= v_normalised_addr;
    pprot   <= protection;
    psel    <= '1';
    pwrite  <= '1';
    pwdata  <= v_normalised_data;
    pstrb   <= v_normalised_byte_enable;
    penable <= '0';

    -- Access Phase
    wait_on_bfm_sync_start(pclk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
    penable <= '1';

    wait until rising_edge(pclk);

    check_clock_period_margin(pclk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, config.clock_period, config.clock_period_margin, config.clock_margin_severity);

    -- Wait for PREADY
    while pready = '0' loop
      if v_clk_cycles_waited = 0 then
        log(config.id_for_bfm_wait, proc_call & " waiting for response (apb ready=0) " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
      wait until rising_edge(pclk);

      v_clk_cycles_waited := v_clk_cycles_waited + 1;
      check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                  ": Timeout while waiting for apb ready", scope, ID_NEVER, msg_id_panel, proc_call);
    end loop;

    -- Check for errors
    check_value(pslverr, '0', error, "PSLVERR detected", scope, ID_NEVER, msg_id_panel, proc_call);

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_exit(pclk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

    -- Cleanup
    psel    <= '0';
    penable <= '0';
    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure apb_write;

  procedure apb_write(
    constant addr_value   : in    unsigned;
    constant data_value   : in    std_logic_vector;
    constant byte_enable  : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal   apb_if       : inout t_apb_if;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  ) is
  begin
    apb_write(addr_value, data_value, byte_enable, protection, msg, apb_if.pclk, apb_if.paddr, apb_if.pprot, 
              apb_if.psel, apb_if.penable, apb_if.pwrite, apb_if.pwdata, apb_if.pstrb, apb_if.pready, apb_if.pslverr,
              scope, msg_id_panel, config);
  end procedure apb_write;

  ---------------------------------------------------------------------------------
  -- sbi_read
  ---------------------------------------------------------------------------------

  procedure apb_read(
    constant addr_value     : in    unsigned;
    variable data_value     : out   std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant msg            : in    string;
    signal pclk             : in    std_logic;
    signal paddr            : inout std_logic_vector;
    signal pprot            : inout std_logic_vector(2 downto 0);
    signal psel             : inout std_logic;
    signal penable          : inout std_logic;
    signal pwrite           : inout std_logic;
    signal prdata           : in    std_logic_vector;
    signal pstrb            : inout std_logic_vector;
    signal pready           : in    std_logic;
    signal pslverr          : in    std_logic;
    constant scope          : in    string           := C_BFM_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in    string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    -- local_proc_* used if called from sequencer or VVC
    constant local_proc_name : string := "apb_read";
    constant local_proc_call : string := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- Normalize to the DUT addr/data widths
    variable v_normalised_addr        : std_logic_vector(paddr'length - 1 downto 0) := normalize_and_check(std_logic_vector(addr_value), paddr, ALLOW_WIDER_NARROWER, "addr_value", "paddr", msg);
    variable v_normalised_byte_enable : std_logic_vector(pstrb'length - 1 downto 0) := (others=>'0');
    variable v_clk_cycles_waited      : natural                                     := 0;
    variable v_proc_call              : line;
    variable v_time_of_rising_edge    : time                                        := -1 ns; -- time stamp for clk period checking
    variable v_time_of_falling_edge   : time                                        := -1 ns; -- time stamp for clk period checking
  begin
    if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
      check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
      check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_call);
    end if;

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'apb_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing apb_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_sync_start(pclk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);

    -- Setup Phase
    paddr   <= v_normalised_addr;
    pprot   <= protection;
    psel    <= '1';
    pwrite  <= '0';
    pstrb   <= v_normalised_byte_enable;
    penable <= '0';

    -- Access Phase
    wait_on_bfm_sync_start(pclk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
    penable <= '1';

    wait until rising_edge(pclk);

    check_clock_period_margin(pclk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge,
                              config.clock_period, config.clock_period_margin, config.clock_margin_severity);

    -- Wait for PREADY
    while pready = '0' loop
      if v_clk_cycles_waited = 0 then
        log(config.id_for_bfm_wait, v_proc_call.all & " waiting for response (apb ready=0) " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
      wait until rising_edge(pclk);
      v_clk_cycles_waited := v_clk_cycles_waited + 1;
      check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                  ": Timeout while waiting for apb ready", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    end loop;

    -- Capture data
    data_value := prdata;

    -- Check for errors
    check_value(pslverr, '0', error, "PSLVERR detected", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    -- Wait according to config.bfm_sync setup
    wait_on_bfm_exit(pclk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

    -- Cleanup
    psel    <= '0';
    penable <= '0';

    if ext_proc_call = "" then
      log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else
    -- Log will be handled by calling procedure (e.g. apb_check)
    end if;

    DEALLOCATE(v_proc_call);
  end procedure apb_read;

  procedure apb_read(
    constant addr_value     : in    unsigned;
    variable data_value     : out   std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant msg            : in    string;
    signal   apb_if         : inout t_apb_if;
    constant scope          : in    string           := C_BFM_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT;
    constant ext_proc_call  : in    string           := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
  begin
    apb_read(addr_value, data_value, protection, msg, apb_if.pclk, apb_if.paddr, apb_if.pprot, apb_if.psel,
              apb_if.penable, apb_if.pwrite, apb_if.prdata, apb_if.pstrb, apb_if.pready, apb_if.pslverr, scope,
              msg_id_panel, config, ext_proc_call);
  end procedure apb_read;

  ---------------------------------------------------------------------------------
  -- sbi_check
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the POLL_UNTILed value.
  procedure apb_check(
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal pclk           : in    std_logic;
    signal paddr          : inout std_logic_vector;
    signal pprot          : inout std_logic_vector(2 downto 0);
    signal psel           : inout std_logic;
    signal penable        : inout std_logic;
    signal pwrite         : inout std_logic;
    signal prdata         : in    std_logic_vector;
    signal pstrb          : inout std_logic_vector;
    signal pready         : in    std_logic;
    signal pslverr        : in    std_logic;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name                : string                                        := "apb_check";
    constant proc_call                : string                                        := "apb_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    -- Normalize to the DUT addr/data widths
    variable v_normalised_addr        : std_logic_vector(paddr'length - 1 downto 0)   := normalize_and_check(std_logic_vector(addr_value), paddr, ALLOW_WIDER_NARROWER, "addr_value", "paddr", msg);
    variable v_normalised_data        : std_logic_vector(prdata'length - 1 downto 0)  := normalize_and_check(data_exp, prdata, ALLOW_WIDER_NARROWER, "data_exp", "prdata", msg);
    -- Helper variables
    variable v_data_value             : std_logic_vector(prdata'length -1 downto 0);
    variable v_check_ok               : boolean                                       := true;
    variable v_alert_radix            : t_radix;
  begin 
    apb_read(addr_value, v_data_value, protection, msg, pclk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr, scope, msg_id_panel, config);

    for i in v_normalised_data'range loop
      -- Allow don't care in expected value and use match strictness from config for comparison
      if v_normalised_data(i) = '-' or check_value(v_data_value(i), v_normalised_data(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_value, v_normalised_data, MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      alert(alert_level, proc_call & "=> Failed. Was " & to_string(v_data_value, v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalised_data, v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, read data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure apb_check;

  procedure apb_check(
    constant addr_value   : in    unsigned;
    constant data_exp     : in    std_logic_vector;
    constant protection   : in    std_logic_vector(2 downto 0);
    constant msg          : in    string;
    signal   apb_if       : inout t_apb_if;
    constant alert_level  : in    t_alert_level    := error;
    constant scope        : in    string           := C_BFM_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config       : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  ) is
  begin
    apb_check(addr_value, data_exp, protection, msg, apb_if.pclk, apb_if.paddr, apb_if.pprot, 
              apb_if.psel, apb_if.penable, apb_if.pwrite, apb_if.prdata, apb_if.pstrb, apb_if.pready, apb_if.pslverr,
              alert_level, scope, msg_id_panel, config);
  end procedure apb_check;

  ---------------------------------------------------------------------------------
  -- apb_poll_until
  ---------------------------------------------------------------------------------
  -- Perform a read operation, then compare the read value to the POLL_UNTILed value.
  -- The checking is repeated until timeout or N occurrences (reads) without POLL_UNTILed data.
  procedure apb_poll_until(
    constant addr_value     : in    unsigned;
    constant data_exp       : in    std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant max_polls      : in    integer          := 1;
    constant timeout        : in    time             := 0 ns;
    constant msg            : in    string;
    signal   pclk           : in    std_logic;
    signal   paddr          : inout std_logic_vector;
    signal   pprot          : inout std_logic_vector(2 downto 0);
    signal   psel           : inout std_logic;
    signal   penable        : inout std_logic;
    signal   pwrite         : inout std_logic;
    signal   prdata         : in    std_logic_vector;
    signal   pstrb          : inout std_logic_vector;
    signal   pready         : in    std_logic;
    signal   pslverr        : in    std_logic;
    signal   terminate_loop : in    std_logic;
    constant alert_level    : in    t_alert_level    := error;
    constant scope          : in    string           := C_BFM_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in    t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name               : string                             := "apb_poll_until";
    constant proc_call               : string                             := proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ", " & to_string(max_polls) & ", " & to_string(timeout, ns) & ")";
    constant start_time              : time                               := now;
    -- Normalise to the DUT addr/data widths
    variable v_normalised_addr       : unsigned(paddr'length - 1 downto 0) := normalize_and_check(addr_value, unsigned(paddr), ALLOW_WIDER_NARROWER, "addr_value", "paddr", msg);
    -- Helper variables
    variable v_data_value            : std_logic_vector(prdata'length - 1 downto 0);
    variable v_check_ok              : boolean;
    variable v_timeout_ok            : boolean;
    variable v_num_of_occurrences_ok : boolean;
    variable v_num_of_occurrences    : integer                            := 0;
    variable v_clk_cycles_waited     : natural                            := 0;
    variable v_config                : t_apb_bfm_config                   := config;

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
      -- Read data on APB register
      apb_read(v_normalised_addr, v_data_value, protection, "As a part of " & proc_call & ". " & add_msg_delimiter(msg), 
               pclk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr, scope, msg_id_panel, v_config); -- ID_BFM_POLL will allow the logging inside apb_read to be executed

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
  end procedure apb_poll_until;

  procedure apb_poll_until(
    constant addr_value     : in unsigned;
    constant data_exp       : in std_logic_vector;
    constant protection     : in    std_logic_vector(2 downto 0);
    constant max_polls      : in integer          := 1;
    constant timeout        : in time             := 0 ns;
    constant msg            : in string;
    signal   apb_if         : inout t_apb_if;
    signal   terminate_loop : in std_logic;
    constant alert_level    : in t_alert_level    := error;
    constant scope          : in string           := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel   := shared_msg_id_panel;
    constant config         : in t_apb_bfm_config := C_APB_BFM_CONFIG_DEFAULT
  ) is
  begin
    apb_poll_until(addr_value, data_exp, protection, max_polls, timeout, msg, apb_if.pclk, apb_if.paddr, apb_if.pprot,
                   apb_if.psel, apb_if.penable, apb_if.pwrite, apb_if.prdata, apb_if.pstrb, apb_if.pready,
                   apb_if.pslverr, terminate_loop, alert_level, scope, msg_id_panel, config);
  end procedure apb_poll_until;

end package body apb_bfm_pkg;
