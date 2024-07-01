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

use work.uart_bfm_pkg.all;
use work.transaction_pkg.all;

--=================================================================================================
entity uart_vvc_old is
  generic(
    GC_DATA_WIDTH                         : natural range 1 to C_VVC_CMD_DATA_MAX_LENGTH := 8;
    GC_INSTANCE_IDX                       : natural                                      := 1;
    GC_UART_CONFIG                        : t_uart_bfm_config                            := C_UART_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                : natural                                      := 1000;
    GC_CMD_QUEUE_COUNT_THRESHOLD          : natural                                      := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level                                := WARNING
  );
  port(
    uart_vvc_rx : in    std_logic;
    uart_vvc_tx : inout std_logic
  );
end entity uart_vvc_old;

--=================================================================================================
--=================================================================================================

architecture struct of uart_vvc_old is

begin

  -- UART RX VVC
  i1_uart_rx : entity work.uart_rx_vvc_old
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_INSTANCE_IDX                       => GC_INSTANCE_IDX,
      GC_CHANNEL                            => RX,
      GC_UART_CONFIG                        => GC_UART_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      uart_vvc_rx => uart_vvc_rx
    );

  -- UART TX VVC
  i1_uart_tx : entity work.uart_tx_vvc_old
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_INSTANCE_IDX                       => GC_INSTANCE_IDX,
      GC_CHANNEL                            => TX,
      GC_UART_CONFIG                        => GC_UART_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      uart_vvc_tx => uart_vvc_tx
    );

end struct;

