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
--  vvc_sb_pkg
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_vip_scoreboard;

use work.transaction_pkg.all;

library bitvis_vip_avalon_mm;
use bitvis_vip_avalon_mm.vvc_cmd_pkg;

package vvc_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg
  generic map(
    t_element         => vvc_cmd_pkg.t_vvc_result,
    element_match     => vvc_cmd_pkg.vvc_result_match,
    to_string_element => vvc_cmd_pkg.to_string);

--==========================================================================================
--  vvc_sb_support_pkg
--==========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

library bitvis_vip_avalon_mm;
use bitvis_vip_avalon_mm.vvc_cmd_pkg.t_vvc_result;

use work.transaction_pkg.all;

package vvc_sb_support_pkg is
  -- The data parameter used in the scoreboard procedures needs to have the same length/type as
  -- the t_element defined in the VVC's built-in scoreboard, since even though it is a generic
  -- type, it constrained during elaboration time.
  -- This function is used to pad the data without having to know the exact length of t_element.
  function pad_avalon_mm_addr_sb(
    constant addr : in std_logic_vector
  ) return t_vvc_result;

  function pad_avalon_mm_data_sb(
    constant data : in std_logic_vector
  ) return t_vvc_result;

  function pad_avalon_mm_addr_and_data_sb(
    constant addr : in std_logic_vector;
    constant data : in std_logic_vector
  ) return t_vvc_result;

end package vvc_sb_support_pkg;

package body vvc_sb_support_pkg is

  function pad_avalon_mm_addr_sb(
    constant addr : in std_logic_vector
  ) return t_vvc_result is
    variable v_result : t_vvc_result := (others => (others => '0'));
  begin
    v_result.addr := pad_sb_slv(addr, C_VVC_CMD_ADDR_MAX_LENGTH);
    return v_result;
  end function pad_avalon_mm_addr_sb;

  function pad_avalon_mm_data_sb(
    constant data : in std_logic_vector
  ) return t_vvc_result is
    variable v_result : t_vvc_result := (others => (others => '0'));
  begin
    v_result.data := pad_sb_slv(data, C_VVC_CMD_DATA_MAX_LENGTH);
    return v_result;
  end function pad_avalon_mm_data_sb;

  function pad_avalon_mm_addr_and_data_sb(
    constant addr : in std_logic_vector;
    constant data : in std_logic_vector
  ) return t_vvc_result is
    variable v_result : t_vvc_result := (others => (others => '0'));
  begin
    v_result.addr := pad_sb_slv(addr, C_VVC_CMD_ADDR_MAX_LENGTH);
    v_result.data := pad_sb_slv(data, C_VVC_CMD_DATA_MAX_LENGTH);
    return v_result;
  end function pad_avalon_mm_addr_and_data_sb;

end package body vvc_sb_support_pkg;
