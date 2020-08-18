-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Delay Controller
-- /___/   /\     Filename : IDELAYCTRL.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:20 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    09/12/06 - intialized output # 234140
--    04/10/07 - CR 436682 fix, disable activity when rst is high
--    04/07/08 - CR 469973 -- Header Description fix
--    07/17/09 - CR 526847 -- Reworked RST/clock_lost to get rid of glitch 
--    08/12/09 - CR 529498 -- Fixed initial conditions due to above rework
-- End Revision

----- CELL IDELAYCTRL -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IDELAYCTRL is

  port(
      RDY	: out std_ulogic;

      REFCLK	: in  std_ulogic;
      RST	: in  std_ulogic
  );

end IDELAYCTRL;

architecture IDELAYCTRL_V OF IDELAYCTRL is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal REFCLK_ipd	: std_ulogic := 'X';
  signal RST_ipd	: std_ulogic := 'X';

  signal GSR_dly	: std_ulogic := '0';
  signal REFCLK_dly	: std_ulogic := 'X';
  signal RST_dly	: std_ulogic := 'X';

  signal RDY_zd		: std_ulogic := '0';
  signal RDY_viol	: std_ulogic := 'X';

-- taken from DCM_adv
  signal period : time := 0 ps;
-- CR 234140
  signal lost   : std_ulogic := '1';
  signal lost_r : std_ulogic := '0';
  signal lost_f : std_ulogic := '0';
  signal clock_negedge, clock_posedge, clock : std_ulogic;
  signal temp1 : boolean := false;
  signal temp2 : boolean := false;
  signal clock_low, clock_high : std_ulogic := '0';
  signal clock_second_pos, clock_second_neg : std_ulogic := '0';


begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  REFCLK_dly     	 <= REFCLK         	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                             RDY                          #####
--####################################################################
   prcs_rdy:process(RST_dly, lost)
   begin
      if((RST_dly = '1') or (lost = '1')) then
         RDY_zd <= '0';
--    CR 436682 fix
--      elsif((RST_dly'event) and (RST_dly = '0') and (lost = '0')) then
      elsif((RST_dly = '0') and (lost = '0')) then
         RDY_zd <= '1';
      end if;
   end process prcs_rdy;
--####################################################################
--#####                prcs_determine_period                     #####
--####################################################################
  prcs_determine_period : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current  : time := 0 ps;
  begin
      if (RST_dly = '1') then
        period <= 0 ps;
      elsif (rising_edge(REFCLK_dly)) then
        clock_edge_previous := clock_edge_current;
        clock_edge_current := NOW;
        if (period /= 0 ps and ((clock_edge_current - clock_edge_previous) <= (1.5 * period))) then
          period <= NOW - clock_edge_previous;
        elsif (period /= 0 ps and ((NOW - clock_edge_previous) > (1.5 * period))) then
          period <= 0 ps;
        elsif ((period = 0 ps) and (clock_edge_previous /= 0 ps) and (clock_second_pos = '1')) then
          period <= NOW - clock_edge_previous;
        end if;
      end if;
    wait on REFCLK_dly, RST_dly;
  end process prcs_determine_period;

--####################################################################
--#####                prcs_clock_lost_checker                   #####
--####################################################################
  prcs_clock_lost_checker : process
--    variable clock_low, clock_high : std_ulogic := '0';

  begin
      if (RST_dly = '1') then
        clock_low <= '0';
        clock_high <= '0';
        clock_posedge <= '0';
        clock_negedge <= '0';
      else
        if (rising_edge(REFCLK_dly)) then
          clock_low  <= '0';
          clock_high <= '1';
          clock_posedge <= '0';
          clock_negedge <= '1';
        end if;

        if (falling_edge(REFCLK_dly)) then
          clock_high <= '0';
          clock_low  <= '1';
          clock_posedge <= '1';
          clock_negedge <= '0';
        end if;
      end if;
    wait on REFCLK_dly, RST_dly;
  end process prcs_clock_lost_checker;

--####################################################################
--#####                  prcs_clock_second_p                     #####
--####################################################################
  prcs_clock_second_p : process
    begin
      if (RST_dly = '1') then
        clock_second_pos <= '0';
        clock_second_neg <= '0';
    else
      if (rising_edge(REFCLK_dly)) then
        clock_second_pos <= '1';
      end if;
      if (falling_edge(REFCLK_dly)) then
          clock_second_neg <= '1';
      end if;
    end if;
    wait on REFCLK_dly, RST_dly;
  end process prcs_clock_second_p;
--####################################################################
--#####                prcs_set_reset_lost_r                     #####
--####################################################################
  prcs_set_reset_lost_r : process
    begin
    if(RST_dly = '1') then
-- CR 529498
--     lost_r <= '0';
       lost_r <= '1';
    else
       if (clock_second_pos = '1')then
         if (rising_edge(REFCLK_dly)) then
            wait for 1 ps;
           if (period /= 0 ps) then
             lost_r <= '0';
           end if;
           wait for (period * (9.1/10.0));
           if ((clock_low /= '1') and (clock_posedge /= '1') and (RST_dly = '0')) then
             lost_r <= '1';
           end if;
         end if;
       end if;
    end if;
    wait on REFCLK_dly, RST_dly;
  end process prcs_set_reset_lost_r;

--####################################################################
--#####                prcs_set_reset_lost_f                     #####
--####################################################################
  prcs_set_reset_lost_f : process
    begin
    if(RST_dly = '1') then
-- CR 529498
--     lost_f <= '0';
       lost_f <= '1';
    else
       if (clock_second_neg = '1')then
         if (falling_edge(REFCLK_dly)) then
           if (period /= 0 ps) then
             lost_f <= '0';
           end if;
           wait for (period * (9.1/10.0));
           if ((clock_high /= '1') and (clock_negedge /= '1') and (RST_dly = '0')) then
             lost_f <= '1';
           end if;
         end if;
       end if;
    end if;
    wait on REFCLK_dly, RST_dly;
  end process prcs_set_reset_lost_f;

--####################################################################
--#####                     prcs_assign_lost                     #####
--####################################################################
  prcs_assign_lost : process
    begin
-- CR 529498
--      if (lost_r'event) then
--        lost <= lost_r;
--      end if;
--      if (lost_f'event) then
--        lost <= lost_f;
--      end if;
      lost <= lost_r or  lost_f;
      wait on lost_r, lost_f;
    end process prcs_assign_lost;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(RDY_zd)
  begin
      RDY <= RDY_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDELAYCTRL_V;

