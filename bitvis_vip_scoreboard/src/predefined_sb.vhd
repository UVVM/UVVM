--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.generic_sb_pkg;
use work.local_pkg.all;

------------------------------------------------------------------------------------------
-- Package declarations
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--
--  slv_sb_pkg
--
--    Predefined scoreboard package for std_logic_vector. Vector length is defined by
--    the constant C_SB_SLV_WIDTH located under scoreboard adaptions in adaptions_pkg.
--
------------------------------------------------------------------------------------------
package slv_sb_pkg is new work.generic_sb_pkg
  generic map (t_expected_element       => std_logic_vector(C_SB_SLV_WIDTH-1 downto 0),
               t_actual_element         => std_logic_vector(C_SB_SLV_WIDTH-1 downto 0),
               match                    => std_match,
               expected_to_string       => slv_to_string,
               actual_to_string         => slv_to_string);




------------------------------------------------------------------------------------------
--
--  int_sb_pkg
--
--    Predefined scoreboard package for integer.
--
------------------------------------------------------------------------------------------
package int_sb_pkg is new work.generic_sb_pkg
  generic map (t_expected_element       => integer,
               t_actual_element         => integer,
               match                    => "=",
               expected_to_string       => to_string,
               actual_to_string         => to_string);