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
-- /___/   /\      Filename    : STARTUP_VIRTEX6.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                                 
-- Revision:
--    10/30/09 - CR 537641 -- Added CFGMCLK functionality.
-- End Revision

----- CELL STARTUP_VIRTEX6 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;

library unisim;
use unisim.vpkg.all;

  entity STARTUP_VIRTEX6 is
    generic (
      PROG_USR : boolean := FALSE
    );

    port (
      CFGCLK               : out std_ulogic;
      CFGMCLK              : out std_ulogic;
      DINSPI               : out std_ulogic;
      EOS                  : out std_ulogic;
      PREQ                 : out std_ulogic;
      TCKSPI               : out std_ulogic;
      CLK                  : in std_ulogic;
      GSR                  : in std_ulogic;
      GTS                  : in std_ulogic;
      KEYCLEARB            : in std_ulogic;
      PACK                 : in std_ulogic;
      USRCCLKO             : in std_ulogic;
      USRCCLKTS            : in std_ulogic;
      USRDONEO             : in std_ulogic;
      USRDONETS            : in std_ulogic      
    );
  end STARTUP_VIRTEX6;

  architecture STARTUP_VIRTEX6_V of STARTUP_VIRTEX6 is
    constant  CFGMCLK_PERIOD : time       := 20000 ps;
    signal    CFGMCLK_zd     : std_ulogic := '0';

    begin
       CFGMCLK_zd <= not CFGMCLK_zd after CFGMCLK_PERIOD/2.0;
       CFGMCLK <= CFGMCLK_zd;
    end STARTUP_VIRTEX6_V;
