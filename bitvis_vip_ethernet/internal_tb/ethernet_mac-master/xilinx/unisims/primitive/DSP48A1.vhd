-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Multifunctional, Cascadable, 48-bit Output Arithmetic Block
-- /___/   /\     Filename : DSP48A1.vhd
-- \   \  /  \    Timestamp : Tue Jul 31 09:23:05 PDT 2007
--  \___\/\___\
--
-- Revision:
--    07/25/07 - Initial version.
--    05/07/08 - IR # 467568, pulldown CARRYIN, BCIN and PCIN -- both unisim and isimprim
--    05/17/08 - CR 472154 Removed Vital GSR constructs
--    09/23/09 - CR 534398 Reset qcarryout_o_reg1
-- End Revision
----- CELL DSP48A1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library STD;
use STD.TEXTIO.all;


library unisim;
use unisim.vpkg.all;

entity DSP48A1 is

  generic(

        A0REG           : integer       := 0;
        A1REG           : integer       := 1;
        B0REG           : integer       := 0;
        B1REG           : integer       := 1;
        CARRYINREG      : integer       := 1;
        CARRYINSEL      : string        := "OPMODE5";
        CARRYOUTREG     : integer       := 1;
        CREG            : integer       := 1;
        DREG            : integer       := 1;
        MREG            : integer       := 1;
        OPMODEREG       : integer       := 1;
        PREG            : integer       := 1;
        RSTTYPE         : string        := "SYNC"
        );

  port(
        BCOUT                   : out std_logic_vector(17 downto 0);
        CARRYOUT                : out std_ulogic;
        CARRYOUTF               : out std_ulogic;
        M                       : out std_logic_vector(35 downto 0);
        P                       : out std_logic_vector(47 downto 0);
        PCOUT                   : out std_logic_vector(47 downto 0);

        A                       : in  std_logic_vector(17 downto 0);
        B                       : in  std_logic_vector(17 downto 0);
        C                       : in  std_logic_vector(47 downto 0);
        CARRYIN                 : in  std_ulogic := 'L';
        CEA                     : in  std_ulogic;
        CEB                     : in  std_ulogic;
        CEC                     : in  std_ulogic;
        CECARRYIN               : in  std_ulogic;
        CED                     : in  std_ulogic;
        CEM                     : in  std_ulogic;
        CEOPMODE                : in  std_ulogic;
        CEP                     : in  std_ulogic;
        CLK                     : in  std_ulogic;
        D                       : in  std_logic_vector(17 downto 0);
        OPMODE                  : in  std_logic_vector(7 downto 0);
        PCIN                    : in  std_logic_vector(47 downto 0) := (others => 'L');
        RSTA                    : in  std_ulogic;
        RSTB                    : in  std_ulogic;
        RSTC                    : in  std_ulogic;
        RSTCARRYIN              : in  std_ulogic;
        RSTD                    : in  std_ulogic;
        RSTM                    : in  std_ulogic;
        RSTOPMODE               : in  std_ulogic;
        RSTP                    : in  std_ulogic
      );

end DSP48A1;

-- architecture body                    --

architecture DSP48A1_V of DSP48A1 is

    procedure invalid_opmode_preg_msg( OPMODE : IN string ; 
                                   CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48A1 instance "));
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
       Write ( Message, string'(" to DSP48A1 instance "));
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
       Write ( Message, string'(" to DSP48A1 instance "));
       Write ( Message, string'("requires attribute MREG set to 0."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_no_mreg_msg;




  constant SYNC_PATH_DELAY : time := 100 ps;

  constant MAX_ACCUM      : integer    := 48;
  constant MAX_BCOUT      : integer    := 18;
  constant MAX_M          : integer    := 36;
  constant MAX_P          : integer    := 48;
  constant MAX_PCOUT      : integer    := 48;
  constant MSB_ACCUM      : integer    := MAX_ACCUM - 1;
  constant MSB_BCOUT      : integer    := MAX_BCOUT - 1;
  constant MSB_M          : integer    := MAX_M     - 1;
  constant MSB_P          : integer    := MAX_P     - 1;
  constant MSB_PCOUT      : integer    := MAX_PCOUT - 1;

  constant MAX_A          : integer    := 18;
  constant MAX_B          : integer    := 18;
  constant MAX_BCIN       : integer    := 18;
  constant MAX_C          : integer    := 48;
  constant MAX_D          : integer    := 18;
  constant MAX_PREADD     : integer    := 18;
  constant MAX_OPMODE     : integer    := 8;
  constant MAX_PCIN       : integer    := 48;
  constant MSB_A          : integer    := MAX_A      - 1;
  constant MSB_B          : integer    := MAX_B      - 1;
  constant MSB_BCIN       : integer    := MAX_BCIN   - 1;
  constant MSB_C          : integer    := MAX_C      - 1;
  constant MSB_D          : integer    := MAX_D      - 1;
  constant MSB_PREADD     : integer    := MAX_PREADD - 1;
  constant MSB_OPMODE     : integer    := MAX_OPMODE - 1;
  constant MSB_PCIN       : integer    := MAX_PCIN   - 1;


  constant SHIFT_MUXZ     : integer    := 17;

  signal 	A_ipd		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	B_ipd		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_ipd	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_ipd		: std_logic_vector(MSB_C downto 0)    := (others => '0');
  signal 	CARRYIN_ipd	: std_ulogic := '0';
  signal 	CEA_ipd		: std_ulogic := '0';
  signal 	CEB_ipd		: std_ulogic := '0';
  signal 	CEC_ipd		: std_ulogic := '0';
  signal 	CECARRYIN_ipd	: std_ulogic := '0';
  signal 	CED_ipd		: std_ulogic := '0';
  signal 	CEM_ipd		: std_ulogic := '0';
  signal 	CEOPMODE_ipd	: std_ulogic := '0';
  signal 	CEP_ipd		: std_ulogic := '0';
  signal 	CLK_ipd		: std_ulogic := '0';
  signal 	D_ipd		: std_logic_vector(MSB_D downto 0) := (others => '0');
  signal        GSR             : std_ulogic := '0';
  signal 	GSR_ipd		: std_ulogic := '0';
  signal 	OPMODE_ipd	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_ipd	: std_logic_vector(MSB_PCIN downto 0) := (others => '0');
  signal 	RSTA_ipd	: std_ulogic := '0';
  signal 	RSTB_ipd	: std_ulogic := '0';
  signal 	RSTC_ipd	: std_ulogic := '0';
  signal 	RSTCARRYIN_ipd	: std_ulogic := '0';
  signal 	RSTD_ipd	: std_ulogic := '0';
  signal 	RSTM_ipd	: std_ulogic := '0';
  signal 	RSTOPMODE_ipd	: std_ulogic := '0';
  signal 	RSTP_ipd	: std_ulogic := '0';

  signal 	A_dly		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	B_dly		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_dly	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_dly		: std_logic_vector(MSB_C downto 0)    := (others => '0');
  signal 	CARRYIN_dly	: std_ulogic := '0';
  signal 	CEA_dly		: std_ulogic := '0';
  signal 	CEB_dly		: std_ulogic := '0';
  signal 	CEC_dly		: std_ulogic := '0';
  signal 	CECARRYIN_dly	: std_ulogic := '0';
  signal 	CED_dly		: std_ulogic := '0';
  signal 	CEM_dly		: std_ulogic := '0';
  signal 	CEOPMODE_dly	: std_ulogic := '0';
  signal 	CEP_dly		: std_ulogic := '0';
  signal 	CLK_dly		: std_ulogic := '0';
  signal 	D_dly		: std_logic_vector(MSB_D downto 0) := (others => '0');
  signal 	GSR_dly		: std_ulogic := '0';
  signal 	OPMODE_dly	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_dly	: std_logic_vector(MSB_PCIN downto 0) := (others => '0');
  signal 	RSTA_dly	: std_ulogic := '0';
  signal 	RSTB_dly	: std_ulogic := '0';
  signal 	RSTC_dly	: std_ulogic := '0';
  signal 	RSTCARRYIN_dly	: std_ulogic := '0';
  signal 	RSTD_dly	: std_ulogic := '0';
  signal 	RSTM_dly	: std_ulogic := '0';
  signal 	RSTOPMODE_dly	: std_ulogic := '0';
  signal 	RSTP_dly	: std_ulogic := '0';


  signal	BCOUT_zd	: std_logic_vector(MSB_BCOUT downto 0) := (others => '0');
  signal 	CARRYOUT_zd	: std_ulogic := '0';
  signal 	CARRYOUTF_zd	: std_ulogic := '0';
  signal	M_zd		: std_logic_vector(MSB_M downto 0) := (others => '0');
  signal	P_zd		: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	PCOUT_zd	: std_logic_vector(MSB_PCOUT downto 0) := (others => '0');
  
  --- Internal Signal Declarations
  signal	qa_o_reg1	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_reg2	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_mux	: std_logic_vector(MSB_A downto 0) := (others => '0');

  signal	b_o_mux		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg1	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg2	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_mux0	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_mux	: std_logic_vector(MSB_B downto 0) := (others => '0');

  signal	qc_o_reg        : std_logic_vector(MSB_C downto 0) := (others => '0');
  signal	qc_o_mux	: std_logic_vector(MSB_C downto 0) := (others => '0');

  signal	qd_o_reg        : std_logic_vector(MSB_D downto 0) := (others => '0');
  signal	qd_o_mux	: std_logic_vector(MSB_D downto 0) := (others => '0');

  signal	preadd		: std_logic_vector(MSB_PREADD downto 0) := (others => '0');
  signal	mux_preadd	: std_logic_vector(MSB_PREADD downto 0) := (others => '0');

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

  signal	carryinsel_o_reg	: std_ulogic := '0';
  signal	carryinsel_o_mux	: std_ulogic := '0';

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


  signal	output_x_sig	  : std_ulogic := '0';

  signal	RST_META          : std_ulogic := '0';

  signal	DefDelay          : time := 10 ps;

  signal	rst_async_flag    : std_ulogic := '0';
  signal	carryinsel_attr   : std_ulogic := '0';

  signal	opmode_valid_flg  : boolean := true;

  signal 	carryout_o		: std_ulogic := '0';
  signal	qcarryout_o_reg1	: std_ulogic := '0';
  signal	qcarryout_o_mux		: std_ulogic := '0';
begin

  A_dly          	 <= A              	after 0 ps;
  B_dly          	 <= B              	after 0 ps;
  C_dly          	 <= C              	after 0 ps;
  CARRYIN_dly    	 <= CARRYIN        	after 0 ps;
  CEA_dly        	 <= CEA            	after 0 ps;
  CEB_dly        	 <= CEB            	after 0 ps;
  CEC_dly        	 <= CEC            	after 0 ps;
  CECARRYIN_dly  	 <= CECARRYIN      	after 0 ps;
  CED_dly        	 <= CED            	after 0 ps;
  CEM_dly        	 <= CEM            	after 0 ps;
  CEOPMODE_dly   	 <= CEOPMODE       	after 0 ps;
  CEP_dly        	 <= CEP            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  D_dly          	 <= D              	after 0 ps;
  OPMODE_dly     	 <= OPMODE         	after 0 ps;
  PCIN_dly       	 <= PCIN           	after 0 ps;
  RSTA_dly       	 <= RSTA           	after 0 ps;
  RSTB_dly       	 <= RSTB           	after 0 ps;
  RSTC_dly       	 <= RSTC           	after 0 ps;
  RSTCARRYIN_dly 	 <= RSTCARRYIN     	after 0 ps;
  RSTD_dly       	 <= RSTD           	after 0 ps;
  RSTM_dly       	 <= RSTM           	after 0 ps;
  RSTOPMODE_dly  	 <= RSTOPMODE      	after 0 ps;
  RSTP_dly       	 <= RSTP           	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                        Initialization                      ###
--####################################################################
  prcs_init:process
  begin

-------- A0REG/A1REG  & B0REG/B1REG ------

     if((A0REG /= 0) and (A0REG /= 1 )) then
        assert false
        report "Attribute Syntax Error: Legal values for attribute A0REG on instance DSP48A1 are 0 or 1."
        severity Failure;
     end if;

     if((A1REG /= 0) and (A1REG /= 1 )) then
        assert false
        report "Attribute Syntax Error: Legal values for attribute A1REG on instance DSP48A1 are 0 or 1."
        severity Failure;
     end if;

     if((B0REG /= 0) and (B0REG /= 1 )) then
        assert false
        report "Attribute Syntax Error: Legal values for attribute B0REG on instance DSP48A1 are 0 or 1."
        severity Failure;
     end if;

     if((B1REG /= 0) and (B1REG /= 1 )) then
        assert false
        report "Attribute Syntax Error: Legal values for attribute B1REG on instance DSP48A1 are 0 or 1."
        severity Failure;
     end if;

-------- RSTTYPE ----------

     if((RSTTYPE = "SYNC") or (RSTTYPE = "sync")) then
        rst_async_flag  <= '0';
     elsif((RSTTYPE = "ASYNC") or (RSTTYPE = "async")) then
        rst_async_flag  <= '1';
     else
        assert false
        report "Attribute Syntax Error: The attribute RSTTYPE on DSP48A1 is incorrect. Legal values for this attribute are SYNC or ASYNC."
        severity Failure;
     end if;

-------- CARRYINSEL ---------

     if((CARRYINSEL = "CARRYIN") or (CARRYINSEL = "carryin")) then
        carryinsel_attr  <= '0';
     elsif((CARRYINSEL = "OPMODE5") or (CARRYINSEL = "opmode5")) then
        carryinsel_attr  <= '1';
     else
        assert false
        report "Attribute Syntax Error: The attribute RSTTYPE on DSP48A1 is incorrect. Legal values for this attribute are SYNC or ASYNC."
        severity Failure;
     end if;

     wait;

  end process prcs_init;
--####################################################################
--#####      Input Register A with two levels of registers         ###
--####################################################################

  prcs_qa_2lvl:process(CLK_dly, GSR_dly, RSTA_dly)
  begin
      if(GSR_dly = '1') then
          qa_o_reg1 <= ( others => '0');
          qa_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTA_dly = '1') then
                  qa_o_reg1 <= ( others => '0');
                  qa_o_reg2 <= ( others => '0');
               elsif ((RSTA_dly = '0') and (CEA_dly = '1')) then
                  if(rising_edge(CLK_dly)) then
                     qa_o_reg2 <= qa_o_reg1;
                     qa_o_reg1 <= A_dly;
                  end if;
               end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTA_dly = '1') then
                     qa_o_reg1 <= ( others => '0');
                     qa_o_reg2 <= ( others => '0');
                  elsif ((RSTA_dly = '0') and (CEA_dly = '1')) then
                      qa_o_reg2 <= qa_o_reg1;
                      qa_o_reg1 <= A_dly;
                  end if;
               end if;
            when others => null;
         end case;
      end if;
  end process prcs_qa_2lvl;
------------------------------------------------------------------
  prcs_qa_o_mux:process(A_dly, qa_o_reg1, qa_o_reg2)
  begin
     if((A0REG=0) and (A1REG=0)) then
        qa_o_mux <= A_dly;
     elsif(((A0REG=1) and (A1REG=0)) or ((A0REG=0) and (A1REG=1))) then
        qa_o_mux <= qa_o_reg1;
     elsif((A0REG=1) and (A1REG=1)) then
        qa_o_mux <= qa_o_reg2;
     end if; 
  end process prcs_qa_o_mux;

--####################################################################
--#### Input Register B with two levels of registers and two muxes ###
--####################################################################
 prcs_qb_2lvl:process(CLK_dly, GSR_dly, RSTB_dly)
  begin
      if(GSR_dly = '1') then
          qb_o_reg1 <= ( others => '0');
          qb_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTB_dly = '1') then
                  qb_o_reg1 <= ( others => '0');
                  qb_o_reg2 <= ( others => '0');
               elsif ((RSTB_dly = '0') and (CEB_dly = '1')) then
                   if(rising_edge(CLK_dly)) then
                      qb_o_reg2 <= mux_preadd;
                      qb_o_reg1 <= B_dly;
                   end if;
               end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTB_dly = '1') then
                     qb_o_reg1 <= ( others => '0');
                     qb_o_reg2 <= ( others => '0');
                  elsif ((RSTB_dly = '0') and (CEB_dly = '1')) then
                      qb_o_reg2 <= mux_preadd;
                      qb_o_reg1 <= B_dly;
                  end if;
               end if;
            when others => null;
         end case;
      end if;
  end process prcs_qb_2lvl;

------- PRE ADD --------------------------------------------------

  prcs_qb_preadd:process(opmode_o_mux, B_dly, qd_o_mux, qb_o_reg1)
  begin
     if(((B0REG=0) and (B1REG=0)) or ((B0REG=0) and (B1REG=1))) then
        qb_o_mux0 <= B_dly;
        if(opmode_o_mux(6)='0') then
            preadd <= (qd_o_mux + B_dly );
         elsif(opmode_o_mux(6)='1') then
            preadd <= (qd_o_mux - B_dly );
         end if;
     elsif(((B0REG=1) and (B1REG=1)) or ((B0REG=1) and (B1REG=0))) then
        qb_o_mux0 <= qb_o_reg1;
        if(opmode_o_mux(6)='0') then
            preadd <= (qd_o_mux + qb_o_reg1);
         elsif(opmode_o_mux(6)='1') then
            preadd <= (qd_o_mux - qb_o_reg1);
         end if;
     end if; 
  end process prcs_qb_preadd;

------------------------------------------------------------------
  prcs_preadd_sel:process(opmode_o_mux(4), preadd, qb_o_mux0)
  begin
     if(opmode_o_mux(4)='1') then
        mux_preadd <= preadd;
     elsif(opmode_o_mux(4)='0') then
        mux_preadd <= qb_o_mux0;
     end if;
  end process prcs_preadd_sel;
------------------------------------------------------------------
  prcs_qb_o_mux:process(mux_preadd, qb_o_reg2)
  begin
     if(((B0REG=0) and (B1REG=0)) or ((B0REG=1) and (B1REG=0))) then
        qb_o_mux <= mux_preadd;
     elsif(((B0REG=1) and (B1REG=1)) or ((B0REG=0) and (B1REG=1))) then
        qb_o_mux <= qb_o_reg2;
     end if; 
  end process prcs_qb_o_mux;

--####################################################################
--#####    Input Register C with 0, 1, level of registers        #####
--####################################################################

  prcs_qc_1lvl:process(CLK_dly, GSR_dly, RSTC_dly)

  begin
      if(GSR_dly = '1') then
         qc_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTC_dly = '1') then
                  qc_o_reg <= ( others => '0');
               elsif((RSTC_dly = '0') and (CEC_dly = '1'))then
                  if(rising_edge(CLK_dly)) then
                     qc_o_reg <= C_dly;
                  end if;
                end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTC_dly = '1') then
                     qc_o_reg <= ( others => '0');
                  elsif ((RSTC_dly = '0') and (CEC_dly = '1')) then
                      qc_o_reg <= C_dly;
                  end if;
               end if;
            when others => null;
         end case;
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
           report "Attribute Syntax Error: The allowed values for CREG on instace DSP48A1 are 0 or 1"
           severity Failure;
      end case;
  end process prcs_qc_o_mux;

--####################################################################
--#####    Input Register D with 0, 1, level of registers        #####
--####################################################################

  prcs_qd_1lvl:process(CLK_dly, GSR_dly, RSTD_dly)

  begin
      if(GSR_dly = '1') then
         qd_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTD_dly = '1') then
                  qd_o_reg <= ( others => '0');
               elsif((RSTD_dly = '0') and (CED_dly = '1'))then
                  if(rising_edge(CLK_dly)) then
                     qd_o_reg <= D_dly;
                  end if;
                end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTD_dly = '1') then
                     qd_o_reg <= ( others => '0');
                  elsif ((RSTD_dly = '0') and (CED_dly = '1')) then
                      qd_o_reg <= D_dly;
                  end if;
               end if;
            when others => null;
         end case;
      end if;
  end process prcs_qd_1lvl;
------------------------------------------------------------------
  prcs_qd_o_mux:process(D_dly, qd_o_reg)
  begin
     case DREG is
      when 0 => qd_o_mux <= D_dly;
      when 1 => qd_o_mux <= qd_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for DREG on instace DSP48A1 are 0 or 1"
           severity Failure;
      end case;
  end process prcs_qd_o_mux;

--####################################################################
--#####                     Multiplier                           #####
--####################################################################
  prcs_mult:process(qa_o_mux, qb_o_mux)
  begin
     mult_o_int <=  qa_o_mux * qb_o_mux;
  end process prcs_mult;
------------------------------------------------------------------
  prcs_mult_reg:process(CLK_dly, GSR_dly, RSTM_dly)
  begin
      if(GSR_dly = '1') then
         mult_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTM_dly = '1') then
                  mult_o_reg <= ( others => '0');
               elsif((RSTM_dly = '0') and (CEM_dly = '1'))then
                  if(rising_edge(CLK_dly)) then
                     mult_o_reg <= mult_o_int;
                  end if;
                end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTM_dly = '1') then
                     mult_o_reg <= ( others => '0');
                  elsif ((RSTM_dly = '0') and (CEM_dly = '1')) then
                      mult_o_reg <= mult_o_int;
                  end if;
               end if;
            when others => null;
         end case;
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
           report "Attribute Syntax Error: The allowed values for MREG on instance DSP48A1 are 0 or 1"
           severity Failure;
      end case;
  end process prcs_mult_mux;

--####################################################################
--#####     OpMode Register with 0, 1, level of registers        #####
--####################################################################

  prcs_opmode_reg:process(CLK_dly, GSR_dly, RSTOPMODE_dly)
  begin
      if(GSR_dly = '1') then
         opmode_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTOPMODE_dly = '1') then
                  opmode_o_reg <= ( others => '0');
               elsif((RSTOPMODE_dly = '0') and (CEOPMODE_dly = '1'))then
                  if(rising_edge(CLK_dly)) then
                     opmode_o_reg <= OPMODE_dly;
                  end if;
                end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTOPMODE_dly = '1') then
                     opmode_o_reg <= ( others => '0');
                  elsif ((RSTOPMODE_dly = '0') and (CEOPMODE_dly = '1')) then
                      opmode_o_reg <= OPMODE_dly;
                  end if;
               end if;
            when others => null;
         end case;
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
------------------------------------------------------------------
  prcs_carryout_mux:process(carryout_o, qcarryout_o_reg1 )
  begin
     case CARRYOUTREG is
      when 0 => qcarryout_o_mux <= carryout_o;
      when 1 => qcarryout_o_mux <= qcarryout_o_reg1;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for CARRYOUTREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_carryout_mux;
--####################################################################
--#####                        MUX_XYZ                           #####
--####################################################################
  prcs_mux_xz:process(opmode_o_mux, qp_o_mux, qa_o_mux, qb_o_mux, mult_o_mux, 
                       qc_o_mux, qd_o_mux, PCIN_dly, output_x_sig)
  begin
    if(output_x_sig = '1') then
      muxx_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxy_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxz_o_mux(MSB_P downto 0) <= ( others => 'X');
    elsif(output_x_sig = '0') then
    --MUX_X -----
       case opmode_o_mux(1 downto 0) is
         when "00" => muxx_o_mux <= ( others => '0');
         when "01" => muxx_o_mux((MAX_A + MAX_B - 1) downto 0) <= mult_o_mux;
                   if(mult_o_mux(MAX_A + MAX_B - 1) = '1') then
                     muxx_o_mux(MSB_P downto (MAX_A + MAX_B)) <=  ( others => '1');
                   elsif (mult_o_mux(MSB_A + MSB_B + 1) = '0') then 
                     muxx_o_mux(MSB_P downto (MAX_A + MAX_B)) <=  ( others => '0');
                   end if;

         when "10" => muxx_o_mux <= qp_o_mux;
         when "11" => muxx_o_mux(MSB_P downto 0) <=  (qd_o_mux((MSB_P - (MAX_A + MAX_B)) downto 0) & qa_o_mux & qb_o_mux);
      when others => null;
       end case;

    --MUX_Z -----
       case opmode_o_mux(3 downto 2) is
         when "00" => muxz_o_mux <= ( others => '0');
         when "01" => muxz_o_mux <= PCIN_dly;
         when "10" => muxz_o_mux <= qp_o_mux;
         when "11" => muxz_o_mux <= qc_o_mux;
         when others => null;
       end case;
    end if;
  end process prcs_mux_xz;

--####################################################################
--#####        CarryIn   1 level of register                     #####
--####################################################################

  prcs_carryinsel_mux:process(opmode_o_mux(5), CARRYIN_dly)
  begin
     if((CARRYINSEL = "CARRYIN") or (CARRYINSEL = "carryin")) then
        carryinsel_o_mux <= CARRYIN_dly;
     elsif((CARRYINSEL = "OPMODE5") or (CARRYINSEL = "opmode5")) then
        carryinsel_o_mux <= opmode_o_mux(5);
     else
        assert false
            report "Attribute Syntax Error: The allowed values for CARRYINSEL on instance DSP48A1 are CARRYIN or OPMODES."
            severity Failure;
     end if;
  end process prcs_carryinsel_mux;
------------------------------------------
  prcs_carryin_reg:process(CLK_dly, GSR_dly, RSTCARRYIN_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg1 <= '0';
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTCARRYIN_dly = '1') then
                  qcarryin_o_reg1 <= '0';
                  qcarryout_o_reg1 <= '0';
               elsif((RSTCARRYIN_dly = '0') and (CECARRYIN_dly = '1'))then
                  if(rising_edge(CLK_dly)) then
                     qcarryin_o_reg1 <= carryinsel_o_mux;
                     qcarryout_o_reg1 <= carryout_o;
                  end if;
                end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTCARRYIN_dly = '1') then
                     qcarryin_o_reg1 <= '0';
                     qcarryout_o_reg1 <= '0';
                  elsif ((RSTCARRYIN_dly = '0') and (CECARRYIN_dly = '1')) then
                      qcarryin_o_reg1 <= carryinsel_o_mux;
                      qcarryout_o_reg1 <= carryout_o;
                  end if;
               end if;
            when others => null;
         end case;
      end if;
  end process prcs_carryin_reg;
------------------------------------------------------------------
  prcs_carryin_mux:process(qcarryin_o_reg1, carryinsel_o_mux)
  begin
     case CARRYINREG is
       when 0 => carryin_o_mux <= carryinsel_o_mux;
       when 1 => carryin_o_mux <= qcarryin_o_reg1;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for CARRYINREG on instance DSP48A1 are 0 or 1"
            severity Failure;
     end case;
  end process prcs_carryin_mux;
------------------------------------------------------------------
--####################################################################
--#####         Output register P with 1 level of register       #####
--####################################################################

  prcs_qp_reg:process(CLK_dly, GSR_dly, RSTP_dly)
  begin
      if(GSR_dly = '1') then
         qp_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         case rst_async_flag is
            when '1' => 
            -----------// async reset
               if(RSTP_dly = '1') then
                  qp_o_reg <= ( others => '0');
               elsif((RSTP_dly = '0') and (CEP_dly = '1'))then
                  if(rising_edge(CLK_dly)) then
                     qp_o_reg <= accum_o;
                  end if;
                end if;
            when '0' => 
            -----------// sync reset
               if(rising_edge(CLK_dly)) then
                  if(RSTP_dly = '1') then
                     qp_o_reg <= ( others => '0');
                  elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
                      qp_o_reg <= accum_o;
                  end if;
               end if;
            when others => null;
         end case;
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
           report "Attribute Syntax Error: The allowed values for PREG on instace X_MDPS1 are 0 or 1"
           severity Failure;
     end case;
   
  end process prcs_qp_mux;
--####################################################################
--#####                   ZERO_DELAY_OUTPUTS                     #####
--####################################################################
  prcs_zero_delay_outputs:process(qb_o_mux, qp_o_mux, mult_o_mux, qcarryout_o_mux)
  begin
    BCOUT_zd     <= qb_o_mux;
    CARRYOUT_zd  <= qcarryout_o_mux;
    CARRYOUTF_zd <= qcarryout_o_mux;
    M_zd         <= mult_o_mux;
    P_zd         <= qp_o_mux;
    PCOUT_zd     <= qp_o_mux;
  end process prcs_zero_delay_outputs;

--####################################################################
--#####                OPMODE DRC                                #####
--####################################################################

  prcs_opmode_drc:process(opmode_o_mux, carryinsel_attr,
                       muxx_o_mux, muxz_o_mux, carryin_o_mux)
  variable Message : line;
  variable invalid_opmode_flg : boolean := true;
  variable opmode_valid_var : boolean := true;
  variable opmode_carryinsel_var : std_logic_vector(8 downto 0) := (others => '0');
  variable accum_o_tmp : std_logic_vector(MAX_ACCUM downto 0) := (others => '0');
  begin
      opmode_carryinsel_var := opmode_o_mux & carryinsel_attr;
      case opmode_carryinsel_var is
               when "000000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111100000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111000001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111100001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111000100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111000101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111100100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111100101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111000110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111000111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111100110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111100111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111000010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111100010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111100011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111001001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111101000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111101001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111001100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111001101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111101100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111101101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111001110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111001111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111101110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111101111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111001010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111101010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111101011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110000" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110001" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110110" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110111" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111010011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110010" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111110011" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111011001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111111001" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "001111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "010111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "011111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "100111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "101111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "110111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111011100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111011101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111111100" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "111111101" => 
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), CARRYINSEL);
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "000011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111011110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111011111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111011010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111111010" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "000111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "001111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "010111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "011111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "100111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "101111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "110111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111111110" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "111111111" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
                when others    =>
                          if(invalid_opmode_flg = true) then
                             invalid_opmode_flg := false;
                             opmode_valid_var := false;
                             output_x_sig <= '1';
                             accum_o <= (others => 'X');
                             Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
                             Write ( Message,  slv_to_str(opmode_o_mux));
                             Write ( Message, string'(" with CARRYINSEL  "));
                             Write ( Message,  CARRYINSEL);
                             Write ( Message, string'(" to DSP48A1 instance"));
                             Write ( Message, string'(" is invalid for that specific OPMODE."));
                             assert false report Message.all severity Warning;
                             DEALLOCATE (Message);
                           end if;
      end case;

      opmode_valid_flg <= opmode_valid_var;

      if(opmode_valid_var) then 
         if(opmode_o_mux(7) = '0') then
            accum_o_tmp :=  ('0'& muxz_o_mux) + ('0'& muxx_o_mux) + carryin_o_mux;
         elsif(opmode_o_mux(7) = '1') then
            accum_o_tmp :=  ('0'& muxz_o_mux) - ('0'& muxx_o_mux) - carryin_o_mux;
         end if;

         accum_o <= accum_o_tmp(MSB_ACCUM downto 0);
--         CARRYOUT_zd  <= accum_o_tmp(MAX_ACCUM);
--         CARRYOUTF_zd <= accum_o_tmp(MAX_ACCUM);
           carryout_o <= accum_o_tmp(MAX_ACCUM);
      end if;
  end process prcs_opmode_drc;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(BCOUT_zd, CARRYOUT_zd, CARRYOUTF_zd, M_zd, PCOUT_zd, P_zd)
  begin
      BCOUT      <= BCOUT_zd after SYNC_PATH_DELAY;
      CARRYOUT   <= CARRYOUT_zd after SYNC_PATH_DELAY;
      CARRYOUTF  <= CARRYOUTF_zd after SYNC_PATH_DELAY;
      M          <= M_zd     after SYNC_PATH_DELAY;
      P          <= P_zd     after SYNC_PATH_DELAY;
      PCOUT      <= PCOUT_zd after SYNC_PATH_DELAY;
  end process prcs_output;



end DSP48A1_V;

