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

library uvvm_util;
context uvvm_util.uvvm_util_context;

package error_injection_pkg is

  type t_error_injection_types is (
    BYPASS,
    PULSE,
    DELAY,
    JITTER,
    INVERT,
    STUCK_AT_OLD,
    STUCK_AT_NEW
  );

  type t_error_injection_config is record
    error_type          : t_error_injection_types;
    initial_delay_min   : time;
    initial_delay_max   : time;
    return_delay_min    : time;
    return_delay_max    : time;
    width_min           : time;
    width_max           : time;
    interval            : positive;
    base_value          : std_logic; -- SL only
    randomization_seed1 : positive;
    randomization_seed2 : positive;
  end record;

  constant C_EI_CONFIG_DEFAULT : t_error_injection_config := (
    error_type          => BYPASS,
    initial_delay_min   => 0 ns,
    initial_delay_max   => 0 ns,
    return_delay_min    => 0 ns,
    return_delay_max    => 0 ns,
    width_min           => 0 ns,
    width_max           => 0 ns,
    interval            => 1,
    base_value          => '0',
    randomization_seed1 => 1,
    randomization_seed2 => 2
  );

  constant C_MAX_EI_INSTANCE_NUM : natural := 100;

  type t_error_injection_config_array is array(natural range <>) of t_error_injection_config;

  shared variable shared_ei_config : t_error_injection_config_array(0 to C_MAX_EI_INSTANCE_NUM) := (others => C_EI_CONFIG_DEFAULT);


end package error_injection_pkg;


