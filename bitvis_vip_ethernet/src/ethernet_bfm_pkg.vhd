--========================================================================================================================
-- This VVC was generated with Bitvis VVC Generator
--========================================================================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--========================================================================================================================
--========================================================================================================================
package ethernet_bfm_pkg is

  --========================================================================================================================
  -- Types and constants for ETHERNET BFM
  --========================================================================================================================
  constant C_MAX_PAYLOAD_LENGTH          : natural := 1500;
  constant C_MAX_FRAME_LENGTH            : natural := C_MAX_PAYLOAD_LENGTH + 18;
  constant C_MAX_PACKET_LENGTH           : natural := C_MAX_FRAME_LENGTH + 8;
  constant C_VVC_CMD_STRING_MAX_LENGTH   : natural := 300;

  constant C_SCOPE             : string := "ETHERNET BFM";
  constant C_PREAMBLE          : std_logic_vector(55 downto 0) := x"55_55_55_55_55_55_55";
  constant C_SFD               : std_logic_vector( 7 downto 0) := x"D5";
  constant C_CRC_32_RESIDUE    : std_logic_vector(31 downto 0) := x"C704DD7B";
  constant C_CRC_32_POLYNOMIAL : std_logic_vector(32 downto 0) := (32|26|23|22|16|12|11|10|8|7|5|4|2|1|0 => '1', others => '0');

  -- IF field config number
  constant C_IF_FIELD_NUM_ETHERNET_PREAMBLE_SFD    : natural := 0;
  constant C_IF_FIELD_NUM_ETHERNET_MAC_DESTINATION : natural := 1;
  constant C_IF_FIELD_NUM_ETHERNET_MAC_SOURCE      : natural := 2;
  constant C_IF_FIELD_NUM_ETHERNET_LENTGTH         : natural := 3;
  constant C_IF_FIELD_NUM_ETHERNET_PAYLOAD         : natural := 4;
  constant C_IF_FIELD_NUM_ETHERNET_FCS             : natural := 5;

  type t_ethernet_frame is record
    mac_destination : unsigned(47 downto 0);
    mac_source      : unsigned(47 downto 0);
    length          : integer;
    payload         : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH-1);
    fcs             : t_byte_array(0 to 3);
  end record t_ethernet_frame;

  constant C_ETHERNET_FRAME_DEFAULT : t_ethernet_frame := (
    mac_destination => (others => '0'),
    mac_source      => (others => '0'),
    length          => 0,
    payload         => (others => (others => '0')),
    fcs             => (others => (others => '0')));

  type t_ethernet_frame_status is record
    fcs_error : boolean;
  end record t_ethernet_frame_status;

  -- Configuration record to be assigned in the test harness.
  type t_ethernet_bfm_config is record
    mac_destination      : unsigned(47 downto 0);
    mac_source           : unsigned(47 downto 0);
    fcs_error_severity   : t_alert_level;
    interpacket_gap_time : time;
  end record;

  constant C_ETHERNET_BFM_CONFIG_DEFAULT : t_ethernet_bfm_config := (
    mac_destination      => (others => 'Z'),
    mac_source           => (others => 'Z'),
    fcs_error_severity   => ERROR,
    interpacket_gap_time => 768 ns
  );


  --========================================================================================================================
  -- BFM procedures
  --========================================================================================================================
  function generate_crc(
    constant data    : in std_logic_vector;
    constant crc_in  : in std_logic_vector;
    constant polynom : in std_logic_vector
  ) return std_logic_vector;

  impure function generate_crc_32_complete(
    constant data : in t_byte_array
  ) return std_logic_vector;

  impure function check_crc_32(
    constant data : in t_byte_array
  ) return boolean;

  function get_ethernet_frame_length(
    constant payload_length : in positive
  ) return positive;

  function to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string;

  function to_slv(
    constant byte_array : in t_byte_array
  ) return std_logic_vector;

  function to_byte_array(
    constant data : in std_logic_vector
  ) return t_byte_array;

  procedure compare_ethernet_frames(
    constant frame_1      : in t_ethernet_frame;
    constant frame_2      : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant scope        : in string;
    constant msg_id       : in t_msg_id;
    constant msg_id_panel : in t_msg_id_panel
  );

end package ethernet_bfm_pkg;


--========================================================================================================================
--========================================================================================================================

package body ethernet_bfm_pkg is

  function generate_crc(
    constant data    : in std_logic_vector;
    constant crc_in  : in std_logic_vector;
    constant polynom : in std_logic_vector
  ) return std_logic_vector is
    variable crc_out : std_logic_vector(crc_in'range) := crc_in;
  begin
    -- Sanity checks
    check_value(not data'ascending,    TB_FAILURE, "data have to be decending",    C_SCOPE, ID_NEVER);
    check_value(not crc_in'ascending,  TB_FAILURE, "crc_in have to be decending",  C_SCOPE, ID_NEVER);
    check_value(not polynom'ascending, TB_FAILURE, "polynom have to be decending", C_SCOPE, ID_NEVER);
    check_value(crc_in'length, polynom'length-1, TB_FAILURE, "crc_in have to be one bit shorter than polynom", C_SCOPE, ID_NEVER);

    for i in data'high downto data'low loop
      if crc_out(crc_out'high) xor data(i) then
        crc_out := crc_out sll 1;
        crc_out := crc_out xor polynom(polynom'high-1 downto polynom'low);
      else
        crc_out := crc_out sll 1;
      end if;
    end loop;
    return crc_out;
  end function generate_crc;

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
    constant C_NUM_BYTES : positive := data'length;
    variable crc : std_logic_vector(31 downto 0) := C_CRC_32_START_VALUE;
  begin
    for i in data'low to data'high loop
      crc := generate_crc(data(i), crc, C_CRC_32_POLYNOMIAL);
    end loop;
    return crc;
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

  function to_string(
    constant ethernet_frame : in t_ethernet_frame
  ) return string is
  begin
    return "\n    MAC destination: " & to_string(ethernet_frame.mac_destination, HEX, KEEP_LEADING_0, INCL_RADIX) & ";" &
           "\n    MAC source:      " & to_string(ethernet_frame.mac_source, HEX, KEEP_LEADING_0, INCL_RADIX) & ";" &
           "\n    length:          " & to_string(ethernet_frame.length);
  end function to_string;

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
    constant frame_1      : in t_ethernet_frame;
    constant frame_2      : in t_ethernet_frame;
    constant alert_level  : in t_alert_level;
    constant scope        : in string;
    constant msg_id       : in t_msg_id;
    constant msg_id_panel : in t_msg_id_panel
  ) is
  begin
    check_value(frame_1.mac_destination,                frame_2.mac_destination,                alert_level, "Verify MAC destination", scope, HEX, KEEP_LEADING_0, msg_id, msg_id_panel);
    check_value(frame_1.mac_source,                     frame_2.mac_source,                     alert_level, "Verify MAC source",      scope, HEX, KEEP_LEADING_0, msg_id, msg_id_panel);
    check_value(frame_1.length,                         frame_2.length,                         alert_level, "Verify length",          scope,                      msg_id, msg_id_panel);
    if check_value(frame_1.payload(0 to frame_1.length-1), frame_2.payload(0 to frame_2.length-1), alert_level, "Verify payload",         scope, HEX, KEEP_LEADING_0, ID_NEVER, msg_id_panel) then
      log(msg_id, "check_value() => OK. " & add_msg_delimiter("Verify payload"), scope, msg_id_panel);
    end if;
    check_value(frame_1.fcs,                            frame_2.fcs,                            alert_level, "Verify FCS",             scope, HEX, KEEP_LEADING_0, msg_id, msg_id_panel);
  end procedure compare_ethernet_frames;

end package body ethernet_bfm_pkg;

