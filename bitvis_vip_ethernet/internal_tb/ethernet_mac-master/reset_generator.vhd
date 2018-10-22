-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Monitor the speed and issue a core-wide reset if it changes

library ieee;
use ieee.std_logic_1164.all;

use work.ethernet_types.all;

entity reset_generator is
	generic(
		-- Number of clock_i ticks reset should get asserted for
		RESET_TICKS : positive := 1000
	);
	port(
		clock_i : in  std_ulogic;
		-- Speed signal synchronous to clock_i
		speed_i : in  t_ethernet_speed;

		-- Asynchronous reset input for this logic
		-- Do NOT connect reset_i and reset_o anywhere in the design
		reset_i : in  std_ulogic;
		-- Reset output
		-- Is also asserted whenever reset_i is asserted
		reset_o : out std_ulogic
	);
end entity;

architecture rtl of reset_generator is
	type t_state is (
		WATCH,
		RESET
	);
	signal state         : t_state := WATCH;
	signal reset_counter : integer range 0 to RESET_TICKS;

	signal last_speed : t_ethernet_speed;
begin
	speed_watch : process(reset_i, clock_i)
	begin
		if reset_i = '1' then
			last_speed <= SPEED_UNSPECIFIED;
			state      <= WATCH;
			reset_o    <= '1';
		elsif rising_edge(clock_i) then
			reset_o    <= '0';

			case state is
				when WATCH =>
					null;
				when RESET =>
					reset_o <= '1';
					if reset_counter = RESET_TICKS then
						state <= WATCH;
					else
						reset_counter <= reset_counter + 1;
					end if;
			end case;

			if speed_i /= last_speed then
				-- Speed was changed
				state         <= RESET;
				-- Always reset counter
				reset_counter <= 0;
			end if;
			
			last_speed <= speed_i;
		end if;
	end process;

end architecture;
