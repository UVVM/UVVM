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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--HDLUnit:TB
entity funct_cov_tb is
  generic(
    GC_TESTCASE : string
  );
end entity;

architecture func of funct_cov_tb is

  shared variable v_coverpoint : t_coverpoint;

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_value  : integer;
    variable v_vector : std_logic_vector(1 downto 0);

  begin

    -------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Functional Coverage package - " & GC_TESTCASE);
    -------------------------------------------------------------------------------------------
    enable_log_msg(ID_FUNCT_COV);
    enable_log_msg(ID_FUNCT_COV_BINS);
    enable_log_msg(ID_FUNCT_COV_RAND);
    enable_log_msg(ID_FUNCT_COV_SAMPLE);
    enable_log_msg(ID_FUNCT_COV_CONFIG);

    --===================================================================================
    if GC_TESTCASE = "basic" then
    --===================================================================================
      v_coverpoint.set_name("MY_COVERPOINT");
      check_value("MY_COVERPOINT", v_coverpoint.get_name(VOID), ERROR, "Checking name");
      v_coverpoint.set_scope("MY_SCOPE");
      check_value("MY_SCOPE", v_coverpoint.get_scope(VOID), ERROR, "Checking scope");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin functions");
      ------------------------------------------------------------
      v_coverpoint.add_bins(bin(-1));
      v_coverpoint.add_bins(bin(0));
      v_coverpoint.add_bins(bin(1));

      v_coverpoint.add_bins(bin((2,4,6,8)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(bin((10,11,12,13,14,15,16,17,18,19,20)));

      v_coverpoint.add_bins(bin_range(21,30,1));
      v_coverpoint.add_bins(bin_range(31,35,2));
      v_coverpoint.add_bins(bin_range(36,40,20));
      v_coverpoint.add_bins(bin_range(41,43));
      v_coverpoint.add_bins(bin_range(45,45));
      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_coverpoint.add_bins(bin_range(43,41));

      v_coverpoint.add_bins(bin_vector(v_vector,1));
      v_coverpoint.add_bins(bin_vector(v_vector,2));
      v_coverpoint.add_bins(bin_vector(v_vector,20));
      v_coverpoint.add_bins(bin_vector(v_vector));

      v_coverpoint.add_bins(bin_transition((51,53,55,59)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(bin_transition((60,61,62,63,64,65,66,67,68,69,70)));

      v_coverpoint.add_bins(ignore_bin(-101));
      v_coverpoint.add_bins(ignore_bin(100));
      v_coverpoint.add_bins(ignore_bin(101));

      v_coverpoint.add_bins(ignore_bin_range(110,120));
      v_coverpoint.add_bins(ignore_bin_range(125,125));
      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_coverpoint.add_bins(ignore_bin_range(129,126));

      v_coverpoint.add_bins(ignore_bin_transition((131,133,135,139)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(ignore_bin_transition((140,141,142,143,144,145,146,147,148,149,150)));

      v_coverpoint.add_bins(illegal_bin(-201));
      v_coverpoint.add_bins(illegal_bin(200));
      v_coverpoint.add_bins(illegal_bin(201));

      v_coverpoint.add_bins(illegal_bin_range(210,220));
      v_coverpoint.add_bins(illegal_bin_range(225,225));
      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_coverpoint.add_bins(illegal_bin_range(229,226));

      v_coverpoint.add_bins(illegal_bin_transition((231,233,235,239)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(illegal_bin_transition((240,241,242,243,244,245,246,247,248,249,250)));

      v_coverpoint.print_summary(VOID);

      --------------------------------------------------------------
      --log(ID_LOG_HDR, "Testing uninitialized coverpoint");
      --------------------------------------------------------------
      --increment_expected_alerts_and_stop_limit(TB_FAILURE,10);
      --v_coverpoint.set_name("MY_COVERPOINT");
      --v_coverpoint.set_scope("MY_SCOPE");
      --v_coverpoint.set_coverage_weight(5);
      --v_coverpoint.set_coverage_goal(5);
      --v_coverpoint.set_illegal_bin_alert_level(FAILURE);
      --v_coverpoint.detect_bin_overlap(true);
      --v_coverpoint.write_coverage_db("file.txt");
      --v_value := v_coverpoint.rand(VOID);
      --log(to_string(v_coverpoint.is_defined(VOID)));
      --v_coverpoint.sample_coverage(5);
      --log(to_string(v_coverpoint.get_coverage(VOID)));
      --log(to_string(v_coverpoint.coverage_completed(VOID)));
      --v_coverpoint.print_summary(VOID);

    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- Allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED");
    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end architecture func;