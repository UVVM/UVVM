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

library bitvis_vip_avalon_st;
use bitvis_vip_avalon_st.avalon_st_bfm_pkg.all;

--=================================================================================================
-- Test harness entity
--=================================================================================================
entity test_harness is
  generic(
    GC_DATA_WIDTH    : natural := 32;
    GC_CHANNEL_WIDTH : natural := 8;
    GC_ERROR_WIDTH   : natural := 1;
    GC_SYMBOL_WIDTH  : natural := 8;
    GC_EMPTY_WIDTH   : natural := 1
  );
  port(
    signal clk                 : in    std_logic;
    signal areset              : in    std_logic;
    signal avalon_st_master_if : inout t_avalon_st_if(channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                                      data(GC_DATA_WIDTH - 1 downto 0),
                                                      data_error(GC_ERROR_WIDTH - 1 downto 0),
                                                      empty(GC_EMPTY_WIDTH - 1 downto 0));
    signal avalon_st_slave_if  : inout t_avalon_st_if(channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                                      data(GC_DATA_WIDTH - 1 downto 0),
                                                      data_error(GC_ERROR_WIDTH - 1 downto 0),
                                                      empty(GC_EMPTY_WIDTH - 1 downto 0))
  );
end entity;

--=================================================================================================
-- Test harness architectures
--=================================================================================================
architecture struct_bfm of test_harness is
  signal avalon_st_master_if_int : t_avalon_st_if(channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                                  data(GC_DATA_WIDTH - 1 downto 0),
                                                  data_error(GC_ERROR_WIDTH - 1 downto 0),
                                                  empty(GC_EMPTY_WIDTH - 1 downto 0));
  signal avalon_st_slave_if_int  : t_avalon_st_if(channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                                  data(GC_DATA_WIDTH - 1 downto 0),
                                                  data_error(GC_ERROR_WIDTH - 1 downto 0),
                                                  empty(GC_EMPTY_WIDTH - 1 downto 0));
begin
  --------------------------------------------------------------------------------
  -- Instantiate DUT
  --------------------------------------------------------------------------------
  -- Mapping of interface to signals is done to make TB run in Riviera Pro.
  -- Values are not propagated when interface elements are mapped directly
  -- to ports. Riviera-PRO version 2019.10
  avalon_st_master_if_int.data            <= avalon_st_master_if.data;
  avalon_st_master_if_int.channel         <= avalon_st_master_if.channel;
  avalon_st_master_if_int.empty           <= avalon_st_master_if.empty;
  avalon_st_master_if_int.data_error      <= avalon_st_master_if.data_error;
  avalon_st_master_if_int.valid           <= avalon_st_master_if.valid;
  avalon_st_master_if_int.start_of_packet <= avalon_st_master_if.start_of_packet;
  avalon_st_master_if_int.end_of_packet   <= avalon_st_master_if.end_of_packet;
  avalon_st_master_if.ready               <= avalon_st_master_if_int.ready;

  avalon_st_slave_if.data            <= avalon_st_slave_if_int.data;
  avalon_st_slave_if.channel         <= avalon_st_slave_if_int.channel;
  avalon_st_slave_if.empty           <= avalon_st_slave_if_int.empty;
  avalon_st_slave_if.data_error      <= avalon_st_slave_if_int.data_error;
  avalon_st_slave_if.valid           <= avalon_st_slave_if_int.valid;
  avalon_st_slave_if.start_of_packet <= avalon_st_slave_if_int.start_of_packet;
  avalon_st_slave_if.end_of_packet   <= avalon_st_slave_if_int.end_of_packet;
  avalon_st_slave_if_int.ready       <= avalon_st_slave_if.ready;

  i_avalon_st_fifo : entity work.avalon_st_fifo
    generic map(
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_CHANNEL_WIDTH => GC_CHANNEL_WIDTH,
      GC_EMPTY_WIDTH   => GC_EMPTY_WIDTH,
      GC_ERROR_WIDTH   => GC_ERROR_WIDTH,
      GC_FIFO_DEPTH    => 512
    )
    port map(
      clk_i            => clk,
      reset_i          => areset,
      -- Slave stream interface
      slave_data_i     => avalon_st_master_if_int.data,
      slave_channel_i  => avalon_st_master_if_int.channel,
      slave_empty_i    => avalon_st_master_if_int.empty,
      slave_error_i    => avalon_st_master_if_int.data_error,
      slave_valid_i    => avalon_st_master_if_int.valid,
      slave_sop_i      => avalon_st_master_if_int.start_of_packet,
      slave_eop_i      => avalon_st_master_if_int.end_of_packet,
      slave_ready_o    => avalon_st_master_if_int.ready,
      -- Master stream interface
      master_data_o    => avalon_st_slave_if_int.data,
      master_channel_o => avalon_st_slave_if_int.channel,
      master_empty_o   => avalon_st_slave_if_int.empty,
      master_error_o   => avalon_st_slave_if_int.data_error,
      master_valid_o   => avalon_st_slave_if_int.valid,
      master_sop_o     => avalon_st_slave_if_int.start_of_packet,
      master_eop_o     => avalon_st_slave_if_int.end_of_packet,
      master_ready_i   => avalon_st_slave_if_int.ready
    );
end struct_bfm;

architecture struct_vvc of test_harness is
  signal avalon_st_vvc2vvc_if : t_avalon_st_if(channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                               data(GC_DATA_WIDTH - 1 downto 0),
                                               data_error(GC_ERROR_WIDTH - 1 downto 0),
                                               empty(GC_EMPTY_WIDTH - 1 downto 0));
begin
  --------------------------------------------------------------------------------
  -- Instantiate DUT
  --------------------------------------------------------------------------------
  i_avalon_st_fifo : entity work.avalon_st_fifo
    generic map(
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_CHANNEL_WIDTH => GC_CHANNEL_WIDTH,
      GC_EMPTY_WIDTH   => GC_EMPTY_WIDTH,
      GC_ERROR_WIDTH   => GC_ERROR_WIDTH,
      GC_FIFO_DEPTH    => 512
    )
    port map(
      clk_i            => clk,
      reset_i          => areset,
      -- Slave stream interface
      slave_data_i     => avalon_st_master_if.data,
      slave_channel_i  => avalon_st_master_if.channel,
      slave_empty_i    => avalon_st_master_if.empty,
      slave_error_i    => avalon_st_master_if.data_error,
      slave_valid_i    => avalon_st_master_if.valid,
      slave_sop_i      => avalon_st_master_if.start_of_packet,
      slave_eop_i      => avalon_st_master_if.end_of_packet,
      slave_ready_o    => avalon_st_master_if.ready,
      -- Master stream interface
      master_data_o    => avalon_st_slave_if.data,
      master_channel_o => avalon_st_slave_if.channel,
      master_empty_o   => avalon_st_slave_if.empty,
      master_error_o   => avalon_st_slave_if.data_error,
      master_valid_o   => avalon_st_slave_if.valid,
      master_sop_o     => avalon_st_slave_if.start_of_packet,
      master_eop_o     => avalon_st_slave_if.end_of_packet,
      master_ready_i   => avalon_st_slave_if.ready
    );

  --------------------------------------------------------------------------------
  -- Instantiate VVCs
  --------------------------------------------------------------------------------
  i_avalon_st_vvc_master : entity work.avalon_st_vvc
    generic map(
      GC_VVC_IS_MASTER    => true,
      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
      GC_DATA_WIDTH       => GC_DATA_WIDTH,
      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
      GC_EMPTY_WIDTH      => GC_EMPTY_WIDTH,
      GC_INSTANCE_IDX     => 0
    )
    port map(
      clk              => clk,
      avalon_st_vvc_if => avalon_st_master_if
    );

  i_avalon_st_vvc_slave : entity work.avalon_st_vvc
    generic map(
      GC_VVC_IS_MASTER    => false,
      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
      GC_DATA_WIDTH       => GC_DATA_WIDTH,
      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
      GC_EMPTY_WIDTH      => GC_EMPTY_WIDTH,
      GC_INSTANCE_IDX     => 1
    )
    port map(
      clk              => clk,
      avalon_st_vvc_if => avalon_st_slave_if
    );

  i_avalon_st_vvc2vvc_master : entity work.avalon_st_vvc
    generic map(
      GC_VVC_IS_MASTER    => true,
      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
      GC_DATA_WIDTH       => GC_DATA_WIDTH,
      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
      GC_EMPTY_WIDTH      => GC_EMPTY_WIDTH,
      GC_INSTANCE_IDX     => 2
    )
    port map(
      clk              => clk,
      avalon_st_vvc_if => avalon_st_vvc2vvc_if
    );

  i_avalon_st_vvc2vcc_slave : entity work.avalon_st_vvc
    generic map(
      GC_VVC_IS_MASTER    => false,
      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
      GC_DATA_WIDTH       => GC_DATA_WIDTH,
      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
      GC_EMPTY_WIDTH      => GC_EMPTY_WIDTH,
      GC_INSTANCE_IDX     => 3
    )
    port map(
      clk              => clk,
      avalon_st_vvc_if => avalon_st_vvc2vvc_if
    );
end struct_vvc;
