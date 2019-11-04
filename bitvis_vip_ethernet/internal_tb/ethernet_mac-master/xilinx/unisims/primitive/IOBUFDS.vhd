-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/IOBUFDS.vhd,v 1.8 2012/09/13 23:10:58 robh Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  3-State Diffential Signaling I/O Buffer
-- /___/   /\     Filename : IOBUFDS.vhd
-- \   \  /  \    
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/26/07 - Add else to handle x case for output (CR 424214).
--    07/16/08 - Added IBUF_LOW_PWR attribute.
--    04/22/09 - CR 519127 - Changed IBUF_LOW_PWR default to TRUE.
--    10/14/09 - CR 535630 - Added DIFF_TERM attribute.
--    05/12/10 - CR 559468 -- Added DRC warnings for LVDS_25 bus architectures.
--    12/01/10 - CR 584500 -- Added attribute SLEW
--    08/28/12 - 675511 - add parameter DQS_BIAS and functionality
--    09/11/12 - 677753 - remove X glitch on O
-- End Revision

----- CELL IOBUFDS -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IOBUFDS is
  generic(
    CAPACITANCE : string  := "DONT_CARE";
    DIFF_TERM   : boolean :=  FALSE;
    DQS_BIAS    : string :=  "FALSE";
    IBUF_DELAY_VALUE : string := "0";
    IBUF_LOW_PWR : boolean :=  TRUE;
    IFD_DELAY_VALUE  : string := "AUTO";
    IOSTANDARD  : string  := "DEFAULT";
    SLEW             : string  := "SLOW"
    );

  port(
    O : out std_ulogic;

    IO  : inout std_ulogic;
    IOB : inout std_ulogic;

    I  : in std_ulogic;
    T  : in std_ulogic
    );

end IOBUFDS;

architecture IOBUFDS_V of IOBUFDS is
  signal O_zd    : std_ulogic := 'X';
  signal IO_zd   : std_ulogic := 'X';
  signal IOB_zd  : std_ulogic := 'X';
  signal I_ipd   : std_ulogic := 'X';
  signal IO_ipd  : std_ulogic := 'X';
  signal IOB_ipd : std_ulogic := 'X';
  signal T_ipd   : std_ulogic := 'X';

  signal DQS_BIAS_BINARY : std_ulogic := '0';
begin

  I_ipd   <= I; 
  IO_ipd  <= IO; 
  IOB_ipd <= IOB; 
  T_ipd   <= T;  

  O       <= O_zd;
  IO      <= IO_zd;
  IOB     <= IOB_zd;


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
           report "Attribute Syntax Error: The allowed values for DQS_BIAS are TRUE or FALSE"
           severity Failure;
        end if;
--   
        if((DIFF_TERM = TRUE) or
           (DIFF_TERM = FALSE)) then
             FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The allowed values for DIFF_TERM are TRUE or FALSE"
           severity Failure;
        end if;

--   
        if((CAPACITANCE = "LOW") or
           (CAPACITANCE = "NORMAL") or
           (CAPACITANCE = "DONT_CARE")) then
             FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The allowed values for CAPACITANCE are LOW, NORMAL or DONT_CARE"
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
           report "Attribute Syntax Error: The allowed values for IBUF_DELAY_VALUE are 0, 1, 2, ... , or 16. "
           severity Failure;
        end if;        

--
        if((IBUF_LOW_PWR = TRUE) or
           (IBUF_LOW_PWR = FALSE)) then
             FIRST_TIME := false;
        else
           assert false
           report "Attribute Syntax Error: The allowed values for IBUF_LOW_PWR are TRUE or FALSE"
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
           report "Attribute Syntax Error: The allowed values for IFD_DELAY_VALUE are AUTO, 0, 1, ... , or 8"
           severity Failure;
        end if;        

     end if;

     if((IOSTANDARD = "LVDS_25") or (IOSTANDARD = "LVDSEXT_25")) then
        assert false
        report "DRC Warning : The IOSTANDARD attribute on IOBUFDS instance is either set to LVDS_25 or LVDSEXT_25. These are fixed impedance structure optimized to 100ohm differential. If the intended usage is a bus architecture, please use BLVDS. This is only intended to be used in point to point transmissions that do not have turn around timing requirements"
        severity Warning;
     end if;

     wait;
  end process prcs_init;

  Behavior : process (IO_ipd, IOB_ipd, I_ipd, T_ipd, DQS_BIAS_BINARY)
  begin

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

end IOBUFDS_V;
