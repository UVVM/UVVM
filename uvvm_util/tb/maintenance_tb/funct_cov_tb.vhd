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

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_cov_point : t_cov_point;
    variable v_value     : integer;
    variable v_slv       : std_logic_vector(1 downto 0);

  begin

    set_alert_stop_limit(TB_ERROR,0); --TODO: remove

    -------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Functional Coverage package - " & GC_TESTCASE);
    -------------------------------------------------------------------------------------------
    enable_log_msg(ID_FUNCT_COV);

    --===================================================================================
    if GC_TESTCASE = "test" then
    --===================================================================================
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing add_bin()");
      ------------------------------------------------------------
      v_cov_point.add_bins(bin(1), 5, 2, "val1");
      v_cov_point.add_bins(bin(2), 5, "val2");
      v_cov_point.add_bins(bin(3), "val3");
      v_cov_point.add_bins(bin((0,2,4,6)), 5, 2, "set1");
      v_cov_point.add_bins(bin((1,3,5,7)), 5, "set2");
      v_cov_point.add_bins(bin((8,9,10)), "set3");
      v_cov_point.add_bins(bin_range(0, 5, 1), 5, 2, "split_range1");
      v_cov_point.add_bins(bin_range(6, 10, 1), 5, "split_range2");
      v_cov_point.add_bins(bin_range(0, 10, 2), "split_range3");
      v_cov_point.add_bins(bin_range(0, 5), 5, 2, "range1");
      v_cov_point.add_bins(bin_range(6, 10), 5, "range2");
      v_cov_point.add_bins(bin_range(0, 10), "range3");
      v_cov_point.add_bins(bin_vector(v_slv), 5, 2, "addr1");
      v_cov_point.add_bins(bin_vector(v_slv), 5, "addr2");
      v_cov_point.add_bins(bin_vector(v_slv), "addr3");
      v_cov_point.add_bins(bin_transition((1,3,5,7)), 1, 1, "transition_odd");
      v_cov_point.add_bins(bin_transition((2,4,6,8)), 1, 1, "transition_even");
      v_cov_point.add_bins(ignore_bin(0), "ignore1");
      v_cov_point.add_bins(ignore_bin(255), "ignore2");
      v_cov_point.add_bins(illegal_bin(256), "illegal");
      v_cov_point.add_bins(bin(50) & bin((100,200,300)) & bin_range(50, 100, 2), 5, 2, "single_line");

      v_cov_point.sample_coverage(0);
      v_cov_point.sample_coverage(1);
      v_cov_point.sample_coverage(3);
      v_cov_point.sample_coverage(5);
      v_cov_point.sample_coverage(7);
      v_cov_point.sample_coverage(2);
      v_cov_point.sample_coverage(4);
      v_cov_point.sample_coverage(6);
      v_cov_point.sample_coverage(8);
      v_cov_point.sample_coverage(255);
      increment_expected_alerts(TB_WARNING, 1);
      v_cov_point.sample_coverage(256);
      v_cov_point.print_summary(VOID);

      --------------------------------------------------------------
      --log(ID_LOG_HDR, "Testing rand()");
      --------------------------------------------------------------
      --enable_log_msg(ID_RAND_GEN);

      --v_cov_point.add_bins(bin(5), 5, 2, "val1");
      --v_cov_point.add_bins(bin((10,12,14)), 5, 1, "val2");
      --v_cov_point.add_bins(bin_range(15,20,1), 5, 1, "val3");
      --for i in 0 to 99 loop
      --  v_value := v_cov_point.rand;
      --  v_cov_point.sample_coverage(v_value);
      --end loop;

      ---- one bin stops generating values
      --v_cov_point.add_bins(bin(5), 20, 1, "val1");
      --v_cov_point.add_bins(bin((10,12,14)), 50, 1, "val2");
      --v_cov_point.add_bins(bin_range(15,20,1), 50, 1, "val3");
      --for i in 0 to 99 loop
      --  v_value := v_cov_point.rand;
      --  v_cov_point.sample_coverage(v_value);
      --end loop;

      ---- one bin stops generating values then resumes when others reach their goal
      --v_cov_point.add_bins(bin(5), 20, 1, "val1");
      --v_cov_point.add_bins(bin((10,12,14)), 30, 1, "val2");
      --v_cov_point.add_bins(bin_range(15,20,1), 30, 1, "val3");
      --for i in 0 to 99 loop
      --  v_value := v_cov_point.rand;
      --  v_cov_point.sample_coverage(v_value);
      --end loop;

      ---- ignore and illegal
      --v_cov_point.add_bins(bin(5), 20, 1, "val1");
      --v_cov_point.add_bins(bin((10,12,14)), 30, 1, "val2");
      --v_cov_point.add_bins(bin_range(15,20,1), 30, 1, "val3");
      --v_cov_point.add_bins(ignore_bin(100), 20, 1, "val1");
      --v_cov_point.add_bins(illegal_bin(200), 20, 1, "val1");
      --for i in 0 to 99 loop
      --  v_value := v_cov_point.rand;
      --  v_cov_point.sample_coverage(v_value);
      --end loop;

      ---- transition
      --v_cov_point.add_bins(bin(5), 10, 1, "val1");
      --v_cov_point.add_bins(bin_transition((10,12,14)), 30, 1, "val2");
      --v_cov_point.add_bins(bin_range(15,20,1), 30, 1, "val3");
      --for i in 0 to 99 loop
      --  v_value := v_cov_point.rand;
      --  v_cov_point.sample_coverage(v_value);
      --end loop;

      --v_cov_point.print_summary(VOID);
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