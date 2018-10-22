-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Prebuilt Ethernet MAC with FIFOs connected

library ieee;
use ieee.std_logic_1164.all;

use work.ethernet_types.all;
use work.miim_types.all;

entity ethernet_with_fifos is
	generic(
		MIIM_PHY_ADDRESS      : t_phy_address := (others => '0');
		MIIM_RESET_WAIT_TICKS : natural       := 0;
		MIIM_POLL_WAIT_TICKS  : natural       := DEFAULT_POLL_WAIT_TICKS;
		-- See comment in miim for values
		-- Default is fine for 125 MHz MIIM clock
		MIIM_CLOCK_DIVIDER    : positive      := 50;
		MIIM_DISABLE          : boolean       := FALSE;

		-- See comment in rx_fifo for values
		RX_FIFO_SIZE_BITS     : positive      := 12
	);
	port(
		-- Unbuffered 125 MHz clock input
		clock_125_i      : in    std_ulogic;
		-- Asynchronous reset
		reset_i          : in    std_ulogic;
		-- MAC address of this station
		-- Must not change after reset is deasserted
		mac_address_i    : in    t_mac_address;

		-- MII (Media-independent interface)
		mii_tx_clk_i     : in    std_ulogic;
		mii_tx_er_o      : out   std_ulogic;
		mii_tx_en_o      : out   std_ulogic;
		mii_txd_o        : out   std_ulogic_vector(7 downto 0);
		mii_rx_clk_i     : in    std_ulogic;
		mii_rx_er_i      : in    std_ulogic;
		mii_rx_dv_i      : in    std_ulogic;
		mii_rxd_i        : in    std_ulogic_vector(7 downto 0);

		-- GMII (Gigabit media-independent interface)
		gmii_gtx_clk_o   : out   std_ulogic;

		-- RGMII (Reduced pin count gigabit media-independent interface)
		rgmii_tx_ctl_o   : out   std_ulogic;
		rgmii_rx_ctl_i   : in    std_ulogic;

		-- MII Management Interface
		-- Clock, can be identical to clock_125_i
		-- If not, adjust MIIM_CLOCK_DIVIDER accordingly
		miim_clock_i     : in    std_ulogic;
		mdc_o            : out   std_ulogic;
		mdio_io          : inout std_ulogic;
		-- Status, synchronous to miim_clock_i
		link_up_o        : out   std_ulogic;
		speed_o          : out   t_ethernet_speed;
		-- Also synchronous to miim_clock_i if used!
		speed_override_i : in    t_ethernet_speed := SPEED_UNSPECIFIED;

		-- TX FIFO
		tx_clock_i       : in    std_ulogic;
		-- Synchronous reset
		-- When asserted, the content of the buffer was lost.
		-- When full is deasserted the next time, a packet size must be written.
		-- The data of the packet previously being written is not available anymore then.
		tx_reset_o       : out   std_ulogic;
		tx_data_i        : in    t_ethernet_data;
		tx_wr_en_i       : in    std_ulogic;
		tx_full_o        : out   std_ulogic;

		-- RX FIFO
		rx_clock_i       : in    std_ulogic;
		-- Synchronous reset
		-- When asserted, the content of the buffer was lost.
		-- When empty is deasserted the next time, a packet size must be read out.
		-- The data of the packet previously being read out is not available anymore then.
		rx_reset_o       : out   std_ulogic;
		rx_empty_o       : out   std_ulogic;
		rx_rd_en_i       : in    std_ulogic;
		rx_data_o        : out   t_ethernet_data
	);
end entity;

architecture rtl of ethernet_with_fifos is
	signal mac_reset : std_ulogic := '1';

	signal mac_tx_reset         : std_ulogic := '1';
	signal mac_tx_clock         : std_ulogic;
	signal mac_tx_enable        : std_ulogic := '0';
	signal mac_tx_data          : t_ethernet_data;
	signal mac_tx_byte_sent     : std_ulogic;
	signal mac_tx_busy          : std_ulogic;
	signal mac_tx_busy_int      : std_ulogic;
	signal mac_rx_reset         : std_ulogic := '1';
	signal mac_rx_clock         : std_ulogic;
	signal mac_rx_frame         : std_ulogic;
	signal mac_rx_data          : t_ethernet_data;
	signal mac_rx_byte_received : std_ulogic;
	signal mac_rx_error         : std_ulogic;

begin

	-- Needed for correct simulation of the inter-packet gap
	-- Without any delay, tx_fifo_adapter would see the tx_busy indication too early
	-- This generally applies to all signals, but the behavior of the other ones
	-- does not cause simulation mismatches.
	mac_tx_busy <= transport mac_tx_busy_int after 1 ns;

	-- Synchronize user resets
	sync_tx_reset_inst : entity work.single_signal_synchronizer
		port map(
			clock_target_i => tx_clock_i,
			signal_i       => mac_reset,
			signal_o       => tx_reset_o
		);

	sync_rx_reset_inst : entity work.single_signal_synchronizer
		port map(
			clock_target_i => rx_clock_i,
			signal_i       => mac_reset,
			signal_o       => rx_reset_o
		);

	ethernet_inst : entity work.ethernet
		generic map(
			MIIM_PHY_ADDRESS      => MIIM_PHY_ADDRESS,
			MIIM_RESET_WAIT_TICKS => MIIM_RESET_WAIT_TICKS,
			MIIM_POLL_WAIT_TICKS  => MIIM_POLL_WAIT_TICKS,
			MIIM_CLOCK_DIVIDER    => MIIM_CLOCK_DIVIDER,
			MIIM_DISABLE          => MIIM_DISABLE
		)
		port map(
			clock_125_i        => clock_125_i,
			reset_i            => reset_i,
			reset_o            => mac_reset,
			mac_address_i      => mac_address_i,
			mii_tx_clk_i       => mii_tx_clk_i,
			mii_tx_er_o        => mii_tx_er_o,
			mii_tx_en_o        => mii_tx_en_o,
			mii_txd_o          => mii_txd_o,
			mii_rx_clk_i       => mii_rx_clk_i,
			mii_rx_er_i        => mii_rx_er_i,
			mii_rx_dv_i        => mii_rx_dv_i,
			mii_rxd_i          => mii_rxd_i,
			gmii_gtx_clk_o     => gmii_gtx_clk_o,
			rgmii_tx_ctl_o     => rgmii_tx_ctl_o,
			rgmii_rx_ctl_i     => rgmii_rx_ctl_i,
			miim_clock_i       => miim_clock_i,
			mdc_o              => mdc_o,
			mdio_io            => mdio_io,
			tx_reset_o         => mac_tx_reset,
			tx_clock_o         => mac_tx_clock,
			tx_enable_i        => mac_tx_enable,
			tx_data_i          => mac_tx_data,
			tx_byte_sent_o     => mac_tx_byte_sent,
			tx_busy_o          => mac_tx_busy_int,
			rx_reset_o         => mac_rx_reset,
			rx_clock_o         => mac_rx_clock,
			rx_frame_o         => mac_rx_frame,
			rx_data_o          => mac_rx_data,
			rx_byte_received_o => mac_rx_byte_received,
			rx_error_o         => mac_rx_error,
			link_up_o          => link_up_o,
			speed_o            => speed_o,
			speed_override_i   => speed_override_i
		);

	rx_fifo_inst : entity work.rx_fifo
		generic map(
			MEMORY_SIZE_BITS => RX_FIFO_SIZE_BITS
		)
		port map(
			clock_i                => rx_clock_i,
			mac_rx_reset_i         => mac_rx_reset,
			mac_rx_clock_i         => mac_rx_clock,
			mac_rx_frame_i         => mac_rx_frame,
			mac_rx_data_i          => mac_rx_data,
			mac_rx_byte_received_i => mac_rx_byte_received,
			mac_rx_error_i         => mac_rx_error,
			empty_o                => rx_empty_o,
			rd_en_i                => rx_rd_en_i,
			data_o                 => rx_data_o
		);

	tx_fifo_inst : entity work.tx_fifo
		port map(
			clock_i            => tx_clock_i,
			data_i             => tx_data_i,
			wr_en_i            => tx_wr_en_i,
			full_o             => tx_full_o,
			mac_tx_reset_i     => mac_tx_reset,
			mac_tx_clock_i     => mac_tx_clock,
			mac_tx_enable_o    => mac_tx_enable,
			mac_tx_data_o      => mac_tx_data,
			mac_tx_byte_sent_i => mac_tx_byte_sent,
			mac_tx_busy_i      => mac_tx_busy
		);

end architecture;

