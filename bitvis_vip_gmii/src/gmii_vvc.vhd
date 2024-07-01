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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.gmii_bfm_pkg.all;

--==========================================================================================
entity gmii_vvc is
  generic(
    GC_INSTANCE_IDX                          : natural;
    GC_GMII_BFM_CONFIG                       : t_gmii_bfm_config := C_GMII_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural           := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural           := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level     := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural           := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural           := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level     := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
  port(
    gmii_vvc_tx_if : inout t_gmii_tx_if;
    gmii_vvc_rx_if : inout t_gmii_rx_if
  );
end entity gmii_vvc;

--==========================================================================================
--==========================================================================================
architecture struct of gmii_vvc is

begin

  -- GMII TX VVC
  i_gmii_tx : entity work.gmii_tx_vvc
    generic map(
      GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
      GC_CHANNEL                               => TX,
      GC_GMII_BFM_CONFIG                       => GC_GMII_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
      GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
      GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
      GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      gmii_vvc_tx_if => gmii_vvc_tx_if
    );

  -- GMII RX VVC
  i_gmii_rx : entity work.gmii_rx_vvc
    generic map(
      GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
      GC_CHANNEL                               => RX,
      GC_GMII_BFM_CONFIG                       => GC_GMII_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
      GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
      GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
      GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      gmii_vvc_rx_if => gmii_vvc_rx_if
    );

end struct;
