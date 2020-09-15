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

-- Include Verification IPs
library bitvis_vip_axi;
use bitvis_vip_axi.axi_bfm_pkg.all;
use bitvis_vip_axi.axi_slave_model_pkg.all;

--=================================================================================================
entity axi_th is
  generic(
    GC_ADDR_WIDTH_1   : natural := 32;
    GC_DATA_WIDTH_1   : natural := 32;
    GC_ID_WIDTH_1     : natural := 8;
    GC_USER_WIDTH_1   : natural := 8;
    GC_ADDR_WIDTH_2   : natural := 32;
    GC_DATA_WIDTH_2   : natural := 32;
    GC_ID_WIDTH_2     : natural := 8;
    GC_USER_WIDTH_2   : natural := 8
  );
end entity axi_th;
--=================================================================================================
--=================================================================================================

architecture struct of axi_th is

  constant C_AXI_CONFIG_1 : t_axi_bfm_config := (
    max_wait_cycles             => 1000,
    max_wait_cycles_severity    => TB_FAILURE,
    clock_period                => 10 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => -1 ns,
    hold_time                   => -1 ns,
    bfm_sync                    => SYNC_ON_CLOCK_ONLY,
    match_strictness            => MATCH_EXACT,
    num_aw_pipe_stages          => 0,
    num_w_pipe_stages           => 0,
    num_ar_pipe_stages          => 0,
    num_r_pipe_stages           => 0,
    num_b_pipe_stages           => 0,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL
  );

  constant C_AXI_CONFIG_2 : t_axi_bfm_config := (
    max_wait_cycles             => 1000,
    max_wait_cycles_severity    => TB_FAILURE,
    clock_period                => 10 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => -1 ns,
    hold_time                   => -1 ns,
    bfm_sync                    => SYNC_ON_CLOCK_ONLY,
    match_strictness            => MATCH_EXACT,
    num_aw_pipe_stages          => 1,
    num_w_pipe_stages           => 1,
    num_ar_pipe_stages          => 1,
    num_r_pipe_stages           => 1,
    num_b_pipe_stages           => 1,
    id_for_bfm                  => ID_BFM,
    id_for_bfm_wait             => ID_BFM_WAIT,
    id_for_bfm_poll             => ID_BFM_POLL
  );

  constant C_CLK_PERIOD : time := 10 ns;

  signal clk      : std_logic;
  signal aresetn  : std_logic;

  signal axi_if_1 : t_axi_if( write_address_channel( awid(   GC_ID_WIDTH_1 -1 downto 0),
                                                     awaddr( GC_ADDR_WIDTH_1-1 downto 0),
                                                     awuser( GC_USER_WIDTH_1 -1 downto 0)),
                              write_data_channel(    wdata(  GC_DATA_WIDTH_1-1 downto 0),
                                                     wstrb(  GC_DATA_WIDTH_1/8 -1 downto 0),
                                                     wuser(  GC_USER_WIDTH_1 -1 downto 0)),
                              write_response_channel(bid(    GC_ID_WIDTH_1 -1 downto 0),
                                                     buser(  GC_USER_WIDTH_1 -1 downto 0)),
                              read_address_channel(  arid(   GC_ID_WIDTH_1 -1 downto 0),
                                                     araddr( GC_ADDR_WIDTH_1-1 downto 0),
                                                     aruser( GC_USER_WIDTH_1-1 downto 0)),
                              read_data_channel(     rid(    GC_ID_WIDTH_1-1 downto 0),
                                                     rdata(  GC_DATA_WIDTH_1-1 downto 0),
                                                     ruser(  GC_USER_WIDTH_1-1 downto 0)));

  signal axi_if_2 : t_axi_if( write_address_channel( awid(   GC_ID_WIDTH_2 -1 downto 0),
                                                     awaddr( GC_ADDR_WIDTH_2-1 downto 0),
                                                     awuser( GC_USER_WIDTH_2 -1 downto 0)),
                              write_data_channel(    wdata(  GC_DATA_WIDTH_2-1 downto 0),
                                                     wstrb(  GC_DATA_WIDTH_2/8 -1 downto 0),
                                                     wuser(  GC_USER_WIDTH_2 -1 downto 0)),
                              write_response_channel(bid(    GC_ID_WIDTH_2 -1 downto 0),
                                                     buser(  GC_USER_WIDTH_2 -1 downto 0)),
                              read_address_channel(  arid(   GC_ID_WIDTH_2 -1 downto 0),
                                                     araddr( GC_ADDR_WIDTH_2-1 downto 0),
                                                     aruser( GC_USER_WIDTH_2-1 downto 0)),
                              read_data_channel(     rid(    GC_ID_WIDTH_2-1 downto 0),
                                                     rdata(  GC_DATA_WIDTH_2-1 downto 0),
                                                     ruser(  GC_USER_WIDTH_2-1 downto 0)));

begin

  -----------------------------
  -- Instantiate DUTs
  -----------------------------
  i_axi_slave_1 : entity work.axi_slave_model
    generic map (
      C_MEMORY_SIZE    => 4096, -- size in bytes
      C_MEMORY_START   => x"00000000"  -- address offset to start on
    )
    port map (
      aclk                => clk,
      aresetn             => aresetn,
      -- Inputs
      -- write address channel
      wr_port_in.awid     => axi_if_1.write_address_channel.awid,
      wr_port_in.awaddr   => axi_if_1.write_address_channel.awaddr,
      wr_port_in.awlen    => axi_if_1.write_address_channel.awlen,
      wr_port_in.awsize   => axi_if_1.write_address_channel.awsize,
      wr_port_in.awburst  => axi_if_1.write_address_channel.awburst,
      wr_port_in.awlock   => axi_if_1.write_address_channel.awlock,
      wr_port_in.awcache  => axi_if_1.write_address_channel.awcache,
      wr_port_in.awprot   => axi_if_1.write_address_channel.awprot,
      wr_port_in.awqos    => axi_if_1.write_address_channel.awqos,
      wr_port_in.awregion => axi_if_1.write_address_channel.awregion,
      wr_port_in.awuser   => axi_if_1.write_address_channel.awuser,
      wr_port_in.awvalid  => axi_if_1.write_address_channel.awvalid,
      -- write data channel
      wr_port_in.wdata    => axi_if_1.write_data_channel.wdata,
      wr_port_in.wstrb    => axi_if_1.write_data_channel.wstrb,
      wr_port_in.wlast    => axi_if_1.write_data_channel.wlast,
      wr_port_in.wuser    => axi_if_1.write_data_channel.wuser,
      wr_port_in.wvalid   => axi_if_1.write_data_channel.wvalid,
      -- write response channel
      wr_port_in.bready   => axi_if_1.write_response_channel.bready,
      -- read address channel
      rd_port_in.arid     => axi_if_1.read_address_channel.arid,
      rd_port_in.araddr   => axi_if_1.read_address_channel.araddr,
      rd_port_in.arlen    => axi_if_1.read_address_channel.arlen,
      rd_port_in.arsize   => axi_if_1.read_address_channel.arsize,
      rd_port_in.arburst  => axi_if_1.read_address_channel.arburst,
      rd_port_in.arlock   => axi_if_1.read_address_channel.arlock,
      rd_port_in.arcache  => axi_if_1.read_address_channel.arcache,
      rd_port_in.arprot   => axi_if_1.read_address_channel.arprot,
      rd_port_in.arqos    => axi_if_1.read_address_channel.arqos,
      rd_port_in.arregion => axi_if_1.read_address_channel.arregion,
      rd_port_in.aruser   => axi_if_1.read_address_channel.aruser,
      rd_port_in.arvalid  => axi_if_1.read_address_channel.arvalid,
      -- read data channel
      rd_port_in.rready   => axi_if_1.read_data_channel.rready,
      -- Outputs
      -- write address channel
      wr_port_out.awready => axi_if_1.write_address_channel.awready,
      -- write data channel
      wr_port_out.wready  => axi_if_1.write_data_channel.wready,
      -- write response channel
      wr_port_out.bid     => axi_if_1.write_response_channel.bid,
      wr_port_out.bresp   => axi_if_1.write_response_channel.bresp,
      wr_port_out.buser   => axi_if_1.write_response_channel.buser,
      wr_port_out.bvalid  => axi_if_1.write_response_channel.bvalid,
      -- read address channel
      rd_port_out.arready => axi_if_1.read_address_channel.arready,
      -- read data channel
      rd_port_out.rid     => axi_if_1.read_data_channel.rid,
      rd_port_out.rdata   => axi_if_1.read_data_channel.rdata,
      rd_port_out.rresp   => axi_if_1.read_data_channel.rresp,
      rd_port_out.rlast   => axi_if_1.read_data_channel.rlast,
      rd_port_out.ruser   => axi_if_1.read_data_channel.ruser,
      rd_port_out.rvalid  => axi_if_1.read_data_channel.rvalid
    );

  i_axi_slave_2 : entity work.axi_slave_model
    generic map (
      C_MEMORY_SIZE    => 4096, -- size in bytes
      C_MEMORY_START   => x"00000000"  -- address offset to start on
    )
    port map (
      aclk                => clk,
      aresetn             => aresetn,
      -- Inputs
      -- write address channel
      wr_port_in.awid     => axi_if_2.write_address_channel.awid,
      wr_port_in.awaddr   => axi_if_2.write_address_channel.awaddr,
      wr_port_in.awlen    => axi_if_2.write_address_channel.awlen,
      wr_port_in.awsize   => axi_if_2.write_address_channel.awsize,
      wr_port_in.awburst  => axi_if_2.write_address_channel.awburst,
      wr_port_in.awlock   => axi_if_2.write_address_channel.awlock,
      wr_port_in.awcache  => axi_if_2.write_address_channel.awcache,
      wr_port_in.awprot   => axi_if_2.write_address_channel.awprot,
      wr_port_in.awqos    => axi_if_2.write_address_channel.awqos,
      wr_port_in.awregion => axi_if_2.write_address_channel.awregion,
      wr_port_in.awuser   => axi_if_2.write_address_channel.awuser,
      wr_port_in.awvalid  => axi_if_2.write_address_channel.awvalid,
      -- write data channel
      wr_port_in.wdata    => axi_if_2.write_data_channel.wdata,
      wr_port_in.wstrb    => axi_if_2.write_data_channel.wstrb,
      wr_port_in.wlast    => axi_if_2.write_data_channel.wlast,
      wr_port_in.wuser    => axi_if_2.write_data_channel.wuser,
      wr_port_in.wvalid   => axi_if_2.write_data_channel.wvalid,
      -- write response channel
      wr_port_in.bready   => axi_if_2.write_response_channel.bready,
      -- read address channel
      rd_port_in.arid     => axi_if_2.read_address_channel.arid,
      rd_port_in.araddr   => axi_if_2.read_address_channel.araddr,
      rd_port_in.arlen    => axi_if_2.read_address_channel.arlen,
      rd_port_in.arsize   => axi_if_2.read_address_channel.arsize,
      rd_port_in.arburst  => axi_if_2.read_address_channel.arburst,
      rd_port_in.arlock   => axi_if_2.read_address_channel.arlock,
      rd_port_in.arcache  => axi_if_2.read_address_channel.arcache,
      rd_port_in.arprot   => axi_if_2.read_address_channel.arprot,
      rd_port_in.arqos    => axi_if_2.read_address_channel.arqos,
      rd_port_in.arregion => axi_if_2.read_address_channel.arregion,
      rd_port_in.aruser   => axi_if_2.read_address_channel.aruser,
      rd_port_in.arvalid  => axi_if_2.read_address_channel.arvalid,
      -- read data channel
      rd_port_in.rready   => axi_if_2.read_data_channel.rready,
      -- Outputs
      -- write address channel
      wr_port_out.awready => axi_if_2.write_address_channel.awready,
      -- write data channel
      wr_port_out.wready  => axi_if_2.write_data_channel.wready,
      -- write response channel
      wr_port_out.bid     => axi_if_2.write_response_channel.bid,
      wr_port_out.bresp   => axi_if_2.write_response_channel.bresp,
      wr_port_out.buser   => axi_if_2.write_response_channel.buser,
      wr_port_out.bvalid  => axi_if_2.write_response_channel.bvalid,
      -- read address channel
      rd_port_out.arready => axi_if_2.read_address_channel.arready,
      -- read data channel
      rd_port_out.rid     => axi_if_2.read_data_channel.rid,
      rd_port_out.rdata   => axi_if_2.read_data_channel.rdata,
      rd_port_out.rresp   => axi_if_2.read_data_channel.rresp,
      rd_port_out.rlast   => axi_if_2.read_data_channel.rlast,
      rd_port_out.ruser   => axi_if_2.read_data_channel.ruser,
      rd_port_out.rvalid  => axi_if_2.read_data_channel.rvalid
    );

  -----------------------------
  -- Instantiate VVCs
  -----------------------------
  i_axi_vvc_1 : entity work.axi_vvc
    generic map(
      GC_ADDR_WIDTH                            => GC_ADDR_WIDTH_1,
      GC_DATA_WIDTH                            => GC_DATA_WIDTH_1,
      GC_ID_WIDTH                              => GC_ID_WIDTH_1,
      GC_USER_WIDTH                            => GC_USER_WIDTH_1,
      GC_INSTANCE_IDX                          => 1,
      GC_AXI_CONFIG                            => C_AXI_CONFIG_1
    )
    port map (
      clk               => clk,
      axi_vvc_master_if => axi_if_1
    );

  i_axi_vvc_2 : entity work.axi_vvc
    generic map(
      GC_ADDR_WIDTH                            => GC_ADDR_WIDTH_2,
      GC_DATA_WIDTH                            => GC_DATA_WIDTH_2,
      GC_ID_WIDTH                              => GC_ID_WIDTH_2,
      GC_USER_WIDTH                            => GC_USER_WIDTH_2,
      GC_INSTANCE_IDX                          => 2,
      GC_AXI_CONFIG                            => C_AXI_CONFIG_2
    )
    port map (
      clk               => clk,
      axi_vvc_master_if => axi_if_2
    );

  -- Clock generator
  clock_generator(clk, C_CLK_PERIOD);

  -- Reset generator
  p_aresetn : process
  begin
    aresetn <= '0';
    wait for C_CLK_PERIOD*3;
    aresetn <= '1';
    wait;
  end process p_aresetn;

end architecture struct;
