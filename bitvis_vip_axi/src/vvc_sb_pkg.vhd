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

--==========================================================================================
-- Local package
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.axi_bfm_pkg.all;
use work.vvc_cmd_pkg.all;

package local_pkg is
  function result_to_string(
    constant value : in t_vvc_result
  ) return string;
end package local_pkg;

package body local_pkg is
  function result_to_string(
    constant value : in t_vvc_result
  ) return string is
    variable v_line          : line;
    variable v_return_string : string(1 to 1000);
    variable v_string_length : integer;
  begin
    -- Limiting output to the first four elements in the result queue
    write(v_line, LF & "RID: " & to_string(value.rid, HEX, SKIP_LEADING_0, INCL_RADIX));
    for i in 0 to minimum(value.len, 3) loop
      write(v_line, LF &
        "RDATA(" & to_string(i) & "): " & to_string(value.rdata(i), HEX, SKIP_LEADING_0, INCL_RADIX) &
        ", RRESP(" & to_string(i) & "): " & t_xresp'image(value.rresp(i)) &
        ", RUSER(" & to_string(i) & "): " & to_string(value.ruser(i), HEX, SKIP_LEADING_0, INCL_RADIX));
    end loop;
    write(v_line, LF);
    if value.len > 3 then
      write(v_line, LF & "Truncated remaining result..");
    end if;
    v_string_length                       := v_line.all'length;
    v_return_string(1 to v_string_length) := v_line.all;
    deallocate(v_line);
    return v_return_string(1 to v_string_length);
  end function;
end package body local_pkg;

--==========================================================================================
--  vvc_sb_pkg
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_vip_scoreboard;

use work.vvc_cmd_pkg.all;
use work.local_pkg.all;

package vvc_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
  generic map(t_element         => t_vvc_result,
              element_match     => "=",
              to_string_element => result_to_string);
