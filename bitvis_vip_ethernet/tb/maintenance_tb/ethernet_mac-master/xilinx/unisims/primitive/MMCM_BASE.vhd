-------------------------------------------------------
--  Copyright (c) 2008 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : MMCM_BASE.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  03/22/10 - Change CLKFBOUT_MULT_F default to 5 (554618)
--  03/23/10 - Add SIM_DEVICE attribute.
--  07/22/10 - Remove SIM_DEVICE attribute.
-------------------------------------------------------

----- CELL MMCM_BASE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity MMCM_BASE is
    generic (
      BANDWIDTH : string := "OPTIMIZED";
      CLKFBOUT_MULT_F : real := 5.000;
      CLKFBOUT_PHASE : real := 0.000;
      CLKIN1_PERIOD : real := 0.000;
      CLKOUT0_DIVIDE_F : real := 1.000;
      CLKOUT0_DUTY_CYCLE : real := 0.500;
      CLKOUT0_PHASE : real := 0.000;
      CLKOUT1_DIVIDE : integer := 1;
      CLKOUT1_DUTY_CYCLE : real := 0.500;
      CLKOUT1_PHASE : real := 0.000;
      CLKOUT2_DIVIDE : integer := 1;
      CLKOUT2_DUTY_CYCLE : real := 0.500;
      CLKOUT2_PHASE : real := 0.000;
      CLKOUT3_DIVIDE : integer := 1;
      CLKOUT3_DUTY_CYCLE : real := 0.500;
      CLKOUT3_PHASE : real := 0.000;
      CLKOUT4_CASCADE : boolean := FALSE;
      CLKOUT4_DIVIDE : integer := 1;
      CLKOUT4_DUTY_CYCLE : real := 0.500;
      CLKOUT4_PHASE : real := 0.000;
      CLKOUT5_DIVIDE : integer := 1;
      CLKOUT5_DUTY_CYCLE : real := 0.500;
      CLKOUT5_PHASE : real := 0.000;
      CLKOUT6_DIVIDE : integer := 1;
      CLKOUT6_DUTY_CYCLE : real := 0.500;
      CLKOUT6_PHASE : real := 0.000;
      CLOCK_HOLD : boolean := FALSE;
      DIVCLK_DIVIDE : integer := 1;
      REF_JITTER1 : real := 0.010;
      STARTUP_WAIT : boolean := FALSE
    );

    port (
      CLKFBOUT             : out std_ulogic;
      CLKFBOUTB            : out std_ulogic;
      CLKOUT0              : out std_ulogic;
      CLKOUT0B             : out std_ulogic;
      CLKOUT1              : out std_ulogic;
      CLKOUT1B             : out std_ulogic;
      CLKOUT2              : out std_ulogic;
      CLKOUT2B             : out std_ulogic;
      CLKOUT3              : out std_ulogic;
      CLKOUT3B             : out std_ulogic;
      CLKOUT4              : out std_ulogic;
      CLKOUT5              : out std_ulogic;
      CLKOUT6              : out std_ulogic;
      LOCKED               : out std_ulogic;
      CLKFBIN              : in std_ulogic;
      CLKIN1               : in std_ulogic;
      PWRDWN               : in std_ulogic;
      RST                  : in std_ulogic      
    );

  end MMCM_BASE;

  architecture MMCM_BASE_V of MMCM_BASE is
    
    signal  z1 : std_ulogic := '1';
    signal  z0 : std_ulogic := '0';
    signal  z7 : std_logic_vector(6 downto 0) := "0000000";
    signal  z16 : std_logic_vector(15 downto 0) := "0000000000000000";
    signal  OPEN0 : std_ulogic;
    signal  OPEN1 : std_ulogic;
    signal  OPEN2 : std_ulogic;
    signal  OPEN3 : std_ulogic;
    signal  OPEN4 : std_ulogic;
    signal  OPEN16 : std_logic_vector(15 downto 0);

  begin

    MMCM_ADV_inst : MMCM_ADV
        generic map (
                BANDWIDTH => BANDWIDTH,
                CLKFBOUT_MULT_F => CLKFBOUT_MULT_F,
                CLKFBOUT_PHASE => CLKFBOUT_PHASE,
                CLKIN1_PERIOD => CLKIN1_PERIOD,
                CLKIN2_PERIOD => 10.0,
                CLKOUT0_DIVIDE_F => CLKOUT0_DIVIDE_F,
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
                CLKOUT4_CASCADE => CLKOUT4_CASCADE,
                CLKOUT4_DIVIDE => CLKOUT4_DIVIDE,
                CLKOUT4_DUTY_CYCLE => CLKOUT4_DUTY_CYCLE,
                CLKOUT4_PHASE => CLKOUT4_PHASE,
                CLKOUT5_DIVIDE => CLKOUT5_DIVIDE,
                CLKOUT5_DUTY_CYCLE => CLKOUT5_DUTY_CYCLE,
                CLKOUT5_PHASE => CLKOUT5_PHASE,
                CLKOUT6_DIVIDE => CLKOUT6_DIVIDE,
                CLKOUT6_DUTY_CYCLE => CLKOUT6_DUTY_CYCLE,
                CLKOUT6_PHASE => CLKOUT6_PHASE,
                CLOCK_HOLD => CLOCK_HOLD,
                DIVCLK_DIVIDE => DIVCLK_DIVIDE,
                REF_JITTER1 => REF_JITTER1,
                STARTUP_WAIT => STARTUP_WAIT
    )

    port map (
                CLKFBOUT => CLKFBOUT,
                CLKFBOUTB => CLKFBOUTB,
                CLKFBSTOPPED => OPEN1,
                CLKINSTOPPED => OPEN2,
                CLKOUT0 => CLKOUT0,
                CLKOUT0B => CLKOUT0B,
                CLKOUT1 => CLKOUT1,
                CLKOUT1B => CLKOUT1B,
                CLKOUT2 => CLKOUT2,
                CLKOUT2B => CLKOUT2B,
                CLKOUT3 => CLKOUT3,
                CLKOUT3B => CLKOUT3B,
                CLKOUT4 => CLKOUT4,
                CLKOUT5 => CLKOUT5,
                CLKOUT6 => CLKOUT6,
                DO => OPEN16,
                DRDY => OPEN3,
                PSDONE => OPEN4,
                LOCKED => LOCKED,
                CLKFBIN => CLKFBIN,
                CLKIN1 => CLKIN1,
                CLKIN2 => z0,
                CLKINSEL => z1,
                DADDR => z7,
                DCLK => z0,
                DEN => z0,
                DI => z16,
                DWE => z0,
                PSCLK => z0,
                PSEN => z0,
                PSINCDEC => z0,
                PWRDWN => PWRDWN,
                RST => RST
    );

  end MMCM_BASE_V;
