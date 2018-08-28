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
-- VHDL unit     : Bitvis VIP GMII Library : gmii_bfm_pkg
--
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


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
package gmii_bfm_pkg is

  ----------------------------------------------------
  -- Types for GMII BFMs
  ----------------------------------------------------
  constant C_SCOPE           : string := "GMII BFM";

  -- Configuration record to be assigned in the test harness.
  type t_gmii_config is
  record
    clock_period                : time;           -- Period of the clock signal.
    clock_period_margin         : time;           -- Input clock period margin to specified clock_period
    clock_margin_severity       : t_alert_level;  -- The above margin will have this severity
    setup_time                  : time;           -- Setup time for generated signals, set to clock_period/4
    hold_time                   : time;           -- Hold time for generated signals, set to clock_period/4
    max_wait_cycles             : integer;        -- max number of cycles to wait (for read or check)
    max_wait_cycles_severity    : t_alert_level;  -- severity if max_wait_cycles expires
    received_too_much_severity  : t_alert_level;  -- severity if receive more than expected
  end record;

  constant C_GMII_CONFIG_DEFAULT : t_gmii_config := (
    clock_period                => 8 ns,
    clock_period_margin         => 0 ns,
    clock_margin_severity       => TB_ERROR,
    setup_time                  => 2 ns,
    hold_time                   => 2 ns,
    max_wait_cycles             => 10,
    max_wait_cycles_severity    => ERROR,
    received_too_much_severity  => ERROR
    );

  type t_eth_frame_config is
  record
    preamble         : std_logic_vector(7 downto 0);
    preamble_len     : natural;
    start_of_frame   : std_logic_vector(7 downto 0);
    dest_addr        : std_logic_vector(47 downto 0); -- sent MSB first
    source_addr      : std_logic_vector(47 downto 0); -- sent MSB first
    insert_vlan1     : boolean; -- insert inner vlan type
    vlan_type1       : std_logic_vector(15 downto 0); -- inner vlan type (close
                                                      -- to payload)
    vlan_setting1    : std_logic_vector(15 downto 0); -- pri and vlan entry
    insert_vlan2     : boolean; -- insert outer vlan type
    vlan_type2       : std_logic_vector(15 downto 0); -- outer vlan type
    vlan_setting2    : std_logic_vector(15 downto 0); -- pri and vlan entry
    len_field_is_len : boolean; -- 802.3 or other content
    ether_type       : std_logic_vector(15 downto 0); -- if len_field_is_len is
                                                      -- false, set ether_type
                                                      -- to this value;
                                                      -- indicating what the
                                                      -- payload content is
  end record;

  constant C_ETH_FRAME_CONFIG_DEFAULT : t_eth_frame_config := (
    preamble         => x"55",
    preamble_len     => 7,
    start_of_frame   => x"D5",
    dest_addr        => x"777788889999", -- sent MSB first
    source_addr      => x"111122223333", -- sent MSB first
    insert_vlan1     => false,
    vlan_type1       => x"8100", -- sent MSB first
    vlan_setting1    => x"0001", -- sent MSB first
    insert_vlan2     => false,
    vlan_type2       => x"88a8", -- sent MSB first
    vlan_setting2    => x"0001", -- sent MSB first
    len_field_is_len => true,
    ether_type       => x"0800"
    );

  -- Gmii Interface signals
  type t_gmii_to_dut is record
    reset      : std_logic;
    reset_n    : std_logic;
    -- Gmii bus signals (both tx and rx)
    valid      : std_logic;
    data_err   : std_logic;
    data       : std_logic_vector(7 downto 0);
  end record;

  type t_gmii_from_dut is record
    -- Gmii bus signals (both tx and rx)
    valid      : std_logic;
    data_err   : std_logic;
    data       : std_logic_vector(7 downto 0);
  end record;

  constant C_GMII_TO_DUT_PASSIVE : t_gmii_to_dut := (
    reset         => 'L',
    reset_n       => 'H',
    valid         => 'L',
    data_err      => 'L',
    data          => (others => 'L')
    );

  ----------------------------------------------------
  -- BFM procedures
  ----------------------------------------------------

  -- This procedure could be called from an a simple testbench or
  -- from an executor where there are concurrent BFMs - where
  -- all BFMs could have different configs and msg_id_panels
  -- From a simple testbench, just don't touch the defaults for
  -- the fields that are not needed. e.g.:
  -- gmii_write(my_gmii_if, data);
  procedure gmii_write (
    signal clk : std_logic;
    signal gmii_to_dut : out t_gmii_to_dut;
    signal gmii_from_dut : in t_gmii_from_dut;
    eth_cfg           : in t_eth_frame_config; -- eth frame config
    payload           : in std_logic_vector;   -- eth payload
    payload_size      : in natural;            -- determines how much is sent
    gmii_config       : in t_gmii_config := C_GMII_CONFIG_DEFAULT;
    constant msg      : in string := "";
    constant msg_id_panel  : in t_msg_id_panel  := shared_msg_id_panel;
    constant scope    : in string := C_SCOPE
    );

  procedure gmii_read (
    signal clk : std_logic;
    signal gmii_to_dut : out t_gmii_to_dut;
    signal gmii_from_dut : in t_gmii_from_dut;
    eth_cfg           : in t_eth_frame_config; -- eth frame config
    payload           : out std_logic_vector;  -- eth payload
    payload_size      : in natural;            -- determines how much to rcv
    gmii_config       : in t_gmii_config := C_GMII_CONFIG_DEFAULT;
    constant msg      : in string := "";
    constant msg_id_panel  : in t_msg_id_panel  := shared_msg_id_panel;
    constant scope    : in string := C_SCOPE
    );

  procedure gmii_check (
    signal clk : std_logic;
    signal gmii_to_dut : out t_gmii_to_dut;
    signal gmii_from_dut : in t_gmii_from_dut;
    eth_cfg           : in t_eth_frame_config; -- eth frame config
    payload           : in std_logic_vector;   -- eth payload
    payload_size      : in natural;            -- determines how much to check
    gmii_config       : in t_gmii_config := C_GMII_CONFIG_DEFAULT;
    constant msg      : in string := "";
    constant msg_id_panel  : in t_msg_id_panel  := shared_msg_id_panel;
    constant scope    : in string := C_SCOPE
    );

  procedure gmii_reset (
    signal clk : std_logic;
    signal gmii_to_dut : out t_gmii_to_dut;
    num_rst_cycles    : in integer;
    gmii_config       : in t_gmii_config := C_GMII_CONFIG_DEFAULT
    );

end package gmii_bfm_pkg;


--=================================================================================================
--=================================================================================================

package body gmii_bfm_pkg is

  procedure gmii_write (
    signal clk : std_logic;
    signal gmii_to_dut    : out t_gmii_to_dut;
    signal gmii_from_dut  : in t_gmii_from_dut;
    eth_cfg               : in t_eth_frame_config; -- eth frame config
    payload               : in std_logic_vector;   -- eth payload
    payload_size          : in natural;            -- determines how much is sent
    gmii_config           : in t_gmii_config := C_GMII_CONFIG_DEFAULT;
    constant msg          : in string := "";
    constant msg_id_panel : in t_msg_id_panel  := shared_msg_id_panel;
    constant scope        : in string := C_SCOPE
    ) is
    variable cycle                : integer := 0;
    variable timeout              : boolean := false;
    variable v_last_rising_edge  : time    := -1 ns;  -- time stamp for clk period checking
    variable sent_header          : boolean := false;
    variable finished             : boolean := false;
    variable sent_so_far          : natural := 0; -- # of bits sent
    -- Normalise to the DUT payload widths
    variable v_normalized_payload : std_logic_vector(payload_size*8-1 downto 0) := payload(payload_size*8-1 downto 0);
    constant name                 : string:= "gmii_write (size = " & to_string(payload_size,1) & ")\n" &
                                              to_string(v_normalized_payload, HEX, AS_IS, INCL_RADIX);
    variable payload_length       : std_logic_vector(15 downto 0);
    variable header_length        : natural := 0; -- # of bytes
    variable header_bits_sent     : natural := 0; -- # of header bits sent
    -- max buffer size
    variable header_buffer : std_logic_vector((eth_cfg.preamble_len+1+12+8+2)*8 downto 0);
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, name);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, name);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, name);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, name);

    gmii_to_dut <= C_GMII_TO_DUT_PASSIVE;

    -- check if enough room for setup_time in high period
    if (clk = '1') and (config.setup_time > (config.clock_period/2 - clk'last_event))then
      await_value(clk, '0', 0 ns, config.clock_period/2, TB_FAILURE, proc_name & ": timeout waiting for clk high period for setup_time.");
    end if;
    -- Wait setup_time specified in config record
    wait_until_given_time_after_rising_edge(clk, gmii_config.setup_time, gmii_config.clock_period);
    --wait_until_given_time_after_rising_edge(clk, gmii_config.clock_period/4);

    -- TODO - should we check for RUNT (less than 64 bytes total) ??
    -- build the header buffer
    -- TODO - add FCS support
    header_length := 2;
    if (eth_cfg.len_field_is_len) then
      payload_length := std_logic_vector(to_unsigned(payload_size,16));
      header_buffer(15 downto 0) := payload_length;
    else
      header_buffer(15 downto 0) := eth_cfg.ether_type;
    end if;
    if eth_cfg.insert_vlan1 then
      header_buffer(header_length*8 + 31 downto header_length*8) := eth_cfg.vlan_type1 & eth_cfg.vlan_setting1;
      header_length := header_length + 4;
    end if;
    if eth_cfg.insert_vlan2 then
      header_buffer(header_length*8 + 31 downto header_length*8) := eth_cfg.vlan_type2 & eth_cfg.vlan_setting2;
      header_length := header_length + 4;
    end if;
    header_buffer(header_length*8 + 47 downto header_length*8) := eth_cfg.source_addr;
    header_length := header_length + 6;
    header_buffer(header_length*8 + 47 downto header_length*8) := eth_cfg.dest_addr;
    header_length := header_length + 6;
    header_buffer(header_length*8 + 7 downto header_length*8) := eth_cfg.start_of_frame;
    header_length := header_length + 1;
    for i in 0 to (eth_cfg.preamble_len-1) loop
      header_buffer(header_length*8 + 7 downto header_length*8) := eth_cfg.preamble;
      header_length := header_length + 1;
    end loop;

    while (not finished) loop
      -- send IPG, addresses etc first
      gmii_to_dut.valid  <= '1';
      if (not sent_header) then
        gmii_to_dut.data(7 downto 0) <= header_buffer(header_length*8-1 - header_bits_sent downto
                                               (header_length-1)*8 - header_bits_sent);
        header_bits_sent := header_bits_sent + 8;
      elsif (cycle = 0) then
        gmii_to_dut.data(7 downto 0) <=
          v_normalized_payload(v_normalized_payload'left downto
                            v_normalized_payload'left-7);
        if (v_normalized_payload'length <= 8) then
          finished     := true;
        end if;
      elsif (sent_so_far + 8 < v_normalized_payload'length) then
        -- middle packet - not last yet
        gmii_to_dut.data(7 downto 0) <=
          v_normalized_payload(v_normalized_payload'length-1 - sent_so_far downto
                            v_normalized_payload'length-1 - sent_so_far - 7);
      else
        -- last packet
        finished     := true;
        gmii_to_dut.data(7 downto (8 - (v_normalized_payload'length-sent_so_far))) <=
          v_normalized_payload(v_normalized_payload'length-1 - sent_so_far downto v_normalized_payload'right);
      end if;
      if (sent_header) then
        cycle := cycle + 1;
        sent_so_far := sent_so_far + 8;
      end if;

      if (header_bits_sent = header_length * 8) then
        -- done sending the header
        sent_header := true;
      end if;

      wait until rising_edge(clk);
      -- check if clk period since last rising edge is within specifications and take a new time stamp
      if v_last_rising_edge > -1 ns then
        check_value_in_range(now - v_last_rising_edge, gmii_config.clock_period - gmii_config.clock_period_margin, gmii_config.clock_period + gmii_config.clock_period_margin, gmii_config.clock_margin_severity, "clk period not within requirement.");
      end if;
      v_last_rising_edge := now; -- time stamp for clk period checking

      -- Wait hold time specified in config record
      wait_until_given_time_after_rising_edge(clk, gmii_config.hold_time);
      --wait_until_given_time_after_rising_edge(clk, gmii_config.clock_period/4);
    end loop;

    gmii_to_dut <= C_GMII_TO_DUT_PASSIVE;
    log(ID_BFM, "gmii write : DA = " & to_string(eth_cfg.dest_addr, HEX) & ", SA = " & to_string(eth_cfg.source_addr,HEX) & add_msg_delimiter(msg), scope, msg_id_panel);
    if (eth_cfg.insert_vlan2) then
    log(ID_BFM, "gmii write : VLAN2 type = " & to_string(eth_cfg.vlan_type2, HEX) & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;
    if (eth_cfg.insert_vlan1) then
    log(ID_BFM, "gmii write : VLAN1 type = " & to_string(eth_cfg.vlan_type1, HEX) & add_msg_delimiter(msg), scope, msg_id_panel);
    end if;

    log(ID_BFM, name & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);

  end procedure gmii_write;

  procedure gmii_read (
    signal clk            : std_logic;
    signal gmii_to_dut    : out t_gmii_to_dut;
    signal gmii_from_dut  : in t_gmii_from_dut;
    eth_cfg               : in t_eth_frame_config; -- eth frame config
    payload               : out std_logic_vector;  -- eth payload
    payload_size          : in natural;            -- determines how much is sent
    gmii_config           : in t_gmii_config := C_GMII_CONFIG_DEFAULT;
    constant msg          : in string := "";
    constant msg_id_panel : in t_msg_id_panel  := shared_msg_id_panel;
    constant scope        : in string := C_SCOPE
    ) is
    constant name                 : string:= "gmii_read"
    variable timeout              : boolean := false;
    variable v_last_rising_edge  : time    := -1 ns;  -- time stamp for clk period checking
    variable finished             : boolean := false;
    variable received_header      : boolean := false;
    variable header_bits_rcvd     : natural := 0; -- # of header bits received
    variable header_length        : natural := 0; -- # of bytes
    variable payload_length       : std_logic_vector(15 downto 0);
    variable received_so_far      : natural := 0; -- # of bits received
    variable received_sfd         : boolean := false; -- received start of frame delimiter
    variable invalid_count        : integer := 0; -- # cycles without valid being asserted
    -- max buffer size
    variable header_buffer : std_logic_vector((12+8+2)*8 downto 0);
    -- Normalise to the DUT payload widths
    variable v_normalized_payload : std_logic_vector(payload_size*8-1 downto 0) := payload(payload_size*8-1 downto 0);
  begin
    -- setup_time and hold_time checking
    check_value(config.setup_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that setup_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, name);
    check_value(config.hold_time < config.clock_period/2, TB_FAILURE, "Sanity check: Check that hold_time do not exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, name);
    check_value(config.setup_time > 0 ns, TB_FAILURE, "Sanity check: Check that setup_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, name);
    check_value(config.hold_time > 0 ns, TB_FAILURE, "Sanity check: Check that hold_time is more than 0 ns.", scope, ID_NEVER, msg_id_panel, name);

    gmii_to_dut <= C_GMII_TO_DUT_PASSIVE;

    -- check if enough room for setup_time in high period
    if (clk = '1') and (config.setup_time > (config.clock_period/2 - clk'last_event))then
      await_value(clk, '0', 0 ns, config.clock_period/2, TB_FAILURE, proc_name & ": timeout waiting for clk high period for setup_time.");
    end if;
    -- Wait setup_time specified in config record
    wait_until_given_time_after_rising_edge(clk, gmii_config.setup_time, gmii_config.clock_period);
    --wait_until_given_time_after_rising_edge(clk, gmii_config.clock_period/4);

    -- start the read
    --log(ID_BFM, "Reading GMII " & add_msg_delimiter(msg), scope, msg_id_panel);

    -- build the header buffer
    header_length := 2;
    if (eth_cfg.len_field_is_len) then
      payload_length := std_logic_vector(to_unsigned(payload_size,16));
      header_buffer(15 downto 0) := payload_length;
    else
      header_buffer(15 downto 0) := eth_cfg.ether_type;
    end if;
    if eth_cfg.insert_vlan1 then
      header_buffer(header_length*8 + 31 downto header_length*8) := eth_cfg.vlan_type1 & eth_cfg.vlan_setting1;
      header_length := header_length + 4;
    end if;
    if eth_cfg.insert_vlan2 then
      header_buffer(header_length*8 + 31 downto header_length*8) := eth_cfg.vlan_type2 & eth_cfg.vlan_setting2;
      header_length := header_length + 4;
    end if;
    header_buffer(header_length*8 + 47 downto header_length*8) := eth_cfg.source_addr;
    header_length := header_length + 6;
    header_buffer(header_length*8 + 47 downto header_length*8) := eth_cfg.dest_addr;
    header_length := header_length + 6;

    -- TODO - what if payload_size is set to 0 - still check header?
    while (not finished) loop
      wait until rising_edge(clk);
      -- check if clk period since last rising edge is within specifications and take a new time stamp
      if v_last_rising_edge > -1 ns then
        check_value_in_range(now - v_last_rising_edge, gmii_config.clock_period - gmii_config.clock_period_margin, gmii_config.clock_period + gmii_config.clock_period_margin, gmii_config.clock_margin_severity, "clk period not within requirement.");
      end if;
      v_last_rising_edge := now; -- time stamp for clk period checking

      -- Wait setup_time specified in config record
      wait_until_given_time_after_rising_edge(clk, gmii_config.setup_time, gmii_config.clock_period);
      --wait_until_given_time_after_rising_edge(clk, gmii_config.clock_period/4);

      if (gmii_from_dut.valid = '1') then
        invalid_count := 0;
        -- receive eth header before we get the actual payload
        if (not received_header) then
          if (not received_sfd) then -- TODO - need a timeout
            if ((gmii_from_dut.data /= eth_cfg.preamble) and
                (gmii_from_dut.data /= eth_cfg.start_of_frame)) then
              alert(ERROR, "gmii_read() Incorrect preamble/SFD : " & to_string(gmii_from_dut.data, HEX) & add_msg_delimiter(msg), scope);
            end if;
            if (gmii_from_dut.data = eth_cfg.start_of_frame) then
              received_sfd := true;
            end if;
          else
            -- receive DA, SA etc., and check against expected header buffer
            if (gmii_from_dut.data /= header_buffer(header_length*8-1 - header_bits_rcvd downto
                                           (header_length-1)*8 - header_bits_rcvd)) then
              alert(ERROR, "gmii_read() Incorrect header. Expected : " &
                  to_string(header_buffer(header_length*8-1 - header_bits_rcvd downto
                                          (header_length-1)*8 - header_bits_rcvd), HEX) &
                " but received " & to_string(gmii_from_dut.data, HEX) & add_msg_delimiter(msg), scope);
            end if;
            header_bits_rcvd := header_bits_rcvd + 8;
            if (header_bits_rcvd = header_length * 8) then
              received_header := true;
            end if;
          end if;

        else
          -- got data
          if (v_normalized_payload'left - received_so_far) >= 7 then
            v_normalized_payload(v_normalized_payload'left - received_so_far downto
                              v_normalized_payload'left - received_so_far - 7) := gmii_from_dut.data(7 downto 0);
          end if;
          received_so_far := received_so_far + 8;
          if (received_so_far > v_normalized_payload'length) then
            log(ID_BFM, "received_so_far = " & to_string(received_so_far, 8) & ", expected " &
              to_string(v_normalized_payload'length,8) & msg, scope, msg_id_panel);
            alert(gmii_config.received_too_much_severity, "gmii_read() Received more payload than expected - timeout" & add_msg_delimiter(msg), scope);
            finished := true;
          end if;
        end if;
      else
        if (received_so_far > 0) then
          finished := true;
        end if;
        if invalid_count >= gmii_config.max_wait_cycles then
          timeout := true;
          finished := true;
        else
          invalid_count := invalid_count + 1;
        end if;
      end if;

      -- did we timeout?
      if timeout then
        alert(gmii_config.max_wait_cycles_severity, "gmii_read() timeout waiting for valid data" & add_msg_delimiter(msg), scope);
      end if;
    end loop;

    payload := v_normalized_payload;
    log(ID_BFM, "gmii_read " & " completed. " & add_msg_delimiter(msg), scope, msg_id_panel);

    wait until rising_edge(clk);
    -- check if clk period since last rising edge is within specifications and take a new time stamp
    if v_last_rising_edge > -1 ns then
      check_value_in_range(now - v_last_rising_edge, gmii_config.clock_period - gmii_config.clock_period_margin, gmii_config.clock_period + gmii_config.clock_period_margin, gmii_config.clock_margin_severity, "clk period not within requirement.");
    end if;

    -- Wait hold time specified in config record
    wait_until_given_time_after_rising_edge(clk, gmii_config.hold_time);
    --wait_until_given_time_after_rising_edge(clk, gmii_config.clock_period/4);
    gmii_to_dut <= C_GMII_TO_DUT_PASSIVE;
  end procedure gmii_read;


  procedure gmii_check (
    signal clk : std_logic;
    signal gmii_to_dut : out t_gmii_to_dut;
    signal gmii_from_dut : in t_gmii_from_dut;
    eth_cfg           : in t_eth_frame_config; -- eth frame config
    payload           : in std_logic_vector;   -- eth payload
    payload_size      : in natural;            -- determines how much is sent
    gmii_config       : in t_gmii_config := C_GMII_CONFIG_DEFAULT;
    constant msg      : in string := "";
    constant msg_id_panel : in t_msg_id_panel  := shared_msg_id_panel;
    constant scope    : in string := C_SCOPE
    ) is
    variable v_payload   : std_logic_vector(payload_size*8-1 downto 0) := (others => '0');
    variable v_normalized_payload : std_logic_vector(payload_size*8-1 downto 0) := payload(payload_size*8-1 downto 0);
    variable v_status : boolean;
  begin
    gmii_read(clk, gmii_to_dut, gmii_from_dut, eth_cfg, v_payload, payload_size, gmii_config, msg, msg_id_panel, scope);

    v_status := true;
    for i in 0 to (payload_size*8)-1 loop
      if v_normalized_payload(i) = '-' or v_normalized_payload(i) = v_payload(i) then
        v_status := true;
      else
        v_status := false;
        exit;
      end if;
    end loop;

    if not v_status then
      alert(ERROR, "gmii_check() expected/received " & to_string(v_normalized_payload,HEX, AS_IS, INCL_RADIX) & "/\n" & to_string(v_payload,HEX, AS_IS, INCL_RADIX)  & add_msg_delimiter(msg), scope);
    else
      log(ID_BFM, "gmii_check() completed successfully" & add_msg_delimiter(msg), scope, msg_id_panel);
      --log(ID_BFM, "gmii_check() expected/received " & to_string(v_normalized_payload,HEX, AS_IS, INCL_RADIX) & "/\n" & to_string(v_payload,HEX, AS_IS, INCL_RADIX) );
    end if;
  end procedure gmii_check;


  procedure gmii_reset (
    signal clk : std_logic;
    signal gmii_to_dut : out t_gmii_to_dut;
    num_rst_cycles : in integer;
    gmii_config    : in t_gmii_config := C_GMII_CONFIG_DEFAULT
    ) is
  begin
    gmii_to_dut       <= C_GMII_TO_DUT_PASSIVE;
    gmii_to_dut.reset   <= '1';
    gmii_to_dut.reset_n <= '0';
    for i in 1 to num_rst_cycles loop
      wait until rising_edge(clk);
    end loop;
    gmii_to_dut.reset   <= '0';
    gmii_to_dut.reset_n <= '1';

    wait until rising_edge(clk);
  end procedure gmii_reset;

end package body gmii_bfm_pkg;



