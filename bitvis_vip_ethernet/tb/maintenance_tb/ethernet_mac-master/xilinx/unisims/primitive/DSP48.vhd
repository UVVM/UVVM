-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  18X18 Signed Multiplier Followed by Three-Input Adder with Pipeline Registers
-- /___/   /\     Filename : DSP48.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:19 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/25/05 - CR 204870 changed all bit_vector message calls to strings.
--    06/30/05 - CR 210790 fixed CheckEnabled in Vital so that timing.
--               violation are not reported when global GSR_dly = 1.
--    01/17/06 - CR 224235 CECARRYIN, CECINSUB fasle hold violation fix.
--    02/28/06 - CR 225886 -- LEGACY_MODE check updates.
--    06/30/06 - CR 234078 -- Fixed False Timing error on RSTCARRYIN
--    08/21/06 - CR 232521 -- fixed DRC check to allow "0010101_11"
--    02/06/08 - CR 455601 -- DRC relax for OPMODEREG/CARRYINSELREG
--    04/07/08 - CR 469973 -- Header Description fix
--    27/05/08 - CR 472154 Removed Vital GSR constructs
--    08/20/08 - CR 479833 -- DRC relax for OPMODEREG/CARRYINSELREG
--    12/14/10 - CR 582515 -- Fixed sensitivity list error in carryin selection
-- End Revision
----- CELL DSP48 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library STD;
use STD.TEXTIO.all;


library unisim;
use unisim.vpkg.all;

entity DSP48 is

  generic(

        AREG            : integer       := 1;
        B_INPUT         : string        := "DIRECT";
        BREG            : integer       := 1;
        CARRYINREG      : integer       := 1;
        CARRYINSELREG   : integer       := 1;
        CREG            : integer       := 1;
        LEGACY_MODE     : string        := "MULT18X18S";
        MREG            : integer       := 1;
        OPMODEREG       : integer       := 1;
        PREG            : integer       := 1;
        SUBTRACTREG     : integer       := 1
        );

  port(
        BCOUT                   : out std_logic_vector(17 downto 0);
        P                       : out std_logic_vector(47 downto 0);
        PCOUT                   : out std_logic_vector(47 downto 0);

        A                       : in  std_logic_vector(17 downto 0);
        B                       : in  std_logic_vector(17 downto 0);
        BCIN                    : in  std_logic_vector(17 downto 0);
        C                       : in  std_logic_vector(47 downto 0);
        CARRYIN                 : in  std_ulogic;
        CARRYINSEL              : in  std_logic_vector(1 downto 0);
        CEA                     : in  std_ulogic;
        CEB                     : in  std_ulogic;
        CEC                     : in  std_ulogic;
        CECARRYIN               : in  std_ulogic;
        CECINSUB                : in  std_ulogic;
        CECTRL                  : in  std_ulogic;
        CEM                     : in  std_ulogic;
        CEP                     : in  std_ulogic;
        CLK                     : in  std_ulogic;
        OPMODE                  : in  std_logic_vector(6 downto 0);
        PCIN                    : in  std_logic_vector(47 downto 0);
        RSTA                    : in  std_ulogic;
        RSTB                    : in  std_ulogic;
        RSTC                    : in  std_ulogic;
        RSTCARRYIN              : in  std_ulogic;
        RSTCTRL                 : in  std_ulogic;
        RSTM                    : in  std_ulogic;
        RSTP                    : in  std_ulogic;
        SUBTRACT                : in  std_ulogic
      );

end DSP48;

-- architecture body                    --

architecture DSP48_V of DSP48 is

    procedure invalid_opmode_preg_msg( OPMODE : IN string ; 
                                   CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48 instance "));
       Write ( Message, string'("requires attribute PREG set to 1."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_preg_msg;

    procedure invalid_opmode_mreg_msg( OPMODE : IN string ; 
                                   CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48 instance "));
       Write ( Message, string'("requires attribute MREG set to 1."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_mreg_msg;

    procedure invalid_opmode_no_mreg_msg( OPMODE : IN string ; 
                                      CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48 instance "));
       Write ( Message, string'("requires attribute MREG set to 0."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_no_mreg_msg;




  constant SYNC_PATH_DELAY : time := 100 ps;

  constant MAX_P          : integer    := 48;
  constant MAX_PCIN       : integer    := 48;
  constant MAX_OPMODE     : integer    := 7;
  constant MAX_BCIN       : integer    := 18;
  constant MAX_B          : integer    := 18;
  constant MAX_A          : integer    := 18;
  constant MAX_C          : integer    := 48;

  constant MSB_PCIN       : integer    := 47;
  constant MSB_OPMODE     : integer    := 6;
  constant MSB_BCIN       : integer    := 17;
  constant MSB_B          : integer    := 17;
  constant MSB_A          : integer    := 17;
  constant MSB_C          : integer    := 47;
  constant MSB_CARRYINSEL : integer    := 1;

  constant MSB_P          : integer    := 47;
  constant MSB_PCOUT      : integer    := 47;
  constant MSB_BCOUT      : integer    := 17;

  constant SHIFT_MUXZ     : integer    := 17;

  signal 	A_ipd		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	B_ipd		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_ipd	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_ipd		: std_logic_vector(MSB_C downto 0)    := (others => '0');
  signal 	CARRYIN_ipd	: std_ulogic := '0';
  signal 	CARRYINSEL_ipd	: std_logic_vector(MSB_CARRYINSEL downto 0)  := (others => '0');
  signal 	CEA_ipd		: std_ulogic := '0';
  signal 	CEB_ipd		: std_ulogic := '0';
  signal 	CEC_ipd		: std_ulogic := '0';
  signal 	CECARRYIN_ipd	: std_ulogic := '0';
  signal 	CECINSUB_ipd	: std_ulogic := '0';
  signal 	CECTRL_ipd	: std_ulogic := '0';
  signal 	CEM_ipd		: std_ulogic := '0';
  signal 	CEP_ipd		: std_ulogic := '0';
  signal 	CLK_ipd		: std_ulogic := '0';
  signal GSR            : std_ulogic := '0';
  signal 	GSR_ipd		: std_ulogic := '0';
  signal 	OPMODE_ipd	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_ipd	: std_logic_vector(MSB_PCIN downto 0) := (others => '0');
  signal 	RSTA_ipd	: std_ulogic := '0';
  signal 	RSTB_ipd	: std_ulogic := '0';
  signal 	RSTC_ipd	: std_ulogic := '0';
  signal 	RSTCARRYIN_ipd	: std_ulogic := '0';
  signal 	RSTCTRL_ipd	: std_ulogic := '0';
  signal 	RSTM_ipd	: std_ulogic := '0';
  signal 	RSTP_ipd	: std_ulogic := '0';
  signal 	SUBTRACT_ipd	: std_ulogic := '0';

  signal 	A_dly		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	B_dly		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_dly	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_dly		: std_logic_vector(MSB_C downto 0) := (others => '0');
  signal 	CARRYIN_dly	: std_ulogic := '0';
  signal 	CARRYINSEL_dly	: std_logic_vector(MSB_CARRYINSEL downto 0)  := (others => '0');
  signal 	CEA_dly		: std_ulogic := '0';
  signal 	CEB_dly		: std_ulogic := '0';
  signal 	CEC_dly		: std_ulogic := '0';
  signal 	CECARRYIN_dly	: std_ulogic := '0';
  signal 	CECINSUB_dly	: std_ulogic := '0';
  signal 	CECTRL_dly	: std_ulogic := '0';
  signal 	CEM_dly		: std_ulogic := '0';
  signal 	CEP_dly		: std_ulogic := '0';
  signal 	CLK_dly		: std_ulogic := '0';
  signal 	GSR_dly		: std_ulogic := '0';
  signal 	OPMODE_dly	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_dly	: std_logic_vector(MSB_PCIN downto 0)     := (others => '0');
  signal 	RSTA_dly	: std_ulogic := '0';
  signal 	RSTB_dly	: std_ulogic := '0';
  signal 	RSTC_dly	: std_ulogic := '0';
  signal 	RSTCARRYIN_dly	: std_ulogic := '0';
  signal 	RSTCTRL_dly	: std_ulogic := '0';
  signal 	RSTM_dly	: std_ulogic := '0';
  signal 	RSTP_dly	: std_ulogic := '0';
  signal 	SUBTRACT_dly	: std_ulogic := '0';

  signal	BCOUT_zd	: std_logic_vector(MSB_BCOUT downto 0) := (others => '0');
  signal	P_zd		: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	PCOUT_zd		: std_logic_vector(MSB_PCOUT downto 0) := (others => '0');
  
  --- Internal Signal Declarations
  signal	qa_o_reg1	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_reg2	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_mux	: std_logic_vector(MSB_A downto 0) := (others => '0');

  signal	b_o_mux		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg1	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg2	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_mux	: std_logic_vector(MSB_B downto 0) := (others => '0');

  signal	qc_o_reg        : std_logic_vector(MSB_C downto 0) := (others => '0');
  signal	qc_o_mux	: std_logic_vector(MSB_C downto 0) := (others => '0');

  signal	mult_o_int	: std_logic_vector((MSB_A + MSB_B + 1) downto 0) := (others => '0');
  signal	mult_o_reg	: std_logic_vector((MSB_A + MSB_B + 1) downto 0) := (others => '0');
  signal	mult_o_mux	: std_logic_vector((MSB_A + MSB_B + 1) downto 0) := (others => '0');

  signal	opmode_o_reg	: std_logic_vector(MSB_OPMODE downto 0) := (others => '0');
  signal	opmode_o_mux	: std_logic_vector(MSB_OPMODE downto 0) := (others => '0');

  signal	muxx_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	muxy_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	muxz_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');

  signal	subtract_o_reg	: std_ulogic := '0';
  signal	subtract_o_mux	: std_ulogic := '0';

  signal	carryinsel_o_reg	: std_logic_vector(MSB_CARRYINSEL downto 0) := (others => '0');
  signal	carryinsel_o_mux	: std_logic_vector(MSB_CARRYINSEL downto 0) := (others => '0');

  signal	qcarryin_o_reg1	: std_ulogic := '0';
  signal	carryin0_o_mux	: std_ulogic := '0';
  signal	carryin1_o_mux	: std_ulogic := '0';
  signal	carryin2_o_mux	: std_ulogic := '0';

  signal	qcarryin_o_reg2	: std_ulogic := '0';

  signal	carryin_o_mux	: std_ulogic := '0';

  signal	accum_o		: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	qp_o_reg	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	qp_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');

  signal	add_i_int      : std_logic_vector(47 downto 0) := (others => '0');
  signal	add_o_int      : std_logic_vector(47 downto 0) := (others => '0');

  signal	reg_p_int         : std_logic_vector(47 downto 0) := (others => '0');
  signal	p_o_int         : std_logic_vector(47 downto 0) := (others => '0');

  signal	subtract1_o_int : std_ulogic := '0';
  signal	carryinsel1_o_int : std_logic_vector(1 downto 0) := (others => '0');
  signal	carry1_o_int     : std_ulogic := '0';
  signal	carry2_o_int     : std_ulogic := '0';


  signal	output_x_sig	: std_ulogic := '0';

  signal   RST_META          : std_ulogic := '0';

  signal   DefDelay          : time := 10 ps;

begin

  A_dly          	 <= A              	after 0 ps;
  B_dly          	 <= B              	after 0 ps;
  BCIN_dly       	 <= BCIN           	after 0 ps;
  C_dly          	 <= C              	after 0 ps;
  CARRYIN_dly    	 <= CARRYIN        	after 0 ps;
  CARRYINSEL_dly 	 <= CARRYINSEL     	after 0 ps;
  CEA_dly        	 <= CEA            	after 0 ps;
  CEB_dly        	 <= CEB            	after 0 ps;
  CEC_dly        	 <= CEC            	after 0 ps;
  CECARRYIN_dly  	 <= CECARRYIN      	after 0 ps;
  CECINSUB_dly   	 <= CECINSUB       	after 0 ps;
  CECTRL_dly     	 <= CECTRL         	after 0 ps;
  CEM_dly        	 <= CEM            	after 0 ps;
  CEP_dly        	 <= CEP            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  OPMODE_dly     	 <= OPMODE         	after 0 ps;
  PCIN_dly       	 <= PCIN           	after 0 ps;
  RSTA_dly       	 <= RSTA           	after 0 ps;
  RSTB_dly       	 <= RSTB           	after 0 ps;
  RSTC_dly       	 <= RSTC           	after 0 ps;
  RSTCARRYIN_dly 	 <= RSTCARRYIN     	after 0 ps;
  RSTCTRL_dly    	 <= RSTCTRL        	after 0 ps;
  RSTM_dly       	 <= RSTM           	after 0 ps;
  RSTP_dly       	 <= RSTP           	after 0 ps;
  SUBTRACT_dly   	 <= SUBTRACT       	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                        Initialization                      ###
--####################################################################
 prcs_init:process
  begin
     if((LEGACY_MODE /="NONE") and (LEGACY_MODE /="MULT18X18") and 
        (LEGACY_MODE /="MULT18X18S")) then
        assert false
        report "Attribute Syntax Error: The allowed values for LEGACY_MODE are NONE, MULT18X18 or MULT18X18S."
        severity Failure;
     elsif((LEGACY_MODE ="MULT18X18") and (MREG /= 0)) then
        assert false
        report "Attribute Syntax Error: The attribute LEGACY_MODE on DSP48 is set to MULT18X18. This requires attribute MREG to be set to 0."
        severity Failure;
     elsif((LEGACY_MODE ="MULT18X18S") and (MREG /= 1)) then
        assert false
        report "Attribute Syntax Error: The attribute LEGACY_MODE on DSP48 is set to MULT18X18S. This requires attribute MREG to be set to 1."
        severity Failure;
     end if;

     wait; 
  end process prcs_init;
--####################################################################
--#####    Input Register A with two levels of registers and a mux ###
--####################################################################
  prcs_qa_2lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qa_o_reg1 <= ( others => '0');
          qa_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTA_dly = '1') and (CEA_dly = '1')) then
            if(RSTA_dly = '1') then
               qa_o_reg1 <= ( others => '0');
               qa_o_reg2 <= ( others => '0');
            elsif ((RSTA_dly = '0') and  (CEA_dly = '1')) then
               qa_o_reg2 <= qa_o_reg1;
               qa_o_reg1 <= A_dly;
            end if;
         end if;
      end if;
  end process prcs_qa_2lvl;
------------------------------------------------------------------
  prcs_qa_o_mux:process(A_dly, qa_o_reg1, qa_o_reg2)
  begin
     case AREG is
       when 0 => qa_o_mux <= A_dly;
       when 1 => qa_o_mux <= qa_o_reg1;
       when 2 => qa_o_mux <= qa_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for AREG are 0 or 1 or 2"
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
 prcs_qb_2lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qb_o_reg1 <= ( others => '0');
          qb_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
-- FP            if((RSTB_dly = '1') and (CEB_dly = '1')) then
            if(RSTB_dly = '1') then
               qb_o_reg1 <= ( others => '0');
               qb_o_reg2 <= ( others => '0');
            elsif ((RSTB_dly = '0') and  (CEB_dly = '1')) then
               qb_o_reg2 <= qb_o_reg1;
               qb_o_reg1 <= b_o_mux;
            end if;
         end if;
      end if;
  end process prcs_qb_2lvl;
------------------------------------------------------------------
  prcs_qb_o_mux:process(b_o_mux, qb_o_reg1, qb_o_reg2)
  begin
     case BREG is
       when 0 => qb_o_mux <= b_o_mux;
       when 1 => qb_o_mux <= qb_o_reg1;
       when 2 => qb_o_mux <= qb_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for BREG are 0 or 1 or 2 "
            severity Failure;
     end case;

  end process prcs_qb_o_mux;

--####################################################################
--#####    Input Register C with 0, 1, level of registers        #####
--####################################################################
  prcs_qc_1lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qc_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
-- FP           if((RSTC_dly = '1') and (CEC_dly = '1'))then
            if(RSTC_dly = '1') then
               qc_o_reg <= ( others => '0');
            elsif ((RSTC_dly = '0') and (CEC_dly = '1')) then
               qc_o_reg <= C_dly;
            end if;
         end if;
      end if;
  end process prcs_qc_1lvl;
------------------------------------------------------------------
  prcs_qc_o_mux:process(C_dly, qc_o_reg)
  begin
     case CREG is
      when 0 => qc_o_mux <= C_dly;
      when 1 => qc_o_mux <= qc_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for CREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_qc_o_mux;

--####################################################################
--#####                     Mulitplier                           #####
--####################################################################
  prcs_mult:process(qa_o_mux, qb_o_mux)
  begin
     mult_o_int <=  qa_o_mux * qb_o_mux;
  end process prcs_mult;
------------------------------------------------------------------
  prcs_mult_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         mult_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTM_dly = '1') and (CEM_dly = '1'))then
            if(RSTM_dly = '1') then
               mult_o_reg <= ( others => '0');
            elsif ((RSTM_dly = '0') and (CEM_dly = '1')) then
               mult_o_reg <= mult_o_int;
            end if;
         end if;
      end if;
  end process prcs_mult_reg;
------------------------------------------------------------------
  prcs_mult_mux:process(mult_o_reg, mult_o_int)
  begin
     case MREG is
      when 0 => mult_o_mux <= mult_o_int;
      when 1 => mult_o_mux <= mult_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for MREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_mult_mux;

--####################################################################
--#####                        OpMode                            #####
--####################################################################
  prcs_opmode_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         opmode_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTCTRL_dly = '1') and (CECTRL_dly = '1'))then
            if(RSTCTRL_dly = '1') then
               opmode_o_reg <= ( others => '0');
            elsif ((RSTCTRL_dly = '0') and (CECTRL_dly = '1')) then
               opmode_o_reg <= OPMODE_dly;
            end if;
         end if;
      end if;
  end process prcs_opmode_reg;
------------------------------------------------------------------
  prcs_opmode_mux:process(opmode_o_reg, OPMODE_dly)
  begin
     case OPMODEREG is
      when 0 => opmode_o_mux <= OPMODE_dly;
      when 1 => opmode_o_mux <= opmode_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for OPMODEREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_opmode_mux;
--####################################################################
--#####                        MUX_XYZ                           #####
--####################################################################
--  prcs_mux_xyz:process(opmode_o_mux,,,, FP)
      -- FP ?? more (Z) should be added to sensitivity list
  prcs_mux_xyz:process(opmode_o_mux, qp_o_mux, qa_o_mux, qb_o_mux, mult_o_mux, 
                       qc_o_mux, PCIN_dly, output_x_sig)
  begin
    if(output_x_sig = '1') then
      muxx_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxy_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxz_o_mux(MSB_P downto 0) <= ( others => 'X');
    elsif(output_x_sig = '0') then
    --MUX_X -----
       case opmode_o_mux(1 downto 0) is
         when "00" => muxx_o_mux <= ( others => '0');
         -- FP ?? better way to concat ? and sign extend ?
         when "01" => muxx_o_mux((MAX_A + MAX_B - 1) downto 0) <= mult_o_mux;
                   if(mult_o_mux(MAX_A + MAX_B - 1) = '1') then
                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '1');
                   elsif (mult_o_mux(MSB_A + MSB_B + 1) = '0') then 
                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '0');
                   end if;

         when "10" => muxx_o_mux <= qp_o_mux;
         when "11" => if(qa_o_mux(MSB_A) = '0') then
                        muxx_o_mux(MSB_P downto 0)  <= ("000000000000" & qa_o_mux & qb_o_mux);
                      elsif(qa_o_mux(MSB_A) = '1') then
                        muxx_o_mux(MSB_P downto 0)  <= ("111111111111" & qa_o_mux & qb_o_mux);
                      end if;
--      when "11" => muxx_o_mux(MSB_B downto 0)  <= qb_o_mux;
--                   muxx_o_mux((MAX_A + MAX_B - 1) downto MAX_B) <= qa_o_mux;
--
--                  if(mult_o_mux(MAX_A + MAX_B - 1) = '1') then
--                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '1');
--                   elsif (mult_o_mux(MSB_A + MSB_B + 1) = '0') then
--                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '0');
--                   end if;
      when others => null;
--            assert false
--            report "Error: input signal OPMODE(1 downto 0) has unknown values"
--            severity Failure;
       end case;

    --MUX_Y -----
       case opmode_o_mux(3 downto 2) is
         when "00" => muxy_o_mux <= ( others => '0');
         when "01" => muxy_o_mux <= ( others => '0');
         when "10" => null;
         when "11" => muxy_o_mux <= qc_o_mux;
         when others => null;
--            assert false
--            report "Error: input signal OPMODE(3 downto 2) has unknown values"
--            severity Failure;
       end case;
    --MUX_Z -----
       case opmode_o_mux(6 downto 4) is
         when "000" => muxz_o_mux <= ( others => '0');
         when "001" => muxz_o_mux <= PCIN_dly;
         when "010" => muxz_o_mux <= qp_o_mux;
         when "011" => muxz_o_mux <= qc_o_mux;
         when "100" => null;
      -- FP ?? better shift possible ?
         when "101" => if(PCIN_dly(MSB_PCIN) = '0') then
                         muxz_o_mux  <= ( others => '0');
                       elsif(PCIN_dly(MSB_PCIN) = '1') then
                         muxz_o_mux  <= ( others => '1');
                       end if;
                       muxz_o_mux ((MSB_PCIN - SHIFT_MUXZ) downto 0) <= PCIN_dly(MSB_PCIN downto SHIFT_MUXZ ); 
         when "110" => if(qp_o_mux(MSB_P) = '0') then
                         muxz_o_mux  <= ( others => '0');
                       elsif(qp_o_mux(MSB_P) = '1') then
                         muxz_o_mux  <= ( others => '1');
                       end if;
--                    muxz_o_mux ((MAX_P - SHIFT_MUXZ) downto 0) <= qp_o_mux(MSB_P downto (SHIFT_MUXZ - 1)); 
                       muxz_o_mux ((MSB_P - SHIFT_MUXZ) downto 0) <= qp_o_mux(MSB_P downto SHIFT_MUXZ ); 
                      
         when "111" => null;
         when others => null;
--            assert false
--            report "Error: input signal OPMODE(6 downto 4) has unknown values"
--            severity Failure;
       end case;
    end if;
  end process prcs_mux_xyz;
--####################################################################
--#####                        Subtract                          #####
--####################################################################
  prcs_subtract_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         subtract_o_reg <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTCTRL_dly = '1') then
               subtract_o_reg <= '0';
            elsif ((RSTCTRL_dly = '0') and (CECINSUB_dly = '1'))then
               subtract_o_reg <= SUBTRACT_dly;
            end if;
         end if;
      end if;
  end process prcs_subtract_reg;
------------------------------------------------------------------
  prcs_subtract_mux:process(subtract_o_reg, SUBTRACT_dly)
  begin
     case SUBTRACTREG is
      when 0 => subtract_o_mux <= SUBTRACT_dly;
      when 1 => subtract_o_mux <= subtract_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for SUBTRACTREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_subtract_mux;

--####################################################################
--#####                     CarryInSel                           #####
--####################################################################
  prcs_carryinsel_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         carryinsel_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTCTRL_dly = '1') and (CECTRL_dly = '1'))then
            if(RSTCTRL_dly = '1') then
               carryinsel_o_reg <= ( others => '0');
            elsif ((RSTCTRL_dly = '0') and (CECTRL_dly = '1')) then
               carryinsel_o_reg <= CARRYINSEL_dly;
            end if;
         end if;
      end if;
  end process prcs_carryinsel_reg;
------------------------------------------------------------------
  prcs_carryinsel_mux:process(carryinsel_o_reg, CARRYINSEL_dly)
  begin
     case CARRYINSELREG is
       when 0 => carryinsel_o_mux <= CARRYINSEL_dly;
       when 1 => carryinsel_o_mux <= carryinsel_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for CARRYINSELREG are 0 or 1"
           severity Failure;
     end case;
  end process prcs_carryinsel_mux;

--####################################################################
--#####                       CarryIn                            #####
--####################################################################
  prcs_carryin_reg1:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg1 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTCARRYIN_dly = '1') then
               qcarryin_o_reg1 <= '0';
            elsif((RSTCARRYIN_dly = '0') and (CECINSUB_dly = '1')) then
               qcarryin_o_reg1 <= CARRYIN_dly;
            end if;
         end if;
      end if;
  end process prcs_carryin_reg1;
------------------------------------------------------------------
  prcs_carryin0_mux:process(qcarryin_o_reg1, CARRYIN_dly)
  begin
     case CARRYINREG is
       when 0 => carryin0_o_mux <= CARRYIN_dly;
       when 1 => carryin0_o_mux <= qcarryin_o_reg1;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for CARRYINREG are 0 or 1"
            severity Failure;
     end case;
  end process prcs_carryin0_mux;
------------------------------------------------------------------
  prcs_carryin1_mux:process(opmode_o_mux(0), opmode_o_mux(1), qa_o_mux(17), qb_o_mux(17))
  begin
     case (opmode_o_mux(0) and opmode_o_mux(1)) is
       when '0' => carryin1_o_mux <= NOT(qa_o_mux(17) xor qb_o_mux(17));
       when '1' => carryin1_o_mux <= NOT qa_o_mux(17);
       when others => null;
--           assert false
--           report "Error: UNKOWN Value at PORT OPMODE(1) "
--           severity Failure;
     end case;
  end process prcs_carryin1_mux;
------------------------------------------------------------------
-- CR 582515 fixed sensitvity list
  prcs_carryin2_mux:process(opmode_o_mux, qp_o_mux(47), PCIN_dly(47))
  begin
     if(((opmode_o_mux(1) = '1') and (opmode_o_mux(0) = '0')) or 
        (opmode_o_mux(5) = '1') or 
        (NOT ((opmode_o_mux(6) = '1') or (opmode_o_mux(4) = '1')))) then
        carryin2_o_mux <= NOT qp_o_mux(47);
     else
        carryin2_o_mux <= NOT PCIN_dly(47);
     end if;
  end process prcs_carryin2_mux;
------------------------------------------------------------------
  prcs_carryin_reg2:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg2 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTCARRYIN_dly = '1') then
               qcarryin_o_reg2 <= '0';
            elsif ((RSTCARRYIN_dly = '0') and (CECARRYIN_dly = '1'))then
               qcarryin_o_reg2 <= carryin1_o_mux;
            end if;
         end if;
      end if;
  end process prcs_carryin_reg2;
------------------------------------------------------------------
  prcs_carryin_mux:process(carryinsel_o_mux, carryin0_o_mux, carryin1_o_mux, carryin2_o_mux, qcarryin_o_reg2)
  begin
     case carryinsel_o_mux is
       when "00" => carryin_o_mux  <= carryin0_o_mux;
       when "01" => carryin_o_mux  <= carryin2_o_mux;
       when "10" => carryin_o_mux  <= carryin1_o_mux;
       when "11" => carryin_o_mux  <= qcarryin_o_reg2;
       when others => null;
--           assert false
--           report "Error: UNKOWN Value at carryinsel_o_mux"
--           severity Failure;
     end case;
  end process prcs_carryin_mux;
--####################################################################
--#####                       ACCUM                              #####
--####################################################################
--
--  NOTE :  moved it to the drc process
--
--  prcs_accum_xyz:process(muxx_o_mux, muxy_o_mux, muxz_o_mux, subtract_o_mux, carryin_o_mux )
--  variable carry_var : integer;
--  begin
--       if(carryin_o_mux = '1') then
--          carry_var := 1;
--       elsif (carryin_o_mux = '0') then 
--          carry_var := 0;
----       else
----          assert false
----          report "Error : CarryIn has Unknown value."
----          severity Failure;
--       end if;
          
--       if(subtract_o_mux = '0') then
--         accum_o <=  muxz_o_mux + (muxx_o_mux + muxy_o_mux + carryin_o_mux); 
--       elsif(subtract_o_mux = '1') then
--         accum_o <=  muxz_o_mux - (muxx_o_mux + muxy_o_mux + carryin_o_mux); 
----       else
----          assert false
----          report "Error : Subtract has Unknown value."
----          severity Failure;
--       end if;
--  end process prcs_accum_xyz;
--####################################################################
--#####                       PCOUT                               #####
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
               qp_o_reg <= accum_o;
            end if;
         end if;
      end if;
  end process prcs_qp_reg;
------------------------------------------------------------------
  prcs_qp_mux:process(accum_o, qp_o_reg)
  begin
     case PREG is
       when 0 => qp_o_mux <= accum_o;
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
    PCOUT_zd <= qp_o_mux;
  end process prcs_zero_delay_outputs;

--####################################################################
--#####                 PMODE DRC                                #####
--####################################################################
  prcs_opmode_drc:process(opmode_o_mux, carryinsel_o_mux, subtract_o_mux,
                       muxx_o_mux, muxy_o_mux, muxz_o_mux, carryin_o_mux)
  variable Message : line;
  variable invalid_opmode_flg : boolean := true;
  variable add_flg : boolean := true;
  variable opmode_carryinsel_var : std_logic_vector(8 downto 0) := (others => '0');
  begin
--    if now > 100 ns then
--    The above line was cusing the intial values of A, B or C not trigger
      opmode_carryinsel_var := opmode_o_mux & carryinsel_o_mux;
      case opmode_carryinsel_var is


        when "000000000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000001000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;
-- CR 455601 eased the following drc 
        when "000001001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;
--

        when "000001100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000010100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000110000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000111000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "000111001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "000111100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000111110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

-- CR 479833 eased the following drc 
        when "000111111" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';
--
        when "001000000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001001000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001001001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001001100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001001101" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001001110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010101" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010111" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001110000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001110001" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001111000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001111001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001111100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001111101" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001111110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "010000000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010001000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011000000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011001000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011001001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011001100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011001110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011010100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011010110" => 
                          if (MREG /= 0) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_no_mreg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011010111" => 
                          if (MREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_mreg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011110000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011111000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011111100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';


        when "011111101" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101000000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101001000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "101001100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101001101" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101001110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010101" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010111" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101110000" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101110001" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101111000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "101111001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "101111100" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101111101" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101111110" => 
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "110000000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110001000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;
        when others    =>
                       if(invalid_opmode_flg = true) then
                          invalid_opmode_flg := false;
                          add_flg := false;
                          output_x_sig <= '1';
                          accum_o <= (others => 'X');
                          Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
                          Write ( Message,  slv_to_str(opmode_o_mux));
                          Write ( Message, string'(" with CARRYINSEL  "));
                          Write ( Message,  slv_to_str(carryinsel_o_mux));
                          Write ( Message, string'(" to DSP48 instance"));
                          Write ( Message, string'(" is invalid."));
                          assert false report Message.all severity Warning;
                          DEALLOCATE (Message);
                        end if;
      end case;


      if(add_flg) then 
         if(subtract_o_mux = '0') then
            accum_o <=  muxz_o_mux + (muxx_o_mux + muxy_o_mux + carryin_o_mux);
         elsif(subtract_o_mux = '1') then
            accum_o <=  muxz_o_mux - (muxx_o_mux + muxy_o_mux + carryin_o_mux);
         end if;
      end if;
--    end if;
  end process prcs_opmode_drc;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(BCOUT_zd, PCOUT_zd, P_zd)
  begin
      BCOUT  <= BCOUT_zd after SYNC_PATH_DELAY;
      P      <= P_zd     after SYNC_PATH_DELAY;
      PCOUT  <= PCOUT_zd after SYNC_PATH_DELAY;
  end process prcs_output;



end DSP48_V;

