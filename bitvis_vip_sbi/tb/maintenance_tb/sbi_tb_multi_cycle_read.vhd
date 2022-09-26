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

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

--hdlregression:tb
-- Test case entity
entity sbi_tb_multi_cycle_read is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of sbi_tb_multi_cycle_read is

  constant C_CLK_PERIOD : time   := 10 ns; -- **** Trenger metode for setting av clk period
  constant C_SCOPE      : string := "SBI_VVC_TB";

  constant C_ADDR_WIDTH_1 : integer := 8;
  constant C_DATA_WIDTH_1 : integer := 8;

  signal sbi_if_1 : t_sbi_if(addr(C_ADDR_WIDTH_1 - 1 downto 0), wdata(C_DATA_WIDTH_1 - 1 downto 0), rdata(C_DATA_WIDTH_1 - 1 downto 0));

  signal rst        : std_logic := '1';
  signal last_write : std_logic_vector(sbi_if_1.rdata'range);
  signal data_in    : std_logic_vector(sbi_if_1.wdata'range);

  signal clk : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Instantiate DUT and VVC, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  i1_sbi_slave : entity work.sbi_slave
    generic map(
      GC_ADDR_WIDTH             => 8,
      GC_DATA_WIDTH             => 8,
      GC_FIXED_WAIT_CYCLES_READ => 2,
      GC_CLK_PERIOD             => 10 ns
    )
    port map(
      clk        => clk,
      rst        => rst,
      sbi_cs     => sbi_if_1.cs,
      sbi_rd     => sbi_if_1.rena,
      sbi_wr     => sbi_if_1.wena,
      sbi_addr   => sbi_if_1.addr,
      sbi_wdata  => sbi_if_1.wdata,
      sbi_rdata  => sbi_if_1.rdata,
      last_write => last_write,
      data_in    => data_in
    );

  i3_sbi_vvc : entity work.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH_1,
      GC_DATA_WIDTH   => C_DATA_WIDTH_1,
      GC_INSTANCE_IDX => 1
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => sbi_if_1
    );
  p_clk : clock_generator(clk, C_CLK_PERIOD);

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_cmd_idx            : integer;
    variable v_data               : work.vvc_cmd_pkg.t_vvc_result;
    variable v_is_ok              : boolean := false;
    variable v_timestamp          : time;
    variable v_alert_num_mismatch : boolean := false;

    variable v_result_from_fetch : bitvis_vip_sbi.vvc_cmd_pkg.t_vvc_result;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    set_alert_stop_limit(TB_ERROR, 4);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);
    enable_log_msg(ID_BFM_POLL);

    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(VVC_BROADCAST, ID_BFM);
    enable_log_msg(VVC_BROADCAST, ID_BFM_POLL);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Set that ready signal is not in use
    shared_sbi_vvc_config(1).bfm_config.use_ready_signal           := false;
    shared_sbi_vvc_config(1).bfm_config.use_fixed_wait_cycles_read := true;
    shared_sbi_vvc_config(1).bfm_config.fixed_wait_cycles_read     := 2;
    wait for 3 * C_CLK_PERIOD;          -- Wait for reset being released in test harness

    -- release reset to DUT
    rst <= '0';

    --------------------------------------------------------------------------------------
    -- Verifying
    --------------------------------------------------------------------------------------
    if GC_TESTCASE = "fixed_wait_read_test" then
      log(ID_LOG_HDR, "Check that the fixed wait cycles are working correct");

      enable_log_msg(VVC_BROADCAST, ALL_MESSAGES);

      -- Fill FIFO 1
      sbi_write(SBI_VVCT, 1, x"00", x"01", "Set Register 0");
      await_completion(SBI_VVCT, ALL_INSTANCES, 1000 ns, "Await execution for both VVCs");

      wait until rising_edge(clk);
      v_timestamp := now;
      sbi_read(SBI_VVCT, 1, x"00", "Reading from Register 0");
      v_cmd_idx   := get_last_received_cmd_idx(SBI_VVCT, 1);
      await_completion(SBI_VVCT, 1, 100 ns, "Await execution");
      fetch_result(SBI_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
      check_value(((now - v_timestamp) = C_CLK_PERIOD * 3.25), ERROR, "Checking that timing was upheld");
      report (to_string(v_result_from_fetch(7 downto 0)));
      check_value(x"01", v_result_from_fetch(7 downto 0), ERROR, "checking read value");

      shared_sbi_vvc_config(1).bfm_config.fixed_wait_cycles_read := 1; -- setting fixed_wait_cycles_read to one leading to wrong data
      sbi_write(SBI_VVCT, 1, x"00", x"55", "Set Register 0 to a new value");
      await_completion(SBI_VVCT, 1, 1000 ns, "Await execution of VVC");

      wait until rising_edge(clk);
      v_timestamp := now;
      sbi_read(SBI_VVCT, 1, x"00", "Reading from Register 0");
      v_cmd_idx   := get_last_received_cmd_idx(SBI_VVCT, 1);
      await_completion(SBI_VVCT, 1, 100 ns, "Await execution");
      fetch_result(SBI_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
      increment_expected_alerts(warning, 2);
      check_value(((now - v_timestamp) = C_CLK_PERIOD * 3.25), WARNING, "The read should only take 2.25 clk_periods and therefore throw a warning");
      check_value(v_result_from_fetch(7 downto 0), x"55", WARNING, "checking read value should lead to a warning");

      check_value(((now - v_timestamp) = C_CLK_PERIOD * 2.25), ERROR, "Checking that the read took 2.25 clk_periods");
      check_value(v_result_from_fetch(7 downto 0), x"00", ERROR, "Reading to fast should return 00");

      shared_sbi_vvc_config(1).bfm_config.fixed_wait_cycles_read := 2; -- setting fixed_wait_cycles_read to one leading to wrong data
    end if;

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
