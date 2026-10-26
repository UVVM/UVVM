--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--HDLRegression:TB
entity questa_extension_tb is
  generic (
    GC_EXTENSIONS_ENABLED : boolean := TRUE
  );
end entity;

architecture sim of questa_extension_tb is

  -- Signals for FC auto-sampling
  signal target_signal  : integer   := 0;
  signal trigger_signal : std_logic := '0';    

begin


  p_main : process

    -- Coverpoints
    variable v_cp_manual   : t_coverpoint;
    variable v_cp_auto_sig : t_coverpoint; -- Samples signal, signal trigger
    variable v_cp_auto_var : t_coverpoint; -- Samples variable, signal trigger

    -- Target for auto-sampling (variable type)
    variable v_sampling_target  : integer := 0;

    -- Randomization variables (t_rand objects)
    variable v_rand_90_100              : t_rand;
    variable v_rand_zero_bitwise_and    : t_rand;
    variable v_rand_nonzero_bitwise_and : t_rand;
    variable v_rand_integer_vector      : t_rand;
    variable v_rand_force_bits_to       : t_rand;
    variable v_rand_one_hot             : t_rand;
    variable v_rand_real                : t_rand;
    variable v_rand_time                : t_rand;
    variable v_rand_v1                  : t_rand;
    variable v_rand_v2                  : t_rand;
    variable v_rand_v3                  : t_rand;

    -- Variables to be randomized
    variable v_integer         : integer;
    variable v_slv             : std_logic_vector(7 downto 0);
    variable v_integer_vector  : integer_vector(0 to 4);
    variable v_real            : real;
    variable v_time            : time;

    -- Variables to be randomized with linking
    variable v_integer_v1      : integer;
    variable v_integer_v2      : integer;
    variable v_integer_v3      : integer;
    variable v_real_v1         : real;
    variable v_real_v2         : real;
    variable v_time_v1         : time;
    variable v_time_v2         : time;

    -- Linking handles
    variable v_link_handle_v2 : integer;
    variable v_link_handle_v3 : integer;    

    -- Variables used in checking of randomized values
    variable v_vector_sum : integer;
    variable v_num_ones   : integer;
    variable v_slv_bitwise_and : std_logic_vector(7 downto 0);

    -- Randomization seeds
    variable v_seeds : t_positive_vector(0 to 1);


    -------------------------------------
    -- Randomization constraint methods
    -------------------------------------
    procedure test_questa_randomization_constraints(void : t_void) is
    begin

      if GC_EXTENSIONS_ENABLED then

        log(ID_LOG_HDR_XL, "Test Questa One Randomization Constraint Methods - ENABLED", C_SCOPE);

        log(ID_LOG_HDR, "Exclude range");
        -- Exclude range
        v_rand_90_100.add_range(0, 100);
        v_rand_90_100.excl_range(0, 10);
        v_rand_90_100.excl_range(11, 89);
        v_integer := v_rand_90_100.randm(VOID);
        log(ID_SEQUENCER, "Rand 90-100: " & to_string(v_integer));
        check_value_in_range(v_integer, 90, 100, ERROR, "Check that integer is in range 90-100 (excl_range() test)");

        log(ID_LOG_HDR, "Exclude range (real)");
        -- Exclude range (real)
        v_rand_real.add_range_real(1.0, 5.5);
        v_rand_real.excl_range_real(1.5, 5.5);
        v_real := v_rand_real.randm(VOID);
        log(ID_SEQUENCER, "Rand real 1.0-1.5: " & to_string(v_real));
        check_value_in_range(v_real, 1.0, 1.5, ERROR, "Check that real is in range 1.0-1.5 (excl_range_real() test)");


        log(ID_LOG_HDR, "Exclude range (time)");
        -- Exclude range (time)
        v_rand_time.add_range_time(5 ns, 100 ns);
        v_rand_time.excl_range_time(50 ns, 100 ns);
        v_time := v_rand_time.randm(VOID);
        log(ID_SEQUENCER, "Rand time 5 ns - 50 ns: " & to_string(v_time));
        check_value_in_range(v_time, 5 ns, 50 ns, ERROR, "Check that time is in range 5 ns to 50 ns (excl_range_time() test)");


        -- Vector sum min/max
        log(ID_LOG_HDR, "Vector sum min/max");
        v_rand_integer_vector.vector_sum_min(5);
        v_rand_integer_vector.vector_sum_max(10);
        -- Run five tests
        for test_iteration in 1 to 5 loop
          v_integer_vector := v_rand_integer_vector.randm(5);
          log(ID_SEQUENCER, "Integer vector sum 5-10: " & to_string(v_integer_vector));
          -- Add all elements in vector and verify that sum is within given range
          v_vector_sum := 0;
          for j in v_integer_vector'range loop
            v_vector_sum := v_vector_sum + v_integer_vector(j);
          end loop;
          check_value_in_range(v_vector_sum, 5, 10, ERROR, "Check that vector sum is in range 5-10");
        end loop;

        -- Nonzero bitwise AND
        -- Bitwise and of randomized slv and input parameter shall be nonzero
        -- Input parameter = 3 (0b00000011) -> Valid output values xxxxxx10/01/11
        log(ID_LOG_HDR, "Nonzero bitwise AND");
        v_rand_nonzero_bitwise_and.nonzero_bitwise_and(3); -- Apply constraint
        v_slv             := v_rand_nonzero_bitwise_and.randm(8); -- Generate randomized value (8-bit)
        v_slv_bitwise_and := v_slv and std_logic_vector(to_unsigned(3, 8)); -- Perform AND-operation with randomized value
        check_value(v_slv_bitwise_and /= "00000000", ERROR, "Check nonzero bitwise AND"); -- Verify that result is non-zero


        -- Zero bitwise AND
        -- Bitwise and of randomized slv and input parameter shall be zero
        -- Input parameter = 3 -> Valid output values xxxxxx10/01/11
        log(ID_LOG_HDR, "Zero bitwise and");
        v_rand_zero_bitwise_and.zero_bitwise_and(3); -- Apply constraint
        v_slv             := v_rand_zero_bitwise_and.randm(8); -- Generate randomized value (8-bit)
        v_slv_bitwise_and := v_slv and std_logic_vector(to_unsigned(3, 8)); -- Perform AND-operation with randomized value
        check_value(v_slv_bitwise_and = "00000000", ERROR, "Check zero bitwise AND"); -- Verify that result is zero
 
        -- Force bits to
        log(ID_LOG_HDR, "Force bits to");
        v_rand_force_bits_to.force_bits_to("1100----");
        v_slv := v_rand_force_bits_to.randm(8);
        check_value(v_slv(7 downto 4), "1100", ERROR, "Check forced bits");

        -- one-hot
        log(ID_LOG_HDR, "One-hot");
        v_rand_one_hot.one_hot(VOID);
        for num_bits in 4 to 8 loop
          v_slv(num_bits-1 downto 0) := v_rand_one_hot.randm(num_bits);
          log(ID_SEQUENCER, "One-hot (" & to_string(num_bits) & "-bit): " & to_string(v_slv(num_bits-1 downto 0)));
          v_num_ones := 0;
            for j in 0 to num_bits-1 loop
              if v_slv(j) = '1' then
                v_num_ones := v_num_ones + 1;
              end if;
            end loop;
            check_value(v_num_ones, 1, ERROR, "Check that SLV is one-hot");
        end loop;

        --=======================
        -- Linking
        --=======================
        log(ID_LOG_HDR, "Linking of randomized variables");
        -- v1 is in range 0-10
        v_rand_v1.add_range(0, 10);
        -- v2 is in range 0-15
        v_rand_v2.add_range(0, 15);
        -- v2 > v1
        v_link_handle_v2 := v_rand_v2.create_rand(VOID);

        -- Less than
        v_rand_v1.link(LT, v_link_handle_v2);      -- Link as less than v2
        v_integer_v1 := v_rand_v1.randm(VOID);     -- Randomizes v_rand_v1 and v_rand_v2
        v_integer_v2 := v_rand_v2.get_value(VOID); -- Extracts link-randomized value from v_rand_v2
        log(ID_SEQUENCER, "v1 < v2: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2));
        check_value(v_integer_v1 < v_integer_v2, ERROR, "Check that int v1 < v2");

        -- Arithmetic and relational link (v1 + v2 < v3)
        v_rand_v1.unlink(VOID);
        v_rand_v3.add_range(0,5);
        v_link_handle_v3 := v_rand_v3.create_rand(VOID);
        v_rand_v1.link(ADD, v_link_handle_v2, LT, v_link_handle_v3, true);
        v_integer_v1 := v_rand_v1.randm(VOID);
        v_integer_v2 := v_rand_v2.get_value(VOID);
        v_integer_v3 := v_rand_v3.get_value(VOID);
        log(ID_SEQUENCER, "v1 + v2 < v3: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2) & " v3=" & to_string(v_integer_v3));
        check_value((v_integer_v1 + v_integer_v2) < v_integer_v3, ERROR, "Check that v1 + v2 < v3");

        v_rand_v1.unlink(VOID);
        v_rand_v1.link(ADD, v_link_handle_v2, EQ, v_link_handle_v3, true);
        v_integer_v1 := v_rand_v1.randm(VOID);
        v_integer_v2 := v_rand_v2.get_value(VOID);
        v_integer_v3 := v_rand_v3.get_value(VOID);
        log(ID_SEQUENCER, "v1 + v2 = v3: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2) & " v3=" & to_string(v_integer_v3));
        check_value((v_integer_v1 + v_integer_v2) = v_integer_v3, ERROR, "Check that v1 + v2 = v3");

        -- Greater than
        v_rand_v1.unlink(v_link_handle_v2);   -- Unlink from v2
        v_rand_v1.link(GT, v_link_handle_v2); -- Constrain v1 to be greater than v2
        v_integer_v1 := v_rand_v1.randm(VOID);
        v_integer_v2 := v_rand_v2.get_value(VOID);
        log(ID_SEQUENCER, "v1 > v2: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2));
        check_value(v_integer_v1 > v_integer_v2, ERROR, "Check that int v1 > v2");

        -- Equal
        v_rand_v1.unlink(v_link_handle_v2); -- Unlink from v2
        v_rand_v1.link(EQ, v_link_handle_v2); -- Relink as equal to v2
        v_integer_v1 := v_rand_v1.randm(VOID);
        v_integer_v2 := v_rand_v2.get_value(VOID);
        log(ID_SEQUENCER, "v1 = v2: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2));
        check_value(v_integer_v2 = v_integer_v1, ERROR, "Check that int v1 = v2");

        -- Less than or equal
        v_rand_v1.unlink(v_link_handle_v2); -- Unlink from v1
        v_rand_v1.link(LE, v_link_handle_v2); -- Relink as less than or equal to v1
        v_integer_v1 := v_rand_v1.randm(VOID);
        v_integer_v2 := v_rand_v2.get_value(VOID);
        log(ID_SEQUENCER, "v1 <= v2: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2));
        check_value(v_integer_v1 <= v_integer_v2, ERROR, "Check that int v2 <= v1"); 

        -- Greater than or equal
        v_rand_v1.unlink(v_link_handle_v2); -- Unlink from v1
        v_rand_v1.link(GE, v_link_handle_v2); -- Relink as less than or equal to v1
        v_integer_v1 := v_rand_v1.randm(VOID);
        v_integer_v2 := v_rand_v2.get_value(VOID);
        log(ID_SEQUENCER, "v1 >= v2: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2));
        check_value(v_integer_v1 >= v_integer_v2, ERROR, "Check that int v1 >= v2");

        -- Not equal
        v_rand_v1.unlink(v_link_handle_v2); -- Unlink from v1
        v_rand_v1.link(NE, v_link_handle_v2); -- Relink as less than or equal to v1
        v_integer_v1 := v_rand_v1.randm(VOID);
        v_integer_v2 := v_rand_v2.get_value(VOID);
        log(ID_SEQUENCER, "v1 != v2: v1=" & to_string(v_integer_v1) & " v2=" & to_string(v_integer_v2));
        check_value(v_integer_v1 /= v_integer_v2, ERROR, "Check that int v1 /= v2");

        -- Test linking of variables with type real
        v_rand_v1.unlink(VOID);
        v_rand_v1.add_range_real(5.0, 10.0);
        v_rand_v2.add_range_real(1.0, 10.0);
        v_link_handle_v2 := v_rand_v2.create_rand(VOID);
        v_rand_v1.link(GT, v_link_handle_v2);
        v_real_v1 := v_rand_v1.randm(VOID);
        v_real_v2 := v_rand_v2.get_value(VOID);
        log(ID_SEQUENCER, "Real: v1 > v2: v1=" & to_string(v_real_v1) & " v2=" & to_string(v_real_v2));
        check_value(v_real_v1 > v_real_v2, ERROR, "Check that real v1 > v2");

        -- Test linking of variables with type time
        v_rand_v1.unlink(VOID);
        v_rand_v1.add_range_time(90 ns, 100 ns);
        v_rand_v2.add_range_time(80 ns, 100 ns);
        v_link_handle_v2 := v_rand_v2.create_rand(VOID);
        v_rand_v1.link(LT, v_link_handle_v2);
        v_time_v1 := v_rand_v1.randm(VOID);
        v_time_v2 := v_rand_v2.get_value(VOID);
        log(ID_SEQUENCER, "Time: v1 < v2: v1=" & to_string(v_time_v1) & " v2=" & to_string(v_time_v2));
        check_value(v_time_v1 < v_time_v2, ERROR, "Check that time v1 < v2");

        v_rand_v1.set_rand_seeds(2,10);
        v_rand_v1.get_rand_seeds(v_seeds(0), v_seeds(1));
        log(ID_SEQUENCER, "Seeds v_rand_v1: " & to_string(v_seeds(0)) & to_string(v_seeds(1)));

      else  -- Questa extensions not enabled. Verify TB_ERROR in case extended methods are called

        log(ID_LOG_HDR_XL, "Test Questa One Randomization Constraint Methods - DISABLED (expect TB_ERROR)", C_SCOPE);

        -- excl_range()
        v_rand_90_100.add_range(0, 100);
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_rand_90_100.excl_range(0, 10);

        --vector_sum_min()
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_rand_integer_vector.vector_sum_min(5);

        -- vector_sum_max()
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_rand_integer_vector.vector_sum_max(10);

        -- nonzero_bitwise_and()
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_rand_nonzero_bitwise_and.nonzero_bitwise_and(3);

        -- zero_bitwise_and()
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_rand_zero_bitwise_and.zero_bitwise_and(3);

        -- force_bits_to()
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_rand_force_bits_to.force_bits_to("1100----");

        -- one_hot()
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_rand_one_hot.one_hot(VOID);

      end if;

    end procedure;


    procedure test_questa_functional_coverage_extensions(void : t_void) is
    begin

        log(ID_LOG_HDR_XL, "Test functional coverage auto-sampling");

        set_alert_stop_limit(ERROR, 5);

        v_cp_manual.set_name("Manual CP");
        v_cp_auto_sig.set_name("Auto CP, sig sample, sig trigger");
        v_cp_auto_var.set_name("Auto CP, var sample, sig trigger");

        v_cp_manual.add_bins(bin_range(0,5), 4, "low_bin");
        v_cp_manual.add_bins(bin_range(1,4,2), 1);
        v_cp_manual.add_bins(bin(6), 10);
        v_cp_manual.add_bins(bin(8), 10);
        v_cp_manual.add_bins(bin(10), "max bin");


        v_cp_auto_sig.add_bins(bin_range(0,5), 4, "low_bin");
        v_cp_auto_sig.add_bins(bin_range(1,4,2), 1);
        v_cp_auto_sig.add_bins(bin(6), 10);
        v_cp_auto_sig.add_bins(bin(8), 10);
        v_cp_auto_sig.add_bins(bin(10), "max bin");

        v_cp_auto_var.add_bins(bin_range(0,5), 4, "low_bin");
        v_cp_auto_var.add_bins(bin_range(1,4,2), 1);
        v_cp_auto_var.add_bins(bin(6), 10);
        v_cp_auto_var.add_bins(bin(8), 10);
        v_cp_auto_var.add_bins(bin(10), "max bin");

      if GC_EXTENSIONS_ENABLED then

        v_cp_auto_sig.enable_auto_sampling("/questa_extension_tb/target_signal"  , "/questa_extension_tb/trigger_signal");
        v_cp_auto_var.enable_auto_sampling("/questa_extension_tb/p_main/v_sampling_target", "/questa_extension_tb/trigger_signal");

        log(ID_LOG_HDR, "Sample data so we get some (but not full) coverage");

        for i in 0 to 10 loop
          for j in 1 to i loop -- Sample each value i times (to differentiate bin coverage)
            target_signal <= i;
            v_sampling_target := i;
            wait for 0 ns;

            trigger_signal <= not trigger_signal;
            wait for 0 ns;

            v_cp_manual.sample_coverage(i);
          end loop;
        end loop;

        v_cp_manual.report_coverage(VERBOSE);
        v_cp_auto_sig.report_coverage(VERBOSE);
        v_cp_auto_var.report_coverage(VERBOSE);

        log(ID_LOG_HDR, "Add more samples to complete coverage for all bins");

        for i in 0 to 10 loop
          for j in 1 to 10 loop
            target_signal <= i;
            v_sampling_target := i;
            wait for 0 ns;

            trigger_signal <= not trigger_signal;
            wait for 0 ns;

            v_cp_manual.sample_coverage(i);
          end loop;
        end loop;

        -- Check that coverage_completed() method works for all coverpoints
        check_value(v_cp_manual.coverage_completed(BINS_AND_HITS) = TRUE, ERROR, "Check manual CP coverage completed");
        check_value(v_cp_auto_sig.coverage_completed(BINS_AND_HITS) = TRUE, ERROR, "Check auto CP sample sig, sig trigger coverage completed");
        check_value(v_cp_auto_var.coverage_completed(BINS_AND_HITS) = TRUE, ERROR, "Check auto CP sample var, sig trigger coverage completed");      

        v_cp_manual.report_coverage(VERBOSE);
        v_cp_auto_sig.report_coverage(VERBOSE);
        v_cp_auto_var.report_coverage(VERBOSE);

        -- TODO: Needs fix for default values of seeds in questaRandPkg. Uncomment when fixed by Siemens. 
        -- v_cp_manual.write_coverage_db("cp_manual_db.txt");
        -- log(ID_LOG_HDR, "Manual db written");
        -- v_cp_auto_sig.write_coverage_db("cp_auto_sig_db.txt");
        -- log(ID_LOG_HDR, "Auto sig db written");
        -- v_cp_auto_var.write_coverage_db("cp_auto_var_db.txt");

      else -- Extensions disabled. Verify that TB_ERROR is given

        increment_expected_alerts_and_stop_limit(TB_ERROR);
        increment_expected_alerts_and_stop_limit(TB_ERROR);
        v_cp_auto_sig.enable_auto_sampling("/questa_extension_tb/target_signal"  , "/questa_extension_tb/trigger_signal");
        v_cp_auto_var.enable_auto_sampling("/questa_extension_tb/p_main/v_sampling_target", "/questa_extension_tb/trigger_signal");

      end if;

    end procedure;

  begin

    test_questa_randomization_constraints(VOID);

    test_questa_functional_coverage_extensions(VOID);


    wait for 10 us;
    log(ID_LOG_HDR, "SIMULATION COMPLETED");
    -- Finish the simulation
    std.env.stop;
    wait;   -- to stop completely
    

  end process p_main;
  

end architecture;