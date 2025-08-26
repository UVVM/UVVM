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
--
-- NOTE: This BFM is only intended as a simplified UART BFM to be used as a test
--       vehicle for presenting UVVM functionality.
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--=================================================================================================
package uart_bfm_pkg is

  --===============================================================================================
  -- Types and constants for UART BFMs
  --===============================================================================================

  constant C_BFM_SCOPE : string := "UART BFM";

  constant C_DATA_MAX_LENGTH                       : natural := 8;
  constant C_EXPECT_RECEIVED_DATA_STRING_SEPARATOR : string  := "; ";
  type uart_expect_received_data_array is array (natural range <>) of std_logic_vector(C_DATA_MAX_LENGTH - 1 downto 0);

  type t_bfm_error_injection is record
    parity_bit_error : boolean;
    stop_bit_error   : boolean;
  end record t_bfm_error_injection;

  constant C_BFM_ERROR_INJECTION_INACTIVE : t_bfm_error_injection := (
    parity_bit_error => false,
    stop_bit_error   => false
  );

  type t_uart_bfm_config is record
    bit_time                              : time; -- The time it takes to transfer one bit
    num_data_bits                         : natural range 7 to 8; -- Number of data bits to send per transmission
    idle_state                            : std_logic; -- Bit value when line is idle
    num_stop_bits                         : t_stop_bits; -- Number of stop-bits to use per transmission {STOP_BITS_ONE, STOP_BITS_ONE_AND_HALF, STOP_BITS_TWO}
    parity                                : t_parity; -- Transmission parity bit {PARITY_NONE, PARITY_ODD, PARITY_EVEN}
    timeout                               : time; -- The maximum time to pass before the expected data must be received. Exceeding this limit results in an alert with severity ‘alert_level’.
    timeout_severity                      : t_alert_level; -- The above timeout will have this severity
    num_bytes_to_log_before_expected_data : natural; -- Maximum number of bytes to save ahead of the expected data in the receive buffer. The bytes in the receive buffer will be logged.
    match_strictness                      : t_match_strictness; -- Matching strictness for std_logic values in check procedures.
    id_for_bfm                            : t_msg_id; -- The message ID used as a general message ID in the UART BFM
    id_for_bfm_wait                       : t_msg_id; -- The message ID used for logging waits in the UART BFM
    id_for_bfm_poll                       : t_msg_id; -- The message ID used for logging polling in the UART BFM -- DEPRECATE: will be removed
    id_for_bfm_poll_summary               : t_msg_id; -- The message ID used for logging polling summary in the UART BFM
    error_injection                       : t_bfm_error_injection;
  end record;

  constant C_UART_BFM_CONFIG_DEFAULT : t_uart_bfm_config := (
    bit_time                              => -1 ns,
    num_data_bits                         => 8,
    idle_state                            => '1',
    num_stop_bits                         => STOP_BITS_ONE,
    parity                                => PARITY_ODD,
    timeout                               => 0 ns, -- will default never time out
    timeout_severity                      => error,
    num_bytes_to_log_before_expected_data => 10,
    match_strictness                      => MATCH_EXACT,
    id_for_bfm                            => ID_BFM,
    id_for_bfm_wait                       => ID_BFM_WAIT,
    id_for_bfm_poll                       => ID_BFM_POLL,
    id_for_bfm_poll_summary               => ID_BFM_POLL_SUMMARY,
    error_injection                       => C_BFM_ERROR_INJECTION_INACTIVE
  );

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  ------------------------------------------
  -- uart_transmit
  ------------------------------------------
  -- - This procedure transmits data 'data_value' to the UART DUT
  -- - The TX configuration can be set in the config parameter
  procedure uart_transmit(
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   tx           : inout std_logic;
    constant config       : in t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel
  );

  ------------------------------------------
  -- uart_receive
  ------------------------------------------
  -- - This procedure reads data from the UART DUT and returns it in 'data_value'
  -- - The RX configuration can be set in the config parameter
  procedure uart_receive(
    variable data_value     : out std_logic_vector;
    constant msg            : in string;
    signal   rx             : in std_logic;
    signal   terminate_loop : in std_logic;
    constant config         : in t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant ext_proc_call  : in string            := "" -- External proc_call. Overwrite if called from another BFM procedure
  );

  ------------------------------------------
  -- uart_expect
  ------------------------------------------
  -- - This procedure reads data from the UART DUT and compares it to the data in
  --   'data_exp'.
  -- - If the read data is inconsistent with the 'data_exp' data, a new read will
  --   be performed, and the new read data will be compared with 'data_exp'.
  --   This process will continue untill one of the following conditions are met:
  --     a) The read data is equal to the expected data
  --     b) The number of reads equal 'max_receptions'
  --     c) The time spent reading is equal to the 'timeout'
  -- - If 'timeout' is set to 0, it will be interpreted as no timeout
  -- - If 'max_receptions' is set to 0, it will be interpreted as no limitation on number of reads
  -- - The RX configuration can be set in the config parameter
  procedure uart_expect(
    constant data_exp       : in std_logic_vector;
    constant msg            : in string;
    signal   rx             : in std_logic;
    signal   terminate_loop : in std_logic;
    constant max_receptions : in natural           := 1;
    constant timeout        : in time              := -1 ns;
    constant alert_level    : in t_alert_level     := ERROR;
    constant config         : in t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel
  );

  ------------------------------------------
  -- odd_parity
  ------------------------------------------
  -- - This function checks if the data parity is odd or even
  -- - If the number of '1' in the 'data' input is odd, '1' will be returned
  -- - If the number of '1' in the 'data' input is even, '0' will be returned
  function odd_parity(
    constant data : std_logic_vector)
  return std_logic;

end package uart_bfm_pkg;

--=================================================================================================
--=================================================================================================

package body uart_bfm_pkg is

  function odd_parity(
    constant data : std_logic_vector)
  return std_logic is
  begin
    return xnor(data);
  end odd_parity;

  ---------------------------------------------------------------------------------
  -- uart_transmit
  ---------------------------------------------------------------------------------
  procedure uart_transmit(
    constant data_value   : in std_logic_vector;
    constant msg          : in string;
    signal   tx           : inout std_logic;
    constant config       : in t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope        : in string            := C_BFM_SCOPE;
    constant msg_id_panel : in t_msg_id_panel    := shared_msg_id_panel
  ) is
    constant proc_name : string := "uart_transmit";
    constant proc_call : string := proc_name & "(" & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";

    variable v_data_value      : std_logic_vector(config.num_data_bits - 1 downto 0);
    variable v_normalized_data : std_logic_vector(config.num_data_bits - 1 downto 0) := normalize_and_check(data_value, v_data_value, ALLOW_WIDER_NARROWER, "data_value", "v_data_value", "Normalize data_value");

    alias stop_bit_error is config.error_injection.stop_bit_error;
    alias parity_bit_error is config.error_injection.parity_bit_error;

  begin
    -- check whether config.bit_time was set probably
    check_value(config.bit_time /= -1 ns, TB_ERROR, "UART Bit time was not set in config. " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);
    check_value(data_value'length = config.num_data_bits, FAILURE, "length of data_value does not match config.num_data_bits. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    -- check if tx line was idle when trying to transmit data
    check_value(tx, config.idle_state, FAILURE, proc_call & " Bus was active when trying to send data. " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);

    tx <= not config.idle_state;
    wait for config.bit_time;

    for j in v_normalized_data'low to v_normalized_data'high loop
      tx <= v_normalized_data(j);
      wait for config.bit_time;
    end loop;

    -- Set parity bit
    if (config.parity = PARITY_ODD) then
      tx <= odd_parity(v_normalized_data);
    elsif (config.parity = PARITY_EVEN) then
      tx <= not (odd_parity(v_normalized_data));
    end if;

    -- Invert parity bit if error injection is requested
    if parity_bit_error = true then
      if (config.parity = PARITY_ODD) then
        tx <= not (odd_parity(v_normalized_data));
      elsif (config.parity = PARITY_EVEN) then
        tx <= odd_parity(v_normalized_data);
      end if;
    end if;

    if (config.parity /= PARITY_NONE) then
      wait for config.bit_time;
    end if;

    -- Set stop bits
    if stop_bit_error = false then
      tx <= config.idle_state;
    else
      -- Invert stop bit if error injection is requested
      tx <= not (config.idle_state);
      --Will return to idle/normal stop bit after 1 bit time
      tx <= transport config.idle_state after config.bit_time;
    end if;

    wait for config.bit_time;
    if (config.num_stop_bits = STOP_BITS_ONE_AND_HALF) then
      wait for config.bit_time / 2;
    elsif (config.num_stop_bits = STOP_BITS_TWO) then
      wait for config.bit_time;
    end if;

    log(config.id_for_bfm, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------
  -- uart_receive
  ---------------------------------------------------------------------------------
  -- Perform a receive operation
  procedure uart_receive(
    variable data_value     : out std_logic_vector;
    constant msg            : in string;
    signal   rx             : in std_logic;
    signal   terminate_loop : in std_logic;
    constant config         : in t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel;
    constant ext_proc_call  : in string            := "" -- External proc_call. Overwrite if called from another BFM procedure
  ) is
    constant start_time : time := now;

    -- local_proc_* used if uart_receive is called directly from sequencer or VVC
    constant local_proc_name : string := "uart_receive";
    constant local_proc_call : string := local_proc_name & "()";

    -- Helper variables
    variable v_transfer_time  : time;
    variable v_proc_call      : line;   -- Current proc_call, external or internal
    variable v_remaining_time : time;   -- temp variable to calculate the remaining time before timeout
    variable v_data_value     : std_logic_vector(config.num_data_bits - 1 downto 0);
    variable v_terminated     : boolean := false;
    variable v_timeout        : boolean := false;
  begin
    -- check whether config.bit_time was set properly
    check_value(config.bit_time /= -1 ns, TB_ERROR, "UART Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    data_value := (data_value'range => 'X');
    check_value(data_value'length = config.num_data_bits, FAILURE, "length of data_value does not match config.num_data_bits. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    -- If timeout enabled, check that timeout is longer than transfer time
    if config.timeout /= 0 ns then
      v_transfer_time := (config.num_data_bits + 2) * config.bit_time;
      if config.parity = PARITY_ODD or config.parity = PARITY_EVEN then
        v_transfer_time := v_transfer_time + config.bit_time;
      end if;
      if config.num_stop_bits = STOP_BITS_ONE_AND_HALF then
        v_transfer_time := v_transfer_time + config.bit_time / 2;
      elsif config.num_stop_bits = STOP_BITS_TWO then
        v_transfer_time := v_transfer_time + config.bit_time;
      end if;
      check_value(v_transfer_time < config.timeout, TB_ERROR, "Length of timeout is shorter than or equal length of transfer time.", C_BFM_SCOPE, ID_NEVER, msg_id_panel);
    end if;

    if ext_proc_call = "" then
      -- Called directly from sequencer/VVC, log 'uart_receive...'
      write(v_proc_call, local_proc_call);
    else
      -- Called from another BFM procedure, log 'ext_proc_call while executing uart_receive...'
      write(v_proc_call, ext_proc_call & " while executing " & local_proc_name & ". ");
    end if;

    -- check if bus is in idle state
    check_value(rx, config.idle_state, FAILURE, v_proc_call.all & "Bus was active when trying to receive data. " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);

    -- wait until the start bit is sent on the bus, configured timeout occures or procedure get terminate signal
    if config.timeout = 0 ns then
      wait until (rx = not config.idle_state) or (terminate_loop = '1');
    else
      wait until (rx = not config.idle_state) or (terminate_loop = '1') for config.timeout;
    end if;

    if terminate_loop = '1' then
      if ext_proc_call = "" then
        log(ID_TERMINATE_CMD, v_proc_call.all & "=> terminated." & add_msg_delimiter(msg), scope, msg_id_panel);
      else
      -- termination handled in calling procedure
      end if;
      v_terminated := true;
    end if;

    -- if configured timeout, check if there is enough time remaining to receive the byte
    if config.timeout /= 0 ns and not v_terminated then
      v_remaining_time := (config.num_data_bits + 2) * config.bit_time;
      if config.parity = PARITY_ODD or config.parity = PARITY_EVEN then
        v_remaining_time := v_remaining_time + config.bit_time;
      end if;
      if config.num_stop_bits = STOP_BITS_ONE_AND_HALF then
        v_remaining_time := v_remaining_time + config.bit_time / 2;
      elsif config.num_stop_bits = STOP_BITS_TWO then
        v_remaining_time := v_remaining_time + config.bit_time;
      end if;
      if now + v_remaining_time > start_time + config.timeout then
        -- wait until timeout
        wait for ((start_time + config.timeout) - now);
        if ext_proc_call = "" then
          alert(config.timeout_severity, v_proc_call.all & "=> timeout. " & add_msg_delimiter(msg), scope);
        else
        -- timeout handled in upper module
        end if;
        v_timeout := true;
      end if;
    end if;

    if not v_terminated and not v_timeout then
      -- enter the middle of the bit period
      wait for config.bit_time / 2;
      check_value(rx, not config.idle_state, FAILURE, v_proc_call.all & " Start bit was not stable during receiving. " & add_msg_delimiter(msg), scope, ID_NEVER, msg_id_panel);
      -- wait for data bit
      wait for config.bit_time;
      -- sample the data bits
      for i in 0 to config.num_data_bits - 1 loop
        v_data_value(i) := rx;
        -- wait for middle of the next bit
        wait for config.bit_time;
      end loop;

      -- check parity, if enabled
      if config.parity = PARITY_ODD then
        if rx /= odd_parity(v_data_value) then
          alert(error, v_proc_call.all & "=> Failed. Incorrect parity received. " & add_msg_delimiter(msg), scope);
        end if;
        wait for config.bit_time;
      elsif config.parity = PARITY_EVEN then
        if rx /= not odd_parity(v_data_value) then
          alert(error, v_proc_call.all & "=> Failed. Incorrect parity received. " & add_msg_delimiter(msg), scope);
        end if;
        wait for config.bit_time;
      end if;

      -- check the stop bit
      if rx /= config.idle_state then
        alert(error, v_proc_call.all & "=> Failed. Incorrect stop bit received. " & add_msg_delimiter(msg), scope);
      end if;

      if config.num_stop_bits = STOP_BITS_ONE_AND_HALF then
        wait for config.bit_time / 2 + config.bit_time / 4; -- middle of the last half. Last half of previous stop bit + first half of current stop bit
        if rx /= config.idle_state then
          alert(error, v_proc_call.all & "=> Failed. Incorrect second half stop bit received. " & add_msg_delimiter(msg), scope);
        end if;
      elsif config.num_stop_bits = STOP_BITS_TWO then
        wait for config.bit_time;       -- middle of the last bit. Last half of previous stop bit + first half of current stop bit
        if rx /= config.idle_state then
          alert(error, v_proc_call.all & "=> Failed. Incorrect second stop bit received. " & add_msg_delimiter(msg), scope);
        end if;
      end if;

      -- return the received data
      data_value := v_data_value;
      if ext_proc_call = "" then
        log(config.id_for_bfm, v_proc_call.all & "=> " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      else
      -- Log will be handled by calling procedure (e.g. uart_expect)
      end if;
    end if;

    DEALLOCATE(v_proc_call);
  end procedure;

  ----------------------------------------------------------------------------------------
  -- uart_expect
  ----------------------------------------------------------------------------------------
  -- Perform a receive operation, then compare the received value to the expected value.
  procedure uart_expect(
    constant data_exp       : in std_logic_vector;
    constant msg            : in string;
    signal   rx             : in std_logic;
    signal   terminate_loop : in std_logic;
    constant max_receptions : in natural           := 1; -- 0 = any occurrence before timeout
    constant timeout        : in time              := -1 ns;
    constant alert_level    : in t_alert_level     := ERROR;
    constant config         : in t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope          : in string            := C_BFM_SCOPE;
    constant msg_id_panel   : in t_msg_id_panel    := shared_msg_id_panel
  ) is
    constant proc_name                      : string                                                                                   := "uart_expect";
    constant proc_call                      : string                                                                                   := proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    constant start_time                     : time                                                                                     := now;
    variable v_data_value                   : std_logic_vector(config.num_data_bits - 1 downto 0);
    variable v_normalized_data              : std_logic_vector(config.num_data_bits - 1 downto 0)                                      := normalize_and_check(data_exp, v_data_value, ALLOW_WIDER_NARROWER, "data_exp", "v_data_value", "Normalize data_exp");
    variable v_num_of_occurrences           : natural                                                                                  := 0;
    variable v_check_ok                     : boolean;
    variable v_num_of_occurrences_ok        : boolean;
    variable v_timeout_ok                   : boolean;
    variable v_config                       : t_uart_bfm_config                                                                        := config;
    variable v_received_data_fifo           : uart_expect_received_data_array(0 to v_config.num_bytes_to_log_before_expected_data - 1) := (others => (others => '0'));
    variable v_received_data_fifo_write_idx : natural                                                                                  := 0;
    variable v_received_output_line         : line;
    variable v_internal_timeout             : time;
    variable v_alert_radix                  : t_radix;
  begin
    -- check whether config.bit_time was set probably
    check_value(config.bit_time /= -1 ns, TB_ERROR, "UART Bit time was not set in config. " & add_msg_delimiter(msg), C_BFM_SCOPE, ID_NEVER, msg_id_panel);

    -- if timeout = -1 function was called without parameter
    if timeout = -1 ns then
      v_internal_timeout := config.timeout;
    else
      v_internal_timeout := timeout;
    end if;
    assert (v_internal_timeout >= 0 ns) report "configured negative timeout(not allowed). " & add_msg_delimiter(msg) severity failure;

    -- Check for v_internal_timeout = 0 and max_receptions = 0. This combination can result in an infinite loop.
    if v_internal_timeout = 0 ns and max_receptions = 0 then
      alert(ERROR, proc_name & " called with timeout=0 and max_receptions = 0. This combination can result in an infinite loop. " & add_msg_delimiter(msg), scope);
    end if;

    if v_internal_timeout = 0 ns then
      log(v_config.id_for_bfm_wait, "Expecting data " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " within " & to_string(max_receptions) & " occurrences. " & msg, scope, msg_id_panel);
    elsif max_receptions = 0 then
      log(v_config.id_for_bfm_wait, "Expecting data " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " within " & to_string(v_internal_timeout, ns) & ". " & msg, scope, msg_id_panel);
    else
      log(v_config.id_for_bfm_wait, "Expecting data " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & " within " & to_string(max_receptions) & " occurrences and " & to_string(v_internal_timeout, ns) & ". " & msg, scope, msg_id_panel);
    end if;

    -- Initial status of check variables
    v_check_ok   := false;
    v_timeout_ok := true;
    if max_receptions < 1 then
      v_num_of_occurrences_ok := true;
    else
      v_num_of_occurrences_ok := v_num_of_occurrences < max_receptions;
    end if;

    -- Setup of v_config with correct timeout
    v_config.timeout := v_internal_timeout;

    -- Check operation
    while not v_check_ok and v_timeout_ok and v_num_of_occurrences_ok and (terminate_loop = '0') loop

      -- Receive and check data
      uart_receive(v_data_value, msg, rx, terminate_loop, v_config, scope, msg_id_panel, proc_call);
      for i in 0 to v_config.num_data_bits - 1 loop
        -- Allow don't care in expected value and use match strictness from config for comparison
        if v_normalized_data(i) = '-' or check_value(v_data_value(i), v_normalized_data(i), config.match_strictness, NO_ALERT, msg, scope, ID_NEVER) then
          v_check_ok := true;
        else
          v_check_ok := false;
          exit;
        end if;
      end loop;

      -- Place the received data in the received data buffer for debugging
      -- If the FIFO is not full, fill it up
      if v_received_data_fifo_write_idx < v_config.num_bytes_to_log_before_expected_data then
        v_received_data_fifo(v_received_data_fifo_write_idx)(v_data_value'length - 1 downto 0) := v_data_value;
        v_received_data_fifo_write_idx                                                         := v_received_data_fifo_write_idx + 1;
      else
        -- If the FIFO is full, left shift all input and append new data
        for i in 1 to v_config.num_bytes_to_log_before_expected_data - 1 loop
          v_received_data_fifo(i - 1) := v_received_data_fifo(i);
        end loop;
        v_received_data_fifo(v_received_data_fifo_write_idx - 1)(v_data_value'length - 1 downto 0) := v_data_value;
      end if;

      -- Evaluate number of occurrences, if limited by user
      if max_receptions > 0 then
        v_num_of_occurrences    := v_num_of_occurrences + 1;
        v_num_of_occurrences_ok := v_num_of_occurrences < max_receptions;
      end if;

      -- Evaluate timeout if specified by user
      if v_internal_timeout = 0 ns then
        v_timeout_ok := true;
      else
        v_timeout_ok := now < start_time + v_internal_timeout;
      end if;
    end loop;

    -- Concatenate the string FIFO into a single string with given separators
    for i in 0 to v_received_data_fifo_write_idx - 1 loop
      write(v_received_output_line, to_string(v_received_data_fifo(i), HEX, SKIP_LEADING_0, INCL_RADIX));
      if i /= v_received_data_fifo_write_idx - 1 then
        write(v_received_output_line, C_EXPECT_RECEIVED_DATA_STRING_SEPARATOR);
      end if;
    end loop;

    if max_receptions > 1 then
      -- Print the received string of bytes
      log(v_config.id_for_bfm_poll_summary, "Last " & to_string(v_received_data_fifo_write_idx) & " received data bytes while waiting for expected data: " & v_received_output_line.all, scope, msg_id_panel);
    end if;

    if v_check_ok then
      log(v_config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & " after " & to_string(v_num_of_occurrences) & " occurrences and " & to_string((now - start_time), ns) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    elsif not v_timeout_ok then
      alert(config.timeout_severity, proc_call & "=> Failed due to timeout. Did not get expected value " & to_string(v_normalized_data, HEX, AS_IS, INCL_RADIX) & " before time " & to_string(v_internal_timeout, ns) & ". " & add_msg_delimiter(msg), scope);
    elsif not v_num_of_occurrences_ok then
      -- Use binary representation when mismatch is due to weak signals
      v_alert_radix := BIN when config.match_strictness = MATCH_EXACT and check_value(v_data_value, v_normalized_data, MATCH_STD, NO_ALERT, msg, scope, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER) else HEX;
      if max_receptions = 1 then
        alert(alert_level, proc_call & "=> Failed. Expected value " & to_string(v_normalized_data, v_alert_radix, AS_IS, INCL_RADIX) & " did not appear within " & to_string(max_receptions) & " occurrences, received value " & to_string(v_data_value, v_alert_radix, AS_IS, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope);
      else
        alert(alert_level, proc_call & "=> Failed. Expected value " & to_string(v_normalized_data, v_alert_radix, AS_IS, INCL_RADIX) & " did not appear within " & to_string(max_receptions) & " occurrences. " & add_msg_delimiter(msg), scope);
      end if;
    else
      alert(warning, proc_call & "=> Failed. Terminate loop received. " & add_msg_delimiter(msg), scope);
    end if;

    DEALLOCATE(v_received_output_line);
  end procedure;

end package body uart_bfm_pkg;

