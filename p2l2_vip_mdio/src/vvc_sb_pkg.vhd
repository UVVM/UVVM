--================================================================================================================================
-- Copyright 2026 UVVM
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
-- Built-in scoreboard of the MDIO VVC
-- - One shared scoreboard (mdio_vvc_sb, declared in vvc_methods_pkg), one instance per VVC
--   instance (GC_INSTANCE_IDX).
-- - STA reads and PHY receives called with data_routing = TO_SB send the read / received
--   value to check_received() instead of the result queue. The sequencer adds the expected data with add_expected().
--==========================================================================================

--==========================================================================================
--  vvc_sb_pkg
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_vip_scoreboard;

use work.transaction_pkg.all;

package vvc_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
  generic map(
    t_element         => std_logic_vector(C_VVC_CMD_DATA_LENGTH - 1 downto 0),
    element_match     => std_match,
    to_string_element => to_string);

--==========================================================================================
--  vvc_sb_support_pkg
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

use work.transaction_pkg.all;

package vvc_sb_support_pkg is

  -- The data parameter of the scoreboard procedures must have the same length as t_element of
  -- the VVC's built-in scoreboard (16 bit). This function zero-extends narrower data, so the
  -- testbench does not need to know that length, e.g. mdio_vvc_sb.add_expected(1, pad_mdio_sb(x"AB")).
  function pad_mdio_sb(
    constant data : in std_logic_vector
  ) return std_logic_vector;

end package vvc_sb_support_pkg;

package body vvc_sb_support_pkg is

  function pad_mdio_sb(
    constant data : in std_logic_vector
  ) return std_logic_vector is
  begin
    return pad_sb_slv(data, C_VVC_CMD_DATA_LENGTH);
  end function pad_mdio_sb;

end package body vvc_sb_support_pkg;
