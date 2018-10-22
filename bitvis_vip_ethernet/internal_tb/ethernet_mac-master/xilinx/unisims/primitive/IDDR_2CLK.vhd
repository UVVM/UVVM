-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Input Dual Data-Rate Register with Dual Clock inputs.
-- /___/   /\     Filename : IDDR_2CLK.vhd
-- \   \  /  \    Timestamp : Mon Jun 26 08:18:20 PST 2006
--  \___\/\___\
--
-- Revision:
--    06/26/06 - Initial version.
--    05/15/07 - CR 438883 fix
--    04/07/08 - CR 469973 -- Header Description fix
--    28/05/08 - CR 472154 Removed Vital GSR constructs
--    06/23/10 - CR 566394 Removed extra recovery/removal checks
-- End Revision


----- CELL IDDR_2CLK -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IDDR_2CLK is

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
      CB          : in  std_ulogic;
      CE          : in  std_ulogic;
      D           : in  std_ulogic;
      R           : in  std_ulogic;
      S           : in  std_ulogic
    );

end IDDR_2CLK;

architecture IDDR_2CLK_V OF IDDR_2CLK is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C_ipd	        : std_ulogic := 'X';
  signal CB_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D_ipd	        : std_ulogic := 'X';
  signal GSR_ipd	: std_ulogic := '0';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C_dly	        : std_ulogic := 'X';
  signal CB_dly	        : std_ulogic := 'X';
  signal CE_C_dly       : std_ulogic := 'X';
  signal CE_CB_dly      : std_ulogic := 'X';
  signal D_C_dly        : std_ulogic := 'X';
  signal D_CB_dly       : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := '0';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';
  signal R_C_dly	: std_ulogic := 'X';
  signal R_CB_dly	: std_ulogic := 'X';
  signal S_C_dly	: std_ulogic := 'X';
  signal S_CB_dly	: std_ulogic := 'X';

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
  CB_dly         	 <= CB             	after 0 ps;
  CE_C_dly       	 <= CE             	after 0 ps;
  CE_CB_dly      	 <= CE             	after 0 ps;
  D_C_dly        	 <= D              	after 0 ps;
  D_CB_dly       	 <= D              	after 0 ps;
  GSR_dly        	 <= '0'            	after 0 ps;
  R_dly          	 <= R              	after 0 ps;
  R_C_dly        	 <= R              	after 0 ps;
  R_CB_dly       	 <= R              	after 0 ps;
  S_dly          	 <= S              	after 0 ps;
  S_C_dly        	 <= S              	after 0 ps;
  S_CB_dly       	 <= S              	after 0 ps;

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
             EntityName => "/IDDR_2CLK",
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
             EntityName => "/IDDR_2CLK",
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
  prcs_q1q2q3q4_reg:process(C_dly, CB_dly, GSR_dly, R_dly, S_dly)
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
                   elsif((R_dly = '0') and (S_dly = '1')) then
                      Q1_var := '1';
                      Q2_var := '1';
                      Q3_var := '1';
                      Q4_var := '1';
                   elsif((R_dly = '0') and (S_dly = '0')) then
                      if(rising_edge(C_dly)) then
                         if(CE_C_dly = '1') then
                            Q3_var := Q1_var;
                            Q1_var := D_C_dly;
                            Q4_var := Q2_var;
                         end if;
                      end if;
                      if(rising_edge(CB_dly)) then
                        if(CE_CB_dly = '1') then
                            Q2_var := D_CB_dly;
                        end if;
                      end if;
                   end if;

           when 2 => 
                   if(rising_edge(C_dly)) then
                      if(R_C_dly = '1') then
                         Q1_var := '0';
                         Q3_var := '0';
                         Q4_var := '0';
                      elsif((R_C_dly = '0') and (S_C_dly = '1')) then
                         Q1_var := '1';
                         Q3_var := '1';
                         Q4_var := '1';
                      elsif((R_C_dly = '0') and (S_C_dly = '0')) then
                         if(CE_C_dly = '1') then
                               Q3_var := Q1_var;
                               Q1_var := D_C_dly;
                               Q4_var := Q2_var;
                         end if;
                      end if;
                   end if;
                        
                   if(rising_edge(CB_dly)) then
                      if(R_CB_dly = '1') then
                         Q2_var := '0';
                      elsif((R_CB_dly = '0') and (S_CB_dly = '1')) then
                         Q2_var := '1';
                      elsif((R_CB_dly = '0') and (S_CB_dly = '0')) then
                         if(CE_CB_dly = '1') then
                               Q2_var := D_CB_dly;
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


end IDDR_2CLK_V;

