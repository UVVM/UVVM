--================================================================================================================================
-- Copyright (c) 2020 by Bitvis AS.  All rights reserved.
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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.support_pkg.all;

--==========================================================================================
entity ethernet_vvc is
  generic (
    GC_INSTANCE_IDX                          : natural;
    GC_PHY_INTERFACE                         : t_interface;
    GC_PHY_VVC_INSTANCE_IDX                  : natural;
    GC_DUT_IF_FIELD_CONFIG                   : t_dut_if_field_config_direction_array := C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY_DEFAULT;
    GC_ETHERNET_BFM_CONFIG                   : t_ethernet_bfm_config                 := C_ETHERNET_BFM_CONFIG_DEFAULT;
    GC_CMD_QUEUE_COUNT_MAX                   : natural                               := 1000;
    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                               := 950;
    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level                         := WARNING;
    GC_RESULT_QUEUE_COUNT_MAX                : natural                               := 1000;
    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                               := 950;
    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level                         := WARNING
  );
end entity ethernet_vvc;

--==========================================================================================
--==========================================================================================
architecture struct of ethernet_vvc is

begin

  -- ETHERNET TRANSMIT VVC
  i_ethernet_transmit: entity work.ethernet_transmit_vvc
  generic map(
    GC_INSTANCE_IDX                          => GC_INSTANCE_IDX,
    GC_CHANNEL                               => TX,
    GC_PHY_INTERFACE                         => GC_PHY_INTERFACE,
    GC_PHY_VVC_INSTANCE_IDX                  => GC_PHY_VVC_INSTANCE_IDX,
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
    GC_CHANNEL                               => RX,
    GC_PHY_INTERFACE                         => GC_PHY_INTERFACE,
    GC_PHY_VVC_INSTANCE_IDX                  => GC_PHY_VVC_INSTANCE_IDX,
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