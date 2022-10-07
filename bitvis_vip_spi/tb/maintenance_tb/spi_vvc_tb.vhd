-------------------------------------------------------------------------------
-- Title      : Testbench for design "spi_vvc"
-- Project    :
-------------------------------------------------------------------------------
-- File       : spi_vvc_tb.vhd
-- Author     :   <dag.sverre.skjelbreid@bitvis.no>
-- Company    :
-- Created    : 2015-11-19
-- Last update: 2017-08-16
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-11-19  1.0      DagSverre       Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- uses UVVM
library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

-- Include Verification IPs
library bitvis_vip_spi;
context bitvis_vip_spi.vvc_context;

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

  -- component generics
  constant C_CMD_QUEUE_COUNT_MAX                : natural       := 1000;
  constant C_CMD_QUEUE_COUNT_THRESHOLD          : natural       := 950;
  constant C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level := warning;

  constant C_SPI_VVC_0 : natural := 0;
  constant C_SPI_VVC_1 : natural := 1;
  constant C_SPI_VVC_2 : natural := 2;
  constant C_SPI_VVC_3 : natural := 3;

  constant C_SBI_VVC_0 : natural := 0;

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

begin                                   -- architecture behav

  -- clock generator
  clock_generator(clk, clk_ena, C_CLK_PERIOD, "system_clock");

  -- Pull-downs on mosi and miso
  -- spi_vvc_if_1.mosi <= 'L';
  -- spi_vvc_if_1.miso <= 'L';
  -- spi_vvc_if_2.mosi <= 'L';
  -- spi_vvc_if_2.miso <= 'L';
  -- spi_vvc_if_3.mosi <= 'L';
  -- spi_vvc_if_3.miso <= 'L';

  -- component instantiations
  i_master_vvc_1 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_SPI_VVC_0,
      GC_MASTER_MODE                        => true,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE),
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      spi_vvc_if => spi_vvc_if_1);

  i_slave_vvc_1 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_SPI_VVC_1,
      GC_MASTER_MODE                        => false,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE),
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      spi_vvc_if => spi_vvc_if_1);

  i_slave_vvc_2 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_SPI_VVC_2,
      GC_MASTER_MODE                        => false,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE),
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
    port map(
      spi_vvc_if => spi_vvc_if_2);

  i_master_vvc_2 : entity work.spi_vvc
    generic map(
      GC_DATA_WIDTH                         => GC_DATA_WIDTH,
      GC_DATA_ARRAY_WIDTH                   => GC_DATA_ARRAY_WIDTH,
      GC_INSTANCE_IDX                       => C_SPI_VVC_3,
      GC_MASTER_MODE                        => true,
      GC_SPI_CONFIG                         => C_SPI_BFM_CONFIG_ARRAY(GC_SPI_MODE),
      GC_CMD_QUEUE_COUNT_MAX                => C_CMD_QUEUE_COUNT_MAX,
      GC_CMD_QUEUE_COUNT_THRESHOLD          => C_CMD_QUEUE_COUNT_THRESHOLD,
      GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY)
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
      -- sbi_vvc_master_if      => sbi_vvc_if
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
      -- sbi_if       => sbi_vvc_if,
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
    variable v_alert_num_mismatch       : boolean := false;
    variable tx_word                    : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable rx_word                    : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable tx_word_2                  : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable rx_word_2                  : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable data_word                  : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable data_exp_word              : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable master_word_array          : t_slv_array(GC_DATA_ARRAY_WIDTH - 1 downto 0)(GC_DATA_WIDTH - 1 downto 0);
    variable slave_word_array           : t_slv_array(GC_DATA_ARRAY_WIDTH - 1 downto 0)(GC_DATA_WIDTH - 1 downto 0);
    variable slave_tx_data_word         : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable master_tx_data_word        : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable master_tx_slv_word         : t_slv_array(GC_DATA_ARRAY_WIDTH - 1 downto 0)(GC_DATA_WIDTH - 1 downto 0);
    variable result                     : std_logic_vector(bitvis_vip_spi.transaction_pkg.C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
    variable v_cmd_idx                  : natural;
    variable v_inter_bfm_delay          : time    := 0 ns;
    variable v_vvc_delay                : integer := 0;
    variable v_vvc_delay_sync           : integer := 0;
    variable v_num_words                : positive;
    constant C_BIT_TRANSFER_SCLK_CYCLES : natural := ((GC_DATA_WIDTH + 8) * GC_DATA_ARRAY_WIDTH);

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
      log("\rSetting inter bfm delay for single-word transfer");
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).inter_bfm_delay.delay_in_time := ((3 + GC_DATA_WIDTH) * C_SPI_BFM_CONFIG_MODE0.spi_bit_time);
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).inter_bfm_delay.delay_type     := TIME_START2START;
      shared_spi_vvc_config(C_VVC_IDX_SLAVE_1).inter_bfm_delay.delay_in_time  := ((3 + GC_DATA_WIDTH) * C_SPI_BFM_CONFIG_MODE0.spi_bit_time);
    end procedure;

    procedure set_multi_word_inter_bfm_delay is
    begin
      log("\rSetting inter bfm delay for multi-word transfer");
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

    disable_log_msg(ALL_MESSAGES, "Disables all messages");
    enable_log_msg(ID_SEQUENCER, "Enable ID_SEQUENCER");
    enable_log_msg(ID_SEQUENCER_SUB, "Enable ID_SEQUENCER_SUB");
    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES, "Disables all messages in all VVCs");
    for i in 0 to 3 loop
      enable_log_msg(SPI_VVCT, i, ID_LOG_HDR, "Enabling SBI BFM logging");
      enable_log_msg(SPI_VVCT, i, ID_BFM, "Enabling SBI BFM logging");
      enable_log_msg(SPI_VVCT, i, ID_BFM_WAIT, "Enabling SBI BFM logging");
      enable_log_msg(SPI_VVCT, i, ID_SEQUENCER, "Enabling SBI logging");
      enable_log_msg(SPI_VVCT, i, ID_SEQUENCER_SUB, "Enabling SBI logging");
    end loop;

    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    wait for 1 ms;

    powerup;
    randomize(GC_DATA_WIDTH, GC_DATA_WIDTH + 10, "Setting global seeds");

    if GC_TESTCASE = "VVC-to-VVC" then
      -- configure single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      --
      -- Single-word transfer
      --
      for iteration in 0 to 5 loop
        slave_tx_data_word  := random(GC_DATA_WIDTH);
        master_tx_data_word := random(GC_DATA_WIDTH);
        spi_slave_transmit_and_check(slave_tx_data_word, master_tx_data_word, C_VVC_IDX_SLAVE_1);
        spi_master_transmit_and_check(master_tx_data_word, slave_tx_data_word, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER);
      end loop;

      --
      -- Single-word transfer
      --
      for iteration in 0 to 5 loop
        tx_word := random(GC_DATA_WIDTH);
        rx_word := random(GC_DATA_WIDTH);
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_check_only(tx_word, C_VVC_IDX_SLAVE_1);
        spi_master_transmit_only(tx_word, C_VVC_IDX_MASTER_1);
        spi_slave_transmit_only(rx_word, 1);
        spi_master_check_only(rx_word, 0);
      end loop;

      --
      -- Slave start on next SS
      --
      for idx in 1 to 5 loop
        tx_word := random(GC_DATA_WIDTH); --std_logic_vector(to_unsigned(idx, GC_DATA_WIDTH)); --random(GC_DATA_WIDTH);
        -- transfer missed word
        spi_master_transmit_only(not (tx_word), C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER); -- transfer missed by slave
        -- delay and start slave
        insert_delay(SPI_VVCT, C_VVC_IDX_SLAVE_1, random(5, GC_DATA_WIDTH) * C_CLK_PERIOD, "Skew SPI BFM start.");
        increment_expected_alerts(warning, 1);
        spi_slave_check_only(tx_word, C_VVC_IDX_SLAVE_1, START_TRANSFER_ON_NEXT_SS);
        -- transfer received word
        spi_master_transmit_only(tx_word, C_VVC_IDX_MASTER_1, RELEASE_LINE_AFTER_TRANSFER); -- next transfer, slave will receive this
      end loop;

      --      --
      --      -- Master and slave transmit and receive
      --      --
      --      for idx in 1 to 5 loop
      --        tx_word := random(GC_DATA_WIDTH);
      --        tx_word_2 := random(GC_DATA_WIDTH);
      --
      --        SPI_VVC_SB.add_expected(C_SPI_VVC_0, pad_spi_sb(tx_word_2));
      --        SPI_VVC_SB.add_expected(C_SPI_VVC_1, pad_spi_sb(tx_word));
      --
      --        spi_master_transmit_and_receive(SPI_VVCT, C_VVC_IDX_MASTER_1, TO_SB, "SPI Master Tx and Rx. Rx data will be sent to the SPI scoreboard for checking.", RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, C_SCOPE);
      --        spi_slave_transmit_and_receive(SPI_VVCT, C_VVC_IDX_SLAVE_1, TO_SB, "SPI Slave Tx and Rx. Rx data will be sent to the SPI scoreboard for checking", RELEASE_LINE_AFTER_TRANSFER, HOLD_LINE_BETWEEN_WORDS, C_SCOPE);
      --
      --        await_master_rx_completion(50 ms);
      --        await_slave_rx_completion(50 ms);
      --      end loop;

      await_master_tx_completion(50 ms);
      await_slave_rx_completion(50 ms);
      await_slave_tx_completion(50 ms);
      await_master_rx_completion(50 ms);

      -- Set inter_bfm_delay for multi-word transfer
      set_multi_word_inter_bfm_delay;

      --
      -- Multi-word transfer
      --
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

      --
      -- Multi-word transfer with different number of words
      --
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

      --
      -- Transfer array of words with SS_N deasserted between each word
      --
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

      --
      -- Transfer array with different number of words with SS_N deasserted between each word
      --
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

      --
      -- Receive only, one word
      --
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

      --
      -- Receive only, multi-word
      --
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

      shared_spi_vvc_config(C_VVC_IDX_MASTER_1).bfm_config.inter_word_delay := 0 ns;

    elsif GC_TESTCASE = "spi_master_dut_to_slave_VVC" then
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      --
      -- Single-word transfer
      --
      for iteration in 0 to 10 loop
        tx_word := random(GC_DATA_WIDTH);
        -- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, 2);
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, 2);

      -- Set multi-word inter_bfm_delay
      set_multi_word_inter_bfm_delay;

      --
      -- Multi-word transfer
      --
      for iteration in 0 to 10 loop
        -- generate word array
        for idx in 0 to master_word_array'length - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        spi_slave_check_only(master_word_array, 2);
        for idx in 0 to master_word_array'length - 1 loop
          sbi_master_write(master_word_array(idx)); -- this will cause dut to write on SPI
        end loop;
      end loop;

      --
      -- Multi-word transfer with different number of words
      --
      for iteration in 0 to 10 loop
        v_num_words := random(1, GC_DATA_ARRAY_WIDTH);
        -- generate word array
        for idx in 0 to v_num_words - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        spi_slave_check_only(master_word_array(v_num_words - 1 downto 0), 2);
        for idx in 0 to v_num_words - 1 loop
          sbi_master_write(master_word_array(idx)); -- this will cause dut to write on SPI
        end loop;
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, 2);

      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      --
      -- Single-word transfer
      --
      if GC_DATA_WIDTH = 32 then
        tx_word := x"5555_5555";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, 2);

        tx_word := x"AAAA_AAAA";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, 2);

        tx_word := x"FFFF_FFFF";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, 2);

        tx_word := x"0000_0000";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_master_write(tx_word);      -- this will cause dut to write on SPI
        spi_slave_check_only(tx_word, 2);
      end if;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, 2);

      -- Set multi-word inter_bfm_delay
      set_multi_word_inter_bfm_delay;

      --
      -- Master DUT to slave VVC multi-word transfer
      --
      for iteration in 0 to 5 loop
        -- generate word array
        for idx in 0 to GC_DATA_ARRAY_WIDTH - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        -- start slave
        spi_slave_check_only(master_word_array, 2, START_TRANSFER_IMMEDIATE);
        -- master DUT start multi-word transfer
        for idx in 0 to GC_DATA_ARRAY_WIDTH - 1 loop
          sbi_master_write(master_word_array(idx));
        end loop;
      end loop;

      --
      -- Master DUT to slave VVC multi-word transfer with different number of words
      --
      for iteration in 0 to 5 loop
        v_num_words := random(1, GC_DATA_ARRAY_WIDTH);
        -- generate word array
        for idx in 0 to v_num_words - 1 loop
          master_word_array(idx) := random(GC_DATA_WIDTH);
        end loop;
        -- start slave
        spi_slave_check_only(master_word_array(v_num_words - 1 downto 0), 2, START_TRANSFER_IMMEDIATE);
        -- master DUT start multi-word transfer
        for idx in 0 to v_num_words - 1 loop
          sbi_master_write(master_word_array(idx));
        end loop;
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, 2);

      --
      -- Slave start on next SS
      --
      for idx in 0 to 5 loop
        tx_word := random(GC_DATA_WIDTH);
        sbi_master_write(not (tx_word)); -- missed transfer
        insert_delay(SPI_VVCT, 2, random(2, GC_DATA_WIDTH - 1)); -- delay slave
        spi_slave_check_only(tx_word, 2, START_TRANSFER_ON_NEXT_SS); -- start slave
        sbi_master_write(tx_word);      -- received transfer
      end loop;

      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, 2);

      --
      -- Receive only, one word
      --
      tx_word   := random(GC_DATA_WIDTH);
      spi_slave_receive_only(1, 2, START_TRANSFER_IMMEDIATE);
      v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, 2);
      sbi_master_write(tx_word);
      sbi_await_completion(50 ms);
      await_slave_rx_completion(50 ms, 2);
      fetch_result(SPI_VVCT, 2, v_cmd_idx, result);
      check_value(tx_word, result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");
      --
      -- Receive only, multi-word
      --
      for iteration in 2 to GC_DATA_ARRAY_WIDTH loop
        spi_slave_receive_only(iteration, 2, START_TRANSFER_IMMEDIATE);
        v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, 2);
        for i in 1 to iteration loop
          master_word_array(i - 1) := random(GC_DATA_WIDTH);
          sbi_master_write(master_word_array(i - 1));
        end loop;
        sbi_await_completion(50 ms);
        await_slave_rx_completion(50 ms, 2);
        --await_slave_rx_completion(50 ms);
        for i in 1 to iteration loop
          fetch_result(SPI_VVCT, 2, v_cmd_idx, result);
          check_value(master_word_array(i - 1), result(GC_DATA_WIDTH - 1 downto 0), ERROR, "check received data");
        end loop;
      end loop;

    elsif GC_TESTCASE = "spi_slave_vvc_to_master_dut" then
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      for iteration in 0 to 10 loop
        tx_word := random(GC_DATA_WIDTH);
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, 2);
        sbi_master_write(std_logic_vector(to_unsigned(iteration, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, 2);
        sbi_master_check(tx_word);      -- this will cause dut to receive on SPI
        sbi_await_completion(50 ms);
      end loop;

      if GC_DATA_WIDTH = 32 then
        tx_word := x"5555_5555";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, 2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, 2);
        sbi_master_check(tx_word);      -- this will cause dut to receive on SPI
        sbi_await_completion(50 ms);

        tx_word := x"AAAA_AAAA";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, 2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, 2);
        sbi_master_check(tx_word);      -- this will cause dut to receive on SPI
        sbi_await_completion(50 ms);

        tx_word := x"FFFF_FFFF";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, 2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, 2);
        sbi_master_check(tx_word);      -- this will cause dut to receive on SPI
        sbi_await_completion(50 ms);

        tx_word := x"0000_0000";
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        spi_slave_transmit_only(tx_word, 2);
        sbi_master_write(std_logic_vector(to_unsigned(0, 8))); -- transmit dummy byte from master DUT to allow slave VVC to transmit to master DUT
        await_slave_tx_completion(50 ms, 2);
        sbi_master_check(tx_word);      -- this will cause dut to receive on SPI
        sbi_await_completion(50 ms);
      end if;

    elsif GC_TESTCASE = "spi_master_vvc_to_slave_dut" then
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      tx_word := random(GC_DATA_WIDTH);
      log("Transmit: " & to_string(tx_word), C_SCOPE);
      ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
      spi_master_transmit_only(tx_word, 3);
      await_master_tx_completion(50 ms, 3);
      sbi_slave_check(tx_word);         -- this will read what the DUT just received via SPI
      sbi_await_completion(50 ms);

    -- for iteration in 0 to 10 loop
    --   tx_word := random(GC_DATA_WIDTH);
    --   ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
    --   spi_master_transmit_only(tx_word, 3);
    --   await_master_tx_completion(50 ms, 3);
    --   sbi_slave_check(tx_word);  -- this will read what the DUT just received via SPI
    --   sbi_await_completion(50 ms);
    -- end loop;

    -- -- Verify corner cases
    -- if GC_DATA_WIDTH = 32 then
    --   tx_word := x"5555_5555";
    --   spi_master_transmit_only(tx_word, 3);
    --   await_master_tx_completion(50 ms, 3);
    --   sbi_slave_check(tx_word);
    --   sbi_await_completion(50 ms);

    --   tx_word := x"AAAA_AAAA";
    --   spi_master_transmit_only(tx_word, 3);
    --   await_master_tx_completion(50 ms, 3);
    --   sbi_slave_check(tx_word);
    --   sbi_await_completion(50 ms);

    --   tx_word := x"FFFF_FFFF";
    --   spi_master_transmit_only(tx_word, 3);
    --   await_master_tx_completion(50 ms, 3);
    --   sbi_slave_check(tx_word);
    --   sbi_await_completion(50 ms);

    --   tx_word := x"0000_0000";
    --   spi_master_transmit_only(tx_word, 3);
    --   await_master_tx_completion(50 ms, 3);
    --   sbi_slave_check(tx_word);
    --   sbi_await_completion(50 ms);
    -- end if;

    elsif GC_TESTCASE = "spi_slave_dut_to_master_vvc" then
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      for iteration in 0 to 10 loop
        tx_word := random(GC_DATA_WIDTH);
        ---- Master TX must be active for any transactions to occur; drives sclk and ss_n
        sbi_slave_write(tx_word);
        sbi_await_completion(50 ms);
        wait for C_CLK_PERIOD;          -- to allow the tx_word to be applied in the SPI slave dut.
        spi_master_transmit_only(std_logic_vector(to_unsigned(iteration, GC_DATA_WIDTH)), 3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, 3);
        await_master_tx_completion(50 ms, 3);
      end loop;

      -- Verify corner cases
      if GC_DATA_WIDTH = 32 then
        tx_word := x"5555_5555";
        sbi_slave_write(tx_word);
        sbi_await_completion(50 ms);
        wait for C_CLK_PERIOD;          -- to allow the tx_word to be applied in the SPI slave dut.
        spi_master_transmit_only(std_logic_vector(to_unsigned(0, GC_DATA_WIDTH)), 3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, 3);
        await_master_tx_completion(50 ms, 3);

        tx_word := x"AAAA_AAAA";
        sbi_slave_write(tx_word);
        sbi_await_completion(50 ms);
        wait for C_CLK_PERIOD;          -- to allow the tx_word to be applied in the SPI slave dut.
        spi_master_transmit_only(std_logic_vector(to_unsigned(0, GC_DATA_WIDTH)), 3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, 3);
        await_master_tx_completion(50 ms, 3);

        tx_word := x"0000_0000";
        sbi_slave_write(tx_word);
        sbi_await_completion(50 ms);
        wait for C_CLK_PERIOD;          -- to allow the tx_word to be applied in the SPI slave dut.
        spi_master_transmit_only(x"FFFF_FFFF", 3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, 3);
        await_master_tx_completion(50 ms, 3);

        tx_word := x"FFFF_FFFF";
        sbi_slave_write(tx_word);
        sbi_await_completion(50 ms);
        wait for C_CLK_PERIOD;          -- to allow the tx_word to be applied in the SPI slave dut.
        spi_master_transmit_only(x"FFFF_FFFF", 3); -- transmit dummy byte to allow slave to transmit.
        spi_master_check_only(tx_word, 3);
        await_master_tx_completion(50 ms, 3);
      end if;

      --
      -- Receive only, one word
      --
      tx_word   := random(GC_DATA_WIDTH);
      sbi_slave_write(tx_word);
      sbi_await_completion(50 ms);
      wait for C_CLK_PERIOD;            -- to allow the tx_word to be applied in the SPI slave dut.
      spi_master_transmit_only(not (tx_word), 3); -- transmit dummy byte to allow slave to transmit.
      spi_master_receive_only(1, 3, RELEASE_LINE_AFTER_TRANSFER);
      v_cmd_idx := get_last_received_cmd_idx(SPI_VVCT, 3);
      await_master_tx_completion(50 ms, 3);
      fetch_result(SPI_VVCT, 3, v_cmd_idx, result);
      check_value(result(GC_DATA_WIDTH - 1 downto 0), tx_word, ERROR, "check received data");

    --
    -- Receive only, multi-word
    --
    -- Not posible with DUT

    elsif GC_TESTCASE = "scoreboard_test" then
      -- Set single-word inter_bfm_delay
      set_single_word_inter_bfm_delay;

      tx_word := random(GC_DATA_WIDTH);
      spi_master_transmit_only(SPI_VVCT, C_SPI_VVC_0, tx_word, "SPI Master transmit");
      SPI_VVC_SB.add_expected(C_SPI_VVC_1, pad_spi_sb(tx_word));
      spi_slave_receive_only(SPI_VVCT, C_SPI_VVC_1, TO_SB, "SPI Slave receive data and send to SB");
      await_slave_rx_completion(50 ms);

      tx_word := random(GC_DATA_WIDTH);
      spi_slave_transmit_only(SPI_VVCT, C_SPI_VVC_1, tx_word, "SPI Slave transmit");
      SPI_VVC_SB.add_expected(C_SPI_VVC_0, pad_spi_sb(tx_word));
      spi_master_receive_only(SPI_VVCT, C_SPI_VVC_0, TO_SB, "SPI Master receive data and send to SB");
      await_master_rx_completion(50 ms);

      SPI_VVC_SB.report_counters(ALL_INSTANCES);
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
