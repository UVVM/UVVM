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

--HDLUnit:TB
entity rand_tb is
  generic(
    GC_TESTCASE : string
  );
end entity;

architecture func of rand_tb is

  constant C_NUM_RAND_REPETITIONS   : natural := 7;
  constant C_NUM_WEIGHT_REPETITIONS : natural := 1000; -- Changing this value affects check_weight_distribution() C_MARGIN.
  constant C_NUM_CYCLIC_REPETITIONS : natural := 3;

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_rand          : t_rand;
    variable v_seeds         : t_positive_vector(0 to 1);
    variable v_int           : integer;
    variable v_prev_int      : integer := 0;
    variable v_real          : real;
    variable v_time          : time;
    variable v_int_vec       : integer_vector(0 to 4);
    variable v_int_vec_long  : integer_vector(0 to 127);
    variable v_real_vec      : real_vector(0 to 4);
    variable v_time_vec      : time_vector(0 to 4);
    variable v_uns           : unsigned(3 downto 0);
    variable v_uns_long      : unsigned(127 downto 0);
    variable v_uns_long_min  : unsigned(127 downto 0);
    variable v_uns_long_max  : unsigned(127 downto 0);
    variable v_prev_uns_long : unsigned(127 downto 0) := (others => '0');
    variable v_sig           : signed(3 downto 0);
    variable v_sig_long      : signed(127 downto 0);
    variable v_sig_long_min  : signed(127 downto 0);
    variable v_sig_long_max  : signed(127 downto 0);
    variable v_prev_sig_long : signed(127 downto 0) := (others => '0');
    variable v_slv           : std_logic_vector(3 downto 0);
    variable v_slv_long      : std_logic_vector(127 downto 0);
    variable v_slv_long_min  : std_logic_vector(127 downto 0);
    variable v_slv_long_max  : std_logic_vector(127 downto 0);
    variable v_prev_slv_long : std_logic_vector(127 downto 0) := (others => '0');
    variable v_std           : std_logic;
    variable v_bln           : boolean;
    variable v_value_cnt     : t_integer_cnt(-32 to 31) := (others => 0);
    variable v_num_values    : natural;
    variable v_bit_check     : std_logic_vector(1 downto 0);
    variable v_mean          : real;
    variable v_std_deviation : real;
    variable v_found         : boolean := false;
    variable v_incr_list     : integer_vector(1 to 256);

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Randomization package - " & GC_TESTCASE);
    -------------------------------------------------------------------------------------
    enable_log_msg(ID_RAND_GEN);
    enable_log_msg(ID_RAND_CONF);

    --===================================================================================
    if GC_TESTCASE = "rand_basic" then
    --===================================================================================
      increment_expected_alerts(TB_WARNING, 1); -- Single warning for using same specifier in rand()

      v_rand.set_name("long_string_abcdefghijklmnopqrstuvwxyz");
      check_value(v_rand.get_name(VOID), "long_string_abcdefgh", ERROR, "Checking name"); -- C_RAND_MAX_NAME_LENGTH = 20
      v_rand.set_scope("long_string_abcdefghijklmnopqrstuvwxyz");
      check_value(v_rand.get_scope(VOID), "long_string_abcdefghijklmnopqr", ERROR, "Checking scope"); -- C_LOG_SCOPE_WIDTH = 30

      v_rand.set_name("MY_RAND_GEN");
      check_value(v_rand.get_name(VOID), "MY_RAND_GEN", ERROR, "Checking name");
      v_rand.set_scope("MY SCOPE");
      check_value(v_rand.get_scope(VOID), "MY SCOPE", ERROR, "Checking scope");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing seeds");
      ------------------------------------------------------------
      log(ID_SEQUENCER, "Check default seed values");
      v_seeds := v_rand.get_rand_seeds(VOID);
      check_value(v_seeds(0), C_RAND_INIT_SEED_1, ERROR, "Checking initial seed 1");
      check_value(v_seeds(1), C_RAND_INIT_SEED_2, ERROR, "Checking initial seed 2");

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
      v_rand.set_rand_seeds(v_rand'instance_name);
      v_seeds := v_rand.get_rand_seeds(VOID);
      check_value(v_seeds(0) /= 800, ERROR, "Checking seed 1");
      check_value(v_seeds(1) /= 8000, ERROR, "Checking seed 2");

      ------------------------------------------------------------
      -- Integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2);
        check_rand_value(v_int, (0 => (-2,2)));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(ONLY,(-2,0,2));
        check_rand_value(v_int, ONLY,(-2,0,2));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-1, 1, ADD,(-10));
        check_rand_value(v_int, (0 => (-1,1)), ADD,(0 => -10));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1));
        check_rand_value(v_int, (0 => (-2,2)), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (range + 2 sets of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, ADD,(-10,15,16), EXCL,(1,15));
        check_rand_value(v_int, (0 => (-2,2)), ADD,(-10,15,16), EXCL,(1,15));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(1,15), ADD,(-10,15,16));
        check_rand_value(v_int, (0 => (-2,2)), EXCL,(1,15), ADD,(-10,15,16));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-1, 1, ADD,(-10), ADD,(15,16));
        check_rand_value(v_int, (0 => (-1,1)), ADD, (-10,15,16));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(-3, 3, EXCL,(-2), EXCL,(2));
        check_rand_value(v_int, (0 => (-3,3)), EXCL, (-2,2));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer (full range)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(integer'left, integer'right);
        check_rand_value(v_int, (0 => (integer'left,integer'right)));
        -- Since range of values is too big to verify the distribution, we only check that the value is different than the previous one
        check_value(v_int /= v_prev_int, TB_ERROR, "Checking value is different than previous one");
        v_prev_int := v_int;
      end loop;

      v_found := false;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(integer'right-1, integer'right, ADD,(-10));
        check_rand_value(v_int, (0 => (integer'right-1,integer'right)), ADD,(0 => -10));
        v_found := true when v_int = -10;
      end loop;
      check_value(v_found, TB_ERROR, "Checking ADD value is generated");

      v_found := false;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(integer'right-1, integer'right, ADD,(-10), EXCL,(integer'right));
        check_rand_value(v_int, (0 => (integer'right-1,integer'right)), ADD,(0 => -10), EXCL,(integer'right,0));
        v_found := true when v_int = -10;
      end loop;
      check_value(v_found, TB_ERROR, "Checking ADD value is generated");

      v_found := false;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int := v_rand.rand(integer'right-1, integer'right, EXCL,(integer'right), ADD,(-10));
        check_rand_value(v_int, (0 => (integer'right-1,integer'right)), EXCL,(integer'right,0), ADD,(0 => -10));
        v_found := true when v_int = -10;
      end loop;
      check_value(v_found, TB_ERROR, "Checking ADD value is generated");

      log(ID_LOG_HDR, "Testing integer (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8);
      v_int := v_rand.rand(10, 0);                                           -- TB_ERROR: min_value > max_value
      v_int := v_rand.rand(ADD,(1,2));                                       -- TB_ERROR: wrong specifier
      v_int := v_rand.rand(1,10, ONLY,(1,2,3));                              -- TB_ERROR: wrong specifier
      v_int := v_rand.rand(1,10, ONLY,(1,2,3), EXCL,(1,2,3));                -- TB_ERROR: wrong specifier
      v_int := v_rand.rand(1,10, EXCL,(1,2,3), ONLY,(1,2,3));                -- TB_ERROR: wrong specifier
      v_int := v_rand.rand(integer'left, integer'right, ADD,(0));            -- TB_ERROR: constraints too big
      v_int := v_rand.rand(integer'left, integer'right, ADD,(0), EXCL,(1));  -- TB_ERROR: constraints too big
      v_int := v_rand.rand(integer'left, integer'right, EXCL,(-1), ADD,(0)); -- TB_ERROR: constraints too big

      ------------------------------------------------------------
      -- Integer Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer_vector (range)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2);
        check_rand_value(v_int_vec, (0 => (-2,2)));
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, UNIQUE);
        check_rand_value(v_int_vec, (0 => (-2,2)));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (set of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2));
        check_rand_value(v_int_vec, ONLY,(-2,-1,0,1,2));
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), UNIQUE);
        check_rand_value(v_int_vec, ONLY,(-2,-1,0,1,2));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (range + set of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, ADD,(-10));
        check_rand_value(v_int_vec, (0 => (-1,1)), ADD,(0 => -10));
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, ADD,(-10,15), UNIQUE);
        check_rand_value(v_int_vec, (0 => (-1,1)), ADD,(-10,15));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), UNIQUE);
        check_rand_value(v_int_vec, (0 => (-3,4)), EXCL,(-1,0,1));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (range + 2 sets of values)");
      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, ADD,(-10,15,16), EXCL,(1,15));
        check_rand_value(v_int_vec, (0 => (-2,2)), ADD,(-10,15,16), EXCL,(1,15));
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, ADD,(-10,15,16), EXCL,(1,15,16), UNIQUE);
        check_rand_value(v_int_vec, (0 => (-2,2)), ADD,(-10,15,16), EXCL,(1,15,16));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, EXCL,(-1,15,16), ADD,(-10,15,16), UNIQUE);
        check_rand_value(v_int_vec, (0 => (-2,2)), EXCL,(-1,15,16), ADD,(-10,15,16));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, ADD,(-10), ADD,(15,16), UNIQUE);
        check_rand_value(v_int_vec, (0 => (-1,1)), ADD,(-10,15,16));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -3, 3, EXCL,(-2), EXCL,(2), UNIQUE);
        check_rand_value(v_int_vec, (0 => (-3,3)), EXCL,(-2,2));
        check_uniqueness(v_int_vec);
        count_rand_value(v_value_cnt, v_int_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 7);
      v_int_vec := v_rand.rand(v_int_vec'length, 10,1);                                    -- TB_ERROR: min_value > max_value
      v_int_vec := v_rand.rand(v_int_vec'length, ADD,(1,2));                               -- TB_ERROR: wrong specifier
      v_int_vec := v_rand.rand(v_int_vec'length, 1,10, ONLY,(1,2,3));                      -- TB_ERROR: wrong specifier
      v_int_vec := v_rand.rand(v_int_vec'length, 1,10, ONLY,(1,2,3), EXCL,(1,2,3));        -- TB_ERROR: wrong specifier
      v_int_vec := v_rand.rand(v_int_vec'length, 1,10, EXCL,(1,2,3), ONLY,(1,2,3));        -- TB_ERROR: wrong specifier
      v_int_vec := v_rand.rand(v_int_vec'length, integer'left,integer'right, ADD,(1,2,3)); -- TB_ERROR: constraints too big
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(0,1), UNIQUE);                      -- TB_ERROR: not enough constraints

      ------------------------------------------------------------
      -- Real
      -- It is impossible to verify every value within a real range
      -- is generated, so instead only the rounded values are verified.
      -- There is twice as many repetitions since the values are discrete.
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing real (range)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0);
        check_rand_value(v_real, (0 => (-1.0,1.0)));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(ONLY,(-2.0,0.555,2.0));
        check_rand_value(v_real, ONLY,(-2.0,0.555,2.0));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, ADD,(15.5));
        check_rand_value(v_real, (0 => (-1.0,1.0)), ADD,(0 => 15.5));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, EXCL,(-1.0,0.0,1.0));
        check_rand_value(v_real, (0 => (-1.0,1.0)), EXCL,(-1.0,0.0,1.0));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (range + 2 sets of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, ADD,(15.5,16.6), EXCL,(-1.0,16.6));
        check_rand_value(v_real, (0 => (-1.0,1.0)), ADD,(15.5,16.6), EXCL,(-1.0,16.6));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, EXCL,(-1.0,16.6), ADD,(15.5,16.6));
        check_rand_value(v_real, (0 => (-1.0,1.0)), EXCL,(-1.0,16.6), ADD,(15.5,16.6));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, ADD,(15.5), ADD,(16.6,17.7));
        check_rand_value(v_real, (0 => (-1.0,1.0)), ADD,(15.5,16.6,17.7));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS*2 loop
        v_real := v_rand.rand(-1.0, 1.0, EXCL,(-1.0), EXCL,(1.0));
        check_rand_value(v_real, (0 => (-1.0,1.0)), EXCL,(-1.0,1.0));
        count_rand_value(v_value_cnt, v_real);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 5);
      v_real := v_rand.rand(10.0, 0.0);                                        -- TB_ERROR: min_value > max_value
      v_real := v_rand.rand(ADD,(1.0,2.0));                                    -- TB_ERROR: wrong specifier
      v_real := v_rand.rand(1.0,10.0, ONLY,(1.0,2.0,3.0));                     -- TB_ERROR: wrong specifier
      v_real := v_rand.rand(1.0,10.0, ONLY,(1.0,2.0,3.0), EXCL,(1.0,2.0,3.0)); -- TB_ERROR: wrong specifier
      v_real := v_rand.rand(1.0,10.0, EXCL,(1.0,2.0,3.0), ONLY,(1.0,2.0,3.0)); -- TB_ERROR: wrong specifier

      ------------------------------------------------------------
      -- Real Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing real_vector (range)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0);
        check_rand_value(v_real_vec, (0 => (-2.0,2.0)));
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, UNIQUE);
        check_rand_value(v_real_vec, (0 => (-2.0,2.0)));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real_vector (set of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.25,1.1,2.0));
        check_rand_value(v_real_vec, ONLY,(-2.0,-1.1,0.25,1.1,2.0));
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.25,1.1,2.0), UNIQUE);
        check_rand_value(v_real_vec, ONLY,(-2.0,-1.1,0.25,1.1,2.0));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real_vector (range + set of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5));
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), ADD,(0 => 15.5));
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5,16.6), UNIQUE);
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), ADD,(15.5,16.6));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0,0.0,1.0), UNIQUE);
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), EXCL,(-1.0,0.0,1.0));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real_vector (range + 2 sets of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5,16.6), EXCL,(-1.0,16.6));
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), ADD,(15.5,16.6), EXCL,(-1.0,16.6));
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5,16.6), EXCL,(-1.0,16.6), UNIQUE);
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), ADD,(15.5,16.6), EXCL,(-1.0,16.6));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0,16.6), ADD,(15.5,16.6), UNIQUE);
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), EXCL,(-1.0,16.6), ADD,(15.5,16.6));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5), ADD,(16.6,17.7), UNIQUE);
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), ADD,(15.5,16.6,17.7));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to C_NUM_RAND_REPETITIONS*2 loop
        v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0), EXCL,(1.0), UNIQUE);
        check_rand_value(v_real_vec, (0 => (-1.0,1.0)), EXCL,(-1.0,1.0));
        check_uniqueness(v_real_vec);
        count_rand_value(v_value_cnt, v_real_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing real_vector (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 6);
      v_real_vec := v_rand.rand(v_real_vec'length, 10.0,1.0);                                         -- TB_ERROR: min_value > max_value
      v_real_vec := v_rand.rand(v_real_vec'length, ADD,(1.0,2.0));                                    -- TB_ERROR: wrong specifier
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,10.0, ONLY,(1.0,2.0,3.0));                     -- TB_ERROR: wrong specifier
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,10.0, ONLY,(1.0,2.0,3.0), EXCL,(1.0,2.0,3.0)); -- TB_ERROR: wrong specifier
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,10.0, EXCL,(1.0,2.0,3.0), ONLY,(1.0,2.0,3.0)); -- TB_ERROR: wrong specifier
      v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(0.0,1.0), UNIQUE);                           -- TB_ERROR: not enough constraints

      ------------------------------------------------------------
      -- Time
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing time (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps);
        check_rand_value(v_time, (0 => (-2 ps,2 ps)));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(ONLY,(-2 ps,1 ps,2 ps));
        check_rand_value(v_time, ONLY,(-2 ps,1 ps,2 ps));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-1 ps, 1 ps, ADD,(-15 ps));
        check_rand_value(v_time, (0 => (-1 ps,1 ps)), ADD,(0 => -15 ps));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(-1 ps,0 ps,1 ps));
        check_rand_value(v_time, (0 => (-2 ps,2 ps)), EXCL,(-1 ps,0 ps,1 ps));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time (range + 2 sets of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, ADD,(-15 ps,16 ps,17 ps), EXCL,(1 ps,16 ps));
        check_rand_value(v_time, (0 => (-2 ps,2 ps)), ADD,(-15 ps,16 ps,17 ps), EXCL,(1 ps,16 ps));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-2 ps, 2 ps, EXCL,(1 ps,16 ps), ADD,(-15 ps,16 ps,17 ps));
        check_rand_value(v_time, (0 => (-2 ps,2 ps)), EXCL,(1 ps,16 ps), ADD,(-15 ps,16 ps,17 ps));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-1 ps, 1 ps, ADD,(-15 ps), ADD,(17 ps,18 ps));
        check_rand_value(v_time, (0 => (-1 ps,1 ps)), ADD,(-15 ps,17 ps,18 ps));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_time := v_rand.rand(-3 ps, 3 ps, EXCL,(-2 ps), EXCL,(2 ps));
        check_rand_value(v_time, (0 => (-3 ps,3 ps)), EXCL,(-2 ps,2 ps));
        count_rand_value(v_value_cnt, v_time);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 5);
      v_time := v_rand.rand(10 ns, 0 ns);                                              -- TB_ERROR: min_value > max_value
      v_time := v_rand.rand(ADD,(1 ps,2 ps));                                          -- TB_ERROR: wrong specifier
      v_time := v_rand.rand(1 ps,10 ps, ONLY,(1 ps,2 ps,3 ps));                        -- TB_ERROR: wrong specifier
      v_time := v_rand.rand(1 ps,10 ps, ONLY,(1 ps,2 ps,3 ps), EXCL,(1 ps,2 ps,3 ps)); -- TB_ERROR: wrong specifier
      v_time := v_rand.rand(1 ps,10 ps, EXCL,(1 ps,2 ps,3 ps), ONLY,(1 ps,2 ps,3 ps)); -- TB_ERROR: wrong specifier

      ------------------------------------------------------------
      -- Time Vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing time_vector (range)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps);
        check_rand_value(v_time_vec, (0 => (-2 ps,2 ps)));
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, UNIQUE);
        check_rand_value(v_time_vec, (0 => (-2 ps,2 ps)));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time_vector (set of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps));
        check_rand_value(v_time_vec, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps));
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps), UNIQUE);
        check_rand_value(v_time_vec, ONLY,(-2 ps,-1 ps,0 ps,1 ps,2 ps));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time_vector (range + set of values)");
      v_num_values := 4;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -1 ps, 1 ps, ADD,(-15 ps));
        check_rand_value(v_time_vec, (0 => (-1 ps,1 ps)), ADD,(0 => -15 ps));
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -1 ps, 1 ps, ADD,(-15 ps,16 ps), UNIQUE);
        check_rand_value(v_time_vec, (0 => (-1 ps,1 ps)), ADD,(-15 ps,16 ps));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -4 ps, 4 ps, EXCL,(-1 ps,0 ps,1 ps), UNIQUE);
        check_rand_value(v_time_vec, (0 => (-4 ps,4 ps)), EXCL,(-1 ps,0 ps,1 ps));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time_vector (range + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, ADD,(-15 ps,16 ps), EXCL,(1 ps,16 ps));
        check_rand_value(v_time_vec, (0 => (-2 ps,2 ps)), ADD,(-15 ps,16 ps), EXCL,(1 ps,16 ps));
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, ADD,(-15 ps,16 ps,17 ps), EXCL,(-1 ps,0 ps,16 ps), UNIQUE);
        check_rand_value(v_time_vec, (0 => (-2 ps,2 ps)), ADD,(-15 ps,16 ps,17 ps), EXCL,(-1 ps,0 ps,16 ps));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps, EXCL,(-1 ps,0 ps,16 ps), ADD,(-15 ps,16 ps,17 ps), UNIQUE);
        check_rand_value(v_time_vec, (0 => (-2 ps,2 ps)), EXCL,(-1 ps,0 ps,16 ps), ADD,(-15 ps,16 ps,17 ps));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -1 ps, 1 ps, ADD,(-15 ps), ADD,(17 ps,18 ps), UNIQUE);
        check_rand_value(v_time_vec, (0 => (-1 ps,1 ps)), ADD,(-15 ps,17 ps,18 ps));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_time_vec := v_rand.rand(v_time_vec'length, -3 ps, 3 ps, EXCL,(-2 ps), EXCL,(2 ps), UNIQUE);
        check_rand_value(v_time_vec, (0 => (-3 ps,3 ps)), EXCL,(-2 ps,2 ps));
        check_uniqueness(v_time_vec);
        count_rand_value(v_value_cnt, v_time_vec);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing time_vector (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 6);
      v_time_vec := v_rand.rand(v_time_vec'length, 10 ps,1 ps);                                               -- TB_ERROR: min_value > max_value
      v_time_vec := v_rand.rand(v_time_vec'length, ADD,(1 ps,2 ps));                                          -- TB_ERROR: wrong specifier
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,10 ps, ONLY,(1 ps,2 ps,3 ps));                        -- TB_ERROR: wrong specifier
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,10 ps, ONLY,(1 ps,2 ps,3 ps), EXCL,(1 ps,2 ps,3 ps)); -- TB_ERROR: wrong specifier
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,10 ps, EXCL,(1 ps,2 ps,3 ps), ONLY,(1 ps,2 ps,3 ps)); -- TB_ERROR: wrong specifier
      v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(0 ps,1 ps), UNIQUE);                                 -- TB_ERROR: not enough constraints

      ------------------------------------------------------------
      -- Unsigned
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unsigned (length)");
      v_num_values := 2**v_uns'length;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length);
        check_rand_value(v_uns, (0 => (0,2**v_uns'length-1)));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (range)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 3);
        check_rand_value(v_uns, (0 => (0,3)));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, ONLY,(0,1,2));
        check_rand_value(v_uns, ONLY,(0,1,2));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2**v_uns'length-10;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, EXCL,(0,1,2,3,4,5,6,7,8,9));
        check_rand_value(v_uns, (0 => (0,2**v_uns'length-1)), EXCL,(0,1,2,3,4,5,6,7,8,9));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(7));
        check_rand_value(v_uns, (0 => (0,2)), ADD,(0 => 7));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_uns, (0 => (0,3)), EXCL,(1,2));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (range + 2 sets of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(7,8), EXCL,(1,8));
        check_rand_value(v_uns, (0 => (0,2)), ADD,(7,8), EXCL,(1,8));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, EXCL,(1,2,8), ADD,(7,8,9));
        check_rand_value(v_uns, (0 => (0,2)), EXCL,(1,2,8), ADD,(7,8,9));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(7), ADD,(8,9));
        check_rand_value(v_uns, (0 => (0,2)), ADD,(7,8,9));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 5, EXCL,(0), EXCL,(2));
        check_rand_value(v_uns, (0 => (0,5)), EXCL,(0,2));
        count_rand_value(v_value_cnt, v_uns);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8);
      v_uns := v_rand.rand(v_uns'length, 5, 0);                                  -- TB_ERROR: min_value < max_value
      v_uns := v_rand.rand(v_uns'length, 0, 2**16);                              -- TB_ERROR: constraints too big
      v_uns := v_rand.rand(v_uns'length, ONLY,(2**17, 2**18));                   -- TB_ERROR: constraints too big
      v_uns := v_rand.rand(v_uns'length, 0, 2**16, ADD,(0, 2));                  -- TB_ERROR: constraints too big
      v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(2**17, 2**18));              -- TB_ERROR: constraints too big
      v_uns := v_rand.rand(v_uns'length, 0, 2**16, ADD,(0, 2), EXCL,(0, 1));     -- TB_ERROR: constraints too big
      v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(2**17, 2**18), EXCL,(0, 1)); -- TB_ERROR: constraints too big
      v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(0, 2), EXCL,(2**17, 2**18)); -- TB_ERROR: constraints too big

      ------------------------------------------------------------
      -- Unsigned long
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unsigned (length)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length);
        -- Since range of values is too big, we only check that the value is different than the previous one
        check_value(v_uns_long /= v_prev_uns_long, TB_ERROR, "Checking value is different than previous one");
        v_prev_uns_long := v_uns_long;
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing unsigned (range long vectors)");
      v_num_values := 9;
      v_uns_long_min := x"0F000000000000000000000000000000";
      v_uns_long_max := x"0F000000000000000000000000000008";
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, v_uns_long_min, v_uns_long_max);
        check_rand_value_long(v_uns_long, (0 => (v_uns_long_min,v_uns_long_max)));
        count_rand_value(v_value_cnt, v_uns_long-v_uns_long_min);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      v_uns_long_min := x"00F00000000000000000000000000000";
      v_uns_long_max := x"00F00000000000000000000000000003";
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long_min, v_uns_long_max);
        check_rand_value_long(v_uns_long, (0 => (v_uns_long_min,v_uns_long_max)));
        count_rand_value(v_value_cnt, v_uns_long-v_uns_long_min);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (range)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 3);
        check_rand_value(v_uns_long, (0 => (0,3)));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, integer'right);
        check_rand_value(v_uns_long, (0 => (0,integer'right)));
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing unsigned (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, ONLY,(0,1,2));
        check_rand_value(v_uns_long, ONLY,(0,1,2));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, EXCL,(0,1,2,3,4,5,6,7,8,9));
        -- Since range of values is too big, we only check that the value is different than the previous one
        check_value(v_uns_long /= v_prev_uns_long, TB_ERROR, "Checking value is different than previous one");
        v_prev_uns_long := v_uns_long;
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing unsigned (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 2, ADD,(7));
        check_rand_value(v_uns_long, (0 => (0,2)), ADD,(0 => 7));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_uns_long, (0 => (0,3)), EXCL,(1,2));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (range + 2 sets of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 2, ADD,(7,8), EXCL,(1,8));
        check_rand_value(v_uns_long, (0 => (0,2)), ADD,(7,8), EXCL,(1,8));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 2, EXCL,(1,2,8), ADD,(7,8,9));
        check_rand_value(v_uns_long, (0 => (0,2)), EXCL,(1,2,8), ADD,(7,8,9));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 2, ADD,(7), ADD,(8,9));
        check_rand_value(v_uns_long, (0 => (0,2)), ADD,(7,8,9));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, 0, 5, EXCL,(0), EXCL,(2));
        check_rand_value(v_uns_long, (0 => (0,5)), EXCL,(0,2));
        count_rand_value(v_value_cnt, v_uns_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing unsigned (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 2);
      v_uns_long := v_rand.rand(v_uns_long'length, v_uns_long_max, v_uns_long_min); -- TB_ERROR: min_value < max_value
      v_uns_long := v_rand.rand(v_uns_long_max, v_uns_long_min);                    -- TB_ERROR: min_value < max_value

      ------------------------------------------------------------
      -- Signed
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing signed (length)");
      v_num_values := 2**v_sig'length;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length);
        check_rand_value(v_sig, (0 => (-2**(v_sig'length-1),2**(v_sig'length-1)-1)));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2);
        check_rand_value(v_sig, (0 => (-2,2)));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, ONLY,(-2,0,2));
        check_rand_value(v_sig, ONLY,(-2,0,2));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2**v_sig'length-10;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, EXCL,(-5,-4,-3,-2,-1,0,1,2,3,4));
        check_rand_value(v_sig, (0 => (-2**(v_sig'length-1),2**(v_sig'length-1)-1)), EXCL,(-5,-4,-3,-2,-1,0,1,2,3,4));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -1, 1, ADD,(-8));
        check_rand_value(v_sig, (0 => (-1,1)), ADD,(0 => -8));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1));
        check_rand_value(v_sig, (0 => (-2,2)), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (range + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, ADD,(-8,7), EXCL,(1,7));
        check_rand_value(v_sig, (0 => (-2,2)), ADD,(-8,7), EXCL,(1,7));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(1,7), ADD,(-8,7));
        check_rand_value(v_sig, (0 => (-2,2)), EXCL,(1,7), ADD,(-8,7));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -1, 1, ADD,(-8), ADD,(6,7));
        check_rand_value(v_sig, (0 => (-1,1)), ADD,(-8,6,7));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -3, 3, EXCL,(-2), EXCL,(2));
        check_rand_value(v_sig, (0 => (-3,3)), EXCL,(-2,2));
        count_rand_value(v_value_cnt, v_sig);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8);
      v_sig := v_rand.rand(v_sig'length, 5, 0);                                   -- TB_ERROR: min_value < max_value
      v_sig := v_rand.rand(v_sig'length, 0, 2**16);                               -- TB_ERROR: constraints too big
      v_sig := v_rand.rand(v_sig'length, ONLY,(2**17, 2**18));                    -- TB_ERROR: constraints too big
      v_sig := v_rand.rand(v_sig'length, 0, 2**16, ADD,(0, 2));                   -- TB_ERROR: constraints too big
      v_sig := v_rand.rand(v_sig'length, 0, 2, ADD,(2**17, 2**18));               -- TB_ERROR: constraints too big
      v_sig := v_rand.rand(v_sig'length, 0, 2**16, ADD,(0, 2), EXCL,(0, 1));      -- TB_ERROR: constraints too big
      v_sig := v_rand.rand(v_sig'length, 0, 2, ADD,(2**17, 2**18), EXCL,(0, 1));  -- TB_ERROR: constraints too big
      v_sig := v_rand.rand(v_sig'length, 0, 2, ADD,(0, 2), EXCL,(2**17, 2**18));  -- TB_ERROR: constraints too big

      ------------------------------------------------------------
      -- Signed long
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing signed (length)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length);
        -- Since range of values is too big, we only check that the value is different than the previous one
        check_value(v_sig_long /= v_prev_sig_long, TB_ERROR, "Checking value is different than previous one");
        v_prev_sig_long := v_sig_long;
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing signed (range long vectors)");
      v_num_values := 9;
      v_sig_long_min := x"8F000000000000000000000000000000";
      v_sig_long_max := x"8F000000000000000000000000000008";
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, v_sig_long_min, v_sig_long_max);
        check_rand_value_long(v_sig_long, (0 => (v_sig_long_min,v_sig_long_max)));
        count_rand_value(v_value_cnt, v_sig_long-v_sig_long_min);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      v_sig_long_min := x"00F00000000000000000000000000000";
      v_sig_long_max := x"00F00000000000000000000000000003";
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long_min, v_sig_long_max);
        check_rand_value_long(v_sig_long, (0 => (v_sig_long_min,v_sig_long_max)));
        count_rand_value(v_value_cnt, v_sig_long-v_sig_long_min);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -2, 2);
        check_rand_value(v_sig_long, (0 => (-2,2)));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, integer'left, integer'right);
        check_rand_value(v_sig_long, (0 => (integer'left,integer'right)));
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing signed (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, ONLY,(-2,0,2));
        check_rand_value(v_sig_long, ONLY,(-2,0,2));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, EXCL,(-5,-4,-3,-2,-1,0,1,2,3,4));
        -- Since range of values is too big, we only check that the value is different than the previous one
        check_value(v_sig_long /= v_prev_sig_long, TB_ERROR, "Checking value is different than previous one");
        v_prev_sig_long := v_sig_long;
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing signed (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -1, 1, ADD,(-8));
        check_rand_value(v_sig_long, (0 => (-1,1)), ADD,(0 => -8));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -2, 2, EXCL,(-1,0,1));
        check_rand_value(v_sig_long, (0 => (-2,2)), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (range + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -2, 2, ADD,(-8,7), EXCL,(1,7));
        check_rand_value(v_sig_long, (0 => (-2,2)), ADD,(-8,7), EXCL,(1,7));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -2, 2, EXCL,(1,7), ADD,(-8,7));
        check_rand_value(v_sig_long, (0 => (-2,2)), EXCL,(1,7), ADD,(-8,7));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -1, 1, ADD,(-8), ADD,(6,7));
        check_rand_value(v_sig_long, (0 => (-1,1)), ADD,(-8,6,7));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, -3, 3, EXCL,(-2), EXCL,(2));
        check_rand_value(v_sig_long, (0 => (-3,3)), EXCL,(-2,2));
        count_rand_value(v_value_cnt, v_sig_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing signed (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 2);
      v_sig_long := v_rand.rand(v_sig_long'length, v_sig_long_max, v_sig_long_min); -- TB_ERROR: min_value < max_value
      v_sig_long := v_rand.rand(v_sig_long_max, v_sig_long_min);                    -- TB_ERROR: min_value < max_value

      ------------------------------------------------------------
      -- Std_logic_vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic_vector (length)");
      v_num_values := 2**v_slv'length;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length);
        check_rand_value(v_slv, (0 => (0,(2**v_slv'length)-1)));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (range)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 3);
        check_rand_value(v_slv, (0 => (0,3)));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, ONLY,(0,1,2));
        check_rand_value(v_slv, ONLY,(0,1,2));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2**v_slv'length-10;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, EXCL,(0,1,2,3,4,5,6,7,8,9));
        check_rand_value(v_slv, (0 => (0,2**v_slv'length-1)), EXCL,(0,1,2,3,4,5,6,7,8,9));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(7));
        check_rand_value(v_slv, (0 => (0,2)), ADD,(0 => 7));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_slv, (0 => (0,3)), EXCL,(1,2));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (range + 2 sets of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(7,8), EXCL,(1,8));
        check_rand_value(v_slv, (0 => (0,2)), ADD,(7,8), EXCL,(1,8));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, EXCL,(1,2,8), ADD,(7,8,9));
        check_rand_value(v_slv, (0 => (0,2)), EXCL,(1,2,8), ADD,(7,8,9));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(7), ADD,(9,10));
        check_rand_value(v_slv, (0 => (0,2)), ADD,(7,9,10));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 5, EXCL,(0), EXCL,(2));
        check_rand_value(v_slv, (0 => (0,5)), EXCL,(0,2));
        count_rand_value(v_value_cnt, v_slv);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 8);
      v_slv := v_rand.rand(v_slv'length, 5, 0);                                   -- TB_ERROR: min_value < max_value
      v_slv := v_rand.rand(v_slv'length, 0, 2**16);                               -- TB_ERROR: constraints too big
      v_slv := v_rand.rand(v_slv'length, ONLY,(2**17, 2**18));                    -- TB_ERROR: constraints too big
      v_slv := v_rand.rand(v_slv'length, 0, 2**16, ADD,(0, 2));                   -- TB_ERROR: constraints too big
      v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(2**17, 2**18));               -- TB_ERROR: constraints too big
      v_slv := v_rand.rand(v_slv'length, 0, 2**16, ADD,(0, 2), EXCL,(0, 1));      -- TB_ERROR: constraints too big
      v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(2**17, 2**18), EXCL,(0, 1));  -- TB_ERROR: constraints too big
      v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(0, 2), EXCL,(2**17, 2**18));  -- TB_ERROR: constraints too big

      ------------------------------------------------------------
      -- Std_logic_vector long
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic_vector (length)");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length);
        -- Since range of values is too big, we only check that the value is different than the previous one
        check_value(v_slv_long /= v_prev_slv_long, TB_ERROR, "Checking value is different than previous one");
        v_prev_slv_long := v_slv_long;
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing std_logic_vector (range long vectors)");
      v_num_values := 9;
      v_slv_long_min := x"0F000000000000000000000000000000";
      v_slv_long_max := x"0F000000000000000000000000000008";
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, v_slv_long_min, v_slv_long_max);
        check_rand_value_long(unsigned(v_slv_long), (0 => (unsigned(v_slv_long_min),unsigned(v_slv_long_max))));
        count_rand_value(v_value_cnt, unsigned(v_slv_long)-unsigned(v_slv_long_min));
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      v_slv_long_min := x"00F00000000000000000000000000000";
      v_slv_long_max := x"00F00000000000000000000000000003";
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long_min, v_slv_long_max);
        check_rand_value_long(unsigned(v_slv_long), (0 => (unsigned(v_slv_long_min),unsigned(v_slv_long_max))));
        count_rand_value(v_value_cnt, unsigned(v_slv_long)-unsigned(v_slv_long_min));
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (range)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 3);
        check_rand_value(v_slv_long, (0 => (0,3)));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, integer'right);
        check_rand_value(v_slv_long, (0 => (0,integer'right)));
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, ONLY,(0,1,2));
        check_rand_value(v_slv_long, ONLY,(0,1,2));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, EXCL,(0,1,2,3,4,5,6,7,8,9));
        -- Since range of values is too big, we only check that the value is different than the previous one
        check_value(v_slv_long /= v_prev_slv_long, TB_ERROR, "Checking value is different than previous one");
        v_prev_slv_long := v_slv_long;
      end loop;
      -- Since the range of values is bigger than the integer range we can't verify the distribution

      log(ID_LOG_HDR, "Testing std_logic_vector (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 2, ADD,(7));
        check_rand_value(v_slv_long, (0 => (0,2)), ADD,(0 => 7));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 3, EXCL,(1,2));
        check_rand_value(v_slv_long, (0 => (0,3)), EXCL,(1,2));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (range + 2 sets of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 2, ADD,(7,8), EXCL,(1,8));
        check_rand_value(v_slv_long, (0 => (0,2)), ADD,(7,8), EXCL,(1,8));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 2, EXCL,(1,2,8), ADD,(7,8,9));
        check_rand_value(v_slv_long, (0 => (0,2)), EXCL,(1,2,8), ADD,(7,8,9));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 2, ADD,(7), ADD,(9,10));
        check_rand_value(v_slv_long, (0 => (0,2)), ADD,(7,9,10));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_RAND_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, 0, 5, EXCL,(0), EXCL,(2));
        check_rand_value(v_slv_long, (0 => (0,5)), EXCL,(0,2));
        count_rand_value(v_value_cnt, v_slv_long);
      end loop;
      check_uniform_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing std_logic_vector (invalid parameters)");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 2);
      v_slv_long := v_rand.rand(v_slv_long'length, v_slv_long_max, v_slv_long_min); -- TB_ERROR: min_value < max_value
      v_slv_long := v_rand.rand(v_slv_long_max, v_slv_long_min);                    -- TB_ERROR: min_value < max_value

      ------------------------------------------------------------
      -- Std_logic & boolean
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic & boolean");
      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_std := v_rand.rand(VOID);
        v_bit_check := (v_bit_check or "10") when v_std else (v_bit_check or "01");
      end loop;
      check_value(v_bit_check, "11", ERROR, "Check '0' and '1' are generated");
      v_bit_check := "00";

      for i in 1 to C_NUM_RAND_REPETITIONS loop
        v_bln := v_rand.rand(VOID);
        v_bit_check := (v_bit_check or "10") when v_bln else (v_bit_check or "01");
      end loop;
      check_value(v_bit_check, "11", ERROR, "Check true and false are generated");
      v_bit_check := "00";

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing zero constraints");
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_ERROR,3);
      v_int := v_rand.rand(1,2, EXCL,(1,2));
      v_int := v_rand.rand(1,2, ADD,(5), EXCL,(1,2,5));
      v_int := v_rand.rand(1,2, EXCL,(1,2,5,6), ADD, (5,6));

      increment_expected_alerts_and_stop_limit(TB_ERROR,3);
      v_real := v_rand.rand(1.0,1.0, EXCL,(1.0));
      v_real := v_rand.rand(1.0,1.0, ADD,(5.0), EXCL,(1.0,5.0));
      v_real := v_rand.rand(1.0,1.0, EXCL,(1.0,5.0,6.0), ADD,(5.0,6.0));

      increment_expected_alerts_and_stop_limit(TB_ERROR,3);
      v_time := v_rand.rand(1 ps,2 ps, EXCL,(1 ps,2 ps));
      v_time := v_rand.rand(1 ps,2 ps, ADD,(5 ps), EXCL,(1 ps,2 ps,5 ps));
      v_time := v_rand.rand(1 ps,2 ps, EXCL,(1 ps,2 ps,5 ps,6 ps), ADD, (5 ps,6 ps));

      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_uns := v_rand.rand(v_uns'length, EXCL,(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15));

      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_sig := v_rand.rand(v_sig'length, EXCL,(-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7));

      increment_expected_alerts_and_stop_limit(TB_ERROR,6);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,2, EXCL,(1,2));
      v_int_vec := v_rand.rand(v_int_vec'length, 1,2, EXCL,(1,2), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,2, ADD,(5), EXCL,(1,2,5));
      v_int_vec := v_rand.rand(v_int_vec'length, 1,2, ADD,(5), EXCL,(1,2,5), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,2, EXCL,(1,2,5,6), ADD,(5,6));
      v_int_vec := v_rand.rand(v_int_vec'length, 1,2, EXCL,(1,2,5,6), ADD,(5,6), UNIQUE);

      increment_expected_alerts_and_stop_limit(TB_ERROR,6);
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, EXCL,(1.0));
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, EXCL,(1.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, ADD,(5.0), EXCL,(1.0,5.0));
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, ADD,(5.0), EXCL,(1.0,5.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, EXCL,(1.0,5.0,6.0), ADD,(5.0,6.0));
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, EXCL,(1.0,5.0,6.0), ADD,(5.0,6.0), UNIQUE);

      increment_expected_alerts_and_stop_limit(TB_ERROR,6);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,2 ps, EXCL,(1 ps,2 ps));
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,2 ps, EXCL,(1 ps,2 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,2 ps, ADD,(5 ps), EXCL,(1 ps,2 ps,5 ps));
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,2 ps, ADD,(5 ps), EXCL,(1 ps,2 ps,5 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,2 ps, EXCL,(1 ps,2 ps,5 ps,6 ps), ADD,(5 ps,6 ps));
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,2 ps, EXCL,(1 ps,2 ps,5 ps,6 ps), ADD,(5 ps,6 ps), UNIQUE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing not enough unique constraints");
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_ERROR,8);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,1, UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,4, UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(1,2,3,4), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(1,2,3,4,4), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,6, EXCL,(1,2), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,6, ADD,(7), EXCL,(1,2,3), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,6, ADD,(6,7,7), EXCL,(1,2,3), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,6, EXCL,(1,2,3), ADD,(6,7,7), UNIQUE);

      increment_expected_alerts_and_stop_limit(TB_ERROR,6);
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(1.0,2.0,3.0,4.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(1.0,2.0,3.0,4.0,4.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, ADD,(2.0,3.0,4.0,5.0,6.0,7.0), EXCL,(1.0,2.0,3.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, ADD,(1.0,2.0,3.0,4.0,5.0,6.0,7.0,7.0), EXCL,(1.0,2.0,3.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, EXCL,(1.0,2.0,3.0), ADD,(1.0,2.0,3.0,4.0,5.0,6.0,7.0,7.0), UNIQUE);

      increment_expected_alerts_and_stop_limit(TB_ERROR,8);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,1 ps, UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,4 ps, UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(1 ps,2 ps,3 ps,4 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, ONLY,(1 ps,2 ps,3 ps,4 ps,4 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,6 ps, EXCL,(1 ps,2 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,6 ps, ADD,(7 ps), EXCL,(1 ps,2 ps,3 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,6 ps, ADD,(6 ps,7 ps,7 ps), EXCL,(1 ps,2 ps,3 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,6 ps, EXCL,(1 ps,2 ps,3 ps), ADD,(6 ps,7 ps,7 ps), UNIQUE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing exact unique constraints (with repeated values)");
      ------------------------------------------------------------
      v_int_vec := v_rand.rand(v_int_vec'length, 1,7, EXCL,(1,2,2,2,2,100,100,100), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,7, ADD,(8), EXCL,(1,2,2,2,3,3,3,100,100,100), UNIQUE);

      v_real_vec := v_rand.rand(v_real_vec'length, 1.0,1.0, ADD,(2.0,3.0,4.0,5.0,6.0,7.0), EXCL,(1.0,2.0,2.0,100.0,100.0), UNIQUE);

      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,7 ps, EXCL,(1 ps,2 ps,2 ps,2 ps,2 ps,100 ps,100 ps,100 ps), UNIQUE);
      v_time_vec := v_rand.rand(v_time_vec'length, 1 ps,7 ps, ADD,(8 ps), EXCL,(1 ps,2 ps,2 ps,2 ps,3 ps,3 ps,3 ps,100 ps,100 ps,100 ps), UNIQUE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing small and big unique ranges");
      ------------------------------------------------------------
      for i in v_incr_list'range loop
        v_incr_list(i) := i;
      end loop;
      log(ID_SEQUENCER, "Generate 5 unique values");
      v_int_vec := v_rand.rand(v_int_vec'length, 1,5, UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(1,2,3,4,5), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,6, EXCL,(1), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,10, EXCL,(1,2,3,4,5), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, 1,40, EXCL,(v_incr_list(1 to 35)), UNIQUE);
      log(ID_SEQUENCER, "Generate 128 unique values");
      v_int_vec_long := v_rand.rand(v_int_vec_long'length, 1,128, UNIQUE);
      v_int_vec_long := v_rand.rand(v_int_vec_long'length, ONLY,(v_incr_list(1 to 128)), UNIQUE);
      v_int_vec_long := v_rand.rand(v_int_vec_long'length, 1,129, EXCL,(1), UNIQUE);
      v_int_vec_long := v_rand.rand(v_int_vec_long'length, 1,256, EXCL,(v_incr_list(1 to 128)), UNIQUE);
      v_int_vec_long := v_rand.rand(v_int_vec_long'length, 1,378, EXCL,(v_incr_list(1 to 250)), UNIQUE);

    --===================================================================================
    elsif GC_TESTCASE = "rand_weighted" then
    --===================================================================================
      log(ID_SEQUENCER, "Reducing log messages from rand_pkg");
      disable_log_msg(ID_LOG_MSG_CTRL);

      ------------------------------------------------------------
      -- Weighted integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing weighted integer (single values) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,1),(10,3)));
        count_rand_value(v_value_cnt, v_int);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,1),(10,0)));
        count_rand_value(v_value_cnt, v_int);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_val_weight(((-5,10),(0,30),(10,60)));
        count_rand_value(v_value_cnt, v_int);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted integer (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = COMBINED_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_range_weight(((-5,-3,30),(0,0,20),(9,10,50)));
        count_rand_value(v_value_cnt, v_int);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(-4,10),(-3,10),(0,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = INDIVIDUAL_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_range_weight(((-5,-3,30),(0,0,20),(9,10,50)));
        count_rand_value(v_value_cnt, v_int);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,30),(-4,30),(-3,30),(0,20),(9,50),(10,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted integer (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_int := v_rand.rand_range_weight_mode(((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(9,10,50,COMBINED_WEIGHT)));
        count_rand_value(v_value_cnt, v_int);
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
        count_rand_value(v_value_cnt, v_real);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_val_weight(((-5.0,1),(10.1,0)));
        count_rand_value(v_value_cnt, v_real);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_val_weight(((-5.0,10),(0.0,30),(10.1,60)));
        count_rand_value(v_value_cnt, v_real);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted real (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = COMBINED_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_range_weight(((-5.0,-3.0,30),(0.0,0.0,20),(9.3,10.1,50)));
        count_rand_value(v_value_cnt, v_real);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,-3,30),(0,0,20),(9,10,50)));
      enable_log_msg(ID_RAND_GEN);

      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = INDIVIDUAL_WEIGHT, ERROR, "Checking range_weight_default_mode");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_real := v_rand.rand_range_weight(((-5.0,-3.0,30),(0.0,0.0,20),(9.3,10.1,50)));


      log(ID_LOG_HDR, "Testing weighted real (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_real := v_rand.rand_range_weight_mode(((-5.0,-3.0,30,COMBINED_WEIGHT),(0.0,0.0,20,NA),(9.3,10.1,50,COMBINED_WEIGHT)));
        count_rand_value(v_value_cnt, v_real);
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
        count_rand_value(v_value_cnt, v_time);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_val_weight(((-5 ps,1),(10 ps,0)));
        count_rand_value(v_value_cnt, v_time);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_val_weight(((-5 ps,10),(0 ps,30),(10 ps,60)));
        count_rand_value(v_value_cnt, v_time);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted time (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = COMBINED_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_range_weight(((-5 ps,-3 ps,30),(0 ps,0 ps,20),(9 ps,10 ps,50)));
        count_rand_value(v_value_cnt, v_time);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,-3,30),(0,0,20),(9,10,50)));
      enable_log_msg(ID_RAND_GEN);

      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = INDIVIDUAL_WEIGHT, ERROR, "Checking range_weight_default_mode");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_time := v_rand.rand_range_weight(((-5 ps,-3 ps,30),(0 ps,0 ps,20),(9 ps,10 ps,50)));


      log(ID_LOG_HDR, "Testing weighted time (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_time := v_rand.rand_range_weight_mode(((-5 ps,-3 ps,30,COMBINED_WEIGHT),(0 ps,0 ps,20,NA),(9 ps,10 ps,50,COMBINED_WEIGHT)));
        count_rand_value(v_value_cnt, v_time);
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
        count_rand_value(v_value_cnt, v_uns);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_val_weight(v_uns'length,((5,1),(10,0)));
        count_rand_value(v_value_cnt, v_uns);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_val_weight(v_uns'length,((0,10),(5,30),(10,60)));
        count_rand_value(v_value_cnt, v_uns);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(5,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted unsigned (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = COMBINED_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_range_weight(v_uns'length,((0,2,30),(5,5,20),(9,10,50)));
        count_rand_value(v_value_cnt, v_uns);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(1,10),(2,10),(5,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = INDIVIDUAL_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_range_weight(v_uns'length,((0,2,30),(5,5,20),(9,10,50)));
        count_rand_value(v_value_cnt, v_uns);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,30),(1,30),(2,30),(5,20),(9,50),(10,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted unsigned (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_uns := v_rand.rand_range_weight_mode(v_uns'length,((0,2,30,INDIVIDUAL_WEIGHT),(5,5,20,NA),(9,10,50,COMBINED_WEIGHT)));
        count_rand_value(v_value_cnt, v_uns);
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
        count_rand_value(v_value_cnt, v_sig);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(7,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_val_weight(v_sig'length,((-5,1),(7,0)));
        count_rand_value(v_value_cnt, v_sig);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,1),(7,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_val_weight(v_sig'length,((-5,10),(0,30),(7,60)));
        count_rand_value(v_value_cnt, v_sig);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(0,30),(7,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted signed (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = COMBINED_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_range_weight(v_sig'length,((-5,-3,30),(0,0,20),(6,7,50)));
        count_rand_value(v_value_cnt, v_sig);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,10),(-4,10),(-3,10),(0,20),(6,25),(7,25)));
      enable_log_msg(ID_RAND_GEN);

      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = INDIVIDUAL_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_range_weight(v_sig'length,((-5,-3,30),(0,0,20),(6,7,50)));
        count_rand_value(v_value_cnt, v_sig);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((-5,30),(-4,30),(-3,30),(0,20),(6,50),(7,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted signed (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_sig := v_rand.rand_range_weight_mode(v_sig'length,((-5,-3,30,INDIVIDUAL_WEIGHT),(0,0,20,NA),(6,7,50,COMBINED_WEIGHT)));
        count_rand_value(v_value_cnt, v_sig);
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
        count_rand_value(v_value_cnt, v_slv);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,3)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_val_weight(v_slv'length,((5,1),(10,0)));
        count_rand_value(v_value_cnt, v_slv);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((5,1),(10,0)));
      enable_log_msg(ID_RAND_GEN);

      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_val_weight(v_slv'length,((0,10),(5,30),(10,60)));
        count_rand_value(v_value_cnt, v_slv);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(5,30),(10,60)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted std_logic_vector (ranges w/default mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      v_rand.set_range_weight_default_mode(COMBINED_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = COMBINED_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_range_weight(v_slv'length,((0,2,30),(5,5,20),(9,10,50)));
        count_rand_value(v_value_cnt, v_slv);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,10),(1,10),(2,10),(5,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);

      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      check_value(v_rand.get_range_weight_default_mode(VOID) = INDIVIDUAL_WEIGHT, ERROR, "Checking range_weight_default_mode");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_range_weight(v_slv'length,((0,2,30),(5,5,20),(9,10,50)));
        count_rand_value(v_value_cnt, v_slv);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,30),(1,30),(2,30),(5,20),(9,50),(10,50)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing weighted std_logic_vector (ranges w/explicit mode) - Generate " & to_string(C_NUM_WEIGHT_REPETITIONS) & " random values for each test");
      for i in 1 to C_NUM_WEIGHT_REPETITIONS loop
        v_slv := v_rand.rand_range_weight_mode(v_slv'length,((0,2,30,INDIVIDUAL_WEIGHT),(5,5,20,NA),(9,10,50,COMBINED_WEIGHT)));
        count_rand_value(v_value_cnt, v_slv);
        if i = 1 then
          disable_log_msg(ID_RAND_GEN);
        end if;
      end loop;
      check_weight_distribution(v_value_cnt, ((0,30),(1,30),(2,30),(5,20),(9,25),(10,25)));
      enable_log_msg(ID_RAND_GEN);


      log(ID_LOG_HDR, "Testing invalid parameters");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 3);
      v_rand.set_range_weight_default_mode(NA);                -- TB_ERROR: mode not supported
      v_int := v_rand.rand_val_weight(((1,0),(2,0),(3,0)));    -- TB_ERROR: total weight is zero
      v_int := v_rand.rand_range_weight(((10,5,50),(1,1,50))); -- TB_ERROR: min_value > max_value

    --===================================================================================
    elsif GC_TESTCASE = "rand_cyclic" then
    --===================================================================================
      ------------------------------------------------------------
      -- Random cyclic integer
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, CYCLIC);
        check_rand_value(v_int, (0 => (-2,2)));
        count_rand_value(v_value_cnt, v_int);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing integer (set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(ONLY,(-2,0,1,3), CYCLIC);
        check_rand_value(v_int, ONLY,(-2,0,1,3));
        count_rand_value(v_value_cnt, v_int);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing integer (range + set of values)");
      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-1, 1, ADD,(3), CYCLIC);
        check_rand_value(v_int, (0 => (-1,1)), ADD,(0 => 3));
        count_rand_value(v_value_cnt, v_int);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 4;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-3, 3, EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_int, (0 => (-3,3)), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_int);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing integer (range + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, ADD,(-5), EXCL,(1), CYCLIC);
        check_rand_value(v_int, (0 => (-2,2)), ADD,(0 => -5), EXCL,(0 => 1));
        count_rand_value(v_value_cnt, v_int);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, ADD,(-5,5,6), EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_int, (0 => (-2,2)), ADD,(-5,5,6), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_int);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_int := v_rand.rand(-2, 2, EXCL,(0), ADD,(6,7), CYCLIC);
        check_rand_value(v_int, (0 => (-2,2)), EXCL,(0 => 0), ADD,(6,7));
        count_rand_value(v_value_cnt, v_int);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Random cyclic integer vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing integer_vector (range)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, (0 => (-2,2)));
        count_rand_value(v_value_cnt, v_int_vec);
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_num_values := 5; -- same as v_int_vec'length
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, UNIQUE, CYCLIC);
      check_rand_value(v_int_vec, (0 => (-2,2)));
      count_rand_value(v_value_cnt, v_int_vec);
      check_cyclic_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (set of values)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, ONLY,(-2,-1,0,1,2));
        count_rand_value(v_value_cnt, v_int_vec);
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_num_values := 5; -- same as v_int_vec'length
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), UNIQUE, CYCLIC);
      check_rand_value(v_int_vec, ONLY,(-2,-1,0,1,2));
      count_rand_value(v_value_cnt, v_int_vec);
      check_cyclic_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (range + set of values)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -1, 2, ADD,(-5), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, (0 => (-1,2)), ADD,(0 => -5));
        count_rand_value(v_value_cnt, v_int_vec);
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_num_values := 5; -- same as v_int_vec'length
      v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, ADD,(-5,6), UNIQUE, CYCLIC);
      check_rand_value(v_int_vec, (0 => (-1,1)), ADD,(-5,6));
      count_rand_value(v_value_cnt, v_int_vec);
      check_cyclic_distribution(v_value_cnt, v_num_values);

      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, (0 => (-3,4)), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_int_vec);
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_num_values := 5; -- same as v_int_vec'length
      v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), UNIQUE, CYCLIC);
      check_rand_value(v_int_vec, (0 => (-3,4)), EXCL,(-1,0,1));
      count_rand_value(v_value_cnt, v_int_vec);
      check_cyclic_distribution(v_value_cnt, v_num_values);

      log(ID_LOG_HDR, "Testing integer_vector (range + 2 sets of values)");
      v_num_values := 5; -- same as v_int_vec'length
      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, ADD,(-5), EXCL,(1), NON_UNIQUE, CYCLIC);
        check_rand_value(v_int_vec, (0 => (-2,2)), ADD,(0 => -5), EXCL,(0 => 1));
        count_rand_value(v_value_cnt, v_int_vec);
        check_cyclic_distribution(v_value_cnt, v_num_values);
      end loop;

      increment_expected_alerts(TB_WARNING, 1);
      v_num_values := 5; -- same as v_int_vec'length
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, ADD,(-5,6,8), EXCL,(-1,0,1), UNIQUE, CYCLIC);
      check_rand_value(v_int_vec, (0 => (-2,2)), ADD,(-5,6,8), EXCL,(-1,0,1));
      count_rand_value(v_value_cnt, v_int_vec);
      check_cyclic_distribution(v_value_cnt, v_num_values);

      increment_expected_alerts(TB_WARNING, 1);
      v_num_values := 5; -- same as v_int_vec'length
      v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, EXCL,(-1), ADD,(-5,6,8), UNIQUE, CYCLIC);
      check_rand_value(v_int_vec, (0 => (-1,1)), EXCL,(0 => -1), ADD,(-5,6,8));
      count_rand_value(v_value_cnt, v_int_vec);
      check_cyclic_distribution(v_value_cnt, v_num_values);

      ------------------------------------------------------------
      -- Random cyclic unsigned
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unsigned (length)");
      v_num_values := 2**v_uns'length;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, CYCLIC);
        check_rand_value(v_uns, (0 => (0,2**v_uns'length-1)));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, CYCLIC);
        check_rand_value(v_uns, (0 => (0,4)));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, ONLY,(0,2,4), CYCLIC);
        check_rand_value(v_uns, ONLY,(0,2,4));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2**v_uns'length-3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_uns, (0 => (0,2**v_uns'length-1)), EXCL,(0,1,2));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (range + set of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, ADD,(5), CYCLIC);
        check_rand_value(v_uns, (0 => (0,4)), ADD,(0 => 5));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_uns, (0 => (0,4)), EXCL,(0,1,2));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing unsigned (range + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, ADD,(5), EXCL,(0), CYCLIC);
        check_rand_value(v_uns, (0 => (0,4)), ADD,(0 => 5), EXCL,(0 => 0));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 4, ADD,(5,8,9), EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_uns, (0 => (0,4)), ADD,(5,8,9), EXCL,(0,1,2));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns := v_rand.rand(v_uns'length, 0, 2, EXCL,(0), ADD,(5,8,9), CYCLIC);
        check_rand_value(v_uns, (0 => (0,2)), EXCL,(0 => 0), ADD,(5,8,9));
        count_rand_value(v_value_cnt, v_uns);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Random cyclic unsigned long
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unsigned (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_uns_long := v_rand.rand(v_uns_long'length, ONLY,(0,2,4), CYCLIC);
        check_rand_value(v_uns_long, ONLY,(0,2,4));
        count_rand_value(v_value_cnt, v_uns_long);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_uns_long(30 downto 0) := v_rand.rand(31, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_uns_long(30 downto 0), (0 => (0,integer'right)));
        -- Since the range of values is too big it would take too long to verify the distribution
      end loop;

      increment_expected_alerts(TB_WARNING, 2);
      v_uns_long := v_rand.rand(v_uns_long'length, CYCLIC);
      v_uns_long(31 downto 0) := v_rand.rand(32, EXCL,(0,1,2), CYCLIC);

      ------------------------------------------------------------
      -- Random cyclic signed
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing signed (length)");
      v_num_values := 2**v_sig'length;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, CYCLIC);
        check_rand_value(v_sig, (0 => (-2**(v_sig'length-1),2**(v_sig'length-1)-1)));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing signed (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, CYCLIC);
        check_rand_value(v_sig, (0 => (-2,2)));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing signed (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, ONLY,(-2,0,2), CYCLIC);
        check_rand_value(v_sig, ONLY,(-2,0,2));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2**v_sig'length-3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_sig, (0 => (-2**(v_sig'length-1),2**(v_sig'length-1)-1)), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing signed (range + set of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, ADD,(-8), CYCLIC);
        check_rand_value(v_sig, (0 => (-2,2)), ADD,(0 => -8));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_sig, (0 => (-2,2)), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing signed (range + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, ADD,(-8), EXCL,(1), CYCLIC);
        check_rand_value(v_sig, (0 => (-2,2)), ADD,(0 => -8), EXCL,(0 => 1));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -2, 2, ADD,(-8,6,7), EXCL,(-1,0,1), CYCLIC);
        check_rand_value(v_sig, (0 => (-2,2)), ADD,(-8,6,7), EXCL,(-1,0,1));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig := v_rand.rand(v_sig'length, -1, 1, EXCL,(0), ADD,(-8,6,7), CYCLIC);
        check_rand_value(v_sig, (0 => (-1,1)), EXCL,(0 => 0), ADD,(-8,6,7));
        count_rand_value(v_value_cnt, v_sig);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Random cyclic signed long
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing signed (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_sig_long := v_rand.rand(v_sig_long'length, ONLY,(-2,0,2), CYCLIC);
        check_rand_value(v_sig_long, ONLY,(-2,0,2));
        count_rand_value(v_value_cnt, v_sig_long);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_sig_long(31 downto 0) := v_rand.rand(32, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_sig_long(31 downto 0), (0 => (integer'left,integer'right)));
        -- Since the range of values is too big it would take too long to verify the distribution
      end loop;

      increment_expected_alerts(TB_WARNING, 2);
      v_sig_long := v_rand.rand(v_sig_long'length, CYCLIC);
      v_sig_long(32 downto 0) := v_rand.rand(33, EXCL,(0,1,2), CYCLIC);

      ------------------------------------------------------------
      -- Random cyclic std_logic_vector
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic_vector (length)");
      v_num_values := 2**v_slv'length;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, CYCLIC);
        check_rand_value(v_slv, (0 => (0,2**v_slv'length-1)));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (range)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, CYCLIC);
        check_rand_value(v_slv, (0 => (0,4)));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, ONLY,(0,2,4), CYCLIC);
        check_rand_value(v_slv, ONLY,(0,2,4));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2**v_slv'length-3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_slv, (0 => (0,2**v_slv'length-1)), EXCL,(0,1,2));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (range + set of values)");
      v_num_values := 6;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, ADD,(8), CYCLIC);
        check_rand_value(v_slv, (0 => (0,4)), ADD,(0 => 8));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 2;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_slv, (0 => (0,4)), EXCL,(0,1,2));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      log(ID_LOG_HDR, "Testing std_logic_vector (range + 2 sets of values)");
      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, ADD,(5), EXCL,(0), CYCLIC);
        check_rand_value(v_slv, (0 => (0,4)), ADD,(0 => 5), EXCL,(0 => 0));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 4, ADD,(5,8,9), EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_slv, (0 => (0,4)), ADD,(5,8,9), EXCL,(0,1,2));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      v_num_values := 5;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv := v_rand.rand(v_slv'length, 0, 2, EXCL,(0), ADD,(5,8,9), CYCLIC);
        check_rand_value(v_slv, (0 => (0,2)), EXCL,(0 => 0), ADD,(5,8,9));
        count_rand_value(v_value_cnt, v_slv);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      ------------------------------------------------------------
      -- Random cyclic std_logic_vector long
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing std_logic_vector (set of values)");
      v_num_values := 3;
      for i in 1 to v_num_values*C_NUM_CYCLIC_REPETITIONS loop
        v_slv_long := v_rand.rand(v_slv_long'length, ONLY,(0,2,4), CYCLIC);
        check_rand_value(v_slv_long, ONLY,(0,2,4));
        count_rand_value(v_value_cnt, v_slv_long);
        if i mod v_num_values = 0 then
          check_cyclic_distribution(v_value_cnt, v_num_values);
        end if;
      end loop;

      for i in 1 to C_NUM_CYCLIC_REPETITIONS loop
        v_slv_long(30 downto 0) := v_rand.rand(31, EXCL,(0,1,2), CYCLIC);
        check_rand_value(v_slv_long(30 downto 0), (0 => (0,integer'right)));
        -- Since the range of values is too big it would take too long to verify the distribution
      end loop;

      increment_expected_alerts(TB_WARNING, 2);
      v_slv_long := v_rand.rand(v_slv_long'length, CYCLIC);
      v_slv_long(31 downto 0) := v_rand.rand(32, EXCL,(0,1,2), CYCLIC);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing clear_rand_cyclic");
      ------------------------------------------------------------
      log(ID_SEQUENCER, "Generate some values");
      v_num_values := 7;
      for i in 1 to v_num_values-2 loop
        v_int := v_rand.rand(-3, 3, CYCLIC);
        check_rand_value(v_int, (0 => (-3,3)));
      end loop;

      v_rand.clear_rand_cyclic(VOID);

      log(ID_SEQUENCER, "Generate whole range of values");
      for i in 1 to v_num_values loop
        v_int := v_rand.rand(-3, 3, CYCLIC);
        check_rand_value(v_int, (0 => (-3,3)));
        count_rand_value(v_value_cnt, v_int);
      end loop;
      check_cyclic_distribution(v_value_cnt, v_num_values);

      v_rand.clear_rand_cyclic(VOID);

    --===================================================================================
    elsif GC_TESTCASE = "rand_cyclic_performance" then
    --===================================================================================
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing random cyclic large ranges");
      ------------------------------------------------------------
      for i in 1 to 10 loop
        v_int := v_rand.rand(0, 2**29, CYCLIC);
      end loop;
      for i in 1 to 10 loop
        v_int := v_rand.rand(0, 2**30, CYCLIC);
      end loop;
      for i in 1 to 10 loop
        v_int := v_rand.rand(0, integer'right, CYCLIC);
      end loop;
      for i in 1 to 10 loop
        v_int := v_rand.rand(integer'left, integer'right, CYCLIC);
      end loop;

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing random cyclic list and queue performance");
      ------------------------------------------------------------
      disable_log_msg(ID_RAND_GEN);

      v_num_values := 100;
      log(ID_SEQUENCER, "Testing cyclic list with " & to_string(v_num_values) & " values");
      for i in 1 to v_num_values loop
        v_int := v_rand.rand(1, v_num_values, CYCLIC);
      end loop;

      v_num_values := 1000;
      log(ID_SEQUENCER, "Testing cyclic list with " & to_string(v_num_values) & " values");
      for i in 1 to v_num_values loop
        v_int := v_rand.rand(1, v_num_values, CYCLIC);
      end loop;

      v_num_values := 11000;
      log(ID_SEQUENCER, "Testing cyclic list with " & to_string(v_num_values) & " values");
      for i in 1 to v_num_values loop
        v_int := v_rand.rand(1, 2**30, CYCLIC);
      end loop;
      increment_expected_alerts(TB_WARNING, 1);
      log(ID_SEQUENCER, "Testing cyclic queue with " & to_string(v_num_values) & " values");
      for i in 1 to v_num_values loop
        v_int := v_rand.rand(1, integer'right, CYCLIC);
      end loop;

      v_num_values := 100000;
      log(ID_SEQUENCER, "Testing cyclic list with " & to_string(v_num_values) & " values");
      for i in 1 to v_num_values loop
        v_int := v_rand.rand(1, v_num_values, CYCLIC);
      end loop;

      enable_log_msg(ID_RAND_GEN);
      v_rand.clear_rand_cyclic(VOID);

    --===================================================================================
    elsif GC_TESTCASE = "rand_report" then
    --===================================================================================
      v_rand.report_config(VOID);

      v_rand.set_name("MY_RAND_GEN");
      v_rand.set_scope("MY_SCOPE");
      v_int := v_rand.rand(10,20);
      v_rand.set_rand_dist(GAUSSIAN);
      v_rand.set_range_weight_default_mode(INDIVIDUAL_WEIGHT);
      v_rand.set_rand_dist_mean(1.0);
      v_rand.set_rand_dist_std_deviation(5.0);
      v_rand.report_config(VOID);

    --===================================================================================
    elsif GC_TESTCASE = "rand_gaussian" then
    --===================================================================================
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution config");
      ------------------------------------------------------------
      v_rand.set_rand_dist(GAUSSIAN);
      check_value(v_rand.get_rand_dist(VOID) = GAUSSIAN, ERROR, "Checking distribution");
      v_rand.set_rand_dist_mean(5.0);
      check_value(v_rand.get_rand_dist_mean(VOID), 5.0, ERROR, "Checking mean");
      v_rand.set_rand_dist_std_deviation(1.0);
      check_value(v_rand.get_rand_dist_std_deviation(VOID), 1.0, ERROR, "Checking std_deviation");

      increment_expected_alerts(TB_NOTE, 2);
      v_rand.clear_rand_dist_mean(VOID);
      check_value(v_rand.get_rand_dist_mean(VOID), 0.0, ERROR, "Checking mean config was cleared");
      v_rand.clear_rand_dist_std_deviation(VOID);
      check_value(v_rand.get_rand_dist_std_deviation(VOID), 0.0, ERROR, "Checking std_deviation config was cleared");

      disable_log_msg(ID_POS_ACK);
      disable_log_msg(ID_RAND_GEN);
      v_num_values := 5000;

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution (integer)");
      ------------------------------------------------------------
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, -10, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, 0, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, -10, 0);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution (integer_vector)");
      ------------------------------------------------------------
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, -10, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, 0, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, -10, 0);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "INT_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution (real)");
      ------------------------------------------------------------
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, -10, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, 0, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, -10, 0);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution (real_vector)");
      ------------------------------------------------------------
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, -10, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, 0, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, -10, 0);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "REAL_VEC", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution (unsigned)");
      ------------------------------------------------------------
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, 20);

      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 10, 20);

      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, 10);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS_VEC", v_num_values, 0, 31);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "UNS_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution (signed)");
      ------------------------------------------------------------
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, -10, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, 0, 10);

      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, -10, 0);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG", v_num_values, v_value_cnt'low, v_value_cnt'high, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG_VEC", v_num_values, -32, 31);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG_VEC", v_num_values, -32, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG_VEC", v_num_values, -32, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG_VEC", v_num_values, -32, 31, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG_VEC", v_num_values, -32, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG_VEC", v_num_values, -32, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SIG_VEC", v_num_values, -32, 31, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Gaussian distribution (std_logic_vector)");
      ------------------------------------------------------------
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, 20);

      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 10, 20);

      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, 10);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV", v_num_values, 0, v_value_cnt'high, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV_VEC", v_num_values, 0, 31);

      v_mean          := 0.0;
      v_std_deviation := 0.1;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 0.5;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 5.0;
      v_std_deviation := 1.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 3.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      v_mean          := 0.0;
      v_std_deviation := 6.0;
      generate_gaussian_distribution(v_rand, v_value_cnt, "SLV_VEC", v_num_values, 0, 31, false, v_mean, v_std_deviation);

      wait for 200 ns;
      v_rand.clear_rand_dist_mean(VOID);
      v_rand.clear_rand_dist_std_deviation(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing invalid parameters");
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_rand.set_rand_dist_std_deviation(-1.0);

      -- Gaussian distribution can only be used with range
      -- constraints and cannot be combined with cyclic or unique
      -- parameters. The mean must be inside the range.
      v_rand.set_rand_dist_mean(1.0);

      increment_expected_alerts(TB_WARNING, 5);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_int := v_rand.rand(ONLY,(-2,0,2));
      v_int := v_rand.rand(-1, 1, ADD,(-10));
      v_int := v_rand.rand(-2, 2, EXCL,(-1,0,1));
      v_int := v_rand.rand(-2, 2, ADD,(-10), EXCL,(1));
      v_int := v_rand.rand(-2, 2, CYCLIC);
      v_int := v_rand.rand(1000, 2000);

      increment_expected_alerts(TB_WARNING, 10);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2));
      v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, ADD,(-10));
      v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1));
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, ADD,(-10), EXCL,(1));
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, NON_UNIQUE, CYCLIC);
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, ONLY,(-2,-1,0,1,2), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, -1, 1, ADD,(-10,15), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, -3, 4, EXCL,(-1,0,1), UNIQUE);
      v_int_vec := v_rand.rand(v_int_vec'length, -2, 2, ADD,(-10,15,16), EXCL,(-1,0,1), UNIQUE);
      v_int_vec(0 to 0) := v_rand.rand(1, 1000, 2000);

      increment_expected_alerts(TB_WARNING, 4);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_real := v_rand.rand(ONLY,(-2.0,0.555,2.0));
      v_real := v_rand.rand(-1.0, 1.0, ADD,(15.5));
      v_real := v_rand.rand(-1.0, 1.0, EXCL,(-1.0,0.0,1.0));
      v_real := v_rand.rand(-1.0, 1.0, ADD,(15.5), EXCL,(-1.0));
      v_real := v_rand.rand(1000.0, 2000.0);

      increment_expected_alerts(TB_WARNING, 9);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.25,1.1,2.0));
      v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5));
      v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0,0.0,1.0));
      v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5), EXCL,(-1.0));
      v_real_vec := v_rand.rand(v_real_vec'length, -2.0, 2.0, UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, ONLY,(-2.0,-1.1,0.25,1.1,2.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5,16.6), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, EXCL,(-1.0,0.0,1.0), UNIQUE);
      v_real_vec := v_rand.rand(v_real_vec'length, -1.0, 1.0, ADD,(15.5,16.6), EXCL,(-1.0,0.0,1.0), UNIQUE);
      v_real_vec(0 to 0) := v_rand.rand(1, 1000.0, 2000.0);

      -- Gaussian distribution does not support time
      increment_expected_alerts_and_stop_limit(TB_ERROR, 2);
      v_time     := v_rand.rand(-2 ps, 2 ps);
      v_time_vec := v_rand.rand(v_time_vec'length, -2 ps, 2 ps);

      increment_expected_alerts(TB_WARNING, 9);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_uns_long_min := to_unsigned(1, v_uns_long_min'length);
      v_uns_long_max := to_unsigned(100, v_uns_long_max'length);
      v_uns_long := v_rand.rand(v_uns_long'length);
      v_uns_long := v_rand.rand(v_uns_long'length, v_uns_long_min, v_uns_long_max);
      v_uns_long := v_rand.rand(v_uns_long_min, v_uns_long_max);
      v_uns := v_rand.rand(v_uns'length, ONLY,(0,1,2));
      v_uns := v_rand.rand(v_uns'length, EXCL,(0,1));
      v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(7));
      v_uns := v_rand.rand(v_uns'length, 0, 3, EXCL,(1,2));
      v_uns := v_rand.rand(v_uns'length, 0, 2, ADD,(7), EXCL,(1));
      v_uns := v_rand.rand(v_uns'length, 0, 3, CYCLIC);
      v_uns := v_rand.rand(v_uns'length, 10, 15);

      increment_expected_alerts(TB_WARNING, 9);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_sig_long_min := to_signed(1, v_sig_long_min'length);
      v_sig_long_max := to_signed(100, v_sig_long_max'length);
      v_sig_long := v_rand.rand(v_sig_long'length);
      v_sig_long := v_rand.rand(v_sig_long'length, v_sig_long_min, v_sig_long_max);
      v_sig_long := v_rand.rand(v_sig_long_min, v_sig_long_max);
      v_sig := v_rand.rand(v_sig'length, ONLY,(-2,0,2));
      v_sig := v_rand.rand(v_sig'length, EXCL,(0,1));
      v_sig := v_rand.rand(v_sig'length, -1, 1, ADD,(-8));
      v_sig := v_rand.rand(v_sig'length, -2, 2, EXCL,(-1,0,1));
      v_sig := v_rand.rand(v_sig'length, -2, 2, ADD,(-8), EXCL,(1));
      v_sig := v_rand.rand(v_sig'length, -2, 2, CYCLIC);
      v_sig := v_rand.rand(v_sig'length, 6, 7);

      increment_expected_alerts(TB_WARNING, 9);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_slv_long_min := std_logic_vector(to_unsigned(1, v_slv_long_min'length));
      v_slv_long_max := std_logic_vector(to_unsigned(100, v_slv_long_max'length));
      v_slv_long := v_rand.rand(v_slv_long'length);
      v_slv_long := v_rand.rand(v_slv_long'length, v_slv_long_min, v_slv_long_max);
      v_slv_long := v_rand.rand(v_slv_long_min, v_slv_long_max);
      v_slv := v_rand.rand(v_slv'length, ONLY,(0,1,2));
      v_slv := v_rand.rand(v_slv'length, EXCL,(0,1));
      v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(7));
      v_slv := v_rand.rand(v_slv'length, 0, 3, EXCL,(1,2));
      v_slv := v_rand.rand(v_slv'length, 0, 2, ADD,(7), EXCL,(1));
      v_slv := v_rand.rand(v_slv'length, 0, 3, CYCLIC);
      v_slv := v_rand.rand(v_slv'length, 10, 15);

      increment_expected_alerts(TB_WARNING, 6);
      v_int  := v_rand.rand_val_weight(((0,30),(1,20),(2,50)));
      v_real := v_rand.rand_val_weight(((0.0,30),(1.0,20),(2.0,50)));
      v_time := v_rand.rand_val_weight(((0 ps,30),(1 ps,20),(2 ps,50)));
      v_uns  := v_rand.rand_val_weight(v_uns'length, ((0,30),(1,20),(2,50)));
      v_sig  := v_rand.rand_val_weight(v_sig'length, ((0,30),(1,20),(2,50)));
      v_slv  := v_rand.rand_val_weight(v_slv'length, ((0,30),(1,20),(2,50)));

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
