-- This file is part of the ethernet_mac project.
--
-- For the full copyright and license information, please read the
-- LICENSE.md file that was distributed with this source code.

-- Apply a fixed delay to an input pin using IODELAY2

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity fixed_input_delay is
	generic(
		IDELAY_VALUE : natural range 0 to 255 := 0
	);
	port(
		pad_i     : in  std_ulogic;
		delayed_o : out std_ulogic
	);
end entity;

architecture spartan_6 of fixed_input_delay is
begin
	mii_rx_dv_IODELAY2_inst : IODELAY2
		generic map(
			COUNTER_WRAPAROUND => "WRAPAROUND", -- "STAY_AT_LIMIT" or "WRAPAROUND" 
			DATA_RATE          => "SDR", -- "SDR" or "DDR" 
			DELAY_SRC          => "IDATAIN", -- "IO", "ODATAIN" or "IDATAIN" 
			IDELAY2_VALUE      => 0,    -- Delay value when IDELAY_MODE="PCI" (0-255)
			IDELAY_MODE        => "NORMAL", -- "NORMAL" or "PCI" 
			IDELAY_TYPE        => "FIXED", -- "FIXED", "DEFAULT", "VARIABLE_FROM_ZERO", "VARIABLE_FROM_HALF_MAX" 
			-- or "DIFF_PHASE_DETECTOR" 
			IDELAY_VALUE       => IDELAY_VALUE, -- Amount of taps for fixed input delay (0-255)
			ODELAY_VALUE       => 0,    -- Amount of taps fixed output delay (0-255)
			SERDES_MODE        => "NONE", -- "NONE", "MASTER" or "SLAVE" 
			SIM_TAPDELAY_VALUE => 75    -- Per tap delay used for simulation in ps
		)
		port map(
			BUSY     => open,           -- 1-bit output: Busy output after CAL
			DATAOUT  => delayed_o,      -- 1-bit output: Delayed data output to ISERDES/input register
			DATAOUT2 => open,           -- 1-bit output: Delayed data output to general FPGA fabric
			DOUT     => open,           -- 1-bit output: Delayed data output
			TOUT     => open,           -- 1-bit output: Delayed 3-state output
			CAL      => '0',            -- 1-bit input: Initiate calibration input
			CE       => '0',            -- 1-bit input: Enable INC input
			CLK      => '0',            -- 1-bit input: Clock input
			IDATAIN  => pad_i,          -- 1-bit input: Data input (connect to top-level port or I/O buffer)
			INC      => '0',            -- 1-bit input: Increment / decrement input
			IOCLK0   => '0',            -- 1-bit input: Input from the I/O clock network
			IOCLK1   => '0',            -- 1-bit input: Input from the I/O clock network
			ODATAIN  => '0',            -- 1-bit input: Output data input from output register or OSERDES2.
			RST      => '0',            -- 1-bit input: Reset to zero or 1/2 of total delay period
			T        => '1'             -- 1-bit input: 3-state input signal
		);

end architecture;

