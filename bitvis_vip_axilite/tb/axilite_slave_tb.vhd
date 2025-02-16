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

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;


use work.axilite_bfm_pkg.all;
use work.axilite_slave_bfm_pkg.all;

-- hdlregression:tb
-- Test bench entity
entity axi_lite_bfm_tb is
end entity axi_lite_bfm_tb;

architecture sim of axi_lite_bfm_tb is

  constant ADDR_WIDTH : natural := 32;
  constant DATA_WIDTH : natural := 32;

  signal clk  : std_logic := '0';
  signal arst : std_logic := '0';

  constant C_CLK_PERIOD : time    := 10 ns; -- 100 MHz clock
  constant C_CLOCK_GEN  : natural := 1;

  ------------------------------------------------------------------------------
  -- Create a common AXI‑Lite interface signal. We initialize it using the master’s
  -- helper function (assumed to be compatible with the slave’s view).
  ------------------------------------------------------------------------------
  signal axi_if : t_axilite_if(write_address_channel(awaddr(ADDR_WIDTH - 1 downto 0)),
  write_data_channel(wdata(DATA_WIDTH - 1 downto 0),
                     wstrb((DATA_WIDTH / 8) - 1 downto 0)),
  read_address_channel(araddr(ADDR_WIDTH - 1 downto 0)),
  read_data_channel(rdata(DATA_WIDTH - 1 downto 0))) := init_axilite_if_signals(ADDR_WIDTH, DATA_WIDTH);
  

begin
  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.axi_lite_bfm_th;

  -- Wait for UVVM to finish initialization
  --await_uvvm_initialization(VOID);
  start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock generator");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_UVVM_SEND_CMD);

    log(ID_LOG_HDR, "Starting simulation of TB for UART using VVCs", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    -- wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off

  ----------------------------------------------------------------------------
  -- AXI Lite Master Process
  ----------------------------------------------------------------------------
  master_process : process
    variable read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
  begin
    -- Wait for reset
    --wait until arst = '0';
    wait for 20 ns;

    -- Write Transaction: Write 0xCAFEBABE to address 100.
    axilite_write(
      addr_value  => to_unsigned(100, ADDR_WIDTH),
      data_value  => X"CAFEBABE",
      msg         => "Master write transaction",
      clk         => clk,
      axilite_if  => axi_if
    );

    -- Indicate write is done
    --write_done <= true;

    -- wait until write_response_done = true;
    
    -- Read Transaction: Read from address 100.
    axilite_read(
      addr_value  => to_unsigned(100, ADDR_WIDTH),
      data_value  => read_data,
      msg         => "Master read transaction",
      clk         => clk,
      axilite_if  => axi_if
    );

    -- Indicate read is done
    --read_done <= true;

    report "Master read data = " & to_hstring(read_data);

    wait; -- End process
  end process master_process;

  ----------------------------------------------------------------------------
  -- AXI Lite Slave Process: DUT
  ----------------------------------------------------------------------------
  slave_process : process
  begin
    -- Wait for reset
    --wait until arst = '0';
    
    -- Wait for a write transaction
    axilite_slave_wait_write(
      msg         => "Slave wait for write",
      clk         => clk,
      axilite_if  => axi_if
    );

    -- Wait until master completes the write
    -- wait until write_done = true; -- Note: probabbly redundant since I am already waiting

    -- Send write response
    axilite_slave_send_write_response(
      msg         => "Slave sending write response",
      clk         => clk,
      axilite_if  => axi_if
    );

    -- Indicate write responce is done
    --write_response_done = true;

    -- Wait for a read transaction
    axilite_slave_wait_read(
      --addr_value  => to_unsigned(100, ADDR_WIDTH),
      msg         => "Slave waiting for read",
      clk         => clk,
      axilite_if  => axi_if
    );

    -- Send read response
    axilite_slave_send_read_response(
      data_value  => X"CAFEBABE",
      msg         => "Slave sending read response",
      clk         => clk,
      axilite_if  => axi_if
    );
  
    wait; -- End process
  end process slave_process;

  ------------------------------------------------------------------------------
  -- Clock Generator VVC.
  ------------------------------------------------------------------------------
  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => C_CLOCK_GEN,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => C_CLK_PERIOD,
      GC_CLOCK_HIGH_TIME => C_CLK_PERIOD / 2
    )
    port map(
      clk => clk
    );

  ------------------------------------------------------------------------------
  -- Reset Generator Process: Assert reset for 5 clock cycles.
  ------------------------------------------------------------------------------
  p_arst : process
  begin
    arst <= '1';
    wait for 5 * C_CLK_PERIOD;
    arst <= '0';
    wait;
  end process p_arst;

end architecture sim;
