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

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

--=================================================================================================
entity test_harness is
  generic(
    GC_CLK_PERIOD   : time;
    GC_ADDR_WIDTH_1 : integer := 8;
    GC_DATA_WIDTH_1 : integer := 8;
    GC_ADDR_WIDTH_2 : integer := 8;
    GC_DATA_WIDTH_2 : integer := 8
  );
  port(
    sbi_if_1 : inout t_sbi_if(addr(GC_ADDR_WIDTH_1 - 1 downto 0), wdata(GC_DATA_WIDTH_1 - 1 downto 0), rdata(GC_DATA_WIDTH_1 - 1 downto 0));
    sbi_if_2 : inout t_sbi_if(addr(GC_ADDR_WIDTH_2 - 1 downto 0), wdata(GC_DATA_WIDTH_2 - 1 downto 0), rdata(GC_DATA_WIDTH_2 - 1 downto 0));
    clk      : out   std_logic
  );
end entity test_harness;

--=================================================================================================
--=================================================================================================

architecture struct of test_harness is

begin

  -----------------------------
  -- INstantiate DUT
  -----------------------------
  i1_sbi_fifo : entity work.sbi_fifo
    generic map(
      GC_ADDR_WIDTH_1 => GC_ADDR_WIDTH_1,
      GC_DATA_WIDTH_1 => GC_DATA_WIDTH_1,
      GC_ADDR_WIDTH_2 => GC_ADDR_WIDTH_2,
      GC_DATA_WIDTH_2 => GC_DATA_WIDTH_2
    )
    port map(
      clk      => clk,
      sbi_if_1 => sbi_if_1,
      sbi_if_2 => sbi_if_2
    );

  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_sbi_vvc : entity work.sbi_vvc
    generic map(
      GC_ADDR_WIDTH                         => GC_ADDR_WIDTH_1,
      GC_DATA_WIDTH                         => GC_DATA_WIDTH_1,
      GC_INSTANCE_IDX                       => 1,
      GC_SBI_CONFIG                         => C_SBI_BFM_CONFIG_DEFAULT,
      GC_CMD_QUEUE_COUNT_MAX                => 500,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => 450,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => WARNING
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => sbi_if_1
    );

  i2_sbi_vvc : entity work.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => GC_ADDR_WIDTH_2,
      GC_DATA_WIDTH   => GC_DATA_WIDTH_2,
      GC_INSTANCE_IDX => 2
    )
    port map(
      clk               => clk,
      sbi_vvc_master_if => sbi_if_2
    );

  p_clk : clock_generator(clk, GC_CLK_PERIOD);

end struct;

