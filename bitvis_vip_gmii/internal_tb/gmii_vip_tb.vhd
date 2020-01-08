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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

-- Test case entity
entity gmii_vip_tb is
  generic (
    GC_TEST : string := "UVVM"
    );
end entity;

-- Test case architecture
architecture func of gmii_vip_tb is

  constant C_CLK_PERIOD   : time := 8 ns;    -- **** Trenger metode for setting av clk period
  constant C_SCOPE        : string := "GMII_VVC_TB";

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_gmii.test_harness generic map(GC_CLK_PERIOD => C_CLK_PERIOD);

  i_ti_uvvm_engine  : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    variable v_alert_num_mismatch : boolean := false;
    variable v_cmd_idx            : natural;
    variable v_send_data          : t_byte_array(0 to 9);
    variable v_receive_data       : t_vvc_result;
  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    await_uvvm_initialization(VOID);


    log(ID_LOG_HDR_LARGE, "START SIMULATION OF GMII VVC");


    log(ID_LOG_HDR, "Send 10 bytes of data from i1 to i2");
    for i in 0 to 9 loop
      v_send_data(i) := random(8);
    end loop;
    gmii_write(GMII_VVCT, 1, TX, v_send_data, "Send random data from instance 1.");
    gmii_read(GMII_VVCT, 2, RX, 10, "Read random data from instance 1.");
    v_cmd_idx := shared_cmd_idx;
    await_completion(GMII_VVCT, 2, RX, 1 us, "Wait for read to finish.");

    log(ID_LOG_HDR, "Fetch data from i2");
    fetch_result(GMII_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

    for i in 0 to 9 loop
      check_value(v_receive_data(i), v_send_data(i), ERROR, "Verify received data byte " & to_string(i) & ".");
    end loop;


    log(ID_LOG_HDR, "Send 5 bytes of data from i1 to i2");
    for i in 0 to 4 loop
      v_send_data(i) := random(8);
    end loop;
    gmii_write(GMII_VVCT, 1, TX, v_send_data(0 to 4), "Send random data from instance 1.");
    gmii_read(GMII_VVCT, 2, RX, 5, "Read random data from instance 1.");
    v_cmd_idx := shared_cmd_idx;
    await_completion(GMII_VVCT, 2, RX, 1 us, "Wait for read to finish.");

    log(ID_LOG_HDR, "Fetch data from i2");
    fetch_result(GMII_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

    for i in 0 to 4 loop
      check_value(v_receive_data(i), v_send_data(i), ERROR, "Verify received data byte " & to_string(i) & ".");
    end loop;



    for i in 0 to 19 loop
      log(ID_LOG_HDR, "Send 1 byte of data from i1 to i2: byte " & to_string(i));
      v_send_data(0) := random(8);
      gmii_write(GMII_VVCT, 1, TX, v_send_data(0 to 0), "Send random data from instance 1.");
      gmii_read(GMII_VVCT, 2, RX, 1, "Read random data from instance 1.");
      v_cmd_idx := shared_cmd_idx;
      await_completion(GMII_VVCT, 2, RX, 1 us, "Wait for read to finish.");

      log(ID_LOG_HDR, "Fetch data from i2");
      fetch_result(GMII_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

      check_value(v_receive_data(0), v_send_data(0), ERROR, "Verify single received data byte " & to_string(i) & ".");
    end loop;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end architecture func;