-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- MIIM types

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package miim_types is
	subtype t_register_address is unsigned(4 downto 0);
	subtype t_phy_address is unsigned(4 downto 0);
	subtype t_data is std_ulogic_vector(15 downto 0);

	function to_register_address(c : natural) return t_register_address;

	constant DEFAULT_POLL_WAIT_TICKS : natural := 10000000;
end package;

package body miim_types is
	function to_register_address(c : natural) return t_register_address is
	begin
		return to_unsigned(c, t_register_address'length);
	end function;
end package body;