-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  18X18 Signed Multiplier 
-- /___/   /\     Filename : MULT18X18SIO.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:19 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    07/25/05 - Added CLK_dly to the sensitivity list
--    08/29/05 - Added rest of the signals to the sensitivity list to avoid false
--             - Setup/Hold violations at initial stages
--    11/22/05 - CR 221818, tpw CLK
--    04/07/08 - CR 469973 -- Header Description fix
--    27/05/08 - CR 472154 Removed Vital GSR constructs
-- End Revision

----- CELL MULT18X18SIO -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;


library unisim;
use unisim.vpkg.all;

entity MULT18X18SIO is

  generic (

	AREG            : integer       := 1;
	BREG            : integer       := 1;
	B_INPUT         : string        := "DIRECT";

	PREG            : integer       := 1
        );

  port (
	BCOUT	: out std_logic_vector (17 downto 0);
	P	: out std_logic_vector (35 downto 0);

	A	: in  std_logic_vector (17 downto 0);
	B	: in  std_logic_vector (17 downto 0);
	BCIN	: in  std_logic_vector (17 downto 0);
	CEA	: in  std_ulogic;
	CEB	: in  std_ulogic;
	CEP	: in  std_ulogic;
	CLK	: in  std_ulogic;
	RSTA	: in  std_ulogic;
	RSTB	: in  std_ulogic;
	RSTP	: in  std_ulogic
	);

end MULT18X18SIO;


architecture MULT18X18SIO_V of MULT18X18SIO is

  constant MAX_P          : integer    := 36;
  constant MAX_BCOUT      : integer    := 36;
  constant MAX_BCIN       : integer    := 18;
  constant MAX_B          : integer    := 18;
  constant MAX_A          : integer    := 18;

  constant MSB_P          : integer    := 35;
  constant MSB_BCOUT      : integer    := 17;
  constant MSB_BCIN       : integer    := 17;
  constant MSB_B          : integer    := 17;
  constant MSB_A          : integer    := 17;

  signal A_ipd    : std_logic_vector(MSB_A downto 0) := (others => '0' );
  signal B_ipd    : std_logic_vector(MSB_B downto 0) := (others => '0' );
  signal BCIN_ipd : std_logic_vector(MSB_BCIN downto 0) := (others => '0' );
  signal CEA_ipd  : std_ulogic := 'X';
  signal CEB_ipd  : std_ulogic := 'X';
  signal CEP_ipd  : std_ulogic := 'X';
  signal CLK_ipd  : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd  : std_ulogic := 'X';
  signal RSTA_ipd : std_ulogic := 'X';
  signal RSTB_ipd : std_ulogic := 'X';
  signal RSTP_ipd : std_ulogic := 'X';

  signal A_dly    : std_logic_vector(MSB_A downto 0) := (others => '0' );
  signal B_dly    : std_logic_vector(MSB_B downto 0) := (others => '0' );
  signal BCIN_dly : std_logic_vector(MSB_BCIN downto 0) := (others => '0' );
  signal CEA_dly  : std_ulogic := 'X';
  signal CEB_dly  : std_ulogic := 'X';
  signal CEP_dly  : std_ulogic := 'X';
  signal CLK_dly  : std_ulogic := 'X';
  signal GSR_dly  : std_ulogic := '0';
  signal RSTA_dly : std_ulogic := 'X';
  signal RSTB_dly : std_ulogic := 'X';
  signal RSTP_dly : std_ulogic := 'X';


  --- Internal Signal Declarations

  signal qa_o_reg1 : std_logic_vector(MSB_A downto 0) := (others => '0');
  signal qa_o_mux  : std_logic_vector(MSB_A downto 0) := (others => '0');

  signal b_o_mux   : std_logic_vector(MSB_B downto 0) := (others => '0');
  signal qb_o_reg1 : std_logic_vector(MSB_B downto 0) := (others => '0');
  signal qb_o_mux  : std_logic_vector(MSB_B downto 0) := (others => '0');

  signal mult_o_int : std_logic_vector((MSB_A + MSB_B + 1) downto 0) := (others => '0');

  signal qp_o_reg : std_logic_vector(MSB_P downto 0) := (others => '0');
  signal qp_o_mux : std_logic_vector(MSB_P downto 0) := (others => '0');

  signal BCOUT_zd : std_logic_vector(MSB_BCOUT downto 0) := (others => '0');
  signal P_zd : std_logic_vector(MSB_P downto 0) := (others => '0');

begin

  A_dly          	 <= A              	after 0 ps;
  B_dly          	 <= B              	after 0 ps;
  BCIN_dly       	 <= BCIN           	after 0 ps;
  CEA_dly        	 <= CEA            	after 0 ps;
  CEB_dly        	 <= CEB            	after 0 ps;
  CEP_dly        	 <= CEP            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  RSTA_dly       	 <= RSTA           	after 0 ps;
  RSTB_dly       	 <= RSTB           	after 0 ps;
  RSTP_dly       	 <= RSTP           	after 0 ps;
  GSR_dly                <= GSR                 after 0 ps;


--####################################################################
--#####    Input Register A with 1 level of registers and a mux  #####
--####################################################################
  prcs_qa_1lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qa_o_reg1 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTA_dly = '1') then
               qa_o_reg1 <= ( others => '0');
            elsif ((RSTA_dly = '0') and  (CEA_dly = '1')) then
               qa_o_reg1 <= A_dly;
            end if;
         end if;
      end if;
  end process prcs_qa_1lvl;

----------------------------------------------------------------------

  prcs_qa_o_mux:process(A_dly, qa_o_reg1)
  begin
     case AREG is
       when 0 => qa_o_mux <= A_dly;
       when 1 => qa_o_mux <= qa_o_reg1;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for AREG are 0 or 1"
            severity Failure;
     end case;
  end process prcs_qa_o_mux;

--####################################################################
--#####    Input Register B with two levels of registers and a mux ###
--####################################################################
  prcs_b_in:process(B_dly, BCIN_dly)
  begin
     if(B_INPUT ="DIRECT") then
        b_o_mux <= B_dly;
     elsif(B_INPUT ="CASCADE") then
        b_o_mux <= BCIN_dly;
     else
        assert false
        report "Attribute Syntax Error: The allowed values for B_INPUT are DIRECT or CASCADE."
        severity Failure;
     end if;
  end process prcs_b_in;
------------------------------------------------------------------
 prcs_qb_1lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qb_o_reg1 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTB_dly = '1') then
               qb_o_reg1 <= ( others => '0');
            elsif ((RSTB_dly = '0') and  (CEB_dly = '1')) then
               qb_o_reg1 <= b_o_mux;
            end if;
         end if;
      end if;
  end process prcs_qb_1lvl;
------------------------------------------------------------------
  prcs_qb_o_mux:process(b_o_mux, qb_o_reg1)
  begin
     case BREG is
       when 0 => qb_o_mux <= b_o_mux;
       when 1 => qb_o_mux <= qb_o_reg1;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for BREG are 0 or 1 "
            severity Failure;
     end case;

  end process prcs_qb_o_mux;
--####################################################################
--#####                     Multiply                             #####
--####################################################################
  prcs_mult:process(qa_o_mux, qb_o_mux)
  begin
     mult_o_int <=  qa_o_mux * qb_o_mux;
  end process prcs_mult;
--####################################################################
--#####                    Output  P                             #####
--####################################################################
  prcs_qp_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qp_o_reg <=  ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTP_dly = '1') then
               qp_o_reg <= ( others => '0');
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               qp_o_reg <= mult_o_int;
            end if;
         end if;
      end if;
  end process prcs_qp_reg;
------------------------------------------------------------------
  prcs_qp_mux:process(mult_o_int, qp_o_reg)
  begin
     case PREG is
       when 0 => qp_o_mux <= mult_o_int;
       when 1 => qp_o_mux <= qp_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;

  end process prcs_qp_mux;
--####################################################################
--#####                   ZERO_DELAY_OUTPUTS                     #####
--####################################################################
  prcs_zero_delay_outputs:process(qb_o_mux, qp_o_mux)
  begin
    BCOUT_zd <= qb_o_mux;
    P_zd     <= qp_o_mux;
  end process prcs_zero_delay_outputs;


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_outputs:process(BCOUT_zd, P_zd)
  begin
    BCOUT <= BCOUT_zd;
    P     <= P_zd;
  end process prcs_outputs;

end MULT18X18SIO_V ;

