-------------------------------------------------------
--  Copyright (c) 1995/2007 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : 
--  /   /                      
-- /___/   /\      Filename    : USR_ACCESS_VIRTEX6.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
-------------------------------------------------------

----- CELL USR_ACCESS_VIRTEX6 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.vpkg.all;

  entity USR_ACCESS_VIRTEX6 is
    port (
      CFGCLK               : out std_ulogic;
      DATA                 : out std_logic_vector(31 downto 0);
      DATAVALID            : out std_ulogic      
    );
  end USR_ACCESS_VIRTEX6;

  architecture USR_ACCESS_VIRTEX6_V of USR_ACCESS_VIRTEX6 is
    
    signal  Z1_1 : std_ulogic := '1';
    signal  Z1_0 : std_ulogic := '0';

    begin
  end USR_ACCESS_VIRTEX6_V;
