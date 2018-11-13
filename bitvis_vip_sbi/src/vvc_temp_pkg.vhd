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

use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.td_vvc_framework_common_methods_pkg.all;


--=================================================================================================
--=================================================================================================
--=================================================================================================
package vvc_temp_pkg is


  --==============================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order to queue BFM calls
  --   in the VVC command queue. The VVC will store and forward these calls to the
  --   SBI BFM when the command is at the from of the VVC command queue.
  -- - For details on how the BFM procedures work, see sbi_bfm_pkg.vhd or the
  --   quickref.
  --==============================================================================

  procedure fetch_result(
    signal   vvc_target                : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant wanted_idx                : in    integer;
    variable result                    : out   std_logic_vector;
    constant msg                       : in    string                      := "";
    constant alert_level               : in    t_alert_level               := TB_ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  function to_sb_result(
    constant data : in std_logic_vector
  ) return t_vvc_result;

end package vvc_temp_pkg;

package body vvc_temp_pkg is



  --==============================================================================
  -- Methods dedicated to this VVC
  -- Notes:
  --   - shared_vvc_cmd is initialised to C_VVC_CMD_DEFAULT, and also reset to this after every command
  --==============================================================================

  procedure fetch_result(
    signal   vvc_target                : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant wanted_idx                : in    integer;
    variable result                    : out   std_logic_vector;
    constant msg                       : in    string                      := "";
    constant alert_level               : in    t_alert_level               := TB_ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
    variable v_result : t_vvc_result;
  begin
    fetch_result(vvc_target, vvc_instance_idx, wanted_idx, v_result, msg, alert_level, scope, use_provided_msg_id_panel, msg_id_panel);
    result := v_result(result'length-1 downto 0);
  end procedure fetch_result;

  function to_sb_result(
    constant data : in std_logic_vector
  ) return t_vvc_result is
    variable v_vvc_result : t_vvc_result := (others => '-');
  begin
    v_vvc_result(data'length-1 downto 0) := data;
    return v_vvc_result;
  end function to_sb_result;

end package body vvc_temp_pkg;