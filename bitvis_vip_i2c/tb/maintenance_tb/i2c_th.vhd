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

library uvvm_util;
context uvvm_util.uvvm_util_context;

-- Include Verification IPs
library bitvis_vip_i2c;
use bitvis_vip_i2c.i2c_bfm_pkg.all;

library bitvis_vip_wishbone;
use bitvis_vip_wishbone.wishbone_bfm_pkg.all;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

--=================================================================================================
entity i2c_th is
  generic(
    GC_CLK_PERIOD                 : time;
    GC_WISHBONE_DATA_WIDTH        : natural;
    GC_WISHBONE_ADDR_WIDTH        : natural;
    GC_SBI_DATA_WIDTH             : natural;
    GC_SBI_ADDR_WIDTH             : natural;
    GC_I2C_SLAVE_DUT_ADDR_1       : unsigned(6 downto 0);
    GC_I2C_SLAVE_DUT_ADDR_2       : unsigned(6 downto 0);
    GC_I2C_SLAVE_DUT_ADDR_3       : unsigned(6 downto 0);
    GC_I2C_SLAVE_DUT_ADDR_4       : unsigned(6 downto 0);
    GC_I2C_BFM_CONFIG_7_BIT_ADDR  : t_i2c_bfm_config;
    GC_I2C_BFM_CONFIG_10_BIT_ADDR : t_i2c_bfm_config;
    GC_WISHBONE_MASTER_BFM_CONFIG : t_wishbone_bfm_config;
    GC_SBI_BFM_CONFIG             : t_sbi_bfm_config
  );
  port(
    arst : in std_logic
  );
end entity i2c_th;

--=================================================================================================
--=================================================================================================

architecture struct of i2c_th is

  signal clk : std_logic;               -- 10 ns period

  -- component generics
  constant C_CMD_QUEUE_COUNT_MAX                : natural       := 1000;
  constant C_CMD_QUEUE_COUNT_THRESHOLD          : natural       := 950;
  constant C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level := WARNING;

  -- component ports
  signal i2c_vvc_if_1     : t_i2c_if;
  signal i2c_vvc_if_1_sda : std_logic;
  signal i2c_vvc_if_1_scl : std_logic;
  signal i2c_vvc_if_2     : t_i2c_if;
  signal wishbone_vvc_if  : t_wishbone_if(adr_o(GC_WISHBONE_ADDR_WIDTH - 1 downto 0), dat_o(GC_WISHBONE_DATA_WIDTH - 1 downto 0), dat_i(GC_WISHBONE_DATA_WIDTH - 1 downto 0));
  signal sbi_vvc_if       : t_sbi_if(addr(GC_SBI_ADDR_WIDTH - 1 downto 0), wdata(GC_SBI_DATA_WIDTH - 1 downto 0), rdata(GC_SBI_DATA_WIDTH - 1 downto 0));

  signal sbi_rdata_slave_dut_1 : std_logic_vector(7 downto 0);
  signal sbi_ready_slave_dut_1 : std_logic;
  signal sbi_rdata_slave_dut_2 : std_logic_vector(7 downto 0);
  signal sbi_ready_slave_dut_2 : std_logic;
  signal sbi_rdata_slave_dut_3 : std_logic_vector(7 downto 0);
  signal sbi_ready_slave_dut_3 : std_logic;
  signal sbi_rdata_slave_dut_4 : std_logic_vector(7 downto 0);
  signal sbi_ready_slave_dut_4 : std_logic;

begin

  sbi_vvc_if.rdata <= sbi_rdata_slave_dut_1 or sbi_rdata_slave_dut_2 or sbi_rdata_slave_dut_3 or sbi_rdata_slave_dut_4;

  sbi_vvc_if.ready <= sbi_ready_slave_dut_1 or sbi_ready_slave_dut_2 or sbi_ready_slave_dut_3 or sbi_ready_slave_dut_4;

  -- pull ups on sda and scl
  -- Use non-record signals to be able to force them from the tb
  i2c_vvc_if_1_sda <= 'H';
  i2c_vvc_if_1_scl <= 'H';
  i2c_vvc_if_1.sda <= i2c_vvc_if_1_sda;
  i2c_vvc_if_1.scl <= i2c_vvc_if_1_scl;

  i2c_vvc_if_2.sda <= 'H';
  i2c_vvc_if_2.scl <= 'H';

  -- component instantiations
  i_i2c_master_vvc : entity work.i2c_vvc
    generic map(
      GC_INSTANCE_IDX                       => 0,
      GC_MASTER_MODE                        => true,
      GC_I2C_CONFIG                         => GC_I2C_BFM_CONFIG_7_BIT_ADDR,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      i2c_vvc_if => i2c_vvc_if_1);

  i_i2c_slave_vvc_1 : entity work.i2c_vvc
    generic map(
      GC_INSTANCE_IDX                       => 1,
      GC_MASTER_MODE                        => false,
      GC_I2C_CONFIG                         => GC_I2C_BFM_CONFIG_7_BIT_ADDR,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      i2c_vvc_if => i2c_vvc_if_1);

  i_wishbone_master_vvc : entity bitvis_vip_wishbone.wishbone_vvc
    generic map(
      GC_ADDR_WIDTH                         => GC_WISHBONE_ADDR_WIDTH,
      GC_DATA_WIDTH                         => GC_WISHBONE_DATA_WIDTH,
      GC_INSTANCE_IDX                       => 0,
      GC_WISHBONE_BFM_CONFIG                => GC_WISHBONE_MASTER_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      clk                    => clk,
      wishbone_vvc_master_if => wishbone_vvc_if);

  i_i2c_master_dut : entity work.i2c_master_dut
    generic map(
      GC_WISHBONE_DATA_WIDTH => GC_WISHBONE_DATA_WIDTH,
      GC_WISHBONE_ADDR_WIDTH => GC_WISHBONE_ADDR_WIDTH
    )
    port map(
      -- wishbone
      clk        => clk,
      arst       => arst,
      -- wishbone_vvc_if  => wishbone_vvc_if,
      adr_i      => wishbone_vvc_if.adr_o,
      dat_i      => wishbone_vvc_if.dat_o,
      dat_o      => wishbone_vvc_if.dat_i,
      we_i       => wishbone_vvc_if.we_o,
      stb_i      => wishbone_vvc_if.stb_o,
      cyc_i      => wishbone_vvc_if.cyc_o,
      ack_o      => wishbone_vvc_if.ack_i,
      wb_inta_o  => open,               -- What does this do? Interrupt request output signal. Not in the standard...
      -- i2c
      i2c_vvc_if => i2c_vvc_if_2
    );

  i_i2c_slave_vvc_2 : entity work.i2c_vvc
    generic map(
      GC_INSTANCE_IDX                       => 2,
      GC_MASTER_MODE                        => false,
      GC_I2C_CONFIG                         => GC_I2C_BFM_CONFIG_7_BIT_ADDR,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      i2c_vvc_if => i2c_vvc_if_2);

  -- 10 bit address
  i_i2c_master_vvc_3 : entity work.i2c_vvc
    generic map(
      GC_INSTANCE_IDX                       => 5,
      GC_MASTER_MODE                        => true,
      GC_I2C_CONFIG                         => GC_I2C_BFM_CONFIG_10_BIT_ADDR,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      i2c_vvc_if => i2c_vvc_if_1);

  i_i2c_slave_vvc_3 : entity work.i2c_vvc
    generic map(
      GC_INSTANCE_IDX                       => 4,
      GC_MASTER_MODE                        => false,
      GC_I2C_CONFIG                         => GC_I2C_BFM_CONFIG_10_BIT_ADDR,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      i2c_vvc_if => i2c_vvc_if_1);

  i_i2c_slave_vvc_4 : entity work.i2c_vvc
    generic map(
      GC_INSTANCE_IDX                       => 6,
      GC_MASTER_MODE                        => false,
      GC_I2C_CONFIG                         => GC_I2C_BFM_CONFIG_10_BIT_ADDR,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      i2c_vvc_if => i2c_vvc_if_2);

  i_i2c_slave_dut_1 : entity work.i2c_slave_dut
    generic map(
      GC_SLAVE_ADDR => GC_I2C_SLAVE_DUT_ADDR_1
    )
    port map(
      clk        => clk,
      arst       => arst,
      sbi_cs     => sbi_vvc_if.cs,
      sbi_addr   => sbi_vvc_if.addr,
      sbi_rd     => sbi_vvc_if.rena,
      sbi_wr     => sbi_vvc_if.wena,
      sbi_wdata  => sbi_vvc_if.wdata,
      sbi_ready  => sbi_ready_slave_dut_1,
      sbi_rdata  => sbi_rdata_slave_dut_1,
      i2c_vvc_if => i2c_vvc_if_2
    );

  i_i2c_slave_dut_2 : entity work.i2c_slave_dut
    generic map(
      GC_SLAVE_ADDR => GC_I2C_SLAVE_DUT_ADDR_2
    )
    port map(
      clk        => clk,
      arst       => arst,
      sbi_cs     => sbi_vvc_if.cs,
      sbi_addr   => sbi_vvc_if.addr,
      sbi_rd     => sbi_vvc_if.rena,
      sbi_wr     => sbi_vvc_if.wena,
      sbi_wdata  => sbi_vvc_if.wdata,
      sbi_ready  => sbi_ready_slave_dut_2,
      sbi_rdata  => sbi_rdata_slave_dut_2,
      i2c_vvc_if => i2c_vvc_if_2
    );

  i_i2c_slave_dut_3 : entity work.i2c_slave_dut
    generic map(
      GC_SLAVE_ADDR => GC_I2C_SLAVE_DUT_ADDR_3
    )
    port map(
      clk        => clk,
      arst       => arst,
      sbi_cs     => sbi_vvc_if.cs,
      sbi_addr   => sbi_vvc_if.addr,
      sbi_rd     => sbi_vvc_if.rena,
      sbi_wr     => sbi_vvc_if.wena,
      sbi_wdata  => sbi_vvc_if.wdata,
      sbi_ready  => sbi_ready_slave_dut_3,
      sbi_rdata  => sbi_rdata_slave_dut_3,
      i2c_vvc_if => i2c_vvc_if_2
    );

  i_i2c_slave_dut_4 : entity work.i2c_slave_dut
    generic map(
      GC_SLAVE_ADDR => GC_I2C_SLAVE_DUT_ADDR_4
    )
    port map(
      clk        => clk,
      arst       => arst,
      sbi_cs     => sbi_vvc_if.cs,
      sbi_addr   => sbi_vvc_if.addr,
      sbi_rd     => sbi_vvc_if.rena,
      sbi_wr     => sbi_vvc_if.wena,
      sbi_wdata  => sbi_vvc_if.wdata,
      sbi_ready  => sbi_ready_slave_dut_4,
      sbi_rdata  => sbi_rdata_slave_dut_4,
      i2c_vvc_if => i2c_vvc_if_2
    );

  i_i2c_master_vvc_2 : entity work.i2c_vvc
    generic map(
      GC_INSTANCE_IDX                       => 3,
      GC_MASTER_MODE                        => true,
      GC_I2C_CONFIG                         => GC_I2C_BFM_CONFIG_7_BIT_ADDR,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      i2c_vvc_if => i2c_vvc_if_2);

  i_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH                         => GC_SBI_ADDR_WIDTH,
      GC_DATA_WIDTH                         => GC_SBI_DATA_WIDTH,
      GC_INSTANCE_IDX                       => 0,
      GC_SBI_CONFIG                         => GC_SBI_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      clk               => clk,
      sbi_vvc_master_if => sbi_vvc_if
    );

  p_clk : clock_generator(clk, GC_CLK_PERIOD);

end struct;
