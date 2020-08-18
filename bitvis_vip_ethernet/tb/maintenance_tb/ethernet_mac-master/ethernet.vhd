-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

library ieee;
use ieee.std_logic_1164.all;

-- Prebuilt Ethernet MAC without FIFOs

use work.ethernet_types.all;
use work.miim_types.all;

entity ethernet is
	generic(
		MIIM_PHY_ADDRESS      : t_phy_address := (others => '0');
		MIIM_RESET_WAIT_TICKS : natural       := 0;
		MIIM_POLL_WAIT_TICKS  : natural       := DEFAULT_POLL_WAIT_TICKS;
		MIIM_CLOCK_DIVIDER    : positive      := 50;
		-- You need to supply the current speed via speed_override when MIIM is disabled
		MIIM_DISABLE          : boolean       := FALSE
	);
	port(
		clock_125_i        : in    std_ulogic;
		-- Reset input synchronous to miim_clock_i
		reset_i            : in    std_ulogic;
		-- Asynchronous reset output
		-- Reset may be asserted when the speed changes to get the system
		-- back to a defined state (glitches might occur on the clock)
		reset_o            : out   std_ulogic;

		-- MAC address of this station
		-- Must not change after reset is deasserted
		mac_address_i      : in    t_mac_address;

		-- MII (Media-independent interface)
		mii_tx_clk_i       : in    std_ulogic;
		mii_tx_er_o        : out   std_ulogic;
		mii_tx_en_o        : out   std_ulogic;
		mii_txd_o          : out   std_ulogic_vector(7 downto 0);
		mii_rx_clk_i       : in    std_ulogic;
		mii_rx_er_i        : in    std_ulogic;
		mii_rx_dv_i        : in    std_ulogic;
		mii_rxd_i          : in    std_ulogic_vector(7 downto 0);

		-- GMII (Gigabit media-independent interface)
		gmii_gtx_clk_o     : out   std_ulogic;

		-- RGMII (Reduced pin count gigabit media-independent interface)
		rgmii_tx_ctl_o     : out   std_ulogic;
		rgmii_rx_ctl_i     : in    std_ulogic;

		-- MII Management Interface
		miim_clock_i       : in    std_ulogic;
		mdc_o              : out   std_ulogic;
		mdio_io            : inout std_ulogic;
		-- Status, synchronous to miim_clock_i
		link_up_o          : out   std_ulogic;
		speed_o            : out   t_ethernet_speed;
		-- Also synchronous to miim_clock_i if used!
		speed_override_i   : in    t_ethernet_speed := SPEED_UNSPECIFIED;

		-- TX from client logic
		tx_clock_o         : out   std_ulogic;
		-- Asynchronous reset that deasserts synchronously to tx_clock_o
		tx_reset_o         : out   std_ulogic;
		tx_enable_i        : in    std_ulogic;
		tx_data_i          : in    t_ethernet_data;
		tx_byte_sent_o     : out   std_ulogic;
		tx_busy_o          : out   std_ulogic;

		-- RX to client logic 
		rx_clock_o         : out   std_ulogic;
		-- Asynchronous reset that deasserts synchronously to rx_clock_o
		rx_reset_o         : out   std_ulogic;
		rx_frame_o         : out   std_ulogic;
		rx_data_o          : out   t_ethernet_data;
		rx_byte_received_o : out   std_ulogic;
		rx_error_o         : out   std_ulogic
	);
end entity;

architecture rtl of ethernet is
	signal tx_clock : std_ulogic;
	signal rx_clock : std_ulogic;

	signal reset    : std_ulogic := '1';
	signal rx_reset : std_ulogic;
	signal tx_reset : std_ulogic;

	-- Interface between mii_gmii and framing
	signal mac_tx_enable        : std_ulogic := '0';
	signal mac_tx_data          : t_ethernet_data;
	signal mac_tx_byte_sent     : std_ulogic;
	signal mac_tx_gap           : std_ulogic;
	signal mac_rx_frame         : std_ulogic;
	signal mac_rx_data          : t_ethernet_data;
	signal mac_rx_byte_received : std_ulogic;
	signal mac_rx_error         : std_ulogic;

	-- Internal MII bus between mii_gmii and mii_gmii_io
	signal int_mii_tx_en : std_ulogic;
	signal int_mii_txd   : std_ulogic_vector(7 downto 0);
	signal int_mii_rx_er : std_ulogic;
	signal int_mii_rx_dv : std_ulogic;
	signal int_mii_rxd   : std_ulogic_vector(7 downto 0);

	-- MIIM interconnection signals
	signal miim_register_address : t_register_address;
	signal miim_phy_address_sig  : t_phy_address;
	signal miim_data_read        : t_data;
	signal miim_data_write       : t_data;
	signal miim_req              : std_ulogic;
	signal miim_ack              : std_ulogic;
	signal miim_wr_en            : std_ulogic;
	signal miim_speed            : t_ethernet_speed;
	signal speed                 : t_ethernet_speed;
	signal link_up               : std_ulogic;
begin
	reset_o    <= reset;
	rx_reset_o <= rx_reset;
	tx_reset_o <= tx_reset;
	tx_clock_o <= tx_clock;
	rx_clock_o <= rx_clock;

	link_up_o            <= link_up;
	speed_o              <= speed;
	miim_phy_address_sig <= MIIM_PHY_ADDRESS;
	-- Errors are never transmitted in full-duplex mode
	mii_tx_er_o          <= '0';

	with speed_override_i select speed <=
		miim_speed when SPEED_UNSPECIFIED,
		speed_override_i when others;

	-- Generate MAC reset if necessary
	reset_generator_inst : entity work.reset_generator
		port map(
			clock_i => miim_clock_i,
			speed_i => speed,
			reset_i => reset_i,
			reset_o => reset
		);

	-- Bring reset into RX and TX clock domains, using:
	-- * Asynchronous assertion of reset to guarantee resetting even when the MII clock is not running
	-- * Synchronous deassertion of reset to guarantee meeting the reset recovery time of the flip flops
	sync_rx_reset_inst : entity work.single_signal_synchronizer
		port map(
			clock_target_i => rx_clock,
			preset_i       => reset,
			signal_i       => '0',
			signal_o       => rx_reset
		);

	sync_tx_reset_inst : entity work.single_signal_synchronizer
		port map(
			clock_target_i => tx_clock,
			preset_i       => reset,
			signal_i       => '0',
			signal_o       => tx_reset
		);

	mii_gmii_inst : entity work.mii_gmii
		port map(
			rx_reset_i         => rx_reset,
			rx_clock_i         => rx_clock,
			tx_reset_i         => tx_reset,
			tx_clock_i         => tx_clock,

			-- MII (Media-independent interface)
			mii_tx_en_o        => int_mii_tx_en,
			mii_txd_o          => int_mii_txd,
			mii_rx_er_i        => int_mii_rx_er,
			mii_rx_dv_i        => int_mii_rx_dv,
			mii_rxd_i          => int_mii_rxd,

			-- RGMII (Reduced pin count gigabit media-independent interface)
			rgmii_tx_ctl_o     => open,
			rgmii_rx_ctl_i     => '0',

			-- Interface control signals
			speed_select_i     => speed,
			tx_enable_i        => mac_tx_enable,
			tx_gap_i           => mac_tx_gap,
			tx_data_i          => mac_tx_data,
			tx_byte_sent_o     => mac_tx_byte_sent,
			rx_frame_o         => mac_rx_frame,
			rx_data_o          => mac_rx_data,
			rx_byte_received_o => mac_rx_byte_received,
			rx_error_o         => mac_rx_error
		);

	mii_gmii_io_inst : entity work.mii_gmii_io
		port map(
			clock_125_i     => clock_125_i,
			clock_tx_o      => tx_clock,
			clock_rx_o      => rx_clock,
			speed_select_i  => speed,
			mii_tx_clk_i    => mii_tx_clk_i,
			mii_tx_en_o     => mii_tx_en_o,
			mii_txd_o       => mii_txd_o,
			mii_rx_clk_i    => mii_rx_clk_i,
			mii_rx_er_i     => mii_rx_er_i,
			mii_rx_dv_i     => mii_rx_dv_i,
			mii_rxd_i       => mii_rxd_i,
			gmii_gtx_clk_o  => gmii_gtx_clk_o,
			int_mii_tx_en_i => int_mii_tx_en,
			int_mii_txd_i   => int_mii_txd,
			int_mii_rx_er_o => int_mii_rx_er,
			int_mii_rx_dv_o => int_mii_rx_dv,
			int_mii_rxd_o   => int_mii_rxd
		);

	framing_inst : entity work.framing
		port map(
			rx_reset_i             => rx_reset,
			tx_clock_i             => tx_clock,
			tx_reset_i             => tx_reset,
			rx_clock_i             => rx_clock,
			mac_address_i          => mac_address_i,
			tx_enable_i            => tx_enable_i,
			tx_data_i              => tx_data_i,
			tx_byte_sent_o         => tx_byte_sent_o,
			tx_busy_o              => tx_busy_o,
			rx_frame_o             => rx_frame_o,
			rx_data_o              => rx_data_o,
			rx_byte_received_o     => rx_byte_received_o,
			rx_error_o             => rx_error_o,
			mii_tx_enable_o        => mac_tx_enable,
			mii_tx_gap_o           => mac_tx_gap,
			mii_tx_data_o          => mac_tx_data,
			mii_tx_byte_sent_i     => mac_tx_byte_sent,
			mii_rx_frame_i         => mac_rx_frame,
			mii_rx_data_i          => mac_rx_data,
			mii_rx_byte_received_i => mac_rx_byte_received,
			mii_rx_error_i         => mac_rx_error
		);

	miim_gen : if MIIM_DISABLE = FALSE generate
		miim_inst : entity work.miim
			generic map(
				CLOCK_DIVIDER => MIIM_CLOCK_DIVIDER
			)
			port map(
				reset_i            => reset_i,
				clock_i            => miim_clock_i,
				register_address_i => miim_register_address,
				phy_address_i      => miim_phy_address_sig,
				data_read_o        => miim_data_read,
				data_write_i       => miim_data_write,
				req_i              => miim_req,
				ack_o              => miim_ack,
				wr_en_i            => miim_wr_en,
				mdc_o              => mdc_o,
				mdio_io            => mdio_io
			);

		miim_control_inst : entity work.miim_control
			generic map(
				RESET_WAIT_TICKS => MIIM_RESET_WAIT_TICKS,
				POLL_WAIT_TICKS  => MIIM_POLL_WAIT_TICKS,
				DEBUG_OUTPUT     => FALSE
			)
			port map(
				reset_i                 => reset_i,
				clock_i                 => miim_clock_i,
				miim_register_address_o => miim_register_address,
				miim_data_read_i        => miim_data_read,
				miim_data_write_o       => miim_data_write,
				miim_req_o              => miim_req,
				miim_ack_i              => miim_ack,
				miim_we_o               => miim_wr_en,
				link_up_o               => link_up,
				speed_o                 => miim_speed,
				debug_fifo_we_o         => open,
				debug_fifo_write_data_o => open
			);
	end generate;
end architecture;

