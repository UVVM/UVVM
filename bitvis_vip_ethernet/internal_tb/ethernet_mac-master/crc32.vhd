-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Utility functions for CRC32/Ethernet frame check sequence calculation

library ieee;
use ieee.std_logic_1164.all;

use work.crc.all;

package crc32 is
	-- As defined in IEEE 802.3 clause 3.2.9
	-- x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
	constant CRC32_POLYNOMIAL : std_ulogic_vector(32 downto 0) := (
		32 | 26 | 23 | 22 | 16 | 12 | 11 | 10 | 8 | 7 | 5 | 4 | 2 | 1 | 0 => '1',
		others => '0'
	);

	-- CRC32 value type
	subtype t_crc32 is std_ulogic_vector(31 downto 0);

	-- Value that remains as CRC value when incoming data including the original FCS is piped through update_crc32 
	-- and the FCS is correct.
	-- Usually this would be zero, but the inversion of the FCS in clause 3.2.9 e changes it to this magic value.
	constant CRC32_POSTINVERT_MAGIC : t_crc32 := X"C704DD7B";
	
	-- Update CRC32 old_crc by one bit (input)
	function update_crc32(old_crc : t_crc32; input : std_ulogic) return t_crc32;
	-- Update CRC32 old_crc by an arbitrary number of bits (input)
	function update_crc32(old_crc : t_crc32; input : std_ulogic_vector) return t_crc32;

	constant CRC32_BYTES : positive := (t_crc32'length / 8);
end package;

package body crc32 is
	function update_crc32(old_crc : t_crc32; input : std_ulogic) return t_crc32 is
	begin
		return update_crc(old_crc, input, CRC32_POLYNOMIAL);
	end function;
	
	function update_crc32(old_crc : t_crc32; input : std_ulogic_vector) return t_crc32 is
	begin
		return update_crc(old_crc, input, CRC32_POLYNOMIAL);
	end function;
end package body;
