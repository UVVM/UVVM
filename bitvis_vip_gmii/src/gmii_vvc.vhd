--========================================================================================================================
-- This VVC was generated with Bitvis VVC Generator
--========================================================================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.gmii_bfm_pkg.all;

--========================================================================================================================
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
    gmii_vvc_if : inout t_gmii_if
  );
end entity gmii_vvc;

--========================================================================================================================
--========================================================================================================================
architecture struct of gmii_vvc is

begin

  -- GMII TRANSMITTER VVC
  i_gmii_transmitter: entity work.gmii_transmitter_vvc
  generic map(
    GC_INSTANCE_IDX                           => GC_INSTANCE_IDX,
    GC_CHANNEL                                => TRANSMITTER,
    GC_GMII_BFM_CONFIG                        => GC_GMII_BFM_CONFIG,
    GC_CMD_QUEUE_COUNT_MAX                    => GC_CMD_QUEUE_COUNT_MAX,
    GC_CMD_QUEUE_COUNT_THRESHOLD              => GC_CMD_QUEUE_COUNT_THRESHOLD,
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY
  )
  port map(
    gmii_to_dut_if => gmii_vvc_if.gmii_to_dut_if
  );


  -- GMII RECEIVER VVC
  i_gmii_receiver: entity work.gmii_receiver_vvc
  generic map(
    GC_INSTANCE_IDX                           => GC_INSTANCE_IDX,
    GC_CHANNEL                                => RECEIVER,
    GC_GMII_BFM_CONFIG                        => GC_GMII_BFM_CONFIG,
    GC_CMD_QUEUE_COUNT_MAX                    => GC_CMD_QUEUE_COUNT_MAX,
    GC_CMD_QUEUE_COUNT_THRESHOLD              => GC_CMD_QUEUE_COUNT_THRESHOLD,
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY
  )
  port map(
    gmii_from_dut_if => gmii_vvc_if.gmii_from_dut_if
  );

end struct;

