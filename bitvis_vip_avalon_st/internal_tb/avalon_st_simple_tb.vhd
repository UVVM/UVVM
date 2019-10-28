--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- A free license is hereby granted, free of charge, to any person obtaining
-- a copy of this VHDL code and associated documentation files (for 'Bitvis Utility Library'),
-- to use, copy, modify, merge, publish and/or distribute - subject to the following conditions:
--  - This copyright notice shall be included as is in all copies or substantial portions of the code and documentation
--  - The files included in Bitvis Utility Library may only be used as a part of this library as a whole
--  - The License file may not be modified
--  - The calls in the code to the license file ('show_license') may not be removed or modified.
--  - No other conditions whatsoever may be added to those of this License

-- BITVIS UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH BITVIS UTILITY LIBRARY.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- VHDL unit     : Bitvis AVALON_ST Library : avalon_st_simple_tb
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------

-- *******************************************************************************************
--
-- Example of wrapper around this generic package with channel width 32 and data width 64.
-- This needs to be in the very top of e.g. a test bench file, before all other library
-- and use clauses.
-- 
-- package avalon_st_bfm_c32_d64_pkg is new bitvis_vip_avalon_st.avalon_st_bfm_generic_pkg
--    generic map(GC_AVALON_ST_CHAN_WIDTH => 32,
--                GC_AVALON_ST_DATA_WIDTH => 64);
-- 
-- use work.avalon_st_bfm_c32_d64_pkg.all;
--
-- *******************************************************************************************
library bitvis_vip_avalon_st;
package avalon_st_bfm_c32_d72_pkg is new bitvis_vip_avalon_st.avalon_st_bfm_generic_pkg
                                       generic map(GC_AVALON_ST_CHAN_WIDTH => 32,
                                                   GC_AVALON_ST_DATA_WIDTH => 72);

use work.avalon_st_bfm_c32_d72_pkg.all;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use std.textio.all;

library ieee_proposed;
use ieee_proposed.standard_additions.all;
use ieee_proposed.std_logic_1164_additions.all;

library bitvis_util;
use bitvis_util.types_pkg.all;
use bitvis_util.string_methods_pkg.all;
use bitvis_util.adaptations_pkg.all;
use bitvis_util.methods_pkg.all;
use bitvis_util.bfm_common_pkg.all;

-- Test case entity
entity avalon_st_simple_tb is
end entity;

-- Test case architecture
architecture func of avalon_st_simple_tb is

  constant C_CLK_PERIOD : time := 10 ns;
  signal clk_master     : std_logic;
  signal clk_slave      : std_logic;

  -- The avalon_st interface is gathered in a record, so procedures that use the
  -- avalon_st interface have less arguments
  signal avalon_st_to_dut   : t_avalon_st_to_dut;
  signal avalon_st_from_dut : t_avalon_st_from_dut;
  signal clock_ena          : boolean := false;

  -- unused signals
  signal csr_address   : std_logic_vector (2 downto 0);
  signal csr_read      : std_logic;
  signal csr_readdata  : std_logic_vector (31 downto 0);
  signal csr_write     : std_logic;
  signal csr_writedata : std_logic_vector (31 downto 0);

  -- sc_fifo generated with Quartus Qsys system
  component sc_fifo is
    port (
      clk               : in  std_logic;
      csr_address       : in  std_logic_vector (2 downto 0);
      csr_read          : in  std_logic;
      csr_readdata      : out std_logic_vector (31 downto 0);
      csr_write         : in  std_logic;
      csr_writedata     : in  std_logic_vector (31 downto 0);
      in_data           : in  std_logic_vector (7 downto 0);
      in_endofpacket    : in  std_logic;
      in_ready          : out std_logic;
      in_startofpacket  : in  std_logic;
      in_valid          : in  std_logic;
      out_data          : out std_logic_vector (7 downto 0);
      out_endofpacket   : out std_logic;
      out_ready         : in  std_logic;
      out_startofpacket : out std_logic;
      out_valid         : out std_logic;
      reset             : in  std_logic);
  end component sc_fifo;
begin

  -- Set up clock generator
  p_clock_master : clock_generator(clk_master, clock_ena, C_CLK_PERIOD, "Avalon streaming Master clock");
  p_clock_slave  : clock_generator(clk_slave, clock_ena, C_CLK_PERIOD, "Avalon streaming slave clock");

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  sc_fifo_1 : entity work.sc_fifo
    port map (
      clk               => clk_slave,
      csr_address       => csr_address,
      csr_read          => csr_read,
      csr_readdata      => csr_readdata,
      csr_write         => csr_write,
      csr_writedata     => csr_writedata,
      in_data           => avalon_st_to_dut.data(7 downto 0),
      in_endofpacket    => avalon_st_to_dut.end_of_packet,
      in_ready          => avalon_st_from_dut.ready,
      in_startofpacket  => avalon_st_to_dut.start_of_packet,
      in_valid          => avalon_st_to_dut.valid,
      out_data          => avalon_st_from_dut.data(7 downto 0),
      out_endofpacket   => avalon_st_from_dut.end_of_packet,
      out_ready         => avalon_st_to_dut.ready,
      out_startofpacket => avalon_st_from_dut.start_of_packet,
      out_valid         => avalon_st_from_dut.valid,
      reset             => avalon_st_to_dut.reset);

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE          : string             := C_TB_SCOPE_DEFAULT;
   -- BFM config
    variable avalon_st_config : t_avalon_st_config := C_AVALON_ST_CONFIG_DEFAULT;

   -- overload for this testbench
    procedure avalon_st_write (
      data_value : in std_logic_vector
      ) is
    begin
      avalon_st_write(to_unsigned(0, 32), data_value, "", clk_master, avalon_st_to_dut, avalon_st_from_dut, C_SCOPE, shared_msg_id_panel, avalon_st_config);
    end;

   -- overload for this testbench
    procedure avalon_st_read (
      data_value : out std_logic_vector
      ) is
    begin
      avalon_st_read(to_unsigned(0, 32), data_value, "", clk_slave, avalon_st_to_dut, avalon_st_from_dut, C_SCOPE, shared_msg_id_panel, avalon_st_config);
    end;

   -- overload for this testbench
    procedure avalon_st_check (
      data_exp : in std_logic_vector
      ) is
    begin
      avalon_st_check(to_unsigned(0, 32), data_exp, "", clk_slave, avalon_st_to_dut, avalon_st_from_dut, error, C_SCOPE, shared_msg_id_panel, avalon_st_config);
    end;

    variable data_buffer : std_logic_vector(71 downto 0);  -- some data
    variable exp_buffer  : std_logic_vector(63 downto 0);

  begin
                                                      -- set up our avalon config - could be different than default config in BFM
    avalon_st_config.clk_period     := C_CLK_PERIOD;  -- same clock period for BFM as
   -- for clock generator
    avalon_st_config.bits_per_clock := 8;

    avalon_st_to_dut <= C_AVALON_ST_TO_DUT_PASSIVE;
    avalon_st_from_dut  <= C_AVALON_ST_FROM_DUT_PASSIVE;
   --avalon_st_slave_if.ready <= '0';
   -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
   --disable_log_msg(ALL_MESSAGES);
   --enable_log_msg(ID_LOG_HDR);

    log("Start Simulation of TB for AVALON");
                        ------------------------------------------------------------
    clock_ena <= true;  -- the avalon_st_reset routine assumes the clock is running
    avalon_st_reset(clk_master, avalon_st_to_dut, 5);

   -- allow some time before we start
    for i in 0 to 50 loop
      wait until rising_edge(clk_master);
    end loop;

    log("Stream some data to FIFO, and read out again");
    data_buffer := random(72);
    avalon_st_write(data_buffer);
    log("Read back and check what was sent");
    avalon_st_check(data_buffer);

    log("Stream some more data to FIFO, and read out again");
    data_buffer                                 := random(72);
    avalon_st_write(data_buffer);
    exp_buffer(63 downto 0)                     := data_buffer(71 downto 8);
    log("Read back and check what was sent, but with too small receive buffer");
    avalon_st_config.received_too_much_severity := note;
    avalon_st_check(exp_buffer);

   --==================================================================================================
   -- Ending the simulation
   --------------------------------------------------------------------------------------
   -- allow some time for completion
    for i in 0 to 100 loop
      wait until rising_edge(clk_master);
    end loop;

    report_alert_counters(VOID);  -- Report final counters and print conclusion for simulation (Success/Fail)
    log("SIMULATION COMPLETED");
    clock_ena <= false;  -- to gracefully stop the simulation - if possible
    wait until rising_edge(clk_master);
    wait until rising_edge(clk_master);  -- should never be reached
           -- Hopefully stops when clock is stopped. Otherwise force a stop.
    assert false
      report "End of simulation.  (***Ignore this failure. Was provoked to stop the simulation.)"
      severity failure;
    wait;  -- to stop completely

  end process p_main;

end func;
