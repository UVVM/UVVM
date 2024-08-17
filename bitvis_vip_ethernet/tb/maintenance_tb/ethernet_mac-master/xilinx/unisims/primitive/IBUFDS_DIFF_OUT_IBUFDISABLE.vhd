------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Buffer with Differential Outputs
-- /___/   /\     Filename : IBUFDS_DIFF_OUT_IBUFDISABLE.vhd
-- \   \  /  \    Timestamp : Wed Dec  8 17:04:24 PST 2010
--  \___\/\___\
--
-- Revision:
--    12/08/10 - Initial version.
--    04/04/11 - CR 604808 fix
--    06/15/11 - CR 613347 - made ouput logic_1 when IBUFDISABLE is active
--    08/31/11 - CR 623170 -- added attribute USE_IBUFDISABLE
-- End Revision


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFDS_DIFF_OUT_IBUFDISABLE is
  generic(
    DIFF_TERM       : string := "FALSE";
    IBUF_LOW_PWR    : string := "TRUE";
    IOSTANDARD      : string := "DEFAULT";          
    USE_IBUFDISABLE : string := "TRUE"
    );

   port(
      O                              :	out   STD_ULOGIC;
      OB                             :	out   STD_ULOGIC;      
      
      I                              :	in    STD_ULOGIC;
      IB                             :	in    STD_ULOGIC;
      IBUFDISABLE                    :	in    STD_ULOGIC
      );
end IBUFDS_DIFF_OUT_IBUFDISABLE;

architecture IBUFDS_DIFF_OUT_IBUFDISABLE_V of IBUFDS_DIFF_OUT_IBUFDISABLE is

begin

  prcs_init : process
  variable FIRST_TIME        : boolean    := TRUE;
  begin
     If(FIRST_TIME = true) then
        if((DIFF_TERM = "TRUE") or
           (DIFF_TERM = "FALSE")) then
           FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for DIFF_TERM are TRUE or FALSE"
           severity Failure;
        end if;
     end if;
--
        if((IBUF_LOW_PWR = "TRUE") or
           (IBUF_LOW_PWR = "FALSE")) then
           FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for IBUF_LOW_PWR are TRUE or FALSE"
           severity Failure;
        end if;
--
        if((USE_IBUFDISABLE = "TRUE") or
           (USE_IBUFDISABLE = "FALSE")) then
           FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for USE_IBUFDISABLE are TRUE or FALSE"
           severity Failure;
        end if;

     wait;
  end process prcs_init;


--   VITALBehavior : process (I, IB)
--   begin
--      if (I /= IB ) then
--        O_zd  <= TO_X01(I);
--        OB_zd <= TO_X01(NOT I);
--      end if;
--end process;

   prcs_output : process (IBUFDISABLE, I, IB)
   begin
      if(USE_IBUFDISABLE = "TRUE") then
         if(IBUFDISABLE = '1') then  
            O  <= '1';
            OB <= '1';  
         elsif (IBUFDISABLE = '0') then 
            if (I /= IB ) then
              O  <= TO_X01(I);
              OB <= TO_X01(NOT I);
            end if;
         else
            O  <= 'X';
            OB <= 'X';  
         end if;
      elsif(USE_IBUFDISABLE = "FALSE") then
            if (I /= IB ) then
              O  <= TO_X01(I);
              OB <= TO_X01(NOT I);
            end if;
      end if;
   end process;

end IBUFDS_DIFF_OUT_IBUFDISABLE_V;
