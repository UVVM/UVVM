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
    constant value : in t_base_transaction
  ) return string;

  function uart_transaction_match(
    constant value    : in t_base_transaction;
    constant expected : in t_base_transaction
  ) return boolean;
end package local_pkg;

package body local_pkg is
  function uart_transaction_to_string(
    constant value : in t_base_transaction
  ) return string is
  begin
    return "operation: " & to_string(value.operation) & "; data: " & to_string(value.data, HEX, KEEP_LEADING_0, INCL_RADIX) & "; parity_bit_error: " & to_string(value.error_info.parity_bit_error) & "; stop_bit_error: " & to_string(value.error_info.stop_bit_error);
  end function uart_transaction_to_string;

  function uart_transaction_match(
    constant value    : in t_base_transaction;
    constant expected : in t_base_transaction
  ) return boolean is
  begin
    return (value.operation = expected.operation) and (value.data = expected.data) and (value.error_info.parity_bit_error = expected.error_info.parity_bit_error) and (value.error_info.stop_bit_error = expected.error_info.stop_bit_error);
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
  generic map(t_element         => t_base_transaction,
              element_match     => uart_transaction_match,
              to_string_element => uart_transaction_to_string);
