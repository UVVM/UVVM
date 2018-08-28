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
-- VHDL unit     : Bitvis VIP AVALON Library : avalon_st_bfm_generic_pkg 
--
-- Description   : See library quick reference (under 'doc') and README-file(s)
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library bitvis_util;
use bitvis_util.types_pkg.all;
use bitvis_util.string_methods_pkg.all;
use bitvis_util.adaptations_pkg.all;
use bitvis_util.methods_pkg.all;
use bitvis_util.bfm_common_pkg.all;

--=================================================================================================
package avalon_st_bfm_generic_pkg is
  generic (GC_AVALON_ST_CHAN_WIDTH : natural;
           GC_AVALON_ST_DATA_WIDTH : natural);

  ----------------------------------------------------
  -- Types for AVALON BFMs
  ----------------------------------------------------
  constant C_SCOPE : string := "AVALON BFM";

  -- Configuration record to be assigned in the test harness.
  type t_avalon_st_config is
  record
    clk_period                 : time;
    uses_channels              : boolean;  -- does this Streaming interface use channels?
    bits_per_clock             : natural;  -- # of bits sent per clock (= width of
                                           -- DUT data bus)
    max_wait_cycles            : integer;  -- max number of cycles to wait (for
                                           -- read or check)
    ready_latency              : integer;  -- OPTIONAL: The number of cycles from the time 
                                           -- that ready is asserted until valid data can 
                                           -- be driven. Needed for backpressure 
                                           -- functionality.   
    max_wait_cycles_severity   : t_alert_level;  -- severity if max_wait_cycles expires
    received_too_much_severity : t_alert_level;  -- severity if receive more than expected
    
  end record;

  constant C_AVALON_ST_CONFIG_DEFAULT : t_avalon_st_config := (
    clk_period                 => 20 ns,
    uses_channels              => false,
    bits_per_clock             => 8,
    max_wait_cycles            => 10,
    ready_latency              => 0,
    max_wait_cycles_severity   => error,
    received_too_much_severity => error
    );

  -- Avalon Interface signals    
  type t_avalon_st_to_dut is record
    reset   : std_logic;
    reset_n : std_logic;

    -- Avalon bus signals 
    channel         : std_logic_vector(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    start_of_packet : std_logic;
    end_of_packet   : std_logic;
    empty           : std_logic_vector(7 downto 0);
    data            : std_logic_vector(GC_AVALON_ST_DATA_WIDTH-1 downto 0);
    valid           : std_logic;
    data_error      : std_logic;  -- use just one bit - TODO - up to 256 with
  -- corresponding errorDescriptor
    ready : std_logic;
  end record;

  type t_avalon_st_from_dut is record
    -- Avalon bus signals 
    channel         : std_logic_vector(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    start_of_packet : std_logic;
    end_of_packet   : std_logic;
    empty           : std_logic_vector(7 downto 0);
    data            : std_logic_vector(GC_AVALON_ST_DATA_WIDTH-1 downto 0);  -- C_AVALON_ST_CONFIG_DEFAULT.bits_per_clock
    valid           : std_logic;
    data_error      : std_logic;  -- use just one bit - TODO - up to 256 with
  -- corresponding errorDescriptor
    ready : std_logic;
  end record;
  
  constant C_AVALON_ST_TO_DUT_PASSIVE : t_avalon_st_to_dut := (
    reset           => 'L',
    reset_n         => 'H',
    channel         => (others => 'L'),
    start_of_packet => 'L',
    end_of_packet   => 'L',
    empty           => (others => 'L'),
    data            => (others => 'L'),
    valid           => 'L',
    data_error      => 'L',
    ready           => 'L'
    );  
    
  constant C_AVALON_ST_FROM_DUT_PASSIVE : t_avalon_st_from_dut := (
    channel         => (others => 'L'),
    start_of_packet => 'L',
    end_of_packet   => 'L',
    empty           => (others => 'L'),
    data            => (others => 'L'),
    valid           => 'L',
    data_error      => 'L',
    ready           => 'L'
    );  
    
  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  -- This procedure could be called from an a simple testbench or
  -- from an executor where there are concurrent BFMs - where
  -- all BFMs could have different configs and msg_id_panels
  -- From a simple testbench, just don't touch the defaults for
  -- the fields that are not needed. e.g.:
  -- avalon_st_write(my_avalon_st_if, chan, data);
  
  --
  -- avalon_st_write
  --
  -- Source: BFM
  -- Sink:   DUT
  --
  procedure avalon_st_write (
    constant channel_value    : in  unsigned(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string             := "";
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    signal avalon_st_from_dut : in  t_avalon_st_from_dut;
    constant scope            : in  string             := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel     := shared_msg_id_panel;
    constant config           : in  t_avalon_st_config := C_AVALON_ST_CONFIG_DEFAULT
    );

  --
  -- avalon_st_read
  --
  -- Source: DUT
  -- Sink:   BFM
  --
  procedure avalon_st_read (
    constant channel_value    : in  unsigned(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    signal avalon_st_from_dut : in  t_avalon_st_from_dut;
    constant scope            : in  string             := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel     := shared_msg_id_panel;
    constant config           : in  t_avalon_st_config := C_AVALON_ST_CONFIG_DEFAULT;
    constant proc_name        : in  string             := "avalon_st_read"  -- overwrite if called from other procedure like avalon_st_check
    );

  procedure avalon_st_check (
    constant channel_value    : in  unsigned(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    signal avalon_st_from_dut : in  t_avalon_st_from_dut;
    constant alert_level      : in  t_alert_level      := error;
    constant scope            : in  string             := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel     := shared_msg_id_panel;
    constant config           : in  t_avalon_st_config := C_AVALON_ST_CONFIG_DEFAULT
    );

  procedure avalon_st_reset (
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    constant num_rst_cycles   : in  integer
    );

end package avalon_st_bfm_generic_pkg;


--=================================================================================================
--=================================================================================================

package body avalon_st_bfm_generic_pkg is

  --
  -- avalon_st_write
  --
  -- Source: BFM
  -- Sink:   DUT
  --

  procedure avalon_st_write (
    constant channel_value    : in  unsigned(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    constant data_value       : in  std_logic_vector;
    constant msg              : in  string             := "";
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    signal avalon_st_from_dut : in  t_avalon_st_from_dut;
    constant scope            : in  string             := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel     := shared_msg_id_panel;
    constant config           : in  t_avalon_st_config := C_AVALON_ST_CONFIG_DEFAULT
    ) is    
    constant proc_name : string := "avalon_st_write";
    constant proc_call : string := "avalon_st_write(Channel:" & to_string(channel_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- Normalize to the DUT chan/data widths
    variable v_normalized_chan : std_logic_vector(GC_AVALON_ST_CHAN_WIDTH-1 downto 0) :=
      normalize_and_check(std_logic_vector(channel_value), avalon_st_to_dut.channel, ALLOW_NARROWER, "channel", "avalon_st_to_dut.channel", msg);
    variable v_normalized_data : std_logic_vector(data_value'length-1 downto 0) := data_value;

    -- Helper variables
    variable cycle        : integer := 0;
    variable timeout      : boolean := false;
    variable finished     : boolean := false;
    variable sent_so_far  : natural := 0;  -- # of bits sent
    variable bits_per_clk : natural := config.bits_per_clock;
  begin
    avalon_st_to_dut <= C_AVALON_ST_TO_DUT_PASSIVE;
    wait_until_given_time_after_rising_edge(clk, config.clk_period/4);

    -- Need to check that avalon_st_from_dut.ready = '1' if we shall
    -- support backpressure
    
    while not finished loop
      if cycle = 0 then
        avalon_st_to_dut.start_of_packet <= '1';
        avalon_st_to_dut.valid           <= '1';
        avalon_st_to_dut.channel         <= v_normalized_chan;
        avalon_st_to_dut.data(bits_per_clk-1 downto 0) <=
          v_normalized_data(v_normalized_data'left downto
                            v_normalized_data'left-(bits_per_clk-1));
        if (v_normalized_data'length <= bits_per_clk) then
          avalon_st_to_dut.end_of_packet <= '1';
          finished                := true;
        end if;
      elsif sent_so_far + bits_per_clk < data_value'length then
        -- middle packet - not last yet
        avalon_st_to_dut.start_of_packet <= '0';
        avalon_st_to_dut.valid           <= '1';
        avalon_st_to_dut.channel         <= v_normalized_chan;
        avalon_st_to_dut.data(bits_per_clk-1 downto 0) <=
          v_normalized_data(v_normalized_data'length-1 - sent_so_far downto
                            v_normalized_data'length-1 - sent_so_far - (bits_per_clk-1));
      else
        -- last packet
        avalon_st_to_dut        <= C_AVALON_ST_TO_DUT_PASSIVE;
        finished                := true;
        avalon_st_to_dut.end_of_packet <= '1';
        avalon_st_to_dut.valid         <= '1';
        avalon_st_to_dut.channel       <= v_normalized_chan;
        avalon_st_to_dut.data(bits_per_clk-1 downto
                       (bits_per_clk - (v_normalized_data'length-sent_so_far))) <=
          v_normalized_data(v_normalized_data'length-1 - sent_so_far downto v_normalized_data'right);
      end if;
      cycle       := cycle + 1;
      sent_so_far := sent_so_far + bits_per_clk;

      wait until rising_edge(clk);
      wait_until_given_time_after_rising_edge(clk, config.clk_period/4);
      
    end loop;

    avalon_st_to_dut <= C_AVALON_ST_TO_DUT_PASSIVE;
    log(ID_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
    
  end procedure avalon_st_write;
  
  --
  -- avalon_st_read
  --
  -- Source: DUT
  -- Sink:   BFM
  --
  
  procedure avalon_st_read (
    constant channel_value    : in  unsigned(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    variable data_value       : out std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    signal avalon_st_from_dut : in  t_avalon_st_from_dut;
    constant scope            : in  string             := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel     := shared_msg_id_panel;
    constant config           : in  t_avalon_st_config := C_AVALON_ST_CONFIG_DEFAULT;
    constant proc_name        : in  string             := "avalon_st_read"  -- overwrite if called from other procedure like avalon_st_check
    ) is  
    constant proc_call : string := "avalon_st_read(Channel:" & to_string(channel_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- Normalize to the DUT chan/data widths
    variable v_normalized_chan : std_logic_vector(GC_AVALON_ST_CHAN_WIDTH-1 downto 0) :=
      normalize_and_check(std_logic_vector(channel_value), avalon_st_from_dut.channel, ALLOW_NARROWER, "channel", "avalon_st_from_dut.channel", msg);
    variable v_normalized_data : std_logic_vector(data_value'length-1 downto 0) := data_value;
    -- Helper variables
    variable start_of_packet_detected : boolean := false;
    variable timeout                  : boolean := false;
    variable finished                 : boolean := false;
    variable bits_per_clk             : natural := config.bits_per_clock;
    variable received_so_far          : natural := 0;  -- # of bits received
    variable invalid_count            : integer := 0;  -- # cycles without valid being asserted
  begin
    avalon_st_to_dut         <= C_AVALON_ST_TO_DUT_PASSIVE;
    wait_until_given_time_after_rising_edge(clk, config.clk_period/4);
    -- start the read by activating BFM ready signal.
    avalon_st_to_dut.ready   <= '1';

    while not finished loop
      wait until rising_edge(clk);
      wait_until_given_time_after_rising_edge(clk, config.clk_period/4);

      if avalon_st_from_dut.valid = '1' then
        invalid_count := 0;
        -- got data
        if not start_of_packet_detected then
          start_of_packet_detected := true;
          if (not avalon_st_from_dut.start_of_packet) then
            alert(error, proc_call & "=> Failed. Start of packet not set for first valid transfer.");
          end if;
        end if;
        if avalon_st_from_dut.end_of_packet then
          finished := true;
          v_normalized_data(v_normalized_data'left - received_so_far downto 0) :=
            avalon_st_from_dut.data(bits_per_clk-1 downto bits_per_clk - (data_value'length-received_so_far));
          received_so_far := received_so_far + (data_value'length-received_so_far);
        else
          if (v_normalized_data'left - received_so_far) >= (bits_per_clk-1) then
            v_normalized_data(v_normalized_data'left - received_so_far downto
                              v_normalized_data'left - received_so_far - (bits_per_clk-1)) := avalon_st_from_dut.data(bits_per_clk-1 downto 0);
          end if;
          received_so_far := received_so_far + bits_per_clk;
        end if;
        if (received_so_far > v_normalized_data'length) or
          ((received_so_far = v_normalized_data'length) and
           finished = false) then
          alert(config.received_too_much_severity, proc_call & "=> Failed. Received more data than expected - timeout");
          finished := true;
        end if;
      else
        if invalid_count >= config.max_wait_cycles then
          timeout  := true;
          finished := true;
        else
          invalid_count := invalid_count + 1;
        end if;
      end if;

      -- did we timeout?
      if timeout then
        alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout waiting for valid data");
      end if;
    end loop;

    data_value := v_normalized_data;

    if proc_name = "avalon_st_read" then
      log(ID_BFM, proc_call & "=> " & to_string(data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else

    end if;

    wait until rising_edge(clk);
    wait_until_given_time_after_rising_edge(clk, config.clk_period/4);
    avalon_st_to_dut <= C_AVALON_ST_TO_DUT_PASSIVE;
  end procedure avalon_st_read;
  
  
  procedure avalon_st_check (
    constant channel_value    : in  unsigned(GC_AVALON_ST_CHAN_WIDTH-1 downto 0);
    constant data_exp         : in  std_logic_vector;
    constant msg              : in  string;
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    signal avalon_st_from_dut : in  t_avalon_st_from_dut;
    constant alert_level      : in  t_alert_level      := error;
    constant scope            : in  string             := C_SCOPE;
    constant msg_id_panel     : in  t_msg_id_panel     := shared_msg_id_panel;
    constant config           : in  t_avalon_st_config := C_AVALON_ST_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_st_check";
    constant proc_call : string := "avalon_st_check(Channel:" & to_string(channel_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- Helper variables
    variable v_data_value      : std_logic_vector(data_exp'length-1 downto 0) := (others => '0');
    variable v_normalized_data : std_logic_vector(data_exp'length-1 downto 0) := data_exp;
    variable v_check_ok        : boolean;
  begin
    avalon_st_read(channel_value, v_data_value, msg, clk, avalon_st_to_dut, avalon_st_from_dut, scope, msg_id_panel, config, proc_name);

    v_check_ok := true;
    for i in 0 to (data_exp'length)-1 loop
      if v_normalized_data(i) = '-' or v_normalized_data(i) = v_data_value(i) then
        v_check_ok := true;
      else
        v_check_ok := false;
        exit;
      end if;
    end loop;

    if not v_check_ok then
      alert(alert_level, proc_call & "=> Failed. slv Was " & to_string(v_data_value, HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & "." & LF & msg, scope);
    else
      log(ID_BFM, proc_call & "=> OK, received data = " & to_string(v_normalized_data, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
  end procedure avalon_st_check;
  
  
  procedure avalon_st_reset (
    signal clk                : in  std_logic;
    signal avalon_st_to_dut   : out t_avalon_st_to_dut;
    constant num_rst_cycles   : in  integer
    ) is 
  begin
    avalon_st_to_dut         <= C_AVALON_ST_TO_DUT_PASSIVE;
    avalon_st_to_dut.reset   <= '1';
    avalon_st_to_dut.reset_n <= '0';
    for i in 1 to num_rst_cycles loop
      wait until rising_edge(clk);
    end loop;
    avalon_st_to_dut.reset   <= '0';
    avalon_st_to_dut.reset_n <= '1';

    wait until rising_edge(clk);
  end procedure avalon_st_reset;

end package body avalon_st_bfm_generic_pkg;

