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

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================

package avalon_mm_bfm_pkg is

  ----------------------------------------------------
  -- Types for Avalon BFM
  ----------------------------------------------------
  constant C_SCOPE : string := "AVALON MM BFM";

  -- Avalon Interface signals
  type t_avalon_mm_if is record
    -- Avalon MM BFM to DUT signals
    reset             : std_logic;
    address           : std_logic_vector;
    begintransfer     : std_logic;  -- optional, Altera recommends not to use
    byte_enable       : std_logic_vector;
    chipselect        : std_logic;
    write             : std_logic;
    writedata         : std_logic_vector;
    read              : std_logic;
    lock              : std_logic;

    -- Avalon MM DUT to BFM signals
    readdata          : std_logic_vector;
    response          : std_logic_vector(1 downto 0); -- Set use_response_signal to false if not in use
    waitrequest       : std_logic;
    readdatavalid     : std_logic;  -- might be used, might not.. If not used, fixed latency is a given
                                    -- (same for read and write), unless waitrequest is used.
    irq               : std_logic;
  end record;


  -- Configuration record to be assigned in the test harness.
  type t_avalon_mm_bfm_config is
  record
    max_wait_cycles           : integer;        -- Sets the maximum number of wait cycles before an alert occurs when waiting for readdatavalid or stalling because of waitrequest
    max_wait_cycles_severity  : t_alert_level;  -- The above timeout will have this severity
    clock_period              : time;           -- Period of the clock signal.
    clock_period_margin       : time;           -- Input clock period accuracy margin to specified clock_period
    clock_margin_severity     : t_alert_level;  -- The above margin will have this severity
    setup_time                : time;           -- Setup time for generated signals, set to clock_period/4
    hold_time                 : time;           -- Hold time for generated signals, set to clock_period/4
    num_wait_states_read      : natural;        -- use_waitrequest = false -> this controls the (fixed) latency for read
    num_wait_states_write     : natural;        -- use_waitrequest = false -> this controls the (fixed) latency for write
    use_waitrequest           : boolean;        -- slave uses waitrequest
    use_readdatavalid         : boolean;        -- slave uses readdatavalid (variable latency)
    use_response_signal       : boolean;        -- Whether or not to check the response signal on read
    use_begintransfer         : boolean;        -- Whether or not to assert begintransfer on start of transfer (Altera recommends not to use)
    id_for_bfm                : t_msg_id;       -- The message ID used as a general message ID in the Avalon BFM
    id_for_bfm_wait           : t_msg_id;       -- The message ID used for logging waits in the Avalon BFM
    id_for_bfm_poll           : t_msg_id;       -- The message ID used for logging polling in the Avalon BFM
  end record;

  constant C_AVALON_MM_BFM_CONFIG_DEFAULT : t_avalon_mm_bfm_config := (
    max_wait_cycles           => 10,
    max_wait_cycles_severity  => TB_FAILURE,
    clock_period              => 10 ns,
    clock_period_margin       => 0 ns,
    clock_margin_severity     => TB_ERROR,
    setup_time                => 2.5 ns,
    hold_time                 => 2.5 ns,
    num_wait_states_read      => 0,
    num_wait_states_write     => 0,
    use_waitrequest           => true,
    use_readdatavalid         => false,
    use_response_signal       => true,
    use_begintransfer         => false,
    id_for_bfm                => ID_BFM,
    id_for_bfm_wait           => ID_BFM_WAIT,
    id_for_bfm_poll           => ID_BFM_POLL
    );

    type t_avalon_mm_response_status is (OKAY, RESERVED, SLAVEERROR, DECODEERROR);

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

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
  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );

  -- avalon_mm_write with byte_enable
  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant byte_enable      : in  std_logic_vector;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );

  procedure avalon_mm_read (
    constant addr_value       : in  unsigned;
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name        : in  string                    := "avalon_mm_read"  -- overwrite if called from other procedure like avalon_mm_check
    );

  procedure avalon_mm_check (
    constant addr_value       : in  unsigned;
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant alert_level      : in  t_alert_level             := error;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );

  procedure avalon_mm_reset (
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant num_rst_cycles   : in  integer;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );

  procedure avalon_mm_read_request (
    constant addr_value       : in  unsigned;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call    : in  string                    := ""  -- External proc_call; overwrite if called from other BFM procedure like avalon_mm_check
  );

  procedure avalon_mm_read_response (
    constant addr_value       : in  unsigned;
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name        : in  string                    := "avalon_mm_read_response"  -- overwrite if called from other procedure like avalon_mm_check
  );

  procedure avalon_mm_check_response (
    constant addr_value       : in  unsigned;
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant alert_level      : in  t_alert_level             := error;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
  );

  procedure avalon_mm_lock (
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    );

  procedure avalon_mm_unlock (
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
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
                                         byte_enable((data_width/8) - 1 downto 0),
                                         writedata(data_width - 1 downto 0),
                                         readdata(data_width-1 downto 0));
  begin
    -- BFM to DUT signals
    result.reset            := '0';
    result.address          := (result.address'range => '0');
    result.begintransfer    := '0';
    result.byte_enable      := (result.byte_enable'range => '1');
    result.chipselect       := '0';
    result.write            := '0';
    result.writedata        := (result.writedata'range => '0');
    result.read             := '0';
    result.lock             := lock_value;

    -- DUT to BFM signals
    result.readdata         := (result.readdata'range => 'Z');
    result.response         := (result.response'range => 'Z');
    result.waitrequest      := 'Z';
    result.readdatavalid    := 'Z';
    result.irq              := 'Z';

    return result;
  end function;


  function to_avalon_mm_response_status(
    constant response       : in std_logic_vector(1 downto 0);
    constant scope          : in  string           := C_SCOPE;
    constant msg_id_panel   : in  t_msg_id_panel   := shared_msg_id_panel
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
  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_mm_write";
    constant proc_call : string := "avalon_mm_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "address", "avalon_mm_if.address", msg);
    variable v_normalized_data : std_logic_vector(avalon_mm_if.writedata'length-1 downto 0) :=
      normalize_and_check(data_value, avalon_mm_if.writedata, ALLOW_NARROWER, "data", "avalon_mm_if.writedata", msg);

    variable v_byte_enable : std_logic_vector((avalon_mm_if.writedata'length/8) - 1 downto 0) := (others => '1');

    variable timeout : boolean := false;

  begin
    avalon_mm_write(addr_value, data_value, msg, clk, avalon_mm_if, v_byte_enable, scope, msg_id_panel, config);
  end procedure;


  procedure avalon_mm_write (
    constant addr_value       : in  unsigned;
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant byte_enable      : in  std_logic_vector;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_mm_write";
    constant proc_call : string := "avalon_mm_write(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) &
                                   ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "address", "avalon_mm_if.address", msg);
    variable v_normalized_data : std_logic_vector(avalon_mm_if.writedata'length-1 downto 0) :=
      normalize_and_check(data_value, avalon_mm_if.writedata, ALLOW_NARROWER, "data", "avalon_mm_if.writedata", msg);

    variable v_last_rising_edge   : time    := -1 ns;  -- time stamp for clk period checking
    variable timeout              : boolean := false;
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_name);

    -- check if enough room for setup_time if clk is in low period
    if (clk = '0') and (config.setup_time > (config.clock_period/2 - clk'last_event)) then
      await_value(clk, '1', 0 ns, config.clock_period/2, TB_FAILURE, proc_name & ": timeout waiting for clk low period for setup_time.");
    end if;
    -- Wait setup_time specified in config record
    wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

    avalon_mm_if.writedata    <= v_normalized_data;
    avalon_mm_if.byte_enable  <= byte_enable;
    avalon_mm_if.write        <= '1';
    avalon_mm_if.chipselect   <= '1';
    avalon_mm_if.address      <= v_normalized_addr;

    if config.use_begintransfer then
      avalon_mm_if.begintransfer <= '1';
    end if;

    wait until rising_edge(clk);     -- wait for DUT update of signal
    v_last_rising_edge := now;      -- time stamp for clk period checking

    -- Release the begintransfer signal after one clock cycle, if waitrequest is in use
    if config.use_begintransfer then
      avalon_mm_if.begintransfer <= '0' after config.clock_period/4;
    end if;

    -- use wait request?
    if config.use_waitrequest then
      for cycle in 1 to config.max_wait_cycles loop
        if avalon_mm_if.waitrequest = '1' then
          wait until rising_edge(clk);
          -- check if clk period since last rising edge is within specifications and take a new time stamp
          check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
          v_last_rising_edge := now; -- time stamp for clk period checking
        else
          exit;
        end if;
        if cycle = config.max_wait_cycles then
          timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for waitrequest " & add_msg_delimiter(msg), scope);
      end if;

    else  -- not waitrequest. num_wait_states_write will be used as number of wait cycles in fixed wait-states
      for cycle in 1 to config.num_wait_states_write loop
        wait until rising_edge(clk);
        -- check if clk period since last rising edge is within specifications and take a new time stamp
        check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
        v_last_rising_edge := now; -- time stamp for clk period checking
      end loop;
    end if;

    -- Wait hold_time specified in config record
    wait_until_given_time_after_rising_edge(clk, config.hold_time);

    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length, avalon_mm_if.lock);

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure avalon_mm_write;


  function is_readdatavalid_active(
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant config           : in t_avalon_mm_bfm_config
  ) return boolean is
  begin
    if (config.use_readdatavalid and avalon_mm_if.readdatavalid = '1') then
      return true;
    end if;
    return false;
  end function is_readdatavalid_active;

  function is_waitrequest_active(
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant config           : in t_avalon_mm_bfm_config
  ) return boolean is
  begin
    if (config.use_waitrequest and avalon_mm_if.waitrequest = '1') then
      return true;
    end if;
    return false;
  end function is_waitrequest_active;


  procedure avalon_mm_read (
    constant addr_value       : in  unsigned;
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name        : in  string                    := "avalon_mm_read"  -- overwrite if called from other procedure like avalon_mm_check
    ) is
  begin
    avalon_mm_read_request(addr_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_name);
    avalon_mm_read_response(addr_value, data_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_name);
  end procedure avalon_mm_read;


  procedure avalon_mm_check (
    constant addr_value       : in  unsigned;
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant alert_level      : in  t_alert_level             := error;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_mm_check";
    constant proc_call : string := "avalon_mm_check(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) :=
      normalize_and_check(data_exp, avalon_mm_if.readdata, ALLOW_NARROWER, "data", "avalon_mm_if.readdata", msg);

    -- Helper variables
    variable v_data_value : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) := (others => '0');
    variable v_check_ok   : boolean;
  begin
    avalon_mm_read_request(addr_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_call);
    avalon_mm_check_response(addr_value, data_exp, msg, clk, avalon_mm_if, alert_level, scope, msg_id_panel, config);
  end procedure avalon_mm_check;


  procedure avalon_mm_reset (
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant num_rst_cycles   : in  integer;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_call : string := "avalon_mm_reset(num_rst_cycles=" & to_string(num_rst_cycles) & ")";
  begin
    log(config.id_for_bfm, proc_call & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length);
    avalon_mm_if.reset <= '1';
    for i in 1 to num_rst_cycles loop
      wait until rising_edge(clk);
    end loop;

    avalon_mm_if.reset <= '0';

    wait until rising_edge(clk);
  end procedure avalon_mm_reset;


  -- NOTE: This procedure returns as soon as the read command has been accepted. To retreive the response, use
  -- avalon_mm_read_response or avalon_mm_check_response.
  procedure avalon_mm_read_request (
    constant addr_value       : in  unsigned;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant ext_proc_call    : in  string                    := ""  -- External proc_call; overwrite if called from other BFM procedure like avalon_mm_check
  ) is
    -- local_proc_* used if called from sequencer or VVC
    constant local_proc_name          : string := "avalon_mm_read_request";
    constant local_proc_call          : string := local_proc_name & "(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";
    variable timeout                  : boolean := false;
    variable v_proc_call              : line;                           -- Current proc_call, external or local
    variable v_normalized_addr : std_logic_vector(avalon_mm_if.address'length-1 downto 0) :=
             normalize_and_check(std_logic_vector(addr_value), avalon_mm_if.address, ALLOW_NARROWER, "addr", "avalon_mm_if.address", msg);
    variable v_last_rising_edge      : time := -1 ns; -- time stamp for clk period checking
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_name);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, local_proc_name);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, local_proc_name);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, local_proc_name);

    if ext_proc_call = "" then
      -- called from sequencer/VVC, show 'avalon_mm_read_request...' in log
      write(v_proc_call, local_proc_call);
    else
      -- called from other BFM procedure like axistream_expect, log 'avalon_mm_check() while executing avalon_mm_read_request...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    -- check if enough room for setup_time in low period
    if (clk = '0') and (config.setup_time > (config.clock_period/2 - clk'last_event)) then
      await_value(clk, '1', 0 ns, config.clock_period/2, TB_FAILURE, local_proc_name & ": timeout waiting for clk low period for setup_time.");
    end if;
    -- Setup time
    wait_until_given_time_before_rising_edge(clk, config.setup_time, config.clock_period);

    -- start the read
    avalon_mm_if.address      <= v_normalized_addr;
    avalon_mm_if.read         <= '1';
    avalon_mm_if.byte_enable(avalon_mm_if.byte_enable'length - 1 downto 0) <= (others => '1');  -- always all bytes for reads
    avalon_mm_if.chipselect   <= '1';

    wait until rising_edge(clk);   -- wait for DUT update of signal
    v_last_rising_edge := now;    -- time stamp for clock_period checking

    -- Handle read with waitrequests
    if config.use_waitrequest then
      for cycle in 1 to config.max_wait_cycles loop
        if is_waitrequest_active(avalon_mm_if, config) then
          wait until rising_edge(clk);
          -- check if clk period since last rising edge is within specifications and take a new time stamp
          check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
          v_last_rising_edge := now; -- time stamp for clk period checking
        else
          exit;
        end if;
        if cycle = config.max_wait_cycles then
          timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if timeout then
        alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout waiting for waitrequest" & add_msg_delimiter(msg), scope);
      end if;

    else  -- not waitrequest - issue read, wait num_wait_states_read before finishing the read
      for cycle in 1 to config.num_wait_states_read loop
        wait until rising_edge(clk);
        -- check if clk period since last rising edge is within specifications and take a new time stamp
        check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
        v_last_rising_edge := now; -- time stamp for clk period checking
      end loop;
    end if;

    if ext_proc_call = "" then -- proc_name = "avalon_mm_read_request"
      log(ID_BFM, v_proc_call.all & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

    avalon_mm_if <= init_avalon_mm_if_signals(avalon_mm_if.address'length, avalon_mm_if.writedata'length, avalon_mm_if.lock) after config.clock_period/4;

  end procedure avalon_mm_read_request;


  procedure avalon_mm_read_response (
    constant addr_value       : in  unsigned;
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT;
    constant proc_name        : in  string                    := "avalon_mm_read_response"  -- overwrite if called from other procedure like avalon_mm_check
    ) is
    constant proc_call : string := "avalon_mm_read_response(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) :=
      normalize_and_check(data_value, avalon_mm_if.readdata, ALLOW_NARROWER, "data", "avalon_mm_if.readdata", msg);
    -- Helper variables
    variable v_last_rising_edge : time    := -1 ns;   -- time stamp for clock_period checking
    variable timeout            : boolean := false;
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_name);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_name);

    -- Handle read with readdatavalid.
    if config.use_readdatavalid then
      for cycle in 1 to config.max_wait_cycles loop
        -- Check for readdatavalid
        if is_readdatavalid_active(avalon_mm_if, config) then
          log(config.id_for_bfm, "readdatavalid was active after " & to_string(cycle) & " clock cycles", scope, msg_id_panel);
          exit;
        else
          wait until rising_edge(clk);
          -- check if clk period since last rising edge is within specifications and take a new time stamp
          if v_last_rising_edge > -1 ns then
            check_value_in_range(now - v_last_rising_edge, config.clock_period - config.clock_period_margin, config.clock_period + config.clock_period_margin, config.clock_margin_severity, "clk period not within requirement.");
          end if;
          v_last_rising_edge := now; -- take a new time stamp for clk period checking
        end if;

        if cycle = config.max_wait_cycles then
          timeout := true;
        end if;
      end loop;

      -- did we timeout?
      if timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for readdatavalid" & add_msg_delimiter(msg), scope);
      end if;
    end if;

    if config.use_response_signal = true and to_avalon_mm_response_status(avalon_mm_if.response) /= OKAY then
      error("Avalon MM read response was not OKAY, got " & to_string(avalon_mm_if.response), scope);
    end if;

    v_normalized_data := avalon_mm_if.readdata;
    data_value        := v_normalized_data(data_value'length-1 downto 0);

    -- Wait hold_time specified in config record
    wait_until_given_time_after_rising_edge(clk, config.hold_time);

    if proc_name = "avalon_mm_read_response" then
      log(config.id_for_bfm, proc_call & "=> " & to_string(data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure avalon_mm_read_response;


  procedure avalon_mm_check_response (
    constant addr_value       : in  unsigned;
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_mm_if       : in t_avalon_mm_if;
    constant alert_level      : in  t_alert_level             := error;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_mm_check_response";
    constant proc_call : string := proc_name&"(A:" & to_string(addr_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- normalize_and_check to the DUT addr/data widths
    variable v_normalized_data : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) :=
      normalize_and_check(data_exp, avalon_mm_if.readdata, ALLOW_NARROWER, "data", "avalon_mm_if.readdata", msg);

    -- Helper variables
    variable v_data_value : std_logic_vector(avalon_mm_if.readdata'length-1 downto 0) := (others => '0');
    variable v_check_ok   : boolean;
  begin

    avalon_mm_read_response(addr_value, v_data_value, msg, clk, avalon_mm_if, scope, msg_id_panel, config, proc_name);

    v_check_ok := true;
    for i in 0 to (v_normalized_data'length)-1 loop
      if v_normalized_data(i) = '-' or v_normalized_data(i) = v_data_value(i) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      alert(alert_level, proc_call & "=> Failed. slv Was " & to_string(v_data_value, HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure avalon_mm_check_response;


  procedure avalon_mm_lock (
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "avalon_mm_lock()";
  begin
    log(config.id_for_bfm, proc_call & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    avalon_mm_if.lock <= '1';
  end procedure avalon_mm_lock;


  procedure avalon_mm_unlock (
    signal avalon_mm_if       : inout t_avalon_mm_if;
    constant msg              : in  string;
    constant scope            : in  string                    := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel            := shared_msg_id_panel;
    constant config           : in  t_avalon_mm_bfm_config    := C_AVALON_MM_BFM_CONFIG_DEFAULT
  ) is
    constant proc_call : string := "avalon_mm_unlock()";
  begin
    log(config.id_for_bfm, proc_call & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    avalon_mm_if.lock <= '0';
  end procedure avalon_mm_unlock;

end package body avalon_mm_bfm_pkg;
