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

library bitvis_vip_avalon_mm;
context bitvis_vip_avalon_mm.vvc_context;

--hdlunit:tb
-- Test case entity
entity avalon_mm_vvc_pipeline_tb is
  generic (
    GC_TESTCASE               : string  := "UVVM";
    GC_DELTA_DELAYED_VVC_CLK  : boolean := false
    );
end entity;

-- Test case architecture
architecture func of avalon_mm_vvc_pipeline_tb is

  constant C_ADDR_WIDTH   : integer := 23;
  constant C_DATA_WIDTH   : integer := 32;
  constant C_CLK_PERIOD   : time := 10 ns;

  signal clk                  : std_logic;
  signal clk_delta_delayed_d1 : std_logic; -- Clk delayed by one delta cycle

  signal avalon_mm_if_1     : t_avalon_mm_if(address(C_ADDR_WIDTH-1 downto 0), byte_enable((C_DATA_WIDTH/8)-1 downto 0),
                                           writedata(C_DATA_WIDTH-1 downto 0), readdata(C_DATA_WIDTH-1 downto 0));

  -- RAM dummy signals
  signal ram_addr : std_logic_vector(11 downto 0);
  signal ram_ba : std_logic_vector(1 downto 0);
  signal ram_cas_n : std_logic;
  signal ram_cke : std_logic;
  signal ram_cs_n : std_logic;
  signal ram_dq : std_logic_vector(31 downto 0);
  signal ram_dqm : std_logic_vector(3 downto 0);
  signal ram_ras_n : std_logic;
  signal ram_we_n : std_logic;

  signal debug_received_data  : std_logic_vector(31 downto 0);
  signal debug_data_to_send   : std_logic_vector(31 downto 0);

  component fpga4u_sdram_controller
    port (
        signal clk, reset : in std_logic;
        signal as_address : in std_logic_vector(22 downto 0);
        signal as_read, as_write : in std_logic;
        signal as_byteenable : in std_logic_vector(3 downto 0);
        signal as_readdata : out std_logic_vector(31 downto 0);
        signal as_writedata : in std_logic_vector(31 downto 0);
        signal as_waitrequest : out std_logic;
        signal as_readdatavalid : out std_logic;

        --SDRAM interface to FPGA4U SDRAM
        signal ram_addr : out std_logic_vector(11 downto 0);
        signal ram_ba : out std_logic_vector(1 downto 0);
        signal ram_cas_n : out std_logic;
        signal ram_cke : out std_logic;
        signal ram_cs_n : out std_logic;
        signal ram_dq : inout std_logic_vector(31 downto 0);
        signal ram_dqm : out std_logic_vector(3 downto 0);
        signal ram_ras_n : out std_logic;
        signal ram_we_n : out std_logic;

        signal debug_received_data  : out std_logic_vector(31 downto 0);
        signal debug_data_to_send   : in std_logic_vector(31 downto 0));
  end component;

begin

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  fpga4u_sdram_controller_1 : fpga4u_sdram_controller
    port map (
      -- Avalon signals
      clk               => clk,
      reset             => avalon_mm_if_1.reset,
      as_address        => avalon_mm_if_1.address,
      as_read           => avalon_mm_if_1.read,
      as_write          => avalon_mm_if_1.write,
      as_byteenable     => avalon_mm_if_1.byte_enable,
      as_readdata       => avalon_mm_if_1.readdata,
      as_writedata      => avalon_mm_if_1.writedata,
      as_waitrequest    => avalon_mm_if_1.waitrequest,
      as_readdatavalid  => avalon_mm_if_1.readdatavalid,

      -- RAM signals
      ram_addr          => ram_addr,
      ram_ba            => ram_ba,
      ram_cas_n         => ram_cas_n,
      ram_cke           => ram_cke,
      ram_cs_n          => ram_cs_n,
      ram_dq            => ram_dq,
      ram_dqm           => ram_dqm,
      ram_ras_n         => ram_ras_n,
      ram_we_n          => ram_we_n,

      debug_received_data => debug_received_data,
      debug_data_to_send => debug_data_to_send
    );


  -----------------------------
  -- vvc/executors
  -----------------------------

  --
  -- Normal case, where the VVC uses the exact same clk as DUT
  --
  g_not_delta_delayed_vvc_clk : if not GC_DELTA_DELAYED_VVC_CLK generate
    i1_avalon_mm_vvc : entity work.avalon_mm_vvc
      generic map(
        GC_ADDR_WIDTH   => C_ADDR_WIDTH,
        GC_DATA_WIDTH   => C_DATA_WIDTH,
        GC_INSTANCE_IDX => 1
      )
      port map(
        clk                         => clk, -- Not delta delayed. Exact same clk as DUT
        avalon_mm_vvc_master_if     => avalon_mm_if_1
      );
  end generate;

  --
  --
  -- Test delaying the clock towards the VVC with one delta cycle
  -- This tests if it affects sampling of control signals from DUT,
  -- for example it may lead to detecting the as_readdatavalid at the rising edge instead of later in the pulse
  --
  g_delta_delayed_vvc_clk : if GC_DELTA_DELAYED_VVC_CLK generate
    i1_avalon_mm_vvc : entity work.avalon_mm_vvc
      generic map(
        GC_ADDR_WIDTH   => C_ADDR_WIDTH,
        GC_DATA_WIDTH   => C_DATA_WIDTH,
        GC_INSTANCE_IDX => 1
      )
      port map(
        clk                         => clk_delta_delayed_d1, -- Delta delayed wrt DUT, which can affect sampling of signals
        avalon_mm_vvc_master_if     => avalon_mm_if_1
      );
  end generate;

  -- Set default to unused interface signals
  avalon_mm_if_1.response <= (others => '0');
  avalon_mm_if_1.irq <= '0';

  ------------------------
  -- Clocks
  ------------------------
  p_clk : clock_generator(clk, C_CLK_PERIOD);
  clk_delta_delayed_d1 <= clk;  -- Clk delayed by one delta cycle

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- Sequencer constants and variables
    constant C_SCOPE      : string             := C_TB_SCOPE_DEFAULT;
    variable v_cmd_idx    : natural;
    variable v_data_int    : natural;
    variable v_prev_data_int    : natural;
    variable v_data       : std_logic_vector(1023 downto 0);
    variable v_is_ok      : boolean;
    variable v_is_new     : boolean;
    variable v_timestamp  : time;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");


    await_uvvm_initialization(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);
    enable_log_msg(ID_BFM_POLL);
    enable_log_msg(ID_POS_ACK);

    disable_log_msg(AVALON_MM_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_BFM);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_BFM_POLL);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_CMD_EXECUTOR);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_IMMEDIATE_CMD);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_IMMEDIATE_CMD_WAIT);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    log("Start Simulation of TB for AVALON_MM");
    ------------------------------------------------------------
    -- Reset the Avalon bus
    avalon_mm_reset(AVALON_MM_VVCT, 1, 5, "Resetting Avalon MM Interface 1");

    -- Set maximum allowed pipeline delay
    shared_avalon_mm_vvc_config(1).bfm_config.max_wait_cycles   := 100;
    shared_avalon_mm_vvc_config(1).bfm_config.use_readdatavalid := TRUE;
    shared_avalon_mm_vvc_config(1).bfm_config.clock_period      := C_CLK_PERIOD;

    -- Wait for SDRAM to init.
    wait for 1 ms;

    -- Allow some time before testing starts
    insert_delay(AVALON_MM_VVCT, 1, 50, "Giving the DUT some time to initialize");
    await_completion(AVALON_MM_VVCT,1, 55000 ns, "Awaiting completion of inserted delay and wait statement");

    --==================================================================================================
    -- Start of tests
    --------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Basic read and write tests with pipelined DUT");

    for i in 0 to 1 loop
      log(ID_SEQUENCER, "Testing pipeliend read/check, iteration i=" & to_string(i));
      debug_data_to_send <= x"00110032";
      wait for 100 ns;
      avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"00110032", "Reading data, i=" & to_string(i));
      await_completion(AVALON_MM_VVCT,1, 1 us, "Awaiting completion of read");

      debug_data_to_send <= x"01AB129C";
      wait for i*100 ns;
      avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"01AB129C", "Reading data, i=" & to_string(i));

      await_completion(AVALON_MM_VVCT,1, 1 us, "Awaiting completion of read");
    end loop;

    wait for 1 us;
    log(ID_SEQUENCER, "Testing pipeliend write");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"10", "Writing to DUT");
    await_completion(AVALON_MM_VVCT,1, 2000 ns, "Awaiting completion of write");
    await_value(debug_received_data, x"10",0 ns, 1 us, ERROR, "Awaiting value on debug output port");
    wait for 1 us;
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"55", "Writing to DUT");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"AA", "Writing to DUT");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"1234", "Writing to DUT");

    await_value(debug_received_data, x"55", 0 ns, 1 us, ERROR, "Awaiting value on debug output port");
    await_value(debug_received_data, x"AA", 0 ns, 1 us, ERROR, "Awaiting value on debug output port");
    await_value(debug_received_data, x"1234", 0 ns, 1 us, ERROR, "Awaiting value on debug output port");
    await_completion(AVALON_MM_VVCT,1, 2000 ns, "Awaiting completion of write");



    log(ID_LOG_HDR, "Test of multiple pipelined reads");

    log(ID_SEQUENCER, "Reading multiple times");
    debug_data_to_send <= x"00001100";
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"00001100", "Reading data");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"00001100", "Reading data");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"00001100", "Reading data");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"00001100", "Reading data");
    await_completion(AVALON_MM_VVCT,1, 5 us, "Awaiting completion of read");
    wait for 10 us;


    log(ID_SEQUENCER, "Reading above pipeline limit");
    shared_avalon_mm_vvc_config(1).num_pipeline_stages := 5;
    debug_data_to_send <= x"10100011";
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 1");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 2");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 3");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"10101010", "Writing to DUT - 1");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 4");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 5");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 6");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 7");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 8");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 9");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 10");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 11");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 12");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 13");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"12345678", "Writing to DUT - 2");
    avalon_mm_check(AVALON_MM_VVCT, 1, x"0", x"10100011", "Reading data - 14");

    await_value(debug_received_data, x"10101010", 0 ns, 1 us, ERROR, "Awaiting value on debug output port");
    await_value(debug_received_data, x"12345678", 0 ns, 1 us, ERROR, "Awaiting value on debug output port");

    await_completion(AVALON_MM_VVCT,1, 10 us, "Awaiting completion of read");

    wait for 1 us;

    check_value(avalon_mm_if_1.lock, '0', ERROR, "Verifying that bus is unlocked");
    avalon_mm_lock(AVALON_MM_VVCT, 1, "Locking Avalon MM Master 1");
    await_completion(AVALON_MM_VVCT,1, 10 us, "Awaiting lock");
    check_value(avalon_mm_if_1.lock, '1', ERROR, "Verifying that bus is locked");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"55", "Writing to DUT");
    check_value(avalon_mm_if_1.lock, '1', ERROR, "Verifying that bus is locked");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"AA", "Writing to DUT");
    check_value(avalon_mm_if_1.lock, '1', ERROR, "Verifying that bus is locked");
    avalon_mm_write(AVALON_MM_VVCT, 1, x"0", x"1234", "Writing to DUT");
    check_value(avalon_mm_if_1.lock, '1', ERROR, "Verifying that bus is locked");
    avalon_mm_unlock(AVALON_MM_VVCT, 1, "Unlocking Avalon MM Master 1");
    await_completion(AVALON_MM_VVCT,1, 10 us, "Awaiting unlock");
    check_value(avalon_mm_if_1.lock, '0', ERROR, "Verifying that bus is unlocked");

    await_completion(AVALON_MM_VVCT,1, 10 us, "Waiting until test is done");
    wait for 1 us;

    -- Test : pipelined reading, when different readdata each read:
    log(ID_LOG_HDR, "Test of pipelined reading, when different readdata each read");
    log(ID_SEQUENCER, "Reading multiple times");

    -- Schedule each change in debug_data_to_send
    for i in 0 to 200 loop
      debug_data_to_send <= transport std_logic_vector(to_unsigned(i,32)) after i*C_CLK_PERIOD;
    end loop;

    v_prev_data_int := 0;
    for i in 0 to 2 loop
      avalon_mm_read(AVALON_MM_VVCT, 1, x"0", "Reading i="&to_string(i));
      v_cmd_idx := get_last_received_cmd_idx(AVALON_MM_VVCT, 1); -- for last read
      await_completion(AVALON_MM_VVCT, 1, 100 us, "Wait for _read to finish");
      fetch_result(AVALON_MM_VVCT, 1, v_cmd_idx, v_data, "Fetching read-result");
      v_data_int := to_integer(unsigned(v_data(29 downto 0)));
      check_value_in_range(v_data_int, v_prev_data_int+5, (2**30)-1, ERROR, "checking that read data has increased (i.e. not sampling the same readdata twice), Reading i="&to_string(i));
      -- For Next iteration
      v_prev_data_int := v_data_int;
    end loop;



    -- Ensuring everything has completed
    wait for 10 us;
    await_completion(AVALON_MM_VVCT,1, 10000 ns, "Awaiting completion");
    wait for 10 us;


    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely


  end process p_main;

end func;
