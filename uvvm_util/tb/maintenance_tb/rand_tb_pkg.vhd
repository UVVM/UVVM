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

library uvvm_util;
context uvvm_util.uvvm_util_context;

package rand_tb_pkg is

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
  function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer;
    constant set_type1   : t_set_type;
    constant set_values1 : integer_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : integer_vector)
  return boolean;

  -- Base function (real)
  function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real;
    constant set_type1   : t_set_type;
    constant set_values1 : real_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : real_vector)
  return boolean;

  -- Base function (time)
  function check_rand_value(
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
  function check_rand_value(
    constant value       : integer;
    constant min_range   : integer;
    constant max_range   : integer;
    constant set_type1   : t_set_type;
    constant set_values1 : integer_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : integer_vector)
  return boolean is
  begin
    check_value(set_type1 /= set_type2, TB_ERROR, "Set types must be different", C_SCOPE, ID_NEVER);
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
  function check_rand_value(
    constant value       : real;
    constant min_range   : real;
    constant max_range   : real;
    constant set_type1   : t_set_type;
    constant set_values1 : real_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : real_vector)
  return boolean is
  begin
    check_value(set_type1 /= set_type2, TB_ERROR, "Set types must be different", C_SCOPE, ID_NEVER);
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
  function check_rand_value(
    constant value       : time;
    constant min_range   : time;
    constant max_range   : time;
    constant set_type1   : t_set_type;
    constant set_values1 : time_vector;
    constant set_type2   : t_set_type;
    constant set_values2 : time_vector)
  return boolean is
  begin
    check_value(set_type1 /= set_type2, TB_ERROR, "Set types must be different", C_SCOPE, ID_NEVER);
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

end package body rand_tb_pkg;