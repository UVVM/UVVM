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

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.vvc_cmd_pkg.all;

package local_pkg is
  function vvc_result_to_string(
    constant value : in t_vvc_result
  ) return string;
end package local_pkg;

package body local_pkg is
  function vvc_result_to_string(
    constant value : in t_vvc_result
  ) return string is
    variable length : natural := 0;
  begin
    for i in 0 to value'high loop
      if value(i) = '-' then
        return to_string(value(length-1 downto 0), HEX, KEEP_LEADING_0, INCL_RADIX);
      end if;
    end loop;
    return to_string(value, HEX, KEEP_LEADING_0, INCL_RADIX);
  end function;
end package body local_pkg;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_pkg;

use work.vvc_cmd_pkg.all;
use work.local_pkg.all;

--========================================================================================================================
--========================================================================================================================

package sbi_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
  generic map (t_expected_element       => t_vvc_result,
               t_actual_element         => t_vvc_result,
               match                    => std_match,
               expected_to_string       => vvc_result_to_string,
               actual_to_string         => vvc_result_to_string);