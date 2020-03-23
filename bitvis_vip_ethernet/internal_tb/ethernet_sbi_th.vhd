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

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_ethernet;

use work.ethernet_sbi_pkg.all;


--=================================================================================================
-- Test harness entity
--=================================================================================================
entity ethernet_sbi_th is
  generic(
    GC_CLK_PERIOD : time;
    GC_ADDR_WIDTH : positive;
    GC_DATA_WIDTH : positive
  );
end entity ethernet_sbi_th;

--=================================================================================================
-- Test harness architecture
--=================================================================================================
architecture struct of ethernet_sbi_th is

  signal clk       : std_logic;
  signal i1_sbi_if : t_sbi_if(addr(GC_ADDR_WIDTH-1 downto 0), wdata(GC_DATA_WIDTH-1 downto 0), rdata(GC_DATA_WIDTH-1 downto 0));
  signal i2_sbi_if : t_sbi_if(addr(GC_ADDR_WIDTH-1 downto 0), wdata(GC_DATA_WIDTH-1 downto 0), rdata(GC_DATA_WIDTH-1 downto 0));

  -- Configuration for the Ethernet MAC field addresses
  constant C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY : t_dut_if_field_config_direction_array(TRANSMIT to RECEIVE)(0 to 5) :=
    (TRANSMIT => (0 => (dut_address => to_unsigned(C_ADDR_FIFO_PUT, 8), dut_address_increment => 0, data_width => 8, use_field => false, field_description => "TX Preamble and SFD"),
                  1 => (dut_address => to_unsigned(C_ADDR_FIFO_PUT, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "TX MAC destination "),
                  2 => (dut_address => to_unsigned(C_ADDR_FIFO_PUT, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "TX MAC source      "),
                  3 => (dut_address => to_unsigned(C_ADDR_FIFO_PUT, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "TX payload length  "),
                  4 => (dut_address => to_unsigned(C_ADDR_FIFO_PUT, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "TX payload         "),
                  5 => (dut_address => to_unsigned(C_ADDR_FIFO_PUT, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "TX FCS             ")),
    RECEIVE =>   (0 => (dut_address => to_unsigned(C_ADDR_FIFO_GET, 8), dut_address_increment => 0, data_width => 8, use_field => false, field_description => "RX Preamble and SFD"),
                  1 => (dut_address => to_unsigned(C_ADDR_FIFO_GET, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "RX MAC destination "),
                  2 => (dut_address => to_unsigned(C_ADDR_FIFO_GET, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "RX MAC source      "),
                  3 => (dut_address => to_unsigned(C_ADDR_FIFO_GET, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "RX payload length  "),
                  4 => (dut_address => to_unsigned(C_ADDR_FIFO_GET, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "RX payload         "),
                  5 => (dut_address => to_unsigned(C_ADDR_FIFO_GET, 8), dut_address_increment => 0, data_width => 8, use_field => true,  field_description => "RX FCS             "))
    );

begin

  ------------------------------------------
  -- Clock generator
  ------------------------------------------
  p_clk : clock_generator(clk, GC_CLK_PERIOD);

  -----------------------------
  -- VVC/executors
  -----------------------------
  i1_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX         => 1,
      GC_PHY_INTERFACE        => SBI,
      GC_PHY_VVC_INSTANCE_IDX => 1,
      GC_PHY_MAX_ACCESS_TIME  => GC_CLK_PERIOD*2, -- add some margin in case of SBI ready low
      GC_DUT_IF_FIELD_CONFIG  => C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY
    );

  i1_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => GC_ADDR_WIDTH,
      GC_DATA_WIDTH   => GC_DATA_WIDTH,
      GC_INSTANCE_IDX => 1
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => i1_sbi_if
    );

  i2_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX         => 2,
      GC_PHY_INTERFACE        => SBI,
      GC_PHY_VVC_INSTANCE_IDX => 2,
      GC_PHY_MAX_ACCESS_TIME  => GC_CLK_PERIOD*2, -- add some margin in case of SBI ready low
      GC_DUT_IF_FIELD_CONFIG  => C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY
    );

  i2_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => GC_ADDR_WIDTH,
      GC_DATA_WIDTH   => GC_DATA_WIDTH,
      GC_INSTANCE_IDX => 2
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => i2_sbi_if
    );

  -----------------------------
  -- DUT
  -----------------------------
  i_sbi_fifo : entity work.sbi_fifo
    generic map(
      GC_DATA_WIDTH_1  => GC_DATA_WIDTH,
      GC_ADDR_WIDTH_1  => GC_ADDR_WIDTH,
      GC_DATA_WIDTH_2  => GC_DATA_WIDTH,
      GC_ADDR_WIDTH_2  => GC_ADDR_WIDTH
    )
    port map(
      clk      => clk,
      sbi_if_1 => i1_sbi_if,
      sbi_if_2 => i2_sbi_if
    );

end architecture struct;