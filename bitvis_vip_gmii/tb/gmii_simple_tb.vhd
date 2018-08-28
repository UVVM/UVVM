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
-- VHDL unit     : Bitvis GMII Library : gmii_simple_tb
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------


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

library bitvis_vip_gmii;
use bitvis_vip_gmii.gmii_bfm_pkg.all;

-- Test case entity
entity gmii_simple_tb is
end entity;

-- Test case architecture
architecture func of gmii_simple_tb is

  constant C_CLK_PERIOD  : time := 8 ns;
  signal clk : std_logic;

  -- The gmii interface is gathered in a record, so procedures that use the
  -- gmii interface have less arguments
  signal gmii_to_dut        : t_gmii_to_dut;
  signal gmii_from_dut        : t_gmii_from_dut;

  signal eth_cfg           : t_eth_frame_config;
  signal clock_ena         : boolean := false;

  -- used signals
  signal dut_ready          : std_logic;
  signal bfm_ready         : std_logic := '0';
  signal out_valid         : std_logic;

  -- sc_fifo generated with Quartus Qsys system
  component sc_fifo is
    port (
      clk       : IN  STD_LOGIC;
      in_data   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      in_ready  : OUT STD_LOGIC;
      in_valid  : IN  STD_LOGIC;
      out_data  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      out_ready : IN  STD_LOGIC;
      out_valid : OUT STD_LOGIC;
      reset     : IN  STD_LOGIC);
  end component sc_fifo;
begin

  -- Set up clock generator
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "GMII CLK");

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  sc_fifo_1: entity work.sc_fifo
    port map (
      clk               => clk,
      in_data           => gmii_to_dut.data,
      in_ready          => dut_ready,
      in_valid          => gmii_to_dut.valid,
      out_data          => gmii_from_dut.data,
      out_ready         => bfm_ready,
      out_valid         => out_valid,
      reset             => gmii_to_dut.reset);

  -- only use valid signal when we read from fifo
  p_out_valid: process (out_valid, bfm_ready) is
  begin  -- process p_out_valid
    gmii_from_dut.valid <= bfm_ready and out_valid;
  end process p_out_valid;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;
    -- BFM config
    variable gmii_config : t_gmii_config := C_GMII_CONFIG_DEFAULT;

    -- overload for this testbench
    procedure gmii_write (
      payload           : in std_logic_vector;
      payload_size      : in natural
      ) is
      variable not_ready_count : natural := 0;
      variable timeout : boolean := false;
    begin
      while ((dut_ready = '0') and
             (timeout = false)) loop
        log("gmii_write waiting for dut_ready..");
        not_ready_count := not_ready_count + 1;
        wait until rising_edge(clk);
        if not_ready_count >= gmii_config.max_wait_cycles then
          timeout := true;
          alert(gmii_config.max_wait_cycles_severity, "gmii_write() timeout waiting for FIFO to be ready");
        end if;
      end loop;
      gmii_write(clk, gmii_to_dut, gmii_from_dut, eth_cfg, payload, payload_size, gmii_config);
    end;

    -- overload for this testbench
    procedure gmii_read (
      payload           : out std_logic_vector;
      payload_size      : in natural
      ) is
    begin
      bfm_ready <= '1';
      gmii_read(clk, gmii_to_dut, gmii_from_dut, eth_cfg, payload, payload_size, gmii_config);
      bfm_ready <= '0';
    end;

    -- overload for this testbench
    procedure gmii_check (
      payload           : in std_logic_vector;
      payload_size      : in natural
      ) is
    begin
      bfm_ready <= '1';
      gmii_check(clk, gmii_to_dut, gmii_from_dut, eth_cfg, payload, payload_size, gmii_config);
      bfm_ready <= '0';
    end;

    variable i              : integer;
    variable payload_buffer : std_logic_vector(2048*8-1 downto 0);
    variable payload_size   : natural;

  begin
    -- set up our gmii config - could be different than default config in BFM
    gmii_config.clk_period := C_CLK_PERIOD;  -- same clock period for BFM as
                                             -- for clock generator

    gmii_to_dut <= C_GMII_TO_DUT_PASSIVE;
    eth_cfg    <= C_ETH_FRAME_CONFIG_DEFAULT;
    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);

    log("Start Simulation of TB for GMII");
    ------------------------------------------------------------
    clock_ena <= true; -- the gmii_reset routine assumes the clock is running
    gmii_reset(clk, gmii_to_dut, 5, gmii_config);

    -- allow some time before we start
    for i in 0 to 50 loop
      wait until rising_edge(clk);
    end loop;

    for i in 0 to 50 loop
      log("Send random payload, random size in eth frame #" & to_string(i,8));
      eth_cfg.dest_addr    <= random(48);
      eth_cfg.source_addr  <= random(48);
      if (i mod 2)=0 then
        eth_cfg.insert_vlan1 <= true;
        eth_cfg.insert_vlan2 <= true;
        eth_cfg.len_field_is_len <= true;
      else
        eth_cfg.insert_vlan1 <= false;
        eth_cfg.insert_vlan2 <= false;
        eth_cfg.len_field_is_len <= false;
      end if;
      eth_cfg.vlan_type1   <= random(16);
      eth_cfg.vlan_type2   <= random(16);
      eth_cfg.vlan_setting1<= random(16);
      eth_cfg.vlan_setting2<= random(16);
      eth_cfg.ether_type   <= random(16);
      payload_buffer       := random(2048*8);
      payload_size         := random(46,150);
      gmii_write(payload_buffer, payload_size);
      log("Read back and check what was sent");
      gmii_check(payload_buffer, payload_size);
    end loop;

    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    -- allow some time for completion
    for i in 0 to 100 loop
      wait until rising_edge(clk);
    end loop;

    report_alert_counters(VOID); -- Report final counters and print conclusion for simulation (Success/Fail)
    log("SIMULATION COMPLETED");
    clock_ena <= false;           -- to gracefully stop the simulation - if possible
    wait until rising_edge(clk);
    wait until rising_edge(clk);  -- should never be reached
    -- Hopefully stops when clock is stopped. Otherwise force a stop.
    assert false
      report "End of simulation.  (***Ignore this failure. Was provoked to stop the simulation.)"
      severity failure;
    wait;  -- to stop completely

  end process p_main;

end func;
