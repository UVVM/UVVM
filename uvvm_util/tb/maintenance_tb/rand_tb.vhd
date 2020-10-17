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
entity rand_tb is
  generic(
    GC_TEST : string  := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of rand_tb is

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_rand     : t_rand;
    variable v_seeds    : t_positive_vector(0 to 1);
    variable v_int      : integer;
    variable v_real     : real;
    variable v_time     : time;
    variable v_int_vec  : integer_vector(0 to 4);
    variable v_real_vec : real_vector(0 to 4);
    variable v_time_vec : time_vector(0 to 4);
    variable v_uns      : unsigned(7 downto 0);
    variable v_sig      : signed(7 downto 0);
    variable v_slv      : std_logic_vector(7 downto 0);
    variable v_std      : std_logic;
    variable v_bln      : boolean;

  begin

    set_alert_stop_limit(TB_ERROR,0); --TODO: remove

    increment_expected_alerts(TB_WARNING, 1);

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Randomization package");
    --------------------------------------------------------------------------------
    --TODO: test actual implementation
    log(ID_LOG_HDR, "Testing seeds");
    v_rand.set_rand_seeds("test_string");
    v_rand.set_rand_seeds(v_seeds(0), v_seeds(1));
    v_rand.set_rand_seeds(v_seeds);
    v_rand.get_rand_seeds(v_seeds(0), v_seeds(1));
    v_seeds := v_rand.get_rand_seeds(VOID);
    
    --TODO: test actual implementation
    log(ID_LOG_HDR, "Testing distributions");
    v_rand.set_rand_dist(GAUSSIAN);
    v_rand.set_rand_dist(UNIFORM);

    v_rand.set_scope("MY SCOPE");

    --TODO: for all rand() test corner cases
    --      *negative values
    --      *min & max range: within length limits (uns,sig,slv), inverted order
    --      *set of values: within length limits (uns,sig,slv), only 1 value
    --      *real: use different decimals
    --      *time: use different time units
    -- We could either have an overload with integer instead of integer_vector OR use a function to return integer_vector: INCL/EXCL? VECTOR?
    ------------------------------------------------------------
    -- Integer
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing integer (min/max)");
    for i in 0 to 4 loop
      v_int := v_rand.rand(-2, 2);
      log("v_int:" & to_string(v_int));
    end loop;

    log(ID_LOG_HDR, "Testing integer (set of values)");
    for i in 0 to 4 loop
      v_int := v_rand.rand(ONLY,(-2,0,2));
      log("v_int:" & to_string(v_int));
    end loop;

    log(ID_LOG_HDR, "Testing integer (min/max + set of values)");
    for i in 0 to 4 loop
      v_int := v_rand.rand(-2, 2, INCL,(15,16,17));
      log("v_int:" & to_string(v_int));
    end loop;
    for i in 0 to 4 loop
      v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1));
      log("v_int:" & to_string(v_int));
    end loop;
    for i in 0 to 4 loop
      v_int := v_rand.rand(-2, 2, INCL,(15,16,17), EXCL,(-1,0,1));
      log("v_int:" & to_string(v_int));
    end loop;
    for i in 0 to 4 loop
      v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1), INCL,(15,16,17));
      log("v_int:" & to_string(v_int));
    end loop;
    for i in 0 to 4 loop
      v_int := v_rand.rand(-2, 2, INCL,(15,16), INCL,(17,18));
      log("v_int:" & to_string(v_int));
    end loop;
    for i in 0 to 4 loop
      v_int := v_rand.rand(-3, 3, EXCL,(-2,-1,0), EXCL,(1,2));
      log("v_int:" & to_string(v_int));
    end loop;

    ------------------------------------------------------------
    -- Integer Vector
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing integer_vector (min/max)");
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2);
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, UNIQUE);
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;

    log(ID_LOG_HDR, "Testing integer_vector (set of values)");
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2));
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), UNIQUE);
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;

    log(ID_LOG_HDR, "Testing integer_vector (min/max + set of values)");
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-3,3));
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-3,3), UNIQUE);
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 5, EXCL,(-1,0,1), UNIQUE);
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-3,3), EXCL,(-1,0,1));
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-3,3,4), EXCL,(-1,0,1), UNIQUE);
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;
    for i in 0 to 4 loop
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-3,3), INCL,(4,5), UNIQUE);
      log("v_int_vec:" & to_string(v_int_vec));
    end loop;

    ------------------------------------------------------------
    -- Real
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing real (min/max)");
    for i in 0 to 4 loop
      v_real := v_rand.rand(-2.0, 2.0);
      log("v_real:" & to_string(v_real));
    end loop;

    log(ID_LOG_HDR, "Testing real (set of values)");
    for i in 0 to 4 loop
      v_real := v_rand.rand(ONLY,(-2.0,0.1234,2.0));
      log("v_real:" & to_string(v_real));
    end loop;

    log(ID_LOG_HDR, "Testing real (min/max + set of values)");
    for i in 0 to 4 loop
      v_real := v_rand.rand(-2.0, 2.0, INCL,(15.0,16.0,17.0));
      log("v_real:" & to_string(v_real));
    end loop;
    for i in 0 to 4 loop
      v_real := v_rand.rand(-2.0, 2.0, EXCL,(-1.0,0.0,1.0));
      log("v_real:" & to_string(v_real));
    end loop;
    for i in 0 to 4 loop
      v_real := v_rand.rand(-2.0, 2.0, INCL,(15.0,16.0,17.0), EXCL,(-1.0,0.0,1.0));
      log("v_real:" & to_string(v_real));
    end loop;
    for i in 0 to 4 loop
      v_real := v_rand.rand(-2.0, 2.0, EXCL,(-1.0,0.0,1.0), INCL,(15.0,16.0,17.0));
      log("v_real:" & to_string(v_real));
    end loop;
    for i in 0 to 4 loop
      v_real := v_rand.rand(-2.0, 2.0, INCL,(15.0,16.0), INCL,(17.0,18.0));
      log("v_real:" & to_string(v_real));
    end loop;
    for i in 0 to 4 loop
      v_real := v_rand.rand(-3.0, 3.0, EXCL,(-2.0,-1.0,0.0), EXCL,(1.0,2.0));
      log("v_real:" & to_string(v_real));
    end loop;

    ------------------------------------------------------------
    -- Real Vector
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing real_vector (min/max)");
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0);
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, UNIQUE);
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;

    log(ID_LOG_HDR, "Testing real_vector (set of values)");
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.0,0.0,1.0,2.0));
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.0,0.0,1.0,2.0), UNIQUE);
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;

    log(ID_LOG_HDR, "Testing real_vector (min/max + set of values)");
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(-3.0,3.0));
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(-3.0,3.0), UNIQUE);
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 5.0, EXCL,(-1.0,0.0,1.0), UNIQUE);
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(-3.0,3.0), EXCL,(-1.0,0.0,1.0));
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(-3.0,3.0,4.0), EXCL,(-1.0,0.0,1.0), UNIQUE);
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;
    for i in 0 to 4 loop
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(-3.0,3.0), INCL,(4.0,5.0), UNIQUE);
      log("v_real_vec:" & to_string(v_real_vec));
    end loop;

    ------------------------------------------------------------
    -- Time
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing time (min/max)");
    for i in 0 to 4 loop
      v_time := v_rand.rand(-2 ps, 2 ps);
      log("v_time:" & to_string(v_time));
    end loop;

    log(ID_LOG_HDR, "Testing time (set of values)");
    for i in 0 to 4 loop
      v_time := v_rand.rand(ONLY,(-2 ps,0 ps,2 ps));
      log("v_time:" & to_string(v_time));
    end loop;

    log(ID_LOG_HDR, "Testing time (min/max + set of values)");
    for i in 0 to 4 loop
      v_time := v_rand.rand(-2 ps, 2 ps, INCL,(15 ps,16 ps,17 ps));
      log("v_time:" & to_string(v_time));
    end loop;
    for i in 0 to 4 loop
      v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps));
      log("v_time:" & to_string(v_time));
    end loop;
    for i in 0 to 4 loop
      v_time := v_rand.rand(-2 ps, 2 ps, INCL,(15 ps,16 ps,17 ps), EXCL,(-1 ps,0 ps,1 ps));
      log("v_time:" & to_string(v_time));
    end loop;
    for i in 0 to 4 loop
      v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(15 ps,16 ps,17 ps));
      log("v_time:" & to_string(v_time));
    end loop;
    for i in 0 to 4 loop
      v_time := v_rand.rand(-2 ps, 2 ps, INCL,(15 ps,16 ps), INCL,(17 ps,18 ps));
      log("v_time:" & to_string(v_time));
    end loop;
    for i in 0 to 4 loop
      v_time := v_rand.rand(-3 ps, 3 ps, EXCL,(-2 ps,-1 ps,0 ps), EXCL,(1 ps,2 ps));
      log("v_time:" & to_string(v_time));
    end loop;

    ------------------------------------------------------------
    -- Time Vector
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing time_vector (min/max)");
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps);
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, UNIQUE);
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;

    log(ID_LOG_HDR, "Testing time_vector (set of values)");
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps));
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps), UNIQUE);
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;

    log(ID_LOG_HDR, "Testing time_vector (min/max + set of values)");
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-3 ps,3 ps));
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-3 ps,3 ps), UNIQUE);
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 5 ps, EXCL,(-1 ps,0 ps,1 ps), UNIQUE);
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-3 ps,3 ps), EXCL,(-1 ps,0 ps,1 ps));
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-3 ps,3 ps,4 ps), EXCL,(-1 ps,0 ps,1 ps), UNIQUE);
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;
    for i in 0 to 4 loop
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-3 ps,3 ps), INCL,(4 ps,5 ps), UNIQUE);
      log("v_time_vec:" & to_string(v_time_vec));
    end loop;

    ------------------------------------------------------------
    -- Unsigned
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing unsigned (length)");
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length);
      log("v_uns:" & to_hstring(v_uns));
    end loop;

    log(ID_LOG_HDR, "Testing unsigned (min/max)");
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, 0, 3);
      log("v_uns:" & to_hstring(v_uns));
    end loop;

    log(ID_LOG_HDR, "Testing unsigned (set of values)");
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, ONLY,(0,1,2));
      log("v_uns:" & to_hstring(v_uns));
    end loop;
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, EXCL,(0,1,2));
      log("v_uns:" & to_hstring(v_uns));
    end loop;

    log(ID_LOG_HDR, "Testing unsigned (min/max + set of values)");
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(15,16,17));
      log("v_uns:" & to_hstring(v_uns));
    end loop;
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, 0, 3, EXCL,(1,2));
      log("v_uns:" & to_hstring(v_uns));
    end loop;
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(15,16,17), EXCL,(1,2));
      log("v_uns:" & to_hstring(v_uns));
    end loop;
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, 0, 2, EXCL,(1,2), INCL,(15,16,17));
      log("v_uns:" & to_hstring(v_uns));
    end loop;
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(15,16), INCL,(17,18));
      log("v_uns:" & to_hstring(v_uns));
    end loop;
    for i in 0 to 4 loop
      v_uns := v_rand.rand(v_uns'length, 0, 5, EXCL,(1,2), EXCL,(0,3));
      log("v_uns:" & to_hstring(v_uns));
    end loop;

    ------------------------------------------------------------
    -- Std_logic_vector
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing std_logic_vector (length)");
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length);
      log("v_slv:" & to_hstring(v_slv));
    end loop;

    log(ID_LOG_HDR, "Testing std_logic_vector (min/max)");
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, 0, 3);
      log("v_slv:" & to_hstring(v_slv));
    end loop;

    log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, ONLY,(0,1,2));
      log("v_slv:" & to_hstring(v_slv));
    end loop;
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, EXCL,(0,1,2));
      log("v_slv:" & to_hstring(v_slv));
    end loop;

    log(ID_LOG_HDR, "Testing std_logic_vector (min/max + set of values)");
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(15,16,17));
      log("v_slv:" & to_hstring(v_slv));
    end loop;
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, 0, 3, EXCL,(1,2));
      log("v_slv:" & to_hstring(v_slv));
    end loop;
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(15,16,17), EXCL,(1,2));
      log("v_slv:" & to_hstring(v_slv));
    end loop;
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, 0, 2, EXCL,(1,2), INCL,(15,16,17));
      log("v_slv:" & to_hstring(v_slv));
    end loop;
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(15,16), INCL,(17,18));
      log("v_slv:" & to_hstring(v_slv));
    end loop;
    for i in 0 to 4 loop
      v_slv := v_rand.rand(v_slv'length, 0, 5, EXCL,(1,2), EXCL,(0,3));
      log("v_slv:" & to_hstring(v_slv));
    end loop;

    ------------------------------------------------------------
    -- Std_logic & boolean
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Testing std_logic & boolean");
    for i in 0 to 4 loop
      v_std := v_rand.rand(VOID);
      log("v_std:" & to_string(v_std));
    end loop;
    for i in 0 to 4 loop
      v_bln := v_rand.rand(VOID);
      log("v_bln:" & to_string(v_bln));
    end loop;

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