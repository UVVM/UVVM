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
-- Inspired by similar functionality in SystemVerilog/UVM and OSVVM.
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Local package
------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package local_pkg is
  function slv_to_string(
    constant value : in std_logic_vector
  ) return string;
end package local_pkg;

package body local_pkg is
  function slv_to_string(
    constant value : in std_logic_vector
  ) return string is
  begin
    return to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX);
  end function;
end package body local_pkg;

------------------------------------------------------------------------------------------
--
--  slv_sb_pkg
--
--    Predefined scoreboard package for std_logic_vector. Vector length is defined by
--    the constant C_SB_SLV_WIDTH located under scoreboard adaptions in adaptions_pkg.
--
------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.local_pkg.all;

-- WARNING! The slv_sb_pkg will be deprecated 
package slv_sb_pkg is new work.generic_sb_pkg
  generic map(t_element         => std_logic_vector(C_SB_SLV_WIDTH - 1 downto 0),
              element_match     => std_match,
              to_string_element => slv_to_string);

------------------------------------------------------------------------------------------
--
--  slv8_sb_pkg
--
--    Predefined scoreboard package for std_logic_vector(7 downto 0).
--
------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.local_pkg.all;

package slv8_sb_pkg is new work.generic_sb_pkg
  generic map(t_element         => std_logic_vector(7 downto 0),
              element_match     => std_match,
              to_string_element => slv_to_string);

------------------------------------------------------------------------------------------
--
--  int_sb_pkg
--
--    Predefined scoreboard package for integer.
--
------------------------------------------------------------------------------------------
package int_sb_pkg is new work.generic_sb_pkg
  generic map(t_element         => integer,
              element_match     => "=",
              to_string_element => to_string);
