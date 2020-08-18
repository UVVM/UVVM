-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IOBUF.vhd,v 1.3 2009/08/22 00:26:02 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Bi-Directional Buffer
-- /___/   /\     Filename : IOBUF.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:43 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/16/08 - Added IBUF_LOW_PWR attribute.
--    04/22/09 - CR 519127 - Changed IBUF_LOW_PWR default to TRUE.
-- End Revision


----- CELL IOBUF -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IOBUF is
  generic(
      CAPACITANCE : string     := "DONT_CARE";
      DRIVE       : integer    := 12;
      IBUF_DELAY_VALUE : string := "0";
      IBUF_LOW_PWR : boolean :=  TRUE;
      IFD_DELAY_VALUE  : string := "AUTO";
      IOSTANDARD  : string     := "DEFAULT";
      SLEW        : string     := "SLOW"
    );

  port(
    O  : out   std_ulogic;
    IO : inout std_ulogic;
    I  : in    std_ulogic;
    T  : in    std_ulogic
    );
end IOBUF;

architecture IOBUF_V of IOBUF is
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

  VPKGBehavior     : process (IO, I, T)

  begin
    O  <= TO_X01(IO);
    if ((T = '1') or (T = 'H')) then
      IO <= 'Z';
    elsif ((T = '0') or (T = 'L')) then
      if ((I = '1') or (I = 'H')) then
        IO <= '1';
      elsif ((I = '0') or (I = 'L')) then
        IO <= '0';
      elsif (I = 'U') then
        IO <= 'U';
      else
        IO <= 'X';  
      end if;
    elsif (T = 'U') then
      IO <= 'U';          
    else                                      
      IO <= 'X';  
    end if;
  end process;
end IOBUF_V;
