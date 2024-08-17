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
-- /___/   /\      Filename    : CAPTURE_VIRTEX6.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
-------------------------------------------------------

----- CELL CAPTURE_VIRTEX6 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.vpkg.all;

  entity CAPTURE_VIRTEX6 is
    generic (
      ONESHOT : boolean := TRUE
    );

    port (
      CAP                  : in std_ulogic;
      CLK                  : in std_ulogic      
    );
  end CAPTURE_VIRTEX6;

  architecture CAPTURE_VIRTEX6_V of CAPTURE_VIRTEX6 is
    
    signal  Z1_1 : std_ulogic := '1';
    signal  Z1_0 : std_ulogic := '0';

    begin
  end CAPTURE_VIRTEX6_V;
