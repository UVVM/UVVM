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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.ti_vvc_framework_support_pkg.all;

entity ti_uvvm_engine is
end entity ti_uvvm_engine;

architecture func of ti_uvvm_engine is
begin

  --------------------------------------------------------
  -- Initializes the UVVM VVC Framework
  --------------------------------------------------------
  p_initialize_uvvm : process
  begin
    -- shared_uvvm_state is initialized to IDLE. Hence it will stay in IDLE if this procedure is not included in the TB
    shared_uvvm_state := PHASE_A;
    wait for 0 ns;                      -- A single delta cycle
    wait for 0 ns;                      -- A single delta cycle
    if (shared_uvvm_state = PHASE_B) then
      tb_failure("ti_uvvm_engine seems to have been instantiated more than once in this testbench system", C_SCOPE);
    end if;
    shared_uvvm_state := PHASE_B;
    wait for 0 ns;                      -- A single delta cycle
    wait for 0 ns;                      -- A single delta cycle
    shared_uvvm_state := INIT_COMPLETED;
    wait;
  end process p_initialize_uvvm;

end func;
