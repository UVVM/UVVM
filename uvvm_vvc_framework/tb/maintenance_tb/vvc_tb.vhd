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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;
use uvvm_vvc_framework.ti_protected_types_pkg.all;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;
use bitvis_vip_uart.uart_bfm_pkg.all;

library bitvis_vip_avalon_mm;
context bitvis_vip_avalon_mm.vvc_context;

--hdlregression:tb
-- Test bench entity
entity vvc_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test bench architecture
architecture func of vvc_tb is

  -- Clock and bit period settings
  constant C_CLK_PERIOD   : time := 10 ns;
  constant C_BIT_PERIOD   : time := 16 * C_CLK_PERIOD;
  constant C_FRAME_PERIOD : time := 11 * C_BIT_PERIOD;

  -- Time for one UART transmission to complete
  constant C_TIME_OF_ONE_UART_TX : time := 11 * C_BIT_PERIOD; -- =1760 ns;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(3 downto 0) := x"0";
  constant C_ADDR_RX_DATA_VALID : unsigned(3 downto 0) := x"1";
  constant C_ADDR_TX_DATA       : unsigned(3 downto 0) := x"2";
  constant C_ADDR_TX_READY      : unsigned(3 downto 0) := x"3";

  constant C_FLAG_A : string := "flag_a";
  constant C_FLAG_B : string := "flag_b";
  constant C_FLAG_C : string := "flag_c";
  constant C_FLAG_D : string := "flag_d";
  constant C_FLAG_E : string := "flag_e";
  constant C_FLAG_F : string := "flag_f";
  constant C_FLAG_G : string := "flag_g";
  constant C_FLAG_H : string := "flag_h";
  constant C_FLAG_I : string := "flag_i";
  constant C_FLAG_J : string := "flag_j";

  constant C_UART_BFM_CONFIG_0 : t_uart_bfm_config := (
    bit_time                              => 160 ns,
    num_data_bits                         => 8,
    idle_state                            => '1',
    num_stop_bits                         => STOP_BITS_ONE,
    parity                                => PARITY_ODD,
    timeout                               => 0 ns,
    timeout_severity                      => error,
    num_bytes_to_log_before_expected_data => 10,
    match_strictness                      => MATCH_EXACT,
    id_for_bfm                            => ID_BFM,
    id_for_bfm_wait                       => ID_BFM_WAIT,
    id_for_bfm_poll                       => ID_BFM_POLL,
    id_for_bfm_poll_summary               => ID_BFM_POLL_SUMMARY,
    error_injection                       => C_BFM_ERROR_INJECTION_INACTIVE
  );

  signal clk  : std_logic := '0';
  signal arst : std_logic := '0';

  signal uart_0_rx_data_ready : std_logic := '0';
  signal uart_1_rx_data_ready : std_logic := '0';
  signal uart_2_rx_data_ready : std_logic := '0';
  signal uart_3_rx_data_ready : std_logic := '0';
  signal uart_4_rx_data_ready : std_logic := '0';

  signal uart_0_cs    : std_logic                    := '0';
  signal uart_0_addr  : unsigned(2 downto 0)         := (others => '0');
  signal uart_0_wr    : std_logic                    := '0';
  signal uart_0_rd    : std_logic                    := '0';
  signal uart_0_wdata : std_logic_vector(7 downto 0) := (others => '0');
  signal uart_0_rdata : std_logic_vector(7 downto 0);
  signal uart_0_rx_a  : std_logic                    := '1';
  signal uart_0_tx    : std_logic;

  signal uart_1_rx_a : std_logic := '1';
  signal uart_1_tx   : std_logic;

  signal uart_2_cs    : std_logic                    := '0';
  signal uart_2_addr  : unsigned(2 downto 0)         := (others => '0');
  signal uart_2_wr    : std_logic                    := '0';
  signal uart_2_rd    : std_logic                    := '0';
  signal uart_2_wdata : std_logic_vector(7 downto 0) := (others => '0');
  signal uart_2_rdata : std_logic_vector(7 downto 0);

  signal uart_2_ready   : std_logic := '1'; -- Always ready
  signal uart_3_ready   : std_logic := '1'; -- Always ready
  signal uart_4_ready   : std_logic := '1'; -- Always ready
  signal terminate_loop : std_logic := '0'; -- Never in this testbench

  signal barrier_a        : std_logic := 'X';
  signal barrier_b        : std_logic := 'X';
  signal barrier_c        : std_logic := 'X';
  signal barrier_d        : std_logic := 'X';
  signal barrier_e        : std_logic := 'X';
  signal barrier_e_helper : std_logic := 'X';
  signal barrier_f        : std_logic := 'X';
  signal barrier_g        : std_logic := 'X';
  signal barrier_h        : std_logic := 'X';
  signal barrier_h_helper : std_logic := 'X';
  signal barrier_i        : std_logic := 'X';
  signal barrier_i_helper : std_logic := 'X';
  signal barrier_j        : std_logic := 'X';

  -- Procedure to make every single test start on a "round" time
  procedure separate_tests_in_time(     -- Wait for next round time number - e.g. if now=2100ns, and round_time=1000ns, then next round time is 3000ns
    round_time : time) is
    variable v_overshoot : time := now rem round_time;
  begin
    wait for (round_time - v_overshoot);
  end;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.vvc_th
    port map(
      -- DSP interface and general control signals
      clk          => clk,
      arst         => arst,
      -- UART 0 CPU interface
      uart_0_cs    => uart_0_cs,
      uart_0_addr  => uart_0_addr,
      uart_0_wr    => uart_0_wr,
      uart_0_rd    => uart_0_rd,
      uart_0_wdata => uart_0_wdata,
      uart_0_rdata => uart_0_rdata,
      -- UART 0 signals
      uart_0_rx_a  => uart_0_rx_a,
      uart_0_tx    => uart_0_tx,
      -- UART 1 signals
      uart_1_rx_a  => uart_1_rx_a,
      uart_1_tx    => uart_1_tx,
      -- UART 2 CPU interface
      uart_2_cs    => uart_2_cs,
      uart_2_addr  => uart_2_addr,
      uart_2_wr    => uart_2_wr,
      uart_2_rd    => uart_2_rd,
      uart_2_wdata => uart_2_wdata,
      uart_2_rdata => uart_2_rdata
    );

  clock_generator(clk, C_CLK_PERIOD);

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE_MAIN : string := C_TB_SCOPE_DEFAULT & " Main";
  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    set_alert_stop_limit(ERROR, 0);

    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    set_alert_stop_limit(WARNING, 0);
    set_alert_stop_limit(ERROR, 0);     -- 0 = Never stop
    set_alert_stop_limit(TB_ERROR, 0);

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    log(ID_LOG_HDR, "Starting simulation using several sequencers", C_SCOPE_MAIN);
    enable_log_msg(ALL_MESSAGES, scope => C_SCOPE_MAIN);

    log("Wait 10 clock period for reset to be turned off", C_SCOPE_MAIN);
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off

    --------------------------------------------------------------------------------------
    -- Verifying
    --------------------------------------------------------------------------------------
    if GC_TESTCASE = "Testing_2_Sequencer_Parallel_using_different_types_of_VVCs" then
      unblock_flag(C_FLAG_A, "Unblocking Flag_A -> starting the other 2 sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_a, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_2_Sequencer_Parallel_using_same_types_of_VVCs_but_different_instances" then
      unblock_flag(C_FLAG_B, "Unblocking Flag_B -> starting the other 2 sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_b, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_but_not_at_the_same_time" then
      unblock_flag(C_FLAG_C, "Unblocking Flag_C -> starting the other 2 sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_c, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_get_last_received_cmd_idx" then
      unblock_flag(C_FLAG_D, "Unblocking Flag_D -> starting the other 2 sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_d, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_different_accesses_between_two_sequencer" then
      unblock_flag(C_FLAG_E, "Unblocking Flag_E -> starting the other 2 sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_e, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_different_single_sequencer_access" then
      unblock_flag(C_FLAG_F, "Unblocking Flag_F -> starting the other sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_f, 100 us, "waiting for the sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_shared_uvvm_status_await_any_completion_info" then
      unblock_flag(C_FLAG_G, "Unblocking Flag_G -> starting the other sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_g, 100 us, "waiting for the sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_await_completion_from_different_sequencers" then
      unblock_flag(C_FLAG_H, "Unblocking Flag_H -> starting the other sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_h, 200 us, "waiting for the sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_await_any_completion_from_different_sequencers" then
      unblock_flag(C_FLAG_I, "Unblocking Flag_I -> starting the other sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_i, 200 us, "waiting for the sequencers to finish", scope => C_SCOPE_MAIN);
    elsif GC_TESTCASE = "Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_at_the_same_time" then
      unblock_flag(C_FLAG_J, "Unblocking Flag_J -> starting the other 2 sequencer", global_trigger, C_SCOPE_MAIN);
      await_barrier(barrier_j, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_MAIN);
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE_MAIN);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_main;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_2_Sequencer_Parallel_using_different_types_of_VVCs
  --------------------------------------------------------------------------------------------------
  p_main_a1 : process
    constant C_SCOPE_A1 : string := C_TB_SCOPE_DEFAULT & " A1";

    procedure uart_expect(
      constant data_exp       : in std_logic_vector(7 downto 0);
      constant max_receptions : in natural := 1;
      constant timeout        : in time    := 0 ns;
      constant alert_level    : in t_alert_level;
      constant msg            : in string) is
    begin
      uart_expect(data_exp, msg, uart_1_tx, terminate_loop, max_receptions, timeout, alert_level, C_UART_BFM_CONFIG_0, C_SCOPE_A1);
    end;
  begin
    await_unblock_flag(C_FLAG_A, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_A1);

    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_A1);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, x"55", "TX_DATA", C_SCOPE_A1);
    uart_expect(x"55", 1, 2 * C_FRAME_PERIOD, ERROR, "out of UART 0 TX");

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_A1);
    await_barrier(barrier_a, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_A1);
    wait;                               -- to stop completely
  end process p_main_a1;

  p_main_a2 : process
    constant C_SCOPE_A2 : string := C_TB_SCOPE_DEFAULT & " A2";

    procedure sbi_write(
      constant addr_value : in unsigned;
      constant data_value : in std_logic_vector;
      constant msg        : in string) is
    begin
      sbi_write(addr_value, data_value, msg,
                clk, uart_2_cs, uart_2_addr, uart_2_rd, uart_2_wr, uart_2_ready, uart_2_wdata, C_SCOPE_A2);
    end;
  begin
    await_unblock_flag(C_FLAG_A, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_A2);

    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE_A2);
    shared_uart_vvc_config(RX, 1).bfm_config.bit_time := 160 ns;

    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_A2);
    sbi_write(C_ADDR_TX_DATA, x"55", "TX_DATA");
    uart_expect(UART_VVCT, 1, RX, x"55", "out of UART 2 TX", scope => C_SCOPE_A2);
    await_completion(UART_VVCT, 1, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_A2);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_A2);
    await_barrier(barrier_a, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_A2);
    wait;                               -- to stop completely
  end process p_main_a2;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_2_Sequencer_Parallel_using_same_types_of_VVCs_but_different_instances
  --------------------------------------------------------------------------------------------------
  p_main_b1 : process
    constant C_SCOPE_B1 : string := C_TB_SCOPE_DEFAULT & " B1";
  begin
    await_unblock_flag(C_FLAG_B, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_B1);
    wait for 1 ns;

    log(ID_LOG_HDR, "Configure UART VVC 2", C_SCOPE_B1);
    shared_uart_vvc_config(RX, 2).bfm_config.bit_time := C_BIT_PERIOD; --- RX 3?
    enable_log_msg(UART_VVCT, 2, RX, ALL_MESSAGES, scope => C_SCOPE_B1);

    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_B1);
    sbi_write(SBI_VVCT, 2, C_ADDR_TX_DATA, x"55", "TX_DATA", C_SCOPE_B1);
    uart_expect(UART_VVCT, 2, RX, x"55", "out of UART 3 TX", scope => C_SCOPE_B1);
    await_completion(UART_VVCT, 2, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_B1);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_B1);
    await_barrier(barrier_b, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_B1);
    wait;                               -- to stop completely
  end process p_main_b1;

  p_main_b2 : process
    constant C_SCOPE_B2 : string := C_TB_SCOPE_DEFAULT & " B2";
  begin
    await_unblock_flag(C_FLAG_B, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_B2);
    wait for 1 ns;

    log(ID_LOG_HDR, "Configure UART VVC 3", C_SCOPE_B2);
    shared_uart_vvc_config(RX, 3).bfm_config.bit_time := C_BIT_PERIOD;
    enable_log_msg(SBI_VVCT, 3, ALL_MESSAGES, scope => C_SCOPE_B2);

    -- send x"AA" from sbi interface to UART 3
    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_B2);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_B2);
    uart_expect(UART_VVCT, 3, RX, x"AA", "out of UART 4 TX", scope => C_SCOPE_B2);
    await_completion(UART_VVCT, 3, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_B2);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_B2);
    await_barrier(barrier_b, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_B2);
    wait;                               -- to stop completely
  end process p_main_b2;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_but_not_at_the_same_time
  --------------------------------------------------------------------------------------------------
  p_main_c1 : process
    constant C_SCOPE_C1 : string := C_TB_SCOPE_DEFAULT & " C1";
  begin
    await_unblock_flag(C_FLAG_C, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_C1);

    log(ID_LOG_HDR, "Configure UART VVC 2", C_SCOPE_C1);
    shared_uart_vvc_config(RX, 2).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_C1);
    sbi_write(SBI_VVCT, 2, C_ADDR_TX_DATA, x"55", "TX_DATA", C_SCOPE_C1);
    uart_expect(UART_VVCT, 2, RX, x"55", "out of UART 2 TX", scope => C_SCOPE_C1);
    await_completion(UART_VVCT, 2, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_C1);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_C1);
    await_barrier(barrier_c, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_C1);
    wait;                               -- to stop completely
  end process p_main_c1;

  p_main_c2 : process
    constant C_SCOPE_C2 : string := C_TB_SCOPE_DEFAULT & " C2";
  begin
    await_unblock_flag(C_FLAG_C, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_C2);

    log(ID_LOG_HDR, "Configure UART VVC 2", C_SCOPE_C2);
    shared_uart_vvc_config(RX, 2).bfm_config.bit_time := C_BIT_PERIOD;

    wait for 2 * C_FRAME_PERIOD;

    -- send x"AA" from sbi interface to UART 2
    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_C2);
    sbi_write(SBI_VVCT, 2, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_C2);
    uart_expect(UART_VVCT, 2, RX, x"AA", "out of UART 2 TX", scope => C_SCOPE_C2);
    await_completion(UART_VVCT, 2, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_C2);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_C2);
    await_barrier(barrier_c, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_C2);
    wait;                               -- to stop completely
  end process p_main_c2;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_get_last_received_cmd_idx
  --------------------------------------------------------------------------------------------------
  p_main_d1 : process
    constant C_SCOPE_D1          : string := C_TB_SCOPE_DEFAULT & " D1";
    variable v_cmd_idx           : natural;
    variable v_result_from_fetch : bitvis_vip_uart.vvc_cmd_pkg.t_vvc_result;
  begin
    await_unblock_flag(C_FLAG_D, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_D1);

    log(ID_LOG_HDR, "Configure UART VVC 2", C_SCOPE_D1);
    shared_uart_vvc_config(RX, 2).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_D1);
    sbi_write(SBI_VVCT, 2, C_ADDR_TX_DATA, x"55", "TX_DATA", C_SCOPE_D1);
    uart_receive(UART_VVCT, 2, RX, "reading out of UART 2 TX", scope => C_SCOPE_D1);
    v_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 2, RX);
    await_completion(UART_VVCT, 2, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_D1);
    fetch_result(UART_VVCT, 2, RX, v_cmd_idx, v_result_from_fetch, "Fetch result from uart_receive using the simple fetch_result overload", scope => C_SCOPE_D1);
    check_value(v_result_from_fetch, x"55", error, "Verifying data", C_SCOPE_D1);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_D1);
    await_barrier(barrier_d, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_D1);
    wait;                               -- to stop completely
  end process p_main_d1;

  p_main_d2 : process
    constant C_SCOPE_D2          : string := C_TB_SCOPE_DEFAULT & " D2";
    variable v_cmd_idx           : natural;
    variable v_result_from_fetch : bitvis_vip_uart.vvc_cmd_pkg.t_vvc_result;
  begin
    await_unblock_flag(C_FLAG_D, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_D2);

    log(ID_LOG_HDR, "Configure UART VVC 3", C_SCOPE_D2);
    shared_uart_vvc_config(RX, 3).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX, 2).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX, 3).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Check simple transmit and readback with 2 sequencer parallel", C_SCOPE_D2);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"33", "TX_DATA", C_SCOPE_D2);
    uart_receive(UART_VVCT, 3, RX, "reading out of UART 3 TX", scope => C_SCOPE_D2);
    v_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 3, RX);
    await_completion(UART_VVCT, 3, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_D2);
    fetch_result(UART_VVCT, 3, RX, v_cmd_idx, v_result_from_fetch, "Fetch result from uart_receive using the simple fetch_result overload", scope => C_SCOPE_D2);
    check_value(v_result_from_fetch, x"33", error, "Verifying data", C_SCOPE_D2);

    v_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 3, TX);
    uart_transmit(UART_VVCT, 2, TX, x"33", "Sending data on VVC 2 should not change the last received cmd index on VVC 3", C_SCOPE_D2);
    check_value(v_cmd_idx = get_last_received_cmd_idx(UART_VVCT, 3, TX), error, "The command index must not change", C_SCOPE_D2);
    uart_transmit(UART_VVCT, 3, TX, x"55", "Sending data on VVC 3 should change the last received cmd index on VVC 3", C_SCOPE_D2);
    check_value(v_cmd_idx /= get_last_received_cmd_idx(UART_VVCT, 3, TX), error, "The command index must have been changed", C_SCOPE_D2);

    log(ID_SEQUENCER, "testing a not supported channel should result in a tb_error", C_SCOPE_D2);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_D2);
    v_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 3, NA, C_SCOPE_D2);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_D2);
    await_barrier(barrier_d, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_D2);
    wait;                               -- to stop completely
  end process p_main_d2;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_different_accesses_between_two_sequencer
  --------------------------------------------------------------------------------------------------
  p_main_e1 : process
    constant C_SCOPE_E1  : string := C_TB_SCOPE_DEFAULT & " E1";
    variable v_timestamp : time;
  begin
    await_unblock_flag(C_FLAG_E, 0 us, "SEQUENCER 1: waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_E1);

    shared_uart_vvc_config(TX, 2).bfm_config.bit_time := 160 ns;

    log(ID_LOG_HDR, "SEQUENCER 1: Sending 2 Broadcasts at the same time", C_SCOPE_E1);
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E1);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 1", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Sending Broadcast and simple command at the same time", C_SCOPE_E1);
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E1);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 2", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Sending first Broadcast and afterwards simple command with some delta cycle delay", C_SCOPE_E1);
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E1);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 3", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Sending first simple command and afterwards Broadcast with some delta cycle delay", C_SCOPE_E1);
    for i in 0 to 5 loop
      wait for 0 ns;
    end loop;
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E1);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 4", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Send data and wait for finish while the other sequencer tries a Broadcast (old await_completion)", C_SCOPE_E1);
    for i in 0 to 10 loop
      wait for 0 ns;
    end loop;
    v_timestamp := now;
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E1);
    check_value(((now - v_timestamp) > 1 ns), ERROR, "SEQUENCER 1: Checking that it is waiting for other sequencer to finish await_completion", C_SCOPE_E1);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 5", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Send data and wait for finish while the other sequencer tries a Multicast (old await_completion)", C_SCOPE_E1);
    for i in 0 to 10 loop
      wait for 0 ns;
    end loop;
    v_timestamp := now;
    enable_log_msg(SBI_VVCT, ALL_INSTANCES, ALL_MESSAGES, scope => C_SCOPE_E1);
    check_value(((now - v_timestamp) > 1 ns), ERROR, "SEQUENCER 1: Checking that it is waiting for other sequencer to finish await_completion", C_SCOPE_E1);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 6", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Sending two Multicast simultaniously to different VVCs", C_SCOPE_E1);
    uart_transmit(UART_VVCT, 2, TX, x"33", "SEQUENCER 1: Sending data on VVC 2", C_SCOPE_E1);
    await_completion(UART_VVCT, ALL_INSTANCES, TX, 100 us, scope => C_SCOPE_E1);
    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 7", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Sending await_completion Multicast on one sequencer and on the other a non time consuming cmd", C_SCOPE_E1);
    uart_transmit(UART_VVCT, 2, TX, x"33", "SEQUENCER 1: Sending data on VVC 2", C_SCOPE_E1);
    await_completion(UART_VVCT, ALL_INSTANCES, TX, 100 us, scope => C_SCOPE_E1);
    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 8", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Sending Brodcast while Multicast is running", C_SCOPE_E1);
    for i in 0 to 2 loop
      wait for 0 ns;
    end loop;
    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E1);
    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 9", scope => C_SCOPE_E1);

    log(ID_LOG_HDR, "SEQUENCER 1: Sending Multicast while Brodcast is running", C_SCOPE_E1);
    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E1);
    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 1: synchronising both sequencer point 10", scope => C_SCOPE_E1);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_E1);
    await_barrier(barrier_e, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_E1);
    wait;                               -- to stop completely
  end process p_main_e1;

  p_main_e2 : process
    constant C_SCOPE_E2  : string := C_TB_SCOPE_DEFAULT & " E2";
    variable v_timestamp : time;

    procedure check_log(
      msg_id_panel : t_msg_id_panel;
      enabled      : t_enabled) is
    begin
      -- for vvc_idx in 0 to C_MAX_VVC_INSTANCE_NUM-1 loop
      -- for channel in t_channel'left to t_channel'right loop
      -- if (config(channel, vvc_idx) /= -1) then
      for msg_id in t_msg_id'left to t_msg_id'right loop
        if (msg_id_panel(msg_id) /= enabled and msg_id /= ID_NEVER and msg_id /= ID_UTIL_BURIED and msg_id /= ID_BITVIS_DEBUG and msg_id /= ID_COVERAGE_MAKEBIN and msg_id /= ID_COVERAGE_ADDBIN and msg_id /= ID_COVERAGE_ICOVER and msg_id /= ID_LOG_MSG_CTRL) then
          tb_error("Log Message " & to_string(msg_id) & " not " & to_string(enabled), C_SCOPE_E2);
          exit;
        end if;
      end loop;
      -- end if;
      -- end loop;
      -- end loop;
    end procedure;
  begin
    await_unblock_flag(C_FLAG_E, 0 us, "SEQUENCER 2: waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_E2);

    log(ID_LOG_HDR, "SEQUENCER 2: Sending 2 Broadcasts at the same time", C_SCOPE_E2);
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 1", scope => C_SCOPE_E2);

    log(ID_LOG_HDR, "SEQUENCER 2: Sending Broadcast and simple command at the same time", C_SCOPE_E2);
    enable_log_msg(SBI_VVCT, 2, ALL_MESSAGES, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 2", scope => C_SCOPE_E2);

    log(ID_LOG_HDR, "SEQUENCER 2: Sending first Broadcast and afterwards simple command with some delta cycle delay", C_SCOPE_E2);
    for i in 0 to 5 loop
      wait for 0 ns;
    end loop;
    enable_log_msg(SBI_VVCT, 2, ALL_MESSAGES, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 3", scope => C_SCOPE_E2);

    log(ID_LOG_HDR, "SEQUENCER 2: Sending first simple command and afterwards Broadcast with some delta cycle delay", C_SCOPE_E2);
    enable_log_msg(SBI_VVCT, 2, ALL_MESSAGES, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 4", scope => C_SCOPE_E2);
    log(ID_LOG_HDR, "SEQUENCER 2: Send data and wait for finish while the other sequencer tries a Broadcast (old await_completion)", C_SCOPE_E2);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"33", "TX_DATA", C_SCOPE_E2);
    await_completion(SBI_VVCT, 4, 100 ns, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 5", scope => C_SCOPE_E2);
    log(ID_LOG_HDR, "SEQUENCER 2: Send data and wait for finish while the other sequencer tries a Multicast (old await_completion)", C_SCOPE_E2);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"33", "TX_DATA", C_SCOPE_E2);
    await_completion(SBI_VVCT, 4, 100 ns, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 6", scope => C_SCOPE_E2);
    log(ID_LOG_HDR, "SEQUENCER 2: Sending two Multicast simultaniously to different VVCs", C_SCOPE_E2);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"33", "TX_DATA", C_SCOPE_E2);
    await_completion(SBI_VVCT, ALL_INSTANCES, 100 ns, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 7", scope => C_SCOPE_E2);

    log(ID_LOG_HDR, "SEQUENCER 2: Sending await_completion Multicast on one sequencer and on the other a non time consuming cmd", C_SCOPE_E2);
    for i in 0 to 10 loop
      wait for 0 ns;
    end loop;
    v_timestamp := now;
    enable_log_msg(SBI_VVCT, 3, ALL_MESSAGES, scope => C_SCOPE_E2);
    check_value(((now - v_timestamp) = 0 ns), ERROR, "SEQUENCER 2: Checking that no time has passed", C_SCOPE_E2);
    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 8", scope => C_SCOPE_E2);

    log(ID_LOG_HDR, "SEQUENCER 2: Sending Brodcast while Multicast is running", C_SCOPE_E2);
    enable_log_msg(SBI_VVCT, ALL_INSTANCES, ALL_MESSAGES, scope => C_SCOPE_E2);
    check_log(shared_sbi_vvc_config(2).msg_id_panel, ENABLED);
    check_log(shared_sbi_vvc_config(3).msg_id_panel, ENABLED);
    wait for 1 ns;
    -- log messages should be disabled of broadcast
    check_log(shared_sbi_vvc_config(2).msg_id_panel, DISABLED);
    check_log(shared_sbi_vvc_config(3).msg_id_panel, DISABLED);
    -- enable all messages again
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 9", scope => C_SCOPE_E2);

    log(ID_LOG_HDR, "SEQUENCER 2: Sending Multicast while Brodcast is running", C_SCOPE_E2);
    -- get sure that Broadcast comes first
    for i in 0 to 2 loop
      wait for 0 ns;
    end loop;
    -- sending Multicast
    enable_log_msg(SBI_VVCT, ALL_INSTANCES, ALL_MESSAGES, scope => C_SCOPE_E2);
    check_log(shared_sbi_vvc_config(2).msg_id_panel, ENABLED);
    check_log(shared_sbi_vvc_config(3).msg_id_panel, ENABLED);
    check_log(shared_uart_vvc_config(RX, 2).msg_id_panel, DISABLED);
    check_log(shared_uart_vvc_config(TX, 2).msg_id_panel, DISABLED);
    check_log(shared_uart_vvc_config(RX, 3).msg_id_panel, DISABLED);
    check_log(shared_uart_vvc_config(TX, 3).msg_id_panel, DISABLED);
    -- enable all messages again
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES, scope => C_SCOPE_E2);

    await_barrier(barrier_e_helper, 100 us, "SEQUENCER 2: synchronising both sequencer point 10", scope => C_SCOPE_E2);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_E2);
    await_barrier(barrier_e, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_E2);
    wait;                               -- to stop completely
  end process p_main_e2;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_different_single_sequencer_access
  --------------------------------------------------------------------------------------------------
  p_main_f : process
    constant C_SCOPE_F   : string := C_TB_SCOPE_DEFAULT & " F";
    variable v_timestamp : time;
  begin
    await_unblock_flag(C_FLAG_F, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_F);

    log(ID_LOG_HDR, "Configure UART VVC 2", C_SCOPE_F);
    shared_uart_vvc_config(RX, 2).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX, 2).bfm_config.bit_time := C_BIT_PERIOD;

    uart_transmit(UART_VVCT, 2, TX, x"33", "Sending data on VVC 2", C_SCOPE_F);

    v_timestamp := now;
    await_completion(UART_VVCT, 2, ALL_CHANNELS, 2 * C_FRAME_PERIOD, scope => C_SCOPE_F);
    check_value(now > (0.5 * C_FRAME_PERIOD), TB_ERROR, "await_completion should take at least a frame_period", C_SCOPE_F);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_F);
    await_barrier(barrier_f, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_F);
    wait;                               -- to stop completely
  end process p_main_f;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_shared_uvvm_status_await_any_completion_info
  -- Test await_any_completion() shared_uvvm_status for command index and VVC name
  --------------------------------------------------------------------------------------------------
  p_main_g : process
    constant C_SCOPE_G                : string  := C_TB_SCOPE_DEFAULT & " G";
    variable v_uart_cmd_idx           : natural := 0;
    variable v_sbi_cmd_idx            : natural := 0;
    variable v_vvc_name               : string(1 to C_INFO_ON_FINISHING_AWAIT_ANY_COMPLETION_VVC_NAME_DEFAULT'length);
    variable v_vvc_cmd_idx            : natural;
    variable v_vvc_time_of_completion : time    := 0 ns;
  begin
    await_unblock_flag(C_FLAG_G, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_G);

    log(ID_LOG_HDR, "Check shared_uvvm_status defaults.", C_SCOPE_G);
    v_vvc_cmd_idx            := shared_uvvm_status.info_on_finishing_await_any_completion.vvc_cmd_idx;
    v_vvc_name               := shared_uvvm_status.info_on_finishing_await_any_completion.vvc_name(1 to v_vvc_name'length);
    v_vvc_time_of_completion := shared_uvvm_status.info_on_finishing_await_any_completion.vvc_time_of_completion;
    check_value(v_vvc_cmd_idx = 0, ERROR, "check vvc_cmd_idx default", C_SCOPE_G);
    check_value(v_vvc_name = C_INFO_ON_FINISHING_AWAIT_ANY_COMPLETION_VVC_NAME_DEFAULT, ERROR, "check vvc_name default", C_SCOPE_G);
    check_value(v_vvc_time_of_completion = 0 ns, ERROR, "check vvc_time_of_completion initial value", C_SCOPE_G);

    wait for 200 ns;

    log(ID_LOG_HDR, "Activate UART VVC 3 and SBI VVC 3 and await VVC completion.", C_SCOPE_G);
    shared_uart_vvc_config(RX, 3).bfm_config.bit_time := C_BIT_PERIOD;

    check_value(shared_sbi_vvc_status(3).previous_cmd_idx = shared_sbi_vvc_status(3).current_cmd_idx, ERROR, "check that previous_cmd_idx and current_cmd_idx are the same (initial value)", C_SCOPE_G);
    check_value(shared_uart_vvc_status(RX, 3).previous_cmd_idx = shared_uart_vvc_status(RX, 3).current_cmd_idx, ERROR, "check that previous_cmd_idx and current_cmd_idx are the same (initial value)", C_SCOPE_G);

    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"33", "TX_DATA", C_SCOPE_G);
    uart_receive(UART_VVCT, 3, RX, "reading out of UART 3 TX", scope => C_SCOPE_G);

    insert_delay(SBI_VVCT, 3, C_CLK_PERIOD, scope => C_SCOPE_G);
    insert_delay(UART_VVCT, 3, RX, 2 * C_CLK_PERIOD, scope => C_SCOPE_G);

    v_sbi_cmd_idx  := get_last_received_cmd_idx(SBI_VVCT, 3);
    v_uart_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 3, RX);

    check_value(shared_sbi_vvc_status(3).previous_cmd_idx /= shared_sbi_vvc_status(3).current_cmd_idx, ERROR, "check that previous_cmd_idx and current_cmd_idx are different (during execution)", C_SCOPE_G);
    check_value(shared_uart_vvc_status(RX, 3).previous_cmd_idx /= shared_uart_vvc_status(RX, 3).current_cmd_idx, ERROR, "check that previous_cmd_idx and current_cmd_idx are different (during execution)", C_SCOPE_G);

    await_any_completion(SBI_VVCT, 3, v_sbi_cmd_idx, NOT_LAST, 2 us, "waiting for VVC to finish.", scope => C_SCOPE_G);
    await_any_completion(UART_VVCT, 3, RX, v_uart_cmd_idx, LAST, 2 us, "waiting for VVC to finish.", scope => C_SCOPE_G);

    v_vvc_time_of_completion := shared_uvvm_status.info_on_finishing_await_any_completion.vvc_time_of_completion;
    v_vvc_cmd_idx            := shared_uvvm_status.info_on_finishing_await_any_completion.vvc_cmd_idx;
    log(ID_SEQUENCER, "await_any_completion() initiated by " & to_string(shared_uvvm_status.info_on_finishing_await_any_completion.vvc_name) & ", command index=" & to_string(v_vvc_cmd_idx) & ", completed at " & to_string(v_vvc_time_of_completion) & ".", C_SCOPE_G);

    check_value((v_vvc_cmd_idx = v_sbi_cmd_idx) or (v_vvc_cmd_idx = v_uart_cmd_idx), ERROR, "check command index initiated await_any_completion", C_SCOPE_G);
    check_value(v_vvc_time_of_completion > 0 ns, ERROR, "check vvc_time_of_completion value has increased.", C_SCOPE_G);

    await_completion(UART_VVCT, 3, RX, v_uart_cmd_idx, 2 us, "waiting for VVC to finish.", scope => C_SCOPE_G);
    check_value(shared_sbi_vvc_status(3).current_cmd_idx = 0, ERROR, "check that current_cmd_idx is 0 (when idle)", C_SCOPE_G);
    check_value(shared_uart_vvc_status(RX, 3).current_cmd_idx = 0, ERROR, "check that current_cmd_idx is 0 (when idle)", C_SCOPE_G);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_G);
    await_barrier(barrier_g, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_G);
    wait;                               -- to stop completely
  end process p_main_g;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_await_completion_from_different_sequencers
  --------------------------------------------------------------------------------------------------
  p_main_h1 : process
    constant C_SCOPE_H1 : string := C_TB_SCOPE_DEFAULT & " H1";
    variable v_cmd_idx  : natural;
  begin
    await_unblock_flag(C_FLAG_H, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_H1);

    -------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Test old await_completion mechanism", C_SCOPE_H1);
    -------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Check await_completion for non-existing VVC instance", C_SCOPE_H1);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_H1);
    await_completion(SBI_VVCT, 20, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_H1);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 1", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, 4, RANDOM, "TX_DATA", C_SCOPE_H1);
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 4);
    await_completion(SBI_VVCT, 4, v_cmd_idx, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 2", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    await_completion(SBI_VVCT, 4, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 3", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_H1);
    await_completion(SBI_VVCT, 4, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 4", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion with broadcast to all VVCs while another sequencer access one of the VVCs", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, 4, RANDOM, "TX_DATA", C_SCOPE_H1);
    await_completion(VVC_BROADCAST, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 5", scope => C_SCOPE_H1);

    -------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Test new await_completion mechanism", C_SCOPE_H1);
    -------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Check await_completion from non-existing VVC instance", C_SCOPE_H1);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_H1);
    await_completion(UART_VVCT, 20, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_H1);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 6", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 4, RANDOM, "TX_DATA", C_SCOPE_H1);
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 3);
    await_completion(SBI_VVCT, 3, v_cmd_idx, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 7", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_H1);
    await_completion(SBI_VVCT, 3, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 8", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_H1);
    await_completion(SBI_VVCT, 3, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 9", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion in a VVC with multiple executors from two different sequencers", C_SCOPE_H1);
    shared_avalon_mm_vvc_config(1).bfm_config.use_readdatavalid := true;
    avalon_mm_read(AVALON_MM_VVCT, 1, "0", "Send a read request");
    await_completion(AVALON_MM_VVCT, 1, 100 ns, scope => C_SCOPE_H1);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 10", scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion and check that it timeouts", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_H1);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_H1);
    await_completion(SBI_VVCT, 3, 10 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion with ALL_INSTANCES and/or ALL_CHANNELS of a VVC", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_H1);
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 3);
    await_completion(SBI_VVCT, ALL_INSTANCES, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;

    await_completion(UART_VVCT, ALL_INSTANCES, RX, 100 ns, scope => C_SCOPE_H1);

    await_completion(UART_VVCT, 3, ALL_CHANNELS, 100 ns, scope => C_SCOPE_H1);

    await_completion(UART_VVCT, ALL_INSTANCES, ALL_CHANNELS, 100 ns, scope => C_SCOPE_H1);

    log(ID_LOG_HDR, "Use await_completion for a command idx with ALL_INSTANCES of a VVC", C_SCOPE_H1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_H1);
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 3);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_H1);
    await_completion(SBI_VVCT, ALL_INSTANCES, v_cmd_idx, 100 ns, scope => C_SCOPE_H1);
    wait for 6 * C_FRAME_PERIOD;

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_H1);
    await_barrier(barrier_h, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_H1);
    wait;                               -- to stop completely
  end process p_main_h1;

  p_main_h2 : process
    constant C_SCOPE_H2 : string := C_TB_SCOPE_DEFAULT & " H2";
  begin
    await_unblock_flag(C_FLAG_H, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_H2);

    shared_uart_vvc_config(RX, 3).bfm_config.bit_time := C_BIT_PERIOD;

    -------------------------------------------------------------------------------
    --"Test old await_completion mechanism"
    -------------------------------------------------------------------------------
    -- Wait for SEQUENCER 1: "Check await_completion for non-existing VVC instance"
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 1", scope => C_SCOPE_H2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_H2);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_H2);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"11", "TX_DATA", C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 2", scope => C_SCOPE_H2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_H2);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_H2);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"22", "TX_DATA", C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 3", scope => C_SCOPE_H2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_H2);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_H2);
    await_completion(SBI_VVCT, 4, 100 ns, scope => C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 4", scope => C_SCOPE_H2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion with broadcast to all VVCs while another sequencer access one of the VVCs", C_SCOPE_H2);
    increment_expected_alerts(TB_ERROR, 2, scope => C_SCOPE_H2);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"33", "TX_DATA", C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 5", scope => C_SCOPE_H2);

    -------------------------------------------------------------------------------
    --"Test new await_completion mechanism"
    -------------------------------------------------------------------------------
    -- Wait for SEQUENCER 1: "Check await_completion from non-existing VVC instance"
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 6", scope => C_SCOPE_H2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_H2);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"44", "TX_DATA", C_SCOPE_H2);
    uart_expect(UART_VVCT, 3, RX, x"44", "Expect data in UART within the last 5 bytes", 5, scope => C_SCOPE_H2);
    await_completion(UART_VVCT, 3, RX, 6 * C_FRAME_PERIOD, scope => C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 7", scope => C_SCOPE_H2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_H2);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"55", "TX_DATA", C_SCOPE_H2);
    uart_expect(UART_VVCT, 3, RX, x"55", "Expect data in UART within the last 5 bytes", 5, scope => C_SCOPE_H2);
    await_completion(UART_VVCT, 3, RX, 6 * C_FRAME_PERIOD, scope => C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 8", scope => C_SCOPE_H2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_H2);
    await_completion(SBI_VVCT, 3, 100 ns, scope => C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 9", scope => C_SCOPE_H2);

    wait for 20 ns;                     -- wait long enough so the VVC is handling the read response (2nd executor)
    log(ID_LOG_HDR, "Use await_completion in a VVC with multiple executors from two different sequencers", C_SCOPE_H2);
    await_completion(AVALON_MM_VVCT, 1, 100 ns, scope => C_SCOPE_H2);
    await_barrier(barrier_h_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 10", scope => C_SCOPE_H2);

    -- Ending the simulation in sequencer 2
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_H2);
    await_barrier(barrier_h, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_H2);
    wait;                               -- to stop completely
  end process p_main_h2;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_await_any_completion_from_different_sequencers
  --------------------------------------------------------------------------------------------------
  p_main_i1 : process
    constant C_SCOPE_I1      : string := C_TB_SCOPE_DEFAULT & " I1";
    variable v_cmd_idx       : natural;
    variable v_vvc_info_list : t_vvc_info_list;
  begin
    await_unblock_flag(C_FLAG_I, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_I1);

    -------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Test old await_any_completion mechanism", C_SCOPE_I1);
    -------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Use await_any_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, 4, RANDOM, "TX_DATA", C_SCOPE_I1);
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 4);
    await_any_completion(SBI_VVCT, 4, v_cmd_idx, LAST, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 1", scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_any_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    await_any_completion(SBI_VVCT, 4, LAST, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 2", scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_any_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    await_any_completion(SBI_VVCT, 4, LAST, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 3", scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_any_completion for a group of VVCs from two different sequencers", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    await_any_completion(UART_VVCT, 4, TX, NOT_LAST, 100 ns, scope => C_SCOPE_I1);
    await_any_completion(UART_VVCT, 4, RX, NOT_LAST, 100 ns, scope => C_SCOPE_I1);
    await_any_completion(SBI_VVCT, 4, LAST, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 4", scope => C_SCOPE_I1);

    -------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Test new await_any_completion mechanism", C_SCOPE_I1);
    -------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Use await_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 3);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    v_vvc_info_list.add("SBI_VVC", 3, v_cmd_idx);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 5", scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_I1);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 6", scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 1: synchronising both sequencers point 7", scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_completion for one VVC", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion for one of several VVCs and keep the list", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    v_vvc_info_list.add("UART_VVC", 3, TX);
    v_vvc_info_list.add("UART_VVC", 3, RX);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, KEEP_LIST, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion for one of several VVCs and clear the list", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    increment_expected_alerts(TB_WARNING, 3, scope => C_SCOPE_I1);
    v_vvc_info_list.add("UART_VVC", 3, TX);
    v_vvc_info_list.add("UART_VVC", 3, RX);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, CLEAR_LIST, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion with an empty list", C_SCOPE_I1);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I1);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_completion with some unsupported VVCs", C_SCOPE_I1);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I1);
    v_vvc_info_list.add("UART_VVC", 3, TX);
    v_vvc_info_list.add("UART_VVC", 3, RX);
    v_vvc_info_list.add("UART_VVC", 4, TX);
    v_vvc_info_list.add("UART_VVC", 4, RX);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_completion and check that it timeouts", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I1);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ANY_OF, v_vvc_info_list, 10 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion with ALL_INSTANCES and/or ALL_CHANNELS of a VVC", C_SCOPE_I1);
    v_vvc_info_list.add("SBI_VVC", ALL_INSTANCES);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    v_vvc_info_list.add("UART_VVC", ALL_INSTANCES, RX);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    v_vvc_info_list.add("UART_VVC", 3, ALL_CHANNELS);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    v_vvc_info_list.add("UART_VVC", ALL_INSTANCES, ALL_CHANNELS);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    v_vvc_info_list.add("UART_VVC", 3, ALL_CHANNELS);
    v_vvc_info_list.add("UART_VVC", 2, RX);
    v_vvc_info_list.add("UART_VVC", 1, ALL_CHANNELS);
    v_vvc_info_list.add("SBI_VVC", ALL_INSTANCES);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I1);
    v_vvc_info_list.add("UART_VVC", 3, ALL_CHANNELS);
    v_vvc_info_list.add("UART_VVC", 4, RX);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I1);
    v_vvc_info_list.add("UART_VVC", 4, RX);
    v_vvc_info_list.add("UART_VVC", 3, ALL_CHANNELS);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_completion for a command idx with ALL_INSTANCES of a VVC", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 3);
    v_vvc_info_list.add("SBI_VVC", ALL_INSTANCES, v_cmd_idx);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion for several VVCs", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    v_vvc_info_list.add("UART_VVC", 3, ALL_CHANNELS);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ALL_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion for any or all VVCs of a list without a list", C_SCOPE_I1);
    increment_expected_alerts(TB_ERROR, 2, scope => C_SCOPE_I1);
    await_completion(ANY_OF, 100 ns, scope => C_SCOPE_I1);
    await_completion(ALL_OF, 100 ns, scope => C_SCOPE_I1);

    log(ID_LOG_HDR, "Use await_completion with broadcast to all VVCs", C_SCOPE_I1);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, 5, RANDOM, "TX_DATA", C_SCOPE_I1);
    await_completion(ALL_VVCS, 100 ns, scope => C_SCOPE_I1);
    wait for 6 * C_FRAME_PERIOD;

    log(ID_LOG_HDR, "Use await_completion with broadcast to all VVCs using a list", C_SCOPE_I1);
    increment_expected_alerts(TB_WARNING, 1, scope => C_SCOPE_I1);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ALL_VVCS, v_vvc_info_list, 100 ns, scope => C_SCOPE_I1);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_I1);
    await_barrier(barrier_i, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_I1);
    wait;                               -- to stop completely
  end process p_main_i1;

  p_main_i2 : process
    constant C_SCOPE_I2      : string := C_TB_SCOPE_DEFAULT & " I2";
    variable v_vvc_info_list : t_vvc_info_list;
  begin
    await_unblock_flag(C_FLAG_I, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_I2);

    shared_uart_vvc_config(RX, 3).bfm_config.bit_time := C_BIT_PERIOD;

    -------------------------------------------------------------------------------
    --"Test old await_any_completion mechanism"
    -------------------------------------------------------------------------------
    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_any_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_I2);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I2);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"11", "TX_DATA", C_SCOPE_I2);
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 1", scope => C_SCOPE_I2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_any_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_I2);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I2);
    sbi_write(SBI_VVCT, 4, C_ADDR_TX_DATA, x"22", "TX_DATA", C_SCOPE_I2);
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 2", scope => C_SCOPE_I2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_any_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_I2);
    increment_expected_alerts(TB_ERROR, 1, scope => C_SCOPE_I2);
    await_any_completion(SBI_VVCT, 4, LAST, 100 ns, scope => C_SCOPE_I2);
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 3", scope => C_SCOPE_I2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_any_completion for a group of VVCs from two different sequencers", C_SCOPE_I2);
    await_any_completion(SBI_VVCT, 4, LAST, 100 ns, scope => C_SCOPE_I2);
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 4", scope => C_SCOPE_I2);

    -------------------------------------------------------------------------------
    --"Test new await_any_completion mechanism"
    -------------------------------------------------------------------------------
    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for a command idx in a VVC while another sequencer access the same VVC", C_SCOPE_I2);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"33", "TX_DATA", C_SCOPE_I2);
    uart_expect(UART_VVCT, 3, RX, x"33", "Expect data in UART within the last 5 bytes", 5, scope => C_SCOPE_I2);
    await_completion(UART_VVCT, 3, RX, 6 * C_FRAME_PERIOD, scope => C_SCOPE_I2);
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 5", scope => C_SCOPE_I2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC while another sequencer access the same VVC", C_SCOPE_I2);
    sbi_write(SBI_VVCT, 3, C_ADDR_TX_DATA, x"44", "TX_DATA", C_SCOPE_I2);
    uart_expect(UART_VVCT, 3, RX, x"44", "Expect data in UART within the last 5 bytes", 5, scope => C_SCOPE_I2);
    await_completion(UART_VVCT, 3, RX, 6 * C_FRAME_PERIOD, scope => C_SCOPE_I2);
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 6", scope => C_SCOPE_I2);

    wait for 1 ns;
    log(ID_LOG_HDR, "Use await_completion for all pending commands in a VVC from two different sequencers", C_SCOPE_I2);
    v_vvc_info_list.add("SBI_VVC", 3);
    await_completion(ANY_OF, v_vvc_info_list, 100 ns, scope => C_SCOPE_I2);
    await_barrier(barrier_i_helper, 100 us, "SEQUENCER 2: synchronising both sequencers point 7", scope => C_SCOPE_I2);

    -- Ending the simulation in sequencer 2
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_I2);
    await_barrier(barrier_i, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_I2);
    wait;                               -- to stop completely
  end process p_main_i2;

  --------------------------------------------------------------------------------------------------
  -- TEST: Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_at_the_same_time
  --------------------------------------------------------------------------------------------------
  p_main_j1 : process
    constant C_SCOPE_J1 : string := C_TB_SCOPE_DEFAULT & " J1";
  begin
    await_unblock_flag(C_FLAG_J, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_J1);

    log(ID_LOG_HDR, "Configure UART VVC 2", C_SCOPE_J1);
    shared_uart_vvc_config(RX, 2).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_J1);
    sbi_write(SBI_VVCT, 2, C_ADDR_TX_DATA, x"55", "TX_DATA", C_SCOPE_J1);
    uart_expect(UART_VVCT, 2, RX, x"55", "out of UART 2 TX", scope => C_SCOPE_J1);
    await_completion(UART_VVCT, 2, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_J1);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 1 COMPLETED", C_SCOPE_J1);
    await_barrier(barrier_j, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_J1);
    wait;                               -- to stop completely
  end process p_main_j1;

  p_main_j2 : process
    constant C_SCOPE_J2 : string := C_TB_SCOPE_DEFAULT & " J2";
  begin
    await_unblock_flag(C_FLAG_J, 0 us, "waiting for main sequencer to unblock flag", RETURN_TO_BLOCK, scope => C_SCOPE_J2);

    log(ID_LOG_HDR, "Configure UART VVC 2", C_SCOPE_J2);
    shared_uart_vvc_config(RX, 2).bfm_config.bit_time := C_BIT_PERIOD;

    -- send x"AA" from sbi interface to UART 2
    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE_J2);
    sbi_write(SBI_VVCT, 2, C_ADDR_TX_DATA, x"AA", "TX_DATA", C_SCOPE_J2);
    uart_expect(UART_VVCT, 2, RX, x"AA", "out of UART 2 TX", scope => C_SCOPE_J2);
    await_completion(UART_VVCT, 2, RX, 2 * C_FRAME_PERIOD, scope => C_SCOPE_J2);

    -- Ending the simulation in sequencer 1
    log(ID_LOG_HDR, "SEQUENCER 2 COMPLETED", C_SCOPE_J2);
    await_barrier(barrier_j, 100 us, "waiting for all sequencers to finish", scope => C_SCOPE_J2);
    wait;                               -- to stop completely
  end process p_main_j2;

  -- Toggle the reset after 5 clock periods
  p_arst : arst <= '1', '0' after 5 * C_CLK_PERIOD;

end func;
