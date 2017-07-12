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

use work.uart_bfm_pkg.all;
use work.vvc_cmd_pkg.all;

--=================================================================================================
entity uart_vvc is
  generic (
    GC_DATA_WIDTH                           : natural range 1 to C_VVC_CMD_DATA_MAX_LENGTH := 8;
    GC_INSTANCE_IDX                         : natural                                      := 1;
    GC_UART_CONFIG                          : t_uart_bfm_config                            := C_UART_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                  : natural                                      := 1000; 
    GC_CMD_QUEUE_COUNT_THRESHOLD            : natural                                      := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY   : t_alert_level                                := WARNING
  );
  port (
    uart_vvc_rx         : in std_logic;
    uart_vvc_tx         : inout std_logic
  );
end entity uart_vvc;


--=================================================================================================
--=================================================================================================

architecture struct of uart_vvc is


begin

    -- UART RX VVC
    i1_uart_rx: entity work.uart_rx_vvc
    generic map(
      GC_DATA_WIDTH                             => GC_DATA_WIDTH,
      GC_INSTANCE_IDX                           => GC_INSTANCE_IDX,
      GC_CHANNEL                                => RX,
      GC_UART_CONFIG                            => GC_UART_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                    => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD              => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      uart_vvc_rx         => uart_vvc_rx
    );

    -- UART TX VVC
    i1_uart_tx: entity work.uart_tx_vvc
    generic map(
      GC_DATA_WIDTH                             => GC_DATA_WIDTH,
      GC_INSTANCE_IDX                           => GC_INSTANCE_IDX,
      GC_CHANNEL                                => TX,
      GC_UART_CONFIG                            => GC_UART_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                    => GC_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD              => GC_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY
    )
    port map(
      uart_vvc_tx         => uart_vvc_tx
    );

end struct;


