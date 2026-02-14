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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library external_vip_apb;
use external_vip_apb.apb_bfm_pkg.all;

--HDLRegression:tb
entity apb_bfm_tb is
  generic(
    GC_TESTCASE   : string := "UVVM";
    GC_ADDR_WIDTH : integer := 32;
    GC_DATA_WIDTH : integer := 32
  );
end entity apb_bfm_tb;

architecture tb of apb_bfm_tb is

  constant C_CLK_PERIOD : time    := 10 ns;
  constant C_REG_ADDR   : natural := 8; -- Must be addressable with the number of GC_ADDR_WIDTH bits

  signal clk                    : std_logic := '0';
  signal presetn                : std_logic := '1';
  signal paddr                  : std_logic_vector(GC_ADDR_WIDTH - 1 downto 0);
  signal pprot                  : std_logic_vector(2 downto 0);
  signal psel                   : std_logic;
  signal penable                : std_logic;
  signal pwrite                 : std_logic;
  signal pwdata                 : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal pstrb                  : std_logic_vector((GC_DATA_WIDTH / 8) - 1 downto 0);
  signal prdata                 : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
  signal pready                 : std_logic;
  signal pslverr                : std_logic;
  signal number_of_wait_states  : integer;
  signal terminate_loop         : std_logic := '0';

begin

  --------------------------------------------------------------------------------
  -- Clock generator
  --------------------------------------------------------------------------------
  p_clk : clk <= not clk after C_CLK_PERIOD;

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
      pclk                  => clk,
      presetn               => presetn,
      paddr                 => paddr,
      pprot                 => pprot,
      psel                  => psel,
      penable               => penable,
      pwrite                => pwrite,
      pwdata                => pwdata,
      pstrb                 => pstrb,
      prdata                => prdata,
      pready                => pready,
      pslverr               => pslverr,
      -- Control signals
      number_of_wait_states => number_of_wait_states
    );

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_apb_bfm_config : t_apb_bfm_config                                   := C_APB_BFM_CONFIG_DEFAULT;
    variable v_wr_data        : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable v_rd_data        : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable v_strb           : std_logic_vector((GC_DATA_WIDTH / 8) - 1 downto 0) := (others => '1');
    variable v_protection     : std_logic_vector(2 downto 0)                       := (others => '0');

    --------------------------------------------
    -- Overloads for this testbench
    --------------------------------------------
    procedure apb_write(
      addr        : in natural;
      data        : in std_logic_vector;
      byte_enable : in std_logic_vector;
      protection  : in std_logic_vector;
      msg         : in string) is
    begin
      apb_write(to_unsigned(addr, GC_ADDR_WIDTH), data, byte_enable, protection, msg,
        clk, paddr, pprot, psel, penable, pwrite, pwdata, pstrb, pready, pslverr, config => v_apb_bfm_config);
    end procedure;

    procedure apb_read(
      addr        : in  natural;
      data        : out std_logic_vector;
      protection  : in  std_logic_vector;
      msg         : in  string) is
    begin
      apb_read(to_unsigned(addr, GC_ADDR_WIDTH), data, protection, msg,
        clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr, config => v_apb_bfm_config);
    end procedure;

    procedure apb_check(
      addr        : in natural;
      exp_data    : in std_logic_vector;
      protection  : in std_logic_vector;
      msg         : in string) is
    begin
      apb_check(to_unsigned(addr, GC_ADDR_WIDTH), exp_data, protection, msg,
        clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr, config => v_apb_bfm_config);
    end procedure;

    procedure apb_poll_until(
      addr        : in natural;
      exp_data    : in std_logic_vector;
      protection  : in std_logic_vector;
      max_polls   : in integer;
      timeout     : in time;
      msg         : in string) is
    begin
      apb_poll_until(to_unsigned(addr, GC_ADDR_WIDTH), exp_data, protection, max_polls, timeout, msg,
        clk, paddr, pprot, psel, penable, pwrite, prdata, pstrb, pready, pslverr, terminate_loop, config => v_apb_bfm_config);
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of APB BFM");
    --------------------------------------------------------------------------------
    gen_pulse(presetn, '0', 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");
    wait for 10 * C_CLK_PERIOD;

    -- Test sequence
    log(ID_LOG_HDR, "Testing APB write/read/check with zero waitstates");
    number_of_wait_states <= 0;
    v_wr_data := random(GC_DATA_WIDTH);
    apb_write(C_REG_ADDR, v_wr_data, v_strb, v_protection, "Writing data");
    apb_read(C_REG_ADDR, v_rd_data, v_protection, "Reading data back");
    check_value(v_rd_data, v_wr_data, ERROR, "Checking read data");
    apb_check(C_REG_ADDR, v_wr_data, v_protection, "Checking written data");

    log(ID_LOG_HDR, "Testing APB write/read/check with 1 waitstate");
    number_of_wait_states <= 1;
    v_wr_data := random(GC_DATA_WIDTH);
    apb_write(C_REG_ADDR, v_wr_data, v_strb, v_protection, "Writing data");
    apb_read(C_REG_ADDR, v_rd_data, v_protection, "Reading data back");
    check_value(v_rd_data, v_wr_data, ERROR, "Checking read data");
    apb_check(C_REG_ADDR, v_wr_data, v_protection, "Checking written data");

    log(ID_LOG_HDR, "Testing APB write/read/check with 10 waitstates");
    number_of_wait_states <= 10;
    v_wr_data := random(GC_DATA_WIDTH);
    apb_write(C_REG_ADDR, v_wr_data, v_strb, v_protection, "Writing data");
    apb_read(C_REG_ADDR, v_rd_data, v_protection, "Reading data back");
    check_value(v_rd_data, v_wr_data, ERROR, "Checking read data");
    apb_check(C_REG_ADDR, v_wr_data, v_protection, "Checking written data");

    log(ID_LOG_HDR, "Testing APB pstrobe");
    number_of_wait_states <= random(2, 20);
    v_strb := (others => '0'); -- All written bytes should be ignored
    apb_write(C_REG_ADDR, random(GC_DATA_WIDTH), v_strb, v_protection, "Writing data");
    apb_read(C_REG_ADDR, v_rd_data, v_protection, "Reading data back");
    check_value(v_rd_data, v_wr_data, ERROR, "Checking read data");
    apb_check(C_REG_ADDR, v_wr_data, v_protection, "Checking written data");
    v_strb := (others => '1'); -- Enable all bits for other tests

    log(ID_LOG_HDR, "Testing APB protection levels");
    for i in 0 to 2 loop
      number_of_wait_states <= random(2, 20);
      v_wr_data       := random(GC_DATA_WIDTH);
      v_protection    := (others => '0');
      v_protection(i) := '1';
      if i = 1 then
        increment_expected_alerts_and_stop_limit(ERROR, 3, "Expecting errors due to non-secure access");
      end if;
      apb_write(C_REG_ADDR, v_wr_data, v_strb, v_protection, "Writing data with protection: " & to_string(v_protection));
      apb_check(C_REG_ADDR, v_wr_data, v_protection, "Checking written data");
    end loop;
    v_protection := (others => '0'); -- Reset protection bits for other tests

    log(ID_LOG_HDR, "Testing APB check with don't care values");
    number_of_wait_states <= random(2, 20);
    v_wr_data := random(GC_DATA_WIDTH);
    apb_write(C_REG_ADDR, v_wr_data, v_strb, v_protection, "Writing data");
    v_wr_data(2 downto 1) := "--";
    apb_check(C_REG_ADDR, v_wr_data, v_protection, "Checking written data");

    log(ID_LOG_HDR, "Testing APB poll until");
    number_of_wait_states <= random(2, 20);
    apb_poll_until(C_REG_ADDR, v_wr_data, v_protection, 1, 1 ms, "Testing apb_poll_until");

    log(ID_LOG_HDR, "Testing APB setup and hold times");
    v_apb_bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
    v_apb_bfm_config.clock_period := C_CLK_PERIOD;
    v_apb_bfm_config.setup_time   := C_CLK_PERIOD / 4;
    v_apb_bfm_config.hold_time    := C_CLK_PERIOD / 4;
    for i in 0 to 9 loop
      number_of_wait_states <= random(2, 20);
      v_wr_data := random(GC_DATA_WIDTH);
      apb_write(C_REG_ADDR, v_wr_data, v_strb, v_protection, "Writing data");
      apb_check(C_REG_ADDR, v_wr_data, v_protection, "Checking written data");
    end loop;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- Allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait; -- to stop completely
  end process p_main;

end architecture tb;
