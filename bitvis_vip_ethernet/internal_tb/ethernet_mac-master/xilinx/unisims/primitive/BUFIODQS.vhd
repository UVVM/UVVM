-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  
-- /___/   /\     Filename : BUFIODQS.vhd
-- \   \  /  \    Timestamp : Mon Jul 14 14:30:57 PDT 2008
--  \___\/\___\
--
-- Revision:
--    07/14/08 - Initial version.
--    03/18/09 - CR 513153 fix -- unisim output goes "X"
--    03/20/09 - CR 513938 remove DELAY_BYPASS 
--    05/12/09 - CR 521124 changed functionality as specified by hw.
--    09/01/09 - CR 532419 Changed default value of DQSMASK_ENABLE
-- End Revision

----- CELL BUFIODQS -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity BUFIODQS is

  generic(

      DQSMASK_ENABLE : boolean := FALSE  -- TRUE, FALSE
      );

  port(
      O : out std_ulogic;

      DQSMASK : in  std_ulogic;
      I : in  std_ulogic
    );

end BUFIODQS;

architecture BUFIODQS_V OF BUFIODQS is


  signal q1          : std_ulogic := '0';
  signal q2          : std_ulogic := '0';
  signal clk         : std_ulogic := '0';
  signal dglitch_en  : std_ulogic := '0';

  signal I_ipd       : std_ulogic := '0';
  signal DQSMASK_ipd : std_ulogic := '0';
  signal O_zd        : std_ulogic := '0';
  signal Violation   : std_ulogic := '0';

begin

  DQSMASK_ipd    	 <= DQSMASK        ;
  I_ipd          	 <= I              ;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
-------------------------------------------------
------ DQSMASK_ENABLE Check
-------------------------------------------------
      if((DQSMASK_ENABLE /= true) and (DQSMASK_ENABLE /= false))  then
           assert false
           report "Attribute Syntax Error: The Legal values for DQSMASK_ENABLE are TRUE or FALSE"
           severity Failure;
      end if;
     wait;
  end process prcs_init;

--####################################################################
--#####                     Functionality                        #####
--####################################################################

  dglitch_en <= (not q2 or DQSMASK_ipd);

  clk <= I_ipd when (dglitch_en = '1')
        else '0';

  prcs_q1 : process(DQSMASK_ipd, clk)
  begin
     if(DQSMASK_ipd = '1') then
        q1 <= '0';
     else
        if(clk <= '1') then 
           q1 <= '1' after 300 ps;
        end if;
     end if; 
  end process prcs_q1;

  prcs_q2 : process(DQSMASK_ipd, clk) 
  begin
     if(DQSMASK_ipd = '1') then
        q2 <= '0';
     else
        if(clk <= '0') then 
           q2 <= q1 after 400 ps;
        end if;
     end if; 
  end process prcs_q2;


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
 O  <=  clk when DQSMASK_ENABLE else I;
--####################################################################


end BUFIODQS_V;
