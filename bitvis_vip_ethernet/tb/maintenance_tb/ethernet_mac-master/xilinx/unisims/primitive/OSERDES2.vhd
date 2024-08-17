-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/stan/VITAL/OSERDES2.vhd,v 1.12 2009/08/22 00:26:01 harikr Exp $
-------------------------------------------------------
--  Copyright (c) 2008 Xilinx Inc.
--  All Right Reserved.
-------------------------------------------------------
--
--   ____  ____
--  /   /\/   / 
-- /___/  \  /     Vendor      : Xilinx 
-- \   \   \/      Version : 11.1
--  \   \          Description : Xilinx Functional Simulation Library Component
--  /   /                  Source Synchronous Onput Serializer for the Spartan Series
-- /___/   /\      Filename    : OSERDES2.vhd
-- \   \  /  \      
--  \__ \/\__ \                   
--                               
-- Revision:     Date:  Comment
--      1.0: 01/16/08:  Initial version.
--      1.1: 11/13/08:  IR495203 Gate behavior with OCE, TCE.
--                      Fix specify block
--      1.2: 12/11/08:  delay internal ioce by 1 ioclk
--      1.3: 01/30/09:  CR504529 add BYPASS_GCLK_FF attribute
--      1.4: 02/11/09:  CR507848 add missing MODULE_NAME constant
--      1.5: 03/05/09:  CR511015 VHDL - VER sync
--      1.6: 04/02/09:  CR513901 unisim-simprim mismatch, proceedure -> when, else
--      1.7: 07/07/09:  CR524403 Add NONE to valid serdes_mode values

-- End Revision
-------------------------------------------------------

----- CELL OSERDES2 -----

library IEEE;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

library unisim;
use unisim.VCOMPONENTS.all;
use unisim.vpkg.all;

  entity OSERDES2 is
    generic (
      BYPASS_GCLK_FF : boolean := FALSE;
      DATA_RATE_OQ : string := "DDR";
      DATA_RATE_OT : string := "DDR";
      DATA_WIDTH : integer := 2;
      OUTPUT_MODE : string := "SINGLE_ENDED";
      SERDES_MODE : string := "NONE";
      TRAIN_PATTERN : integer := 0
    );

    port (
      OQ                   : out std_ulogic;
      SHIFTOUT1            : out std_ulogic;
      SHIFTOUT2            : out std_ulogic;
      SHIFTOUT3            : out std_ulogic;
      SHIFTOUT4            : out std_ulogic;
      TQ                   : out std_ulogic;
      CLK0                 : in std_ulogic;
      CLK1                 : in std_ulogic;
      CLKDIV               : in std_ulogic;
      D1                   : in std_ulogic;
      D2                   : in std_ulogic;
      D3                   : in std_ulogic;
      D4                   : in std_ulogic;
      IOCE                 : in std_ulogic := 'H';
      OCE                  : in std_ulogic := 'H';
      RST                  : in std_ulogic;
      SHIFTIN1             : in std_ulogic;
      SHIFTIN2             : in std_ulogic;
      SHIFTIN3             : in std_ulogic;
      SHIFTIN4             : in std_ulogic;
      T1                   : in std_ulogic;
      T2                   : in std_ulogic;
      T3                   : in std_ulogic;
      T4                   : in std_ulogic;
      TCE                  : in std_ulogic;
      TRAIN                : in std_ulogic      
    );
  end OSERDES2;

  architecture OSERDES2_V of OSERDES2 is

    constant MODULE_NAME : string  := "OSERDES2";
    constant IN_DELAY : time := 1 ps;
    constant OUT_DELAY : time := 1 ps;
    constant INCLK_DELAY : time := 0 ps;
    constant OUTCLK_DELAY : time := 0 ps;

    signal BYPASS_GCLK_FF_BINARY : std_ulogic := '0';
    signal DATA_RATE_OQ_BINARY : std_logic_vector(1 downto 0);
    signal DATA_RATE_OT_BINARY : std_logic_vector(4 downto 0);
    signal DATA_WIDTH_BINARY : std_logic_vector(7 downto 0);
    signal OUTPUT_MODE_BINARY : std_ulogic;
    signal SERDES_MODE_BINARY : std_ulogic;
    signal TRAIN_PATTERN_BINARY : std_ulogic;
    
    signal OQ_out : std_ulogic := '0';
    signal SHIFTOUT1_out : std_ulogic := '0';
    signal SHIFTOUT2_out : std_ulogic := '0';
    signal SHIFTOUT3_out : std_ulogic := '0';
    signal SHIFTOUT4_out : std_ulogic := '0';
    signal TQ_out : std_ulogic := '0';
    
    signal OQ_outdelay : std_ulogic;
    signal SHIFTOUT1_outdelay : std_ulogic;
    signal SHIFTOUT2_outdelay : std_ulogic;
    signal SHIFTOUT3_outdelay : std_ulogic;
    signal SHIFTOUT4_outdelay : std_ulogic;
    signal TQ_outdelay : std_ulogic;
    
    signal CLK0_ipd : std_ulogic;
    signal CLK1_ipd : std_ulogic;
    signal CLKDIV_ipd : std_ulogic;
    signal D1_ipd : std_ulogic;
    signal D2_ipd : std_ulogic;
    signal D3_ipd : std_ulogic;
    signal D4_ipd : std_ulogic;
    signal IOCE_ipd : std_ulogic;
    signal OCE_ipd : std_ulogic;
    signal RST_ipd : std_ulogic;
    signal SHIFTIN1_ipd : std_ulogic;
    signal SHIFTIN2_ipd : std_ulogic;
    signal SHIFTIN3_ipd : std_ulogic;
    signal SHIFTIN4_ipd : std_ulogic;
    signal T1_ipd : std_ulogic;
    signal T2_ipd : std_ulogic;
    signal T3_ipd : std_ulogic;
    signal T4_ipd : std_ulogic;
    signal TCE_ipd : std_ulogic;
    signal TRAIN_ipd : std_ulogic;
    
    signal CLK0_indelay : std_ulogic;
    signal CLK1_indelay : std_ulogic;
    signal CLKDIV_indelay : std_ulogic;
    signal D1_indelay : std_ulogic;
    signal D2_indelay : std_ulogic;
    signal D3_indelay : std_ulogic;
    signal D4_indelay : std_ulogic;
    signal IOCE_indelay : std_ulogic;
    signal OCE_indelay : std_ulogic;
    signal RST_indelay : std_ulogic;
    signal SHIFTIN1_indelay : std_ulogic;
    signal SHIFTIN2_indelay : std_ulogic;
    signal SHIFTIN3_indelay : std_ulogic;
    signal SHIFTIN4_indelay : std_ulogic;
    signal T1_indelay : std_ulogic;
    signal T2_indelay : std_ulogic;
    signal T3_indelay : std_ulogic;
    signal T4_indelay : std_ulogic;
    signal TCE_indelay : std_ulogic;
    signal TRAIN_indelay : std_ulogic;
    signal GSR_indelay : std_ulogic;
    
-- FF outputs
  signal tgff            : std_logic_vector(3 downto 0) := (others => '0');
  signal toff            : std_logic_vector(3 downto 0) := (others => '0');
  signal dgff            : std_logic_vector(3 downto 0) := (others => '0');
  signal doff            : std_logic_vector(3 downto 0) := (others => '0');
  signal tdata           : std_logic_vector(3 downto 0) := (others => '0');
  signal ddata           : std_logic_vector(3 downto 0) := (others => '0');

  signal tlsb            : std_ulogic := '0';
  signal dlsb            : std_ulogic := '0';
  signal tpre            : std_ulogic := '0';
  signal dpre            : std_ulogic := '0';

  signal Tff             : std_ulogic := '0';
  signal Dff             : std_ulogic := '0';

  signal Tpf             : std_ulogic := '0';
  signal Dpf             : std_ulogic := '0';

  signal one_shot_OCE    : std_ulogic := '1';
  signal one_shot_TCE    : std_ulogic := '1';
  signal ioce_int        : std_ulogic := '0';

-- Other nodes
  signal tcasc_in        : std_ulogic := 'X';
  signal dcasc_in        : std_ulogic := 'X';
  signal tinit           : std_ulogic := '0';

  signal trainp          : std_logic_vector(3 downto 0) := (others => 'X');

-- clk doubler signals 
  signal clk0_int       : std_ulogic := '0';
  signal clk1_int       : std_ulogic := '0';
  signal clk_int        : std_ulogic := 'X';

-- Attribute settings 
  signal data_rate_int  : std_ulogic := '0';
  signal encasc     : std_ulogic := 'X'; -- 1 = enable cascade input
  signal isslave    : std_ulogic := 'X'; -- 1 = slave mode
  signal endiffop   : std_ulogic := 'X'; -- 1 = enable pseudo diff output
  signal enTCE      : std_ulogic := 'X';  --1 = enable the tristate path
  signal bypassTFF  : std_ulogic := 'X'; -- 1 = direct out

-- Other signal
  signal BYPASS_GCLK_FF_err_flag   : boolean := FALSE;
  signal data_rate_oq_err_flag     : boolean := FALSE;
  signal data_rate_tq_err_flag     : boolean := FALSE;
  signal data_width_err_flag       : boolean := FALSE;
  signal output_mode_err_flag      : boolean := FALSE;
  signal serdes_mode_err_flag      : boolean := FALSE;
  signal train_pattern_err_flag    : boolean := FALSE;
  signal attr_err_flag             : std_ulogic := '0';

    begin
    OQ_out <= OQ_outdelay after OUT_DELAY;
    SHIFTOUT1_out <= SHIFTOUT1_outdelay after OUT_DELAY;
    SHIFTOUT2_out <= SHIFTOUT2_outdelay after OUT_DELAY;
    SHIFTOUT3_out <= SHIFTOUT3_outdelay after OUT_DELAY;
    SHIFTOUT4_out <= SHIFTOUT4_outdelay after OUT_DELAY;
    TQ_out <= TQ_outdelay after OUT_DELAY;
    
    CLK0_ipd <= CLK0;
    CLK1_ipd <= CLK1;
    CLKDIV_ipd <= CLKDIV;
    
    D1_ipd <= D1;
    D2_ipd <= D2;
    D3_ipd <= D3;
    D4_ipd <= D4;
    IOCE_ipd <= IOCE;
    OCE_ipd <= OCE;
    RST_ipd <= RST;
    SHIFTIN1_ipd <= SHIFTIN1;
    SHIFTIN2_ipd <= SHIFTIN2;
    SHIFTIN3_ipd <= SHIFTIN3;
    SHIFTIN4_ipd <= SHIFTIN4;
    T1_ipd <= T1;
    T2_ipd <= T2;
    T3_ipd <= T3;
    T4_ipd <= T4;
    TCE_ipd <= TCE;
    TRAIN_ipd <= TRAIN;
    
    CLK0_indelay <= CLK0_ipd after INCLK_DELAY;
    CLK1_indelay <= CLK1_ipd after INCLK_DELAY;
    CLKDIV_indelay <= CLKDIV_ipd after INCLK_DELAY;
    
    D1_indelay <= D1_ipd after IN_DELAY;
    D2_indelay <= D2_ipd after IN_DELAY;
    D3_indelay <= D3_ipd after IN_DELAY;
    D4_indelay <= D4_ipd after IN_DELAY;
    IOCE_indelay <= IOCE_ipd after IN_DELAY;
    OCE_indelay <= OCE_ipd after IN_DELAY;
    RST_indelay <= RST_ipd after IN_DELAY;
    SHIFTIN1_indelay <= SHIFTIN1_ipd after IN_DELAY;
    SHIFTIN2_indelay <= SHIFTIN2_ipd after IN_DELAY;
    SHIFTIN3_indelay <= SHIFTIN3_ipd after IN_DELAY;
    SHIFTIN4_indelay <= SHIFTIN4_ipd after IN_DELAY;
    T1_indelay <= T1_ipd after IN_DELAY;
    T2_indelay <= T2_ipd after IN_DELAY;
    T3_indelay <= T3_ipd after IN_DELAY;
    T4_indelay <= T4_ipd after IN_DELAY;
    TCE_indelay <= TCE_ipd after IN_DELAY;
    TRAIN_indelay <= TRAIN_ipd after IN_DELAY;
    GSR_indelay      <= GSR after IN_DELAY;
--####################################################################
--#####                     Initialize                           #####
--####################################################################


    INIPROC : process
    begin
-------------------------------------------------
------ BYPASS_GCLK_FF Check
-------------------------------------------------
      if(BYPASS_GCLK_FF = TRUE) then BYPASS_GCLK_FF_BINARY <= '1';
      elsif(BYPASS_GCLK_FF = FALSE) then BYPASS_GCLK_FF_BINARY <= '0';
      else
        wait for 1 ps;
        GenericValueCheckMessage
         (  HeaderMsg  => " Attribute Syntax Error ",
            GenericName => " BYPASS_GCLK_FF ",
            EntityName => MODULE_NAME,
            GenericValue => BYPASS_GCLK_FF,
            Unit => "",
            ExpectedValueMsg => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TRUE or FALSE.",
            TailMsg => "",
            MsgSeverity => Warning 
        );
        BYPASS_GCLK_FF_err_flag <= TRUE;
      end if;

-------------------------------------------------
------ DATA_RATE_OQ Check
-------------------------------------------------
        if((DATA_RATE_OQ = "DDR") or (DATA_RATE_OQ = "ddr")) then
          DATA_RATE_OQ_BINARY <= "01";
          data_rate_int <= '0';
        elsif((DATA_RATE_OQ = "SDR") or (DATA_RATE_OQ= "sdr")) then
          DATA_RATE_OQ_BINARY <= "10";
        else
          wait for 1 ps;
          GenericValueCheckMessage
           (  HeaderMsg  => " Attribute Syntax Error ",
              GenericName => " DATA_RATE_OQ ",
              EntityName => MODULE_NAME,
              GenericValue => DATA_RATE_OQ,
              Unit => "",
              ExpectedValueMsg => " The Legal values for this attribute are ",
              ExpectedGenericValue => " DDR or SDR.",
              TailMsg => "",
              MsgSeverity => Warning 
          );
          data_rate_oq_err_flag <= TRUE;
        end if;
  
-------------------------------------------------
------ DATA_RATE_OT Check
-------------------------------------------------

        if((DATA_RATE_OT = "DDR") or (DATA_RATE_OT = "ddr")) then
          DATA_RATE_OT_BINARY <= "11010";
          tinit <= '1';
          enTCE <= '1';
          bypassTFF <= '0';
          if((DATA_RATE_OQ = "SDR") or (DATA_RATE_OT = "sdr")) then
             wait for 1 ps;
             GenericValueCheckMessage
              (  HeaderMsg  => " Attribute Conflict Error ",
                 GenericName => " DATA_RATE_OT ",
                 EntityName => MODULE_NAME,
                 GenericValue => DATA_RATE_OT,
                 Unit => "",
                 ExpectedValueMsg => " When DATA_RATE_OT is DDR ",
                 ExpectedGenericValue => " DATA_RATE_OQ must also be DDR ",
                 TailMsg => "",
                 MsgSeverity => Warning 
             );
             data_rate_tq_err_flag <= TRUE;
          end if;
        elsif((DATA_RATE_OT = "BUF") or (DATA_RATE_OT= "buf")) then
          DATA_RATE_OT_BINARY <= "00001";
          tinit <= '0';
          enTCE <= '0';
          bypassTFF <= '1';
        elsif((DATA_RATE_OT = "SDR") or (DATA_RATE_OT= "sdr")) then
          DATA_RATE_OT_BINARY <= "11100";
          tinit <= '1';
          enTCE <= '1';
          bypassTFF <= '0';
          if((DATA_RATE_OQ = "DDR") or (DATA_RATE_OQ = "ddr")) then
            wait for 1 ps;
            GenericValueCheckMessage
             (  HeaderMsg  => " Attribute Conflict Error ",
                GenericName => " DATA_RATE_OT ",
                EntityName => MODULE_NAME,
                GenericValue => DATA_RATE_OT,
                Unit => "",
                ExpectedValueMsg => " When DATA_RATE_OT is SDR ",
                ExpectedGenericValue => " DATA_RATE_OQ must also be SDR ",
                TailMsg => "",
                MsgSeverity => Warning 
            );
            data_rate_tq_err_flag <= TRUE;
          end if;
        else
          wait for 1 ps;
          GenericValueCheckMessage
           (  HeaderMsg  => " Attribute Syntax Error ",
              GenericName => " DATA_RATE_OT ",
              EntityName => MODULE_NAME,
              GenericValue => DATA_RATE_OT,
              Unit => "",
              ExpectedValueMsg => " The Legal values for this attribute are ",
              ExpectedGenericValue => " DDR, SDR or BUF.",
              TailMsg => "",
              MsgSeverity => Warning 
          );
          data_rate_tq_err_flag <= TRUE;
        end if;
  
-------------------------------------------------
------ OUTPUT_MODE Check
-------------------------------------------------
      if((OUTPUT_MODE = "DIFFERENTIAL") or (OUTPUT_MODE= "differential")) then
        OUTPUT_MODE_BINARY <= '1';
        endiffop <= '1';
      elsif((OUTPUT_MODE = "SINGLE_ENDED") or (OUTPUT_MODE = "single_ended")) then
        OUTPUT_MODE_BINARY <= '0';
        if (((SERDES_MODE = "SLAVE") or (SERDES_MODE = "slave")) or (DATA_WIDTH < 5)) then
           endiffop <= '0';
        else
           endiffop <= '1';
        end if;
      else
        wait for 1 ps;
        GenericValueCheckMessage
         (  HeaderMsg  => " Attribute Syntax Error ",
            GenericName => " OUTPUT_MODE ",
            EntityName => MODULE_NAME,
            GenericValue => OUTPUT_MODE,
            Unit => "",
            ExpectedValueMsg => " The Legal values for this attribute are ",
            ExpectedGenericValue => " DIFFERENTIAL or SINGLE_ENDED.",
            TailMsg => "",
            MsgSeverity => Warning 
        );
        output_mode_err_flag <= TRUE;
      end if;

-------------------------------------------------
------ DATA_WIDTH Check
-------------------------------------------------

      if ((DATA_WIDTH > 0) and (DATA_WIDTH <= 8)) then
        DATA_WIDTH_BINARY <= CONV_STD_LOGIC_VECTOR(DATA_WIDTH, 8);
      else
        wait for 1 ps;
        GenericValueCheckMessage
         (  HeaderMsg  => " Attribute Syntax Error ",
            GenericName => " DATA_WIDTH ",
            EntityName => MODULE_NAME,
            GenericValue => DATA_WIDTH,
            Unit => "",
            ExpectedValueMsg => " The Legal values for this attribute are ",
            ExpectedGenericValue => " 1, 2, 3, 4, 5, 6, 7, or 8.",
            TailMsg => "",
            MsgSeverity => Warning
        );
        data_width_err_flag <= TRUE;
      end if;

-------------------------------------------------
------ SERDES_MODE Check
-------------------------------------------------
      if((SERDES_MODE = "NONE") or (SERDES_MODE = "none")) then
         isslave <= '0';
         encasc <= '0';
      elsif((SERDES_MODE = "MASTER") or (SERDES_MODE = "master")) then
         isslave <= '0';
         encasc <= '0';
      elsif((SERDES_MODE = "SLAVE") or (SERDES_MODE = "slave")) then 
         isslave <= '1';
         if (DATA_WIDTH > 4) then
             encasc <= '1';
         else
             encasc <= '0';
         end if;
      else
         wait for 1 ps;
         GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " SERDES_MODE ",
             EntityName => MODULE_NAME,
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE, MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => Warning 
         );
         serdes_mode_err_flag <= TRUE;
      end if;


-------------------------------------------------
------ TRAIN_PATTERN Check
-------------------------------------------------

      if((TRAIN_PATTERN < 0) or (TRAIN_PATTERN > 15)) then
         wait for 1 ps;
         GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " TRAIN_PATTERN ",
             EntityName => MODULE_NAME,
             GenericValue => TRAIN_PATTERN,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 0, 1, 2, ... 13, 14, 15.",
             TailMsg => "",
             MsgSeverity => Warning
         );
         train_pattern_err_flag <= TRUE;
      else
         trainp <= CONV_STD_LOGIC_VECTOR(TRAIN_PATTERN, 4);
      end if;

-------------------------------------------------
------  Error Flag
-------------------------------------------------

      wait for 1 ps;

      if (data_rate_oq_err_flag or data_rate_tq_err_flag or
          data_width_err_flag   or output_mode_err_flag  or
          serdes_mode_err_flag or train_pattern_err_flag or
          BYPASS_GCLK_FF_err_flag) then
         attr_err_flag <= '1';
         wait for 1 ps;
         ASSERT FALSE REPORT "Attribute Errors detected, simulation cannot continue. Exiting ..." SEVERITY Failure;

      end if;

      wait;
      end process INIPROC;
--####################################################################
--#####                       DDR doubler                        #####
--####################################################################
  prcs_ddr_dblr_clk0:process(CLK0_indelay)
  begin
     if(rising_edge(CLK0_indelay)) then
        clk0_int <= '1',
                    '0' after 100 ps;
     end if;
  end process prcs_ddr_dblr_clk0;


  prcs_ddr_dblr_clk1:process(CLK1_indelay)
  begin
     if(rising_edge(CLK1_indelay) and (DATA_RATE_OQ = "DDR")) then
         clk1_int <= '1', 
                     '0' after 100 ps;
     end if;
  end process prcs_ddr_dblr_clk1;

  clk_int <= clk0_int or clk1_int;

--####################################################################
--#####                    IOCE sample                           #####
--####################################################################
  prcs_ioce_int:process(clk_int, RST_indelay)
  begin
     if(RST_indelay = '1') then
         ioce_int <= '0'; 
     elsif(rising_edge(clk_int) and (RST_indelay = '0')) then
         ioce_int <= IOCE_indelay; 
     end if;
  end process prcs_ioce_int;

--####################################################################
--#####                   GCLK Register Banks                    #####
--####################################################################
  prcs_dgff:process(CLKDIV_indelay, GSR_indelay, RST_indelay)
  begin
     if((GSR_indelay = '1') or (RST_indelay = '1'))then
         dgff(3) <= '0';
         dgff(2) <= '0';
         dgff(1) <= '0';
         dgff(0) <= '0';
     elsif(rising_edge(CLKDIV_indelay) and (GSR_indelay = '0') and (RST_indelay = '0') and (OCE_indelay = '1'))then
         dgff(3) <= D4_indelay;
         dgff(2) <= D3_indelay;
         dgff(1) <= D2_indelay;
         dgff(0) <= D1_indelay;
     end if;
  end process prcs_dgff;

  prcs_tgff:process(CLKDIV_indelay, GSR_indelay, RST_indelay)
  begin
     if((GSR_indelay = '1') or (RST_indelay = '1'))then
         tgff(3) <= '0'; -- tinit;
         tgff(2) <= '0'; -- tinit;
         tgff(1) <= '0'; -- tinit;
         tgff(0) <= '0'; -- tinit;
     elsif(rising_edge(CLKDIV_indelay) and (GSR_indelay = '0') and (RST_indelay = '0') and (TCE_indelay = '1'))then
         tgff(3) <= T4_indelay;
         tgff(2) <= T3_indelay;
         tgff(1) <= T2_indelay;
         tgff(0) <= T1_indelay;
     end if;
  end process prcs_tgff;
--####################################################################
--#####                   Bypass Muxes                           #####
--####################################################################
     ddata <= trainp when (TRAIN_indelay = '1') else
              (D4_indelay & D3_indelay & D2_indelay & D1_indelay) when (BYPASS_GCLK_FF_BINARY = '1') else
              dgff;

     tdata <= (T4_indelay & T3_indelay & T2_indelay & T1_indelay) when (BYPASS_GCLK_FF_BINARY = '1') else
              tgff;
--####################################################################
--#####             Top of Shift Registers                       #####
--####################################################################
  prcs_dcascin:process
  begin
     if(encasc = '1') then
         dcasc_in <= SHIFTIN1_indelay;
     else
         dcasc_in <= '0'; 
     end if;
     wait on SHIFTIN1_indelay, encasc;
   end process prcs_dcascin;

  prcs_tcascin:process
  begin
     if(encasc = '1') then
         tcasc_in <= SHIFTIN2_indelay;
     else
         tcasc_in <= '0'; 
     end if;
     wait on SHIFTIN2_indelay, encasc;
   end process prcs_tcascin;

--####################################################################
--#####             Output Shift Registers                       #####
--####################################################################
  prcs_dofftoff:process(clk_int, GSR_indelay, RST_indelay)
  begin
     if((GSR_indelay = '1') or (RST_indelay = '1'))then
         doff(3) <= '0';
         doff(2) <= '0';
         doff(1) <= '0';
         doff(0) <= '0';
         toff(3) <= '0'; -- tinit;
         toff(2) <= '0'; -- tinit;
         toff(1) <= '0'; -- tinit;
         toff(0) <= '0'; -- tinit;
     elsif(rising_edge(clk_int) and (GSR_indelay = '0') and (RST_indelay = '0') ) then
        if (ioce_int = '1') then
           if (OCE_indelay = '1') then doff <= ddata; end if;
           if (TCE_indelay = '1') then toff <= tdata; end if;
        else
           if (OCE_indelay = '1') then doff <= (dcasc_in & doff(3 downto 1)); end if;
           if (TCE_indelay = '1') then toff <= (tcasc_in & toff(3 downto 1)); end if;
        end if;
     end if;
  end process prcs_dofftoff;
    
--####################################################################
--#####             Bottom of Shift Registers                    #####
--####################################################################
  SHIFTOUT1_outdelay <= doff(0); -- MASTER
  SHIFTOUT2_outdelay <= toff(0); -- MASTER

  SHIFTOUT3_outdelay <= dlsb;    -- SLAVE
  SHIFTOUT4_outdelay <= tlsb;    -- SLAVE
    
  prcs_dlsb:process(ioce_int, ddata(0), doff(1))
  begin
     if(ioce_int = '1') then
         dlsb <= ddata(0);
     else
         dlsb <= doff(1);
     end if;
  end process prcs_dlsb;
    
  prcs_tlsb:process(ioce_int, tdata(0), toff(1), T1_indelay)
  begin
     if(bypassTFF = '1') then
         tlsb <= T1_indelay;
     elsif(ioce_int = '1') then
         tlsb <= tdata(0);
     else
         tlsb <= toff(1);
     end if;
  end process prcs_tlsb;
    
  prcs_dpre:process(dlsb, SHIFTIN3_indelay, endiffop, isslave)
  begin
     if(endiffop = '0') then
        dpre <= dlsb;
     elsif(isslave = '1') then
        dpre <= not dlsb;
     else
        dpre <= SHIFTIN3_indelay;
     end if;
   end process prcs_dpre;

  prcs_tpre:process(tlsb, SHIFTIN4_indelay, endiffop, isslave)
  begin
     if(endiffop = '0') then
        tpre <= tlsb;
     elsif(isslave = '1') then
        tpre <= tlsb;
     else
        tpre <= SHIFTIN4_indelay;
     end if;
   end process prcs_tpre;

--####################################################################
--#####                    Output Sampling FFs                   #####
--####################################################################
  prcs_DpfTpf:process(clk_int, GSR_indelay, RST_indelay)
  begin
     if (GSR_indelay = '1') then
         Dpf <= '0';
         Tpf <= '0'; -- should be tinit
         one_shot_OCE <= '1';
         one_shot_TCE <= '1';
     elsif(RST_indelay = '1') then
         Dpf <= isslave and endiffop; -- '0'
         Tpf <= '0'; -- should be tinit
         one_shot_OCE <= '1';
         one_shot_TCE <= '1';
     elsif(rising_edge(clk_int) and (GSR_indelay = '0') and (RST_indelay = '0') ) then
         if (OCE_indelay = '1') then Dpf <= dpre; end if;
         if (TCE_indelay = '1') then Tpf <= tpre; end if;
         if (OCE_indelay = '1') then one_shot_OCE <= '0'; end if;
         if (TCE_indelay = '1') then one_shot_TCE <= '0'; end if;
     end if;
  end process prcs_DpfTpf;
  prcs_DffTff:process(clk_int, GSR_indelay, RST_indelay)
  begin
     if(GSR_indelay = '1') then
         Dff <= '0';
         Tff <= '0';
     elsif(RST_indelay = '1') then
         Dff <= '0';
         Tff <= tinit;
     elsif(rising_edge(clk_int) and (GSR_indelay = '0') and (RST_indelay = '0') )then
         if (OCE_indelay = '1') then
            if (one_shot_OCE = '1') then
               Dff <= Dpf;
            else
               Dff <= dpre;
            end if;
         end if;
         if (TCE_indelay = '1') then
            if (one_shot_TCE = '1') then
               Tff <= Tpf;
            else
               Tff <= tpre;
            end if;
         end if;
     end if;
  end process prcs_DffTff;
--####################################################################
--#####                   Final Output Mux                       #####
--####################################################################
  prcs_oqout:process(Dff)
  begin
     OQ_outdelay <= Dff;
  end process prcs_oqout;

  prcs_tqout:process(Tff, tpre)
  begin
     if( bypassTFF = '1') then
        TQ_outdelay <= tpre;
     else
        TQ_outdelay <= Tff;
     end if;
  end process prcs_tqout;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
    OQ <= OQ_out;
    SHIFTOUT1 <= SHIFTOUT1_out;
    SHIFTOUT2 <= SHIFTOUT2_out;
    SHIFTOUT3 <= SHIFTOUT3_out;
    SHIFTOUT4 <= SHIFTOUT4_out;
    TQ <= TQ_out;
--####################################################################
    end OSERDES2_V;
