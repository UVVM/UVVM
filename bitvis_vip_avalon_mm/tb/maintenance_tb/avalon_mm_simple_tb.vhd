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

-- Using the instantiated pkg
library bitvis_vip_avalon_mm;
use bitvis_vip_avalon_mm.avalon_mm_bfm_pkg.all;

--hdlregression:tb
-- Test case entity
entity avalon_mm_tb is
  generic (
    GC_TESTCASE : string := "UVVM"
    );
end entity;

-- Test case architecture
architecture func of avalon_mm_tb is

  constant C_CLK_PERIOD : time := 10 ns;
  signal clk : std_logic;

  -- signals
  -- The avalon_mm interface is gathered in two records (to and from DUT),
  -- so procedures that use the avalon_mm interface have less arguments
  signal avalon_mm_if     : t_avalon_mm_if(address(31 downto 0), byte_enable(3 downto 0), writedata(31 downto 0), readdata(31 downto 0));
  signal clock_ena        : boolean := false;

  -- FIFO signals
  signal empty : std_logic;
  signal full  : std_logic;
  signal usedw : std_logic_vector (3 downto 0);

  component avalon_fifo_single_clock_fifo
    port (
      signal aclr  : in  std_logic;
      signal clock : in  std_logic;
      signal data  : in  std_logic_vector (31 downto 0);
      signal rdreq : in  std_logic;
      signal wrreq : in  std_logic;
      signal empty : out std_logic;
      signal full  : out std_logic;
      signal q     : out std_logic_vector (31 downto 0);
      signal usedw : out std_logic_vector (3 downto 0));
  end component;
begin

  -- Set up clock generator
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "Avalon Mem Mapped clock");

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  avalon_fifo_single_clock_fifo_1 : avalon_fifo_single_clock_fifo
    port map (
      aclr  => avalon_mm_if.reset,
      clock => clk,
      data  => avalon_mm_if.writedata,
      rdreq => avalon_mm_if.read,
      wrreq => avalon_mm_if.write,
      empty => empty,
      full  => full,
      q     => avalon_mm_if.readdata,
      usedw => usedw);

  -- Response signal is not used in the DUT, so we ground it.
  avalon_mm_if.response <= (others => '0');

  p_waitrequest : process (avalon_mm_if, full, empty)
  begin
    if avalon_mm_if.write and full then
      avalon_mm_if.waitrequest <= '1';
    elsif avalon_mm_if.read and empty then
      avalon_mm_if.waitrequest <= '1';
    else
      avalon_mm_if.waitrequest <= '0';
    end if;
  end process p_waitrequest;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE              : string             := C_TB_SCOPE_DEFAULT;
    variable fifo_data            : std_logic_vector(31 downto 0);
   -- BFM config
    variable avalon_mm_bfm_config : t_avalon_mm_bfm_config := C_AVALON_MM_BFM_CONFIG_DEFAULT;

   -- overload for this testbench
    procedure avalon_mm_write (
      addr_value : in unsigned;
      data_value : in std_logic_vector
      ) is
    begin
      avalon_mm_write(addr_value, data_value, "", clk, avalon_mm_if, "1111", C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
    end;

   -- overload for this testbench
    procedure avalon_mm_read (
      addr_value : in  unsigned;
      data_value : out std_logic_vector
      ) is
    begin
      avalon_mm_read(addr_value, data_value, "", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
    end;

   -- overload for this testbench
    procedure avalon_mm_check (
      addr_value : in unsigned;
      data_exp   : in std_logic_vector;
      alert_level : in t_alert_level  := error
      ) is
    begin
      avalon_mm_check(addr_value, data_exp, "", clk, avalon_mm_if, alert_level, C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
    end;


  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

                                                                -- set up our avalon_mm config - could be different than default config in BFM
    avalon_mm_bfm_config.clock_period             := C_CLK_PERIOD;  -- same clock period for BFM as
    avalon_mm_bfm_config.setup_time               := C_CLK_PERIOD/4;
    avalon_mm_bfm_config.hold_time                := C_CLK_PERIOD/4;
   -- for clock generator
    avalon_mm_bfm_config.max_wait_cycles          := 10;
    avalon_mm_bfm_config.max_wait_cycles_severity := TB_FAILURE;
    avalon_mm_bfm_config.num_wait_states_read     := 0;
    avalon_mm_bfm_config.num_wait_states_write    := 0;
    avalon_mm_bfm_config.use_waitrequest          := true;

   -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
   --disable_log_msg(ALL_MESSAGES);
   --enable_log_msg(ID_LOG_HDR);

    log("Start Simulation of TB for AVALON_MM");
                        ------------------------------------------------------------
    clock_ena <= true;  -- the avalon_mm_reset routine assumes the clock is running
    avalon_mm_reset(clk, avalon_mm_if, 5,"Resetting avalon MM interface", C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);

   -- allow some time before we start
    for i in 0 to 50 loop
      wait until rising_edge(clk);
    end loop;

    log("Do some avalon_mm writes to the FIFO");
    avalon_mm_write("0", x"abba5959");
    avalon_mm_write("0", x"01234567");
    avalon_mm_write("0", x"98765432");

    log("Read back data, and check it");
    avalon_mm_check("0", x"abba5959");
    avalon_mm_check("0", x"01234567");
    avalon_mm_check("0", x"98765432");

    log("Do another read - should timeout");
    increment_expected_alerts(WARNING, 1);
    avalon_mm_bfm_config.max_wait_cycles_severity := WARNING;
    avalon_mm_read("0", fifo_data);
    avalon_mm_write("0", x"10");
    avalon_mm_read("0", fifo_data);
    avalon_mm_bfm_config.max_wait_cycles_severity := TB_FAILURE;

    log("Fill the FIFO");
    for i in 0 to 15 loop
      fifo_data := random(32);
      avalon_mm_write("0", fifo_data);
    end loop;

    log("Do another write - should timeout");
    increment_expected_alerts(WARNING, 1);
    avalon_mm_bfm_config.max_wait_cycles_severity := WARNING;
    avalon_mm_write("0", x"deadbeef");
    avalon_mm_bfm_config.max_wait_cycles_severity := TB_FAILURE;

    log("Empty the FIFO");
    for i in 0 to 15 loop
      avalon_mm_read("0", fifo_data);
    end loop;

    log("Random data write and read-back w check");
    for i in 0 to 100 loop
      fifo_data := random(32);
      avalon_mm_write("0", fifo_data);
      avalon_mm_check("0", fifo_data);
    end loop;


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
