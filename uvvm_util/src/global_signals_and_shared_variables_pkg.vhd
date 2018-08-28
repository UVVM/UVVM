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

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.protected_types_pkg.all;

package global_signals_and_shared_variables_pkg is
-- Shared variables
  shared variable shared_initialised_util        : boolean  := false;
  shared variable shared_msg_id_panel            : t_msg_id_panel   := C_MSG_ID_PANEL_DEFAULT;
  shared variable shared_log_file_name_is_set    : boolean  := false;
  shared variable shared_alert_file_name_is_set  : boolean  := false;
  shared variable shared_warned_time_stamp_trunc : boolean  := false;
  shared variable shared_alert_attention         : t_alert_attention:= C_DEFAULT_ALERT_ATTENTION;
  shared variable shared_stop_limit              : t_alert_counters := C_DEFAULT_STOP_LIMIT;
  shared variable shared_log_hdr_for_waveview    : string(1 to C_LOG_HDR_FOR_WAVEVIEW_WIDTH);
  shared variable shared_current_log_hdr         : t_current_log_hdr;
  shared variable shared_seed1                   : positive;
  shared variable shared_seed2                   : positive;
  shared variable shared_flag_array              : t_sync_flag_record_array := (others => C_SYNC_FLAG_DEFAULT);
  shared variable protected_semaphore            : t_protected_semaphore;
  shared variable protected_broadcast_semaphore  : t_protected_semaphore;
  shared variable protected_response_semaphore   : t_protected_semaphore;
  shared variable shared_uvvm_status             : t_uvvm_status := C_UVVM_STATUS_DEFAULT;

  -- Global signals
  signal global_trigger : std_logic := 'L';
  signal global_barrier : std_logic := 'X';
end package global_signals_and_shared_variables_pkg;