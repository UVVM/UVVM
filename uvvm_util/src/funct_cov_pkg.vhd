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

  constant C_MAX_NUM_CROSS_BINS  : positive := 15;
  --TODO: move to adaptations_pkg?
  constant C_MAX_NUM_BINS        : positive := 100;
  constant C_MAX_NUM_BIN_VALUES  : positive := 10;
  constant C_MAX_BIN_NAME_LENGTH : positive := 20;

  ------------------------------------------------------------
  -- Types
  ------------------------------------------------------------
  type t_cov_bin_type is (VAL, VAL_IGNORE, VAL_ILLEGAL, RAN, RAN_IGNORE, RAN_ILLEGAL, TRN, TRN_IGNORE, TRN_ILLEGAL);
  type t_overlap_action is (ALERT, COUNT_ALL, COUNT_ONE);

  type t_new_bin is record
    contains   : t_cov_bin_type;
    values     : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
    num_values : natural;
  end record;
  type t_new_bin_vector is array (natural range <>) of t_new_bin;

  type t_cross_bin is record
    contains       : t_cov_bin_type;
    values         : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
    num_values     : natural;
    transition_idx : natural;
  end record;
  type t_cross_bin_vector is array (natural range <>) of t_cross_bin;

  type t_cov_bin is record
    contains       : t_cov_bin_type;
    values         : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
    num_values     : natural;
    transition_idx : natural;
    hits           : natural;
    min_hits       : natural;
    weight         : natural;
    name           : string(1 to C_MAX_BIN_NAME_LENGTH);
  end record;
  type t_cov_bin_vector is array (natural range <>) of t_cov_bin;

  type t_cov_cross is record
    bins           : t_cross_bin_vector(0 to C_MAX_NUM_CROSS_BINS-1);
    hits           : natural;
    min_hits       : natural;
    weight         : natural;
    name           : string(1 to C_MAX_BIN_NAME_LENGTH);
  end record;
  type t_cov_cross_vector is array (natural range <>) of t_cov_cross;

  ------------------------------------------------------------
  -- Functions
  ------------------------------------------------------------
  -- Creates a bin with a single value
  function bin(
    constant value      : integer)
  return t_new_bin_vector;

  -- Creates a bin with multiple values
  function bin(
    constant set_values : integer_vector)
  return t_new_bin_vector;

  -- Divides a range of values into a number bins. If num_bins is 0 then a bin is created for each value.
  -- e.g. (0,10) -> 11 bins [0,1,2,...,10] // (0,10,1) -> 1 bin [0:10] // (0,10,2) -> 2 bins [0:5] [6:10]
  function bin_range(
    constant min_value  : integer;
    constant max_value  : integer;
    constant num_bins   : natural := 0)
  return t_new_bin_vector;

  -- Creates a bin for each value in the vector's range
  function bin_vector(
    constant vector     : std_logic_vector)
  return t_new_bin_vector;

  -- Creates a bin a transition of values
  function bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_vector;

  -- Creates an ignore bin with a single value
  function ignore_bin(
    constant value      : integer)
  return t_new_bin_vector;

  -- Creates an ignore bin with a range of values
  function ignore_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_vector;

  -- Creates an ignore bin with a transition of values
  function ignore_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_vector;

  -- Creates an illegal bin with a single value
  function illegal_bin(
    constant value      : integer)
  return t_new_bin_vector;

  -- Creates an illegal bin with a range of values
  function illegal_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_vector;

  -- Creates an illegal bin with a transition of values
  function illegal_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_vector;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_cov_point is protected

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_scope(
      constant scope : in string);

    impure function get_scope(
      constant VOID : t_void)
    return string;

    ------------------------------------------------------------
    -- Bins
    ------------------------------------------------------------
    procedure add_bins(
      constant bin           : in t_new_bin_vector;
      constant min_cov       : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_bins(
      constant bin           : in t_new_bin_vector;
      constant min_cov       : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_bins(
      constant bin           : in t_new_bin_vector;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure add_cross(
      constant bin1          : in t_new_bin_vector;
      constant bin2          : in t_new_bin_vector;
      constant min_cov       : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    ------------------------------------------------------------
    -- Randomization
    ------------------------------------------------------------
    impure function rand(
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel)
    return integer;

    impure function rand(
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel)
    return integer_vector;

    ------------------------------------------------------------
    -- Coverage
    ------------------------------------------------------------
    procedure sample_coverage(
      constant value         : in integer;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure sample_coverage(
      constant values        : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel);

    procedure print_summary(
      constant VOID : in t_void);

  end protected t_cov_point;

end package funct_cov_pkg;

package body funct_cov_pkg is

  ------------------------------------------------------------
  -- Functions
  ------------------------------------------------------------
  -- Creates a bin with a single value
  function bin(
    constant value      : integer)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := VAL;
    v_ret(0).values(0)  := value;
    v_ret(0).num_values := 1;
    return v_ret;
  end function;

  -- Creates a bin with multiple values
  function bin(
    constant set_values : integer_vector)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := VAL;
    v_ret(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).num_values := set_values'length;
    return v_ret;
  end function;

  -- Divides a range of values into a number bins. If num_bins is 0 then a bin is created for each value.
  -- e.g. (0,10) -> 11 bins [0,1,2,...,10] // (0,10,1) -> 1 bin [0:10] // (0,10,2) -> 2 bins [0:5] [6:10]
  --Q: if division has a residue, either leave it to the last bin or spread it among bins (OSSVM)
  --   -- 1 to 2, 3 to 4, 5 to 6, 7 to 10
  --   -- 1 to 2, 3 to 4, 5 to 7, 8 to 10
  -- **10 /  1; = 10                -- 1 to 10
  -- **10 /  2; = 5                 -- 1 to 5, 6 to 10
  -- 10 /  4; = 2 (round down 2.5)  -- 1 to 2, 3 to 4, 5 to 6, 7 to 8
  -- 10 /  9; = 1 (round down 1.1)
  -- **10 / 10; = 1                 -- 1 to 1, 2 to 2, ...,  10 to 10
  -- **10 / 11; = 0                 -- 1 to 1, 2 to 2, ...,  10 to 10
  function bin_range(
    constant min_value  : integer;
    constant max_value  : integer;
    constant num_bins   : natural := 0)
  return t_new_bin_vector is
    constant C_RANGE_WIDTH : integer := (max_value - min_value + 1); --TODO: absolute value
    variable v_div_range   : integer;
    variable v_num_bins    : integer;
    variable v_ret : t_new_bin_vector(0 to C_RANGE_WIDTH-1);
  begin
    -- Create a bin for each value in the range
    if num_bins = 0 then
      for i in min_value to max_value loop
        v_ret(i-min_value to i-min_value) := bin(i);
      end loop;
      v_num_bins  := C_RANGE_WIDTH;
    -- Create several bins
    elsif min_value <= max_value then
      if C_RANGE_WIDTH > num_bins then
        v_div_range := C_RANGE_WIDTH / num_bins;
        v_num_bins  := num_bins;
      else
        v_div_range := C_RANGE_WIDTH;
        v_num_bins  := 1;
      end if;
      --TODO: figure out what to do with remaining values
      for i in 0 to v_num_bins-1 loop
        v_ret(i).contains   := RAN;
        v_ret(i).values(0)  := min_value+v_div_range*i;
        v_ret(i).values(1)  := min_value+v_div_range*(i+1)-1;
        v_ret(i).num_values := 2;
      end loop;
    else
      --alert(TB_ERROR, v_proc_call.all & "=> Failed. min_value must be less than max_value", priv_scope.all);
    end if;
    return v_ret(0 to v_num_bins-1);
  end function;

  -- Creates a bin for each value in the vector's range
  function bin_vector(
    constant vector     : std_logic_vector)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 2**vector'length-1);
  begin
    for i in v_ret'range loop
      v_ret(i to i) := bin(i);
    end loop;
    return v_ret;
  end function;

  -- Creates a bin a transition of values
  function bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := TRN;
    v_ret(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).num_values := set_values'length;
    return v_ret;
  end function;

  -- Creates an ignore bin with a single value
  function ignore_bin(
    constant value      : integer)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := VAL_IGNORE;
    v_ret(0).values(0)  := value;
    v_ret(0).num_values := 1;
    return v_ret;
  end function;

  -- Creates an ignore bin with a range of values
  function ignore_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := RAN_IGNORE;
    v_ret(0).values(0)  := min_value;
    v_ret(0).values(1)  := max_value;
    v_ret(0).num_values := 2;
    return v_ret;
  end function;

  -- Creates an ignore bin with a transition of values
  function ignore_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := TRN_IGNORE;
    v_ret(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).num_values := set_values'length;
    return v_ret;
  end function;

  -- Creates an illegal bin with a single value
  function illegal_bin(
    constant value      : integer)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := VAL_ILLEGAL;
    v_ret(0).values(0)  := value;
    v_ret(0).num_values := 1;
    return v_ret;
  end function;

  -- Creates an illegal bin with a range of values
  function illegal_bin_range(
    constant min_value  : integer;
    constant max_value  : integer)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := RAN_ILLEGAL;
    v_ret(0).values(0)  := min_value;
    v_ret(0).values(1)  := max_value;
    v_ret(0).num_values := 2;
    return v_ret;
  end function;

  -- Creates an illegal bin with a transition of values
  function illegal_bin_transition(
    constant set_values : integer_vector)
  return t_new_bin_vector is
    variable v_ret : t_new_bin_vector(0 to 0);
  begin
    v_ret(0).contains   := TRN_ILLEGAL;
    v_ret(0).values(0 to set_values'length-1) := set_values;
    v_ret(0).num_values := set_values'length;
    return v_ret;
  end function;

  ------------------------------------------------------------
  -- Protected type
  ------------------------------------------------------------
  type t_cov_point is protected body
    variable priv_scope                         : line    := new string'(C_SCOPE);
    variable priv_bins                          : t_cov_bin_vector(0 to C_MAX_NUM_BINS-1);
    variable priv_bins_idx                      : natural := 0;
    variable priv_invalid_bins                  : t_cov_bin_vector(0 to C_MAX_NUM_BINS-1);
    variable priv_invalid_bins_idx              : natural := 0;
    variable priv_num_bins_crossed              : integer := -1;
    variable priv_cross                         : t_cov_cross_vector(0 to C_MAX_NUM_BINS-1);
    variable priv_cross_idx                     : natural := 0;
    variable priv_invalid_cross                 : t_cov_cross_vector(0 to C_MAX_NUM_BINS-1);
    variable priv_invalid_cross_idx             : natural := 0;
    variable priv_rand_gen                      : t_rand;
    variable priv_rand_transition_bin_idx       : integer := -1;
    variable priv_rand_transition_bin_value_idx : natural := 0;

    ------------------------------------------------------------
    -- Internal functions and procedures
    ------------------------------------------------------------
    -- Returns the string representation of the bin vector
    impure function to_string(
      bins           : t_new_bin_vector;
      use_in_summary : boolean := false)
    return string is
      variable v_line   : line;
      variable v_result : string(1 to 500);
      variable v_width  : natural;
    begin
      for i in bins'range loop
        case bins(i).contains is
          when VAL | VAL_IGNORE | VAL_ILLEGAL =>
            if bins(i).contains = VAL then
              write(v_line, string'(return_string1_if_true_otherwise_string2("", "bin", use_in_summary)));
            elsif bins(i).contains = VAL_IGNORE then
              write(v_line, string'(return_string1_if_true_otherwise_string2("IGN", "ignore_bin", use_in_summary)));
            else
              write(v_line, string'(return_string1_if_true_otherwise_string2("ILL", "illegal_bin", use_in_summary)));
            end if;
            if bins(i).num_values = 1 then
              write(v_line, '(');
              write(v_line, to_string(bins(i).values(0)));
              write(v_line, ')');
            else
              write(v_line, to_string(bins(i).values(0 to bins(i).num_values-1)));
            end if;
          when RAN | RAN_IGNORE | RAN_ILLEGAL =>
            if bins(i).contains = RAN then
              write(v_line, string'(return_string1_if_true_otherwise_string2("", "bin_range", use_in_summary)));
            elsif bins(i).contains = RAN_IGNORE then
              write(v_line, string'(return_string1_if_true_otherwise_string2("IGN", "ignore_bin_range", use_in_summary)));
            else
              write(v_line, string'(return_string1_if_true_otherwise_string2("ILL", "illegal_bin_range", use_in_summary)));
            end if;
            write(v_line, "(" & to_string(bins(i).values(0)) & " to " & to_string(bins(i).values(1)) & ")");
          when TRN | TRN_IGNORE | TRN_ILLEGAL =>
            if bins(i).contains = TRN then
              write(v_line, string'(return_string1_if_true_otherwise_string2("", "bin_transition", use_in_summary)));
            elsif bins(i).contains = TRN_IGNORE then
              write(v_line, string'(return_string1_if_true_otherwise_string2("IGN", "ignore_bin_transition", use_in_summary)));
            else
              write(v_line, string'(return_string1_if_true_otherwise_string2("ILL", "illegal_bin_transition", use_in_summary)));
            end if;
            write(v_line, '(');
            for j in 0 to bins(i).num_values-1 loop
              write(v_line, to_string(bins(i).values(j)));
              if j < bins(i).num_values-1 then
                write(v_line, string'("->"));
              end if;
            end loop;
            write(v_line, ')');
        end case;
        if i < bins'length-1 then
          write(v_line, string'(return_string1_if_true_otherwise_string2("x", ",", use_in_summary)));
        end if;
      end loop;

      v_width := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end function;

    -- Overload
    impure function to_string(
      bins           : t_cross_bin_vector;
      use_in_summary : boolean := false)
    return string is
      variable v_new_bin_vector : t_new_bin_vector(bins'range);
    begin
      for i in v_new_bin_vector'range loop
        v_new_bin_vector(i).contains   := bins(i).contains;
        v_new_bin_vector(i).values     := bins(i).values;
        v_new_bin_vector(i).num_values := bins(i).num_values;
      end loop;
      return to_string(v_new_bin_vector, use_in_summary);
    end function;

    -- Overload
    impure function to_string(
      bins           : t_cov_bin_vector;
      use_in_summary : boolean := false)
    return string is
      variable v_new_bin_vector : t_new_bin_vector(bins'range);
    begin
      for i in v_new_bin_vector'range loop
        v_new_bin_vector(i).contains   := bins(i).contains;
        v_new_bin_vector(i).values     := bins(i).values;
        v_new_bin_vector(i).num_values := bins(i).num_values;
      end loop;
      return to_string(v_new_bin_vector, use_in_summary);
    end function;

    -- Returns the string representation of the bin content
    function to_string(
      bin_type       : t_cov_bin_type;
      bin_values     : integer_vector;
      bin_num_values : natural)
    return string is
      variable v_line   : line;
      variable v_result : string(1 to 100);
      variable v_width  : natural;
    begin
      case bin_type is
        when VAL | VAL_IGNORE | VAL_ILLEGAL =>
          if bin_type = VAL_IGNORE then
            write(v_line, string'("IGN"));
          elsif bin_type = VAL_ILLEGAL then
            write(v_line, string'("ILL"));
          end if;
          write(v_line, '(');
          for i in 0 to bin_num_values-1 loop
            write(v_line, to_string(bin_values(i)));
            if i < bin_num_values-1 then
              write(v_line, string'(","));
            end if;
          end loop;
        when RAN | RAN_IGNORE | RAN_ILLEGAL =>
          if bin_type = RAN_IGNORE then
            write(v_line, string'("IGN"));
          elsif bin_type = RAN_ILLEGAL then
            write(v_line, string'("ILL"));
          end if;
          write(v_line, '(' & to_string(bin_values(0)) & " to " & to_string(bin_values(1)));
        when TRN | TRN_IGNORE | TRN_ILLEGAL =>
          if bin_type = TRN_IGNORE then
            write(v_line, string'("IGN"));
          elsif bin_type = TRN_ILLEGAL then
            write(v_line, string'("ILL"));
          end if;
          write(v_line, '(');
          for i in 0 to bin_num_values-1 loop
            write(v_line, to_string(bin_values(i)));
            if i < bin_num_values-1 then
              write(v_line, string'("->"));
            end if;
          end loop;
      end case;
      write(v_line, ')');

      v_width := v_line'length;
      v_result(1 to v_width) := v_line.all;
      deallocate(v_line);
      return v_result(1 to v_width);
    end function;

    ------------------------------------------------------------
    -- Configuration
    ------------------------------------------------------------
    procedure set_scope(
      constant scope : in string) is
    begin
      DEALLOCATE(priv_scope);
      priv_scope := new string'(scope);
    end procedure;

    impure function get_scope(
      constant VOID : t_void)
    return string is
    begin
      return priv_scope.all;
    end function;

    ------------------------------------------------------------
    -- Bins
    ------------------------------------------------------------
    procedure add_bins(
      constant bin           : in t_new_bin_vector;
      constant min_cov       : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_bins(" & to_string(bin) & ", min_cov:" & to_string(min_cov) &
        ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
    begin
      log(ID_FUNCT_COV, C_LOCAL_CALL, priv_scope.all, msg_id_panel);

      -- Store the bins in the corresponding bin structure
      for i in bin'range loop
        if bin(i).contains = VAL or bin(i).contains = RAN or bin(i).contains = TRN then
          priv_bins(priv_bins_idx).contains                   := bin(i).contains;
          priv_bins(priv_bins_idx).values                     := bin(i).values;
          priv_bins(priv_bins_idx).num_values                 := bin(i).num_values;
          priv_bins(priv_bins_idx).transition_idx             := 0;
          priv_bins(priv_bins_idx).hits                       := 0;
          priv_bins(priv_bins_idx).min_hits                   := min_cov;
          priv_bins(priv_bins_idx).weight                     := rand_weight;
          priv_bins(priv_bins_idx).name(1 to bin_name'length) := bin_name;
          priv_bins_idx := priv_bins_idx + 1;
        else
          priv_invalid_bins(priv_invalid_bins_idx).contains                   := bin(i).contains;
          priv_invalid_bins(priv_invalid_bins_idx).values                     := bin(i).values;
          priv_invalid_bins(priv_invalid_bins_idx).num_values                 := bin(i).num_values;
          priv_invalid_bins(priv_invalid_bins_idx).transition_idx             := 0;
          priv_invalid_bins(priv_invalid_bins_idx).hits                       := 0;
          priv_invalid_bins(priv_invalid_bins_idx).min_hits                   := 0;
          priv_invalid_bins(priv_invalid_bins_idx).weight                     := 0;
          priv_invalid_bins(priv_invalid_bins_idx).name(1 to bin_name'length) := bin_name;
          priv_invalid_bins_idx := priv_invalid_bins_idx + 1;
        end if;
      end loop;
    end procedure;

    procedure add_bins(
      constant bin           : in t_new_bin_vector;
      constant min_cov       : in positive;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      add_bins(bin, min_cov, 1, bin_name, msg_id_panel);
    end procedure;

    procedure add_bins(
      constant bin           : in t_new_bin_vector;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
    begin
      add_bins(bin, 1, 1, bin_name, msg_id_panel);
    end procedure;

    procedure add_cross(
      constant bin1          : in t_new_bin_vector;
      constant bin2          : in t_new_bin_vector;
      constant min_cov       : in positive;
      constant rand_weight   : in natural;
      constant bin_name      : in string         := "";
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL : string := "add_cross((" & to_string(bin1) & "),(" & to_string(bin2) & "), min_cov:" & to_string(min_cov) &
        ", rand_weight:" & to_string(rand_weight) & ", """ & bin_name & """)";
    begin
      log(ID_FUNCT_COV, C_LOCAL_CALL, priv_scope.all, msg_id_panel);

      -- The number of bins crossed is set on the first call and can't be changed
      if priv_num_bins_crossed = -1 then
        priv_num_bins_crossed := 2;
      elsif priv_num_bins_crossed /= 2 then
        alert(TB_FAILURE, C_LOCAL_CALL & "=> Failed. Cannot mix different number of crossed bins.", priv_scope.all);
      end if;

      -- Store the crossed bins in the corresponding bin structure
      for i in bin1'range loop
        for j in bin2'range loop
          if (bin1(i).contains = VAL or bin1(i).contains = RAN or bin1(i).contains = TRN) and
             (bin2(j).contains = VAL or bin2(j).contains = RAN or bin2(j).contains = TRN)
          then
            priv_cross(priv_cross_idx).bins(0).contains           := bin1(i).contains;
            priv_cross(priv_cross_idx).bins(0).values             := bin1(i).values;
            priv_cross(priv_cross_idx).bins(0).num_values         := bin1(i).num_values;
            priv_cross(priv_cross_idx).bins(0).transition_idx     := 0;
            priv_cross(priv_cross_idx).bins(1).contains           := bin2(j).contains;
            priv_cross(priv_cross_idx).bins(1).values             := bin2(j).values;
            priv_cross(priv_cross_idx).bins(1).num_values         := bin2(j).num_values;
            priv_cross(priv_cross_idx).bins(1).transition_idx     := 0;
            priv_cross(priv_cross_idx).hits                       := 0;
            priv_cross(priv_cross_idx).min_hits                   := min_cov;
            priv_cross(priv_cross_idx).weight                     := rand_weight;
            priv_cross(priv_cross_idx).name(1 to bin_name'length) := bin_name;
            priv_cross_idx := priv_cross_idx + 1;
          else
            priv_invalid_cross(priv_invalid_cross_idx).bins(0).contains           := bin1(i).contains;
            priv_invalid_cross(priv_invalid_cross_idx).bins(0).values             := bin1(i).values;
            priv_invalid_cross(priv_invalid_cross_idx).bins(0).num_values         := bin1(i).num_values;
            priv_invalid_cross(priv_invalid_cross_idx).bins(0).transition_idx     := 0;
            priv_invalid_cross(priv_invalid_cross_idx).bins(1).contains           := bin2(j).contains;
            priv_invalid_cross(priv_invalid_cross_idx).bins(1).values             := bin2(j).values;
            priv_invalid_cross(priv_invalid_cross_idx).bins(1).num_values         := bin2(j).num_values;
            priv_invalid_cross(priv_invalid_cross_idx).bins(1).transition_idx     := 0;
            priv_invalid_cross(priv_invalid_cross_idx).hits                       := 0;
            priv_invalid_cross(priv_invalid_cross_idx).min_hits                   := 0;
            priv_invalid_cross(priv_invalid_cross_idx).weight                     := 0;
            priv_invalid_cross(priv_invalid_cross_idx).name(1 to bin_name'length) := bin_name;
            priv_invalid_cross_idx := priv_invalid_cross_idx + 1;
          end if;
        end loop;
      end loop;
    end procedure;

    ------------------------------------------------------------
    -- Randomization
    ------------------------------------------------------------
    impure function rand(
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel)
    return integer is
      constant C_LOCAL_CALL      : string := "rand()";
      variable v_bin_weight_list : t_val_weight_int_vec(0 to priv_bins_idx-1);
      variable v_acc_weight      : integer := 0;
      variable v_values_vec      : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
      variable v_bin_idx         : integer;
      variable v_ret             : integer;
    begin
      -- A transition bin returns all the transition values before allowing to select a different bin value
      if priv_rand_transition_bin_idx /= -1 then
        v_bin_idx := priv_rand_transition_bin_idx;
      else
        -- Assign each bin a randomization weight
        for i in 0 to priv_bins_idx-1 loop
          v_bin_weight_list(i).value := i;
          if priv_bins(i).hits < priv_bins(i).min_hits then
            v_bin_weight_list(i).weight := priv_bins(i).weight;
          else
            v_bin_weight_list(i).weight := 0;
          end if;
          v_acc_weight := v_acc_weight + v_bin_weight_list(i).weight;
        end loop;
        -- When all bins have reached their min_hits re-enable valid bins for selection
        if v_acc_weight = 0 then
          for i in 0 to priv_bins_idx-1 loop
            v_bin_weight_list(i).weight := priv_bins(i).weight;
          end loop;
        end if;

        -- Choose a random bin index
        v_bin_idx := priv_rand_gen.rand_val_weight(v_bin_weight_list, msg_id_panel);
      end if;

      -- Select the random bin value to return (ignore and illegal bin values are never selected)
      if priv_bins(v_bin_idx).contains = VAL then
        if priv_bins(v_bin_idx).num_values = 1 then
          v_ret := priv_bins(v_bin_idx).values(0);
        else
          for i in 0 to priv_bins(v_bin_idx).num_values-1 loop
            v_values_vec(i) := priv_bins(v_bin_idx).values(i);
          end loop;
          v_ret := priv_rand_gen.rand(ONLY, v_values_vec(0 to priv_bins(v_bin_idx).num_values-1), NON_CYCLIC, msg_id_panel);
        end if;
      elsif priv_bins(v_bin_idx).contains = RAN then
        v_ret := priv_rand_gen.rand(priv_bins(v_bin_idx).values(0), priv_bins(v_bin_idx).values(1), NON_CYCLIC, msg_id_panel);
      elsif priv_bins(v_bin_idx).contains = TRN then
        if priv_rand_transition_bin_idx = -1 then
          v_ret := priv_bins(v_bin_idx).values(0);
          priv_rand_transition_bin_value_idx := 1;
          priv_rand_transition_bin_idx       := v_bin_idx;
        else
          v_ret := priv_bins(priv_rand_transition_bin_idx).values(priv_rand_transition_bin_value_idx);
          if priv_rand_transition_bin_value_idx < priv_bins(priv_rand_transition_bin_idx).num_values-1 then
            priv_rand_transition_bin_value_idx := priv_rand_transition_bin_value_idx + 1;
          else
            priv_rand_transition_bin_idx       := -1;
            priv_rand_transition_bin_value_idx := 0;
          end if;
        end if;
      else
        alert(TB_FAILURE, C_LOCAL_CALL & "=> Failed. Unexpected error, bin contains " & to_upper(to_string(priv_bins(v_bin_idx).contains)), priv_scope.all);
      end if;

      log(ID_FUNCT_COV, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope.all, msg_id_panel);
      return v_ret;
    end function;

    impure function rand(
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel)
    return integer_vector is
      constant C_LOCAL_CALL      : string := "rand()";
      variable v_bin_weight_list : t_val_weight_int_vec(0 to priv_cross_idx-1);
      variable v_acc_weight      : integer := 0;
      variable v_values_vec      : integer_vector(0 to C_MAX_NUM_BIN_VALUES-1);
      variable v_bin_idx         : integer;
      variable v_ret             : integer_vector(0 to priv_num_bins_crossed-1);
    begin
      -- A transition bin returns all the transition values before allowing to select a different bin value
      if priv_rand_transition_bin_idx /= -1 then
        v_bin_idx := priv_rand_transition_bin_idx;
      else
        -- Assign each bin a randomization weight
        for i in 0 to priv_cross_idx-1 loop
          v_bin_weight_list(i).value := i;
          if priv_cross(i).hits < priv_cross(i).min_hits then
            v_bin_weight_list(i).weight := priv_cross(i).weight;
          else
            v_bin_weight_list(i).weight := 0;
          end if;
          v_acc_weight := v_acc_weight + v_bin_weight_list(i).weight;
        end loop;
        -- When all bins have reached their min_hits re-enable valid bins for selection
        if v_acc_weight = 0 then
          for i in 0 to priv_cross_idx-1 loop
            v_bin_weight_list(i).weight := priv_cross(i).weight;
          end loop;
        end if;

        -- Choose a random bin index
        v_bin_idx := priv_rand_gen.rand_val_weight(v_bin_weight_list, msg_id_panel);
      end if;

      -- Select the random bin values to return (ignore and illegal bin values are never selected)
      for i in 0 to priv_num_bins_crossed-1 loop
        v_values_vec := (others => 0);
        if priv_cross(v_bin_idx).bins(i).contains = VAL then
          if priv_cross(v_bin_idx).bins(i).num_values = 1 then
            v_ret(i) := priv_cross(v_bin_idx).bins(i).values(0);
          else
            for j in 0 to priv_cross(v_bin_idx).bins(i).num_values-1 loop
              v_values_vec(j) := priv_cross(v_bin_idx).bins(i).values(j);
            end loop;
            v_ret(i) := priv_rand_gen.rand(ONLY, v_values_vec(0 to priv_cross(v_bin_idx).bins(i).num_values-1), NON_CYCLIC, msg_id_panel);
          end if;
        elsif priv_cross(v_bin_idx).bins(i).contains = RAN then
          v_ret(i) := priv_rand_gen.rand(priv_cross(v_bin_idx).bins(i).values(0), priv_cross(v_bin_idx).bins(i).values(1), NON_CYCLIC, msg_id_panel);
        elsif priv_cross(v_bin_idx).bins(i).contains = TRN then
          if priv_rand_transition_bin_idx = -1 then
            v_ret(i) := priv_cross(v_bin_idx).bins(i).values(0);
            priv_rand_transition_bin_idx       := v_bin_idx;
            priv_rand_transition_bin_value_idx := 1;
          else
            v_ret(i) := priv_cross(priv_rand_transition_bin_idx).bins(i).values(priv_rand_transition_bin_value_idx);
            if priv_rand_transition_bin_value_idx < priv_cross(priv_rand_transition_bin_idx).bins(i).num_values-1 then
              priv_rand_transition_bin_value_idx := priv_rand_transition_bin_value_idx + 1;
            else
              priv_rand_transition_bin_idx       := -1;
              priv_rand_transition_bin_value_idx := 0;
            end if;
          end if;
        else
          alert(TB_FAILURE, C_LOCAL_CALL & "=> Failed. Unexpected error, bin contains " & to_upper(to_string(priv_cross(v_bin_idx).bins(i).contains)), priv_scope.all);
        end if;
      end loop;

      log(ID_FUNCT_COV, C_LOCAL_CALL & "=> " & to_string(v_ret), priv_scope.all, msg_id_panel);
      return v_ret;
    end function;

    ------------------------------------------------------------
    -- Coverage
    ------------------------------------------------------------
    procedure sample_coverage(
      constant value         : in integer;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL     : string := "sample_coverage(" & to_string(value) & ")";
      variable v_invalid_sample : boolean := false;
    begin
      log(ID_FUNCT_COV, C_LOCAL_CALL, priv_scope.all, msg_id_panel);

      -- Check if the value should be ignored or is illegal
      l_bin_loop : for i in 0 to priv_invalid_bins_idx-1 loop
        case priv_invalid_bins(i).contains is
          when VAL_IGNORE | VAL_ILLEGAL =>
            for j in 0 to priv_invalid_bins(i).num_values-1 loop
              if value = priv_invalid_bins(i).values(j) then
                v_invalid_sample := true;
                priv_invalid_bins(i).hits := priv_invalid_bins(i).hits + 1;
                if priv_invalid_bins(i).contains = VAL_ILLEGAL then
                  alert(TB_WARNING, C_LOCAL_CALL & "=> Sampled " & to_string(priv_invalid_bins(i to i)), priv_scope.all);
                  exit l_bin_loop;
                end if;
              end if;
            end loop;
          when RAN_IGNORE | RAN_ILLEGAL =>
            if value >= priv_invalid_bins(i).values(0) and value <= priv_invalid_bins(i).values(1) then
              v_invalid_sample := true;
              priv_invalid_bins(i).hits := priv_invalid_bins(i).hits + 1;
              if priv_invalid_bins(i).contains = RAN_ILLEGAL then
                alert(TB_WARNING, C_LOCAL_CALL & "=> Sampled " & to_string(priv_invalid_bins(i to i)), priv_scope.all);
                exit l_bin_loop;
              end if;
            end if;
          when TRN_IGNORE | TRN_ILLEGAL =>
            if value = priv_invalid_bins(i).values(priv_invalid_bins(i).transition_idx) then
              if priv_invalid_bins(i).transition_idx < priv_invalid_bins(i).num_values-1 then
                priv_invalid_bins(i).transition_idx := priv_invalid_bins(i).transition_idx + 1;
              else
                v_invalid_sample := true;
                priv_invalid_bins(i).transition_idx := 0;
                priv_invalid_bins(i).hits           := priv_invalid_bins(i).hits + 1;
                if priv_invalid_bins(i).contains = TRN_ILLEGAL then
                  alert(TB_WARNING, C_LOCAL_CALL & "=> Sampled " & to_string(priv_invalid_bins(i to i)), priv_scope.all);
                  exit l_bin_loop;
                end if;
              end if;
            else
              priv_invalid_bins(i).transition_idx := 0;
            end if;
          when others =>
            alert(TB_FAILURE, C_LOCAL_CALL & "=> Failed. Unexpected error, invalid bin contains " & to_upper(to_string(priv_invalid_bins(i).contains)), priv_scope.all);
        end case;
      end loop;

      -- Check if the value is in the valid bins
      if not(v_invalid_sample) then
        for i in 0 to priv_bins_idx-1 loop
          case priv_bins(i).contains is
            when VAL =>
              for j in 0 to priv_bins(i).num_values-1 loop
                if value = priv_bins(i).values(j) then
                  priv_bins(i).hits := priv_bins(i).hits + 1;
                end if;
              end loop;
            when RAN =>
              if value >= priv_bins(i).values(0) and value <= priv_bins(i).values(1) then
                priv_bins(i).hits := priv_bins(i).hits + 1;
              end if;
            when TRN =>
              if value = priv_bins(i).values(priv_bins(i).transition_idx) then
                if priv_bins(i).transition_idx < priv_bins(i).num_values-1 then
                  priv_bins(i).transition_idx := priv_bins(i).transition_idx + 1;
                else
                  priv_bins(i).transition_idx := 0;
                  priv_bins(i).hits           := priv_bins(i).hits + 1;
                end if;
              else
                priv_bins(i).transition_idx := 0;
              end if;
            when others =>
              alert(TB_FAILURE, C_LOCAL_CALL & "=> Failed. Unexpected error, valid bin contains " & to_upper(to_string(priv_bins(i).contains)), priv_scope.all);
          end case;
        end loop;
      end if;
    end procedure;

    procedure sample_coverage(
      constant values        : in integer_vector;
      constant msg_id_panel  : in t_msg_id_panel := shared_msg_id_panel) is
      constant C_LOCAL_CALL        : string := "sample_coverage(" & to_string(values) & ")";
      variable v_invalid_sample    : boolean := false;
      variable v_value_match       : std_logic_vector(0 to priv_num_bins_crossed-1) := (others => '0');
      variable v_illegal_match_idx : integer := -1;
    begin
      log(ID_FUNCT_COV, C_LOCAL_CALL, priv_scope.all, msg_id_panel);

      check_value(values'length, priv_num_bins_crossed, TB_FAILURE, "Number of values does not match the number of crossed bins.", priv_scope.all, ID_NEVER, msg_id_panel, C_LOCAL_CALL);

      -- Check if the values should be ignored or are illegal
      l_cross_bin_loop : for i in 0 to priv_invalid_cross_idx-1 loop
        for j in 0 to priv_num_bins_crossed-1 loop
          case priv_invalid_cross(i).bins(j).contains is
            when VAL | VAL_IGNORE | VAL_ILLEGAL =>
              for k in 0 to priv_invalid_cross(i).bins(j).num_values-1 loop
                if values(j) = priv_invalid_cross(i).bins(j).values(k) then
                  v_value_match(j)    := '1';
                  v_illegal_match_idx := j when priv_invalid_cross(i).bins(j).contains = VAL_ILLEGAL;
                end if;
              end loop;
            when RAN | RAN_IGNORE | RAN_ILLEGAL =>
              if values(j) >= priv_invalid_cross(i).bins(j).values(0) and values(j) <= priv_invalid_cross(i).bins(j).values(1) then
                v_value_match(j)    := '1';
                v_illegal_match_idx := j when priv_invalid_cross(i).bins(j).contains = RAN_ILLEGAL;
              end if;
            when TRN | TRN_IGNORE | TRN_ILLEGAL =>
              if values(j) = priv_invalid_cross(i).bins(j).values(priv_invalid_cross(i).bins(j).transition_idx) then
                if priv_invalid_cross(i).bins(j).transition_idx < priv_invalid_cross(i).bins(j).num_values-1 then
                  priv_invalid_cross(i).bins(j).transition_idx := priv_invalid_cross(i).bins(j).transition_idx + 1;
                else
                  priv_invalid_cross(i).bins(j).transition_idx := 0;
                  v_value_match(j)    := '1';
                  v_illegal_match_idx := j when priv_invalid_cross(i).bins(j).contains = TRN_ILLEGAL;
                end if;
              else
                priv_invalid_cross(i).bins(j).transition_idx := 0;
              end if;
            when others =>
              alert(TB_FAILURE, C_LOCAL_CALL & "=> Failed. Unexpected error, invalid bin contains " & to_upper(to_string(priv_invalid_cross(i).bins(j).contains)), priv_scope.all);
          end case;
        end loop;

        if and(v_value_match) = '1' then
          v_invalid_sample := true;
          priv_invalid_cross(i).hits := priv_invalid_cross(i).hits + 1;
          if v_illegal_match_idx /= -1 then
            alert(TB_WARNING, C_LOCAL_CALL & "=> Sampled " & to_string(priv_invalid_cross(i).bins(v_illegal_match_idx to v_illegal_match_idx)), priv_scope.all);
            exit l_cross_bin_loop;
          end if;
        end if;
        v_value_match       := (others => '0');
        v_illegal_match_idx := -1;
      end loop;

      -- Check if the values are in the valid bins
      if not(v_invalid_sample) then
        for i in 0 to priv_cross_idx-1 loop
          for j in 0 to priv_num_bins_crossed-1 loop
            case priv_cross(i).bins(j).contains is
              when VAL =>
                for k in 0 to priv_cross(i).bins(j).num_values-1 loop
                  if values(j) = priv_cross(i).bins(j).values(k) then
                    v_value_match(j) := '1';
                  end if;
                end loop;
              when RAN =>
                if values(j) >= priv_cross(i).bins(j).values(0) and values(j) <= priv_cross(i).bins(j).values(1) then
                  v_value_match(j) := '1';
                end if;
              when TRN =>
                if values(j) = priv_cross(i).bins(j).values(priv_cross(i).bins(j).transition_idx) then
                  if priv_cross(i).bins(j).transition_idx < priv_cross(i).bins(j).num_values-1 then
                    priv_cross(i).bins(j).transition_idx := priv_cross(i).bins(j).transition_idx + 1;
                  else
                    priv_cross(i).bins(j).transition_idx := 0;
                    v_value_match(j) := '1';
                  end if;
                else
                  priv_cross(i).bins(j).transition_idx := 0;
                end if;
              when others =>
                alert(TB_FAILURE, C_LOCAL_CALL & "=> Failed. Unexpected error, valid bin contains " & to_upper(to_string(priv_cross(i).bins(j).contains)), priv_scope.all);
            end case;
          end loop;

          if and(v_value_match) = '1' then
            priv_cross(i).hits := priv_cross(i).hits + 1;
          end if;
          v_value_match := (others => '0');
        end loop;
      end if;

    end procedure;

    --Q: use same report as scoreboard?
    --Q: how to handle bins with several values? make COLUMN_WIDTH for BINS bigger than others - how big?, truncate and add "..."
    procedure print_summary(
      constant VOID : in t_void) is
      constant C_PREFIX           : string := C_LOG_PREFIX & "     ";
      constant C_HEADER           : string := "*** FUNCTIONAL COVERAGE SUMMARY: " & to_string(priv_scope.all) & " ***";
      constant C_BIN_COLUMN_WIDTH : positive := 40;
      constant C_COLUMN_WIDTH     : positive := 15;
      variable v_line             : line;
      variable v_line_copy        : line;
      variable v_log_extra_space  : integer := 0;

      function is_bin_covered(bin : t_cov_bin) return string is
      begin
        if bin.contains = VAL_ILLEGAL or bin.contains = RAN_ILLEGAL or bin.contains = TRN_ILLEGAL then
          return "-";
        elsif bin.hits >= bin.min_hits then
          return "YES";
        else
          return "NO";
        end if;
      end function;

      function is_bin_covered(cross : t_cov_cross) return string is
      begin
        for i in cross.bins'range loop
          if cross.bins(i).contains = VAL_ILLEGAL or cross.bins(i).contains = RAN_ILLEGAL or cross.bins(i).contains = TRN_ILLEGAL then
            return "-";
          end if;
        end loop;
        if cross.hits >= cross.min_hits then
          return "YES";
        else
          return "NO";
        end if;
      end function;

      --TODO: move this function from scoreboard to another package to reuse
      -- add simulation time stamp to scoreboard report header
      impure function timestamp_header(value : time; txt : string) return string is
          variable v_line             : line;
          variable v_delimiter_pos    : natural;
          variable v_timestamp_width  : natural;
          variable v_result           : string(1 to 50);
          variable v_return           : string(1 to txt'length) := txt;
        begin
          -- get a time stamp
          write(v_line, value, LEFT, 0, C_LOG_TIME_BASE);
          v_timestamp_width := v_line'length;
          v_result(1 to v_timestamp_width) := v_line.all;
          deallocate(v_line);
          v_delimiter_pos := pos_of_leftmost('.', v_result(1 to v_timestamp_width), 0);

          -- truncate decimals and add units
          if v_delimiter_pos > 0 then
            if C_LOG_TIME_BASE = ns then
              v_result(v_delimiter_pos+2 to v_delimiter_pos+4) := " ns";
            else
              v_result(v_delimiter_pos+2 to v_delimiter_pos+4) := " ps";
            end if;
            v_timestamp_width := v_delimiter_pos + 4;
          end if;
          -- add a space after the timestamp
          v_timestamp_width := v_timestamp_width + 1;
          v_result(v_timestamp_width to v_timestamp_width) := " ";

          -- add time string to return string
          v_return := v_result(1 to v_timestamp_width) & txt(1 to txt'length-v_timestamp_width);
          return v_return(1 to txt'length);
        end function timestamp_header;

    begin
      -- Calculate how much space we can insert between the columns of the report
      v_log_extra_space := (C_LOG_LINE_WIDTH - C_PREFIX'length - C_BIN_COLUMN_WIDTH - C_COLUMN_WIDTH*4 - C_MAX_BIN_NAME_LENGTH - 20)/6;
      if v_log_extra_space < 1 then
        alert(TB_WARNING, "C_LOG_LINE_WIDTH is too small or C_MAX_BIN_NAME_LENGTH is too big, the report will not be properly aligned.", priv_scope.all);
        v_log_extra_space := 1;
      end if;

      -- Print report header
      write(v_line, LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
                    timestamp_header(now, justify(C_HEADER, LEFT, C_LOG_LINE_WIDTH - C_PREFIX'length, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE)) & LF &
                    fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);

      -- Print column headers
      write(v_line, justify(
        fill_string(' ', 5) &
        justify("BINS"     , center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("HITS"     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("MIN_HITS" , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("WEIGHT"   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("NAME"     , center, C_MAX_BIN_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
        justify("COVERED"  , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
        left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);

      -- Print bins
      for i in 0 to priv_bins_idx-1 loop
        write(v_line, justify(
          fill_string(' ', 5) &
          justify(to_string(priv_bins(i).contains, priv_bins(i).values, priv_bins(i).num_values), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_bins(i).hits)     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_bins(i).min_hits) , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_bins(i).weight)   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_bins(i).name)     , center, C_MAX_BIN_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(is_bin_covered(priv_bins(i))     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
          left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
      end loop;

      -- Print invalid bins
      for i in 0 to priv_invalid_bins_idx-1 loop
        write(v_line, justify(
          fill_string(' ', 5) &
          justify(to_string(priv_invalid_bins(i).contains, priv_invalid_bins(i).values, priv_invalid_bins(i).num_values), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_bins(i).hits)     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_bins(i).min_hits) , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_bins(i).weight)   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_bins(i).name)     , center, C_MAX_BIN_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(is_bin_covered(priv_invalid_bins(i))     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
          left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
      end loop;

      -- Print cross bins
      for i in 0 to priv_cross_idx-1 loop
        write(v_line, justify(
          fill_string(' ', 5) &
          justify(to_string(priv_cross(i).bins(0 to priv_num_bins_crossed-1), use_in_summary => true), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_cross(i).hits)     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_cross(i).min_hits) , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_cross(i).weight)   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_cross(i).name)     , center, C_MAX_BIN_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(is_bin_covered(priv_cross(i))     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
          left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
      end loop;

      -- Print cross invalid bins
      for i in 0 to priv_invalid_cross_idx-1 loop
        write(v_line, justify(
          fill_string(' ', 5) &
          justify(to_string(priv_invalid_cross(i).bins(0 to priv_num_bins_crossed-1), use_in_summary => true), center, C_BIN_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_cross(i).hits)     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_cross(i).min_hits) , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_cross(i).weight)   , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(to_string(priv_invalid_cross(i).name)     , center, C_MAX_BIN_NAME_LENGTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space) &
          justify(is_bin_covered(priv_invalid_cross(i))     , center, C_COLUMN_WIDTH, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE) & fill_string(' ', v_log_extra_space),
          left, C_LOG_LINE_WIDTH - C_PREFIX'length, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE) & LF);
      end loop;

      -- Print report bottom line
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH-C_PREFIX'length);
      prefix_lines(v_line, C_PREFIX);

      -- Write the info string to transcript
      write (v_line_copy, v_line.all);  -- copy line
      writeline(OUTPUT, v_line);
      writeline(LOG_FILE, v_line_copy);
      deallocate(v_line);
      deallocate(v_line_copy);
    end procedure;

  end protected body t_cov_point;

end package body funct_cov_pkg;