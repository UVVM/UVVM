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
-- /___/   /\      Filename    : POST_CRC_INTERNAL.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
-------------------------------------------------------

----- CELL POST_CRC_INTERNAL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity POST_CRC_INTERNAL is
    port (
      CRCERROR             : out std_ulogic := '0'     
    );
  end POST_CRC_INTERNAL;

  architecture POST_CRC_INTERNAL_V of POST_CRC_INTERNAL is
    component B_POST_CRC_INTERNAL
      port (
        CRCERROR             : out std_ulogic        
      );
    end component;
  begin
    
  end POST_CRC_INTERNAL_V;
