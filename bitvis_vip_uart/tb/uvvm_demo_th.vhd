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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;    -- t_channel (RX/TX)

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;
use bitvis_vip_sbi.vvc_sb_support_pkg.all;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;
use bitvis_vip_uart.monitor_cmd_pkg.all;

library bitvis_uart;
library bitvis_vip_clock_generator;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

-- Test harness entity
entity uvvm_demo_th is
  generic(
    -- Clock and bit period settings
    GC_CLK_PERIOD                : time                 := 10 ns;
    GC_BIT_PERIOD                : time                 := 16 * GC_CLK_PERIOD;
    -- DUT addresses
    GC_ADDR_RX_DATA              : unsigned(2 downto 0) := "000";
    GC_ADDR_RX_DATA_VALID        : unsigned(2 downto 0) := "001";
    GC_ADDR_TX_DATA              : unsigned(2 downto 0) := "010";
    GC_ADDR_TX_READY             : unsigned(2 downto 0) := "011";
    -- Activity watchdog setting
    GC_ACTIVITY_WATCHDOG_TIMEOUT : time                 := 50 * GC_BIT_PERIOD
  );
end entity uvvm_demo_th;

-- Test harness architecture
architecture struct of uvvm_demo_th is

  -- VVC idx
  constant C_SBI_VVC       : natural := 1;
  constant C_UART_TX_VVC   : natural := 1;
  constant C_UART_RX_VVC   : natural := 1;
  constant C_CLOCK_GEN_VVC : natural := 1;

  -- UART if
  constant C_DATA_WIDTH : natural := 8;
  constant C_ADDR_WIDTH : natural := 3;

  -- Clock and reset signals
  signal clk  : std_logic := '0';
  signal arst : std_logic := '0';

  -- SBI VVC signals
  signal cs    : std_logic;
  signal addr  : unsigned(2 downto 0);
  signal wr    : std_logic;
  signal rd    : std_logic;
  signal wdata : std_logic_vector(7 downto 0);
  signal rdata : std_logic_vector(7 downto 0);
  signal ready : std_logic;

  -- UART VVC signals
  signal uart_vvc_rx : std_logic := '1';
  signal uart_vvc_tx : std_logic := '1';

  -- UART Monitor
  constant C_UART_MONITOR_INTERFACE_CONFIG : t_uart_interface_config := (
    bit_time      => GC_BIT_PERIOD,
    num_data_bits => 8,
    parity        => PARITY_ODD,
    num_stop_bits => STOP_BITS_ONE
  );

  constant C_UART_MONITOR_CONFIG : t_uart_monitor_config := (
    scope_name               => (1 to 12 => "UART Monitor", others => NUL),
    msg_id_panel             => C_UART_MONITOR_MSG_ID_PANEL_DEFAULT,
    interface_config         => C_UART_MONITOR_INTERFACE_CONFIG,
    transaction_display_time => 0 ns
  );

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => cs,
      addr  => addr,
      wr    => wr,
      rd    => rd,
      wdata => wdata,
      rdata => rdata,
      -- UART signals
      rx_a  => uart_vvc_tx,
      tx    => uart_vvc_rx
    );

  -----------------------------------------------------------------------------
  -- SBI VVC
  -----------------------------------------------------------------------------
  i1_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH,
      GC_DATA_WIDTH   => C_DATA_WIDTH,
      GC_INSTANCE_IDX => C_SBI_VVC
    )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => cs,
      sbi_vvc_master_if.rena  => rd,
      sbi_vvc_master_if.wena  => wr,
      sbi_vvc_master_if.addr  => addr,
      sbi_vvc_master_if.wdata => wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => rdata
    );

  -----------------------------------------------------------------------------
  -- UART VVC
  -----------------------------------------------------------------------------
  i1_uart_vvc : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      uart_vvc_rx => uart_vvc_rx,
      uart_vvc_tx => uart_vvc_tx
    );

  -- Static '1' ready signal for the SBI VVC
  ready <= '1';

  -----------------------------------------------------------------------------
  -- Monitor - UART
  --
  --   Monitor and validate UART transactions.
  --
  -----------------------------------------------------------------------------

  i1_uart_monitor : entity bitvis_vip_uart.uart_monitor
    generic map(
      GC_INSTANCE_IDX   => 1,
      GC_MONITOR_CONFIG => C_UART_MONITOR_CONFIG
    )
    port map(
      uart_dut_tx => uart_vvc_rx,
      uart_dut_rx => uart_vvc_tx
    );

  -----------------------------------------------------------------------------
  -- Activity Watchdog
  --
  --   Monitor VVC activity and alert if no VVC activity is
  --   detected before timeout.
  --
  -----------------------------------------------------------------------------

  p_activity_watchdog : activity_watchdog(timeout     => GC_ACTIVITY_WATCHDOG_TIMEOUT,
                                          num_exp_vvc => 4);

  -----------------------------------------------------------------------------
  -- Model
  --
  --   Subscribe to SBI and UART transaction infos, and send to Scoreboard or
  --   send VVC commands based on transaction info content.
  --
  -----------------------------------------------------------------------------

  p_model : process
    -- SBI transaction info
    alias sbi_vvc_transaction_info_trigger : std_logic is global_sbi_vvc_transaction_trigger(C_SBI_VVC);
    alias sbi_vvc_transaction_info         : bitvis_vip_sbi.transaction_pkg.t_transaction_group is shared_sbi_vvc_transaction_info(C_SBI_VVC);
    -- UART transaction info
    alias uart_rx_transaction_info_trigger : std_logic is global_uart_vvc_transaction_trigger(RX, C_UART_RX_VVC);
    alias uart_rx_transaction_info         : bitvis_vip_uart.transaction_pkg.t_transaction_group is shared_uart_vvc_transaction_info(RX, C_UART_RX_VVC);

    alias uart_tx_transaction_info_trigger : std_logic is global_uart_vvc_transaction_trigger(TX, C_UART_TX_VVC);
    alias uart_tx_transaction_info         : bitvis_vip_uart.transaction_pkg.t_transaction_group is shared_uart_vvc_transaction_info(TX, C_UART_TX_VVC);

  begin
    while true loop

      -- Wait for transaction info trigger
      wait until (sbi_vvc_transaction_info_trigger = '1') or (uart_rx_transaction_info_trigger = '1') or (uart_tx_transaction_info_trigger = '1');

      -------------------------------
      -- SBI transaction info
      -------------------------------
      if sbi_vvc_transaction_info_trigger'event then
        if sbi_vvc_transaction_info.bt.operation = WRITE and sbi_vvc_transaction_info.bt.transaction_status = IN_PROGRESS then
          -- add to UART scoreboard
          UART_VVC_SB.add_expected(sbi_vvc_transaction_info.bt.data(C_DATA_WIDTH - 1 downto 0));
        end if;
      end if;

      -------------------------------
      -- UART RX transaction info
      -------------------------------
      if uart_rx_transaction_info_trigger'event then
        -- Send to SB is handled by RX VVC.
        null;
      end if;

      -------------------------------
      -- UART TX transaction
      -------------------------------
      if uart_tx_transaction_info_trigger'event then
        if uart_tx_transaction_info.bt.operation = TRANSMIT and uart_tx_transaction_info.bt.transaction_status = IN_PROGRESS then
          -- Check if transaction is intended valid / free of error
          if (uart_tx_transaction_info.bt.error_info.parity_bit_error = false) and (uart_tx_transaction_info.bt.error_info.stop_bit_error = false) then
            -- Add to SBI scoreboard
            SBI_VVC_SB.add_expected(pad_sbi_sb(uart_tx_transaction_info.bt.data(C_DATA_WIDTH - 1 downto 0)));
            -- Wait for UART Transmit to finish before SBI VVC start
            insert_delay(SBI_VVCT, 1, 12 * GC_BIT_PERIOD, "Wait for UART TX to finish");
            -- Request SBI Read
            sbi_read(SBI_VVCT, 1, GC_ADDR_RX_DATA, TO_SB, "SBI_READ");
          end if;
        end if;
      end if;

    end loop;
    wait;
  end process p_model;

  -----------------------------------------------------------------------------
  -- Clock Generator VVC
  -----------------------------------------------------------------------------

  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => C_CLOCK_GEN_VVC,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => GC_CLK_PERIOD,
      GC_CLOCK_HIGH_TIME => GC_CLK_PERIOD / 2
    )
    port map(
      clk => clk
    );

  -----------------------------------------------------------------------------
  -- Reset
  -----------------------------------------------------------------------------

  -- Toggle the reset after 5 clock periods
  p_arst : arst <= '1', '0' after 5 * GC_CLK_PERIOD;

end struct;
