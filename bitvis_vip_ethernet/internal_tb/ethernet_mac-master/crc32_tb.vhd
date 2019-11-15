-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Simple testbench for playing around with the CRC calculation code

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.crc32.all;
use work.utility.all;

entity crc32_tb is
end entity;

architecture behavioral of crc32_tb is

	-- "Known good" function for comparison
	-- polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
	-- data width: 8
	-- convention: the first serial bit is D[0]
	function NEXTCRC32_D8(DATA : std_ulogic_vector(7 downto 0);
		                  CRC  : std_ulogic_vector(31 downto 0)) return std_ulogic_vector is
		variable D      : std_ulogic_vector(7 downto 0);
		variable C      : std_ulogic_vector(31 downto 0);
		variable NEWCRC : std_ulogic_vector(31 downto 0);

	begin
		D          := DATA;
		C          := CRC;
		NewCRC(0)  := C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(1)  := C(25) xor C(31) xor D(0) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(2)  := C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(3)  := C(27) xor D(4) xor C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6);
		NewCRC(4)  := C(28) xor D(3) xor C(27) xor D(4) xor C(26) xor D(5) xor C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(5)  := C(29) xor D(2) xor C(28) xor D(3) xor C(27) xor D(4) xor C(25) xor C(31) xor D(0) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(6)  := C(30) xor D(1) xor C(29) xor D(2) xor C(28) xor D(3) xor C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6);
		NewCRC(7)  := C(31) xor D(0) xor C(29) xor D(2) xor C(27) xor D(4) xor C(26) xor D(5) xor C(24) xor D(7);
		NewCRC(8)  := C(0) xor C(28) xor D(3) xor C(27) xor D(4) xor C(25) xor D(6) xor C(24) xor D(7);
		NewCRC(9)  := C(1) xor C(29) xor D(2) xor C(28) xor D(3) xor C(26) xor D(5) xor C(25) xor D(6);
		NewCRC(10) := C(2) xor C(29) xor D(2) xor C(27) xor D(4) xor C(26) xor D(5) xor C(24) xor D(7);
		NewCRC(11) := C(3) xor C(28) xor D(3) xor C(27) xor D(4) xor C(25) xor D(6) xor C(24) xor D(7);
		NewCRC(12) := C(4) xor C(29) xor D(2) xor C(28) xor D(3) xor C(26) xor D(5) xor C(25) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(13) := C(5) xor C(30) xor D(1) xor C(29) xor D(2) xor C(27) xor D(4) xor C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6);
		NewCRC(14) := C(6) xor C(31) xor D(0) xor C(30) xor D(1) xor C(28) xor D(3) xor C(27) xor D(4) xor C(26) xor D(5);
		NewCRC(15) := C(7) xor C(31) xor D(0) xor C(29) xor D(2) xor C(28) xor D(3) xor C(27) xor D(4);
		NewCRC(16) := C(8) xor C(29) xor D(2) xor C(28) xor D(3) xor C(24) xor D(7);
		NewCRC(17) := C(9) xor C(30) xor D(1) xor C(29) xor D(2) xor C(25) xor D(6);
		NewCRC(18) := C(10) xor C(31) xor D(0) xor C(30) xor D(1) xor C(26) xor D(5);
		NewCRC(19) := C(11) xor C(31) xor D(0) xor C(27) xor D(4);
		NewCRC(20) := C(12) xor C(28) xor D(3);
		NewCRC(21) := C(13) xor C(29) xor D(2);
		NewCRC(22) := C(14) xor C(24) xor D(7);
		NewCRC(23) := C(15) xor C(25) xor D(6) xor C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(24) := C(16) xor C(26) xor D(5) xor C(25) xor C(31) xor D(0) xor D(6);
		NewCRC(25) := C(17) xor C(27) xor D(4) xor C(26) xor D(5);
		NewCRC(26) := C(18) xor C(28) xor D(3) xor C(27) xor D(4) xor C(24) xor C(30) xor D(1) xor D(7);
		NewCRC(27) := C(19) xor C(29) xor D(2) xor C(28) xor D(3) xor C(25) xor C(31) xor D(0) xor D(6);
		NewCRC(28) := C(20) xor C(30) xor D(1) xor C(29) xor D(2) xor C(26) xor D(5);
		NewCRC(29) := C(21) xor C(31) xor D(0) xor C(30) xor D(1) xor C(27) xor D(4);
		NewCRC(30) := C(22) xor C(31) xor D(0) xor C(28) xor D(3);
		NewCRC(31) := C(23) xor C(29) xor D(2);

		return NEWCRC;
	end NEXTCRC32_D8;

	-- Signals as isim cannot trace variables
	signal crc            : t_crc32;
	signal comparison_crc : t_crc32;
	signal data           : std_ulogic_vector(7 downto 0);

	constant WAIT_PERIOD : time := 40 ns;
begin
	test_crc32 : process
		variable saved_crc : t_crc32;
	begin
		crc            <= (others => '1');
		comparison_crc <= (others => '1');
		data           <= (others => '0');
		wait for WAIT_PERIOD;

		for cnt in 0 to 10 loop
			crc            <= update_crc32(crc, data);
			comparison_crc <= NEXTCRC32_D8(data, crc);
			if cnt >= 7 then
				data <= (others => '0');
			else
				data <= std_ulogic_vector(to_unsigned(cnt + 1, 8));
			end if;
			wait for WAIT_PERIOD;
			if crc /= comparison_crc then
				report "CRC mismatch" severity note;
			end if;
		end loop;

		saved_crc := not reverse_vector(crc);

		wait for 100 ns;

		for j in 0 to 3 loop
			crc            <= update_crc32(crc, saved_crc(((j + 1) * 8) - 1 downto j * 8));
			comparison_crc <= NEXTCRC32_D8(saved_crc(((j + 1) * 8) - 1 downto j * 8), crc);
			wait for WAIT_PERIOD;
		end loop;

		--crc <= reverse_vector(crc);

		wait for WAIT_PERIOD;

		if crc /= X"C704dd7B" then
			report "Final CRC wrong" severity note;
		end if;

		wait;
	end process;

end architecture;

