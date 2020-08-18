-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFGDS.vhd,v 1.3 2009/08/22 00:26:02 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Clock Buffer
-- /___/   /\     Filename : IBUFGDS.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:40 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/26/07 - Add else to handle x case for output (CR 424214).
--    07/16/08 - Added IBUF_LOW_PWR attribute.
--    04/22/09 - CR 519127 - Changed IBUF_LOW_PWR default to TRUE.
-- End Revision

----- CELL IBUFGDS -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFGDS is
  generic(
      CAPACITANCE : string  := "DONT_CARE";
      DIFF_TERM   : boolean :=  FALSE;
      IBUF_DELAY_VALUE : string := "0";
      IBUF_LOW_PWR : boolean :=  TRUE;
      IOSTANDARD  : string  := "DEFAULT"
    );

  port(
    O : out std_ulogic;

    I  : in std_ulogic;
    IB : in std_ulogic
    );
end IBUFGDS;

architecture IBUFGDS_V of IBUFGDS is
begin
  prcs_init : process
  variable FIRST_TIME        : boolean    := TRUE;
  begin

     If(FIRST_TIME = true) then

        if((CAPACITANCE = "LOW") or
           (CAPACITANCE = "NORMAL") or
           (CAPACITANCE = "DONT_CARE")) then
           FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for CAPACITANCE are LOW, NORMAL or DONT_CARE"
           severity Failure;
        end if;

        if((DIFF_TERM = TRUE) or
           (DIFF_TERM = FALSE)) then
           FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for DIFF_TERM are TRUE or FALSE"
           severity Failure;
        end if;

--   
        if((IBUF_DELAY_VALUE = "0") or (IBUF_DELAY_VALUE = "1") or 
          (IBUF_DELAY_VALUE = "2")  or (IBUF_DELAY_VALUE = "3") or
          (IBUF_DELAY_VALUE = "4")  or (IBUF_DELAY_VALUE = "5") or
          (IBUF_DELAY_VALUE = "6")  or (IBUF_DELAY_VALUE = "7") or
          (IBUF_DELAY_VALUE = "8")  or (IBUF_DELAY_VALUE = "9") or
          (IBUF_DELAY_VALUE = "10") or (IBUF_DELAY_VALUE = "11") or
          (IBUF_DELAY_VALUE = "12") or (IBUF_DELAY_VALUE = "13") or
          (IBUF_DELAY_VALUE = "14") or (IBUF_DELAY_VALUE = "15") or
          (IBUF_DELAY_VALUE = "16")) then 
              FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for IBUF_DELAY_VALUE are 0, 1, 2, ... , or 16. "
           severity Failure;
        end if;        

--

        if((IBUF_LOW_PWR = TRUE) or
           (IBUF_LOW_PWR = FALSE)) then
           FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for IBUF_LOW_PWR are TRUE or FALSE"
           severity Failure;
        end if;

     end if;

     wait;
  end process prcs_init;

  VitalBehavior : process (I, IB)
  begin
    if ((I = '1') and (IB = '0')) then
      O <= TO_X01(I);
    elsif ((I = '0') and (IB = '1')) then
      O <= TO_X01(I);
    elsif (I = 'Z' or I = 'X' or IB = 'Z' or IB ='X') then
        O <= 'X';
    end if;
  end process;
end IBUFGDS_V;
