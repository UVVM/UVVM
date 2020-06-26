-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/VITAL/BUFPLL.vhd,v 1.8 2012/10/04 22:10:38 robh Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Phase Locked Loop buffer for Spartan Series
-- /___/   /\     Filename : BUFPLL.vhd
-- \   \  /  \
--  \___\/\___\
--
-------------------------------------------------------------------------------
-- Revision:
--    06/11/08 - Initial version.
--    08/19/08 - IR 479918 -- added 100 ps latency to sequential paths. 
--    03/10/09 - IR 505709 -- correlate SERDESSTROBE to GLCK
--    03/24/09 - CR 514119 -- sync output to LOCKED high signal
--    06/16/09 - CR 525221 -- added ENABLE_SYNC attribute
--    02/08/11 - CR 584404 -- restart, if LOCK lost or reprogrammed
--    10/02/12 - 680268 -- line up SERDESSTROBE with neg edge PLLCLK and other clean up
-- End Revision
-------------------------------------------------------------------------------


----- CELL BUFPLL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


library unisim;
use unisim.vpkg.all;

entity BUFPLL is

  generic(

      DIVIDE        : integer := 1;    -- {1..8}
      ENABLE_SYNC   : boolean := TRUE
      );

  port(
      IOCLK        : out std_ulogic;
      LOCK         : out std_ulogic;
      SERDESSTROBE : out std_ulogic;

      GCLK         : in  std_ulogic;
      LOCKED       : in  std_ulogic;
      PLLIN        : in  std_ulogic
    );

end BUFPLL;

architecture BUFPLL_V OF BUFPLL is



  signal GCLK_ipd   : std_ulogic := '0';
  signal GCLK_dly   : std_ulogic := '0';
  signal LOCKED_ipd : std_ulogic := '0';
  signal LOCKED_dly : std_ulogic := '0';
  signal PLLIN_ipd  : std_ulogic := '0';
  signal PLLIN_dly  : std_ulogic := '0';

  signal IOCLK_zd        : std_ulogic := '0';
  signal LOCK_zd         : std_ulogic := '0';
  signal SERDESSTROBE_zd : std_ulogic := '0';

  signal SYNC_STROBE_OUT : std_ulogic := '0';
  signal ENABLE_SYNC_STROBE_OUT : std_ulogic := '0';

-- other signals
  signal time_cal		: boolean := false;
  signal start_wait_time	: time := 0 ps;
  signal end_wait_time		: time := 0 ps;
begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  GCLK_dly       	 <= GCLK           ;
  LOCKED_dly     	 <= LOCKED         ;
  PLLIN_dly      	 <= PLLIN          ;


  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin

-------------------------------------------------
------ DIVIDE Check
-------------------------------------------------

      if((DIVIDE /= 1) and (DIVIDE /= 2) and  (DIVIDE /= 3) and
         (DIVIDE /= 4) and (DIVIDE /= 5) and  (DIVIDE /= 6) and
         (DIVIDE /= 7) and (DIVIDE /= 8)) then
         GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DIVIDE ",
             EntityName => "/BUFPLL",
             GenericValue => DIVIDE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 1, 2, 3, 4, 5, 6, 7, or 8 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

----------- Check for ENABLE_SYNC ----------------------

     case ENABLE_SYNC is
       when true | false => null;
       when others =>
          assert false
          report "Attribute Syntax Error: The allowed values for ENABLE_SYNC are TRUE or FALSE"
          severity Failure;
     end case;

     wait;
  end process prcs_init;

--####################################################################
--#####          Generate ENABLE_SYNC_STROBE_OUT                 #####
--####################################################################

  prcs_calc_period:process(PLLIN_dly)
  variable pre_clk_edge_var : time := 0 ps;
  variable cur_clk_edge_var : time := 0 ps;
  variable clk_period_var : time := 0 ps;
  begin
-- CR 584404
-- pay attention to LOCKED if ENABLE_SYNC true or already calculated once => loss of lock.
     if(rising_edge(PLLIN_dly)) then
        if(LOCKED_dly /= '1' and (ENABLE_SYNC or time_cal)) then
          pre_clk_edge_var := 0 ps;
          cur_clk_edge_var := 0 ps;
          clk_period_var   := 0 ps;
          start_wait_time  <= 0 ps; 
          end_wait_time    <= 0 ps; 
          time_cal         <= false; 
        elsif(not time_cal) then
           pre_clk_edge_var := cur_clk_edge_var;   
           cur_clk_edge_var := now;   
           if(pre_clk_edge_var > 0 ps) then
               clk_period_var := cur_clk_edge_var - pre_clk_edge_var;
               if (DIVIDE = 1) then
                  start_wait_time <= clk_period_var * (1.0 / 4.0) * 1.0 ;
               else
                  start_wait_time <= clk_period_var * (((2.0 * real (DIVIDE -1)) - 1.0) / 4.0) * 1.0 ;
               end if;
               end_wait_time   <= clk_period_var;
               if(LOCKED_dly = '1')  then
                  time_cal <= true;
               end if;
           end if;
        end if;
     end if;
  end process prcs_calc_period;

  prcs_EnableSyncSerdesStrobe:process(GCLK_dly)
  begin
     if(rising_edge(GCLK_dly)) then
        if((time_cal or not ENABLE_SYNC) and (start_wait_time > 0 ps)) then
           if (DIVIDE = 1) then
              ENABLE_SYNC_STROBE_OUT <= transport '1' after start_wait_time;
           else
              ENABLE_SYNC_STROBE_OUT <= transport '1' after start_wait_time, '0' after (start_wait_time+end_wait_time);
           end if;
        else
           ENABLE_SYNC_STROBE_OUT <= '0';
        end if;
     end if;
  end process prcs_EnableSyncSerdesStrobe;

  prcs_SyncSerdesStrobe:process(PLLIN_dly)
  begin
     if(falling_edge(PLLIN_dly)) then
        SYNC_STROBE_OUT <= ENABLE_SYNC_STROBE_OUT after 100 ps;
     end if;
  end process prcs_SyncSerdesStrobe;

--####################################################################
--#####          Generate SERDESSTROBE_zd                        #####
--####################################################################

  SERDESSTROBE_zd <= SYNC_STROBE_OUT;

--####################################################################
--#####          Generate IOCLK                                  #####
--####################################################################

  IOCLK_zd <= PLLIN_dly;

--####################################################################
--#####          Generate LOCK                                   #####
--####################################################################

  LOCK_zd <= LOCKED_dly;
     

--####################################################################
--#####                           OUTPUT                         #####
--####################################################################
  IOCLK          <= IOCLK_zd;

  LOCK           <= LOCK_zd;

  SERDESSTROBE   <= SERDESSTROBE_zd;

--####################################################################

end BUFPLL_V;

