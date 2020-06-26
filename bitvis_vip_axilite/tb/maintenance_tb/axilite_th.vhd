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

-- Include Verification IPs
library bitvis_vip_axilite;
use bitvis_vip_axilite.axilite_bfm_pkg.all;
use bitvis_vip_axilite.axilite_slave_model_pkg.all;

--=================================================================================================
entity test_harness is
  generic(
    constant C_ADDR_WIDTH_1   : natural := 32;
    constant C_DATA_WIDTH_1   : natural := 32;
    constant C_ADDR_WIDTH_2   : natural := 32;
    constant C_DATA_WIDTH_2   : natural := 32
  );
  port(
    signal clk          : in std_logic;
    signal areset       : in std_logic;
    signal axilite_if_1 : inout t_axilite_if( write_address_channel(  awaddr( C_ADDR_WIDTH_1    -1 downto 0)), 
                                              write_data_channel(     wdata(  C_DATA_WIDTH_1    -1 downto 0),
                                                                      wstrb(( C_DATA_WIDTH_1/8) -1 downto 0)),
                                              read_address_channel(   araddr( C_ADDR_WIDTH_1    -1 downto 0)),
                                              read_data_channel(      rdata(  C_DATA_WIDTH_1    -1 downto 0)));

    signal axilite_if_2 : inout t_axilite_if( write_address_channel(  awaddr( C_ADDR_WIDTH_2    -1 downto 0)), 
                                              write_data_channel(     wdata(  C_DATA_WIDTH_2    -1 downto 0),
                                                                      wstrb(( C_DATA_WIDTH_2/8) -1 downto 0)),
                                              read_address_channel(   araddr( C_ADDR_WIDTH_2    -1 downto 0)),
                                              read_data_channel(      rdata(  C_DATA_WIDTH_2    -1 downto 0))));

end entity test_harness;
--=================================================================================================
--=================================================================================================

architecture struct_simple of test_harness is

begin
  -----------------------------
  -- Instantiate DUT
  -----------------------------
  i_axilite_slave_1 : entity bitvis_vip_axilite.msec_ipcore_axilite
    generic map(
      C_S_AXI_DATA_WIDTH => C_DATA_WIDTH_1,
      C_S_AXI_ADDR_WIDTH => C_ADDR_WIDTH_1
    )
    port map (
      core_clk      => clk,
      calc_time     => open,
      IntrEvent     => open,
      S_AXI_ACLK    => clk,
      S_AXI_ARESETN => not areset,
      S_AXI_AWADDR  => axilite_if_1.write_address_channel.awaddr,
      S_AXI_AWVALID => axilite_if_1.write_address_channel.awvalid,
      S_AXI_AWREADY => axilite_if_1.write_address_channel.awready,
      S_AXI_WDATA   => axilite_if_1.write_data_channel.wdata, 
      S_AXI_WVALID  => axilite_if_1.write_data_channel.wvalid,
      S_AXI_WREADY  => axilite_if_1.write_data_channel.wready,
      S_AXI_WSTRB   => axilite_if_1.write_data_channel.wstrb, 
      S_AXI_BVALID  => axilite_if_1.write_response_channel.bvalid,
      S_AXI_BREADY  => axilite_if_1.write_response_channel.bready,
      S_AXI_BRESP   => axilite_if_1.write_response_channel.bresp,
      S_AXI_ARADDR  => axilite_if_1.read_address_channel.araddr,
      S_AXI_ARVALID => axilite_if_1.read_address_channel.arvalid,
      S_AXI_ARREADY => axilite_if_1.read_address_channel.arready,
      S_AXI_RDATA   => axilite_if_1.read_data_channel.rdata,
      S_AXI_RVALID  => axilite_if_1.read_data_channel.rvalid,
      S_AXI_RREADY  => axilite_if_1.read_data_channel.rready,
      S_AXI_RRESP   => axilite_if_1.read_data_channel.rresp);

  --Undriven from DUT_1 side (Innputs on inout record):
  axilite_if_1.write_address_channel.awaddr  <= (others => 'Z');
  axilite_if_1.write_address_channel.awvalid <= 'Z';
  axilite_if_1.write_address_channel.awprot  <= (others => 'Z');
  axilite_if_1.write_data_channel.wdata      <= (others => 'Z');
  axilite_if_1.write_data_channel.wvalid     <= 'Z';
  axilite_if_1.write_data_channel.wstrb      <= (others => 'Z');
  axilite_if_1.write_response_channel.bready <= 'Z';
  axilite_if_1.read_address_channel.araddr   <= (others => 'Z');
  axilite_if_1.read_address_channel.arvalid  <= 'Z';
  axilite_if_1.read_address_channel.arprot   <= (others => 'Z');
  axilite_if_1.read_data_channel.rready      <= 'Z';


  i_axilite_slave_2 : entity bitvis_vip_axilite.axilite_slave_model
    generic map(
      C_AXI_DATA_WIDTH => C_DATA_WIDTH_2
    )
    port map (
      aclk                => clk,
      aresetn             => not areset,

      wr_port_in.awaddr   =>  axilite_if_2.write_address_channel.awaddr,
      wr_port_in.awvalid  =>  axilite_if_2.write_address_channel.awvalid,
      wr_port_in.wdata    =>  axilite_if_2.write_data_channel.wdata,
      wr_port_in.wstrb    =>  axilite_if_2.write_data_channel.wstrb,
      wr_port_in.wvalid   =>  axilite_if_2.write_data_channel.wvalid,
      wr_port_in.bready   =>  axilite_if_2.write_response_channel.bready,
      
      wr_port_out.awready =>  axilite_if_2.write_address_channel.awready,
      wr_port_out.wready  =>  axilite_if_2.write_data_channel.wready,
      wr_port_out.bresp   =>  axilite_if_2.write_response_channel.bresp,
      wr_port_out.bvalid  =>  axilite_if_2.write_response_channel.bvalid,
      
      rd_port_in.araddr   =>  axilite_if_2.read_address_channel.araddr,
      rd_port_in.arvalid  =>  axilite_if_2.read_address_channel.arvalid,
      rd_port_in.rready   =>  axilite_if_2.read_data_channel.rready,
      
      rd_port_out.arready =>  axilite_if_2.read_address_channel.arready,
      rd_port_out.rdata   =>  axilite_if_2.read_data_channel.rdata,
      rd_port_out.rresp   =>  axilite_if_2.read_data_channel.rresp,
      rd_port_out.rvalid  =>  axilite_if_2.read_data_channel.rvalid
      );

  --Undriven from DUT_2 side (Innputs on inout record):
  axilite_if_2.write_address_channel.awaddr  <= (others => 'Z');
  axilite_if_2.write_address_channel.awvalid <= 'Z';
  axilite_if_2.write_address_channel.awprot  <= (others => 'Z');
  axilite_if_2.write_data_channel.wdata      <= (others => 'Z');
  axilite_if_2.write_data_channel.wvalid     <= 'Z';
  axilite_if_2.write_data_channel.wstrb      <= (others => 'Z');
  axilite_if_2.write_response_channel.bready <= 'Z';
  axilite_if_2.read_address_channel.araddr   <= (others => 'Z');
  axilite_if_2.read_address_channel.arvalid  <= 'Z';
  axilite_if_2.read_address_channel.arprot   <= (others => 'Z');
  axilite_if_2.read_data_channel.rready      <= 'Z';
end struct_simple;

architecture struct_vvc of test_harness is

begin
  -----------------------------
  -- Instantiate DUT
  -----------------------------
  i_axilite_slave_1 : entity bitvis_vip_axilite.msec_ipcore_axilite
    generic map(
      C_S_AXI_DATA_WIDTH => C_DATA_WIDTH_1,
      C_S_AXI_ADDR_WIDTH => C_ADDR_WIDTH_1
    )
    port map (
      core_clk      => clk,
      calc_time     => open,
      IntrEvent     => open,
      S_AXI_ACLK    => clk,
      S_AXI_ARESETN => not areset,
      S_AXI_AWADDR  => axilite_if_1.write_address_channel.awaddr,
      S_AXI_AWVALID => axilite_if_1.write_address_channel.awvalid,
      S_AXI_AWREADY => axilite_if_1.write_address_channel.awready,
      S_AXI_WDATA   => axilite_if_1.write_data_channel.wdata, 
      S_AXI_WVALID  => axilite_if_1.write_data_channel.wvalid,
      S_AXI_WREADY  => axilite_if_1.write_data_channel.wready,
      S_AXI_WSTRB   => axilite_if_1.write_data_channel.wstrb, 
      S_AXI_BVALID  => axilite_if_1.write_response_channel.bvalid,
      S_AXI_BREADY  => axilite_if_1.write_response_channel.bready,
      S_AXI_BRESP   => axilite_if_1.write_response_channel.bresp,
      S_AXI_ARADDR  => axilite_if_1.read_address_channel.araddr,
      S_AXI_ARVALID => axilite_if_1.read_address_channel.arvalid,
      S_AXI_ARREADY => axilite_if_1.read_address_channel.arready,
      S_AXI_RDATA   => axilite_if_1.read_data_channel.rdata,
      S_AXI_RVALID  => axilite_if_1.read_data_channel.rvalid,
      S_AXI_RREADY  => axilite_if_1.read_data_channel.rready,
      S_AXI_RRESP   => axilite_if_1.read_data_channel.rresp);

  --Undriven from DUT_1 side (Inputs on inout record):
  axilite_if_1.write_address_channel.awaddr  <= (others => 'Z');
  axilite_if_1.write_address_channel.awvalid <= 'Z';
  axilite_if_1.write_address_channel.awprot  <= (others => 'Z');
  axilite_if_1.write_data_channel.wdata      <= (others => 'Z');
  axilite_if_1.write_data_channel.wvalid     <= 'Z';
  axilite_if_1.write_data_channel.wstrb      <= (others => 'Z');
  axilite_if_1.write_response_channel.bready <= 'Z';
  axilite_if_1.read_address_channel.araddr   <= (others => 'Z');
  axilite_if_1.read_address_channel.arvalid  <= 'Z';
  axilite_if_1.read_address_channel.arprot   <= (others => 'Z');
  axilite_if_1.read_data_channel.rready      <= 'Z';


  i_axilite_slave_2 : entity bitvis_vip_axilite.axilite_slave_model
    generic map(
      C_AXI_ADDR_WIDTH => C_ADDR_WIDTH_2,
      C_AXI_DATA_WIDTH => C_DATA_WIDTH_2
    )
    port map (
      aclk                => clk,
      aresetn             => not areset,

      wr_port_in.awaddr   =>  axilite_if_2.write_address_channel.awaddr,
      wr_port_in.awvalid  =>  axilite_if_2.write_address_channel.awvalid,
      wr_port_in.wdata    =>  axilite_if_2.write_data_channel.wdata,
      wr_port_in.wstrb    =>  axilite_if_2.write_data_channel.wstrb,
      wr_port_in.wvalid   =>  axilite_if_2.write_data_channel.wvalid,
      wr_port_in.bready   =>  axilite_if_2.write_response_channel.bready,
      
      wr_port_out.awready =>  axilite_if_2.write_address_channel.awready,
      wr_port_out.wready  =>  axilite_if_2.write_data_channel.wready,
      wr_port_out.bresp   =>  axilite_if_2.write_response_channel.bresp,
      wr_port_out.bvalid  =>  axilite_if_2.write_response_channel.bvalid,
      
      rd_port_in.araddr   =>  axilite_if_2.read_address_channel.araddr,
      rd_port_in.arvalid  =>  axilite_if_2.read_address_channel.arvalid,
      rd_port_in.rready   =>  axilite_if_2.read_data_channel.rready,
      
      rd_port_out.arready =>  axilite_if_2.read_address_channel.arready,
      rd_port_out.rdata   =>  axilite_if_2.read_data_channel.rdata,
      rd_port_out.rresp   =>  axilite_if_2.read_data_channel.rresp,
      rd_port_out.rvalid  =>  axilite_if_2.read_data_channel.rvalid
      );

  --Undriven from DUT_2 side (Inputs on inout record):
  axilite_if_2.write_address_channel.awaddr  <= (others => 'Z');
  axilite_if_2.write_address_channel.awvalid <= 'Z';
  axilite_if_2.write_address_channel.awprot  <= (others => 'Z');
  axilite_if_2.write_data_channel.wdata      <= (others => 'Z');
  axilite_if_2.write_data_channel.wvalid     <= 'Z';
  axilite_if_2.write_data_channel.wstrb      <= (others => 'Z');
  axilite_if_2.write_response_channel.bready <= 'Z';
  axilite_if_2.read_address_channel.araddr   <= (others => 'Z');
  axilite_if_2.read_address_channel.arvalid  <= 'Z';
  axilite_if_2.read_address_channel.arprot   <= (others => 'Z');
  axilite_if_2.read_data_channel.rready      <= 'Z';
  
  
  
  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_axilite_vvc : entity work.axilite_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH_1,
      GC_DATA_WIDTH   => C_DATA_WIDTH_1,
      GC_INSTANCE_IDX => 1
      )
    port map(
      clk                    => clk, 
      axilite_vvc_master_if  => axilite_if_1
      );

  i2_axilite_vvc : entity work.axilite_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH_2,
      GC_DATA_WIDTH   => C_DATA_WIDTH_2,
      GC_INSTANCE_IDX => 2
      )
    port map(
      clk                   => clk,
      axilite_vvc_master_if => axilite_if_2
    );


end struct_vvc;