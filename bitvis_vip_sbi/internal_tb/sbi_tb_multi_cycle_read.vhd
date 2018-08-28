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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_run_context;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.vvc_cmd_pkg.all;
use work.vvc_methods_pkg.all;
use work.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;
-- Test case entity
entity sbi_tb_multi_cycle_read is
  generic (
    -- This generic is used to configure the testbench from run.py, e.g. what
    -- test case to run. The default value is used when not running from script
    -- and in that case all test cases are run.
    runner_cfg : runner_cfg_t := runner_cfg_default);
end entity;

-- Test case architecture
architecture func of sbi_tb_multi_cycle_read is

  constant C_CLK_PERIOD   : time := 10 ns;    -- **** Trenger metode for setting av clk period
  constant C_SCOPE        : string := "SBI_VVC_TB";


  constant C_ADDR_WIDTH_1 : integer := 8;
  constant C_DATA_WIDTH_1 : integer := 8;

  signal sbi_if_1   : t_sbi_if(addr(C_ADDR_WIDTH_1-1 downto 0), wdata(C_DATA_WIDTH_1-1 downto 0), rdata(C_DATA_WIDTH_1-1 downto 0));

  signal rst        : std_logic := '1';
  signal last_write   : std_logic_vector(sbi_if_1.rdata'range);
  signal data_in  : std_logic_vector(sbi_if_1.wdata'range);

  signal clk : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Instantiate DUT and VVC, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine  : entity uvvm_vvc_framework.ti_uvvm_engine;


  i1_sbi_slave : entity work.sbi_slave
    generic map(
      GC_ADDR_WIDTH              => 8,
      GC_DATA_WIDTH              => 8,
      GC_FIXED_WAIT_CYCLES_READ  => 2,
      GC_CLK_PERIOD              => 10 ns
    )
    port map(
      clk         => clk,
      rst         => rst,
      sbi_cs      => sbi_if_1.cs,
      sbi_rd      => sbi_if_1.rena,
      sbi_wr      => sbi_if_1.wena,
      sbi_addr    => sbi_if_1.addr,
      sbi_wdata   => sbi_if_1.wdata,
      sbi_rdata   => sbi_if_1.rdata,
      last_write  => last_write,
      data_in     => data_in
    );

  i3_sbi_vvc : entity work.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH_1,
      GC_DATA_WIDTH   => C_DATA_WIDTH_1,
      GC_INSTANCE_IDX => 1
      )
    port map(
      clk                     => clk,
      sbi_vvc_master_if       => sbi_if_1
      );
  p_clk : clock_generator(clk, C_CLK_PERIOD);

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process

      variable v_cmd_idx            : integer;
      variable v_data               : work.vvc_cmd_pkg.t_vvc_result;
      variable v_is_ok              : boolean := false;
      variable v_timestamp          : time;
      variable v_alert_num_mismatch : boolean := false;

      variable v_result_from_fetch : bitvis_vip_sbi.vvc_cmd_pkg.t_vvc_result;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other run.py provides separate test case
    -- directories through the runner_cfg generic (<root>/vunit_out/tests/<test case
    -- name>). When not using run.py the default path is the current directory
    -- (<root>/vunit_out/<simulator>). These directories are used by VUnit
    -- itself and these lines make sure that BVUL do to.
    set_log_file_name(join(output_path(runner_cfg), "_Log.txt"));
    set_alert_file_name(join(output_path(runner_cfg), "_Alert.txt"));

    -- Setup the VUnit runner with the input configuration.
    test_runner_setup(runner, runner_cfg);



    -- The default behavior for VUnit is to stop the simulation on a failing
    -- check when running from script but keep on running when running without
    -- script. The rationale for this and how you can change that behavior is
    -- described at the bottom of this file (see Stopping the Simulation on
    -- Failing Checks). The following if statement causes BVUL checks to behave
    -- in the same way.
    if not active_python_runner(runner_cfg) then
      set_alert_stop_limit(ERROR, 0);
    end if;

    await_uvvm_initialization(VOID);

    set_alert_stop_limit(TB_ERROR,4);

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
    shared_sbi_vvc_config(1).bfm_config.use_ready_signal := false;
    shared_sbi_vvc_config(1).bfm_config.use_fixed_wait_cycles_read := true;
    shared_sbi_vvc_config(1).bfm_config.fixed_wait_cycles_read := 2;
    wait for 3*C_CLK_PERIOD; -- Wait for reset being released in test harness

    -- release reset to DUT
    rst <= '0';

    while test_suite loop
      --------------------------------------------------------------------------------------
      -- Verifying
      --------------------------------------------------------------------------------------
      if run("fixed_wait_read_test") then

        log(ID_LOG_HDR, "Check that the fixed wait cycles are working correct");

        enable_log_msg(VVC_BROADCAST, ALL_MESSAGES);

        -- Fill FIFO 1
        sbi_write(SBI_VVCT,1, x"00", x"01", "Set Register 0");
        await_completion(SBI_VVCT,C_VVCT_ALL_INSTANCES, 1000 ns, "Await execution for both VVCs");

        wait until rising_edge(clk);
        v_timestamp := now;
        sbi_read(SBI_VVCT,1, x"00", "Reading from Register 0");
        v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 1);
        await_completion(SBI_VVCT,1, 100 ns, "Await execution");
        fetch_result(SBI_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
        check_value(((now - v_timestamp) = C_CLK_PERIOD*3.25), ERROR, "Checking that timing was upheld");
        report(to_string(v_result_from_fetch(7 downto 0)));
        check_value(x"01" , v_result_from_fetch(7 downto 0), ERROR, "checking read value");

        shared_sbi_vvc_config(1).bfm_config.fixed_wait_cycles_read := 1; -- setting fixed_wait_cycles_read to one leading to wrong data
        sbi_write(SBI_VVCT,1, x"00", x"55", "Set Register 0 to a new value");
        await_completion(SBI_VVCT,1, 1000 ns, "Await execution of VVC");

        wait until rising_edge(clk);
        v_timestamp := now;
        sbi_read(SBI_VVCT,1, x"00", "Reading from Register 0");
        v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 1);
        await_completion(SBI_VVCT,1, 100 ns, "Await execution");
        fetch_result(SBI_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
        increment_expected_alerts(warning, 2);
        check_value(((now - v_timestamp) = C_CLK_PERIOD*3.25), WARNING, "The read should only take 2.25 clk_periods and therefore throw a warning");
        check_value(v_result_from_fetch(7 downto 0), x"55" , WARNING, "checking read value should lead to a warning");

        check_value(((now - v_timestamp) = C_CLK_PERIOD*2.25), ERROR, "Checking that the read took 2.25 clk_periods");
        check_value(v_result_from_fetch(7 downto 0), x"00" , ERROR, "Reading to fast should return 00");


        shared_sbi_vvc_config(1).bfm_config.fixed_wait_cycles_read := 2; -- setting fixed_wait_cycles_read to one leading to wrong data


      end if;
    end loop;
    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;  -- to allow some time for completion
    report_alert_counters(VOID);
    log(ID_LOG_HDR, "SIMULATION COMPLETED");

    -- Cleanup VUnit. The UVVM-Util error status is imported into VUnit at this
    -- point. This is neccessary when the UVVM-Util alert stop limit is set such that
    -- UVVM-Util doesn't stop on the first error. In that case VUnit has no way of
    -- knowing the error status unless you tell it.
    for alert_level in NOTE to t_alert_level'right loop
      if alert_level /= MANUAL_CHECK and get_alert_counter(alert_level, REGARD) /= get_alert_counter(alert_level, EXPECT) then
        v_alert_num_mismatch := true;
      end if;
    end loop;

    test_runner_cleanup(runner, v_alert_num_mismatch);
    wait;

  end process p_main;



end func;
