-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Instantiate test_mirror and add Spartan 6-specific clock buffering

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ethernet_types.all;
use work.test_common.all;

library unisim;
use unisim.vcomponents.all;

entity test_instance_spartan6 is
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

		test_mode_i      : in  std_ulogic_vector(1 downto 0)
	);
end entity;

architecture rtl of test_instance_spartan6 is
	signal clock_125            : std_ulogic;
	signal clock_125_unbuffered : std_ulogic;
	signal locked               : std_ulogic;
	signal reset                : std_ulogic;
	signal test_mode            : t_test_mode;
begin
	reset                             <= reset_i or (not locked);
	with test_mode_i select test_mode <=
		TEST_LOOPBACK when "01",
		TEST_TX_PADDING when "10",
		TEST_NOTHING when others;

	clock_125_BUFG_inst : BUFG
		port map(
			O => clock_125,             -- 1-bit output: Clock buffer output
			I => clock_125_unbuffered   -- 1-bit input: Clock buffer input
		);

	DCM_SP_inst : DCM_SP
		generic map(
			CLKDV_DIVIDE          => 5.0, -- CLKDV divide value
			-- (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
			CLKFX_DIVIDE          => 5, -- Divide value on CLKFX outputs - D - (1-32)
			CLKFX_MULTIPLY        => 2, -- Multiply value on CLKFX outputs - M - (2-32)
			CLKIN_DIVIDE_BY_2     => FALSE, -- CLKIN divide by two (TRUE/FALSE)
			CLKIN_PERIOD          => 8.0, -- Input clock period specified in nS
			CLKOUT_PHASE_SHIFT    => "NONE", -- Output phase shift (NONE, FIXED, VARIABLE)
			CLK_FEEDBACK          => "1X", -- Feedback source (NONE, 1X, 2X)
			DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS", -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
			DFS_FREQUENCY_MODE    => "LOW", -- Unsupported - Do not change value
			DLL_FREQUENCY_MODE    => "LOW", -- Unsupported - Do not change value
			DSS_MODE              => "NONE", -- Unsupported - Do not change value
			DUTY_CYCLE_CORRECTION => TRUE, -- Unsupported - Do not change value
			FACTORY_JF            => X"c080", -- Unsupported - Do not change value
			PHASE_SHIFT           => 0, -- Amount of fixed phase shift (-255 to 255)
			STARTUP_WAIT          => FALSE -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
		)
		port map(
			CLK0     => clock_125_unbuffered, -- 1-bit output: 0 degree clock output
			CLK180   => open,           -- 1-bit output: 180 degree clock output
			CLK270   => open,           -- 1-bit output: 270 degree clock output
			CLK2X    => open,           -- 1-bit output: 2X clock frequency clock output
			CLK2X180 => open,           -- 1-bit output: 2X clock frequency, 180 degree clock output
			CLK90    => open,           -- 1-bit output: 90 degree clock output
			CLKDV    => open,           -- 1-bit output: Divided clock output
			CLKFX    => open,           -- 1-bit output: Digital Frequency Synthesizer output (DFS)
			CLKFX180 => open,           -- 1-bit output: 180 degree CLKFX output
			LOCKED   => locked,         -- 1-bit output: DCM_SP Lock Output
			PSDONE   => open,           -- 1-bit output: Phase shift done output
			STATUS   => open,           -- 8-bit output: DCM_SP status output
			CLKFB    => clock_125_unbuffered, -- 1-bit input: Clock feedback input
			CLKIN    => clock_125_i,    -- 1-bit input: Clock input
			DSSEN    => '0',            -- 1-bit input: Unsupported, specify to GND.
			PSCLK    => '0',            -- 1-bit input: Phase shift clock input
			PSEN     => '0',            -- 1-bit input: Phase shift enable
			PSINCDEC => '0',            -- 1-bit input: Phase shift increment/decrement input
			RST      => '0'             -- 1-bit input: Active high reset input
		);

	test_instance_inst : entity work.test_instance
		port map(
			clock_125_i      => clock_125_unbuffered,
			user_clock_i     => clock_125,
			reset_i          => reset,
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
			speed_override_i => speed_override_i,
			test_mode_i      => test_mode
		);

end architecture;

