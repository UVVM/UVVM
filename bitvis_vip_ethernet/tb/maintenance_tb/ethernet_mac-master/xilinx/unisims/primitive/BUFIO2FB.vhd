-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  I/O Clock Buffer/Divider for the Spartan Series
-- /___/   /\     Filename : BUFIO2FB.vhd
-- \   \  /  \    Timestamp : Fri Mar 21 16:42:08 PDT 2008
--  \___\/\___\
--
-- Revision:
--    03/21/08 - Initial version.
-- End Revision

----- CELL BUFIO2FB -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;

entity BUFIO2FB is

  generic(

      DIVIDE_BYPASS : boolean := TRUE  -- TRUE, FALSE
      );

  port(
      O : out std_ulogic;

      I : in  std_ulogic
    );

end BUFIO2FB;

architecture BUFIO2FB_V OF BUFIO2FB is


  signal I_ipd       : std_ulogic := '0';

begin


  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
-------------------------------------------------
------ DIVIDE_BYPASS Check
-------------------------------------------------
      if((DIVIDE_BYPASS /= true) and (DIVIDE_BYPASS /= false))  then
           assert false
           report "Attribute Syntax Error: The Legal values for DIVIDE_BYPASS are TRUE or FALSE"
           severity Failure;
      end if;

     wait;
  end process prcs_init;


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  O  <= I;
--####################################################################


end BUFIO2FB_V;
