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

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.protected_types_pkg.all;

package global_signals_and_shared_variables_pkg is

  -- Global signals
  signal global_trigger : std_logic := 'L';
  signal global_barrier : std_logic := 'X';

  -- Shared variables
  shared variable shared_uvvm_status  : t_uvvm_status  := C_UVVM_STATUS_DEFAULT;
  shared variable shared_msg_id_panel : t_msg_id_panel := C_MSG_ID_PANEL_DEFAULT;

  -- Randomization seeds
  shared variable shared_rand_seeds_register : t_seeds;

  -- UVVM internal shared variables
  shared variable shared_initialised_util        : boolean                                         := false;
  shared variable shared_log_file_name_is_set    : boolean                                         := false;
  shared variable shared_alert_file_name_is_set  : boolean                                         := false;
  shared variable shared_warned_time_stamp_trunc : boolean                                         := false;
  shared variable shared_warned_rand_time_res    : boolean                                         := false;
  shared variable shared_alert_attention         : t_alert_attention                               := C_DEFAULT_ALERT_ATTENTION;
  shared variable shared_stop_limit              : t_alert_counters                                := C_DEFAULT_STOP_LIMIT;
  shared variable shared_log_hdr_for_waveview    : string(1 to C_LOG_HDR_FOR_WAVEVIEW_WIDTH);
  shared variable shared_current_log_hdr         : t_current_log_hdr;
  shared variable shared_seed1                   : positive;
  shared variable shared_seed2                   : positive;
  shared variable shared_flag_array              : t_sync_flag_record_array(1 to C_NUM_SYNC_FLAGS) := (others => C_SYNC_FLAG_DEFAULT);
  shared variable protected_semaphore            : t_protected_semaphore;
  shared variable protected_broadcast_semaphore  : t_protected_semaphore;
  shared variable protected_response_semaphore   : t_protected_semaphore;
  shared variable protected_covergroup_status    : t_protected_covergroup_status;
  shared variable protected_sb_activity_register : t_sb_activity;

end package global_signals_and_shared_variables_pkg;
