-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for VIRTEX5
-- /___/   /\     Filename : STARTUP_VIRTEX5.vhd
-- \   \  /  \    Timestamp : Thu Jun  2 10:57:05 PDT 2005
--  \___\/\___\
--
-- Revision:
--    06/02/05 - Initial version.
--    10/30/09 - CR 537429 -- Added CFGMCLK functionality.
-- End Revision


----- CELL STARTUP_VIRTEX5 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTUP_VIRTEX5 is
  port(
    CFGCLK	: out std_ulogic;
    CFGMCLK	: out std_ulogic;
    DINSPI	: out std_ulogic;
    EOS		: out std_ulogic;
    TCKSPI	: out std_ulogic;

    CLK		: in std_ulogic := 'X';
    GSR		: in std_ulogic := 'X';
    GTS		: in std_ulogic := 'X';
    USRCCLKO	: in std_ulogic := 'X';
    USRCCLKTS	: in std_ulogic := 'X';
    USRDONEO	: in std_ulogic := 'X';
    USRDONETS	: in std_ulogic := 'X'
    );

end STARTUP_VIRTEX5;

architecture STARTUP_VIRTEX5_V of STARTUP_VIRTEX5 is
   constant  CFGMCLK_PERIOD : time       := 10000 ps;
   signal    CFGMCLK_zd     : std_ulogic := '0'; 

begin
   CFGMCLK_zd <= not CFGMCLK_zd after CFGMCLK_PERIOD; 
   CFGMCLK <= CFGMCLK_zd;
end STARTUP_VIRTEX5_V;
