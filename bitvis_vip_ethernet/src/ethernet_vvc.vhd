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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.support_pkg.all;

--==========================================================================================
entity ethernet_vvc is
  generic(
    GC_INSTANCE_IDX                          : natural;
    GC_PHY_INTERFACE                         : t_interface;
    GC_PHY_VVC_INSTANCE_IDX                  : natural;
    GC_PHY_MAX_ACCESS_TIME                   : time                                  := 1 us;
    GC_DUT_IF_FIELD_CONFIG                   : t_dut_if_field_config_direction_array := C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY_DEFAULT;
    GC_ETHERNET_PROTOCOL_CONFIG              : t_ethernet_protocol_config            := C_ETHERNET_PROTOCOL_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural                               := C_CMD_QUEUE_COUNT_MAX;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                               := C_CMD_QUEUE_COUNT_THRESHOLD;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level                         := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;
    GC_RESULT_QUEUE_COUNT_MAX                : natural                               := C_RESULT_QUEUE_COUNT_MAX;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                               := C_RESULT_QUEUE_COUNT_THRESHOLD;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level                         := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );
end entity ethernet_vvc;

--==========================================================================================
--==========================================================================================
architecture struct of ethernet_vvc is

begin

  -- ETHERNET TX VVC
  i_ethernet_tx : entity work.ethernet_tx_vvc
    generic map(
      GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
      GC_CHANNEL                               => TX,
      GC_PHY_INTERFACE                         => GC_PHY_INTERFACE,
      GC_PHY_VVC_INSTANCE_IDX                  => GC_PHY_VVC_INSTANCE_IDX,
      GC_PHY_MAX_ACCESS_TIME                   => GC_PHY_MAX_ACCESS_TIME,
      GC_DUT_IF_FIELD_CONFIG                   => GC_DUT_IF_FIELD_CONFIG,
      GC_ETHERNET_PROTOCOL_CONFIG              => GC_ETHERNET_PROTOCOL_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
      GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
      GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
      GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
    );

  -- ETHERNET RX VVC
  i_ethernet_rx : entity work.ethernet_rx_vvc
    generic map(
      GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
      GC_CHANNEL                               => RX,
      GC_PHY_INTERFACE                         => GC_PHY_INTERFACE,
      GC_PHY_VVC_INSTANCE_IDX                  => GC_PHY_VVC_INSTANCE_IDX,
      GC_PHY_MAX_ACCESS_TIME                   => GC_PHY_MAX_ACCESS_TIME,
      GC_DUT_IF_FIELD_CONFIG                   => GC_DUT_IF_FIELD_CONFIG,
      GC_ETHERNET_PROTOCOL_CONFIG              => GC_ETHERNET_PROTOCOL_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
      GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
      GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
      GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
    );

end struct;
