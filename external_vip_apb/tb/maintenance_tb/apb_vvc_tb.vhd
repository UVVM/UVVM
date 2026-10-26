--================================================================================================================================
-- Copyright 2026 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library external_vip_apb;
context external_vip_apb.vvc_context;
use external_vip_apb.vvc_sb_support_pkg.all;

--HDLRegression:tb
entity apb_vvc_tb is
  generic(
    GC_TESTCASE   : string := "UVVM";
    GC_ADDR_WIDTH : integer := 32;
    GC_DATA_WIDTH : integer := 32
  );
end entity apb_vvc_tb;

architecture tb of apb_vvc_tb is

  constant C_CLK_PERIOD   : time    := 10 ns;
  constant C_REG_ADDR     : natural := 8; -- Must be addressable with the number of GC_ADDR_WIDTH bits
  constant C_REG_ADDR_UNS : unsigned := to_unsigned(C_REG_ADDR, GC_ADDR_WIDTH);

  signal presetn : std_logic := '1';
  signal apb_if  : t_apb_if(paddr(GC_ADDR_WIDTH-1 downto 0),
                            pwdata(GC_DATA_WIDTH-1 downto 0),
                            prdata(GC_DATA_WIDTH-1 downto 0),
                            pstrb((GC_DATA_WIDTH/8)-1 downto 0)
                            );

begin

  --------------------------------------------------------------------------------
  -- Clock generator
  --------------------------------------------------------------------------------
  p_clk : clock_generator(apb_if.pclk, C_CLK_PERIOD);

  --------------------------------------------------------------------------------
  -- DUT
  --------------------------------------------------------------------------------
  i_dut : entity work.apb_register
    generic map (
      GC_REG_ADDR   => C_REG_ADDR,
      GC_ADDR_WIDTH => GC_ADDR_WIDTH,
      GC_DATA_WIDTH => GC_DATA_WIDTH
    ) port map (
      -- APB Interface
      pclk                  => apb_if.pclk,
      presetn               => presetn,
      paddr                 => apb_if.paddr,
      pprot                 => apb_if.pprot,
      psel                  => apb_if.psel,
      penable               => apb_if.penable,
      pwrite                => apb_if.pwrite,
      pwdata                => apb_if.pwdata,
      pstrb                 => apb_if.pstrb,
      prdata                => apb_if.prdata,
      pready                => apb_if.pready,
      pslverr               => apb_if.pslverr,
      -- Control signals
      number_of_wait_states => 0
    );

  --------------------------------------------------------------------------------
  -- APB VVC
  --------------------------------------------------------------------------------
  i_apb_vvc_inst : entity external_vip_apb.apb_vvc
    generic map(
      GC_ADDR_WIDTH => GC_ADDR_WIDTH,
      GC_DATA_WIDTH => GC_DATA_WIDTH
    )
    port map (
      apb_vvc_master_if => apb_if
    );

  --------------------------------------------------------------------------------
  -- UVVM engine
  --------------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_wr_data     : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable v_rd_data     : external_vip_apb.vvc_cmd_pkg.t_vvc_result;
    variable v_strb        : std_logic_vector((GC_DATA_WIDTH / 8) - 1 downto 0) := (others => '1');
    variable v_protection  : std_logic_vector(2 downto 0)                       := (others => '0');
    variable v_cmd_idx     : natural;
    variable v_alert_level : t_alert_level;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 2;
    alias prdata  is << signal i_dut.prdata  : std_logic_vector >>;
    alias pslverr is << signal i_dut.pslverr : std_logic >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_level : in t_alert_level
    ) is
      variable v_num_expected_alerts : natural;
      variable v_rand                : t_rand;
    begin
      -- Number of total expected alerts: (number of signals tested individually + number of signals tested together) x 1 toggle
      if alert_level /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_level, (C_NUM_VVC_SIGNALS + C_NUM_VVC_SIGNALS) * 2);
      end if;
      for i in 0 to C_NUM_VVC_SIGNALS loop
        -- Force new value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => prdata  <= force not prdata;
                    pslverr <= force not pslverr;
          when 1 => prdata  <= force not prdata;
          when 2 => pslverr <= force not pslverr;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => prdata  <= release;
                    pslverr <= release;
          when 1 => prdata  <= release;
          when 2 => pslverr <= release;
        end case;
        wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
        wait for 0 ns;
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
      end loop;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Verbosity control
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(ID_AWAIT_COMPLETION_WAIT);
    disable_log_msg(ID_IMMEDIATE_CMD);
    disable_log_msg(APB_VVCT, 0, ID_CMD_INTERPRETER);
    disable_log_msg(APB_VVCT, 0, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(APB_VVCT, 0, ID_CMD_EXECUTOR);
    disable_log_msg(APB_VVCT, 0, ID_CMD_EXECUTOR_WAIT);

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of APB VVC");
    --------------------------------------------------------------------------------
    gen_pulse(presetn, '0', 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");
    wait for 10 * C_CLK_PERIOD;

    -- Test sequence
    log(ID_LOG_HDR, "Testing APB write/read/check without byte_enable or protection");
    for i in 0 to 9 loop
      v_wr_data := random(GC_DATA_WIDTH);
      apb_write(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Writing data");
      apb_read(APB_VVCT, 0, C_REG_ADDR_UNS, "Reading data back");
      v_cmd_idx := get_last_received_cmd_idx(APB_VVCT, 0);
      await_completion(APB_VVCT, 0, v_cmd_idx, 10 us);
      fetch_result(APB_VVCT, 0, v_cmd_idx, v_rd_data);
      check_value(v_rd_data, v_wr_data, ERROR, "Checking read data");
      apb_check(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Checking written data");
    end loop;
    await_completion(APB_VVCT, 0, 1 ms);

    log(ID_LOG_HDR, "Testing APB pstrobe");
    v_strb := (others => '0'); -- All written bytes should be ignored
    apb_write(APB_VVCT, 0, C_REG_ADDR_UNS, random(GC_DATA_WIDTH), v_strb, v_protection, "Writing data");
    apb_read(APB_VVCT, 0, C_REG_ADDR_UNS, v_protection, "Reading data back");
    v_cmd_idx := get_last_received_cmd_idx(APB_VVCT, 0);
    await_completion(APB_VVCT, 0, v_cmd_idx, 10 us);
    fetch_result(APB_VVCT, 0, v_cmd_idx, v_rd_data);
    check_value(v_rd_data, v_wr_data, ERROR, "Checking read data");
    apb_check(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Checking written data");
    v_strb := (others => '1'); -- Enable all bits for other tests
    await_completion(APB_VVCT, 0, 1 ms);

    log(ID_LOG_HDR, "Testing APB protection levels");
    for i in 0 to 2 loop
      v_wr_data       := random(GC_DATA_WIDTH);
      v_protection    := (others => '0');
      v_protection(i) := '1';
      if i = 1 then
        increment_expected_alerts_and_stop_limit(ERROR, 3, "Expecting errors due to non-secure access");
      end if;
      apb_write(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, v_strb, v_protection, "Writing data with protection: " & to_string(v_protection));
      apb_check(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, v_protection, "Checking written data");
    end loop;
    v_protection := (others => '0'); -- Reset protection bits for other tests
    await_completion(APB_VVCT, 0, 1 ms);

    log(ID_LOG_HDR, "Testing APB check with don't care values");
    v_wr_data := random(GC_DATA_WIDTH);
    apb_write(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Writing data");
    v_wr_data(2 downto 1) := "--";
    apb_check(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Checking written data");
    await_completion(APB_VVCT, 0, 1 ms);

    log(ID_LOG_HDR, "Testing APB poll until");
    apb_poll_until(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Testing apb_poll_until", 1, 1 ms);
    await_completion(APB_VVCT, 0, 1 ms);
    apb_poll_until(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, v_protection, "Testing apb_poll_until", 1, 1 ms);
    await_completion(APB_VVCT, 0, 1 ms);

    log(ID_LOG_HDR, "Testing APB setup and hold times");
    shared_apb_vvc_config(0).bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
    shared_apb_vvc_config(0).bfm_config.clock_period := C_CLK_PERIOD;
    shared_apb_vvc_config(0).bfm_config.setup_time   := C_CLK_PERIOD / 4;
    shared_apb_vvc_config(0).bfm_config.hold_time    := C_CLK_PERIOD / 4;
    for i in 0 to 9 loop
      v_wr_data := random(GC_DATA_WIDTH);
      apb_write(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Writing data");
      apb_check(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Checking written data");
    end loop;
    await_completion(APB_VVCT, 0, 1 ms);

    log(ID_LOG_HDR, "Testing APB scoreboard");
    for i in 0 to 9 loop
      v_wr_data := random(GC_DATA_WIDTH);
      apb_write(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Writing data");
      apb_vvc_sb.add_expected(0, pad_apb_sb(v_wr_data));
      apb_read(APB_VVCT, 0, C_REG_ADDR_UNS, TO_SB, "Reading data back into SB");
    end loop;
    await_completion(APB_VVCT, 0, 1 ms);
    apb_vvc_sb.report_counters(0);

    log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC");
    for i in 0 to 2 loop
      -- Test different alert severity configurations
      if i = 0 then
        v_alert_level := C_APB_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
      elsif i = 1 then
        v_alert_level := FAILURE;
      else
        v_alert_level := NO_ALERT;
      end if;
      log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)));
      shared_apb_vvc_config(0).unwanted_activity_severity := v_alert_level;

      log(ID_SEQUENCER, "Testing normal data transmission");
      v_wr_data := random(GC_DATA_WIDTH);
      apb_write(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Writing data");
      apb_check(APB_VVCT, 0, C_REG_ADDR_UNS, v_wr_data, "Checking written data");
      await_completion(APB_VVCT, 0, 1 ms);

      -- Test with and without a time gap between await_completion and unexpected data transmission
      if i = 0 then
        log(ID_SEQUENCER, "Wait 100 ns");
        wait for 100 ns;
      end if;

      log(ID_SEQUENCER, "Testing unexpected data transmission");
      toggle_vvc_if(v_alert_level);
    end loop;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    await_uvvm_completion(1000 ns, print_alert_counters => REPORT_ALERT_COUNTERS_FINAL, scope => C_SCOPE);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait; -- to stop completely

  end process p_main;

end architecture tb;