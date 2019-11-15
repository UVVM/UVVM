-------------------------------------------------------------------------------
-- Copyright (c) 1995/2010 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Source Synchronous Input Deserializer for Virtex7
-- /___/   /\     Filename : ISERDESE2.vhd
-- \   \  /  \    Timestamp : Tue Jan 19 16:29:39 PST 2010
--  \___\/\___\
--
-- Revision:
--    01/19/10 - Initial version.
--    08/31/10 - CR 574021 -- Added Data Muxing.
--    10/28/10 - CR 580517 -- Data Muxing varibles must be initialized for certain simulators.
--    11/08/11 - CR 633088 -- vhdl O output fix
-- End Revision

----- CELL ISERDESE2 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VCOMPONENTS.all; 

library secureip; 
use secureip.all; 
use unisim.vpkg.all;

  entity ISERDESE2 is
    generic (
      DATA_RATE : string := "DDR";
      DATA_WIDTH : integer := 4;
      DYN_CLKDIV_INV_EN : string := "FALSE";
      DYN_CLK_INV_EN : string := "FALSE";
      INIT_Q1 : bit := '0';
      INIT_Q2 : bit := '0';
      INIT_Q3 : bit := '0';
      INIT_Q4 : bit := '0';
      INTERFACE_TYPE : string := "MEMORY";
      IOBDELAY : string := "NONE";
      NUM_CE : integer := 2;
      OFB_USED : string := "FALSE";
      SERDES_MODE : string := "MASTER";
      SRVAL_Q1 : bit := '0';
      SRVAL_Q2 : bit := '0';
      SRVAL_Q3 : bit := '0';
      SRVAL_Q4 : bit := '0'
    );

    port (
      O                    : out std_ulogic;
      Q1                   : out std_ulogic;
      Q2                   : out std_ulogic;
      Q3                   : out std_ulogic;
      Q4                   : out std_ulogic;
      Q5                   : out std_ulogic;
      Q6                   : out std_ulogic;
      Q7                   : out std_ulogic;
      Q8                   : out std_ulogic;
      SHIFTOUT1            : out std_ulogic;
      SHIFTOUT2            : out std_ulogic;
      BITSLIP              : in std_ulogic;
      CE1                  : in std_ulogic;
      CE2                  : in std_ulogic;
      CLK                  : in std_ulogic;
      CLKB                 : in std_ulogic;
      CLKDIV               : in std_ulogic;
      CLKDIVP              : in std_ulogic;
      D                    : in std_ulogic;
      DDLY                 : in std_ulogic;
      DYNCLKDIVSEL         : in std_ulogic;
      DYNCLKSEL            : in std_ulogic;
      OCLK                 : in std_ulogic;
      OCLKB                : in std_ulogic;
      OFB                  : in std_ulogic;
      RST                  : in std_ulogic;
      SHIFTIN1             : in std_ulogic;
      SHIFTIN2             : in std_ulogic      
    );
  end ISERDESE2;

  architecture ISERDESE2_V of ISERDESE2 is
    component ISERDESE2_WRAP
      generic (
        DATA_RATE : string;
        DATA_WIDTH : integer;
        DYN_CLKDIV_INV_EN : string;
        DYN_CLK_INV_EN : string;
        INIT_Q1 : string;
        INIT_Q2 : string;
        INIT_Q3 : string;
        INIT_Q4 : string;
        INTERFACE_TYPE : string;
        IOBDELAY : string;
        NUM_CE : integer;
        OFB_USED : string;
        SERDES_MODE : string;
        SRVAL_Q1 : string;
        SRVAL_Q2 : string;
        SRVAL_Q3 : string;
        SRVAL_Q4 : string        
      );
      
      port (
        O                    : out std_ulogic;
        Q1                   : out std_ulogic;
        Q2                   : out std_ulogic;
        Q3                   : out std_ulogic;
        Q4                   : out std_ulogic;
        Q5                   : out std_ulogic;
        Q6                   : out std_ulogic;
        Q7                   : out std_ulogic;
        Q8                   : out std_ulogic;
        SHIFTOUT1            : out std_ulogic;
        SHIFTOUT2            : out std_ulogic;
        BITSLIP              : in std_ulogic;
        CE1                  : in std_ulogic;
        CE2                  : in std_ulogic;
        CLK                  : in std_ulogic;
        CLKB                 : in std_ulogic;
        CLKDIV               : in std_ulogic;
        CLKDIVP              : in std_ulogic;
        D                    : in std_ulogic;
        DDLY                 : in std_ulogic;
        DYNCLKDIVSEL         : in std_ulogic;
        DYNCLKSEL            : in std_ulogic;
        OCLK                 : in std_ulogic;
        OCLKB                : in std_ulogic;
        OFB                  : in std_ulogic;
        RST                  : in std_ulogic;
        SHIFTIN1             : in std_ulogic;
        SHIFTIN2             : in std_ulogic        
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
    constant INIT_Q1_BINARY : std_ulogic := To_StduLogic(INIT_Q1);
    constant INIT_Q2_BINARY : std_ulogic := To_StduLogic(INIT_Q2);
    constant INIT_Q3_BINARY : std_ulogic := To_StduLogic(INIT_Q3);
    constant INIT_Q4_BINARY : std_ulogic := To_StduLogic(INIT_Q4);
    constant SRVAL_Q1_BINARY : std_ulogic := To_StduLogic(SRVAL_Q1);
    constant SRVAL_Q2_BINARY : std_ulogic := To_StduLogic(SRVAL_Q2);
    constant SRVAL_Q3_BINARY : std_ulogic := To_StduLogic(SRVAL_Q3);
    constant SRVAL_Q4_BINARY : std_ulogic := To_StduLogic(SRVAL_Q4);
    
    -- Convert std_logic_vector to string
    constant INIT_Q1_STRING : string := SUL_TO_STR(INIT_Q1_BINARY);
    constant INIT_Q2_STRING : string := SUL_TO_STR(INIT_Q2_BINARY);
    constant INIT_Q3_STRING : string := SUL_TO_STR(INIT_Q3_BINARY);
    constant INIT_Q4_STRING : string := SUL_TO_STR(INIT_Q4_BINARY);
    constant SRVAL_Q1_STRING : string := SUL_TO_STR(SRVAL_Q1_BINARY);
    constant SRVAL_Q2_STRING : string := SUL_TO_STR(SRVAL_Q2_BINARY);
    constant SRVAL_Q3_STRING : string := SUL_TO_STR(SRVAL_Q3_BINARY);
    constant SRVAL_Q4_STRING : string := SUL_TO_STR(SRVAL_Q4_BINARY);
    
    signal DATA_RATE_BINARY : std_ulogic;
    signal DATA_WIDTH_BINARY : std_logic_vector(3 downto 0);
    signal DYN_CLKDIV_INV_EN_BINARY : std_ulogic;
    signal DYN_CLK_INV_EN_BINARY : std_ulogic;
    signal INTERFACE_TYPE_BINARY : std_ulogic;
    signal IOBDELAY_BINARY : std_ulogic;
    signal NUM_CE_BINARY : std_ulogic;
    signal OFB_USED_BINARY : std_logic_vector(1 downto 0);
    signal SERDES_MODE_BINARY : std_ulogic;
    
    signal O_out : std_ulogic;
    signal Q1_out : std_ulogic;
    signal Q2_out : std_ulogic;
    signal Q3_out : std_ulogic;
    signal Q4_out : std_ulogic;
    signal Q5_out : std_ulogic;
    signal Q6_out : std_ulogic;
    signal Q7_out : std_ulogic;
    signal Q8_out : std_ulogic;
    signal SHIFTOUT1_out : std_ulogic;
    signal SHIFTOUT2_out : std_ulogic;
    
    signal O_outdelay : std_ulogic;
    signal Q1_outdelay : std_ulogic;
    signal Q2_outdelay : std_ulogic;
    signal Q3_outdelay : std_ulogic;
    signal Q4_outdelay : std_ulogic;
    signal Q5_outdelay : std_ulogic;
    signal Q6_outdelay : std_ulogic;
    signal Q7_outdelay : std_ulogic;
    signal Q8_outdelay : std_ulogic;
    signal SHIFTOUT1_outdelay : std_ulogic;
    signal SHIFTOUT2_outdelay : std_ulogic;
    
    signal BITSLIP_ipd : std_ulogic;
    signal CE1_ipd : std_ulogic;
    signal CE2_ipd : std_ulogic;
    signal CLKB_ipd : std_ulogic;
    signal CLKDIVP_ipd : std_ulogic;
    signal CLKDIV_ipd : std_ulogic;
    signal CLK_ipd : std_ulogic;
    signal DDLY_ipd : std_ulogic;
    signal DYNCLKDIVSEL_ipd : std_ulogic;
    signal DYNCLKSEL_ipd : std_ulogic;
    signal D_ipd : std_ulogic;
    signal OCLKB_ipd : std_ulogic;
    signal OCLK_ipd : std_ulogic;
    signal OFB_ipd : std_ulogic;
    signal RST_ipd : std_ulogic;
    signal SHIFTIN1_ipd : std_ulogic;
    signal SHIFTIN2_ipd : std_ulogic;
    
    signal BITSLIP_indelay : std_ulogic;
    signal CE1_indelay : std_ulogic;
    signal CE2_indelay : std_ulogic;
    signal CLKB_indelay : std_ulogic;
    signal CLKDIVP_indelay : std_ulogic;
    signal CLKDIV_indelay : std_ulogic;
    signal CLK_indelay : std_ulogic;
    signal DDLY_indelay : std_ulogic;
    signal DYNCLKDIVSEL_indelay : std_ulogic;
    signal DYNCLKSEL_indelay : std_ulogic;
    signal D_indelay : std_ulogic;
    signal OCLKB_indelay : std_ulogic;
    signal OCLK_indelay : std_ulogic;
    signal OFB_indelay : std_ulogic;
    signal RST_indelay : std_ulogic;
    signal SHIFTIN1_indelay : std_ulogic;
    signal SHIFTIN2_indelay : std_ulogic;

    signal pre_fdbk_O_zd    : std_ulogic := '0';
    signal pre_fdbk_datain  : std_ulogic := '0';
    signal datain           : std_ulogic := '0';
    signal O_zd             : std_ulogic;

    
    begin
    O_out <= O_zd after OUT_DELAY;
    Q1_out <= Q1_outdelay after OUT_DELAY;
    Q2_out <= Q2_outdelay after OUT_DELAY;
    Q3_out <= Q3_outdelay after OUT_DELAY;
    Q4_out <= Q4_outdelay after OUT_DELAY;
    Q5_out <= Q5_outdelay after OUT_DELAY;
    Q6_out <= Q6_outdelay after OUT_DELAY;
    Q7_out <= Q7_outdelay after OUT_DELAY;
    Q8_out <= Q8_outdelay after OUT_DELAY;
    SHIFTOUT1_out <= SHIFTOUT1_outdelay after OUT_DELAY;
    SHIFTOUT2_out <= SHIFTOUT2_outdelay after OUT_DELAY;
    
    CLKB_ipd <= CLKB;
    CLKDIVP_ipd <= CLKDIVP;
    CLKDIV_ipd <= CLKDIV;
    CLK_ipd <= CLK;
    OCLKB_ipd <= OCLKB;
    OCLK_ipd <= OCLK;
    
    BITSLIP_ipd <= BITSLIP;
    CE1_ipd <= CE1;
    CE2_ipd <= CE2;
    DDLY_ipd <= DDLY;
    DYNCLKDIVSEL_ipd <= DYNCLKDIVSEL;
    DYNCLKSEL_ipd <= DYNCLKSEL;
    D_ipd <= D;
    OFB_ipd <= OFB;
    RST_ipd <= RST;
    SHIFTIN1_ipd <= SHIFTIN1;
    SHIFTIN2_ipd <= SHIFTIN2;
    
    CLKB_indelay <= CLKB_ipd after INCLK_DELAY;
    CLKDIVP_indelay <= CLKDIVP_ipd after INCLK_DELAY;
    CLKDIV_indelay <= CLKDIV_ipd after INCLK_DELAY;
    CLK_indelay <= CLK_ipd after INCLK_DELAY;
    OCLKB_indelay <= OCLKB_ipd after INCLK_DELAY;
    OCLK_indelay <= OCLK_ipd after INCLK_DELAY;
    
    BITSLIP_indelay <= BITSLIP_ipd after IN_DELAY;
    CE1_indelay <= CE1_ipd after IN_DELAY;
    CE2_indelay <= CE2_ipd after IN_DELAY;
    DDLY_indelay <= DDLY_ipd after IN_DELAY;
    DYNCLKDIVSEL_indelay <= DYNCLKDIVSEL_ipd after IN_DELAY;
    DYNCLKSEL_indelay <= DYNCLKSEL_ipd after IN_DELAY;
    D_indelay <= D_ipd after IN_DELAY;
    OFB_indelay <= OFB_ipd after IN_DELAY;
    RST_indelay <= RST_ipd after IN_DELAY;
    SHIFTIN1_indelay <= SHIFTIN1_ipd after IN_DELAY;
    SHIFTIN2_indelay <= SHIFTIN2_ipd after IN_DELAY;

    
--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
-----------------------------------------------------------------
--------------------- DATA_RATE validity check ------------------
-----------------------------------------------------------------
      if((DATA_RATE /= "DDR") and (DATA_RATE /= "SDR")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_RATE ",
             EntityName => "/ISERDESE2",
             GenericValue => DATA_RATE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " DDR or SDR. ",
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
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_WIDTH ",
             EntityName => "/ISERDESE2",
             GenericValue => DATA_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 2, 3, 4, 5, 6, 7, 8, 10 or 14",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
--------------- DYN_CLKDIV_INV_EN validity check -------------------
-----------------------------------------------------------------
      if((DYN_CLKDIV_INV_EN /= "TRUE") and (DYN_CLKDIV_INV_EN /= "true") and 
         (DYN_CLKDIV_INV_EN /= "FALSE") and (DYN_CLKDIV_INV_EN /= "false")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DYN_CLKDIV_INV_EN ",
             EntityName => "/ISERDESE2",
             GenericValue => DYN_CLKDIV_INV_EN,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
--------------- DYN_CLK_INV_EN validity check -------------------
-----------------------------------------------------------------
      if((DYN_CLK_INV_EN /= "TRUE") and (DYN_CLK_INV_EN /= "true") and 
         (DYN_CLK_INV_EN /= "FALSE") and (DYN_CLK_INV_EN /= "false"))then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DYN_CLK_INV_EN ",
             EntityName => "/ISERDESE2",
             GenericValue => DYN_CLK_INV_EN,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

-----------------------------------------------------------------
------------------- INTERFACE_TYPE validity check ---------------
-----------------------------------------------------------------
      if((INTERFACE_TYPE /= "MEMORY") and (INTERFACE_TYPE /= "memory") and
         (INTERFACE_TYPE /= "NETWORKING") and (INTERFACE_TYPE /= "networking") and 
         (INTERFACE_TYPE /= "MEMORY_QDR") and  (INTERFACE_TYPE /= "memory_qdr") and
         (INTERFACE_TYPE /= "MEMORY_DDR3") and  (INTERFACE_TYPE /= "memory_ddr3") and
         (INTERFACE_TYPE /= "OVERSAMPLE") and  (INTERFACE_TYPE /= "oversample")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "INTERFACE_TYPE ",
             EntityName => "/ISERDESE2",
             GenericValue => INTERFACE_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MEMORY, NETWORKING, MEMORY_QDR, MEMORY_DDR3 or OVERSAMPLE.",
             TailMsg => "",
             MsgSeverity => FAILURE
         );
      end if;

-----------------------------------------------------------------
---------------    IOBDELAY validity check    -------------------
-----------------------------------------------------------------
      if((IOBDELAY /= "NONE")  and  (IOBDELAY = "none") and
          (IOBDELAY /= "BOTH") and  (IOBDELAY = "both") and
          (IOBDELAY /= "IFD")  and  (IOBDELAY = "ifd") and
          (IOBDELAY /= "IBUF") and  (IOBDELAY = "ibuf")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " IOBDELAY ",
             EntityName => "/ISERDESE2",
             GenericValue => IOBDELAY,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE or IBUF or IFD or BOTH ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;


-----------------------------------------------------------------
----------------     NUM_CE validity check    -------------------
-----------------------------------------------------------------
      if((NUM_CE /= 1) and (NUM_CE /= 2)) then 
         GenericValueCheckMessage
           (  HeaderMsg  => " Attribute Syntax Warning ",
              GenericName => " NUM_CE ",
              EntityName => "/ISERDESE2",
              GenericValue => NUM_CE,
              Unit => "",
              ExpectedValueMsg => " The Legal values for this attribute are ",
              ExpectedGenericValue => " 1 or 2 ",
              TailMsg => "",
              MsgSeverity => Failure
           );
      end if;

-----------------------------------------------------------------
--------------- OFB_USED validity check -------------------
-----------------------------------------------------------------
      if((OFB_USED /= "TRUE") and (OFB_USED /= "true") and 
         (OFB_USED /= "FALSE") and (OFB_USED /= "false")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " OFB_USED ",
             EntityName => "/ISERDESE2",
             GenericValue => OFB_USED,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
-----------------------------------------------------------------
----------------- SERDES_MODE validity check --------------------
-----------------------------------------------------------------
      if((SERDES_MODE /= "MASTER") and (SERDES_MODE /= "master") and
          (SERDES_MODE /= "SLAVE") and (SERDES_MODE /= "slave")) then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "SERDES_MODE ",
             EntityName => "/ISERDESE2",
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => FAILURE
         );
      end if;
    wait;
  end process prcs_init;

-- CR 574021
--###################################################################
--#####                   Input to ISERDES                      #####
--###################################################################
  prcs_pre_fdbk_d_delay:process(D_indelay, DDLY_indelay)
  begin
       if(IOBDELAY="NONE") then 
               pre_fdbk_O_zd        <= D_indelay;
               pre_fdbk_datain      <= D_indelay;
        elsif(IOBDELAY="IBUF") then
               pre_fdbk_O_zd        <= DDLY_indelay;
               pre_fdbk_datain      <= D_indelay;
        elsif(IOBDELAY="IFD") then
               pre_fdbk_O_zd        <= D_indelay;
               pre_fdbk_datain      <= DDLY_indelay;
        elsif(IOBDELAY="BOTH") then
               pre_fdbk_O_zd        <= DDLY_indelay;
               pre_fdbk_datain      <= DDLY_indelay;
        end if;
  end process prcs_pre_fdbk_d_delay;


    O_zd        <= OFB_indelay when (OFB_USED="TRUE") else pre_fdbk_O_zd;
    datain      <= OFB_indelay when (OFB_USED="TRUE") else pre_fdbk_datain;

----------------------------------------------------------------------------------
    ISERDESE2_INST : ISERDESE2_WRAP
      generic map (
        DATA_RATE            => DATA_RATE,
        DATA_WIDTH           => DATA_WIDTH,
        DYN_CLKDIV_INV_EN    => DYN_CLKDIV_INV_EN,
        DYN_CLK_INV_EN       => DYN_CLK_INV_EN,
        INIT_Q1              => INIT_Q1_STRING,
        INIT_Q2              => INIT_Q2_STRING,
        INIT_Q3              => INIT_Q3_STRING,
        INIT_Q4              => INIT_Q4_STRING,
        INTERFACE_TYPE       => INTERFACE_TYPE,
        IOBDELAY             => IOBDELAY,
        NUM_CE               => NUM_CE,
        OFB_USED             => OFB_USED,
        SERDES_MODE          => SERDES_MODE,
        SRVAL_Q1             => SRVAL_Q1_STRING,
        SRVAL_Q2             => SRVAL_Q2_STRING,
        SRVAL_Q3             => SRVAL_Q3_STRING,
        SRVAL_Q4             => SRVAL_Q4_STRING
      )
      
      port map (
        O                    => O_outdelay,
        Q1                   => Q1_outdelay,
        Q2                   => Q2_outdelay,
        Q3                   => Q3_outdelay,
        Q4                   => Q4_outdelay,
        Q5                   => Q5_outdelay,
        Q6                   => Q6_outdelay,
        Q7                   => Q7_outdelay,
        Q8                   => Q8_outdelay,
        SHIFTOUT1            => SHIFTOUT1_outdelay,
        SHIFTOUT2            => SHIFTOUT2_outdelay,
        BITSLIP              => BITSLIP_indelay,
        CE1                  => CE1_indelay,
        CE2                  => CE2_indelay,
        CLK                  => CLK_indelay,
        CLKB                 => CLKB_indelay,
        CLKDIV               => CLKDIV_indelay,
        CLKDIVP              => CLKDIVP_indelay,
        D                    => datain,
        DDLY                 => DDLY_indelay,
        DYNCLKDIVSEL         => DYNCLKDIVSEL_indelay,
        DYNCLKSEL            => DYNCLKSEL_indelay,
        OCLK                 => OCLK_indelay,
        OCLKB                => OCLKB_indelay,
        OFB                  => OFB_indelay,
        RST                  => RST_indelay,
        SHIFTIN1             => SHIFTIN1_indelay,
        SHIFTIN2             => SHIFTIN2_indelay        
      );
    
    INIPROC : process
    begin
    -- case DATA_RATE is
      if((DATA_RATE = "DDR") or (DATA_RATE = "ddr")) then
        DATA_RATE_BINARY <= '0';
      elsif((DATA_RATE = "SDR") or (DATA_RATE= "sdr")) then
        DATA_RATE_BINARY <= '1';
      else
        assert FALSE report "Error : DATA_RATE = is not DDR, SDR." severity error;
      end if;
    -- end case;
    -- case DYN_CLKDIV_INV_EN is
      if((DYN_CLKDIV_INV_EN = "FALSE") or (DYN_CLKDIV_INV_EN = "false")) then
        DYN_CLKDIV_INV_EN_BINARY <= '0';
      elsif((DYN_CLKDIV_INV_EN = "TRUE") or (DYN_CLKDIV_INV_EN= "true")) then
        DYN_CLKDIV_INV_EN_BINARY <= '1';
      else
        assert FALSE report "Error : DYN_CLKDIV_INV_EN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case DYN_CLK_INV_EN is
      if((DYN_CLK_INV_EN = "FALSE") or (DYN_CLK_INV_EN = "false")) then
        DYN_CLK_INV_EN_BINARY <= '0';
      elsif((DYN_CLK_INV_EN = "TRUE") or (DYN_CLK_INV_EN= "true")) then
        DYN_CLK_INV_EN_BINARY <= '1';
      else
        assert FALSE report "Error : DYN_CLK_INV_EN = is not FALSE, TRUE." severity error;
      end if;
    -- end case;
    -- case OFB_USED is
      if((OFB_USED = "FALSE") or (OFB_USED = "false")) then
        OFB_USED_BINARY <= "00";
      elsif((OFB_USED = "TRUE") or (OFB_USED= "true")) then
        OFB_USED_BINARY <= "11";
      else
        assert FALSE report "Error : OFB_USED = is not FALSE, TRUE." severity error;
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
    case NUM_CE is
      when  2   =>  NUM_CE_BINARY <= '1';
      when  1   =>  NUM_CE_BINARY <= '0';
      when others  =>  assert FALSE report "Error : NUM_CE is not in range 1 .. 2." severity error;
    end case;
    if ((DATA_WIDTH >= 2) and (DATA_WIDTH <= 14)) then
      DATA_WIDTH_BINARY <= CONV_STD_LOGIC_VECTOR(DATA_WIDTH, 4);
    else
      assert FALSE report "Error : DATA_WIDTH is not in range 2 .. 14." severity error;
    end if;
    wait;
    end process INIPROC;
    O <= O_out;
    Q1 <= Q1_out;
    Q2 <= Q2_out;
    Q3 <= Q3_out;
    Q4 <= Q4_out;
    Q5 <= Q5_out;
    Q6 <= Q6_out;
    Q7 <= Q7_out;
    Q8 <= Q8_out;
    SHIFTOUT1 <= SHIFTOUT1_out;
    SHIFTOUT2 <= SHIFTOUT2_out;
  end ISERDESE2_V;
