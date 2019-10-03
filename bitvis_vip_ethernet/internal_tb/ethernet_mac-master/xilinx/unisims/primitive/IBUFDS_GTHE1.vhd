-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Buffer for GTs
-- /___/   /\     Filename : IBUFDS_GTHE1.vhd
-- \   \  /  \    Timestamp : Tue Jun  2 11:25:11 PDT 2009
--  \___\/\___\
--
-- Revision:
--    06/02/09 - Initial version.
-- End Revision


----- CELL IBUFDS_GTHE1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;



entity IBUFDS_GTHE1 is



  port(
      O       : out std_ulogic;

      I       : in  std_ulogic;
      IB      : in  std_ulogic
    );

end IBUFDS_GTHE1;

architecture IBUFDS_GTHE1_V OF IBUFDS_GTHE1 is



  signal I_ipd  : std_ulogic := 'X';
  signal IB_ipd : std_ulogic := 'X';

  signal O_zd     : std_ulogic := 'X';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------


  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####              Generate O                                  #####
--####################################################################
  VitalBehavior : process (I, IB)
  begin
    if ( (((I = '1') or (I = 'H')) and ((IB = '0') or (IB = 'L'))) or
         (((I = '0') or (I = 'L')) and ((IB = '1') or (IB = 'H'))) ) then
       O_zd <= TO_X01(I);
    elsif (I = 'Z' or I = 'X' or IB = 'Z' or IB ='X') then
       O_zd <= 'X';
    end if;

  end process;
     

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  O          <= O_zd;
--####################################################################


end IBUFDS_GTHE1_V;
