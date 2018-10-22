-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Synchronize a single bit from an arbitrary clock domain
-- into the clock_target domain

library ieee;
use ieee.std_logic_1164.all;

entity single_signal_synchronizer is
	port(
		clock_target_i : in  std_ulogic;
		-- Asynchronous preset of the output and synchronizer flip-flops
		preset_i       : in  std_ulogic := '0';
		-- Asynchronous signal input
		signal_i       : in  std_ulogic;
		-- Synchronous signal output
		signal_o       : out std_ulogic
	);
end entity;