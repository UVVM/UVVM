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
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_vip_axistream;
use bitvis_vip_axistream.axistream_bfm_pkg.all;

--=================================================================================================
entity axistream_th is
  generic(
    constant GC_DATA_WIDTH     : natural := 32;
    constant GC_USER_WIDTH     : natural := 1;
    constant GC_ID_WIDTH       : natural := 1;
    constant GC_DEST_WIDTH     : natural := 1;
    constant GC_DUT_FIFO_DEPTH : natural := 4;
    constant GC_INCLUDE_TUSER  : boolean := true -- If tuser is used in AXI interface
  );
  port(
    signal clk                     : in    std_logic;
    signal areset                  : in    std_logic;
    -- BFM
    signal axistream_if_m_VVC2FIFO : inout t_axistream_if(tdata(GC_DATA_WIDTH - 1 downto 0),
                                                          tkeep((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                          tuser(GC_USER_WIDTH - 1 downto 0),
                                                          tstrb((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                          tid(GC_ID_WIDTH - 1 downto 0),
                                                          tdest(GC_DEST_WIDTH - 1 downto 0)
                                                         );
    signal axistream_if_s_FIFO2VVC : inout t_axistream_if(tdata(GC_DATA_WIDTH - 1 downto 0),
                                                          tkeep((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                          tuser(GC_USER_WIDTH - 1 downto 0),
                                                          tstrb((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                          tid(GC_ID_WIDTH - 1 downto 0),
                                                          tdest(GC_DEST_WIDTH - 1 downto 0)
                                                         )
  );

end entity axistream_th;

--=================================================================================================
architecture struct_bfm of axistream_th is

  signal s_axis_tready : std_logic;
  signal s_axis_tvalid : std_logic;
  signal s_axis_tdata  : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal s_axis_tuser  : std_logic_vector(GC_USER_WIDTH - 1 downto 0);
  signal s_axis_tkeep  : std_logic_vector(GC_DATA_WIDTH / 8 - 1 downto 0);
  signal s_axis_tlast  : std_logic;

  signal m_axis_tready : std_logic;
  signal m_axis_tvalid : std_logic;
  signal m_axis_tdata  : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal m_axis_tuser  : std_logic_vector(GC_USER_WIDTH - 1 downto 0);
  signal m_axis_tkeep  : std_logic_vector(GC_DATA_WIDTH / 8 - 1 downto 0);
  signal m_axis_tlast  : std_logic;

begin

  -- Mapping of interface to signals is done to make TB run in Riviera Pro.
  -- Values are not propagated when interface elements are mapped directly
  -- to ports. Riviera-PRO version 2018.10.137.7135
  axistream_if_m_VVC2FIFO.tdata  <= (others => 'Z');
  axistream_if_m_VVC2FIFO.tkeep  <= (others => 'Z');
  axistream_if_m_VVC2FIFO.tuser  <= (others => 'Z');
  axistream_if_m_VVC2FIFO.tvalid <= 'Z';
  axistream_if_m_VVC2FIFO.tlast  <= 'Z';
  axistream_if_m_VVC2FIFO.tready <= s_axis_tready;
  axistream_if_m_VVC2FIFO.tstrb  <= (others => 'Z');
  axistream_if_m_VVC2FIFO.tid    <= (others => 'Z');
  axistream_if_m_VVC2FIFO.tdest  <= (others => 'Z');
  s_axis_tvalid                  <= axistream_if_m_VVC2FIFO.tvalid;
  s_axis_tdata                   <= axistream_if_m_VVC2FIFO.tdata;
  s_axis_tuser                   <= axistream_if_m_VVC2FIFO.tuser;
  s_axis_tkeep                   <= axistream_if_m_VVC2FIFO.tkeep;
  s_axis_tlast                   <= axistream_if_m_VVC2FIFO.tlast;

  m_axis_tready                  <= axistream_if_s_FIFO2VVC.tready;
  axistream_if_s_FIFO2VVC.tdata  <= m_axis_tdata;
  axistream_if_s_FIFO2VVC.tkeep  <= m_axis_tkeep;
  axistream_if_s_FIFO2VVC.tuser  <= m_axis_tuser;
  axistream_if_s_FIFO2VVC.tvalid <= m_axis_tvalid;
  axistream_if_s_FIFO2VVC.tlast  <= m_axis_tlast;
  axistream_if_s_FIFO2VVC.tready <= 'Z';
  axistream_if_s_FIFO2VVC.tstrb  <= (others => 'Z');
  axistream_if_s_FIFO2VVC.tid    <= (others => 'Z');
  axistream_if_s_FIFO2VVC.tdest  <= (others => 'Z');

  -----------------------------
  -- Instantiate a DUT model
  -----------------------------
  i_axis_fifo : entity work.axis_fifo
    generic map(
      GC_DATA_WIDTH => GC_DATA_WIDTH,
      GC_USER_WIDTH => GC_USER_WIDTH,
      GC_FIFO_DEPTH => GC_DUT_FIFO_DEPTH
    )
    PORT MAP(
      rst           => areset,
      clk           => clk,
      s_axis_tready => s_axis_tready,
      s_axis_tvalid => s_axis_tvalid,
      s_axis_tdata  => s_axis_tdata,
      s_axis_tuser  => s_axis_tuser,
      s_axis_tkeep  => s_axis_tkeep,
      s_axis_tlast  => s_axis_tlast,
      m_axis_tready => m_axis_tready,
      m_axis_tvalid => m_axis_tvalid,
      m_axis_tdata  => m_axis_tdata,
      m_axis_tuser  => m_axis_tuser,
      m_axis_tkeep  => m_axis_tkeep,
      m_axis_tlast  => m_axis_tlast,
      empty         => open
    );

end architecture struct_bfm;

--=================================================================================================
architecture struct_vvc of axistream_th is

  signal axistream_if_m_VVC2VVC : t_axistream_if(tdata(GC_DATA_WIDTH - 1 downto 0),
                                                 tkeep((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                 tuser(GC_USER_WIDTH - 1 downto 0),
                                                 tstrb((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                 tid(GC_ID_WIDTH - 1 downto 0),
                                                 tdest(GC_DEST_WIDTH - 1 downto 0)
                                                );
  signal dut_m_axis_tstrb : std_logic_vector((GC_DATA_WIDTH / 8) - 1 downto 0);
  signal dut_m_axis_tid   : std_logic_vector(GC_ID_WIDTH - 1 downto 0);
  signal dut_m_axis_tdest : std_logic_vector(GC_DEST_WIDTH - 1 downto 0);

begin
  -----------------------------
  -- Instantiate a DUT model
  -----------------------------
  i_axis_fifo : entity work.axis_fifo
    generic map(
      GC_DATA_WIDTH => GC_DATA_WIDTH,
      GC_USER_WIDTH => GC_USER_WIDTH,
      GC_FIFO_DEPTH => GC_DUT_FIFO_DEPTH
    )
    PORT MAP(
      rst           => areset,
      clk           => clk,
      s_axis_tready => axistream_if_m_VVC2FIFO.tready,
      s_axis_tvalid => axistream_if_m_VVC2FIFO.tvalid,
      s_axis_tdata  => axistream_if_m_VVC2FIFO.tdata,
      s_axis_tuser  => axistream_if_m_VVC2FIFO.tuser,
      s_axis_tkeep  => axistream_if_m_VVC2FIFO.tkeep,
      s_axis_tlast  => axistream_if_m_VVC2FIFO.tlast,
      m_axis_tready => axistream_if_s_FIFO2VVC.tready,
      m_axis_tvalid => axistream_if_s_FIFO2VVC.tvalid,
      m_axis_tdata  => axistream_if_s_FIFO2VVC.tdata,
      m_axis_tuser  => axistream_if_s_FIFO2VVC.tuser,
      m_axis_tkeep  => axistream_if_s_FIFO2VVC.tkeep,
      m_axis_tlast  => axistream_if_s_FIFO2VVC.tlast,
      empty         => open
    );

  -- Use non-record signals to be able to force them from the tb
  dut_m_axis_tstrb <= (others => '0');
  dut_m_axis_tid   <= (others => '0');
  dut_m_axis_tdest <= (others => '0');
  axistream_if_s_FIFO2VVC.tstrb <= dut_m_axis_tstrb;
  axistream_if_s_FIFO2VVC.tid   <= dut_m_axis_tid;
  axistream_if_s_FIFO2VVC.tdest <= dut_m_axis_tdest;

  -----------------------------
  -- vvc/executors
  -----------------------------
  -- master vvc that transmit to FIFO
  i_axistream_vvc_master_VVC2FIFO : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => true,
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_USER_WIDTH    => GC_USER_WIDTH,
      GC_ID_WIDTH      => GC_ID_WIDTH,
      GC_DEST_WIDTH    => GC_DEST_WIDTH,
      GC_INSTANCE_IDX  => 0
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_m_VVC2FIFO
    );

  -- slave vvc that receive from FIFO
  i_axistream_vvc_slave_FIFO2VVC : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => false,
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_USER_WIDTH    => GC_USER_WIDTH,
      GC_ID_WIDTH      => GC_ID_WIDTH,
      GC_DEST_WIDTH    => GC_DEST_WIDTH,
      GC_INSTANCE_IDX  => 1
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_s_FIFO2VVC
    );

  --------------------------------------------------------------------

  -- master vvc that transmit directly to Slave VVC
  i_axistream_vvc_master_VVC2VVC : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => true,
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_USER_WIDTH    => GC_USER_WIDTH,
      GC_ID_WIDTH      => GC_ID_WIDTH,
      GC_DEST_WIDTH    => GC_DEST_WIDTH,
      GC_INSTANCE_IDX  => 2
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_m_VVC2VVC
    );

  -- slave vvc that receive directly from Master VVC
  i_axistream_vvc_slave_VVC2VVC : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => false,
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_USER_WIDTH    => GC_USER_WIDTH,
      GC_ID_WIDTH      => GC_ID_WIDTH,
      GC_DEST_WIDTH    => GC_DEST_WIDTH,
      GC_INSTANCE_IDX  => 3
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_m_VVC2VVC
    );

end architecture struct_vvc;

--=================================================================================================
architecture struct_multiple_vvc of axistream_th is

begin
  -----------------------------
  -- Multiple VVCs just to test await_completion(ANY_OF)
  -----------------------------
  gen_axistream_vvc_master : for i in 0 to 7 generate
    signal axistream_if_m_local : t_axistream_if(tdata(GC_DATA_WIDTH - 1 downto 0),
                                                 tkeep((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                 tuser(GC_USER_WIDTH - 1 downto 0),
                                                 tstrb((GC_DATA_WIDTH / 8) - 1 downto 0),
                                                 tid(GC_ID_WIDTH - 1 downto 0),
                                                 tdest(GC_DEST_WIDTH - 1 downto 0)
                                                );
  begin
    axistream_if_m_local.tready <= '1';

    i_axistream_vvc_master : entity work.axistream_vvc
      generic map(
        GC_VVC_IS_MASTER => true,
        GC_DATA_WIDTH    => GC_DATA_WIDTH,
        GC_USER_WIDTH    => GC_USER_WIDTH,
        GC_ID_WIDTH      => GC_ID_WIDTH,
        GC_DEST_WIDTH    => GC_DEST_WIDTH,
        GC_INSTANCE_IDX  => i
      )
      port map(
        clk              => clk,
        axistream_vvc_if => axistream_if_m_local
      );
  end generate gen_axistream_vvc_master;

end architecture struct_multiple_vvc;

--=================================================================================================
architecture struct_width_vvc of axistream_th is

  constant C_DATA_WIDTH_1 : natural := 32;
  constant C_DATA_WIDTH_2 : natural := 64;
  constant C_USER_WIDTH   : natural := 1;
  constant C_ID_WIDTH     : natural := 1;
  constant C_DEST_WIDTH   : natural := 1;

  signal axistream_if_32b : t_axistream_if(tdata(C_DATA_WIDTH_1 - 1 downto 0),
                                           tkeep((C_DATA_WIDTH_1 / 8) - 1 downto 0),
                                           tuser(C_USER_WIDTH - 1 downto 0),
                                           tstrb((C_DATA_WIDTH_1 / 8) - 1 downto 0),
                                           tid(C_ID_WIDTH - 1 downto 0),
                                           tdest(C_DEST_WIDTH - 1 downto 0)
                                          );
  signal axistream_if_64b : t_axistream_if(tdata(C_DATA_WIDTH_2 - 1 downto 0),
                                           tkeep((C_DATA_WIDTH_2 / 8) - 1 downto 0),
                                           tuser(C_USER_WIDTH - 1 downto 0),
                                           tstrb((C_DATA_WIDTH_2 / 8) - 1 downto 0),
                                           tid(C_ID_WIDTH - 1 downto 0),
                                           tdest(C_DEST_WIDTH - 1 downto 0)
                                          );

begin

  axistream_if_m_VVC2FIFO.tvalid <= '0';
  axistream_if_m_VVC2FIFO.tlast  <= '0';
  axistream_if_m_VVC2FIFO.tready <= '0';
  axistream_if_m_VVC2FIFO.tdata  <= (others => '0');
  axistream_if_m_VVC2FIFO.tuser  <= (others => '0');
  axistream_if_m_VVC2FIFO.tkeep  <= (others => '0');
  axistream_if_m_VVC2FIFO.tstrb  <= (others => '0');
  axistream_if_m_VVC2FIFO.tid    <= (others => '0');
  axistream_if_m_VVC2FIFO.tdest  <= (others => '0');

  axistream_if_s_FIFO2VVC.tvalid <= '0';
  axistream_if_s_FIFO2VVC.tlast  <= '0';
  axistream_if_s_FIFO2VVC.tready <= '0';
  axistream_if_s_FIFO2VVC.tdata  <= (others => '0');
  axistream_if_s_FIFO2VVC.tuser  <= (others => '0');
  axistream_if_s_FIFO2VVC.tkeep  <= (others => '0');
  axistream_if_s_FIFO2VVC.tstrb  <= (others => '0');
  axistream_if_s_FIFO2VVC.tid    <= (others => '0');
  axistream_if_s_FIFO2VVC.tdest  <= (others => '0');

  i_axistream_vvc_master_32b : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => true,
      GC_DATA_WIDTH    => C_DATA_WIDTH_1,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 0
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_32b
    );

  i_axistream_vvc_slave_32b : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => false,
      GC_DATA_WIDTH    => C_DATA_WIDTH_1,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 1
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_32b
    );

  i_axistream_vvc_master_64b : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => true,
      GC_DATA_WIDTH    => C_DATA_WIDTH_2,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 2
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_64b
    );

  i_axistream_vvc_slave_64b : entity work.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => false,
      GC_DATA_WIDTH    => C_DATA_WIDTH_2,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 3
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_64b
    );

end architecture struct_width_vvc;
