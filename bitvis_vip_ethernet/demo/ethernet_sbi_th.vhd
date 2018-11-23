--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

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
context bitvis_vip_sbi.vvc_context;

library bitvis_vip_ethernet;
context bitvis_vip_ethernet.hvvc_context;
use bitvis_vip_ethernet.ethernet_sbi_pkg.all;

--=================================================================================================
entity sbi_test_harness is
  generic(
    GC_CLK_PERIOD : time
  );
end entity sbi_test_harness;


--=================================================================================================
--=================================================================================================

architecture struct of sbi_test_harness is

  signal i1_sbi_if : t_sbi_if(addr(C_ADDR_WIDTH_1-1 downto 0), wdata(C_DATA_WIDTH_1-1 downto 0), rdata(C_DATA_WIDTH_1-1 downto 0));
  signal i2_sbi_if : t_sbi_if(addr(C_ADDR_WIDTH_2-1 downto 0), wdata(C_DATA_WIDTH_2-1 downto 0), rdata(C_DATA_WIDTH_2-1 downto 0));

  signal clk       : std_logic;

  constant C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY : t_dut_if_field_config_direction_array(TRANSMIT to RECEIVE)(0 to 0) :=
   (TRANSMIT => (0 => (dut_address => to_unsigned(C_ADDR_FIFO_PUT, 8), dut_address_increment => 0, data_width => 8, field_description => "transmitter field config")),
    RECEIVE  => (0 => (dut_address => to_unsigned(C_ADDR_FIFO_GET, 8), dut_address_increment => 0, data_width => 8, field_description => "receiver field config   "))
    );

begin

  -- Clock generator
  p_clk : clock_generator(clk, GC_CLK_PERIOD);

  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX        => 1,
      GC_INTERFACE           => SBI,
      GC_VVC_INSTANCE_IDX    => 1,
      GC_DUT_IF_FIELD_CONFIG => C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY
    );

  i2_ethernet_vvc : entity bitvis_vip_ethernet.ethernet_vvc
    generic map(
      GC_INSTANCE_IDX        => 2,
      GC_INTERFACE           => SBI,
      GC_VVC_INSTANCE_IDX    => 2,
      GC_DUT_IF_FIELD_CONFIG => C_DUT_IF_FIELD_CONFIG_DIRECTION_ARRAY
    );


  i1_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH                         => 8,
      GC_DATA_WIDTH                         => 8,
      GC_INSTANCE_IDX                       => 1,
      GC_SBI_CONFIG                         => C_SBI_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                => C_MAX_PACKET_LENGTH+50,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_MAX_PACKET_LENGTH+1,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => WARNING
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => i1_sbi_if
    );

  i2_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH                         => 8,
      GC_DATA_WIDTH                         => 8,
      GC_INSTANCE_IDX                       => 2,
      GC_SBI_CONFIG                         => C_SBI_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                => C_MAX_PACKET_LENGTH+50,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_MAX_PACKET_LENGTH+1,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => WARNING
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => i2_sbi_if
    );

  i1_sbi_fifo : entity  work.sbi_fifo
    port map(
      clk      => clk,
      sbi_if_1 => i1_sbi_if,
      sbi_if_2 => i2_sbi_if
    );

end struct;