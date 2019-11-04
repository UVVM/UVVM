-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Utility functions for CRC calculation
-- Inspired by "Automatic Generation of Parallel CRC Circuits" by Michael Sprachmann

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utility.all;

package crc is
	-- Update CRC old_crc by one bit (input) using a given polynomial
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic; polynomial : std_ulogic_vector) return std_ulogic_vector;
	-- Update CRC old_crc by an arbitrary number of bits (input) using a given polynomial
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic_vector; polynomial : std_ulogic_vector) return std_ulogic_vector;
end package;

package body crc is
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic; polynomial : std_ulogic_vector) return std_ulogic_vector is
		variable new_crc  : std_ulogic_vector(old_crc'range);
		variable feedback : std_ulogic;
	begin
		assert not old_crc'ascending report "CRC argument must have descending range";
		-- Simple calculation with LFSR
		new_crc  := old_crc;
		feedback := new_crc(new_crc'high) xor input;

		new_crc  := std_ulogic_vector(unsigned(new_crc) sll 1);
		if (feedback = '1') then
			new_crc := new_crc xor polynomial(polynomial'high - 1 downto 0);
		end if;

		return new_crc;
	end function;

	-- Let the synthesizer figure out how to compute the checksum in parallel
	-- for any number of bits
	function update_crc(old_crc : std_ulogic_vector; input : std_ulogic_vector; polynomial : std_ulogic_vector) return std_ulogic_vector is
		variable new_crc : std_ulogic_vector(old_crc'range);
	begin
		assert not old_crc'ascending report "CRC argument must have descending range";
		assert not input'ascending report "Input argument must have descending range";
		new_crc := old_crc;

		-- Start with LSB
		for i in input'low to input'high loop
			new_crc := update_crc(new_crc, input(i), polynomial);
		end loop;
		
		return new_crc;
	end function;

end package body;
