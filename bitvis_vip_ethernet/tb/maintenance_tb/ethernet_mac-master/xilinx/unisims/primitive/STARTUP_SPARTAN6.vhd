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
-- /___/   /\      Filename    : STARTUP_SPARTAN6.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
--  Revision: 1.0
--    10/30/09 - CR 537641 -- Added CFGMCLK functionality.
--    08/27/12 - Added EOS functionality (CR 668043).
-- End Revision

----- CELL STARTUP_SPARTAN6 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.vpkg.all;

  entity STARTUP_SPARTAN6 is
    port (
      CFGCLK               : out std_ulogic;
      CFGMCLK              : out std_ulogic;
      EOS                  : out std_ulogic;
      CLK                  : in std_ulogic;
      GSR                  : in std_ulogic;
      GTS                  : in std_ulogic;
      KEYCLEARB            : in std_ulogic      
    );
  end STARTUP_SPARTAN6;

  architecture STARTUP_SPARTAN6_V of STARTUP_SPARTAN6 is
    
    constant  CFGMCLK_PERIOD : time       := 20000 ps;
    signal    CFGMCLK_zd     : std_ulogic := '0';
    signal    EOS_zd         : std_ulogic := '0';
    signal    GSR_int        : std_ulogic := '1';
      
    begin
      CFGMCLK_zd <= not CFGMCLK_zd after CFGMCLK_PERIOD/2.0;
      CFGMCLK <= CFGMCLK_zd;
      GSR_int <= '0' after 100 ns; 
      EOS_zd <= NOT GSR_int;
      EOS <= EOS_zd;  
  end STARTUP_SPARTAN6_V;
