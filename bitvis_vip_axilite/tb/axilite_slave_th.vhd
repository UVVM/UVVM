--================================================================================================================================
-- Copyright 2025 UVVM
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_clock_generator;
use work.axilite_bfm_pkg.all;

entity axi_lite_bfm_th is
end entity axi_lite_bfm_th;

architecture struct of axi_lite_bfm_th is

  signal clk  : std_logic := '0';
  signal arst : std_logic := '0';

  constant C_CLK_PERIOD : time    := 10 ns; -- 100 MHz clock
  constant C_CLOCK_GEN  : natural := 1;

  constant ADDR_WIDTH : natural := 32;
  constant DATA_WIDTH : natural := 32;

  ------------------------------------------------------------------------------
  -- Create a common AXI‑Lite interface signal. We initialize it using the master’s
  -- helper function (assumed to be compatible with the slave’s view).
  ------------------------------------------------------------------------------
  signal axi_if : t_axilite_if(write_address_channel(awaddr(ADDR_WIDTH - 1 downto 0)),
  write_data_channel(wdata(DATA_WIDTH - 1 downto 0),
                     wstrb((DATA_WIDTH / 8) - 1 downto 0)),
  read_address_channel(araddr(ADDR_WIDTH - 1 downto 0)),
  read_data_channel(rdata(DATA_WIDTH - 1 downto 0))) := init_axilite_if_signals(ADDR_WIDTH, DATA_WIDTH);

begin

  ------------------------------------------------------------------------------
  -- Instantiate the UVVM engine.
  ------------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------------------------------------
  -- Clock Generator VVC.
  ------------------------------------------------------------------------------
  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => C_CLOCK_GEN,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => C_CLK_PERIOD,
      GC_CLOCK_HIGH_TIME => C_CLK_PERIOD / 2
    )
    port map(
      clk => clk
    );

  ------------------------------------------------------------------------------
  -- Reset Generator Process: Assert reset for 5 clock cycles.
  ------------------------------------------------------------------------------
  p_arst : process
  begin
    arst <= '1';
    wait for 5 * C_CLK_PERIOD;
    arst <= '0';
    wait;
  end process p_arst;

end architecture struct;
