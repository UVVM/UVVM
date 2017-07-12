--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
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

package uart_pkg is
 
  function find_num_hits(
    vector    : std_logic_vector;
    pattern   : std_logic)
    return integer;

  function find_most_repeated_bit(
    vector    : std_logic_vector)
    return std_logic;
  
  function transient_error(
    vector    : std_logic_vector;
    limit     : integer)
    return boolean;
    
  function f_log2 (x : positive)
    return natural;
    
  function odd_parity (
    signal data : std_logic_vector(7 downto 0))
    return std_logic;
  
end package uart_pkg;

package body uart_pkg is

  function find_num_hits(
    vector    : std_logic_vector;
    pattern   : std_logic)
    return integer is
    variable hitcount : natural := 0;
  begin
    for i in 0 to vector'length-1 loop
      if (vector(i) = pattern) then
        hitcount := hitcount+1;
      end if;
    end loop;
    return hitcount;
  end function;

  function find_most_repeated_bit(
    vector    : std_logic_vector)
    return std_logic is
  begin
    if (find_num_hits(vector,'1') >
        find_num_hits(vector,'0')) then
      return '1';
    else
      return '0';
    end if;
  end function;
  
  function transient_error(
    vector    : std_logic_vector;
    limit     : integer)
    return boolean is
  begin
    if ((find_num_hits(vector,'1') < limit) and
        (find_num_hits(vector,'0') < limit)) then
      return true;
    else
      return false;
    end if;
  end function;
  
  function f_log2 (x : positive)
     return natural is
     variable i : natural;
   begin
      i := 0;  
      while (2**i < x) and i < 31 loop
         i := i + 1;
      end loop;
      return i;
   end function;
   
  function odd_parity (
    signal data : std_logic_vector(7 downto 0))
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

