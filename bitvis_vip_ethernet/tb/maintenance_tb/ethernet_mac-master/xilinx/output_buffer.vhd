-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Configurable output buffer forced into the IO block

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity output_buffer is
	port(
		-- Connect to pad or OBUF
		pad_o    : out std_ulogic;
		-- Connect to user logic
		buffer_i : in  std_ulogic;

		-- Capture clock
		clock_i  : in  std_ulogic
	);
end entity;

architecture spartan_6 of output_buffer is
	-- Force putting input Flip-Flop into IOB so it doesn't end up in a normal logic tile
	-- which would ruin the timing.
	attribute iob : string;
	attribute iob of FDRE_inst : label is "FORCE";
begin
	FDRE_inst : FDRE
		generic map(
			INIT => '0')                -- Initial value of register ('0' or '1')  
		port map(
			Q  => pad_o,                -- Data output
			C  => clock_i,              -- Clock input
			CE => '1',                  -- Clock enable input
			R  => '0',                  -- Synchronous reset input
			D  => buffer_i              -- Data input
		);
end architecture;
