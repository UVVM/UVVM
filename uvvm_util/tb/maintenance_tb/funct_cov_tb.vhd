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


-- Test case entity
entity funct_cov_tb is
  generic(
    GC_TEST : string  := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of funct_cov_tb is

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_cov_point : t_cov_point;
    variable v_addr       : std_logic_vector(1 downto 0);

  begin

    set_alert_stop_limit(TB_ERROR,0); --TODO: remove

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Functional Coverage package");
    --------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing add_bin()");
    v_cov_point.add_bin_single(1, 5, 2, "val1");
    v_cov_point.add_bin_single(2, 5, "val2");
    v_cov_point.add_bin_single(3, "val3");
    v_cov_point.add_bin_multiple((0,2,4,6), 5, 2, "set1");
    v_cov_point.add_bin_multiple((1,3,5,7), 5, "set2");
    v_cov_point.add_bin_multiple((8,9,10), "set3");
    v_cov_point.add_bins_range(0, 5, 1, 5, 2, "split_range1");
    v_cov_point.add_bins_range(6, 10, 1, 5, "split_range2");
    v_cov_point.add_bins_range(0, 10, 1, "split_range3");
    v_cov_point.add_bin_range(0, 5, 5, 2, "range1");
    v_cov_point.add_bin_range(6, 10, 5, "range2");
    v_cov_point.add_bin_range(0, 10, "range3");
    v_cov_point.add_bins_slv(v_addr, 5, 2, "addr1");
    v_cov_point.add_bins_slv(v_addr, 5, "addr2");
    v_cov_point.add_bins_slv(v_addr, "addr3");

    v_cov_point.sample_coverage(0);
    v_cov_point.sample_coverage(5);
    v_cov_point.sample_coverage(20);
    v_cov_point.print_summary(VOID);


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