-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Device-specific IO setup needed for communicating with the PHY

library ieee;
use ieee.std_logic_1164.all;

use work.ethernet_types.all;

entity mii_gmii_io is
	port(
		-- 125 MHz clock input (exact requirements can vary by implementation)
		-- Spartan 6: clock should be unbuffered
		clock_125_i     : in  std_ulogic;

		-- RX and TX clocks
		clock_tx_o      : out std_ulogic;
		clock_rx_o      : out std_ulogic;

		-- Speed selection for clock switch
		speed_select_i  : in  t_ethernet_speed;

		-- Signals connected directly to external ports
		-- MII
		mii_tx_clk_i    : in  std_ulogic;
		mii_tx_en_o     : out std_ulogic;
		mii_txd_o       : out t_ethernet_data;
		mii_rx_clk_i    : in  std_ulogic;
		mii_rx_er_i     : in  std_ulogic;
		mii_rx_dv_i     : in  std_ulogic;
		mii_rxd_i       : in  t_ethernet_data;

		-- GMII
		gmii_gtx_clk_o  : out std_ulogic;

		-- Signals connected to the mii_gmii module
		int_mii_tx_en_i : in  std_ulogic;
		int_mii_txd_i   : in  t_ethernet_data;
		int_mii_rx_er_o : out std_ulogic;
		int_mii_rx_dv_o : out std_ulogic;
		int_mii_rxd_o   : out t_ethernet_data
	);
end entity;

