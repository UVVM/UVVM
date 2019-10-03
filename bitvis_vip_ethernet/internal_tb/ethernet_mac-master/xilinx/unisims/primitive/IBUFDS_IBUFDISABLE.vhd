-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/VITAL/IBUFDS_IBUFDISABLE.vhd,v 1.9 2012/09/13 23:10:58 robh Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2010 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Input Buffer
-- /___/   /\     Filename : IBUFDS_IBUFDISABLE.vhd
-- \   \  /  \    
--  \___\/\___\
--
-- Revision:
--    12/08/10 - Initial version.
--    04/04/11 - CR 604808 fix
--    06/15/11 - CR 613347 -- made ouput logic_1 when IBUFDISABLE is active
--    08/31/11 - CR 623170 -- added attribute USE_IBUFDISABLE
--    09/13/11 - CR 624774 -- Removed attributes IBUF_DELAY_VALUE and IFD_DELAY_VALUE
--    09/16/11 - CR 625725 -- Removed attribute CAPACITANCE
--    08/29/12 - 675511 - add parameter DQS_BIAS and functionality
--    09/11/12 - 677753 - remove X glitch on O
-- End Revision

----- CELL IBUFDS_IBUFDISABLE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IBUFDS_IBUFDISABLE is
  generic(
      DIFF_TERM   : string  :=  "FALSE";
      DQS_BIAS    : string  :=  "FALSE";
      IBUF_LOW_PWR : string :=  "TRUE";
      IOSTANDARD  : string  := "DEFAULT";
      USE_IBUFDISABLE : string :=  "TRUE"
    );

  port(
    O : out std_ulogic;

    I  : in std_ulogic;
    IB : in std_ulogic;
    IBUFDISABLE : in std_ulogic
    );

end IBUFDS_IBUFDISABLE;

architecture IBUFDS_IBUFDISABLE_V of IBUFDS_IBUFDISABLE is
  signal O_zd               : std_ulogic := '0';
  signal I_ipd              : std_ulogic := 'X';
  signal IB_ipd             : std_ulogic := 'X';
  signal IBUFDISABLE_ipd    : std_ulogic := 'X';

  signal DQS_BIAS_BINARY : std_ulogic := '0';
  signal USE_IBUFDISABLE_BINARY : std_ulogic := '0';

begin

  I_ipd <= I;
  IB_ipd <= IB;
  IBUFDISABLE_ipd <= IBUFDISABLE;

  prcs_init : process
    variable FIRST_TIME : boolean := TRUE;
  begin

     if (FIRST_TIME = true) then
        FIRST_TIME := false;

        if (DQS_BIAS = "TRUE") then
           DQS_BIAS_BINARY <= '1';
        elsif (DQS_BIAS = "FALSE") then
           DQS_BIAS_BINARY <= '0';
        else
           assert false
           report "Attribute Syntax Error: The Legal values for DQS_BIAS are TRUE or FALSE"
           severity Failure;
        end if;

--
        if ((DIFF_TERM = "TRUE") or
            (DIFF_TERM = "FALSE")) then
             FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for DIFF_TERM are TRUE or FALSE"
           severity Failure;
        end if;

--
        if ((IBUF_LOW_PWR = "TRUE") or
            (IBUF_LOW_PWR = "FALSE")) then
             FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The Legal values for IBUF_LOW_PWR are TRUE or FALSE"
           severity Failure;
        end if;

--

        if (USE_IBUFDISABLE = "TRUE") then
           USE_IBUFDISABLE_BINARY <= '1';
        elsif (USE_IBUFDISABLE = "FALSE") then
           USE_IBUFDISABLE_BINARY <= '0';
        else
           assert false
           report "Attribute Syntax Error: The Legal values for USE_IBUFDISABLE are TRUE or FALSE"
           severity Failure;
        end if;

--

    end if;

    wait;
  end process prcs_init;

  Behavior : process (I_ipd, IB_ipd, IBUFDISABLE_ipd, USE_IBUFDISABLE_BINARY, DQS_BIAS_BINARY)
     variable IBUFDISABLE_AND_ENABLED   : std_ulogic := '0';
  begin
    IBUFDISABLE_AND_ENABLED := (IBUFDISABLE_ipd and USE_IBUFDISABLE_BINARY);
    if(IBUFDISABLE_AND_ENABLED = '1') then
       O_zd <= '1';
    elsif(IBUFDISABLE_AND_ENABLED = '0') then
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
       elsif ((I_ipd = 'X' or I_ipd = 'U') and (IB_ipd = 'X' or IB_ipd = 'U')) then
         O_zd <= 'X';
       end if;
    end if;

  end process Behavior;

  O <= O_zd;


end IBUFDS_IBUFDISABLE_V;
