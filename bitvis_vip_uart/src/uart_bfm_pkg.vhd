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
--
-- NOTE: This BFM is only intended as a simplified UART BFM to be used as a test 
--       vehicle for presenting UVVM functionality.
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library STD;
use std.textio.all;

--=================================================================================================
package uart_bfm_pkg is

  --===============================================================================================
  -- Types and constants for UART BFMs 
  --===============================================================================================

  constant C_SCOPE : string := "UART BFM";

  -- Configuration record to be assigned in the test harness.
  type t_parity is (
    PARITY_NONE,
    PARITY_ODD,
    PARITY_EVEN
  );
  type t_stop_bits is (
    STOP_BITS_ONE,
    STOP_BITS_ONE_AND_HALF,
    STOP_BITS_TWO
  );
  type t_flow_control is (
    FLOW_NONE,
    FLOW_XOFF_XON,
    FLOW_HW
  );
  
  constant C_MAX_BITS_IN_RECEIVED_DATA              : natural := 16;
  constant C_EXPECT_RECEIVED_DATA_STRING_SEPARATOR  : string := "; ";
  type uart_expect_received_data_array is array (natural range<>) of std_logic_vector(C_MAX_BITS_IN_RECEIVED_DATA-1 downto 0);

  type t_uart_bfm_config is
  record
    clock_period                               : time;
    clocks_per_bit                             : natural;
    num_data_bits                              : natural;
    start_bit                                  : std_logic;  -- specify high or low
    stop_bit                                   : std_logic;  -- specify high or low
    num_stop_bits                              : t_stop_bits;
    parity                                     : t_parity;
    max_wait_cycles                            : natural;
    max_wait_cycles_severity                   : t_alert_level;
    received_data_to_log_before_expected_data  : natural;
    id_for_bfm                                 : t_msg_id;
    id_for_bfm_wait                            : t_msg_id;
    id_for_bfm_poll                            : t_msg_id;
    id_for_bfm_poll_summary                    : t_msg_id;
  end record;

  constant C_UART_BFM_CONFIG_DEFAULT : t_uart_bfm_config := (
    clock_period             => 10 ns, 
    clocks_per_bit           => 16,
    num_data_bits            => 8,
    start_bit                => '0',
    stop_bit                 => '1',
    num_stop_bits            => STOP_BITS_ONE,
    parity                   => PARITY_ODD,
    max_wait_cycles          => 50,
    max_wait_cycles_severity => failure,
    received_data_to_log_before_expected_data    => 10,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL,
    id_for_bfm_poll_summary  => ID_BFM_POLL_SUMMARY
    );

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------
  
  ------------------------------------------
  -- uart_transmit
  ------------------------------------------
  -- - This procedure transmits data 'data_value' to the UART DUT
  -- - The TX configuration can be set in the config parameter
  procedure uart_transmit (
    constant data_value    : in  std_logic_vector(7 downto 0);
    constant msg           : in  string;
    signal clk             : in  std_logic;
    signal tx              : out std_logic;
    constant config        : in  t_uart_bfm_config  := C_UART_BFM_CONFIG_DEFAULT;
    constant scope         : in  string             := C_SCOPE;
    constant msg_id_panel  : in  t_msg_id_panel     := shared_msg_id_panel
    );

    
  ------------------------------------------
  -- uart_receive
  ------------------------------------------
  -- - This procedure reads data from the UART DUT and returns it in 'data_value'
  -- - The RX configuration can be set in the config parameter
  procedure uart_receive (
    variable data_value   : out std_logic_vector;
    constant msg          : in  string;
    signal clk            : in  std_logic;
    signal rx             : in  std_logic;
    signal terminate_loop : in  std_logic;
    constant config       : in  t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope        : in  string            := C_SCOPE;
    constant msg_id_panel : in  t_msg_id_panel    := shared_msg_id_panel;
    constant proc_name    : in  string            := "uart_receive"  -- overwrite if called from other procedure like uart_expect
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
  procedure uart_expect (
    constant data_exp        : in std_logic_vector(7 downto 0);
    constant max_receptions  : in natural           := 1;
    constant timeout         : in time              := 0 ns;
    constant alert_level     : in t_alert_level     := ERROR;
    constant msg             : in string;
    signal clk               : in std_logic;
    signal rx                : in std_logic;
    signal terminate_loop    : in std_logic;
    constant config          : in t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope           : in string            := C_SCOPE;
    constant msg_id_panel    : in t_msg_id_panel    := shared_msg_id_panel
    );

    
  ------------------------------------------
  -- odd_parity
  ------------------------------------------
  -- - This function checks if the data parity is odd or even
  -- - If the number of '1' in the 'data' input is odd, '1' will be returned
  -- - If the number of '1' in the 'data' input is even, '0' will be returned
  function odd_parity (
    constant data : std_logic_vector(7 downto 0))
    return std_logic;

end package uart_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body uart_bfm_pkg is


  function odd_parity (
    constant data : std_logic_vector(7 downto 0))
    return std_logic is
    variable odd : std_logic;
    variable i   : integer;
  begin
    odd := '1';
    for i in data'range loop
      odd := odd xor data(i);
    end loop;
    return odd;
  end odd_parity;

  
  ---------------------------------------------------------------------------------
  -- uart_transmit
  ---------------------------------------------------------------------------------
  procedure uart_transmit (
    constant data_value    : in  std_logic_vector(7 downto 0);
    constant msg           : in  string;
    signal clk             : in  std_logic;
    signal tx              : out std_logic;
    constant config        : in  t_uart_bfm_config  := C_UART_BFM_CONFIG_DEFAULT;
    constant scope         : in  string             := C_SCOPE;
    constant msg_id_panel  : in  t_msg_id_panel     := shared_msg_id_panel
    ) is
    constant proc_name    : string := "uart_transmit";
    constant proc_call    : string := "uart transmit(" & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);

    tx <= config.start_bit;
    wait_num_rising_edge(clk, config.clocks_per_bit);

    for j in 0 to config.num_data_bits-1 loop
      tx <= data_value(j);
      wait_num_rising_edge(clk, config.clocks_per_bit);
    end loop;

    -- parity?
    if (config.parity = PARITY_ODD) then
      tx <= odd_parity(data_value);
      wait_num_rising_edge(clk, config.clocks_per_bit);
    elsif(config.parity = PARITY_EVEN) then
      tx <= not odd_parity(data_value);
      wait_num_rising_edge(clk, config.clocks_per_bit);
    end if;

    -- stop bits
    tx <= config.stop_bit;
    wait_num_rising_edge(clk, config.clocks_per_bit);
    if (config.num_stop_bits = STOP_BITS_ONE_AND_HALF) then
      wait_num_rising_edge(clk, config.clocks_per_bit/2);
    elsif(config.num_stop_bits = STOP_BITS_TWO) then
      wait_num_rising_edge(clk, config.clocks_per_bit);
    end if;

    tx <= not config.start_bit;         -- back to idle
    log(config.id_for_bfm, proc_call & " completed. " & msg, scope, msg_id_panel);
  end procedure;

  
  ---------------------------------------------------------------------------------
  -- uart_receive
  ---------------------------------------------------------------------------------
  -- Perform a receive operation
  procedure uart_receive (
    variable data_value   : out std_logic_vector;
    constant msg          : in  string;
    signal clk            : in  std_logic;
    signal rx             : in  std_logic;
    signal terminate_loop : in  std_logic;
    constant config       : in  t_uart_bfm_config := C_UART_BFM_CONFIG_DEFAULT;
    constant scope        : in  string            := C_SCOPE;
    constant msg_id_panel : in  t_msg_id_panel    := shared_msg_id_panel;
    constant proc_name    : in  string            := "uart_receive"  -- overwrite if called from other procedure like uart_expect
    ) is
    constant proc_call           : string := "uart receive()";
    -- Helper variables
    variable v_data_value        : std_logic_vector(7 downto 0);
    variable v_clk_cycles_waited : natural := 0;
    variable started             : boolean := false;
    variable timeout             : boolean := false;
  begin
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    while not started and not timeout and (terminate_loop = '0') loop
      if rx = config.start_bit then
        started := true;
      end if;
      wait for config.clock_period;
      v_clk_cycles_waited := v_clk_cycles_waited + 1;
      if v_clk_cycles_waited >= config.max_wait_cycles then
        timeout := true;
      end if;
    end loop;

    if started then
      -- wait for data bit
      wait_num_rising_edge(clk, config.clocks_per_bit-1);

      -- enter the middle of the bit period
      wait_num_rising_edge(clk, config.clocks_per_bit/2);
      -- sample the data bits
      for i in 0 to config.num_data_bits-1 loop
        v_data_value(i) := rx;
        -- wait for middle of the next bit
        wait_num_rising_edge(clk, config.clocks_per_bit);
      end loop;

      -- check parity, if enabled
      if config.parity = PARITY_ODD and
        rx /= odd_parity(v_data_value) then
        alert(error, proc_call & "=> Failed. Incorrect parity received");
      elsif config.parity = PARITY_EVEN and
        rx /= not odd_parity(v_data_value) then
        alert(error, proc_call & "=> Failed. Incorrect parity received");
      end if;
      wait_num_rising_edge(clk, config.clocks_per_bit);

      -- check the stop bit
      if rx /= config.stop_bit then
        alert(error, proc_call & "=> Failed. Incorrect stop bit received");
      end if;
      if config.num_stop_bits = STOP_BITS_ONE_AND_HALF then
        wait_num_rising_edge(clk, config.clocks_per_bit/2);
        wait_num_rising_edge(clk, config.clocks_per_bit/4);  -- middle of the last half
        if rx /= config.stop_bit then
          alert(error, proc_call & "=> Failed. Incorrect second half stop bit received");
        end if;
      elsif config.num_stop_bits = STOP_BITS_TWO then
        wait_num_rising_edge(clk, config.clocks_per_bit);
        if rx /= config.stop_bit then
          alert(error, proc_call & "=> Failed. Incorrect second stop bit received");
        end if;
      end if;

      -- return the received data
      data_value := v_data_value;
      if proc_name = "uart_receive" then
        log(config.id_for_bfm, proc_call & "=> " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & msg, scope, msg_id_panel);
      else
      -- Log will be handled by calling procedure (e.g. uart_expect)
      end if;
    elsif timeout then
      alert(config.max_wait_cycles_severity, proc_call & " => Failed. Timeout");
    elsif proc_name = "uart_receive" then
      -- No alert if uart receive was called from uart_expect.
      alert(warning, proc_call & " => Failed. Exited due to terminate signal.");
    end if;
  end procedure;

  ----------------------------------------------------------------------------------------
  -- uart_expect
  ----------------------------------------------------------------------------------------
  -- Perform a receive operation, then compare the received value to the expected value.
  procedure uart_expect (
    constant data_exp               : in std_logic_vector(7 downto 0);
    constant max_receptions         : in natural            := 1;     -- 0 = any occurrence before timeout
    constant timeout                : in time               := 0 ns;  -- 0 = no timeout
    constant alert_level            : in t_alert_level      := ERROR;
    constant msg                    : in string;
    signal clk                      : in std_logic;
    signal rx                       : in std_logic;
    signal terminate_loop           : in  std_logic;
    constant config                 : in t_uart_bfm_config  := C_UART_BFM_CONFIG_DEFAULT;
    constant scope                  : in string             := C_SCOPE;
    constant msg_id_panel           : in t_msg_id_panel     := shared_msg_id_panel
    ) is
    constant proc_name                : string  := "uart_expect";
    constant proc_call                : string  := proc_name & "(" & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
    constant start_time               : time    := now;
    variable v_data_value             : std_logic_vector(7 downto 0);
    variable v_num_of_occurrences     : natural := 0;
    variable v_check_ok               : boolean;
    variable v_num_of_occurrences_ok  : boolean;
    variable v_timeout_ok             : boolean;
    variable v_config                 : t_uart_bfm_config;
    variable v_received_data_fifo     : uart_expect_received_data_array(0 to config.received_data_to_log_before_expected_data-1) := (others => (others =>'0'));
    variable v_received_data_fifo_pos : natural := 0;
    variable v_received_output_line   : line;
  begin
    -- Check for timeout = 0 and max_receptions = 0. This combination can result in an infinite loop.
    if max_receptions = 0 and timeout = 0 ns then
      alert(ERROR, proc_name & " called with timeout=0 and max_receptions=0. This can result in an infinite loop.");
    end if;

    log(config.id_for_bfm_wait, "Expecting data " & to_string(data_exp, HEX, SKIP_LEADING_0, INCL_RADIX) & " within " & to_string(max_receptions) & " occurrences and " & to_string(timeout,ns) & ".", scope, msg_id_panel);

    -- Initial status of check variables
    v_check_ok    := false;
    v_timeout_ok  := true;
    if max_receptions < 1 then
      v_num_of_occurrences_ok := true;
    else
      v_num_of_occurrences_ok := v_num_of_occurrences < max_receptions;
    end if;

    -- Setup of config with correct timeout
    v_config := config;
    if timeout > 0 ns then
      v_config.max_wait_cycles := timeout / config.clock_period;
    else
      v_config.max_wait_cycles := integer'high;
    end if;

    -- Check operation
    while not v_check_ok and v_timeout_ok and v_num_of_occurrences_ok and (terminate_loop = '0') loop

      -- Receive and check data
      uart_receive(v_data_value, msg, clk, rx, terminate_loop, v_config, scope, msg_id_panel, proc_name);
      for i in 0 to config.num_data_bits-1 loop
        if (data_exp(i) = '-' or
            v_data_value(i) = data_exp(i)) then
          v_check_ok := true;
        else
          v_check_ok := false;
          exit;
        end if;
      end loop;
      
      -- Place the received data in the received data buffer for debugging
      -- If the FIFO is not full, fill it up
      if v_received_data_fifo_pos < config.received_data_to_log_before_expected_data then
        v_received_data_fifo(v_received_data_fifo_pos)(v_data_value'length-1 downto 0) := v_data_value;
        v_received_data_fifo_pos := v_received_data_fifo_pos + 1;
      else 
        -- If the FIFO is full, left shift all input and append new data
        for i in 1 to config.received_data_to_log_before_expected_data-1 loop
          v_received_data_fifo(i-1) := v_received_data_fifo(i);
        end loop;
        v_received_data_fifo(v_received_data_fifo_pos-1)(v_data_value'length-1 downto 0) := v_data_value;
      end if;
      
      -- Evaluate number of occurrences, if limited by user
      if max_receptions > 0 then
        v_num_of_occurrences := v_num_of_occurrences + 1;
        v_num_of_occurrences_ok := v_num_of_occurrences < max_receptions;
      end if;
      
      -- Evaluate timeout if specified by user
      if timeout = 0 ns then
        v_timeout_ok := true;
      else
        v_timeout_ok := (now - start_time) < timeout;
      end if;
    end loop;

    -- Concatenate the string FIFO into a single string with given separators
    for i in 0 to v_received_data_fifo_pos-1 loop
      write(v_received_output_line, to_string(v_received_data_fifo(i), HEX, SKIP_LEADING_0, INCL_RADIX));
      if i /= v_received_data_fifo_pos-1 then
        write(v_received_output_line, C_EXPECT_RECEIVED_DATA_STRING_SEPARATOR);
      end if;
    end loop;
    
    if max_receptions > 1 then
      -- Print the received string of bytes
      log(config.id_for_bfm_poll_summary, "Last "& to_string(v_received_data_fifo_pos) & " received data bytes while waiting for expected data: " & v_received_output_line.all, scope, msg_id_panel);
    end if;
    
    if v_check_ok then
      log(config.id_for_bfm, proc_call & "=> OK, received data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & " after " & to_string(v_num_of_occurrences) & " occurrences and " & to_string((now - start_time),ns) & ". " & msg, scope, msg_id_panel);
    elsif not v_timeout_ok then
      alert(alert_level, proc_call & "=> Failed due to timeout. Did not get expected value " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & " before time " & to_string(timeout,ns) & ". " & msg, scope);
    elsif not v_num_of_occurrences_ok then
      alert(alert_level, proc_call & "=> Failed. Expected value " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & " did not appear within " & to_string(max_receptions) & " occurrences. " & msg, scope);
    else 
      alert(warning, proc_call & "=> Failed. Terminated loop received. " & msg, scope);
    end if;
  end procedure;

end package body uart_bfm_pkg;



