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

use work.rand_tb_pkg.all;

-- Test case entity
entity rand_tb is
  generic(
    GC_TEST : string  := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of rand_tb is

  constant C_NUM_RAND_REPETITIONS : natural := 5;
  constant C_NUM_DIST_REPETITIONS : natural := 1000; -- Changing this value affects print_and_check_weights() C_MARGIN.

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
    variable v_uns_long : unsigned(39 downto 0);
    variable v_sig      : signed(7 downto 0);
    variable v_sig_long : signed(39 downto 0);
    variable v_slv      : std_logic_vector(7 downto 0);
    variable v_slv_long : std_logic_vector(39 downto 0);
    variable v_std      : std_logic;
    variable v_bln      : boolean;
    variable v_weight_cnt : t_integer_cnt(-10 to 10) := (others => 0);

  begin

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Randomization package - " & GC_TEST);
    --------------------------------------------------------------------------------

    --===================================================================================
    if GC_TEST = "basic_rand" then
    --===================================================================================
      increment_expected_alerts(TB_WARNING, 1);

      --TODO: test actual implementation
      log(ID_LOG_HDR, "Testing distributions");
      v_rand.set_rand_dist(GAUSSIAN);
      v_rand.set_rand_dist(UNIFORM);

      v_rand.set_scope("MY SCOPE");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing seeds");
      ------------------------------------------------------------
      log(ID_SEQUENCER, "Check default seed values");
      v_seeds := v_rand.get_rand_seeds(VOID);
      check_value(v_seeds(0), C_INIT_SEED_1, ERROR, "Checking initial seed 1");
      check_value(v_seeds(1), C_INIT_SEED_2, ERROR, "Checking initial seed 2");

      log(ID_SEQUENCER, "Set and get seeds with vector value");
      v_seeds(0) := 500;
      v_seeds(1) := 5000;
      v_rand.set_rand_seeds(v_seeds);
      v_seeds := v_rand.get_rand_seeds(VOID);
      check_value(v_seeds(0), 500, ERROR, "Checking seed 1");
      check_value(v_seeds(1), 5000, ERROR, "Checking seed 2");

      log(ID_SEQUENCER, "Set and get seeds with positive values");
      v_seeds(0) := 800;
      v_seeds(1) := 8000;
      v_rand.set_rand_seeds(v_seeds(0), v_seeds(1));
      v_rand.get_rand_seeds(v_seeds(0), v_seeds(1));
      check_value(v_seeds(0), 800, ERROR, "Checking seed 1");
      check_value(v_seeds(1), 8000, ERROR, "Checking seed 2");

      log(ID_SEQUENCER, "Set seeds with string value");
      v_rand.set_rand_seeds("test_string");
      v_seeds := v_rand.get_rand_seeds(VOID);
      check_value(v_seeds(0) /= 800, ERROR, "Checking initial seed 1");
      check_value(v_seeds(1) /= 8000, ERROR, "Checking initial seed 2");


      --TODO: for all rand() test corner cases
      --      *check that different random values are generated?
      --         Could store value in an array and check for some threshold (all of them have been selected at least once)
      --      *min/max + set of values (only 1 value)
      --         We could either have an overload with integer instead of integer_vector OR make the user type cast integer_vector
      --      *how to check distributions
      --         Store value in an array and check waveform to see distribution
      ------------------------------------------------------------
      -- Integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2);
        check_rand_value(v_int, -2, 2);
      end loop;

      log(ID_LOG_HDR, "Testing integer (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(ONLY,(-2,0,2));
        check_rand_value(v_int, (-2,0,2));
      end loop;

      log(ID_LOG_HDR, "Testing integer (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, INCL,(-10,15,16));
        check_rand_value(v_int, -2, 2, INCL, (-10,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1));
        check_rand_value(v_int, -2, 2, EXCL,(-1,0,1));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
        check_rand_value(v_int, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
        check_rand_value(v_int, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, INCL,(-10,-11), INCL,(15,16));
        check_rand_value(v_int, -2, 2, INCL, (-10,-11,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-3, 3, EXCL,(-2,-1), EXCL,(1,2));
        check_rand_value(v_int, -3, 3, EXCL, (-2,-1,1,2));
      end loop;

      log(ID_LOG_HDR, "Testing integer (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_int := v_rand.rand(10, 0);

      ------------------------------------------------------------
      -- Integer Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer_vector (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2);
        check_rand_value(v_int_vec, -2, 2);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, UNIQUE);
        check_rand_value(v_int_vec, -2, 2);
      end loop;

      log(ID_LOG_HDR, "Testing integer_vector (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2));
        check_rand_value(v_int_vec, (-2,-1,0,1,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), UNIQUE);
        check_rand_value(v_int_vec, (-2,-1,0,1,2));
      end loop;

      log(ID_LOG_HDR, "Testing integer_vector (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-10,15,16));
        check_rand_value(v_int_vec, -2, 2, INCL,(-10,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-10,15,16), UNIQUE);
        check_rand_value(v_int_vec, -2, 2, INCL,(-10,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), UNIQUE);
        check_rand_value(v_int_vec, -3, 4, EXCL,(-1,0,1));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
        check_rand_value(v_int_vec, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1), UNIQUE);
        check_rand_value(v_int_vec, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16), UNIQUE);
        check_rand_value(v_int_vec, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-10,-11), INCL,(15,16), UNIQUE);
        check_rand_value(v_int_vec, -2, 2, INCL,(-10,-11,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -4, 4, EXCL,(-2,-1), EXCL,(1,2), UNIQUE);
        check_rand_value(v_int_vec, -4, 4, EXCL,(-2,-1,1,2));
      end loop;

      ------------------------------------------------------------
      -- Real
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing real (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(-2.0, 2.0);
        check_rand_value(v_real, -2.0, 2.0);
      end loop;

      log(ID_LOG_HDR, "Testing real (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(ONLY,(-2.0,0.555,2.0));
        check_rand_value(v_real, (-2.0,0.555,2.0));
      end loop;

      log(ID_LOG_HDR, "Testing real (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(-2.0, 2.0, INCL,(15.5,16.6,17.7));
        check_rand_value(v_real, -2.0, 2.0, INCL,(15.5,16.6,17.7));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(-2.0, 2.0, EXCL,(-1.0,0.0,1.0));
        check_rand_value(v_real, -2.0, 2.0, EXCL,(-1.0,0.0,1.0));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(-2.0, 2.0, INCL,(15.5,16.6,17.7), EXCL,(-1.0,0.0,1.0));
        check_rand_value(v_real, -2.0, 2.0, INCL,(15.5,16.6,17.7), EXCL,(-1.0,0.0,1.0));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(-2.0, 2.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6,17.7));
        check_rand_value(v_real, -2.0, 2.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6,17.7));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(-2.0, 2.0, INCL,(15.5,16.6), INCL,(17.7,18.8));
        check_rand_value(v_real, -2.0, 2.0, INCL,(15.5,16.6,17.7,18.8));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real := v_rand.rand(-2.0, 2.0, EXCL,(-2.0,-1.0), EXCL,(1.0,2.0));
        check_rand_value(v_real, -2.0, 2.0, EXCL,(-2.0,-1.0,1.0,2.0));
      end loop;

      log(ID_LOG_HDR, "Testing real (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_real := v_rand.rand(10.0, 0.0);

      ------------------------------------------------------------
      -- Real Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing real_vector (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0);
        check_rand_value(v_real_vec, -2.0, 2.0);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0);
      end loop;

      log(ID_LOG_HDR, "Testing real_vector (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.55,1.1,2.0));
        check_rand_value(v_real_vec, (-2.0,-1.1,0.55,1.1,2.0));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.55,1.1,2.0), UNIQUE);
        check_rand_value(v_real_vec, (-2.0,-1.1,0.55,1.1,2.0));
      end loop;

      log(ID_LOG_HDR, "Testing real_vector (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(15.5,16.6,17.7));
        check_rand_value(v_real_vec, -2.0, 2.0, INCL,(15.5,16.6,17.7));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(15.5,16.6,17.7), UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0, INCL,(15.5,16.6,17.7));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, EXCL,(-1.0,0.0,1.0), UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0, EXCL,(-1.0,0.0,1.0));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(15.5,16.6,17.7), EXCL,(-1.0,0.0,1.0));
        check_rand_value(v_real_vec, -2.0, 2.0, INCL,(15.5,16.6,17.7), EXCL,(-1.0,0.0,1.0));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(15.5,16.6,17.7), EXCL,(-1.0,0.0,1.0), UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0, INCL,(15.5,16.6,17.7), EXCL,(-1.0,0.0,1.0));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6,17.7), UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6,17.7));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, INCL,(15.5,16.6), INCL,(17.7,18.8), UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0, INCL,(15.5,16.6,17.7,18.8));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, EXCL,(-2.0,-1.0), EXCL,(1.0,2.0), UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0, EXCL,(-2.0,-1.0,1.0,2.0));
      end loop;

      ------------------------------------------------------------
      -- Time
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing time (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps);
        check_rand_value(v_time, -2 ps, 2 ps);
      end loop;

      log(ID_LOG_HDR, "Testing time (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(ONLY,(-2 us,1 ps,2 ns));
        check_rand_value(v_time, (-2 us,1 ps,2 ns));
      end loop;

      log(ID_LOG_HDR, "Testing time (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps));
        check_rand_value(v_time, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps));
        check_rand_value(v_time, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps), EXCL,(-1 ps,0 ps,1 ps));
        check_rand_value(v_time, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps), EXCL,(-1 ps,0 ps,1 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 us,16 ns,17 ps));
        check_rand_value(v_time, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 us,16 ns,17 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, INCL,(-15 us,-16 ns), INCL,(17 ps,18 ps));
        check_rand_value(v_time, -2 ps, 2 ps, INCL,(-15 us,-16 ns,17 ps,18 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-3 ps, 3 ps, EXCL,(-2 ps,-1 ps), EXCL,(1 ps,2 ps));
        check_rand_value(v_time, -3 ps, 3 ps, EXCL,(-2 ps,-1 ps,1 ps,2 ps));
      end loop;

      log(ID_LOG_HDR, "Testing time (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_time := v_rand.rand(10 ns, 0 ns);

      ------------------------------------------------------------
      -- Time Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing time_vector (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps);
        check_rand_value(v_time_vec, -2 ps, 2 ps);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps);
      end loop;

      log(ID_LOG_HDR, "Testing time_vector (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 us,-1 us,0 ns,1 ps,2 ps));
        check_rand_value(v_time_vec, (-2 us,-1 us,0 ns,1 ps,2 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 us,-1 us,0 ns,1 ps,2 ps), UNIQUE);
        check_rand_value(v_time_vec, (-2 us,-1 us,0 ns,1 ps,2 ps));
      end loop;

      log(ID_LOG_HDR, "Testing time_vector (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps));
        check_rand_value(v_time_vec, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps), UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -4 ps, 4 ps, EXCL,(-1 ps,0 ps,1 ps), UNIQUE);
        check_rand_value(v_time_vec, -4 ps, 4 ps, EXCL,(-1 ps,0 ps,1 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps), EXCL,(-1 ps,0 ps,1 ps));
        check_rand_value(v_time_vec, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps), EXCL,(-1 ps,0 ps,1 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps), EXCL,(-1 ps,0 ps,1 ps), UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps, INCL,(-15 us,16 ns,17 ps), EXCL,(-1 ps,0 ps,1 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 us,16 ns,17 ps), UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 us,16 ns,17 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-15 us,-16 ns), INCL,(17 ps,18 ps), UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps, INCL,(-15 us,-16 ns,17 ps,18 ps));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -4 ps, 4 ps, EXCL,(-2 ps,-1 ps), EXCL,(1 ps,2 ps), UNIQUE);
        check_rand_value(v_time_vec, -4 ps, 4 ps);
      end loop;

      ------------------------------------------------------------
      -- Unsigned
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unsigned (length)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length);
        log("v_uns:" & to_string(v_uns, HEX, KEEP_LEADING_0, INCL_RADIX));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length);
        log("v_uns_long:" & to_string(v_uns_long, HEX, KEEP_LEADING_0, INCL_RADIX));
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 3);
        check_rand_value(v_uns, 0, 3);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 3);
        check_rand_value(v_uns_long, 0, 3);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, integer'right);
        check_rand_value(v_uns_long, 0, integer'right);
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, ONLY,(0,1,2));
        check_rand_value(v_uns, (0,1,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, EXCL,(0,1,2));
        check_rand_value(v_uns, 0, 2**v_uns'length-1, EXCL,(0,1,2));
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(15,16,17));
        check_rand_value(v_uns, 0, 2, INCL,(15,16,17));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_uns, 0, 3, EXCL,(1,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(15,16,17), EXCL,(1,2));
        check_rand_value(v_uns, 0, 2, INCL,(15,16,17), EXCL,(1,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, EXCL,(1,2), INCL,(15,16,17));
        check_rand_value(v_uns, 0, 2, EXCL,(1,2), INCL,(15,16,17));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(15,16), INCL,(17,18));
        check_rand_value(v_uns, 0, 2, INCL,(15,16,17,18));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 5, EXCL,(0,1), EXCL,(2,3));
        check_rand_value(v_uns, 0, 5, EXCL,(0,1,2,3));
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_uns := v_rand.rand(v_uns'length, 10, 0);
      increment_expected_alerts(TB_WARNING, 3);
      v_uns := v_rand.rand(v_uns'length, 0, 2**16);
      v_uns := v_rand.rand(v_uns'length, ONLY,(2**17, 2**18));

      ------------------------------------------------------------
      -- Signed
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing signed (length)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length);
        log("v_sig:" & to_string(v_sig, DEC));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length);
        log("v_sig_long:" & to_string(v_sig_long, DEC));
      end loop;

      log(ID_LOG_HDR, "Testing signed (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2);
        check_rand_value(v_sig, -2, 2);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -2, 2);
        check_rand_value(v_sig_long, -2, 2);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, integer'left, integer'right);
        check_rand_value(v_sig_long, integer'left, integer'right);
      end loop;

      log(ID_LOG_HDR, "Testing signed (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, ONLY,(-2,0,2));
        check_rand_value(v_sig, (-2,0,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, EXCL,(-1,0,1));
        check_rand_value(v_sig, -2**(v_sig'length-1), 2**(v_sig'length-1)-1, EXCL,(-1,0,1));
      end loop;

      log(ID_LOG_HDR, "Testing signed (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, INCL,(-10,15,16));
        check_rand_value(v_sig, -2, 2, INCL,(-10,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1));
        check_rand_value(v_sig, -2, 2, EXCL,(-1,0,1));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
        check_rand_value(v_sig, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
        check_rand_value(v_sig, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, INCL,(-10,-11), INCL,(15,16));
        check_rand_value(v_sig, -2, 2, INCL,(-10,-11,15,16));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -3, 3, EXCL,(-2,-1), EXCL,(1,2));
        check_rand_value(v_sig, -3, 3, EXCL,(-2,-1,1,2));
      end loop;

      log(ID_LOG_HDR, "Testing signed (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_sig := v_rand.rand(v_sig'length, 10, 0);
      increment_expected_alerts(TB_WARNING, 3);
      v_sig := v_rand.rand(v_sig'length, 0, 2**16);
      v_sig := v_rand.rand(v_sig'length, ONLY,(2**17, 2**18));

      ------------------------------------------------------------
      -- Std_logic_vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic_vector (length)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length);
        log("v_slv:" & to_string(v_slv, HEX, KEEP_LEADING_0, INCL_RADIX));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length);
        log("v_slv_long:" & to_string(v_slv_long, HEX, KEEP_LEADING_0, INCL_RADIX));
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (min/max)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 3);
        check_rand_value(v_slv, 0, 3);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 3);
        check_rand_value(v_slv_long, 0, 3);
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, integer'right);
        check_rand_value(v_slv_long, 0, integer'right);
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, ONLY,(0,1,2));
        check_rand_value(v_slv, (0,1,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, EXCL,(0,1,2));
        check_rand_value(v_slv, 0, 2**v_slv'length-1, EXCL,(0,1,2));
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (min/max + set of values)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(15,16,17));
        check_rand_value(v_slv, 0, 2, INCL,(15,16,17));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_slv, 0, 3, EXCL,(1,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(15,16,17), EXCL,(1,2));
        check_rand_value(v_slv, 0, 2, INCL,(15,16,17), EXCL,(1,2));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, EXCL,(1,2), INCL,(15,16,17));
        check_rand_value(v_slv, 0, 2, EXCL,(1,2), INCL,(15,16,17));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(15,16), INCL,(17,18));
        check_rand_value(v_slv, 0, 2, INCL,(15,16,17,18));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 5, EXCL,(0,1), EXCL,(2,3));
        check_rand_value(v_slv, 0, 5, EXCL,(0,1,2,3));
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_slv := v_rand.rand(v_slv'length, 10, 0);
      increment_expected_alerts(TB_WARNING, 3);
      v_slv := v_rand.rand(v_slv'length, 0, 2**16);
      v_slv := v_rand.rand(v_slv'length, ONLY,(2**17, 2**18));

      ------------------------------------------------------------
      -- Std_logic & boolean
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic & boolean");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_std := v_rand.rand(VOID);
        log("v_std:" & to_string(v_std));
      end loop;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_bln := v_rand.rand(VOID);
        log("v_bln:" & to_string(v_bln));
      end loop;

    --===================================================================================
    elsif GC_TEST = "weighted_rand" then
    --===================================================================================
      ------------------------------------------------------------
      -- Weighted integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted integer - Generate " & to_string(C_NUM_DIST_REPETITIONS) & " random values for each test");
      log(ID_SEQUENCER, "Reducing log messages from rand_pkg");
      disable_log_msg(ID_LOG_MSG_CTRL);

      -----------------
      -- Single values
      -----------------
      for i in 1 to C_NUM_DIST_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,1),(10,3)));
        v_weight_cnt(v_int) := v_weight_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      print_and_check_weights(v_weight_cnt, (1,3));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_DIST_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,1),(5,0)));
        v_weight_cnt(v_int) := v_weight_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      v_int_vec(0) := 1;
      print_and_check_weights(v_weight_cnt, v_int_vec(0 to 0));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_DIST_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,10),(0,30),(10,60)));
        v_weight_cnt(v_int) := v_weight_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      print_and_check_weights(v_weight_cnt, (10,30,60));
      enable_log_msg(ID_RAND_GEN);

      ----------------------------
      -- Ranges with default mode
      ----------------------------
      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(COMBINED_WEIGHT)));
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      for i in 1 to C_NUM_DIST_REPETITIONS loop
        v_int := v_rand.rand_range_weight(((-5,-3,30),(0,0,20),(9,10,50)));
        v_weight_cnt(v_int) := v_weight_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      print_and_check_weights(v_weight_cnt, (10,10,10,20,25,25));
      enable_log_msg(ID_RAND_GEN);

      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(INDIVIDUAL_WEIGHT)));
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      for i in 1 to C_NUM_DIST_REPETITIONS loop
        v_int := v_rand.rand_range_weight(((-5,-3,30),(0,0,20),(9,10,50)));
        v_weight_cnt(v_int) := v_weight_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      print_and_check_weights(v_weight_cnt, (30,30,30,20,50,50));
      enable_log_msg(ID_RAND_GEN);

      -----------------------------
      -- Ranges with explicit mode
      -----------------------------
      for i in 1 to C_NUM_DIST_REPETITIONS loop
        v_int := v_rand.rand_range_weight_mode(((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(9,10,50,COMBINED_WEIGHT)));
        v_weight_cnt(v_int) := v_weight_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      print_and_check_weights(v_weight_cnt, (30,30,30,20,25,25));
      enable_log_msg(ID_RAND_GEN);

      log(ID_LOG_HDR, "Testing weighted integer (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 3);
      v_rand.set_range_weight_default_mode(NA);
      v_int := v_rand.rand_val_weight(((1,0),(2,0),(3,0)));
      v_int := v_rand.rand_range_weight(((10,5,50),(1,1,50)));

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