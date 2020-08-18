library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

package spi_common_pkg is
  function f_log2 (x : positive) return natural;
end package spi_common_pkg;

package body spi_common_pkg is
  function f_log2 (x : positive) return natural is
      variable i : natural;
   begin
      i := 0;  
      while (2**i < x) and i < 31 loop
         i := i + 1;
      end loop;
      return i;
   end function;
end package body spi_common_pkg;