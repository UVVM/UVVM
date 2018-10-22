-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- ethernet_with_fifos wrapped with an application that just loops all incoming packets back

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utility.all;
use work.ethernet_types.all;
use work.framing_common.all;
use work.test_common.all;

entity test_instance is
	port(
		clock_125_i      : in  std_ulogic;
		-- Clock used for FIFOs and MIIM
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

		-- Test type
		test_mode_i      : in  t_test_mode
	);
end entity;

architecture rtl of test_instance is
	signal rx_empty : std_ulogic;
	signal tx_full  : std_ulogic;
	
	signal mac_address : t_mac_address;

	-- Connected to ethernet_with_fifos via mux on test_mode_i 
	signal rx_rd_en : std_ulogic := '0';
	signal rx_data  : t_ethernet_data;
	signal tx_data  : t_ethernet_data;
	signal tx_wr_en : std_ulogic := '0';

	-- Signals in TEST_LOOPBACK 
	signal rx_rd_en_loopback : std_ulogic := '0';
	signal tx_data_loopback  : t_ethernet_data;
	signal tx_wr_en_loopback : std_ulogic := '0';
	-- Signals in other test modes
	signal rx_rd_en_sync     : std_ulogic := '0';
	signal tx_data_sync      : t_ethernet_data;
	signal tx_wr_en_sync     : std_ulogic := '0';

	type t_tx_padding_state is (
		TX_PAD_SIZE_HI,
		TX_PAD_SIZE_LO,
		TX_PAD_DATA,
		TX_PAD_DONE
	);
	signal tx_padding_state : t_tx_padding_state := TX_PAD_SIZE_HI;
	signal tx_packet_byte   : integer range 0 to MIN_FRAME_DATA_BYTES;
	signal tx_packet_size   : integer range 0 to MIN_FRAME_DATA_BYTES;
	signal tx_reset : std_ulogic;

begin
	mac_address <= TEST_MAC_ADDRESS;
	
	-- Process for mirroring packets from the RX FIFO to the TX FIFO
	-- Asynchronous to avoid complicated buffering on full/empty conditions
	tx_data_loopback  <= rx_data;
	tx_wr_en_loopback <= not rx_empty and not tx_full;
	rx_rd_en_loopback <= not rx_empty and not tx_full;

	-- Mux for FIFO user signals
	with test_mode_i select rx_rd_en <=
		rx_rd_en_loopback when TEST_LOOPBACK,
		rx_rd_en_sync when TEST_TX_PADDING,
		'0' when others;
	with test_mode_i select tx_wr_en <=
		tx_wr_en_loopback when TEST_LOOPBACK,
		tx_wr_en_sync when TEST_TX_PADDING,
		'0' when others;
	with test_mode_i select tx_data <=
		tx_data_loopback when TEST_LOOPBACK,
		tx_data_sync when others;

	ethernet_with_fifos_inst : entity work.ethernet_with_fifos
		generic map(
			MIIM_DISABLE => TRUE
		)
		port map(
			clock_125_i      => clock_125_i,
			reset_i          => reset_i,
			mac_address_i    => mac_address,
			mii_tx_clk_i     => mii_tx_clk_i,
			mii_tx_er_o      => mii_tx_er_o,
			mii_tx_en_o      => mii_tx_en_o,
			mii_txd_o        => mii_txd_o,
			mii_rx_clk_i     => mii_rx_clk_i,
			mii_rx_er_i      => mii_rx_er_i,
			mii_rx_dv_i      => mii_rx_dv_i,
			mii_rxd_i        => mii_rxd_i,
			gmii_gtx_clk_o   => gmii_gtx_clk_o,
			rgmii_tx_ctl_o   => rgmii_tx_ctl_o,
			rgmii_rx_ctl_i   => rgmii_rx_ctl_i,
			miim_clock_i     => user_clock_i,
			speed_override_i => speed_override_i,
			rx_clock_i       => user_clock_i,
			rx_empty_o       => rx_empty,
			rx_rd_en_i       => rx_rd_en,
			rx_data_o        => rx_data,
			tx_clock_i       => user_clock_i,
			tx_data_i        => tx_data,
			tx_wr_en_i       => tx_wr_en,
			tx_full_o        => tx_full,
			tx_reset_o       => tx_reset
		);

	-- Process for synchronous test modes
	-- Currently only TEST_TX_PADDING
	test_proc : process(user_clock_i)
	begin
		if rising_edge(user_clock_i) then
			rx_rd_en_sync <= '0';

			if test_mode_i = TEST_TX_PADDING and tx_reset = '0' then
				tx_wr_en_sync <= '1';
				case tx_padding_state is
					when TX_PAD_SIZE_HI =>
						tx_data_sync     <= (others => '0');
						tx_padding_state <= TX_PAD_SIZE_LO;
					when TX_PAD_SIZE_LO =>
						tx_data_sync     <= t_ethernet_data(to_unsigned(tx_packet_size, 8));
						tx_padding_state <= TX_PAD_DATA;
						tx_packet_byte   <= 0;
					when TX_PAD_DATA =>
						tx_data_sync <= t_ethernet_data(to_unsigned(tx_packet_byte + 1, 8));
						if tx_packet_byte = tx_packet_size - 1 then
							if tx_packet_size = MIN_FRAME_DATA_BYTES - 1 then
								-- Last size (59)
								tx_padding_state <= TX_PAD_DONE;
							else
								-- Last byte of the current packet
								tx_packet_size   <= tx_packet_size + 1;
								tx_padding_state <= TX_PAD_SIZE_HI;
							end if;
						else
							tx_packet_byte <= tx_packet_byte + 1;
						end if;
					when TX_PAD_DONE =>
						tx_wr_en_sync <= '0';
				end case;
			else
				-- Reset
				tx_padding_state <= TX_PAD_SIZE_HI;
				tx_packet_size   <= 1;
				tx_wr_en_sync    <= '0';
			end if;
		end if;
	end process;

end architecture;
