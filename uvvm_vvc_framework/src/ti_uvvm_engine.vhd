--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

entity ti_uvvm_engine is
end entity;

architecture func of ti_uvvm_engine is
begin

  --------------------------------------------------------
  -- Initializes the UVVM VVC Framework
  --------------------------------------------------------
  p_initialize_uvvm : process
  begin
    -- shared_uvvm_state is initialized to IDLE. Hence it will stay in IDLE if this procedure is not included in the TB
    shared_uvvm_state := PHASE_A;
    wait for 0 ns;  -- A single delta cycle
    wait for 0 ns;  -- A single delta cycle
    if (shared_uvvm_state = PHASE_B) then
      tb_failure("ti_uvvm_engine seems to have been instantiated more than once in this testbench system", C_SCOPE);
    end if;
    shared_uvvm_state := PHASE_B;
    wait for 0 ns;  -- A single delta cycle
    wait for 0 ns;  -- A single delta cycle
    shared_uvvm_state := INIT_COMPLETED;
    wait;
  end process p_initialize_uvvm;

end func;
