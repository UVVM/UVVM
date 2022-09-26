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
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_uart;
use bitvis_vip_uart.uart_bfm_pkg.all;

use work.uart_pif_pkg.all;

--hdlregression:tb
-- Test case entity
entity uart_simple_bfm_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of uart_simple_bfm_tb is

  -- DSP interface and general control signals
  signal clk            : std_logic                    := '0';
  signal arst           : std_logic                    := '0';
  -- CPU interface
  signal cs             : std_logic                    := '0';
  signal addr           : unsigned(2 downto 0)         := (others => '0');
  signal wr             : std_logic                    := '0';
  signal rd             : std_logic                    := '0';
  signal wdata          : std_logic_vector(7 downto 0) := (others => '0'); --
  signal rdata          : std_logic_vector(7 downto 0) := (others => '0');
  signal ready          : std_logic                    := '1'; -- Always ready in the same clock cycle
  -- UART related signals
  signal rx             : std_logic                    := '1';
  signal tx             : std_logic                    := '1';
  signal terminate_loop : std_logic                    := '0';

  signal clock_ena : boolean := false;

  constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

  constant C_UART_BFM_CONFIG_0 : t_uart_bfm_config := (
    bit_time                              => 160 ns,
    num_data_bits                         => 8,
    idle_state                            => '1',
    num_stop_bits                         => STOP_BITS_ONE,
    parity                                => PARITY_ODD,
    timeout                               => 0 ns,
    timeout_severity                      => error,
    match_strictness                      => MATCH_EXACT,
    num_bytes_to_log_before_expected_data => 10,
    id_for_bfm                            => ID_BFM,
    id_for_bfm_wait                       => ID_BFM_WAIT,
    id_for_bfm_poll                       => ID_BFM_POLL,
    id_for_bfm_poll_summary               => ID_BFM_POLL_SUMMARY,
    error_injection                       => C_BFM_ERROR_INJECTION_INACTIVE
  );

  procedure clock_gen(
    signal   clock_signal : inout std_logic;
    signal   clock_ena    : in boolean;
    constant clock_period : in time
  ) is
    variable v_first_half_clk_period : time := C_CLK_PERIOD / 2;
  begin
    loop
      if not clock_ena then
        wait until clock_ena;
      end if;
      wait for v_first_half_clk_period;
      clock_signal <= not clock_signal;
      wait for (clock_period - v_first_half_clk_period);
      clock_signal <= not clock_signal;
    end loop;
  end;

begin

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart : entity work.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,                     --
      arst  => arst,                    --
      -- CPU interface
      cs    => cs,                      --
      addr  => addr,                    --
      wr    => wr,                      --
      rd    => rd,                      --
      wdata => wdata,                   --
      rdata => rdata,                   --
      -- Interrupt related signals
      rx_a  => rx,
      tx    => tx
    );

  -- Set upt clock generator
  clock_gen(clk, clock_ena, 10 ns);

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE         : string := C_TB_SCOPE_DEFAULT;
    -- Helper variables
    variable v_received_data : std_logic_vector(7 downto 0);

    procedure pulse(
      signal   target       : inout std_logic;
      signal   clock_signal : in std_logic;
      constant num_periods  : in natural;
      constant msg          : in string
    ) is
    begin
      -- Add checks etc. later.
      if num_periods > 0 then
        wait until falling_edge(clock_signal);
        target <= '1';
        for i in 1 to num_periods loop
          wait until falling_edge(clock_signal);
        end loop;
      else
        target <= '1';
        wait for 0 ns;                  -- Delta cycle only
      end if;
      target <= '0';
      log(ID_SEQUENCER_SUB, msg, C_SCOPE);
    end;

    -- To do: Combine with above procedure
    procedure pulse(
      signal   target       : inout std_logic_vector;
      constant pulse_value  : in std_logic_vector;
      signal   clock_signal : in std_logic;
      constant num_periods  : in natural;
      constant msg          : in string) is
    begin
      -- Add checks etc. later.
      if num_periods > 0 then
        wait until falling_edge(clock_signal);
        target <= pulse_value;
        for i in 1 to num_periods loop
          wait until falling_edge(clock_signal);
        end loop;
      else
        target <= pulse_value;
        wait for 0 ns;                  -- Delta cycle only
      end if;
      target(target'range) <= (others => '0');
      log(ID_SEQUENCER_SUB, "Pulsed to " & to_string(pulse_value, HEX, AS_IS, INCL_RADIX) & ". " & add_msg_delimiter(msg), C_SCOPE);
    end;

    -- Overloads for PIF BFMs for SBI (Simple Bus Interface)
    procedure sbi_write(
      constant addr_value : in natural;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      sbi_write(to_unsigned(addr_value, addr'length), data_value, msg,
                clk, cs, addr, rd, wr, ready, wdata, C_SCOPE);
    end;

    procedure sbi_check(
      constant addr_value  : in natural;
      constant data_exp    : in std_logic_vector;
      constant alert_level : in t_alert_level;
      constant msg         : in string) is
    begin
      sbi_check(addr_value  => to_unsigned(addr_value, addr'length),
                data_exp    => data_exp,
                msg         => msg,
                clk         => clk,
                cs          => cs,
                addr        => addr,
                rena        => rd,
                wena        => wr,
                ready       => ready,
                rdata       => rdata,
                alert_level => alert_level,
                scope       => C_SCOPE);
    end;

    procedure sbi_await_value(
      constant addr_value        : in natural;
      constant data_exp          : in std_logic_vector;
      constant num_read_attempts : in integer;
      constant alert_level       : in t_alert_level    := ERROR;
      constant msg               : in string;
      constant scope             : in string           := C_SCOPE;
      constant msg_id_panel      : in t_msg_id_panel   := shared_msg_id_panel;
      constant config            : in t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT
    ) is
      constant proc_name       : string  := "sbi_await_value";
      constant proc_call       : string  := "sbi_await_value(A:" & to_string(to_unsigned(addr_value, addr'length), HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";
      -- Helper variables
      variable v_data_value    : std_logic_vector(rdata'length - 1 downto 0);
      variable v_check_ok      : boolean;
      variable v_read_attempts : integer := 0;
    begin
      sbi_read(to_unsigned(addr_value, addr'length), v_data_value, msg, clk, cs, addr, rd, wr, ready, rdata, scope, msg_id_panel, config, proc_name);
      v_read_attempts := v_read_attempts + 1;
      while v_data_value /= data_exp and v_read_attempts <= num_read_attempts loop
        sbi_read(to_unsigned(addr_value, addr'length), v_data_value, msg, clk, cs, addr, rd, wr, ready, rdata, scope, msg_id_panel, config, proc_name);
      end loop;

      v_check_ok := check_value(v_data_value, data_exp, alert_level, msg, scope, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
      if v_check_ok then
        log(ID_BFM, proc_call & "=> OK, read data = " & to_string(v_data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
      end if;
    end;

    -- Overloads for BFMs for UART
    procedure uart_transmit(
      constant data_value : in std_logic_vector(7 downto 0)
    ) is
    begin
      uart_transmit(data_value, "", rx, C_UART_BFM_CONFIG_0, C_SCOPE);
    end;

    procedure uart_receive(
      variable data_value : out std_logic_vector(7 downto 0)
    ) is
      constant msg : string := "";
    begin
      uart_receive(data_value, msg, tx, terminate_loop, C_UART_BFM_CONFIG_0, C_SCOPE);
    end;

    procedure uart_expect(
      constant data_exp : in std_logic_vector(7 downto 0)
    ) is
    begin
      uart_expect(data_exp, "", tx, terminate_loop, 1, 0 ns, ERROR, C_UART_BFM_CONFIG_0, C_SCOPE);
    end;

    procedure set_inputs_passive(
      dummy : t_void) is
    begin
      cs    <= '0';
      addr  <= (others => '0');
      wr    <= '0';
      rd    <= '0';
      wdata <= (others => '0');
      rx    <= '1';
      log(ID_SEQUENCER_SUB, "All inputs set passive", C_SCOPE);
    end;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);

    log(ID_LOG_HDR, "Start Simulation of TB for UART", C_SCOPE);
    ------------------------------------------------------------

    set_inputs_passive(VOID);
    clock_ena <= true;                  -- to start clock generator
    pulse(arst, clk, 10, "Pulsed reset-signal - active for 10T");

    log(ID_LOG_HDR, "Check defaults on output ports", C_SCOPE);
    ------------------------------------------------------------
    check_value(tx, '1', ERROR, "UART TX port must be default '1'", C_SCOPE);
    check_value(rdata, x"00", ERROR, "Register data bus output must be default passive");

    log(ID_LOG_HDR, "Check register defaults and access (transmit + receive)", C_SCOPE);
    ------------------------------------------------------------
    log("\nChecking Register defaults");
    sbi_check(C_ADDR_RX_DATA, x"00", ERROR, "RX_DATA default");
    sbi_check(C_ADDR_TX_READY, x"01", ERROR, "TX_READY default");
    sbi_check(C_ADDR_RX_DATA_VALID, x"00", ERROR, "RX_DATA_VALID default");

    log("\nChecking Register UART DUT transmission (BFM uart_expect)");
    sbi_check(C_ADDR_TX_READY, x"01", ERROR, "TX_READY active");
    sbi_write(C_ADDR_TX_DATA, x"55", "TX_DATA");
    uart_expect(x"55");
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");
    sbi_write(C_ADDR_TX_DATA, x"AA", "TX_DATA");
    uart_expect(x"AA");
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");
    sbi_write(C_ADDR_TX_DATA, x"00", "TX_DATA");
    uart_expect(x"00");
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");

    log("\nChecking Register UART DUT transmission (BFM uart_receive)");
    sbi_check(C_ADDR_TX_READY, x"01", ERROR, "TX_READY active");
    sbi_write(C_ADDR_TX_DATA, x"55", "TX_DATA");
    uart_receive(v_received_data);
    check_value(v_received_data, x"55", ERROR, "", C_SCOPE, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, shared_msg_id_panel);
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");
    sbi_write(C_ADDR_TX_DATA, x"AA", "TX_DATA");
    uart_receive(v_received_data);
    check_value(v_received_data, x"AA", ERROR, "", C_SCOPE, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, shared_msg_id_panel);
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");
    sbi_write(C_ADDR_TX_DATA, x"00", "TX_DATA");
    uart_receive(v_received_data);
    check_value(v_received_data, x"00", ERROR, "", C_SCOPE, HEX_BIN_IF_INVALID, SKIP_LEADING_0, ID_NEVER, shared_msg_id_panel);
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");

    log("\nChecking two consecutive UART DUT transmissions (BFM uart_expect)");
    sbi_write(C_ADDR_TX_DATA, x"55", "TX_DATA");
    sbi_write(C_ADDR_TX_DATA, x"AA", "TX_DATA");
    uart_expect(x"55");
    uart_expect(x"AA");
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");

    log("\nChecking six consecutive UART DUT transmissions (BFM uart_expect)");
    sbi_write(C_ADDR_TX_DATA, x"55", "TX_DATA");
    sbi_write(C_ADDR_TX_DATA, x"AA", "TX_DATA");
    uart_expect(x"55");
    uart_expect(x"AA");
    sbi_write(C_ADDR_TX_DATA, x"BB", "TX_DATA");
    sbi_write(C_ADDR_TX_DATA, x"FF", "TX_DATA");
    uart_expect(x"BB");
    uart_expect(x"FF");
    sbi_write(C_ADDR_TX_DATA, x"DD", "TX_DATA");
    sbi_write(C_ADDR_TX_DATA, x"EE", "TX_DATA");
    uart_expect(x"DD");
    uart_expect(x"EE");
    sbi_await_value(C_ADDR_TX_READY, x"01", 10, ERROR, "TX_READY active");

    log("\nChecking UART DUT reception (BFM uart_transmit)");
    uart_transmit(x"55");
    sbi_await_value(C_ADDR_RX_DATA_VALID, x"01", 10, ERROR, "RX_DATA_VALID enable");
    sbi_check(C_ADDR_RX_DATA, x"55", ERROR, "RX_DATA pure readback");
    uart_transmit(x"AA");
    sbi_await_value(C_ADDR_RX_DATA_VALID, x"01", 10, ERROR, "RX_DATA_VALID enable");
    sbi_check(C_ADDR_RX_DATA, x"AA", ERROR, "RX_DATA pure readback");
    uart_transmit(x"00");
    sbi_await_value(C_ADDR_RX_DATA_VALID, x"01", 10, ERROR, "RX_DATA_VALID enable");
    sbi_check(C_ADDR_RX_DATA, x"00", ERROR, "RX_DATA pure readback");

    sbi_await_value(C_ADDR_RX_DATA_VALID, x"00", 10, ERROR, "");
    log("\nChecking five consecutive UART DUT receptions (BFM uart_transmit)");
    uart_transmit(x"55");
    uart_transmit(x"AA");
    uart_transmit(x"BB");
    uart_transmit(x"FF");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"55", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"AA", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"BB", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"FF", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"00", ERROR, "");

    uart_transmit(x"55");
    uart_transmit(x"AA");
    uart_transmit(x"BB");
    uart_transmit(x"FF");
    uart_transmit(x"DD");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"55", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"AA", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"BB", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"01", ERROR, "");
    sbi_check(C_ADDR_RX_DATA, x"DD", ERROR, "");
    sbi_check(C_ADDR_RX_DATA_VALID, x"00", ERROR, "");

    log(ID_LOG_HDR, "Check Reset", C_SCOPE);
    ------------------------------------------------------------
    log("\nChecking tx output");
    sbi_write(C_ADDR_TX_DATA, x"FF", "TX_DATA : Set to 0xFF");
    pulse(arst, clk, 1, "Pulse reset");
    check_value(tx, '1', ERROR, "UART TX port must be default '1'", C_SCOPE);

    log("\nChecking Register UART TX_READY");
    sbi_check(C_ADDR_TX_READY, x"01", ERROR, "TX_READY default");
    sbi_write(C_ADDR_TX_DATA, x"FF", "");
    sbi_write(C_ADDR_TX_DATA, x"AA", "");
    sbi_write(C_ADDR_TX_DATA, x"55", "");
    sbi_write(C_ADDR_TX_DATA, x"BB", "");
    sbi_write(C_ADDR_TX_DATA, x"EE", "");
    sbi_check(C_ADDR_TX_READY, x"00", ERROR, "TX_READY inactive");
    pulse(arst, clk, 1, "Pulse reset");
    sbi_check(C_ADDR_TX_READY, x"01", ERROR, "TX_READY default");
    check_value(tx, '1', ERROR, "UART TX port must be default '1'", C_SCOPE);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
