-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Convert std_logic_vector ports of test_instance_spartan6 (changed on compilation
-- by the Xilinx toolchain) to std_ulogic_vector

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_types.all;
use work.test_common.all;

entity test_wrapper_spartan6 is
	port(
		clock_125_i      : in  std_ulogic;
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
		test_mode_i      : in  t_test_mode
	);
end entity;

architecture structure of test_wrapper_spartan6 is
	signal mii_txd   : std_logic_vector(7 downto 0);
	signal test_mode : std_logic_vector(1 downto 0);
begin
	mii_txd_o                         <= std_ulogic_vector(mii_txd);
	-- Convert to std_logic_vector for the interface
	with test_mode_i select test_mode <=
		"01" when TEST_LOOPBACK,
		"10" when TEST_TX_PADDING,
		"00" when others;

	test_instance_inst : entity work.test_instance_spartan6
		port map(
			clock_125_i      => clock_125_i,
			user_clock_i     => user_clock_i,
			reset_i          => reset_i,
			mii_tx_clk_i     => mii_tx_clk_i,
			mii_tx_er_o      => mii_tx_er_o,
			mii_tx_en_o      => mii_tx_en_o,
			mii_txd_o        => mii_txd,
			mii_rx_clk_i     => mii_rx_clk_i,
			mii_rx_er_i      => mii_rx_er_i,
			mii_rx_dv_i      => mii_rx_dv_i,
			mii_rxd_i        => std_logic_vector(mii_rxd_i),
			gmii_gtx_clk_o   => gmii_gtx_clk_o,
			rgmii_tx_ctl_o   => rgmii_tx_ctl_o,
			rgmii_rx_ctl_i   => rgmii_rx_ctl_i,
			speed_override_i => std_logic_vector(speed_override_i),
			test_mode_i      => test_mode
		);

end architecture;

