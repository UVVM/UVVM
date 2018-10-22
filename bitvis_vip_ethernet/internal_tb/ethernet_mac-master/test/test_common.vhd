-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Some types used in the test user application and the testbench

library ieee;
use ieee.std_logic_1164.all;

use work.ethernet_types.all;
use work.utility.all;

package test_common is
	type t_test_mode is (
		-- Do nothing
		TEST_NOTHING,
		-- Loop all RX frames back to TX identically
		TEST_LOOPBACK,
		-- Transmit frames with each size from 1 to 59 bytes to see if they are padded correctly
		TEST_TX_PADDING
	);
	
	constant TEST_MAC_ADDRESS : t_mac_address := reverse_bytes(x"000102030405");
	
	component test_instance
		port(clock_125_i      : in  std_ulogic;
			 user_clock_i     : in  std_ulogic;
			 reset_i          : in  std_ulogic;

			 mii_tx_clk_i     : in  std_ulogic;
			 mii_tx_er_o      : out std_ulogic;
			 mii_tx_en_o      : out std_ulogic;
			 mii_txd_o        : out std_ulogic_vector(7 downto 0);
			 mii_rx_clk_i     : in  std_ulogic;
			 mii_rx_er_i      : in  std_ulogic;
			 mii_rx_dv_i      : in  std_ulogic;
			 mii_rxd_i        : in  std_ulogic_vector(7 downto 0);

			 gmii_gtx_clk_o   : out std_ulogic;

			 rgmii_tx_ctl_o   : out std_ulogic;
			 rgmii_rx_ctl_i   : in  std_ulogic;

			 speed_override_i : in  t_ethernet_speed;

			 test_mode_i      : in  t_test_mode);
	end component;
end package;
