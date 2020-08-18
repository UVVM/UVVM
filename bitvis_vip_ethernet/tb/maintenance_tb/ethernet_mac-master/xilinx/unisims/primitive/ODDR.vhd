-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Dual Data Rate Output D Flip-Flop
-- /___/   /\     Filename : ODDR.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:20 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/30/06 - CR 232324 -- Added  timing checks for S/R wrt negedge CLK
--    04/07/08 - CR 469973 -- Header Description fix
--    27/05/08 - CR 472154 Removed Vital GSR constructs
--    10/02/08 - CR 489522 fixed false setup/hold when "_"ve values are in sdf
--    12/03/08 - CR 498674 added pulldown on R/S.
--    01/21/09 - CR 503784 pulldown on R/S enhancement.
--    07/28/09 - CR 527698 According to holistic, CE has to be high for both rise/fall CLK
--             - If CE is low on the rising edge, it has an effect of no change in the falling CLK. 
--    06/23/10 - CR 566394 Removed extra recovery/removal checks
-- End Revision

----- CELL ODDR -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity ODDR is

  generic(

      DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
      INIT         : bit    := '0';
      SRTYPE       : string := "SYNC"
      );

  port(
      Q           : out std_ulogic;

      C           : in  std_ulogic;
      CE          : in  std_ulogic;
      D1          : in  std_ulogic;
      D2          : in  std_ulogic;
      R           : in  std_ulogic := 'L';
      S           : in  std_ulogic := 'L'
    );

end ODDR;

architecture ODDR_V OF ODDR is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D1_ipd	        : std_ulogic := 'X';
  signal D2_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D1_dly	        : std_ulogic := 'X';
  signal D2_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := '0';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

  signal Q_zd		: std_ulogic := 'X';

  signal Q_viol		: std_ulogic := 'X';

  signal ddr_clk_edge_type	: integer := -999;
  signal sr_type		: integer := -999;

begin

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  D1_dly         	 <= D1             	after 0 ps;
  D2_dly         	 <= D2             	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  R_dly          	 <= R              	after 0 ps;
  S_dly          	 <= S              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
      if((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
         ddr_clk_edge_type <= 1;
      elsif((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
         ddr_clk_edge_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/ODDR",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " OPPOSITE_EDGE or SAME_EDGE.",
             TailMsg => "",
             MsgSeverity => ERROR 
         );
      end if;

      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         sr_type <= 1;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         sr_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SRTYPE ",
             EntityName => "/ODDR",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

     wait;
  end process prcs_init;
--####################################################################
--#####                       q1_q2_q3 reg                       #####
--####################################################################
  prcs_q1q2q3_reg:process(C_dly, GSR_dly, R_dly, S_dly)
  variable Q1_var         : std_ulogic := TO_X01(INIT);
  variable Q2_posedge_var : std_ulogic := TO_X01(INIT);
  begin
     if(GSR_dly = '1') then
         Q1_var         := TO_X01(INIT);
         Q2_posedge_var := TO_X01(INIT);
     elsif(GSR_dly = '0') then
        case sr_type is
           when 1 => 
                   if(R_dly = '1') then
                      Q1_var := '0';
                      Q2_posedge_var := '0';
                   elsif(((R_dly = '0') or (R_dly = 'L')) and (S_dly = '1')) then
                      Q1_var := '1';
                      Q2_posedge_var := '1';
                   elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                      if(CE_dly = '1') then
                         if(rising_edge(C_dly)) then
                            Q1_var         := D1_dly;
                            Q2_posedge_var := D2_dly;
                         end if;
                         if(falling_edge(C_dly)) then
                             case ddr_clk_edge_type is
                                when 1 => 
                                       Q1_var :=  D2_dly;
                                when 2 => 
                                       Q1_var :=  Q2_posedge_var;
                                when others =>
                                          null;
                              end case;
                         end if;
-- CR 527698
                      elsif(CE_dly = '0') then
                          if(rising_edge(C_dly)) then
                            Q2_posedge_var := Q_zd;
                           end if;
                      end if;
                   end if;

           when 2 => 
                   if(rising_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q1_var := '0';
                         Q2_posedge_var := '0';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and (S_dly = '1')) then
                         Q1_var := '1';
                         Q2_posedge_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                            Q1_var         := D1_dly;
                            Q2_posedge_var := D2_dly;
-- CR 527698
                         elsif(CE_dly = '0') then
                            Q2_posedge_var := Q_zd;
                         end if;
                      end if;
                   end if;
                        
                   if(falling_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q1_var := '0';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and (S_dly = '1')) then
                         Q1_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                             case ddr_clk_edge_type is
                                when 1 => 
                                       Q1_var :=  D2_dly;
                                when 2 => 
                                       Q1_var :=  Q2_posedge_var;
                                when others =>
                                          null;
                              end case;
                         end if;
                      end if;
                   end if;
 
           when others =>
                   null; 
        end case;
     end if;

     Q_zd <= Q1_var;

  end process prcs_q1q2q3_reg;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q_zd)
  begin
      Q <= Q_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end ODDR_V;

