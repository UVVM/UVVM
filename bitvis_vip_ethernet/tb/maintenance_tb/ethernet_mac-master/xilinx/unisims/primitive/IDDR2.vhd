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
-- /___/   /\     Filename : IDDR2.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:20 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    04/07/08 - CR 469973 -- Header Description fix
--    08/20/08 - CR 478850 added pulldown on R/S and pullup on CE.
--    01/21/09 - CR 503784 pulldown on R/S enhancement.
--    04/08/09 - CR 517973 Reworked to matched Holistic tests
--    01/12/10 - CR 538181 Fixed R/S to take INIT values.
--    05/04/10 - CR 558177 revert the above CR. Holistic tests are failing
-- End Revision


----- CELL IDDR2 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IDDR2 is

  generic(

      DDR_ALIGNMENT : string := "NONE";
      INIT_Q0       : bit    := '0';
      INIT_Q1       : bit    := '0';
      SRTYPE        : string := "SYNC"
      );

  port(
      Q0          : out std_ulogic;
      Q1          : out std_ulogic;

      C0          : in  std_ulogic;
      C1          : in  std_ulogic;
      CE          : in  std_ulogic := 'H';
      D           : in  std_ulogic;
      R           : in  std_ulogic := 'L';
      S           : in  std_ulogic := 'L'
    );

end IDDR2;

architecture IDDR2_V OF IDDR2 is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C0_ipd	        : std_ulogic := 'X';
  signal C1_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C0_dly	        : std_ulogic := 'X';
  signal C1_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := 'X';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

  signal PC0_dly        : std_ulogic := 'X';
  signal PC1_dly        : std_ulogic := 'X';

  signal Q0_zd	        : std_ulogic := 'X';
  signal Q1_zd	        : std_ulogic := 'X';

  signal Q0_viol        : std_ulogic := 'X';
  signal Q1_viol        : std_ulogic := 'X';

  signal q0_o_reg	: std_ulogic := 'X';
  signal q0_c0_o_reg	: std_ulogic := 'X';
  signal q1_o_reg	: std_ulogic := 'X';
  signal q1_c0_o_reg	: std_ulogic := 'X';

  signal ddr_alignment_type	: integer := -999;
  signal sr_type		: integer := -999;
  
begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C0_dly         	 <= C0             	after 0 ps;
  C1_dly         	 <= C1             	after 0 ps;
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
      if((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none")) then
         ddr_alignment_type <= 1;
      elsif((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) then
         ddr_alignment_type <= 2;
      elsif((DDR_ALIGNMENT = "C1") or (DDR_ALIGNMENT = "c1")) then
         ddr_alignment_type <= 3;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DDR_ALIGNMENT ",
             EntityName => "/IDDR2",
             GenericValue => DDR_ALIGNMENT,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE or C0 or C1.",
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
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " SRTYPE ",
             EntityName => "/IDDR2",
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
--#####                     Clocks                               #####
--####################################################################
  prcs_clocks:process(C0_dly, C1_dly)
  begin
     if(((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) or ((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none"))) then
        PC0_dly <= C0_dly;
     else
        PC0_dly <= C1_dly;
     end if;

     if(((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) or ((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none"))) then
        PC1_dly <= C1_dly;
     else
        PC1_dly <= C0_dly;
     end if;
  end process prcs_clocks;

--####################################################################
--#####                    functionality                         #####
--####################################################################
  prcs_func_reg:process(PC0_dly, PC1_dly, GSR_dly, R_dly, S_dly)
  variable FIRST_TIME : boolean := true;
  variable q0_out_var : std_ulogic := TO_X01(INIT_Q0);
  variable q1_out_var : std_ulogic := TO_X01(INIT_Q1);
  variable q0_c0_out_var : std_ulogic := TO_X01(INIT_Q0);
  variable q1_c0_out_var : std_ulogic := TO_X01(INIT_Q1);
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
       q0_out_var := TO_X01(INIT_Q0);
       q1_out_var := TO_X01(INIT_Q1);
       q0_c0_out_var := TO_X01(INIT_Q0);
       q1_c0_out_var := TO_X01(INIT_Q1);
       FIRST_TIME := false;
     else
        case sr_type is
           when 1 => 
                   if(R_dly = '1') then
                     q0_out_var := '0';
                     q1_out_var := '0';
                     q1_c0_out_var := '0';
                     q0_c0_out_var := '0';                     
                   elsif(((R_dly = '0') or (R_dly = 'L')) and (S_dly = '1')) then
                     q0_out_var := '1';
                     q1_out_var := '1';
                   elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                      if(CE_dly = '1') then
                         if(rising_edge(PC0_dly)) then
                           q0_out_var := D_dly;
                           q0_c0_out_var := q0_out_var;
                           q1_c0_out_var := q1_out_var;
                         end if;
                         if(rising_edge(PC1_dly)) then
                           q1_out_var := D_dly;
                         end if;
                      end if;
                   end if;

           when 2 => 
                   if(rising_edge(PC0_dly)) then
                      if(R_dly = '1') then
                        q0_out_var := '0';
                        q0_c0_out_var := '0';
                        q1_c0_out_var := '0';
                      elsif(((R_dly = '0') or (R_dly = 'L')) and (S_dly = '1')) then
                        q0_out_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                           q0_out_var := D_dly;
                           q0_c0_out_var := q0_out_var;
                           q1_c0_out_var := q1_out_var;
                         end if;
                      end if;
                   end if;
                        
                   if(rising_edge(PC1_dly)) then
                      if(R_dly = '1') then
                        q1_out_var := '0';
                      elsif(((R_dly = '0') or (R_dly = 'L')) and (S_dly = '1')) then
                        q1_out_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                           q1_out_var := D_dly;
                         end if;
                      end if;
                   end if;
 
           when others =>
                   null; 
        end case;
     end if;
         
     q0_o_reg <= q0_out_var;
     q1_o_reg <= q1_out_var;
     q0_c0_o_reg <= q0_c0_out_var;
     q1_c0_o_reg <= q1_c0_out_var;

  end process prcs_func_reg;
--####################################################################
--#####                        output mux                        #####
--####################################################################
  prcs_output_mux:process(q0_o_reg, q1_o_reg, q0_c0_o_reg, q1_c0_o_reg)
  begin
     case ddr_alignment_type is
       when 1 => 
                 Q0_zd <= q0_o_reg;
                 Q1_zd <= q1_o_reg;
       when 2 => 
                 Q0_zd <= q0_o_reg;
                 Q1_zd <= q1_c0_o_reg;
       when 3 => 
                 Q0_zd <= q0_o_reg;
                 Q1_zd <= q1_c0_o_reg;
       when others =>
                 null;
     end case;
  end process prcs_output_mux;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q0_zd, Q1_zd)
  begin
      Q0 <= Q0_zd after SYNC_PATH_DELAY;
      Q1 <= Q1_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDDR2_V;

