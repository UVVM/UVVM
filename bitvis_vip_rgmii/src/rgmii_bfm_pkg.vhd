--================================================================================================================================
-- Copyright (c) 2019 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

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
package rgmii_bfm_pkg is

  --==========================================================================================
  -- Types and constants for RGMII BFM 
  --==========================================================================================
  constant C_SCOPE : string := "RGMII BFM";

  -- Interface record for BFM signals
  type t_rgmii_if is record
    txc    : std_logic;                    -- to dut
    txd    : std_logic_vector(3 downto 0); -- to dut
    tx_ctl : std_logic;                    -- to dut
    rxc    : std_logic;                    -- from dut
    rxd    : std_logic_vector(3 downto 0); -- from dut
    rx_ctl : std_logic;                    -- from dut
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_rgmii_bfm_config is
  record
    max_wait_cycles          : integer;       -- Used for setting the maximum cycles to wait before an alert is issued when
                                              -- waiting for signals from the DUT.
    max_wait_cycles_severity : t_alert_level; -- Severity if max_wait_cycles expires.
    clock_period             : time;          -- Period of the clock signal.
    setup_time               : time;          -- Setup time for generated signals, set to clock_period/4
    hold_time                : time;          -- Hold time for generated signals, set to clock_period/4
    id_for_bfm               : t_msg_id;      -- The message ID used as a general message ID in the BFM
  end record;

  -- Define the default value for the BFM config
  constant C_RGMII_BFM_CONFIG_DEFAULT : t_rgmii_bfm_config := (
    max_wait_cycles          => 10,
    max_wait_cycles_severity => ERROR,
    clock_period             => -1 ns,
    setup_time               => -1 ns,
    hold_time                => -1 ns,
    id_for_bfm               => ID_BFM
  );

  --==========================================================================================
  -- BFM procedures 
  --==========================================================================================
  -- This function returns an RGMII interface with initialized signals.
  -- All input signals are initialized to 0
  -- All output signals are initialized to Z
  function init_rgmii_if_signals
    return t_rgmii_if;

  ---------------------------------------------------------------------------------------------
  -- RGMII Write
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure rgmii_write (
    constant data_array   : in    t_byte_array;
    constant msg          : in    string             := "";
    signal   rgmii_if     : inout t_rgmii_if;
    constant scope        : in    string             := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in    t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------------------
  -- RGMII Read
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure rgmii_read (
    variable data_array    : out   t_byte_array;
    variable data_len      : out   natural;
    constant msg           : in    string             := "";
    signal   rgmii_if      : inout t_rgmii_if;
    constant scope         : in    string             := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel     := shared_msg_id_panel;
    constant config        : in    t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string := ""  -- External proc_call. Overwrite if called from another BFM procedure
  );

  ---------------------------------------------------------------------------------------------
  -- RGMII Expect
  ---------------------------------------------------------------------------------------------
  procedure rgmii_expect (
    constant data_exp     : in    t_byte_array;
    constant msg          : in    string             := "";
    signal   rgmii_if     : inout t_rgmii_if;
    constant alert_level  : in    t_alert_level      := ERROR;
    constant scope        : in    string             := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in    t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  );

end package rgmii_bfm_pkg;


--================================================================================================================================
--================================================================================================================================
package body rgmii_bfm_pkg is

  function init_rgmii_if_signals
      return t_rgmii_if is
    variable init_if : t_rgmii_if;
  begin
    -- to dut
    init_if.txc    := 'Z';
    init_if.txd    := (init_if.txd'range => '0');
    init_if.tx_ctl := '0';
    -- from dut
    init_if.rxc    := 'Z';
    init_if.rxd    := (init_if.rxd'range => 'Z');
    init_if.rx_ctl := 'Z';
    return init_if;
  end function;

  ---------------------------------------------------------------------------------------------
  -- RGMII Write
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure rgmii_write (
    constant data_array   : in    t_byte_array;
    constant msg          : in    string             := "";
    signal   rgmii_if     : inout t_rgmii_if;
    constant scope        : in    string             := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in    t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string := "rgmii_write";
    constant proc_call : string := proc_name & "(" & to_string(data_array'length) & " bytes)";

  begin
    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.clock_period /= 0 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, proc_call);

    rgmii_if <= init_rgmii_if_signals;
    -- Start transmission during setup time
    wait_until_given_time_before_rising_edge(rgmii_if.txc, config.setup_time, config.clock_period);
    log(config.id_for_bfm, proc_call & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    -- Enable control line and send 4 bits on each clock edge
    rgmii_if.tx_ctl <= '1';
    for i in data_array'range loop
      rgmii_if.txd <= data_array(i)(3 downto 0);
      wait for config.clock_period/2;
      rgmii_if.txd <= data_array(i)(7 downto 4);
      wait for config.clock_period/2;
    end loop;

    rgmii_if <= init_rgmii_if_signals;
    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- RGMII Read
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure rgmii_read (
    variable data_array    : out   t_byte_array;
    variable data_len      : out   natural;
    constant msg           : in    string             := "";
    signal   rgmii_if      : inout t_rgmii_if;
    constant scope         : in    string             := C_SCOPE;
    constant msg_id_panel  : in    t_msg_id_panel     := shared_msg_id_panel;
    constant config        : in    t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in    string := ""  -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name  : string := "rgmii_read"; -- Internal proc_name; Used if called from sequencer or VVC
    constant local_proc_call  : string := local_proc_name & "(" & to_string(data_array'length) & " bytes)";
    variable v_proc_call : line; -- Current proc_call, external or local
    variable v_byte_cnt  : natural := 0;
    variable v_overflow  : boolean := false;
    variable v_timeout   : boolean := false;

  begin
    -- If called from sequencer/VVC, show 'rgmii_read()...' in log
    if ext_proc_call = "" then
      write(v_proc_call, local_proc_call);
    -- If called from another BFM procedure like rgmii_expect, log 'rgmii_expect() while executing rgmii_read()...'
    else
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.clock_period /= 0 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    rgmii_if <= init_rgmii_if_signals;
    -- Start reception during setup time
    wait_until_given_time_before_rising_edge(rgmii_if.rxc, config.setup_time, config.clock_period);
    log(config.id_for_bfm, v_proc_call.all & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    -- Wait for control line to be active
    for i in 0 to 2*config.max_wait_cycles-1 loop
      if rgmii_if.rx_ctl = '0' then
        wait for config.clock_period/2;
      else
        exit;
      end if;
    end loop;

    if rgmii_if.rx_ctl = '1' then
      -- Read 4 bits on each clock edge
      while rgmii_if.rx_ctl = '1' loop
        -- Check that the received data fits in the data array
        if v_byte_cnt > data_array'length-1 then
          v_overflow := true;
          exit;
        end if;
        data_array(v_byte_cnt)(3 downto 0) := rgmii_if.rxd;
        wait for config.clock_period/2;
        data_array(v_byte_cnt)(7 downto 4) := rgmii_if.rxd;
        wait for config.clock_period/2;
        v_byte_cnt := v_byte_cnt + 1;
      end loop;
    else
      v_timeout := true;
    end if;
    data_len := v_byte_cnt;

    rgmii_if <= init_rgmii_if_signals;
    if v_overflow then
      alert(TB_ERROR, v_proc_call.all & "=> Failed. Received more bytes than data_array size. " & add_msg_delimiter(msg), scope);
    elsif v_timeout then
      alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout while waiting for control line. " & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, v_proc_call.all & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- RGMII Expect
  ---------------------------------------------------------------------------------------------
  procedure rgmii_expect (
    constant data_exp     : in    t_byte_array;
    constant msg          : in    string             := "";
    signal   rgmii_if     : inout t_rgmii_if;
    constant alert_level  : in    t_alert_level      := ERROR;
    constant scope        : in    string             := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in    t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string := "rgmii_expect";
    constant proc_call : string := proc_name & "(" & to_string(data_exp'length) & " bytes)";
    variable v_rx_data_array    : t_byte_array(data_exp'range);
    variable v_rx_data_len      : natural;
    variable v_length_error     : boolean := false;
    variable v_data_error_cnt   : natural := 0;
    variable v_first_wrong_byte : natural;

  begin
    -- Read data
    rgmii_read(v_rx_data_array, v_rx_data_len, msg, rgmii_if, scope, msg_id_panel, config, proc_call);

    -- Check the length of the received data
    if v_rx_data_len /= data_exp'length then
      v_length_error := true;
    end if;

    -- Check if each received bit matches the expected.
    -- Report the first wrong byte (iterate from the last to the first)
    for byte in v_rx_data_array'high downto 0 loop
      for i in v_rx_data_array(byte)'range loop
        -- Expected set to don't care or received value matches expected
        if (data_exp(byte)(i) = '-') or (v_rx_data_array(byte)(i) = data_exp(byte)(i)) then
          -- Check is OK
        else
          -- Received byte doesn't match
          v_data_error_cnt   := v_data_error_cnt + 1;
          v_first_wrong_byte := byte;
        end if;
      end loop;
    end loop;

    -- Done. Report result
    if v_data_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_data_error_cnt) & " data bits. First mismatch in byte# " &
        to_string(v_first_wrong_byte) & ". Was " & to_string(v_rx_data_array(v_first_wrong_byte), HEX, AS_IS, INCL_RADIX) &
        ". Expected " & to_string(data_exp(v_first_wrong_byte), HEX, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
    elsif v_length_error then
      alert(alert_level, proc_call & "=> Failed. Mismatch in received data length. Was " & to_string(v_rx_data_len) &
        ". Expected " & to_string(data_exp'length) & "." & LF & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & " bytes. " &
        add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

end package body rgmii_bfm_pkg;