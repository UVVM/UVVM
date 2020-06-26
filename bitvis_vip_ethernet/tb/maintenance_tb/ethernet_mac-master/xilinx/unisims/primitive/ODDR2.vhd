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
-- /___/   /\     Filename : ODDR2.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:20 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    04/07/08 - CR 469973 -- Header Description fix
--    08/20/08 - CR 478850 added pulldown on R/S and pullup on CE.
--    01/12/09 - IR 503207 Reworked C0/C1 alignments
--    01/30/09 - IR 505640 fix
-- End Revision


----- CELL ODDR2 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity ODDR2 is

  generic(

      DDR_ALIGNMENT : string := "NONE";
      INIT          : bit    := '0';
      SRTYPE        : string := "SYNC"
      );

  port(
      Q           : out std_ulogic;

      C0          : in  std_ulogic;
      C1          : in  std_ulogic;
      CE          : in  std_ulogic := 'H';
      D0          : in  std_ulogic;
      D1          : in  std_ulogic;
      R           : in  std_ulogic := 'L';
      S           : in  std_ulogic := 'L'
    );

end ODDR2;

architecture ODDR2_V OF ODDR2 is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C0_ipd	        : std_ulogic := 'X';
  signal C1_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D0_ipd	        : std_ulogic := 'X';
  signal D1_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C0_dly	        : std_ulogic := 'X';
  signal C1_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D0_dly	        : std_ulogic := 'X';
  signal D1_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := 'X';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

--  signal PC0_dly	: std_ulogic := 'X';
--  signal PC1_dly	: std_ulogic := 'X';

  signal Q_zd		: std_ulogic := 'X';

  signal Q_viol		: std_ulogic := 'X';

  signal ddr_alignment_type	: integer := -999;
  signal sr_type		: integer := -999;

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C0_dly         	 <= C0             	after 0 ps;
  C1_dly         	 <= C1             	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  D0_dly         	 <= D0             	after 0 ps;
  D1_dly         	 <= D1             	after 0 ps;
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
          (  HeaderMsg  => " Attribute Syntax Error :",
             GenericName => " DDR_ALIGNMENT ",
             EntityName => "/ODDR2",
             GenericValue => DDR_ALIGNMENT,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE, C0 or C1.",
             TailMsg => "",
             MsgSeverity => failure
         );
      end if;

      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         sr_type <= 1;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         sr_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error :",
             GenericName => " SRTYPE ",
             EntityName => "/ODDR2",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => failure
         );
      end if;

     wait;
  end process prcs_init;
--####################################################################
--#####                     Clocks                               #####
--####################################################################
--  prcs_clocks:process(C0_dly, C1_dly)
--  begin
--     if(((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) or ((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none"))) then
--        PC0_dly <= C0_dly;
--     else
--        PC0_dly <= C1_dly;
--     end if; 

--     if(((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) or ((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none"))) then
--        PC1_dly <= C1_dly;
--     else
--        PC1_dly <= C0_dly;
--     end if; 
--  end process prcs_clocks;

--####################################################################
--#####                      functionality                       #####
--####################################################################

Case0: IF (((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) or ((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none"))) GENERATE
 c0_prcs_func_reg:process(C0_dly, C1_dly, GSR_dly, R_dly, S_dly)
    variable FIRST_TIME : boolean := true;
    variable q_var         : std_ulogic := TO_X01(INIT);
    variable q_d1_c0_out_var : std_ulogic := TO_X01(INIT);
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         q_var         := TO_X01(INIT);
         q_d1_c0_out_var := TO_X01(INIT);
         FIRST_TIME := false;
     else
        case sr_type is
           when 1 => 
                   if(R_dly = '1') then
                      q_var := '0';
                      q_d1_c0_out_var := '0';
                   elsif(((R_dly = '0') or (R_dly = 'L'))and (S_dly = '1')) then
                      q_var := '1';
                      q_d1_c0_out_var := '1';
                   elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                      if(CE_dly = '1') then
                         if(rising_edge(C0_dly)) then
                             q_var := D0_dly;
                             q_d1_c0_out_var := D1_dly;
                         end if;
                         if(rising_edge(C1_dly)) then
                           if(ddr_alignment_type = 1) then
                             q_var := D1_dly;
                           else
                             q_var := q_d1_c0_out_var;
                           end if;
                         end if;
                      end if;
                   end if;

           when 2 => 
                   if(rising_edge(C0_dly)) then
                      if(R_dly = '1') then
                         q_var := '0';
                         q_d1_c0_out_var := '0';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and (S_dly = '1')) then
                         q_var := '1';
                         q_d1_c0_out_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                           q_var := D0_dly;
                           q_d1_c0_out_var := D1_dly;
                         end if;
                      end if;
                   end if;
                        
                   if(rising_edge(C1_dly)) then
                      if(R_dly = '1') then
                         q_var := '0';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and (S_dly = '1')) then
                         q_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                           if(ddr_alignment_type = 1) then
                             q_var := D1_dly;
                           else
                             q_var := q_d1_c0_out_var;
                           end if;
                         end if;
                      end if;
                   end if;
 
           when others =>
                   null; 
        end case;
     end if;

     Q_zd <= q_var;

  end process c0_prcs_func_reg;
END GENERATE Case0;

Case1 : IF ((DDR_ALIGNMENT =  "C1") or (DDR_ALIGNMENT = "c1")) GENERATE
c1_prcs_func_reg:process(C0_dly, C1_dly, GSR_dly, R_dly, S_dly)
    variable FIRST_TIME : boolean := true;
    variable q_var         : std_ulogic := TO_X01(INIT);
    variable q_d1_c0_out_var : std_ulogic := TO_X01(INIT);
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         q_var         := TO_X01(INIT);
         q_d1_c0_out_var := TO_X01(INIT);
         FIRST_TIME := false;
     else
        case sr_type is
           when 1 => 
                   if(R_dly = '1') then
                      q_var := '0';
                      q_d1_c0_out_var := '0';
                   elsif(((R_dly = '0') or (R_dly = 'L'))and (S_dly = '1')) then
                      q_var := '1';
                      q_d1_c0_out_var := '1';
                   elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                      if(CE_dly = '1') then
                         if(rising_edge(C1_dly)) then
                             q_var := D0_dly;
                             q_d1_c0_out_var := D1_dly;
                         end if;
                         if(rising_edge(C0_dly)) then
                           if(ddr_alignment_type = 1) then
                             q_var := D1_dly;
                           else
                             q_var := q_d1_c0_out_var;
                           end if;
                         end if;
                      end if;
                   end if;

           when 2 => 
                   if(rising_edge(C1_dly)) then
                      if(R_dly = '1') then
                         q_var := '0';
                         q_d1_c0_out_var := '0';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and (S_dly = '1')) then
                         q_var := '1';
                         q_d1_c0_out_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                           q_var := D0_dly;
                           q_d1_c0_out_var := D1_dly;
                         end if;
                      end if;
                   end if;
                        
                   if(rising_edge(C0_dly)) then
                      if(R_dly = '1') then
                         q_var := '0';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and (S_dly = '1')) then
                         q_var := '1';
                      elsif(((R_dly = '0')  or (R_dly = 'L')) and ((S_dly = '0') or (S_dly = 'L'))) then
                         if(CE_dly = '1') then
                           if(ddr_alignment_type = 1) then
                             q_var := D1_dly;
                           else
                             q_var := q_d1_c0_out_var;
                           end if;
                         end if;
                      end if;
                   end if;
 
           when others =>
                   null; 
        end case;
     end if;

     Q_zd <= q_var;

  end process c1_prcs_func_reg;
END GENERATE Case1;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q_zd)
  begin
      Q <= Q_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end ODDR2_V;

