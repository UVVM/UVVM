-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Utility functions

library ieee;
use ieee.std_logic_1164.all;

package utility is
	-- Return the reverse of the given vector
	function reverse_vector(vec : in std_ulogic_vector) return std_ulogic_vector;
	-- Return a vector with the bytes in opposite order but the content of the bytes unchanged (e.g. for big/little endian conversion)
	function reverse_bytes(vec : in std_ulogic_vector) return std_ulogic_vector;
	-- Extract a byte out of a vector
	function extract_byte(vec : in std_ulogic_vector; byteno : in natural) return std_ulogic_vector;
	-- Set a byte in a vector
	procedure set_byte(vec : inout std_ulogic_vector; byteno : in natural; value : in std_ulogic_vector(7 downto 0));
end package;

package body utility is
	function reverse_vector(vec : in std_ulogic_vector) return std_ulogic_vector is
		variable result : std_ulogic_vector(vec'range);
		alias rev_vec   : std_ulogic_vector(vec'reverse_range) is vec;
	begin
		for i in rev_vec'range loop
			result(i) := rev_vec(i);
		end loop;
		return result;
	end function;
	
	function reverse_bytes(vec : in std_ulogic_vector) return std_ulogic_vector is
		variable result : std_ulogic_vector(vec'range);
	begin
		assert vec'length mod 8 = 0 report "Vector length must be a multiple of 8 for byte reversal" severity failure;
		assert vec'low = 0 report "Vector must start at 0 for byte reversal" severity failure;
		for byte in 0 to vec'high / 8 loop
			set_byte(result, vec'high / 8 - byte, extract_byte(vec, byte));
		end loop;
		return result;
	end function;

	function extract_byte(vec : in std_ulogic_vector; byteno : in natural) return std_ulogic_vector is
	begin
		-- Support both vector directions
		if vec'ascending then
			return vec(byteno * 8 to (byteno + 1) * 8 - 1);
		else
			return vec((byteno + 1) * 8 - 1 downto byteno * 8);
		end if;
	end function;
	
	procedure set_byte(vec : inout std_ulogic_vector; byteno : in natural; value : in std_ulogic_vector(7 downto 0)) is
	begin
		-- Support both vector directions
		if vec'ascending then
			vec(byteno * 8 to (byteno + 1) * 8 - 1) := value;
		else
			vec((byteno + 1) * 8 - 1 downto byteno * 8) := value;
		end if;
	end procedure;
end package body;
