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
-- Inspired by similar functionality in SystemVerilog and OSVVM.
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------
--==========================================================================================
--  bin_name_association_list_pkg
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bin_name_association_list_pkg is new work.association_list_pkg
  generic map(
    GC_SCOPE      => "bin_name_association_list_pkg",
    GC_KEY_TYPE   => string,
    GC_VALUE_TYPE => natural
  );

--==========================================================================================
--  func_cov_pkg
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.string_methods_pkg.all;
use work.global_signals_and_shared_variables_pkg.all;
use work.methods_pkg.all;
use work.rand_pkg.all;
use work.vendor_func_cov_extension_pkg.all;
use work.bin_name_association_list_pkg.all;

package func_cov_pkg is

  constant C_MAX_NUM_CROSS_BINS : positive := 16;

  ------------------------------------------------------------
  -- Types
  ------------------------------------------------------------
  type t_report_verbosity is (NON_VERBOSE, VERBOSE, HOLES_ONLY);
  type t_rand_weight_visibility is (SHOW_RAND_WEIGHT, HIDE_RAND_WEIGHT);
  type t_coverage_type is (BINS, HITS, BINS_AND_HITS);
  type t_overall_coverage_type is (COVPTS, BINS, HITS);
  type t_rand_sample_cov is (SAMPLE_COV, NO_SAMPLE_COV);
  type t_new_bins_acceptance is (NO_ALERT_ON_NEW_BINS, WARNING_ON_NEW_BINS, ERROR_ON_NEW_BINS);
  type t_cov_bin_type is (VAL, VAL_IGNORE, VAL_ILLEGAL, RAN, RAN_IGNORE, RAN_ILLEGAL, TRN, TRN_IGNORE, TRN_ILLEGAL);

  type t_new_bin is record
    contains   : t_cov_bin_type;
    values     : integer_vector(0 to C_FC_MAX_NUM_BIN_VALUES - 1);
    num_values : natural range 0 to C_FC_MAX_NUM_BIN_VALUES;
  end record;
  type t_new_bin_vector is array (natural range <>) of t_new_bin;

  type t_new_cov_bin is record
    bin_vector : t_new_bin_vector(0 to C_FC_MAX_NUM_NEW_BINS - 1);
    num_bins   : natural range 0 to C_FC_MAX_NUM_NEW_BINS;
    proc_call  : string(1 to C_FC_MAX_PROC_CALL_LENGTH);
  end record;
  type t_new_bin_array is array (natural range <>) of t_new_cov_bin;
  constant C_EMPTY_NEW_BIN_ARRAY : t_new_bin_array(0 to 0) := (0 => ((0 to C_FC_MAX_NUM_NEW_BINS - 1 => (VAL, (others => 0), 0)),
                                                                     0,
                                                                     (1 to C_FC_MAX_PROC_CALL_LENGTH => NUL)));

  type t_bin is record
    contains   : t_cov_bin_type;
    values     : integer_vector(0 to C_FC_MAX_NUM_BIN_VALUES - 1);
    num_values : natural range 0 to C_FC_MAX_NUM_BIN_VALUES;
  end record;
  type t_bin_vector is array (natural range <>) of t_bin;

  type t_cov_bin is record
    cross_bins      : t_bin_vector(0 to C_MAX_NUM_CROSS_BINS - 1);
    hits            : natural;
    min_hits        : natural;
    rand_weight     : integer;
    transition_mask : std_logic_vector(C_FC_MAX_NUM_BIN_VALUES - 1 downto 0);
    name            : string(1 to C_FC_MAX_NAME_LENGTH);
    ucdb_index      : t_ucdb_bin_index;
  end record;
  type t_cov_bin_vector is array (natural range <>) of t_cov_bin;
  type t_cov_bin_vector_ptr is access t_cov_bin_vector;

  ------------------------------------------------------------
  -- Bin functions
  ------------------------------------------------------------
  -- Creates a bin for a single value
  impure function bin(
    constant value : integer)
  return t_new_bin_array;

  -- Creates a bin for multiple values
  impure function bin(
    constant set_of_values : integer_vector)
  return t_new_bin_array;

  -- Creates a bin for a range of values. Several bins can be created by dividing the range into num_bins.
  -- If num_bins is 0 then a bin is created for each value.
  impure function bin_range(
    constant min_value : integer;
    constant max_value : integer;
    constant num_bins  : natural := 1)
  return t_new_bin_array;

  -- Creates a bin for a vector's range. Several bins can be created by dividing the range into num_bins.
  -- If num_bins is 0 then a bin is created for each value.
  impure function bin_vector(
    constant vector   : std_logic_vector;
    constant num_bins : natural := 1)
  return t_new_bin_array;

  -- Creates a bin for a transition of values
  impure function bin_transition(
    constant set_of_values : integer_vector)
  return t_new_bin_array;

  -- Creates an ignore bin for a single value
  impure function ignore_bin(
    constant value : integer)
  return t_new_bin_array;

  -- Creates an ignore bin for a range of values
  impure function ignore_bin_range(
    constant min_value : integer;
    constant max_value : integer)
  return t_new_bin_array;

  -- Creates an ignore bin for a transition of values
  impure function ignore_bin_transition(
    constant set_of_values : integer_vector)
  return t_new_bin_array;

  -- Creates an illegal bin for a single value
  impure function illegal_bin(
    constant value : integer)
  return t_new_bin_array;

  -- Creates an illegal bin for a range of values
  impure function illegal_bin_range(
    constant min_value : integer;
    constant max_value : integer)
  return t_new_bin_array;

  -- Creates an illegal bin for a transition of values
  impure function illegal_bin_transition(
    constant set_of_values : integer_vector)
  return t_new_bin_array;

  ------------------------------------------------------------
  -- Overall coverage
  ------------------------------------------------------------
  procedure fc_set_covpts_coverage_goal(
    constant percentage   : in positive range 1 to 100;
    constant scope        : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

  impure function fc_get_covpts_coverage_goal(
    constant VOID : t_void)
  return positive;

  impure function fc_get_overall_coverage(
    constant coverage_type : t_overall_coverage_type)
  return real;

  impure function fc_overall_coverage_completed(
    constant VOID : t_void)
  return boolean;

  procedure fc_report_overall_coverage(
    constant VOID : in t_void);

  procedure fc_report_overall_coverage(
    constant verbosity : in t_report_verbosity;
    constant file_name : in string         := "";
    constant open_mode : in file_open_kind := append_mode;
    constant scope     : in string         := C_TB_SCOPE_DEFAULT);

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_coverpoint is protected

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_name(
      constant name : in string);

    impure function get_name(
      constant VOID : t_void)
    return string;

    procedure set_scope(
      constant scope : in string);

    impure function get_scope(
      constant VOID : t_void)
    return string;

    procedure set_overall_coverage_weight(
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_overall_coverage_weight(
      constant VOID : t_void)
    return natural;

    procedure set_bins_coverage_goal(
      constant percentage   : in positive range 1 to 100;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_bins_coverage_goal(
      constant VOID : t_void)
    return positive;

    procedure set_hits_coverage_goal(
      constant percentage   : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_hits_coverage_goal(
      constant VOID : t_void)
    return positive;

    procedure set_illegal_bin_alert_level(
      constant alert_level  : in t_alert_level;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_illegal_bin_alert_level(
      constant VOID : t_void)
    return t_alert_level;

    procedure set_bin_overlap_alert_level(
      constant alert_level  : in t_alert_level;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_bin_overlap_alert_level(
      constant VOID : t_void)
    return t_alert_level;

    procedure write_coverage_db(
      constant file_name    : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure load_coverage_db(
      constant file_name                : in string;
      constant new_bins_acceptance      : in t_new_bins_acceptance := WARNING_ON_NEW_BINS;
      constant alert_level_if_not_found : in t_alert_level         := TB_ERROR;
      constant report_verbosity         : in t_report_verbosity    := HOLES_ONLY;
      constant msg_id_panel             : in t_msg_id_panel        := shared_msg_id_panel);

    procedure clear_coverage(
      constant VOID : in t_void);

    procedure clear_coverage(
      constant msg_id_panel : in t_msg_id_panel);

    procedure set_num_allocated_bins(
      constant value        : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure set_num_allocated_bins_increment(
      constant value : in positive);

    procedure delete_coverpoint(
      constant VOID : in t_void);

    procedure delete_coverpoint(
      constant msg_id_panel : in t_msg_id_panel);

    -- Returns the number of bins crossed in the coverpoint
    impure function get_num_bins_crossed(
      constant VOID : t_void)
    return integer;

    -- Returns the number of valid bins in the coverpoint
    impure function get_num_valid_bins(
      constant VOID : t_void)
    return natural;

    -- Returns the number of illegal and ignore bins in the coverpoint
    impure function get_num_invalid_bins(
      constant VOID : t_void)
    return natural;

    -- Returns a valid bin in the coverpoint
    impure function get_valid_bin(
      constant bin_idx : natural)
    return t_cov_bin;

    -- Returns an invalid bin in the coverpoint
    impure function get_invalid_bin(
      constant bin_idx : natural)
    return t_cov_bin;

    -- Returns a vector with the valid bins in the coverpoint
    impure function get_valid_bins(
      constant VOID : t_void)
    return t_cov_bin_vector;

    -- Returns a vector with the illegal and ignore bins in the coverpoint
    impure function get_invalid_bins(
      constant VOID : t_void)
    return t_cov_bin_vector;

    -- Returns a string with all the bins, including illegal and ignore, in the coverpoint
    impure function get_all_bins_string(
      constant VOID : t_void)
    return string;

    ------------------------------------------------------------
    -- Add bins
    ------------------------------------------------------------
    procedure add_bins(
      constant bin           : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_bins(
      constant bin          : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_bins(
      constant bin          : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (2 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (3 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (4 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant bin4          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (5 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant bin4          : in t_new_bin_array;
      constant bin5          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant bin5         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant bin5         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    -- TODO: max 16 dimensions
    ------------------------------------------------------------
    -- Add cross (2 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (3 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (4 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      variable coverpoint4   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (5 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      variable coverpoint4   : inout t_coverpoint;
      variable coverpoint5   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      variable coverpoint5  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      variable coverpoint5  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Coverage
    ------------------------------------------------------------
    impure function is_defined(
      constant VOID : t_void)
    return boolean;

    procedure sample_coverage(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure sample_coverage(
      constant values        : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    impure function get_coverage(
      constant coverage_type      : t_coverage_type;
      constant percentage_of_goal : boolean := false)
    return real;

    impure function coverage_completed(
      constant coverage_type : t_coverage_type)
    return boolean;

    procedure report_coverage(
      constant VOID : in t_void);

    procedure report_coverage(
      constant verbosity       : in t_report_verbosity;
      constant file_name       : in string                   := "";
      constant open_mode       : in file_open_kind           := append_mode;
      constant rand_weight_col : in t_rand_weight_visibility := HIDE_RAND_WEIGHT);

    procedure report_config(
      constant VOID : in t_void);

    procedure report_config(
      constant file_name : in string;
      constant open_mode : in file_open_kind := append_mode);

    ------------------------------------------------------------
    -- Optimized Randomization
    ------------------------------------------------------------
    impure function rand(
      constant sampling     : t_rand_sample_cov;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant sampling      : t_rand_sample_cov;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector;

    procedure set_rand_seeds(
      constant seed1 : in positive;
      constant seed2 : in positive);

    procedure set_rand_seeds(
      constant seeds : in t_positive_vector(0 to 1));

    procedure get_rand_seeds(
      variable seed1 : out positive;
      variable seed2 : out positive);

    impure function get_rand_seeds(
      constant VOID : t_void)
    return t_positive_vector;

    ------------------------------------------------------------
    -- Vendor Extension
    ------------------------------------------------------------
    procedure enable_auto_sampling(
      constant target       : in string;
      constant trigger      : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);


  end protected t_coverpoint;

end package func_cov_pkg;

package body func_cov_pkg is

  -- Generates the correct procedure call to be used for logging or alerts
  procedure create_proc_call(
    constant proc_call     : in string;
    constant ext_proc_call : in string;
    variable new_proc_call : inout line) is
  begin
    -- Called directly from sequencer/VVC
    if ext_proc_call = "" then
      write(new_proc_call, proc_call);
    -- Called from another procedure
    else
      write(new_proc_call, ext_proc_call);
    end if;
  end procedure;

  -- Creates a bin with a single value
  impure function create_bin_single(
    constant contains  : t_cov_bin_type;
    constant value     : integer;
    constant proc_call : string)
  return t_new_bin_array is
    constant C_PROC_CALL_NORMALISED : string(1 to proc_call'length) := proc_call;
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := contains;
    v_ret(0).bin_vector(0).values(0)  := value;
    v_ret(0).bin_vector(0).num_values := 1;
    v_ret(0).num_bins                 := 1;
    if C_PROC_CALL_NORMALISED'length > C_FC_MAX_PROC_CALL_LENGTH then
      v_ret(0).proc_call := C_PROC_CALL_NORMALISED(1 to C_FC_MAX_PROC_CALL_LENGTH - 3) & "...";
    else
      v_ret(0).proc_call(1 to C_PROC_CALL_NORMALISED'length) := C_PROC_CALL_NORMALISED;
    end if;
    return v_ret;
  end function;

  -- Creates a bin with multiple values
  impure function create_bin_multiple(
    constant contains      : t_cov_bin_type;
    constant set_of_values : integer_vector;
    constant proc_call     : string)
  return t_new_bin_array is
    constant C_SET_OF_VALUES_NORMALISED : integer_vector(0 to set_of_values'length-1) := set_of_values;
    constant C_PROC_CALL_NORMALISED     : string(1 to proc_call'length) := proc_call;
    variable v_ret                      : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains := contains;
    if C_SET_OF_VALUES_NORMALISED'length <= C_FC_MAX_NUM_BIN_VALUES then
      v_ret(0).bin_vector(0).values(0 to C_SET_OF_VALUES_NORMALISED'length - 1) := C_SET_OF_VALUES_NORMALISED;
      v_ret(0).bin_vector(0).num_values                                         := C_SET_OF_VALUES_NORMALISED'length;
    else
      v_ret(0).bin_vector(0).values     := C_SET_OF_VALUES_NORMALISED(0 to C_FC_MAX_NUM_BIN_VALUES - 1);
      v_ret(0).bin_vector(0).num_values := C_FC_MAX_NUM_BIN_VALUES;
      alert(TB_WARNING, C_PROC_CALL_NORMALISED & "=> Number of values (" & to_string(C_SET_OF_VALUES_NORMALISED'length) & ") exceeds C_FC_MAX_NUM_BIN_VALUES.\n Increase C_FC_MAX_NUM_BIN_VALUES in adaptations package.", C_TB_SCOPE_DEFAULT);
    end if;
    v_ret(0).num_bins               := 1;
    if C_PROC_CALL_NORMALISED'length > C_FC_MAX_PROC_CALL_LENGTH then
      v_ret(0).proc_call := C_PROC_CALL_NORMALISED(1 to C_FC_MAX_PROC_CALL_LENGTH - 3) & "...";
    else
      v_ret(0).proc_call(1 to C_PROC_CALL_NORMALISED'length) := C_PROC_CALL_NORMALISED;
    end if;
    return v_ret;
  end function;

  -- Creates a bin or bins from a range of values. If num_bins is 0 then a bin is created for each value.
  impure function create_bin_range(
    constant contains  : t_cov_bin_type;
    constant min_value : integer;
    constant max_value : integer;
    constant num_bins  : natural;
    constant proc_call : string)
  return t_new_bin_array is
    constant C_PROC_CALL_NORMALISED : string(1 to proc_call'length) := proc_call;
    constant C_RANGE_WIDTH          : unsigned(31 downto 0) := to_unsigned(abs(max_value - min_value), 32) + 1;
    variable v_div_range            : unsigned(31 downto 0);
    variable v_div_residue          : integer := 0;
    variable v_div_residue_min      : integer := 0;
    variable v_div_residue_max      : integer := 0;
    variable v_num_bins             : integer := 0;
    variable v_ret                  : t_new_bin_array(0 to 0);
  begin
    check_value(contains = RAN or contains = RAN_IGNORE or contains = RAN_ILLEGAL, TB_FAILURE, "This function should only be used with range types.",
                C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => "create_bin_range()");

    if min_value <= max_value then
      -- Create a bin for each value in the range (when num_bins is not defined or range is smaller than the number of bins)
      if num_bins = 0 or C_RANGE_WIDTH <= num_bins then
        if C_RANGE_WIDTH > C_FC_MAX_NUM_NEW_BINS then
          alert(TB_ERROR, C_PROC_CALL_NORMALISED & "=> Failed. Number of bins (" & to_string(to_integer(C_RANGE_WIDTH)) & ") added in a single procedure call exceeds C_FC_MAX_NUM_NEW_BINS.\n Increase C_FC_MAX_NUM_NEW_BINS in adaptations package.", C_TB_SCOPE_DEFAULT);
          return C_EMPTY_NEW_BIN_ARRAY;
        end if;
        for i in min_value to max_value loop
          v_ret(0).bin_vector(i - min_value).contains   := VAL when contains = RAN else
                                                           VAL_IGNORE when contains = RAN_IGNORE else
                                                           VAL_ILLEGAL when contains = RAN_ILLEGAL;
          v_ret(0).bin_vector(i - min_value).values(0)  := i;
          v_ret(0).bin_vector(i - min_value).num_values := 1;
        end loop;
        v_num_bins := to_integer(C_RANGE_WIDTH);
      -- Create several bins by diving the range
      else
        if num_bins > C_FC_MAX_NUM_NEW_BINS then
          alert(TB_ERROR, C_PROC_CALL_NORMALISED & "=> Failed. Number of bins (" & to_string(num_bins) & ") added in a single procedure call exceeds C_FC_MAX_NUM_NEW_BINS.\n Increase C_FC_MAX_NUM_NEW_BINS in adaptations package.", C_TB_SCOPE_DEFAULT);
          return C_EMPTY_NEW_BIN_ARRAY;
        end if;
        v_div_residue := to_integer(C_RANGE_WIDTH mod num_bins);
        v_div_range   := C_RANGE_WIDTH / num_bins;
        v_num_bins    := num_bins;
        for i in 0 to v_num_bins - 1 loop
          -- Add the residue values to the last bins
          if v_div_residue /= 0 and i = v_num_bins - v_div_residue then
            v_div_residue_max := v_div_residue_max + 1;
          elsif v_div_residue /= 0 and i > v_num_bins - v_div_residue then
            v_div_residue_min := v_div_residue_min + 1;
            v_div_residue_max := v_div_residue_max + 1;
          end if;
          v_ret(0).bin_vector(i).contains   := contains;
          v_ret(0).bin_vector(i).values(0)  := min_value + to_integer(resize(v_div_range * i, 31)) + v_div_residue_min;
          v_ret(0).bin_vector(i).values(1)  := min_value + to_integer(resize(v_div_range * (i + 1) - 1, 31)) + v_div_residue_max;
          v_ret(0).bin_vector(i).num_values := 2;
        end loop;
      end if;
      v_ret(0).num_bins := v_num_bins;
      if C_PROC_CALL_NORMALISED'length > C_FC_MAX_PROC_CALL_LENGTH then
        v_ret(0).proc_call := C_PROC_CALL_NORMALISED(1 to C_FC_MAX_PROC_CALL_LENGTH - 3) & "...";
      else
        v_ret(0).proc_call(1 to C_PROC_CALL_NORMALISED'length) := C_PROC_CALL_NORMALISED;
      end if;
    else
      alert(TB_ERROR, C_PROC_CALL_NORMALISED & "=> Failed. min_value must be less or equal than max_value", C_TB_SCOPE_DEFAULT);
      return C_EMPTY_NEW_BIN_ARRAY;
    end if;
    return v_ret;
  end function;

  ------------------------------------------------------------
  -- Bin functions
  ------------------------------------------------------------
  -- Creates a bin for a single value
  impure function bin(
    constant value : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin(" & to_string(value) & ")";
  begin
    return create_bin_single(VAL, value, C_LOCAL_CALL);
  end function;

  -- Creates a bin for multiple values
  impure function bin(
    constant set_of_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin(" & to_string(set_of_values) & ")";
  begin
    return create_bin_multiple(VAL, set_of_values, C_LOCAL_CALL);
  end function;

  -- Creates a bin for a range of values. Several bins can be created by dividing the range into num_bins.
  -- If num_bins is 0 then a bin is created for each value.
  impure function bin_range(
    constant min_value : integer;
    constant max_value : integer;
    constant num_bins  : natural := 1)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin_range(" & to_string(min_value) & ", " & to_string(max_value) & return_string_if_true(", num_bins:" & to_string(num_bins), num_bins /= 1) & ")";
  begin
    return create_bin_range(RAN, min_value, max_value, num_bins, C_LOCAL_CALL);
  end function;

  -- Creates a bin for a vector's range. Several bins can be created by dividing the range into num_bins.
  -- If num_bins is 0 then a bin is created for each value.
  impure function bin_vector(
    constant vector   : std_logic_vector;
    constant num_bins : natural := 1)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin_vector(LEN:" & to_string(vector'length) & return_string_if_true(", num_bins:" & to_string(num_bins), num_bins /= 1) & ")";
  begin
    if vector'length >= 32 then
      alert(TB_ERROR, C_LOCAL_CALL & "=> vector's length must be less than 32 bits", C_TB_SCOPE_DEFAULT);
      return C_EMPTY_NEW_BIN_ARRAY;
    end if;

    return create_bin_range(RAN, 0, 2 ** vector'length - 1, num_bins, C_LOCAL_CALL);
  end function;

  -- Creates a bin for a transition of values
  impure function bin_transition(
    constant set_of_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin_transition(" & to_string(set_of_values) & ")";
  begin
    return create_bin_multiple(TRN, set_of_values, C_LOCAL_CALL);
  end function;

  -- Creates an ignore bin for a single value
  impure function ignore_bin(
    constant value : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "ignore_bin(" & to_string(value) & ")";
  begin
    return create_bin_single(VAL_IGNORE, value, C_LOCAL_CALL);
  end function;

  -- Creates an ignore bin for a range of values
  impure function ignore_bin_range(
    constant min_value : integer;
    constant max_value : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "ignore_bin_range(" & to_string(min_value) & "," & to_string(max_value) & ")";
  begin
    return create_bin_range(RAN_IGNORE, min_value, max_value, 1, C_LOCAL_CALL);
  end function;

  -- Creates an ignore bin for a transition of values
  impure function ignore_bin_transition(
    constant set_of_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "ignore_bin_transition(" & to_string(set_of_values) & ")";
  begin
    return create_bin_multiple(TRN_IGNORE, set_of_values, C_LOCAL_CALL);
  end function;

  -- Creates an illegal bin for a single value
  impure function illegal_bin(
    constant value : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "illegal_bin(" & to_string(value) & ")";
  begin
    return create_bin_single(VAL_ILLEGAL, value, C_LOCAL_CALL);
  end function;

  -- Creates an illegal bin for a range of values
  impure function illegal_bin_range(
    constant min_value : integer;
    constant max_value : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "illegal_bin_range(" & to_string(min_value) & "," & to_string(max_value) & ")";
  begin
    return create_bin_range(RAN_ILLEGAL, min_value, max_value, 1, C_LOCAL_CALL);
  end function;

  -- Creates an illegal bin for a transition of values
  impure function illegal_bin_transition(
    constant set_of_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "illegal_bin_transition(" & to_string(set_of_values) & ")";
  begin
    return create_bin_multiple(TRN_ILLEGAL, set_of_values, C_LOCAL_CALL);
  end function;

  ------------------------------------------------------------
  -- Overall coverage
  ------------------------------------------------------------
  procedure fc_set_covpts_coverage_goal(
    constant percentage   : in positive range 1 to 100;
    constant scope        : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    constant C_LOCAL_CALL : string := "fc_set_covpts_coverage_goal(" & to_string(percentage) & ")";
  begin
    log(ID_FUNC_COV_CONFIG, C_LOCAL_CALL, scope, msg_id_panel);
    protected_covergroup_status.set_covpts_coverage_goal(percentage);
  end procedure;

  impure function fc_get_covpts_coverage_goal(
    constant VOID : t_void)
  return positive is
  begin
    return protected_covergroup_status.get_covpts_coverage_goal(VOID);
  end function;

  impure function fc_get_overall_coverage(
    constant coverage_type : t_overall_coverage_type)
  return real is
  begin
    if coverage_type = BINS then
      return protected_covergroup_status.get_total_bins_coverage(VOID);
    elsif coverage_type = HITS then
      return protected_covergroup_status.get_total_hits_coverage(VOID);
    else                                -- COVPTS
      return protected_covergroup_status.get_total_covpts_coverage(NO_GOAL);
    end if;
  end function;

  impure function fc_overall_coverage_completed(
    constant VOID : t_void)
  return boolean is
  begin
    return protected_covergroup_status.get_total_covpts_coverage(GOAL_CAPPED) = 100.0;
  end function;

  procedure fc_report_overall_coverage(
    constant VOID : in t_void) is
  begin
    fc_report_overall_coverage(NON_VERBOSE);
  end procedure;

  procedure fc_report_overall_coverage(
    constant verbosity : in t_report_verbosity;
    constant file_name : in string         := "";
    constant open_mode : in file_open_kind := append_mode;
    constant scope     : in string         := C_TB_SCOPE_DEFAULT) is
    file file_handler          : text;
    constant C_PREFIX          : string   := C_LOG_PREFIX & "     ";
    constant C_HEADER_1        : string   := "*** OVERALL COVERAGE REPORT (VERBOSE): " & to_string(scope) & " ***";
    constant C_HEADER_2        : string   := "*** OVERALL COVERAGE REPORT (NON VERBOSE): " & to_string(scope) & " ***";
    constant C_HEADER_3        : string   := "*** OVERALL HOLES REPORT: " & to_string(scope) & " ***";
    constant C_COLUMN_WIDTH    : positive := 20;
    constant C_PRINT_GOAL      : boolean  := protected_covergroup_status.get_covpts_coverage_goal(VOID) /= 100;
    variable C_PRINT_NUM_TC    : boolean  := protected_covergroup_status.is_covpt_loaded(VOID);
    variable v_line            : line;
    variable v_log_extra_space : integer  := 0;
  begin
    initialize_util(VOID); -- Only executed the first time called. Ensures that the log and alert files are open.
    -- Calculate how much space we can insert between the columns of the report
    v_log_extra_space := (C_LOG_LINE_WIDTH - C_PREFIX'length - C_FC_MAX_NAME_LENGTH - C_COLUMN_WIDTH * 6) / 8;
    if v_log_extra_space < 1 then
      alert(TB_WARNING, "C_LOG_LINE_WIDTH is too small or C_FC_MAX_NAME_LENGTH is too big, the report will not be properly aligned.", scope);
      v_log_extra_space := 1;
    end if;

    -- Print report header
    write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    if verbosity = VERBOSE then
      write(v_line, timestamp_header(now, justify(C_HEADER_1, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
    elsif verbosity = NON_VERBOSE then
      write(v_line, timestamp_header(now, justify(C_HEADER_2, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
    elsif verbosity = HOLES_ONLY then
      write(v_line, timestamp_header(now, justify(C_HEADER_3, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
    end if;
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

    -- Print summary
    write(v_line, return_string_if_true("Goal:                    Covpts: " & to_string(protected_covergroup_status.get_covpts_coverage_goal(VOID)) & "%" & LF, C_PRINT_GOAL) &
                  return_string_if_true("% of Goal:               Covpts: " & to_string(protected_covergroup_status.get_total_covpts_coverage(GOAL_CAPPED), 2) & "%" & LF, C_PRINT_GOAL) &
                  return_string_if_true("% of Goal (uncapped):    Covpts: " & to_string(protected_covergroup_status.get_total_covpts_coverage(GOAL_UNCAPPED), 2) & "%" & LF, C_PRINT_GOAL) &
                  "Coverage (for goal 100): " &
                    justify("Covpts: " & to_string(protected_covergroup_status.get_total_covpts_coverage(NO_GOAL), 2) & "%, ", left, 18, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                    justify("Bins: " & to_string(protected_covergroup_status.get_total_bins_coverage(VOID), 2) & "%, ", left, 16, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                    justify("Hits: " & to_string(protected_covergroup_status.get_total_hits_coverage(VOID), 2) & "%", left, 14, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF &
                  fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

    if verbosity = VERBOSE or verbosity = HOLES_ONLY then
      -- Print column headers
      write(v_line, justify(
        fill_string(' ', v_log_extra_space) &
        justify("COVERPOINT", center, C_FC_MAX_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("COVERAGE WEIGHT", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("COVERED BINS", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("COVERAGE(BINS|HITS)", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("GOAL(BINS|HITS)", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("% OF GOAL(BINS|HITS)", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        return_string_if_true(justify("NUM TESTCASES", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space), C_PRINT_NUM_TC),
        left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);

      -- Print coverpoints
      for i in 0 to C_FC_MAX_NUM_COVERPOINTS - 1 loop
        if protected_covergroup_status.is_initialized(i) then
          if verbosity /= HOLES_ONLY or not (protected_covergroup_status.get_bins_coverage(i, GOAL_CAPPED) = 100.0 and protected_covergroup_status.get_hits_coverage(i, GOAL_CAPPED) = 100.0) then
            write(v_line, justify(
              fill_string(' ', v_log_extra_space) &
              justify(protected_covergroup_status.get_name(i), center, C_FC_MAX_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(protected_covergroup_status.get_coverage_weight(i)), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(protected_covergroup_status.get_num_covered_bins(i)) & " / " &
                      to_string(protected_covergroup_status.get_num_valid_bins(i)), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(protected_covergroup_status.get_bins_coverage(i, NO_GOAL), 2) & "% | " &
                      to_string(protected_covergroup_status.get_hits_coverage(i, NO_GOAL), 2) & "%", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(protected_covergroup_status.get_bins_coverage_goal(i)) & "% | " &
                      to_string(protected_covergroup_status.get_hits_coverage_goal(i)) & "%", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(protected_covergroup_status.get_bins_coverage(i, GOAL_CAPPED), 2) & "% | " &
                      to_string(protected_covergroup_status.get_hits_coverage(i, GOAL_CAPPED), 2) & "%", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              return_string_if_true(justify(to_string(protected_covergroup_status.get_num_tc_accumulated(i) + 1), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space), C_PRINT_NUM_TC),
              left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
          end if;
        end if;
      end loop;

      -- Print report bottom line
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);
    end if;

    -- Format the report
    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);

    -- Write the report to a separate file if specified
    if file_name /= "" then
      file_open(file_handler, file_name, open_mode);
      tee_and_keep_line(file_handler, v_line); -- Write to file, while keeping the line contents
      file_close(file_handler);
    end if;
    -- Write the report to the log destination
    write_line_to_log_destination(v_line);
    deallocate(v_line);
  end procedure;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_coverpoint is protected body

    type t_bin_type_verbosity is (LONG, SHORT, NONE);
    type t_samples_vector is array (natural range <>) of integer_vector(C_FC_MAX_NUM_BIN_VALUES - 1 downto 0);
    type t_integer_vector_ptr is access integer_vector;

    -- This means that the randomization weight of the bin will be equal to the min_hits
    -- parameter and will be reduced by 1 every time the bin is sampled.
    constant C_USE_ADAPTIVE_WEIGHT : integer := -1;
    -- Indicates that the coverpoint hasn't been initialized
    constant C_DEALLOCATED_ID      : integer := -1;
    -- Indicates an uninitialized natural value
    constant C_UNINITIALIZED       : integer := -1;
    -- Header used in the database files for authentication
    constant C_DB_FILE_HEADER      : string  := "--UVVM_FUNCTIONAL_COVERAGE_FILE--";

    variable priv_id                            : integer                                         := C_DEALLOCATED_ID;
    variable priv_name                          : string(1 to C_FC_MAX_NAME_LENGTH);
    variable priv_scope                         : string(1 to C_LOG_SCOPE_WIDTH)                  := C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH - C_TB_SCOPE_DEFAULT'length);
    variable priv_bins                          : t_cov_bin_vector_ptr                            := new t_cov_bin_vector(0 to C_FC_DEFAULT_INITIAL_NUM_BINS_ALLOCATED-1);
    variable priv_bins_idx                      : natural                                         := 0;
    variable priv_invalid_bins                  : t_cov_bin_vector_ptr                            := new t_cov_bin_vector(0 to C_FC_DEFAULT_INITIAL_NUM_BINS_ALLOCATED-1);
    variable priv_invalid_bins_idx              : natural                                         := 0;
    variable priv_num_bins_crossed              : integer                                         := C_UNINITIALIZED;
    variable priv_sampled_coverpoint            : boolean                                         := false;
    variable priv_loaded_coverpoint             : boolean                                         := false;
    variable priv_num_tc_accumulated            : natural                                         := 0;
    variable priv_rand_gen                      : t_rand;
    variable priv_rand_transition_bin_idx       : integer                                         := C_UNINITIALIZED;
    variable priv_rand_transition_bin_value_idx : t_natural_vector(0 to C_MAX_NUM_CROSS_BINS - 1) := (others => 0);
    variable priv_bin_sample_shift_reg          : t_samples_vector(0 to C_MAX_NUM_CROSS_BINS - 1) := (others => (others => 0));
    variable priv_illegal_bin_alert_level       : t_alert_level                                   := ERROR;
    variable priv_bin_overlap_alert_level       : t_alert_level                                   := NO_ALERT;
    variable priv_num_bins_allocated_increment  : positive                                        := C_FC_DEFAULT_NUM_BINS_ALLOCATED_INCREMENT;
    variable priv_bin_name_list                 : work.bin_name_association_list_pkg.t_association_list;

    variable priv_vendor_coverpoint_id          : integer                                         := -1;
    variable priv_ucdb_handle                   : t_ucdb_cp_handle                                := 0;

    ------------------------------------------------------------
    -- Internal functions and procedures
    ------------------------------------------------------------
    -- Returns a string with all the procedure calls in the array
    impure function get_proc_calls(
      constant bin_array : t_new_bin_array)
    return string is
      variable v_line : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in bin_array'range loop
        write(v_line, bin_array(i).proc_call);
        if i < bin_array'length - 1 then
          write(v_line, ',');
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    -- Returns a string with all the bin values in the array
    impure function get_bin_array_values(
      constant bin_array     : t_new_bin_array;
      constant bin_verbosity : t_bin_type_verbosity := SHORT;
      constant bin_delimiter : character            := ',')
    return string is
      variable v_line : line;
      impure function return_bin_type(
        constant full_name     : string;
        constant short_name    : string;
        constant bin_verbosity : t_bin_type_verbosity)
      return string is
      begin
        if bin_verbosity = LONG then
          return full_name;
        elsif bin_verbosity = SHORT then
          return short_name;
        else
          return "";
        end if;
      end function;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in bin_array'range loop
        for j in 0 to bin_array(i).num_bins - 1 loop
          case bin_array(i).bin_vector(j).contains is
            when VAL | VAL_IGNORE | VAL_ILLEGAL =>
              if bin_array(i).bin_vector(j).contains = VAL then
                write(v_line, string'(return_bin_type("bin", "", bin_verbosity)));
              elsif bin_array(i).bin_vector(j).contains = VAL_IGNORE then
                write(v_line, string'(return_bin_type("ignore_bin", "IGN", bin_verbosity)));
              else
                write(v_line, string'(return_bin_type("illegal_bin", "ILL", bin_verbosity)));
              end if;
              if bin_array(i).bin_vector(j).num_values = 1 then
                write(v_line, '(' & to_string(bin_array(i).bin_vector(j).values(0)) & ')');
              else
                write(v_line, to_string(bin_array(i).bin_vector(j).values(0 to bin_array(i).bin_vector(j).num_values - 1)));
              end if;
            when RAN | RAN_IGNORE | RAN_ILLEGAL =>
              if bin_array(i).bin_vector(j).contains = RAN then
                write(v_line, string'(return_bin_type("bin_range", "", bin_verbosity)));
              elsif bin_array(i).bin_vector(j).contains = RAN_IGNORE then
                write(v_line, string'(return_bin_type("ignore_bin_range", "IGN", bin_verbosity)));
              else
                write(v_line, string'(return_bin_type("illegal_bin_range", "ILL", bin_verbosity)));
              end if;
              write(v_line, "(" & to_string(bin_array(i).bin_vector(j).values(0)) & " to " & to_string(bin_array(i).bin_vector(j).values(1)) & ")");
            when TRN | TRN_IGNORE | TRN_ILLEGAL =>
              if bin_array(i).bin_vector(j).contains = TRN then
                write(v_line, string'(return_bin_type("bin_transition", "", bin_verbosity)));
              elsif bin_array(i).bin_vector(j).contains = TRN_IGNORE then
                write(v_line, string'(return_bin_type("ignore_bin_transition", "IGN", bin_verbosity)));
              else
                write(v_line, string'(return_bin_type("illegal_bin_transition", "ILL", bin_verbosity)));
              end if;
              write(v_line, '(');
              for k in 0 to bin_array(i).bin_vector(j).num_values - 1 loop
                write(v_line, to_string(bin_array(i).bin_vector(j).values(k)));
                if k < bin_array(i).bin_vector(j).num_values - 1 then
                  write(v_line, string'("->"));
                end if;
              end loop;
              write(v_line, ')');
          end case;
          if i < bin_array'length - 1 or j < bin_array(i).num_bins - 1 then
            write(v_line, bin_delimiter);
          end if;
        end loop;
      end loop;
      if v_line /= NULL then
        return return_and_deallocate;
      else
        return "";
      end if;
    end function;

    -- Returns a string with all the values in the bin. Since it is
    -- used in the report, if the string is bigger than the maximum
    -- length allowed, the bin name is returned instead.
    -- If max_str_length is 0 then the string with the values is
    -- always returned.
    impure function get_bin_values(
      constant bin            : t_cov_bin;
      constant max_str_length : natural := 0)
    return string is
      variable v_new_bin_array : t_new_bin_array(0 to 0);
      variable v_line          : line;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      for i in 0 to priv_num_bins_crossed - 1 loop
        v_new_bin_array(0).bin_vector(i).contains   := bin.cross_bins(i).contains;
        v_new_bin_array(0).bin_vector(i).values     := bin.cross_bins(i).values;
        v_new_bin_array(0).bin_vector(i).num_values := bin.cross_bins(i).num_values;
      end loop;
      v_new_bin_array(0).num_bins := priv_num_bins_crossed;
      -- Used in the report, so the bins in each vector are crossed
      write(v_line, get_bin_array_values(v_new_bin_array, NONE, 'x'));

      if max_str_length /= 0 and v_line'length > max_str_length then
        DEALLOCATE(v_line);
        return to_string(bin.name);
      else
        return return_and_deallocate;
      end if;
    end function;

    -- Returns a string with the bin content
    impure function get_bin_info(
      constant bin : t_bin)
    return string is
      variable v_new_bin_array : t_new_bin_array(0 to 0);
    begin
      v_new_bin_array(0).bin_vector(0).contains   := bin.contains;
      v_new_bin_array(0).bin_vector(0).values     := bin.values;
      v_new_bin_array(0).bin_vector(0).num_values := bin.num_values;
      v_new_bin_array(0).num_bins                 := 1;
      return get_bin_array_values(v_new_bin_array, LONG);
    end function;

    -- If the bin_name is empty, it returns a default name based on the bin_idx.
    -- Otherwise it returns the bin_name padded to match the C_FC_MAX_NAME_LENGTH.
    function get_bin_name(
      constant bin_name : string;
      constant bin_idx  : string)
    return string is
      constant C_BIN_NAME_NORMALISED : string(1 to bin_name'length) := bin_name;
    begin
      if C_BIN_NAME_NORMALISED = "" or C_BIN_NAME_NORMALISED = C_FC_DEFAULT_BIN_NAME then
        return C_FC_DEFAULT_BIN_NAME & bin_idx & fill_string(NUL, C_FC_MAX_NAME_LENGTH - 4 - bin_idx'length);
      else
        if C_BIN_NAME_NORMALISED'length > C_FC_MAX_NAME_LENGTH then
          return C_BIN_NAME_NORMALISED(1 to C_FC_MAX_NAME_LENGTH);
        else
          return C_BIN_NAME_NORMALISED & fill_string(NUL, C_FC_MAX_NAME_LENGTH - C_BIN_NAME_NORMALISED'length);
        end if;
      end if;
    end function;

    -- If the bin_name is empty, it returns a default name based on the bin_idx.
    -- Otherwise it returns the bin_name padded to match the C_FC_MAX_NAME_LENGTH.
    -- Add bin values
    impure function get_bin_name_with_values(
      constant bin_name        : string;
      constant bin_idx         : string;
      constant bin             : t_cov_bin;
      constant with_separator  : boolean;
      constant max_name_length : integer)
    return string is
      variable v_new_bin_array   : t_new_bin_array(0 to 0);
      variable v_values          : line;
      variable v_name_string     : string(1 to max_name_length);
      variable v_bin_name_length : integer;
      variable v_values_length   : integer;
    begin
      -- Generate values string (as line type)
      for i in 0 to priv_num_bins_crossed - 1 loop
        v_new_bin_array(0).bin_vector(i).contains   := bin.cross_bins(i).contains;
        v_new_bin_array(0).bin_vector(i).values     := bin.cross_bins(i).values;
        v_new_bin_array(0).bin_vector(i).num_values := bin.cross_bins(i).num_values;
      end loop;
      v_new_bin_array(0).num_bins := priv_num_bins_crossed;
      -- Used in the report, so the bins in each vector are crossed
      write(v_values, get_bin_array_values(v_new_bin_array, NONE, 'x'));

      -- Set first part of name string
      v_name_string(1 to C_FC_MAX_NAME_LENGTH) := get_bin_name(bin_name, bin_idx);

      -- Get length of bin name components
      v_bin_name_length := valid_length(v_name_string);
      if with_separator then
        -- Add separator after name
        v_name_string(v_bin_name_length + 1 to v_bin_name_length + 3) := " : ";
        -- Get updated length of bin name
        v_bin_name_length := valid_length(v_name_string);
      end if;
      v_values_length := v_values'length;

      -- Check if resulting bin name is too long
      if v_bin_name_length + v_values_length > max_name_length then
        -- Name too long. Cut off
        v_name_string(v_bin_name_length + 1 to max_name_length) := get_bin_array_values(v_new_bin_array, NONE, 'x')(1 to max_name_length - v_bin_name_length);
        DEALLOCATE(v_values);
        return v_name_string;
      else
        -- Can use name+values. Add values after name.
        v_name_string(v_bin_name_length + 1 to v_bin_name_length + v_values_length) := v_values.all;
        DEALLOCATE(v_values);
        return v_name_string;
      end if;
    end function;

    -- Returns a string with the coverpoint's name. Used as prefix in log messages
    impure function get_name_prefix(
      constant VOID : t_void)
    return string is
    begin
      return "[" & to_string(priv_name) & "] ";
    end function;

    -- Returns true if the bin is ignored
    impure function is_bin_ignore(
      constant bin : t_cov_bin)
    return boolean is
      variable v_is_ignore : boolean := false;
    begin
      for i in 0 to priv_num_bins_crossed - 1 loop
        v_is_ignore := v_is_ignore or (bin.cross_bins(i).contains = VAL_IGNORE or
                                       bin.cross_bins(i).contains = RAN_IGNORE or
                                       bin.cross_bins(i).contains = TRN_IGNORE);
      end loop;
      return v_is_ignore;
    end function;

    -- Returns true if the bin is illegal
    impure function is_bin_illegal(
      constant bin : t_cov_bin)
    return boolean is
      variable v_is_illegal : boolean := false;
    begin
      for i in 0 to priv_num_bins_crossed - 1 loop
        v_is_illegal := v_is_illegal or (bin.cross_bins(i).contains = VAL_ILLEGAL or
                                         bin.cross_bins(i).contains = RAN_ILLEGAL or
                                         bin.cross_bins(i).contains = TRN_ILLEGAL);
      end loop;
      return v_is_illegal;
    end function;

    -- Returns the minimum number of hits multiplied by the hits coverage goal
    impure function get_total_min_hits(
      constant min_hits : natural)
    return natural is
    begin
      return integer(real(min_hits) * real(protected_covergroup_status.get_hits_coverage_goal(priv_id)) / 100.0);
    end function;

    -- Returns the percentage of hits/min_hits in a bin. Note that it saturates at 100%
    impure function get_bin_coverage(
      constant bin : t_cov_bin)
    return real is
      variable v_coverage : real;
    begin
      if bin.hits < bin.min_hits then
        v_coverage := real(bin.hits) * 100.0 / real(bin.min_hits);
      else
        v_coverage := 100.0;
      end if;
      return v_coverage;
    end function;

    -- Initializes a new coverpoint by registering it in the covergroup status register, setting its name, randomization seeds, and default bin name.
    procedure initialize_coverpoint(
      constant local_call : in string) is
      variable v_association_list_status : t_association_list_status;
    begin
      if priv_id = C_DEALLOCATED_ID then
        priv_id := protected_covergroup_status.add_coverpoint(VOID);
        if priv_id = C_DEALLOCATED_ID then
          alert(TB_FAILURE, local_call & "=> Number of coverpoints exceeds C_FC_MAX_NUM_COVERPOINTS.\n Increase C_FC_MAX_NUM_COVERPOINTS in adaptations package.", priv_scope);
          return;
        end if;
        -- Add coverpoint to UCDB model
        fli_create_ucdb_coverpoint(priv_ucdb_handle, priv_name);
        -- Only set the default name if it hasn't been given
        if priv_name = fill_string(NUL, priv_name'length) then
          set_name(protected_covergroup_status.get_name(priv_id));
        end if;
        priv_rand_gen.set_rand_seeds(priv_name);

        -- Initialize the bin name association list by appending the default bin name
        v_association_list_status := priv_bin_name_list.append(C_FC_DEFAULT_BIN_NAME, 0);
        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_NOTE, local_call & "=> The bin name association list has already been initialized.", priv_scope);
        end if;

      end if;
    end procedure;

    -- TODO: max 16 dimensions
    -- Checks that the number of crossed bins does not change.
    -- If the extra parameters are given, it checks that the coverpoints are not empty.
    procedure check_num_bins_crossed(
      constant num_bins_crossed             : in integer;
      constant local_call                   : in string;
      constant coverpoint1_num_bins_crossed : in integer := 0;
      constant coverpoint2_num_bins_crossed : in integer := 0;
      constant coverpoint3_num_bins_crossed : in integer := 0;
      constant coverpoint4_num_bins_crossed : in integer := 0;
      constant coverpoint5_num_bins_crossed : in integer := 0) is
    begin
      initialize_coverpoint(local_call);

      if priv_loaded_coverpoint then
        alert(TB_WARNING, local_call & "=> It is recommended to always add all the bins before loading a database to avoid creating duplicate bins.", priv_scope);
      elsif priv_sampled_coverpoint then
        alert(TB_WARNING, local_call & "=> Coverpoint has already been sampled, adding more bins is not recommended otherwise their coverage might not be correct.", priv_scope);
      end if;

      check_value(coverpoint1_num_bins_crossed /= C_UNINITIALIZED, TB_FAILURE, "Coverpoint 1 is empty", priv_scope, ID_NEVER, caller_name => local_call);
      check_value(coverpoint2_num_bins_crossed /= C_UNINITIALIZED, TB_FAILURE, "Coverpoint 2 is empty", priv_scope, ID_NEVER, caller_name => local_call);
      check_value(coverpoint3_num_bins_crossed /= C_UNINITIALIZED, TB_FAILURE, "Coverpoint 3 is empty", priv_scope, ID_NEVER, caller_name => local_call);
      check_value(coverpoint4_num_bins_crossed /= C_UNINITIALIZED, TB_FAILURE, "Coverpoint 4 is empty", priv_scope, ID_NEVER, caller_name => local_call);
      check_value(coverpoint5_num_bins_crossed /= C_UNINITIALIZED, TB_FAILURE, "Coverpoint 5 is empty", priv_scope, ID_NEVER, caller_name => local_call);

      -- The number of bins crossed is set on the first call and can't be changed
      if priv_num_bins_crossed = C_UNINITIALIZED and num_bins_crossed > 0 then
        priv_num_bins_crossed := num_bins_crossed;
      elsif priv_num_bins_crossed /= num_bins_crossed and num_bins_crossed > 0 then
        alert(TB_FAILURE, local_call & "=> Cannot mix different number of crossed bins.", priv_scope);
      end if;
    end procedure;

    -- Returns true if a bin is already stored in the bin vector
    impure function find_duplicate_bin(
      constant cov_bin_vector : t_cov_bin_vector;
      constant cov_bin_idx    : natural;
      constant cross_bin_idx  : natural)
    return boolean is
      constant C_CONTAINS   : t_cov_bin_type                        := cov_bin_vector(cov_bin_idx).cross_bins(cross_bin_idx).contains;
      constant C_NUM_VALUES : natural                               := cov_bin_vector(cov_bin_idx).cross_bins(cross_bin_idx).num_values;
      constant C_VALUES     : integer_vector(0 to C_NUM_VALUES - 1) := cov_bin_vector(cov_bin_idx).cross_bins(cross_bin_idx).values(0 to C_NUM_VALUES - 1);
    begin
      for i in 0 to cov_bin_idx - 1 loop
        if cov_bin_vector(i).cross_bins(cross_bin_idx).contains = C_CONTAINS and
           cov_bin_vector(i).cross_bins(cross_bin_idx).num_values = C_NUM_VALUES and
           cov_bin_vector(i).cross_bins(cross_bin_idx).values(0 to C_NUM_VALUES - 1) = C_VALUES
        then
          return true;
        end if;
      end loop;
      return false;
    end function;

    -- Copies all the bins in a bin array to a bin vector.
    -- The bin array can contain several bin_vector elements depending on the
    -- number of bins created by a single bin function. It can also contain
    -- several array elements depending on the number of concatenated bin
    -- functions used.
    procedure copy_bins_in_bin_array(
      constant bin_array : in t_new_bin_array;
      variable cov_bin   : out t_new_cov_bin;
      constant proc_call : in string) is
      variable v_num_bins : natural := 0;
    begin
      for i in bin_array'range loop
        if v_num_bins + bin_array(i).num_bins > C_FC_MAX_NUM_NEW_BINS then
          alert(TB_ERROR, proc_call & "=> Number of bins added in a single procedure call exceeds C_FC_MAX_NUM_NEW_BINS.\n" & "Increase C_FC_MAX_NUM_NEW_BINS in adaptations package.", C_TB_SCOPE_DEFAULT);
          return;
        end if;
        cov_bin.bin_vector(v_num_bins to v_num_bins + bin_array(i).num_bins - 1) := bin_array(i).bin_vector(0 to bin_array(i).num_bins - 1);
        v_num_bins                                                               := v_num_bins + bin_array(i).num_bins;
      end loop;
      cov_bin.num_bins := v_num_bins;
    end procedure;

    -- Copies all the bins in a coverpoint to a bin array (including crossed bins)
    -- Duplicate bins are not copied since they are assumed to be the result of a cross
    procedure copy_bins_in_coverpoint(
      variable coverpoint : inout t_coverpoint;
      variable bin_array  : out t_new_bin_array) is
      variable v_coverpoint_bins         : t_cov_bin_vector(0 to coverpoint.get_num_valid_bins(VOID) - 1);
      variable v_coverpoint_invalid_bins : t_cov_bin_vector(0 to coverpoint.get_num_invalid_bins(VOID) - 1);
      variable v_num_bins                : natural := 0;
    begin
      v_coverpoint_bins         := coverpoint.get_valid_bins(VOID);
      v_coverpoint_invalid_bins := coverpoint.get_invalid_bins(VOID);

      for cross in 0 to bin_array'length - 1 loop
        for i in v_coverpoint_bins'range loop
          if not find_duplicate_bin(v_coverpoint_bins, i, cross) then
            bin_array(cross).bin_vector(v_num_bins).contains   := v_coverpoint_bins(i).cross_bins(cross).contains;
            bin_array(cross).bin_vector(v_num_bins).values     := v_coverpoint_bins(i).cross_bins(cross).values;
            bin_array(cross).bin_vector(v_num_bins).num_values := v_coverpoint_bins(i).cross_bins(cross).num_values;
            v_num_bins                                         := v_num_bins + 1;
          end if;
        end loop;
        for i in v_coverpoint_invalid_bins'range loop
          if not find_duplicate_bin(v_coverpoint_invalid_bins, i, cross) then
            bin_array(cross).bin_vector(v_num_bins).contains   := v_coverpoint_invalid_bins(i).cross_bins(cross).contains;
            bin_array(cross).bin_vector(v_num_bins).values     := v_coverpoint_invalid_bins(i).cross_bins(cross).values;
            bin_array(cross).bin_vector(v_num_bins).num_values := v_coverpoint_invalid_bins(i).cross_bins(cross).num_values;
            v_num_bins                                         := v_num_bins + 1;
          end if;
        end loop;
        bin_array(cross).num_bins := v_num_bins;
        v_num_bins                := 0;
      end loop;
    end procedure;

    -- Creates a bin array from several bin arrays
    procedure create_bin_array(
      constant proc_call : in string;
      variable bin_array : out t_new_bin_array;
      constant bin1      : in t_new_bin_array;
      constant bin2      : in t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY;
      constant bin3      : in t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY;
      constant bin4      : in t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY;
      constant bin5      : in t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY) is
    begin
      copy_bins_in_bin_array(bin1, bin_array(0), proc_call);

      if bin2 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin2, bin_array(1), proc_call);
      end if;

      if bin3 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin3, bin_array(2), proc_call);
      end if;

      if bin4 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin4, bin_array(3), proc_call);
      end if;

      if bin5 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin5, bin_array(4), proc_call);
      end if;
    end procedure;

    -- Creates a bin array from several coverpoints
    procedure create_bin_array(
      variable bin_array   : out t_new_bin_array;
      variable coverpoint1 : inout t_coverpoint;
      variable coverpoint2 : inout t_coverpoint) is
      variable v_bin_array1 : t_new_bin_array(0 to coverpoint1.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array2 : t_new_bin_array(0 to coverpoint2.get_num_bins_crossed(VOID) - 1);
    begin
      copy_bins_in_coverpoint(coverpoint1, v_bin_array1);
      copy_bins_in_coverpoint(coverpoint2, v_bin_array2);
      bin_array := v_bin_array1 & v_bin_array2;
    end procedure;

    -- Overload
    procedure create_bin_array(
      variable bin_array   : out t_new_bin_array;
      variable coverpoint1 : inout t_coverpoint;
      variable coverpoint2 : inout t_coverpoint;
      variable coverpoint3 : inout t_coverpoint) is
      variable v_bin_array1 : t_new_bin_array(0 to coverpoint1.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array2 : t_new_bin_array(0 to coverpoint2.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array3 : t_new_bin_array(0 to coverpoint3.get_num_bins_crossed(VOID) - 1);
    begin
      copy_bins_in_coverpoint(coverpoint1, v_bin_array1);
      copy_bins_in_coverpoint(coverpoint2, v_bin_array2);
      copy_bins_in_coverpoint(coverpoint3, v_bin_array3);
      bin_array := v_bin_array1 & v_bin_array2 & v_bin_array3;
    end procedure;

    -- Overload
    procedure create_bin_array(
      variable bin_array   : out t_new_bin_array;
      variable coverpoint1 : inout t_coverpoint;
      variable coverpoint2 : inout t_coverpoint;
      variable coverpoint3 : inout t_coverpoint;
      variable coverpoint4 : inout t_coverpoint) is
      variable v_bin_array1 : t_new_bin_array(0 to coverpoint1.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array2 : t_new_bin_array(0 to coverpoint2.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array3 : t_new_bin_array(0 to coverpoint3.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array4 : t_new_bin_array(0 to coverpoint4.get_num_bins_crossed(VOID) - 1);
    begin
      copy_bins_in_coverpoint(coverpoint1, v_bin_array1);
      copy_bins_in_coverpoint(coverpoint2, v_bin_array2);
      copy_bins_in_coverpoint(coverpoint3, v_bin_array3);
      copy_bins_in_coverpoint(coverpoint4, v_bin_array4);
      bin_array := v_bin_array1 & v_bin_array2 & v_bin_array3 & v_bin_array4;
    end procedure;

    -- TODO: create more overloads (16)
    -- Overload
    procedure create_bin_array(
      variable bin_array   : out t_new_bin_array;
      variable coverpoint1 : inout t_coverpoint;
      variable coverpoint2 : inout t_coverpoint;
      variable coverpoint3 : inout t_coverpoint;
      variable coverpoint4 : inout t_coverpoint;
      variable coverpoint5 : inout t_coverpoint) is
      variable v_bin_array1 : t_new_bin_array(0 to coverpoint1.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array2 : t_new_bin_array(0 to coverpoint2.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array3 : t_new_bin_array(0 to coverpoint3.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array4 : t_new_bin_array(0 to coverpoint4.get_num_bins_crossed(VOID) - 1);
      variable v_bin_array5 : t_new_bin_array(0 to coverpoint5.get_num_bins_crossed(VOID) - 1);
    begin
      copy_bins_in_coverpoint(coverpoint1, v_bin_array1);
      copy_bins_in_coverpoint(coverpoint2, v_bin_array2);
      copy_bins_in_coverpoint(coverpoint3, v_bin_array3);
      copy_bins_in_coverpoint(coverpoint4, v_bin_array4);
      copy_bins_in_coverpoint(coverpoint5, v_bin_array5);
      bin_array := v_bin_array1 & v_bin_array2 & v_bin_array3 & v_bin_array4 & v_bin_array5;
    end procedure;

    -- Checks that the number of transitions is the same for all elements in a cross
    procedure check_cross_num_transitions(
      variable num_transitions : inout integer;
      constant contains        : in t_cov_bin_type;
      constant num_values      : in natural) is
    begin
      if contains = TRN or contains = TRN_IGNORE or contains = TRN_ILLEGAL then
        if num_transitions = C_UNINITIALIZED then
          num_transitions := num_values;
        else
          check_value(num_values, num_transitions, TB_ERROR, "Number of transition values must be the same in all cross elements", priv_scope, ID_NEVER);
        end if;
      end if;
    end procedure;

    -- Resizes the bin vector by creating a new memory structure and deallocating the old one
    procedure resize_bin_vector(
      variable bin_vector : inout t_cov_bin_vector_ptr;
      constant num_bins   : in natural := 0;
      constant size       : in natural := 0) is
      variable v_copy_ptr : t_cov_bin_vector_ptr;
    begin
      v_copy_ptr := bin_vector;
      if size = 0 then
        bin_vector                             := new t_cov_bin_vector(0 to v_copy_ptr'length-1 + priv_num_bins_allocated_increment);
        bin_vector(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      else
        bin_vector                    := new t_cov_bin_vector(0 to size-1);
        bin_vector(0 to num_bins - 1) := v_copy_ptr(0 to num_bins - 1);
      end if;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    -- Adds bins in a recursive way
    procedure add_bins_recursive(
      constant bin_array       : in t_new_bin_array;
      constant bin_array_idx   : in integer;
      variable idx_reg         : inout integer_vector;
      constant min_hits        : in positive;
      constant rand_weight     : in natural;
      constant use_rand_weight : in boolean;
      constant bin_name        : in string
    ) is
      constant C_NUM_CROSS_BINS          : natural := bin_array'length;
      variable v_bin_is_valid            : boolean;
      variable v_num_transitions         : integer;
      variable v_association_list_status : t_association_list_status;
      variable v_ucdb_bin_index          : t_ucdb_bin_index;
      variable v_ucdb_bin_name           : string(1 to C_FC_MAX_UCDB_NAME_LENGTH);
      variable v_tmp_bin_name            : string(1 to C_FC_MAX_NAME_LENGTH);
      variable v_bin_name_idx            : integer;

      -- Return the total number of bins in the bin array
      function num_bins_in_bin_array (
        constant dummy : t_void
      ) return integer is
        variable v_ret : integer := 0;
      begin
        for i in 0 to bin_array'length - 1 loop
          v_ret := v_ret + bin_array(i).num_bins;
        end loop;

        return v_ret;
      end function num_bins_in_bin_array;

      -- Get the bin name index based on the bin name and bin number.
      impure function get_bin_name_index (
        bin_name : string;
        bin_number : integer
      ) return integer is
        constant C_LOCAL_CALL : string := "get_bin_name_index(" & bin_name & "," & to_string(bin_number) & ")";
        variable v_ret        : integer;
      begin
        if C_NUM_CROSS_BINS > 1 then
          if priv_bin_name_list.key_in_list(bin_name) then -- the name is already in the list
            v_ret := priv_bin_name_list.get(key => bin_name) + 1;
            v_association_list_status := priv_bin_name_list.set(key => bin_name, value => v_ret);

            if v_association_list_status = ASSOCIATION_LIST_FAILURE then
              alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to bin name: '" & bin_name & "' in the bin name association list.", priv_scope);
            end if;
          else
            alert(TB_ERROR, C_LOCAL_CALL & "=> The bin name: '" & bin_name & "' is expected to be in the association list.", priv_scope);
          end if;
        else
          v_ret := bin_number + 1;
        end if;

        return v_ret;
      end function get_bin_name_index;

      -- Append the index to the string inside square brackets. Truncate before
      -- appending if the resulting string is longer than the given max length.
      function append_index_to_bin_name (
        constant str            : string;
        constant idx            : integer;
        constant max_str_length : integer := C_FC_MAX_NAME_LENGTH
      ) return string is
      constant C_IDX_STR : string := "["& to_string(idx) & "]";
        variable v_ret   : string(1 to max_str_length);
      begin
        if valid_length(str) + C_IDX_STR'length >= max_str_length then
          v_ret := str(1 to max_str_length - C_IDX_STR'length) & C_IDX_STR;
        else
          v_ret := str(1 to valid_length(str)) & C_IDX_STR & fill_string(NUL, max_str_length - valid_length(str) - C_IDX_STR'length);
        end if;

        return v_ret;
      end function append_index_to_bin_name;

    begin
      check_value(priv_id /= C_DEALLOCATED_ID, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER);

      -- Iterate through the bins in the current array element
      for i in 0 to bin_array(bin_array_idx).num_bins - 1 loop
        -- Store the bin index for the current element of the array
        idx_reg(bin_array_idx) := i;
        -- Last element of the array has been reached, add bins
        if bin_array_idx = C_NUM_CROSS_BINS - 1 then
          -- Check that all the bins being added are valid
          v_bin_is_valid    := true;
          for j in 0 to C_NUM_CROSS_BINS - 1 loop
            v_bin_is_valid := v_bin_is_valid and (bin_array(j).bin_vector(idx_reg(j)).contains = VAL or
                                                  bin_array(j).bin_vector(idx_reg(j)).contains = RAN or
                                                  bin_array(j).bin_vector(idx_reg(j)).contains = TRN);
          end loop;
          v_num_transitions := C_UNINITIALIZED;

          -- Store valid bins
          if v_bin_is_valid then
            -- Resize if there's no space in the list
            if priv_bins_idx = priv_bins'length then
              resize_bin_vector(priv_bins);
            end if;
            for j in 0 to C_NUM_CROSS_BINS - 1 loop
              check_cross_num_transitions(v_num_transitions, bin_array(j).bin_vector(idx_reg(j)).contains, bin_array(j).bin_vector(idx_reg(j)).num_values);
              priv_bins(priv_bins_idx).cross_bins(j).contains   := bin_array(j).bin_vector(idx_reg(j)).contains;
              priv_bins(priv_bins_idx).cross_bins(j).values     := bin_array(j).bin_vector(idx_reg(j)).values;
              priv_bins(priv_bins_idx).cross_bins(j).num_values := bin_array(j).bin_vector(idx_reg(j)).num_values;
            end loop;
            priv_bins(priv_bins_idx).hits            := 0;
            priv_bins(priv_bins_idx).min_hits        := min_hits;
            priv_bins(priv_bins_idx).rand_weight     := rand_weight when use_rand_weight else C_USE_ADAPTIVE_WEIGHT;
            priv_bins(priv_bins_idx).transition_mask := (others => '0');

            v_tmp_bin_name := get_bin_name(bin_name, to_string(priv_bin_name_list.get(bin_name))); -- get the next bin name

            -- Append an index to the bin name if multiple bins are given or if the number of bins in the cross is larger than the cross
            if (C_NUM_CROSS_BINS = 1 and bin_array(bin_array_idx).num_bins > 1)  or (num_bins_in_bin_array(VOID) > C_NUM_CROSS_BINS) then
              v_tmp_bin_name := append_index_to_bin_name(v_tmp_bin_name, get_bin_name_index(bin_name, i));
            end if;

            priv_bins(priv_bins_idx).name := v_tmp_bin_name;

            -- Add bins to UCDB model
            priv_bins(priv_bins_idx).ucdb_index := v_ucdb_bin_index;
            v_ucdb_bin_name := get_bin_name_with_values(bin_name, to_string(priv_bins_idx + priv_invalid_bins_idx + 1), priv_bins(priv_bins_idx), true, C_FC_MAX_UCDB_NAME_LENGTH); -- default bin names are 1-indexed
            fli_add_ucdb_bin(priv_ucdb_handle, C_UCDB_ACTION_COUNT, min_hits, v_ucdb_bin_name, v_ucdb_bin_index);

            priv_bins_idx := priv_bins_idx + 1;
            -- Update covergroup status register
            protected_covergroup_status.increment_valid_bin_count(priv_id);
            protected_covergroup_status.increment_min_hits_count(priv_id, min_hits);

          -- Store ignore or illegal bins
          else
            -- Check if there's space in the list
            if priv_invalid_bins_idx = priv_invalid_bins'length then
              resize_bin_vector(priv_invalid_bins);
            end if;
            for j in 0 to C_NUM_CROSS_BINS - 1 loop
              check_cross_num_transitions(v_num_transitions, bin_array(j).bin_vector(idx_reg(j)).contains, bin_array(j).bin_vector(idx_reg(j)).num_values);
              priv_invalid_bins(priv_invalid_bins_idx).cross_bins(j).contains   := bin_array(j).bin_vector(idx_reg(j)).contains;
              priv_invalid_bins(priv_invalid_bins_idx).cross_bins(j).values     := bin_array(j).bin_vector(idx_reg(j)).values;
              priv_invalid_bins(priv_invalid_bins_idx).cross_bins(j).num_values := bin_array(j).bin_vector(idx_reg(j)).num_values;
            end loop;
            priv_invalid_bins(priv_invalid_bins_idx).hits            := 0;
            priv_invalid_bins(priv_invalid_bins_idx).min_hits        := 0;
            priv_invalid_bins(priv_invalid_bins_idx).rand_weight     := 0;
            priv_invalid_bins(priv_invalid_bins_idx).transition_mask := (others => '0');

            v_tmp_bin_name := get_bin_name(bin_name, to_string(priv_bin_name_list.get(bin_name))); -- get the next bin name

            -- Append an index to the bin name if multiple bins are given or if the number of bins in the cross is larger than the cross
            if bin_array(bin_array_idx).num_bins > 1  or (num_bins_in_bin_array(VOID) > C_NUM_CROSS_BINS) then
              v_tmp_bin_name := append_index_to_bin_name(v_tmp_bin_name, get_bin_name_index(bin_name, i)); -- bin names are 1-indexed
            end if;

            priv_invalid_bins(priv_invalid_bins_idx).name := v_tmp_bin_name;
            priv_invalid_bins_idx                         := priv_invalid_bins_idx + 1;
          end if;

        -- Go to the next element of the array
        else
          add_bins_recursive(bin_array, bin_array_idx + 1, idx_reg, min_hits, rand_weight, use_rand_weight, bin_name);
        end if;
      end loop;
    end procedure;

    procedure check_and_initialize_vendor_coverpoint_id(
      constant VOID : t_void) is
    begin
      if (C_VENDOR_EXTENSION_IS_ENABLED) then
        if (priv_vendor_coverpoint_id = -1) then
          priv_vendor_coverpoint_id := vendor_create_coverpoint_var;
        end if;
      end if;
    end procedure;

    procedure vendor_add_bins(
      constant idx_from         : integer;
      constant invalid_idx_from : integer) is
      variable v_lval       : integer;
      variable v_rval       : integer;
      variable v_index      : integer := 0;
      variable v_is_tran    : integer := 0;
      variable v_is_illegal : integer := 1;
    begin
      if (C_VENDOR_EXTENSION_IS_ENABLED) then
        if (priv_vendor_coverpoint_id = -1) then
          priv_vendor_coverpoint_id := vendor_create_coverpoint_var;
        end if;

        for i in idx_from to priv_bins_idx - 1 loop
          v_lval := priv_bins(i).cross_bins(0).values(0);
          if (priv_bins(i).cross_bins(0).contains = VAL) then
            v_rval := v_lval;
          elsif (priv_bins(i).cross_bins(0).contains = RAN) then
            v_rval := priv_bins(i).cross_bins(0).values(1);
          elsif (priv_bins(i).cross_bins(0).contains = TRN) then
            v_is_tran := 1;
            v_rval := v_lval;
          else
            next;
          end if;
          vendor_func_cov_add_bin(priv_vendor_coverpoint_id, priv_bins(i).name, 0, v_is_tran, v_lval, v_rval);
          if (priv_bins(i).cross_bins(0).contains = RAN) then
            v_index := 2;
            while (v_index < priv_bins(i).cross_bins(0).num_values) loop
              v_lval := priv_bins(i).cross_bins(0).values(v_index);
              v_rval := priv_bins(i).cross_bins(0).values(v_index+1);
              v_index := v_index + 2;
              vendor_func_cov_bin_add_value(priv_vendor_coverpoint_id, v_lval, v_rval);
            end loop;
          else
            -- For VAL and TRN
            for j in 1 to priv_bins(i).cross_bins(0).num_values -1 loop
              v_lval := priv_bins(i).cross_bins(0).values(j);
              v_rval := v_lval;
              vendor_func_cov_bin_add_value(priv_vendor_coverpoint_id, v_lval, v_rval);
            end loop;
          end if;
        end loop;

        for i in invalid_idx_from to priv_invalid_bins_idx - 1 loop
          v_lval := priv_invalid_bins(i).cross_bins(0).values(0);
          if (priv_invalid_bins(i).cross_bins(0).contains = VAL_IGNORE or priv_invalid_bins(i).cross_bins(0).contains = VAL_ILLEGAL) then
            v_rval := v_lval;
          elsif (priv_invalid_bins(i).cross_bins(0).contains = RAN_IGNORE or priv_invalid_bins(i).cross_bins(0).contains = RAN_ILLEGAL) then
            v_rval := priv_invalid_bins(i).cross_bins(0).values(1);
          elsif (priv_invalid_bins(i).cross_bins(0).contains = TRN_IGNORE or priv_invalid_bins(i).cross_bins(0).contains = TRN_ILLEGAL) then
            v_is_tran := 1;
            v_rval := v_lval;
          else
            next;
          end if;
          if (is_bin_illegal(priv_invalid_bins(i))) then
            v_is_illegal := 2;
          end if;
          vendor_func_cov_add_bin(priv_vendor_coverpoint_id, priv_invalid_bins(i).name, v_is_illegal, v_is_tran, v_lval, v_rval);
          if (priv_invalid_bins(i).cross_bins(0).contains = TRN_IGNORE or priv_invalid_bins(i).cross_bins(0).contains = TRN_ILLEGAL) then
            for j in 1 to priv_invalid_bins(i).cross_bins(0).num_values -1 loop
              v_lval := priv_invalid_bins(i).cross_bins(0).values(j);
              v_rval := v_lval;
              vendor_func_cov_bin_add_value(priv_vendor_coverpoint_id, v_lval, v_rval);
            end loop;
          end if;
        end loop;
      end if;
    end procedure;

    procedure vendor_get_bin_hits(
      constant VOID : t_void) is
      variable v_num_new_hits : integer;
    begin
      if (C_VENDOR_EXTENSION_IS_ENABLED) then
        if (priv_vendor_coverpoint_id = -1) then
          return;
        end if;

        for i in 0 to priv_bins_idx - 1 loop
          if (priv_bins(i).cross_bins(1).num_values = 0) then
            -- Get number of auto-sampled hits
            v_num_new_hits := vendor_func_cov_get_bin_hits(priv_vendor_coverpoint_id, priv_bins(i).name);
            -- Update covergroup status
            if v_num_new_hits > 0 then
              for j in 1 to v_num_new_hits loop
                -- Increment UVVM bin hits, one by one
                priv_bins(i).hits := priv_bins(i).hits + 1;
                -- Update covergroup status register
                protected_covergroup_status.increment_hits_count(priv_id); -- Count the total hits
                if priv_bins(i).hits <= priv_bins(i).min_hits then
                  protected_covergroup_status.increment_coverage_hits_count(priv_id); -- Count until min_hits has been reached
                end if;
                if priv_bins(i).hits <= get_total_min_hits(priv_bins(i).min_hits) then
                  protected_covergroup_status.increment_goal_hits_count(priv_id); -- Count until min_hits x goal has been reached
                end if;
                if priv_bins(i).hits = priv_bins(i).min_hits and priv_bins(i).min_hits /= 0 then
                  protected_covergroup_status.increment_covered_bin_count(priv_id); -- Count the covered bins
                end if;
              end loop;
            end if;
          end if;
        end loop;

        for i in 0 to priv_invalid_bins_idx - 1 loop
          if (priv_invalid_bins(i).cross_bins(1).num_values = 0) then
            priv_invalid_bins(i).hits := priv_invalid_bins(i).hits + vendor_func_cov_get_bin_hits(priv_vendor_coverpoint_id, priv_invalid_bins(i).name);
          end if;
        end loop;
      end if;
    end procedure;

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_name(
      constant name : in string) is
      constant C_NAME_NORMALISED  : string(1 to name'length) := name;
      constant C_LOCAL_CALL       : string := "set_name(" & name & ")";
    begin
      if C_NAME_NORMALISED'length > C_FC_MAX_NAME_LENGTH then
        priv_name := C_NAME_NORMALISED(1 to C_FC_MAX_NAME_LENGTH);
      else
        priv_name := C_NAME_NORMALISED & fill_string(NUL, C_FC_MAX_NAME_LENGTH - C_NAME_NORMALISED'length);
      end if;
      initialize_coverpoint(C_LOCAL_CALL);
      protected_covergroup_status.set_name(priv_id, priv_name);
      fli_set_ucdb_coverpoint_name(priv_ucdb_handle, name); -- Write name to CP in UCDB model
    end procedure;

    impure function get_name(
      constant VOID : t_void)
    return string is
    begin
      return to_string(priv_name);
    end function;

    procedure set_scope(
      constant scope : in string) is
      constant C_SCOPE_NORMALISED : string(1 to scope'length) := scope;
      constant C_LOCAL_CALL       : string := "set_scope(" & scope & ")";
    begin
      initialize_coverpoint(C_LOCAL_CALL);
      if C_SCOPE_NORMALISED'length > C_LOG_SCOPE_WIDTH then
        priv_scope := C_SCOPE_NORMALISED(1 to C_LOG_SCOPE_WIDTH);
      else
        priv_scope := C_SCOPE_NORMALISED & fill_string(NUL, C_LOG_SCOPE_WIDTH - C_SCOPE_NORMALISED'length);
      end if;
    end procedure;

    impure function get_scope(
      constant VOID : t_void)
    return string is
    begin
      return to_string(priv_scope);
    end function;

    procedure set_overall_coverage_weight(
      constant weight       : in natural;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_overall_coverage_weight(" & to_string(weight) & ")";
    begin
      initialize_coverpoint(C_LOCAL_CALL);
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      protected_covergroup_status.set_coverage_weight(priv_id, weight);
    end procedure;

    impure function get_overall_coverage_weight(
      constant VOID : t_void)
    return natural is
    begin
      if priv_id /= C_DEALLOCATED_ID then
        return protected_covergroup_status.get_coverage_weight(priv_id);
      else
        return 1;
      end if;
    end function;

    procedure set_bins_coverage_goal(
      constant percentage   : in positive range 1 to 100;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_bins_coverage_goal(" & to_string(percentage) & ")";
    begin
      initialize_coverpoint(C_LOCAL_CALL);
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      protected_covergroup_status.set_bins_coverage_goal(priv_id, percentage);
    end procedure;

    impure function get_bins_coverage_goal(
      constant VOID : t_void)
    return positive is
    begin
      if priv_id /= C_DEALLOCATED_ID then
        return protected_covergroup_status.get_bins_coverage_goal(priv_id);
      else
        return 100;
      end if;
    end function;

    procedure set_hits_coverage_goal(
      constant percentage   : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_hits_coverage_goal(" & to_string(percentage) & ")";
    begin
      initialize_coverpoint(C_LOCAL_CALL);
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      protected_covergroup_status.set_hits_coverage_goal(priv_id, percentage);
    end procedure;

    impure function get_hits_coverage_goal(
      constant VOID : t_void)
    return positive is
    begin
      if priv_id /= C_DEALLOCATED_ID then
        return protected_covergroup_status.get_hits_coverage_goal(priv_id);
      else
        return 100;
      end if;
    end function;

    procedure set_illegal_bin_alert_level(
      constant alert_level  : in t_alert_level;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_illegal_bin_alert_level(" & to_upper(to_string(alert_level)) & ")";
    begin
      initialize_coverpoint(C_LOCAL_CALL);
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_illegal_bin_alert_level := alert_level;
    end procedure;

    impure function get_illegal_bin_alert_level(
      constant VOID : t_void)
    return t_alert_level is
    begin
      return priv_illegal_bin_alert_level;
    end function;

    procedure set_bin_overlap_alert_level(
      constant alert_level  : in t_alert_level;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_bin_overlap_alert_level(" & to_upper(to_string(alert_level)) & ")";
    begin
      initialize_coverpoint(C_LOCAL_CALL);
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_bin_overlap_alert_level := alert_level;
    end procedure;

    impure function get_bin_overlap_alert_level(
      constant VOID : t_void)
    return t_alert_level is
    begin
      return priv_bin_overlap_alert_level;
    end function;

    procedure write_coverage_db(
      constant file_name    : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "write_coverage_db(" & get_basename(file_name) & ")";
      file file_handler     : text open write_mode is file_name;
      variable v_line       : line;

      procedure write_value(
        constant value : in integer) is
      begin
        write(v_line, value);
        writeline(file_handler, v_line);
      end procedure;

      procedure write_value(
        constant value : in integer_vector) is
      begin
        for i in 0 to value'length - 1 loop
          write(v_line, value(i));
          if i < value'length - 1 then
            write(v_line, ' ');
          end if;
        end loop;
        writeline(file_handler, v_line);
      end procedure;

      procedure write_value(
        constant value : in string) is
      begin
        write(v_line, value);
        writeline(file_handler, v_line);
      end procedure;

      procedure write_value(
        constant value : in boolean) is
      begin
        write(v_line, value);
        writeline(file_handler, v_line);
      end procedure;

      procedure write_bins(
        constant bins_idx    : in natural;
        variable bins_vector : in t_cov_bin_vector_ptr) is
      begin
        write(v_line, bins_idx);
        writeline(file_handler, v_line);
        for i in 0 to bins_idx - 1 loop
          write(v_line, to_string(bins_vector(i).name));
          writeline(file_handler, v_line);
          write(v_line, to_string(bins_vector(i).hits) & ' ' & to_string(bins_vector(i).min_hits) & ' ' & to_string(bins_vector(i).rand_weight));
          writeline(file_handler, v_line);
          for j in 0 to priv_num_bins_crossed - 1 loop
            write(v_line, to_string(t_cov_bin_type'pos(bins_vector(i).cross_bins(j).contains)) & ' ' & to_string(bins_vector(i).cross_bins(j).num_values) & ' ');
            for k in 0 to bins_vector(i).cross_bins(j).num_values - 1 loop
              write(v_line, bins_vector(i).cross_bins(j).values(k));
              write(v_line, ' ');
            end loop;
            writeline(file_handler, v_line);
          end loop;
        end loop;
      end procedure;

    begin
      vendor_get_bin_hits(VOID); -- Update coverage from auto-sampled coverpoints
      if priv_id /= C_DEALLOCATED_ID then
        log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
        write_value(C_DB_FILE_HEADER);
        -- Coverpoint config
        write_value(to_string(priv_name));
        write_value(to_string(priv_scope));
        write_value(priv_num_bins_crossed);
        write_value(priv_sampled_coverpoint);
        write_value(priv_num_tc_accumulated);
        write_value(integer_vector(priv_rand_gen.get_rand_seeds(VOID)));
        write_value(t_alert_level'pos(priv_illegal_bin_alert_level));
        write_value(t_alert_level'pos(priv_bin_overlap_alert_level));
        -- Covergroup config
        write_value(protected_covergroup_status.get_num_valid_bins(priv_id));
        write_value(protected_covergroup_status.get_num_covered_bins(priv_id));
        write_value(protected_covergroup_status.get_total_bin_min_hits(priv_id));
        write_value(protected_covergroup_status.get_total_bin_hits(priv_id));
        write_value(protected_covergroup_status.get_total_coverage_bin_hits(priv_id));
        write_value(protected_covergroup_status.get_total_goal_bin_hits(priv_id));
        write_value(protected_covergroup_status.get_coverage_weight(priv_id));
        write_value(protected_covergroup_status.get_bins_coverage_goal(priv_id));
        write_value(protected_covergroup_status.get_hits_coverage_goal(priv_id));
        write_value(protected_covergroup_status.get_covpts_coverage_goal(VOID));
        -- Bin structure
        write_bins(priv_bins_idx, priv_bins);
        write_bins(priv_invalid_bins_idx, priv_invalid_bins);
      else
        alert(TB_ERROR, C_LOCAL_CALL & "=> Coverpoint has not been initialized", priv_scope);
      end if;
      file_close(file_handler);
      DEALLOCATE(v_line);
    end procedure;

    procedure load_coverage_db(
      constant file_name                : in string;
      constant new_bins_acceptance      : in t_new_bins_acceptance := WARNING_ON_NEW_BINS;
      constant alert_level_if_not_found : in t_alert_level         := TB_ERROR;
      constant report_verbosity         : in t_report_verbosity    := HOLES_ONLY;
      constant msg_id_panel             : in t_msg_id_panel        := shared_msg_id_panel) is
      constant C_LOCAL_CALL       : string := "load_coverage_db(" & get_basename(file_name) & ")";
      file file_handler           : text;
      variable v_open_status      : file_open_status;
      variable v_line             : line;
      variable v_value            : integer;
      variable v_num_bins_crossed : natural;
      variable v_rand_seeds       : integer_vector(0 to 1);
      variable v_loaded_bins_idx  : natural;

      procedure read_value(
        variable value : out integer) is
      begin
        readline(file_handler, v_line);
        read(v_line, value);
      end procedure;

      procedure read_value(
        variable value : out integer_vector) is
        variable v_idx : natural := 0;
      begin
        readline(file_handler, v_line);
        while v_line.all'length > 0 loop
          read(v_line, value(v_idx));
          v_idx := v_idx + 1;
          exit when v_idx > value'length - 1;
        end loop;
      end procedure;

      procedure read_value(
        variable value : out boolean) is
      begin
        readline(file_handler, v_line);
        read(v_line, value);
      end procedure;

      procedure read_bins(
        variable bins_idx        : inout natural;
        variable bins_vector     : inout t_cov_bin_vector_ptr;
        constant loaded_bins_idx : in natural) is
        variable v_loaded_bins : t_cov_bin_vector(0 to loaded_bins_idx - 1);
        variable v_contains    : integer;
        variable v_num_values  : integer;
        variable v_alert_level : t_alert_level;
      begin
        -- Read all the bins and copy them to a temporary variable
        for i in 0 to loaded_bins_idx - 1 loop
          readline(file_handler, v_line);
          v_loaded_bins(i).name := v_line.all & fill_string(NUL, C_FC_MAX_NAME_LENGTH - v_line'length);
          readline(file_handler, v_line);
          read(v_line, v_loaded_bins(i).hits);
          read(v_line, v_loaded_bins(i).min_hits);
          read(v_line, v_loaded_bins(i).rand_weight);
          for j in 0 to priv_num_bins_crossed - 1 loop
            readline(file_handler, v_line);
            read(v_line, v_contains);
            v_loaded_bins(i).cross_bins(j).contains   := t_cov_bin_type'val(v_contains);
            read(v_line, v_num_values);
            check_value(v_num_values <= C_FC_MAX_NUM_BIN_VALUES, TB_FAILURE, "Cannot load the " & to_string(v_num_values) & " bin values. Increase C_FC_MAX_NUM_BIN_VALUES",
                        priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
            v_loaded_bins(i).cross_bins(j).num_values := v_num_values;
            for k in 0 to v_num_values - 1 loop
              read(v_line, v_loaded_bins(i).cross_bins(j).values(k));
            end loop;
          end loop;
        end loop;

        -- Resize the bin vector in case it's not big enough
        if (bins_idx + loaded_bins_idx) > bins_vector'length - 1 then
          resize_bin_vector(bins_vector, bins_idx, (bins_idx + loaded_bins_idx));
        end if;

        -- Iterate through the current bins and compare them with the loaded bins
        for i in 0 to bins_idx - 1 loop
          for j in 0 to v_loaded_bins'length - 1 loop
            -- Match only the unique elements in the bin
            if bins_vector(i).cross_bins = v_loaded_bins(j).cross_bins and bins_vector(i).min_hits = v_loaded_bins(j).min_hits and bins_vector(i).rand_weight = v_loaded_bins(j).rand_weight then
              -- Overwrite the rest of the elements in the bin using the loaded data
              bins_vector(i).name                       := v_loaded_bins(j).name;
              bins_vector(i).hits                       := v_loaded_bins(j).hits;
              -- Delete the bin from the loaded bins
              v_loaded_bins(j).cross_bins(0).num_values := 0;
              exit;
            elsif j = v_loaded_bins'length - 1 then
              -- Add bin information to the covergroup status since it was overwritten by the loaded data
              if not (is_bin_ignore(bins_vector(i)) or is_bin_illegal(bins_vector(i))) then
                protected_covergroup_status.increment_valid_bin_count(priv_id);
                protected_covergroup_status.increment_min_hits_count(priv_id, bins_vector(i).min_hits);
              end if;
              -- Generate an alert if the current bin was not found in the loaded bins
              if new_bins_acceptance /= NO_ALERT_ON_NEW_BINS then
                v_alert_level := TB_ERROR when new_bins_acceptance = ERROR_ON_NEW_BINS else TB_WARNING;
                alert(v_alert_level, C_LOCAL_CALL & "=> bin[" & get_bin_values(bins_vector(i)) & ", min_hits:" & to_string(bins_vector(i).min_hits) &
                  ", rand_weight:" & to_string(bins_vector(i).rand_weight) & "] not found in loaded database. Coverage for this bin might not be correct.", priv_scope);
              end if;
            end if;
          end loop;
        end loop;

        -- Add any extra loaded bins not found in the current bins
        for i in 0 to v_loaded_bins'length - 1 loop
          if v_loaded_bins(i).cross_bins(0).num_values /= 0 then
            bins_vector(bins_idx) := v_loaded_bins(i);
            bins_idx              := bins_idx + 1;
          end if;
        end loop;
      end procedure;

    begin
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      initialize_coverpoint(C_LOCAL_CALL);

      priv_loaded_coverpoint := true;
      protected_covergroup_status.set_covpt_is_loaded(VOID);

      file_open(v_open_status, file_handler, file_name, read_mode);
      if v_open_status /= open_ok then
        alert(alert_level_if_not_found, C_LOCAL_CALL & "=> Cannot open file: " & file_name, priv_scope);
        return;
      end if;

      -- Check file header
      readline(file_handler, v_line);
      if v_line.all /= C_DB_FILE_HEADER then
        alert(TB_ERROR, C_LOCAL_CALL & "=> File has an unknown format", priv_scope);
        deallocate(v_line);
        return;
      end if;

      if priv_sampled_coverpoint then
        alert(TB_WARNING, C_LOCAL_CALL & "=> Coverpoint has already been sampled, loading DB afterwards is not recommended since coverage in the bins will be overwritten", priv_scope);
      end if;

      -- Add coverpoint to covergroup status register
      if priv_id = C_DEALLOCATED_ID then
        priv_id := protected_covergroup_status.add_coverpoint(VOID);
        check_value(priv_id /= C_DEALLOCATED_ID, TB_FAILURE, "Number of coverpoints exceeds C_FC_MAX_NUM_COVERPOINTS.\n Increase C_FC_MAX_NUM_COVERPOINTS in adaptations package.",
                    priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      end if;

      -- Coverpoint config
      readline(file_handler, v_line);
      set_name(v_line.all);
      readline(file_handler, v_line);
      set_scope(v_line.all);
      read_value(v_num_bins_crossed);
      if v_num_bins_crossed /= priv_num_bins_crossed and priv_num_bins_crossed /= C_UNINITIALIZED then
        alert(TB_ERROR, C_LOCAL_CALL & "=> Cannot load " & to_string(v_num_bins_crossed) & " crossed bins to a coverpoint with " & to_string(priv_num_bins_crossed) & " crossed bins", priv_scope);
        deallocate(v_line);
        return;
      elsif v_num_bins_crossed > C_MAX_NUM_CROSS_BINS then
        alert(TB_ERROR, C_LOCAL_CALL & "=> Cannot load " & to_string(v_num_bins_crossed) & " crossed bins. Increase C_MAX_NUM_CROSS_BINS", priv_scope);
        deallocate(v_line);
        return;
      else
        priv_num_bins_crossed := v_num_bins_crossed;
      end if;
      read_value(priv_sampled_coverpoint);
      read_value(priv_num_tc_accumulated);
      read_value(v_rand_seeds);
      priv_rand_gen.set_rand_seeds(t_positive_vector(v_rand_seeds));
      read_value(v_value);
      priv_illegal_bin_alert_level := t_alert_level'val(v_value);
      read_value(v_value);
      priv_bin_overlap_alert_level := t_alert_level'val(v_value);
      -- Covergroup config
      protected_covergroup_status.set_name(priv_id, priv_name); -- Previously read from the file
      read_value(v_value);
      protected_covergroup_status.set_num_valid_bins(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_num_covered_bins(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_total_bin_min_hits(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_total_bin_hits(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_total_coverage_bin_hits(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_total_goal_bin_hits(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_coverage_weight(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_bins_coverage_goal(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_hits_coverage_goal(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_covpts_coverage_goal(v_value);
      -- Bin structure
      read_value(v_loaded_bins_idx);
      read_bins(priv_bins_idx, priv_bins, v_loaded_bins_idx);
      read_value(v_loaded_bins_idx);
      read_bins(priv_invalid_bins_idx, priv_invalid_bins, v_loaded_bins_idx);

      file_close(file_handler);
      DEALLOCATE(v_line);

      priv_num_tc_accumulated := priv_num_tc_accumulated + 1;
      protected_covergroup_status.set_num_tc_accumulated(priv_id, priv_num_tc_accumulated);
      report_coverage(report_verbosity);
    end procedure;

    procedure clear_coverage(
      constant VOID : in t_void) is
    begin
      clear_coverage(shared_msg_id_panel);
    end procedure;

    procedure clear_coverage(
      constant msg_id_panel : in t_msg_id_panel) is
      constant C_LOCAL_CALL : string := "clear_coverage()";
    begin
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);

      if (C_VENDOR_EXTENSION_IS_ENABLED and priv_vendor_coverpoint_id >= 0) then
        vendor_func_cov_clear_coverage(priv_vendor_coverpoint_id);
      end if;

      for i in 0 to priv_bins_idx - 1 loop
        priv_bins(i).hits            := 0;
        priv_bins(i).transition_mask := (others => '0');
      end loop;
      for i in 0 to priv_invalid_bins_idx - 1 loop
        priv_invalid_bins(i).hits            := 0;
        priv_invalid_bins(i).transition_mask := (others => '0');
      end loop;
      priv_rand_transition_bin_idx       := C_UNINITIALIZED;
      priv_rand_transition_bin_value_idx := (others => 0);
      priv_bin_sample_shift_reg          := (others => (others => 0));
      if priv_id /= C_DEALLOCATED_ID then
        protected_covergroup_status.set_num_covered_bins(priv_id, 0);
        protected_covergroup_status.set_total_coverage_bin_hits(priv_id, 0);
        protected_covergroup_status.set_total_goal_bin_hits(priv_id, 0);
        protected_covergroup_status.set_total_bin_hits(priv_id, 0);
        protected_covergroup_status.set_num_tc_accumulated(priv_id, 0);
      end if;
      priv_sampled_coverpoint            := false;
      priv_loaded_coverpoint             := false;
      priv_num_tc_accumulated            := 0;
    end procedure;

    procedure set_num_allocated_bins(
      constant value        : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_num_allocated_bins(" & to_string(value) & ")";
    begin
      initialize_coverpoint(C_LOCAL_CALL);
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      if value >= priv_bins_idx then
        resize_bin_vector(priv_bins, priv_bins_idx, value);
      else
        alert(TB_ERROR, C_LOCAL_CALL & "=> Cannot set the allocated size to a value smaller than the actual number of bins", priv_scope);
      end if;
    end procedure;

    procedure set_num_allocated_bins_increment(
      constant value : in positive) is
    begin
      priv_num_bins_allocated_increment := value;
    end procedure;

    procedure delete_coverpoint(
      constant VOID : in t_void) is
    begin
      delete_coverpoint(shared_msg_id_panel);
    end procedure;

    procedure delete_coverpoint(
      constant msg_id_panel : in t_msg_id_panel) is
      constant C_LOCAL_CALL    : string := "delete_coverpoint()";
      variable v_association_list_status : t_association_list_status;
    begin
      log(ID_FUNC_COV_CONFIG, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      if priv_id /= C_DEALLOCATED_ID then
        protected_covergroup_status.remove_coverpoint(priv_id);
      end if;
      priv_id                            := C_DEALLOCATED_ID;
      priv_name                          := fill_string(NUL, C_FC_MAX_NAME_LENGTH);
      priv_scope                         := C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH - C_TB_SCOPE_DEFAULT'length);
      DEALLOCATE(priv_bins);
      priv_bins                          := new t_cov_bin_vector(0 to C_FC_DEFAULT_INITIAL_NUM_BINS_ALLOCATED-1);
      priv_bins_idx                      := 0;
      DEALLOCATE(priv_invalid_bins);
      priv_invalid_bins                  := new t_cov_bin_vector(0 to C_FC_DEFAULT_INITIAL_NUM_BINS_ALLOCATED-1);
      priv_invalid_bins_idx              := 0;
      priv_num_bins_crossed              := C_UNINITIALIZED;
      priv_sampled_coverpoint            := false;
      priv_loaded_coverpoint             := false;
      priv_num_tc_accumulated            := 0;
      priv_rand_gen.set_rand_seeds(C_RAND_INIT_SEED_1, C_RAND_INIT_SEED_2);
      priv_rand_transition_bin_idx       := C_UNINITIALIZED;
      priv_rand_transition_bin_value_idx := (others => 0);
      priv_bin_sample_shift_reg          := (others => (others => 0));
      priv_illegal_bin_alert_level       := ERROR;
      priv_bin_overlap_alert_level       := NO_ALERT;
      priv_num_bins_allocated_increment  := C_FC_DEFAULT_NUM_BINS_ALLOCATED_INCREMENT;
      v_association_list_status          := priv_bin_name_list.clear(VOID);
    end procedure;

    -- Returns the number of bins crossed in the coverpoint
    impure function get_num_bins_crossed(
      constant VOID : t_void)
    return integer is
    begin
      return priv_num_bins_crossed;
    end function;

    -- Returns the number of valid bins in the coverpoint
    impure function get_num_valid_bins(
      constant VOID : t_void)
    return natural is
    begin
      return priv_bins_idx;
    end function;

    -- Returns the number of illegal and ignore bins in the coverpoint
    impure function get_num_invalid_bins(
      constant VOID : t_void)
    return natural is
    begin
      return priv_invalid_bins_idx;
    end function;

    -- Returns a valid bin in the coverpoint
    impure function get_valid_bin(
      constant bin_idx : natural)
    return t_cov_bin is
      constant C_LOCAL_CALL : string := "get_valid_bin(" & to_string(bin_idx) & ")";
    begin
      check_value(bin_idx < priv_bins'length, TB_ERROR, "bin_idx is out of range", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      return priv_bins(bin_idx);
    end function;

    -- Returns an invalid bin in the coverpoint
    impure function get_invalid_bin(
      constant bin_idx : natural)
    return t_cov_bin is
      constant C_LOCAL_CALL : string := "get_invalid_bin(" & to_string(bin_idx) & ")";
    begin
      check_value(bin_idx < priv_invalid_bins'length, TB_ERROR, "bin_idx is out of range", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      return priv_invalid_bins(bin_idx);
    end function;

    -- Returns a vector with the valid bins in the coverpoint
    impure function get_valid_bins(
      constant VOID : t_void)
    return t_cov_bin_vector is
    begin
      return priv_bins(0 to priv_bins_idx - 1);
    end function;

    -- Returns a vector with the illegal and ignore bins in the coverpoint
    impure function get_invalid_bins(
      constant VOID : t_void)
    return t_cov_bin_vector is
    begin
      return priv_invalid_bins(0 to priv_invalid_bins_idx - 1);
    end function;

    -- Returns a string with all the bins in the coverpoint including illegal, ignore and cross
    -- Duplicate bins are not printed since they are assumed to be the result of a cross
    impure function get_all_bins_string(
      constant VOID : t_void)
    return string is
      variable v_new_bin_array : t_new_bin_array(0 to priv_num_bins_crossed - 1);
      variable v_line          : line;
      variable v_num_bins      : natural := 0;
      impure function return_and_deallocate return string is
        constant ret : string := v_line.all;
      begin
        DEALLOCATE(v_line);
        return ret;
      end function;
    begin
      if priv_bins_idx = 0 and priv_invalid_bins_idx = 0 then
        return "";
      end if;

      for cross in v_new_bin_array'range loop
        for i in 0 to priv_bins_idx - 1 loop
          if not find_duplicate_bin(priv_bins.all, i, cross) then
            v_new_bin_array(cross).bin_vector(v_num_bins).contains   := priv_bins(i).cross_bins(cross).contains;
            v_new_bin_array(cross).bin_vector(v_num_bins).values     := priv_bins(i).cross_bins(cross).values;
            v_new_bin_array(cross).bin_vector(v_num_bins).num_values := priv_bins(i).cross_bins(cross).num_values;
            v_num_bins                                               := v_num_bins + 1;
          end if;
        end loop;
        for i in 0 to priv_invalid_bins_idx - 1 loop
          if not find_duplicate_bin(priv_invalid_bins.all, i, cross) then
            v_new_bin_array(cross).bin_vector(v_num_bins).contains   := priv_invalid_bins(i).cross_bins(cross).contains;
            v_new_bin_array(cross).bin_vector(v_num_bins).values     := priv_invalid_bins(i).cross_bins(cross).values;
            v_new_bin_array(cross).bin_vector(v_num_bins).num_values := priv_invalid_bins(i).cross_bins(cross).num_values;
            v_num_bins                                               := v_num_bins + 1;
          end if;
        end loop;
        v_new_bin_array(cross).num_bins := v_num_bins;
        v_num_bins                      := 0;
        write(v_line, get_bin_array_values(v_new_bin_array(cross to cross)));
        if cross < v_new_bin_array'length - 1 then
          write(v_line, string'(" x "));
        end if;
      end loop;
      return return_and_deallocate;
    end function;

    ------------------------------------------------------------
    -- Append bin name and check
    --
    -- Appends the bin name to the bin names association list
    -- and issues a TB_WARNING if the name is already in the
    -- list.
    ------------------------------------------------------------
    procedure  append_bin_name_and_check (
      constant bin_name : string
    ) is
      constant C_LOCAL_CALL : string := "append_bin_name_and_check(" & bin_name & ")";
      variable v_association_list_status : t_association_list_status;
    begin
      v_association_list_status := priv_bin_name_list.append(key => bin_name, value => 0);
      if C_FC_BIN_NAME_DUPLICATE_WARNING then
        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_WARNING, C_LOCAL_CALL & "=> The bin name: '" & bin_name & "' has already been used." & LF &
          "This warning can be turned off by setting the" & LF &
          "C_FC_BIN_NAME_DUPLICATION_WARNING constant in the" & LF &
          "adaptations_pkg to 'false'", priv_scope);
        end if;
      end if;
    end procedure append_bin_name_and_check;

    ------------------------------------------------------------
    -- Add bins
    ------------------------------------------------------------
    procedure add_bins(
      constant bin           : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL               : string  := "add_bins(" & get_proc_calls(bin) & ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS           : natural := 1;
      constant C_USE_RAND_WEIGHT          : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call                : line;
      variable v_bin_array                : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                  : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_cur_priv_bin_idx         : integer := priv_bins_idx;
      variable v_cur_priv_invalid_bin_idx : integer := priv_invalid_bins_idx;
      variable v_default_bin_name_idx     : integer;
      variable v_association_list_status  : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding bins: " & get_bin_array_values(bin) & ", min_hits:" & to_string(min_hits) &
        ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) & ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_proc_call.all, v_bin_array, bin);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME);
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      vendor_add_bins(v_cur_priv_bin_idx, v_cur_priv_invalid_bin_idx);
      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_bins(
      constant bin          : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_bins(" & get_proc_calls(bin) & ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_bins(bin, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_bins(
      constant bin          : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_bins(" & get_proc_calls(bin) & ", """ & bin_name & """)";
    begin
      add_bins(bin, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (2 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", min_hits:" & to_string(min_hits) &
        ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : natural := 2;
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & get_bin_array_values(bin1) & " x " & get_bin_array_values(bin2) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) &
        ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_proc_call.all, v_bin_array, bin1, bin2);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", min_hits:" & to_string(min_hits) &
        ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (3 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : natural := 3;
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & get_bin_array_values(bin1) & " x " & get_bin_array_values(bin2) & " x " & get_bin_array_values(bin3) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) &
        ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_proc_call.all, v_bin_array, bin1, bin2, bin3);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (4 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant bin4          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", " & get_proc_calls(bin4) & ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : natural := 4;
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & get_bin_array_values(bin1) & " x " & get_bin_array_values(bin2) & " x " & get_bin_array_values(bin3) & " x " & get_bin_array_values(bin4) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) &
        ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_proc_call.all, v_bin_array, bin1, bin2, bin3, bin4);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", " & get_proc_calls(bin4) & ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, bin4, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", " & get_proc_calls(bin4) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, bin4, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (5 bins)
    ------------------------------------------------------------
    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant bin4          : in t_new_bin_array;
      constant bin5          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", " & get_proc_calls(bin4) & ", " & get_proc_calls(bin5) & ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : natural := 5;
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & get_bin_array_values(bin1) & " x " & get_bin_array_values(bin2) & " x " & get_bin_array_values(bin3) &
        " x " & get_bin_array_values(bin4) & " x " & get_bin_array_values(bin5) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) &
        ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_proc_call.all, v_bin_array, bin1, bin2, bin3, bin4, bin5);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant bin5         : in t_new_bin_array;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", " & get_proc_calls(bin4) & ", " & get_proc_calls(bin5) & ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, bin4, bin5, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      constant bin1         : in t_new_bin_array;
      constant bin2         : in t_new_bin_array;
      constant bin3         : in t_new_bin_array;
      constant bin4         : in t_new_bin_array;
      constant bin5         : in t_new_bin_array;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", " & get_proc_calls(bin4) & ", " & get_proc_calls(bin5) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, bin4, bin5, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (2 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : integer := coverpoint1.get_num_bins_crossed(VOID) + coverpoint2.get_num_bins_crossed(VOID);
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all, coverpoint1.get_num_bins_crossed(VOID), coverpoint2.get_num_bins_crossed(VOID));
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & coverpoint1.get_all_bins_string(VOID) & " x " & coverpoint2.get_all_bins_string(VOID) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) &
        ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, coverpoint1, coverpoint2);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (3 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : integer := coverpoint1.get_num_bins_crossed(VOID) + coverpoint2.get_num_bins_crossed(VOID) + coverpoint3.get_num_bins_crossed(VOID);
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all, coverpoint1.get_num_bins_crossed(VOID), coverpoint2.get_num_bins_crossed(VOID),
                             coverpoint3.get_num_bins_crossed(VOID));
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & coverpoint1.get_all_bins_string(VOID) & " x " & coverpoint2.get_all_bins_string(VOID) & " x " & coverpoint3.get_all_bins_string(VOID) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) &
        ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, coverpoint1, coverpoint2, coverpoint3);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) &
        ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (4 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      variable coverpoint4   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) &
        ", " & coverpoint4.get_name(VOID) & ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : integer := coverpoint1.get_num_bins_crossed(VOID) + coverpoint2.get_num_bins_crossed(VOID) + coverpoint3.get_num_bins_crossed(VOID) + coverpoint4.get_num_bins_crossed(VOID);
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all, coverpoint1.get_num_bins_crossed(VOID), coverpoint2.get_num_bins_crossed(VOID),
                             coverpoint3.get_num_bins_crossed(VOID), coverpoint4.get_num_bins_crossed(VOID));
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & coverpoint1.get_all_bins_string(VOID) & " x " & coverpoint2.get_all_bins_string(VOID) & " x " & coverpoint3.get_all_bins_string(VOID) &
        " x " & coverpoint4.get_all_bins_string(VOID) & ", min_hits:" & to_string(min_hits) & ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) &
        ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, coverpoint1, coverpoint2, coverpoint3, coverpoint4);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) & ", " & coverpoint4.get_name(VOID) &
        ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) & ", " & coverpoint4.get_name(VOID) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (5 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      variable coverpoint4   : inout t_coverpoint;
      variable coverpoint5   : inout t_coverpoint;
      constant min_hits      : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL              : string  := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) & ", " & coverpoint4.get_name(VOID) &
        ", " & coverpoint5.get_name(VOID) & ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS          : integer := coverpoint1.get_num_bins_crossed(VOID) + coverpoint2.get_num_bins_crossed(VOID) + coverpoint3.get_num_bins_crossed(VOID) + coverpoint4.get_num_bins_crossed(VOID) + coverpoint5.get_num_bins_crossed(VOID);
      constant C_USE_RAND_WEIGHT         : boolean := ext_proc_call = ""; -- When procedure is called from the sequencer
      variable v_proc_call               : line;
      variable v_bin_array               : t_new_bin_array(0 to C_NUM_CROSS_BINS - 1);
      variable v_idx_reg                 : integer_vector(0 to C_NUM_CROSS_BINS - 1);
      variable v_default_bin_name_idx    : integer;
      variable v_association_list_status : t_association_list_status;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all, coverpoint1.get_num_bins_crossed(VOID), coverpoint2.get_num_bins_crossed(VOID),
                             coverpoint3.get_num_bins_crossed(VOID), coverpoint4.get_num_bins_crossed(VOID), coverpoint5.get_num_bins_crossed(VOID));
      log(ID_FUNC_COV_BINS, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNC_COV_BINS_INFO, get_name_prefix(VOID) & "Adding cross: " & coverpoint1.get_all_bins_string(VOID) & " x " & coverpoint2.get_all_bins_string(VOID) &
        " x " & coverpoint3.get_all_bins_string(VOID) & " x " & coverpoint4.get_all_bins_string(VOID) & " x " & coverpoint5.get_all_bins_string(VOID) & ", min_hits:" & to_string(min_hits) &
        ", rand_weight:" & return_string1_if_true_otherwise_string2(to_string(rand_weight), to_string(min_hits), C_USE_RAND_WEIGHT) & ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, coverpoint1, coverpoint2, coverpoint3, coverpoint4, coverpoint5);

      if bin_name = "" or bin_name = C_FC_DEFAULT_BIN_NAME then -- use the default bin name
        v_default_bin_name_idx := priv_bin_name_list.get(C_FC_DEFAULT_BIN_NAME) + 1;
        v_association_list_status := priv_bin_name_list.set(C_FC_DEFAULT_BIN_NAME, v_default_bin_name_idx);

        if v_association_list_status = ASSOCIATION_LIST_FAILURE then
          alert(TB_ERROR, C_LOCAL_CALL & "=> Unable to set a new value to the '" & bin_name & "' key.", priv_scope);
        end if;

        append_bin_name_and_check(C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, C_FC_DEFAULT_BIN_NAME & to_string(v_default_bin_name_idx));
      else -- use the given bin name
        append_bin_name_and_check(bin_name);
        add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, C_USE_RAND_WEIGHT, bin_name);
      end if;

      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      variable coverpoint5  : inout t_coverpoint;
      constant min_hits     : in positive;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) & ", " & coverpoint4.get_name(VOID) &
        ", " & coverpoint5.get_name(VOID) & ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, coverpoint5, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      variable coverpoint1  : inout t_coverpoint;
      variable coverpoint2  : inout t_coverpoint;
      variable coverpoint3  : inout t_coverpoint;
      variable coverpoint4  : inout t_coverpoint;
      variable coverpoint5  : inout t_coverpoint;
      constant bin_name     : in string         := "";
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " & coverpoint3.get_name(VOID) & ", " & coverpoint4.get_name(VOID) &
        ", " & coverpoint5.get_name(VOID) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, coverpoint4, coverpoint5, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Coverage
    ------------------------------------------------------------
    impure function is_defined(
      constant VOID : t_void)
    return boolean is
    begin
      return priv_num_bins_crossed /= C_UNINITIALIZED;
    end function;

    procedure sample_coverage(
      constant value        : in integer;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string                 := "sample_coverage(" & to_string(value) & ")";
      variable v_values     : integer_vector(0 to 0) := (0 => value);
    begin
      log(ID_FUNC_COV_SAMPLE, get_name_prefix(VOID) & C_LOCAL_CALL, priv_scope, msg_id_panel);
      sample_coverage(v_values, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure sample_coverage(
      constant values        : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL        : string                                           := "sample_coverage(" & to_string(values) & ")";
      variable v_proc_call         : line;
      variable v_invalid_sample    : boolean                                          := false;
      variable v_value_match       : std_logic_vector(0 to priv_num_bins_crossed - 1) := (others => '0');
      variable v_illegal_match_idx : integer                                          := -1;
      variable v_num_occurrences   : natural                                          := 0;
      variable v_sample_shift_reg  : t_integer_vector_ptr;
      variable v_bin_values        : t_integer_vector_ptr;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      if priv_num_bins_crossed = C_UNINITIALIZED then
        alert(TB_ERROR, v_proc_call.all & "=> Coverpoint does not contain any bins", priv_scope);
        DEALLOCATE(v_proc_call);
        return;
      end if;
      if ext_proc_call = "" then        -- Do not print log message when being called from another method
        log(ID_FUNC_COV_SAMPLE, get_name_prefix(VOID) & v_proc_call.all, priv_scope, msg_id_panel);
      end if;

      if priv_num_bins_crossed /= values'length then
        alert(TB_FAILURE, v_proc_call.all & "=> Number of values does not match the number of crossed bins", priv_scope);
      end if;

      -- Shift register used to check transition bins
      for i in 0 to priv_num_bins_crossed - 1 loop
        priv_bin_sample_shift_reg(i) := priv_bin_sample_shift_reg(i)(priv_bin_sample_shift_reg(0)'length - 2 downto 0) & values(i);
      end loop;

      -- Check if the values should be ignored or are illegal
      for i in 0 to priv_invalid_bins_idx - 1 loop
        priv_invalid_bins(i).transition_mask := priv_invalid_bins(i).transition_mask(priv_invalid_bins(i).transition_mask'length - 2 downto 0) & '1';
        for j in 0 to priv_num_bins_crossed - 1 loop
          case priv_invalid_bins(i).cross_bins(j).contains is
            when VAL | VAL_IGNORE | VAL_ILLEGAL =>
              for k in 0 to priv_invalid_bins(i).cross_bins(j).num_values - 1 loop
                if values(j) = priv_invalid_bins(i).cross_bins(j).values(k) then
                  v_value_match(j)    := '1';
                  v_illegal_match_idx := j when priv_invalid_bins(i).cross_bins(j).contains = VAL_ILLEGAL;
                end if;
              end loop;
            when RAN | RAN_IGNORE | RAN_ILLEGAL =>
              if values(j) >= priv_invalid_bins(i).cross_bins(j).values(0) and values(j) <= priv_invalid_bins(i).cross_bins(j).values(1) then
                v_value_match(j)    := '1';
                v_illegal_match_idx := j when priv_invalid_bins(i).cross_bins(j).contains = RAN_ILLEGAL;
              end if;
            when TRN | TRN_IGNORE | TRN_ILLEGAL =>
              -- Fix for Modelsim: copy the 2 values to variables before comparing them, otherwise the comparison always returns true.
              v_sample_shift_reg     := new integer_vector(priv_invalid_bins(i).cross_bins(j).num_values - 1 downto 0);
              v_sample_shift_reg.all := priv_bin_sample_shift_reg(j)(priv_invalid_bins(i).cross_bins(j).num_values - 1 downto 0);
              v_bin_values           := new integer_vector(0 to priv_invalid_bins(i).cross_bins(j).num_values - 1);
              v_bin_values.all       := priv_invalid_bins(i).cross_bins(j).values(0 to priv_invalid_bins(i).cross_bins(j).num_values - 1);

              -- Check if there are enough valid values in the shift register to compare the transition
              if priv_invalid_bins(i).transition_mask(priv_invalid_bins(i).cross_bins(j).num_values - 1) = '1' and v_sample_shift_reg.all = v_bin_values.all then
                v_value_match(j)    := '1';
                v_illegal_match_idx := j when priv_invalid_bins(i).cross_bins(j).contains = TRN_ILLEGAL;
              end if;

              DEALLOCATE(v_sample_shift_reg);
              DEALLOCATE(v_bin_values);
            when others =>
              alert(TB_FAILURE, v_proc_call.all & "=> Unexpected error, invalid bin contains " & to_upper(to_string(priv_invalid_bins(i).cross_bins(j).contains)), priv_scope);
          end case;
        end loop;

        if and(v_value_match) = '1' then
          v_invalid_sample                     := true;
          priv_invalid_bins(i).transition_mask := (others => '0');
          priv_invalid_bins(i).hits            := priv_invalid_bins(i).hits + 1;
          if v_illegal_match_idx /= -1 then
            alert(priv_illegal_bin_alert_level, get_name_prefix(VOID) & v_proc_call.all & "=> Sampled " & get_bin_info(priv_invalid_bins(i).cross_bins(v_illegal_match_idx)), priv_scope);
          end if;
        end if;
        v_value_match       := (others => '0');
        v_illegal_match_idx := -1;
      end loop;

      -- Check if the values are in the valid bins
      if not (v_invalid_sample) then
        for i in 0 to priv_bins_idx - 1 loop
          priv_bins(i).transition_mask := priv_bins(i).transition_mask(priv_bins(i).transition_mask'length - 2 downto 0) & '1';
          for j in 0 to priv_num_bins_crossed - 1 loop
            case priv_bins(i).cross_bins(j).contains is
              when VAL =>
                for k in 0 to priv_bins(i).cross_bins(j).num_values - 1 loop
                  if values(j) = priv_bins(i).cross_bins(j).values(k) then
                    v_value_match(j) := '1';
                  end if;
                end loop;
              when RAN =>
                if values(j) >= priv_bins(i).cross_bins(j).values(0) and values(j) <= priv_bins(i).cross_bins(j).values(1) then
                  v_value_match(j) := '1';
                end if;
              when TRN =>
                -- Fix for Modelsim: copy the 2 values to variables before comparing them, otherwise the comparison always returns true.
                v_sample_shift_reg     := new integer_vector(priv_bins(i).cross_bins(j).num_values - 1 downto 0);
                v_sample_shift_reg.all := priv_bin_sample_shift_reg(j)(priv_bins(i).cross_bins(j).num_values - 1 downto 0);
                v_bin_values           := new integer_vector(0 to priv_bins(i).cross_bins(j).num_values - 1);
                v_bin_values.all       := priv_bins(i).cross_bins(j).values(0 to priv_bins(i).cross_bins(j).num_values - 1);

                -- Check if there are enough valid values in the shift register to compare the transition
                if priv_bins(i).transition_mask(priv_bins(i).cross_bins(j).num_values - 1) = '1' and v_sample_shift_reg.all = v_bin_values.all then
                  v_value_match(j) := '1';
                end if;

                DEALLOCATE(v_sample_shift_reg);
                DEALLOCATE(v_bin_values);
              when others =>
                alert(TB_FAILURE, v_proc_call.all & "=> Unexpected error, valid bin contains " & to_upper(to_string(priv_bins(i).cross_bins(j).contains)), priv_scope);
            end case;
          end loop;

          if and(v_value_match) = '1' then
            priv_bins(i).transition_mask := (others => '0');
            priv_bins(i).hits            := priv_bins(i).hits + 1;
            -- Increment bin in UCDB model
            fli_increment_ucdb_bin(priv_ucdb_handle, i+1);
            v_num_occurrences            := v_num_occurrences + 1;
            -- Update covergroup status register
            protected_covergroup_status.increment_hits_count(priv_id); -- Count the total hits
            if priv_bins(i).hits <= priv_bins(i).min_hits then
              protected_covergroup_status.increment_coverage_hits_count(priv_id); -- Count until min_hits has been reached
            end if;
            if priv_bins(i).hits <= get_total_min_hits(priv_bins(i).min_hits) then
              protected_covergroup_status.increment_goal_hits_count(priv_id); -- Count until min_hits x goal has been reached
            end if;
            if priv_bins(i).hits = priv_bins(i).min_hits and priv_bins(i).min_hits /= 0 then
              protected_covergroup_status.increment_covered_bin_count(priv_id); -- Count the covered bins
            end if;
          end if;
          v_value_match := (others => '0');
        end loop;

        if v_num_occurrences > 1 then
          alert(priv_bin_overlap_alert_level, get_name_prefix(VOID) & "There is an overlap between " & to_string(v_num_occurrences) & " bins.", priv_scope);
        end if;
      else
        -- When an ignore or illegal bin is sampled, valid bins won't be sampled so we need to clear all transition masks in the valid bins
        for i in 0 to priv_bins_idx - 1 loop
          priv_bins(i).transition_mask := (others => '0');
        end loop;
      end if;

      DEALLOCATE(v_proc_call);
      priv_sampled_coverpoint := true;
    end procedure;

    impure function get_coverage(
      constant coverage_type      : t_coverage_type;
      constant percentage_of_goal : boolean := false)
    return real is
      constant C_LOCAL_CALL              : string := "get_coverage(" & to_upper(to_string(coverage_type)) & ")";
      variable v_coverage_representation : t_coverage_representation;
    begin
      vendor_get_bin_hits(VOID); -- Update coverage from auto-sampled coverpoints
      if priv_id /= C_DEALLOCATED_ID then
        v_coverage_representation := GOAL_CAPPED when percentage_of_goal else NO_GOAL;
        if coverage_type = BINS then
          return protected_covergroup_status.get_bins_coverage(priv_id, v_coverage_representation);
        elsif coverage_type = HITS then
          return protected_covergroup_status.get_hits_coverage(priv_id, v_coverage_representation);
        else                            -- BINS_AND_HITS
          alert(TB_ERROR, C_LOCAL_CALL & "=> Use either BINS or HITS.", priv_scope);
          return 0.0;
        end if;
      else
        return 0.0;
      end if;
    end function;

    impure function coverage_completed(
      constant coverage_type : t_coverage_type)
    return boolean is
    begin
      vendor_get_bin_hits(VOID); -- Update coverage from auto-sampled coverpoints
      if priv_id /= C_DEALLOCATED_ID then
        if coverage_type = BINS then
          return protected_covergroup_status.get_bins_coverage(priv_id, GOAL_CAPPED) = 100.0;
        elsif coverage_type = HITS then
          return protected_covergroup_status.get_hits_coverage(priv_id, GOAL_CAPPED) = 100.0;
        else                            -- BINS_AND_HITS
          return protected_covergroup_status.get_bins_coverage(priv_id, GOAL_CAPPED) = 100.0 and protected_covergroup_status.get_hits_coverage(priv_id, GOAL_CAPPED) = 100.0;
        end if;
      else
        return false;
      end if;
    end function;

    procedure report_coverage(
      constant VOID : in t_void) is
    begin
      report_coverage(NON_VERBOSE);
    end procedure;

    procedure report_coverage(
      constant verbosity       : in t_report_verbosity;
      constant file_name       : in string                   := "";
      constant open_mode       : in file_open_kind           := append_mode;
      constant rand_weight_col : in t_rand_weight_visibility := HIDE_RAND_WEIGHT) is
      file file_handler           : text;
      constant C_PREFIX           : string   := C_LOG_PREFIX & "     ";
      constant C_HEADER_1         : string   := "*** COVERAGE SUMMARY REPORT (VERBOSE): " & to_string(priv_scope) & " ***";
      constant C_HEADER_2         : string   := "*** COVERAGE SUMMARY REPORT (NON VERBOSE): " & to_string(priv_scope) & " ***";
      constant C_HEADER_3         : string   := "*** COVERAGE HOLES REPORT: " & to_string(priv_scope) & " ***";
      constant C_BIN_COLUMN_WIDTH : positive := 40;
      constant C_COLUMN_WIDTH     : positive := 15;
      variable v_line             : line;
      variable v_log_extra_space  : integer  := 0;
      variable v_print_goal       : boolean;
      variable v_rand_weight      : natural;
    begin
      initialize_util(VOID); -- Only executed the first time called. Ensures that the log and alert files are open.
      vendor_get_bin_hits(VOID); -- Update coverage from auto-sampled coverpoints
      -- Calculate how much space we can insert between the columns of the report
      v_log_extra_space := (C_LOG_LINE_WIDTH - C_PREFIX'length - C_BIN_COLUMN_WIDTH - C_COLUMN_WIDTH * 5 - C_FC_MAX_NAME_LENGTH) / 8;
      if v_log_extra_space < 1 then
        alert(TB_WARNING, "C_LOG_LINE_WIDTH is too small or C_FC_MAX_NAME_LENGTH is too big, the report will not be properly aligned.", priv_scope);
        v_log_extra_space := 1;
      end if;

      vendor_get_bin_hits(VOID);

      -- Print report header
      write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
      if verbosity = VERBOSE then
        write(v_line, timestamp_header(now, justify(C_HEADER_1, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
      elsif verbosity = NON_VERBOSE then
        write(v_line, timestamp_header(now, justify(C_HEADER_2, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
      elsif verbosity = HOLES_ONLY then
        write(v_line, timestamp_header(now, justify(C_HEADER_3, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF);
      end if;
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print summary
      if priv_id /= C_DEALLOCATED_ID then
        v_print_goal := protected_covergroup_status.get_bins_coverage_goal(priv_id) /= 100 or
                        protected_covergroup_status.get_hits_coverage_goal(priv_id) /= 100;
        write(v_line, "Coverpoint:              " & to_string(priv_name) &
                      return_string_if_true("    (accumulated over this and " & to_string(priv_num_tc_accumulated) & " previous testcases)", priv_loaded_coverpoint) & LF &
                      return_string_if_true("Goal:                    " &
                        justify("Bins: " & to_string(protected_covergroup_status.get_bins_coverage_goal(priv_id)) & "%, ", left, 16, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                        justify("Hits: " & to_string(protected_covergroup_status.get_hits_coverage_goal(priv_id)) & "%", left, 14, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF, v_print_goal) &
                      return_string_if_true("% of Goal:               " &
                        justify("Bins: " & to_string(protected_covergroup_status.get_bins_coverage(priv_id, GOAL_CAPPED), 2) & "%, ", left, 16, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                        justify("Hits: " & to_string(protected_covergroup_status.get_hits_coverage(priv_id, GOAL_CAPPED), 2) & "%", left, 14, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF, v_print_goal) &
                      return_string_if_true("% of Goal (uncapped):    " &
                        justify("Bins: " & to_string(protected_covergroup_status.get_bins_coverage(priv_id, GOAL_UNCAPPED), 2) & "%, ", left, 16, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                        justify("Hits: " & to_string(protected_covergroup_status.get_hits_coverage(priv_id, GOAL_UNCAPPED), 2) & "%", left, 14, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF, v_print_goal) &
                      "Coverage (for goal 100): " &
                        justify("Bins: " & to_string(protected_covergroup_status.get_bins_coverage(priv_id, NO_GOAL), 2) & "%, ", left, 16, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                        justify("Hits: " & to_string(protected_covergroup_status.get_hits_coverage(priv_id, NO_GOAL), 2) & "%", left, 14, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF &
                      fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
      else
        write(v_line, "Coverpoint:              " & to_string(priv_name) & LF &
                      "Coverage (for goal 100): " &
                        justify("Bins: 0.0%, ", left, 16, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) &
                        justify("Hits: 0.0%", left, 14, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF &
                      fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
      end if;

      -- Print column headers
      write(v_line, justify(
        fill_string(' ', v_log_extra_space) &
        justify("BINS", center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("HITS", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("MIN HITS", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("HIT COVERAGE", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        return_string_if_true(justify("RAND WEIGHT", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space), rand_weight_col = SHOW_RAND_WEIGHT) &
        justify("NAME", center, C_FC_MAX_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("ILLEGAL/IGNORE", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
        left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);

      -- Print illegal bins
      for i in 0 to priv_invalid_bins_idx - 1 loop
        if is_bin_illegal(priv_invalid_bins(i)) and (verbosity = VERBOSE or (verbosity = NON_VERBOSE and priv_invalid_bins(i).hits > 0)) then
          write(v_line, justify(
            fill_string(' ', v_log_extra_space) &
            justify(get_bin_values(priv_invalid_bins(i), C_BIN_COLUMN_WIDTH), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_invalid_bins(i).hits), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            return_string_if_true(justify("N/A", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space), rand_weight_col = SHOW_RAND_WEIGHT) &
            justify(to_string(priv_invalid_bins(i).name), center, C_FC_MAX_NAME_LENGTH, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("ILLEGAL", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
            left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
        end if;
      end loop;

      -- Print ignore bins
      if verbosity = VERBOSE then
        for i in 0 to priv_invalid_bins_idx - 1 loop
          if is_bin_ignore(priv_invalid_bins(i)) then
            write(v_line, justify(
              fill_string(' ', v_log_extra_space) &
              justify(get_bin_values(priv_invalid_bins(i), C_BIN_COLUMN_WIDTH), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify(to_string(priv_invalid_bins(i).hits), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("N/A", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("N/A", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              return_string_if_true(justify("N/A", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space), rand_weight_col = SHOW_RAND_WEIGHT) &
              justify(to_string(priv_invalid_bins(i).name), center, C_FC_MAX_NAME_LENGTH, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
              justify("IGNORE", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
              left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
          end if;
        end loop;
      end if;

      -- Print valid bins
      for i in 0 to priv_bins_idx - 1 loop
        if verbosity = VERBOSE or verbosity = NON_VERBOSE or (verbosity = HOLES_ONLY and priv_bins(i).hits < get_total_min_hits(priv_bins(i).min_hits)) then
          v_rand_weight := priv_bins(i).min_hits when priv_bins(i).rand_weight = C_USE_ADAPTIVE_WEIGHT else priv_bins(i).rand_weight;
          write(v_line, justify(
            fill_string(' ', v_log_extra_space) &
            justify(get_bin_values(priv_bins(i), C_BIN_COLUMN_WIDTH), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).hits), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).min_hits), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_bin_coverage(priv_bins(i)), 2) & "%", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            return_string_if_true(justify(to_string(v_rand_weight), center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space), rand_weight_col = SHOW_RAND_WEIGHT) &
            justify(to_string(priv_bins(i).name), center, C_FC_MAX_NAME_LENGTH, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("-", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
            left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
        end if;
      end loop;

      write(v_line, fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print bin values that didn't fit in section above
      for i in 0 to priv_invalid_bins_idx - 1 loop
        if is_bin_illegal(priv_invalid_bins(i)) and (verbosity = VERBOSE or (verbosity = NON_VERBOSE and priv_invalid_bins(i).hits > 0)) then
          if get_bin_values(priv_invalid_bins(i), C_BIN_COLUMN_WIDTH) = to_string(priv_invalid_bins(i).name) then
            write(v_line, to_string(priv_invalid_bins(i).name) & ": " & get_bin_values(priv_invalid_bins(i)) & LF);
          end if;
        end if;
      end loop;
      if verbosity = VERBOSE then
        for i in 0 to priv_invalid_bins_idx - 1 loop
          if is_bin_ignore(priv_invalid_bins(i)) then
            if get_bin_values(priv_invalid_bins(i), C_BIN_COLUMN_WIDTH) = to_string(priv_invalid_bins(i).name) then
              write(v_line, to_string(priv_invalid_bins(i).name) & ": " & get_bin_values(priv_invalid_bins(i)) & LF);
            end if;
          end if;
        end loop;
      end if;
      for i in 0 to priv_bins_idx - 1 loop
        if verbosity = VERBOSE or verbosity = NON_VERBOSE or (verbosity = HOLES_ONLY and priv_bins(i).hits < get_total_min_hits(priv_bins(i).min_hits)) then
          if get_bin_values(priv_bins(i), C_BIN_COLUMN_WIDTH) = to_string(priv_bins(i).name) then
            write(v_line, to_string(priv_bins(i).name) & ": " & get_bin_values(priv_bins(i)) & LF);
          end if;
        end if;
      end loop;

      -- Print report bottom line
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

      -- Format the report
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
      prefix_lines(v_line, C_PREFIX);

      -- Write the report to a separate file if specified
      if file_name /= "" then
        file_open(file_handler, file_name, open_mode);
        tee_and_keep_line(file_handler, v_line); -- Write to file, while keeping the line contents
        file_close(file_handler);
      end if;
      -- Write the report to the log destination
      write_line_to_log_destination(v_line);
      deallocate(v_line);
    end procedure;

    procedure report_config(
      constant VOID : in t_void) is
    begin
      report_config("");
    end procedure;

    procedure report_config(
      constant file_name : in string;
      constant open_mode : in file_open_kind := append_mode) is
      file file_handler        : text;
      constant C_PREFIX        : string   := C_LOG_PREFIX & "     ";
      constant C_COLUMN1_WIDTH : positive := 24;
      constant C_COLUMN2_WIDTH : positive := MAXIMUM(C_FC_MAX_NAME_LENGTH, C_LOG_SCOPE_WIDTH);
      variable v_line          : line;
    begin
      initialize_util(VOID); -- Only executed the first time called. Ensures that the log and alert files are open.
      -- Print report header
      write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
                    "***  COVERPOINT CONFIGURATION REPORT ***" & LF &
                    fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print report config
      if priv_id /= C_DEALLOCATED_ID then
        write(v_line, "          " & justify("NAME", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_name), right, C_COLUMN2_WIDTH) & LF);
      else
        write(v_line, "          " & justify("NAME", left, C_COLUMN1_WIDTH) & ": " & justify("**uninitialized**", right, C_COLUMN2_WIDTH) & LF);
      end if;
      write(v_line, "          " & justify("SCOPE", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_scope), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("ILLEGAL BIN ALERT LEVEL", left, C_COLUMN1_WIDTH) & ": " & justify(to_upper(to_string(priv_illegal_bin_alert_level)), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("BIN OVERLAP ALERT LEVEL", left, C_COLUMN1_WIDTH) & ": " & justify(to_upper(to_string(priv_bin_overlap_alert_level)), right, C_COLUMN2_WIDTH) & LF);
      if priv_id /= C_DEALLOCATED_ID then
        write(v_line, "          " & justify("COVERAGE WEIGHT", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(protected_covergroup_status.get_coverage_weight(priv_id)), right, C_COLUMN2_WIDTH) & LF);
        write(v_line, "          " & justify("BINS COVERAGE GOAL", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(protected_covergroup_status.get_bins_coverage_goal(priv_id)), right, C_COLUMN2_WIDTH) & LF);
        write(v_line, "          " & justify("HITS COVERAGE GOAL", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(protected_covergroup_status.get_hits_coverage_goal(priv_id)), right, C_COLUMN2_WIDTH) & LF);
      else
        write(v_line, "          " & justify("COVERAGE WEIGHT", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(1), right, C_COLUMN2_WIDTH) & LF);
        write(v_line, "          " & justify("BINS COVERAGE GOAL", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(100), right, C_COLUMN2_WIDTH) & LF);
        write(v_line, "          " & justify("HITS COVERAGE GOAL", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(100), right, C_COLUMN2_WIDTH) & LF);
      end if;
      write(v_line, "          " & justify("COVERPOINTS GOAL", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(protected_covergroup_status.get_covpts_coverage_goal(VOID)), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("NUMBER OF BINS", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_bins_idx + priv_invalid_bins_idx), right, C_COLUMN2_WIDTH) & LF);
      write(v_line, "          " & justify("CROSS DIMENSIONS", left, C_COLUMN1_WIDTH) & ": " & justify(to_string(priv_num_bins_crossed), right, C_COLUMN2_WIDTH) & LF);

      -- Print report bottom line
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

      -- Format the report
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
      prefix_lines(v_line, C_PREFIX);

      -- Write the report to a separate file if specified
      if file_name /= "" then
        file_open(file_handler, file_name, open_mode);
        tee_and_keep_line(file_handler, v_line); -- Write to file, while keeping the line contents
        file_close(file_handler);
      end if;
      -- Write the report to the log destination
      write_line_to_log_destination(v_line);
      deallocate(v_line);
    end procedure;

    ------------------------------------------------------------
    -- Optimized Randomization
    ------------------------------------------------------------
    impure function rand(
      constant sampling     : t_rand_sample_cov;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel)
    return integer is
      constant C_LOCAL_CALL : string := "rand(" & to_upper(to_string(sampling)) & ")";
      variable v_ret        : integer_vector(0 to 0);
    begin
      v_ret := rand(sampling, msg_id_panel, C_LOCAL_CALL);
      if priv_num_bins_crossed /= C_UNINITIALIZED then
        log(ID_FUNC_COV_RAND, get_name_prefix(VOID) & C_LOCAL_CALL & "=> " & to_string(v_ret(0)), priv_scope, msg_id_panel);
      end if;
      return v_ret(0);
    end function;

    impure function rand(
      constant sampling      : t_rand_sample_cov;
      constant msg_id_panel  : t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : string         := "")
    return integer_vector is
      constant C_LOCAL_CALL      : string  := "rand(" & to_upper(to_string(sampling)) & ")";
      constant C_MSG_ID_ENABLED  : boolean := msg_id_panel(ID_RAND_GEN) = ENABLED;
      variable v_bin_weight_list : t_val_weight_int_vec(0 to priv_bins_idx - 1);
      variable v_acc_weight      : natural := 0;
      variable v_values_vec      : integer_vector(0 to C_FC_MAX_NUM_BIN_VALUES - 1);
      variable v_bin_idx         : natural;
      variable v_ret             : integer_vector(0 to MAXIMUM(priv_num_bins_crossed, 1) - 1);
      variable v_hits            : natural := 0;
      variable v_iteration       : natural := 0;
    begin
      if priv_num_bins_crossed = C_UNINITIALIZED then
        alert(TB_ERROR, C_LOCAL_CALL & "=> Coverpoint does not contain any bins", priv_scope);
        return v_ret;
      end if;
      if C_MSG_ID_ENABLED then
        disable_log_msg(ID_RAND_GEN, QUIET);
      end if;

      -- A transition bin returns all the transition values before allowing to select a different bin value
      if priv_rand_transition_bin_idx /= C_UNINITIALIZED then
        v_bin_idx := priv_rand_transition_bin_idx;
      else
        -- Assign each bin a randomization weight
        while v_acc_weight = 0 loop
          for i in 0 to priv_bins_idx - 1 loop
            v_bin_weight_list(i).value := i;
            v_hits                     := priv_bins(i).hits - (v_iteration * get_total_min_hits(priv_bins(i).min_hits));
            if v_hits < get_total_min_hits(priv_bins(i).min_hits) then
              v_bin_weight_list(i).weight := get_total_min_hits(priv_bins(i).min_hits) - v_hits when priv_bins(i).rand_weight = C_USE_ADAPTIVE_WEIGHT else
                                             priv_bins(i).rand_weight;
            else
              v_bin_weight_list(i).weight := 0;
            end if;
            v_acc_weight               := v_acc_weight + v_bin_weight_list(i).weight;
          end loop;
          -- When all the bins have reached their min_hits, the accumulated weight will be 0 and
          -- a new iteration will be done where all the bins are uncovered again by simulating
          -- the number of hits are cleared
          v_iteration := v_iteration + 1;
        end loop;

        -- Choose a random bin index
        v_bin_idx := priv_rand_gen.rand_val_weight(v_bin_weight_list, msg_id_panel);
      end if;

      -- Select the random bin values to return (ignore and illegal bin values are never selected)
      for i in 0 to priv_num_bins_crossed - 1 loop
        v_values_vec := (others => 0);
        if priv_bins(v_bin_idx).cross_bins(i).contains = VAL then
          if priv_bins(v_bin_idx).cross_bins(i).num_values = 1 then
            v_ret(i) := priv_bins(v_bin_idx).cross_bins(i).values(0);
          else
            for j in 0 to priv_bins(v_bin_idx).cross_bins(i).num_values - 1 loop
              v_values_vec(j) := priv_bins(v_bin_idx).cross_bins(i).values(j);
            end loop;
            v_ret(i) := priv_rand_gen.rand(ONLY, v_values_vec(0 to priv_bins(v_bin_idx).cross_bins(i).num_values - 1), NON_CYCLIC, msg_id_panel);
          end if;
        elsif priv_bins(v_bin_idx).cross_bins(i).contains = RAN then
          v_ret(i) := priv_rand_gen.rand(priv_bins(v_bin_idx).cross_bins(i).values(0), priv_bins(v_bin_idx).cross_bins(i).values(1), NON_CYCLIC, msg_id_panel);
        elsif priv_bins(v_bin_idx).cross_bins(i).contains = TRN then
          -- Store the bin index to return the next value in the following rand() call
          if priv_rand_transition_bin_idx = C_UNINITIALIZED then
            priv_rand_transition_bin_idx := v_bin_idx;
          end if;
          v_ret(i) := priv_bins(v_bin_idx).cross_bins(i).values(priv_rand_transition_bin_value_idx(i));
          if priv_rand_transition_bin_value_idx(i) < priv_bins(v_bin_idx).cross_bins(i).num_values then
            priv_rand_transition_bin_value_idx(i) := priv_rand_transition_bin_value_idx(i) + 1;
          end if;
        else
          alert(TB_FAILURE, C_LOCAL_CALL & "=> Unexpected error, bin contains " & to_upper(to_string(priv_bins(v_bin_idx).cross_bins(i).contains)), priv_scope);
        end if;

        -- Reset transition index variables when all the transitions in a bin have been generated
        if i = priv_num_bins_crossed - 1 and priv_rand_transition_bin_idx /= C_UNINITIALIZED then
          for j in 0 to priv_num_bins_crossed - 1 loop
            if priv_bins(v_bin_idx).cross_bins(j).contains = TRN and priv_rand_transition_bin_value_idx(j) < priv_bins(v_bin_idx).cross_bins(j).num_values then
              exit;
            elsif j = priv_num_bins_crossed - 1 then
              priv_rand_transition_bin_idx       := C_UNINITIALIZED;
              priv_rand_transition_bin_value_idx := (others => 0);
            end if;
          end loop;
        end if;
      end loop;

      if sampling = SAMPLE_COV then
        sample_coverage(v_ret, msg_id_panel, C_LOCAL_CALL);
      end if;

      if ext_proc_call = "" then        -- Do not print log message when being called from another method
        log(ID_FUNC_COV_RAND, get_name_prefix(VOID) & C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      end if;
      if C_MSG_ID_ENABLED then
        enable_log_msg(ID_RAND_GEN, QUIET);
      end if;
      return v_ret;
    end function;

    procedure set_rand_seeds(
      constant seed1 : in positive;
      constant seed2 : in positive) is
    begin
      initialize_coverpoint("set_rand_seeds");
      priv_rand_gen.set_rand_seeds(seed1, seed2);
    end procedure;

    procedure set_rand_seeds(
      constant seeds : in t_positive_vector(0 to 1)) is
    begin
      initialize_coverpoint("set_rand_seeds");
      priv_rand_gen.set_rand_seeds(seeds);
    end procedure;

    procedure get_rand_seeds(
      variable seed1 : out positive;
      variable seed2 : out positive) is
    begin
      priv_rand_gen.get_rand_seeds(seed1, seed2);
    end procedure;

    impure function get_rand_seeds(
      constant VOID : t_void)
    return t_positive_vector is
    begin
      return priv_rand_gen.get_rand_seeds(VOID);
    end function;

    -- Requires Questa One 2026.1 or newer
    procedure enable_auto_sampling(
      constant target       : in string;
      constant trigger      : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      if (C_VENDOR_EXTENSION_IS_ENABLED) then
        check_and_initialize_vendor_coverpoint_id(void);
        vendor_func_cov_set_coverpoint_var(priv_vendor_coverpoint_id, target);
        vendor_func_cov_set_sampling_var(priv_vendor_coverpoint_id, trigger);
        return;
      else
        alert(TB_ERROR, "Procedure enable_auto_sampling() is only supported in Questa One 2026.1 and newer", C_SCOPE);
      end if;
    end procedure;

  end protected body t_coverpoint;

end package body func_cov_pkg;
