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
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package generic_sb_support_pkg is

  type t_sb_config is record
    mismatch_alert_level      : t_alert_level;
    allow_lossy               : boolean;
    allow_out_of_order        : boolean;
    overdue_check_alert_level : t_alert_level;
    overdue_check_time_limit  : time;
    ignore_initial_garbage    : boolean;
  end record;

  type t_sb_config_array is array(integer range <>) of t_sb_config;

  constant C_SB_CONFIG_DEFAULT : t_sb_config := (mismatch_alert_level      => ERROR,
                                                 allow_lossy               => false,
                                                 allow_out_of_order        => false,
                                                 overdue_check_alert_level => ERROR,
                                                 overdue_check_time_limit  => 0 ns,
                                                 ignore_initial_garbage    => false);

end package generic_sb_support_pkg;