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
    vector : std_logic_vector;
    limit  : integer)
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
    variable hitcount : natural := 0;
  begin
    for i in 0 to vector'length - 1 loop
      if (vector(i) = pattern) then
        hitcount := hitcount + 1;
      end if;
    end loop;
    return hitcount;
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
    vector : std_logic_vector;
    limit  : integer)
  return boolean is
  begin
    if ((find_num_hits(vector, '1') < limit) and (find_num_hits(vector, '0') < limit)) then
      return true;
    else
      return false;
    end if;
  end function;

  function f_log2(x : positive)
  return natural is
    variable i : natural;
  begin
    i := 0;
    while (2 ** i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  function odd_parity(
    signal data : std_logic_vector)
  return std_logic is
    variable odd : std_logic;
  begin
    odd := '1';
    for i in data'range loop
      odd := odd xor data(i);
    end loop;
    return odd;
  end odd_parity;

end package body uart_pkg;

