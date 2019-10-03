-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  18X18 Signed Multiplier Followed by Three-Input Adder plus ALU with Pipeline Registers
-- /___/   /\     Filename : DSP48E.vhd
-- \   \  /  \    Timestamp : Mon Mar 28 22:50:04 PST 2005
--  \___\/\___\
--
-- Revision:
--    03/28/05 - Initial version.
--    05/26/05 - BTrack 191 mult not valid in TWO24/FOUR12/USE_MULT=NONE.
--    06/16/05 - Added MULTSIGNIN/OUT pins and functionality
--    09/29/05 - Made xyz muxes to be sensitive to carryinsel when recovering from invalid opmode/carryinsel
--    10/05/05 - Added more valid DRC check entries.
--    10/25/05 - CR 219047
--    11/03/05 - Added two DRC checks -- ARITHMETIC and LOGIC
--    11/07/05 - 'X'ed out carrycascout in LOGIC modes (like the carryout)
--    11/21/05 - 'X'ed out pattern detect signals when in illegal opmodes.
--    02/28/06 - CR 225886 -- USE_MULT check updates. 
--    02/28/06 - CR 226267 -- Changed USE_MULT default to MULT_S.
--    05/20/06 - CR 230656 -- Disabled RSTP timing check during GSR.
--    05/29/06 - CR 232187 -- Corrected multcarryinreg CASE statement 
--    05/29/06 - CR 232275 -- Corrected PREG/multsignout_o_mux
--    10/29/06 - CR 424959 -- Corrected unisim false violation warnings
--    12/10/06 - CR 429825 -- Added Timing Checks for CARRYCASCIN.
--    02/20/07 - CR 434192 -- Fixed RSTALUMODE issue
--    06/11/07 - Added SIM_MODE -- FAST/SAFE feature
--    06/29/07 - CR 438456 -- Added DRC to output X when USE_MULT=MULT_S is set and not using the multiplier opmode through muxX 
--    08/06/07 - CR 445673 -- Fixed CARRYCASCOUT registered mode issue
--    10/01/07 - CR 448147 -- Fixed error introduced by 438456
--    10/10/07 - CR 451453 -- DRC warning
--    10/15/07 - CR 444150 -- DRC check enhancements for OPMODEREG/CARRYINSELREG 
--    11/06/07 - CR 451178 -- DRC warning enhancement
--    02/06/08 - CR 455601 -- DRC relax for OPMODEREG/CARRYINSELREG
--    04/07/08 - CR 469973 -- Header Description fix
--    05/27/08 - CR 472154 -- Removed Vital GSR constructs
--    10/23/08 - CR 491227 -- Fixed multsignout_o_reg
--    12/03/08 - CR 497513 -- Fixed macc ext mode
--    01/08/09 - CR 501854 -- Fixed invalid pdet comparison when there is a X in pattern.
--    10/04/11 - CR 619940 -- Enhanced DRC warning
--    11/04/11 - CR 632559 -- Fixed issues caused by 619940
-- End Revision
----- CELL DSP48E -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library STD;
use STD.TEXTIO.all;


library unisim;
use unisim.vpkg.all;

entity DSP48E is

  generic(

        SIM_MODE	: string		:= "SAFE";

        ACASCREG	: integer		:= 1;
        ALUMODEREG	: integer		:= 1;
        AREG		: integer		:= 1;
        AUTORESET_PATTERN_DETECT		: boolean		:= FALSE;
        AUTORESET_PATTERN_DETECT_OPTINV		: string		:= "MATCH";
        A_INPUT		: string		:= "DIRECT";
        BCASCREG	: integer		:= 1;
        BREG		: integer		:= 1;
        B_INPUT		: string		:= "DIRECT";
        CARRYINREG	: integer		:= 1;
        CARRYINSELREG	: integer		:= 1;
        CREG		: integer		:= 1;
        MASK            : bit_vector            := X"3FFFFFFFFFFF";
        MREG		: integer		:= 1;
        MULTCARRYINREG	: integer		:= 1;
        OPMODEREG	: integer		:= 1;
        PATTERN         : bit_vector            := X"000000000000";
        PREG		: integer		:= 1;
        SEL_MASK	: string		:= "MASK";
        SEL_PATTERN	: string		:= "PATTERN";
        SEL_ROUNDING_MASK	: string	:= "SEL_MASK";
        USE_MULT	: string		:= "MULT_S";
        USE_PATTERN_DETECT	: string	:= "NO_PATDET";
        USE_SIMD	: string		:= "ONE48"
        );

  port(
        ACOUT                   : out std_logic_vector(29 downto 0);
        BCOUT                   : out std_logic_vector(17 downto 0);
        CARRYCASCOUT            : out std_ulogic;
        CARRYOUT                : out std_logic_vector(3 downto 0);
        MULTSIGNOUT             : out std_ulogic;
        OVERFLOW                : out std_ulogic;
        P                       : out std_logic_vector(47 downto 0);
        PATTERNBDETECT          : out std_ulogic;
        PATTERNDETECT           : out std_ulogic;
        PCOUT                   : out std_logic_vector(47 downto 0);
        UNDERFLOW               : out std_ulogic;

        A                       : in  std_logic_vector(29 downto 0);
        ACIN                    : in  std_logic_vector(29 downto 0);
        ALUMODE                 : in  std_logic_vector(3 downto 0);
        B                       : in  std_logic_vector(17 downto 0);
        BCIN                    : in  std_logic_vector(17 downto 0);
        C                       : in  std_logic_vector(47 downto 0);
        CARRYCASCIN             : in  std_ulogic;
        CARRYIN                 : in  std_ulogic;
        CARRYINSEL              : in  std_logic_vector(2 downto 0);
        CEA1                    : in  std_ulogic;
        CEA2                    : in  std_ulogic;
        CEALUMODE               : in  std_ulogic;
        CEB1                    : in  std_ulogic;
        CEB2                    : in  std_ulogic;
        CEC                     : in  std_ulogic;
        CECARRYIN               : in  std_ulogic;
        CECTRL                  : in  std_ulogic;
        CEM                     : in  std_ulogic;
        CEMULTCARRYIN           : in  std_ulogic;
        CEP                     : in  std_ulogic;
        CLK                     : in  std_ulogic;
        MULTSIGNIN              : in std_ulogic;
        OPMODE                  : in  std_logic_vector(6 downto 0);
        PCIN                    : in  std_logic_vector(47 downto 0);
        RSTA                    : in  std_ulogic;
        RSTALLCARRYIN           : in  std_ulogic;
        RSTALUMODE              : in  std_ulogic;
        RSTB                    : in  std_ulogic;
        RSTC                    : in  std_ulogic;
        RSTCTRL                 : in  std_ulogic;
        RSTM                    : in  std_ulogic;
        RSTP                    : in  std_ulogic
      );

end DSP48E;

-- architecture body                    --

architecture DSP48E_V of DSP48E is

    function find_x (
      lhs : in std_logic_vector (47 downto 0);
      rhs : in std_logic_vector (47 downto 0)
    ) return boolean is
    variable test_bit : std_ulogic := '0';
    variable found_x : boolean := false;
    variable i : integer := 0;
    begin

       found_x := false;

       for i in 0 to 47 loop
         test_bit := lhs(i);
         if (test_bit /= '0' and test_bit /= '1') then
              found_x := true;
         end if;
       end loop;
       for i in 0 to 47 loop
         test_bit := rhs(i);
         if (test_bit /= '0' and test_bit /= '1') then
              found_x := true;
         end if;
       end loop;
      return found_x;
    end;

    procedure invalid_opmode_preg_msg( OPMODE : IN string ; 
                                   CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48E instance "));
       Write ( Message, string'("requires attribute PREG set to 1."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_preg_msg;

    procedure invalid_opmode_preg_msg_logic( OPMODE : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" to DSP48E instance "));
       Write ( Message, string'("requires attribute PREG set to 1."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_preg_msg_logic;

    procedure invalid_opmode_mreg_msg( OPMODE : IN string ; 
                                   CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48E instance "));
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
       Write ( Message, string'(" to DSP48E instance "));
       Write ( Message, string'("requires attribute MREG set to 0."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_no_mreg_msg;



  TYPE AluFuntionType is (INVALID_ALU, ADD_ALU, ADD_XY_NOTZ_ALU, NOT_XYZC_ALU, SUBTRACT_ALU, NOT_ALU, 
                          AND_ALU, OR_ALU, XOR_ALU, NAND_ALU, NOR_ALU, 
                          XNOR_ALU, X_AND_NOT_Z_ALU, NOT_X_OR_Z_ALU, X_OR_NOT_Z_ALU,
                          X_NOR_Z_ALU, NOT_X_AND_Z_ALU);

  constant SYNC_PATH_DELAY : time := 100 ps;

  constant MAX_ACOUT      : integer    := 30;
  constant MAX_BCOUT      : integer    := 18;
  constant MAX_CARRYOUT   : integer    := 4;
  constant MAX_P          : integer    := 48;
  constant MAX_PCOUT      : integer    := 48;

  constant MAX_A          : integer    := 30;
  constant MAX_ACIN       : integer    := 30;
  constant MAX_ALUMODE    : integer    := 4;
  constant MAX_A_MULT     : integer    := 25;
  constant MAX_B          : integer    := 18;
  constant MAX_B_MULT     : integer    := 18;
  constant MAX_BCIN       : integer    := 18;
  constant MAX_C          : integer    := 48;
  constant MAX_CARRYINSEL : integer    := 3;
  constant MAX_OPMODE     : integer    := 7;
  constant MAX_PCIN       : integer    := 48;

  constant MAX_ALU_FULL   : integer    := 48;
  constant MAX_ALU_HALF   : integer    := 24;
  constant MAX_ALU_QUART  : integer    := 12;

  constant MSB_ACOUT      : integer    := MAX_ACOUT - 1;
  constant MSB_BCOUT      : integer    := MAX_BCOUT - 1;
  constant MSB_CARRYOUT   : integer    := MAX_CARRYOUT - 1;
  constant MSB_P          : integer    := MAX_P - 1;
  constant MSB_PCOUT      : integer    := MAX_PCOUT - 1;


  constant MSB_A          : integer    := MAX_A - 1;
  constant MSB_ACIN       : integer    := MAX_ACIN - 1;
  constant MSB_ALUMODE    : integer    := MAX_ALUMODE - 1;
  constant MSB_A_MULT     : integer    := MAX_A_MULT - 1;
  constant MSB_B          : integer    := MAX_B - 1;
  constant MSB_B_MULT     : integer    := MAX_B_MULT - 1;
  constant MSB_BCIN       : integer    := MAX_BCIN - 1;
  constant MSB_C          : integer    := MAX_C - 1;
  constant MSB_CARRYINSEL : integer    := MAX_CARRYINSEL - 1;
  constant MSB_OPMODE     : integer    := MAX_OPMODE - 1;
  constant MSB_PCIN       : integer    := MAX_PCIN - 1;

  constant MSB_ALU_FULL   : integer    := MAX_ALU_FULL - 1;
  constant MSB_ALU_HALF   : integer    := MAX_ALU_HALF - 1;
  constant MSB_ALU_QUART  : integer    := MAX_ALU_QUART - 1;

  constant SHIFT_MUXZ     : integer    := 17;

  signal 	A_ipd		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	ACIN_ipd	: std_logic_vector(MSB_ACIN downto 0) := (others => '0');
  signal 	ALUMODE_ipd	: std_logic_vector(MSB_ALUMODE downto 0) := (others => '0');
  signal 	B_ipd		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_ipd	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_ipd		: std_logic_vector(MSB_C downto 0)    := (others => '0');
  signal 	CARRYCASCIN_ipd	: std_logic := '0';
  signal 	CARRYIN_ipd	: std_logic := '0';
  signal 	CARRYINSEL_ipd	: std_logic_vector(MSB_CARRYINSEL downto 0)  := (others => '0');
  signal 	CEA1_ipd	: std_logic := '0';
  signal 	CEA2_ipd	: std_logic := '0';
  signal 	CEALUMODE_ipd	: std_logic := '0';
  signal 	CEB1_ipd	: std_logic := '0';
  signal 	CEB2_ipd	: std_logic := '0';
  signal 	CEC_ipd		: std_logic := '0';
  signal 	CECARRYIN_ipd	: std_logic := '0';
  signal 	CECTRL_ipd	: std_logic := '0';
  signal 	CEM_ipd		: std_logic := '0';
  signal 	CEMULTCARRYIN_ipd	: std_logic := '0';
  signal 	CEP_ipd		: std_logic := '0';
  signal 	CLK_ipd		: std_logic := '0';
  signal GSR            : std_ulogic := '0';
  signal 	GSR_ipd		: std_ulogic := '0';
  signal 	MULTSIGNIN_ipd		: std_logic := '0';
  signal 	OPMODE_ipd	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_ipd	: std_logic_vector(MSB_PCIN downto 0) := (others => '0');
  signal 	RSTA_ipd	: std_logic := '0';
  signal 	RSTALLCARRYIN_ipd	: std_logic := '0';
  signal 	RSTALUMODE_ipd	: std_logic := '0';
  signal 	RSTB_ipd	: std_logic := '0';
  signal 	RSTC_ipd	: std_logic := '0';
  signal 	RSTCTRL_ipd	: std_logic := '0';
  signal 	RSTM_ipd	: std_logic := '0';
  signal 	RSTP_ipd	: std_logic := '0';

  signal 	A_dly		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	ACIN_dly	: std_logic_vector(MSB_ACIN downto 0) := (others => '0');
  signal 	ALUMODE_dly	: std_logic_vector(MSB_ALUMODE downto 0) := (others => '0');
  signal 	B_dly		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_dly	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_dly		: std_logic_vector(MSB_C downto 0)    := (others => '0');
  signal 	CARRYCASCIN_dly	: std_logic := '0';
  signal 	CARRYIN_dly	: std_logic := '0';
  signal 	CARRYINSEL_dly	: std_logic_vector(MSB_CARRYINSEL downto 0)  := (others => '0');
  signal 	CEA1_dly	: std_logic := '0';
  signal 	CEA2_dly	: std_logic := '0';
  signal 	CEALUMODE_dly	: std_logic := '0';
  signal 	CEB1_dly	: std_logic := '0';
  signal 	CEB2_dly	: std_logic := '0';
  signal 	CEC_dly		: std_logic := '0';
  signal 	CECARRYIN_dly	: std_logic := '0';
  signal 	CECTRL_dly	: std_logic := '0';
  signal 	CEM_dly		: std_logic := '0';
  signal 	CEMULTCARRYIN_dly	: std_logic := '0';
  signal 	CEP_dly		: std_logic := '0';
  signal 	CLK_dly		: std_logic := '0';
  signal 	GSR_dly		: std_logic := '0';
  signal 	MULTSIGNIN_dly	: std_logic := '0';
  signal 	OPMODE_dly	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_dly	: std_logic_vector(MSB_PCIN downto 0) := (others => '0');
  signal 	RSTA_dly	: std_logic := '0';
  signal 	RSTALLCARRYIN_dly	: std_logic := '0';
  signal 	RSTALUMODE_dly	: std_logic := '0';
  signal 	RSTB_dly	: std_logic := '0';
  signal 	RSTC_dly	: std_logic := '0';
  signal 	RSTCTRL_dly	: std_logic := '0';
  signal 	RSTM_dly	: std_logic := '0';
  signal 	RSTP_dly	: std_logic := '0';


  signal	ACOUT_zd	: std_logic_vector(MSB_ACOUT downto 0) := (others => '0');
  signal	BCOUT_zd	: std_logic_vector(MSB_BCOUT downto 0) := (others => '0');
  signal 	CARRYCASCOUT_zd	: std_logic := '0';
  signal	CARRYOUT_zd	: std_logic_vector(MSB_CARRYOUT downto 0) := (others => '0');
  signal 	OVERFLOW_zd	: std_logic := '0';
  signal	P_zd		: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal 	PATTERNBDETECT_zd	: std_logic := '0';
  signal 	PATTERNDETECT_zd	: std_logic := '0';
  signal	PCOUT_zd	: std_logic_vector(MSB_PCOUT downto 0) := (others => '0');
  signal 	UNDERFLOW_zd	: std_logic := '0';
  signal 	MULTSIGNOUT_zd	: std_logic;
  
  --- Internal Signal Declarations
  signal	a_o_mux		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_reg1	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_reg2	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_mux	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qacout_o_mux	: std_logic_vector(MSB_ACOUT downto 0) := (others => '0');

  signal	b_o_mux		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg1	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg2	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_mux	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qbcout_o_mux	: std_logic_vector(MSB_BCOUT downto 0) := (others => '0');

  signal	qc_o_reg        : std_logic_vector(MSB_C downto 0) := (others => '0');
  signal	qc_o_mux	: std_logic_vector(MSB_C downto 0) := (others => '0');

  signal	mult_o_int	: std_logic_vector((MSB_A_MULT + MSB_B_MULT + 1) downto 0) := (others => '0');
  signal	mult_o_reg	: std_logic_vector((MSB_A_MULT + MSB_B_MULT + 1) downto 0) := (others => '0');
  signal	mult_o_mux	: std_logic_vector((MSB_A_MULT + MSB_B_MULT + 1) downto 0) := (others => '0');

  signal	opmode_o_reg	: std_logic_vector(MSB_OPMODE downto 0) := (others => '0');
  signal	opmode_o_mux	: std_logic_vector(MSB_OPMODE downto 0) := (others => '0');

  signal	muxx_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	muxy_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	muxz_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');

  signal	carryinsel_o_reg	: std_logic_vector(MSB_CARRYINSEL downto 0) := (others => '0');
  signal	carryinsel_o_mux	: std_logic_vector(MSB_CARRYINSEL downto 0) := (others => '0');

  signal	qcarryin_o_reg0	: std_logic := '0';
  signal	carryin_o_mux0	: std_logic := '0';
  signal	qcarryin_o_reg7	: std_logic := '0';
  signal	carryin_o_mux7	: std_logic := '0';

  signal	carryin_o_mux	: std_logic := '0';

  signal	qp_o_reg	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	qp_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');

  signal	reg_p_int       : std_logic_vector(47 downto 0) := (others => '0');
  signal	p_o_int         : std_logic_vector(47 downto 0) := (others => '0');

  signal	output_x_sig	: std_logic := '0';

  signal	RST_META          : std_logic := '0';

  signal	DefDelay          : time := 10 ps;

  signal	opmode_valid_flg   : boolean := true;
  signal	alumode_valid_flg  : boolean := true;

  signal	AluFunction	: AluFuntionType := INVALID_ALU;

  signal	alumode_o_reg	: std_logic_vector(MSB_ALUMODE downto 0) := (others => '0');
  signal	alumode_o_mux	: std_logic_vector(MSB_ALUMODE downto 0) := (others => '0');

  signal	carrycascout_o  : std_logic := '0';
  signal	carrycascout_o_reg  : std_logic := '0';
  signal	carrycascout_o_mux  : std_logic := '0';
  signal	carryout_o	: std_logic_vector(MSB_CARRYOUT downto 0) := (others => '0');
  signal	carryout_o_reg	: std_logic_vector(MSB_CARRYOUT downto 0) := (others => '0');
  signal	carryout_o_mux	: std_logic_vector(MSB_CARRYOUT downto 0) := (others => '0');
  signal        carryout_x_o    : std_logic_vector(MSB_CARRYOUT downto 0) := (others => 'X');
  signal	overflow_o      : std_logic := '0';
  signal	pdetb_o         : std_logic := '0';
  signal	pdetb_o_reg1    : std_logic := '0';
  signal	pdetb_o_reg2    : std_logic := '0';
  signal	pdet_o          : std_logic := '0';
  signal	pdet_o_reg1     : std_logic := '0';
  signal	pdet_o_reg2     : std_logic := '0';
  signal	underflow_o     : std_logic := '0';

  signal	alu_o		: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	pattern_qp	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	mask_qp		: std_logic_vector(MSB_P downto 0) := (others => '0');

  signal        multsignout_o_reg : std_logic    := '0';
  signal        multsignout_o_mux : std_logic    := '0';
  signal        multsignout_o_opmode : std_logic := '0';

  signal	OPMODE_NUMBER	: integer		:= -1;

  signal	ping_opmode_drc_check : std_logic := '0';

begin

  A_dly          	 <= A              	after 0 ps;
  ACIN_dly       	 <= ACIN           	after 0 ps;
  ALUMODE_dly    	 <= ALUMODE        	after 0 ps;
  B_dly          	 <= B              	after 0 ps;
  BCIN_dly       	 <= BCIN           	after 0 ps;
  C_dly          	 <= C              	after 0 ps;
  CARRYCASCIN_dly	 <= CARRYCASCIN    	after 0 ps;
  CARRYIN_dly    	 <= CARRYIN        	after 0 ps;
  CARRYINSEL_dly 	 <= CARRYINSEL     	after 0 ps;
  CEA1_dly       	 <= CEA1           	after 0 ps;
  CEA2_dly       	 <= CEA2           	after 0 ps;
  CEALUMODE_dly  	 <= CEALUMODE      	after 0 ps;
  CEB1_dly       	 <= CEB1           	after 0 ps;
  CEB2_dly       	 <= CEB2           	after 0 ps;
  CEC_dly        	 <= CEC            	after 0 ps;
  CECARRYIN_dly  	 <= CECARRYIN      	after 0 ps;
  CECTRL_dly     	 <= CECTRL         	after 0 ps;
  CEM_dly        	 <= CEM            	after 0 ps;
  CEMULTCARRYIN_dly	 <= CEMULTCARRYIN  	after 0 ps;
  CEP_dly        	 <= CEP            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  MULTSIGNIN_dly 	 <= MULTSIGNIN     	after 0 ps;
  OPMODE_dly     	 <= OPMODE         	after 0 ps;
  PCIN_dly       	 <= PCIN           	after 0 ps;
  RSTA_dly       	 <= RSTA           	after 0 ps;
  RSTALLCARRYIN_dly	 <= RSTALLCARRYIN  	after 0 ps;
  RSTALUMODE_dly 	 <= RSTALUMODE     	after 0 ps;
  RSTB_dly       	 <= RSTB           	after 0 ps;
  RSTC_dly       	 <= RSTC           	after 0 ps;
  RSTCTRL_dly    	 <= RSTCTRL        	after 0 ps;
  RSTM_dly       	 <= RSTM           	after 0 ps;
  RSTP_dly       	 <= RSTP           	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

standard_model : if (SIM_MODE = "SAFE") generate 
--####################################################################
--#####                        Initialization                      ###
--####################################################################
 prcs_init:process
  begin

----------- Checks for AREG ----------------------
    case AREG is
      when 0|1|2 =>
      when others =>
         assert false
         report "Attribute Syntax Error: The allowed values for AREG are 0 or 1 or 2"
         severity Failure;
    end case;

----------- Checks for ACASCREG and (ACASCREG vs AREG) ----------------------
      
    case AREG is
      when 0 => if(AREG /= ACASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute ACASCREG on DSP48E has to be set to 0 when attribute AREG = 0."
              severity Failure;
           end if;
      when 1 => if(AREG /= ACASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute ACASCREG on DSP48E has to be set to 1 when attribute AREG = 1."
              severity Failure;
           end if;
      when 2 => if((AREG /= ACASCREG) and ((AREG-1) /= ACASCREG))then
              assert false
              report "Attribute Syntax Error : The attribute ACASCREG on DSP48E has to be set to either 2 or 1 when attribute AREG = 2."
              severity Failure;
           end if;
      when others => null;
    end case;

----------- Checks for BREG ----------------------
    case BREG is
      when 0|1|2 =>
      when others =>
         assert false
         report "Attribute Syntax Error: The allowed values for BREG are 0 or 1 or 2"
         severity Failure;
    end case;

----------- Checks for BCASCREG and (BCASCREG vs BREG) ----------------------

    case BREG is
      when 0 => if(BREG /= BCASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute BCASCREG on DSP48E has to be set to 0 when attribute BREG = 0."
              severity Failure;
           end if;
      when 1 => if(BREG /= BCASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute BCASCREG on DSP48E has to be set to 1 when attribute BREG = 1."
              severity Failure;
           end if;
      when 2 => if((BREG /= BCASCREG) and ((BREG-1) /= BCASCREG))then
              assert false
              report "Attribute Syntax Error : The attribute BCASCREG on DSP48E has to be set to either 2 or 1 when attribute BREG = 2."
              severity Failure;
           end if;
      when others => null;
    end case;

----------- Check for AUTORESET_OVER_UNDER_FLOW ----------------------

--   case AUTORESET_OVER_UNDER_FLOW is
--      when true | false => null;
--      when others =>
--         assert false
--         report "Attribute Syntax Error: The allowed values for AUTORESET_OVER_UNDER_FLOW are true or fasle"
--         severity Failure;
--    end case;
         
----------- Check for AUTORESET_PATTERN_DETECT ----------------------

    case AUTORESET_PATTERN_DETECT is
      when true | false => null;
      when others =>
         assert false
         report "Attribute Syntax Error: The allowed values for AUTORESET_PATTERN_DETECT are true or fasle"
         severity Failure;
    end case;
         
----------- Check for AUTORESET_PATTERN_DETECT_OPTINV ----------------------

    if((AUTORESET_PATTERN_DETECT_OPTINV /="MATCH") and (AUTORESET_PATTERN_DETECT_OPTINV /="NOT_MATCH")) then
        assert false
        report "Attribute Syntax Error: The allowed values for AUTORESET_PATTERN_DETECT_OPTINV are MATCH or NOT_MATCH."
        severity Failure;
    end if;

----------- Check for USE_MULT ----------------------

     if((USE_MULT /="NONE") and (USE_MULT /="MULT") and
        (USE_MULT /="MULT_S")) then
        assert false
        report "Attribute Syntax Error: The allowed values for USE_MULT are NONE, MULT or MULT_S."
        severity Failure;
     elsif((USE_MULT ="MULT") and (MREG /= 0)) then
        assert false
        report "Attribute Syntax Error: The attribute USE_MULT on DSP48 is set to MULT. This requires attribute MREG to be set to 0."
        severity Failure;
     elsif((USE_MULT ="MULT_S") and (MREG /= 1)) then
        assert false
        report "Attribute Syntax Error: The attribute USE_MULT on DSP48 is set to MULT_S. This requires attribute MREG to be set to 1."
        severity Failure;
     end if;

----------- Check for USE_PATTERN_DETECT ----------------------

    if((USE_PATTERN_DETECT /="PATDET") and (USE_PATTERN_DETECT /="NO_PATDET")) then
        assert false
        report "Attribute Syntax Error: The allowed values for USE_PATTERN_DETECT are PATDET or NO_PATDET."
        severity Failure;
    end if;

--*********************************************************
--*** ADDITIONAL DRC
--*********************************************************
-- CR 219407  --  (1)
    if((AUTORESET_PATTERN_DETECT = TRUE) and (USE_PATTERN_DETECT = "NO_PATDET")) then
        assert false
        report "Attribute Syntax Error : The attribute USE_PATTERN_DETECT on DSP48E instance must be set to PATDET in order to use AUTORESET_PATTERN_DETECT equals TRUE. Failure to do so could make timing reports inaccurate. "
        severity Warning;
    end if;
------------------------------------------------------------
    ping_opmode_drc_check   <= '1' after 100010 ps;
------------------------------------------------------------

    wait;
  end process prcs_init;
--####################################################################
--#####    Input Register A with two levels of registers and a mux ###
--####################################################################
  prcs_a_in:process(A_dly, ACIN_dly)
  begin
     if(A_INPUT ="DIRECT") then
        a_o_mux <= A_dly;
     elsif(A_INPUT ="CASCADE") then
        a_o_mux <= ACIN_dly;
     else
        assert false
        report "Attribute Syntax Error: The allowed values for A_INPUT are DIRECT or CASCADE."
        severity Failure;
     end if;
  end process prcs_a_in;
------------------------------------------------------------------
  prcs_qa_2lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qa_o_reg1 <= ( others => '0');
          qa_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTA_dly = '1') then
               qa_o_reg1 <= ( others => '0');
               qa_o_reg2 <= ( others => '0');
            elsif (RSTA_dly = '0') then
               case AREG is
                    when 1 =>
                       if(CEA2_dly = '1') then
                          qa_o_reg2 <= a_o_mux;
                       end if;
                    when 2 =>
                       if(CEA1_dly = '1') then
                          qa_o_reg1 <= a_o_mux;
                       end if;
                       if(CEA2_dly = '1') then
                          qa_o_reg2 <= qa_o_reg1;
                       end if;
                    when others => null;
               end case;
            end if;
         end if;
      end if;
  end process prcs_qa_2lvl;
------------------------------------------------------------------
  prcs_qa_o_mux:process(a_o_mux, qa_o_reg2)
  begin
     case AREG is
       when 0   => qa_o_mux <= a_o_mux;
       when 1|2 => qa_o_mux <= qa_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for AREG are 0 or 1 or 2"
            severity Failure;
     end case;
  end process prcs_qa_o_mux;
------------------------------------------------------------------
  prcs_qacout_o_mux:process(qa_o_mux, qa_o_reg1)
  begin
     case ACASCREG is
       when 1 => case AREG is
                   when 2 => qacout_o_mux <= qa_o_reg1;
                   when others =>  qacout_o_mux <= qa_o_mux;
                 end case;
       when others =>  qacout_o_mux <= qa_o_mux;
     end case;

  end process prcs_qacout_o_mux;
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
            if(RSTB_dly = '1') then
               qb_o_reg1 <= ( others => '0');
               qb_o_reg2 <= ( others => '0');
            elsif (RSTB_dly = '0') then
               case BREG is
                    when 1 =>
                       if(CEB2_dly = '1') then
                          qb_o_reg2 <= b_o_mux;
                       end if;
                    when 2 =>
                       if(CEB1_dly = '1') then
                          qb_o_reg1 <= b_o_mux;
                       end if;
                       if(CEB2_dly = '1') then
                          qb_o_reg2 <= qb_o_reg1;
                       end if;
                    when others => null;
               end case;
            end if;
         end if;
      end if;
  end process prcs_qb_2lvl;
------------------------------------------------------------------
  prcs_qb_o_mux:process(b_o_mux, qb_o_reg2)
  begin
     case BREG is
       when 0   => qb_o_mux <= b_o_mux;
       when 1|2 => qb_o_mux <= qb_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for BREG are 0 or 1 or 2 "
            severity Failure;
     end case;

  end process prcs_qb_o_mux;
------------------------------------------------------------------
  prcs_qbcout_o_mux:process(qb_o_mux, qb_o_reg1)
  begin
     case BCASCREG is
       when 1 => case BREG is
                   when 2 => qbcout_o_mux <= qb_o_reg1;
                   when others =>  qbcout_o_mux <= qb_o_mux;
                 end case;
       when others =>  qbcout_o_mux <= qb_o_mux;
     end case;
  end process prcs_qbcout_o_mux;

--####################################################################
--#####    Input Register C with 0, 1, level of registers        #####
--####################################################################
  prcs_qc_1lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qc_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
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
--###################      25x18 Multiplier     ######################
--####################################################################
--
-- 05/26/05 -- FP -- Added warning for invalid mult when USE_MULT=NONE
-- SIMD=FOUR12 and SIMD=TWO24
-- Made mult_o to be "X"
--
  prcs_mult:process(qa_o_mux, qb_o_mux)
  begin
     if(USE_MULT /= "NONE") then
        mult_o_int <=  qa_o_mux(MSB_A_MULT downto 0) * qb_o_mux (MSB_B_MULT downto 0);
     end if;
  end process prcs_mult;
------------------------------------------------------------------
  prcs_mult_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         mult_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
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
  prcs_mux_xyz:process(opmode_o_mux, qp_o_mux, qa_o_mux, qb_o_mux, mult_o_mux, 
                       qc_o_mux, PCIN_dly, output_x_sig, MULTSIGNIN_dly)
  begin
    if(output_x_sig = '1') then
      muxx_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxy_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxz_o_mux(MSB_P downto 0) <= ( others => 'X');
    elsif(output_x_sig = '0') then
    --MUX_X -----
       case opmode_o_mux(1 downto 0) is
         when "00" => muxx_o_mux <= ( others => '0');
         -- FP ?? sign extend needed from 43rd bit to 48th bit 
         when "01" => muxx_o_mux((MSB_A_MULT + MSB_B_MULT +1) downto 0) <= mult_o_mux;
                   if(mult_o_mux(MSB_A_MULT + MSB_B_MULT + 1) = '1') then
                     muxx_o_mux(MSB_PCIN downto (MAX_A_MULT + MAX_B_MULT)) <=  ( others => '1');
                   elsif (mult_o_mux(MSB_A_MULT + MSB_B_MULT + 1) = '0') then
                     muxx_o_mux(MSB_PCIN downto (MAX_A_MULT + MAX_B_MULT)) <=  ( others => '0');
                   end if;
         when "10" => muxx_o_mux <= qp_o_mux;

-- CR 438456  & CR 448147 & CR 451453
         when "11" => if((USE_MULT = "MULT_S") and (AREG=0 or BREG=0)) then 
                          muxx_o_mux(MSB_P downto 0) <=  ( others => 'X');  
                          assert false
                          report "DRC warning: When attribute USE_MULT on DSP48E instance %m is set to MULT_S, the A:B opmode selection is not permitted when AREG or BREG=0. If the multiplier is not used, set USE_MULT = NONE. For dynamic switching between multiply and add operation, set AREG and BREG=1 or MREG=0 and USE_MULT=MULT."
                          severity Warning;
                      else
                          muxx_o_mux(MSB_P downto 0)  <= (qa_o_mux & qb_o_mux);
                      end if;

         when others => null;
       end case;

    --MUX_Y -----
       case opmode_o_mux(3 downto 2) is
         when "00" => muxy_o_mux <= ( others => '0');
         when "01" => muxy_o_mux <= ( others => '0');
         when "10" => 
                     if(opmode_o_mux(6 downto 4) = "100") then
                        muxy_o_mux <= ( others => MULTSIGNIN_dly);
                     else
                        muxy_o_mux <= ( others => '1');
                     end if;
         when "11" => muxy_o_mux <= qc_o_mux;
         when others => null;
       end case;
    --MUX_Z -----
       case opmode_o_mux(6 downto 4) is
         when "000" => muxz_o_mux <= ( others => '0');
         when "001" => muxz_o_mux <= PCIN_dly;
         when "010" => muxz_o_mux <= qp_o_mux;
         when "011" => muxz_o_mux <= qc_o_mux;
         when "100" => muxz_o_mux <= qp_o_mux; -- Used for MACC extend -- multsignin
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
                       muxz_o_mux ((MSB_P - SHIFT_MUXZ) downto 0) <= qp_o_mux(MSB_P downto SHIFT_MUXZ ); 
                      
         when "111" => null;
         when others => null;
       end case;
    end if;
  end process prcs_mux_xyz;
--####################################################################
--#####                        Alumode                          #####
--####################################################################
  prcs_alumode_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         alumode_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTALUMODE_dly = '1') then
               alumode_o_reg <= ( others => '0');
            elsif ((RSTALUMODE_dly = '0') and (CEALUMODE_dly = '1'))then
               alumode_o_reg <= ALUMODE_dly;
            end if;
         end if;
      end if;
  end process prcs_alumode_reg;
------------------------------------------------------------------
  prcs_alumode_mux:process(alumode_o_reg, ALUMODE_dly)
  begin
     case ALUMODEREG is
      when 0 => alumode_o_mux <= ALUMODE_dly;
      when 1 => alumode_o_mux <= alumode_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for ALUMODEREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_alumode_mux;

--####################################################################
--#####                     CarryInSel                           #####
--####################################################################
  prcs_carryinsel_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         carryinsel_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
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

------------------------------------------------------------------
-- CR 219047 (3)

  prcs_carryinsel_drc:process(carryinsel_o_mux, MULTSIGNIN_dly, opmode_o_mux)
  begin
     if(carryinsel_o_mux = "010") then
        if(not((MULTSIGNIN_dly = 'X') or ((opmode_o_mux = "1001000") and (MULTSIGNIN_dly /= 'X')) 
                                 or ((MULTSIGNIN_dly = '0') and (CARRYCASCIN_dly = '0')))) then
           assert false
-- CR 451178 -- DRC warning Enhancement
-- CR 619940 -- Enhanced DRC warning
-- CR 632559 fixed 619940 -- Enhanced DRC warning
           report "DRC warning : CARRYCASCIN can only be used in the current DSP48E instance if the previous DSP48E  is performing a two input ADD operation, or the current DSP48E is configured in the MAC extend opmode(6:0) equals 1001000. This warning can be also triggered if OPMODEREG is set to 1 and CARRYINSELREG is set to 0 - in which case please set CARRYINSELREG to 1.\n DRC warning note : The simulation model does not know the placement of the DSP48E slices used, so it cannot fully confirm the above warning. It is necessary to view the placement of the DSP48E slices and ensure that these warnings are not being breached\n"
           severity Warning;
        end if;
     end if;
  end process prcs_carryinsel_drc;

-- CR 219047 (4)
  prcs_carryinsel_mac_drc:process(carryinsel_o_mux)
  begin
     if((carryinsel_o_mux = "110")  and (MULTCARRYINREG /= MREG)) then
        assert false
        report "Attribute Syntax Warning : It is recommended that MREG and MULTCARRYINREG on DSP48E instance be set to the same value when using CARRYINSEL = 110 for multiply rounding. "
        severity Warning;
     end if;
  end process prcs_carryinsel_mac_drc;


--####################################################################
--#####                       CarryIn                            #####
--####################################################################

-------  input 0

  prcs_carryin_reg0:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg0 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTALLCARRYIN_dly = '1') then
               qcarryin_o_reg0 <= '0';
            elsif((RSTALLCARRYIN_dly = '0') and (CECARRYIN_dly = '1')) then
               qcarryin_o_reg0 <= CARRYIN_dly;
            end if;
         end if;
      end if;
  end process prcs_carryin_reg0;

  prcs_carryin_mux0:process(qcarryin_o_reg0, CARRYIN_dly)
  begin
     case CARRYINREG is
       when 0 => carryin_o_mux0 <= CARRYIN_dly;
       when 1 => carryin_o_mux0 <= qcarryin_o_reg0;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for CARRYINREG are 0 or 1"
            severity Failure;
     end case;
  end process prcs_carryin_mux0;

------------------------------------------------------------------
-------  input 7

  prcs_carryin_reg7:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg7 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTALLCARRYIN_dly = '1') then
               qcarryin_o_reg7 <= '0';
            elsif((RSTALLCARRYIN_dly = '0') and (CEMULTCARRYIN_dly = '1')) then
               qcarryin_o_reg7 <= qa_o_mux(24) XNOR qb_o_mux(17);
            end if;
         end if;
      end if;
  end process prcs_carryin_reg7;

  prcs_carryin_mux7:process(qa_o_mux(24), qb_o_mux(17), qcarryin_o_reg7)
  begin
     case MULTCARRYINREG is
       when 0 => carryin_o_mux7 <= qa_o_mux(24) XNOR qb_o_mux(17);
-- CR 232187
       when 1 => carryin_o_mux7 <= qcarryin_o_reg7;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for MULTCARRYINREG are 0 or 1"
            severity Failure;
     end case;
  end process prcs_carryin_mux7;

------------------------------------------------------------------
-- FP Check this with VV 
------------------------------------------------------------------
-- 
  prcs_carryin_mux:process(carryin_o_mux0, PCIN_dly(47), CARRYCASCIN_dly, carrycascout_o_mux, qp_o_mux(47), carryin_o_mux7, carryinsel_o_mux)
  begin
     case carryinsel_o_mux is
       when "000" => carryin_o_mux  <= carryin_o_mux0;
       when "001" => carryin_o_mux  <= NOT PCIN_dly(47);
       when "010" => carryin_o_mux  <= CARRYCASCIN_dly;
       when "011" => carryin_o_mux  <= PCIN_dly(47);
       when "100" => carryin_o_mux  <= carrycascout_o_mux;
       when "101" => carryin_o_mux  <= NOT qp_o_mux(47);
       when "110" => carryin_o_mux  <= carryin_o_mux7;
       when "111" => carryin_o_mux  <= qp_o_mux(47);
       when others => null;
     end case;
  end process prcs_carryin_mux;
--####################################################################
--#####                         ALU                              #####
--####################################################################
  prcs_alu:process(muxx_o_mux, muxy_o_mux, muxz_o_mux, alumode_o_mux, opmode_o_mux, carryin_o_mux, output_x_sig)

  variable opmode_alu_var : std_logic_vector(5 downto 0) := (others => '0');
  variable alu_full_tmp   : std_logic_vector(MAX_ALU_FULL downto 0) := (others => '0');
  variable alu_hlf1_tmp, alu_hlf2_tmp  : std_logic_vector(MAX_ALU_HALF downto 0) := (others => '0');
  variable alu_qrt1_tmp, alu_qrt2_tmp, alu_qrt3_tmp, alu_qrt4_tmp : std_logic_vector(MAX_ALU_QUART downto 0) := (others => '0');

  begin
     if(output_x_sig = '1') then
       alu_o <= (others => 'X');

     elsif(opmode_valid_flg) then
        opmode_alu_var := opmode_o_mux(3 downto 2) & alumode_o_mux;
        case opmode_alu_var is
           ---------------------------------
           ------------- ADD ---------------
           ---------------------------------
           when "000000" | "010000" | "100000" | "110000" => 

               AluFunction <= ADD_ALU;
               alumode_valid_flg <= true;

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := (('0'&muxz_o_mux) + 
                                   ('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux); 
                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux);
                  alu_hlf2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)))); 
                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux);
                  alu_qrt2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))));
                  alu_qrt3_tmp := (('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))));
                  alu_qrt4_tmp := (('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ------ SUBTRACT (X + ~Z ) ---- carryin must be 1 ---------------
           ---------------------------------
           when "000001" | "010001" | "100001" | "110001" => 

               AluFunction <= ADD_XY_NOTZ_ALU;
               alumode_valid_flg <= true;

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := NOT('0'&muxz_o_mux) + 
                                   ('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux; 
                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  NOT alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := NOT('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux;
                  alu_hlf2_tmp := NOT('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)));

                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := NOT('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux;
                  alu_qrt2_tmp := NOT('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART)));
                  alu_qrt3_tmp := NOT('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART)));
                  alu_qrt4_tmp := NOT('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART)));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  NOT alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  NOT alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ---------- NOT (X + Y + Z + C) ----------
           ---------------------------------
           when "000010" | "010010" | "100010" | "110010" => 

               AluFunction <= NOT_XYZC_ALU;
               alumode_valid_flg <= true;

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := NOT((('0'&muxz_o_mux) + 
                                   ('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux)); 

                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  NOT alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := NOT((('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_hlf2_tmp := NOT((('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)))));

                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := NOT((('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_qrt2_tmp := NOT((('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART)))));
                  alu_qrt3_tmp := NOT((('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART)))));
                  alu_qrt4_tmp := NOT((('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART)))));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  NOT alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  NOT alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ------- SUBTRACT (Z - X ) -------
           ---------------------------------
           when "000011" | "010011" | "100011" | "110011"=> 
               AluFunction <= SUBTRACT_ALU;
               alumode_valid_flg <= true;

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := (('0'&muxz_o_mux) - 
                                   (('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux)); 

                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) -
                                  (('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_hlf2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) -
                                  (('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)))));

                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) -
                                  (('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_qrt2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) -
                                  (('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART)))));
                  alu_qrt3_tmp := (('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) -
                                  (('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART)))));
                  alu_qrt4_tmp := (('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) -
                                  (('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART)))));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  NOT alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  NOT alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ------------- XOR ---------------
           ---------------------------------
           when "000100" | "000111" | "100101" | "100110" =>
                AluFunction <= XOR_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux xor muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------- XNOR ---------------
           ---------------------------------
           when "000101" | "000110" | "100100" | "100111" =>
                AluFunction <= XNOR_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux xnor muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------- AND ---------------
           ---------------------------------
           when "001100" =>
                AluFunction <= AND_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux and muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           --------- X AND (NOT Z) ---------
           ---------------------------------
           when "001101" =>
                AluFunction <= X_AND_NOT_Z_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux and (not muxz_o_mux); 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------- NAND ---------------
           ---------------------------------
           when "001110" =>
                AluFunction <= NAND_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux nand muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           -------- - (NOT X) OR Z ---------
           ---------------------------------
           when "001111" =>
                AluFunction <= NOT_X_OR_Z_ALU;
                alumode_valid_flg <= true;
                alu_o <= (not muxx_o_mux) or  muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           -------------- OR ---------------
           ---------------------------------
           when "101100" =>
                AluFunction <= OR_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux or muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           --------- X OR (NOT Z) ---------
           ---------------------------------
           when "101101" =>
                AluFunction <= X_OR_NOT_Z_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux or (not muxz_o_mux); 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------ X NOR Z ------------
           ---------------------------------
           when "101110" =>
                AluFunction <= X_NOR_Z_ALU;
                alumode_valid_flg <= true;
                alu_o <= muxx_o_mux nor  muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           --------- (NOT X) and Z ---------
           ---------------------------------
           when "101111" =>
                AluFunction <= NOT_X_AND_Z_ALU;
                alumode_valid_flg <= true;
                alu_o <= (not muxx_o_mux) and  muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';


           when others => 
                AluFunction <= INVALID_ALU;
                alumode_valid_flg <= false;

                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

        end case;
    end if;
  end process prcs_alu;
--####################################################################
--#####                CARRYOUT and CARRYCASCOUT                 #####
--####################################################################
  prcs_carry_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         carryout_o_reg     <=  ( others => '0');
         carrycascout_o_reg <=  '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if((RSTP_dly = '1') or 
               ((AUTORESET_PATTERN_DETECT) and (
                ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and pdet_o_reg1 = '1') or 
                ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and (pdet_o_reg2 = '1' and pdet_o_reg1 = '0')))
               )
              ) then
               carryout_o_reg     <= ( others => '0');
               carrycascout_o_reg <=  '0';
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               carryout_o_reg <= carryout_o;
               carrycascout_o_reg <= carrycascout_o;
            end if;
         end if;
      end if;
  end process prcs_carry_reg;
------------------------------------------------------------------
  prcs_carryout_mux:process(carryout_o, carryout_o_reg)
  begin
     case PREG is
       when 0 => carryout_o_mux <= carryout_o;
       when 1 => carryout_o_mux <= carryout_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;
   
  end process prcs_carryout_mux;

------------------------------------------------------------------
  prcs_carryout_x_o:process(carryout_o_mux)
  begin
     if(USE_SIMD = "ONE48") then
        carryout_x_o(3) <= carryout_o_mux(3);
     elsif(USE_SIMD = "TWO24") then
        carryout_x_o(3) <= carryout_o_mux(3);
        carryout_x_o(1) <= carryout_o_mux(1);
     elsif(USE_SIMD = "FOUR12") then
        carryout_x_o(3) <= carryout_o_mux(3);
        carryout_x_o(2) <= carryout_o_mux(2);
        carryout_x_o(1) <= carryout_o_mux(1);
        carryout_x_o(0) <= carryout_o_mux(0);
     end if;
  end process prcs_carryout_x_o;

------------------------------------------------------------------
  prcs_carrycascout_mux:process(carrycascout_o, carrycascout_o_reg)
  begin
     case PREG is
       when 0 => carrycascout_o_mux <= carrycascout_o;
       when 1 => carrycascout_o_mux <= carrycascout_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;
   
  end process prcs_carrycascout_mux;
------------------------------------------------------------------
-- CR 219047 (2)
  prcs_multsignout_o_opmode:process(mult_o_mux(MSB_A_MULT+MSB_B_MULT+1), opmode_o_mux(3 downto 0))
  begin
    if(opmode_o_mux(3 downto 0) = "0101") then
       multsignout_o_opmode <= mult_o_mux(MSB_A_MULT+MSB_B_MULT+1);
    else
       multsignout_o_opmode <= 'X';
    end if;
  end process prcs_multsignout_o_opmode;

  prcs_multsignout_o_mux:process(multsignout_o_opmode, multsignout_o_reg)
  begin
     case PREG is
       when 0 => multsignout_o_mux <= multsignout_o_opmode;
-- CR 232275
       when 1 => multsignout_o_mux <= multsignout_o_reg;
       when others => null;
--           assert false
--           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
--           severity Failure;
     end case;
   
  end process prcs_multsignout_o_mux;
--####################################################################
--####################################################################
--####################################################################
--#####                 PCOUT and MULTSIGNOUT                    #####
--####################################################################
  prcs_qp_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qp_o_reg <=  ( others => '0');
         multsignout_o_reg <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if((RSTP_dly = '1') or 
               ((AUTORESET_PATTERN_DETECT) and (
                ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and pdet_o_reg1 = '1') or 
                ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and (pdet_o_reg2 = '1' and pdet_o_reg1 = '0')))
               )
              ) then
               qp_o_reg <= ( others => '0');
               multsignout_o_reg <= '0';
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               qp_o_reg <= alu_o;
-- CR 491227               multsignout_o_reg <= mult_o_reg((MSB_A_MULT+MSB_B_MULT+1));
               multsignout_o_reg <= multsignout_o_opmode;
            end if;
         end if;
      end if;
  end process prcs_qp_reg;
------------------------------------------------------------------
  prcs_qp_mux:process(alu_o, qp_o_reg)
  begin
     case PREG is
       when 0 => qp_o_mux <= alu_o;
       when 1 => qp_o_mux <= qp_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;
   
  end process prcs_qp_mux;
--####################################################################
--#####                    Pattern Detector                      #####
--####################################################################
  prcs_sel_pattern_detect:process(alu_o, qc_o_mux)
  begin

     -- Select the pattern
     if((SEL_PATTERN = "PATTERN") or (SEL_PATTERN = "pattern")) then
         pattern_qp <= To_StdLogicVector(PATTERN);
     elsif((SEL_PATTERN = "C") or (SEL_PATTERN = "c")) then
         pattern_qp <= qc_o_mux;
     else 
         assert false
         report "Attribute Syntax Error: The attribute SEL_PATTERN on DSP48_ALU is incorrect. Legal values for this attribute are PATTERN or C"
         severity Failure;
     end if;

     -- Select the mask  -- if ROUNDING MASK set, use rounding mode, else use SEL_MASK
     if((SEL_ROUNDING_MASK = "SEL_MASK") or (SEL_ROUNDING_MASK = "sel_mask")) then
         if((SEL_MASK = "MASK") or (SEL_MASK = "mask")) then
             mask_qp <= To_StdLogicVector(MASK);
         elsif((SEL_MASK = "C") or (SEL_MASK = "c")) then
             mask_qp <= qc_o_mux;
         else
           assert false
           report "Attribute Syntax Error: The attribute SEL_MASK on DSP48_ALU is incorrect. Legal values for this attribute are MASK or C"
           severity Failure;
         end if;
     elsif((SEL_ROUNDING_MASK = "MODE1") or (SEL_ROUNDING_MASK = "mode1")) then
         mask_qp <=   To_StdLogicVector((To_bitvector( not qc_o_mux)) sla 1) ;
         mask_qp (0) <= '0';
     elsif((SEL_ROUNDING_MASK = "MODE2") or (SEL_ROUNDING_MASK = "mode2")) then
         mask_qp <=   To_StdLogicVector((To_bitvector( not qc_o_mux)) sla 2) ;
         mask_qp (1 downto 0) <= (others => '0');
     else
         assert false
         report "Attribute Syntax Error: The attribute SEL_ROUNDING_MASK on DSP48_ALU is incorrect. Legal values for this attribute are SEL_MASK or MODE1 or MODE2."
         severity Failure;
     end if;
     
  end process prcs_sel_pattern_detect;


---------------------------------------------------------------

  prcs_pdet:process(alu_o, mask_qp, pattern_qp, GSR_dly )
  variable x_found : boolean := false;
  variable lhs     : std_logic_vector(MSB_P downto 0) := (others => '0');
  variable rhs     : std_logic_vector(MSB_P downto 0) := (others => '0');

  begin

  --   CR 501854

       lhs := (alu_o or mask_qp);
       rhs := (pattern_qp or mask_qp);

       x_found := find_x(lhs, rhs);
 
       if(((alu_o or mask_qp) = (pattern_qp or mask_qp)) and (GSR_dly = '0') and (not x_found))then 
          pdet_o <= '1';
       else
          pdet_o <= '0';
       end if;

       if(((alu_o or mask_qp) = ((NOT pattern_qp) or mask_qp)) and (GSR_dly = '0') and (not x_found)) then 
          pdetb_o <= '1';
       else
          pdetb_o <= '0';
       end if;

  end process prcs_pdet;

---------------------------------------------------------------

  prcs_pdet_reg:process(CLK_dly, GSR_dly)
  variable pdetb_reg1_var, pdetb_reg2_var, pdet_reg1_var, pdet_reg2_var : std_ulogic := '0';  
  begin
      if(GSR_dly = '1') then
         pdetb_o_reg1 <= '0';
         pdetb_o_reg2 <= '0';
         pdet_o_reg1  <= '0';
         pdet_o_reg2  <= '0';

         pdetb_reg1_var := '0';
         pdetb_reg2_var := '0';
         pdet_reg1_var  := '0';
         pdet_reg2_var  := '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if((RSTP_dly = '1') or 
               ((AUTORESET_PATTERN_DETECT) and (
                ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and pdet_o_reg1 = '1') or 
                ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and (pdet_o_reg2 = '1' and pdet_o_reg1 = '0')))
               )
              ) then
               pdetb_o_reg1 <= '0';
               pdetb_o_reg2 <= '0';
               pdet_o_reg1  <= '0';
               pdet_o_reg2  <= '0';

               pdetb_reg1_var := '0';
               pdetb_reg2_var := '0';
               pdet_reg1_var  := '0';
               pdet_reg2_var  := '0';
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               pdetb_reg2_var := pdetb_reg1_var;
               pdetb_reg1_var := pdetb_o;

               pdet_reg2_var := pdet_reg1_var;
               pdet_reg1_var := pdet_o;

               pdetb_o_reg1 <= pdetb_reg1_var;
               pdetb_o_reg2 <= pdetb_reg2_var;
               pdet_o_reg1  <= pdet_reg1_var;
               pdet_o_reg2  <= pdet_reg2_var;

            end if;
         end if;
      end if;
  end process prcs_pdet_reg;

--####################################################################
--#####                 Underflow / Overflow                     #####
--####################################################################
  prcs_uflow_oflow:process(pdet_o_reg1 , pdet_o_reg2 , pdetb_o_reg1 , pdetb_o_reg2)
  begin
--    if(((AUTORESET_PATTERN_DETECT) and (
--       ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and (pdet_o_reg1 = '1'))  or
--       ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and ((pdet_o_reg2 = '1') and (pdet_o_reg1 = '0'))))
--      )) then
--       underflow_o <= '0';
--       overflow_o  <= '0';
--    else
--       overflow_o  <= pdet_o_reg2   AND  (NOT pdet_o_reg1)  AND  (NOT pdetb_o_reg1);
--       underflow_o <= pdetb_o_reg2  AND  (NOT pdet_o_reg1)  AND (NOT pdetb_o_reg1);
--    end if;
    if(GSR_dly = '1') then
        overflow_o  <= '0';
        underflow_o <= '0';
    elsif(USE_PATTERN_DETECT = "NO_PATDET") then
        overflow_o  <= 'X';
        underflow_o <= 'X';
    elsif(PREG = 0) then
          overflow_o  <= 'X';
          underflow_o <= 'X';
    elsif(PREG = 1) then
          overflow_o  <= pdet_o_reg2   AND  (NOT pdet_o_reg1)  AND  (NOT pdetb_o_reg1);
          underflow_o <= pdetb_o_reg2  AND  (NOT pdet_o_reg1)  AND (NOT pdetb_o_reg1);
    end if;

  end process prcs_uflow_oflow;
--####################################################################
--#####                 OPMODE DRC                               #####
--####################################################################
  prcs_opmode_drc:process(ping_opmode_drc_check, alumode_o_mux, opmode_o_mux, carryinsel_o_mux)
  variable Message : line;
  variable invalid_opmode_flg : boolean := true;
  variable opmode_valid_var : boolean := true;
  variable opmode_carryinsel_var : std_logic_vector(9 downto 0) := (others => '0');
  begin
      opmode_carryinsel_var := opmode_o_mux & carryinsel_o_mux(MSB_CARRYINSEL downto 0);
      case alumode_o_mux(3 downto 2) is
-----------------------------------------
--        ARITHMETIC MODES DRC         --
-----------------------------------------
         when "00" => 
            case opmode_carryinsel_var is
               when "0000000000" => 
                          OPMODE_NUMBER <= 1;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0000010000" => 
                          OPMODE_NUMBER <= 3;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0000010010" => 
                          OPMODE_NUMBER <= 4;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
-- CR 455601 eased the following two 
               when "0000010101" => 
                          OPMODE_NUMBER <= 50;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0000010111" => 
                          OPMODE_NUMBER <= 50;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
--
               when "0000011000" => 
                          OPMODE_NUMBER <= 7;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0000011010" => 
                          OPMODE_NUMBER <= 8;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0000011100" => 
                          OPMODE_NUMBER <= 9;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0000101000" => 
                          OPMODE_NUMBER <= 13;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001000000" => 
                          OPMODE_NUMBER <= 15;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001010000" => 
                          OPMODE_NUMBER <= 17;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001010010" => 
                          OPMODE_NUMBER <= 18;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001011000" => 
                          OPMODE_NUMBER <= 21;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001011010" => 
                          OPMODE_NUMBER <= 22;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001011100" => 
                          OPMODE_NUMBER <= 23;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001100000" => 
                          OPMODE_NUMBER <= 27;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001100010" => 
                          OPMODE_NUMBER <= 28;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001100100" => 
                          OPMODE_NUMBER <= 29;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001110000" => 
                          OPMODE_NUMBER <= 33;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001110010" => 
                          OPMODE_NUMBER <= 34;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001110101" => 
                          OPMODE_NUMBER <= 37;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001110111" => 
                          OPMODE_NUMBER <= 37;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001111000" => 
                          OPMODE_NUMBER <= 38;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001111010" => 
                          OPMODE_NUMBER <= 39;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001111100" => 
                          OPMODE_NUMBER <= 40;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010000000" => 
                          OPMODE_NUMBER <= 46;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010010000" => 
                          OPMODE_NUMBER <= 48;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0010010101" => 
                          OPMODE_NUMBER <= 50;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0010010111" => 
                          OPMODE_NUMBER <= 50;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0010011000" => 
                          OPMODE_NUMBER <= 51;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010011001" => 
                          OPMODE_NUMBER <= 53;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010011011" => 
                          OPMODE_NUMBER <= 53;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010101000" => 
                          OPMODE_NUMBER <= 55;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010101001" => 
                          OPMODE_NUMBER <= 57;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010101011" => 
                          OPMODE_NUMBER <= 57;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010101110" => 
                          OPMODE_NUMBER <= 58;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011000000" => 
                          OPMODE_NUMBER <= 59;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011010000" => 
                          OPMODE_NUMBER <= 61;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011010101" => 
                          OPMODE_NUMBER <= 63;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011010111" => 
                          OPMODE_NUMBER <= 63;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011011000" => 
                          OPMODE_NUMBER <= 64;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011011001" => 
                          OPMODE_NUMBER <= 66;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011011011" => 
                          OPMODE_NUMBER <= 66;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011100000" => 
                          OPMODE_NUMBER <= 68;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011100001" => 
                          OPMODE_NUMBER <= 70;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011100011" => 
                          OPMODE_NUMBER <= 70;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011110000" => 
                          OPMODE_NUMBER <= 72;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011110101" => 
                          OPMODE_NUMBER <= 74;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011110111" => 
                          OPMODE_NUMBER <= 74;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011110001" => 
                          OPMODE_NUMBER <= 75;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011110011" => 
                          OPMODE_NUMBER <= 75;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011111000" => 
                          OPMODE_NUMBER <= 77;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011111001" => 
                          OPMODE_NUMBER <= 79;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011111011" => 
                          OPMODE_NUMBER <= 79;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0100000000" => 
                          OPMODE_NUMBER <= 82;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100000010" => 
                          OPMODE_NUMBER <= 83;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100010000" => 
                          OPMODE_NUMBER <= 86;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100010010" => 
                          OPMODE_NUMBER <= 87;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100011000" => 
                          OPMODE_NUMBER <= 90;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100011010" => 
                          OPMODE_NUMBER <= 91;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100011101" => 
                          OPMODE_NUMBER <= 94;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100011111" => 
                          OPMODE_NUMBER <= 94;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100101000" => 
                          OPMODE_NUMBER <= 95;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100101101" => 
                          OPMODE_NUMBER <= 97;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100101111" => 
                          OPMODE_NUMBER <= 97;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101000000" => 
                          OPMODE_NUMBER <= 98;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101000010" => 
                          OPMODE_NUMBER <= 99;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101010000" => 
                          OPMODE_NUMBER <= 102;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101011000" => 
                          OPMODE_NUMBER <= 104;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101011101" => 
                          OPMODE_NUMBER <= 106;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101011111" => 
                          OPMODE_NUMBER <= 106;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101100000" => 
                          OPMODE_NUMBER <= 107;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101100010" => 
                          OPMODE_NUMBER <= 108;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101100101" => 
                          OPMODE_NUMBER <= 111;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101100111" => 
                          OPMODE_NUMBER <= 111;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101110000" => 
                          OPMODE_NUMBER <= 112;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101110101" => 
                          OPMODE_NUMBER <= 114;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101110111" => 
                          OPMODE_NUMBER <= 114;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101111000" => 
                          OPMODE_NUMBER <= 115;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101111101" => 
                          OPMODE_NUMBER <= 117;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101111111" => 
                          OPMODE_NUMBER <= 117;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0110000000" => 
                          OPMODE_NUMBER <= 120;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110000010" => 
                          OPMODE_NUMBER <= 121;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110000100" => 
                          OPMODE_NUMBER <= 122;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110010000" => 
                          OPMODE_NUMBER <= 126;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0110010010" => 
                          OPMODE_NUMBER <= 127;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0110010101" => 
                          OPMODE_NUMBER <= 130;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0110010111" => 
                          OPMODE_NUMBER <= 130;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0110011000" => 
                          OPMODE_NUMBER <= 131;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110011010" => 
                          OPMODE_NUMBER <= 132;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110011100" => 
                          OPMODE_NUMBER <= 133;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110101000" => 
                          OPMODE_NUMBER <= 139;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110101110" => 
                          OPMODE_NUMBER <= 141;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111000000" => 
                          OPMODE_NUMBER <= 143;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111000010" => 
                          OPMODE_NUMBER <= 144;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111000100" => 
                          OPMODE_NUMBER <= 145;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111010000" => 
                          OPMODE_NUMBER <= 149;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0111010101" => 
                          OPMODE_NUMBER <= 151;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0111010111" => 
                          OPMODE_NUMBER <= 151;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0111011000" => 
                          OPMODE_NUMBER <= 152;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111100000" => 
                          OPMODE_NUMBER <= 156;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111100010" => 
                          OPMODE_NUMBER <= 157;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111110000" => 
                          OPMODE_NUMBER <= 160;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0111111000" => 
                          OPMODE_NUMBER <= 162;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1001000010" => 
                          OPMODE_NUMBER <= 165;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1010000000" => 
                          OPMODE_NUMBER <= 167;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010010000" => 
                          OPMODE_NUMBER <= 169;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1010010101" => 
                          OPMODE_NUMBER <= 171;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1010010111" => 
                          OPMODE_NUMBER <= 171;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1010011000" => 
                          OPMODE_NUMBER <= 172;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010011001" => 
                          OPMODE_NUMBER <= 174;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010011011" => 
                          OPMODE_NUMBER <= 174;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010101000" => 
                          OPMODE_NUMBER <= 176;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010101001" => 
                          OPMODE_NUMBER <= 178;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010101011" => 
                          OPMODE_NUMBER <= 178;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010101110" => 
                          OPMODE_NUMBER <= 179;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011000000" => 
                          OPMODE_NUMBER <= 180;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011010000" => 
                          OPMODE_NUMBER <= 182;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011010101" => 
                          OPMODE_NUMBER <= 184;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011010111" => 
                          OPMODE_NUMBER <= 184;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011011000" => 
                          OPMODE_NUMBER <= 185;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011011001" => 
                          OPMODE_NUMBER <= 187;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011011011" => 
                          OPMODE_NUMBER <= 187;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011100000" => 
                          OPMODE_NUMBER <= 189;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011100001" => 
                          OPMODE_NUMBER <= 191;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011100011" => 
                          OPMODE_NUMBER <= 191;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011110000" => 
                          OPMODE_NUMBER <= 193;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011110101" => 
                          OPMODE_NUMBER <= 195;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011110111" => 
                          OPMODE_NUMBER <= 195;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011110001" => 
                          OPMODE_NUMBER <= 197;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011110011" => 
                          OPMODE_NUMBER <= 197;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011111000" => 
                          OPMODE_NUMBER <= 198;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011111001" => 
                          OPMODE_NUMBER <= 200;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011111011" => 
                          OPMODE_NUMBER <= 200;
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1100000000" => 
                          OPMODE_NUMBER <= 203;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100010000" => 
                          OPMODE_NUMBER <= 205;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100011000" => 
                          OPMODE_NUMBER <= 207;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100011101" => 
                          OPMODE_NUMBER <= 209;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100011111" => 
                          OPMODE_NUMBER <= 209;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100101000" => 
                          OPMODE_NUMBER <= 210;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100101101" => 
                          OPMODE_NUMBER <= 212;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100101111" => 
                          OPMODE_NUMBER <= 212;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101000000" => 
                          OPMODE_NUMBER <= 213;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101010000" => 
                          OPMODE_NUMBER <= 215;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101011000" => 
                          OPMODE_NUMBER <= 217;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101011101" => 
                          OPMODE_NUMBER <= 219;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101011111" => 
                          OPMODE_NUMBER <= 219;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101100000" => 
                          OPMODE_NUMBER <= 220;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101100101" => 
                          OPMODE_NUMBER <= 222;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101100111" => 
                          OPMODE_NUMBER <= 222;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101110000" => 
                          OPMODE_NUMBER <= 223;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101110101" => 
                          OPMODE_NUMBER <= 225;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101110111" => 
                          OPMODE_NUMBER <= 225;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101111000" => 
                          OPMODE_NUMBER <= 226;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101111101" => 
                          OPMODE_NUMBER <= 228;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101111111" => 
                          OPMODE_NUMBER <= 228;
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when others    =>
                          OPMODE_NUMBER <= -1;
                          if(invalid_opmode_flg = true) then
                             invalid_opmode_flg := false;
                             opmode_valid_var := false;
                             output_x_sig <= '1';
-- CR 444150
                             if((opmode_carryinsel_var = "0000000010") and ((OPMODEREG = 1) and (CARRYINSELREG = 0))) then
                                Write ( Message, string'("DRC Warning : The attribute CARRYINSELREG on DSP48E instance is set to 0. "));
                                Write ( Message, string'("It is required to have CARRYINSELREG be set to 1 to match OPMODEREG, "));
                                Write ( Message, string'("in order to ensure that the simulation model will match the hardware "));
                                Write ( Message, string'("behavior in all use cases."));
                                assert false report Message.all severity Warning;
                                DEALLOCATE (Message);
                             end if;

                             Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
                             Write ( Message,  slv_to_str(opmode_o_mux));
                             Write ( Message, string'(" to DSP48E instance"));
                             Write ( Message, string'(" is either invalid or the CARRYINSEL "));
                             Write ( Message,  slv_to_str(carryinsel_o_mux));
                             Write ( Message, string'(" for that specific OPMODE is invalid. "));
                             Write ( Message, string'(" This error may be due to mismatch in the OPMODEREG "));
                             Write ( Message, string'(" and CARRYINSELREG attribute settings."));
                             Write ( Message, string'(" It is recommended that OPMODEREG and CARRYINSELREG always be set to the same value."));
                             assert false report Message.all severity Warning;
                             DEALLOCATE (Message);
                           end if;
            end case;
         when "01" | "11" => 
-----------------------------------------
--          LOGIC MODES DRC            --
-----------------------------------------
            case opmode_o_mux is
               when "0000000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0000010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0000011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0010010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0010011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0100000" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0100011" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0110000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0110010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0110011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1010010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1010011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1100000" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1100011" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0001010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0001011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0011010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0101000" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0101011" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0111000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "0111010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "0111011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011000" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1011010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1011011" => 
                          invalid_opmode_flg := true ;
                          opmode_valid_var := true ;
                          output_x_sig <= '0';
               when "1101000" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101010" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
               when "1101011" => 
                          if (PREG /= 1) then
                             opmode_valid_var := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg_logic(slv_to_str(opmode_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             opmode_valid_var := true;
                             output_x_sig <= '0';
                          end if;
                when others    =>
                          OPMODE_NUMBER <= -1;
                          if(invalid_opmode_flg = true) then
                             invalid_opmode_flg := false;
                             opmode_valid_var := false;
                             output_x_sig <= '1';
                             Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
                             Write ( Message,  slv_to_str(opmode_o_mux));
                             Write ( Message, string'(" to DSP48E instance"));
                             Write ( Message, string'(" is invalid for ALU LOGIC modes."));
                             assert false report Message.all severity Warning;
                             DEALLOCATE (Message);
                           end if;
            end case;
         when others => null;
      end case;

      opmode_valid_flg <= opmode_valid_var;

  end process prcs_opmode_drc;
--####################################################################
--#####                   ZERO_DELAY_OUTPUTS                     #####
--####################################################################
  prcs_zero_delay_outputs:process(qacout_o_mux, qbcout_o_mux, carryout_x_o, carrycascout_o_mux,
                                  overflow_o, qp_o_mux, pdet_o, pdetb_o,
                                  pdet_o_reg1, pdetb_o_reg1,
                                  pdet_o_reg2, pdetb_o_reg2,
                                  underflow_o, multsignout_o_mux, opmode_valid_flg, alumode_valid_flg)
  begin
    ACOUT_zd          <= qacout_o_mux;
    BCOUT_zd          <= qbcout_o_mux;
    OVERFLOW_zd       <= overflow_o;
    UNDERFLOW_zd      <= underflow_o;
    P_zd              <= qp_o_mux;
    PCOUT_zd          <= qp_o_mux;
    MULTSIGNOUT_zd    <= multsignout_o_mux;

    if(((AUTORESET_PATTERN_DETECT) and (
       ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and (pdet_o_reg1 = '1'))  or
       ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and ((pdet_o_reg2 = '1') and (pdet_o_reg1 = '0'))))
      )) then
      CARRYCASCOUT_zd   <= '0';
      CARRYOUT_zd       <= (others => '0');
    else
      CARRYCASCOUT_zd   <= carrycascout_o_mux;   
      CARRYOUT_zd       <= carryout_x_o; 
    end if;

    if((USE_PATTERN_DETECT = "NO_PATDET") or (not opmode_valid_flg) or (not alumode_valid_flg)) then
       PATTERNBDETECT_zd <= 'X';
       PATTERNDETECT_zd  <= 'X';
    elsif (PREG = 0) then
          PATTERNBDETECT_zd <= pdetb_o;
          PATTERNDETECT_zd  <= pdet_o;
    elsif(PREG = 1) then
          PATTERNBDETECT_zd <= pdetb_o_reg1;
          PATTERNDETECT_zd  <= pdet_o_reg1;
    end if;

  end process prcs_zero_delay_outputs;

end generate; 
fast_model : if (SIM_MODE = "FAST") generate 
--####################################################################
--#####                        Initialization                      ###
--####################################################################
 prcs_init:process
  begin

----------- Checks for AREG ----------------------
    case AREG is
      when 0|1|2 =>
      when others =>
         assert false
         report "Attribute Syntax Error: The allowed values for AREG are 0 or 1 or 2"
         severity Failure;
    end case;

----------- Checks for ACASCREG and (ACASCREG vs AREG) ----------------------
      
    case AREG is
      when 0 => if(AREG /= ACASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute ACASCREG on DSP48E has to be set to 0 when attribute AREG = 0."
              severity Failure;
           end if;
      when 1 => if(AREG /= ACASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute ACASCREG on DSP48E has to be set to 1 when attribute AREG = 1."
              severity Failure;
           end if;
      when 2 => if((AREG /= ACASCREG) and ((AREG-1) /= ACASCREG))then
              assert false
              report "Attribute Syntax Error : The attribute ACASCREG on DSP48E has to be set to either 2 or 1 when attribute AREG = 2."
              severity Failure;
           end if;
      when others => null;
    end case;

----------- Checks for BREG ----------------------
    case BREG is
      when 0|1|2 =>
      when others =>
         assert false
         report "Attribute Syntax Error: The allowed values for BREG are 0 or 1 or 2"
         severity Failure;
    end case;

----------- Checks for BCASCREG and (BCASCREG vs BREG) ----------------------

    case BREG is
      when 0 => if(BREG /= BCASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute BCASCREG on DSP48E has to be set to 0 when attribute BREG = 0."
              severity Failure;
           end if;
      when 1 => if(BREG /= BCASCREG) then
              assert false
              report "Attribute Syntax Error : The attribute BCASCREG on DSP48E has to be set to 1 when attribute BREG = 1."
              severity Failure;
           end if;
      when 2 => if((BREG /= BCASCREG) and ((BREG-1) /= BCASCREG))then
              assert false
              report "Attribute Syntax Error : The attribute BCASCREG on DSP48E has to be set to either 2 or 1 when attribute BREG = 2."
              severity Failure;
           end if;
      when others => null;
    end case;

----------- Check for AUTORESET_OVER_UNDER_FLOW ----------------------

--   case AUTORESET_OVER_UNDER_FLOW is
--      when true | false => null;
--      when others =>
--         assert false
--         report "Attribute Syntax Error: The allowed values for AUTORESET_OVER_UNDER_FLOW are true or fasle"
--         severity Failure;
--    end case;
         
----------- Check for AUTORESET_PATTERN_DETECT ----------------------

    case AUTORESET_PATTERN_DETECT is
      when true | false => null;
      when others =>
         assert false
         report "Attribute Syntax Error: The allowed values for AUTORESET_PATTERN_DETECT are true or fasle"
         severity Failure;
    end case;
         
----------- Check for AUTORESET_PATTERN_DETECT_OPTINV ----------------------

    if((AUTORESET_PATTERN_DETECT_OPTINV /="MATCH") and (AUTORESET_PATTERN_DETECT_OPTINV /="NOT_MATCH")) then
        assert false
        report "Attribute Syntax Error: The allowed values for AUTORESET_PATTERN_DETECT_OPTINV are MATCH or NOT_MATCH."
        severity Failure;
    end if;

----------- Check for USE_MULT ----------------------

     if((USE_MULT /="NONE") and (USE_MULT /="MULT") and
        (USE_MULT /="MULT_S")) then
        assert false
        report "Attribute Syntax Error: The allowed values for USE_MULT are NONE, MULT or MULT_S."
        severity Failure;
     elsif((USE_MULT ="MULT") and (MREG /= 0)) then
        assert false
        report "Attribute Syntax Error: The attribute USE_MULT on DSP48 is set to MULT. This requires attribute MREG to be set to 0."
        severity Failure;
     elsif((USE_MULT ="MULT_S") and (MREG /= 1)) then
        assert false
        report "Attribute Syntax Error: The attribute USE_MULT on DSP48 is set to MULT_S. This requires attribute MREG to be set to 1."
        severity Failure;
     end if;

----------- Check for USE_PATTERN_DETECT ----------------------

    if((USE_PATTERN_DETECT /="PATDET") and (USE_PATTERN_DETECT /="NO_PATDET")) then
        assert false
        report "Attribute Syntax Error: The allowed values for USE_PATTERN_DETECT are PATDET or NO_PATDET."
        severity Failure;
    end if;

--*********************************************************
--*** ADDITIONAL DRC
--*********************************************************
-- CR 219407  --  (1)
    if((AUTORESET_PATTERN_DETECT = TRUE) and (USE_PATTERN_DETECT = "NO_PATDET")) then
        assert false
        report "Attribute Syntax Error : The attribute USE_PATTERN_DETECT on DSP48E instance must be set to PATDET in order to use AUTORESET_PATTERN_DETECT equals TRUE. Failure to do so could make timing reports inaccurate. "
        severity Warning;
    end if;
------------------------------------------------------------
    ping_opmode_drc_check   <= '1' after 100010 ps;
------------------------------------------------------------

    wait;
  end process prcs_init;
--####################################################################
--#####    Input Register A with two levels of registers and a mux ###
--####################################################################
  prcs_a_in:process(A_dly, ACIN_dly)
  begin
     if(A_INPUT ="DIRECT") then
        a_o_mux <= A_dly;
     elsif(A_INPUT ="CASCADE") then
        a_o_mux <= ACIN_dly;
     else
        assert false
        report "Attribute Syntax Error: The allowed values for A_INPUT are DIRECT or CASCADE."
        severity Failure;
     end if;
  end process prcs_a_in;
------------------------------------------------------------------
  prcs_qa_2lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qa_o_reg1 <= ( others => '0');
          qa_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTA_dly = '1') then
               qa_o_reg1 <= ( others => '0');
               qa_o_reg2 <= ( others => '0');
            elsif (RSTA_dly = '0') then
               case AREG is
                    when 1 =>
                       if(CEA2_dly = '1') then
                          qa_o_reg2 <= a_o_mux;
                       end if;
                    when 2 =>
                       if(CEA1_dly = '1') then
                          qa_o_reg1 <= a_o_mux;
                       end if;
                       if(CEA2_dly = '1') then
                          qa_o_reg2 <= qa_o_reg1;
                       end if;
                    when others => null;
               end case;
            end if;
         end if;
      end if;
  end process prcs_qa_2lvl;
------------------------------------------------------------------
  prcs_qa_o_mux:process(a_o_mux, qa_o_reg2)
  begin
     case AREG is
       when 0   => qa_o_mux <= a_o_mux;
       when 1|2 => qa_o_mux <= qa_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for AREG are 0 or 1 or 2"
            severity Failure;
     end case;
  end process prcs_qa_o_mux;
------------------------------------------------------------------
  prcs_qacout_o_mux:process(qa_o_mux, qa_o_reg1)
  begin
     case ACASCREG is
       when 1 => case AREG is
                   when 2 => qacout_o_mux <= qa_o_reg1;
                   when others =>  qacout_o_mux <= qa_o_mux;
                 end case;
       when others =>  qacout_o_mux <= qa_o_mux;
     end case;

  end process prcs_qacout_o_mux;
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
            if(RSTB_dly = '1') then
               qb_o_reg1 <= ( others => '0');
               qb_o_reg2 <= ( others => '0');
            elsif (RSTB_dly = '0') then
               case BREG is
                    when 1 =>
                       if(CEB2_dly = '1') then
                          qb_o_reg2 <= b_o_mux;
                       end if;
                    when 2 =>
                       if(CEB1_dly = '1') then
                          qb_o_reg1 <= b_o_mux;
                       end if;
                       if(CEB2_dly = '1') then
                          qb_o_reg2 <= qb_o_reg1;
                       end if;
                    when others => null;
               end case;
            end if;
         end if;
      end if;
  end process prcs_qb_2lvl;
------------------------------------------------------------------
  prcs_qb_o_mux:process(b_o_mux, qb_o_reg2)
  begin
     case BREG is
       when 0   => qb_o_mux <= b_o_mux;
       when 1|2 => qb_o_mux <= qb_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for BREG are 0 or 1 or 2 "
            severity Failure;
     end case;

  end process prcs_qb_o_mux;
------------------------------------------------------------------
  prcs_qbcout_o_mux:process(qb_o_mux, qb_o_reg1)
  begin
     case BCASCREG is
       when 1 => case BREG is
                   when 2 => qbcout_o_mux <= qb_o_reg1;
                   when others =>  qbcout_o_mux <= qb_o_mux;
                 end case;
       when others =>  qbcout_o_mux <= qb_o_mux;
     end case;
  end process prcs_qbcout_o_mux;

--####################################################################
--#####    Input Register C with 0, 1, level of registers        #####
--####################################################################
  prcs_qc_1lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qc_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
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
--###################      25x18 Multiplier     ######################
--####################################################################
--
-- 05/26/05 -- FP -- Added warning for invalid mult when USE_MULT=NONE
-- SIMD=FOUR12 and SIMD=TWO24
-- Made mult_o to be "X"
--
  prcs_mult:process(qa_o_mux, qb_o_mux)
  begin
     if(USE_MULT /= "NONE") then
        mult_o_int <=  qa_o_mux(MSB_A_MULT downto 0) * qb_o_mux (MSB_B_MULT downto 0);
     end if;
  end process prcs_mult;
------------------------------------------------------------------
  prcs_mult_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         mult_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
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
  prcs_mux_xyz:process(opmode_o_mux, qp_o_mux, qa_o_mux, qb_o_mux, mult_o_mux, 
                       qc_o_mux, PCIN_dly, output_x_sig, MULTSIGNIN_dly)
  begin
    if(output_x_sig = '1') then
      muxx_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxy_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxz_o_mux(MSB_P downto 0) <= ( others => 'X');
    elsif(output_x_sig = '0') then
    --MUX_X -----
       case opmode_o_mux(1 downto 0) is
         when "00" => muxx_o_mux <= ( others => '0');
         -- FP ?? sign extend needed from 43rd bit to 48th bit 
         when "01" => muxx_o_mux((MSB_A_MULT + MSB_B_MULT +1) downto 0) <= mult_o_mux;
                   if(mult_o_mux(MSB_A_MULT + MSB_B_MULT + 1) = '1') then
                     muxx_o_mux(MSB_PCIN downto (MAX_A_MULT + MAX_B_MULT)) <=  ( others => '1');
                   elsif (mult_o_mux(MSB_A_MULT + MSB_B_MULT + 1) = '0') then
                     muxx_o_mux(MSB_PCIN downto (MAX_A_MULT + MAX_B_MULT)) <=  ( others => '0');
                   end if;

         when "10" => muxx_o_mux <= qp_o_mux;

-- CR 438456  & CR 448147 & CR 451453
         when "11" => if((USE_MULT = "MULT_S") and (AREG=0 or BREG=0)) then 
                          muxx_o_mux(MSB_P downto 0) <=  ( others => 'X');  
                          assert false
                          report "DRC warning: When attribute USE_MULT on DSP48E instance %m is set to MULT_S, the A:B opmode selection is not permitted when AREG or BREG=0. If the multiplier is not used, set USE_MULT = NONE. For dynamic switching between multiply and add operation, set AREG and BREG=1 or MREG=0 and USE_MULT=MULT."
                          severity Warning;
                      else
                          muxx_o_mux(MSB_P downto 0)  <= (qa_o_mux & qb_o_mux);
                      end if;

         when others => null;
       end case;

    --MUX_Y -----
       case opmode_o_mux(3 downto 2) is
         when "00" => muxy_o_mux <= ( others => '0');
         when "01" => muxy_o_mux <= ( others => '0');
         when "10" => 
                     if(opmode_o_mux(6 downto 4) = "100") then
                        muxy_o_mux <= ( others => MULTSIGNIN_dly);
                     else
                        muxy_o_mux <= ( others => '1');
                     end if;
         when "11" => muxy_o_mux <= qc_o_mux;
         when others => null;
       end case;
    --MUX_Z -----
       case opmode_o_mux(6 downto 4) is
         when "000" => muxz_o_mux <= ( others => '0');
         when "001" => muxz_o_mux <= PCIN_dly;
         when "010" => muxz_o_mux <= qp_o_mux;
         when "011" => muxz_o_mux <= qc_o_mux;
         when "100" => muxz_o_mux <= qp_o_mux; -- Used for MACC extend -- multsignin
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
                       muxz_o_mux ((MSB_P - SHIFT_MUXZ) downto 0) <= qp_o_mux(MSB_P downto SHIFT_MUXZ ); 
                      
         when "111" => null;
         when others => null;
       end case;
    end if;
  end process prcs_mux_xyz;
--####################################################################
--#####                        Alumode                          #####
--####################################################################
  prcs_alumode_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         alumode_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTALUMODE_dly = '1') then
               alumode_o_reg <= ( others => '0');
            elsif ((RSTALUMODE_dly = '0') and (CEALUMODE_dly = '1'))then
               alumode_o_reg <= ALUMODE_dly;
            end if;
         end if;
      end if;
  end process prcs_alumode_reg;
------------------------------------------------------------------
  prcs_alumode_mux:process(alumode_o_reg, ALUMODE_dly)
  begin
     case ALUMODEREG is
      when 0 => alumode_o_mux <= ALUMODE_dly;
      when 1 => alumode_o_mux <= alumode_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for ALUMODEREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_alumode_mux;

--####################################################################
--#####                     CarryInSel                           #####
--####################################################################
  prcs_carryinsel_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         carryinsel_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
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

------------------------------------------------------------------
-- CR 219047 (3)
  prcs_carryinsel_drc:process(carryinsel_o_mux, MULTSIGNIN_dly, opmode_o_mux)
  begin
     if(carryinsel_o_mux = "010") then
        if(not((MULTSIGNIN_dly = 'X') or ((opmode_o_mux = "1001000") and (MULTSIGNIN_dly /= 'X')) 
                                 or ((MULTSIGNIN_dly = '0') and (CARRYCASCIN_dly = '0')))) then
           assert false
-- CR 451178 -- DRC warning Enhancement
           report "DRC warning : CARRYCASCIN can only be used in the current DSP48E instance if the previous DSP48E  is performing a two input ADD operation, or the current DSP48E is configured in the MAC extend opmode(6:0) equals 1001000. This warning can be also triggered if OPMODEREG is set to 1 and CARRYINSELREG is set to 0 - in which case please set CARRYINSELREG to 1."
           severity Warning;
        end if;
     end if;
  end process prcs_carryinsel_drc;

-- CR 219047 (4)
  prcs_carryinsel_mac_drc:process(carryinsel_o_mux)
  begin
     if((carryinsel_o_mux = "110")  and (MULTCARRYINREG /= MREG)) then
        assert false
        report "Attribute Syntax Warning : It is recommended that MREG and MULTCARRYINREG on DSP48E instance be set to the same value when using CARRYINSEL = 110 for multiply rounding. "
        severity Warning;
     end if;
  end process prcs_carryinsel_mac_drc;


--####################################################################
--#####                       CarryIn                            #####
--####################################################################

-------  input 0

  prcs_carryin_reg0:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg0 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTALLCARRYIN_dly = '1') then
               qcarryin_o_reg0 <= '0';
            elsif((RSTALLCARRYIN_dly = '0') and (CECARRYIN_dly = '1')) then
               qcarryin_o_reg0 <= CARRYIN_dly;
            end if;
         end if;
      end if;
  end process prcs_carryin_reg0;

  prcs_carryin_mux0:process(qcarryin_o_reg0, CARRYIN_dly)
  begin
     case CARRYINREG is
       when 0 => carryin_o_mux0 <= CARRYIN_dly;
       when 1 => carryin_o_mux0 <= qcarryin_o_reg0;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for CARRYINREG are 0 or 1"
            severity Failure;
     end case;
  end process prcs_carryin_mux0;

------------------------------------------------------------------
-------  input 7

  prcs_carryin_reg7:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg7 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTALLCARRYIN_dly = '1') then
               qcarryin_o_reg7 <= '0';
            elsif((RSTALLCARRYIN_dly = '0') and (CEMULTCARRYIN_dly = '1')) then
               qcarryin_o_reg7 <= qa_o_mux(24) XNOR qb_o_mux(17);
            end if;
         end if;
      end if;
  end process prcs_carryin_reg7;

  prcs_carryin_mux7:process(qa_o_mux(24), qb_o_mux(17), qcarryin_o_reg7)
  begin
     case MULTCARRYINREG is
       when 0 => carryin_o_mux7 <= qa_o_mux(24) XNOR qb_o_mux(17);
-- CR 232187
       when 1 => carryin_o_mux7 <= qcarryin_o_reg7;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for MULTCARRYINREG are 0 or 1"
            severity Failure;
     end case;
  end process prcs_carryin_mux7;

------------------------------------------------------------------
-- FP Check this with VV 
------------------------------------------------------------------
-- 
  prcs_carryin_mux:process(carryin_o_mux0, PCIN_dly(47), CARRYCASCIN_dly, carrycascout_o_mux, qp_o_mux(47), carryin_o_mux7, carryinsel_o_mux)
  begin
     case carryinsel_o_mux is
       when "000" => carryin_o_mux  <= carryin_o_mux0;
       when "001" => carryin_o_mux  <= NOT PCIN_dly(47);
       when "010" => carryin_o_mux  <= CARRYCASCIN_dly;
       when "011" => carryin_o_mux  <= PCIN_dly(47);
       when "100" => carryin_o_mux  <= carrycascout_o_mux;
       when "101" => carryin_o_mux  <= NOT qp_o_mux(47);
       when "110" => carryin_o_mux  <= carryin_o_mux7;
       when "111" => carryin_o_mux  <= qp_o_mux(47);
       when others => null;
     end case;
  end process prcs_carryin_mux;
--####################################################################
--#####                         ALU                              #####
--####################################################################
  prcs_alu:process(muxx_o_mux, muxy_o_mux, muxz_o_mux, alumode_o_mux, opmode_o_mux, carryin_o_mux, output_x_sig)

  variable opmode_alu_var : std_logic_vector(5 downto 0) := (others => '0');
  variable alu_full_tmp   : std_logic_vector(MAX_ALU_FULL downto 0) := (others => '0');
  variable alu_hlf1_tmp, alu_hlf2_tmp  : std_logic_vector(MAX_ALU_HALF downto 0) := (others => '0');
  variable alu_qrt1_tmp, alu_qrt2_tmp, alu_qrt3_tmp, alu_qrt4_tmp : std_logic_vector(MAX_ALU_QUART downto 0) := (others => '0');

  begin
     if(output_x_sig = '1') then
       alu_o <= (others => 'X');

     elsif(opmode_valid_flg) then
        opmode_alu_var := opmode_o_mux(3 downto 2) & alumode_o_mux;
        case opmode_alu_var is
           ---------------------------------
           ------------- ADD ---------------
           ---------------------------------
           when "000000" | "010000" | "100000" | "110000" => 

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := (('0'&muxz_o_mux) + 
                                   ('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux); 
                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux);
                  alu_hlf2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)))); 
                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux);
                  alu_qrt2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))));
                  alu_qrt3_tmp := (('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))));
                  alu_qrt4_tmp := (('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ------ SUBTRACT (X + ~Z ) ---- carryin must be 1 ---------------
           ---------------------------------
           when "000001" | "010001" | "100001" | "110001" => 

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := NOT('0'&muxz_o_mux) + 
                                   ('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux; 
                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  NOT alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := NOT('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux;
                  alu_hlf2_tmp := NOT('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)));

                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := NOT('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux;
                  alu_qrt2_tmp := NOT('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART)));
                  alu_qrt3_tmp := NOT('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART)));
                  alu_qrt4_tmp := NOT('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART)));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  NOT alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  NOT alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ---------- NOT (X + Y + Z + C) ----------
           ---------------------------------
           when "000010" | "010010" | "100010" | "110010" => 

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := NOT((('0'&muxz_o_mux) + 
                                   ('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux)); 

                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  NOT alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := NOT((('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_hlf2_tmp := NOT((('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)))));

                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := NOT((('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_qrt2_tmp := NOT((('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART)))));
                  alu_qrt3_tmp := NOT((('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART)))));
                  alu_qrt4_tmp := NOT((('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART)))));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  NOT alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  NOT alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ------- SUBTRACT (Z - X ) -------
           ---------------------------------
           when "000011" | "010011" | "100011" | "110011"=> 

               if((USE_SIMD = "ONE48") or (USE_SIMD = "one48")) then
                  alu_full_tmp := (('0'&muxz_o_mux) - 
                                   (('0'&muxx_o_mux) + 
                                   ('0'&muxy_o_mux) + carryin_o_mux)); 

                  alu_o <= alu_full_tmp(MSB_ALU_FULL downto 0);

                  carrycascout_o               <=  alu_full_tmp(MAX_ALU_FULL);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_full_tmp(MAX_ALU_FULL);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  'X';
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "TWO24") or (USE_SIMD = "two24")) then
                  alu_hlf1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) -
                                  (('0'&muxx_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_HALF)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_hlf2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) -
                                  (('0'&muxx_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_HALF)-1) downto (1*MAX_ALU_HALF)))));

                  alu_o <= (alu_hlf2_tmp(MSB_ALU_HALF downto 0) & alu_hlf1_tmp(MSB_ALU_HALF downto 0)) ;

                  carrycascout_o               <=  alu_hlf2_tmp(MAX_ALU_HALF);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_hlf2_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 1) <=  'X';
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_hlf1_tmp(MAX_ALU_HALF);
                     carryout_o(MSB_CARRYOUT - 3) <=  'X';
                  end if;

               elsif((USE_SIMD = "FOUR12") or (USE_SIMD = "four12")) then
                  alu_qrt1_tmp := (('0'&muxz_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) -
                                  (('0'&muxx_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  ('0'&muxy_o_mux(((1*MAX_ALU_QUART)-1) downto 0)) +
                                  carryin_o_mux));
                  alu_qrt2_tmp := (('0'&muxz_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) -
                                  (('0'&muxx_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((2*MAX_ALU_QUART)-1) downto (1*MAX_ALU_QUART)))));
                  alu_qrt3_tmp := (('0'&muxz_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) -
                                  (('0'&muxx_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((3*MAX_ALU_QUART)-1) downto (2*MAX_ALU_QUART)))));
                  alu_qrt4_tmp := (('0'&muxz_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) -
                                  (('0'&muxx_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART))) +
                                  ('0'&muxy_o_mux(((4*MAX_ALU_QUART)-1) downto (3*MAX_ALU_QUART)))));

                  alu_o <= (alu_qrt4_tmp(MSB_ALU_QUART downto 0) & alu_qrt3_tmp(MSB_ALU_QUART downto 0) &
                              alu_qrt2_tmp(MSB_ALU_QUART downto 0) & alu_qrt1_tmp(MSB_ALU_QUART downto 0));

                  carrycascout_o               <=  alu_qrt4_tmp(MAX_ALU_QUART);
                  --  if multiply operation then "X"out the carryout
                  if((opmode_o_mux(1 downto 0) = "01") or (opmode_o_mux(3 downto 2) = "01")) then
                     carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                  else
                     carryout_o(MSB_CARRYOUT - 0) <=  NOT alu_qrt4_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 1) <=  NOT alu_qrt3_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 2) <=  NOT alu_qrt2_tmp(MAX_ALU_QUART);
                     carryout_o(MSB_CARRYOUT - 3) <=  NOT alu_qrt1_tmp(MAX_ALU_QUART);
                  end if;

               else
                  assert false
                  report "Attribute Syntax Error: The legal values for USE_SIMD are ONE48 or TWO24 or FOUR12."
                  severity Failure;
               end if;

           ---------------------------------
           ------------- XOR ---------------
           ---------------------------------
           when "000100" | "000111" | "100101" | "100110" =>
                alu_o <= muxx_o_mux xor muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------- XNOR ---------------
           ---------------------------------
           when "000101" | "000110" | "100100" | "100111" =>
                alu_o <= muxx_o_mux xnor muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------- AND ---------------
           ---------------------------------
           when "001100" =>
                alu_o <= muxx_o_mux and muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           --------- X AND (NOT Z) ---------
           ---------------------------------
           when "001101" =>
                alu_o <= muxx_o_mux and (not muxz_o_mux); 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------- NAND ---------------
           ---------------------------------
           when "001110" =>
                alu_o <= muxx_o_mux nand muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           -------- - (NOT X) OR Z ---------
           ---------------------------------
           when "001111" =>
                alu_o <= (not muxx_o_mux) or  muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           -------------- OR ---------------
           ---------------------------------
           when "101100" =>
                alu_o <= muxx_o_mux or muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           --------- X OR (NOT Z) ---------
           ---------------------------------
           when "101101" =>
                alu_o <= muxx_o_mux or (not muxz_o_mux); 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           ------------ X NOR Z ------------
           ---------------------------------
           when "101110" =>
                alu_o <= muxx_o_mux nor  muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

           ---------------------------------
           --------- (NOT X) and Z ---------
           ---------------------------------
           when "101111" =>
                alu_o <= (not muxx_o_mux) and  muxz_o_mux; 
                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';


           when others => 

                carryout_o(MSB_CARRYOUT downto 0) <= (others => 'X');
                carrycascout_o <= 'X';

        end case;
    end if;
  end process prcs_alu;
--####################################################################
--#####                CARRYOUT and CARRYCASCOUT                 #####
--####################################################################
  prcs_carry_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         carryout_o_reg     <=  ( others => '0');
         carrycascout_o_reg <=  '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if((RSTP_dly = '1') or 
               ((AUTORESET_PATTERN_DETECT) and (
                ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and pdet_o_reg1 = '1') or 
                ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and (pdet_o_reg2 = '1' and pdet_o_reg1 = '0')))
               )
              ) then
               carryout_o_reg     <= ( others => '0');
               carrycascout_o_reg <=  '0';
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               carryout_o_reg <= carryout_o;
               carrycascout_o_reg <= carrycascout_o;
            end if;
         end if;
      end if;
  end process prcs_carry_reg;
------------------------------------------------------------------
  prcs_carryout_mux:process(carryout_o, carryout_o_reg)
  begin
     case PREG is
       when 0 => carryout_o_mux <= carryout_o;
       when 1 => carryout_o_mux <= carryout_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;
   
  end process prcs_carryout_mux;

------------------------------------------------------------------
  prcs_carryout_x_o:process(carryout_o_mux)
  begin
     if(USE_SIMD = "ONE48") then
        carryout_x_o(3) <= carryout_o_mux(3);
     elsif(USE_SIMD = "TWO24") then
        carryout_x_o(3) <= carryout_o_mux(3);
        carryout_x_o(1) <= carryout_o_mux(1);
     elsif(USE_SIMD = "FOUR12") then
        carryout_x_o(3) <= carryout_o_mux(3);
        carryout_x_o(2) <= carryout_o_mux(2);
        carryout_x_o(1) <= carryout_o_mux(1);
        carryout_x_o(0) <= carryout_o_mux(0);
     end if;
  end process prcs_carryout_x_o;

------------------------------------------------------------------
  prcs_carrycascout_mux:process(carrycascout_o, carrycascout_o_reg)
  begin
     case PREG is
       when 0 => carrycascout_o_mux <= carrycascout_o;
       when 1 => carrycascout_o_mux <= carrycascout_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;
   
  end process prcs_carrycascout_mux;
------------------------------------------------------------------
-- CR 219047 (2)
  prcs_multsignout_o_opmode:process(mult_o_mux(MSB_A_MULT+MSB_B_MULT+1), opmode_o_mux(3 downto 0))
  begin
    if(opmode_o_mux(3 downto 0) = "0101") then
       multsignout_o_opmode <= mult_o_mux(MSB_A_MULT+MSB_B_MULT+1);
    else
       multsignout_o_opmode <= 'X';
    end if;
  end process prcs_multsignout_o_opmode;

  prcs_multsignout_o_mux:process(multsignout_o_opmode, multsignout_o_reg)
  begin
     case PREG is
       when 0 => multsignout_o_mux <= multsignout_o_opmode;
-- CR 232275
       when 1 => multsignout_o_mux <= multsignout_o_reg;
       when others => null;
--           assert false
--           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
--           severity Failure;
     end case;
   
  end process prcs_multsignout_o_mux;
--####################################################################
--####################################################################
--####################################################################
--#####                 PCOUT and MULTSIGNOUT                    #####
--####################################################################
  prcs_qp_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qp_o_reg <=  ( others => '0');
         multsignout_o_reg <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if((RSTP_dly = '1') or 
               ((AUTORESET_PATTERN_DETECT) and (
                ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and pdet_o_reg1 = '1') or 
                ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and (pdet_o_reg2 = '1' and pdet_o_reg1 = '0')))
               )
              ) then
               qp_o_reg <= ( others => '0');
               multsignout_o_reg <= '0';
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               qp_o_reg <= alu_o;
-- CR 491227               multsignout_o_reg <= mult_o_reg((MSB_A_MULT+MSB_B_MULT+1));
               multsignout_o_reg <= multsignout_o_opmode;
            end if;
         end if;
      end if;
  end process prcs_qp_reg;
------------------------------------------------------------------
  prcs_qp_mux:process(alu_o, qp_o_reg)
  begin
     case PREG is
       when 0 => qp_o_mux <= alu_o;
       when 1 => qp_o_mux <= qp_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;
   
  end process prcs_qp_mux;
--####################################################################
--#####                    Pattern Detector                      #####
--####################################################################
  prcs_sel_pattern_detect:process(alu_o, qc_o_mux)
  begin

     -- Select the pattern
     if((SEL_PATTERN = "PATTERN") or (SEL_PATTERN = "pattern")) then
         pattern_qp <= To_StdLogicVector(PATTERN);
     elsif((SEL_PATTERN = "C") or (SEL_PATTERN = "c")) then
         pattern_qp <= qc_o_mux;
     else 
         assert false
         report "Attribute Syntax Error: The attribute SEL_PATTERN on DSP48_ALU is incorrect. Legal values for this attribute are PATTERN or C"
         severity Failure;
     end if;

     -- Select the mask  -- if ROUNDING MASK set, use rounding mode, else use SEL_MASK
     if((SEL_ROUNDING_MASK = "SEL_MASK") or (SEL_ROUNDING_MASK = "sel_mask")) then
         if((SEL_MASK = "MASK") or (SEL_MASK = "mask")) then
             mask_qp <= To_StdLogicVector(MASK);
         elsif((SEL_MASK = "C") or (SEL_MASK = "c")) then
             mask_qp <= qc_o_mux;
         else
           assert false
           report "Attribute Syntax Error: The attribute SEL_MASK on DSP48_ALU is incorrect. Legal values for this attribute are MASK or C"
           severity Failure;
         end if;
     elsif((SEL_ROUNDING_MASK = "MODE1") or (SEL_ROUNDING_MASK = "mode1")) then
         mask_qp <=   To_StdLogicVector((To_bitvector( not qc_o_mux)) sla 1) ;
         mask_qp (0) <= '0';
     elsif((SEL_ROUNDING_MASK = "MODE2") or (SEL_ROUNDING_MASK = "mode2")) then
         mask_qp <=   To_StdLogicVector((To_bitvector( not qc_o_mux)) sla 2) ;
         mask_qp (1 downto 0) <= (others => '0');
     else
         assert false
         report "Attribute Syntax Error: The attribute SEL_ROUNDING_MASK on DSP48_ALU is incorrect. Legal values for this attribute are SEL_MASK or MODE1 or MODE2."
         severity Failure;
     end if;
     
  end process prcs_sel_pattern_detect;


---------------------------------------------------------------

  prcs_pdet:process(alu_o, mask_qp, pattern_qp, GSR_dly )
  variable x_found : boolean := false;
  variable lhs     : std_logic_vector(MSB_P downto 0) := (others => '0');
  variable rhs     : std_logic_vector(MSB_P downto 0) := (others => '0');


  begin

  --   CR 501854

       lhs := (alu_o or mask_qp);
       rhs := (pattern_qp or mask_qp);

       x_found := find_x(lhs, rhs);

       if(((alu_o or mask_qp) = (pattern_qp or mask_qp)) and (GSR_dly = '0') and (not x_found))then 
          pdet_o <= '1';
       else
          pdet_o <= '0';
       end if;

       if(((alu_o or mask_qp) = ((NOT pattern_qp) or mask_qp)) and (GSR_dly = '0') and (not x_found)) then 
          pdetb_o <= '1';
       else
          pdetb_o <= '0';
       end if;

  end process prcs_pdet;

---------------------------------------------------------------

  prcs_pdet_reg:process(CLK_dly, GSR_dly)
  variable pdetb_reg1_var, pdetb_reg2_var, pdet_reg1_var, pdet_reg2_var : std_ulogic := '0';  
  begin
      if(GSR_dly = '1') then
         pdetb_o_reg1 <= '0';
         pdetb_o_reg2 <= '0';
         pdet_o_reg1  <= '0';
         pdet_o_reg2  <= '0';

         pdetb_reg1_var := '0';
         pdetb_reg2_var := '0';
         pdet_reg1_var  := '0';
         pdet_reg2_var  := '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if((RSTP_dly = '1') or 
               ((AUTORESET_PATTERN_DETECT) and (
                ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and pdet_o_reg1 = '1') or 
                ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and (pdet_o_reg2 = '1' and pdet_o_reg1 = '0')))
               )
              ) then
               pdetb_o_reg1 <= '0';
               pdetb_o_reg2 <= '0';
               pdet_o_reg1  <= '0';
               pdet_o_reg2  <= '0';

               pdetb_reg1_var := '0';
               pdetb_reg2_var := '0';
               pdet_reg1_var  := '0';
               pdet_reg2_var  := '0';
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               pdetb_reg2_var := pdetb_reg1_var;
               pdetb_reg1_var := pdetb_o;

               pdet_reg2_var := pdet_reg1_var;
               pdet_reg1_var := pdet_o;

               pdetb_o_reg1 <= pdetb_reg1_var;
               pdetb_o_reg2 <= pdetb_reg2_var;
               pdet_o_reg1  <= pdet_reg1_var;
               pdet_o_reg2  <= pdet_reg2_var;

            end if;
         end if;
      end if;
  end process prcs_pdet_reg;

--####################################################################
--#####                 Underflow / Overflow                     #####
--####################################################################
  prcs_uflow_oflow:process(pdet_o_reg1 , pdet_o_reg2 , pdetb_o_reg1 , pdetb_o_reg2)
  begin
--    if(((AUTORESET_PATTERN_DETECT) and (
--       ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and (pdet_o_reg1 = '1'))  or
--       ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and ((pdet_o_reg2 = '1') and (pdet_o_reg1 = '0'))))
--      )) then
--       underflow_o <= '0';
--       overflow_o  <= '0';
--    else
--       overflow_o  <= pdet_o_reg2   AND  (NOT pdet_o_reg1)  AND  (NOT pdetb_o_reg1);
--       underflow_o <= pdetb_o_reg2  AND  (NOT pdet_o_reg1)  AND (NOT pdetb_o_reg1);
--    end if;
    if(GSR_dly = '1') then
        overflow_o  <= '0';
        underflow_o <= '0';
    elsif(USE_PATTERN_DETECT = "NO_PATDET") then
        overflow_o  <= 'X';
        underflow_o <= 'X';
    elsif(PREG = 0) then
          overflow_o  <= 'X';
          underflow_o <= 'X';
    elsif(PREG = 1) then
          overflow_o  <= pdet_o_reg2   AND  (NOT pdet_o_reg1)  AND  (NOT pdetb_o_reg1);
          underflow_o <= pdetb_o_reg2  AND  (NOT pdet_o_reg1)  AND (NOT pdetb_o_reg1);
    end if;

  end process prcs_uflow_oflow;
--####################################################################
--#####                 OPMODE DRC                               #####
--####################################################################
--  prcs_opmode_drc:process(ping_opmode_drc_check, alumode_o_mux, opmode_o_mux, carryinsel_o_mux)

--      opmode_valid_flg <= opmode_valid_var;

--  end process prcs_opmode_drc;
--####################################################################
--#####                   ZERO_DELAY_OUTPUTS                     #####
--####################################################################
  prcs_zero_delay_outputs:process(qacout_o_mux, qbcout_o_mux, carryout_x_o, carrycascout_o_mux,
                                  overflow_o, qp_o_mux, pdet_o, pdetb_o,
                                  pdet_o_reg1, pdetb_o_reg1,
                                  pdet_o_reg2, pdetb_o_reg2,
                                  underflow_o, multsignout_o_mux, opmode_valid_flg, alumode_valid_flg)
  begin
    ACOUT_zd          <= qacout_o_mux;
    BCOUT_zd          <= qbcout_o_mux;
    OVERFLOW_zd       <= overflow_o;
    UNDERFLOW_zd      <= underflow_o;
    P_zd              <= qp_o_mux;
    PCOUT_zd          <= qp_o_mux;
    MULTSIGNOUT_zd    <= multsignout_o_mux;

    if(((AUTORESET_PATTERN_DETECT) and (
       ((AUTORESET_PATTERN_DETECT_OPTINV = "MATCH") and (pdet_o_reg1 = '1'))  or
       ((AUTORESET_PATTERN_DETECT_OPTINV = "NOT_MATCH") and ((pdet_o_reg2 = '1') and (pdet_o_reg1 = '0'))))
      )) then
      CARRYCASCOUT_zd   <= '0';
      CARRYOUT_zd       <= (others => '0');
    else
      CARRYCASCOUT_zd   <= carrycascout_o_mux;   
      CARRYOUT_zd       <= carryout_x_o; 
    end if;

    if((USE_PATTERN_DETECT = "NO_PATDET") or (not opmode_valid_flg) or (not alumode_valid_flg)) then
       PATTERNBDETECT_zd <= 'X';
       PATTERNDETECT_zd  <= 'X';
    elsif (PREG = 0) then
          PATTERNBDETECT_zd <= pdetb_o;
          PATTERNDETECT_zd  <= pdet_o;
    elsif(PREG = 1) then
          PATTERNBDETECT_zd <= pdetb_o_reg1;
          PATTERNDETECT_zd  <= pdet_o_reg1;
    end if;

  end process prcs_zero_delay_outputs;

end generate; 
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(ACOUT_zd, BCOUT_zd, CARRYCASCOUT_zd, CARRYOUT_zd,
                      OVERFLOW_zd, P_zd, PATTERNBDETECT_zd, PATTERNDETECT_zd,
                      PCOUT_zd, UNDERFLOW_zd, MULTSIGNOUT_zd)
  begin
      ACOUT             <= ACOUT_zd after SYNC_PATH_DELAY;
      BCOUT             <= BCOUT_zd after SYNC_PATH_DELAY;
      CARRYCASCOUT      <= CARRYCASCOUT_zd after SYNC_PATH_DELAY;
      CARRYOUT          <= CARRYOUT_zd after SYNC_PATH_DELAY;
      OVERFLOW          <= OVERFLOW_zd after SYNC_PATH_DELAY;
      P                 <= P_zd after SYNC_PATH_DELAY;
      PATTERNBDETECT    <= PATTERNBDETECT_zd after SYNC_PATH_DELAY;
      PATTERNDETECT     <= PATTERNDETECT_zd after SYNC_PATH_DELAY;
      PCOUT             <= PCOUT_zd after SYNC_PATH_DELAY;
      UNDERFLOW         <= UNDERFLOW_zd after SYNC_PATH_DELAY;

      MULTSIGNOUT       <= MULTSIGNOUT_zd after SYNC_PATH_DELAY;
  end process prcs_output;



end DSP48E_V;

