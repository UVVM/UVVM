--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.generic_sb_support_pkg.all;
use work.generic_sb_pkg;

-- Test case entity
entity generic_sb_record_tb is
  generic (
    GC_TEST : string := "UVVM"
    );
end entity generic_sb_record_tb;

-- Test case architecture
architecture func of generic_sb_record_tb is

  type t_input is record
    address : std_logic_vector(7 downto 0);
    data_1  : std_logic_vector(7 downto 0);
    data_2  : std_logic_vector(7 downto 0);
  end record t_input;

  type t_output is record
    address : std_logic_vector( 7 downto 0);
    data    : std_logic_vector(15 downto 0);
  end record t_output;

  function data_match(
    constant input_data  : in t_input;
    constant output_data : in t_output
  ) return boolean is
  begin
    return (input_data.address = output_data.address) and (input_data.data_1 & input_data.data_2 = output_data.data);
  end function data_match;

  function input_to_string(
    constant input_data : t_input
  ) return string is
  begin
    return "address: " & to_string(input_data.address) & ", data_1: " & to_string(input_data.data_1) & ", data_2: " & to_string(input_data.data_2);
  end function input_to_string;

  function output_to_string(
    constant output_data : t_output
  ) return string is
  begin
    return "address: " & to_string(output_data.address) & ", data: " & to_string(output_data.data);
  end function output_to_string;

  constant C_RECORD_SB_CONFIG_DEFAULT : t_sb_config := (mismatch_alert_level      => NO_ALERT,
                                                        allow_lossy               => false,
                                                        allow_out_of_order        => false,
                                                        overdue_check_alert_level => WARNING,
                                                        overdue_check_time_limit  => 0 ns,
                                                        ignore_initial_garbage    => false);

  -- Package declaration
  package record_sb_pkg is new work.generic_sb_pkg
  generic map (t_expected_element       => t_input,
               t_actual_element         => t_output,
               match                    => data_match,
               expected_to_string       => input_to_string,
               actual_to_string         => output_to_string,
               sb_config_default        => C_RECORD_SB_CONFIG_DEFAULT);

  use record_sb_pkg.all;

  shared variable sb_under_test  : record_sb_pkg.t_generic_sb;

  constant C_SCOPE     : string  := "test_bench";
  constant C_SB_SCOPE  : string  := "record_sb_scope";

  begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process

    procedure add_100_expected_elements_with_same_tag(
      constant scope : string
    ) is
      variable v_input : t_input;
    begin
      log(ID_SEQUENCER, "adding 100 expected elements with same tag", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(i, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.add_expected(v_input, TAG, "tag added", "add expected: " & to_string(i));
      end loop;
    end procedure add_100_expected_elements_with_same_tag;



    procedure add_100_expected_elements_with_different_tag(
      constant scope : string
    ) is
      variable v_input : t_input;
    begin
      log(ID_SEQUENCER, "adding 100 expected elements with different tag", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(i, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.add_expected(v_input, TAG, "tag " & to_string(i), "add expected with tag: " & to_string(i), "source " & to_string(i));
      end loop;
    end procedure add_100_expected_elements_with_different_tag;



    procedure test_add_expected is
      constant scope : string := "TB: add_expected";
    begin

      log(ID_LOG_HDR_LARGE, "Test add_expected", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      check_value(sb_under_test.is_empty(VOID),        false, ERROR, "verify SB is not empty", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count",   scope);
      check_value(sb_under_test.get_pending_count(VOID), 100, ERROR, "verify pending count",   scope);

      sb_under_test.reset(VOID);

    end procedure test_add_expected;



    procedure test_check_actual is
      constant scope    : string := "TB: check_actual";
      variable v_output : t_output;
    begin

      log(ID_LOG_HDR_LARGE, "Test check_actual", scope);

      log(ID_LOG_HDR, "checking actual data vs expected data", scope);
      add_100_expected_elements_with_same_tag(scope);
      for i in 1 to 100 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID),               ERROR, "verify SB is empty",   scope);
      check_value(sb_under_test.get_pending_count(VOID),   0, ERROR, "verify pending count", scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count", scope);
      check_value(sb_under_test.get_match_count(VOID),   100, ERROR, "verify match count",   scope);

      sb_under_test.reset(VOID);

      log(ID_LOG_HDR, "checking actual data vs expected data with wrong tag", scope);
      add_100_expected_elements_with_same_tag(scope);
      for i in 1 to 50 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(i));
      end loop;
      for i in 51 to 100 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "wrong tag", "check actual: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID),               ERROR, "verify SB is empty",    scope);
      check_value(sb_under_test.get_pending_count(VOID),   0, ERROR, "verify pending count",  scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count",  scope);
      check_value(sb_under_test.get_match_count(VOID),    50, ERROR, "verify match count",    scope);
      check_value(sb_under_test.get_mismatch_count(VOID), 50, ERROR, "verify mismatch count", scope);

      sb_under_test.reset(VOID);

    end procedure test_check_actual;



    procedure test_check_actual_out_of_order is
      constant scope : string := "TB: check_actual OOO";
      variable v_config : t_sb_config;
      variable v_output : t_output;
    begin

      log(ID_LOG_HDR_LARGE, "Test check_actual with out of order", scope);

      v_config := C_SB_CONFIG_DEFAULT;
      v_config.allow_out_of_order := true;

      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "checking actual data vs expected data", scope);
      for i in 100 downto 1 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID),               ERROR, "verify SB is empty",    scope);
      check_value(sb_under_test.get_pending_count(VOID),   0, ERROR, "verify pending count",  scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count",  scope);
      check_value(sb_under_test.get_match_count(VOID),   100, ERROR, "verify match count",    scope);
      check_value(sb_under_test.get_mismatch_count(VOID),  0, ERROR, "verify mismatch count", scope);

      sb_under_test.reset(VOID);

    end procedure test_check_actual_out_of_order;



    procedure test_check_actual_lossy is
      constant scope    : string := "TB: check_actual lossy";
      variable v_config : t_sb_config;
      variable v_output : t_output;
    begin

      log(ID_LOG_HDR_LARGE, "Test check_actual with lossy", scope);

      v_config := C_SB_CONFIG_DEFAULT;
      v_config.allow_lossy := true;

      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "checking actual data vs expected data", scope);
      for i in 51 to 100 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(i));
      end loop;

      check_value(sb_under_test.is_empty(VOID),               ERROR, "verify SB is empty",    scope);
      check_value(sb_under_test.get_pending_count(VOID),   0, ERROR, "verify pending count",  scope);
      check_value(sb_under_test.get_entered_count(VOID), 100, ERROR, "verify entered count",  scope);
      check_value(sb_under_test.get_match_count(VOID),    50, ERROR, "verify match count",    scope);
      check_value(sb_under_test.get_mismatch_count(VOID),  0, ERROR, "verify mismatch count", scope);

      sb_under_test.reset(VOID);

    end procedure test_check_actual_lossy;



    procedure test_initial_garbage is
      variable scope    : string(1 to 26);
      variable v_config : t_sb_config;
      variable v_output : t_output;
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
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking initial garbage", scope);
      for i in 2 to 100 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "initial garbage");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 1 to 50 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          50, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            50, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 52 to 100 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "check actual expect mismatch");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),           1, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            50, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         49, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      v_output.address := std_logic_vector(to_unsigned(100, 8));
      v_output.data    := std_logic_vector(to_unsigned(100, 8)) & std_logic_vector(to_unsigned(101, 8));
      sb_under_test.check_actual(v_output, "checking actual");


      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                 true, ERROR, "verify SB is empty",           scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            51, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         49, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  99, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

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
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking initial garbage", scope);
      for i in 101 to 150 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "initial garbage");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 50 downto 1 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual OOO");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          50, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            50, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual mismatch", scope);
      for i in 50 downto 1 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual OOO expect mismatch");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          50, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            50, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         50, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 100 downto 51 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual OOO");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                 true, ERROR, "verify SB is empty",           scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),           100, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         50, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

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
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking initial garbage", scope);
      for i in 101 to 150 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "initial garbage");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      v_output.address := std_logic_vector(to_unsigned(50, 8));
      v_output.data    := std_logic_vector(to_unsigned(50, 8)) & std_logic_vector(to_unsigned(51, 8));
      sb_under_test.check_actual(v_output, "checking actual lossy");

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          50, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             1, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             49, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 49 downto 1 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual lossy");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          50, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             1, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         49, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             49, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 51 to 100 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual lossy");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                 true, ERROR, "verify SB is empty",           scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            51, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         49, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             49, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  50, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset("reset SB");

    end procedure test_initial_garbage;



    procedure test_overdue_time_limit is
      constant scope    : string := "TB: overdue check";
      variable v_config : t_sb_config;
      variable v_input  : t_input;
      variable v_output : t_output;
    begin

      sb_under_test.enable_log_msg(ID_CTRL);
      sb_under_test.enable_log_msg(ID_DATA);
      set_alert_stop_limit(TB_WARNING, 1);

      log(ID_LOG_HDR, "Test overdue check", scope);

      log(ID_LOG_HDR, "set configuration", scope);
      v_config := C_SB_CONFIG_DEFAULT;
      v_config.overdue_check_alert_level := ERROR;
      v_config.overdue_check_time_limit  := 10 ns;
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "add expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "wait 9 ns", scope);
      wait for 9 ns;

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 1 to 10 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          90, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            10, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "Insert 10 expected to possition 76", scope);
      for i in 1 to 10 loop
        v_input.address := x"AA";
        v_input.data_1  := x"55";
        v_input.data_2  := x"66";
        sb_under_test.insert_expected(POSITION,   76, v_input, TAG, "inserted, " & to_string(i), "insert in position 76");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         110, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            10, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "wait 1 ns", scope);
      wait for 1 ns;

      log(ID_LOG_HDR, "checking actual", scope);
      for i in 11 to 80 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          30, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         110, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            80, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      set_alert_stop_limit(TB_WARNING, 2);
      increment_expected_alerts(TB_WARNING, 1); -- Becouse of time stamp truncate warning
      log(ID_LOG_HDR, "wait 1 ps", scope);
      wait for 1 ps;

      set_alert_stop_limit(ERROR, 6);
      increment_expected_alerts(ERROR, 5);
      log(ID_LOG_HDR, "checking actual, expecting 5 ERRORs", scope);
      for i in 81 to 85 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual");
      end loop;
      v_output.address := x"AA";
      v_output.data    := x"5566";
      for i in 86 to 90 loop
        sb_under_test.check_actual(v_output, "checking actual inserted");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          20, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         110, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            90, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);
      check_value(sb_under_test.get_overdue_check_count(VOID),     5, ERROR, "verify overdue check count",   scope);

      log(ID_LOG_HDR, "wait 10 ns", scope);
      wait for 10 ns;

      log(ID_LOG_HDR, "set configuration, overdue_check_alert_level = NO_ALERT ", scope);
      v_config := C_SB_CONFIG_DEFAULT;
      v_config.overdue_check_alert_level := NO_ALERT;
      v_config.overdue_check_time_limit  := 10 ns;
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "checking actual, expecting 20 overdue checks", scope);
      for i in 91 to 95 loop
        sb_under_test.check_actual(v_output, "checking actual inserted");
      end loop;
      for i in 86 to 100 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, "checking actual");
      end loop;

      log(ID_LOG_HDR, "check counters", scope);
      check_value(sb_under_test.is_empty(VOID),                 true, ERROR, "verify SB is empty",           scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         110, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),           110, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);
      check_value(sb_under_test.get_overdue_check_count(VOID),    25, ERROR, "verify overdue check count",   scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset("reset SB");

    end procedure test_overdue_time_limit;



    procedure test_find is
      constant scope    : string := "TB: find";
      variable v_config : t_sb_config;
      variable v_input : t_input;

      procedure add_data is
        variable v_input : t_input;
      begin
        for i in 1 to 10 loop
        v_input.address := std_logic_vector(to_unsigned(i, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(i, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.add_expected(v_input, "Add expected " & to_string(i) & " without tag"); -- entry num 1 to 10
        end loop;
        v_input.address := std_logic_vector(to_unsigned(11, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(11, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(12, 8));
        sb_under_test.add_expected(v_input, "Add expected 11 without tag"); -- entry num 11
        sb_under_test.add_expected(v_input, "Add expected 11 without tag"); -- entry num 12
        for i in 13 to 20 loop
          v_input.address := std_logic_vector(to_unsigned(i, 8));
          v_input.data_1  := std_logic_vector(to_unsigned(i, 8));
          v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
          sb_under_test.add_expected(v_input, TAG, "same tag", "Add expected " & to_string(i) & " with tag 'same tag'"); -- entry num 13 to 20
        end loop;
        for i in 21 to 30 loop
          v_input.address := std_logic_vector(to_unsigned(21, 8));
          v_input.data_1  := std_logic_vector(to_unsigned(21, 8));
          v_input.data_2  := std_logic_vector(to_unsigned(22, 8));
          sb_under_test.add_expected(v_input, TAG, "tag " & to_string(i), "Add expected " & expected_to_string(v_input) & " with tag 'tag " & to_string(i) & "'"); -- entry num 21 to 30
        end loop;
      end procedure add_data;

      procedure check_position is
        variable v_input : t_input;
      begin
        v_input.address := std_logic_vector(to_unsigned(1, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(1, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(2, 8));
        check_value(sb_under_test.find_expected_position(v_input),  1, ERROR, "expect position 1",  scope);
        check_value(sb_under_test.find_expected_position(v_input),  1, ERROR, "expect position 1",  scope);
        v_input.address := std_logic_vector(to_unsigned(11, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(11, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(12, 8));
        check_value(sb_under_test.find_expected_position(v_input), 11, ERROR, "expect position 11", scope);
        check_value(sb_under_test.find_expected_position(TAG, "same tag"),                      13, ERROR, "expect position 13", scope);
        for i in 21 to 30 loop
          check_value(sb_under_test.find_expected_position(TAG, "tag " & to_string(i)), i, ERROR, "expect position " & to_string(i), scope);
        end loop;
        v_input.address := std_logic_vector(to_unsigned(21, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(21, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(22, 8));
        check_value(sb_under_test.find_expected_position(v_input, TAG, "tag 27"), 27, ERROR, "expect position 27", scope);
        v_input.address := std_logic_vector(to_unsigned(23, 8));
        v_input.data_1  := std_logic_vector(to_unsigned(23, 8));
        v_input.data_2  := std_logic_vector(to_unsigned(24, 8));
        check_value(sb_under_test.find_expected_position(v_input, TAG, "tag 24"), -1, ERROR, "expect no match found", scope);
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
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         30, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         30, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check find_expected_position()", scope);
      check_position;

      log(ID_LOG_HDR, "check counters after find_expected_position()", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         30, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         30, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check find_expected_entry_num()", scope);
      v_input.address := std_logic_vector(to_unsigned(1, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(1, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(2, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input),  1, ERROR, "expect entry number 1",  scope);
      check_value(sb_under_test.find_expected_entry_num(v_input),  1, ERROR, "expect entry number 1",  scope);
      v_input.address := std_logic_vector(to_unsigned(11, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(11, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(12, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input), 11, ERROR, "expect entry number 11", scope);
      check_value(sb_under_test.find_expected_entry_num(TAG, "same tag"),                      13, ERROR, "expect entry number 13", scope);
      for i in 21 to 30 loop
        check_value(sb_under_test.find_expected_entry_num(TAG, "tag " & to_string(i)), i, ERROR, "expect entry number " & to_string(i), scope);
      end loop;
      v_input.address := std_logic_vector(to_unsigned(21, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(21, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(22, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input, TAG, "tag 27"), 27, ERROR, "expect entry number 27", scope);
      v_input.address := std_logic_vector(to_unsigned(23, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(23, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(24, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input, TAG, "tag 24"), -1, ERROR, "expect no match found", scope);

      log(ID_LOG_HDR, "check counters after find_expected_entry_num()", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         30, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         30, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      sb_under_test.flush("Flush SB");

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "adding expected data", scope);
      add_data;

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         30, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         60, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          30, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check find_expected_position()", scope);
      check_position;

      log(ID_LOG_HDR, "check counters after find_expected_position()", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         30, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         60, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          30, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check find_expected_entry_num()", scope);
      v_input.address := std_logic_vector(to_unsigned(1, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(1, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(2, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input), 31, ERROR, "expect entry number 31", scope);
      check_value(sb_under_test.find_expected_entry_num(v_input), 31, ERROR, "expect entry number 31", scope);
      v_input.address := std_logic_vector(to_unsigned(11, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(11, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(12, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input),        41, ERROR, "expect entry number 41", scope);
      check_value(sb_under_test.find_expected_entry_num(TAG, "same tag"), 43, ERROR, "expect entry number 43", scope);
      for i in 21 to 30 loop
        check_value(sb_under_test.find_expected_entry_num(TAG, "tag " & to_string(i)), 30+i, ERROR, "expect entry number " & to_string(30+i), scope);
      end loop;
      v_input.address := std_logic_vector(to_unsigned(21, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(21, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(22, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input, TAG, "tag 27"), 57, ERROR, "expect entry number 57", scope);
      v_input.address := std_logic_vector(to_unsigned(23, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(23, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(24, 8));
      check_value(sb_under_test.find_expected_entry_num(v_input, TAG, "tag 24"), -1, ERROR, "expect no match found", scope);

      log(ID_LOG_HDR, "check counters after find_expected_entry_num()", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         30, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         60, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          30, ERROR, "verify delete count",          scope);

      sb_under_test.reset("reset SB");

    end procedure test_find;



    procedure test_peek is
      constant scope    : string := "TB: peek";
      variable v_config : t_sb_config;
      variable v_input  : t_input;
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
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),        100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check peek with position 1", scope);
      v_input.address := std_logic_vector(to_unsigned(1, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(1, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(2, 8));
      check_value(sb_under_test.peek_expected(VOID) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.peek_expected(POSITION, i) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
        check_value(sb_under_test.peek_source(POSITION, i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(POSITION, i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check peek with entry number 1", scope);
      v_input.address := std_logic_vector(to_unsigned(1, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(1, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(2, 8));
      check_value(sb_under_test.peek_expected(VOID) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.peek_expected(ENTRY_NUM, i) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
        check_value(sb_under_test.peek_source(ENTRY_NUM, i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(ENTRY_NUM, i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),        100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      sb_under_test.flush("flushing SB");

      log(ID_LOG_HDR, "adding expected data 2", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),        100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        200, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),         100, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check peek with position 2", scope);
      v_input.address := std_logic_vector(to_unsigned(1, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(1, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(2, 8));
      check_value(sb_under_test.peek_expected(VOID) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.peek_expected(POSITION, i) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
        check_value(sb_under_test.peek_source(POSITION, i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(POSITION, i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check peek with entry number 2", scope);
      v_input.address := std_logic_vector(to_unsigned(1, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(1, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(2, 8));
      check_value(sb_under_test.peek_expected(VOID) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      check_value(sb_under_test.peek_source(VOID), "source 1", ERROR, "source 1", scope);
      check_value(sb_under_test.peek_tag(VOID), "tag 1", ERROR, "tag 1", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.peek_expected(ENTRY_NUM, 100+i) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
        check_value(sb_under_test.peek_source(ENTRY_NUM, 100+i), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
        check_value(sb_under_test.peek_tag(ENTRY_NUM, 100+i), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),        100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        200, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),         100, ERROR, "verify delete count",          scope);

      sb_under_test.reset("reseting SB");

    end procedure test_peek;



    procedure test_fetch is
      constant scope    : string := "TB: fetch";
      variable v_config : t_sb_config;
      variable v_input  : t_input;
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
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),            0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.fetch_expected("fetch nr. " & to_string(i)) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          100, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         200, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          100, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_source("fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         200, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          200, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         300, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          200, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_tag("tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         300, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          300, ERROR, "verify delete count",          scope);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "check fetch from back by position", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         400, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          300, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 100 downto 1 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.fetch_expected(POSITION, i, "fetch nr. " & to_string(i)) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         400, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          400, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         500, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          400, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_source(POSITION, i, "fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         500, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          500, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         600, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          500, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_tag(POSITION, i, "tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         600, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          600, ERROR, "verify delete count",          scope);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "check fetch from back by entry number", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         700, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          600, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 100 downto 1 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.fetch_expected(ENTRY_NUM, 600+i, "fetch nr. " & to_string(i)) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         700, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          700, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         800, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          700, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_source(ENTRY_NUM, 700+i, "fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         800, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          800, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         900, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          800, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 100 downto 1 loop
        check_value(sb_under_test.fetch_tag(ENTRY_NUM, 800+i, "tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),           0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         900, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),             0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),          0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),              0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),   0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          900, ERROR, "verify delete count",          scope);

      -----------------------------------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "check fetch from front by entry number", scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         1000, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),              0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),           0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),               0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),    0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           900, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch expected", scope);
      for i in 1 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.fetch_expected(ENTRY_NUM, 900+i, "fetch nr. " & to_string(i)) = v_input, ERROR, "expect " & expected_to_string(v_input), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                 true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),            0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         1000, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),              0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),           0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),               0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),    0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          1000, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                 false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         1100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),              0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),           0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),               0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),    0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          1000, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch source", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_source(ENTRY_NUM, 1000+i, "fetch nr. " & to_string(i)), "source " & to_string(i), ERROR, "source " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                 true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),            0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         1100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),              0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),           0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),               0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),    0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          1100, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_different_tag(scope);

      log(ID_LOG_HDR, "check counters after adding expected", scope);
      check_value(sb_under_test.is_empty(VOID),                 false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),          100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         1200, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),              0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),           0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),               0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),    0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          1100, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "fetch tag", scope);
      for i in 1 to 100 loop
        check_value(sb_under_test.fetch_tag(ENTRY_NUM, 1100+i, "tag nr. " & to_string(i)), "tag " & to_string(i), ERROR, "tag " & to_string(i), scope);
      end loop;

      log(ID_LOG_HDR, "check counters after fetch", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",            scope);
      check_value(sb_under_test.get_pending_count(VOID),            0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),         1200, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),              0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),           0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),               0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),    0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          1200, ERROR, "verify delete count",          scope);

      -----------------------------------------------------------------------------------------------------------------

      sb_under_test.reset("reseting SB");

    end procedure test_fetch;



    procedure test_insert_expected is
      constant scope    : string := "TB: insert_expected";
      variable v_config : t_sb_config;
      variable v_input  : t_input;
      variable v_output : t_output;
    begin

      log(ID_LOG_HDR_LARGE, "Test insert_expected", scope);

      sb_under_test.disable_log_msg(ID_DATA);

      v_config := C_SB_CONFIG_DEFAULT;
      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "check counters before inserts", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),        100, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        100, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "Insert expected", scope);
      v_input.address := x"AA";
      v_input.data_1  := x"AA";
      v_input.data_2  := x"BB";
      sb_under_test.insert_expected(POSITION,   2, v_input, TAG, "inserted, 1", "insert in position 2");
      v_input.address := x"BB";
      v_input.data_1  := x"BB";
      v_input.data_2  := x"CC";
      sb_under_test.insert_expected(ENTRY_NUM, 50, v_input, TAG, "inserted, 2", "insert after entry number 50");
      v_input.address := x"CC";
      v_input.data_1  := x"CC";
      v_input.data_2  := x"DD";
      sb_under_test.insert_expected(POSITION, 102, v_input, TAG, "inserted, 3", "insert in position 102");

      log(ID_LOG_HDR, "check counters after inserts", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),        103, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        103, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check expected", scope);
      v_output.address := std_logic_vector(to_unsigned(1, 8));
      v_output.data    := std_logic_vector(to_unsigned(1, 8)) & std_logic_vector(to_unsigned(2, 8));
      sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(1));
      v_output.address := x"AA";
      v_output.data    := x"AABB";
      sb_under_test.check_actual(v_output, TAG, "inserted, 1", "check actual: inserted element 1");
      for i in 2 to 50 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(i));
      end loop;
      v_output.address := x"BB";
      v_output.data    := x"BBCC";
      sb_under_test.check_actual(v_output, TAG, "inserted, 2", "check actual: inserted element 2");
      for i in 51 to 99 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(i));
      end loop;
      v_output.address := x"CC";
      v_output.data    := x"CCDD";
      sb_under_test.check_actual(v_output, TAG, "inserted, 3", "check actual: inserted element 3");
      v_output.address := std_logic_vector(to_unsigned(100, 8));
      v_output.data    := std_logic_vector(to_unsigned(100, 8)) & std_logic_vector(to_unsigned(101, 8));
      sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & to_string(100));

      log(ID_LOG_HDR, "check counters after check_expected", scope);
      check_value(sb_under_test.is_empty(VOID),                      ERROR, "verify SB is empty",           scope);
      check_value(sb_under_test.get_pending_count(VOID),          0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        103, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),          103, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      sb_under_test.report_counters(ALL_ENABLED_INSTANCES);
      sb_under_test.report_counters(VOID);

      sb_under_test.reset(VOID);

    end procedure test_insert_expected;

    procedure test_delete_expected is
      constant scope    : string := "TB: delete_expected";
      variable v_config : t_sb_config;
      variable v_input  : t_input;
      variable v_output : t_output;
    begin

      log(ID_LOG_HDR_LARGE, "Test delete_expected", scope);

      sb_under_test.enable_log_msg(ID_DATA);

      v_config := C_SB_CONFIG_DEFAULT;
      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config);

      log(ID_LOG_HDR, "adding expected data", scope);
      add_100_expected_elements_with_same_tag(scope);

      log(ID_LOG_HDR, "Insert expected", scope);
      v_input.address := x"AA";
      v_input.data_1  := x"AA";
      v_input.data_2  := x"BB";
      sb_under_test.insert_expected(POSITION,   7, v_input, TAG, "inserted 1", "insert in position 7");
      v_input.address := x"BB";
      v_input.data_1  := x"BB";
      v_input.data_2  := x"CC";
      sb_under_test.insert_expected(ENTRY_NUM, 34, v_input, TAG, "inserted 2", "insert after entry number 34");
      v_input.address := x"CC";
      v_input.data_1  := x"CC";
      v_input.data_2  := x"DD";
      sb_under_test.insert_expected(POSITION,  99, v_input, TAG, "inserted 3", "insert in position 99");

      log(ID_LOG_HDR, "check counters after inserts", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),        103, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        103, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),           0, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "Delete expected", scope);
      sb_under_test.delete_expected( POSITION, 103, SINGLE, "delete back entry");
      sb_under_test.delete_expected( POSITION,   2, SINGLE, "delete position 2");
      sb_under_test.delete_expected(ENTRY_NUM,   5, SINGLE, "delete entry number 5");
      sb_under_test.delete_expected(v_input, "delete expected xCC");
      v_input.address := std_logic_vector(to_unsigned(76, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(76, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(77, 8));
      sb_under_test.delete_expected(v_input, TAG, "tag added", "delete expected value 76 with tag");
      sb_under_test.delete_expected(TAG, "tag added", "delete tag 'tag added', should delete first element in queue");
      sb_under_test.delete_expected( POSITION, 81, 85, "delete position 81-85");
      sb_under_test.delete_expected(ENTRY_NUM, 91, 95, "delete entry number 91-95");

      log(ID_LOG_HDR, "check counters after delete", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         87, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        103, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          16, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "Delete expected that don't match", scope);
      increment_expected_alerts(TB_ERROR, 3);
      sb_under_test.delete_expected(ENTRY_NUM, 93, SINGLE, "delete entry number 93");
      sb_under_test.delete_expected(POSITION, 110, SINGLE, "delete position 110");
      v_input.address := std_logic_vector(to_unsigned(78, 8));
      v_input.data_1  := std_logic_vector(to_unsigned(78, 8));
      v_input.data_2  := std_logic_vector(to_unsigned(79, 8));
      sb_under_test.delete_expected(v_input, TAG, "tag not added", "delete expected x76 with not matching tag");

      log(ID_LOG_HDR, "check counters after delete", scope);
      check_value(sb_under_test.is_empty(VOID),               false, ERROR, "verify SB is not empty",       scope);
      check_value(sb_under_test.get_pending_count(VOID),         87, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        103, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),            0, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          16, ERROR, "verify delete count",          scope);

      log(ID_LOG_HDR, "check expected", scope);
      v_output.address := std_logic_vector(to_unsigned(3, 8));
      v_output.data    := std_logic_vector(to_unsigned(3, 8)) & std_logic_vector(to_unsigned(4, 8));
      sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      v_output.address := std_logic_vector(to_unsigned(4, 8));
      v_output.data    := std_logic_vector(to_unsigned(4, 8)) & std_logic_vector(to_unsigned(5, 8));
      sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      v_output.address := std_logic_vector(to_unsigned(6, 8));
      v_output.data    := std_logic_vector(to_unsigned(6, 8)) & std_logic_vector(to_unsigned(7, 8));
      sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      v_output.address := x"AA";
      v_output.data    := x"AABB";
      sb_under_test.check_actual(v_output, TAG, "inserted 1", "check actual: xAA, inserted 1");
      for i in 7 to 34 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      end loop;
      v_output.address := x"BB";
      v_output.data    := x"BBCC";
      sb_under_test.check_actual(v_output, TAG, "inserted 2", "check actual: xBB, inserted 2");
      for i in 35 to 75 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      end loop;
      for i in 77 to 82 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      end loop;
      for i in 88 to 90 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      end loop;
      for i in 96 to 99 loop
        v_output.address := std_logic_vector(to_unsigned(i, 8));
        v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
        sb_under_test.check_actual(v_output, TAG, "tag added", "check actual: " & actual_to_string(v_output));
      end loop;

      log(ID_LOG_HDR, "check counters after check", scope);
      check_value(sb_under_test.is_empty(VOID),                true, ERROR, "verify SB is empty",           scope);
      check_value(sb_under_test.get_pending_count(VOID),          0, ERROR, "verify pending count",         scope);
      check_value(sb_under_test.get_entered_count(VOID),        103, ERROR, "verify entered count",         scope);
      check_value(sb_under_test.get_match_count(VOID),           87, ERROR, "verify match count",           scope);
      check_value(sb_under_test.get_mismatch_count(VOID),         0, ERROR, "verify mismatch count",        scope);
      check_value(sb_under_test.get_drop_count(VOID),             0, ERROR, "verify drop count",            scope);
      check_value(sb_under_test.get_initial_garbage_count(VOID),  0, ERROR, "verify initial garbage count", scope);
      check_value(sb_under_test.get_delete_count(VOID),          16, ERROR, "verify delete count",          scope);

      sb_under_test.report_counters(VOID);

      sb_under_test.reset(VOID);

    end procedure test_delete_expected;



    procedure test_exists is
      constant scope    : string := "TB: exists";
      variable v_config : t_sb_config;
      variable v_input  : t_input;
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
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.exists(v_input), ERROR, "without tag");
      end loop;

      log(ID_LOG_HDR, "exists only tag", scope);
      check_value(sb_under_test.exists(TAG, "tag added"), ERROR, "with only tag");
      check_value(sb_under_test.exists(TAG, "wrong tag"), false, ERROR, "with only tag");

      for i in 51 to 100 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.exists(v_input, TAG, "tag added"), ERROR, "with value " & expected_to_string(v_input) & " and tag 'tag added'");
      end loop;

      for i in 101 to 150 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.exists(v_input), false, ERROR, "without tag");
      end loop;

      for i in 1 to 50 loop
        v_input.address := std_logic_vector(to_unsigned(i,   8));
        v_input.data_1  := std_logic_vector(to_unsigned(i,   8));
        v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
        check_value(sb_under_test.exists(v_input, TAG, "wrong tag"), false, ERROR, "without tag");
      end loop;

      sb_under_test.reset(VOID);

    end procedure test_exists;



    procedure test_multiple_instances is
      constant scope          : string := "TB: multiple instances";
      variable v_config_array : t_sb_config_array(1 to 100) := (others => C_SB_CONFIG_DEFAULT);
      variable v_input        : t_input;
      variable v_output       : t_output;
    begin

      log(ID_LOG_HDR_LARGE, "Test multiple instances", scope);

      sb_under_test.disable_log_msg(ALL_INSTANCES, ID_DATA);
      disable_log_msg(ID_POS_ACK);

      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config_array);

      log(ID_LOG_HDR_LARGE, "add_expected", scope);
      for instance in 1 to 100 loop
        sb_under_test.enable(instance);
        for i in 1 to 100 loop
          v_input.address := std_logic_vector(to_unsigned(i, 8));
          v_input.data_1  := std_logic_vector(to_unsigned(i, 8));
          v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
          sb_under_test.add_expected(instance, v_input, TAG, "tag added");
        end loop;
      end loop;

      log(ID_LOG_HDR_LARGE, "insert_expected", scope);
      for instance in 1 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        sb_under_test.insert_expected(instance, POSITION, 3, v_input, TAG, "tag inserted pos");
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        sb_under_test.insert_expected(instance, ENTRY_NUM, 6, v_input, TAG, "tag inserted entry num 1");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 6, v_input, TAG, "tag inserted entry num 2");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 7, v_input, TAG, "tag inserted entry num 3");
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        sb_under_test.insert_expected(instance, ENTRY_NUM, 10, v_input, TAG, "tag inserted entry num 4");
      end loop;

      log(ID_LOG_HDR_LARGE, "find_expected_position/entry_num", scope);
      for instance in 1 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        check_value(sb_under_test.find_expected_position(instance, v_input), 3, ERROR, "check position", scope);
        check_value(sb_under_test.find_expected_entry_num(instance, v_input), 101, ERROR, "check entry num", scope);
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        check_value(sb_under_test.find_expected_position(instance, v_input), 8, ERROR, "check position", scope);
        check_value(sb_under_test.find_expected_entry_num(instance, v_input), 103, ERROR, "check entry num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "peek_expected", scope);
      for instance in 1 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        check_value(sb_under_test.peek_expected(instance, POSITION, 3) = v_input, ERROR, "peek position", scope);
        check_value(sb_under_test.peek_tag(instance, POSITION, 3), "tag inserted pos", ERROR, "peek position", scope);
        check_value(sb_under_test.peek_expected(instance, ENTRY_NUM, 101) = v_input, ERROR, "peek entry_num", scope);
        check_value(sb_under_test.peek_tag(instance,  ENTRY_NUM, 104), "tag inserted entry num 3", ERROR, "peek entry_num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "fetch_expected", scope);
      for instance in 1 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        check_value(sb_under_test.fetch_expected(instance, POSITION, 3) = v_input, ERROR, "fetch position", scope);
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        check_value(sb_under_test.fetch_expected(instance, ENTRY_NUM, 103) = v_input, ERROR, "fetch entry_num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "delete_expected", scope);
      for instance in 1 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        sb_under_test.delete_expected(instance, v_input, TAG, "tag inserted entry num 4");
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        sb_under_test.delete_expected(instance, v_input);
        sb_under_test.delete_expected(instance, TAG, "tag inserted entry num 3");
      end loop;


      log(ID_LOG_HDR_LARGE, "check_actual", scope);
      for instance in 1 to 100 loop
        for i in 1 to 101-instance loop
          v_output.address := std_logic_vector(to_unsigned(i, 8));
          v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
          sb_under_test.check_actual(instance, v_output, TAG, "tag added");
        end loop;
      end loop;

      log(ID_LOG_HDR, "check counters after check", scope);
      for instance in 1 to 10 loop
        check_value(sb_under_test.is_empty(instance),                  instance = 1, ERROR, "verify SB is empty",           scope);
        check_value(sb_under_test.get_pending_count(instance),           instance-1, ERROR, "verify pending count",         scope);
        check_value(sb_under_test.get_entered_count(instance),                  105, ERROR, "verify entered count",         scope);
        check_value(sb_under_test.get_match_count(instance),           101-instance, ERROR, "verify match count",           scope);
        check_value(sb_under_test.get_mismatch_count(instance),                   0, ERROR, "verify mismatch count",        scope);
        check_value(sb_under_test.get_drop_count(instance),                       0, ERROR, "verify drop count",            scope);
        check_value(sb_under_test.get_initial_garbage_count(instance),            0, ERROR, "verify initial garbage count", scope);
        check_value(sb_under_test.get_delete_count(instance),                     5, ERROR, "verify delete count",          scope);
        check_value(sb_under_test.get_overdue_check_count(instance),              0, ERROR, "verify delete count",          scope);
      end loop;

      sb_under_test.report_counters(ALL_INSTANCES);

      sb_under_test.reset(ALL_INSTANCES);

    end procedure test_multiple_instances;



    -- run multiple instance test with index 0 (default=1)
    procedure test_instance_index_0 is
      constant scope          : string := "TB: instance index 0";
      variable v_config_array : t_sb_config_array(0 to 100) := (others => C_SB_CONFIG_DEFAULT);
      variable v_input        : t_input;
      variable v_output       : t_output;
    begin

      log(ID_LOG_HDR_LARGE, "Test instance index 0", scope);

      sb_under_test.disable_log_msg(ALL_INSTANCES, ID_DATA);
      disable_log_msg(ID_POS_ACK);

      log(ID_LOG_HDR, "set configuration", scope);
      sb_under_test.config(v_config_array);

      log(ID_LOG_HDR_LARGE, "add_expected", scope);
      for instance in 0 to 100 loop
        sb_under_test.enable(instance);
        for i in 0 to 100 loop
          v_input.address := std_logic_vector(to_unsigned(i, 8));
          v_input.data_1  := std_logic_vector(to_unsigned(i, 8));
          v_input.data_2  := std_logic_vector(to_unsigned(i+1, 8));
          sb_under_test.add_expected(instance, v_input, TAG, "tag added");
        end loop;
      end loop;

      log(ID_LOG_HDR_LARGE, "insert_expected", scope);
      for instance in 0 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        sb_under_test.insert_expected(instance, POSITION, 3, v_input, TAG, "tag inserted pos");
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        sb_under_test.insert_expected(instance, ENTRY_NUM, 6, v_input, TAG, "tag inserted entry num 1");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 6, v_input, TAG, "tag inserted entry num 2");
        sb_under_test.insert_expected(instance, ENTRY_NUM, 7, v_input, TAG, "tag inserted entry num 3");
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        sb_under_test.insert_expected(instance, ENTRY_NUM, 10, v_input, TAG, "tag inserted entry num 4");
      end loop;

      log(ID_LOG_HDR_LARGE, "find_expected_position/entry_num", scope);
      for instance in 0 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        check_value(sb_under_test.find_expected_position(instance, v_input), 3, ERROR, "check position", scope);
        check_value(sb_under_test.find_expected_entry_num(instance, v_input), 102, ERROR, "check entry num", scope);
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        check_value(sb_under_test.find_expected_position(instance, v_input), 8, ERROR, "check position", scope);
        check_value(sb_under_test.find_expected_entry_num(instance, v_input), 104, ERROR, "check entry num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "peek_expected", scope);
      for instance in 0 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        check_value(sb_under_test.peek_expected(instance, POSITION, 3) = v_input, ERROR, "peek position", scope);
        check_value(sb_under_test.peek_tag(instance, POSITION, 3), "tag inserted pos", ERROR, "peek position", scope);
        check_value(sb_under_test.peek_expected(instance, ENTRY_NUM, 102) = v_input, ERROR, "peek entry_num", scope);
        check_value(sb_under_test.peek_tag(instance,  ENTRY_NUM, 105), "tag inserted entry num 3", ERROR, "peek entry_num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "fetch_expected", scope);
      for instance in 0 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        check_value(sb_under_test.fetch_expected(instance, POSITION, 3) = v_input, ERROR, "fetch position", scope);
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        check_value(sb_under_test.fetch_expected(instance, ENTRY_NUM, 103) = v_input, ERROR, "fetch entry_num", scope);
      end loop;

      log(ID_LOG_HDR_LARGE, "delete_expected", scope);
      for instance in 0 to 100 loop
        v_input.address := x"AA";
        v_input.data_1  := x"AA";
        v_input.data_2  := x"BB";
        sb_under_test.delete_expected(instance, v_input, TAG, "tag inserted entry num 4");
        v_input.address := x"BB";
        v_input.data_1  := x"BB";
        v_input.data_2  := x"CC";
        sb_under_test.delete_expected(instance, v_input);
        sb_under_test.delete_expected(instance, TAG, "tag inserted entry num 3");
      end loop;


      log(ID_LOG_HDR_LARGE, "check_actual", scope);
      for instance in 0 to 100 loop
        for i in 0 to 100-instance loop
          v_output.address := std_logic_vector(to_unsigned(i, 8));
          v_output.data    := std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i+1, 8));
          sb_under_test.check_actual(instance, v_output, TAG, "tag added");
        end loop;
      end loop;

      log(ID_LOG_HDR, "check counters after check", scope);
      for instance in 0 to 10 loop
        check_value(sb_under_test.is_empty(instance),                  instance = 0, ERROR, "verify SB is empty",           scope);
        check_value(sb_under_test.get_pending_count(instance),             instance, ERROR, "verify pending count",         scope);
        check_value(sb_under_test.get_entered_count(instance),                  106, ERROR, "verify entered count",         scope);
        check_value(sb_under_test.get_match_count(instance),           101-instance, ERROR, "verify match count",           scope);
        check_value(sb_under_test.get_mismatch_count(instance),                   0, ERROR, "verify mismatch count",        scope);
        check_value(sb_under_test.get_drop_count(instance),                       0, ERROR, "verify drop count",            scope);
        check_value(sb_under_test.get_initial_garbage_count(instance),            0, ERROR, "verify initial garbage count", scope);
        check_value(sb_under_test.get_delete_count(instance),                     5, ERROR, "verify delete count",          scope);
        check_value(sb_under_test.get_overdue_check_count(instance),              0, ERROR, "verify delete count",          scope);
      end loop;

      sb_under_test.report_counters(ALL_INSTANCES);

      sb_under_test.reset(ALL_INSTANCES);

    end procedure test_instance_index_0;




  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);
    set_alert_stop_limit(TB_ERROR, 0);    -- 0 = Never stop

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ID_POS_ACK);
    --disable_log_msg(ID_SEQUENCER_SUB);

    log(ID_LOG_HDR_LARGE, "Start Simulation of scoreboard package with record", C_SCOPE);
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Test procedures
    ------------------------------------------------------------

    sb_under_test.set_scope("SB record");
    sb_under_test.enable("Enable SB");

    test_add_expected;
    test_check_actual;
    test_check_actual_out_of_order;
    test_check_actual_lossy;
    test_initial_garbage;
    test_overdue_time_limit;
    test_find;
    test_peek;
    test_fetch;
    test_insert_expected;
    test_delete_expected;
    test_exists;
    test_multiple_instances;
    test_instance_index_0;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;
end architecture func;