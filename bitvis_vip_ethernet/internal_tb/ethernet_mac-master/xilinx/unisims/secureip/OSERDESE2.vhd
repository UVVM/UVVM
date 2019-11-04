-------------------------------------------------------------------------------
-- Copyright (c) 1995/2010 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Source Synchronous Output Serializer Virtex7
-- /___/   /\     Filename : OSERDESE2.vhd
-- \   \  /  \    Timestamp : Fri Jan 29 14:59:32 PST 2010
--  \___\/\___\
--
-- Revision:
--    01/29/10 - Initial version.
-- End Revision

----- CELL OSERDESE2 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all; 

library secureip; 
use secureip.all; 
use unisim.vpkg.all;

  entity OSERDESE2 is
    generic (
      DATA_RATE_OQ : string := "DDR";
      DATA_RATE_TQ : string := "DDR";
      DATA_WIDTH : integer := 4;
      INIT_OQ : bit := '0';
      INIT_TQ : bit := '0';
      SERDES_MODE : string := "MASTER";
      SRVAL_OQ : bit := '0';
      SRVAL_TQ : bit := '0';
      TBYTE_CTL : string := "FALSE";
      TBYTE_SRC : string := "FALSE";
      TRISTATE_WIDTH : integer := 4
    );

    port (
      OFB                  : out std_ulogic;
      OQ                   : out std_ulogic;
      SHIFTOUT1            : out std_ulogic;
      SHIFTOUT2            : out std_ulogic;
      TBYTEOUT             : out std_ulogic;
      TFB                  : out std_ulogic;
      TQ                   : out std_ulogic;
      CLK                  : in std_ulogic;
      CLKDIV               : in std_ulogic;
      D1                   : in std_ulogic;
      D2                   : in std_ulogic;
      D3                   : in std_ulogic;
      D4                   : in std_ulogic;
      D5                   : in std_ulogic;
      D6                   : in std_ulogic;
      D7                   : in std_ulogic;
      D8                   : in std_ulogic;
      OCE                  : in std_ulogic;
      RST                  : in std_ulogic;
      SHIFTIN1             : in std_ulogic;
      SHIFTIN2             : in std_ulogic;
      T1                   : in std_ulogic;
      T2                   : in std_ulogic;
      T3                   : in std_ulogic;
      T4                   : in std_ulogic;
      TBYTEIN              : in std_ulogic;
      TCE                  : in std_ulogic      
    );
  end OSERDESE2;

  architecture OSERDESE2_V of OSERDESE2 is
    component OSERDESE2_WRAP
      generic (
        DATA_RATE_OQ : string;
        DATA_RATE_TQ : string;
        DATA_WIDTH : integer;
        INIT_OQ : string;
        INIT_TQ : string;
        SERDES_MODE : string;
        SRVAL_OQ : string;
        SRVAL_TQ : string;
        TBYTE_CTL : string;
        TBYTE_SRC : string;
        TRISTATE_WIDTH : integer        
      );
      
      port (
        OFB                  : out std_ulogic;
        OQ                   : out std_ulogic;
        SHIFTOUT1            : out std_ulogic;
        SHIFTOUT2            : out std_ulogic;
        TBYTEOUT             : out std_ulogic;
        TFB                  : out std_ulogic;
        TQ                   : out std_ulogic;
        CLK                  : in std_ulogic;
        CLKDIV               : in std_ulogic;
        D1                   : in std_ulogic;
        D2                   : in std_ulogic;
        D3                   : in std_ulogic;
        D4                   : in std_ulogic;
        D5                   : in std_ulogic;
        D6                   : in std_ulogic;
        D7                   : in std_ulogic;
        D8                   : in std_ulogic;
        OCE                  : in std_ulogic;
        RST                  : in std_ulogic;
        SHIFTIN1             : in std_ulogic;
        SHIFTIN2             : in std_ulogic;
        T1                   : in std_ulogic;
        T2                   : in std_ulogic;
        T3                   : in std_ulogic;
        T4                   : in std_ulogic;
        TBYTEIN              : in std_ulogic;
        TCE                  : in std_ulogic        
      );
    end component;
    
    constant IN_DELAY : time := 0 ps;
    constant OUT_DELAY : time := 0 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    function SUL_TO_STR (sul : std_ulogic)
    return string is
    begin
      if sul = '0' then
        return "0";
      else
        return "1";
      end if;
    end SUL_TO_STR;

    function boolean_to_string(bool: boolean)
    return string is
    begin
      if bool then
        return "TRUE";
      else
        return "FALSE";
      end if;
    end boolean_to_string;

    function getstrlength(in_vec : std_logic_vector)
    return integer is
      variable string_length : integer;
    begin
      if ((in_vec'length mod 4) = 0) then
        string_length := in_vec'length/4;
      elsif ((in_vec'length mod 4) > 0) then
        string_length := in_vec'length/4 + 1;
      end if;
      return string_length;
    end getstrlength;

    -- Convert bit_vector to std_logic_vector
    constant INIT_OQ_BINARY : std_ulogic := To_StduLogic(INIT_OQ);
    constant INIT_TQ_BINARY : std_ulogic := To_StduLogic(INIT_TQ);
    constant SRVAL_OQ_BINARY : std_ulogic := To_StduLogic(SRVAL_OQ);
    constant SRVAL_TQ_BINARY : std_ulogic := To_StduLogic(SRVAL_TQ);
    
    -- Convert std_logic_vector to string
    constant INIT_OQ_STRING : string := SUL_TO_STR(INIT_OQ_BINARY);
    constant INIT_TQ_STRING : string := SUL_TO_STR(INIT_TQ_BINARY);
    constant SRVAL_OQ_STRING : string := SUL_TO_STR(SRVAL_OQ_BINARY);
    constant SRVAL_TQ_STRING : string := SUL_TO_STR(SRVAL_TQ_BINARY);
    
    signal DATA_RATE_OQ_BINARY : std_ulogic;
    signal DATA_RATE_TQ_BINARY : std_logic_vector(5 downto 0);
    signal DATA_WIDTH_BINARY : std_ulogic;
    signal SERDES_MODE_BINARY : std_ulogic;
    signal TBYTE_CTL_BINARY : std_ulogic;
    signal TBYTE_SRC_BINARY : std_ulogic;
    signal TRISTATE_WIDTH_BINARY : std_ulogic;
    
    signal OFB_out : std_ulogic;
    signal OQ_out : std_ulogic;
    signal SHIFTOUT1_out : std_ulogic;
    signal SHIFTOUT2_out : std_ulogic;
    signal TBYTEOUT_out : std_ulogic;
    signal TFB_out : std_ulogic;
    signal TQ_out : std_ulogic;
    
    signal OFB_outdelay : std_ulogic;
    signal OQ_outdelay : std_ulogic;
    signal SHIFTOUT1_outdelay : std_ulogic;
    signal SHIFTOUT2_outdelay : std_ulogic;
    signal TBYTEOUT_outdelay : std_ulogic;
    signal TFB_outdelay : std_ulogic;
    signal TQ_outdelay : std_ulogic;
    
    signal CLKDIV_ipd : std_ulogic;
    signal CLK_ipd : std_ulogic;
    signal D1_ipd : std_ulogic;
    signal D2_ipd : std_ulogic;
    signal D3_ipd : std_ulogic;
    signal D4_ipd : std_ulogic;
    signal D5_ipd : std_ulogic;
    signal D6_ipd : std_ulogic;
    signal D7_ipd : std_ulogic;
    signal D8_ipd : std_ulogic;
    signal OCE_ipd : std_ulogic;
    signal RST_ipd : std_ulogic;
    signal SHIFTIN1_ipd : std_ulogic;
    signal SHIFTIN2_ipd : std_ulogic;
    signal T1_ipd : std_ulogic;
    signal T2_ipd : std_ulogic;
    signal T3_ipd : std_ulogic;
    signal T4_ipd : std_ulogic;
    signal TBYTEIN_ipd : std_ulogic;
    signal TCE_ipd : std_ulogic;
    
    signal CLKDIV_indelay : std_ulogic;
    signal CLK_indelay : std_ulogic;
    signal D1_indelay : std_ulogic;
    signal D2_indelay : std_ulogic;
    signal D3_indelay : std_ulogic;
    signal D4_indelay : std_ulogic;
    signal D5_indelay : std_ulogic;
    signal D6_indelay : std_ulogic;
    signal D7_indelay : std_ulogic;
    signal D8_indelay : std_ulogic;
    signal OCE_indelay : std_ulogic;
    signal RST_indelay : std_ulogic;
    signal SHIFTIN1_indelay : std_ulogic;
    signal SHIFTIN2_indelay : std_ulogic;
    signal T1_indelay : std_ulogic;
    signal T2_indelay : std_ulogic;
    signal T3_indelay : std_ulogic;
    signal T4_indelay : std_ulogic;
    signal TBYTEIN_indelay : std_ulogic;
    signal TCE_indelay : std_ulogic;
    
    begin
    OFB_out <= OFB_outdelay after OUT_DELAY;
    OQ_out <= OQ_outdelay after OUT_DELAY;
    SHIFTOUT1_out <= SHIFTOUT1_outdelay after OUT_DELAY;
    SHIFTOUT2_out <= SHIFTOUT2_outdelay after OUT_DELAY;
    TBYTEOUT_out <= TBYTEOUT_outdelay after OUT_DELAY;
    TFB_out <= TFB_outdelay after OUT_DELAY;
    TQ_out <= TQ_outdelay after OUT_DELAY;
    
    CLKDIV_ipd <= CLKDIV;
    CLK_ipd <= CLK;
    
    D1_ipd <= D1;
    D2_ipd <= D2;
    D3_ipd <= D3;
    D4_ipd <= D4;
    D5_ipd <= D5;
    D6_ipd <= D6;
    D7_ipd <= D7;
    D8_ipd <= D8;
    OCE_ipd <= OCE;
    RST_ipd <= RST;
    SHIFTIN1_ipd <= SHIFTIN1;
    SHIFTIN2_ipd <= SHIFTIN2;
    T1_ipd <= T1;
    T2_ipd <= T2;
    T3_ipd <= T3;
    T4_ipd <= T4;
    TBYTEIN_ipd <= TBYTEIN;
    TCE_ipd <= TCE;
    
    CLKDIV_indelay <= CLKDIV_ipd after INCLK_DELAY;
    CLK_indelay <= CLK_ipd after INCLK_DELAY;
    
    D1_indelay <= D1_ipd after IN_DELAY;
    D2_indelay <= D2_ipd after IN_DELAY;
    D3_indelay <= D3_ipd after IN_DELAY;
    D4_indelay <= D4_ipd after IN_DELAY;
    D5_indelay <= D5_ipd after IN_DELAY;
    D6_indelay <= D6_ipd after IN_DELAY;
    D7_indelay <= D7_ipd after IN_DELAY;
    D8_indelay <= D8_ipd after IN_DELAY;
    OCE_indelay <= OCE_ipd after IN_DELAY;
    RST_indelay <= RST_ipd after IN_DELAY;
    SHIFTIN1_indelay <= SHIFTIN1_ipd after IN_DELAY;
    SHIFTIN2_indelay <= SHIFTIN2_ipd after IN_DELAY;
    T1_indelay <= T1_ipd after IN_DELAY;
    T2_indelay <= T2_ipd after IN_DELAY;
    T3_indelay <= T3_ipd after IN_DELAY;
    T4_indelay <= T4_ipd after IN_DELAY;
    TBYTEIN_indelay <= TBYTEIN_ipd after IN_DELAY;
    TCE_indelay <= TCE_ipd after IN_DELAY;
    
    
--####################################################################
--#####                     Initialize                           #####
--####################################################################

   prcs_init:process
   begin
-----------------------------------------------------------------
--------------------- DATA_RATE_OQ validity check ------------------
-----------------------------------------------------------------
      if((DATA_RATE_OQ /= "DDR") and (DATA_RATE_OQ /= "ddr") and
         (DATA_RATE_OQ /= "SDR") and (DATA_RATE_OQ /= "sdr")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DATA_RATE_OQ ",
             EntityName => "/OSERDESE2",
             GenericValue => DATA_RATE_OQ,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " DDR or SDR. ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
--------------------- DATA_RATE_TQ validity check ------------------
-----------------------------------------------------------------
      if((DATA_RATE_TQ /= "SDR") and (DATA_RATE_TQ /= "sdr") and
         (DATA_RATE_TQ /= "DDR") and (DATA_RATE_TQ /= "ddr") and 
         (DATA_RATE_TQ /= "BUF") and (DATA_RATE_TQ /= "buf")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DATA_RATE_TQ ",
             EntityName => "/OSERDESE2",
             GenericValue => DATA_RATE_TQ,
             Unit => "",
             ExpectedValueMsg => " The legal values for this attribute are ",
             ExpectedGenericValue => " SDR, DDR or BUF. ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
-------------------- DATA_WIDTH validity check ------------------
-----------------------------------------------------------------
      if((DATA_WIDTH /= 2) and (DATA_WIDTH /= 3) and  (DATA_WIDTH /= 4) and
         (DATA_WIDTH /= 5) and (DATA_WIDTH /= 6) and  (DATA_WIDTH /= 7) and
         (DATA_WIDTH /= 8) and (DATA_WIDTH /= 10) and (DATA_WIDTH /= 14)) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DATA_WIDTH ",
             EntityName => "/OSERDESE2",
             GenericValue => DATA_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 2, 3, 4, 5, 6, 7, 8, 10 or 14 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
----------------- SERDES_MODE validity check --------------------
-----------------------------------------------------------------
      if((SERDES_MODE /= "MASTER") and (SERDES_MODE /= "master") and
         (SERDES_MODE /= "SLAVE")  and (SERDES_MODE /= "slave")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => "SERDES_MODE ",
             EntityName => "/OSERDESE2",
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => FAILURE
         );
      end if;

-----------------------------------------------------------------
-----------------   TBYTE_CTL validity check --------------------
-----------------------------------------------------------------
      if((TBYTE_CTL /= "TRUE")  and (TBYTE_CTL /= "true") and
         (TBYTE_CTL /= "FALSE") and (TBYTE_CTL /= "false")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => "SERDES_MODE ",
             EntityName => "/OSERDESE2",
             GenericValue => TBYTE_CTL,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE.",
             TailMsg => "",
             MsgSeverity => FAILURE
         );
      end if;

-----------------------------------------------------------------
-----------------   TBYTE_SRC validity check --------------------
-----------------------------------------------------------------
      if((TBYTE_SRC /= "TRUE")  and (TBYTE_SRC /= "true") and
         (TBYTE_SRC /= "FALSE") and (TBYTE_SRC /= "false")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => "SERDES_MODE ",
             EntityName => "/OSERDESE2",
             GenericValue => TBYTE_SRC,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE.",
             TailMsg => "",
             MsgSeverity => FAILURE
         );
      end if;


-----------------------------------------------------------------
---------------- TRISTATE_WIDTH validity check ------------------
-----------------------------------------------------------------
      if((TRISTATE_WIDTH /= 1) and (TRISTATE_WIDTH /= 4)) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " TRISTATE_WIDTH ",
             EntityName => "/OSERDESE2",
             GenericValue => TRISTATE_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 1 or 4 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

     wait;
   end process prcs_init;


    OSERDESE2_WRAP_INST : OSERDESE2_WRAP
      generic map (
        DATA_RATE_OQ         => DATA_RATE_OQ,
        DATA_RATE_TQ         => DATA_RATE_TQ,
        DATA_WIDTH           => DATA_WIDTH,
        INIT_OQ              => INIT_OQ_STRING,
        INIT_TQ              => INIT_TQ_STRING,
        SERDES_MODE          => SERDES_MODE,
        SRVAL_OQ             => SRVAL_OQ_STRING,
        SRVAL_TQ             => SRVAL_TQ_STRING,
        TBYTE_CTL            => TBYTE_CTL,
        TBYTE_SRC            => TBYTE_SRC,
        TRISTATE_WIDTH       => TRISTATE_WIDTH
      )
      
      port map (
        OFB                  => OFB_outdelay,
        OQ                   => OQ_outdelay,
        SHIFTOUT1            => SHIFTOUT1_outdelay,
        SHIFTOUT2            => SHIFTOUT2_outdelay,
        TBYTEOUT             => TBYTEOUT_outdelay,
        TFB                  => TFB_outdelay,
        TQ                   => TQ_outdelay,
        CLK                  => CLK_indelay,
        CLKDIV               => CLKDIV_indelay,
        D1                   => D1_indelay,
        D2                   => D2_indelay,
        D3                   => D3_indelay,
        D4                   => D4_indelay,
        D5                   => D5_indelay,
        D6                   => D6_indelay,
        D7                   => D7_indelay,
        D8                   => D8_indelay,
        OCE                  => OCE_indelay,
        RST                  => RST_indelay,
        SHIFTIN1             => SHIFTIN1_indelay,
        SHIFTIN2             => SHIFTIN2_indelay,
        T1                   => T1_indelay,
        T2                   => T2_indelay,
        T3                   => T3_indelay,
        T4                   => T4_indelay,
        TBYTEIN              => TBYTEIN_indelay,
        TCE                  => TCE_indelay        
      );
    
    INIPROC : process
    begin
    -- case DATA_RATE_TQ is
      if((DATA_RATE_TQ = "DDR") or (DATA_RATE_TQ = "ddr")) then
        DATA_RATE_TQ_BINARY <= "101000";
      elsif((DATA_RATE_TQ = "BUF") or (DATA_RATE_TQ= "buf")) then
        DATA_RATE_TQ_BINARY <= "000100";
      elsif((DATA_RATE_TQ = "SDR") or (DATA_RATE_TQ= "sdr")) then
        DATA_RATE_TQ_BINARY <= "110000";
      else
        assert FALSE report "Error : DATA_RATE_TQ = is not DDR, BUF, SDR." severity error;
      end if;
    -- end case;
    -- case SERDES_MODE is
      if((SERDES_MODE = "MASTER") or (SERDES_MODE = "master")) then
        SERDES_MODE_BINARY <= '0';
      elsif((SERDES_MODE = "SLAVE") or (SERDES_MODE= "slave")) then
        SERDES_MODE_BINARY <= '1';
      else
        assert FALSE report "Error : SERDES_MODE = is not MASTER, SLAVE." severity error;
      end if;
    -- end case;
    -- case TBYTE_CTL is
      if((TBYTE_CTL = "FALSE") or (TBYTE_CTL = "false")) then
        TBYTE_CTL_BINARY <= '0';
      elsif((TBYTE_CTL = "TRUE") or (TBYTE_CTL= "true")) then
        TBYTE_CTL_BINARY <= '1';
      else
        assert FALSE report "Error : TBYTE_CTL = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case TBYTE_SRC is
      if((TBYTE_SRC = "FALSE") or (TBYTE_SRC = "false")) then
        TBYTE_SRC_BINARY <= '0';
      elsif((TBYTE_SRC = "TRUE") or (TBYTE_SRC= "true")) then
        TBYTE_SRC_BINARY <= '1';
      else
        assert FALSE report "Error : TBYTE_SRC = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    case TRISTATE_WIDTH is
      when  4   =>  TRISTATE_WIDTH_BINARY <= '1';
      when  1   =>  TRISTATE_WIDTH_BINARY <= '0';
      when others  =>  assert FALSE report "Error : TRISTATE_WIDTH is not in range 1 .. 4." severity error;
    end case;
    wait;
    end process INIPROC;
    OFB <= OFB_out;
    OQ <= OQ_out;
    SHIFTOUT1 <= SHIFTOUT1_out;
    SHIFTOUT2 <= SHIFTOUT2_out;
    TBYTEOUT <= TBYTEOUT_out;
    TFB <= TFB_out;
    TQ <= TQ_out;
  end OSERDESE2_V;
