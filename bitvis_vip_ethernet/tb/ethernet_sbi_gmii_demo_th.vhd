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
-- Description : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_gmii;
use bitvis_vip_gmii.gmii_bfm_pkg.all;

library bitvis_vip_ethernet;

use work.ethernet_mac_pkg.all;

--=================================================================================================
-- Test harness entity
--=================================================================================================
entity ethernet_sbi_gmii_demo_th is
  generic(
    GC_CLK_PERIOD : time
  );
end entity ethernet_sbi_gmii_demo_th;

--=================================================================================================
-- Test harness architecture
--=================================================================================================
architecture struct of ethernet_sbi_gmii_demo_th is
  -- VVC instance indexes
  constant C_VVC_ETH_SBI  : natural := 1;
  constant C_VVC_SBI      : natural := 1;
  constant C_VVC_ETH_GMII : natural := 2;
  constant C_VVC_GMII     : natural := 2;

  signal clk            : std_logic;
  signal sbi_if         : t_sbi_if(addr(C_SBI_ADDR_WIDTH - 1 downto 0),
                                   wdata(C_SBI_DATA_WIDTH - 1 downto 0),
                                   rdata(C_SBI_DATA_WIDTH - 1 downto 0));
  signal gmii_vvc_tx_if : t_gmii_tx_if;
  signal gmii_vvc_rx_if : t_gmii_rx_if;

  -- Configuration for the Ethernet MAC field addresses (only applicable for SBI, use default for GMII).
  constant C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY : t_dut_if_field_config_direction_array(TRANSMIT to RECEIVE)(0 to 5) := (TRANSMIT => (0 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => false, field_description => "TX Preamble and SFD"),
                                                                                                                                       1 => (dut_address => C_ETH_ADDR_MAC_DEST, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "TX MAC destination "),
                                                                                                                                       2 => (dut_address => C_ETH_ADDR_MAC_SRC, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "TX MAC source      "),
                                                                                                                                       3 => (dut_address => C_ETH_ADDR_PAY_LEN, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "TX payload length  "),
                                                                                                                                       4 => (dut_address => C_ETH_ADDR_PAYLOAD, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "TX payload         "),
                                                                                                                                       5 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => false, field_description => "TX FCS             ")),
                                                                                                                          RECEIVE  => (0 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "RX NOT USING ADDR  "),
                                                                                                                                       1 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "RX NOT USING ADDR  "),
                                                                                                                                       2 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "RX NOT USING ADDR  "),
                                                                                                                                       3 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "RX NOT USING ADDR  "),
                                                                                                                                       4 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "RX NOT USING ADDR  "),
                                                                                                                                       5 => (dut_address => C_ETH_ADDR_INVALID, dut_address_increment => 0, data_width => C_SBI_DATA_WIDTH, use_field => true, field_description => "RX NOT USING ADDR  "))
                                                                                                                         );

begin

  ------------------------------------------
  -- Clock generator
  ------------------------------------------
  p_clk : clock_generator(clk, GC_CLK_PERIOD);

  ------------------------------------------
  -- CPU to MAC interface
  ------------------------------------------
  i1_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX         => C_VVC_ETH_SBI,
      GC_PHY_INTERFACE        => SBI,
      GC_PHY_VVC_INSTANCE_IDX => C_VVC_SBI,
      GC_PHY_MAX_ACCESS_TIME  => GC_CLK_PERIOD * 2, -- add some margin in case of SBI ready low
      GC_DUT_IF_FIELD_CONFIG  => C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY
    );

  i1_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => C_SBI_ADDR_WIDTH,
      GC_DATA_WIDTH   => C_SBI_DATA_WIDTH,
      GC_INSTANCE_IDX => C_VVC_SBI
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => sbi_if
    );

  ------------------------------------------
  -- Ethernet MAC
  ------------------------------------------
  i_ethernet_mac : entity work.ethernet_mac
    port map(
      -- SBI interface
      clk       => clk,
      sbi_cs    => sbi_if.cs,
      sbi_addr  => sbi_if.addr,
      sbi_rena  => sbi_if.rena,
      sbi_wena  => sbi_if.wena,
      sbi_wdata => sbi_if.wdata,
      sbi_ready => sbi_if.ready,
      sbi_rdata => sbi_if.rdata,
      -- GMII interface (only TX)
      gtxclk    => gmii_vvc_rx_if.rxclk,
      txd       => gmii_vvc_rx_if.rxd,
      txen      => gmii_vvc_rx_if.rxdv
    );

  ------------------------------------------
  -- MAC to PHY interface
  ------------------------------------------
  i2_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX         => C_VVC_ETH_GMII,
      GC_PHY_INTERFACE        => GMII,
      GC_PHY_VVC_INSTANCE_IDX => C_VVC_GMII,
      GC_PHY_MAX_ACCESS_TIME  => GC_CLK_PERIOD * 4, -- add some margin
      GC_DUT_IF_FIELD_CONFIG  => C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY
    );

  i2_gmii_vvc : entity bitvis_vip_gmii.gmii_vvc
    generic map(
      GC_INSTANCE_IDX => C_VVC_GMII
    )
    port map(
      gmii_vvc_tx_if => gmii_vvc_tx_if,
      gmii_vvc_rx_if => gmii_vvc_rx_if
    );

end architecture struct;
