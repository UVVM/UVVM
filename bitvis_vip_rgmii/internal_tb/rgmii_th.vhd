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


--architecture struct_vvc of test_harness is
--  signal avalon_st_vvc2vvc_if : t_avalon_st_if(channel(GC_CHANNEL_WIDTH-1 downto 0),
--                                               data(GC_DATA_WIDTH-1 downto 0),
--                                               data_error(GC_ERROR_WIDTH-1 downto 0),
--                                               empty(log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH)-1 downto 0));
--begin
--  --------------------------------------------------------------------------------
--  -- Instantiate DUT
--  --------------------------------------------------------------------------------
--  i_avalon_st_fifo : entity work.avalon_st_fifo
--    generic map (
--      GC_DATA_WIDTH    => GC_DATA_WIDTH,
--      GC_CHANNEL_WIDTH => GC_CHANNEL_WIDTH,
--      GC_EMPTY_WIDTH   => log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH),
--      GC_ERROR_WIDTH   => GC_ERROR_WIDTH,
--      GC_FIFO_DEPTH    => 512
--    )
--    port map (
--      clk_i            => clk,
--      reset_i          => areset,
--      -- Slave stream interface
--      slave_data_i     => avalon_st_master_if.data,
--      slave_channel_i  => avalon_st_master_if.channel,
--      slave_empty_i    => avalon_st_master_if.empty,
--      slave_error_i    => avalon_st_master_if.data_error,
--      slave_valid_i    => avalon_st_master_if.valid,
--      slave_sop_i      => avalon_st_master_if.start_of_packet,
--      slave_eop_i      => avalon_st_master_if.end_of_packet,
--      slave_ready_o    => avalon_st_master_if.ready,
--      -- Master stream interface
--      master_data_o    => avalon_st_slave_if.data,
--      master_channel_o => avalon_st_slave_if.channel,
--      master_empty_o   => avalon_st_slave_if.empty,
--      master_error_o   => avalon_st_slave_if.data_error,
--      master_valid_o   => avalon_st_slave_if.valid,
--      master_sop_o     => avalon_st_slave_if.start_of_packet,
--      master_eop_o     => avalon_st_slave_if.end_of_packet,
--      master_ready_i   => avalon_st_slave_if.ready
--    );

--  --------------------------------------------------------------------------------
--  -- Instantiate VVCs
--  --------------------------------------------------------------------------------
--  i_avalon_st_vvc_master : entity work.avalon_st_vvc
--    generic map(
--      GC_VVC_IS_MASTER    => true,
--      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
--      GC_DATA_WIDTH       => GC_DATA_WIDTH,
--      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
--      GC_EMPTY_WIDTH      => log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH),
--      GC_INSTANCE_IDX     => 0
--      )
--    port map(
--      clk               => clk,
--      avalon_st_vvc_if  => avalon_st_master_if
--    );

--  i_avalon_st_vvc_slave : entity work.avalon_st_vvc
--    generic map(
--      GC_VVC_IS_MASTER    => false,
--      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
--      GC_DATA_WIDTH       => GC_DATA_WIDTH,
--      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
--      GC_EMPTY_WIDTH      => log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH),
--      GC_INSTANCE_IDX     => 1
--      )
--    port map(
--      clk               => clk,
--      avalon_st_vvc_if  => avalon_st_slave_if
--    );

--  i_avalon_st_vvc2vvc_master : entity work.avalon_st_vvc
--    generic map(
--      GC_VVC_IS_MASTER    => true,
--      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
--      GC_DATA_WIDTH       => GC_DATA_WIDTH,
--      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
--      GC_EMPTY_WIDTH      => log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH),
--      GC_INSTANCE_IDX     => 2
--      )
--    port map(
--      clk               => clk,
--      avalon_st_vvc_if  => avalon_st_vvc2vvc_if
--    );

--  i_avalon_st_vvc2vcc_slave : entity work.avalon_st_vvc
--    generic map(
--      GC_VVC_IS_MASTER    => false,
--      GC_CHANNEL_WIDTH    => GC_CHANNEL_WIDTH,
--      GC_DATA_WIDTH       => GC_DATA_WIDTH,
--      GC_DATA_ERROR_WIDTH => GC_ERROR_WIDTH,
--      GC_EMPTY_WIDTH      => log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH),
--      GC_INSTANCE_IDX     => 3
--      )
--    port map(
--      clk               => clk,
--      avalon_st_vvc_if  => avalon_st_vvc2vvc_if
--    );
--end struct_vvc;