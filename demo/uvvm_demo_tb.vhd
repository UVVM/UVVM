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

library bitvis_vip_sbi;
use bitvis_vip_sbi.vvc_methods_pkg.all;
use bitvis_vip_sbi.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_uart;
use bitvis_vip_uart.vvc_methods_pkg.all;
use bitvis_vip_uart.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

--hdlunit:tb
entity uvvm_demo_tb is
  generic (
    GC_TEST         : string := "UVVM";
    GC_RAND_SEED_1  : integer := 5;
    GC_RAND_SEED_2  : integer := 10
    );  
end entity;

-- Test bench architecture
architecture func of uvvm_demo_tb is

  constant C_SCOPE              : string  := C_TB_SCOPE_DEFAULT;

  -- Clock and bit period settings
  constant C_CLK_PERIOD         : time := 10 ns;
  constant C_BIT_PERIOD         : time := 16 * C_CLK_PERIOD;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
  constant C_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
  constant C_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
  constant C_ADDR_TX_READY      : unsigned(2 downto 0) := "011";



begin


  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  --
  --   Map timing constants and DUT addresses for VIPs and Model
  -----------------------------------------------------------------------------
  i_test_harness : entity work.uvvm_demo_th generic map(
    GC_CLK_PERIOD                 => C_CLK_PERIOD,
    GC_BIT_PERIOD                 => C_BIT_PERIOD,
    GC_ADDR_RX_DATA               => C_ADDR_RX_DATA,
    GC_ADDR_RX_DATA_VALID         => C_ADDR_RX_DATA_VALID,
    GC_ADDR_TX_DATA               => C_ADDR_TX_DATA,
    GC_ADDR_TX_READY              => C_ADDR_TX_READY
  );


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    variable v_data       : std_logic_vector(7 downto 0);


    -- Description:
    --
    --    1. UART TX VVC is instructed to send 1 and 3 randomised
    --       data to DUT.
    --    2. Model will put expected data on SBI Scoreboard.
    --    3. Model will issue a SBI VVC read request.
    --    4. SBI VVC will put actual data on SBI Scoreboard.
    --    5. Sequencer present SBI Scoreboard statistics.
    --
    procedure test_randomise(void : t_void) is
    begin

    end procedure test_randomise;


    -- Description:
    --
    --  1. UART RX VVC is instructed to receive full coverage (0-15), and
    --     put actual data on UART Scoreboard.
    --  2. SBI VVC is set up to send 100 bytes of random data (0-16).
    --  3. Model will put expected data on UART Scoreboard.
    --  4. SBI VVC command queue is flushed when UART RX VVC is finished, i.e.
    --     has achieved full coverage.
    --  5. Sequencer present coverage results and UART Scoreboard statistics.
    --
    procedure test_functional_coverage(void : t_void) is
    begin

    end procedure test_functional_coverage;




  begin

    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    await_uvvm_initialization(VOID);
    
    set_alert_stop_limit(TB_ERROR,4);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);
    enable_log_msg(ID_BFM_POLL);

    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(VVC_BROADCAST, ID_BFM);
    enable_log_msg(VVC_BROADCAST, ID_BFM_POLL);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock generator");

    log(ID_LOG_HDR, "Starting simulation of UVVM DEMO TB using SBI and UART VVCs", C_SCOPE);
    --============================================================================================================
    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);


    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    --============================================================================================================
    shared_uart_vvc_config(RX,1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX,1).bfm_config.bit_time := C_BIT_PERIOD;

    shared_uart_vvc_config(RX,1).bfm_config.num_stop_bits := STOP_BITS_ONE;
    shared_uart_vvc_config(TX,1).bfm_config.num_stop_bits := STOP_BITS_ONE;

    shared_uart_vvc_config(RX,1).bfm_config.parity := PARITY_ODD;
    shared_uart_vvc_config(TX,1).bfm_config.parity := PARITY_ODD;


    -----------------------------------------------------------------------------
    -- Tests
    -----------------------------------------------------------------------------
    if GC_TEST = "test_randomise" then    
      test_randomise(VOID);

    elsif GC_TEST = "test_functional_coverage" then
      test_functional_coverage(VOID);

    else
      alert(tb_error, "Unsupported test " & GC_TEST);
    end if;
  

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