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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_uart;
use bitvis_uart.uart_pif_pkg.all;

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_uart;
use bitvis_vip_uart.uart_bfm_pkg.all;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.slv8_sb_pkg.all;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

--hdlregression:tb
-- Test harness entity
entity sb_uart_sbi_demo_tb is
end entity sb_uart_sbi_demo_tb;

-- Test harness architecture
architecture func of sb_uart_sbi_demo_tb is

  constant C_SCOPE      : string  := "TB";
  constant C_ADDR_WIDTH : integer := 3;
  constant C_DATA_WIDTH : integer := 8;

  -- DSP interface and general control signals
  signal clk     : std_logic := '0';
  signal clk_ena : boolean   := false;
  signal arst    : std_logic := '0';

  -- SBI signals
  signal sbi_if         : t_sbi_if(addr(C_ADDR_WIDTH - 1 downto 0),
                                   wdata(C_DATA_WIDTH - 1 downto 0),
                                   rdata(C_DATA_WIDTH - 1 downto 0)) := init_sbi_if_signals(addr_width => C_ADDR_WIDTH,
                                                                   data_width => C_DATA_WIDTH);
  signal terminate_loop : std_logic                       := '0';

  -- UART signals
  signal uart_rx : std_logic := '1';
  signal uart_tx : std_logic := '1';

  constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

  -- One SB for each side of the DUT
  shared variable v_uart_sb : t_generic_sb;
  shared variable v_sbi_sb  : t_generic_sb;

begin

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => sbi_if.cs,
      addr  => sbi_if.addr,
      wr    => sbi_if.wena,
      rd    => sbi_if.rena,
      wdata => sbi_if.wdata,
      rdata => sbi_if.rdata,
      -- UART signals
      rx_a  => uart_tx,
      tx    => uart_rx
    );

  -----------------------------------------------------------------------------
  -- Clock generator
  -----------------------------------------------------------------------------
  p_clk : clock_generator(clk, clk_ena, C_CLK_PERIOD, "tb clock");

  -- Static '1' ready signal for the SBI VVC
  sbi_if.ready <= '1';

  -- Toggle the reset after 5 clock periods
  p_arst : arst <= '1', '0' after 5 * C_CLK_PERIOD;

  -----------------------------------------------------------------------------
  -- Sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
    variable v_data        : std_logic_vector(7 downto 0);
    variable v_uart_config : t_uart_bfm_config;
  begin
    set_log_file_name("sb_uart_sbi_demo_log.txt");
    set_alert_file_name("sb_uart_sbi_demo_alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_POS_ACK);
    --disable_log_msg(ID_SEQUENCER_SUB);

    log(ID_LOG_HDR_XL, "SCOREBOARD UART-SBI DEMO ", C_SCOPE);
    ------------------------------------------------------------
    clk_ena <= true;
    wait for 1 ns;
    await_value(arst, '0', 0 ns, 6 * C_CLK_PERIOD, TB_ERROR, "await deassertion of arst", C_SCOPE);
    wait for C_CLK_PERIOD;

    ------------------------------------------------------------
    -- Config
    ------------------------------------------------------------
    -- Set scope of SBs
    v_uart_sb.set_scope("SB UART");
    v_sbi_sb.set_scope("SB SBI");

    log(ID_LOG_HDR, "Set configuration", C_SCOPE);
    v_uart_sb.config(C_SB_CONFIG_DEFAULT, "Set config for SB UART");
    v_sbi_sb.config(C_SB_CONFIG_DEFAULT, "Set config for SB SBI");

    log(ID_LOG_HDR, "Enable SBs", C_SCOPE);
    v_uart_sb.enable(VOID);
    v_sbi_sb.enable(VOID);

    -- Enable log msg for data
    v_uart_sb.enable_log_msg(ID_DATA);
    v_sbi_sb.enable_log_msg(ID_DATA);

    v_uart_config          := C_UART_BFM_CONFIG_DEFAULT;
    v_uart_config.bit_time := C_CLK_PERIOD * 16;

    ------------------------------------------------------------
    -- UART --> SBI
    ------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Send data UART --> SBI", C_SCOPE);
    for i in 1 to 5 loop
      for j in 1 to 4 loop
        v_data := random(8);
        v_sbi_sb.add_expected(v_data);
        uart_transmit(v_data, "data to DUT", uart_tx, v_uart_config);
      end loop;

      for j in 1 to 4 loop
        sbi_poll_until(to_unsigned(C_ADDR_RX_DATA_VALID, 3), x"01", 0, 100 ns, "wait on data valid", clk, sbi_if, terminate_loop);
        sbi_read(to_unsigned(C_ADDR_RX_DATA, 3), v_data, "read data from DUT", clk, sbi_if);
        v_sbi_sb.check_received(v_data);
      end loop;
    end loop;

    -- print report of counters
    v_sbi_sb.report_counters(VOID);

    ------------------------------------------------------------
    -- SBI --> UART
    ------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Send data SBI --> UART", C_SCOPE);
    for i in 1 to 5 loop
      for j in 1 to 4 loop
        v_data := random(8);
        v_uart_sb.add_expected(v_data);
        sbi_poll_until(to_unsigned(C_ADDR_TX_READY, 3), x"01", 0, 100 ns, "wait on TX ready", clk, sbi_if, terminate_loop);
        sbi_write(to_unsigned(C_ADDR_TX_DATA, 3), v_data, "write data to DUT", clk, sbi_if);
        uart_receive(v_data, "data from DUT", uart_rx, terminate_loop, v_uart_config);
        v_uart_sb.check_received(v_data);
      end loop;
    end loop;

    -- print report of counters
    v_uart_sb.report_counters(VOID);

    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    std.env.stop;
    wait;

  end process;

end architecture func;
