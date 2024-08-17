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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--================================================================================================================================
--================================================================================================================================
package rgmii_bfm_pkg is

  --==========================================================================================
  -- Types and constants for RGMII BFM
  --==========================================================================================
  constant C_BFM_SCOPE : string := "RGMII BFM";

  -- Interface record for BFM signals to DUT
  type t_rgmii_tx_if is record
    txc    : std_logic;
    txd    : std_logic_vector(3 downto 0);
    tx_ctl : std_logic;
  end record;
  -- Interface record for BFM signals from DUT
  type t_rgmii_rx_if is record
    rxc    : std_logic;
    rxd    : std_logic_vector(3 downto 0);
    rx_ctl : std_logic;
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_rgmii_bfm_config is record
    max_wait_cycles                : integer; -- Used for setting the maximum cycles to wait before an alert is issued when
                                              -- waiting for signals from the DUT.
    max_wait_cycles_severity       : t_alert_level; -- Severity if max_wait_cycles expires.
    clock_period                   : time;    -- Period of the clock signal.
    rx_clock_skew                  : time;    -- Skew of the sampling of the data in connection to the RX clock edges
    match_strictness               : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm                     : t_msg_id; -- The message ID used as a general message ID in the BFM
    data_valid_on_both_clock_edges : boolean;  -- Data is valid on both edges of the clock. Set this to true for 1 Gbps, and false for 10/100 Mbps.
  end record;

  -- Define the default value for the BFM config
  constant C_RGMII_BFM_CONFIG_DEFAULT : t_rgmii_bfm_config := (
    max_wait_cycles                => 10,
    max_wait_cycles_severity       => ERROR,
    clock_period                   => -1 ns,
    rx_clock_skew                  => -1 ns,
    match_strictness               => MATCH_EXACT,
    id_for_bfm                     => ID_BFM,
    data_valid_on_both_clock_edges => true -- Default 1 Gbps
  );

  --==========================================================================================
  -- BFM procedures
  --==========================================================================================
  -- This function returns an RGMII interface with initialized signals.
  -- All BFM output signals are initialized to 0
  -- All BFM input signals are initialized to Z
  function init_rgmii_if_signals
  return t_rgmii_tx_if;

  function init_rgmii_if_signals
  return t_rgmii_rx_if;

  ---------------------------------------------------------------------------------------------
  -- RGMII Write
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure rgmii_write(
    constant data_array   : in t_byte_array;
    constant msg          : in string             := "";
    signal   rgmii_tx_if  : inout t_rgmii_tx_if;
    constant scope        : in string             := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  );

  procedure rgmii_write(
    constant data_array                   : in t_byte_array;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done;
    constant msg                          : in string             := "";
    signal   rgmii_tx_if                  : inout t_rgmii_tx_if;
    constant scope                        : in string             := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel     := shared_msg_id_panel;
    constant config                       : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  );

  ---------------------------------------------------------------------------------------------
  -- RGMII Read
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure rgmii_read(
    variable data_array    : out t_byte_array;
    variable data_len      : out natural;
    constant msg           : in string             := "";
    signal   rgmii_rx_if   : inout t_rgmii_rx_if;
    constant scope         : in string             := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel     := shared_msg_id_panel;
    constant config        : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string             := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ---------------------------------------------------------------------------------------------
  -- RGMII Expect
  ---------------------------------------------------------------------------------------------
  procedure rgmii_expect(
    constant data_exp     : in t_byte_array;
    constant msg          : in string             := "";
    signal   rgmii_rx_if  : inout t_rgmii_rx_if;
    constant alert_level  : in t_alert_level      := ERROR;
    constant scope        : in string             := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  );

end package rgmii_bfm_pkg;

--================================================================================================================================
--================================================================================================================================
package body rgmii_bfm_pkg is

  function init_rgmii_if_signals
  return t_rgmii_tx_if is
    variable init_if : t_rgmii_tx_if;
  begin
    init_if.txc    := 'Z';
    init_if.txd    := (init_if.txd'range => '0');
    init_if.tx_ctl := '0';
    return init_if;
  end function;

  function init_rgmii_if_signals
  return t_rgmii_rx_if is
    variable init_if : t_rgmii_rx_if;
  begin
    init_if.rxc    := 'Z';
    init_if.rxd    := (init_if.rxd'range => 'Z');
    init_if.rx_ctl := 'Z';
    return init_if;
  end function;

  ---------------------------------------------------------------------------------------------
  -- RGMII Write
  -- BFM -> DUT
  ---------------------------------------------------------------------------------------------
  procedure rgmii_write(
    constant data_array   : in t_byte_array;
    constant msg          : in string             := "";
    signal   rgmii_tx_if  : inout t_rgmii_tx_if;
    constant scope        : in string             := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  ) is
  begin
    rgmii_write(data_array, RELEASE_LINE_AFTER_TRANSFER, msg, rgmii_tx_if, scope, msg_id_panel, config);
  end procedure;

  procedure rgmii_write(
    constant data_array                   : in t_byte_array;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done;
    constant msg                          : in string             := "";
    signal   rgmii_tx_if                  : inout t_rgmii_tx_if;
    constant scope                        : in string             := C_BFM_SCOPE;
    constant msg_id_panel                 : in t_msg_id_panel     := shared_msg_id_panel;
    constant config                       : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name : string  := "rgmii_write";
    constant proc_call : string  := proc_name & "(" & to_string(data_array'length) & " bytes)";
    variable v_timeout : boolean := false;

  begin
    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);

    rgmii_tx_if.txc <= 'Z';
    log(config.id_for_bfm, proc_call & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);
    -- Wait for the first rising edge to enable the control line
    wait until rising_edge(rgmii_tx_if.txc) for config.clock_period * config.max_wait_cycles;
    if rgmii_tx_if.txc = '1' then
      rgmii_tx_if.tx_ctl <= '1';
      -- Send 4 data bits on each clock edge
      for i in data_array'range loop
        rgmii_tx_if.txd <= data_array(i)(3 downto 0);
        wait until falling_edge(rgmii_tx_if.txc);

        if config.data_valid_on_both_clock_edges then
          -- 1 Gbps
          rgmii_tx_if.txd <= data_array(i)(7 downto 4);
        else -- not config.data_valid_on_both_clock_edges
          -- 10/100 Mbps
          wait until rising_edge(rgmii_tx_if.txc);
          rgmii_tx_if.txd <= data_array(i)(7 downto 4);
          wait until falling_edge(rgmii_tx_if.txc);
        end if; -- config.data_valid_on_both_clock_edges

        if i < data_array'high then
          -- Wait for the next rising edge to send the next byte
          wait until rising_edge(rgmii_tx_if.txc);
          rgmii_tx_if.tx_ctl <= '1';
        else
          -- Last byte sent, release the control line
          if action_when_transfer_is_done = RELEASE_LINE_AFTER_TRANSFER then
            wait until rising_edge(rgmii_tx_if.txc);
            rgmii_tx_if <= init_rgmii_if_signals;
          end if;
          -- else: Keep the control line active, and next byte is held until next rgmii_write (first rising edge in this procedure)
        end if;
      end loop;
    else
      v_timeout := true;
    end if;

    if v_timeout then
      alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout while waiting for txc. " & add_msg_delimiter(msg), scope);
    else
      log(config.id_for_bfm, proc_call & " DONE. " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- RGMII Read
  -- DUT -> BFM
  ---------------------------------------------------------------------------------------------
  procedure rgmii_read(
    variable data_array    : out t_byte_array;
    variable data_len      : out natural;
    constant msg           : in string             := "";
    signal   rgmii_rx_if   : inout t_rgmii_rx_if;
    constant scope         : in string             := C_BFM_SCOPE;
    constant msg_id_panel  : in t_msg_id_panel     := shared_msg_id_panel;
    constant config        : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT;
    constant ext_proc_call : in string             := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant local_proc_name   : string  := "rgmii_read"; -- Internal proc_name; Used if called from sequencer or VVC
    constant local_proc_call   : string  := local_proc_name & "(" & to_string(data_array'length) & " bytes)";
    variable v_proc_call       : line;  -- Current proc_call, external or local
    variable v_normalized_data : t_byte_array(0 to data_array'length - 1);
    variable v_byte_cnt        : natural := 0;
    variable v_done            : boolean := false;
    variable v_timeout         : boolean := false;
    variable v_wait_cycles     : natural := 0;

  begin
    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'rgmii_read...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing rgmii_read...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
    end if;

    check_value(data_array'ascending, TB_FAILURE, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.clock_period > -1 ns, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);
    check_value(config.rx_clock_skew > -1 ns, TB_FAILURE, "Sanity check: Check that rx_clock_skew is set.", scope, ID_NEVER, msg_id_panel, v_proc_call.all);

    rgmii_rx_if <= init_rgmii_if_signals;
    log(config.id_for_bfm, v_proc_call.all & "=> " & add_msg_delimiter(msg), scope, msg_id_panel);

    -- Wait for the first rising edge
    if rgmii_rx_if.rxc /= '1' then
      wait until rising_edge(rgmii_rx_if.rxc) for config.clock_period * config.max_wait_cycles;
    end if;

    -- Sample the data using the RX clock edges and a skew
    if rgmii_rx_if.rxc = '1' then
      wait for config.rx_clock_skew;

      -- Wait for control line to be active
      while rgmii_rx_if.rx_ctl /= '1' and v_wait_cycles < config.max_wait_cycles loop
        wait until rising_edge(rgmii_rx_if.rxc);
        wait for config.rx_clock_skew;
        v_wait_cycles := v_wait_cycles + 1;
      end loop;
      if rgmii_rx_if.rx_ctl /= '1' then
        v_timeout := true;
      end if;

      -- Sample the data
      while not (v_done) loop
        if rgmii_rx_if.rx_ctl = '1' then
          v_normalized_data(v_byte_cnt)(3 downto 0) := rgmii_rx_if.rxd;
          wait until falling_edge(rgmii_rx_if.rxc);

          if config.data_valid_on_both_clock_edges then
            -- 1 Gbps
            wait for config.rx_clock_skew;
            v_normalized_data(v_byte_cnt)(7 downto 4) := rgmii_rx_if.rxd;
          else -- not config.data_valid_on_both_clock_edges
            -- 10/100 Mbps
            wait until rising_edge(rgmii_rx_if.rxc);
            wait for config.rx_clock_skew;
            v_normalized_data(v_byte_cnt)(7 downto 4) := rgmii_rx_if.rxd;
            wait until falling_edge(rgmii_rx_if.rxc);
          end if; -- config.data_valid_on_both_clock_edges

          if v_byte_cnt = v_normalized_data'length - 1 then
            v_done := true;
          else
            wait until rising_edge(rgmii_rx_if.rxc);
            wait for config.rx_clock_skew;
          end if;
          v_byte_cnt := v_byte_cnt + 1;
        else
          -- Data valid went low
          v_done := true;
        end if;
      end loop;
    else
      v_timeout := true;
    end if;

    data_array := v_normalized_data;
    data_len   := v_byte_cnt;

    wait until rising_edge(rgmii_rx_if.rxc); -- Wait until rising edge so that the procedure exits after the interface is idle

    if v_timeout then
      alert(config.max_wait_cycles_severity, v_proc_call.all & "=> Failed. Timeout while waiting for rxc or rx_ctl. " & add_msg_delimiter(msg), scope);
    else
      if ext_proc_call = "" then
        log(config.id_for_bfm, v_proc_call.all & " DONE. " & add_msg_delimiter(msg), scope, msg_id_panel);
      else
      -- Log will be handled by calling procedure (e.g. rgmii_expect)
      end if;
    end if;

    DEALLOCATE(v_proc_call);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- RGMII Expect
  ---------------------------------------------------------------------------------------------
  procedure rgmii_expect(
    constant data_exp     : in t_byte_array;
    constant msg          : in string             := "";
    signal   rgmii_rx_if  : inout t_rgmii_rx_if;
    constant alert_level  : in t_alert_level      := ERROR;
    constant scope        : in string             := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel     := shared_msg_id_panel;
    constant config       : in t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT
  ) is
    constant proc_name          : string                                 := "rgmii_expect";
    constant proc_call          : string                                 := proc_name & "(" & to_string(data_exp'length) & " bytes)";
    variable v_normalized_data  : t_byte_array(0 to data_exp'length - 1) := data_exp;
    variable v_rx_data_array    : t_byte_array(v_normalized_data'range);
    variable v_rx_data_len      : natural;
    variable v_length_error     : boolean                                := false;
    variable v_data_error_cnt   : natural                                := 0;
    variable v_first_wrong_byte : natural;
    variable v_alert_radix      : t_radix;
  begin

    check_value(data_exp'ascending, TB_FAILURE, "Sanity check: Check that data_exp is ascending (defined with 'to'), for byte order clarity.", scope, ID_NEVER, msg_id_panel, proc_call);

    -- Read data
    rgmii_read(v_rx_data_array, v_rx_data_len, msg, rgmii_rx_if, scope, msg_id_panel, config, proc_call);

    -- Check the length of the received data
    if v_rx_data_len /= v_normalized_data'length then
      v_length_error := true;
    end if;

    -- Check if each received bit matches the expected.
    -- Report the first wrong byte (iterate from the last to the first)
    for byte in v_rx_data_array'high downto 0 loop
      for i in v_rx_data_array(byte)'range loop
        -- Allow don't care in expected value and use match strictness from config for comparison
        if v_normalized_data(byte)(i) = '-' or check_value(v_rx_data_array(byte)(i), v_normalized_data(byte)(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
        -- Check is OK
        else
          -- Received byte doesn't match
          v_data_error_cnt   := v_data_error_cnt + 1;
          v_first_wrong_byte := byte;
        end if;
      end loop;
    end loop;

    -- Done. Report result
    if C_ERROR_REPORT_EXTENT = EXTENDED then
        if v_length_error then
          alert(alert_level, proc_call & "=> Failed. Mismatch in received data length. Was " & to_string(v_rx_data_len) & ". Expected " & to_string(v_normalized_data'length) & "." & LF 
            & add_msg_delimiter(msg), scope);
        elsif v_data_error_cnt /= 0 then
          -- Use binary representation when mismatch is due to weak signals
          v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_data_array(v_first_wrong_byte), v_normalized_data(v_first_wrong_byte), MATCH_STD, 
            NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
          alert(alert_level, proc_call & "=> Failed in " & to_string(v_data_error_cnt) & " data bits. First mismatch in byte# " & to_string(v_first_wrong_byte+1) & ". Was " & 
            to_string(v_rx_data_array(v_first_wrong_byte), v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data(v_first_wrong_byte), 
            v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & "Was:" & LF & to_string(v_rx_data_array, v_alert_radix, AS_IS) & LF &"Expected:" & LF & 
            to_string(v_normalized_data, v_alert_radix, AS_IS) & LF & add_msg_delimiter(msg), scope);
        else
          log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & " bytes. " & add_msg_delimiter(msg), scope, msg_id_panel);
        end if;
    elsif C_ERROR_REPORT_EXTENT = BRIEF then
        if v_length_error then
          alert(alert_level, proc_call & "=> Failed. Mismatch in received data length. Was " & to_string(v_rx_data_len) & ". Expected " & to_string(v_normalized_data'length) & "." & LF 
            & add_msg_delimiter(msg), scope);
        elsif v_data_error_cnt /= 0 then
          -- Use binary representation when mismatch is due to weak signals
          v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_rx_data_array(v_first_wrong_byte), v_normalized_data(v_first_wrong_byte), MATCH_STD, 
            NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
          alert(alert_level, proc_call & "=> Failed in " & to_string(v_data_error_cnt) & " data bits. First mismatch in byte# " & to_string(v_first_wrong_byte+1) & ". Was " & 
            to_string(v_rx_data_array(v_first_wrong_byte), v_alert_radix, AS_IS, INCL_RADIX) & ". Expected " & to_string(v_normalized_data(v_first_wrong_byte),
            v_alert_radix, AS_IS, INCL_RADIX) & "." & LF & add_msg_delimiter(msg), scope);
        else
          log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & " bytes. " & add_msg_delimiter(msg), scope, msg_id_panel);
        end if;
    end if;
  end procedure;

end package body rgmii_bfm_pkg;
