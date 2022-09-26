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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

-- Include Verification IPs
library bitvis_vip_gpio;
context bitvis_vip_gpio.vvc_context;

--hdlregression:tb
-- Test case entity
entity gpio_vip_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of gpio_vip_tb is

  constant C_CLK_PERIOD        : time    := 10 ns;
  constant C_SCOPE             : string  := C_TB_SCOPE_DEFAULT;
  constant C_GPIO_WIDTH        : natural := 8;
  constant C_GPIO_SET_MAX_TIME : time    := 1 ps;

  signal gpio_1_input  : std_logic_vector(C_GPIO_WIDTH - 1 downto 0);
  signal gpio_2_output : std_logic_vector(C_GPIO_WIDTH - 1 downto 0);
  signal gpio_3_inout  : std_logic_vector(C_GPIO_WIDTH - 1 downto 0);

  procedure set_gpio(
    signal   pins   : out std_logic_vector;
    constant data : std_logic_vector;
    constant msg  : string
  ) is
  begin
    if pins'length /= data'length then
      alert(TB_ERROR, "pin length " & to_string(pins'length) & " and data length " & to_string(data'length) & " doesn't match.");
    end if;
    log("Setting GPIO to " & to_string(data, BIN) & ". " & add_msg_delimiter(msg));
    pins <= data;
  end procedure;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -- GPIO as input
  i1_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => C_GPIO_WIDTH,
      GC_INSTANCE_IDX       => 1,
      GC_DEFAULT_LINE_VALUE => x"ZZ"
    )
    port map(
      gpio_vvc_if => gpio_1_input
    );

  -- GPIO as output
  i2_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => C_GPIO_WIDTH,
      GC_INSTANCE_IDX       => 2,
      GC_DEFAULT_LINE_VALUE => x"00"
    )
    port map(
      gpio_vvc_if => gpio_2_output
    );

  -- GPIO as input/output
  i3_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => C_GPIO_WIDTH,
      GC_INSTANCE_IDX       => 3,
      GC_DEFAULT_LINE_VALUE => x"ZZ"
    )
    port map(
      gpio_vvc_if => gpio_3_inout
    );

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- Helper variables
    variable v_received_data : bitvis_vip_gpio.vvc_cmd_pkg.t_vvc_result;
    variable v_set_data      : std_logic_vector(7 downto 0);
    variable v_expect_data   : std_logic_vector(7 downto 0);
    variable v_vvc_id        : natural;
    variable v_cmd_idx       : natural;
    variable v_is_ok         : boolean;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    set_alert_stop_limit(error, 2);
    set_alert_stop_limit(TB_WARNING, 5);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);

    disable_log_msg(GPIO_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(GPIO_VVCT, 1, ID_BFM);

    disable_log_msg(GPIO_VVCT, 2, ALL_MESSAGES);
    enable_log_msg(GPIO_VVCT, 2, ID_BFM);

    disable_log_msg(GPIO_VVCT, 3, ALL_MESSAGES);
    enable_log_msg(GPIO_VVCT, 3, ID_BFM);

    log(ID_LOG_HDR, "Verifying TLM + GPIO executor + BFM", C_SCOPE);
    wait for C_CLK_PERIOD * 10;
    ------------------------------------------------------------

    --------------------------------------------------------------------------------------
    --
    -- Checking of initial state
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Checking initial state of output VVC", C_SCOPE);

    --
    -- Check GPIO initial setting is 0x00
    --
    check_value(gpio_2_output, "00000000", error, "Checking initial value of GPIO VVC 2");

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC Set method
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Set", C_SCOPE);

    --
    -- Set GPIO setting to 0xAA. Check GPIO setting
    --
    v_set_data    := x"FF";             -- "1111 11111"
    v_expect_data := v_set_data;
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");
    wait for C_CLK_PERIOD;              -- Margin

    --
    -- Set GPIO setting to 0xAA. Check GPIO setting
    --
    v_set_data    := x"AA";             -- "1010 1010"
    v_expect_data := v_set_data;
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");
    wait for C_CLK_PERIOD;              -- Margin

    --
    -- Set GPIO setting to 0x00. Check GPIO setting
    --
    v_set_data    := x"00";             -- "0000 0000"
    v_expect_data := v_set_data;
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");
    wait for C_CLK_PERIOD * 4;          -- Margin

    --
    -- Set GPIO setting to 0xFF. Check GPIO setting
    --
    v_set_data    := x"FF";             -- "1111 1111"
    v_expect_data := v_set_data;
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");
    wait for C_CLK_PERIOD * 4;          -- Margin

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC Set method with don't care
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Set with don't care", C_SCOPE);

    --
    -- GPIO status is 0xFF. Test by setting bit 4-7, don't touch bit 0-3
    --
    v_set_data    := x"5-";             -- "0101 ----", should now be 0x5F
    v_expect_data := x"5F";
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");

    --
    -- GPIO setting is 0x5F. Test by setting bit 0-3, don't touch bit 4-7
    --
    v_set_data    := x"-A";             -- "---- 1010", should now be 0x5A
    v_expect_data := x"5A";
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");
    wait for C_CLK_PERIOD * 4;          -- Margin

    --
    -- Set GPIO setting to 0x55. Check bit 0 and bit 4, ignore bit 1-3 and 5-7
    --
    v_set_data    := "01010101";        -- 0x55
    v_expect_data := "---1---1";
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");

    --
    -- Set GPIO bit 1-3 and bit 5-7. Change bit 1-3 and 5-7, check bit 0 and bit 4
    --
    v_set_data := "101-101-";
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");
    wait for C_CLK_PERIOD;              -- Margin

    --
    -- Set GPIO setting to 0xAZ. Check bit 4-7 is A, ignore bit 0-3
    --
    v_set_data    := x"AZ";
    v_expect_data := "1010----";
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting gpio 2 to 0x" & to_string(v_set_data, HEX) & " (" & to_string(v_set_data, BIN) & ").");
    await_completion(GPIO_VVCT, 2, C_GPIO_SET_MAX_TIME);
    check_value(gpio_2_output, v_expect_data, error, "Checking value of GPIO VVC 2");
    wait for C_CLK_PERIOD;              -- Margin

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC Get method
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Get", C_SCOPE);

    --
    -- Set GPIO 1 input manually to 0x1D. Test GPIO Get method and check
    -- received data from GPIO setting.
    --
    log("Testing get on GPIO VVC 1");
    v_set_data    := x"1D";
    v_expect_data := v_set_data;
    set_gpio(gpio_1_input, v_set_data, "GPIO 1 input");
    -- Perform get, which stores the data in the VVC
    gpio_get(GPIO_VVCT, 1, "Readback inside VVC");
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 1); -- for last get
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_get to finish");
    -- Fetch the result from index v_cmd_idx (last index set above)
    fetch_result(GPIO_VVCT, 1, v_cmd_idx, v_received_data, v_is_ok, "Fetching get-result");
    -- Check if get was OK and that the data is correct
    check_value(v_is_ok, error, "Readback OK via fetch_result()");
    check_value(v_received_data, v_expect_data, error, "Readback data via fetch_result()");
    wait for C_CLK_PERIOD * 4;          -- Margin

    --
    -- Test GPIO Get method using Scoreboard to check received data.
    --
    log("Testing get on GPIO VVC 1 using SB");
    v_set_data := x"5A";
    set_gpio(gpio_1_input, v_set_data, "GPIO 1 input");
    GPIO_VVC_SB.add_expected(1, pad_gpio_sb(v_set_data));
    -- Perform get, which stores the data in the VVC's Scoreboard
    gpio_get(GPIO_VVCT, 1, TO_SB, "Readback inside VVC using SB");
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_get to finish");
    wait for C_CLK_PERIOD * 4;          -- Margin

    log("Testing get on GPIO VVC 2 using SB");
    v_set_data := x"B8";
    gpio_set(GPIO_VVCT, 2, v_set_data, "Setting GPIO 2 input.");
    GPIO_VVC_SB.add_expected(2, pad_gpio_sb(v_set_data));
    -- Perform get, which stores the data in the VVC's Scoreboard
    gpio_get(GPIO_VVCT, 2, TO_SB, "Readback inside VVC using SB");
    await_completion(GPIO_VVCT, 2, v_cmd_idx, 100 ns, "Wait for gpio_get to finish");
    wait for C_CLK_PERIOD * 4;          -- Margin

    GPIO_VVC_SB.report_counters(ALL_INSTANCES);

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC Check method
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Check", C_SCOPE);

    --
    -- Set GPIO 1 input manually to 0x55. Call GPIO Check and check actual GPIO
    -- setting with expected GPIO setting.
    --
    log("Testing check on GPIO VVC 1");
    v_set_data    := x"55";
    v_expect_data := v_set_data;
    set_gpio(gpio_1_input, v_set_data, "GPIO 1 input");
    wait for C_CLK_PERIOD;
    -- Perform get, which stores the data in the VVC
    gpio_check(GPIO_VVCT, 1, v_expect_data, "Readback inside VVC", error);
    wait for C_CLK_PERIOD * 4;

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC Check Stable method
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Check Stable", C_SCOPE);

    --
    -- Set GPIO 1 input to 0x77. Call GPIO Check Stable and check actual GPIO
    -- setting is same as expected and that it has been stable for a certain time.
    --
    log("Testing check_stable on GPIO VVC 1");
    v_set_data    := x"77";
    v_expect_data := v_set_data;
    set_gpio(gpio_1_input, v_set_data, "GPIO 1 input");
    wait for C_CLK_PERIOD * 5;
    -- Perform get, which stores the data in the VVC
    gpio_check_stable(GPIO_VVCT, 1, v_expect_data, C_CLK_PERIOD * 5, "Readback inside VVC", error);
    await_completion(GPIO_VVCT, 1, 1 us, "Wait for gpio_check_stable to finish");

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC Expect method
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Expect", C_SCOPE);

    --
    -- Set GPIO setting to 0xFF. Test GPIO Expect and that GPIO setting is
    -- updated immediately (within 0 ns).
    --
    log("Testing gpio_expect as instant change check");
    v_set_data    := x"FF";
    v_expect_data := v_set_data;
    set_gpio(gpio_1_input, v_set_data, "Setting GPIO 1 input to 0xff");
    gpio_expect(GPIO_VVCT, 1, v_expect_data, 0 ns, "Checking GPIO 1", error);
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 1); -- for last get
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");

    --
    -- Set GPIO setting to 0xFF, then to 0x12 after 90 ns. Test GPIO Expect
    -- with delay by checking that GPIO setting is set to 0x12 after 100 ns.
    --
    log("Testing gpio_expect where value is correct after a delay");
    v_set_data    := x"FF";
    v_expect_data := x"12";
    set_gpio(gpio_1_input, v_set_data, "Setting GPIO 1 input to 0xff");
    wait for C_CLK_PERIOD;
    gpio_expect(GPIO_VVCT, 1, v_expect_data, 100 ns, "Checking GPIO 1", error);
    wait for 80 ns;
    v_set_data    := x"12";
    set_gpio(gpio_1_input, v_set_data, "Setting GPIO 1 input to 0x12");
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 1); -- for last get
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");

    --
    -- Set GPIO setting to 0xFF, 0xAA, 0xAB, 0xAC and finally 0x00. Test GPIO
    -- Expect by checking that GPIO setting is set to 0x00 after 10 clk periods.
    --
    log("Testing gpio_expect where value is not first to arrive");
    v_set_data    := x"FF";
    v_expect_data := x"00";
    set_gpio(gpio_1_input, v_set_data, "Setting GPIO 1 input to 0xff");
    wait for C_CLK_PERIOD;
    gpio_expect(GPIO_VVCT, 1, v_expect_data, C_CLK_PERIOD * 10, "Checking GPIO 1", error);
    wait for C_CLK_PERIOD;
    set_gpio(gpio_1_input, x"aa", "Setting GPIO 1 input to 0xaa");
    set_gpio(gpio_1_input, x"ab", "Setting GPIO 1 input to 0xab");
    set_gpio(gpio_1_input, x"ac", "Setting GPIO 1 input to 0xac");
    set_gpio(gpio_1_input, x"00", "Setting GPIO 1 input to 0x00");
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 1); -- for last get
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC Expect Stable method
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Expect Stable", C_SCOPE);
    --
    -- Set GPIO 1 input to 0xAA. Call GPIO Expect Stable and check actual GPIO
    -- setting is same as expected and that it remains stable for a certain time.
    --
    log("Testing gpio_expect_stable with expected stable value FROM_NOW");
    v_set_data    := x"AA";
    v_expect_data := v_set_data;
    set_gpio(gpio_1_input, v_set_data, "Setting GPIO 1 input to 0xAA");
    gpio_expect_stable(GPIO_VVCT, 1, v_expect_data, C_CLK_PERIOD * 5, FROM_NOW, 0 ns, "Checking GPIO 1", error);
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 1); -- for last get
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_expect_stable to finish");

    --
    -- Set GPIO 1 input to 0xBB and wait. Call GPIO Expect Stable and check actual GPIO
    -- setting is same as expected and that it has been stable for a certain time after
    -- the last event.
    --
    log("Testing gpio_expect_stable with expected stable value FROM_LAST_EVENT");
    v_set_data    := x"BB";
    v_expect_data := v_set_data;
    set_gpio(gpio_1_input, v_set_data, "Setting GPIO 1 input to 0xBB");
    wait for C_CLK_PERIOD * 5;
    gpio_expect_stable(GPIO_VVCT, 1, v_expect_data, C_CLK_PERIOD * 10, FROM_LAST_EVENT, 0 ns, "Checking GPIO 1", error);
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 1); -- for last get
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_expect_stable to finish");

    --
    -- Set GPIO 1 input to 0xCC after 10 ns. Call GPIO Expect Stable and wait until actual GPIO
    -- setting is same as expected and that it remains stable for a certain time.
    --
    log("Testing gpio_expect_stable with expected stable value after a delayed update");
    v_set_data    := x"CC";
    v_expect_data := v_set_data;
    gpio_expect_stable(GPIO_VVCT, 1, v_expect_data, C_CLK_PERIOD * 5, FROM_NOW, 20 ns, "Checking GPIO 1", error);
    wait for 10 ns;
    set_gpio(gpio_1_input, v_set_data, "Setting GPIO 1 input to 0xCC");
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 1); -- for last get
    await_completion(GPIO_VVCT, 1, v_cmd_idx, 100 ns, "Wait for gpio_expect_stable to finish");

    --------------------------------------------------------------------------------------
    --
    -- Test of GPIO VVC as inout port
    --
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO VVC as inout port", C_SCOPE);

    for i in 0 to 1 loop
      log("GPIO 3 port is 'Z', set data using the DUT to configure as input");
      v_set_data    := x"55";
      v_expect_data := v_set_data;
      set_gpio(gpio_3_inout, v_set_data, "Setting GPIO 3 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      gpio_expect(GPIO_VVCT, 3, v_expect_data, 0 ns, "Checking GPIO 3", error);
      v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
      await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");
      wait for C_CLK_PERIOD;

      v_set_data    := x"AA";
      v_expect_data := v_set_data;
      set_gpio(gpio_3_inout, v_set_data, "Setting GPIO 3 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      gpio_expect(GPIO_VVCT, 3, v_expect_data, 0 ns, "Checking GPIO 3", error);
      v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
      await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");
      wait for C_CLK_PERIOD;

      log("Set GPIO 3 port to 'Z' from the DUT to release the port");
      v_set_data := x"ZZ";
      set_gpio(gpio_3_inout, v_set_data, "Releasing the port");
      await_completion(GPIO_VVCT, 3, C_GPIO_SET_MAX_TIME);
      wait for C_CLK_PERIOD;

      log("GPIO 3 port is 'Z', set data using the VVC to configure as output");
      v_set_data    := x"FF";
      v_expect_data := v_set_data;
      gpio_set(GPIO_VVCT, 3, v_set_data, "Setting GPIO 3 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      await_completion(GPIO_VVCT, 3, C_GPIO_SET_MAX_TIME);
      check_value(gpio_3_inout, v_expect_data, error, "Checking value of GPIO VVC 3");
      wait for C_CLK_PERIOD;

      v_set_data    := x"33";
      v_expect_data := v_set_data;
      gpio_set(GPIO_VVCT, 3, v_set_data, "Setting GPIO 3 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      await_completion(GPIO_VVCT, 3, C_GPIO_SET_MAX_TIME);
      check_value(gpio_3_inout, v_expect_data, error, "Checking value of GPIO VVC 3");
      wait for C_CLK_PERIOD;

      log("Set GPIO 3 port to 'Z' from the VVC to release the port");
      v_set_data := x"ZZ";
      gpio_set(GPIO_VVCT, 3, v_set_data, "Releasing the port");
      await_completion(GPIO_VVCT, 3, C_GPIO_SET_MAX_TIME);
      wait for C_CLK_PERIOD;
    end loop;

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

end func;
