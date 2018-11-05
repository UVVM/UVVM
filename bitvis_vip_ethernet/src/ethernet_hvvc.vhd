--========================================================================================================================
-- This VVC was generated with Bitvis VVC Generator
--========================================================================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

use work.ethernet_bfm_pkg.all;

--========================================================================================================================
entity ethernet_vvc is
  generic (
    GC_INSTANCE_IDX                          : natural;
    GC_INTERFACE                             : t_interface;
    GC_VVC_INSTANCE_IDX                      : natural;
    GC_DUT_IF_FIELD_CONFIG                   : t_dut_if_field_config_channel_array := C_DUT_IF_FIELD_CONFIG_CHANNEL_ARRAY_DEFAULT;
    GC_ETHERNET_BFM_CONFIG                   : t_ethernet_bfm_config               := C_ETHERNET_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural                             := 1000;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                             := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level                       := WARNING;
    GC_RESULT_QUEUE_COUNT_MAX                : natural                             := 1000;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                             := 950;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level                       := WARNING
  );
end entity ethernet_vvc;

--========================================================================================================================
--========================================================================================================================
architecture struct of ethernet_vvc is

begin


  -- ETHERNET TRANSMIT VVC
  i_ethernet_transmit: entity work.ethernet_transmit_vvc
  generic map(
    GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
    GC_INTERFACE                             => GC_INTERFACE,
    GC_VVC_INSTANCE_IDX                      => GC_VVC_INSTANCE_IDX,
    GC_DUT_IF_FIELD_CONFIG                   => GC_DUT_IF_FIELD_CONFIG,
    GC_ETHERNET_BFM_CONFIG                   => GC_ETHERNET_BFM_CONFIG,
    GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
    GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
    GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );


  -- ETHERNET RECEIVE VVC
  i_ethernet_receive: entity work.ethernet_receive_vvc
  generic map(
    GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
    GC_INTERFACE                             => GC_INTERFACE,
    GC_VVC_INSTANCE_IDX                      => GC_VVC_INSTANCE_IDX,
    GC_DUT_IF_FIELD_CONFIG                   => GC_DUT_IF_FIELD_CONFIG,
    GC_ETHERNET_BFM_CONFIG                   => GC_ETHERNET_BFM_CONFIG,
    GC_CMD_QUEUE_COUNT_MAX                   => GC_CMD_QUEUE_COUNT_MAX,
    GC_CMD_QUEUE_COUNT_THRESHOLD             => GC_CMD_QUEUE_COUNT_THRESHOLD,
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    GC_RESULT_QUEUE_COUNT_MAX                => GC_RESULT_QUEUE_COUNT_MAX,
    GC_RESULT_QUEUE_COUNT_THRESHOLD          => GC_RESULT_QUEUE_COUNT_THRESHOLD,
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY
  );

end struct;

