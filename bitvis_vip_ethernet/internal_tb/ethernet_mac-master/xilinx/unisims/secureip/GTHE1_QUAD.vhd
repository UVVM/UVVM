-------------------------------------------------------
--  Copyright (c) 2010 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                        Gigabit Transceiver
-- /___/   /\      Filename    : GTHE1_QUAD.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--  05/29/09 - CR523112 - Initial version
--  06/16/09 - CR523112 - Parameter update in YML
--  06/24/09 - CR523112 - YML update
--  07/07/09 - CR526271 - secureip publish
--  07/14/09 - CR527136 - YML update
--  08/13/09 - CR530821 - writer bug - update GTH_CFG_PWRUP_LANE_* bit_vector to bit
--  10/01/09 - CR534680 - YML Attribute updates
--  01/26/10 - CR546178 - YML new output pins & parameter default update
--  02/10/10 - CR543263 - Add new output pin connections in B_GTHE1_QUAD_INST
--  03/22/10 - CR552516 - DRC checks added
--  03/22/11 - CR602582 - YML attribute updates
--  05/16/11 - CR610451 - YML attribute default updates
--  11/16/11 - CR629921 - DRC checks updated
-------------------------------------------------------

----- CELL GTHE1_QUAD -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

library secureip;
use secureip.all;

  entity GTHE1_QUAD is
    generic (
      BER_CONST_PTRN0 : bit_vector := X"0000";
      BER_CONST_PTRN1 : bit_vector := X"0000";
      BUFFER_CONFIG_LANE0 : bit_vector := X"4004";
      BUFFER_CONFIG_LANE1 : bit_vector := X"4004";
      BUFFER_CONFIG_LANE2 : bit_vector := X"4004";
      BUFFER_CONFIG_LANE3 : bit_vector := X"4004";
      DFE_TRAIN_CTRL_LANE0 : bit_vector := X"0000";
      DFE_TRAIN_CTRL_LANE1 : bit_vector := X"0000";
      DFE_TRAIN_CTRL_LANE2 : bit_vector := X"0000";
      DFE_TRAIN_CTRL_LANE3 : bit_vector := X"0000";
      DLL_CFG0 : bit_vector := X"8202";
      DLL_CFG1 : bit_vector := X"0000";
      E10GBASEKR_LD_COEFF_UPD_LANE0 : bit_vector := X"0000";
      E10GBASEKR_LD_COEFF_UPD_LANE1 : bit_vector := X"0000";
      E10GBASEKR_LD_COEFF_UPD_LANE2 : bit_vector := X"0000";
      E10GBASEKR_LD_COEFF_UPD_LANE3 : bit_vector := X"0000";
      E10GBASEKR_LP_COEFF_UPD_LANE0 : bit_vector := X"0000";
      E10GBASEKR_LP_COEFF_UPD_LANE1 : bit_vector := X"0000";
      E10GBASEKR_LP_COEFF_UPD_LANE2 : bit_vector := X"0000";
      E10GBASEKR_LP_COEFF_UPD_LANE3 : bit_vector := X"0000";
      E10GBASEKR_PMA_CTRL_LANE0 : bit_vector := X"0002";
      E10GBASEKR_PMA_CTRL_LANE1 : bit_vector := X"0002";
      E10GBASEKR_PMA_CTRL_LANE2 : bit_vector := X"0002";
      E10GBASEKR_PMA_CTRL_LANE3 : bit_vector := X"0002";
      E10GBASEKX_CTRL_LANE0 : bit_vector := X"0000";
      E10GBASEKX_CTRL_LANE1 : bit_vector := X"0000";
      E10GBASEKX_CTRL_LANE2 : bit_vector := X"0000";
      E10GBASEKX_CTRL_LANE3 : bit_vector := X"0000";
      E10GBASER_PCS_CFG_LANE0 : bit_vector := X"070C";
      E10GBASER_PCS_CFG_LANE1 : bit_vector := X"070C";
      E10GBASER_PCS_CFG_LANE2 : bit_vector := X"070C";
      E10GBASER_PCS_CFG_LANE3 : bit_vector := X"070C";
      E10GBASER_PCS_SEEDA0_LANE0 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDA0_LANE1 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDA0_LANE2 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDA0_LANE3 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDA1_LANE0 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA1_LANE1 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA1_LANE2 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA1_LANE3 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA2_LANE0 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA2_LANE1 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA2_LANE2 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA2_LANE3 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA3_LANE0 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA3_LANE1 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA3_LANE2 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDA3_LANE3 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB0_LANE0 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDB0_LANE1 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDB0_LANE2 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDB0_LANE3 : bit_vector := X"0001";
      E10GBASER_PCS_SEEDB1_LANE0 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB1_LANE1 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB1_LANE2 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB1_LANE3 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB2_LANE0 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB2_LANE1 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB2_LANE2 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB2_LANE3 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB3_LANE0 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB3_LANE1 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB3_LANE2 : bit_vector := X"0000";
      E10GBASER_PCS_SEEDB3_LANE3 : bit_vector := X"0000";
      E10GBASER_PCS_TEST_CTRL_LANE0 : bit_vector := X"0000";
      E10GBASER_PCS_TEST_CTRL_LANE1 : bit_vector := X"0000";
      E10GBASER_PCS_TEST_CTRL_LANE2 : bit_vector := X"0000";
      E10GBASER_PCS_TEST_CTRL_LANE3 : bit_vector := X"0000";
      E10GBASEX_PCS_TSTCTRL_LANE0 : bit_vector := X"0000";
      E10GBASEX_PCS_TSTCTRL_LANE1 : bit_vector := X"0000";
      E10GBASEX_PCS_TSTCTRL_LANE2 : bit_vector := X"0000";
      E10GBASEX_PCS_TSTCTRL_LANE3 : bit_vector := X"0000";
      GLBL0_NOISE_CTRL : bit_vector := X"F0B8";
      GLBL_AMON_SEL : bit_vector := X"0000";
      GLBL_DMON_SEL : bit_vector := X"0200";
      GLBL_PWR_CTRL : bit_vector := X"0000";
      GTH_CFG_PWRUP_LANE0 : bit := '1';
      GTH_CFG_PWRUP_LANE1 : bit := '1';
      GTH_CFG_PWRUP_LANE2 : bit := '1';
      GTH_CFG_PWRUP_LANE3 : bit := '1';
      LANE_AMON_SEL : bit_vector := X"00F0";
      LANE_DMON_SEL : bit_vector := X"0000";
      LANE_LNK_CFGOVRD : bit_vector := X"0000";
      LANE_PWR_CTRL_LANE0 : bit_vector := X"0400";
      LANE_PWR_CTRL_LANE1 : bit_vector := X"0400";
      LANE_PWR_CTRL_LANE2 : bit_vector := X"0400";
      LANE_PWR_CTRL_LANE3 : bit_vector := X"0400";
      LNK_TRN_CFG_LANE0 : bit_vector := X"0000";
      LNK_TRN_CFG_LANE1 : bit_vector := X"0000";
      LNK_TRN_CFG_LANE2 : bit_vector := X"0000";
      LNK_TRN_CFG_LANE3 : bit_vector := X"0000";
      LNK_TRN_COEFF_REQ_LANE0 : bit_vector := X"0000";
      LNK_TRN_COEFF_REQ_LANE1 : bit_vector := X"0000";
      LNK_TRN_COEFF_REQ_LANE2 : bit_vector := X"0000";
      LNK_TRN_COEFF_REQ_LANE3 : bit_vector := X"0000";
      MISC_CFG : bit_vector := X"0008";
      MODE_CFG1 : bit_vector := X"0000";
      MODE_CFG2 : bit_vector := X"0000";
      MODE_CFG3 : bit_vector := X"0000";
      MODE_CFG4 : bit_vector := X"0000";
      MODE_CFG5 : bit_vector := X"0000";
      MODE_CFG6 : bit_vector := X"0000";
      MODE_CFG7 : bit_vector := X"0000";
      PCS_ABILITY_LANE0 : bit_vector := X"0010";
      PCS_ABILITY_LANE1 : bit_vector := X"0010";
      PCS_ABILITY_LANE2 : bit_vector := X"0010";
      PCS_ABILITY_LANE3 : bit_vector := X"0010";
      PCS_CTRL1_LANE0 : bit_vector := X"2040";
      PCS_CTRL1_LANE1 : bit_vector := X"2040";
      PCS_CTRL1_LANE2 : bit_vector := X"2040";
      PCS_CTRL1_LANE3 : bit_vector := X"2040";
      PCS_CTRL2_LANE0 : bit_vector := X"0000";
      PCS_CTRL2_LANE1 : bit_vector := X"0000";
      PCS_CTRL2_LANE2 : bit_vector := X"0000";
      PCS_CTRL2_LANE3 : bit_vector := X"0000";
      PCS_MISC_CFG_0_LANE0 : bit_vector := X"1116";
      PCS_MISC_CFG_0_LANE1 : bit_vector := X"1116";
      PCS_MISC_CFG_0_LANE2 : bit_vector := X"1116";
      PCS_MISC_CFG_0_LANE3 : bit_vector := X"1116";
      PCS_MISC_CFG_1_LANE0 : bit_vector := X"0000";
      PCS_MISC_CFG_1_LANE1 : bit_vector := X"0000";
      PCS_MISC_CFG_1_LANE2 : bit_vector := X"0000";
      PCS_MISC_CFG_1_LANE3 : bit_vector := X"0000";
      PCS_MODE_LANE0 : bit_vector := X"0000";
      PCS_MODE_LANE1 : bit_vector := X"0000";
      PCS_MODE_LANE2 : bit_vector := X"0000";
      PCS_MODE_LANE3 : bit_vector := X"0000";
      PCS_RESET_1_LANE0 : bit_vector := X"0002";
      PCS_RESET_1_LANE1 : bit_vector := X"0002";
      PCS_RESET_1_LANE2 : bit_vector := X"0002";
      PCS_RESET_1_LANE3 : bit_vector := X"0002";
      PCS_RESET_LANE0 : bit_vector := X"0000";
      PCS_RESET_LANE1 : bit_vector := X"0000";
      PCS_RESET_LANE2 : bit_vector := X"0000";
      PCS_RESET_LANE3 : bit_vector := X"0000";
      PCS_TYPE_LANE0 : bit_vector := X"002C";
      PCS_TYPE_LANE1 : bit_vector := X"002C";
      PCS_TYPE_LANE2 : bit_vector := X"002C";
      PCS_TYPE_LANE3 : bit_vector := X"002C";
      PLL_CFG0 : bit_vector := X"95DF";
      PLL_CFG1 : bit_vector := X"81C0";
      PLL_CFG2 : bit_vector := X"0424";
      PMA_CTRL1_LANE0 : bit_vector := X"0000";
      PMA_CTRL1_LANE1 : bit_vector := X"0000";
      PMA_CTRL1_LANE2 : bit_vector := X"0000";
      PMA_CTRL1_LANE3 : bit_vector := X"0000";
      PMA_CTRL2_LANE0 : bit_vector := X"000B";
      PMA_CTRL2_LANE1 : bit_vector := X"000B";
      PMA_CTRL2_LANE2 : bit_vector := X"000B";
      PMA_CTRL2_LANE3 : bit_vector := X"000B";
      PMA_LPBK_CTRL_LANE0 : bit_vector := X"0004";
      PMA_LPBK_CTRL_LANE1 : bit_vector := X"0004";
      PMA_LPBK_CTRL_LANE2 : bit_vector := X"0004";
      PMA_LPBK_CTRL_LANE3 : bit_vector := X"0004";
      PRBS_BER_CFG0_LANE0 : bit_vector := X"0000";
      PRBS_BER_CFG0_LANE1 : bit_vector := X"0000";
      PRBS_BER_CFG0_LANE2 : bit_vector := X"0000";
      PRBS_BER_CFG0_LANE3 : bit_vector := X"0000";
      PRBS_BER_CFG1_LANE0 : bit_vector := X"0000";
      PRBS_BER_CFG1_LANE1 : bit_vector := X"0000";
      PRBS_BER_CFG1_LANE2 : bit_vector := X"0000";
      PRBS_BER_CFG1_LANE3 : bit_vector := X"0000";
      PRBS_CFG_LANE0 : bit_vector := X"000A";
      PRBS_CFG_LANE1 : bit_vector := X"000A";
      PRBS_CFG_LANE2 : bit_vector := X"000A";
      PRBS_CFG_LANE3 : bit_vector := X"000A";
      PTRN_CFG0_LSB : bit_vector := X"5555";
      PTRN_CFG0_MSB : bit_vector := X"5555";
      PTRN_LEN_CFG : bit_vector := X"001F";
      PWRUP_DLY : bit_vector := X"0000";
      RX_AEQ_VAL0_LANE0 : bit_vector := X"03C0";
      RX_AEQ_VAL0_LANE1 : bit_vector := X"03C0";
      RX_AEQ_VAL0_LANE2 : bit_vector := X"03C0";
      RX_AEQ_VAL0_LANE3 : bit_vector := X"03C0";
      RX_AEQ_VAL1_LANE0 : bit_vector := X"0000";
      RX_AEQ_VAL1_LANE1 : bit_vector := X"0000";
      RX_AEQ_VAL1_LANE2 : bit_vector := X"0000";
      RX_AEQ_VAL1_LANE3 : bit_vector := X"0000";
      RX_AGC_CTRL_LANE0 : bit_vector := X"0000";
      RX_AGC_CTRL_LANE1 : bit_vector := X"0000";
      RX_AGC_CTRL_LANE2 : bit_vector := X"0000";
      RX_AGC_CTRL_LANE3 : bit_vector := X"0000";
      RX_CDR_CTRL0_LANE0 : bit_vector := X"0005";
      RX_CDR_CTRL0_LANE1 : bit_vector := X"0005";
      RX_CDR_CTRL0_LANE2 : bit_vector := X"0005";
      RX_CDR_CTRL0_LANE3 : bit_vector := X"0005";
      RX_CDR_CTRL1_LANE0 : bit_vector := X"4200";
      RX_CDR_CTRL1_LANE1 : bit_vector := X"4200";
      RX_CDR_CTRL1_LANE2 : bit_vector := X"4200";
      RX_CDR_CTRL1_LANE3 : bit_vector := X"4200";
      RX_CDR_CTRL2_LANE0 : bit_vector := X"2000";
      RX_CDR_CTRL2_LANE1 : bit_vector := X"2000";
      RX_CDR_CTRL2_LANE2 : bit_vector := X"2000";
      RX_CDR_CTRL2_LANE3 : bit_vector := X"2000";
      RX_CFG0_LANE0 : bit_vector := X"0500";
      RX_CFG0_LANE1 : bit_vector := X"0500";
      RX_CFG0_LANE2 : bit_vector := X"0500";
      RX_CFG0_LANE3 : bit_vector := X"0500";
      RX_CFG1_LANE0 : bit_vector := X"821F";
      RX_CFG1_LANE1 : bit_vector := X"821F";
      RX_CFG1_LANE2 : bit_vector := X"821F";
      RX_CFG1_LANE3 : bit_vector := X"821F";
      RX_CFG2_LANE0 : bit_vector := X"1001";
      RX_CFG2_LANE1 : bit_vector := X"1001";
      RX_CFG2_LANE2 : bit_vector := X"1001";
      RX_CFG2_LANE3 : bit_vector := X"1001";
      RX_CTLE_CTRL_LANE0 : bit_vector := X"008F";
      RX_CTLE_CTRL_LANE1 : bit_vector := X"008F";
      RX_CTLE_CTRL_LANE2 : bit_vector := X"008F";
      RX_CTLE_CTRL_LANE3 : bit_vector := X"008F";
      RX_CTRL_OVRD_LANE0 : bit_vector := X"000C";
      RX_CTRL_OVRD_LANE1 : bit_vector := X"000C";
      RX_CTRL_OVRD_LANE2 : bit_vector := X"000C";
      RX_CTRL_OVRD_LANE3 : bit_vector := X"000C";
      RX_FABRIC_WIDTH0 : integer := 6466;
      RX_FABRIC_WIDTH1 : integer := 6466;
      RX_FABRIC_WIDTH2 : integer := 6466;
      RX_FABRIC_WIDTH3 : integer := 6466;
      RX_LOOP_CTRL_LANE0 : bit_vector := X"007F";
      RX_LOOP_CTRL_LANE1 : bit_vector := X"007F";
      RX_LOOP_CTRL_LANE2 : bit_vector := X"007F";
      RX_LOOP_CTRL_LANE3 : bit_vector := X"007F";
      RX_MVAL0_LANE0 : bit_vector := X"0000";
      RX_MVAL0_LANE1 : bit_vector := X"0000";
      RX_MVAL0_LANE2 : bit_vector := X"0000";
      RX_MVAL0_LANE3 : bit_vector := X"0000";
      RX_MVAL1_LANE0 : bit_vector := X"0000";
      RX_MVAL1_LANE1 : bit_vector := X"0000";
      RX_MVAL1_LANE2 : bit_vector := X"0000";
      RX_MVAL1_LANE3 : bit_vector := X"0000";
      RX_P0S_CTRL : bit_vector := X"1206";
      RX_P0_CTRL : bit_vector := X"11F0";
      RX_P1_CTRL : bit_vector := X"120F";
      RX_P2_CTRL : bit_vector := X"0E0F";
      RX_PI_CTRL0 : bit_vector := X"D2F0";
      RX_PI_CTRL1 : bit_vector := X"0080";
      SIM_GTHRESET_SPEEDUP : integer := 1;
      SIM_VERSION : string := "1.0";
      SLICE_CFG : bit_vector := X"0000";
      SLICE_NOISE_CTRL_0_LANE01 : bit_vector := X"0000";
      SLICE_NOISE_CTRL_0_LANE23 : bit_vector := X"0000";
      SLICE_NOISE_CTRL_1_LANE01 : bit_vector := X"0000";
      SLICE_NOISE_CTRL_1_LANE23 : bit_vector := X"0000";
      SLICE_NOISE_CTRL_2_LANE01 : bit_vector := X"7FFF";
      SLICE_NOISE_CTRL_2_LANE23 : bit_vector := X"7FFF";
      SLICE_TX_RESET_LANE01 : bit_vector := X"0000";
      SLICE_TX_RESET_LANE23 : bit_vector := X"0000";
      TERM_CTRL_LANE0 : bit_vector := X"5007";
      TERM_CTRL_LANE1 : bit_vector := X"5007";
      TERM_CTRL_LANE2 : bit_vector := X"5007";
      TERM_CTRL_LANE3 : bit_vector := X"5007";
      TX_CFG0_LANE0 : bit_vector := X"203D";
      TX_CFG0_LANE1 : bit_vector := X"203D";
      TX_CFG0_LANE2 : bit_vector := X"203D";
      TX_CFG0_LANE3 : bit_vector := X"203D";
      TX_CFG1_LANE0 : bit_vector := X"0F00";
      TX_CFG1_LANE1 : bit_vector := X"0F00";
      TX_CFG1_LANE2 : bit_vector := X"0F00";
      TX_CFG1_LANE3 : bit_vector := X"0F00";
      TX_CFG2_LANE0 : bit_vector := X"0081";
      TX_CFG2_LANE1 : bit_vector := X"0081";
      TX_CFG2_LANE2 : bit_vector := X"0081";
      TX_CFG2_LANE3 : bit_vector := X"0081";
      TX_CLK_SEL0_LANE0 : bit_vector := X"2121";
      TX_CLK_SEL0_LANE1 : bit_vector := X"2121";
      TX_CLK_SEL0_LANE2 : bit_vector := X"2121";
      TX_CLK_SEL0_LANE3 : bit_vector := X"2121";
      TX_CLK_SEL1_LANE0 : bit_vector := X"2121";
      TX_CLK_SEL1_LANE1 : bit_vector := X"2121";
      TX_CLK_SEL1_LANE2 : bit_vector := X"2121";
      TX_CLK_SEL1_LANE3 : bit_vector := X"2121";
      TX_DISABLE_LANE0 : bit_vector := X"0000";
      TX_DISABLE_LANE1 : bit_vector := X"0000";
      TX_DISABLE_LANE2 : bit_vector := X"0000";
      TX_DISABLE_LANE3 : bit_vector := X"0000";
      TX_FABRIC_WIDTH0 : integer := 6466;
      TX_FABRIC_WIDTH1 : integer := 6466;
      TX_FABRIC_WIDTH2 : integer := 6466;
      TX_FABRIC_WIDTH3 : integer := 6466;
      TX_P0P0S_CTRL : bit_vector := X"060C";
      TX_P1P2_CTRL : bit_vector := X"0C39";
      TX_PREEMPH_LANE0 : bit_vector := X"00A1";
      TX_PREEMPH_LANE1 : bit_vector := X"00A1";
      TX_PREEMPH_LANE2 : bit_vector := X"00A1";
      TX_PREEMPH_LANE3 : bit_vector := X"00A1";
      TX_PWR_RATE_OVRD_LANE0 : bit_vector := X"0060";
      TX_PWR_RATE_OVRD_LANE1 : bit_vector := X"0060";
      TX_PWR_RATE_OVRD_LANE2 : bit_vector := X"0060";
      TX_PWR_RATE_OVRD_LANE3 : bit_vector := X"0060"
    );

    port (
      DRDY                 : out std_ulogic;
      DRPDO                : out std_logic_vector(15 downto 0);
      GTHINITDONE          : out std_ulogic;
      MGMTPCSRDACK         : out std_ulogic;
      MGMTPCSRDDATA        : out std_logic_vector(15 downto 0);
      RXCODEERR0           : out std_logic_vector(7 downto 0);
      RXCODEERR1           : out std_logic_vector(7 downto 0);
      RXCODEERR2           : out std_logic_vector(7 downto 0);
      RXCODEERR3           : out std_logic_vector(7 downto 0);
      RXCTRL0              : out std_logic_vector(7 downto 0);
      RXCTRL1              : out std_logic_vector(7 downto 0);
      RXCTRL2              : out std_logic_vector(7 downto 0);
      RXCTRL3              : out std_logic_vector(7 downto 0);
      RXCTRLACK0           : out std_ulogic;
      RXCTRLACK1           : out std_ulogic;
      RXCTRLACK2           : out std_ulogic;
      RXCTRLACK3           : out std_ulogic;
      RXDATA0              : out std_logic_vector(63 downto 0);
      RXDATA1              : out std_logic_vector(63 downto 0);
      RXDATA2              : out std_logic_vector(63 downto 0);
      RXDATA3              : out std_logic_vector(63 downto 0);
      RXDATATAP0           : out std_ulogic;
      RXDATATAP1           : out std_ulogic;
      RXDATATAP2           : out std_ulogic;
      RXDATATAP3           : out std_ulogic;
      RXDISPERR0           : out std_logic_vector(7 downto 0);
      RXDISPERR1           : out std_logic_vector(7 downto 0);
      RXDISPERR2           : out std_logic_vector(7 downto 0);
      RXDISPERR3           : out std_logic_vector(7 downto 0);
      RXPCSCLKSMPL0        : out std_ulogic;
      RXPCSCLKSMPL1        : out std_ulogic;
      RXPCSCLKSMPL2        : out std_ulogic;
      RXPCSCLKSMPL3        : out std_ulogic;
      RXUSERCLKOUT0        : out std_ulogic;
      RXUSERCLKOUT1        : out std_ulogic;
      RXUSERCLKOUT2        : out std_ulogic;
      RXUSERCLKOUT3        : out std_ulogic;
      RXVALID0             : out std_logic_vector(7 downto 0);
      RXVALID1             : out std_logic_vector(7 downto 0);
      RXVALID2             : out std_logic_vector(7 downto 0);
      RXVALID3             : out std_logic_vector(7 downto 0);
      TSTPATH              : out std_ulogic;
      TSTREFCLKFAB         : out std_ulogic;
      TSTREFCLKOUT         : out std_ulogic;
      TXCTRLACK0           : out std_ulogic;
      TXCTRLACK1           : out std_ulogic;
      TXCTRLACK2           : out std_ulogic;
      TXCTRLACK3           : out std_ulogic;
      TXDATATAP10          : out std_ulogic;
      TXDATATAP11          : out std_ulogic;
      TXDATATAP12          : out std_ulogic;
      TXDATATAP13          : out std_ulogic;
      TXDATATAP20          : out std_ulogic;
      TXDATATAP21          : out std_ulogic;
      TXDATATAP22          : out std_ulogic;
      TXDATATAP23          : out std_ulogic;
      TXN0                 : out std_ulogic;
      TXN1                 : out std_ulogic;
      TXN2                 : out std_ulogic;
      TXN3                 : out std_ulogic;
      TXP0                 : out std_ulogic;
      TXP1                 : out std_ulogic;
      TXP2                 : out std_ulogic;
      TXP3                 : out std_ulogic;
      TXPCSCLKSMPL0        : out std_ulogic;
      TXPCSCLKSMPL1        : out std_ulogic;
      TXPCSCLKSMPL2        : out std_ulogic;
      TXPCSCLKSMPL3        : out std_ulogic;
      TXUSERCLKOUT0        : out std_ulogic;
      TXUSERCLKOUT1        : out std_ulogic;
      TXUSERCLKOUT2        : out std_ulogic;
      TXUSERCLKOUT3        : out std_ulogic;
      DADDR                : in std_logic_vector(15 downto 0);
      DCLK                 : in std_ulogic;
      DEN                  : in std_ulogic;
      DFETRAINCTRL0        : in std_ulogic;
      DFETRAINCTRL1        : in std_ulogic;
      DFETRAINCTRL2        : in std_ulogic;
      DFETRAINCTRL3        : in std_ulogic;
      DI                   : in std_logic_vector(15 downto 0);
      DISABLEDRP           : in std_ulogic;
      DWE                  : in std_ulogic;
      GTHINIT              : in std_ulogic;
      GTHRESET             : in std_ulogic;
      GTHX2LANE01          : in std_ulogic;
      GTHX2LANE23          : in std_ulogic;
      GTHX4LANE            : in std_ulogic;
      MGMTPCSLANESEL       : in std_logic_vector(3 downto 0);
      MGMTPCSMMDADDR       : in std_logic_vector(4 downto 0);
      MGMTPCSREGADDR       : in std_logic_vector(15 downto 0);
      MGMTPCSREGRD         : in std_ulogic;
      MGMTPCSREGWR         : in std_ulogic;
      MGMTPCSWRDATA        : in std_logic_vector(15 downto 0);
      PLLPCSCLKDIV         : in std_logic_vector(5 downto 0);
      PLLREFCLKSEL         : in std_logic_vector(2 downto 0);
      POWERDOWN0           : in std_ulogic;
      POWERDOWN1           : in std_ulogic;
      POWERDOWN2           : in std_ulogic;
      POWERDOWN3           : in std_ulogic;
      REFCLK               : in std_ulogic;
      RXBUFRESET0          : in std_ulogic;
      RXBUFRESET1          : in std_ulogic;
      RXBUFRESET2          : in std_ulogic;
      RXBUFRESET3          : in std_ulogic;
      RXENCOMMADET0        : in std_ulogic;
      RXENCOMMADET1        : in std_ulogic;
      RXENCOMMADET2        : in std_ulogic;
      RXENCOMMADET3        : in std_ulogic;
      RXN0                 : in std_ulogic;
      RXN1                 : in std_ulogic;
      RXN2                 : in std_ulogic;
      RXN3                 : in std_ulogic;
      RXP0                 : in std_ulogic;
      RXP1                 : in std_ulogic;
      RXP2                 : in std_ulogic;
      RXP3                 : in std_ulogic;
      RXPOLARITY0          : in std_ulogic;
      RXPOLARITY1          : in std_ulogic;
      RXPOLARITY2          : in std_ulogic;
      RXPOLARITY3          : in std_ulogic;
      RXPOWERDOWN0         : in std_logic_vector(1 downto 0);
      RXPOWERDOWN1         : in std_logic_vector(1 downto 0);
      RXPOWERDOWN2         : in std_logic_vector(1 downto 0);
      RXPOWERDOWN3         : in std_logic_vector(1 downto 0);
      RXRATE0              : in std_logic_vector(1 downto 0);
      RXRATE1              : in std_logic_vector(1 downto 0);
      RXRATE2              : in std_logic_vector(1 downto 0);
      RXRATE3              : in std_logic_vector(1 downto 0);
      RXSLIP0              : in std_ulogic;
      RXSLIP1              : in std_ulogic;
      RXSLIP2              : in std_ulogic;
      RXSLIP3              : in std_ulogic;
      RXUSERCLKIN0         : in std_ulogic;
      RXUSERCLKIN1         : in std_ulogic;
      RXUSERCLKIN2         : in std_ulogic;
      RXUSERCLKIN3         : in std_ulogic;
      SAMPLERATE0          : in std_logic_vector(2 downto 0);
      SAMPLERATE1          : in std_logic_vector(2 downto 0);
      SAMPLERATE2          : in std_logic_vector(2 downto 0);
      SAMPLERATE3          : in std_logic_vector(2 downto 0);
      TXBUFRESET0          : in std_ulogic;
      TXBUFRESET1          : in std_ulogic;
      TXBUFRESET2          : in std_ulogic;
      TXBUFRESET3          : in std_ulogic;
      TXCTRL0              : in std_logic_vector(7 downto 0);
      TXCTRL1              : in std_logic_vector(7 downto 0);
      TXCTRL2              : in std_logic_vector(7 downto 0);
      TXCTRL3              : in std_logic_vector(7 downto 0);
      TXDATA0              : in std_logic_vector(63 downto 0);
      TXDATA1              : in std_logic_vector(63 downto 0);
      TXDATA2              : in std_logic_vector(63 downto 0);
      TXDATA3              : in std_logic_vector(63 downto 0);
      TXDATAMSB0           : in std_logic_vector(7 downto 0);
      TXDATAMSB1           : in std_logic_vector(7 downto 0);
      TXDATAMSB2           : in std_logic_vector(7 downto 0);
      TXDATAMSB3           : in std_logic_vector(7 downto 0);
      TXDEEMPH0            : in std_ulogic;
      TXDEEMPH1            : in std_ulogic;
      TXDEEMPH2            : in std_ulogic;
      TXDEEMPH3            : in std_ulogic;
      TXMARGIN0            : in std_logic_vector(2 downto 0);
      TXMARGIN1            : in std_logic_vector(2 downto 0);
      TXMARGIN2            : in std_logic_vector(2 downto 0);
      TXMARGIN3            : in std_logic_vector(2 downto 0);
      TXPOWERDOWN0         : in std_logic_vector(1 downto 0);
      TXPOWERDOWN1         : in std_logic_vector(1 downto 0);
      TXPOWERDOWN2         : in std_logic_vector(1 downto 0);
      TXPOWERDOWN3         : in std_logic_vector(1 downto 0);
      TXRATE0              : in std_logic_vector(1 downto 0);
      TXRATE1              : in std_logic_vector(1 downto 0);
      TXRATE2              : in std_logic_vector(1 downto 0);
      TXRATE3              : in std_logic_vector(1 downto 0);
      TXUSERCLKIN0         : in std_ulogic;
      TXUSERCLKIN1         : in std_ulogic;
      TXUSERCLKIN2         : in std_ulogic;
      TXUSERCLKIN3         : in std_ulogic      
    );
  end GTHE1_QUAD;

  architecture GTHE1_QUAD_V of GTHE1_QUAD is
    component GTHE1_QUAD_WRAP
      generic (
        BER_CONST_PTRN0 : string;
        BER_CONST_PTRN1 : string;
        BUFFER_CONFIG_LANE0 : string;
        BUFFER_CONFIG_LANE1 : string;
        BUFFER_CONFIG_LANE2 : string;
        BUFFER_CONFIG_LANE3 : string;
        DFE_TRAIN_CTRL_LANE0 : string;
        DFE_TRAIN_CTRL_LANE1 : string;
        DFE_TRAIN_CTRL_LANE2 : string;
        DFE_TRAIN_CTRL_LANE3 : string;
        DLL_CFG0 : string;
        DLL_CFG1 : string;
        E10GBASEKR_LD_COEFF_UPD_LANE0 : string;
        E10GBASEKR_LD_COEFF_UPD_LANE1 : string;
        E10GBASEKR_LD_COEFF_UPD_LANE2 : string;
        E10GBASEKR_LD_COEFF_UPD_LANE3 : string;
        E10GBASEKR_LP_COEFF_UPD_LANE0 : string;
        E10GBASEKR_LP_COEFF_UPD_LANE1 : string;
        E10GBASEKR_LP_COEFF_UPD_LANE2 : string;
        E10GBASEKR_LP_COEFF_UPD_LANE3 : string;
        E10GBASEKR_PMA_CTRL_LANE0 : string;
        E10GBASEKR_PMA_CTRL_LANE1 : string;
        E10GBASEKR_PMA_CTRL_LANE2 : string;
        E10GBASEKR_PMA_CTRL_LANE3 : string;
        E10GBASEKX_CTRL_LANE0 : string;
        E10GBASEKX_CTRL_LANE1 : string;
        E10GBASEKX_CTRL_LANE2 : string;
        E10GBASEKX_CTRL_LANE3 : string;
        E10GBASER_PCS_CFG_LANE0 : string;
        E10GBASER_PCS_CFG_LANE1 : string;
        E10GBASER_PCS_CFG_LANE2 : string;
        E10GBASER_PCS_CFG_LANE3 : string;
        E10GBASER_PCS_SEEDA0_LANE0 : string;
        E10GBASER_PCS_SEEDA0_LANE1 : string;
        E10GBASER_PCS_SEEDA0_LANE2 : string;
        E10GBASER_PCS_SEEDA0_LANE3 : string;
        E10GBASER_PCS_SEEDA1_LANE0 : string;
        E10GBASER_PCS_SEEDA1_LANE1 : string;
        E10GBASER_PCS_SEEDA1_LANE2 : string;
        E10GBASER_PCS_SEEDA1_LANE3 : string;
        E10GBASER_PCS_SEEDA2_LANE0 : string;
        E10GBASER_PCS_SEEDA2_LANE1 : string;
        E10GBASER_PCS_SEEDA2_LANE2 : string;
        E10GBASER_PCS_SEEDA2_LANE3 : string;
        E10GBASER_PCS_SEEDA3_LANE0 : string;
        E10GBASER_PCS_SEEDA3_LANE1 : string;
        E10GBASER_PCS_SEEDA3_LANE2 : string;
        E10GBASER_PCS_SEEDA3_LANE3 : string;
        E10GBASER_PCS_SEEDB0_LANE0 : string;
        E10GBASER_PCS_SEEDB0_LANE1 : string;
        E10GBASER_PCS_SEEDB0_LANE2 : string;
        E10GBASER_PCS_SEEDB0_LANE3 : string;
        E10GBASER_PCS_SEEDB1_LANE0 : string;
        E10GBASER_PCS_SEEDB1_LANE1 : string;
        E10GBASER_PCS_SEEDB1_LANE2 : string;
        E10GBASER_PCS_SEEDB1_LANE3 : string;
        E10GBASER_PCS_SEEDB2_LANE0 : string;
        E10GBASER_PCS_SEEDB2_LANE1 : string;
        E10GBASER_PCS_SEEDB2_LANE2 : string;
        E10GBASER_PCS_SEEDB2_LANE3 : string;
        E10GBASER_PCS_SEEDB3_LANE0 : string;
        E10GBASER_PCS_SEEDB3_LANE1 : string;
        E10GBASER_PCS_SEEDB3_LANE2 : string;
        E10GBASER_PCS_SEEDB3_LANE3 : string;
        E10GBASER_PCS_TEST_CTRL_LANE0 : string;
        E10GBASER_PCS_TEST_CTRL_LANE1 : string;
        E10GBASER_PCS_TEST_CTRL_LANE2 : string;
        E10GBASER_PCS_TEST_CTRL_LANE3 : string;
        E10GBASEX_PCS_TSTCTRL_LANE0 : string;
        E10GBASEX_PCS_TSTCTRL_LANE1 : string;
        E10GBASEX_PCS_TSTCTRL_LANE2 : string;
        E10GBASEX_PCS_TSTCTRL_LANE3 : string;
        GLBL0_NOISE_CTRL : string;
        GLBL_AMON_SEL : string;
        GLBL_DMON_SEL : string;
        GLBL_PWR_CTRL : string;
        GTH_CFG_PWRUP_LANE0 : string;
        GTH_CFG_PWRUP_LANE1 : string;
        GTH_CFG_PWRUP_LANE2 : string;
        GTH_CFG_PWRUP_LANE3 : string;
        LANE_AMON_SEL : string;
        LANE_DMON_SEL : string;
        LANE_LNK_CFGOVRD : string;
        LANE_PWR_CTRL_LANE0 : string;
        LANE_PWR_CTRL_LANE1 : string;
        LANE_PWR_CTRL_LANE2 : string;
        LANE_PWR_CTRL_LANE3 : string;
        LNK_TRN_CFG_LANE0 : string;
        LNK_TRN_CFG_LANE1 : string;
        LNK_TRN_CFG_LANE2 : string;
        LNK_TRN_CFG_LANE3 : string;
        LNK_TRN_COEFF_REQ_LANE0 : string;
        LNK_TRN_COEFF_REQ_LANE1 : string;
        LNK_TRN_COEFF_REQ_LANE2 : string;
        LNK_TRN_COEFF_REQ_LANE3 : string;
        MISC_CFG : string;
        MODE_CFG1 : string;
        MODE_CFG2 : string;
        MODE_CFG3 : string;
        MODE_CFG4 : string;
        MODE_CFG5 : string;
        MODE_CFG6 : string;
        MODE_CFG7 : string;
        PCS_ABILITY_LANE0 : string;
        PCS_ABILITY_LANE1 : string;
        PCS_ABILITY_LANE2 : string;
        PCS_ABILITY_LANE3 : string;
        PCS_CTRL1_LANE0 : string;
        PCS_CTRL1_LANE1 : string;
        PCS_CTRL1_LANE2 : string;
        PCS_CTRL1_LANE3 : string;
        PCS_CTRL2_LANE0 : string;
        PCS_CTRL2_LANE1 : string;
        PCS_CTRL2_LANE2 : string;
        PCS_CTRL2_LANE3 : string;
        PCS_MISC_CFG_0_LANE0 : string;
        PCS_MISC_CFG_0_LANE1 : string;
        PCS_MISC_CFG_0_LANE2 : string;
        PCS_MISC_CFG_0_LANE3 : string;
        PCS_MISC_CFG_1_LANE0 : string;
        PCS_MISC_CFG_1_LANE1 : string;
        PCS_MISC_CFG_1_LANE2 : string;
        PCS_MISC_CFG_1_LANE3 : string;
        PCS_MODE_LANE0 : string;
        PCS_MODE_LANE1 : string;
        PCS_MODE_LANE2 : string;
        PCS_MODE_LANE3 : string;
        PCS_RESET_1_LANE0 : string;
        PCS_RESET_1_LANE1 : string;
        PCS_RESET_1_LANE2 : string;
        PCS_RESET_1_LANE3 : string;
        PCS_RESET_LANE0 : string;
        PCS_RESET_LANE1 : string;
        PCS_RESET_LANE2 : string;
        PCS_RESET_LANE3 : string;
        PCS_TYPE_LANE0 : string;
        PCS_TYPE_LANE1 : string;
        PCS_TYPE_LANE2 : string;
        PCS_TYPE_LANE3 : string;
        PLL_CFG0 : string;
        PLL_CFG1 : string;
        PLL_CFG2 : string;
        PMA_CTRL1_LANE0 : string;
        PMA_CTRL1_LANE1 : string;
        PMA_CTRL1_LANE2 : string;
        PMA_CTRL1_LANE3 : string;
        PMA_CTRL2_LANE0 : string;
        PMA_CTRL2_LANE1 : string;
        PMA_CTRL2_LANE2 : string;
        PMA_CTRL2_LANE3 : string;
        PMA_LPBK_CTRL_LANE0 : string;
        PMA_LPBK_CTRL_LANE1 : string;
        PMA_LPBK_CTRL_LANE2 : string;
        PMA_LPBK_CTRL_LANE3 : string;
        PRBS_BER_CFG0_LANE0 : string;
        PRBS_BER_CFG0_LANE1 : string;
        PRBS_BER_CFG0_LANE2 : string;
        PRBS_BER_CFG0_LANE3 : string;
        PRBS_BER_CFG1_LANE0 : string;
        PRBS_BER_CFG1_LANE1 : string;
        PRBS_BER_CFG1_LANE2 : string;
        PRBS_BER_CFG1_LANE3 : string;
        PRBS_CFG_LANE0 : string;
        PRBS_CFG_LANE1 : string;
        PRBS_CFG_LANE2 : string;
        PRBS_CFG_LANE3 : string;
        PTRN_CFG0_LSB : string;
        PTRN_CFG0_MSB : string;
        PTRN_LEN_CFG : string;
        PWRUP_DLY : string;
        RX_AEQ_VAL0_LANE0 : string;
        RX_AEQ_VAL0_LANE1 : string;
        RX_AEQ_VAL0_LANE2 : string;
        RX_AEQ_VAL0_LANE3 : string;
        RX_AEQ_VAL1_LANE0 : string;
        RX_AEQ_VAL1_LANE1 : string;
        RX_AEQ_VAL1_LANE2 : string;
        RX_AEQ_VAL1_LANE3 : string;
        RX_AGC_CTRL_LANE0 : string;
        RX_AGC_CTRL_LANE1 : string;
        RX_AGC_CTRL_LANE2 : string;
        RX_AGC_CTRL_LANE3 : string;
        RX_CDR_CTRL0_LANE0 : string;
        RX_CDR_CTRL0_LANE1 : string;
        RX_CDR_CTRL0_LANE2 : string;
        RX_CDR_CTRL0_LANE3 : string;
        RX_CDR_CTRL1_LANE0 : string;
        RX_CDR_CTRL1_LANE1 : string;
        RX_CDR_CTRL1_LANE2 : string;
        RX_CDR_CTRL1_LANE3 : string;
        RX_CDR_CTRL2_LANE0 : string;
        RX_CDR_CTRL2_LANE1 : string;
        RX_CDR_CTRL2_LANE2 : string;
        RX_CDR_CTRL2_LANE3 : string;
        RX_CFG0_LANE0 : string;
        RX_CFG0_LANE1 : string;
        RX_CFG0_LANE2 : string;
        RX_CFG0_LANE3 : string;
        RX_CFG1_LANE0 : string;
        RX_CFG1_LANE1 : string;
        RX_CFG1_LANE2 : string;
        RX_CFG1_LANE3 : string;
        RX_CFG2_LANE0 : string;
        RX_CFG2_LANE1 : string;
        RX_CFG2_LANE2 : string;
        RX_CFG2_LANE3 : string;
        RX_CTLE_CTRL_LANE0 : string;
        RX_CTLE_CTRL_LANE1 : string;
        RX_CTLE_CTRL_LANE2 : string;
        RX_CTLE_CTRL_LANE3 : string;
        RX_CTRL_OVRD_LANE0 : string;
        RX_CTRL_OVRD_LANE1 : string;
        RX_CTRL_OVRD_LANE2 : string;
        RX_CTRL_OVRD_LANE3 : string;
        RX_FABRIC_WIDTH0 : integer;
        RX_FABRIC_WIDTH1 : integer;
        RX_FABRIC_WIDTH2 : integer;
        RX_FABRIC_WIDTH3 : integer;
        RX_LOOP_CTRL_LANE0 : string;
        RX_LOOP_CTRL_LANE1 : string;
        RX_LOOP_CTRL_LANE2 : string;
        RX_LOOP_CTRL_LANE3 : string;
        RX_MVAL0_LANE0 : string;
        RX_MVAL0_LANE1 : string;
        RX_MVAL0_LANE2 : string;
        RX_MVAL0_LANE3 : string;
        RX_MVAL1_LANE0 : string;
        RX_MVAL1_LANE1 : string;
        RX_MVAL1_LANE2 : string;
        RX_MVAL1_LANE3 : string;
        RX_P0S_CTRL : string;
        RX_P0_CTRL : string;
        RX_P1_CTRL : string;
        RX_P2_CTRL : string;
        RX_PI_CTRL0 : string;
        RX_PI_CTRL1 : string;
        SIM_GTHRESET_SPEEDUP : integer;
        SIM_VERSION : string;
        SLICE_CFG : string;
        SLICE_NOISE_CTRL_0_LANE01 : string;
        SLICE_NOISE_CTRL_0_LANE23 : string;
        SLICE_NOISE_CTRL_1_LANE01 : string;
        SLICE_NOISE_CTRL_1_LANE23 : string;
        SLICE_NOISE_CTRL_2_LANE01 : string;
        SLICE_NOISE_CTRL_2_LANE23 : string;
        SLICE_TX_RESET_LANE01 : string;
        SLICE_TX_RESET_LANE23 : string;
        TERM_CTRL_LANE0 : string;
        TERM_CTRL_LANE1 : string;
        TERM_CTRL_LANE2 : string;
        TERM_CTRL_LANE3 : string;
        TX_CFG0_LANE0 : string;
        TX_CFG0_LANE1 : string;
        TX_CFG0_LANE2 : string;
        TX_CFG0_LANE3 : string;
        TX_CFG1_LANE0 : string;
        TX_CFG1_LANE1 : string;
        TX_CFG1_LANE2 : string;
        TX_CFG1_LANE3 : string;
        TX_CFG2_LANE0 : string;
        TX_CFG2_LANE1 : string;
        TX_CFG2_LANE2 : string;
        TX_CFG2_LANE3 : string;
        TX_CLK_SEL0_LANE0 : string;
        TX_CLK_SEL0_LANE1 : string;
        TX_CLK_SEL0_LANE2 : string;
        TX_CLK_SEL0_LANE3 : string;
        TX_CLK_SEL1_LANE0 : string;
        TX_CLK_SEL1_LANE1 : string;
        TX_CLK_SEL1_LANE2 : string;
        TX_CLK_SEL1_LANE3 : string;
        TX_DISABLE_LANE0 : string;
        TX_DISABLE_LANE1 : string;
        TX_DISABLE_LANE2 : string;
        TX_DISABLE_LANE3 : string;
        TX_FABRIC_WIDTH0 : integer;
        TX_FABRIC_WIDTH1 : integer;
        TX_FABRIC_WIDTH2 : integer;
        TX_FABRIC_WIDTH3 : integer;
        TX_P0P0S_CTRL : string;
        TX_P1P2_CTRL : string;
        TX_PREEMPH_LANE0 : string;
        TX_PREEMPH_LANE1 : string;
        TX_PREEMPH_LANE2 : string;
        TX_PREEMPH_LANE3 : string;
        TX_PWR_RATE_OVRD_LANE0 : string;
        TX_PWR_RATE_OVRD_LANE1 : string;
        TX_PWR_RATE_OVRD_LANE2 : string;
        TX_PWR_RATE_OVRD_LANE3 : string        
      );
      
      port (
        DRDY                 : out std_ulogic;
        DRPDO                : out std_logic_vector(15 downto 0);
        GTHINITDONE          : out std_ulogic;
        MGMTPCSRDACK         : out std_ulogic;
        MGMTPCSRDDATA        : out std_logic_vector(15 downto 0);
        RXCODEERR0           : out std_logic_vector(7 downto 0);
        RXCODEERR1           : out std_logic_vector(7 downto 0);
        RXCODEERR2           : out std_logic_vector(7 downto 0);
        RXCODEERR3           : out std_logic_vector(7 downto 0);
        RXCTRL0              : out std_logic_vector(7 downto 0);
        RXCTRL1              : out std_logic_vector(7 downto 0);
        RXCTRL2              : out std_logic_vector(7 downto 0);
        RXCTRL3              : out std_logic_vector(7 downto 0);
        RXCTRLACK0           : out std_ulogic;
        RXCTRLACK1           : out std_ulogic;
        RXCTRLACK2           : out std_ulogic;
        RXCTRLACK3           : out std_ulogic;
        RXDATA0              : out std_logic_vector(63 downto 0);
        RXDATA1              : out std_logic_vector(63 downto 0);
        RXDATA2              : out std_logic_vector(63 downto 0);
        RXDATA3              : out std_logic_vector(63 downto 0);
        RXDATATAP0           : out std_ulogic;
        RXDATATAP1           : out std_ulogic;
        RXDATATAP2           : out std_ulogic;
        RXDATATAP3           : out std_ulogic;
        RXDISPERR0           : out std_logic_vector(7 downto 0);
        RXDISPERR1           : out std_logic_vector(7 downto 0);
        RXDISPERR2           : out std_logic_vector(7 downto 0);
        RXDISPERR3           : out std_logic_vector(7 downto 0);
        RXPCSCLKSMPL0        : out std_ulogic;
        RXPCSCLKSMPL1        : out std_ulogic;
        RXPCSCLKSMPL2        : out std_ulogic;
        RXPCSCLKSMPL3        : out std_ulogic;
        RXUSERCLKOUT0        : out std_ulogic;
        RXUSERCLKOUT1        : out std_ulogic;
        RXUSERCLKOUT2        : out std_ulogic;
        RXUSERCLKOUT3        : out std_ulogic;
        RXVALID0             : out std_logic_vector(7 downto 0);
        RXVALID1             : out std_logic_vector(7 downto 0);
        RXVALID2             : out std_logic_vector(7 downto 0);
        RXVALID3             : out std_logic_vector(7 downto 0);
        TSTPATH              : out std_ulogic;
        TSTREFCLKFAB         : out std_ulogic;
        TSTREFCLKOUT         : out std_ulogic;
        TXCTRLACK0           : out std_ulogic;
        TXCTRLACK1           : out std_ulogic;
        TXCTRLACK2           : out std_ulogic;
        TXCTRLACK3           : out std_ulogic;
        TXDATATAP10          : out std_ulogic;
        TXDATATAP11          : out std_ulogic;
        TXDATATAP12          : out std_ulogic;
        TXDATATAP13          : out std_ulogic;
        TXDATATAP20          : out std_ulogic;
        TXDATATAP21          : out std_ulogic;
        TXDATATAP22          : out std_ulogic;
        TXDATATAP23          : out std_ulogic;
        TXN0                 : out std_ulogic;
        TXN1                 : out std_ulogic;
        TXN2                 : out std_ulogic;
        TXN3                 : out std_ulogic;
        TXP0                 : out std_ulogic;
        TXP1                 : out std_ulogic;
        TXP2                 : out std_ulogic;
        TXP3                 : out std_ulogic;
        TXPCSCLKSMPL0        : out std_ulogic;
        TXPCSCLKSMPL1        : out std_ulogic;
        TXPCSCLKSMPL2        : out std_ulogic;
        TXPCSCLKSMPL3        : out std_ulogic;
        TXUSERCLKOUT0        : out std_ulogic;
        TXUSERCLKOUT1        : out std_ulogic;
        TXUSERCLKOUT2        : out std_ulogic;
        TXUSERCLKOUT3        : out std_ulogic;
        GSR                  : in std_ulogic;
        DADDR                : in std_logic_vector(15 downto 0);
        DCLK                 : in std_ulogic;
        DEN                  : in std_ulogic;
        DFETRAINCTRL0        : in std_ulogic;
        DFETRAINCTRL1        : in std_ulogic;
        DFETRAINCTRL2        : in std_ulogic;
        DFETRAINCTRL3        : in std_ulogic;
        DI                   : in std_logic_vector(15 downto 0);
        DISABLEDRP           : in std_ulogic;
        DWE                  : in std_ulogic;
        GTHINIT              : in std_ulogic;
        GTHRESET             : in std_ulogic;
        GTHX2LANE01          : in std_ulogic;
        GTHX2LANE23          : in std_ulogic;
        GTHX4LANE            : in std_ulogic;
        MGMTPCSLANESEL       : in std_logic_vector(3 downto 0);
        MGMTPCSMMDADDR       : in std_logic_vector(4 downto 0);
        MGMTPCSREGADDR       : in std_logic_vector(15 downto 0);
        MGMTPCSREGRD         : in std_ulogic;
        MGMTPCSREGWR         : in std_ulogic;
        MGMTPCSWRDATA        : in std_logic_vector(15 downto 0);
        PLLPCSCLKDIV         : in std_logic_vector(5 downto 0);
        PLLREFCLKSEL         : in std_logic_vector(2 downto 0);
        POWERDOWN0           : in std_ulogic;
        POWERDOWN1           : in std_ulogic;
        POWERDOWN2           : in std_ulogic;
        POWERDOWN3           : in std_ulogic;
        REFCLK               : in std_ulogic;
        RXBUFRESET0          : in std_ulogic;
        RXBUFRESET1          : in std_ulogic;
        RXBUFRESET2          : in std_ulogic;
        RXBUFRESET3          : in std_ulogic;
        RXENCOMMADET0        : in std_ulogic;
        RXENCOMMADET1        : in std_ulogic;
        RXENCOMMADET2        : in std_ulogic;
        RXENCOMMADET3        : in std_ulogic;
        RXN0                 : in std_ulogic;
        RXN1                 : in std_ulogic;
        RXN2                 : in std_ulogic;
        RXN3                 : in std_ulogic;
        RXP0                 : in std_ulogic;
        RXP1                 : in std_ulogic;
        RXP2                 : in std_ulogic;
        RXP3                 : in std_ulogic;
        RXPOLARITY0          : in std_ulogic;
        RXPOLARITY1          : in std_ulogic;
        RXPOLARITY2          : in std_ulogic;
        RXPOLARITY3          : in std_ulogic;
        RXPOWERDOWN0         : in std_logic_vector(1 downto 0);
        RXPOWERDOWN1         : in std_logic_vector(1 downto 0);
        RXPOWERDOWN2         : in std_logic_vector(1 downto 0);
        RXPOWERDOWN3         : in std_logic_vector(1 downto 0);
        RXRATE0              : in std_logic_vector(1 downto 0);
        RXRATE1              : in std_logic_vector(1 downto 0);
        RXRATE2              : in std_logic_vector(1 downto 0);
        RXRATE3              : in std_logic_vector(1 downto 0);
        RXSLIP0              : in std_ulogic;
        RXSLIP1              : in std_ulogic;
        RXSLIP2              : in std_ulogic;
        RXSLIP3              : in std_ulogic;
        RXUSERCLKIN0         : in std_ulogic;
        RXUSERCLKIN1         : in std_ulogic;
        RXUSERCLKIN2         : in std_ulogic;
        RXUSERCLKIN3         : in std_ulogic;
        SAMPLERATE0          : in std_logic_vector(2 downto 0);
        SAMPLERATE1          : in std_logic_vector(2 downto 0);
        SAMPLERATE2          : in std_logic_vector(2 downto 0);
        SAMPLERATE3          : in std_logic_vector(2 downto 0);
        TXBUFRESET0          : in std_ulogic;
        TXBUFRESET1          : in std_ulogic;
        TXBUFRESET2          : in std_ulogic;
        TXBUFRESET3          : in std_ulogic;
        TXCTRL0              : in std_logic_vector(7 downto 0);
        TXCTRL1              : in std_logic_vector(7 downto 0);
        TXCTRL2              : in std_logic_vector(7 downto 0);
        TXCTRL3              : in std_logic_vector(7 downto 0);
        TXDATA0              : in std_logic_vector(63 downto 0);
        TXDATA1              : in std_logic_vector(63 downto 0);
        TXDATA2              : in std_logic_vector(63 downto 0);
        TXDATA3              : in std_logic_vector(63 downto 0);
        TXDATAMSB0           : in std_logic_vector(7 downto 0);
        TXDATAMSB1           : in std_logic_vector(7 downto 0);
        TXDATAMSB2           : in std_logic_vector(7 downto 0);
        TXDATAMSB3           : in std_logic_vector(7 downto 0);
        TXDEEMPH0            : in std_ulogic;
        TXDEEMPH1            : in std_ulogic;
        TXDEEMPH2            : in std_ulogic;
        TXDEEMPH3            : in std_ulogic;
        TXMARGIN0            : in std_logic_vector(2 downto 0);
        TXMARGIN1            : in std_logic_vector(2 downto 0);
        TXMARGIN2            : in std_logic_vector(2 downto 0);
        TXMARGIN3            : in std_logic_vector(2 downto 0);
        TXPOWERDOWN0         : in std_logic_vector(1 downto 0);
        TXPOWERDOWN1         : in std_logic_vector(1 downto 0);
        TXPOWERDOWN2         : in std_logic_vector(1 downto 0);
        TXPOWERDOWN3         : in std_logic_vector(1 downto 0);
        TXRATE0              : in std_logic_vector(1 downto 0);
        TXRATE1              : in std_logic_vector(1 downto 0);
        TXRATE2              : in std_logic_vector(1 downto 0);
        TXRATE3              : in std_logic_vector(1 downto 0);
        TXUSERCLKIN0         : in std_ulogic;
        TXUSERCLKIN1         : in std_ulogic;
        TXUSERCLKIN2         : in std_ulogic;
        TXUSERCLKIN3         : in std_ulogic        
      );
    end component;
    
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    function SUL_TO_STR (sul : std_ulogic)
    return string is
    begin
    if sul = '0' then
        return "0";
      else
        return "1";
      end if;
    end SUL_TO_STR;
      
    function boolean_to_string(bool: boolean)
    return string is
    begin
      if bool then
        return "TRUE";
      else
        return "FALSE";
      end if;
    end boolean_to_string;

    function getstrlength(in_vec : std_logic_vector)
    return integer is
      variable string_length : integer;
    begin
      if ((in_vec'length mod 4) = 0) then
        string_length := in_vec'length/4;
      elsif ((in_vec'length mod 4) > 0) then
        string_length := in_vec'length/4 + 1;
      end if;
      return string_length;
    end getstrlength;

    -- Convert bit_vector to std_logic_vector
    constant BER_CONST_PTRN0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(BER_CONST_PTRN0)(15 downto 0);
    constant BER_CONST_PTRN1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(BER_CONST_PTRN1)(15 downto 0);
    constant BUFFER_CONFIG_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(BUFFER_CONFIG_LANE0)(15 downto 0);
    constant BUFFER_CONFIG_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(BUFFER_CONFIG_LANE1)(15 downto 0);
    constant BUFFER_CONFIG_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(BUFFER_CONFIG_LANE2)(15 downto 0);
    constant BUFFER_CONFIG_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(BUFFER_CONFIG_LANE3)(15 downto 0);
    constant DFE_TRAIN_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DFE_TRAIN_CTRL_LANE0)(15 downto 0);
    constant DFE_TRAIN_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DFE_TRAIN_CTRL_LANE1)(15 downto 0);
    constant DFE_TRAIN_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DFE_TRAIN_CTRL_LANE2)(15 downto 0);
    constant DFE_TRAIN_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DFE_TRAIN_CTRL_LANE3)(15 downto 0);
    constant DLL_CFG0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DLL_CFG0)(15 downto 0);
    constant DLL_CFG1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(DLL_CFG1)(15 downto 0);
    constant E10GBASEKR_LD_COEFF_UPD_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LD_COEFF_UPD_LANE0)(15 downto 0);
    constant E10GBASEKR_LD_COEFF_UPD_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LD_COEFF_UPD_LANE1)(15 downto 0);
    constant E10GBASEKR_LD_COEFF_UPD_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LD_COEFF_UPD_LANE2)(15 downto 0);
    constant E10GBASEKR_LD_COEFF_UPD_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LD_COEFF_UPD_LANE3)(15 downto 0);
    constant E10GBASEKR_LP_COEFF_UPD_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LP_COEFF_UPD_LANE0)(15 downto 0);
    constant E10GBASEKR_LP_COEFF_UPD_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LP_COEFF_UPD_LANE1)(15 downto 0);
    constant E10GBASEKR_LP_COEFF_UPD_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LP_COEFF_UPD_LANE2)(15 downto 0);
    constant E10GBASEKR_LP_COEFF_UPD_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_LP_COEFF_UPD_LANE3)(15 downto 0);
    constant E10GBASEKR_PMA_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_PMA_CTRL_LANE0)(15 downto 0);
    constant E10GBASEKR_PMA_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_PMA_CTRL_LANE1)(15 downto 0);
    constant E10GBASEKR_PMA_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_PMA_CTRL_LANE2)(15 downto 0);
    constant E10GBASEKR_PMA_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKR_PMA_CTRL_LANE3)(15 downto 0);
    constant E10GBASEKX_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKX_CTRL_LANE0)(15 downto 0);
    constant E10GBASEKX_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKX_CTRL_LANE1)(15 downto 0);
    constant E10GBASEKX_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKX_CTRL_LANE2)(15 downto 0);
    constant E10GBASEKX_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEKX_CTRL_LANE3)(15 downto 0);
    constant E10GBASER_PCS_CFG_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_CFG_LANE0)(15 downto 0);
    constant E10GBASER_PCS_CFG_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_CFG_LANE1)(15 downto 0);
    constant E10GBASER_PCS_CFG_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_CFG_LANE2)(15 downto 0);
    constant E10GBASER_PCS_CFG_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_CFG_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDA0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA0_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDA0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA0_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDA0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA0_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDA0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA0_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDA1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA1_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDA1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA1_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDA1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA1_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDA1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA1_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDA2_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA2_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDA2_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA2_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDA2_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA2_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDA2_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA2_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDA3_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA3_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDA3_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA3_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDA3_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA3_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDA3_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDA3_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDB0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB0_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDB0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB0_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDB0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB0_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDB0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB0_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDB1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB1_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDB1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB1_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDB1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB1_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDB1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB1_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDB2_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB2_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDB2_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB2_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDB2_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB2_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDB2_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB2_LANE3)(15 downto 0);
    constant E10GBASER_PCS_SEEDB3_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB3_LANE0)(15 downto 0);
    constant E10GBASER_PCS_SEEDB3_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB3_LANE1)(15 downto 0);
    constant E10GBASER_PCS_SEEDB3_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB3_LANE2)(15 downto 0);
    constant E10GBASER_PCS_SEEDB3_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_SEEDB3_LANE3)(15 downto 0);
    constant E10GBASER_PCS_TEST_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_TEST_CTRL_LANE0)(15 downto 0);
    constant E10GBASER_PCS_TEST_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_TEST_CTRL_LANE1)(15 downto 0);
    constant E10GBASER_PCS_TEST_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_TEST_CTRL_LANE2)(15 downto 0);
    constant E10GBASER_PCS_TEST_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASER_PCS_TEST_CTRL_LANE3)(15 downto 0);
    constant E10GBASEX_PCS_TSTCTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEX_PCS_TSTCTRL_LANE0)(15 downto 0);
    constant E10GBASEX_PCS_TSTCTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEX_PCS_TSTCTRL_LANE1)(15 downto 0);
    constant E10GBASEX_PCS_TSTCTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEX_PCS_TSTCTRL_LANE2)(15 downto 0);
    constant E10GBASEX_PCS_TSTCTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(E10GBASEX_PCS_TSTCTRL_LANE3)(15 downto 0);
    constant GLBL0_NOISE_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(GLBL0_NOISE_CTRL)(15 downto 0);
    constant GLBL_AMON_SEL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(GLBL_AMON_SEL)(15 downto 0);
    constant GLBL_DMON_SEL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(GLBL_DMON_SEL)(15 downto 0);
    constant GLBL_PWR_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(GLBL_PWR_CTRL)(15 downto 0);
    constant GTH_CFG_PWRUP_LANE0_BINARY : std_ulogic := To_StduLogic(GTH_CFG_PWRUP_LANE0);
    constant GTH_CFG_PWRUP_LANE1_BINARY : std_ulogic := To_StduLogic(GTH_CFG_PWRUP_LANE1);
    constant GTH_CFG_PWRUP_LANE2_BINARY : std_ulogic := To_StduLogic(GTH_CFG_PWRUP_LANE2);
    constant GTH_CFG_PWRUP_LANE3_BINARY : std_ulogic := To_StduLogic(GTH_CFG_PWRUP_LANE3);
    constant LANE_AMON_SEL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LANE_AMON_SEL)(15 downto 0);
    constant LANE_DMON_SEL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LANE_DMON_SEL)(15 downto 0);
    constant LANE_LNK_CFGOVRD_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LANE_LNK_CFGOVRD)(15 downto 0);
    constant LANE_PWR_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LANE_PWR_CTRL_LANE0)(15 downto 0);
    constant LANE_PWR_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LANE_PWR_CTRL_LANE1)(15 downto 0);
    constant LANE_PWR_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LANE_PWR_CTRL_LANE2)(15 downto 0);
    constant LANE_PWR_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LANE_PWR_CTRL_LANE3)(15 downto 0);
    constant LNK_TRN_CFG_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_CFG_LANE0)(15 downto 0);
    constant LNK_TRN_CFG_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_CFG_LANE1)(15 downto 0);
    constant LNK_TRN_CFG_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_CFG_LANE2)(15 downto 0);
    constant LNK_TRN_CFG_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_CFG_LANE3)(15 downto 0);
    constant LNK_TRN_COEFF_REQ_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_COEFF_REQ_LANE0)(15 downto 0);
    constant LNK_TRN_COEFF_REQ_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_COEFF_REQ_LANE1)(15 downto 0);
    constant LNK_TRN_COEFF_REQ_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_COEFF_REQ_LANE2)(15 downto 0);
    constant LNK_TRN_COEFF_REQ_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(LNK_TRN_COEFF_REQ_LANE3)(15 downto 0);
    constant MISC_CFG_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MISC_CFG)(15 downto 0);
    constant MODE_CFG1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MODE_CFG1)(15 downto 0);
    constant MODE_CFG2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MODE_CFG2)(15 downto 0);
    constant MODE_CFG3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MODE_CFG3)(15 downto 0);
    constant MODE_CFG4_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MODE_CFG4)(15 downto 0);
    constant MODE_CFG5_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MODE_CFG5)(15 downto 0);
    constant MODE_CFG6_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MODE_CFG6)(15 downto 0);
    constant MODE_CFG7_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(MODE_CFG7)(15 downto 0);
    constant PCS_ABILITY_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_ABILITY_LANE0)(15 downto 0);
    constant PCS_ABILITY_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_ABILITY_LANE1)(15 downto 0);
    constant PCS_ABILITY_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_ABILITY_LANE2)(15 downto 0);
    constant PCS_ABILITY_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_ABILITY_LANE3)(15 downto 0);
    constant PCS_CTRL1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL1_LANE0)(15 downto 0);
    constant PCS_CTRL1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL1_LANE1)(15 downto 0);
    constant PCS_CTRL1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL1_LANE2)(15 downto 0);
    constant PCS_CTRL1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL1_LANE3)(15 downto 0);
    constant PCS_CTRL2_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL2_LANE0)(15 downto 0);
    constant PCS_CTRL2_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL2_LANE1)(15 downto 0);
    constant PCS_CTRL2_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL2_LANE2)(15 downto 0);
    constant PCS_CTRL2_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_CTRL2_LANE3)(15 downto 0);
    constant PCS_MISC_CFG_0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_0_LANE0)(15 downto 0);
    constant PCS_MISC_CFG_0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_0_LANE1)(15 downto 0);
    constant PCS_MISC_CFG_0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_0_LANE2)(15 downto 0);
    constant PCS_MISC_CFG_0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_0_LANE3)(15 downto 0);
    constant PCS_MISC_CFG_1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_1_LANE0)(15 downto 0);
    constant PCS_MISC_CFG_1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_1_LANE1)(15 downto 0);
    constant PCS_MISC_CFG_1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_1_LANE2)(15 downto 0);
    constant PCS_MISC_CFG_1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MISC_CFG_1_LANE3)(15 downto 0);
    constant PCS_MODE_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MODE_LANE0)(15 downto 0);
    constant PCS_MODE_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MODE_LANE1)(15 downto 0);
    constant PCS_MODE_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MODE_LANE2)(15 downto 0);
    constant PCS_MODE_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_MODE_LANE3)(15 downto 0);
    constant PCS_RESET_1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_1_LANE0)(15 downto 0);
    constant PCS_RESET_1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_1_LANE1)(15 downto 0);
    constant PCS_RESET_1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_1_LANE2)(15 downto 0);
    constant PCS_RESET_1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_1_LANE3)(15 downto 0);
    constant PCS_RESET_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_LANE0)(15 downto 0);
    constant PCS_RESET_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_LANE1)(15 downto 0);
    constant PCS_RESET_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_LANE2)(15 downto 0);
    constant PCS_RESET_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_RESET_LANE3)(15 downto 0);
    constant PCS_TYPE_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_TYPE_LANE0)(15 downto 0);
    constant PCS_TYPE_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_TYPE_LANE1)(15 downto 0);
    constant PCS_TYPE_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_TYPE_LANE2)(15 downto 0);
    constant PCS_TYPE_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PCS_TYPE_LANE3)(15 downto 0);
    constant PLL_CFG0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PLL_CFG0)(15 downto 0);
    constant PLL_CFG1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PLL_CFG1)(15 downto 0);
    constant PLL_CFG2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PLL_CFG2)(15 downto 0);
    constant PMA_CTRL1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL1_LANE0)(15 downto 0);
    constant PMA_CTRL1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL1_LANE1)(15 downto 0);
    constant PMA_CTRL1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL1_LANE2)(15 downto 0);
    constant PMA_CTRL1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL1_LANE3)(15 downto 0);
    constant PMA_CTRL2_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL2_LANE0)(15 downto 0);
    constant PMA_CTRL2_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL2_LANE1)(15 downto 0);
    constant PMA_CTRL2_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL2_LANE2)(15 downto 0);
    constant PMA_CTRL2_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_CTRL2_LANE3)(15 downto 0);
    constant PMA_LPBK_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_LPBK_CTRL_LANE0)(15 downto 0);
    constant PMA_LPBK_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_LPBK_CTRL_LANE1)(15 downto 0);
    constant PMA_LPBK_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_LPBK_CTRL_LANE2)(15 downto 0);
    constant PMA_LPBK_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PMA_LPBK_CTRL_LANE3)(15 downto 0);
    constant PRBS_BER_CFG0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG0_LANE0)(15 downto 0);
    constant PRBS_BER_CFG0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG0_LANE1)(15 downto 0);
    constant PRBS_BER_CFG0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG0_LANE2)(15 downto 0);
    constant PRBS_BER_CFG0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG0_LANE3)(15 downto 0);
    constant PRBS_BER_CFG1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG1_LANE0)(15 downto 0);
    constant PRBS_BER_CFG1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG1_LANE1)(15 downto 0);
    constant PRBS_BER_CFG1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG1_LANE2)(15 downto 0);
    constant PRBS_BER_CFG1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_BER_CFG1_LANE3)(15 downto 0);
    constant PRBS_CFG_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_CFG_LANE0)(15 downto 0);
    constant PRBS_CFG_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_CFG_LANE1)(15 downto 0);
    constant PRBS_CFG_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_CFG_LANE2)(15 downto 0);
    constant PRBS_CFG_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PRBS_CFG_LANE3)(15 downto 0);
    constant PTRN_CFG0_LSB_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PTRN_CFG0_LSB)(15 downto 0);
    constant PTRN_CFG0_MSB_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PTRN_CFG0_MSB)(15 downto 0);
    constant PTRN_LEN_CFG_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PTRN_LEN_CFG)(15 downto 0);
    constant PWRUP_DLY_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(PWRUP_DLY)(15 downto 0);
    constant RX_AEQ_VAL0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL0_LANE0)(15 downto 0);
    constant RX_AEQ_VAL0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL0_LANE1)(15 downto 0);
    constant RX_AEQ_VAL0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL0_LANE2)(15 downto 0);
    constant RX_AEQ_VAL0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL0_LANE3)(15 downto 0);
    constant RX_AEQ_VAL1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL1_LANE0)(15 downto 0);
    constant RX_AEQ_VAL1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL1_LANE1)(15 downto 0);
    constant RX_AEQ_VAL1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL1_LANE2)(15 downto 0);
    constant RX_AEQ_VAL1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AEQ_VAL1_LANE3)(15 downto 0);
    constant RX_AGC_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AGC_CTRL_LANE0)(15 downto 0);
    constant RX_AGC_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AGC_CTRL_LANE1)(15 downto 0);
    constant RX_AGC_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AGC_CTRL_LANE2)(15 downto 0);
    constant RX_AGC_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_AGC_CTRL_LANE3)(15 downto 0);
    constant RX_CDR_CTRL0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL0_LANE0)(15 downto 0);
    constant RX_CDR_CTRL0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL0_LANE1)(15 downto 0);
    constant RX_CDR_CTRL0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL0_LANE2)(15 downto 0);
    constant RX_CDR_CTRL0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL0_LANE3)(15 downto 0);
    constant RX_CDR_CTRL1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL1_LANE0)(15 downto 0);
    constant RX_CDR_CTRL1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL1_LANE1)(15 downto 0);
    constant RX_CDR_CTRL1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL1_LANE2)(15 downto 0);
    constant RX_CDR_CTRL1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL1_LANE3)(15 downto 0);
    constant RX_CDR_CTRL2_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL2_LANE0)(15 downto 0);
    constant RX_CDR_CTRL2_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL2_LANE1)(15 downto 0);
    constant RX_CDR_CTRL2_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL2_LANE2)(15 downto 0);
    constant RX_CDR_CTRL2_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CDR_CTRL2_LANE3)(15 downto 0);
    constant RX_CFG0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG0_LANE0)(15 downto 0);
    constant RX_CFG0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG0_LANE1)(15 downto 0);
    constant RX_CFG0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG0_LANE2)(15 downto 0);
    constant RX_CFG0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG0_LANE3)(15 downto 0);
    constant RX_CFG1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG1_LANE0)(15 downto 0);
    constant RX_CFG1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG1_LANE1)(15 downto 0);
    constant RX_CFG1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG1_LANE2)(15 downto 0);
    constant RX_CFG1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG1_LANE3)(15 downto 0);
    constant RX_CFG2_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG2_LANE0)(15 downto 0);
    constant RX_CFG2_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG2_LANE1)(15 downto 0);
    constant RX_CFG2_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG2_LANE2)(15 downto 0);
    constant RX_CFG2_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CFG2_LANE3)(15 downto 0);
    constant RX_CTLE_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTLE_CTRL_LANE0)(15 downto 0);
    constant RX_CTLE_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTLE_CTRL_LANE1)(15 downto 0);
    constant RX_CTLE_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTLE_CTRL_LANE2)(15 downto 0);
    constant RX_CTLE_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTLE_CTRL_LANE3)(15 downto 0);
    constant RX_CTRL_OVRD_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTRL_OVRD_LANE0)(15 downto 0);
    constant RX_CTRL_OVRD_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTRL_OVRD_LANE1)(15 downto 0);
    constant RX_CTRL_OVRD_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTRL_OVRD_LANE2)(15 downto 0);
    constant RX_CTRL_OVRD_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_CTRL_OVRD_LANE3)(15 downto 0);
    constant RX_LOOP_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_LOOP_CTRL_LANE0)(15 downto 0);
    constant RX_LOOP_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_LOOP_CTRL_LANE1)(15 downto 0);
    constant RX_LOOP_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_LOOP_CTRL_LANE2)(15 downto 0);
    constant RX_LOOP_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_LOOP_CTRL_LANE3)(15 downto 0);
    constant RX_MVAL0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL0_LANE0)(15 downto 0);
    constant RX_MVAL0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL0_LANE1)(15 downto 0);
    constant RX_MVAL0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL0_LANE2)(15 downto 0);
    constant RX_MVAL0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL0_LANE3)(15 downto 0);
    constant RX_MVAL1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL1_LANE0)(15 downto 0);
    constant RX_MVAL1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL1_LANE1)(15 downto 0);
    constant RX_MVAL1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL1_LANE2)(15 downto 0);
    constant RX_MVAL1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_MVAL1_LANE3)(15 downto 0);
    constant RX_P0S_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_P0S_CTRL)(15 downto 0);
    constant RX_P0_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_P0_CTRL)(15 downto 0);
    constant RX_P1_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_P1_CTRL)(15 downto 0);
    constant RX_P2_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_P2_CTRL)(15 downto 0);
    constant RX_PI_CTRL0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_PI_CTRL0)(15 downto 0);
    constant RX_PI_CTRL1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(RX_PI_CTRL1)(15 downto 0);
    constant SLICE_CFG_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_CFG)(15 downto 0);
    constant SLICE_NOISE_CTRL_0_LANE01_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_NOISE_CTRL_0_LANE01)(15 downto 0);
    constant SLICE_NOISE_CTRL_0_LANE23_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_NOISE_CTRL_0_LANE23)(15 downto 0);
    constant SLICE_NOISE_CTRL_1_LANE01_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_NOISE_CTRL_1_LANE01)(15 downto 0);
    constant SLICE_NOISE_CTRL_1_LANE23_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_NOISE_CTRL_1_LANE23)(15 downto 0);
    constant SLICE_NOISE_CTRL_2_LANE01_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_NOISE_CTRL_2_LANE01)(15 downto 0);
    constant SLICE_NOISE_CTRL_2_LANE23_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_NOISE_CTRL_2_LANE23)(15 downto 0);
    constant SLICE_TX_RESET_LANE01_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_TX_RESET_LANE01)(15 downto 0);
    constant SLICE_TX_RESET_LANE23_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(SLICE_TX_RESET_LANE23)(15 downto 0);
    constant TERM_CTRL_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TERM_CTRL_LANE0)(15 downto 0);
    constant TERM_CTRL_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TERM_CTRL_LANE1)(15 downto 0);
    constant TERM_CTRL_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TERM_CTRL_LANE2)(15 downto 0);
    constant TERM_CTRL_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TERM_CTRL_LANE3)(15 downto 0);
    constant TX_CFG0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG0_LANE0)(15 downto 0);
    constant TX_CFG0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG0_LANE1)(15 downto 0);
    constant TX_CFG0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG0_LANE2)(15 downto 0);
    constant TX_CFG0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG0_LANE3)(15 downto 0);
    constant TX_CFG1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG1_LANE0)(15 downto 0);
    constant TX_CFG1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG1_LANE1)(15 downto 0);
    constant TX_CFG1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG1_LANE2)(15 downto 0);
    constant TX_CFG1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG1_LANE3)(15 downto 0);
    constant TX_CFG2_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG2_LANE0)(15 downto 0);
    constant TX_CFG2_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG2_LANE1)(15 downto 0);
    constant TX_CFG2_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG2_LANE2)(15 downto 0);
    constant TX_CFG2_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CFG2_LANE3)(15 downto 0);
    constant TX_CLK_SEL0_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL0_LANE0)(15 downto 0);
    constant TX_CLK_SEL0_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL0_LANE1)(15 downto 0);
    constant TX_CLK_SEL0_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL0_LANE2)(15 downto 0);
    constant TX_CLK_SEL0_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL0_LANE3)(15 downto 0);
    constant TX_CLK_SEL1_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL1_LANE0)(15 downto 0);
    constant TX_CLK_SEL1_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL1_LANE1)(15 downto 0);
    constant TX_CLK_SEL1_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL1_LANE2)(15 downto 0);
    constant TX_CLK_SEL1_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_CLK_SEL1_LANE3)(15 downto 0);
    constant TX_DISABLE_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_DISABLE_LANE0)(15 downto 0);
    constant TX_DISABLE_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_DISABLE_LANE1)(15 downto 0);
    constant TX_DISABLE_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_DISABLE_LANE2)(15 downto 0);
    constant TX_DISABLE_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_DISABLE_LANE3)(15 downto 0);
    constant TX_P0P0S_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_P0P0S_CTRL)(15 downto 0);
    constant TX_P1P2_CTRL_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_P1P2_CTRL)(15 downto 0);
    constant TX_PREEMPH_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PREEMPH_LANE0)(15 downto 0);
    constant TX_PREEMPH_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PREEMPH_LANE1)(15 downto 0);
    constant TX_PREEMPH_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PREEMPH_LANE2)(15 downto 0);
    constant TX_PREEMPH_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PREEMPH_LANE3)(15 downto 0);
    constant TX_PWR_RATE_OVRD_LANE0_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PWR_RATE_OVRD_LANE0)(15 downto 0);
    constant TX_PWR_RATE_OVRD_LANE1_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PWR_RATE_OVRD_LANE1)(15 downto 0);
    constant TX_PWR_RATE_OVRD_LANE2_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PWR_RATE_OVRD_LANE2)(15 downto 0);
    constant TX_PWR_RATE_OVRD_LANE3_BINARY : std_logic_vector(15 downto 0) := To_StdLogicVector(TX_PWR_RATE_OVRD_LANE3)(15 downto 0);

    --Added for DRC checks
    constant PCS_MODE_LANE0_74 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE0)(7 downto 4);
    constant PCS_MODE_LANE0_30 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE0)(3 downto 0);
    constant PCS_MODE_LANE1_74 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE1)(7 downto 4);
    constant PCS_MODE_LANE1_30 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE1)(3 downto 0);
    constant PCS_MODE_LANE2_74 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE2)(7 downto 4);
    constant PCS_MODE_LANE2_30 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE2)(3 downto 0);
    constant PCS_MODE_LANE3_74 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE3)(7 downto 4);
    constant PCS_MODE_LANE3_30 : std_logic_vector(3 downto 0) := To_StdLogicVector(PCS_MODE_LANE3)(3 downto 0);
      
    -- Get String Length
    constant BER_CONST_PTRN0_STRLEN : integer := getstrlength(BER_CONST_PTRN0_BINARY);
    constant BER_CONST_PTRN1_STRLEN : integer := getstrlength(BER_CONST_PTRN1_BINARY);
    constant BUFFER_CONFIG_LANE0_STRLEN : integer := getstrlength(BUFFER_CONFIG_LANE0_BINARY);
    constant BUFFER_CONFIG_LANE1_STRLEN : integer := getstrlength(BUFFER_CONFIG_LANE1_BINARY);
    constant BUFFER_CONFIG_LANE2_STRLEN : integer := getstrlength(BUFFER_CONFIG_LANE2_BINARY);
    constant BUFFER_CONFIG_LANE3_STRLEN : integer := getstrlength(BUFFER_CONFIG_LANE3_BINARY);
    constant DFE_TRAIN_CTRL_LANE0_STRLEN : integer := getstrlength(DFE_TRAIN_CTRL_LANE0_BINARY);
    constant DFE_TRAIN_CTRL_LANE1_STRLEN : integer := getstrlength(DFE_TRAIN_CTRL_LANE1_BINARY);
    constant DFE_TRAIN_CTRL_LANE2_STRLEN : integer := getstrlength(DFE_TRAIN_CTRL_LANE2_BINARY);
    constant DFE_TRAIN_CTRL_LANE3_STRLEN : integer := getstrlength(DFE_TRAIN_CTRL_LANE3_BINARY);
    constant DLL_CFG0_STRLEN : integer := getstrlength(DLL_CFG0_BINARY);
    constant DLL_CFG1_STRLEN : integer := getstrlength(DLL_CFG1_BINARY);
    constant E10GBASEKR_LD_COEFF_UPD_LANE0_STRLEN : integer := getstrlength(E10GBASEKR_LD_COEFF_UPD_LANE0_BINARY);
    constant E10GBASEKR_LD_COEFF_UPD_LANE1_STRLEN : integer := getstrlength(E10GBASEKR_LD_COEFF_UPD_LANE1_BINARY);
    constant E10GBASEKR_LD_COEFF_UPD_LANE2_STRLEN : integer := getstrlength(E10GBASEKR_LD_COEFF_UPD_LANE2_BINARY);
    constant E10GBASEKR_LD_COEFF_UPD_LANE3_STRLEN : integer := getstrlength(E10GBASEKR_LD_COEFF_UPD_LANE3_BINARY);
    constant E10GBASEKR_LP_COEFF_UPD_LANE0_STRLEN : integer := getstrlength(E10GBASEKR_LP_COEFF_UPD_LANE0_BINARY);
    constant E10GBASEKR_LP_COEFF_UPD_LANE1_STRLEN : integer := getstrlength(E10GBASEKR_LP_COEFF_UPD_LANE1_BINARY);
    constant E10GBASEKR_LP_COEFF_UPD_LANE2_STRLEN : integer := getstrlength(E10GBASEKR_LP_COEFF_UPD_LANE2_BINARY);
    constant E10GBASEKR_LP_COEFF_UPD_LANE3_STRLEN : integer := getstrlength(E10GBASEKR_LP_COEFF_UPD_LANE3_BINARY);
    constant E10GBASEKR_PMA_CTRL_LANE0_STRLEN : integer := getstrlength(E10GBASEKR_PMA_CTRL_LANE0_BINARY);
    constant E10GBASEKR_PMA_CTRL_LANE1_STRLEN : integer := getstrlength(E10GBASEKR_PMA_CTRL_LANE1_BINARY);
    constant E10GBASEKR_PMA_CTRL_LANE2_STRLEN : integer := getstrlength(E10GBASEKR_PMA_CTRL_LANE2_BINARY);
    constant E10GBASEKR_PMA_CTRL_LANE3_STRLEN : integer := getstrlength(E10GBASEKR_PMA_CTRL_LANE3_BINARY);
    constant E10GBASEKX_CTRL_LANE0_STRLEN : integer := getstrlength(E10GBASEKX_CTRL_LANE0_BINARY);
    constant E10GBASEKX_CTRL_LANE1_STRLEN : integer := getstrlength(E10GBASEKX_CTRL_LANE1_BINARY);
    constant E10GBASEKX_CTRL_LANE2_STRLEN : integer := getstrlength(E10GBASEKX_CTRL_LANE2_BINARY);
    constant E10GBASEKX_CTRL_LANE3_STRLEN : integer := getstrlength(E10GBASEKX_CTRL_LANE3_BINARY);
    constant E10GBASER_PCS_CFG_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_CFG_LANE0_BINARY);
    constant E10GBASER_PCS_CFG_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_CFG_LANE1_BINARY);
    constant E10GBASER_PCS_CFG_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_CFG_LANE2_BINARY);
    constant E10GBASER_PCS_CFG_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_CFG_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDA0_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA0_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDA0_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA0_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDA0_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA0_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDA0_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA0_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDA1_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA1_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDA1_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA1_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDA1_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA1_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDA1_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA1_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDA2_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA2_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDA2_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA2_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDA2_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA2_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDA2_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA2_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDA3_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA3_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDA3_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA3_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDA3_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA3_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDA3_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDA3_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDB0_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB0_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDB0_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB0_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDB0_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB0_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDB0_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB0_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDB1_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB1_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDB1_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB1_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDB1_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB1_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDB1_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB1_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDB2_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB2_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDB2_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB2_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDB2_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB2_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDB2_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB2_LANE3_BINARY);
    constant E10GBASER_PCS_SEEDB3_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB3_LANE0_BINARY);
    constant E10GBASER_PCS_SEEDB3_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB3_LANE1_BINARY);
    constant E10GBASER_PCS_SEEDB3_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB3_LANE2_BINARY);
    constant E10GBASER_PCS_SEEDB3_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_SEEDB3_LANE3_BINARY);
    constant E10GBASER_PCS_TEST_CTRL_LANE0_STRLEN : integer := getstrlength(E10GBASER_PCS_TEST_CTRL_LANE0_BINARY);
    constant E10GBASER_PCS_TEST_CTRL_LANE1_STRLEN : integer := getstrlength(E10GBASER_PCS_TEST_CTRL_LANE1_BINARY);
    constant E10GBASER_PCS_TEST_CTRL_LANE2_STRLEN : integer := getstrlength(E10GBASER_PCS_TEST_CTRL_LANE2_BINARY);
    constant E10GBASER_PCS_TEST_CTRL_LANE3_STRLEN : integer := getstrlength(E10GBASER_PCS_TEST_CTRL_LANE3_BINARY);
    constant E10GBASEX_PCS_TSTCTRL_LANE0_STRLEN : integer := getstrlength(E10GBASEX_PCS_TSTCTRL_LANE0_BINARY);
    constant E10GBASEX_PCS_TSTCTRL_LANE1_STRLEN : integer := getstrlength(E10GBASEX_PCS_TSTCTRL_LANE1_BINARY);
    constant E10GBASEX_PCS_TSTCTRL_LANE2_STRLEN : integer := getstrlength(E10GBASEX_PCS_TSTCTRL_LANE2_BINARY);
    constant E10GBASEX_PCS_TSTCTRL_LANE3_STRLEN : integer := getstrlength(E10GBASEX_PCS_TSTCTRL_LANE3_BINARY);
    constant GLBL0_NOISE_CTRL_STRLEN : integer := getstrlength(GLBL0_NOISE_CTRL_BINARY);
    constant GLBL_AMON_SEL_STRLEN : integer := getstrlength(GLBL_AMON_SEL_BINARY);
    constant GLBL_DMON_SEL_STRLEN : integer := getstrlength(GLBL_DMON_SEL_BINARY);
    constant GLBL_PWR_CTRL_STRLEN : integer := getstrlength(GLBL_PWR_CTRL_BINARY);
    constant LANE_AMON_SEL_STRLEN : integer := getstrlength(LANE_AMON_SEL_BINARY);
    constant LANE_DMON_SEL_STRLEN : integer := getstrlength(LANE_DMON_SEL_BINARY);
    constant LANE_LNK_CFGOVRD_STRLEN : integer := getstrlength(LANE_LNK_CFGOVRD_BINARY);
    constant LANE_PWR_CTRL_LANE0_STRLEN : integer := getstrlength(LANE_PWR_CTRL_LANE0_BINARY);
    constant LANE_PWR_CTRL_LANE1_STRLEN : integer := getstrlength(LANE_PWR_CTRL_LANE1_BINARY);
    constant LANE_PWR_CTRL_LANE2_STRLEN : integer := getstrlength(LANE_PWR_CTRL_LANE2_BINARY);
    constant LANE_PWR_CTRL_LANE3_STRLEN : integer := getstrlength(LANE_PWR_CTRL_LANE3_BINARY);
    constant LNK_TRN_CFG_LANE0_STRLEN : integer := getstrlength(LNK_TRN_CFG_LANE0_BINARY);
    constant LNK_TRN_CFG_LANE1_STRLEN : integer := getstrlength(LNK_TRN_CFG_LANE1_BINARY);
    constant LNK_TRN_CFG_LANE2_STRLEN : integer := getstrlength(LNK_TRN_CFG_LANE2_BINARY);
    constant LNK_TRN_CFG_LANE3_STRLEN : integer := getstrlength(LNK_TRN_CFG_LANE3_BINARY);
    constant LNK_TRN_COEFF_REQ_LANE0_STRLEN : integer := getstrlength(LNK_TRN_COEFF_REQ_LANE0_BINARY);
    constant LNK_TRN_COEFF_REQ_LANE1_STRLEN : integer := getstrlength(LNK_TRN_COEFF_REQ_LANE1_BINARY);
    constant LNK_TRN_COEFF_REQ_LANE2_STRLEN : integer := getstrlength(LNK_TRN_COEFF_REQ_LANE2_BINARY);
    constant LNK_TRN_COEFF_REQ_LANE3_STRLEN : integer := getstrlength(LNK_TRN_COEFF_REQ_LANE3_BINARY);
    constant MISC_CFG_STRLEN : integer := getstrlength(MISC_CFG_BINARY);
    constant MODE_CFG1_STRLEN : integer := getstrlength(MODE_CFG1_BINARY);
    constant MODE_CFG2_STRLEN : integer := getstrlength(MODE_CFG2_BINARY);
    constant MODE_CFG3_STRLEN : integer := getstrlength(MODE_CFG3_BINARY);
    constant MODE_CFG4_STRLEN : integer := getstrlength(MODE_CFG4_BINARY);
    constant MODE_CFG5_STRLEN : integer := getstrlength(MODE_CFG5_BINARY);
    constant MODE_CFG6_STRLEN : integer := getstrlength(MODE_CFG6_BINARY);
    constant MODE_CFG7_STRLEN : integer := getstrlength(MODE_CFG7_BINARY);
    constant PCS_ABILITY_LANE0_STRLEN : integer := getstrlength(PCS_ABILITY_LANE0_BINARY);
    constant PCS_ABILITY_LANE1_STRLEN : integer := getstrlength(PCS_ABILITY_LANE1_BINARY);
    constant PCS_ABILITY_LANE2_STRLEN : integer := getstrlength(PCS_ABILITY_LANE2_BINARY);
    constant PCS_ABILITY_LANE3_STRLEN : integer := getstrlength(PCS_ABILITY_LANE3_BINARY);
    constant PCS_CTRL1_LANE0_STRLEN : integer := getstrlength(PCS_CTRL1_LANE0_BINARY);
    constant PCS_CTRL1_LANE1_STRLEN : integer := getstrlength(PCS_CTRL1_LANE1_BINARY);
    constant PCS_CTRL1_LANE2_STRLEN : integer := getstrlength(PCS_CTRL1_LANE2_BINARY);
    constant PCS_CTRL1_LANE3_STRLEN : integer := getstrlength(PCS_CTRL1_LANE3_BINARY);
    constant PCS_CTRL2_LANE0_STRLEN : integer := getstrlength(PCS_CTRL2_LANE0_BINARY);
    constant PCS_CTRL2_LANE1_STRLEN : integer := getstrlength(PCS_CTRL2_LANE1_BINARY);
    constant PCS_CTRL2_LANE2_STRLEN : integer := getstrlength(PCS_CTRL2_LANE2_BINARY);
    constant PCS_CTRL2_LANE3_STRLEN : integer := getstrlength(PCS_CTRL2_LANE3_BINARY);
    constant PCS_MISC_CFG_0_LANE0_STRLEN : integer := getstrlength(PCS_MISC_CFG_0_LANE0_BINARY);
    constant PCS_MISC_CFG_0_LANE1_STRLEN : integer := getstrlength(PCS_MISC_CFG_0_LANE1_BINARY);
    constant PCS_MISC_CFG_0_LANE2_STRLEN : integer := getstrlength(PCS_MISC_CFG_0_LANE2_BINARY);
    constant PCS_MISC_CFG_0_LANE3_STRLEN : integer := getstrlength(PCS_MISC_CFG_0_LANE3_BINARY);
    constant PCS_MISC_CFG_1_LANE0_STRLEN : integer := getstrlength(PCS_MISC_CFG_1_LANE0_BINARY);
    constant PCS_MISC_CFG_1_LANE1_STRLEN : integer := getstrlength(PCS_MISC_CFG_1_LANE1_BINARY);
    constant PCS_MISC_CFG_1_LANE2_STRLEN : integer := getstrlength(PCS_MISC_CFG_1_LANE2_BINARY);
    constant PCS_MISC_CFG_1_LANE3_STRLEN : integer := getstrlength(PCS_MISC_CFG_1_LANE3_BINARY);
    constant PCS_MODE_LANE0_STRLEN : integer := getstrlength(PCS_MODE_LANE0_BINARY);
    constant PCS_MODE_LANE1_STRLEN : integer := getstrlength(PCS_MODE_LANE1_BINARY);
    constant PCS_MODE_LANE2_STRLEN : integer := getstrlength(PCS_MODE_LANE2_BINARY);
    constant PCS_MODE_LANE3_STRLEN : integer := getstrlength(PCS_MODE_LANE3_BINARY);
    constant PCS_RESET_1_LANE0_STRLEN : integer := getstrlength(PCS_RESET_1_LANE0_BINARY);
    constant PCS_RESET_1_LANE1_STRLEN : integer := getstrlength(PCS_RESET_1_LANE1_BINARY);
    constant PCS_RESET_1_LANE2_STRLEN : integer := getstrlength(PCS_RESET_1_LANE2_BINARY);
    constant PCS_RESET_1_LANE3_STRLEN : integer := getstrlength(PCS_RESET_1_LANE3_BINARY);
    constant PCS_RESET_LANE0_STRLEN : integer := getstrlength(PCS_RESET_LANE0_BINARY);
    constant PCS_RESET_LANE1_STRLEN : integer := getstrlength(PCS_RESET_LANE1_BINARY);
    constant PCS_RESET_LANE2_STRLEN : integer := getstrlength(PCS_RESET_LANE2_BINARY);
    constant PCS_RESET_LANE3_STRLEN : integer := getstrlength(PCS_RESET_LANE3_BINARY);
    constant PCS_TYPE_LANE0_STRLEN : integer := getstrlength(PCS_TYPE_LANE0_BINARY);
    constant PCS_TYPE_LANE1_STRLEN : integer := getstrlength(PCS_TYPE_LANE1_BINARY);
    constant PCS_TYPE_LANE2_STRLEN : integer := getstrlength(PCS_TYPE_LANE2_BINARY);
    constant PCS_TYPE_LANE3_STRLEN : integer := getstrlength(PCS_TYPE_LANE3_BINARY);
    constant PLL_CFG0_STRLEN : integer := getstrlength(PLL_CFG0_BINARY);
    constant PLL_CFG1_STRLEN : integer := getstrlength(PLL_CFG1_BINARY);
    constant PLL_CFG2_STRLEN : integer := getstrlength(PLL_CFG2_BINARY);
    constant PMA_CTRL1_LANE0_STRLEN : integer := getstrlength(PMA_CTRL1_LANE0_BINARY);
    constant PMA_CTRL1_LANE1_STRLEN : integer := getstrlength(PMA_CTRL1_LANE1_BINARY);
    constant PMA_CTRL1_LANE2_STRLEN : integer := getstrlength(PMA_CTRL1_LANE2_BINARY);
    constant PMA_CTRL1_LANE3_STRLEN : integer := getstrlength(PMA_CTRL1_LANE3_BINARY);
    constant PMA_CTRL2_LANE0_STRLEN : integer := getstrlength(PMA_CTRL2_LANE0_BINARY);
    constant PMA_CTRL2_LANE1_STRLEN : integer := getstrlength(PMA_CTRL2_LANE1_BINARY);
    constant PMA_CTRL2_LANE2_STRLEN : integer := getstrlength(PMA_CTRL2_LANE2_BINARY);
    constant PMA_CTRL2_LANE3_STRLEN : integer := getstrlength(PMA_CTRL2_LANE3_BINARY);
    constant PMA_LPBK_CTRL_LANE0_STRLEN : integer := getstrlength(PMA_LPBK_CTRL_LANE0_BINARY);
    constant PMA_LPBK_CTRL_LANE1_STRLEN : integer := getstrlength(PMA_LPBK_CTRL_LANE1_BINARY);
    constant PMA_LPBK_CTRL_LANE2_STRLEN : integer := getstrlength(PMA_LPBK_CTRL_LANE2_BINARY);
    constant PMA_LPBK_CTRL_LANE3_STRLEN : integer := getstrlength(PMA_LPBK_CTRL_LANE3_BINARY);
    constant PRBS_BER_CFG0_LANE0_STRLEN : integer := getstrlength(PRBS_BER_CFG0_LANE0_BINARY);
    constant PRBS_BER_CFG0_LANE1_STRLEN : integer := getstrlength(PRBS_BER_CFG0_LANE1_BINARY);
    constant PRBS_BER_CFG0_LANE2_STRLEN : integer := getstrlength(PRBS_BER_CFG0_LANE2_BINARY);
    constant PRBS_BER_CFG0_LANE3_STRLEN : integer := getstrlength(PRBS_BER_CFG0_LANE3_BINARY);
    constant PRBS_BER_CFG1_LANE0_STRLEN : integer := getstrlength(PRBS_BER_CFG1_LANE0_BINARY);
    constant PRBS_BER_CFG1_LANE1_STRLEN : integer := getstrlength(PRBS_BER_CFG1_LANE1_BINARY);
    constant PRBS_BER_CFG1_LANE2_STRLEN : integer := getstrlength(PRBS_BER_CFG1_LANE2_BINARY);
    constant PRBS_BER_CFG1_LANE3_STRLEN : integer := getstrlength(PRBS_BER_CFG1_LANE3_BINARY);
    constant PRBS_CFG_LANE0_STRLEN : integer := getstrlength(PRBS_CFG_LANE0_BINARY);
    constant PRBS_CFG_LANE1_STRLEN : integer := getstrlength(PRBS_CFG_LANE1_BINARY);
    constant PRBS_CFG_LANE2_STRLEN : integer := getstrlength(PRBS_CFG_LANE2_BINARY);
    constant PRBS_CFG_LANE3_STRLEN : integer := getstrlength(PRBS_CFG_LANE3_BINARY);
    constant PTRN_CFG0_LSB_STRLEN : integer := getstrlength(PTRN_CFG0_LSB_BINARY);
    constant PTRN_CFG0_MSB_STRLEN : integer := getstrlength(PTRN_CFG0_MSB_BINARY);
    constant PTRN_LEN_CFG_STRLEN : integer := getstrlength(PTRN_LEN_CFG_BINARY);
    constant PWRUP_DLY_STRLEN : integer := getstrlength(PWRUP_DLY_BINARY);
    constant RX_AEQ_VAL0_LANE0_STRLEN : integer := getstrlength(RX_AEQ_VAL0_LANE0_BINARY);
    constant RX_AEQ_VAL0_LANE1_STRLEN : integer := getstrlength(RX_AEQ_VAL0_LANE1_BINARY);
    constant RX_AEQ_VAL0_LANE2_STRLEN : integer := getstrlength(RX_AEQ_VAL0_LANE2_BINARY);
    constant RX_AEQ_VAL0_LANE3_STRLEN : integer := getstrlength(RX_AEQ_VAL0_LANE3_BINARY);
    constant RX_AEQ_VAL1_LANE0_STRLEN : integer := getstrlength(RX_AEQ_VAL1_LANE0_BINARY);
    constant RX_AEQ_VAL1_LANE1_STRLEN : integer := getstrlength(RX_AEQ_VAL1_LANE1_BINARY);
    constant RX_AEQ_VAL1_LANE2_STRLEN : integer := getstrlength(RX_AEQ_VAL1_LANE2_BINARY);
    constant RX_AEQ_VAL1_LANE3_STRLEN : integer := getstrlength(RX_AEQ_VAL1_LANE3_BINARY);
    constant RX_AGC_CTRL_LANE0_STRLEN : integer := getstrlength(RX_AGC_CTRL_LANE0_BINARY);
    constant RX_AGC_CTRL_LANE1_STRLEN : integer := getstrlength(RX_AGC_CTRL_LANE1_BINARY);
    constant RX_AGC_CTRL_LANE2_STRLEN : integer := getstrlength(RX_AGC_CTRL_LANE2_BINARY);
    constant RX_AGC_CTRL_LANE3_STRLEN : integer := getstrlength(RX_AGC_CTRL_LANE3_BINARY);
    constant RX_CDR_CTRL0_LANE0_STRLEN : integer := getstrlength(RX_CDR_CTRL0_LANE0_BINARY);
    constant RX_CDR_CTRL0_LANE1_STRLEN : integer := getstrlength(RX_CDR_CTRL0_LANE1_BINARY);
    constant RX_CDR_CTRL0_LANE2_STRLEN : integer := getstrlength(RX_CDR_CTRL0_LANE2_BINARY);
    constant RX_CDR_CTRL0_LANE3_STRLEN : integer := getstrlength(RX_CDR_CTRL0_LANE3_BINARY);
    constant RX_CDR_CTRL1_LANE0_STRLEN : integer := getstrlength(RX_CDR_CTRL1_LANE0_BINARY);
    constant RX_CDR_CTRL1_LANE1_STRLEN : integer := getstrlength(RX_CDR_CTRL1_LANE1_BINARY);
    constant RX_CDR_CTRL1_LANE2_STRLEN : integer := getstrlength(RX_CDR_CTRL1_LANE2_BINARY);
    constant RX_CDR_CTRL1_LANE3_STRLEN : integer := getstrlength(RX_CDR_CTRL1_LANE3_BINARY);
    constant RX_CDR_CTRL2_LANE0_STRLEN : integer := getstrlength(RX_CDR_CTRL2_LANE0_BINARY);
    constant RX_CDR_CTRL2_LANE1_STRLEN : integer := getstrlength(RX_CDR_CTRL2_LANE1_BINARY);
    constant RX_CDR_CTRL2_LANE2_STRLEN : integer := getstrlength(RX_CDR_CTRL2_LANE2_BINARY);
    constant RX_CDR_CTRL2_LANE3_STRLEN : integer := getstrlength(RX_CDR_CTRL2_LANE3_BINARY);
    constant RX_CFG0_LANE0_STRLEN : integer := getstrlength(RX_CFG0_LANE0_BINARY);
    constant RX_CFG0_LANE1_STRLEN : integer := getstrlength(RX_CFG0_LANE1_BINARY);
    constant RX_CFG0_LANE2_STRLEN : integer := getstrlength(RX_CFG0_LANE2_BINARY);
    constant RX_CFG0_LANE3_STRLEN : integer := getstrlength(RX_CFG0_LANE3_BINARY);
    constant RX_CFG1_LANE0_STRLEN : integer := getstrlength(RX_CFG1_LANE0_BINARY);
    constant RX_CFG1_LANE1_STRLEN : integer := getstrlength(RX_CFG1_LANE1_BINARY);
    constant RX_CFG1_LANE2_STRLEN : integer := getstrlength(RX_CFG1_LANE2_BINARY);
    constant RX_CFG1_LANE3_STRLEN : integer := getstrlength(RX_CFG1_LANE3_BINARY);
    constant RX_CFG2_LANE0_STRLEN : integer := getstrlength(RX_CFG2_LANE0_BINARY);
    constant RX_CFG2_LANE1_STRLEN : integer := getstrlength(RX_CFG2_LANE1_BINARY);
    constant RX_CFG2_LANE2_STRLEN : integer := getstrlength(RX_CFG2_LANE2_BINARY);
    constant RX_CFG2_LANE3_STRLEN : integer := getstrlength(RX_CFG2_LANE3_BINARY);
    constant RX_CTLE_CTRL_LANE0_STRLEN : integer := getstrlength(RX_CTLE_CTRL_LANE0_BINARY);
    constant RX_CTLE_CTRL_LANE1_STRLEN : integer := getstrlength(RX_CTLE_CTRL_LANE1_BINARY);
    constant RX_CTLE_CTRL_LANE2_STRLEN : integer := getstrlength(RX_CTLE_CTRL_LANE2_BINARY);
    constant RX_CTLE_CTRL_LANE3_STRLEN : integer := getstrlength(RX_CTLE_CTRL_LANE3_BINARY);
    constant RX_CTRL_OVRD_LANE0_STRLEN : integer := getstrlength(RX_CTRL_OVRD_LANE0_BINARY);
    constant RX_CTRL_OVRD_LANE1_STRLEN : integer := getstrlength(RX_CTRL_OVRD_LANE1_BINARY);
    constant RX_CTRL_OVRD_LANE2_STRLEN : integer := getstrlength(RX_CTRL_OVRD_LANE2_BINARY);
    constant RX_CTRL_OVRD_LANE3_STRLEN : integer := getstrlength(RX_CTRL_OVRD_LANE3_BINARY);
    constant RX_LOOP_CTRL_LANE0_STRLEN : integer := getstrlength(RX_LOOP_CTRL_LANE0_BINARY);
    constant RX_LOOP_CTRL_LANE1_STRLEN : integer := getstrlength(RX_LOOP_CTRL_LANE1_BINARY);
    constant RX_LOOP_CTRL_LANE2_STRLEN : integer := getstrlength(RX_LOOP_CTRL_LANE2_BINARY);
    constant RX_LOOP_CTRL_LANE3_STRLEN : integer := getstrlength(RX_LOOP_CTRL_LANE3_BINARY);
    constant RX_MVAL0_LANE0_STRLEN : integer := getstrlength(RX_MVAL0_LANE0_BINARY);
    constant RX_MVAL0_LANE1_STRLEN : integer := getstrlength(RX_MVAL0_LANE1_BINARY);
    constant RX_MVAL0_LANE2_STRLEN : integer := getstrlength(RX_MVAL0_LANE2_BINARY);
    constant RX_MVAL0_LANE3_STRLEN : integer := getstrlength(RX_MVAL0_LANE3_BINARY);
    constant RX_MVAL1_LANE0_STRLEN : integer := getstrlength(RX_MVAL1_LANE0_BINARY);
    constant RX_MVAL1_LANE1_STRLEN : integer := getstrlength(RX_MVAL1_LANE1_BINARY);
    constant RX_MVAL1_LANE2_STRLEN : integer := getstrlength(RX_MVAL1_LANE2_BINARY);
    constant RX_MVAL1_LANE3_STRLEN : integer := getstrlength(RX_MVAL1_LANE3_BINARY);
    constant RX_P0S_CTRL_STRLEN : integer := getstrlength(RX_P0S_CTRL_BINARY);
    constant RX_P0_CTRL_STRLEN : integer := getstrlength(RX_P0_CTRL_BINARY);
    constant RX_P1_CTRL_STRLEN : integer := getstrlength(RX_P1_CTRL_BINARY);
    constant RX_P2_CTRL_STRLEN : integer := getstrlength(RX_P2_CTRL_BINARY);
    constant RX_PI_CTRL0_STRLEN : integer := getstrlength(RX_PI_CTRL0_BINARY);
    constant RX_PI_CTRL1_STRLEN : integer := getstrlength(RX_PI_CTRL1_BINARY);
    constant SLICE_CFG_STRLEN : integer := getstrlength(SLICE_CFG_BINARY);
    constant SLICE_NOISE_CTRL_0_LANE01_STRLEN : integer := getstrlength(SLICE_NOISE_CTRL_0_LANE01_BINARY);
    constant SLICE_NOISE_CTRL_0_LANE23_STRLEN : integer := getstrlength(SLICE_NOISE_CTRL_0_LANE23_BINARY);
    constant SLICE_NOISE_CTRL_1_LANE01_STRLEN : integer := getstrlength(SLICE_NOISE_CTRL_1_LANE01_BINARY);
    constant SLICE_NOISE_CTRL_1_LANE23_STRLEN : integer := getstrlength(SLICE_NOISE_CTRL_1_LANE23_BINARY);
    constant SLICE_NOISE_CTRL_2_LANE01_STRLEN : integer := getstrlength(SLICE_NOISE_CTRL_2_LANE01_BINARY);
    constant SLICE_NOISE_CTRL_2_LANE23_STRLEN : integer := getstrlength(SLICE_NOISE_CTRL_2_LANE23_BINARY);
    constant SLICE_TX_RESET_LANE01_STRLEN : integer := getstrlength(SLICE_TX_RESET_LANE01_BINARY);
    constant SLICE_TX_RESET_LANE23_STRLEN : integer := getstrlength(SLICE_TX_RESET_LANE23_BINARY);
    constant TERM_CTRL_LANE0_STRLEN : integer := getstrlength(TERM_CTRL_LANE0_BINARY);
    constant TERM_CTRL_LANE1_STRLEN : integer := getstrlength(TERM_CTRL_LANE1_BINARY);
    constant TERM_CTRL_LANE2_STRLEN : integer := getstrlength(TERM_CTRL_LANE2_BINARY);
    constant TERM_CTRL_LANE3_STRLEN : integer := getstrlength(TERM_CTRL_LANE3_BINARY);
    constant TX_CFG0_LANE0_STRLEN : integer := getstrlength(TX_CFG0_LANE0_BINARY);
    constant TX_CFG0_LANE1_STRLEN : integer := getstrlength(TX_CFG0_LANE1_BINARY);
    constant TX_CFG0_LANE2_STRLEN : integer := getstrlength(TX_CFG0_LANE2_BINARY);
    constant TX_CFG0_LANE3_STRLEN : integer := getstrlength(TX_CFG0_LANE3_BINARY);
    constant TX_CFG1_LANE0_STRLEN : integer := getstrlength(TX_CFG1_LANE0_BINARY);
    constant TX_CFG1_LANE1_STRLEN : integer := getstrlength(TX_CFG1_LANE1_BINARY);
    constant TX_CFG1_LANE2_STRLEN : integer := getstrlength(TX_CFG1_LANE2_BINARY);
    constant TX_CFG1_LANE3_STRLEN : integer := getstrlength(TX_CFG1_LANE3_BINARY);
    constant TX_CFG2_LANE0_STRLEN : integer := getstrlength(TX_CFG2_LANE0_BINARY);
    constant TX_CFG2_LANE1_STRLEN : integer := getstrlength(TX_CFG2_LANE1_BINARY);
    constant TX_CFG2_LANE2_STRLEN : integer := getstrlength(TX_CFG2_LANE2_BINARY);
    constant TX_CFG2_LANE3_STRLEN : integer := getstrlength(TX_CFG2_LANE3_BINARY);
    constant TX_CLK_SEL0_LANE0_STRLEN : integer := getstrlength(TX_CLK_SEL0_LANE0_BINARY);
    constant TX_CLK_SEL0_LANE1_STRLEN : integer := getstrlength(TX_CLK_SEL0_LANE1_BINARY);
    constant TX_CLK_SEL0_LANE2_STRLEN : integer := getstrlength(TX_CLK_SEL0_LANE2_BINARY);
    constant TX_CLK_SEL0_LANE3_STRLEN : integer := getstrlength(TX_CLK_SEL0_LANE3_BINARY);
    constant TX_CLK_SEL1_LANE0_STRLEN : integer := getstrlength(TX_CLK_SEL1_LANE0_BINARY);
    constant TX_CLK_SEL1_LANE1_STRLEN : integer := getstrlength(TX_CLK_SEL1_LANE1_BINARY);
    constant TX_CLK_SEL1_LANE2_STRLEN : integer := getstrlength(TX_CLK_SEL1_LANE2_BINARY);
    constant TX_CLK_SEL1_LANE3_STRLEN : integer := getstrlength(TX_CLK_SEL1_LANE3_BINARY);
    constant TX_DISABLE_LANE0_STRLEN : integer := getstrlength(TX_DISABLE_LANE0_BINARY);
    constant TX_DISABLE_LANE1_STRLEN : integer := getstrlength(TX_DISABLE_LANE1_BINARY);
    constant TX_DISABLE_LANE2_STRLEN : integer := getstrlength(TX_DISABLE_LANE2_BINARY);
    constant TX_DISABLE_LANE3_STRLEN : integer := getstrlength(TX_DISABLE_LANE3_BINARY);
    constant TX_P0P0S_CTRL_STRLEN : integer := getstrlength(TX_P0P0S_CTRL_BINARY);
    constant TX_P1P2_CTRL_STRLEN : integer := getstrlength(TX_P1P2_CTRL_BINARY);
    constant TX_PREEMPH_LANE0_STRLEN : integer := getstrlength(TX_PREEMPH_LANE0_BINARY);
    constant TX_PREEMPH_LANE1_STRLEN : integer := getstrlength(TX_PREEMPH_LANE1_BINARY);
    constant TX_PREEMPH_LANE2_STRLEN : integer := getstrlength(TX_PREEMPH_LANE2_BINARY);
    constant TX_PREEMPH_LANE3_STRLEN : integer := getstrlength(TX_PREEMPH_LANE3_BINARY);
    constant TX_PWR_RATE_OVRD_LANE0_STRLEN : integer := getstrlength(TX_PWR_RATE_OVRD_LANE0_BINARY);
    constant TX_PWR_RATE_OVRD_LANE1_STRLEN : integer := getstrlength(TX_PWR_RATE_OVRD_LANE1_BINARY);
    constant TX_PWR_RATE_OVRD_LANE2_STRLEN : integer := getstrlength(TX_PWR_RATE_OVRD_LANE2_BINARY);
    constant TX_PWR_RATE_OVRD_LANE3_STRLEN : integer := getstrlength(TX_PWR_RATE_OVRD_LANE3_BINARY);
    
    -- Convert std_logic_vector to string
    constant BER_CONST_PTRN0_STRING : string := SLV_TO_HEX(BER_CONST_PTRN0_BINARY, BER_CONST_PTRN0_STRLEN);
    constant BER_CONST_PTRN1_STRING : string := SLV_TO_HEX(BER_CONST_PTRN1_BINARY, BER_CONST_PTRN1_STRLEN);
    constant BUFFER_CONFIG_LANE0_STRING : string := SLV_TO_HEX(BUFFER_CONFIG_LANE0_BINARY, BUFFER_CONFIG_LANE0_STRLEN);
    constant BUFFER_CONFIG_LANE1_STRING : string := SLV_TO_HEX(BUFFER_CONFIG_LANE1_BINARY, BUFFER_CONFIG_LANE1_STRLEN);
    constant BUFFER_CONFIG_LANE2_STRING : string := SLV_TO_HEX(BUFFER_CONFIG_LANE2_BINARY, BUFFER_CONFIG_LANE2_STRLEN);
    constant BUFFER_CONFIG_LANE3_STRING : string := SLV_TO_HEX(BUFFER_CONFIG_LANE3_BINARY, BUFFER_CONFIG_LANE3_STRLEN);
    constant DFE_TRAIN_CTRL_LANE0_STRING : string := SLV_TO_HEX(DFE_TRAIN_CTRL_LANE0_BINARY, DFE_TRAIN_CTRL_LANE0_STRLEN);
    constant DFE_TRAIN_CTRL_LANE1_STRING : string := SLV_TO_HEX(DFE_TRAIN_CTRL_LANE1_BINARY, DFE_TRAIN_CTRL_LANE1_STRLEN);
    constant DFE_TRAIN_CTRL_LANE2_STRING : string := SLV_TO_HEX(DFE_TRAIN_CTRL_LANE2_BINARY, DFE_TRAIN_CTRL_LANE2_STRLEN);
    constant DFE_TRAIN_CTRL_LANE3_STRING : string := SLV_TO_HEX(DFE_TRAIN_CTRL_LANE3_BINARY, DFE_TRAIN_CTRL_LANE3_STRLEN);
    constant DLL_CFG0_STRING : string := SLV_TO_HEX(DLL_CFG0_BINARY, DLL_CFG0_STRLEN);
    constant DLL_CFG1_STRING : string := SLV_TO_HEX(DLL_CFG1_BINARY, DLL_CFG1_STRLEN);
    constant E10GBASEKR_LD_COEFF_UPD_LANE0_STRING : string := SLV_TO_HEX(E10GBASEKR_LD_COEFF_UPD_LANE0_BINARY, E10GBASEKR_LD_COEFF_UPD_LANE0_STRLEN);
    constant E10GBASEKR_LD_COEFF_UPD_LANE1_STRING : string := SLV_TO_HEX(E10GBASEKR_LD_COEFF_UPD_LANE1_BINARY, E10GBASEKR_LD_COEFF_UPD_LANE1_STRLEN);
    constant E10GBASEKR_LD_COEFF_UPD_LANE2_STRING : string := SLV_TO_HEX(E10GBASEKR_LD_COEFF_UPD_LANE2_BINARY, E10GBASEKR_LD_COEFF_UPD_LANE2_STRLEN);
    constant E10GBASEKR_LD_COEFF_UPD_LANE3_STRING : string := SLV_TO_HEX(E10GBASEKR_LD_COEFF_UPD_LANE3_BINARY, E10GBASEKR_LD_COEFF_UPD_LANE3_STRLEN);
    constant E10GBASEKR_LP_COEFF_UPD_LANE0_STRING : string := SLV_TO_HEX(E10GBASEKR_LP_COEFF_UPD_LANE0_BINARY, E10GBASEKR_LP_COEFF_UPD_LANE0_STRLEN);
    constant E10GBASEKR_LP_COEFF_UPD_LANE1_STRING : string := SLV_TO_HEX(E10GBASEKR_LP_COEFF_UPD_LANE1_BINARY, E10GBASEKR_LP_COEFF_UPD_LANE1_STRLEN);
    constant E10GBASEKR_LP_COEFF_UPD_LANE2_STRING : string := SLV_TO_HEX(E10GBASEKR_LP_COEFF_UPD_LANE2_BINARY, E10GBASEKR_LP_COEFF_UPD_LANE2_STRLEN);
    constant E10GBASEKR_LP_COEFF_UPD_LANE3_STRING : string := SLV_TO_HEX(E10GBASEKR_LP_COEFF_UPD_LANE3_BINARY, E10GBASEKR_LP_COEFF_UPD_LANE3_STRLEN);
    constant E10GBASEKR_PMA_CTRL_LANE0_STRING : string := SLV_TO_HEX(E10GBASEKR_PMA_CTRL_LANE0_BINARY, E10GBASEKR_PMA_CTRL_LANE0_STRLEN);
    constant E10GBASEKR_PMA_CTRL_LANE1_STRING : string := SLV_TO_HEX(E10GBASEKR_PMA_CTRL_LANE1_BINARY, E10GBASEKR_PMA_CTRL_LANE1_STRLEN);
    constant E10GBASEKR_PMA_CTRL_LANE2_STRING : string := SLV_TO_HEX(E10GBASEKR_PMA_CTRL_LANE2_BINARY, E10GBASEKR_PMA_CTRL_LANE2_STRLEN);
    constant E10GBASEKR_PMA_CTRL_LANE3_STRING : string := SLV_TO_HEX(E10GBASEKR_PMA_CTRL_LANE3_BINARY, E10GBASEKR_PMA_CTRL_LANE3_STRLEN);
    constant E10GBASEKX_CTRL_LANE0_STRING : string := SLV_TO_HEX(E10GBASEKX_CTRL_LANE0_BINARY, E10GBASEKX_CTRL_LANE0_STRLEN);
    constant E10GBASEKX_CTRL_LANE1_STRING : string := SLV_TO_HEX(E10GBASEKX_CTRL_LANE1_BINARY, E10GBASEKX_CTRL_LANE1_STRLEN);
    constant E10GBASEKX_CTRL_LANE2_STRING : string := SLV_TO_HEX(E10GBASEKX_CTRL_LANE2_BINARY, E10GBASEKX_CTRL_LANE2_STRLEN);
    constant E10GBASEKX_CTRL_LANE3_STRING : string := SLV_TO_HEX(E10GBASEKX_CTRL_LANE3_BINARY, E10GBASEKX_CTRL_LANE3_STRLEN);
    constant E10GBASER_PCS_CFG_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_CFG_LANE0_BINARY, E10GBASER_PCS_CFG_LANE0_STRLEN);
    constant E10GBASER_PCS_CFG_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_CFG_LANE1_BINARY, E10GBASER_PCS_CFG_LANE1_STRLEN);
    constant E10GBASER_PCS_CFG_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_CFG_LANE2_BINARY, E10GBASER_PCS_CFG_LANE2_STRLEN);
    constant E10GBASER_PCS_CFG_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_CFG_LANE3_BINARY, E10GBASER_PCS_CFG_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDA0_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA0_LANE0_BINARY, E10GBASER_PCS_SEEDA0_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDA0_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA0_LANE1_BINARY, E10GBASER_PCS_SEEDA0_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDA0_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA0_LANE2_BINARY, E10GBASER_PCS_SEEDA0_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDA0_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA0_LANE3_BINARY, E10GBASER_PCS_SEEDA0_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDA1_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA1_LANE0_BINARY, E10GBASER_PCS_SEEDA1_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDA1_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA1_LANE1_BINARY, E10GBASER_PCS_SEEDA1_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDA1_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA1_LANE2_BINARY, E10GBASER_PCS_SEEDA1_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDA1_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA1_LANE3_BINARY, E10GBASER_PCS_SEEDA1_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDA2_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA2_LANE0_BINARY, E10GBASER_PCS_SEEDA2_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDA2_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA2_LANE1_BINARY, E10GBASER_PCS_SEEDA2_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDA2_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA2_LANE2_BINARY, E10GBASER_PCS_SEEDA2_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDA2_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA2_LANE3_BINARY, E10GBASER_PCS_SEEDA2_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDA3_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA3_LANE0_BINARY, E10GBASER_PCS_SEEDA3_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDA3_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA3_LANE1_BINARY, E10GBASER_PCS_SEEDA3_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDA3_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA3_LANE2_BINARY, E10GBASER_PCS_SEEDA3_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDA3_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDA3_LANE3_BINARY, E10GBASER_PCS_SEEDA3_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDB0_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB0_LANE0_BINARY, E10GBASER_PCS_SEEDB0_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDB0_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB0_LANE1_BINARY, E10GBASER_PCS_SEEDB0_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDB0_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB0_LANE2_BINARY, E10GBASER_PCS_SEEDB0_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDB0_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB0_LANE3_BINARY, E10GBASER_PCS_SEEDB0_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDB1_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB1_LANE0_BINARY, E10GBASER_PCS_SEEDB1_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDB1_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB1_LANE1_BINARY, E10GBASER_PCS_SEEDB1_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDB1_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB1_LANE2_BINARY, E10GBASER_PCS_SEEDB1_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDB1_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB1_LANE3_BINARY, E10GBASER_PCS_SEEDB1_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDB2_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB2_LANE0_BINARY, E10GBASER_PCS_SEEDB2_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDB2_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB2_LANE1_BINARY, E10GBASER_PCS_SEEDB2_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDB2_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB2_LANE2_BINARY, E10GBASER_PCS_SEEDB2_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDB2_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB2_LANE3_BINARY, E10GBASER_PCS_SEEDB2_LANE3_STRLEN);
    constant E10GBASER_PCS_SEEDB3_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB3_LANE0_BINARY, E10GBASER_PCS_SEEDB3_LANE0_STRLEN);
    constant E10GBASER_PCS_SEEDB3_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB3_LANE1_BINARY, E10GBASER_PCS_SEEDB3_LANE1_STRLEN);
    constant E10GBASER_PCS_SEEDB3_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB3_LANE2_BINARY, E10GBASER_PCS_SEEDB3_LANE2_STRLEN);
    constant E10GBASER_PCS_SEEDB3_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_SEEDB3_LANE3_BINARY, E10GBASER_PCS_SEEDB3_LANE3_STRLEN);
    constant E10GBASER_PCS_TEST_CTRL_LANE0_STRING : string := SLV_TO_HEX(E10GBASER_PCS_TEST_CTRL_LANE0_BINARY, E10GBASER_PCS_TEST_CTRL_LANE0_STRLEN);
    constant E10GBASER_PCS_TEST_CTRL_LANE1_STRING : string := SLV_TO_HEX(E10GBASER_PCS_TEST_CTRL_LANE1_BINARY, E10GBASER_PCS_TEST_CTRL_LANE1_STRLEN);
    constant E10GBASER_PCS_TEST_CTRL_LANE2_STRING : string := SLV_TO_HEX(E10GBASER_PCS_TEST_CTRL_LANE2_BINARY, E10GBASER_PCS_TEST_CTRL_LANE2_STRLEN);
    constant E10GBASER_PCS_TEST_CTRL_LANE3_STRING : string := SLV_TO_HEX(E10GBASER_PCS_TEST_CTRL_LANE3_BINARY, E10GBASER_PCS_TEST_CTRL_LANE3_STRLEN);
    constant E10GBASEX_PCS_TSTCTRL_LANE0_STRING : string := SLV_TO_HEX(E10GBASEX_PCS_TSTCTRL_LANE0_BINARY, E10GBASEX_PCS_TSTCTRL_LANE0_STRLEN);
    constant E10GBASEX_PCS_TSTCTRL_LANE1_STRING : string := SLV_TO_HEX(E10GBASEX_PCS_TSTCTRL_LANE1_BINARY, E10GBASEX_PCS_TSTCTRL_LANE1_STRLEN);
    constant E10GBASEX_PCS_TSTCTRL_LANE2_STRING : string := SLV_TO_HEX(E10GBASEX_PCS_TSTCTRL_LANE2_BINARY, E10GBASEX_PCS_TSTCTRL_LANE2_STRLEN);
    constant E10GBASEX_PCS_TSTCTRL_LANE3_STRING : string := SLV_TO_HEX(E10GBASEX_PCS_TSTCTRL_LANE3_BINARY, E10GBASEX_PCS_TSTCTRL_LANE3_STRLEN);
    constant GLBL0_NOISE_CTRL_STRING : string := SLV_TO_HEX(GLBL0_NOISE_CTRL_BINARY, GLBL0_NOISE_CTRL_STRLEN);
    constant GLBL_AMON_SEL_STRING : string := SLV_TO_HEX(GLBL_AMON_SEL_BINARY, GLBL_AMON_SEL_STRLEN);
    constant GLBL_DMON_SEL_STRING : string := SLV_TO_HEX(GLBL_DMON_SEL_BINARY, GLBL_DMON_SEL_STRLEN);
    constant GLBL_PWR_CTRL_STRING : string := SLV_TO_HEX(GLBL_PWR_CTRL_BINARY, GLBL_PWR_CTRL_STRLEN);
    constant GTH_CFG_PWRUP_LANE0_STRING : string := SUL_TO_STR(GTH_CFG_PWRUP_LANE0_BINARY);
    constant GTH_CFG_PWRUP_LANE1_STRING : string := SUL_TO_STR(GTH_CFG_PWRUP_LANE1_BINARY);
    constant GTH_CFG_PWRUP_LANE2_STRING : string := SUL_TO_STR(GTH_CFG_PWRUP_LANE2_BINARY);
    constant GTH_CFG_PWRUP_LANE3_STRING : string := SUL_TO_STR(GTH_CFG_PWRUP_LANE3_BINARY);
    constant LANE_AMON_SEL_STRING : string := SLV_TO_HEX(LANE_AMON_SEL_BINARY, LANE_AMON_SEL_STRLEN);
    constant LANE_DMON_SEL_STRING : string := SLV_TO_HEX(LANE_DMON_SEL_BINARY, LANE_DMON_SEL_STRLEN);
    constant LANE_LNK_CFGOVRD_STRING : string := SLV_TO_HEX(LANE_LNK_CFGOVRD_BINARY, LANE_LNK_CFGOVRD_STRLEN);
    constant LANE_PWR_CTRL_LANE0_STRING : string := SLV_TO_HEX(LANE_PWR_CTRL_LANE0_BINARY, LANE_PWR_CTRL_LANE0_STRLEN);
    constant LANE_PWR_CTRL_LANE1_STRING : string := SLV_TO_HEX(LANE_PWR_CTRL_LANE1_BINARY, LANE_PWR_CTRL_LANE1_STRLEN);
    constant LANE_PWR_CTRL_LANE2_STRING : string := SLV_TO_HEX(LANE_PWR_CTRL_LANE2_BINARY, LANE_PWR_CTRL_LANE2_STRLEN);
    constant LANE_PWR_CTRL_LANE3_STRING : string := SLV_TO_HEX(LANE_PWR_CTRL_LANE3_BINARY, LANE_PWR_CTRL_LANE3_STRLEN);
    constant LNK_TRN_CFG_LANE0_STRING : string := SLV_TO_HEX(LNK_TRN_CFG_LANE0_BINARY, LNK_TRN_CFG_LANE0_STRLEN);
    constant LNK_TRN_CFG_LANE1_STRING : string := SLV_TO_HEX(LNK_TRN_CFG_LANE1_BINARY, LNK_TRN_CFG_LANE1_STRLEN);
    constant LNK_TRN_CFG_LANE2_STRING : string := SLV_TO_HEX(LNK_TRN_CFG_LANE2_BINARY, LNK_TRN_CFG_LANE2_STRLEN);
    constant LNK_TRN_CFG_LANE3_STRING : string := SLV_TO_HEX(LNK_TRN_CFG_LANE3_BINARY, LNK_TRN_CFG_LANE3_STRLEN);
    constant LNK_TRN_COEFF_REQ_LANE0_STRING : string := SLV_TO_HEX(LNK_TRN_COEFF_REQ_LANE0_BINARY, LNK_TRN_COEFF_REQ_LANE0_STRLEN);
    constant LNK_TRN_COEFF_REQ_LANE1_STRING : string := SLV_TO_HEX(LNK_TRN_COEFF_REQ_LANE1_BINARY, LNK_TRN_COEFF_REQ_LANE1_STRLEN);
    constant LNK_TRN_COEFF_REQ_LANE2_STRING : string := SLV_TO_HEX(LNK_TRN_COEFF_REQ_LANE2_BINARY, LNK_TRN_COEFF_REQ_LANE2_STRLEN);
    constant LNK_TRN_COEFF_REQ_LANE3_STRING : string := SLV_TO_HEX(LNK_TRN_COEFF_REQ_LANE3_BINARY, LNK_TRN_COEFF_REQ_LANE3_STRLEN);
    constant MISC_CFG_STRING : string := SLV_TO_HEX(MISC_CFG_BINARY, MISC_CFG_STRLEN);
    constant MODE_CFG1_STRING : string := SLV_TO_HEX(MODE_CFG1_BINARY, MODE_CFG1_STRLEN);
    constant MODE_CFG2_STRING : string := SLV_TO_HEX(MODE_CFG2_BINARY, MODE_CFG2_STRLEN);
    constant MODE_CFG3_STRING : string := SLV_TO_HEX(MODE_CFG3_BINARY, MODE_CFG3_STRLEN);
    constant MODE_CFG4_STRING : string := SLV_TO_HEX(MODE_CFG4_BINARY, MODE_CFG4_STRLEN);
    constant MODE_CFG5_STRING : string := SLV_TO_HEX(MODE_CFG5_BINARY, MODE_CFG5_STRLEN);
    constant MODE_CFG6_STRING : string := SLV_TO_HEX(MODE_CFG6_BINARY, MODE_CFG6_STRLEN);
    constant MODE_CFG7_STRING : string := SLV_TO_HEX(MODE_CFG7_BINARY, MODE_CFG7_STRLEN);
    constant PCS_ABILITY_LANE0_STRING : string := SLV_TO_HEX(PCS_ABILITY_LANE0_BINARY, PCS_ABILITY_LANE0_STRLEN);
    constant PCS_ABILITY_LANE1_STRING : string := SLV_TO_HEX(PCS_ABILITY_LANE1_BINARY, PCS_ABILITY_LANE1_STRLEN);
    constant PCS_ABILITY_LANE2_STRING : string := SLV_TO_HEX(PCS_ABILITY_LANE2_BINARY, PCS_ABILITY_LANE2_STRLEN);
    constant PCS_ABILITY_LANE3_STRING : string := SLV_TO_HEX(PCS_ABILITY_LANE3_BINARY, PCS_ABILITY_LANE3_STRLEN);
    constant PCS_CTRL1_LANE0_STRING : string := SLV_TO_HEX(PCS_CTRL1_LANE0_BINARY, PCS_CTRL1_LANE0_STRLEN);
    constant PCS_CTRL1_LANE1_STRING : string := SLV_TO_HEX(PCS_CTRL1_LANE1_BINARY, PCS_CTRL1_LANE1_STRLEN);
    constant PCS_CTRL1_LANE2_STRING : string := SLV_TO_HEX(PCS_CTRL1_LANE2_BINARY, PCS_CTRL1_LANE2_STRLEN);
    constant PCS_CTRL1_LANE3_STRING : string := SLV_TO_HEX(PCS_CTRL1_LANE3_BINARY, PCS_CTRL1_LANE3_STRLEN);
    constant PCS_CTRL2_LANE0_STRING : string := SLV_TO_HEX(PCS_CTRL2_LANE0_BINARY, PCS_CTRL2_LANE0_STRLEN);
    constant PCS_CTRL2_LANE1_STRING : string := SLV_TO_HEX(PCS_CTRL2_LANE1_BINARY, PCS_CTRL2_LANE1_STRLEN);
    constant PCS_CTRL2_LANE2_STRING : string := SLV_TO_HEX(PCS_CTRL2_LANE2_BINARY, PCS_CTRL2_LANE2_STRLEN);
    constant PCS_CTRL2_LANE3_STRING : string := SLV_TO_HEX(PCS_CTRL2_LANE3_BINARY, PCS_CTRL2_LANE3_STRLEN);
    constant PCS_MISC_CFG_0_LANE0_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_0_LANE0_BINARY, PCS_MISC_CFG_0_LANE0_STRLEN);
    constant PCS_MISC_CFG_0_LANE1_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_0_LANE1_BINARY, PCS_MISC_CFG_0_LANE1_STRLEN);
    constant PCS_MISC_CFG_0_LANE2_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_0_LANE2_BINARY, PCS_MISC_CFG_0_LANE2_STRLEN);
    constant PCS_MISC_CFG_0_LANE3_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_0_LANE3_BINARY, PCS_MISC_CFG_0_LANE3_STRLEN);
    constant PCS_MISC_CFG_1_LANE0_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_1_LANE0_BINARY, PCS_MISC_CFG_1_LANE0_STRLEN);
    constant PCS_MISC_CFG_1_LANE1_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_1_LANE1_BINARY, PCS_MISC_CFG_1_LANE1_STRLEN);
    constant PCS_MISC_CFG_1_LANE2_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_1_LANE2_BINARY, PCS_MISC_CFG_1_LANE2_STRLEN);
    constant PCS_MISC_CFG_1_LANE3_STRING : string := SLV_TO_HEX(PCS_MISC_CFG_1_LANE3_BINARY, PCS_MISC_CFG_1_LANE3_STRLEN);
    constant PCS_MODE_LANE0_STRING : string := SLV_TO_HEX(PCS_MODE_LANE0_BINARY, PCS_MODE_LANE0_STRLEN);
    constant PCS_MODE_LANE1_STRING : string := SLV_TO_HEX(PCS_MODE_LANE1_BINARY, PCS_MODE_LANE1_STRLEN);
    constant PCS_MODE_LANE2_STRING : string := SLV_TO_HEX(PCS_MODE_LANE2_BINARY, PCS_MODE_LANE2_STRLEN);
    constant PCS_MODE_LANE3_STRING : string := SLV_TO_HEX(PCS_MODE_LANE3_BINARY, PCS_MODE_LANE3_STRLEN);
    constant PCS_RESET_1_LANE0_STRING : string := SLV_TO_HEX(PCS_RESET_1_LANE0_BINARY, PCS_RESET_1_LANE0_STRLEN);
    constant PCS_RESET_1_LANE1_STRING : string := SLV_TO_HEX(PCS_RESET_1_LANE1_BINARY, PCS_RESET_1_LANE1_STRLEN);
    constant PCS_RESET_1_LANE2_STRING : string := SLV_TO_HEX(PCS_RESET_1_LANE2_BINARY, PCS_RESET_1_LANE2_STRLEN);
    constant PCS_RESET_1_LANE3_STRING : string := SLV_TO_HEX(PCS_RESET_1_LANE3_BINARY, PCS_RESET_1_LANE3_STRLEN);
    constant PCS_RESET_LANE0_STRING : string := SLV_TO_HEX(PCS_RESET_LANE0_BINARY, PCS_RESET_LANE0_STRLEN);
    constant PCS_RESET_LANE1_STRING : string := SLV_TO_HEX(PCS_RESET_LANE1_BINARY, PCS_RESET_LANE1_STRLEN);
    constant PCS_RESET_LANE2_STRING : string := SLV_TO_HEX(PCS_RESET_LANE2_BINARY, PCS_RESET_LANE2_STRLEN);
    constant PCS_RESET_LANE3_STRING : string := SLV_TO_HEX(PCS_RESET_LANE3_BINARY, PCS_RESET_LANE3_STRLEN);
    constant PCS_TYPE_LANE0_STRING : string := SLV_TO_HEX(PCS_TYPE_LANE0_BINARY, PCS_TYPE_LANE0_STRLEN);
    constant PCS_TYPE_LANE1_STRING : string := SLV_TO_HEX(PCS_TYPE_LANE1_BINARY, PCS_TYPE_LANE1_STRLEN);
    constant PCS_TYPE_LANE2_STRING : string := SLV_TO_HEX(PCS_TYPE_LANE2_BINARY, PCS_TYPE_LANE2_STRLEN);
    constant PCS_TYPE_LANE3_STRING : string := SLV_TO_HEX(PCS_TYPE_LANE3_BINARY, PCS_TYPE_LANE3_STRLEN);
    constant PLL_CFG0_STRING : string := SLV_TO_HEX(PLL_CFG0_BINARY, PLL_CFG0_STRLEN);
    constant PLL_CFG1_STRING : string := SLV_TO_HEX(PLL_CFG1_BINARY, PLL_CFG1_STRLEN);
    constant PLL_CFG2_STRING : string := SLV_TO_HEX(PLL_CFG2_BINARY, PLL_CFG2_STRLEN);
    constant PMA_CTRL1_LANE0_STRING : string := SLV_TO_HEX(PMA_CTRL1_LANE0_BINARY, PMA_CTRL1_LANE0_STRLEN);
    constant PMA_CTRL1_LANE1_STRING : string := SLV_TO_HEX(PMA_CTRL1_LANE1_BINARY, PMA_CTRL1_LANE1_STRLEN);
    constant PMA_CTRL1_LANE2_STRING : string := SLV_TO_HEX(PMA_CTRL1_LANE2_BINARY, PMA_CTRL1_LANE2_STRLEN);
    constant PMA_CTRL1_LANE3_STRING : string := SLV_TO_HEX(PMA_CTRL1_LANE3_BINARY, PMA_CTRL1_LANE3_STRLEN);
    constant PMA_CTRL2_LANE0_STRING : string := SLV_TO_HEX(PMA_CTRL2_LANE0_BINARY, PMA_CTRL2_LANE0_STRLEN);
    constant PMA_CTRL2_LANE1_STRING : string := SLV_TO_HEX(PMA_CTRL2_LANE1_BINARY, PMA_CTRL2_LANE1_STRLEN);
    constant PMA_CTRL2_LANE2_STRING : string := SLV_TO_HEX(PMA_CTRL2_LANE2_BINARY, PMA_CTRL2_LANE2_STRLEN);
    constant PMA_CTRL2_LANE3_STRING : string := SLV_TO_HEX(PMA_CTRL2_LANE3_BINARY, PMA_CTRL2_LANE3_STRLEN);
    constant PMA_LPBK_CTRL_LANE0_STRING : string := SLV_TO_HEX(PMA_LPBK_CTRL_LANE0_BINARY, PMA_LPBK_CTRL_LANE0_STRLEN);
    constant PMA_LPBK_CTRL_LANE1_STRING : string := SLV_TO_HEX(PMA_LPBK_CTRL_LANE1_BINARY, PMA_LPBK_CTRL_LANE1_STRLEN);
    constant PMA_LPBK_CTRL_LANE2_STRING : string := SLV_TO_HEX(PMA_LPBK_CTRL_LANE2_BINARY, PMA_LPBK_CTRL_LANE2_STRLEN);
    constant PMA_LPBK_CTRL_LANE3_STRING : string := SLV_TO_HEX(PMA_LPBK_CTRL_LANE3_BINARY, PMA_LPBK_CTRL_LANE3_STRLEN);
    constant PRBS_BER_CFG0_LANE0_STRING : string := SLV_TO_HEX(PRBS_BER_CFG0_LANE0_BINARY, PRBS_BER_CFG0_LANE0_STRLEN);
    constant PRBS_BER_CFG0_LANE1_STRING : string := SLV_TO_HEX(PRBS_BER_CFG0_LANE1_BINARY, PRBS_BER_CFG0_LANE1_STRLEN);
    constant PRBS_BER_CFG0_LANE2_STRING : string := SLV_TO_HEX(PRBS_BER_CFG0_LANE2_BINARY, PRBS_BER_CFG0_LANE2_STRLEN);
    constant PRBS_BER_CFG0_LANE3_STRING : string := SLV_TO_HEX(PRBS_BER_CFG0_LANE3_BINARY, PRBS_BER_CFG0_LANE3_STRLEN);
    constant PRBS_BER_CFG1_LANE0_STRING : string := SLV_TO_HEX(PRBS_BER_CFG1_LANE0_BINARY, PRBS_BER_CFG1_LANE0_STRLEN);
    constant PRBS_BER_CFG1_LANE1_STRING : string := SLV_TO_HEX(PRBS_BER_CFG1_LANE1_BINARY, PRBS_BER_CFG1_LANE1_STRLEN);
    constant PRBS_BER_CFG1_LANE2_STRING : string := SLV_TO_HEX(PRBS_BER_CFG1_LANE2_BINARY, PRBS_BER_CFG1_LANE2_STRLEN);
    constant PRBS_BER_CFG1_LANE3_STRING : string := SLV_TO_HEX(PRBS_BER_CFG1_LANE3_BINARY, PRBS_BER_CFG1_LANE3_STRLEN);
    constant PRBS_CFG_LANE0_STRING : string := SLV_TO_HEX(PRBS_CFG_LANE0_BINARY, PRBS_CFG_LANE0_STRLEN);
    constant PRBS_CFG_LANE1_STRING : string := SLV_TO_HEX(PRBS_CFG_LANE1_BINARY, PRBS_CFG_LANE1_STRLEN);
    constant PRBS_CFG_LANE2_STRING : string := SLV_TO_HEX(PRBS_CFG_LANE2_BINARY, PRBS_CFG_LANE2_STRLEN);
    constant PRBS_CFG_LANE3_STRING : string := SLV_TO_HEX(PRBS_CFG_LANE3_BINARY, PRBS_CFG_LANE3_STRLEN);
    constant PTRN_CFG0_LSB_STRING : string := SLV_TO_HEX(PTRN_CFG0_LSB_BINARY, PTRN_CFG0_LSB_STRLEN);
    constant PTRN_CFG0_MSB_STRING : string := SLV_TO_HEX(PTRN_CFG0_MSB_BINARY, PTRN_CFG0_MSB_STRLEN);
    constant PTRN_LEN_CFG_STRING : string := SLV_TO_HEX(PTRN_LEN_CFG_BINARY, PTRN_LEN_CFG_STRLEN);
    constant PWRUP_DLY_STRING : string := SLV_TO_HEX(PWRUP_DLY_BINARY, PWRUP_DLY_STRLEN);
    constant RX_AEQ_VAL0_LANE0_STRING : string := SLV_TO_HEX(RX_AEQ_VAL0_LANE0_BINARY, RX_AEQ_VAL0_LANE0_STRLEN);
    constant RX_AEQ_VAL0_LANE1_STRING : string := SLV_TO_HEX(RX_AEQ_VAL0_LANE1_BINARY, RX_AEQ_VAL0_LANE1_STRLEN);
    constant RX_AEQ_VAL0_LANE2_STRING : string := SLV_TO_HEX(RX_AEQ_VAL0_LANE2_BINARY, RX_AEQ_VAL0_LANE2_STRLEN);
    constant RX_AEQ_VAL0_LANE3_STRING : string := SLV_TO_HEX(RX_AEQ_VAL0_LANE3_BINARY, RX_AEQ_VAL0_LANE3_STRLEN);
    constant RX_AEQ_VAL1_LANE0_STRING : string := SLV_TO_HEX(RX_AEQ_VAL1_LANE0_BINARY, RX_AEQ_VAL1_LANE0_STRLEN);
    constant RX_AEQ_VAL1_LANE1_STRING : string := SLV_TO_HEX(RX_AEQ_VAL1_LANE1_BINARY, RX_AEQ_VAL1_LANE1_STRLEN);
    constant RX_AEQ_VAL1_LANE2_STRING : string := SLV_TO_HEX(RX_AEQ_VAL1_LANE2_BINARY, RX_AEQ_VAL1_LANE2_STRLEN);
    constant RX_AEQ_VAL1_LANE3_STRING : string := SLV_TO_HEX(RX_AEQ_VAL1_LANE3_BINARY, RX_AEQ_VAL1_LANE3_STRLEN);
    constant RX_AGC_CTRL_LANE0_STRING : string := SLV_TO_HEX(RX_AGC_CTRL_LANE0_BINARY, RX_AGC_CTRL_LANE0_STRLEN);
    constant RX_AGC_CTRL_LANE1_STRING : string := SLV_TO_HEX(RX_AGC_CTRL_LANE1_BINARY, RX_AGC_CTRL_LANE1_STRLEN);
    constant RX_AGC_CTRL_LANE2_STRING : string := SLV_TO_HEX(RX_AGC_CTRL_LANE2_BINARY, RX_AGC_CTRL_LANE2_STRLEN);
    constant RX_AGC_CTRL_LANE3_STRING : string := SLV_TO_HEX(RX_AGC_CTRL_LANE3_BINARY, RX_AGC_CTRL_LANE3_STRLEN);
    constant RX_CDR_CTRL0_LANE0_STRING : string := SLV_TO_HEX(RX_CDR_CTRL0_LANE0_BINARY, RX_CDR_CTRL0_LANE0_STRLEN);
    constant RX_CDR_CTRL0_LANE1_STRING : string := SLV_TO_HEX(RX_CDR_CTRL0_LANE1_BINARY, RX_CDR_CTRL0_LANE1_STRLEN);
    constant RX_CDR_CTRL0_LANE2_STRING : string := SLV_TO_HEX(RX_CDR_CTRL0_LANE2_BINARY, RX_CDR_CTRL0_LANE2_STRLEN);
    constant RX_CDR_CTRL0_LANE3_STRING : string := SLV_TO_HEX(RX_CDR_CTRL0_LANE3_BINARY, RX_CDR_CTRL0_LANE3_STRLEN);
    constant RX_CDR_CTRL1_LANE0_STRING : string := SLV_TO_HEX(RX_CDR_CTRL1_LANE0_BINARY, RX_CDR_CTRL1_LANE0_STRLEN);
    constant RX_CDR_CTRL1_LANE1_STRING : string := SLV_TO_HEX(RX_CDR_CTRL1_LANE1_BINARY, RX_CDR_CTRL1_LANE1_STRLEN);
    constant RX_CDR_CTRL1_LANE2_STRING : string := SLV_TO_HEX(RX_CDR_CTRL1_LANE2_BINARY, RX_CDR_CTRL1_LANE2_STRLEN);
    constant RX_CDR_CTRL1_LANE3_STRING : string := SLV_TO_HEX(RX_CDR_CTRL1_LANE3_BINARY, RX_CDR_CTRL1_LANE3_STRLEN);
    constant RX_CDR_CTRL2_LANE0_STRING : string := SLV_TO_HEX(RX_CDR_CTRL2_LANE0_BINARY, RX_CDR_CTRL2_LANE0_STRLEN);
    constant RX_CDR_CTRL2_LANE1_STRING : string := SLV_TO_HEX(RX_CDR_CTRL2_LANE1_BINARY, RX_CDR_CTRL2_LANE1_STRLEN);
    constant RX_CDR_CTRL2_LANE2_STRING : string := SLV_TO_HEX(RX_CDR_CTRL2_LANE2_BINARY, RX_CDR_CTRL2_LANE2_STRLEN);
    constant RX_CDR_CTRL2_LANE3_STRING : string := SLV_TO_HEX(RX_CDR_CTRL2_LANE3_BINARY, RX_CDR_CTRL2_LANE3_STRLEN);
    constant RX_CFG0_LANE0_STRING : string := SLV_TO_HEX(RX_CFG0_LANE0_BINARY, RX_CFG0_LANE0_STRLEN);
    constant RX_CFG0_LANE1_STRING : string := SLV_TO_HEX(RX_CFG0_LANE1_BINARY, RX_CFG0_LANE1_STRLEN);
    constant RX_CFG0_LANE2_STRING : string := SLV_TO_HEX(RX_CFG0_LANE2_BINARY, RX_CFG0_LANE2_STRLEN);
    constant RX_CFG0_LANE3_STRING : string := SLV_TO_HEX(RX_CFG0_LANE3_BINARY, RX_CFG0_LANE3_STRLEN);
    constant RX_CFG1_LANE0_STRING : string := SLV_TO_HEX(RX_CFG1_LANE0_BINARY, RX_CFG1_LANE0_STRLEN);
    constant RX_CFG1_LANE1_STRING : string := SLV_TO_HEX(RX_CFG1_LANE1_BINARY, RX_CFG1_LANE1_STRLEN);
    constant RX_CFG1_LANE2_STRING : string := SLV_TO_HEX(RX_CFG1_LANE2_BINARY, RX_CFG1_LANE2_STRLEN);
    constant RX_CFG1_LANE3_STRING : string := SLV_TO_HEX(RX_CFG1_LANE3_BINARY, RX_CFG1_LANE3_STRLEN);
    constant RX_CFG2_LANE0_STRING : string := SLV_TO_HEX(RX_CFG2_LANE0_BINARY, RX_CFG2_LANE0_STRLEN);
    constant RX_CFG2_LANE1_STRING : string := SLV_TO_HEX(RX_CFG2_LANE1_BINARY, RX_CFG2_LANE1_STRLEN);
    constant RX_CFG2_LANE2_STRING : string := SLV_TO_HEX(RX_CFG2_LANE2_BINARY, RX_CFG2_LANE2_STRLEN);
    constant RX_CFG2_LANE3_STRING : string := SLV_TO_HEX(RX_CFG2_LANE3_BINARY, RX_CFG2_LANE3_STRLEN);
    constant RX_CTLE_CTRL_LANE0_STRING : string := SLV_TO_HEX(RX_CTLE_CTRL_LANE0_BINARY, RX_CTLE_CTRL_LANE0_STRLEN);
    constant RX_CTLE_CTRL_LANE1_STRING : string := SLV_TO_HEX(RX_CTLE_CTRL_LANE1_BINARY, RX_CTLE_CTRL_LANE1_STRLEN);
    constant RX_CTLE_CTRL_LANE2_STRING : string := SLV_TO_HEX(RX_CTLE_CTRL_LANE2_BINARY, RX_CTLE_CTRL_LANE2_STRLEN);
    constant RX_CTLE_CTRL_LANE3_STRING : string := SLV_TO_HEX(RX_CTLE_CTRL_LANE3_BINARY, RX_CTLE_CTRL_LANE3_STRLEN);
    constant RX_CTRL_OVRD_LANE0_STRING : string := SLV_TO_HEX(RX_CTRL_OVRD_LANE0_BINARY, RX_CTRL_OVRD_LANE0_STRLEN);
    constant RX_CTRL_OVRD_LANE1_STRING : string := SLV_TO_HEX(RX_CTRL_OVRD_LANE1_BINARY, RX_CTRL_OVRD_LANE1_STRLEN);
    constant RX_CTRL_OVRD_LANE2_STRING : string := SLV_TO_HEX(RX_CTRL_OVRD_LANE2_BINARY, RX_CTRL_OVRD_LANE2_STRLEN);
    constant RX_CTRL_OVRD_LANE3_STRING : string := SLV_TO_HEX(RX_CTRL_OVRD_LANE3_BINARY, RX_CTRL_OVRD_LANE3_STRLEN);
    constant RX_LOOP_CTRL_LANE0_STRING : string := SLV_TO_HEX(RX_LOOP_CTRL_LANE0_BINARY, RX_LOOP_CTRL_LANE0_STRLEN);
    constant RX_LOOP_CTRL_LANE1_STRING : string := SLV_TO_HEX(RX_LOOP_CTRL_LANE1_BINARY, RX_LOOP_CTRL_LANE1_STRLEN);
    constant RX_LOOP_CTRL_LANE2_STRING : string := SLV_TO_HEX(RX_LOOP_CTRL_LANE2_BINARY, RX_LOOP_CTRL_LANE2_STRLEN);
    constant RX_LOOP_CTRL_LANE3_STRING : string := SLV_TO_HEX(RX_LOOP_CTRL_LANE3_BINARY, RX_LOOP_CTRL_LANE3_STRLEN);
    constant RX_MVAL0_LANE0_STRING : string := SLV_TO_HEX(RX_MVAL0_LANE0_BINARY, RX_MVAL0_LANE0_STRLEN);
    constant RX_MVAL0_LANE1_STRING : string := SLV_TO_HEX(RX_MVAL0_LANE1_BINARY, RX_MVAL0_LANE1_STRLEN);
    constant RX_MVAL0_LANE2_STRING : string := SLV_TO_HEX(RX_MVAL0_LANE2_BINARY, RX_MVAL0_LANE2_STRLEN);
    constant RX_MVAL0_LANE3_STRING : string := SLV_TO_HEX(RX_MVAL0_LANE3_BINARY, RX_MVAL0_LANE3_STRLEN);
    constant RX_MVAL1_LANE0_STRING : string := SLV_TO_HEX(RX_MVAL1_LANE0_BINARY, RX_MVAL1_LANE0_STRLEN);
    constant RX_MVAL1_LANE1_STRING : string := SLV_TO_HEX(RX_MVAL1_LANE1_BINARY, RX_MVAL1_LANE1_STRLEN);
    constant RX_MVAL1_LANE2_STRING : string := SLV_TO_HEX(RX_MVAL1_LANE2_BINARY, RX_MVAL1_LANE2_STRLEN);
    constant RX_MVAL1_LANE3_STRING : string := SLV_TO_HEX(RX_MVAL1_LANE3_BINARY, RX_MVAL1_LANE3_STRLEN);
    constant RX_P0S_CTRL_STRING : string := SLV_TO_HEX(RX_P0S_CTRL_BINARY, RX_P0S_CTRL_STRLEN);
    constant RX_P0_CTRL_STRING : string := SLV_TO_HEX(RX_P0_CTRL_BINARY, RX_P0_CTRL_STRLEN);
    constant RX_P1_CTRL_STRING : string := SLV_TO_HEX(RX_P1_CTRL_BINARY, RX_P1_CTRL_STRLEN);
    constant RX_P2_CTRL_STRING : string := SLV_TO_HEX(RX_P2_CTRL_BINARY, RX_P2_CTRL_STRLEN);
    constant RX_PI_CTRL0_STRING : string := SLV_TO_HEX(RX_PI_CTRL0_BINARY, RX_PI_CTRL0_STRLEN);
    constant RX_PI_CTRL1_STRING : string := SLV_TO_HEX(RX_PI_CTRL1_BINARY, RX_PI_CTRL1_STRLEN);
    constant SLICE_CFG_STRING : string := SLV_TO_HEX(SLICE_CFG_BINARY, SLICE_CFG_STRLEN);
    constant SLICE_NOISE_CTRL_0_LANE01_STRING : string := SLV_TO_HEX(SLICE_NOISE_CTRL_0_LANE01_BINARY, SLICE_NOISE_CTRL_0_LANE01_STRLEN);
    constant SLICE_NOISE_CTRL_0_LANE23_STRING : string := SLV_TO_HEX(SLICE_NOISE_CTRL_0_LANE23_BINARY, SLICE_NOISE_CTRL_0_LANE23_STRLEN);
    constant SLICE_NOISE_CTRL_1_LANE01_STRING : string := SLV_TO_HEX(SLICE_NOISE_CTRL_1_LANE01_BINARY, SLICE_NOISE_CTRL_1_LANE01_STRLEN);
    constant SLICE_NOISE_CTRL_1_LANE23_STRING : string := SLV_TO_HEX(SLICE_NOISE_CTRL_1_LANE23_BINARY, SLICE_NOISE_CTRL_1_LANE23_STRLEN);
    constant SLICE_NOISE_CTRL_2_LANE01_STRING : string := SLV_TO_HEX(SLICE_NOISE_CTRL_2_LANE01_BINARY, SLICE_NOISE_CTRL_2_LANE01_STRLEN);
    constant SLICE_NOISE_CTRL_2_LANE23_STRING : string := SLV_TO_HEX(SLICE_NOISE_CTRL_2_LANE23_BINARY, SLICE_NOISE_CTRL_2_LANE23_STRLEN);
    constant SLICE_TX_RESET_LANE01_STRING : string := SLV_TO_HEX(SLICE_TX_RESET_LANE01_BINARY, SLICE_TX_RESET_LANE01_STRLEN);
    constant SLICE_TX_RESET_LANE23_STRING : string := SLV_TO_HEX(SLICE_TX_RESET_LANE23_BINARY, SLICE_TX_RESET_LANE23_STRLEN);
    constant TERM_CTRL_LANE0_STRING : string := SLV_TO_HEX(TERM_CTRL_LANE0_BINARY, TERM_CTRL_LANE0_STRLEN);
    constant TERM_CTRL_LANE1_STRING : string := SLV_TO_HEX(TERM_CTRL_LANE1_BINARY, TERM_CTRL_LANE1_STRLEN);
    constant TERM_CTRL_LANE2_STRING : string := SLV_TO_HEX(TERM_CTRL_LANE2_BINARY, TERM_CTRL_LANE2_STRLEN);
    constant TERM_CTRL_LANE3_STRING : string := SLV_TO_HEX(TERM_CTRL_LANE3_BINARY, TERM_CTRL_LANE3_STRLEN);
    constant TX_CFG0_LANE0_STRING : string := SLV_TO_HEX(TX_CFG0_LANE0_BINARY, TX_CFG0_LANE0_STRLEN);
    constant TX_CFG0_LANE1_STRING : string := SLV_TO_HEX(TX_CFG0_LANE1_BINARY, TX_CFG0_LANE1_STRLEN);
    constant TX_CFG0_LANE2_STRING : string := SLV_TO_HEX(TX_CFG0_LANE2_BINARY, TX_CFG0_LANE2_STRLEN);
    constant TX_CFG0_LANE3_STRING : string := SLV_TO_HEX(TX_CFG0_LANE3_BINARY, TX_CFG0_LANE3_STRLEN);
    constant TX_CFG1_LANE0_STRING : string := SLV_TO_HEX(TX_CFG1_LANE0_BINARY, TX_CFG1_LANE0_STRLEN);
    constant TX_CFG1_LANE1_STRING : string := SLV_TO_HEX(TX_CFG1_LANE1_BINARY, TX_CFG1_LANE1_STRLEN);
    constant TX_CFG1_LANE2_STRING : string := SLV_TO_HEX(TX_CFG1_LANE2_BINARY, TX_CFG1_LANE2_STRLEN);
    constant TX_CFG1_LANE3_STRING : string := SLV_TO_HEX(TX_CFG1_LANE3_BINARY, TX_CFG1_LANE3_STRLEN);
    constant TX_CFG2_LANE0_STRING : string := SLV_TO_HEX(TX_CFG2_LANE0_BINARY, TX_CFG2_LANE0_STRLEN);
    constant TX_CFG2_LANE1_STRING : string := SLV_TO_HEX(TX_CFG2_LANE1_BINARY, TX_CFG2_LANE1_STRLEN);
    constant TX_CFG2_LANE2_STRING : string := SLV_TO_HEX(TX_CFG2_LANE2_BINARY, TX_CFG2_LANE2_STRLEN);
    constant TX_CFG2_LANE3_STRING : string := SLV_TO_HEX(TX_CFG2_LANE3_BINARY, TX_CFG2_LANE3_STRLEN);
    constant TX_CLK_SEL0_LANE0_STRING : string := SLV_TO_HEX(TX_CLK_SEL0_LANE0_BINARY, TX_CLK_SEL0_LANE0_STRLEN);
    constant TX_CLK_SEL0_LANE1_STRING : string := SLV_TO_HEX(TX_CLK_SEL0_LANE1_BINARY, TX_CLK_SEL0_LANE1_STRLEN);
    constant TX_CLK_SEL0_LANE2_STRING : string := SLV_TO_HEX(TX_CLK_SEL0_LANE2_BINARY, TX_CLK_SEL0_LANE2_STRLEN);
    constant TX_CLK_SEL0_LANE3_STRING : string := SLV_TO_HEX(TX_CLK_SEL0_LANE3_BINARY, TX_CLK_SEL0_LANE3_STRLEN);
    constant TX_CLK_SEL1_LANE0_STRING : string := SLV_TO_HEX(TX_CLK_SEL1_LANE0_BINARY, TX_CLK_SEL1_LANE0_STRLEN);
    constant TX_CLK_SEL1_LANE1_STRING : string := SLV_TO_HEX(TX_CLK_SEL1_LANE1_BINARY, TX_CLK_SEL1_LANE1_STRLEN);
    constant TX_CLK_SEL1_LANE2_STRING : string := SLV_TO_HEX(TX_CLK_SEL1_LANE2_BINARY, TX_CLK_SEL1_LANE2_STRLEN);
    constant TX_CLK_SEL1_LANE3_STRING : string := SLV_TO_HEX(TX_CLK_SEL1_LANE3_BINARY, TX_CLK_SEL1_LANE3_STRLEN);
    constant TX_DISABLE_LANE0_STRING : string := SLV_TO_HEX(TX_DISABLE_LANE0_BINARY, TX_DISABLE_LANE0_STRLEN);
    constant TX_DISABLE_LANE1_STRING : string := SLV_TO_HEX(TX_DISABLE_LANE1_BINARY, TX_DISABLE_LANE1_STRLEN);
    constant TX_DISABLE_LANE2_STRING : string := SLV_TO_HEX(TX_DISABLE_LANE2_BINARY, TX_DISABLE_LANE2_STRLEN);
    constant TX_DISABLE_LANE3_STRING : string := SLV_TO_HEX(TX_DISABLE_LANE3_BINARY, TX_DISABLE_LANE3_STRLEN);
    constant TX_P0P0S_CTRL_STRING : string := SLV_TO_HEX(TX_P0P0S_CTRL_BINARY, TX_P0P0S_CTRL_STRLEN);
    constant TX_P1P2_CTRL_STRING : string := SLV_TO_HEX(TX_P1P2_CTRL_BINARY, TX_P1P2_CTRL_STRLEN);
    constant TX_PREEMPH_LANE0_STRING : string := SLV_TO_HEX(TX_PREEMPH_LANE0_BINARY, TX_PREEMPH_LANE0_STRLEN);
    constant TX_PREEMPH_LANE1_STRING : string := SLV_TO_HEX(TX_PREEMPH_LANE1_BINARY, TX_PREEMPH_LANE1_STRLEN);
    constant TX_PREEMPH_LANE2_STRING : string := SLV_TO_HEX(TX_PREEMPH_LANE2_BINARY, TX_PREEMPH_LANE2_STRLEN);
    constant TX_PREEMPH_LANE3_STRING : string := SLV_TO_HEX(TX_PREEMPH_LANE3_BINARY, TX_PREEMPH_LANE3_STRLEN);
    constant TX_PWR_RATE_OVRD_LANE0_STRING : string := SLV_TO_HEX(TX_PWR_RATE_OVRD_LANE0_BINARY, TX_PWR_RATE_OVRD_LANE0_STRLEN);
    constant TX_PWR_RATE_OVRD_LANE1_STRING : string := SLV_TO_HEX(TX_PWR_RATE_OVRD_LANE1_BINARY, TX_PWR_RATE_OVRD_LANE1_STRLEN);
    constant TX_PWR_RATE_OVRD_LANE2_STRING : string := SLV_TO_HEX(TX_PWR_RATE_OVRD_LANE2_BINARY, TX_PWR_RATE_OVRD_LANE2_STRLEN);
    constant TX_PWR_RATE_OVRD_LANE3_STRING : string := SLV_TO_HEX(TX_PWR_RATE_OVRD_LANE3_BINARY, TX_PWR_RATE_OVRD_LANE3_STRLEN);
    
    signal RX_FABRIC_WIDTH0_BINARY : std_logic_vector(2 downto 0);
    signal RX_FABRIC_WIDTH1_BINARY : std_logic_vector(2 downto 0);
    signal RX_FABRIC_WIDTH2_BINARY : std_logic_vector(2 downto 0);
    signal RX_FABRIC_WIDTH3_BINARY : std_logic_vector(2 downto 0);
    signal SIM_GTHRESET_SPEEDUP_BINARY : std_ulogic;
    signal SIM_VERSION_BINARY : std_ulogic;
    signal TX_FABRIC_WIDTH0_BINARY : std_logic_vector(2 downto 0);
    signal TX_FABRIC_WIDTH1_BINARY : std_logic_vector(2 downto 0);
    signal TX_FABRIC_WIDTH2_BINARY : std_logic_vector(2 downto 0);
    signal TX_FABRIC_WIDTH3_BINARY : std_logic_vector(2 downto 0);
    
    signal DRDY_out : std_ulogic;
    signal DRPDO_out : std_logic_vector(15 downto 0);
    signal GTHINITDONE_out : std_ulogic;
    signal MGMTPCSRDACK_out : std_ulogic;
    signal MGMTPCSRDDATA_out : std_logic_vector(15 downto 0);
    signal RXCODEERR0_out : std_logic_vector(7 downto 0);
    signal RXCODEERR1_out : std_logic_vector(7 downto 0);
    signal RXCODEERR2_out : std_logic_vector(7 downto 0);
    signal RXCODEERR3_out : std_logic_vector(7 downto 0);
    signal RXCTRL0_out : std_logic_vector(7 downto 0);
    signal RXCTRL1_out : std_logic_vector(7 downto 0);
    signal RXCTRL2_out : std_logic_vector(7 downto 0);
    signal RXCTRL3_out : std_logic_vector(7 downto 0);
    signal RXCTRLACK0_out : std_ulogic;
    signal RXCTRLACK1_out : std_ulogic;
    signal RXCTRLACK2_out : std_ulogic;
    signal RXCTRLACK3_out : std_ulogic;
    signal RXDATA0_out : std_logic_vector(63 downto 0);
    signal RXDATA1_out : std_logic_vector(63 downto 0);
    signal RXDATA2_out : std_logic_vector(63 downto 0);
    signal RXDATA3_out : std_logic_vector(63 downto 0);
    signal RXDATATAP0_out : std_ulogic;
    signal RXDATATAP1_out : std_ulogic;
    signal RXDATATAP2_out : std_ulogic;
    signal RXDATATAP3_out : std_ulogic;
    signal RXDISPERR0_out : std_logic_vector(7 downto 0);
    signal RXDISPERR1_out : std_logic_vector(7 downto 0);
    signal RXDISPERR2_out : std_logic_vector(7 downto 0);
    signal RXDISPERR3_out : std_logic_vector(7 downto 0);
    signal RXPCSCLKSMPL0_out : std_ulogic;
    signal RXPCSCLKSMPL1_out : std_ulogic;
    signal RXPCSCLKSMPL2_out : std_ulogic;
    signal RXPCSCLKSMPL3_out : std_ulogic;
    signal RXUSERCLKOUT0_out : std_ulogic;
    signal RXUSERCLKOUT1_out : std_ulogic;
    signal RXUSERCLKOUT2_out : std_ulogic;
    signal RXUSERCLKOUT3_out : std_ulogic;
    signal RXVALID0_out : std_logic_vector(7 downto 0);
    signal RXVALID1_out : std_logic_vector(7 downto 0);
    signal RXVALID2_out : std_logic_vector(7 downto 0);
    signal RXVALID3_out : std_logic_vector(7 downto 0);
    signal TSTPATH_out : std_ulogic;
    signal TSTREFCLKFAB_out : std_ulogic;
    signal TSTREFCLKOUT_out : std_ulogic;
    signal TXCTRLACK0_out : std_ulogic;
    signal TXCTRLACK1_out : std_ulogic;
    signal TXCTRLACK2_out : std_ulogic;
    signal TXCTRLACK3_out : std_ulogic;
    signal TXDATATAP10_out : std_ulogic;
    signal TXDATATAP11_out : std_ulogic;
    signal TXDATATAP12_out : std_ulogic;
    signal TXDATATAP13_out : std_ulogic;
    signal TXDATATAP20_out : std_ulogic;
    signal TXDATATAP21_out : std_ulogic;
    signal TXDATATAP22_out : std_ulogic;
    signal TXDATATAP23_out : std_ulogic;
    signal TXN0_out : std_ulogic;
    signal TXN1_out : std_ulogic;
    signal TXN2_out : std_ulogic;
    signal TXN3_out : std_ulogic;
    signal TXP0_out : std_ulogic;
    signal TXP1_out : std_ulogic;
    signal TXP2_out : std_ulogic;
    signal TXP3_out : std_ulogic;
    signal TXPCSCLKSMPL0_out : std_ulogic;
    signal TXPCSCLKSMPL1_out : std_ulogic;
    signal TXPCSCLKSMPL2_out : std_ulogic;
    signal TXPCSCLKSMPL3_out : std_ulogic;
    signal TXUSERCLKOUT0_out : std_ulogic;
    signal TXUSERCLKOUT1_out : std_ulogic;
    signal TXUSERCLKOUT2_out : std_ulogic;
    signal TXUSERCLKOUT3_out : std_ulogic;
    
    signal DRDY_outdelay : std_ulogic;
    signal DRPDO_outdelay : std_logic_vector(15 downto 0);
    signal GTHINITDONE_outdelay : std_ulogic;
    signal MGMTPCSRDACK_outdelay : std_ulogic;
    signal MGMTPCSRDDATA_outdelay : std_logic_vector(15 downto 0);
    signal RXCODEERR0_outdelay : std_logic_vector(7 downto 0);
    signal RXCODEERR1_outdelay : std_logic_vector(7 downto 0);
    signal RXCODEERR2_outdelay : std_logic_vector(7 downto 0);
    signal RXCODEERR3_outdelay : std_logic_vector(7 downto 0);
    signal RXCTRL0_outdelay : std_logic_vector(7 downto 0);
    signal RXCTRL1_outdelay : std_logic_vector(7 downto 0);
    signal RXCTRL2_outdelay : std_logic_vector(7 downto 0);
    signal RXCTRL3_outdelay : std_logic_vector(7 downto 0);
    signal RXCTRLACK0_outdelay : std_ulogic;
    signal RXCTRLACK1_outdelay : std_ulogic;
    signal RXCTRLACK2_outdelay : std_ulogic;
    signal RXCTRLACK3_outdelay : std_ulogic;
    signal RXDATA0_outdelay : std_logic_vector(63 downto 0);
    signal RXDATA1_outdelay : std_logic_vector(63 downto 0);
    signal RXDATA2_outdelay : std_logic_vector(63 downto 0);
    signal RXDATA3_outdelay : std_logic_vector(63 downto 0);
    signal RXDATATAP0_outdelay : std_ulogic;
    signal RXDATATAP1_outdelay : std_ulogic;
    signal RXDATATAP2_outdelay : std_ulogic;
    signal RXDATATAP3_outdelay : std_ulogic;
    signal RXDISPERR0_outdelay : std_logic_vector(7 downto 0);
    signal RXDISPERR1_outdelay : std_logic_vector(7 downto 0);
    signal RXDISPERR2_outdelay : std_logic_vector(7 downto 0);
    signal RXDISPERR3_outdelay : std_logic_vector(7 downto 0);
    signal RXPCSCLKSMPL0_outdelay : std_ulogic;
    signal RXPCSCLKSMPL1_outdelay : std_ulogic;
    signal RXPCSCLKSMPL2_outdelay : std_ulogic;
    signal RXPCSCLKSMPL3_outdelay : std_ulogic;
    signal RXUSERCLKOUT0_outdelay : std_ulogic;
    signal RXUSERCLKOUT1_outdelay : std_ulogic;
    signal RXUSERCLKOUT2_outdelay : std_ulogic;
    signal RXUSERCLKOUT3_outdelay : std_ulogic;
    signal RXVALID0_outdelay : std_logic_vector(7 downto 0);
    signal RXVALID1_outdelay : std_logic_vector(7 downto 0);
    signal RXVALID2_outdelay : std_logic_vector(7 downto 0);
    signal RXVALID3_outdelay : std_logic_vector(7 downto 0);
    signal TSTPATH_outdelay : std_ulogic;
    signal TSTREFCLKFAB_outdelay : std_ulogic;
    signal TSTREFCLKOUT_outdelay : std_ulogic;
    signal TXCTRLACK0_outdelay : std_ulogic;
    signal TXCTRLACK1_outdelay : std_ulogic;
    signal TXCTRLACK2_outdelay : std_ulogic;
    signal TXCTRLACK3_outdelay : std_ulogic;
    signal TXDATATAP10_outdelay : std_ulogic;
    signal TXDATATAP11_outdelay : std_ulogic;
    signal TXDATATAP12_outdelay : std_ulogic;
    signal TXDATATAP13_outdelay : std_ulogic;
    signal TXDATATAP20_outdelay : std_ulogic;
    signal TXDATATAP21_outdelay : std_ulogic;
    signal TXDATATAP22_outdelay : std_ulogic;
    signal TXDATATAP23_outdelay : std_ulogic;
    signal TXN0_outdelay : std_ulogic;
    signal TXN1_outdelay : std_ulogic;
    signal TXN2_outdelay : std_ulogic;
    signal TXN3_outdelay : std_ulogic;
    signal TXP0_outdelay : std_ulogic;
    signal TXP1_outdelay : std_ulogic;
    signal TXP2_outdelay : std_ulogic;
    signal TXP3_outdelay : std_ulogic;
    signal TXPCSCLKSMPL0_outdelay : std_ulogic;
    signal TXPCSCLKSMPL1_outdelay : std_ulogic;
    signal TXPCSCLKSMPL2_outdelay : std_ulogic;
    signal TXPCSCLKSMPL3_outdelay : std_ulogic;
    signal TXUSERCLKOUT0_outdelay : std_ulogic;
    signal TXUSERCLKOUT1_outdelay : std_ulogic;
    signal TXUSERCLKOUT2_outdelay : std_ulogic;
    signal TXUSERCLKOUT3_outdelay : std_ulogic;

    signal DADDR_ipd : std_logic_vector(15 downto 0);
    signal DCLK_ipd : std_ulogic;
    signal DEN_ipd : std_ulogic;
    signal DFETRAINCTRL0_ipd : std_ulogic;
    signal DFETRAINCTRL1_ipd : std_ulogic;
    signal DFETRAINCTRL2_ipd : std_ulogic;
    signal DFETRAINCTRL3_ipd : std_ulogic;
    signal DISABLEDRP_ipd : std_ulogic;
    signal DI_ipd : std_logic_vector(15 downto 0);
    signal DWE_ipd : std_ulogic;
    signal GTHINIT_ipd : std_ulogic;
    signal GTHRESET_ipd : std_ulogic;
    signal GTHX2LANE01_ipd : std_ulogic;
    signal GTHX2LANE23_ipd : std_ulogic;
    signal GTHX4LANE_ipd : std_ulogic;
    signal MGMTPCSLANESEL_ipd : std_logic_vector(3 downto 0);
    signal MGMTPCSMMDADDR_ipd : std_logic_vector(4 downto 0);
    signal MGMTPCSREGADDR_ipd : std_logic_vector(15 downto 0);
    signal MGMTPCSREGRD_ipd : std_ulogic;
    signal MGMTPCSREGWR_ipd : std_ulogic;
    signal MGMTPCSWRDATA_ipd : std_logic_vector(15 downto 0);
    signal PLLPCSCLKDIV_ipd : std_logic_vector(5 downto 0);
    signal PLLREFCLKSEL_ipd : std_logic_vector(2 downto 0);
    signal POWERDOWN0_ipd : std_ulogic;
    signal POWERDOWN1_ipd : std_ulogic;
    signal POWERDOWN2_ipd : std_ulogic;
    signal POWERDOWN3_ipd : std_ulogic;
    signal REFCLK_ipd : std_ulogic;
    signal RXBUFRESET0_ipd : std_ulogic;
    signal RXBUFRESET1_ipd : std_ulogic;
    signal RXBUFRESET2_ipd : std_ulogic;
    signal RXBUFRESET3_ipd : std_ulogic;
    signal RXENCOMMADET0_ipd : std_ulogic;
    signal RXENCOMMADET1_ipd : std_ulogic;
    signal RXENCOMMADET2_ipd : std_ulogic;
    signal RXENCOMMADET3_ipd : std_ulogic;
    signal RXN0_ipd : std_ulogic;
    signal RXN1_ipd : std_ulogic;
    signal RXN2_ipd : std_ulogic;
    signal RXN3_ipd : std_ulogic;
    signal RXP0_ipd : std_ulogic;
    signal RXP1_ipd : std_ulogic;
    signal RXP2_ipd : std_ulogic;
    signal RXP3_ipd : std_ulogic;
    signal RXPOLARITY0_ipd : std_ulogic;
    signal RXPOLARITY1_ipd : std_ulogic;
    signal RXPOLARITY2_ipd : std_ulogic;
    signal RXPOLARITY3_ipd : std_ulogic;
    signal RXPOWERDOWN0_ipd : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN1_ipd : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN2_ipd : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN3_ipd : std_logic_vector(1 downto 0);
    signal RXRATE0_ipd : std_logic_vector(1 downto 0);
    signal RXRATE1_ipd : std_logic_vector(1 downto 0);
    signal RXRATE2_ipd : std_logic_vector(1 downto 0);
    signal RXRATE3_ipd : std_logic_vector(1 downto 0);
    signal RXSLIP0_ipd : std_ulogic;
    signal RXSLIP1_ipd : std_ulogic;
    signal RXSLIP2_ipd : std_ulogic;
    signal RXSLIP3_ipd : std_ulogic;
    signal RXUSERCLKIN0_ipd : std_ulogic;
    signal RXUSERCLKIN1_ipd : std_ulogic;
    signal RXUSERCLKIN2_ipd : std_ulogic;
    signal RXUSERCLKIN3_ipd : std_ulogic;
    signal SAMPLERATE0_ipd : std_logic_vector(2 downto 0);
    signal SAMPLERATE1_ipd : std_logic_vector(2 downto 0);
    signal SAMPLERATE2_ipd : std_logic_vector(2 downto 0);
    signal SAMPLERATE3_ipd : std_logic_vector(2 downto 0);
    signal TXBUFRESET0_ipd : std_ulogic;
    signal TXBUFRESET1_ipd : std_ulogic;
    signal TXBUFRESET2_ipd : std_ulogic;
    signal TXBUFRESET3_ipd : std_ulogic;
    signal TXCTRL0_ipd : std_logic_vector(7 downto 0);
    signal TXCTRL1_ipd : std_logic_vector(7 downto 0);
    signal TXCTRL2_ipd : std_logic_vector(7 downto 0);
    signal TXCTRL3_ipd : std_logic_vector(7 downto 0);
    signal TXDATA0_ipd : std_logic_vector(63 downto 0);
    signal TXDATA1_ipd : std_logic_vector(63 downto 0);
    signal TXDATA2_ipd : std_logic_vector(63 downto 0);
    signal TXDATA3_ipd : std_logic_vector(63 downto 0);
    signal TXDATAMSB0_ipd : std_logic_vector(7 downto 0);
    signal TXDATAMSB1_ipd : std_logic_vector(7 downto 0);
    signal TXDATAMSB2_ipd : std_logic_vector(7 downto 0);
    signal TXDATAMSB3_ipd : std_logic_vector(7 downto 0);
    signal TXDEEMPH0_ipd : std_ulogic;
    signal TXDEEMPH1_ipd : std_ulogic;
    signal TXDEEMPH2_ipd : std_ulogic;
    signal TXDEEMPH3_ipd : std_ulogic;
    signal TXMARGIN0_ipd : std_logic_vector(2 downto 0);
    signal TXMARGIN1_ipd : std_logic_vector(2 downto 0);
    signal TXMARGIN2_ipd : std_logic_vector(2 downto 0);
    signal TXMARGIN3_ipd : std_logic_vector(2 downto 0);
    signal TXPOWERDOWN0_ipd : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN1_ipd : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN2_ipd : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN3_ipd : std_logic_vector(1 downto 0);
    signal TXRATE0_ipd : std_logic_vector(1 downto 0);
    signal TXRATE1_ipd : std_logic_vector(1 downto 0);
    signal TXRATE2_ipd : std_logic_vector(1 downto 0);
    signal TXRATE3_ipd : std_logic_vector(1 downto 0);
    signal TXUSERCLKIN0_ipd : std_ulogic;
    signal TXUSERCLKIN1_ipd : std_ulogic;
    signal TXUSERCLKIN2_ipd : std_ulogic;
    signal TXUSERCLKIN3_ipd : std_ulogic;
    
    signal DADDR_indelay : std_logic_vector(15 downto 0);
    signal DCLK_indelay : std_ulogic;
    signal DEN_indelay : std_ulogic;
    signal DFETRAINCTRL0_indelay : std_ulogic;
    signal DFETRAINCTRL1_indelay : std_ulogic;
    signal DFETRAINCTRL2_indelay : std_ulogic;
    signal DFETRAINCTRL3_indelay : std_ulogic;
    signal DISABLEDRP_indelay : std_ulogic;
    signal DI_indelay : std_logic_vector(15 downto 0);
    signal DWE_indelay : std_ulogic;
    signal GTHINIT_indelay : std_ulogic;
    signal GTHRESET_indelay : std_ulogic;
    signal GTHX2LANE01_indelay : std_ulogic;
    signal GTHX2LANE23_indelay : std_ulogic;
    signal GTHX4LANE_indelay : std_ulogic;
    signal MGMTPCSLANESEL_indelay : std_logic_vector(3 downto 0);
    signal MGMTPCSMMDADDR_indelay : std_logic_vector(4 downto 0);
    signal MGMTPCSREGADDR_indelay : std_logic_vector(15 downto 0);
    signal MGMTPCSREGRD_indelay : std_ulogic;
    signal MGMTPCSREGWR_indelay : std_ulogic;
    signal MGMTPCSWRDATA_indelay : std_logic_vector(15 downto 0);
    signal PLLPCSCLKDIV_indelay : std_logic_vector(5 downto 0);
    signal PLLREFCLKSEL_indelay : std_logic_vector(2 downto 0);
    signal POWERDOWN0_indelay : std_ulogic;
    signal POWERDOWN1_indelay : std_ulogic;
    signal POWERDOWN2_indelay : std_ulogic;
    signal POWERDOWN3_indelay : std_ulogic;
    signal REFCLK_indelay : std_ulogic;
    signal RXBUFRESET0_indelay : std_ulogic;
    signal RXBUFRESET1_indelay : std_ulogic;
    signal RXBUFRESET2_indelay : std_ulogic;
    signal RXBUFRESET3_indelay : std_ulogic;
    signal RXENCOMMADET0_indelay : std_ulogic;
    signal RXENCOMMADET1_indelay : std_ulogic;
    signal RXENCOMMADET2_indelay : std_ulogic;
    signal RXENCOMMADET3_indelay : std_ulogic;
    signal RXN0_indelay : std_ulogic;
    signal RXN1_indelay : std_ulogic;
    signal RXN2_indelay : std_ulogic;
    signal RXN3_indelay : std_ulogic;
    signal RXP0_indelay : std_ulogic;
    signal RXP1_indelay : std_ulogic;
    signal RXP2_indelay : std_ulogic;
    signal RXP3_indelay : std_ulogic;
    signal RXPOLARITY0_indelay : std_ulogic;
    signal RXPOLARITY1_indelay : std_ulogic;
    signal RXPOLARITY2_indelay : std_ulogic;
    signal RXPOLARITY3_indelay : std_ulogic;
    signal RXPOWERDOWN0_indelay : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN1_indelay : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN2_indelay : std_logic_vector(1 downto 0);
    signal RXPOWERDOWN3_indelay : std_logic_vector(1 downto 0);
    signal RXRATE0_indelay : std_logic_vector(1 downto 0);
    signal RXRATE1_indelay : std_logic_vector(1 downto 0);
    signal RXRATE2_indelay : std_logic_vector(1 downto 0);
    signal RXRATE3_indelay : std_logic_vector(1 downto 0);
    signal RXSLIP0_indelay : std_ulogic;
    signal RXSLIP1_indelay : std_ulogic;
    signal RXSLIP2_indelay : std_ulogic;
    signal RXSLIP3_indelay : std_ulogic;
    signal RXUSERCLKIN0_indelay : std_ulogic;
    signal RXUSERCLKIN1_indelay : std_ulogic;
    signal RXUSERCLKIN2_indelay : std_ulogic;
    signal RXUSERCLKIN3_indelay : std_ulogic;
    signal SAMPLERATE0_indelay : std_logic_vector(2 downto 0);
    signal SAMPLERATE1_indelay : std_logic_vector(2 downto 0);
    signal SAMPLERATE2_indelay : std_logic_vector(2 downto 0);
    signal SAMPLERATE3_indelay : std_logic_vector(2 downto 0);
    signal TXBUFRESET0_indelay : std_ulogic;
    signal TXBUFRESET1_indelay : std_ulogic;
    signal TXBUFRESET2_indelay : std_ulogic;
    signal TXBUFRESET3_indelay : std_ulogic;
    signal TXCTRL0_indelay : std_logic_vector(7 downto 0);
    signal TXCTRL1_indelay : std_logic_vector(7 downto 0);
    signal TXCTRL2_indelay : std_logic_vector(7 downto 0);
    signal TXCTRL3_indelay : std_logic_vector(7 downto 0);
    signal TXDATA0_indelay : std_logic_vector(63 downto 0);
    signal TXDATA1_indelay : std_logic_vector(63 downto 0);
    signal TXDATA2_indelay : std_logic_vector(63 downto 0);
    signal TXDATA3_indelay : std_logic_vector(63 downto 0);
    signal TXDATAMSB0_indelay : std_logic_vector(7 downto 0);
    signal TXDATAMSB1_indelay : std_logic_vector(7 downto 0);
    signal TXDATAMSB2_indelay : std_logic_vector(7 downto 0);
    signal TXDATAMSB3_indelay : std_logic_vector(7 downto 0);
    signal TXDEEMPH0_indelay : std_ulogic;
    signal TXDEEMPH1_indelay : std_ulogic;
    signal TXDEEMPH2_indelay : std_ulogic;
    signal TXDEEMPH3_indelay : std_ulogic;
    signal TXMARGIN0_indelay : std_logic_vector(2 downto 0);
    signal TXMARGIN1_indelay : std_logic_vector(2 downto 0);
    signal TXMARGIN2_indelay : std_logic_vector(2 downto 0);
    signal TXMARGIN3_indelay : std_logic_vector(2 downto 0);
    signal TXPOWERDOWN0_indelay : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN1_indelay : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN2_indelay : std_logic_vector(1 downto 0);
    signal TXPOWERDOWN3_indelay : std_logic_vector(1 downto 0);
    signal TXRATE0_indelay : std_logic_vector(1 downto 0);
    signal TXRATE1_indelay : std_logic_vector(1 downto 0);
    signal TXRATE2_indelay : std_logic_vector(1 downto 0);
    signal TXRATE3_indelay : std_logic_vector(1 downto 0);
    signal TXUSERCLKIN0_indelay : std_ulogic;
    signal TXUSERCLKIN1_indelay : std_ulogic;
    signal TXUSERCLKIN2_indelay : std_ulogic;
    signal TXUSERCLKIN3_indelay : std_ulogic;
    
    begin
    RXUSERCLKOUT0_out <= RXUSERCLKOUT0_outdelay after OUTCLK_DELAY;
    RXUSERCLKOUT1_out <= RXUSERCLKOUT1_outdelay after OUTCLK_DELAY;
    RXUSERCLKOUT2_out <= RXUSERCLKOUT2_outdelay after OUTCLK_DELAY;
    RXUSERCLKOUT3_out <= RXUSERCLKOUT3_outdelay after OUTCLK_DELAY;
    TSTPATH_out <= TSTPATH_outdelay after OUTCLK_DELAY;
    TSTREFCLKFAB_out <= TSTREFCLKFAB_outdelay after OUTCLK_DELAY;
    TSTREFCLKOUT_out <= TSTREFCLKOUT_outdelay after OUTCLK_DELAY;
    TXUSERCLKOUT0_out <= TXUSERCLKOUT0_outdelay after OUTCLK_DELAY;
    TXUSERCLKOUT1_out <= TXUSERCLKOUT1_outdelay after OUTCLK_DELAY;
    TXUSERCLKOUT2_out <= TXUSERCLKOUT2_outdelay after OUTCLK_DELAY;
    TXUSERCLKOUT3_out <= TXUSERCLKOUT3_outdelay after OUTCLK_DELAY;

    DRDY_out <= DRDY_outdelay after OUT_DELAY;
    DRPDO_out <= DRPDO_outdelay after OUT_DELAY;
    GTHINITDONE_out <= GTHINITDONE_outdelay after OUT_DELAY;
    MGMTPCSRDACK_out <= MGMTPCSRDACK_outdelay after OUT_DELAY;
    MGMTPCSRDDATA_out <= MGMTPCSRDDATA_outdelay after OUT_DELAY;
    RXCODEERR0_out <= RXCODEERR0_outdelay after OUT_DELAY;
    RXCODEERR1_out <= RXCODEERR1_outdelay after OUT_DELAY;
    RXCODEERR2_out <= RXCODEERR2_outdelay after OUT_DELAY;
    RXCODEERR3_out <= RXCODEERR3_outdelay after OUT_DELAY;
    RXCTRL0_out <= RXCTRL0_outdelay after OUT_DELAY;
    RXCTRL1_out <= RXCTRL1_outdelay after OUT_DELAY;
    RXCTRL2_out <= RXCTRL2_outdelay after OUT_DELAY;
    RXCTRL3_out <= RXCTRL3_outdelay after OUT_DELAY;
    RXCTRLACK0_out <= RXCTRLACK0_outdelay after OUT_DELAY;
    RXCTRLACK1_out <= RXCTRLACK1_outdelay after OUT_DELAY;
    RXCTRLACK2_out <= RXCTRLACK2_outdelay after OUT_DELAY;
    RXCTRLACK3_out <= RXCTRLACK3_outdelay after OUT_DELAY;
    RXDATA0_out <= RXDATA0_outdelay after OUT_DELAY;
    RXDATA1_out <= RXDATA1_outdelay after OUT_DELAY;
    RXDATA2_out <= RXDATA2_outdelay after OUT_DELAY;
    RXDATA3_out <= RXDATA3_outdelay after OUT_DELAY;
    RXDATATAP0_out <= RXDATATAP0_outdelay after OUT_DELAY;
    RXDATATAP1_out <= RXDATATAP1_outdelay after OUT_DELAY;
    RXDATATAP2_out <= RXDATATAP2_outdelay after OUT_DELAY;
    RXDATATAP3_out <= RXDATATAP3_outdelay after OUT_DELAY;
    RXDISPERR0_out <= RXDISPERR0_outdelay after OUT_DELAY;
    RXDISPERR1_out <= RXDISPERR1_outdelay after OUT_DELAY;
    RXDISPERR2_out <= RXDISPERR2_outdelay after OUT_DELAY;
    RXDISPERR3_out <= RXDISPERR3_outdelay after OUT_DELAY;
    RXPCSCLKSMPL0_out <= RXPCSCLKSMPL0_outdelay after OUT_DELAY;
    RXPCSCLKSMPL1_out <= RXPCSCLKSMPL1_outdelay after OUT_DELAY;
    RXPCSCLKSMPL2_out <= RXPCSCLKSMPL2_outdelay after OUT_DELAY;
    RXPCSCLKSMPL3_out <= RXPCSCLKSMPL3_outdelay after OUT_DELAY;
    RXVALID0_out <= RXVALID0_outdelay after OUT_DELAY;
    RXVALID1_out <= RXVALID1_outdelay after OUT_DELAY;
    RXVALID2_out <= RXVALID2_outdelay after OUT_DELAY;
    RXVALID3_out <= RXVALID3_outdelay after OUT_DELAY;
    TXCTRLACK0_out <= TXCTRLACK0_outdelay after OUT_DELAY;
    TXCTRLACK1_out <= TXCTRLACK1_outdelay after OUT_DELAY;
    TXCTRLACK2_out <= TXCTRLACK2_outdelay after OUT_DELAY;
    TXCTRLACK3_out <= TXCTRLACK3_outdelay after OUT_DELAY;
    TXDATATAP10_out <= TXDATATAP10_outdelay after OUT_DELAY;
    TXDATATAP11_out <= TXDATATAP11_outdelay after OUT_DELAY;
    TXDATATAP12_out <= TXDATATAP12_outdelay after OUT_DELAY;
    TXDATATAP13_out <= TXDATATAP13_outdelay after OUT_DELAY;
    TXDATATAP20_out <= TXDATATAP20_outdelay after OUT_DELAY;
    TXDATATAP21_out <= TXDATATAP21_outdelay after OUT_DELAY;
    TXDATATAP22_out <= TXDATATAP22_outdelay after OUT_DELAY;
    TXDATATAP23_out <= TXDATATAP23_outdelay after OUT_DELAY;
    TXN0_out <= TXN0_outdelay after OUT_DELAY;
    TXN1_out <= TXN1_outdelay after OUT_DELAY;
    TXN2_out <= TXN2_outdelay after OUT_DELAY;
    TXN3_out <= TXN3_outdelay after OUT_DELAY;
    TXP0_out <= TXP0_outdelay after OUT_DELAY;
    TXP1_out <= TXP1_outdelay after OUT_DELAY;
    TXP2_out <= TXP2_outdelay after OUT_DELAY;
    TXP3_out <= TXP3_outdelay after OUT_DELAY;
    TXPCSCLKSMPL0_out <= TXPCSCLKSMPL0_outdelay after OUT_DELAY;
    TXPCSCLKSMPL1_out <= TXPCSCLKSMPL1_outdelay after OUT_DELAY;
    TXPCSCLKSMPL2_out <= TXPCSCLKSMPL2_outdelay after OUT_DELAY;
    TXPCSCLKSMPL3_out <= TXPCSCLKSMPL3_outdelay after OUT_DELAY;
    
    DCLK_ipd <= DCLK;
    REFCLK_ipd <= REFCLK;
    RXUSERCLKIN0_ipd <= RXUSERCLKIN0;
    RXUSERCLKIN1_ipd <= RXUSERCLKIN1;
    RXUSERCLKIN2_ipd <= RXUSERCLKIN2;
    RXUSERCLKIN3_ipd <= RXUSERCLKIN3;
    TXUSERCLKIN0_ipd <= TXUSERCLKIN0;
    TXUSERCLKIN1_ipd <= TXUSERCLKIN1;
    TXUSERCLKIN2_ipd <= TXUSERCLKIN2;
    TXUSERCLKIN3_ipd <= TXUSERCLKIN3;
    
    DADDR_ipd <= DADDR;
    DEN_ipd <= DEN;
    DFETRAINCTRL0_ipd <= DFETRAINCTRL0;
    DFETRAINCTRL1_ipd <= DFETRAINCTRL1;
    DFETRAINCTRL2_ipd <= DFETRAINCTRL2;
    DFETRAINCTRL3_ipd <= DFETRAINCTRL3;
    DISABLEDRP_ipd <= DISABLEDRP;
    DI_ipd <= DI;
    DWE_ipd <= DWE;
    GTHINIT_ipd <= GTHINIT;
    GTHRESET_ipd <= GTHRESET;
    GTHX2LANE01_ipd <= GTHX2LANE01;
    GTHX2LANE23_ipd <= GTHX2LANE23;
    GTHX4LANE_ipd <= GTHX4LANE;
    MGMTPCSLANESEL_ipd <= MGMTPCSLANESEL;
    MGMTPCSMMDADDR_ipd <= MGMTPCSMMDADDR;
    MGMTPCSREGADDR_ipd <= MGMTPCSREGADDR;
    MGMTPCSREGRD_ipd <= MGMTPCSREGRD;
    MGMTPCSREGWR_ipd <= MGMTPCSREGWR;
    MGMTPCSWRDATA_ipd <= MGMTPCSWRDATA;
    PLLPCSCLKDIV_ipd <= PLLPCSCLKDIV;
    PLLREFCLKSEL_ipd <= PLLREFCLKSEL;
    POWERDOWN0_ipd <= POWERDOWN0;
    POWERDOWN1_ipd <= POWERDOWN1;
    POWERDOWN2_ipd <= POWERDOWN2;
    POWERDOWN3_ipd <= POWERDOWN3;
    RXBUFRESET0_ipd <= RXBUFRESET0;
    RXBUFRESET1_ipd <= RXBUFRESET1;
    RXBUFRESET2_ipd <= RXBUFRESET2;
    RXBUFRESET3_ipd <= RXBUFRESET3;
    RXENCOMMADET0_ipd <= RXENCOMMADET0;
    RXENCOMMADET1_ipd <= RXENCOMMADET1;
    RXENCOMMADET2_ipd <= RXENCOMMADET2;
    RXENCOMMADET3_ipd <= RXENCOMMADET3;
    RXN0_ipd <= RXN0;
    RXN1_ipd <= RXN1;
    RXN2_ipd <= RXN2;
    RXN3_ipd <= RXN3;
    RXP0_ipd <= RXP0;
    RXP1_ipd <= RXP1;
    RXP2_ipd <= RXP2;
    RXP3_ipd <= RXP3;
    RXPOLARITY0_ipd <= RXPOLARITY0;
    RXPOLARITY1_ipd <= RXPOLARITY1;
    RXPOLARITY2_ipd <= RXPOLARITY2;
    RXPOLARITY3_ipd <= RXPOLARITY3;
    RXPOWERDOWN0_ipd <= RXPOWERDOWN0;
    RXPOWERDOWN1_ipd <= RXPOWERDOWN1;
    RXPOWERDOWN2_ipd <= RXPOWERDOWN2;
    RXPOWERDOWN3_ipd <= RXPOWERDOWN3;
    RXRATE0_ipd <= RXRATE0;
    RXRATE1_ipd <= RXRATE1;
    RXRATE2_ipd <= RXRATE2;
    RXRATE3_ipd <= RXRATE3;
    RXSLIP0_ipd <= RXSLIP0;
    RXSLIP1_ipd <= RXSLIP1;
    RXSLIP2_ipd <= RXSLIP2;
    RXSLIP3_ipd <= RXSLIP3;
    SAMPLERATE0_ipd <= SAMPLERATE0;
    SAMPLERATE1_ipd <= SAMPLERATE1;
    SAMPLERATE2_ipd <= SAMPLERATE2;
    SAMPLERATE3_ipd <= SAMPLERATE3;
    TXBUFRESET0_ipd <= TXBUFRESET0;
    TXBUFRESET1_ipd <= TXBUFRESET1;
    TXBUFRESET2_ipd <= TXBUFRESET2;
    TXBUFRESET3_ipd <= TXBUFRESET3;
    TXCTRL0_ipd <= TXCTRL0;
    TXCTRL1_ipd <= TXCTRL1;
    TXCTRL2_ipd <= TXCTRL2;
    TXCTRL3_ipd <= TXCTRL3;
    TXDATA0_ipd <= TXDATA0;
    TXDATA1_ipd <= TXDATA1;
    TXDATA2_ipd <= TXDATA2;
    TXDATA3_ipd <= TXDATA3;
    TXDATAMSB0_ipd <= TXDATAMSB0;
    TXDATAMSB1_ipd <= TXDATAMSB1;
    TXDATAMSB2_ipd <= TXDATAMSB2;
    TXDATAMSB3_ipd <= TXDATAMSB3;
    TXDEEMPH0_ipd <= TXDEEMPH0;
    TXDEEMPH1_ipd <= TXDEEMPH1;
    TXDEEMPH2_ipd <= TXDEEMPH2;
    TXDEEMPH3_ipd <= TXDEEMPH3;
    TXMARGIN0_ipd <= TXMARGIN0;
    TXMARGIN1_ipd <= TXMARGIN1;
    TXMARGIN2_ipd <= TXMARGIN2;
    TXMARGIN3_ipd <= TXMARGIN3;
    TXPOWERDOWN0_ipd <= TXPOWERDOWN0;
    TXPOWERDOWN1_ipd <= TXPOWERDOWN1;
    TXPOWERDOWN2_ipd <= TXPOWERDOWN2;
    TXPOWERDOWN3_ipd <= TXPOWERDOWN3;
    TXRATE0_ipd <= TXRATE0;
    TXRATE1_ipd <= TXRATE1;
    TXRATE2_ipd <= TXRATE2;
    TXRATE3_ipd <= TXRATE3;
    
    DCLK_indelay <= DCLK_ipd after INCLK_DELAY;
    REFCLK_indelay <= REFCLK_ipd after INCLK_DELAY;
    RXUSERCLKIN0_indelay <= RXUSERCLKIN0_ipd after INCLK_DELAY;
    RXUSERCLKIN1_indelay <= RXUSERCLKIN1_ipd after INCLK_DELAY;
    RXUSERCLKIN2_indelay <= RXUSERCLKIN2_ipd after INCLK_DELAY;
    RXUSERCLKIN3_indelay <= RXUSERCLKIN3_ipd after INCLK_DELAY;
    TXUSERCLKIN0_indelay <= TXUSERCLKIN0_ipd after INCLK_DELAY;
    TXUSERCLKIN1_indelay <= TXUSERCLKIN1_ipd after INCLK_DELAY;
    TXUSERCLKIN2_indelay <= TXUSERCLKIN2_ipd after INCLK_DELAY;
    TXUSERCLKIN3_indelay <= TXUSERCLKIN3_ipd after INCLK_DELAY;
    
    DADDR_indelay <= DADDR_ipd after IN_DELAY;
    DEN_indelay <= DEN_ipd after IN_DELAY;
    DFETRAINCTRL0_indelay <= DFETRAINCTRL0_ipd after IN_DELAY;
    DFETRAINCTRL1_indelay <= DFETRAINCTRL1_ipd after IN_DELAY;
    DFETRAINCTRL2_indelay <= DFETRAINCTRL2_ipd after IN_DELAY;
    DFETRAINCTRL3_indelay <= DFETRAINCTRL3_ipd after IN_DELAY;
    DISABLEDRP_indelay <= DISABLEDRP_ipd after IN_DELAY;
    DI_indelay <= DI_ipd after IN_DELAY;
    DWE_indelay <= DWE_ipd after IN_DELAY;
    GTHINIT_indelay <= GTHINIT_ipd after IN_DELAY;
    GTHRESET_indelay <= GTHRESET_ipd after IN_DELAY;
    GTHX2LANE01_indelay <= GTHX2LANE01_ipd after IN_DELAY;
    GTHX2LANE23_indelay <= GTHX2LANE23_ipd after IN_DELAY;
    GTHX4LANE_indelay <= GTHX4LANE_ipd after IN_DELAY;
    MGMTPCSLANESEL_indelay <= MGMTPCSLANESEL_ipd after IN_DELAY;
    MGMTPCSMMDADDR_indelay <= MGMTPCSMMDADDR_ipd after IN_DELAY;
    MGMTPCSREGADDR_indelay <= MGMTPCSREGADDR_ipd after IN_DELAY;
    MGMTPCSREGRD_indelay <= MGMTPCSREGRD_ipd after IN_DELAY;
    MGMTPCSREGWR_indelay <= MGMTPCSREGWR_ipd after IN_DELAY;
    MGMTPCSWRDATA_indelay <= MGMTPCSWRDATA_ipd after IN_DELAY;
    PLLPCSCLKDIV_indelay <= PLLPCSCLKDIV_ipd after IN_DELAY;
    PLLREFCLKSEL_indelay <= PLLREFCLKSEL_ipd after IN_DELAY;
    POWERDOWN0_indelay <= POWERDOWN0_ipd after IN_DELAY;
    POWERDOWN1_indelay <= POWERDOWN1_ipd after IN_DELAY;
    POWERDOWN2_indelay <= POWERDOWN2_ipd after IN_DELAY;
    POWERDOWN3_indelay <= POWERDOWN3_ipd after IN_DELAY;
    RXBUFRESET0_indelay <= RXBUFRESET0_ipd after IN_DELAY;
    RXBUFRESET1_indelay <= RXBUFRESET1_ipd after IN_DELAY;
    RXBUFRESET2_indelay <= RXBUFRESET2_ipd after IN_DELAY;
    RXBUFRESET3_indelay <= RXBUFRESET3_ipd after IN_DELAY;
    RXENCOMMADET0_indelay <= RXENCOMMADET0_ipd after IN_DELAY;
    RXENCOMMADET1_indelay <= RXENCOMMADET1_ipd after IN_DELAY;
    RXENCOMMADET2_indelay <= RXENCOMMADET2_ipd after IN_DELAY;
    RXENCOMMADET3_indelay <= RXENCOMMADET3_ipd after IN_DELAY;
    RXN0_indelay <= RXN0_ipd after IN_DELAY;
    RXN1_indelay <= RXN1_ipd after IN_DELAY;
    RXN2_indelay <= RXN2_ipd after IN_DELAY;
    RXN3_indelay <= RXN3_ipd after IN_DELAY;
    RXP0_indelay <= RXP0_ipd after IN_DELAY;
    RXP1_indelay <= RXP1_ipd after IN_DELAY;
    RXP2_indelay <= RXP2_ipd after IN_DELAY;
    RXP3_indelay <= RXP3_ipd after IN_DELAY;
    RXPOLARITY0_indelay <= RXPOLARITY0_ipd after IN_DELAY;
    RXPOLARITY1_indelay <= RXPOLARITY1_ipd after IN_DELAY;
    RXPOLARITY2_indelay <= RXPOLARITY2_ipd after IN_DELAY;
    RXPOLARITY3_indelay <= RXPOLARITY3_ipd after IN_DELAY;
    RXPOWERDOWN0_indelay <= RXPOWERDOWN0_ipd after IN_DELAY;
    RXPOWERDOWN1_indelay <= RXPOWERDOWN1_ipd after IN_DELAY;
    RXPOWERDOWN2_indelay <= RXPOWERDOWN2_ipd after IN_DELAY;
    RXPOWERDOWN3_indelay <= RXPOWERDOWN3_ipd after IN_DELAY;
    RXRATE0_indelay <= RXRATE0_ipd after IN_DELAY;
    RXRATE1_indelay <= RXRATE1_ipd after IN_DELAY;
    RXRATE2_indelay <= RXRATE2_ipd after IN_DELAY;
    RXRATE3_indelay <= RXRATE3_ipd after IN_DELAY;
    RXSLIP0_indelay <= RXSLIP0_ipd after IN_DELAY;
    RXSLIP1_indelay <= RXSLIP1_ipd after IN_DELAY;
    RXSLIP2_indelay <= RXSLIP2_ipd after IN_DELAY;
    RXSLIP3_indelay <= RXSLIP3_ipd after IN_DELAY;
    SAMPLERATE0_indelay <= SAMPLERATE0_ipd after IN_DELAY;
    SAMPLERATE1_indelay <= SAMPLERATE1_ipd after IN_DELAY;
    SAMPLERATE2_indelay <= SAMPLERATE2_ipd after IN_DELAY;
    SAMPLERATE3_indelay <= SAMPLERATE3_ipd after IN_DELAY;
    TXBUFRESET0_indelay <= TXBUFRESET0_ipd after IN_DELAY;
    TXBUFRESET1_indelay <= TXBUFRESET1_ipd after IN_DELAY;
    TXBUFRESET2_indelay <= TXBUFRESET2_ipd after IN_DELAY;
    TXBUFRESET3_indelay <= TXBUFRESET3_ipd after IN_DELAY;
    TXCTRL0_indelay <= TXCTRL0_ipd after IN_DELAY;
    TXCTRL1_indelay <= TXCTRL1_ipd after IN_DELAY;
    TXCTRL2_indelay <= TXCTRL2_ipd after IN_DELAY;
    TXCTRL3_indelay <= TXCTRL3_ipd after IN_DELAY;
    TXDATA0_indelay <= TXDATA0_ipd after IN_DELAY;
    TXDATA1_indelay <= TXDATA1_ipd after IN_DELAY;
    TXDATA2_indelay <= TXDATA2_ipd after IN_DELAY;
    TXDATA3_indelay <= TXDATA3_ipd after IN_DELAY;
    TXDATAMSB0_indelay <= TXDATAMSB0_ipd after IN_DELAY;
    TXDATAMSB1_indelay <= TXDATAMSB1_ipd after IN_DELAY;
    TXDATAMSB2_indelay <= TXDATAMSB2_ipd after IN_DELAY;
    TXDATAMSB3_indelay <= TXDATAMSB3_ipd after IN_DELAY;
    TXDEEMPH0_indelay <= TXDEEMPH0_ipd after IN_DELAY;
    TXDEEMPH1_indelay <= TXDEEMPH1_ipd after IN_DELAY;
    TXDEEMPH2_indelay <= TXDEEMPH2_ipd after IN_DELAY;
    TXDEEMPH3_indelay <= TXDEEMPH3_ipd after IN_DELAY;
    TXMARGIN0_indelay <= TXMARGIN0_ipd after IN_DELAY;
    TXMARGIN1_indelay <= TXMARGIN1_ipd after IN_DELAY;
    TXMARGIN2_indelay <= TXMARGIN2_ipd after IN_DELAY;
    TXMARGIN3_indelay <= TXMARGIN3_ipd after IN_DELAY;
    TXPOWERDOWN0_indelay <= TXPOWERDOWN0_ipd after IN_DELAY;
    TXPOWERDOWN1_indelay <= TXPOWERDOWN1_ipd after IN_DELAY;
    TXPOWERDOWN2_indelay <= TXPOWERDOWN2_ipd after IN_DELAY;
    TXPOWERDOWN3_indelay <= TXPOWERDOWN3_ipd after IN_DELAY;
    TXRATE0_indelay <= TXRATE0_ipd after IN_DELAY;
    TXRATE1_indelay <= TXRATE1_ipd after IN_DELAY;
    TXRATE2_indelay <= TXRATE2_ipd after IN_DELAY;
    TXRATE3_indelay <= TXRATE3_ipd after IN_DELAY;
    
    
    GTHE1_QUAD_INST : GTHE1_QUAD_WRAP
      generic map (
        BER_CONST_PTRN0      => BER_CONST_PTRN0_STRING,
        BER_CONST_PTRN1      => BER_CONST_PTRN1_STRING,
        BUFFER_CONFIG_LANE0  => BUFFER_CONFIG_LANE0_STRING,
        BUFFER_CONFIG_LANE1  => BUFFER_CONFIG_LANE1_STRING,
        BUFFER_CONFIG_LANE2  => BUFFER_CONFIG_LANE2_STRING,
        BUFFER_CONFIG_LANE3  => BUFFER_CONFIG_LANE3_STRING,
        DFE_TRAIN_CTRL_LANE0 => DFE_TRAIN_CTRL_LANE0_STRING,
        DFE_TRAIN_CTRL_LANE1 => DFE_TRAIN_CTRL_LANE1_STRING,
        DFE_TRAIN_CTRL_LANE2 => DFE_TRAIN_CTRL_LANE2_STRING,
        DFE_TRAIN_CTRL_LANE3 => DFE_TRAIN_CTRL_LANE3_STRING,
        DLL_CFG0             => DLL_CFG0_STRING,
        DLL_CFG1             => DLL_CFG1_STRING,
        E10GBASEKR_LD_COEFF_UPD_LANE0 => E10GBASEKR_LD_COEFF_UPD_LANE0_STRING,
        E10GBASEKR_LD_COEFF_UPD_LANE1 => E10GBASEKR_LD_COEFF_UPD_LANE1_STRING,
        E10GBASEKR_LD_COEFF_UPD_LANE2 => E10GBASEKR_LD_COEFF_UPD_LANE2_STRING,
        E10GBASEKR_LD_COEFF_UPD_LANE3 => E10GBASEKR_LD_COEFF_UPD_LANE3_STRING,
        E10GBASEKR_LP_COEFF_UPD_LANE0 => E10GBASEKR_LP_COEFF_UPD_LANE0_STRING,
        E10GBASEKR_LP_COEFF_UPD_LANE1 => E10GBASEKR_LP_COEFF_UPD_LANE1_STRING,
        E10GBASEKR_LP_COEFF_UPD_LANE2 => E10GBASEKR_LP_COEFF_UPD_LANE2_STRING,
        E10GBASEKR_LP_COEFF_UPD_LANE3 => E10GBASEKR_LP_COEFF_UPD_LANE3_STRING,
        E10GBASEKR_PMA_CTRL_LANE0 => E10GBASEKR_PMA_CTRL_LANE0_STRING,
        E10GBASEKR_PMA_CTRL_LANE1 => E10GBASEKR_PMA_CTRL_LANE1_STRING,
        E10GBASEKR_PMA_CTRL_LANE2 => E10GBASEKR_PMA_CTRL_LANE2_STRING,
        E10GBASEKR_PMA_CTRL_LANE3 => E10GBASEKR_PMA_CTRL_LANE3_STRING,
        E10GBASEKX_CTRL_LANE0 => E10GBASEKX_CTRL_LANE0_STRING,
        E10GBASEKX_CTRL_LANE1 => E10GBASEKX_CTRL_LANE1_STRING,
        E10GBASEKX_CTRL_LANE2 => E10GBASEKX_CTRL_LANE2_STRING,
        E10GBASEKX_CTRL_LANE3 => E10GBASEKX_CTRL_LANE3_STRING,
        E10GBASER_PCS_CFG_LANE0 => E10GBASER_PCS_CFG_LANE0_STRING,
        E10GBASER_PCS_CFG_LANE1 => E10GBASER_PCS_CFG_LANE1_STRING,
        E10GBASER_PCS_CFG_LANE2 => E10GBASER_PCS_CFG_LANE2_STRING,
        E10GBASER_PCS_CFG_LANE3 => E10GBASER_PCS_CFG_LANE3_STRING,
        E10GBASER_PCS_SEEDA0_LANE0 => E10GBASER_PCS_SEEDA0_LANE0_STRING,
        E10GBASER_PCS_SEEDA0_LANE1 => E10GBASER_PCS_SEEDA0_LANE1_STRING,
        E10GBASER_PCS_SEEDA0_LANE2 => E10GBASER_PCS_SEEDA0_LANE2_STRING,
        E10GBASER_PCS_SEEDA0_LANE3 => E10GBASER_PCS_SEEDA0_LANE3_STRING,
        E10GBASER_PCS_SEEDA1_LANE0 => E10GBASER_PCS_SEEDA1_LANE0_STRING,
        E10GBASER_PCS_SEEDA1_LANE1 => E10GBASER_PCS_SEEDA1_LANE1_STRING,
        E10GBASER_PCS_SEEDA1_LANE2 => E10GBASER_PCS_SEEDA1_LANE2_STRING,
        E10GBASER_PCS_SEEDA1_LANE3 => E10GBASER_PCS_SEEDA1_LANE3_STRING,
        E10GBASER_PCS_SEEDA2_LANE0 => E10GBASER_PCS_SEEDA2_LANE0_STRING,
        E10GBASER_PCS_SEEDA2_LANE1 => E10GBASER_PCS_SEEDA2_LANE1_STRING,
        E10GBASER_PCS_SEEDA2_LANE2 => E10GBASER_PCS_SEEDA2_LANE2_STRING,
        E10GBASER_PCS_SEEDA2_LANE3 => E10GBASER_PCS_SEEDA2_LANE3_STRING,
        E10GBASER_PCS_SEEDA3_LANE0 => E10GBASER_PCS_SEEDA3_LANE0_STRING,
        E10GBASER_PCS_SEEDA3_LANE1 => E10GBASER_PCS_SEEDA3_LANE1_STRING,
        E10GBASER_PCS_SEEDA3_LANE2 => E10GBASER_PCS_SEEDA3_LANE2_STRING,
        E10GBASER_PCS_SEEDA3_LANE3 => E10GBASER_PCS_SEEDA3_LANE3_STRING,
        E10GBASER_PCS_SEEDB0_LANE0 => E10GBASER_PCS_SEEDB0_LANE0_STRING,
        E10GBASER_PCS_SEEDB0_LANE1 => E10GBASER_PCS_SEEDB0_LANE1_STRING,
        E10GBASER_PCS_SEEDB0_LANE2 => E10GBASER_PCS_SEEDB0_LANE2_STRING,
        E10GBASER_PCS_SEEDB0_LANE3 => E10GBASER_PCS_SEEDB0_LANE3_STRING,
        E10GBASER_PCS_SEEDB1_LANE0 => E10GBASER_PCS_SEEDB1_LANE0_STRING,
        E10GBASER_PCS_SEEDB1_LANE1 => E10GBASER_PCS_SEEDB1_LANE1_STRING,
        E10GBASER_PCS_SEEDB1_LANE2 => E10GBASER_PCS_SEEDB1_LANE2_STRING,
        E10GBASER_PCS_SEEDB1_LANE3 => E10GBASER_PCS_SEEDB1_LANE3_STRING,
        E10GBASER_PCS_SEEDB2_LANE0 => E10GBASER_PCS_SEEDB2_LANE0_STRING,
        E10GBASER_PCS_SEEDB2_LANE1 => E10GBASER_PCS_SEEDB2_LANE1_STRING,
        E10GBASER_PCS_SEEDB2_LANE2 => E10GBASER_PCS_SEEDB2_LANE2_STRING,
        E10GBASER_PCS_SEEDB2_LANE3 => E10GBASER_PCS_SEEDB2_LANE3_STRING,
        E10GBASER_PCS_SEEDB3_LANE0 => E10GBASER_PCS_SEEDB3_LANE0_STRING,
        E10GBASER_PCS_SEEDB3_LANE1 => E10GBASER_PCS_SEEDB3_LANE1_STRING,
        E10GBASER_PCS_SEEDB3_LANE2 => E10GBASER_PCS_SEEDB3_LANE2_STRING,
        E10GBASER_PCS_SEEDB3_LANE3 => E10GBASER_PCS_SEEDB3_LANE3_STRING,
        E10GBASER_PCS_TEST_CTRL_LANE0 => E10GBASER_PCS_TEST_CTRL_LANE0_STRING,
        E10GBASER_PCS_TEST_CTRL_LANE1 => E10GBASER_PCS_TEST_CTRL_LANE1_STRING,
        E10GBASER_PCS_TEST_CTRL_LANE2 => E10GBASER_PCS_TEST_CTRL_LANE2_STRING,
        E10GBASER_PCS_TEST_CTRL_LANE3 => E10GBASER_PCS_TEST_CTRL_LANE3_STRING,
        E10GBASEX_PCS_TSTCTRL_LANE0 => E10GBASEX_PCS_TSTCTRL_LANE0_STRING,
        E10GBASEX_PCS_TSTCTRL_LANE1 => E10GBASEX_PCS_TSTCTRL_LANE1_STRING,
        E10GBASEX_PCS_TSTCTRL_LANE2 => E10GBASEX_PCS_TSTCTRL_LANE2_STRING,
        E10GBASEX_PCS_TSTCTRL_LANE3 => E10GBASEX_PCS_TSTCTRL_LANE3_STRING,
        GLBL0_NOISE_CTRL     => GLBL0_NOISE_CTRL_STRING,
        GLBL_AMON_SEL        => GLBL_AMON_SEL_STRING,
        GLBL_DMON_SEL        => GLBL_DMON_SEL_STRING,
        GLBL_PWR_CTRL        => GLBL_PWR_CTRL_STRING,
        GTH_CFG_PWRUP_LANE0  => GTH_CFG_PWRUP_LANE0_STRING,
        GTH_CFG_PWRUP_LANE1  => GTH_CFG_PWRUP_LANE1_STRING,
        GTH_CFG_PWRUP_LANE2  => GTH_CFG_PWRUP_LANE2_STRING,
        GTH_CFG_PWRUP_LANE3  => GTH_CFG_PWRUP_LANE3_STRING,
        LANE_AMON_SEL        => LANE_AMON_SEL_STRING,
        LANE_DMON_SEL        => LANE_DMON_SEL_STRING,
        LANE_LNK_CFGOVRD     => LANE_LNK_CFGOVRD_STRING,
        LANE_PWR_CTRL_LANE0  => LANE_PWR_CTRL_LANE0_STRING,
        LANE_PWR_CTRL_LANE1  => LANE_PWR_CTRL_LANE1_STRING,
        LANE_PWR_CTRL_LANE2  => LANE_PWR_CTRL_LANE2_STRING,
        LANE_PWR_CTRL_LANE3  => LANE_PWR_CTRL_LANE3_STRING,
        LNK_TRN_CFG_LANE0    => LNK_TRN_CFG_LANE0_STRING,
        LNK_TRN_CFG_LANE1    => LNK_TRN_CFG_LANE1_STRING,
        LNK_TRN_CFG_LANE2    => LNK_TRN_CFG_LANE2_STRING,
        LNK_TRN_CFG_LANE3    => LNK_TRN_CFG_LANE3_STRING,
        LNK_TRN_COEFF_REQ_LANE0 => LNK_TRN_COEFF_REQ_LANE0_STRING,
        LNK_TRN_COEFF_REQ_LANE1 => LNK_TRN_COEFF_REQ_LANE1_STRING,
        LNK_TRN_COEFF_REQ_LANE2 => LNK_TRN_COEFF_REQ_LANE2_STRING,
        LNK_TRN_COEFF_REQ_LANE3 => LNK_TRN_COEFF_REQ_LANE3_STRING,
        MISC_CFG             => MISC_CFG_STRING,
        MODE_CFG1            => MODE_CFG1_STRING,
        MODE_CFG2            => MODE_CFG2_STRING,
        MODE_CFG3            => MODE_CFG3_STRING,
        MODE_CFG4            => MODE_CFG4_STRING,
        MODE_CFG5            => MODE_CFG5_STRING,
        MODE_CFG6            => MODE_CFG6_STRING,
        MODE_CFG7            => MODE_CFG7_STRING,
        PCS_ABILITY_LANE0    => PCS_ABILITY_LANE0_STRING,
        PCS_ABILITY_LANE1    => PCS_ABILITY_LANE1_STRING,
        PCS_ABILITY_LANE2    => PCS_ABILITY_LANE2_STRING,
        PCS_ABILITY_LANE3    => PCS_ABILITY_LANE3_STRING,
        PCS_CTRL1_LANE0      => PCS_CTRL1_LANE0_STRING,
        PCS_CTRL1_LANE1      => PCS_CTRL1_LANE1_STRING,
        PCS_CTRL1_LANE2      => PCS_CTRL1_LANE2_STRING,
        PCS_CTRL1_LANE3      => PCS_CTRL1_LANE3_STRING,
        PCS_CTRL2_LANE0      => PCS_CTRL2_LANE0_STRING,
        PCS_CTRL2_LANE1      => PCS_CTRL2_LANE1_STRING,
        PCS_CTRL2_LANE2      => PCS_CTRL2_LANE2_STRING,
        PCS_CTRL2_LANE3      => PCS_CTRL2_LANE3_STRING,
        PCS_MISC_CFG_0_LANE0 => PCS_MISC_CFG_0_LANE0_STRING,
        PCS_MISC_CFG_0_LANE1 => PCS_MISC_CFG_0_LANE1_STRING,
        PCS_MISC_CFG_0_LANE2 => PCS_MISC_CFG_0_LANE2_STRING,
        PCS_MISC_CFG_0_LANE3 => PCS_MISC_CFG_0_LANE3_STRING,
        PCS_MISC_CFG_1_LANE0 => PCS_MISC_CFG_1_LANE0_STRING,
        PCS_MISC_CFG_1_LANE1 => PCS_MISC_CFG_1_LANE1_STRING,
        PCS_MISC_CFG_1_LANE2 => PCS_MISC_CFG_1_LANE2_STRING,
        PCS_MISC_CFG_1_LANE3 => PCS_MISC_CFG_1_LANE3_STRING,
        PCS_MODE_LANE0       => PCS_MODE_LANE0_STRING,
        PCS_MODE_LANE1       => PCS_MODE_LANE1_STRING,
        PCS_MODE_LANE2       => PCS_MODE_LANE2_STRING,
        PCS_MODE_LANE3       => PCS_MODE_LANE3_STRING,
        PCS_RESET_1_LANE0    => PCS_RESET_1_LANE0_STRING,
        PCS_RESET_1_LANE1    => PCS_RESET_1_LANE1_STRING,
        PCS_RESET_1_LANE2    => PCS_RESET_1_LANE2_STRING,
        PCS_RESET_1_LANE3    => PCS_RESET_1_LANE3_STRING,
        PCS_RESET_LANE0      => PCS_RESET_LANE0_STRING,
        PCS_RESET_LANE1      => PCS_RESET_LANE1_STRING,
        PCS_RESET_LANE2      => PCS_RESET_LANE2_STRING,
        PCS_RESET_LANE3      => PCS_RESET_LANE3_STRING,
        PCS_TYPE_LANE0       => PCS_TYPE_LANE0_STRING,
        PCS_TYPE_LANE1       => PCS_TYPE_LANE1_STRING,
        PCS_TYPE_LANE2       => PCS_TYPE_LANE2_STRING,
        PCS_TYPE_LANE3       => PCS_TYPE_LANE3_STRING,
        PLL_CFG0             => PLL_CFG0_STRING,
        PLL_CFG1             => PLL_CFG1_STRING,
        PLL_CFG2             => PLL_CFG2_STRING,
        PMA_CTRL1_LANE0      => PMA_CTRL1_LANE0_STRING,
        PMA_CTRL1_LANE1      => PMA_CTRL1_LANE1_STRING,
        PMA_CTRL1_LANE2      => PMA_CTRL1_LANE2_STRING,
        PMA_CTRL1_LANE3      => PMA_CTRL1_LANE3_STRING,
        PMA_CTRL2_LANE0      => PMA_CTRL2_LANE0_STRING,
        PMA_CTRL2_LANE1      => PMA_CTRL2_LANE1_STRING,
        PMA_CTRL2_LANE2      => PMA_CTRL2_LANE2_STRING,
        PMA_CTRL2_LANE3      => PMA_CTRL2_LANE3_STRING,
        PMA_LPBK_CTRL_LANE0  => PMA_LPBK_CTRL_LANE0_STRING,
        PMA_LPBK_CTRL_LANE1  => PMA_LPBK_CTRL_LANE1_STRING,
        PMA_LPBK_CTRL_LANE2  => PMA_LPBK_CTRL_LANE2_STRING,
        PMA_LPBK_CTRL_LANE3  => PMA_LPBK_CTRL_LANE3_STRING,
        PRBS_BER_CFG0_LANE0  => PRBS_BER_CFG0_LANE0_STRING,
        PRBS_BER_CFG0_LANE1  => PRBS_BER_CFG0_LANE1_STRING,
        PRBS_BER_CFG0_LANE2  => PRBS_BER_CFG0_LANE2_STRING,
        PRBS_BER_CFG0_LANE3  => PRBS_BER_CFG0_LANE3_STRING,
        PRBS_BER_CFG1_LANE0  => PRBS_BER_CFG1_LANE0_STRING,
        PRBS_BER_CFG1_LANE1  => PRBS_BER_CFG1_LANE1_STRING,
        PRBS_BER_CFG1_LANE2  => PRBS_BER_CFG1_LANE2_STRING,
        PRBS_BER_CFG1_LANE3  => PRBS_BER_CFG1_LANE3_STRING,
        PRBS_CFG_LANE0       => PRBS_CFG_LANE0_STRING,
        PRBS_CFG_LANE1       => PRBS_CFG_LANE1_STRING,
        PRBS_CFG_LANE2       => PRBS_CFG_LANE2_STRING,
        PRBS_CFG_LANE3       => PRBS_CFG_LANE3_STRING,
        PTRN_CFG0_LSB        => PTRN_CFG0_LSB_STRING,
        PTRN_CFG0_MSB        => PTRN_CFG0_MSB_STRING,
        PTRN_LEN_CFG         => PTRN_LEN_CFG_STRING,
        PWRUP_DLY            => PWRUP_DLY_STRING,
        RX_AEQ_VAL0_LANE0    => RX_AEQ_VAL0_LANE0_STRING,
        RX_AEQ_VAL0_LANE1    => RX_AEQ_VAL0_LANE1_STRING,
        RX_AEQ_VAL0_LANE2    => RX_AEQ_VAL0_LANE2_STRING,
        RX_AEQ_VAL0_LANE3    => RX_AEQ_VAL0_LANE3_STRING,
        RX_AEQ_VAL1_LANE0    => RX_AEQ_VAL1_LANE0_STRING,
        RX_AEQ_VAL1_LANE1    => RX_AEQ_VAL1_LANE1_STRING,
        RX_AEQ_VAL1_LANE2    => RX_AEQ_VAL1_LANE2_STRING,
        RX_AEQ_VAL1_LANE3    => RX_AEQ_VAL1_LANE3_STRING,
        RX_AGC_CTRL_LANE0    => RX_AGC_CTRL_LANE0_STRING,
        RX_AGC_CTRL_LANE1    => RX_AGC_CTRL_LANE1_STRING,
        RX_AGC_CTRL_LANE2    => RX_AGC_CTRL_LANE2_STRING,
        RX_AGC_CTRL_LANE3    => RX_AGC_CTRL_LANE3_STRING,
        RX_CDR_CTRL0_LANE0   => RX_CDR_CTRL0_LANE0_STRING,
        RX_CDR_CTRL0_LANE1   => RX_CDR_CTRL0_LANE1_STRING,
        RX_CDR_CTRL0_LANE2   => RX_CDR_CTRL0_LANE2_STRING,
        RX_CDR_CTRL0_LANE3   => RX_CDR_CTRL0_LANE3_STRING,
        RX_CDR_CTRL1_LANE0   => RX_CDR_CTRL1_LANE0_STRING,
        RX_CDR_CTRL1_LANE1   => RX_CDR_CTRL1_LANE1_STRING,
        RX_CDR_CTRL1_LANE2   => RX_CDR_CTRL1_LANE2_STRING,
        RX_CDR_CTRL1_LANE3   => RX_CDR_CTRL1_LANE3_STRING,
        RX_CDR_CTRL2_LANE0   => RX_CDR_CTRL2_LANE0_STRING,
        RX_CDR_CTRL2_LANE1   => RX_CDR_CTRL2_LANE1_STRING,
        RX_CDR_CTRL2_LANE2   => RX_CDR_CTRL2_LANE2_STRING,
        RX_CDR_CTRL2_LANE3   => RX_CDR_CTRL2_LANE3_STRING,
        RX_CFG0_LANE0        => RX_CFG0_LANE0_STRING,
        RX_CFG0_LANE1        => RX_CFG0_LANE1_STRING,
        RX_CFG0_LANE2        => RX_CFG0_LANE2_STRING,
        RX_CFG0_LANE3        => RX_CFG0_LANE3_STRING,
        RX_CFG1_LANE0        => RX_CFG1_LANE0_STRING,
        RX_CFG1_LANE1        => RX_CFG1_LANE1_STRING,
        RX_CFG1_LANE2        => RX_CFG1_LANE2_STRING,
        RX_CFG1_LANE3        => RX_CFG1_LANE3_STRING,
        RX_CFG2_LANE0        => RX_CFG2_LANE0_STRING,
        RX_CFG2_LANE1        => RX_CFG2_LANE1_STRING,
        RX_CFG2_LANE2        => RX_CFG2_LANE2_STRING,
        RX_CFG2_LANE3        => RX_CFG2_LANE3_STRING,
        RX_CTLE_CTRL_LANE0   => RX_CTLE_CTRL_LANE0_STRING,
        RX_CTLE_CTRL_LANE1   => RX_CTLE_CTRL_LANE1_STRING,
        RX_CTLE_CTRL_LANE2   => RX_CTLE_CTRL_LANE2_STRING,
        RX_CTLE_CTRL_LANE3   => RX_CTLE_CTRL_LANE3_STRING,
        RX_CTRL_OVRD_LANE0   => RX_CTRL_OVRD_LANE0_STRING,
        RX_CTRL_OVRD_LANE1   => RX_CTRL_OVRD_LANE1_STRING,
        RX_CTRL_OVRD_LANE2   => RX_CTRL_OVRD_LANE2_STRING,
        RX_CTRL_OVRD_LANE3   => RX_CTRL_OVRD_LANE3_STRING,
        RX_FABRIC_WIDTH0     => RX_FABRIC_WIDTH0,
        RX_FABRIC_WIDTH1     => RX_FABRIC_WIDTH1,
        RX_FABRIC_WIDTH2     => RX_FABRIC_WIDTH2,
        RX_FABRIC_WIDTH3     => RX_FABRIC_WIDTH3,
        RX_LOOP_CTRL_LANE0   => RX_LOOP_CTRL_LANE0_STRING,
        RX_LOOP_CTRL_LANE1   => RX_LOOP_CTRL_LANE1_STRING,
        RX_LOOP_CTRL_LANE2   => RX_LOOP_CTRL_LANE2_STRING,
        RX_LOOP_CTRL_LANE3   => RX_LOOP_CTRL_LANE3_STRING,
        RX_MVAL0_LANE0       => RX_MVAL0_LANE0_STRING,
        RX_MVAL0_LANE1       => RX_MVAL0_LANE1_STRING,
        RX_MVAL0_LANE2       => RX_MVAL0_LANE2_STRING,
        RX_MVAL0_LANE3       => RX_MVAL0_LANE3_STRING,
        RX_MVAL1_LANE0       => RX_MVAL1_LANE0_STRING,
        RX_MVAL1_LANE1       => RX_MVAL1_LANE1_STRING,
        RX_MVAL1_LANE2       => RX_MVAL1_LANE2_STRING,
        RX_MVAL1_LANE3       => RX_MVAL1_LANE3_STRING,
        RX_P0S_CTRL          => RX_P0S_CTRL_STRING,
        RX_P0_CTRL           => RX_P0_CTRL_STRING,
        RX_P1_CTRL           => RX_P1_CTRL_STRING,
        RX_P2_CTRL           => RX_P2_CTRL_STRING,
        RX_PI_CTRL0          => RX_PI_CTRL0_STRING,
        RX_PI_CTRL1          => RX_PI_CTRL1_STRING,
        SIM_GTHRESET_SPEEDUP => SIM_GTHRESET_SPEEDUP,
        SIM_VERSION          => SIM_VERSION,
        SLICE_CFG            => SLICE_CFG_STRING,
        SLICE_NOISE_CTRL_0_LANE01 => SLICE_NOISE_CTRL_0_LANE01_STRING,
        SLICE_NOISE_CTRL_0_LANE23 => SLICE_NOISE_CTRL_0_LANE23_STRING,
        SLICE_NOISE_CTRL_1_LANE01 => SLICE_NOISE_CTRL_1_LANE01_STRING,
        SLICE_NOISE_CTRL_1_LANE23 => SLICE_NOISE_CTRL_1_LANE23_STRING,
        SLICE_NOISE_CTRL_2_LANE01 => SLICE_NOISE_CTRL_2_LANE01_STRING,
        SLICE_NOISE_CTRL_2_LANE23 => SLICE_NOISE_CTRL_2_LANE23_STRING,
        SLICE_TX_RESET_LANE01 => SLICE_TX_RESET_LANE01_STRING,
        SLICE_TX_RESET_LANE23 => SLICE_TX_RESET_LANE23_STRING,
        TERM_CTRL_LANE0      => TERM_CTRL_LANE0_STRING,
        TERM_CTRL_LANE1      => TERM_CTRL_LANE1_STRING,
        TERM_CTRL_LANE2      => TERM_CTRL_LANE2_STRING,
        TERM_CTRL_LANE3      => TERM_CTRL_LANE3_STRING,
        TX_CFG0_LANE0        => TX_CFG0_LANE0_STRING,
        TX_CFG0_LANE1        => TX_CFG0_LANE1_STRING,
        TX_CFG0_LANE2        => TX_CFG0_LANE2_STRING,
        TX_CFG0_LANE3        => TX_CFG0_LANE3_STRING,
        TX_CFG1_LANE0        => TX_CFG1_LANE0_STRING,
        TX_CFG1_LANE1        => TX_CFG1_LANE1_STRING,
        TX_CFG1_LANE2        => TX_CFG1_LANE2_STRING,
        TX_CFG1_LANE3        => TX_CFG1_LANE3_STRING,
        TX_CFG2_LANE0        => TX_CFG2_LANE0_STRING,
        TX_CFG2_LANE1        => TX_CFG2_LANE1_STRING,
        TX_CFG2_LANE2        => TX_CFG2_LANE2_STRING,
        TX_CFG2_LANE3        => TX_CFG2_LANE3_STRING,
        TX_CLK_SEL0_LANE0    => TX_CLK_SEL0_LANE0_STRING,
        TX_CLK_SEL0_LANE1    => TX_CLK_SEL0_LANE1_STRING,
        TX_CLK_SEL0_LANE2    => TX_CLK_SEL0_LANE2_STRING,
        TX_CLK_SEL0_LANE3    => TX_CLK_SEL0_LANE3_STRING,
        TX_CLK_SEL1_LANE0    => TX_CLK_SEL1_LANE0_STRING,
        TX_CLK_SEL1_LANE1    => TX_CLK_SEL1_LANE1_STRING,
        TX_CLK_SEL1_LANE2    => TX_CLK_SEL1_LANE2_STRING,
        TX_CLK_SEL1_LANE3    => TX_CLK_SEL1_LANE3_STRING,
        TX_DISABLE_LANE0     => TX_DISABLE_LANE0_STRING,
        TX_DISABLE_LANE1     => TX_DISABLE_LANE1_STRING,
        TX_DISABLE_LANE2     => TX_DISABLE_LANE2_STRING,
        TX_DISABLE_LANE3     => TX_DISABLE_LANE3_STRING,
        TX_FABRIC_WIDTH0     => TX_FABRIC_WIDTH0,
        TX_FABRIC_WIDTH1     => TX_FABRIC_WIDTH1,
        TX_FABRIC_WIDTH2     => TX_FABRIC_WIDTH2,
        TX_FABRIC_WIDTH3     => TX_FABRIC_WIDTH3,
        TX_P0P0S_CTRL        => TX_P0P0S_CTRL_STRING,
        TX_P1P2_CTRL         => TX_P1P2_CTRL_STRING,
        TX_PREEMPH_LANE0     => TX_PREEMPH_LANE0_STRING,
        TX_PREEMPH_LANE1     => TX_PREEMPH_LANE1_STRING,
        TX_PREEMPH_LANE2     => TX_PREEMPH_LANE2_STRING,
        TX_PREEMPH_LANE3     => TX_PREEMPH_LANE3_STRING,
        TX_PWR_RATE_OVRD_LANE0 => TX_PWR_RATE_OVRD_LANE0_STRING,
        TX_PWR_RATE_OVRD_LANE1 => TX_PWR_RATE_OVRD_LANE1_STRING,
        TX_PWR_RATE_OVRD_LANE2 => TX_PWR_RATE_OVRD_LANE2_STRING,
        TX_PWR_RATE_OVRD_LANE3 => TX_PWR_RATE_OVRD_LANE3_STRING
      )
      
      port map (
        GSR                  => GSR,
        DRDY                 => DRDY_outdelay,
        DRPDO                => DRPDO_outdelay,
        GTHINITDONE          => GTHINITDONE_outdelay,
        MGMTPCSRDACK         => MGMTPCSRDACK_outdelay,
        MGMTPCSRDDATA        => MGMTPCSRDDATA_outdelay,
        RXCODEERR0           => RXCODEERR0_outdelay,
        RXCODEERR1           => RXCODEERR1_outdelay,
        RXCODEERR2           => RXCODEERR2_outdelay,
        RXCODEERR3           => RXCODEERR3_outdelay,
        RXCTRL0              => RXCTRL0_outdelay,
        RXCTRL1              => RXCTRL1_outdelay,
        RXCTRL2              => RXCTRL2_outdelay,
        RXCTRL3              => RXCTRL3_outdelay,
        RXCTRLACK0           => RXCTRLACK0_outdelay,
        RXCTRLACK1           => RXCTRLACK1_outdelay,
        RXCTRLACK2           => RXCTRLACK2_outdelay,
        RXCTRLACK3           => RXCTRLACK3_outdelay,
        RXDATA0              => RXDATA0_outdelay,
        RXDATA1              => RXDATA1_outdelay,
        RXDATA2              => RXDATA2_outdelay,
        RXDATA3              => RXDATA3_outdelay,
        RXDATATAP0           => RXDATATAP0_outdelay,
        RXDATATAP1           => RXDATATAP1_outdelay,
        RXDATATAP2           => RXDATATAP2_outdelay,
        RXDATATAP3           => RXDATATAP3_outdelay,
        RXDISPERR0           => RXDISPERR0_outdelay,
        RXDISPERR1           => RXDISPERR1_outdelay,
        RXDISPERR2           => RXDISPERR2_outdelay,
        RXDISPERR3           => RXDISPERR3_outdelay,
        RXPCSCLKSMPL0        => RXPCSCLKSMPL0_outdelay,
        RXPCSCLKSMPL1        => RXPCSCLKSMPL1_outdelay,
        RXPCSCLKSMPL2        => RXPCSCLKSMPL2_outdelay,
        RXPCSCLKSMPL3        => RXPCSCLKSMPL3_outdelay,
        RXUSERCLKOUT0        => RXUSERCLKOUT0_outdelay,
        RXUSERCLKOUT1        => RXUSERCLKOUT1_outdelay,
        RXUSERCLKOUT2        => RXUSERCLKOUT2_outdelay,
        RXUSERCLKOUT3        => RXUSERCLKOUT3_outdelay,
        RXVALID0             => RXVALID0_outdelay,
        RXVALID1             => RXVALID1_outdelay,
        RXVALID2             => RXVALID2_outdelay,
        RXVALID3             => RXVALID3_outdelay,
        TSTPATH              => TSTPATH_outdelay,
        TSTREFCLKFAB         => TSTREFCLKFAB_outdelay,
        TSTREFCLKOUT         => TSTREFCLKOUT_outdelay,
        TXCTRLACK0           => TXCTRLACK0_outdelay,
        TXCTRLACK1           => TXCTRLACK1_outdelay,
        TXCTRLACK2           => TXCTRLACK2_outdelay,
        TXCTRLACK3           => TXCTRLACK3_outdelay,
        TXDATATAP10          => TXDATATAP10_outdelay,
        TXDATATAP11          => TXDATATAP11_outdelay,
        TXDATATAP12          => TXDATATAP12_outdelay,
        TXDATATAP13          => TXDATATAP13_outdelay,
        TXDATATAP20          => TXDATATAP20_outdelay,
        TXDATATAP21          => TXDATATAP21_outdelay,
        TXDATATAP22          => TXDATATAP22_outdelay,
        TXDATATAP23          => TXDATATAP23_outdelay,
        TXN0                 => TXN0_outdelay,
        TXN1                 => TXN1_outdelay,
        TXN2                 => TXN2_outdelay,
        TXN3                 => TXN3_outdelay,
        TXP0                 => TXP0_outdelay,
        TXP1                 => TXP1_outdelay,
        TXP2                 => TXP2_outdelay,
        TXP3                 => TXP3_outdelay,
        TXPCSCLKSMPL0        => TXPCSCLKSMPL0_outdelay,
        TXPCSCLKSMPL1        => TXPCSCLKSMPL1_outdelay,
        TXPCSCLKSMPL2        => TXPCSCLKSMPL2_outdelay,
        TXPCSCLKSMPL3        => TXPCSCLKSMPL3_outdelay,
        TXUSERCLKOUT0        => TXUSERCLKOUT0_outdelay,
        TXUSERCLKOUT1        => TXUSERCLKOUT1_outdelay,
        TXUSERCLKOUT2        => TXUSERCLKOUT2_outdelay,
        TXUSERCLKOUT3        => TXUSERCLKOUT3_outdelay,
        DADDR                => DADDR_indelay,
        DCLK                 => DCLK_indelay,
        DEN                  => DEN_indelay,
        DFETRAINCTRL0        => DFETRAINCTRL0_indelay,
        DFETRAINCTRL1        => DFETRAINCTRL1_indelay,
        DFETRAINCTRL2        => DFETRAINCTRL2_indelay,
        DFETRAINCTRL3        => DFETRAINCTRL3_indelay,
        DI                   => DI_indelay,
        DISABLEDRP           => DISABLEDRP_indelay,
        DWE                  => DWE_indelay,
        GTHINIT              => GTHINIT_indelay,
        GTHRESET             => GTHRESET_indelay,
        GTHX2LANE01          => GTHX2LANE01_indelay,
        GTHX2LANE23          => GTHX2LANE23_indelay,
        GTHX4LANE            => GTHX4LANE_indelay,
        MGMTPCSLANESEL       => MGMTPCSLANESEL_indelay,
        MGMTPCSMMDADDR       => MGMTPCSMMDADDR_indelay,
        MGMTPCSREGADDR       => MGMTPCSREGADDR_indelay,
        MGMTPCSREGRD         => MGMTPCSREGRD_indelay,
        MGMTPCSREGWR         => MGMTPCSREGWR_indelay,
        MGMTPCSWRDATA        => MGMTPCSWRDATA_indelay,
        PLLPCSCLKDIV         => PLLPCSCLKDIV_indelay,
        PLLREFCLKSEL         => PLLREFCLKSEL_indelay,
        POWERDOWN0           => POWERDOWN0_indelay,
        POWERDOWN1           => POWERDOWN1_indelay,
        POWERDOWN2           => POWERDOWN2_indelay,
        POWERDOWN3           => POWERDOWN3_indelay,
        REFCLK               => REFCLK_indelay,
        RXBUFRESET0          => RXBUFRESET0_indelay,
        RXBUFRESET1          => RXBUFRESET1_indelay,
        RXBUFRESET2          => RXBUFRESET2_indelay,
        RXBUFRESET3          => RXBUFRESET3_indelay,
        RXENCOMMADET0        => RXENCOMMADET0_indelay,
        RXENCOMMADET1        => RXENCOMMADET1_indelay,
        RXENCOMMADET2        => RXENCOMMADET2_indelay,
        RXENCOMMADET3        => RXENCOMMADET3_indelay,
        RXN0                 => RXN0_indelay,
        RXN1                 => RXN1_indelay,
        RXN2                 => RXN2_indelay,
        RXN3                 => RXN3_indelay,
        RXP0                 => RXP0_indelay,
        RXP1                 => RXP1_indelay,
        RXP2                 => RXP2_indelay,
        RXP3                 => RXP3_indelay,
        RXPOLARITY0          => RXPOLARITY0_indelay,
        RXPOLARITY1          => RXPOLARITY1_indelay,
        RXPOLARITY2          => RXPOLARITY2_indelay,
        RXPOLARITY3          => RXPOLARITY3_indelay,
        RXPOWERDOWN0         => RXPOWERDOWN0_indelay,
        RXPOWERDOWN1         => RXPOWERDOWN1_indelay,
        RXPOWERDOWN2         => RXPOWERDOWN2_indelay,
        RXPOWERDOWN3         => RXPOWERDOWN3_indelay,
        RXRATE0              => RXRATE0_indelay,
        RXRATE1              => RXRATE1_indelay,
        RXRATE2              => RXRATE2_indelay,
        RXRATE3              => RXRATE3_indelay,
        RXSLIP0              => RXSLIP0_indelay,
        RXSLIP1              => RXSLIP1_indelay,
        RXSLIP2              => RXSLIP2_indelay,
        RXSLIP3              => RXSLIP3_indelay,
        RXUSERCLKIN0         => RXUSERCLKIN0_indelay,
        RXUSERCLKIN1         => RXUSERCLKIN1_indelay,
        RXUSERCLKIN2         => RXUSERCLKIN2_indelay,
        RXUSERCLKIN3         => RXUSERCLKIN3_indelay,
        SAMPLERATE0          => SAMPLERATE0_indelay,
        SAMPLERATE1          => SAMPLERATE1_indelay,
        SAMPLERATE2          => SAMPLERATE2_indelay,
        SAMPLERATE3          => SAMPLERATE3_indelay,
        TXBUFRESET0          => TXBUFRESET0_indelay,
        TXBUFRESET1          => TXBUFRESET1_indelay,
        TXBUFRESET2          => TXBUFRESET2_indelay,
        TXBUFRESET3          => TXBUFRESET3_indelay,
        TXCTRL0              => TXCTRL0_indelay,
        TXCTRL1              => TXCTRL1_indelay,
        TXCTRL2              => TXCTRL2_indelay,
        TXCTRL3              => TXCTRL3_indelay,
        TXDATA0              => TXDATA0_indelay,
        TXDATA1              => TXDATA1_indelay,
        TXDATA2              => TXDATA2_indelay,
        TXDATA3              => TXDATA3_indelay,
        TXDATAMSB0           => TXDATAMSB0_indelay,
        TXDATAMSB1           => TXDATAMSB1_indelay,
        TXDATAMSB2           => TXDATAMSB2_indelay,
        TXDATAMSB3           => TXDATAMSB3_indelay,
        TXDEEMPH0            => TXDEEMPH0_indelay,
        TXDEEMPH1            => TXDEEMPH1_indelay,
        TXDEEMPH2            => TXDEEMPH2_indelay,
        TXDEEMPH3            => TXDEEMPH3_indelay,
        TXMARGIN0            => TXMARGIN0_indelay,
        TXMARGIN1            => TXMARGIN1_indelay,
        TXMARGIN2            => TXMARGIN2_indelay,
        TXMARGIN3            => TXMARGIN3_indelay,
        TXPOWERDOWN0         => TXPOWERDOWN0_indelay,
        TXPOWERDOWN1         => TXPOWERDOWN1_indelay,
        TXPOWERDOWN2         => TXPOWERDOWN2_indelay,
        TXPOWERDOWN3         => TXPOWERDOWN3_indelay,
        TXRATE0              => TXRATE0_indelay,
        TXRATE1              => TXRATE1_indelay,
        TXRATE2              => TXRATE2_indelay,
        TXRATE3              => TXRATE3_indelay,
        TXUSERCLKIN0         => TXUSERCLKIN0_indelay,
        TXUSERCLKIN1         => TXUSERCLKIN1_indelay,
        TXUSERCLKIN2         => TXUSERCLKIN2_indelay,
        TXUSERCLKIN3         => TXUSERCLKIN3_indelay        
      );
    
    DRCPROC :  process(PLLPCSCLKDIV)
    begin

    -- Start DRC Checks
    -- DRC Checks SET 1 - DRC Error for PLLPCSCLKDIV = 6'b32
        
      if ((PLLPCSCLKDIV = "100000") and (not(PCS_MODE_LANE0_74 = "0001" and RX_FABRIC_WIDTH0 = 6466) or (PCS_MODE_LANE0_74 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE0(7 downto 4)=0001, RX_FABRIC_WIDTH0=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;
            
      if ((PLLPCSCLKDIV = "100000")  and (not(PCS_MODE_LANE0_30 = "0001" and TX_FABRIC_WIDTH0 = 6466) or (PCS_MODE_LANE0_30 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE0(3 downto 0)=0001, TX_FABRIC_WIDTH0=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;

      if ((PLLPCSCLKDIV = "100000") and (not(PCS_MODE_LANE1_74 = "0001" and RX_FABRIC_WIDTH1 = 6466) or (PCS_MODE_LANE1_74 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE1(7 downto 4)=0001, RX_FABRIC_WIDTH1=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;
                                                                                                                  
      if ((PLLPCSCLKDIV = "100000") and (not(PCS_MODE_LANE1_30 = "0001" and TX_FABRIC_WIDTH1 = 6466) or (PCS_MODE_LANE1_30 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE1(3 downto 0)=0001, TX_FABRIC_WIDTH1=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;
                                                                                                                                            
      if ((PLLPCSCLKDIV = "100000") and (not(PCS_MODE_LANE2_74 = "0001" and RX_FABRIC_WIDTH2 = 6466) or (PCS_MODE_LANE2_74 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE2(7 downto 4)=0001, RX_FABRIC_WIDTH2=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;

      if ((PLLPCSCLKDIV = "100000") and (not(PCS_MODE_LANE2_30 = "0001" and TX_FABRIC_WIDTH2 = 6466) or (PCS_MODE_LANE2_30 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE2(3 downto 0)=0001, TX_FABRIC_WIDTH2=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;

      if ((PLLPCSCLKDIV = "100000") and (not(PCS_MODE_LANE3_74 = "0001" and RX_FABRIC_WIDTH3 = 6466) or (PCS_MODE_LANE3_74 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE3(7 downto 4)=0001, RX_FABRIC_WIDTH3=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;

      if ((PLLPCSCLKDIV = "100000") and (not(PCS_MODE_LANE3_30 = "0001" and TX_FABRIC_WIDTH3 = 6466) or (PCS_MODE_LANE3_30 = "1100"))) then
          assert false
          report "DRC Error: If PLLPCSCLKDIV is set to 100000 then set PCS_MODE_LANE3(3 downto 0)=0001, TX_FABRIC_WIDTH3=6466 for instance GTHE1_QUAD."
          severity failure;
      end if;
        
         -- DRC Checks SET 2 - DRC Error for PLLPCSCLKDIV = 6'b7
      
      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE0_74 = "1100") or ((PCS_MODE_LANE0_74 = "1000") and (RX_FABRIC_WIDTH0 = 8 or RX_FABRIC_WIDTH0 =16 or RX_FABRIC_WIDTH0 = 32 or RX_FABRIC_WIDTH0 = 64)) or   ((PCS_MODE_LANE0_74 = "1010") and (RX_FABRIC_WIDTH0 = 16 or RX_FABRIC_WIDTH0 = 32 or RX_FABRIC_WIDTH0 = 64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE0(7 downto 4)=1100 or 1000 and RX_FABRIC_WIDTH0 to 8,16,32,64 or (PCS_MODE_LANE0(7 downto 4)=1010 and RX_FABRIC_WIDTH0 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;
         
      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE0_30 = "1100") or ((PCS_MODE_LANE0_30 = "1000") and (TX_FABRIC_WIDTH0 = 8 or TX_FABRIC_WIDTH0 = 16 or TX_FABRIC_WIDTH0 = 32 or TX_FABRIC_WIDTH0 = 64)) or  ((PCS_MODE_LANE0_30 = "1010") and (TX_FABRIC_WIDTH0 = 16 or TX_FABRIC_WIDTH0 = 32 or TX_FABRIC_WIDTH0 = 64 )))))then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE0(3 downto 0)=1100 or 1000 and TX_FABRIC_WIDTH0 to 8,16,32,64 or (PCS_MODE_LANE0(3 downto 0)=1010 and TX_FABRIC_WIDTH0 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;
      
      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE1_74 = "1100") or((PCS_MODE_LANE1_74 = "1000") and (RX_FABRIC_WIDTH1 = 8 or RX_FABRIC_WIDTH1 = 16 or RX_FABRIC_WIDTH1 = 32 or RX_FABRIC_WIDTH1 = 64)) or   ((PCS_MODE_LANE1_74 = "1010") and (RX_FABRIC_WIDTH1 = 16 or RX_FABRIC_WIDTH1 = 32 or RX_FABRIC_WIDTH1 = 64 ))))) then
         assert false
         report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE1(7 downto 4)=1100 or 1000 and RX_FABRIC_WIDTH1 to 8,16,32,64 or (PCS_MODE_LANE1(7 downto 4)=1010 and RX_FABRIC_WIDTH1 to 16,32,64) for instance GTHE1_QUAD."
         severity failure;
      end if;

      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE1_30 = "1100") or((PCS_MODE_LANE1_30 = "1000") and (TX_FABRIC_WIDTH1 = 8 or TX_FABRIC_WIDTH1 = 16 or TX_FABRIC_WIDTH1 = 32 or TX_FABRIC_WIDTH1 =64)) or   ((PCS_MODE_LANE1_30 = "1010") and (TX_FABRIC_WIDTH1 =16 or TX_FABRIC_WIDTH1=32 or TX_FABRIC_WIDTH1 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE1(3 downto 0)=1100 or 1000 and TX_FABRIC_WIDTH1 to 8,16,32,64 or (PCS_MODE_LANE1(3 downto 0)=1010 and TX_FABRIC_WIDTH1 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;
      
      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE2_74 = "1100") or ((PCS_MODE_LANE2_74 = "1000") and (RX_FABRIC_WIDTH2 = 8 or RX_FABRIC_WIDTH2 =16 or RX_FABRIC_WIDTH2=32 or RX_FABRIC_WIDTH2 =64)) or   ((PCS_MODE_LANE2_74 = "1010") and (RX_FABRIC_WIDTH2 =16 or RX_FABRIC_WIDTH2=32 or RX_FABRIC_WIDTH2 =64 ))))) then
         assert false
         report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE2(7 downto 4)=1100 or 1000 and RX_FABRIC_WIDTH2 to 8,16,32,64 or (PCS_MODE_LANE2(7 downto 4)=1010 and RX_FABRIC_WIDTH2 to 16,32,64) for instance GTHE1_QUAD."
         severity failure;
      end if;
      
      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE2_30 = "1100") or ((PCS_MODE_LANE2_30 = "1000") and (TX_FABRIC_WIDTH2 = 8 or TX_FABRIC_WIDTH2 =16 or TX_FABRIC_WIDTH2=32 or TX_FABRIC_WIDTH2 =64)) or   ((PCS_MODE_LANE2_30 = "1010") and (TX_FABRIC_WIDTH2 =16 or TX_FABRIC_WIDTH2=32 or TX_FABRIC_WIDTH2 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE2(3 downto 0)=1100 or 1000 and TX_FABRIC_WIDTH2 to 8,16,32,64 or (PCS_MODE_LANE2(3 downto 0)=1010 and TX_FABRIC_WIDTH2 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;
         
      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE3_74 = "1100") or ((PCS_MODE_LANE3_74 = "1000") and (RX_FABRIC_WIDTH3 = 8 or RX_FABRIC_WIDTH3 =16 or RX_FABRIC_WIDTH3=32 or RX_FABRIC_WIDTH3 =64)) or   ((PCS_MODE_LANE3_74 = "1010") and (RX_FABRIC_WIDTH3 =16 or RX_FABRIC_WIDTH3=32 or RX_FABRIC_WIDTH3 =64 ))))) then
         assert false
         report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE3(7 downto 4)=1100 or 1000 and RX_FABRIC_WIDTH3 to 8,16,32,64 or (PCS_MODE_LANE3(7 downto 4)=1010 and RX_FABRIC_WIDTH3 to 16,32,64) for instance GTHE1_QUAD."
         severity failure;
      end if;
      
      if ((PLLPCSCLKDIV = "000111") and (not((PCS_MODE_LANE3_30 = "1100") or ((PCS_MODE_LANE3_30 = "1000") and (TX_FABRIC_WIDTH3 = 8 or TX_FABRIC_WIDTH3 =16 or TX_FABRIC_WIDTH3=32 or TX_FABRIC_WIDTH3 =64)) or   ((PCS_MODE_LANE3_30 = "1010") and (TX_FABRIC_WIDTH3 =16 or TX_FABRIC_WIDTH3=32 or TX_FABRIC_WIDTH3 =64 ))))) then
           assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 000111, set PCS_MODE_LANE3(3 downto 0)=1100 or 1000 and TX_FABRIC_WIDTH3 to 8,16,32,64 or (PCS_MODE_LANE3(3 downto 0)=1010 and TX_FABRIC_WIDTH3 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;

         --DRC Checks Set 3 --  DRC Error for PLLPCSCLKDIV = 6'b9
      if ((PLLPCSCLKDIV =  "001001") and (not((PCS_MODE_LANE0_74 = "1100") or ((PCS_MODE_LANE0_74 = "1011") and (RX_FABRIC_WIDTH0=20 or RX_FABRIC_WIDTH0 =40 or RX_FABRIC_WIDTH0 =80)) or ((PCS_MODE_LANE0_74 = "0111") and (RX_FABRIC_WIDTH0 =16 or RX_FABRIC_WIDTH0=32 or RX_FABRIC_WIDTH0 =64 )))))then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE0(7 downto 4)=1100 or (PCS_MODE_LANE0(7 downto 4)=1011 and RX_FABRIC_WIDTH0 to 20,40,80) or (PCS_MODE_LANE0(7 downto 4)=0111 and RX_FABRIC_WIDTH0 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
        end if;

  
      if ((PLLPCSCLKDIV =  "001001") and (not((PCS_MODE_LANE0_30 = "1100") or ((PCS_MODE_LANE0_30 = "1011") and (TX_FABRIC_WIDTH0=20 or TX_FABRIC_WIDTH0 =40 or TX_FABRIC_WIDTH0 =80)) or ((PCS_MODE_LANE0_30 = "0111") and (TX_FABRIC_WIDTH0 =16 or TX_FABRIC_WIDTH0=32 or TX_FABRIC_WIDTH0 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE0(3 downto 0)=1100 or (PCS_MODE_LANE0(3 downto 0)=1011 and TX_FABRIC_WIDTH0 to 20,40,80) or (PCS_MODE_LANE0(3 downto 0)=0111 and TX_FABRIC_WIDTH0 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;
      
      if ((PLLPCSCLKDIV =  "001001") and (not((PCS_MODE_LANE1_74 = "1100") or ((PCS_MODE_LANE1_74 = "1011") and (RX_FABRIC_WIDTH1=20 or RX_FABRIC_WIDTH1 =40 or RX_FABRIC_WIDTH1 =80)) or ((PCS_MODE_LANE1_74 = "0111") and (RX_FABRIC_WIDTH1 =16 or RX_FABRIC_WIDTH1=32 or RX_FABRIC_WIDTH1 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE1(7 downto 4)=1100 or (PCS_MODE_LANE1(7 downto 4)=1011 and RX_FABRIC_WIDTH1 to 20,40,80) or (PCS_MODE_LANE1(7 downto 4)=0111 and RX_FABRIC_WIDTH1 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
        end if;
      
      if ((PLLPCSCLKDIV = "001001") and (not((PCS_MODE_LANE1_30 = "1100") or ((PCS_MODE_LANE1_30 = "1011") and (TX_FABRIC_WIDTH1=20 or TX_FABRIC_WIDTH1 =40 or TX_FABRIC_WIDTH1 =80)) or ((PCS_MODE_LANE1_30 = "0111") and (TX_FABRIC_WIDTH1 =16 or TX_FABRIC_WIDTH1=32 or TX_FABRIC_WIDTH1 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE1(3 downto 0)=1100 or (PCS_MODE_LANE1(3 downto 0)=1011 and TX_FABRIC_WIDTH1 to 20,40,80) or (PCS_MODE_LANE1(3 downto 0)=0111 and TX_FABRIC_WIDTH1 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
        end if;
      
      if ((PLLPCSCLKDIV = "001001") and (not((PCS_MODE_LANE2_74 = "1100") or ((PCS_MODE_LANE2_74 = "1011") and (RX_FABRIC_WIDTH2=20 or RX_FABRIC_WIDTH2 =40 or RX_FABRIC_WIDTH2 =80)) or ((PCS_MODE_LANE2_74 = "0111") and (RX_FABRIC_WIDTH2 =16 or RX_FABRIC_WIDTH2=32 or RX_FABRIC_WIDTH2 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE2(7 downto 4)=1100 or (PCS_MODE_LANE2(7 downto 4)=1011 and RX_FABRIC_WIDTH2 to 20,40,80) or (PCS_MODE_LANE2(7 downto 4)=0111 and RX_FABRIC_WIDTH2 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;                                                                                                                                                                                                                                                                                                    
      if ((PLLPCSCLKDIV =  "001001") and (not((PCS_MODE_LANE2_30 = "1100") or ((PCS_MODE_LANE2_30 = "1011") and (TX_FABRIC_WIDTH2=20 or TX_FABRIC_WIDTH2 =40 or TX_FABRIC_WIDTH2 =80)) or ((PCS_MODE_LANE2_30 = "0111") and (TX_FABRIC_WIDTH2 =16 or TX_FABRIC_WIDTH2=32 or TX_FABRIC_WIDTH2 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE2(3 downto 0)=1100 or (PCS_MODE_LANE2(3 downto 0)=1011 and TX_FABRIC_WIDTH2 to 20,40,80) or (PCS_MODE_LANE2(3 downto 0)=0111 and TX_FABRIC_WIDTH2 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;
      
      if ((PLLPCSCLKDIV = "001001") and (not((PCS_MODE_LANE3_74 = "1100") or ((PCS_MODE_LANE3_74 = "1011") and (RX_FABRIC_WIDTH3=20 or RX_FABRIC_WIDTH3 =40 or RX_FABRIC_WIDTH3 =80)) or ((PCS_MODE_LANE3_74 = "0111") and (RX_FABRIC_WIDTH3 =16 or RX_FABRIC_WIDTH3=32 or RX_FABRIC_WIDTH3 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE3(7 downto 4)=1100 or (PCS_MODE_LANE3(7 downto 4)=1011 and RX_FABRIC_WIDTH3 to 20,40,80) or (PCS_MODE_LANE3(7 downto 4)=0111 and RX_FABRIC_WIDTH3 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;                                                                                                                                                                                                                                                                                                    
      if ((PLLPCSCLKDIV = "001001") and (not((PCS_MODE_LANE3_30 = "1100") or ((PCS_MODE_LANE3_30 = "1011") and (TX_FABRIC_WIDTH3=20 or TX_FABRIC_WIDTH3 =40 or TX_FABRIC_WIDTH3 =80)) or ((PCS_MODE_LANE3_30 = "0111") and (TX_FABRIC_WIDTH3 =16 or TX_FABRIC_WIDTH3=32 or TX_FABRIC_WIDTH3 =64 ))))) then
          assert false
          report "DRC Error : When PLLPCSCLKDIV is set to 001001, set PCS_MODE_LANE3(3 downto 0)=1100 or (PCS_MODE_LANE3(3 downto 0)=1011 and TX_FABRIC_WIDTH3 to 20,40,80) or (PCS_MODE_LANE3(3 downto 0)=0111 and TX_FABRIC_WIDTH3 to 16,32,64) for instance GTHE1_QUAD."
          severity failure;
      end if;
      
   end process;
   -- End DRC Checks
           
          
     INIPROC :  process 
      begin
    if ((RX_FABRIC_WIDTH0 >= 8) and (RX_FABRIC_WIDTH0 <= 6466)) then
      RX_FABRIC_WIDTH0_BINARY <= CONV_STD_LOGIC_VECTOR(RX_FABRIC_WIDTH0, 3);
    else
      assert FALSE report "Error : RX_FABRIC_WIDTH0 is not in range 8 .. 6466." severity error;
    end if;
    if ((RX_FABRIC_WIDTH1 >= 8) and (RX_FABRIC_WIDTH1 <= 6466)) then
      RX_FABRIC_WIDTH1_BINARY <= CONV_STD_LOGIC_VECTOR(RX_FABRIC_WIDTH1, 3);
    else
      assert FALSE report "Error : RX_FABRIC_WIDTH1 is not in range 8 .. 6466." severity error;
    end if;
    if ((RX_FABRIC_WIDTH2 >= 8) and (RX_FABRIC_WIDTH2 <= 6466)) then
      RX_FABRIC_WIDTH2_BINARY <= CONV_STD_LOGIC_VECTOR(RX_FABRIC_WIDTH2, 3);
    else
      assert FALSE report "Error : RX_FABRIC_WIDTH2 is not in range 8 .. 6466." severity error;
    end if;
    if ((RX_FABRIC_WIDTH3 >= 8) and (RX_FABRIC_WIDTH3 <= 6466)) then
      RX_FABRIC_WIDTH3_BINARY <= CONV_STD_LOGIC_VECTOR(RX_FABRIC_WIDTH3, 3);
    else
      assert FALSE report "Error : RX_FABRIC_WIDTH3 is not in range 8 .. 6466." severity error;
    end if;
    if ((TX_FABRIC_WIDTH0 >= 8) and (TX_FABRIC_WIDTH0 <= 6466)) then
      TX_FABRIC_WIDTH0_BINARY <= CONV_STD_LOGIC_VECTOR(TX_FABRIC_WIDTH0, 3);
    else
      assert FALSE report "Error : TX_FABRIC_WIDTH0 is not in range 8 .. 6466." severity error;
    end if;
    if ((TX_FABRIC_WIDTH1 >= 8) and (TX_FABRIC_WIDTH1 <= 6466)) then
      TX_FABRIC_WIDTH1_BINARY <= CONV_STD_LOGIC_VECTOR(TX_FABRIC_WIDTH1, 3);
    else
      assert FALSE report "Error : TX_FABRIC_WIDTH1 is not in range 8 .. 6466." severity error;
    end if;
    if ((TX_FABRIC_WIDTH2 >= 8) and (TX_FABRIC_WIDTH2 <= 6466)) then
      TX_FABRIC_WIDTH2_BINARY <= CONV_STD_LOGIC_VECTOR(TX_FABRIC_WIDTH2, 3);
    else
      assert FALSE report "Error : TX_FABRIC_WIDTH2 is not in range 8 .. 6466." severity error;
    end if;
    if ((TX_FABRIC_WIDTH3 >= 8) and (TX_FABRIC_WIDTH3 <= 6466)) then
      TX_FABRIC_WIDTH3_BINARY <= CONV_STD_LOGIC_VECTOR(TX_FABRIC_WIDTH3, 3);
    else
      assert FALSE report "Error : TX_FABRIC_WIDTH3 is not in range 8 .. 6466." severity error;
    end if;
    wait;
    end process INIPROC;
    DRDY <= DRDY_out;
    DRPDO <= DRPDO_out;
    GTHINITDONE <= GTHINITDONE_out;
    MGMTPCSRDACK <= MGMTPCSRDACK_out;
    MGMTPCSRDDATA <= MGMTPCSRDDATA_out;
    RXCODEERR0 <= RXCODEERR0_out;
    RXCODEERR1 <= RXCODEERR1_out;
    RXCODEERR2 <= RXCODEERR2_out;
    RXCODEERR3 <= RXCODEERR3_out;
    RXCTRL0 <= RXCTRL0_out;
    RXCTRL1 <= RXCTRL1_out;
    RXCTRL2 <= RXCTRL2_out;
    RXCTRL3 <= RXCTRL3_out;
    RXCTRLACK0 <= RXCTRLACK0_out;
    RXCTRLACK1 <= RXCTRLACK1_out;
    RXCTRLACK2 <= RXCTRLACK2_out;
    RXCTRLACK3 <= RXCTRLACK3_out;
    RXDATA0 <= RXDATA0_out;
    RXDATA1 <= RXDATA1_out;
    RXDATA2 <= RXDATA2_out;
    RXDATA3 <= RXDATA3_out;
    RXDATATAP0 <= RXDATATAP0_out;
    RXDATATAP1 <= RXDATATAP1_out;
    RXDATATAP2 <= RXDATATAP2_out;
    RXDATATAP3 <= RXDATATAP3_out;
    RXDISPERR0 <= RXDISPERR0_out;
    RXDISPERR1 <= RXDISPERR1_out;
    RXDISPERR2 <= RXDISPERR2_out;
    RXDISPERR3 <= RXDISPERR3_out;
    RXPCSCLKSMPL0 <= RXPCSCLKSMPL0_out;
    RXPCSCLKSMPL1 <= RXPCSCLKSMPL1_out;
    RXPCSCLKSMPL2 <= RXPCSCLKSMPL2_out;
    RXPCSCLKSMPL3 <= RXPCSCLKSMPL3_out;
    RXUSERCLKOUT0 <= RXUSERCLKOUT0_out;
    RXUSERCLKOUT1 <= RXUSERCLKOUT1_out;
    RXUSERCLKOUT2 <= RXUSERCLKOUT2_out;
    RXUSERCLKOUT3 <= RXUSERCLKOUT3_out;
    RXVALID0 <= RXVALID0_out;
    RXVALID1 <= RXVALID1_out;
    RXVALID2 <= RXVALID2_out;
    RXVALID3 <= RXVALID3_out;
    TSTPATH <= TSTPATH_out;
    TSTREFCLKFAB <= TSTREFCLKFAB_out;
    TSTREFCLKOUT <= TSTREFCLKOUT_out;
    TXCTRLACK0 <= TXCTRLACK0_out;
    TXCTRLACK1 <= TXCTRLACK1_out;
    TXCTRLACK2 <= TXCTRLACK2_out;
    TXCTRLACK3 <= TXCTRLACK3_out;
    TXDATATAP10 <= TXDATATAP10_out;
    TXDATATAP11 <= TXDATATAP11_out;
    TXDATATAP12 <= TXDATATAP12_out;
    TXDATATAP13 <= TXDATATAP13_out;
    TXDATATAP20 <= TXDATATAP20_out;
    TXDATATAP21 <= TXDATATAP21_out;
    TXDATATAP22 <= TXDATATAP22_out;
    TXDATATAP23 <= TXDATATAP23_out;
    TXN0 <= TXN0_out;
    TXN1 <= TXN1_out;
    TXN2 <= TXN2_out;
    TXN3 <= TXN3_out;
    TXP0 <= TXP0_out;
    TXP1 <= TXP1_out;
    TXP2 <= TXP2_out;
    TXP3 <= TXP3_out;
    TXPCSCLKSMPL0 <= TXPCSCLKSMPL0_out;
    TXPCSCLKSMPL1 <= TXPCSCLKSMPL1_out;
    TXPCSCLKSMPL2 <= TXPCSCLKSMPL2_out;
    TXPCSCLKSMPL3 <= TXPCSCLKSMPL3_out;
    TXUSERCLKOUT0 <= TXUSERCLKOUT0_out;
    TXUSERCLKOUT1 <= TXUSERCLKOUT1_out;
    TXUSERCLKOUT2 <= TXUSERCLKOUT2_out;
    TXUSERCLKOUT3 <= TXUSERCLKOUT3_out;
  end GTHE1_QUAD_V;
