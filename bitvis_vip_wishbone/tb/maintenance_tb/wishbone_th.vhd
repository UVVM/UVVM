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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_wishbone;
use bitvis_vip_wishbone.wishbone_bfm_pkg.all;

entity wishbone_th is
  generic(
    GC_CLK_PERIOD : time;
    GC_DATA_WIDTH : integer
  );
end entity wishbone_th;

architecture struct of wishbone_th is

  constant C_ADDR_WIDTH : natural := 2;

  signal clk : std_logic;
  signal rst : std_logic := '1';

  signal wishbone_vvc_master_if : t_wishbone_if(adr_o(C_ADDR_WIDTH - 1 downto 0), dat_o(GC_DATA_WIDTH - 1 downto 0), dat_i(GC_DATA_WIDTH - 1 downto 0));

begin

  p_clk : clock_generator(clk, GC_CLK_PERIOD);

  p_rst : rst <= '0' after GC_CLK_PERIOD * 2;

  i_dut : entity work.wishbone_fifo
    generic map (
      GC_DATA_WIDTH => GC_DATA_WIDTH
    )
    port map (
      clk_i => clk,
      rst_i => rst,
      -- Inputs
      cyc_i => wishbone_vvc_master_if.cyc_o,
      stb_i => wishbone_vvc_master_if.stb_o,
      we_i  => wishbone_vvc_master_if.we_o ,
      adr_i => wishbone_vvc_master_if.adr_o,
      dat_i => wishbone_vvc_master_if.dat_o,
      -- Outputs
      dat_o => wishbone_vvc_master_if.dat_i,
      ack_o => wishbone_vvc_master_if.ack_i
    );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine(func);

  i_wishbone_vvc : entity work.wishbone_vvc
    generic map (
      GC_ADDR_WIDTH   => C_ADDR_WIDTH,
      GC_DATA_WIDTH   => GC_DATA_WIDTH,
      GC_INSTANCE_IDX => 0
    )
    port map (
      clk                    => clk,
      wishbone_vvc_master_if => wishbone_vvc_master_if
    );

end architecture struct;
