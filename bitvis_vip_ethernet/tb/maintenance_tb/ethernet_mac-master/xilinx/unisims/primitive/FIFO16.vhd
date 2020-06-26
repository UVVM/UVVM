-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  16K-Bit FIFO
-- /___/   /\     Filename : FIFO16.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:18:20 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    02/06/06 - Updated the reset requirement message.
--    05/31/06 - Added feature for invalid reset condition. (CR 223364).
--    04/07/08 - CR 469973 -- Header Description fix
-- End Revision
  
----- CELL FIFO16 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

library STD;
use STD.TEXTIO.ALL;


library unisim;
use unisim.vpkg.all;

entity FIFO16 is

  generic(

    ALMOST_FULL_OFFSET      : bit_vector := X"080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"080"; 
    DATA_WIDTH              : integer    := 36;
    FIRST_WORD_FALL_THROUGH : boolean    := false
    );

  port(
    ALMOSTEMPTY : out std_ulogic;
    ALMOSTFULL  : out std_ulogic;
    DO          : out std_logic_vector (31 downto 0);
    DOP         : out std_logic_vector (3 downto 0);
    EMPTY       : out std_ulogic;
    FULL        : out std_ulogic;
    RDCOUNT     : out std_logic_vector (11 downto 0);
    RDERR       : out std_ulogic;
    WRCOUNT     : out std_logic_vector (11 downto 0);
    WRERR       : out std_ulogic;

    DI          : in  std_logic_vector (31 downto 0);
    DIP         : in  std_logic_vector (3 downto 0);
    RDCLK       : in  std_ulogic;
    RDEN        : in  std_ulogic;
    RST         : in  std_ulogic;
    WRCLK       : in  std_ulogic;
    WREN        : in  std_ulogic
    );

end FIFO16;

-- architecture body                    --

architecture FIFO16_V of FIFO16 is


    constant SYNC_PATH_DELAY: time  := 100 ps;
    
    constant MAX_DO      : integer    := 32;
    constant MAX_DOP     : integer    := 4;
    constant MAX_RDCOUNT : integer    := 12;
    constant MAX_WRCOUNT : integer    := 12;
    constant MSB_MAX_DO  : integer    := 31;
    constant MSB_MAX_DOP : integer    := 3;
    constant MSB_MAX_RDCOUNT : integer    := 11;
    constant MSB_MAX_WRCOUNT : integer    := 11;

    constant MAX_DI      : integer    := 32;
    constant MAX_DIP     : integer    := 4;
    constant MSB_MAX_DI  : integer    := 31;
    constant MSB_MAX_DIP : integer    := 3;

    constant MAX_LATENCY_EMPTY : integer := 3;
    constant MAX_LATENCY_FULL  : integer := 3;

    signal MEM  : std_logic_vector( 16383 downto 0 ) := (others => 'X');
    signal MEMP : std_logic_vector( 2047 downto 0 )  := (others => 'X');

    signal DI_ipd    : std_logic_vector(MSB_MAX_DI downto 0)    := (others => 'X');
    signal DIP_ipd   : std_logic_vector(MSB_MAX_DIP downto 0)   := (others => 'X');
    signal GSR       : std_ulogic     :=    '0';
    signal GSR_ipd   : std_ulogic     :=    'X';
    signal RDCLK_ipd : std_ulogic     :=    'X';
    signal RDEN_ipd  : std_ulogic     :=    'X';
    signal RST_ipd   : std_ulogic     :=    'X';
    signal WRCLK_ipd : std_ulogic     :=    'X';
    signal WREN_ipd  : std_ulogic     :=    'X';

    signal DI_dly    : std_logic_vector(MSB_MAX_DI downto 0)    := (others => 'X');
    signal DIP_dly   : std_logic_vector(MSB_MAX_DIP downto 0)   := (others => 'X');
    signal GSR_dly   : std_ulogic     :=    'X';
    signal RDCLK_dly : std_ulogic     :=    'X';
    signal RDEN_dly  : std_ulogic     :=    'X';
    signal RST_dly   : std_ulogic     :=    'X';
    signal WRCLK_dly : std_ulogic     :=    'X';
    signal WREN_dly  : std_ulogic     :=    'X';

    signal DO_zd          : std_logic_vector(MSB_MAX_DO  downto 0)    := (others => '0');
    signal DOP_zd         : std_logic_vector(MSB_MAX_DOP downto 0)    := (others => '0');
    signal ALMOSTEMPTY_zd : std_ulogic     :=    '1';
    signal ALMOSTFULL_zd  : std_ulogic     :=    '0';
    signal EMPTY_zd       : std_ulogic     :=    '1';
    signal FULL_zd        : std_ulogic     :=    '0';
    signal RDCOUNT_zd     : std_logic_vector(MSB_MAX_RDCOUNT  downto 0)    := (others => '0');
    signal RDERR_zd       : std_ulogic     :=    '0';
    signal WRCOUNT_zd     : std_logic_vector(MSB_MAX_WRCOUNT  downto 0)    := (others => '0');
    signal WRERR_zd       : std_ulogic     :=    '0';
    signal RDCOUNT_OUT_zd : std_logic_vector(MSB_MAX_RDCOUNT  downto 0)    := (others => '1');
    signal WRCOUNT_OUT_zd : std_logic_vector(MSB_MAX_WRCOUNT  downto 0)    := (others => '1');
    signal DO_OUT_zd      : std_logic_vector(MSB_MAX_DO  downto 0)         := (others => 'X');
    signal DOP_OUT_zd     : std_logic_vector(MSB_MAX_DOP  downto 0)        := (others => 'X');
    
  --- Internal Signal Declarations

    signal RST_META    : std_ulogic := '0';

    signal DefDelay    : time := 10 ps;

    signal addr_limit    : integer := 0;
    signal wr_addr       : integer := 0;
    signal rd_addr       : integer := 0;
    signal rd_addr_range : integer := 0;
    signal wr_addr_range : integer := 0;

    signal rd_flag       : std_ulogic := '0';
    signal wr_flag       : std_ulogic := '0';

    signal rdcount_flag  : std_ulogic := '0';

    signal D_W           : integer := 32;
    signal P_W           : integer := 4;

    signal almostempty_limit : real := 0.0;
    signal almostfull_limit  : real := 0.0;

    signal violation : std_ulogic := '0'; 

    signal fwft      : std_ulogic := 'X';

    signal update_from_write_prcs      : std_ulogic := '0';
    signal update_from_read_prcs       : std_ulogic := '0';

    signal ae_empty   : integer := 0;

-- CR 182616 fix
   signal rst_rdckreg : std_logic_vector (2 downto 0) := (others => '0');
   signal rst_wrckreg : std_logic_vector (2 downto 0) := (others => '0');
   signal rst_rdclk_flag : std_ulogic := '0';
   signal rst_wrclk_flag : std_ulogic := '0';
    
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

  begin
     if (first_time) then
       case  DATA_WIDTH is
            when 4  => 
                      addr_limit_var := 4096;
                      D_W <= 4;
                      P_W <= 0;
            when 9  =>
                      addr_limit_var := 2048;
                      D_W <= 8;
                      P_W <= 1;
            when 18 => 
                      addr_limit_var := 1024;
                      D_W <= 16; 
                      P_W <= 2;
            when 36 => 
                      addr_limit_var := 512;
                      D_W <= 32;
                      P_W <= 4;
            when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " DATA_WIDTH ",
                        EntityName           => "FIFO16",
                        GenericValue         => DATA_WIDTH,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " 4, 9, 18 and 36 ",
                        TailMsg              => "",
                        MsgSeverity          => error
                        );
       end case;

       rd_offset_stdlogic := To_StdLogicVector(ALMOST_EMPTY_OFFSET);
       rd_offset_int := SLV_TO_INT(rd_offset_stdlogic);

       wr_offset_stdlogic := To_StdLogicVector(ALMOST_FULL_OFFSET);
       wr_offset_int := SLV_TO_INT(wr_offset_stdlogic);

       case FIRST_WORD_FALL_THROUGH is
            when true  =>
                         fwft_var     := '1';
                         ae_empty_var := rd_offset_int - 2;
            when false =>
                         fwft_var     := '0';
                         ae_empty_var := rd_offset_int - 1;
            when others =>
                    GenericValueCheckMessage
                      ( HeaderMsg            => " Attribute Syntax Error ",
                        GenericName          => " FIRST_WORD_FALL_THROUGH ",
                        EntityName           => "FIFO16",
                        GenericValue         => FIRST_WORD_FALL_THROUGH,
                        Unit                 => "",
                        ExpectedValueMsg     => " The Legal values for this attribute are ",
                        ExpectedGenericValue => " true or false ",
                        TailMsg              => "",
                        MsgSeverity          => error
                        );
       end case;

       if ((fwft_var = '0') and ((rd_offset_int < 5) or (rd_offset_int > addr_limit_var - 4))) then
          write( Message, STRING'("Attribute Syntax Error : ") );
          write( Message, STRING'("The attribute ") );
          write( Message, STRING'("ALMOST_EMPTY_OFFSET on FIFO16 is set to ") );
          write( Message, rd_offset_int);
          write( Message, STRING'(". Legal values for this attribute are ") );
          write( Message, 5);
          write( Message, STRING'(" to ") );
          write( Message, addr_limit_var - 4 );
          ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
          DEALLOCATE (Message);
       end if;
 
       if ((fwft_var = '0') and ((wr_offset_int < 4) or (wr_offset_int > addr_limit_var - 5))) then
          write( Message, STRING'("Attribute Syntax Error : ") );
          write( Message, STRING'("The attribute ") );
          write( Message, STRING'("ALMOST_FULL_OFFSET on FIFO16 is set to ") );
          write( Message, wr_offset_int);
          write( Message, STRING'(". Legal values for this attribute are ") );
          write( Message, 4);
          write( Message, STRING'(" to ") );
          write( Message, addr_limit_var - 5 );
          ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
          DEALLOCATE (Message);
       end if;

       if ((fwft_var = '1') and ((rd_offset_int < 6) or (rd_offset_int > addr_limit_var - 3))) then
          write( Message, STRING'("Attribute Syntax Error : ") );
          write( Message, STRING'("The attribute ") );
          write( Message, STRING'("ALMOST_EMPTY_OFFSET on FIFO16 is set to ") );
          write( Message, rd_offset_int);
          write( Message, STRING'(". Legal values for this attribute are ") );
          write( Message, 6);
          write( Message, STRING'(" to ") );
          write( Message, addr_limit_var - 3 );
          ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
          DEALLOCATE (Message);
       end if;

       if ((fwft_var = '1') and ((wr_offset_int < 4) or (wr_offset_int > addr_limit_var - 5))) then
          write( Message, STRING'("Attribute Syntax Error : ") );
          write( Message, STRING'("The attribute ") );
          write( Message, STRING'("ALMOST_FULL_OFFSET on FIFO16 is set to ") );
          write( Message, wr_offset_int);
          write( Message, STRING'(". Legal values for this attribute are ") );
          write( Message, 4);
          write( Message, STRING'(" to ") );
          write( Message, addr_limit_var - 5 );
          ASSERT FALSE REPORT Message.ALL SEVERITY Failure;
          DEALLOCATE (Message);
       end if;


       addr_limit <= addr_limit_var;
       fwft       <= fwft_var;
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
          report "Warning : RDEN on FIFO16  is high when RST is high. RDEN should be low during reset."
          severity Warning;
       end if;

       if(WREN_dly = '1') then
          assert false
          report "Warning : WREN on FIFO16  is high when RST is high. WREN should be low during reset."
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
             report "Error : RST signal on FIFO16 stays high for less than three RDCLK clock cycles. RST has to stay high for more than three RDCLK clock cycles"
             severity Error;
             rst_rdclk_flag <= '1';
         end if;
         if((rst_wrckreg(2) ='0') or (rst_wrckreg(1) ='0') or (rst_wrckreg(0) ='0')) then  
             assert false
             report "Error : RST signal on FIFO16 stays high for less than three WRCLK clock cycles. RST has to stay high for more than three WRCLK clock cycles"
             severity Error;
             rst_wrclk_flag <= '1';
         end if;
      end if;
  end process prcs_2clkrst;

--####################################################################
--#####                         Read                             #####
--####################################################################
  prcs_read:process(RDCLK_dly, RST_dly, GSR_dly, update_from_write_prcs, rst_rdclk_flag, rst_wrclk_flag)
  variable first_time        : boolean    := true;
  variable rd_addr_var       : integer    := 0;
  variable wr_addr_var       : integer    := 0;
  variable rdcount_var       : integer    := 0;

  variable rd_flag_var       : std_ulogic := '0';
  variable wr_flag_var       : std_ulogic := '0';

  variable rdcount_flag_var  : std_ulogic := '0';

  variable rd_offset_stdlogic : std_logic_vector (ALMOST_EMPTY_OFFSET'length-1 downto 0);
  variable rd_offset_int : integer := 0;

  variable do_in             : std_logic_vector(MSB_MAX_DO  downto 0)    := (others => 'X');
  variable dop_in            : std_logic_vector(MSB_MAX_DOP downto 0)    := (others => 'X');

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

  begin
     if((GSR_dly = '1') or (RST_dly = '1'))then
       rd_addr <= 0;
       rd_flag <= '0';

       rd_addr_var  := 0;
       wr_addr_var  := 0;
       wr1_addr_var := 0;
       rd_prefetch_var := 0;
   
       rdcount_var := 0;
       
       rd_flag_var  := '0';
       wr_flag_var  := '0';
       wr1_flag_var := '0';
       rd_prefetch_flag_var := '0';
  
       rdcount_flag_var := '0';

       empty_int       :=  (others => '1');
       almostempty_int :=  (others => '1');
       empty_ram       :=  (others => '1');

       ALMOSTEMPTY_zd <= '1';
       EMPTY_zd <= '1';
       RDERR_zd <= '0';
       RDCOUNT_zd <= (others => '0');

       if(GSR_dly = '1') then
          DO_zd((D_W -1) downto 0) <= (others => '0');
          DOP_zd((P_W -1) downto 0) <= (others => '0');
       end if;

     elsif ((rst_rdclk_flag = '1') or (rst_wrclk_flag = '1'))then

       rd_addr <= 0;
       rd_flag <= '0';

       rd_addr_var  := 0;
       wr_addr_var  := 0;
       wr1_addr_var := 0;
       rd_prefetch_var := 0;
   
       rdcount_var := 0;
       
       rd_flag_var  := '0';
       wr_flag_var  := '0';
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

       DO_zd((D_W -1) downto 0) <= (others => 'X');
       DOP_zd((P_W -1) downto 0) <= (others => 'X');
       
     elsif ((GSR_dly = '0') and (RST_dly = '0'))then

       rden_var := RDEN_dly;
       wren_var := WREN_dly;

       if(rising_edge(RDCLK_dly)) then

         rd_offset_stdlogic := To_StdLogicVector(ALMOST_EMPTY_OFFSET);
         rd_offset_int := SLV_TO_INT(rd_offset_stdlogic);

         rd_flag_var := rd_flag;
         wr_flag_var := wr_flag;

         rd_addr_var := rd_addr;
         wr_addr_var := wr_addr;

         rdcount_var := SLV_TO_INT(RDCOUNT_zd);
         rdcount_flag_var := rdcount_flag;

         if(fwft = '0') then
           addr_limit_var := addr_limit;
           if((rden_var = '1') and (rd_addr_var /= rdcount_var)) then
              DO_zd   <= do_in;
              DOP_zd  <= dop_in;
              rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
              if(rd_addr_var = 0) then 
                  rd_flag_var := NOT rd_flag_var;
              end if;
           end if;
           if (((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or 
              ((rden_var = '1') and (empty_ram(1) = '0'))) then
              do_in((D_W-1) downto 0) := MEM((((rdcount_var)*D_W)+(D_W -1)) downto ((rdcount_var)*D_W));
              dop_in((P_W-1) downto 0) := MEMP((((rdcount_var)*P_W)+(P_W -1)) downto ((rdcount_var)*P_W));
              rdcount_var := (rdcount_var + 1) mod addr_limit;

              if(rdcount_var = 0) then
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;
           end if;
-----------------  FP --------------------------------
         elsif(fwft = '1') then
           if((rden_var = '1') and (rd_addr_var /= rd_prefetch_var)) then
              rd_prefetch_var := (rd_prefetch_var + 1) mod addr_limit;
              if(rd_prefetch_var = 0) then 
                  rd_prefetch_flag_var := NOT rd_prefetch_flag_var;
              end if;
           end if;
           if((rd_prefetch_var = rd_addr_var) and (rd_addr_var /= rdcount_var)) then
             DO_zd   <= do_in;
             DOP_zd <= dop_in;
             rd_addr_var  := (rd_addr_var + 1) mod addr_limit;
             if(rd_addr_var = 0) then 
                rd_flag_var := NOT rd_flag_var;
             end if;
           end if;
           if(((rd_addr_var = rdcount_var) and (empty_ram(3) = '0')) or
              ((rden_var = '1')  and (empty_ram(1) = '0')) or 
              ((rden_var = '0')  and (empty_ram(1) = '0') and (rd_addr_var = rdcount_var))) then 
              do_in((D_W-1) downto 0) := MEM((((rdcount_var)*D_W)+(D_W -1)) downto ((rdcount_var)*D_W));
              dop_in((P_W-1) downto 0) := MEMP((((rdcount_var)*P_W)+(P_W -1)) downto ((rdcount_var)*P_W));
              rdcount_var := (rdcount_var + 1) mod addr_limit;
              if(rdcount_var = 0) then 
                 rdcount_flag_var := NOT rdcount_flag_var;
              end if;
           end if;
         end if;  ---  end if(fwft = '1')


         ALMOSTEMPTY_zd <= almostempty_int(3);
         if((((rdcount_var + ae_empty) >= wr_addr_var) and (rdcount_flag_var = wr_flag_var)) or (((rdcount_var + ae_empty) >= (wr_addr_var + addr_limit)) and (rdcount_flag_var /= wr_flag_var))) then    
            almostempty_int(3) := '1';
            almostempty_int(2) := '1';
            almostempty_int(1) := '1';
            almostempty_int(0) := '1';
         elsif(almostempty_int(2)  = '0') then
            almostempty_int(3) :=  almostempty_int(0);
            almostempty_int(0) :=  '0';
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
          
         if((rdcount_var = wr_addr_var) and (rdcount_flag_var = wr_flag_var)) then
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
         wr1_flag_var := wr_flag;

         if (not (rst_rdclk_flag or rst_wrclk_flag) = '1') then
           RDCOUNT_zd <= CONV_STD_LOGIC_VECTOR(rdcount_var, MAX_RDCOUNT);       
         end if;

         if((rden_var = '1') and (EMPTY_zd = '1')) then
             RDERR_zd <= '1';
--         elsif(rden_var = '0') then
         else
             RDERR_zd <= '0';
         end if; -- end ((rden_var = '1') and (empty_int /= '1'))

        update_from_read_prcs <= NOT update_from_read_prcs;

       end if; -- end (rising_edge(RDCLK_dly))

     end if; -- end (GSR_dly = 1)

     if(update_from_write_prcs'event) then
       wr_addr_var := wr_addr;
       wr_flag_var := wr_flag;
       if((((rdcount_var + ae_empty) <  wr_addr_var)  and (rdcount_flag_var = wr_flag_var)) or 
          (((rdcount_var + ae_empty) <  ( wr_addr_var + addr_limit)) and (rdcount_flag_var /= wr_flag_var))) then    
          if(wren_var = '1') then
             almostempty_int(2) := almostempty_int(1);
             almostempty_int(1) := '0';
          end if;
       else
           almostempty_int(2) := '1';
           almostempty_int(1) := '1';
       end if;
     end if;

     rd_addr <= rd_addr_var;
     rd_flag <= rd_flag_var;
     rdcount_flag <= rdcount_flag_var;


  end process prcs_read;

--####################################################################
--#####                         Write                            #####
--####################################################################
  prcs_write:process(WRCLK_dly, RST_dly, GSR_dly, update_from_read_prcs, rst_rdclk_flag, rst_wrclk_flag)
  variable first_time        : boolean    := true;
  variable wr_addr_var       : integer := 0;
  variable rd_addr_var       : integer := 0;
  variable rdcount_var       : integer := 0;
  variable wrcount_var       : integer := 0;

  variable rd_flag_var       : std_ulogic := '0';
  variable wr_flag_var       : std_ulogic := '0';

  variable rdcount_flag_var  : std_ulogic := '0';

  variable wr_offset_stdlogic : std_logic_vector (ALMOST_FULL_OFFSET'length-1 downto 0);
  variable wr_offset_int : integer := 0;

  variable almostfull_int : std_ulogic_vector(3 downto 0) := (others => '0');
  variable full_int       : std_ulogic_vector(3 downto 0) := (others => '0');

-- CR 195129  fix from verilog (may not be necessary for vhdl)
-- Added ren_var/wren_var to remember the old val of RDEN_dly/WREN_dly

  variable rden_var  : std_ulogic := '0';
  variable wren_var  : std_ulogic := '0';

  begin
    if ((GSR_dly = '1') or (RST_dly = '1'))then
        wr_addr_var := 0;
        wr_addr <=  0;
        wr_flag <= '0';

        wr_addr_var := 0;
        rd_addr_var := 0;
        rdcount_var := 0;
        wrcount_var := 0;

        rd_flag_var := '0';
        wr_flag_var := '0';

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
        end if;

    elsif((GSR_dly = '0') and (RST_dly = '0'))then
      rden_var := RDEN_dly;
      wren_var := WREN_dly;

      if(rising_edge(WRCLK_dly)) then

        wr_offset_stdlogic := To_StdLogicVector(ALMOST_FULL_OFFSET);
        wr_offset_int := SLV_TO_INT(wr_offset_stdlogic);

        rd_flag_var := rd_flag;
        wr_flag_var := wr_flag;

        rd_addr_var := rd_addr;
        wr_addr_var := wr_addr;

        rdcount_var := SLV_TO_INT(RDCOUNT_zd);
        rdcount_flag_var := rdcount_flag;

        if((wren_var = '1') and (full_int(1)= '0') and (RST_dly = '0'))then
          MEM((((wr_addr_var)*D_W) +(D_W-1)) downto ((wr_addr_var)*D_W)) <= DI_dly((D_W -1) downto 0);
          MEMP((((wr_addr_var)*P_W) +(P_W-1)) downto ((wr_addr_var)*P_W)) <= DIP_dly((P_W -1) downto 0);

          wr_addr_var := (wr_addr_var + 1) mod addr_limit;
         
          if(wr_addr_var = 0) then
            wr_flag_var := NOT wr_flag_var;
          end if;
        end if; -- if((wren_var = '1') and (FULL_zd = '0') ....      

        if((wren_var = '1') and (full_int(1) = '1')) then 
            WRERR_zd <= '1';
        else
            WRERR_zd <= '0';
        end if;

        ALMOSTFULL_zd <= almostfull_int(3);
        if((((rdcount_var + addr_limit) <= (wr_addr_var + wr_offset_int)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var <= (wr_addr_var + wr_offset_int)) and (rdcount_flag_var /= wr_flag_var))) then    
          almostfull_int(3) := '1';
          almostfull_int(2) := '1';
          almostfull_int(1) := '1';
          almostfull_int(0) := '1';
        elsif(almostfull_int(2)  = '0') then
          almostfull_int(3) := almostfull_int(0);
          almostfull_int(0) :=  '0';
        end if;
            

        FULL_zd <= full_int(1);
        if((rdcount_var = wr_addr_var) and (rdcount_flag_var /= wr_flag_var)) then
          full_int(1) := '1';
          full_int(0) := '1';
        else
          full_int(1) := full_int(0);
          full_int(0) := '0';
        end if;

        update_from_write_prcs <= NOT update_from_write_prcs;

        WRCOUNT_zd <= CONV_STD_LOGIC_VECTOR( wr_addr_var, MAX_WRCOUNT);

        wr_addr <= wr_addr_var;
        wr_flag <= wr_flag_var;

      end if; -- if(rising(WRCLK_dly))

    end if; -- if(GSR_dly = '1'))


    if(update_from_read_prcs'event) then
       rdcount_var := SLV_TO_INT(RDCOUNT_zd);
       rdcount_flag_var := rdcount_flag;
       if((((rdcount_var + addr_limit) > (wr_addr_var + wr_offset_int)) and (rdcount_flag_var = wr_flag_var)) or ((rdcount_var > (wr_addr_var + wr_offset_int)) and (rdcount_flag_var /= wr_flag_var))) then    
--         if(rden_var = '1') then
-- replaced the above line with line below
-- fp -- 09_10_03

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

  
  -- matching HW behavior to pull up the unused output bits
  prcs_x_1_output: process (WRCOUNT_zd, RDCOUNT_zd, DO_zd, DOP_zd)
  begin  -- process prcs_x_1_output

    case DATA_WIDTH is
      when 4  => 
                WRCOUNT_OUT_zd <= WRCOUNT_zd;
                RDCOUNT_OUT_zd <= RDCOUNT_zd;
                DO_OUT_zd(3 downto 0) <= DO_zd(3 downto 0);
      when 9  =>
                WRCOUNT_OUT_zd(10 downto 0) <= WRCOUNT_zd(10 downto 0);
                RDCOUNT_OUT_zd(10 downto 0) <= RDCOUNT_zd(10 downto 0);
                DO_OUT_zd(7 downto 0) <= DO_zd(7 downto 0);
                DOP_OUT_zd(0 downto 0) <= DOP_zd(0 downto 0);
      when 18 =>
                WRCOUNT_OUT_zd(9 downto 0) <= WRCOUNT_zd(9 downto 0);
                RDCOUNT_OUT_zd(9 downto 0) <= RDCOUNT_zd(9 downto 0);
                DO_OUT_zd(15 downto 0) <= DO_zd(15 downto 0);
                DOP_OUT_zd(1 downto 0) <= DOP_zd(1 downto 0);
      when 36 => 
                WRCOUNT_OUT_zd(8 downto 0) <= WRCOUNT_zd(8 downto 0);
                RDCOUNT_OUT_zd(8 downto 0) <= RDCOUNT_zd(8 downto 0);
                DO_OUT_zd(31 downto 0) <= DO_zd(31 downto 0);
                DOP_OUT_zd(3 downto 0) <= DOP_zd(3 downto 0);
      when others =>
                WRCOUNT_OUT_zd <= WRCOUNT_zd;
                RDCOUNT_OUT_zd <= RDCOUNT_zd;
                DO_OUT_zd <= DO_zd;
    end case;
  end process prcs_x_1_output;

  
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(ALMOSTEMPTY_zd, ALMOSTFULL_zd, DO_OUT_zd, DOP_OUT_zd, 
                      EMPTY_zd, FULL_zd, RDCOUNT_OUT_zd, RDERR_zd, 
                      WRCOUNT_OUT_zd, WRERR_zd)
  begin
      ALMOSTEMPTY <= ALMOSTEMPTY_zd	after SYNC_PATH_DELAY;
      ALMOSTFULL  <= ALMOSTFULL_zd	after SYNC_PATH_DELAY;
      DO          <= DO_OUT_zd		after SYNC_PATH_DELAY;
      DOP         <= DOP_OUT_zd		after SYNC_PATH_DELAY;
      EMPTY       <= EMPTY_zd		after SYNC_PATH_DELAY;
      FULL        <= FULL_zd		after SYNC_PATH_DELAY;
      RDCOUNT     <= RDCOUNT_OUT_zd 	after SYNC_PATH_DELAY;
      RDERR       <= RDERR_zd		after SYNC_PATH_DELAY;
      WRCOUNT     <= WRCOUNT_OUT_zd	after SYNC_PATH_DELAY;
      WRERR       <= WRERR_zd		after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end FIFO16_V;

