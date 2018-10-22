-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IBUFGDS_DIFF_OUT.vhd,v 1.4 2010/11/03 23:13:25 fphillip Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Clock Buffer with Differential Outputs
-- /___/   /\     Filename : IBUFGDS_DIFF_OUT.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:40 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    02/10/09 - CR 430124 -- Added attribute DIFF_TERM.
--    06/02/09 - CR 523083 -- Added attribute IBUF_LOW_PWR.
--    11/03/10 - CR 576577 -- changed default value of IOSTANDARD from LVDS_25 to DEFAULT.
-- End Revision


----- CELL IBUFGDS_DIFF_OUT -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFGDS_DIFF_OUT is
  generic(
    DIFF_TERM   : boolean :=  FALSE;
    IBUF_LOW_PWR : boolean :=  TRUE;
    IOSTANDARD  : string  := "DEFAULT"          
    );

   port(
      O                              :	out   STD_ULOGIC;
      OB                              :	out   STD_ULOGIC;      
      
      I                              :	in    STD_ULOGIC;
      IB                              :	in    STD_ULOGIC      
      );
end IBUFGDS_DIFF_OUT;

architecture IBUFGDS_DIFF_OUT_V of IBUFGDS_DIFF_OUT is
begin

   prcs_init : process
   variable FIRST_TIME        : boolean    := TRUE;
   begin
      If(FIRST_TIME = true) then
         if((DIFF_TERM = TRUE) or
            (DIFF_TERM = FALSE)) then
            FIRST_TIME := false;
         else
            assert false
            report "Attribute Syntax Error: The Legal values for DIFF_TERM are TRUE or FALSE"
            severity Failure;
         end if;
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

      wait;
   end process prcs_init;

   VITALBehavior : process (I, IB)
   begin
      if (I /= IB ) then
        O  <= TO_X01(I);
        OB <= TO_X01(NOT I);
      end if;
end process;
end IBUFGDS_DIFF_OUT_V;
