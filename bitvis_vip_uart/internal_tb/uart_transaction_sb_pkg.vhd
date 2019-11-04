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

use work.transaction_pkg.all;
use work.vvc_cmd_pkg.all;


package local_pkg is
  function uart_transaction_to_string(
    constant value : in t_transaction
  ) return string;

  function uart_transaction_match(
    constant value    : in t_transaction;
    constant expected : in t_transaction
  ) return boolean;
end package local_pkg;

package body local_pkg is
  function uart_transaction_to_string(
    constant value : in t_transaction
  ) return string is
  begin
    return "operation: "           & to_string(value.operation) &
           "; data: "              & to_string(value.data, HEX, KEEP_LEADING_0, INCL_RADIX) &
           "; parity_bit_error: "  & to_string(value.error_info.parity_bit_error) &
           "; stop_bit_error: "    & to_string(value.error_info.stop_bit_error);
  end function uart_transaction_to_string;

  function uart_transaction_match(
    constant value    : in t_transaction;
    constant expected : in t_transaction
  ) return boolean is
  begin
    return (value.operation                   = expected.operation)                   and
           (value.data                        = expected.data)                        and
           (value.error_info.parity_bit_error = expected.error_info.parity_bit_error) and
           (value.error_info.stop_bit_error   = expected.error_info.stop_bit_error);
  end function uart_transaction_match;
end package body local_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;
use bitvis_vip_scoreboard.generic_sb_pkg;

use work.local_pkg.all;
use work.transaction_pkg.all;

------------------------------------------------------------------------------------------
-- Package declaration
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--
--  uart_transaction_sb_pkg
--
--    Scoreboard package for uart_transaction_info.
--
------------------------------------------------------------------------------------------
package uart_transaction_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
  generic map (t_expected_element => t_transaction,
               t_actual_element   => t_transaction,
               match              => uart_transaction_match,
               expected_to_string => uart_transaction_to_string,
               actual_to_string   => uart_transaction_to_string);