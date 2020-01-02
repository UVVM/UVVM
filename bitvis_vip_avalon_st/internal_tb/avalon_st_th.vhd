--================================================================================================================================
-- Copyright (c) 2019 by Bitvis AS.  All rights reserved.
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
    GC_SYMBOL_WIDTH  : natural := 8
  );
  port(
    signal clk       : in std_logic;
    signal areset    : in std_logic;
    signal avalon_st_master_if : inout t_avalon_st_if(channel(GC_CHANNEL_WIDTH-1 downto 0),
                                                      data(GC_DATA_WIDTH-1 downto 0),
                                                      data_error(GC_ERROR_WIDTH-1 downto 0),
                                                      empty(log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH)-1 downto 0));
    signal avalon_st_slave_if  : inout t_avalon_st_if(channel(GC_CHANNEL_WIDTH-1 downto 0),
                                                      data(GC_DATA_WIDTH-1 downto 0),
                                                      data_error(GC_ERROR_WIDTH-1 downto 0),
                                                      empty(log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH)-1 downto 0))
  );
end entity;

--=================================================================================================
-- Test harness architectures
--=================================================================================================
architecture struct_simple of test_harness is
begin
  --------------------------------------------------------------------------------
  -- Instantiate DUT
  --------------------------------------------------------------------------------
  i_avalon_st_fifo : entity work.avalon_st_fifo
    generic map (
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_CHANNEL_WIDTH => GC_CHANNEL_WIDTH,
      GC_EMPTY_WIDTH   => log2(GC_DATA_WIDTH/GC_SYMBOL_WIDTH),
      GC_ERROR_WIDTH   => GC_ERROR_WIDTH,
      GC_FIFO_DEPTH    => 512
    )
    port map (
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
end struct_simple;