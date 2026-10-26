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

library bitvis_vip_axistream;
context bitvis_vip_axistream.vvc_context;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;

--hdlregression:tb
-- Test bench entity
entity vvc_id_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of vvc_id_tb is

  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_DATA_WIDTH : integer := 8;
  constant C_USER_WIDTH : integer := 1;
  constant C_ID_WIDTH   : integer := 1;
  constant C_DEST_WIDTH : integer := 1;
  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk : std_logic;

  signal axistream_if_m : t_axistream_if(tdata(C_DATA_WIDTH - 1 downto 0),
                                         tkeep((C_DATA_WIDTH / 8) - 1 downto 0),
                                         tuser(C_USER_WIDTH - 1 downto 0),
                                         tstrb((C_DATA_WIDTH / 8) - 1 downto 0),
                                         tid(C_ID_WIDTH - 1 downto 0),
                                         tdest(C_DEST_WIDTH - 1 downto 0)
                                        );

  signal axistream_if_s : t_axistream_if(tdata(C_DATA_WIDTH - 1 downto 0),
                                         tkeep((C_DATA_WIDTH / 8) - 1 downto 0),
                                         tuser(C_USER_WIDTH - 1 downto 0),
                                         tstrb((C_DATA_WIDTH / 8) - 1 downto 0),
                                         tid(C_ID_WIDTH - 1 downto 0),
                                         tdest(C_DEST_WIDTH - 1 downto 0)
                                        );

  signal uart_vvc_rx_1 : std_logic;
  signal uart_vvc_tx_1 : std_logic;
  signal uart_vvc_rx_2 : std_logic;
  signal uart_vvc_tx_2 : std_logic;

begin

  --------------------------------------------------------------------------------
  -- VVC Instantiations with Distinct ID
  --------------------------------------------------------------------------------
  g_distinct_id_vvc : if GC_TESTCASE = "distinct_vvc_id" generate
    -- AXI-Stream VVC
    i_axistream_vvc_master : entity bitvis_vip_axistream.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => true,
      GC_DATA_WIDTH    => C_DATA_WIDTH,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 0
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_m
    );

    i_axistream_vvc_slave : entity bitvis_vip_axistream.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => false,
      GC_DATA_WIDTH    => C_DATA_WIDTH,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 1
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_s
    );

    -- UART VVC
    i_uart_vvc_1 : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      uart_vvc_rx => uart_vvc_rx_1,
      uart_vvc_tx => uart_vvc_tx_1
    );

    i_uart_vvc_2 : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 2
    )
    port map(
      uart_vvc_rx => uart_vvc_rx_2,
      uart_vvc_tx => uart_vvc_tx_2
    );
  end generate;

  --------------------------------------------------------------------------------
  -- VVC Instantiations with Duplicate ID
  --------------------------------------------------------------------------------
  g_duplicate_id_vvc : if GC_TESTCASE = "duplicate_vvc_id" generate
    -- AXI-Stream VVC
    i_axistream_vvc_master : entity bitvis_vip_axistream.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => true,
      GC_DATA_WIDTH    => C_DATA_WIDTH,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 1
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_m
    );

    i_axistream_vvc_slave : entity bitvis_vip_axistream.axistream_vvc
    generic map(
      GC_VVC_IS_MASTER => false,
      GC_DATA_WIDTH    => C_DATA_WIDTH,
      GC_USER_WIDTH    => C_USER_WIDTH,
      GC_ID_WIDTH      => C_ID_WIDTH,
      GC_DEST_WIDTH    => C_DEST_WIDTH,
      GC_INSTANCE_IDX  => 1
    )
    port map(
      clk              => clk,
      axistream_vvc_if => axistream_if_s
    );

    -- UART VVC
    i_uart_vvc_1 : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      uart_vvc_rx => uart_vvc_rx_1,
      uart_vvc_tx => uart_vvc_tx_1
    );

    i_uart_vvc_2 : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      uart_vvc_rx => uart_vvc_rx_2,
      uart_vvc_tx => uart_vvc_tx_2
    );
  end generate;

  --------------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  --------------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    --============================================================================================================================
    if GC_TESTCASE = "distinct_vvc_id" then
    --============================================================================================================================
      --------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Distinct VVC Instance Number.\n\n" & "Two AXI-Stream VVCs and two UART VVCs are instantiated with a distinct instance number.", C_SCOPE);
      --------------------------------------------------------------------------------

    --============================================================================================================================
    elsif GC_TESTCASE = "duplicate_vvc_id" then
    --============================================================================================================================
      --------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Duplicate VVC Instance Number.\n\n" & "Two AXI-Stream VVCs and two UART VVCs are instantiated with a duplicate instance number.", C_SCOPE);
      --------------------------------------------------------------------------------

      -- Increment alerts and stop limit
      increment_expected_alerts_and_stop_limit(TB_ERROR, 3);   -- Number of total expected alerts = number of identical VVC IDs (UART_VVC_1_TX + UART_VVC_1_RX + AXISTREAM_VVC_1)
      set_alert_stop_limit(TB_WARNING, 1);                     -- To prevent UART VVC SB from stopping the TB, increase the stop limit
      increment_expected_alerts_and_stop_limit(TB_WARNING, 1); -- Increment alert and stop limit for already enabled UART VVC SB 1
      --------------------------------------------------------------------------------

    else
      log(ID_LOG_HDR, "Unknown test case", C_SCOPE);
    end if;

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Set verbosity level
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    await_uvvm_completion(1000 ns, print_alert_counters => REPORT_ALERT_COUNTERS_FINAL, scope => C_SCOPE);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;
end architecture;