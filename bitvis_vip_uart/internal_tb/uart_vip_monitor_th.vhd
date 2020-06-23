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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_uart;
use bitvis_vip_uart.monitor_cmd_pkg.all;

library bitvis_uart;

-- Test case entity
entity monitor_test_harness is
end entity;

-- Test case architecture
architecture struct of monitor_test_harness is

  -- DSP interface and general control signals
  signal clk           : std_logic  := '0';
  signal arst          : std_logic  := '0';

  signal cs            : std_logic;
  signal addr          : unsigned(2 downto 0);
  signal wr            : std_logic;
  signal rd            : std_logic;
  signal wdata         : std_logic_vector(7 downto 0);
  signal rdata         : std_logic_vector(7 downto 0);
  signal ready         : std_logic;

  signal uart_rx       : std_logic;
  signal uart_tx       : std_logic;

  constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz
  constant C_CLK_JITTER : time := 0.2 ns;
  constant C_BIT_PERIOD : time := 16*C_CLK_PERIOD;

  constant C_SBI_BFM_CONFIG : t_sbi_bfm_config := (
    max_wait_cycles          => 10000000,
    max_wait_cycles_severity => failure,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read   => 0,
    clock_period             => C_CLK_PERIOD,
    clock_period_margin      => C_CLK_JITTER,
    clock_margin_severity    => TB_ERROR,
    setup_time               => C_CLK_PERIOD/4,
    hold_time                => C_CLK_PERIOD/4,
    bfm_sync                 => SYNC_ON_CLOCK_ONLY,
    match_strictness         => MATCH_EXACT,
    id_for_bfm               => ID_BFM,
    id_for_bfm_wait          => ID_BFM_WAIT,
    id_for_bfm_poll          => ID_BFM_POLL,
    use_ready_signal         => true
    --error_injection          => C_ERROR_INJECTION_INACTIVE
    );

  constant C_UART_MONITOR_INTERFACE_CONFIG : t_uart_interface_config := (
    bit_time         => C_BIT_PERIOD,
    num_data_bits    => 8,
    parity           => PARITY_ODD,
    num_stop_bits    => STOP_BITS_ONE
    );

  constant C_UART_MONITOR_CONFIG : t_uart_monitor_config := (
    scope_name               => (1 to 12 => "UART Monitor", others => NUL),
    msg_id_panel             => C_UART_MONITOR_MSG_ID_PANEL_DEFAULT,
    interface_config         => C_UART_MONITOR_INTERFACE_CONFIG,
    transaction_display_time => 0 ns
    );

begin
  ready <= '1';

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart: entity bitvis_uart.uart
    generic map (
      GC_MIN_EQUAL_SAMPLES_PER_BIT => 9
    )
    port map (
    -- DSP interface and general control signals
        clk             => clk,
        arst            => arst,
    -- CPU interface
        cs              => cs,
        addr            => addr,
        wr              => wr,
        rd              => rd,
        wdata           => wdata,
        rdata           => rdata,
    -- Interrupt related signals
        rx_a            => uart_tx,
        tx              => uart_rx
        );



  i1_sbi_vvc: entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => 3, -- integer := 8;
      GC_DATA_WIDTH   => 8, -- integer := 32;
      GC_INSTANCE_IDX => 1,
      GC_SBI_CONFIG   => C_SBI_BFM_CONFIG
    )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => cs,
      sbi_vvc_master_if.addr  => addr,
      sbi_vvc_master_if.rena  => rd,
      sbi_vvc_master_if.wena  => wr,
      sbi_vvc_master_if.wdata => wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => rdata
    );


  i1_uart_vvc: entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX   => 1
    )
    port map(
      uart_vvc_rx       => uart_rx,
      uart_vvc_tx       => uart_tx
    );

  i1_uart_monitor : entity bitvis_vip_uart.uart_monitor
    generic map(
      GC_INSTANCE_IDX   => 1,
      GC_MONITOR_CONFIG => C_UART_MONITOR_CONFIG
    )
    port map(
      uart_dut_tx => uart_tx,
      uart_dut_rx => uart_rx
    );

  p_arst: arst <= '1', '0' after 5 *C_CLK_PERIOD;

  p_clk: process
  begin
    clk <= '0', '1' after C_CLK_PERIOD / 2;
    wait for C_CLK_PERIOD;  -- provoke jitter on the clock, half a clock period faster per 12 clock periods: - ((bit period/2) / (bit period*12/clk period)) / 2
  end process;


end struct;
