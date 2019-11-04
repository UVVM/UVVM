-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Combination of tx_fifo_adapter with a Xilinx core generator FIFO

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_types.all;

entity tx_fifo is
	port(
		clock_i            : in  std_ulogic;

		data_i             : in  t_ethernet_data;
		wr_en_i            : in  std_ulogic;
		full_o             : out std_ulogic;

		-- Interface to framing layer
		mac_tx_reset_i     : in  std_ulogic;
		mac_tx_clock_i     : in  std_ulogic;
		mac_tx_enable_o    : out std_ulogic;
		mac_tx_data_o      : out t_ethernet_data;
		mac_tx_byte_sent_i : in  std_ulogic;
		mac_tx_busy_i      : in  std_ulogic
	);
end entity;

architecture rtl of tx_fifo is
	signal rd_en         : std_ulogic := '0';
	signal data_out      : std_logic_vector(t_ethernet_data'range);
	signal empty         : std_ulogic := '1';
	-- Intermediate signal needed for conversion between std_logic_vector and std_ulogic_vector
	signal read_count_lv : std_logic_vector(11 downto 0);
	signal read_count    : unsigned(11 downto 0);

begin
	-- Convert type
	read_count <= unsigned(read_count_lv);

	tx_data_fifo_inst : entity work.ethernet_mac_tx_fifo_xilinx
		port map(
			rst           => mac_tx_reset_i,
			wr_clk        => clock_i,
			rd_clk        => mac_tx_clock_i,
			din           => std_logic_vector(data_i),
			wr_en         => wr_en_i,
			rd_en         => rd_en,
			dout          => data_out,
			full          => full_o,
			empty         => empty,
			rd_data_count => read_count_lv
		);

	tx_fifo_adapter_inst : entity work.tx_fifo_adapter
		port map(
			mac_tx_reset_i     => mac_tx_reset_i,
			mac_tx_clock_i     => mac_tx_clock_i,
			mac_tx_enable_o    => mac_tx_enable_o,
			mac_tx_data_o      => mac_tx_data_o,
			mac_tx_byte_sent_i => mac_tx_byte_sent_i,
			mac_tx_busy_i      => mac_tx_busy_i,
			rd_en_o            => rd_en,
			data_i             => std_ulogic_vector(data_out),
			empty_i            => empty,
			read_count_i       => read_count
		);

end architecture;
