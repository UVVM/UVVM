-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

library ieee;
use ieee.std_logic_1164.all;

package ethernet_types is
	-- One Ethernet interface byte
	subtype t_ethernet_data is std_ulogic_vector(7 downto 0);
	-- Ethernet speed, values defined below
	subtype t_ethernet_speed is std_ulogic_vector(1 downto 0);
	-- Ethernet MAC layer address
	constant MAC_ADDRESS_BYTES : positive := 6;
	subtype t_mac_address is std_ulogic_vector((MAC_ADDRESS_BYTES * 8 - 1) downto 0);
	-- Use utility.reverse_bytes to convert from the canoncial form to the internal representation
	-- Example: signal m : t_mac_address := reverse_bytes(x"04AA19BCDE10");
	-- m then represents the canoncial address 04-AA-19-BC-DE-10
	-- Broadcast address
	constant BROADCAST_MAC_ADDRESS : t_mac_address := x"FFFFFFFFFFFF";	

	-- Speed constants
	constant SPEED_1000MBPS    : t_ethernet_speed := "10";
	constant SPEED_100MBPS     : t_ethernet_speed := "01";
	constant SPEED_10MBPS      : t_ethernet_speed := "00";
	constant SPEED_UNSPECIFIED : t_ethernet_speed := "11";
end package;