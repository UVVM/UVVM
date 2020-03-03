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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

entity hvvc_to_vvc_bridge is
  generic(
    GC_INSTANCE_IDX        : integer;
    GC_DUT_IF_FIELD_CONFIG : t_dut_if_field_config_direction_array;
    GC_MAX_NUM_WORDS       : positive;
    GC_PHY_MAX_ACCESS_TIME : time;
    GC_SCOPE               : string
  );
  port(
    hvvc_to_bridge : in  t_hvvc_to_bridge;
    bridge_to_hvvc : out t_bridge_to_hvvc
  );
end entity hvvc_to_vvc_bridge;