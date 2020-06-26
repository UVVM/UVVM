-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/EFUSE_USR.vhd,v 1.3 2009/08/22 00:26:00 harikr Exp $
-------------------------------------------------------
--  Copyright (c) 2009 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : EFUSE_USR.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
-------------------------------------------------------

----- CELL EFUSE_USR -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity EFUSE_USR is
    generic (
      SIM_EFUSE_VALUE : bit_vector := X"00000000"
    );

    port (
      EFUSEUSR             : out std_logic_vector(31 downto 0)    
);
  end EFUSE_USR;

  architecture EFUSE_USR_V of EFUSE_USR is
    
    constant SIM_EFUSE_VALUE_BINARY : std_logic_vector(31 downto 0) := To_StdLogicVector(SIM_EFUSE_VALUE);
    
    begin
    
    EFUSEUSR <= SIM_EFUSE_VALUE_BINARY;

  end EFUSE_USR_V;
