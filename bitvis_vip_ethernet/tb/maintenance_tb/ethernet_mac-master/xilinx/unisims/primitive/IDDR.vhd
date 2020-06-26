-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Dual Data Rate Input D Flip-Flop
-- /___/   /\     Filename : IDDR.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:20 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/30/06 - CR 232324 -- Added  timing checks for S/R wrt negedge CLK
--    04/07/08 - CR 469973 -- Header Description fix
--    27/05/08 - CR 472154 Removed Vital GSR constructs
--    10/02/08 - CR 489522 fixed false setup/hold msg when "_"ve values are in sdf
--    12/03/08 - CR 498674 added pulldown on R/S.
--    01/21/09 - CR 503784 pulldown on R/S enhancement.
--    06/23/10 - CR 566394 Removed extra recovery/removal checks
-- End Revision


----- CELL IDDR -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IDDR is

  generic(

      DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
      INIT_Q1      : bit    := '0';
      INIT_Q2      : bit    := '0';
      SRTYPE       : string := "SYNC"
      );

  port(
      Q1          : out std_ulogic;
      Q2          : out std_ulogic;

      C           : in  std_ulogic;
      CE          : in  std_ulogic;
      D           : in  std_ulogic;
      R           : in  std_ulogic := 'L';
      S           : in  std_ulogic := 'L'
    );

end IDDR;

architecture IDDR_V OF IDDR is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := '0';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

  signal Q1_zd	        : std_ulogic := 'X';
  signal Q2_zd	        : std_ulogic := 'X';

  signal Q1_viol        : std_ulogic := 'X';
  signal Q2_viol        : std_ulogic := 'X';

  signal Q1_o_reg	: std_ulogic := 'X';
  signal Q2_o_reg	: std_ulogic := 'X';
  signal Q3_o_reg	: std_ulogic := 'X';
  signal Q4_o_reg	: std_ulogic := 'X';

  signal ddr_clk_edge_type	: integer := -999;
  signal sr_type		: integer := -999;
begin

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  D_dly          	 <= D              	after 0 ps;
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
      elsif((DDR_CLK_EDGE = "SAME_EDGE_PIPELINED") or (DDR_CLK_EDGE = "same_edge_pipelined")) then
         ddr_clk_edge_type <= 3;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/IDDR",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " OPPOSITE_EDGE or SAME_EDGE or  SAME_EDGE_PIPELINED.",
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
             EntityName => "/IDDR",
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
--#####                    q1_q2_q3_q4 reg                       #####
--####################################################################
  prcs_q1q2q3q4_reg:process(C_dly, D_dly, GSR_dly, R_dly, S_dly)
  variable Q1_var : std_ulogic := TO_X01(INIT_Q1);
  variable Q2_var : std_ulogic := TO_X01(INIT_Q2);
  variable Q3_var : std_ulogic := TO_X01(INIT_Q1);
  variable Q4_var : std_ulogic := TO_X01(INIT_Q2);
  begin
     if(GSR_dly = '1') then
         Q1_var := TO_X01(INIT_Q1);
         Q3_var := TO_X01(INIT_Q1);
         Q2_var := TO_X01(INIT_Q2);
         Q4_var := TO_X01(INIT_Q2);
     elsif(GSR_dly = '0') then
        case sr_type is
           when 1 => 
                   if(R_dly = '1') then
                      Q1_var := '0';
                      Q2_var := '0';
                      Q3_var := '0';
                      Q4_var := '0';
                   elsif(((R_dly = '0') or (R_dly = 'L') or (R_dly = 'U')) and (S_dly = '1')) then
                      Q1_var := '1';
                      Q2_var := '1';
                      Q3_var := '1';
                      Q4_var := '1';
                   elsif(((R_dly = '0')  or (R_dly = 'L') or (R_dly = 'U')) and ((S_dly = '0') or (S_dly = 'L') or (S_dly = 'U'))) then
                      if(CE_dly = '1') then
                         if(rising_edge(C_dly)) then
                            Q3_var := Q1_var;
                            Q1_var := D_dly;
                            Q4_var := Q2_var;
                         end if;
                         if(falling_edge(C_dly)) then
                            Q2_var := D_dly;
                         end if;
                      end if;
                   end if;

           when 2 => 
                   if(rising_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q1_var := '0';
                         Q3_var := '0';
                         Q4_var := '0';
                      elsif(((R_dly = '0') or (R_dly = 'L') or (R_dly = 'U')) and (S_dly = '1')) then
                         Q1_var := '1';
                         Q3_var := '1';
                         Q4_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L') or (R_dly = 'U')) and ((S_dly = '0') or (S_dly = 'L') or (S_dly = 'U'))) then
                         if(CE_dly = '1') then
                               Q3_var := Q1_var;
                               Q1_var := D_dly;
                               Q4_var := Q2_var;
                         end if;
                      end if;
                   end if;
                        
                   if(falling_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q2_var := '0';
                      elsif(((R_dly = '0') or (R_dly = 'L') or (R_dly = 'U')) and (S_dly = '1')) then
                         Q2_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L') or (R_dly = 'U')) and ((S_dly = '0') or (S_dly = 'L') or (S_dly = 'U'))) then
                         if(CE_dly = '1') then
                               Q2_var := D_dly;
                         end if;
                      end if;
                   end if;
 
           when others =>
                   null; 
        end case;
     end if;

     q1_o_reg <= Q1_var;
     q2_o_reg <= Q2_var;
     q3_o_reg <= Q3_var;
     q4_o_reg <= Q4_var;

  end process prcs_q1q2q3q4_reg;
--####################################################################
--#####                        q1 & q2  mux                      #####
--####################################################################
  prcs_q1q2_mux:process(q1_o_reg, q2_o_reg, q3_o_reg, q4_o_reg)
  begin
     case ddr_clk_edge_type is
        when 1 => 
                 Q1_zd <= q1_o_reg;
                 Q2_zd <= q2_o_reg;
        when 2 => 
                 Q1_zd <= q1_o_reg;
                 Q2_zd <= q4_o_reg;
       when 3 => 
                 Q1_zd <= q3_o_reg;
                 Q2_zd <= q4_o_reg;
       when others =>
                 null;
     end case;
  end process prcs_q1q2_mux;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q1_zd, Q2_zd)
  begin
      Q1 <= Q1_zd after SYNC_PATH_DELAY;
      Q2 <= Q2_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDDR_V;

