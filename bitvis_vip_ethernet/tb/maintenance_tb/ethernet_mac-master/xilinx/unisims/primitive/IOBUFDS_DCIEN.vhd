-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/fuji/VITAL/IOBUFDS_DCIEN.vhd,v 1.10 2012/09/13 23:10:58 robh Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2010 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-State Diffential Signaling I/O Buffer
-- /___/   /\     Filename : IOBUFDS_DCIEN.vhd
-- \   \  /  \    
--  \___\/\___\
--
-- Revision:
--    12/08/10 - Initial version.
--    03/28/11 - CR 603466 fix
--    05/05/11 - CR 608892 fix
--    06/15/11 - CR 613347 -- made ouput logic_1 when IBUFDISABLE is active
--    08/31/11 - CR 623170 -- Tristate powergating support
--    09/13/11 - CR 624774 -- Removed attributes IBUF_DELAY_VALUE and IFD_DELAY_VALUE
--    09/16/11 - CR 625725 -- Removed attribute CAPACITANCE
--    09/19/11 - CR 625564 -- Fixed Tristate powergating polarity
--    08/23/12 - 675511 - add parameter DQS_BIAS and functionality
--    09/11/12 - 677753 - remove X glitch on O
-- End Revision

----- CELL IOBUFDS_DCIEN -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IOBUFDS_DCIEN is
  generic(
    DIFF_TERM    : string := "FALSE";
    DQS_BIAS    : string  :=  "FALSE";
    IBUF_LOW_PWR    : string := "TRUE";
    IOSTANDARD      : string := "DEFAULT";
    SLEW             : string := "SLOW";
    USE_IBUFDISABLE : string :=  "TRUE"
    );

  port(
    O  : out std_ulogic;

    IO  : inout std_ulogic;
    IOB : inout std_ulogic;

    DCITERMDISABLE : in std_ulogic;
    I           : in std_ulogic;
    IBUFDISABLE : in std_ulogic;
    T           : in std_ulogic
    );
end IOBUFDS_DCIEN;

architecture IOBUFDS_DCIEN_V of IOBUFDS_DCIEN is
  signal IO_ipd                 : std_ulogic := 'X';
  signal IOB_ipd                : std_ulogic := 'X';
  signal DCITERMDISABLE_ipd     : std_ulogic := 'X';
  signal I_ipd                  : std_ulogic := 'X';
  signal IBUFDISABLE_ipd        : std_ulogic := 'X';
  signal T_ipd                  : std_ulogic := 'X';
  signal O_zd                   : std_ulogic;
  signal IO_zd                  : std_ulogic;
  signal IOB_zd                 : std_ulogic;
  signal DQS_BIAS_BINARY        : std_ulogic := '0';
  signal USE_IBUFDISABLE_BINARY : std_ulogic := '0';



begin

  IO_ipd             <=  IO;
  IOB_ipd            <=  IOB;
  DCITERMDISABLE_ipd <=  DCITERMDISABLE;
  I_ipd              <=  I;
  IBUFDISABLE_ipd    <=  IBUFDISABLE;
  T_ipd              <=  T;

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
        elsif (USE_IBUFDISABLE = "FALSE")  then
           USE_IBUFDISABLE_BINARY <= '0';
        else
           assert false
           report "Attribute Syntax Error: The Legal values for USE_IBUFDISABLE are TRUE or FALSE"
           severity Failure;
        end if;

--
    end if;

    if((IOSTANDARD = "LVDS_25") or (IOSTANDARD = "LVDSEXT_25")) then
       assert false
       report "DRC Warning : The IOSTANDARD attribute on IOBUFDS_DCIEN instance is either set to LVDS_25 or LVDSEXT_25. These are fixed impedance structure optimized to 100ohm differential. If the intended usage is a bus architecture, please use BLVDS. This is only intended to be used in point to point transmissions that do not have turn around timing requirements"
       severity Warning;
    end if;

    wait;
  end process prcs_init;

  Behavior : process (I_ipd, T_ipd, IO_ipd, IOB_ipd, IBUFDISABLE_ipd, USE_IBUFDISABLE_BINARY, DQS_BIAS_BINARY)
     variable NOT_T_OR_IBUFDISABLE   : std_ulogic := '0';
  begin
    NOT_T_OR_IBUFDISABLE := ((IBUFDISABLE_ipd or (not T_ipd)) and USE_IBUFDISABLE_BINARY);

    if(NOT_T_OR_IBUFDISABLE = '1') then
       O_zd <= '1';
    elsif (NOT_T_OR_IBUFDISABLE = '0') then
       if ((IO_ipd = '1' or IO_ipd = 'H') and (IOB_ipd = '0' or IOB_ipd = 'L')) then
          O_zd <= '1';
       elsif ((IO_ipd = '0' or IO_ipd = 'L') and (IOB_ipd = '1' or IOB_ipd = 'H')) then
          O_zd <= '0';
       elsif ((IO_ipd = 'Z' or IO_ipd = '0' or IO_ipd = 'L') and (IOB_ipd = 'Z' or IOB_ipd = '1' or IOB_ipd = 'H')) then
          if (DQS_BIAS_BINARY = '1') then
            O_zd <= '0';
          else
            O_zd <= 'X';
          end if;
       elsif (IO_ipd = 'X' or IO_ipd = 'U' or IOB_ipd = 'X' or IO_ipd = 'U' ) then
         O_zd <= 'X';
       end if;
    end if;

    if ((T_ipd = '1') or (T_ipd = 'H')) then
      IO_zd <= 'Z';
      IOB_zd <= 'Z';
    elsif ((T_ipd = '0') or (T_ipd = 'L')) then
      if ((I_ipd = '1') or (I_ipd = 'H')) then
        IO_zd <= '1';
        IOB_zd <= '0';
      elsif ((I_ipd = '0') or (I_ipd = 'L')) then
        IO_zd <= '0';
        IOB_zd <= '1';
      elsif (I_ipd = 'U') then
        IO_zd <= 'U';
        IOB_zd <= 'U';
      else
        IO_zd <= 'X';
        IOB_zd <= 'X';
      end if;
    elsif (T_ipd = 'U') then
      IO_zd <= 'U';
      IOB_zd <= 'U';
    else
      IO_zd <= 'X';
      IOB_zd <= 'X';
    end if;
  end process Behavior;

  O <= O_zd;
  IO <= IO_zd;
  IOB <= IOB_zd;


end IOBUFDS_DCIEN_V;
