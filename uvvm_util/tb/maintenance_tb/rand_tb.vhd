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

  constant C_NUM_RAND_REPETITIONS   : natural := 6;
  constant C_NUM_WEIGHT_REPETITIONS : natural := 1000; -- Changing this value affects check_weight_distribution() C_MARGIN.
  constant C_NUM_CYCLIC_REPETITIONS : natural := 3;

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_rand       : t_rand;
    variable v_seeds      : t_positive_vector(0 to 1);
    variable v_int        : integer;
    variable v_real       : real;
    variable v_time       : time;
    variable v_int_vec    : integer_vector(0 to 4);
    variable v_real_vec   : real_vector(0 to 4);
    variable v_time_vec   : time_vector(0 to 4);
    variable v_uns        : unsigned(3 downto 0);
    variable v_uns_long   : unsigned(39 downto 0);
    variable v_sig        : signed(3 downto 0);
    variable v_sig_long   : signed(39 downto 0);
    variable v_slv        : std_logic_vector(3 downto 0);
    variable v_slv_long   : std_logic_vector(39 downto 0);
    variable v_std        : std_logic;
    variable v_bln        : boolean;
    variable v_value_cnt  : t_integer_cnt(-20 to 20) := (others => 0);
    variable v_num_values : natural;
    variable v_bit_check  : std_logic_vector(1 downto 0);

  begin

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Randomization package - " & GC_TEST);
    --------------------------------------------------------------------------------
    enable_log_msg(ID_RAND_GEN);

    --===================================================================================
    if GC_TEST = "basic_rand" then
    --===================================================================================
      increment_expected_alerts(TB_WARNING, 1); -- Single warning for using same set_type in rand()

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

      ------------------------------------------------------------
      -- Integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer (min/max)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2);
        check_rand_value(v_int, -2, 2);
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(ONLY,(-2,0,2));
        check_rand_value(v_int, (-2,0,2));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-1, 1, INCL,(-10));
        check_rand_value(v_int, -1, 1, INCL,(-10,-10)); -- use vector to save overload
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1));
        check_rand_value(v_int, -2, 2, EXCL,(-1,0,1));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, INCL,(-10), EXCL,(1));
        check_rand_value(v_int, -2, 2, INCL,(-10,-10), EXCL,(1,1)); -- use vector to save overload
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
        check_rand_value(v_int, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-1, 1, INCL,(-10), INCL,(15,16));
        check_rand_value(v_int, -1, 1, INCL, (-10,15,16));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-3, 3, EXCL,(-2,-1), EXCL,(1,2));
        check_rand_value(v_int, -3, 3, EXCL, (-2,-1,1,2));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_int := v_rand.rand(10, 0);

      ------------------------------------------------------------
      -- Integer Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer_vector (min/max)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2);
        check_rand_value(v_int_vec, -2, 2);
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, UNIQUE);
        check_rand_value(v_int_vec, -2, 2);
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (set of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2));
        check_rand_value(v_int_vec, (-2,-1,0,1,2));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), UNIQUE);
        check_rand_value(v_int_vec, (-2,-1,0,1,2));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, INCL,(-10));
        check_rand_value(v_int_vec, -1, 1, INCL,(-10,-10)); -- use vector to save overload
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, INCL,(-10,15), UNIQUE);
        check_rand_value(v_int_vec, -1, 1, INCL,(-10,15));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), UNIQUE);
        check_rand_value(v_int_vec, -3, 4, EXCL,(-1,0,1));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-10), EXCL,(1));
        check_rand_value(v_int_vec, -2, 2, INCL,(-10,-10), EXCL,(1,1)); -- use vector to save overload
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1), UNIQUE);
        check_rand_value(v_int_vec, -2, 2, INCL,(-10,15,16), EXCL,(-1,0,1));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16), UNIQUE);
        check_rand_value(v_int_vec, -2, 2, EXCL,(-1,0,1), INCL,(-10,15,16));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, INCL,(-10), INCL,(15,16), UNIQUE);
        check_rand_value(v_int_vec, -1, 1, INCL,(-10,15,16));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -4, 4, EXCL,(-2,-1), EXCL,(1,2), UNIQUE);
        check_rand_value(v_int_vec, -4, 4, EXCL,(-2,-1,1,2));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      ------------------------------------------------------------
      -- Real
      -- It is impossible to verify every value within a real range
      -- is generated, so instead only the rounded values are verified.
      -- There is twice as many repetitions since the values are discrete.
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing real (min/max)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0);
        check_rand_value(v_real, -1.0, 1.0);
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(ONLY,(-2.0,0.555,2.0));
        check_rand_value(v_real, (-2.0,0.555,2.0));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, INCL,(15.5));
        check_rand_value(v_real, -1.0, 1.0, INCL,(15.5,15.5)); -- use vector to save overload
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, EXCL,(-1.0,0.0,1.0));
        check_rand_value(v_real, -1.0, 1.0, EXCL,(-1.0,0.0,1.0));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (min/max + 2 sets of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, INCL,(15.5), EXCL,(-1.0));
        check_rand_value(v_real, -1.0, 1.0, INCL,(15.5,15.5), EXCL,(-1.0,-1.0)); -- use vector to save overload
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6));
        check_rand_value(v_real, -1.0, 1.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, INCL,(15.5), INCL,(16.6,17.7));
        check_rand_value(v_real, -1.0, 1.0, INCL,(15.5,16.6,17.7));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, EXCL,(-2.0,-1.0), EXCL,(1.0,2.0));
        check_rand_value(v_real, -1.0, 1.0, EXCL,(-2.0,-1.0,1.0,2.0));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_real := v_rand.rand(10.0, 0.0);

      ------------------------------------------------------------
      -- Real Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing real_vector (min/max)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0);
        check_rand_value(v_real_vec, -2.0, 2.0);
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, UNIQUE);
        check_rand_value(v_real_vec, -2.0, 2.0);
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real_vector (set of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.25,1.1,2.0));
        check_rand_value(v_real_vec, (-2.0,-1.1,0.25,1.1,2.0));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.25,1.1,2.0), UNIQUE);
        check_rand_value(v_real_vec, (-2.0,-1.1,0.25,1.1,2.0));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real_vector (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, INCL,(15.5));
        check_rand_value(v_real_vec, -1.0, 1.0, INCL,(15.5,15.5)); -- use vector to save overload
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, INCL,(15.5,16.6), UNIQUE);
        check_rand_value(v_real_vec, -1.0, 1.0, INCL,(15.5,16.6));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0,0.0,1.0), UNIQUE);
        check_rand_value(v_real_vec, -1.0, 1.0, EXCL,(-1.0,0.0,1.0));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real_vector (min/max + 2 sets of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, INCL,(15.5), EXCL,(-1.0));
        check_rand_value(v_real_vec, -1.0, 1.0, INCL,(15.5,15.5), EXCL,(-1.0,-1.0)); -- use vector to save overload
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, INCL,(15.5,16.6), EXCL,(-1.0,0.0,1.0), UNIQUE);
        check_rand_value(v_real_vec, -1.0, 1.0, INCL,(15.5,16.6), EXCL,(-1.0,0.0,1.0));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6), UNIQUE);
        check_rand_value(v_real_vec, -1.0, 1.0, EXCL,(-1.0,0.0,1.0), INCL,(15.5,16.6));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, INCL,(15.5), INCL,(16.6,17.7), UNIQUE);
        check_rand_value(v_real_vec, -1.0, 1.0, INCL,(15.5,16.6,17.7));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0,-0.5), EXCL,(0.5,1.0), UNIQUE);
        check_rand_value(v_real_vec, -1.0, 1.0, EXCL,(-1.0,-0.5,0.5,1.0));
        for j in v_real_vec'range loop
          v_value_cnt(integer(v_real_vec(j))) := v_value_cnt(integer(v_real_vec(j))) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      ------------------------------------------------------------
      -- Time
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing time (min/max)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps);
        check_rand_value(v_time, -2 ps, 2 ps);
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(ONLY,(-2 ps,1 ps,2 ps));
        check_rand_value(v_time, (-2 ps,1 ps,2 ps));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(ONLY,(-2 us,1 ns,2 ps));
        check_rand_value(v_time, (-2 us,1 ns,2 ps));
      end loop;

      log(ID_LOG_HDR, "Testing time (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-1 ps, 1 ps, INCL,(-15 ps));
        check_rand_value(v_time, -1 ps, 1 ps, INCL,(-15 ps,-15 ps)); -- use vector to save overload
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps));
        check_rand_value(v_time, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, INCL,(-15 ps), EXCL,(1 ps));
        check_rand_value(v_time, -2 ps, 2 ps, INCL,(-15 ps,-15 ps), EXCL,(1 ps,1 ps)); -- use vector to save overload
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 ps,16 ps,17 ps));
        check_rand_value(v_time, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 ps,16 ps,17 ps));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-1 ps, 1 ps, INCL,(-15 ps), INCL,(17 ps,18 ps));
        check_rand_value(v_time, -1 ps, 1 ps, INCL,(-15 ps,17 ps,18 ps));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-3 ps, 3 ps, EXCL,(-2 ps,-1 ps), EXCL,(1 ps,2 ps));
        check_rand_value(v_time, -3 ps, 3 ps, EXCL,(-2 ps,-1 ps,1 ps,2 ps));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_time := v_rand.rand(10 ns, 0 ns);

      ------------------------------------------------------------
      -- Time Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing time_vector (min/max)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps);
        check_rand_value(v_time_vec, -2 ps, 2 ps);
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps);
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time_vector (set of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps));
        check_rand_value(v_time_vec, (-2 ps,-1 ps,0 ps,1 ps,2 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps), UNIQUE);
        check_rand_value(v_time_vec, (-2 ps,-1 ps,0 ps,1 ps,2 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 us,-1 us,0 ns,1 ps,2 ps));
        check_rand_value(v_time_vec, (-2 us,-1 us,0 ns,1 ps,2 ps));
      end loop;

      log(ID_LOG_HDR, "Testing time_vector (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -1 ps, 1 ps, INCL,(-15 ps));
        check_rand_value(v_time_vec, -1 ps, 1 ps, INCL,(-15 ps,-15 ps)); -- use vector to save overload
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -1 ps, 1 ps, INCL,(-15 ps,16 ps), UNIQUE);
        check_rand_value(v_time_vec, -1 ps, 1 ps, INCL,(-15 ps,16 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -4 ps, 4 ps, EXCL,(-1 ps,0 ps,1 ps), UNIQUE);
        check_rand_value(v_time_vec, -4 ps, 4 ps, EXCL,(-1 ps,0 ps,1 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time_vector (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-15 ps), EXCL,(1 ps));
        check_rand_value(v_time_vec, -2 ps, 2 ps, INCL,(-15 ps,-15 ps), EXCL,(1 ps,1 ps)); -- use vector to save overload
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, INCL,(-15 ps,16 ps,17 ps), EXCL,(-1 ps,0 ps,1 ps), UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps, INCL,(-15 ps,16 ps,17 ps), EXCL,(-1 ps,0 ps,1 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 ps,16 ps,17 ps), UNIQUE);
        check_rand_value(v_time_vec, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps), INCL,(-15 ps,16 ps,17 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -1 ps, 1 ps, INCL,(-15 ps), INCL,(17 ps,18 ps), UNIQUE);
        check_rand_value(v_time_vec, -1 ps, 1 ps, INCL,(-15 ps,17 ps,18 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -4 ps, 4 ps, EXCL,(-2 ps,-1 ps), EXCL,(1 ps,2 ps), UNIQUE);
        check_rand_value(v_time_vec, -4 ps, 4 ps, EXCL,(-2 ps,-1 ps,1 ps,2 ps));
        for j in v_real_vec'range loop
          v_value_cnt(v_time_vec(j)/1 ps) := v_value_cnt(v_time_vec(j)/1 ps) + 1;
        end loop;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      ------------------------------------------------------------
      -- Unsigned
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unsigned (length)");
      v_num_values := 3; -- only need to check that it doesn't generate the same value
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length);
        log("v_uns:" & to_string(v_uns, HEX, KEEP_LEADING_0, INCL_RADIX));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values, match_num_values => false);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length);
        log("v_uns_long:" & to_string(v_uns_long, HEX, KEEP_LEADING_0, INCL_RADIX));
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (min/max)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 3);
        check_rand_value(v_uns, 0, 3);
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 3);
        check_rand_value(v_uns_long, 0, 3);
      end loop;

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, integer'right);
        check_rand_value(v_uns_long, 0, integer'right);
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, ONLY,(0,1,2));
        check_rand_value(v_uns, (0,1,2));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, EXCL,(0,1,2,3,4,5,6,7,8,9));
        check_rand_value(v_uns, 0, (2**v_uns'length)-1, EXCL,(0,1,2,3,4,5,6,7,8,9));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(7));
        check_rand_value(v_uns, 0, 2, INCL,(7,7)); -- use vector to save overload
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_uns, 0, 3, EXCL,(1,2));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (min/max + 2 sets of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(7), EXCL,(1));
        check_rand_value(v_uns, 0, 2, INCL,(7,7), EXCL,(1,1)); -- use vector to save overload
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, EXCL,(1,2), INCL,(7,8,9));
        check_rand_value(v_uns, 0, 2, EXCL,(1,2), INCL,(7,8,9));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, INCL,(7), INCL,(8,9));
        check_rand_value(v_uns, 0, 2, INCL,(7,8,9));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 5, EXCL,(0,1), EXCL,(2,3));
        check_rand_value(v_uns, 0, 5, EXCL,(0,1,2,3));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_uns := v_rand.rand(v_uns'length, 5, 0);
      increment_expected_alerts(TB_WARNING, 3);
      v_uns := v_rand.rand(v_uns'length, 0, 2**16);
      v_uns := v_rand.rand(v_uns'length, ONLY,(2**17, 2**18));

      ------------------------------------------------------------
      -- Signed
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing signed (length)");
      v_num_values := 3; -- only need to check that it doesn't generate the same value
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length);
        log("v_sig:" & to_string(v_sig, DEC));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values, match_num_values => false);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length);
        log("v_sig_long:" & to_string(v_sig_long, DEC));
      end loop;

      log(ID_LOG_HDR, "Testing signed (min/max)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2);
        check_rand_value(v_sig, -2, 2);
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -2, 2);
        check_rand_value(v_sig_long, -2, 2);
      end loop;

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, integer'left, integer'right);
        check_rand_value(v_sig_long, integer'left, integer'right);
      end loop;

      log(ID_LOG_HDR, "Testing signed (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, ONLY,(-2,0,2));
        check_rand_value(v_sig, (-2,0,2));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, EXCL,(-5,-4,-3,-2,-1,0,1,2,3,4));
        check_rand_value(v_sig, -2**(v_sig'length-1), 2**(v_sig'length-1)-1, EXCL,(-5,-4,-3,-2,-1,0,1,2,3,4));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -1, 1, INCL,(-8));
        check_rand_value(v_sig, -1, 1, INCL,(-8,-8)); -- use vector to save overload
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1));
        check_rand_value(v_sig, -2, 2, EXCL,(-1,0,1));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, INCL,(-8), EXCL,(1));
        check_rand_value(v_sig, -2, 2, INCL,(-8,-8), EXCL,(1,1)); -- use vector to save overload
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1), INCL,(-8,7));
        check_rand_value(v_sig, -2, 2, EXCL,(-1,0,1), INCL,(-8,7));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -1, 1, INCL,(-8), INCL,(6,7));
        check_rand_value(v_sig, -1, 1, INCL,(-8,6,7));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -3, 3, EXCL,(-2,-1), EXCL,(1,2));
        check_rand_value(v_sig, -3, 3, EXCL,(-2,-1,1,2));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_sig := v_rand.rand(v_sig'length, 5, 0);
      increment_expected_alerts(TB_WARNING, 3);
      v_sig := v_rand.rand(v_sig'length, 0, 2**16);
      v_sig := v_rand.rand(v_sig'length, ONLY,(2**17, 2**18));

      ------------------------------------------------------------
      -- Std_logic_vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic_vector (length)");
      v_num_values := 3; -- only need to check that it doesn't generate the same value
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length);
        log("v_slv:" & to_string(v_slv, HEX, KEEP_LEADING_0, INCL_RADIX));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values, match_num_values => false);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length);
        log("v_slv_long:" & to_string(v_slv_long, HEX, KEEP_LEADING_0, INCL_RADIX));
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (min/max)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 3);
        check_rand_value(v_slv, 0, 3);
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 3);
        check_rand_value(v_slv_long, 0, 3);
      end loop;

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, integer'right);
        check_rand_value(v_slv_long, 0, integer'right);
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, ONLY,(0,1,2));
        check_rand_value(v_slv, (0,1,2));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, EXCL,(0,1,2,3,4,5,6,7,8,9));
        check_rand_value(v_slv, 0, 2**v_slv'length-1, EXCL,(0,1,2,3,4,5,6,7,8,9));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(7));
        check_rand_value(v_slv, 0, 2, INCL,(7,7)); -- use vector to save overload
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_slv, 0, 3, EXCL,(1,2));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (min/max + 2 sets of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(7), EXCL,(1));
        check_rand_value(v_slv, 0, 2, INCL,(7,7), EXCL,(1,1)); -- use vector to save overload
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, EXCL,(1,2), INCL,(7,8,9));
        check_rand_value(v_slv, 0, 2, EXCL,(1,2), INCL,(7,8,9));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, INCL,(7), INCL,(9,10));
        check_rand_value(v_slv, 0, 2, INCL,(7,9,10));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 5, EXCL,(0,1), EXCL,(2,3));
        check_rand_value(v_slv, 0, 5, EXCL,(0,1,2,3));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_slv := v_rand.rand(v_slv'length, 5, 0);
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
        v_bit_check := (v_bit_check or "10") when v_std else (v_bit_check or "01");
      end loop;
      check_value(v_bit_check, "11", ERROR, "Check '0' and '1' are generated");
      v_bit_check := "00";

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_bln := v_rand.rand(VOID);
        log("v_bln:" & to_string(v_bln));
        v_bit_check := (v_bit_check or "10") when v_bln else (v_bit_check or "01");
      end loop;
      check_value(v_bit_check, "11", ERROR, "Check true and false are generated");
      v_bit_check := "00";

    --===================================================================================
    elsif GC_TEST = "weighted_rand" then
    --===================================================================================
      log(ID_SEQUENCER, "Reducing log messages from rand_pkg");
      disable_log_msg(ID_LOG_MSG_CTRL);

      ------------------------------------------------------------
      -- Weighted integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted integer (single values) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,1),(10,3)));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,1),(10,0)));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,10),(0,30),(10,60)));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted integer (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(COMBINED_WEIGHT)));
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_range_weight(((-5,-3,30),(0,0,20),(9,10,50)));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(-4,10),(-3,10),(0,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(INDIVIDUAL_WEIGHT)));
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_range_weight(((-5,-3,30),(0,0,20),(9,10,50)));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,30),(-4,30),(-3,30),(0,20),(9,50),(10,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted integer (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_range_weight_mode(((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(9,10,50,COMBINED_WEIGHT)));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,30),(-4,30),(-3,30),(0,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      ------------------------------------------------------------
      -- Weighted real
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted real (single values) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_val_weight(((-5.0,1),(10.1,3)));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_val_weight(((-5.0,1),(10.1,0)));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_val_weight(((-5.0,10),(0.0,30),(10.1,60)));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted real (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(COMBINED_WEIGHT)));
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_range_weight(((-5.0,-3.0,30),(0.0,0.0,20),(9.3,10.1,50)));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,-3,30),(0,0,20),(9,10,50)));
      enable_log_msg(ID_RAND_GEN);

      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(INDIVIDUAL_WEIGHT)));
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_real := v_rand.rand_range_weight(((-5.0,-3.0,30),(0.0,0.0,20),(9.3,10.1,50)));


      log(ID_LOG_HDR, "Testing weighted real (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_range_weight_mode(((-5.0,-3.0,30,COMBINED_WEIGHT),(0.0,0.0,20,NA),(9.3,10.1,50,COMBINED_WEIGHT)));
        v_value_cnt(integer(v_real)) := v_value_cnt(integer(v_real)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,-3,30),(0,0,20),(9,10,50)));
      enable_log_msg(ID_RAND_GEN);

      ------------------------------------------------------------
      -- Weighted time
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted time (single values) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_val_weight(((-5 ps,1),(10 ps,3)));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_val_weight(((-5 ps,1),(10 ps,0)));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_val_weight(((-5 ps,10),(0 ps,30),(10 ps,60)));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted time (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(COMBINED_WEIGHT)));
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_range_weight(((-5 ps,-3 ps,30),(0 ps,0 ps,20),(9 ps,10 ps,50)));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,-3,30),(0,0,20),(9,10,50)));
      enable_log_msg(ID_RAND_GEN);

      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(INDIVIDUAL_WEIGHT)));
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_time := v_rand.rand_range_weight(((-5 ps,-3 ps,30),(0 ps,0 ps,20),(9 ps,10 ps,50)));


      log(ID_LOG_HDR, "Testing weighted time (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_range_weight_mode(((-5 ps,-3 ps,30,COMBINED_WEIGHT),(0 ps,0 ps,20,NA),(9 ps,10 ps,50,COMBINED_WEIGHT)));
        v_value_cnt(v_time/1 ps) := v_value_cnt(v_time/1 ps) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,-3,30),(0,0,20),(9,10,50)));
      enable_log_msg(ID_RAND_GEN);

      ------------------------------------------------------------
      -- Weighted unsigned
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted unsigned (single values) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_val_weight(v_uns'length,((5,1),(10,3)));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_val_weight(v_uns'length,((5,1),(10,0)));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_val_weight(v_uns'length,((0,10),(5,30),(10,60)));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(5,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted unsigned (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(COMBINED_WEIGHT)));
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_range_weight(v_uns'length,((0,2,30),(5,5,20),(9,10,50)));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(1,10),(2,10),(5,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(INDIVIDUAL_WEIGHT)));
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_range_weight(v_uns'length,((0,2,30),(5,5,20),(9,10,50)));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,30),(1,30),(2,30),(5,20),(9,50),(10,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted unsigned (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_range_weight_mode(v_uns'length,((0,2,30,INDIVIDUAL_WEIGHT),(5,5,20,NA),(9,10,50,COMBINED_WEIGHT)));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,30),(1,30),(2,30),(5,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      ------------------------------------------------------------
      -- Weighted signed
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted signed (single values) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_val_weight(v_sig'length,((-5,1),(7,3)));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(7,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_val_weight(v_sig'length,((-5,1),(7,0)));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(7,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_val_weight(v_sig'length,((-5,10),(0,30),(7,60)));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(7,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted signed (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(COMBINED_WEIGHT)));
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_range_weight(v_sig'length,((-5,-3,30),(0,0,20),(6,7,50)));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(-4,10),(-3,10),(0,20),(6,25),(7,25)));
      enable_log_msg(ID_RAND_GEN);

      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(INDIVIDUAL_WEIGHT)));
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_range_weight(v_sig'length,((-5,-3,30),(0,0,20),(6,7,50)));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,30),(-4,30),(-3,30),(0,20),(6,50),(7,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted signed (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_range_weight_mode(v_sig'length,((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(6,7,50,COMBINED_WEIGHT)));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,30),(-4,30),(-3,30),(0,20),(6,25),(7,25)));
      enable_log_msg(ID_RAND_GEN);

      ------------------------------------------------------------
      -- Weighted std_logic_vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted std_logic_vector (single values) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_val_weight(v_slv'length,((5,1),(10,3)));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_val_weight(v_slv'length,((5,1),(10,0)));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_val_weight(v_slv'length,((0,10),(5,30),(10,60)));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(5,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted std_logic_vector (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(COMBINED_WEIGHT)));
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_range_weight(v_slv'length,((0,2,30),(5,5,20),(9,10,50)));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(1,10),(2,10),(5,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      log(ID_SEQUENCER, "Set range weight default mode to " & to_upper(to_string(INDIVIDUAL_WEIGHT)));
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_range_weight(v_slv'length,((0,2,30),(5,5,20),(9,10,50)));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,30),(1,30),(2,30),(5,20),(9,50),(10,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted std_logic_vector (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_range_weight_mode(v_slv'length,((0,2,30,INDIVIDUAL_WEIGHT),(5,5,20,NA),(9,10,50,COMBINED_WEIGHT)));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,30),(1,30),(2,30),(5,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing invalid parameters");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 3);
      v_rand.set_range_weight_default_mode(NA);
      v_int := v_rand.rand_val_weight(((1,0),(2,0),(3,0)));
      v_int := v_rand.rand_range_weight(((10,5,50),(1,1,50)));

    --===================================================================================
    elsif GC_TEST = "cyclic_rand" then
    --===================================================================================
      ------------------------------------------------------------
      -- Random cyclic integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer (min/max)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, CYCLIC);
        check_rand_value(v_int, -2, 2);
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing integer (set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(ONLY,(-2,0,1,3), CYCLIC);
        check_rand_value(v_int, (-2,0,1,3));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing integer (min/max + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-1, 1, INCL,(3), CYCLIC);
        check_rand_value(v_int, -1, 1, INCL,(3,3)); -- use vector to save overload
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-3, 3, EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_int, -3, 3, EXCL,(-1,0,1));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing integer (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, INCL,(-5), EXCL,(1), CYCLIC);
        check_rand_value(v_int, -2, 2, INCL,(-5,-5), EXCL,(1,1)); -- use vector to save overload
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, INCL,(-5,5,6), EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_int, -2, 2, INCL,(-5,5,6), EXCL,(-1,0,1));
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(0), INCL,(6,7), CYCLIC);
        check_rand_value(v_int, -2, 2, EXCL,(0,0), INCL,(6,7)); -- use vector to save overload
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Random cyclic integer vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer_vector (min/max)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -2, 2);
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -2, 2);
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      log(ID_LOG_HDR, "Testing integer_vector (set of values)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, (-2,-1,0,1,2));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, (-2,-1,0,1,2));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      log(ID_LOG_HDR, "Testing integer_vector (min/max + set of values)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 2, INCL,(-5), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -1, 2, INCL,(-5,-5)); -- use vector to save overload
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, INCL,(-5,6), UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -1, 1, INCL,(-5,6));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -3, 4, EXCL,(-1,0,1));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -3, 4, EXCL,(-1,0,1));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      log(ID_LOG_HDR, "Testing integer_vector (min/max + 2 sets of values)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-5), EXCL,(1), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -2, 2, INCL,(-5,-5), EXCL,(1,1)); -- use vector to save overload
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, INCL,(-5,6,8), EXCL,(-1,0,1), UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -2, 2, INCL,(-5,6,8), EXCL,(-1,0,1));
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, EXCL,(-1), INCL,(-5,6,8), UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, -1, 1, EXCL,(-1,-1), INCL,(-5,6,8)); -- use vector to save overload
        for j in v_int_vec'range loop
          v_value_cnt(v_int_vec(j)) := v_value_cnt(v_int_vec(j)) + 1;
        end loop;
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      ------------------------------------------------------------
      -- Random cyclic unsigned
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unsigned (min/max)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, CYCLIC);
        check_rand_value(v_uns, 0, 4);
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, ONLY,(0,2,4), CYCLIC);
        check_rand_value(v_uns, (0,2,4));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_uns := v_rand.rand(v_uns'length, EXCL,(0,1,2), CYCLIC);
      check_rand_value(v_uns, 0, 2**v_uns'length-1, EXCL,(0,1,2));

      log(ID_LOG_HDR, "Testing unsigned (min/max + set of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, INCL,(5), CYCLIC);
        check_rand_value(v_uns, 0, 4, INCL,(5,5)); -- use vector to save overload
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_uns, 0, 4, EXCL,(0,1,2));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, INCL,(5), EXCL,(0), CYCLIC);
        check_rand_value(v_uns, 0, 4, INCL,(5,5), EXCL,(0,0)); -- use vector to save overload
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, INCL,(5,8,9), EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_uns, 0, 4, INCL,(5,8,9), EXCL,(0,1,2));
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, EXCL,(0), INCL,(5,8,9), CYCLIC);
        check_rand_value(v_uns, 0, 2, EXCL,(0,0), INCL,(5,8,9)); -- use vector to save overload
        v_value_cnt(to_integer(v_uns)) := v_value_cnt(to_integer(v_uns)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Random cyclic signed
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing signed (min/max)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, CYCLIC);
        check_rand_value(v_sig, -2, 2);
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing signed (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, ONLY,(-2,0,2), CYCLIC);
        check_rand_value(v_sig, (-2,0,2));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_sig := v_rand.rand(v_sig'length, EXCL,(-1,0,1), CYCLIC);
      check_rand_value(v_sig, -2**(v_sig'length-1), 2**(v_sig'length-1)-1, EXCL,(-1,0,1));

      log(ID_LOG_HDR, "Testing signed (min/max + set of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, INCL,(-8), CYCLIC);
        check_rand_value(v_sig, -2, 2, INCL,(-8,-8)); -- use vector to save overload
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_sig, -2, 2, EXCL,(-1,0,1));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing signed (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, INCL,(-8), EXCL,(1), CYCLIC);
        check_rand_value(v_sig, -2, 2, INCL,(-8,-8), EXCL,(1,1)); -- use vector to save overload
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, INCL,(-8,6,7), EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_sig, -2, 2, INCL,(-8,6,7), EXCL,(-1,0,1));
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -1, 1, EXCL,(0), INCL,(-8,6,7), CYCLIC);
        check_rand_value(v_sig, -1, 1, EXCL,(0,0), INCL,(-8,6,7)); -- use vector to save overload
        v_value_cnt(to_integer(v_sig)) := v_value_cnt(to_integer(v_sig)) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Random cyclic std_logic_vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic_vector (min/max)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, CYCLIC);
        check_rand_value(v_slv, 0, 4);
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, ONLY,(0,2,4), CYCLIC);
        check_rand_value(v_slv, (0,2,4));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_slv := v_rand.rand(v_slv'length, EXCL,(0,1,2), CYCLIC);
      check_rand_value(v_slv, 0, 2**v_slv'length-1, EXCL,(0,1,2));

      log(ID_LOG_HDR, "Testing std_logic_vector (min/max + set of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, INCL,(8), CYCLIC);
        check_rand_value(v_slv, 0, 4, INCL,(8,8)); -- use vector to save overload
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_slv, 0, 4, EXCL,(0,1,2));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (min/max + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, INCL,(5), EXCL,(0), CYCLIC);
        check_rand_value(v_slv, 0, 4, INCL,(5,5), EXCL,(0,0)); -- use vector to save overload
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, INCL,(5,8,9), EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_slv, 0, 4, INCL,(5,8,9), EXCL,(0,1,2));
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, EXCL,(0), INCL,(5,8,9), CYCLIC);
        check_rand_value(v_slv, 0, 2, EXCL,(0,0), INCL,(5,8,9)); -- use vector to save overload
        v_value_cnt(to_integer(unsigned(v_slv))) := v_value_cnt(to_integer(unsigned(v_slv))) + 1;
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Clear random cyclic
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing clear_rand_cyclic");
      log(ID_SEQUENCER, "Generate some values");
      v_num_values := 7;
      for i in 1 to v_num_values-2 loop
        v_int := v_rand.rand(-3, 3, CYCLIC);
        check_rand_value(v_int, -3, 3);
      end loop;

      log(ID_SEQUENCER, "Clear the random cyclic list");
      v_rand.clear_rand_cyclic(VOID);

      log(ID_SEQUENCER, "Generate whole range of values");
      for i in 1 to v_num_values loop
        v_int := v_rand.rand(-3, 3, CYCLIC);
        check_rand_value(v_int, -3, 3);
        v_value_cnt(v_int) := v_value_cnt(v_int) + 1;
      end loop;
      check_cyclic_distribution(v_value_cnt, v_num_values);


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