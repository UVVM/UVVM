--================================================================================================================================
-- Copyright (c) 2019 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--================================================================================================================================

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--================================================================================================================================
--================================================================================================================================
package avalon_st_bfm_pkg is

  --==========================================================================================
  -- Types and constants for AVALON_ST BFM
  --==========================================================================================
  constant C_SCOPE : string := "AVALON_ST BFM";

  -- Interface record for BFM signals
  type t_avalon_st_if is record
    channel         : std_logic_vector;
    data            : std_logic_vector; -- Data. Width is constrained when the procedure is called.
    data_error      : std_logic_vector;
    ready           : std_logic;        -- Backpressure
    valid           : std_logic;        -- Data valid
    empty           : std_logic_vector;
    end_of_packet   : std_logic;
    start_of_packet : std_logic;
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_avalon_st_bfm_config is
  record
    max_wait_cycles             : integer;       -- Used for setting the maximum cycles to wait before an alert is issued when
                                                 -- waiting for ready or valid signals from the DUT.
    max_wait_cycles_severity    : t_alert_level; -- Severity if max_wait_cycles expires.
    clock_period                : time;          -- Period of the clock signal.
    --clock_period_margin         : time;          -- Input clock period margin to specified clock_period
    --clock_margin_severity       : t_alert_level; -- The above margin will have this severity
    --setup_time                  : time;          -- Setup time for generated signals, set to clock_period/4
    --hold_time                   : time;          -- Hold time for generated signals, set to clock_period/4
    --byte_endianness             : t_byte_endianness; -- Byte ordering from left (big-endian) or right (little-endian)
    --uses_channels               : boolean;       -- does this Streaming interface use channels?
    bits_per_clock              : natural;       -- Number of bits sent per clock (= width of DUT data bus)
    --ready_latency               : integer;       -- OPTIONAL: The number of cycles from the time that ready is asserted until
                                                 -- valid data can be driven. Needed for backpressure functionality.   
    received_too_much_severity  : t_alert_level; -- severity if receive more than expected
    -- Common
    --id_for_bfm                  : t_msg_id;      -- The message ID used as a general message ID in the BFM
    --id_for_bfm_wait             : t_msg_id;      -- The message ID used for logging waits in the BFM
    --id_for_bfm_poll             : t_msg_id;      -- The message ID used for logging polling in the BFM
  end record;

  -- Define the default value for the BFM config
  constant C_AVALON_ST_BFM_CONFIG_DEFAULT : t_avalon_st_bfm_config := (
    max_wait_cycles             => 100,
    max_wait_cycles_severity    => ERROR,
    clock_period                => 0 ns,  -- Make sure we notice if we forget to set clock period.
    --clock_period_margin         => 0 ns,
    --clock_margin_severity       => TB_ERROR,
    --setup_time                  => 0 ns,
    --hold_time                   => 0 ns,
    --byte_endianness             => FIRST_BYTE_LEFT,
    --uses_channels               => false,
    bits_per_clock              => 8,
    --ready_latency               => 0,
    received_too_much_severity  => ERROR
    --id_for_bfm                  => ID_BFM,
    --id_for_bfm_wait             => ID_BFM_WAIT,
    --id_for_bfm_poll             => ID_BFM_POLL
  );

  --==========================================================================================
  -- BFM procedures
  --==========================================================================================
  -- This function returns an Avalon-ST interface with initialized signals.
  -- All input signals are initialized to 0
  -- All output signals are initialized to Z
  function init_avalon_st_if_signals(
    is_master        : boolean; -- When true, this BFM drives data signals
    channel_width    : natural;
    data_width       : natural;
    data_error_width : natural;
    empty_width      : natural
    ) return t_avalon_st_if;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Transmit
  -- Source: BFM
  -- Sink:   DUT
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_transmit (
    constant channel_value    : in    unsigned;
    constant data_value       : in    std_logic_vector;
    constant msg              : in    string                 := "";
    signal   clk              : in    std_logic;
    signal   avalon_st_if     : inout t_avalon_st_if;
    constant scope            : in    string                 := C_SCOPE;
    constant msg_id_panel     : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config           : in    t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
    );

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Receive
  -- Source: DUT
  -- Sink:   BFM
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_receive (
    constant channel_value    : in    unsigned;
    variable data_value       : out   std_logic_vector;
    constant msg              : in    string                 := "";
    signal   clk              : in    std_logic;
    signal   avalon_st_if     : inout t_avalon_st_if;
    constant scope            : in    string                 := C_SCOPE;
    constant msg_id_panel     : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config           : in    t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    constant proc_name        : in    string := "avalon_st_receive"  -- overwrite if called from other procedure like avalon_st_expect
    );

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Expect
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_expect (
    constant channel_value    : in    unsigned;
    constant data_exp         : in    std_logic_vector;
    constant msg              : in    string                 := "";
    signal   clk              : in    std_logic;
    signal   avalon_st_if     : inout t_avalon_st_if;
    constant alert_level      : in    t_alert_level          := error;
    constant scope            : in    string                 := C_SCOPE;
    constant msg_id_panel     : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config           : in    t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
    );

end package avalon_st_bfm_pkg;


--================================================================================================================================
--================================================================================================================================
package body avalon_st_bfm_pkg is

  function init_avalon_st_if_signals(
    is_master        : boolean; -- When true, this BFM drives data signals
    channel_width    : natural;
    data_width       : natural;
    data_error_width : natural;
    empty_width      : natural
    ) return t_avalon_st_if is
    variable init_if : t_avalon_st_if(channel(channel_width-1 downto 0),
                                      data(data_width-1 downto 0),
                                      data_error(data_error_width-1 downto 0),
                                      empty(empty_width-1 downto 0));
  begin
    if is_master then
      -- from slave to master
      init_if.ready           := 'Z';
      -- from master to slave
      init_if.channel         := (init_if.channel'range => '0');
      init_if.data            := (init_if.data'range => '0');
      init_if.data_error      := (init_if.data_error'range => '0');
      init_if.valid           := '0';
      init_if.empty           := (init_if.empty'range => '0');
      init_if.end_of_packet   := '0';
      init_if.start_of_packet := '0';
    else
      -- from slave to master
      init_if.ready           := '0';
      -- from master to slave
      init_if.channel         := (init_if.channel'range => 'Z');
      init_if.data            := (init_if.data'range => 'Z');
      init_if.data_error      := (init_if.data_error'range => 'Z');
      init_if.valid           := 'Z';
      init_if.empty           := (init_if.empty'range => 'Z');
      init_if.end_of_packet   := 'Z';
      init_if.start_of_packet := 'Z';
    end if;
    return init_if;
  end function;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Transmit
  -- Source: BFM
  -- Sink:   DUT
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_transmit (
    constant channel_value    : in    unsigned;
    constant data_value       : in    std_logic_vector;
    constant msg              : in    string                 := "";
    signal   clk              : in    std_logic;
    signal   avalon_st_if     : inout t_avalon_st_if;
    constant scope            : in    string                 := C_SCOPE;
    constant msg_id_panel     : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config           : in    t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
    ) is    
    constant proc_name : string := "avalon_st_transmit";
    constant proc_call : string := "avalon_st_transmit(Channel:" & to_string(channel_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- Normalize to the DUT chan/data widths
    variable v_normalized_chan : std_logic_vector(channel_value'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(channel_value), avalon_st_if.channel, ALLOW_NARROWER, "channel", "avalon_st_if.channel", msg);
    variable v_normalized_data : std_logic_vector(data_value'length-1 downto 0) := data_value;

    -- Helper variables
    variable cycle        : integer := 0;
    variable timeout      : boolean := false;
    variable finished     : boolean := false;
    variable sent_so_far  : natural := 0;  -- # of bits sent
    variable bits_per_clk : natural := config.bits_per_clock;
  begin
    avalon_st_if <= init_avalon_st_if_signals(is_master        => true, -- this BFM drives data signals
                                              channel_width    => avalon_st_if.channel'length,
                                              data_width       => avalon_st_if.data'length,
                                              data_error_width => avalon_st_if.data_error'length,
                                              empty_width      => avalon_st_if.empty'length);
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);

    -- Need to check that avalon_st_if.ready = '1' if we shall
    -- support backpressure
    while not finished loop
      if cycle = 0 then
        avalon_st_if.start_of_packet <= '1';
        avalon_st_if.valid           <= '1';
        avalon_st_if.channel         <= v_normalized_chan;
        avalon_st_if.data(bits_per_clk-1 downto 0) <=
          v_normalized_data(v_normalized_data'left downto
                            v_normalized_data'left-(bits_per_clk-1));
        if (v_normalized_data'length <= bits_per_clk) then
          avalon_st_if.end_of_packet <= '1';
          finished                := true;
        end if;
      elsif sent_so_far + bits_per_clk < data_value'length then
        -- middle packet - not last yet
        avalon_st_if.start_of_packet <= '0';
        avalon_st_if.valid           <= '1';
        avalon_st_if.channel         <= v_normalized_chan;
        avalon_st_if.data(bits_per_clk-1 downto 0) <=
          v_normalized_data(v_normalized_data'length-1 - sent_so_far downto
                            v_normalized_data'length-1 - sent_so_far - (bits_per_clk-1));
      else
        -- last packet
        avalon_st_if <= init_avalon_st_if_signals(is_master        => true, -- this BFM drives data signals
                                                  channel_width    => avalon_st_if.channel'length,
                                                  data_width       => avalon_st_if.data'length,
                                                  data_error_width => avalon_st_if.data_error'length,
                                                  empty_width      => avalon_st_if.empty'length);
        finished                := true;
        avalon_st_if.end_of_packet <= '1';
        avalon_st_if.valid         <= '1';
        avalon_st_if.channel       <= v_normalized_chan;
        avalon_st_if.data(bits_per_clk-1 downto
                       (bits_per_clk - (v_normalized_data'length-sent_so_far))) <=
          v_normalized_data(v_normalized_data'length-1 - sent_so_far downto v_normalized_data'right);
      end if;
      cycle       := cycle + 1;
      sent_so_far := sent_so_far + bits_per_clk;

      wait until rising_edge(clk);
      wait_until_given_time_after_rising_edge(clk, config.clock_period/4);

    end loop;

    avalon_st_if <= init_avalon_st_if_signals(is_master        => true, -- this BFM drives data signals
                                              channel_width    => avalon_st_if.channel'length,
                                              data_width       => avalon_st_if.data'length,
                                              data_error_width => avalon_st_if.data_error'length,
                                              empty_width      => avalon_st_if.empty'length);
    log(ID_BFM, proc_call & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);
  end procedure avalon_st_transmit;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Receive
  -- Source: DUT
  -- Sink:   BFM
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_receive (
    constant channel_value    : in    unsigned;
    variable data_value       : out   std_logic_vector;
    constant msg              : in    string                 := "";
    signal   clk              : in    std_logic;
    signal   avalon_st_if     : inout t_avalon_st_if;
    constant scope            : in    string                 := C_SCOPE;
    constant msg_id_panel     : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config           : in    t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    constant proc_name        : in    string := "avalon_st_receive"  -- overwrite if called from other procedure like avalon_st_expect
    ) is  
    constant proc_call : string := "avalon_st_receive(Channel:" & to_string(channel_value, HEX, AS_IS, INCL_RADIX) & ")";

    -- Normalize to the DUT chan/data widths
    variable v_normalized_chan : std_logic_vector(channel_value'length-1 downto 0) :=
      normalize_and_check(std_logic_vector(channel_value), avalon_st_if.channel, ALLOW_NARROWER, "channel", "avalon_st_if.channel", msg);
    variable v_normalized_data : std_logic_vector(data_value'length-1 downto 0) := data_value;
    -- Helper variables
    variable start_of_packet_detected : boolean := false;
    variable timeout                  : boolean := false;
    variable finished                 : boolean := false;
    variable bits_per_clk             : natural := config.bits_per_clock;
    variable received_so_far          : natural := 0;  -- # of bits received
    variable invalid_count            : integer := 0;  -- # cycles without valid being asserted
  begin
    avalon_st_if <= init_avalon_st_if_signals(is_master        => false,
                                              channel_width    => avalon_st_if.channel'length,
                                              data_width       => avalon_st_if.data'length,
                                              data_error_width => avalon_st_if.data_error'length,
                                              empty_width      => avalon_st_if.empty'length);
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    -- start the read by activating BFM ready signal.
    avalon_st_if.ready   <= '1';

    while not finished loop
      wait until rising_edge(clk);
      wait_until_given_time_after_rising_edge(clk, config.clock_period/4);

      if avalon_st_if.valid = '1' then
        invalid_count := 0;
        -- got data
        if not start_of_packet_detected then
          start_of_packet_detected := true;
          if (not avalon_st_if.start_of_packet) then
            alert(error, proc_call & "=> Failed. Start of packet not set for first valid transfer.");
          end if;
        end if;
        if avalon_st_if.end_of_packet then
          finished := true;
          v_normalized_data(v_normalized_data'left - received_so_far downto 0) :=
            avalon_st_if.data(bits_per_clk-1 downto bits_per_clk - (data_value'length-received_so_far));
          received_so_far := received_so_far + (data_value'length-received_so_far);
        else
          if (v_normalized_data'left - received_so_far) >= (bits_per_clk-1) then
            v_normalized_data(v_normalized_data'left - received_so_far downto
                              v_normalized_data'left - received_so_far - (bits_per_clk-1)) := avalon_st_if.data(bits_per_clk-1 downto 0);
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

    if proc_name = "avalon_st_receive" then
      log(ID_BFM, proc_call & "=> " & to_string(data_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ". " & add_msg_delimiter(msg), scope, msg_id_panel);
    else

    end if;

    wait until rising_edge(clk);
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
    avalon_st_if <= init_avalon_st_if_signals(is_master        => false,
                                              channel_width    => avalon_st_if.channel'length,
                                              data_width       => avalon_st_if.data'length,
                                              data_error_width => avalon_st_if.data_error'length,
                                              empty_width      => avalon_st_if.empty'length);
  end procedure avalon_st_receive;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Expect
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_expect (
    constant channel_value    : in    unsigned;
    constant data_exp         : in    std_logic_vector;
    constant msg              : in    string                 := "";
    signal   clk              : in    std_logic;
    signal   avalon_st_if     : inout t_avalon_st_if;
    constant alert_level      : in    t_alert_level          := error;
    constant scope            : in    string                 := C_SCOPE;
    constant msg_id_panel     : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config           : in    t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT
    ) is
    constant proc_name : string := "avalon_st_expect";
    constant proc_call : string := "avalon_st_expect(Channel:" & to_string(channel_value, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data_exp, HEX, AS_IS, INCL_RADIX) & ")";

    -- Helper variables
    variable v_data_value      : std_logic_vector(data_exp'length-1 downto 0) := (others => '0');
    variable v_normalized_data : std_logic_vector(data_exp'length-1 downto 0) := data_exp;
    variable v_check_ok        : boolean;
  begin
    avalon_st_receive(channel_value, v_data_value, msg, clk, avalon_st_if, scope, msg_id_panel, config, proc_name);

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
  end procedure avalon_st_expect;

end package body avalon_st_bfm_pkg;