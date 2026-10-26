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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------
library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.slv8_sb_pkg.all;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

architecture check_arch of methods_tb is
  signal bool   : boolean                        := false;
  signal slv8   : std_logic_vector(7 downto 0)   := (others => '0');
  signal slv128 : std_logic_vector(127 downto 0) := (others => '1');
  signal uns8   : unsigned(7 downto 0)           := (others => '0');
  signal sig8   : signed(7 downto 0)             := (others => '0');
  signal int    : integer                        := 0;
  signal real_a : real                           := 0.0;
  signal sl     : std_logic                      := '0';

  -- Used in the check_sb_completion testcase
  shared variable v_sb   : t_generic_sb;
  shared variable v_sb_2 : t_generic_sb;
  -- 1. Default config (error on mismatch)
  constant C_SB_CONFIG_1 : t_sb_config := C_SB_CONFIG_DEFAULT;
  -- 2. Warning on mismatch
  constant C_SB_CONFIG_2 : t_sb_config := (
    mismatch_alert_level      => WARNING,
    allow_lossy               => false,
    allow_out_of_order        => false,
    overdue_check_alert_level => ERROR,
    overdue_check_time_limit  => 0 ns,
    ignore_initial_garbage    => false
  );

begin

  p_main : process
    variable v_slv5_a               : std_logic_vector(4 downto 0);
    variable v_slv5_b               : std_logic_vector(4 downto 0);
    variable v_slv8                 : std_logic_vector(7 downto 0);
    variable v_slv8_2               : std_logic_vector(7 downto 0);
    variable v_uns5_a               : unsigned(4 downto 0);
    variable v_uns5_b               : unsigned(4 downto 0);
    variable v_uns6                 : unsigned(5 downto 0);
    variable v_uns32                : unsigned(31 downto 0);
    variable v_sig8_a               : signed(7 downto 0);
    variable v_sig8_b               : signed(7 downto 0);
    variable v_sig32                : signed(31 downto 0);
    variable v_real                 : real;
    variable v_int_a                : integer;
    variable v_int_b                : integer;
    variable v_time                 : time;
    variable v_bool                 : boolean;
    variable v_exp_slv_array        : t_slv_array(0 to 1)(0 to 3);
    variable v_exp_slv_array_4      : t_slv_array(0 to 3)(0 to 3);
    variable v_exp_slv_array_revers : t_slv_array(1 downto 0)(0 to 3);
    variable v_value_slv_array      : t_slv_array(2 to 3)(0 to 3);
    variable v_exp_signed_array     : t_signed_array(0 to 1)(0 to 3);
    variable v_value_signed_array   : t_signed_array(2 to 3)(0 to 3);
    variable v_exp_unsigned_array   : t_unsigned_array(0 to 1)(0 to 3);
    variable v_value_unsigned_array : t_unsigned_array(2 to 3)(0 to 3);

    alias found_unexpected_simulation_warnings_or_worse is shared_uvvm_status.found_unexpected_simulation_warnings_or_worse;
    alias found_unexpected_simulation_errors_or_worse is shared_uvvm_status.found_unexpected_simulation_errors_or_worse;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "check_value" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_value", C_SCOPE);
      -- Boolean
      v_bool  := check_value(14 > 6, error, "A must be higher than B, OK", C_SCOPE);
      check_value(v_bool, error, "check_value with return value shall return true when OK", C_SCOPE);
      -- SLV
      v_slv5_a := "01111";
      v_slv5_b := "01111";
      check_value(v_slv5_a, v_slv5_b, error, "My msg1, OK", C_SCOPE);
      v_slv5_b := "01110";
      increment_expected_alerts_and_stop_limit(error, 8);
      check_value(v_slv5_a, v_slv5_b, error, "My msg2, Fail", C_SCOPE);
      check_value(std_logic_vector'("100101"), "10010-", error, "My msg3a, OK", C_SCOPE);
      check_value(std_logic_vector'("100101"), "100101", error, "My msg3b, OK", C_SCOPE);
      v_bool  := check_value(std_logic_vector'("100101"), "100100", error, "My msg3c, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", error, "My msg (none), OK", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", error, "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "10010", error, "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "111010", error, "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("110010"), "111010", error, "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("110010"), "111010", error, "My msg BIN, Fail", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "10010", error, "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "110010", error, "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "0010010", error, "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0010010"), "010010", error, "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("0000010010"), "000010-10", error, "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg BIN, KEEP_LEADING_0, OK", C_SCOPE, BIN, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "000010-10", error, "My msg HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "00--10-10", error, "My msg dontcare-in-extended-width HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_STD, error, "My msg dontcare-in-extended-width HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_EXACT, error, "My msg dontcare-in-extended-width HEX, KEEP_LEADING_0, Fail", C_SCOPE, HEX, KEEP_LEADING_0);
      -- MATCH_STD_INCL_Z
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("01Z0"), "----", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z with don't care", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("01Z0"), "01--", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z with don't care", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("01Z0"), "01-1", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z with don't care, Fail", C_SCOPE, HEX, KEEP_LEADING_0);
      -- MATCH_STD_INCL_ZXUW
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("000X0X00X0"), "000X0X00X0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("000U0U00U0"), "000U0U00U0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("000W0W00W0"), "000W0W00W0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0Z0X0U00W0"), "0Z0X0U00W0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "0000010010", error, "My msg HEX_BIN_IF_INVALID, OK", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("0000011111"), "0000010010", error, "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("00000U00U0"), "0000010010", error, "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      -- wide vector
      check_value(slv128, slv128, error, "Test wide vector, HEX, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(slv128, slv128, error, "Test wide vector, DEC, OK", C_SCOPE, DEC, KEEP_LEADING_0);
      -- Boolean
      -- As function
      increment_expected_alerts_and_stop_limit(error, 2);
      v_bool := check_value(true, true, error, "Boolean check true vs true, OK");
      check_value(v_bool, error, "check_value should return true");
      v_bool := check_value(true, false, error, "Boolean check true vs false, Fail");
      check_value(not v_bool, error, "check_value should return false");
      v_bool := check_value(false, true, error, "Boolean check false vs true, Fail");
      check_value(not v_bool, error, "check_value should return false");
      v_bool := check_value(false, false, error, "Boolean check false vs false, OK");
      check_value(v_bool, error, "check_value should return true");
      -- As procedure
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value(true, true, error, "Boolean check true vs true, OK");
      check_value(true, false, error, "Boolean check true vs false, Fail");
      check_value(false, true, error, "Boolean check false vs true, Fail");
      check_value(false, false, error, "Boolean check false vs false, OK");
      -- Unsigned
      v_uns5_a := "01100";
      v_uns5_b := "11100";
      v_uns6   := "101100";
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value(v_uns5_a, v_uns5_a, error, "My msg U, BIN, KEEP_LEADING_0, OK", C_SCOPE, BIN);
      check_value(v_uns5_a, v_uns5_b, error, "My msg U, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      v_bool := check_value(v_uns5_a, v_uns6, error, "My msg U, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Signed
      v_sig8_a := "10101100";
      v_sig8_b := "10101101";
      v_sig32  := x"80000001"; -- -2^31 (-2147483647)
      increment_expected_alerts_and_stop_limit(error, 6);
      check_value(v_sig8_a, v_sig8_a, error, "My msg S, BIN, KEEP_LEADING_0, OK", C_SCOPE, BIN);
      check_value(v_sig8_a, v_sig8_a, error, "My msg S, HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX);
      check_value(v_sig8_a, v_sig8_a, error, "My msg S, DEC, KEEP_LEADING_0, OK", C_SCOPE, DEC);
      check_value(v_sig8_a, v_sig8_b, error, "My msg S, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      check_value(v_sig8_a, v_sig8_b, error, "My msg S, HEX, KEEP_LEADING_0, Fail", C_SCOPE, HEX);
      check_value(v_sig8_a, v_sig8_b, error, "My msg S, DEC, KEEP_LEADING_0, Fail", C_SCOPE, DEC);
      check_value(v_sig8_a, v_sig32, error, "My msg S, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      check_value(v_sig8_a, v_sig32, error, "My msg S, HEX, KEEP_LEADING_0, Fail", C_SCOPE, HEX);
      v_bool := check_value(v_sig8_a, v_sig32, error, "My msg S, DEC, KEEP_LEADING_0, Fail", C_SCOPE, DEC);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Integer
      v_int_a := 5;
      v_int_b := 23456;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value(v_int_a, 5, error, "My msg I, OK", C_SCOPE);
      check_value(v_int_a, 12345, error, "My msg I, Fail", C_SCOPE);
      v_bool := check_value(v_int_a, v_int_b, warning, "My msg I, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Real
      v_real := 5222.01;
      check_value(v_real, 5222.01, error, "My msg I, OK", C_SCOPE);
      v_bool := check_value(v_real, 1421.02, warning, "My msg I, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Std_logic
      v_bool := check_value('1', '1', warning, "My msg SL, OK", C_SCOPE);
      check_value(v_bool, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value('1', '0', warning, "My msg SL, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value('0', '-', warning, "My msg SL, OK, use default match_strictness", C_SCOPE);
      check_value('1', '-', MATCH_STD, warning, "My msg SL, OK", C_SCOPE);
      check_value('L', '0', MATCH_STD, warning, "My msg SL, OK", C_SCOPE);
      check_value('1', 'H', MATCH_EXACT, warning, "My msg SL, Fail", C_SCOPE);
      check_value('-', '1', MATCH_EXACT, warning, "My msg SL, Fail", C_SCOPE);
      -- MATCH_STD_INCL_Z
      check_value('Z', 'Z', MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z", C_SCOPE);
      -- MATCH_STD_INCL_ZXUW
      check_value('Z', 'Z', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('X', 'X', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('U', 'U', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('W', 'W', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      -- Time
      v_time := 15 ns;
      v_bool := check_value(15 ns, 74 ps, warning, "My msg I, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(15 ns, 14 ns, warning, "My msg I, Fail", C_SCOPE);
      check_value(v_time, 15 ns, warning, "My msg I, OK", C_SCOPE);
      check_value(v_time, 15.0 ns, warning, "My msg I, OK", C_SCOPE);
      check_value(v_time, 15000 ps, warning, "My msg I, OK", C_SCOPE);
      check_value(v_time, 74 ps, warning, "My msg I, Fail", C_SCOPE);
      increment_expected_alerts(warning, 8);

      -- Check UVVM successful status
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, "Check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse correctly updated");
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, "Check shared_uvvm_status.found_unexpected_simulation_errors_or_worse correctly updated");
      -- Check value reporting with padding of short SLV
      increment_expected_alerts(tb_warning, 3);
      check_value(std_logic_vector'("00110010"), std_logic_vector'("0010"), tb_warning, "Check padding of different check_value SLV lengths (actual>expected)");
      check_value(std_logic_vector'("1010"), std_logic_vector'("00110010"), tb_warning, "Check padding of different check_value SLV lengths (actual<expected)");
      check_value(std_logic_vector'("00001010"), std_logic_vector'("00110010"), tb_warning, "Check padding of different check_value SLV lengths (actual=expected)");

      ----------------------------------------------------------------------------
      -- Check value with unequal array indexes for t_slv/signed/unsigned_array
      ----------------------------------------------------------------------------
      -- Verify check_value array index conversion
      v_exp_slv_array(0)   := x"A";
      v_exp_slv_array(1)   := x"B";
      v_value_slv_array(2) := x"A";
      v_value_slv_array(3) := x"B";
      check_value(v_value_slv_array, v_exp_slv_array, tb_warning, "check_value with t_slv_array of different array indexes");
      v_exp_signed_array(0)   := x"C";
      v_exp_signed_array(1)   := x"D";
      v_value_signed_array(2) := x"C";
      v_value_signed_array(3) := x"D";
      check_value(v_value_signed_array, v_exp_signed_array, tb_warning, "check_value with t_signed_array of different array indexes");
      v_exp_unsigned_array(0)   := x"E";
      v_exp_unsigned_array(1)   := x"F";
      v_value_unsigned_array(2) := x"E";
      v_value_unsigned_array(3) := x"F";
      check_value(v_value_unsigned_array, v_exp_unsigned_array, tb_warning, "check_value with t_unsigned_array of different array indexes");

      -- Verify check_value with array conversion catch errors
      increment_expected_alerts(tb_warning, 3);
      v_exp_slv_array(1)      := x"C";
      v_exp_signed_array(1)   := x"A";
      v_exp_unsigned_array(1) := x"D";
      check_value(v_value_slv_array, v_exp_slv_array, tb_warning, "check_value with t_slv_array of different array indexes");
      check_value(v_value_signed_array, v_exp_signed_array, tb_warning, "check_value with t_signed_array of different array indexes");
      check_value(v_value_unsigned_array, v_exp_unsigned_array, tb_warning, "check_value with t_unsigned_array of different array indexes");

      log(ID_SEQUENCER, "Incrementing alert_stop_limit(TB_ERROR) for 1 provoked tb_error to pass in simulation.", C_SCOPE);
      set_alert_stop_limit(TB_ERROR, 2);

      -- Verify warning with arrays of different directions and unequal lengths
      v_exp_slv_array        := (others => "1010");
      v_exp_slv_array_4      := (others => "1010");
      v_exp_slv_array_revers := (others => "1010");
      increment_expected_alerts_and_stop_limit(tb_error, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_4, tb_warning, "check_value with different array lenghts");
      increment_expected_alerts(tb_warning, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_revers, tb_warning, "check_value with different array directions");

      report_check_counters(VOID);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "check_value_default_alert" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_value with default alert level", C_SCOPE);
      -- Boolean
      v_bool  := check_value(14 > 6, "A must be higher than B, OK", C_SCOPE);
      check_value(v_bool, "check_value with return value shall return true when OK", C_SCOPE);
      -- SLV
      v_slv5_a := "01111";
      v_slv5_b := "01111";
      check_value(v_slv5_a, v_slv5_b, "My msg1, OK", C_SCOPE);
      v_slv5_b := "01110";
      increment_expected_alerts_and_stop_limit(error, 8);
      check_value(v_slv5_a, v_slv5_b, "My msg2, Fail", C_SCOPE);
      check_value(std_logic_vector'("100101"), "10010-", "My msg3a, OK", C_SCOPE);
      check_value(std_logic_vector'("100101"), "100101", "My msg3b, OK", C_SCOPE);
      v_bool  := check_value(std_logic_vector'("100101"), "100100", "My msg3c, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", "My msg (none), OK", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "10010", "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "111010", "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("110010"), "111010", "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("110010"), "111010", "My msg BIN, Fail", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "10010", "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "110010", "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "0010010", "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0010010"), "010010", "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0000010010"), "000010010", "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0000010010"), "000010010", "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("0000010010"), "000010-10", "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("0000010010"), "000010010", "My msg BIN, KEEP_LEADING_0, OK", C_SCOPE, BIN, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "000010010", "My msg HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "000010-10", "My msg HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "00--10-10", "My msg dontcare-in-extended-width HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_STD, "My msg dontcare-in-extended-width HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_EXACT, "My msg dontcare-in-extended-width HEX, KEEP_LEADING_0, Fail", C_SCOPE, HEX, KEEP_LEADING_0);
      -- MATCH_STD_INCL_Z
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_Z, "Check MATCH_STD_INCL_Z", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("01Z0"), "----", MATCH_STD_INCL_Z, "Check MATCH_STD_INCL_Z with don't care", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("01Z0"), "01--", MATCH_STD_INCL_Z, "Check MATCH_STD_INCL_Z with don't care", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("01Z0"), "01-1", MATCH_STD_INCL_Z, "Check MATCH_STD_INCL_Z with don't care, Fail", C_SCOPE, HEX, KEEP_LEADING_0);
      -- MATCH_STD_INCL_ZXUW
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("000X0X00X0"), "000X0X00X0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("000U0U00U0"), "000U0U00U0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("000W0W00W0"), "000W0W00W0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0Z0X0U00W0"), "0Z0X0U00W0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(std_logic_vector'("0000010010"), "0000010010", "My msg HEX_BIN_IF_INVALID, OK", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("0000011111"), "0000010010", "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("00000U00U0"), "0000010010", "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      -- wide vector
      check_value(slv128, slv128, "Test wide vector, HEX, OK", C_SCOPE, HEX, KEEP_LEADING_0);
      check_value(slv128, slv128, "Test wide vector, DEC, OK", C_SCOPE, DEC, KEEP_LEADING_0);
      -- Boolean
      -- As function
      increment_expected_alerts_and_stop_limit(error, 2);
      v_bool := check_value(true, true, "Boolean check true vs true, OK");
      check_value(v_bool, "check_value should return true");
      v_bool := check_value(true, false, "Boolean check true vs false, Fail");
      check_value(not v_bool, "check_value should return false");
      v_bool := check_value(false, true, "Boolean check false vs true, Fail");
      check_value(not v_bool, "check_value should return false");
      v_bool := check_value(false, false, "Boolean check false vs false, OK");
      check_value(v_bool, "check_value should return true");
      -- As procedure
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value(true, true, "Boolean check true vs true, OK");
      check_value(true, false, "Boolean check true vs false, Fail");
      check_value(false, true, "Boolean check false vs true, Fail");
      check_value(false, false, "Boolean check false vs false, OK");
      -- Unsigned
      v_uns5_a := "01100";
      v_uns5_b := "11100";
      v_uns6   := "101100";
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value(v_uns5_a, v_uns5_a, "My msg U, BIN, KEEP_LEADING_0, OK", C_SCOPE, BIN);
      check_value(v_uns5_a, v_uns5_b, "My msg U, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      v_bool := check_value(v_uns5_a, v_uns6, "My msg U, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Signed
      v_sig8_a := "10101100";
      v_sig8_b := "10101101";
      v_sig32  := x"80000001"; -- -2^31 (-2147483647)
      increment_expected_alerts_and_stop_limit(error, 6);
      check_value(v_sig8_a, v_sig8_a, "My msg S, BIN, KEEP_LEADING_0, OK", C_SCOPE, BIN);
      check_value(v_sig8_a, v_sig8_a, "My msg S, HEX, KEEP_LEADING_0, OK", C_SCOPE, HEX);
      check_value(v_sig8_a, v_sig8_a, "My msg S, DEC, KEEP_LEADING_0, OK", C_SCOPE, DEC);
      check_value(v_sig8_a, v_sig8_b, "My msg S, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      check_value(v_sig8_a, v_sig8_b, "My msg S, HEX, KEEP_LEADING_0, Fail", C_SCOPE, HEX);
      check_value(v_sig8_a, v_sig8_b, "My msg S, DEC, KEEP_LEADING_0, Fail", C_SCOPE, DEC);
      check_value(v_sig8_a, v_sig32, "My msg S, BIN, KEEP_LEADING_0, Fail", C_SCOPE, BIN);
      check_value(v_sig8_a, v_sig32, "My msg S, HEX, KEEP_LEADING_0, Fail", C_SCOPE, HEX);
      v_bool := check_value(v_sig8_a, v_sig32, "My msg S, DEC, KEEP_LEADING_0, Fail", C_SCOPE, DEC);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Integer
      v_int_a := 5;
      v_int_b := 23456;
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value(v_int_a, 5, "My msg I, OK", C_SCOPE);
      check_value(v_int_a, 12345, "My msg I, Fail", C_SCOPE);
      v_bool := check_value(v_int_a, v_int_b, "My msg I, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Real
      v_real := 5222.01;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value(v_real, 5222.01, "My msg I, OK", C_SCOPE);
      v_bool := check_value(v_real, 1421.02, "My msg I, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);
      -- Std_logic
      increment_expected_alerts_and_stop_limit(error, 3);
      v_bool := check_value('1', '1', "My msg SL, OK", C_SCOPE);
      check_value(v_bool, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value('1', '0', "My msg SL, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value('0', '-', "My msg SL, OK, use default match_strictness", C_SCOPE);
      check_value('1', '-', MATCH_STD, "My msg SL, OK", C_SCOPE);
      check_value('L', '0', MATCH_STD, "My msg SL, OK", C_SCOPE);
      check_value('1', 'H', MATCH_EXACT, "My msg SL, Fail", C_SCOPE);
      check_value('-', '1', MATCH_EXACT, "My msg SL, Fail", C_SCOPE);
      -- MATCH_STD_INCL_Z
      check_value('Z', 'Z', MATCH_STD_INCL_Z, "Check MATCH_STD_INCL_Z", C_SCOPE);
      -- MATCH_STD_INCL_ZXUW
      check_value('Z', 'Z', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('X', 'X', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('U', 'U', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('W', 'W', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      -- Time
      v_time := 15 ns;
      increment_expected_alerts_and_stop_limit(error, 3);
      v_bool := check_value(15 ns, 74 ps, "My msg I, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(15 ns, 14 ns, "My msg I, Fail", C_SCOPE);
      check_value(v_time, 15 ns, "My msg I, OK", C_SCOPE);
      check_value(v_time, 15.0 ns, "My msg I, OK", C_SCOPE);
      check_value(v_time, 15000 ps, "My msg I, OK", C_SCOPE);
      check_value(v_time, 74 ps, "My msg I, Fail", C_SCOPE);

      -- Check UVVM successful status
      check_value(found_unexpected_simulation_warnings_or_worse, 0, "Check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse correctly updated");
      check_value(found_unexpected_simulation_errors_or_worse, 0, "Check shared_uvvm_status.found_unexpected_simulation_errors_or_worse correctly updated");
      -- Check value reporting with padding of short SLV
      increment_expected_alerts_and_stop_limit(error, 3);
      check_value(std_logic_vector'("00110010"), std_logic_vector'("0010"), "Check padding of different check_value SLV lengths (actual>expected)");
      check_value(std_logic_vector'("1010"), std_logic_vector'("00110010"), "Check padding of different check_value SLV lengths (actual<expected)");
      check_value(std_logic_vector'("00001010"), std_logic_vector'("00110010"), "Check padding of different check_value SLV lengths (actual=expected)");

      ----------------------------------------------------------------------------
      -- Check value with unequal array indexes for t_slv/signed/unsigned_array
      ----------------------------------------------------------------------------
      -- Verify check_value array index conversion
      v_exp_slv_array(0)   := x"A";
      v_exp_slv_array(1)   := x"B";
      v_value_slv_array(2) := x"A";
      v_value_slv_array(3) := x"B";
      check_value(v_value_slv_array, v_exp_slv_array, "check_value with t_slv_array of different array indexes");
      v_exp_signed_array(0)   := x"C";
      v_exp_signed_array(1)   := x"D";
      v_value_signed_array(2) := x"C";
      v_value_signed_array(3) := x"D";
      check_value(v_value_signed_array, v_exp_signed_array, "check_value with t_signed_array of different array indexes");
      v_exp_unsigned_array(0)   := x"E";
      v_exp_unsigned_array(1)   := x"F";
      v_value_unsigned_array(2) := x"E";
      v_value_unsigned_array(3) := x"F";
      check_value(v_value_unsigned_array, v_exp_unsigned_array, "check_value with t_unsigned_array of different array indexes");

      -- Verify check_value with array conversion catch errors
      increment_expected_alerts_and_stop_limit(error, 3);
      v_exp_slv_array(1)      := x"C";
      v_exp_signed_array(1)   := x"A";
      v_exp_unsigned_array(1) := x"D";
      check_value(v_value_slv_array, v_exp_slv_array, "check_value with t_slv_array of different array indexes");
      check_value(v_value_signed_array, v_exp_signed_array, "check_value with t_signed_array of different array indexes");
      check_value(v_value_unsigned_array, v_exp_unsigned_array, "check_value with t_unsigned_array of different array indexes");

      log(ID_SEQUENCER, "Incrementing alert_stop_limit(TB_ERROR) for 1 provoked tb_error to pass in simulation.", C_SCOPE);
      set_alert_stop_limit(TB_ERROR, 2);

      -- Verify warning with arrays of different directions and unequal lengths
      v_exp_slv_array        := (others => "1010");
      v_exp_slv_array_4      := (others => "1010");
      v_exp_slv_array_revers := (others => "1010");
      increment_expected_alerts_and_stop_limit(tb_error, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_4, "check_value with different array lenghts");
      increment_expected_alerts(tb_warning, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_revers, "check_value with different array directions");

      report_check_counters(VOID);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "check_stable" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_stable", C_SCOPE);
      bool   <= true;
      slv8   <= (others => '1');
      uns8   <= (others => '1');
      sig8   <= (others => '1');
      int    <= 14;
      real_a <= 1337.14;
      sl     <= '1';
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 7);
      check_stable(bool, 9 ns, error, "Stable boolean OK", C_SCOPE);
      check_stable(slv8, 9 ns, error, "Stable slv OK", C_SCOPE);
      check_stable(uns8, 9 ns, error, "Stable unsigned OK", C_SCOPE);
      check_stable(sig8, 9 ns, error, "Stable signed OK", C_SCOPE);
      check_stable(int, 9 ns, error, "Stable integer OK", C_SCOPE);
      check_stable(real_a, 9 ns, error, "Stable real OK", C_SCOPE);
      check_stable(sl, 9 ns, error, "Stable std_logic OK", C_SCOPE);
      check_stable(bool, 11 ns, error, "Stable boolean Fail", C_SCOPE);
      check_stable(slv8, 11 ns, error, "Stable slv Fail", C_SCOPE);
      check_stable(uns8, 11 ns, error, "Stable unsigned Fail", C_SCOPE);
      check_stable(sig8, 11 ns, error, "Stable signed Fail", C_SCOPE);
      check_stable(int, 11 ns, error, "Stable integer Fail", C_SCOPE);
      check_stable(real_a, 11 ns, error, "Stable real Fail", C_SCOPE);
      check_stable(sl, 11 ns, error, "Stable std_logic Fail", C_SCOPE);

      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 20 ns, error, "Stable slv OK", C_SCOPE);
      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 30 ns, error, "Stable slv OK", C_SCOPE);

      report_check_counters(VOID);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "check_stable_default_alert" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_stable with default alert level", C_SCOPE);
      bool   <= true;
      slv8   <= (others => '1');
      uns8   <= (others => '1');
      sig8   <= (others => '1');
      int    <= 14;
      real_a <= 1337.14;
      sl     <= '1';
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 7);
      check_stable(bool, 9 ns, "Stable boolean OK", C_SCOPE);
      check_stable(slv8, 9 ns, "Stable slv OK", C_SCOPE);
      check_stable(uns8, 9 ns, "Stable unsigned OK", C_SCOPE);
      check_stable(sig8, 9 ns, "Stable signed OK", C_SCOPE);
      check_stable(int, 9 ns, "Stable integer OK", C_SCOPE);
      check_stable(real_a, 9 ns, "Stable real OK", C_SCOPE);
      check_stable(sl, 9 ns, "Stable std_logic OK", C_SCOPE);
      check_stable(bool, 11 ns, "Stable boolean Fail", C_SCOPE);
      check_stable(slv8, 11 ns, "Stable slv Fail", C_SCOPE);
      check_stable(uns8, 11 ns, "Stable unsigned Fail", C_SCOPE);
      check_stable(sig8, 11 ns, "Stable signed Fail", C_SCOPE);
      check_stable(int, 11 ns, "Stable integer Fail", C_SCOPE);
      check_stable(real_a, 11 ns, "Stable real Fail", C_SCOPE);
      check_stable(sl, 11 ns, "Stable std_logic Fail", C_SCOPE);

      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 20 ns, "Stable slv OK", C_SCOPE);
      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 30 ns, "Stable slv OK", C_SCOPE);

      report_check_counters(VOID);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "check_value_in_range" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_value_in_range", C_SCOPE);
      -- check_value_in_range : integer
      v_int_a := 3;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_int_a, 3, 4, error, "Check_value_in_range, OK", C_SCOPE);
      v_bool := check_value_in_range(v_int_a, 2, 3, error, "Check_value_in_range, OK", C_SCOPE);
      check_value(v_bool, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value_in_range(v_int_a, 4, 5, error, "Check_value_in_range, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);

      -- check_value_in_range : unsigned
      v_uns32 := x"80000000";             -- +2^31 (2147483648)
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value_in_range(v_uns32, x"00000001", x"80000001", error, "Check 2147483648 between 1 and 2147483649, OK", C_SCOPE);
      check_value_in_range(v_uns32, x"00000001", x"7FFFFFFF", error, "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      v_bool := check_value_in_range(v_uns32, x"00000001", x"7FFFFFFF", error, "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);

      -- check_value_in_range : signed
      v_sig32 := x"80000001";             -- -2^31 (-2147483647)
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_sig32, x"80000000", x"00000001", error, "Check -2147483647 between -2147483648 and 1, OK", C_SCOPE);
      check_value_in_range(v_sig32, x"80000002", x"00000001", error, "Check -2147483647 between -2147483646 and 1, Fail", C_SCOPE);

      -- check_value_in_range : time
      v_time := 3 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_time, 2 ns, 5 ns, error, "Check time in range, OK", C_SCOPE);
      v_bool := check_value_in_range(v_time, 3 ns, 5 ns, error, "Check time in range, OK", C_SCOPE);
      check_value(v_bool, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value_in_range(v_time, 4 ns, 5 ns, error, "Check time in range, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);

      -- check_value_in_range : real
      v_real := 3.0;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_real, 1.5, 3.1, error, "Check real in range, OK", C_SCOPE);
      v_bool := check_value_in_range(v_real, 3.0, 5.1, error, "Check real in range, OK", C_SCOPE);
      check_value(v_bool, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value_in_range(v_real, 3.1, 4.9, error, "Check real in range, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);

      report_check_counters(VOID);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "check_value_in_range_default_alert" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_value_in_range with default alert level", C_SCOPE);
      -- check_value_in_range : integer
      v_int_a := 3;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_int_a, 3, 4, "Check_value_in_range, OK", C_SCOPE);
      v_bool := check_value_in_range(v_int_a, 2, 3, "Check_value_in_range, OK", C_SCOPE);
      check_value(v_bool, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value_in_range(v_int_a, 4, 5, "Check_value_in_range, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);

      -- check_value_in_range : unsigned
      v_uns32 := x"80000000";             -- +2^31 (2147483648)
      increment_expected_alerts_and_stop_limit(error, 2);
      check_value_in_range(v_uns32, x"00000001", x"80000001", "Check 2147483648 between 1 and 2147483649, OK", C_SCOPE);
      check_value_in_range(v_uns32, x"00000001", x"7FFFFFFF", "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      v_bool := check_value_in_range(v_uns32, x"00000001", x"7FFFFFFF", "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);

      -- check_value_in_range : signed
      v_sig32 := x"80000001";             -- -2^31 (-2147483647)
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_sig32, x"80000000", x"00000001", "Check -2147483647 between -2147483648 and 1, OK", C_SCOPE);
      check_value_in_range(v_sig32, x"80000002", x"00000001", "Check -2147483647 between -2147483646 and 1, Fail", C_SCOPE);

      -- check_value_in_range : time
      v_time := 3 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_time, 2 ns, 5 ns, "Check time in range, OK", C_SCOPE);
      v_bool := check_value_in_range(v_time, 3 ns, 5 ns, "Check time in range, OK", C_SCOPE);
      check_value(v_bool, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value_in_range(v_time, 4 ns, 5 ns, "Check time in range, Fail", C_SCOPE);
      check_value(not v_bool, "check_value with return value shall return false when Fail", C_SCOPE);

      -- check_value_in_range : real
      v_real := 3.0;
      increment_expected_alerts_and_stop_limit(error, 1);
      check_value_in_range(v_real, 1.5, 3.1, error, "Check real in range, OK", C_SCOPE);
      v_bool := check_value_in_range(v_real, 3.0, 5.1, error, "Check real in range, OK", C_SCOPE);
      check_value(v_bool, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_bool := check_value_in_range(v_real, 3.1, 4.9, error, "Check real in range, Fail", C_SCOPE);
      check_value(not v_bool, error, "check_value with return value shall return false when Fail", C_SCOPE);

      report_check_counters(VOID);
    
    elsif GC_TESTCASE = "check_sb_completion" then

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection [without SB]", C_SCOPE);
      -----------------------------------------------------------------------------
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show no SB to report
      check_value(v_bool, "check_sb_completion with return value shall return true when no SB (and no expected)", C_SCOPE);

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection with SB [enabling/disabling]", C_SCOPE);
      -----------------------------------------------------------------------------
      v_sb.set_scope("DEMO SB 1");
      v_sb.config(C_SB_CONFIG_1); -- Config with error on mismatch
      v_sb.enable(VOID);
      v_sb.enable_log_msg(ID_DATA);

      log(ID_SEQUENCER, "Testing completion detection with SB (enabled, no expected)", C_SCOPE);
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show 1-SB enabled
      check_value(v_bool, "check_sb_completion with return value shall return true when no SB has expected", C_SCOPE);

      log(ID_SEQUENCER, "Testing completion detection with SB (disabled, no expected)", C_SCOPE);
      v_sb.disable(VOID);
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show 1-SB disabled
      check_value(v_bool, "check_sb_completion with return value shall return true when no SB has expected", C_SCOPE);

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection with SB [without received, then with received]", C_SCOPE);
      -----------------------------------------------------------------------------
      v_sb.set_scope("DEMO SB 2");
      v_sb.config(C_SB_CONFIG_2); -- Config with warning on mismatch
      v_sb.enable(VOID);

      log(ID_SEQUENCER, "Testing completion detection with SB (without received)", C_SCOPE);
      v_slv8 := "01010101";
      v_sb.add_expected(v_slv8, "adding expected");
      increment_expected_alerts(TB_WARNING, 1, "Increment for await sb completion alert");
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, NO_REPORT, C_SCOPE); -- Should give an alert as it never got expected
      check_value(not v_bool, "check_sb_completion with return value shall return false when SB has expected", C_SCOPE);

      log(ID_SEQUENCER, "Testing completion detection with SB (with received)", C_SCOPE);
      v_slv8_2 := "01010101";
      v_sb.check_received(v_slv8_2, "checking received");
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, NO_REPORT, C_SCOPE);
      check_value(v_bool, "check_sb_completion with return value shall return true when SB has no expected left", C_SCOPE);

      v_sb.disable(VOID); -- Will remove the SB for the next test

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection with SB [delayed received check]", C_SCOPE);
      -----------------------------------------------------------------------------
      v_sb.set_scope("DEMO SB 3");
      v_sb.config(C_SB_CONFIG_2); -- Config with warning on mismatch
      v_sb.enable(VOID);

      log(ID_SEQUENCER, "Testing completion detection with SB (delayed received check)", C_SCOPE);
      v_slv8 := "01010101";
      v_sb.add_expected(v_slv8, "adding expected");
      increment_expected_alerts(TB_WARNING, 1, "Increment for await sb completion alert");
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, NO_REPORT, C_SCOPE); -- Should give an alert as it never got expected
      check_value(not v_bool, "check_sb_completion with return value shall return false when SB has expected", C_SCOPE);

      v_sb.disable(VOID); -- Will remove the SB for the next test

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection with SB [reset/flush]", C_SCOPE);
      -----------------------------------------------------------------------------
      v_sb.set_scope("DEMO SB 4");
      v_sb.config(C_SB_CONFIG_2); -- Config with warning on mismatch
      v_sb.enable(VOID);

      -- Two mismatching values for testing
      v_slv8   := "01010101";
      v_slv8_2 := "10101010";

      log(ID_SEQUENCER, "Resetting Scoreboard", C_SCOPE);
      v_sb.add_expected(v_slv8_2, "adding expected 1");
      v_sb.reset(VOID); -- Reset the scoreboard (this will remove all expected and received data)
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show 1-SB enabled
      check_value(v_bool, "check_sb_completion with return value shall return true when SB has no expected left", C_SCOPE);

      increment_expected_alerts(WARNING, 1, "Increment for await sb completion alert"); -- Increment alert to check reset worked as expected
      v_sb.add_expected(v_slv8, "adding expected 2");
      v_sb.check_received(v_slv8_2, "checking received"); -- Should give an alert (still on config set before reset)

      log(ID_SEQUENCER, "Flushing Scoreboard", C_SCOPE);
      v_sb.add_expected(v_slv8, "adding expected 3");
      v_sb.flush(VOID); -- Flush the scoreboard (this will remove all received data, and config)
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show 1-SB enabled
      check_value(v_bool, "check_sb_completion with return value shall return true when SB has no expected left", C_SCOPE);

      v_sb.disable(VOID); -- Will remove the SB for the next test

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection with SB [pending entries (alert), disabled]", C_SCOPE);
      -----------------------------------------------------------------------------
      v_sb.set_scope("DEMO SB 5");
      v_sb.config(C_SB_CONFIG_2); -- Config with warning on mismatch
      v_sb.enable(VOID);

      log(ID_SEQUENCER, "Testing completion detection with SB (pending entries, disabled)", C_SCOPE);
      v_sb.add_expected(v_slv8, "adding expected");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "Increment for await sb completion alert");
      v_bool := check_sb_completion(TB_ERROR, NO_REPORT, NO_REPORT, C_SCOPE); -- Should give an alert as it never got expected
      check_value(not v_bool, "check_sb_completion with return value shall return false when SB has expected", C_SCOPE);

      v_sb.disable(VOID); -- Disable the SB (this will keep the pending entries, but no alerts will be given)
      check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show 1-SB disabled

      v_sb.enable(VOID); -- The SB is enabled again for the next test (the pending entries are still there)
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "Increment for await sb completion alert");
      v_bool := check_sb_completion(TB_ERROR, NO_REPORT, NO_REPORT, C_SCOPE); -- Should give an alert as it never got expected
      check_value(not v_bool, "check_sb_completion with return value shall return false when SB has expected", C_SCOPE);

      v_sb.flush(VOID); -- Flush the scoreboard (this will remove all received data, and config)
      check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show 1-SB enabled

      v_sb.disable(VOID); -- Will remove the SB for the next test

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection with SB [different SB methods (insert_expected, delete_expected, fetch_expected)]", C_SCOPE);
      -----------------------------------------------------------------------------
      v_sb.set_scope("DEMO SB 6");
      v_sb.config(C_SB_CONFIG_1); -- Config default with error on mismatch
      v_sb.enable(VOID);

      log(ID_SEQUENCER, "Inserting expected to SB", C_SCOPE);
      v_slv8   := "01010101";
      v_slv8_2 := "10101010";
      v_sb.add_expected(v_slv8,   "adding expected 1");
      v_sb.add_expected(v_slv8_2, "adding expected 2");
      v_int_a  := v_sb.find_expected_entry_num(v_slv8);
      v_slv8   := "11111111";
      v_slv8_2 := "00000001";
      v_sb.insert_expected(ENTRY_NUM, v_int_a, v_slv8,   "inserting expected 3 after 1, but before 2");
      v_sb.insert_expected(ENTRY_NUM, v_int_a, v_slv8_2, "inserting expected 4 after 1, but before 3 and 2");
      increment_expected_alerts(TB_WARNING, 1, "Increment for await sb completion alert");
      v_bool := check_sb_completion(TB_WARNING, NO_REPORT, NO_REPORT, C_SCOPE); -- Should give an alert as it never got expected
      check_value(not v_bool, "check_sb_completion with return value shall return false when SB has expected", C_SCOPE);

      log(ID_SEQUENCER, "Deleting expected from SB", C_SCOPE);
      v_slv8 := v_sb.fetch_expected(1, POSITION, 2, "fetching expected 4");
      v_sb.delete_expected(1, POSITION, 2, SINGLE); -- so only pos 2 is deleted
      check_value(v_slv8, v_slv8_2, "checking fetched value 4");
      log(ID_SEQUENCER, "Remove both 1 and 2 by use of check_received", C_SCOPE);
      v_slv8   := "01010101";
      v_slv8_2 := "10101010";
      v_sb.check_received(v_slv8,   "checking received 1");
      v_sb.check_received(v_slv8_2, "checking received 2");
      check_sb_completion(TB_WARNING, NO_REPORT, NO_REPORT, C_SCOPE);

      v_sb.disable(VOID); -- Will remove the SB for the next test

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection with SB [multiple instances, multiple SBs]", C_SCOPE);
      -----------------------------------------------------------------------------
      -- SB 1
      v_sb.set_scope("DEMO SB 7");
      v_sb.config(C_SB_CONFIG_2); -- Config with warning on mismatch
      v_sb.enable(VOID);

      -- SB 2
      v_sb_2.set_scope("DEMO SB 8");
      v_sb_2.config(C_SB_CONFIG_2); -- Config with warning on mismatch
      v_sb_2.enable(VOID);
      v_sb_2.enable_log_msg(ID_DATA);

      -- SB 1 (adding instances)
      v_sb.enable(2);
      v_sb.enable(3);
      v_sb.enable_log_msg(ALL_INSTANCES, ID_DATA);

      check_sb_completion(TB_WARNING, NO_REPORT, REPORT_SCOREBOARDS, C_SCOPE); -- Should show 4-SB enabled

      v_sb.add_expected(2, v_slv8, "adding expected 1");
      v_sb.add_expected(3, v_slv8, "adding expected 2");
      v_sb_2.add_expected( v_slv8, "adding expected 3");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1, "Increment for await sb completion alert");
      v_bool := check_sb_completion(TB_ERROR, NO_REPORT, NO_REPORT, C_SCOPE); -- Should give a single alert as it never got expected
      check_value(not v_bool, "check_sb_completion with return value shall return false when SB has expected", C_SCOPE);
      
      -- Will remove the SB for the next test
      v_sb.disable(1);
      v_sb.disable(2);
      v_sb.disable(3);
      v_sb_2.disable(VOID);

      -----------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing completion detection alert counter reports", C_SCOPE);
      -----------------------------------------------------------------------------
      check_sb_completion(TB_WARNING, REPORT_ALERT_COUNTERS, NO_REPORT, C_SCOPE);
      check_sb_completion(TB_WARNING, REPORT_ALERT_COUNTERS_FINAL, NO_REPORT, C_SCOPE);

    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;              -- to allow some time for completion
    report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                          -- to stop completely
  end process p_main;

end architecture check_arch;
