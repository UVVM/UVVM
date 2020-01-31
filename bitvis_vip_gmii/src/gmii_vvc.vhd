--================================================================================================================================
-- Copyright (c) 2019 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

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
  generic (
    GC_INSTANCE_IDX                          : natural;
    GC_GMII_BFM_CONFIG                       : t_gmii_bfm_config         := C_GMII_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural                   := 1000;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                   := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level             := WARNING;
    GC_RESULT_QUEUE_COUNT_MAX                : natural                   := 1000;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                   := 950;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level             := WARNING
  );
  port (
    gmii_vvc_tx_if : inout t_gmii_tx_if;
    gmii_vvc_rx_if : inout t_gmii_rx_if
  );
end entity gmii_vvc;

--==========================================================================================
--==========================================================================================
architecture struct of gmii_vvc is

begin

  -- GMII TX VVC
  i_gmii_tx: entity work.gmii_tx_vvc
  generic map(
    GC_INSTANCE_IDX                           => GC_INSTANCE_IDX,
    GC_CHANNEL                                => TX,
    GC_GMII_BFM_CONFIG                        => GC_GMII_BFM_CONFIG,
    GC_CMD_QUEUE_COUNT_MAX                    => GC_CMD_QUEUE_COUNT_MAX,
    GC_CMD_QUEUE_COUNT_THRESHOLD              => GC_CMD_QUEUE_COUNT_THRESHOLD,
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    GC_RESULT_QUEUE_COUNT_MAX                 => GC_RESULT_QUEUE_COUNT_MAX,
    GC_RESULT_QUEUE_COUNT_THRESHOLD           => GC_RESULT_QUEUE_COUNT_THRESHOLD,
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY  => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  )
  port map(
    gmii_vvc_tx_if => gmii_vvc_tx_if
  );


  -- GMII RX VVC
  i_gmii_rx: entity work.gmii_rx_vvc
  generic map(
    GC_INSTANCE_IDX                           => GC_INSTANCE_IDX,
    GC_CHANNEL                                => RX,
    GC_GMII_BFM_CONFIG                        => GC_GMII_BFM_CONFIG,
    GC_CMD_QUEUE_COUNT_MAX                    => GC_CMD_QUEUE_COUNT_MAX,
    GC_CMD_QUEUE_COUNT_THRESHOLD              => GC_CMD_QUEUE_COUNT_THRESHOLD,
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    GC_RESULT_QUEUE_COUNT_MAX                 => GC_RESULT_QUEUE_COUNT_MAX,
    GC_RESULT_QUEUE_COUNT_THRESHOLD           => GC_RESULT_QUEUE_COUNT_THRESHOLD,
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY  => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  )
  port map(
    gmii_vvc_rx_if => gmii_vvc_rx_if
  );

end struct;