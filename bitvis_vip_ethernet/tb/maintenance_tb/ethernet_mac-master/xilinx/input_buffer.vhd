-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Configurable input buffer forced into the IO block

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity input_buffer is
	generic(
		-- If TRUE, fixed_input_delay is inserted between the pad and the flip-flop
		HAS_DELAY    : boolean                := FALSE;
		IDELAY_VALUE : natural range 0 to 255 := 0
	);
	port(
		-- Connect to pad or IBUF
		pad_i    : in  std_ulogic;
		-- Connect to user logic
		buffer_o : out std_ulogic;

		-- Capture clock
		clock_i  : in  std_ulogic
	);
end entity;

architecture spartan_6 of input_buffer is
	signal delayed : std_ulogic := '0';

	-- Force putting input Flip-Flop into IOB so it doesn't end up in a normal logic tile
	-- which would ruin the timing.
	attribute iob : string;
	attribute iob of FDRE_inst : label is "FORCE";
begin
	-- When delay activated: Instantiate IODELAY2 and then capture its output
	delay_gen : if HAS_DELAY = TRUE generate
		fixed_input_delay_inst : entity work.fixed_input_delay
			generic map(
				IDELAY_VALUE => IDELAY_VALUE
			)
			port map(
				pad_i     => pad_i,
				delayed_o => delayed
			);
	end generate;

	-- When delay deactivated: Directly capture the signal
	no_delay_gen : if HAS_DELAY = FALSE generate
		delayed <= pad_i;
	end generate;

	FDRE_inst : FDRE
		generic map(
			INIT => '0')                -- Initial value of register ('0' or '1')  
		port map(
			Q  => buffer_o,             -- Data output
			C  => clock_i,              -- Clock input
			CE => '1',                  -- Clock enable input
			R  => '0',                  -- Synchronous reset input
			D  => delayed               -- Data input
		);

end architecture;
