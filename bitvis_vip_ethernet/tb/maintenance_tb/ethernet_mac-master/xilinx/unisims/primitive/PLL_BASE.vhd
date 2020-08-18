-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/PLL_BASE.vhd,v 1.3 2009/08/22 00:26:01 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                 Phase Lock Loop Clock 
-- /___/   /\     Filename : PLL_BASE.vhd
-- \   \  /  \    Timestamp : 
--  \___\/\___\
-- Revision:
--    12/02/05 - Initial version.
--    02/26/09 - Add CLK_FEEDBACK attribute for Spartan6.
-- End Revision


----- CELL PLL_BASE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library unisim;
use unisim.vpkg.all;
use unisim.VCOMPONENTS.all;

entity PLL_BASE is
generic (
		BANDWIDTH : string := "OPTIMIZED";
		CLKFBOUT_MULT : integer := 1;
		CLKFBOUT_PHASE : real := 0.0;
		CLKIN_PERIOD : real := 0.000;
		CLKOUT0_DIVIDE : integer := 1;
		CLKOUT0_DUTY_CYCLE : real := 0.5;
		CLKOUT0_PHASE : real := 0.0;
		CLKOUT1_DIVIDE : integer := 1;
		CLKOUT1_DUTY_CYCLE : real := 0.5;
		CLKOUT1_PHASE : real := 0.0;
		CLKOUT2_DIVIDE : integer := 1;
		CLKOUT2_DUTY_CYCLE : real := 0.5;
		CLKOUT2_PHASE : real := 0.0;
		CLKOUT3_DIVIDE : integer := 1;
		CLKOUT3_DUTY_CYCLE : real := 0.5;
		CLKOUT3_PHASE : real := 0.0;
		CLKOUT4_DIVIDE : integer := 1;
		CLKOUT4_DUTY_CYCLE : real := 0.5;
		CLKOUT4_PHASE : real := 0.0;
		CLKOUT5_DIVIDE : integer := 1;
		CLKOUT5_DUTY_CYCLE : real := 0.5;
		CLKOUT5_PHASE : real := 0.0;
      CLK_FEEDBACK : string := "CLKFBOUT";
		COMPENSATION : string := "SYSTEM_SYNCHRONOUS";
      DIVCLK_DIVIDE : integer := 1;
		REF_JITTER : real := 0.100;
		RESET_ON_LOSS_OF_LOCK : boolean := FALSE


  );

port (
		CLKFBOUT : out std_ulogic;
		CLKOUT0 : out std_ulogic;
		CLKOUT1 : out std_ulogic;
		CLKOUT2 : out std_ulogic;
		CLKOUT3 : out std_ulogic;
		CLKOUT4 : out std_ulogic;
		CLKOUT5 : out std_ulogic;
		LOCKED : out std_ulogic;

		CLKFBIN : in std_ulogic;
		CLKIN : in std_ulogic;
		RST : in std_ulogic
     );
end PLL_BASE;

-- Architecture body --

architecture PLL_BASE_V of PLL_BASE is

signal  h1 : std_ulogic := '1';
signal  z1 : std_ulogic := '0';
signal  z5 : std_logic_vector(4 downto 0) := "00000";
signal  z16 : std_logic_vector(15 downto 0) := "0000000000000000";
signal  OPEN0 : std_ulogic;
signal  OPEN1 : std_ulogic;
signal  OPEN2 : std_ulogic;
signal  OPEN3 : std_ulogic;
signal  OPEN4 : std_ulogic;
signal  OPEN5 : std_ulogic;
signal  OPEN6 : std_ulogic;
signal  OPEN7 : std_ulogic;
signal  OPEN16 : std_logic_vector(15 downto 0);

begin
-- PLL_ADV Instantiation (port map, generic map)

PLL_ADV_inst : PLL_ADV
	generic map (
		BANDWIDTH => BANDWIDTH,
		CLKFBOUT_MULT => CLKFBOUT_MULT,
		CLKFBOUT_PHASE => CLKFBOUT_PHASE,
		CLKIN1_PERIOD => CLKIN_PERIOD,
		CLKIN2_PERIOD => 10.0,
		CLKOUT0_DIVIDE => CLKOUT0_DIVIDE,
		CLKOUT0_DUTY_CYCLE => CLKOUT0_DUTY_CYCLE,
		CLKOUT0_PHASE => CLKOUT0_PHASE,
		CLKOUT1_DIVIDE => CLKOUT1_DIVIDE,
		CLKOUT1_DUTY_CYCLE => CLKOUT1_DUTY_CYCLE,
		CLKOUT1_PHASE => CLKOUT1_PHASE,
		CLKOUT2_DIVIDE => CLKOUT2_DIVIDE,
		CLKOUT2_DUTY_CYCLE => CLKOUT2_DUTY_CYCLE,
		CLKOUT2_PHASE => CLKOUT2_PHASE,
		CLKOUT3_DIVIDE => CLKOUT3_DIVIDE,
		CLKOUT3_DUTY_CYCLE => CLKOUT3_DUTY_CYCLE,
		CLKOUT3_PHASE => CLKOUT3_PHASE,
		CLKOUT4_DIVIDE => CLKOUT4_DIVIDE,
		CLKOUT4_DUTY_CYCLE => CLKOUT4_DUTY_CYCLE,
		CLKOUT4_PHASE => CLKOUT4_PHASE,
		CLKOUT5_DIVIDE => CLKOUT5_DIVIDE,
		CLKOUT5_DUTY_CYCLE => CLKOUT5_DUTY_CYCLE,
		CLKOUT5_PHASE => CLKOUT5_PHASE,
      CLK_FEEDBACK => CLK_FEEDBACK,
		COMPENSATION => COMPENSATION,
      DIVCLK_DIVIDE => DIVCLK_DIVIDE,
      EN_REL => FALSE,
      PLL_PMCD_MODE => FALSE,
		REF_JITTER => REF_JITTER,
		RESET_ON_LOSS_OF_LOCK => RESET_ON_LOSS_OF_LOCK, 
      RST_DEASSERT_CLK => "CLKIN1"
)
port map (
		CLKFBDCM => OPEN6,
		CLKFBOUT => CLKFBOUT,
		CLKOUT0 => CLKOUT0,
		CLKOUT1 => CLKOUT1,
		CLKOUT2 => CLKOUT2,
		CLKOUT3 => CLKOUT3,
		CLKOUT4 => CLKOUT4,
		CLKOUT5 => CLKOUT5,
		CLKOUTDCM0 => OPEN0,
		CLKOUTDCM1 => OPEN1,
		CLKOUTDCM2 => OPEN2,
		CLKOUTDCM3 => OPEN3,
		CLKOUTDCM4 => OPEN4,
		CLKOUTDCM5 => OPEN5,
		DO => OPEN16,
		DRDY => OPEN7,
		LOCKED => LOCKED,
		CLKFBIN => CLKFBIN,
		CLKIN1 => CLKIN,
		CLKIN2 => z1,
      CLKINSEL => h1,
      DADDR => z5,
      DCLK => z1,
      DEN => z1,
      DI => z16,
      DWE => z1,
      REL => z1,
		RST => RST
);

end PLL_BASE_V;

