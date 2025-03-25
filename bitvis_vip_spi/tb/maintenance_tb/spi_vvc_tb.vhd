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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

-- Include Verification IPs
library bitvis_vip_spi;
context bitvis_vip_spi.vvc_context;
use bitvis_vip_spi.vvc_sb_support_pkg.all;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

--hdlregression:tb
entity spi_vvc_tb is
  generic(
    GC_TESTCASE         : string               := "UVVM";
    GC_SPI_MODE         : natural range 0 to 3 := 0;
    GC_DATA_WIDTH       : positive             := 32;
    GC_DATA_ARRAY_WIDTH : positive             := 8
  );
end entity spi_vvc_tb;

architecture behav of spi_vvc_tb is

  constant C_SCOPE      : string := "SPI_TB";
  constant C_CLK_PERIOD : time   := 20 ns;

  constant C_SPI_MASTER_SBI_ADDR : unsigned(7 downto 0) := x"00";
  constant C_SPI_SLAVE_SBI_ADDR  : unsigned(7 downto 0) := x"01";

  -- VVC indexes
  constant C_VVC_IDX_MASTER_1 : natural := 0;
  constant C_VVC_IDX_SLAVE_1  : natural := 1;
  constant C_SPI_VVC_2        : natural := 2;
  constant C_SPI_VVC_3        : natural := 3;

  constant C_SBI_VVC_0        : natural := 0;

  constant C_SPI_BFM_CONFIG_MODE0 : t_spi_bfm_config := (
    CPOL             => '0',
    CPHA             => '0',
    spi_bit_time     => 200 ns,
    ss_n_to_sclk     => 301 ns,
    sclk_to_ss_n     => 301 ns,
    inter_word_delay => 0 ns,
    match_strictness => MATCH_EXACT,
    id_for_bfm       => ID_BFM,
    id_for_bfm_wait  => ID_BFM_WAIT,
    id_for_bfm_poll  => ID_BFM_POLL
  );

  constant C_SPI_BFM_CONFIG_MODE1 : t_spi_bfm_config := (
    CPOL             => '0',
    CPHA             => '1',
    spi_bit_time     => 200 ns,
    ss_n_to_sclk     => 301 ns,
    sclk_to_ss_n     => 301 ns,
    inter_word_delay => 0 ns,
    match_strictness => MATCH_EXACT,
    id_for_bfm       => ID_BFM,
    id_for_bfm_wait  => ID_BFM_WAIT,
    id_for_bfm_poll  => ID_BFM_POLL
  );

  constant C_SPI_BFM_CONFIG_MODE2 : t_spi_bfm_config := (
    CPOL             => '1',
    CPHA             => '0',
    spi_bit_time     => 200 ns,
    ss_n_to_sclk     => 301 ns,
    sclk_to_ss_n     => 301 ns,
    inter_word_delay => 0 ns,
    match_strictness => MATCH_EXACT,
    id_for_bfm       => ID_BFM,
    id_for_bfm_wait  => ID_BFM_WAIT,
    id_for_bfm_poll  => ID_BFM_POLL
  );

  constant C_SPI_BFM_CONFIG_MODE3 : t_spi_bfm_config := (
    CPOL             => '1',
    CPHA             => '1',
    spi_bit_time     => 200 ns,
    ss_n_to_sclk     => 301 ns,
    sclk_to_ss_n     => 301 ns,
    inter_word_delay => 0 ns,
    match_strictness => MATCH_EXACT,
    id_for_bfm       => ID_BFM,
    id_for_bfm_wait  => ID_BFM_WAIT,
    id_for_bfm_poll  => ID_BFM_POLL
  );

  type t_spi_bfm_config_array is array (0 to 3) of t_spi_bfm_config;
  constant C_SPI_BFM_CONFIG_ARRAY : t_spi_bfm_config_array := (0 => C_SPI_BFM_CONFIG_MODE0,
                                                               1 => C_SPI_BFM_CONFIG_MODE1,
                                                               2 => C_SPI_BFM_CONFIG_MODE2,
                                                               3 => C_SPI_BFM_CONFIG_MODE3);

  constant C_SBI_BFM_CONFIG : t_sbi_bfm_config := (
    max_wait_cycles            => 10000000,
    max_wait_cycles_severity   => failure,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read     => 0,
    clock_period               => C_CLK_PERIOD,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => C_CLK_PERIOD / 4,
    hold_time                  => C_CLK_PERIOD / 4,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    clock_period_margin        => 0 ns,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL,
    use_ready_signal           => true
  );

  -- component ports
  signal spi_vvc_if_1 : t_spi_if;       -- used for inter-vvc communication, basic tests/
  signal spi_vvc_if_2 : t_spi_if;       -- used for spi_master to slave vvc
  signal spi_vvc_if_3 : t_spi_if;       -- used for master vvc to spi_slave

  signal sbi_vvc_if           : t_sbi_if(addr(7 downto 0), wdata(GC_DATA_WIDTH - 1 downto 0), rdata(GC_DATA_WIDTH - 1 downto 0)); -- used to access spi master and slave
  signal spi_master_sbi_rdata : std_logic_vector(GC_DATA_WIDTH - 1 downto 0) := (others => '0');
  signal spi_master_sbi_ready : std_logic                                    := '0';
  signal spi_slave_sbi_rdata  : std_logic_vector(GC_DATA_WIDTH - 1 downto 0) := (others => '0');
  signal spi_slave_sbi_ready  : std_logic                                    := '0';

  signal sbi_vvc_rdata_input : std_logic_vector(GC_DATA_WIDTH - 1 downto 0) := (others => '0');
  signal sbi_vvc_ready_input : std_logic                                    := '0';

  -- signal spi_master_din_req    : std_logic;
  signal spi_master_din        : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal spi_master_wr_ena     : std_logic;
  signal spi_master_wr_ack     : std_logic;
  signal spi_master_dout_valid : std_logic;
  signal spi_master_dout       : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);

  signal spi_slave_din        : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal spi_slave_wr_ena     : std_logic;
  signal spi_slave_wr_ack     : std_logic;
  signal spi_slave_dout_valid : std_logic;
  signal spi_slave_dout       : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);

  -- clock and reset
  signal clk     : std_logic := '0';
  signal clk_ena : boolean   := false;
  signal arst    : std_logic := '0';

begin

  -- clock generator
  clock_generator(clk, clk_ena, C_CLK_PERIOD, "system_clock");

  -- component instantiations
  i_master_vvc_1 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_VVC_IDX_MASTER_1,
      GC_MASTER_MODE                        => true,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE))
    port map(
      spi_vvc_if => spi_vvc_if_1);

  i_slave_vvc_1 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_VVC_IDX_SLAVE_1,
      GC_MASTER_MODE                        => false,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE))
    port map(
      spi_vvc_if => spi_vvc_if_1);

  i_slave_vvc_2 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_SPI_VVC_2,
      GC_MASTER_MODE                        => false,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE))
    port map(
      spi_vvc_if => spi_vvc_if_2);

  i_master_vvc_2 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_SPI_VVC_3,
      GC_MASTER_MODE                        => true,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE))
    port map(
      spi_vvc_if => spi_vvc_if_3);

  -- SPI master with a 10 MHz SPI SCK
  i_spi_master : entity work.spi_master
    generic map(
      N    => GC_DATA_WIDTH,
      CPOL => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).CPOL,
      CPHA => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).CPHA
    )
    port map(
      sclk_i     => clk,                -- spi_sck will be 1/10 of the frequency of this clk. Need 20 ns period for this clk.
      pclk_i     => clk,                -- same as sclk_i
      rst_i      => arst,
      -- spi if --
      spi_ssel_o => spi_vvc_if_2.ss_n,
      spi_sck_o  => spi_vvc_if_2.sclk,
      spi_mosi_o => spi_vvc_if_2.mosi,
      spi_miso_i => spi_vvc_if_2.miso,
      -- parallel if --
      di_req_o   => open,
      di_i       => spi_master_din,
      wren_i     => spi_master_wr_ena,
      wr_ack_o   => spi_master_wr_ack,
      do_valid_o => spi_master_dout_valid,
      do_o       => spi_master_dout
    );

  -- SPI slave with a 10 MHz SPI SCK
  i_spi_slave : entity work.spi_slave
    generic map(
      N    => GC_DATA_WIDTH,
      CPOL => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).CPOL,
      CPHA => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).CPHA
    )
    port map(
      clk_i      => clk,                -- spi_sck will be 1/10 of the frequency of this clk. Need 20 ns period for this clk.
      -- spi if --
      spi_ssel_i => spi_vvc_if_3.ss_n,
      spi_sck_i  => spi_vvc_if_3.sclk,
      spi_mosi_i => spi_vvc_if_3.mosi,
      spi_miso_o => spi_vvc_if_3.miso,
      -- parallel if --
      di_req_o   => open,
      di_i       => spi_slave_din,
      wren_i     => spi_slave_wr_ena,
      wr_ack_o   => spi_slave_wr_ack,
      do_valid_o => spi_slave_dout_valid,
      do_o       => spi_slave_dout
    );

  sbi_vvc_rdata_input <= spi_master_sbi_rdata or spi_slave_sbi_rdata;
  sbi_vvc_ready_input <= spi_master_sbi_ready or spi_slave_sbi_ready;

  i_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH                         => 8,
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_INSTANCE_IDX                       => C_SBI_VVC_0,
      GC_SBI_CONFIG                         => C_SBI_BFM_CONFIG,
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => sbi_vvc_if.cs,
      sbi_vvc_master_if.addr  => sbi_vvc_if.addr,
      sbi_vvc_master_if.rena  => sbi_vvc_if.rena,
      sbi_vvc_master_if.wena  => sbi_vvc_if.wena,
      sbi_vvc_master_if.wdata => sbi_vvc_if.wdata,
      sbi_vvc_master_if.ready => sbi_vvc_ready_input,
      sbi_vvc_master_if.rdata => sbi_vvc_rdata_input
    );

  -- SPI MASTER PIF (SBI)
  i_spi_master_pif : entity work.spi_pif
    generic map(
      GC_SLAVE_ADDR => C_SPI_MASTER_SBI_ADDR,
      GC_DATA_WIDTH => GC_DATA_WIDTH
    )
    port map(
      clk          => clk,
      arst         => arst,
      sbi_if.cs    => sbi_vvc_if.cs,
      sbi_if.addr  => sbi_vvc_if.addr,
      sbi_if.rena  => sbi_vvc_if.rena,
      sbi_if.wena  => sbi_vvc_if.wena,
      sbi_if.wdata => sbi_vvc_if.wdata,
      sbi_if.ready => spi_master_sbi_ready,
      sbi_if.rdata => spi_master_sbi_rdata,
      -- di_req_i   => spi_master_din_req,
      spi_ss       => spi_vvc_if_2.ss_n,
      di_o         => spi_master_din,
      wren_o       => spi_master_wr_ena,
      wr_ack_i     => spi_master_wr_ack,
      do_valid_i   => spi_master_dout_valid,
      do_i         => spi_master_dout
    );

  -- SPI SLAVE PIF (SBI)
  i_spi_slave_pif : entity work.spi_pif
    generic map(
      GC_SLAVE_ADDR => C_SPI_SLAVE_SBI_ADDR,
      GC_DATA_WIDTH => GC_DATA_WIDTH
    )
    port map(
      clk          => clk,
      arst         => arst,
      sbi_if.cs    => sbi_vvc_if.cs,
      sbi_if.addr  => sbi_vvc_if.addr,
      sbi_if.rena  => sbi_vvc_if.rena,
      sbi_if.wena  => sbi_vvc_if.wena,
      sbi_if.wdata => sbi_vvc_if.wdata,
      sbi_if.ready => spi_slave_sbi_ready,
      sbi_if.rdata => spi_slave_sbi_rdata,
      spi_ss       => spi_vvc_if_3.ss_n,
      di_o         => spi_slave_din,
      wren_o       => spi_slave_wr_ena,
      wr_ack_i     => spi_slave_wr_ack,
      do_valid_i   => spi_slave_dout_valid,
      do_i         => spi_slave_dout
    );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable tx_word             : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable rx_word             : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable tx_word_2           : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable master_word_array   : t_slv_array(GC_DATA_ARRAY_WIDTH - 1 downto 0)(GC_DATA_WIDTH - 1 downto 0);
    variable slave_word_array    : t_slv_array(GC_DATA_ARRAY_WIDTH - 1 downto 0)(GC_DATA_WIDTH - 1 downto 0);
    variable slave_tx_data_word  : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable master_tx_data_word : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable result              : std_logic_vector(bitvis_vip_spi.transaction_pkg.C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    variable v_cmd_idx           : natural;
    variable v_num_words         : positive;
    variable v_alert_level       : t_alert_level;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 4;
    alias dut_ss_n is << signal i_spi_master.spi_ssel_o : std_logic >>;
    alias dut_sclk is << signal i_spi_master.spi_sck_o  : std_logic >>;
    alias dut_mosi is << signal i_spi_master.spi_mosi_o : std_logic >>;
    alias dut_miso is << signal i_spi_slave.spi_miso_o  : std_logic >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_level : in t_alert_level
    ) is
      constant C_BFM_CONFIG          : t_spi_bfm_config := C_SPI_BFM_CONFIG_MODE0; -- The applicable timing parameters are equal for all configs
      variable v_num_expected_alerts : natural;
      variable v_rand                : t_rand;
      variable v_hold_time           : time;
    begin
      for i in 0 to C_NUM_VVC_SIGNALS loop
        -- Set expected alerts before toggle
        if alert_level /= NO_ALERT then
          if i = 0 then
            increment_expected_alerts_and_stop_limit(alert_level, C_NUM_VVC_SIGNALS);
          else
            increment_expected_alerts_and_stop_limit(alert_level, 1);
          end if;
        end if;

        -- Force new value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_ss_n <= force not dut_ss_n;
                    dut_sclk <= force not dut_sclk;
                    dut_mosi <= force not dut_mosi;
                    dut_miso <= force not dut_miso;
          when 1 => dut_ss_n <= force not dut_ss_n;
          when 2 => dut_sclk <= force not dut_sclk;
          when 3 => dut_mosi <= force not dut_mosi;
          when 4 => dut_miso <= force not dut_miso;
        end case;
        v_hold_time := v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        wait for v_hold_time;
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);

        -- Set expected alerts before toggle
        if alert_level /= NO_ALERT then
          if i < 2 then
            -- Toggles ss_n
            if v_hold_time > (C_BFM_CONFIG.sclk_to_ss_n - minimum(C_BFM_CONFIG.spi_bit_time/2, C_BFM_CONFIG.ss_n_to_sclk) + std.env.resolution_limit) then
              if i = 0 then
                increment_expected_alerts_and_stop_limit(alert_level, C_NUM_VVC_SIGNALS);
              else
                increment_expected_alerts_and_stop_limit(alert_level, 1);
              end if;
            else -- v_hold_time <= (C_BFM_CONFIG.sclk_to_ss_n - minimum(C_BFM_CONFIG.spi_bit_time/2, C_BFM_CONFIG.ss_n_to_sclk) + std.env.resolution_limit)
              if i = 0 then
                increment_expected_alerts_and_stop_limit(alert_level, C_NUM_VVC_SIGNALS - 1); -- No alert for ss_n because toggle happened within accepted time period
              end if;
            end if; -- v_hold_time
          else
            -- Does not toggle ss_n
            if i = 0 then
              increment_expected_alerts_and_stop_limit(alert_level, C_NUM_VVC_SIGNALS);
            else
              increment_expected_alerts_and_stop_limit(alert_level, 1);
            end if;
          end if;
        end if;

        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_ss_n <= release;
                    dut_sclk <= release;
                    dut_mosi <= release;
                    dut_miso <= release;
          when 1 => dut_ss_n <= release;
          when 2 => dut_sclk <= release;
          when 3 => dut_mosi <= release;
          when 4 => dut_miso <= release;
        end case;
        wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
        wait for 0 ns;

        if i < 2 then
          -- Toggles ss_n
          if v_hold_time > (C_BFM_CONFIG.sclk_to_ss_n - minimum(C_BFM_CONFIG.spi_bit_time/2, C_BFM_CONFIG.ss_n_to_sclk) + std.env.resolution_limit) then
            v_num_expected_alerts := 0 when alert_level = NO_ALERT else
              v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
              v_num_expected_alerts + 1;
          else -- v_hold_time <= (C_BFM_CONFIG.sclk_to_ss_n - minimum(C_BFM_CONFIG.spi_bit_time/2, C_BFM_CONFIG.ss_n_to_sclk) + std.env.resolution_limit)
            v_num_expected_alerts := 0 when alert_level = NO_ALERT else
              v_num_expected_alerts + C_NUM_VVC_SIGNALS - 1 when i = 0 else
              v_num_expected_alerts;
          end if; -- v_hold_time
        else -- i >=2
          -- Does not toggle ss_n
          v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                  v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                  v_num_expected_alerts + 1;
        end if;
        wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
      end loop;
    end procedure;

    procedure powerup is
    begin
      clk_ena <= false;
      arst    <= '0';
      wait for 10 * C_CLK_PERIOD;
      arst    <= '1';
      wait for C_CLK_PERIOD;
      clk_ena <= true;
      wait for 10 * C_CLK_PERIOD;
      arst    <= '0';
      wait for C_CLK_PERIOD;
    end procedure;

    procedure await_master_tx_completion(
      constant duration         : in time;
      constant vvc_instance_idx : natural := C_VVC_IDX_MASTER_1
    ) is
    begin
      await_completion(SPI_VVCT, vvc_instance_idx, duration);
    end procedure;

    procedure await_master_rx_completion(
      constant duration         : in time;
      constant vvc_instance_idx : natural := C_VVC_IDX_MASTER_1
    ) is
    begin
      await_completion(SPI_VVCT, vvc_instance_idx, duration);
    end procedure;

    procedure await_slave_tx_completion(
      constant duration         : in time;
      constant vvc_instance_idx : natural := C_VVC_IDX_SLAVE_1
    ) is
    begin
      await_completion(SPI_VVCT, vvc_instance_idx, duration);
    end procedure;

    procedure await_slave_rx_completion(
      constant duration         : in time;
      constant vvc_instance_idx : natural := C_VVC_IDX_SLAVE_1
    ) is
    begin
      await_completion(SPI_VVCT, vvc_instance_idx, duration);
    end procedure;

    procedure sbi_master_write(
      constant data : in std_logic_vector
    ) is
    begin
      sbi_write(SBI_VVCT, C_SBI_VVC_0, C_SPI_MASTER_SBI_ADDR, data, "");
    end procedure;

    procedure sbi_master_check(
      constant data : in std_logic_vector
    ) is
    begin
      sbi_check(SBI_VVCT, C_SBI_VVC_0, C_SPI_MASTER_SBI_ADDR, data, "");
    end procedure;

    procedure sbi_slave_write(
      constant data : in std_logic_vector
    ) is
    begin
      sbi_write(SBI_VVCT, C_SBI_VVC_0, C_SPI_SLAVE_SBI_ADDR, data, "");
    end procedure;

    procedure sbi_slave_check(
      constant data : in std_logic_vector
    ) is
    begin
      sbi_check(SBI_VVCT, C_SBI_VVC_0, C_SPI_SLAVE_SBI_ADDR, data, "");
    end procedure;

    procedure sbi_await_completion(
      constant duration : in time
    ) is
    begin
      await_completion(SBI_VVCT, C_SBI_VVC_0, duration);
    end procedure;

    procedure spi_master_transmit_only(
      constant data                         : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_transmit_only(SPI_VVCT, vvc_instance_idx, data, "Master to Slave transmit " & msg, action_when_transfer_is_done);
    end procedure;

    procedure spi_master_transmit_only(
      constant data                         : in t_slv_array;
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant action_between_words         : in t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_transmit_only(SPI_VVCT, vvc_instance_idx, data, "Master to Slave transmit " & msg, action_when_transfer_is_done, action_between_words);
    end procedure;

    procedure spi_master_check_only(
      constant data                         : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant alert_level                  : in t_alert_level                  := TB_ERROR;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_check_only(SPI_VVCT, vvc_instance_idx, data, "Slave to Master check " & msg, alert_level, action_when_transfer_is_done);
    end procedure;

    procedure spi_master_check_only(
      constant data                         : in t_slv_array(GC_DATA_ARRAY_WIDTH-1 downto 0)(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant alert_level                  : in t_alert_level                  := TB_ERROR;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant action_between_words         : in t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_check_only(SPI_VVCT, vvc_instance_idx, data, "Slave to Master check " & msg, alert_level, action_when_transfer_is_done, action_between_words);
    end procedure;

    procedure spi_master_receive_only(
      constant num_words                    : in positive;
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant action_between_words         : in t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
      constant alert_level                  : in t_alert_level                  := TB_ERROR;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_receive_only(SPI_VVCT, vvc_instance_idx, "Slave to Master receive " & msg, num_words, action_when_transfer_is_done, action_between_words);
    end procedure;

    procedure spi_master_transmit_and_receive(
      constant data                         : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_transmit_and_receive(SPI_VVCT, vvc_instance_idx, data, "Master to Slave transmit and receive " & msg, action_when_transfer_is_done);
    end procedure;

    procedure spi_master_transmit_and_receive(
      constant data                         : in t_slv_array;
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant action_between_words         : in t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_transmit_and_receive(SPI_VVCT, vvc_instance_idx, data, "Master to Slave transmit and receive " & msg, action_when_transfer_is_done, action_between_words);
    end procedure;

    procedure spi_master_transmit_and_check(
      constant data                         : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant data_exp                     : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant alert_level                  : in t_alert_level                  := TB_ERROR;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_transmit_and_check(SPI_VVCT, vvc_instance_idx, data, data_exp, "Master to Slave transmit and check " & msg, alert_level, action_when_transfer_is_done);
    end procedure;

    procedure spi_master_transmit_and_check(
      constant data                         : in t_slv_array;
      constant data_exp                     : in t_slv_array;
      constant vvc_instance_idx             : natural                           := C_VVC_IDX_MASTER_1;
      constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
      constant action_between_words         : in t_action_between_words         := HOLD_LINE_BETWEEN_WORDS;
      constant alert_level                  : in t_alert_level                  := TB_ERROR;
      constant msg                          : in string                         := ""
    ) is
    begin
      spi_master_transmit_and_check(SPI_VVCT, vvc_instance_idx, data, data_exp, "Master to Slave transmit and check " & msg, alert_level, action_when_transfer_is_done, action_between_words);
    end procedure;

    procedure spi_slave_transmit_and_receive(
      constant data                   : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_transmit_and_receive(SPI_VVCT, vvc_instance_idx, data, "Slave to Master transmit and receive " & msg, when_to_start_transfer);
    end procedure;

    procedure spi_slave_transmit_and_receive(
      constant data                   : in t_slv_array;
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_transmit_and_receive(SPI_VVCT, vvc_instance_idx, data, "Slave to Master transmit and receive " & msg, when_to_start_transfer);
    end procedure;

    procedure spi_slave_transmit_and_check(
      constant data                   : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant data_exp               : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant alert_level            : in t_alert_level            := TB_ERROR;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_transmit_and_check(SPI_VVCT, vvc_instance_idx, data, data_exp, "Slave to Master transmit and check " & msg, alert_level, when_to_start_transfer);
    end procedure;

    procedure spi_slave_transmit_and_check(
      constant data                   : in t_slv_array;
      constant data_exp               : in t_slv_array;
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant alert_level            : in t_alert_level            := TB_ERROR;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_transmit_and_check(SPI_VVCT, vvc_instance_idx, data, data_exp, "Slave to Master transmit and check " & msg, alert_level, when_to_start_transfer);
    end procedure;

    procedure spi_slave_transmit_only(
      constant data                   : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_transmit_only(SPI_VVCT, vvc_instance_idx, data, "Slave to Master transmit " & msg, when_to_start_transfer);
    end procedure;

    procedure spi_slave_transmit_only(
      constant data                   : in t_slv_array;
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_transmit_only(SPI_VVCT, vvc_instance_idx, data, "Slave to Master transmit " & msg, when_to_start_transfer);
    end procedure;

    procedure spi_slave_receive_only(
      constant num_words              : in positive;
      constant vvc_instance_idx       : in natural                  := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant alert_level            : in t_alert_level            := TB_ERROR;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_receive_only(SPI_VVCT, vvc_instance_idx, "Master to Slave receive " & msg, num_words, when_to_start_transfer);
    end procedure;

    procedure spi_slave_check_only(
      constant data                   : in std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant alert_level            : in t_alert_level            := TB_ERROR;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_check_only(SPI_VVCT, vvc_instance_idx, data, "Master to Slave check " & msg, alert_level, when_to_start_transfer);
    end procedure;

    procedure spi_slave_check_only(
      constant data                   : in t_slv_array;
      constant vvc_instance_idx       : natural                     := C_VVC_IDX_SLAVE_1;
      constant when_to_start_transfer : in t_when_to_start_transfer := START_TRANSFER_ON_NEXT_SS;
      constant alert_level            : in t_alert_level            := TB_ERROR;
      constant msg                    : in string                   := ""
    ) is
    begin
      spi_slave_check_only(SPI_VVCT, vvc_instance_idx, data, "Master to Slave check " & msg, alert_level, when_to_start_transfer);
    end procedure;

    procedure set_single_word_inter_bfm_delay is
    begin
      log(ID_SEQUENCER, "Setting inter bfm delay for single-word transfer", C_SCOPE);
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).inter_bfm_delay.delay_in_time := ((3 + GC_DATA_WIDTH) * C_SPI_BFM_CONFIG_MODE0.spi_bit_time);
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).inter_bfm_delay.delay_type     := TIME_START2START;
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).inter_bfm_delay.delay_in_time  := ((3 + GC_DATA_WIDTH) * C_SPI_BFM_CONFIG_MODE0.spi_bit_time);
    end procedure;

    procedure set_multi_word_inter_bfm_delay is
    begin
      log(ID_SEQUENCER, "Setting inter bfm delay for multi-word transfer", C_SCOPE);
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).inter_bfm_delay.delay_in_time := 2 * GC_DATA_ARRAY_WIDTH * ((6 + GC_DATA_WIDTH) * C_SPI_BFM_CONFIG_MODE0.spi_bit_time);
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).inter_bfm_delay.delay_type     := TIME_START2START;
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).inter_bfm_delay.delay_in_time  := 2 * GC_DATA_ARRAY_WIDTH * ((6 + GC_DATA_WIDTH) * C_SPI_BFM_CONFIG_MODE0.spi_bit_time);
    end procedure;

    procedure check_inter_word_delay(
      constant delay : in time
    ) is
      variable v_time_stamp : time;
    begin
      await_value(spi_vvc_if_1.ss_n, '0', 0 ns, shared_spi_vvc_config(C_VVC_IDX_MASTER_1).inter_bfm_delay.delay_in_time + 1 ms, ERROR, "await active ss_n");
      await_value(spi_vvc_if_1.ss_n, '1', 0 ns, shared_spi_vvc_config(C_VVC_IDX_MASTER_1).bfm_config.ss_n_to_sclk + shared_spi_vvc_config(C_VVC_IDX_MASTER_1).bfm_config.spi_bit_time * GC_DATA_WIDTH + shared_spi_vvc_config(C_VVC_IDX_MASTER_1).bfm_config.sclk_to_ss_n + 100 ns, ERROR, "await inactive ss_n");
      v_time_stamp := now;
      await_value(spi_vvc_if_1.ss_n, '0', 0 ns, 2 * delay, ERROR, "await active ss_n");
      check_value(now - v_time_stamp, delay, ERROR, "check inter word delay");
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR_LARGE);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(SPI_VVCT, ALL_INSTANCES, ID_BFM);

    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    wait for 1 ms;

    powerup;
    randomize(GC_DATA_WIDTH, GC_DATA_WIDTH + 10, "Setting global seeds");

    if GC_TESTCASE = "VVC-to-VVC" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Testing VVC to VVC", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Configure single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Single-word transfer", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 5 loop
        slave_tx_data_word  := random(GC_DATA_WIDTH);
        master_tx_data_word := random(GC_DATA_WIDTH);
        spi_slave_transmit_and_check(slave_tx_data_word, master_tx_data_word, C_VVC_IDX_SLAVE_1);
        spi_master_transmit_and_check(master_tx_data_word, slave_tx_data_word, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER);
      end loop;

      for iteration in 0 to 5 loop
        tx_word := random(GC_DATA_WIDTH);
        rx_word := random(GC_DATA_WIDTH);
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_check_only(tx_word, C_VVC_IDX_SLAVE_1);
        spi_master_transmit_only(tx_word, C_VVC_IDX_MASTER_1);
        spi_slave_transmit_only(rx_word, 1);
        spi_master_check_only(rx_word, 0);
      end loop;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Slave start on next SS", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for idx in 1 to 5 loop
        tx_word := random(GC_DATA_WIDTH); --std_logic_vector(to_unsigned(idx, GC_DATA_WIDTH)); --random(GC_DATA_WIDTH);
        -- transfer missed word
        spi_master_transmit_only(not (tx_word), C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER); -- transfer missed by slave
        -- delay and start slave
        insert_delay(SPI_VVCT, C_VVC_IDX_SLAVE_1, random(16, 16 + GC_DATA_WIDTH) * C_CLK_PERIOD, "Skew SPI BFM start.");
        increment_expected_alerts(warning, 1);
        spi_slave_check_only(tx_word, C_VVC_IDX_SLAVE_1, START_TRANSFER_ON_NEXT_SS);
        -- transfer received word
        spi_master_transmit_only(tx_word, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER); -- next transfer, slave will receive this
      end loop;

      await_master_tx_completion(50 ms);
      await_slave_rx_completion(50 ms);
      await_slave_tx_completion(50 ms);
      await_master_rx_completion(50 ms);

      -- Set inter_bfm_delay for multi-word transfer
      set_multi_word_inter_bfm_delay;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Multi-word transfer", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 5 loop
        -- Generate word array
        for idx in 0 to GC_DATA_ARRAY_WIDTH - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
          slave_word_array(idx)  := random(GC_DATA_WIDTH);
        end loop;
        -- transmit and check
        spi_master_transmit_and_check(master_word_array, slave_word_array, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        spi_slave_transmit_and_check(slave_word_array, master_word_array, C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
      end loop;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Multi-word transfer with different number of words", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 5 loop
        v_num_words := random(1, GC_DATA_ARRAY_WIDTH);
        -- Generate word array
        for idx in 0 to v_num_words - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
          slave_word_array(idx)  := random(GC_DATA_WIDTH);
        end loop;
        -- transmit and check
        spi_master_transmit_and_check(master_word_array(v_num_words - 1 downto 0), slave_word_array(v_num_words - 1 downto 0), C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        spi_slave_transmit_and_check(slave_word_array(v_num_words - 1 downto 0), master_word_array(v_num_words - 1 downto 0), C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
      end loop;

      await_master_tx_completion(50 ms);
      await_slave_rx_completion(50 ms);
      await_slave_tx_completion(50 ms);
      await_master_rx_completion(50 ms);

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Transfer array of words with SS_N deasserted between each word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).bfm_config.inter_word_delay := 250 ns;

      for iteration in 0 to 5 loop
        -- Generate word array
        for idx in 0 to master_word_array'length - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
          slave_word_array(idx)  := random(GC_DATA_WIDTH);
        end loop;
        -- transmit and check
        spi_slave_transmit_and_check(slave_word_array, master_word_array, C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
        spi_master_transmit_and_check(master_word_array, slave_word_array, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        for i in 0 to master_word_array'length - 2 loop
          check_inter_word_delay(250 ns);
        end loop;
        await_value(spi_vvc_if_1.ss_n, '1', 0 ns, 10 ms, ERROR, "await inative ss_n");
      end loop;

      await_master_tx_completion(50 ms);
      await_slave_rx_completion(50 ms);
      await_slave_tx_completion(50 ms);
      await_master_rx_completion(50 ms);

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Transfer array with different number of words with SS_N deasserted between each word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).bfm_config.inter_word_delay := 150 ns;

      for iteration in 0 to 5 loop
        v_num_words := random(2, GC_DATA_ARRAY_WIDTH);
        -- Generate word array
        for idx in 0 to v_num_words - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
          slave_word_array(idx)  := random(GC_DATA_WIDTH);
        end loop;
        -- transmit and check
        spi_slave_transmit_and_check(slave_word_array(v_num_words - 1 downto 0), master_word_array(v_num_words - 1 downto 0), C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
        spi_master_transmit_and_check(master_word_array(v_num_words - 1 downto 0), slave_word_array(v_num_words - 1 downto 0), C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        for i in 0 to v_num_words - 2 loop
          check_inter_word_delay(150 ns);
        end loop;
        await_value(spi_vvc_if_1.ss_n, '1', 0 ns, 10 ms, ERROR, "await inative ss_n");
      end loop;

      await_master_tx_completion(50 ms);
      await_slave_rx_completion(50 ms);
      await_slave_tx_completion(50 ms);
      await_master_rx_completion(50 ms);

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Receive only, one word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- master --> slave
      tx_word   := random(GC_DATA_WIDTH);
      spi_slave_receive_only(1, C_VVC_IDX_SLAVE_1);
      v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_VVC_IDX_SLAVE_1);
      spi_master_transmit_only(tx_word, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER);
      await_slave_rx_completion(50 ms);
      await_master_tx_completion(50 ms);
      fetch_result(SPI_VVCT, C_VVC_IDX_SLAVE_1, v_cmd_idx, result);
      check_value(tx_word, result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");

      -- slave --> master
      tx_word   := random(GC_DATA_WIDTH);
      spi_master_receive_only(1, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER);
      v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_VVC_IDX_MASTER_1);
      spi_slave_transmit_only(tx_word, C_VVC_IDX_SLAVE_1);
      await_slave_rx_completion(50 ms);
      await_master_tx_completion(50 ms);
      fetch_result(SPI_VVCT, C_VVC_IDX_MASTER_1, v_cmd_idx, result);
      check_value(tx_word, result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Receive only, multi-word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- master --> slave
      for iteration in 2 to GC_DATA_ARRAY_WIDTH loop
        for i in 1 to iteration loop
          master_word_array(i - 1) := random(GC_DATA_WIDTH);
        end loop;
        spi_slave_receive_only(iteration, C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
        v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_VVC_IDX_SLAVE_1);
        spi_master_transmit_only(master_word_array(iteration - 1 downto 0), C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        await_slave_rx_completion(50 ms);
        await_master_tx_completion(50 ms);
        for i in 1 to iteration loop
          fetch_result(SPI_VVCT, C_VVC_IDX_SLAVE_1, v_cmd_idx, result);
          check_value(master_word_array(i - 1), result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");
        end loop;
      end loop;

      -- slave --> master
      for iteration in 2 to GC_DATA_ARRAY_WIDTH loop
        for i in 1 to iteration loop
          master_word_array(i - 1) := random(GC_DATA_WIDTH);
        end loop;
        spi_master_receive_only(iteration, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_VVC_IDX_MASTER_1);
        spi_slave_transmit_only(master_word_array(iteration - 1 downto 0), C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
        await_slave_rx_completion(50 ms);
        await_master_tx_completion(50 ms);
        for i in 1 to iteration loop
          fetch_result(SPI_VVCT, C_VVC_IDX_MASTER_1, v_cmd_idx, result);
          check_value(master_word_array(i - 1), result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");
        end loop;
      end loop;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing functionality of terminate_access for slave side, one word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors due to terminate command
      for iteration in 1 to 10 loop
        tx_word := std_logic_vector(to_unsigned(iteration, GC_DATA_WIDTH)); --Making individual tx words per loop
        spi_master_transmit_and_check(not(tx_word), tx_word);
        spi_slave_transmit_and_check(tx_word, not(tx_word));
        -- Terminating commands between loop 3 and 7.
        -- This is done to firstly check function of terminate_access, and then
        -- to verify correct function of slave_transmit after previous terminated access
        if (iteration > 3) and (iteration < 7) then
          wait for iteration*C_CLK_PERIOD;
          increment_expected_alerts(WARNING, 1);
          increment_expected_alerts_and_stop_limit(ERROR);
          terminate_current_command(SPI_VVCT, C_VVC_IDX_SLAVE_1);
        end if;
        await_slave_tx_completion(50 ms);
        await_master_tx_completion(50 ms);
      end loop;
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).unwanted_activity_severity := C_SPI_VVC_CONFIG_DEFAULT.unwanted_activity_severity;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing functionality of terminate_access for slave side, multi-word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors due to terminate command
      for iteration in 2 to GC_DATA_ARRAY_WIDTH loop
        for i in 1 to iteration loop
          master_word_array(i - 1) := random(GC_DATA_WIDTH);
        end loop;
        spi_master_receive_only(iteration, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_VVC_IDX_MASTER_1);
        spi_slave_transmit_only(master_word_array(iteration - 1 downto 0), C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
        terminate_current_command(SPI_VVCT, C_VVC_IDX_SLAVE_1);
        await_slave_rx_completion(50 ms);
        await_master_tx_completion(50 ms);
        for i in 1 to iteration loop
          increment_expected_alerts_and_stop_limit(ERROR);
          fetch_result(SPI_VVCT, C_VVC_IDX_MASTER_1, v_cmd_idx, result);
          check_value(master_word_array(i - 1), result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");
        end loop;
      end loop;
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).unwanted_activity_severity := C_SPI_VVC_CONFIG_DEFAULT.unwanted_activity_severity;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying correct function of multi-word transaction from slave after previous terminated access", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 5 loop
        -- Generate word array
        for idx in 0 to GC_DATA_ARRAY_WIDTH - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
          slave_word_array(idx)  := random(GC_DATA_WIDTH);
        end loop;
        -- transmit and check
        spi_master_transmit_and_check(master_word_array, slave_word_array, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER, RELEASE_LINE_BETWEEN_WORDS);
        spi_slave_transmit_and_check(slave_word_array, master_word_array, C_VVC_IDX_SLAVE_1, START_TRANSFER_IMMEDIATE);
      end loop;

      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).bfm_config.inter_word_delay := 0 ns;

    elsif GC_TESTCASE = "spi_master_dut_to_slave_VVC" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Testing master DUT to slave VVC", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Single-word transfer", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 10 loop
        tx_word := random(GC_DATA_WIDTH);
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, C_SPI_VVC_2);
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, C_SPI_VVC_2);

      -- Set multi-word inter_bfm_delay
      set_multi_word_inter_bfm_delay;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Multi-word transfer", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 10 loop
        -- generate word array
        for idx in 0 to master_word_array'length - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        spi_slave_check_only(master_word_array, C_SPI_VVC_2);
        for idx in 0 to master_word_array'length - 1 loop
          sbi_master_write(master_word_array(idx)); -- this will cause dut to write on SPI
        end loop;
      end loop;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Multi-word transfer with different number of words", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 10 loop
        v_num_words := random(1, GC_DATA_ARRAY_WIDTH);
        -- generate word array
        for idx in 0 to v_num_words - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        spi_slave_check_only(master_word_array(v_num_words - 1 downto 0), C_SPI_VVC_2);
        for idx in 0 to v_num_words - 1 loop
          sbi_master_write(master_word_array(idx)); -- this will cause dut to write on SPI
        end loop;
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, C_SPI_VVC_2);

      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Single-word transfer", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      if GC_DATA_WIDTH = 32 then
        tx_word := x"5555_5555";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, C_SPI_VVC_2);

        tx_word := x"AAAA_AAAA";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, C_SPI_VVC_2);

        tx_word := x"FFFF_FFFF";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, C_SPI_VVC_2);

        tx_word := x"0000_0000";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, C_SPI_VVC_2);
      end if;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, C_SPI_VVC_2);

      -- Set multi-word inter_bfm_delay
      set_multi_word_inter_bfm_delay;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Master DUT to slave VVC multi-word transfer", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 5 loop
        -- generate word array
        for idx in 0 to GC_DATA_ARRAY_WIDTH - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        -- start slave
        spi_slave_check_only(master_word_array, C_SPI_VVC_2, START_TRANSFER_IMMEDIATE);
        -- master DUT start multi-word transfer
        for idx in 0 to GC_DATA_ARRAY_WIDTH - 1 loop
          sbi_master_write(master_word_array(idx));
        end loop;
      end loop;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Master DUT to slave VVC multi-word transfer with different number of words", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 0 to 5 loop
        v_num_words := random(1, GC_DATA_ARRAY_WIDTH);
        -- generate word array
        for idx in 0 to v_num_words - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        -- start slave
        spi_slave_check_only(master_word_array(v_num_words - 1 downto 0), C_SPI_VVC_2, START_TRANSFER_IMMEDIATE);
        -- master DUT start multi-word transfer
        for idx in 0 to v_num_words - 1 loop
          sbi_master_write(master_word_array(idx));
        end loop;
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, C_SPI_VVC_2);

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Slave start on next SS", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for idx in 0 to 5 loop
        tx_word := random(GC_DATA_WIDTH);
        sbi_master_write(not (tx_word)); -- missed transfer
        insert_delay(SPI_VVCT, C_SPI_VVC_2, random(3, GC_DATA_WIDTH - 1)); -- delay slave
        spi_slave_check_only(tx_word, C_SPI_VVC_2, START_TRANSFER_ON_NEXT_SS); -- start slave
        sbi_master_write(tx_word);      -- received transfer
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, C_SPI_VVC_2);

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Receive only, one word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      tx_word   := random(GC_DATA_WIDTH);
      spi_slave_receive_only(1, C_SPI_VVC_2, START_TRANSFER_IMMEDIATE);
      v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_SPI_VVC_2);
      sbi_master_write(tx_word);
      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, C_SPI_VVC_2);
      fetch_result(SPI_VVCT, C_SPI_VVC_2, v_cmd_idx, result);
      check_value(tx_word, result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Receive only, multi-word", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for iteration in 2 to GC_DATA_ARRAY_WIDTH loop
        spi_slave_receive_only(iteration, C_SPI_VVC_2, START_TRANSFER_IMMEDIATE);
        v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_SPI_VVC_2);
        for i in 1 to iteration loop
          master_word_array(i - 1) := random(GC_DATA_WIDTH);
          sbi_master_write(master_word_array(i - 1));
        end loop;
        sbi_await_completion(50 ms);
        await_slave_rx_completion(50 ms, C_SPI_VVC_2);
        for i in 1 to iteration loop
          fetch_result(SPI_VVCT, C_SPI_VVC_2, v_cmd_idx, result);
          check_value(master_word_array(i - 1), result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");
        end loop;
      end loop;

    elsif GC_TESTCASE = "spi_slave_vvc_to_master_dut" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Testing slave VVC to master DUT", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      for iteration in 0 to 10 loop
        tx_word := random(GC_DATA_WIDTH);
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, C_SPI_VVC_2);
        sbi_master_write(std_logic_vector(to_unsigned(iteration, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, C_SPI_VVC_2);
        await_value(spi_vvc_if_2.ss_n, '1', 0 ns, C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).sclk_to_ss_n, ERROR, "await inactive ss_n"); -- Allow SPI operation to finish completely
        sbi_master_check(tx_word); -- this will read the received SPI data via SBI
        sbi_await_completion(50 ms);
      end loop;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Verify corner cases", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      if GC_DATA_WIDTH = 32 then
        tx_word := x"5555_5555";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, C_SPI_VVC_2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, C_SPI_VVC_2);
        await_value(spi_vvc_if_2.ss_n, '1', 0 ns, C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).sclk_to_ss_n, ERROR, "await inactive ss_n"); -- Allow SPI operation to finish completely
        sbi_master_check(tx_word); -- this will read the received SPI data via SBI
        sbi_await_completion(50 ms);

        tx_word := x"AAAA_AAAA";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, C_SPI_VVC_2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, C_SPI_VVC_2);
        await_value(spi_vvc_if_2.ss_n, '1', 0 ns, C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).sclk_to_ss_n, ERROR, "await inactive ss_n"); -- Allow SPI operation to finish completely
        sbi_master_check(tx_word); -- this will read the received SPI data via SBI
        sbi_await_completion(50 ms);

        tx_word := x"FFFF_FFFF";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, C_SPI_VVC_2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, C_SPI_VVC_2);
        await_value(spi_vvc_if_2.ss_n, '1', 0 ns, C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).sclk_to_ss_n, ERROR, "await inactive ss_n"); -- Allow SPI operation to finish completely
        sbi_master_check(tx_word); -- this will read the received SPI data via SBI
        sbi_await_completion(50 ms);

        tx_word := x"0000_0000";
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, C_SPI_VVC_2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, C_SPI_VVC_2);
        await_value(spi_vvc_if_2.ss_n, '1', 0 ns, C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE).sclk_to_ss_n, ERROR, "await inactive ss_n"); -- Allow SPI operation to finish completely
        sbi_master_check(tx_word); -- this will read the received SPI data via SBI
        sbi_await_completion(50 ms);
      end if;

    elsif GC_TESTCASE = "spi_master_vvc_to_slave_dut" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Testing master VVC to slave DUT", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      tx_word := random(GC_DATA_WIDTH);
      log("Transmit: " & to_string(tx_word), C_SCOPE);
      -- Master TX must be active for any transactions to occur; drives sclk and ss_n
      spi_master_transmit_only(tx_word, C_SPI_VVC_3);
      await_master_tx_completion(50 ms, C_SPI_VVC_3);
      sbi_slave_check(tx_word);         -- this will read what the DUT just received via SPI
      sbi_await_completion(50 ms);

     for iteration in 0 to 10 loop
       tx_word := random(GC_DATA_WIDTH);
       -- Master TX must be active for any transactions to occur; drives sclk and ss_n
       spi_master_transmit_only(tx_word, C_SPI_VVC_3);
       await_master_tx_completion(50 ms, C_SPI_VVC_3);
       sbi_slave_check(tx_word);  -- this will read what the DUT just received via SPI
       sbi_await_completion(50 ms);
     end loop;

     ----------------------------------------------------------------------------------------------------------------------------
     log(ID_LOG_HDR_LARGE, "Verify corner cases", C_SCOPE);
     ----------------------------------------------------------------------------------------------------------------------------
     if GC_DATA_WIDTH = 32 then
       tx_word := x"5555_5555";
       spi_master_transmit_only(tx_word, C_SPI_VVC_3);
       await_master_tx_completion(50 ms, C_SPI_VVC_3);
       sbi_slave_check(tx_word);
       sbi_await_completion(50 ms);

       tx_word := x"AAAA_AAAA";
       spi_master_transmit_only(tx_word, C_SPI_VVC_3);
       await_master_tx_completion(50 ms, C_SPI_VVC_3);
       sbi_slave_check(tx_word);
       sbi_await_completion(50 ms);

       tx_word := x"FFFF_FFFF";
       spi_master_transmit_only(tx_word, C_SPI_VVC_3);
       await_master_tx_completion(50 ms, C_SPI_VVC_3);
       sbi_slave_check(tx_word);
       sbi_await_completion(50 ms);

       tx_word := x"0000_0000";
       spi_master_transmit_only(tx_word, C_SPI_VVC_3);
       await_master_tx_completion(50 ms, C_SPI_VVC_3);
       sbi_slave_check(tx_word);
       sbi_await_completion(50 ms);
     end if;

    elsif GC_TESTCASE = "spi_slave_dut_to_master_vvc" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Testing slave DUT to master VVC", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      for iteration in 0 to 10 loop
        tx_word := random(GC_DATA_WIDTH);
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_slave_write(tx_word);
        insert_delay(SPI_VVCT, C_SPI_VVC_3, 2 * C_CLK_PERIOD, "Delay check to allow the tx_word to be applied in the SPI slave DUT", C_SCOPE);
        spi_master_transmit_only(std_logic_vector(to_unsigned(iteration, GC_DATA_WIDTH)), C_SPI_VVC_3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, C_SPI_VVC_3);
        await_master_tx_completion(50 ms, C_SPI_VVC_3);
      end loop;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Verify corner cases", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      if GC_DATA_WIDTH = 32 then
        tx_word := x"5555_5555";
        sbi_slave_write(tx_word);
        insert_delay(SPI_VVCT, C_SPI_VVC_3, 2 * C_CLK_PERIOD, "Delay check to allow the tx_word to be applied in the SPI slave DUT", C_SCOPE);
        spi_master_transmit_only(std_logic_vector(to_unsigned(0, GC_DATA_WIDTH)), C_SPI_VVC_3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, C_SPI_VVC_3);
        await_master_tx_completion(50 ms, C_SPI_VVC_3);

        tx_word := x"AAAA_AAAA";
        sbi_slave_write(tx_word);
        insert_delay(SPI_VVCT, C_SPI_VVC_3, 2 * C_CLK_PERIOD, "Delay check to allow the tx_word to be applied in the SPI slave DUT", C_SCOPE);
        spi_master_transmit_only(std_logic_vector(to_unsigned(0, GC_DATA_WIDTH)), C_SPI_VVC_3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, C_SPI_VVC_3);
        await_master_tx_completion(50 ms, C_SPI_VVC_3);

        tx_word := x"0000_0000";
        sbi_slave_write(tx_word);
        insert_delay(SPI_VVCT, C_SPI_VVC_3, 2 * C_CLK_PERIOD, "Delay check to allow the tx_word to be applied in the SPI slave DUT", C_SCOPE);
        spi_master_transmit_only(x"FFFF_FFFF", C_SPI_VVC_3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, C_SPI_VVC_3);
        await_master_tx_completion(50 ms, C_SPI_VVC_3);

        tx_word := x"FFFF_FFFF";
        sbi_slave_write(tx_word);
        insert_delay(SPI_VVCT, C_SPI_VVC_3, 2 * C_CLK_PERIOD, "Delay check to allow the tx_word to be applied in the SPI slave DUT", C_SCOPE);
        spi_master_transmit_only(x"FFFF_FFFF", C_SPI_VVC_3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, C_SPI_VVC_3);
        await_master_tx_completion(50 ms, C_SPI_VVC_3);
      end if;

      log(ID_LOG_HDR_LARGE, "Receive only, one word", C_SCOPE);
      tx_word   := random(GC_DATA_WIDTH);
      sbi_slave_write(tx_word);
      insert_delay(SPI_VVCT, C_SPI_VVC_3, 2 * C_CLK_PERIOD, "Delay check to allow the tx_word to be applied in the SPI slave DUT", C_SCOPE);
      spi_master_transmit_only(not (tx_word), C_SPI_VVC_3); -- transmit dummy byte to allow slave to transmit.
      spi_master_receive_only(1, C_SPI_VVC_3, RELEASE_LINE_AFTER_TRANSFER);
      v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, C_SPI_VVC_3);
      await_master_tx_completion(50 ms, C_SPI_VVC_3);
      fetch_result(SPI_VVCT, C_SPI_VVC_3, v_cmd_idx, result);
      check_value(result(GC_DATA_WIDTH - 1 downto 0), tx_word, ERROR, "check received data");

    --
    -- Receive only, multi-word
    --
    -- Not posible with DUT

    elsif GC_TESTCASE = "scoreboard_test" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Testing Scoreboard", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      tx_word := random(GC_DATA_WIDTH);
      SPI_VVC_SB.add_expected(C_VVC_IDX_SLAVE_1, pad_spi_sb(tx_word));
      spi_slave_receive_only(SPI_VVCT, C_VVC_IDX_SLAVE_1, TO_SB, "SPI Slave receive data and send to SB");
      spi_master_transmit_only(SPI_VVCT, C_VVC_IDX_MASTER_1, tx_word, "SPI Master transmit");
      await_slave_rx_completion(50 ms);

      tx_word := random(GC_DATA_WIDTH);
      SPI_VVC_SB.add_expected(C_VVC_IDX_MASTER_1, pad_spi_sb(tx_word));
      spi_master_receive_only(SPI_VVCT, C_VVC_IDX_MASTER_1, TO_SB, "SPI Master receive data and send to SB");
      spi_slave_transmit_only(SPI_VVCT, C_VVC_IDX_SLAVE_1, tx_word, "SPI Slave transmit");
      await_master_rx_completion(50 ms);

      SPI_VVC_SB.report_counters(ALL_INSTANCES);

    elsif GC_TESTCASE = "test_unwanted_activity" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for i in 0 to 2 loop
        -- Test different alert severity configurations
        if i = 0 then
          v_alert_level := C_SPI_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
        elsif i = 1 then
          v_alert_level := FAILURE;
        else
          v_alert_level := NO_ALERT;
        end if;
        log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
        shared_spi_vvc_config(C_SPI_VVC_2).unwanted_activity_severity := v_alert_level;
        shared_spi_vvc_config(C_SPI_VVC_3).unwanted_activity_severity := v_alert_level;

        log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
        tx_word := random(GC_DATA_WIDTH);
        sbi_master_write(tx_word);
        spi_slave_check_only(tx_word, C_SPI_VVC_2);
        await_slave_rx_completion(50 ms, C_SPI_VVC_2);

        tx_word := random(GC_DATA_WIDTH);
        sbi_slave_write(tx_word);
        wait for 2*C_CLK_PERIOD; -- to allow the tx_word to be applied in the SPI slave dut.
        spi_master_check_only(tx_word, C_SPI_VVC_3);
        await_master_tx_completion(50 ms, C_SPI_VVC_3);

        -- Test with and without a time gap between await_completion and unexpected data transmission
        if i = 0 then
          log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
          wait for 100 ns;
        end if;

        log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
        toggle_vvc_if(v_alert_level);
      end loop;

    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;
end architecture behav;
