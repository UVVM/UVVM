-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFDS.vhd,v 1.5 2012/09/13 23:10:58 robh Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Buffer
-- /___/   /\     Filename : IBUFDS.vhd
-- \   \  /  \    
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    01/10/06 - CR 222428 -- added H(pullup) and L(pulldown) usage
--    07/19/06 - Add else to handle x case for o_out (CR 234718).
--    07/16/08 - Added IBUF_LOW_PWR attribute.
--    04/22/09 - CR 519127 - Changed IBUF_LOW_PWR default to TRUE.
--    08/29/12 - 675511 - add parameter DQS_BIAS and functionality
--    09/11/12 - 677753 - remove X glitch on O
-- End Revision

----- CELL IBUFDS -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFDS is
  generic(
    CAPACITANCE : string  := "DONT_CARE";
    DIFF_TERM   : boolean :=  FALSE;
    DQS_BIAS    : string :=  "FALSE";
    IBUF_DELAY_VALUE : string := "0";
    IBUF_LOW_PWR : boolean :=  TRUE;
    IFD_DELAY_VALUE  : string := "AUTO";
    IOSTANDARD  : string  := "DEFAULT"
    );

  port(
    O : out std_ulogic;

    I  : in std_ulogic;
    IB : in std_ulogic
    );

end IBUFDS;

architecture IBUFDS_V of IBUFDS is
  signal O_zd   : std_ulogic := 'X';
  signal I_ipd  : std_ulogic := 'X';
  signal IB_ipd : std_ulogic := 'X';

  signal DQS_BIAS_BINARY : std_ulogic := '0';
begin

  I_ipd <= I; 
  IB_ipd <= IB;  

  O <= O_zd;


  prcs_init : process
  variable FIRST_TIME        : boolean    := TRUE;
  begin

     if (FIRST_TIME = true) then
        FIRST_TIME := false;

        if (DQS_BIAS = "TRUE") then
           DQS_BIAS_BINARY <= '1';
        elsif (DQS_BIAS = "FALSE")  then
           DQS_BIAS_BINARY <= '0';
        else
           assert false
           report "Attribute Syntax Error: The Legal values for DQS_BIAS are TRUE or FALSE"
           severity Failure;
        end if;
--   
        if((CAPACITANCE = "LOW") or
           (CAPACITANCE = "NORMAL") or
           (CAPACITANCE = "DONT_CARE")) then
             FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for CAPACITANCE are LOW, NORMAL or DONT_CARE"
           severity Failure;
        end if;
--   
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

--  

        if((IFD_DELAY_VALUE = "AUTO") or (IFD_DELAY_VALUE = "auto") or 
          (IFD_DELAY_VALUE = "0")     or (IFD_DELAY_VALUE = "1") or 
          (IFD_DELAY_VALUE = "2")     or (IFD_DELAY_VALUE = "3") or
          (IFD_DELAY_VALUE = "4")     or (IFD_DELAY_VALUE = "5") or
          (IFD_DELAY_VALUE = "6")     or (IFD_DELAY_VALUE = "7") or
          (IFD_DELAY_VALUE = "8")) then
             FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for IFD_DELAY_VALUE are AUTO, 0, 1, ... , or 8"
           severity Failure;
        end if;        


     end if;

     wait;
  end process prcs_init;

  Behavior : process (I_ipd, IB_ipd, DQS_BIAS_BINARY)
  begin
    if  (((I_ipd = '1') or (I_ipd = 'H')) and ((IB_ipd = '0') or (IB_ipd = 'L'))) then
      O_zd <= '1';
    elsif (((I_ipd = '0') or (I_ipd = 'L')) and ((IB_ipd = '1') or (IB_ipd = 'H'))) then
      O_zd <= '0';
    elsif ((I_ipd = 'Z' or I_ipd = '0' or I_ipd = 'L') and (IB_ipd = 'Z' or IB_ipd = '1' or IB_ipd = 'H')) then
      if (DQS_BIAS_BINARY = '1') then
        O_zd <= '0';
      else
        O_zd <= 'X';
      end if;
    elsif ((I_ipd = 'X') or (IB_ipd = 'X')) then
      O_zd <= 'X';
    end if;
  end process Behavior;

end IBUFDS_V;
