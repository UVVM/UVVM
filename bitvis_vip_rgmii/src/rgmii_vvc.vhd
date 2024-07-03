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

use work.rgmii_bfm_pkg.all;

--==========================================================================================
entity rgmii_vvc is
  generic(
    GC_INSTANCE_IDX                          : natural;
    GC_RGMII_BFM_CONFIG                      : t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural            := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural            := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level      := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural            := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural            := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level      := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
  port(
    rgmii_vvc_tx_if : inout t_rgmii_tx_if;
    rgmii_vvc_rx_if : inout t_rgmii_rx_if
  );
end entity rgmii_vvc;

--==========================================================================================
--==========================================================================================
architecture struct of rgmii_vvc is

begin

  -- RGMII TX VVC
  i_rgmii_tx : entity work.rgmii_tx_vvc
    generic map(
      GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
      GC_CHANNEL                               => TX,
      GC_RGMII_BFM_CONFIG                      => GC_RGMII_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
      GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
      GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
      GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      rgmii_vvc_tx_if => rgmii_vvc_tx_if
    );

  -- RGMII RX VVC
  i_rgmii_rx : entity work.rgmii_rx_vvc
    generic map(
      GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
      GC_CHANNEL                               => RX,
      GC_RGMII_BFM_CONFIG                      => GC_RGMII_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
      GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
      GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
      GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      rgmii_vvc_rx_if => rgmii_vvc_rx_if
    );

end struct;
