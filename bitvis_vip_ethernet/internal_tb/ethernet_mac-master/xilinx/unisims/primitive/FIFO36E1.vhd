-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/blanc/VITAL/FIFO36E1.vhd,v 1.39.74.3 2013/08/01 23:44:44 wloo Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2009 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                       36K-Bit FIFO
-- /___/   /\     Filename : FIFO36E1.vhd
-- \   \  /  \    Timestamp : Mon Apr 14 18:32:30 PDT 2008
--  \___\/\___\
--
-- Revision:
--    04/14/08 - Initial version.
--    07/10/08 - IR476500 Add INIT parameter support, sync with FIFO36 internal
--    08/26/08 - Updated unused bit on wrcount and rdcount to match the hardware.
--    09/02/08 - Fixed ECC mismatch with hardware. (IR 479250)
--    09/18/08 - Fixed ECC injection. (IR 474017)
--    09/23/08 - Fixed X's from wrcount and rdcount. (IR 488611)
--    11/11/08 - Added DRC for invalid input parity for ECC (CR 482976).
--    01/07/09 - Fixed rdcount output when reset (IR 501177).
--    01/15/09 - Fixed X in ECCPARITY during initialization (IR 501358).
--    01/30/09 - Fixed sbiterr and dbiterr in synchronous and output register mode (IR 501358).
--    04/02/09 - Implemented DRC for FIFO_MODE (CR 517127).
--    10/23/09 - Fixed RST and RSTREG (CR 537067).
--    11/17/09 - Fixed ECCPARITY behavior during RST (CR 537360).
--    12/02/09 - Updated SRVAL and INIT port mapping for FIFO_MODE = FIFO36_72 (CR 539776).
--    06/30/10 - Updated RESET behavior and added SIM_DEVICE (CR 567515).
--    07/09/10 - Fixed INJECTSBITERR and INJECTDBITERR behaviors (CR 565234).
--    07/19/10 - Fixed RESET behavior during startup (CR 568626).
--    08/19/10 - Fixed RESET DRC during startup (CR 570708).
--    12/02/10 - Added warning message for 7SERIES Aysnc mode (CR 584052).
--    12/08/10 - Error out if no reset before first use of the fifo (CR 583638).
--    01/12/11 - updated warning message for 7SERIES Aysnc mode (CR 589721).
--    04/01/11 - Fixed RESET behvavior at 0 ps (CR 588406).
--    04/08/11 - Fixed RSTREG behavior when RST is asserted (CR 596723).
--    05/11/11 - Fixed DO not suppose to be reseted when RST asserted (CR 586526).
--    05/19/11 - Fixed drc for almost_empty/full_offset (CR 611056).
--    05/26/11 - Update Aysnc fifo behavior (CR 599680).
--    05/31/11 - Fixed DRC for almost_empty/full_offset (CR 611228).
--    06/02/11 - Fixed full flag for 7 series aysnc fifo (CR 611949).
--    06/06/11 - Fixed RST in standard mode (CR 613216).
--    06/07/11 - Update DRC equation for ALMOST_FULL_OFFSET (CR 611057).
--    06/09/11 - Fixed GSR behavior (CR 611989).
--    06/29/11 - Fixed almostempty flag (CR 614659).
--    07/07/11 - Fixed Full flag (CR 615773).
--    08/29/11 - Fixed FULL and ALMOSTFULL during initial time (CR 622163).
--    09/19/11 - Fixed almostempty flag when write counter looped around (CR 624102).
--    11/01/11 - Removed all mention of internal block ram from messaging (CR 569190).
--    03/08/12 - Added DRC to check WREN/RDEN after RST deassertion (CR 644571).
--    11/05/12 - Fixed full flag in async mode with sync clocks (CR 677254).
--    04/02/13 - Fixed almostfull flag in async mode (CR 709350).
--    08/01/13 - Fixed async mode with sync clocks (CR 728728).
-- End Revision


-- WARNING !!!: The following FF36_INTERNAL_VHDL entity is not an user primitive. 
--              Please do not modify any part of it. FIFO36E1 may not work properly if do so.
--
  
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library STD;
use STD.TEXTIO.ALL;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;



entity FF36_INTERNAL_VHDL is

  generic(

    ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"0080"; 
    DATA_WIDTH              : integer    := 4;
    DO_REG                  : integer    := 1;
    EN_ECC_READ             : boolean    := FALSE;
    EN_ECC_WRITE            : boolean    := FALSE;    
    EN_SYN                  : boolean    := FALSE;
    FIFO_MODE               : string     := "FIFO36";
    FIFO_SIZE               : integer    := 36;
    FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
    INIT                    : bit_vector := X"000000000000000000";
    SIM_DEVICE              : string     := "VIRTEX6";
    SRVAL                   : bit_vector := X"000000000000000000"
    );

  port(
    ALMOSTEMPTY          : out std_ulogic;
    ALMOSTFULL           : out std_ulogic;
    DBITERR              : out std_ulogic;
    DO                   : out std_logic_vector (63 downto 0);
    DOP                  : out std_logic_vector (7 downto 0);
    ECCPARITY            : out std_logic_vector (7 downto 0);
    EMPTY                : out std_ulogic;
    FULL                 : out std_ulogic;
    RDCOUNT              : out std_logic_vector (12 downto 0);
    RDERR                : out std_ulogic;
    SBITERR              : out std_ulogic;
    WRCOUNT              : out std_logic_vector (12 downto 0);
    WRERR                : out std_ulogic;

    DI                   : in  std_logic_vector (63 downto 0);
    DIP                  : in  std_logic_vector (7 downto 0);
    INJECTDBITERR        : in  std_ulogic;
    INJECTSBITERR        : in  std_ulogic;
    RDCLK                : in  std_ulogic;
    RDEN                 : in  std_ulogic;
    REGCE                : in  std_ulogic;
    RST                  : in  std_ulogic;
    RSTREG               : in  std_ulogic;
    WRCLK                : in  std_ulogic;
    WREN                 : in  std_ulogic
    );

end FF36_INTERNAL_VHDL;

-- architecture body                    --

architecture FF36_INTERNAL_VHDL_V of FF36_INTERNAL_VHDL is

  function GetMemoryDepth (
    rdwr_width : in integer;
    func_fifo_size : in integer
    ) return integer is
    variable func_mem_depth : integer;
  begin
    case rdwr_width is
      when 4 => if (func_fifo_size = 18) then
                  func_mem_depth := 4096;
                else
                  func_mem_depth := 8192;
                end if;
      when 9 => if (func_fifo_size = 18) then
                  func_mem_depth := 2048;
                else
                  func_mem_depth := 4096;
                end if;
      when 18 => if (func_fifo_size = 18) then
                   func_mem_depth := 1024;
                 else
                   func_mem_depth := 2048;
                 end if;
      when 36 => if (func_fifo_size = 18) then
                   func_mem_depth := 512;
                 else
                   func_mem_depth := 1024;
                 end if;
      when 72 => if (func_fifo_size = 18) then
                   func_mem_depth := 0;
                 else
                   func_mem_depth := 512;
                 end if;
      when others => func_mem_depth := 8192;
    end case;
    return func_mem_depth;
  end;

  function GetMemoryDepthP (
    rdwr_width : in integer;
    func_fifo_size : in integer
    ) return integer is
    variable func_memp_depth : integer;
  begin
    case rdwr_width is
      when 9 => if (func_fifo_size = 18) then
                  func_memp_depth := 2048;
                else
                  func_memp_depth := 4096;
                end if;
      when 18 => if (func_fifo_size = 18) then
                   func_memp_depth := 1024;
                 else
                   func_memp_depth := 2048;
                 end if;
      when 36 => if (func_fifo_size = 18) then
                   func_memp_depth := 512;
                 else
                   func_memp_depth := 1024;
                 end if;
      when 72 => if (func_fifo_size = 18) then
                   func_memp_depth := 0;
                 else
                   func_memp_depth := 512;
                 end if;
      when others => func_memp_depth := 8192;
    end case;
    return func_memp_depth;
  end;

  
  function GetWidth (
    rdwr_width : in integer
    ) return integer is
    variable func_width : integer;
  begin
    case rdwr_width is
      when 4 => func_width := 4;
      when 9 => func_width := 8;
      when 18 => func_width := 16;
      when 36 => func_width := 32;
      when 72 => func_width := 64;
      when others => func_width := 64;
    end case;
    return func_width;
  end;

  
  function GetWidthp (
    rdwr_widthp : in integer
    ) return integer is
    variable func_widthp : integer;
  begin
    case rdwr_widthp is
      when 9 => func_widthp := 1;
      when 18 => func_widthp := 2;
      when 36 => func_widthp := 4;
      when 72 => func_widthp := 8;
      when others => func_widthp := 8;
    end case;
    return func_widthp;
  end;
    
    constant MAX_DO      : integer    := 64;
    constant MAX_DOP     : integer    := 8;
    constant MAX_RDCOUNT : integer    := 13;
    constant MAX_WRCOUNT : integer    := 13;
    constant MSB_MAX_DO  : integer    := 63;
    constant MSB_MAX_DOP : integer    := 7;
    constant MSB_MAX_RDCOUNT : integer    := 12;
    constant MSB_MAX_WRCOUNT : integer    := 12;

    constant MAX_DI      : integer    := 64;
    constant MAX_DIP     : integer    := 8;
    constant MSB_MAX_DI  : integer    := 63;
    constant MSB_MAX_DIP : integer    := 7;

    constant MAX_LATENCY_EMPTY : integer := 3;
    constant MAX_LATENCY_FULL  : integer := 3;

    constant mem_depth : integer := GetMemoryDepth(DATA_WIDTH, FIFO_SIZE);
    constant memp_depth : integer := GetMemoryDepthP(DATA_WIDTH, FIFO_SIZE);
    constant mem_width : integer := GetWidth(DATA_WIDTH);
    constant memp_width : integer := GetWidthp(DATA_WIDTH); 

    type Two_D_array_type is array ((mem_depth -  1) downto 0) of std_logic_vector((mem_width - 1) downto 0);
    type Two_D_parity_array_type is array ((memp_depth - 1) downto 0) of std_logic_vector((memp_width -1) downto 0);
  
    signal mem : Two_D_array_type;
    signal memp : Two_D_parity_array_type;

    signal DI_dly    : std_logic_vector(MSB_MAX_DI downto 0)    := (others => 'X');
    signal DIP_dly   : std_logic_vector(MSB_MAX_DIP downto 0)   := (others => 'X');
    signal GSR_dly   : std_ulogic;
    signal RDCLK_dly : std_ulogic     :=    'X';
    signal RDEN_dly  : std_ulogic     :=    'X';
    signal RST_dly   : std_ulogic     :=    'X';
    signal WRCLK_dly : std_ulogic     :=    'X';
    signal WREN_dly  : std_ulogic     :=    'X';

    signal DO_zd          : std_logic_vector(MSB_MAX_DO  downto 0)    := (others => '0');
    signal DOP_zd         : std_logic_vector(MSB_MAX_DOP downto 0)    := (others => '0');
    signal ALMOSTEMPTY_zd : std_logic     :=    '1';
    signal ALMOSTFULL_zd  : std_logic     :=    '0';
    signal EMPTY_zd       : std_logic     :=    '1';
    signal FULL_zd        : std_logic     :=    '0';
    signal RDCOUNT_zd     : std_logic_vector(MSB_MAX_RDCOUNT  downto 0)    := (others => '0');
    signal RDERR_zd       : std_logic     :=    '0';
    signal WRCOUNT_zd     : std_logic_vector(MSB_MAX_WRCOUNT  downto 0)    := (others => '0');
    signal WRERR_zd       : std_logic     :=    '0';
    signal RDCOUNT_OUT_zd : std_logic_vector(MSB_MAX_RDCOUNT  downto 0)    := (others => '0');
    signal WRCOUNT_OUT_zd : std_logic_vector(MSB_MAX_WRCOUNT  downto 0)    := (others => '0');
    signal DO_OUT_zd      : std_logic_vector(MSB_MAX_DO  downto 0)         := (others => 'X');
    signal DOP_OUT_zd     : std_logic_vector(MSB_MAX_DOP  downto 0)        := (others => 'X');
    signal DO_OUTREG_zd          : std_logic_vector(MSB_MAX_DO  downto 0)    := (others => '0');
    signal DOP_OUTREG_zd         : std_logic_vector(MSB_MAX_DOP downto 0)    := (others => '0');
    signal DO_OUT_MUX_zd         : std_logic_vector(MSB_MAX_DO  downto 0)    := (others => '0');
    signal DOP_OUT_MUX_zd        : std_logic_vector(MSB_MAX_DOP downto 0)    := (others => '0');

  --- Internal Signal Declarations

    signal RST_META    : std_ulogic := '0';

    signal DefDelay    : time := 10 ps;

    signal addr_limit    : integer := 0;
    signal wr_addr       : integer := 0;
    signal wr_addr_7s       : integer := 0;
    signal rdcount_m1 : integer := -1;

    signal rd_addr       : integer := 0;
    signal rd_addr_7s       : integer := 0;
    signal rd_addr_range : integer := 0;
    signal wr_addr_range : integer := 0;

    signal rd_flag       : std_logic := '0';
    signal wr_flag       : std_logic := '0';
    signal awr_flag      : std_logic := '0';

    signal rdcount_flag  : std_logic := '0';

    signal almostempty_limit : real := 0.0;
    signal almostfull_limit  : real := 0.0;

    signal violation : std_ulogic := '0'; 

    signal fwft      : std_logic := 'X';

    signal update_from_write_prcs      : std_logic := '0';
    signal update_from_read_prcs       : std_logic := '0';
    signal update_from_write_prcs_sync : std_logic := '0';
    signal update_from_read_prcs_sync  : std_logic := '0';
  
    signal ae_empty   : integer := 0;
    signal ae_full    : integer := 0;

-- CR 182616 fix
   signal rst_rdckreg : std_logic_vector (4 downto 0) := (others => '0');
   signal rst_wrckreg : std_logic_vector (4 downto 0) := (others => '0');
   signal rst_rdckreg_flag : std_logic := '0';
   signal rst_wrckreg_flag : std_logic := '0';
   signal sync : std_logic := 'X';
   signal sbiterr_zd : std_logic := '0';
   signal dbiterr_zd : std_logic := '0';
   signal ECCPARITY_zd : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
   signal rst_rdclk_flag : std_logic := '0';
   signal rst_wrclk_flag : std_logic := '0';
   signal INIT_STD : std_logic_vector(INIT'length-1 downto 0) := To_StdLogicVector(INIT);
   signal SRVAL_STD : std_logic_vector(SRVAL'length-1 downto 0) := To_StdLogicVector(SRVAL);
   signal INJECTDBITERR_dly     : std_ulogic          := '0';
   signal INJECTSBITERR_dly     : std_ulogic          := '0';
   signal RSTREG_dly :  std_ulogic := '0';
   signal REGCE_dly   : std_ulogic                    := '0';
   signal viol_rst_rden : std_logic := '0';
   signal viol_rst_wren : std_logic := '0';
   signal first_rst_flag : std_logic := '0';
   signal rm1w_eq : std_logic := '0';
   signal rm1wp1_eq : std_logic := '0';
   signal full_v3 : std_logic := '0';
   signal count_freq_wrclk : integer := 0;
   signal period_wrclk : time := 0 ps;
   signal count_freq_wrclk_reset : std_logic := '0';
   signal fwft_prefetch_flag : integer := 1;
   signal set_fwft_prefetch_flag_to_0 : std_logic := '0';
   signal after_rst_x_flag : std_logic := '0';
   signal time_rdclk : time := 0 ps;
   signal time_wrclk : time := 0 ps;
   signal sync_clk_async_mode : std_logic := '0';
  

begin

  ---------------------
  --  INPUT PATH DELAYs
  ---------------------

  DI_dly         	 <= DI             	after 0 ps;
  DIP_dly        	 <= DIP            	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  RDCLK_dly      	 <= RDCLK          	after 0 ps;
  RDEN_dly       	 <= RDEN           	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;
  RSTREG_dly             <= RSTREG              after 0 ps;
  REGCE_dly              <= REGCE               after 0 ps;
  WRCLK_dly      	 <= WRCLK          	after 0 ps;
  WREN_dly       	 <= WREN           	after 0 ps;
  INJECTDBITERR_dly      <= INJECTDBITERR       after 0 ps;
  INJECTSBITERR_dly      <= INJECTSBITERR       after 0 ps;
  
  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_initialize:process
  variable first_time        : boolean    := true;
  variable addr_limit_var    : integer    := 0; 
  variable fwft_var          : std_ulogic := 'X';
  variable rd_offset_stdlogic : std_logic_vector (ALMOST_EMPTY_OFFSET'length-1 downto 0);
  variable rd_offset_int : integer := 0;
  variable wr_offset_stdlogic : std_logic_vector (ALMOST_FULL_OFFSET'length-1 downto 0);
  variable wr_offset_int : integer := 0;
--  variable Message : LINE;
  variable ae_empty_var      : integer := 0;
  variable ae_full_var       : integer := 0;
  
  begin
     if (first_time) then

       case EN_SYN is
            when TRUE  => sync <= '1';
            when FALSE => sync <= '0';
            when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " EN_SYN ",
                        EntityName           => "FIFO36E1",
                        GenericValue         => EN_SYN,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " TRUE or FALSE ",
                        TailMsg              => "",
                        MsgSeverity          => failure
                        );
       end case;

       
       case DATA_WIDTH is
            when 4  => if (FIFO_SIZE = 36) then
                         addr_limit_var := 8192;
                       else                         
                         addr_limit_var := 4096;
                       end if;     
            when 9  => if (FIFO_SIZE = 36) then
                         addr_limit_var := 4096;
                       else                         
                         addr_limit_var := 2048;
                       end if;
            when 18 => if (FIFO_SIZE = 36) then
                         addr_limit_var := 2048;
                       else                         
                         addr_limit_var := 1024;
                       end if;
            when 36 => if (FIFO_SIZE = 36) then
                         addr_limit_var := 1024;
                       else                         
                         addr_limit_var := 512;
                       end if;
            when 72 =>
                       addr_limit_var := 512;

            when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " DATA_WIDTH ",
                        EntityName           => "FIFO36E1",
                        GenericValue         => DATA_WIDTH,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " 4, 9, 18, 36 and 72 ",
                        TailMsg              => "",
                        MsgSeverity          => failure
                        );
       end case;

       rd_offset_stdlogic := To_StdLogicVector(ALMOST_EMPTY_OFFSET);
       rd_offset_int := SLV_TO_INT(rd_offset_stdlogic);

       wr_offset_stdlogic := To_StdLogicVector(ALMOST_FULL_OFFSET);
       wr_offset_int := SLV_TO_INT(wr_offset_stdlogic);

       case FIRST_WORD_FALL_THROUGH is
            when TRUE  =>
                         fwft_var     := '1';
                         ae_empty_var := rd_offset_int - 2;
                         ae_full_var := wr_offset_int;
            when FALSE =>
                         fwft_var     := '0';
                         if (EN_SYN = FALSE) then
                           ae_empty_var := rd_offset_int - 1;
                           ae_full_var := wr_offset_int;
                         else
                           ae_empty_var := rd_offset_int;
                           ae_full_var := wr_offset_int;
                         end if;
         when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " FIRST_WORD_FALL_THROUGH ",
                        EntityName           => "FIFO36E1",
                        GenericValue         => FIRST_WORD_FALL_THROUGH,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " true or false ",
                        TailMsg              => "",
                        MsgSeverity          => failure
                        );
       end case;

       
       if(fwft_var = '1' and EN_SYN = TRUE) then
          assert false
          report "DRC Error : First word fall through is not supported in synchronous mode on FIFO36E1."
          severity failure;
       end if;

       
       if(EN_SYN = FALSE and DO_REG = 0) then
          assert false
          report "DRC Error : DO_REG = 0 is invalid when EN_SYN is set to FALSE on FIFO36E1."
          severity failure;
       end if;

       
       if (not (EN_ECC_WRITE = TRUE or EN_ECC_WRITE = FALSE)) then
         GenericValueCheckMessage
           ( HeaderMsg            => " Attribute Syntax Error ",
             GenericName          => " EN_ECC_WRITE ",
             EntityName           => "FIFO36E1",
             GenericValue         => EN_ECC_WRITE,
             Unit                 => "",
             ExpectedValueMsg     => " The Legal values for this attribute are ",
             ExpectedGenericValue => " true or false ",
             TailMsg              => "",
             MsgSeverity          => failure
             );
       end if;

       
       if (not (EN_ECC_READ = TRUE or EN_ECC_READ = FALSE)) then
         GenericValueCheckMessage
           ( HeaderMsg            => " Attribute Syntax Error ",
             GenericName          => " EN_ECC_READ ",
             EntityName           => "FIFO36E1",
             GenericValue         => EN_ECC_READ,
             Unit                 => "",
             ExpectedValueMsg     => " The Legal values for this attribute are ",
             ExpectedGenericValue => " true or false ",
             TailMsg              => "",
             MsgSeverity          => failure
             );
       end if;


       if ((EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) and DATA_WIDTH /= 72) then
          assert false
            report "DRC Error : The attribute DATA_WIDTH must be set to 72 when FIFO36E1 is configured in the ECC mode."
          severity failure;
       end if;

       
       if (not(SIM_DEVICE = "VIRTEX6" or SIM_DEVICE = "7SERIES")) then
         GenericValueCheckMessage
            ( HeaderMsg            => " Attribute Syntax Error ",
              GenericName          => " SIM_DEVICE ",
              EntityName           => "FIFO36E1",
              GenericValue         => SIM_DEVICE,
              Unit                 => "",
              ExpectedValueMsg     => " The Legal values for this attribute are ",
              ExpectedGenericValue => " VIRTEX6 or 7SERIES ",
              TailMsg              => "",
              MsgSeverity          => failure
              );
       end if;


       addr_limit <= addr_limit_var;
       fwft       <= fwft_var;
       ae_full    <= ae_full_var;
       ae_empty   <= ae_empty_var;
       first_time := false;
     end if;
     wait;
  end process prcs_initialize;



  prcs_check_almost_rdclk:process(RDCLK_dly)
      variable count_freq_rdclk_var : integer := 0;
      variable period_rdclk_var : time := 0 ps;
      variable rise_rdclk_var : time := 0 ps;
      variable Message : LINE;
      variable aempty_offset_stdlogic : std_logic_vector (ALMOST_EMPTY_OFFSET'length-1 downto 0);
      variable aempty_offset_int : integer := 0;
      variable afull_offset_stdlogic : std_logic_vector (ALMOST_FULL_OFFSET'length-1 downto 0);
      variable afull_offset_int : integer := 0;
      variable roundup_period_rd_wr_int : integer := 0;
      variable s7_roundup_period_rd_wr_int : integer := 0;
      variable roundup_period_wr_rd_int : integer := 0;
      variable period_rdclk_real_var : real := 0.0;
      variable period_wrclk_real_var : real := 0.0;

  begin

      if (rising_edge(RDCLK_dly)) then

          aempty_offset_stdlogic := To_StdLogicVector(ALMOST_EMPTY_OFFSET);
          aempty_offset_int := SLV_TO_INT(aempty_offset_stdlogic);
             
          afull_offset_stdlogic := To_StdLogicVector(ALMOST_FULL_OFFSET);
          afull_offset_int := SLV_TO_INT(afull_offset_stdlogic);
                
          count_freq_rdclk_var := count_freq_rdclk_var + 1;

          if (count_freq_rdclk_var = 100) then
              rise_rdclk_var := now;
          elsif (count_freq_rdclk_var = 101) then
              period_rdclk_var := now - rise_rdclk_var;
          
           if (count_freq_wrclk >= 101 and RST_dly = '0' and GSR_dly = '0') then

              -- Setup ranges for almostempty
              if (period_rdclk_var = period_wrclk) then
                                                    
                  if (EN_SYN = FALSE) then

                      if (SIM_DEVICE = "7SERIES") then
                    
                          if (fwft = '0') then

                              if ((aempty_offset_int < 5) or (aempty_offset_int > addr_limit - 6)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_EMPTY_OFFSET on FIFO36E1 is set to ") );
                                write( Message, aempty_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 5);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 6 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;
 
                              if ((afull_offset_int < 4) or (afull_offset_int > addr_limit - 7)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_FULL_OFFSET on FIFO36E1 is set to ") );
                                write( Message, afull_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 4);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 7 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;

                          else
           
                              if ((aempty_offset_int < 6) or (aempty_offset_int > addr_limit - 5)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_EMPTY_OFFSET on FIFO36E1 is set to ") );
                                write( Message, aempty_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 6);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 5 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;
 
                              if ((afull_offset_int < 4) or (afull_offset_int > addr_limit - 7)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_FULL_OFFSET on FIFO36E1 is set to ") );
                                write( Message, afull_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 4);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 7 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;

                          end if;

                      else

                          if (fwft = '0') then

                              if ((aempty_offset_int < 5) or (aempty_offset_int > addr_limit - 5)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_EMPTY_OFFSET on FIFO36E1 is set to ") );
                                write( Message, aempty_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 5);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 5 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;
 
                              if ((afull_offset_int < 4) or (afull_offset_int > addr_limit - 5)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_FULL_OFFSET on FIFO36E1 is set to ") );
                                write( Message, afull_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 4);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 5 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;

                          else
           
                              if ((aempty_offset_int < 6) or (aempty_offset_int > addr_limit - 4)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_EMPTY_OFFSET on FIFO36E1 is set to ") );
                                write( Message, aempty_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 6);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 4 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;
 
                              if ((afull_offset_int < 4) or (afull_offset_int > addr_limit - 5)) then
                                write( Message, STRING'("Attribute Syntax Error : ") );
                                write( Message, STRING'("The attribute ") );
                                write( Message, STRING'("ALMOST_FULL_OFFSET on FIFO36E1 is set to ") );
                                write( Message, afull_offset_int);
                                write( Message, STRING'(". Legal values for this attribute are ") );
                                write( Message, 4);
                                write( Message, STRING'(" to ") );
                                write( Message, addr_limit - 5 );
                                ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                                DEALLOCATE (Message);
                              end if;

                          end if;

                      end if;
                      
                  else
                    -- sync
           
                    if ((fwft = '0') and ((aempty_offset_int < 1) or (aempty_offset_int > addr_limit - 2))) then
                      write( Message, STRING'("Attribute Syntax Error : ") );
                      write( Message, STRING'("The attribute ") );
                      write( Message, STRING'("ALMOST_EMPTY_OFFSET on FIFO36E1 is set to ") );
                      write( Message, aempty_offset_int);
                      write( Message, STRING'(". Legal values for this attribute are ") );
                      write( Message, 1);
                      write( Message, STRING'(" to ") );
                      write( Message, addr_limit - 2 );
                      ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                      DEALLOCATE (Message);
                    end if;

                    if ((fwft = '0') and ((afull_offset_int < 1) or (afull_offset_int > addr_limit - 2))) then
                      write( Message, STRING'("Attribute Syntax Error : ") );
                      write( Message, STRING'("The attribute ") );
                      write( Message, STRING'("ALMOST_FULL_OFFSET on FIFO36E1 is set to ") );
                      write( Message, afull_offset_int);
                      write( Message, STRING'(". Legal values for this attribute are ") );
                      write( Message, 1);
                      write( Message, STRING'(" to ") );
                      write( Message, addr_limit - 2 );
                      ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                      DEALLOCATE (Message);
                    end if;

                  end if;

              else
                -- (period_rdclk_var /= period_wrclk)
                
                period_rdclk_real_var := real (period_rdclk_var / 1 ps);
                period_wrclk_real_var := real (period_wrclk / 1 ps);
              
                roundup_period_rd_wr_int := integer ((period_rdclk_real_var / period_wrclk_real_var) + 0.499);
                roundup_period_wr_rd_int := integer ((period_wrclk_real_var / period_rdclk_real_var) + 0.499);

                s7_roundup_period_rd_wr_int := integer ((4.0 * (period_rdclk_real_var / period_wrclk_real_var)) + 0.499);
                
                if (SIM_DEVICE = "7SERIES") then

                  if (afull_offset_int > (addr_limit - (s7_roundup_period_rd_wr_int + 6))) then
                    write( Message, STRING'("DRC Error : ") );
                    write( Message, STRING'("The attribute ") );
                    write( Message, STRING'("ALMOST_FULL_OFFSET on AFIFO36E1 is set to ") );
                    write( Message, afull_offset_int);
                    write( Message, STRING'(". It must be set to a value smaller than (FIFO_DEPTH - ((roundup (4 * (WRCLK frequency / RDCLK frequency))) + 6)) when FIFO36E1 has different frequencies for RDCLK and WRCLK.") );
                    ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                    DEALLOCATE (Message);
                  end if;

                else

                  if (afull_offset_int > (addr_limit - ((3 * roundup_period_wr_rd_int) + 3))) then
                    write( Message, STRING'("DRC Error : ") );
                    write( Message, STRING'("The attribute ") );
                    write( Message, STRING'("ALMOST_FULL_OFFSET on AFIFO36E1 is set to ") );
                    write( Message, afull_offset_int);
                    write( Message, STRING'(". It must be set to a value smaller than (FIFO_DEPTH - ((3 * roundup (RDCLK frequency / WRCLK frequency)) + 3)) when FIFO36E1 has different frequencies for RDCLK and WRCLK.") );
                    ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                    DEALLOCATE (Message);
                  end if;
                  

                  if (aempty_offset_int > (addr_limit - ((3 * roundup_period_rd_wr_int) + 3))) then
                    write( Message, STRING'("DRC Error : ") );
                    write( Message, STRING'("The attribute ") );
                    write( Message, STRING'("ALMOST_EMPTY_OFFSET on AFIFO36E1 is set to ") );
                    write( Message, aempty_offset_int);
                    write( Message, STRING'(". It must be set to a value smaller than (FIFO_DEPTH - ((3 * roundup (WRCLK frequency / RDCLK frequency)) + 3)) when FIFO36E1 has different frequencies for RDCLK and WRCLK.") );
                    ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
                    DEALLOCATE (Message);
                  end if;

                end if;
  
              end if;

              count_freq_rdclk_var := 0;
              count_freq_wrclk_reset <= not count_freq_wrclk_reset;

            end if;

         end if;

      end if;

  end process prcs_check_almost_rdclk;


  
  prcs_check_almost_wrclk:process(WRCLK_dly, count_freq_wrclk_reset)
      variable count_freq_wrclk_var : integer := 0;
      variable rise_wrclk_var : time := 0 ps;
    begin

      if(count_freq_wrclk_reset'event) then
        count_freq_wrclk_var := 0;
        count_freq_wrclk <= 0;
      end if;

        
      if (rising_edge(WRCLK_dly)) then

        count_freq_wrclk_var := count_freq_wrclk_var + 1;

        if (count_freq_wrclk_var = 100) then
          rise_wrclk_var := now;
        elsif (count_freq_wrclk_var = 101) then
          period_wrclk <= now - rise_wrclk_var;
        end if;

        count_freq_wrclk <= count_freq_wrclk_var;

      end if;
        
  end process prcs_check_almost_wrclk;

                                                       
  
  V6: if (SIM_DEVICE = "VIRTEX6") generate

    prcs_3clkrst_readwrite:process(RDCLK_dly, WRCLK_dly, rst_rdckreg_flag, rst_wrckreg_flag)
      variable  rst_rdckreg_var : std_logic_vector (4 downto 0) := (others => '0');
      variable  rst_wrckreg_var : std_logic_vector (4 downto 0) := (others => '0');
      variable  rden_rdckreg_var : std_logic_vector (3 downto 0) := (others => '0');
      variable  wren_wrckreg_var : std_logic_vector (3 downto 0) := (others => '0');
      variable  viol_rst_rden_var : std_logic := '0';
      variable  viol_rst_wren_var : std_logic := '0';

    begin

      if(rising_edge(RDCLK_dly)) then

        if (RST_dly = '1' and RDEN_dly = '1') then
          viol_rst_rden_var := '1';
        end if;
        
        if (RST_dly = '0') then
          rden_rdckreg_var(3 downto 0) := rden_rdckreg_var(2 downto 0) & RDEN_dly;
        end if;

        if (rden_rdckreg_var = "0000") then
          rst_rdckreg_var(2) := RST_dly and rst_rdckreg_var(1);
          rst_rdckreg_var(1) := RST_dly and rst_rdckreg_var(0);
          rst_rdckreg_var(0) := RST_dly;
        end if;   

      end if;


      if(rising_edge(WRCLK_dly)) then

        if (RST_dly = '1' and WREN_dly = '1') then
          viol_rst_wren_var := '1';
        end if;
        
        if (RST_dly = '0') then
          wren_wrckreg_var(3 downto 0) := wren_wrckreg_var(2 downto 0) & WREN_dly;
        end if;
        
        if (wren_wrckreg_var = "0000") then
          rst_wrckreg_var(2) := RST_dly and rst_wrckreg_var(1);
          rst_wrckreg_var(1) := RST_dly and rst_wrckreg_var(0);
          rst_wrckreg_var(0) := RST_dly;
        end if;   

      end if;
      
    
      if (rst_rdckreg_flag'event) then
        rst_rdckreg <= "00000";
        rst_rdckreg_var := "00000";
        viol_rst_rden <= '0';
        viol_rst_rden_var := '0';
      else
        rst_rdckreg <= rst_rdckreg_var;
        viol_rst_rden <= viol_rst_rden_var;
      end if;


      if (rst_wrckreg_flag'event) then
        rst_wrckreg <= "00000";
        rst_wrckreg_var := "00000";
        viol_rst_wren <= '0';
        viol_rst_wren_var := '0';
      else
        rst_wrckreg <= rst_wrckreg_var;
        viol_rst_wren <= viol_rst_wren_var;
      end if;
    
    end process prcs_3clkrst_readwrite;

  
    prcs_2clkrst:process(RST_dly)
      variable rst_rdclk_flag_var : std_logic := '0';
      variable rst_wrclk_flag_var : std_logic := '0';
    begin
      rst_rdclk_flag <= '0';
      rst_wrclk_flag <= '0';
      rst_rdclk_flag_var := '0';
      rst_wrclk_flag_var := '0';
      
      if(falling_edge(RST_dly)) then
        if(((rst_rdckreg(2) ='0') or (rst_rdckreg(1) ='0') or (rst_rdckreg(0) ='0')) or viol_rst_rden = '1') then  
          assert false
            report "DRC Error : Reset is unsuccessful.  RST must be held high for at least three RDCLK clock cycles, and RDEN must be low for four clock cycles before RST becomes active high, and RDEN remains low during this reset cycle."
            severity Error;
          rst_rdclk_flag <= '1';
          rst_rdclk_flag_var := '1';
        end if;
         
        if(((rst_wrckreg(2) ='0') or (rst_wrckreg(1) ='0') or (rst_wrckreg(0) ='0')) or viol_rst_wren = '1') then  
          assert false
            report "DRC Error : Reset is unsuccessful.  RST must be held high for at least three WRCLK clock cycles, and WREN must be low for four clock cycles before RST becomes active high, and WREN remains low during this reset cycle."
            severity Error;
          rst_wrclk_flag <= '1';
          rst_wrclk_flag_var := '1';
        end if;

        if (rst_rdclk_flag_var = '0' and rst_wrclk_flag_var = '0' and first_rst_flag = '0') then
          first_rst_flag <= '1';
        end if;
        
        rst_rdckreg_flag <= not rst_rdckreg_flag;
        rst_wrckreg_flag <= not rst_wrckreg_flag;

      end if;

      
    end process prcs_2clkrst;

    
  end generate V6;


  S_7: if (SIM_DEVICE = "7SERIES") generate

    prcs_rst_rden_after_rst:process(RDCLK_dly, WRCLK_dly, RST_dly)
      variable rst_trans_rden_1 : std_logic := '0';
      variable rst_trans_rden_2 : std_logic := '0';
      variable after_rst_rdclk : integer := 0;
      variable rst_trans_wren_1 : std_logic := '0';
      variable rst_trans_wren_2 : std_logic := '0';
      variable after_rst_wrclk : integer := 0;
      variable after_rst_rden_flag : std_logic := '0';
      variable after_rst_wren_flag : std_logic := '0';
    begin


        if (rising_edge(RST_dly)) then
          rst_trans_rden_1 := '1';
        elsif (falling_edge(RST_dly) and rst_trans_rden_1 = '1') then 
          rst_trans_rden_2 := '1';
        end if;

        
        if (rising_edge(RST_dly)) then
          rst_trans_wren_1 := '1';
        elsif (falling_edge(RST_dly) and rst_trans_wren_1 = '1') then 
          rst_trans_wren_2 := '1';
        end if;

        
       if (rising_edge(RST_dly)) then
         after_rst_x_flag <= '0';
         after_rst_rdclk := 0;
         after_rst_wrclk := 0;
       end if;

        
	if (rising_edge(RDCLK_dly)) then
		    
          if (rst_trans_rden_1 = '1' and rst_trans_rden_2 = '1') then
			
            after_rst_rdclk := after_rst_rdclk + 1;
			
            if (RDEN_dly = '1' and after_rst_rdclk <= 2) then

              after_rst_rden_flag := '1';
            
            elsif (after_rst_rdclk = 3) then
              rst_trans_rden_1 := '0';
              rst_trans_rden_2 := '0';

              if (after_rst_rden_flag = '1') then
                assert false
                  report "DRC Error : Reset is unsuccessful at time %t.  RDEN must be low for at least two RDCLK clock cycles after RST deasserted."
                  severity Error;

                after_rst_rden_flag := '0';
                after_rst_x_flag <= '1';
				
              end if;
            end if;
          end if;
        end if;

        
	if (rising_edge(WRCLK_dly)) then
		    
          if (rst_trans_wren_1 = '1' and rst_trans_wren_2 = '1') then
			
            after_rst_wrclk := after_rst_wrclk + 1;
			
            if (WREN_dly = '1' and after_rst_wrclk <= 2) then

              after_rst_wren_flag := '1';
            
            elsif (after_rst_wrclk = 3) then
              rst_trans_wren_1 := '0';
              rst_trans_wren_2 := '0';

              if (after_rst_wren_flag = '1') then
                assert false
                  report "DRC Error : Reset is unsuccessful at time %t.  WREN must be low for at least two WRCLK clock cycles after RST deasserted."
                  severity Error;

                after_rst_wren_flag := '0';
                after_rst_x_flag <= '1';
				
              end if;
            end if;
          end if;
        end if;
        
    end process prcs_rst_rden_after_rst;

        
    prcs_5clkrst_readwrite:process(RDCLK_dly, WRCLK_dly, rst_rdckreg_flag, rst_wrckreg_flag)
      variable  rst_rdckreg_var : std_logic_vector (4 downto 0) := (others => '0');
      variable  rst_wrckreg_var : std_logic_vector (4 downto 0) := (others => '0');
      variable  rden_rst_cnt_var  : integer := 0;
      variable  wren_rst_cnt_var  : integer := 0;   
      variable  viol_rst_rden_var : std_logic := '0';
      variable  viol_rst_wren_var : std_logic := '0';
      
    begin

      if(rising_edge(RDCLK_dly)) then

        if (RST_dly = '1' and RDEN_dly = '1') then
          viol_rst_rden_var := '1';
        end if;

        
        if (RDEN_dly = '0' and RST_dly = '1') then
          rst_rdckreg_var(4) := RST_dly and rst_rdckreg_var(3);
          rst_rdckreg_var(3) := RST_dly and rst_rdckreg_var(2);
          rst_rdckreg_var(2) := RST_dly and rst_rdckreg_var(1);
          rst_rdckreg_var(1) := RST_dly and rst_rdckreg_var(0);
          rst_rdckreg_var(0) := RST_dly;
        elsif (RDEN_dly = '1' and RST_dly = '1') then
          rst_rdckreg_var := "00000";
        end if;   

      end if;


      if(rising_edge(WRCLK_dly)) then

        if (RST_dly = '1' and WREN_dly = '1') then
          viol_rst_wren_var := '1';
        end if;
        
        
        if (WREN_dly = '0' and RST_dly = '1') then
          rst_wrckreg_var(4) := RST_dly and rst_wrckreg_var(3);
          rst_wrckreg_var(3) := RST_dly and rst_wrckreg_var(2);
          rst_wrckreg_var(2) := RST_dly and rst_wrckreg_var(1);
          rst_wrckreg_var(1) := RST_dly and rst_wrckreg_var(0);
          rst_wrckreg_var(0) := RST_dly;
        elsif (WREN_dly = '1' and RST_dly = '1') then
          rst_wrckreg_var := "00000";
        end if;   

      end if;

      
      if (rst_rdckreg_flag'event) then
        rst_rdckreg <= "00000";
        rst_rdckreg_var := "00000";
        viol_rst_rden <= '0';
        viol_rst_rden_var := '0';
      else
        rst_rdckreg <= rst_rdckreg_var;
        viol_rst_rden <= viol_rst_rden_var;
      end if;


      if (rst_wrckreg_flag'event) then
        rst_wrckreg <= "00000";
        rst_wrckreg_var := "00000";
        viol_rst_wren <= '0';
        viol_rst_wren_var := '0';
      else
        rst_wrckreg <= rst_wrckreg_var;
        viol_rst_wren <= viol_rst_wren_var;
      end if;
    
    end process prcs_5clkrst_readwrite;


    prcs_2clkrst:process(RST_dly)
      variable rst_rdclk_flag_var : std_logic := '0';
      variable rst_wrclk_flag_var : std_logic := '0';
    begin
      rst_rdclk_flag <= '0';
      rst_wrclk_flag <= '0';

      if(falling_edge(RST_dly)) then
        if(((rst_rdckreg(4) ='0') or (rst_rdckreg(3) ='0') or (rst_rdckreg(2) ='0') or (rst_rdckreg(1) ='0') or (rst_rdckreg(0) ='0')) or viol_rst_rden = '1') then  
          assert false
            report "DRC Error : Reset is unsuccessful.  RST must be held high for at least five RDCLK clock cycles, and RDEN must be low before RST becomes active high, and RDEN remains low during this reset cycle."
            severity Error;
          rst_rdclk_flag <= '1';
          rst_rdclk_flag_var := '1';
        end if;
         
        if(((rst_wrckreg(4) ='0') or (rst_wrckreg(3) ='0') or (rst_wrckreg(2) ='0') or (rst_wrckreg(1) ='0') or (rst_wrckreg(0) ='0')) or viol_rst_wren = '1') then  
          assert false
            report "DRC Error : Reset is unsuccessful.  RST must be held high for at least five WRCLK clock cycles, and WREN must be low before RST becomes active high, and WREN remains low during this reset cycle."
            severity Error;
          rst_wrclk_flag <= '1';
          rst_wrclk_flag_var := '1';
        end if;

        if (rst_rdclk_flag_var = '0' and rst_wrclk_flag_var = '0' and first_rst_flag = '0') then
          first_rst_flag <= '1';
        end if;
        
        rst_rdckreg_flag <= not rst_rdckreg_flag;
        rst_wrckreg_flag <= not rst_wrckreg_flag;

      end if;
      
    end process prcs_2clkrst;

    
  end generate S_7;


-- DRC
  prcs_rst_rden_drc:process
    begin
      if (now > 0 ps and (RDEN_dly = '1' or GSR_dly = '0')) then
        wait until (rising_edge(RDCLK_dly));
          if (first_rst_flag = '0' and RDEN_dly = '1') then
            assert false
              report "A RESET cycle must be observerd before the first use of the FIFO instance."
              severity Error;
          end if;
      end if;
      wait on RDEN_dly;
  end process prcs_rst_rden_drc;

  
  prcs_rst_wren_drc:process
    begin
      if (now > 0 ps and (WREN_dly = '1' or GSR_dly = '0')) then
        wait until (rising_edge(WRCLK_dly));
          if (first_rst_flag = '0' and WREN_dly = '1') then
            assert false
              report "A RESET cycle must be observerd before the first use of the FIFO instance."
              severity Error;
          end if;
      end if;
      wait on WREN_dly, GSR_dly;
  end process prcs_rst_wren_drc;

  
V6_read_write: if (SIM_DEVICE = "VIRTEX6") generate
    
--####################################################################
--#####                         Read                             #####
--####################################################################
  prcs_read:process(RDCLK_dly, RST_dly, GSR_dly, update_from_write_prcs, update_from_write_prcs_sync, rst_rdclk_flag, rst_wrclk_flag)
  variable first_time        : boolean    := true;
  variable rd_addr_var       : integer    := 0;
  variable wr_addr_var       : integer    := 0;
  variable rdcount_var       : integer    := 0;

  variable rd_flag_var       : std_ulogic := '0';
  variable wr_flag_var       : std_ulogic := '0';
  variable awr_flag_var       : std_ulogic := '0';  

  variable rdcount_flag_var  : std_ulogic := '0';

  variable do_in             : std_logic_vector(MSB_MAX_DO  downto 0)    := (others => '0');
  variable dop_in            : std_logic_vector(MSB_MAX_DOP downto 0)    := (others => '0');

  variable almostempty_int   : std_ulogic_vector(3 downto 0) := (others => '1');
  variable empty_int         : std_ulogic_vector(3 downto 0) := (others => '1');
  variable empty_ram         : std_ulogic_vector(3 downto 0) := (others => '1');

  variable addr_limit_var    : integer    := 0;

  variable wr1_addr_var      : integer := 0;
  variable wr1_flag_var      : std_ulogic := '0';
  variable rd_prefetch_var   : integer := 0;
  variable rd_prefetch_flag_var  : std_ulogic := '0';

-- CR 195129  fix from verilog (may not be necessary for vhdl)
-- Added ren_var/wren_var to remember the old val of RDEN_dly/WREN_dly

  variable rden_var  : std_ulogic := '0';
  variable wren_var  : std_ulogic := '0';

  variable do_buf : std_logic_vector(MSB_MAX_DO downto 0) := (others => '0');
  variable dop_buf : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable dopr_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable tmp_syndrome_int : integer;    
  variable syndrome : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable ecc_bit_position : std_logic_vector(71 downto 0) := (others => '0');
  variable di_dly_ecc_corrected : std_logic_vector(MSB_MAX_DO downto 0) := (others => '0');
  variable dip_dly_ecc_corrected : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable sbiterr_out : std_ulogic := '0';
  variable dbiterr_out : std_ulogic := '0';
  variable sbiterr_out_out_var : std_ulogic := '0';
  variable dbiterr_out_out_var : std_ulogic := '0';
  variable DO_OUTREG_var: std_logic_vector(MSB_MAX_DO downto 0) := (others => '0');
  variable DOP_OUTREG_var : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');

  begin


    if ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then

       rd_addr <= 0;
       rd_flag <= '0';

       rd_addr_var  := 0;
       wr_addr_var  := 0;
       wr1_addr_var := 0;
       rd_prefetch_var := 0;
   
       rdcount_var := 0;
       
       rd_flag_var  := '0';
       wr_flag_var  := '0';
       awr_flag_var  := '0';       
       wr1_flag_var := '0';
       rd_prefetch_flag_var := '0';
  
       rdcount_flag_var := '0';

       empty_int       :=  (others => '1');
       almostempty_int :=  (others => '1');
       empty_ram       :=  (others => '1');

       ALMOSTEMPTY_zd <= 'X';
       EMPTY_zd <= 'X';
       RDERR_zd <= 'X';
       RDCOUNT_zd <= (others => 'X');
       
       sbiterr_zd <= 'X';
       dbiterr_zd <= 'X';

    end if;
    
    
    if(RST_dly = '1') then

       rd_addr <= 0;
       rd_flag <= '0';

       rd_addr_var  := 0;
       wr_addr_var  := 0;
       wr1_addr_var := 0;
       rd_prefetch_var := 0;
   
       rdcount_var := 0;
       
       rd_flag_var  := '0';
       wr_flag_var  := '0';
       awr_flag_var  := '0';       
       wr1_flag_var := '0';
       rd_prefetch_flag_var := '0';
  
       rdcount_flag_var := '0';

       empty_int       :=  (others => '1');
       almostempty_int :=  (others => '1');
       empty_ram       :=  (others => '1');

       sbiterr_zd <= '0';
       dbiterr_zd <= '0';
       
       ALMOSTEMPTY_zd <= '1';
       EMPTY_zd <= '1';
       RDERR_zd <= '0';
       RDCOUNT_zd <= (others => '0');

    end if;

       
    if(GSR_dly = '1') then

         if (DO_REG = 1 and sync = '1') then
           
           DO_zd(mem_width-1 downto 0) <= INIT_STD(mem_width-1 downto 0);
           DO_OUTREG_zd(mem_width-1 downto 0) <= INIT_STD(mem_width-1 downto 0);
           do_in(mem_width-1 downto 0) := INIT_STD(mem_width-1 downto 0);
           do_buf(mem_width-1 downto 0) := INIT_STD(mem_width-1 downto 0);
           
           if (DATA_WIDTH /= 4) then
             DOP_zd(memp_width-1 downto 0) <= INIT_STD((memp_width+mem_width)-1 downto mem_width);
             DOP_OUTREG_zd(memp_width-1 downto 0) <= INIT_STD((memp_width+mem_width)-1 downto mem_width);
             dop_in(memp_width-1 downto 0) := INIT_STD((memp_width+mem_width)-1 downto mem_width);
             dop_buf(memp_width-1 downto 0) := INIT_STD((memp_width+mem_width)-1 downto mem_width);
           end if;

         else

           DO_zd((mem_width -1) downto 0) <= (others => '0');
           DO_OUTREG_zd((mem_width -1) downto 0) <= (others => '0');
           do_in((mem_width -1) downto 0) := (others => '0');
           do_buf((mem_width -1) downto 0) := (others => '0');
           
           if (DATA_WIDTH /= 4) then
             DOP_zd((memp_width -1) downto 0) <= (others => '0');
             DOP_OUTREG_zd((memp_width -1) downto 0) <= (others => '0');
             dop_in((memp_width -1) downto 0) := (others => '0');
             dop_buf((memp_width -1) downto 0) := (others => '0');
           end if;

         end if;

    elsif (GSR_dly = '0')then
       
       rden_var := RDEN_dly;
       wren_var := WREN_dly;

       if(rising_edge(RDCLK_dly)) then

         -- SRVAL in output register mode
         if (DO_REG = 1 and sync = '1' and rstreg_dly = '1') then
			
           DO_OUTREG_var(mem_width-1 downto 0) := SRVAL_STD(mem_width-1 downto 0);
         
           if (mem_width >= 8) then
             DOP_OUTREG_var(memp_width-1 downto 0) := SRVAL_STD((memp_width+mem_width)-1 downto mem_width);
           end if;

         end if;

         
         if (RST_dly = '0')then
         
          rd_flag_var := rd_flag;
          wr_flag_var := wr_flag;
          awr_flag_var := awr_flag;

          rd_addr_var := rd_addr;
          wr_addr_var := wr_addr;

          rdcount_var := SLV_TO_INT(RDCOUNT_zd);
          rdcount_flag_var := rdcount_flag;

         
          if (sync = '1') then

           -- output register
           if (DO_REG = 1 and regce_dly = '1' and rstreg_dly = '0') then
             
             DO_OUTREG_var := DO_zd;
             DOP_OUTREG_var := DOP_zd;
             dbiterr_out_out_var := dbiterr_out;
             sbiterr_out_out_var := sbiterr_out;
             
           end if;
            
                     
           if (RDEN_dly = '1') then

             if (EMPTY_zd = '0') then

               do_buf(mem_width-1 downto 0) := mem(rdcount_var);
               dop_buf(memp_width-1 downto 0) := memp(rdcount_var);

               -- ECC decode
               if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;

                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';  -- latch out in sync mode
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                   
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              

               end if;

               if (DO_REG = 0) then
                 dbiterr_out_out_var := dbiterr_out;
                 sbiterr_out_out_var := sbiterr_out;
               end if;

               
               DO_zd <= do_buf;
               DOP_zd <= dop_buf;

               rdcount_var := (rdcount_var + 1) mod addr_limit;

               if (rdcount_var = 0) then
                 rdcount_flag_var := not rdcount_flag_var;
               end if;

             end if;
           end if;


           if (RDEN_dly = '1' and EMPTY_zd = '1') then
             RDERR_zd <= '1';
           else
             RDERR_zd <= '0';
           end if;
           
           
           if (WREN_dly = '1') then
             EMPTY_zd <= '0';
           elsif (rdcount_var = wr_addr_var and rdcount_flag_var = wr_flag_var) then
             EMPTY_zd <= '1';
           end if;
             
           if((((rdcount_var + ae_empty) >= wr_addr_var) and (rdcount_flag_var = wr_flag_var)) or (((rdcount_var + ae_empty) >= (wr_addr_var + addr_limit)) and (rdcount_flag_var /= wr_flag_var))) then    
             ALMOSTEMPTY_zd <= '1';
           end if;

           update_from_read_prcs_sync <= not update_from_read_prcs_sync;

       elsif (sync = '0') then
         
         if(fwft = '0') then
           addr_limit_var := addr_limit;
           if((rden_var = '1') and (rd_addr_var /= rdcount_var)) then
              DO_zd   <= do_in;
              if (DATA_WIDTH /= 4) then
                DOP_zd  <= dop_in;
              end if;
              rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
              if(rd_addr_var = 0) then 
                  rd_flag_var := NOT rd_flag_var;
              end if;

              dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
              sbiterr_out_out_var := sbiterr_out;

           end if;
           if (((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or 
              ((rden_var = '1') and (empty_ram(1) = '0'))) then
                do_buf(mem_width-1 downto 0) := mem(rdcount_var);
                dop_buf(memp_width-1 downto 0) := memp(rdcount_var);

 
                -- ECC decode
                if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;
                     
                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                     
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              

              end if;

                
              do_in := do_buf;
              dop_in := dop_buf;
                 
                
              rdcount_var := (rdcount_var + 1) mod addr_limit;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;
         
         elsif(fwft = '1') then
           if((rden_var = '1') and (rd_addr_var /= rd_prefetch_var)) then
              rd_prefetch_var := (rd_prefetch_var + 1) mod addr_limit;
              if(rd_prefetch_var = 0) then 
                  rd_prefetch_flag_var := NOT rd_prefetch_flag_var;
              end if;
           end if;
           if((rd_prefetch_var = rd_addr_var) and (rd_addr_var /= rdcount_var)) then
             DO_zd   <= do_in;
             if (DATA_WIDTH /= 4) then
               DOP_zd <= dop_in;
             end if;
             rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
             if(rd_addr_var = 0) then 
                rd_flag_var := NOT rd_flag_var;
             end if;

             dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
             sbiterr_out_out_var := sbiterr_out;
             
           end if;
           if(((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or
              ((rden_var = '1')  and (empty_ram(1) = '0')) or 
              ((rden_var = '0')  and (empty_ram(1) = '0') and (rd_addr_var = rdcount_var))) then 
                do_buf(mem_width-1 downto 0) := mem(rdcount_var);
                dop_buf(memp_width-1 downto 0) := memp(rdcount_var);

                -- ECC decode
               if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;                     
                     
                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                   
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              
               end if;

                
              do_in := do_buf;
              dop_in := dop_buf;
                 
                
              rdcount_var := (rdcount_var + 1) mod addr_limit;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;

       end if;  ---  end if(fwft = '1')


         ALMOSTEMPTY_zd <= almostempty_int(3);

         if((((rdcount_var + ae_empty) >= wr_addr_var) and (rdcount_flag_var = awr_flag_var)) or (((rdcount_var + ae_empty) >= (wr_addr_var + addr_limit)) and (rdcount_flag_var /= awr_flag_var))) then    
            almostempty_int(3) := '1';
            almostempty_int(2) := '1';
            almostempty_int(1) := '1';
            almostempty_int(0) := '1';
         elsif(almostempty_int(2)  = '0') then
           -- added to match verilog
           if (rdcount_var <= rdcount_var + ae_empty or rdcount_flag_var /= awr_flag_var) then
            almostempty_int(3) :=  almostempty_int(0);
            almostempty_int(0) :=  '0';
           end if;
         end if;

         if(fwft = '0') then
           if((rdcount_var = rd_addr_var) and (rdcount_flag_var = rd_flag_var)) then
              EMPTY_zd <= '1';
           else
             EMPTY_zd  <= '0';
           end if;
         elsif(fwft = '1') then
           if((rd_prefetch_var = rd_addr_var) and (rd_prefetch_flag_var = rd_flag_var)) then
             EMPTY_zd <=  '1';
           else
             EMPTY_zd  <= '0';
           end if;
         end if;   
          
         if((rdcount_var = wr_addr_var) and (rdcount_flag_var = awr_flag_var)) then
           empty_ram(2) := '1';
           empty_ram(1) := '1';
           empty_ram(0) := '1';
         else
           empty_ram(2) := empty_ram(1);
           empty_ram(1) := empty_ram(0);
           empty_ram(0) := '0';
         end if;
           
         if((rdcount_var = wr1_addr_var) and (rdcount_flag_var = wr1_flag_var)) then
           empty_ram(3) := '1';
         else
           empty_ram(3) := '0';
         end if;

         wr1_addr_var := wr_addr;
         wr1_flag_var := awr_flag;

         if((rden_var = '1') and (EMPTY_zd = '1')) then
             RDERR_zd <= '1';
         else
             RDERR_zd <= '0';
         end if; -- end ((rden_var = '1') and (empty_int /= '1'))

        update_from_read_prcs <= NOT update_from_read_prcs;

       end if;

      end if; -- end (RST_dly = '0')

    end if; -- end (rising_edge(RDCLK_dly))

  end if; -- end (GSR_dly = 1)



     if(update_from_write_prcs_sync'event) then
       wr_addr_var := wr_addr;
       wr_flag_var := wr_flag;
       if((((rdcount_var + ae_empty) <  wr_addr_var)  and (rdcount_flag_var = wr_flag_var)) or 
          (((rdcount_var + ae_empty) < (wr_addr_var + addr_limit)) and (rdcount_flag_var /= wr_flag_var))) then    
          if(rdcount_var <= rdcount_var + ae_empty or rdcount_flag_var /= wr_flag_var) then
            almostempty_zd <= '0';
          end if;
       end if;
     end if;
  
     
     if(update_from_write_prcs'event) then
       wr_addr_var := wr_addr;
       wr_flag_var := wr_flag;
       awr_flag_var := awr_flag;

       if((((rdcount_var + ae_empty) <  wr_addr_var)  and (rdcount_flag_var = awr_flag_var)) or 
          (((rdcount_var + ae_empty) <  ( wr_addr_var + addr_limit)) and (rdcount_flag_var /= awr_flag_var))) then    
         if(wren_var = '1') then
             almostempty_int(2) := almostempty_int(1);
             almostempty_int(1) := '0';
          end if;
       else
           almostempty_int(2) := '1';
           almostempty_int(1) := '1';
       end if;
     end if;
  
  
     if (not (rst_rdclk_flag or rst_wrclk_flag) = '1') then
       RDCOUNT_zd <= CONV_STD_LOGIC_VECTOR(rdcount_var, MAX_RDCOUNT);       
       dbiterr_zd <= dbiterr_out_out_var;
       sbiterr_zd <= sbiterr_out_out_var;
     end if;

     rd_addr <= rd_addr_var;
     rd_flag <= rd_flag_var;
     rdcount_flag <= rdcount_flag_var;
     DO_OUTREG_zd <= DO_OUTREG_var;
     DOP_OUTREG_zd <= DOP_OUTREG_var;

  end process prcs_read;

--####################################################################
--#####                         Write                            #####
--####################################################################
  prcs_write:process(WRCLK_dly, RST_dly, GSR_dly, update_from_read_prcs, update_from_read_prcs_sync, rst_rdclk_flag, rst_wrclk_flag)
  variable first_time        : boolean    := true;
  variable wr_addr_var       : integer := 0;
  variable rd_addr_var       : integer := 0;
  variable rdcount_var       : integer := 0;
  variable wrcount_var       : integer := 0;

  variable rd_flag_var       : std_ulogic := '0';
  variable wr_flag_var       : std_ulogic := '0';
  variable awr_flag_var       : std_ulogic := '0';

  variable rdcount_flag_var  : std_ulogic := '0';

  variable almostfull_int : std_ulogic_vector(3 downto 0) := (others => '0');
  variable full_int       : std_ulogic_vector(3 downto 0) := (others => '0');

-- CR 195129  fix from verilog (may not be necessary for vhdl)
-- Added ren_var/wren_var to remember the old val of RDEN_dly/WREN_dly

  variable rden_var  : std_ulogic := '0';
  variable wren_var  : std_ulogic := '0';
  variable di_ecc_col : std_logic_vector(63 downto 0) := (others => '0');
  variable dip_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable dip_dly_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable ALMOSTFULL_var : std_ulogic     :=    '0';

  begin
    if ((RST_dly = '1') or (rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then
        wr_addr_var := 0;
        wr_addr <=  0;
        wr_flag <= '0';
        awr_flag <= '0';
        
        wr_addr_var := 0;
        rd_addr_var := 0;
        rdcount_var := 0;
        wrcount_var := 0;
        ALMOSTFULL_var := '0';
   
        rd_flag_var := '0';
        wr_flag_var := '0';
        awr_flag_var := '0';

        rdcount_flag_var  := '0';

        full_int       :=  (others => '0');
        almostfull_int :=  (others => '0');

        if ((GSR_dly = '1') or (RST_dly = '1'))then
          ALMOSTFULL_zd <= '0';      
          FULL_zd <= '0';            
          WRERR_zd <= '0';           
          WRCOUNT_zd <= (others => '0');
        else
          ALMOSTFULL_zd <= 'X';       
          FULL_zd <= 'X';             
          WRERR_zd <= 'X';            
          WRCOUNT_zd <= (others => 'X');
          eccparity_zd <= (others => 'X');
        end if;

    end if;
    
    if((GSR_dly = '0') and (RST_dly = '1'))then  -- match HW eccparity output when RST = 1

      if(rising_edge(WRCLK_dly)) then
        if(wren_dly = '1') then
          if (full_zd= '0') then

            -- ECC encode
            if (EN_ECC_WRITE = TRUE) then

              -- regenerate parity
              dip_ecc(0) := di_dly(0) xor di_dly(1) xor di_dly(3) xor di_dly(4) xor di_dly(6) xor di_dly(8)
		      xor di_dly(10) xor di_dly(11) xor di_dly(13) xor di_dly(15) xor di_dly(17) xor di_dly(19)
		      xor di_dly(21) xor di_dly(23) xor di_dly(25) xor di_dly(26) xor di_dly(28)
            	      xor di_dly(30) xor di_dly(32) xor di_dly(34) xor di_dly(36) xor di_dly(38)
		      xor di_dly(40) xor di_dly(42) xor di_dly(44) xor di_dly(46) xor di_dly(48)
		      xor di_dly(50) xor di_dly(52) xor di_dly(54) xor di_dly(56) xor di_dly(57) xor di_dly(59)
		      xor di_dly(61) xor di_dly(63);

              dip_ecc(1) := di_dly(0) xor di_dly(2) xor di_dly(3) xor di_dly(5) xor di_dly(6) xor di_dly(9)
                      xor di_dly(10) xor di_dly(12) xor di_dly(13) xor di_dly(16) xor di_dly(17)
                      xor di_dly(20) xor di_dly(21) xor di_dly(24) xor di_dly(25) xor di_dly(27) xor di_dly(28)
                      xor di_dly(31) xor di_dly(32) xor di_dly(35) xor di_dly(36) xor di_dly(39)
                      xor di_dly(40) xor di_dly(43) xor di_dly(44) xor di_dly(47) xor di_dly(48)
                      xor di_dly(51) xor di_dly(52) xor di_dly(55) xor di_dly(56) xor di_dly(58) xor di_dly(59)
                      xor di_dly(62) xor di_dly(63);

              dip_ecc(2) := di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17)
                      xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48)
                      xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);
	
              dip_ecc(3) := di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
		      xor di_dly(10) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(4) := di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);


              dip_ecc(5) := di_dly(26) xor di_dly(27) xor di_dly(28) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38)
	              xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47)
                      xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(6) := di_dly(57) xor di_dly(58) xor di_dly(59)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              dip_ecc(7) := dip_ecc(0) xor dip_ecc(1) xor dip_ecc(2) xor dip_ecc(3) xor dip_ecc(4) xor dip_ecc(5) xor dip_ecc(6)
                      xor di_dly(0) xor di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18)
                      xor di_dly(19) xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(26) xor di_dly(27)
                      xor di_dly(28) xor di_dly(29) xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36)
                      xor di_dly(37) xor di_dly(38) xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45)
                      xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54)
                      xor di_dly(55) xor di_dly(56) xor di_dly(57) xor di_dly(58) xor di_dly(59) xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              ECCPARITY_zd <= dip_ecc;

            end if;
          end if;
        end if;
      end if;
        
    elsif((GSR_dly = '0') and (RST_dly = '0') and (rst_rdclk_flag = '0') and (rst_wrclk_flag = '0'))then
      rden_var := RDEN_dly;
      wren_var := WREN_dly;

      if(rising_edge(WRCLK_dly)) then

        rd_flag_var := rd_flag;
        wr_flag_var := wr_flag;
        awr_flag_var := awr_flag;        

        rd_addr_var := rd_addr;
        wr_addr_var := wr_addr;

        rdcount_var := SLV_TO_INT(RDCOUNT_zd);
        rdcount_flag_var := rdcount_flag;


        if (not(EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE)) then
      
          if (injectsbiterr_dly = '1') then
            assert false
              report "DRC Warning : INJECTSBITERR is not supported when neither EN_ECC_WRITE nor EN_ECCREAD = TRUE on FIFO36E1 instance."
              severity Warning;
          end if;

          if (injectdbiterr_dly = '1') then
            assert false
            report "DRC Warning : INJECTDBITERR is not supported when neither EN_ECC_WRITE nor EN_ECCREAD = TRUE on FIFO36E1 instance."
            severity Warning;
          end if;

        end if;

        
	if (sync = '1') then
          if(wren_dly = '1') then
            if (full_zd= '0') then

            -- ECC encode
            if (EN_ECC_WRITE = TRUE) then

              -- regenerate parity
              dip_ecc(0) := di_dly(0) xor di_dly(1) xor di_dly(3) xor di_dly(4) xor di_dly(6) xor di_dly(8)
		      xor di_dly(10) xor di_dly(11) xor di_dly(13) xor di_dly(15) xor di_dly(17) xor di_dly(19)
		      xor di_dly(21) xor di_dly(23) xor di_dly(25) xor di_dly(26) xor di_dly(28)
            	      xor di_dly(30) xor di_dly(32) xor di_dly(34) xor di_dly(36) xor di_dly(38)
		      xor di_dly(40) xor di_dly(42) xor di_dly(44) xor di_dly(46) xor di_dly(48)
		      xor di_dly(50) xor di_dly(52) xor di_dly(54) xor di_dly(56) xor di_dly(57) xor di_dly(59)
		      xor di_dly(61) xor di_dly(63);

              dip_ecc(1) := di_dly(0) xor di_dly(2) xor di_dly(3) xor di_dly(5) xor di_dly(6) xor di_dly(9)
                      xor di_dly(10) xor di_dly(12) xor di_dly(13) xor di_dly(16) xor di_dly(17)
                      xor di_dly(20) xor di_dly(21) xor di_dly(24) xor di_dly(25) xor di_dly(27) xor di_dly(28)
                      xor di_dly(31) xor di_dly(32) xor di_dly(35) xor di_dly(36) xor di_dly(39)
                      xor di_dly(40) xor di_dly(43) xor di_dly(44) xor di_dly(47) xor di_dly(48)
                      xor di_dly(51) xor di_dly(52) xor di_dly(55) xor di_dly(56) xor di_dly(58) xor di_dly(59)
                      xor di_dly(62) xor di_dly(63);

              dip_ecc(2) := di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17)
                      xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48)
                      xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);
	
              dip_ecc(3) := di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
		      xor di_dly(10) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(4) := di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);


              dip_ecc(5) := di_dly(26) xor di_dly(27) xor di_dly(28) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38)
	              xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47)
                      xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(6) := di_dly(57) xor di_dly(58) xor di_dly(59)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              dip_ecc(7) := dip_ecc(0) xor dip_ecc(1) xor dip_ecc(2) xor dip_ecc(3) xor dip_ecc(4) xor dip_ecc(5) xor dip_ecc(6)
                      xor di_dly(0) xor di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18)
                      xor di_dly(19) xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(26) xor di_dly(27)
                      xor di_dly(28) xor di_dly(29) xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36)
                      xor di_dly(37) xor di_dly(38) xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45)
                      xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54)
                      xor di_dly(55) xor di_dly(56) xor di_dly(57) xor di_dly(58) xor di_dly(59) xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              ECCPARITY_zd <= dip_ecc;

              dip_dly_ecc := dip_ecc;  -- only 64 bits width

            else

              dip_dly_ecc := dip_dly; -- only 64 bits width

            end if;


            -- injecting error
            di_ecc_col := di_dly;

            if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then
               
              if (injectdbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
                di_ecc_col(62) := not(di_ecc_col(62));
              elsif (injectsbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
              end if;

            end if;

            
            mem(wr_addr_var) <= di_ecc_col(mem_width-1 downto 0);
            memp(wr_addr_var) <= dip_dly_ecc(memp_width-1 downto 0);

            wr_addr_var := (wr_addr_var + 1) mod addr_limit;

            if(wr_addr_var = 0) then
              wr_flag_var := NOT wr_flag_var;
            end if;

          end if;
        end if;


        if ((WREN_dly = '1') and (FULL_zd = '1')) then
          WRERR_zd <= '1';
        else
          WRERR_zd <= '0';
        end if;

        
        if (rden_dly = '1') then
          full_zd <= '0';
        elsif (rdcount_var = wr_addr_var and rdcount_flag_var /= wr_flag_var) then
          full_zd <= '1';
        end if;

        update_from_write_prcs_sync <= NOT update_from_write_prcs_sync;

        if((((rdcount_var + addr_limit) <= (wr_addr_var + ae_full)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var <= (wr_addr_var + ae_full)) and (rdcount_flag_var /= wr_flag_var))) then
          almostfull_zd <= '1';
        end if;
        

      elsif (sync = '0') then

        if((wren_var = '1') and (full_zd = '0'))then  

          -- ECC encode
            if (EN_ECC_WRITE = TRUE) then

              -- regenerate parity
              dip_ecc(0) := di_dly(0) xor di_dly(1) xor di_dly(3) xor di_dly(4) xor di_dly(6) xor di_dly(8)
		      xor di_dly(10) xor di_dly(11) xor di_dly(13) xor di_dly(15) xor di_dly(17) xor di_dly(19)
		      xor di_dly(21) xor di_dly(23) xor di_dly(25) xor di_dly(26) xor di_dly(28)
            	      xor di_dly(30) xor di_dly(32) xor di_dly(34) xor di_dly(36) xor di_dly(38)
		      xor di_dly(40) xor di_dly(42) xor di_dly(44) xor di_dly(46) xor di_dly(48)
		      xor di_dly(50) xor di_dly(52) xor di_dly(54) xor di_dly(56) xor di_dly(57) xor di_dly(59)
		      xor di_dly(61) xor di_dly(63);

              dip_ecc(1) := di_dly(0) xor di_dly(2) xor di_dly(3) xor di_dly(5) xor di_dly(6) xor di_dly(9)
                      xor di_dly(10) xor di_dly(12) xor di_dly(13) xor di_dly(16) xor di_dly(17)
                      xor di_dly(20) xor di_dly(21) xor di_dly(24) xor di_dly(25) xor di_dly(27) xor di_dly(28)
                      xor di_dly(31) xor di_dly(32) xor di_dly(35) xor di_dly(36) xor di_dly(39)
                      xor di_dly(40) xor di_dly(43) xor di_dly(44) xor di_dly(47) xor di_dly(48)
                      xor di_dly(51) xor di_dly(52) xor di_dly(55) xor di_dly(56) xor di_dly(58) xor di_dly(59)
                      xor di_dly(62) xor di_dly(63);

              dip_ecc(2) := di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17)
                      xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48)
                      xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);
	
              dip_ecc(3) := di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
		      xor di_dly(10) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(4) := di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);


              dip_ecc(5) := di_dly(26) xor di_dly(27) xor di_dly(28) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38)
	              xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47)
                      xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(6) := di_dly(57) xor di_dly(58) xor di_dly(59)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              dip_ecc(7) := dip_ecc(0) xor dip_ecc(1) xor dip_ecc(2) xor dip_ecc(3) xor dip_ecc(4) xor dip_ecc(5) xor dip_ecc(6)
                      xor di_dly(0) xor di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18)
                      xor di_dly(19) xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(26) xor di_dly(27)
                      xor di_dly(28) xor di_dly(29) xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36)
                      xor di_dly(37) xor di_dly(38) xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45)
                      xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54)
                      xor di_dly(55) xor di_dly(56) xor di_dly(57) xor di_dly(58) xor di_dly(59) xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              ECCPARITY_zd <= dip_ecc;

              dip_dly_ecc := dip_ecc;  -- only 64 bits width

            else

              dip_dly_ecc := dip_dly; -- only 64 bits width

            end if;

            
            -- injecting error
            di_ecc_col := di_dly;

            if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then
              
              if (injectdbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
                di_ecc_col(62) := not(di_ecc_col(62));
              elsif (injectsbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
              end if;

            end if;
            
            
            mem(wr_addr_var) <= di_ecc_col(mem_width-1 downto 0);
            if (DATA_WIDTH >= 9) then
              memp(wr_addr_var) <= dip_dly_ecc(memp_width-1 downto 0);              
            end if;
                
            wr_addr_var := (wr_addr_var + 1) mod addr_limit;
         
            if(wr_addr_var = 0) then
              awr_flag_var := NOT awr_flag_var;
            end if;

            if(wr_addr_var = addr_limit - 1) then
              wr_flag_var := NOT wr_flag_var;
            end if;
            
        end if; -- if((wren_var = '1') and (FULL_zd = '0') ....      

        if((wren_var = '1') and (full_zd = '1')) then 
            WRERR_zd <= '1';
        else
            WRERR_zd <= '0';
        end if;

        ALMOSTFULL_var := almostfull_int(3);
        
        if((((rdcount_var + addr_limit) <= (wr_addr_var + ae_full)) and (rdcount_flag_var = awr_flag_var)) or ((rdcount_var <= (wr_addr_var + ae_full)) and (rdcount_flag_var /= awr_flag_var))) then    
          almostfull_int(3) := '1';
          almostfull_int(2) := '1';
          almostfull_int(1) := '1';
          almostfull_int(0) := '1';
        elsif(almostfull_int(2)  = '0') then
          if (wr_addr_var <= wr_addr_var + ae_full or rdcount_flag_var = awr_flag_var) then

            almostfull_int(3) := almostfull_int(0);
            almostfull_int(0) :=  '0';

          end if;
        end if;

        if (wren_var = '1' or full_zd = '1') then
          full_zd <= full_int(1);
        end if;

        if(((rdcount_var = wr_addr_var) or (rdcount_var - 1 = wr_addr_var or rdcount_var + addr_limit - 1 = wr_addr_var)) and ALMOSTFULL_var = '1') then
          full_int(1) := '1';
          full_int(0) := '1';
        else
          full_int(1) := full_int(0);
          full_int(0) := '0';
        end if;

        update_from_write_prcs <= NOT update_from_write_prcs;
        ALMOSTFULL_zd <= ALMOSTFULL_var;

      end if; -- if (sync)
  
        WRCOUNT_zd <= CONV_STD_LOGIC_VECTOR( wr_addr_var, MAX_WRCOUNT);

        wr_addr <= wr_addr_var;
        wr_flag <= wr_flag_var;
        awr_flag <= awr_flag_var;

    end if; -- if(rising(WRCLK_dly))

  end if; -- if(GSR_dly = '1'))


    if(update_from_read_prcs_sync'event) then
      rdcount_var := SLV_TO_INT(RDCOUNT_zd);
      rdcount_flag_var := rdcount_flag;
      if((((rdcount_var + addr_limit) > (wr_addr_var + ae_full)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var > (wr_addr_var + ae_full)) and (rdcount_flag_var /= wr_flag_var))) then
        if (wr_addr_var <= wr_addr_var + ae_full or rdcount_flag_var = wr_flag_var) then
          ALMOSTFULL_zd <= '0';
        end if;
      end if;
    end if;

    if(update_from_read_prcs'event) then
       rdcount_var := SLV_TO_INT(RDCOUNT_zd);
       rdcount_flag_var := rdcount_flag;

       if((((rdcount_var + addr_limit) > (wr_addr_var + ae_full)) and (rdcount_flag_var = awr_flag_var)) or ((rdcount_var > (wr_addr_var + ae_full)) and (rdcount_flag_var /= awr_flag_var))) then    

           if(((rden_var = '1') and (EMPTY_zd = '0')) or ((((rd_addr_var + 1) mod addr_limit) = rdcount_var) and (almostfull_int(1) = '1'))) then
              almostfull_int(2) := almostfull_int(1);
              almostfull_int(1) := '0';
           end if;
       else
           almostfull_int(2) := '1';
           almostfull_int(1) := '1';
       end if;
    end if;

  end process prcs_write;

end generate V6_read_write;


S7_read_write : if (SIM_DEVICE = "7SERIES") generate

  prcs_time_rd : process(RDCLK_dly)
    begin
      if (rising_edge(RDCLK_dly)) then
        time_rdclk <= now;
      end if;
  end process prcs_time_rd;

  
  prcs_time_wr : process(WRCLK_dly)
    begin
      if (rising_edge(WRCLK_dly)) then
        time_wrclk <= now;
      end if;
  end process prcs_time_wr;
  

  prcs_sync_clk_async_mode : process(time_rdclk, time_wrclk)
    begin
      if ((time_rdclk - time_wrclk = 0 ps or time_wrclk - time_rdclk = 0 ps) and now /= 0 ps) then
        sync_clk_async_mode <= '1';
      end if;
  end process prcs_sync_clk_async_mode;
      
  
--####################################################################
--#####                         Read                             #####
--####################################################################
  prcs_read:process(RDCLK_dly, RST_dly, GSR_dly, update_from_write_prcs, update_from_write_prcs_sync, rst_rdclk_flag, rst_wrclk_flag, after_rst_x_flag)
  variable first_time        : boolean    := true;
  variable rd_addr_var       : integer    := 0;
  variable wr_addr_var       : integer    := 0;
  variable wr_addr_sync_3_var : integer   := 0;
  variable wr_addr_sync_2_var : integer   := 0;
  variable wr_addr_sync_1_var : integer   := 0;

  variable rdcount_var         : integer    := 0;
  variable rdcount_m1_temp_var : integer    := 0;

  variable rd_flag_var       : std_ulogic := '0';
  variable wr_flag_var       : std_ulogic := '0';
  variable awr_flag_var       : std_ulogic := '0';  

  variable rdcount_flag_var  : std_ulogic := '0';

  variable do_in             : std_logic_vector(MSB_MAX_DO  downto 0)    := (others => '0');
  variable dop_in            : std_logic_vector(MSB_MAX_DOP downto 0)    := (others => '0');

  variable almostempty_int   : std_ulogic_vector(3 downto 0) := (others => '1');
  variable empty_int         : std_ulogic_vector(3 downto 0) := (others => '1');
  variable empty_ram         : std_ulogic_vector(3 downto 0) := (others => '1');

  variable addr_limit_var    : integer    := 0;

  variable wr1_addr_var      : integer := 0;
  variable wr1_flag_var      : std_ulogic := '0';
  variable rd_prefetch_var   : integer := 0;
  variable rd_prefetch_flag_var  : std_ulogic := '0';

  variable rden_var  : std_ulogic := '0';
  variable wren_var  : std_ulogic := '0';

  variable do_buf : std_logic_vector(MSB_MAX_DO downto 0) := (others => '0');
  variable dop_buf : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable dopr_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable tmp_syndrome_int : integer;    
  variable syndrome : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable ecc_bit_position : std_logic_vector(71 downto 0) := (others => '0');
  variable di_dly_ecc_corrected : std_logic_vector(MSB_MAX_DO downto 0) := (others => '0');
  variable dip_dly_ecc_corrected : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable sbiterr_out : std_ulogic := '0';
  variable dbiterr_out : std_ulogic := '0';
  variable sbiterr_out_out_var : std_ulogic := '0';
  variable dbiterr_out_out_var : std_ulogic := '0';
  variable DO_OUTREG_var: std_logic_vector(MSB_MAX_DO downto 0) := (others => '0');
  variable DOP_OUTREG_var : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable awr_flag_sync_1_var : std_ulogic := '0';
  variable awr_flag_sync_2_var : std_ulogic := '0';
  variable awr_flag_sync_3_var : std_ulogic := '0';
  
  begin

    if (rising_edge(RDCLK_dly)) then
         wr_addr_sync_3_var := wr_addr_sync_2_var;
         wr_addr_sync_2_var := wr_addr_sync_1_var;
         wr_addr_sync_1_var := wr_addr_7s;

         awr_flag_sync_3_var := awr_flag_sync_2_var;
         awr_flag_sync_2_var := awr_flag_sync_1_var;
         awr_flag_sync_1_var := awr_flag;
    end if;


    if ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1') or (after_rst_x_flag = '1'))then

       rd_addr_7s <= 0;
       rd_flag <= '0';

       rd_addr_var  := 0;
       wr_addr_var  := 0;
       wr1_addr_var := 0;
       rd_prefetch_var := 0;

       rdcount_var := 0;
       
       rd_flag_var  := '0';
       wr_flag_var  := '0';
       awr_flag_var  := '0';       
       wr1_flag_var := '0';
       rd_prefetch_flag_var := '0';
  
       rdcount_flag_var := '0';

       empty_int       :=  (others => '1');
       almostempty_int :=  (others => '1');
       empty_ram       :=  (others => '1');

       ALMOSTEMPTY_zd <= 'X';
       EMPTY_zd <= 'X';
       RDERR_zd <= 'X';
       RDCOUNT_zd <= (others => 'X');
       
       sbiterr_zd <= 'X';
       dbiterr_zd <= 'X';

       rdcount_m1 <= -1;
       wr_addr_sync_3_var := 0;
       
    end if;
    
    
    if(RST_dly = '1') then

       rd_addr_7s <= 0;
       rd_flag <= '0';

       rd_addr_var  := 0;
       wr_addr_var  := 0;
       wr1_addr_var := 0;
       rd_prefetch_var := 0;
   
       rdcount_var := 0;
       
       rd_flag_var  := '0';
       wr_flag_var  := '0';
       awr_flag_var  := '0';       
       wr1_flag_var := '0';
       rd_prefetch_flag_var := '0';
  
       rdcount_flag_var := '0';

       empty_int       :=  (others => '1');
       almostempty_int :=  (others => '1');
       empty_ram       :=  (others => '1');

       sbiterr_zd <= '0';
       dbiterr_zd <= '0';
       
       ALMOSTEMPTY_zd <= '1';
       EMPTY_zd <= '1';
       RDERR_zd <= '0';
       RDCOUNT_zd <= (others => '0');

       rdcount_m1 <= -1;
       wr_addr_sync_3_var := 0;


       if (fwft_prefetch_flag = 1) then

         set_fwft_prefetch_flag_to_0 <= NOT set_fwft_prefetch_flag_to_0;

         DO_zd <= do_in;

         if (DATA_WIDTH /= 4) then
           DOP_zd <= dop_in;
         end if;

       end if;

    end if;

    
    if(GSR_dly = '1') then

         if (DO_REG = 1 and sync = '1') then
           
           DO_zd(mem_width-1 downto 0) <= INIT_STD(mem_width-1 downto 0);
           DO_OUTREG_zd(mem_width-1 downto 0) <= INIT_STD(mem_width-1 downto 0);
           do_in(mem_width-1 downto 0) := INIT_STD(mem_width-1 downto 0);
           do_buf(mem_width-1 downto 0) := INIT_STD(mem_width-1 downto 0);
           
           if (DATA_WIDTH /= 4) then
             DOP_zd(memp_width-1 downto 0) <= INIT_STD((memp_width+mem_width)-1 downto mem_width);
             DOP_OUTREG_zd(memp_width-1 downto 0) <= INIT_STD((memp_width+mem_width)-1 downto mem_width);
             dop_in(memp_width-1 downto 0) := INIT_STD((memp_width+mem_width)-1 downto mem_width);
             dop_buf(memp_width-1 downto 0) := INIT_STD((memp_width+mem_width)-1 downto mem_width);
           end if;

         else

           DO_zd((mem_width -1) downto 0) <= (others => '0');
           DO_OUTREG_zd((mem_width -1) downto 0) <= (others => '0');
           do_in((mem_width -1) downto 0) := (others => '0');
           do_buf((mem_width -1) downto 0) := (others => '0');
           
           if (DATA_WIDTH /= 4) then
             DOP_zd((memp_width -1) downto 0) <= (others => '0');
             DOP_OUTREG_zd((memp_width -1) downto 0) <= (others => '0');
             dop_in((memp_width -1) downto 0) := (others => '0');
             dop_buf((memp_width -1) downto 0) := (others => '0');
           end if;

         end if;

    elsif (GSR_dly = '0')then

       rden_var := RDEN_dly;
       wren_var := WREN_dly;

       if(rising_edge(RDCLK_dly)) then

         -- SRVAL in output register mode
         if (DO_REG = 1 and sync = '1' and rstreg_dly = '1') then
			
           DO_OUTREG_var(mem_width-1 downto 0) := SRVAL_STD(mem_width-1 downto 0);
         
           if (mem_width >= 8) then
             DOP_OUTREG_var(memp_width-1 downto 0) := SRVAL_STD((memp_width+mem_width)-1 downto mem_width);
           end if;

         end if;

         
         if (RST_dly = '0')then
         
          rd_flag_var := rd_flag;
          wr_flag_var := wr_flag;
          awr_flag_var := awr_flag;

          rd_addr_var := rd_addr_7s;
          wr_addr_var := wr_addr_7s;

          rdcount_var := SLV_TO_INT(RDCOUNT_zd);
          rdcount_flag_var := rdcount_flag;

         
          if (sync = '1') then

           -- output register
           if (DO_REG = 1 and regce_dly = '1' and rstreg_dly = '0') then
             
             DO_OUTREG_var := DO_zd;
             DOP_OUTREG_var := DOP_zd;
             dbiterr_out_out_var := dbiterr_out;
             sbiterr_out_out_var := sbiterr_out;
             
           end if;
            
                     
           if (RDEN_dly = '1') then

             if (EMPTY_zd = '0') then

               do_buf(mem_width-1 downto 0) := mem(rdcount_var);
               dop_buf(memp_width-1 downto 0) := memp(rdcount_var);
               
               -- ECC decode
               if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;

                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';  -- latch out in sync mode
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                   
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              

               end if;

               if (DO_REG = 0) then
                 dbiterr_out_out_var := dbiterr_out;
                 sbiterr_out_out_var := sbiterr_out;
               end if;

               
               DO_zd <= do_buf;
               DOP_zd <= dop_buf;

               
               rdcount_var := (rdcount_var + 1) mod addr_limit;

               if (rdcount_var = 0) then
                 rdcount_flag_var := not rdcount_flag_var;
               end if;

             end if;
           end if;


           if (RDEN_dly = '1' and EMPTY_zd = '1') then
             RDERR_zd <= '1';
           else
             RDERR_zd <= '0';
           end if;
           
           
           if (WREN_dly = '1') then
             EMPTY_zd <= '0';
           elsif (rdcount_var = wr_addr_var and rdcount_flag_var = wr_flag_var) then
             EMPTY_zd <= '1';
           end if;
             
           if((((rdcount_var + ae_empty) >= wr_addr_var) and (rdcount_flag_var = wr_flag_var)) or (((rdcount_var + ae_empty) >= (wr_addr_var + addr_limit)) and (rdcount_flag_var /= wr_flag_var))) then    
             ALMOSTEMPTY_zd <= '1';
           end if;

           update_from_read_prcs_sync <= not update_from_read_prcs_sync;

      elsif (sync = '0') then

       if (sync_clk_async_mode = '1') then

        if(fwft = '0') then
           addr_limit_var := addr_limit;
           if((rden_var = '1') and (rd_addr_var /= rdcount_var)) then
              DO_zd   <= do_in;
              if (DATA_WIDTH /= 4) then
                DOP_zd  <= dop_in;
              end if;
              rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
              if(rd_addr_var = 0) then 
                  rd_flag_var := NOT rd_flag_var;
              end if;

              dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
              sbiterr_out_out_var := sbiterr_out;

           end if;
           if (((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or 
              ((rden_var = '1') and (empty_ram(1) = '0'))) then
                do_buf(mem_width-1 downto 0) := mem(rdcount_var);
                dop_buf(memp_width-1 downto 0) := memp(rdcount_var);

 
                -- ECC decode
                if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;
                     
                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                     
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              

              end if;

                
              do_in := do_buf;
              dop_in := dop_buf;
                 
                
              rdcount_var := (rdcount_var + 1) mod addr_limit;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;
         
         elsif(fwft = '1') then
           if((rden_var = '1') and (rd_addr_var /= rd_prefetch_var)) then
              rd_prefetch_var := (rd_prefetch_var + 1) mod addr_limit;
              if(rd_prefetch_var = 0) then 
                  rd_prefetch_flag_var := NOT rd_prefetch_flag_var;
              end if;
           end if;
           if((rd_prefetch_var = rd_addr_var) and (rd_addr_var /= rdcount_var)) then
             DO_zd   <= do_in;
             if (DATA_WIDTH /= 4) then
               DOP_zd <= dop_in;
             end if;
             rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
             if(rd_addr_var = 0) then 
                rd_flag_var := NOT rd_flag_var;
             end if;

             dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
             sbiterr_out_out_var := sbiterr_out;
             
           end if;
           if(((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or
              ((rden_var = '1')  and (empty_ram(1) = '0')) or 
              ((rden_var = '0')  and (empty_ram(1) = '0') and (rd_addr_var = rdcount_var))) then 
                do_buf(mem_width-1 downto 0) := mem(rdcount_var);
                dop_buf(memp_width-1 downto 0) := memp(rdcount_var);

                -- ECC decode
               if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;                     
                     
                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                   
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              
               end if;

                
              do_in := do_buf;
              dop_in := dop_buf;
                 
                
              rdcount_var := (rdcount_var + 1) mod addr_limit;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;

       end if;  ---  end if(fwft = '1')


         ALMOSTEMPTY_zd <= almostempty_int(3);

         if((((rdcount_var + ae_empty) >= wr_addr_var) and (rdcount_flag_var = awr_flag_var)) or (((rdcount_var + ae_empty) >= (wr_addr_var + addr_limit)) and (rdcount_flag_var /= awr_flag_var))) then    
            almostempty_int(3) := '1';
            almostempty_int(2) := '1';
            almostempty_int(1) := '1';
            almostempty_int(0) := '1';
         elsif(almostempty_int(2)  = '0') then
           -- added to match verilog
           if (rdcount_var <= rdcount_var + ae_empty or rdcount_flag_var /= awr_flag_var) then
            almostempty_int(3) :=  almostempty_int(0);
            almostempty_int(0) :=  '0';
           end if;
         end if;

         if(fwft = '0') then
           if((rdcount_var = rd_addr_var) and (rdcount_flag_var = rd_flag_var)) then
              EMPTY_zd <= '1';
           else
             EMPTY_zd  <= '0';
           end if;
         elsif(fwft = '1') then
           if((rd_prefetch_var = rd_addr_var) and (rd_prefetch_flag_var = rd_flag_var)) then
             EMPTY_zd <=  '1';
           else
             EMPTY_zd  <= '0';
           end if;
         end if;   
          
         if((rdcount_var = wr_addr_var) and (rdcount_flag_var = awr_flag_var)) then
           empty_ram(2) := '1';
           empty_ram(1) := '1';
           empty_ram(0) := '1';
         else
           empty_ram(2) := empty_ram(1);
           empty_ram(1) := empty_ram(0);
           empty_ram(0) := '0';
         end if;
           
         if((rdcount_var = wr1_addr_var) and (rdcount_flag_var = wr1_flag_var)) then
           empty_ram(3) := '1';
         else
           empty_ram(3) := '0';
         end if;

         wr1_addr_var := wr_addr_7s;
         wr1_flag_var := awr_flag;

         if((rden_var = '1') and (EMPTY_zd = '1')) then
             RDERR_zd <= '1';
         else
             RDERR_zd <= '0';
         end if; -- end ((rden_var = '1') and (empty_int /= '1'))

        update_from_read_prcs <= NOT update_from_read_prcs;

    else
    
         if(fwft = '0') then
           addr_limit_var := addr_limit;

           if(RDEN_dly = '1' and rd_addr_var /= rdcount_var) then

             DO_zd   <= do_in;
              if (DATA_WIDTH /= 4) then
                DOP_zd  <= dop_in;
              end if;
              rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
              if(rd_addr_var = 0) then 
                  rd_flag_var := NOT rd_flag_var;
              end if;

              dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
              sbiterr_out_out_var := sbiterr_out;

           end if;

             
           if (empty_ram(0) = '0' and (RDEN_dly = '1' or rd_addr_var = rdcount_var)) then

                do_buf(mem_width-1 downto 0) := mem(rdcount_var);
                dop_buf(memp_width-1 downto 0) := memp(rdcount_var);

                
                -- ECC decode
                if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;
                     
                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                     
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              

              end if;

                
              do_in := do_buf;
              dop_in := dop_buf;

              rdcount_m1_temp_var := rdcount_var;
              rdcount_m1 <= rdcount_m1_temp_var;
           
              rdcount_var := (rdcount_var + 1) mod addr_limit;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;
         
         elsif(fwft = '1') then
           if((RDEN_dly = '1') and (rd_addr_var /= rd_prefetch_var)) then
              rd_prefetch_var := (rd_prefetch_var + 1) mod addr_limit;
              if(rd_prefetch_var = 0) then 
                  rd_prefetch_flag_var := NOT rd_prefetch_flag_var;
              end if;
           end if;

           
           if((rd_prefetch_var = rd_addr_var and rd_addr_var /= rdcount_var) or (RST_dly = '1' and fwft_prefetch_flag = 1)) then

             set_fwft_prefetch_flag_to_0 <= NOT set_fwft_prefetch_flag_to_0;

             DO_zd   <= do_in;
             if (DATA_WIDTH /= 4) then
               DOP_zd <= dop_in;
             end if;
             rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
             if(rd_addr_var = 0) then 
                rd_flag_var := NOT rd_flag_var;
             end if;

             dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
             sbiterr_out_out_var := sbiterr_out;
             
           end if;

           
           if (empty_ram(0) = '0' and (RDEN_dly = '1' or rd_addr_var = rdcount_var)) then
             
               do_buf(mem_width-1 downto 0) := mem(rdcount_var);
               dop_buf(memp_width-1 downto 0) := memp(rdcount_var);

                -- ECC decode
               if (EN_ECC_READ = TRUE) then
                 -- regenerate parity
                 dopr_ecc(0) := do_buf(0) xor do_buf(1) xor do_buf(3) xor do_buf(4) xor do_buf(6) xor do_buf(8)
		      xor do_buf(10) xor do_buf(11) xor do_buf(13) xor do_buf(15) xor do_buf(17) xor do_buf(19)
		      xor do_buf(21) xor do_buf(23) xor do_buf(25) xor do_buf(26) xor do_buf(28)
            	      xor do_buf(30) xor do_buf(32) xor do_buf(34) xor do_buf(36) xor do_buf(38)
		      xor do_buf(40) xor do_buf(42) xor do_buf(44) xor do_buf(46) xor do_buf(48)
		      xor do_buf(50) xor do_buf(52) xor do_buf(54) xor do_buf(56) xor do_buf(57) xor do_buf(59)
		      xor do_buf(61) xor do_buf(63);

                 dopr_ecc(1) := do_buf(0) xor do_buf(2) xor do_buf(3) xor do_buf(5) xor do_buf(6) xor do_buf(9)
                      xor do_buf(10) xor do_buf(12) xor do_buf(13) xor do_buf(16) xor do_buf(17)
                      xor do_buf(20) xor do_buf(21) xor do_buf(24) xor do_buf(25) xor do_buf(27) xor do_buf(28)
                      xor do_buf(31) xor do_buf(32) xor do_buf(35) xor do_buf(36) xor do_buf(39)
                      xor do_buf(40) xor do_buf(43) xor do_buf(44) xor do_buf(47) xor do_buf(48)
                      xor do_buf(51) xor do_buf(52) xor do_buf(55) xor do_buf(56) xor do_buf(58) xor do_buf(59)
                      xor do_buf(62) xor do_buf(63);

                 dopr_ecc(2) := do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17)
                      xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48)
                      xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);
	
                 dopr_ecc(3) := do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
		      xor do_buf(10) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38) xor do_buf(39)
                      xor do_buf(40) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(4) := do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18) xor do_buf(19)
                      xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25)
                      xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49)
                      xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);


                 dopr_ecc(5) := do_buf(26) xor do_buf(27) xor do_buf(28) xor do_buf(29)
                      xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36) xor do_buf(37) xor do_buf(38)
	              xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45) xor do_buf(46) xor do_buf(47)
                      xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54) xor do_buf(55) xor do_buf(56);

                 dopr_ecc(6) := do_buf(57) xor do_buf(58) xor do_buf(59)
                      xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 dopr_ecc(7) := dop_buf(0) xor dop_buf(1) xor dop_buf(2) xor dop_buf(3) xor dop_buf(4) xor dop_buf(5) xor dop_buf(6)
                      xor do_buf(0) xor do_buf(1) xor do_buf(2) xor do_buf(3) xor do_buf(4) xor do_buf(5) xor do_buf(6) xor do_buf(7) xor do_buf(8) xor do_buf(9)
                      xor do_buf(10) xor do_buf(11) xor do_buf(12) xor do_buf(13) xor do_buf(14) xor do_buf(15) xor do_buf(16) xor do_buf(17) xor do_buf(18)
                      xor do_buf(19) xor do_buf(20) xor do_buf(21) xor do_buf(22) xor do_buf(23) xor do_buf(24) xor do_buf(25) xor do_buf(26) xor do_buf(27)
                      xor do_buf(28) xor do_buf(29) xor do_buf(30) xor do_buf(31) xor do_buf(32) xor do_buf(33) xor do_buf(34) xor do_buf(35) xor do_buf(36)
                      xor do_buf(37) xor do_buf(38) xor do_buf(39) xor do_buf(40) xor do_buf(41) xor do_buf(42) xor do_buf(43) xor do_buf(44) xor do_buf(45)
                      xor do_buf(46) xor do_buf(47) xor do_buf(48) xor do_buf(49) xor do_buf(50) xor do_buf(51) xor do_buf(52) xor do_buf(53) xor do_buf(54)
                      xor do_buf(55) xor do_buf(56) xor do_buf(57) xor do_buf(58) xor do_buf(59) xor do_buf(60) xor do_buf(61) xor do_buf(62) xor do_buf(63);

                 syndrome := dopr_ecc xor dop_buf;

                 if (syndrome /= "00000000") then

                   if (syndrome(7) = '1') then  -- dectect single bit error

                     ecc_bit_position := do_buf(63 downto 57) & dop_buf(6) & do_buf(56 downto 26) & dop_buf(5) & do_buf(25 downto 11) & dop_buf(4) & do_buf(10 downto 4) & dop_buf(3) & do_buf(3 downto 1) & dop_buf(2) & do_buf(0) & dop_buf(1 downto 0) & dop_buf(7);

                     tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));

                     if (tmp_syndrome_int > 71) then
                       assert false
                         report "DRC Error : Simulation halted due Corrupted DIP. To correct this problem, make sure that reliable data is fed to the DIP. The correct Parity must be generated by a Hamming code encoder or encoder in the Block RAM. The output from the model is unreliable if there are more than 2 bit errors. The model doesn't warn if there is sporadic input of more than 2 bit errors due to the limitation in Hamming code."
                         severity failure;
                     end if;                     
                     
                     ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output 

                     di_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                     do_buf := di_dly_ecc_corrected;
			
                     dip_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory
                
                     dop_buf := dip_dly_ecc_corrected;
                
                     dbiterr_out := '0';
                     sbiterr_out := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out := '0';
                     dbiterr_out := '1';
                   end if;
                   
                 else
                   dbiterr_out := '0';
                   sbiterr_out := '0';
                 end if;              
               end if;

                
              do_in := do_buf;
              dop_in := dop_buf;

              rdcount_m1_temp_var := rdcount_var;
              rdcount_m1 <= rdcount_m1_temp_var;
                
              rdcount_var := (rdcount_var + 1) mod addr_limit;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;

       end if;  ---  end if(fwft = '1')


       ALMOSTEMPTY_zd <= almostempty_int(0);


       if (((wr_addr_sync_3_var - rdcount_var <= ae_empty) and (rdcount_flag_var = awr_flag_sync_3_var)) or (((wr_addr_sync_3_var + addr_limit)- rdcount_var <= ae_empty) and (rdcount_flag_var /= awr_flag_sync_3_var))) then
         almostempty_int(0) := '1';
       else
         almostempty_int(0) := '0';
       end if;
       

         if(fwft = '0') then
           if((rdcount_var = rd_addr_var) and (rdcount_flag_var = rd_flag_var)) then
             EMPTY_zd <= '1';
           else
             EMPTY_zd  <= '0';
           end if;
         elsif(fwft = '1') then
           if((rd_prefetch_var = rd_addr_var) and (rd_prefetch_flag_var = rd_flag_var)) then
             EMPTY_zd <=  '1';
           else
             EMPTY_zd  <= '0';
           end if;
         end if;   
          

         if((rdcount_var = wr_addr_sync_2_var) and (rdcount_flag_var = awr_flag_sync_2_var)) then
           empty_ram(0) := '1';
         else
           empty_ram(0) := '0';
         end if;

       
         if((RDEN_dly = '1') and (EMPTY_zd = '1')) then
             RDERR_zd <= '1';
         else
             RDERR_zd <= '0';
         end if; -- end ((RDEN_dly = '1') and (empty_int /= '1'))


       end if;

      end if; -- time_wrclk
     end if; -- end (RST_dly = '0')

    end if; -- end (rising_edge(RDCLK_dly))

  end if; -- end (GSR_dly = 1)


    if(update_from_write_prcs'event) then
       wr_addr_var := wr_addr_7s;
       wr_flag_var := wr_flag;
       awr_flag_var := awr_flag;

       if((((rdcount_var + ae_empty) <  wr_addr_var)  and (rdcount_flag_var = awr_flag_var)) or 
          (((rdcount_var + ae_empty) <  ( wr_addr_var + addr_limit)) and (rdcount_flag_var /= awr_flag_var))) then    
         if(wren_var = '1') then
             almostempty_int(2) := almostempty_int(1);
             almostempty_int(1) := '0';
          end if;
       else
           almostempty_int(2) := '1';
           almostempty_int(1) := '1';
       end if;
     end if;

    
     if(update_from_write_prcs_sync'event) then
       wr_addr_var := wr_addr_7s;
       wr_flag_var := wr_flag;
       if((((rdcount_var + ae_empty) <  wr_addr_var)  and (rdcount_flag_var = wr_flag_var)) or 
          (((rdcount_var + ae_empty) < (wr_addr_var + addr_limit)) and (rdcount_flag_var /= wr_flag_var))) then    
          if(rdcount_var <= rdcount_var + ae_empty or rdcount_flag_var /= wr_flag_var) then
            almostempty_zd <= '0';
          end if;
       end if;
     end if;

    
     if (not (rst_rdclk_flag or rst_wrclk_flag or after_rst_x_flag) = '1') then
       RDCOUNT_zd <= CONV_STD_LOGIC_VECTOR(rdcount_var, MAX_RDCOUNT);
       dbiterr_zd <= dbiterr_out_out_var;
       sbiterr_zd <= sbiterr_out_out_var;
     end if;

     rd_addr_7s <= rd_addr_var;
     rd_flag <= rd_flag_var;
     rdcount_flag <= rdcount_flag_var;
     DO_OUTREG_zd <= DO_OUTREG_var;
     DOP_OUTREG_zd <= DOP_OUTREG_var;

  end process prcs_read;


--####################################################################
--#####                         Write                            #####
--####################################################################
  prcs_write:process(WRCLK_dly, RST_dly, GSR_dly, update_from_read_prcs, update_from_read_prcs_sync, rst_rdclk_flag, rst_wrclk_flag, after_rst_x_flag)
  variable first_time        : boolean    := true;
  variable wr_addr_var       : integer := 0;
  variable rd_addr_var       : integer := 0;
  variable rdcount_var       : integer := 0;
  variable rdcount_sync_3_var : integer := -1;
  variable rdcount_sync_2_var : integer := -1;
  variable rdcount_sync_1_var : integer := -1;

  
  variable wrcount_var       : integer := 0;

  variable rd_flag_var       : std_ulogic := '0';
  variable wr_flag_var       : std_ulogic := '0';
  variable awr_flag_var       : std_ulogic := '0';

  variable rdcount_flag_var  : std_ulogic := '0';

  variable almostfull_int : std_ulogic_vector(3 downto 0) := (others => '0');
  variable full_int       : std_ulogic_vector(3 downto 0) := (others => '0');

  variable rden_var  : std_ulogic := '0';
  variable wren_var  : std_ulogic := '0';
  variable di_ecc_col : std_logic_vector(63 downto 0) := (others => '0');
  variable dip_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable dip_dly_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable ALMOSTFULL_var : std_ulogic     :=    '0';
  variable ard_flag_sync_1_var : std_ulogic := '0';
  variable ard_flag_sync_2_var : std_ulogic := '0';
  variable ard_flag_sync_3_var : std_ulogic := '0';
  
  begin

    if (rising_edge(WRCLK_dly)) then
      rdcount_sync_3_var := rdcount_sync_2_var;
      rdcount_sync_2_var := rdcount_sync_1_var;
      rdcount_sync_1_var := rdcount_m1;

      ard_flag_sync_3_var := ard_flag_sync_2_var;
      ard_flag_sync_2_var := ard_flag_sync_1_var;
      ard_flag_sync_1_var := rd_flag;
    end if;


    if ((RST_dly = '1') or (rst_rdclk_flag = '1') or (rst_wrclk_flag = '1') or (after_rst_x_flag = '1'))then
        wr_addr_var := 0;
        wr_addr_7s <=  0;
        wr_flag <= '0';
        awr_flag <= '0';
        
        rd_addr_var := 0;
        rdcount_var := 0;
        wrcount_var := 0;
        ALMOSTFULL_var := '0';
   
        rd_flag_var := '0';
        wr_flag_var := '0';
        awr_flag_var := '0';

        rdcount_flag_var  := '0';

        full_int       :=  (others => '0');
        almostfull_int :=  (others => '0');

        rdcount_sync_3_var := -1;
          
        if (RST_dly = '1')then
          ALMOSTFULL_zd <= '0';      
          FULL_zd <= '0';            
          WRERR_zd <= '0';           
          WRCOUNT_zd <= (others => '0');
        else
          ALMOSTFULL_zd <= 'X';       
          FULL_zd <= 'X';             
          WRERR_zd <= 'X';            
          WRCOUNT_zd <= (others => 'X');
          eccparity_zd <= (others => 'X');
        end if;

    end if;
    
    if((GSR_dly = '0') and (RST_dly = '1'))then  -- match HW eccparity output when RST = 1

      if(rising_edge(WRCLK_dly)) then
        if(wren_dly = '1') then
          if (full_zd= '0') then

            -- ECC encode
            if (EN_ECC_WRITE = TRUE) then

              -- regenerate parity
              dip_ecc(0) := di_dly(0) xor di_dly(1) xor di_dly(3) xor di_dly(4) xor di_dly(6) xor di_dly(8)
		      xor di_dly(10) xor di_dly(11) xor di_dly(13) xor di_dly(15) xor di_dly(17) xor di_dly(19)
		      xor di_dly(21) xor di_dly(23) xor di_dly(25) xor di_dly(26) xor di_dly(28)
            	      xor di_dly(30) xor di_dly(32) xor di_dly(34) xor di_dly(36) xor di_dly(38)
		      xor di_dly(40) xor di_dly(42) xor di_dly(44) xor di_dly(46) xor di_dly(48)
		      xor di_dly(50) xor di_dly(52) xor di_dly(54) xor di_dly(56) xor di_dly(57) xor di_dly(59)
		      xor di_dly(61) xor di_dly(63);

              dip_ecc(1) := di_dly(0) xor di_dly(2) xor di_dly(3) xor di_dly(5) xor di_dly(6) xor di_dly(9)
                      xor di_dly(10) xor di_dly(12) xor di_dly(13) xor di_dly(16) xor di_dly(17)
                      xor di_dly(20) xor di_dly(21) xor di_dly(24) xor di_dly(25) xor di_dly(27) xor di_dly(28)
                      xor di_dly(31) xor di_dly(32) xor di_dly(35) xor di_dly(36) xor di_dly(39)
                      xor di_dly(40) xor di_dly(43) xor di_dly(44) xor di_dly(47) xor di_dly(48)
                      xor di_dly(51) xor di_dly(52) xor di_dly(55) xor di_dly(56) xor di_dly(58) xor di_dly(59)
                      xor di_dly(62) xor di_dly(63);

              dip_ecc(2) := di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17)
                      xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48)
                      xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);
	
              dip_ecc(3) := di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
		      xor di_dly(10) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(4) := di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);


              dip_ecc(5) := di_dly(26) xor di_dly(27) xor di_dly(28) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38)
	              xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47)
                      xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(6) := di_dly(57) xor di_dly(58) xor di_dly(59)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              dip_ecc(7) := dip_ecc(0) xor dip_ecc(1) xor dip_ecc(2) xor dip_ecc(3) xor dip_ecc(4) xor dip_ecc(5) xor dip_ecc(6)
                      xor di_dly(0) xor di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18)
                      xor di_dly(19) xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(26) xor di_dly(27)
                      xor di_dly(28) xor di_dly(29) xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36)
                      xor di_dly(37) xor di_dly(38) xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45)
                      xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54)
                      xor di_dly(55) xor di_dly(56) xor di_dly(57) xor di_dly(58) xor di_dly(59) xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              ECCPARITY_zd <= dip_ecc;

            end if;
          end if;
        end if;
      end if;
        
    elsif((GSR_dly = '0') and (RST_dly = '0') and (rst_rdclk_flag = '0') and (rst_wrclk_flag = '0') and (after_rst_x_flag = '0'))then
      rden_var := RDEN_dly;
      wren_var := WREN_dly;

      if(rising_edge(WRCLK_dly)) then

        rd_flag_var := rd_flag;
        wr_flag_var := wr_flag;
        awr_flag_var := awr_flag;        

        rd_addr_var := rd_addr_7s;
        wr_addr_var := wr_addr_7s;

        rdcount_var := SLV_TO_INT(RDCOUNT_zd);
        rdcount_flag_var := rdcount_flag;


        if (not(EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE)) then
      
          if (injectsbiterr_dly = '1') then
            assert false
              report "DRC Warning : INJECTSBITERR is not supported when neither EN_ECC_WRITE nor EN_ECCREAD = TRUE on FIFO36E1 instance."
              severity Warning;
          end if;

          if (injectdbiterr_dly = '1') then
            assert false
            report "DRC Warning : INJECTDBITERR is not supported when neither EN_ECC_WRITE nor EN_ECCREAD = TRUE on FIFO36E1 instance."
            severity Warning;
          end if;

        end if;

        
	if (sync = '1') then
          if(wren_dly = '1') then
            if (full_zd= '0') then

            -- ECC encode
            if (EN_ECC_WRITE = TRUE) then

              -- regenerate parity
              dip_ecc(0) := di_dly(0) xor di_dly(1) xor di_dly(3) xor di_dly(4) xor di_dly(6) xor di_dly(8)
		      xor di_dly(10) xor di_dly(11) xor di_dly(13) xor di_dly(15) xor di_dly(17) xor di_dly(19)
		      xor di_dly(21) xor di_dly(23) xor di_dly(25) xor di_dly(26) xor di_dly(28)
            	      xor di_dly(30) xor di_dly(32) xor di_dly(34) xor di_dly(36) xor di_dly(38)
		      xor di_dly(40) xor di_dly(42) xor di_dly(44) xor di_dly(46) xor di_dly(48)
		      xor di_dly(50) xor di_dly(52) xor di_dly(54) xor di_dly(56) xor di_dly(57) xor di_dly(59)
		      xor di_dly(61) xor di_dly(63);

              dip_ecc(1) := di_dly(0) xor di_dly(2) xor di_dly(3) xor di_dly(5) xor di_dly(6) xor di_dly(9)
                      xor di_dly(10) xor di_dly(12) xor di_dly(13) xor di_dly(16) xor di_dly(17)
                      xor di_dly(20) xor di_dly(21) xor di_dly(24) xor di_dly(25) xor di_dly(27) xor di_dly(28)
                      xor di_dly(31) xor di_dly(32) xor di_dly(35) xor di_dly(36) xor di_dly(39)
                      xor di_dly(40) xor di_dly(43) xor di_dly(44) xor di_dly(47) xor di_dly(48)
                      xor di_dly(51) xor di_dly(52) xor di_dly(55) xor di_dly(56) xor di_dly(58) xor di_dly(59)
                      xor di_dly(62) xor di_dly(63);

              dip_ecc(2) := di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17)
                      xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48)
                      xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);
	
              dip_ecc(3) := di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
		      xor di_dly(10) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(4) := di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);


              dip_ecc(5) := di_dly(26) xor di_dly(27) xor di_dly(28) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38)
	              xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47)
                      xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(6) := di_dly(57) xor di_dly(58) xor di_dly(59)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              dip_ecc(7) := dip_ecc(0) xor dip_ecc(1) xor dip_ecc(2) xor dip_ecc(3) xor dip_ecc(4) xor dip_ecc(5) xor dip_ecc(6)
                      xor di_dly(0) xor di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18)
                      xor di_dly(19) xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(26) xor di_dly(27)
                      xor di_dly(28) xor di_dly(29) xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36)
                      xor di_dly(37) xor di_dly(38) xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45)
                      xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54)
                      xor di_dly(55) xor di_dly(56) xor di_dly(57) xor di_dly(58) xor di_dly(59) xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              ECCPARITY_zd <= dip_ecc;

              dip_dly_ecc := dip_ecc;  -- only 64 bits width

            else

              dip_dly_ecc := dip_dly; -- only 64 bits width

            end if;


            -- injecting error
            di_ecc_col := di_dly;

            if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then
               
              if (injectdbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
                di_ecc_col(62) := not(di_ecc_col(62));
              elsif (injectsbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
              end if;

            end if;

            
            mem(wr_addr_var) <= di_ecc_col(mem_width-1 downto 0);
            memp(wr_addr_var) <= dip_dly_ecc(memp_width-1 downto 0);

            wr_addr_var := (wr_addr_var + 1) mod addr_limit;

            if(wr_addr_var = 0) then
              wr_flag_var := NOT wr_flag_var;
            end if;

          end if;
        end if;


        if ((WREN_dly = '1') and (FULL_zd = '1')) then
          WRERR_zd <= '1';
        else
          WRERR_zd <= '0';
        end if;

        
        if (rden_dly = '1') then
          full_zd <= '0';
        elsif (rdcount_var = wr_addr_var and rdcount_flag_var /= wr_flag_var) then
          full_zd <= '1';
        end if;

        update_from_write_prcs_sync <= NOT update_from_write_prcs_sync;

        if((((rdcount_var + addr_limit) <= (wr_addr_var + ae_full)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var <= (wr_addr_var + ae_full)) and (rdcount_flag_var /= wr_flag_var))) then
          almostfull_zd <= '1';
        end if;
        
        
      elsif (sync = '0') then

      if (sync_clk_async_mode = '1') then

        if((wren_var = '1') and (full_zd = '0'))then  

          -- ECC encode
            if (EN_ECC_WRITE = TRUE) then

              -- regenerate parity
              dip_ecc(0) := di_dly(0) xor di_dly(1) xor di_dly(3) xor di_dly(4) xor di_dly(6) xor di_dly(8)
		      xor di_dly(10) xor di_dly(11) xor di_dly(13) xor di_dly(15) xor di_dly(17) xor di_dly(19)
		      xor di_dly(21) xor di_dly(23) xor di_dly(25) xor di_dly(26) xor di_dly(28)
            	      xor di_dly(30) xor di_dly(32) xor di_dly(34) xor di_dly(36) xor di_dly(38)
		      xor di_dly(40) xor di_dly(42) xor di_dly(44) xor di_dly(46) xor di_dly(48)
		      xor di_dly(50) xor di_dly(52) xor di_dly(54) xor di_dly(56) xor di_dly(57) xor di_dly(59)
		      xor di_dly(61) xor di_dly(63);

              dip_ecc(1) := di_dly(0) xor di_dly(2) xor di_dly(3) xor di_dly(5) xor di_dly(6) xor di_dly(9)
                      xor di_dly(10) xor di_dly(12) xor di_dly(13) xor di_dly(16) xor di_dly(17)
                      xor di_dly(20) xor di_dly(21) xor di_dly(24) xor di_dly(25) xor di_dly(27) xor di_dly(28)
                      xor di_dly(31) xor di_dly(32) xor di_dly(35) xor di_dly(36) xor di_dly(39)
                      xor di_dly(40) xor di_dly(43) xor di_dly(44) xor di_dly(47) xor di_dly(48)
                      xor di_dly(51) xor di_dly(52) xor di_dly(55) xor di_dly(56) xor di_dly(58) xor di_dly(59)
                      xor di_dly(62) xor di_dly(63);

              dip_ecc(2) := di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17)
                      xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48)
                      xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);
	
              dip_ecc(3) := di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
		      xor di_dly(10) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(4) := di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);


              dip_ecc(5) := di_dly(26) xor di_dly(27) xor di_dly(28) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38)
	              xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47)
                      xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(6) := di_dly(57) xor di_dly(58) xor di_dly(59)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              dip_ecc(7) := dip_ecc(0) xor dip_ecc(1) xor dip_ecc(2) xor dip_ecc(3) xor dip_ecc(4) xor dip_ecc(5) xor dip_ecc(6)
                      xor di_dly(0) xor di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18)
                      xor di_dly(19) xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(26) xor di_dly(27)
                      xor di_dly(28) xor di_dly(29) xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36)
                      xor di_dly(37) xor di_dly(38) xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45)
                      xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54)
                      xor di_dly(55) xor di_dly(56) xor di_dly(57) xor di_dly(58) xor di_dly(59) xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              ECCPARITY_zd <= dip_ecc;

              dip_dly_ecc := dip_ecc;  -- only 64 bits width

            else

              dip_dly_ecc := dip_dly; -- only 64 bits width

            end if;

            
            -- injecting error
            di_ecc_col := di_dly;

            if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then
              
              if (injectdbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
                di_ecc_col(62) := not(di_ecc_col(62));
              elsif (injectsbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
              end if;

            end if;
            
            
            mem(wr_addr_var) <= di_ecc_col(mem_width-1 downto 0);
            if (DATA_WIDTH >= 9) then
              memp(wr_addr_var) <= dip_dly_ecc(memp_width-1 downto 0);              
            end if;
                
            wr_addr_var := (wr_addr_var + 1) mod addr_limit;
         
            if(wr_addr_var = 0) then
              awr_flag_var := NOT awr_flag_var;
            end if;

            if(wr_addr_var = addr_limit - 1) then
              wr_flag_var := NOT wr_flag_var;
            end if;
            
        end if; -- if((wren_var = '1') and (FULL_zd = '0') ....      

        if((wren_var = '1') and (full_zd = '1')) then 
            WRERR_zd <= '1';
        else
            WRERR_zd <= '0';
        end if;

        ALMOSTFULL_var := almostfull_int(3);
        
        if((((rdcount_var + addr_limit) <= (wr_addr_var + ae_full)) and (rdcount_flag_var = awr_flag_var)) or ((rdcount_var <= (wr_addr_var + ae_full)) and (rdcount_flag_var /= awr_flag_var))) then    
          almostfull_int(3) := '1';
          almostfull_int(2) := '1';
          almostfull_int(1) := '1';
          almostfull_int(0) := '1';
        elsif(almostfull_int(2)  = '0') then
          if (wr_addr_var <= wr_addr_var + ae_full or rdcount_flag_var = awr_flag_var) then

            almostfull_int(3) := almostfull_int(0);
            almostfull_int(0) :=  '0';

          end if;
        end if;

        if (wren_var = '1' or full_zd = '1') then
          full_zd <= full_int(1);
        end if;

        if(((rdcount_var = wr_addr_var) or (rdcount_var - 1 = wr_addr_var or rdcount_var + addr_limit - 1 = wr_addr_var)) and ALMOSTFULL_var = '1') then
          full_int(1) := '1';
          full_int(0) := '1';
        else
          full_int(1) := full_int(0);
          full_int(0) := '0';
        end if;

        update_from_write_prcs <= NOT update_from_write_prcs;
        ALMOSTFULL_zd <= ALMOSTFULL_var;

       else

      assert false
          report "never come in here if sync clocks in async mode"
          severity note;
        
         
        if((wren_var = '1') and (full_zd = '0'))then  

          -- ECC encode
            if (EN_ECC_WRITE = TRUE) then

              -- regenerate parity
              dip_ecc(0) := di_dly(0) xor di_dly(1) xor di_dly(3) xor di_dly(4) xor di_dly(6) xor di_dly(8)
		      xor di_dly(10) xor di_dly(11) xor di_dly(13) xor di_dly(15) xor di_dly(17) xor di_dly(19)
		      xor di_dly(21) xor di_dly(23) xor di_dly(25) xor di_dly(26) xor di_dly(28)
            	      xor di_dly(30) xor di_dly(32) xor di_dly(34) xor di_dly(36) xor di_dly(38)
		      xor di_dly(40) xor di_dly(42) xor di_dly(44) xor di_dly(46) xor di_dly(48)
		      xor di_dly(50) xor di_dly(52) xor di_dly(54) xor di_dly(56) xor di_dly(57) xor di_dly(59)
		      xor di_dly(61) xor di_dly(63);

              dip_ecc(1) := di_dly(0) xor di_dly(2) xor di_dly(3) xor di_dly(5) xor di_dly(6) xor di_dly(9)
                      xor di_dly(10) xor di_dly(12) xor di_dly(13) xor di_dly(16) xor di_dly(17)
                      xor di_dly(20) xor di_dly(21) xor di_dly(24) xor di_dly(25) xor di_dly(27) xor di_dly(28)
                      xor di_dly(31) xor di_dly(32) xor di_dly(35) xor di_dly(36) xor di_dly(39)
                      xor di_dly(40) xor di_dly(43) xor di_dly(44) xor di_dly(47) xor di_dly(48)
                      xor di_dly(51) xor di_dly(52) xor di_dly(55) xor di_dly(56) xor di_dly(58) xor di_dly(59)
                      xor di_dly(62) xor di_dly(63);

              dip_ecc(2) := di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17)
                      xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48)
                      xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);
	
              dip_ecc(3) := di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
		      xor di_dly(10) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38) xor di_dly(39)
                      xor di_dly(40) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(4) := di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18) xor di_dly(19)
                      xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25)
                      xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49)
                      xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);


              dip_ecc(5) := di_dly(26) xor di_dly(27) xor di_dly(28) xor di_dly(29)
                      xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36) xor di_dly(37) xor di_dly(38)
	              xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45) xor di_dly(46) xor di_dly(47)
                      xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54) xor di_dly(55) xor di_dly(56);

              dip_ecc(6) := di_dly(57) xor di_dly(58) xor di_dly(59)
                      xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              dip_ecc(7) := dip_ecc(0) xor dip_ecc(1) xor dip_ecc(2) xor dip_ecc(3) xor dip_ecc(4) xor dip_ecc(5) xor dip_ecc(6)
                      xor di_dly(0) xor di_dly(1) xor di_dly(2) xor di_dly(3) xor di_dly(4) xor di_dly(5) xor di_dly(6) xor di_dly(7) xor di_dly(8) xor di_dly(9)
                      xor di_dly(10) xor di_dly(11) xor di_dly(12) xor di_dly(13) xor di_dly(14) xor di_dly(15) xor di_dly(16) xor di_dly(17) xor di_dly(18)
                      xor di_dly(19) xor di_dly(20) xor di_dly(21) xor di_dly(22) xor di_dly(23) xor di_dly(24) xor di_dly(25) xor di_dly(26) xor di_dly(27)
                      xor di_dly(28) xor di_dly(29) xor di_dly(30) xor di_dly(31) xor di_dly(32) xor di_dly(33) xor di_dly(34) xor di_dly(35) xor di_dly(36)
                      xor di_dly(37) xor di_dly(38) xor di_dly(39) xor di_dly(40) xor di_dly(41) xor di_dly(42) xor di_dly(43) xor di_dly(44) xor di_dly(45)
                      xor di_dly(46) xor di_dly(47) xor di_dly(48) xor di_dly(49) xor di_dly(50) xor di_dly(51) xor di_dly(52) xor di_dly(53) xor di_dly(54)
                      xor di_dly(55) xor di_dly(56) xor di_dly(57) xor di_dly(58) xor di_dly(59) xor di_dly(60) xor di_dly(61) xor di_dly(62) xor di_dly(63);

              ECCPARITY_zd <= dip_ecc;

              dip_dly_ecc := dip_ecc;  -- only 64 bits width

            else

              dip_dly_ecc := dip_dly; -- only 64 bits width

            end if;

            
            -- injecting error
            di_ecc_col := di_dly;

            if (EN_ECC_WRITE = TRUE or EN_ECC_READ = TRUE) then
              
              if (injectdbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
                di_ecc_col(62) := not(di_ecc_col(62));
              elsif (injectsbiterr_dly = '1') then
                di_ecc_col(30) := not(di_ecc_col(30));
              end if;

            end if;
            
            
            mem(wr_addr_var) <= di_ecc_col(mem_width-1 downto 0);
            if (DATA_WIDTH >= 9) then
              memp(wr_addr_var) <= dip_dly_ecc(memp_width-1 downto 0);              
            end if;
                
            wr_addr_var := (wr_addr_var + 1) mod addr_limit;
         
            if(wr_addr_var = 0) then
              awr_flag_var := NOT awr_flag_var;
            end if;

            if(wr_addr_var = addr_limit - 1) then
              wr_flag_var := NOT wr_flag_var;
            end if;
            
        end if; -- if((wren_var = '1') and (FULL_zd = '0') ....      

        if((wren_var = '1') and (full_zd = '1')) then 
            WRERR_zd <= '1';
        else
            WRERR_zd <= '0';
        end if;


        ALMOSTFULL_var := almostfull_int(0);

        
        if(((((rdcount_sync_3_var + addr_limit) - wr_addr_var) <= ae_full) and (ard_flag_sync_3_var = awr_flag_var)) or (((rdcount_sync_3_var - wr_addr_var) <= ae_full) and (ard_flag_sync_3_var /= awr_flag_var))) then    
            almostfull_int(0) := '1';
        else
          almostfull_int(0) := '0';
        end if;
        

        FULL_zd <= full_v3;
        

        ALMOSTFULL_zd <= ALMOSTFULL_var;

       end if; -- if (time_rdclk - time_wrclk = 0)
      end if; -- if (sync)
  
        WRCOUNT_zd <= CONV_STD_LOGIC_VECTOR( wr_addr_var, MAX_WRCOUNT);

        wr_addr_7s <= wr_addr_var;
        wr_flag <= wr_flag_var;
        awr_flag <= awr_flag_var;

    end if; -- if(rising(WRCLK_dly))

   end if; -- if(GSR_dly = '1'))


   if (rising_edge(WRCLK_dly)) then

     if (rdcount_sync_2_var = wr_addr_var) then
       rm1w_eq <= '1';
     else
       rm1w_eq <= '0';
     end if;


     if (wr_addr_var + 1 = addr_limit) then -- wr_addr(FF) + 1 != 0

       if (rdcount_sync_2_var = 0) then
         rm1wp1_eq <= '1';
       else
         rm1wp1_eq <= '0';
       end if;

     else

       if (rdcount_sync_2_var = wr_addr_var + 1) then
         rm1wp1_eq <= '1';
       else
         rm1wp1_eq <= '0';
       end if;

     end if;
     
   end if;
    

    if(update_from_read_prcs_sync'event) then
      rdcount_var := SLV_TO_INT(RDCOUNT_zd);
      rdcount_flag_var := rdcount_flag;
      if((((rdcount_var + addr_limit) > (wr_addr_var + ae_full)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var > (wr_addr_var + ae_full)) and (rdcount_flag_var /= wr_flag_var))) then
        if (wr_addr_var <= wr_addr_var + ae_full or rdcount_flag_var = wr_flag_var) then
          ALMOSTFULL_zd <= '0';
        end if;
      end if;
    end if;

    
    if(update_from_read_prcs'event) then
       rdcount_var := SLV_TO_INT(RDCOUNT_zd);
       rdcount_flag_var := rdcount_flag;

       if((((rdcount_var + addr_limit) > (wr_addr_var + ae_full)) and (rdcount_flag_var = awr_flag_var)) or ((rdcount_var > (wr_addr_var + ae_full)) and (rdcount_flag_var /= awr_flag_var))) then    

           if(((rden_var = '1') and (EMPTY_zd = '0')) or ((((rd_addr_var + 1) mod addr_limit) = rdcount_var) and (almostfull_int(1) = '1'))) then
              almostfull_int(2) := almostfull_int(1);
              almostfull_int(1) := '0';
           end if;
       else
           almostfull_int(2) := '1';
           almostfull_int(1) := '1';
       end if;
    end if;

  end process prcs_write;

end generate S7_read_write;


  fwft_prefetch_7s : process (set_fwft_prefetch_flag_to_0, WRCLK_dly)
  begin                     

    if (RST_dly = '0' and sync = '0') then
      if (EMPTY_zd = '1' and WREN_dly = '1' and fwft_prefetch_flag = 0) then
        fwft_prefetch_flag <= 1;
      end if;
    end if;

    
    if (set_fwft_prefetch_flag_to_0'event) then
          fwft_prefetch_flag <= 0;
    end if;

  end process fwft_prefetch_7s;
                
                
  full_7s : process (rm1w_eq, rm1wp1_eq, WREN_dly, FULL_zd)
  begin 

    if (rm1w_eq = '1' or (rm1wp1_eq = '1' and (WREN_dly = '1' and FULL_zd = '0'))) then 
     full_v3 <= '1';
    else
     full_v3 <= '0';
    end if;

  end process full_7s;

      
  outmux: process (DO_zd, DOP_zd, DO_OUTREG_zd, DOP_OUTREG_zd)
  begin  -- process outmux_clka

    if (sync = '1') then
      
      case DO_REG is
        when 0 =>
                  DO_OUT_MUX_zd <= DO_zd;
                  DOP_OUT_MUX_zd <= DOP_zd;
        when 1 =>
                  DO_OUT_MUX_zd <= DO_OUTREG_zd;
                  DOP_OUT_MUX_zd <= DOP_OUTREG_zd;
        when others => assert false
                       report "Attribute Syntax Error: The allowed integer values for DO_REG are 0 or 1."
                       severity Failure;
      end case;

    else
      DO_OUT_MUX_zd <= DO_zd;
      DOP_OUT_MUX_zd <= DOP_zd;
    end if;
    
  end process outmux;
  

  -- matching HW behavior to pull up and X the unused output bits
  prcs_x_1_output: process (DO_OUT_MUX_zd, DOP_OUT_MUX_zd)
  begin  -- process prcs_x_1_output

    if (FIFO_SIZE = 18) then
      
      case DATA_WIDTH is
        when 4  => 
                  DO_OUT_zd(3 downto 0) <= DO_OUT_MUX_zd(3 downto 0);
        when 9  =>
                  DO_OUT_zd(7 downto 0) <= DO_OUT_MUX_zd(7 downto 0);
                  DOP_OUT_zd(0 downto 0) <= DOP_OUT_MUX_zd(0 downto 0);
        when 18 =>
                  DO_OUT_zd(15 downto 0) <= DO_OUT_MUX_zd(15 downto 0);
                  DOP_OUT_zd(1 downto 0) <= DOP_OUT_MUX_zd(1 downto 0);
        when 36 => 
                  DO_OUT_zd(31 downto 0) <= DO_OUT_MUX_zd(31 downto 0);
                  DOP_OUT_zd(3 downto 0) <= DOP_OUT_MUX_zd(3 downto 0);
        when others =>
                  DO_OUT_zd <= DO_OUT_MUX_zd;
      end case;   

    else

      case DATA_WIDTH is
        when 4  => 
                  DO_OUT_zd(3 downto 0) <= DO_OUT_MUX_zd(3 downto 0);
        when 9  =>
                  DO_OUT_zd(7 downto 0) <= DO_OUT_MUX_zd(7 downto 0);
                  DOP_OUT_zd(0 downto 0) <= DOP_OUT_MUX_zd(0 downto 0);
        when 18 =>
                  DO_OUT_zd(15 downto 0) <= DO_OUT_MUX_zd(15 downto 0);
                  DOP_OUT_zd(1 downto 0) <= DOP_OUT_MUX_zd(1 downto 0);
        when 36 => 
                  DO_OUT_zd(31 downto 0) <= DO_OUT_MUX_zd(31 downto 0);
                  DOP_OUT_zd(3 downto 0) <= DOP_OUT_MUX_zd(3 downto 0);
        when 72 => 
                  DO_OUT_zd(63 downto 0) <= DO_OUT_MUX_zd(63 downto 0);
                  DOP_OUT_zd(7 downto 0) <= DOP_OUT_MUX_zd(7 downto 0);          
        when others =>
                  DO_OUT_zd <= DO_OUT_MUX_zd;
      end case;
         
    end if;
    
  end process prcs_x_1_output;


  -- matching HW behavior to pull up and X the unused output bits
  prcs_x_1_output_wrcount: process (WRCOUNT_zd, RST_dly, GSR_dly, rst_rdclk_flag, rst_wrclk_flag, after_rst_x_flag)
  begin

    if((GSR_dly = '1') or (RST_dly = '1')) then
      WRCOUNT_OUT_zd <= (others => '0');
    elsif ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1') or (after_rst_x_flag = '1'))then
      WRCOUNT_OUT_zd <= (others => 'X');
    elsif (WRCOUNT_zd'event) then
      
      if (FIFO_SIZE = 18) then
      
        case DATA_WIDTH is
          when 4  => 
                  WRCOUNT_OUT_zd(12 downto 0) <= '1' & WRCOUNT_zd(11 downto 0);
          when 9  =>
                  WRCOUNT_OUT_zd(12 downto 0) <= "11" & WRCOUNT_zd(10 downto 0);
          when 18 =>
                  WRCOUNT_OUT_zd(12 downto 0) <= "111" & WRCOUNT_zd(9 downto 0);
          when 36 => 
                  WRCOUNT_OUT_zd(12 downto 0) <= "1111" & WRCOUNT_zd(8 downto 0);
          when others =>
                  WRCOUNT_OUT_zd <= WRCOUNT_zd;
        end case;   

      else

        case DATA_WIDTH is
          when 4  => 
                  WRCOUNT_OUT_zd(12 downto 0) <= WRCOUNT_zd(12 downto 0);
          when 9  =>
                  WRCOUNT_OUT_zd(12 downto 0) <= '1' & WRCOUNT_zd(11 downto 0);
          when 18 =>
                  WRCOUNT_OUT_zd(12 downto 0) <= "11" & WRCOUNT_zd(10 downto 0);
          when 36 => 
                  WRCOUNT_OUT_zd(12 downto 0) <= "111" & WRCOUNT_zd(9 downto 0);
          when 72 => 
                  WRCOUNT_OUT_zd(12 downto 0) <= "1111" & WRCOUNT_zd(8 downto 0);
          when others =>
                  WRCOUNT_OUT_zd <= WRCOUNT_zd;
        end case;
         
      end if;

    end if;
    
  end process prcs_x_1_output_wrcount;


  -- matching HW behavior to pull up and X the unused output bits
  prcs_x_1_output_rdcount: process (RDCOUNT_zd, RST_dly, GSR_dly, rst_rdclk_flag, rst_wrclk_flag)
  begin

    if((GSR_dly = '1') or (RST_dly = '1')) then
      RDCOUNT_OUT_zd <= (others => '0');
    elsif ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1') or (after_rst_x_flag = '1'))then
      RDCOUNT_OUT_zd <= (others => 'X');
    elsif (RDCOUNT_zd'event) then
      
      if (FIFO_SIZE = 18) then
      
        case DATA_WIDTH is
          when 4  => 
                  RDCOUNT_OUT_zd(12 downto 0) <= '1' & RDCOUNT_zd(11 downto 0);
          when 9  =>
                  RDCOUNT_OUT_zd(12 downto 0) <= "11" & RDCOUNT_zd(10 downto 0);
          when 18 =>
                  RDCOUNT_OUT_zd(12 downto 0) <= "111" & RDCOUNT_zd(9 downto 0);
          when 36 => 
                  RDCOUNT_OUT_zd(12 downto 0) <= "1111" & RDCOUNT_zd(8 downto 0);
          when others =>
                  RDCOUNT_OUT_zd <= RDCOUNT_zd;
        end case;   

      else

        case DATA_WIDTH is
          when 4  => 
                  RDCOUNT_OUT_zd(12 downto 0) <= RDCOUNT_zd(12 downto 0);
          when 9  =>
                  RDCOUNT_OUT_zd(12 downto 0) <= '1' & RDCOUNT_zd(11 downto 0);
          when 18 =>
                  RDCOUNT_OUT_zd(12 downto 0) <= "11" & RDCOUNT_zd(10 downto 0);
          when 36 => 
                  RDCOUNT_OUT_zd(12 downto 0) <= "111" & RDCOUNT_zd(9 downto 0);
          when 72 => 
                  RDCOUNT_OUT_zd(12 downto 0) <= "1111" & RDCOUNT_zd(8 downto 0);
          when others =>
                  RDCOUNT_OUT_zd <= RDCOUNT_zd;
        end case;
         
      end if;

    end if;
    
  end process prcs_x_1_output_rdcount;

  
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(ALMOSTEMPTY_zd, ALMOSTFULL_zd, DO_OUT_zd, DOP_OUT_zd, 
                      EMPTY_zd, FULL_zd, RDCOUNT_OUT_zd, RDERR_zd, 
                      WRCOUNT_OUT_zd, WRERR_zd, sbiterr_zd, dbiterr_zd, ECCPARITY_zd)
  begin
      ALMOSTEMPTY <= ALMOSTEMPTY_zd;
      ALMOSTFULL  <= ALMOSTFULL_zd;
      DBITERR     <= dbiterr_zd;
      DO          <= DO_OUT_zd;
      DOP         <= DOP_OUT_zd;
      ECCPARITY   <= ECCPARITY_zd;
      EMPTY       <= EMPTY_zd;
      FULL        <= FULL_zd;
      RDCOUNT     <= RDCOUNT_OUT_zd;
      RDERR       <= RDERR_zd;
      SBITERR     <= sbiterr_zd;
      WRCOUNT     <= WRCOUNT_OUT_zd;
      WRERR       <= WRERR_zd;
  end process prcs_output;
--####################################################################


end FF36_INTERNAL_VHDL_V;


-- end of FF36_INTERNAL_VHDL - Note: Not an user primitive


-------------------------------------------------------------------------------
-- FIFO36E1
-------------------------------------------------------------------------------

----- CELL FIFO36E1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

entity FIFO36E1 is
generic (

    ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"0080"; 
    DATA_WIDTH              : integer    := 4;
    DO_REG                  : integer    := 1;
    EN_ECC_READ             : boolean    := FALSE;
    EN_ECC_WRITE            : boolean    := FALSE;
    EN_SYN                  : boolean    := FALSE;
    FIFO_MODE               : string     := "FIFO36";
    FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
    INIT                    : bit_vector := X"000000000000000000";
    SIM_DEVICE              : string     := "VIRTEX6";
    SRVAL                   : bit_vector := X"000000000000000000"
    
  );

port (

    ALMOSTEMPTY    : out std_ulogic;
    ALMOSTFULL     : out std_ulogic;
    DBITERR        : out std_ulogic;
    DO             : out std_logic_vector (63 downto 0);
    DOP            : out std_logic_vector (7 downto 0);
    ECCPARITY      : out std_logic_vector (7 downto 0);
    EMPTY          : out std_ulogic;
    FULL           : out std_ulogic;
    RDCOUNT        : out std_logic_vector (12 downto 0);
    RDERR          : out std_ulogic;
    SBITERR        : out std_ulogic;
    WRCOUNT        : out std_logic_vector (12 downto 0);
    WRERR          : out std_ulogic;

    DI             : in  std_logic_vector (63 downto 0);
    DIP            : in  std_logic_vector (7 downto 0);
    INJECTDBITERR  : in  std_ulogic;
    INJECTSBITERR  : in  std_ulogic;
    RDCLK          : in  std_ulogic;
    RDEN           : in  std_ulogic;
    REGCE          : in  std_ulogic;
    RST            : in  std_ulogic;
    RSTREG         : in  std_ulogic;
    WRCLK          : in  std_ulogic;
    WREN           : in  std_ulogic    
  );

end FIFO36E1;
                                                                        
architecture FIFO36E1_V of FIFO36E1 is

  component FF36_INTERNAL_VHDL

    generic(

    ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"0080"; 
    DATA_WIDTH              : integer    := 4;
    DO_REG                  : integer    := 1;
    EN_ECC_READ             : boolean    := FALSE;
    EN_ECC_WRITE            : boolean    := FALSE;    
    EN_SYN                  : boolean    := FALSE;
    FIFO_MODE               : string     := "FIFO36";
    FIFO_SIZE               : integer    := 36;
    FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
    INIT                    : bit_vector := X"000000000000000000";
    SIM_DEVICE              : string     := "VIRTEX6";
    SRVAL                   : bit_vector := X"000000000000000000"
    );

  port(
    ALMOSTEMPTY          : out std_ulogic;
    ALMOSTFULL           : out std_ulogic;
    DBITERR              : out std_ulogic;
    DO                   : out std_logic_vector (63 downto 0);
    DOP                  : out std_logic_vector (7 downto 0);
    ECCPARITY            : out std_logic_vector (7 downto 0);
    EMPTY                : out std_ulogic;
    FULL                 : out std_ulogic;
    RDCOUNT              : out std_logic_vector (12 downto 0);
    RDERR                : out std_ulogic;
    SBITERR              : out std_ulogic;
    WRCOUNT              : out std_logic_vector (12 downto 0);
    WRERR                : out std_ulogic;

    DI                   : in  std_logic_vector (63 downto 0);
    DIP                  : in  std_logic_vector (7 downto 0);
    INJECTDBITERR        : in  std_ulogic;
    INJECTSBITERR        : in  std_ulogic;
    RDCLK                : in  std_ulogic;
    RDEN                 : in  std_ulogic;
    REGCE                : in  std_ulogic;
    RST                  : in  std_ulogic;
    RSTREG               : in  std_ulogic;
    WRCLK                : in  std_ulogic;
    WREN                 : in  std_ulogic
    );

  end component;

    
  constant SYNC_PATH_DELAY : time := 100 ps;
  signal do_dly : std_logic_vector(63 downto 0) :=  (others => '0');
  signal dop_dly : std_logic_vector(7 downto 0) :=  (others => '0');
  signal almostfull_dly : std_ulogic := '0';
  signal almostempty_dly : std_ulogic := '0';
  signal empty_dly : std_ulogic := '0';
  signal full_dly : std_ulogic := '0';
  signal rderr_dly : std_ulogic := '0';
  signal wrerr_dly : std_ulogic := '0';
  signal rdcount_dly : std_logic_vector(12 downto 0) :=  (others => '0');
  signal wrcount_dly : std_logic_vector(12 downto 0) :=  (others => '0');
  signal sbiterr_dly : std_ulogic := '0';
  signal dbiterr_dly : std_ulogic := '0';
  signal eccparity_dly : std_logic_vector(7 downto 0) :=  (others => '0');


  function INIT_SRVAL_SDP (
    input_a : bit_vector(71 downto 0))
    return bit_vector is variable out_init_srval : bit_vector(71 downto 0);
  begin

    if (FIFO_MODE = "FIFO36_72") then
      out_init_srval := input_a(71 downto 68) & input_a(35 downto 32) & input_a(67 downto 36) & input_a(31 downto 0);
    else
      out_init_srval := input_a;
    end if;

    return out_init_srval;  
                         
  end;

  
begin
      
FIFO36E1_inst : FF36_INTERNAL_VHDL
  generic map (
    ALMOST_EMPTY_OFFSET => ALMOST_EMPTY_OFFSET, 
    ALMOST_FULL_OFFSET => ALMOST_FULL_OFFSET,
    DATA_WIDTH => DATA_WIDTH,
    DO_REG => DO_REG,
    EN_ECC_READ => EN_ECC_READ, 
    EN_ECC_WRITE => EN_ECC_WRITE,
    EN_SYN => EN_SYN,
    FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
    INIT => INIT_SRVAL_SDP(INIT),
    SIM_DEVICE => SIM_DEVICE,
    SRVAL => INIT_SRVAL_SDP(SRVAL)
    )

  port map (
    ALMOSTEMPTY => almostempty_dly,
    ALMOSTFULL => almostfull_dly,
    DBITERR => dbiterr_dly,
    DO => do_dly,
    DOP => dop_dly,
    ECCPARITY => eccparity_dly,
    EMPTY => empty_dly,
    FULL => full_dly,
    RDCOUNT => rdcount_dly,
    RDERR => rderr_dly,
    SBITERR => sbiterr_dly,
    WRCOUNT => wrcount_dly,
    WRERR => wrerr_dly,

    DI => DI,
    DIP => DIP,
    INJECTDBITERR => INJECTDBITERR,
    INJECTSBITERR => INJECTSBITERR,
    RDCLK => RDCLK,
    RDEN => RDEN,
    REGCE => REGCE,
    RST => RST,
    RSTREG => RSTREG,
    WRCLK => WRCLK,
    WREN => WREN
    );

   prcs_initialize:process
     variable first_time        : boolean    := true;

     begin
       if (first_time) then
         case DATA_WIDTH is
            when 4 | 9 | 18 | 36 | 72 => null;
            when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " DATA_WIDTH ",
                        EntityName           => "FIFO36E1",
                        GenericValue         => DATA_WIDTH,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " 4, 9, 18, 36 and 72",
                        TailMsg              => "",
                        MsgSeverity          => failure
                        );
         end case;


         if (not(FIFO_MODE = "FIFO36" or FIFO_MODE = "FIFO36_72")) then

           GenericValueCheckMessage
             ( HeaderMsg            => " Attribute Syntax Error : ",
               GenericName          => " FIFO_MODE ",
               EntityName           => "FIFO36E1",
               GenericValue         => FIFO_MODE,
               Unit                 => "",
               ExpectedValueMsg     => " The Legal values for this attribute are ",
               ExpectedGenericValue => " FIFO36 or FIFO36_72 ",
               TailMsg              => "",
               MsgSeverity          => failure
               );
         end if;

         
         if(DATA_WIDTH = 72 xor FIFO_MODE = "FIFO36_72") then
          assert false
          report "DRC Error : The attribute DATA_WIDTH must be set to 72 when attribute FIFO_MODE = FIFO36_72."
          severity failure;
         end if;

         
         first_time := false;

       end if;
       wait;
   end process prcs_initialize;

     
   prcs_output_wtiming: process (do_dly, dop_dly, almostempty_dly, almostfull_dly, empty_dly, full_dly, rdcount_dly, wrcount_dly, rderr_dly, wrerr_dly, dbiterr_dly,eccparity_dly, sbiterr_dly)
   begin  -- process prcs_output_wtiming

     ALMOSTEMPTY <= almostempty_dly after SYNC_PATH_DELAY;
     ALMOSTFULL <= almostfull_dly after SYNC_PATH_DELAY;
     DBITERR <= dbiterr_dly after SYNC_PATH_DELAY;
     DO <= do_dly after SYNC_PATH_DELAY;
     DOP <= dop_dly after SYNC_PATH_DELAY;
     ECCPARITY <= eccparity_dly after SYNC_PATH_DELAY;
     EMPTY <= empty_dly after SYNC_PATH_DELAY;
     FULL <= full_dly after SYNC_PATH_DELAY;
     RDCOUNT <= rdcount_dly after SYNC_PATH_DELAY;
     RDERR <= rderr_dly after SYNC_PATH_DELAY;
     SBITERR <= sbiterr_dly after SYNC_PATH_DELAY;
     WRCOUNT <= wrcount_dly after SYNC_PATH_DELAY;
     WRERR <= wrerr_dly after SYNC_PATH_DELAY;
     
   end process prcs_output_wtiming;

end FIFO36E1_V;
