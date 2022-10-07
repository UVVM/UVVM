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

package local_adaptations_pkg is

  -------------------------------------------------------------------------------
  -- Constants for this VIP
  -------------------------------------------------------------------------------
  -- This constant can be smaller than C_MAX_VVC_INSTANCE_NUM but not bigger.
  constant C_AVALON_ST_MAX_VVC_INSTANCE_NUM : natural := C_MAX_VVC_INSTANCE_NUM;

  constant C_AVALON_ST_CHANNEL_MAX_LENGTH : natural := 8;
  constant C_AVALON_ST_WORD_MAX_LENGTH    : natural := 512;
  constant C_AVALON_ST_DATA_MAX_WORDS     : natural := 1024;

end package local_adaptations_pkg;

package body local_adaptations_pkg is
end package body local_adaptations_pkg;
