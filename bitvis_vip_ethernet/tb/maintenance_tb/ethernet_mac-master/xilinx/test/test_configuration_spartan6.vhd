-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Configuration for using the testbench in post-synthesis simulation
-- Start work.post_synthesis_spartan6 in your simulator of choice

configuration post_synthesis_spartan6 of ethernet_mac_tb is
	for behavioral
		for all : test_instance
			use entity work.test_wrapper_spartan6;
		end for;
	end for;
end configuration;