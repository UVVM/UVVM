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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_rgmii;
use bitvis_vip_rgmii.rgmii_bfm_pkg.all;


--=================================================================================================
-- Test harness entity
--=================================================================================================
entity test_harness is
  generic(
    GC_CLK_PERIOD      : time
  );
  port(
    signal clk         : in    std_logic;
    signal rgmii_tx_if : inout t_rgmii_tx_if;
    signal rgmii_rx_if : inout t_rgmii_rx_if
  );
end entity;

--=================================================================================================
-- Test harness architectures
--=================================================================================================
architecture struct_bfm of test_harness is
begin

  -- Delay the RX path
  rgmii_tx_if.txc    <= clk;
  rgmii_rx_if.rxc    <= clk;
  rgmii_rx_if.rxd    <= transport rgmii_tx_if.txd after GC_CLK_PERIOD*5;
  rgmii_rx_if.rx_ctl <= transport rgmii_tx_if.tx_ctl after GC_CLK_PERIOD*5;

end struct_bfm;


architecture struct_vvc of test_harness is
begin

  -- Instantiate VVC
  i_rgmii_vvc : entity work.rgmii_vvc
    generic map(
      GC_INSTANCE_IDX => 0
      )
    port map(
      rgmii_vvc_tx_if => rgmii_tx_if,
      rgmii_vvc_rx_if => rgmii_rx_if
    );

  rgmii_tx_if.txc    <= clk;
  rgmii_rx_if.rxc    <= clk;
  rgmii_rx_if.rxd    <= rgmii_tx_if.txd;
  rgmii_rx_if.rx_ctl <= rgmii_tx_if.tx_ctl;

end struct_vvc;