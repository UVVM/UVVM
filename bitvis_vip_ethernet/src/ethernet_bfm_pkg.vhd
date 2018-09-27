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
  constant C_SCOPE          : string := "ETHERNET BFM";
  constant C_PREAMBLE       : std_logic_vector(55 downto 0) := x"55_55_55_55_55_55_55";
  constant C_SFD            : std_logic_vector( 7 downto 0) := x"5D";
  constant C_CRC_32_RESIDUE : std_logic_vector(31 downto 0) := x"C704DD7B";

  type t_ethernet_frame is record
    mac_destination : t_byte_array(0 to 5);
    mac_source      : t_byte_array(0 to 5);
    length          : t_byte_array(0 to 1);
    payload         : t_byte_array;
    fcs             : t_byte_array(0 to 3);
  end record t_ethernet_frame;

  type t_ethernet_frame_status is record
    fcs_error : boolean;
  end record t_ethernet_frame_status;

  -- Configuration record to be assigned in the test harness.
  type t_ethernet_bfm_config is record
    mac_destination      : t_byte_array(0 to 5);
    mac_source           : t_byte_array(0 to 5);
    fcs_error_severity   : t_alert_level;
    interpacket_gap_time : time;
  end record;

  constant C_ETHERNET_BFM_CONFIG_DEFAULT : t_ethernet_bfm_config := (
    mac_destination      => (others => (others => 'Z')),
    mac_source           => (others => (others => 'Z')),
    fcs_error_severity   => ERROR,
    interpacket_gap_time => 768 ns
  );


  --========================================================================================================================
  -- BFM procedures
  --========================================================================================================================

  function generate_crc_32(
    constant data   : in std_logic_vector(7 downto 0);
    constant crc_in : in std_logic_vector(31 downto 0)
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

--  function encode_ethernet_frame(
--    constant mac_destination : in t_byte_array(0 to 5);
--    constant mac_source      : in t_byte_array(0 to 5);
--    constant payload         : in t_byte_array;
--    constant scope           : in string         := C_SCOPE;
--    constant msg_id_panel    : in t_msg_id_panel := shared_msg_id_panel
--  ) return t_byte_array;
--
--  function decode_ethernet_frame(
--    constant data         : in t_byte_array;
--    constant scope        : in string         := C_SCOPE;
--    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
--  ) return t_ethernet_frame;

end package ethernet_bfm_pkg;


--========================================================================================================================
--========================================================================================================================

package body ethernet_bfm_pkg is

  ---------------------------------------------------------------------------------
  -- generate_crc_32
  ---------------------------------------------------------------------------------
  --
  -- This function generate the IEEE 802.3 CRC32 for 8-bit input data.
  --
  ---------------------------------------------------------------------------------
  function generate_crc_32(
    constant data   : in std_logic_vector(7 downto 0);
    constant crc_in : in std_logic_vector(31 downto 0)
  ) return std_logic_vector is
    variable v_crc_out : std_logic_vector(31 downto 0);
  begin
    v_crc_out(0)  := crc_in(24) xor crc_in(30) xor data(0)    xor data(6);
    v_crc_out(1)  := crc_in(24) xor crc_in(25) xor crc_in(30) xor crc_in(31) xor data(0)    xor data(1)    xor data(6)    xor data(7);
    v_crc_out(2)  := crc_in(24) xor crc_in(25) xor crc_in(26) xor crc_in(30) xor crc_in(31) xor data(0)    xor data(1)    xor data(2) xor data(6) xor data(7);
    v_crc_out(3)  := crc_in(25) xor crc_in(26) xor crc_in(27) xor crc_in(31) xor data(1)    xor data(2)    xor data(3)    xor data(7);
    v_crc_out(4)  := crc_in(24) xor crc_in(26) xor crc_in(27) xor crc_in(28) xor crc_in(30) xor data(0)    xor data(2)    xor data(3) xor data(4) xor data(6);
    v_crc_out(5)  := crc_in(24) xor crc_in(25) xor crc_in(27) xor crc_in(28) xor crc_in(29) xor crc_in(30) xor crc_in(31) xor data(0) xor data(1) xor data(3) xor data(4) xor data(5) xor data(6) xor data(7);
    v_crc_out(6)  := crc_in(25) xor crc_in(26) xor crc_in(28) xor crc_in(29) xor crc_in(30) xor crc_in(31) xor data(1)    xor data(2) xor data(4) xor data(5) xor data(6) xor data(7);
    v_crc_out(7)  := crc_in(24) xor crc_in(26) xor crc_in(27) xor crc_in(29) xor crc_in(31) xor data(0)    xor data(2)    xor data(3) xor data(5) xor data(7);
    v_crc_out(8)  := crc_in(0)  xor crc_in(24) xor crc_in(25) xor crc_in(27) xor crc_in(28) xor data(0)    xor data(1)    xor data(3) xor data(4);
    v_crc_out(9)  := crc_in(1)  xor crc_in(25) xor crc_in(26) xor crc_in(28) xor crc_in(29) xor data(1)    xor data(2)    xor data(4) xor data(5);
    v_crc_out(10) := crc_in(2)  xor crc_in(24) xor crc_in(26) xor crc_in(27) xor crc_in(29) xor data(0)    xor data(2)    xor data(3) xor data(5);
    v_crc_out(11) := crc_in(3)  xor crc_in(24) xor crc_in(25) xor crc_in(27) xor crc_in(28) xor data(0)    xor data(1)    xor data(3) xor data(4);
    v_crc_out(12) := crc_in(4)  xor crc_in(24) xor crc_in(25) xor crc_in(26) xor crc_in(28) xor crc_in(29) xor crc_in(30) xor data(0) xor data(1) xor data(2) xor data(4) xor data(5) xor data(6);
    v_crc_out(13) := crc_in(5)  xor crc_in(25) xor crc_in(26) xor crc_in(27) xor crc_in(29) xor crc_in(30) xor crc_in(31) xor data(1) xor data(2) xor data(3) xor data(5) xor data(6) xor data(7);
    v_crc_out(14) := crc_in(6)  xor crc_in(26) xor crc_in(27) xor crc_in(28) xor crc_in(30) xor crc_in(31) xor data(2)    xor data(3) xor data(4) xor data(6) xor data(7);
    v_crc_out(15) := crc_in(7)  xor crc_in(27) xor crc_in(28) xor crc_in(29) xor crc_in(31) xor data(3)    xor data(4)    xor data(5) xor data(7);
    v_crc_out(16) := crc_in(8)  xor crc_in(24) xor crc_in(28) xor crc_in(29) xor data(0)    xor data(4)    xor data(5);
    v_crc_out(17) := crc_in(9)  xor crc_in(25) xor crc_in(29) xor crc_in(30) xor data(1)    xor data(5)    xor data(6);
    v_crc_out(18) := crc_in(10) xor crc_in(26) xor crc_in(30) xor crc_in(31) xor data(2)    xor data(6)    xor data(7);
    v_crc_out(19) := crc_in(11) xor crc_in(27) xor crc_in(31) xor data(3)    xor data(7);
    v_crc_out(20) := crc_in(12) xor crc_in(28) xor data(4);
    v_crc_out(21) := crc_in(13) xor crc_in(29) xor data(5);
    v_crc_out(22) := crc_in(14) xor crc_in(24) xor data(0);
    v_crc_out(23) := crc_in(15) xor crc_in(24) xor crc_in(25) xor crc_in(30) xor data(0)    xor data(1)    xor data(6);
    v_crc_out(24) := crc_in(16) xor crc_in(25) xor crc_in(26) xor crc_in(31) xor data(1)    xor data(2)    xor data(7);
    v_crc_out(25) := crc_in(17) xor crc_in(26) xor crc_in(27) xor data(2)    xor data(3);
    v_crc_out(26) := crc_in(18) xor crc_in(24) xor crc_in(27) xor crc_in(28) xor crc_in(30) xor data(0)    xor data(3)    xor data(4) xor data(6);
    v_crc_out(27) := crc_in(19) xor crc_in(25) xor crc_in(28) xor crc_in(29) xor crc_in(31) xor data(1)    xor data(4)    xor data(5) xor data(7);
    v_crc_out(28) := crc_in(20) xor crc_in(26) xor crc_in(29) xor crc_in(30) xor data(2)    xor data(5)    xor data(6);
    v_crc_out(29) := crc_in(21) xor crc_in(27) xor crc_in(30) xor crc_in(31) xor data(3)    xor data(6)    xor data(7);
    v_crc_out(30) := crc_in(22) xor crc_in(28) xor crc_in(31) xor data(4)    xor data(7);
    v_crc_out(31) := crc_in(23) xor crc_in(29) xor data(5);
    return v_crc_out;
  end function generate_crc_32;

  impure function generate_crc_32_complete(
    constant data : in t_byte_array
  ) return std_logic_vector is
    constant C_NUM_BYTES : positive := data'length;
    variable crc : std_logic_vector(31 downto 0) := C_CRC_32_START_VALUE;
  begin
    for i in data'low to data'high loop
      crc := generate_crc_32(data(i), crc);
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
--
--  impure function encode_ethernet_frame(
--    constant mac_destination : in t_byte_array(0 to 5);
--    constant mac_source      : in t_byte_array(0 to 5);
--    constant payload         : in t_byte_array;
--    constant scope           : in string         := C_SCOPE;
--    constant msg_id_panel    : in t_msg_id_panel := shared_msg_id_panel
--  ) return t_byte_array is
--    constant proc_name               : string := "encode_ethernet_package";
--    constant proc_call               : string := proc_name;
--    constant C_PAYLOAD_LENGTH        : positive := payload'high-payload'low;
--    constant C_PAYLOAD_LENGTH_VECTOR : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(C_PAYLOAD_LENGTH, 16));
--    variable v_ethernet_frame        : t_byte_array(0 to 17 + C_PAYLOAD_LENGTH) := (others => (others => '0'));
--    variable v_crc, v_fcs            : std_logic_vector(31 downto 0);
--  begin
--    -- Check valid payload length
--    check_value_in_range(payload'high-payload'low, C_ETHERNET_PAYLOAD_MIN_LENGTH, C_ETHERNET_PAYLOAD_MAX_LENGTH, TB_ERROR, proc_call &
--        ": length of payload is not in the valid range " & to_string(C_ETHERNET_PAYLOAD_MAX_LENGTH) & " - " &
--        to_string(C_ETHERNET_PAYLOAD_MIN_LENGTH) & " bytes.", scope, ID_NEVER, msg_id_panel);
--
--    -- MAC destination
--    v_ethernet_frame( 0 to  5) := mac_destination;
--
--    -- MAC source
--    v_ethernet_frame( 6 to 11) := mac_source;
--
--    -- payload length
--    v_ethernet_frame(12) := C_PAYLOAD_LENGTH_VECTOR(15 downto 8);
--    v_ethernet_frame(13) := C_PAYLOAD_LENGTH_VECTOR( 7 downto 0);
--
--    -- payload
--    v_ethernet_frame(14 to 14 + C_PAYLOAD_LENGTH - 1) := payload; -- TBD: normalize
--
--    -- FCS
--    v_crc := generate_crc_32_complete(v_ethernet_frame(0 to 14 + C_PAYLOAD_LENGTH - 1));
--    v_fcs := not(v_crc);
--    v_ethernet_frame(14 + C_PAYLOAD_LENGTH to 14 + C_PAYLOAD_LENGTH)     := v_fcs(31 downto 24);
--    v_ethernet_frame(14 + C_PAYLOAD_LENGTH to 14 + C_PAYLOAD_LENGTH + 1) := v_fcs(23 downto 16);
--    v_ethernet_frame(14 + C_PAYLOAD_LENGTH to 14 + C_PAYLOAD_LENGTH + 2) := v_fcs(15 downto  8);
--    v_ethernet_frame(14 + C_PAYLOAD_LENGTH to 14 + C_PAYLOAD_LENGTH + 3) := v_fcs( 7 downto  0);
--
--    return v_ethernet_frame;
--  end function encode_ethernet_frame;
--
--  impure function decode_ethernet_frame(
--    constant data         : in t_byte_array
--    constant scope        : in string         := C_SCOPE;
--    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
--  ) return t_ethernet_frame is
--    constant proc_name        : string := "decode_ethernet_package";
--    constant proc_call        : string := proc_name;
--    variable v_ethernet_frame : t_ethernet_frame;
--  begin
--    -- Check valid pa
--    check_value_in_range(data'length, 18 + C_ETHERNET_PAYLOAD_MIN_LENGTH, 18 + C_ETHERNET_PAYLOAD_MAX_LENGTH, TB_ERROR, proc_call &
--        ": length of ethernet packet is not in the valid range " & to_string(18 + C_ETHERNET_PAYLOAD_MIN_LENGTH) & " - " &
--        to_string(18 + C_ETHERNET_PAYLOAD_MAX_LENGTH) & " bytes.", C_SCOPE, ID_NEVER, msg_id_panel);
--
--    v_ethernet_frame.mac_destination := data( 0 to  5);
--    v_ethernet_frame.mac_source      := data( 6 to 11);
--    v_ethernet_frame.length          := data(12 to 13);
--    v_ethernet_frame.payload         := data(14 to data'length-5);
--    v_ethernet_frame.fcs             := data(data'length-4 to data'length-1);
--
--    return v_ethernet_frame;
--  end function decode_ethernet_frame;
--
--  procedure send_to_sub_vvc(
--    constant sub_vvc : in t_vvc;
--    constant ethernet_packet : in t_ethernet_packet
--  ) begin
--
--    case sub_vvc.interface is
--
--      when GMII =>
--        transmit(GMII_VVCT, sub_vvc.instance, sub_vvc.channel, ethernet_packet);
--
--      when others =>
--        alert(TB_ERROR, "This interface has not been defined for this VVC");
--
--  end procedure send_to_sub_vvc;


end package body ethernet_bfm_pkg;

