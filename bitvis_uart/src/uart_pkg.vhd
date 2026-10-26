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

package uart_pkg is

  function find_num_hits(
    vector  : std_logic_vector;
    pattern : std_logic)
  return integer;

  function find_most_repeated_bit(
    vector : std_logic_vector)
  return std_logic;

  function transient_error(
    vector    : std_logic_vector;
    err_limit : integer)
  return boolean;

  function f_log2(x : positive)
  return natural;

  function odd_parity(
    signal data : std_logic_vector)
  return std_logic;

end package uart_pkg;

package body uart_pkg is

  function find_num_hits(
    vector  : std_logic_vector;
    pattern : std_logic)
  return integer is
    variable v_hitcount : natural := 0;
  begin
    for i in 0 to vector'length - 1 loop
      if (vector(i) = pattern) then
        v_hitcount := v_hitcount + 1;
      end if;
    end loop;
    return v_hitcount;
  end function;

  function find_most_repeated_bit(
    vector : std_logic_vector)
  return std_logic is
  begin
    if (find_num_hits(vector, '1') > find_num_hits(vector, '0')) then
      return '1';
    else
      return '0';
    end if;
  end function;

  function transient_error(
    vector    : std_logic_vector;
    err_limit : integer)
  return boolean is
  begin
    if ((find_num_hits(vector, '1') < err_limit) and (find_num_hits(vector, '0') < err_limit)) then
      return true;
    else
      return false;
    end if;
  end function;

  function f_log2(x : positive)
  return natural is
    variable v_i : natural;
  begin
    v_i := 0;
    while (2 ** v_i < x) and v_i < 31 loop
      v_i := v_i + 1;
    end loop;
    return v_i;
  end function;

  function odd_parity(
    signal data : std_logic_vector)
  return std_logic is
    variable v_odd : std_logic;
  begin
    v_odd := '1';
    for i in data'range loop
      v_odd := v_odd xor data(i);
    end loop;
    return v_odd;
  end function odd_parity;

end package body uart_pkg;

