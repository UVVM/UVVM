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
  constant C_PREAMBLE          : std_logic_vector(55 downto 0) := x"55_55_55_55_55_55_55";
  constant C_SFD               : std_logic_vector( 7 downto 0) := x"D5";
  constant C_CRC_32_RESIDUE    : std_logic_vector(31 downto 0) := x"C704DD7B";
  constant C_CRC_32_POLYNOMIAL : std_logic_vector(32 downto 0) := (32|26|23|22|16|12|11|10|8|7|5|4|2|1|0 => '1', others => '0');

  constant C_MIN_PAYLOAD_LENGTH : natural := 46;
  constant C_MAX_PAYLOAD_LENGTH : natural := 1500;
  constant C_MAX_FRAME_LENGTH   : natural := C_MAX_PAYLOAD_LENGTH + 18;
  constant C_MAX_PACKET_LENGTH  : natural := C_MAX_FRAME_LENGTH + 8;

  -- IF field index config
  constant C_ETHERNET_FIELD_IDX_PREAMBLE_SFD    : natural := 0;
  constant C_ETHERNET_FIELD_IDX_MAC_DESTINATION : natural := 1;
  constant C_ETHERNET_FIELD_IDX_MAC_SOURCE      : natural := 2;
  constant C_ETHERNET_FIELD_IDX_LENGTH          : natural := 3;
  constant C_ETHERNET_FIELD_IDX_PAYLOAD         : natural := 4;
  constant C_ETHERNET_FIELD_IDX_FCS             : natural := 5;

  type t_ethernet_frame is record
    mac_destination : unsigned(47 downto 0);
    mac_source      : unsigned(47 downto 0);
    length          : integer;
    payload         : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH-1);
    fcs             : std_logic_vector(31 downto 0);
  end record t_ethernet_frame;

  constant C_ETHERNET_FRAME_DEFAULT : t_ethernet_frame := (
    mac_destination => (others => '0'),
    mac_source      => (others => '0'),
    length          => 0,
    payload         => (others => (others => '0')),
    fcs             => (others => '0'));

  type t_ethernet_frame_status is record
    fcs_error : boolean;
  end record t_ethernet_frame_status;

  -- Configuration record to be assigned in the test harness.
  type t_ethernet_protocol_config is record
    mac_destination      : unsigned(47 downto 0);
    mac_source           : unsigned(47 downto 0);
    fcs_error_severity   : t_alert_level;
    interpacket_gap_time : time;
  end record;

  constant C_ETHERNET_PROTOCOL_CONFIG_DEFAULT : t_ethernet_protocol_config := (
    mac_destination      => (others => 'Z'),
    mac_source           => (others => 'Z'),
    fcs_error_severity   => ERROR,
    interpacket_gap_time => 96 ns -- Standard minimum interpacket gap (Gigabith Ethernet)
  );


  --========================================================================================================================
  -- Functions and procedures
  --========================================================================================================================
  impure function generate_crc_32_complete(
    constant data : in t_byte_array
  ) return std_logic_vector;

  impure function check_crc_32(
    constant data : in t_byte_array
  ) return boolean;

  function get_ethernet_frame_length(
    constant payload_length : in positive
  ) return positive;

  function hdr_to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string;

  function data_to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string;

  function complete_to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string;

  function to_slv(
    constant byte_array : in t_byte_array
  ) return std_logic_vector;

  function to_byte_array(
    constant data : in std_logic_vector
  ) return t_byte_array;

  procedure compare_ethernet_frames(
    constant actual       : in t_ethernet_frame;
    constant expected     : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant proc_call    : in string
  );

  impure function compare_ethernet_frames(
    constant actual       : in t_ethernet_frame;
    constant expected     : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant proc_call    : in string
  ) return boolean;

  function ethernet_match(
    constant actual   : in t_ethernet_frame;
    constant expected : in t_ethernet_frame
  ) return boolean;

end package support_pkg;


--========================================================================================================================
--========================================================================================================================

package body support_pkg is

  ---------------------------------------------------------------------------------
  -- generate_crc_32
  ---------------------------------------------------------------------------------
  --
  -- This function generate the IEEE 802.3 CRC32 for byte array input.
  --
  ---------------------------------------------------------------------------------
  impure function generate_crc_32_complete(
    constant data : in t_byte_array
  ) return std_logic_vector is
  begin
    return generate_crc(data, C_CRC_32_START_VALUE, C_CRC_32_POLYNOMIAL);
  end function generate_crc_32_complete;

  impure function check_crc_32(
    constant data : in t_byte_array
  ) return boolean is
  begin
    return generate_crc_32_complete(data) = C_CRC_32_RESIDUE;
  end function check_crc_32;

  function get_ethernet_frame_length(
    constant payload_length : in positive
  ) return positive is
  begin
    return payload_length + 18;
  end function get_ethernet_frame_length;

  function hdr_to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string is
  begin
    return LF & "    MAC destination: " & to_string(ethernet_frame.mac_destination, HEX, KEEP_LEADING_0, INCL_RADIX) & ";" &
           LF & "    MAC source:      " & to_string(ethernet_frame.mac_source, HEX, KEEP_LEADING_0, INCL_RADIX) & ";" &
           LF & "    length:          " & to_string(ethernet_frame.length);
  end function hdr_to_string;

  function data_to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string is
    variable payload_string : string(1 to 21*ethernet_frame.length); --byte 1500: x"00"
  begin
    for i in 0 to ethernet_frame.length-1 loop
      payload_string(i*21+1 to (i+1)*21) := LF & "    byte " & to_string(i, 4, RIGHT) & ": " & to_string(ethernet_frame.payload(i), HEX, AS_IS, INCL_RADIX);
    end loop;
    return LF & "    Payload:" & payload_string;
  end function data_to_string;

  function complete_to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string is
  begin
    return "MAC dest: "  & to_string(ethernet_frame.mac_destination, HEX, AS_IS, INCL_RADIX) &
           "; MAC src: " & to_string(ethernet_frame.mac_source, HEX, AS_IS, INCL_RADIX) &
           "; length: "  & to_string(ethernet_frame.length) &
           "; fcs: "     & to_string(ethernet_frame.fcs, HEX, AS_IS, INCL_RADIX);
  end function complete_to_string;

  function to_slv(
    constant byte_array : in t_byte_array
  ) return std_logic_vector is
    constant C_NUM_BYTES           : integer := byte_array'length;
    variable normalized_byte_array : t_byte_array(0 to C_NUM_BYTES-1) ;
    variable v_return_val          : std_logic_vector(8*C_NUM_BYTES-1 downto 0);
  begin
    normalized_byte_array := byte_array;
    for i in 0 to C_NUM_BYTES-1 loop
      v_return_val(8*(C_NUM_BYTES-i)-1 downto 8*(C_NUM_BYTES-i-1)) := normalized_byte_array(i);
    end loop;
    return v_return_val;
  end function to_slv;

  function get_num_bytes(
    constant num_bits : in positive
  ) return positive is
    variable v_num_bytes : positive;
  begin
    v_num_bytes := num_bits/8;
    if (num_bits rem 8) /= 0 then
      v_num_bytes := v_num_bytes+1;
    end if;
    return v_num_bytes;
  end function get_num_bytes;

  function to_byte_array(
    constant data : in std_logic_vector
  ) return t_byte_array is
    alias    normalized_data : std_logic_vector(data'length-1 downto 0) is data;
    constant C_NUM_BYTES     : positive := get_num_bytes(data'length);
    variable v_byte_array    : t_byte_array(0 to C_NUM_BYTES-1);
    variable v_bit_idx       : integer := normalized_data'high;
  begin
    for byte_idx in 0 to C_NUM_BYTES-1 loop
      for i in 7 downto 0 loop
        if v_bit_idx = -1 then
          v_byte_array(byte_idx)(i) := 'Z'; -- Pads 'Z'
        else
          v_byte_array(byte_idx)(i) := normalized_data(v_bit_idx);
          v_bit_idx := v_bit_idx-1;
        end if;
      end loop;
    end loop;
    return v_byte_array;
  end function to_byte_array;

  procedure compare_ethernet_frames(
    constant actual       : in t_ethernet_frame;
    constant expected     : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant proc_call    : in string
  ) is
  begin
    check_value(actual.mac_destination, expected.mac_destination, alert_level, "Verify MAC destination"              & LF & msg, scope, HEX, KEEP_LEADING_0, ID_PACKET_HDR,  msg_id_panel, proc_call);
    check_value(actual.mac_source,      expected.mac_source,      alert_level, "Verify MAC source"                   & LF & msg, scope, HEX, KEEP_LEADING_0, ID_PACKET_HDR,  msg_id_panel, proc_call);
    check_value(actual.length,          expected.length,          alert_level, "Verify length"                       & LF & msg, scope,                      ID_PACKET_HDR,  msg_id_panel, proc_call);
    for i in 0 to actual.length-1 loop
      check_value(actual.payload(i),    expected.payload(i),      alert_level, "Verify payload byte " & to_string(i) & LF & msg, scope, HEX, KEEP_LEADING_0, ID_PACKET_DATA, msg_id_panel, proc_call);
    end loop;
    check_value(actual.fcs,             expected.fcs,             alert_level, "Verify FCS"                          & LF & msg, scope, HEX, KEEP_LEADING_0, ID_PACKET_DATA, msg_id_panel, proc_call);
  end procedure compare_ethernet_frames;

  impure function compare_ethernet_frames(
    constant actual       : in t_ethernet_frame;
    constant expected     : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant msg          : in string;
    constant scope        : in string;
    constant msg_id_panel : in t_msg_id_panel;
    constant proc_call    : in string
  ) return boolean is
  begin
    if not check_value(actual.mac_destination, expected.mac_destination, alert_level, "Verify MAC destination" & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call) then
      return false;
    end if;
    if not check_value(actual.mac_source, expected.mac_source, alert_level, "Verify MAC source" & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call) then
      return false;
    end if;
    if not check_value(actual.length, expected.length, alert_level, "Verify length" & LF & msg, scope, ID_NEVER, msg_id_panel, proc_call) then
      return false;
    end if;
    for i in 0 to actual.length-1 loop
      if not check_value(actual.payload(i), expected.payload(i), alert_level, "Verify payload byte " & to_string(i) & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call) then
        return false;
      end if;
    end loop;
    if not check_value(actual.fcs, expected.fcs, alert_level, "Verify FCS" & LF & msg, scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel, proc_call) then
      return false;
    end if;
    return true;
  end function compare_ethernet_frames;

  function ethernet_match(
    constant actual   : in t_ethernet_frame;
    constant expected : in t_ethernet_frame
  ) return boolean is
  begin
    return actual.mac_destination               = expected.mac_destination                 and
           actual.mac_source                    = expected.mac_source                      and
           actual.length                        = expected.length                          and
           actual.payload(0 to actual.length-1) = expected.payload(0 to expected.length-1) and
           actual.fcs                           = expected.fcs;
  end function ethernet_match;

end package body support_pkg;