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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package generic_sb_support_pkg is

  function pad_sb_slv(
    constant pad_data  : std_logic_vector;
    constant pad_width : positive := C_SB_SLV_WIDTH
  ) return std_logic_vector;

  type t_sb_config is record
    mismatch_alert_level      : t_alert_level;
    allow_lossy               : boolean;
    allow_out_of_order        : boolean;
    overdue_check_alert_level : t_alert_level;
    overdue_check_time_limit  : time;
    ignore_initial_garbage    : boolean;
  end record;

  type t_sb_config_array is array (integer range <>) of t_sb_config;

  constant C_SB_CONFIG_DEFAULT : t_sb_config := (mismatch_alert_level      => ERROR,
                                                 allow_lossy               => false,
                                                 allow_out_of_order        => false,
                                                 overdue_check_alert_level => ERROR,
                                                 overdue_check_time_limit  => 0 ns,
                                                 ignore_initial_garbage    => false);

end package generic_sb_support_pkg;

package body generic_sb_support_pkg is

  -- Return a descending std_logic_vector with zeros padded on the left side
  function pad_sb_slv(
    constant pad_data  : std_logic_vector;
    constant pad_width : positive := C_SB_SLV_WIDTH
  ) return std_logic_vector is
    variable v_padded_slv : std_logic_vector(pad_width - 1 downto 0) := (others => '0');
  begin
    check_value(pad_data'length <= pad_width, TB_WARNING, "check: pad_data width exceed pad_width", C_VVC_CMD_SCOPE_DEFAULT, ID_NEVER);

    v_padded_slv(pad_data'length - 1 downto 0) := pad_data;
    return v_padded_slv;
  end function pad_sb_slv;

end package body generic_sb_support_pkg;
