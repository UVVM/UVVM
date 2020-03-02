--================================================================================================================================
-- Copyright 2020 Bitvis
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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

library bitvis_vip_ethernet;
context bitvis_vip_ethernet.vvc_context;

--=================================================================================================
entity gmii_test_harness is
  generic(
    GC_CLK_PERIOD : time
  );
end entity gmii_test_harness;


--=================================================================================================
--=================================================================================================

architecture struct of gmii_test_harness is

  signal clk           : std_logic;
  signal i1_gmii_tx_if : t_gmii_tx_if;
  signal i1_gmii_rx_if : t_gmii_rx_if;
  signal i2_gmii_tx_if : t_gmii_tx_if;
  signal i2_gmii_rx_if : t_gmii_rx_if;

begin

  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX         => 1,
      GC_PHY_INTERFACE        => GMII,
      GC_PHY_VVC_INSTANCE_IDX => 1
    );

  i2_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX         => 2,
      GC_PHY_INTERFACE        => GMII,
      GC_PHY_VVC_INSTANCE_IDX => 2
    );


  i1_gmii_vvc : entity bitvis_vip_gmii.gmii_vvc
    generic map(
      GC_INSTANCE_IDX                       => 1,
      GC_GMII_BFM_CONFIG                    => C_GMII_BFM_CONFIG_DEFAULT,
      GC_CMD_QUEUE_COUNT_MAX                => 500,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => 450,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => WARNING
    )
    port map(
      gmii_vvc_tx_if => i1_gmii_tx_if,
      gmii_vvc_rx_if => i1_gmii_rx_if
    );

  i2_gmii_vvc : entity bitvis_vip_gmii.gmii_vvc
    generic map(
      GC_INSTANCE_IDX                       => 2,
      GC_GMII_BFM_CONFIG                    => C_GMII_BFM_CONFIG_DEFAULT,
      GC_CMD_QUEUE_COUNT_MAX                => 500,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => 450,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => WARNING
    )
    port map(
      gmii_vvc_tx_if => i2_gmii_tx_if,
      gmii_vvc_rx_if => i2_gmii_rx_if
    );

  p_clk : clock_generator(clk, GC_CLK_PERIOD);

  i1_gmii_tx_if.gtxclk <= clk;
  i1_gmii_rx_if.rxclk  <= clk;
  i1_gmii_rx_if.rxdv   <= i2_gmii_tx_if.txen;
  i1_gmii_rx_if.rxd    <= i2_gmii_tx_if.txd;
  i2_gmii_tx_if.gtxclk <= clk;
  i2_gmii_rx_if.rxclk  <= clk;
  i2_gmii_rx_if.rxdv   <= i1_gmii_tx_if.txen;
  i2_gmii_rx_if.rxd    <= i1_gmii_tx_if.txd;

end struct;