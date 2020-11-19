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
-- Description   : Helper functions and procedures for rand_tb
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package rand_tb_pkg is

  type t_integer_cnt  is array (integer range <>) of integer;

  ------------------------------------------------------------
  -- Check within range
  ------------------------------------------------------------
  -- Base function (integer)
  function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer)
  return boolean;

  -- Base function (real)
  function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real)
  return boolean;

  -- Base function (time)
  function check_rand_value(
    constant value       : time;
    constant min_range   : time;
    constant max_range   : time)
  return boolean;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant min_range   : in integer;
    constant max_range   : in integer);

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant min_range   : in real;
    constant max_range   : in real);

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant min_range   : in time;
    constant max_range   : in time);

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant min_range   : in integer;
    constant max_range   : in integer);

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant min_range   : in real;
    constant max_range   : in real);

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant min_range   : in time;
    constant max_range   : in time);

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant min_range   : in natural;
    constant max_range   : in natural);

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant min_range   : in integer;
    constant max_range   : in integer);

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant min_range   : in natural;
    constant max_range   : in natural);

  ------------------------------------------------------------
  -- Check within set of values
  ------------------------------------------------------------
  -- Base function (integer)
  function check_rand_value(
    constant value       : integer;
    constant set_values  : integer_vector)
  return boolean;

  -- Base function (real)
  function check_rand_value(
    constant value       : real;
    constant set_values  : real_vector)
  return boolean;

  -- Base function (time)
  function check_rand_value(
    constant value       : time;
    constant set_values  : time_vector)
  return boolean;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant set_values  : in integer_vector);

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant set_values  : in real_vector);

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant set_values  : in time_vector);

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant set_values  : in integer_vector);

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant set_values  : in real_vector);

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant set_values  : in time_vector);

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant set_values  : in t_natural_vector);

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant set_values  : in integer_vector);

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant set_values  : in t_natural_vector);

  ------------------------------------------------------------
  -- Check within range and set of values
  ------------------------------------------------------------
  -- Base function (integer)
  function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer;
    constant set_type    : t_set_type;
    constant set_values  : integer_vector)
  return boolean;

  -- Base function (real)
  function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real;
    constant set_type    : t_set_type;
    constant set_values  : real_vector)
  return boolean;

  -- Base function (time)
  function check_rand_value(
    constant value       : time;
    constant min_range   : time;
    constant max_range   : time;
    constant set_type    : t_set_type;
    constant set_values  : time_vector)
  return boolean;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type    : in t_set_type;
    constant set_values  : in integer_vector);

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type    : in t_set_type;
    constant set_values  : in real_vector);

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type    : in t_set_type;
    constant set_values  : in time_vector);

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type    : in t_set_type;
    constant set_values  : in integer_vector);

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type    : in t_set_type;
    constant set_values  : in real_vector);

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type    : in t_set_type;
    constant set_values  : in time_vector);

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type    : in t_set_type;
    constant set_values  : in t_natural_vector);

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type    : in t_set_type;
    constant set_values  : in integer_vector);

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type    : in t_set_type;
    constant set_values  : in t_natural_vector);

  ------------------------------------------------------------
  -- Check within range and sets of values
  ------------------------------------------------------------
  -- Base function (integer)
  impure function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer;
    constant set_type1   : t_set_type;
    constant set_values1 : integer_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : integer_vector)
  return boolean;

  -- Base function (real)
  impure function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real;
    constant set_type1   : t_set_type;
    constant set_values1 : real_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : real_vector)
  return boolean;

  -- Base function (time)
  impure function check_rand_value(
    constant value       : time;
    constant min_range   : time;
    constant max_range   : time;
    constant set_type1   : t_set_type;
    constant set_values1 : time_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : time_vector)
  return boolean;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type1   : in t_set_type;
    constant set_values1 : in integer_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in integer_vector);

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type1   : in t_set_type;
    constant set_values1 : in real_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in real_vector);

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type1   : in t_set_type;
    constant set_values1 : in time_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in time_vector);

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type1   : in t_set_type;
    constant set_values1 : in integer_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in integer_vector);

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type1   : in t_set_type;
    constant set_values1 : in real_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in real_vector);

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type1   : in t_set_type;
    constant set_values1 : in time_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in time_vector);

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type1   : in t_set_type;
    constant set_values1 : in t_natural_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in t_natural_vector);

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type1   : in t_set_type;
    constant set_values1 : in integer_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in integer_vector);

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type1   : in t_set_type;
    constant set_values1 : in t_natural_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in t_natural_vector);

  -- Prints an array of values with their corresponding weight count and weight percentage.
  -- Checks that the weight count is within margins of the expected count. And resets the weight counts.
  procedure print_and_check_weights(
    variable weight_cnt  : inout t_integer_cnt;
    constant weight_dist : in    integer_vector);

end package rand_tb_pkg;

package body rand_tb_pkg is

  ------------------------------------------------------------
  -- Check within range
  ------------------------------------------------------------
  -- Base function (integer)
  function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer)
  return boolean is
  begin
    if value >= min_range and value <= max_range then
      return true;
    else
      return false;
    end if;
  end function;

  -- Base function (real)
  function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real)
  return boolean is
  begin
    if value >= min_range and value <= max_range then
      return true;
    else
      return false;
    end if;
  end function;

  -- Base function (time)
  function check_rand_value(
    constant value       : time;
    constant min_range   : time;
    constant max_range   : time)
  return boolean is
  begin
    if value >= min_range and value <= max_range then
      return true;
    else
      return false;
    end if;
  end function;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant min_range   : in integer;
    constant max_range   : in integer) is
  begin
    if check_rand_value(value, min_range, max_range) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant min_range   : in real;
    constant max_range   : in real) is
  begin
    if check_rand_value(value, min_range, max_range) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant min_range   : in time;
    constant max_range   : in time) is
  begin
    if check_rand_value(value, min_range, max_range) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant min_range   : in integer;
    constant max_range   : in integer) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant min_range   : in real;
    constant max_range   : in real) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant min_range   : in time;
    constant max_range   : in time) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant min_range   : in natural;
    constant max_range   : in natural) is
  begin
    if check_rand_value(to_integer(value), min_range, max_range) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant min_range   : in integer;
    constant max_range   : in integer) is
  begin
    if check_rand_value(to_integer(value), min_range, max_range) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, DEC) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, DEC) & ".");
    end if;
  end procedure;

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant min_range   : in natural;
    constant max_range   : in natural) is
  begin
    if check_rand_value(to_integer(unsigned(value)), min_range, max_range) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  ------------------------------------------------------------
  -- Check within set of values
  ------------------------------------------------------------
  -- Base function (integer)
  function check_rand_value(
    constant value       : integer;
    constant set_values  : integer_vector)
  return boolean is
  begin
    for i in set_values'range loop
      if value = set_values(i) then
        return true;
      end if;
    end loop;
    return false;
  end function;

  -- Base function (real)
  function check_rand_value(
    constant value       : real;
    constant set_values  : real_vector)
  return boolean is
  begin
    for i in set_values'range loop
      if value = set_values(i) then
        return true;
      end if;
    end loop;
    return false;
  end function;

  -- Base function (time)
  function check_rand_value(
    constant value       : time;
    constant set_values  : time_vector)
  return boolean is
  begin
    for i in set_values'range loop
      if value = set_values(i) then
        return true;
      end if;
    end loop;
    return false;
  end function;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant set_values  : in integer_vector) is
  begin
    if check_rand_value(value, set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant set_values  : in real_vector) is
  begin
    if check_rand_value(value, set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant set_values  : in time_vector) is
  begin
    if check_rand_value(value, set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant set_values  : in integer_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), set_values);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant set_values  : in real_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), set_values);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant set_values  : in time_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), set_values);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant set_values  : in t_natural_vector) is
  begin
    if check_rand_value(to_integer(value), integer_vector(set_values)) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant set_values  : in integer_vector) is
  begin
    if check_rand_value(to_integer(value), set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, DEC) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, DEC) & ".");
    end if;
  end procedure;

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant set_values  : in t_natural_vector) is
  begin
    if check_rand_value(to_integer(unsigned(value)), integer_vector(set_values)) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  ------------------------------------------------------------
  -- Check within range and set of values
  ------------------------------------------------------------
  -- Base function (integer)
  function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer;
    constant set_type    : t_set_type;
    constant set_values  : integer_vector)
  return boolean is
  begin
    -- Check in range plus a set of values
    if set_type = INCL then
      if check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values) then
        return true;
      end if;
    -- Check in range except a set of values
    elsif set_type = EXCL then
      if check_rand_value(value, min_range, max_range) and not(check_rand_value(value, set_values)) then
        return true;
      end if;
    end if;
    return false;
  end function;

  -- Base function (real)
  function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real;
    constant set_type    : t_set_type;
    constant set_values  : real_vector)
  return boolean is
  begin
    -- Check in range plus a set of values
    if set_type = INCL then
      if check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values) then
        return true;
      end if;
    -- Check in range except a set of values
    elsif set_type = EXCL then
      if check_rand_value(value, min_range, max_range) and not(check_rand_value(value, set_values)) then
        return true;
      end if;
    end if;
    return false;
  end function;

  -- Base function (time)
  function check_rand_value(
    constant value       : time;
    constant min_range   : time;
    constant max_range   : time;
    constant set_type    : t_set_type;
    constant set_values  : time_vector)
  return boolean is
  begin
    -- Check in range plus a set of values
    if set_type = INCL then
      if check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values) then
        return true;
      end if;
    -- Check in range except a set of values
    elsif set_type = EXCL then
      if check_rand_value(value, min_range, max_range) and not(check_rand_value(value, set_values)) then
        return true;
      end if;
    end if;
    return false;
  end function;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type    : in t_set_type;
    constant set_values  : in integer_vector) is
  begin
    if check_rand_value(value, min_range, max_range, set_type, set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type    : in t_set_type;
    constant set_values  : in real_vector) is
  begin
    if check_rand_value(value, min_range, max_range, set_type, set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type    : in t_set_type;
    constant set_values  : in time_vector) is
  begin
    if check_rand_value(value, min_range, max_range, set_type, set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type    : in t_set_type;
    constant set_values  : in integer_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range, set_type, set_values);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type    : in t_set_type;
    constant set_values  : in real_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range, set_type, set_values);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type    : in t_set_type;
    constant set_values  : in time_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range, set_type, set_values);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type    : in t_set_type;
    constant set_values  : in t_natural_vector) is
  begin
    if check_rand_value(to_integer(value), min_range, max_range, set_type, integer_vector(set_values)) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type    : in t_set_type;
    constant set_values  : in integer_vector) is
  begin
    if check_rand_value(to_integer(value), min_range, max_range, set_type, set_values) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, DEC) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, DEC) & ".");
    end if;
  end procedure;

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type    : in t_set_type;
    constant set_values  : in t_natural_vector) is
  begin
    if check_rand_value(to_integer(unsigned(value)), min_range, max_range, set_type, integer_vector(set_values)) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  ------------------------------------------------------------
  -- Check within range and sets of values
  ------------------------------------------------------------
  -- Base function (integer)
  impure function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer;
    constant set_type1   : t_set_type;
    constant set_values1 : integer_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : integer_vector)
  return boolean is
    constant C_PROC_NAME : string := "check_rand_value";
  begin
    check_value(set_type1 /= set_type2, TB_ERROR, "Set types must be different", C_SCOPE, ID_NEVER, shared_msg_id_panel, C_PROC_NAME);
    if set_type1 = INCL then
      if (check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values1)) and not(check_rand_value(value, set_values2)) then
        return true;
      end if;
    elsif set_type1 = EXCL then
      if (check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values2)) and not(check_rand_value(value, set_values1)) then
        return true;
      end if;
    end if;
    return false;
  end function;

  -- Base function (real)
  impure function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real;
    constant set_type1   : t_set_type;
    constant set_values1 : real_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : real_vector)
  return boolean is
    constant C_PROC_NAME : string := "check_rand_value";
  begin
    check_value(set_type1 /= set_type2, TB_ERROR, "Set types must be different", C_SCOPE, ID_NEVER, shared_msg_id_panel, C_PROC_NAME);
    if set_type1 = INCL then
      if (check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values1)) and not(check_rand_value(value, set_values2)) then
        return true;
      end if;
    elsif set_type1 = EXCL then
      if (check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values2)) and not(check_rand_value(value, set_values1)) then
        return true;
      end if;
    end if;
    return false;
  end function;

  -- Base function (time)
  impure function check_rand_value(
    constant value       : time;
    constant min_range   : time;
    constant max_range   : time;
    constant set_type1   : t_set_type;
    constant set_values1 : time_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : time_vector)
  return boolean is
    constant C_PROC_NAME : string := "check_rand_value";
  begin
    check_value(set_type1 /= set_type2, TB_ERROR, "Set types must be different", C_SCOPE, ID_NEVER, shared_msg_id_panel, C_PROC_NAME);
    if set_type1 = INCL then
      if (check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values1)) and not(check_rand_value(value, set_values2)) then
        return true;
      end if;
    elsif set_type1 = EXCL then
      if (check_rand_value(value, min_range, max_range) or check_rand_value(value, set_values2)) and not(check_rand_value(value, set_values1)) then
        return true;
      end if;
    end if;
    return false;
  end function;

  -- Overload (integer)
  procedure check_rand_value(
    constant value       : in integer;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type1   : in t_set_type;
    constant set_values1 : in integer_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in integer_vector) is
  begin
    if check_rand_value(value, min_range, max_range, set_type1, set_values1, set_type2, set_values2) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (real)
  procedure check_rand_value(
    constant value       : in real;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type1   : in t_set_type;
    constant set_values1 : in real_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in real_vector) is
  begin
    if check_rand_value(value, min_range, max_range, set_type1, set_values1, set_type2, set_values2) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (time)
  procedure check_rand_value(
    constant value       : in time;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type1   : in t_set_type;
    constant set_values1 : in time_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in time_vector) is
  begin
    if check_rand_value(value, min_range, max_range, set_type1, set_values1, set_type2, set_values2) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value) & ".");
    end if;
  end procedure;

  -- Overload (integer_vector)
  procedure check_rand_value(
    constant value_vec   : in integer_vector;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type1   : in t_set_type;
    constant set_values1 : in integer_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in integer_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range, set_type1, set_values1, set_type2, set_values2);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (real_vector)
  procedure check_rand_value(
    constant value_vec   : in real_vector;
    constant min_range   : in real;
    constant max_range   : in real;
    constant set_type1   : in t_set_type;
    constant set_values1 : in real_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in real_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range, set_type1, set_values1, set_type2, set_values2);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (time_vector)
  procedure check_rand_value(
    constant value_vec   : in time_vector;
    constant min_range   : in time;
    constant max_range   : in time;
    constant set_type1   : in t_set_type;
    constant set_values1 : in time_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in time_vector) is
    variable v_check_ok  : boolean := true;
  begin
    for i in value_vec'range loop
      v_check_ok := v_check_ok and check_rand_value(value_vec(i), min_range, max_range, set_type1, set_values1, set_type2, set_values2);
    end loop;
    if v_check_ok then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value_vec) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value_vec) & ".");
    end if;
  end procedure;

  -- Overload (unsigned)
  procedure check_rand_value(
    constant value       : in unsigned;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type1   : in t_set_type;
    constant set_values1 : in t_natural_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in t_natural_vector) is
  begin
    if check_rand_value(to_integer(value), min_range, max_range, set_type1, integer_vector(set_values1), set_type2, integer_vector(set_values2)) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  -- Overload (signed)
  procedure check_rand_value(
    constant value       : in signed;
    constant min_range   : in integer;
    constant max_range   : in integer;
    constant set_type1   : in t_set_type;
    constant set_values1 : in integer_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in integer_vector) is
  begin
    if check_rand_value(to_integer(value), min_range, max_range, set_type1, set_values1, set_type2, set_values2) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, DEC) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, DEC) & ".");
    end if;
  end procedure;

  -- Overload (std_logic_vector)
  procedure check_rand_value(
    constant value       : in std_logic_vector;
    constant min_range   : in natural;
    constant max_range   : in natural;
    constant set_type1   : in t_set_type;
    constant set_values1 : in t_natural_vector;
    constant set_type2   : in t_set_type;
    constant set_values2 : in t_natural_vector) is
  begin
    if check_rand_value(to_integer(unsigned(value)), min_range, max_range, set_type1, integer_vector(set_values1), set_type2, integer_vector(set_values2)) then
      log(ID_POS_ACK, "check_rand_value => OK, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    else
      alert(ERROR, "check_rand_value => Failed, for " & to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX) & ".");
    end if;
  end procedure;

  -- Prints an array of values with their corresponding weight count and weight percentage.
  -- Checks that the weight count is within margins of the expected count. And resets the weight counts.
  procedure print_and_check_weights(
    variable weight_cnt  : inout t_integer_cnt;
    constant weight_dist : in    integer_vector) is
    constant C_PROC_NAME      : string := "print_and_check_weights";
    constant C_PREFIX         : string := C_LOG_PREFIX & fill_string(' ', C_LOG_MSG_ID_WIDTH+C_LOG_TIME_WIDTH+C_LOG_SCOPE_WIDTH+4);
    constant C_COL_WIDTH      : natural := 7;
    constant C_NUM_WEIGHTS    : natural := weight_dist'length;
    constant C_MARGIN         : natural := 30; -- Considering there's a total of 1000 samples (C_NUM_DIST_REPETITIONS).
    variable v_line           : line;
    variable v_line_copy      : line;
    variable v_tot_weight     : natural := 0;
    variable v_weight_cnt_vld : integer_vector(0 to C_NUM_WEIGHTS-1);
    variable v_idx            : natural := 0;
    variable v_val_size       : natural := 0;
    variable v_percentage     : natural := 0;
  begin
    -- Calculate the total weight
    for i in weight_dist'range loop
      v_tot_weight := v_tot_weight + weight_dist(i);
    end loop;

    -- Copy the valid weight counts (greater than 0) to a new vector
    for i in weight_cnt'range loop
      if weight_cnt(i) > 0 then
        v_weight_cnt_vld(v_idx) := weight_cnt(i);
        v_idx := v_idx + 1;
      end if;
    end loop;
    check_value(v_idx = C_NUM_WEIGHTS, TB_ERROR, "Length of weight_dist (" & to_string(C_NUM_WEIGHTS) & ") doesn't match expected number of valid weight_cnt (" &
      to_string(v_idx) & ").", C_SCOPE, ID_NEVER, shared_msg_id_panel, C_PROC_NAME);

    -- Print upper line
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
    -- Print info
    for row in 0 to 2 loop
      case row is
        when 0 =>
          write(v_line, string'("value: "));
          for i in weight_cnt'range loop
            if weight_cnt(i) > 0 then
              v_val_size := integer'image(i)'length;
              write(v_line, fill_string(' ', (C_COL_WIDTH - v_val_size)) & to_string(i));
            end if;
          end loop;
        when 1 =>
          write(v_line, string'("weight:"));
          for i in weight_dist'range loop
            v_percentage := weight_dist(i)*100/v_tot_weight;
            v_val_size := integer'image(v_percentage)'length + 1;
            write(v_line, fill_string(' ', (C_COL_WIDTH - v_val_size)) & to_string(v_percentage) & "%");
          end loop;
        when 2 =>
          write(v_line, string'("hits:  "));
          for i in v_weight_cnt_vld'range loop
            v_val_size := integer'image(v_weight_cnt_vld(i))'length;
            write(v_line, fill_string(' ', (C_COL_WIDTH - v_val_size)) & to_string(v_weight_cnt_vld(i)));
          end loop;
      end case;
      write(v_line, LF);
    end loop;
    -- Print bottom line
    write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)));

    wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH-C_PREFIX'length);
    prefix_lines(v_line, C_PREFIX);

    -- Write the info string to transcript
    write (v_line_copy, v_line.all);  -- copy line
    writeline(OUTPUT, v_line);
    writeline(LOG_FILE, v_line_copy);
    deallocate(v_line);
    deallocate(v_line_copy);

    -- Check the weight counts are within margin
    for i in v_weight_cnt_vld'range loop
      v_percentage := (weight_dist(i)*100/v_tot_weight)*10; -- Multiply by 10 since there are 1000 samples
      check_value_in_range(v_weight_cnt_vld(i), v_percentage-C_MARGIN, v_percentage+C_MARGIN, TB_WARNING, "Number of hits is outside expected margin.",
        C_SCOPE, ID_NEVER, shared_msg_id_panel, C_PROC_NAME);
    end loop;

    -- Reset weight counts
    for i in weight_cnt'range loop
      weight_cnt(i) := 0;
    end loop;
  end procedure;

end package body rand_tb_pkg;