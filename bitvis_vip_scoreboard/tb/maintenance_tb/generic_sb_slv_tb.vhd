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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

--hdlregression:tb
-- Test case entity
entity generic_sb_slv_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity generic_sb_slv_tb;

-- Test case architecture
architecture func of generic_sb_slv_tb is

  constant C_SLV_SB_CONFIG_DEFAULT : t_sb_config := (mismatch_alert_level      => NO_ALERT,
                                                     allow_lossy               => false,
                                                     allow_out_of_order        => false,
                                                     overdue_check_alert_level => WARNING,
                                                     overdue_check_time_limit  => 0 ns,
                                                     ignore_initial_garbage    => false);

  package slv_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
    generic map(t_element         => std_logic_vector(7 downto 0),
                element_match     => std_match,
                to_string_element => to_string,
                sb_config_default => C_SLV_SB_CONFIG_DEFAULT);

  use slv_sb_pkg.all;

  shared variable sb_under_test : slv_sb_pkg.t_generic_sb;

  constant C_SCOPE    : string := "test_bench";
  constant C_SB_SCOPE : string := "slv_sb_scope";

begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    procedure add_100_expected_elements_with_no_tag(
      constant scope : string
    ) is
    begin
      log(ID_SEQUENCER, "adding 100 expected elements with no tag", scope);
      for i in 1 to 100 loop
        sb_under_test.add_expected(std_logic_vector(to_unsigned(i, 8)), "add expected: " & to_string(i));
      end loop;
    end procedure add_100_expected_elements_with_no_tag;

    procedure add_100_expected_elements_with_same_tag(
      constant scope : string
    ) is
    begin
      log(ID_SEQUENCER, "adding 100 expected elements with same tag", scope);
      for i in 1 to 100 loop
        sb_under_test.add_expected(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "add expected: " & to_string(i));
      end loop;
    end procedure add_100_expected_elements_with_same_tag;

    procedure add_100_expected_elements_with_different_tag(
      constant scope : string
    ) is
    begin
      log(ID_SEQUENCER, "adding 100 expected elements with different tag", scope);
      for i in 1 to 100 loop
        sb_under_test.add_expected(std_logic_vector(to_unsigned(i, 8)), TAG, "tag " & to_string(i), "add expected with tag: " & to_string(i), "source " & to_string(i));
      end loop;
    end procedure add_100_expected_elements_with_different_tag;

    procedure test_add_expected is
      constant scope : string := "TB: add_expected";
    begin

      log(ID_LOG_HDR_LARGE, "Test add_expected", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);

      sb_under_test.reset(VOID);

    end procedure test_add_expected;

    procedure test_check_received is
      constant scope : string := "TB: check_received";
    begin

      log(ID_LOG_HDR_LARGE, "Test check_received", scope);

      log(ID_LOG_HDR, "checking received data vs expected data", scope);
      add_100_expected_elements_with_same_tag(scope);
      for i in 1 to 100 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID), ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 100, ERROR, "verify match count", scope);

      sb_under_test.reset(VOID);

      log(ID_LOG_HDR, "checking received data vs expected data with wrong tag", scope);
      add_100_expected_elements_with_same_tag(scope);
      for i in 1 to 50 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;
      for i in 51 to 100 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "wrong tag", "check received: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID), ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 50, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 50, ERROR, "verify mismatch count", scope);

      sb_under_test.reset(VOID);

    end procedure test_check_received;

    procedure test_check_received_out_of_order is
      constant scope    : string := "TB: check_received OOO";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test check_received with out of order", scope);

      v_config                    := C_SB_CONFIG_DEFAULT;
      v_config.allow_out_of_order := true;

      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "checking received data vs expected data", scope);
      for i in 100 downto 1 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID), ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 100, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);

      sb_under_test.reset(VOID);

    end procedure test_check_received_out_of_order;

    procedure test_check_received_lossy is
      constant scope    : string := "TB: check_received lossy";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test check_received with lossy", scope);

      v_config             := C_SB_CONFIG_DEFAULT;
      v_config.allow_lossy := true;

      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "checking received data vs expected data", scope);
      for i in 51 to 100 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID), ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 50, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);

      sb_under_test.reset(VOID);

    end procedure test_check_received_lossy;

    procedure test_initial_garbage is
      variable scope    : string(1 to 26);
      variable v_config : t_sb_config;
    begin

      sb_under_test.enable_log_msg(ID_CTRL);
      sb_under_test.enable_log_msg(ID_DATA);

      scope := pad_string("TB: initial garbage", NUL, 26);
      log(ID_LOG_HDR, "Initial garbage with no OOO or LOSSY", scope);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config                        := C_SB_CONFIG_DEFAULT;
      v_config.mismatch_alert_level   := NO_ALERT;
      v_config.ignore_initial_garbage := true;
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "add expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking initial garbage", scope);
      for i in 2 to 100 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "initial garbage");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      for i in 1 to 50 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 50, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 50, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      for i in 52 to 100 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "check received expect mismatch");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 1, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 50, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 49, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      sb_under_test.check_received(std_logic_vector(to_unsigned(100, 8)), "checking received");

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 51, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 49, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset("reset SB");

      -----------------------------------------------------------------------------------------------------------------

      scope := pad_string("TB: initial garbage, OOO", NUL, 26);
      log(ID_LOG_HDR, "Initial garbage with OOO", scope);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config                        := C_SB_CONFIG_DEFAULT;
      v_config.mismatch_alert_level   := NO_ALERT;
      v_config.allow_out_of_order     := true;
      v_config.ignore_initial_garbage := true;
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "add expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking initial garbage", scope);
      for i in 101 to 150 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "initial garbage");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      for i in 50 downto 1 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received OOO");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 50, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 50, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received mismatch", scope);
      for i in 50 downto 1 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received OOO expect mismatch");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 50, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 50, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 50, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      for i in 100 downto 51 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received OOO");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 100, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 50, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset("reset SB");

      -----------------------------------------------------------------------------------------------------------------

      scope := "TB: initial garbage, lossy";
      log(ID_LOG_HDR, "Initial garbage with lossy", scope);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config                        := C_SB_CONFIG_DEFAULT;
      v_config.mismatch_alert_level   := NO_ALERT;
      v_config.allow_lossy            := true;
      v_config.ignore_initial_garbage := true;
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "add expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking initial garbage", scope);
      for i in 101 to 150 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "initial garbage");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      sb_under_test.check_received(std_logic_vector(to_unsigned(50, 8)), "checking received lossy");

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 50, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 1, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 49, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      for i in 49 downto 1 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received lossy");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 50, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 1, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 49, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 49, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "checking received", scope);
      for i in 51 to 100 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received lossy");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 51, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 49, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 49, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset("reset SB");

    end procedure test_initial_garbage;

    procedure test_overdue_time_limit is
      constant scope    : string := "TB: overdue check";
      variable v_config : t_sb_config;
    begin

      sb_under_test.enable_log_msg(ID_CTRL);
      sb_under_test.enable_log_msg(ID_DATA);
      set_alert_stop_limit(TB_WARNING, 1);

      log(ID_LOG_HDR, "Test overdue check", scope);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config                           := C_SB_CONFIG_DEFAULT;
      v_config.overdue_check_alert_level := TB_WARNING;
      v_config.overdue_check_time_limit  := 10 ns;
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "add expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "wait 9 ns", scope);
      wait for 9 ns;

      log(ID_LOG_HDR, "checking received", scope);
      for i in 1 to 10 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 90, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 10, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "Insert 10 expected to possition 76", scope);
      for i in 1 to 10 loop
        sb_under_test.insert_expected(POSITION, 76, x"AA", TAG, "inserted, " & to_string(i), "insert in position 76");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 110, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 10, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "wait 1 ns", scope);
      wait for 1 ns;

      log(ID_LOG_HDR, "checking received", scope);
      for i in 11 to 80 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 30, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 110, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 80, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      set_alert_stop_limit(TB_WARNING, 7);
      increment_expected_alerts(TB_WARNING, 1); -- Becouse of time stamp truncate warning
      log(ID_LOG_HDR, "wait 1 ps", scope);
      wait for 1 ps;

      increment_expected_alerts(TB_WARNING, 5);
      log(ID_LOG_HDR, "checking received, expecting 5 TB_WARNINGs", scope);
      for i in 81 to 85 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received");
      end loop;
      for i in 86 to 90 loop
        sb_under_test.check_received(x"AA", "checking received inserted");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 20, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 110, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 90, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "wait 10 ns", scope);
      wait for 10 ns;

      set_alert_stop_limit(TB_WARNING, 27);
      increment_expected_alerts(TB_WARNING, 20);

      log(ID_LOG_HDR, "checking received, expecting 20 TB_WARNINGs", scope);
      for i in 91 to 95 loop
        sb_under_test.check_received(x"AA", "checking received inserted");
      end loop;
      for i in 86 to 100 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "checking received");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 110, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 110, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset("reset SB");

    end procedure test_overdue_time_limit;

    procedure test_find is
      constant scope    : string := "TB: find";
      variable v_config : t_sb_config;

      procedure add_data is
      begin
        for i in 1 to 10 loop
          sb_under_test.add_expected(std_logic_vector(to_unsigned(i, 8)), "Add expected " & to_string(i) & " without tag"); -- entry num 1 to 10
        end loop;
        sb_under_test.add_expected(std_logic_vector(to_unsigned(11, 8)), "Add expected 11 without tag"); -- entry num 11
        sb_under_test.add_expected(std_logic_vector(to_unsigned(11, 8)), "Add expected 11 without tag"); -- entry num 12
        for i in 13 to 20 loop
          sb_under_test.add_expected(std_logic_vector(to_unsigned(i, 8)), TAG, "same tag", "Add expected " & to_string(i) & " with tag 'same tag'"); -- entry num 13 to 20
        end loop;
        for i in 21 to 30 loop
          sb_under_test.add_expected(std_logic_vector(to_unsigned(21, 8)), TAG, "tag " & to_string(i), "Add expected " & to_string(21) & " with tag 'tag " & to_string(i) & "'"); -- entry num 21 to 30
        end loop;
      end procedure add_data;

      procedure check_position is
      begin
        check_value(sb_under_test.find_expected_position(std_logic_vector(to_unsigned(1, 8))), 1, ERROR, "expect position 1", scope);
        check_value(sb_under_test.find_expected_position(std_logic_vector(to_unsigned(1, 8))), 1, ERROR, "expect position 1", scope);
        check_value(sb_under_test.find_expected_position(std_logic_vector(to_unsigned(11, 8))), 11, ERROR, "expect position 11", scope);
        check_value(sb_under_test.find_expected_position(TAG, "same tag"), 13, ERROR, "expect position 13", scope);
        for i in 21 to 30 loop
          check_value(sb_under_test.find_expected_position(TAG, "tag " & to_string(i)), i, ERROR, "expect position " & to_string(i), scope);
        end loop;
        check_value(sb_under_test.find_expected_position(std_logic_vector(to_unsigned(21, 8)), TAG, "tag 27"), 27, ERROR, "expect position 27", scope);
        check_value(sb_under_test.find_expected_position(std_logic_vector(to_unsigned(23, 8)), TAG, "tag 24"), -1, ERROR, "expect no match found", scope);
      end procedure check_position;
    begin

      log(ID_LOG_HDR_LARGE, "Test find()", scope);

      sb_under_test.enable_log_msg(ID_CTRL);
      sb_under_test.enable_log_msg(ID_DATA);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config := C_SB_CONFIG_DEFAULT;
      sb_under_test.config(v_config);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "adding expected data", scope);
      add_data;

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 30, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 30, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check find_expected_position()", scope);
      check_position;

      log(ID_LOG_HDR, "check counters after find_expected_position()", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 30, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 30, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check find_expected_entry_num()", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(1, 8))), 1, ERROR, "expect entry number 1", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(1, 8))), 1, ERROR, "expect entry number 1", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(11, 8))), 11, ERROR, "expect entry number 11", scope);
      check_value(sb_under_test.find_expected_entry_num(TAG, "same tag"), 13, ERROR, "expect entry number 13", scope);
      for i in 21 to 30 loop
        check_value(sb_under_test.find_expected_entry_num(TAG, "tag " & to_string(i)), i, ERROR, "expect entry number " & to_string(i), scope);
      end loop;
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(21, 8)), TAG, "tag 27"), 27, ERROR, "expect entry number 27", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(23, 8)), TAG, "tag 24"), -1, ERROR, "expect no match found", scope);

      log(ID_LOG_HDR, "check counters after find_expected_entry_num()", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 30, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 30, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.flush("Flush SB");

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "adding expected data", scope);
      add_data;

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 30, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 60, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 30, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check find_expected_position()", scope);
      check_position;

      log(ID_LOG_HDR, "check counters after find_expected_position()", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 30, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 60, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 30, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check find_expected_entry_num()", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(1, 8))), 31, ERROR, "expect entry number 31", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(1, 8))), 31, ERROR, "expect entry number 31", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(11, 8))), 41, ERROR, "expect entry number 41", scope);
      check_value(sb_under_test.find_expected_entry_num(TAG, "same tag"), 43, ERROR, "expect entry number 43", scope);
      for i in 21 to 30 loop
        check_value(sb_under_test.find_expected_entry_num(TAG, "tag " & to_string(i)), 30 + i, ERROR, "expect entry number " & to_string(30 + i), scope);
      end loop;
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(21, 8)), TAG, "tag 27"), 57, ERROR, "expect entry number 57", scope);
      check_value(sb_under_test.find_expected_entry_num(std_logic_vector(to_unsigned(23, 8)), TAG, "tag 24"), -1, ERROR, "expect no match found", scope);

      log(ID_LOG_HDR, "check counters after find_expected_entry_num()", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 30, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 60, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 30, ERROR, "verify delete count", scope);

      sb_under_test.reset("reset SB");

    end procedure test_find;

    procedure test_peek is
      constant scope    : string := "TB: peek";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test peek", scope);

      sb_under_test.enable_log_msg(ID_CTRL);
      sb_under_test.enable_log_msg(ID_DATA);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config := C_SB_CONFIG_DEFAULT;
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data 1", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check peek with position 1", scope);
      check_value(sb_under_test.peek_expected(VOID), std_logic_vector(to_unsigned(1, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(1, 8)), HEX), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.peek_expected(POSITION, i), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
        check_value(sb_under_test.peek_source(POSITION, i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(POSITION, i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check peek with entry number 1", scope);
      check_value(sb_under_test.peek_expected(VOID), std_logic_vector(to_unsigned(1, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(1, 8)), HEX), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.peek_expected(ENTRY_NUM, i), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
        check_value(sb_under_test.peek_source(ENTRY_NUM, i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(ENTRY_NUM, i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.flush("flushing SB");

      log(ID_LOG_HDR, "adding expected data 2", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 200, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 100, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check peek with position 2", scope);
      check_value(sb_under_test.peek_expected(VOID), std_logic_vector(to_unsigned(1, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(1, 8)), HEX), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.peek_expected(POSITION, i), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
        check_value(sb_under_test.peek_source(POSITION, i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(POSITION, i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check peek with entry number 2", scope);
      check_value(sb_under_test.peek_expected(VOID), std_logic_vector(to_unsigned(1, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(1, 8)), HEX), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.peek_expected(ENTRY_NUM, 100 + i), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
        check_value(sb_under_test.peek_source(ENTRY_NUM, 100 + i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(ENTRY_NUM, 100 + i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 200, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 100, ERROR, "verify delete count", scope);

      sb_under_test.reset("reseting SB");

    end procedure test_peek;

    procedure test_fetch is
      constant scope    : string := "TB: fetch";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test fetch", scope);

      sb_under_test.enable_log_msg(ID_CTRL);
      sb_under_test.enable_log_msg(ID_DATA);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config := C_SB_CONFIG_DEFAULT;
      sb_under_test.config(v_config);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "check fetch from front", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_expected("fetch nr. " & to_string(i)), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 100, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 200, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 100, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_source("fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 200, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 200, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 300, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 200, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_tag("tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 300, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 300, ERROR, "verify delete count", scope);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "check fetch from back by position", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 400, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 300, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_expected(POSITION, i, "fetch nr. " & to_string(i)), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 400, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 400, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 500, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 400, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_source(POSITION, i, "fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 500, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 500, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 600, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 500, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_tag(POSITION, i, "tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 600, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 600, ERROR, "verify delete count", scope);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "check fetch from back by entry number", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 700, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 600, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_expected(ENTRY_NUM, 600 + i, "fetch nr. " & to_string(i)), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 700, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 700, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 800, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 700, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_source(ENTRY_NUM, 700 + i, "fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 800, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 800, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 900, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 800, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_tag(ENTRY_NUM, 800 + i, "tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 900, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 900, ERROR, "verify delete count", scope);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "check fetch from front by entry number", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 1000, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 900, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_expected(ENTRY_NUM, 900 + i, "fetch nr. " & to_string(i)), std_logic_vector(to_unsigned(i, 8)), ERROR, "expect " & to_string(std_logic_vector(to_unsigned(i, 8)), HEX), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 1000, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 1000, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 1100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 1000, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_source(ENTRY_NUM, 1000 + i, "fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 1100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 1100, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 1200, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 1100, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_tag(ENTRY_NUM, 1100 + i, "tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 1200, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 1200, ERROR, "verify delete count", scope);

      -----------------------------------------------------------------------------------------------------------------

      sb_under_test.reset("reseting SB");

    end procedure test_fetch;

    procedure test_insert_expected is
      constant scope    : string := "TB: insert_expected";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test insert_expected", scope);

      sb_under_test.disable_log_msg(ID_DATA);

      v_config := C_SB_CONFIG_DEFAULT;
      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "check counters before inserts", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "Insert expected", scope);
      sb_under_test.insert_expected(POSITION, 2, x"AA", TAG, "inserted, 1", "insert in position 2");
      sb_under_test.insert_expected(ENTRY_NUM, 50, x"BB", TAG, "inserted, 2", "insert after entry number 50");
      sb_under_test.insert_expected(POSITION, 102, x"CC", TAG, "inserted, 3", "insert in position 102");

      log(ID_LOG_HDR, "check counters after inserts", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 103, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check expected", scope);
      sb_under_test.check_received(std_logic_vector(to_unsigned(1, 8)), TAG, "tag added", "check received: " & to_string(1));
      sb_under_test.check_received(x"AA", TAG, "inserted, 1", "check received: inserted element 1");
      for i in 2 to 50 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;
      sb_under_test.check_received(x"BB", TAG, "inserted, 2", "check received: inserted element 2");
      for i in 51 to 99 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;
      sb_under_test.check_received(x"CC", TAG, "inserted, 3", "check received: inserted element 3");
      sb_under_test.check_received(std_logic_vector(to_unsigned(100, 8)), TAG, "tag added", "check received: " & to_string(100));

      log(ID_LOG_HDR, "check counters after check_expected", scope);
      check_value(sb_under_test.is_empty(VOID), ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 103, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.report_counters(ALL_INSTANCES);
      sb_under_test.report_counters(VOID);

      sb_under_test.reset(VOID);

      log(ID_LOG_HDR, "check insert_expected to empty SB with identifier_option=POSITION, identifier=1", scope);
      sb_under_test.insert_expected(POSITION, 1, x"AA", TAG, "inserted, 1", "insert in position 2");

      sb_under_test.report_counters(ALL_INSTANCES);
      sb_under_test.report_counters(VOID);

      sb_under_test.reset(VOID);

    end procedure test_insert_expected;

    procedure test_insert_expected_no_tag is
      constant scope    : string := "TB: insert_expected_no_tag";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test insert_expected", scope);

      sb_under_test.disable_log_msg(ID_DATA);

      v_config := C_SB_CONFIG_DEFAULT;
      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_no_tag(scope);

      log(ID_LOG_HDR, "check counters before inserts", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "Insert expected", scope);
      sb_under_test.insert_expected(POSITION, 2, x"AA", "insert in position 2");
      sb_under_test.insert_expected(ENTRY_NUM, 50, x"BB", "insert after entry number 50");
      sb_under_test.insert_expected(POSITION, 102, x"CC", "insert in position 102");

      log(ID_LOG_HDR, "check counters after inserts", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 103, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check expected", scope);
      sb_under_test.check_received(std_logic_vector(to_unsigned(1, 8)), "check received: " & to_string(1));
      sb_under_test.check_received(x"AA", "check received: inserted element 1");
      for i in 2 to 50 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "check received: " & to_string(i));
      end loop;
      sb_under_test.check_received(x"BB", "check received: inserted element 2");
      for i in 51 to 99 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), "check received: " & to_string(i));
      end loop;
      sb_under_test.check_received(x"CC", "check received: inserted element 3");
      sb_under_test.check_received(std_logic_vector(to_unsigned(100, 8)), "check received: " & to_string(100));

      log(ID_LOG_HDR, "check counters after check_expected", scope);
      check_value(sb_under_test.is_empty(VOID), ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 103, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      sb_under_test.report_counters(ALL_INSTANCES);
      sb_under_test.report_counters(VOID);

      sb_under_test.reset(VOID);

    end procedure test_insert_expected_no_tag;

    procedure test_delete_expected is
      constant scope    : string := "TB: delete_expected";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test delete_expected", scope);

      sb_under_test.enable_log_msg(ID_DATA);

      v_config := C_SB_CONFIG_DEFAULT;
      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "Insert expected", scope);
      sb_under_test.insert_expected(POSITION, 7, x"AA", TAG, "inserted 1", "insert in position 7");
      sb_under_test.insert_expected(ENTRY_NUM, 34, x"BB", TAG, "inserted 2", "insert after entry number 34");
      sb_under_test.insert_expected(POSITION, 99, x"CC", TAG, "inserted 3", "insert in position 99");

      log(ID_LOG_HDR, "check counters after inserts", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 103, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 0, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "Delete expected", scope);
      sb_under_test.delete_expected(POSITION, 103, SINGLE, "delete back entry");
      sb_under_test.delete_expected(POSITION, 2, SINGLE, "delete position 2");
      sb_under_test.delete_expected(ENTRY_NUM, 5, SINGLE, "delete entry number 5");
      sb_under_test.delete_expected(x"CC", "delete expected xCC");
      sb_under_test.delete_expected(std_logic_vector(to_unsigned(76, 8)), TAG, "tag added", "delete expected value 76 with tag");
      sb_under_test.delete_expected(TAG, "tag added", "delete tag 'tag added', should delete first element in queue");
      sb_under_test.delete_expected(POSITION, 81, 85, "delete position 81-85");
      sb_under_test.delete_expected(ENTRY_NUM, 91, 95, "delete entry number 91-95");

      log(ID_LOG_HDR, "check counters after delete", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 87, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 16, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "Delete expected that don't match", scope);
      increment_expected_alerts(TB_ERROR, 3);
      sb_under_test.delete_expected(ENTRY_NUM, 93, SINGLE, "delete entry number 93");
      sb_under_test.delete_expected(POSITION, 110, SINGLE, "delete position 110");
      sb_under_test.delete_expected(x"78", TAG, "tag not added", "delete expected x76 with not matching tag");

      log(ID_LOG_HDR, "check counters after delete", scope);
      check_value(sb_under_test.is_empty(VOID), false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 87, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 0, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 16, ERROR, "verify delete count", scope);

      log(ID_LOG_HDR, "check expected", scope);
      sb_under_test.check_received(std_logic_vector(to_unsigned(3, 8)), TAG, "tag added", "check received: " & to_string(3));
      sb_under_test.check_received(std_logic_vector(to_unsigned(4, 8)), TAG, "tag added", "check received: " & to_string(4));
      sb_under_test.check_received(std_logic_vector(to_unsigned(6, 8)), TAG, "tag added", "check received: " & to_string(6));
      sb_under_test.check_received(x"AA", TAG, "inserted 1", "check received: xAA, inserted 1");
      for i in 7 to 34 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;
      sb_under_test.check_received(x"BB", TAG, "inserted 2", "check received: xBB, inserted 2");
      for i in 35 to 75 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;
      for i in 77 to 82 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;
      for i in 88 to 90 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;
      for i in 96 to 99 loop
        sb_under_test.check_received(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added", "check received: " & to_string(i));
      end loop;

      log(ID_LOG_HDR, "check counters after check", scope);
      check_value(sb_under_test.is_empty(VOID), true, ERROR, "verify SB is empty", scope);
      check_value(sb_under_test.get_pending_count(VOID), 0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 103, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID), 87, ERROR, "verify match count", scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 0, ERROR, "verify mismatch count", scope);
      check_value(sb_under_test.get_drop_count(VOID), 0, ERROR, "verify drop count", scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID), 0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID), 16, ERROR, "verify delete count", scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset(VOID);

    end procedure test_delete_expected;

    procedure test_exists is
      constant scope    : string := "TB: exists";
      variable v_config : t_sb_config;
    begin

      log(ID_LOG_HDR_LARGE, "Test exists", scope);

      sb_under_test.enable_log_msg(ID_DATA);

      v_config := C_SB_CONFIG_DEFAULT;
      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "exists without tag", scope);
      for i in 1 to 50 loop
        check_value(sb_under_test.exists(std_logic_vector(to_unsigned(i, 8))), ERROR, "without tag");
      end loop;

      log(ID_LOG_HDR, "exists only tag", scope);
      check_value(sb_under_test.exists(TAG, "tag added"), ERROR, "with only tag");
      check_value(sb_under_test.exists(TAG, "wrong tag"), false, ERROR, "with only tag");

      for i in 51 to 100 loop
        check_value(sb_under_test.exists(std_logic_vector(to_unsigned(i, 8)), TAG, "tag added"), ERROR, "with value " & to_string(i) & " and tag 'tag added'");
      end loop;

      for i in 101 to 150 loop
        check_value(sb_under_test.exists(std_logic_vector(to_unsigned(i, 8))), false, ERROR, "without tag");
      end loop;

      for i in 1 to 50 loop
        check_value(sb_under_test.exists(std_logic_vector(to_unsigned(i, 8)), TAG, "wrong tag"), false, ERROR, "without tag");
      end loop;

      sb_under_test.reset(VOID);

    end procedure test_exists;

    procedure test_multiple_instances is
      constant scope          : string                      := "TB: multiple instances";
      variable v_config_array : t_sb_config_array(0 to 100) := (others => C_SLV_SB_CONFIG_DEFAULT);
    begin

      log(ID_LOG_HDR_LARGE, "Test multiple instances", scope);

      sb_under_test.disable_log_msg(ALL_INSTANCES, ID_DATA);
      sb_under_test.disable(ALL_INSTANCES);
      disable_log_msg(ID_POS_ACK);

      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config_array);

      log(ID_LOG_HDR_LARGE, "add_expected", scope);
      for instance in 0 to 100 loop
        sb_under_test.enable(instance);
        for i in 0 to 100 loop
          sb_under_test.add_expected(instance, std_logic_vector(to_unsigned(i, 8)), TAG, "tag added");
        end loop;
      end loop;

      log(ID_LOG_HDR_LARGE, "insert_expected", scope);
      for instance in 0 to 100 loop
        sb_under_test.insert_expected(instance, POSITION, 3, x"AA", TAG, "tag inserted pos");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 6, x"BB", TAG, "tag inserted entry num 1");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 6, x"BB", TAG, "tag inserted entry num 2");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 7, x"BB", TAG, "tag inserted entry num 3");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 10, x"AA", TAG, "tag inserted entry num 4");
      end loop;

      log(ID_LOG_HDR_LARGE, "find_expected_position/entry_num", scope);
      for instance in 0 to 100 loop
        check_value(sb_under_test.find_expected_position(instance, x"AA"), 3, ERROR, "check position", scope);
        check_value(sb_under_test.find_expected_entry_num(instance, x"AA"), 102, ERROR, "check entry num", scope);
        check_value(sb_under_test.find_expected_position(instance, x"BB"), 8, ERROR, "check position", scope);
        check_value(sb_under_test.find_expected_entry_num(instance, x"BB"), 104, ERROR, "check entry num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "peek_expected", scope);
      for instance in 0 to 100 loop
        check_value(sb_under_test.peek_expected(instance, POSITION, 3), x"AA", ERROR, "peek position", scope);
        check_value(sb_under_test.peek_tag(instance, POSITION, 3), "tag inserted pos", ERROR, "peek position", scope);
        check_value(sb_under_test.peek_expected(instance, ENTRY_NUM, 102), x"AA", ERROR, "peek entry_num", scope);
        check_value(sb_under_test.peek_tag(instance, ENTRY_NUM, 105), "tag inserted entry num 3", ERROR, "peek entry_num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "fetch_expected", scope);
      for instance in 0 to 100 loop
        check_value(sb_under_test.fetch_expected(instance, POSITION, 3), x"AA", ERROR, "peek position", scope);
        check_value(sb_under_test.fetch_expected(instance, ENTRY_NUM, 104), x"BB", ERROR, "peek entry_num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "delete_expected", scope);
      for instance in 0 to 100 loop
        sb_under_test.delete_expected(instance, x"AA", TAG, "tag inserted entry num 4");
        sb_under_test.delete_expected(instance, x"BB");
        sb_under_test.delete_expected(instance, TAG, "tag inserted entry num 3");
      end loop;

      log(ID_LOG_HDR_LARGE, "check_received", scope);
      for instance in 0 to 100 loop
        for i in 0 to 100 - instance loop
          --log(ID_SEQUENCER, "instance: " & to_string(instance) & ", i: " & to_string(i) & ", get_pending_count:" & to_string(sb_under_test.get_pending_count(instance)));
          sb_under_test.check_received(instance, std_logic_vector(to_unsigned(i, 8)), TAG, "tag added");
        end loop;
      end loop;

      log(ID_LOG_HDR, "check counters after check", scope);
      for instance in 0 to 10 loop
        check_value(sb_under_test.is_empty(instance), instance = 0, ERROR, "verify SB is empty", scope);
        check_value(sb_under_test.get_pending_count(instance), instance, ERROR, "verify pending count", scope);
        check_value(sb_under_test.get_entered_count(instance), 106, ERROR, "verify entered count", scope);
        check_value(sb_under_test.get_match_count(instance), 101 - instance, ERROR, "verify match count", scope);
        check_value(sb_under_test.get_mismatch_count(instance), 0, ERROR, "verify mismatch count", scope);
        check_value(sb_under_test.get_drop_count(instance), 0, ERROR, "verify drop count", scope);
        check_value(sb_under_test.get_initial_garbage_count(instance), 0, ERROR, "verify initial garbage count", scope);
        check_value(sb_under_test.get_delete_count(instance), 5, ERROR, "verify delete count", scope);
        check_value(sb_under_test.get_overdue_check_count(instance), 0, ERROR, "verify delete count", scope);
      end loop;

      sb_under_test.report_counters(ALL_INSTANCES);

      sb_under_test.reset(ALL_INSTANCES);

    end procedure test_multiple_instances;

    -- check that all SB procedures give a warning when instance is not enabled
    procedure test_instance_is_enabled is
      constant scope   : string := "TB: check instance enabled";
      variable v_empty : boolean;
      variable v_count : integer;
    begin
      sb_under_test.config(C_SB_CONFIG_DEFAULT);
      log(ID_LOG_HDR_LARGE, "Test that all SB procedures give a warning when instance is not enabled", scope);

      log(ID_LOG_HDR, "Test disabling an already disabled instance", scope);
      sb_under_test.disable("Disable SB");
      increment_expected_alerts_and_stop_limit(TB_WARNING, 1);
      sb_under_test.disable("Disable SB");

      increment_expected_alerts(TB_ERROR, 16);
      log(ID_LOG_HDR, "Test disable_log_msg", scope);
      sb_under_test.disable_log_msg(ID_DATA);
      log(ID_LOG_HDR, "Test enable_log_msg", scope);
      sb_under_test.enable_log_msg(ID_DATA);
      log(ID_LOG_HDR, "Test add_expected", scope);
      sb_under_test.add_expected(x"FF");
      log(ID_LOG_HDR, "Test check_received", scope);
      sb_under_test.check_received(x"FF");
      log(ID_LOG_HDR, "Test flush", scope);
      sb_under_test.flush(VOID);
      log(ID_LOG_HDR, "Test reset", scope);
      sb_under_test.reset(VOID);
      log(ID_LOG_HDR, "Test is_empty", scope);
      v_empty := sb_under_test.is_empty(VOID);
      log(ID_LOG_HDR, "Test get_entered_count", scope);
      v_count := sb_under_test.get_entered_count(VOID);
      log(ID_LOG_HDR, "Test get_pending_count", scope);
      v_count := sb_under_test.get_pending_count(VOID);
      log(ID_LOG_HDR, "Test get_match_count", scope);
      v_count := sb_under_test.get_match_count(VOID);
      log(ID_LOG_HDR, "Test get_mismatch_count", scope);
      v_count := sb_under_test.get_mismatch_count(VOID);
      log(ID_LOG_HDR, "Test get_drop_count", scope);
      v_count := sb_under_test.get_drop_count(VOID);
      log(ID_LOG_HDR, "Test get_initial_garbage_count", scope);
      v_count := sb_under_test.get_initial_garbage_count(VOID);
      log(ID_LOG_HDR, "Test get_delete_count", scope);
      v_count := sb_under_test.get_delete_count(VOID);
      log(ID_LOG_HDR, "Test get_overdue_check_count", scope);
      v_count := sb_under_test.get_overdue_check_count(VOID);
      log(ID_LOG_HDR, "Test report_counters", scope);
      increment_expected_alerts(TB_ERROR, 8); -- report_counters calls other procedures
      sb_under_test.report_counters(VOID);

      log(ID_LOG_HDR, "Test enabling an already enabled instance", scope);
      sb_under_test.enable("Enable SB");
      increment_expected_alerts_and_stop_limit(TB_WARNING, 1);
      sb_under_test.enable("Enable SB");

      sb_under_test.reset(ALL_INSTANCES);

    end procedure test_instance_is_enabled;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);
    set_alert_stop_limit(TB_ERROR, 0);  -- 0 = Never stop

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ID_POS_ACK);
    --disable_log_msg(ID_SEQUENCER_SUB);

    log(ID_LOG_HDR_LARGE, "Start Simulation of scoreboard package", C_SCOPE);
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Test procedures
    ------------------------------------------------------------

    sb_under_test.set_scope("SB slv");
    sb_under_test.enable("Enable SB");

    --    test_add_expected;
    --    test_check_received;
    --    test_check_received_out_of_order;
    --    test_check_received_lossy;
    --    test_initial_garbage;
    --    test_overdue_time_limit;
    --    test_find;
    --    test_peek;
    --    test_fetch;
    test_insert_expected;
    --    test_insert_expected_no_tag;
    --    test_delete_expected;
    --    test_exists;
    --    test_multiple_instances;
    --    test_instance_is_enabled;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;
end architecture func;
