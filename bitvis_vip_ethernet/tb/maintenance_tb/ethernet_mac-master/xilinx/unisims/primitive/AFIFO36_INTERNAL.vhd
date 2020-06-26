-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/rainier/VITAL/AFIFO36_INTERNAL.vhd,v 1.8 2010/12/09 01:10:20 wloo Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2009 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : This is not an user primitive.
--  /   /                  Xilinx Functional Simulation Library Component 36K-Bit FIFO
-- /___/   /\     Filename : AFIFO36_INTERNAL.vhd
-- \   \  /  \    Timestamp : Tues October 18 08:18:20 PST 2005
--  \___\/\___\
--
-- Revision:
--    10/18/05 - Initial version.
--    06/13/06 - Fixed out of range error (CR 232285). Fixed almostfull flag in
--               sync mode (CR 232931).
--    10/16/06 - Fixed the unused bits of wrcount and rdcount to match the hardware (CR 426347).
--    11/15/06 - Fixed SBITERR and DBITERR in synchronous mode (CR 429311).
--    11/20/06 - Fixed WRCOUNT and RDCOUNT (CR 429310).
--    01/24/07 - Removed DRC warning for RST in ECC mode (CR 432367).
--    06/14/07 - Implemented high performace version of the model.
--    10/26/07 - Changed wren_dly to wren_var to fix FULL flag (CR 452554).
--    04/28/08 - Fixed sbiterr and dbiterr outputs deassertion (CR 470460).
--    11/06/08 - Added DRC for invalid input parity for ECC (CR 482976).
--    01/07/09 - Fixed rdcount output when reset (IR 501177).
--    03/26/09 - Implemented DRC check for ALMOST_EMPTY_OFFSET (CR 511589).
--    07/16/09 - Fixed DOP in fast mode (CR 526558).
--    07/06/10 - Fixed DRC for attribute ALMOST_EMPTY_OFFSET (CR 556915).
--    07/07/10 - Fixed DRC equation for attribute ALMOST_EMPTY_OFFSET (CR 555972).
--    07/14/10 - Fixed DRC equation for attribute ALMOST_EMPTY_OFFSET (CR 555972).
--    07/20/10 - Fixed DRC equation ALMOST_EMPTY_OFFSET when division is 1 (CR 568979).
--    12/08/10 - Fixed error message for RST (CR 579994).
-- End Revision
  
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library STD;
use STD.TEXTIO.ALL;

library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

entity AFIFO36_INTERNAL is

  generic(

    ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"0080"; 
    DATA_WIDTH              : integer    := 4;
    DO_REG                  : integer    := 1;
    EN_ECC_READ             : boolean    := FALSE;
    EN_ECC_WRITE            : boolean    := FALSE;    
    EN_SYN                  : boolean    := FALSE;
    FIFO_SIZE               : integer    := 36;
    FIRST_WORD_FALL_THROUGH : boolean    := FALSE;
    SIM_MODE                : string     := "SAFE"
    );

  port(
    ALMOSTEMPTY : out std_ulogic;
    ALMOSTFULL  : out std_ulogic;
    DBITERR       : out std_ulogic;
    DO          : out std_logic_vector (63 downto 0);
    DOP         : out std_logic_vector (7 downto 0);
    ECCPARITY   : out std_logic_vector (7 downto 0);
    EMPTY       : out std_ulogic;
    FULL        : out std_ulogic;
    RDCOUNT     : out std_logic_vector (12 downto 0);
    RDERR       : out std_ulogic;
    SBITERR     : out std_ulogic;
    WRCOUNT     : out std_logic_vector (12 downto 0);
    WRERR       : out std_ulogic;

    DI          : in  std_logic_vector (63 downto 0);
    DIP         : in  std_logic_vector (7 downto 0);
    RDCLK       : in  std_ulogic;
    RDRCLK      : in  std_ulogic;
    RDEN        : in  std_ulogic;
    RST         : in  std_ulogic;
    WRCLK       : in  std_ulogic;
    WREN        : in  std_ulogic
    );

end AFIFO36_INTERNAL;

-- architecture body                    --

architecture AFIFO36_INTERNAL_V of AFIFO36_INTERNAL is


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

    signal DI_ipd    : std_logic_vector(MSB_MAX_DI downto 0)    := (others => 'X');
    signal DIP_ipd   : std_logic_vector(MSB_MAX_DIP downto 0)   := (others => 'X');
    signal GSR_ipd   : std_ulogic     :=    'X';
    signal RDCLK_ipd : std_ulogic     :=    'X';
    signal RDEN_ipd  : std_ulogic     :=    'X';
    signal RST_ipd   : std_ulogic     :=    'X';
    signal WRCLK_ipd : std_ulogic     :=    'X';
    signal WREN_ipd  : std_ulogic     :=    'X';

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
    signal RDCOUNT_OUT_zd : std_logic_vector(MSB_MAX_RDCOUNT  downto 0)    := (others => '1');
    signal WRCOUNT_OUT_zd : std_logic_vector(MSB_MAX_WRCOUNT  downto 0)    := (others => '1');
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
    signal addr_limit_fast    : integer := 0;
    signal wr_addr       : integer := 0;
    signal wr_addr_fast       : integer := 0;
    signal rd_addr       : integer := 0;
    signal rd_addr_fast       : integer := 0;
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
    signal ae_empty_fast   : integer := 0;
    signal ae_full_fast    : integer := 0;

-- CR 182616 fix
   signal rst_rdckreg : std_logic_vector (2 downto 0) := (others => '0');
   signal rst_wrckreg : std_logic_vector (2 downto 0) := (others => '0');
   signal sync : std_logic := 'X';
   signal sbiterr_zd : std_logic := '0';
   signal dbiterr_zd : std_logic := '0';
   signal ECCPARITY_zd : std_logic_vector(MSB_MAX_DOP downto 0) := (others => 'X');
   signal rst_rdclk_flag : std_logic := '0';
   signal rst_wrclk_flag : std_logic := '0';

   signal afull_flag : integer := 0;
   signal rise_wrclk : time := 0 ps;
   signal period_wrclk : time := 0 ps;
  
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
  WRCLK_dly      	 <= WRCLK          	after 0 ps;
  WREN_dly       	 <= WREN           	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

  ---------------------------------------------------------------------------
  -- SAFE mode
  ---------------------------------------------------------------------------

  safe_mode : if (SIM_MODE = "SAFE") generate
    
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
  variable Message : LINE;
  variable ae_empty_var      : integer := 0;
  variable ae_full_var       : integer := 0;
  
  begin
     if (first_time) then

       if (SIM_MODE /= "FAST" and SIM_MODE /= "SAFE") then
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " SIM_MODE ",
            EntityName           => "AFIFO36_INTERNAL",
            GenericValue         => SIM_MODE,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " FAST or SAFE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
       end if;

      
       case EN_SYN is
            when TRUE  => sync <= '1';
            when FALSE => sync <= '0';
            when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " EN_SYN ",
                        EntityName           => "AFIFO36_INTERNAL",
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
                        EntityName           => "AFIFO36_INTERNAL",
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
                        EntityName           => "AFIFO36_INTERNAL",
                        GenericValue         => FIRST_WORD_FALL_THROUGH,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " true or false ",
                        TailMsg              => "",
                        MsgSeverity          => failure
                        );
       end case;

       
       if (EN_SYN = FALSE) then

         if (fwft_var = '0') then
           
           if ((rd_offset_int < 5) or (rd_offset_int > addr_limit_var - 5)) then
             write( Message, STRING'("Attribute Syntax Error : ") );
             write( Message, STRING'("The attribute ") );
             write( Message, STRING'("ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL is set to ") );
             write( Message, rd_offset_int);
             write( Message, STRING'(". Legal values for this attribute are ") );
             write( Message, 5);
             write( Message, STRING'(" to ") );
             write( Message, addr_limit_var - 5 );
             ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
             DEALLOCATE (Message);
           end if;
 
           if ((wr_offset_int < 4) or (wr_offset_int > addr_limit_var - 5)) then
             write( Message, STRING'("Attribute Syntax Error : ") );
             write( Message, STRING'("The attribute ") );
             write( Message, STRING'("ALMOST_FULL_OFFSET on AFIFO36_INTERNAL is set to ") );
             write( Message, wr_offset_int);
             write( Message, STRING'(". Legal values for this attribute are ") );
             write( Message, 4);
             write( Message, STRING'(" to ") );
             write( Message, addr_limit_var - 5 );
             ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
             DEALLOCATE (Message);
           end if;

         else
           
           if ((rd_offset_int < 6) or (rd_offset_int > addr_limit_var - 4)) then
             write( Message, STRING'("Attribute Syntax Error : ") );
             write( Message, STRING'("The attribute ") );
             write( Message, STRING'("ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL is set to ") );
             write( Message, rd_offset_int);
             write( Message, STRING'(". Legal values for this attribute are ") );
             write( Message, 6);
             write( Message, STRING'(" to ") );
             write( Message, addr_limit_var - 4 );
             ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
             DEALLOCATE (Message);
           end if;
 
           if ((wr_offset_int < 4) or (wr_offset_int > addr_limit_var - 5)) then
             write( Message, STRING'("Attribute Syntax Error : ") );
             write( Message, STRING'("The attribute ") );
             write( Message, STRING'("ALMOST_FULL_OFFSET on AFIFO36_INTERNAL is set to ") );
             write( Message, wr_offset_int);
             write( Message, STRING'(". Legal values for this attribute are ") );
             write( Message, 4);
             write( Message, STRING'(" to ") );
             write( Message, addr_limit_var - 5 );
             ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
             DEALLOCATE (Message);
           end if;

         end if;

       else
           
         if ((fwft_var = '0') and ((rd_offset_int < 1) or (rd_offset_int > addr_limit_var - 2))) then
           write( Message, STRING'("Attribute Syntax Error : ") );
           write( Message, STRING'("The attribute ") );
           write( Message, STRING'("ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL is set to ") );
           write( Message, rd_offset_int);
           write( Message, STRING'(". Legal values for this attribute are ") );
           write( Message, 1);
           write( Message, STRING'(" to ") );
           write( Message, addr_limit_var - 2 );
           ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
           DEALLOCATE (Message);
         end if;

         if ((fwft_var = '0') and ((wr_offset_int < 1) or (wr_offset_int > addr_limit_var - 2))) then
           write( Message, STRING'("Attribute Syntax Error : ") );
           write( Message, STRING'("The attribute ") );
           write( Message, STRING'("ALMOST_FULL_OFFSET on AFIFO36_INTERNAL is set to ") );
           write( Message, wr_offset_int);
           write( Message, STRING'(". Legal values for this attribute are ") );
           write( Message, 1);
           write( Message, STRING'(" to ") );
           write( Message, addr_limit_var - 2 );
           ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
           DEALLOCATE (Message);
         end if;

       end if;

       
       if(fwft_var = '1' and EN_SYN = TRUE) then
          assert false
          report "DRC Error : First word fall through is not supported in synchronous mode on AFIFO36_INTERNAL."
          severity failure;
       end if;

       
       if(EN_SYN = FALSE and DO_REG = 0) then
          assert false
          report "DRC Error : DO_REG = 0 is invalid when EN_SYN is set to FALSE on AFIFO36_INTERNAL."
          severity failure;
       end if;

       
       if (not (EN_ECC_WRITE = TRUE or EN_ECC_WRITE = FALSE)) then
         GenericValueCheckMessage
           ( HeaderMsg            => " Attribute Syntax Error ",
             GenericName          => " EN_ECC_WRITE ",
             EntityName           => "AFIFO36_INTERNAL",
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
             EntityName           => "AFIFO36_INTERNAL",
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
            report "DRC Error : The attribute DATA_WIDTH must be set to 72 when AFIFO36_INTERNAL is configured in the ECC mode."
          severity failure;
       end if;

       
       addr_limit <= addr_limit_var;
       fwft       <= fwft_var;
       ae_full    <= ae_full_var;
       ae_empty   <= ae_empty_var;
       first_time := false;
     end if;
     wait;
  end process prcs_initialize;

--####################################################################
--#####                         CR 182616                        #####
--####################################################################
  prcs_rst_rdin_wrin:process(RST_dly, RDEN_dly, WREN_dly)
  begin
     if(RST_dly = '1') then
       if(RDEN_dly = '1') then
          assert false
          report "Warning : RDEN on AFIFO36_INTERNAL  is high when RST is high. RDEN should be low during reset."
          severity Warning;
       end if;

       if(WREN_dly = '1') then
          assert false
          report "Warning : WREN on AFIFO36_INTERNAL  is high when RST is high. WREN should be low during reset."
          severity Warning;
       end if;
     end if;
  end process prcs_rst_rdin_wrin;
-------------------------------------------

  prcs_3clkrst_readwrite:process(RDCLK_dly, WRCLK_dly)
  variable  rst_rdckreg_var : std_logic_vector (2 downto 0) := (others => '0');
  variable  rst_wrckreg_var : std_logic_vector (2 downto 0) := (others => '0');
  begin
    if(rising_edge(RDCLK_dly)) then
      rst_rdckreg_var(2) := RST_dly and rst_rdckreg_var(1);
      rst_rdckreg_var(1) := RST_dly and rst_rdckreg_var(0);
      rst_rdckreg_var(0) := RST_dly;
    end if;   
           
    if(rising_edge(WRCLK_dly)) then
      rst_wrckreg_var(2) := RST_dly and rst_wrckreg_var(1);
      rst_wrckreg_var(1) := RST_dly and rst_wrckreg_var(0);
      rst_wrckreg_var(0) := RST_dly;
    end if;   

    rst_rdckreg <= rst_rdckreg_var;
    rst_wrckreg <= rst_wrckreg_var;
  end process prcs_3clkrst_readwrite;

  prcs_2clkrst:process(RST_dly)
  begin
    rst_rdclk_flag <= '0';
    rst_wrclk_flag <= '0';

       if(falling_edge(RST_dly)) then
         if((rst_rdckreg(2) ='0') or (rst_rdckreg(1) ='0') or (rst_rdckreg(0) ='0')) then  
             assert false
             report "DRC Error : RST has to be held high for more than three RDCLK cycles on AFIFO36_INTERNAL instance."
             severity Error;
             rst_rdclk_flag <= '1';
         end if;
         
         if((rst_wrckreg(2) ='0') or (rst_wrckreg(1) ='0') or (rst_wrckreg(0) ='0')) then  
             assert false
             report "DRC Error : RST has to be held high for more than three WRCLK cycles on AFIFO36_INTERNAL instance."
             severity Error;
             rst_wrclk_flag <= '1';
         end if;

      end if;

      
  end process prcs_2clkrst;

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

  variable Message : LINE;
  variable aempty_flag_var : integer := 0;
  variable rise_rdclk_var : time := 0 ps;
  variable period_rdclk_var : time := 0 ps;
  variable rd_offset_stdlogic : std_logic_vector (ALMOST_EMPTY_OFFSET'length-1 downto 0);
  variable rd_offset_int : integer := 0;
  variable roundup_period_rd_wr_int : integer := 0;
  variable period_rdclk_real_var : real := 0.0;
  variable period_wrclk_real_var : real := 0.0;

  
  begin
     if((GSR_dly = '1') or (RST_dly = '1')) then
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

       period_rdclk_var := 0 ps;
       rise_rdclk_var := 0 ps;
       aempty_flag_var := 0;
   
       if(GSR_dly = '1') then
         DO_zd((mem_width -1) downto 0) <= (others => '0');
         DO_OUTREG_zd((mem_width -1) downto 0) <= (others => '0');
         if (DATA_WIDTH /= 4) then
           DOP_zd((memp_width -1) downto 0) <= (others => '0');
           DOP_OUTREG_zd((memp_width -1) downto 0) <= (others => '0');
         end if;
       end if;

     elsif ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then

       rd_addr <= 0;
       rd_flag <= '0';

       rd_addr_var  := 0;
       wr_addr_var  := 0;
       wr1_addr_var := 0;
       rd_prefetch_var := 0;
   
       rdcount_var := 0;

       period_rdclk_var := 0 ps;
       rise_rdclk_var := 0 ps;
       aempty_flag_var := 0;
       
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

       DO_zd((mem_width -1) downto 0) <= (others => 'X');
       DO_OUTREG_zd((mem_width -1) downto 0) <= (others => 'X');

       if (DATA_WIDTH /= 4) then
         DOP_zd((memp_width -1) downto 0) <= (others => 'X');
         DOP_OUTREG_zd((memp_width -1) downto 0) <= (others => 'X');
       end if;
       
     elsif ((GSR_dly = '0') and (RST_dly = '0'))then

       rden_var := RDEN_dly;
       wren_var := WREN_dly;

       if(rising_edge(RDCLK_dly)) then

         rd_flag_var := rd_flag;
         wr_flag_var := wr_flag;
         awr_flag_var := awr_flag;

         rd_addr_var := rd_addr;
         wr_addr_var := wr_addr;

         rdcount_var := SLV_TO_INT(RDCOUNT_zd);
         rdcount_flag_var := rdcount_flag;

         
         if (fwft = '1' and (NOW > 100000 ps) and aempty_flag_var < 2) then
	    
	    if (aempty_flag_var = 0) then
		rise_rdclk_var := NOW;
	    else
		period_rdclk_var := NOW - rise_rdclk_var;
            end if;
            
	    aempty_flag_var := aempty_flag_var + 1;

         end if;
        
	
         if (aempty_flag_var = 2 and afull_flag = 2) then
          
           rd_offset_stdlogic := To_StdLogicVector(ALMOST_EMPTY_OFFSET);
           rd_offset_int := SLV_TO_INT(rd_offset_stdlogic);
           
           period_rdclk_real_var := real (period_rdclk_var / 1 ps);
           period_wrclk_real_var := real (period_wrclk / 1 ps);
              
           roundup_period_rd_wr_int := integer ((period_rdclk_real_var / period_wrclk_real_var) + 0.499);

           if (rd_offset_int <= (4 * roundup_period_rd_wr_int)) then

              write( Message, STRING'("DRC Error : ") );
              write( Message, STRING'("The attribute ") );
              write( Message, STRING'("ALMOST_EMPTY_OFFSET on AFIFO36_INTERNAL is set to ") );
              write( Message, rd_offset_int);
              write( Message, STRING'(". It must be set to a value greater than (4 * roundup (WRCLK frequency / RDCLK frequency)) when AFIFO36_INTERNAL is configured in FIRST_WORD_FALL_THROUGH mode.") );
              ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
              DEALLOCATE (Message);

            end if;

       end if;
              
         
         if (sync = '1') then
           
           DO_OUTREG_var := DO_zd;
           DOP_OUTREG_var := DOP_zd;

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
                
                     dbiterr_out_out_var := '0';  -- latch out in sync mode
                     sbiterr_out_out_var := '1';

                   elsif (syndrome(7) = '0') then  -- double bit error
                     sbiterr_out_out_var := '0';
                     dbiterr_out_out_var := '1';
                   end if;
                 else
                   dbiterr_out_out_var := '0';
                   sbiterr_out_out_var := '0';
                 end if;              
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

         dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
         sbiterr_out_out_var := sbiterr_out;
                    
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
                
                     dbiterr_out := '0';  -- reg out in async mode
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
       dbiterr_zd <= dbiterr_out_out_var; -- reg out in async mode
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
  variable dip_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable dip_dly_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable ALMOSTFULL_var : std_ulogic     :=    '0';

  begin
    if ((GSR_dly = '1') or (RST_dly = '1') or (rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then
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

        period_wrclk <= 0 ps;
        rise_wrclk <= 0 ps;
        afull_flag <= 0;
        
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

    elsif((GSR_dly = '0') and (RST_dly = '0'))then
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


        if (fwft = '1' and (NOW > 100000 ps) and afull_flag < 2) then
	    
	    if (afull_flag = 0) then
		rise_wrclk <= NOW;
	    else
		period_wrclk <= NOW - rise_wrclk;
            end if;
                
	    afull_flag <= afull_flag + 1;

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

            mem(wr_addr_var) <= DI_dly(mem_width-1 downto 0);
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

            mem(wr_addr_var) <= DI_dly(mem_width-1 downto 0);
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
  prcs_x_1_output_wrcount: process (WRCOUNT_zd, RST_dly, GSR_dly, rst_rdclk_flag, rst_wrclk_flag)
  begin

    if((GSR_dly = '1') or (RST_dly = '1')) then
      WRCOUNT_OUT_zd <= (others => '0');
    elsif ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then
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
    elsif ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then
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

  
  end generate;

-------------------------------------------------------------------------------
-- FAST mode
-------------------------------------------------------------------------------

  fast_mode : if (SIM_MODE = "FAST") generate


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
  variable Message : LINE;
  variable ae_empty_var      : integer := 0;
  variable ae_full_var       : integer := 0;
  
  begin
     if (first_time) then

       if (SIM_MODE /= "FAST" and SIM_MODE /= "SAFE") then
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " SIM_MODE ",
            EntityName           => "AFIFO36_INTERNAL",
            GenericValue         => SIM_MODE,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " FAST or SAFE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
       end if;

       
       case EN_SYN is
            when TRUE  => sync <= '1';
            when FALSE => sync <= '0';
            when others =>
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
       end case;

       
       addr_limit_fast <= addr_limit_var;
       fwft       <= fwft_var;
       ae_full_fast    <= ae_full_var;
       ae_empty_fast   <= ae_empty_var;
       first_time := false;
     end if;
     wait;
  end process prcs_initialize;


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
     if((GSR_dly = '1') or (RST_dly = '1')) then
       rd_addr_fast <= 0;
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
  
       if(GSR_dly = '1') then
         DO_zd((mem_width -1) downto 0) <= (others => '0');
         DO_OUTREG_zd((mem_width -1) downto 0) <= (others => '0');
         if (DATA_WIDTH /= 4) then
           DOP_zd((memp_width -1) downto 0) <= (others => '0');
           DOP_OUTREG_zd((memp_width -1) downto 0) <= (others => '0');
         end if;
       end if;

     elsif ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then

       rd_addr_fast <= 0;
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

       DO_zd((mem_width -1) downto 0) <= (others => 'X');
       DO_OUTREG_zd((mem_width -1) downto 0) <= (others => 'X');

       if (DATA_WIDTH /= 4) then
         DOP_zd((memp_width -1) downto 0) <= (others => 'X');
         DOP_OUTREG_zd((memp_width -1) downto 0) <= (others => 'X');
       end if;
       
     elsif ((GSR_dly = '0') and (RST_dly = '0'))then

       rden_var := RDEN_dly;
       wren_var := WREN_dly;

       if(rising_edge(RDCLK_dly)) then

         rd_flag_var := rd_flag;
         wr_flag_var := wr_flag;
         awr_flag_var := awr_flag;

         rd_addr_var := rd_addr_fast;
         wr_addr_var := wr_addr_fast;

         rdcount_var := SLV_TO_INT(RDCOUNT_zd);
         rdcount_flag_var := rdcount_flag;


         if (sync = '1') then
           
           DO_OUTREG_var := DO_zd;
           DOP_OUTREG_var := DOP_zd;

           if (RDEN_dly = '1') then

             if (EMPTY_zd = '0') then

               DO_zd(mem_width-1 downto 0) <= mem(rdcount_var);
               DOP_zd(memp_width-1 downto 0) <= memp(rdcount_var);
               
               rdcount_var := (rdcount_var + 1) mod addr_limit_fast;

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
             
           if((((rdcount_var + ae_empty_fast) >= wr_addr_var) and (rdcount_flag_var = wr_flag_var)) or (((rdcount_var + ae_empty_fast) >= (wr_addr_var + addr_limit_fast)) and (rdcount_flag_var /= wr_flag_var))) then    
             ALMOSTEMPTY_zd <= '1';
           end if;

           update_from_read_prcs_sync <= not update_from_read_prcs_sync;

       elsif (sync = '0') then

         dbiterr_out_out_var := dbiterr_out; -- reg out in async mode
         sbiterr_out_out_var := sbiterr_out;
                    
         if(fwft = '0') then
           addr_limit_var := addr_limit_fast;
           if((rden_var = '1') and (rd_addr_var /= rdcount_var)) then
              DO_zd   <= do_in;
              if (DATA_WIDTH /= 4) then
                DOP_zd  <= dop_in;
              end if;
              rd_addr_var  := (rd_addr_var + 1) mod addr_limit_fast;
              if(rd_addr_var = 0) then 
                  rd_flag_var := NOT rd_flag_var;
              end if;
           end if;
           if (((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or 
              ((rden_var = '1') and (empty_ram(1) = '0'))) then
                do_in(mem_width-1 downto 0) := mem(rdcount_var);
                dop_in(memp_width-1 downto 0) := memp(rdcount_var);
 
             rdcount_var := (rdcount_var + 1) mod addr_limit_fast;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;
         
         elsif(fwft = '1') then
           if((rden_var = '1') and (rd_addr_var /= rd_prefetch_var)) then
              rd_prefetch_var := (rd_prefetch_var + 1) mod addr_limit_fast;
              if(rd_prefetch_var = 0) then 
                  rd_prefetch_flag_var := NOT rd_prefetch_flag_var;
              end if;
           end if;
           if((rd_prefetch_var = rd_addr_var) and (rd_addr_var /= rdcount_var)) then
             DO_zd   <= do_in;
             if (DATA_WIDTH /= 4) then
               DOP_zd <= dop_in;
             end if;
             rd_addr_var  := (rd_addr_var + 1) mod addr_limit_fast;
             if(rd_addr_var = 0) then 
                rd_flag_var := NOT rd_flag_var;
             end if;
           end if;
           if(((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or
              ((rden_var = '1')  and (empty_ram(1) = '0')) or 
              ((rden_var = '0')  and (empty_ram(1) = '0') and (rd_addr_var = rdcount_var))) then 
                do_in(mem_width-1 downto 0) := mem(rdcount_var);
                dop_in(memp_width-1 downto 0) := memp(rdcount_var);

              rdcount_var := (rdcount_var + 1) mod addr_limit_fast;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;

         end if;

       end if;  ---  end if(fwft = '1')


         ALMOSTEMPTY_zd <= almostempty_int(3);

         if((((rdcount_var + ae_empty_fast) >= wr_addr_var) and (rdcount_flag_var = awr_flag_var)) or (((rdcount_var + ae_empty_fast) >= (wr_addr_var + addr_limit_fast)) and (rdcount_flag_var /= awr_flag_var))) then    
            almostempty_int(3) := '1';
            almostempty_int(2) := '1';
            almostempty_int(1) := '1';
            almostempty_int(0) := '1';
         elsif(almostempty_int(2)  = '0') then
           -- added to match verilog
           if (rdcount_var <= rdcount_var + ae_empty_fast or rdcount_flag_var /= awr_flag_var) then
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

         wr1_addr_var := wr_addr_fast;
         wr1_flag_var := awr_flag;

         if((rden_var = '1') and (EMPTY_zd = '1')) then
             RDERR_zd <= '1';
         else
             RDERR_zd <= '0';
         end if; -- end ((rden_var = '1') and (empty_int /= '1'))

        update_from_read_prcs <= NOT update_from_read_prcs;

       end if;
       
     end if; -- end (rising_edge(RDCLK_dly))

  end if; -- end (GSR_dly = 1)



     if(update_from_write_prcs_sync'event) then
       wr_addr_var := wr_addr_fast;
       wr_flag_var := wr_flag;
       if((((rdcount_var + ae_empty_fast) <  wr_addr_var)  and (rdcount_flag_var = wr_flag_var)) or 
          (((rdcount_var + ae_empty_fast) < (wr_addr_var + addr_limit_fast)) and (rdcount_flag_var /= wr_flag_var))) then    
          if(rdcount_var <= rdcount_var + ae_empty_fast or rdcount_flag_var /= wr_flag_var) then
            almostempty_zd <= '0';
          end if;
       end if;
     end if;
  
     
     if(update_from_write_prcs'event) then
       wr_addr_var := wr_addr_fast;
       wr_flag_var := wr_flag;
       awr_flag_var := awr_flag;

       if((((rdcount_var + ae_empty_fast) <  wr_addr_var)  and (rdcount_flag_var = awr_flag_var)) or 
          (((rdcount_var + ae_empty_fast) <  ( wr_addr_var + addr_limit_fast)) and (rdcount_flag_var /= awr_flag_var))) then    
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
       dbiterr_zd <= dbiterr_out_out_var; -- reg out in async mode
       sbiterr_zd <= sbiterr_out_out_var;
     end if;

     rd_addr_fast <= rd_addr_var;
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
  variable dip_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable dip_dly_ecc : std_logic_vector(MSB_MAX_DOP downto 0) := (others => '0');
  variable ALMOSTFULL_var : std_ulogic     :=    '0';

  begin
    if ((GSR_dly = '1') or (RST_dly = '1') or (rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then
        wr_addr_var := 0;
        wr_addr_fast <=  0;
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

    elsif((GSR_dly = '0') and (RST_dly = '0'))then
      rden_var := RDEN_dly;
      wren_var := WREN_dly;

      if(rising_edge(WRCLK_dly)) then

        rd_flag_var := rd_flag;
        wr_flag_var := wr_flag;
        awr_flag_var := awr_flag;        

        rd_addr_var := rd_addr_fast;
        wr_addr_var := wr_addr_fast;

        rdcount_var := SLV_TO_INT(RDCOUNT_zd);
        rdcount_flag_var := rdcount_flag;

	if (sync = '1') then
          if(wren_dly = '1') then
            if (full_zd= '0') then

            mem(wr_addr_var) <= DI_dly(mem_width-1 downto 0);
            memp(wr_addr_var) <= DIP_dly(memp_width-1 downto 0);

            wr_addr_var := (wr_addr_var + 1) mod addr_limit_fast;

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

        if((((rdcount_var + addr_limit_fast) <= (wr_addr_var + ae_full_fast)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var <= (wr_addr_var + ae_full_fast)) and (rdcount_flag_var /= wr_flag_var))) then
          almostfull_zd <= '1';
        end if;
        

      elsif (sync = '0') then

        if((wren_var = '1') and (full_zd = '0'))then  

            mem(wr_addr_var) <= DI_dly(mem_width-1 downto 0);
            if (DATA_WIDTH >= 9) then
              memp(wr_addr_var) <= DIP_dly(memp_width-1 downto 0);              
            end if;
                
            wr_addr_var := (wr_addr_var + 1) mod addr_limit_fast;
         
            if(wr_addr_var = 0) then
              awr_flag_var := NOT awr_flag_var;
            end if;

            if(wr_addr_var = addr_limit_fast - 1) then
              wr_flag_var := NOT wr_flag_var;
            end if;
            
        end if; -- if((wren_var = '1') and (FULL_zd = '0') ....      

        if((wren_var = '1') and (full_zd = '1')) then 
            WRERR_zd <= '1';
        else
            WRERR_zd <= '0';
        end if;

        ALMOSTFULL_var := almostfull_int(3);
        
        if((((rdcount_var + addr_limit_fast) <= (wr_addr_var + ae_full_fast)) and (rdcount_flag_var = awr_flag_var)) or ((rdcount_var <= (wr_addr_var + ae_full_fast)) and (rdcount_flag_var /= awr_flag_var))) then    
          almostfull_int(3) := '1';
          almostfull_int(2) := '1';
          almostfull_int(1) := '1';
          almostfull_int(0) := '1';
        elsif(almostfull_int(2)  = '0') then
          if (wr_addr_var <= wr_addr_var + ae_full_fast or rdcount_flag_var = awr_flag_var) then

            almostfull_int(3) := almostfull_int(0);
            almostfull_int(0) :=  '0';

          end if;
        end if;

        if (wren_var = '1' or full_zd = '1') then
          full_zd <= full_int(1);
        end if;

        if(((rdcount_var = wr_addr_var) or (rdcount_var - 1 = wr_addr_var or rdcount_var + addr_limit_fast - 1 = wr_addr_var)) and ALMOSTFULL_var = '1') then
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

        wr_addr_fast <= wr_addr_var;
        wr_flag <= wr_flag_var;
        awr_flag <= awr_flag_var;

    end if; -- if(rising(WRCLK_dly))

  end if; -- if(GSR_dly = '1'))


    if(update_from_read_prcs_sync'event) then
      rdcount_var := SLV_TO_INT(RDCOUNT_zd);
      rdcount_flag_var := rdcount_flag;
      if((((rdcount_var + addr_limit_fast) > (wr_addr_var + ae_full_fast)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var > (wr_addr_var + ae_full_fast)) and (rdcount_flag_var /= wr_flag_var))) then
        if (wr_addr_var <= wr_addr_var + ae_full_fast or rdcount_flag_var = wr_flag_var) then
          ALMOSTFULL_zd <= '0';
        end if;
      end if;
    end if;

    if(update_from_read_prcs'event) then
       rdcount_var := SLV_TO_INT(RDCOUNT_zd);
       rdcount_flag_var := rdcount_flag;

       if((((rdcount_var + addr_limit_fast) > (wr_addr_var + ae_full_fast)) and (rdcount_flag_var = awr_flag_var)) or ((rdcount_var > (wr_addr_var + ae_full_fast)) and (rdcount_flag_var /= awr_flag_var))) then    

           if(((rden_var = '1') and (EMPTY_zd = '0')) or ((((rd_addr_var + 1) mod addr_limit_fast) = rdcount_var) and (almostfull_int(1) = '1'))) then
              almostfull_int(2) := almostfull_int(1);
              almostfull_int(1) := '0';
           end if;
       else
           almostfull_int(2) := '1';
           almostfull_int(1) := '1';
       end if;
    end if;

  end process prcs_write;

  
  outmux: process (DO_zd, DOP_zd, DO_OUTREG_zd, DOP_OUTREG_zd)
  begin  -- process outmux_clka

    if (sync = '1') then
      
      case DO_REG is
        when 0 =>
                  DO_OUT_zd <= DO_zd;
                  DOP_OUT_zd <= DOP_zd;
        when 1 =>
                  DO_OUT_zd <= DO_OUTREG_zd;
                  DOP_OUT_zd <= DOP_OUTREG_zd;
        when others =>
      end case;

    else
      DO_OUT_zd <= DO_zd;
      DOP_OUT_zd <= DOP_zd;
    end if;
    
  end process outmux;
  

  -- matching HW behavior to pull up and X the unused output bits
  prcs_x_1_output: process (WRCOUNT_zd, RDCOUNT_zd, RST_dly, GSR_dly)
  begin  -- process prcs_x_1_output

    if ((GSR_dly = '1') or (RST_dly = '1')) then
      RDCOUNT_OUT_zd <= (others => '0');
      WRCOUNT_OUT_zd <= (others => '0');
    else
      RDCOUNT_OUT_zd <= RDCOUNT_zd;
      WRCOUNT_OUT_zd <= WRCOUNT_zd;
    end if;
        
  end process prcs_x_1_output;

  
  end generate;


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(ALMOSTEMPTY_zd, ALMOSTFULL_zd, DO_OUT_zd, DOP_OUT_zd, 
                      EMPTY_zd, FULL_zd, RDCOUNT_OUT_zd, RDERR_zd, 
                      WRCOUNT_OUT_zd, WRERR_zd, sbiterr_zd, dbiterr_zd)
  begin
      ALMOSTEMPTY <= ALMOSTEMPTY_zd;
      ALMOSTFULL  <= ALMOSTFULL_zd;
      DO          <= DO_OUT_zd;
      DOP         <= DOP_OUT_zd;
      EMPTY       <= EMPTY_zd;
      FULL        <= FULL_zd;
      RDCOUNT     <= RDCOUNT_OUT_zd;
      RDERR       <= RDERR_zd;
      WRCOUNT     <= WRCOUNT_OUT_zd;
      WRERR       <= WRERR_zd;
      ECCPARITY   <= ECCPARITY_zd;
      SBITERR     <= sbiterr_zd;
      DBITERR     <= dbiterr_zd;
  end process prcs_output;
--####################################################################


end AFIFO36_INTERNAL_V;

