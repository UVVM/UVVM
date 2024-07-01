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

library bitvis_vip_gmii;
use bitvis_vip_gmii.gmii_bfm_pkg.all;

--=================================================================================================
-- Test harness entity
--=================================================================================================
entity gmii_th is
  generic(
    GC_CLK_PERIOD : time
  );
  port(
    signal clk        : in    std_logic;
    signal gmii_tx_if : inout t_gmii_tx_if;
    signal gmii_rx_if : inout t_gmii_rx_if
  );
end entity;

--=================================================================================================
-- Test harness architectures
--=================================================================================================
architecture struct_bfm of gmii_th is
begin

  -- Delay the RX path
  gmii_tx_if.gtxclk <= clk;
  gmii_tx_if.txd    <= (others => 'Z');
  gmii_tx_if.txen   <= 'Z';
  gmii_rx_if.rxclk  <= clk;
  gmii_rx_if.rxd    <= transport gmii_tx_if.txd after GC_CLK_PERIOD * 5;
  gmii_rx_if.rxdv   <= transport gmii_tx_if.txen after GC_CLK_PERIOD * 5;

end struct_bfm;

architecture struct_vvc of gmii_th is
  signal dut_txd  : std_logic_vector(7 downto 0);
  signal dut_txen : std_logic;
begin

  -- Instantiate VVC
  i_gmii_vvc : entity work.gmii_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      gmii_vvc_tx_if => gmii_tx_if,
      gmii_vvc_rx_if => gmii_rx_if
    );

  gmii_tx_if.gtxclk <= clk;
  gmii_rx_if.rxclk  <= clk;
  -- Use non-record signals to be able to force them from the tb
  dut_txd           <= gmii_tx_if.txd;
  dut_txen          <= gmii_tx_if.txen;
  gmii_rx_if.rxd    <= dut_txd;
  gmii_rx_if.rxdv   <= dut_txen;

end struct_vvc;
