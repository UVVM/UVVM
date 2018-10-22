-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Common definitions pertaining to the structure of Ethernet frames

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_types.all;
use work.crc32.all;
use work.utility.all;

package framing_common is

	-- Preamble/SFD data in IEEE 802.3 clauses 4.2.5 and 4.2.6 is denoted LSB first, so they appear reversed here
	constant PREAMBLE_DATA              : t_ethernet_data := "01010101";
	--constant PREAMBLE_LENGTH : positive := 7;
	constant START_FRAME_DELIMITER_DATA : t_ethernet_data := "11010101";
	constant PADDING_DATA               : t_ethernet_data := "00000000";

	-- Data is counted from the end of the SFD to the beginning of the frame check sequence, exclusive
	constant MIN_FRAME_DATA_BYTES : positive := 46 + 2 + 6 + 6; -- bytes
	constant MAX_FRAME_DATA_BYTES : positive := 1500 + 2 + 6 + 6; -- bytes

	constant INTERPACKET_GAP_BYTES : positive := 12; -- bytes

	-- 11 bits are sufficient for 2048 bytes, Ethernet can only have 1518
	constant PACKET_LENGTH_BITS : positive := 11;
	constant MAX_PACKET_LENGTH  : positive := (2 ** PACKET_LENGTH_BITS) - 1;
	subtype t_packet_length is unsigned((PACKET_LENGTH_BITS - 1) downto 0);

	-- Get a specific byte out of the given CRC32 suitable for transmission as Ethernet FCS
	function fcs_output_byte(fcs : t_crc32; byte : integer) return t_ethernet_data;
end package;

package body framing_common is
	function fcs_output_byte(fcs : t_crc32; byte : integer) return t_ethernet_data is
		variable reversed : t_crc32;
		variable out_byte : t_ethernet_data;
		variable inverted : t_ethernet_data;
	begin
		-- Reverse and invert the whole CRC32, then get the needed byte out
		reversed := reverse_vector(fcs);
		out_byte := reversed((((byte + 1) * 8) - 1) downto byte * 8);
		inverted := not out_byte;
		return inverted;
	end function;
end package body;
