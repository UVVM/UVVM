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
use bitvis_vip_gpio.vvc_sb_support_pkg.all;

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
  constant C_GPIO_SET_MAX_TIME : time    := 1 ps;

  signal gpio_1_input  : std_logic_vector(0 downto 0);
  signal gpio_2_input  : std_logic_vector(1 downto 0);
  signal gpio_3_input  : std_logic_vector(7 downto 0);
  signal gpio_4_input  : std_logic_vector(1023 downto 0);
  
  signal gpio_5_output : std_logic_vector(0 downto 0);
  signal gpio_6_output : std_logic_vector(1 downto 0);
  signal gpio_7_output : std_logic_vector(7 downto 0);
  signal gpio_8_output : std_logic_vector(1023 downto 0);
  
  signal gpio_9_inout  : std_logic_vector(7 downto 0);

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
      GC_DATA_WIDTH         => 1,
      GC_INSTANCE_IDX       => 1,
      GC_DEFAULT_LINE_VALUE => "Z"
    )
    port map(
      gpio_vvc_if => gpio_1_input
    );
    
  -- GPIO as input
  i2_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 2,
      GC_INSTANCE_IDX       => 2,
      GC_DEFAULT_LINE_VALUE => "ZZ"
    )
    port map(
      gpio_vvc_if => gpio_2_input
    );
    
  -- GPIO as input
  i3_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 8,
      GC_INSTANCE_IDX       => 3,
      GC_DEFAULT_LINE_VALUE => x"ZZ"
    )
    port map(
      gpio_vvc_if => gpio_3_input
    );

  -- GPIO as input
  i4_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 1024,
      GC_INSTANCE_IDX       => 4,
      GC_DEFAULT_LINE_VALUE => (others => 'Z')
    )
    port map(
      gpio_vvc_if => gpio_4_input
    );
    
  ---------------------------------------------------------------

  -- GPIO as output
  i5_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 1,
      GC_INSTANCE_IDX       => 5,
      GC_DEFAULT_LINE_VALUE => "0"
    )
    port map(
      gpio_vvc_if => gpio_5_output
    );
    
  -- GPIO as output
  i6_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 2,
      GC_INSTANCE_IDX       => 6,
      GC_DEFAULT_LINE_VALUE => "00"
    )
    port map(
      gpio_vvc_if => gpio_6_output
    );

  -- GPIO as output
  i7_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 8,
      GC_INSTANCE_IDX       => 7,
      GC_DEFAULT_LINE_VALUE => x"00"
    )
    port map(
      gpio_vvc_if => gpio_7_output
    );

  -- GPIO as output
  i8_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 1024,
      GC_INSTANCE_IDX       => 8,
      GC_DEFAULT_LINE_VALUE => (others => '0')
    )
    port map(
      gpio_vvc_if => gpio_8_output
    );
    
  ---------------------------------------------------------------   

  -- GPIO as input/output
  i9_gpio_vvc : entity work.gpio_vvc
    generic map(
      GC_DATA_WIDTH         => 8,
      GC_INSTANCE_IDX       => 9,
      GC_DEFAULT_LINE_VALUE => x"ZZ"
    )
    port map(
      gpio_vvc_if => gpio_9_inout
    );

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- Helper variables
    variable v_received_data : bitvis_vip_gpio.vvc_cmd_pkg.t_vvc_result;
    variable v_set_data      : std_logic_vector(7 downto 0);
    variable v_expect_data   : std_logic_vector(7 downto 0);
    variable v_data_1024     : std_logic_vector(1023 downto 0);
    variable v_data_exp_1024 : std_logic_vector(1023 downto 0);
    variable v_vvc_id        : natural;
    variable v_cmd_idx       : natural;
    variable v_is_ok         : boolean;
    
    -- Procedure / Functions
      
    ----------------------------------------------------------------------
    -- Test GPIO VVC Set method
    ----------------------------------------------------------------------
    procedure set_and_check_gpio(
      constant vvc_instance_idx : natural;
      signal   vvc_output       : std_logic_vector;
      constant data             : std_logic_vector;
      constant expected_data    : std_logic_vector
      ) is
    begin
      log(ID_SEQUENCER_SUB, "xxx Testing get on GPIO VVC " & to_string(vvc_instance_idx));
      -- Set GPIO setting to 0xAA. Check GPIO setting
      gpio_set(GPIO_VVCT, vvc_instance_idx, data, "Setting gpio " & to_string(vvc_instance_idx) & " to 0x" & to_string(data, HEX) & ").");
      await_completion(GPIO_VVCT, vvc_instance_idx, C_GPIO_SET_MAX_TIME);
      check_value(vvc_output, expected_data, error, "Checking value of GPIO VVC " & to_string(vvc_instance_idx));
      wait for C_CLK_PERIOD * 4;              -- Margin
    end procedure set_and_check_gpio;
   
    ----------------------------------------------------------------------
    -- Test of GPIO VVC Get method
    ----------------------------------------------------------------------
    procedure get_and_check_gpio(
      constant vvc_instance_idx : natural;
      signal   vvc_input        : out std_logic_vector;
      constant data             : std_logic_vector
      ) is
      variable v_cmd_idx        : natural;
      variable v_received_data  : bitvis_vip_gpio.vvc_cmd_pkg.t_vvc_result;
      variable v_is_ok          : boolean;
    begin
      log(ID_SEQUENCER_SUB, "Testing get on GPIO VVC " & to_string(vvc_instance_idx));
      set_gpio(vvc_input, data, "GPIO " & to_string(vvc_instance_idx) & " input");
      -- Perform get, which stores the data in the VVC
      gpio_get(GPIO_VVCT, vvc_instance_idx, "Readback inside VVC");
      v_cmd_idx := get_last_received_cmd_idx(GPIO_VVCT, vvc_instance_idx);  -- for last get
      await_completion(GPIO_VVCT, vvc_instance_idx, v_cmd_idx, 100 ns, "Wait for gpio_get to finish");
      -- Fetch the result from index v_cmd_idx (last index set above)
      fetch_result(GPIO_VVCT, vvc_instance_idx, v_cmd_idx, v_received_data, v_is_ok, "Fetching get-result");

      -- Check if get was OK and that data is correct
      check_value(v_is_ok, error,"Readback OK via fetch_result()");
      check_value(v_received_data, data, error, "Readback data via fetch_result()");
      wait for C_CLK_PERIOD * 4;    -- margin
    end procedure get_and_check_gpio;
    
    ----------------------------------------------------------------------
    -- Test of GPIO VVC Get method using Scoreboard to check received data
    ----------------------------------------------------------------------
    procedure get_and_check_gpio_sb(
      constant vvc_instance_idx : natural;
      signal   vvc_input        : out std_logic_vector;
      constant data             : std_logic_vector
      ) is
      variable v_cmd_idx        : natural;
    begin
      log(ID_SEQUENCER_SUB, "Testing get on GPIO VVC " & to_string(vvc_instance_idx) & " using SB");
      set_gpio(vvc_input, data, "GPIO " & to_string(vvc_instance_idx) & " input");
      GPIO_VVC_SB.add_expected(vvc_instance_idx, pad_gpio_sb(data));
      
      -- Perform get, which stores the data in the VVC's Scoreboard
      gpio_get(GPIO_VVCT, vvc_instance_idx, TO_SB, "Readback inside VVC using SB");
      v_cmd_idx := get_last_received_cmd_idx(GPIO_VVCT, vvc_instance_idx);  -- for last get
      await_completion(GPIO_VVCT, vvc_instance_idx, v_cmd_idx, 100 ns, "Wait for gpio_get to finish");
      wait for C_CLK_PERIOD * 4;          -- Margin
    end procedure get_and_check_gpio_sb;
    
    ----------------------------------------------------------------------
    -- Test of GPIO VVC Check method
    ----------------------------------------------------------------------
    procedure set_and_check_gpio(
      constant vvc_instance_idx : natural;
      signal   vvc_input        : out std_logic_vector;
      constant data             : std_logic_vector
      ) is
    begin
      log(ID_SEQUENCER_SUB, "Testing check on GPIO VVC " & to_string(vvc_instance_idx));
      set_gpio(vvc_input, data, "GPIO " & to_string(vvc_instance_idx) & " input");
      wait for C_CLK_PERIOD;
      
      -- Perform get, which stores the data in the VVC
      gpio_check(GPIO_VVCT, vvc_instance_idx, data, "Readback inside VVC", error);
      await_completion(GPIO_VVCT, vvc_instance_idx, 100 ns, "Wait for gpio_check to finish");
      wait for C_CLK_PERIOD * 4;
    end procedure set_and_check_gpio;
    
    ----------------------------------------------------------------------
    -- Test of GPIO VVC Check Stable method
      -- Set GPIO input and call GPIO Check Stable and check actual GPIO
      -- setting is same as expected and that it has been stable for a certain time.
    ----------------------------------------------------------------------
    procedure check_stable_gpio(
      constant vvc_instance_idx : natural;
      signal   vvc_input        : out std_logic_vector;
      constant data             : std_logic_vector
      ) is
    begin
      log(ID_SEQUENCER_SUB, "Testing check_stable on GPIO VVC " & to_string(vvc_instance_idx));
      set_gpio(vvc_input, data, "GPIO " & to_string(vvc_instance_idx) & " input");
      wait for C_CLK_PERIOD * 5;
      -- Perform get, which stores the data in the VVC
      gpio_check_stable(GPIO_VVCT, vvc_instance_idx, data, C_CLK_PERIOD * 5, "Readback inside VVC", error);
      await_completion(GPIO_VVCT, vvc_instance_idx, 1 us, "Wait for gpio_check_stable to finish");
    end procedure check_stable_gpio;

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

    -- disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_LOG_HDR_LARGE);
    enable_log_msg(ID_BFM);

    disable_log_msg(GPIO_VVCT, ALL_INSTANCES, ALL_MESSAGES);
    enable_log_msg(GPIO_VVCT, ALL_INSTANCES, ID_BFM);


    log(ID_LOG_HDR_LARGE, "Verifying TLM + GPIO executor + BFM", C_SCOPE);
    wait for C_CLK_PERIOD * 10;
    ------------------------------------------------------------

    --------------------------------------------------------------------------------------
    -- Checking of initial state
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Checking initial state of output VVC's", C_SCOPE);

    -- Check GPIO initial setting is all 0's
    v_data_exp_1024 := (others => '0');
    check_value(gpio_5_output, "0",           error, "Checking initial value of GPIO VVC 5");
    check_value(gpio_6_output, "00",          error, "Checking initial value of GPIO VVC 6");
    check_value(gpio_7_output, "00000000",    error, "Checking initial value of GPIO VVC 7");
    check_value(gpio_8_output, v_data_exp_1024, error, "Checking initial value of GPIO VVC 8");


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC Set method
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Set", C_SCOPE);

    -- Set GPIO  to all 1's. Check GPIO setting
    v_data_1024 := (others => '1');
    set_and_check_gpio(5, gpio_5_output, "1", "1");
    set_and_check_gpio(6, gpio_6_output, "11", "11");
    set_and_check_gpio(7, gpio_7_output, "11111111", "11111111");
    set_and_check_gpio(8, gpio_8_output, v_data_1024, v_data_1024);

    -- Set GPIO setting to 0xAA etc. Check GPIO setting
    set_and_check_gpio(6, gpio_6_output, "01", "01");
    set_and_check_gpio(7, gpio_7_output, "10101010", "10101010");
    set_and_check_gpio(8, gpio_8_output, "10101010101", "10101010101");
    
    -- Set GPIO setting to all 0's. Check GPIO setting
    set_and_check_gpio(5, gpio_5_output, "0", "0");
    set_and_check_gpio(6, gpio_6_output, "00", "00");
    set_and_check_gpio(7, gpio_7_output, "00000000", "00000000");
    set_and_check_gpio(8, gpio_8_output, "00000000000", "00000000000");
    
    -- Set GPIO setting to all 1's. Check GPIO setting
    set_and_check_gpio(5, gpio_5_output, "1", "1");
    set_and_check_gpio(6, gpio_6_output, "11", "11");
    set_and_check_gpio(7, gpio_7_output, "11111111", "11111111");
    set_and_check_gpio(8, gpio_8_output, "11111111111", "11111111111");


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC Set method with don't care
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Set with don't care", C_SCOPE);

    -- GPIO status is all 1's. Test by setting bits to don't care with '-'
    set_and_check_gpio(5, gpio_5_output, "-", "1");
    set_and_check_gpio(6, gpio_6_output, "1-", "11");
    set_and_check_gpio(7, gpio_7_output, "0101----", "01011111");
    set_and_check_gpio(8, gpio_8_output, "010--------", "01011111111");
    
    set_and_check_gpio(5, gpio_5_output, "0", "0");
    set_and_check_gpio(6, gpio_6_output, "-0", "10");
    set_and_check_gpio(7, gpio_7_output, "----1010", "01011010");
    set_and_check_gpio(8, gpio_8_output, "---10101010", "01010101010");
    
    set_and_check_gpio(5, gpio_5_output, "1", "-"); --?
    set_and_check_gpio(6, gpio_6_output, "01", "-1");
    set_and_check_gpio(7, gpio_7_output, "01010101", "---1---1");
    set_and_check_gpio(8, gpio_8_output, "10101010101", "--1---1---1");

    set_and_check_gpio(6, gpio_6_output, "1-", "-1");
    set_and_check_gpio(7, gpio_7_output, "101-101-", "---1---1");
    set_and_check_gpio(8, gpio_8_output, "01-101-101-", "--1---1---1");
    
    set_and_check_gpio(5, gpio_5_output, "Z", "-"); --?
    set_and_check_gpio(6, gpio_6_output, "1Z", "1-");
    set_and_check_gpio(7, gpio_7_output, "1010ZZZZ", "1010----");
    set_and_check_gpio(8, gpio_8_output, "101ZZZZZZZZ", "101--------");


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC Get method
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Get", C_SCOPE);
    v_data_exp_1024 := (others => '1');
    get_and_check_gpio(1, gpio_1_input, "1");
    get_and_check_gpio(2, gpio_2_input, "11");
    get_and_check_gpio(3, gpio_3_input, "00011101");
    get_and_check_gpio(4, gpio_4_input, v_data_exp_1024);
    
    
    --------------------------------------------------------------------------------------
    -- Test GPIO Get method using Scoreboard to check received data.
    --------------------------------------------------------------------------------------
    v_data_exp_1024 := (others => '0');
    get_and_check_gpio_sb(1, gpio_1_input, "0");
    get_and_check_gpio_sb(2, gpio_2_input, "00");
    get_and_check_gpio_sb(3, gpio_3_input, "11111111");
    get_and_check_gpio_sb(4, gpio_4_input, v_data_exp_1024);

    GPIO_VVC_SB.report_counters(ALL_INSTANCES);


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC Check method
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Check", C_SCOPE);
    v_data_exp_1024 := (others => '1');
    set_and_check_gpio(1, gpio_1_input, "1");
    set_and_check_gpio(2, gpio_2_input, "11");
    set_and_check_gpio(3, gpio_3_input, "00000000");
    set_and_check_gpio(4, gpio_4_input, v_data_exp_1024);


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC Check Stable method
    --------------------------------------------------------------------------------------
    v_data_exp_1024 := (others => '0');
    check_stable_gpio(1, gpio_1_input, "0");
    check_stable_gpio(2, gpio_2_input, "00");
    check_stable_gpio(3, gpio_3_input, "11111111");
    check_stable_gpio(4, gpio_4_input, v_data_exp_1024);


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC Expect method
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Expect", C_SCOPE);

    -- Set GPIO setting to 0xFF. Test GPIO Expect and that GPIO setting is
    -- updated immediately (within 0 ns).
    log("Testing gpio_expect as instant change check");
    v_set_data    := x"FF";
    v_expect_data := v_set_data;
    set_gpio(gpio_3_input, v_set_data, "Setting GPIO 3 input to 0xff");
    gpio_expect(GPIO_VVCT, 3, v_expect_data, 0 ns, "Checking GPIO 3", error);
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
    await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");

    -- Set GPIO setting to 0xFF, then to 0x12 after 90 ns. Test GPIO Expect
    -- with delay by checking that GPIO setting is set to 0x12 after 100 ns.
    log("Testing gpio_expect where value is correct after a delay");
    v_set_data    := x"FF";
    v_expect_data := x"12";
    set_gpio(gpio_3_input, v_set_data, "Setting GPIO 3 input to 0xff");
    wait for C_CLK_PERIOD;
    gpio_expect(GPIO_VVCT, 3, v_expect_data, 100 ns, "Checking GPIO 3", error);
    wait for 80 ns;
    v_set_data    := x"12";
    set_gpio(gpio_3_input, v_set_data, "Setting GPIO 3 input to 0x12");
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
    await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");

    -- Set GPIO setting to 0xFF, 0xAA, 0xAB, 0xAC and finally 0x00. Test GPIO
    -- Expect by checking that GPIO setting is set to 0x00 after 10 clk periods.
    log("Testing gpio_expect where value is not first to arrive");
    v_set_data    := x"FF";
    v_expect_data := x"00";
    set_gpio(gpio_3_input, v_set_data, "Setting GPIO 3 input to 0xff");
    wait for C_CLK_PERIOD;
    gpio_expect(GPIO_VVCT, 3, v_expect_data, C_CLK_PERIOD * 10, "Checking GPIO 3", error);
    wait for C_CLK_PERIOD;
    set_gpio(gpio_3_input, x"aa", "Setting GPIO 3 input to 0xaa");
    set_gpio(gpio_3_input, x"ab", "Setting GPIO 3 input to 0xab");
    set_gpio(gpio_3_input, x"ac", "Setting GPIO 3 input to 0xac");
    set_gpio(gpio_3_input, x"00", "Setting GPIO 3 input to 0x00");
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
    await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC Expect Stable method
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO Expect Stable", C_SCOPE);

    -- Set GPIO 3 input to 0xAA. Call GPIO Expect Stable and check actual GPIO
    -- setting is same as expected and that it remains stable for a certain time.
    log("Testing gpio_expect_stable with expected stable value FROM_NOW");
    v_set_data    := x"AA";
    v_expect_data := v_set_data;
    set_gpio(gpio_3_input, v_set_data, "Setting GPIO 3 input to 0xAA");
    gpio_expect_stable(GPIO_VVCT, 3, v_expect_data, C_CLK_PERIOD * 5, FROM_NOW, 0 ns, "Checking GPIO 3", error);
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
    await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect_stable to finish");

    -- Set GPIO 3 input to 0xBB and wait. Call GPIO Expect Stable and check actual GPIO
    -- setting is same as expected and that it has been stable for a certain time after
    -- the last event.
    log("Testing gpio_expect_stable with expected stable value FROM_LAST_EVENT");
    v_set_data    := x"BB";
    v_expect_data := v_set_data;
    set_gpio(gpio_3_input, v_set_data, "Setting GPIO 3 input to 0xBB");
    wait for C_CLK_PERIOD * 5;
    gpio_expect_stable(GPIO_VVCT, 3, v_expect_data, C_CLK_PERIOD * 10, FROM_LAST_EVENT, 0 ns, "Checking GPIO 3", error);
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
    await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect_stable to finish");

    -- Set GPIO 3 input to 0xCC after 10 ns. Call GPIO Expect Stable and wait until actual GPIO
    -- setting is same as expected and that it remains stable for a certain time.
    log("Testing gpio_expect_stable with expected stable value after a delayed update");
    v_set_data    := x"CC";
    v_expect_data := v_set_data;
    gpio_expect_stable(GPIO_VVCT, 3, v_expect_data, C_CLK_PERIOD * 5, FROM_NOW, 20 ns, "Checking GPIO 3", error);
    wait for 10 ns;
    set_gpio(gpio_3_input, v_set_data, "Setting GPIO 3 input to 0xCC");
    v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 3); -- for last get
    await_completion(GPIO_VVCT, 3, v_cmd_idx, 100 ns, "Wait for gpio_expect_stable to finish");


    --------------------------------------------------------------------------------------
    -- Test of GPIO VVC as inout port
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of GPIO VVC as inout port", C_SCOPE);

    for i in 0 to 1 loop
      log("GPIO 9 port is 'Z', set data using the DUT to configure as input");
      v_set_data    := x"55";
      v_expect_data := v_set_data;
      set_gpio(gpio_9_inout, v_set_data, "Setting GPIO 9 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      gpio_expect(GPIO_VVCT, 9, v_expect_data, 0 ns, "Checking GPIO 9", error);
      v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 9); -- for last get
      await_completion(GPIO_VVCT, 9, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");
      wait for C_CLK_PERIOD;

      v_set_data    := x"AA";
      v_expect_data := v_set_data;
      set_gpio(gpio_9_inout, v_set_data, "Setting GPIO 9 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      gpio_expect(GPIO_VVCT, 9, v_expect_data, 0 ns, "Checking GPIO 9", error);
      v_cmd_idx     := get_last_received_cmd_idx(GPIO_VVCT, 9); -- for last get
      await_completion(GPIO_VVCT, 9, v_cmd_idx, 100 ns, "Wait for gpio_expect to finish");
      wait for C_CLK_PERIOD;

      log("Set GPIO 9 port to 'Z' from the DUT to release the port");
      v_set_data := x"ZZ";
      set_gpio(gpio_9_inout, v_set_data, "Releasing the port");
      await_completion(GPIO_VVCT, 9, C_GPIO_SET_MAX_TIME);
      wait for C_CLK_PERIOD;

      log("GPIO 9 port is 'Z', set data using the VVC to configure as output");
      v_set_data    := x"FF";
      v_expect_data := v_set_data;
      gpio_set(GPIO_VVCT, 9, v_set_data, "Setting GPIO 9 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      await_completion(GPIO_VVCT, 9, C_GPIO_SET_MAX_TIME);
      check_value(gpio_9_inout, v_expect_data, error, "Checking value of GPIO VVC 9");
      wait for C_CLK_PERIOD;

      v_set_data    := x"33";
      v_expect_data := v_set_data;
      gpio_set(GPIO_VVCT, 9, v_set_data, "Setting GPIO 9 input to " & to_string(v_set_data, HEX, KEEP_LEADING_0, INCL_RADIX));
      await_completion(GPIO_VVCT, 9, C_GPIO_SET_MAX_TIME);
      check_value(gpio_9_inout, v_expect_data, error, "Checking value of GPIO VVC 9");
      wait for C_CLK_PERIOD;

      log("Set GPIO 9 port to 'Z' from the VVC to release the port");
      v_set_data := x"ZZ";
      gpio_set(GPIO_VVCT, 9, v_set_data, "Releasing the port");
      await_completion(GPIO_VVCT, 9, C_GPIO_SET_MAX_TIME);
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
