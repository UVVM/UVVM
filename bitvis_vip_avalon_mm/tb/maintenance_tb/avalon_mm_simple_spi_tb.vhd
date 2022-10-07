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
-- VHDL unit     : Bitvis AVALON_MM Library : avalon_mm_spi_tb
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_avalon_mm;
use bitvis_vip_avalon_mm.avalon_mm_bfm_pkg.all;

--hdlregression:tb
-- Test case entity
entity avalon_mm_spi_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of avalon_mm_spi_tb is

  constant C_CLK_PERIOD : time := 10 ns;
  signal clk            : std_logic;

  -- signals
  -- The avalon_mm interface is gathered in two records (to and from DUT),
  -- so procedures that use the avalon_mm interface have less arguments
  signal avalon_mm_if : t_avalon_mm_if(address(2 downto 0), byte_enable(1 downto 0), writedata(15 downto 0), readdata(15 downto 0));
  signal clock_ena    : boolean := false;

  -- SPI signals
  signal MISO          : STD_LOGIC;
  signal MOSI          : STD_LOGIC;
  signal SCLK          : STD_LOGIC;
  signal SS_n          : STD_LOGIC;
  signal dataavailable : STD_LOGIC;
  signal endofpacket   : STD_LOGIC;
  signal irq           : STD_LOGIC;
  signal readyfordata  : STD_LOGIC;

  component avalon_spi
    port(
      signal MISO          : IN  STD_LOGIC;
      signal clk           : IN  STD_LOGIC;
      signal data_from_cpu : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      signal mem_addr      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      signal read_n        : IN  STD_LOGIC;
      signal reset_n       : IN  STD_LOGIC;
      signal spi_select    : IN  STD_LOGIC;
      signal write_n       : IN  STD_LOGIC;
      signal MOSI          : OUT STD_LOGIC;
      signal SCLK          : OUT STD_LOGIC;
      signal SS_n          : OUT STD_LOGIC;
      signal data_to_cpu   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      signal dataavailable : OUT STD_LOGIC;
      signal endofpacket   : OUT STD_LOGIC;
      signal irq           : OUT STD_LOGIC;
      signal readyfordata  : OUT STD_LOGIC);
  end component;
begin

  -- Set up clock generator
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "Avalon MM clock");

  -----------------------------------------------------------------------------
  -- Instantiate DUT - a master mode Avalon_Mm SPI
  -----------------------------------------------------------------------------
  avalon_spi_1 : avalon_spi
    port map(
      MISO          => MISO,
      clk           => clk,
      data_from_cpu => avalon_mm_if.writedata(15 downto 0),
      mem_addr      => avalon_mm_if.address(2 downto 0),
      read_n        => not avalon_mm_if.read,
      reset_n       => not avalon_mm_if.reset,
      spi_select    => avalon_mm_if.chipselect,
      write_n       => not avalon_mm_if.write,
      MOSI          => MOSI,
      SCLK          => SCLK,
      SS_n          => SS_n,
      data_to_cpu   => avalon_mm_if.readdata(15 downto 0),
      dataavailable => dataavailable,
      endofpacket   => endofpacket,
      irq           => irq,
      readyfordata  => readyfordata);

  -- Response signal is not used in the DUT, so we ground it.
  avalon_mm_if.response <= (others => '0');

  p_loopback_mosi : process(MOSI)
  begin                                 -- process MOSI
    MISO <= MOSI;
  end process p_loopback_mosi;
  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE              : string                 := C_TB_SCOPE_DEFAULT;
    -- BFM config
    variable avalon_mm_bfm_config : t_avalon_mm_bfm_config := C_avalon_mm_bfm_config_DEFAULT;

    -- overload for this testbench
    procedure avalon_mm_write(
      addr_value  : in unsigned;
      data_value  : in std_logic_vector;
      alert_level : in t_alert_level := error
    ) is
      variable timeout : boolean := false;
      variable cycle   : natural := 0;
    begin
      if addr_value = 1 then
        -- check that SPI module is ready for data - wait if necessary
        while not readyfordata loop
          wait until rising_edge(clk);
          cycle := cycle + 1;
          if cycle = 100 then
            timeout := true;
            alert(alert_level, "avalon_mm_write() timeout waiting for SPI to be ready");
            exit;
          end if;
        end loop;
        if not timeout then
          avalon_mm_write(addr_value, data_value, "", clk, avalon_mm_if, "11", C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
        end if;
      else
        avalon_mm_write(addr_value, data_value, "", clk, avalon_mm_if, "11", C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
      end if;
    end;

    -- overload for this testbench
    procedure avalon_mm_read(
      addr_value  : in unsigned;
      data_value  : out std_logic_vector;
      alert_level : in t_alert_level := error
    ) is
      variable timeout : boolean := false;
      variable cycle   : natural := 0;
    begin
      if addr_value = 0 then
        -- check that SPI module is ready to deliver - wait if necessary
        while not dataavailable loop
          wait until rising_edge(clk);
          cycle := cycle + 1;
          if cycle = 100 then
            timeout := true;
            alert(alert_level, "avalon_mm_read) timeout waiting for SPI to have data");
            exit;
          end if;
        end loop;
        if not timeout then
          avalon_mm_read(addr_value, data_value, "", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
        end if;
      else
        avalon_mm_read(addr_value, data_value, "", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
      end if;
    end;

    -- overload for this testbench
    procedure avalon_mm_check(
      addr_value  : in unsigned;
      data_exp    : in std_logic_vector;
      alert_level : in t_alert_level := error
    ) is
      variable timeout : boolean := false;
      variable cycle   : natural := 0;
    begin
      -- same timeout as for reads - if checking addr 0
      if addr_value = 0 then
        -- check that SPI module is ready to deliver - wait if necessary
        while not dataavailable loop
          wait until rising_edge(clk);
          cycle := cycle + 1;
          if cycle = 100 then
            timeout := true;
            alert(alert_level, "avalon_mm_read) timeout waiting for SPI to have data");
            exit;
          end if;
        end loop;
        if not timeout then
          avalon_mm_check(addr_value, data_exp, "", clk, avalon_mm_if, alert_level, C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
        end if;
      else
        avalon_mm_check(addr_value, data_exp, "", clk, avalon_mm_if, alert_level, C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);
      end if;
    end;

    variable i                    : integer;
    variable fifo_data            : std_logic_vector(31 downto 0);
    variable v_alert_num_mismatch : boolean := false;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- set up our avalon_mm config - could be different than default config in BFM
    avalon_mm_bfm_config.clock_period          := C_CLK_PERIOD; -- same clock period for BFM as for clock generator
    avalon_mm_bfm_config.setup_time            := C_CLK_PERIOD / 4;
    avalon_mm_bfm_config.hold_time             := C_CLK_PERIOD / 4;
    avalon_mm_bfm_config.max_wait_cycles       := 10;
    avalon_mm_bfm_config.num_wait_states_read  := 1;
    avalon_mm_bfm_config.num_wait_states_write := 1;
    avalon_mm_bfm_config.use_waitrequest       := false;
    avalon_mm_bfm_config.use_readdatavalid     := false;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);

    log("Start Simulation of TB for AVALON_MM");
    ------------------------------------------------------------
    clock_ena <= true;                  -- the avalon_mm_reset routine assumes the clock is running
    avalon_mm_reset(clk, avalon_mm_if, 5, "Resetting Avalon MM Interface", C_SCOPE, shared_msg_id_panel, avalon_mm_bfm_config);

    -- allow some time before we start
    for i in 0 to 50 loop
      wait until rising_edge(clk);
    end loop;

    log("Write to TXDATA register");
    avalon_mm_write("1", x"55");
    avalon_mm_write("1", x"aa");

    -- should take 8 bits X 10 clocks (SPI clock 10 x slower)
    for i in 0 to 80 loop
      wait until rising_edge(clk);
    end loop;

    log("Read back (and check) loopback of TXDATA");
    avalon_mm_check("0", x"55");
    wait for 1 ns;
    avalon_mm_check("0", x"aa");

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
