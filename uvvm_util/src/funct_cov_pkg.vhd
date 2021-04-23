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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

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

package funct_cov_pkg is

  constant C_MAX_NUM_CROSS_BINS   : positive := 16;
  --TODO: move to adaptations_pkg?
  constant C_MAX_NUM_BINS         : positive := 100; --Q: make it possible to grow?
  constant C_MAX_NUM_BIN_VALUES   : positive := 10;

  ------------------------------------------------------------
  -- Types
  ------------------------------------------------------------
  type t_cov_bin_type is (VAL, VAL_IGNORE, VAL_ILLEGAL, RAN, RAN_IGNORE, RAN_ILLEGAL, TRN, TRN_IGNORE, TRN_ILLEGAL);

  type t_new_bin is record
    contains   : t_cov_bin_type;
    values     : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
    num_values : natural;
  end record;
  type t_new_bin_vector is array (natural range <>) of t_new_bin;

  type t_new_cov_bin is record
    bin_vector : t_new_bin_vector(0 to C_MAX_NUM_BINS-1);
    num_bins   : natural;
    proc_call  : string(1 to C_FC_MAX_PROC_CALL_LENGTH);
  end record;
  type t_new_bin_array is array (natural range <>) of t_new_cov_bin;
  constant C_EMPTY_NEW_BIN_ARRAY : t_new_bin_array(0 to 0) := (0 => ((0 to C_MAX_NUM_BINS-1 => (VAL, (others => 0), 0)),
                                                                     0,
                                                                     (1 to C_FC_MAX_PROC_CALL_LENGTH => ' ')));

  type t_bin is record
    contains       : t_cov_bin_type;
    values         : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
    num_values     : natural;
    transition_idx : natural;
  end record;
  type t_bin_vector is array (natural range <>) of t_bin;

  type t_cov_bin is record
    cross_bins     : t_bin_vector(0 to C_MAX_NUM_CROSS_BINS-1);
    hits           : natural;
    min_hits       : natural;
    rand_weight    : natural;
    name           : string(1 to C_FC_MAX_NAME_LENGTH);
  end record;
  type t_cov_bin_vector is array (natural range <>) of t_cov_bin;

  ------------------------------------------------------------
  -- Bin functions
  ------------------------------------------------------------
  -- Creates a bin with a single value
  impure function bin(
    constant value      : integer)
  return t_new_bin_array;

  -- Creates a bin with multiple values
  impure function bin(
    constant set_values : integer_vector)
  return t_new_bin_array;

  -- Divides a range of values into a number bins. If num_bins is 0 then a bin is created for each value.
  impure function bin_range(
    constant min_value     : integer;
    constant max_value     : integer;
    constant num_bins      : natural := 0;
    constant ext_proc_call : string  := "")
  return t_new_bin_array;

  -- Divides a vector's range into a number bins. If num_bins is 0 then a bin is created for each value.
  impure function bin_vector(
    constant vector     : std_logic_vector;
    constant num_bins   : natural := 0)
  return t_new_bin_array;

  -- Creates a bin with a transition of values
  impure function bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_array;

  -- Creates an ignore bin with a single value
  impure function ignore_bin(
    constant value      : integer)
  return t_new_bin_array;

  -- Creates an ignore bin with a range of values
  impure function ignore_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_array;

  -- Creates an ignore bin with a transition of values
  impure function ignore_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_array;

  -- Creates an illegal bin with a single value
  impure function illegal_bin(
    constant value      : integer)
  return t_new_bin_array;

  -- Creates an illegal bin with a range of values
  impure function illegal_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_array;

  -- Creates an illegal bin with a transition of values
  impure function illegal_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_array;

  ------------------------------------------------------------
  -- Simulation coverage
  ------------------------------------------------------------
  procedure set_sim_coverage_goal(
    constant percentage   : in positive;
    constant scope        : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

  impure function get_sim_coverage(
    constant VOID : t_void)
  return real;

  impure function sim_coverage_completed(
    constant VOID : t_void)
  return boolean;

  procedure print_sim_coverage_summary(
    constant VOID : in t_void);

  procedure print_sim_coverage_summary(
    constant scope : in string);

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

    procedure detect_bin_overlap(
      constant enable       : in boolean;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure write_coverage_db(
      constant file_name    : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure load_coverage_db(
      constant file_name    : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    -- Returns the number of bins crossed in the coverpoint
    impure function get_num_bins_crossed(
      constant VOID : t_void)
    return integer;

    -- Returns the number of bins in the coverpoint
    impure function get_num_bins(
      constant VOID : t_void)
    return natural;

    -- Returns the number of illegal and ignore bins in the coverpoint
    impure function get_num_invalid_bins(
      constant VOID : t_void)
    return natural;

    -- Returns a vector with the bins in the coverpoint
    impure function get_bins(
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
      constant bin           : in t_new_bin_array;
      constant min_hits      : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_bins(
      constant bin           : in t_new_bin_array;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    -- TODO: max 5 dimensions
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
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

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
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    -- TODO: max 16 dimensions
    ------------------------------------------------------------
    -- Add cross (2 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant min_hits      : in    positive;
      constant rand_weight   : in    natural;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in    string         := "");

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant min_hits      : in    positive;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Add cross (3 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      constant min_hits      : in    positive;
      constant rand_weight   : in    natural;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in    string         := "");

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      constant min_hits      : in    positive;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Randomization
    ------------------------------------------------------------
    impure function rand(
      constant VOID : t_void)
    return integer;

    impure function rand(
      constant msg_id_panel : t_msg_id_panel)
    return integer;

    impure function rand(
      constant VOID : t_void)
    return integer_vector;

    impure function rand(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return integer_vector;

    ------------------------------------------------------------
    -- Coverage
    ------------------------------------------------------------
    procedure sample_coverage(
      constant value         : in integer;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure sample_coverage(
      constant values        : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "");

    procedure set_coverage_weight(
      constant weight       : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    procedure set_coverage_goal(
      constant percentage   : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel);

    impure function get_coverage(
      constant VOID : t_void)
    return real;

    impure function coverage_completed(
      constant VOID : t_void)
    return boolean;

    procedure print_summary(
      constant VOID : in t_void);

  end protected t_coverpoint;

end package funct_cov_pkg;

package body funct_cov_pkg is

  -- Generates the correct procedure call to be used for logging or alerts
  procedure create_proc_call(
    constant proc_call     : in    string;
    constant ext_proc_call : in    string;
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

  ------------------------------------------------------------
  -- Bin functions
  ------------------------------------------------------------
  -- Creates a bin with a single value
  impure function bin(
    constant value      : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin(" & to_string(value) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := VAL;
    v_ret(0).bin_vector(0).values(0)  := value;
    v_ret(0).bin_vector(0).num_values := 1;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Creates a bin with multiple values
  impure function bin(
    constant set_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin(" & to_string(set_values) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := VAL;
    v_ret(0).bin_vector(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).bin_vector(0).num_values := set_values'length;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Divides a range of values into a number bins. If num_bins is 0 then a bin is created for each value.
  impure function bin_range(
    constant min_value     : integer;
    constant max_value     : integer;
    constant num_bins      : natural := 0;
    constant ext_proc_call : string  := "")
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin_range(" & to_string(min_value) & ", " & to_string(max_value) &
      return_string_if_true(", num_bins:" & to_string(num_bins), num_bins > 0) & ")";
    constant C_RANGE_WIDTH     : integer := abs(max_value - min_value) + 1;
    variable v_proc_call       : line;
    variable v_div_range       : integer;
    variable v_div_residue     : integer := 0;
    variable v_div_residue_min : integer := 0;
    variable v_div_residue_max : integer := 0;
    variable v_num_bins        : integer := 0;
    variable v_ret             : t_new_bin_array(0 to 0);
  begin
    create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);

    if min_value <= max_value then
      -- Create a bin for each value in the range
      if num_bins = 0 then
        for i in min_value to max_value loop
          v_ret(0).bin_vector(i-min_value).contains   := VAL;
          v_ret(0).bin_vector(i-min_value).values(0)  := i;
          v_ret(0).bin_vector(i-min_value).num_values := 1;
        end loop;
        v_num_bins := C_RANGE_WIDTH;
      -- Create several bins
      else
        -- Range is divided into a number of bins
        if C_RANGE_WIDTH > num_bins then
          v_div_residue := C_RANGE_WIDTH mod num_bins;
          v_div_range   := C_RANGE_WIDTH / num_bins;
          v_num_bins    := num_bins;
          for i in 0 to v_num_bins-1 loop
            -- Add the residue values to the last bins
            if v_div_residue /= 0 and i = v_num_bins-v_div_residue then
              v_div_residue_max := v_div_residue_max + 1;
            elsif v_div_residue /= 0 and i > v_num_bins-v_div_residue then
              v_div_residue_min := v_div_residue_min + 1;
              v_div_residue_max := v_div_residue_max + 1;
            end if;
            v_ret(0).bin_vector(i).contains   := RAN;
            v_ret(0).bin_vector(i).values(0)  := min_value + v_div_range*i + v_div_residue_min;
            v_ret(0).bin_vector(i).values(1)  := min_value + v_div_range*(i+1)-1 + v_div_residue_max;
            v_ret(0).bin_vector(i).num_values := 2;
          end loop;
        -- Range is smaller than the number of bins, create a bin for each value in the range
        else
          for i in min_value to max_value loop
            v_ret(0).bin_vector(i-min_value).contains   := VAL;
            v_ret(0).bin_vector(i-min_value).values(0)  := i;
            v_ret(0).bin_vector(i-min_value).num_values := 1;
          end loop;
          v_num_bins := C_RANGE_WIDTH;
        end if;
      end if;
    else
      alert(TB_ERROR, v_proc_call.all & "=> Failed. min_value must be less or equal than max_value", C_TB_SCOPE_DEFAULT);
    end if;
    v_ret(0).num_bins := v_num_bins;
    v_ret(0).proc_call(1 to v_proc_call'length) := v_proc_call.all;
    DEALLOCATE(v_proc_call);
    return v_ret;
  end function;

  -- Divides a vector's range into a number bins. If num_bins is 0 then a bin is created for each value.
  impure function bin_vector(
    constant vector     : std_logic_vector;
    constant num_bins   : natural := 0)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin_vector(LEN:" & to_string(vector'length) & return_string_if_true(", num_bins:" & to_string(num_bins), num_bins > 0) & ")";
  begin
    return bin_range(0, 2**vector'length-1, num_bins, C_LOCAL_CALL);
  end function;

  -- Creates a bin with a transition of values
  impure function bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "bin_transition(" & to_string(set_values) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := TRN;
    v_ret(0).bin_vector(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).bin_vector(0).num_values := set_values'length;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Creates an ignore bin with a single value
  impure function ignore_bin(
    constant value      : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "ignore_bin(" & to_string(value) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := VAL_IGNORE;
    v_ret(0).bin_vector(0).values(0)  := value;
    v_ret(0).bin_vector(0).num_values := 1;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Creates an ignore bin with a range of values
  impure function ignore_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "ignore_bin_range(" & to_string(min_value) & "," & to_string(max_value) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := RAN_IGNORE;
    v_ret(0).bin_vector(0).values(0)  := min_value;
    v_ret(0).bin_vector(0).values(1)  := max_value;
    v_ret(0).bin_vector(0).num_values := 2;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Creates an ignore bin with a transition of values
  impure function ignore_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "ignore_bin_transition(" & to_string(set_values) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := TRN_IGNORE;
    v_ret(0).bin_vector(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).bin_vector(0).num_values := set_values'length;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Creates an illegal bin with a single value
  impure function illegal_bin(
    constant value      : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "illegal_bin(" & to_string(value) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := VAL_ILLEGAL;
    v_ret(0).bin_vector(0).values(0)  := value;
    v_ret(0).bin_vector(0).num_values := 1;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Creates an illegal bin with a range of values
  impure function illegal_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "illegal_bin_range(" & to_string(min_value) & "," & to_string(max_value) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := RAN_ILLEGAL;
    v_ret(0).bin_vector(0).values(0)  := min_value;
    v_ret(0).bin_vector(0).values(1)  := max_value;
    v_ret(0).bin_vector(0).num_values := 2;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  -- Creates an illegal bin with a transition of values
  impure function illegal_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_array is
    constant C_LOCAL_CALL : string := "illegal_bin_transition(" & to_string(set_values) & ")";
    variable v_ret : t_new_bin_array(0 to 0);
  begin
    v_ret(0).bin_vector(0).contains   := TRN_ILLEGAL;
    v_ret(0).bin_vector(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).bin_vector(0).num_values := set_values'length;
    v_ret(0).num_bins := 1;
    v_ret(0).proc_call(1 to C_LOCAL_CALL'length) := C_LOCAL_CALL;
    return v_ret;
  end function;

  ------------------------------------------------------------
  -- Simulation coverage
  ------------------------------------------------------------
  procedure set_sim_coverage_goal(
    constant percentage   : in positive;
    constant scope        : in string         := C_TB_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
    constant C_LOCAL_CALL : string := "set_sim_coverage_goal(" & to_string(percentage) & ")";
  begin
    log(ID_FUNCT_COV_CONFIG, C_LOCAL_CALL, scope, msg_id_panel);
    protected_covergroup_status.set_covergroup_coverage_goal(percentage);
  end procedure;

  impure function get_sim_coverage(
    constant VOID : t_void)
  return real is
  begin
    return protected_covergroup_status.get_total_hits_coverage(VOID);
  end function;

  impure function sim_coverage_completed(
    constant VOID : t_void)
  return boolean is
  begin
    return protected_covergroup_status.get_total_hits_coverage(VOID) >= real(protected_covergroup_status.get_covergroup_coverage_goal(VOID));
  end function;

  procedure print_sim_coverage_summary(
    constant VOID : in t_void) is
  begin
    print_sim_coverage_summary(C_TB_SCOPE_DEFAULT);
  end procedure;

  procedure print_sim_coverage_summary(
    constant scope : in string) is
    constant C_PREFIX : string := C_LOG_PREFIX & "     ";
    constant C_HEADER : string := "*** FUNCTIONAL COVERAGE SUMMARY: " & to_string(scope) & " ***";
    variable v_line   : line;
  begin
    -- Print report header
    write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
                  timestamp_header(now, justify(C_HEADER, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF &
                  "Total Hits Coverage: " & to_string(protected_covergroup_status.get_total_hits_coverage(VOID),2) & "% (goal: " & to_string(protected_covergroup_status.get_covergroup_coverage_goal(VOID)) & "%)" & LF &
                  fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)));

    -- Print coverpoints summaries
    for i in 0 to protected_covergroup_status.get_num_coverpoints(VOID)-1 loop
      write(v_line, "Coverpoint:      " & protected_covergroup_status.get_name(i) & LF &
                    "Uncovered bins:  " & to_string(protected_covergroup_status.get_num_uncovered_bins(i)) & LF &
                    "Illegal bins:    " & to_string(protected_covergroup_status.get_num_illegal_bins(i)) & LF &
                    "Coverage:        bins: " & to_string(protected_covergroup_status.get_bins_coverage(i),2) & "% hits: " & to_string(protected_covergroup_status.get_hits_coverage(i),2)
                      & "% (goal: " & to_string(protected_covergroup_status.get_coverage_goal(i)) & "%)" & LF &
                    "Coverage weight: " & to_string(protected_covergroup_status.get_coverage_weight(i)) & LF &
                    fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    end loop;

    -- Print report bottom line
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

    -- Write the info string to transcript
    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH-C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);
    write_line_to_log_destination(v_line);
    deallocate(v_line);
  end procedure;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_coverpoint is protected body
    variable priv_id                            : integer := -1;
    variable priv_name                          : string(1 to C_FC_MAX_NAME_LENGTH);
    variable priv_scope                         : string(1 to C_LOG_SCOPE_WIDTH) := C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH-C_TB_SCOPE_DEFAULT'length);
    variable priv_bins                          : t_cov_bin_vector(0 to C_MAX_NUM_BINS-1);
    variable priv_bins_idx                      : natural := 0;
    variable priv_invalid_bins                  : t_cov_bin_vector(0 to C_MAX_NUM_BINS-1);
    variable priv_invalid_bins_idx              : natural := 0;
    variable priv_num_bins_crossed              : integer := -1;
    variable priv_rand_gen                      : t_rand;
    variable priv_rand_transition_bin_idx       : integer := -1;
    variable priv_rand_transition_bin_value_idx : natural := 0;
    variable priv_detect_bin_overlap            : boolean := false;

    type t_bin_type_verbosity is (LONG, SHORT, NONE);

    ------------------------------------------------------------
    -- Internal functions and procedures
    ------------------------------------------------------------
    -- Returns a string with all the procedure calls in the array
    impure function get_proc_calls(
      constant bin_array : t_new_bin_array)
    return string is
      variable v_line   : line;
      variable v_result : string(1 to 1000);
      variable v_width  : natural;
    begin
      for i in bin_array'range loop
        write(v_line, bin_array(i).proc_call);
        if i < bin_array'length-1 then
          write(v_line, ',');
        end if;
      end loop;

      v_width := v_line'length;
      v_result(1 to v_width) := v_line.all;
      DEALLOCATE(v_line);
      return v_result(1 to v_width);
    end function;

    -- Returns a string with all the bins values in the array
    impure function get_bin_array_values(
      constant bin_array     : t_new_bin_array;
      constant bin_verbosity : t_bin_type_verbosity := SHORT;
      constant bin_delimiter : character := ',')
    return string is
      variable v_line   : line;
      variable v_result : string(1 to 1000);
      variable v_width  : natural;

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

    begin
      for i in bin_array'range loop
        for j in 0 to bin_array(i).num_bins-1 loop
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
                write(v_line, '(');
                write(v_line, to_string(bin_array(i).bin_vector(j).values(0)));
                write(v_line, ')');
              else
                write(v_line, to_string(bin_array(i).bin_vector(j).values(0 to bin_array(i).bin_vector(j).num_values-1)));
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
              for k in 0 to bin_array(i).bin_vector(j).num_values-1 loop
                write(v_line, to_string(bin_array(i).bin_vector(j).values(k)));
                if k < bin_array(i).bin_vector(j).num_values-1 then
                  write(v_line, string'("->"));
                end if;
              end loop;
              write(v_line, ')');
          end case;
          if i < bin_array'length-1 or j < bin_array(i).num_bins-1 then
            write(v_line, bin_delimiter);
          end if;
        end loop;
      end loop;

      v_width := v_line'length;
      v_result(1 to v_width) := v_line.all;
      DEALLOCATE(v_line);
      return v_result(1 to v_width);
    end function;

    -- Returns a string with all the bins values in the vector
    -- Used in the report, so the bins in the vector are crossed
    impure function get_bin_vector_values(
      constant bins : t_bin_vector)
    return string is
      variable v_new_bin_array : t_new_bin_array(0 to 0);
    begin
      for i in 0 to bins'length-1 loop
        v_new_bin_array(0).bin_vector(i).contains   := bins(i).contains;
        v_new_bin_array(0).bin_vector(i).values     := bins(i).values;
        v_new_bin_array(0).bin_vector(i).num_values := bins(i).num_values;
      end loop;
      v_new_bin_array(0).num_bins := bins'length;
      return get_bin_array_values(v_new_bin_array, NONE, 'x');
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
      v_new_bin_array(0).num_bins := 1;
      return get_bin_array_values(v_new_bin_array, LONG);
    end function;

    -- Returns true if the bin is ignored
    impure function is_bin_ignore(
      constant bin : t_cov_bin)
    return boolean is
      variable v_is_ignore : boolean := false;
    begin
      for i in 0 to priv_num_bins_crossed-1 loop
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
      for i in 0 to priv_num_bins_crossed-1 loop
        v_is_illegal := v_is_illegal or (bin.cross_bins(i).contains = VAL_ILLEGAL or
                                         bin.cross_bins(i).contains = RAN_ILLEGAL or
                                         bin.cross_bins(i).contains = TRN_ILLEGAL);
      end loop;
      return v_is_illegal;
    end function;

    -- Returns the percentage of hits/min_hits in a bin. Note that it saturates at 100%
    impure function get_bin_coverage(
      constant bin : t_cov_bin)
    return real is
      variable v_coverage : real;
    begin
      if bin.hits < bin.min_hits then
        v_coverage := real(bin.hits)*100.0/real(bin.min_hits);
      else
        v_coverage := 100.0;
      end if;
      return v_coverage;
    end function;

    -- Initializes a new coverpoint by registering it in the covergroup, setting its name, scope and randomization seeds.
    procedure initialize_coverpoint(
      constant local_call : in string) is
    begin
      if priv_id = -1 then
        priv_id := protected_covergroup_status.add_coverpoint(VOID);
        check_value(priv_id /= -1, TB_FAILURE, "Number of coverpoints exceed C_FC_MAX_NUM_COVERPOINTS.\n Increase C_FC_MAX_NUM_COVERPOINTS in adaptations package.",
          priv_scope, ID_NEVER, caller_name => local_call);
        -- Only set the default name and scope if none have been given
        if priv_name = fill_string(NUL, priv_name'length) then
          set_name(protected_covergroup_status.get_name(priv_id));
        else
          -- In case the name was set before the coverpoint was registered, we need to update the name in the covergroup
          protected_covergroup_status.set_name(priv_id, priv_name);
        end if;
        if priv_scope = C_TB_SCOPE_DEFAULT & fill_string(NUL, C_LOG_SCOPE_WIDTH-C_TB_SCOPE_DEFAULT'length) then
          set_scope(priv_name);
        end if;
        priv_rand_gen.set_rand_seeds(priv_name);
      end if;
    end procedure;

    -- Checks that the number of crossed bins does not change.
    -- If the extra parameters are given, it checks that the coverpoints are not empty.
    procedure check_num_bins_crossed(
      constant num_bins_crossed             : in integer;
      constant local_call                   : in string;
      constant coverpoint1_num_bins_crossed : in integer := 0;
      constant coverpoint2_num_bins_crossed : in integer := 0;
      constant coverpoint3_num_bins_crossed : in integer := 0) is
    begin
      initialize_coverpoint(local_call);

      check_value(coverpoint1_num_bins_crossed /= -1, TB_FAILURE, "Coverpoint 1 is empty", priv_scope, ID_NEVER, caller_name => local_call);
      check_value(coverpoint2_num_bins_crossed /= -1, TB_FAILURE, "Coverpoint 2 is empty", priv_scope, ID_NEVER, caller_name => local_call);
      check_value(coverpoint3_num_bins_crossed /= -1, TB_FAILURE, "Coverpoint 3 is empty", priv_scope, ID_NEVER, caller_name => local_call);

      check_value(priv_bins_idx < C_MAX_NUM_BINS-1, TB_FAILURE, "Cannot add more bins. Number of bins in the coverpoint has reached C_MAX_NUM_BINS",
        priv_scope, ID_NEVER, caller_name => local_call);
      check_value(priv_invalid_bins_idx < C_MAX_NUM_BINS-1, TB_FAILURE, "Cannot add more bins. Number of bins in the coverpoint has reached C_MAX_NUM_BINS",
        priv_scope, ID_NEVER, caller_name => local_call);

      -- The number of bins crossed is set on the first call and can't be changed
      if priv_num_bins_crossed = -1 and num_bins_crossed > 0 then
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
      constant C_CONTAINS   : t_cov_bin_type := cov_bin_vector(cov_bin_idx).cross_bins(cross_bin_idx).contains;
      constant C_NUM_VALUES : natural        := cov_bin_vector(cov_bin_idx).cross_bins(cross_bin_idx).num_values;
      constant C_VALUES     : integer_vector(0 to C_NUM_VALUES-1) := cov_bin_vector(cov_bin_idx).cross_bins(cross_bin_idx).values(0 to C_NUM_VALUES-1);
    begin
      for i in 0 to cov_bin_idx-1 loop
        if cov_bin_vector(i).cross_bins(cross_bin_idx).contains = C_CONTAINS and
           cov_bin_vector(i).cross_bins(cross_bin_idx).num_values = C_NUM_VALUES and
           cov_bin_vector(i).cross_bins(cross_bin_idx).values(0 to C_NUM_VALUES-1) = C_VALUES
        then
          return true;
        end if;
      end loop;
      return false;
    end function;

    -- Copies all the bins in a bin array to a bin vector
    procedure copy_bins_in_bin_array(
      constant bin_array : in  t_new_bin_array;
      variable cov_bin   : out t_new_cov_bin) is
      variable v_num_bins : natural := 0;
    begin
      for i in bin_array'range loop
        cov_bin.bin_vector(v_num_bins to v_num_bins+bin_array(i).num_bins-1) := bin_array(i).bin_vector(0 to bin_array(i).num_bins-1);
        v_num_bins := v_num_bins + bin_array(i).num_bins;
      end loop;
      cov_bin.num_bins := v_num_bins;
    end procedure;

    -- Copies all the bins in a coverpoint to a bin array (including crossed bins)
    -- Duplicate bins are not copied since they are assumed to be the result of a cross
    procedure copy_bins_in_coverpoint(
      variable coverpoint : inout t_coverpoint;
      variable bin_array  : out   t_new_bin_array) is
      variable v_coverpoint_bins         : t_cov_bin_vector(0 to coverpoint.get_num_bins(VOID)-1);
      variable v_coverpoint_invalid_bins : t_cov_bin_vector(0 to coverpoint.get_num_invalid_bins(VOID)-1);
      variable v_num_bins                : natural := 0;
    begin
      v_coverpoint_bins         := coverpoint.get_bins(VOID);
      v_coverpoint_invalid_bins := coverpoint.get_invalid_bins(VOID);

      for cross in 0 to bin_array'length-1 loop
        for i in v_coverpoint_bins'range loop
          if not find_duplicate_bin(v_coverpoint_bins, i, cross) then
            bin_array(cross).bin_vector(v_num_bins).contains   := v_coverpoint_bins(i).cross_bins(cross).contains;
            bin_array(cross).bin_vector(v_num_bins).values     := v_coverpoint_bins(i).cross_bins(cross).values;
            bin_array(cross).bin_vector(v_num_bins).num_values := v_coverpoint_bins(i).cross_bins(cross).num_values;
            v_num_bins := v_num_bins + 1;
          end if;
        end loop;
        for i in v_coverpoint_invalid_bins'range loop
          if not find_duplicate_bin(v_coverpoint_invalid_bins, i, cross) then
            bin_array(cross).bin_vector(v_num_bins).contains   := v_coverpoint_invalid_bins(i).cross_bins(cross).contains;
            bin_array(cross).bin_vector(v_num_bins).values     := v_coverpoint_invalid_bins(i).cross_bins(cross).values;
            bin_array(cross).bin_vector(v_num_bins).num_values := v_coverpoint_invalid_bins(i).cross_bins(cross).num_values;
            v_num_bins := v_num_bins + 1;
          end if;
        end loop;
        bin_array(cross).num_bins := v_num_bins;
        v_num_bins := 0;
      end loop;
    end procedure;

    -- Creates a bin array from several bin arrays
    procedure create_bin_array(
      variable bin_array : out t_new_bin_array;
      constant bin1      : in  t_new_bin_array;
      constant bin2      : in  t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY;
      constant bin3      : in  t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY;
      constant bin4      : in  t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY;
      constant bin5      : in  t_new_bin_array := C_EMPTY_NEW_BIN_ARRAY) is
    begin
      copy_bins_in_bin_array(bin1, bin_array(0));

      if bin2 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin2, bin_array(1));
      end if;

      if bin3 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin3, bin_array(2));
      end if;

      if bin4 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin4, bin_array(3));
      end if;

      if bin5 /= C_EMPTY_NEW_BIN_ARRAY then
        copy_bins_in_bin_array(bin5, bin_array(4));
      end if;
    end procedure;

    -- Creates a bin array from several coverpoints
    procedure create_bin_array(
      variable bin_array   : out   t_new_bin_array;
      variable coverpoint1 : inout t_coverpoint;
      variable coverpoint2 : inout t_coverpoint) is
      variable v_bin_array1 : t_new_bin_array(0 to coverpoint1.get_num_bins_crossed(VOID)-1);
      variable v_bin_array2 : t_new_bin_array(0 to coverpoint2.get_num_bins_crossed(VOID)-1);
    begin
      copy_bins_in_coverpoint(coverpoint1, v_bin_array1);
      copy_bins_in_coverpoint(coverpoint2, v_bin_array2);
      bin_array := v_bin_array1 & v_bin_array2;
    end procedure;

    -- TODO: create more overloads (16)
    -- Overload
    procedure create_bin_array(
      variable bin_array   : out   t_new_bin_array;
      variable coverpoint1 : inout t_coverpoint;
      variable coverpoint2 : inout t_coverpoint;
      variable coverpoint3 : inout t_coverpoint) is
      variable v_bin_array1 : t_new_bin_array(0 to coverpoint1.get_num_bins_crossed(VOID)-1);
      variable v_bin_array2 : t_new_bin_array(0 to coverpoint2.get_num_bins_crossed(VOID)-1);
      variable v_bin_array3 : t_new_bin_array(0 to coverpoint3.get_num_bins_crossed(VOID)-1);
    begin
      copy_bins_in_coverpoint(coverpoint1, v_bin_array1);
      copy_bins_in_coverpoint(coverpoint2, v_bin_array2);
      copy_bins_in_coverpoint(coverpoint3, v_bin_array3);
      bin_array := v_bin_array1 & v_bin_array2 & v_bin_array3;
    end procedure;

    -- Adds bins in a recursive way
    procedure add_bins_recursive(
      constant bin_array     : in    t_new_bin_array;
      constant bin_array_idx : in    integer;
      variable idx_reg       : inout integer_vector;
      constant min_hits      : in    positive;
      constant rand_weight   : in    natural;
      constant bin_name      : in    string) is
      constant C_NUM_CROSS_BINS : natural := bin_array'length;
      variable v_bin_is_valid   : boolean := true;
      variable v_bin_is_illegal : boolean := false;
    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER);
      -- Iterate through the bins in the current array element
      for i in 0 to bin_array(bin_array_idx).num_bins-1 loop
        -- Store the bin index for the current element of the array
        idx_reg(bin_array_idx) := i;
        -- Last element of the array has been reached, add bins
        if bin_array_idx = C_NUM_CROSS_BINS-1 then
          -- Check that all the bins being added are valid
          for j in 0 to C_NUM_CROSS_BINS-1 loop
            v_bin_is_valid := v_bin_is_valid and (bin_array(j).bin_vector(idx_reg(j)).contains = VAL or
                                                  bin_array(j).bin_vector(idx_reg(j)).contains = RAN or
                                                  bin_array(j).bin_vector(idx_reg(j)).contains = TRN);
            v_bin_is_illegal := v_bin_is_illegal or (bin_array(j).bin_vector(idx_reg(j)).contains = VAL_ILLEGAL or
                                                     bin_array(j).bin_vector(idx_reg(j)).contains = RAN_ILLEGAL or
                                                     bin_array(j).bin_vector(idx_reg(j)).contains = TRN_ILLEGAL);
          end loop;
          -- Store valid bins
          if v_bin_is_valid then
            for j in 0 to C_NUM_CROSS_BINS-1 loop
              priv_bins(priv_bins_idx).cross_bins(j).contains       := bin_array(j).bin_vector(idx_reg(j)).contains;
              priv_bins(priv_bins_idx).cross_bins(j).values         := bin_array(j).bin_vector(idx_reg(j)).values;
              priv_bins(priv_bins_idx).cross_bins(j).num_values     := bin_array(j).bin_vector(idx_reg(j)).num_values;
              priv_bins(priv_bins_idx).cross_bins(j).transition_idx := 0;
            end loop;
            priv_bins(priv_bins_idx).hits                         := 0;
            priv_bins(priv_bins_idx).min_hits                     := min_hits;
            priv_bins(priv_bins_idx).rand_weight                  := rand_weight;
            priv_bins(priv_bins_idx).name(1 to bin_name'length)   := bin_name;
            priv_bins_idx := priv_bins_idx + 1;
            -- Update covergroup status register
            protected_covergroup_status.increment_valid_bin_count(priv_id);
            protected_covergroup_status.increment_min_hits_count(priv_id, min_hits);
          -- Store ignore or illegal bins
          else
            for j in 0 to C_NUM_CROSS_BINS-1 loop
              priv_invalid_bins(priv_invalid_bins_idx).cross_bins(j).contains       := bin_array(j).bin_vector(idx_reg(j)).contains;
              priv_invalid_bins(priv_invalid_bins_idx).cross_bins(j).values         := bin_array(j).bin_vector(idx_reg(j)).values;
              priv_invalid_bins(priv_invalid_bins_idx).cross_bins(j).num_values     := bin_array(j).bin_vector(idx_reg(j)).num_values;
              priv_invalid_bins(priv_invalid_bins_idx).cross_bins(j).transition_idx := 0;
            end loop;
            priv_invalid_bins(priv_invalid_bins_idx).hits                         := 0;
            priv_invalid_bins(priv_invalid_bins_idx).min_hits                     := 0;
            priv_invalid_bins(priv_invalid_bins_idx).rand_weight                  := 0;
            priv_invalid_bins(priv_invalid_bins_idx).name(1 to bin_name'length)   := bin_name;
            priv_invalid_bins_idx := priv_invalid_bins_idx + 1;
            -- Update covergroup status register
            if v_bin_is_illegal then
              protected_covergroup_status.increment_illegal_bin_count(priv_id);
            end if;
          end if;
        -- Go to the next element of the array
        else
          add_bins_recursive(bin_array, bin_array_idx+1, idx_reg, min_hits, rand_weight, bin_name);
        end if;
      end loop;
    end procedure;

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_name(
      constant name : in string) is
    begin
      if name'length > C_FC_MAX_NAME_LENGTH then
        priv_name := name(1 to C_FC_MAX_NAME_LENGTH);
      else
        priv_name := name & fill_string(NUL, C_FC_MAX_NAME_LENGTH-name'length);
      end if;
      -- Update covergroup status register
      if priv_id /= -1 then
        protected_covergroup_status.set_name(priv_id, name);
      end if;
    end procedure;

    impure function get_name(
      constant VOID : t_void)
    return string is
    begin
      return to_string(priv_name);
    end function;

    procedure set_scope(
      constant scope : in string) is
    begin
      if scope'length > C_LOG_SCOPE_WIDTH then
        priv_scope := scope(1 to C_LOG_SCOPE_WIDTH);
      else
        priv_scope := scope & fill_string(NUL, C_LOG_SCOPE_WIDTH-scope'length);
      end if;
    end procedure;

    impure function get_scope(
      constant VOID : t_void)
    return string is
    begin
      return to_string(priv_scope);
    end function;

    procedure detect_bin_overlap(
      constant enable       : in boolean;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "detect_bin_overlap(" & to_string(enable) & ")";
    begin
      log(ID_FUNCT_COV_CONFIG, C_LOCAL_CALL, priv_scope, msg_id_panel);
      priv_detect_bin_overlap := enable;
    end procedure;

    procedure write_coverage_db(
      constant file_name    : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "write_coverage_db(" & file_name & ")";
      file fileHandler      : text open write_mode is file_name;
      variable v_line       : line;
      variable v_rand_seeds : t_positive_vector(0 to 1);

      procedure write_value(
        constant value : in integer) is
      begin
        write(v_line, value);
        writeline(fileHandler, v_line);
      end procedure;

      procedure write_value(
        constant value : in string) is
      begin
        write(v_line, value);
        writeline(fileHandler, v_line);
      end procedure;

      procedure write_value(
        constant value : in boolean) is
      begin
        write(v_line, value);
        writeline(fileHandler, v_line);
      end procedure;

      procedure write_bins(
        constant bin_idx    : in natural;
        constant bin_vector : in t_cov_bin_vector) is
      begin
        write(v_line, bin_idx);
        writeline(fileHandler, v_line);
        for i in 0 to bin_idx-1 loop
          write(v_line, bin_vector(i).hits);
          writeline(fileHandler, v_line);
          write(v_line, bin_vector(i).min_hits);
          writeline(fileHandler, v_line);
          write(v_line, bin_vector(i).rand_weight);
          writeline(fileHandler, v_line);
          write(v_line, bin_vector(i).name);
          writeline(fileHandler, v_line);
          for j in 0 to priv_num_bins_crossed-1 loop
            write(v_line, t_cov_bin_type'pos(bin_vector(i).cross_bins(j).contains));
            writeline(fileHandler, v_line);
            write(v_line, bin_vector(i).cross_bins(j).num_values);
            writeline(fileHandler, v_line);
            write(v_line, bin_vector(i).cross_bins(j).transition_idx);
            writeline(fileHandler, v_line);
            for k in 0 to bin_vector(i).cross_bins(j).num_values-1 loop
              write(v_line, bin_vector(i).cross_bins(j).values(k));
              writeline(fileHandler, v_line);
            end loop;
          end loop;
        end loop;
      end procedure;

    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      log(ID_FUNCT_COV_CONFIG, C_LOCAL_CALL, priv_scope, msg_id_panel);

      -- Coverpoint config
      write_value(priv_name);
      write_value(priv_scope);
      write_value(priv_num_bins_crossed);
      v_rand_seeds := priv_rand_gen.get_rand_seeds(VOID);
      write_value(v_rand_seeds(0));
      write_value(v_rand_seeds(1));
      write_value(priv_rand_transition_bin_idx);
      write_value(priv_rand_transition_bin_value_idx);
      write_value(priv_detect_bin_overlap);
      -- Covergroup config
      write_value(protected_covergroup_status.get_num_valid_bins(priv_id));
      write_value(protected_covergroup_status.get_num_illegal_bins(priv_id));
      write_value(protected_covergroup_status.get_num_uncovered_bins(priv_id));
      write_value(protected_covergroup_status.get_total_bin_hits(priv_id));
      write_value(protected_covergroup_status.get_total_bin_min_hits(priv_id));
      write_value(protected_covergroup_status.get_coverage_weight(priv_id));
      write_value(protected_covergroup_status.get_coverage_goal(priv_id));
      write_value(protected_covergroup_status.get_covergroup_coverage_goal(VOID));
      -- Bin structure
      write_bins(priv_bins_idx, priv_bins);
      write_bins(priv_invalid_bins_idx, priv_invalid_bins);

      file_close(fileHandler);
      DEALLOCATE(v_line);
    end procedure;

    procedure load_coverage_db(
      constant file_name    : in string;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "load_coverage_db(" & file_name & ")";
      file fileHandler      : text open read_mode is file_name;
      variable v_line       : line;
      variable v_rand_seeds : t_positive_vector(0 to 1);
      variable v_value      : integer;

      procedure read_value(
        variable value : out integer) is
      begin
        readline(fileHandler, v_line);
        read(v_line, value);
      end procedure;

      procedure read_value(
        variable value : out string) is
      begin
        readline(fileHandler, v_line);
        read(v_line, value);
      end procedure;

      procedure read_value(
        variable value : out boolean) is
      begin
        readline(fileHandler, v_line);
        read(v_line, value);
      end procedure;

      procedure read_bins(
        constant bin_idx    : in  natural;
        variable bin_vector : out t_cov_bin_vector) is
        variable v_contains   : integer;
        variable v_num_values : integer;
      begin
        for i in 0 to bin_idx-1 loop
          readline(fileHandler, v_line);
          read(v_line, bin_vector(i).hits);
          readline(fileHandler, v_line);
          read(v_line, bin_vector(i).min_hits);
          readline(fileHandler, v_line);
          read(v_line, bin_vector(i).rand_weight);
          readline(fileHandler, v_line);
          read(v_line, bin_vector(i).name);  -- read() crops the string
          for j in 0 to priv_num_bins_crossed-1 loop
            readline(fileHandler, v_line);
            read(v_line, v_contains);
            bin_vector(i).cross_bins(j).contains := t_cov_bin_type'val(v_contains);
            readline(fileHandler, v_line);
            read(v_line, v_num_values);
            bin_vector(i).cross_bins(j).num_values := v_num_values;
            check_value(v_num_values <= C_MAX_NUM_BIN_VALUES, TB_FAILURE, "Cannot load the " & to_string(v_num_values) & " bin values. Increase C_MAX_NUM_BIN_VALUES",
              priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
            readline(fileHandler, v_line);
            read(v_line, bin_vector(i).cross_bins(j).transition_idx);
            for k in 0 to v_num_values-1 loop
              readline(fileHandler, v_line);
              read(v_line, bin_vector(i).cross_bins(j).values(k));
            end loop;
          end loop;
        end loop;
      end procedure;

    begin
      log(ID_FUNCT_COV_CONFIG, C_LOCAL_CALL, priv_scope, msg_id_panel);

      -- Add coverpoint to covergroup status
      if priv_id = -1 then
        priv_id := protected_covergroup_status.add_coverpoint(VOID);
        check_value(priv_id /= -1, TB_FAILURE, "Number of coverpoints exceed C_FC_MAX_NUM_COVERPOINTS.\n Increase C_FC_MAX_NUM_COVERPOINTS in adaptations package.",
          priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      else
        alert(TB_WARNING, C_LOCAL_CALL & "=> Coverpoint model will be overwritten.", priv_scope);
      end if;
      -- Coverpoint config
      read_value(priv_name);  -- read() crops the string
      set_name(priv_name);
      read_value(priv_scope); -- read() crops the string
      set_scope(priv_scope);
      read_value(priv_num_bins_crossed);
      check_value(priv_num_bins_crossed <= C_MAX_NUM_CROSS_BINS, TB_FAILURE, "Cannot load the " & to_string(priv_num_bins_crossed) & " crossed bins. Increase C_MAX_NUM_CROSS_BINS",
        priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      read_value(v_rand_seeds(0));
      read_value(v_rand_seeds(1));
      priv_rand_gen.set_rand_seeds(v_rand_seeds);
      read_value(priv_rand_transition_bin_idx);
      read_value(priv_rand_transition_bin_value_idx);
      read_value(priv_detect_bin_overlap);
      -- Covergroup config
      read_value(v_value);
      protected_covergroup_status.set_num_valid_bins(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_num_illegal_bins(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_num_uncovered_bins(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_total_bin_hits(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_total_bin_min_hits(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_coverage_weight(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_coverage_goal(priv_id, v_value);
      read_value(v_value);
      protected_covergroup_status.set_covergroup_coverage_goal(v_value);
      -- Bin structure
      read_value(priv_bins_idx);
      check_value(priv_bins_idx <= C_MAX_NUM_BINS, TB_FAILURE, "Cannot load the " & to_string(priv_bins_idx) & " bins. Increase C_MAX_NUM_BINS",
        priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      read_bins(priv_bins_idx, priv_bins);
      read_value(priv_invalid_bins_idx);
      check_value(priv_invalid_bins_idx <= C_MAX_NUM_BINS, TB_FAILURE, "Cannot load the " & to_string(priv_invalid_bins_idx) & " bins. Increase C_MAX_NUM_BINS",
        priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      read_bins(priv_invalid_bins_idx, priv_invalid_bins);

      file_close(fileHandler);
      DEALLOCATE(v_line);
    end procedure;

    -- Returns the number of bins crossed in the coverpoint
    impure function get_num_bins_crossed(
      constant VOID : t_void)
    return integer is
    begin
      return priv_num_bins_crossed;
    end function;

    -- Returns the number of bins in the coverpoint
    impure function get_num_bins(
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

    -- Returns a vector with the bins in the coverpoint
    impure function get_bins(
      constant VOID : t_void)
    return t_cov_bin_vector is
    begin
      return priv_bins(0 to priv_bins_idx-1);
    end function;

    -- Returns a vector with the illegal and ignore bins in the coverpoint
    impure function get_invalid_bins(
      constant VOID : t_void)
    return t_cov_bin_vector is
    begin
      return priv_invalid_bins(0 to priv_invalid_bins_idx-1);
    end function;

    -- Returns a string with all the bins in the coverpoint including illegal, ignore and cross
    -- Duplicate bins are not printed since they are assumed to be the result of a cross
    impure function get_all_bins_string(
      constant VOID : t_void)
    return string is
      variable v_new_bin_array : t_new_bin_array(0 to priv_num_bins_crossed-1);
      variable v_line          : line;
      variable v_result        : string(1 to 1000);
      variable v_width         : natural;
      variable v_num_bins      : natural := 0;
    begin
      if priv_bins_idx = 0 and priv_invalid_bins_idx = 0 then
        return "";
      end if;

      for cross in v_new_bin_array'range loop
        for i in 0 to priv_bins_idx-1 loop
          if not find_duplicate_bin(priv_bins, i, cross) then
            v_new_bin_array(cross).bin_vector(v_num_bins).contains   := priv_bins(i).cross_bins(cross).contains;
            v_new_bin_array(cross).bin_vector(v_num_bins).values     := priv_bins(i).cross_bins(cross).values;
            v_new_bin_array(cross).bin_vector(v_num_bins).num_values := priv_bins(i).cross_bins(cross).num_values;
            v_num_bins := v_num_bins + 1;
          end if;
        end loop;
        for i in 0 to priv_invalid_bins_idx-1 loop
          if not find_duplicate_bin(priv_bins, i, cross) then
            v_new_bin_array(cross).bin_vector(v_num_bins).contains   := priv_bins(i).cross_bins(cross).contains;
            v_new_bin_array(cross).bin_vector(v_num_bins).values     := priv_bins(i).cross_bins(cross).values;
            v_new_bin_array(cross).bin_vector(v_num_bins).num_values := priv_bins(i).cross_bins(cross).num_values;
            v_num_bins := v_num_bins + 1;
          end if;
        end loop;
        v_new_bin_array(cross).num_bins := v_num_bins;
        v_num_bins := 0;
        write(v_line, get_bin_array_values(v_new_bin_array(cross to cross)));
        if cross < v_new_bin_array'length-1 then
          write(v_line, string'(" x "));
        end if;
      end loop;

      v_width := v_line'length;
      v_result(1 to v_width) := v_line.all;
      DEALLOCATE(v_line);
      return v_result(1 to v_width);
    end function;

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
      constant C_LOCAL_CALL : string := "add_bins(" & get_proc_calls(bin) & ", min_hits:" & to_string(min_hits) &
        ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS : natural := 1;
      variable v_proc_call      : line;
      variable v_bin_array      : t_new_bin_array(0 to C_NUM_CROSS_BINS-1);
      variable v_idx_reg        : integer_vector(0 to C_NUM_CROSS_BINS-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNCT_COV, v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNCT_COV_BINS, "Adding bins: " &  get_bin_array_values(bin) & ", min_hits:" & to_string(min_hits) &
        ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, bin);
      add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, bin_name);
      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_bins(
      constant bin           : in t_new_bin_array;
      constant min_hits      : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_bins(" & get_proc_calls(bin) & ", min_hits:" & to_string(min_hits) &
        ", """ & bin_name & """)";
    begin
      add_bins(bin, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_bins(
      constant bin           : in t_new_bin_array;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
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
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS : natural := 2;
      variable v_proc_call      : line;
      variable v_bin_array      : t_new_bin_array(0 to C_NUM_CROSS_BINS-1);
      variable v_idx_reg        : integer_vector(0 to C_NUM_CROSS_BINS-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNCT_COV, v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNCT_COV_BINS, "Adding cross: " &  get_bin_array_values(bin1) & " x "  &  get_bin_array_values(bin2) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, bin1, bin2);
      add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, bin_name);
      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) &
        ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) &
        ", """ & bin_name & """)";
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
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS : natural := 3;
      variable v_proc_call      : line;
      variable v_bin_array      : t_new_bin_array(0 to C_NUM_CROSS_BINS-1);
      variable v_idx_reg        : integer_vector(0 to C_NUM_CROSS_BINS-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all);
      log(ID_FUNCT_COV, v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNCT_COV_BINS, "Adding cross: " &  get_bin_array_values(bin1) & " x "  &  get_bin_array_values(bin2) & " x "  &  get_bin_array_values(bin3) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, bin1, bin2, bin3);
      add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, bin_name);
      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant min_hits      : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      constant bin1          : in t_new_bin_array;
      constant bin2          : in t_new_bin_array;
      constant bin3          : in t_new_bin_array;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & get_proc_calls(bin1) & ", " & get_proc_calls(bin2) & ", " & get_proc_calls(bin3) &
        ", """ & bin_name & """)";
    begin
      add_cross(bin1, bin2, bin3, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Add cross (2 coverpoints)
    ------------------------------------------------------------
    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant min_hits      : in    positive;
      constant rand_weight   : in    natural;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in    string         := "") is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS : integer := coverpoint1.get_num_bins_crossed(VOID) + coverpoint2.get_num_bins_crossed(VOID);
      variable v_proc_call      : line;
      variable v_bin_array      : t_new_bin_array(0 to C_NUM_CROSS_BINS-1);
      variable v_idx_reg        : integer_vector(0 to C_NUM_CROSS_BINS-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all, coverpoint1.get_num_bins_crossed(VOID), coverpoint2.get_num_bins_crossed(VOID));
      log(ID_FUNCT_COV, v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNCT_COV_BINS, "Adding cross: " &  coverpoint1.get_all_bins_string(VOID) & " x "  &  coverpoint2.get_all_bins_string(VOID) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, coverpoint1, coverpoint2);
      add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, bin_name);
      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant min_hits      : in    positive;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) &
        ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) &
        ", """ & bin_name & """)";
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
      constant min_hits      : in    positive;
      constant rand_weight   : in    natural;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in    string         := "") is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " &
        coverpoint3.get_name(VOID) & ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
      constant C_NUM_CROSS_BINS : integer := coverpoint1.get_num_bins_crossed(VOID) + coverpoint2.get_num_bins_crossed(VOID) +
        coverpoint3.get_num_bins_crossed(VOID);
      variable v_proc_call      : line;
      variable v_bin_array      : t_new_bin_array(0 to C_NUM_CROSS_BINS-1);
      variable v_idx_reg        : integer_vector(0 to C_NUM_CROSS_BINS-1);
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_num_bins_crossed(C_NUM_CROSS_BINS, v_proc_call.all, coverpoint1.get_num_bins_crossed(VOID), coverpoint2.get_num_bins_crossed(VOID),
        coverpoint3.get_num_bins_crossed(VOID));
      log(ID_FUNCT_COV, v_proc_call.all, priv_scope, msg_id_panel);
      log(ID_FUNCT_COV_BINS, "Adding cross: " &  coverpoint1.get_all_bins_string(VOID) & " x "  &  coverpoint2.get_all_bins_string(VOID) &
        " x "  &  coverpoint3.get_all_bins_string(VOID) &
        ", min_hits:" & to_string(min_hits) & ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """", priv_scope, msg_id_panel);

      -- Copy the bins into an array and use a recursive procedure to add them to the list
      create_bin_array(v_bin_array, coverpoint1, coverpoint2, coverpoint3);
      add_bins_recursive(v_bin_array, 0, v_idx_reg, min_hits, rand_weight, bin_name);
      DEALLOCATE(v_proc_call);
    end procedure;

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      constant min_hits      : in    positive;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " &
        coverpoint3.get_name(VOID) & ", min_hits:" & to_string(min_hits) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, min_hits, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure add_cross(
      variable coverpoint1   : inout t_coverpoint;
      variable coverpoint2   : inout t_coverpoint;
      variable coverpoint3   : inout t_coverpoint;
      constant bin_name      : in    string         := "";
      constant msg_id_panel  : in    t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross(" & coverpoint1.get_name(VOID) & ", " & coverpoint2.get_name(VOID) & ", " &
        coverpoint3.get_name(VOID) & ", """ & bin_name & """)";
    begin
      add_cross(coverpoint1, coverpoint2, coverpoint3, 1, 1, bin_name, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    ------------------------------------------------------------
    -- Randomization
    ------------------------------------------------------------
    impure function rand(
      constant VOID : t_void)
    return integer is
      variable v_ret : integer;
    begin
      v_ret := rand(shared_msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant msg_id_panel  : t_msg_id_panel)
    return integer is
      constant C_LOCAL_CALL  : string := "rand()";
      variable v_ret         : integer_vector(0 to 0);
    begin
      v_ret := rand(msg_id_panel, C_LOCAL_CALL);
      log(ID_FUNCT_COV_RAND, C_LOCAL_CALL & "=> " & to_string(v_ret(0)), priv_scope, msg_id_panel);
      return v_ret(0);
    end function;

    impure function rand(
      constant VOID : t_void)
    return integer_vector is
      variable v_ret : integer_vector(0 to priv_num_bins_crossed-1);
    begin
      v_ret := rand(shared_msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant msg_id_panel  : t_msg_id_panel;
      constant ext_proc_call : string := "")
    return integer_vector is
      constant C_LOCAL_CALL      : string := "rand()";
      variable v_bin_weight_list : t_val_weight_int_vec(0 to priv_bins_idx-1);
      variable v_acc_weight      : integer := 0;
      variable v_values_vec      : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
      variable v_bin_idx         : integer;
      variable v_ret             : integer_vector(0 to priv_num_bins_crossed-1);
    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);

      -- A transition bin returns all the transition values before allowing to select a different bin value
      if priv_rand_transition_bin_idx /= -1 then
        v_bin_idx := priv_rand_transition_bin_idx;
      else
        -- Assign each bin a randomization weight
        for i in 0 to priv_bins_idx-1 loop
          v_bin_weight_list(i).value := i;
          if priv_bins(i).hits < priv_bins(i).min_hits then
            v_bin_weight_list(i).weight := priv_bins(i).rand_weight;
          else
            v_bin_weight_list(i).weight := 0;
          end if;
          v_acc_weight := v_acc_weight + v_bin_weight_list(i).weight;
        end loop;
        -- When all bins have reached their min_hits re-enable valid bins for selection
        if v_acc_weight = 0 then
          for i in 0 to priv_bins_idx-1 loop
            v_bin_weight_list(i).weight := priv_bins(i).rand_weight;
          end loop;
        end if;

        -- Choose a random bin index
        v_bin_idx := priv_rand_gen.rand_val_weight(v_bin_weight_list, msg_id_panel);
      end if;

      -- Select the random bin values to return (ignore and illegal bin values are never selected)
      for i in 0 to priv_num_bins_crossed-1 loop
        v_values_vec := (others => 0);
        if priv_bins(v_bin_idx).cross_bins(i).contains = VAL then
          if priv_bins(v_bin_idx).cross_bins(i).num_values = 1 then
            v_ret(i) := priv_bins(v_bin_idx).cross_bins(i).values(0);
          else
            for j in 0 to priv_bins(v_bin_idx).cross_bins(i).num_values-1 loop
              v_values_vec(j) := priv_bins(v_bin_idx).cross_bins(i).values(j);
            end loop;
            v_ret(i) := priv_rand_gen.rand(ONLY, v_values_vec(0 to priv_bins(v_bin_idx).cross_bins(i).num_values-1), NON_CYCLIC, msg_id_panel);
          end if;
        elsif priv_bins(v_bin_idx).cross_bins(i).contains = RAN then
          v_ret(i) := priv_rand_gen.rand(priv_bins(v_bin_idx).cross_bins(i).values(0), priv_bins(v_bin_idx).cross_bins(i).values(1), NON_CYCLIC, msg_id_panel);
        elsif priv_bins(v_bin_idx).cross_bins(i).contains = TRN then
          if priv_rand_transition_bin_idx = -1 then
            v_ret(i) := priv_bins(v_bin_idx).cross_bins(i).values(0);
            priv_rand_transition_bin_idx       := v_bin_idx;
            priv_rand_transition_bin_value_idx := 1;
          else
            v_ret(i) := priv_bins(priv_rand_transition_bin_idx).cross_bins(i).values(priv_rand_transition_bin_value_idx);
            if priv_rand_transition_bin_value_idx < priv_bins(priv_rand_transition_bin_idx).cross_bins(i).num_values-1 then
              priv_rand_transition_bin_value_idx := priv_rand_transition_bin_value_idx + 1;
            else
              priv_rand_transition_bin_idx       := -1;
              priv_rand_transition_bin_value_idx := 0;
            end if;
          end if;
        else
          alert(TB_FAILURE, C_LOCAL_CALL & "=> Unexpected error, bin contains " & to_upper(to_string(priv_bins(v_bin_idx).cross_bins(i).contains)), priv_scope);
        end if;
      end loop;

      -- Do not print log message when being called from another function
      if ext_proc_call = "" then
        log(ID_FUNCT_COV_RAND, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope, msg_id_panel);
      end if;
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Coverage
    ------------------------------------------------------------
    procedure sample_coverage(
      constant value         : in integer;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL  : string := "sample_coverage(" & to_string(value) & ")";
      variable v_values      : integer_vector(0 to 0) := (0 => value);
    begin
      sample_coverage(v_values, msg_id_panel, C_LOCAL_CALL);
    end procedure;

    procedure sample_coverage(
      constant values        : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel;
      constant ext_proc_call : in string         := "") is
      constant C_LOCAL_CALL        : string := "sample_coverage(" & to_string(values) & ")";
      variable v_proc_call         : line;
      variable v_invalid_sample    : boolean := false;
      variable v_value_match       : std_logic_vector(0 to priv_num_bins_crossed-1) := (others => '0');
      variable v_illegal_match_idx : integer := -1;
      variable v_num_occurrences   : natural := 0;
    begin
      create_proc_call(C_LOCAL_CALL, ext_proc_call, v_proc_call);
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => v_proc_call.all);
      log(ID_FUNCT_COV_SAMPLE, v_proc_call.all, priv_scope, msg_id_panel);

      if priv_num_bins_crossed /= values'length then
        alert(TB_FAILURE, v_proc_call.all & "=> Number of values does not match the number of crossed bins", priv_scope);
      end if;

      -- Check if the values should be ignored or are illegal
      l_bin_loop : for i in 0 to priv_invalid_bins_idx-1 loop
        for j in 0 to priv_num_bins_crossed-1 loop
          case priv_invalid_bins(i).cross_bins(j).contains is
            when VAL | VAL_IGNORE | VAL_ILLEGAL =>
              for k in 0 to priv_invalid_bins(i).cross_bins(j).num_values-1 loop
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
              if values(j) = priv_invalid_bins(i).cross_bins(j).values(priv_invalid_bins(i).cross_bins(j).transition_idx) then
                if priv_invalid_bins(i).cross_bins(j).transition_idx < priv_invalid_bins(i).cross_bins(j).num_values-1 then
                  priv_invalid_bins(i).cross_bins(j).transition_idx := priv_invalid_bins(i).cross_bins(j).transition_idx + 1;
                else
                  priv_invalid_bins(i).cross_bins(j).transition_idx := 0;
                  v_value_match(j)    := '1';
                  v_illegal_match_idx := j when priv_invalid_bins(i).cross_bins(j).contains = TRN_ILLEGAL;
                end if;
              else
                priv_invalid_bins(i).cross_bins(j).transition_idx := 0;
              end if;
            when others =>
              alert(TB_FAILURE, v_proc_call.all & "=> Unexpected error, invalid bin contains " & to_upper(to_string(priv_invalid_bins(i).cross_bins(j).contains)), priv_scope);
          end case;
        end loop;

        if and(v_value_match) = '1' then
          v_invalid_sample := true;
          priv_invalid_bins(i).hits := priv_invalid_bins(i).hits + 1;
          if v_illegal_match_idx /= -1 then
            alert(WARNING, v_proc_call.all & "=> Sampled " & get_bin_info(priv_invalid_bins(i).cross_bins(v_illegal_match_idx)), priv_scope);
            exit l_bin_loop;
          end if;
        end if;
        v_value_match       := (others => '0');
        v_illegal_match_idx := -1;
      end loop;

      -- Check if the values are in the valid bins
      if not(v_invalid_sample) then
        for i in 0 to priv_bins_idx-1 loop
          for j in 0 to priv_num_bins_crossed-1 loop
            case priv_bins(i).cross_bins(j).contains is
              when VAL =>
                for k in 0 to priv_bins(i).cross_bins(j).num_values-1 loop
                  if values(j) = priv_bins(i).cross_bins(j).values(k) then
                    v_value_match(j) := '1';
                  end if;
                end loop;
              when RAN =>
                if values(j) >= priv_bins(i).cross_bins(j).values(0) and values(j) <= priv_bins(i).cross_bins(j).values(1) then
                  v_value_match(j) := '1';
                end if;
              when TRN =>
                if values(j) = priv_bins(i).cross_bins(j).values(priv_bins(i).cross_bins(j).transition_idx) then
                  if priv_bins(i).cross_bins(j).transition_idx < priv_bins(i).cross_bins(j).num_values-1 then
                    priv_bins(i).cross_bins(j).transition_idx := priv_bins(i).cross_bins(j).transition_idx + 1;
                  else
                    priv_bins(i).cross_bins(j).transition_idx := 0;
                    v_value_match(j) := '1';
                  end if;
                else
                  priv_bins(i).cross_bins(j).transition_idx := 0;
                end if;
              when others =>
                alert(TB_FAILURE, v_proc_call.all & "=> Unexpected error, valid bin contains " & to_upper(to_string(priv_bins(i).cross_bins(j).contains)), priv_scope);
            end case;
          end loop;

          if and(v_value_match) = '1' then
            priv_bins(i).hits := priv_bins(i).hits + 1;
            v_num_occurrences := v_num_occurrences + 1;
            -- Update covergroup status register
            -- Stop accumulating the coverage contribution of the bin when the goal has been reached
            if priv_bins(i).hits <= integer(real(priv_bins(i).min_hits)*real(protected_covergroup_status.get_combined_coverage_goal(priv_id))/100.0) then
              protected_covergroup_status.increment_hits_count(priv_id);
            end if;
            if priv_bins(i).hits = priv_bins(i).min_hits and priv_bins(i).min_hits /= 0 then
              protected_covergroup_status.increment_covered_bin_count(priv_id);
            end if;
          end if;
          v_value_match := (others => '0');
        end loop;

        if priv_detect_bin_overlap and v_num_occurrences > 1 then
          alert(TB_WARNING, "There is an overlap between " & to_string(v_num_occurrences) & " bins.", priv_scope);
        end if;
      end if;
      DEALLOCATE(v_proc_call);
    end procedure;

    procedure set_coverage_weight(
      constant weight       : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_coverage_weight(" & to_string(weight) & ")";
    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      log(ID_FUNCT_COV_CONFIG, C_LOCAL_CALL, priv_scope, msg_id_panel);
      -- Update covergroup status register
      protected_covergroup_status.set_coverage_weight(priv_id, weight);
    end procedure;

    procedure set_coverage_goal(
      constant percentage   : in positive;
      constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "set_coverage_goal(" & to_string(percentage) & ")";
    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      log(ID_FUNCT_COV_CONFIG, C_LOCAL_CALL, priv_scope, msg_id_panel);
      protected_covergroup_status.set_coverage_goal(priv_id, percentage);
    end procedure;

    impure function get_coverage(
      constant VOID : t_void)
    return real is
      constant C_LOCAL_CALL : string := "get_coverage(VOID)";
    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      return protected_covergroup_status.get_hits_coverage(priv_id);
    end function;

    impure function coverage_completed(
      constant VOID : t_void)
    return boolean is
      constant C_LOCAL_CALL : string := "coverage_completed(VOID)";
    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);
      return protected_covergroup_status.get_hits_coverage(priv_id) >= real(protected_covergroup_status.get_coverage_goal(priv_id));
    end function;

    procedure print_summary(
      constant VOID : in t_void) is
      constant C_LOCAL_CALL       : string := "print_summary(VOID)";
      constant C_PREFIX           : string := C_LOG_PREFIX & "     ";
      constant C_HEADER           : string := "*** FUNCTIONAL COVERAGE SUMMARY: " & to_string(priv_scope) & " ***";
      constant C_BIN_COLUMN_WIDTH : positive := 40; --Q: how to handle when bins overflow the column? trucante and "..."? currently shifts everything
      constant C_COLUMN_WIDTH     : positive := 15;
      variable v_line             : line;
      variable v_log_extra_space  : integer := 0;
    begin
      check_value(priv_id /= -1, TB_FAILURE, "Coverpoint has not been initialized", priv_scope, ID_NEVER, caller_name => C_LOCAL_CALL);

      -- Calculate how much space we can insert between the columns of the report
      v_log_extra_space := (C_LOG_LINE_WIDTH - C_PREFIX'length - C_BIN_COLUMN_WIDTH - C_COLUMN_WIDTH*5 - C_FC_MAX_NAME_LENGTH - 20)/6;
      if v_log_extra_space < 1 then
        alert(TB_WARNING, "C_LOG_LINE_WIDTH is too small or C_FC_MAX_NAME_LENGTH is too big, the report will not be properly aligned.", priv_scope);
        v_log_extra_space := 1;
      end if;

      -- Print report header
      write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
                    timestamp_header(now, justify(C_HEADER, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF &
                    fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print summary
      write(v_line, "Coverpoint:     " & priv_name & LF &
                    "Uncovered bins: " & to_string(protected_covergroup_status.get_num_uncovered_bins(priv_id)) & LF &
                    "Illegal bins:   " & to_string(protected_covergroup_status.get_num_illegal_bins(priv_id)) & LF &
                    "Coverage:       bins: " & to_string(protected_covergroup_status.get_bins_coverage(priv_id),2) & "% hits: " & to_string(protected_covergroup_status.get_hits_coverage(priv_id),2)
                      & "% (goal: " & to_string(protected_covergroup_status.get_coverage_goal(priv_id)) & "%)" & LF &
                    fill_string('-', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print column headers
      write(v_line, justify(
        fill_string(' ', 5) &
        justify("BINS"       , center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("HITS"       , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("MIN_HITS"   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("COVERAGE"   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("RAND_WEIGHT", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("NAME"       , center, C_FC_MAX_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("STATUS"     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
        left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);

      -- Print illegal bins
      for i in 0 to priv_invalid_bins_idx-1 loop
        if is_bin_illegal(priv_invalid_bins(i)) then
          write(v_line, justify(
            fill_string(' ', 5) &
            justify(get_bin_vector_values(priv_invalid_bins(i).cross_bins(0 to priv_num_bins_crossed-1)), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_invalid_bins(i).hits)        , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A"                                       , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A"                                       , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A"                                       , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_invalid_bins(i).name)        , center, C_FC_MAX_NAME_LENGTH, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("ILLEGAL"                                   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
            left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
        end if;
      end loop;

      -- Print ignore bins
      for i in 0 to priv_invalid_bins_idx-1 loop
        if is_bin_ignore(priv_invalid_bins(i)) then
          write(v_line, justify(
            fill_string(' ', 5) &
            justify(get_bin_vector_values(priv_invalid_bins(i).cross_bins(0 to priv_num_bins_crossed-1)), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_invalid_bins(i).hits)        , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A"                                       , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A"                                       , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("N/A"                                       , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_invalid_bins(i).name)        , center, C_FC_MAX_NAME_LENGTH, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("IGNORE"                                    , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
            left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
        end if;
      end loop;

      -- Print uncovered bins
      for i in 0 to priv_bins_idx-1 loop
        if priv_bins(i).hits < priv_bins(i).min_hits then
          write(v_line, justify(
            fill_string(' ', 5) &
            justify(get_bin_vector_values(priv_bins(i).cross_bins(0 to priv_num_bins_crossed-1)), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).hits)                     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).min_hits)                 , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_bin_coverage(priv_bins(i)),2) & "%", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).rand_weight)              , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).name)                     , center, C_FC_MAX_NAME_LENGTH, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("UNCOVERED"                                      , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
            left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
        end if;
      end loop;

      -- Print covered bins
      for i in 0 to priv_bins_idx-1 loop
        if priv_bins(i).hits >= priv_bins(i).min_hits then
          write(v_line, justify(
            fill_string(' ', 5) &
            justify(get_bin_vector_values(priv_bins(i).cross_bins(0 to priv_num_bins_crossed-1)), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).hits)                     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).min_hits)                 , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(get_bin_coverage(priv_bins(i)),2) & "%", center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).rand_weight)              , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify(to_string(priv_bins(i).name)                     , center, C_FC_MAX_NAME_LENGTH, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
            justify("COVERED"                                        , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
            left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
        end if;
      end loop;

      -- Print report bottom line
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

      -- Write the info string to transcript
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH-C_PREFIX'length);
      prefix_lines(v_line, C_PREFIX);
      write_line_to_log_destination(v_line);
      DEALLOCATE(v_line);
    end procedure;

  end protected body t_coverpoint;

end package body funct_cov_pkg;