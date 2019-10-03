--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
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

library bitvis_vip_ethernet;
context bitvis_vip_ethernet.hvvc_context;

-- Test case entity
entity ethernet_gmii_tb is
  generic (
    -- This generic is used to configure the testbench from run.py, e.g. what
    -- test case to run. The default value is used when not running from script
    -- and in that case all test cases are run.
    runner_cfg : runner_cfg_t := runner_cfg_default);
end entity ethernet_gmii_tb;

-- Test case architecture
architecture func of ethernet_gmii_tb is

  constant C_CLK_PERIOD   : time := 8 ns;    -- **** Trenger metode for setting av clk period
  constant C_SCOPE        : string := "GMII_VVC_TB";

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_ethernet.gmii_test_harness generic map(GC_CLK_PERIOD => C_CLK_PERIOD);

  i_ti_uvvm_engine  : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    variable v_alert_num_mismatch : boolean := false;
    variable v_cmd_idx            : natural;
    variable v_send_data          : t_byte_array(0 to 150);
    variable v_receive_data       : t_vvc_result;
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


    log(ID_LOG_HDR_LARGE, "START SIMULATION OF ETHERNET VVC");

    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"02");


    log(ID_LOG_HDR, "Send 10 bytes of data from i1 to i2");
    for i in 0 to 9 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to 9), "Send random data from instance 1.");
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.");
    v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 2, RX);
    await_completion(ETHERNET_VVCT, 2, RX, 1 us, "Wait for read to finish.");

    log(ID_LOG_HDR, "Fetch data from i2");
    fetch_result(ETHERNET_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

    check_value(v_receive_data.ethernet_frame.mac_destination = (x"00", x"00", x"00", x"00", x"00", x"02"), ERROR, "Verify MAC destination.");
    check_value(v_receive_data.ethernet_frame.mac_source      = (x"00", x"00", x"00", x"00", x"00", x"01"), ERROR, "Verify MAC source.");
    check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");
    for i in 0 to 9 loop
      check_value(v_receive_data.ethernet_frame.payload(i), v_send_data(i), ERROR, "Verify received payload, byte " & to_string(i) & ".");
    end loop;


    log(ID_LOG_HDR, "Send 5 bytes of data from i1 to i2");
    for i in 0 to 4 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to 4), "Send random data from instance 1.");
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.");
    v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 2, RX);
    await_completion(ETHERNET_VVCT, 2, RX, 2 us, "Wait for read to finish.");

    log(ID_LOG_HDR, "Fetch data from i2");
    fetch_result(ETHERNET_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

    check_value(v_receive_data.ethernet_frame.mac_destination = (x"00", x"00", x"00", x"00", x"00", x"02"), ERROR, "Verify MAC destination.");
    check_value(v_receive_data.ethernet_frame.mac_source      = (x"00", x"00", x"00", x"00", x"00", x"01"), ERROR, "Verify MAC source.");
    check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");
    for i in 0 to 4 loop
      check_value(v_receive_data.ethernet_frame.payload(i), v_send_data(i), ERROR, "Verify received payload, byte " & to_string(i) & ".");
    end loop;



    for i in 0 to 19 loop
      log(ID_LOG_HDR, "Send 1 byte of data from i1 to i2: byte " & to_string(i));
      v_send_data(0) := random(8);
      ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to 0), "Send random data from instance 1.");
      ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.");
      v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 2, RX);
      await_completion(ETHERNET_VVCT, 2, RX, 2 us, "Wait for read to finish.");

      log(ID_LOG_HDR, "Fetch data from i2");
      fetch_result(ETHERNET_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

      check_value(v_receive_data.ethernet_frame.mac_destination = (x"00", x"00", x"00", x"00", x"00", x"02"), ERROR, "Verify MAC destination.");
      check_value(v_receive_data.ethernet_frame.mac_source      = (x"00", x"00", x"00", x"00", x"00", x"01"), ERROR, "Verify MAC source.");
      check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");
      check_value(v_receive_data.ethernet_frame.payload(0), v_send_data(0), ERROR, "Verify received payload.");
    end loop;

    log(ID_LOG_HDR_LARGE, "VERIFY EXPECT");
    for i in 0 to 4 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to 4), "Send random data from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, v_send_data(0 to 4), "Expect random data from instance 1.");
    await_completion(ETHERNET_VVCT, 2, RX, 2 us, "Wait for read to finish.");


    for i in 0 to 150 loop
      v_send_data(i) := random(8);
    end loop;
    -- Expect ERROR
    increment_expected_alerts_and_stop_limit(ERROR);
    ethernet_send(ETHERNET_VVCT, 2, TX, v_send_data(0 to 150), "Send random data from instance 2.");
    v_send_data(100) := not v_send_data(100);
    ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data(0 to 150), "Expect random data from instance 2.");
    await_completion(ETHERNET_VVCT, 1, RX, 2 us, "Wait for read to finish.");


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
    std.env.stop;

  end process p_main;

end architecture func;