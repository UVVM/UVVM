--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- VHDL unit     : Bitvis VIP AXISTREAM Library : axistream_bfm_pkg 
--
-- Description   : See library quick reference (under 'doc') and README-file(s).
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use IEEE.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--========================================================================================================================
--========================================================================================================================
package axistream_bfm_pkg is

  --========================================================================================================================
  -- Types and constants for AXISTREAM_BFM 
  --========================================================================================================================
  constant C_SCOPE : string := "AXISTREAM_BFM";

  alias t_slv8_array is t_byte_array;

  -- c_max_tuser_bits : The BFM supports up to c_max_tuser_bits user bit per data word. The value may be increased as needed. 
  constant c_max_tuser_bits : positive := 8;
  type     t_user_array is array(natural range <>) of std_logic_vector(c_max_tuser_bits-1 downto 0);

  -- Interface record for BFM signals when data flows from BFM to DUT
  -- Interface record for BFM signals when data flows from DUT to BFM 
  type t_axistream_if is record
    tdata  : std_logic_vector;  -- Data. Width is constrained when the procedure is called
    tkeep  : std_logic_vector;  -- One valid-bit per data byte
    tuser  : std_logic_vector;  -- User metadata 
    tvalid : std_logic;         -- Data valid
    tlast  : std_logic;         -- Active high during last data word in packet.
    tready : std_logic;         -- Backpressure 
  end record;

  -- Configuration record to be assigned in the test harness.
  type t_axistream_bfm_config is
  record
    -- Common
    max_wait_cycles            : integer;
    max_wait_cycles_severity   : t_alert_level;
    clock_period               : time;
    -- config for axistream_receive()
    check_packet_length        : boolean;       -- When true, receive() will check that last is set at data_array'high
    protocol_error_severity    : t_alert_level; -- severity if protocol errors are detected by axistream_receive()
    ready_low_at_word_num      : integer;       -- When the Sink BFM shall deassert ready
    ready_low_duration         : integer;       -- Number of clock cycles to deassert ready
    ready_default_value        : std_logic;     -- Which value the BFM shall set ready to between accesses.
    -- Common
    id_for_bfm                 : t_msg_id;
    id_for_bfm_wait            : t_msg_id;
    id_for_bfm_poll            : t_msg_id;
  end record;

  -- Define the default value for the BFM config
  constant C_AXISTREAM_BFM_CONFIG_DEFAULT : t_axistream_bfm_config := (
    max_wait_cycles            => 100,
    max_wait_cycles_severity   => ERROR,
    clock_period               => 0 ns,  -- Make sure we notice if we forget to set clock period.
    check_packet_length        => false,
    protocol_error_severity    => ERROR,
    ready_low_at_word_num      => 0,
    ready_low_duration         => 0,
    ready_default_value        => '0',
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL
    );

  --========================================================================================================================
  -- BFM procedures 
  --========================================================================================================================

  -- - This function returns an AXI Stream interface with initialized signals.
  -- - All input signals are initialized to 0
  -- - All output signals are initialized to Z
  function init_axistream_if_signals(
    is_master  : boolean;  -- When true, this BFM drives data signals
    data_width : natural;
    user_width : natural
    ) return t_axistream_if;


  --
  -- Source: BFM
  -- Sink:   DUT
  --
  procedure axistream_transmit (
    constant data_array   : in    t_slv8_array;
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );

  -- Overloaded version without records
  procedure axistream_transmit (
    constant data_array          : in    t_slv8_array;
    constant user_array          : in    t_user_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : out   std_logic_vector;
    signal   axistream_if_tkeep  : out   std_logic_vector;
    signal   axistream_if_tuser  : out   std_logic_vector;
    signal   axistream_if_tvalid : out   std_logic;
    signal   axistream_if_tlast  : out   std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );

  procedure axistream_transmit (
    constant data_array   : in    t_slv8_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );

  --
  -- Source: DUT
  -- Sink:   BFM
  --
  procedure axistream_receive (
    variable data_array   : inout t_slv8_array;
    variable data_length  : inout natural;       -- Number of bytes received
    variable user_array   : inout t_user_array;  -- Assuming c_max_tuser_bits user bit per data byte. 
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string                 := "axistream_receive"  -- overwrite if called from other procedure like axistream_expect
    );

  procedure axistream_expect (
    constant exp_data_array : in    t_slv8_array;
    constant exp_user_array : in    t_user_array;
    constant alert_level    : in    t_alert_level          := error;
    constant msg            : in    string                 := "";
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );   

  procedure axistream_expect (
    constant exp_data_array : in    t_slv8_array;
    constant alert_level    : in    t_alert_level          := error;
    constant msg            : in    string                 := "";
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    );   
end package axistream_bfm_pkg;


--========================================================================================================================
--========================================================================================================================

package body axistream_bfm_pkg is
  -- WORKAROUND: for GHDL
  --   Version:	 0.34dev (last tested pre-release version: 6235a6a)
  --   Issue:		 'others' can't be used to initialize unconstrained arrays
  --             in a record.
  --   Ticket:   https://github.com/tgingold/ghdl/issues/191
  --   Solution: prefix'range can be used as a workaround
  function init_axistream_if_signals(
    is_master  : boolean;  -- When true, this BFM drives data signals
    data_width : natural;
    user_width : natural
    ) return t_axistream_if is
    variable init_if : t_axistream_if(tdata(data_width-1 downto 0),
                                      tkeep(data_width/8-1 downto 0),
                                      tuser(user_width-1 downto 0)
                                      ); 
  begin

    if is_master then
      -- from slave to master 
      init_if.tready := 'Z';

      -- from master to slave
      init_if.tvalid := '0';
      init_if.tdata  := (init_if.tdata'range => '0');
      init_if.tkeep  := (init_if.tkeep'range => '0');
      init_if.tuser  := (init_if.tuser'range => '0');
      init_if.tlast  := '0';
    else
      -- from slave to master
      init_if.tready := '0';
      -- from master to slave
      init_if.tvalid := 'Z';
      init_if.tdata  := (init_if.tdata'range => 'Z');
      init_if.tkeep  := (init_if.tkeep'range => 'Z');
      init_if.tuser  := (init_if.tuser'range => 'Z');
      init_if.tlast  := 'Z';
    end if;
    return init_if;
  end function;

  -- Send a packet on the AXI interface. 
  -- Packet length and data is defined by data_array
  -- tuser is set based on user_array
  procedure axistream_transmit (
    constant data_array   : in    t_slv8_array;  -- Byte in index 0 is transmitted first
    constant user_array   : in    t_user_array;
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is 

    constant proc_name : string := "axistream_transmit";
    constant proc_call : string := "axistream_transmit(" & to_string(data_array'length) & "B)";

    constant c_num_bytes_per_word     : natural := axistream_if.tdata'length/8;
    constant c_num_user_bits_per_word : natural := axistream_if.tuser'length;

    -- Helper variables
    variable v_byte_in_word                 : integer range 0 to c_num_bytes_per_word-1 := 0;  -- current byte within the data word
    variable v_byte_cnt                     : natural := 0;
    variable v_clk_cycles_waited            : natural := 0;
    variable v_wait_for_next_transfer_cycle : boolean := false;  -- When set, the BFM shall wait for at least one clock cycle, until tready='1' before continuing

  begin
    check_value(axistream_if.tdata'length >= 8,      TB_ERROR, "Sanity check: Check that tdata is at least one byte wide. Narrower tdata is not supported.", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tdata'length mod 8 = 0, TB_ERROR, "Sanity check: Check that tdata is an integer number of bytes wide.",                         scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(axistream_if.tuser'length <= c_max_tuser_bits, TB_ERROR, "Sanity check: Check that c_max_tuser_bits is high enough for axistream_if.tuser.", scope, ID_NEVER, msg_id_panel, proc_call); 
    check_value(data_array'ascending,                TB_ERROR, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(user_array'ascending,                TB_ERROR, "Sanity check: Check that data_array is ascending (defined with 'to'), for byte order clarity", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(config.clock_period /= 0 ns,         TB_ERROR, "Sanity check: Check that bfm_config.clock_period is set",                                    scope, ID_NEVER, msg_id_panel, proc_call);

    axistream_if <= init_axistream_if_signals(is_master  => true,  -- this BFM drives data signals
                                              data_width => axistream_if.tdata'length,
                                              user_width => axistream_if.tuser'length);

    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);


    log(ID_PACKET_INITIATE, proc_call & "=> " & msg, scope, msg_id_panel);

    for byte in 0 to data_array'high loop
      log(ID_PACKET_DATA, proc_call & "=> Tx " & to_string(data_array(byte), HEX, AS_IS, INCL_RADIX) &
          ", tuser=" & to_string(user_array(byte/c_num_bytes_per_word), HEX, AS_IS, INCL_RADIX) &
          ", byte=" & to_string(byte) &
          ", v_byte_in_word=" & to_string(v_byte_in_word) &
          ". " & msg,
          scope, msg_id_panel);
      axistream_if.tvalid <= '1';

      -- Byte locations within the data word is described in chapter 2.3 in "ARM IHI 0051A"
      axistream_if.tdata(7+8*v_byte_in_word downto 8*v_byte_in_word) <= data_array(byte);

      -- Set tuser for this clock cycle (word)
      if v_byte_in_word = 0 then
        axistream_if.tuser(c_num_user_bits_per_word-1 downto 0) <= user_array(byte/c_num_bytes_per_word)(c_num_user_bits_per_word-1 downto 0);
      end if;

      -- TKEEP[x] is associated with TDATA[(7+8*v_byte_in_word) : 8*v_byte_in_word]. 
      axistream_if.tkeep(v_byte_in_word) <= '1';

      v_wait_for_next_transfer_cycle := false;  -- default

      if byte = data_array'high then
        -- Packet done
        axistream_if.tlast     <= '1';
        v_wait_for_next_transfer_cycle := true;
      else
        axistream_if.tlast <= '0';
      end if;

      if v_byte_in_word = c_num_bytes_per_word-1 then
        -- Next byte is in the next clk cycle
        v_byte_in_word := 0;

        v_wait_for_next_transfer_cycle := true;
      else
        -- Next byte is in the same clk cycle
        v_byte_in_word := v_byte_in_word + 1;
      end if;

      if v_wait_for_next_transfer_cycle then
        wait for config.clock_period;
        while axistream_if.tready = '0' loop
          wait for config.clock_period;
          v_clk_cycles_waited := v_clk_cycles_waited + 1;
          check_value(v_clk_cycles_waited <= config.max_wait_cycles, config.max_wait_cycles_severity,
                      ": Timeout while waiting for tready", scope, ID_NEVER, msg_id_panel, proc_call);
        end loop;

        -- Default values for the next clk cycle
        axistream_if <= init_axistream_if_signals(is_master  => true,  -- this BFM drives data signals
                                                  data_width => axistream_if.tdata'length,
                                                  user_width => axistream_if.tuser'length);
      end if;

    end loop;

    -- Done.
    axistream_if.tvalid <= '0';

    log(ID_PACKET_COMPLETE, proc_call & "=> Tx DONE" &
        ". " & msg,
        scope, msg_id_panel);

  end procedure axistream_transmit;

  -- Overload that doesn't use records for the AXI interface: 
  procedure axistream_transmit (
    constant data_array          : in    t_slv8_array;
    constant user_array          : in    t_user_array;
    constant msg                 : in    string                 := "";
    signal   clk                 : in    std_logic;
    signal   axistream_if_tdata  : out   std_logic_vector;
    signal   axistream_if_tkeep  : out   std_logic_vector;
    signal   axistream_if_tuser  : out   std_logic_vector;
    signal   axistream_if_tvalid : out   std_logic;
    signal   axistream_if_tlast  : out   std_logic;
    signal   axistream_if_tready : inout std_logic;
    constant scope               : in    string                 := C_SCOPE;
    constant msg_id_panel        : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config              : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is 
  begin
    axistream_transmit(
      data_array          => data_array,
      user_array          => user_array,
      msg                 => msg,
      clk                 => clk,
      axistream_if.tdata  => axistream_if_tdata,
      axistream_if.tkeep  => axistream_if_tkeep,
      axistream_if.tuser  => axistream_if_tuser,
      axistream_if.tvalid => axistream_if_tvalid,
      axistream_if.tlast  => axistream_if_tlast,
      axistream_if.tready => axistream_if_tready,
      scope               => scope,
      msg_id_panel        => msg_id_panel,
      config              => config);

  end procedure axistream_transmit;

  -- Overload with default value for user_array
  procedure axistream_transmit (
    constant data_array   : in    t_slv8_array;  -- Byte in index 0 is transmitted first
    constant msg          : in    string                 := "";
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is 
    constant c_user_array_default : t_user_array(0 to data_array'high) := (others => (others => '0'));
  begin
    axistream_transmit(
      data_array   => data_array,
      user_array   => c_user_array_default,
      msg          => msg,
      clk          => clk,
      axistream_if => axistream_if,
      scope        => scope,
      msg_id_panel => msg_id_panel,
      config       => config);

  end procedure axistream_transmit;

  -- Receive a packet, store it in data_array
  -- data_array'length can be longer than the actual packet, so that you can call receive() without knowing the length to be expected.
  procedure axistream_receive (
    variable data_array   : inout t_slv8_array;
    variable data_length  : inout natural;  -- Number of bytes received
    variable user_array   : inout t_user_array;
    constant msg          : in    string;
    signal   clk          : in    std_logic;
    signal   axistream_if : inout t_axistream_if;
    constant scope        : in    string                 := C_SCOPE;
    constant msg_id_panel : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config       : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant proc_name    : in    string                 := "axistream_receive"  -- overwrite if called from other procedure like axistream_expect
    ) is
    constant proc_call                : string := proc_name;
    constant c_num_bytes_per_word     : natural := axistream_if.tdata'length/8;
    constant c_num_user_bits_per_word : natural := axistream_if.tuser'length;

    -- Helper variables
    variable v_byte_in_word          : integer range 0 to c_num_bytes_per_word-1 := 0;  -- current Byte within the data word
    variable v_byte_cnt              : integer                                   := 0;  -- # bytes received
    variable v_timeout               : boolean                                   := false;
    variable v_done                  : boolean                                   := false;
    variable v_invalid_count         : integer                                   := 0;  -- # cycles without valid being asserted
    variable v_waited_this_iteration : boolean                                   := false;
    variable v_ready_low_done        : boolean                                   := false;
    variable v_byte_idx              : integer;
    variable v_word_idx              : integer;

  begin
    check_value(axistream_if.tuser'length <= c_max_tuser_bits, TB_ERROR, "Sanity check: Check that c_max_tuser_bits is high enough for axistream_if.tuser.", scope, ID_NEVER, msg_id_panel, proc_call); 
    check_value(data_array'ascending, TB_ERROR, "Sanity check: Check that data_array is defined with 'to' (not 'downto'), for knowing which byte is sent first", scope, ID_NEVER, msg_id_panel, proc_call);
    check_value(user_array'ascending, TB_ERROR, "Sanity check: Check that data_array is defined with 'to' (not 'downto'), for knowing which byte is sent first", scope, ID_NEVER, msg_id_panel, proc_call);

    -- Avoid driving inputs
    axistream_if <= init_axistream_if_signals(
      is_master  => false,
      data_width => axistream_if.tdata'length,
      user_width => axistream_if.tuser'length); 

    check_value(config.clock_period /= 0 ns, TB_ERROR, "Check that bfm_config.clock_period is set", scope, ID_NEVER, msg_id_panel, proc_call);

    -- wait until 1/4 clk period after rising edge 
    wait_until_given_time_after_rising_edge(clk, config.clock_period/4);

    log(ID_PACKET_INITIATE, proc_call & "=> Receive packet. " &
        "ready_low_at_word_num=" & to_string(config.ready_low_at_word_num) &
        "ready_low_duration=" & to_string(config.ready_low_duration) &
        msg, scope, msg_id_panel);

    ------------------------------------------------------------------------------------------------------------
    -- Sample byte by byte. There may be multiple bytes per clock cycle, depending on axistream_if'tdata width.
    ------------------------------------------------------------------------------------------------------------
    
    while not v_done loop
      v_waited_this_iteration := false;

      --
      -- Set tready low before given word
      --
      if (v_byte_in_word = 0) and
        (config.ready_low_at_word_num = v_byte_cnt/c_num_bytes_per_word) and
        (not v_ready_low_done) then
        axistream_if.tready <= '0';

        -- If we deassert ready before byte 0, keep it deasserted until valid goes high so that it matters
        if config.ready_low_at_word_num = 0 and axistream_if.tvalid = '0' then
          wait until axistream_if.tvalid = '1';
          -- wait until 1/4 clk period after rising edge 
          wait_until_given_time_after_rising_edge(clk, config.clock_period/4);
        end if;

        wait for config.ready_low_duration * config.clock_period;
        v_ready_low_done := true;

        log(ID_PACKET_DATA, proc_call & "=> ready low " &
            ", v_byte_cnt=" & to_string(v_byte_cnt) &
            ", v_byte_in_word=" & to_string(v_byte_in_word) &
            ", c_num_bytes_per_word=" & to_string(c_num_bytes_per_word) &
            ", div=" & to_string(v_byte_cnt/c_num_bytes_per_word) &
            ". " & msg,
            scope, msg_id_panel);
      end if;

      axistream_if.tready <= '1';       -- In case it was '0' 
      wait for 0 ns;                    -- Wait for signal to change value 

      -- Wait until data is transferred: valid and ready 
      if axistream_if.tvalid = '1' and axistream_if.tready = '1' then
        v_invalid_count := 0;

        -- Sample data. 
        data_array(v_byte_cnt) := axistream_if.tdata(7+8*v_byte_in_word downto 8*v_byte_in_word);

        -- Sample tuser for this clock cycle (word): There is one user_array entry per word 
        if v_byte_in_word = 0 then
          v_word_idx     := v_byte_cnt/c_num_bytes_per_word;
          if (v_word_idx <= user_array'high) then  -- Include this 'if' to allow a shorter user_array if the caller doesn't care what tuser is
            user_array(v_byte_cnt/c_num_bytes_per_word)(c_num_user_bits_per_word-1 downto 0) := axistream_if.tuser(c_num_user_bits_per_word-1 downto 0);
          end if;
        end if;

        log(ID_PACKET_DATA, proc_call & "=> Rx " & to_string(data_array(v_byte_cnt), HEX, AS_IS, INCL_RADIX) &
            ", v_byte_cnt=" & to_string(v_byte_cnt) &
            ", v_byte_in_word=" & to_string(v_byte_in_word) &
            ". " & msg,
            scope, msg_id_panel);

        -- Check tlast='1' at expected last byte
        if v_byte_cnt = data_array'high then
          check_value(axistream_if.tlast, '1', config.protocol_error_severity, "Check tlast at expected last byte = " & to_string(v_byte_cnt) & ". " & msg, scope);

          v_done := true;  -- Stop sampling data when we have filled the data_array
        end if;

        -- Allow that tlast arrives sooner than indicated by data_array'high
        -- if receive() is called without knowing the length to be expected.
        if axistream_if.tlast = '1' then
          if axistream_if.tkeep(v_byte_in_word) = '1' then
            if v_byte_in_word = c_num_bytes_per_word-1 then
              -- it's the last byte in word and tlast='1', thus the last in packet. 
              v_done := true;
            else
              if axistream_if.tkeep(v_byte_in_word+1) = '0' then
                -- Next byte in word is invalid, so this is the last byte
                v_done := true;

                -- Check that tkeep for the remaining bytes in the last word are also '0'. (Only continous stream supported)
                v_byte_idx := v_byte_in_word+1;
                l_check_remaining_TKEEP: loop
                  check_value(axistream_if.tkeep(v_byte_idx), '0', ERROR, "Check that tkeep doesn't go from '1' to '0' to '1' again within this last word. (The BFM supports only continuous stream)", scope, ID_NEVER, msg_id_panel, proc_call);
                  if v_byte_idx < c_num_bytes_per_word-1 then
                    v_byte_idx := v_byte_idx + 1; 
                  else
                    exit l_check_remaining_TKEEP;
                  end if; 
                end loop; 

              end if;
            end if;
          end if;
        else
          -- tlast = 0
          if (v_byte_cnt = data_array'high) then
            alert(config.protocol_error_severity, proc_call & "=> Failed. tlast not received, expected at or before byte#" & to_string(v_byte_cnt) & "." & msg, scope);
          end if;

          -- Check that all tkeep bits are '1'. (Only continous stream supported)
          check_value(axistream_if.tkeep(v_byte_in_word), '1', ERROR, "When tlast='0', check that all tkeep bits are '1'. (The BFM supports only continuous stream)", scope, ID_NEVER, msg_id_panel, proc_call);
        end if;

        if v_byte_in_word = c_num_bytes_per_word-1 then
          -- Next byte is in the next clk cycle
          wait for config.clock_period;
          v_waited_this_iteration := true;
          v_byte_in_word          := 0;
        else
          -- Next byte is in the same clk cycle
          v_byte_in_word := v_byte_in_word + 1;
        end if;

        -- Next byte
        v_byte_cnt := v_byte_cnt + 1;

      else  
        -- (tvalid and tready) = '0'
        -- Check for timeout (also when max_wait_cycles_severity = NO_ALERT, 
        --                    or else the VVC will wait forever, until the UVVM cmd times out)
        if (v_invalid_count >= config.max_wait_cycles) then
          v_timeout := true;
          v_done    := true;
        else
          v_invalid_count := v_invalid_count + 1;
        end if;

        wait for config.clock_period;
        v_waited_this_iteration := true;

      end if;

    end loop;  -- while not v_done

    data_length := v_byte_cnt;

    -- did we time out?
    if v_timeout then
      alert(config.max_wait_cycles_severity, proc_call & "=> Failed. Timeout while waiting for valid data. " & msg);
    else
      log(ID_PACKET_COMPLETE, proc_call & "=> Rx DONE (" & to_string(v_byte_cnt) & "B)" &
          ". " & msg, scope, msg_id_panel);
    end if;

    if not v_waited_this_iteration then
      -- Avoid sampling the same word again if the BFM is called again immediately
      wait for config.clock_period;
    end if;

    -- Done
    axistream_if.tready <= config.ready_default_value;

  end procedure axistream_receive;


  -- Receive data, then compare the received data against exp_data_array
  -- - If the received data is inconsistent with the expected data, an alert with 
  --   severity 'alert_level' is triggered.
  procedure axistream_expect (
    constant exp_data_array : in    t_slv8_array;  -- Expected data
    constant exp_user_array : in    t_user_array;  -- Expected tuser
    constant alert_level    : in    t_alert_level          := error;
    constant msg            : in    string                 := "";
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is 
    constant proc_name : string := "axistream_expect";
    constant proc_call : string := "axistream_expect(" & to_string(exp_data_array'length) & "B)";

    constant c_num_bytes_per_word     : natural := axistream_if.tdata'length/8;
    constant c_num_user_bits_per_word : natural := axistream_if.tuser'length;

    -- Helper variables
    variable v_config             : t_axistream_bfm_config := config;
    variable v_rx_data_array      : t_slv8_array(exp_data_array'range);  -- received data
    variable v_rx_user_array      : t_user_array(exp_user_array'range);  -- received tuser 
    variable v_rx_data_length     : natural;
    variable v_data_error_cnt     : natural                := 0;
    variable v_user_error_cnt     : natural                := 0;
    variable v_first_errored_byte : natural;
  begin
    -- Make the receive() procedure check tlast position is as expected
    v_config.check_packet_length := true;

    -- Receive and store data 
    axistream_receive(data_array   => v_rx_data_array,
                      data_length  => v_rx_data_length,
                      user_array   => v_rx_user_array,
                      msg          => msg,
                      clk          => clk,
                      axistream_if => axistream_if,
                      scope        => scope,
                      msg_id_panel => msg_id_panel,
                      config       => v_config,
                      proc_name    => proc_name);

    -- Check if each received bit matches the expected
    -- Find and report the first errored byte
    for byte in v_rx_data_array'high downto 0 loop
      for i in v_rx_data_array(byte)'range loop
        if (exp_data_array(byte)(i) = '-') or  -- Expected set to don't care, or 
          (v_rx_data_array(byte)(i) = exp_data_array(byte)(i)) then  -- received value matches expected
          -- Check is OK
        else
          -- Received byte does not match the expected byte
          --log(config.id_for_bfm, proc_call & "=> NOK, checked " & to_string(v_rx_data_array(byte), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_data_array(byte), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
          v_data_error_cnt     := v_data_error_cnt + 1;
          v_first_errored_byte := byte;
        end if;
      end loop;
    end loop;

    -- Check tuser matches exp_user_array 
    -- Check all bits in exp_user_array
    -- If the caller (Test Sequencer or VVC) don't care, set the exp_user_array length to only one 
    for word in exp_user_array'high downto 0 loop
      for i in c_num_user_bits_per_word-1 downto 0 loop              -- i = bit
        if (exp_user_array(word)(i) = '-') or  -- Expected set to don't care, or 
          (v_rx_user_array(word)(i) = exp_user_array(word)(i)) then  -- received value matches expected
          -- Check is OK
          -- log(ID_PACKET_COMPLETE, proc_call & "=> OK(word="&to_string(word)&"), checked " & to_string(v_rx_user_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_user_array(word), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
        else
          log(ID_PACKET_DATA, proc_call & "=> NOK(word="&to_string(word)&"), checked " & to_string(v_rx_user_array(word), HEX, AS_IS, INCL_RADIX) & "=" & to_string(exp_user_array(word), HEX, AS_IS, INCL_RADIX) & msg, scope, msg_id_panel);
          -- Received tuser word does not match the expected word
          v_user_error_cnt     := v_user_error_cnt + 1;
          v_first_errored_byte := word;
        end if;
      end loop;
    end loop;

    if v_data_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_data_error_cnt) & " data bits. First mismatch in byte# " & to_string(v_first_errored_byte) & ". Was " & to_string(v_rx_data_array(v_first_errored_byte), HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_data_array(v_first_errored_byte), HEX, AS_IS, INCL_RADIX) & "." & LF & msg, scope);
    elsif v_user_error_cnt /= 0 then
      alert(alert_level, proc_call & "=> Failed in "& to_string(v_user_error_cnt) & " tuser bits. First mismatch in word# " & to_string(v_first_errored_byte) & ". Was " & to_string(v_rx_user_array(v_first_errored_byte), HEX, AS_IS, INCL_RADIX) & ". Expected " & to_string(exp_user_array(v_first_errored_byte), HEX, AS_IS, INCL_RADIX) & "." & LF & msg, scope);
    else
      log(config.id_for_bfm, proc_call & "=> OK, received " & to_string(v_rx_data_array'length) & "B. " & msg, scope, msg_id_panel);
    end if;

  end procedure axistream_expect;

  -- Overload without 'exp_user_array' argument
  procedure axistream_expect (
    constant exp_data_array : in    t_slv8_array;  -- Expected data
    constant alert_level    : in    t_alert_level          := error;
    constant msg            : in    string                 := "";
    signal   clk            : in    std_logic;
    signal   axistream_if   : inout t_axistream_if;
    constant scope          : in    string                 := C_SCOPE;
    constant msg_id_panel   : in    t_msg_id_panel         := shared_msg_id_panel;
    constant config         : in    t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT
    ) is 
    -- Helper variables
    variable v_exp_user_array : t_user_array(0 to 0) := (others => (others => '-'));  -- Default value: don't care
  begin

    axistream_expect(exp_data_array,
                     v_exp_user_array,
                     alert_level,
                     msg,
                     clk,
                     axistream_if,
                     scope,
                     msg_id_panel,
                     config); 

  end procedure;
end package body axistream_bfm_pkg;

