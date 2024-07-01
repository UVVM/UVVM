--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--========================================================================================================================
--========================================================================================================================
package support_pkg is

  --========================================================================================================================
  -- Types and constants
  --========================================================================================================================
  -- The preamble & SFD sequence is represented with the LSb transmitted first
  constant C_PREAMBLE : std_logic_vector(55 downto 0) := x"55_55_55_55_55_55_55";
  constant C_SFD      : std_logic_vector(7 downto 0)  := x"D5";

  -- Sizes in bytes
  constant C_MIN_PAYLOAD_LENGTH : natural := 46;
  constant C_MAX_PAYLOAD_LENGTH : natural := 1500;
  constant C_MAX_FRAME_LENGTH   : natural := C_MAX_PAYLOAD_LENGTH + 18;
  constant C_MAX_PACKET_LENGTH  : natural := C_MAX_FRAME_LENGTH + 8;

  -- IF field index config
  constant C_FIELD_IDX_PREAMBLE_AND_SFD : natural := 0;
  constant C_FIELD_IDX_MAC_DESTINATION  : natural := 1;
  constant C_FIELD_IDX_MAC_SOURCE       : natural := 2;
  constant C_FIELD_IDX_PAYLOAD_LENGTH   : natural := 3;
  constant C_FIELD_IDX_PAYLOAD          : natural := 4;
  constant C_FIELD_IDX_FCS              : natural := 5;

  type t_ethernet_frame is record
    mac_destination : unsigned(47 downto 0);
    mac_source      : unsigned(47 downto 0);
    payload_length  : integer;
    payload         : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH - 1);
    fcs             : std_logic_vector(31 downto 0);
  end record t_ethernet_frame;

  constant C_ETHERNET_FRAME_DEFAULT : t_ethernet_frame := (
    mac_destination => (others => '0'),
    mac_source      => (others => '0'),
    payload_length  => 0,
    payload         => (others => (others => '0')),
    fcs             => (others => '0'));

  type t_ethernet_frame_status is record
    fcs_error : boolean;
  end record t_ethernet_frame_status;

  -- Configuration record to be assigned in the test harness
  type t_ethernet_protocol_config is record
    mac_destination      : unsigned(47 downto 0);
    mac_source           : unsigned(47 downto 0);
    fcs_error_severity   : t_alert_level;
    interpacket_gap_time : time;
  end record;

  constant C_ETHERNET_PROTOCOL_CONFIG_DEFAULT : t_ethernet_protocol_config := (
    mac_destination      => (others => '0'),
    mac_source           => (others => '0'),
    fcs_error_severity   => ERROR,
    interpacket_gap_time => 96 ns       -- Standard minimum interpacket gap (Gigabith Ethernet)
  );

  --========================================================================================================================
  -- Functions and procedures
  --========================================================================================================================
  impure function generate_crc_32(
    constant data_array : in t_byte_array
  ) return std_logic_vector;

  impure function check_crc_32(
    constant data_array : in t_byte_array
  ) return boolean;

  function get_ethernet_frame_length(
    constant payload_length : in positive
  ) return positive;

  function to_string(
    constant ethernet_frame : in t_ethernet_frame;
    constant frame_field    : in t_frame_field
  ) return string;

  function to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string;

  procedure compare_ethernet_frames(
    constant actual       : in t_ethernet_frame;
    constant expected     : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant msg_id       : in t_msg_id;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel
  );

  function ethernet_match(
    constant actual   : in t_ethernet_frame;
    constant expected : in t_ethernet_frame
  ) return boolean;

end package support_pkg;

--========================================================================================================================
--========================================================================================================================

package body support_pkg is

  -- Returns the IEEE 802.3 CRC32 for an ascending byte array input with LSb first.
  impure function generate_crc_32(
    constant data_array : in t_byte_array
  ) return std_logic_vector is
  begin
    -- The function generate_crc() generates CRC from high to low (MSb first),
    -- however the Ethernet standard uses LSb first for the frame data so we need
    -- to reverse the bits in each byte.
    return generate_crc(reverse_vectors_in_array(data_array), C_CRC_32_START_VALUE, C_CRC_32_POLYNOMIAL);
  end function generate_crc_32;

  -- Generates the IEEE 802.3 CRC32 for an ascending byte array containing
  -- the frame data and the FCS. Returns true if the result is equal to the
  -- expected residue.
  impure function check_crc_32(
    constant data_array : in t_byte_array
  ) return boolean is
  begin
    return generate_crc_32(data_array) = C_CRC_32_RESIDUE;
  end function check_crc_32;

  -- Returns the complete frame length
  function get_ethernet_frame_length(
    constant payload_length : in positive
  ) return positive is
  begin
    return payload_length + 18;
  end function get_ethernet_frame_length;

  -- Returns a string with a specific field from the frame
  function to_string(
    constant ethernet_frame : in t_ethernet_frame;
    constant frame_field    : in t_frame_field
  ) return string is
    variable payload_string : string(1 to 14 * ethernet_frame.payload_length); --[1500]:x"00",
    variable v_line         : line;
    variable v_line_width   : natural;
  begin
    case frame_field is
      when HEADER =>
        return LF & "    MAC destination: " & to_string(ethernet_frame.mac_destination, HEX, KEEP_LEADING_0, INCL_RADIX) &
               LF & "    MAC source:      " & to_string(ethernet_frame.mac_source, HEX, KEEP_LEADING_0, INCL_RADIX) &
               LF & "    payload length:  " & to_string(ethernet_frame.payload_length);

      when PAYLOAD =>
        write(v_line, string'("[" & to_string(0) & "]:" & to_string(ethernet_frame.payload(0), HEX, AS_IS, INCL_RADIX)));
        if ethernet_frame.payload_length > 1 then
          for i in 1 to ethernet_frame.payload_length - 1 loop
            write(v_line, string'(", [" & to_string(i) & "]:" & to_string(ethernet_frame.payload(i), HEX, AS_IS, INCL_RADIX)));
          end loop;
        end if;
        v_line_width                      := v_line'length;
        payload_string(1 to v_line_width) := v_line.all;
        deallocate(v_line);
        return LF & payload_string(1 to v_line_width);

      when CHECKSUM =>
        return LF & "    FCS: " & to_string(ethernet_frame.fcs, HEX, AS_IS, INCL_RADIX);

      when others =>
        return "";
    end case;
  end function to_string;

  -- Returns a string with the main frame info (used in scoreboard)
  function to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string is
  begin
    return "MAC dest: " & to_string(ethernet_frame.mac_destination, HEX, AS_IS, INCL_RADIX) &
           ", MAC src: " & to_string(ethernet_frame.mac_source, HEX, AS_IS, INCL_RADIX) &
           ", payload length: " & to_string(ethernet_frame.payload_length);
  end function to_string;

  -- Compares two ethernet frames
  procedure compare_ethernet_frames(
    constant actual       : in t_ethernet_frame;
    constant expected     : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant msg_id       : in t_msg_id;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel
  ) is
    constant proc_call  : string  := "compare_ethernet_frames()";
    variable v_check_ok : boolean := true;
  begin
    v_check_ok := v_check_ok and check_value(actual.mac_destination, expected.mac_destination, alert_level, "Verify MAC destination" & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
    v_check_ok := v_check_ok and check_value(actual.mac_source, expected.mac_source, alert_level, "Verify MAC source" & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
    v_check_ok := v_check_ok and check_value(actual.payload_length, expected.payload_length, alert_level, "Verify payload length" & LF & msg, scope, ID_NEVER, msg_id_panel, proc_call);
    for i in 0 to actual.payload_length - 1 loop
      v_check_ok := v_check_ok and check_value(actual.payload(i), expected.payload(i), alert_level, "Verify payload byte " & to_string(i) & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);
    end loop;
    v_check_ok := v_check_ok and check_value(actual.fcs, expected.fcs, alert_level, "Verify FCS" & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call);

    if v_check_ok then
      log(msg_id, proc_call & ". " & add_msg_delimiter(msg) & " => OK");
    else
      log(msg_id, proc_call & ". " & add_msg_delimiter(msg) & " => FAILED");
    end if;
  end procedure compare_ethernet_frames;

  -- Compares two ethernet frames and returns true if they are equal (used in scoreboard)
  function ethernet_match(
    constant actual   : in t_ethernet_frame;
    constant expected : in t_ethernet_frame
  ) return boolean is
  begin
    return actual.mac_destination = expected.mac_destination and
           actual.mac_source = expected.mac_source and
           actual.payload_length = expected.payload_length and
           actual.payload(0 to actual.payload_length - 1) = expected.payload(0 to expected.payload_length - 1) and
           actual.fcs = expected.fcs;
  end function ethernet_match;

end package body support_pkg;
